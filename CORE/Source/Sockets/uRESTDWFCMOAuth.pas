Unit uRESTDWFCMOAuth;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMTransport;

Type
  TRESTDWFCMOAuth = Class
  Private
    FHTTP        : TRESTDWFCMHTTPTransport;
    FEmail       : String;
    FPrivateKey  : String;
    FAccessToken : String;
    FExpires     : TDateTime;
    Function Sign(Const AData : String) : String;
    Function Post(Const AURL,
                        ABody : String;
                  AHeaders : TStrings;
                  Var AResponse : String) : Integer;
  Public
    Constructor Create(AHTTP : TRESTDWFCMHTTPTransport);
    Property HTTPTransport : TRESTDWFCMHTTPTransport Read FHTTP Write FHTTP;
    Function AccessToken(Const AEmail,
                               APrivateKey : String) : String;
  End;

Implementation

Uses
  uRESTDWOpenSslLib,
  uRESTDWFCMCompat;

Function JSONEscape(Const S : String) : String;
Begin
  Result := StringReplace(S, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
End;

Constructor TRESTDWFCMOAuth.Create(AHTTP : TRESTDWFCMHTTPTransport);
Begin
  Inherited Create;
  FHTTP := AHTTP;
End;

Function TRESTDWFCMOAuth.Post(Const AURL,
                                    ABody : String;
                              AHeaders : TStrings;
                              Var AResponse : String) : Integer;
Var
  LBody,
  LResponse,
  LError : TRESTDWFCMUTF8Stream;
Begin
  LBody := TRESTDWFCMUTF8Stream.Create(ABody);
  LResponse := TRESTDWFCMUTF8Stream.Create('');
  LError := TRESTDWFCMUTF8Stream.Create('');
  Try
    Result := FHTTP.Post(AURL, AHeaders, LBody, LResponse, LError);
    If LResponse.Size > 0 Then
      AResponse := LResponse.AsString
    Else
      AResponse := LError.AsString;
  Finally
    LError.Free;
    LResponse.Free;
    LBody.Free;
  End;
End;

Function TRESTDWFCMOAuth.Sign(Const AData : String) : String;
Var
  LData,
  LKey,
  LSignature : TRESTDWFCMBytes;
  LBIO       : PBIO;
  LPKey      : PEVP_PKEY;
  LCtx       : PEVP_MD_CTX;
  {$IFDEF FPC}
  LSize      : NativeUInt;
  {$ELSE}
    {$IFDEF DELPHI2009UP}
    LSize      : NativeUInt;
    {$ELSE}
    LSize      : Cardinal;
    {$ENDIF}
  {$ENDIF}
Begin
  LData := RESTDWFCMStringToBytes(AData);
  LKey := RESTDWFCMStringToBytes(
    StringReplace(FPrivateKey, '\n', #13#10, [rfReplaceAll])
  );

  If (Length(LData) = 0) Or (Length(LKey) = 0) Then
    Raise Exception.Create('FCM OAuth2: dados de assinatura invalidos');

  LBIO := BIO_new_mem_buf(@LKey[0], Length(LKey));
  If LBIO = Nil Then
    Raise Exception.Create('FCM OAuth2: BIO da chave privada falhou');
  Try
    LPKey := PEM_read_bio_PrivateKey(LBIO, Nil, Nil, Nil);
    If LPKey = Nil Then
      Raise Exception.Create('FCM OAuth2: chave privada PEM invalida');
    Try
      LCtx := EVP_MD_CTX_new;
      If LCtx = Nil Then
        Raise Exception.Create('FCM OAuth2: contexto RS256 falhou');
      Try
        If EVP_DigestSignInit(LCtx, Nil, EVP_sha256, Nil, LPKey) <= 0 Then
          Raise Exception.Create('FCM OAuth2: DigestSignInit falhou');
        If EVP_DigestUpdate(LCtx, @LData[0], Length(LData)) <= 0 Then
          Raise Exception.Create('FCM OAuth2: DigestUpdate falhou');
        LSize := 0;
        If EVP_DigestSignFinal(LCtx, Nil, LSize) <= 0 Then
          Raise Exception.Create('FCM OAuth2: tamanho da assinatura falhou');
        SetLength(LSignature, LSize);
        If EVP_DigestSignFinal(LCtx, @LSignature[0], LSize) <= 0 Then
          Raise Exception.Create('FCM OAuth2: assinatura RS256 falhou');
        SetLength(LSignature, LSize);
      Finally
        EVP_MD_CTX_free(LCtx);
      End;
    Finally
      EVP_PKEY_free(LPKey);
    End;
  Finally
    BIO_free(LBIO);
  End;

  Result := RESTDWFCMBase64URL(LSignature);
End;

Function TRESTDWFCMOAuth.AccessToken(Const AEmail,
                                           APrivateKey : String) : String;
Var
  LHeader,
  LPayload,
  LData,
  LJWT,
  LBody,
  LResponse : String;
  LHeaders  : TStringList;
  LNowUnix  : Int64;
  LCode     : Integer;
Begin
  If (FAccessToken <> '') And
     (Now < FExpires) And
     (FEmail = AEmail) And
     (FPrivateKey = APrivateKey) Then
  Begin
    Result := FAccessToken;
    Exit;
  End;

  FEmail := AEmail;
  FPrivateKey := APrivateKey;
  LNowUnix := RESTDWFCMUnixNow;

  LHeader := RESTDWFCMBase64URL(
    RESTDWFCMStringToBytes('{"alg":"RS256","typ":"JWT"}')
  );

  LPayload :=
    '{"iss":"' + JSONEscape(FEmail) +
    '","scope":"https://www.googleapis.com/auth/firebase.messaging"' +
    ',"aud":"https://oauth2.googleapis.com/token"' +
    ',"iat":' +
    RESTDWFCMUIntToStr(
      TRESTDWFCMUInt64(LNowUnix)
    ) +
    ',"exp":' +
    RESTDWFCMUIntToStr(
      TRESTDWFCMUInt64(LNowUnix + 3600)
    ) + '}';

  LPayload := RESTDWFCMBase64URL(RESTDWFCMStringToBytes(LPayload));
  LData := LHeader + '.' + LPayload;
  LJWT := LData + '.' + Sign(LData);

  LBody :=
    'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer' +
    '&assertion=' + RESTDWFCMURLEncode(LJWT);

  LHeaders := TStringList.Create;
  Try
    LHeaders.Values['Content-Type'] := 'application/x-www-form-urlencoded';
    LHeaders.Values['Accept'] := 'application/json';
    LCode := Post('https://oauth2.googleapis.com/token',
                  LBody,
                  LHeaders,
                  LResponse);
  Finally
    LHeaders.Free;
  End;

  If LCode <> 200 Then
    Raise Exception.Create('FCM OAuth2 HTTP ' +
                           IntToStr(LCode) + ': ' + LResponse);

  FAccessToken := RESTDWFCMJSONValue(LResponse, 'access_token');
  If FAccessToken = '' Then
    Raise Exception.Create('FCM OAuth2 retornou token vazio');

  FExpires := Now + (50 / 1440);
  Result := FAccessToken;
End;

End.
