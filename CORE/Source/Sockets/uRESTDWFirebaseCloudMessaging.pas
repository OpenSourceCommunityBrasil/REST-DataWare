Unit uRESTDWFirebaseCloudMessaging;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  IniFiles,
  SyncObjs,
  uRESTDWFCMTypes,
  uRESTDWFCMMessage,
  uRESTDWFCMTransport;

Type
  TRESTDWFirebaseCloudMessaging = Class;

  TRESTDWFCMTokenEvent = Procedure(Sender : TObject;
                                   Const AToken : String) Of Object;

  TRESTDWFCMMessageEvent = Procedure(Sender  : TObject;
                                     Message : TRESTDWFCMMessage) Of Object;

  TRESTDWFCMErrorEvent = Procedure(Sender : TObject;
                                   Const AWhere,
                                         AError : String) Of Object;

  TRESTDWFCMStateEvent = Procedure(Sender : TObject;
                                   AState : TRESTDWFCMState) Of Object;

  TRESTDWFCMConnection = Class(TPersistent)
  Private
    FAutoReconnect     : Boolean;
    FConnectTimeout    : Integer;
    FReadTimeout       : Integer;
    FMCSReadTimeout    : Integer;
    FReconnectDelay    : Integer;
    FTLSVerifyPeer      : Boolean;
    FTLSCAFile          : String;
    FTLSCAPath          : String;

    Function GetTLSAllowInsecure : Boolean;
    Procedure SetTLSAllowInsecure(AValue : Boolean);
  Public
    Constructor Create;
    Procedure Assign(Source : TPersistent); Override;
  Published
    Property AutoReconnect  : Boolean Read FAutoReconnect Write FAutoReconnect;
    Property ConnectTimeout : Integer Read FConnectTimeout Write FConnectTimeout;
    Property ReadTimeout    : Integer Read FReadTimeout Write FReadTimeout;
    Property MCSReadTimeout : Integer Read FMCSReadTimeout Write FMCSReadTimeout;
    Property ReconnectDelay : Integer Read FReconnectDelay Write FReconnectDelay;
    Property TLSAllowInsecure : Boolean Read GetTLSAllowInsecure Write SetTLSAllowInsecure;
    Property TLSVerifyPeer     : Boolean Read FTLSVerifyPeer Write FTLSVerifyPeer;
    Property TLSCAFile        : String Read FTLSCAFile Write FTLSCAFile;
    Property TLSCAPath       : String Read FTLSCAPath Write FTLSCAPath;
  End;

  TRESTDWFCMReceive = Class(TPersistent)
  Private
    FQueueSize : Integer;
  Public
    Constructor Create;
    Procedure Assign(Source : TPersistent); Override;
  Published
    Property QueueSize : Integer Read FQueueSize Write FQueueSize;
  End;

  TRESTDWFCMNotificationDisplayEvent = Procedure(Sender : TObject;
                                                 Target : TComponent;
                                                 Const ATitle,
                                                       ABody,
                                                       AImageURL : String) Of Object;

  TRESTDWFCMNotification = Class(TPersistent)
  Private
    FOwner       : TComponent;
    FActive      : Boolean;
    FTitle       : String;
    FPushObject  : TComponent;
    FToastObject : TComponent;
    FOnDisplay   : TRESTDWFCMNotificationDisplayEvent;

    Procedure SetPushObject(AValue : TComponent);
    Procedure SetToastObject(AValue : TComponent);
  Public
    Constructor Create(AOwner : TComponent);
  Published
    Property Active      : Boolean Read FActive Write FActive;
    Property Title       : String Read FTitle Write FTitle;
    Property PushObject  : TComponent Read FPushObject Write SetPushObject;
    Property ToastObject : TComponent Read FToastObject Write SetToastObject;
    Property OnDisplay   : TRESTDWFCMNotificationDisplayEvent Read FOnDisplay Write FOnDisplay;
  End;

  TRESTDWFCMQueueItem = Class
  Public
    PersistentID : String;
    Message      : TRESTDWFCMMessage;
    Destructor Destroy; Override;
  End;

  TRESTDWFCMWorker = Class(TThread)
  Private
    FOwner : TRESTDWFirebaseCloudMessaging;
  Protected
    Procedure Execute; Override;
  Public
    Constructor Create(AOwner : TRESTDWFirebaseCloudMessaging);
    Function MustTerminate : Boolean;
  End;

  TRESTDWFirebaseCloudMessaging = Class(TComponent)
  Private
    FProjectID        : String;

    FAppID            : String;
    FAPIKey           : String;

    FVAPIDKey      : String;

    FClientEmail      : String;
    FPrivateKey       : String;
    FToken            : String;

    FLastRequest      : String;
    FLastResponse     : String;
    FLastError        : String;
    FResponseCode     : Integer;

    FStateLoaded      : Boolean;

    FHTTP         : TRESTDWFCMHTTPTransport;
    FSendHTTP     : TRESTDWFCMHTTPTransport;
    FSendOAuth    : TObject;
    FSendLock     : TCriticalSection;
    FMCSLock      : TCriticalSection;
    FMCSStream    : TRESTDWFCMStreamTransport;
    FMCS          : TObject;
    FThread       : TRESTDWFCMWorker;
    FWorkerFinished    : Boolean;
    FInReceiveCallback : Boolean;
    FCredentials  : TRESTDWFCMCredentials;

    FQueue        : TList;
    FQueueLock    : TCriticalSection;
    FConnection   : TRESTDWFCMConnection;
    FReceive      : TRESTDWFCMReceive;
    FNotification : TRESTDWFCMNotification;

    FOnToken   : TRESTDWFCMTokenEvent;
    FOnMessage : TRESTDWFCMMessageEvent;
    FOnError   : TRESTDWFCMErrorEvent;
    FOnState   : TRESTDWFCMStateEvent;

    Function GetConfig : TRESTDWFCMConfig;
    Function GetStateFileName : String;
    Procedure LoadState;
    Procedure SaveState;
    Procedure Worker;
    Procedure ProcessQueue;
    Function SendTarget(Const ATargetName,
                              ATargetValue : String;
                        AMessage           : TRESTDWFCMMessage) : Boolean;
    Procedure MCSData(Sender : TObject;
                      Const APersistentID,
                            AMessageData,
                            ARaw : String);
  Protected
    Procedure Notification(AComponent : TComponent;
                           Operation  : TOperation); Override;

    Function CreateHTTPTransport(AConnectTimeout,
                                 AReadTimeout : Integer) : TRESTDWFCMHTTPTransport; Virtual; Abstract;

    Function CreateMCSStreamTransport(AConnectTimeout,
                                      AReadTimeout : Integer) : TRESTDWFCMStreamTransport; Virtual; Abstract;

    Procedure SetToken(Const AValue : String);
    Procedure QueueMessage(Const APersistentID : String;
                           AMessage            : TRESTDWFCMMessage);
    Procedure Error(Const AWhere,
                          AError : String);
    Procedure State(AState : TRESTDWFCMState);
    Procedure EnsureOpenSSL;
  Public
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;

    Procedure Start;
    Procedure Stop;
    Procedure RefreshToken;
    Procedure LoadGoogleServices(Const AFileName : String);
    Procedure LoadServiceAccount(Const AFileName : String);
    Procedure LoadServiceAccountConfig(Const AFileName : String);

    Function Send(Const ADeviceToken : String;
                  AMessage           : TRESTDWFCMMessage) : Boolean;
    Function SendTopic(Const ATopic : String;
                       AMessage      : TRESTDWFCMMessage) : Boolean;
    Function SendCondition(Const ACondition : String;
                           AMessage          : TRESTDWFCMMessage) : Boolean;

    Property Token        : String Read FToken;
    Property LastRequest  : String Read FLastRequest;
    Property LastResponse : String Read FLastResponse;
    Property LastError    : String Read FLastError;
    Property ResponseCode : Integer Read FResponseCode;
  Published
    Property ProjectID        : String Read FProjectID Write FProjectID;

    Property AppID            : String Read FAppID Write FAppID;
    Property APIKey           : String Read FAPIKey Write FAPIKey;

    Property VAPIDKey         : String Read FVAPIDKey Write FVAPIDKey;

    Property ClientEmail      : String Read FClientEmail Write FClientEmail;
    Property PrivateKey       : String Read FPrivateKey Write FPrivateKey;

    Property Connection   : TRESTDWFCMConnection Read FConnection;
    Property Receive      : TRESTDWFCMReceive Read FReceive;
    Property NotificationOptions : TRESTDWFCMNotification Read FNotification;

    Property OnToken   : TRESTDWFCMTokenEvent Read FOnToken Write FOnToken;
    Property OnMessage : TRESTDWFCMMessageEvent Read FOnMessage Write FOnMessage;
    Property OnError   : TRESTDWFCMErrorEvent Read FOnError Write FOnError;
    Property OnState   : TRESTDWFCMStateEvent Read FOnState Write FOnState;
  End;

