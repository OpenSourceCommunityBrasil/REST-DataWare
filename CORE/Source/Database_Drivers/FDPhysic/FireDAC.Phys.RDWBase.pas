unit FireDAC.Phys.RDWBase;

interface

uses
  Classes, SysUtils, FireDAC.Phys, FireDAC.Stan.Intf, FireDAC.Phys.Intf,
  FireDAC.Phys.SQLGenerator, FireDAC.Stan.Util, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.Phys.RDWMeta, Firedac.Stan.Option, Variants,
  uRESTDWBasicDB, DB, StrUtils, FireDAC.Stan.Error;

type
  TFDPhysRDWConnectionBase = class;
  TRDWReader = class;
  TFDPhysRDWCommand = class;

  TFDPhysRDWBaseDriverLink = class(TFDPhysDriverLink)
  private
    FDatabase : TRESTDWDatabasebaseBase;
  public
    function GetBaseDriverID: String; override;
    function IsConfigured: Boolean; override;
  published
    property Database : TRESTDWDatabasebaseBase read FDatabase write FDatabase;
  end;

  TFDPhysRDWDriverBase = class(TFDPhysDriver)
  protected
    procedure InternalLoad; override;
    procedure InternalUnload; override;
  end;

  TFDPhysRDWConnectionBase = class(TFDPhysConnection)
  private
    FDatabase : TRESTDWDatabasebaseBase;
    FRDBMSKind : TFDRDBMSKind;
    FCurrentCommand: TFDPhysRDWCommand;
    function getDatabase : TRESTDWDatabasebaseBase;
    function getRDBMSKindFromAlias: TFDRDBMSKind;
    function getPhysDriver: TFDPhysRDWDriverBase;
  protected
    procedure InternalConnect; override;
    procedure InternalDisconnect; override;
    function InternalCreateMetadata: TObject; override;
    function InternalCreateTransaction: TFDPhysTransaction; override;
    function InternalCreateCommand: TFDPhysCommand; override;
    function InternalCreateCommandGenerator(
      const ACommand: IFDPhysCommand): TFDPhysCommandGenerator; override;
    procedure InternalExecuteDirect(
      const ASQL: String; ATransaction: TFDPhysTransaction); override;
    procedure GetItem(AIndex: Integer; out AName: String; out AValue: Variant;
      out AKind: TFDMoniAdapterItemKind); override;
    function GetItemCount: Integer; override;
    function GetCliObj: Pointer; override;
    function InternalGetCliHandle: Pointer; override;
    function IsDs:Boolean;
  published
    property Database : TRESTDWDatabasebaseBase read FDatabase;
    property PhysDriver: TFDPhysRDWDriverBase read GetPhysDriver;
  end;

  TFDPhysRDWTransaction = class(TFDPhysTransaction)
  protected
    procedure InternalStartTransaction(AID: LongWord); override;
    procedure InternalCommit(AID: LongWord); override;
    procedure InternalRollback(AID: LongWord); override;
  end;

  TRDWCommand = class(TObject)
  private
    FCommandKind: TFDPhysCommandKind;
    FRowsAffected: Int64;
    FDsResult     : TRESTDWClientSQL;
    FDatabase     : TRESTDWDatabasebaseBase;
    FLastReader   : TRDWReader;
    FMessageError : string;
    FPrepared: Boolean;
    FText: string;
    FOpen: Boolean;
    procedure CommandExecuting;
    procedure CommandExecuted;
    function GetParameters: TParams;
    procedure SetRowSetSize(const Value: Int64);
    procedure SetText(const Value: string);
  protected
    procedure Open;
    procedure Close;
    procedure CloseReader;
    procedure GetParamValues(AParams: TFDParams; AGetDataSets: Boolean);
    procedure SetParamValues(AParams: TFDParams; AValueIndex: Integer);
    procedure CreateParams(AFDParams : TFDParams);
  public
    constructor Create(aKind: TFDPhysCommandKind);
    destructor Destroy; override;
    procedure Prepare; virtual;
    function ExecuteQuery: TRDWReader; virtual;
    function GetNextReader: TRDWReader; virtual;

    property RowsAffected: Int64 read FRowsAffected;
    property Parameters: TParams read GetParameters;
    property RowSetSize: Int64 write SetRowSetSize;
    property Text: string read FText write SetText;
    property Database: TRESTDWDatabasebaseBase read FDatabase write FDatabase;
  end;

  TRDWReader = class(TObject)
  private
    FClosed : Boolean;
    FCommand: TRDWCommand;
    FFirst  : Boolean;
    function GetColumnCount: Integer;
    procedure CommandCloseReader;
    procedure CloseReader;
  public
    constructor Create;
    destructor Destroy; override;
    function Next: Boolean;

    property ColumnCount: Integer read GetColumnCount;
    property Closed: Boolean read FClosed;
  end;

  TFDPhysRDWCommand = class(TFDPhysCommand)
  private
    FRDWCommand    : TRDWCommand;
    FRDWReader     : TRDWReader;
    FReadersList   : TFDObjList;
    FColumnIndex   : Word;
    FParamChildPos : array of Word;
    FMetaForPackage: Boolean;
    procedure FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
    procedure GetParamValues(AParams: TFDParams; AGetDataSets: Boolean);
    procedure SetParamValues(AParams: TFDParams; AValueIndex: Integer);
    procedure CreateParams;
    procedure OpenMetaInfo;
    procedure AddCursor(AReader: TRDWReader);
    procedure DeleteCursor(AReader: TRDWReader);
    function FetchMetaRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow; ARowIndex: Integer) : Boolean;
    function GetPhysConn: TFDPhysRDWConnectionBase;
  protected
    procedure InternalClose; override;
    procedure InternalExecute(ATimes, AOffset: Integer; var ACount: TFDCounter); override;
    procedure InternalPrepare; override;
    procedure InternalUnprepare; override;
    function InternalFetchRowSet(ATable: TFDDatSTable; AParentRow: TFDDatSRow; ARowsetSize: LongWord): LongWord; override;
    function InternalOpen{$if CompilerVersion > 31}(var ACount: TFDCounter){$IFEND}: Boolean; override;
    function InternalNextRecordSet: Boolean; override;
    function InternalColInfoStart(var ATabInfo: TFDPhysDataTableInfo): Boolean; override;
    function InternalColInfoGet(var AColInfo: TFDPhysDataColumnInfo): Boolean; override;
    function GetCliObj: Pointer; override;
    function CreateRDWCommand:TRDWCommand;
  public
    constructor Create(AConnectionObj: TFDPhysConnection);
    destructor Destroy; override;
    property PhysConn: TFDPhysRDWConnectionBase read GetPhysConn;
  end;

