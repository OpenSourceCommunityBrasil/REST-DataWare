unit uRESTDWDriverBase;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

Interface

Uses
  Classes, SysUtils,    TypInfo, uRESTDWParams, uRESTDWComponentBase, DB,
  uRESTDWEncodeClass,   uRESTDWCharset,         uRESTDWComponentEvents,
  uRESTDWMassiveBuffer, uRESTDWJSONInterface,   uRESTDWConsts,
  uRESTDWDataModule,    uRESTDWBasicTypes,      uRESTDWTools,
  uRESTDWBufferBase,    Variants;

 Type
  TRESTDWDatabaseInfo = Record
   rdwDatabaseName          : String;
   rdwDatabaseMajorVersion,
   rdwDatabaseMinorVersion,
   rdwDatabaseSubVersion    : Integer;
 End;
  TRESTDWDataset      = Class(TComponent)
 Protected
  Function  getFields                     : TFields; Virtual;
  Function  getParams                     : TParams; Virtual;
  Procedure CreateSequencedField(seqname,
                                 field    : String); Virtual;
 Public
  Procedure Close;    Virtual;
  Procedure Open;     Virtual;
  Procedure Insert;   Virtual;
  Procedure Edit;     Virtual;
  Procedure Post;     Virtual;
  Procedure Delete;   Virtual;
  Procedure Next;     Virtual;
  Procedure Prepare;  Virtual;
  Procedure ExecSQL;  Virtual;
  Procedure FetchAll; Virtual;
  Procedure SaveToStream(stream : TStream); Virtual;
  Function  Eof         : Boolean; Virtual;
  Function  RecNo       : Int64;   Virtual;
  Function  RecordCount : Int64;   Virtual;
  Function  ParamCount  : Integer; Virtual;
  Function  ParamByName(param : String) : TParam; Virtual;
  Function  FieldByName(field : String) : TField; Virtual;
  Function  FindField  (field : String) : TField; Virtual;
  Function  RDWDataTypeFieldName(field  : String) : Byte;    Virtual;
  Function  RDWDataTypeParamName(param  : String) : Byte;    Virtual;
  Function  GetParamIndex       (param  : String) : integer; Virtual;
 Published
  Property Params : TParams Read getParams;
  Property Fields : TFields Read getFields;
 End;
 { TRESTDWStoreProc }
  TRESTDWStoreProc = Class(TRESTDWDataset)
 Protected
  Function  getStoredProcName        : String;
  Procedure setStoredProcName(AValue : String);
 Public
  Procedure ExecProc; Virtual;
 Published
  Property StoredProcName : String Read getStoredProcName Write setStoredProcName;
 End;
 { TRESTDWTable }
  TRESTDWTable = Class(TRESTDWDataset)
 Private
  Function getFilter            : String;   Virtual;
  Function getFiltered          : Boolean;  Virtual;
  Function getTableName         : String;   Virtual;
  Procedure setFilter   (AValue : String);  Virtual;
  Procedure setFiltered (AValue : Boolean); Virtual;
  Procedure setTableName(AValue : String);  Virtual;
 Public
 Published
  Property Filter    : String  Read getFilter    Write setFilter;
  Property Filtered  : Boolean Read getFiltered  Write setFiltered;
  Property TableName : String  Read getTableName Write setTableName;
 End;
  TRESTDWQuery = Class(TRESTDWDataset)
 Private
  Function getSQL       : TStrings; Virtual;
 Public
  Function RowsAffected : Int64;    Virtual;
  Function GetInsertID  : int64;    Virtual;
 Published
  Property SQL          : TStrings  Read getSQL;
 End;
  { TRESTDWDriverBase }
  TRESTDWDriverBase = Class(TRESTDWComponent)
 Private
  FConnection : TComponent;
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vEncodeStrings,
  vCompression         : Boolean;
  vEncoding            : TEncodeSelect;
  vCommitRecords       : Integer;
  {$IFDEF FPC}
   vDatabaseCharSet    : TDatabaseCharSet;
  {$ENDIF}
  vParamCreate         : Boolean;
  vOnPrepareConnection : TOnPrepareConnection;
  vOnTableBeforeOpen   : TOnTableBeforeOpen;
  vOnQueryBeforeOpen   : TOnQueryBeforeOpen;
  vOnQueryException    : TOnQueryException;
 Protected
  Procedure setConnection(AValue : TComponent); Virtual;
  Function  isConnected          : Boolean;     Virtual;
  Function  connInTransaction    : Boolean;     Virtual;
  Procedure connStartTransaction; Virtual;
  Procedure connRollback;         Virtual;
  Procedure connCommit;           Virtual;
  Function isMinimumVersion(major,
                            minor,
                            sub    : Integer) : Boolean; Overload;
  Function isMinimumVersion(major,
                            minor  : Integer) : Boolean; Overload;
 Public
  Function  getConectionType : TRESTDWDatabaseType; Virtual;
  Function  getDatabaseInfo  : TRESTDWDatabaseInfo; Virtual;
  Function  getQuery         : TRESTDWQuery;        Virtual;
  Function  getTable         : TRESTDWTable;        Virtual;
  Function  getStoreProc     : TRESTDWStoreProc;    Virtual;
  Procedure Connect;                                Virtual;
  Procedure Disconect;                              Virtual;
  Function ConnectionSet    : Boolean;              Virtual;
  Function GetGenID          (Query                 : TRESTDWQuery;
                              GenName               : String;
                              valor                 : Integer = 1) : Integer;Overload;Virtual;
  Function GetGenID          (GenName               : String;
                              valor                 : Integer = 1) : Integer;Overload;Virtual;
  Function ApplyUpdates      (MassiveStream         : TStream;
                              SQL                   : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdates      (Massive,
                              SQL                   : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdatesTB    (MassiveStream         : TStream;
                              SQL                   : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdatesTB    (Massive               : String;
                              Params                : TRESTDWParams;
                              Var Error             : Boolean;
                              Var MessageError      : String;
                              Var RowsAffected      : Integer)   : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCache  (MassiveStream         : TStream;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCache  (MassiveCache          : String;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCacheTB(MassiveStream         : TStream;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ApplyUpdates_MassiveCacheTB(MassiveCache          : String;
                                       Var Error             : Boolean;
                                       Var MessageError      : String) : TJSONValue;Overload;Virtual;
  Function ExecuteCommand     (SQL                   : String;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               Execute               : Boolean = False;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String;Overload;Virtual;
  Function ExecuteCommand     (SQL                   : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               Execute               : Boolean = False;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String;Overload;Virtual;
  Function ExecuteCommandTB   (Tablename             : String;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String; Overload;Virtual;
  Function ExecuteCommandTB   (Tablename             : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               Var RowsAffected      : Integer;
                               BinaryEvent           : Boolean = False;
                               MetaData              : Boolean = False;
                               BinaryCompatibleMode  : Boolean = False) : String; Overload;Virtual;
  Procedure ExecuteProcedure  (ProcName              : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure ExecuteProcedurePure(ProcName            : String;
                                 Var Error           : Boolean;
                                 Var MessageError    : String); Virtual;
  Procedure GetTableNames     (Var TableNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetFieldNames     (TableName             : String;
                               Var FieldNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetKeyFieldNames  (TableName             : String;
                               Var FieldNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetProcNames      (Var ProcNames         : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Procedure GetProcParams     (ProcName              : String;
                               Var ParamNames        : TStringList;
                               Var Error             : Boolean;
                               Var MessageError      : String); Virtual;
  Function InsertMySQLReturnID(SQL                   : String;
                               Var Error             : Boolean;
                               Var MessageError      : String)          : Integer;    Overload;Virtual;
  Function InsertMySQLReturnID(SQL                   : String;
                               Params                : TRESTDWParams;
                               Var Error             : Boolean;
                               Var MessageError      : String)          : Integer;    Overload;Virtual;
  Function OpenDatasets       (DatasetsLine          : String;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream)   : TJSONValue; Overload;Virtual;
  Function OpenDatasets       (DatapackStream        : TStream;
                               Var Error             : Boolean;
                               Var MessageError      : String;
                               Var BinaryBlob        : TMemoryStream;
                               aBinaryEvent          : Boolean = False;
                               aBinaryCompatibleMode : Boolean = False) : TStream; Overload;Virtual;
  Class Procedure CreateConnection(Const AConnectionDefs  : TConnectionDefs;
                                   Var AConnection        : TComponent);     Virtual;
  Procedure PrepareConnection     (Var AConnectionDefs    : TConnectionDefs);Virtual;
  Function  ProcessMassiveSQLCache(MassiveSQLCache        : String;
                                   Var Error              : Boolean;
                                   Var MessageError       : String)     : TJSONValue; Virtual;
  Procedure BuildDatasetLine      (Var Query              : TRESTDWDataset;
                                   Massivedataset         : TMassivedatasetBuffer;
                                   MassiveCache           : Boolean = False);
 Published
  Property Connection          : TComponent           Read FConnection            Write setConnection;
  Property StrsTrim            : Boolean              Read vStrsTrim              Write vStrsTrim;
  Property StrsEmpty2Null      : Boolean              Read vStrsEmpty2Null        Write vStrsEmpty2Null;
  Property StrsTrim2Len        : Boolean              Read vStrsTrim2Len          Write vStrsTrim2Len;
  Property Compression         : Boolean              Read vCompression           Write vCompression;
  Property EncodeStringsJSON   : Boolean              Read vEncodeStrings         Write vEncodeStrings;
  Property Encoding            : TEncodeSelect        Read vEncoding              Write vEncoding;
  Property ParamCreate         : Boolean              Read vParamCreate           Write vParamCreate;
  {$IFDEF FPC}
  Property DatabaseCharSet     : TDatabaseCharSet     Read vDatabaseCharSet       Write vDatabaseCharSet;
  {$ENDIF}
  Property CommitRecords       : Integer              Read vCommitRecords         Write vCommitRecords;
  Property OnPrepareConnection : TOnPrepareConnection Read vOnPrepareConnection   Write vOnPrepareConnection;
  Property OnTableBeforeOpen   : TOnTableBeforeOpen   Read vOnTableBeforeOpen     Write vOnTableBeforeOpen;
  Property OnQueryBeforeOpen   : TOnQueryBeforeOpen   Read vOnQueryBeforeOpen     Write vOnQueryBeforeOpen;
  Property OnQueryException    : TOnQueryException    Read vOnQueryException      Write vOnQueryException;
 End;

Implementation

Uses
 uRESTDWBasicDB;

{ TRESTDWStoreProc }

Function TRESTDWStoreProc.getStoredProcName : String;
Begin
 Try
  Result := GetStrProp(Self.Owner, 'StoredProcName');
 Except
  Result := '';
 End;
End;

Procedure TRESTDWStoreProc.setStoredProcName(AValue : String);
Begin
 Try
  SetStrProp(Self.Owner, 'Filter', AValue);
 Except
 End;
End;

Procedure TRESTDWStoreProc.ExecProc;
Begin

End;

{ TRESTDWDataset }

Function TRESTDWDataset.getFields : TFields;
Begin
 Result := TDataSet(Self.Owner).Fields;
End;

Function TRESTDWDataset.getParams : TParams;
Begin
 Try
  Result := TParams(GetObjectProp(Self.Owner, 'Params'));
 Except
  Result := Nil;
 End;
End;

Procedure TRESTDWDataset.createSequencedField(seqname,
                                              field    : String);
Begin

End;

Procedure TRESTDWDataset.Close;
Begin
 TDataSet(Self.Owner).Close;
End;

Procedure TRESTDWDataset.Open;
Begin
 TDataSet(Self.Owner).Open;
End;

Procedure TRESTDWDataset.Insert;
Begin
 TDataSet(Self.Owner).Insert;
End;

Procedure TRESTDWDataset.Edit;
Begin
 TDataSet(Self.Owner).Edit;
End;

Procedure TRESTDWDataset.Post;
Begin
 TDataSet(Self.Owner).Post;
End;

Procedure TRESTDWDataset.Delete;
Begin
 TDataSet(Self.Owner).Delete;
End;

Procedure TRESTDWDataset.Next;
Begin
 TDataSet(Self.Owner).Next;
End;

Procedure TRESTDWDataset.Prepare;
Begin

End;

Procedure TRESTDWDataset.ExecSQL;
Begin

End;

Procedure TRESTDWDataset.FetchAll;
Begin

End;

Procedure TRESTDWDataset.SaveToStream(stream: TStream);
Begin

End;

Function TRESTDWDataset.Eof: boolean;
Begin
 Result := TDataSet(Self.Owner).EOF;
End;

Function TRESTDWDataset.RecNo: int64;
Begin
 Result := TDataSet(Self.Owner).RecNo;
End;

Function TRESTDWDataset.RecordCount: int64;
Begin
 Result := -1;
End;

Function TRESTDWDataset.ParamCount: integer;
Begin
 Try
  Result := Params.Count;
 Except
  Result := -1;
 End;
End;

Function TRESTDWDataset.ParamByName(param: String): TParam;
Begin
 Try
  Result := Params.FindParam(param);
 Except
  Result := nil;
 End;
End;

Function TRESTDWDataset.FieldByName(field: String): TField;
Begin
 Result := TDataSet(Self.Owner).FieldByName(field);
End;

Function TRESTDWDataset.FindField(field: String): TField;
Begin
 Result := TDataSet(Self.Owner).FindField(field);
End;

Function TRESTDWDataset.RDWDataTypeFieldName(field : String) : Byte;
Var
 vDType : TFieldType;
Begin
 vDType := FieldByName(field).DataType;
 Result := FieldTypeToDWFieldType(vDType);
End;

Function TRESTDWDataset.RDWDataTypeParamName(param : String) : Byte;
Var
 vDType : TFieldType;
Begin
 Try
  vDType := ParamByName(param).DataType;
 Except
  vDType := ftUnknown;
 End;
 Result := FieldTypeToDWFieldType(vDType);
End;

Function TRESTDWDataset.GetParamIndex(param : String): integer;
Var
 prm : TParam;
Begin
 Try
  prm := Params.FindParam(param);
  Result := prm.Index;
 Except
  Result := -1;
 End;
End;

{ TRESTDWTable }

Function TRESTDWTable.getFilter : String;
Begin
 Try
  Result := GetStrProp(Self.Owner,'Filter');
 Except
  Result := '';
 End;
End;

Function TRESTDWTable.getFiltered: boolean;
Begin
 Try
  Result := Boolean(GetPropValue(Self.Owner,'Filtered'));
 Except
  Result := False;
 End;
End;

Function TRESTDWTable.getTableName : String;
Begin
 Try
  Result := GetStrProp(Self.Owner,'TableName');
 Except
  Result := '';
 End;
End;

Procedure TRESTDWTable.setFilter(AValue : String);
Begin
 Try
  SetStrProp(Self.Owner,'Filter',AValue);
 Except

 End;
End;

Procedure TRESTDWTable.setFiltered(AValue: boolean);
Begin
 Try
  SetPropValue(Self.Owner,'Filtered',AValue);
 Except

 End;
End;

Procedure TRESTDWTable.setTableName(AValue : String);
Begin

End;

{ TRESTDWQuery }

Function TRESTDWQuery.getSQL: TStrings;
Begin
 Try
  Result := TStrings(GetObjectProp(Self.Owner,'SQL'));
 Except
  Result := nil;
 End;
End;

Function TRESTDWQuery.RowsAffected : Int64;
Begin
 Result := -1;
End;

Function TRESTDWQuery.GetInsertID : Int64;
Var
 drv : TRESTDWDriverBase;
Begin
 Result := -1;
 drv    := TRESTDWDriverBase(Self.Owner);
 Try
  If drv.getConectionType = dbtMySQL Then
   Begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT LAST_INSERT_ID() ID');
    Open;
    Result := Fields[0].AsLargeInt;
   End;
 Except
  Result := -1;
 End;
End;

{ TRESTDWDriverBase }

Function TRESTDWDriverBase.getConectionType : TRESTDWDatabaseType;
Begin
 Result := dbtUndefined;
End;

Function TRESTDWDriverBase.getDatabaseInfo  : TRESTDWDatabaseInfo;
Var
 connType : TRESTDWDatabaseType;
 qry      : TRESTDWQuery;
 iAux1    : Integer;
 sAux1,
 sVersion : String;
 lst      : TStringList;
Begin
 Result.rdwDatabaseName         := '';
 Result.rdwDatabaseMajorVersion := 0;
 Result.rdwDatabaseMinorVersion := 0;
 Result.rdwDatabaseSubVersion   := 0;
 // rdwDatabaseName foi definido para possiveis subversoes
 // ex: no MySQL temos o MariaDB
 // ex: no Firebird temos a versao HQBird
 sVersion := '';
 connType := getConectionType;
 lst := TStringList.Create;
 qry := getQuery;
 Try
  Case connType Of
   dbtFirebird    : Begin
                     Result.rdwDatabaseName         := 'firebird';
                     Result.rdwDatabaseMajorVersion := 1;
                     Result.rdwDatabaseMinorVersion := 5;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select rdb$get_context(''SYSTEM'',''ENGINE_VERSION'')');
                      qry.SQL.Add('from rdb$database');
                      qry.Open;
                      sVersion := qry.Fields[0].AsString;
                     Except
                     End;
                    End;
   dbtInterbase   : Begin
                     Result.rdwDatabaseName         := 'interbase';
                     Result.rdwDatabaseMajorVersion := 6;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select rdb$get_context(''SYSTEM'',''ENGINE_VERSION'')');
                      qry.SQL.Add('from rdb$database');
                      qry.Open;
                      sVersion := qry.Fields[0].AsString;
                     Except

                     End;
                    End;
    dbtMySQL      : Begin
                     Result.rdwDatabaseName         := 'mysql';
                     Result.rdwDatabaseMajorVersion := 3;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('SHOW VARIABLES LIKE ''%version%''');
                      qry.Open;
                      While Not qry.Eof Do
                       Begin
                        sAux1 := qry.FieldByName('variable_name').AsString;
                        If SameText(sAux1, 'innodb_version') Then
                         sVersion := qry.FieldByName('value').AsString
                        Else If SameText(sAux1,'version')    Then
                         Begin
                          sAux1 := qry.FieldByName('value').AsString;
                          If Pos('mariadb',LowerCase(sAux1)) > 0 Then
                           Result.rdwDatabaseName := 'mariadb';
                          iAux1 := 1;
                          While iAux1 <= Length(sAux1) Do
                           Begin
                            If Not (sAux1[iAux1] In ['0'..'9', '.']) Then
                             Delete(sAux1,iAux1,1)
                            Else
                             iAux1 := iAux1 + 1;
                           End;
                          sVersion := sAux1;
                         End
                        Else If SameText(sAux1,'version_comment') Then
                         Begin
                          sAux1 := qry.FieldByName('value').AsString;
                          If Pos('mariadb',LowerCase(sAux1)) > 0 Then
                           Result.rdwDatabaseName := 'mariadb';
                         End;
                        qry.Next;
                       End;
                     Except

                     End;
                    End;
    dbtPostgreSQL : Begin
                     Result.rdwDatabaseName := 'postgresql';
                     Result.rdwDatabaseMajorVersion := 7;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('SELECT version()');
                      qry.Open;
                      sAux1 := qry.Fields[0].AsString;
                      iAux1 := Pos('.',sAux1);
                      While (iAux1 > 0)           And
                            (sAux1[iAux1] <> ' ') Do
                       iAux1 := iAux1 - 1;
                      If iAux1 > 0 then
                       Delete(sAux1,1,iAux1);
                      sAux1 := Trim(sAux1);
                      iAux1 := 1;
                      While (iAux1        <= Length(sAux1))  And
                            (sAux1[iAux1] In ['0'..'9','.']) Do
                       Begin
                        sVersion := sVersion + sAux1[iAux1];
                        iAux1 := iAux1 + 1;
                       End;
                     Except

                     End;
                     If sVersion = '' Then
                      Begin
                       Try
                        qry.SQL.Add('SHOW server_version');
                        qry.Open;
                        sVersion := qry.Fields[0].AsString;
                       Except
                       End;
                      End;
                    End;
    dbtSQLLite    : Begin
                     Result.rdwDatabaseName         := 'sqlite';
                     Result.rdwDatabaseMajorVersion := 1;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select sqlite_version()');
                      qry.Open;
                      sVersion := qry.Fields[0].AsString;
                     Except

                     End;
                    End;
    dbtOracle     : Begin
                     Result.rdwDatabaseName         := 'oracle';
                     Result.rdwDatabaseMajorVersion := 0;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('SELECT * FROM v$version');
                      qry.SQL.Add('WHERE banner LIKE ''Oracle%''');
                      qry.Open;
                      sAux1 := qry.Fields[0].AsString;
                      Repeat
                       iAux1 := Pos(' ',sAux1);
                       If iAux1 > 0 Then
                        Begin
                         If Pos('.',Copy(sAux1,1,iAux1-1)) > 0 Then
                          Begin
                           sVersion := Copy(sAux1,1,iAux1-1);
                           Break;
                          End;
                         Delete(sVersion,1,iAux1);
                        End;
                      Until iAux1 = 0;
                     Except
                     End;
                    End;
    dbtMsSQL      : Begin
                     Result.rdwDatabaseName         := 'mssql';
                     Result.rdwDatabaseMajorVersion := 0;
                     Result.rdwDatabaseMinorVersion := 0;
                     Result.rdwDatabaseSubVersion   := 0;
                     Try
                      qry.SQL.Add('select @@VERSION');
                      qry.Open;
                      sAux1 := qry.Fields[0].AsString;
                      Repeat
                       iAux1 := Pos(' ',sAux1);
                       If iAux1 > 0 Then
                        Begin
                         If Pos('.',Copy(sAux1,1,iAux1-1)) > 0 Then
                          Begin
                           sVersion := Copy(sAux1,1,iAux1-1);
                           Break;
                          End;
                         Delete(sVersion,1,iAux1);
                        End;
                      Until iAux1 = 0;
                     Except
                     End;
                    End;
  End;
  If sVersion <> '' Then
   Begin
    Repeat
     iAux1 := Pos('.',sVersion);
     If iAux1 > 0 Then
      Begin
       lst.Add(Copy(sVersion,1,iAux1-1));
       Delete(sVersion,1,iAux1);
      End;
    Until iAux1 = 0;
    If lst.Count > 0 Then
     Result.rdwDatabaseMajorVersion := StrToInt(lst.Strings[0]);
    If lst.Count > 1 Then
     Result.rdwDatabaseMinorVersion := StrToInt(lst.Strings[1]);
    If lst.Count > 2 Then
     Result.rdwDatabaseSubVersion := StrToInt(lst.Strings[2]);
   End;
 Finally
  FreeAndNil(qry);
  FreeAndNil(lst);
 End;
End;

Function TRESTDWDriverBase.getQuery: TRESTDWQuery;
Begin
 Result := Nil;
End;

Function TRESTDWDriverBase.getTable: TRESTDWTable;
Begin
 Result := Nil;
End;

Function TRESTDWDriverBase.getStoreProc : TRESTDWStoreProc;
Begin
 Result := Nil;
End;

Function TRESTDWDriverBase.isConnected: boolean;
Begin
 Result := False;
End;

Function TRESTDWDriverBase.connInTransaction: boolean;
Begin
 Result := False;
End;

Procedure TRESTDWDriverBase.connStartTransaction;
Begin

End;

Procedure TRESTDWDriverBase.connRollback;
Begin

End;

Procedure TRESTDWDriverBase.connCommit;
Begin

End;

Function TRESTDWDriverBase.isMinimumVersion(major, minor, sub: integer): boolean;
Var
 info : TRESTDWDatabaseInfo;
Begin
 info := getDatabaseInfo;
 Result := (info.rdwDatabaseMajorVersion >= major) And
           (info.rdwDatabaseMinorVersion >= minor) And
           (info.rdwDatabaseMinorVersion >= sub);
End;

Function TRESTDWDriverBase.isMinimumVersion(major, minor: integer): boolean;
Begin
 Result := isMinimumVersion(major, minor, 0);
End;

Procedure TRESTDWDriverBase.setConnection(AValue: TComponent);
Begin
 If FConnection = AValue Then
  Exit;
 Disconect;
 FConnection := AValue;
End;

Procedure TRESTDWDriverBase.Connect;
Begin

End;

Procedure TRESTDWDriverBase.Disconect;
Begin

End;

Function TRESTDWDriverBase.ConnectionSet: Boolean;
Begin
 Result := Assigned(FConnection);
End;

Function TRESTDWDriverBase.GetGenID(Query   : TRESTDWQuery;
                                    GenName : String;
                                    valor   : Integer) : Integer;
Var
 connType : TRESTDWDatabaseType;
Begin
 Result := -1;
 connType := getConectionType;
 With Query Do
  Begin
   Close;
   SQL.Clear;
   Case connType Of
    dbtFirebird   : Begin
                     SQL.Add('select gen_id('+QuotedStr(GenName)+','+IntToStr(valor)+')');
                     SQL.Add('from rdb$database');
                     Open;
                     Result := Query.Fields[0].AsInteger;
                    End;
    dbtMySQL      : Begin
                     SQL.Add('show table status where name = '+QuotedStr(GenName));
                     Open;
                     Result := valor + Query.FieldByName('auto_increment').AsInteger;
                     If valor <> 0 Then
                      Begin
                       SQL.Clear;
                       SQL.Add('alter table '+GenName+' auto_increment='+IntToStr(Result));
                       ExecSQL;
                      End;
                    End;
    dbtSQLLite    : Begin
                     SQL.Add('create table if not exist sqlite_sequence(name,seq)');
                     ExecSQL;
                     SQL.Clear;
                     SQL.Add('select seq from sqlite_sequence');
                     SQL.Add('where name = '+QuotedStr(GenName));
                     Open;
                     Result := valor + Query.Fields[0].AsInteger;
                     If valor <> 0 Then
                      Begin
                       SQL.Clear;
                       SQL.Add('insert or replace into sqlite_sequence(name,seq)');
                       SQL.Add('values('+QuotedStr(GenName)+','+IntToStr(Result)+')');
                       ExecSQL;
                      End;
                    End;
    dbtPostgreSQL : Begin
                     SQL.Add('select currval('+QuotedStr(GenName)+')');
                     Open;
                     Try
                      If valor <> 0 Then
                       Begin
                        SQL.Clear;
                        SQL.Add('select nextval('+QuotedStr(GenName)+')');
                        Open;
                       End;
                     Except
                      SQL.Clear;
                      SQL.Add('select nextval('+QuotedStr(GenName)+')');
                      Open;
                     End;
                     Result := Query.Fields[0].AsInteger;
                    End;
   End;
  End;
End;

Function TRESTDWDriverBase.GetGenID(GenName : String;
                                    valor   : Integer) : Integer;
Var
 qry : TRESTDWQuery;
Begin
 qry := getQuery;
 Try
  Result := GetGenID(qry,GenName,valor);
 Finally
  FreeAndNil(qry);
 End;
End;

Function TRESTDWDriverBase.ApplyUpdates(MassiveStream    : TStream;
                                        SQL              : String;
                                        Params           : TRESTDWParams;
                                        var Error        : Boolean;
                                        var MessageError : String;
                                        var RowsAffected : integer) : TJSONValue;
Var
 vTempQuery     : TRESTDWQuery;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
 vMassiveLine   : Boolean;
 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vTempValue,
  vStringFloat,
  vReflectionLine,
  vReflectionLines : String;
  vFieldType       : TFieldType;
  MassiveField     : TMassiveField;
  vFieldChanged    : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  vFieldChanged     := False;
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]']);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                          (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                        vFieldChanged     := True
                                       Else
                                        Begin
                                         If (Not MassiveField.IsNull) Then
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value)
                                         Else
                                          vFieldChanged    := Not(Query.Fields[I].IsNull);
                                        End;
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        If Assigned(vStringStream) Then
                                         FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (Not MassiveField.IsNull) Then
                                       Begin
                                        If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                   IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                     IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                                       End;
                                     End;
           {$IFNDEF FPC}
             {$IF CompilerVersion >= 21}
                ftSingle,
                ftExtended,
             {$IFEND}
           {$ENDIF}
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd : Begin
                                       vStringFloat  := Query.Fields[I].AsString;
                                       If (Trim(vStringFloat) <> '') Then
                                        vStringFloat := BuildStringFloat(vStringFloat)
                                       Else
                                        vStringFloat := cNullvalue;
                                       If (MassiveField.Modified) Then
                                        vStringFloat := BuildStringFloat(MassiveField.Value);
                                       If vReflectionLine = '' Then
                                        vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                       Else
                                        vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                      End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               vTempValue := Query.Fields[I].AsString;
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                             EncodeStream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 EncodeStream(vStringStream)]); // StreamToHex(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                If Assigned(vStringStream) Then
                 FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : TStream; Var Query : TRESTDWQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TRESTDWQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X                 : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
    vTempValue        : String;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 21}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 21}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat, ftCurrency, ftBCD,ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                            ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                            ftString,    ftWideString,
                            ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 21}
                                     , ftWideMemo
                                    {$IFEND}
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
          Else
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
         End;
       End
      Else
       Begin
        If Query.Params[I].DataType in [ftUnknown] Then
         Begin
          If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
           Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
          Else
           Query.Params[I].DataType := ftString;
         End;
        If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd {$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle{$IFEND}{$ENDIF} ] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
            Try
             MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
             If vStringStream <> Nil Then
              Begin
               vStringStream.Position := 0;
               Query.Params[I].LoadFromStream(vStringStream, ftBlob);
              End
             Else
              Query.Params[I].Clear;
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Query.Params[I].Clear;
         End
        Else
         Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' Where %s'])
                Else
                 vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                        (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                        (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                       (MassiveDataset.Fields.Items[I].ReadOnly))          And
                       (Not(MassiveDataset.ReflectChanges)))               Or
                      ((MassiveDataset.ReflectChanges) And
                       (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                    Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                  If MassiveDataset.ReflectChanges Then
                   Begin
                    If MassiveDataset.Fields.Items[I].KeyField Then
                     If vParamsSQL = '' Then
                      vParamsSQL := MassiveDataset.Fields.Items[I].FieldName + ' is null '
                     Else
                      vParamsSQL  := vParamsSQL + ' and ' + MassiveDataset.Fields.Items[I].FieldName + ' is null ';
                   End;
                 End;
                If MassiveDataset.ReflectChanges Then
                 Begin
                  If (vParamsSQL = '') And
                     (MassiveDataset.AtualRec.MassiveMode <> mmInsert) Then
                   Begin
                    Raise Exception.Create(PChar(Format('Invalid insert, table %s no have keys defined to use in Reflect Changes...', [MassiveDataset.TableName])));
                    Exit;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vFields  := '';
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' %s'])
                Else
                 vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                If Not MassiveDataset.ReflectChanges Then
                 Begin
                  For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If vFields = '' Then
                       vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End
                Else
                 Begin
                  For I := 0 To MassiveDataset.Fields.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                        Continue;
                      If vFields = '' Then
                       vFields     := MassiveDataset.Fields.Items[I].FieldName//MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName //MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
    mmExec   : vLineSQL := MassiveDataset.Dataexec.Text;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   If (MassiveDataset.ReflectChanges) And
      (Not(MassiveDataset.MassiveMode in [mmDelete, mmExec])) Then
    Begin
     If MassiveDataset.MassiveMode = mmUpdate Then
      SetUpdateBuffer(True);
     Query.Open;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
          Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query.Owner));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query.Owner));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     For I := 0 To Query.ParamCount -1 Do
      Begin
       If MassiveDataset.MassiveMode = mmExec Then
        Begin
         If MassiveDataset.Params.ItemsString[Query.Params[I].Name] <> Nil Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue);
           If MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd {$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull))  Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                   Begin
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(TStream(vStringStream));
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End;
        End
       Else
        Begin
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
           If Not MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End
               Else  If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd {$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull))     Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                   Begin
                    MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  If Assigned(vStringStream) Then
                   FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End
         Else
          Begin
           If I = 0 Then
            SetUpdateBuffer;
          End;
        End;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Result         := False;
  Try
   MassiveDataset.LoadFromStream(Massive);
   MassiveDataset.First;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
      TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
    End;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If Not connInTransaction Then
      Begin
         connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Query.SQL.Clear;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      If (Not (MassiveDataset.ReflectChanges))     Or
         ((MassiveDataset.ReflectChanges)          And
          (MassiveDataset.MassiveMode in [mmExec, mmDelete])) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
          connRollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If connInTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
            connCommit;
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
           End;
         End;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If connInTransaction Then
            connRollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If connInTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
         connCommit;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
       End;
     End;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If connInTransaction Then
        connRollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
   FreeAndNil(MassiveDataset);
   Query.SQL.Clear;
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Try
  Result     := Nil;
  Error      := False;
  vStringStream := Nil;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If Not isConnected Then
   Connect;
  vTempQuery.SQL.Clear;
  vResultReflection := '';
  If LoadMassive(MassiveStream, vTempQuery) Then
   Begin
    If (SQL <> '') And (vResultReflection = '') Then
     Begin
      Try
       vTempQuery.SQL.Clear;
       vTempQuery.SQL.Add(SQL);
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.ParamCount > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A          := vTempQuery.GetParamIndex(vParamName);
             If A > -1 Then
              Begin
               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}]    Then
                Begin
                 If vTempQuery.Params[A].DataType In [ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}] Then
                  vTempQuery.Params[A].Value := Params[I].Value
                 Else
                  Begin
                   If vTempQuery.Params[A].Size > 0 Then
                    vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
                   Else
                    vTempQuery.Params[A].Value := Params[I].Value;
                  End;
                End
               Else
                Begin
                 If vTempQuery.Params[A].DataType in [ftUnknown] Then
                  Begin
                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
                    vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
                   Else
                    vTempQuery.Params[A].DataType := ftString;
                  End;
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                      vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType = ftDate Then
                      vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
                     Else If vTempQuery.Params[A].DataType = ftTime Then
                      vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
                     Else
                      vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   If Not Assigned(vStringStream) Then
                    vStringStream  := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(TStream(vStringStream));
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                   Finally
                    If Assigned(vStringStream) Then
                     FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Params[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Error         := False;
       If not vStateResource then
        Disconect;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          Result.SetValue(GetPairJSONStr('NOK', MessageError));
          If connInTransaction Then
           connRollback;
         Except
         End;
         Disconect;
        End;
      End;
     End
    Else If (vResultReflection <> '') Then
     Begin
      If Result = Nil Then
       Result         := TJSONValue.Create;
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
     End;
   End;
 Finally
  FreeAndNil(BufferBase);
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
 End;
End;

Function TRESTDWDriverBase.ApplyUpdates(Massive,
                                        SQL              : String;
                                        Params           : TRESTDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var RowsAffected : Integer): TJSONValue;
Var
 vTempQuery     : TRESTDWQuery;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vStateResource,
 vMassiveLine   : Boolean;

 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vTempValue,
  vStringFloat,
  vReflectionLine,
  vReflectionLines : String;
  vFieldType       : TFieldType;
  MassiveField     : TMassiveField;
  vFieldChanged    : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  vFieldChanged     := False;
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]']);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                          (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                        vFieldChanged     := True
                                       Else
                                        Begin
                                         If (Not MassiveField.IsNull) Then
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value)
                                         Else
                                          vFieldChanged    := Not(Query.Fields[I].IsNull);
                                        End;
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        If Assigned(vStringStream) Then
                                         FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (Not MassiveField.IsNull) Then
                                       Begin
                                        If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                   IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                     IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                                       End;
                                     End;
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},
                                 ftSingle,
                                 ftExtended{$IFEND}{$ENDIF} : Begin
                                       vStringFloat  := Query.Fields[I].AsString;
                                       If (Trim(vStringFloat) <> '') Then
                                        vStringFloat := BuildStringFloat(vStringFloat)
                                       Else
                                        vStringFloat := cNullvalue;
                                       If (MassiveField.Modified) Then
                                        vStringFloat := BuildStringFloat(MassiveField.Value);
                                       If vReflectionLine = '' Then
                                        vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                       Else
                                        vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                      End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               vTempValue := Query.Fields[I].AsString;
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                             EncodeStream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 EncodeStream(vStringStream)]); // StreamToHex(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                If Assigned(vStringStream) Then
                 FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TRESTDWQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TRESTDWQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X                 : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
    vTempValue        : String;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 21}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 21}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD,ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                            ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                            ftString,    ftWideString,
                            ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 21}
                                     , ftWideMemo
                                    {$IFEND}
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
          Else
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
         End;
       End
      Else
       Begin
        If Query.Params[I].DataType in [ftUnknown] Then
         Begin
          If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
           Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
          Else
           Query.Params[I].DataType := ftString;
         End;
        If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
            Try
             MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
             If vStringStream <> Nil Then
              Begin
               vStringStream.Position := 0;
               Query.Params[I].LoadFromStream(vStringStream, ftBlob);
              End
             Else
              Query.Params[I].Clear;
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Query.Params[I].Clear;
         End
        Else
         Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' Where %s'])
                Else
                 vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                        (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                        (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                       (MassiveDataset.Fields.Items[I].ReadOnly))          And
                       (Not(MassiveDataset.ReflectChanges)))               Or
                      ((MassiveDataset.ReflectChanges) And
                       (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                    Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                  If MassiveDataset.ReflectChanges Then
                   Begin
                    If MassiveDataset.Fields.Items[I].KeyField Then
                     If vParamsSQL = '' Then
                      vParamsSQL := MassiveDataset.Fields.Items[I].FieldName + ' is null '
                     Else
                      vParamsSQL  := vParamsSQL + ' and ' + MassiveDataset.Fields.Items[I].FieldName + ' is null ';
                   End;
                 End;
                If MassiveDataset.ReflectChanges Then
                 Begin
                  If (vParamsSQL = '') And
                     (MassiveDataset.AtualRec.MassiveMode <> mmInsert) Then
                   Begin
                    Raise Exception.Create(PChar(Format('Invalid insert, table %s no have keys defined to use in Reflect Changes...', [MassiveDataset.TableName])));
                    Exit;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vFields  := '';
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' %s'])
                Else
                 vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                If Not MassiveDataset.ReflectChanges Then
                 Begin
                  For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If vFields = '' Then
                       vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End
                Else
                 Begin
                  For I := 0 To MassiveDataset.Fields.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                        Continue;
                      If vFields = '' Then
                       vFields     := MassiveDataset.Fields.Items[I].FieldName//MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName //MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
    mmExec   : vLineSQL := MassiveDataset.Dataexec.Text;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   If (MassiveDataset.ReflectChanges) And
      (Not(MassiveDataset.MassiveMode in [mmDelete, mmExec])) Then
    Begin
     If MassiveDataset.MassiveMode = mmUpdate Then
      SetUpdateBuffer(True);
     Query.Open;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query.Owner));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query.Owner));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     For I := 0 To Query.ParamCount -1 Do
      Begin
       If MassiveDataset.MassiveMode = mmExec Then
        Begin
         If MassiveDataset.Params.ItemsString[Query.Params[I].Name] <> Nil Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue);
           If MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull))  Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                   Begin
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(TStream(vStringStream));
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End;
        End
       Else
        Begin
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
           If Not MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End
               Else  If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull))     Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                   Begin
                    MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  If Assigned(vStringStream) Then
                   FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End
         Else
          Begin
           If I = 0 Then
            SetUpdateBuffer;
          End;
        End;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Result         := False;
  Try
   MassiveDataset.FromJSON(Massive);
   MassiveDataset.First;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
      TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
    End;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If Not connInTransaction Then
      Begin
       connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Query.SQL.Clear;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      If (Not (MassiveDataset.ReflectChanges))     Or
         ((MassiveDataset.ReflectChanges)          And
          (MassiveDataset.MassiveMode in [mmExec, mmDelete])) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
          connRollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If connInTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
           connCommit;
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
           End;
         End;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If connInTransaction Then
            connRollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If connInTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
       connCommit;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
       End;
     End;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If connInTransaction Then
        connRollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
   FreeAndNil(MassiveDataset);
   Query.SQL.Clear;
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Try
  Result     := Nil;
  Error      := False;
  vStringStream := Nil;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If Not vStateResource Then
   connCommit;
  vTempQuery.SQL.Clear;
  vResultReflection := '';
  If LoadMassive(Massive, vTempQuery) Then
   Begin
    If (SQL <> '') And (vResultReflection = '') Then
     Begin
      Try
       vTempQuery.SQL.Clear;
       vTempQuery.SQL.Add(SQL);
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.ParamCount > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A          := vTempQuery.GetParamIndex(vParamName);
             If A > -1 Then
              Begin
               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}]    Then
                Begin
                 If vTempQuery.Params[A].DataType In [ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}] Then
                  vTempQuery.Params[A].Value := Params[I].Value
                 Else
                  Begin
                   If vTempQuery.Params[A].Size > 0 Then
                    vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
                   Else
                    vTempQuery.Params[A].Value := Params[I].Value;
                  End;
                End
               Else
                Begin
                 If vTempQuery.Params[A].DataType in [ftUnknown] Then
                  Begin
                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
                    vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
                   Else
                    vTempQuery.Params[A].DataType := ftString;
                  End;
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                      vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType = ftDate Then
                      vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
                     Else If vTempQuery.Params[A].DataType = ftTime Then
                      vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
                     Else
                      vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   If Not Assigned(vStringStream) Then
                    vStringStream  := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(TStream(vStringStream));
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                   Finally
                    If Assigned(vStringStream) Then
                     FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Params[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Error          := False;
       If Not vStateResource Then
        Disconect;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          Result.SetValue(GetPairJSONStr('NOK', MessageError));
          If connInTransaction Then
            connRollback;
         Except
         End;
         Disconect;
        End;
      End;
     End
    Else If (vResultReflection <> '') Then
     Begin
      If Result = Nil Then
       Result         := TJSONValue.Create;
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RowsAffected;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
 End;
End;

Function TRESTDWDriverBase.ApplyUpdatesTB(MassiveStream    : TStream;
                                          SQL              : String;
                                          Params           : TRESTDWParams;
                                          Var Error        : Boolean;
                                          Var MessageError : String;
                                          Var RowsAffected : Integer): TJSONValue;
Var
 vTempQuery     : TRESTDWTable;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vMassiveLine   : Boolean;
 vValueKeys     : TRESTDWValueKeys;
 vDataSet       : TDataSet;
 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vTempValue,
  vStringFloat,
  vReflectionLine,
  vReflectionLines : String;
  vFieldType       : TFieldType;
  MassiveField     : TMassiveField;
  vFieldChanged    : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  {$IFDEF FPC}
  vFieldChanged     := False;
  {$ENDIF}
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]']);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (Not MassiveField.IsNull) Then
                                        Begin
                                         If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                            (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                          vFieldChanged     := True
                                         Else
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value);
                                        End
                                       Else
                                        vFieldChanged    := Not(Query.Fields[I].IsNull);
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (Not MassiveField.IsNull) Then
                                       Begin
                                        If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                   IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                     IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                                       End;
                                     End;
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22},
                                 ftSingle,
                                 ftExtended
                                 {$IFEND}
                                 {$ENDIF} : Begin
                                             vStringFloat  := Query.Fields[I].AsString;
                                             If (Trim(vStringFloat) <> '') Then
                                              vStringFloat := BuildStringFloat(vStringFloat)
                                             Else
                                              vStringFloat := cNullvalue;
                                             If (MassiveField.Modified) Then
                                              vStringFloat := BuildStringFloat(MassiveField.Value);
                                             If vReflectionLine = '' Then
                                              vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                             Else
                                              vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                            End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               vTempValue := Query.Fields[I].AsString;
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                             EncodeStream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 EncodeStream(vStringStream)]); // StreamToHex(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(MassiveStream : TStream;
                      Var Query     : TRESTDWTable) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;

  Procedure PrepareData(Var Query      : TRESTDWTable;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLocate    : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 22}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                               {$ELSE}
                                                                               , ftWideMemo
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Begin
             Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
             Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size);
            end
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                         ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                         ftString,    ftWideString,
                         ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 22}
                                     , ftWideMemo
                                    {$IFEND}
                                    {$ELSE}
                                    , ftWideMemo
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
         Begin
          If Query.Fields[I].Size > 0 Then
           Begin
            Query.Fields[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value, 1, Query.Fields[I].Size);
           End
          Else
           Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
         End;
       End
      Else
       Begin
        If Query.Fields[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Begin
            If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
             Query.Fields[I]{$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value)
            Else
             Query.Fields[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
           End
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value))
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value
          Else
           Query.Fields[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
           If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).SaveToStream(vStringStream);
              If vStringStream <> Nil Then
               Begin
                vStringStream.Position := 0;
                TBlobField(Query.Fields[I]).LoadFromStream(vStringStream);
               End
              Else
               Query.Fields[I].Clear;
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.Fields[I].Clear;
         End
        Else
         Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.Filter    := '';
   Query.Filtered  := False;
   Query.TableName := MassiveDataset.TableName;
   vLocate         := '';
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vLocate := '1=0';
               End;
    mmUpdate,
    mmDelete : Begin
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If MassiveDataset.MassiveMode = mmUpdate Then
                    Begin
                     If I = 0 Then
                      vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value])
                     Else
                      vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value]);
                    End
                   Else
                    Begin
                     If I = 0 Then
                      vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I +1].Value])
                     Else
                      vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I +1].Value]);
                    End;
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
               End;
   End;
   Query.Filter    := vLocate;
   Query.Filtered  := True;
   //Params
   If (MassiveDataset.MassiveMode <> mmDelete) Then
    Begin
     If Assigned(Self.OnTableBeforeOpen) Then
      Self.OnTableBeforeOpen(vDataSet, Params, MassiveDataset.TableName);
     Query.Open;
     Query.FetchAll;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
          End;
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Begin
                             Query.Post;
