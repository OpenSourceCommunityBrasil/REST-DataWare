unit FireDAC.Phys.RESTDWBase;

{$I ..\Includes\uRESTDWPlataform.inc}

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
  FireDAC.DatS, Firedac.Stan.Option, Variants,
  uRESTDWBasicDB, DB, uRESTDWPoolermethod, uRESTDWProtoTypes, FireDAC.Phys.RESTDWMeta;

type
  TFDPhysRDWConnectionBase = class;

  TFDPhysRDWBaseDriverLink = class(TFDPhysDriverLink)
  private
    FDatabase : TRESTDWDatabasebaseBase;
    FRDBMS : TFDRDBMSKind;
  protected
    function GetBaseDriverID: String; override;
    function IsConfigured: Boolean; override;
  published
    property Database : TRESTDWDatabasebaseBase read FDatabase write FDatabase;
    property RDBMS: TFDRDBMSKind read FRDBMS write FRDBMS;
  end;

  TFDPhysRDWDriverBase = class(TFDPhysDriver)
  protected
    procedure InternalLoad; override;
    procedure InternalUnload; override;
  public
    constructor Create(AManager: TFDPhysManager; const ADriverDef: IFDStanDefinition); override;
    destructor Destroy; override;
  end;

  TFDPhysRDWConnectionBase = class(TFDPhysConnection)
  private
    FDatabase : TRESTDWDatabasebaseBase;
    procedure findDatabase;
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
  public
    constructor Create(ADriverObj: TFDPhysDriver; AConnHost: TFDPhysConnectionHost); override;
    destructor Destroy; override;
  published
    property Database : TRESTDWDatabasebaseBase read FDatabase;
  end;

  TFDPhysRDWTransaction = class(TFDPhysTransaction)
  protected
    procedure InternalStartTransaction(AID: LongWord); override;
    procedure InternalCommit(AID: LongWord); override;
    procedure InternalRollback(AID: LongWord); override;
  end;

  TFDPhysRDWCommand = class(TFDPhysCommand)
  private
    FStream : TMemoryStream;
    FColumnIndex : integer;
    FEncodeStrs : boolean;
    FFieldCount : integer;
    FRecordCount : Longint;
    FFieldTypes : array of integer;
    FInfoMetada : TStringList;
    procedure FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
    procedure FetchMetaRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow; ARow : integer);

    function readFieldStream : TFDPhysDataColumnInfo;
    function readDataStream(col : integer) : Variant;
    procedure readStreamFields;

    function RDWExecuteComand(exec : boolean = False) : Longint;
    function RDWGetTables : integer;
    function RDWGetTablesFields(tabela : string) : integer;
    function RDWGetPKTablesFields(tabela : string) : integer;
  protected
    procedure InternalPrepare; override;
    procedure InternalUnprepare; override;
    function InternalOpen{$IF CompilerVersion > 31}(var ACount: TFDCounter){$IFEND}: Boolean; override;
    function InternalNextRecordSet: Boolean; override;
    procedure InternalClose; override;
    procedure InternalExecute(ATimes, AOffset: Integer; var ACount: TFDCounter); override;
    function InternalColInfoStart(var ATabInfo: TFDPhysDataTableInfo): Boolean; override;
    function InternalColInfoGet(var AColInfo: TFDPhysDataColumnInfo): Boolean; override;
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
  uRESTDWTools, uRESTDWBasicTypes;

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

constructor TFDPhysRDWConnectionBase.Create(ADriverObj: TFDPhysDriver;
  AConnHost: TFDPhysConnectionHost);
begin
  inherited;
  FDatabase := nil;
end;

destructor TFDPhysRDWConnectionBase.Destroy;
begin
  if Assigned(FDatabase) then
    FDatabase.Close;
  FDatabase := nil;
  inherited;
end;

procedure TFDPhysRDWConnectionBase.findDatabase;
var
  rdwDriver : TFDPhysRDWBaseDriverLink;