const
  S_FD_RDWId = 'RDW';

implementation

uses
  FireDAC.Phys.RDWDef, Data.SqlTimSt, uRESTDWParams, uRESTDWPoolermethod;

{ TFDPhysRDWDriverBase }

procedure TFDPhysRDWDriverBase.InternalLoad;
begin
  inherited;

end;

procedure TFDPhysRDWDriverBase.InternalUnload;
begin
  inherited;

end;

{ TFDPhysRDWConnectionBase }

function TFDPhysRDWConnectionBase.GetCliObj: Pointer;
begin
  if not Assigned(FDatabase) then
    FDatabase := getDatabase;

  if Assigned(FDatabase) then
    Result := FDatabase;
end;

function TFDPhysRDWConnectionBase.getDatabase : TRESTDWDatabasebaseBase;
var
  rdwDriver : TFDPhysRDWBaseDriverLink;
begin
  rdwDriver := TFDPhysRDWBaseDriverLink(DriverObj.Manager.FindDriverLink(S_FD_RDWId));
  if rdwDriver <> nil then
    Result := rdwDriver.Database;
end;

procedure TFDPhysRDWConnectionBase.GetItem(AIndex: Integer; out AName: String;
  out AValue: Variant; out AKind: TFDMoniAdapterItemKind);
begin
  if AIndex < inherited GetItemCount then begin
    inherited GetItem(AIndex, AName, AValue, AKind)
  end
  else begin
    case AIndex - inherited GetItemCount of
      0:
        begin
          AName  := 'RDW product name';
          AKind  := ikClientInfo;
          AValue := 'REST Dataware Core';
        end;
      1:
        begin
          AName  := 'RDW product version';
          AKind  := ikClientInfo;
          AValue := FDatabase.VersionInfo;
        end;
    end;
  end;
end;

function TFDPhysRDWConnectionBase.GetItemCount: Integer;
begin
  Result := inherited GetItemCount;

  if Assigned(FDatabase) then
    Inc(Result, 2)
  else
    Inc(Result);
end;

function TFDPhysRDWConnectionBase.getPhysDriver: TFDPhysRDWDriverBase;
begin
  Result := TFDPhysRDWDriverBase(DriverObj);
end;

function TFDPhysRDWConnectionBase.getRDBMSKindFromAlias: TFDRDBMSKind;
var
  oManMeta: IFDPhysManagerMetadata;
begin
  Result := FRDBMSKind;
  if Result = TFDRDBMSKinds.Unknown then begin
    FDPhysManager.CreateMetadata(oManMeta);
    Result := oManMeta.GetRDBMSKind(GetConnectionDef.AsString[S_FD_ConnParam_Common_RDBMS]);
  end;
end;

procedure TFDPhysRDWConnectionBase.InternalConnect;
begin
  if not Assigned(FDatabase) then
    FDatabase := getDatabase;

  if not Assigned(FDatabase) then
    raise Exception.Create('Database not assigned');

  if not FDatabase.Connected then
    FDatabase.Open;
end;

function TFDPhysRDWConnectionBase.InternalCreateCommand: TFDPhysCommand;
begin
  Result := TFDPhysRDWCommand.Create(Self);
end;

function TFDPhysRDWConnectionBase.InternalCreateCommandGenerator(
  const ACommand: IFDPhysCommand): TFDPhysCommandGenerator;
begin
  Result := TFDPhysCommandGenerator.Create(ACommand);
end;

function TFDPhysRDWConnectionBase.InternalCreateMetadata: TObject;
begin
  Result := TFDPhysRDWMetadata.Create(Self,'');
end;

function TFDPhysRDWConnectionBase.InternalCreateTransaction: TFDPhysTransaction;
begin
  Result := TFDPhysRDWTransaction.Create(Self);
end;

procedure TFDPhysRDWConnectionBase.InternalDisconnect;
begin
  inherited;
  FDFreeAndNil(FDatabase);
end;

procedure TFDPhysRDWConnectionBase.InternalExecuteDirect(const ASQL: String;
  ATransaction: TFDPhysTransaction);
var
  _Sql         : TStringList;
  _Params      : TParams;
  _Error       : Boolean;
  _MessageError: String;
  _Result      : uRESTDWParams.TJSONValue;
  _RowsAffected: Integer;
  _PoolerMethod: TRESTDWPoolerMethodClient;
  _Execute     : Boolean;
begin
  _Params       := nil;
  _Error        := False;
  _MessageError := '';
  _Result       := nil;
  _RowsAffected := 0;

  _Sql    := TStringList.Create;
  _Params := TParams.Create(nil);
  try
    _Sql.Text := ASQL;
    _Execute  := not ContainsText(ASQL, 'select');

    FDatabase.ExecuteCommand(_PoolerMethod, _Sql, _Params, _Error, _MessageError, _Result,
      _RowsAffected, _Execute, True, True);
  finally
    FreeAndNil(_Sql);
    FreeAndNil(_Params);
  end;

  if _Error then
    raise Exception.Create(_MessageError);
end;

function TFDPhysRDWConnectionBase.InternalGetCliHandle: Pointer;
begin
  if not Assigned(FDatabase) then
    FDatabase := getDatabase;

  if Assigned(FDatabase) then
    Result := @FDatabase;
end;

function TFDPhysRDWConnectionBase.IsDs: Boolean;
begin
  Result := False;
end;

{ TFDPhysRDWTransaction }

procedure TFDPhysRDWTransaction.InternalCommit(AID: LongWord);
begin
  inherited;

end;

procedure TFDPhysRDWTransaction.InternalRollback(AID: LongWord);
begin
  inherited;

end;

procedure TFDPhysRDWTransaction.InternalStartTransaction(AID: LongWord);
begin
  inherited;

end;

{ TFDPhysRDWCommand }

procedure TFDPhysRDWCommand.AddCursor(AReader: TRDWReader);
begin
  if AReader = nil then
    Exit;

  if FReadersList.IndexOf(AReader) = -1 then begin
    if AReader.ColumnCount > 0 then begin
      FReadersList.Add(AReader);
      if FRDWReader = nil then
        FRDWReader := TRDWReader(FReadersList[0]);
    end
    else begin
      FDFree(AReader);
    end;
  end;
