Unit uRESTDWMemoryDataset;

{$I ..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
  de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo leVar componentes compatíveis entre o Delphi e outros Compiladores
  Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
  de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  Alberto Brito              - Admin - Administrador do desenvolvimento
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
  Flávio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}

Interface

uses
  SysUtils, Classes, DB, Variants, uRESTDWProtoTypes, uRESTDWMemDBUtils,
  uRESTDWMemExprParser{$IFNDEF FPC}, uRESTDWABMemDBFilterExpr, SqlTimSt{$ENDIF},
  uRESTDWAbout, uRESTDWConsts;

Const
 ftBlobTypes    = [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle,
                   ftTypedBinary, ftOraBlob, ftOraClob
                  {$IF DEFINED(FPC) OR DEFINED(DELPHI10_0UP)}, ftWideMemo{$IFEND}];
 ftSupported    = [ftString, ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency,
                   ftDate, ftTime, ftDateTime, ftAutoInc, ftBCD, ftFMTBCD, ftTimestamp,
                   {$IFNDEF FPC}
                     {$IFDEF DELPHI10_0UP}
                      ftOraTimestamp, ftFixedWideChar, ftTimeStampOffset,
                      ftLongWord, ftShortint, ftByte, ftExtended, ftSingle,
                     {$ENDIF DELPHI10_0UP}
                   {$ELSE}
                    ftFixedWideChar,
                   {$ENDIF FPC}
                   ftBytes, ftVarBytes, ftADT, ftFixedChar, ftWideString, ftLargeint, ftVariant, ftGuid] + ftBlobTypes;
 fkStoredFields = [fkData];

Type
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF CompilerVersion < 21}
    TRecordBuffer  = PChar;
   {$ELSE}
    TRecordBuffer  = PByte;
   {$IFEND}
  {$ELSE}
   {$IF CompilerVersion < 20}
    TRecordBuffer  = PChar;
   {$IFEND}
  {$IFEND}
 {$ENDIF}
 TPVariant             = ^Variant;
 TApplyMode            = (amNone, amAppend, amMerge);
 TApplyEvent           = Procedure(Dataset    : TDataset;
                                   Rows       : Integer) Of Object;
 TRecordStatus         = (rsOriginal, rsUpdated, rsInserted, rsDeleted);
 TApplyRecordEvent     = Procedure(Dataset    : TDataset;
                                   RecStatus  : TRecordStatus;
                                   FoundApply : Boolean) Of Object;
 TMemBlobData          = TRESTDWBytes;
 TMemBlobArray         = Array [0 .. MaxInt Div SizeOf(TMemBlobData) - 1] Of TMemBlobData;
 PMemBlobArray         = ^TMemBlobArray;
 PRESTDWMTMemoryRecord = ^TRESTDWMTMemoryRecord;
 TRESTDWMTMemoryRecord = Class;
 TLoadMode             = (lmCopy, lmAppend);
 TSaveLoadState        = (slsNone, slsLoading, slsSaving);
 TCompareRecords       = Function(Item1, Item2 : TRESTDWMTMemoryRecord) : Integer Of Object;
 TWordArray            = Array Of Word;
 TRESTDWMTBookmarkData = Integer;
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
    PRESTDWMTMemBuffer    = PByte;
    TRESTDWMTBookmark     = TBookmark;
    TRESTDWMTValueBuffer  = TValueBuffer;
    TRESTDWMTRecordBuffer = TRecordBuffer;
  {$ELSE}
   {$IFDEF UNICODE}
    PRESTDWMTMemBuffer    = PByte;
   {$ELSE}
     PRESTDWMTMemBuffer   = PAnsiChar;
   {$ENDIF UNICODE}
   TRESTDWMTBookmark      = Pointer;
   TRESTDWMTValueBuffer   = Pointer;
   TRESTDWMTRecordBuffer  = Pointer;
  {$IFEND}
 {$ELSE}
  TValueBuffer            = Array of Byte;
  PRESTDWMTMemBuffer      = PByte;
  TRESTDWMTBookmark       = Pointer;
  TRESTDWMTValueBuffer    = Pointer;
  TRESTDWMTRecordBuffer   = TRecordBuffer;
 {$ENDIF}
  IRESTDWMemTable = Interface
    Function GetRecordCount               : Integer;
    Function GetMemoryRecord  (Index      : Integer)      : TRESTDWMTMemoryRecord;
    Function GetOffSets       (Index      : Integer)      : Word;
    Function GetOffSetsBlobs              : Word;
    Function DataTypeSuported(datatype    : TFieldType)   : Boolean; // new
    Function DataTypeIsBlobTypes(datatype : TFieldType)   : Boolean; // new
    Function GetBlobRec         (Field    : TField;
                                 Rec      : TRESTDWMTMemoryRecord) : TMemBlobData;
    Function CreateBlobStream   (Field    : TField;
                                 Mode     : TBlobStreamMode)       : TStream;
    Function GetCalcFieldLen    (FieldType: TFieldType;
                                 Size     : Word)                  : Word;
    Procedure InternalAddRecord (Buffer   : {$IFDEF FPC}Pointer{$ELSE}
                                            {$IFDEF RESTDWANDROID}TRecBuf{$ELSE}
                                            {$IF CompilerVersion >22}Pointer{$ELSE}TRecordBuffer{$IFEND}{$ENDIF}{$ENDIF};
                                 aAppend  : Boolean);
    Procedure InitRecord        (Buffer   : {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF});
    Function  AllocRecordBuffer           : TRecordBuffer;
    Procedure SetMemoryRecordData(Buffer  : PRESTDWMTMemBuffer;
                                  Pos     : Integer);
    Procedure AfterLoad;
    Function  GetDataset                  : TDataset;
    {$IFDEF RESTDWLAZARUS}
    Function  GetDatabaseCharSet          : TDatabaseCharSet;
    {$ENDIF}
  End;
  TRESTDWStorageBase = class(TRESTDWComponent)
  Private
   {$IFDEF FPC}
    FDatabaseCharSet: TDatabaseCharSet;
   {$ENDIF}
   FEncodeStrs: Boolean;
  Protected
   Procedure SaveDatasetToStream  (Dataset    : TDataset;
                                   Var stream : TStream); Virtual;
   Procedure LoadDatasetFromStream(Dataset    : TDataset;
                                   stream     : TStream); Virtual;
   Procedure SaveDWMemToStream    (Dataset    : IRESTDWMemTable;
                                   Var stream : TStream); Virtual;
   Procedure LoadDWMemFromStream  (Dataset    : IRESTDWMemTable;
                                   stream     : TStream); Virtual;
  Public
   Constructor Create        (AOwner     : TComponent); Override;
   Procedure   SaveToStream  (Dataset    : TDataset;
                              Var Stream : TStream);
   Procedure   LoadFromStream(Dataset    : TDataset;
                              Stream     : TStream);
   Procedure   SaveToFile    (Dataset    : TDataset;
                              FileName   : String);
   Procedure   LoadFromFile  (Dataset    : TDataset;
                              FileName   : String);
  Public
   Property  EncodeStrs      : Boolean          Read FEncodeStrs      Write FEncodeStrs;
  Published
   {$IFDEF FPC}
    Property DatabaseCharSet : TDatabaseCharSet Read FDatabaseCharSet Write FDatabaseCharSet;
   {$ENDIF}
  End;
  PRecordList = ^TRecordList;
  TRecordList = Class(TList)
  Private
   Function  GetRec(Index : Integer) : TRESTDWMTMemoryRecord; Overload;
   Procedure PutRec(Index : Integer;
                    Item  : TRESTDWMTMemoryRecord);           Overload;
   Procedure ClearAll;
  Protected
  Public
   Destructor Destroy; Override;
   Procedure  Delete(Index : Integer); Overload;
   Function   Add   (Item  : TRESTDWMTMemoryRecord): Integer; Overload;
   Property   Items [Index : Integer] : TRESTDWMTMemoryRecord Read GetRec Write PutRec; Default;
  End;
  TRESTDWMemTable = Class(TDataset, IRESTDWMemTable)
  Private
    FSaveLoadState    : TSaveLoadState;
    FRecordPos,
    FRecordSize,
    FBookmarkOfs,
    FBlobOfs,
    FRecBufSize,
    FLastID,
    FRowsOriginal,
    FRowsChanged,
    FRowsAffected     : Integer;
    FOffsets          : TWordArray;
    FAutoInc          : Longint;
    FDeletedValues,
    FIndexList        : TList;
    FSrcAutoIncField  : TField;
    FRecords          : TRecordList;
    FDataSet          : TDataset;
    FClearing,
    FTrimEmptyString,
    FExactApply,
    FAutoIncAsInteger,
    FOneValueInArray,
    FActive,
    FCaseInsensitiveSort,
    FDescendingSort,
    FDataSetClosed,
    FLoadStructure,
    FLoadRecords      : Boolean;
    FStatusName,
    FKeyFieldNames    : String;
    FApplyMode        : TApplyMode;
    FBeforeApply,
    FAfterApply       : TApplyEvent;
    FBeforeApplyRecord,
    FAfterApplyRecord : TApplyRecordEvent;
    FFilterParser     : TExprParser;
    FStorageDataType  : TRESTDWStorageBase;
    {$IFNDEF FPC}
    FFilterExpression : TRDWABExprParser;
    {$ENDIF}
    {$IFDEF RESTDWLAZARUS}
    vDatabaseCharSet                   : TDatabaseCharSet;
    Procedure SetDatabaseCharSet(Value : TDatabaseCharSet);
    Function  GetDatabaseCharSet       : TDatabaseCharSet;
    {$ENDIF}
    Function  AddRecord          : TRESTDWMTMemoryRecord;
    Function  InsertRecord(Index : Integer) : TRESTDWMTMemoryRecord;
    Function  FindRecordID(ID    : Integer) : TRESTDWMTMemoryRecord;
    Procedure CreateIndexList(Const FieldNames : DWWideString);
    Procedure FreeIndexList;
    Procedure QuickSort      (L, R    : Integer;
                              Compare : TCompareRecords);
    Procedure Sort;
    Function  CalcRecordSize    : Integer;
    Function  GetMemoryRecord(Index : Integer) : TRESTDWMTMemoryRecord;
    Function  GetCapacity       : Integer;
    Function  RecordFilter      : Boolean;
    Procedure SetCapacity(Value : Integer);
    Procedure ClearRecords;
    Procedure InitBufferPointers(GetProps : Boolean);
    Procedure CheckStructure    (UseAutoIncAsInteger : Boolean = False);
    Procedure AddStatusField;
    Procedure HideStatusField;
    Function  CopyFromDataSet: Integer;
    Procedure ClearChanges;
    Procedure DoBeforeApply     (ADataset    : TDataset;
                                 RowsPending : Integer);
    Procedure DoAfterApply      (ADataset    : TDataset;
                                 RowsApplied : Integer);
    Procedure DoBeforeApplyRecord(ADataset   : TDataset;
                                  RS         : TRecordStatus;
                                  aFound     : Boolean);
    Procedure DoAfterApplyRecord (ADataset   : TDataset;
                                  RS         : TRecordStatus;
                                  aApply     : Boolean);
    Procedure InternalGotoBookmarkData(BookmarkData : TRESTDWMTBookmarkData);
    Function  InternalGetFieldData    (Field        : TField;
                                       Var Buffer   : TRESTDWMTValueBuffer) : Boolean;
    Procedure InternalSetFieldData    (Field        : TField;
                                       Buffer       : Pointer;
                                       Const ValidateBuffer : TRESTDWMTValueBuffer);
  Protected
    Function FindFieldData            (Buffer          : Pointer;
                                       Field           : TField) : Pointer;
    Function CompareFields            (Data1,
                                       Data2           : Pointer;
                                       FieldType       : TFieldType;
                                       CaseInsensitive : Boolean): Integer;     Virtual;
    // Delphi 2006+ has support for DWWideString
    {$IF DEFINED(FPC) OR DEFINED(RESTDWVCL)}
     Procedure DataConvert (Field    : TField;
                            Source,
                            Dest     : Pointer;
                            ToNative : Boolean); Override;
    {$IFEND}
    Procedure  AssignMemoryRecord(Rec        : TRESTDWMTMemoryRecord;
                                  Buffer     : PRESTDWMTMemBuffer);
    Function   GetActiveRecBuf   (Var RecBuf : PRESTDWMTMemBuffer) : Boolean;   Virtual;
    Procedure  InitFieldDefsFromFields;
    Procedure  RecordToBuffer    (Rec        : TRESTDWMTMemoryRecord;
                                  Buffer     : PRESTDWMTMemBuffer);
    Procedure SetMemoryRecordData(Buffer     : PRESTDWMTMemBuffer;
                                  Pos        : Integer);  Virtual;
    Procedure SetAutoIncFields   (Buffer     : PRESTDWMTMemBuffer);             Virtual;
    Function  CompareRecords     (Item1,
                                  Item2      : TRESTDWMTMemoryRecord): Integer; Virtual;
    Function  GetBlobData        (Field      : TField;
                                  Buffer     : PRESTDWMTMemBuffer)   : TMemBlobData;
    Procedure SetBlobData        (Field      : TField;
                                  Buffer     : PRESTDWMTMemBuffer;
                                  Value      : TMemBlobData);
   {$IFDEF NEXTGEN}
    Function  AllocRecBuf : TRecBuf; override;
    Procedure FreeRecBuf         (Var Buffer : TRecBuf); Override;
   {$ENDIF NEXTGEN}
    Function  AllocRecordBuffer : TRecordBuffer;{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure FreeRecordBuffer   (Var Buffer : TRecordBuffer);{$IFNDEF NEXTGEN}Override;{$ENDIF}
    Procedure InternalInitRecord (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}); Override;
    Function  GetRecord          (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF};
                                  GetMode    : TGetMode;
                                  DoCheck    : Boolean) : TGetResult; Overload; Override;
    Procedure GetBookmarkData    (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF};
                                  Data       : TRESTDWMTBookmark); Overload;Override;
    Function  GetBookmarkFlag    (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}) : TBookmarkFlag;Overload;Override;
    Procedure InternalSetToRecord(Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}); Overload;Override;
    Procedure SetBookmarkFlag    (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF};
                                  Value      : TBookmarkFlag);Overload; Override;
    Procedure SetBookmarkData    (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF};
                                  Data       : TRESTDWMTBookmark); Overload;Override;
    Procedure InitRecord         (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}); Overload;Override;
    Procedure InternalAddRecord  (Buffer     : {$IFDEF FPC}Pointer{$ELSE}
                                               {$IFDEF RESTDWANDROID}TRecBuf{$ELSE}
                                               {$IF CompilerVersion >22}Pointer{$ELSE}TRecordBuffer{$IFEND}{$ENDIF}{$ENDIF};
                                  aAppend    : Boolean); Overload;
    Function  GetCurrentRecord   (Buffer     :{$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}): Boolean; Overload;Override;
    Procedure ClearCalcFields    (Buffer     :{$IFDEF NEXTGEN}NativeInt{$ELSE}TRecordBuffer{$ENDIF}); Override;
    Function  GetRecordSize                  : Word; Override;
    Procedure SetFiltered      (Value        : Boolean); Overload;  Override;
    Procedure SetOnFilterRecord(Const Value  : TFilterRecordEvent); Override;
    Procedure SetFieldData     (Field        : TField;
                                Buffer       : TRESTDWMTValueBuffer);Overload;Override;
   {$IFNDEF NEXTGEN}
    {$IFDEF RTL240_UP}
     Procedure SetFieldData    (Field        : TField;
                                Buffer       : Pointer);Overload;Override;
     Procedure GetBookmarkData (Buffer       : TRecordBuffer;
                                Data         : Pointer);Overload;Override;
     Procedure InternalGotoBookmark(Bookmark : Pointer);Overload;Override;
     Procedure SetBookmarkData (Buffer       : TRecordBuffer;
                                Data         : Pointer);Overload;Override;
    {$ENDIF RTL240_UP}
   {$ENDIF ~NEXTGEN}
    Procedure CloseBlob        (Field        : TField);Override;
    Procedure InternalGotoBookmark(aBookmark : TRESTDWMTBookmark);Overload;Override;
    Function  GetIsIndexField     (Field     : TField): Boolean;Override;
    Procedure InternalFirst;  Override;
    Procedure InternalLast;   Override;
    Procedure InternalDelete; Override;
    Procedure InternalPost;   Override;
    Procedure InternalClose;  Override;
    Procedure InternalHandleException; Override;
    Procedure InternalInitFieldDefs;   Override;
    Procedure InternalOpen;            Override;
    Procedure OpenCursor(InfoQuery : Boolean);Overload;Override;
    Function  IsCursorOpen         : Boolean; Override;
    Function  GetRecordCount       : Integer; Override;
    Function  GetRecNo             : Integer; Override;
    Procedure SetRecNo  (Value     : Integer);Override;
    Procedure DoAfterOpen;                    Override;
    Procedure SetFilterText(Const Value : String);Override;
    Function  ParserGetVariableValue(Sender        : TObject;
                                     Const VarName : String;
                                     Var Value     : Variant)    : Boolean;Virtual;
    Procedure Notification          (AComponent    : TComponent;
                                     Operation     : TOperation);Override;
    Function DataTypeSuported       (datatype      : TFieldType) : Boolean;
    Function DataTypeIsBlobTypes    (datatype      : TFieldType) : Boolean;
    Function GetOffSets             (Index         : Integer)    : Word;
    Function GetOffSetsBlobs  : Word;
    Function GetBlobRec             (Field         : TField;
                                     Rec           : TRESTDWMTMemoryRecord) : TMemBlobData;
    Function GetCalcFieldLen        (FieldType     : TFieldType;
                                     Size          : Word)       : Word;
    Function GetDataset       : TDataset;
    Property Records [Index   : Integer] : TRESTDWMTMemoryRecord Read GetMemoryRecord;
  Public
    Constructor Create(AOwner : TComponent);Override;
    Destructor  Destroy;Override;
    Function    BookmarkValid   (aBookmark    : TBookmark)       : Boolean;Override;
    Function    CompareBookmarks(aBookmark1,
                                 aBookmark2   : TBookmark)       : Integer;Override;
    Function    CreateBlobStream(Field        : TField;
                                 Mode         : TBlobStreamMode) : TStream;Override;
    Procedure FixReadOnlyFields (MakeReadOnly : Boolean);
    Procedure ClearBuffer;
    Function  GetFieldData      (Field        : TField;
                                 {$IFNDEF FPC}
                                  {$IF CompilerVersion > 21}Var{$IFEND}
                                  Buffer       : TRESTDWMTValueBuffer
                                 {$ELSE}
                                  Buffer       : Pointer
                                 {$ENDIF})     : Boolean;Overload;Override;
    {$IFNDEF NEXTGEN}
     {$IFDEF RTL240_UP}
      Function GetFieldData     (Field         : TField;
                                 Buffer        : Pointer) : Boolean;Overload;Override;
     {$ENDIF RTL240_UP}
    {$ENDIF ~NEXTGEN}
    Function IsSequenced               : Boolean; Override;
    Function Locate(Const KeyFields    : String;
                    Const KeyValues    : Variant;
                    Options            : TLocateOptions) : Boolean;Override;
    Function Lookup(Const KeyFields    : String;
                    Const KeyValues    : Variant;
                    Const ResultFields : String)         : Variant;Override;
    Procedure SortOnFields(Const FieldNames : String = '';
                           CaseInsensitive  : Boolean = True;
                           Descending       : Boolean = False);
    Procedure SwapRecords (Idx1             : Integer;
                           Idx2             : Integer);
    Procedure EmptyTable;
    Procedure CopyStructure  (Source              : TDataset;
                              UseAutoIncAsInteger : Boolean = False);
    Function  LoadFromDataSet(Source              : TDataset;
                              aRecordCount        : Integer;
                              Mode                : TLoadMode;
                              DisableAllControls  : Boolean = True) : Integer;
    Function  SaveToDataSet  (Dest                : TDataset;
                              aRecordCount        : Integer;
                              DisableAllControls  : Boolean = True) : Integer;
    Property SaveLoadState : TSaveLoadState Read FSaveLoadState;
    Function  GetValues   (FldNames  : String = '') : Variant;
    Function  FindDeleted (KeyValues : Variant)     : Integer;
    Procedure AfterLoad;
    Function  IsDeleted   (out Index : Integer)     : Boolean;
    Function  IsInserted   : Boolean;
    Function  IsUpdated    : Boolean;
    Function  IsOriginal   : Boolean;
    Procedure CancelChanges;
    Function  ApplyChanges : Boolean;
    Function  IsLoading    : Boolean;
    Function  IsSaving     : Boolean;
    Procedure SaveToStream  (Var stream : TStream);
    Procedure LoadFromStream(stream     : TStream);
    Procedure Assign        (Source     : TPersistent);Reintroduce;Overload;Override;
    Property  RowsOriginal      : Integer            Read FRowsOriginal;
    Property  RowsChanged       : Integer            Read FRowsChanged;
    Property  RowsAffected      : Integer            Read FRowsAffected;
    Property  StorageDataType   : TRESTDWStorageBase Read FStorageDataType   Write FStorageDataType;
  published
    Property  Capacity          : Integer            Read GetCapacity        Write SetCapacity    Default 0;
    Property  Active;
    Property  AutoCalcFields;
    Property  Filtered;
    Property  FilterOptions;
    Property  FieldDefs;
    {$IFNDEF FPC}
     Property ObjectView default False;
    {$ENDIF}
    {$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet    : TDatabaseCharSet   Read GetDatabaseCharSet Write SetDatabaseCharSet;
    {$ENDIF}
    Property  DatasetClosed     : Boolean            Read FDataSetClosed     Write FDataSetClosed    Default False;
    Property  KeyFieldNames     : String             Read FKeyFieldNames     Write FKeyFieldNames;
    Property  LoadStructure     : Boolean            Read FLoadStructure     Write FLoadStructure    Default False;
    Property  LoadRecords       : Boolean            Read FLoadRecords       Write FLoadRecords      Default False;
    Property  ApplyMode         : TApplyMode         Read FApplyMode         Write FApplyMode        Default amNone;
    Property  ExactApply        : Boolean            Read FExactApply        Write FExactApply       Default False;
    Property  AutoIncAsInteger  : Boolean            Read FAutoIncAsInteger  Write FAutoIncAsInteger Default False;
    Property  OneValueInArray   : Boolean            Read FOneValueInArray   Write FOneValueInArray  Default True;
    Property  TrimEmptyString   : Boolean            Read FTrimEmptyString   Write FTrimEmptyString  Default True;
    Property  BeforeApply       : TApplyEvent        Read FBeforeApply       Write FBeforeApply;
    Property  AfterApply        : TApplyEvent        Read FAfterApply        Write FAfterApply;
    Property  BeforeApplyRecord : TApplyRecordEvent  Read FBeforeApplyRecord Write FBeforeApplyRecord;
    Property  AfterApplyRecord  : TApplyRecordEvent  Read FAfterApplyRecord  Write FAfterApplyRecord;
    Property  BeforeOpen;
    Property  AfterOpen;
    Property  BeforeClose;
    Property  AfterClose;
    Property  BeforeInsert;
    Property  AfterInsert;
    Property  BeforeEdit;
    Property  AfterEdit;
    Property  BeforePost;
    Property  AfterPost;
    Property  BeforeCancel;
    Property  AfterCancel;
    Property  BeforeDelete;
    Property  AfterDelete;
    Property  BeforeScroll;
    Property  AfterScroll;
    Property  OnCalcFields;
    Property  OnDeleteError;
    Property  OnEditError;
    Property  OnFilterRecord;
    Property  OnNewRecord;
    Property  OnPostError;
  End;

  TRESTDWMTMemBlobStream = Class(TStream)
  Private
   FField      : TBlobField;
   FDataSet    : TRESTDWMemTable;
   FBuffer     : PRESTDWMTMemBuffer;
   FActualBlob : Pointer;
   FMode       : TBlobStreamMode;
   FCached,
   FOpened,
   FModified   : Boolean;
   FPosition   : Longint;
   Function GetBlobSize : Longint;
   Function GetBlobFromRecord (Field : TField) : TMemBlobData;
   Procedure SetBlobFromRecord(Field : TField;
                               Value : TMemBlobData);
  Public
   Constructor Create(Field : TBlobField;
                      Mode  : TBlobStreamMode);
   Destructor Destroy; override;
   Function   Read   (Var Buffer;
                      Count : Longint) : Longint;Overload;Override;
   Function   Write  (Const Buffer;
                      Count : Longint) : Longint;Override;
   Function   Seek   (Offset: Longint;
                      Origin: Word)    : Longint;Override;
   Procedure Truncate;
  End;
  TRESTDWMTMemoryRecord = Class(TPersistent)
  Private
   FMemoryData : TRESTDWMemTable;
   FIndex,
   FID         : Integer;
   FData,
   FBlobs      : Pointer;
   FIsNull     : Boolean;
   Function  GetIndex : Integer;
   Procedure SetMemoryData(Value        : TRESTDWMemTable;
                           UpdateParent : Boolean);
  Protected
   Procedure SetIndex     (Value        : Integer);         Virtual;
  Public
   Constructor Create     (MemoryData   : TRESTDWMemTable); Virtual;
   Constructor CreateEx   (MemoryData   : TRESTDWMemTable;
                           UpdateParent : Boolean);         Virtual;
   Destructor  Destroy;Override;
   Property    MemoryData : TRESTDWMemTable Read FMemoryData;
   Property    ID         : Integer         Read FID         Write FID;
   Property    Index      : Integer         Read GetIndex    Write SetIndex;
   Property    Data       : Pointer         Read FData       Write FData;
   Property    Blobs      : Pointer         Read FBlobs      Write FBlobs;
   Property    IsNull     : Boolean         Read FIsNull     Write FIsNull;
  End;
  TSortOrder        = (soAsc, soDesc);
  //Possible sorting case sensitivity values
  // sensitive sorting - insensitive sorting
  TSortCaseSens     = (scYes, scNo);
  TRESTDWMemTableEx = Class(TRESTDWMemTable)
  Private
   fSortFields                     : String;
   fSortOrder                      : TSortOrder;
   fSortCaseSens                   : TSortCaseSens;
   fAutoSortOnOpen,
   fAutoRefreshOnFilterChanged     : Boolean;
   fFilteredRecordCount            : Integer;
   Function GetFilteredRecordCount : Integer;
  Protected
   Procedure SetFiltered       (Value       : Boolean);            Override;
   Procedure SetOnFilterRecord (Const Value : TFilterRecordEvent); Override;
   Procedure InternalRefresh;   Overload;
   Procedure InternalAddRecord (Buffer      : Pointer;
                                {$IFDEF FPC}aAppend : Boolean{$ELSE}Append : Boolean{$ENDIF});Overload;
   Procedure InternalDelete;    Overload;
   Procedure InternalPost;      Overload;
   Procedure RefreshFilteredRecordCount;
  Public
   Constructor Create          (AOwner      : TComponent);Override;
   Procedure   ReSortOnFields  (pSortOrder  : TSortOrder;
                                {$IFDEF FPC}afields : String{$ELSE}fields: String{$ENDIF});
   Function    LoadFromDataSet (Source      : TDataSet;
                                {$IFDEF FPC}aRecordCount : Integer;{$ELSE}RecordCount : Integer;{$ENDIF}
                                Mode        : TLoadMode) : Integer;
   Procedure   EmptyTable;
   Procedure   CopyStructure   (Source      : TDataSet);
   Function    IsSortField     (field       : TField)    : Boolean;
  Published
   Property    SortOrder                  : TSortOrder    Read fSortOrder                  Write fSortOrder;
   Property    SortCaseSens               : TSortCaseSens Read fSortCaseSens               Write fSortCaseSens;
   Property    SortFields                 : String        Read fSortFields                 Write fSortFields nodefault;
   Property    AutoSortOnOpen             : Boolean       Read fAutoSortOnOpen             Write fAutoSortOnOpen;
   Property    AutoRefreshOnFilterChanged : Boolean       Read fAutoRefreshOnFilterChanged Write fAutoRefreshOnFilterChanged;
   Property    RecordCount                : Integer       Read GetFilteredRecordCount;
  End;


Implementation

Uses
  Types, Math,
  {$IFDEF RTL240_UP}
   System.Generics.Collections,
  {$ENDIF RTL240_UP}
  FMTBcd,
  {$IFDEF RESTDWVCL}uRESTDWMemVCLUtils,{$ENDIF}
  uRESTDWMemResources,
  uRESTDWTools, uRESTDWBasicTypes, uRESTDWStorageBin;

Const
 GuidSize = 38;
 STATUSNAME = 'C67F70Z90'; (* Magic *)

Type
 PMemBookmarkInfo = ^TMemBookmarkInfo;
 TMemBookmarkInfo = record
  BookmarkData: TRESTDWMTBookmarkData;
  BookmarkFlag: TBookmarkFlag;
End;

Function ExtractFieldNameEx(Const Fields : {$IFDEF COMPILER10_UP}DWWideString{$ELSE}String{$ENDIF};
                            Var   Pos    : Integer) : String;
Begin
 Result := ExtractFieldName(Fields, Pos);
End;

Procedure AppHandleException(Sender: TObject);
Begin
 If Assigned(ApplicationHandleException) then
  ApplicationHandleException(Sender);
End;

Procedure CopyFieldValue(DestField, SourceField: TField);
Begin
 If SourceField.IsNull then
  DestField.Clear
 Else If DestField.ClassType = SourceField.ClassType then
  Begin
   Case DestField.datatype Of
    ftInteger,
    ftSmallint,
    ftWord      : DestField.AsInteger  := SourceField.AsInteger;
    ftBCD,
    ftCurrency  : DestField.AsCurrency := SourceField.AsCurrency;
    ftFMTBCD    : DestField.AsBCD      := SourceField.AsBCD;
    ftString    : DestField.AsString   := SourceField.AsString;
    {$IF DEFINED(FPC) OR DEFINED(COMPILER10_UP)}
     ftWideString    : DestField.AsWideString := SourceField.AsWideString;
     ftFixedWideChar : DestField.AsWideString := SourceField.AsWideString;
    {$IFEND}
    ftFloat
    {$IFNDEF FPC}
     {$IFDEF DELPHI10_0UP}
      , ftSingle
     {$ENDIF DELPHI10_0UP}
    {$ENDIF}: DestField.AsFloat := SourceField.AsFloat;
    ftDateTime       : DestField.AsDateTime := SourceField.AsDateTime;
    Else DestField.Assign(SourceField);
   End;
  End
 Else
  DestField.Assign(SourceField);
End;

Function CalcFieldLen(FieldType : TFieldType;
                      Size      : Word) : Word;
Var
 vDWFieldType : Byte;
Begin
 If Not(FieldType In ftSupported) Then
  Begin
   Result := 0;
   Exit;
  End
 Else If FieldType In ftBlobTypes Then
  Begin
   Result := SizeOf(Int64);
   Exit;
  End
 Else
  Result := Size;
 vDWFieldType := FieldTypeToDWFieldType(FieldType);    //Gledston - Alterei a partir deste ponto
 Case vDWFieldType of
  dwftString    : Inc (Result, Size + 1);
  dwftSmallint  : Result := SizeOf(Smallint);
  dwftInteger   : Result := SizeOf(Integer);
  dwftWord      : Result := SizeOf(Word);
  dwftBoolean   : Result := SizeOf(Wordbool);
  dwftFloat     : Result := SizeOf(Double);
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21}
   dwftSingle    : Result := SizeOf(Single) + 5;
   {$IFEND}
  {$ENDIF}
  dwftCurrency  : Result := SizeOf(Currency);
  dwftDate,
  dwftTime      : Result := SizeOf(Int64)+ 8;
  dwftDateTime  : Result := {$IFDEF FPC}SizeOf(TDateTime){$ELSE}SizeOf(TSQLTimeStamp){$ENDIF};
  dwftAutoInc   : Result := SizeOf(Longint);
  dwftLargeint  : Result := {$IFDEF FPC}8{$ELSE}{$IF CompilerVersion <= 22}8{$ELSE}64{$IFEND}{$ENDIF}; //Field Size é 64 Bits
  dwftBCD,                                                                           //Result := SizeOf(TBcd);
  dwftFMTBCD    : Result := SizeOf(DWBCD);
  dwftTimeStamp : Begin
                   Result := {$IFDEF FPC}SizeOf(TTimeStamp){$ELSE}SizeOf(TSQLTimeStamp){$ENDIF};
                  End;
  dwftTimeStampOffset : Begin
                         Inc(Result,SizeOf(Double));
                         Inc(Result,SizeOf(Byte));
                         Inc(Result,SizeOf(Byte));
                        End;
  {$IFDEF COMPILER10_UP}
   dwftOraTimestamp   : Result := SizeOf(TSQLTimeStamp);
   dwftFixedWideChar  : Result := (Result + 1) * SizeOf(WideChar);
  {$ENDIF COMPILER10_UP}
  {$IFDEF COMPILER12_UP}
   dwftLongWord       : Result := SizeOf(LongWord);
   dwftShortint       : Result := SizeOf(Shortint);
   dwftByte           : Result := SizeOf(Byte);
   dwftExtended       : Result := SizeOf(Extended);
  {$ENDIF COMPILER12_UP}
  dwftADT             : Result := 0;
  dwftFixedChar       : Inc(Result);
  dwftWideString      : Result := (Result + 1) * SizeOf(WideChar);
  dwftVariant         : Result := SizeOf(Variant);
  dwftGuid            : Result := GuidSize + 1;
  dwftWideMemo,
  dwftBlob,
  dwftMemo,
  dwftBytes,
  dwftVarBytes,
  dwftFmtMemo,
  dwftOraBlob,
  dwftOraClob         : Result := SizeOf(Pointer);
 End;
 If vDWFieldType      In FieldGroupVariant Then
  Result := SizeOf(Variant)
 Else If vDWFieldType In FieldGroupGUID    Then
  Result := GuidSize + 1;
 If Result > 0 Then
  Result := Result + SizeOf(Boolean);
