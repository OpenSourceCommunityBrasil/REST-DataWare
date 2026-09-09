Unit uRESTDWDBExpressDriver;

{$I uRESTDW.inc}

Interface

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes, System.SysUtils, Data.DB, Data.SqlExpr,
{$ELSE}
 Classes, SysUtils, DB, SqlExpr,
{$ENDIF}
 uRESTDWDriverBase, uRESTDWBasicDbTypes, uRESTDWProtoTypes,
 uRESTDWMemoryDataset;

Type
 TRESTDWDBExpressStoreProc = Class(TRESTDWDrvStoreProc)
 Public
  Procedure ExecProc; Override;
  Procedure Prepare; Override;
 End;

 TRESTDWDBExpressTable = Class(TRESTDWDrvTable)
 Public
  Procedure SaveToStream(Stream : TStream); Override;
 End;

 TRESTDWDBExpressQuery = Class(TRESTDWDrvQuery)
 Private
  FRowsAffected : Int64;
 Public
  Procedure ExecSQL; Override;
  Procedure Prepare; Override;
  Procedure SaveToStream(Stream : TStream); Override;

  Function RowsAffected : Int64; Override;
  Function ParamCount : Integer; Override;
  Function getParamDataType(IParam : Integer) : TFieldType; Override;
  Function getParamName(IParam : Integer) : String; Override;
  Function getParamSize(IParam : Integer) : Integer; Override;
  Function getParamValue(IParam : Integer) : Variant; Override;

  Procedure setParamDataType(IParam : Integer; AValue : TFieldType); Override;
  Procedure setParamValue(IParam : Integer; AValue : Variant); Override;
  Procedure LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                BlobType : TBlobType); Override;
 End;

 TRESTDWDBExpressDriver = Class(TRESTDWDriverBase)
 Private
  FTransaction : TTransactionDesc;
 Protected
  Function getConnectionType : TRESTDWDatabaseType; Override;
  Function compConnIsValid(Comp : TComponent) : Boolean; Override;
 Public
  Constructor Create(AOwner : TComponent); Override;

  Function getQuery : TRESTDWDrvQuery; Override;
  Function getQuery(AUnidir : Boolean) : TRESTDWDrvQuery; Override;
  Function getTable : TRESTDWDrvTable; Override;
  Function getStoreProc : TRESTDWDrvStoreProc; Override;

  Procedure Connect; Override;
  Procedure Disconect; Override;

  Function isConnected : Boolean; Override;
  Function connInTransaction : Boolean; Override;
  Procedure connStartTransaction; Override;
  Procedure connRollback; Override;
  Procedure connCommit; Override;

  Class Procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                   Var AConnection : TComponent); Override;
 End;

Procedure Register;

Implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - Drivers', [TRESTDWDBExpressDriver]);
End;

Procedure TRESTDWDBExpressStoreProc.ExecProc;
Begin
 Inherited ExecProc;
 TSQLStoredProc(Self.Owner).ExecProc;
End;

Procedure TRESTDWDBExpressStoreProc.Prepare;
Begin
 Inherited Prepare;
 TSQLStoredProc(Self.Owner).Prepared := True;
End;

Procedure TRESTDWDBExpressTable.SaveToStream(Stream : TStream);
Var
 DataSet : TSQLTable;
 MemTable : TRESTDWMemtable;
Begin
 DataSet := TSQLTable(Self.Owner);
 MemTable := TRESTDWMemtable.Create(Nil);
 Try
  MemTable.Assign(DataSet);
  MemTable.SaveToStream(Stream);
  Stream.Position := 0;
 Finally
  FreeAndNil(MemTable);
 End;
End;

Procedure TRESTDWDBExpressQuery.ExecSQL;
Begin
 Inherited ExecSQL;
 FRowsAffected := TSQLQuery(Self.Owner).ExecSQL;
End;

Procedure TRESTDWDBExpressQuery.Prepare;
Begin
 Inherited Prepare;
 TSQLQuery(Self.Owner).Prepared := True;
End;

Procedure TRESTDWDBExpressQuery.SaveToStream(Stream : TStream);
Var
 DataSet : TSQLQuery;
 MemTable : TRESTDWMemtable;