end;

constructor TFDPhysRDWCommand.Create(AConnectionObj: TFDPhysConnection);
begin
  inherited Create(AConnectionObj);
  FReadersList := TFDObjList.Create;
end;

procedure TFDPhysRDWCommand.CreateParams;
var
  oParams: TFDParams;
begin
  oParams := GetParams;

  if (oParams.Count = 0) or (FRDWCommand.FDsResult = nil) then
    Exit;

  FRDWCommand.CreateParams(oParams);
end;

function TFDPhysRDWCommand.CreateRDWCommand: TRDWCommand;
begin
  Result          := TRDWCommand.Create(GetCommandKind);
  Result.Database := PhysConn.Database;
end;

procedure TFDPhysRDWCommand.DeleteCursor(AReader: TRDWReader);
begin
  if AReader = nil then
    Exit;
  FReadersList.Remove(AReader);
  if FRDWReader = AReader then
    FRDWReader := nil;
  FDFree(AReader);
end;

destructor TFDPhysRDWCommand.Destroy;
begin
  inherited Destroy;
  FDFreeAndNil(FReadersList);
  FDFreeAndNil(FRDWCommand);
  FDFreeAndNil(FRDWReader);
end;

function TFDPhysRDWCommand.FetchMetaRow(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow; ARowIndex: Integer): Boolean;
const
  C_Asc: String = 'ASC';
  C_Desc: String = 'DESC';
var
  oRow: TFDDatSRow;
  iDbxPrec: Integer;
  siDbxScale: SmallInt;
  wDbxDataType, wDbxSubType: Word;
  eType: TFDDataType;
  eAttrs: TFDDataAttributes;
  iLen: LongWord;
  iPrec, iScale: Integer;
  iRecNo: Integer;
  eProcType: TFDPhysProcedureKind;
  eTableKind: TFDPhysTableKind;
  eScope: TFDPhysObjectScope;
  eParamType: TParamType;
  eIndexKind: TFDPhysIndexKind;
  sSchema: String;
  lDeleteRow: Boolean;
  oConnMeta: IFDPhysConnectionMetadata;
  s: String;
  i: Integer;
  oVal: TField;

  procedure SetData(ACrsColIndex, ARowColIndex: Integer);
  var
    pData   : Variant;
    q1      : TRESTDWClientSQL;
  begin
    // fernando
//    FRDWCommand.FDsResult.SourceView.Rows[FRDWCommand.FDsResult.RecNo - 1]
//              .GetData(ACrsColIndex {- 1}, rvDefault, pData, 0, iLen, False);
    q1 := FRDWCommand.FDsResult;
    pData := q1.Fields[ACrsColIndex].Value;

    oRow.SetData(ARowColIndex,pData);
{
    case oRow.Table.Columns.ItemsI[ARowColIndex].DataType of
      dtInt16:
        begin
          oRow.SetData(ARowColIndex, PSmallInt(pData), 0);
        end;
      dtInt32:
        begin
           oRow.SetData(ARowColIndex, PInteger(pData), 0);
        end;
      dtWideString:
        begin
          oRow.SetData(ARowColIndex, PWideChar(pData), iLen);
        end;
      else
        ASSERT(False);
    end;
}
  end;

  procedure GetScope(ARowColIndex: Integer; var AScope: TFDPhysObjectScope);
  var
    sSchema: String;
  begin
    sSchema := VarToStr(oRow.GetData(ARowColIndex, rvDefault));
    {TODO -oDelcio -cRDW : Ver IsDS}
    if PhysConn.IsDS and
       ((CompareText(sSchema, 'DSAdmin') = 0) or
        (CompareText(sSchema, 'DSMetadata') = 0)) then
      AScope := osSystem
    else
    {TODO -oDelcio -cRDW : Ver IsDS}
    if not (npSchema in oConnMeta.NameParts) or (PhysConn.IsDS) or
       (AnsiCompareText(sSchema, PhysConn.GetCurrentSchema) = 0) then
      AScope := osMy
    else
      AScope := osOther;
  end;

  procedure SetObjectName(ACrs, ASchemaRow, AObjRow: Integer);
  var
    oConnMeta: IFDPhysConnectionMetadata;
    rName: TFDPhysParsedName;
    sObj: String;
  begin
    SetData(ACrs, AObjRow);
    {TODO -oDelcio -cRDW : Ver IsDS}
    if PhysConn.IsDS then begin
      sObj := VarToStr(oRow.GetData(AObjRow));
      PhysConn.CreateMetadata(oConnMeta);
      oConnMeta.DecodeObjName(sObj, rName, Self, [doUnquote]);
      if rName.FSchema <> '' then begin
        oRow.SetData(AObjRow, rName.FObject);
        oRow.SetData(ASchemaRow, rName.FSchema);
      end;
    end;
  end;

