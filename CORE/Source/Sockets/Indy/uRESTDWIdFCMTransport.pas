Unit uRESTDWIdFCMTransport;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  IdHTTP,
  IdTCPClient,
  IdSSLOpenSSL,
  uRESTDWFCMTransport,
  uRESTDWFCMCompat;

Type
  TRESTDWIdFCMHTTPTransport = Class(TRESTDWFCMHTTPTransport)
  Private
    FHTTP      : TIdHTTP;
    FSSL       : TIdSSLIOHandlerSocketOpenSSL;
    FVerifyPeer : Boolean;

    Function VerifyPeer(Certificate : TIdX509;
                        AOk         : Boolean;
                        ADepth,
                        AError      : Integer) : Boolean;
  Public
    Constructor Create(AConnectTimeout, AReadTimeout : Integer);
    Destructor Destroy; Override;

    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Override;

    Function Post(Const AURL       : String;
                  AHeaders         : TStrings;
                  ABody            : TStream;
                  AResponse        : TStream;
                  AResponseError   : TStream) : Integer; Override;
  End;

  TRESTDWIdFCMStreamTransport = Class(TRESTDWFCMStreamTransport)
  Private
    FTCP        : TIdTCPClient;
    FSSL         : TIdSSLIOHandlerSocketOpenSSL;
    FVerifyPeer  : Boolean;

    Function VerifyPeer(Certificate : TIdX509;
                        AOk         : Boolean;
                        ADepth,
                        AError      : Integer) : Boolean;
  Public
    Constructor Create(AConnectTimeout, AReadTimeout : Integer);
    Destructor Destroy; Override;

    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Override;

    Procedure Connect(Const AHost : String;
                      APort       : Integer); Override;
    Procedure Disconnect; Override;
    Function Connected : Boolean; Override;
    Function ReadByte : Byte; Override;
    Procedure ReadBuffer(Var ABuffer; ACount : Integer); Override;
    Procedure WriteBuffer(Const ABuffer; ACount : Integer); Override;
  End;

Implementation

Constructor TRESTDWIdFCMHTTPTransport.Create(AConnectTimeout, AReadTimeout : Integer);
Begin
  Inherited Create;

  FHTTP := TIdHTTP.Create(Nil);
  FSSL := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);

  FSSL.SSLOptions.Method := sslvTLSv1_2;
  FSSL.PassThrough := False;
  FVerifyPeer := True;
  FSSL.OnVerifyPeer := {$IFDEF FPC}@{$ENDIF}VerifyPeer;

  FHTTP.IOHandler := FSSL;
  FHTTP.ConnectTimeout := AConnectTimeout;
  FHTTP.ReadTimeout := AReadTimeout;
  FHTTP.HandleRedirects := True;
End;

Function TRESTDWIdFCMHTTPTransport.VerifyPeer(Certificate : TIdX509;
                                                  AOk         : Boolean;
                                                  ADepth,
                                                  AError      : Integer) : Boolean;
Begin
  If FVerifyPeer Then
    Result := AOk
  Else
    Result := True;
End;

Procedure TRESTDWIdFCMHTTPTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                                 Const ACAFile,
                                                       ACAPath : String);
Begin
  FVerifyPeer := AVerifyPeer;

  If AVerifyPeer Then
    FSSL.SSLOptions.VerifyMode := [sslvrfPeer]
  Else
    FSSL.SSLOptions.VerifyMode := [];

  If ACAFile <> '' Then
    FSSL.SSLOptions.RootCertFile := ACAFile
  Else
  If FileExists(
       ExtractFilePath(ParamStr(0)) +
       'RESTDWRootCA.pem'
     ) Then
    FSSL.SSLOptions.RootCertFile :=
      ExtractFilePath(ParamStr(0)) +
      'RESTDWRootCA.pem';

  { Indy OpenSSL usa o mesmo CA bundle controlado pelo REST Dataware; ACAPath nao possui equivalente direto
    neste IOHandler antigo. O MCS Indy continua usando o proprio IOHandler. }
End;

Destructor TRESTDWIdFCMHTTPTransport.Destroy;
Begin
  FHTTP.IOHandler := Nil;

  FHTTP.Free;
  FSSL.Free;

  Inherited Destroy;
End;

Function TRESTDWIdFCMHTTPTransport.Post(Const AURL       : String;
                                        AHeaders         : TStrings;
                                        ABody            : TStream;
                                        AResponse        : TStream;
                                        AResponseError   : TStream) : Integer;
