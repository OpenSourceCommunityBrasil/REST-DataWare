Unit uRESTDWSQLDBPhysLink;

{$I uRESTDW.inc}

Interface

{$IFDEF FPC}

{$MODE DELPHI}
{$H+}

Uses
 LResources, Classes, SysUtils, DB, SQLDB, uRESTDWAbout, uRESTDWBasicDB, uRESTDWConsts,
 uRESTDWSQLDBConnection;

Type
 TRESTDWSQLDBQueryBinding = Class
 Public
  Query : TSQLQuery;
  Database : TDatabase;
  Transaction : TDBTransaction;
  BeforeOpen : TDataSetNotifyEvent;
 End;

 TRESTDWSQLDBPhysLink = Class(TRESTDWComponent)
 Private
  FSQLConnection : TSQLConnection;
  FDatabase : TRESTDWDatabasebaseBase;
  FRESTConnection : TRESTDWSQLDBConnection;
  FRESTTransaction : TSQLTransaction;
  FBindings : TList;
  Procedure SetSQLConnection(Const Value : TSQLConnection);
  Procedure SetDatabase(Const Value : TRESTDWDatabasebaseBase);
  Procedure BindSQLDBDataSets;
  Procedure RestoreSQLDBDataSets;
  Procedure BindQuery(AQuery : TSQLQuery);
  Function FindBinding(AQuery : TSQLQuery) : TRESTDWSQLDBQueryBinding;
  Procedure RESTDWQueryBeforeOpen(DataSet : TDataSet);
  Function GetConnected : Boolean;
 Protected
  Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
  Procedure Loaded; Override;
 Public
  Constructor Create(AOwner : TComponent); Override;
  Destructor Destroy; Override;
  Function RESTDWConnect : Boolean;
  Procedure RESTDWDisconnect;
  Property Connected : Boolean Read GetConnected;
 Published
  Property SQLConnection : TSQLConnection Read FSQLConnection Write SetSQLConnection;
  Property Database : TRESTDWDatabasebaseBase Read FDatabase Write SetDatabase;
 End;

{$ENDIF}

Procedure Register;

Implementation

{$IFDEF FPC}

Constructor TRESTDWSQLDBPhysLink.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 FBindings := TList.Create;
 FRESTConnection := TRESTDWSQLDBConnection.Create(Self);
 FRESTConnection.RESTDWDatabase := FDatabase;
 FRESTConnection.LoginPrompt := False;
 FRESTConnection.DatabaseName := 'RESTDW';
 FRESTTransaction := TSQLTransaction.Create(Self);
 FRESTTransaction.Database := FRESTConnection;
 FRESTConnection.Transaction := FRESTTransaction;
End;

Destructor TRESTDWSQLDBPhysLink.Destroy;
Begin
 RestoreSQLDBDataSets;
 SetSQLConnection(Nil);
 SetDatabase(Nil);
 FBindings.Free;
 Inherited Destroy;
End;

Procedure TRESTDWSQLDBPhysLink.Loaded;
Begin
 Inherited Loaded;
 BindSQLDBDataSets;
End;

Function TRESTDWSQLDBPhysLink.FindBinding(AQuery : TSQLQuery) : TRESTDWSQLDBQueryBinding;
Var
 I : Integer;
Begin
 Result := Nil;
 If (AQuery = Nil) Or (FBindings = Nil) Then
  Begin
   Exit;
  End;
 For I := 0 To FBindings.Count - 1 Do
  Begin
   If TRESTDWSQLDBQueryBinding(FBindings[I]).Query = AQuery Then
    Begin
     Result := TRESTDWSQLDBQueryBinding(FBindings[I]);
     Exit;
    End;
  End;
End;

Procedure TRESTDWSQLDBPhysLink.BindQuery(AQuery : TSQLQuery);
Var
 LBinding : TRESTDWSQLDBQueryBinding;
