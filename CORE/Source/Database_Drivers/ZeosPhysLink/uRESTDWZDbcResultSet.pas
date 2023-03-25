unit uRESTDWZDbcResultSet;

{$I ..\..\Includes\uRESTDW.inc}

{$IFNDEF RESTDWLAZARUS}
  {$I ZDbc.inc}
{$ELSE}
  {$MODE DELPHI}
{$ENDIF}

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

interface

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

  {$IFDEF ZEOS80UP}
  TZRESTDWResultSet = class(TZAbstractReadOnlyResultSet, IZResultSet)
  {$ELSE}
  TZRESTDWResultSet = class(TZAbstractResultSet)
  {$ENDIF}
  private
    FRESTDWConnection : IZRESTDWConnection;

    FStream : TStream;
    FEncodeStrs : boolean;
    FFieldCount : integer;
    FRecordPos : int64;
    FRecordCount : int64;
    FFieldTypes : array of byte;
    FVariantTable : array of array of Variant;

    FFirstRow : boolean;
  protected
    procedure Open; override;
    procedure streamToArray;
  public
    constructor Create(const Statement: IZStatement; const SQL: string; Stream : TStream);

    procedure ResetCursor; override;

    function IsNull(ColumnIndex: Integer): Boolean; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetPAnsiChar(ColumnIndex: Integer; out Len: NativeUInt): PAnsiChar; {$IFDEF ZEOS80UP} overload {$ELSE} override {$ENDIF};
    function GetPWideChar(ColumnIndex: Integer; out Len: NativeUInt): PWideChar; {$IFDEF ZEOS80UP} overload {$ELSE} override {$ENDIF};
    {$IFNDEF NO_UTF8STRING}
    function GetUTF8String(ColumnIndex: Integer): UTF8String; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    {$ENDIF}
    {$IFNDEF NO_ANSISTRING}
    function GetAnsiString(ColumnIndex: Integer): AnsiString; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    {$ENDIF}
    function GetBoolean(ColumnIndex: Integer): Boolean; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetInt(ColumnIndex: Integer): Integer; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetUInt(ColumnIndex: Integer): Cardinal; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetLong(ColumnIndex: Integer): Int64; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetULong(ColumnIndex: Integer): UInt64; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetFloat(ColumnIndex: Integer): Single; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetDouble(ColumnIndex: Integer): Double; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    function GetCurrency(ColumnIndex: Integer): Currency; {$IFNDEF ZEOS80UP} override; {$ENDIF}
    {$IFDEF ZEOS80UP}
      procedure GetBigDecimal(ColumnIndex: Integer; var Result: TBCD);
      function GetBytes(ColumnIndex: Integer; out Len: NativeUInt): PByte; overload;
    {$ELSE}
      function GetBigDecimal(ColumnIndex: Integer) : Extended; override;
      function GetBytes(ColumnIndex: Integer): TBytes; override;
    {$ENDIF}
    procedure GetGUID(ColumnIndex: Integer; var Result: TGUID);
    {$IFDEF ZEOS80UP}
      procedure GetDate(ColumnIndex: Integer; Var Result: TZDate); reintroduce; overload;
      procedure GetTime(ColumnIndex: Integer; var Result: TZTime); reintroduce; overload;
      procedure GetTimestamp(ColumnIndex: Integer; Var Result: TZTimeStamp); reintroduce; overload;
      function GetBlob(ColumnIndex: Integer; LobStreamMode: TZLobStreamMode = lsmRead): IZBlob;
    {$ELSE}
      function GetDate(ColumnIndex: Integer): TDateTime; override;
      function GetTime(ColumnIndex: Integer): TDateTime; override;
      function GetTimestamp(ColumnIndex: Integer): TDateTime; override;
      function GetBlob(ColumnIndex: Integer): IZBlob; override;
    {$ENDIF}


    function Next: Boolean; {$IFDEF ZEOS80UP} reintroduce {$ELSE} override {$ENDIF};
    {$IFDEF WITH_COLUMNS_TO_JSON}
    procedure ColumnsToJSON(ResultsWriter: {$IFDEF MORMOT2}TResultsWriter{$ELSE}TJSONWriter{$ENDIF}; JSONComposeOptions: TZJSONComposeOptions);
    {$ENDIF WITH_COLUMNS_TO_JSON}
  end;

  {** Implements a cached resolver with RESTDW specific functionality. }
  {$IFDEF ZEOS80UP}
  TZRESTDWCachedResolver = class (TZGenerateSQLCachedResolver, IZCachedResolver)
  {$ELSE}
  TZRESTDWCachedResolver = class (TZGenericCachedResolver, IZCachedResolver)
  {$ENDIF}
  private
    FPlainDriver: TZRESTDWPlainDriver;
    FAutoColumnIndex: Integer;
  public
    constructor Create(const Statement: IZStatement; const Metadata: IZResultSetMetadata);

    {$IFDEF ZEOS80UP}
    procedure PostUpdates(const Sender: IZCachedResultSet; UpdateType: TZRowUpdateType;
      const OldRowAccessor, NewRowAccessor: TZRowAccessor); override;
    {$ELSE}
    procedure PostUpdates(Sender: IZCachedResultSet; UpdateType: TZRowUpdateType;
      OldRowAccessor, NewRowAccessor: TZRowAccessor); override;
    {$ENDIF}

    function CheckKeyColumn(ColumnIndex: Integer): Boolean; override;

    {$IFDEF ZEOS80UP}
      procedure UpdateAutoIncrementFields(const Sender: IZCachedResultSet;
        UpdateType: TZRowUpdateType; const OldRowAccessor, NewRowAccessor: TZRowAccessor;
        const Resolver: IZCachedResolver); override;
    {$ELSE}
      procedure UpdateAutoIncrementFields(Sender: IZCachedResultSet; UpdateType: TZRowUpdateType;
        OldRowAccessor, NewRowAccessor: TZRowAccessor; Resolver: IZCachedResolver); override;
    {$ENDIF}
  end;

  {$IFDEF ZEOS80UP}
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
  {$ENDIF}

