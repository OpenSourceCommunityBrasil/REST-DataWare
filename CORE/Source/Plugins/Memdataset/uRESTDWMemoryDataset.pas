unit uRESTDWMemoryDataset;

{$I ..\..\..\Source\Includes\uRESTDWPlataform.inc}

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
}

interface

uses
  SysUtils, Classes, DB, Variants, uRESTDWProtoTypes, uRESTDWMemDBUtils,
  uRESTDWMemExprParser{$IFNDEF FPC}, uRESTDWMemDBFilterExpr, SqlTimSt{$ENDIF},
  uRESTDWComponentBase, uRESTDWConsts;

Const
  ftBlobTypes = [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle,
                 ftDBaseOle, ftTypedBinary, ftOraBlob, ftOraClob
                 {$IF DEFINED(FPC) OR DEFINED(COMPILER10_UP)}, ftWideMemo{$IFEND}];
  // If you add a new supported type you _must_ also update CalcFieldLen()
  ftSupported = [ftString, ftSmallint, ftInteger, ftWord, ftBoolean,
                 ftFloat, ftCurrency, ftDate, ftTime, ftDateTime, ftAutoInc, ftBCD,
                 ftFMTBCD, ftTimestamp,
                 {$IFNDEF FPC}
                  {$IFDEF COMPILER10_UP}
                  ftOraTimestamp, ftFixedWideChar,
                  {$ENDIF COMPILER10_UP}
                  {$IFDEF COMPILER12_UP}
                  ftLongWord, ftShortint, ftByte, ftExtended,
                  {$ENDIF COMPILER12_UP}
                 {$ELSE}
                   ftFixedWideChar,
                 {$ENDIF FPC}
                 ftBytes, ftVarBytes, ftADT, ftFixedChar, ftWideString, ftLargeint,
                 ftVariant, ftGuid] + ftBlobTypes;
  fkStoredFields = [fkData];

type
  {$IFDEF NEXTGEN}
   TRecordBuffer = PByte;
  {$ENDIF !NEXTGEN}
  TPVariant = ^Variant;
  TApplyMode = (amNone, amAppend, amMerge);
  TApplyEvent = procedure(Dataset: TDataset; Rows: Integer) of object;
  TRecordStatus = (rsOriginal, rsUpdated, rsInserted, rsDeleted);
  TApplyRecordEvent = procedure(Dataset: TDataset; RecStatus: TRecordStatus; FoundApply: Boolean) of object;
  TMemBlobData  = TRESTDWBytes;
  TMemBlobArray = array[0..MaxInt div SizeOf(TMemBlobData) - 1] of TMemBlobData;
  PMemBlobArray = ^TMemBlobArray;
  TJvMemoryRecord = class;
  TLoadMode = (lmCopy, lmAppend);
  TSaveLoadState = (slsNone, slsLoading, slsSaving);
  TCompareRecords = function(Item1, Item2: TJvMemoryRecord): Integer of object;
  TWordArray = array of Word;
  TJvBookmarkData = Integer;
  {$IFDEF RTL240_UP}
  PJvMemBuffer = PByte;
  TJvBookmark = TBookmark;
  TJvValueBuffer = TValueBuffer;
  TJvRecordBuffer = TRecordBuffer;
  {$ELSE}
  {$IFDEF UNICODE}
  PJvMemBuffer = PByte;
  {$ELSE}
  PJvMemBuffer = PAnsiChar;
  {$ENDIF UNICODE}
  TJvBookmark = Pointer;
  TJvValueBuffer = Pointer;
  TJvRecordBuffer = Pointer;
  {$ENDIF RTL240_UP}

  IRESTDWMemTable = interface
    function GetRecordCount: Integer;
    function GetMemoryRecord(Index: integer): TJvMemoryRecord;
    function GetOffSets(index : integer) : Word;
    function GetOffSetsBlobs : Word;
    function DataTypeSuported(datatype : TFieldType) : boolean; // new
    function DataTypeIsBlobTypes(datatype : TFieldType) : boolean; // new
    function GetBlobRec(Field: TField; Rec : TJvMemoryRecord) : TMemBlobData;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
    function GetCalcFieldLen(FieldType: TFieldType; Size: Word): Word;
    procedure InternalAddRecord(Buffer  : {$IFDEF FPC}Pointer{$ELSE}
                                          {$IFDEF NEXTGEN}TRecBuf{$ELSE}
                                          {$IF CompilerVersion <= 22}Pointer{$ELSE}TRecordBuffer
                                          {$IFEND}
                                          {$ENDIF}
                                          {$ENDIF};
                               aAppend : Boolean);
    procedure InitRecord(Buffer: PJvMemBuffer);
    function AllocRecordBuffer: PJvMemBuffer;
    procedure SetMemoryRecordData(Buffer: PJvMemBuffer; Pos: Integer);
    function GetDataset : TDataSet;
  end;

  TRESTDWStorageBase = class(TRESTDWComponent)
  private
    {$IFDEF FPC}
      FDatabaseCharSet : TDatabaseCharSet;
    {$ENDIF}
    FEncodeStrs : boolean;
  protected
    procedure SaveDatasetToStream(dataset : TDataset; var stream : TStream); virtual;
    procedure LoadDatasetFromStream(dataset : TDataset; stream : TStream); virtual;

    procedure SaveDWMemToStream(dataset : IRESTDWMemTable; var stream : TStream); virtual;
    procedure LoadDWMemFromStream(dataset : IRESTDWMemTable; stream : TStream); virtual;
  public
    constructor Create(AOwner : TComponent); override;

    procedure SaveToStream(dataset : TDataset; var stream : TStream);
    procedure LoadFromStream(dataset : TDataset; stream : TStream);
  public
    {$IFDEF FPC}
      property DatabaseCharSet : TDatabaseCharSet read FDatabaseCharSet write FDatabaseCharSet;
    {$ENDIF}
    property EncodeStrs : boolean read FEncodeStrs write FEncodeStrs;
  end;

  TRESTDWMemTable = class(TDataSet, IRESTDWMemTable)
  private
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
    FDataSet: TDataSet;
    FDataSetClosed: Boolean;
    FLoadStructure: Boolean;
    FLoadRecords: Boolean;
    FKeyFieldNames: string;
    FApplyMode: TApplyMode;
    FExactApply: Boolean;
    FAutoIncAsInteger: Boolean;
    FOneValueInArray: Boolean;
    FRowsOriginal: Integer;
    FRowsChanged: Integer;
    FRowsAffected: Integer;
    FDeletedValues: TList;
    FStatusName: string;
    FBeforeApply: TApplyEvent;
    FAfterApply: TApplyEvent;
    FBeforeApplyRecord: TApplyRecordEvent;
    FAfterApplyRecord: TApplyRecordEvent;
    FFilterParser: TExprParser; // CSchiffler. June 2009.  See JvExprParser.pas
    {$IFNDEF FPC}
    FFilterExpression: TJvDBFilterExpression; // ahuser. Same filter expression parser that ClientDataSet uses
    {$ENDIF}
    FClearing: Boolean;
    FUseDataSetFilter: Boolean;
    FTrimEmptyString: Boolean;
    FRESTDWStorage : TRESTDWStorageBase;
    function AddRecord: TJvMemoryRecord;
    function InsertRecord(Index: Integer): TJvMemoryRecord;
    function FindRecordID(ID: Integer): TJvMemoryRecord;
    procedure CreateIndexList(const FieldNames: DWWideString);
    procedure FreeIndexList;
    procedure QuickSort(L, R: Integer; Compare: TCompareRecords);
    procedure Sort;
    function CalcRecordSize: Integer;
    function GetMemoryRecord(Index: Integer): TJvMemoryRecord;
    function GetCapacity: Integer;
    function RecordFilter: Boolean;
    procedure SetCapacity(Value: Integer);
    procedure ClearRecords;
    procedure InitBufferPointers(GetProps: Boolean);
    procedure CheckStructure(UseAutoIncAsInteger: Boolean = False);
    procedure AddStatusField;
    procedure HideStatusField;
    function CopyFromDataSet: Integer;
    procedure ClearChanges;
    procedure DoBeforeApply(ADataset: TDataset; RowsPending: Integer);
    procedure DoAfterApply(ADataset: TDataset; RowsApplied: Integer);
    procedure DoBeforeApplyRecord(ADataset: TDataset; RS: TRecordStatus; aFound: Boolean);
    procedure DoAfterApplyRecord(ADataset: TDataset; RS: TRecordStatus; aApply: Boolean);
    procedure SetUseDataSetFilter(const Value: Boolean);
    procedure InternalGotoBookmarkData(BookmarkData: TJvBookmarkData);
    function  InternalGetFieldData(Field: TField; Var Buffer: TJvValueBuffer): Boolean;
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer; const ValidateBuffer: TJvValueBuffer);
  protected
    function FindFieldData(Buffer: Pointer; Field: TField): Pointer;
    function CompareFields(Data1, Data2: Pointer; FieldType: TFieldType;
      CaseInsensitive: Boolean): Integer; virtual;
    // Delphi 2006+ has support for DWWideString
    {$IF DEFINED(FPC) OR NOT DEFINED(COMPILER10_UP)}
      procedure DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean); override;
    {$IFEND}
    procedure AssignMemoryRecord(Rec: TJvMemoryRecord; Buffer: PJvMemBuffer);
    function  GetActiveRecBuf(var RecBuf: PJvMemBuffer): Boolean; virtual;
    procedure InitFieldDefsFromFields;
    procedure RecordToBuffer(Rec: TJvMemoryRecord; Buffer: PJvMemBuffer);
    procedure SetMemoryRecordData(Buffer: PJvMemBuffer; Pos: Integer); virtual;
    procedure SetAutoIncFields(Buffer: PJvMemBuffer); virtual;
    function  CompareRecords(Item1, Item2: TJvMemoryRecord): Integer; virtual;
    function  GetBlobData(Field: TField; Buffer: PJvMemBuffer): TMemBlobData;
    procedure SetBlobData(Field: TField; Buffer: PJvMemBuffer; Value: TMemBlobData);
    {$IFDEF NEXTGEN}
     Function  AllocRecBuf                : TRecBuf;    override;
     Procedure FreeRecBuf    (Var Buffer  : TRecBuf);   override;
    {$ENDIF NEXTGEN}
    Function  AllocRecordBuffer           : PJvMemBuffer; {$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure FreeRecordBuffer(Var Buffer : PJvMemBuffer);{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure InternalInitRecord(Buffer   : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF});{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Function  GetRecord         (Buffer   : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF};
                                 GetMode  : TGetMode;
                                 DoCheck  : Boolean) : TGetResult;        Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure GetBookmarkData   (Buffer   : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF};
                                 Data     : TJvBookmark);                 Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Function  GetBookmarkFlag   (Buffer   : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}): TBookmarkFlag; Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure InternalSetToRecord(Buffer  : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF});                Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure SetBookmarkFlag    (Buffer  : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF};
                                  Value   : TBookmarkFlag);               Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure SetBookmarkData    (Buffer  : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF};
                                  Data    : TJvBookmark);                 Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure InitRecord         (Buffer  : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF});Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure InternalAddRecord  (Buffer  : {$IFDEF FPC}Pointer{$ELSE}{$IFDEF NEXTGEN}TRecBuf{$ELSE}{$IF CompilerVersion <= 22}Pointer{$ELSE}TRecordBuffer{$IFEND}{$ENDIF}{$ENDIF};
                                  aAppend : Boolean);                              {$IFNDEF NEXTGEN}Override;{$ENDIF}
    Function  GetCurrentRecord   (Buffer  : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}): Boolean;Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure ClearCalcFields    (Buffer  : {$IFDEF NEXTGEN}NativeInt{$ELSE}PJvMemBuffer{$ENDIF});Override;

    function GetRecordSize: Word; override;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); override;
    procedure SetFieldData(Field: TField; Buffer: TJvValueBuffer); overload; override;
    {$IFNDEF NEXTGEN}
      {$IFDEF RTL240_UP}
       procedure SetFieldData(Field: TField; Buffer: Pointer); overload; override;
       procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); overload; override;
       procedure InternalGotoBookmark(Bookmark: Pointer); overload; override;
       procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); overload; override;
      {$ENDIF RTL240_UP}
    {$ENDIF ~NEXTGEN}
    procedure CloseBlob(Field: TField); override;
    procedure InternalGotoBookmark(aBookmark: TJvBookmark); overload; override;
    function  GetIsIndexField(Field: TField): Boolean; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
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
    procedure DoAfterOpen; override;
    procedure SetFilterText(const Value: string); override;
    function ParserGetVariableValue(Sender: TObject; const VarName: string; var Value: Variant): Boolean; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    // interface
      function DataTypeSuported(datatype : TFieldType) : boolean;
      function DataTypeIsBlobTypes(datatype : TFieldType) : boolean;
      function GetOffSets(index : integer) : Word;
      function GetOffSetsBlobs : Word;
      function GetBlobRec(Field: TField; Rec : TJvMemoryRecord) : TMemBlobData;
      function GetCalcFieldLen(FieldType: TFieldType; Size: Word): Word;
      function GetDataset : TDataSet;
    // interface
    property Records[Index: Integer]: TJvMemoryRecord read GetMemoryRecord;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function BookmarkValid(aBookmark: TBookmark): Boolean; override;
    function CompareBookmarks(aBookmark1, aBookmark2: TBookmark): Integer; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    procedure FixReadOnlyFields(MakeReadOnly: Boolean);
    Procedure ClearBuffer;
    function GetFieldData(Field: TField; var Buffer: TJvValueBuffer): Boolean; overload; override;
    {$IFNDEF NEXTGEN}
      {$IFDEF RTL240_UP}
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; overload; override;
      {$ENDIF RTL240_UP}
    {$ENDIF ~NEXTGEN}
    function IsSequenced: Boolean; override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; override;
    procedure SortOnFields(const FieldNames: string = '';
      CaseInsensitive: Boolean = True; Descending: Boolean = False);
    procedure SwapRecords(Idx1: integer; Idx2: integer);
    procedure EmptyTable;
    procedure CopyStructure(Source: TDataSet; UseAutoIncAsInteger: Boolean = False);
    function LoadFromDataSet(Source: TDataSet; aRecordCount: Integer;
      Mode: TLoadMode; DisableAllControls: Boolean = True): Integer;
    function SaveToDataSet(Dest: TDataSet; aRecordCount: Integer; DisableAllControls: Boolean = True): Integer;
    property SaveLoadState: TSaveLoadState read FSaveLoadState;
    function GetValues(FldNames: string = ''): Variant;
    function FindDeleted(KeyValues: Variant): Integer;
    function IsDeleted(out Index: Integer): Boolean;
    function IsInserted: Boolean;
    function IsUpdated: Boolean;
    function IsOriginal: Boolean;
    procedure CancelChanges;
    function ApplyChanges: Boolean;
    function IsLoading: Boolean;
    function IsSaving: Boolean;
    Procedure SaveToStream(var Stream : TStream);
    Procedure LoadFromStream(Stream : TStream);

    Procedure Assign(Source : TPersistent); Reintroduce;  Overload; Override;

    property RowsOriginal: Integer read FRowsOriginal;
    property RowsChanged: Integer read FRowsChanged;
    property RowsAffected: Integer read FRowsAffected;
  published
    property Capacity: Integer read GetCapacity write SetCapacity default 0;
    property Active;
    property AutoCalcFields;
    property Filtered;
    property FilterOptions;
    property UseDataSetFilter: Boolean read FUseDataSetFilter write SetUseDataSetFilter default False;
    property FieldDefs;
    {$IFNDEF FPC}
    property ObjectView default False;
    {$ENDIF}
    property DatasetClosed: Boolean read FDatasetClosed write FDatasetClosed default False;
    property KeyFieldNames: string read FKeyFieldNames write FKeyFieldNames;
    property LoadStructure: Boolean read FLoadStructure write FLoadStructure default False;
    property LoadRecords: Boolean read FLoadRecords write FLoadRecords default False;
    property ApplyMode: TApplyMode read FApplyMode write FApplyMode default amNone;
    property ExactApply: Boolean read FExactApply write FExactApply default False;
    property AutoIncAsInteger: Boolean read FAutoIncAsInteger write FAutoIncAsInteger default False;
    property OneValueInArray: Boolean read FOneValueInArray write FOneValueInArray default True;
    property TrimEmptyString: Boolean read FTrimEmptyString write FTrimEmptyString default True;
    property RESTDWStorage : TRESTDWStorageBase read FRESTDWStorage write FRESTDWStorage;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    property BeforeApply: TApplyEvent read FBeforeApply write FBeforeApply;
    property AfterApply: TApplyEvent read FAfterApply write FAfterApply;
    property BeforeApplyRecord: TApplyRecordEvent read FBeforeApplyRecord write FBeforeApplyRecord;
    property AfterApplyRecord: TApplyRecordEvent read FAfterApplyRecord write FAfterApplyRecord;
  end;
  TJvMemBlobStream = class(TStream)
  private
    FField: TBlobField;
    FDataSet: TRESTDWMemTable;
    FBuffer: PJvMemBuffer;
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
    function Read(Buffer: TBytes; Offset, Count: Longint): Longint; overload; override;
    function Read(var Buffer; Count: Longint): Longint;overload; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure Truncate;
  end;
  TJvMemoryRecord = class(TPersistent)
  private
    FMemoryData: TRESTDWMemTable;
    FID: Integer;
    FData: Pointer;
    FBlobs: Pointer;
    function GetIndex: Integer;
    procedure SetMemoryData(Value: TRESTDWMemTable; UpdateParent: Boolean);
  protected
    procedure SetIndex(Value: Integer); virtual;
  public
    constructor Create  (MemoryData: TRESTDWMemTable); virtual;
    constructor CreateEx(MemoryData: TRESTDWMemTable; UpdateParent: Boolean); virtual;
    destructor Destroy; override;
    property MemoryData: TRESTDWMemTable read FMemoryData;
    property ID: Integer read FID write FID;
    property Index: Integer read GetIndex write SetIndex;
    property Data: Pointer read FData Write FData;
    property Blobs: Pointer read FBlobs Write FBlobs;
  end;

