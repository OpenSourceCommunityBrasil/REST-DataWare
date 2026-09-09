Unit uRESTDWIdFirebaseCloudMessaging;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  uRESTDWFirebaseCloudMessaging,
  uRESTDWFCMTransport;

Type
  TRESTDWIdFirebaseCloudMessaging = Class(TRESTDWFirebaseCloudMessaging)
  Protected
    Function CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport; Override;
    Function CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport; Override;
  End;

Implementation

Uses
  uRESTDWIdFCMTransport;

Function TRESTDWIdFirebaseCloudMessaging.CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport;
Begin
  Result := TRESTDWIdFCMHTTPTransport.Create(AConnectTimeout, AReadTimeout);
End;

Function TRESTDWIdFirebaseCloudMessaging.CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport;
Begin
  Result := TRESTDWIdFCMStreamTransport.Create(AConnectTimeout, AReadTimeout);
End;

End.
