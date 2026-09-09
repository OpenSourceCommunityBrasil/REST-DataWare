Unit uRESTDWADODriver;

{$I uRESTDW.inc}

Interface

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes, System.SysUtils, Data.DB, Data.Win.ADODB,
{$ELSE}
 Classes, SysUtils, DB, ADODB,
{$ENDIF}
 uRESTDWDriverBase, uRESTDWBasicDbTypes, uRESTDWProtoTypes,
 uRESTDWMemoryDataset;

Type
 TRESTDWADOStoreProc = Class(TRESTDWDrvStoreProc)
 Public
  Procedure ExecProc; Override;
  Procedure Prepare; Override;
 End;

 TRESTDWADOTable = Class(TRESTDWDrvTable)
 Public
  Procedure SaveToStream(Stream : TStream); Override;
 End;

 TRESTDWADOQuery = Class(TRESTDWDrvQuery)
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

 TRESTDWADODriver = Class(TRESTDWDriverBase)
 Protected
  Function getConnectionType : TRESTDWDatabaseType; Override;
  Function compConnIsValid(Comp : TComponent) : Boolean; Override;
 Public
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
 RegisterComponents('REST Dataware - Drivers', [TRESTDWADODriver]);
End;

Procedure TRESTDWADOStoreProc.ExecProc;
Begin
 Inherited ExecProc;
 TADOStoredProc(Self.Owner).ExecProc;
End;

Procedure TRESTDWADOStoreProc.Prepare;
Begin
 Inherited Prepare;
 TADOStoredProc(Self.Owner).Prepared := True;
End;

Procedure TRESTDWADOTable.SaveToStream(Stream : TStream);
Var
 DataSet : TADOTable;
 MemTable : TRESTDWMemtable;
Begin
 DataSet := TADOTable(Self.Owner);
 MemTable := TRESTDWMemtable.Create(Nil);
 Try
  MemTable.Assign(DataSet);
  MemTable.SaveToStream(Stream);
  Stream.Position := 0;
 Finally
  FreeAndNil(MemTable);
 End;
End;

Procedure TRESTDWADOQuery.ExecSQL;
Begin
 Inherited ExecSQL;
 FRowsAffected := TADOQuery(Self.Owner).ExecSQL;
End;

Procedure TRESTDWADOQuery.Prepare;
Begin
 Inherited Prepare;
 TADOQuery(Self.Owner).Prepared := True;
End;

Procedure TRESTDWADOQuery.SaveToStream(Stream : TStream);
Var
 DataSet : TADOQuery;
 MemTable : TRESTDWMemtable;
Begin
 DataSet := TADOQuery(Self.Owner);
 MemTable := TRESTDWMemtable.Create(Nil);
 Try
  MemTable.Assign(DataSet);
  MemTable.SaveToStream(Stream);
  Stream.Position := 0;
 Finally
  FreeAndNil(MemTable);
 End;
End;

Function TRESTDWADOQuery.RowsAffected : Int64;
Begin
 Result := FRowsAffected;
End;

Function TRESTDWADOQuery.ParamCount : Integer;
Begin
 Result:=TADOQuery(Self.Owner).Parameters.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   Result:=TADOQuery(Self.Owner).Parameters.Count;
  End;
End;

Function TRESTDWADOQuery.getParamDataType(IParam : Integer) : TFieldType;
Begin
 Result := TADOQuery(Self.Owner).Parameters[IParam].DataType;
End;

Function TRESTDWADOQuery.getParamName(IParam : Integer) : String;
Begin
 Result := TADOQuery(Self.Owner).Parameters[IParam].Name;
End;

Function TRESTDWADOQuery.getParamSize(IParam : Integer) : Integer;
Begin
 Result := TADOQuery(Self.Owner).Parameters[IParam].Size;
End;

Function TRESTDWADOQuery.getParamValue(IParam : Integer) : Variant;
Begin
 Result := TADOQuery(Self.Owner).Parameters[IParam].Value;
End;

Procedure TRESTDWADOQuery.setParamDataType(IParam : Integer; AValue : TFieldType);
Begin
 TADOQuery(Self.Owner).Parameters[IParam].DataType := AValue;
End;

Procedure TRESTDWADOQuery.setParamValue(IParam : Integer; AValue : Variant);
Begin
 TADOQuery(Self.Owner).Parameters[IParam].Value := AValue;
End;

Procedure TRESTDWADOQuery.LoadFromStreamParam(IParam : Integer; Stream : TStream;
                                              BlobType : TBlobType);
Begin
 TADOQuery(Self.Owner).Parameters[IParam].LoadFromStream(Stream, TFieldType(BlobType));
End;

Function TRESTDWADODriver.getConnectionType : TRESTDWDatabaseType;
Begin
 Result := dbtAdo;
