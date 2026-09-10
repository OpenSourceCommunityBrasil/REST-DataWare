Unit uRESTDWADOPhysLink;

{$I uRESTDW.inc}

Interface

{$IFNDEF FPC}

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes, System.SysUtils, Data.DB, Data.Win.ADODB,
{$ELSE}
 Classes, SysUtils, DB, ADODB,
{$ENDIF}
 uRESTDWAbout, uRESTDWBasicDB, uRESTDWConsts;

Type
 TRESTDWADOPhysLink = Class(TRESTDWComponent)
 Private
  FADOConnection : TADOConnection;
  FDatabase : TRESTDWDatabasebaseBase;
  FOldBeforeConnect : TNotifyEvent;
  FOldAfterDisconnect : TNotifyEvent;
  Procedure SetADOConnection(Const Value : TADOConnection);
  Procedure SetDatabase(Const Value : TRESTDWDatabasebaseBase);
 Protected
  Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
  Procedure RESTDWBeforeConnect(Sender : TObject);
  Procedure RESTDWAfterDisconnect(Sender : TObject);
 Public
  Destructor Destroy; Override;
 Published
  Property ADOConnection : TADOConnection Read FADOConnection Write SetADOConnection;
  Property Database : TRESTDWDatabasebaseBase Read FDatabase Write SetDatabase;
 End;

{$ENDIF}

Implementation

{$IFNDEF FPC}

Procedure TRESTDWADOPhysLink.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If Operation = opRemove Then
  Begin
   If AComponent = FADOConnection Then
    Begin
     FADOConnection := Nil;
     FOldBeforeConnect := Nil;
     FOldAfterDisconnect := Nil;
    End;
   If AComponent = FDatabase Then
    Begin
     FDatabase := Nil;
    End;
  End;
End;

Destructor TRESTDWADOPhysLink.Destroy;
Begin
 SetADOConnection(Nil);
 SetDatabase(Nil);
 Inherited Destroy;
End;

Procedure TRESTDWADOPhysLink.RESTDWBeforeConnect(Sender : TObject);
Begin
 If Assigned(FOldBeforeConnect) Then
  Begin
   FOldBeforeConnect(Sender);
  End;
 If FDatabase = Nil Then
  Begin
   Raise Exception.Create(cErrorDatabaseNotFound);
  End;
 FDatabase.Active := True;
End;

Procedure TRESTDWADOPhysLink.RESTDWAfterDisconnect(Sender : TObject);
Begin
 If FDatabase <> Nil Then
  Begin
   FDatabase.Active := False;
  End;
 If Assigned(FOldAfterDisconnect) Then
  Begin
   FOldAfterDisconnect(Sender);
  End;
End;

Procedure TRESTDWADOPhysLink.SetADOConnection(Const Value : TADOConnection);
Begin
 If FADOConnection = Value Then
  Begin
   Exit;
  End;
 If FADOConnection <> Nil Then
  Begin
   FADOConnection.BeforeConnect := FOldBeforeConnect;
   FADOConnection.AfterDisconnect := FOldAfterDisconnect;
   FADOConnection.RemoveFreeNotification(Self);
  End;
 FADOConnection := Value;
 FOldBeforeConnect := Nil;
 FOldAfterDisconnect := Nil;
 If FADOConnection <> Nil Then
  Begin
   FADOConnection.FreeNotification(Self);
   FOldBeforeConnect := FADOConnection.BeforeConnect;
   FOldAfterDisconnect := FADOConnection.AfterDisconnect;
   FADOConnection.BeforeConnect := RESTDWBeforeConnect;
   FADOConnection.AfterDisconnect := RESTDWAfterDisconnect;
  End;
End;

Procedure TRESTDWADOPhysLink.SetDatabase(Const Value : TRESTDWDatabasebaseBase);
Begin
 If FDatabase = Value Then
  Begin
   Exit;
  End;
 If FDatabase <> Nil Then
  Begin
   FDatabase.RemoveFreeNotification(Self);
  End;
 FDatabase := Value;
 If FDatabase <> Nil Then
  Begin
   FDatabase.FreeNotification(Self);
  End;
End;

{$ENDIF}
End.