//                             Query.RefreshCurrentRow(true);
//                             Query.Resync([rmExact, rmCenter]);
                            End;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     Query.Open;
     Query.Delete;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Result         := False;
  Try
   MassiveStream.Position := 0;
   MassiveDataset.LoadFromStream(MassiveStream);
   MassiveDataset.First;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
      TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
    End;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If not connInTransaction Then Begin
       connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Query.Close;
     Query.Filter := '';
     Query.Filtered := False;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      If (Not (MassiveDataset.ReflectChanges))     Or
         ((MassiveDataset.ReflectChanges)          And
          (MassiveDataset.MassiveMode in [mmExec])) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
          connRollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If connInTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
           connCommit;
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
           End;
         End;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If connInTransaction Then
            connRollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If connInTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
         connCommit;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
       End;
     End;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If connInTransaction Then
        connRollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
   FreeAndNil(MassiveDataset);
   Query.Filter := '';
   Query.Filtered := False;
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Try
  Result         := Nil;
  Error          := False;
  vStringStream  := Nil;
  vTempQuery     := getTable;
  vDataSet       := TDataSet(vTempQuery.Owner);
  vValueKeys     := TRESTDWValueKeys.Create;
  If Not isConnected Then
   Connect;
  vTempQuery.Filter       := '';
  vResultReflection := '';
  If LoadMassive(MassiveStream, vTempQuery) Then
   Begin
    If (vResultReflection = '') Then
     Begin
      Try
       vTempQuery.Filter   := '';
       vTempQuery.Filtered := False;
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.Fields.Count > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A := vTempQuery.GetParamIndex(vParamName);
             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
              Begin
               If vTempQuery.Fields[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                              {$IF CompilerVersion > 22}
                                                               , ftWideMemo
                                                              {$IFEND}
                                                              {$ELSE}
                                                              , ftWideMemo
                                                            {$ENDIF}]    Then
                Begin
                 If vTempQuery.Fields[A].Size > 0 Then
                  Begin