Implementation

Uses
  uRESTDWFCMCompat,
  uRESTDWFCMJSON,
  uRESTDWFCMOAuth,
  uRESTDWFCMFIS,
  uRESTDWFCMCheckin,
  uRESTDWFCMRegistration,
  uRESTDWFCMMCS,
  uRESTDWOpenSslLib;

Constructor TRESTDWFCMNotification.Create(AOwner : TComponent);
Begin
  Inherited Create;
  FOwner := AOwner;
End;

Procedure TRESTDWFCMNotification.SetPushObject(AValue : TComponent);
Begin
  FPushObject := AValue;

  If Assigned(FOwner) And
     Assigned(FPushObject) Then
    FPushObject.FreeNotification(FOwner);
End;

Procedure TRESTDWFCMNotification.SetToastObject(AValue : TComponent);
Begin
  FToastObject := AValue;

  If Assigned(FOwner) And
     Assigned(FToastObject) Then
    FToastObject.FreeNotification(FOwner);
End;

Function TRESTDWFCMConnection.GetTLSAllowInsecure : Boolean;
Begin
  Result := Not FTLSVerifyPeer;
End;

Procedure TRESTDWFCMConnection.SetTLSAllowInsecure(AValue : Boolean);
Begin
  FTLSVerifyPeer := Not AValue;
