Unit uRESTDWjClientLAMWFirebaseCloudMessaging;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  uRESTDWFirebaseCloudMessaging,
  uRESTDWFCMTransport;

Type
  TRESTDWjClientLAMWFirebaseCloudMessaging = Class(TRESTDWFirebaseCloudMessaging)
  Protected
    Function CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport; Override;
    Function CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport; Override;
  End;

Implementation

Uses
  uRESTDWjClientLAMWFCMTransport;

Function TRESTDWjClientLAMWFirebaseCloudMessaging.CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport;
Begin
  Result := TRESTDWjClientLAMWFCMHTTPTransport.Create;
End;

Function TRESTDWjClientLAMWFirebaseCloudMessaging.CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport;
Begin
  Result := TRESTDWjClientLAMWFCMStreamTransport.Create;
End;

End.