Begin
 If (AQuery = Nil) Or (FSQLConnection = Nil) Then
  Begin
   Exit;
  End;
 If FindBinding(AQuery) <> Nil Then
  Begin
   Exit;
  End;
 If AQuery.Database <> FSQLConnection Then
  Begin
   Exit;
  End;
 LBinding := TRESTDWSQLDBQueryBinding.Create;
 LBinding.Query := AQuery;
 LBinding.Database := AQuery.Database;
 LBinding.Transaction := AQuery.Transaction;
 LBinding.BeforeOpen := AQuery.BeforeOpen;
 FBindings.Add(LBinding);
 AQuery.FreeNotification(Self);
 If LBinding.Database <> Nil Then
  Begin
   LBinding.Database.FreeNotification(Self);
  End;
 If LBinding.Transaction <> Nil Then
  Begin
   LBinding.Transaction.FreeNotification(Self);
  End;
 AQuery.BeforeOpen := RESTDWQueryBeforeOpen;
 AQuery.Database := FRESTConnection;
 AQuery.Transaction := FRESTTransaction;
End;

Procedure TRESTDWSQLDBPhysLink.RESTDWQueryBeforeOpen(DataSet : TDataSet);
Var
 LQuery : TSQLQuery;
 LBinding : TRESTDWSQLDBQueryBinding;
Begin
 If Not (DataSet Is TSQLQuery) Then
  Begin
   Exit;
  End;
 LQuery := TSQLQuery(DataSet);
 LBinding := FindBinding(LQuery);
 If LBinding = Nil Then
  Begin
   Exit;
  End;
 If Not RESTDWConnect Then
  Begin
   Raise Exception.Create(cErrorDatabaseNotFound);
  End;
 LQuery.Database := FRESTConnection;
 LQuery.Transaction := FRESTTransaction;
 If Assigned(LBinding.BeforeOpen) Then
  Begin
   LBinding.BeforeOpen(DataSet);
  End;
End;

Function TRESTDWSQLDBPhysLink.GetConnected : Boolean;
Begin
 Result := False;
 If FDatabase = Nil Then
  Begin
   Exit;
  End;
 If FRESTConnection = Nil Then
  Begin
   Exit;
  End;
 Result := FDatabase.Active And FRESTConnection.Connected;
End;

Function TRESTDWSQLDBPhysLink.RESTDWConnect : Boolean;
Begin
 Result := False;
 If FDatabase = Nil Then
  Begin
   Exit;
  End;
 If FRESTConnection = Nil Then
  Begin
   Exit;
  End;
 FRESTConnection.RESTDWDatabase := FDatabase;
 If Not FDatabase.Active Then
  Begin
   FDatabase.Active := True;
  End;
 If Not FDatabase.Active Then
  Begin
   Exit;
  End;
 FRESTConnection.DatabaseName := 'RESTDW';
 FRESTConnection.LoginPrompt := False;
 If Not FRESTConnection.Connected Then
  Begin
   FRESTConnection.Connected := True;
  End;
 Result := FRESTConnection.Connected;
End;

Procedure TRESTDWSQLDBPhysLink.RESTDWDisconnect;
Begin
 If FRESTConnection <> Nil Then
  Begin
   If FRESTConnection.Connected Then
    Begin
     FRESTConnection.Connected := False;
    End;
  End;
End;

Procedure TRESTDWSQLDBPhysLink.Notification(AComponent : TComponent; Operation : TOperation);
Var
 I : Integer;
 LBinding : TRESTDWSQLDBQueryBinding;
Begin
 Inherited Notification(AComponent, Operation);
 If Operation = opRemove Then
  Begin
   If FBindings <> Nil Then
    Begin
     For I := FBindings.Count - 1 DownTo 0 Do
      Begin
       LBinding := TRESTDWSQLDBQueryBinding(FBindings[I]);
       If LBinding.Query = AComponent Then
        Begin
         LBinding.Query := Nil;
         LBinding.Free;
         FBindings.Delete(I);
        End
       Else
        Begin
         If LBinding.Database = AComponent Then
          Begin
           LBinding.Database := Nil;
          End;
         If LBinding.Transaction = AComponent Then
          Begin
           LBinding.Transaction := Nil;
          End;
        End;
      End;
    End;
   If AComponent = FSQLConnection Then
    Begin
     FSQLConnection := Nil;
    End;
   If AComponent = FDatabase Then
    Begin
     FDatabase := Nil;
     If FRESTConnection <> Nil Then
      Begin
       FRESTConnection.RESTDWDatabase := Nil;
      End;
    End;
  End;