begin
  rdwDriver := TFDPhysRDWBaseDriverLink(DriverObj.Manager.FindDriverLink(DriverObj.DriverID));
  if Assigned(rdwDriver) then
    FDatabase := rdwDriver.Database;
end;

procedure TFDPhysRDWConnectionBase.InternalConnect;
begin
  if not Assigned(FDatabase) then
    findDatabase;

  if not Assigned(FDatabase) then
    raise Exception.Create('Database not assigned');

  FDatabase.Active := True;
end;

function TFDPhysRDWConnectionBase.InternalCreateCommand: TFDPhysCommand;
begin
  Result := TFDPhysRDWCommand.Create(Self);
end;

function TFDPhysRDWConnectionBase.InternalCreateCommandGenerator(
  const ACommand: IFDPhysCommand): TFDPhysCommandGenerator;
begin
  if Assigned(ACommand) then
    Result := TFDPhysRDWCommandGenerator.Create(ACommand)
  else
    Result := TFDPhysRDWCommandGenerator.Create(Self);
end;

function TFDPhysRDWConnectionBase.InternalCreateMetadata: TObject;
begin
  Result := TFDPhysRDWMetadata.Create(Self,1,0,False);
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

procedure TFDPhysRDWCommand.FetchMetaRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow; ARow : integer);
var
//  oCol    : TFDDatSColumn;
  oRow    : TFDDatSRow;
  j       : Integer;
  oFmtOpts: TFDFormatOptions;
//  ss : TStringList;
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
    if GetMetaInfoKind = mkPrimaryKeyFields then begin
      oRow.SetData(0, ARow); // RECNO
      oRow.SetData(1, null); // CATALOG_NAME
      oRow.SetData(2, null); // SCHEMA_NAME
      oRow.SetData(3, GetBaseObjectName); // TABLE_NAME
      oRow.SetData(4, null); // INDEX_NAME
      oRow.SetData(5, Trim(FInfoMetada.Strings[ARow])); // CONSTRAINT_NAME
      oRow.SetData(6, ARow); // INDEX_TYPE
    end
    else if GetMetaInfoKind = mkTables then begin
      oRow.SetData(0, ARow); // RECNO
      oRow.SetData(1, null); // CATALOG_NAME
      oRow.SetData(2, null); // SCHEMA_NAME
      oRow.SetData(3, Trim(FInfoMetada.Strings[ARow])); // TABLE_NAME
      oRow.SetData(4, ctTable); // TABLE_TYPE
    end
    else if GetMetaInfoKind = mkTableFields then begin
      oRow.SetData(0, ARow); // RECNO
      oRow.SetData(1, null); // CATALOG_NAME
      oRow.SetData(2, null); // SCHEMA_NAME
      oRow.SetData(3, GetBaseObjectName); // TABLE_NAME
      oRow.SetData(4, Trim(FInfoMetada.Strings[ARow])); // COLUMN_NAME
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

procedure TFDPhysRDWCommand.FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
var
  oCol    : TFDDatSColumn;
  oRow    : TFDDatSRow;
  j       : Integer;
  pData   : Variant;
  oFmtOpts: TFDFormatOptions;
begin
  oRow     := ATable.NewRow(True);
  oFmtOpts := GetOptions.FormatOptions;
  try
    for j := 0 to ATable.Columns.Count - 1 do begin
      oCol := ATable.Columns[j];
      if (oCol.SourceID >= 0) and CheckFetchColumn(oCol.SourceDataType, oCol.Attributes) then begin
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

function TFDPhysRDWCommand.InternalColInfoGet(
  var AColInfo: TFDPhysDataColumnInfo): Boolean;
var
  b : boolean;
begin
  if GetMetaInfoKind <> mkNone then begin
    Result := False;
    Exit;
  end;

  if FStream.Size = 0 then begin
    Result := False;
    Exit;
  end;

  if FFieldCount = -1 then begin
    FStream.Position := 0;
    FStream.Read(FFieldCount,SizeOf(integer));
    SetLength(FFieldTypes,FFieldCount);

    FStream.Read(b, Sizeof(Byte));
    FEncodeStrs := b;
  end;

  if FColumnIndex >= FFieldCount then begin
    Result := False;
    Exit;
  end;

  AColInfo := readFieldStream;

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
      FFieldCount          := -1;
      FRecordCount         := -1;
     end
    else begin
      raise Exception.Create('TFDPhysRDWCommand.InternalColInfoStart');
      ATabInfo.FSourceID := ATabInfo.FSourceID;
    end;
  end;