//                   vTempQuery.Fields[A].DataType := ftString;
                   vTempQuery.Fields[A].Value := Copy(Params[I].Value, 1, vTempQuery.Fields[A].Size);
                  End
                 Else
                  vTempQuery.Fields[A].Value := Params[I].Value;
                End
               Else
                Begin
//                 If vTempQuery.Fields[A].DataType in [ftUnknown] Then
//                  Begin
//                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
//                    vTempQuery.Fields[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
//                   Else
//                    vTempQuery.Fields[A].DataType := ftString;
//                  End;
                 If vTempQuery.Fields[A].DataType in [ftInteger, ftSmallInt, ftWord{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}, ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Fields[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                      Begin
                       {$IFNDEF FPC}
                        {$IF CompilerVersion > 22}vTempQuery.Fields[A].AsLargeInt := StrToInt64(Params[I].Value);
                        {$ELSE}vTempQuery.Fields[A].AsInteger                     := StrToInt64(Params[I].Value);
                        {$IFEND}
                       {$ELSE}
                        vTempQuery.Fields[A].AsLargeInt := StrToInt64(Params[I].Value);
                       {$ENDIF}
                      End
                     Else
                      vTempQuery.Fields[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Fields[A].Clear;
                  End
                 Else If vTempQuery.Fields[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Fields[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Fields[A].Clear;
                  End
                 Else If vTempQuery.Fields[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Fields[A].AsDateTime := Params[I].AsDateTime
                   Else
                    vTempQuery.Fields[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Fields[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   If Not Assigned(vStringStream) Then
                    vStringStream  := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(vStringStream);
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     TBlobField(vTempQuery.Fields[A]).LoadFromStream(vStringStream);
                   Finally
                    If Assigned(vStringStream) Then
                     FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Fields[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       vTempQuery.FetchAll;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       {$IFDEF FPC}
        Result.DatabaseCharSet := DatabaseCharSet;
       {$ENDIF}
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Error         := False;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          {$IFDEF FPC}
           Result.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          Result.SetValue(GetPairJSONStr('NOK', MessageError));
          connRollback;
         Except
         End;
        End;
      End;
     End
    Else If (vResultReflection <> '') Then
     Begin
      If Result = Nil Then
       Result         := TJSONValue.Create;
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      {$IFDEF FPC}
       Result.DatabaseCharSet := DatabaseCharSet;
      {$ENDIF}
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RecordCount;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
  FreeAndNil(vValueKeys);
 End;
End;

Function TRESTDWDriverBase.ApplyUpdatesTB(Massive          : String;
                                          Params           : TRESTDWParams;
                                          var Error        : Boolean;
                                          var MessageError : String;
                                          var RowsAffected : Integer): TJSONValue;
Var
 vTempQuery     : TRESTDWTable;
 A, I           : Integer;
 vResultReflection,
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vMassiveLine   : Boolean;
 vValueKeys     : TRESTDWValueKeys;
 vDataSet       : TDataSet;

 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vTempValue,
  vStringFloat,
  vReflectionLine,
  vReflectionLines : String;
  vFieldType       : TFieldType;
  MassiveField     : TMassiveField;
  vFieldChanged    : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  {$IFDEF FPC}
  vFieldChanged     := False;
  {$ENDIF}
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]']);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (Not MassiveField.IsNull) Then
                                        Begin
                                         If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                            (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                          vFieldChanged     := True
                                         Else
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value);
                                        End
                                       Else
                                        vFieldChanged    := Not(Query.Fields[I].IsNull);
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (Not MassiveField.IsNull) Then
                                       Begin
                                        If (Query.Fields[I].AsDateTime <> MassiveField.Value) Or (MassiveField.Modified) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                   IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                     IntToStr(DateTimeToUnix(Query.Fields[I].AsDateTime))]);
                                       End;
                                     End;
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22},
                                 ftSingle,
                                 ftExtended
                                 {$IFEND}
                                 {$ENDIF} : Begin
                                             vStringFloat  := Query.Fields[I].AsString;
                                             If (Trim(vStringFloat) <> '') Then
                                              vStringFloat := BuildStringFloat(vStringFloat)
                                             Else
                                              vStringFloat := cNullvalue;
                                             If (MassiveField.Modified) Then
                                              vStringFloat := BuildStringFloat(MassiveField.Value);
                                             If vReflectionLine = '' Then
                                              vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                             Else
                                              vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                            End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               vTempValue := Query.Fields[I].AsString;
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                             EncodeStream(vStringStream)]) // StreamToHex(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                 EncodeStream(vStringStream)]); // StreamToHex(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TRESTDWTable) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;

  Procedure PrepareData(Var Query      : TRESTDWTable;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLocate    : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 22}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                               {$ELSE}
                                                                               , ftWideMemo
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Begin
             Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
             Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size);
            end
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                         ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                         ftString,    ftWideString,
                         ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 22}
                                     , ftWideMemo
                                    {$IFEND}
                                    {$ELSE}
                                    , ftWideMemo
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
         Begin
          If Query.Fields[I].Size > 0 Then
           Begin
            Query.Fields[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value, 1, Query.Fields[I].Size);
           End
          Else
           Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
         End;
       End
      Else
       Begin
        If Query.Fields[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Begin
            If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
             Query.Fields[I]{$IFNDEF FPC}{$IF CompilerVersion >= 22}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value)
            Else
             Query.Fields[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
           End
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value))
          Else
           Query.Fields[I].Clear;
         End
        Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
           Query.Fields[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value
          Else
           Query.Fields[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
           If (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull)) Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).SaveToStream(vStringStream);
              If vStringStream <> Nil Then
               Begin
                vStringStream.Position := 0;
                TBlobField(Query.Fields[I]).LoadFromStream(vStringStream);
               End
              Else
               Query.Fields[I].Clear;
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.Fields[I].Clear;
         End
        Else
         Query.Fields[I].Value := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.Filter    := '';
   Query.Filtered  := False;
   Query.TableName := MassiveDataset.TableName;
   vLocate         := '';
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vLocate := '1=0';
               End;
    mmUpdate,
    mmDelete : Begin
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If MassiveDataset.MassiveMode = mmUpdate Then
                    Begin
                     If I = 0 Then
                      vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value])
                     Else
                      vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.PrimaryValues[I].Value]);
                    End
                   Else
                    Begin
                     If I = 0 Then
                      vLocate := Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I +1].Value])
                     Else
                      vLocate := vLocate + ' and ' + Format('%s=''%s''', [bPrimaryKeys[I], MassiveDataset.AtualRec.Values[I +1].Value]);
                    End;
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
               End;
   End;
   Query.Filter    := vLocate;
   Query.Filtered  := True;
   //Params
   If (MassiveDataset.MassiveMode <> mmDelete) Then
    Begin
     If Assigned(Self.OnTableBeforeOpen) Then
      Self.OnTableBeforeOpen(vDataSet, Params, MassiveDataset.TableName);
     Query.Open;
     Query.FetchAll;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         If Query.FindField(MassiveDataset.Fields.Items[I].FieldName) <> Nil Then
          Begin
           Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
          End;
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Begin
                             Query.Post;