End;

Procedure CalcDataSize(FieldDef: TFieldDef; Var DataSize: Integer);
Var
 I : Integer;
Begin
 If FieldDef.datatype in ftSupported - ftBlobTypes then
  Inc(DataSize, CalcFieldLen(FieldDef.datatype, FieldDef.Size));
 If FieldDef.datatype in ftBlobTypes then
  Inc(DataSize, CalcFieldLen(FieldDef.datatype, FieldDef.Size));
 {$IFNDEF FPC}
  For I := 0 to FieldDef.ChildDefs.Count - 1 do
   CalcDataSize(FieldDef.ChildDefs[I], DataSize);
 {$ENDIF}
End;

Procedure Error(const Msg: string);
Begin
 DatabaseError(Msg);
End;

Procedure ErrorFmt(const Msg: string; const Args: array of const);
Begin
 DatabaseErrorFmt(Msg, Args);
End;

// === { TRESTDWMTMemoryRecord } ====================================================
Constructor TRESTDWMTMemoryRecord.Create(MemoryData: TRESTDWMemTable);
Begin
 FIsNull := True;
 FIndex := -1;
 CreateEx(MemoryData, True);
End;

Constructor TRESTDWMTMemoryRecord.CreateEx(MemoryData: TRESTDWMemTable; UpdateParent: Boolean);
Begin
 Inherited Create;
 SetMemoryData(MemoryData, UpdateParent);
End;

Destructor TRESTDWMTMemoryRecord.Destroy;
Begin
 SetMemoryData(Nil, False);
 Inherited Destroy;
End;

Function TRESTDWMTMemoryRecord.GetIndex: Integer;
Begin
  // If FMemoryData <> nil then
  // Result := FMemoryData.FRecords.IndexOf(Self)
  // Else
 Result := FIndex;
End;

Procedure TRESTDWMTMemoryRecord.SetMemoryData(Value: TRESTDWMemTable; UpdateParent: Boolean);
var
  I: Integer;
  DataSize: Integer;
Begin
  If FMemoryData <> Value then
  Begin
    If FMemoryData <> nil then
    Begin
      // If not FMemoryData.FClearing Then
      // FMemoryData.FRecords.Remove(Self);
      ReallocMem(FBlobs, 0);
      ReallocMem(FData, 0);
      FMemoryData := Nil;
    End;
    If Value <> nil then
    Begin
      If UpdateParent then
      Begin
        Value.FRecords.Add(Self);
        Inc(Value.FLastID);
        FID := Value.FLastID;
      End;
      FMemoryData := Value;
      If Value.BlobFieldCount > 0 then
      Begin
        ReallocMem(FBlobs, Value.BlobFieldCount * SizeOf(Pointer));
        Initialize(PMemBlobArray(FBlobs)^[0], Value.BlobFieldCount);
      End;
      DataSize := 0;
      For I := 0 to Value.FieldDefs.Count - 1 do
        CalcDataSize(Value.FieldDefs[I], DataSize);
      ReallocMem(FData, DataSize);
    End;
  End;
End;

Procedure TRESTDWMTMemoryRecord.SetIndex(Value: Integer);
var
  CurIndex: Integer;
Begin
  CurIndex := GetIndex;
  If (CurIndex >= 0) and (CurIndex <> Value) then
    FMemoryData.FRecords.Move(CurIndex, Value);
  FIndex := Value;
End;
// === { TRESTDWMemTable } ======================================================
// Function TRESTDWMemTable.FieldByName(const FieldName: string): TField;
// Begin
//
// End;
//
// Function FindField(const FieldName: string): TField;
// Begin
//
// End;

constructor TRESTDWMemTable.Create(AOwner: TComponent);
Begin
  inherited Create(AOwner);
  FRecordPos := -1;
  FLastID := Low(Integer);
  FAutoInc := 1;
  FRecords := TRecordList.Create;
  FStatusName := STATUSNAME;
  FDeletedValues := TList.Create;
  FRowsOriginal := 0;
  FRowsChanged := 0;
  FRowsAffected := 0;
  FSaveLoadState := slsNone;
  FOneValueInArray := True;
  FDataSetClosed := False;
  FTrimEmptyString := True;
  FStorageDataType := nil;
