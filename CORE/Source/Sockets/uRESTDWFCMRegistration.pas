Unit uRESTDWFCMRegistration;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMTypes,
  uRESTDWFCMTransport;

Type
  TRESTDWFCMRegistration = Class
  Private
    FConfig : TRESTDWFCMConfig;
    FHTTP   : TRESTDWFCMHTTPTransport;
    Function Post(Const AURL,
                        ABody : String;
                  AHeaders : TStrings;
                  Var AResponse : String) : Integer;
    Function NewPushAppID : String;
    Procedure RegisterGCMEndpoint(Var ACredentials : TRESTDWFCMCredentials);
    Procedure RegisterFCMToken(Var ACredentials : TRESTDWFCMCredentials);
  Public
    Constructor Create(Const AConfig : TRESTDWFCMConfig;
                       AHTTP         : TRESTDWFCMHTTPTransport);
    Procedure Execute(Var ACredentials : TRESTDWFCMCredentials);
  End;

Implementation

Uses
  uRESTDWFCMCompat,
  uRESTDWFCMWebPush,
  uRESTDWFCMCheckin;

Const
  CGCMRegistrationURL = 'https://android.clients.google.com/c2dm/register3';
  CFCMRegistrationURL = 'https://fcmregistrations.googleapis.com/v1/projects/';
  CFCMSendBase        = 'https://fcm.googleapis.com/fcm/send/';
  CGCMRegisterApp     = 'org.chromium.linux';
  CDefaultVAPIDKey    =
    'BDOU99-h67HcA6JeFXHbSNMu7e2yNNu3RzoMj8TM4W88jITfq7ZmPvIM1Iv-4_l2LxQcYwhqby2xGpWwzjfAnG4';

Constructor TRESTDWFCMRegistration.Create(Const AConfig : TRESTDWFCMConfig;
                                          AHTTP         : TRESTDWFCMHTTPTransport);
Begin
  Inherited Create;
  FConfig := AConfig;
  FHTTP := AHTTP;
End;