//                             Query.RefreshCurrentRow(true);
//                             Query.Resync([rmExact, rmCenter]);
                            End;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     Query.Open;
     Query.Delete;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Result         := False;
  Try
   MassiveDataset.FromJSON(Massive);
   MassiveDataset.First;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
      TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
    End;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If not connInTransaction Then Begin
       connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Query.Close;
     Query.Filter := '';
     Query.Filtered := False;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      If (Not (MassiveDataset.ReflectChanges))     Or
         ((MassiveDataset.ReflectChanges)          And
          (MassiveDataset.MassiveMode in [mmExec])) Then
       Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
          connRollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If connInTransaction Then
         Begin
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
           End;
           connCommit;
          If Self.Owner      Is TServerMethodDataModule Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
             TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
           End;
         End;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If connInTransaction Then
            connRollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If connInTransaction Then
     Begin
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
       End;
         connCommit;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
         TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
       End;
     End;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If connInTransaction Then
        connRollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
   FreeAndNil(MassiveDataset);
   Query.Filter := '';
   Query.Filtered := False;
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Try
  Result         := Nil;
  Error          := False;
  vStringStream  := Nil;
  vTempQuery     := getTable;
  vDataSet       := TDataSet(vTempQuery.Owner);
  vValueKeys     := TRESTDWValueKeys.Create;
  If Not isConnected Then
   Connect;
  vTempQuery.Filter       := '';
  vResultReflection := '';
  If LoadMassive(Massive, vTempQuery) Then
   Begin
    If (vResultReflection = '') Then
     Begin
      Try
       vTempQuery.Filter   := '';
       vTempQuery.Filtered := False;
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.Fields.Count > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A := vTempQuery.GetParamIndex(vParamName);
             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
              Begin
               If vTempQuery.Fields[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 22} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString,
                                                     ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                              {$IF CompilerVersion > 22}
                                                               , ftWideMemo
                                                              {$IFEND}
                                                              {$ELSE}
                                                              , ftWideMemo
                                                            {$ENDIF}]    Then
                Begin
                 If vTempQuery.Fields[A].Size > 0 Then
                  Begin
//                   vTempQuery.Fields[A].DataType := ftString;
                   vTempQuery.Fields[A].Value := Copy(Params[I].Value, 1, vTempQuery.Fields[A].Size);
                  End
                 Else
                  vTempQuery.Fields[A].Value := Params[I].Value;
                End
               Else
                Begin
//                 If vTempQuery.Fields[A].DataType in [ftUnknown] Then
//                  Begin
//                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
//                    vTempQuery.Fields[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
//                   Else
//                    vTempQuery.Fields[A].DataType := ftString;
//                  End;
                 If vTempQuery.Fields[A].DataType in [ftInteger, ftSmallInt, ftWord{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftLongWord{$IFEND}{$ENDIF}, ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Fields[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 22}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                      Begin
                       {$IFNDEF FPC}
                        {$IF CompilerVersion > 22}vTempQuery.Fields[A].AsLargeInt := StrToInt64(Params[I].Value);
                        {$ELSE}vTempQuery.Fields[A].AsInteger                     := StrToInt64(Params[I].Value);
                        {$IFEND}
                       {$ELSE}
                        vTempQuery.Fields[A].AsLargeInt := StrToInt64(Params[I].Value);
                       {$ENDIF}
                      End
                     Else
                      vTempQuery.Fields[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Fields[A].Clear;
                  End
                 Else If vTempQuery.Fields[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 22}, ftSingle{$IFEND}{$ENDIF}] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Fields[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Fields[A].Clear;
                  End
                 Else If vTempQuery.Fields[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Fields[A].AsDateTime := Params[I].AsDateTime
                   Else
                    vTempQuery.Fields[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Fields[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob] Then
                  Begin
                   If Not Assigned(vStringStream) Then
                    vStringStream  := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(vStringStream);
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     TBlobField(vTempQuery.Fields[A]).LoadFromStream(vStringStream);
                   Finally
                    If Assigned(vStringStream) Then
                     FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Fields[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       vTempQuery.FetchAll;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       {$IFDEF FPC}
        Result.DatabaseCharSet := DatabaseCharSet;
       {$ENDIF}
       Result.Utf8SpecialChars := True;
       Result.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Error         := False;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          {$IFDEF FPC}
           Result.DatabaseCharSet := DatabaseCharSet;
          {$ENDIF}
          Result.SetValue(GetPairJSONStr('NOK', MessageError));
          connRollback;
         Except
         End;
        End;
      End;
     End
    Else If (vResultReflection <> '') Then
     Begin
      If Result = Nil Then
       Result         := TJSONValue.Create;
      Result.Encoding := Encoding;
      Result.Encoded  := EncodeStringsJSON;
      {$IFDEF FPC}
       Result.DatabaseCharSet := DatabaseCharSet;
      {$ENDIF}
      Result.SetValue('[' + vResultReflection + ']');
      Error         := False;
     End;
   End;
 Finally
  RowsAffected := vTempQuery.RecordCount;
  vTempQuery.Close;
  FreeAndNil(vTempQuery);
  FreeAndNil(vValueKeys);
 End;
end;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCache  (MassiveStream         : TStream;
                                                       Var Error             : Boolean;
                                                       Var MessageError      : String) : TJSONValue;
Begin

End;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCache  (MassiveCache     : String;
                                                       Var Error        : Boolean;
                                                       Var MessageError : String): TJSONValue;
Var
 vTempQuery        : TRESTDWQuery;
 vStringStream     : TMemoryStream;
 bPrimaryKeys      : TStringList;
 vFieldType        : TFieldType;
 vStateResource,
 vMassiveLine      : Boolean;
 vResultReflection : String;

 Procedure BuildReflectionChanges(Var ReflectionChanges : String;
                                  MassiveDataset        : TMassiveDatasetBuffer;
                                  Query                 : TDataset); //Todo
 Var
  I                : Integer;
  vStringFloat,
  vTempValue,
  vReflectionLine,
  vReflectionLines  : String;
  vFieldType        : TFieldType;
  MassiveField      : TMassiveField;
  MassiveReplyValue : TMassiveReplyValue;
  vFieldChanged     : Boolean;
 Begin
  ReflectionChanges := '%s';
  vReflectionLine   := '';
  vFieldChanged     := False;
  If MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark) <> Nil Then
   Begin
    vReflectionLines  := Format('{"dwbookmark":"%s"%s, "mycomptag":"%s"}', [MassiveDataset.Fields.FieldByName(RESTDWFieldBookmark).Value, ', "reflectionlines":[%s]', MassiveDataset.MyCompTag]);
    For I := 0 To Query.Fields.Count -1 Do
     Begin
      MassiveField := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName);
      If MassiveField <> Nil Then
       Begin
        vFieldType := Query.Fields[I].DataType;
        If MassiveField.Modified Then
         vFieldChanged := MassiveField.Modified
        Else
         Begin
          Case vFieldType Of
            ftDate, ftTime,
            ftDateTime, ftTimeStamp : Begin
                                       If (MassiveField.IsNull And Not (Query.Fields[I].IsNull)) Or
                                          (Not (MassiveField.IsNull) And Query.Fields[I].IsNull) Then
                                        vFieldChanged     := True
                                       Else
                                        Begin
                                         If (Not MassiveField.IsNull) Then
                                          vFieldChanged     := (Query.Fields[I].AsDateTime <> MassiveField.Value)
                                         Else
                                          vFieldChanged    := Not(Query.Fields[I].IsNull);
                                        End;
                                      End;
           ftBytes, ftVarBytes,
           ftBlob,  ftGraphic,
           ftOraBlob, ftOraClob     : Begin
                                       vStringStream  := TMemoryStream.Create;
                                       Try
                                        TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                                        vStringStream.Position := 0;
  //                                      vFieldChanged := StreamToHex(vStringStream) <> MassiveField.Value;
                                        vFieldChanged := EncodeStream(vStringStream) <> MassiveField.Value;
                                       Finally
                                        If Assigned(vStringStream) Then
                                         FreeAndNil(vStringStream);
                                       End;
                                      End;
           Else
            vFieldChanged := (Query.Fields[I].Value <> MassiveField.Value);
          End;
         End;
        If vFieldChanged Then
         Begin
          MassiveReplyValue := MassiveDataset.MassiveReply.GetReplyValue(MassiveDataset.MyCompTag, Query.Fields[I].FieldName, MassiveField.Value);
          If MassiveField.KeyField Then
           Begin
            If MassiveReplyValue = Nil Then
             MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, MassiveField.Value, Query.Fields[I].AsString)
            Else
             MassiveDataset.MassiveReply.UpdateBufferValue(MassiveDataset.MyCompTag, Query.Fields[I].FieldName, MassiveField.Value, Query.Fields[I].AsString);
           End;
          vTempValue := Query.Fields[I].AsString;
          Case vFieldType Of
           ftDate, ftTime,
           ftDateTime, ftTimeStamp : Begin
                                      If (vTempValue <> cNullvalue) And (vTempValue <> '') Or (MassiveField.Modified) Then
                                       Begin
                                        If (StrToDateTime(vTempValue) <> MassiveField.Value) Then
                                         Begin
                                          If (MassiveField.Modified) Then
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(MassiveField.Value)))
                                          Else
                                           vTempValue := IntToStr(DateTimeToUnix(StrToDateTime(vTempValue)));
                                          If vReflectionLine = '' Then
                                           vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                                                     vTempValue])
                                          Else
                                           vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                                         vTempValue]);
                                         End;
                                       End
                                      Else
                                       Begin
                                        If vReflectionLine = '' Then
                                         vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                                        Else
                                         vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                                                       cNullvalue]);
                                       End;
                                     End;
           ftFloat,
           ftCurrency, ftBCD,
           ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},
                                 ftSingle,
                                 ftExtended{$IFEND}{$ENDIF} : Begin
                                       vStringFloat  := Query.Fields[I].AsString;
                                       If (Trim(vStringFloat) <> '') Then
                                        vStringFloat := BuildStringFloat(vStringFloat)
                                       Else
                                        vStringFloat := cNullvalue;
                                       If (MassiveField.Modified) Then
                                        vStringFloat := BuildStringFloat(MassiveField.Value);
                                       If vReflectionLine = '' Then
                                        vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, vStringFloat])
                                       Else
                                        vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, vStringFloat]);
                                      End;
           Else
            Begin
             If Not (vFieldType In [ftBytes, ftVarBytes, ftBlob,
                                    ftGraphic, ftOraBlob, ftOraClob]) Then
              Begin
               If (MassiveField.Modified) Then
                If Not MassiveField.IsNull Then
                 vTempValue := MassiveField.Value
                Else
                 vTempValue := cNullvalue;
               If vReflectionLine = '' Then
                vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName,
                                                          EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})])
               Else
                vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName,
                                                                              EncodeStrings(vTempValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
              End
             Else
              Begin
               vStringStream  := TMemoryStream.Create;
               Try
                TBlobfield(Query.Fields[I]).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                If vStringStream.Size > 0 Then
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, EncodeStream(vStringStream)])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, EncodeStream(vStringStream)]);
                 End
                Else
                 Begin
                  If vReflectionLine = '' Then
                   vReflectionLine := Format('{"%s":"%s"}', [MassiveField.FieldName, cNullvalue])
                  Else
                   vReflectionLine := vReflectionLine + Format(', {"%s":"%s"}', [MassiveField.FieldName, cNullvalue]);
                 End;
               Finally
                If Assigned(vStringStream) then
                 FreeAndNil(vStringStream);
               End;
              End;
            End;
          End;
         End;
       End;
     End;
    If vReflectionLine <> '' Then
     ReflectionChanges := Format(ReflectionChanges, [Format(vReflectionLines, [vReflectionLine])])
    Else
     ReflectionChanges := '';
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TRESTDWQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, X           : Integer;
  bJsonValueB    : TRESTDWJSONInterfaceBase;
  bJsonValue     : TRESTDWJSONInterfaceObject;
  bJsonArray     : TRESTDWJSONInterfaceArray;
  Procedure PrepareData(Var Query      : TRESTDWQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vResultReflectionLine,
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer(All : Boolean = False);
   Var
    X : Integer;
    MassiveReplyCache : TMassiveReplyCache;
    MassiveReplyValue : TMassiveReplyValue;
    vTempValue        : String;
   Begin
    If (I = 0) or (All) Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString,
                                                                       ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                               {$IF CompilerVersion > 21}
                                                                                , ftWideMemo
                                                                               {$IFEND}
                                                                              {$ENDIF}]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
            Begin
             If MassiveDataset.MasterCompTag <> '' Then
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag]
             Else
              MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MyCompTag];
             MassiveReplyValue := Nil;
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].OldValue);
               If MassiveReplyValue = Nil Then
                MassiveReplyValue := MassiveReplyCache.ItemByValue(bPrimaryKeys[X], MassiveDataset.AtualRec.PrimaryValues[X].Value);
               If MassiveReplyValue <> Nil Then
                Begin
                 If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]){$IFNDEF FPC}{$IF CompilerVersion >= 21}.AsLargeInt{$ELSE}.AsInteger{$IFEND}{$ELSE}.AsLargeInt{$ENDIF} := StrToInt64(MassiveReplyValue.NewValue)
                 Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveReplyValue.NewValue)
                 Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveReplyValue.NewValue);
                End;
              End;
             If (MassiveReplyValue = Nil) And (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Begin
               If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
               Else
                Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD,ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (Not (MassiveDataset.AtualRec.PrimaryValues[X].IsNull)) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := MassiveDataset.AtualRec.PrimaryValues[X].Value
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob] Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream  := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
      Finally
       FreeAndNil(bPrimaryKeys);
      End;
     End;
    If Not (All) Then
     Begin
      If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                            ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                            ftString,    ftWideString,
                            ftMemo, ftFmtMemo {$IFNDEF FPC}
                                    {$IF CompilerVersion > 21}
                                     , ftWideMemo
                                    {$IFEND}
                                   {$ENDIF}]    Then
       Begin
        If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
         Begin
          If Query.Params[I].Size > 0 Then
           Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
          Else
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
         End;
       End
      Else
       Begin
        If Query.Params[I].DataType in [ftUnknown] Then
         Begin
          If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
           Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
          Else
           Query.Params[I].DataType := ftString;
         End;
        If Query.Params[I].DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Begin
            If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else If Query.Params[I].DataType = ftSmallInt           Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
            Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
           End
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
          Else
           Query.Params[I].Clear;
         End
        Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
           Query.Params[I].AsDateTime  := StrToDateTime(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
          Else
           Query.Params[I].Clear;
         End  //Tratar Blobs de Parametros...
        Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                             ftGraphic, ftOraBlob, ftOraClob] Then
         Begin
           If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
            Begin
             If Not Assigned(vStringStream) Then
              vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
              If vStringStream <> Nil Then
               Begin
                vStringStream.Position := 0;
                Query.Params[I].LoadFromStream(vStringStream, ftBlob);
               End
              Else
               Query.Params[I].Clear;
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.Params[I].Clear;
         End
        Else
         Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
       End;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' Where %s'])
                Else
                 vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                        (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                        (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                       (MassiveDataset.Fields.Items[I].ReadOnly))          And
                       (Not(MassiveDataset.ReflectChanges)))               Or
                      ((MassiveDataset.ReflectChanges) And
                       (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                        (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                    Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    If Not MassiveDataset.ReflectChanges Then
                     vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                  If MassiveDataset.ReflectChanges Then
                   Begin
                    If MassiveDataset.Fields.Items[I].KeyField Then
                     If vParamsSQL = '' Then
                      vParamsSQL := MassiveDataset.Fields.Items[I].FieldName + ' is null '
                     Else
                      vParamsSQL  := vParamsSQL + ' and ' + MassiveDataset.Fields.Items[I].FieldName + ' is null ';
                   End;
                 End;
                If MassiveDataset.ReflectChanges Then
                 Begin
                  If vParamsSQL = '' Then
                   Begin
                    Raise Exception.Create(PChar(Format('Invalid insert, table %s no have keys defined to use in Reflect Changes...', [MassiveDataset.TableName])));
                    Exit;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vFields  := '';
                vParamsSQL  := '';
                If MassiveDataset.ReflectChanges Then
                 vLineSQL := Format('Select %s ', ['%s From ' + MassiveDataset.TableName + ' %s'])
                Else
                 vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                If Not MassiveDataset.ReflectChanges Then
                 Begin
                  For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If vFields = '' Then
                       vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End
                Else
                 Begin
                  For I := 0 To MassiveDataset.Fields.Count -1 Do
                   Begin
                    If Lowercase(MassiveDataset.Fields.Items[I].FieldName) <> Lowercase(RESTDWFieldBookmark) Then // Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(RESTDWFieldBookmark) Then
                     Begin
                      If ((((MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                            (MassiveDataset.AtualRec.MassiveMode = mmInsert)   And
                            (MassiveDataset.Fields.Items[I].ReadOnly))         Or
                           (MassiveDataset.Fields.Items[I].ReadOnly))          And
                           (Not(MassiveDataset.ReflectChanges)))               Or
                          ((MassiveDataset.ReflectChanges) And
                           (((MassiveDataset.Fields.Items[I].ReadOnly) And (Not MassiveDataset.Fields.Items[I].AutoGenerateValue)) Or
                            (Lowercase(MassiveDataset.Fields.Items[I].FieldName) = Lowercase(RESTDWFieldBookmark)))) Then
                        Continue;
                      If vFields = '' Then
                       vFields     := MassiveDataset.Fields.Items[I].FieldName//MassiveDataset.AtualRec.UpdateFieldChanges[I]
                      Else
                       vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName //MassiveDataset.AtualRec.UpdateFieldChanges[I];
                     End;
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
    mmExec   : vLineSQL := MassiveDataset.Dataexec.Text;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   If (MassiveDataset.ReflectChanges) And
      (Not(MassiveDataset.MassiveMode in [mmDelete, mmExec])) Then
    Begin
     If MassiveDataset.MassiveMode = mmUpdate Then
      SetUpdateBuffer(True);
     Query.Open;
     For I := 0 To MassiveDataset.Fields.Count -1 Do
      Begin
       If (MassiveDataset.Fields.Items[I].KeyField) And
          (MassiveDataset.Fields.Items[I].AutoGenerateValue) Then
        Begin
         Query.createSequencedField(MassiveDataset.SequenceName, MassiveDataset.Fields.Items[I].FieldName);
        End;
      End;
     Try
      Case MassiveDataset.MassiveMode Of
       mmInsert : Query.Insert;
       mmUpdate : Begin
                   If Query.RecNo > 0 Then
                    Query.Edit
                   Else
                    Raise Exception.Create(PChar('Record not found to update...'));
                  End;
      End;
      BuildDatasetLine(TRESTDWDataset(Query), MassiveDataset, True);
     Finally
      Case MassiveDataset.MassiveMode Of
       mmInsert, mmUpdate : Query.Post;
      End;
      //Retorno de Dados do ReflectionChanges
      BuildReflectionChanges(vResultReflectionLine, MassiveDataset, TDataset(Query.Owner));
      If vResultReflection = '' Then
       vResultReflection := vResultReflectionLine
      Else
       vResultReflection := vResultReflection + ', ' + vResultReflectionLine;
      If (Self.Owner.ClassType = TServerMethodDatamodule)             Or
         (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
         TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query));
       End;
      Query.Close;
     End;
    End
   Else
    Begin
     For I := 0 To Query.ParamCount -1 Do
      Begin
       If MassiveDataset.MassiveMode = mmExec Then
        Begin
         If MassiveDataset.Params.ItemsString[Query.Params[I].Name] <> Nil Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue);
           If MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Params.ItemsString[Query.Params[I].Name].ObjectValue)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull))  Then
                  Query.Params[I].AsDateTime  := StrToDateTime(MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value)
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                   Begin
                    MassiveDataset.Params.ItemsString[Query.Params[I].Name].SaveToStream(TStream(vStringStream));
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Params.ItemsString[Query.Params[I].Name].IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Params.ItemsString[Query.Params[I].Name].Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End;
        End
       Else
        Begin
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
          Begin
           vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
           If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull Then
            Begin
             If vFieldType = ftUnknown Then
              Query.Params[I].DataType := ftString
             Else
              Query.Params[I].DataType := vFieldType;
             Query.Params[I].Clear;
            End;
           If MassiveDataset.MassiveMode <> mmUpdate Then
            Begin
             If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                   ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                   ftString,    ftWideString,
                                   ftMemo, ftFmtMemo {$IFNDEF FPC}
                                           {$IF CompilerVersion > 21}
                                            , ftWideMemo
                                           {$IFEND}
                                          {$ENDIF}]    Then
              Begin
               If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Begin
                 If Query.Params[I].Size > 0 Then
                  Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
                 Else
                  Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
                End
               Else
                Query.Params[I].Clear;
              End
             Else
              Begin
               If Query.Params[I].DataType in [ftUnknown] Then
                Begin
                 If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
                  Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
                 Else
                  Query.Params[I].DataType := ftString;
                End;
               If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Begin
                   If Query.Params[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else If Query.Params[I].DataType = ftSmallInt Then
                    Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                   Else
                    Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                  End
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21},ftSingle {$IFEND}{$ENDIF}] Then
                Begin
                 If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                  Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
                 Else
                  Query.Params[I].Clear;
                End
               Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                Begin
                 If (Not (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull))  Then
                  Query.Params[I].AsDateTime  := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
                 Else
                  Query.Params[I].Clear;
                End  //Tratar Blobs de Parametros...
               Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                    ftGraphic, ftOraBlob, ftOraClob] Then
                Begin
                 If Not Assigned(vStringStream) Then
                  vStringStream  := TMemoryStream.Create;
                 Try
                  If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                   Begin
                    MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                    If vStringStream <> Nil Then
                     Begin
                      vStringStream.Position := 0;
                      Query.Params[I].LoadFromStream(vStringStream, ftBlob);
                     End
                    Else
                     Query.Params[I].Clear;
                   End
                  Else
                   Query.Params[I].Clear;
                 Finally
                  FreeAndNil(vStringStream);
                 End;
                End
               Else If (Not(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).IsNull)) Then
                Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
               Else
                Query.Params[I].Clear;
              End;
            End
           Else //Update
            Begin
             SetUpdateBuffer;
            End;
          End
         Else
          Begin
           If I = 0 Then
            SetUpdateBuffer;
          End;
        End;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  bJsonValue     := TRESTDWJSONInterfaceObject.Create(MassiveCache);
  bJsonArray     := TRESTDWJSONInterfaceArray(bJsonValue);
  Result         := False;
  Try
   For x := 0 To bJsonArray.ElementCount -1 Do
    Begin
     bJsonValueB := bJsonArray.GetObject(X);//bJsonArray.get(X);
     If not connInTransaction Then
      Begin
       connStartTransaction;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction) Then
          TServerMethodDataModule(Self.Owner).OnMassiveAfterStartTransaction(MassiveDataset);
        End;
      End;
     Try
      MassiveDataset.FromJSON(TRESTDWJSONInterfaceObject(bJsonValueB).ToJSON);
      MassiveDataset.First;
      If Self.Owner      Is TServerMethodDataModule Then
       Begin
        If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveBegin) Then
         TServerMethodDataModule(Self.Owner).OnMassiveBegin(MassiveDataset);
       End;
      For A := 1 To MassiveDataset.RecordCount Do
       Begin
        Query.SQL.Clear;
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          vMassiveLine := False;
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
           Begin
            TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
            If vMassiveLine Then
             Begin
              MassiveDataset.Next;
              Continue;
             End;
           End;
         End;
        PrepareData(Query, MassiveDataset, Error, MessageError);
        Try
         If (Not (MassiveDataset.ReflectChanges))     Or
            ((MassiveDataset.ReflectChanges)          And
            (MassiveDataset.MassiveMode in [mmExec, mmDelete])) Then
          Begin
           Query.ExecSQL;

           // Inclusão do método de after massive line process
           If (Self.Owner.ClassType = TServerMethodDatamodule) Or
             (Self.Owner.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
           Begin
            If Assigned(TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess) Then
             TServerMethodDataModule(Self.Owner).OnAfterMassiveLineProcess(MassiveDataset, TDataset(Query));
           End;
         End;
        Except
         On E : Exception do
          Begin
           Error  := True;
           Result := False;
           If connInTransaction Then
             connRollback;
           MessageError := E.Message;
           Exit;
          End;
        End;
        MassiveDataset.Next;
       End;
     Finally
      Query.SQL.Clear;
      FreeAndNil(bJsonValueB);
     End;
    End;
   If Not Error Then
    Begin
     Try
      Result        := True;
      If connInTransaction Then
       Begin
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit) Then
           TServerMethodDataModule(Self.Owner).OnMassiveAfterBeforeCommit(MassiveDataset);
         End;
         connCommit;
        If Self.Owner      Is TServerMethodDataModule Then
         Begin
          If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit) Then
           TServerMethodDataModule(Self.Owner).OnMassiveAfterAfterCommit(MassiveDataset);
         End;
       End;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
           connRollback;
        MessageError := E.Message;
       End;
     End;
    End;
   If Self.Owner      Is TServerMethodDataModule Then
    Begin
     If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveEnd) Then
      TServerMethodDataModule(Self.Owner).OnMassiveEnd(MassiveDataset);
    End;
  Finally
   FreeAndNil(bJsonValue);
   FreeAndNil(MassiveDataset);
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 vResultReflection := '';
 Result     := Nil;
 vStringStream := Nil;
 Try
  Error      := False;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If Not vStateResource Then
    Connect;
  vTempQuery.SQL.Clear;
  LoadMassive(MassiveCache, vTempQuery);
  If Result = Nil Then
   Result         := TJSONValue.Create;
  If (vResultReflection <> '') Then
   Begin
    Result.Encoding := Encoding;
    Result.Encoded  := EncodeStringsJSON;
    Result.SetValue('[' + vResultReflection + ']');
    Error         := False;
   End
  Else
   Result.SetValue('[]');
  If Not vStateResource Then
    Disconect;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