{$ENDIF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
implementation
{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit

uses
  ZMessages, ZTokenizer, ZVariant, ZEncoding, ZFastCode,
  ZGenericSqlAnalyser, uRESTDWProtoTypes {$IFNDEF RESTDWLAZARUS}, SqlTimSt {$ENDIF};

{ TZRESTDWCachedResultSet }

{$IFDEF ZEOS80UP}
  class function TZRESTDWCachedResultSet.GetRowAccessorClass: TZRowAccessorClass;
  begin
    Result := TZRESTDWRowAccessor;
  end;
{$ENDIF}

{ TZRESTDWRowAccessor }
{$IFDEF ZEOS80UP}
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
{$ENDIF}

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
  FRESTDWConnection := Statement.GetConnection as TZRESTDWConnection;
  Metadata := TZRESTDWResultSetMetadata.Create(FRESTDWConnection.GetMetadata,SQL,Self);
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
  vString : utf8string;
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

  // field count
  FStream.Read(FFieldCount,SizeOf(integer));
  SetLength(FFieldTypes,FFieldCount);

  // encodestrs
  FStream.Read(vBoolean, Sizeof(vBoolean));
  FEncodeStrs := vBoolean;

  i := 0;
  while i < FFieldCount do begin
    ColumnInfo := TZColumnInfo.Create;
    with ColumnInfo do begin
      // field kind
      FStream.Read(vByte,SizeOf(vByte));
      vFieldKind := TFieldKind(vByte);

      // field name
      FStream.Read(vByte,SizeOf(vByte));
      SetLength(vString,vByte);
      FStream.Read(vString[InitStrPos],vByte);

      ColumnName := vString;
      ColumnLabel := vString;
      TableName := '';
      CatalogName := '';

      ReadOnly := False;

      // field type
      FStream.Read(vDWFielType,SizeOf(vDWFielType));
      vFieldType := DWFieldTypeToFieldType(vDWFielType);
      FFieldTypes[i] := vDWFielType;

      ColumnType := ConvertDatasetToDbcType(vFieldType);

      // field size
      FStream.Read(vFieldSize,SizeOf(Integer));

      // field precision
      FStream.Read(vFieldPrecision,SizeOf(Integer));

      // required + provider flags
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
    i := i + 1;
  end;

  FStream.Read(FRecordCount,SizeOf(FRecordCount));
  FRecordPos := FStream.Position;

  streamToArray;

  FStream.Size := 0;

  inherited Open;
  {$IFDEF ZEOS80UP}
    FCursorLocation := rctServer;
  {$ENDIF}
end;

procedure TZRESTDWResultSet.ResetCursor;
begin
  FFirstRow := True; // zeos7
  if not Closed then begin
    FStream.Position := 0;
    inherited ResetCursor;
  end;
end;

procedure TZRESTDWResultSet.streamToArray;
var
  i             : int64;
  j             : integer;
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
  {$IFDEF DELPHIXEUP}
  vTimeStampOffset : TSQLTimeStampOffset;
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
          {$IFDEF RESTDWLAZARUS}
           FStream.Read(Pointer(vString)^, vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString, csUndefined);
           vString := GetStringEncode(vString, csUTF8);
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
          {$IFDEF RESTDWLAZARUS}
           FStream.Read(Pointer(vString)^, vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString, csUndefined);
           vString := GetStringEncode(vString, csUTF8);
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
        {$IFDEF DELPHIXEUP}
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
        {$ENDIF}
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
          {$IFDEF RESTDWLAZARUS}
           FStream.Read(Pointer(vString)^, vInt64);
           if FEncodeStrs then
             vString := DecodeStrings(vString, csUndefined);
           vString := GetStringEncode(vString, csUTF8);
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
  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}
  Result := FVariantTable[RowNo-1,ColumnIndex] = Null;
end;

function TZRESTDWResultSet.GetPAnsiChar(ColumnIndex: Integer; out Len: NativeUInt): PAnsiChar;
var
  vInt64 : int64;
  vString : ansistring;
begin
  Result := PAnsiChar('');
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}

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
  {$IFDEF RESTDWLAZARUS}
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

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}

  if not LastWasNull then begin
    vBoolean := FVariantTable[RowNo-1,ColumnIndex];
    Result := vBoolean;
  end;
