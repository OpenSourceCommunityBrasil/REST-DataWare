Unit uRESTDWDBExpressPhysLink;

{$I uRESTDW.inc}

Interface

{$IFNDEF FPC}

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes, System.SysUtils, Data.DB, Data.SqlExpr,
{$ELSE}
 Classes, SysUtils, DB, SqlExpr,
{$ENDIF}
 uRESTDWAbout, uRESTDWBasicDB, uRESTDWConsts;

Type
 TRESTDWDBExpressPhysLink = Class(TRESTDWComponent)
 Private
  FSQLConnection : TSQLConnection;
  FDatabase : TRESTDWDatabasebaseBase;
  FOldBeforeConnect : TNotifyEvent;
  FOldAfterDisconnect : TNotifyEvent;
  Procedure SetSQLConnection(Const Value : TSQLConnection);
  Procedure SetDatabase(Const Value : TRESTDWDatabasebaseBase);
 Protected
  Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
  Procedure RESTDWBeforeConnect(Sender : TObject);
  Procedure RESTDWAfterDisconnect(Sender : TObject);
 Public
  Destructor Destroy; Override;
 Published
  Property SQLConnection : TSQLConnection Read FSQLConnection Write SetSQLConnection;
  Property Database : TRESTDWDatabasebaseBase Read FDatabase Write SetDatabase;
 End;

{$ENDIF}

Implementation

{$IFNDEF FPC}

Procedure TRESTDWDBExpressPhysLink.Notification(AComponent : TComponent; Operation : TOperation);
Begin
 Inherited Notification(AComponent, Operation);
 If Operation = opRemove Then
  Begin
   If AComponent = FSQLConnection Then
    Begin
     FSQLConnection := Nil;
     FOldBeforeConnect := Nil;
     FOldAfterDisconnect := Nil;
    End;
   If AComponent = FDatabase Then
    Begin
     FDatabase := Nil;
    End;
  End;
End;

Destructor TRESTDWDBExpressPhysLink.Destroy;
Begin
 SetSQLConnection(Nil);
 SetDatabase(Nil);
 Inherited Destroy;
End;

Procedure TRESTDWDBExpressPhysLink.RESTDWBeforeConnect(Sender : TObject);
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

Procedure TRESTDWDBExpressPhysLink.RESTDWAfterDisconnect(Sender : TObject);
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

Procedure TRESTDWDBExpressPhysLink.SetSQLConnection(Const Value : TSQLConnection);
Begin
 If FSQLConnection = Value Then
  Begin
   Exit;
  End;
 If FSQLConnection <> Nil Then
  Begin
   FSQLConnection.BeforeConnect := FOldBeforeConnect;
   FSQLConnection.AfterDisconnect := FOldAfterDisconnect;
   FSQLConnection.RemoveFreeNotification(Self);
  End;
 FSQLConnection := Value;
 FOldBeforeConnect := Nil;
 FOldAfterDisconnect := Nil;
 If FSQLConnection <> Nil Then
  Begin
   FSQLConnection.FreeNotification(Self);
   FOldBeforeConnect := FSQLConnection.BeforeConnect;
   FOldAfterDisconnect := FSQLConnection.AfterDisconnect;
   FSQLConnection.BeforeConnect := RESTDWBeforeConnect;
   FSQLConnection.AfterDisconnect := RESTDWAfterDisconnect;
  End;
End;

Procedure TRESTDWDBExpressPhysLink.SetDatabase(Const Value : TRESTDWDatabasebaseBase);
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