End;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCacheTB(MassiveStream         : TStream;
                                                       Var Error             : Boolean;
                                                       Var MessageError      : String) : TJSONValue;
Begin

End;

Function TRESTDWDriverBase.ApplyUpdates_MassiveCacheTB(MassiveCache     : String;
                                                       Var Error        : Boolean;
                                                       Var MessageError : String): TJSONValue;
Begin

End;

Function TRESTDWDriverBase.ProcessMassiveSQLCache(MassiveSQLCache: String;
                                                  var Error: Boolean;
                                                  var MessageError: String): TJSONValue;
Var
 vTempQuery        : TRESTDWQuery;
 vStringStream     : TMemoryStream;
 vStateResource    : Boolean;
 vResultReflection : String;

 Function LoadMassive(Massive : String; Var Query : TRESTDWQuery) : Boolean;
 Var
  X, A, I         : Integer;
  vMassiveSQLMode : TMassiveSQLMode;
  vSQL,
  vParamsString,
  vBookmark,
  vParamName      : String;
  vBinaryRequest  : Boolean;
  vDWParams       : TRESTDWParams;
  bJsonValueB     : TRESTDWJSONInterfaceBase;
  bJsonValue      : TRESTDWJSONInterfaceObject;
  bJsonArray      : TRESTDWJSONInterfaceArray;
 Begin
  bJsonValue     := TRESTDWJSONInterfaceObject.Create(MassiveSQLCache);
  bJsonArray     := TRESTDWJSONInterfaceArray(bJsonValue);
  Result         := False;
  Try
   For X := 0 To bJsonArray.ElementCount -1 Do
    Begin
     bJsonValueB := bJsonArray.GetObject(X);//bJsonArray.get(X);
     If Not connInTransaction Then
       connStartTransaction;
     vDWParams          := TRESTDWParams.Create;
     vDWParams.Encoding := Encoding;
     Try
      vMassiveSQLMode := MassiveSQLMode(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[0].Value);
      vSQL            := StringReplace(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}), #$B, ' ', [rfReplaceAll]);
      vParamsString   := DecodeStrings(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[2].Value{$IFDEF FPC}, csUndefined{$ENDIF});
      vBookmark       := TRESTDWJSONInterfaceObject(bJsonValueB).pairs[3].Value;
      vBinaryRequest  := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonValueB).pairs[4].Value);
      If Not vBinaryRequest Then
       vDWParams.FromJSON(vParamsString)
      Else
       vDWParams.FromJSON(vParamsString, vBinaryRequest);
      Query.Close;
      Case vMassiveSQLMode Of
       msqlQuery    :; //TODO
       msqlExecute  : Begin
                       Query.SQL.Text := vSQL;
                       If vDWParams.Count > 0 Then
                        Begin
                           Try
                           // vTempQuery.Prepare;
                           Except
                           End;
                           For I := 0 To vDWParams.Count -1 Do
                            Begin
                             If vTempQuery.ParamCount > I Then
                              Begin
                               vParamName := Copy(StringReplace(vDWParams[I].ParamName, ',', '', []), 1, Length(vDWParams[I].ParamName));
                               A          := vTempQuery.GetParamIndex(vParamName);
                               If A > -1 Then
                                Begin
                                 If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       {$IF CompilerVersion > 22}{$IFEND}DB.ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString]    Then
                                  Begin
                                   if not vDWParams[I].IsNull then begin
                                     If vTempQuery.Params[A].Size > 0 Then
                                      vTempQuery.Params[A].Value := Copy(vDWParams[I].Value, 1, vTempQuery.Params[A].Size)
                                     Else
                                      vTempQuery.Params[A].Value := vDWParams[I].Value;
                                   end
                                   else begin
                                     vTempQuery.Params[A].Clear;
                                   end;
                                  End
                                 Else
                                  Begin
                                   If vTempQuery.Params[A].DataType in [ftUnknown] Then
                                    Begin
                                     If Not (ObjectValueToFieldType(vDWParams[I].ObjectValue) in [ftUnknown]) Then
                                      vTempQuery.Params[A].DataType := ObjectValueToFieldType(vDWParams[I].ObjectValue)
                                     Else
                                      vTempQuery.Params[A].DataType := ftString;
                                    End;
                                   If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                                    Begin
                                     If (Not (vDWParams[I].isNull)) Then
                                      Begin
                                       If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                                        vTempQuery.Params[A].AsLargeInt := StrToInt64(vDWParams[I].Value)
                                       Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                                        vTempQuery.Params[A].AsSmallInt := StrToInt(vDWParams[I].Value)
                                       Else
                                        vTempQuery.Params[A].AsInteger  := StrToInt(vDWParams[I].Value);
                                      End
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End
                                   Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle {$IFEND}{$ENDIF}] Then
                                    Begin
                                     If (Not (vDWParams[I].IsNull)) Then
                                      vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(vDWParams[I].Value))
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End
                                   Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                                    Begin
                                     If (Not (vDWParams[I].IsNull)) Then
                                      Begin
                                       If vTempQuery.Params[A].DataType = ftDate Then
                                        vTempQuery.Params[A].AsDate     := vDWParams[I].AsDateTime
                                       Else If vTempQuery.Params[A].DataType = ftTime Then
                                        vTempQuery.Params[A].AsTime     := vDWParams[I].AsDateTime
                                       Else
                                        vTempQuery.Params[A].AsDateTime := vDWParams[I].AsDateTime;
                                      End
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End  //Tratar Blobs de Parametros...
                                   Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                             ftGraphic, ftOraBlob, ftOraClob] Then
                                    Begin
                                     If Not Assigned(vStringStream) Then
                                      vStringStream  := TMemoryStream.Create;
                                     Try
                                      vDWParams[I].SaveToStream(TStream(vStringStream));
                                      vStringStream.Position := 0;
                                      If vStringStream.Size > 0 Then
                                       vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                                     Finally
                                      If Assigned(vStringStream) Then
                                       FreeAndNil(vStringStream);
                                     End;
                                    End
                                   Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                             ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                             ftString,    ftWideString,
                                                                             ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                                     {$IF CompilerVersion > 21}
                                                                                     , ftWideMemo
                                                                                     {$IFEND}
                                                                                    {$ENDIF}]    Then
                                    Begin
                                     if not vDWParams[I].IsNull then
                                      vTempQuery.Params[A].AsString := vDWParams[I].Value
                                     Else
                                      vTempQuery.Params[A].Clear;
                                    End
                                   Else
                                    vTempQuery.Params[A].Value    := vDWParams[I].Value;
                                  End;
                                End;
                              End
                             Else
                              Break;
                            End;
                        End;
                       Query.ExecSQL;
                      End;
      End;
     Finally
      Query.SQL.Clear;
      FreeAndNil(bJsonValueB);
      FreeAndNil(vDWParams);
     End;
    End;
   If Not Error Then
    Begin
     Try
      Result        := True;
      If connInTransaction Then
       Begin
        connCommit;
       End;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If connInTransaction Then
         connRollback;
        MessageError := E.Message;
       End;
     End;
    End;
  Finally
   FreeAndNil(bJsonValue);
  End;
 End;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 vResultReflection := '';
 Result     := Nil;
 vStringStream := Nil;
 Try
  Error      := False;
  vTempQuery := getQuery;
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  vTempQuery.SQL.Clear;
  LoadMassive(MassiveSQLCache, vTempQuery);
  If Result = Nil Then
   Result         := TJSONValue.Create;
  If (vResultReflection <> '') Then
   Begin
    Result.Encoding := Encoding;
    Result.Encoded  := EncodeStringsJSON;
    Result.SetValue('[' + vResultReflection + ']');
    Error         := False;
   End
  Else
   Result.SetValue('[]');
  If Not vStateResource Then
   Disconect;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
end;

Function TRESTDWDriverBase.ExecuteCommand(SQL                   : String;
                                          Var Error             : Boolean;
                                          Var MessageError      : String;
                                          Var BinaryBlob        : TMemoryStream;
                                          Var RowsAffected      : Integer;
                                          Execute               : Boolean = False;
                                          BinaryEvent           : Boolean = False;
                                          MetaData              : Boolean = False;
                                          BinaryCompatibleMode  : Boolean = False) : String;
Begin
 Result := ExecuteCommand(SQL, Nil, Error, MessageError, BinaryBlob, RowsAffected,
                          Execute, BinaryEvent, MetaData, BinaryCompatibleMode);
End;

Function TRESTDWDriverBase.ExecuteCommand(SQL                   : String;
                                          Params                : TRESTDWParams;
                                          Var Error             : Boolean;
                                          Var MessageError      : String;
                                          Var BinaryBlob        : TMemoryStream;
                                          Var RowsAffected      : Integer;
                                          Execute               : Boolean = False;
                                          BinaryEvent           : Boolean = False;
                                          MetaData              : Boolean = False;
                                          BinaryCompatibleMode  : Boolean = False): String;
