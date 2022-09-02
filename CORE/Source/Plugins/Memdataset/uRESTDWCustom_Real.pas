unit uRESTDWCustom;

interface

uses
  Windows, // to avoid warning under BDS2006, and in the interface section to allow compilation in RS2008
  SysUtils, Classes, DB, Variants, uRESTDWDBFilterExpr, uRESTDWFieldsClass, uRESTDWDetailLink;

type
  TPVariant = ^Variant;
  TMemBlobData = string;
  TMemBlobArray = array [0 .. MaxInt div SizeOf(TMemBlobData) - 1] of TMemBlobData;
  PMemBlobArray = ^TMemBlobArray;
  TFTMemoryRecord = class;
  TLoadMode = (lmCopy, lmAppend);
  TSaveLoadState = (slsNone, slsLoading, slsSaving);
  TCompareRecords = function(Item1, Item2: TFTMemoryRecord): Integer of object;
  TWordArray = array of Word;
  TFTBookmarkData = Integer;
{$IFDEF RTL240_UP}
  PFTMemBuffer = PByte;
  TFTBookmark = TBookmark;
  TFTValueBuffer = TValueBuffer;
  TFTRecordBuffer = TRecordBuffer;
{$ELSE}
{$IFDEF UNICODE}
  PFTMemBuffer = PByte;
{$ELSE}
  PFTMemBuffer = PAnsiChar;
{$ENDIF UNICODE}
  TFTBookmark = Pointer;
  TFTValueBuffer = Pointer;
  TFTRecordBuffer = Pointer;
{$ENDIF RTL240_UP}
{$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF RTL230_UP}
  TkbmifoOption = (mtifoDescending, mtifoCaseInsensitive, mtifoPartial, mtifoIgnoreNull, mtifoIgnoreLocale, mtifoAggregate,
    mtifoAggSum, mtifoAggMin, mtifoAggMax, mtifoAggCount, mtifoAggAvg, mtifoAggStdDev, mtifoAggUsr1, mtifoAggUsr2, mtifoAggUsr3,
    mtifoIgnoreNonSpace, mtifoIgnoreKanatype, mtifoIgnoreSymbols, mtifoIgnoreWidth, mtifoExtract, mtifoAsDate, mtifoAsTime,
    mtifoAsDateTime, mtifoNullFirst);
  TkbmifoOptions = set of TkbmifoOption;

  TCustomFreeTable = class(TDataset)
  private
    FMasterLink: TFtMasterDataLink;

    FSaveLoadState: TSaveLoadState;
    FRecordPos: Integer;
    FRecordSize: Integer;
    FBookmarkOfs: Integer;
    FBlobOfs: Integer;
    FRecBufSize: Integer;
    FOffsets: TWordArray;
    FLastID: Integer;
    FAutoInc: Longint;
    FActive: Boolean;
    FRecords: TList;
    FIndexList: TList;
    FCaseInsensitiveSort: Boolean;
    FDescendingSort: Boolean;
    FSrcAutoIncField: TField;
    FDataSet: TDataset;
    FDataSetClosed: Boolean;
    FLoadStructure: Boolean;
    FLoadRecords: Boolean;
    FKeyFieldNames: string;
    FAutoIn: Boolean;
    FOneValueInArray: Boolean;
    FDeletedValues: TList;
    FFilterExpression: TDBFilterExpression;
    // ahuser. Same filter expression parser that ClientDataSet uses
    FClearing: Boolean;
    FUseDataSetFilter: Boolean;
    FTrimEmptyString: Boolean;
    FBlockEvents: Boolean;
    FKeyFieldList: TStringList;
    FOnDataChange: TDataChangeEvent;
    FOnStateChange: TNotifyEvent;
    FIndexDefs: TIndexDefs;
    FRecalcOnIndex: Boolean;
    FIndexFieldNames: string;
    FIndexName: string;

    procedure UpdateIndex;
    procedure SetIndex(Value: string);
    function AddRecord: TFTMemoryRecord;
    function InsertRecord(Index: Integer): TFTMemoryRecord;
    function FindRecordID(ID: Integer): TFTMemoryRecord;
    procedure CreateIndexList(const FieldNames: WideString);
    procedure FreeIndexList;
    procedure QuickSort(L, R: Integer; Compare: TCompareRecords);
    procedure Sort;
    function CalcRecordSize: Integer;
    function GetMemoryRecord(Index: Integer): TFTMemoryRecord;
    function RecordFilter: Boolean;
    procedure ClearRecords;
    procedure InitBufferPointers(GetProps: Boolean);
    procedure SetDataSet(ADataSet: TDataset);
    procedure CheckStructure(UseAutoIncAsInteger: Boolean = False);
    procedure SetUseDataSetFilter(const Value: Boolean);
    procedure InternalGotoBookmarkData(BookmarkData: TFTBookmarkData);
    function InternalGetFieldData(Field: TField; Buffer: Pointer): Boolean;
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer; const ValidateBuffer: TFTValueBuffer);
    procedure SetKeyFieldNames(const Value: string); virtual;
    function GetSaveLoadState: TSaveLoadState;
    procedure SetSaveLoadState(const Value: TSaveLoadState);
    procedure SetIndexDefs(const Value: TIndexDefs);
    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    function GetMasterFields: string;
    procedure SetMasterFields(const Value: string);
    function GetIndexFieldNames: string;
    procedure SetIndexFieldNames(const Value: string);
    function GetIndexName: string;
    procedure SetIndexName(const Value: string);

  protected
    procedure CreateFields; override;
    function GetFieldsClass: TFieldsClass; override;
    procedure DoAfterCancel; override;
    procedure DoAfterClose; override;
    procedure DoAfterDelete; override;
    procedure DoAfterEdit; override;
    procedure DoAfterInsert; override;
    procedure DoAfterOpen; override;
    procedure DoAfterPost; override;
    procedure DoAfterRefresh; override;
    procedure DoAfterScroll; override;
    procedure DoBeforeCancel; override;
    procedure DoBeforeClose; override;
    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforeOpen; override;
    procedure DoBeforePost; override;
    procedure DoBeforeRefresh; override;
    procedure DoBeforeScroll; override;
    procedure DoOnCalcFields; override;
    procedure DoOnNewRecord; override;

    function FindFieldData(Buffer: Pointer; Field: TField): Pointer;
    function CompareFields(Data1, Data2: Pointer; FieldType: TFieldType; CaseInsensitive: Boolean): Integer; virtual;
{$IFNDEF COMPILER10_UP} // Delphi 2006+ has support for WideString
    procedure DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean); override;
{$ENDIF ~COMPILER10_UP}
    procedure AssignMemoryRecord(Rec: TFTMemoryRecord; Buffer: PFTMemBuffer);
    function GetActiveRecBuf(var RecBuf: PFTMemBuffer): Boolean; virtual;
    procedure InitFieldDefsFromFields;
    procedure RecordToBuffer(Rec: TFTMemoryRecord; Buffer: PFTMemBuffer);
    procedure SetMemoryRecordData(Buffer: PFTMemBuffer; Pos: Integer); virtual;
    procedure SetAutoIncFields(Buffer: PFTMemBuffer); virtual;
    function CompareRecords(Item1, Item2: TFTMemoryRecord): Integer; virtual;
    function GetBlobData(Field: TField; Buffer: PFTMemBuffer): TMemBlobData;
    procedure SetBlobData(Field: TField; Buffer: PFTMemBuffer; Value: TMemBlobData);
    function AllocRecordBuffer: PFTMemBuffer; override;
    procedure FreeRecordBuffer(var Buffer: PFTMemBuffer); override;
    procedure InternalInitRecord(Buffer: PFTMemBuffer); override;
    procedure ClearCalcFields(Buffer: PFTMemBuffer); override;
    function GetRecord(Buffer: PFTMemBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordSize: Word; override;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); override;
    procedure SetFieldData(Field: TField; Buffer: TFTValueBuffer); overload; override;
{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}
    procedure SetFieldData(Field: TField; Buffer: Pointer); overload; override;
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); overload; override;
    procedure InternalGotoBookmark(Bookmark: Pointer); overload; override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); overload; override;
{$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}
    procedure CloseBlob(Field: TField); override;
    procedure GetBookmarkData(Buffer: PFTMemBuffer; Data: TFTBookmark); overload; override;
    function GetBookmarkFlag(Buffer: PFTMemBuffer): TBookmarkFlag; override;
    procedure InternalGotoBookmark(Bookmark: TFTBookmark); overload; override;
    procedure InternalSetToRecord(Buffer: PFTMemBuffer); override;
    procedure SetBookmarkFlag(Buffer: PFTMemBuffer; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: PFTMemBuffer; Data: TFTBookmark); overload; override;
    function GetIsIndexField(Field: TField): Boolean; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure InitRecord(Buffer: PFTMemBuffer); override;
    procedure InternalAddRecord(Buffer: TFTRecordBuffer; Append: Boolean); override;
    procedure InternalDelete; override;
    procedure InternalPost; override;
    procedure InternalClose; override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    procedure OpenCursor(InfoQuery: Boolean); override;
    function IsCursorOpen: Boolean; override;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    procedure SetFilterText(const Value: string); override;
    function ParserGetVariableValue(Sender: TObject; const VarName: string; var Value: Variant): Boolean; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property Records[Index: Integer]: TFTMemoryRecord read GetMemoryRecord;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function GetExtractFieldOption(const AExtractOption: string): TkbmifoOptions; virtual;

    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    procedure FixReadOnlyFields(MakeReadOnly: Boolean);
    function GetFieldData(Field: TField; {$IFDEF RTL250_UP}var
{$ENDIF} Buffer: TFTValueBuffer): Boolean; overload; override;
{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; overload; override;
{$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}
    function GetCurrentRecord(Buffer: PFTMemBuffer): Boolean; override;
    function IsSequenced: Boolean; override;
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant; override;
    procedure SortOn(const FieldNames: string = ''; CaseInsensitive: Boolean = True; Descending: Boolean = False);
    procedure SwapRecords(Idx1: Integer; Idx2: Integer);
    procedure EmptyTable;
    procedure CleanData;
    procedure CopyStructure(Source: TDataset; UseAutoIncAsInteger: Boolean = False);
    function LoadFromDataSet(Source: TDataset; RecordCount: Integer; Mode: TLoadMode; DisableAllControls: Boolean = True): Integer;
    function SaveToDataSet(Dest: TDataset; RecordCount: Integer; DisableAllControls: Boolean = True): Integer;
    property SaveLoadState: TSaveLoadState read GetSaveLoadState write SetSaveLoadState;
    function GetValues(FldNames: string = ''): Variant;
    function GetKeyFieldsValues(AdditionalValues: Array of Variant): Variant;

    function FindDeleted(KeyValues: Variant): Integer;
    function IsDeleted(out Index: Integer): Boolean;
    function IsLoading: Boolean;
    function IsSaving: Boolean;
    property BlockEvents: Boolean read FBlockEvents write FBlockEvents;

    function GetKeyFieldList: TStringList;
    property KeyFieldList: TStringList read GetKeyFieldList;

    property RecalcOnIndex: Boolean read FRecalcOnIndex write FRecalcOnIndex default False;

    property MasterFields: string read GetMasterFields write SetMasterFields;
    property MasterSource: TDataSource read GetDataSource write SetDataSource;
    property IndexDefs: TIndexDefs read FIndexDefs write SetIndexDefs;
    property IndexFieldNames: string read GetIndexFieldNames write SetIndexFieldNames;
    property IndexName: string read GetIndexName write SetIndexName;
    property OnDataChange: TDataChangeEvent read FOnDataChange write FOnDataChange;
    property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;
    property AutoCalcFields;
    property UseDataSetFilter: Boolean read FUseDataSetFilter write SetUseDataSetFilter default False;
    property Dataset: TDataset read FDataSet write SetDataSet;
    property DatasetClosed: Boolean read FDataSetClosed write FDataSetClosed default False;
    property KeyFieldNames: string read FKeyFieldNames write SetKeyFieldNames;
    property LoadStructure: Boolean read FLoadStructure write FLoadStructure default False;
    property LoadRecords: Boolean read FLoadRecords write FLoadRecords default False;
    property AutoIncAsInteger: Boolean read FAutoIncAsInteger write FAutoIncAsInteger default False;
    property OneValueInArray: Boolean read FOneValueInArray write FOneValueInArray default True;
    property TrimEmptyString: Boolean read FTrimEmptyString write FTrimEmptyString default True;
  end;

  TFTMemBlobStream = class(TStream)
  private
    FField: TBlobField;
    FDataSet: TCustomFreeTable;
    FBuffer: PFTMemBuffer;
    FMode: TBlobStreamMode;
    FOpened: Boolean;
    FModified: Boolean;
    FPosition: Longint;
    FCached: Boolean;
    function GetBlobSize: Longint;
    function GetBlobFromRecord(Field: TField): TMemBlobData;

  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure Truncate;
  end;

  TFTMemoryRecord = class(TPersistent)
  private
    FMemoryData: TCustomFreeTable;
    FID: Integer;
    FData: Pointer;
    FBlobs: Pointer;
    function GetIndex: Integer;
    procedure SetMemoryData(Value: TCustomFreeTable; UpdateParent: Boolean);

  protected
    procedure SetIndex(Value: Integer); virtual;

  public
    constructor Create(MemoryData: TCustomFreeTable); virtual;
    constructor CreateEx(MemoryData: TCustomFreeTable; UpdateParent: Boolean); virtual;
    destructor Destroy; override;
    property MemoryData: TCustomFreeTable read FMemoryData;
    property ID: Integer read FID write FID;
    property Index: Integer read GetIndex write SetIndex;
    property Data: Pointer read FData;
  end;

const
  ftBlobTypes = [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftOraBlob, ftOraClob
{$IFDEF COMPILER10_UP}, ftWideMemo{$ENDIF COMPILER10_UP}];

  // If you add a new supported type you _must_ also update CalcFieldLen()
  ftSupported = [ftString, ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftDate, ftTime, ftDateTime, ftAutoInc,
    ftBCD, ftFMTBCD, ftTimestamp,
{$IFDEF COMPILER10_UP}
  ftOraTimestamp, ftFixedWideChar,
{$ENDIF COMPILER10_UP}
{$IFDEF COMPILER12_UP}
  ftLongWord, ftShortint, ftByte, ftExtended,
{$ENDIF COMPILER12_UP}
  ftBytes, ftVarBytes, ftADT, ftFixedChar, ftWideString, ftLargeint, ftVariant, ftGuid] + ftBlobTypes;

  fkStoredFields = [fkData];

  GuidSize = 38;

procedure AssignRecord(Source, Dest: TDataset; ByName: Boolean);

implementation

uses
  Types, DBConsts, Math,
{$IFDEF RTL240_UP}
  System.Generics.Collections,
{$ENDIF RTL240_UP}
{$IFDEF HAS_UNIT_ANSISTRINGS}
  AnsiStrings,
{$ENDIF HAS_UNIT_ANSISTRINGS}
  FMTBcd, SqlTimSt,
{$IFNDEF UNICODE}
{$ENDIF ~UNICODE}
  Resources_FT;

type
  PMemBookmarkInfo = ^TMemBookmarkInfo;

  TMemBookmarkInfo = record
    BookmarkData: TFTBookmarkData;
    BookmarkFlag: TBookmarkFlag;
  end;

function StrLenA(S: PAnsiChar): Integer;
begin
  Result := {$IFDEF DEPRECATED_SYSUTILS_ANSISTRINGS}System.AnsiStrings.{$ENDIF}StrLen(S);
end;

function VarIsNullEmpty(const V: Variant): Boolean;
begin
  Result := VarIsNull(V) or VarIsEmpty(V);
end;

function ExtractFieldNameEx(const Fields: {$IFDEF COMPILER10_UP} WideString {$ELSE} string {$ENDIF}; var Pos: Integer): string;
begin
  Result := ExtractFieldName(Fields, Pos);
end;

procedure _DBError(const Msg: string);
begin
  DatabaseError(Msg);
end;

procedure AssignRecord(Source, Dest: TDataset; ByName: Boolean);
var
  I: Integer;
  F, FSrc: TField;
begin
  if not(Dest.State in dsEditModes) then
    _DBError(SNotEditing);
  if ByName then begin
    for I := 0 to Source.FieldCount - 1 do begin
      F := Dest.FindField(Source.Fields[I].FieldName);
      FSrc := Source.Fields[I];
      if (F <> nil) and (F.DataType <> ftAutoInc) then begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
          ftString:
            F.AsString := FSrc.AsString;
          ftInteger:
            F.AsInteger := FSrc.AsInteger;
          ftBoolean:
            F.AsBoolean := FSrc.AsBoolean;
          ftFloat:
            F.AsFloat := FSrc.AsFloat;
          ftCurrency:
            F.AsCurrency := FSrc.AsCurrency;
          ftDate:
            F.AsDateTime := FSrc.AsDateTime;
          ftDateTime:
            F.AsDateTime := FSrc.AsDateTime;
        else
          F.Value := FSrc.Value;
          end;
      end;
    end;
  end else begin
    for I := 0 to Min(Source.FieldDefs.Count - 1, Dest.FieldDefs.Count - 1) do begin
      F := Dest.FindField(Dest.FieldDefs[I].Name);
      FSrc := Source.FindField(Source.FieldDefs[I].Name);
      if (F <> nil) and (FSrc <> nil) and (F.DataType <> ftAutoInc) then begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
          ftString:
            F.AsString := FSrc.AsString;
          ftInteger:
            F.AsInteger := FSrc.AsInteger;
          ftBoolean:
            F.AsBoolean := FSrc.AsBoolean;
          ftFloat:
            F.AsFloat := FSrc.AsFloat;
          ftCurrency:
            F.AsCurrency := FSrc.AsCurrency;
          ftDate:
            F.AsDateTime := FSrc.AsDateTime;
          ftDateTime:
            F.AsDateTime := FSrc.AsDateTime;
        else
          F.Value := FSrc.Value;
          end;
      end;
    end;
  end;
end;

function SetToBookmark(ADataSet: TDataset; ABookmark: TBookmark): Boolean;
begin
  Result := False;
  if ADataSet.Active and (ABookmark <> nil) and not(ADataSet.Bof and ADataSet.Eof) and ADataSet.BookmarkValid(ABookmark) then
    try
      ADataSet.GotoBookmark(ABookmark);
      Result := True;
    except
    end;
end;

function DataSetLocateThrough(Dataset: TDataset; const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
var
  FieldCount: Integer;
  Fields: TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
  Bookmark: {$IFDEF RTL200_UP}TBookmark{$ELSE}TBookmarkStr{$ENDIF RTL200_UP};

  function CompareField(Field: TField; const Value: Variant): Boolean;
  var
    S: string;
  begin
    if Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString{$ENDIF UNICODE}] then begin
      if Value = Null then
        Result := Field.IsNull
      else begin
        S := Field.AsString;
        if loPartialKey in Options then
          Delete(S, Length(Value) + 1, MaxInt);
        if loCaseInsensitive in Options then
          Result := AnsiSameText(S, Value)
        else
          Result := AnsiSameStr(S, Value);
      end;
    end
    else
      Result := (Field.Value = Value);
  end;

  function CompareRecord: Boolean;
  var
    I: Integer;
  begin
    // Works with the KeyValues variant like TCustomClientDataSet.LocateRecord
    if (FieldCount = 1) and not VarIsArray(KeyValues) then
      Result := CompareField(TField(Fields[0]), KeyValues)
    else begin
      Result := True;
      for I := 0 to FieldCount - 1 do
        Result := Result and CompareField(TField(Fields[I]), KeyValues[I]);
    end;
  end;

begin
  Result := False;
  Dataset.CheckBrowseMode;
  if Dataset.IsEmpty then
    Exit;
  Fields := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
  try
    Dataset.GetFieldList(Fields, KeyFields);
    FieldCount := Fields.Count;
    Result := CompareRecord;
    if Result then
      Exit;
    Dataset.DisableControls;
    try
      Bookmark := Dataset.Bookmark;
      try
        Dataset.First;
        while not Dataset.Eof do begin
          Result := CompareRecord;
          if Result then
            Break;
          Dataset.Next;
        end;
      finally
        if not Result and Dataset.BookmarkValid(TBookmark(Bookmark)) then
          Dataset.Bookmark := Bookmark;
      end;
    finally
      Dataset.EnableControls;
    end;
  finally
    Fields.Free;
  end;
end;

{ DataSetSortedSearch. Navigate on sorted DataSet routine. }

function DataSetSortedSearch(Dataset: TDataset; const Value, FieldName: string; CaseInsensitive: Boolean): Boolean;
var
  L, H, I: Longint;
  CurrentPos: Longint;
  CurrentValue: string;
  BookMk: TBookmark;
  Field: TField;

  function UpStr(const Value: string): string;
  begin
    if CaseInsensitive then
      Result := AnsiUpperCase(Value)
    else
      Result := Value;
  end;

  function GetCurrentStr: string;
  begin
    Result := Field.AsString;
    if Length(Result) > Length(Value) then
      SetLength(Result, Length(Value));
    Result := UpStr(Result);
  end;

begin
  Result := False;
  if Dataset = nil then
    Exit;
  Field := Dataset.FindField(FieldName);
  if Field = nil then
    Exit;
  if Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString{$ENDIF UNICODE}] then begin
    Dataset.DisableControls;
    BookMk := Dataset.GetBookmark;
    try
      L := 0;
      Dataset.First;
      CurrentPos := 0;
      H := Dataset.RecordCount - 1;
      if Value <> '' then begin
        while L <= H do begin
          I := (L + H) shr 1;
          if I <> CurrentPos then
            Dataset.MoveBy(I - CurrentPos);
          CurrentPos := I;
          CurrentValue := GetCurrentStr;
          if UpStr(Value) > CurrentValue then
            L := I + 1
          else begin
            H := I - 1;
            if UpStr(Value) = CurrentValue then
              Result := True;
          end;
        end;
        if Result then begin
          if L <> CurrentPos then
            Dataset.MoveBy(L - CurrentPos);
          while (L < Dataset.RecordCount) and (UpStr(Value) <> GetCurrentStr) do begin
            Inc(L);
            Dataset.MoveBy(1);
          end;
        end;
      end
      else
        Result := True;
      if not Result then
        SetToBookmark(Dataset, BookMk);
    finally
      Dataset.FreeBookmark(BookMk);
      Dataset.EnableControls;
    end;
  end
  else
    DatabaseErrorFmt(SFieldTypeMismatch, [Field.DisplayName]);