End;

destructor TRESTDWMemTable.Destroy;
var
  I: Integer;
  PFValues: TPVariant;
Begin
  If Active then
    Close;
  If FFilterParser <> nil then
    FreeAndNil(FFilterParser);
{$IFNDEF FPC}
  If FFilterExpression <> nil then
    FreeAndNil(FFilterExpression);
{$ENDIF}
  If Assigned(FDeletedValues) then
  Begin
    If FDeletedValues.Count > 0 then
      for I := 0 to (FDeletedValues.Count - 1) do
      Begin
        PFValues := FDeletedValues[I];
        If PFValues <> nil then
          Dispose(PFValues);
        FDeletedValues[I] := nil;
      End;
    FreeAndNil(FDeletedValues);
  End;
  FreeIndexList;
  // ClearRecords;
  FRecords.Free;
  FOffsets := nil;
  inherited Destroy;
End;

Function TRESTDWMemTable.CompareFields(Data1, Data2: Pointer; FieldType: TFieldType;
  CaseInsensitive: Boolean): Integer;
Begin
  Result := 0;
  case FieldType of
    ftString:
      If CaseInsensitive then
        Result := AnsiCompareText(PDWString(@Data1)^, PDWString(@Data2)^)
      Else
        Result := AnsiCompareStr(PDWString(@Data1)^, PDWString(@Data2)^);
    ftSmallint:
      If Smallint(Data1^) > Smallint(Data2^) then
        Result := 1
      Else If Smallint(Data1^) < Smallint(Data2^) then
        Result := -1;
    ftInteger, ftDate, ftTime, ftAutoInc:
      If Longint(Data1^) > Longint(Data2^) then
        Result := 1
      Else If Longint(Data1^) < Longint(Data2^) then
        Result := -1;
    ftWord:
      If Word(Data1^) > Word(Data2^) then
        Result := 1
      Else If Word(Data1^) < Word(Data2^) then
        Result := -1;
    ftBoolean:
      If Wordbool(Data1^) and not Wordbool(Data2^) then
        Result := 1
      Else If not Wordbool(Data1^) and Wordbool(Data2^) then
        Result := -1;
    ftFloat, ftCurrency
    {$IFNDEF FPC}
     {$IFDEF DELPHI10_0UP}
      , ftSingle
     {$ENDIF DELPHI10_0UP}
    {$ENDIF}:
      If Double(Data1^) > Double(Data2^) then
        Result := 1
      Else If Double(Data1^) < Double(Data2^) then
        Result := -1;
{$IFDEF FPC}
    ftFMTBCD:
      Result := BcdCompare(TBCD(Data1^), TBCD(Data2^));
    ftBCD:
      If Double(Data1^) > Double(Data2^) then
        Result := 1
      Else If Double(Data1^) < Double(Data2^) then
        Result := -1;
{$ELSE}
    ftFMTBCD, ftBCD:
      Result := BcdCompare(TBCD(Data1^), TBCD(Data2^));
{$ENDIF}
    ftDateTime:
      If TDateTime(Data1^) > TDateTime(Data2^) then
        Result := 1
      Else If TDateTime(Data1^) < TDateTime(Data2^) then
        Result := -1;
    ftFixedChar:
      If CaseInsensitive then
        Result := AnsiCompareText(PDWString(@Data1)^, PDWString(@Data2)^)
      Else
        Result := AnsiCompareStr(PDWString(@Data1)^, PDWString(@Data2)^);
{$IF DEFINED(FPC) OR DEFINED(COMPILER10_UP)}
    ftFixedWideChar:
      If CaseInsensitive then
        Result := AnsiCompareText(WideCharToString(PWideChar(Data1)),
          WideCharToString(PWideChar(Data2)))
      Else
        Result := AnsiCompareStr(WideCharToString(PWideChar(Data1)),
          WideCharToString(PWideChar(Data2)));
    ftWideString:
      If CaseInsensitive then
        Result := AnsiCompareText(WideCharToString(PWideChar(Data1)),
          WideCharToString(PWideChar(Data2)))
      Else
        Result := AnsiCompareStr(WideCharToString(PWideChar(Data1)),
          WideCharToString(PWideChar(Data2)));
{$IFEND}
    ftLargeint:
      If Int64(Data1^) > Int64(Data2^) then
        Result := 1
      Else If Int64(Data1^) < Int64(Data2^) then
        Result := -1;
    ftVariant:
      Result := 0;
    ftGuid:
      Result := CompareText(PDWString(Data1)^, PDWString(Data2)^);
  End;
End;

Function TRESTDWMemTable.GetCapacity: Integer;
Begin
  If FRecords <> nil then
    Result := FRecords.Capacity
  Else
    Result := 0;
End;

Procedure TRESTDWMemTable.SetCapacity(Value: Integer);
Begin
  If FRecords <> nil then
    FRecords.Capacity := Value;
End;

Function TRESTDWMemTable.AddRecord: TRESTDWMTMemoryRecord;
Begin
  Result := TRESTDWMTMemoryRecord.Create(Self);
End;

Function TRESTDWMemTable.FindRecordID(ID: Integer): TRESTDWMTMemoryRecord;
var
  I: Integer;
Begin
  for I := 0 to FRecords.Count - 1 do
  Begin
    Result := TRESTDWMTMemoryRecord(FRecords[I]);
    If Result.ID = ID then
      Exit;
  End;
  Result := nil;
End;

Function TRESTDWMemTable.InsertRecord(Index: Integer): TRESTDWMTMemoryRecord;
Begin
  Result := AddRecord;
  Result.Index := Index;
End;

Function TRESTDWMemTable.GetMemoryRecord(Index: Integer): TRESTDWMTMemoryRecord;
Begin
  Result := TRESTDWMTMemoryRecord(FRecords[Index]);
End;

Procedure TRESTDWMemTable.InitFieldDefsFromFields;
var
  I: Integer;
  Offset: Word;
  Field: TField;
  FieldDefsUpdated: Boolean;
  FieldLen: Word;
Begin
  If FieldDefs.Count = 0 then
  Begin
    for I := 0 to FieldCount - 1 do
    Begin
      Field := Fields[I];
      If (Field.FieldKind in fkStoredFields) and not(Field.datatype in ftSupported) then
        ErrorFmt('Field ''%s'' is of unknown type', [Field.DisplayName]);
    End;
    FreeIndexList;
  End;
  Offset := 0;
  inherited InitFieldDefsFromFields;
  { Calculate fields offsets }
  // Actual TODO XyberX
  SetLength(FOffsets, FieldDefs.Count);
  FieldDefs.Update;
  FieldDefsUpdated := FieldDefs.Updated;
  Try
    FieldDefs.Updated := True;
    // Performance optimization: FieldDefList.Updated returns False is FieldDefs.Updated is False
    for I := 0 to FieldDefs.Count - 1 do
    Begin
      FOffsets[I] := Offset;
      If FieldDefs[I].datatype in ftSupported - ftBlobTypes then
      Begin
        FieldLen := CalcFieldLen(FieldDefs[I].datatype, FieldDefs[I].Size);
        If Offset + FieldLen<= high(Offset) then
          Inc(Offset, FieldLen)
        Else
          raise ERangeError.CreateResFmt(@RsEFieldOffsetOverflow, [I]);
      End;

    End;
  Finally
    FieldDefs.Updated := FieldDefsUpdated;
  End;
End;

Function TRESTDWMemTable.FindFieldData(Buffer: Pointer; Field: TField): Pointer;
var
  Index: Integer;
  datatype: TFieldType;
Begin
  Result := nil;
  Index := Field.FieldNo - 1;
  // FieldDefList index (-1 and 0 become less than zero => ignored)
  If (Index >= 0) And (Buffer <> nil) Then
  Begin
    datatype := FieldDefs[Index].datatype;
    If datatype in ftSupported then
      If datatype in ftBlobTypes then
      Begin
{$IFDEF FPC}
        Result := Pointer(GetBlobData(Field, Buffer));
{$ELSE}
{$IF CompilerVersion <= 22}
        Result := Pointer(@PMemBlobArray(PRESTDWMTMemBuffer(Buffer) + FOffsets[Index] +
          FBlobOfs)^[Field.Offset]);
{$ELSE}
        Result := Pointer(GetBlobData(Field, Buffer));
{$IFEND}
{$ENDIF}
      End
      Else
      {$IFDEF FPC}
        Result := Pointer(PRESTDWMTMemBuffer(Buffer + FOffsets[Index]));
      {$ELSE}
        Result := Pointer(PRESTDWMTMemBuffer(Buffer) + FOffsets[Index]);
      {$ENDIF}
  End;
End;

Function TRESTDWMemTable.CalcRecordSize: Integer;
var
  I: Integer;
Begin
  Result := 0;
  for I := 0 to FieldDefs.Count - 1 do
    CalcDataSize(FieldDefs[I], Result);
End;

Procedure TRESTDWMemTable.InitBufferPointers(GetProps: Boolean);
Begin
  If GetProps then
    FRecordSize := CalcRecordSize;
  FBookmarkOfs := FRecordSize + sizeof(int64); //o int64 para adicionar o size do blob. o calcfieldssize vem zero  //CalcFieldsSize;
  FBlobOfs := FBookmarkOfs + SizeOf(TMemBookmarkInfo);
  FRecBufSize := FBlobOfs + BlobFieldCount * SizeOf(Pointer);
End;

Procedure TRESTDWMemTable.ClearRecords;
Begin
  Try
    FClearing := True;
    FRecords.ClearAll;
  Finally
    FClearing := False;
  End;
  FLastID := Low(Integer);
  FRecordPos := -1;
End;

Function TRESTDWMemTable.AllocRecordBuffer: TRecordBuffer;
Var
  I: Integer;
  FBlobs: Pointer;
Begin
{$IFDEF DELPHI10_0UP}
  GetMem(Result, FRecBufSize);
{$ELSE}
  Result := StrAlloc(FRecBufSize);
{$ENDIF DELPHI10_0UP}
  FBlobs := Pointer(@PMemBlobArray(Result + FBlobOfs)^);
  // {$IFDEF FPC}
  // ReallocMem(FBlobs, 0);
  // {$ELSE}
  // {$IF CompilerVersion <= 22}
  // If FMemoryData.BlobFieldCount > 0 Then
  // Finalize(PMemBlobArray(@FBlobs)^[0], FMemoryData.BlobFieldCount);
  // {$ELSE}
  // ReallocMem(FBlobs, 0);
  // {$IFEND}
  // {$ENDIF}
  // ReallocMem(FBlobs, BlobFieldCount * SizeOf(Pointer));
{$IFNDEF FPC}
  If BlobFieldCount > 0 Then
    Initialize(PMemBlobArray(FBlobs)[0], BlobFieldCount);
{$ELSE}
  If BlobFieldCount > 0 Then
    Initialize(PMemBlobArray(FBlobs)^[0], BlobFieldCount);
{$ENDIF}
End;

Procedure TRESTDWMemTable.FreeRecordBuffer(Var Buffer: TRecordBuffer);
Var
  I: Integer;
Begin
  For I := 0 To BlobFieldCount - 1 Do
  Begin
{$IFNDEF FPC}
    If BlobFieldCount > 0 Then
      Finalize(PMemBlobArray(Buffer + FBlobOfs)[I], 1);
{$ELSE}
    If BlobFieldCount > 0 Then
      Finalize(PMemBlobArray(Buffer + FBlobOfs)^[I], 1);
{$ENDIF}
  End;
{$IFDEF DELPHI10_0UP}
  FreeMem(Buffer);
{$ELSE}
  StrDispose(Buffer);
{$ENDIF DELPHI10_0UP}
  Buffer := nil;
End;

Procedure TRESTDWMemTable.ClearCalcFields(Buffer:
  {$IFDEF NEXTGEN}NativeInt{$ELSE}TRecordBuffer{$ENDIF});
Begin
{$IFNDEF NEXTGEN}
  FillChar(Buffer[FRecordSize], CalcFieldsSize, 0);
{$ENDIF !NEXTGEN}
End;

{$IFDEF NEXTGEN}

Function TRESTDWMemTable.AllocRecBuf: TRecBuf;
Begin
  Result := TRecBuf(AllocRecordBuffer);
End;

Procedure TRESTDWMemTable.FreeRecBuf(Var Buffer: TRecBuf);
Begin
  FreeRecordBuffer(TRecordBuffer(Buffer));
End;
{$ENDIF}

Procedure TRESTDWMemTable.InternalInitRecord(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF});
var
  I: Integer;
Begin
{$IFDEF NEXTGEN}
  FillChar(PChar(Buffer), FBlobOfs, 0);
{$ELSE}
  FillChar(Buffer^, FBlobOfs, 0);
{$ENDIF}
  // For I := 0 to BlobFieldCount - 1 do
  // SetLength(PMemBlobArray(Buffer + FBlobOfs)^[I], 0);
  Initialize(PMemBlobArray(Buffer + FBlobOfs)^[0], BlobFieldCount);
End;

Procedure TRESTDWMemTable.InitRecord(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF});
Var
 vBoolean : Boolean;
  PActualRecord: PRESTDWMTMemBuffer;
  PData: {$IFDEF FPC} PAnsiChar {$ELSE} PByte {$ENDIF};
  I, aIndex, cLen: Integer;
  aDataType: TFieldType;
  aFieldCount: Integer;
  aFields: TFields;
  Fld: TField; // Else BAD mem leak on 'Field.asString'
Begin
 vBoolean := True;
{$IFDEF NEXTGEN}
  inherited InitRecord({$IFDEF RTL250_UP}TRecBuf{$ENDIF}(Buffer));
{$ELSE}
  // in non-NEXTGEN InitRecord(TRectBuf) calls InitRecord(TRecordBuffer) => Endless recursion
{$WARN SYMBOL_DEPRECATED OFF} // XE4
  inherited InitRecord({$IFDEF RTL250_UP}TRecordBuffer{$ENDIF}(Buffer));
{$WARN SYMBOL_DEPRECATED ON}
{$ENDIF NEXTGEN}
  With PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do
  Begin
    BookmarkData := Low(Integer);
    BookmarkFlag := bfInserted;
  End;
  PActualRecord := PRESTDWMTMemBuffer(Buffer);
  aFields := Fields;
  Try
    aFieldCount := aFields.Count;
    For I := 0 To aFieldCount - 1 Do
    Begin
      PData := Nil;
      Fld := aFields[I];
      aDataType := Fld.datatype;
      aIndex := Fld.FieldNo - 1;
      If DataTypeSuported(aDataType) Then
      Begin
        If Not DataTypeIsBlobTypes(aDataType) Then
          PData := Pointer(PActualRecord + GetOffSets(aIndex))
        Else
          PData := Pointer(@PMemBlobArray(PActualRecord + GetOffSetsBlobs)^[Fld.Offset]);
        If (PData <> Nil) Then
        Begin
          Case FieldTypeToDWFieldType(aDataType) Of
            dwftFixedChar, dwftString, dwftWideString, dwftFixedWideChar:
              Begin
                If Fld <> Nil Then
                Begin
                  cLen := GetCalcFieldLen(aDataType, Fld.Size);
{$IFDEF FPC}
                  FillChar(PData^, cLen, #0);
{$ELSE}
                  FillChar(PData^, cLen, 0);
{$ENDIF}
                End;
              End;
              dwftByte, dwftShortint, dwftSmallint, dwftWord, dwftInteger, dwftAutoInc,
              dwftLargeint, dwftDate, dwftTime, dwftDateTime, dwftTimeStamp, dwftExtended, dwftSingle,
              dwftTimeStampOffset, dwftFloat, dwftFMTBcd, dwftCurrency, dwftBCD:
              Begin
               If Not(FieldTypeToDWFieldType(aDataType) in [dwftByte, dwftShortint]) then
                Begin
                 Move(vBoolean, pData^, SizeOf(Boolean));
                 Inc(pData^);
                End;
              {$IFDEF FPC}
                FillChar(PData^, 1, 'S');
              {$ELSE}
                FillChar(PData^, 1, 'S');
              {$ENDIF}
              End;
            dwftStream, dwftBlob, dwftBytes, dwftMemo, dwftWideMemo, dwftFmtMemo:
              Begin
                SetLength(PRESTDWBytes(PData)^, 0);
              End;
          End;
        End;
      End;
    End;
  Finally
     //FreeAndNil(aFields);
  End;
End;

Function TRESTDWMemTable.GetCurrentRecord(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}): Boolean;
Begin
  Result := False;
  If not IsEmpty and (GetBookmarkFlag(ActiveBuffer) = bfCurrent) then
  Begin
    UpdateCursorPos;
    If (FRecordPos >= 0) and (FRecordPos < RecordCount) then
    Begin
      Move(Records[FRecordPos].Data^,
        {$IFDEF NEXTGEN}PChar(Buffer)^{$ELSE}Buffer^{$ENDIF}, FRecordSize);
      Result := True;
    End;
  End;
End;

Function TRESTDWMemTable.GetRecord(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
var
  Accept: Boolean;
Begin
  Result := grOk;
  Accept := True;
  case GetMode of
    gmPrior:
      If FRecordPos <= 0 then
      Begin
        Result := grBOF;
        FRecordPos := -1;
      End
      Else
      Begin
        repeat
          Dec(FRecordPos);
          If Filtered then
            Accept := RecordFilter;
        until Accept or (FRecordPos < 0);
        If not Accept then
        Begin
          Result := grBOF;
          FRecordPos := -1;
        End;
      End;
    gmCurrent:
      If (FRecordPos < 0) or (FRecordPos >= FRecords.Count) then
        Result := grError
      Else If Filtered then
        If not RecordFilter then
          Result := grError;
    gmNext:
      If FRecordPos >= FRecords.Count - 1 then
        Result := grEOF
      Else
      Begin
        repeat
          Inc(FRecordPos);
          If Filtered then
            Accept := RecordFilter;
        until Accept or (FRecordPos > FRecords.Count - 1);
        If not Accept then
        Begin
          Result := grEOF;
          FRecordPos := RecordCount - 1;
        End;
      End;
  End;
  If (Result = grOk) Then
    RecordToBuffer(Records[FRecordPos], PRESTDWMTMemBuffer(Buffer))
  Else If (Result = grError) and DoCheck then
    Error(RsEMemNoRecords);
End;

Procedure TRESTDWMemTable.GetBookmarkData(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}; Data: TRESTDWMTBookmark);
Begin
  Move(PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData,
    TRESTDWMTBookmarkData({$IFDEF RTL240_UP}Pointer(@Data[0]){$ELSE}Data{$ENDIF RTL240_UP}^),
    SizeOf(TRESTDWMTBookmarkData));
End;

Procedure TRESTDWMemTable.SetBookmarkData(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}; Data: TRESTDWMTBookmark);
Begin
  Move({$IFDEF RTL240_UP}Pointer(@Data[0]){$ELSE}Data{$ENDIF RTL240_UP}^,
    PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData, SizeOf(TRESTDWMTBookmarkData));
End;

Function TRESTDWMemTable.GetBookmarkFlag(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}): TBookmarkFlag;
Begin
  Result := PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag;
End;

