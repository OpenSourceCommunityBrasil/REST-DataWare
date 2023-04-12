unit FireDAC.Phys.RESTDWBase;

{$I ..\Includes\uRESTDW.inc}

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
  Fernando Banhos            - Drivers e Datasets.
}

interface

uses
  Classes, SysUtils, FireDAC.Phys, FireDAC.Stan.Intf, FireDAC.Phys.Intf,
  FireDAC.Phys.SQLGenerator, FireDAC.Stan.Util, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.Stan.Option, Variants, uRESTDWProtoTypes,
  uRESTDWBasicDB, DB, uRESTDWPoolermethod, FireDAC.Phys.RESTDWMeta,
  uRESTDWBasicTypes, FireDAC.Stan.Error, FireDAC.Stan.Consts,
  uRESTDWMassiveBuffer;

type
  TFDPhysRDWConnectionBase = class;

  TFDPhysRDWException = class(EFDDBEngineException)
  public
    constructor Create(AObj: TObject; AMsg: string);
  end;

  TFDPhysRDWBaseDriverLink = class(TFDPhysDriverLink)
  private
    FDatabase: TRESTDWDatabasebaseBase;
    FRDBMS: TFDRDBMSKind;
  protected
    function GetBaseDriverID: String; override;
    function IsConfigured: Boolean; override;
  published
    property Database: TRESTDWDatabasebaseBase read FDatabase write FDatabase;
    property RDBMS: TFDRDBMSKind read FRDBMS write FRDBMS;
  end;

  TFDPhysRDWDriverBase = class(TFDPhysDriver)
  protected
    procedure InternalLoad; override;
    procedure InternalUnload; override;
  public
    constructor Create(AManager: TFDPhysManager;
      const ADriverDef: IFDStanDefinition); override;
    destructor Destroy; override;
  end;

  TFDPhysRDWConnectionBase = class(TFDPhysConnection)
  private
    FDatabase: TRESTDWDatabasebaseBase;
    FMassiveSQL: TRESTDWMassiveSQLCache;
    FIntransaction: Boolean;
    procedure findDatabase;
  protected
    procedure InternalConnect; override;
    procedure InternalDisconnect; override;
    function InternalCreateMetadata: TObject; override;
    function InternalCreateTransaction: TFDPhysTransaction; override;
    function InternalCreateCommand: TFDPhysCommand; override;
    function InternalCreateCommandGenerator(const ACommand: IFDPhysCommand)
      : TFDPhysCommandGenerator; override;
    procedure InternalExecuteDirect(const ASQL: String;
      ATransaction: TFDPhysTransaction); override;
  public
    constructor Create(ADriverObj: TFDPhysDriver;
      AConnHost: TFDPhysConnectionHost); override;
    destructor Destroy; override;
    procedure SendMassive(Var Error: Boolean; Var MessageError: String);
    procedure ClearMassive;
    function findRESTDWLink: TFDPhysRDWBaseDriverLink;
  published
    property Database: TRESTDWDatabasebaseBase read FDatabase;
    property MassiveSQL: TRESTDWMassiveSQLCache read FMassiveSQL;
    property Intransaction: Boolean read FIntransaction write FIntransaction;
  end;

  TFDPhysRDWTransaction = class(TFDPhysTransaction)
  protected
    procedure InternalStartTransaction(AID: LongWord); override;
    procedure InternalCommit(AID: LongWord); override;
    procedure InternalRollback(AID: LongWord); override;
  end;

  TFDPhysRDWCommand = class(TFDPhysCommand)
  private
    FStream: TMemoryStream;
    FColumnIndex: integer;
    FEncodeStrs: Boolean;
    FFieldCount: integer;
    FRecordCount: int64;
    FFieldTypes: array of integer;
    FInfoMetada: TStringList;
    procedure FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
    procedure FetchMetaRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow;
      ARow: integer);
    function readFieldStream: TFDPhysDataColumnInfo;
    function readDataStream(col: integer): Variant;
    procedure readStreamFields;
    function RDWExecuteComand(exec: Boolean = False): Longint;
    function RDWGetTables: integer;
    function RDWGetTablesFields(tabela: string): integer;
    function RDWGetPKTablesFields(tabela: string): integer;
    function RestDWConnection: TFDPhysRDWConnectionBase;
  protected
    procedure InternalPrepare; override;
    procedure InternalUnprepare; override;
    function InternalOpen{$IFDEF DELPHI10_3UP}(var ACount: TFDCounter){$ENDIF}: Boolean; override;
    function InternalNextRecordSet: Boolean; override;
    procedure InternalClose; override;
    procedure InternalExecute(ATimes, AOffset: integer;
      var ACount: TFDCounter); override;
    function InternalColInfoStart(var ATabInfo: TFDPhysDataTableInfo)
      : Boolean; override;
    function InternalColInfoGet(var AColInfo: TFDPhysDataColumnInfo)
      : Boolean; override;
    function InternalFetchRowSet(ATable: TFDDatSTable; AParentRow: TFDDatSRow;
      ARowsetSize: LongWord): LongWord; override;
  public
    constructor Create(AConnection: TFDPhysConnection);
    destructor Destroy; override;
  end;