implementation
uses
  Types, Math,
  {$IFDEF RTL240_UP}
  System.Generics.Collections,
  {$ENDIF RTL240_UP}
  FMTBcd,
  uRESTDWMemAnsiStrings,
  uRESTDWMemVCLUtils,
  uRESTDWMemResources,
  uRESTDWTools,
  uRESTDWBasicTypes,
  uRESTDWStorageBin;

const
  GuidSize = 38;
  STATUSNAME = 'C67F70Z90'; (* Magic *)

type
  PMemBookmarkInfo = ^TMemBookmarkInfo;
  TMemBookmarkInfo = record
    BookmarkData: TJvBookmarkData;
    BookmarkFlag: TBookmarkFlag;
  end;


Function ExtractFieldNameEx(const Fields: {$IFDEF COMPILER10_UP} DWWideString {$ELSE} string {$ENDIF};
  var Pos: Integer): string;
begin
  Result := ExtractFieldName(Fields, Pos);
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
  else if DestField.ClassType = SourceField.ClassType then
  begin
    case DestField.DataType of
      ftInteger, ftSmallint, ftWord:
        DestField.AsInteger := SourceField.AsInteger;
      ftBCD, ftCurrency:
        DestField.AsCurrency := SourceField.AsCurrency;
      ftFMTBcd:
        DestField.AsBCD := SourceField.AsBCD;
      ftString:
        DestField.AsString := SourceField.AsString;
      {$IF DEFINED(FPC) OR DEFINED(COMPILER10_UP)}
        ftWideString: DestField.AsWideString := SourceField.AsWideString;
        ftFixedWideChar: DestField.AsWideString := SourceField.AsWideString;
      {$IFEND}
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
  if not (FieldType in ftSupported) then
    Result := 0
  else
  if FieldType in ftBlobTypes then
    Result := SizeOf(Longint)
  else
  begin
    Result := Size;
    case FieldType of
      ftString,
      ftFixedChar:
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
      {$IFDEF FPC}
        ftBCD: Result := SizeOf(Currency);
        ftFMTBCD: Result := SizeOf(TBCD);
      {$ELSE}
        ftBCD, ftFMTBCD:
          Result := SizeOf(TBcd);
      {$ENDIF}
      ftTimeStamp:
        Result := SizeOf(TSQLTimeStamp);
      {$IFNDEF FPC}
        {$IFDEF COMPILER10_UP}
        ftOraTimestamp:
          Result := SizeOf(TSQLTimeStamp);
        ftFixedWideChar:
          Result := (Result + 1) * SizeOf(WideChar);
        ftWideString:
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
      {$ELSE}
        ftFixedWideChar:
          Result := (Result + 1) * SizeOf(WideChar);
        ftWideString:
          Result := (Result + 1) * SizeOf(WideChar);
      {$ENDIF}
      ftBytes:
        Result := Size;
      ftVarBytes:
        Result := Size + 2;
      ftADT:
        Result := 0;
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
  {$IFNDEF FPC}
  for I := 0 to FieldDef.ChildDefs.Count - 1 do
    CalcDataSize(FieldDef.ChildDefs[I], DataSize);
  {$ENDIF}
end;
procedure Error(const Msg: string);
begin
  DatabaseError(Msg);
end;
procedure ErrorFmt(const Msg: string; const Args: array of const);
begin
  DatabaseErrorFmt(Msg, Args);
end;
//=== { TJvMemoryRecord } ====================================================
constructor TJvMemoryRecord.Create(MemoryData: TRESTDWMemTable);
begin
  CreateEx(MemoryData, True);
end;

Constructor TJvMemoryRecord.CreateEx(MemoryData: TRESTDWMemTable; UpdateParent: Boolean);
Begin
 Inherited Create;
 SetMemoryData(MemoryData, UpdateParent);
End;

destructor TJvMemoryRecord.Destroy;
begin
 SetMemoryData(nil, True);
 inherited Destroy;
end;

function TJvMemoryRecord.GetIndex: Integer;
begin
  if FMemoryData <> nil then
    Result := FMemoryData.FRecords.IndexOf(Self)
  else
    Result := -1;
end;
procedure TJvMemoryRecord.SetMemoryData(Value: TRESTDWMemTable; UpdateParent: Boolean);
var
  I: Integer;
  DataSize: Integer;
begin
  if FMemoryData <> Value then
  begin
    if FMemoryData <> nil then
    begin
      If not FMemoryData.FClearing Then
       FMemoryData.FRecords.Remove(Self);
      {$IFDEF FPC}
       ReallocMem(FBlobs, 0);
       ReallocMem(FData, 0);
      {$ELSE}
       {$IF CompilerVersion <= 22}
        If FMemoryData.BlobFieldCount > 0 Then
         Finalize(PMemBlobArray(@FBlobs)^[0], FMemoryData.BlobFieldCount);
       {$ELSE}
        ReallocMem(FBlobs, 0);
       {$IFEND}
       ReallocMem(FData, 0);
      {$ENDIF}
     FMemoryData := Nil;
    end;
    if Value <> nil then
    begin
      if UpdateParent then
      begin
        Value.FRecords.Add(Self);
        Inc(Value.FLastID);
        FID := Value.FLastID;
      end;
      FMemoryData := Value;
      if Value.BlobFieldCount > 0 then
      begin
        ReallocMem(FBlobs, Value.BlobFieldCount * SizeOf(Pointer));
        Initialize(PMemBlobArray(FBlobs)^[0], Value.BlobFieldCount);
      end;
      DataSize := 0;
      for I := 0 to Value.FieldDefs.Count - 1 do
        CalcDataSize(Value.FieldDefs[I], DataSize);
      ReallocMem(FData, DataSize);
    end;
  end;
end;
procedure TJvMemoryRecord.SetIndex(Value: Integer);
var
  CurIndex: Integer;
begin
  CurIndex := GetIndex;
  if (CurIndex >= 0) and (CurIndex <> Value) then
    FMemoryData.FRecords.Move(CurIndex, Value);
end;
//=== { TRESTDWMemTable } ======================================================
constructor TRESTDWMemTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRecordPos := -1;
  FLastID := Low(Integer);
  FAutoInc := 1;
  FRecords := TList.Create;
  FStatusName := STATUSNAME;
  FDeletedValues := TList.Create;
  FRowsOriginal := 0;
  FRowsChanged := 0;
  FRowsAffected := 0;
  FSaveLoadState := slsNone;
  FOneValueInArray := True;
  FDataSetClosed := False;
  FTrimEmptyString := True;
  FRESTDWStorage := nil;
end;
destructor TRESTDWMemTable.Destroy;
var
  I: Integer;
  PFValues: TPVariant;
begin
  if Active then
    Close;
  if FFilterParser <> nil then
    FreeAndNil(FFilterParser);
  {$IFNDEF FPC}
  if FFilterExpression <> nil then
    FreeAndNil(FFilterExpression);
  {$ENDIF}
  if Assigned(FDeletedValues) then
  begin
    if FDeletedValues.Count > 0 then
      for I := 0 to (FDeletedValues.Count - 1) do
      begin
        PFValues := FDeletedValues[I];
        if PFValues <> nil then
          Dispose(PFValues);
        FDeletedValues[I] := nil;
      end;
    FreeAndNil(FDeletedValues);
  end;
  FreeIndexList;
  ClearRecords;
  FreeAndNil(FRecords);
  FOffsets := nil;
  inherited Destroy;
