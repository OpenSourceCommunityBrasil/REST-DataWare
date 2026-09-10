Unit uRESTDWHttpDefFirebaseCloudMessaging;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  uRESTDWFirebaseCloudMessaging,
  uRESTDWFCMTransport;

Type
  TRESTDWHttpDefFirebaseCloudMessaging = Class(TRESTDWFirebaseCloudMessaging)
  Protected
    Function CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport; Override;
    Function CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport; Override;
  End;

Implementation

Uses
  uRESTDWHttpDefFCMTransport;

Function TRESTDWHttpDefFirebaseCloudMessaging.CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport;
Begin
  Result := TRESTDWHttpDefFCMHTTPTransport.Create(AConnectTimeout, AReadTimeout);
End;

Function TRESTDWHttpDefFirebaseCloudMessaging.CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport;
Begin
  Result := TRESTDWHttpDefFCMStreamTransport.Create;
End;

End.