end;

procedure TFDPhysRDWCommand.InternalExecute(ATimes, AOffset: Integer;
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

  if GetMetaInfoKind in [mkTables,mkTableFields,mkPrimaryKeyFields] then begin
    ARowsetSize := FInfoMetada.Count;

    for i := 1 to ARowsetSize do begin
      FetchMetaRow(ATable, AParentRow, i-1);
      Inc(Result);
    end
  end
  else if GetMetaInfoKind = mkNone then begin
    if FRecordCount = -1 then begin
      if FStream.Position = 0 then
        readStreamFields;
      FStream.Read(FRecordCount,SizeOf(Longint));
    end;

    for i := 1 to ARowsetSize do begin
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

function TFDPhysRDWCommand.InternalOpen{$IF CompilerVersion > 31}(var ACount: TFDCounter){$IFEND}: Boolean;
begin
 {$IF CompilerVersion > 31}
  ACount := -1;
 {$IFEND}
  Result := False;
  if GetMetaInfoKind = mkNone then begin
   {$IF CompilerVersion > 31}
    ACount := RDWExecuteComand;
    Result := ACount >= 0;
   {$ELSE}
    Result := RDWExecuteComand >= 0;
   {$IFEND}
  end
  else if GetMetaInfoKind = mkTables then begin
   {$IF CompilerVersion > 31}
    ACount := RDWGetTables;
    Result := ACount >= 0;
   {$ELSE}
    Result := RDWGetTables >= 0;
   {$IFEND}
    if Result then
      Self.SetState(csOpen);
  end
  else if GetMetaInfoKind = mkPrimaryKeyFields then begin
   {$IF CompilerVersion > 31}
    ACount := RDWGetPKTablesFields(GetBaseObjectName);
    Result := ACount >= 0;
   {$ELSE}
    Result := RDWGetPKTablesFields(GetBaseObjectName) >= 0;
   {$IFEND}
    if Result then
      Self.SetState(csOpen);
  end
  else if GetMetaInfoKind = mkTableFields then begin
   {$IF CompilerVersion > 31}
    ACount := RDWGetTablesFields(GetBaseObjectName);
    Result := ACount >= 0;
   {$ELSE}
    Result := RDWGetTablesFields(GetBaseObjectName) >= 0;
   {$IFEND}
    if Result then
      Self.SetState(csOpen);
  end;
end;

procedure TFDPhysRDWCommand.InternalPrepare;
//var
//  rName: TFDPhysParsedName;
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

function TFDPhysRDWCommand.RDWExecuteComand(exec: boolean) : Longint;
var
  sSQL : string;
  vSQL : TStringList;
  vRESTDataBase : TRESTDWDatabasebaseBase;
  vParams : TParams;
  vError : boolean;
  vMessageError : string;
  vDataSetList : TJSONValue;
  vRowsAffected : integer;
  vPoolermethod : TRESTDWPoolerMethodClient;

  procedure addParams(AFDParams : TFDParams);
  var
    i : integer;
  begin
    for I := 0 to AFDParams.Count - 1 do begin
      with vParams.AddParameter do begin
        Name      := AFDParams[I].Name;
        DataType  := AFDParams[I].DataType;
        ParamType := AFDParams[I].ParamType;
        Value     := AFDParams[I].Value;
      end;
    end;
  end;
begin
  Result := -1;
  sSQL := GetCommandText;
  if Trim(sSQL) <> '' then begin
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
                                   vMessageError, vDataSetList, vRowsAffected,
                                   exec, (not exec), (not exec), False,
                                   vRESTDataBase.RESTClientPooler);
      FStream.Size := 0;
      if (vDataSetList <> nil) and (not vDataSetList.IsNull) then
        vDataSetList.SaveToStream(FStream);
    finally
      FreeAndNil(vDataSetList);
    end;

    vSQL.Free;
    vParams.Free;

    if not vError then begin

      Result := vRowsAffected;
      if exec then
        Result := vRowsAffected;
    end
    else begin
      Result := -1;
      raise Exception.Create(vMessageError);
    end;
  end
  else begin
    raise Exception.Create('Comando SQL em branco');
  end;
