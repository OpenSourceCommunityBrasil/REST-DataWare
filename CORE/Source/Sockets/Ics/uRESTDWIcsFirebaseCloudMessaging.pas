Unit uRESTDWIcsFirebaseCloudMessaging;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  uRESTDWFirebaseCloudMessaging,
  uRESTDWFCMTransport;

Type
  TRESTDWIcsFirebaseCloudMessaging = Class(TRESTDWFirebaseCloudMessaging)
  Protected
    Function CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport; Override;
    Function CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport; Override;
  End;

Implementation

Uses
  uRESTDWIcsFCMTransport;

Function TRESTDWIcsFirebaseCloudMessaging.CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport;
Begin
  Result := TRESTDWIcsFCMHTTPTransport.Create(AConnectTimeout, AReadTimeout);
End;

Function TRESTDWIcsFirebaseCloudMessaging.CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport;
Begin
  Result := TRESTDWIcsFCMStreamTransport.Create;
End;

End.
