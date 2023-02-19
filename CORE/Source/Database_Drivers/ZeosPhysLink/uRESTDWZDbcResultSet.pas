unit uRESTDWZDbcResultSet;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
uses
  System.Types, Contnrs, Classes, {$IFDEF MSEgui}mclasses,{$ENDIF} SysUtils, FmtBCD,
  ZSysUtils, ZDbcIntfs, ZDbcResultSet, ZDbcResultSetMetadata, uRESTDWZPlainDriver,
  ZCompatibility, ZDbcCache, ZDbcCachedResultSet, ZDbcGenericResolver, Variants,
  ZDbcMetadata, ZSelectSchema, ZDatasetUtils,
  uRESTDWZDbc, DB, uRESTDWConsts, uRESTDWTools;

type
  TZRESTDWResultSetMetadata = class(TZAbstractResultSetMetadata)
  protected
    procedure ClearColumn(ColumnInfo: TZColumnInfo); override;
  end;

  {** Implements RESTDW ResultSet. }
  TZRESTDWResultSet = class(TZAbstractReadOnlyResultSet, IZResultSet)
  private
    FConnection : TZRESTDWConnection;

    FStream : TStream;
    FEncodeStrs : boolean;
    FFieldCount : integer;
    FRecordPos : int64;
    FRecordCount : LongInt;
    FFieldTypes : array of byte;
    FVariantTable : array of array of Variant;

    FFirstRow : boolean;
  protected
    procedure Open; override;
  public
    constructor Create(const Statement: IZStatement; const SQL: string; Stream : TStream);

    procedure ResetCursor; override;

    function IsNull(ColumnIndex: Integer): Boolean;
    function GetPAnsiChar(ColumnIndex: Integer; out Len: NativeUInt): PAnsiChar; overload;
    function GetPWideChar(ColumnIndex: Integer; out Len: NativeUInt): PWideChar; overload;
    {$IFNDEF NO_UTF8STRING}
    function GetUTF8String(ColumnIndex: Integer): UTF8String;
    {$ENDIF}
    {$IFNDEF NO_ANSISTRING}
    function GetAnsiString(ColumnIndex: Integer): AnsiString;
    {$ENDIF}
    function GetBoolean(ColumnIndex: Integer): Boolean;
    function GetInt(ColumnIndex: Integer): Integer;
    function GetUInt(ColumnIndex: Integer): Cardinal;
    function GetLong(ColumnIndex: Integer): Int64;
    function GetULong(ColumnIndex: Integer): UInt64;
    function GetFloat(ColumnIndex: Integer): Single;
    function GetDouble(ColumnIndex: Integer): Double;
    function GetCurrency(ColumnIndex: Integer): Currency;
    procedure GetBigDecimal(ColumnIndex: Integer; var Result: TBCD);
    procedure GetGUID(ColumnIndex: Integer; var Result: TGUID);
    function GetBytes(ColumnIndex: Integer; out Len: NativeUInt): PByte; overload;
    procedure GetDate(ColumnIndex: Integer; Var Result: TZDate); reintroduce; overload;
    procedure GetTime(ColumnIndex: Integer; var Result: TZTime); reintroduce; overload;
    procedure GetTimestamp(ColumnIndex: Integer; Var Result: TZTimeStamp); reintroduce; overload;
    function GetBlob(ColumnIndex: Integer; LobStreamMode: TZLobStreamMode = lsmRead): IZBlob;

    function Next: Boolean; reintroduce;
    {$IFDEF WITH_COLUMNS_TO_JSON}
    procedure ColumnsToJSON(ResultsWriter: {$IFDEF MORMOT2}TResultsWriter{$ELSE}TJSONWriter{$ENDIF}; JSONComposeOptions: TZJSONComposeOptions);
    {$ENDIF WITH_COLUMNS_TO_JSON}
  end;

  {** Implements a cached resolver with RESTDW specific functionality. }
  TZRESTDWCachedResolver = class (TZGenerateSQLCachedResolver, IZCachedResolver)
  private
    FPlainDriver: TZRESTDWPlainDriver;
    FAutoColumnIndex: Integer;
  public
    constructor Create(const Statement: IZStatement; const Metadata: IZResultSetMetadata);

    procedure PostUpdates(const Sender: IZCachedResultSet; UpdateType: TZRowUpdateType;
      const OldRowAccessor, NewRowAccessor: TZRowAccessor); override;

    function CheckKeyColumn(ColumnIndex: Integer): Boolean; override;

    procedure UpdateAutoIncrementFields(const Sender: IZCachedResultSet;
      UpdateType: TZRowUpdateType; const OldRowAccessor, NewRowAccessor: TZRowAccessor;
      const Resolver: IZCachedResolver); override;
  end;

  { TZRESTDWCachedResultSet }

  TZRESTDWCachedResultSet = Class(TZCachedResultSet)
  protected
    class function GetRowAccessorClass: TZRowAccessorClass; override;
  end;

  { TZRESTDWRowAccessor }

  TZRESTDWRowAccessor = class(TZRowAccessor)
  protected
    class function MetadataToAccessorType(ColumnInfo: TZColumnInfo;
      ConSettings: PZConSettings; Var ColumnCodePage: Word): TZSQLType; override;
  end;