const
  // nao mude o conteudo dessa variavel, ela influencia da adicão automatica
  // da unit FireDAC.Phys.{RESTDW}Def no projeto
  S_FD_RDWId = 'RESTDW';

implementation

uses
  FireDAC.Phys.RESTDWDef, Data.SqlTimSt, uRESTDWParams, uRESTDWConsts,
  uRESTDWTools, FmtBCD;

resourcestring
  errSQLEmpty = 'Empty SQL command';

  { TFDPhysRDWDriverBase }
constructor TFDPhysRDWDriverBase.Create(AManager: TFDPhysManager;
  const ADriverDef: IFDStanDefinition);
begin
  inherited Create(AManager, ADriverDef);
end;

destructor TFDPhysRDWDriverBase.Destroy;
begin
  inherited;
end;

procedure TFDPhysRDWDriverBase.InternalLoad;
begin
  inherited;
end;

procedure TFDPhysRDWDriverBase.InternalUnload;
begin
  inherited;
end;

{ TFDPhysRDWConnectionBase }
procedure TFDPhysRDWConnectionBase.ClearMassive;
begin
  FMassiveSQL.Clear;
end;

constructor TFDPhysRDWConnectionBase.Create(ADriverObj: TFDPhysDriver;
  AConnHost: TFDPhysConnectionHost);
begin
  inherited;
  FDatabase := nil;
  FMassiveSQL := TRESTDWMassiveSQLCache.Create(nil);
  FIntransaction := False;
end;

destructor TFDPhysRDWConnectionBase.Destroy;
begin
  FMassiveSQL.Free;
  if Assigned(FDatabase) then
    FDatabase.Close;
  FDatabase := nil;
  inherited;
end;

procedure TFDPhysRDWConnectionBase.findDatabase;
var
  rdwDriver: TFDPhysRDWBaseDriverLink;
begin
  rdwDriver := findRESTDWLink;
  if Assigned(rdwDriver) then
    FDatabase := rdwDriver.Database;
end;

function TFDPhysRDWConnectionBase.findRESTDWLink: TFDPhysRDWBaseDriverLink;
begin
  Result := TFDPhysRDWBaseDriverLink
    (DriverObj.Manager.FindDriverLink(DriverObj.DriverID));
end;

procedure TFDPhysRDWConnectionBase.InternalConnect;
begin
  if not Assigned(FDatabase) then
    findDatabase;
  if not Assigned(FDatabase) then
    raise Exception.Create(cErrorDataSetNotDefined);
  FDatabase.Active := True;
end;

function TFDPhysRDWConnectionBase.InternalCreateCommand: TFDPhysCommand;
begin
  Result := TFDPhysRDWCommand.Create(Self);
end;

function TFDPhysRDWConnectionBase.InternalCreateCommandGenerator
  (const ACommand: IFDPhysCommand): TFDPhysCommandGenerator;
begin
  if Assigned(ACommand) then
    Result := TFDPhysRDWCommandGenerator.Create(ACommand)
  else
    Result := TFDPhysRDWCommandGenerator.Create(Self);
end;

function TFDPhysRDWConnectionBase.InternalCreateMetadata: TObject;
begin
  Result := TFDPhysRDWMetadata.Create(Self, 1, 0, False);
end;

function TFDPhysRDWConnectionBase.InternalCreateTransaction: TFDPhysTransaction;
begin
  Result := TFDPhysRDWTransaction.Create(Self);
end;

procedure TFDPhysRDWConnectionBase.InternalDisconnect;
begin
  if Assigned(FDatabase) then
    FDatabase.Active := False;
  FDatabase := nil;
  inherited;
end;

procedure TFDPhysRDWConnectionBase.InternalExecuteDirect(const ASQL: String;
  ATransaction: TFDPhysTransaction);
begin
  inherited;
end;

procedure TFDPhysRDWConnectionBase.SendMassive(Var Error: Boolean;
  Var MessageError: String);