End;

Constructor TRESTDWFCMConnection.Create;
Begin
  Inherited Create;

  FAutoReconnect := True;
  FConnectTimeout := 15000;
  FReadTimeout := 30000;
  FMCSReadTimeout := 0;
  FReconnectDelay := 2000;
  FTLSVerifyPeer := True;
  FTLSCAFile := '';
  FTLSCAPath := '';
End;

Procedure TRESTDWFCMConnection.Assign(Source : TPersistent);
Var
  LSource : TRESTDWFCMConnection;
Begin
  If Source Is TRESTDWFCMConnection Then
  Begin
    LSource := TRESTDWFCMConnection(Source);

    FAutoReconnect := LSource.AutoReconnect;
    FConnectTimeout := LSource.ConnectTimeout;
    FReadTimeout := LSource.ReadTimeout;
    FMCSReadTimeout := LSource.MCSReadTimeout;
    FReconnectDelay := LSource.ReconnectDelay;
    FTLSVerifyPeer := LSource.TLSVerifyPeer;
    FTLSCAFile := LSource.TLSCAFile;
    FTLSCAPath := LSource.TLSCAPath;
  End
  Else
    Inherited Assign(Source);
End;

Constructor TRESTDWFCMReceive.Create;
Begin
  Inherited Create;
  FQueueSize := 1000;
End;

Procedure TRESTDWFCMReceive.Assign(Source : TPersistent);
Begin
  If Source Is TRESTDWFCMReceive Then
    FQueueSize := TRESTDWFCMReceive(Source).QueueSize
  Else
    Inherited Assign(Source);
End;

Destructor TRESTDWFCMQueueItem.Destroy;
Begin
  Message.Free;
  Inherited Destroy;
End;

Constructor TRESTDWFCMWorker.Create(AOwner : TRESTDWFirebaseCloudMessaging);
Begin
  Inherited Create(True);
  FreeOnTerminate := False;
  FOwner := AOwner;
End;

Procedure TRESTDWFCMWorker.Execute;
Begin
  FOwner.Worker;
End;

Function TRESTDWFCMWorker.MustTerminate : Boolean;
Begin
  Result := Terminated;
End;

Constructor TRESTDWFirebaseCloudMessaging.Create(AOwner : TComponent);
Begin
  Inherited Create(AOwner);
{ O estado pertence ao REST Dataware, nao ao SysOp. }

  FQueue := TList.Create;
  FQueueLock := TCriticalSection.Create;
  FSendLock := TCriticalSection.Create;
  FMCSLock := TCriticalSection.Create;
  FConnection := TRESTDWFCMConnection.Create;
  FReceive := TRESTDWFCMReceive.Create;
  FNotification := TRESTDWFCMNotification.Create(Self);

  FHTTP := Nil;
  FSendHTTP := Nil;
  FSendOAuth := Nil;
  FMCSStream := Nil;
  FMCS := Nil;
  FThread := Nil;
  FWorkerFinished := False;
  FInReceiveCallback := False;

End;

Destructor TRESTDWFirebaseCloudMessaging.Destroy;
Begin
  Stop;

  FQueueLock.Acquire;
  Try
    While FQueue.Count > 0 Do
    Begin
      TObject(FQueue[FQueue.Count - 1]).Free;
      FQueue.Delete(FQueue.Count - 1);
    End;
  Finally
    FQueueLock.Release;
  End;

  FSendOAuth.Free;
  FSendHTTP.Free;

  FNotification.Free;
  FReceive.Free;
  FConnection.Free;
  FMCSLock.Free;
  FSendLock.Free;
  FQueueLock.Free;
  FQueue.Free;

  Inherited Destroy;
End;

Procedure TRESTDWFirebaseCloudMessaging.Notification(AComponent : TComponent;
                                                       Operation  : TOperation);
Begin
  Inherited Notification(AComponent, Operation);

  If (Operation = opRemove) And
     Assigned(FNotification) Then
  Begin
    If FNotification.FPushObject = AComponent Then
      FNotification.FPushObject := Nil;

    If FNotification.FToastObject = AComponent Then
      FNotification.FToastObject := Nil;
  End;
End;

Procedure TRESTDWFirebaseCloudMessaging.EnsureOpenSSL;
Begin
  {$IFNDEF RESTDWLAMW}
  If Not LoadCrypto Then
    Raise Exception.Create('OpenSSL Crypto library not found');

  If Not LoadSSL Then
    Raise Exception.Create('OpenSSL SSL library not found');
  {$ENDIF}
End;

Function TRESTDWFirebaseCloudMessaging.GetConfig : TRESTDWFCMConfig;
Begin
  Result.ProjectID := FProjectID;
  Result.AppID := FAppID;
  Result.APIKey := FAPIKey;
  Result.VAPIDKey := FVAPIDKey;
  Result.ClientCategory := 'com.restdw.fcm';
End;