end;

function ReplaceComponentReference(This, NewReference: TComponent; var VarReference: TComponent): Boolean;
begin
  Result := (VarReference <> NewReference) and Assigned(This);
  if Result then begin
    if Assigned(VarReference) then
      VarReference.RemoveFreeNotification(This);
    VarReference := NewReference;
    if Assigned(VarReference) then
      VarReference.FreeNotification(This);
  end;
end;

procedure AppHandleException(Sender: TObject);
begin
  if Assigned(ApplicationHandleException) then
    ApplicationHandleException(Sender);
end;

procedure CopyFieldValue(DestField, SourceField: TField);
begin
  if SourceField.IsNull then
    DestField.Clear
  else if DestField.ClassType = SourceField.ClassType then begin
    case DestField.DataType of
    ftInteger, ftSmallint, ftWord:
      DestField.AsInteger := SourceField.AsInteger;
    ftBCD, ftCurrency:
      DestField.AsCurrency := SourceField.AsCurrency;
    ftFMTBCD:
      DestField.AsBCD := SourceField.AsBCD;
    ftString:
      DestField.AsString := SourceField.AsString;
{$IFDEF COMPILER10_UP}
    ftWideString:
      DestField.AsWideString := SourceField.AsWideString;
{$ENDIF COMPILER10_UP}
    ftFloat:
      DestField.AsFloat := SourceField.AsFloat;
    ftDateTime:
      DestField.AsDateTime := SourceField.AsDateTime;
  else
    DestField.Assign(SourceField);
    end;
  end
  else
    DestField.Assign(SourceField);;