Var
  I : Integer;
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

  FHTTP.Request.CustomHeaders.Clear;
  FHTTP.Request.ContentType := '';
  FHTTP.Request.Accept := '';

  If AHeaders <> Nil Then
    For I := 0 To AHeaders.Count - 1 Do
    Begin
      If SameText(AHeaders.Names[I], 'Content-Type') Then
        FHTTP.Request.ContentType := AHeaders.ValueFromIndex[I]
      Else
      If SameText(AHeaders.Names[I], 'Accept') Then
        FHTTP.Request.Accept := AHeaders.ValueFromIndex[I]
      Else
        FHTTP.Request.CustomHeaders.Values[AHeaders.Names[I]] :=
          AHeaders.ValueFromIndex[I];
    End;

  If ABody <> Nil Then
    ABody.Position := 0;

  Try
    Try
      FHTTP.Post(
        AURL,
        ABody,
        AResponse
      );

      Result := FHTTP.ResponseCode;
    Except
      On E : EIdHTTPProtocolException Do
      Begin
        Result := E.ErrorCode;

        If (AResponseError <> Nil) And
           (E.ErrorMessage <> '') Then
          RESTDWFCMWriteUTF8(
            AResponseError,
            E.ErrorMessage
          );
      End;
    End;
  Finally
    If AResponse <> Nil Then
      AResponse.Position := 0;

    If AResponseError <> Nil Then
      AResponseError.Position := 0;
  End;
End;

Constructor TRESTDWIdFCMStreamTransport.Create(AConnectTimeout, AReadTimeout : Integer);
Begin
  Inherited Create;

  FTCP := TIdTCPClient.Create(Nil);
  FSSL := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);

  FSSL.SSLOptions.Method := sslvTLSv1_2;
  FSSL.PassThrough := False;
  FVerifyPeer := True;
  FSSL.OnVerifyPeer := {$IFDEF FPC}@{$ENDIF}VerifyPeer;

  FTCP.IOHandler := FSSL;
  FTCP.ConnectTimeout := AConnectTimeout;
  FTCP.ReadTimeout := AReadTimeout;
End;

Function TRESTDWIdFCMStreamTransport.VerifyPeer(Certificate : TIdX509;
                                                    AOk         : Boolean;
                                                    ADepth,
                                                    AError      : Integer) : Boolean;
Begin
  If FVerifyPeer Then
    Result := AOk
  Else
    Result := True;
End;

Procedure TRESTDWIdFCMStreamTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                                   Const ACAFile,
                                                         ACAPath : String);
Begin
  FVerifyPeer := AVerifyPeer;

  If AVerifyPeer Then
    FSSL.SSLOptions.VerifyMode := [sslvrfPeer]
  Else
    FSSL.SSLOptions.VerifyMode := [];

  If ACAFile <> '' Then
    FSSL.SSLOptions.RootCertFile := ACAFile
  Else
  If FileExists(
       ExtractFilePath(ParamStr(0)) +
       'RESTDWRootCA.pem'
     ) Then
    FSSL.SSLOptions.RootCertFile :=
      ExtractFilePath(ParamStr(0)) +
      'RESTDWRootCA.pem';
End;

Destructor TRESTDWIdFCMStreamTransport.Destroy;
Begin
  Disconnect;

  FTCP.IOHandler := Nil;

  FTCP.Free;
  FSSL.Free;

  Inherited Destroy;
End;

Procedure TRESTDWIdFCMStreamTransport.Connect(Const AHost : String;
                                              APort       : Integer);
Begin
  Disconnect;

  FTCP.Host := AHost;
  FTCP.Port := APort;
  FSSL.Host := AHost;
  FSSL.Port := APort;
  FTCP.Connect;
End;

Procedure TRESTDWIdFCMStreamTransport.Disconnect;
Begin
  If FTCP.Connected Then
    FTCP.Disconnect;
End;

Function TRESTDWIdFCMStreamTransport.Connected : Boolean;
Begin
  Result := FTCP.Connected;
End;

Function TRESTDWIdFCMStreamTransport.ReadByte : Byte;
Begin
  Result := FTCP.IOHandler.ReadByte;
End;

Procedure TRESTDWIdFCMStreamTransport.ReadBuffer(Var ABuffer;
                                                 ACount : Integer);
Var
  LStream : TMemoryStream;
Begin
  If ACount <= 0 Then
    Exit;

  LStream := TMemoryStream.Create;
  Try
    FTCP.IOHandler.ReadStream(
      LStream,
      ACount,
      False
    );

    LStream.Position := 0;

    LStream.ReadBuffer(
      ABuffer,
      ACount
    );
  Finally
    LStream.Free;
  End;
End;

Procedure TRESTDWIdFCMStreamTransport.WriteBuffer(Const ABuffer;
                                                  ACount : Integer);
Var
  LStream : TMemoryStream;
Begin
  If ACount <= 0 Then
    Exit;

  LStream := TMemoryStream.Create;
  Try
    LStream.WriteBuffer(
      ABuffer,
      ACount
    );

    LStream.Position := 0;

    FTCP.IOHandler.Write(
      LStream,
      0,
      False
    );
  Finally
    LStream.Free;
  End;
End;

End.