Function TRESTDWFirebaseCloudMessaging.GetStateFileName : String;
Var
  LName : String;
  I     : Integer;
Begin
LName := FProjectID;

  If FAppID <> '' Then
    LName := LName + '_' + FAppID;

  If LName = '' Then
    LName := 'client';

  For I := 1 To Length(LName) Do
    If Not (((LName[I] >= 'a') And (LName[I] <= 'z')) Or
            ((LName[I] >= 'A') And (LName[I] <= 'Z')) Or
            ((LName[I] >= '0') And (LName[I] <= '9')) Or
            (LName[I] = '-') Or
            (LName[I] = '_') Or
            (LName[I] = '.')) Then
      LName[I] := '_';

  If Length(LName) > 120 Then
    SetLength(LName, 120);

  Result :=
    ExtractFilePath(ParamStr(0)) +
    'restdw_fcm_' +
    LName +
    '.dat';
End;

Procedure TRESTDWFirebaseCloudMessaging.LoadState;
Const
  CStateVersion = 48;
Var
  LIni : TIniFile;
Begin

  If Not FileExists(GetStateFileName) Then
    Exit;

  LIni := TIniFile.Create(GetStateFileName);
  Try
    If LIni.ReadInteger('FCM', 'StateVersion', 0) <> CStateVersion Then
      Exit;

    If Not SameText(
             LIni.ReadString('FCM', 'ProjectID', ''),
             FProjectID
           ) Then
      Exit;

    If Not SameText(
             LIni.ReadString('FCM', 'AppID', ''),
             FAppID
           ) Then
      Exit;

    FCredentials.DeviceID :=
      RESTDWFCMStrToUInt64Def(
        LIni.ReadString('FCM', 'DeviceID', '0'),
        0
      );

    FCredentials.SecurityToken :=
      RESTDWFCMStrToUInt64Def(
        LIni.ReadString('FCM', 'SecurityToken', '0'),
        0
      );

    FCredentials.FID := LIni.ReadString('FCM', 'FID', '');
    FCredentials.FISRefreshToken := LIni.ReadString('FCM', 'FISRefreshToken', '');
    FCredentials.FISAuthToken := LIni.ReadString('FCM', 'FISAuthToken', '');
    FCredentials.RegistrationURL := LIni.ReadString('FCM', 'RegistrationURL', '');
    FCredentials.PushAppID := LIni.ReadString('FCM', 'PushAppID', '');
    FCredentials.PushInstanceID := LIni.ReadString('FCM', 'PushInstanceID', '');
    FCredentials.PushSubscriptionID := LIni.ReadString('FCM', 'PushSubscriptionID', '');
    FCredentials.PushEndpoint := LIni.ReadString('FCM', 'PushEndpoint', '');
    FCredentials.PushPublicKey := LIni.ReadString('FCM', 'PushPublicKey', '');
    FCredentials.PushPrivateKey := LIni.ReadString('FCM', 'PushPrivateKey', '');
    FCredentials.PushAuth := LIni.ReadString('FCM', 'PushAuth', '');
    FCredentials.FCMToken := LIni.ReadString('FCM', 'FCMToken', '');

    FToken := FCredentials.FCMToken;
  Finally
    LIni.Free;
  End;
End;

Procedure TRESTDWFirebaseCloudMessaging.SaveState;
Const
  CStateVersion = 48;
Var
  LIni : TIniFile;
Begin

  LIni := TIniFile.Create(GetStateFileName);
  Try
    LIni.WriteInteger('FCM', 'StateVersion', CStateVersion);
    LIni.WriteString('FCM', 'ProjectID', FProjectID);
    LIni.WriteString('FCM', 'AppID', FAppID);

    LIni.WriteString('FCM', 'DeviceID', RESTDWFCMUIntToStr(FCredentials.DeviceID));
    LIni.WriteString('FCM', 'SecurityToken', RESTDWFCMUIntToStr(FCredentials.SecurityToken));
    LIni.WriteString('FCM', 'FID', FCredentials.FID);
    LIni.WriteString('FCM', 'FISRefreshToken', FCredentials.FISRefreshToken);
    LIni.WriteString('FCM', 'FISAuthToken', FCredentials.FISAuthToken);
    LIni.WriteString('FCM', 'RegistrationURL', FCredentials.RegistrationURL);
    LIni.WriteString('FCM', 'PushAppID', FCredentials.PushAppID);
    LIni.WriteString('FCM', 'PushInstanceID', FCredentials.PushInstanceID);
    LIni.WriteString('FCM', 'PushSubscriptionID', FCredentials.PushSubscriptionID);
    LIni.WriteString('FCM', 'PushEndpoint', FCredentials.PushEndpoint);
    LIni.WriteString('FCM', 'PushPublicKey', FCredentials.PushPublicKey);
    LIni.WriteString('FCM', 'PushPrivateKey', FCredentials.PushPrivateKey);
    LIni.WriteString('FCM', 'PushAuth', FCredentials.PushAuth);
    LIni.WriteString('FCM', 'FCMToken', FCredentials.FCMToken);
  Finally
    LIni.Free;
  End;