end;

function TFDPhysRDWCommand.RDWGetPKTablesFields(tabela : string) : integer;
var
  vRESTDataBase : TRESTDWDatabasebaseBase;
begin
  vRESTDataBase := TFDPhysRDWConnectionBase(FConnection).Database;
  Result := -1;

  FInfoMetada.Clear;
  try
    vRESTDataBase.GetKeyFieldNames(tabela,FInfoMetada);
    Result := FInfoMetada.Count;
    if Result = 0 then
      Result := -1;
  finally

  end;
end;

function TFDPhysRDWCommand.RDWGetTables: integer;
var
  vRESTDataBase : TRESTDWDatabasebaseBase;
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

function TFDPhysRDWCommand.RDWGetTablesFields(tabela : string) : integer;
var
  vRESTDataBase : TRESTDWDatabasebaseBase;
begin
  vRESTDataBase := TFDPhysRDWConnectionBase(FConnection).Database;
  Result := -1;

  FInfoMetada.Clear;
  try
    vRESTDataBase.GetFieldNames(tabela,FInfoMetada);
    Result := FInfoMetada.Count;
    if Result = 0 then
      Result := -1;
  finally

  end;
end;

function TFDPhysRDWCommand.readDataStream(col: integer): Variant;
var
  L : longInt;
  J : integer;
  R : Real;
  E : Extended;
  S : ansistring;
  Cr : Currency;
  P : TStringStream;
  Bool : boolean;
begin
  Result := null;

  FStream.Read(Bool, Sizeof(Byte));

  // is null
  if Bool then
    Exit;

  case FFieldTypes[col] of
    dwftFixedChar,
    dwftWideString,
    dwftString : begin
                FStream.Read(L, Sizeof(L));
                S := '';
                if L > 0 then begin
                  SetLength(S, L);
                  {$IFDEF FPC}
                   Stream.Read(Pointer(S)^, L);
                   if FEncodeStrs then
                     S := DecodeStrings(S);
                   S := GetStringEncode(S, FDatabaseCharSet);
                  {$ELSE}
                   FStream.Read(S[InitStrPos], L);
                   if FEncodeStrs then
                     S := DecodeStrings(S);
                  {$ENDIF}
                end;
                Result := S;
    end;
    dwftByte,
    dwftShortint,
    dwftSmallint,
    dwftWord,
    dwftInteger,
    dwftAutoInc :  Begin
                FStream.Read(J, Sizeof(Integer));
                Result := J;
    end;
    dwftSingle   : begin
                FStream.Read(R, Sizeof(Real));
                Result := R;
    end;
    dwftExtended : begin
                FStream.Read(R, Sizeof(Real));
                Result := R;
    end;
    dwftFloat    : begin
                FStream.Read(R, Sizeof(Real));
                Result := R;
    end;
    dwftFMTBcd,
    dwftCurrency,
    dwftBCD     :  begin
                FStream.Read(Cr, Sizeof(Currency));
                Result := Cr;
    end;
    dwftTimeStampOffset,
    dwftDate,
    dwftTime,
    dwftDateTime,
    dwftTimeStamp : begin
                FStream.Read(R, Sizeof(Real));
                Result := R;
    End;
    dwftLongWord,
    dwftLargeint : begin
                FStream.Read(L, Sizeof(LongInt));
                Result := L
    end;
    dwftBoolean  : begin
                FStream.Read(Bool, Sizeof(Byte));
                Result := Bool
    End;
    dwftMemo,
    dwftWideMemo,
    dwftStream,
    dwftFmtMemo,
    dwftBlob,
    dwftBytes : begin
                FStream.Read(L, Sizeof(LongInt));
                if L > 0 then Begin
                  P := TStringStream.Create;
                  try
                    P.CopyFrom(FStream, L);
                    P.Position := 0;
                    Result := p.DataString;
                  finally
                   P.Free;
                  end;
                end;
    end;
    else begin
                FStream.Read(L, Sizeof(L));
                S := '';
                if L > 0 then begin
                  SetLength(S, L);
                  {$IFDEF FPC}
                   Stream.Read(Pointer(S)^, L);
                   if FEncodeStrs then
                     S := DecodeStrings(S);
                   S := GetStringEncode(S, FDatabaseCharSet);
                  {$ELSE}
                   FStream.Read(S[InitStrPos], L);
                   if FEncodeStrs then
                     S := DecodeStrings(S);
                  {$ENDIF}
                end;
                Result := S;
    end;
  end;