end;

function CalcFieldLen(FieldType: TFieldType; Size: Word): Word;
begin
  if not(FieldType in ftSupported) then
    Result := 0
  else if FieldType in ftBlobTypes then
    Result := SizeOf(Longint)
  else begin
    Result := Size;
    case FieldType of
    ftString:
      Inc(Result);
    ftSmallint:
      Result := SizeOf(Smallint);
    ftInteger:
      Result := SizeOf(Longint);
    ftWord:
      Result := SizeOf(Word);
    ftBoolean:
      Result := SizeOf(Wordbool);
    ftFloat:
      Result := SizeOf(Double);
    ftCurrency:
      Result := SizeOf(Double);
    ftDate, ftTime:
      Result := SizeOf(Longint);
    ftDateTime:
      Result := SizeOf(TDateTime);
    ftAutoInc:
      Result := SizeOf(Longint);
    ftBCD, ftFMTBCD:
      Result := SizeOf(TBcd);
    ftTimestamp:
      Result := SizeOf(TSQLTimeStamp);
{$IFDEF COMPILER10_UP}
    ftOraTimestamp:
      Result := SizeOf(TSQLTimeStamp);
    ftFixedWideChar:
      Result := (Result + 1) * SizeOf(WideChar);
{$ENDIF COMPILER10_UP}
{$IFDEF COMPILER12_UP}
    ftLongWord:
      Result := SizeOf(LongWord);
    ftShortint:
      Result := SizeOf(Shortint);
    ftByte:
      Result := SizeOf(Byte);
    ftExtended:
      Result := SizeOf(Extended);
{$ENDIF COMPILER12_UP}
    ftBytes:
      Result := Size;
    ftVarBytes:
      Result := Size + 2;
    ftADT:
      Result := 0;
    ftFixedChar:
      Inc(Result);
    ftWideString:
      Result := (Result + 1) * SizeOf(WideChar);
    ftLargeint:
      Result := SizeOf(Int64);
    ftVariant:
      Result := SizeOf(Variant);
    ftGuid:
      Result := GuidSize + 1;
    end;
  end;
end;

procedure CalcDataSize(FieldDef: TFieldDef; var DataSize: Integer);
var
  I: Integer;
begin
  if FieldDef.DataType in ftSupported - ftBlobTypes then
    Inc(DataSize, CalcFieldLen(FieldDef.DataType, FieldDef.Size) + 1);
  for I := 0 to FieldDef.ChildDefs.Count - 1 do
    CalcDataSize(FieldDef.ChildDefs[I], DataSize);
end;

procedure Error(const Msg: string);
begin
  DatabaseError(Msg);
end;

procedure ErrorFmt(const Msg: string; const Args: array of const);
begin
  DatabaseErrorFmt(Msg, Args);
end;

// === { TFTMemoryRecord } ====================================================

constructor TFTMemoryRecord.Create(MemoryData: TCustomFreeTable);
begin
  CreateEx(MemoryData, True);
end;

constructor TFTMemoryRecord.CreateEx(MemoryData: TCustomFreeTable; UpdateParent: Boolean);
begin
  inherited Create;
  SetMemoryData(MemoryData, UpdateParent);
end;

destructor TFTMemoryRecord.Destroy;
begin
  SetMemoryData(nil, True);
  inherited Destroy;
end;

function TFTMemoryRecord.GetIndex: Integer;
begin
  if FMemoryData <> nil then
    Result := FMemoryData.FRecords.IndexOf(Self)
  else
    Result := -1;
end;

procedure TFTMemoryRecord.SetMemoryData(Value: TCustomFreeTable; UpdateParent: Boolean);
var
  I: Integer;
  DataSize: Integer;
begin
  if FMemoryData <> Value then begin
    if FMemoryData <> nil then begin
      if not FMemoryData.FClearing then
        FMemoryData.FRecords.Remove(Self);
      if FMemoryData.BlobFieldCount > 0 then
        Finalize(PMemBlobArray(FBlobs)[0], FMemoryData.BlobFieldCount);
      ReallocMem(FBlobs, 0);
      ReallocMem(FData, 0);
      FMemoryData := nil;
    end;
    if Value <> nil then begin
      if UpdateParent then begin
        Value.FRecords.Add(Self);
        Inc(Value.FLastID);
        FID := Value.FLastID;
      end;
      FMemoryData := Value;
      if Value.BlobFieldCount > 0 then begin
        ReallocMem(FBlobs, Value.BlobFieldCount * SizeOf(Pointer));
        Initialize(PMemBlobArray(FBlobs)[0], Value.BlobFieldCount);
      end;
      DataSize := 0;
      for I := 0 to Value.FieldDefs.Count - 1 do
        CalcDataSize(Value.FieldDefs[I], DataSize);
      ReallocMem(FData, DataSize);
    end;
  end;
end;

procedure TFTMemoryRecord.SetIndex(Value: Integer);
var
  CurIndex: Integer;
begin
  CurIndex := GetIndex;
  if (CurIndex >= 0) and (CurIndex <> Value) then
    FMemoryData.FRecords.Move(CurIndex, Value);
end;

// === { TCustomFreeTable } ======================================================

constructor TCustomFreeTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRecordPos := -1;
  FLastID := Low(Integer);
  FAutoInc := 1;
  FRecords := TList.Create;
  FDeletedValues := TList.Create;
  FSaveLoadState := slsNone;
  FOneValueInArray := True;
  FDataSetClosed := False;
  FTrimEmptyString := True;
  FKeyFieldList := TStringList.Create;
  FIndexDefs := TIndexDefs.Create(Self);
  FMasterLink := TFtMasterDataLink.Create(Self);
end;

destructor TCustomFreeTable.Destroy;
var
  I: Integer;
  PFValues: TPVariant;
begin
  FreeAndNil(FKeyFieldList);
  if Active then
    Close;
  // if FFilterParser <> nil then
  // FreeAndNil(FFilterParser);
  if FFilterExpression <> nil then
    FreeAndNil(FFilterExpression);
  if Assigned(FDeletedValues) then begin
    if FDeletedValues.Count > 0 then
      for I := 0 to (FDeletedValues.Count - 1) do begin
        PFValues := FDeletedValues[I];
        if PFValues <> nil then
          Dispose(PFValues);
        FDeletedValues[I] := nil;
      end;
    FreeAndNil(FDeletedValues);
  end;
  FreeIndexList;
  ClearRecords;
  SetDataSet(nil);
  FRecords.Free;
  FOffsets := nil;
  FreeAndNil(FIndexDefs);
  inherited Destroy;
end;

function TCustomFreeTable.CompareFields(Data1, Data2: Pointer; FieldType: TFieldType; CaseInsensitive: Boolean): Integer;
begin
  Result := 0;
  case FieldType of
  ftString:
    if CaseInsensitive then
      Result := AnsiCompareText(PAnsiChar(Data1), PAnsiChar(Data2))
    else
      Result := AnsiCompareStr(PAnsiChar(Data1), PAnsiChar(Data2));
  ftSmallint:
    if Smallint(Data1^) > Smallint(Data2^) then
      Result := 1
    else if Smallint(Data1^) < Smallint(Data2^) then
      Result := -1;
  ftInteger, ftDate, ftTime, ftAutoInc:
    if Longint(Data1^) > Longint(Data2^) then
      Result := 1
    else if Longint(Data1^) < Longint(Data2^) then
      Result := -1;
  ftWord:
    if Word(Data1^) > Word(Data2^) then
      Result := 1
    else if Word(Data1^) < Word(Data2^) then
      Result := -1;
  ftBoolean:
    if Wordbool(Data1^) and not Wordbool(Data2^) then
      Result := 1
    else if not Wordbool(Data1^) and Wordbool(Data2^) then
      Result := -1;
  ftFloat, ftCurrency:
    if Double(Data1^) > Double(Data2^) then
      Result := 1
    else if Double(Data1^) < Double(Data2^) then
      Result := -1;
  ftFMTBCD, ftBCD:
    Result := BcdCompare(TBcd(Data1^), TBcd(Data2^));
  ftDateTime:
    if TDateTime(Data1^) > TDateTime(Data2^) then
      Result := 1
    else if TDateTime(Data1^) < TDateTime(Data2^) then
      Result := -1;
  ftFixedChar:
    if CaseInsensitive then
      Result := AnsiCompareText(PAnsiChar(Data1), PAnsiChar(Data2))
    else
      Result := AnsiCompareStr(PAnsiChar(Data1), PAnsiChar(Data2));
  ftWideString:
    if CaseInsensitive then
      Result := AnsiCompareText(WideCharToString(PWideChar(Data1)), WideCharToString(PWideChar(Data2)))
    else
      Result := AnsiCompareStr(WideCharToString(PWideChar(Data1)), WideCharToString(PWideChar(Data2)));
  ftLargeint:
    if Int64(Data1^) > Int64(Data2^) then
      Result := 1
    else if Int64(Data1^) < Int64(Data2^) then
      Result := -1;
  ftVariant:
    Result := 0;
  ftGuid:
    Result := CompareText(PAnsiChar(Data1), PAnsiChar(Data2));
  end;
end;

function TCustomFreeTable.AddRecord: TFTMemoryRecord;
begin
  Result := TFTMemoryRecord.Create(Self);
end;

function TCustomFreeTable.FindRecordID(ID: Integer): TFTMemoryRecord;
var
  I: Integer;
begin
  for I := 0 to FRecords.Count - 1 do begin
    Result := TFTMemoryRecord(FRecords[I]);
    if Result.ID = ID then
      Exit;
  end;
  Result := nil;
end;

function TCustomFreeTable.InsertRecord(Index: Integer): TFTMemoryRecord;
begin
  Result := AddRecord;
  Result.Index := Index;
