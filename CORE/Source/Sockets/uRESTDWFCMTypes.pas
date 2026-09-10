Unit uRESTDWFCMTypes;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMCompat;

Type
  TRESTDWFCMState = (
    fsStopped,
    fsStarting,
    fsCreatingInstallation,
    fsRefreshingAuth,
    fsCheckin,
    fsRegisteringToken,
    fsConnecting,
    fsConnected,
    fsError
  );

  TRESTDWFCMConfig = Record
    ProjectID      : String;
    AppID          : String;
    APIKey         : String;
    VAPIDKey       : String;
    ClientCategory : String;
  End;

  TRESTDWFCMCredentials = Record
    DeviceID           : TRESTDWFCMUInt64;
    SecurityToken      : TRESTDWFCMUInt64;
    FID                : String;
    FISRefreshToken    : String;
    FISAuthToken       : String;
    RegistrationURL    : String;
    PushAppID          : String;
    PushInstanceID     : String;
    PushSubscriptionID : String;
    PushEndpoint       : String;
    PushPublicKey      : String;
    PushPrivateKey     : String;
    PushAuth           : String;
    FCMToken           : String;
  End;

Implementation

End.