begin
  lDeleteRow := False;
  iRecNo := ATable.Rows.Count + 1;
  oRow := ATable.NewRow(True);
  try
    PhysConn.CreateMetadata(oConnMeta);
    case GetMetaInfoKind of
    mkCatalogs:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXTablesIndex.CatalogName}, 1);
      end;
    mkSchemas:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXTablesIndex.CatalogName}, 1);
        SetData(1{TDBXTablesIndex.SchemaName}, 2);
        {TODO -oDelcio -cRDW : Ver IsDS}
        if PhysConn.IsDS then begin
          SetObjectName(2{TDBXProceduresIndex.ProcedureName}, 2, 1);
          oRow.SetData(1, nil, 0);
          if (GetWildcard <> '') and
             not FDStrLike(VarToStr(oRow.GetData(2, rvDefault)), GetWildcard, True) then
            lDeleteRow := True
          else
            for i := 0 to ATable.Rows.Count - 1 do
              if VarToStr(ATable.Rows[i].GetData(2, rvDefault)) = VarToStr(oRow.GetData(2, rvDefault)) then begin
                lDeleteRow := True;
                Break;
              end;
        end;
      end;
    mkTables:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXTablesIndex.CatalogName}, 1);
        SetData(1{TDBXTablesIndex.SchemaName}, 2);
        SetObjectName(2{TDBXTablesIndex.TableName}, 2, 3);
        GetScope(2, eScope);
        s := FRDWReader.FCommand.FDsResult.Fields[3{TDBXTablesIndex.TableType}].AsWideString;
        if s = 'TABLE' then
          eTableKind := tkTable
        else if s = 'VIEW' then
          eTableKind := tkView
        else if s = 'SYNONYM' then
          eTableKind := tkSynonym
        else if s = 'SYSTEM_TABLE' then begin
          eTableKind := tkTable;
          eScope := osSystem;
        end
        else
          eTableKind := tkTable;
        oRow.SetData(4, SmallInt(eTableKind));
        oRow.SetData(5, SmallInt(eScope));
        lDeleteRow := not (eTableKind in GetTableKinds) or
                      not (eScope in GetObjectScopes);
      end;
    mkTableFields:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXColumnsIndex.CatalogName}, 1);
        SetData(1{TDBXColumnsIndex.SchemaName}, 2);
        SetObjectName(2{TDBXColumnsIndex.TableName}, 2, 3);
        SetData(3{TDBXColumnsIndex.ColumnName}, 4);
        SetData(4{TDBXColumnsIndex.Ordinal}, 5);
        if FRDWReader.FCommand.FDsResult.Fields[9{TDBXColumnsIndex.IsNullable}].AsBoolean then
          Include(eAttrs, caAllowNull);
        if FRDWReader.FCommand.FDsResult.Fields[10{TDBXColumnsIndex.IsAutoIncrement}].AsBoolean then begin
          Include(eAttrs, caAutoInc);
          Include(eAttrs, caAllowNull);
        end;
        if FRDWReader.FCommand.FDsResult.Fields[13{TDBXColumnsIndex.IsFixedLength}].AsBoolean then
          Include(eAttrs, caFixedLen);
        if not FRDWReader.FCommand.FDsResult.Fields[8{TDBXColumnsIndex.DefaultValue}].IsNull then
          Include(eAttrs, caDefault);
        oRow.SetData(6, SmallInt(eType));
        oRow.SetData(8, PWord(@eAttrs)^);
        oRow.SetData(9, iPrec);
        oRow.SetData(10, iScale);
        oRow.SetData(11, iLen);
      end;
    mkPackages:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXPackagesIndex.CatalogName}, 1);
        SetData(1{TDBXPackagesIndex.SchemaName}, 2);
        SetObjectName(2{TDBXPackagesIndex.PackageName}, 2, 3);
        sSchema := oRow.GetData(2, rvDefault);
        if {$IFDEF FireDAC_NOLOCALE_META} CompareText {$ELSE} AnsiCompareText {$ENDIF}
            (sSchema, PhysConn.GetConnectionDef.AsString['USER_NAME']) = 0 then
          eScope := osMy
        else if (sSchema = 'SYS') or (sSchema = 'SYSTEM') then
          eScope := osSystem
        else
          eScope := osOther;
        oRow.SetData(4, Integer(eScope));
        lDeleteRow := not (eScope in GetObjectScopes);
      end;
    mkProcs:
      begin
        oRow.SetData(0, iRecNo);
        if FMetaForPackage then begin
          SetData(0{TDBXPackageProceduresIndex.CatalogName}, 1);
          SetData(1{TDBXPackageProceduresIndex.SchemaName}, 2);
          SetObjectName(2{TDBXPackageProceduresIndex.PackageName}, 2, 3);
          SetData(3{TDBXPackageProceduresIndex.ProcedureName}, 4);
          s := FRDWReader.FCommand.FDsResult.Fields[4{TDBXPackageProceduresIndex.ProcedureType}].AsWideString;
        end
        else begin
          SetData(0{TDBXProceduresIndex.CatalogName}, 1);
          SetData(1{TDBXProceduresIndex.SchemaName}, 2);
          oRow.SetData(3, nil, 0);
          SetObjectName(2{TDBXProceduresIndex.ProcedureName}, 2, 4);
          s := FRDWReader.FCommand.FDsResult.Fields[3{TDBXProceduresIndex.ProcedureType}].AsWideString;
        end;
        oRow.SetData(5, nil, 0);
        GetScope(2, eScope);
        if s = 'PROCEDURE' then
          eProcType := pkProcedure
        else if s = 'FUNCTION' then
          eProcType := pkFunction
        else
          eProcType := pkProcedure;
        oRow.SetData(6, Integer(eProcType));
        oRow.SetData(7, SmallInt(eScope));
        oRow.SetData(8, nil, 0);
        oRow.SetData(9, nil, 0);
        lDeleteRow := not (eScope in GetObjectScopes);
      end;
    mkProcArgs:
      begin
        oRow.SetData(0, iRecNo);
        if FMetaForPackage then begin
          SetData(0{TDBXPackageProcedureParametersIndex.CatalogName}, 1);
          SetData(1{TDBXPackageProcedureParametersIndex.SchemaName}, 2);
          SetObjectName(2{TDBXPackageProcedureParametersIndex.PackageName}, 2, 3);
          SetData(3{TDBXPackageProcedureParametersIndex.ProcedureName}, 4);
          oRow.SetData(5, nil, 0);
          SetData(4{TDBXPackageProcedureParametersIndex.ParameterName}, 6);
          SetData(9{TDBXPackageProcedureParametersIndex.Ordinal}, 7);
          s := FRDWReader.FCommand.FDsResult.Fields[5{TDBXPackageProcedureParametersIndex.ParameterMode}].AsWideString;
          if s = 'IN' then
            eParamType := ptInput
          else if s = 'OUT' then
            eParamType := ptOutput
          else if s = 'INOUT' then
            eParamType := ptInputOutput
          else if s = 'RESULT' then
            eParamType := ptResult
          else
            eParamType := ptUnknown;
          oRow.SetData(8, Integer(eParamType));
          SetData(6{TDBXPackageProcedureParametersIndex.TypeName}, 10);
          if FRDWReader.FCommand.FDsResult.Fields[10{TDBXPackageProcedureParametersIndex.IsNullable}].AsBoolean then
            Include(eAttrs, caAllowNull);
          if FRDWReader.FCommand.FDsResult.Fields[12{TDBXPackageProcedureParametersIndex.IsFixedLength}].AsBoolean then
            Include(eAttrs, caFixedLen);
          oRow.SetData(9, SmallInt(eType));
          oRow.SetData(11, PWord(@eAttrs)^);
          oRow.SetData(12, iPrec);
          oRow.SetData(13, iScale);
          oRow.SetData(14, iLen);
        end
        else begin
          SetData(0{TDBXProcedureParametersIndex.CatalogName}, 1);
          SetData(1{TDBXProcedureParametersIndex.SchemaName}, 2);
          oRow.SetData(3, nil, 0);
          SetObjectName(2{TDBXProcedureParametersIndex.ProcedureName}, 2, 4);
          oRow.SetData(5, nil, 0);
          SetData(3{TDBXProcedureParametersIndex.ParameterName}, 6);
          SetData(8{TDBXProcedureParametersIndex.Ordinal}, 7);
          s := FRDWReader.FCommand.FDsResult.Fields[4{TDBXProcedureParametersIndex.ParameterMode}].AsWideString;
          if s = 'IN' then
            eParamType := ptInput
          else if s = 'OUT' then
            eParamType := ptOutput
          else if s = 'INOUT' then
            eParamType := ptInputOutput
          else if s = 'RESULT' then
            eParamType := ptResult
          else
            eParamType := ptUnknown;
          oRow.SetData(8, Integer(eParamType));
          SetData(5{TDBXProcedureParametersIndex.TypeName}, 10);
          if FRDWReader.FCommand.FDsResult.Fields[9{TDBXProcedureParametersIndex.IsNullable}].AsBoolean then
            Include(eAttrs, caAllowNull);
          if FRDWReader.FCommand.FDsResult.Fields[11{TDBXProcedureParametersIndex.IsFixedLength}].AsBoolean then
            Include(eAttrs, caFixedLen);
          oRow.SetData(9, SmallInt(eType));
          oRow.SetData(11, PWord(@eAttrs)^);
          oRow.SetData(12, iPrec);
          oRow.SetData(13, iScale);
          oRow.SetData(14, iLen);
        end;
        {TODO -oDelcio -cRDW : Ver IsDS}
        if PhysConn.IsDS and
           (eParamType = ptOutput) and (CompareText(oRow.GetData(6), 'ReturnValue') = 0) then begin
          oRow.SetData(8, Integer(ptResult));
          if GetOptions.ResourceOptions.UnifyParams then
            oRow.SetData(6, 'Result');
        end;
      end;
    mkIndexes,
    mkPrimaryKey:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXIndexesIndex.CatalogName}, 1);
        SetData(1{TDBXIndexesIndex.SchemaName}, 2);
        SetObjectName(2{TDBXIndexesIndex.TableName}, 2, 3);
        SetData(3{TDBXIndexesIndex.IndexName}, 4);
        SetData(4{TDBXIndexesIndex.ConstraintName}, 5);
        if FRDWReader.FCommand.FDsResult.Fields[5{TDBXIndexesIndex.IsPrimary}].AsBoolean then
          eIndexKind := ikPrimaryKey
        else if FRDWReader.FCommand.FDsResult.Fields[6{TDBXIndexesIndex.IsUnique}].AsBoolean then
          eIndexKind := ikUnique
        else
          eIndexKind := ikNonUnique;
        if GetMetaInfoKind = mkPrimaryKey then
          if PhysConn.GetRDBMSKindFromAlias = TFDRDBMSKinds.MSAccess then begin
            if not (eIndexKind in [ikUnique, ikPrimaryKey]) then
              lDeleteRow := True
            else
              eIndexKind := ikPrimaryKey;
          end
          else if eIndexKind <> ikPrimaryKey then
            lDeleteRow := True;
        oRow.SetData(6, SmallInt(eIndexKind));
      end;
    mkPrimaryKeyFields,
    mkIndexFields:
      begin
        oRow.SetData(0, iRecNo);
        SetData(1{TDBXIndexColumnsIndex.CatalogName}, 1);
        SetData(2{TDBXIndexColumnsIndex.SchemaName}, 2);
        SetObjectName(3{TDBXIndexColumnsIndex.TableName}, 2, 3);
        SetData(4{TDBXIndexColumnsIndex.IndexName}, 4);
        SetData(5{TDBXIndexColumnsIndex.ColumnName}, 5);
        SetData(6{TDBXIndexColumnsIndex.Ordinal}, 6);
        SetData(7, 7);
      end;
    mkForeignKeys:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXForeignKeysIndex.CatalogName}, 1);
        SetData(1{TDBXForeignKeysIndex.SchemaName}, 2);
        SetObjectName(2{TDBXForeignKeysIndex.TableName}, 2, 3);
        SetData(3{TDBXForeignKeysIndex.ForeignKeyName}, 4);
        oRow.SetData(5, nil, 0);
        oRow.SetData(6, nil, 0);
        oRow.SetData(7, nil, 0);
        oRow.SetData(8, Smallint(ckNone));
        oRow.SetData(9, Smallint(ckNone));
      end;
    mkForeignKeyFields:
      begin
        oRow.SetData(0, iRecNo);
        SetData(0{TDBXForeignKeyColumnsIndex.CatalogName}, 1);
        SetData(1{TDBXForeignKeyColumnsIndex.SchemaName}, 2);
        SetObjectName(2{TDBXForeignKeyColumnsIndex.TableName}, 2, 3);
        SetData(3{TDBXForeignKeyColumnsIndex.ForeignKeyName}, 4);
        SetData(4{TDBXForeignKeyColumnsIndex.ColumnName}, 5);
        SetData(9{TDBXForeignKeyColumnsIndex.PrimaryColumnName}, 6);
        SetData(10{TDBXForeignKeyColumnsIndex.Ordinal}, 7);
      end;
    end;
    if lDeleteRow then begin
      FDFree(oRow);
      Result := False;
    end
    else begin
      if AParentRow <> nil then begin
        oRow.ParentRow := AParentRow;
        AParentRow.Fetched[ATable.Columns.ParentCol] := True;
      end;
      ATable.Rows.Add(oRow);
      Result := True;
    end;
  except
    FDFree(oRow);
    raise;
  end;