Var
 vTempQuery     : TRESTDWQuery;
 vDataSet       : TDataSet;
 A, I           : Integer;
 vParamName     : String;
 vStateResource : Boolean;
 vStringStream  : TMemoryStream;
 aResult        : TJSONValue;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error  := False;
 Result := '';
 vStringStream := Nil;
 aResult := TJSONValue.Create;
 vTempQuery := getQuery;
 vDataSet := TDataSet(vTempQuery.Owner);
 Try
  vStateResource := isConnected;
  If Not isConnected Then
    Connect;

  If Not connInTransaction Then
    connStartTransaction;

  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Params <> Nil Then
   Begin
    Try
      vTempQuery.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If (vTempQuery.ParamCount > I) And (Not (Params[I].IsNull)) Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := vTempQuery.GetParamIndex(vParamName);
        If A > -1 Then
         Begin
          If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                ftString,    ftWideString]    Then
           Begin
            If vTempQuery.Params[A].Size > 0 Then
             vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
            Else
             vTempQuery.Params[A].Value := Params[I].Value;
           End
          Else
           Begin
            If vTempQuery.Params[A].DataType in [ftUnknown] Then
             Begin
              If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
               vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
              Else
               vTempQuery.Params[A].DataType := ftString;
             End;
            If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               Begin
                If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                 vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                 vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                Else
                 vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
               End
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion >= 21}, ftSingle {$IFEND}{$ENDIF}] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
             Begin
              If (Not (Params[I].IsNull)) Then
               Begin
                If vTempQuery.Params[A].DataType = ftDate Then
                 vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
                Else If vTempQuery.Params[A].DataType = ftTime Then
                 vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
                Else
                 vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
                vTempQuery.Params[A].AsDateTime  := Params[I].AsDateTime
               End
              Else
               vTempQuery.Params[A].Clear;
             End  //Tratar Blobs de Parametros...
            Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                      ftGraphic, ftOraBlob, ftOraClob] Then
             Begin
              If (Not (Params[I].IsNull)) Then
              Begin
              If Not Assigned(vStringStream) Then
               vStringStream  := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(TStream(vStringStream));
               vStringStream.Position := 0;
               If vStringStream.Size > 0 Then
                vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
              Finally
               If Assigned(vStringStream) Then
                FreeAndNil(vStringStream);
              End;
             End
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                      ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                      ftString,    ftWideString,
                                                      ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                              {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                              {$IFEND}
                                                             {$ENDIF}]    Then
             Begin
              If (Trim(Params[I].Value) <> '') Then
               vTempQuery.Params[A].AsString := Params[I].Value
              Else
               vTempQuery.Params[A].Clear;
             End
            Else If vTempQuery.Params[A].DataType in [ftGuid] Then
             Begin
              If (Not (Params[I].IsNull)) Then
                vTempQuery.Params[A].Value := Params[I].AsString
              Else
                vTempQuery.Params[A].Clear;
             End
            Else
             vTempQuery.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else If (vTempQuery.ParamCount <= I) Then
       Break;
     End;
   End;
  If Not Execute Then
   Begin
   If Assigned(Self.OnQueryBeforeOpen) Then
     Self.OnQueryBeforeOpen(vDataSet, Params);
    If Not(BinaryCompatibleMode) Then
     Begin
      vTempQuery.Open;
      vTempQuery.FetchAll;
     End;
     If connInTransaction Then
       connCommit;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
    aResult.Encoding := Encoding;
    Try
     If Not BinaryEvent Then
      Begin
       aResult.Utf8SpecialChars := True;
       aResult.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
       Result := aResult.ToJSON;
      End
     Else If Not BinaryCompatibleMode Then
      Begin
       If Not Assigned(BinaryBlob) Then
        BinaryBlob := TMemoryStream.Create;
       Try
        vTempQuery.SaveToStream(BinaryBlob);
        BinaryBlob.Position := 0;
       Finally
       End;
      End
     Else
      TRESTDWClientSQLBase.SaveToStream(TDataSet(vTempQuery.Owner), BinaryBlob);
    Finally
    End;
   End
  Else
   Begin
    If Assigned(Self.OnQueryBeforeOpen) Then
      Self.OnQueryBeforeOpen(vDataSet, Params);
    vTempQuery.ExecSQL;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
     If connInTransaction Then
       connCommit;;
    aResult.SetValue('COMMANDOK');
    Result := aResult.ToJSON;
   End;
   if not vStateResource then
     Disconect
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     If aResult = Nil Then
      aResult := TJSONValue.Create;
     aResult.Encoded := True;
     aResult.SetValue(GetPairJSONStr('NOK', MessageError));
     Result := aResult.ToJSON;
     If connInTransaction Then
       connRollback;

     If Assigned(Self.OnQueryException) Then
      Self.OnQueryException(vDataSet, Params, E.Message);
    Except
    End;
    Disconect;
   End;
 End;
 FreeAndNil(aResult);
 RowsAffected := vTempQuery.RowsAffected;
 vTempQuery.Close;
 vTempQuery.Free;
end;

Function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
                                            var Error: Boolean;
                                            var MessageError: String;
                                            var BinaryBlob: TMemoryStream;
                                            var RowsAffected: Integer;
                                            BinaryEvent: Boolean;
                                            MetaData: Boolean;
                                            BinaryCompatibleMode: Boolean): String;
begin
  ExecuteCommandTB(Tablename,nil,Error,MessageError,BinaryBlob,RowsAffected,
                   BinaryEvent,MetaData,BinaryCompatibleMode);
end;

Function TRESTDWDriverBase.ExecuteCommandTB(Tablename: String;
                                            Params: TRESTDWParams;
                                            var Error: Boolean;
                                            var MessageError: String;
                                            var BinaryBlob: TMemoryStream;
                                            var RowsAffected: Integer;
                                            BinaryEvent: Boolean; MetaData: Boolean;
                                            BinaryCompatibleMode: Boolean): String;
var
  vTempQuery     : TRESTDWTable;
  vDataset       : TDataset;
  aResult        : TJSONValue;
  vStateResource : Boolean;
begin
  {$IFNDEF FPC}Inherited;{$ENDIF}
  Error  := False;
  aResult := TJSONValue.Create;
  vTempQuery := getTable;
  vDataset := TDataset(vTempQuery.Owner);
  try
    vStateResource := isConnected;
    if not vStateResource then
      Connect;

    vTempQuery.TableName    := TableName;
    if Assigned(Self.OnTableBeforeOpen) then
      Self.OnTableBeforeOpen(vDataset, Params, TableName);

    vTempQuery.Open;

    if aResult = nil Then
      aResult := TJSONValue.Create;

    aResult.Encoded         := EncodeStringsJSON;
    aResult.Encoding        := Encoding;
    {$IFDEF FPC}
      aResult.DatabaseCharSet := DatabaseCharSet;
    {$ENDIF}
    try
      if Not BinaryEvent then begin
        aResult.Utf8SpecialChars := True;
        aResult.LoadFromDataset('RESULTDATA', TDataset(vTempQuery.Owner), EncodeStringsJSON);
        Result := aResult.ToJson;
      end
      else if not BinaryCompatibleMode then begin
        if not Assigned(BinaryBlob) then
          BinaryBlob := TMemoryStream.Create;
        try
          vTempQuery.SaveToStream(BinaryBlob);
          BinaryBlob.Position := 0;
        finally

        end;
      end
      else
        TRESTDWClientSQLBase.SaveToStream(TDataset(vTempQuery.Owner), BinaryBlob);

      if not vStateResource then
        Connect;

      if not vStateResource then
        Disconect;
    finally
      FreeAndNil(aResult);
    end;
  except
    on E : Exception do begin
      try
        Error                   := True;
        MessageError            := E.Message;
        if aResult = Nil then
          aResult := TJSONValue.Create;

        aResult.Encoded         := True;
        aResult.Encoding        := Encoding;
        {$IFDEF FPC}
          aResult.DatabaseCharSet := DatabaseCharSet;
        {$ENDIF}
        aResult.SetValue(GetPairJSONStr('NOK', MessageError));
        Result := aResult.ToJson;

        FreeAndNil(aResult);
        connRollback;
        Disconect;
      except

      end;
   end;
 end;

 vTempQuery.Close;
 vTempQuery.Free;
end;

Procedure TRESTDWDriverBase.ExecuteProcedure(ProcName         : String;
                                             Params           : TRESTDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Var
 A, I            : Integer;
 vParamName      : String;
 vStateResource  : Boolean;
 vTempStoredProc : TRESTDWStoreProc;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
  Error  := False;
  vTempStoredProc := getStoreProc;
  vStateResource := isConnected;
  if not vStateResource Then
    Connect;

  if not connInTransaction then
    connStartTransaction;

  try
    vTempStoredProc.StoredProcName := ProcName;
    if Params <> Nil then begin
      try
        vTempStoredProc.Prepare;
      except

      end;

      for I := 0 To Params.Count -1 do begin
        if vTempStoredProc.ParamCount > I then begin
          vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
          A          := vTempStoredProc.GetParamIndex(vParamName);
          if A > -1 then begin
            if vTempStoredProc.Params[A].DataType in [ftFixedChar,ftFixedWideChar,ftString,ftWideString] then begin
              if vTempStoredProc.Params[A].Size > 0 then
                vTempStoredProc.Params[A].Value := Copy(Params[I].Value, 1, vTempStoredProc.Params[A].Size)
              else
                vTempStoredProc.Params[A].Value := Params[I].Value;
            end
            else begin
              if vTempStoredProc.Params[A].DataType in [ftUnknown] Then
                 vTempStoredProc.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue);
              vTempStoredProc.Params[A].Value    := Params[I].Value;
            end;
          end;
        end
        else
          Break;
      end;
    end;
    vTempStoredProc.ExecProc;

    connCommit;

    if not vStateResource Then
      Disconect;
  except
    on E : Exception do begin
      try
        if connInTransaction Then
          connRollback;
      except

      end;
      Error := True;
      MessageError := E.Message;
      Disconect;
   end;
 end;
 vTempStoredProc.Free;
end;

Procedure TRESTDWDriverBase.ExecuteProcedurePure(ProcName         : String;
                                                 Var Error        : Boolean;
                                                 Var MessageError : String);
Begin
 ExecuteProcedure(ProcName, nil, Error, MessageError);
End;

Procedure TRESTDWDriverBase.GetTableNames(Var TableNames   : TStringList;
                                          Var Error        : Boolean;
                                          Var MessageError : String);
Var
 vStateResource : Boolean;
 connType : TRESTDWDatabaseType;
 qry : TRESTDWQuery;
 vSchema : String;
 fdPos : integer;