Procedure TRESTDWMemTable.SetBookmarkFlag(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF}; Value: TBookmarkFlag);
Begin
  PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag := Value;
End;

Procedure TRESTDWMemTable.InternalSetToRecord(Buffer:
  {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF});
Begin
  InternalGotoBookmarkData(PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData);
End;

Procedure TRESTDWMemTable.InternalAddRecord(Buffer  : {$IFDEF FPC}Pointer{$ELSE}
                                                      {$IFDEF RESTDWANDROID}TRecBuf{$ELSE}
                                                      {$IF CompilerVersion >22}Pointer{$ELSE}TRecordBuffer{$IFEND}{$ENDIF}{$ENDIF};
                                            aAppend : Boolean);
var
  RecPos: Integer;
  Rec: TRESTDWMTMemoryRecord;
Begin
  If aAppend then
  Begin
    Rec := AddRecord;
    FRecordPos := FRecords.Count - 1;
  End
  Else
  Begin
    If FRecordPos = -1 then
      RecPos := 0
    Else
      RecPos := FRecordPos;
    Rec := InsertRecord(RecPos);
    FRecordPos := RecPos;
  End;
  SetAutoIncFields({$IFDEF RESTDWANDROID}PRESTDWMTMemBuffer(Buffer){$ELSE}Buffer{$ENDIF});
  SetMemoryRecordData({$IFDEF RESTDWANDROID}PRESTDWMTMemBuffer(Buffer){$ELSE}Buffer{$ENDIF}, Rec.Index);
End;

Procedure TRESTDWMemTable.RecordToBuffer(Rec: TRESTDWMTMemoryRecord; Buffer: PRESTDWMTMemBuffer);
var
  I: Integer;
Begin
  // Buffer := Rec.Data;
  Move(Rec.Data^, Buffer^, FRecordSize);
  with PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do
  Begin
    BookmarkData := Rec.ID;
    BookmarkFlag := bfCurrent;
  End;
  // For I := 0 to BlobFieldCount - 1 do
  // PMemBlobArray(Rec.FBlobs)^[I] := PMemBlobArray(Buffer)^[I];
  // For I := 0 To BlobFieldCount - 1 Do
  // PMemBlobArray(Buffer + FBlobOfs)[I] := PMemBlobArray(Rec.FBlobs)[I];
  GetCalcFields({$IFNDEF FPC}{$IFDEF NEXTGEN}TRecBuf{$ELSE}
{$IF CompilerVersion <= 22}Pointer
{$ELSE}TRecordBuffer
{$IFEND}
{$ENDIF}{$ELSE}TRecordBuffer{$ENDIF}(Buffer));
End;

Function TRESTDWMemTable.GetRecordSize: Word;
Begin
  Result := FRecordSize;
End;

Function TRESTDWMemTable.GetActiveRecBuf(Var RecBuf: PRESTDWMTMemBuffer): Boolean;
Begin
  case State of
    dsBrowse:
      If IsEmpty then
        RecBuf := nil
      Else
        RecBuf := PRESTDWMTMemBuffer(ActiveBuffer);
    dsEdit, dsInsert:
      RecBuf := PRESTDWMTMemBuffer(ActiveBuffer);
    dsCalcFields:
      RecBuf := PRESTDWMTMemBuffer(CalcBuffer);
    dsFilter:
      RecBuf := PRESTDWMTMemBuffer(TempBuffer);
  Else
    RecBuf := nil;
  End;
  Result := RecBuf <> nil;
End;

Function TRESTDWMemTable.InternalGetFieldData(Field: TField;
  Var Buffer: TRESTDWMTValueBuffer): Boolean;
Var
  aNullData: Boolean;
  RecBuf: PRESTDWMTMemBuffer;
  Data: PByte;
  VarData: Variant;
  aVarData: ^TMemBlobData;
  L, cLen: Integer;
  aDataBytes,
  aBytes: TRESTDWBytes;
  pBytes: PRESTDWBytes;
  vDWFieldType : Byte;