end;
function TRESTDWMemTable.CompareFields(Data1, Data2: Pointer;
  FieldType: TFieldType; CaseInsensitive: Boolean): Integer;
begin
  Result := 0;
  case FieldType of
    ftString:
      if CaseInsensitive then
        Result := AnsiCompareText(PDWString(@Data1)^, PDWString(@Data2)^)
      else
        Result := AnsiCompareStr(PDWString(@Data1)^, PDWString(@Data2)^);
    ftSmallint:
      if Smallint(Data1^) > Smallint(Data2^) then
        Result := 1
      else
      if Smallint(Data1^) < Smallint(Data2^) then
        Result := -1;
    ftInteger, ftDate, ftTime, ftAutoInc:
      if Longint(Data1^) > Longint(Data2^) then
        Result := 1
      else
      if Longint(Data1^) < Longint(Data2^) then
        Result := -1;
    ftWord:
      if Word(Data1^) > Word(Data2^) then
        Result := 1
      else
      if Word(Data1^) < Word(Data2^) then
        Result := -1;
    ftBoolean:
      if Wordbool(Data1^) and not Wordbool(Data2^) then
        Result := 1
      else
      if not Wordbool(Data1^) and Wordbool(Data2^) then
        Result := -1;
    ftFloat, ftCurrency:
      if Double(Data1^) > Double(Data2^) then
        Result := 1
      else
      if Double(Data1^) < Double(Data2^) then
        Result := -1;
    {$IFDEF FPC}
      ftFMTBcd : Result := BcdCompare(TBcd(Data1^), TBcd(Data2^));
      ftBcd    :
        if Double(Data1^) > Double(Data2^) then
          Result := 1
        else if Double(Data1^) < Double(Data2^) then
          Result := -1;
    {$ELSE}
      ftFMTBcd, ftBcd:
        Result := BcdCompare(TBcd(Data1^), TBcd(Data2^));
    {$ENDIF}
    ftDateTime:
      if TDateTime(Data1^) > TDateTime(Data2^) then
        Result := 1
      else
      if TDateTime(Data1^) < TDateTime(Data2^) then
        Result := -1;
    ftFixedChar:
      if CaseInsensitive then
        Result := AnsiCompareText(PDWString(@Data1)^, PDWString(@Data2)^)
      else
        Result := AnsiCompareStr(PDWString(@Data1)^, PDWString(@Data2)^);
    {$IF DEFINED(FPC) OR DEFINED(COMPILER10_UP)}
      ftFixedWideChar:
        if CaseInsensitive then
          Result := AnsiCompareText(WideCharToString(PWideChar(Data1)),
            WideCharToString(PWideChar(Data2)))
        else
          Result := AnsiCompareStr(WideCharToString(PWideChar(Data1)),
            WideCharToString(PWideChar(Data2)));
      ftWideString:
        if CaseInsensitive then
          Result := AnsiCompareText(WideCharToString(PWideChar(Data1)),
            WideCharToString(PWideChar(Data2)))
        else
          Result := AnsiCompareStr(WideCharToString(PWideChar(Data1)),
            WideCharToString(PWideChar(Data2)));
    {$IFEND}
    ftLargeint:
      if Int64(Data1^) > Int64(Data2^) then
        Result := 1
      else
      if Int64(Data1^) < Int64(Data2^) then
        Result := -1;
    ftVariant:
      Result := 0;
    ftGuid:
      Result := CompareText(PDWString(Data1)^, PDWString(Data2)^);
  end;
end;

function TRESTDWMemTable.GetCapacity: Integer;
begin
  if FRecords <> nil then
    Result := FRecords.Capacity
  else
    Result := 0;
end;
procedure TRESTDWMemTable.SetCapacity(Value: Integer);
begin
  if FRecords <> nil then
    FRecords.Capacity := Value;
end;
function TRESTDWMemTable.AddRecord: TJvMemoryRecord;
begin
  Result := TJvMemoryRecord.Create(Self);
end;
function TRESTDWMemTable.FindRecordID(ID: Integer): TJvMemoryRecord;
var
  I: Integer;
begin
  for I := 0 to FRecords.Count - 1 do
  begin
    Result := TJvMemoryRecord(FRecords[I]);
    if Result.ID = ID then
      Exit;
  end;
  Result := nil;
end;
function TRESTDWMemTable.InsertRecord(Index: Integer): TJvMemoryRecord;
begin
  Result := AddRecord;
  Result.Index := Index;
end;

function TRESTDWMemTable.GetMemoryRecord(Index: Integer): TJvMemoryRecord;
begin
  Result := TJvMemoryRecord(@FRecords[Index]^);
end;

procedure TRESTDWMemTable.InitFieldDefsFromFields;
var
  I: Integer;
  Offset: Word;
  Field: TField;
  FieldDefsUpdated: Boolean;
  FieldLen: Word;
begin
  if FieldDefs.Count = 0 then
  begin
    for I := 0 to FieldCount - 1 do
    begin
      Field := Fields[I];
      if (Field.FieldKind in fkStoredFields) and not (Field.DataType in ftSupported) then
        ErrorFmt('Field ''%s'' is of unknown type', [Field.DisplayName]);
    end;
    FreeIndexList;
  end;
  Offset := 0;
  inherited InitFieldDefsFromFields;
  { Calculate fields offsets }
  SetLength(FOffsets, FieldDefs.Count);
  FieldDefs.Update;
  FieldDefsUpdated := FieldDefs.Updated;
  try
    FieldDefs.Updated := True; // Performance optimization: FieldDefList.Updated returns False is FieldDefs.Updated is False
    for I := 0 to FieldDefs.Count - 1 do
    begin
      FOffsets[I] := Offset;
      if FieldDefs[I].DataType in ftSupported - ftBlobTypes then
      begin
        FieldLen := CalcFieldLen(FieldDefs[I].DataType, FieldDefs[I].Size);
        if Offset + FieldLen + 1 <= high(Offset) then
          Inc(Offset, FieldLen + 1)
        else
          raise ERangeError.CreateResFmt(@RsEFieldOffsetOverflow, [I]);
      end;
    end;
  finally
    FieldDefs.Updated := FieldDefsUpdated;
  end;
end;
function TRESTDWMemTable.FindFieldData(Buffer: Pointer; Field: TField): Pointer;
var
  Index: Integer;
  DataType: TFieldType;
begin
  Result := nil;
  Index := Field.FieldNo - 1; // FieldDefList index (-1 and 0 become less than zero => ignored)
  If (Index >= 0) And (Buffer <> nil) Then
   Begin
    DataType := FieldDefs[Index].DataType;
    If DataType in ftSupported then
      if DataType in ftBlobTypes then
       Begin
        {$IFDEF FPC}
         Result := Pointer(GetBlobData(Field, Buffer));
        {$ELSE}
         {$IF CompilerVersion <= 22}
          Result := Pointer(@PMemBlobArray(PJvMemBuffer(Buffer) + FOffsets[Index] + FBlobOfs)^[Field.Offset]);
         {$ELSE}
          Result := Pointer(GetBlobData(Field, Buffer));
         {$IFEND}
        {$ENDIF}
       End
      Else
       Result := Pointer(PJvMemBuffer(Buffer) + FOffsets[Index]);
   End;
End;

function TRESTDWMemTable.CalcRecordSize: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FieldDefs.Count - 1 do
    CalcDataSize(FieldDefs[I], Result);
end;
procedure TRESTDWMemTable.InitBufferPointers(GetProps: Boolean);
begin
  if GetProps then
    FRecordSize := CalcRecordSize;
  FBookmarkOfs := FRecordSize + CalcFieldsSize;
  FBlobOfs := FBookmarkOfs + SizeOf(TMemBookmarkInfo);
  FRecBufSize := FBlobOfs + BlobFieldCount * SizeOf(Pointer);
end;

procedure TRESTDWMemTable.ClearRecords;
var
  I: Integer;
begin
  FClearing := True;
  try
   If Assigned(FRecords) Then
    Begin
     for I := FRecords.Count - 1 downto 0  do
      TJvMemoryRecord(FRecords[I]).Free;
     FRecords.Clear;
    End;
  finally
    FClearing := False;
  end;
  FLastID := Low(Integer);
  FRecordPos := -1;
end;

function TRESTDWMemTable.AllocRecordBuffer: PJvMemBuffer;
begin
  {$IFDEF COMPILER12_UP}
  GetMem(Result, FRecBufSize);
  {$ELSE}
  Result := StrAlloc(FRecBufSize);
  {$ENDIF COMPILER12_UP}
  if BlobFieldCount > 0 then
    Initialize(PMemBlobArray(Result + FBlobOfs)[0], BlobFieldCount);
end;

procedure TRESTDWMemTable.FreeRecordBuffer(var Buffer: PJvMemBuffer);
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

procedure TRESTDWMemTable.ClearCalcFields(Buffer: {$IFDEF NEXTGEN}NativeInt{$ELSE}PJvMemBuffer{$ENDIF});
begin
 {$IFNDEF NEXTGEN}
  FillChar(Buffer[FRecordSize], CalcFieldsSize, 0);
 {$ENDIF !NEXTGEN}
end;

{$IFDEF NEXTGEN}
Function TRESTDWMemTable.AllocRecBuf : TRecBuf;
Begin
 Result := TRecBuf(AllocRecordBuffer);
End;

Procedure TRESTDWMemTable.FreeRecBuf(Var Buffer: TRecBuf);
Begin
 FreeRecordBuffer(TRecordBuffer(Buffer));
End;
{$ENDIF}

procedure TRESTDWMemTable.InternalInitRecord(Buffer : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF});
var
  I: Integer;
begin
 {$IFDEF NEXTGEN}
  FillChar(PChar(Buffer), FBlobOfs, 0);
 {$ELSE}
  FillChar(Buffer^, FBlobOfs, 0);
 {$ENDIF}
 For I := 0 to BlobFieldCount - 1 do
  SetLength(PMemBlobArray(Buffer + FBlobOfs)^[I], 0);
end;

procedure TRESTDWMemTable.InitRecord(Buffer: {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF});
begin
  {$IFDEF NEXTGEN}
  inherited InitRecord({$IFDEF RTL250_UP}TRecBuf{$ENDIF}(Buffer));
  {$ELSE}
  // in non-NEXTGEN InitRecord(TRectBuf) calls InitRecord(TRecordBuffer) => endless recursion
    {$WARN SYMBOL_DEPRECATED OFF} // XE4
  inherited InitRecord({$IFDEF RTL250_UP}TRecordBuffer{$ENDIF}(Buffer));
    {$WARN SYMBOL_DEPRECATED ON}
  {$ENDIF NEXTGEN}
  with PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do
  begin
    BookmarkData := Low(Integer);
    BookmarkFlag := bfInserted;
  end;
end;

function TRESTDWMemTable.GetCurrentRecord(Buffer : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}): Boolean;
begin
  Result := False;
  if not IsEmpty and (GetBookmarkFlag(ActiveBuffer) = bfCurrent) then
  begin
    UpdateCursorPos;
    if (FRecordPos >= 0) and (FRecordPos < RecordCount) then
    begin
      Move(Records[FRecordPos].Data^, {$IFDEF NEXTGEN}PChar(Buffer)^{$ELSE}Buffer^{$ENDIF}, FRecordSize);
      Result := True;
    end;
  end;
end;