Begin
 If Not Assigned(TableNames) Then
  TableNames := TStringList.Create;
 vSchema := '';
{
  if Pos('.', vTable) > 0 then begin
    vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
    Delete(vTable, InitStrPos, Pos('.', vTable));
  end;
}
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  fdPos := 0;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird : Begin
                   qry.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS');
                   qry.SQL.Add('ORDER BY RDB$RELATION_NAME');
                   qry.Open;
                  End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS');
                    qry.SQL.Add('ORDER BY RDB$RELATION_NAME');
                    qry.Open;
                   End;
    dbtMySQL     : Begin
                    qry.SQL.Add('SHOW TABLES');
                    qry.Open;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT N.NSPNAME || ''.'' || C.RELNAME');
                     qry.SQL.Add('FROM PG_CATALOG.PG_CLASS C');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = C.RELNAMESPACE');
                     qry.SQL.Add('WHERE C.RELKIND = ''r'' and N.NSPNAME <> ''information_schema'' and ');
                     qry.SQL.Add('      N.NSPNAME <> ''pg_catalog'' and N.NSPNAME <> ''dbo'' and ');
                     qry.SQL.Add('      N.NSPNAME <> ''sys'' and SUBSTR(C.RELNAME, 1, 3) <> ''pg_'' and');
                     If vSchema <> '' Then
                      qry.SQL.Add(' and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                    End;
    dbtSQLLite    : Begin
                     qry.SQL.Add('SELECT name FROM sqlite_master');
                     qry.SQL.Add('WHERE type=''table''');
                     qry.Open;
                    End;
    dbtMsSQL      : Begin
                     qry.SQL.Add('select concat(user_name(uid),''.'',name)');
                     qry.SQL.Add('from sysobjects');
                     qry.SQL.Add('where type in (''U'',''V'')');
                     qry.Open;
                    End;
    dbtOracle     : Begin
                     qry.SQL.Add('SELECT sys_context(''userenv'',''current_schema'') || ''.'' || table_name');
                     qry.SQL.Add('FROM USER_CATALOG');
                     qry.SQL.Add('WHERE TABLE_TYPE <> ''SEQUENCE''');
                     qry.Open;
                    End;

   End;
   While Not qry.Eof Do
    Begin
     TableNames.Add(qry.Fields[fdPos].AsString);
     qry.Next;
    End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Procedure TRESTDWDriverBase.GetFieldNames(TableName        : String;
                                          Var FieldNames   : TStringList;
                                          Var Error        : Boolean;
                                          Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWQuery;
 vTable,
 vSchema        : String;
 fPos           : Integer;
Begin
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 vSchema := '';
 vTable := TableName;
 If Pos('.', vTable) > 0 Then
  Begin
   vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
   Delete(vTable, InitStrPos, Pos('.', vTable));
  End;
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  fPos := 0;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS ');
                    qry.SQL.Add('WHERE RDB$RELATION_NAME='+QuotedStr(UpperCase(vTable)));
                    qry.Open;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT RDB$FIELD_NAME FROM RDB$RELATION_FIELDS ');
                    qry.SQL.Add('WHERE RDB$RELATION_NAME='+QuotedStr(UpperCase(vTable)));
                    qry.Open;
                   End;
    dbtMySQL     : Begin
                    qry.SQL.Add('SHOW COLUMNS FROM '+vTable);
                    qry.Open;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT A.ATTNAME');
                     qry.SQL.Add('FROM PG_CATALOG.PG_CLASS C');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = C.RELNAMESPACE');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_ATTRIBUTE A ON A.ATTRELID = C.OID');
                     qry.SQL.Add('WHERE A.ATTNUM > 0 AND NOT A.ATTISDROPPED AND');
                     qry.SQL.Add('      lower(C.RELNAME) = '+QuotedStr(LowerCase(vTable)));
                     If vSchema <> '' Then
                      qry.SQL.Add('    and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                    End;
    dbtSQLLite    : Begin
                     fPos := 1;
                     qry.SQL.Add('PRAGMA table_info('+vTable+')');
                     qry.Open;
                    End;
    dbtMsSQL      : Begin
                     qry.SQL.Add('select c.name');
                     qry.SQL.Add('from syscolumns c');
                     qry.SQL.Add('join sysobjects o on c.id=o.id');
                     qry.SQL.Add('where c.id=object_id('+QuotedStr(vTable)+')');
                     If vSchema <> '' Then
                      qry.SQL.Add('      and user_name(o.uid) = '+QuotedStr(vSchema));
                     qry.Open;
                    End;
    dbtOracle     : Begin
                     qry.SQL.Add('SELECT COLUMN_NAME');
                     qry.SQL.Add('FROM ALL_TAB_COLUMNS');
                     qry.SQL.Add('WHERE upper(TABLE_NAME) = '+QuotedStr(UpperCase(vTable)));
                     If vSchema <> '' Then
                      qry.SQL.Add('      and upper(OWNER) = '+QuotedStr(UpperCase(vSchema)));
                     qry.Open;
                    End;
   End;
   While Not qry.Eof Do
    Begin
     FieldNames.Add(qry.Fields[fPos].AsString);
     qry.Next;
    End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
end;

Procedure TRESTDWDriverBase.GetKeyFieldNames(TableName        : String;
                                             Var FieldNames   : TStringList;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWQuery;
 vTable,
 vSchema        : String;
Begin
 If Not Assigned(FieldNames) Then
  FieldNames := TStringList.Create;
 vSchema := '';
 vTable := TableName;
 If Pos('.', vTable) > 0     Then
  Begin
   vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
   Delete(vTable, InitStrPos, Pos('.', vTable));
  End;
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT S.RDB$FIELD_NAME');
                    qry.SQL.Add('FROM RDB$RELATION_CONSTRAINTS C, RDB$INDEX_SEGMENTS S');
                    qry.SQL.Add('WHERE C.RDB$RELATION_NAME = '+QuotedStr(AnsiUpperCase(vTable))+' AND');
                    qry.SQL.Add('      C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' AND');
                    qry.SQL.Add('      S.RDB$INDEX_NAME = C.RDB$INDEX_NAME');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      FieldNames.Add(qry.FieldByName('RDB$FIELD_NAME').AsString);
                      qry.Next;
                     End;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT S.RDB$FIELD_NAME');
                    qry.SQL.Add('FROM RDB$RELATION_CONSTRAINTS C, RDB$INDEX_SEGMENTS S');
                    qry.SQL.Add('WHERE C.RDB$RELATION_NAME = '+QuotedStr(AnsiUpperCase(vTable))+' AND');
                    qry.SQL.Add('      C.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' AND');
                    qry.SQL.Add('      S.RDB$INDEX_NAME = C.RDB$INDEX_NAME');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      FieldNames.Add(qry.FieldByName('RDB$FIELD_NAME').AsString);
                      qry.Next;
                     End;
                   End;
    dbtMySQL     : Begin
                    qry.SQL.Add('SHOW INDEX FROM '+vTable);
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      If (Pos('PRIMARY', UpperCase(qry.FieldByName('KEY_NAME').AsString)) > 0) Then
                       FieldNames.Add(qry.FieldByName('COLUMN_NAME').AsString);
                      qry.Next;
                     End;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT A.ATTNAME');
                     qry.SQL.Add('FROM PG_CATALOG.PG_INDEX I');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_CLASS TC ON TC.OID = I.INDRELID');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_CLASS IC ON IC.OID = I.INDEXRELID');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_ATTRIBUTE A ON A.ATTRELID = I.INDRELID AND');
                     qry.SQL.Add('           A.ATTNUM = ANY(I.INDKEY)');
                     qry.SQL.Add('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = TC.RELNAMESPACE');
                     qry.SQL.Add('WHERE lower(TC.RELNAME) = '+QuotedStr(LowerCase(vTable))+' and ');
                     qry.SQL.Add('      I.INDISPRIMARY ');
                     If vSchema <> '' Then
                      qry.SQL.Add('  AND lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                     While Not qry.Eof Do
                      Begin
                       FieldNames.Add(qry.FieldByName('ATTNAME').AsString);
                       qry.Next;
                      End;
                    End;
    dbtSQLLite    : Begin
                     qry.SQL.Add('PRAGMA table_info('+vTable+')');
                     qry.Open;
                     While Not qry.Eof Do
                      Begin
                       If qry.FieldByName('pk').AsInteger > 0 Then
                        FieldNames.Add(qry.FieldByName('name').AsString);
                       qry.Next;
                      End;
                    End;
   End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Procedure TRESTDWDriverBase.GetProcNames(Var ProcNames    : TStringList;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWQuery;
 vSchema        : String;
 fPos           : integer;
Begin
 If Not Assigned(ProcNames) Then
  ProcNames := TStringList.Create;
 vSchema := '';
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  fPos := 0;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT RDB$Procedure_NAME FROM RDB$ProcedureS');
                    qry.Open;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT RDB$Procedure_NAME FROM RDB$ProcedureS');
                    qry.Open;
                   End;
    dbtMySQL     : Begin
                    fPos := 1; // coluna name
                    qry.SQL.Add('SHOW Procedure STATUS');
                    qry.SQL.Add('WHERE db = DATABASE() AND type = ''Procedure''');
                    qry.Open;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('SELECT N.NSPNAME || ''.'' || P.PRONAME FROM PG_CATALOG.PG_PROC P');
                     qry.SQL.ADD('INNER JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = P.PRONAMESPACE');
                     qry.SQL.Add('WHERE P.PROARGNAMES IS NOT NULL');
                     If vSchema <> '' Then
                      qry.SQL.Add('    and lower(N.NSPNAME) = '+QuotedStr(LowerCase(vSchema)));
                     qry.Open;
                    End;
    dbtSQLLite    : Begin
                     // nao existe Procedures
                    End;
    dbtMsSQL      : Begin
                     qry.SQL.Add('select concat(user_name(uid),''.'',name)');
                     qry.SQL.Add('from sysobjects');
                     qry.SQL.Add('where type in (''P'',''FN'',''IF'',''TF'')');
                     qry.Open;
                    End;
    dbtOracle     : Begin
                     qry.SQL.Add('SELECT case ');
                     qry.SQL.Add('         when Procedure_NAME is null then OBJECT_NAME');
                     qry.SQL.Add('              ELSE OBJECT_NAME || ''.'' || Procedure_NAME');
                     qry.SQL.Add('       end AS Procedure_name');
                     qry.SQL.Add('FROM USER_ProcedureS');
                     qry.Open;
                    End;
   End;
   While Not qry.Eof Do
    Begin
     ProcNames.Add(qry.Fields[fPos].AsString);
     qry.Next;
    End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Procedure TRESTDWDriverBase.GetProcParams(ProcName         : String;
                                          Var ParamNames   : TStringList;
                                          Var Error        : Boolean;
                                          Var MessageError : String);
Var
 vStateResource : Boolean;
 connType       : TRESTDWDatabaseType;
 qry            : TRESTDWQuery;
 vProc,
 vSchema,
 vFieldType     : String;
 vSize,
 vPrecision     : Integer;
 Procedure convertFB_IBTypes;
 Begin
  vFieldType := 'ftUnknown';
  vSize := 0;
  vPrecision := 0;
  Case qry.FieldByName('rdb$field_type').AsInteger Of
   007 : Begin
          vFieldType := 'ftSmallint';
          If qry.FieldByName('rdb$field_sub_type').AsInteger > 0 Then
           vFieldType := 'ftFloat';
         End;
   008 : Begin
          vFieldType := 'ftInteger';
          If qry.FieldByName('rdb$field_sub_type').AsInteger > 0 Then
           vFieldType := 'ftFloat';
         End;
   009 : vFieldType := 'ftLargeint';
   010 : vFieldType := 'ftFloat';
   011 : vFieldType := 'ftFloat';
   012 : vFieldType := 'ftDateTime';
   013 : vFieldType := 'ftTime';
   014 : vFieldType := 'ftFixedChar';
   016 : Begin
          vFieldType := 'ftLargeint';
          If qry.FieldByName('rdb$field_sub_type').AsInteger > 0 Then
           vFieldType := 'ftFloat';
         End;
   027 : vFieldType := 'ftFloat';
   035 : vFieldType := 'ftTimeStamp';
   037 : vFieldType := 'ftString';
   040 : vFieldType := 'ftString';
   261 : Begin
          vFieldType := 'ftBlob';
          If qry.FieldByName('rdb$field_sub_type').AsInteger = 1   Then
           vFieldType := 'ftMemo';
         End;
  End;
  If qry.FieldByName('rdb$field_type').AsInteger in [14,37,40]     Then
   Begin
    vSize := qry.FieldByName('rdb$field_length').AsInteger;
      // field com charset e colation
    If (qry.FieldByName('rdb$character_length').AsInteger > 0)     And
       (qry.FieldByName('rdb$character_length').AsInteger < vSize) Then
        vSize := qry.FieldByName('rdb$character_length').AsInteger;
   End
  Else If qry.FieldByName('rdb$field_type').AsInteger = 27         Then
   Begin
    vSize := qry.FieldByName('rdb$field_precision').AsInteger;
    If (qry.FieldByName('rdb$field_scale').AsInteger < 0) Then
     Begin
      vSize := 15;
      If (qry.FieldByName('rdb$field_precision').AsInteger > 0) Then
       vSize := qry.FieldByName('rdb$field_precision').AsInteger;
      vPrecision := Abs(qry.FieldByName('rdb$field_scale').AsInteger);
     End;
   End
  Else If (qry.FieldByName('rdb$field_type').AsInteger    in [7,8,16]) And
          (qry.FieldByName('rdb$field_sub_type').AsInteger > 0)        Then
   Begin
    vSize := qry.FieldByName('rdb$field_precision').AsInteger;
    If (qry.FieldByName('rdb$field_scale').AsInteger < 0) Then
     Begin
      vSize := 15;
      If (qry.FieldByName('rdb$field_precision').AsInteger > 0) Then
       vSize := qry.FieldByName('rdb$field_precision').AsInteger;
      vPrecision := Abs(qry.FieldByName('rdb$field_scale').AsInteger);
     End;
   End;
 End;
 Procedure convertMySQLTypes;
 Var
  sAux1 : String;
 Begin
  vFieldType := 'ftUnknown';
  vSize      := 0;
  vPrecision := 0;
  sAux1      := LowerCase(qry.FieldByName('data_type').AsString);
  If SameText(sAux1, 'integer')        Or
     SameText(sAux1, 'int')            Then
   vFieldType := 'ftInteger'
  Else If SameText(sAux1, 'smallint')  Or
          SameText(sAux1, 'tinyint')   Or
          SameText(sAux1, 'mediumint') Or
          SameText(sAux1, 'bit')       Then
   vFieldType := 'ftSmallint'
  Else If SameText(sAux1, 'longint')   Or
          SameText(sAux1, 'bigint')    Then
   vFieldType := 'ftLargeint'
  Else If SameText(sAux1, 'real')      Or
          SameText(sAux1, 'decimal')   Or
          SameText(sAux1, 'numeric')   Or
          SameText(sAux1, 'float')     Or
          SameText(sAux1, 'double')    Or
          SameText(sAux1, 'double precision') Then
    Begin
     vFieldType := 'ftFloat';
     vSize      := qry.FieldByName('numeric_precision').AsInteger;
     vPrecision := qry.FieldByName('numeric_scale').AsInteger;
    End
   Else If SameText(sAux1, 'varchar') Then
    Begin
     vFieldType := 'ftString';
     vSize := qry.FieldByName('character_maximum_length').AsInteger;
     If vSize >= 32767 Then
      Begin
       vFieldType := 'ftMemo';
       vSize := 0;
      end;
    End
   Else If SameText(sAux1, 'char') Then
    Begin
     vFieldType := 'ftFixedChar';
     vSize := qry.FieldByName('character_maximum_length').AsInteger;
    End
   Else If SameText(sAux1, 'timestamp')  Then
    vFieldType := 'ftTimeStamp'
   Else if SameText(sAux1, 'time')       Then
    vFieldType := 'ftTime'
   Else If SameText(sAux1, 'datetime')   Then
    vFieldType := 'ftDateTime'
   Else If SameText(sAux1, 'date')       Then
    vFieldType := 'ftDate'
   Else If SameText(sAux1, 'year')       Then
    vFieldType := 'ftSmallint'
   Else If SameText(sAux1, 'blob')       Or
           SameText(sAux1, 'binary')     Or
           SameText(sAux1, 'tinyblob')   Or
           SameText(sAux1,'mediumblob')  Or
           SameText(sAux1,'longblob')    Then
    vFieldType := 'ftBlob'
   Else If SameText(sAux1,  'text')       Or
           SameText(sAux1,  'tinytext')   Or
           SameText(sAux1,  'mediumtext') Or
           SameText(sAux1,  'longtext')   Or
            SameText(sAux1, 'json')       Then
    vFieldType := 'ftMemo';
 End;
 Procedure convertPostgresTypes;
 Var
  sAux1 : String;
 Begin
  vFieldType := 'ftUnknown';
  vSize      := 0;
  vPrecision := 0;
  sAux1      := LowerCase(qry.FieldByName('data_type').AsString);
  If SameText(sAux1, 'integer') Or
     SameText(sAux1, 'int')     Or
    (Pos('int[',sAux1) > 0)     Then
   vFieldType := 'ftInteger'
  Else If SameText(sAux1, 'smallint')  Or
          SameText(sAux1, 'tinyint')   Or
          SameText(sAux1, 'mediumint') Or
          SameText(sAux1, 'bit')       Then
   vFieldType := 'ftSmallint'
  Else If (Pos('bigint', sAux1) > 0)   Then
   vFieldType := 'ftLargeint'
  Else If SameText(sAux1, 'real')    Or
          SameText(sAux1, 'decimal') Or
          SameText(sAux1, 'numeric') Or
          SameText(sAux1, 'float')   Or
          SameText(sAux1, 'double')  Or
          SameText(sAux1, 'double precision') Then
   Begin
    vFieldType := 'ftFloat';
    vSize := 15;
    vPrecision := 6;
   End
  Else If SameText(sAux1, 'varchar')           Or
         (Pos('character varying', sAux1) > 0) Then
   Begin
    vFieldType := 'ftString';
    vSize := 255;
   End
  Else If SameText(sAux1, 'character') Or
         (Pos('character[',sAux1) > 0) Then
   Begin
    vFieldType := 'ftFixedChar';
    vSize := 255;
   End
  Else If (Pos('timestamp', sAux1) > 0) Then
   vFieldType := 'ftTimeStamp'
  Else If SameText(sAux1, 'time')       Or
         (Pos('time with', sAux1) > 0)  Then
   vFieldType := 'ftTime'
  Else If SameText(sAux1, 'date')       Then
   vFieldType := 'ftDate'
  Else If (Pos(sAux1,'bytea') > 0) Then
   vFieldType := 'ftBlob'
  Else If (Pos(sAux1, 'text') > 0)  Or
          (Pos(sAux1, 'json') > 0)  Or
          (Pos(sAux1, 'xml')  > 0)  Then
   vFieldType := 'ftMemo';
 End;
Begin
 // nesta funcão pode ser usado as funcoes
 // getDatabaseInfo ou isMinimumVersion
 // para trazer informacao de versao de cada banco
 If Not Assigned(ParamNames) Then
  ParamNames := TStringList.Create;
 vSchema := '';
 vProc := ProcName;
 If Pos('.', vProc) > 0 Then
  Begin
   vSchema := Copy(vProc, InitStrPos, Pos('.', vProc)-1);
   Delete(vProc, InitStrPos, Pos('.', vProc));
  End;
 connType := getConectionType;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  qry := getQuery;
  Try
   Case connType Of
    dbtFirebird  : Begin
                    qry.SQL.Add('SELECT PP.RDB$PARAMETER_NAME, F.RDB$FIELD_LENGTH,');
                    qry.SQL.Add('       F.RDB$FIELD_TYPE, F.RDB$FIELD_SUB_TYPE,');
                    qry.SQL.Add('       F.RDB$CHARACTER_LENGTH, F.RDB$NULL_FLAG,');
                    qry.SQL.Add('       F.RDB$DEFAULT_SOURCE, CS.RDB$CHARACTER_SET_NAME,');
                    qry.SQL.Add('       CL.RDB$COLLATION_NAME, FD.RDB$LOWER_BOUND, FD.RDB$UPPER_BOUND');
                    qry.SQL.Add('FROM RDB$Procedure_PARAMETERS PP ');
                    qry.SQL.Add('INNER JOIN RDB$FIELDS F ON F.RDB$FIELD_NAME = PP.RDB$FIELD_SOURCE');
                    qry.SQL.Add('LEFT JOIN RDB$CHARACTER_SETS CS ON CS.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID');
                    qry.SQL.Add('LEFT JOIN RDB$COLLATIONS CL ON CL.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID AND');
                    qry.SQL.Add('     CL.RDB$COLLATION_ID = coalesce(F.RDB$COLLATION_ID,RF.RDB$COLLATION_ID)');
                    qry.SQL.Add('LEFT JOIN RDB$FIELD_DIMENSIONS FD ON FD.RDB$FIELD_NAME = F.RDB$FIELD_NAME');
                    qry.SQL.Add('WHERE PP.RDB$Procedure_NAME = '+QuotedStr(UpperCase(vProc))+' AND');
                    qry.SQL.Add('      PP.RDB$PARAMETER_TYPE = 0');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      convertFB_IBTypes;
                      ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                            vFieldType,vSize,vPrecision]));
                      qry.Next;
                     End;
                   End;
    dbtInterbase : Begin
                    qry.SQL.Add('SELECT PP.RDB$PARAMETER_NAME, F.RDB$FIELD_LENGTH,');
                    qry.SQL.Add('       F.RDB$FIELD_TYPE, F.RDB$FIELD_SUB_TYPE,');
                    qry.SQL.Add('       F.RDB$CHARACTER_LENGTH, F.RDB$NULL_FLAG,');
                    qry.SQL.Add('       F.RDB$DEFAULT_SOURCE, CS.RDB$CHARACTER_SET_NAME,');
                    qry.SQL.Add('       CL.RDB$COLLATION_NAME, FD.RDB$LOWER_BOUND, FD.RDB$UPPER_BOUND');
                    qry.SQL.Add('FROM RDB$Procedure_PARAMETERS PP ');
                    qry.SQL.Add('INNER JOIN RDB$FIELDS F ON F.RDB$FIELD_NAME = PP.RDB$FIELD_SOURCE');
                    qry.SQL.Add('LEFT JOIN RDB$CHARACTER_SETS CS ON CS.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID');
                    qry.SQL.Add('LEFT JOIN RDB$COLLATIONS CL ON CL.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID AND');
                    qry.SQL.Add('     CL.RDB$COLLATION_ID = coalesce(F.RDB$COLLATION_ID,RF.RDB$COLLATION_ID)');
                    qry.SQL.Add('LEFT JOIN RDB$FIELD_DIMENSIONS FD ON FD.RDB$FIELD_NAME = F.RDB$FIELD_NAME');
                    qry.SQL.Add('WHERE PP.RDB$Procedure_NAME = '+QuotedStr(UpperCase(vProc))+' AND');
                    qry.SQL.Add('      PP.RDB$PARAMETER_TYPE = 0');
                    qry.Open;
                    While Not qry.Eof Do
                     Begin
                      convertFB_IBTypes;
                      ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                            vFieldType,vSize,vPrecision]));
                      qry.Next;
                     End;
                   End;
    dbtMySQL     : Begin
                    // somente mysql maior que 5
                    qry.SQL.Add('SELECT parameter_name, data_type, character_maximum_length,');
                    qry.SQL.Add('       character_octet_length,numeric_precision,numeric_scale,');
                    qry.SQL.Add('       dtd_identifier');
                    qry.SQL.Add('FROM information_schema.parameters');
                    qry.SQL.Add('WHERE SPECIFIC_NAME = '+QuotedStr(vProc)+' AND');
                    qry.SQL.Add('      SPECIFIC_SCHEMA = DATABASE() and');
                    qry.SQL.Add('      ROUTINE_TYPE = ''Procedure'' and');
                    qry.SQL.Add('      PARAMETER_MODE = ''IN''');
                    Try
                     qry.Open;
                     While Not qry.Eof Do
                      Begin
                       convertMySQLTypes;
                       ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                             vFieldType,vSize,vPrecision]));

                       qry.Next;
                      End;
                    Except

                    End;
                   End;
    dbtPostgreSQL : Begin
                     qry.SQL.Add('select a.parameter_name, a.data_type');
                     qry.SQL.Add('from information_schema.routines p');
                     qry.SQL.Add('left join information_schema.parameters a on');
                     qry.SQL.Add('          p.specific_schema = a.specific_schema and');
                     qry.SQL.Add('          p.specific_name = a.specific_name');
                     qry.SQL.Add('where p.routine_schema not in (''pg_catalog'', ''information_schema'') and');
                     qry.SQL.Add('      p.routine_type = ''Procedure'' and');
                     qry.SQL.Add('      p.routine_name = '+QuotedStr(vProc)+' and');
                     qry.SQL.Add('      a.parameter_name is not null and');
                     qry.SQL.Add('      a.parameter_mode like ''IN%''');
                     If vSchema <> '' Then
                      qry.SQL.Add('    and p.specific_schema = '+QuotedStr(vSchema));
                     qry.SQL.Add('order by p.specific_schema, p.specific_name, p.routine_name,');
                     qry.SQL.Add('         a.ordinal_position');
                     Try
                      qry.Open;
                      While Not qry.Eof Do
                       Begin
                        convertPostgresTypes;
                        ParamNames.Add(Format(cParamDetails, [qry.Fields[0].AsString,
                                                              vFieldType,vSize,vPrecision]));

                        qry.Next;
                       End;
                     Except

                     End;
                    End;
    dbtSQLLite    : Begin
                     // sqlite nao tem Procedures
                    End;
   End;
  Finally
   FreeAndNil(qry);
  End;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception Do
   Begin
    Error          := True;
    MessageError   := E.Message;
    Disconect;
   End;
 End;
