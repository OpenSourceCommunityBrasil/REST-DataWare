Unit uRESTDWFCMOpenSSLHTTP;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMTransport;

Type
  TRESTDWFCMOpenSSLHTTPTransport = Class(TRESTDWFCMHTTPTransport)
  Private
    FVerifyPeer : Boolean;
    FCAFile     : String;
    FCAPath     : String;

    Function DecodeChunked(Const AData : AnsiString) : AnsiString;
  Public
    Constructor Create;

    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Override;

    Function Post(Const AURL       : String;
                  AHeaders         : TStrings;
                  ABody            : TStream;
                  AResponse        : TStream;
                  AResponseError   : TStream) : Integer; Override;
  End;

Implementation

Uses
  uRESTDWOpenSslLib,
  uRESTDWFCMTLS;

Constructor TRESTDWFCMOpenSSLHTTPTransport.Create;
Begin
  Inherited Create;
  FVerifyPeer := True;
  FCAFile := '';
  FCAPath := '';
End;

Procedure TRESTDWFCMOpenSSLHTTPTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                                      Const ACAFile,
                                                            ACAPath : String);
Begin
  FVerifyPeer := AVerifyPeer;
  FCAFile := ACAFile;
  FCAPath := ACAPath;
End;

Procedure ParseHTTPSURL(Const AURL : String;
                        Var AHost,
                            APath : String;
                        Var APort : Integer);
Var
  S : String;
  P,
  C : Integer;
Begin
  S := Trim(AURL);

  If Pos('https://', LowerCase(S)) <> 1 Then
    Raise Exception.Create('FCM HTTP: somente HTTPS e suportado');

  Delete(S, 1, Length('https://'));

  P := Pos('/', S);
  If P = 0 Then
  Begin
    AHost := S;
    APath := '/';
  End
  Else
  Begin
    AHost := Copy(S, 1, P - 1);
    APath := Copy(S, P, MaxInt);
  End;

  APort := 443;

  C := Pos(':', AHost);
  If C > 0 Then
  Begin
    APort := StrToIntDef(Copy(AHost, C + 1, MaxInt), 443);
    AHost := Copy(AHost, 1, C - 1);
  End;
End;

Function HexToInt(Const AValue : String) : Integer;
Var
  I,
  LDigit : Integer;
  C : Char;
Begin
  Result := 0;

  For I := 1 To Length(AValue) Do
  Begin
    C := UpCase(AValue[I]);

    If (C >= '0') And (C <= '9') Then
      LDigit := Ord(C) - Ord('0')
    Else
    If (C >= 'A') And (C <= 'F') Then
      LDigit := Ord(C) - Ord('A') + 10
    Else
      Break;

    Result := (Result Shl 4) Or LDigit;
  End;
End;

Function TRESTDWFCMOpenSSLHTTPTransport.DecodeChunked(Const AData : AnsiString) : AnsiString;
Var
  LPos,
  LEnd,
  LChunkSize,
  LSemi : Integer;
  LLine : String;
