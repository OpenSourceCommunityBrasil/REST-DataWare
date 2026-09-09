Unit uRESTDWFpHttpFirebaseCloudMessaging;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  uRESTDWFirebaseCloudMessaging,
  uRESTDWFCMTransport;

Type
  TRESTDWFpHttpFirebaseCloudMessaging = Class(TRESTDWFirebaseCloudMessaging)
  Protected
    Function CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport; Override;
    Function CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport; Override;
  End;

Implementation

Uses
  uRESTDWFpHttpFCMTransport;

Function TRESTDWFpHttpFirebaseCloudMessaging.CreateHTTPTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMHTTPTransport;
Begin
  Result := TRESTDWFpHttpFCMHTTPTransport.Create(AConnectTimeout, AReadTimeout);
End;

Function TRESTDWFpHttpFirebaseCloudMessaging.CreateMCSStreamTransport(AConnectTimeout, AReadTimeout : Integer) : TRESTDWFCMStreamTransport;
Begin
  Result := TRESTDWFpHttpFCMStreamTransport.Create;
End;

End.