end;

{$IFDEF ZEOS80UP}
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
{$ELSE}
  function TZRESTDWResultSet.GetBytes(ColumnIndex: Integer): TBytes;
  var
    vBytes : TBytes;
  begin
    LastWasNull := IsNull(ColumnIndex);

    {$IFNDEF GENERIC_INDEX}
    ColumnIndex := ColumnIndex -1;
    {$ENDIF}

    if not LastWasNull then begin
      vBytes := TBytes(FVariantTable[RowNo-1,ColumnIndex]);
      Result := vBytes;
    end;
  end;
{$ENDIF}

function TZRESTDWResultSet.GetInt(ColumnIndex: Integer): Integer;
var
  vInt : integer;
begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}

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

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}

  if not LastWasNull then begin
    vInt64 := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt64;
  end;
end;

function TZRESTDWResultSet.GetUInt(ColumnIndex: Integer): Cardinal;
begin
  Result := GetLong(ColumnIndex);
end;

{$IF Defined(RangeCheckEnabled) AND Defined(WITH_UINT64_C1118_ERROR)}{$R-}{$IFEND}
function TZRESTDWResultSet.GetULong(ColumnIndex: Integer): System.UInt64;
var
  vInt64 : UInt64;
begin
  Result := 0;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}

  if not LastWasNull then begin
    vInt64 := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt64;
  end;