function TRESTDWMemTable.GetRecord(Buffer: {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
var
  Accept: Boolean;
begin
  Result := grOk;
  Accept := True;
  case GetMode of
    gmPrior:
      if FRecordPos <= 0 then
      begin
        Result := grBOF;
        If State In [dsBrowse] Then
         Begin
          If RecordCount > 0 Then
           FRecordPos := 0
          Else
           FRecordPos := -1;
         End
        Else
         FRecordPos := -1;
      end
      else
      begin
        repeat
          Dec(FRecordPos);
          if Filtered then
            Accept := RecordFilter;
        until Accept or (FRecordPos < 0);
        if not Accept then
        begin
          Result := grBOF;
          FRecordPos := -1;
        end;
      end;
    gmCurrent:
      if (FRecordPos < 0) or (FRecordPos >= RecordCount) then
        Result := grError
      else
      if Filtered then
        if not RecordFilter then
          Result := grError;
    gmNext:
      if FRecordPos >= RecordCount - 1 then
        Result := grEOF
      else
      begin
        repeat
          Inc(FRecordPos);
          if Filtered then
            Accept := RecordFilter;
        until Accept or (FRecordPos > RecordCount - 1);
        if not Accept then
        begin
          Result := grEOF;
          FRecordPos := RecordCount - 1;
        end;
      end;
  end;
  if Result = grOk then
    RecordToBuffer(Records[FRecordPos], {$IFDEF NEXTGEN}PJvMemBuffer(Buffer){$ELSE}Buffer{$ENDIF})
  else
  if (Result = grError) and DoCheck then
    Error(RsEMemNoRecords);
end;

procedure TRESTDWMemTable.GetBookmarkData(Buffer : {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}; Data: TJvBookmark);
begin
  Move(PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData, TJvBookmarkData({$IFDEF RTL240_UP}Pointer(@Data[0]){$ELSE}Data{$ENDIF RTL240_UP}^), SizeOf(TJvBookmarkData));
end;

procedure TRESTDWMemTable.SetBookmarkData(Buffer: {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}; Data: TJvBookmark);
begin
  Move({$IFDEF RTL240_UP}Pointer(@Data[0]){$ELSE}Data{$ENDIF RTL240_UP}^, PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData, SizeOf(TJvBookmarkData));
end;

function TRESTDWMemTable.GetBookmarkFlag(Buffer: {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}): TBookmarkFlag;
begin
  Result := PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag;
end;

procedure TRESTDWMemTable.SetBookmarkFlag(Buffer: {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF}; Value: TBookmarkFlag);
begin
  PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag := Value;
end;

procedure TRESTDWMemTable.InternalSetToRecord(Buffer: {$IFDEF NEXTGEN}TRecBuf{$ELSE}PJvMemBuffer{$ENDIF});
begin
  InternalGotoBookmarkData(PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData);
end;

procedure TRESTDWMemTable.InternalAddRecord(Buffer: {$IFDEF FPC}Pointer{$ELSE}{$IFDEF NEXTGEN}TRecBuf{$ELSE}{$IF CompilerVersion <= 22}Pointer{$ELSE}TRecordBuffer{$IFEND}{$ENDIF}{$ENDIF};
                                            aAppend: Boolean);
var
  RecPos: Integer;
  Rec: TJvMemoryRecord;
begin
  if aAppend then
  begin
    Rec := AddRecord;
    FRecordPos := FRecords.Count - 1;
  end
  else
  begin
    if FRecordPos = -1 then
      RecPos := 0
    else
      RecPos := FRecordPos;
    Rec := InsertRecord(RecPos);
    FRecordPos := RecPos;
  end;
  SetAutoIncFields({$IFDEF NEXTGEN}PJvMemBuffer(Buffer){$ELSE}Buffer{$ENDIF});
  SetMemoryRecordData({$IFDEF NEXTGEN}PJvMemBuffer(Buffer){$ELSE}Buffer{$ENDIF}, Rec.Index);
end;

procedure TRESTDWMemTable.RecordToBuffer(Rec: TJvMemoryRecord; Buffer: PJvMemBuffer);
var
  I: Integer;
begin
//  Buffer := Rec.Data;
  Move(Rec.Data^, Buffer^, FRecordSize);
  with PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do
  begin
    BookmarkData := Rec.ID;
    BookmarkFlag := bfCurrent;
  end;
//  for I := 0 to BlobFieldCount - 1 do
//   Begin
//    If PMemBlobArray(Rec.FBlobs)^[I] = '' Then
//     PMemBlobArray(Rec.FBlobs)^[I] := PMemBlobArray(Buffer)^[I];
//   End;
  GetCalcFields({$IFDEF RTL250_UP}TRecBuf{$ENDIF}(Buffer));
end;
function TRESTDWMemTable.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;
function TRESTDWMemTable.GetActiveRecBuf(var RecBuf: PJvMemBuffer): Boolean;
begin
  case State of
    dsBrowse:
      if IsEmpty then
        RecBuf := nil
      else
        RecBuf := PJvMemBuffer(ActiveBuffer);
    dsEdit, dsInsert:
      RecBuf := PJvMemBuffer(ActiveBuffer);
    dsCalcFields:
      RecBuf := PJvMemBuffer(CalcBuffer);
    dsFilter:
      RecBuf := PJvMemBuffer(TempBuffer);
    else
      RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;
function TRESTDWMemTable.InternalGetFieldData(Field: TField; Var Buffer: TJvValueBuffer): Boolean;
var
  RecBuf   : PJvMemBuffer;
  Data     : PByte;
  VarData  : Variant;
  aVarData : ^TMemBlobData;
  L        : Integer;
  aBytes   : TRESTDWBytes;
begin
  Result := False;
  if not GetActiveRecBuf(RecBuf) then
    Exit;
  if Field.FieldNo > 0 then
  begin
    Data := FindFieldData(RecBuf, Field);
    if (Data <> nil) Or (Field is TBlobField) then
    begin
     If Not (Field is TBlobField) then
      Result := Data^ <> 0;
//      If Not DataTypeIsBlobTypes(Field.DataType) Then
//      Inc(Data);
      case Field.DataType of
        ftGuid:
          Result := Result and(StrLen({$IFNDEF FPC}{$IF CompilerVersion <= 22}PAnsiChar(Data)
                                                   {$ELSE}PChar(Data){$IFEND}
                                      {$ELSE}PAnsiChar(Data){$ENDIF}) > 0);
        ftString, ftFixedChar:
          Result := Result and (not TrimEmptyString or (StrLen({$IFNDEF FPC}{$IF CompilerVersion <= 22}PAnsiChar(Data)
                                                                            {$ELSE}PChar(Data){$IFEND}
                                                               {$ELSE}PAnsiChar(Data){$ENDIF}) > 0));
        {$IF DEFINED(FPC) OR DEFINED(COMPILER10_UP)}
          ftWideString:
            Result := Result and (not TrimEmptyString or (StrLen({$IFNDEF FPC}{$IF CompilerVersion <= 22}PChar(Data)
                                                                              {$ELSE}PChar(Data){$IFEND}
                                                                              {$ELSE}PWideChar(Data){$ENDIF}) > 0));
          ftFixedWideChar:
            Result := Result and (not TrimEmptyString or (StrLen({$IFNDEF FPC}{$IF CompilerVersion <= 22}PChar(Data)
                                                                            {$ELSE}PChar(Data){$IFEND}
                                                                            {$ELSE}PWideChar(Data){$ENDIF}) > 0));
        {$IFEND}
      end;
      if Result then
        if Field.DataType = ftVariant then
        begin
          VarData := PVariant(Data)^;
          PVariant(Buffer)^ := VarData;
        end
       Else If DataTypeIsBlobTypes(Field.DataType) Then
        Begin
         //Novo Codigo
         If State in [dsBrowse] Then
          Begin
           aBytes := PMemBlobArray(Records[RecNo -1].Blobs)^[Field.Offset];
           SetLength(Buffer, Length(aBytes));
           Move(aBytes[0], Buffer[0], Length(aBytes));
          End
         Else
          SetLength(Buffer, 0);
        End
       Else
        Begin
         SetLength(Buffer, CalcFieldLen(Field.DataType, Field.Size));
         Move(Data^, Buffer[0], Length(Buffer));
        End;
    end;
  end
  else
  if State in [dsBrowse, dsEdit, dsInsert, dsCalcFields] then
  begin
   If Not DataTypeIsBlobTypes(Field.DataType) Then
    Begin
     Inc(RecBuf, FRecordSize + Field.Offset);
     Result := Byte(RecBuf[0]) <> 0;
     If Result Then
      Move(RecBuf[1], Buffer, Field.DataSize);
    End;
  end;
end;
function TRESTDWMemTable.GetFieldData(Field: TField; var Buffer: TJvValueBuffer): Boolean;
begin
 Result := InternalGetFieldData(Field, Buffer);
end;
{$IFNDEF NEXTGEN}
  {$IFDEF RTL240_UP}
function TRESTDWMemTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
Var
 aPointer : Pointer;
begin
 aPointer := @Buffer;
 Result := InternalGetFieldData(Field, TJvValueBuffer(aPointer^));
end;
  {$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}
procedure TRESTDWMemTable.InternalSetFieldData(Field: TField; Buffer: Pointer; const ValidateBuffer: TJvValueBuffer);
var
  RecBuf: PJvMemBuffer;
  Data: PByte;
  VarData: Variant;
begin
  if not (State in dsWriteModes) then
    Error('Not Editing...');
  GetActiveRecBuf(RecBuf);
  if Field.FieldNo > 0 then
  begin
    if State in [dsCalcFields, dsFilter] then
      Error('Not Editing...');
    if Field.ReadOnly and not (State in [dsSetKey, dsFilter]) then
      ErrorFmt('The Field %s is readonly...', [Field.DisplayName]);
    Field.Validate(ValidateBuffer); // The non-NEXTGEN Pointer version has "TArray<Byte> := Pointer" in it what interprets an untypes pointer as dyn. array. Not good.
    if Field.FieldKind <> fkInternalCalc then
    begin
      Data := FindFieldData(RecBuf, Field);
      if Data <> nil then
      begin
        if Field.DataType = ftVariant then
        begin
          if Buffer <> nil then
            VarData := PVariant(Buffer)^
          else
            VarData := EmptyParam;
          Data^ := Ord((Buffer <> nil) and not VarIsNullEmpty(VarData));
          if Data^ <> 0 then
          begin
            Inc(Data);
            PVariant(Data)^ := VarData;
          end
          else
            FillChar(Data^, CalcFieldLen(Field.DataType, Field.Size), 0);
        end
        else
        begin
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
  else {fkCalculated, fkLookup}
  begin
    Inc(RecBuf, FRecordSize + Field.Offset);
    Byte(RecBuf[0]) := Ord(Buffer <> nil);
    if Byte(RecBuf[0]) <> 0 then
      Move(Buffer^, RecBuf[1], Field.DataSize);
  end;
  if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
    DataEvent(deFieldChange, NativeInt(Field));
end;
procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: TJvValueBuffer);
begin
  InternalSetFieldData(Field, {$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
end;
{$IFNDEF NEXTGEN}
  {$IFDEF RTL240_UP}
procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: Pointer);
var
  ValidateBuffer: TJvValueBuffer;
begin
  if (Buffer <> nil) and (Field.FieldNo > 0) and (Field.DataSize > 0) then
  begin
    SetLength(ValidateBuffer, Field.DataSize);
    Move(Buffer^, ValidateBuffer[0], Field.DataSize);
  end
  else
    ValidateBuffer := nil;
  InternalSetFieldData(Field, Buffer, ValidateBuffer);
end;
  {$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}
procedure TRESTDWMemTable.SetFiltered(Value: Boolean);
begin
  if Active then
  begin
    CheckBrowseMode;
    if Filtered <> Value then
      inherited SetFiltered(Value);
    First;
  end
  else
    inherited SetFiltered(Value);
end;
procedure TRESTDWMemTable.SetOnFilterRecord(const Value: TFilterRecordEvent);
begin
  if Active then
  begin
    CheckBrowseMode;
    inherited SetOnFilterRecord(Value);
    if Filtered then
      First;
  end
  else
    inherited SetOnFilterRecord(Value);
end;
function TRESTDWMemTable.RecordFilter: Boolean;
var
  SaveState: TDataSetState;
begin
  Result := True;
  if Assigned(OnFilterRecord) or (FFilterParser <> nil){$IFNDEF FPC}or (FFilterExpression <> nil){$ENDIF} then
  begin
    if (FRecordPos >= 0) and (FRecordPos < RecordCount) then
    begin
      SaveState := SetTempState(dsFilter);
      try
        RecordToBuffer(Records[FRecordPos], PJvMemBuffer(TempBuffer));
        if (FFilterParser <> nil) and FFilterParser.Eval() then
        begin
          FFilterParser.EnableWildcardMatching := not (foNoPartialCompare in FilterOptions);
          FFilterParser.CaseInsensitive := foCaseInsensitive in FilterOptions;
          Result := FFilterParser.Value;
        end
        {$IFNDEF FPC}
        else
        if FFilterExpression <> nil then
          Result := FFilterExpression.Evaluate();
        {$ELSE}
        ;
        {$ENDIF}
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
function TRESTDWMemTable.GetBlobData(Field: TField; Buffer: PJvMemBuffer): TMemBlobData;
begin
  Result := PMemBlobArray(Buffer + FBlobOfs)^[Field.Offset];
end;
procedure TRESTDWMemTable.SetBlobData(Field: TField; Buffer: PJvMemBuffer; Value: TMemBlobData);
begin
  if Buffer = PJvMemBuffer(ActiveBuffer) then
  begin
    if State = dsFilter then
      Error('Not Editing...');
    PMemBlobArray(Buffer + FBlobOfs)^[Field.Offset] := Value;
  end;
end;
procedure TRESTDWMemTable.CloseBlob(Field: TField);
begin
  if (FRecordPos >= 0) and (FRecordPos < FRecords.Count) and (State = dsEdit) then
    PMemBlobArray(ActiveBuffer + FBlobOfs)^[Field.Offset] :=
      PMemBlobArray(Records[FRecordPos].FBlobs)^[Field.Offset]
  else
    SetLength(PMemBlobArray(ActiveBuffer + FBlobOfs)^[Field.Offset], 0);
end;
function TRESTDWMemTable.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TJvMemBlobStream.Create(Field as TBlobField, Mode);
end;
function TRESTDWMemTable.BookmarkValid(aBookmark: TBookmark): Boolean;
begin
  Result := (aBookmark <> nil) and FActive and
    (FindRecordID({$IFDEF FPC}NativeInt(@aBookmark[0]){$ELSE}TJvBookmarkData({$IFDEF RTL200_UP}Pointer(@aBookmark[0]){$ELSE}aBookmark{$ENDIF RTL200_UP}^){$ENDIF}) <> nil);
end;

function TRESTDWMemTable.CompareBookmarks(aBookmark1, aBookmark2: TBookmark): Integer;
begin
  if (aBookmark1 = nil) and (aBookmark2 = nil) then
    Result := 0
  else
  if (aBookmark1 <> nil) and (aBookmark2 = nil) then
    Result := 1
  else
  if (aBookmark1 = nil) and (aBookmark2 <> nil) then
    Result := -1
  else
  if TJvBookmarkData({$IFDEF FPC}NativeInt(@aBookmark1[0]){$ELSE}TJvBookmarkData({$IFDEF RTL200_UP}Pointer(@aBookmark1[0]){$ELSE}aBookmark1{$ENDIF RTL200_UP}^){$ENDIF}) >
     TJvBookmarkData({$IFDEF FPC}NativeInt(@aBookmark2[0]){$ELSE}TJvBookmarkData({$IFDEF RTL200_UP}Pointer(@aBookmark2[0]){$ELSE}aBookmark2{$ENDIF RTL200_UP}^){$ENDIF}) then
    Result := 1
  else
  if TJvBookmarkData({$IFDEF FPC}NativeInt(@aBookmark1[0]){$ELSE}TJvBookmarkData({$IFDEF RTL200_UP}Pointer(@aBookmark1[0]){$ELSE}aBookmark1{$ENDIF RTL200_UP}^){$ENDIF}) <
     TJvBookmarkData({$IFDEF FPC}NativeInt(@aBookmark2[0]){$ELSE}TJvBookmarkData({$IFDEF RTL200_UP}Pointer(@aBookmark2[0]){$ELSE}aBookmark2{$ENDIF RTL200_UP}^){$ENDIF}) then
    Result := -1
  else
    Result := 0;
end;

{$IFNDEF NEXTGEN}
 {$IFDEF RTL240_UP}
procedure TRESTDWMemTable.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
var
  Bookmark: TBookmark;
begin
  SetLength(Bookmark, SizeOf(TJvBookmarkData));
  GetBookmarkData(Buffer, Bookmark);
  Move(Bookmark[0], Data^, SizeOf(TJvBookmarkData));
end;
procedure TRESTDWMemTable.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  Move(Data^, PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData, SizeOf(TJvBookmarkData));
end;
  {$ENDIF RTL240_UP}
{$ENDIF !NEXTGEN}

procedure TRESTDWMemTable.InternalGotoBookmarkData(BookmarkData: TJvBookmarkData);
var
  Rec: TJvMemoryRecord;
  SavePos: Integer;
  Accept: Boolean;
begin
  Rec := FindRecordID(BookmarkData);
  if Rec <> nil then
  begin
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
procedure TRESTDWMemTable.InternalGotoBookmark(aBookmark: TJvBookmark);
begin
  InternalGotoBookmarkData(TJvBookmarkData({$IFDEF RTL240_UP}Pointer(@aBookmark[0]){$ELSE}aBookmark{$ENDIF RTL240_UP}^));
end;
{$IFNDEF NEXTGEN}
  {$IFDEF RTL240_UP}
procedure TRESTDWMemTable.InternalGotoBookmark(Bookmark: Pointer);
begin
  InternalGotoBookmarkData(TJvBookmarkData(Bookmark^));
end;
  {$ENDIF RTL240_UP}
{$ENDIF !NEXTGEN}

procedure TRESTDWMemTable.InternalFirst;
begin
  FRecordPos := -1;
end;

procedure TRESTDWMemTable.InternalLast;
begin
  FRecordPos := FRecords.Count;
end;

function TRESTDWMemTable.GetDataset : TDataSet;
begin
  Result := TDataSet(Self);
end;

function TRESTDWMemTable.GetCalcFieldLen(FieldType: TFieldType;
  Size: Word): Word;
begin
  Result := CalcFieldLen(FieldType, Size);
end;

function TRESTDWMemTable.GetBlobRec(Field: TField; Rec : TJvMemoryRecord) : TMemBlobData;
begin
  Result := PMemBlobArray(Rec.FBlobs)^[Field.Offset];
end;

function TRESTDWMemTable.GetOffSets(index : integer) : Word;
begin
  Result := FOffsets[index];
end;

function TRESTDWMemTable.GetOffSetsBlobs : Word;
begin
  Result := FBlobOfs;
end;

function TRESTDWMemTable.DataTypeIsBlobTypes(datatype : TFieldType) : boolean;
begin
  Result := datatype in ftBlobTypes;
end;

function TRESTDWMemTable.DataTypeSuported(datatype: TFieldType): boolean;
begin
  Result := datatype in ftSupported;
end;

{$IFNDEF FPC}
  {$IFNDEF COMPILER10_UP} // Delphi 2006+ has support for DWWideString
  procedure TRESTDWMemTable.DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean);
  begin
    if Field.DataType = ftWideString then
    begin
      if ToNative then
      begin
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
{$ELSE}
  procedure TRESTDWMemTable.DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean);
  begin
    if Field.DataType = ftFixedWideChar then begin
      StrCopy(PWideChar(Dest), PWideChar(Source));
    end
    else
      inherited DataConvert(Field, Source, Dest, ToNative);
  end;
{$ENDIF}