end;

procedure TFDPhysRDWCommand.FetchRow(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow);
var
  oCol    : TFDDatSColumn;
  oRow    : TFDDatSRow;
  j       : Integer;
  pData   : Pointer;
  iLen    : LongWord;
  oFmtOpts: TFDFormatOptions;
  q1      : TRESTDWClientSQL;
begin
  oRow     := ATable.NewRow(True);
  oFmtOpts := GetOptions.FormatOptions;
  q1       := FRDWCommand.FDsResult;
  try
    for j := 0 to ATable.Columns.Count - 1 do begin
      oCol := ATable.Columns[j];
      if (oCol.SourceID >= 0) and CheckFetchColumn(oCol.SourceDataType, oCol.Attributes) then
        oRow.SetData(j,q1.Fields[oCol.SourceID].Value);
    end;

    ATable.Rows.Add(oRow);
  except
    FDFree(oRow);
    raise;
  end;
end;

function TFDPhysRDWCommand.GetCliObj: Pointer;
begin
  Result := FRDWCommand;
end;

procedure TFDPhysRDWCommand.GetParamValues(AParams: TFDParams;
  AGetDataSets: Boolean);
begin
  FRDWCommand.GetParamValues(AParams, AGetDataSets);
end;

function TFDPhysRDWCommand.GetPhysConn: TFDPhysRDWConnectionBase;
begin
  Result := TFDPhysRDWConnectionBase(FConnectionObj);