Begin
  Result := False;
  If Not GetActiveRecBuf(RecBuf) Then
    Exit;
  If Not IsEmpty and ((Field.FieldNo > 0) or (Field.FieldKind in [fkCalculated,
    fkLookup])) Then
  Begin
    Data := FindFieldData(RecBuf, Field);
    If (Data <> nil) Or (Field is TBlobField) then
    Begin
      Result := (Field is TBlobField);
      If Not Result Then
        Result := Data <> Nil;
      cLen      := GetCalcFieldLen(Field.datatype, Field.Size);
      Case Field.datatype Of
        ftGuid:
          Result := Result and (StrLen({$IFNDEF FPC}{$IF CompilerVersion <= 22}PAnsiChar(Data)
                                       {$ELSE}PChar(Data){$IFEND}
                                       {$ELSE}PAnsiChar(Data){$ENDIF}) > 0);
        ftString, ftFixedChar
        {$IF DEFINED(FPC) OR DEFINED(DELPHI10_0UP)}
        , ftFixedWideChar, ftWideString
        {$IFEND}:
         Begin
          SetLength(aDataBytes, cLen);
          Move(Data^, aDataBytes[0], cLen);
          Result := Result and (not (Char(aDataBytes[0]) = #0));
         End;
        ftWord, 
        {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         ftByte, ftShortint, ftLongWord, ftExtended,  ftSingle,
         {$IFEND}
        {$ENDIF}
          ftAutoInc, ftLargeint, ftInteger, ftSmallint, ftFloat, ftFMTBCD, ftBCD, ftCurrency, ftDate,
          ftTime, ftDateTime, ftTimestamp, ftBoolean:
          Begin
            {$IFNDEF FPC}
              {$IF CompilerVersion > 21}
               If Not (Field.datatype in  [ftByte, ftShortint]) then
               Begin
                Result := Not(Result);
                If Not(Result) then
                 Begin
                  aNullData := False;
                  SetLength(aDataBytes, cLen);
                  Move(Data^, aDataBytes[0], cLen);
                  Move(aDataBytes[0], Pointer(@aNullData)^, SizeOf(Boolean));
                  Result := Not(aNullData);
                 End;
               End
              Else
              {$IFEND}
             Result := Not((Result) and({$IFNDEF FPC}{$IF CompilerVersion <= 22}Char(Data^){$ELSE}Chr(Data[0]){$IFEND}{$ELSE}Char(Data^){$ENDIF} = 'S'));
            {$ELSE}
             Result := Not(Result);
             If Not(Result) then
              Begin
               aNullData := False;
               SetLength(aDataBytes, cLen);
               Move(Data^, aDataBytes[0], cLen);
               Move(aDataBytes[0], Pointer(@aNullData)^, SizeOf(Boolean));
               Result := Not(aNullData);
              End;
            {$ENDIF}
          End;
      End;

      aNullData := Not Result;
      If Result Then
      Begin
        If Field.datatype = ftVariant Then
        Begin
          VarData := PVariant(Data)^;
          PVariant(Buffer)^ := VarData;
        End
        Else If DataTypeIsBlobTypes(Field.datatype) Then
        Begin
          // Novo Codigo
          If State in [dsBrowse] Then
          Begin

            aBytes := PMemBlobArray(Records[RecNo - 1].Blobs)^[Field.Offset];
            If Length(aBytes) > 0 Then
            Begin
{$IFNDEF FPC}
{$IF CompilerVersion <= 22}
              SetLength(TRESTDWBytes(Buffer), Length(aBytes));
              Move(aBytes[0], Buffer^, Length(aBytes));
{$ELSE}
              SetLength(Buffer, Length(aBytes));
              Move(aBytes[0], Buffer[0], Length(aBytes));
{$IFEND}
{$ELSE}
              SetLength(TRESTDWBytes(Buffer), Length(aBytes));
              Move(aBytes[0], Buffer^, Length(aBytes));
{$ENDIF}
            End
            Else
              Result := False;
          End
          Else If State in [dsEdit] Then
          Begin
            Result := True;
            aBytes := PMemBlobArray(Records[RecNo - 1].Blobs)^[Field.Offset];
            If Length(TRESTDWBytes(Buffer)) > 0 Then
            Begin
              pBytes := Pointer(@PMemBlobArray(Records[RecNo - 1].Blobs)^[Field.Offset]);
              If Length(pBytes^) = 0 Then
              Begin
                SetLength(pBytes^, 0);
                SetLength(pBytes^, Length(aBytes));
              End;
              Move(aBytes[0], pBytes^, Length(aBytes));
            End
            Else If Length(aBytes) > 0 Then
            Begin
{$IFNDEF FPC}
{$IF CompilerVersion <= 22}
              SetLength(TRESTDWBytes(Buffer), Length(aBytes));
              Move(aBytes[0], Buffer^, Length(aBytes));
{$ELSE}
              SetLength(Buffer, Length(aBytes));
              Move(aBytes[0], Buffer[0], Length(aBytes));
{$IFEND}
{$ELSE}
              SetLength(TRESTDWBytes(Buffer), Length(aBytes));
              Move(aBytes[0], Buffer^, Length(aBytes));
{$ENDIF}
            End
            Else
              Result := False;
          End
         Else If State in [dsInsert] Then
          Result := False;
        End
        Else
        Begin
          cLen := GetCalcFieldLen(Field.datatype, Field.Size);
          {$IFNDEF FPC}
           {$IF CompilerVersion <= 22}
            If Result Then
             Result := ((Not(aNullData)) and Not(VarIsNull(Data^)));
            If (Field.datatype In [ftLargeint, ftInteger, ftSmallint, ftFloat, ftFMTBCD, ftBCD, ftCurrency, ftDate,
                                   ftTime]) Then
             Result := PRESTDWBytes(@Data)^[1] > 0;
            If Result Then
             Begin
              If (Field.datatype In [ftLargeint, ftInteger, ftSmallint, ftFloat, ftFMTBCD, ftBCD, ftCurrency, ftDate,
                                     ftTime, ftDateTime, ftTimestamp]) Then
               Move(PRESTDWBytes(@Data)^[1], Pointer(Buffer)^, cLen-1)
              Else
               Move(PRESTDWBytes(@Data)^[0], Pointer(Buffer)^, cLen);
             End;
           {$ELSE}
            If Length(TRESTDWBytes(Buffer)) = 0 Then
              SetLength(TRESTDWBytes(Buffer), cLen);
            Result := ((Not(aNullData)) and Not(VarIsNull(Data^)));
            If (Field.datatype In [ftAutoInc, ftLargeint, ftInteger, ftSmallint, ftFloat, ftSingle, ftFMTBCD, ftBCD, ftCurrency, ftDate,
                                      ftTime, ftDateTime, ftTimestamp]) Then
             Move(aDataBytes[1], Pointer(Buffer)^, cLen-1)
            Else
             Move(aDataBytes[0], Pointer(Buffer)^, cLen);
           {$IFEND}
          {$ELSE}
           If Length(TRESTDWBytes(Buffer)) = 0 Then
            SetLength(TRESTDWBytes(Buffer), cLen);
           Result := ((Not(aNullData)) and Not(VarIsNull(Data^)));
           If (Field.datatype In [ftAutoInc, ftLargeint, ftInteger, ftSmallint, ftFloat{$IFNDEF FPC}, ftSingle {$ENDIF}, ftFMTBCD, ftBCD, ftCurrency, ftDate,
                                    ftTime, ftDateTime, ftTimestamp]) Then
            Move(aDataBytes[1], Buffer^, cLen-1)
           Else
            Move(aDataBytes[0], Buffer^, cLen);
          {$ENDIF}
        End;
      End
     Else
      Result := False;
    End;
  End
  Else
  Begin
    If State in [dsBrowse, dsEdit, dsInsert, dsCalcFields, dsfilter] Then
    Begin
      If Not DataTypeIsBlobTypes(Field.datatype) Then
      Begin
       Data := FindFieldData(RecBuf, Field);
       cLen      := GetCalcFieldLen(Field.datatype, Field.Size);
        SetLength(aDataBytes, cLen);
        Move(Data^, aDataBytes[0], cLen);
        Result := ((Not(aNullData)) and Not(VarIsNull(Data^)));
        If (Field.datatype In [ftAutoInc, ftLargeint, ftInteger, ftSmallint, ftFloat
         {$IFNDEF FPC}{$IFDEF DELPHI10_0UP}
                       , ftSingle
                      {$ENDIF DELPHI10_0UP}
         {$ENDIF},
         ftFMTBCD, ftBCD, ftCurrency, ftDate,
                              ftTime, ftDateTime, ftTimestamp]) Then
        Move(aDataBytes[1], Pointer(Buffer)^, cLen-1)
        Else
        Move(aDataBytes[0], Pointer(Buffer)^, cLen);
       End
       Else
        Begin
         Inc(RecBuf, FRecordSize + Field.Offset);
         Result := Byte(RecBuf[0]) <> 0;
         If Result Then
             Begin
               {$IFNDEF FPC}
               {$IF CompilerVersion <= 22}
                   Move(RecBuf[1], Buffer^, Field.DataSize);
               {$ELSE}
                   Move(RecBuf[1], Buffer[0], Field.DataSize);
               {$IFEND}
               {$ELSE}
                         Move(RecBuf[1], Buffer^, Field.DataSize);
               {$ENDIF}
             End;
        End;
    End;
  End;
End;

Function TRESTDWMemTable.GetFieldData(Field: TField;
  {$IFNDEF FPC}{$IF CompilerVersion > 21}Var
  {$IFEND}Buffer: TRESTDWMTValueBuffer{$ELSE}Buffer: Pointer{$ENDIF}): Boolean;
{$IFNDEF FPC}
{$IF CompilerVersion < 21}
Type
  PValueBuffer = ^TValueBuffer;
  TValueBuffer = Array of Byte;
Var
  aPointer: Pointer;
  aDummyVar: PValueBuffer;
  aEnterpointer: Boolean;
{$IFEND}
{$ENDIF}
Begin
{$IFNDEF FPC}
{$IF CompilerVersion < 21}
  aEnterpointer := False;
  If Not Assigned(Buffer) Then
  Begin
    aEnterpointer := True;
    aDummyVar := AllocMem(SizeOf(TValueBuffer));
    aPointer := @aDummyVar;
  End
  Else
    aPointer := @Buffer;
  Result := InternalGetFieldData(Field, TRESTDWMTValueBuffer(aPointer^));
  If aEnterpointer Then
  Begin
    SetLength(aDummyVar^, 0);
    FreeMem(aDummyVar);
  End;
{$ELSE}
  Result := InternalGetFieldData(Field, TRESTDWMTValueBuffer(Buffer));
{$IFEND}
{$ELSE}
  Result := InternalGetFieldData(Field, TRESTDWMTValueBuffer(Buffer));
{$ENDIF}
End;
{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

Function TRESTDWMemTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
Var
  aPointer: Pointer;
Begin
  aPointer := @Buffer;
  Result := InternalGetFieldData(Field, TRESTDWMTValueBuffer(aPointer^));
End;
{$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}

Procedure TRESTDWMemTable.InternalSetFieldData(Field: TField; Buffer: Pointer;
  Const ValidateBuffer: TRESTDWMTValueBuffer);
Var
  PActualRecord: PRESTDWMTMemBuffer;
  Data: {$IFDEF FPC} PAnsiChar {$ELSE} PByte {$ENDIF};
  aBytes: TRESTDWBytes;
  pBytes: PRESTDWBytes;
  VarData: Variant;
  aResult, vBoolean, IsData: Boolean;
  aIndex, cLen: Integer;
  aDataType: TFieldType;
Begin
  IsData := False;
  vBoolean := True;
  If Not(State in dsWriteModes) Then
    Error('Not Editing...');
  GetActiveRecBuf(PActualRecord);
  aResult := False;
  If Field.FieldNo > 0 then
  Begin
    aDataType := Field.datatype;
    If State In [dsCalcFields, dsFilter] Then
      Error('Not Editing...');
    If Field.ReadOnly And Not(State In [dsSetKey, dsFilter]) Then
      ErrorFmt('The Field %s is readonly...', [Field.DisplayName]);
    Field.Validate(ValidateBuffer);
    // The non-NEXTGEN Pointer version has "TArray<Byte> := Pointer" in it what interprets an untypes pointer as dyn. array. Not good.
    If Field.FieldKind <> fkInternalCalc Then
    Begin
      aIndex := Field.FieldNo - 1;
      Data := FindFieldData(PActualRecord, Field);
      If (Data <> Nil) Or (Field Is TBlobField) Then
      Begin
        aResult := (Field is TBlobField);
        If Data <> Nil Then
        Begin
          If Not aResult Then
            aResult := Data <> Nil;
        End;
        If aResult Then
        Begin
          If Field.datatype = ftVariant Then
          Begin
            VarData := PVariant(Buffer)^;
            PVariant(Data)^ := VarData;
          End
          Else If DataTypeIsBlobTypes(Field.datatype) Then
          Begin
            SetLength(aBytes, Length(TRESTDWBytes(Buffer)));
{$IFNDEF FPC}
{$IF CompilerVersion <= 22}
            Move(Buffer^, aBytes[0], Length(aBytes));
{$ELSE}
            Move(TRESTDWBytes(Buffer)[0], aBytes[0], Length(aBytes));
{$IFEND}
{$ELSE}
            Move(Buffer^, aBytes[0], Length(aBytes));
{$ENDIF}
            If Length(aBytes) > 0 Then
            Begin
              pBytes := Pointer(@PMemBlobArray(Records[RecNo - 1].Blobs)^[Field.Offset]);
              If Length(pBytes^) = 0 Then
              Begin
                SetLength(pBytes^, 0);
                SetLength(pBytes^, Length(aBytes));
              End;
              Move(aBytes[0], pBytes^, Length(aBytes));
            End;
          End
          Else
          Begin
            If Length(TRESTDWBytes(Buffer)) = 0 Then
            Begin
              If Field.datatype in [ftWord, ftAutoInc,
{$IFNDEF FPC}
{$IF CompilerVersion > 21}
              ftByte, ftShortint, ftLongWord, ftExtended,  ftSingle,
{$IFEND}
{$ENDIF}
             ftLargeint, ftInteger, ftSmallint, ftFloat, ftFMTBCD, ftBCD, ftCurrency, ftDate,
          ftTime, ftDateTime, ftTimestamp] Then
              Begin
               {$IFNDEF FPC}
               {$IF CompilerVersion > 21}
                If Not (Field.datatype in  [ftByte, ftShortint]) then
                 Begin
                  Move(vBoolean, Data^, SizeOf(Boolean));
                  Inc(Data^);
                 End;
               {$IFEND}
               {$ELSE}
                Move(vBoolean, Data^, SizeOf(Boolean));
                Inc(Data^);
               {$ENDIF}

{$IFDEF FPC}
                FillChar(Data^, 1, 'S');
{$ELSE}
                FillChar(Data^, 1, 'S');
{$ENDIF}
              End;
            End
            Else
            Begin
              cLen := GetCalcFieldLen(Field.datatype, Field.Size);
              Case FieldTypeToDWFieldType(aDataType) of
                dwftWideString, dwftFixedWideChar, dwftFixedChar, dwftString:
                  Begin
{$IFDEF FPC}
                    FillChar(Data^, cLen, #0);
{$ELSE}
                    FillChar(Data^, cLen, 0);

{$ENDIF}            Move(buffer^, data^, cLen);
                  End;

                  dwftWord, dwftAutoInc,
    {$IFNDEF FPC}
    {$IF CompilerVersion > 21}
                  dwftByte, dwftShortint, dwftLongWord, dwftExtended, dwftSingle,
    {$IFEND}
    {$ENDIF}
                 dwftLargeint, dwftInteger, dwftSmallint, dwftFloat, dwftFMTBCD, dwftBCD, dwftCurrency, dwftDate,
                 dwftTime, dwftDateTime, dwftTimestamp, dwftBoolean :
                 Begin
                    vBoolean:= Length(TRESTDWBytes(Buffer)) = 0;
                    {$IFNDEF FPC}
                    {$IF CompilerVersion > 21}
                   If Not (Field.datatype in  [ftByte, ftShortint]) then
                    Begin
                     {$IFEND}
                     {$ENDIF}
                     SetLength(aBytes, cLen);
                     Move(vBoolean, aBytes[0], SizeOf(Boolean));
                     Move(TRESTDWBytes(Buffer)[0], aBytes[1], cLen-1);
                     Move(aBytes[0], data^, cLen);
                     SetLength(aBytes, 0);
                     {$IFNDEF FPC}
                     {$IF CompilerVersion > 21}
                    End
                    Else
                     Move(buffer^, data^, cLen);
                    {$IFEND}
                    {$ENDIF}
                 End;
              Else
                Move(buffer^, data^, cLen);
              End;

            End;
          End;
        End;
      End;
    End;
  End
  Else { fkCalculated, fkLookup }
  Begin
    Inc(PActualRecord, FRecordSize + Field.Offset);
    Byte(PActualRecord[0]) := Ord(Buffer <> nil);
    If Byte(PActualRecord[0]) <> 0 then
      Move(Buffer^, PActualRecord[1], Field.DataSize)
    Else
      FillChar(PActualRecord^, CalcFieldLen(Field.datatype, Field.Size), 0);
  End;
  If Not(State In [dsCalcFields, dsFilter, dsNewValue]) Then
    DataEvent(deFieldChange, NativeInt(Field));
End;

Procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: TRESTDWMTValueBuffer);
Begin
{$IFNDEF FPC}
{$IF CompilerVersion <= 22}
  If Length(TRESTDWBytes(Buffer)) > 0 Then
    InternalSetFieldData(Field,
      {$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer)
  Else
    InternalSetFieldData(Field,
      {$IFDEF RTL240_UP}PByte(@Buffer){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
{$ELSE}
  If Length(Buffer) > 0 Then
    InternalSetFieldData(Field,
       {$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP},TRESTDWMTValueBuffer(Buffer))
  Else
    InternalSetFieldData(Field,
      {$IFDEF RTL240_UP}PByte(@Buffer){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
{$IFEND}
{$ELSE}
  If Length(TRESTDWBytes(Buffer)) > 0 Then
    InternalSetFieldData(Field,
      {$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer)
  Else
    InternalSetFieldData(Field,
      {$IFDEF RTL240_UP}PByte(@Buffer){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
{$ENDIF}
End;
{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

Procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: Pointer);
var
  ValidateBuffer: TRESTDWMTValueBuffer;
Begin
  If (Buffer <> nil) and (Field.FieldNo > 0) and (Field.DataSize > 0) then
  Begin
    SetLength(ValidateBuffer, Field.DataSize);
    Move(Buffer^, ValidateBuffer[0], Field.DataSize);
  End
  Else
    ValidateBuffer := nil;
  InternalSetFieldData(Field, Buffer, ValidateBuffer);
End;
{$ENDIF RTL240_UP}
{$ENDIF ~NEXTGEN}

Procedure TRESTDWMemTable.SetFiltered(Value: Boolean);
Begin
  If Active then
  Begin
    CheckBrowseMode;
    If Filtered <> Value then
      inherited SetFiltered(Value);
    First;
  End
  Else
    inherited SetFiltered(Value);
End;

Procedure TRESTDWMemTable.SetOnFilterRecord(const Value: TFilterRecordEvent);
Begin
  If Active then
  Begin
    CheckBrowseMode;
    inherited SetOnFilterRecord(Value);
    If Filtered then
      First;
  End
  Else
    inherited SetOnFilterRecord(Value);
End;

Function TRESTDWMemTable.RecordFilter: Boolean;
var
  SaveState: TDataSetState;
Begin
  Result := True;
  If Assigned(OnFilterRecord) or (FFilterParser <> nil){$IFNDEF FPC} or
    (FFilterExpression <> nil){$ENDIF} then
  Begin
    If (FRecordPos >= 0) and (FRecordPos < RecordCount) then
    Begin
      SaveState := SetTempState(dsFilter);
      Try
        RecordToBuffer(Records[FRecordPos], PRESTDWMTMemBuffer(TempBuffer));
      {$IFDEF FPC}
        If (FFilterParser <> nil) and FFilterParser.Eval() then
        Begin
          FFilterParser.EnableWildcardMatching :=
            not(foNoPartialCompare in FilterOptions);
          FFilterParser.CaseInsensitive := foCaseInsensitive in FilterOptions;
          Result := FFilterParser.Value;
        End;
{$ELSE}
         If FFilterExpression <> nil then
          Result := FFilterExpression.Evaluate();

{$ENDIF}
        If Assigned(OnFilterRecord) then
          OnFilterRecord(Self, Result);
      Except
        AppHandleException(Self);
      End;
      RestoreState(SaveState);
    End
    Else
      Result := False;
  End;
End;

Function TRESTDWMemTable.GetBlobData(Field: TField; Buffer: PRESTDWMTMemBuffer): TMemBlobData;
Begin
  Result := PMemBlobArray(Buffer + FBlobOfs)^[Field.Offset];
End;

Procedure TRESTDWMemTable.SetBlobData(Field: TField; Buffer: PRESTDWMTMemBuffer;
  Value: TMemBlobData);
Begin
  If Buffer = PRESTDWMTMemBuffer(ActiveBuffer) then
  Begin
    If State = dsFilter then
      Error('Not Editing...');
    PMemBlobArray(Buffer + FBlobOfs)^[Field.Offset] := Value;
  End;
End;

Procedure TRESTDWMemTable.CloseBlob(Field: TField);
Begin
  If (FRecordPos >= 0) and (FRecordPos < FRecords.Count) and (State = dsEdit) then
    PMemBlobArray(ActiveBuffer + FBlobOfs)^[Field.Offset] :=
      PMemBlobArray(Records[FRecordPos].FBlobs)^[Field.Offset]
  Else
    SetLength(PMemBlobArray(ActiveBuffer + FBlobOfs)^[Field.Offset], 0);
End;

Function TRESTDWMemTable.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
Begin
  Result := TRESTDWMTMemBlobStream.Create(Field as TBlobField, Mode);
End;

Function TRESTDWMemTable.BookmarkValid(aBookmark: TBookmark): Boolean;
Begin
  Result := (aBookmark <> nil) and FActive and
    (FindRecordID({$IFDEF FPC}NativeInt(@aBookmark[0]){$ELSE}TRESTDWMTBookmarkData
    ({$IFDEF RTL200_UP}Pointer(@aBookmark[0]
    ){$ELSE}aBookmark{$ENDIF RTL200_UP}^){$ENDIF}) <> nil);
End;

Function TRESTDWMemTable.CompareBookmarks(aBookmark1, aBookmark2: TBookmark): Integer;
Begin
  If (aBookmark1 = nil) and (aBookmark2 = nil) then
    Result := 0
  Else If (aBookmark1 <> nil) and (aBookmark2 = nil) then
    Result := 1
  Else If (aBookmark1 = nil) and (aBookmark2 <> nil) then
    Result := -1
  Else If TRESTDWMTBookmarkData({$IFDEF FPC}NativeInt(@aBookmark1[0]){$ELSE}TRESTDWMTBookmarkData
    ({$IFDEF RTL200_UP}Pointer(@aBookmark1[0]
    ){$ELSE}aBookmark1{$ENDIF RTL200_UP}^){$ENDIF}) >
    TRESTDWMTBookmarkData({$IFDEF FPC}NativeInt(@aBookmark2[0]){$ELSE}TRESTDWMTBookmarkData
    ({$IFDEF RTL200_UP}Pointer(@aBookmark2[0]
    ){$ELSE}aBookmark2{$ENDIF RTL200_UP}^){$ENDIF}) then
    Result := 1
  Else If TRESTDWMTBookmarkData({$IFDEF FPC}NativeInt(@aBookmark1[0]){$ELSE}TRESTDWMTBookmarkData
    ({$IFDEF RTL200_UP}Pointer(@aBookmark1[0]
    ){$ELSE}aBookmark1{$ENDIF RTL200_UP}^){$ENDIF}) <
    TRESTDWMTBookmarkData({$IFDEF FPC}NativeInt(@aBookmark2[0]){$ELSE}TRESTDWMTBookmarkData
    ({$IFDEF RTL200_UP}Pointer(@aBookmark2[0]
    ){$ELSE}aBookmark2{$ENDIF RTL200_UP}^){$ENDIF}) then
    Result := -1
  Else
    Result := 0;
End;

{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

Procedure TRESTDWMemTable.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
var
  Bookmark: TBookmark;
Begin
  SetLength(Bookmark, SizeOf(TRESTDWMTBookmarkData));
  GetBookmarkData(Buffer, Bookmark);
  Move(Bookmark[0], Data^, SizeOf(TRESTDWMTBookmarkData));
End;

Procedure TRESTDWMemTable.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
Begin
  Move(Data^, PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData,
    SizeOf(TRESTDWMTBookmarkData));
End;
{$ENDIF RTL240_UP}
{$ENDIF !NEXTGEN}

Procedure TRESTDWMemTable.InternalGotoBookmarkData(BookmarkData: TRESTDWMTBookmarkData);
var
  Rec: TRESTDWMTMemoryRecord;
  SavePos: Integer;
  Accept: Boolean;
Begin
  Rec := FindRecordID(BookmarkData);
  If Rec <> nil then
  Begin
    Accept := True;
    SavePos := FRecordPos;
    Try
      FRecordPos := Rec.Index;
      If Filtered then
        Accept := RecordFilter;
    Finally
      If not Accept then
        FRecordPos := SavePos;
    End;
  End;
End;

Procedure TRESTDWMemTable.InternalGotoBookmark(aBookmark: TRESTDWMTBookmark);
Begin
  InternalGotoBookmarkData(TRESTDWMTBookmarkData({$IFDEF RTL240_UP}Pointer(@aBookmark[0]
    ){$ELSE}aBookmark{$ENDIF RTL240_UP}^));
End;
{$IFNDEF NEXTGEN}
{$IFDEF RTL240_UP}

Procedure TRESTDWMemTable.InternalGotoBookmark(Bookmark: Pointer);
Begin
  InternalGotoBookmarkData(TRESTDWMTBookmarkData(Bookmark^));
End;
{$ENDIF RTL240_UP}
{$ENDIF !NEXTGEN}

Procedure TRESTDWMemTable.InternalFirst;
Begin
  FRecordPos := -1;
End;

Procedure TRESTDWMemTable.InternalLast;
Begin
  FRecordPos := FRecords.Count;
End;

Function TRESTDWMemTable.GetDataset: TDataset;
Begin
  Result := TDataset(Self);
End;

Function TRESTDWMemTable.GetCalcFieldLen(FieldType: TFieldType; Size: Word): Word;
Begin
  Result := CalcFieldLen(FieldType, Size);
End;

Function TRESTDWMemTable.GetBlobRec(Field: TField; Rec: TRESTDWMTMemoryRecord): TMemBlobData;
Begin
  Result := PMemBlobArray(Rec.FBlobs)^[Field.Offset];
End;

Function TRESTDWMemTable.GetOffSets(Index: Integer): Word;
Begin
  Result := FOffsets[index];
End;

Function TRESTDWMemTable.GetOffSetsBlobs: Word;
Begin
  Result := FBlobOfs;
End;

Function TRESTDWMemTable.DataTypeIsBlobTypes(datatype: TFieldType): Boolean;
Begin
  Result := datatype in ftBlobTypes;
End;

Function TRESTDWMemTable.DataTypeSuported(datatype: TFieldType): Boolean;
Begin
  Result := datatype in ftSupported;
End;

{$IFNDEF FPC}
{$IFDEF RESTDWVCL}
// Delphi 2006+ has support for DWWideString
Procedure TRESTDWMemTable.DataConvert(Field: TField; Source, Dest: Pointer;
  ToNative: Boolean);
Begin
  If Field.datatype = ftWideString then
  Begin
    If ToNative then
    Begin
      Word(Dest^) := Length(PWideString(Source)^) * SizeOf(WideChar);
      Move(PWideChar(Source^)^, (PWideChar(Dest) + 1)^, Word(Dest^));
    End
    Else
      SetString(WideString(Dest^), PWideChar(PWideChar(Source) + 1),
        Word(Source^) div SizeOf(WideChar));
  End
  Else
    inherited DataConvert(Field, Source, Dest, ToNative);
End;
{$ENDIF ~COMPILER10_UP}
{$ELSE}

Procedure TRESTDWMemTable.DataConvert(Field: TField; Source, Dest: Pointer;
  ToNative: Boolean);
Begin
  If Field.datatype = ftFixedWideChar then
  Begin
    StrCopy(PWideChar(Dest), PWideChar(Source));
  End
  Else
    inherited DataConvert(Field, Source, Dest, ToNative);
End;
{$ENDIF}

Procedure TRESTDWMemTable.Assign(Source: TPersistent);
Begin
  If Source is TDataset then
    LoadFromDataSet(TDataset(Source), -1, lmCopy)
  Else
    inherited Assign(Source);
End;

Procedure TRESTDWMemTable.AssignMemoryRecord(Rec: TRESTDWMTMemoryRecord; Buffer: PRESTDWMTMemBuffer);
var
  I: Integer;
Begin
  Move(Buffer^, Rec.Data^, FRecordSize);
  For I := 0 to BlobFieldCount - 1 do
    PMemBlobArray(Rec.FBlobs)^[I] := PMemBlobArray(Buffer + FBlobOfs)^[I];
End;

Procedure TRESTDWMemTable.SetMemoryRecordData(Buffer: PRESTDWMTMemBuffer; Pos: Integer);
var
  Rec: TRESTDWMTMemoryRecord;
Begin
  If State = dsFilter then
    Error('Not Editing...');
  Rec := Records[Pos];
  AssignMemoryRecord(Rec, Buffer);
End;

Procedure TRESTDWMemTable.SetAutoIncFields(Buffer: PRESTDWMTMemBuffer);
var
  I, Count: Integer;
  Data: PByte;
Begin
  Count := 0;
  for I := 0 to FieldCount - 1 do
    If (Fields[I].FieldKind in fkStoredFields) and (Fields[I].datatype = ftAutoInc) then
    Begin
      Data := FindFieldData(Buffer, Fields[I]);
      If Data <> nil then
      Begin
        Data^ := Ord(True);
        Inc(Data);
        Move(FAutoInc, Data^, SizeOf(Longint));
        Inc(Count);
      End;
    End;
  If Count > 0 then
    Inc(FAutoInc);
End;

Procedure TRESTDWMemTable.InternalDelete;
var
  Accept: Boolean;
  Status: TRecordStatus;
  PFValues: TPVariant;
Begin
  Status := rsOriginal; // Disable warnings
  PFValues := nil;
  If FApplyMode <> amNone then
  Begin
    Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
    If Status <> rsInserted then
    Begin
      If FApplyMode = amAppend then
      Begin
        Cancel;
        Exit;
      End
      Else
      Begin
        New(PFValues);
        PFValues^ := GetValues;
      End;
    End;
  End;
  If FRecordPos >= FRecords.Count then
    Dec(FRecordPos);
//  Records[FRecordPos].Free;
  FRecords.Delete(FRecordPos);
  Accept := True;
  If Filtered then
   Begin
    repeat
        Accept := RecordFilter;
      If not Accept then
        Dec(FRecordPos);
    until Accept or (FRecordPos < 0);
   End
  Else
   Begin
    If FRecordPos >= 0 then
     Dec(FRecordPos);
   End;
  If FRecords.Count = 0 then
    FLastID := Low(Integer);
  If FApplyMode <> amNone then
  Begin
    If Status = rsInserted then
      Dec(FRowsChanged)
    Else
      FDeletedValues.Add(PFValues);
    If Status = rsOriginal then
      Inc(FRowsChanged);
  End;
End;

Procedure TRESTDWMemTable.InternalPost;
var
  RecPos: Integer;
  Index: Integer;
  Status: TRecordStatus;
  NewChange: Boolean;
Begin
  inherited InternalPost;
  NewChange := False;
  If (FApplyMode <> amNone) and not IsLoading then
  Begin
    Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
    (* If (State = dsEdit) and (Status In [rsInserted,rsUpdated]) then NewChange := False; *)
    If (State = dsEdit) and (Status = rsOriginal) then
    Begin
      If FApplyMode = amAppend then
      Begin
        Cancel;
        Exit;
      End
      Else
      Begin
        NewChange := True;
        FieldByName(FStatusName).AsInteger := Integer(rsUpdated);
      End;
    End;
    If State = dsInsert then
    Begin
      If IsDeleted(Index) then
      Begin
        FDeletedValues[Index] := nil;
        FDeletedValues.Delete(Index);
        If FApplyMode = amAppend then
          FieldByName(FStatusName).AsInteger := Integer(rsInserted)
        Else
          FieldByName(FStatusName).AsInteger := Integer(rsUpdated);
      End
      Else
      Begin
        NewChange := True;
        FieldByName(FStatusName).AsInteger := Integer(rsInserted);
      End;
    End;
  End;
  If State = dsEdit then
    SetMemoryRecordData(PRESTDWMTMemBuffer(ActiveBuffer), FRecordPos)
  Else
  Begin
    If State in [dsInsert] then
      SetAutoIncFields(PRESTDWMTMemBuffer(ActiveBuffer));
    If FRecordPos >= FRecords.Count then
    Begin
      AddRecord;
      FRecordPos := FRecords.Count - 1;
      SetMemoryRecordData(PRESTDWMTMemBuffer(ActiveBuffer), FRecordPos);
    End
    Else
    Begin
      If FRecordPos = -1 then
        RecPos := 0
      Else
        RecPos := FRecordPos;
      SetMemoryRecordData(PRESTDWMTMemBuffer(ActiveBuffer), InsertRecord(RecPos).Index);
      FRecordPos := RecPos;
    End;
  End;
  If NewChange then
    Inc(FRowsChanged);
End;

Procedure TRESTDWMemTable.OpenCursor(InfoQuery: Boolean);
Begin
  Try
    If FDataSet <> nil then
    Begin
      If FLoadStructure then
        CopyStructure(FDataSet, FAutoIncAsInteger)
      Else If FApplyMode <> amNone then
      Begin
        AddStatusField;
        HideStatusField;
      End;
    End;
  Except
    SysUtils.Abort;
    Exit;
  End;
  If not InfoQuery then
  Begin
    // Actual TODO Xyberx
    If FieldCount > 0 then
      FieldDefs.Clear;
    InitFieldDefsFromFields;
  End;
  FActive := True;
  inherited OpenCursor(InfoQuery);
End;

Procedure TRESTDWMemTable.InternalOpen;
Begin
  BookmarkSize := SizeOf(TRESTDWMTBookmarkData);
  FieldDefs.Updated := False;
  FieldDefs.Update;
{$IFNDEF FPC}
  FieldDefList.Update;
{$ENDIF}
{$IFNDEF HAS_AUTOMATIC_DB_FIELDS}
  If DefaultFields then
{$ENDIF !HAS_AUTOMATIC_DB_FIELDS}
    CreateFields;
  BindFields(True);
  InitBufferPointers(True);
  InternalFirst;
End;

Procedure TRESTDWMemTable.DoAfterOpen;
Begin
  If (FDataSet <> nil) and FLoadRecords then
  Begin
    If not FDataSet.Active then
      FDataSet.Open;
    FRowsOriginal := CopyFromDataSet;
    If FRowsOriginal > 0 then
    Begin
      SortOnFields();
      If FApplyMode = amAppend then
        Last
      Else
        First;
    End;
    If FDataSet.Active and FDataSetClosed then
      FDataSet.Close;
  End
  Else If not IsEmpty then
    SortOnFields();
  inherited DoAfterOpen;
End;

Procedure TRESTDWMemTable.SetFilterText(const Value: string);
  Procedure UpdateFilter;
  Begin
    FreeAndNil(FFilterParser);
{$IFNDEF FPC}
    FreeAndNil(FFilterExpression);
{$ENDIF}
    If Filter <> '' then
    Begin
{$IFNDEF FPC}
//     // If UseDataSetFilter then
       // FFilterExpression := TRESTDWMTDBFilterExpression.Create(Self, Value, FilterOptions)
          FFilterExpression:=TRDWABExprParser.Create(self,Value,FilterOptions);
//      Else
//      Begin
{$ELSE}
        FFilterParser := TExprParser.Create;
{$ENDIF}
{$IFNDEF FPC}
        //FFilterParser.OnGetVariable := ParserGetVariableValue;
{$ELSE}
        FFilterParser.OnGetVariable := @ParserGetVariableValue;
{$ENDIF}
{$IFDEF FPC}
        If foCaseInsensitive in FilterOptions then
          FFilterParser.Expression := AnsiUpperCase(Filter)
        Else
          FFilterParser.Expression := Filter;
{$ENDIF}
{$IFNDEF FPC}
     // End;
{$ENDIF}
    End;
  End;

Begin
  If Active then
  Begin
    CheckBrowseMode;
    inherited SetFilterText(Value);
    UpdateFilter;
    If Filtered then
      First;
  End
  Else
  Begin
    inherited SetFilterText(Value);
    UpdateFilter;
  End;
End;

Function TRESTDWMemTable.ParserGetVariableValue(Sender: TObject; const VarName: string;
  Var Value: Variant): Boolean;
var
  Field: TField;
Begin
  Field := FieldByName(VarName);
  If Assigned(Field) then
  Begin
    Value := Field.Value;
    Result := True;
  End
  Else
    Result := False;
End;

Procedure TRESTDWMemTable.InternalClose;
// Procedure CleanAll;
// Begin
// Try
// ClearChanges;
// If Assigned(FRecords) Then
// FreeAndNil(FRecords);
// FRecords := TList.Create;
// If Assigned(FDeletedValues) Then
// FreeAndNil(FDeletedValues);
// FDeletedValues := TList.Create;
// Finally
// ClearRecords;
// ClearBuffers;
// FRecordPos := -1;
// FLastID := Low(Integer);
// FAutoInc := 1;
// FStatusName := STATUSNAME;
// FRowsOriginal := 0;
// FRowsChanged := 0;
// FRowsAffected := 0;
// FSaveLoadState := slsNone;
// FOneValueInArray := True;
// FDataSetClosed := False;
// FRowsChanged := 0;
// FRowsAffected := 0;
// If Assigned(FRESTDWStorage) then
// FreeAndNil(FRESTDWStorage);
// FActive := False;
// End;
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

Procedure TRESTDWMemTable.InternalHandleException;
Begin
  AppHandleException(Self);
End;

Procedure TRESTDWMemTable.InternalInitFieldDefs;
Begin
  // InitFieldDefsFromFields;
End;

// Procedure TRESTDWMemTable.DesignNotify(const AFieldName: string; Dummy: Integer);
// Var
// Stream: TStream;
// Begin
// If not (csDesigning in ComponentState) then Exit;
// case Dummy of
// 100: Begin
// End;
// Else
// inherited DesignNotify(AFieldName, Dummy);
// End;
// End;

Function TRESTDWMemTable.IsCursorOpen: Boolean;
Begin
  Result := FActive;
End;

Function TRESTDWMemTable.GetRecordCount: Integer;
Begin
  Result := 0;
  If State <> dsInactive then
    Result := FRecords.Count;
End;

Function TRESTDWMemTable.GetRecNo: Integer;
Begin
  CheckActive;
  UpdateCursorPos;
  If (FRecordPos = -1) and (RecordCount > 0) then
    Result := 1
  Else
    Result := FRecordPos + 1;
End;

Procedure TRESTDWMemTable.SetRecNo(Value: Integer);
Begin
  If (Value > 0) and (Value <= FRecords.Count) then
  Begin
    DoBeforeScroll;
    FRecordPos := Value - 1;
    Resync([]);
    DoAfterScroll;
  End;
End;

Function TRESTDWMemTable.IsSequenced: Boolean;
Begin
  Result := not Filtered;
End;

{$IFDEF RESTDWLAZARUS}
Function  TRESTDWMemTable.GetDatabaseCharSet : TDatabaseCharSet;
Begin
 Result := vDatabaseCharSet;
End;

Procedure TRESTDWMemTable.SetDatabaseCharSet(Value : TDatabaseCharSet);
Begin
 vDatabaseCharSet := Value;
End;
{$ENDIF}

Function TRESTDWMemTable.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
Begin
  DoBeforeScroll;
  Result := DataSetLocateThrough(Self, KeyFields, KeyValues, Options);
  If Result then
  Begin
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
  End;
End;

Function TRESTDWMemTable.Lookup(const KeyFields: string; const KeyValues: Variant;
  const ResultFields: string): Variant;
var
  aFieldCount: Integer;
{$IFNDEF FPC}
  aFields: TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
{$ELSE}
  aFields: TFields;
{$ENDIF}
  Fld: TField; // Else BAD mem leak on 'Field.asString'
  SaveState: TDataSetState;
  I: Integer;
  Matched: Boolean;
  Function CompareField(Field: TField; Value: Variant): Boolean; { BG }
  var
    S: string;
  Begin
    If Field.datatype in [ftString{$IFDEF UNICODE}, ftWideString, ftFixedWideChar{$ENDIF}]
    then
    Begin
      If Value = Null then
        Result := Field.IsNull
      Else
      Begin
        S := Field.AsString;
        Result := AnsiSameStr(S, Value);
      End;
    End
    Else
      Result := (Field.Value = Value);
  End;
  Function CompareRecord: Boolean;
  var
    I: Integer;
  Begin
    If aFieldCount = 1 then
    Begin
      Fld := TField(Fields[0]);
      Result := CompareField(Fld, KeyValues);
    End
    Else
    Begin
      Result := True;
      for I := 0 to aFieldCount - 1 do
      Begin
        Fld := TField(Fields[I]);
        Result := Result and CompareField(Fld, KeyValues[I]);
      End;
    End;
  End;

Begin
  Result := Null;
  CheckBrowseMode;
  // Actual TODO Xyberx
  If IsEmpty Then
    Exit;
{$IFNDEF FPC}
  aFields := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
{$ELSE}
    aFields := TFields.Create(Nil);
{$ENDIF}
  Try
{$IFNDEF FPC}
    GetFieldList(aFields, KeyFields);
{$ELSE}
    GetFieldList(TList(aFields), KeyFields);
{$ENDIF}
    aFieldCount := aFields.Count;
    Matched := CompareRecord;
    If Matched Then
      Result := ToBytes(FieldValues[ResultFields])
    Else
    Begin
      SaveState := SetTempState(dsCalcFields);
      Try
        Try
          For I := 0 To RecordCount - 1 Do
          Begin
            RecordToBuffer(Records[I], PRESTDWMTMemBuffer(TempBuffer));
            CalculateFields(TempBuffer);
            Matched := CompareRecord;
            If Matched Then
              Break;
          End;
        Finally
          If Matched Then
            Result := ToBytes(FieldValues[ResultFields]);
        End;
      Finally
        RestoreState(SaveState);
      End;
    End;
  Finally
    FreeAndNil(aFields);
  End;
End;

Procedure TRESTDWMemTable.AfterLoad;
Begin
  Try
    SetState(dsInactive);
  Finally
    SetState(dsBrowse);
  End;
End;

Procedure TRESTDWMemTable.Notification(AComponent: TComponent; Operation: TOperation);
Begin
  inherited Notification(AComponent, Operation);
End;

Procedure TRESTDWMemTable.EmptyTable;
Begin
  If Active then
  Begin
    CheckBrowseMode;
    ClearRecords;
    ClearBuffers;
    DataEvent(deDataSetChange, 0);
  End;
End;

Procedure TRESTDWMemTable.AddStatusField;
Begin
  // Check If FieldStatus not exists in FieldDefs
  If (FieldDefs.Count > 0) and not(FieldDefs[FieldDefs.Count - 1].Name = FStatusName) then
    FieldDefs.Add(FStatusName, ftSmallint);
End;

Procedure TRESTDWMemTable.HideStatusField;
Begin
  // Check If FieldStatus already exists in FieldDefs
  If (FieldDefs.Count > 0) and (FieldDefs[FieldDefs.Count - 1].Name = FStatusName) then
  Begin
    FieldDefs[FieldDefs.Count - 1].Attributes := [faHiddenCol]; // Hide in FieldDefs
    // Check If FieldStatus not exists in Fields
    If not(Fields[Fields.Count - 1].FieldName = FStatusName) then
      FieldDefs[FieldDefs.Count - 1].CreateField(Self);
    Fields[Fields.Count - 1].Visible := False; // Hide in Fields
  End;
End;

Procedure TRESTDWMemTable.CheckStructure(UseAutoIncAsInteger: Boolean);
  Procedure CheckDataTypes(FieldDefs: TFieldDefs);
  var
    J: Integer;
  Begin
    for J := FieldDefs.Count - 1 downto 0 do
    Begin
      If (FieldDefs.Items[J].datatype = ftAutoInc) and UseAutoIncAsInteger then
        FieldDefs.Items[J].datatype := ftInteger;
      If not(FieldDefs.Items[J].datatype in ftSupported) then
        FieldDefs.Items[J].Free;
    End;
  End;

var
  I: Integer;
Begin
  CheckDataTypes(FieldDefs);
  for I := 0 to FieldDefs.Count - 1 do
    If (csDesigning in ComponentState) and (Owner <> nil) then
      FieldDefs.Items[I].CreateField(Owner)
    Else
      FieldDefs.Items[I].CreateField(Self);
End;

Procedure TRESTDWMemTable.ClearBuffer;
Begin
  ClearRecords;
  ClearBuffers;
  DataEvent(deDataSetChange, 0);
End;

Procedure TRESTDWMemTable.FixReadOnlyFields(MakeReadOnly: Boolean);
var
  I: Integer;
Begin
  If MakeReadOnly then
    for I := 0 to FieldCount - 1 do
      Fields[I].ReadOnly := (Fields[I].Tag = 1)
  Else
    for I := 0 to FieldCount - 1 do
    Begin
      Fields[I].Tag := Ord(Fields[I].ReadOnly);
      Fields[I].ReadOnly := False;
    End;
End;

Procedure TRESTDWMemTable.CopyStructure(Source: TDataset; UseAutoIncAsInteger: Boolean);
var
  I: Integer;
Begin
  If Source = nil then
    Exit;
  CheckInactive;
  for I := FieldCount - 1 downto 0 do
    Fields[I].Free;
  Source.FieldDefs.Update;
  FieldDefs := Source.FieldDefs;
  If FApplyMode <> amNone then
    AddStatusField;
  CheckStructure(UseAutoIncAsInteger);
  If FApplyMode <> amNone then
    HideStatusField;
End;

Function TRESTDWMemTable.LoadFromDataSet(Source: TDataset; aRecordCount: Integer;
  Mode: TLoadMode; DisableAllControls: Boolean = True): Integer;
var
  MovedCount, I, FinalAutoInc: Integer;
  SB, DB: TBookmark;
Begin
  Result := 0;
  If Source = Self then
    Exit;
  FSaveLoadState := slsLoading;
  // ********** Source *********
  If DisableAllControls then
    Source.DisableControls;
  If not Source.Active then
    Source.Open
  Else
    Source.CheckBrowseMode;
  Source.UpdateCursorPos;
  SB := Source.GetBookmark;
  // ***************************
  Try
    // ********** Dest (self) ***********
    If DisableAllControls then
      DisableControls;
    Filtered := False;
    If Mode = lmCopy then
    Begin
      Close;
      CopyStructure(Source, FAutoIncAsInteger);
    End;
    FreeIndexList;
    If not Active then
      Open
    Else
      CheckBrowseMode;
    DB := GetBookmark;
    // **********************************
    Try
      If aRecordCount > 0 then
        MovedCount := aRecordCount
      Else
      Begin
        Source.First;
        MovedCount := MaxInt;
      End;
      FinalAutoInc := 0;
      FixReadOnlyFields(False);
      // find first source autoinc field
      FSrcAutoIncField := nil;
      If Mode = lmCopy then
        for I := 0 to Source.FieldCount - 1 do
          If Source.Fields[I].datatype = ftAutoInc then
          Begin
            FSrcAutoIncField := Source.Fields[I];
            Break;
          End;
      Try
        while not Source.EOF do
        Begin
          AppEnd;
          AssignRecord(Source, Self, True);
          // assign AutoInc value manually (make user keep largest If source isn't sorted by autoinc field)
          If FSrcAutoIncField <> nil then
          Begin
            FinalAutoInc := Max(FinalAutoInc, FSrcAutoIncField.AsInteger);
            FAutoInc := FSrcAutoIncField.AsInteger;
          End;
          If (Mode = lmCopy) and (FApplyMode <> amNone) then
            FieldByName(FStatusName).AsInteger := Integer(rsOriginal);
          Post;
          Inc(Result);
          If Result >= MovedCount then
            Break;
          Source.Next;
        End;
      Finally
        If (Mode = lmCopy) and (FApplyMode <> amNone) then
        Begin
          FRowsOriginal := Result;
          FRowsChanged := 0;
          FRowsAffected := 0;
        End;
        FixReadOnlyFields(True);
        If Mode = lmCopy then
          FAutoInc := FinalAutoInc + 1;
        FSrcAutoIncField := nil;
        First;
      End;
    Finally
      // ********** Dest (self) ***********
      // move back to where we started from
      If (DB <> nil) and BookmarkValid(DB) then
      Begin
        GotoBookmark(DB);
        FreeBookmark(DB);
      End;
      If DisableAllControls then
        EnableControls;
      // **********************************
    End;
  Finally
    // ************** Source **************
    // move back to where we started from
    If (SB <> nil) and Source.BookmarkValid(SB) and not Source.IsEmpty then
    Begin
      Source.GotoBookmark(SB);
      Source.FreeBookmark(SB);
    End;
    If Source.Active and FDataSetClosed then
      Source.Close;
    If DisableAllControls then
      Source.EnableControls;
    // ************************************
    FSaveLoadState := slsNone;
  End;
End;

Procedure TRESTDWMemTable.LoadFromStream(stream: TStream);
var
  stor: TRESTDWStorageBin;
Begin
  If FStorageDataType = nil then
  Begin
    stor := TRESTDWStorageBin.Create(nil);
    Try
      stor.LoadFromStream(Self, stream);
    Finally
      stor.Free;
    End;
  End
  Else
  Begin
    FStorageDataType.LoadFromStream(Self, stream);
  End;
End;

Function TRESTDWMemTable.SaveToDataSet(Dest: TDataset; aRecordCount: Integer;
  DisableAllControls: Boolean = True): Integer;
var
  MovedCount: Integer;
  SB, DB: TBookmark;
  Status: TRecordStatus;
Begin
  Result := 0;
  FRowsAffected := Result;
  If Dest = Self then
    Exit;
  FSaveLoadState := slsSaving;
  // *********** Dest ************
  If DisableAllControls then
    Dest.DisableControls;
  If not Dest.Active then
    Dest.Open
  Else
    Dest.CheckBrowseMode;
  Dest.UpdateCursorPos;
  DB := Dest.GetBookmark;
  SB := nil;
  // *****************************
  Try
    // *********** Source (self) ************
    If DisableAllControls then
      DisableControls;
    CheckBrowseMode;
    If FApplyMode <> amNone then
    Begin
      FRowsChanged := Self.RecordCount;
      DoBeforeApply(Dest, FRowsChanged);
    End
    Else
    Begin
      SB := GetBookmark;
    End;
    // **************************************
    Try
      If aRecordCount > 0 then
        MovedCount := aRecordCount
      Else
      Begin
        First;
        MovedCount := MaxInt;
      End;
      Status := rsOriginal; // Disable warnings
      Try
        while not EOF do
        Begin
          If FApplyMode <> amNone then
          Begin
            Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
            DoBeforeApplyRecord(Dest, Status, True);
          End;
          Dest.AppEnd;
          AssignRecord(Self, Dest, True);
          Dest.Post;
          Inc(Result);
          If FApplyMode <> amNone then
            DoAfterApplyRecord(Dest, Status, True);
          If Result >= MovedCount then
            Break;
          Next;
        End;
      Finally
        If FApplyMode <> amNone then
        Begin
          FRowsAffected := Result;
          DoAfterApply(Dest, FRowsAffected);
          If Result > 0 then
            ClearChanges;
          FRowsAffected := 0;
          FRowsChanged := 0;
        End
      End;
    Finally
      // *********** Source (self) ************
      If (FApplyMode = amNone) and (SB <> nil) and BookmarkValid(SB) then
      Begin
        GotoBookmark(SB);
        FreeBookmark(SB);
      End;
      If DisableAllControls then
        EnableControls;
      // **************************************
    End;
  Finally
    // ******************* Dest *******************
    // move back to where we started from
    If (DB <> nil) and Dest.BookmarkValid(DB) and not Dest.IsEmpty then
    Begin
      Dest.GotoBookmark(DB);
      Dest.FreeBookmark(DB);
    End;
    If Dest.Active and FDataSetClosed then
      Dest.Close;
    If DisableAllControls then
      Dest.EnableControls;
    // ********************************************
    FSaveLoadState := slsNone;
  End;
End;

Procedure TRESTDWMemTable.SaveToStream(Var stream: TStream);
var
  stor: TRESTDWStorageBin;
Begin
  If FStorageDataType = nil then
  Begin
    stor := TRESTDWStorageBin.Create(nil);
    Try
      stor.SaveToStream(TDataset(Self), stream);
    Finally
      stor.Free;
    End;
  End
  Else
  Begin
    FStorageDataType.SaveToStream(TDataset(Self), stream);
  End;
End;

Procedure TRESTDWMemTable.SortOnFields(const FieldNames: string = '';
  CaseInsensitive: Boolean = True; Descending: Boolean = False);
Begin
  // Post the table before sorting
  If State in dsEditModes then
    Post;
  If FieldNames <> '' then
    CreateIndexList(FieldNames)
  Else If FKeyFieldNames <> '' then
    CreateIndexList(FKeyFieldNames)
  Else
    Exit;
  FCaseInsensitiveSort := CaseInsensitive;
  FDescendingSort := Descending;
  Try
    Sort;
  Except
    FreeIndexList;
    raise;
  End;
End;

Procedure TRESTDWMemTable.SwapRecords(Idx1, Idx2: Integer);
Begin
  FRecords.Exchange(Idx1, Idx2);
End;

Procedure TRESTDWMemTable.Sort;
var
  Pos: {$IFDEF FPC}TBookmark
{$ELSE}
{$IFDEF DELPHI10_0UP}DB.TBookmark{$ELSE}TBookmarkStr{$ENDIF DELPHI10_0UP}
{$ENDIF};
Begin
  If Active and (FRecords <> nil) and (FRecords.Count > 0) then
  Begin
    Pos := Bookmark;
    Try
{$IFDEF FPC}
      QuickSort(0, FRecords.Count - 1, @CompareRecords);
{$ELSE}
      QuickSort(0, FRecords.Count - 1, CompareRecords);
{$ENDIF}
      SetBufListSize(0);
      InitBufferPointers(False);
      Try
        SetBufListSize(BufferCount + 1);
      Except
        SetState(dsInactive);
        CloseCursor;
        raise;
      End;
    Finally
      Bookmark := Pos;
    End;
    Resync([]);
  End;
End;

Procedure TRESTDWMemTable.QuickSort(L, R: Integer; Compare: TCompareRecords);
var
  I, J: Integer;
  P: TRESTDWMTMemoryRecord;
Begin
  repeat
    I := L;
    J := R;
    P := Records[(L + R) shr 1];
    repeat
      while Compare(Records[I], P) < 0 do
        Inc(I);
      while Compare(Records[J], P) > 0 do
        Dec(J);
      If I <= J then
      Begin
        FRecords.Exchange(I, J);
        Inc(I);
        Dec(J);
      End;
    until I > J;
    If L < J then
      QuickSort(L, J, Compare);
    L := I;
  until I >= R;
End;

Function TRESTDWMemTable.CompareRecords(Item1, Item2: TRESTDWMTMemoryRecord): Integer;
var
  Data1, Data2: PByte;
  CData1, CData2, Buffer1, Buffer2: array [0 .. dsMaxStringSize] of Byte;
  F: TField;
  I: Integer;
Begin
  Result := 0;
  If FIndexList <> nil then
  Begin
    for I := 0 to FIndexList.Count - 1 do
    Begin
      F := TField(FIndexList[I]);
      If F.FieldKind = fkData then
      Begin
        Data1 := FindFieldData(Item1.Data, F);
        If Data1 <> nil then
        Begin
          Data2 := FindFieldData(Item2.Data, F);
          If Data2 <> nil then
          Begin
            If Boolean(Data1^) and Boolean(Data2^) then
            Begin
              Inc(Data1);
              Inc(Data2);
              Result := CompareFields(Data1, Data2, F.datatype, FCaseInsensitiveSort);
            End
            Else If Boolean(Data1^) then
              Result := 1
            Else If Boolean(Data2^) then
              Result := -1;
            If FDescendingSort then
              Result := -Result;
          End;
        End;
        If Result <> 0 then
          Exit;
      End
      Else
      Begin
        FillChar(Buffer1, dsMaxStringSize, 0);
        FillChar(Buffer2, dsMaxStringSize, 0);
        RecordToBuffer(Item1, @Buffer1[0]);
        RecordToBuffer(Item2, @Buffer2[0]);
        Move(Buffer1[1 + FRecordSize + F.Offset], CData1, F.DataSize);
        If CData1[0] <> 0 then
        Begin
          Move(Buffer2[1 + FRecordSize + F.Offset], CData2, F.DataSize);
          If CData2[0] <> 0 then
          Begin
            If Boolean(CData1[0]) and Boolean(CData2[0]) then
              Result := CompareFields(@CData1, @CData2, F.datatype, FCaseInsensitiveSort)
            Else If Boolean(CData1[0]) then
              Result := 1
            Else If Boolean(CData2[0]) then
              Result := -1;
            If FDescendingSort then
              Result := -Result;
          End;
        End;
        If Result <> 0 then
          Exit;
      End;
    End;
  End;
  If Result = 0 then
  Begin
    If Item1.ID > Item2.ID then
      Result := 1
    Else If Item1.ID < Item2.ID then
      Result := -1;
    If FDescendingSort then
      Result := -Result;
  End;
End;

Function TRESTDWMemTable.GetIsIndexField(Field: TField): Boolean;
Begin
  If FIndexList <> nil then
    Result := FIndexList.IndexOf(Field) >= 0
  Else
    Result := False;
End;

Procedure TRESTDWMemTable.CreateIndexList(const FieldNames: DWWideString);
type
  TFieldTypeSet = set of TFieldType;
  Function GetSetFieldNames(const FieldTypeSet: TFieldTypeSet): string;
  var
    FieldType: TFieldType;
  Begin
    for FieldType := Low(TFieldType) to High(TFieldType) do
      If FieldType in FieldTypeSet then
        Result := Result + FieldTypeNames[FieldType] + ', ';
    Result := Copy(Result, 1, Length(Result) - 2);
  End;

var
  Pos: Integer;
  F: TField;
Begin
  If FIndexList = nil then
    FIndexList := TList.Create
  Else
    FIndexList.Clear;
  Pos := 1;
  while Pos <= Length(FieldNames) do
  Begin
    F := FieldByName(ExtractFieldNameEx(FieldNames, Pos));
    If { (F.FieldKind = fkData) and } (F.datatype in ftSupported - ftBlobTypes) then
      FIndexList.Add(F)
    Else
      ErrorFmt('Type mismatch for field %s, expecting: %s actual %s',
        [F.DisplayName, GetSetFieldNames(ftSupported - ftBlobTypes),
        FieldTypeNames[F.datatype]]);
  End;
End;

Procedure TRESTDWMemTable.FreeIndexList;
Begin
  If Assigned(FIndexList) Then
    FreeAndNil(FIndexList);
End;

Function TRESTDWMemTable.GetValues(FldNames: string = ''): Variant;
var
  I: Integer;
  List: TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
Begin
  Result := Null;
  If FldNames = '' then
    FldNames := FKeyFieldNames;
  If FldNames = '' then
    Exit;
  // Mantis 3610: If there is only one field in the dataset, return a
  // variant array with only one element. This seems to be required for
  // ADO, DBIsam, DBX and others to work.
  If Pos(';', FldNames) > 0 then
  Begin
    List := TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP}.Create;
    GetFieldList(List, FldNames);
    Result := VarArrayCreate([0, List.Count - 1], varVariant);
    for I := 0 to List.Count - 1 do
      Result[I] := TField(List[I]).Value;
    FreeAndNil(List);
  End
  Else If FOneValueInArray then
  Begin
    Result := VarArrayCreate([0, 0], varVariant);
    Result[0] := FieldByName(FldNames).Value;
  End
  Else
    Result := FieldByName(FldNames).Value;
End;

Function TRESTDWMemTable.CopyFromDataSet: Integer;
var
  I, Len, FinalAutoInc: Integer;
  Original, StatusField: TField;
  OriginalFields: array of TField;
  FieldReadOnly: Boolean;
Begin
  Result := 0;
  If FDataSet = nil then
    Exit;
  If FApplyMode <> amNone then
    Len := FieldDefs.Count - 1
  Else
    Len := FieldDefs.Count;
  If Len < 2 then
    Exit;
  Try
    If not FDataSet.Active then
      FDataSet.Open;
  Except
    Exit;
  End;
  If FDataSet.IsEmpty then
  Begin
    If FDataSet.Active and FDataSetClosed then
      FDataSet.Close;
    Exit;
  End;
  FinalAutoInc := 0;
  FDataSet.DisableControls;
  DisableControls;
  FSaveLoadState := slsLoading;
  Try
    SetLength(OriginalFields, Fields.Count);
    for I := 0 to Fields.Count - 1 do
    Begin
      If Fields[I].FieldKind <> fkCalculated then
        OriginalFields[I] := FDataSet.FindField(Fields[I].FieldName);
    End;
    StatusField := nil;
    If FApplyMode <> amNone then
      StatusField := FieldByName(FStatusName);
    // find first source autoinc field
    FSrcAutoIncField := nil;
    for I := 0 to FDataSet.FieldCount - 1 do
      If FDataSet.Fields[I].datatype = ftAutoInc then
      Begin
        FSrcAutoIncField := FDataSet.Fields[I];
        Break;
      End;
    FDataSet.First;
    while not FDataSet.EOF do
    Begin
      AppEnd;
      for I := 0 to Fields.Count - 1 do
      Begin
        If Fields[I].FieldKind <> fkCalculated then
        Begin
          Original := OriginalFields[I];
          If Original <> nil then
          Begin
            FieldReadOnly := Fields[I].ReadOnly;
            If FieldReadOnly then
              Fields[I].ReadOnly := False;
            Try
              CopyFieldValue(Fields[I], Original);
            Finally
              If FieldReadOnly then
                Fields[I].ReadOnly := True;
            End;
          End;
        End;
      End;
      // assign AutoInc value manually (make user keep largest If source isn't sorted by autoinc field)
      If FSrcAutoIncField <> nil then
      Begin
        FinalAutoInc := Max(FinalAutoInc, FSrcAutoIncField.AsInteger);
        FAutoInc := FSrcAutoIncField.AsInteger;
      End;
      If FApplyMode <> amNone then
        StatusField.AsInteger := Integer(rsOriginal);
      Post;
      Inc(Result);
      FDataSet.Next;
    End;
    FRowsChanged := 0;
    FRowsAffected := 0;
  Finally
    FAutoInc := FinalAutoInc + 1;
    FSaveLoadState := slsNone;
    EnableControls;
    FDataSet.EnableControls;
    If FDataSet.Active and FDataSetClosed then
      FDataSet.Close;
  End;
End;

Procedure TRESTDWMemTable.DoBeforeApply(ADataset: TDataset; RowsPending: Integer);
Begin
  If Assigned(FBeforeApply) then
    FBeforeApply(ADataset, RowsPending);
End;

Procedure TRESTDWMemTable.DoAfterApply(ADataset: TDataset; RowsApplied: Integer);
Begin
  If Assigned(FAfterApply) then
    FAfterApply(ADataset, RowsApplied);
End;

Procedure TRESTDWMemTable.DoBeforeApplyRecord(ADataset: TDataset; RS: TRecordStatus;
  aFound: Boolean);
Begin
  If Assigned(FBeforeApplyRecord) then
    FBeforeApplyRecord(ADataset, RS, Found);
End;

Procedure TRESTDWMemTable.DoAfterApplyRecord(ADataset: TDataset; RS: TRecordStatus;
  aApply: Boolean);
Begin
  If Assigned(FAfterApplyRecord) then
    FAfterApplyRecord(ADataset, RS, aApply);
End;

Procedure TRESTDWMemTable.ClearChanges;
var
  I: Integer;
  PFValues: TPVariant;
Begin
  If FDeletedValues.Count > 0 then
  Begin
    for I := 0 to (FDeletedValues.Count - 1) do
    Begin
      PFValues := FDeletedValues[I];
      If PFValues <> nil then
        Dispose(PFValues);
      FDeletedValues[I] := nil;
    End;
    FDeletedValues.Clear;
  End;
  EmptyTable;
  If FLoadRecords then
  Begin
    FRowsOriginal := CopyFromDataSet;
    If FRowsOriginal > 0 then
    Begin
      If FKeyFieldNames <> '' then
        SortOnFields();
      If FApplyMode = amAppend then
        Last
      Else
        First;
    End;
  End;
End;

Procedure TRESTDWMemTable.CancelChanges;
Begin
  CheckBrowseMode;
  ClearChanges;
  FRowsChanged := 0;
  FRowsAffected := 0;
End;

Function TRESTDWMemTable.ApplyChanges: Boolean;
var
  xKey: Variant;
  PxKey: TPVariant;
  Len, Row: Integer;
  Status: TRecordStatus;
  bFound, bApply: Boolean;
  FOriginal, FClient: TField;
  Function WriteFields: Boolean;
  var
    J: Integer;
  Begin
    Try
      for J := 0 to Len do
      Begin
        If (Fields[J].FieldKind = fkData) then
        Begin
          FClient := Fields[J];
          FOriginal := FDataSet.FindField(FClient.FieldName);
          If (FOriginal <> nil) and (FClient <> nil) and not FClient.ReadOnly then
          Begin
            If FClient.IsNull then
              FOriginal.Clear
            Else
              FDataSet.FieldByName(FOriginal.FieldName).Value := FClient.Value;
          End;
        End;
      End;
      Result := True;
    Except
      Result := False;
    End;
  End;
  Function InsertRec: Boolean;
  Begin
    Try
      FDataSet.AppEnd;
      WriteFields;
      FDataSet.Post;
      Result := True;
    Except
      Result := False;
    End;
  End;
  Function UpdateRec: Boolean;
  Begin
    Try
      FDataSet.Edit;
      WriteFields;
      FDataSet.Post;
      Result := True;
    Except
      Result := False;
    End;
  End;
  Function DeleteRec: Boolean;
  Begin
    Try
      FDataSet.Delete;
      Result := True;
    Except
      Result := False;
    End;
  End;
  Function SaveChanges: Integer;
  var
    I: Integer;
  Begin
    Result := 0;
    FDataSet.DisableControls;
    DisableControls;
    Row := RecNo;
    FSaveLoadState := slsSaving;
    Try
      If not IsEmpty then
        First;
      while not EOF do
      Begin
        Status := TRecordStatus(FieldByName(FStatusName).AsInteger);
        If (Status <> rsOriginal) then
        Begin
          xKey := GetValues;
          bFound := FDataSet.Locate(FKeyFieldNames, xKey, []);
          DoBeforeApplyRecord(FDataSet, Status, bFound);
          bApply := False;
          (* ******************** New Record ********************** *)
          If IsInserted then
          Begin
            If not bFound then // Not Exists in Original
            Begin
              If InsertRec then
              Begin
                Inc(Result);
                bApply := True;
              End
              Else If FExactApply then
              Begin
                Error(RsEInsertError);
                Break;
              End
              Else If (FDataSet.State in dsEditModes) then
                FDataSet.Cancel;
            End
            Else If FApplyMode = amMerge then // Exists in Original
            Begin
              If UpdateRec then
              Begin
                Inc(Result);
                bApply := True;
              End
              Else If FExactApply then
              Begin
                Error(RsEUpdateError);
                Break;
              End
              Else If (FDataSet.State in dsEditModes) then
                FDataSet.Cancel;
            End
            Else If FExactApply then
            Begin
              Error(RsERecordDuplicate);
              Break;
            End;
          End;
          (* ********************** Modified Record *********************** *)
          If IsUpdated then
          Begin
            If bFound then // Exists in Original
            Begin
              If UpdateRec then
              Begin
                Inc(Result);
                bApply := True;
              End
              Else If FExactApply then
              Begin
                Error(RsEUpdateError);
                Break;
              End
              Else If (FDataSet.State in dsEditModes) then
                FDataSet.Cancel;
            End
            Else If FApplyMode = amMerge then // Not exists in Original
            Begin
              If InsertRec then
              Begin
                Inc(Result);
                bApply := True;
              End
              Else If FExactApply then
              Begin
                Error(RsEInsertError);
                Break;
              End
              Else If FDataSet.State in dsEditModes then
                FDataSet.Cancel;
            End
            Else If FExactApply then
            Begin
              Error(RsERecordInexistent);
              Break;
            End;
          End;
          DoAfterApplyRecord(FDataSet, Status, bApply);
        End;
        Next;
      End;
      (* ********************** Deleted Records ************************* *)
      If (FApplyMode = amMerge) then
      Begin
        for I := 0 to FDeletedValues.Count - 1 do
        Begin
          Status := rsDeleted;
          PxKey := FDeletedValues[I];
          // Mantis #3974 : "FDeletedValues" is a List of Pointers, and each item have two
          // possible values... PxKey (a Variant) or NIL. The list counter is incremented
          // with the ADD() method and decremented with the DELETE() method
          If PxKey <> nil then // ONLY If FDeletedValues[I] have a value <> NIL
          Begin
            xKey := PxKey^;
            bFound := FDataSet.Locate(FKeyFieldNames, xKey, []);
            DoBeforeApplyRecord(FDataSet, Status, bFound);
            bApply := False;
            If bFound then // Exists in Original
            Begin
              If DeleteRec then
              Begin
                Inc(Result);
                bApply := True;
              End
              Else If FExactApply then
              Begin
                Error(RsEDeleteError);
                Break;
              End;
            End
            Else If FExactApply then // Not exists in Original
            Begin
              Error(RsERecordInexistent);
              Break;
            End
            Else
            Begin
              Inc(Result);
              bApply := True;
            End;
            DoAfterApplyRecord(FDataSet, Status, bApply);
          End;
        End;
      End;
    Finally
      FSaveLoadState := slsNone;
      RecNo := Row;
      EnableControls;
      FDataSet.EnableControls;
    End;
  End;

Begin
  Result := False;
  If (FDataSet = nil) or (FApplyMode = amNone) then
    Exit;
  If (FApplyMode <> amNone) and (FKeyFieldNames = '') then
    Exit;
  Len := FieldDefs.Count - 2;
  If (Len < 1) then
    Exit;
  Try
    If not FDataSet.Active then
      FDataSet.Open;
  Except
    Exit;
  End;
  CheckBrowseMode;
  DoBeforeApply(FDataSet, FRowsChanged);
  FSaveLoadState := slsSaving;
  If (FRowsChanged < 1) or (IsEmpty and (FDeletedValues.Count < 1)) then
  Begin
    FRowsAffected := 0;
    Result := (FRowsAffected = FRowsChanged);
  End
  Else
  Begin
    FRowsAffected := SaveChanges;
    Result := (FRowsAffected = FRowsChanged) or
      ((FRowsAffected > 0) and (FRowsAffected < FRowsChanged) and not FExactApply);
  End;
  FSaveLoadState := slsNone;
  DoAfterApply(FDataSet, FRowsAffected);
  If Result then
    ClearChanges;
  FRowsAffected := 0;
  FRowsChanged := 0;
  If FDataSet.Active and FDataSetClosed then
    FDataSet.Close;
End;

Function TRESTDWMemTable.FindDeleted(KeyValues: Variant): Integer;
var
  I, J, Len, aEquals: Integer;
  PxKey: TPVariant;
  xKey, ValRow, ValDel: Variant;
Begin
  Result := -1;
  If VarIsNull(KeyValues) then
    Exit;
  PxKey := nil;
  Len := VarArrayHighBound(KeyValues, 1);
  Try
    for I := 0 to FDeletedValues.Count - 1 do
    Begin
      PxKey := FDeletedValues[I];
      // Mantis #3974 : "FDeletedValues" is a List of Pointers, and each item have two
      // possible value... PxKey (a Variant) or NIL. The list counter is incremented
      // with the ADD() method and decremented with the DELETE() method
      If PxKey <> nil then // ONLY If FDeletedValues[I] have a value <> NIL
      Begin
        xKey := PxKey^;
        aEquals := -1;
        for J := 0 to Len - 1 do
        Begin
          ValRow := KeyValues[J];
          ValDel := xKey[J];
          If VarCompareValue(ValRow, ValDel) = vrEqual then
          Begin
            Inc(aEquals);
            If aEquals = (Len - 1) then
              Break;
          End;
        End;
        If aEquals = (Len - 1) then
        Begin
          Result := I;
          Break;
        End;
      End;
    End;
  Finally
    If PxKey <> nil then
      Dispose(PxKey);
  End;
End;

Function TRESTDWMemTable.IsDeleted(out Index: Integer): Boolean;
Begin
  Index := FindDeleted(GetValues());
  Result := Index > -1;
End;

Function TRESTDWMemTable.IsInserted: Boolean;
Begin
  Result := TRecordStatus(FieldByName(FStatusName).AsInteger) = rsInserted;
End;

Function TRESTDWMemTable.IsUpdated: Boolean;
Begin
  Result := TRecordStatus(FieldByName(FStatusName).AsInteger) = rsUpdated;
End;

Function TRESTDWMemTable.IsOriginal: Boolean;
Begin
  Result := TRecordStatus(FieldByName(FStatusName).AsInteger) = rsOriginal;
End;

Function TRESTDWMemTable.IsLoading: Boolean;
Begin
  Result := FSaveLoadState = slsLoading;
End;

Function TRESTDWMemTable.IsSaving: Boolean;
Begin
  Result := FSaveLoadState = slsSaving;
End;

// === { TRESTDWMTMemBlobStream } ===================================================
constructor TRESTDWMTMemBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
Begin
  // (rom) added inherited Create;
  inherited Create;
  FActualBlob := Nil;
  FMode := Mode;
  FField := Field;
  FDataSet := FField.Dataset as TRESTDWMemTable;
  If not FDataSet.GetActiveRecBuf(FBuffer) then
    Exit;
  If not FField.Modified and (Mode <> bmRead) then
  Begin
    If FField.ReadOnly then
      ErrorFmt('The Field %s is ReadOnly', [FField.DisplayName]);
    If not(FDataSet.State in [dsEdit, dsInsert]) then
      Error('Not Editing...');
    FCached := True;
  End
  Else
    FCached := (FBuffer = PRESTDWMTMemBuffer(FDataSet.ActiveBuffer));
  If (FCached) And (FDataSet.State = dsBrowse) Then
    PMemBlobArray(FBuffer + FDataSet.GetOffSetsBlobs)^[FField.Offset] :=
      GetBlobFromRecord(FField);
  FOpened := True;
  If Mode = bmWrite then
    Truncate;
End;

destructor TRESTDWMTMemBlobStream.Destroy;
Begin
  If FOpened and FModified then
    FField.Modified := True;
  If FModified then
    Try
      FDataSet.DataEvent(deFieldChange, NativeInt(FField));
    Except
      AppHandleException(Self);
    End;
  inherited Destroy;
End;

Function TRESTDWMTMemBlobStream.GetBlobFromRecord(Field: TField): TMemBlobData;
var
  Rec: TRESTDWMTMemoryRecord;
  Pos: Integer;
Begin
  SetLength(Result, 0);
  Try
    Pos := FDataSet.RecNo -1;
    If (Pos >= 0) And (Pos < FDataSet.RecordCount) Then
    Begin
      Rec := FDataSet.Records[Pos];
      If Rec <> nil Then
        Result := PMemBlobArray(Rec.FBlobs)^[FField.Offset];
    End;
  Except

  End;
End;

Procedure TRESTDWMTMemBlobStream.SetBlobFromRecord(Field: TField; Value: TMemBlobData);
Var
  Rec: TRESTDWMTMemoryRecord;
  Pos: Integer;
  FBlobs: Pointer;
Begin
  Try
    Pos := FDataSet.RecNo - 1;
    If (Pos >= 0) And (Pos < FDataSet.RecordCount) Then
    Begin
      Rec := FDataSet.Records[Pos];
      If Rec <> nil Then
      Begin
        FBlobs := Pointer(@PMemBlobArray(Rec.FBlobs)^[FField.Offset]);
        SetLength(TRESTDWBytes(FBlobs^), Length(TRESTDWBytes(FBlobs^)) + Length(Value));
        Move(Value[0], TRESTDWBytes(FBlobs^)[FPosition], Length(Value));
      End;
    End;
  Except

  End;
End;

Function TRESTDWMTMemBlobStream.Read(Var Buffer; Count: Longint): Longint;
Var
  aBytes: TRESTDWBytes;
  aRecNo: Integer;
  MemBlobData: ^TMemBlobData;
Begin
  Result := 0;
  If FOpened then
  Begin
    If Not Assigned(FActualBlob) Then
      If FDataSet.State = dsBrowse Then
        FActualBlob := @PMemBlobArray(FDataSet.Records[FDataSet.RecNo - 1].FBlobs)
          ^[FField.Offset]
      Else
        FActualBlob := @PMemBlobArray(FBuffer + FDataSet.GetOffSetsBlobs)^[FField.Offset];
    If Count > (Size - FPosition) Then
      Result := Size - FPosition
    Else
      Result := Count;
    If Result > 0 then
    Begin
      Try
        If Not Assigned(FActualBlob) Then
          Exit;
      Except
        Exit;
      End;
      If Not Assigned(PRESTDWBytes(FActualBlob)^) Then
        Exit;
      If Result > Length(PRESTDWBytes(FActualBlob)^) Then
      Begin
        Result := 0;
        SetLength(aBytes, Result);
        TRESTDWBytes(Buffer) := aBytes;
      End
      Else If (Length(PRESTDWBytes(FActualBlob)^) > 0) Then
      Begin
        SetLength(aBytes, Result);
        Try
          Move(PRESTDWBytes(FActualBlob)^[FPosition], aBytes[0], Result);
        Finally
          Move(aBytes[0], Buffer, Result);
          SetLength(aBytes, 0);
        End;
      End;
      Inc(FPosition, Result);
    End
  End;
End;

Function TRESTDWMTMemBlobStream.Write(const Buffer; Count: Longint): Longint;
Var
  Temp: TMemBlobData;
Begin
  Result := 0;
  If FOpened and FCached and (FMode <> bmRead) then
  Begin
    Temp := FDataSet.GetBlobData(FField, FBuffer);
    If Length(Temp) < FPosition + Count then
      SetLength(Temp, FPosition + Count);
    Move(Buffer, PRESTDWMTMemBuffer(Temp)[FPosition], Count);
    FDataSet.SetBlobData(FField, FBuffer, Temp);
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
  End;
End;

Function TRESTDWMTMemBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
Begin
  case Origin of
    soFromBeginning:
      FPosition := Offset;
    soFromCurrent:
      Inc(FPosition, Offset);
    soFromEnd:
      FPosition := GetBlobSize + Offset;
  End;
  Result := FPosition;
End;

Procedure TRESTDWMTMemBlobStream.Truncate;
Var
  aBytes: TRESTDWBytes;
Begin
  If FOpened and FCached and (FMode <> bmRead) then
  Begin
    FDataSet.SetBlobData(FField, FBuffer, aBytes);
    FModified := True;
  End;
End;

Function TRESTDWMTMemBlobStream.GetBlobSize: Longint;
Begin
  Result := 0;
  If FOpened then
  Begin
    If FDataSet.State = dsBrowse then
      Result := Length(GetBlobFromRecord(FField))
    Else
      Result := Length(PMemBlobArray(FBuffer + FDataSet.GetOffSetsBlobs)^[FField.Offset]);
  End;
End;

{ TRESTDWStorageBase }

constructor TRESTDWStorageBase.Create(AOwner: TComponent);
Begin
  inherited Create(AOwner);
  FEncodeStrs := True;
End;

Procedure TRESTDWStorageBase.LoadDatasetFromStream(Dataset: TDataset; stream: TStream);
Begin

End;

Procedure TRESTDWStorageBase.LoadDWMemFromStream(Dataset: IRESTDWMemTable;
  stream: TStream);
Begin

End;

Destructor TRecordList.Destroy;
Begin
  ClearAll;
  Inherited;
End;

Function TRecordList.GetRec(Index: Integer): TRESTDWMTMemoryRecord;
Begin
  Result := Nil;
  If (Index < Self.Count) And (Index > -1) Then
    Result := TRESTDWMTMemoryRecord(TList(Self).Items[Index]^);
End;

Procedure TRecordList.PutRec(Index: Integer; Item: TRESTDWMTMemoryRecord);
Begin
  If (Index < Self.Count) And (Index > -1) Then
    TRESTDWMTMemoryRecord(TList(Self).Items[Index]^) := Item;
End;

Function TRecordList.Add(Item: TRESTDWMTMemoryRecord): Integer;
Var
  vItem: PRESTDWMTMemoryRecord;
Begin
  New(vItem);
  vItem^ := Item;
  Result := Inherited Add(vItem);
  vItem^.Index := Result;
End;

Procedure TRecordList.Delete(Index: Integer);
Begin
  If (Index > -1) Then
  Begin
    Try
      If Assigned(TList(Self).Items[Index]) Then
      Begin
        If Assigned(TRESTDWMTMemoryRecord(TList(Self).Items[Index]^)) Then
        Begin
{$IFDEF FPC}
          FreeAndNil(TList(Self).Items[Index]^);
{$ELSE}
{$IF CompilerVersion > 33}
          FreeAndNil(TRESTDWMTMemoryRecord(TList(Self).Items[Index]^));
{$ELSE}
          FreeAndNil(TList(Self).Items[Index]^);
{$IFEND}
{$ENDIF}
        End;
      End;
{$IFDEF FPC}
      Dispose(PRESTDWMTMemoryRecord(TList(Self).Items[Index]));
{$ELSE}
      Dispose(TList(Self).Items[Index]);
{$ENDIF}
    Except
    End;
    TList(Self).Delete(Index);
  End;
End;

Procedure TRecordList.ClearAll;
Var
  I: Integer;
Begin
  I := Count - 1;
  While I > -1 Do
  Begin
    Delete(I);
    Dec(I);
  End;
  Inherited Clear;
End;

Procedure TRESTDWStorageBase.LoadFromFile(Dataset: TDataset; FileName: String);
var
  vFileStream : TFileStream;
Begin
  If not FileExists(FileName) then
    Exit;

  vFileStream := TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
  Try
    LoadFromStream(Dataset,TStream(vFileStream));
  Finally
    vFileStream.Free;
  End;
End;

Procedure TRESTDWStorageBase.LoadFromStream(Dataset: TDataset; stream: TStream);
Begin
  If Dataset.InheritsFrom(TRESTDWMemTable) then
    LoadDWMemFromStream(TRESTDWMemTable(Dataset), stream)
  Else
    LoadDatasetFromStream(Dataset, stream);
End;

Procedure TRESTDWStorageBase.SaveDatasetToStream(Dataset: TDataset; Var stream: TStream);
Begin

End;

Procedure TRESTDWStorageBase.SaveDWMemToStream(Dataset: IRESTDWMemTable;
  Var stream: TStream);
Begin

End;

Procedure TRESTDWStorageBase.SaveToFile(Dataset: TDataset; FileName: String);
var
  vFileStream : TFileStream;
Begin
  Try
    vFileStream := TFileStream.Create(FileName,fmCreate);
    Try
      SaveToStream(Dataset,TStream(vFileStream));
    Except

    End;
  Finally
    vFileStream.Free;
  End;
End;

Procedure TRESTDWStorageBase.SaveToStream(Dataset: TDataset; Var stream: TStream);
Begin
  If Dataset.InheritsFrom(TRESTDWMemTable) then
    SaveDWMemToStream(TRESTDWMemTable(Dataset), stream)
  Else
    SaveDatasetToStream(Dataset, stream);
End;


{ TRESTDWMemTableEx }

Procedure TRESTDWMemTableEx.CopyStructure(Source: TDataSet);
Begin
  inherited CopyStructure(source);
  RefreshFilteredRecordCount;
End;

constructor TRESTDWMemTableEx.Create(AOwner: TComponent);
Begin
  inherited;
  fSortOrder := soAsc;
  fSortCaseSens := scYes;
  fAutoSortOnOpen := true;
  fAutoRefreshOnFilterChanged := True;
  fFilteredRecordCount := 0;
End;

Procedure TRESTDWMemTableEx.EmptyTable;
Begin
  inherited EmptyTable;
  RefreshFilteredRecordCount();
End;

Function TRESTDWMemTableEx.GetFilteredRecordCount: Integer;
Begin
  If Filtered and Active then
    Result := fFilteredRecordCount
  Else
    result := inherited GetRecordCount;
End;

Procedure TRESTDWMemTableEx.InternalAddRecord(Buffer: Pointer;
  {$IFDEF FPC}aAppend: Boolean{$ELSE}Append: Boolean{$ENDIF});
Begin
  inherited InternalAddRecord(buffer, {$IFDEF FPC}aAppend{$ELSE}Append{$ENDIF});
  If Active and Filtered then
    inc(fFilteredRecordCount);
End;

Procedure TRESTDWMemTableEx.InternalDelete;
Begin
  inherited InternalDelete;
  If Active and Filtered then
    Dec(fFilteredRecordCount);
End;

Procedure TRESTDWMemTableEx.InternalPost;
Var accept: Boolean;
Begin
  inherited InternalPost;
  If Active and Filtered then
  Begin
    accept := true;

    If assigned(OnFilterRecord) then
    Begin
      OnFilterRecord(self, accept);
      If not accept then
        Dec(fFilteredRecordCount);
    End
  End
End;

Procedure TRESTDWMemTableEx.InternalRefresh;
Begin
  inherited InternalRefresh;
  If Active and Filtered then
  Begin
    RefreshFilteredRecordCount;
    First;
  End;
End;

Function TRESTDWMemTableEx.IsSortField(field: TField): Boolean;
var
  s, whatToSearch: string;
  fieldNameEnd: Boolean;
  i: integer;
Begin
  Result := False;
  whatToSearch := LowerCase(Trim(field.FieldName));
  fieldNameEnd := false;
  i := 1; s := '';
  while (i <= Length(fSortFields)) do
  Begin
    case fSortFields[i] of
      ';':
        Begin
          fieldNameEnd := true;
        End;
      ' ': ;
    Else
      s := s + fSortFields[i];
    End;
    If ((i + 1) > length(fSortFields)) or fieldNameEnd then
    Begin
      {s = s.strip(HString::both).to_lower();}
      If s <> '' then
      Begin
        If LowerCase(s) = whatToSearch then
        Begin
          Result := True;
          exit;
        End
      End;
      fieldNameEnd := false;
      s := ''; ;
    End;
    Inc(i);
  End
End;

Function TRESTDWMemTableEx.LoadFromDataSet(Source: TDataSet;
  {$IFDEF FPC}aRecordCount: Integer; {$ELSE}RecordCount: Integer; {$ENDIF}Mode: TLoadMode): Integer;
Var wasFiltered: boolean;
Begin
  wasFiltered := Filtered;
  result := inherited LoadFromDataSet(source, {$IFDEF FPC}aRecordCount{$ELSE}RecordCount{$ENDIF}, mode);

  Filtered := wasFiltered;

  If fAutoSortOnOpen then
    ReSortOnFields(fSortOrder, fSortFields);
  RefreshFilteredRecordCount();
  First();
End;

Procedure TRESTDWMemTableEx.RefreshFilteredRecordCount;
var
  t: TDataSetState;
  savePlace: TBookmark;
  i: integer;
  _afterScroll, _beforeScroll: TDataSetNotifyEvent;
  dsCountingFilteredRecordCount: TDataSetState;
Begin
//#define dsCountingFilteredRecordCount ((TDataSetState)(dsOpening+1))
//type TDataSetState = (dsInactive, dsBrowse, dsEdit, dsInsert, dsSetKey, dsCalcFields, dsFilter, dsNewValue, dsOldValue, dsCurValue, dsBlockRead, dsInternalCalc, dsOpening);
  fFilteredRecordCount := 0;

  If Filtered and Active then
  Begin

    i := 0;

    savePlace := GetBookmark();
    _afterScroll := AfterScroll;
    _beforeScroll := BeforeScroll;
    dsCountingFilteredRecordCount := TDataSetState(Ord(dsOpening) + 1);
    {store last state}
    t := SetTempState(dsCountingFilteredRecordCount);

    Try
      AfterScroll := nil;
      BeforeScroll := nil;
      DisableControls;
      First;
      while not Eof do
      Begin
        inc(i);
        Next();
      End;
      fFilteredRecordCount := i;

    Finally
      If (fFilteredRecordCount > 0) and assigned(savePlace) and BookmarkValid(savePlace) then
        GotoBookmark(savePlace);
      FreeBookmark(savePlace);
      AfterScroll := _afterScroll;
      BeforeScroll := _beforeScroll;
      {restore state here}
      RestoreState(t);
      EnableControls;
    End;
  End;
End;

Procedure TRESTDWMemTableEx.ReSortOnFields(pSortOrder: TSortOrder;
  {$IFDEF FPC}afields: string{$ELSE}fields: string{$ENDIF});
var
  sAfterScroll: TDataSetNotifyEvent;
  savePlace: TBookmark;
  b: boolean;
  oldSortFiels: string;
Begin
  If {$IFDEF FPC}afields{$ELSE}fields{$ENDIF} = '' then
    {$IFDEF FPC}afields{$ELSE}fields{$ENDIF} := sortFields;

  fSortOrder := pSortOrder; // new sort order
  oldSortFiels := fSortFields;
  fSortFields := {$IFDEF FPC}afields{$ELSE}fields{$ENDIF};

  sAfterScroll := AfterScroll;
  AfterScroll := nil;
  DisableControls();
  Try
    savePlace := GetBookmark();
    b := not boolean(fSortCaseSens);
    SortOnFields(fSortFields, b, fSortOrder = soDesc);

    If assigned(savePlace) then
      GotoBookmark(savePlace);
    FreeBookmark(savePlace);
  Finally
    fSortFields := oldSortFiels;
    EnableControls();
    AfterScroll := sAfterScroll;
  End;
End;

Procedure TRESTDWMemTableEx.SetFiltered(Value: Boolean);
Begin
  inherited SetFiltered(Value);
  If (Active and (fAutoRefreshOnFilterChanged)) then
//    Refresh()
//  Else
   RefreshFilteredRecordCount();
End;

Procedure TRESTDWMemTableEx.SetOnFilterRecord(
  const Value: TFilterRecordEvent);
Begin
  inherited SetOnFilterRecord(value);
  If (fAutoRefreshOnFilterChanged) then
    InternalRefresh()
  Else
    RefreshFilteredRecordCount();
End;

end.