end;
{$IF Defined(RangeCheckEnabled) AND Defined(WITH_UINT64_C1118_ERROR)}{$R+}{$IFEND}

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

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}

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

{$IFDEF ZEOS80UP}
  procedure TZRESTDWResultSet.GetBigDecimal(ColumnIndex: Integer; var Result: TBCD);
  var
    vCurrency : Currency;
  begin
    vCurrency := GetCurrency(ColumnIndex);
    {$IFNDEF RESTDWLAZARUS}
      if not LastWasNull then
        Result := CurrencyToBcd(vCurrency);
    {$ELSE}
      if not LastWasNull then
        Result := DoubleToBCD(vCurrency);
    {$ENDIF}
  end;
{$ELSE}
  function TZRESTDWResultSet.GetBigDecimal(ColumnIndex: Integer) : Extended;
  var
    vCurrency : Currency;
  begin
    vCurrency := GetCurrency(ColumnIndex);

    {$IFNDEF GENERIC_INDEX}
    ColumnIndex := ColumnIndex -1;
    {$ENDIF}

    if not LastWasNull then
      Result := vCurrency;
  end;
{$ENDIF}

function TZRESTDWResultSet.GetCurrency(ColumnIndex: Integer): Currency;
var
  vCurrency : Currency;
begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
  {$ENDIF}

  if not LastWasNull then begin
    vCurrency := FVariantTable[RowNo-1,ColumnIndex];
    Result := vCurrency;
  end;
end;

{$IFDEF ZEOS80UP}
  procedure TZRESTDWResultSet.GetDate(ColumnIndex: Integer; var Result: TZDate);
  var
    vDouble : Double;
  begin
    vDouble := GetDouble(ColumnIndex);
    if not LastWasNull then
      Result := TZAnyValue.CreateWithDouble(vDouble).GetDate;
  end;
{$ELSE}
  function TZRESTDWResultSet.GetDate(ColumnIndex: Integer) : TDateTime;
  var
    vDouble : Double;
  begin
    vDouble := GetDouble(ColumnIndex);
    if not LastWasNull then
      Result := TDateTime(vDouble);
  end;
{$ENDIF}

{$IFDEF ZEOS80UP}
  procedure TZRESTDWResultSet.GetTime(ColumnIndex: Integer; var Result: TZTime);
  var
    vDouble : Double;
  begin
    vDouble := GetDouble(ColumnIndex);
    if not LastWasNull then
      Result := TZAnyValue.CreateWithDouble(vDouble).GetTime;
  end;
{$ELSE}
  function TZRESTDWResultSet.GetTime(ColumnIndex: Integer) : TDateTime;
  var
    vDouble : Double;
  begin
    vDouble := GetDouble(ColumnIndex);
    if not LastWasNull then
      Result := TDateTime(vDouble);
  end;
{$ENDIF}

{$IFDEF ZEOS80UP}
  procedure TZRESTDWResultSet.GetTimestamp(ColumnIndex: Integer; var Result: TZTimeStamp);
  var
    vDouble : Double;
  begin
    vDouble := GetDouble(ColumnIndex);
    if not LastWasNull then
      Result := TZAnyValue.CreateWithDouble(vDouble).GetTimeStamp;
  end;
{$ELSE}
  function TZRESTDWResultSet.GetTimestamp(ColumnIndex: Integer) : TDateTime;
  var
    vDouble : Double;
  begin
    vDouble := GetDouble(ColumnIndex);
    if not LastWasNull then
      Result := TDateTime(vDouble);
  end;
{$ENDIF}