End;

Function TRESTDWADODriver.compConnIsValid(Comp : TComponent) : Boolean;
Begin
 Result := Comp.InheritsFrom(TADOConnection);
End;

Function TRESTDWADODriver.getQuery : TRESTDWDrvQuery;
Var
 Query : TADOQuery;
Begin
 Query := TADOQuery.Create(Self);
 Query.Connection := TADOConnection(Connection);
 Query.ParamCheck := True;
 Result := TRESTDWADOQuery.Create(Query);
End;

Function TRESTDWADODriver.getQuery(AUnidir : Boolean) : TRESTDWDrvQuery;
Begin
 Result := getQuery;
End;

Function TRESTDWADODriver.getTable : TRESTDWDrvTable;
Var
 Table : TADOTable;
Begin
 Table := TADOTable.Create(Self);
 Table.Connection := TADOConnection(Connection);
 Result := TRESTDWADOTable.Create(Table);
End;

Function TRESTDWADODriver.getStoreProc : TRESTDWDrvStoreProc;
Var
 StoreProc : TADOStoredProc;
Begin
 StoreProc := TADOStoredProc.Create(Self);
 StoreProc.Connection := TADOConnection(Connection);
 Result := TRESTDWADOStoreProc.Create(StoreProc);
End;

Procedure TRESTDWADODriver.Connect;
Begin
 If Assigned(Connection) Then
  Begin
   TADOConnection(Connection).Connected := True;
  End;
 Inherited Connect;
End;

Procedure TRESTDWADODriver.Disconect;
Begin
 If Assigned(Connection) Then
  Begin
   TADOConnection(Connection).Connected := False;
  End;
 Inherited Disconect;
End;

Function TRESTDWADODriver.isConnected : Boolean;
Begin
 Result := Inherited isConnected;
 If Assigned(Connection) Then
  Begin
   Result := TADOConnection(Connection).Connected;
  End;
End;

Function TRESTDWADODriver.connInTransaction : Boolean;
Begin
 Result := Inherited connInTransaction;
 If Assigned(Connection) Then
  Begin
   Result := TADOConnection(Connection).InTransaction;
  End;
End;

Procedure TRESTDWADODriver.connStartTransaction;
Begin
 Inherited connStartTransaction;
 If Assigned(Connection) And (Not TADOConnection(Connection).InTransaction) Then
  Begin
   TADOConnection(Connection).BeginTrans;
  End;
End;

Procedure TRESTDWADODriver.connRollback;
Begin
 Inherited connRollback;
 If Assigned(Connection) And TADOConnection(Connection).InTransaction Then
  Begin
   TADOConnection(Connection).RollbackTrans;
  End;
End;

Procedure TRESTDWADODriver.connCommit;
Begin
 Inherited connCommit;
 If Assigned(Connection) And TADOConnection(Connection).InTransaction Then
  Begin
   TADOConnection(Connection).CommitTrans;
  End;
End;

Class Procedure TRESTDWADODriver.CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                                  Var AConnection : TComponent);
Var
 Conn : TADOConnection;
 ConnString : String;
Begin
 Inherited CreateConnection(AConnectionDefs, AConnection);
 If (Not Assigned(AConnectionDefs)) Or (Not Assigned(AConnection)) Then
  Begin
   Exit;
  End;
 Conn := TADOConnection(AConnection);
 If Conn.Connected Then
  Begin
   Exit;
  End;
 Conn.LoginPrompt := False;
 If Trim(AConnectionDefs.OtherDetails) <> '' Then
  Begin
   ConnString := AConnectionDefs.OtherDetails
  End
 Else
  Begin
   ConnString := '';
   If Trim(AConnectionDefs.DataSource) <> '' Then
    Begin
     ConnString := 'Data Source=' + AConnectionDefs.DataSource + ';';
    End;
   If Trim(AConnectionDefs.DatabaseName) <> '' Then
    Begin
     ConnString := ConnString + 'Initial Catalog=' + AConnectionDefs.DatabaseName + ';';
    End;
   If Trim(AConnectionDefs.Username) <> '' Then
    Begin
     ConnString := ConnString + 'User ID=' + AConnectionDefs.Username + ';';
    End;
   If Trim(AConnectionDefs.Password) <> '' Then
    Begin
     ConnString := ConnString + 'Password=' + AConnectionDefs.Password + ';';
    End;
  End;
 If Trim(ConnString) <> '' Then
  Begin
   Conn.ConnectionString := ConnString;
  End;
End;

Initialization
 RegisterClass(TRESTDWADODriver);
 RegisterRESTDWDriverClass(TRESTDWADODriver);

Finalization
 UnregisterRESTDWDriverClass(TRESTDWADODriver);
 UnRegisterClass(TRESTDWADODriver);
End.