end;

procedure TFDPhysRDWCommand.InternalClose;
var
  i: Integer;
begin
  GetParamValues(GetParams, False);

  if not GetNextRecordSet and (FReadersList.Count > 0) then begin
    try
      for i := 0 to FReadersList.Count - 1 do
        FDFree(TRDWReader(FReadersList[i]));

      FRDWCommand.FLastReader:= nil;
    finally
      FReadersList.Clear;
      FRDWReader := nil;
    end;
  end;
end;

function TFDPhysRDWCommand.InternalColInfoGet(
  var AColInfo: TFDPhysDataColumnInfo): Boolean;
var
  iCount: Integer;
  fld : TField;
  datType : TFDDataType;
  datSize : LongWord;
  datPrec : integer;
  datScale : integer;
  datAttrs : TFDDataAttributes;
begin
  if AColInfo.FParentTableSourceID <> -1 then begin
      { TODO -oDelcio -cRDW : Implementar InternalColInfoGet com  AColInfo.FParentTableSourceID }
    Result := False;
    Exit;
  end
  else begin
    iCount := FRDWReader.ColumnCount;
    if FColumnIndex >= iCount then begin
      Result := False;
      Exit;
    end;
  end;

  fld := FRDWCommand.FDsResult.Fields[FColumnIndex];

  TFDFormatOptions.FieldDef2ColumnDef(fld,datType,datSize,datPrec,datScale,datAttrs);

  AColInfo.FSourceID   := FColumnIndex;
  AColInfo.FSourceName := fld.DisplayName;
  // AColInfo.FOriginColName
  AColInfo.FSourceType := datType;
  AColInfo.FType       := datType;
  // AColInfo.FOriginTabName:= OriginTabName;
  AColInfo.FAttrs := datAttrs;

  AColInfo.FLen := datSize;

  AColInfo.FPrec  := datPrec;
  AColInfo.FScale := datScale;

  FColumnIndex := FColumnIndex + 1;

  Result := True;
end;

function TFDPhysRDWCommand.InternalColInfoStart(
  var ATabInfo: TFDPhysDataTableInfo): Boolean;
begin
  Result := OpenBlocked;
  if Result then begin
    if ATabInfo.FSourceID = -1 then begin
      ATabInfo.FSourceName := GetCommandText;
      ATabInfo.FSourceID   := 1;
      FColumnIndex         := 0;
    end
    else begin
      { TODO -oDelcio -cRDW : Implementar TFDPhysRDWCommand.InternalColInfoStart OpenBlocked = False }
      raise Exception.Create('TFDPhysRDWCommand.InternalColInfoStart');

      // ATabInfo.FSourceName := FDBXReader.ValueType[ATabInfo.FSourceID - 1].Name;
      ATabInfo.FSourceID := ATabInfo.FSourceID;
    end;
  end;
end;

procedure TFDPhysRDWCommand.InternalExecute(ATimes, AOffset: Integer;
  var ACount: TFDCounter);
var
  i        : Integer;
  iAffected: Int64;
begin
  ACount := 0;
  if GetMetaInfoKind = TFDPhysMetaInfoKind.mkNone then begin
    for i := AOffset to ATimes - 1 do begin
      SetParamValues(GetParams, i);
      PhysConn.FCurrentCommand := Self;
      try
        try
          AddCursor(FRDWCommand.ExecuteQuery);
        except
          on E: EFDDBEngineException do begin
            E.Errors[0].RowIndex := i;
            raise;
          end;
        end;
      finally
        PhysConn.FCurrentCommand := nil;
        DeleteCursor(FRDWReader);
      end;

      if GetState <> csAborting then begin
        GetParamValues(GetParams, False);
        iAffected := FRDWCommand.RowsAffected;
        if iAffected <= -1 then
          iAffected := 0;
        Inc(ACount, iAffected);
      end
      else begin
        Break;
      end;
    end;
  end;
end;

function TFDPhysRDWCommand.InternalFetchRowSet(ATable: TFDDatSTable;
  AParentRow: TFDDatSRow; ARowsetSize: LongWord): LongWord;
var
  i: LongWord;
begin
  Result := 0;
  { TODO -oDelcio -cRDW : Implementar InternalFetchRowSet }
  if GetMetaInfoKind <> TFDPhysMetaInfoKind.mkNone then
    ARowsetSize := MaxInt;
  for i := 1 to ARowsetSize do begin
    if not FRDWReader.Next then
      Break;

    if GetMetaInfoKind = TFDPhysMetaInfoKind.mkNone then begin
      FetchRow(ATable, AParentRow);
      Inc(Result);
    end
    else if FetchMetaRow(ATable, AParentRow, i - 1) then begin
      Inc(Result);
    end;
  end;
end;

function TFDPhysRDWCommand.InternalNextRecordSet: Boolean;
begin
  { TODO -oDelcio -cRDW : Implementar InternalNextRecordSet }
  DeleteCursor(FRDWReader);
  if FReadersList.Count > 0 then
    FRDWReader := TRDWReader(FReadersList[0])
  else
    AddCursor(FRDWCommand.GetNextReader);
  Result := FRDWReader <> nil;
end;

function TFDPhysRDWCommand.InternalOpen{$if CompilerVersion > 31}(var ACount: TFDCounter){$IFEND}: Boolean;
var
  i: Word;