End;

Procedure TRESTDWFirebaseCloudMessaging.SetToken(Const AValue : String);
Begin
  FToken := AValue;

  If Assigned(FOnToken) Then
  Try
    FOnToken(Self, FToken);
  Except
  End;
End;

Procedure TRESTDWFirebaseCloudMessaging.Error(Const AWhere,
                                                   AError : String);
Begin
  If Assigned(FOnError) Then
  Try
    FOnError(Self, AWhere, AError);
  Except
  End;
End;

Procedure TRESTDWFirebaseCloudMessaging.State(AState : TRESTDWFCMState);
Begin
  If Assigned(FOnState) Then
  Try
    FOnState(Self, AState);
  Except
  End;
End;

Procedure TRESTDWFirebaseCloudMessaging.MCSData(Sender : TObject;
                                                Const APersistentID,
                                                      AMessageData,
                                                      ARaw : String);
Var
  LMessage : TRESTDWFCMMessage;
Begin
  LMessage := TRESTDWFCMMessage.Create;
  Try
    If ARaw <> '' Then
      RESTDWFCMJSONToMessage(ARaw, LMessage);

    If AMessageData <> '' Then
    Begin
      RESTDWFCMJSONToData(AMessageData, LMessage.Data);
      If LMessage.Data.Count = 0 Then
        LMessage.Data.Values['messagedata'] := AMessageData;
      If LMessage.Title = '' Then
        LMessage.Title := LMessage.Data.Values['title'];

      If LMessage.Body = '' Then
        LMessage.Body := LMessage.Data.Values['body'];
    End;

    QueueMessage(APersistentID, LMessage);
    LMessage := Nil;
  Finally
    LMessage.Free;
  End;
End;

Procedure TRESTDWFirebaseCloudMessaging.QueueMessage(Const APersistentID : String;
                                                     AMessage            : TRESTDWFCMMessage);
Var
  LItem      : TRESTDWFCMQueueItem;
  LQueueItem : TRESTDWFCMQueueItem;
  LMCS       : TRESTDWMCSClient;
  LDuplicate,
  LQueueFull : Boolean;
  I          : Integer;
Begin
  If AMessage = Nil Then
    Exit;

  LItem := Nil;
  LDuplicate := False;
  LQueueFull := False;

  FQueueLock.Acquire;
  Try
    If APersistentID <> '' Then
      For I := 0 To FQueue.Count - 1 Do
      Begin
        LQueueItem := TRESTDWFCMQueueItem(FQueue[I]);

        If LQueueItem.PersistentID = APersistentID Then
        Begin
          LDuplicate := True;
          Break;
        End;
      End;

    If Not LDuplicate Then
    Begin
      If (FReceive.QueueSize > 0) And
         (FQueue.Count >= FReceive.QueueSize) Then
        LQueueFull := True
      Else
      Begin
        LItem := TRESTDWFCMQueueItem.Create;
        LItem.PersistentID := APersistentID;
        LItem.Message := AMessage;
        FQueue.Add(LItem);
      End;
    End;
  Finally
    FQueueLock.Release;
  End;

  If LDuplicate Then
  Begin
    AMessage.Free;

    { A mensagem ja estava na FIFO porque um ACK anterior falhou.
      Confirma novamente sem inserir uma segunda copia. }
    FMCSLock.Acquire;
    Try
      If (APersistentID <> '') And
         Assigned(FMCS) Then
      Begin
        LMCS := TRESTDWMCSClient(FMCS);
        LMCS.Ack(APersistentID);
      End;
    Finally
      FMCSLock.Release;
    End;

    ProcessQueue;
    Exit;
  End;

  If LQueueFull Then
  Begin
    AMessage.Free;

    Error(
      'Receive',
      'FIFO queue is full'
    );

    { Sem ACK: o MCS pode reenviar depois. }
    Exit;
  End;

  { ACK somente depois que a mensagem ja esta garantida na FIFO. }
  FMCSLock.Acquire;
  Try
    If (APersistentID <> '') And
       Assigned(FMCS) Then
    Begin
      LMCS := TRESTDWMCSClient(FMCS);
      LMCS.Ack(APersistentID);
    End;
  Finally
    FMCSLock.Release;
  End;

  ProcessQueue;
End;

Procedure TRESTDWFirebaseCloudMessaging.ProcessQueue;
Var
  LItem : TRESTDWFCMQueueItem;