procedure TRESTDWMemTable.Assign(Source: TPersistent);
begin
  if Source is TDataSet then
    LoadFromDataSet(TDataSet(Source), -1, lmCopy)
  else
    inherited Assign(Source);
end;

procedure TRESTDWMemTable.AssignMemoryRecord(Rec: TJvMemoryRecord; Buffer: PJvMemBuffer);
var
  I: Integer;
begin
 Move(Buffer^, Rec.Data^, FRecordSize);
 For I := 0 to BlobFieldCount - 1 do
  PMemBlobArray(Rec.FBlobs)^[I] := PMemBlobArray(Buffer + FBlobOfs)^[I];
end;
procedure TRESTDWMemTable.SetMemoryRecordData(Buffer: PJvMemBuffer; Pos: Integer);
var
  Rec: TJvMemoryRecord;
begin
  if State = dsFilter then
    Error('Not Editing...');
  Rec := Records[Pos];
  AssignMemoryRecord(Rec, Buffer);
end;
procedure TRESTDWMemTable.SetAutoIncFields(Buffer: PJvMemBuffer);
var
  I, Count: Integer;
  Data: PByte;
begin
  Count := 0;
  for I := 0 to FieldCount - 1 do
    if (Fields[I].FieldKind in fkStoredFields) and
      (Fields[I].DataType = ftAutoInc) then
    begin
      Data := FindFieldData(Buffer, Fields[I]);
      if Data <> nil then
      begin
        Data^ := Ord(True);
        Inc(Data);
        Move(FAutoInc, Data^, SizeOf(Longint));
        Inc(Count);
      end;
    end;
  if Count > 0 then
    Inc(FAutoInc);
end;
procedure TRESTDWMemTable.InternalDelete;
var
  Accept: Boolean;
  Status: TRecordStatus;
  PFValues: TPVariant;
begin
  Status := rsOriginal; // Disable warnings
  PFValues := nil;
  if FApplyMode <> amNone then
  begin
    Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
    if Status <> rsInserted then
    begin
      if FApplyMode = amAppend then
      begin
        Cancel;
        Exit;
      end
      else
      begin
        New(PFValues);
        PFValues^ := GetValues;
      end;
    end;
  end;
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
  if FApplyMode <> amNone then
  begin
    if Status = rsInserted then
      Dec(FRowsChanged)
    else
      FDeletedValues.Add(PFValues);
    if Status = rsOriginal then
      Inc(FRowsChanged);
  end;
end;
procedure TRESTDWMemTable.InternalPost;
var
  RecPos: Integer;
  Index: Integer;
  Status: TRecordStatus;
  NewChange: Boolean;
begin
  inherited InternalPost;
  NewChange := False;
  if (FApplyMode <> amNone) and not IsLoading then
  begin
    Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
    (* if (State = dsEdit) and (Status In [rsInserted,rsUpdated]) then NewChange := False; *)
    if (State = dsEdit) and (Status = rsOriginal) then
    begin
      if FApplyMode = amAppend then
      begin
        Cancel;
        Exit;
      end
      else
      begin
        NewChange := True;
        FieldByName(FStatusName).AsInteger := Integer(rsUpdated);
      end;
    end;
    if State = dsInsert then
    begin
      if IsDeleted(Index) then
      begin
        FDeletedValues[Index] := nil;
        FDeletedValues.Delete(Index);
        if FApplyMode = amAppend then
          FieldByName(FStatusName).AsInteger := Integer(rsInserted)
        else
          FieldByName(FStatusName).AsInteger := Integer(rsUpdated);
      end
      else
      begin
        NewChange := True;
        FieldByName(FStatusName).AsInteger := Integer(rsInserted);
      end;
    end;
  end;
  if State = dsEdit then
    SetMemoryRecordData(PJvMemBuffer(ActiveBuffer), FRecordPos)
  else
  begin
    if State in [dsInsert] then
      SetAutoIncFields(PJvMemBuffer(ActiveBuffer));
    if FRecordPos >= FRecords.Count then
    begin
      AddRecord;
      FRecordPos := FRecords.Count - 1;
      SetMemoryRecordData(PJvMemBuffer(ActiveBuffer), FRecordPos);
    end
    else
    begin
      if FRecordPos = -1 then
        RecPos := 0
      else
        RecPos := FRecordPos;
      SetMemoryRecordData(PJvMemBuffer(ActiveBuffer), InsertRecord(RecPos).Index);
      FRecordPos := RecPos;
    end;
  end;
  if NewChange then
    Inc(FRowsChanged);
end;
procedure TRESTDWMemTable.OpenCursor(InfoQuery: Boolean);
begin
  try
    if FDataSet <> nil then
    begin
      if FLoadStructure then
        CopyStructure(FDataSet, FAutoIncAsInteger)
      else
      if FApplyMode <> amNone then
      begin
        AddStatusField;
        HideStatusField;
      end;
    end;
  except
    SysUtils.Abort;
    Exit;
  end;
  if not InfoQuery then
  begin
    if FieldCount > 0 then
      FieldDefs.Clear;
    InitFieldDefsFromFields;
  end;
  FActive := True;
  inherited OpenCursor(InfoQuery);
end;
procedure TRESTDWMemTable.InternalOpen;
begin
  BookmarkSize := SizeOf(TJvBookmarkData);
  FieldDefs.Updated := False;
  FieldDefs.Update;
  {$IFNDEF FPC}
  FieldDefList.Update;
  {$ENDIF}
  {$IFNDEF HAS_AUTOMATIC_DB_FIELDS}
  if DefaultFields then
  {$ENDIF !HAS_AUTOMATIC_DB_FIELDS}
    CreateFields;
  BindFields(True);
  InitBufferPointers(True);
  InternalFirst;
end;
procedure TRESTDWMemTable.DoAfterOpen;
begin
  if (FDataSet <> nil) and FLoadRecords then
  begin
    if not FDataSet.Active then
      FDataSet.Open;
    FRowsOriginal := CopyFromDataset;
    if FRowsOriginal > 0 then
    begin
      SortOnFields();
      if FApplyMode = amAppend then
        Last
      else
        First;
    end;
    if FDataset.Active and FDatasetClosed then
      FDataset.Close;
  end
  else
  if not IsEmpty then
    SortOnFields();
  inherited DoAfterOpen;
End;

procedure TRESTDWMemTable.SetFilterText(const Value: string);
  procedure UpdateFilter;
  begin
    FreeAndNil(FFilterParser);
    {$IFNDEF FPC}
    FreeAndNil(FFilterExpression);
    {$ENDIF}
    if Filter <> '' then
    begin
     {$IFNDEF FPC}
      if UseDataSetFilter then
        FFilterExpression := TJvDBFilterExpression.Create(Self, Value, FilterOptions)
      else
      begin
        {$ENDIF}
        FFilterParser := TExprParser.Create;
        {$IFNDEF FPC}
         FFilterParser.OnGetVariable := ParserGetVariableValue;
        {$ELSE}
         FFilterParser.OnGetVariable := @ParserGetVariableValue;
        {$ENDIF}
        if foCaseInsensitive in FilterOptions then
          FFilterParser.Expression := AnsiUpperCase(Filter)
        else
          FFilterParser.Expression := Filter;
      {$IFNDEF FPC}
      end;
     {$ENDIF}
    end;
  end;