begin
  Error := False;
  MessageError := '';

  if not FIntransaction then
    Exit;

  if FMassiveSQL.MassiveCount > 0 then
    FDatabase.ProcessMassiveSQLCache(FMassiveSQL, Error, MessageError);
end;

{ TFDPhysRDWTransaction }
procedure TFDPhysRDWTransaction.InternalCommit(AID: LongWord);
var
  vError: Boolean;
  vMessageError: string;
begin
  inherited;
  if ConnectionObj.InheritsFrom(TFDPhysRDWConnectionBase) then
  begin
    TFDPhysRDWConnectionBase(ConnectionObj).SendMassive(vError, vMessageError);
    if vError then
    begin
      raise TFDPhysRDWException.Create(Self, vMessageError);
    end
    else
    begin
      TFDPhysRDWConnectionBase(ConnectionObj).Intransaction := False;
    end;
  end;
end;

procedure TFDPhysRDWTransaction.InternalRollback(AID: LongWord);
begin
  inherited;
  if ConnectionObj.InheritsFrom(TFDPhysRDWConnectionBase) then
  begin
    TFDPhysRDWConnectionBase(ConnectionObj).ClearMassive;
    TFDPhysRDWConnectionBase(ConnectionObj).Intransaction := False;
  end;
end;

procedure TFDPhysRDWTransaction.InternalStartTransaction(AID: LongWord);
begin
  inherited;
  if ConnectionObj.InheritsFrom(TFDPhysRDWConnectionBase) then
    TFDPhysRDWConnectionBase(ConnectionObj).Intransaction := True;
end;

{ TFDPhysRDWCommand }
constructor TFDPhysRDWCommand.Create(AConnection: TFDPhysConnection);
begin
  inherited Create(AConnection);
  FStream := TMemoryStream.Create;
  FInfoMetada := TStringList.Create;
end;

destructor TFDPhysRDWCommand.Destroy;
begin
  FInfoMetada.Free;
  FStream.Free;
  inherited;
end;

procedure TFDPhysRDWCommand.FetchMetaRow(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow; ARow: integer);
var
  // oCol    : TFDDatSColumn;
  oRow: TFDDatSRow;
  j: integer;
  oFmtOpts: TFDFormatOptions;
  sSchema, sTable: string;
  // ss : TStringList;
begin
  oFmtOpts := GetOptions.FormatOptions;
  {
    ss := TStringList.Create;
    for j := 0 to ATable.Columns.Count - 1 do begin
    oCol := ATable.Columns[j];
    ss.Add(oCol.Name);
    end;
    ss.SaveToFile('d:\cols.txt');
  }

  try
    oRow := ATable.NewRow(True);
    if GetMetaInfoKind = mkPrimaryKeyFields then
    begin
      oRow.SetData(0, ARow); // RECNO
      oRow.SetData(1, null); // CATALOG_NAME
      oRow.SetData(2, null); // SCHEMA_NAME
      oRow.SetData(3, GetBaseObjectName); // TABLE_NAME
      oRow.SetData(4, null); // INDEX_NAME
      oRow.SetData(5, FInfoMetada.Strings[ARow]); // CONSTRAINT_NAME
      oRow.SetData(6, ARow); // INDEX_TYPE
      oRow.SetData(7, null); // INDEX_TYPE
      oRow.SetData(8, null); // INDEX_TYPE
    end
    else if GetMetaInfoKind = mkTables then
    begin
      sSchema := '';
      sTable := FInfoMetada.Strings[ARow];
      j := Pos('.', sTable);
      if j > 0 then
      begin
        sSchema := Copy(sTable, 1, j - 1);
        Delete(sTable, 1, j);
      end;

      oRow.SetData(0, ARow); // RECNO
      oRow.SetData(1, null); // CATALOG_NAME
      if sSchema <> '' then
        oRow.SetData(2, sSchema) // SCHEMA_NAME
      else
        oRow.SetData(2, null); // SCHEMA_NAME
      oRow.SetData(3, sTable); // TABLE_NAME
      oRow.SetData(4, tkTable); // TABLE_TYPE
      oRow.SetData(5, osMy); // SCOPE_TYPE
    end
    else if GetMetaInfoKind = mkTableFields then
    begin
      oRow.SetData(0, ARow); // RECNO
      oRow.SetData(1, null); // CATALOG_NAME
      oRow.SetData(2, null); // SCHEMA_NAME
      oRow.SetData(3, GetBaseObjectName); // TABLE_NAME
      oRow.SetData(4, FInfoMetada.Strings[ARow]); // COLUMN_NAME
      oRow.SetData(5, ARow); // COLUMN_POSITION
      oRow.SetData(6, null); // COLUMN_DATATYPE
      oRow.SetData(7, null); // COLUMN_TYPENAME
      oRow.SetData(8, null); // COLUMN_ATTRIBUTES
      oRow.SetData(9, null); // COLUMN_PRECISION
      oRow.SetData(10, null); // COLUMN_SCALE
      oRow.SetData(11, null); // COLUMN_LENGTH
    end;
    ATable.Rows.Add(oRow);
  except
    FDFree(oRow);
    raise Exception.Create(IntToStr(j));
  end;