Begin
  Repeat
    LItem := Nil;

    FQueueLock.Acquire;
    Try
      If FQueue.Count > 0 Then
      Begin
        LItem := TRESTDWFCMQueueItem(FQueue[0]);
        FQueue.Delete(0);
      End;
    Finally
      FQueueLock.Release;
    End;

    If LItem <> Nil Then
    Try
      FInReceiveCallback := True;
      Try
        Try
          If FNotification.Active And
           Assigned(FNotification.FOnDisplay) Then
        Begin
          If FNotification.PushObject <> Nil Then
            FNotification.FOnDisplay(Self,
                                     FNotification.PushObject,
                                     FNotification.Title,
                                     LItem.Message.Body,
                                     LItem.Message.ImageURL)
          Else
          If FNotification.ToastObject <> Nil Then
            FNotification.FOnDisplay(Self,
                                     FNotification.ToastObject,
                                     FNotification.Title,
                                     LItem.Message.Body,
                                     LItem.Message.ImageURL);
        End;
      Except
        On E : Exception Do
          Error(
            'Notification',
            E.Message
          );
      End;

        Try
          If Assigned(FOnMessage) Then
            FOnMessage(Self, LItem.Message);
        Except
          On E : Exception Do
            Error(
              'OnMessage',
              E.Message
            );
        End;
      Finally
        FInReceiveCallback := False;
      End;
    Finally
      LItem.Free;
    End;

    If Assigned(FThread) And
       FThread.MustTerminate Then
      Exit;
  Until LItem = Nil;
End;

Procedure TRESTDWFirebaseCloudMessaging.Worker;
Var
  LInstallations : TRESTDWFirebaseInstallations;
  LCheckin       : TRESTDWGCMCheckin;
  LRegistration  : TRESTDWFCMRegistration;
  LMCS           : TRESTDWMCSClient;
  LWhere         : String;
  LRetry         : Integer;
Begin
  LWhere := 'Inicializacao';

  Try
    If (FProjectID = '') Or
       (FAppID = '') Or
       (FAPIKey = '') Then
      Raise Exception.Create('Configuracao Firebase FCM incompleta');

    FHTTP := CreateHTTPTransport(
               FConnection.ConnectTimeout,
               FConnection.ReadTimeout
             );
    If FHTTP = Nil Then
      Raise Exception.Create('Motor HTTP FCM nao disponivel');

    FHTTP.ConfigureTLS(
      Not FConnection.TLSAllowInsecure,
      FConnection.TLSCAFile,
      FConnection.TLSCAPath
    );

    If (FCredentials.FID = '') Or
       (FCredentials.FISRefreshToken = '') Then
    Begin
      State(fsCreatingInstallation);
      LWhere := 'FIS CreateInstallation';

      LInstallations := TRESTDWFirebaseInstallations.Create(GetConfig, FHTTP);
      Try
        LInstallations.CreateInstallation(FCredentials);
      Finally
        LInstallations.Free;
      End;
    End;

    State(fsRefreshingAuth);
    LWhere := 'FIS RefreshAuthToken';

    LInstallations := TRESTDWFirebaseInstallations.Create(GetConfig, FHTTP);
    Try
      LInstallations.RefreshAuthToken(FCredentials);
    Finally
      LInstallations.Free;
    End;

    State(fsCheckin);
    LWhere := 'GCM Checkin';

    LCheckin := TRESTDWGCMCheckin.Create(FHTTP);
    Try
      LCheckin.Execute(FCredentials);
    Finally
      LCheckin.Free;
    End;

    State(fsRegisteringToken);
    LWhere := 'FCM Registration';

    LRegistration := TRESTDWFCMRegistration.Create(GetConfig, FHTTP);
    Try
      LRegistration.Execute(FCredentials);
    Finally
      LRegistration.Free;
    End;

    SaveState;
    SetToken(FCredentials.FCMToken);

    State(fsCheckin);
    LWhere := 'GCM Checkin antes do MCS';

    LCheckin := TRESTDWGCMCheckin.Create(FHTTP);
    Try
      LCheckin.Execute(FCredentials);
    Finally
      LCheckin.Free;
    End;
    SaveState;

    While Not FThread.MustTerminate Do
    Begin
      Try
        State(fsConnecting);
        LWhere := 'MCS Connect';

        If FThread.MustTerminate Then
          Break;

        FMCSStream := CreateMCSStreamTransport(
                       FConnection.ConnectTimeout,
                       FConnection.MCSReadTimeout
                     );

        If FMCSStream = Nil Then
          Raise Exception.Create('Motor de stream TLS FCM nao disponivel');

        FMCSStream.ConfigureTLS(
          Not FConnection.TLSAllowInsecure,
          FConnection.TLSCAFile,
          FConnection.TLSCAPath
        );

        If FThread.MustTerminate Then
        Begin
          FreeAndNil(FMCSStream);
          Break;
        End;

        LMCS := TRESTDWMCSClient.Create(FCredentials, FMCSStream);

        FMCSLock.Acquire;
        Try
          FMCS := LMCS;
        Finally
          FMCSLock.Release;
        End;

        Try
          LMCS.OnData := {$IFDEF FPC}@{$ENDIF}MCSData;
          LMCS.Connect;
          State(fsConnected);

          LWhere := 'MCS Receive';
          LMCS.Run;
        Finally
          LMCS.OnData := Nil;

          FMCSLock.Acquire;
          Try
            FMCS := Nil;
          Finally
            FMCSLock.Release;
          End;

          LMCS.Free;
          FreeAndNil(FMCSStream);
        End;

        If Not FThread.MustTerminate Then
          Raise Exception.Create('Canal MCS desconectado');
      Except
        On E : Exception Do
        Begin
          If FThread.MustTerminate Then
            Break;

          State(fsError);
          Error(LWhere, E.Message);

          If Not FConnection.AutoReconnect Then
            Break;

          If FConnection.ReconnectDelay > 0 Then
            For LRetry := 1 To (FConnection.ReconnectDelay Div 100) Do
            Begin
              If FThread.MustTerminate Then
                Break;
              RESTDWFCMSleep(100);
            End;
        End;
      End;
    End;
  Except
    On E : Exception Do
    Begin
      State(fsError);
      Error(LWhere, E.Message);
    End;
  End;

  FreeAndNil(FHTTP);
  FWorkerFinished := True;