begin
  { TODO -oDelcio -cRDW : Implementar InternalOpen }
  {$if CompilerVersion > 31}
  ACount := 0;
  {$IFEND}
  if FRDWReader = nil then begin
    if GetMetaInfoKind = TFDPhysMetaInfoKind.mkNone then begin
      SetParamValues(GetParams, 0);
      // if PhysConn.FDbxConnection.DatabaseMetaData.SupportsRowSetSize then
      FRDWCommand.RowSetSize   := GetOptions.FetchOptions.ActualRowsetSize;
      PhysConn.FCurrentCommand := Self;
      try
        AddCursor(FRDWCommand.ExecuteQuery);
      finally
       {$if CompilerVersion > 31}
        ACount                   := FRDWCommand.RowsAffected;
       {$IFEND}
        PhysConn.FCurrentCommand := nil;
      end;

      if GetState = csAborting then
        InternalClose
      else
        GetParamValues(GetParams, True);
    end
    else begin
      OpenMetaInfo;
    end;

    if FRDWReader <> nil then begin
      if FRDWReader.Closed then
        InternalClose
      else begin
        // não precisamos
        // check buffer space
        // used for AnsiStr -> WideStr conversion, otherwise
        // buffer will have enough size
      end;
    end;
  end;
  Result := (FRDWReader <> nil);
end;

procedure TFDPhysRDWCommand.InternalPrepare;
var
  rName    : TFDPhysParsedName;
  oConnMeta: IFDPhysConnectionMetadata;
begin
   // generate metadata SQL command
  if GetMetaInfoKind <> FireDAC.Phys.Intf.mkNone then begin
    GetSelectMetaInfoParams(rName);
    GenerateSelectMetaInfo(rName);
    if FDbCommandText = '' then
      Exit;
  end
  else begin
    if GetCommandKind in [skStoredProc, skStoredProcWithCrs, skStoredProcNoCrs] then begin
      GetConnection.CreateMetadata(oConnMeta);

      oConnMeta.DecodeObjName(Trim(GetCommandText()), rName, Self, []);
      FDbCommandText := '';
      if fiMeta in GetOptions.FetchOptions.Items then
        GenerateStoredProcParams(rName);

      FDbCommandText := rName.FObject;
    end;
  end;

  GenerateLimitSelect();
  // adjust SQL command
  if GetCommandKind = skUnknown then
    SetCommandKind(skSelect);
  GenerateParamMarkers();

  if FRDWCommand <> nil then
    FRDWCommand.Free;
  { TODO -oDelcio -cRDW : Implementar InternalPrepare }
  FRDWCommand := CreateRDWCommand;
  FRDWCommand.Text           := FDbCommandText;
      // FRDWCommand.Parameters.SetCount(GetParams.Count);
  PhysConn.FCurrentCommand := Self;
  try
    FRDWCommand.Prepare;
    if GetParams.Count > 0 then
      CreateParams;
  finally
    PhysConn.FCurrentCommand := nil;
  end;

  SetLength(FParamChildPos, GetParams.Count);
end;

procedure TFDPhysRDWCommand.InternalUnprepare;
begin
  if FRDWCommand = nil then
    Exit;
  InternalClose;
  FDFreeAndNil(FRDWCommand);
  SetLength(FParamChildPos, 0);
end;

procedure TFDPhysRDWCommand.OpenMetaInfo;
const
  eSQLUnique      = $0002;
  eSQLPrimaryKey  = $0004;
var
  sCmd: String;
  rName: TFDPhysParsedName;
  sPKName, sUKName: String;
  oCmd: TRDWCommand;
  oRdr: TRDWReader;
  wDbxIndexKind: Word;
  oConnMeta: IFDPhysConnectionMetadata;

  procedure CreateMetadata;
  begin
    if oConnMeta = nil then
      PhysConn.CreateMetadata(oConnMeta);
  end;

  function GetObjWildcard(ANoObject, AObjectSepBySpace, AWildcardAllowed: Boolean;
    const AObjectToUse: String): String;
  var
    sPrev: String;
    rObjName: TFDPhysParsedName;
  begin
    CreateMetadata;
    oConnMeta.DecodeObjName(Trim(GetCommandText), rName, Self, [doUnquote]);
    if rName.FCatalog = '' then
      rName.FCatalog := GetCatalogName;
    if rName.FSchema = '' then
      rName.FSchema := GetSchemaName;
    if ANoObject then
      rName.FObject := '';
    if AObjectToUse <> '' then begin
      if rName.FBaseObject = '' then
        rName.FBaseObject := rName.FObject;
      rName.FObject := AObjectToUse;
    end;
    if AObjectSepBySpace then begin
      sPrev := rName.FObject;
      rName.FObject := '';
    end;
    Result := oConnMeta.EncodeObjName(rName, Self, [eoQuote, eoNormalize]);
    if AWildcardAllowed then begin
      if GetWildcard <> '' then
        Result := Result + '.' + GetWildcard
      else if Result = '' then
        Result := Result + '.%';
    end;
    if AObjectSepBySpace and (sPrev <> '') then begin
      rObjName.FObject := sPrev;
      Result := Result + ' ' + oConnMeta.EncodeObjName(rObjName, Self, [eoQuote, eoNormalize]);
      rName.FObject := sPrev;
    end;
  end;

begin
  if FDbCommandText <> '' then begin
    FRDWCommand := CreateRDWCommand;
    FRDWCommand.Text := FDbCommandText;
    PhysConn.FCurrentCommand := Self;
    try
      FRDWCommand.Prepare;
      FRDWCommand.CreateParams(GetParams);
      SetParamValues(GetParams, 0);
      AddCursor(FRDWCommand.ExecuteQuery);
    finally
      PhysConn.FCurrentCommand := nil;
    end;
  end
  else
    FRDWReader := nil;
end;

procedure TFDPhysRDWCommand.SetParamValues(AParams: TFDParams; AValueIndex: Integer);
begin
  FRDWCommand.SetParamValues(AParams, AValueIndex);
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

{ TRDWCommand }

procedure TRDWCommand.Close;
begin
  CloseReader;
  if FOpen then begin
    FOpen     := false;
    FPrepared := false;
  end;
end;

procedure TRDWCommand.CloseReader;
var
  _Reader: TRDWReader;
begin
  if FLastReader <> nil then begin
    _Reader     := FLastReader;
    FLastReader := nil;
    _Reader.CommandCloseReader;
    _Reader.FCommand := nil;
  end;