end;

function TFDPhysRDWCommand.readFieldStream: TFDPhysDataColumnInfo;
var
  fk : TFieldKind;
  j : integer;
  s : ansistring;
  b : boolean;
  rft : Byte;

  ft : TFieldType;
  fs : Integer;
  fp : integer;

  datType : TFDDataType;
  datSize : LongWord;
  datPrec : integer;
  datScale : integer;
  datAttrs : TFDDataAttributes;

  oFmtOpts: TFDFormatOptions;
begin
  if FStream.Size = 0 then
    Exit;

  oFmtOpts := FOptions.FormatOptions;
  FStream.Read(j,SizeOf(Integer));
  fk := TFieldKind(j);

  FStream.Read(j,SizeOf(Integer));
  SetLength(s,j);
  FStream.Read(s[InitStrPos],j);

  Result.FSourceName := s;
  Result.FOriginColName := s;

  FStream.Read(rft,SizeOf(Byte));
  ft := DWFieldTypeToFieldType(rft);
  FFieldTypes[FColumnIndex] := rft;

  FStream.Read(fs,SizeOf(Integer));

  FStream.Read(fp,SizeOf(Integer));

  FStream.Read(b,SizeOf(Byte)); // somente pra position

  oFmtOpts.FieldDef2ColumnDef(ft,fs,fp,0,datType,datSize,datPrec,datScale,datAttrs);

  Result.FSourceID   := FColumnIndex;
  Result.FSourceType := datType;

  if GetMetaInfoKind = mkNone then begin
    oFmtOpts.ResolveDataType(Result.FSourceName, Result.FSourceName,
          datType, datSize, datPrec,
          datScale, datType, datSize, True);
  end;

  Result.FType       := datType;
  Result.FOriginTabName.FCatalog := 'paciente';

  if datAttrs = [] then begin
    datAttrs := datAttrs + [caBase];

    if not b then
      datAttrs := datAttrs + [caAllowNull];

    if datType in [dtBlob,dtMemo,dtWideMemo,dtXML,dtHBlob,dtHMemo,dtWideHMemo,dtHBFile] then
      datAttrs := datAttrs + [caBlobData]
    else
      datAttrs := datAttrs + [caSearchable];
  end;

//  Result.FOriginTabName := OriginTabName;
  Result.FAttrs := datAttrs;

  Result.FLen := datSize;
  if b then
    Result.FForceAddOpts := Result.FForceAddOpts + [coInKey]
  else
    Result.FForceAddOpts := Result.FForceAddOpts + [coAllowNull];

  Result.FPrec  := datPrec;
  Result.FScale := datScale;
end;

procedure TFDPhysRDWCommand.readStreamFields;
var
  i : integer;
begin
  FStream.Position := 0;
  FStream.Read(FFieldCount,SizeOf(integer));
  SetLength(FFieldTypes,FFieldCount);

  FStream.Read(FEncodeStrs, Sizeof(Byte));

  for i := 0 to FFieldCount-1 do begin
    FColumnIndex := i;
    readFieldStream;
  end;
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

end.