End;

Procedure TRESTDWFirebaseCloudMessaging.Start;
Begin
  EnsureOpenSSL;

  If Assigned(FThread) Then
  Begin
    If FWorkerFinished Then
    Begin
      FThread.WaitFor;
      FreeAndNil(FThread);
      FWorkerFinished := False;
    End
    Else
      Exit;
  End;

  If Not FStateLoaded Then
  Begin
    LoadState;
    FStateLoaded := True;
  End;

  State(fsStarting);
  FWorkerFinished := False;
  FThread := TRESTDWFCMWorker.Create(Self);

  {$IFDEF FPC}
  FThread.Start;
  {$ELSE}
    {$IFDEF DELPHI2010UP}
    FThread.Start;
    {$ELSE}
    FThread.Resume;
    {$ENDIF}
  {$ENDIF}
End;

Procedure TRESTDWFirebaseCloudMessaging.Stop;
Var
  LMCS : TRESTDWMCSClient;
Begin
  If Assigned(FThread) Then
    FThread.Terminate;

  FMCSLock.Acquire;
  Try
    If Assigned(FMCS) Then
    Begin
      LMCS := TRESTDWMCSClient(FMCS);
      LMCS.Stop;
    End
    Else
    If Assigned(FMCSStream) Then
      FMCSStream.Disconnect;
  Finally
    FMCSLock.Release;
  End;

  If FInReceiveCallback Then
    Exit;

  If Assigned(FThread) Then
  Begin
    FThread.WaitFor;
    FreeAndNil(FThread);
    FWorkerFinished := False;
  End;

  State(fsStopped);
End;

Procedure TRESTDWFirebaseCloudMessaging.LoadGoogleServices(Const AFileName : String);
Var
  LFile  : TStringList;
  LJSON  : String;
  LValue : String;
Begin
  If Not FileExists(AFileName) Then
    Raise Exception.Create('google-services.json nao encontrado');

  LFile := TStringList.Create;
  Try
    LFile.LoadFromFile(AFileName);
    LJSON := LFile.Text;
  Finally
    LFile.Free;
  End;

  LValue := RESTDWFCMJSONValue(LJSON, 'project_id');
  If LValue <> '' Then
    FProjectID := LValue;

  LValue := RESTDWFCMJSONValue(LJSON, 'mobilesdk_app_id');
  If LValue <> '' Then
    FAppID := LValue;

  LValue := RESTDWFCMJSONValue(LJSON, 'current_key');
  If LValue <> '' Then
    FAPIKey := LValue;

  If FProjectID = '' Then
    Raise Exception.Create('project_id ausente no google-services.json');

  If FAppID = '' Then
    Raise Exception.Create('mobilesdk_app_id ausente no google-services.json');

  If FAPIKey = '' Then
    Raise Exception.Create('current_key ausente no google-services.json');
End;

Procedure TRESTDWFirebaseCloudMessaging.LoadServiceAccountConfig(Const AFileName : String);
Var
  LFile : TStringList;
  LJSON : String;
  LValue : String;
Begin
  If Not FileExists(AFileName) Then
    Raise Exception.Create('Arquivo de conta de servico nao encontrado');

  LFile := TStringList.Create;
  Try
    LFile.LoadFromFile(AFileName);
    LJSON := LFile.Text;
  Finally
    LFile.Free;
  End;

  LValue := RESTDWFCMJSONValue(LJSON, 'project_id');
  If LValue <> '' Then
    FProjectID := LValue;

  FClientEmail :=
    RESTDWFCMJSONValue(
      LJSON,
      'client_email'
    );

  FPrivateKey :=
    RESTDWFCMJSONValue(
      LJSON,
      'private_key'
    );

  If FClientEmail = '' Then
    Raise Exception.Create('client_email ausente na conta de servico');

  If FPrivateKey = '' Then
    Raise Exception.Create('private_key ausente na conta de servico');
End;

Procedure TRESTDWFirebaseCloudMessaging.LoadServiceAccount(Const AFileName : String);
Begin
  LoadServiceAccountConfig(AFileName);
End;

Procedure TRESTDWFirebaseCloudMessaging.RefreshToken;
Begin
  Stop;

  FCredentials.FCMToken := '';
  FCredentials.PushSubscriptionID := '';
  FCredentials.PushEndpoint := '';
  FToken := '';

  SaveState;
  Start;
End;

Function TRESTDWFirebaseCloudMessaging.SendTarget(Const ATargetName,
                                                          ATargetValue : String;
                                                    AMessage           : TRESTDWFCMMessage) : Boolean;
