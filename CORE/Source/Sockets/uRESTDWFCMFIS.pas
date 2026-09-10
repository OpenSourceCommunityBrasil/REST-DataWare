Unit uRESTDWFCMFIS;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMTypes,
  uRESTDWFCMTransport;

Type
  TRESTDWFirebaseInstallations = Class
  Private
    FConfig : TRESTDWFCMConfig;
    FHTTP   : TRESTDWFCMHTTPTransport;
    Function NewFID : String;
    Function Post(Const AURL,
                        ABody : String;
                  AHeaders : TStrings;
                  Var AResponse : String) : Integer;
  Public
    Constructor Create(Const AConfig : TRESTDWFCMConfig;
                       AHTTP         : TRESTDWFCMHTTPTransport);
    Procedure CreateInstallation(Var ACredentials : TRESTDWFCMCredentials);
    Procedure RefreshAuthToken(Var ACredentials : TRESTDWFCMCredentials);
  End;

Implementation

Uses
  uRESTDWFCMCompat,
  uRESTDWOpenSslLib;

Constructor TRESTDWFirebaseInstallations.Create(Const AConfig : TRESTDWFCMConfig;
                                                AHTTP         : TRESTDWFCMHTTPTransport);
Begin
  Inherited Create;
  FConfig := AConfig;
  FHTTP := AHTTP;
End;

Function TRESTDWFirebaseInstallations.Post(Const AURL,
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

Function TRESTDWFirebaseInstallations.NewFID : String;
Var
  LBytes : TRESTDWFCMBytes;
Begin
  SetLength(LBytes, 17);

  If RAND_bytes(
       @LBytes[0],
       Length(LBytes)
     ) <> 1 Then
    Raise Exception.Create('FIS: RAND_bytes falhou');

  LBytes[0] := (LBytes[0] And $0F) Or $70;
  Result := RESTDWFCMBase64URL(LBytes);
  If Length(Result) > 22 Then
    SetLength(Result, 22);
End;

Procedure TRESTDWFirebaseInstallations.CreateInstallation(Var ACredentials : TRESTDWFCMCredentials);
Var
  LURL,
  LBody,
  LResponse : String;
  LHeaders  : TStringList;
  LCode     : Integer;
Begin
  If ACredentials.FID = '' Then
    ACredentials.FID := NewFID;

  LURL := 'https://firebaseinstallations.googleapis.com/v1/projects/' +
          FConfig.ProjectID + '/installations';

  LBody := '{"fid":"' + ACredentials.FID +
           '","appId":"' + FConfig.AppID +
           '","authVersion":"FIS_v2","sdkVersion":"a:16.3.1"}';

  LHeaders := TStringList.Create;
  Try
    LHeaders.Values['x-goog-api-key'] := FConfig.APIKey;
    LHeaders.Values['Content-Type'] := 'application/json';
    LHeaders.Values['Accept'] := 'application/json';

    LCode := Post(LURL, LBody, LHeaders, LResponse);
    If (LCode Div 100) <> 2 Then
      Raise Exception.Create('FIS CreateInstallation HTTP ' +
                             IntToStr(LCode) + ': ' + LResponse);
  Finally
    LHeaders.Free;
  End;

  ACredentials.FID := RESTDWFCMJSONValue(LResponse, 'fid');
  ACredentials.FISRefreshToken := RESTDWFCMJSONValue(LResponse, 'refreshToken');
  ACredentials.FISAuthToken := RESTDWFCMJSONValue(LResponse, 'token');

  If (ACredentials.FID = '') Or
     (ACredentials.FISRefreshToken = '') Then
    Raise Exception.Create('FIS CreateInstallation retornou dados invalidos');
End;

Procedure TRESTDWFirebaseInstallations.RefreshAuthToken(Var ACredentials : TRESTDWFCMCredentials);
Var
  LURL,
  LBody,
  LResponse : String;
  LHeaders  : TStringList;
  LCode     : Integer;
Begin
  LURL := 'https://firebaseinstallations.googleapis.com/v1/projects/' +
          FConfig.ProjectID + '/installations/' +
          ACredentials.FID + '/authTokens:generate';

  LBody := '{"installation":{"appId":"' + FConfig.AppID +
           '","sdkVersion":"a:16.3.1"}}';

  LHeaders := TStringList.Create;
  Try
    LHeaders.Values['x-goog-api-key'] := FConfig.APIKey;
    LHeaders.Values['Authorization'] := 'FIS_v2 ' + ACredentials.FISRefreshToken;
    LHeaders.Values['Content-Type'] := 'application/json';
    LHeaders.Values['Accept'] := 'application/json';

    LCode := Post(LURL, LBody, LHeaders, LResponse);
    If (LCode Div 100) <> 2 Then
      Raise Exception.Create('FIS RefreshAuthToken HTTP ' +
                             IntToStr(LCode) + ': ' + LResponse);
  Finally
    LHeaders.Free;
  End;

  ACredentials.FISAuthToken := RESTDWFCMJSONValue(LResponse, 'token');
  If ACredentials.FISAuthToken = '' Then
    Raise Exception.Create('FIS RefreshAuthToken retornou token vazio');
End;

End.