Begin
 DataSet := TSQLQuery(Self.Owner);
 MemTable := TRESTDWMemtable.Create(Nil);
 Try
  MemTable.Assign(DataSet);
  MemTable.SaveToStream(Stream);
  Stream.Position := 0;
 Finally
  FreeAndNil(MemTable);
 End;
End;

Function TRESTDWDBExpressQuery.RowsAffected : Int64;
Begin
 Result := FRowsAffected;
End;

Function TRESTDWDBExpressQuery.ParamCount : Integer;
Begin
 Result:=TSQLQuery(Self.Owner).Params.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   Result:=TSQLQuery(Self.Owner).Params.Count;
  End;
End;

Function TRESTDWDBExpressQuery.getParamDataType(IParam : Integer) : TFieldType;
Begin
 Result := TSQLQuery(Self.Owner).Params[IParam].DataType;
End;

Function TRESTDWDBExpressQuery.getParamName(IParam : Integer) : String;
Begin
 Result := TSQLQuery(Self.Owner).Params[IParam].Name;
End;

Function TRESTDWDBExpressQuery.getParamSize(IParam : Integer) : Integer;
Begin
 Result := TSQLQuery(Self.Owner).Params[IParam].Size;
End;

Function TRESTDWDBExpressQuery.getParamValue(IParam : Integer) : Variant;
Begin
 Result := TSQLQuery(Self.Owner).Params[IParam].Value;
End;

Procedure TRESTDWDBExpressQuery.setParamDataType(IParam : Integer; AValue : TFieldType);
Begin
 TSQLQuery(Self.Owner).Params[IParam].DataType := AValue;
End;

Procedure TRESTDWDBExpressQuery.setParamValue(IParam : Integer; AValue : Variant);
Begin
 TSQLQuery(Self.Owner).Params[IParam].Value := AValue;
End;

Procedure TRESTDWDBExpressQuery.LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                                    BlobType : TBlobType);
Begin
 TSQLQuery(Self.Owner).Params[IParam].LoadFromStream(Stream, BlobType);
End;

Constructor TRESTDWDBExpressDriver.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 FillChar(FTransaction, SizeOf(FTransaction), 0);
 FTransaction.TransactionID := 1;
 FTransaction.IsolationLevel := xilREADCOMMITTED;
End;

Function TRESTDWDBExpressDriver.getConnectionType : TRESTDWDatabaseType;
Var
 DriverName : String;
Begin
 Result := Inherited getConnectionType;
 If (Result <> dbtUndefined) or (Not Assigned(Connection)) Then
  Begin
   Exit;
  End;
 DriverName := LowerCase(TSQLConnection(Connection).DriverName);
 If Pos('firebird', DriverName) > 0 Then
  Begin
   Result := dbtFirebird
  End
 Else If Pos('interbase', DriverName) > 0 Then
  Result := dbtInterbase
 Else If Pos('mysql', DriverName) > 0 Then
  Result := dbtMySQL
 Else If Pos('oracle', DriverName) > 0 Then
  Result := dbtOracle
 Else If (Pos('mssql', DriverName) > 0) or (Pos('sqlserver', DriverName) > 0) Then
  Result := dbtMsSQL
 Else If Pos('odbc', DriverName) > 0 Then
  Result := dbtODBC;
End;

Function TRESTDWDBExpressDriver.compConnIsValid(Comp : TComponent) : Boolean;
Begin
 Result := Comp.InheritsFrom(TSQLConnection);
End;

Function TRESTDWDBExpressDriver.getQuery : TRESTDWDrvQuery;
Var
 Query : TSQLQuery;
Begin
 Query := TSQLQuery.Create(Self);
 Query.SQLConnection := TSQLConnection(Connection);
 Query.ParamCheck := True;
 Result := TRESTDWDBExpressQuery.Create(Query);
End;

Function TRESTDWDBExpressDriver.getQuery(AUnidir : Boolean) : TRESTDWDrvQuery;
Var
 Query : TSQLQuery;
Begin
 Query := TSQLQuery.Create(Self);
 Query.SQLConnection := TSQLConnection(Connection);
 Query.ParamCheck := True;
 Query.GetMetadata := False;
 Result := TRESTDWDBExpressQuery.Create(Query);
End;

Function TRESTDWDBExpressDriver.getTable : TRESTDWDrvTable;
Var
 Table : TSQLTable;