begin
  if Active then
  begin
    CheckBrowseMode;
    inherited SetFilterText(Value);
    UpdateFilter;
    if Filtered then
      First;
  end
  else
  begin
    inherited SetFilterText(Value);
    UpdateFilter;
  end;
end;

function TRESTDWMemTable.ParserGetVariableValue(Sender: TObject; const VarName: string; var Value: Variant): Boolean;
var
  Field: TField;
begin
  Field := FieldByName(Varname);
  if Assigned(Field) then
  begin
    Value := Field.Value;
    Result := True;
  end
  else
    Result := False;
end;
procedure TRESTDWMemTable.InternalClose;
// Procedure CleanAll;
// Begin
//  Try
//   ClearChanges;
//   If Assigned(FRecords) Then
//    FreeAndNil(FRecords);
//   FRecords := TList.Create;
//   If Assigned(FDeletedValues) Then
//    FreeAndNil(FDeletedValues);
//   FDeletedValues := TList.Create;
//  Finally
//   ClearRecords;
//   ClearBuffers;
//   FRecordPos := -1;
//   FLastID := Low(Integer);
//   FAutoInc := 1;
//   FStatusName := STATUSNAME;
//   FRowsOriginal := 0;
//   FRowsChanged := 0;
//   FRowsAffected := 0;
//   FSaveLoadState := slsNone;
//   FOneValueInArray := True;
//   FDataSetClosed := False;
//   FRowsChanged := 0;
//   FRowsAffected := 0;
//   if Assigned(FRESTDWStorage) then
//    FreeAndNil(FRESTDWStorage);
//   FActive := False;
//  End;
// End;
Begin
 ClearBuffer;
 FAutoInc := 1;
 BindFields(False);
 If DefaultFields then
  DestroyFields;
 FreeIndexList;
 FActive := False;
End;

procedure TRESTDWMemTable.InternalHandleException;
begin
  AppHandleException(Self);
end;
procedure TRESTDWMemTable.InternalInitFieldDefs;
begin
  // InitFieldDefsFromFields
end;
function TRESTDWMemTable.IsCursorOpen: Boolean;
begin
  Result := FActive;
end;
function TRESTDWMemTable.GetRecordCount: Integer;
begin
  Result := FRecords.Count;
end;
function TRESTDWMemTable.GetRecNo: Integer;
begin
  CheckActive;
  UpdateCursorPos;
  if (FRecordPos = -1) and (RecordCount > 0) then
    Result := 1
  else
    Result := FRecordPos + 1;
end;
procedure TRESTDWMemTable.SetRecNo(Value: Integer);
begin
  if (Value > 0) and (Value <= FRecords.Count) then
  begin
    DoBeforeScroll;
    FRecordPos := Value - 1;
    Resync([]);
    DoAfterScroll;
  end;
end;
procedure TRESTDWMemTable.SetUseDataSetFilter(const Value: Boolean);
begin
  if Value <> FUseDataSetFilter then
  begin
    FUseDataSetFilter := Value;
    SetFilterText(Filter); // update the filter engine
  end;
end;
function TRESTDWMemTable.IsSequenced: Boolean;
begin
  Result := not Filtered;
end;
function TRESTDWMemTable.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll;
  Result := DataSetLocateThrough(Self, KeyFields, KeyValues, Options);
  if Result then
  begin
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
  end;
end;
function TRESTDWMemTable.Lookup(const KeyFields: string; const KeyValues: Variant;
  const ResultFields: string): Variant;
var
  {$IFNDEF FPC}
   FieldCount: Integer;
   aFields   : TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
  {$ELSE}
   aFields   : TFields;
  {$ENDIF}
  Fld: TField; //else BAD mem leak on 'Field.asString'
  SaveState: TDataSetState;
  I: Integer;
  Matched: Boolean;
  function CompareField(var Field: TField; Value: Variant): Boolean; {BG}
  var
    S: string;
  begin
    if Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString, ftFixedWideChar{$ENDIF}] then
    begin
      if Value = Null then
        Result := Field.IsNull
      else
      begin
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
    if FieldCount = 1 then
    begin
      Fld := TField(Fields[0]);
      Result := CompareField(Fld, KeyValues);
    end
    else
    begin
      Result := True;
      for I := 0 to FieldCount - 1 do
      begin
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
  {$IFNDEF FPC}
   aFields := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
  {$ELSE}
   aFields := TFields.Create(Nil);
  {$ENDIF}
  try
    GetFieldList(TList(aFields), KeyFields);
    {$IFNDEF FPC}
     aFields := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
    {$ELSE}
     aFields := TFields.Create(Nil);
    {$ENDIF}
    Matched := CompareRecord;
    if Matched then
      Result := FieldValues[ResultFields]
    else
    begin
      SaveState := SetTempState(dsCalcFields);
      try
        try
          for I := 0 to RecordCount - 1 do
          begin
            RecordToBuffer(Records[I], PJvMemBuffer(TempBuffer));
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
procedure TRESTDWMemTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TRESTDWMemTable.EmptyTable;
begin
 If Active then
  Begin
   CheckBrowseMode;
   ClearRecords;
   ClearBuffers;
   DataEvent(deDataSetChange, 0);
  End;
end;

procedure TRESTDWMemTable.AddStatusField;
begin
  // Check if FieldStatus not exists in FieldDefs
  if (FieldDefs.Count > 0) and not (FieldDefs[FieldDefs.Count - 1].Name =
    FStatusName) then
    FieldDefs.Add(FStatusName, ftSmallint);
end;
procedure TRESTDWMemTable.HideStatusField;
begin
  // Check if FieldStatus already exists in FieldDefs
  if (FieldDefs.Count > 0) and (FieldDefs[FieldDefs.Count - 1].Name = FStatusName) then
  begin
    FieldDefs[FieldDefs.Count - 1].Attributes := [faHiddenCol]; // Hide in FieldDefs
    // Check if FieldStatus not exists in Fields
    if not (Fields[Fields.Count - 1].FieldName = FStatusName) then
      FieldDefs[FieldDefs.Count - 1].CreateField(Self);
    Fields[Fields.Count - 1].Visible := False; // Hide in Fields
  end;
end;
procedure TRESTDWMemTable.CheckStructure(UseAutoIncAsInteger: Boolean);
  procedure CheckDataTypes(FieldDefs: TFieldDefs);
  var
    J: Integer;
  begin
    for J := FieldDefs.Count - 1 downto 0 do
    begin
      if (FieldDefs.Items[J].DataType = ftAutoInc) and UseAutoIncAsInteger then
        FieldDefs.Items[J].DataType := ftInteger;
      if not (FieldDefs.Items[J].DataType in ftSupported) then
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

Procedure TRESTDWMemTable.ClearBuffer;
Begin
 ClearRecords;
 ClearBuffers;
 DataEvent(deDataSetChange, 0);
End;

procedure TRESTDWMemTable.FixReadOnlyFields(MakeReadOnly: Boolean);
var
  I: Integer;
begin
  if MakeReadOnly then
    for I := 0 to FieldCount - 1 do
      Fields[I].ReadOnly := (Fields[I].Tag = 1)
  else
    for I := 0 to FieldCount - 1 do
    begin
      Fields[I].Tag := Ord(Fields[I].ReadOnly);
      Fields[I].ReadOnly := False;
    end;
end;
procedure TRESTDWMemTable.CopyStructure(Source: TDataSet; UseAutoIncAsInteger: Boolean);
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
  if FApplyMode <> amNone then
    AddStatusField;
  CheckStructure(UseAutoIncAsInteger);
  if FApplyMode <> amNone then
    HideStatusField;
end;
function TRESTDWMemTable.LoadFromDataSet(Source: TDataSet; aRecordCount: Integer;
  Mode: TLoadMode; DisableAllControls: Boolean = True): Integer;
var
  MovedCount, I, FinalAutoInc: Integer;
  SB, DB: TBookmark;
begin
  Result := 0;
  if Source = Self then
    Exit;
  FSaveLoadState := slsLoading;
  //********** Source *********
  if DisableAllControls then
    Source.DisableControls;
  if not Source.Active then
    Source.Open
  else
    Source.CheckBrowseMode;
  Source.UpdateCursorPos;
  SB := Source.GetBookmark;
  //***************************
  try
    //********** Dest (self) ***********
    if DisableAllControls then
      DisableControls;
    Filtered := False;
    if Mode = lmCopy then
    begin
      Close;
      CopyStructure(Source, FAutoIncAsInteger);
    end;
    FreeIndexList;
    if not Active then
      Open
    else
      CheckBrowseMode;
    DB := GetBookmark;
    //**********************************
    try
      if aRecordCount > 0 then
        MovedCount := aRecordCount
      else
      begin
        Source.First;
        MovedCount := MaxInt;
      end;
      FinalAutoInc := 0;
      FixReadOnlyFields(False);
      // find first source autoinc field
      FSrcAutoIncField := nil;
      if Mode = lmCopy then
        for I := 0 to Source.FieldCount - 1 do
          if Source.Fields[I].DataType = ftAutoInc then
          begin
            FSrcAutoIncField := Source.Fields[I];
            Break;
          end;
      try
        while not Source.EOF do
        begin
          Append;
          AssignRecord(Source, Self, True);
          // assign AutoInc value manually (make user keep largest if source isn't sorted by autoinc field)
          if FSrcAutoIncField <> nil then
          begin
            FinalAutoInc := Max(FinalAutoInc, FSrcAutoIncField.AsInteger);
            FAutoInc := FSrcAutoIncField.AsInteger;
          end;
          if (Mode = lmCopy) and (FApplyMode <> amNone) then
            FieldByName(FStatusName).AsInteger := Integer(rsOriginal);
          Post;
          Inc(Result);
          if Result >= MovedCount then
            Break;
          Source.Next;
        end;
      finally
        if (Mode = lmCopy) and (FApplyMode <> amNone) then
        begin
          FRowsOriginal := Result;
          FRowsChanged := 0;
          FRowsAffected := 0;
        end;
        FixReadOnlyFields(True);
        if Mode = lmCopy then
          FAutoInc := FinalAutoInc + 1;
        FSrcAutoIncField := nil;
        First;
      end;
    finally
      //********** Dest (self) ***********
      // move back to where we started from
      if (DB <> nil) and BookmarkValid(DB) then
      begin
        GotoBookmark(DB);
        FreeBookmark(DB);
      end;
      if DisableAllControls then
        EnableControls;
      //**********************************
    end;
  finally
    //************** Source **************
    // move back to where we started from
    if (SB <> nil) and Source.BookmarkValid(SB) and not Source.IsEmpty then
    begin
      Source.GotoBookmark(SB);
      Source.FreeBookmark(SB);
    end;
    if Source.Active and FDatasetClosed then
      Source.Close;
    if DisableAllControls then
      Source.EnableControls;
    //************************************
    FSaveLoadState := slsNone;
  end;
end;
procedure TRESTDWMemTable.LoadFromStream(Stream: TStream);
var
  stor : TRESTDWStorageBinRDW;
begin
  if FRESTDWStorage = nil then begin 
    stor := TRESTDWStorageBinRDW.Create(nil);
    try
      stor.LoadFromStream(Self, Stream);
    finally
      stor.Free;
    end;
  end
  else begin
    FRESTDWStorage.LoadFromStream(Self, Stream);
  end;
end;

function TRESTDWMemTable.SaveToDataSet(Dest: TDataSet; aRecordCount: Integer;
  DisableAllControls: Boolean = True): Integer;
var
  MovedCount: Integer;
  SB, DB: TBookmark;
  Status: TRecordStatus;
begin
  Result := 0;
  FRowsAffected := Result;
  if Dest = Self then
    Exit;
  FSaveLoadState := slsSaving;
  //*********** Dest ************
  if DisableAllControls then
    Dest.DisableControls;
  if not Dest.Active then
    Dest.Open
  else
    Dest.CheckBrowseMode;
  Dest.UpdateCursorPos;
  DB := Dest.GetBookmark;
  SB := nil;
  //*****************************
  try
    //*********** Source (self) ************
    if DisableAllControls then
      DisableControls;
    CheckBrowseMode;
    if FApplyMode <> amNone then
    begin
      FRowsChanged := Self.RecordCount;
      DoBeforeApply(Dest, FRowsChanged);
    end
    else
    begin
      SB := GetBookmark;
    end;
    //**************************************
    try
      if aRecordCount > 0 then
        MovedCount := aRecordCount
      else
      begin
        First;
        MovedCount := MaxInt;
      end;
      Status := rsOriginal; // Disable warnings
      try
        while not EOF do
        begin
          if FApplyMode <> amNone then
          begin
            Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
            DoBeforeApplyRecord(Dest, Status, True);
          end;
          Dest.Append;
          AssignRecord(Self, Dest, True);
          Dest.Post;
          Inc(Result);
          if FApplyMode <> amNone then
            DoAfterApplyRecord(Dest, Status, True);
          if Result >= MovedCount then
            Break;
          Next;
        end;
      finally
        if FApplyMode <> amNone then
        begin
          FRowsAffected := Result;
          DoAfterApply(Dest, FRowsAffected);
          if Result > 0 then
            ClearChanges;
          FRowsAffected := 0;
          FRowsChanged := 0;
        end
      end;
    finally
      //*********** Source (self) ************
      if (FApplyMode = amNone) and (SB <> nil) and BookmarkValid(SB) then
      begin
        GotoBookmark(SB);
        FreeBookmark(SB);
      end;
      if DisableAllControls then
        EnableControls;
      //**************************************
    end;
  finally
    //******************* Dest *******************
    // move back to where we started from
    if (DB <> nil) and Dest.BookmarkValid(DB) and not Dest.IsEmpty then
    begin
      Dest.GotoBookmark(DB);
      Dest.FreeBookmark(DB);
    end;
    if Dest.Active and FDatasetClosed then
      Dest.Close;
    if DisableAllControls then
      Dest.EnableControls;
    //********************************************
    FSaveLoadState := slsNone;
  end;