end;

function TCustomFreeTable.GetMasterFields: string;
begin
  Result := FMasterLink.FieldNames;
end;

function TCustomFreeTable.GetMemoryRecord(Index: Integer): TFTMemoryRecord;
begin
  Result := TFTMemoryRecord(FRecords[Index]);
end;

procedure TCustomFreeTable.InitFieldDefsFromFields;
var
  I: Integer;
  Offset: Word;
  Field: TField;
  FieldDefsUpdated: Boolean;
begin
  if FieldDefs.Count = 0 then begin
    for I := 0 to FieldCount - 1 do begin
      Field := Fields[I];
      if (Field.FieldKind in fkStoredFields) and not(Field.DataType in ftSupported) then
        ErrorFmt(SUnknownFieldType, [Field.DisplayName]);
    end;
    FreeIndexList;
  end;
  Offset := 0;
  inherited InitFieldDefsFromFields;
  { Calculate fields offsets }
  SetLength(FOffsets, FieldDefList.Count);

  FieldDefList.Update;
  FieldDefsUpdated := FieldDefs.Updated;
  try
    FieldDefs.Updated := True;
    // Performance optimization: FieldDefList.Updated returns False is FieldDefs.Updated is False
    for I := 0 to FieldDefList.Count - 1 do begin
      FOffsets[I] := Offset;
      if FieldDefList[I].DataType in ftSupported - ftBlobTypes then
        Inc(Offset, CalcFieldLen(FieldDefList[I].DataType, FieldDefList[I].Size) + 1);
    end;
  finally
    FieldDefs.Updated := FieldDefsUpdated;
  end;
end;

function TCustomFreeTable.FindFieldData(Buffer: Pointer; Field: TField): Pointer;
var
  Index: Integer;
  DataType: TFieldType;
begin
  Result := nil;
  Index := Field.FieldNo - 1;
  // FieldDefList index (-1 and 0 become less than zero => ignored)
  if (Index >= 0) and (Buffer <> nil) then begin
    DataType := FieldDefList[Index].DataType;
    if DataType in ftSupported then
      if DataType in ftBlobTypes then
        Result := Pointer(GetBlobData(Field, Buffer))
      else
        Result := (PFTMemBuffer(Buffer) + FOffsets[Index]);
  end;
end;

function TCustomFreeTable.CalcRecordSize: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FieldDefs.Count - 1 do
    CalcDataSize(FieldDefs[I], Result);
end;

procedure TCustomFreeTable.InitBufferPointers(GetProps: Boolean);
begin
  if GetProps then
    FRecordSize := CalcRecordSize;
  FBookmarkOfs := FRecordSize + CalcFieldsSize;
  FBlobOfs := FBookmarkOfs + SizeOf(TMemBookmarkInfo);
  FRecBufSize := FBlobOfs + BlobFieldCount * SizeOf(Pointer);
end;

procedure TCustomFreeTable.ClearRecords;
var
  I: Integer;
begin
  FClearing := True;
  try
    for I := FRecords.Count - 1 downto 0 do
      TFTMemoryRecord(FRecords[I]).Free;
    FRecords.Clear;
  finally
    FClearing := False;
  end;
  FLastID := Low(Integer);
  FRecordPos := -1;
end;

function TCustomFreeTable.AllocRecordBuffer: PFTMemBuffer;
begin
{$IFDEF COMPILER12_UP}
  GetMem(Result, FRecBufSize);
{$ELSE}
  Result := StrAlloc(FRecBufSize);
{$ENDIF COMPILER12_UP}
  if BlobFieldCount > 0 then
    Initialize(PMemBlobArray(Result + FBlobOfs)[0], BlobFieldCount);
end;

procedure TCustomFreeTable.FreeRecordBuffer(var Buffer: PFTMemBuffer);
begin
  if BlobFieldCount > 0 then
    Finalize(PMemBlobArray(Buffer + FBlobOfs)[0], BlobFieldCount);
{$IFDEF COMPILER12_UP}
  FreeMem(Buffer);
{$ELSE}
  StrDispose(Buffer);
{$ENDIF COMPILER12_UP}
  Buffer := nil;
end;

procedure TCustomFreeTable.CleanData;
begin
  EmptyTable;
end;

procedure TCustomFreeTable.ClearCalcFields(Buffer: PFTMemBuffer);
begin
  FillChar(Buffer[FRecordSize], CalcFieldsSize, 0);
end;

procedure TCustomFreeTable.InternalInitRecord(Buffer: PFTMemBuffer);
var
  I: Integer;
begin
  FillChar(Buffer^, FBlobOfs, 0);
  for I := 0 to BlobFieldCount - 1 do
    PMemBlobArray(Buffer + FBlobOfs)[I] := '';
end;

procedure TCustomFreeTable.InitRecord(Buffer: PFTMemBuffer);
begin
{$IFDEF NEXTGEN}
  inherited InitRecord({$IFDEF RTL250_UP}TRecBuf{$ENDIF}(Buffer));
{$ELSE}
  // in non-NEXTGEN InitRecord(TRectBuf) calls InitRecord(TRecordBuffer) => endless recursion
{$WARN SYMBOL_DEPRECATED OFF} // XE4
  inherited InitRecord({$IFDEF RTL250_UP}TRecordBuffer{$ENDIF}(Buffer));
{$WARN SYMBOL_DEPRECATED ON}
{$ENDIF NEXTGEN}
  with PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do begin
    BookmarkData := Low(Integer);
    BookmarkFlag := bfInserted;
  end;
end;

function TCustomFreeTable.GetCurrentRecord(Buffer: PFTMemBuffer): Boolean;
begin
  Result := False;
  if not IsEmpty and (GetBookmarkFlag(ActiveBuffer) = bfCurrent) then begin
    UpdateCursorPos;
    if (FRecordPos >= 0) and (FRecordPos < RecordCount) then begin
      Move(Records[FRecordPos].Data^, Buffer^, FRecordSize);
      Result := True;
    end;
  end;
end;

function TCustomFreeTable.GetDataSource: TDataSource;
begin
  Result := FMasterLink.DataSource;
end;

class function TCustomFreeTable.GetExtractFieldOption(const AExtractOption: string): TkbmifoOptions;
var
  p: Integer;
  sMainOption, sSubOption: string;
begin
  p := Pos(':', AExtractOption);
  if (p > 0) then begin
    sMainOption := copy(AExtractOption, 1, p - 1);
    sSubOption := copy(AExtractOption, p + 1, Length(AExtractOption));
  end else begin
    sMainOption := AExtractOption;
    sSubOption := '';
  end;

  if sMainOption = 'DATE' then
    Result := [mtifoExtract, mtifoAsDate]
  else if sMainOption = 'TIME' then
    Result := [mtifoExtract, mtifoAsTime]
  else if sMainOption = 'DATETIME' then
    Result := [mtifoExtract, mtifoAsDateTime]
  else if sMainOption = 'N' then
    Result := [mtifoExtract, mtifoIgnoreNull]
  else
    Result := [];

  if sSubOption = 'N' then
    Result := Result + [mtifoIgnoreNull];
end;

procedure TCustomFreeTable.RecordToBuffer(Rec: TFTMemoryRecord; Buffer: PFTMemBuffer);
var
  I: Integer;
begin
  Move(Rec.Data^, Buffer^, FRecordSize);
  with PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do begin
    BookmarkData := Rec.ID;
    BookmarkFlag := bfCurrent;
  end;
  for I := 0 to BlobFieldCount - 1 do
    PMemBlobArray(Buffer + FBlobOfs)[I] := PMemBlobArray(Rec.FBlobs)[I];
  GetCalcFields({$IFDEF RTL250_UP}TRecBuf{$ENDIF}(Buffer));
end;