end;

procedure TFDPhysRDWCommand.FetchRow(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow);
var
  oCol: TFDDatSColumn;
  oRow: TFDDatSRow;
  j: integer;
  pData: Variant;
  oFmtOpts: TFDFormatOptions;
begin
  oRow := ATable.NewRow(True);
  oFmtOpts := GetOptions.FormatOptions;
  try
    for j := 0 to ATable.Columns.Count - 1 do
    begin
      oCol := ATable.Columns[j];
      if (oCol.SourceID >= 0) and CheckFetchColumn(oCol.SourceDataType,
        oCol.Attributes) then
      begin
        pData := readDataStream(j);
        oRow.SetData(j, pData);
      end;
    end;
    ATable.Rows.Add(oRow);
  except
    FDFree(oRow);
    raise Exception.Create(IntToStr(j));
  end;
end;

procedure TFDPhysRDWCommand.InternalClose;
begin
  FStream.Size := 0;
  FInfoMetada.Clear;
end;

function TFDPhysRDWCommand.InternalColInfoGet(var AColInfo
  : TFDPhysDataColumnInfo): Boolean;
var
  vBoolean : Boolean;
begin
  if GetMetaInfoKind <> mkNone then
  begin
    Result := False;
    Exit;
  end;
  if FStream.Size = 0 then
  begin
    Result := False;
    Exit;
  end;
  if FFieldCount = -1 then
  begin
    FStream.Position := 0;
    FStream.Read(FFieldCount, SizeOf(integer));
    SetLength(FFieldTypes, FFieldCount);
    FStream.Read(vBoolean, SizeOf(vBoolean));
    FEncodeStrs := vBoolean;
  end;
  if FColumnIndex >= FFieldCount then
  begin
    Result := False;
    Exit;
  end;
  AColInfo := readFieldStream;
  FColumnIndex := FColumnIndex + 1;
  Result := True;
end;

function TFDPhysRDWCommand.InternalColInfoStart(var ATabInfo
  : TFDPhysDataTableInfo): Boolean;
begin
  Result := OpenBlocked;
  if Result then
  begin
    if ATabInfo.FSourceID = -1 then
    begin
      ATabInfo.FSourceName := GetCommandText;
      ATabInfo.FSourceID := 1;
      FColumnIndex := 0;
      FFieldCount := -1;
      FRecordCount := -1;
    end
    else
    begin
      raise Exception.Create('TFDPhysRDWCommand.InternalColInfoStart');
      ATabInfo.FSourceID := ATabInfo.FSourceID;
    end;
  end;
end;

procedure TFDPhysRDWCommand.InternalExecute(ATimes, AOffset: integer;
  var ACount: TFDCounter);
begin
  ACount := RDWExecuteComand(True);
end;

function TFDPhysRDWCommand.InternalFetchRowSet(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow; ARowsetSize: LongWord): LongWord;
var
  i: LongWord;
begin
  Result := 0;
  if GetMetaInfoKind in [mkTables, mkTableFields, mkPrimaryKeyFields] then
  begin
    ARowsetSize := FInfoMetada.Count;
    for i := 1 to ARowsetSize do
    begin
      FetchMetaRow(ATable, AParentRow, i - 1);
      Inc(Result);
    end
  end
  else if GetMetaInfoKind = mkNone then
  begin
    if FRecordCount = -1 then
    begin
      if FStream.Position = 0 then
        readStreamFields;
      FStream.Read(FRecordCount, SizeOf(int64));
    end;
    for i := 1 to ARowsetSize do
    begin
      if FStream.Position = FStream.Size then
        FStream.Size := 0;
      if FStream.Size = 0 then
        Break;
      FetchRow(ATable, AParentRow);
      Inc(Result);
    end
  end;
end;

function TFDPhysRDWCommand.InternalNextRecordSet: Boolean;
begin
  Result := False;
end;