end;

procedure TRESTDWMemTable.SaveToStream(var Stream: TStream);
var
  stor : TRESTDWStorageBinRDW;
begin
  if FRESTDWStorage = nil then begin  
    stor := TRESTDWStorageBinRDW.Create(nil);
    try
      stor.SaveToStream(TDataset(Self), Stream);
    finally
      stor.Free;
    end;
  end
  else begin
    FRESTDWStorage.SaveToStream(TDataset(Self), Stream);
  end;
end;

procedure TRESTDWMemTable.SortOnFields(const FieldNames: string = '';
  CaseInsensitive: Boolean = True; Descending: Boolean = False);
begin
  // Post the table before sorting
  if State in dsEditModes then
    Post;
  if FieldNames <> '' then
    CreateIndexList(FieldNames)
  else
  if FKeyFieldNames <> '' then
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

procedure TRESTDWMemTable.SwapRecords(Idx1, Idx2: integer);
begin
  FRecords.Exchange(Idx1, Idx2);
end;

procedure TRESTDWMemTable.Sort;
var
  Pos: {$IFDEF FPC}TBookmark
       {$ELSE}
       {$IFDEF COMPILER12_UP}DB.TBookmark{$ELSE}TBookmarkStr{$ENDIF COMPILER12_UP}
       {$ENDIF};
begin
  if Active and (FRecords <> nil) and (FRecords.Count > 0) then
  begin
    Pos := Bookmark;
    try
      {$IFDEF FPC}
      QuickSort(0, FRecords.Count - 1, @CompareRecords);
      {$ELSE}
      QuickSort(0, FRecords.Count - 1, CompareRecords);
      {$ENDIF}
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
procedure TRESTDWMemTable.QuickSort(L, R: Integer; Compare: TCompareRecords);
var
  I, J: Integer;
  P: TJvMemoryRecord;
begin
  repeat
    I := L;
    J := R;
    P := Records[(L + R) shr 1];
    repeat
      while Compare(Records[I], P) < 0 do
        Inc(I);
      while Compare(Records[J], P) > 0 do
        Dec(J);
      if I <= J then
      begin
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
function TRESTDWMemTable.CompareRecords(Item1, Item2: TJvMemoryRecord): Integer;
var
  Data1, Data2: PByte;
  CData1, CData2, Buffer1, Buffer2: array[0..dsMaxStringSize] of Byte;
  F: TField;
  I: Integer;
begin
  Result := 0;
  if FIndexList <> nil then
  begin
    for I := 0 to FIndexList.Count - 1 do
    begin
      F := TField(FIndexList[I]);
      if F.FieldKind = fkData then
      begin
        Data1 := FindFieldData(Item1.Data, F);
        if Data1 <> nil then
        begin
          Data2 := FindFieldData(Item2.Data, F);
          if Data2 <> nil then
          begin
            if Boolean(Data1^) and Boolean(Data2^) then
            begin
              Inc(Data1);
              Inc(Data2);
              Result := CompareFields(Data1, Data2, F.DataType, FCaseInsensitiveSort);
            end
            else if Boolean(Data1^) then
              Result := 1
            else if Boolean(Data2^) then
              Result := -1;
            if FDescendingSort then
              Result := -Result;
          end;
        end;
        if Result <> 0 then
          Exit;
      end
      else
      begin
        FillChar(Buffer1, dsMaxStringSize, 0);
        FillChar(Buffer2, dsMaxStringSize, 0);
        RecordToBuffer(Item1, @Buffer1[0]);
        RecordToBuffer(Item2, @Buffer2[0]);
        Move(Buffer1[1 + FRecordSize + F.Offset], CData1, F.DataSize);
        if CData1[0] <> 0 then
        begin
          Move(Buffer2[1 + FRecordSize + F.Offset], CData2, F.DataSize);
          if CData2[0] <> 0 then
          begin
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
  if Result = 0 then
  begin
    if Item1.ID > Item2.ID then
      Result := 1
    else
    if Item1.ID < Item2.ID then
      Result := -1;
    if FDescendingSort then
      Result := -Result;
  end;
end;
function TRESTDWMemTable.GetIsIndexField(Field: TField): Boolean;
begin
  if FIndexList <> nil then
    Result := FIndexList.IndexOf(Field) >= 0
  else
    Result := False;
end;
procedure TRESTDWMemTable.CreateIndexList(const FieldNames: DWWideString);
type
  TFieldTypeSet = set of TFieldType;
  function GetSetFieldNames(const FieldTypeSet: TFieldTypeSet): string;
  var
    FieldType: TFieldType;
  begin
    for FieldType := Low(TFieldType) to High(TFieldType) do
      if FieldType in FieldTypeSet then
        Result := Result + FieldTypeNames[FieldType] + ', ';
    Result := Copy(Result, 1, Length(Result) - 2);
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
  while Pos <= Length(FieldNames) do
  begin
    F := FieldByName(ExtractFieldNameEx(FieldNames, Pos));
    if {(F.FieldKind = fkData) and }(F.DataType in ftSupported - ftBlobTypes) then
      FIndexList.Add(F)
    else
      ErrorFmt('Type mismatch for field %s, expecting: %s actual %s', [F.DisplayName, GetSetFieldNames(ftSupported - ftBlobTypes),
        FieldTypeNames[F.DataType]]);
  end;
end;

Procedure TRESTDWMemTable.FreeIndexList;
Begin
 If Assigned(FIndexList) Then
  FreeANdNil(FIndexList);
End;

function TRESTDWMemTable.GetValues(FldNames: string = ''): Variant;
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
  if Pos(';', FldNames) > 0 then
  begin
    List := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
    GetFieldList(List, FldNames);
    Result := VarArrayCreate([0, List.Count - 1], varVariant);
    for I := 0 to List.Count - 1 do
      Result[I] := TField(List[I]).Value;
    FreeAndNil(List);
  end
  else
  if FOneValueInArray then
  begin
    Result := VarArrayCreate([0, 0], VarVariant);
    Result[0] := FieldByName(FldNames).Value;
  end
  else
    Result := FieldByName(FldNames).Value;
end;
function TRESTDWMemTable.CopyFromDataSet: Integer;
var
  I, Len, FinalAutoInc: Integer;
  Original, StatusField: TField;
  OriginalFields: array of TField;
  FieldReadOnly: Boolean;
begin
  Result := 0;
  if FDataSet = nil then
    Exit;
  if FApplyMode <> amNone then
    Len := FieldDefs.Count - 1
  else
    Len := FieldDefs.Count;
  if Len < 2 then
    Exit;
  try
    if not FDataSet.Active then
      FDataSet.Open;
  except
    Exit;
  end;
  if FDataSet.IsEmpty then
  begin
    if FDataSet.Active and FDatasetClosed then
      FDataSet.Close;
    Exit;
  end;
  FinalAutoInc := 0;
  FDataSet.DisableControls;
  DisableControls;
  FSaveLoadState := slsLoading;
  try
    SetLength(OriginalFields, Fields.Count);
    for I := 0 to Fields.Count - 1 do
    begin
      if Fields[I].FieldKind <> fkCalculated then
        OriginalFields[I] := FDataSet.FindField(Fields[I].FieldName);
    end;
    StatusField := nil;
    if FApplyMode <> amNone then
      StatusField := FieldByName(FStatusName);
    // find first source autoinc field
    FSrcAutoIncField := nil;
    for I := 0 to FDataSet.FieldCount - 1 do
      if FDataSet.Fields[I].DataType = ftAutoInc then
      begin
        FSrcAutoIncField := FDataSet.Fields[I];
        Break;
      end;
    FDataSet.First;
    while not FDataSet.EOF do
    begin
      Append;
      for I := 0 to Fields.Count - 1 do
      begin
        if Fields[I].FieldKind <> fkCalculated then
        begin
          Original := OriginalFields[I];
          if Original <> nil then
          begin
            FieldReadOnly := Fields[I].ReadOnly;
            if FieldReadOnly then
              Fields[I].ReadOnly := False;
            try
              CopyFieldValue(Fields[I], Original);
            finally
              if FieldReadOnly then
                Fields[I].ReadOnly := True;
            end;
          end;
        end;
      end;
      // assign AutoInc value manually (make user keep largest if source isn't sorted by autoinc field)
      if FSrcAutoIncField <> nil then
      begin
        FinalAutoInc := Max(FinalAutoInc, FSrcAutoIncField.AsInteger);
        FAutoInc := FSrcAutoIncField.AsInteger;
      end;
      if FApplyMode <> amNone then
        StatusField.AsInteger := Integer(rsOriginal);
      Post;
      Inc(Result);
      FDataSet.Next;
    end;
    FRowsChanged := 0;
    FRowsAffected := 0;
  finally
    FAutoInc := FinalAutoInc + 1;
    FSaveLoadState := slsNone;
    EnableControls;
    FDataSet.EnableControls;
    if FDataSet.Active and FDatasetClosed then
      FDataSet.Close;
  end;
end;
procedure TRESTDWMemTable.DoBeforeApply(ADataSet: TDataset; RowsPending: Integer);
begin
  if Assigned(FBeforeApply) then
    FBeforeApply(ADataset, RowsPending);
end;
procedure TRESTDWMemTable.DoAfterApply(ADataSet: TDataset; RowsApplied: Integer);
begin
  if Assigned(FAfterApply) then
    FAfterApply(ADataset, RowsApplied);
end;
procedure TRESTDWMemTable.DoBeforeApplyRecord(ADataset: TDataset;
  RS: TRecordStatus; aFound: Boolean);
begin
  if Assigned(FBeforeApplyRecord) then
    FBeforeApplyRecord(ADataset, RS, Found);
end;
procedure TRESTDWMemTable.DoAfterApplyRecord(ADataset: TDataset;
  RS: TRecordStatus; aApply: Boolean);
begin
  if Assigned(FAfterApplyRecord) then
    FAfterApplyRecord(ADataset, RS, aApply);
end;
procedure TRESTDWMemTable.ClearChanges;
var
  I: Integer;
  PFValues: TPVariant;
begin
  if FDeletedValues.Count > 0 then
  begin
    for I := 0 to (FDeletedValues.Count - 1) do
    begin
      PFValues := FDeletedValues[I];
      if PFValues <> nil then
        Dispose(PFValues);
      FDeletedValues[I] := nil;
    end;
    FDeletedValues.Clear;
  end;
  EmptyTable;
  if FLoadRecords then
  begin
    FRowsOriginal := CopyFromDataSet;
    if FRowsOriginal > 0 then
    begin
      if FKeyFieldNames <> '' then
        SortOnFields();
      if FApplyMode = amAppend then
        Last
      else
        First;
    end;
  end;
end;
procedure TRESTDWMemTable.CancelChanges;
begin
  CheckBrowseMode;
  ClearChanges;
  FRowsChanged := 0;
  FRowsAffected := 0;