Function TRESTDWFCMRegistration.Post(Const AURL,
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

Function TRESTDWFCMRegistration.NewPushAppID : String;
Var
  LGUID   : TGUID;
  LBundle : String;
Begin
  If FConfig.ClientCategory <> '' Then
    LBundle := FConfig.ClientCategory
  Else
    LBundle := 'receiver.push.com';

  CreateGUID(LGUID);
  Result := GUIDToString(LGUID);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
  Result := LowerCase(Result);
  Result := 'wp:' + LBundle + '#' + Result;
End;

Procedure TRESTDWFCMRegistration.RegisterGCMEndpoint(Var ACredentials : TRESTDWFCMCredentials);
Var
  LBody,
  LAuthorization,
  LResponse,
  LURL : String;
  LHeaders : TStringList;
  LCode,
  LTry : Integer;
  LCheckin : TRESTDWGCMCheckin;
Begin
  If ACredentials.DeviceID = 0 Then
    Raise Exception.Create('DeviceID nao foi criado');
  If ACredentials.SecurityToken = 0 Then
    Raise Exception.Create('SecurityToken nao foi criado');
  If ACredentials.PushAppID = '' Then
    ACredentials.PushAppID := NewPushAppID;

  If ACredentials.RegistrationURL <> '' Then
    LURL := ACredentials.RegistrationURL
  Else
    LURL := CGCMRegistrationURL;

  For LTry := 0 To 4 Do
  Begin
    LBody :=
      'app=' + RESTDWFCMURLEncode(CGCMRegisterApp) +
      '&X-subtype=' + RESTDWFCMURLEncode(ACredentials.PushAppID) +
      '&device=' + RESTDWFCMURLEncode(RESTDWFCMUIntToStr(ACredentials.DeviceID)) +
      '&sender=' + RESTDWFCMURLEncode(CDefaultVAPIDKey);

    LAuthorization :=
      'AidLogin ' +
      RESTDWFCMUIntToStr(ACredentials.DeviceID) +
      ':' +
      RESTDWFCMUIntToStr(ACredentials.SecurityToken);

    LHeaders := TStringList.Create;
    Try
      LHeaders.Values['Authorization'] := LAuthorization;
      LHeaders.Values['Content-Type'] := 'application/x-www-form-urlencoded';
      LHeaders.Values['Accept'] := '*/*';
      LCode := Post(LURL, LBody, LHeaders, LResponse);
    Finally
      LHeaders.Free;
    End;

    LResponse := Trim(LResponse);
    If (LCode Div 100) <> 2 Then
      Raise Exception.Create('GCM Endpoint HTTP ' +
                             IntToStr(LCode) + ': ' + LResponse);

    If Pos('token=', LResponse) = 1 Then
    Begin
      ACredentials.PushSubscriptionID := Copy(LResponse, 7, MaxInt);
      Break;
    End;

    If SameText(LResponse, 'Error=PHONE_REGISTRATION_ERROR') Then
    Begin
      ACredentials.DeviceID := 0;
      ACredentials.SecurityToken := 0;
      ACredentials.RegistrationURL := '';

      LCheckin := TRESTDWGCMCheckin.Create(FHTTP);
      Try
        LCheckin.Execute(ACredentials);
      Finally
        LCheckin.Free;
      End;

      If ACredentials.RegistrationURL <> '' Then
        LURL := ACredentials.RegistrationURL
      Else
        LURL := CGCMRegistrationURL;

      If LTry < 4 Then
        RESTDWFCMSleep(1000 * (LTry + 1));
      Continue;
    End;

    If Pos('Error=', LResponse) = 1 Then
      Raise Exception.Create('GCM Endpoint: ' + LResponse);

    Raise Exception.Create('GCM Endpoint resposta inesperada: ' + LResponse);
  End;

  If ACredentials.PushSubscriptionID = '' Then
    Raise Exception.Create('GCM Endpoint: PHONE_REGISTRATION_ERROR apos novo check-in');

  ACredentials.PushEndpoint := CFCMSendBase + ACredentials.PushSubscriptionID;
End;

Procedure TRESTDWFCMRegistration.RegisterFCMToken(Var ACredentials : TRESTDWFCMCredentials);
Var
  LURL,
  LBody,
  LResponse : String;
  LHeaders  : TStringList;
  LCode     : Integer;
Begin
  If ACredentials.FISAuthToken = '' Then
    Raise Exception.Create('FISAuthToken nao foi criado');
  If ACredentials.PushEndpoint = '' Then
    Raise Exception.Create('PushEndpoint nao foi criado');
  If ACredentials.PushPublicKey = '' Then
    Raise Exception.Create('PushPublicKey nao foi criada');
  If ACredentials.PushAuth = '' Then
    Raise Exception.Create('PushAuth nao foi criado');

  LBody :=
    '{"web":{"endpoint":"' + ACredentials.PushEndpoint +
    '","auth":"' + ACredentials.PushAuth +
    '","p256dh":"' + ACredentials.PushPublicKey + '"';

  If (FConfig.VAPIDKey <> '') And
     (FConfig.VAPIDKey <> CDefaultVAPIDKey) Then
    LBody := LBody + ',"applicationPubKey":"' +
             FConfig.VAPIDKey + '"';

  LBody := LBody + '}}';
  LURL := CFCMRegistrationURL + FConfig.ProjectID + '/registrations';

  LHeaders := TStringList.Create;
  Try
    LHeaders.Values['x-goog-api-key'] := FConfig.APIKey;
    LHeaders.Values['x-goog-firebase-installations-auth'] :=
      'FIS ' + ACredentials.FISAuthToken;
    LHeaders.Values['Content-Type'] := 'application/json';
    LHeaders.Values['Accept'] := 'application/json';

    LCode := Post(LURL, LBody, LHeaders, LResponse);
  Finally
    LHeaders.Free;
  End;

  If (LCode Div 100) <> 2 Then
    Raise Exception.Create('FCM Registration HTTP ' +
                           IntToStr(LCode) + ': ' + LResponse);

  ACredentials.FCMToken := RESTDWFCMJSONValue(LResponse, 'token');
  If ACredentials.FCMToken = '' Then
    Raise Exception.Create('FCM Registration retornou token vazio');
End;

Procedure TRESTDWFCMRegistration.Execute(Var ACredentials : TRESTDWFCMCredentials);
Begin
  { A estrutura de subscription usada pelo endpoint tem formato WebPush,
    mas e criada e negociada pelo REST Dataware. Nao existe navegador,
    ServiceWorker ou Push API envolvidos nesta chamada. }
  TRESTDWWebPush.Prepare(FConfig, ACredentials);

  If (ACredentials.PushSubscriptionID = '') Or
     (ACredentials.PushEndpoint = '') Then
    RegisterGCMEndpoint(ACredentials);

  RegisterFCMToken(ACredentials);
End;

End.