Var
  LOAuth    : TRESTDWFCMOAuth;
  LHeaders  : TStringList;
  LBody,
  LResponse,
  LError    : TRESTDWFCMUTF8Stream;
  LToken,
  LURL : String;
  LTry,
  LDelay : Integer;
  LNotifyError : String;
Begin
  EnsureOpenSSL;

  Result := False;
  LNotifyError := '';

  If AMessage = Nil Then
  Begin
    FLastError := 'Message is nil';
    Exit;
  End;

  If ATargetValue = '' Then
  Begin
    FLastError := ATargetName + ' is empty';
    Exit;
  End;

  If FProjectID = '' Then
    Raise Exception.Create('ProjectID nao configurado');

  If FClientEmail = '' Then
    Raise Exception.Create('ClientEmail nao configurado');

  If FPrivateKey = '' Then
    Raise Exception.Create('PrivateKey nao configurada');

  FSendLock.Acquire;
  Try
    FLastRequest := '';
    FLastResponse := '';
    FLastError := '';
    FResponseCode := 0;

    If FSendHTTP = Nil Then
      FSendHTTP := CreateHTTPTransport(
                     FConnection.ConnectTimeout,
                     FConnection.ReadTimeout
                   );

    If FSendHTTP = Nil Then
      Raise Exception.Create('Motor HTTP FCM nao disponivel');

    FSendHTTP.ConfigureTLS(
      Not FConnection.TLSAllowInsecure,
      FConnection.TLSCAFile,
      FConnection.TLSCAPath
    );

    If FSendOAuth = Nil Then
      FSendOAuth := TRESTDWFCMOAuth.Create(FSendHTTP);

    LOAuth := TRESTDWFCMOAuth(FSendOAuth);
    LOAuth.HTTPTransport := FSendHTTP;

    LToken :=
      LOAuth.AccessToken(
        FClientEmail,
        FPrivateKey
      );

    LURL :=
      'https://fcm.googleapis.com/v1/projects/' +
      FProjectID +
      '/messages:send';

    FLastRequest :=
      RESTDWFCMMessageToJSONTarget(
        ATargetName,
        ATargetValue,
        AMessage,
        False
      );

    LHeaders := TStringList.Create;
    LBody := TRESTDWFCMUTF8Stream.Create(FLastRequest);
    LResponse := TRESTDWFCMUTF8Stream.Create('');
    LError := TRESTDWFCMUTF8Stream.Create('');
    Try
      LHeaders.Values['Authorization'] := 'Bearer ' + LToken;
      LHeaders.Values['Content-Type'] := 'application/json; charset=utf-8';
      LHeaders.Values['Accept'] := 'application/json';

      For LTry := 0 To 3 Do
      Begin
        LBody.Position := 0;
        LResponse.Size := 0;
        LError.Size := 0;

        FResponseCode :=
          FSendHTTP.Post(
            LURL,
            LHeaders,
            LBody,
            LResponse,
            LError
          );

        If (FResponseCode <> 429) And
           (FResponseCode <> 500) And
           (FResponseCode <> 502) And
           (FResponseCode <> 503) And
           (FResponseCode <> 504) Then
          Break;

        If LTry < 3 Then
        Begin
          LDelay := 1000 Shl LTry;
          RESTDWFCMSleep(LDelay);
        End;
      End;

      If LResponse.Size > 0 Then
        FLastResponse := LResponse.AsString
      Else
        FLastResponse := LError.AsString;

      Result :=
        (FResponseCode >= 200) And
        (FResponseCode < 300);

      If Not Result Then
      Begin
        FLastError :=
          'FCM HTTP ' +
          IntToStr(FResponseCode) +
          ': ' +
          FLastResponse;

        LNotifyError := FLastError;
      End;
    Finally
      LError.Free;
      LResponse.Free;
      LBody.Free;
      LHeaders.Free;
    End;
  Finally
    FSendLock.Release;
  End;

  If LNotifyError <> '' Then
    Error(
      'Send',
      LNotifyError
    );
End;

Function TRESTDWFirebaseCloudMessaging.Send(Const ADeviceToken : String;
                                            AMessage           : TRESTDWFCMMessage) : Boolean;
Begin
  Result := SendTarget(
              'token',
              ADeviceToken,
              AMessage
            );
End;

Function TRESTDWFirebaseCloudMessaging.SendTopic(Const ATopic : String;
                                                 AMessage      : TRESTDWFCMMessage) : Boolean;
Var
  LTopic : String;
Begin
  LTopic := ATopic;

  If Pos('/topics/', LTopic) = 1 Then
    Delete(LTopic, 1, Length('/topics/'));

  Result := SendTarget(
              'topic',
              LTopic,
              AMessage
            );
End;

Function TRESTDWFirebaseCloudMessaging.SendCondition(Const ACondition : String;
                                                     AMessage          : TRESTDWFCMMessage) : Boolean;
Begin
  Result := SendTarget(
              'condition',
              ACondition,
              AMessage
            );
End;

End.