Begin
 Table := TSQLTable.Create(Self);
 Table.SQLConnection := TSQLConnection(Connection);
 Result := TRESTDWDBExpressTable.Create(Table);
End;

Function TRESTDWDBExpressDriver.getStoreProc : TRESTDWDrvStoreProc;
Var
 StoreProc : TSQLStoredProc;
Begin
 StoreProc := TSQLStoredProc.Create(Self);
 StoreProc.SQLConnection := TSQLConnection(Connection);
 Result := TRESTDWDBExpressStoreProc.Create(StoreProc);
End;

Procedure TRESTDWDBExpressDriver.Connect;
Begin
 If Assigned(Connection) Then
  Begin
   TSQLConnection(Connection).Connected := True;
  End;
 Inherited Connect;
End;

Procedure TRESTDWDBExpressDriver.Disconect;
Begin
 If Assigned(Connection) Then
  Begin
   TSQLConnection(Connection).Connected := False;
  End;
 Inherited Disconect;
End;

Function TRESTDWDBExpressDriver.isConnected : Boolean;
Begin
 Result := Inherited isConnected;
 If Assigned(Connection) Then
  Begin
   Result := TSQLConnection(Connection).Connected;
  End;
End;

Function TRESTDWDBExpressDriver.connInTransaction : Boolean;
Begin
 Result := Inherited connInTransaction;
 If Assigned(Connection) Then
  Begin
   Result := TSQLConnection(Connection).InTransaction;
  End;
End;

Procedure TRESTDWDBExpressDriver.connStartTransaction;
Begin
 Inherited connStartTransaction;
 If Assigned(Connection) And (Not TSQLConnection(Connection).InTransaction) Then
  Begin
   TSQLConnection(Connection).StartTransaction(FTransaction);
  End;
End;

Procedure TRESTDWDBExpressDriver.connRollback;
Begin
 Inherited connRollback;
 If Assigned(Connection) And TSQLConnection(Connection).InTransaction Then
  Begin
   TSQLConnection(Connection).Rollback(FTransaction);
  End;
End;

Procedure TRESTDWDBExpressDriver.connCommit;
Begin
 Inherited connCommit;
 If Assigned(Connection) And TSQLConnection(Connection).InTransaction Then
  Begin
   TSQLConnection(Connection).Commit(FTransaction);
  End;
End;

Class Procedure TRESTDWDBExpressDriver.CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                                        Var AConnection : TComponent);
Var
 Conn : TSQLConnection;
Begin
 Inherited CreateConnection(AConnectionDefs, AConnection);
 If (Not Assigned(AConnectionDefs)) or (Not Assigned(AConnection)) Then
  Begin
   Exit;
  End;
 Conn := TSQLConnection(AConnection);
 If Conn.Connected Then
  Begin
   Exit;
  End;
 Conn.LoginPrompt := False;
 If Trim(AConnectionDefs.DriverID) <> '' Then
  Begin
   Conn.DriverName := AConnectionDefs.DriverID;
  End;
 If Trim(AConnectionDefs.DatabaseName) <> '' Then
  Begin
   Conn.Params.Values['Database'] := AConnectionDefs.DatabaseName;
  End;
 If Trim(AConnectionDefs.HostName) <> '' Then
  Begin
   Conn.Params.Values['HostName'] := AConnectionDefs.HostName;
  End;
 If Trim(AConnectionDefs.Username) <> '' Then
  Begin
   Conn.Params.Values['User_Name'] := AConnectionDefs.Username;
  End;
 If Trim(AConnectionDefs.Password) <> '' Then
  Begin
   Conn.Params.Values['Password'] := AConnectionDefs.Password;
  End;
 If Trim(AConnectionDefs.Charset) <> '' Then
  Begin
   Conn.Params.Values['ServerCharSet'] := AConnectionDefs.Charset;
  End;
 If Trim(AConnectionDefs.OtherDetails) <> '' Then
  Begin
   Conn.Params.Text := Conn.Params.Text + AConnectionDefs.OtherDetails;
  End;
End;

Initialization
 RegisterClass(TRESTDWDBExpressDriver);
 RegisterRESTDWDriverClass(TRESTDWDBExpressDriver);

Finalization
 UnregisterRESTDWDriverClass(TRESTDWDBExpressDriver);
 UnRegisterClass(TRESTDWDBExpressDriver);
End.