{$ENDIF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
implementation
{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit

uses
  ZMessages, ZTokenizer, ZVariant, ZEncoding, ZFastCode,
  ZGenericSqlAnalyser, uRESTDWProtoTypes;

{ TZRESTDWCachedResultSet }

class function TZRESTDWCachedResultSet.GetRowAccessorClass: TZRowAccessorClass;
begin
  Result := TZRESTDWRowAccessor;
end;

{ TZRESTDWRowAccessor }

{$IFDEF FPC} {$PUSH} {$WARN 5024 off : Parameter "ConSettings" not used} {$ENDIF}
class function TZRESTDWRowAccessor.MetadataToAccessorType(
  ColumnInfo: TZColumnInfo; ConSettings: PZConSettings; Var ColumnCodePage: Word): TZSQLType;
begin
  Result := ColumnInfo.ColumnType;
  if Result in [stAsciiStream, stUnicodeStream, stBinaryStream] then begin
    Result := TZSQLType(Byte(Result)-3); // no streams 4 RESTDW
    ColumnInfo.Precision := 0;
  end;
  if Result = stUnicodeString then
    Result := stString; // no national chars in RESTDW
end;
{$IFDEF FPC} {$POP} {$ENDIF}

{ TZRESTDWResultSet }

{$IFDEF WITH_COLUMNS_TO_JSON}
procedure TZRESTDWResultSet.ColumnsToJSON(ResultsWriter: {$IFDEF MORMOT2}TResultsWriter{$ELSE}TJSONWriter{$ENDIF};
  JSONComposeOptions: TZJSONComposeOptions);
begin

end;
{$ENDIF WITH_COLUMNS_TO_JSON}

constructor TZRESTDWResultSet.Create(const Statement: IZStatement;
            const SQL: string; Stream : TStream);
var
  Metadata: TContainedObject;
begin
  FConnection := TZRESTDWConnection(Statement.GetConnection);
  Metadata := TZRESTDWResultSetMetadata.Create(FConnection.GetMetadata,SQL,Self);
  inherited Create(Statement, SQL, MetaData, Statement.GetConnection.GetConSettings);
  FFirstRow := True;
  FStream := Stream;
  FStream.Position := 0;
  FRecordPos := 0;
  ResultSetConcurrency := rcReadOnly;
  Open;
end;

procedure TZRESTDWResultSet.Open;
var
  ColumnInfo: TZColumnInfo;

  i, j : int64;
  vFieldKind : TFieldKind;

  vBoolean : boolean;
  vString : ansistring;
  vInt : integer;
  vInt64 : int64;
  vDWFielType : Byte;
  vFieldType : TFieldType;
  vFieldSize : integer;
  vFieldPrecision : integer;
  vByte : Byte;
begin
  LastRowNo := 0;
  ColumnsInfo.Clear;

  FStream.Read(FFieldCount,SizeOf(integer));
  SetLength(FFieldTypes,FFieldCount);

  FStream.Read(vBoolean, Sizeof(vBoolean));
  FEncodeStrs := vBoolean;

  for i := 0 to FFieldCount-1 do begin
    ColumnInfo := TZColumnInfo.Create;
    with ColumnInfo do begin
      FStream.Read(vInt,SizeOf(Integer));
      vFieldKind := TFieldKind(vInt);

      FStream.Read(vInt,SizeOf(Integer));
      SetLength(vString,vInt);
      FStream.Read(vString[InitStrPos],vInt);

      ColumnName := vString;
      ColumnLabel := vString;
      TableName := '';
      CatalogName := '';

      ReadOnly := False;

      FStream.Read(vDWFielType,SizeOf(Byte));
      vFieldType := DWFieldTypeToFieldType(vDWFielType);
      FFieldTypes[i] := vDWFielType;

      ColumnType := ConvertDatasetToDbcType(vFieldType);

      FStream.Read(vFieldSize,SizeOf(Integer));

      FStream.Read(vFieldPrecision,SizeOf(Integer));

      FStream.Read(vByte,SizeOf(Byte));

      if ColumnType in [stString, stAsciiStream] then begin
        ColumnCodePage := zCP_UTF8;
        if ColumnType = stString then
          CharOctedLength := vFieldPrecision shl 2;
      end else if ColumnType = stBytes then
        CharOctedLength := vFieldPrecision;
      AutoIncrement := False;
      Precision := vFieldSize;
      Scale := vFieldPrecision;
      Writable := True;
      DefinitelyWritable := True;
      Signed := True;
      Searchable := True;

      Nullable := ntNoNulls;
      if vByte and 1 = 0 then
        Nullable := ntNullable;
    end;

    ColumnsInfo.Add(ColumnInfo);
  end;

  FStream.Read(FRecordCount,SizeOf(FRecordCount));
  FRecordPos := FStream.Position;

  SetLength(FVariantTable,FRecordCount);
  for i := 0 to FRecordCount-1 do begin
    SetLength(FVariantTable[i],FFieldCount);
    for j := 0 to FFieldCount-1 do begin
      FStream.Read(vBoolean,SizeOf(vBoolean));
      if vBoolean then begin
        FVariantTable[i,j] := variants.null;
        Continue;
      end;
      if FFieldTypes[j] = dwftInteger then begin
        FStream.Read(vInt,SizeOf(vInt));
        FVariantTable[i,j] := vInt;
      end
      else if FFieldTypes[j] = dwftString then begin
        FStream.Read(vInt64,SizeOf(vInt64));
        vString := '';
        SetLength(vString,vInt64);
        if vInt64 > 0 then
          FStream.Read(vString[InitStrPos],vInt64);
        FVariantTable[i,j] := vString;
      end;
    end;
  end;

  FStream.Size := 0;

  inherited Open;
  FCursorLocation := rctServer;
end;

procedure TZRESTDWResultSet.ResetCursor;
begin
  if not Closed then begin
    FStream.Position := 0;
    inherited ResetCursor;
  end;
end;

function TZRESTDWResultSet.IsNull(ColumnIndex: Integer): Boolean;
begin
  Result := FVariantTable[RowNo-1,ColumnIndex] = Null;
end;

function TZRESTDWResultSet.GetPAnsiChar(ColumnIndex: Integer; out Len: NativeUInt): PAnsiChar;
var
  vInt64 : int64;
  vString : ansistring;
  vBoolean : Boolean;
begin
  Result := PAnsiChar('');
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vString := FVariantTable[RowNo-1,ColumnIndex];
    Len := Length(vString)+1;
    Result := PAnsiChar(vString);
  end;
end;

function TZRESTDWResultSet.GetPWideChar(ColumnIndex: Integer;
  out Len: NativeUInt): PWideChar;
var
  P : PAnsiChar;
  S : AnsiString;
  W : WideString;
begin
  P := GetPAnsiChar(ColumnIndex, Len);
  SetLength(S,Len);
  S := P;
  W := S;
  Result := PWideChar(W);
  Len := Length(Result);
end;

{$IFNDEF NO_UTF8STRING}
function TZRESTDWResultSet.GetUTF8String(ColumnIndex: Integer): UTF8String;
var
  P: PAnsiChar;
  Len: NativeUint;
begin
  P := GetPAnsiChar(ColumnIndex, Len);
  {$IFDEF FPC}
  Result := '';
  {$ENDIF}
  if P <> nil
  {$IFDEF MISS_RBS_SETSTRING_OVERLOAD}
  then ZSetString(P, Len, result)
  {$ELSE}
  then System.SetString(Result, P, Len)
  {$ENDIF}
  {$IFNDEF WITH_VAR_INIT_WARNING}
  else Result := '';
  {$ENDIF}
end;
{$ENDIF}

function TZRESTDWResultSet.GetBoolean(ColumnIndex: Integer): Boolean;
begin

end;

function TZRESTDWResultSet.GetBytes(ColumnIndex: Integer;
  out Len: NativeUInt): PByte;
begin

end;

function TZRESTDWResultSet.GetInt(ColumnIndex: Integer): Integer;
var
  vInt : integer;
  vBoolean : Boolean;
begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vInt := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt;
  end;
end;

function TZRESTDWResultSet.GetLong(ColumnIndex: Integer): Int64;
var
  vInt64 : Int64;
  vBoolean : Boolean;
begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vInt64 := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt64;
  end;
end;

function TZRESTDWResultSet.GetUInt(ColumnIndex: Integer): Cardinal;
begin
  Result := GetLong(ColumnIndex);
end;

{$IF defined (RangeCheckEnabled) and defined(WITH_UINT64_C1118_ERROR)}{$R-}{$IFEND}
function TZRESTDWResultSet.GetULong(ColumnIndex: Integer): System.UInt64;
var
  vInt64 : UInt64;
  vBoolean : Boolean;
begin
  Result := 0;
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vInt64 := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt64;
  end;
end;
{$IF defined (RangeCheckEnabled) and defined(WITH_UINT64_C1118_ERROR)}{$R+}{$IFEND}

function TZRESTDWResultSet.GetFloat(ColumnIndex: Integer): Single;
begin
  Result := GetDouble(ColumnIndex);
end;

procedure TZRESTDWResultSet.GetGUID(ColumnIndex: Integer; var Result: TGUID);
begin

end;

function TZRESTDWResultSet.GetDouble(ColumnIndex: Integer): Double;
begin

end;

{$IFNDEF NO_ANSISTRING}
function TZRESTDWResultSet.GetAnsiString(ColumnIndex: Integer): AnsiString;
var
  P: PAnsiChar;
  L: NativeUInt;
begin
  P := GetPAnsiChar(ColumnIndex, L);
  if LastWasNull then
    Result := ''
//  else if (FPlainDriver.RESTDW3_column_type(FRESTDW3_stmt, ColumnIndex) <> RESTDW3_TEXT) or
//          (ZOSCodePage = zCP_UTF8) then
//    System.SetString(Result, P, L)
  else begin
    FUniTemp := PRawToUnicode(P, ZFastCode.StrLen(P), zCP_UTF8);
    Result := ZUnicodeToRaw(FUniTemp, ZOSCodePage);
  end
end;
{$ENDIF}

const BCDScales: array[Boolean] of Byte = (0,4);
procedure TZRESTDWResultSet.GetBigDecimal(ColumnIndex: Integer; var Result: TBCD);
begin

end;

function TZRESTDWResultSet.GetCurrency(ColumnIndex: Integer): Currency;
begin

end;

procedure TZRESTDWResultSet.GetDate(ColumnIndex: Integer; var Result: TZDate);
begin

end;

procedure TZRESTDWResultSet.GetTime(ColumnIndex: Integer; var Result: TZTime);
begin

end;

procedure TZRESTDWResultSet.GetTimestamp(ColumnIndex: Integer;
  var Result: TZTimeStamp);
begin

end;

function TZRESTDWResultSet.GetBlob(ColumnIndex: Integer;
  LobStreamMode: TZLobStreamMode = lsmRead): IZBlob;
begin

end;


function TZRESTDWResultSet.Next: Boolean;
begin
  Result := False;
  if Closed then
    Exit;

  if ((MaxRows > 0) and (RowNo >= MaxRows)) or (RowNo >= FRecordCount-1) then
    Exit;

  if FFirstRow then begin
    FFirstRow := False;
    Result := True;
    RowNo := 1;
    LastRowNo := 1;
    MaxRows := 0;
  end
  else begin
    RowNo := RowNo + 1;
    LastRowNo := RowNo;
    Result := True;
  end;
end;

function TZRESTDWCachedResolver.CheckKeyColumn(ColumnIndex: Integer): Boolean;
begin
  Result := (Metadata.GetTableName(ColumnIndex) <> '')
    and (Metadata.GetColumnName(ColumnIndex) <> '')
    and Metadata.IsSearchable(ColumnIndex)
    and not (Metadata.GetColumnType(ColumnIndex) in [stUnknown, stBinaryStream]);
end;

constructor TZRESTDWCachedResolver.Create(const Statement: IZStatement; const Metadata: IZResultSetMetadata);
var
  I: Integer;
begin
  inherited Create(Statement, Metadata);
  FPlainDriver := TZRESTDWPlainDriver(Statement.GetConnection.GetIZPlainDriver.GetInstance);

  { Defines an index of autoincrement field. }
  FAutoColumnIndex := 0;
  for I := FirstDbcIndex to Metadata.GetColumnCount{$IFDEF GENERIC_INDEX} - 1{$ENDIF} do
    if Metadata.IsAutoIncrement(I) and
      (Metadata.GetColumnType(I) in [stByte, stShort, stSmall, stLongWord,
        stInteger, stUlong, stLong]) then
    begin
      FAutoColumnIndex := I;
      Break;
    end;
end;

procedure TZRESTDWCachedResolver.PostUpdates(const Sender: IZCachedResultSet;
  UpdateType: TZRowUpdateType; const OldRowAccessor, NewRowAccessor: TZRowAccessor);
begin
  inherited PostUpdates(Sender, UpdateType, OldRowAccessor, NewRowAccessor);

  if (UpdateType = utInserted) then
    UpdateAutoIncrementFields(Sender, UpdateType, OldRowAccessor, NewRowAccessor, Self);
end;

procedure TZRESTDWCachedResolver.UpdateAutoIncrementFields(
  const Sender: IZCachedResultSet; UpdateType: TZRowUpdateType; const
  OldRowAccessor, NewRowAccessor: TZRowAccessor; const Resolver: IZCachedResolver);
begin
  inherited;
end;

{ TZRESTDWResultSetMetadata }

procedure TZRESTDWResultSetMetadata.ClearColumn(ColumnInfo: TZColumnInfo);
begin
  inherited;
  ColumnInfo.ReadOnly := False;
  ColumnInfo.Writable := True;
  ColumnInfo.DefinitelyWritable := True;
end;

{$ENDIF ZEOS_DISABLE_RESTDW} //if set we have an empty unit

end.