End;

Procedure TRESTDWSQLDBPhysLink.RestoreSQLDBDataSets;
Var
 I : Integer;
 LBinding : TRESTDWSQLDBQueryBinding;
Begin
 If FBindings = Nil Then
  Begin
   Exit;
  End;
 For I := FBindings.Count - 1 DownTo 0 Do
  Begin
   LBinding := TRESTDWSQLDBQueryBinding(FBindings[I]);
   If LBinding.Query <> Nil Then
    Begin
     If LBinding.Query.Active Then
      Begin
       LBinding.Query.Close;
      End;
     LBinding.Query.BeforeOpen := LBinding.BeforeOpen;
     LBinding.Query.Transaction := LBinding.Transaction;
     LBinding.Query.Database := LBinding.Database;
     LBinding.Query.RemoveFreeNotification(Self);
    End;
   If LBinding.Database <> Nil Then
    Begin
     LBinding.Database.RemoveFreeNotification(Self);
    End;
   If LBinding.Transaction <> Nil Then
    Begin
     LBinding.Transaction.RemoveFreeNotification(Self);
    End;
   LBinding.Free;
  End;
 FBindings.Clear;
 If FRESTConnection <> Nil Then
  Begin
   If FRESTConnection.Connected Then
    Begin
     FRESTConnection.Connected := False;
    End;
  End;
End;

Procedure TRESTDWSQLDBPhysLink.BindSQLDBDataSets;
Var
 I : Integer;
 LDataSet : TDataSet;
 LComponent : TComponent;
Begin
 If csDesigning In ComponentState Then
  Begin
   Exit;
  End;
 If (FSQLConnection = Nil) Or (FRESTConnection = Nil) Or (FRESTTransaction = Nil) Then
  Begin
   Exit;
  End;
 FRESTConnection.RESTDWDatabase := FDatabase;
 For I := 0 To FSQLConnection.DataSetCount - 1 Do
  Begin
   LDataSet := FSQLConnection.DataSets[I];
   If LDataSet Is TSQLQuery Then
    Begin
     BindQuery(TSQLQuery(LDataSet));
    End;
  End;
 If Owner <> Nil Then
  Begin
   For I := 0 To Owner.ComponentCount - 1 Do
    Begin
     LComponent := Owner.Components[I];
     If LComponent Is TSQLQuery Then
      Begin
       BindQuery(TSQLQuery(LComponent));
      End;
    End;
  End;
End;

Procedure TRESTDWSQLDBPhysLink.SetSQLConnection(Const Value : TSQLConnection);
Begin
 If FSQLConnection = Value Then
  Begin
   Exit;
  End;
 RestoreSQLDBDataSets;
 If FSQLConnection <> Nil Then
  Begin
   FSQLConnection.RemoveFreeNotification(Self);
  End;
 FSQLConnection := Value;
 If FSQLConnection <> Nil Then
  Begin
   FSQLConnection.FreeNotification(Self);
  End;
 BindSQLDBDataSets;
End;

Procedure TRESTDWSQLDBPhysLink.SetDatabase(Const Value : TRESTDWDatabasebaseBase);
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
 If FRESTConnection <> Nil Then
  Begin
   FRESTConnection.RESTDWDatabase := FDatabase;
  End;
 If FDatabase <> Nil Then
  Begin
   FDatabase.FreeNotification(Self);
  End;
 BindSQLDBDataSets;
End;

Procedure Register;
Begin
 RegisterComponents('REST Dataware - PhysLink', [TRESTDWSQLDBPhysLink]);
End;

{$ENDIF}

Initialization
{$IFDEF FPC}
 {$I uRESTDWSQLDBPhysLink.lrs}
{$ENDIF}
End.