{$IFDEF ZEOS80UP}
  function TZRESTDWResultSet.GetBlob(ColumnIndex: Integer;
    LobStreamMode: TZLobStreamMode = lsmRead): IZBlob;
  begin
    LastWasNull := IsNull(ColumnIndex);
    if not LastWasNull then
      Result.SetBytes(TBytes(FVariantTable[RowNo-1,ColumnIndex]))
  end;
{$ELSE}
  function TZRESTDWResultSet.GetBlob(ColumnIndex: Integer) : IZBlob;
  var
    sStr : TStringStream;
  begin
    LastWasNull := IsNull(ColumnIndex);
    {$IFNDEF GENERIC_INDEX}
    ColumnIndex := ColumnIndex -1;
    {$ENDIF}
    if not LastWasNull then begin
      if FFieldTypes[ColumnIndex] in [dwftMemo,dwftWideMemo,dwftFmtMemo] then begin
        sStr := TStringStream.Create(String(FVariantTable[RowNo-1,ColumnIndex]));
        try
          sStr.Position := 0;
          Result := TZAbstractCLob.CreateWithStream(sStr,zCP_UTF8,ConSettings);
        finally
          sStr.Free;
        end;
      end
      else begin
        sStr := TStringStream.Create(TBytes(FVariantTable[RowNo-1,ColumnIndex]));
        try
          sStr.Position := 0;
          Result := TZAbstractBlob.CreateWithStream(sStr);
        finally
          sStr.Free;
        end;
      end;
    end;
  end;
{$ENDIF}


function TZRESTDWResultSet.Next: Boolean;
begin
  Result := False;
  if Closed then
    Exit;

  if ((MaxRows > 0) and (RowNo >= MaxRows)) or (RowNo > FRecordCount-1) then begin
    if RowNo <= LastRowNo then
      RowNo := LastRowNo + 1;
    Exit;
  end;

  if FFirstRow then begin
    FFirstRow := False;
    Result := True;
    RowNo := 1;
    LastRowNo := 1;
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
  {$IFDEF ZEOS80UP}
    FPlainDriver := TZRESTDWPlainDriver(Statement.GetConnection.GetIZPlainDriver.GetInstance);
  {$ELSE}
    FPlainDriver := TZRESTDWPlainDriver(Statement.GetConnection.GetIZPlainDriver);
  {$ENDIF}

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

{$IFDEF ZEOS80UP}
  procedure TZRESTDWCachedResolver.PostUpdates(const Sender: IZCachedResultSet;
    UpdateType: TZRowUpdateType; const OldRowAccessor, NewRowAccessor: TZRowAccessor);
  begin
    inherited PostUpdates(Sender, UpdateType, OldRowAccessor, NewRowAccessor);

    if (UpdateType = utInserted) then
      UpdateAutoIncrementFields(Sender, UpdateType, OldRowAccessor, NewRowAccessor, Self);
  end;
{$ELSE}
  procedure TZRESTDWCachedResolver.PostUpdates(Sender: IZCachedResultSet; UpdateType: TZRowUpdateType;
    OldRowAccessor, NewRowAccessor: TZRowAccessor);
  begin
    inherited PostUpdates(Sender, UpdateType, OldRowAccessor, NewRowAccessor);

    if (UpdateType = utInserted) then
      UpdateAutoIncrementFields(Sender, UpdateType, OldRowAccessor, NewRowAccessor, Self);
  end;
{$ENDIF}

{$IFDEF ZEOS80UP}
  procedure TZRESTDWCachedResolver.UpdateAutoIncrementFields(
    const Sender: IZCachedResultSet; UpdateType: TZRowUpdateType; const
    OldRowAccessor, NewRowAccessor: TZRowAccessor; const Resolver: IZCachedResolver);
  begin
    inherited;
  end;
{$ELSE}
  procedure TZRESTDWCachedResolver.UpdateAutoIncrementFields(Sender: IZCachedResultSet;
     UpdateType: TZRowUpdateType; OldRowAccessor, NewRowAccessor: TZRowAccessor;
     Resolver: IZCachedResolver);
  begin
    inherited;
  end;
{$ENDIF}

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