function TFDPhysRDWCommand.InternalOpen{$IFDEF DELPHI10_3UP}(var ACount: TFDCounter){$ENDIF}: Boolean;
begin
  {$IFDEF DELPHI10_3UP}
  ACount := -1;
  {$ENDIF}
  Result := False;
  case GetMetaInfoKind of
    mkNone:
      begin
        {$IFDEF DELPHI10_3UP}
        ACount := RDWExecuteComand;
        Result := ACount >= 0;
        {$ELSE}
        Result := RDWExecuteComand >= 0;
        {$ENDIF}
      end;
    mkTables:
      begin
        {$IFDEF DELPHI10_3UP}
        ACount := RDWGetTables;
        Result := ACount >= 0;
        {$ELSE}
        Result := RDWGetTables >= 0;
        {$ENDIF}
        if Result then
          Self.SetState(csOpen);
      end;
    mkPrimaryKeyFields:
      begin
        {$IFDEF DELPHI10_3UP}
        ACount := RDWGetPKTablesFields(GetBaseObjectName);
        Result := ACount >= 0;
        {$ELSE}
        Result := RDWGetPKTablesFields(GetBaseObjectName) >= 0;
        {$ENDIF}
        if Result then
          Self.SetState(csOpen);
      end;
    mkTableFields:
      begin
        {$IFDEF DELPHI10_3UP}
        ACount := RDWGetTablesFields(GetBaseObjectName);
        Result := ACount >= 0;
        {$ELSE}
        Result := RDWGetTablesFields(GetBaseObjectName) >= 0;
        {$ENDIF}
        if Result then
          Self.SetState(csOpen);
      end;
  end;
end;

procedure TFDPhysRDWCommand.InternalPrepare;
// var
// rName: TFDPhysParsedName;
begin
  {
    if GetMetaInfoKind <> mkNone then begin
    if GetCommandKind = skUnknown then
    SetCommandKind(skSelect);
    GetSelectMetaInfoParams(rName);
    GenerateSelectMetaInfo(rName);
    end;
    GenerateLimitSelect();
    GenerateParamMarkers();
  }
end;

procedure TFDPhysRDWCommand.InternalUnprepare;
begin
  inherited;
end;

function TFDPhysRDWCommand.RDWExecuteComand(exec: Boolean): Longint;
var
  sSQL: string;
  vSQL: TStringList;
  vRESTDataBase: TRESTDWDatabasebaseBase;
  vParams: TParams;
  vError: Boolean;
  vMessageError: string;
  vDataSetList: TJSONValue;
  vRowsAffected: integer;
  vPoolermethod: TRESTDWPoolerMethodClient;
  vMassiveCache: TRESTDWMassiveCacheSQLValue;
  procedure addParams(AFDParams: TFDParams);
  var
    i: integer;
  begin
    for i := 0 to AFDParams.Count - 1 do
    begin
      with vParams.AddParameter do
      begin
        Name := AFDParams[i].Name;
        DataType := AFDParams[i].DataType;
        ParamType := AFDParams[i].ParamType;
        Size := AFDParams[i].Size;
        Value := AFDParams[i].Value;
      end;
    end;
  end;

begin
  Result := -1;
  sSQL := GetCommandText;
  if Trim(sSQL) <> '' then
  begin
    if (exec) and (RestDWConnection.Intransaction) then
    begin
      vMassiveCache := TRESTDWMassiveCacheSQLValue
        (RestDWConnection.MassiveSQL.CachedList.Add);
      vMassiveCache.SQL.Text := sSQL;
      vParams := vMassiveCache.Params;
      addParams(GetParams);
    end
    else
    begin
      vRESTDataBase := TFDPhysRDWConnectionBase(FConnection).Database;
      vParams := TParams.Create(nil);
      addParams(GetParams);
      FFieldCount := -1;
      FRecordCount := -1;
      vSQL := TStringList.Create;
      vSQL.Text := sSQL;
      vDataSetList := nil;
      try
        vRESTDataBase.ExecuteCommand(vPoolermethod, vSQL, vParams, vError,
          vMessageError, vDataSetList, vRowsAffected, exec, (not exec),
          (not exec), False, vRESTDataBase.RESTClientPooler);

        FStream.Size := 0;
        if (vDataSetList <> nil) and (not vDataSetList.IsNull) then
          vDataSetList.SaveToStream(FStream);
      finally
        FreeAndNil(vDataSetList);
      end;
      vSQL.Free;
      vParams.Free;
      if not vError then
      begin
        Result := vRowsAffected;
      end
      else
      begin
        Result := 0;
        raise TFDPhysRDWException.Create(Self, vMessageError);
      end;
    end;
  end
  else
  begin
    raise TFDPhysRDWException.Create(Self, errSQLEmpty);
  end;