End;

Function TRESTDWDriverBase.InsertMySQLReturnID(SQL              : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String) : Integer;
Begin
 Result := InsertMySQLReturnID(SQL, Nil, Error, MessageError);
End;

Function TRESTDWDriverBase.InsertMySQLReturnID(SQL              : String;
                                               Params           : TRESTDWParams;
                                               var Error        : Boolean;
                                               var MessageError : String) : Integer;
Var
 vTempQuery     : TRESTDWQuery;
 A, I           : Integer;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 vStateResource : Boolean;
Begin
 Result := -1;
 Error  := False;
 vStringStream := Nil;
 If Not Assigned(FConnection) Then
  Exit;
 vTempQuery := getQuery;
 vStateResource := isConnected;
 If Not vStateResource Then
  Connect;
 If Not connInTransaction Then
  connStartTransaction;
 vTempQuery.SQL.Clear;
 vTempQuery.SQL.Add(SQL);
 If Params <> Nil Then
  Begin
   For I := 0 To Params.Count -1 Do
    Begin
     If vTempQuery.Params.Count > I Then
      Begin
       vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
       A := vTempQuery.GetParamIndex(vParamName);
       If A > -1 Then
        Begin
         If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                               ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                              ftString,    ftWideString]    Then
          Begin
           If vTempQuery.Params[A].Size > 0 Then
            vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
           Else
            vTempQuery.Params[A].Value := Params[I].Value;
          End
         Else
          Begin
           If vTempQuery.Params[A].DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
              vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
             Else
              vTempQuery.Params[A].DataType := ftString;
            End;
           If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLargeint] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              Begin
               If vTempQuery.Params[A].DataType = ftSmallInt Then
                vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
               Else
                vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
              End;
            End
           Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              vTempQuery.Params[A].AsFloat  := StrToFloat(Params[I].Value);
            End
           Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If Trim(Params[I].Value) <> '' Then
              Begin
               If vTempQuery.Params[A].DataType = ftDate Then
                vTempQuery.Params[A].AsDate     := Params[I].AsDateTime
               Else If vTempQuery.Params[A].DataType = ftTime Then
                vTempQuery.Params[A].AsTime     := Params[I].AsDateTime
               Else
                vTempQuery.Params[A].AsDateTime := Params[I].AsDateTime;
              End
             Else
              vTempQuery.Params[A].Clear
            End
           Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                     ftGraphic, ftOraBlob, ftOraClob,
                                                     ftMemo {$IFNDEF FPC}
                                                            {$IF CompilerVersion > 21}
                                                            , ftWideMemo
                                                            {$IFEND}
                                                            {$ENDIF}] Then
            Begin
             Try
              Params[I].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              If vStringStream.Size > 0 Then
               vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
             Finally
              If Assigned(vStringStream) Then
               FreeAndNil(vStringStream);
             End;
            End
           Else
            vTempQuery.Params[A].Value    := Params[I].Value;
          End;
        End;
      End
     Else
      Break;
    End;
  End;
 Result := -1;
 Error  := False;
 Try
  Try
   vTempQuery.ExecSQL;
   Result := vTempQuery.GetInsertID;
   Error := False;
   If connInTransaction Then
    connCommit;
  Finally
  End;
  If Not vStateResource Then
   Disconect
 Except
  On E : Exception Do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     Result       := -1;
     connRollback;
     Disconect;
    Except
    End;
   End;
 End;
 vTempQuery.Close;
 FreeAndNil(vTempQuery);
End;

Function TRESTDWDriverBase.OpenDatasets(DatasetsLine     : String;
                                        var Error        : Boolean;
                                        var MessageError : String;
                                        var BinaryBlob   : TMemoryStream): TJSONValue;
Var
 vTempQuery      : TRESTDWQuery;
 vTempJSON       : TJSONValue;
 vJSONLine       : String;
 I, X            : Integer;
 vMetaData,
 vBinaryEvent,
 vStateResource,
 vCompatibleMode : Boolean;
 DWParams        : TRESTDWParams;
 bJsonArray      : TRESTDWJSONInterfaceArray;
 bJsonValue      : TRESTDWJSONInterfaceObject;
 vStream         : TMemoryStream;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Error           := False;
 vBinaryEvent    := False;
 vMetaData       := False;
 vCompatibleMode := False;
 bJsonArray      := Nil;
 vTempQuery      := getQuery;
 Try
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  If Not connInTransaction Then
    connStartTransaction;
  bJsonValue  := TRESTDWJSONInterfaceObject.Create(DatasetsLine);
  For I := 0 To bJsonValue.PairCount - 1 Do
   Begin
    bJsonArray  := bJsonValue.OpenArray(I);
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vBinaryEvent    := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[2].Value);
    vMetaData       := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[3].Value);
    vCompatibleMode := StringToBoolean(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[4].Value);
    If bJsonArray.ElementCount > 1 Then
     Begin
      DWParams := TRESTDWParams.Create;
      Try
       DWParams.FromJSON(DecodeStrings(TRESTDWJSONInterfaceObject(bJsonArray).Pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
       For X := 0 To DWParams.Count -1 Do
        Begin
         If vTempQuery.ParamByName(DWParams[X].ParamName) <> Nil Then
          Begin
           vTempQuery.ParamByName(DWParams[X].ParamName).DataType := ObjectValueToFieldType(DWParams[X].ObjectValue);
           vTempQuery.ParamByName(DWParams[X].ParamName).Value    := DWParams[X].Value;
          End;
        End;
      Finally
       DWParams.Free;
      End;
     End;
    vTempQuery.Open;
    vTempJSON  := TJSONValue.Create;
    vTempJSON.Encoding := Encoding;
    vTempJSON.Utf8SpecialChars := True;
    If Not vBinaryEvent Then
     Begin
      vTempJSON.Utf8SpecialChars := True;
      vTempJSON.LoadFromDataset('RESULTDATA', TDataSet(vTempQuery.Owner), EncodeStringsJSON);
     End
    Else If vCompatibleMode Then
     TRESTDWClientSQLBase.SaveToStream(TDataSet(vTempQuery.Owner), vStream)
    Else
     Begin
      vStream := TMemoryStream.Create;
      Try
       vTempQuery.SaveToStream(vStream);
       vStream.Position := 0;
      Finally
      End;
     End;
    Try
     If Not vBinaryEvent Then
      Begin
       If Length(vJSONLine) = 0 Then
        vJSONLine := Format('%s', [vTempJSON.ToJSON])
       Else
        vJSONLine := vJSONLine + Format(', %s', [vTempJSON.ToJSON]);
      End
     Else
      Begin
       If Length(vJSONLine) = 0 Then
        vJSONLine := Format('{"BinaryRequest":"%s"}', [EncodeStream(vStream)])
       Else
        vJSONLine := vJSONLine + Format(', {"BinaryRequest":"%s"}', [EncodeStream(vStream)]);
       If Assigned(vStream) Then
        FreeAndNil(vStream);
      End;
    Finally
     vTempJSON.Free;
    End;
    FreeAndNil(bJsonArray);
   End;
  If connInTransaction Then
   connCommit;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception do
   Begin
    Disconect;
    Try
     Error          := True;
     MessageError   := E.Message;
     vJSONLine      := GetPairJSONStr('NOK', MessageError);
    Except
    End;
   End;
 End;
 Result             := TJSONValue.Create;
 Result.Encoding    := Encoding;
 Result.ObjectValue := ovString;
 Try
  vJSONLine         := Format('[%s]', [vJSONLine]);
  Result.SetValue(vJSONLine, EncodeStringsJSON);
 Finally

 End;
 vTempQuery.Close;
 vTempQuery.Free;
 If bJsonValue <> Nil Then
  FreeAndNil(bJsonValue);
End;

Function TRESTDWDriverBase.OpenDatasets(DatapackStream        : TStream;
                                        Var Error             : Boolean;
                                        Var MessageError      : String;
                                        Var BinaryBlob        : TMemoryStream;
                                        aBinaryEvent          : Boolean;
                                        aBinaryCompatibleMode : Boolean): TStream;
Var
 X               : Integer;
 vTempQuery      : TRESTDWQuery;
 vStateResource  : Boolean;
 DWParams        : TRESTDWParams;
 BufferOutStream,
 BufferStream,
 BufferInStream  : TRESTDWBufferBase;
 vStream         : TMemoryStream;
 vSqlStream      : TRESTDWBytes;
 vBufferStream,
 vParamsStream   : TStream;
Begin
 {$IFNDEF FPC}Inherited;{$ENDIF}
 Result          := Nil;
 Error           := False;
 BufferInStream  := TRESTDWBufferBase.Create;
 BufferOutStream := TRESTDWBufferBase.Create;
 vTempQuery      := getQuery;
 Try
  BufferInStream.LoadToStream(DatapackStream);
  vStateResource := isConnected;
  If Not vStateResource Then
   Connect;
  If Not connInTransaction Then
   connStartTransaction;
  While Not BufferInStream.Eof Do
   Begin
    BufferStream  := Nil;
    vBufferStream := BufferInStream.ReadStream;
    Try
     If Not Assigned(vBufferStream) Then
      Continue;
     BufferStream := TRESTDWBufferBase.Create;
     BufferStream.LoadToStream(vBufferStream);
     vSqlStream    := BufferStream.ReadBytes;
     vParamsStream := TMemoryStream(BufferStream.ReadStream);
    Finally
     If Assigned(BufferStream)  Then
      FreeAndNil(BufferStream);
     If Assigned(vBufferStream) Then
      FreeAndNil(vBufferStream);
    End;
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(BytesToString(vSqlStream));
    SetLength(vSqlStream, 0);
    DWParams := TRESTDWParams.Create;
    Try
     DWParams.LoadFromStream(vParamsStream);
     For X := 0 To DWParams.Count - 1 Do
      Begin
       If vTempQuery.ParamByName(DWParams[X].ParamName) <> Nil Then
        Begin
         vTempQuery.ParamByName(DWParams[X].ParamName).DataType := ObjectValueToFieldType(DWParams[X].ObjectValue);
         vTempQuery.ParamByName(DWParams[X].ParamName).Value    := DWParams[X].Value;
        End;
      End;
    Finally
     DWParams.Free;
     If Assigned(vParamsStream) Then
      FreeAndNil(vParamsStream);
    End;
    vTempQuery.Open;
    vStream := Nil;
    If aBinaryCompatibleMode Then
     TRESTDWClientSQLBase.SaveToStream(TDataSet(vTempQuery.Owner), vStream)
    Else
     Begin
      vStream := TMemoryStream.Create;
      Try
       vTempQuery.SaveToStream(vStream);
       vStream.Position := 0;
      Finally
      End;
     End;
    //Gera o Binario
    Try
     BufferOutStream.InputStream(vStream);
    Finally
    If Assigned(vStream) Then
     FreeAndNil(vStream);
    End;
   End;
  If connInTransaction Then
   connCommit;
  If Not vStateResource Then
   Disconect;
 Except
  On E : Exception do
   Begin
    Disconect;
    Try
     Error          := True;
     MessageError   := E.Message;
    Except
    End;
   End;
 End;
 FreeAndNil(BufferInStream);
 BufferOutStream.SaveToStream(Result);
 FreeAndNil(BufferOutStream);
 vTempQuery.Close;
 vTempQuery.Free;
end;

Class Procedure TRESTDWDriverBase.CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                                   Var AConnection       : TComponent);
Begin
 If (Not Assigned(AConnection))     Or
    (Not Assigned(AConnectionDefs)) Then
  Exit;
End;

Procedure TRESTDWDriverBase.PrepareConnection(Var AConnectionDefs : TConnectionDefs);
Begin
 If Assigned(OnPrepareConnection) Then
  OnPrepareConnection(AConnectionDefs);
 If (Not Assigned(FConnection))     Or
    (Not Assigned(AConnectionDefs)) Then
  Exit;
 CreateConnection(AConnectionDefs,FConnection);
End;

Procedure TRESTDWDriverBase.BuildDatasetLine(var Query: TRESTDWDataset;
                            Massivedataset: TMassivedatasetBuffer;
                            MassiveCache: Boolean);
Var
 I, A              : Integer;
 vMasterField,
 vTempValue        : String;
 vStringStream     : TMemoryStream;
 MassiveField      : TMassiveField;
 MassiveReplyValue : TMassiveReplyValue;
 MassiveReplyCache : TMassiveReplyCache;
Begin
 vTempValue    := '';
 vStringStream := Nil;
 If Massivedataset.MassiveMode = mmUpdate Then
  Begin
   For I := 0 To Massivedataset.AtualRec.UpdateFieldChanges.Count -1 Do
    Begin
     MassiveField  := MassiveDataset.Fields.FieldByName(Massivedataset.AtualRec.UpdateFieldChanges[I]);
     If (Lowercase(MassiveField.FieldName) = Lowercase(RESTDWFieldBookmark)) then
      Continue;
     If (MassiveField <> Nil) Then
      Begin
       If MassiveField.IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveField.Value;
       If MassiveCache Then
        Begin
         If (MassiveField.KeyField) And (Not (MassiveField.ReadOnly)) Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveField.IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, MassiveField.OldValue, MassiveField.Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, Null, MassiveField.OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, Null);
              End;
             If Not MassiveField.IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             If Not MassiveField.IsNull Then
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue)
             Else
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveField.FieldName;
               If Not MassiveField.IsNull Then
                MassiveReplyValue.OldValue := MassiveField.Value
               Else
                MassiveReplyValue.OldValue := MassiveField.OldValue;
               MassiveReplyValue.NewValue  := Null;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End
             Else
              Begin
               MassiveField.Value := MassiveReplyValue.NewValue;
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveField.IsNull Then
            vTempValue := MassiveField.Value;
          End;
        End;
       If ((vTempValue = 'null')  Or
           (Query.FieldByName(MassiveField.FieldName).ReadOnly) Or
           (MassiveField.IsNull)) Then
        Begin
         If Not (Query.FieldByName(MassiveField.FieldName).ReadOnly) Then
          Query.FieldByName(MassiveField.FieldName).Clear;
         Continue;
        End;
       If MassiveField.IsNull Then
        Continue;
       If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                 ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                 ftString,    ftWideString,
                                                                 ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                         {$IF CompilerVersion > 21}
                                                                                 , ftWideMemo
                                                                          {$IFEND}
                                                                         {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And (vTempValue <> '') And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.FieldByName(MassiveField.FieldName).Size > 0 Then
            Query.FieldByName(MassiveField.FieldName).AsString := Copy(vTempValue, 1, Query.FieldByName(MassiveField.FieldName).Size)
           Else
            Query.FieldByName(MassiveField.FieldName).AsString := vTempValue;
          End
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End
       Else
        Begin
         If Query.FieldByName(MassiveField.FieldName).DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).Value := vTempValue
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.FieldByName(MassiveField.FieldName).FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}
                    Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                  {$ELSE}
                    Query.FieldByName(MassiveField.FieldName).AsInteger := StrToInt64(vTempValue);
                  {$IFEND}
                 {$ELSE}
                   Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.FieldByName(MassiveField.FieldName).AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsFloat  := StrToFloat(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                        ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.FieldByName(MassiveField.FieldName)).LoadFromStream(vStringStream);
             End
            Else
             Query.FieldByName(MassiveField.FieldName).Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Query.FieldByName(MassiveField.FieldName).Value := vTempValue
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End;
      End;
    End;
  End
 Else
  Begin
   For I := 0 To Query.Fields.Count -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName) <> Nil) Then
      Begin
       If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
        Begin
         A := -1;
         If (MassiveDataset.SequenceName <> '') Then
          A := GetGenID(TRESTDWQuery(Query),MassiveDataset.SequenceName);
         If A > -1 Then
          Query.Fields[I].Value := A;
         Continue;
        End
       Else If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).isNull) Or
               (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly) Then
        Begin
         If ((Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly)) And
             (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue))) Then
          Query.Fields[I].Clear;
         Continue;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       If MassiveCache Then
        Begin
         If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).KeyField Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          Null,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              Null);
              End;
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                                                                                            MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName;
               MassiveReplyValue.OldValue  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
               MassiveReplyValue.NewValue  := MassiveReplyValue.OldValue;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               vTempValue                  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
              End;
            End;
           vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
           If vMasterField <> '' Then
            Begin
             MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue <> Nil Then
              vTempValue := MassiveReplyValue.NewValue;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
               If vMasterField = '' Then
                vMasterField := Query.Fields[I].FieldName;
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
            vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
          End;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        Continue;
       If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                             ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                             ftString,    ftWideString,
                             ftMemo, ftFmtMemo {$IFNDEF FPC}
                                     {$IF CompilerVersion > 21}
                                      , ftWideMemo
                                     {$IFEND}
                                    {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.Fields[I].Size > 0 Then
            Query.Fields[I].AsString := Copy(vTempValue, 1, Query.Fields[I].Size)
           Else
            Query.Fields[I].AsString := vTempValue;
          End
         Else
          Query.Fields[I].Clear;
        End
       Else
        Begin
         If Query.Fields[I].DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.Fields[I].Value := vTempValue
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.Fields[I].FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}Query.Fields[I].AsLargeInt := StrToInt64(vTempValue)
                  {$ELSE} Query.Fields[I].AsInteger                    := StrToInt64(vTempValue)
                  {$IFEND}
                 {$ELSE}
                  Query.Fields[I].AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.Fields[I].AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle, ftExtended{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsFloat := StrToFloat(BuildFloatString(vTempValue))
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.Fields[I].Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                              ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.Fields[I]).LoadFromStream(vStringStream);
             End
            Else
             Query.Fields[I].Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Value := vTempValue;
          End
         Else
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Clear;
          End;
        End;
      End;
    End;
  End;
End;

End.