function TCustomFreeTable.GetRecord(Buffer: PFTMemBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  Accept: Boolean;
begin
  Result := grOk;
  Accept := True;
  case GetMode of
  gmPrior:
    if FRecordPos <= 0 then begin
      Result := grBOF;
      FRecordPos := -1;
    end else begin
      repeat
        Dec(FRecordPos);
        if Filtered then
          Accept := RecordFilter;
      until Accept or (FRecordPos < 0);
      if not Accept then begin
        Result := grBOF;
        FRecordPos := -1;
      end;
    end;
  gmCurrent:
    if (FRecordPos < 0) or (FRecordPos >= RecordCount) then
      Result := grError
    else if Filtered then
      if not RecordFilter then
        Result := grError;
  gmNext:
    if FRecordPos >= RecordCount - 1 then
      Result := grEOF
    else begin
      repeat
        Inc(FRecordPos);
        if Filtered then
          Accept := RecordFilter;
      until Accept or (FRecordPos > RecordCount - 1);
      if not Accept then begin
        Result := grEOF;
        FRecordPos := RecordCount - 1;
      end;
    end;
  end;
  if Result = grOk then
    RecordToBuffer(Records[FRecordPos], Buffer)
  else if (Result = grError) and DoCheck then
    Error(RsEMemNoRecords);
end;

function TCustomFreeTable.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;

function TCustomFreeTable.GetSaveLoadState: TSaveLoadState;
begin
  Result := FSaveLoadState;
end;

function TCustomFreeTable.GetActiveRecBuf(var RecBuf: PFTMemBuffer): Boolean;
begin
  case State of
  dsBrowse:
    if IsEmpty then
      RecBuf := nil
    else
      RecBuf := PFTMemBuffer(ActiveBuffer);
  dsEdit, dsInsert:
    RecBuf := PFTMemBuffer(ActiveBuffer);
  dsCalcFields:
    RecBuf := PFTMemBuffer(CalcBuffer);
  dsFilter:
    RecBuf := PFTMemBuffer(TempBuffer);
else
  RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

function TCustomFreeTable.InternalGetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  RecBuf: PFTMemBuffer;
  Data: PByte;
  VarData: Variant;
begin
  Result := False;
  if not GetActiveRecBuf(RecBuf) then
    Exit;

  if Field.FieldNo > 0 then begin
    Data := FindFieldData(RecBuf, Field);
    if Data <> nil then begin
      if Field is TBlobField then
        Result := Data <> nil
      else
        Result := Data^ <> 0;
      Inc(Data);
      case Field.DataType of
      ftGuid:
        Result := Result and (StrLenA(PAnsiChar(Data)) > 0);
      ftString, ftFixedChar:
        Result := Result and (not TrimEmptyString or (StrLenA(PAnsiChar(Data)) > 0));
      ftWideString:
{$IFDEF UNICODE}
        Result := Result and (not TrimEmptyString or (StrLen(PWideChar(Data)) > 0));
{$ELSE}
        Result := Result and (not TrimEmptyString or (StrLenW(PWideChar(Data)) > 0));
{$ENDIF UNICODE}
      end;
      if Result and (Buffer <> nil) then
        if Field.DataType = ftVariant then begin
          VarData := PVariant(Data)^;
          PVariant(Buffer)^ := VarData;
        end
        else
          Move(Data^, Buffer^, CalcFieldLen(Field.DataType, Field.Size));
    end;
  end else if State in [dsBrowse, dsEdit, dsInsert, dsCalcFields] then begin
    Inc(RecBuf, FRecordSize + Field.Offset);
    Result := Byte(RecBuf[0]) <> 0;
    if Result and (Buffer <> nil) then
      Move(RecBuf[1], Buffer^, Field.DataSize);
  end;
end;

function TCustomFreeTable.GetFieldData(Field: TField; {$IFDEF RTL250_UP}var
{$ENDIF} Buffer: TFTValueBuffer): Boolean;
begin
  Result := InternalGetFieldData(Field,
{$IFDEF RTL240_UP}@Buffer[0]{$ELSE}Buffer{$ENDIF RTL240_UP});
end;

function TCustomFreeTable.GetFieldsClass: TFieldsClass;
begin
  Result := TFtFields;
end;

{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

function TCustomFreeTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
begin
  Result := InternalGetFieldData(Field, Buffer);
end;
{$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}

procedure TCustomFreeTable.InternalSetFieldData(Field: TField; Buffer: Pointer; const ValidateBuffer: TFTValueBuffer);
var
  RecBuf: PFTMemBuffer;
  Data: PByte;
  VarData: Variant;
begin
  if not(State in dsWriteModes) then
    Error(SNotEditing);
  GetActiveRecBuf(RecBuf);
  if Field.FieldNo > 0 then begin
    if State in [dsCalcFields, dsFilter] then
      Error(SNotEditing);
    if Field.ReadOnly and not(State in [dsSetKey, dsFilter]) then
      ErrorFmt(SFieldReadOnly, [Field.DisplayName]);
    Field.Validate(ValidateBuffer);
    // The non-NEXTGEN Pointer version has "TArray<Byte> := Pointer" in it what interprets an untypes pointer as dyn. array. Not good.
    if Field.FieldKind <> fkInternalCalc then begin
      Data := FindFieldData(RecBuf, Field);
      if Data <> nil then begin
        if Field.DataType = ftVariant then begin
          if Buffer <> nil then
            VarData := PVariant(Buffer)^
          else
            VarData := EmptyParam;
          Data^ := Ord((Buffer <> nil) and not VarIsNullEmpty(VarData));
          if Data^ <> 0 then begin
            Inc(Data);
            PVariant(Data)^ := VarData;
          end
          else
            FillChar(Data^, CalcFieldLen(Field.DataType, Field.Size), 0);
        end else begin
          Data^ := Ord(Buffer <> nil);
          Inc(Data);
          if Buffer <> nil then
            Move(Buffer^, Data^, CalcFieldLen(Field.DataType, Field.Size))
          else
            FillChar(Data^, CalcFieldLen(Field.DataType, Field.Size), 0);
        end;
      end;
    end;
  end
  else { fkCalculated, fkLookup }
  begin
    Inc(RecBuf, FRecordSize + Field.Offset);
    Byte(RecBuf[0]) := Ord(Buffer <> nil);
    if Byte(RecBuf[0]) <> 0 then
      Move(Buffer^, RecBuf[1], Field.DataSize);
  end;
  if not(State in [dsCalcFields, dsFilter, dsNewValue]) then
    DataEvent(deFieldChange, NativeInt(Field));
end;

procedure TCustomFreeTable.SetFieldData(Field: TField; Buffer: TFTValueBuffer);
begin
  InternalSetFieldData(Field,
{$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
end;

{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

procedure TCustomFreeTable.SetFieldData(Field: TField; Buffer: Pointer);
var
  ValidateBuffer: TFTValueBuffer;
begin
  if (Buffer <> nil) and (Field.FieldNo > 0) and (Field.DataSize > 0) then begin
    SetLength(ValidateBuffer, Field.DataSize);
    Move(Buffer^, ValidateBuffer[0], Field.DataSize);
  end
  else
    ValidateBuffer := nil;
  InternalSetFieldData(Field, Buffer, ValidateBuffer);
end;
{$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}

procedure TCustomFreeTable.SetFiltered(Value: Boolean);
begin
  if Active then begin
    CheckBrowseMode;
    if Filtered <> Value then
      inherited SetFiltered(Value);
    First;
  end
  else
    inherited SetFiltered(Value);
end;

procedure TCustomFreeTable.SetOnFilterRecord(const Value: TFilterRecordEvent);
begin
  if Active then begin
    CheckBrowseMode;
    inherited SetOnFilterRecord(Value);
    if Filtered then
      First;
  end
  else
    inherited SetOnFilterRecord(Value);
end;

function TCustomFreeTable.RecordFilter: Boolean;
var
  SaveState: TDataSetState;
begin
  Result := True;
  if Assigned(OnFilterRecord) { //or (FFilterParser <> nil) } or (FFilterExpression <> nil) then begin
    if (FRecordPos >= 0) and (FRecordPos < RecordCount) then begin
      SaveState := SetTempState(dsFilter);
      try
        RecordToBuffer(Records[FRecordPos], PFTMemBuffer(TempBuffer));
        // if (FFilterParser <> nil) and FFilterParser.Eval() then
        // begin
        // FFilterParser.EnableWildcardMatching :=
        // not(foNoPartialCompare in FilterOptions);
        // FFilterParser.CaseInsensitive := foCaseInsensitive in FilterOptions;
        // Result := FFilterParser.Value;
        // end else if FFilterExpression <> nil then
        // Result := FFilterExpression.Evaluate();

        if Assigned(OnFilterRecord) then
          OnFilterRecord(Self, Result);
      except
        AppHandleException(Self);
      end;
      RestoreState(SaveState);
    end
    else
      Result := False;
  end;
end;

function TCustomFreeTable.GetBlobData(Field: TField; Buffer: PFTMemBuffer): TMemBlobData;
begin
  Result := PMemBlobArray(Buffer + FBlobOfs)[Field.Offset];
end;

procedure TCustomFreeTable.SetBlobData(Field: TField; Buffer: PFTMemBuffer; Value: TMemBlobData);
begin
  if Buffer = PFTMemBuffer(ActiveBuffer) then begin
    if State = dsFilter then
      Error(SNotEditing);
    PMemBlobArray(Buffer + FBlobOfs)[Field.Offset] := Value;
  end;
end;

procedure TCustomFreeTable.CloseBlob(Field: TField);
begin
  if (FRecordPos >= 0) and (FRecordPos < FRecords.Count) and (State = dsEdit) then
    PMemBlobArray(ActiveBuffer + FBlobOfs)[Field.Offset] := PMemBlobArray(Records[FRecordPos].FBlobs)[Field.Offset]
  else
    PMemBlobArray(ActiveBuffer + FBlobOfs)[Field.Offset] := '';
end;

function TCustomFreeTable.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TFTMemBlobStream.Create(Field as TBlobField, Mode);
end;

procedure TCustomFreeTable.CreateFields;
begin
  inherited;

end;

function TCustomFreeTable.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  Result := (Bookmark <> nil) and FActive and
    (FindRecordID(TFTBookmarkData({$IFDEF RTL200_UP}Pointer(@Bookmark[0]){$ELSE}Bookmark{$ENDIF RTL200_UP}^)) <> nil);
end;

function TCustomFreeTable.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
begin
  if (Bookmark1 = nil) and (Bookmark2 = nil) then
    Result := 0
  else if (Bookmark1 <> nil) and (Bookmark2 = nil) then
    Result := 1
  else if (Bookmark1 = nil) and (Bookmark2 <> nil) then
    Result := -1
  else if TFTBookmarkData({$IFDEF RTL200_UP}Pointer(@Bookmark1[0]){$ELSE}Bookmark1{$ENDIF RTL200_UP}^) >
    TFTBookmarkData({$IFDEF RTL200_UP}Pointer(@Bookmark2[0]){$ELSE}Bookmark2{$ENDIF RTL200_UP}^) then
    Result := 1
  else if TFTBookmarkData({$IFDEF RTL200_UP}Pointer(@Bookmark1[0]){$ELSE}Bookmark1{$ENDIF RTL200_UP}^) <
    TFTBookmarkData({$IFDEF RTL200_UP}Pointer(@Bookmark2[0]){$ELSE}Bookmark2{$ENDIF RTL200_UP}^) then
    Result := -1
  else
    Result := 0;
end;

procedure TCustomFreeTable.GetBookmarkData(Buffer: PFTMemBuffer; Data: TFTBookmark);
begin
  Move(PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData,
    TFTBookmarkData({$IFDEF RTL240_UP}Pointer(@Data[0]){$ELSE}Data{$ENDIF RTL240_UP}^), SizeOf(TFTBookmarkData));
end;

{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

procedure TCustomFreeTable.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
var
  Bookmark: TBookmark;
begin
  SetLength(Bookmark, SizeOf(TFTBookmarkData));
  GetBookmarkData(Buffer, Bookmark);
  Move(Bookmark[0], Data^, SizeOf(TFTBookmarkData));
end;
{$ENDIF RTL240_UP}
{$ENDIF !NEXTGEN}

procedure TCustomFreeTable.SetBookmarkData(Buffer: PFTMemBuffer; Data: TFTBookmark);
begin
  Move({$IFDEF RTL240_UP}Pointer(@Data[0]){$ELSE}Data{$ENDIF RTL240_UP}^, PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData,
    SizeOf(TFTBookmarkData));
end;

{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

procedure TCustomFreeTable.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  Move(Data^, PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData, SizeOf(TFTBookmarkData));
end;
{$ENDIF RTL240_UP}
{$ENDIF !NEXTGEN}

function TCustomFreeTable.GetBookmarkFlag(Buffer: PFTMemBuffer): TBookmarkFlag;
begin
  Result := PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag;
end;

procedure TCustomFreeTable.SetBookmarkFlag(Buffer: PFTMemBuffer; Value: TBookmarkFlag);
begin
  PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag := Value;
end;

procedure TCustomFreeTable.InternalGotoBookmarkData(BookmarkData: TFTBookmarkData);
var
  Rec: TFTMemoryRecord;
  SavePos: Integer;
  Accept: Boolean;
begin
  Rec := FindRecordID(BookmarkData);
  if Rec <> nil then begin
    Accept := True;
    SavePos := FRecordPos;
    try
      FRecordPos := Rec.Index;
      if Filtered then
        Accept := RecordFilter;
    finally
      if not Accept then
        FRecordPos := SavePos;
    end;
  end;
end;

procedure TCustomFreeTable.InternalGotoBookmark(Bookmark: TFTBookmark);
begin
  InternalGotoBookmarkData(TFTBookmarkData({$IFDEF RTL240_UP}Pointer(@Bookmark[0]){$ELSE}Bookmark{$ENDIF RTL240_UP}^));
end;

{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

procedure TCustomFreeTable.InternalGotoBookmark(Bookmark: Pointer);
begin
  InternalGotoBookmarkData(TFTBookmarkData(Bookmark^));
end;
{$ENDIF RTL240_UP}
{$ENDIF !NEXTGEN}

procedure TCustomFreeTable.InternalSetToRecord(Buffer: PFTMemBuffer);
begin
  InternalGotoBookmarkData(PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData);
end;

procedure TCustomFreeTable.InternalFirst;
begin
  FRecordPos := -1;
end;

procedure TCustomFreeTable.InternalLast;
begin
  FRecordPos := FRecords.Count;
end;


{$IFNDEF COMPILER10_UP}

// Delphi 2006+ has support for WideString
procedure TCustomFreeTable.DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean);
begin
  if Field.DataType = ftWideString then begin
    if ToNative then begin
      Word(Dest^) := Length(PWideString(Source)^) * SizeOf(WideChar);
      Move(PWideChar(Source^)^, (PWideChar(Dest) + 1)^, Word(Dest^));
    end
    else
      SetString(WideString(Dest^), PWideChar(PWideChar(Source) + 1), Word(Source^) div SizeOf(WideChar));
  end
  else
    inherited DataConvert(Field, Source, Dest, ToNative);
end;
{$ENDIF ~COMPILER10_UP}

procedure TCustomFreeTable.AssignMemoryRecord(Rec: TFTMemoryRecord; Buffer: PFTMemBuffer);
var
  I: Integer;
begin
  Move(Buffer^, Rec.Data^, FRecordSize);
  for I := 0 to BlobFieldCount - 1 do
    PMemBlobArray(Rec.FBlobs)[I] := PMemBlobArray(Buffer + FBlobOfs)[I];
end;

procedure TCustomFreeTable.SetMasterFields(const Value: string);
begin
  FMasterLink.FieldNames := Value;
  if Active then
    // RebuildFieldLists;
end;

procedure TCustomFreeTable.SetMemoryRecordData(Buffer: PFTMemBuffer; Pos: Integer);
var
  Rec: TFTMemoryRecord;
begin
  if State = dsFilter then
    Error(SNotEditing);
  Rec := Records[Pos];
  AssignMemoryRecord(Rec, Buffer);
end;

procedure TCustomFreeTable.SetAutoIncFields(Buffer: PFTMemBuffer);
var
  I, Count: Integer;
  Data: PByte;
begin
  Count := 0;
  for I := 0 to FieldCount - 1 do
    if (Fields[I].FieldKind in fkStoredFields) and (Fields[I].DataType = ftAutoInc) then begin
      Data := FindFieldData(Buffer, Fields[I]);
      if Data <> nil then begin
        Data^ := Ord(True);
        Inc(Data);
        Move(FAutoInc, Data^, SizeOf(Longint));
        Inc(Count);
      end;
    end;
  if Count > 0 then
    Inc(FAutoInc);
end;

procedure TCustomFreeTable.InternalAddRecord(Buffer: TFTRecordBuffer; Append: Boolean);
var
  RecPos: Integer;
  Rec: TFTMemoryRecord;
begin
  if Append then begin
    Rec := AddRecord;
    FRecordPos := FRecords.Count - 1;
  end else begin
    if FRecordPos = -1 then
      RecPos := 0
    else
      RecPos := FRecordPos;
    Rec := InsertRecord(RecPos);
    FRecordPos := RecPos;
  end;
  SetAutoIncFields(Buffer);
  SetMemoryRecordData(Buffer, Rec.Index);
end;

procedure TCustomFreeTable.InternalDelete;
var
  Accept: Boolean;
begin
  Records[FRecordPos].Free;
  if FRecordPos >= FRecords.Count then
    Dec(FRecordPos);
  Accept := True;
  repeat
    if Filtered then
      Accept := RecordFilter;
    if not Accept then
      Dec(FRecordPos);
  until Accept or (FRecordPos < 0);
  if FRecords.Count = 0 then
    FLastID := Low(Integer);
end;

procedure TCustomFreeTable.InternalPost;
var
  RecPos: Integer;
begin
  inherited InternalPost;

  if State = dsEdit then
    SetMemoryRecordData(PFTMemBuffer(ActiveBuffer), FRecordPos)
  else begin
    if State in [dsInsert] then
      SetAutoIncFields(PFTMemBuffer(ActiveBuffer));
    if FRecordPos >= FRecords.Count then begin
      AddRecord;
      FRecordPos := FRecords.Count - 1;
      SetMemoryRecordData(PFTMemBuffer(ActiveBuffer), FRecordPos);
    end else begin
      if FRecordPos = -1 then
        RecPos := 0
      else
        RecPos := FRecordPos;
      SetMemoryRecordData(PFTMemBuffer(ActiveBuffer), InsertRecord(RecPos).Index);
      FRecordPos := RecPos;
    end;
  end;
end;

procedure TCustomFreeTable.OpenCursor(InfoQuery: Boolean);
begin
  try
    if FDataSet <> nil then begin
      if FLoadStructure then
        CopyStructure(FDataSet, FAutoIncAsInteger);
    end;
  except
    SysUtils.Abort;
    Exit;
  end;

  if not InfoQuery then begin
    if FieldCount > 0 then
      FieldDefs.Clear;
    InitFieldDefsFromFields;
  end;
  FActive := True;

  inherited OpenCursor(InfoQuery);
end;

procedure TCustomFreeTable.InternalOpen;
begin
  BookmarkSize := SizeOf(TFTBookmarkData);
  FieldDefs.Updated := False;
  FieldDefs.Update;
  FieldDefList.Update;
{$IFNDEF HAS_AUTOMATIC_DB_FIELDS}
  if DefaultFields then
{$ENDIF !HAS_AUTOMATIC_DB_FIELDS}
    CreateFields;
  BindFields(True);
  InitBufferPointers(True);
  InternalFirst;
end;

procedure TCustomFreeTable.DoAfterOpen;
begin
  if (FDataSet <> nil) and FLoadRecords then begin
    if not FDataSet.Active then
      FDataSet.Open;
    if FDataSet.Active and FDataSetClosed then
      FDataSet.Close;
  end else if not IsEmpty then
    SortOn;
  inherited DoAfterOpen;
End;

procedure TCustomFreeTable.DoAfterPost;
begin
  if not BlockEvents then begin
    inherited;
    UpdateIndex;
  end;
end;

procedure TCustomFreeTable.DoAfterRefresh;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoAfterScroll;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.SetSaveLoadState(const Value: TSaveLoadState);
begin
  FSaveLoadState := Value;
  case FSaveLoadState of
  slsNone:
    BlockEvents := False;
  slsLoading:
    BlockEvents := True;
  slsSaving:
    BlockEvents := True;
  end;
end;

procedure TCustomFreeTable.DoBeforeInsert;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoBeforeOpen;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoBeforePost;
begin
  if not BlockEvents then begin
    inherited;
  end;
end;

procedure TCustomFreeTable.DoBeforeRefresh;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoBeforeScroll;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoOnCalcFields;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoOnNewRecord;
begin
  if not BlockEvents then
    inherited;
end;

// Filtering contribution June 2009 - C.Schiffler - MANTIS # 0004328
// Uses expression parser.
procedure TCustomFreeTable.SetFilterText(const Value: string);

  procedure UpdateFilter;
  begin
    // FreeAndNil(FFilterParser);
    FreeAndNil(FFilterExpression);
    if Filter <> '' then begin
      if UseDataSetFilter then
        FFilterExpression := TDBFilterExpression.Create(Self, Value, FilterOptions)
        // else begin
        // FFilterParser := TExprParser.Create;
        // FFilterParser.OnGetVariable := ParserGetVariableValue;
        // if foCaseInsensitive in FilterOptions then
        // FFilterParser.Expression := AnsiUpperCase(Filter)
        // else
        // FFilterParser.Expression := Filter;
        // end;
    end;
  end;

begin
  if Active then begin
    CheckBrowseMode;
    inherited SetFilterText(Value);
    UpdateFilter;
    if Filtered then
      First;
  end else begin
    inherited SetFilterText(Value);
    UpdateFilter;
  end;
end;

procedure TCustomFreeTable.SetIndex(Value: string);
var
  I: Integer;
begin
  if Value <> '' then begin
    for I := 0 to IndexDefs.Count - 1 do begin
      if Value = IndexDefs[I].Name then begin
        SortOn(IndexDefs[I].Fields,
          ixCaseInsensitive in IndexDefs[I].Options,
          ixDescending in IndexDefs[I].Options);
        Break;
      end;
    end;
    if I = IndexDefs.Count then
      raise Exception.Create('Index ' + QuotedStr(Value) + ' not found!');
    FIndexFieldNames := '';
  end;
  FIndexName := Value;
end;

procedure TCustomFreeTable.SetIndexDefs(const Value: TIndexDefs);
begin
  FIndexDefs := Value;
end;

procedure TCustomFreeTable.SetIndexFieldNames(const Value: string);
begin
  if Value <> FIndexFieldNames then begin
    SortOn(Value);
    FIndexFieldNames := Value;
    FIndexName := '';
  end;
end;

procedure TCustomFreeTable.SetIndexName(const Value: string);
begin
  SetIndex(Value);
end;

procedure TCustomFreeTable.SetKeyFieldNames(const Value: string);
begin
  FKeyFieldNames := Value;
  FKeyFieldList.Text := StringReplace(FKeyFieldNames, ';', #13#10, [rfReplaceAll]);
end;

function TCustomFreeTable.ParserGetVariableValue(Sender: TObject; const VarName: string; var Value: Variant): Boolean;
var
  Field: TField;
begin
  Field := FieldByName(VarName);
  if Assigned(Field) then begin
    Value := Field.Value;
    Result := True;
  end
  else
    Result := False;
end;

procedure TCustomFreeTable.InternalClose;
begin
  ClearRecords;
  FAutoInc := 1;
  BindFields(False);
{$IFNDEF HAS_AUTOMATIC_DB_FIELDS}
  if DefaultFields then
{$ENDIF !HAS_AUTOMATIC_DB_FIELDS}
    DestroyFields;
  FreeIndexList;
  FActive := False;
end;

procedure TCustomFreeTable.InternalHandleException;
begin
  AppHandleException(Self);
end;

procedure TCustomFreeTable.InternalInitFieldDefs;
begin
  // InitFieldDefsFromFields
end;

function TCustomFreeTable.IsCursorOpen: Boolean;
begin
  Result := FActive;
end;

function TCustomFreeTable.GetRecordCount: Integer;
begin
  Result := FRecords.Count;
end;

function TCustomFreeTable.GetRecNo: Integer;
begin
  CheckActive;
  UpdateCursorPos;
  if (FRecordPos = -1) and (RecordCount > 0) then
    Result := 1
  else
    Result := FRecordPos + 1;
end;

procedure TCustomFreeTable.SetRecNo(Value: Integer);
begin
  if (Value > 0) and (Value <= FRecords.Count) then begin
    DoBeforeScroll;
    FRecordPos := Value - 1;
    Resync([]);
    DoAfterScroll;
  end;
end;

procedure TCustomFreeTable.SetUseDataSetFilter(const Value: Boolean);
begin
  if Value <> FUseDataSetFilter then begin
    FUseDataSetFilter := Value;
    SetFilterText(Filter); // update the filter engine
  end;
end;

function TCustomFreeTable.IsSequenced: Boolean;
begin
  Result := not Filtered;
end;

function TCustomFreeTable.Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll;
  Result := DataSetLocateThrough(Self, KeyFields, KeyValues, Options);
  if Result then begin
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
  end;
end;

function TCustomFreeTable.Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant;
var
  FieldCount: Integer;
  Fields: TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
  Fld: TField; // else BAD mem leak on 'Field.asString'
  SaveState: TDataSetState;
  I: Integer;
  Matched: Boolean;

  function CompareField(var Field: TField; Value: Variant): Boolean; { BG }
  var
    S: string;
  begin
    if Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString{$ENDIF}] then begin
      if Value = Null then
        Result := Field.IsNull
      else begin
        S := Field.AsString;
        Result := AnsiSameStr(S, Value);
      end;
    end
    else
      Result := (Field.Value = Value);
  end;

  function CompareRecord: Boolean;
  var
    I: Integer;
  begin
    if FieldCount = 1 then begin
      Fld := TField(Fields.First);
      Result := CompareField(Fld, KeyValues);
    end else begin
      Result := True;
      for I := 0 to FieldCount - 1 do begin
        Fld := TField(Fields[I]);
        Result := Result and CompareField(Fld, KeyValues[I]);
      end;
    end;
  end;

begin
  Result := Null;
  CheckBrowseMode;
  if IsEmpty then
    Exit;

  Fields := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
  try
    GetFieldList(Fields, KeyFields);
    FieldCount := Fields.Count;
    Matched := CompareRecord;
    if Matched then
      Result := FieldValues[ResultFields]
    else begin
      SaveState := SetTempState(dsCalcFields);
      try
        try
          for I := 0 to RecordCount - 1 do begin
            RecordToBuffer(Records[I], PFTMemBuffer(TempBuffer));
            CalculateFields(TempBuffer);
            Matched := CompareRecord;
            if Matched then
              Break;
          end;
        finally
          if Matched then
            Result := FieldValues[ResultFields];
        end;
      finally
        RestoreState(SaveState);
      end;
    end;
  finally
    Fields.Free;
  end;
end;

procedure TCustomFreeTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Dataset) then
    SetDataSet(nil);
end;

procedure TCustomFreeTable.EmptyTable;
begin
  if Active then begin
    CheckBrowseMode;
    ClearRecords;
    ClearBuffers;
    DataEvent(deDataSetChange, 0);
  end;
end;

procedure TCustomFreeTable.CheckStructure(UseAutoIncAsInteger: Boolean);

  procedure CheckDataTypes(FieldDefs: TFieldDefs);
  var
    J: Integer;
  begin
    for J := FieldDefs.Count - 1 downto 0 do begin
      if (FieldDefs.Items[J].DataType = ftAutoInc) and UseAutoIncAsInteger then
        FieldDefs.Items[J].DataType := ftInteger;
      if not(FieldDefs.Items[J].DataType in ftSupported) then
        FieldDefs.Items[J].Free;
    end;
  end;

var
  I: Integer;
begin
  CheckDataTypes(FieldDefs);
  for I := 0 to FieldDefs.Count - 1 do
    if (csDesigning in ComponentState) and (Owner <> nil) then
      FieldDefs.Items[I].CreateField(Owner)
    else
      FieldDefs.Items[I].CreateField(Self);
end;

procedure TCustomFreeTable.SetDataSet(ADataSet: TDataset);
begin
  if ADataSet <> Self then
    ReplaceComponentReference(Self, ADataSet, TComponent(FDataSet));
end;

procedure TCustomFreeTable.SetDataSource(const Value: TDataSource);
begin
  if IsLinkedTo(Value) then
    DatabaseError('SelfRef', Self);
  // FMasterLink.DataSource := Value;
  if Active then begin
    // RebuildFieldLists;
    // MasterChanged(Self);
  end;

end;

procedure TCustomFreeTable.FixReadOnlyFields(MakeReadOnly: Boolean);
var
  I: Integer;
begin
  if MakeReadOnly then
    for I := 0 to FieldCount - 1 do
      Fields[I].ReadOnly := (Fields[I].Tag = 1)
  else
    for I := 0 to FieldCount - 1 do begin
      Fields[I].Tag := Ord(Fields[I].ReadOnly);
      Fields[I].ReadOnly := False;
    end;
end;

procedure TCustomFreeTable.CopyStructure(Source: TDataset; UseAutoIncAsInteger: Boolean);
var
  I: Integer;
begin
  if Source = nil then
    Exit;
  CheckInactive;
  for I := FieldCount - 1 downto 0 do
    Fields[I].Free;

  Source.FieldDefs.Update;
  FieldDefs := Source.FieldDefs;
  CheckStructure(UseAutoIncAsInteger);
end;

function TCustomFreeTable.LoadFromDataSet(Source: TDataset; RecordCount: Integer; Mode: TLoadMode;
  DisableAllControls: Boolean = True): Integer;
var
  MovedCount, I, FinalAutoInc: Integer;
  SB, DB: TBookmark;
begin
  Result := 0;
  if Source = Self then
    Exit;
  SaveLoadState := slsLoading;
  // ********** Source *********
  if DisableAllControls then
    Source.DisableControls;
  if not Source.Active then
    Source.Open
  else
    Source.CheckBrowseMode;
  Source.UpdateCursorPos;
  SB := Source.GetBookmark;
  // ***************************
  try
    // ********** Dest (self) ***********
    if DisableAllControls then
      DisableControls;
    Filtered := False;
    if Mode = lmCopy then begin
      Close;
      CopyStructure(Source, FAutoIncAsInteger);
    end;
    FreeIndexList;
    if not Active then
      Open
    else
      CheckBrowseMode;
    DB := GetBookmark;
    // **********************************
    try
      if RecordCount > 0 then
        MovedCount := RecordCount
      else begin
        Source.First;
        MovedCount := MaxInt;
      end;

      FinalAutoInc := 0;
      FixReadOnlyFields(False);
      // find first source autoinc field
      FSrcAutoIncField := nil;
      if Mode = lmCopy then
        for I := 0 to Source.FieldCount - 1 do
          if Source.Fields[I].DataType = ftAutoInc then begin
            FSrcAutoIncField := Source.Fields[I];
            Break;
          end;
      try
        while not Source.Eof do begin
          Append;
          AssignRecord(Source, Self, True);
          // assign AutoInc value manually (make user keep largest if source isn't sorted by autoinc field)
          if FSrcAutoIncField <> nil then begin
            FinalAutoInc := Max(FinalAutoInc, FSrcAutoIncField.AsInteger);
            FAutoInc := FSrcAutoIncField.AsInteger;
          end;
          Post;
          Inc(Result);
          if Result >= MovedCount then
            Break;
          Source.Next;
        end;
      finally
        FixReadOnlyFields(True);
        if Mode = lmCopy then
          FAutoInc := FinalAutoInc + 1;
        FSrcAutoIncField := nil;
        First;
      end;
    finally
      // ********** Dest (self) ***********
      // move back to where we started from
      if (DB <> nil) and BookmarkValid(DB) then begin
        GotoBookmark(DB);
        FreeBookmark(DB);
      end;
      if DisableAllControls then
        EnableControls;
      // **********************************
    end;
  finally
    // ************** Source **************
    // move back to where we started from
    if (SB <> nil) and Source.BookmarkValid(SB) and not Source.IsEmpty then begin
      Source.GotoBookmark(SB);
      Source.FreeBookmark(SB);
    end;
    if Source.Active and FDataSetClosed then
      Source.Close;
    if DisableAllControls then
      Source.EnableControls;
    // ************************************
    SaveLoadState := slsNone;
  end;
end;

function TCustomFreeTable.SaveToDataSet(Dest: TDataset; RecordCount: Integer; DisableAllControls: Boolean = True): Integer;
var
  MovedCount: Integer;
  SB, DB: TBookmark;
begin
  Result := 0;

  if Dest = Self then
    Exit;
  SaveLoadState := slsSaving;
  // *********** Dest ************
  if DisableAllControls then
    Dest.DisableControls;
  if not Dest.Active then
    Dest.Open
  else
    Dest.CheckBrowseMode;
  Dest.UpdateCursorPos;
  DB := Dest.GetBookmark;
  SB := nil;
  // *****************************
  try
    // *********** Source (self) ************
    if DisableAllControls then
      DisableControls;
    CheckBrowseMode;
    SB := GetBookmark;
    // **************************************
    try
      if RecordCount > 0 then
        MovedCount := RecordCount
      else begin
        First;
        MovedCount := MaxInt;
      end;

      while not Eof do begin
        Dest.Append;
        AssignRecord(Self, Dest, True);
        Dest.Post;
        Inc(Result);
        if Result >= MovedCount then
          Break;
        Next;
      end;
    finally
      // *********** Source (self) ************
      if (SB <> nil) and BookmarkValid(SB) then begin
        GotoBookmark(SB);
        FreeBookmark(SB);
      end;
      if DisableAllControls then
        EnableControls;
      // **************************************
    end;
  finally
    // ******************* Dest *******************
    // move back to where we started from
    if (DB <> nil) and Dest.BookmarkValid(DB) and not Dest.IsEmpty then begin
      Dest.GotoBookmark(DB);
      Dest.FreeBookmark(DB);
    end;
    if Dest.Active and FDataSetClosed then
      Dest.Close;
    if DisableAllControls then
      Dest.EnableControls;
    // ********************************************
    SaveLoadState := slsNone;
  end;
end;

procedure TCustomFreeTable.SortOn(const FieldNames: string = ''; CaseInsensitive: Boolean = True; Descending: Boolean = False);
begin
  // Post the table before sorting
  if State in dsEditModes then
    Post;

  if FieldNames <> '' then
    CreateIndexList(FieldNames)
  else if FKeyFieldNames <> '' then
    CreateIndexList(FKeyFieldNames)
  else
    Exit;
  FCaseInsensitiveSort := CaseInsensitive;
  FDescendingSort := Descending;
  try
    Sort;
  except
    FreeIndexList;
    raise;
  end;
end;

procedure TCustomFreeTable.SwapRecords(Idx1, Idx2: Integer);
begin
  FRecords.Exchange(Idx1, Idx2);
end;

procedure TCustomFreeTable.UpdateIndex;
begin
  if IndexFieldNames <> '' then
    SortOn(IndexFieldNames)
  else if IndexName <> '' then begin
    SetIndex(IndexName);
  end;
end;

procedure TCustomFreeTable.Sort;
var
  Pos: {$IFDEF COMPILER12_UP}DB.TBookmark{$ELSE}TBookmarkStr{$ENDIF COMPILER12_UP};
begin
  if Active and (FRecords <> nil) and (FRecords.Count > 0) then begin
    Pos := Bookmark;
    try
      QuickSort(0, FRecords.Count - 1, CompareRecords);
      SetBufListSize(0);
      InitBufferPointers(False);
      try
        SetBufListSize(BufferCount + 1);
      except
        SetState(dsInactive);
        CloseCursor;
        raise;
      end;
    finally
      Bookmark := Pos;
    end;
    Resync([]);
  end;
end;

procedure TCustomFreeTable.QuickSort(L, R: Integer; Compare: TCompareRecords);
var
  I, J: Integer;
  p: TFTMemoryRecord;
begin
  repeat
    I := L;
    J := R;
    p := Records[(L + R) shr 1];
    repeat
      while Compare(Records[I], p) < 0 do
        Inc(I);
      while Compare(Records[J], p) > 0 do
        Dec(J);
      if I <= J then begin
        FRecords.Exchange(I, J);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J, Compare);
    L := I;
  until I >= R;
end;

function TCustomFreeTable.CompareRecords(Item1, Item2: TFTMemoryRecord): Integer;
var
  Data1, Data2: PByte;
  CData1, CData2, Buffer1, Buffer2: array [0 .. dsMaxStringSize] of Byte;
  F: TField;
  I: Integer;
begin
  Result := 0;
  if FIndexList <> nil then begin
    for I := 0 to FIndexList.Count - 1 do begin
      F := TField(FIndexList[I]);
      if F.FieldKind = fkData then begin
        Data1 := FindFieldData(Item1.Data, F);
        if Data1 <> nil then begin
          Data2 := FindFieldData(Item2.Data, F);
          if Data2 <> nil then begin
            if Boolean(Data1^) and Boolean(Data2^) then begin
              Inc(Data1);
              Inc(Data2);
              Result := CompareFields(Data1, Data2, F.DataType, FCaseInsensitiveSort);
            end else if Boolean(Data1^) then
              Result := 1
            else if Boolean(Data2^) then
              Result := -1;
            if FDescendingSort then
              Result := -Result;
          end;
        end;
        if Result <> 0 then
          Exit;
      end else begin
        FillChar(Buffer1, dsMaxStringSize, 0);
        FillChar(Buffer2, dsMaxStringSize, 0);
        RecordToBuffer(Item1, @Buffer1[0]);
        RecordToBuffer(Item2, @Buffer2[0]);
        Move(Buffer1[1 + FRecordSize + F.Offset], CData1, F.DataSize);
        if CData1[0] <> 0 then begin
          Move(Buffer2[1 + FRecordSize + F.Offset], CData2, F.DataSize);
          if CData2[0] <> 0 then begin
            if Boolean(CData1[0]) and Boolean(CData2[0]) then
              Result := CompareFields(@CData1, @CData2, F.DataType, FCaseInsensitiveSort)
            else if Boolean(CData1[0]) then
              Result := 1
            else if Boolean(CData2[0]) then
              Result := -1;
            if FDescendingSort then
              Result := -Result;
          end;
        end;
        if Result <> 0 then
          Exit;
      end;
    end;
  end;
  if Result = 0 then begin
    if Item1.ID > Item2.ID then
      Result := 1
    else if Item1.ID < Item2.ID then
      Result := -1;
    if FDescendingSort then
      Result := -Result;
  end;
end;

function TCustomFreeTable.GetIndexFieldNames: string;
begin
  Result := FIndexFieldNames
end;

function TCustomFreeTable.GetIndexName: string;
begin
  Result := FIndexName;
end;

function TCustomFreeTable.GetIsIndexField(Field: TField): Boolean;
begin
  if FIndexList <> nil then
    Result := FIndexList.IndexOf(Field) >= 0
  else
    Result := False;
end;

function TCustomFreeTable.GetKeyFieldList: TStringList;
begin
  Result := FKeyFieldList;
end;

function TCustomFreeTable.GetKeyFieldsValues(AdditionalValues: array of Variant): Variant;
var
  I, iIni, iEnd: Integer;
  List: TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
  FldNames: string;
begin
  Result := Null;
  FldNames := FKeyFieldNames;
  if Pos(';', FldNames) > 0 then begin
    List := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
    GetFieldList(List, FldNames);
    iEnd := List.Count - 1 + Length(AdditionalValues);
    Result := VarArrayCreate([0, iEnd], varVariant);
    iIni := 0;
    iEnd := (List.Count - 1);
    for I := iIni to iEnd do
      Result[I] := TField(List[I]).Value;
    iIni := iEnd;
    iEnd := iEnd + Length(AdditionalValues);
    for I := iIni to iEnd do begin
      Result[I] := TField(List[I]).Value;
    end;
    FreeAndNil(List);

  end else if FOneValueInArray then begin
    Result := VarArrayCreate([0, 0], varVariant);
    Result[0] := FieldByName(FldNames).Value;
  end
  else
    Result := FieldByName(FldNames).Value;
end;

procedure TCustomFreeTable.CreateIndexList(const FieldNames: WideString);
type
  TFieldTypeSet = set of TFieldType;

  function GetSetFieldNames(const FieldTypeSet: TFieldTypeSet): string;
  var
    FieldType: TFieldType;
  begin
    for FieldType := Low(TFieldType) to High(TFieldType) do
      if FieldType in FieldTypeSet then
        Result := Result + FieldTypeNames[FieldType] + ', ';
    Result := copy(Result, 1, Length(Result) - 2);
  end;

var
  Pos: Integer;
  F: TField;
begin
  if FIndexList = nil then
    FIndexList := TList.Create
  else
    FIndexList.Clear;
  Pos := 1;
  while Pos <= Length(FieldNames) do begin
    F := FieldByName(ExtractFieldNameEx(FieldNames, Pos));
    if { (F.FieldKind = fkData) and } (F.DataType in ftSupported - ftBlobTypes) then
      FIndexList.Add(F)
    else
      ErrorFmt(SFieldTypeMismatch, [F.DisplayName, GetSetFieldNames(ftSupported - ftBlobTypes), FieldTypeNames[F.DataType]]);
  end;
end;

procedure TCustomFreeTable.FreeIndexList;
begin
  if FIndexList <> nil then begin
    FIndexList.Free;
    FIndexList := nil;
  end;
end;

function TCustomFreeTable.GetValues(FldNames: string = ''): Variant;
var
  I: Integer;
  List: TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
begin
  Result := Null;
  if FldNames = '' then
    FldNames := FKeyFieldNames;
  if FldNames = '' then
    Exit;

  // Mantis 3610: If there is only one field in the dataset, return a
  // variant array with only one element. This seems to be required for
  // ADO, DBIsam, DBX and others to work.
  if Pos(';', FldNames) > 0 then begin
    List := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
    GetFieldList(List, FldNames);
    Result := VarArrayCreate([0, List.Count - 1], varVariant);
    for I := 0 to List.Count - 1 do
      Result[I] := TField(List[I]).Value;
    FreeAndNil(List);
  end else if FOneValueInArray then begin
    Result := VarArrayCreate([0, 0], varVariant);
    Result[0] := FieldByName(FldNames).Value;
  end
  else
    Result := FieldByName(FldNames).Value;
end;

procedure TCustomFreeTable.DoBeforeCancel;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoBeforeClose;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoBeforeDelete;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoBeforeEdit;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoAfterCancel;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoAfterClose;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoAfterDelete;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoAfterEdit;
begin
  if not BlockEvents then
    inherited;
end;

procedure TCustomFreeTable.DoAfterInsert;
begin
  if not BlockEvents then
    inherited;
end;

function TCustomFreeTable.FindDeleted(KeyValues: Variant): Integer;
var
  I, J, Len, Equals: Integer;
  PxKey: TPVariant;
  xKey, ValRow, ValDel: Variant;
begin
  Result := -1;
  if VarIsNull(KeyValues) then
    Exit;
  PxKey := nil;
  Len := VarArrayHighBound(KeyValues, 1);
  try
    for I := 0 to FDeletedValues.Count - 1 do begin
      PxKey := FDeletedValues[I];
      // Mantis #3974 : "FDeletedValues" is a List of Pointers, and each item have two
      // possible value... PxKey (a Variant) or NIL. The list counter is incremented
      // with the ADD() method and decremented with the DELETE() method
      if PxKey <> nil then // ONLY if FDeletedValues[I] have a value <> NIL
      begin
        xKey := PxKey^;
        Equals := -1;
        for J := 0 to Len - 1 do begin
          ValRow := KeyValues[J];
          ValDel := xKey[J];
          if VarCompareValue(ValRow, ValDel) = vrEqual then begin
            Inc(Equals);
            if Equals = (Len - 1) then
              Break;
          end;
        end;
        if Equals = (Len - 1) then begin
          Result := I;
          Break;
        end;
      end;
    end;
  finally
    if PxKey <> nil then
      Dispose(PxKey);
  end;
end;

function TCustomFreeTable.IsDeleted(out Index: Integer): Boolean;
begin
  Index := FindDeleted(GetValues());
  Result := Index > -1;
end;

function TCustomFreeTable.IsLoading: Boolean;
begin
  Result := SaveLoadState = slsLoading;
end;

function TCustomFreeTable.IsSaving: Boolean;
begin
  Result := SaveLoadState = slsSaving;
end;

// === { TFTMemBlobStream } ===================================================

constructor TFTMemBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
begin
  // (rom) added inherited Create;
  inherited Create;
  FMode := Mode;
  FField := Field;
  FDataSet := FField.Dataset as TCustomFreeTable;
  if not FDataSet.GetActiveRecBuf(FBuffer) then
    Exit;
  if not FField.Modified and (Mode <> bmRead) then begin
    if FField.ReadOnly then
      ErrorFmt(SFieldReadOnly, [FField.DisplayName]);
    if not(FDataSet.State in [dsEdit, dsInsert]) then
      Error(SNotEditing);
    FCached := True;
  end
  else
    FCached := (FBuffer = PFTMemBuffer(FDataSet.ActiveBuffer));
  FOpened := True;
  if Mode = bmWrite then
    Truncate;
end;

destructor TFTMemBlobStream.Destroy;
begin
  if FOpened and FModified then
    FField.Modified := True;
  if FModified then
    try
      FDataSet.DataEvent(deFieldChange, NativeInt(FField));
    except
      AppHandleException(Self);
    end;
  inherited Destroy;
end;

function TFTMemBlobStream.GetBlobFromRecord(Field: TField): TMemBlobData;
var
  Rec: TFTMemoryRecord;
  Pos: Integer;
begin
  Result := '';
  Pos := FDataSet.FRecordPos;
  if (Pos < 0) and (FDataSet.RecordCount > 0) then
    Pos := 0
  else if Pos >= FDataSet.RecordCount then
    Pos := FDataSet.RecordCount - 1;
  if (Pos >= 0) and (Pos < FDataSet.RecordCount) then begin
    Rec := FDataSet.Records[Pos];
    if Rec <> nil then
      Result := PMemBlobArray(Rec.FBlobs)[FField.Offset];
  end;
end;

function TFTMemBlobStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := 0;
  if FOpened then begin
    if Count > Size - FPosition then
      Result := Size - FPosition
    else
      Result := Count;
    if Result > 0 then begin
      if FCached then begin
        Move(PFTMemBuffer(FDataSet.GetBlobData(FField, FBuffer))[FPosition], Buffer, Result);
        Inc(FPosition, Result);
      end else begin
        Move(PFTMemBuffer(GetBlobFromRecord(FField))[FPosition], Buffer, Result);
        Inc(FPosition, Result);
      end;
    end;
  end;
end;

function TFTMemBlobStream.Write(const Buffer; Count: Longint): Longint;
var
  Temp: TMemBlobData;
begin
  Result := 0;
  if FOpened and FCached and (FMode <> bmRead) then begin
    Temp := FDataSet.GetBlobData(FField, FBuffer);
    if Length(Temp) < FPosition + Count then
      SetLength(Temp, FPosition + Count);
    Move(Buffer, PFTMemBuffer(Temp)[FPosition], Count);
    FDataSet.SetBlobData(FField, FBuffer, Temp);
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
  end;
end;

function TFTMemBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
  soFromBeginning:
    FPosition := Offset;
  soFromCurrent:
    Inc(FPosition, Offset);
  soFromEnd:
    FPosition := GetBlobSize + Offset;
  end;
  Result := FPosition;
end;

procedure TFTMemBlobStream.Truncate;
begin
  if FOpened and FCached and (FMode <> bmRead) then begin
    FDataSet.SetBlobData(FField, FBuffer, '');
    FModified := True;
  end;
end;

function TFTMemBlobStream.GetBlobSize: Longint;
begin
  Result := 0;
  if FOpened then
    if FCached then
      Result := Length(FDataSet.GetBlobData(FField, FBuffer))
    else
      Result := Length(GetBlobFromRecord(FField));
end;

end.