end;

function TFDPhysRDWCommand.RDWGetPKTablesFields(tabela: string): integer;
var
  vRESTDataBase: TRESTDWDatabasebaseBase;
begin
  vRESTDataBase := TFDPhysRDWConnectionBase(FConnection).Database;
  Result := -1;
  FInfoMetada.Clear;
  try
    vRESTDataBase.GetKeyFieldNames(tabela, FInfoMetada);
    Result := FInfoMetada.Count;
    if Result = 0 then
      Result := -1;
  finally
  end;
end;

function TFDPhysRDWCommand.RDWGetTables: integer;
var
  vRESTDataBase: TRESTDWDatabasebaseBase;
begin
  vRESTDataBase := TFDPhysRDWConnectionBase(FConnection).Database;
  Result := -1;
  FInfoMetada.Clear;
  try
    vRESTDataBase.GetTableNames(FInfoMetada);
    Result := FInfoMetada.Count;
    if Result = 0 then
      Result := -1;
  finally
  end;
end;

function TFDPhysRDWCommand.RDWGetTablesFields(tabela: string): integer;
var
  vRESTDataBase: TRESTDWDatabasebaseBase;
begin
  vRESTDataBase := TFDPhysRDWConnectionBase(FConnection).Database;
  Result := -1;
  FInfoMetada.Clear;
  try
    vRESTDataBase.GetFieldNames(tabela, FInfoMetada);
    Result := FInfoMetada.Count;
    if Result = 0 then
      Result := -1;
  finally
  end;
end;

function TFDPhysRDWCommand.readDataStream(col: integer): Variant;
var
  vString: utf8string;
  vRawByteString: RawbyteString;
  vInt64: Int64;
  vInt: integer;
  vByte: Byte;
  vBoolean: Boolean;
  vWord: Word;
  vSingle: Single;
  vDouble: Double;
  VTimeZone: Double;
  vCurrency: Currency;
  vStringStream: TStringStream;
  {$IFDEF DELPHIXEUP}
  vTimeStampOffset: TSQLTimeStampOffset;
  {$ENDIF}