end;
function TRESTDWMemTable.ApplyChanges: Boolean;
var
  xKey: Variant;
  PxKey: TPVariant;
  Len, Row: Integer;
  Status: TRecordStatus;
  bFound, bApply: Boolean;
  FOriginal, FClient: TField;
  function WriteFields: Boolean;
  var
    J: Integer;
  begin
    try
      for J := 0 to Len do
      begin
        if (Fields[J].FieldKind = fkData) then
        begin
          FClient := Fields[J];
          FOriginal := FDataSet.FindField(FClient.FieldName);
          if (FOriginal <> nil) and (FClient <> nil) and not FClient.ReadOnly then
          begin
            if FClient.IsNull then
              FOriginal.Clear
            else
              FDataSet.FieldByName(FOriginal.FieldName).Value := FClient.Value;
          end;
        end;
      end;
      Result := True;
    except
      Result := False;
    end;
  end;
  function InsertRec: Boolean;
  begin
    try
      FDataSet.Append;
      WriteFields;
      FDataSet.Post;
      Result := True;
    except
      Result := False;
    end;
  end;
  function UpdateRec: Boolean;
  begin
    try
      FDataSet.Edit;
      WriteFields;
      FDataSet.Post;
      Result := True;
    except
      Result := False;
    end;
  end;
  function DeleteRec: Boolean;
  begin
    try
      FDataSet.Delete;
      Result := True;
    except
      Result := False;
    end;
  end;
  function SaveChanges: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    FDataSet.DisableControls;
    DisableControls;
    Row := RecNo;
    FSaveLoadState := slsSaving;
    try
      if not IsEmpty then
        First;
      while not EOF do
      begin
        Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
        if (Status <> rsOriginal) then
        begin
          xKey := GetValues;
          bFound := FDataSet.Locate(FKeyFieldNames, xKey, []);
          DoBeforeApplyRecord(FDataSet, Status, bFound);
          bApply := False;
          (********************* New Record ***********************)
          if IsInserted then
          begin
            if not bFound then // Not Exists in Original
            begin
              if InsertRec then
              begin
                Inc(Result);
                bApply := True;
              end
              else
              if FExactApply then
              begin
                Error(RsEInsertError);
                Break;
              end
              else
              if (FDataSet.State in dsEditModes) then
                FDataSet.Cancel;
            end
            else
            if FApplyMode = amMerge then // Exists in Original
            begin
              if UpdateRec then
              begin
                Inc(Result);
                bApply := True;
              end
              else
              if FExactApply then
              begin
                Error(RsEUpdateError);
                Break;
              end
              else
              if (FDataset.State in dsEditModes) then
                FDataset.Cancel;
            end
            else
            if FExactApply then
            begin
              Error(RsERecordDuplicate);
              Break;
            end;
          end;
          (*********************** Modified Record ************************)
          if IsUpdated then
          begin
            if bFound then // Exists in Original
            begin
              if UpdateRec then
              begin
                Inc(Result);
                bApply := True;
              end
              else
              if FExactApply then
              begin
                Error(RsEUpdateError);
                Break;
              end
              else
              if (FDataset.State in dsEditModes) then
                FDataset.Cancel;
            end
            else
            if FApplyMode = amMerge then // Not exists in Original
            begin
              if InsertRec then
              begin
                Inc(Result);
                bApply := True;
              end
              else
              if FExactApply then
              begin
                Error(RsEInsertError);
                Break;
              end
              else
              if FDataset.State in dsEditModes then
                FDataset.Cancel;
            end
            else
            if FExactApply then
            begin
              Error(RsERecordInexistent);
              Break;
            end;
          end;
          DoAfterApplyRecord(FDataset, Status, bApply);
        end;
        Next;
      end;
      (*********************** Deleted Records **************************)
      if (FApplyMode = amMerge) then
      begin
        for I := 0 to FDeletedValues.Count - 1 do
        begin
          Status := rsDeleted;
          PxKey := FDeletedValues[I];
          // Mantis #3974 : "FDeletedValues" is a List of Pointers, and each item have two
          // possible values... PxKey (a Variant) or NIL. The list counter is incremented
          // with the ADD() method and decremented with the DELETE() method
          if PxKey <> nil then // ONLY if FDeletedValues[I] have a value <> NIL
          begin
            xKey := PxKey^;
            bFound := FDataSet.Locate(FKeyFieldNames, xKey, []);
            DoBeforeApplyRecord(FDataSet, Status, bFound);
            bApply := False;
            if bFound then // Exists in Original
            begin
              if DeleteRec then
              begin
                Inc(Result);
                bApply := True;
              end
              else
              if FExactApply then
              begin
                Error(RsEDeleteError);
                Break;
              end;
            end
            else
            if FExactApply then // Not exists in Original
            begin
              Error(RsERecordInexistent);
              Break;
            end
            else
            begin
              Inc(Result);
              bApply := True;
            end;
            DoAfterApplyRecord(FDataSet, Status, bApply);
          end;
        end;
      end;
    finally
      FSaveLoadState := slsNone;
      RecNo := Row;
      EnableControls;
      FDataSet.EnableControls;
    end;
  end;
begin
  Result := False;
  if (FDataSet = nil) or (FApplyMode = amNone) then
    Exit;
  if (FApplyMode <> amNone) and (FKeyFieldNames = '') then
    Exit;
  Len := FieldDefs.Count - 2;
  if (Len < 1) then
    Exit;
  try
    if not FDataSet.Active then
      FDataSet.Open;
  except
    Exit;
  end;
  CheckBrowseMode;
  DoBeforeApply(FDataset, FRowsChanged);
  FSaveLoadState := slsSaving;
  if (FRowsChanged < 1) or (IsEmpty and (FDeletedValues.Count < 1)) then
  begin
    FRowsAffected := 0;
    Result := (FRowsAffected = FRowsChanged);
  end
  else
  begin
    FRowsAffected := SaveChanges;
    Result := (FRowsAffected = FRowsChanged) or
      ((FRowsAffected > 0) and (FRowsAffected < FRowsChanged) and not FExactApply);
  end;
  FSaveLoadState := slsNone;
  DoAfterApply(FDataset, FRowsAffected);
  if Result then
    ClearChanges;
  FRowsAffected := 0;
  FRowsChanged := 0;
  if FDataSet.Active and FDatasetClosed then
    FDataset.Close;
end;
function TRESTDWMemTable.FindDeleted(KeyValues: Variant): Integer;
var
  I, J, Len, aEquals: Integer;
  PxKey: TPVariant;
  xKey, ValRow, ValDel: Variant;
begin
  Result := -1;
  if VarIsNull(KeyValues) then
    Exit;
  PxKey := nil;
  Len := VarArrayHighBound(KeyValues, 1);
  try
    for I := 0 to FDeletedValues.Count - 1 do
    begin
      PxKey := FDeletedValues[I];
      // Mantis #3974 : "FDeletedValues" is a List of Pointers, and each item have two
      // possible value... PxKey (a Variant) or NIL. The list counter is incremented
      // with the ADD() method and decremented with the DELETE() method
      if PxKey <> nil then // ONLY if FDeletedValues[I] have a value <> NIL
      begin
        xKey := PxKey^;
        aEquals := -1;
        for J := 0 to Len - 1 do
        begin
          ValRow := KeyValues[J];
          ValDel := xKey[J];
          if VarCompareValue(ValRow, ValDel) = vrEqual then
          begin
            Inc(aEquals);
            if aEquals = (Len - 1) then
              Break;
          end;
        end;
        if aEquals = (Len - 1) then
        begin
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
function TRESTDWMemTable.IsDeleted(out Index: Integer): Boolean;
begin
  Index := FindDeleted(GetValues());
  Result := Index > -1;
end;
function TRESTDWMemTable.IsInserted: Boolean;
begin
  Result := TRecordStatus(FieldByName(FStatusName).AsInteger) = rsInserted;
end;
function TRESTDWMemTable.IsUpdated: Boolean;
begin
  Result := TRecordStatus(FieldByName(FStatusName).AsInteger) = rsUpdated;
end;
function TRESTDWMemTable.IsOriginal: Boolean;
begin
  Result := TRecordStatus(FieldByName(FStatusName).AsInteger) = rsOriginal;
end;
function TRESTDWMemTable.IsLoading: Boolean;
begin
  Result := FSaveLoadState = slsLoading;
end;
function TRESTDWMemTable.IsSaving: Boolean;
begin
  Result := FSaveLoadState = slsSaving;
end;
//=== { TJvMemBlobStream } ===================================================
constructor TJvMemBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
begin
  // (rom) added inherited Create;
  inherited Create;
  FMode := Mode;
  FField := Field;
  FDataSet := FField.DataSet as TRESTDWMemTable;
  if not FDataSet.GetActiveRecBuf(FBuffer) then
    Exit;
  if not FField.Modified and (Mode <> bmRead) then
  begin
    if FField.ReadOnly then
      ErrorFmt('The Field %s is ReadOnly', [FField.DisplayName]);
    if not (FDataSet.State in [dsEdit, dsInsert]) then
      Error('Not Editing...');
    FCached := True;
  end
  else
    FCached := (FBuffer = PJvMemBuffer(FDataSet.ActiveBuffer));
  FOpened := True;
  if Mode = bmWrite then
    Truncate;
end;
destructor TJvMemBlobStream.Destroy;
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
function TJvMemBlobStream.GetBlobFromRecord(Field: TField): TMemBlobData;
var
  Rec: TJvMemoryRecord;
  Pos: Integer;
begin
  SetLength(Result, 0);
  Pos := FDataSet.RecNo -1;
  if (Pos >= 0) and (Pos < FDataSet.RecordCount) then
  begin
    Rec := FDataSet.Records[Pos];
    if Rec <> nil then
      Result := PMemBlobArray(Rec.FBlobs)[FField.Offset];
  end;
end;

Function TJvMemBlobStream.Read(Buffer: TBytes; Offset, Count: Longint): Longint;
Var
 aPointer : Pointer;
begin
 //Actual TODO XyberX
 aPointer := @Buffer;
 Result := Read(aPointer^, Count);
end;

function TJvMemBlobStream.Read(var Buffer; Count: Longint): Longint;
Var
 vString   : TRESTDWBytes;
 aBuffer   : PJvMemBuffer;
 aBytes    : TRESTDWBytes;
 aPointer  : Pointer;
 aPosition : Integer;
begin
  //Actual TODO XyberX
  Result := 0;
  if FOpened then
  begin
   If Count > 0 then
    Result := Count
   Else
    Result := Size - FPosition;
   If Result > 0 then
    begin
     vString  := GetBlobFromRecord(FField);
     //aPointer := @Buffer;
     aPointer := PRESTDWBytes(@Buffer);
     If Result > Length(vString) Then
      Begin
       Result := 0;
       SetLength(aBytes, Result);
       PRESTDWBytes(aPointer)^ := aBytes;
      End
     Else If Length(vString) > 0 Then
      Begin
       SetLength(aBytes, Result);
       Try
        //Actual TODO XyberX
        aPosition := FPosition;
        Move(vString[aPosition], aBytes[0], Result);
        SetLength(vString, 0);
       Finally
        If Length(PRESTDWBytes(aPointer)^) < Result Then
         PRESTDWBytes(aPointer)^ := aBytes
        Else
         Move(aBytes[0], PRESTDWBytes(aPointer)^[0], Result);
        SetLength(aBytes, 0);
       End;
      End;
     Inc(FPosition, Result);
    end
  end;
end;
function TJvMemBlobStream.Write(const Buffer; Count: Longint): Longint;
var
  Temp: TMemBlobData;
begin
  Result := 0;
  if FOpened and FCached and (FMode <> bmRead) then
  begin
    Temp := FDataSet.GetBlobData(FField, FBuffer);
    if Length(Temp) < FPosition + Count then
      SetLength(Temp, FPosition + Count);
    Move(Buffer, PJvMemBuffer(Temp)[FPosition], Count);
    FDataSet.SetBlobData(FField, FBuffer, Temp);
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
  end;
end;
function TJvMemBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
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
procedure TJvMemBlobStream.Truncate;
begin
  if FOpened and FCached and (FMode <> bmRead) then
  begin
    FDataSet.SetBlobData(FField, FBuffer, 0);
    FModified := True;
  end;
end;
function TJvMemBlobStream.GetBlobSize: Longint;
begin
  Result := 0;
  if FOpened then
   Result := Length(GetBlobFromRecord(FField));
end;

{ TRESTDWStorageBase }

constructor TRESTDWStorageBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEncodeStrs := True;
end;

procedure TRESTDWStorageBase.LoadDatasetFromStream(dataset: TDataset;
  stream: TStream);
begin

end;

procedure TRESTDWStorageBase.LoadDWMemFromStream(dataset: IRESTDWMemTable;
  stream: TStream);
begin

end;

procedure TRESTDWStorageBase.LoadFromStream(dataset: TDataset; stream: TStream);
begin
  if dataset.InheritsFrom(TRESTDWMemTable) then
    LoadDWMemFromStream(TRESTDWMemTable(dataset), stream)
  else
    LoadDatasetFromStream(dataset,stream);
end;

procedure TRESTDWStorageBase.SaveDatasetToStream(dataset: TDataset;
  var stream: TStream);
begin

end;

procedure TRESTDWStorageBase.SaveDWMemToStream(dataset: IRESTDWMemTable;
  var stream: TStream);
begin

end;

procedure TRESTDWStorageBase.SaveToStream(dataset: TDataset;
  var stream: TStream);
begin
  if dataset.InheritsFrom(TRESTDWMemTable) then
    SaveDWMemToStream(TRESTDWMemTable(dataset),stream)
  else
    SaveDatasetToStream(dataset, stream);
end;

end.