end;

procedure TRDWCommand.CommandExecuted;
begin

end;

procedure TRDWCommand.CommandExecuting;
begin
  Open;
  CloseReader;
  if (Parameters.Count > 0) then begin
    if not FPrepared then
      Prepare;
  end;
end;

constructor TRDWCommand.Create(aKind: TFDPhysCommandKind);
begin
  inherited Create;
  FCommandKind := aKind;
end;

procedure TRDWCommand.CreateParams(AFDParams: TFDParams);
var
  I:Integer;
begin
  for I := 0 to aFDparams.Count - 1 do begin
    with Parameters.AddParameter do begin
      Name      := aFDparams[I].Name;
      DataType  := aFDparams[I].DataType;
      ParamType := aFDparams[I].ParamType;
    end;
  end;
end;

destructor TRDWCommand.Destroy;
begin
  if FDsResult <> nil then begin
    FDFree(FDsResult);
    FDsResult := nil;
  end;
  CloseReader;
  inherited;
end;

function TRDWCommand.ExecuteQuery: TRDWReader;
var
  _Error       : Boolean;
  _MessageError: String;
begin
  Result := nil;
  if FText = '' then
    raise Exception.Create(' TRDWCommand.ExecuteQuery: No Statement to Execute');

  CommandExecuting;

  try
    case FCommandKind of
      skSelect, skSelectForLock, skSelectForUnLock:
        begin
          FDsResult.Open;
          FDsResult.First;
        end;
      skDelete, skInsert, skMerge, skUpdate, skCreate,
      skAlter, skDrop, skExecute, skSet:
        begin
          FDsResult.ExecSQL;
        end;
      { TODO -oDelcio -cRDW : Falta implementar TRDWCommand.ExecuteQuery para alguns tipos de comando }
      // skStoredProc: ;
      // skStoredProcWithCrs: ;
      // skStoredProcNoCrs: ;
      // skStartTransaction: ;
      // skCommit: ;
      // skRollback: ;
      // skSetSchema: ;
      // skOther: ;
      // skNotResolved: ;
    else raise Exception.Create('TRDWCommand: Tipo de comando(' + ord(FCommandKind).ToString +
        ') não suportado pelo driver RDW');
    end;

    FRowsAffected := FDsResult.RowsAffected;

    _Error := False;
  except
    on e: Exception do begin
      _Error        := True;
      FMessageError := e.Message;
      raise;
    end;
  end;

  if not _Error then begin
    Result := TRDWReader.Create;
  end;

  if Result <> nil then begin
    Result.FCommand := Self;
    FLastReader     := Result;
  end;
  CommandExecuted;
end;

function TRDWCommand.GetNextReader: TRDWReader;
begin
  CloseReader;
  { TODO -oDelcio -cRDW : Ver casos que necessitam de
    TRDWCommand.GetNextReader - pacotes de dados subsequentes ??? }
  Result := nil; // DerivedGetNextReader;
  if Assigned(Result) then
    Result.FCommand := Self;
end;

function TRDWCommand.GetParameters: TParams;
begin
  Open;
  Result := FDsResult.Params;
end;

procedure TRDWCommand.GetParamValues(AParams: TFDParams; AGetDataSets: Boolean);
var
  I     : Integer;
  _Param: TParam;
begin
  for I := 0 to AParams.Count - 1 do begin
    _Param := Parameters.FindParam(AParams[I].Name);
    if _Param <> nil then
      AParams[I].Value := _Param.Value
    else
      AParams[I].Value := null;
  end;
end;

procedure TRDWCommand.Open;
begin
  if not FOpen then
    FOpen := True;
end;

procedure TRDWCommand.Prepare;
begin
  Open;
  if FPrepared then
    raise Exception.Create('TRDWCommand.Prepare: Already Prepared');

  { TODO -oDelcio -cGeneral : Implementar  TRDWCommand.Prepare }
  if FDsResult = nil then begin
    FDsResult               := TRESTDWClientSQL.Create(nil);
    FDsResult.BinaryRequest := True;
    FDsResult.BinaryCompatibleMode := True;
    FDsResult.DataBase      := FDatabase;
  end;

  FDsResult.SQL.Text := FText;

  FPrepared := true;
end;

procedure TRDWCommand.SetParamValues(AParams: TFDParams; AValueIndex: Integer);
var
  I     : Integer;
  _Param: TParam;
begin
  for I := 0 to AParams.Count - 1 do begin
    _Param := Parameters.FindParam(AParams[I].Name);
    if _Param <> nil then
     _Param.Value := AParams[I].Values[AValueIndex];
  end;
end;

procedure TRDWCommand.SetRowSetSize(const Value: Int64);
begin
  FDsResult.Datapacks := Value;
end;

procedure TRDWCommand.SetText(const Value: string);
begin
  if (FOpen) and (FPrepared) and (FDsResult <> nil) and
     (FDsResult.ParamCount > 0) and (FText <> Value) then
    Close;
  FPrepared := False;
  FText     := Value;
end;

{ TRDWReader }

procedure TRDWReader.CloseReader;
var
  Ordinal: Integer;
begin
  if not FClosed then begin
    { TODO -oDelco -cGeneral : Ver se precisa liberar objetos em FCommand.FCmdResult }
    if (FCommand <> nil) and (FCommand.FDsResult <> nil) then
      FCommand.FDsResult.Close;
    FFirst := True;
  end;
  FClosed := true;
end;

procedure TRDWReader.CommandCloseReader;
begin
  CloseReader;
end;

constructor TRDWReader.Create;
begin
  Inherited Create;
  FFirst := True;
end;

destructor TRDWReader.Destroy;
begin

  inherited;
end;

function TRDWReader.GetColumnCount: Integer;
begin
  if (FCommand.FDsResult <> nil) then
    Result := FCommand.FDsResult.FieldCount
  else
    Result := 0;
end;

function TRDWReader.Next: Boolean;
begin
  Result := not FCommand.FDsResult.Eof;

  if Result then begin
    if FFirst and (FCommand.FDsResult.RecNo = 1) then
      FFirst := False
    else
      FCommand.FDsResult.Next;

    Result := not FCommand.FDsResult.Eof;
  end
  else begin
    // Unidirectional so free up underlying resources.
    if Assigned(FCommand) then
      FCommand.CloseReader;
    Result := False;
  end;
end;

end.