Begin
  Result := '';
  LPos := 1;

  While LPos <= Length(AData) Do
  Begin
    LEnd := LPos;

    While (LEnd < Length(AData)) And
          Not ((AData[LEnd] = #13) And
               (AData[LEnd + 1] = #10)) Do
      Inc(LEnd);

    If LEnd >= Length(AData) Then
      Raise Exception.Create('FCM HTTPS: resposta chunked invalida');

    LLine := String(Copy(AData, LPos, LEnd - LPos));
    LSemi := Pos(';', LLine);

    If LSemi > 0 Then
      LLine := Copy(LLine, 1, LSemi - 1);

    LLine := Trim(LLine);

    If LLine = '' Then
      Raise Exception.Create('FCM HTTPS: tamanho de chunk ausente');

    LChunkSize := StrToIntDef('$' + LLine, -1);

    If LChunkSize < 0 Then
      Raise Exception.Create('FCM HTTPS: tamanho de chunk invalido');

    LPos := LEnd + 2;

    If LChunkSize = 0 Then
      Exit;

    If LChunkSize > Length(AData) - LPos + 1 Then
      Raise Exception.Create('FCM HTTPS: chunk truncado');

    Result := Result + Copy(AData, LPos, LChunkSize);
    Inc(LPos, LChunkSize);

    If Copy(AData, LPos, 2) <> #13#10 Then
      Raise Exception.Create('FCM HTTPS: terminador de chunk invalido');

    Inc(LPos, 2);
  End;
End;

Function TRESTDWFCMOpenSSLHTTPTransport.Post(Const AURL       : String;
                                             AHeaders         : TStrings;
                                             ABody            : TStream;
                                             AResponse        : TStream;
                                             AResponseError   : TStream) : Integer;
Var
  LContext : PSSL_CTX;
  LBIO     : PBIO;
  LSSL     : PSSL;
  LHost,
  LPath,
  LHostPort : String;
  LRequest,
  LRaw,
  LHeader,
  LBodyText,
  LResponseBody,
  LStatusLine : AnsiString;
  LPort,
  I,
  P,
  LHeaderEnd,
  LStatusEnd,
  LRead,
  LContentLength : Integer;
  LBuffer : Array[0..8191] Of Byte;
  LBodyBytes : TMemoryStream;
  LChunked : Boolean;
Begin
  Result := 0;

  If AResponse <> Nil Then
  Begin
    AResponse.Size := 0;
    AResponse.Position := 0;
  End;

  If AResponseError <> Nil Then
  Begin
    AResponseError.Size := 0;
    AResponseError.Position := 0;
  End;

  ParseHTTPSURL(AURL,
                LHost,
                LPath,
                LPort);

  LBodyBytes := TMemoryStream.Create;
  Try
    If ABody <> Nil Then
    Begin
      ABody.Position := 0;
      LBodyBytes.CopyFrom(ABody, 0);
    End;

    LRequest :=
      AnsiString(
        'POST ' + LPath + ' HTTP/1.1' + #13#10 +
        'Host: ' + LHost + #13#10 +
        'Connection: close' + #13#10 +
        'Content-Length: ' + IntToStr(LBodyBytes.Size) + #13#10
      );

    If AHeaders <> Nil Then
      For I := 0 To AHeaders.Count - 1 Do
        If AHeaders.Names[I] <> '' Then
          LRequest :=
            LRequest +
            AnsiString(
              AHeaders.Names[I] + ': ' +
              AHeaders.ValueFromIndex[I] + #13#10
            );

    LRequest := LRequest + #13#10;

    LContext := SSL_CTX_new(TLSv1_2_client_method);
    If LContext = Nil Then
      Raise Exception.Create('FCM HTTPS: SSL_CTX_new falhou');

    Try
      RESTDWFCMConfigureTLSContext(
        LContext,
        FVerifyPeer,
        FCAFile,
        FCAPath
      );
    Except
      SSL_CTX_free(LContext);
      Raise;
    End;

    LBIO := BIO_new_ssl_connect(LContext);
    If LBIO = Nil Then
    Begin
      SSL_CTX_free(LContext);
      Raise Exception.Create('FCM HTTPS: BIO_new_ssl_connect falhou');
    End;

    Try
      LHostPort := LHost + ':' + IntToStr(LPort);

      If BIO_ctrl(LBIO,
                  BIO_C_SET_CONNECT,
                  0,
                  PAnsiChar(AnsiString(LHostPort))) <= 0 Then
        Raise Exception.Create('FCM HTTPS: host invalido');

      LSSL := Nil;

      BIO_ctrl(LBIO,
               BIO_C_GET_SSL,
               0,
               @LSSL);

      If LSSL <> Nil Then
        RESTDWFCMConfigureTLSConnection(
          LSSL,
          LHost,
          FVerifyPeer
        );

      If BIO_ctrl(LBIO,
                  BIO_C_DO_STATE_MACHINE,
                  0,
                  Nil) <= 0 Then
        Raise Exception.Create('FCM HTTPS: conexao TLS falhou');

      RESTDWFCMCheckTLSConnection(
        LSSL,
        FVerifyPeer
      );

      If LRequest <> '' Then
      Begin
        P := 1;

        While P <= Length(LRequest) Do
        Begin
          LRead := BIO_write(LBIO,
                             @LRequest[P],
                             Length(LRequest) - P + 1);

          If LRead <= 0 Then
            Raise Exception.Create('FCM HTTPS: escrita do cabecalho falhou');

          Inc(P, LRead);
        End;
      End;

      If LBodyBytes.Size > 0 Then
      Begin
        LBodyBytes.Position := 0;

        While LBodyBytes.Position < LBodyBytes.Size Do
        Begin
          LRead := LBodyBytes.Read(LBuffer[0],
                                   SizeOf(LBuffer));

          If LRead <= 0 Then
            Break;

          P := 0;

          While P < LRead Do
          Begin
            I := BIO_write(LBIO,
                           @LBuffer[P],
                           LRead - P);

            If I <= 0 Then
              Raise Exception.Create('FCM HTTPS: escrita do body falhou');

            Inc(P, I);
          End;
        End;
      End;

      LRaw := '';

      Repeat
        LRead := BIO_read(LBIO,
                          @LBuffer[0],
                          SizeOf(LBuffer));

        If LRead > 0 Then
        Begin
          SetLength(LBodyText, LRead);

          For I := 0 To LRead - 1 Do
            LBodyText[I + 1] := AnsiChar(LBuffer[I]);

          LRaw := LRaw + LBodyText;
        End;
      Until LRead <= 0;

      LHeaderEnd := Pos(#13#10#13#10, LRaw);

      If LHeaderEnd = 0 Then
        Raise Exception.Create('FCM HTTPS: resposta HTTP invalida');

      LHeader := Copy(LRaw, 1, LHeaderEnd - 1);
      LResponseBody := Copy(LRaw,
                            LHeaderEnd + 4,
                            MaxInt);

      LStatusEnd := Pos(#13#10, LHeader);

      If LStatusEnd > 0 Then
        LStatusLine := Copy(LHeader, 1, LStatusEnd - 1)
      Else
        LStatusLine := LHeader;

      P := Pos(' ', LStatusLine);

      If P = 0 Then
        Raise Exception.Create('FCM HTTPS: status HTTP invalido');

      Result :=
        StrToIntDef(
          Copy(
            LStatusLine,
            P + 1,
            3
          ),
          -1
        );

      If Result < 100 Then
        Raise Exception.Create('FCM HTTPS: codigo HTTP invalido');

      LChunked :=
        Pos('transfer-encoding: chunked',
            LowerCase(LHeader)) > 0;

      If LChunked Then
        LResponseBody := DecodeChunked(LResponseBody)
      Else
      Begin
        LContentLength := 0;
        P := Pos('content-length:',
                 LowerCase(LHeader));

        If P > 0 Then
        Begin
          P := P + Length('content-length:');

          While (P <= Length(LHeader)) And
                (LHeader[P] = ' ') Do
            Inc(P);

          I := P;

          While (I <= Length(LHeader)) And
                (LHeader[I] >= '0') And
                (LHeader[I] <= '9') Do
            Inc(I);

          LContentLength :=
            StrToIntDef(
              Copy(LHeader,
                   P,
                   I - P),
              0
            );

          If LContentLength > 0 Then
          Begin
            If Length(LResponseBody) < LContentLength Then
              Raise Exception.Create('FCM HTTPS: body HTTP truncado');

            If Length(LResponseBody) > LContentLength Then
              SetLength(
                LResponseBody,
                LContentLength
              );
          End;
        End;
      End;

      If (Result >= 200) And
         (Result < 300) Then
      Begin
        If (AResponse <> Nil) And
           (LResponseBody <> '') Then
          AResponse.WriteBuffer(
            LResponseBody[1],
            Length(LResponseBody)
          );
      End
      Else
      Begin
        If (AResponseError <> Nil) And
           (LResponseBody <> '') Then
          AResponseError.WriteBuffer(
            LResponseBody[1],
            Length(LResponseBody)
          );
      End;
    Finally
      BIO_free_all(LBIO);
      SSL_CTX_free(LContext);
    End;
  Finally
    LBodyBytes.Free;

    If AResponse <> Nil Then
      AResponse.Position := 0;

    If AResponseError <> Nil Then
      AResponseError.Position := 0;
  End;
End;

End.