begin
  Result := null;
  if col >= FFieldCount then
    Exit;

  FStream.Read(vBoolean, SizeOf(vBoolean));

  // is null
  if vBoolean then
    Exit;

  // N - Bytes
  if (FFieldTypes[col] in [dwftFixedChar, dwftString, dwftMemo]) then
  begin
    FStream.Read(vInt64, SizeOf(vInt64));
    vRawByteString := '';
    if vInt64 > 0 then
    begin
      SetLength(vRawByteString, vInt64);
      FStream.Read(vRawByteString[InitStrPos], vInt64);
      if (FEncodeStrs)then
        vRawByteString := DecodeStrings(vRawByteString)
    end;
    Result := vRawByteString;
    if Pos(#0, Result) > 0 then
      Result := StringReplace(Result, #0, '', [rfReplaceAll]);
  end
  // N - Bytes Wide
  else if (FFieldTypes[col] in [dwftWideString, dwftFixedWideChar]) then
  begin
    FStream.Read(vInt64, SizeOf(vInt64));
    vString := '';
    if vInt64 > 0 then
    begin
      SetLength(vString, vInt64);
      FStream.Read(vString[InitStrPos], vInt64);
      if FEncodeStrs then
        vString := DecodeStrings(vString);
    end;
    Result := vString;
    if Pos(#0, Result) > 0 then
      Result := StringReplace(Result, #0, '', [rfReplaceAll]);
  end
  // 1 - Byte - Inteiros
  else if (FFieldTypes[col] in [dwftByte, dwftShortint]) then
  begin
    FStream.Read(vByte, SizeOf(vByte));
    Result := vByte;
  end
  // 1 - Byte - Boolean
  else if (FFieldTypes[col] in [dwftBoolean]) then
  begin
    FStream.Read(vBoolean, SizeOf(vBoolean));
    Result := vBoolean;
  end
  // 2 - Bytes
  else if (FFieldTypes[col] in [dwftSmallint, dwftWord]) then
  begin
    FStream.Read(vWord, SizeOf(vWord));
    Result := vWord;
  end
  // 4 - Bytes - Inteiros
  else if (FFieldTypes[col] in [dwftInteger]) then
  begin
    FStream.Read(vInt, SizeOf(vInt));
    Result := vInt;
  end
  // 4 - Bytes - Flutuantes
  else if (FFieldTypes[col] in [dwftSingle]) then
  begin
    FStream.Read(vSingle, SizeOf(vSingle));
    Result := vSingle;
  end
  // 8 - Bytes - Inteiros
  else if (FFieldTypes[col] in [dwftLargeint, dwftAutoInc, dwftLongWord]) then
  begin
    FStream.Read(vInt64, SizeOf(vInt64));
    Result := vInt64;
  end
  // 8 - Bytes - Flutuantes
  else if (FFieldTypes[col] in [dwftFloat, dwftExtended]) then
  begin
    FStream.Read(vDouble, SizeOf(vDouble));
    Result := vDouble;
  end
  // 8 - Bytes - Date, Time, DateTime, TimeStamp
  else if (FFieldTypes[col] in [dwftDate, dwftTime, dwftDateTime, dwftTimeStamp])
  then
  begin
    FStream.Read(vDouble, SizeOf(vDouble));
    Result := vDouble;
  end
  // TimeStampOffSet To Double - 8 Bytes
  // + TimeZone                - 2 Bytes
  else if (FFieldTypes[col] in [dwftTimeStampOffset]) then
  begin
    {$IFDEF DELPHIXEUP}
    FStream.Read(vDouble, SizeOf(vDouble));
    vTimeStampOffset := DateTimeToSQLTimeStampOffset(vDouble);
    FStream.Read(vByte, SizeOf(vByte));
    vTimeStampOffset.TimeZoneHour := vByte - 12;
    FStream.Read(vByte, SizeOf(vByte));
    vTimeStampOffset.TimeZoneMinute := vByte;
    Result := VarSQLTimeStampOffsetCreate(vTimeStampOffset);
    {$ELSE}
    // field foi transformado em datetime
    FStream.Read(vDouble, SizeOf(vDouble));
    FStream.Read(vByte, SizeOf(vByte));
    VTimeZone := (vByte - 12) / 24;
    FStream.Read(vByte, SizeOf(vByte));
    if VTimeZone > 0 then
      VTimeZone := VTimeZone + (vByte / 60 / 24)
    else
      VTimeZone := VTimeZone - (vByte / 60 / 24);
    vDouble := vDouble - VTimeZone;
    Result := vDouble;
    {$ENDIF}
  end
  // 8 - Bytes - Currency
  else if (FFieldTypes[col] in [dwftCurrency, dwftBCD, dwftFMTBcd]) then
  begin
    FStream.Read(vCurrency, SizeOf(vCurrency));
    Result := vCurrency;
  end
  // N Bytes - Wide Memos
  else if (FFieldTypes[col] in [ dwftWideMemo, dwftFmtMemo]) then
  begin
    FStream.Read(vInt64, SizeOf(vInt64));
    if vInt64 > 0 then
    Begin
      vStringStream := TStringStream.Create;
      try
        vStringStream.CopyFrom(FStream, vInt64);
        vStringStream.Position := 0;
        Result := TEncoding.UTF8.GetString(vStringStream.Bytes);
        //Result := vStringStream.DataString;
        if Pos(#0, Result) > 0 then
          Result := StringReplace(Result, #0, '', [rfReplaceAll]);
      finally
        vStringStream.Free;
      end;
    end;
  end
  // N Bytes - Memos e Blobs
  else if (FFieldTypes[col] in [dwftStream, dwftBlob, dwftBytes]) then
  begin
    FStream.Read(vInt64, SizeOf(vInt64));
    if vInt64 > 0 then
    Begin
      vStringStream := TStringStream.Create;
      try
        vStringStream.CopyFrom(FStream, vInt64);
        vStringStream.Position := 0;
        Result := vStringStream.DataString;
      finally
        vStringStream.Free;
      end;
    end;
  end
  else
  begin
    FStream.Read(vInt64, SizeOf(vInt64));
    vString := '';
    if vInt64 > 0 then
    begin
      SetLength(vString, vInt64);
      FStream.Read(vString[InitStrPos], vInt64);
      if FEncodeStrs then
        vString := DecodeStrings(vString);
    end;
    Result := vString;
    if Pos(#0, Result) > 0 then
      Result := StringReplace(Result, #0, '', [rfReplaceAll]);
  end;
end;

function TFDPhysRDWCommand.readFieldStream: TFDPhysDataColumnInfo;
var
  vFieldKind : TFieldKind;
  vString : utf8string;
  vFieldType : TFieldType;
  vFielSize: integer;
  vFieldPrecision: integer;
  vByte : Byte;

  datType: TFDDataType;
  datSize: LongWord;
  datPrec: integer;
  datScale: integer;
  datAttrs: TFDDataAttributes;
  oFmtOpts: TFDFormatOptions;
begin
  if FStream.Size = 0 then
    Exit;

  oFmtOpts := FOptions.FormatOptions;

  // field kind
  FStream.Read(vByte, SizeOf(vByte));
  vFieldKind := TFieldKind(vByte);

  // field name
  FStream.Read(vByte, SizeOf(vByte));
  SetLength(vString, vByte);
  FStream.Read(vString[InitStrPos], vByte);

  Result.FSourceName := vString;
  Result.FOriginColName := vString;

  // field type
  FStream.Read(vByte, SizeOf(vByte));
  vFieldType := DWFieldTypeToFieldType(vByte);

  FFieldTypes[FColumnIndex] := vByte;

  // field size
  FStream.Read(vFielSize, SizeOf(integer));

  // field precision
  FStream.Read(vFieldPrecision, SizeOf(integer));

  oFmtOpts.FieldDef2ColumnDef(vFieldType, vFielSize, vFieldPrecision, 0,
                              datType, datSize, datPrec,datScale, datAttrs);
  Result.FSourceID := FColumnIndex;
  Result.FSourceType := datType;

  if GetMetaInfoKind = mkNone then
  begin
    oFmtOpts.ResolveDataType(Result.FSourceName, Result.FSourceName, datType,
      datSize, datPrec, datScale, datType, datSize, True);
  end;

  // required + provider flags
  FStream.Read(vByte, SizeOf(Byte));

  if vByte and 1 = 0 then
    datAttrs := datAttrs + [caAllowNull];

  if (vFieldType in [ftBlob, ftMemo, ftGraphic, ftWideMemo, ftOraBlob, ftOraClob]) then
    datAttrs := datAttrs + [caBlobData]
  else
    datAttrs := datAttrs + [caSearchable];

  datAttrs := datAttrs + [caBase];

  if vFieldType in [ftFixedChar, ftFixedWideChar] then
    datAttrs := datAttrs + [caFixedLen];

  Result.FType := datType;
  // Result.FOriginTabName.FCatalog := '';
  Result.FAttrs := datAttrs;

  Result.FLen := datSize;
  if vByte and 2 > 0 then
    Result.FForceAddOpts := Result.FForceAddOpts + [coInUpdate];
  if vByte and 4 > 0 then
    Result.FForceAddOpts := Result.FForceAddOpts + [coInWhere];
  if vByte and 8 > 0 then
    Result.FForceAddOpts := Result.FForceAddOpts + [coInKey];
  if vByte and 32 > 0 then
    Result.FForceAddOpts := Result.FForceAddOpts + [coAfterInsChanged];
  if vByte and 64 > 0 then
    Result.FForceAddOpts := Result.FForceAddOpts + [coAfterUpdChanged];

  if vByte and 1 = 0 then
    Result.FForceAddOpts := Result.FForceAddOpts + [coAllowNull];

  Result.FForceRemOpts := [coReadOnly];
  Result.FForceAddOpts := Result.FForceAddOpts - [coReadOnly];
  Result.FLen := datSize;
  Result.FPrec := datPrec;
  Result.FScale := datScale;
end;

procedure TFDPhysRDWCommand.readStreamFields;
var
  i: integer;
begin
  FStream.Position := 0;
  // field count
  FStream.Read(FFieldCount, SizeOf(integer));
  SetLength(FFieldTypes, FFieldCount);
  // encodestr
  FStream.Read(FEncodeStrs, SizeOf(Byte));
  for i := 0 to FFieldCount - 1 do
  begin
    FColumnIndex := i;
    readFieldStream;
  end;
end;

function TFDPhysRDWCommand.RestDWConnection: TFDPhysRDWConnectionBase;
begin
  Result := nil;
  if FConnectionObj.InheritsFrom(TFDPhysRDWConnectionBase) then
    Result := TFDPhysRDWConnectionBase(FConnectionObj);
end;

{ TFDPhysRDWBaseDriverLink }
function TFDPhysRDWBaseDriverLink.GetBaseDriverID: String;
begin
  Result := S_FD_RDWId;
end;

function TFDPhysRDWBaseDriverLink.IsConfigured: Boolean;
begin
  Result := Assigned(FDatabase);
end;
{ TFDPhysRDWException }

constructor TFDPhysRDWException.Create(AObj: TObject; AMsg: string);
var
  eKind: TFDCommandExceptionKind;
begin
  Inherited Create(er_FD_StanTimeout, AMsg);
  eKind := ekCmdAborted;
  AppendError(1, er_FD_StanTimeout, AMsg, '', eKind, -1, -1);
end;

end.
