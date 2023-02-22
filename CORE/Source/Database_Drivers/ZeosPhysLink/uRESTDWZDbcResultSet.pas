unit uRESTDWZDbcResultSet;

interface

{$I ZDbc.inc}

{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
uses
  Classes, SysUtils, Types, Contnrs, FmtBCD, ZSysUtils, ZDbcIntfs, ZDbcResultSet,
  ZDbcResultSetMetadata, ZCompatibility, ZDbcCache, ZDbcCachedResultSet,
  ZDbcGenericResolver, Variants, ZDbcMetadata, ZSelectSchema, ZDatasetUtils,
  uRESTDWZDbc, uRESTDWZPlainDriver, DB, uRESTDWConsts, uRESTDWTools;

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
    procedure streamToArray;
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
  ZGenericSqlAnalyser, uRESTDWProtoTypes, SqlTimSt;

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

  streamToArray;

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

procedure TZRESTDWResultSet.streamToArray;
var
  i, j          : integer;
  vString       : DWString;
  vInt64        : Int64;
  vInt          : Integer;
  vByte         : Byte;
  vBoolean      : Boolean;
  vWord         : Word;
  vSingle       : Single;
  vDouble       : Double;
  VTimeZone     : Double;
  vCurrency     : Currency;
  vStringStream : TStringStream;
  {$IFNDEF FPC}
    {$IF CompilerVersion >= 21}
      vTimeStampOffset : TSQLTimeStampOffset;
    {$IFEND}
  {$ENDIF}
begin
  SetLength(FVariantTable,FRecordCount);
  for i := 0 to FRecordCount-1 do begin
    SetLength(FVariantTable[i],FFieldCount);
    for j := 0 to FFieldCount-1 do begin
      FStream.Read(vBoolean,SizeOf(vBoolean));
      if vBoolean then begin
        FVariantTable[i,j] := variants.null;
        Continue;
      end;

      // N - Bytes
      if (FFieldTypes[j] in [dwftFixedChar,dwftString]) then begin
        FStream.Read(vInt64, Sizeof(vInt64));
        vString := '';
        if vInt64 > 0 then begin
          SetLength(vString, vInt64);
          {$IFDEF FPC}
           Stream.Read(Pointer(vString)^, vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString);
           vString := GetStringEncode(vString, FDatabaseCharSet);
          {$ELSE}
           FStream.Read(vString[InitStrPos], vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString);
          {$ENDIF}
        end;
        if System.Pos(#0,vString) > 0 then
          vString := StringReplace(vString, #0, '', [rfReplaceAll]);
        FVariantTable[i,j] := vString;
      end
      // N - Bytes Wide
      else if (FFieldTypes[j] in [dwftWideString,dwftFixedWideChar]) then begin
        FStream.Read(vInt64, Sizeof(vInt64));
        vString := '';
        if vInt64 > 0 then begin
          SetLength(vString, vInt64);
          {$IFDEF FPC}
           Stream.Read(Pointer(vString)^, vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString);
           vString := GetStringEncode(vString, FDatabaseCharSet);
          {$ELSE}
           FStream.Read(vString[InitStrPos], vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString);
          {$ENDIF}
        end;
        if System.Pos(#0,vString) > 0 then
          vString := StringReplace(vString, #0, '', [rfReplaceAll]);
        FVariantTable[i,j] := vString;
      end
      // 1 - Byte - Inteiros
      else if (FFieldTypes[j] in [dwftByte,dwftShortint]) then
      begin
        FStream.Read(vByte, Sizeof(vByte));
        FVariantTable[i,j] := vByte;
      end
      // 1 - Byte - Boolean
      else if (FFieldTypes[j] in [dwftBoolean]) then
      begin
        FStream.Read(vBoolean, Sizeof(vBoolean));
        FVariantTable[i,j] := vBoolean;
      end
      // 2 - Bytes
      else if (FFieldTypes[j] in [dwftSmallint,dwftWord]) then begin
        FStream.Read(vWord, Sizeof(vWord));
        FVariantTable[i,j] := vWord;
      end
      // 4 - Bytes - Inteiros
      else if (FFieldTypes[j] in [dwftInteger]) then
      begin
        FStream.Read(vInt, Sizeof(vInt));
        FVariantTable[i,j] := vInt;
      end
      // 4 - Bytes - Flutuantes
      else if (FFieldTypes[j] in [dwftSingle]) then
      begin
        FStream.Read(vSingle, Sizeof(vSingle));
        FVariantTable[i,j] := vSingle;
      end
      // 8 - Bytes - Inteiros
      else if (FFieldTypes[j] in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
      begin
        FStream.Read(vInt64, Sizeof(vInt64));
        FVariantTable[i,j] := vInt64;
      end
      // 8 - Bytes - Flutuantes
      else if (FFieldTypes[j] in [dwftFloat,dwftExtended]) then
      begin
        FStream.Read(vDouble, Sizeof(vDouble));
        FVariantTable[i,j] := vDouble;
      end
      // 8 - Bytes - Date, Time, DateTime, TimeStamp
      else if (FFieldTypes[j] in [dwftDate,dwftTime,dwftDateTime,dwftTimeStamp]) then
      begin
        FStream.Read(vDouble, Sizeof(vDouble));
        FVariantTable[i,j] := vDouble;
      end
      // TimeStampOffSet To Double - 8 Bytes
      // + TimeZone                - 2 Bytes
      else if (FFieldTypes[j] in [dwftTimeStampOffset]) then begin
        {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
          FStream.Read(vDouble, Sizeof(vDouble));

          vTimeStampOffSet := DateTimeToSQLTimeStampOffset(vDouble);

          FStream.Read(vByte, Sizeof(vByte));
          vTimeStampOffSet.TimeZoneHour := vByte - 12;

          FStream.Read(vByte, Sizeof(vByte));
          vTimeStampOffSet.TimeZoneMinute := vByte;

          FVariantTable[i,j] := VarSQLTimeStampOffsetCreate(vTimeStampOffset);
        {$ELSE}
          // field foi transformado em datetime
          FStream.Read(vDouble, Sizeof(vDouble));
          FStream.Read(vByte, SizeOf(vByte));
          vTimeZone := (vByte - 12) / 24;

          FStream.Read(vByte, SizeOf(vByte));
          if vTimeZone > 0 then
            vTimeZone := vTimeZone + (vByte / 60 / 24)
          else
            vTimeZone := vTimeZone - (vByte / 60 / 24);

          vDouble := vDouble - vTimeZone;
          FVariantTable[i,j] := vDouble;
        {$IFEND}
      end
      // 8 - Bytes - Currency
      else if (FFieldTypes[j] in [dwftCurrency,dwftBCD,dwftFMTBcd]) then
      begin
        FStream.Read(vCurrency, Sizeof(vCurrency));
        FVariantTable[i,j] := vCurrency;
      end
      // N Bytes - Wide Memos
      else if (FFieldTypes[j] in [dwftMemo,dwftWideMemo,dwftFmtMemo]) then begin
        FStream.Read(vInt64, Sizeof(vInt64));
        if vInt64 > 0 then Begin
          vStringStream := TStringStream.Create;
          try
            vStringStream.CopyFrom(FStream, vInt64);
            vStringStream.Position := 0;
    //        Result := TEncoding.Unicode.GetString(vStringStream.Bytes);
            vString := vStringStream.DataString;
            if System.Pos(#0,vString) > 0 then
              vString := StringReplace(vString, #0, '', [rfReplaceAll]);
          finally
            vStringStream.Free;
          end;
          FVariantTable[i,j] := vString;
        end;
      end
      // N Bytes - Memos e Blobs
      else if (FFieldTypes[j] in [dwftStream,dwftBlob,dwftBytes]) then begin
        FStream.Read(vInt64, Sizeof(vInt64));
        if vInt64 > 0 then Begin
          vStringStream := TStringStream.Create;
          try
            vStringStream.CopyFrom(FStream, vInt64);
            vStringStream.Position := 0;

            FVariantTable[i,j] := vStringStream.Bytes;
          finally
            vStringStream.Free;
          end;
        end;
      end
      else begin
        FStream.Read(vInt64, Sizeof(vInt64));
        vString := '';
        if vInt64 > 0 then begin
          SetLength(vString, vInt64);
          {$IFDEF FPC}
           Stream.Read(Pointer(vString)^, vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString);
           vString := GetStringEncode(vString, FDatabaseCharSet);
          {$ELSE}
           FStream.Read(vString[InitStrPos], vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString);
          {$ENDIF}
        end;
        if System.Pos(#0,vString) > 0 then
          vString := StringReplace(vString, #0, '', [rfReplaceAll]);
        FVariantTable[i,j] := vString;
      end;
    end;
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
var
  vBoolean : Boolean;
begin
  Result := False;
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vBoolean := FVariantTable[RowNo-1,ColumnIndex];
    Result := vBoolean;
  end;
end;

function TZRESTDWResultSet.GetBytes(ColumnIndex: Integer;
  out Len: NativeUInt): PByte;
var
  vBytes : TBytes;
begin
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vBytes := TBytes(FVariantTable[RowNo-1,ColumnIndex]);
    Result := PByte(vBytes);
    Len := Length(vBytes);
  end;
end;

function TZRESTDWResultSet.GetInt(ColumnIndex: Integer): Integer;
var
  vInt : integer;
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
var
  vString : string;
begin
  vString := GetString(ColumnIndex);
  if not LastWasNull then
    Result := StringToGUID(vString);
end;

function TZRESTDWResultSet.GetDouble(ColumnIndex: Integer): Double;
var
  vDouble : Double;
begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vDouble := FVariantTable[RowNo-1,ColumnIndex];
    Result := vDouble;
  end;
end;

{$IFNDEF NO_ANSISTRING}
function TZRESTDWResultSet.GetAnsiString(ColumnIndex: Integer): AnsiString;
var
  P: PAnsiChar;
  L: NativeUInt;
begin
  P := GetPAnsiChar(ColumnIndex, L);
  Result := '';
  if not LastWasNull then begin
    FUniTemp := PRawToUnicode(P, ZFastCode.StrLen(P), zCP_UTF8);
    Result := ZUnicodeToRaw(FUniTemp, ZOSCodePage);
  end
end;
{$ENDIF}

procedure TZRESTDWResultSet.GetBigDecimal(ColumnIndex: Integer; var Result: TBCD);
var
  vCurrency : Currency;
begin
  vCurrency := GetCurrency(ColumnIndex);
  if not LastWasNull then
    Result := CurrencyToBcd(vCurrency);
end;

function TZRESTDWResultSet.GetCurrency(ColumnIndex: Integer): Currency;
var
  vCurrency : Currency;
begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then begin
    vCurrency := FVariantTable[RowNo-1,ColumnIndex];
    Result := vCurrency;
  end;
end;

procedure TZRESTDWResultSet.GetDate(ColumnIndex: Integer; var Result: TZDate);
var
  vDouble : Double;
begin
  vDouble := GetDouble(ColumnIndex);
  if not LastWasNull then
    Result := TZAnyValue.CreateWithDouble(vDouble).GetDate;
end;

procedure TZRESTDWResultSet.GetTime(ColumnIndex: Integer; var Result: TZTime);
var
  vDouble : Double;
begin
  vDouble := GetDouble(ColumnIndex);
  if not LastWasNull then
    Result := TZAnyValue.CreateWithDouble(vDouble).GetTime;
end;

procedure TZRESTDWResultSet.GetTimestamp(ColumnIndex: Integer;
  var Result: TZTimeStamp);
var
  vDouble : Double;
begin
  vDouble := GetDouble(ColumnIndex);
  if not LastWasNull then
    Result := TZAnyValue.CreateWithDouble(vDouble).GetTimeStamp;
end;

function TZRESTDWResultSet.GetBlob(ColumnIndex: Integer;
  LobStreamMode: TZLobStreamMode = lsmRead): IZBlob;
begin
  LastWasNull := IsNull(ColumnIndex);
  if not LastWasNull then
    Result.SetBytes(TBytes(FVariantTable[RowNo-1,ColumnIndex]))
end;


function TZRESTDWResultSet.Next: Boolean;
begin
  Result := False;
  if Closed then
    Exit;

  if ((MaxRows > 0) and (RowNo >= MaxRows)) or (RowNo > FRecordCount-1) then
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
