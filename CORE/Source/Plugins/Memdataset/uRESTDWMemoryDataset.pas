Unit uRESTDWMemoryDataset;

{$I ..\..\Includes\uRESTDW.inc}

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

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}
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
                     {$IF CompilerVersion >= 20}
                      ftOraTimestamp, ftFixedWideChar, ftTimeStampOffset,
                      ftLongWord, ftShortint, ftByte, ftExtended, ftSingle,
                     {$IFEND}
                   {$ELSE}
                    ftFixedWideChar,
                   {$ENDIF FPC}
                   ftBytes, ftVarBytes, ftADT, ftFixedChar, ftWideString, ftLargeint, ftVariant, ftGuid] + ftBlobTypes;
 fkStoredFields = [fkData];
 SDefaultIndex  = 'DEFAULT_ORDER';
 SCustomIndex   = 'CUSTOM_ORDER';
 Desc           = ' DESC';     //leading space is important
 LenDesc        : Integer = Length(Desc);
 Limiter        = ';';
 SNoIndexFieldNameGiven   = 'Cannot create index "%s": No fields available.';
 SErrIndexBasedOnInvField = 'Field "%s" has an invalid field type (%s) to base index on.';
 SMinIndexes              = 'The minimum amount of indexes is 1';
 SIndexNotFound           = 'Index ''%s'' not found';
 SUniDirectional          = 'Operation cannot be performed on an unidirectional dataset';

 Type
  TCompareFunc  = Function(subValue,
                           aValue    : Pointer;
                           size      : Integer;
                           options   : TLocateOptions) : Int64;
  TDBCompareRec = Record
                   CompareFunc : TCompareFunc;
                   Off         : Int64;
                   NullBOff    : Int64;
                   FieldInd    : longint;
                   Size        : integer;
                   Options     : TLocateOptions;
                   Desc        : Boolean;
                  end;
  TDBCompareStruct = array of TDBCompareRec;

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
 PMemBlobData          = ^TRESTDWBytes;
 TMemBlobArray         = Array Of TMemBlobData;
 PMemBlobArray         = ^TMemBlobArray;
 PRESTDWMTMemoryRecord = ^TRESTDWMTMemoryRecord;
 TRESTDWMTMemoryRecord = Class;
 TLoadMode             = (lmCopy, lmAppend);
 TSaveLoadState        = (slsNone, slsLoading, slsSaving);
 TCompareRecords       = Function(Item1, Item2 : TRESTDWMTMemoryRecord) : Integer Of Object;
 TIntArray             = Array Of Integer;
 TRESTDWMTBookmarkData = Integer;
 TRESTDWMemTable       = Class;
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
  PBlobBuffer = ^TBlobBuffer;
  TBlobBuffer = Packed Record
    FieldNo,
    OrgBufID  : Integer;
    Buffer    : Pointer;
    Size      : Int64;
  end;
  PRESTDWBlobField = ^TRESTDWBlobField;
  TRESTDWBlobField = Packed Record
   ConnBlobBuffer : Array[0..11] Of Byte; // DB specific data is stored here
   BlobBuffer     : PBlobBuffer;
  End;
  PRESTDWRecLinkItem = ^TRESTDWRecLinkItem;
  TRESTDWRecLinkItem = Packed Record
   Prior             : PRESTDWRecLinkItem;
   Next              : PRESTDWRecLinkItem;
  End;
  PRESTDWBookmark       = ^TRESTDWBookmark;
  TRESTDWBookmark       = Packed Record
   BookmarkData      : PRESTDWRecLinkItem;
   BookmarkInt       : Integer; // Was used by TArrayBufIndex
   BookmarkFlag      : TBookmarkFlag;
  End;

  IRESTDWMemTable = Interface
    Function GetRecordCount               : Integer;
    Function GetMemoryRecord  (Index      : Integer)      : TRESTDWMTMemoryRecord;
    Function GetOffSets       (aField     : TField)       : Word;Overload;
    Function GetOffSets       (Index      : Integer)      : Word;Overload;
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
    Function  GetBlob           (RecNo, Index    : Integer) : PMemBlobData;
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
  TIndexType = (itNormal,itDefault,itCustom);
  TRESTDWIndex = Class(TObject)
  Private
   FDataset : TRESTDWMemtable;
  Protected
   Function  GetBookmarkSize  : integer;       Virtual; Abstract;
   Function  GetCurrentBuffer : Pointer;       Virtual; Abstract;
   Function  GetCurrentRecord : TRecordBuffer; Virtual; Abstract;
   Function  GetIsInitialized : boolean;       Virtual; Abstract;
   Function  GetSpareBuffer   : TRecordBuffer; Virtual; Abstract;
   Function  GetSpareRecord   : TRecordBuffer; Virtual; Abstract;
   Function  GetRecNo         : Longint;       Virtual; Abstract;
   Procedure SetRecNo(ARecNo  : Longint);      Virtual; Abstract;
  Public
   DBCompareStruct : TDBCompareStruct;
   Name,
   FieldsName,
   CaseinsFields,
   DescFields      : String;
   Options         : TIndexOptions;
   IndNr           : Integer;
   Constructor Create(const ADataset : TRESTDWMemtable); Virtual;
   Function    ScrollBackward        : TGetResult;       Virtual; Abstract;
   Function    ScrollForward         : TGetResult;       Virtual; Abstract;
   Function    GetCurrent            : TGetResult;       Virtual; Abstract;
   Function    ScrollFirst           : TGetResult;       Virtual; Abstract;
   Procedure   ScrollLast;                               Virtual; Abstract;
   // Gets prior/next record relative to given bookmark; does not change current record
   Function  GetRecord(ABookmark     : PRESTDWBookmark;
                       GetMode       : TGetMode): TGetResult; Virtual;
   Procedure SetToFirstRecord;            Virtual; Abstract;
   Procedure SetToLastRecord;             Virtual; Abstract;
   Procedure StoreCurrentRecord;          Virtual; Abstract;
   Procedure RestoreCurrentRecord;        Virtual; Abstract;
   Function  CanScrollForward : Boolean;  Virtual; Abstract;
   Procedure DoScrollForward;             Virtual; Abstract;
   Procedure StoreCurrentRecIntoBookmark(Const ABookmark : PRESTDWBookmark);  Virtual; Abstract;
   Procedure StoreSpareRecIntoBookmark  (Const ABookmark : PRESTDWBookmark);  Virtual; Abstract;
   Procedure GotoBookmark               (Const ABookmark : PRESTDWBookmark);  Virtual; Abstract;
   Function  BookmarkValid              (Const ABookmark : PRESTDWBookmark) : Boolean; Virtual;
   Function  CompareBookmarks           (Const ABookmark1,
                                         ABookmark2      : PRESTDWBookmark) : Integer; Virtual;
   Function  SameBookmarks              (Const ABookmark1,
                                         ABookmark2      : PRESTDWBookmark) : Boolean; Virtual;
   Procedure InitialiseIndex;                                              Virtual; Abstract;
   Procedure InitialiseSpareRecord(Const ASpareRecord : TRecordBuffer);    Virtual; Abstract;
   Procedure ReleaseSpareRecord;                                           Virtual; Abstract;
   Procedure BeginUpdate;                                                  Virtual; Abstract;
   // Adds a record to the end of the index as the new last record (spare record)
   // Normally only used in GetNextPacket
   Procedure AddRecord;                                                        Virtual; Abstract;
   // Inserts a record before the current record, or if the record is sorted,
   // inserts it in the proper position
   Procedure InsertRecordBeforeCurrentRecord(Const ARecord   : TRecordBuffer); Virtual; Abstract;
   Procedure RemoveRecordFromIndex          (Const ABookmark : TRESTDWBookmark);  Virtual; Abstract;
   Procedure OrderCurrentRecord;                                               Virtual; Abstract;
   Procedure EndUpdate;                                                        Virtual; Abstract;
   Property  SpareRecord   : TRecordBuffer Read GetSpareRecord;
   Property  SpareBuffer   : TRecordBuffer Read GetSpareBuffer;
   Property  CurrentRecord : TRecordBuffer Read GetCurrentRecord;
   Property  CurrentBuffer : Pointer       Read GetCurrentBuffer;
   Property  IsInitialized : boolean       Read GetIsInitialized;
   Property  BookmarkSize  : integer       Read GetBookmarkSize;
   Property  RecNo         : Longint       Read GetRecNo Write SetRecNo;
  End;
  TUniDirectionalBufIndex = Class(TRESTDWIndex)
  Private
   FSPareBuffer : TRecordBuffer;
  Protected
   Function  GetBookmarkSize  : Integer;       Override;
   Function  GetCurrentBuffer : Pointer;       Override;
   Function  GetCurrentRecord : TRecordBuffer; Override;
   Function  GetIsInitialized : Boolean;       Override;
   Function  GetSpareBuffer   : TRecordBuffer; Override;
   Function  GetSpareRecord   : TRecordBuffer; Override;
   Function  GetRecNo         : Longint;       Override;
   Procedure SetRecNo(ARecNo  : Longint);      Override;
  Public
   Function  ScrollBackward   : TGetResult;    Override;
   Function  ScrollForward    : TGetResult;    Override;
   Function  GetCurrent       : TGetResult;    Override;
   Function  ScrollFirst      : TGetResult;    Override;
   Procedure ScrollLast;                       Override;
   Procedure SetToFirstRecord;                 Override;
   Procedure SetToLastRecord;                  Override;
   Procedure StoreCurrentRecord;               Override;
   Procedure RestoreCurrentRecord;             Override;
   Function  CanScrollForward : Boolean;       Override;
   Procedure DoScrollForward;                  Override;
   Procedure StoreCurrentRecIntoBookmark(Const ABookmark    : PRESTDWBookmark); Override;
   Procedure StoreSpareRecIntoBookmark  (Const ABookmark    : PRESTDWBookmark); Override;
   Procedure GotoBookmark               (Const ABookmark    : PRESTDWBookmark); Override;
   Procedure InitialiseIndex;                                                   Override;
   Procedure InitialiseSpareRecord      (Const ASpareRecord : TRecordBuffer);   Override;
   Procedure ReleaseSpareRecord;               Override;
   Procedure BeginUpdate;                      Override;
   Procedure AddRecord;                        Override;
   Procedure InsertRecordBeforeCurrentRecord(Const ARecord : TRecordBuffer);    Override;
   Procedure RemoveRecordFromIndex         (const ABookmark : TRESTDWBookmark); Override;
   Procedure OrderCurrentRecord;               Override;
   Procedure EndUpdate;                        Override;
  End;
  TDoubleLinkedBufIndex = class(TRESTDWIndex)
  Private
   FCursOnFirstRec : Boolean;
   FStoredRecBuf   : PRESTDWRecLinkItem;
   FCurrentRecBuf  : PRESTDWRecLinkItem;
  Protected
   Function  GetBookmarkSize  : Integer;       Override;
   Function  GetCurrentBuffer : Pointer;       Override;
   Function  GetCurrentRecord : TRecordBuffer; Override;
   Function  GetIsInitialized : Boolean;       Override;
   Function  GetSpareBuffer   : TRecordBuffer; Override;
   Function  GetSpareRecord   : TRecordBuffer; Override;
   Function  GetRecNo         : Longint;       Override;
   Procedure SetRecNo(ARecNo  : Longint);      Override;
  Public
   FLastRecBuf     : PRESTDWRecLinkItem;
   FFirstRecBuf    : PRESTDWRecLinkItem;
   FNeedScroll     : Boolean;
   Function  ScrollBackward      : TGetResult; Override;
   Function  ScrollForward       : TGetResult; Override;
   Function  GetCurrent          : TGetResult; Override;
   Function  ScrollFirst         : TGetResult; Override;
   Procedure ScrollLast;                       Override;
   Function  GetRecord(ABookmark : PRESTDWBookmark;
                       GetMode   : TGetMode): TGetResult; Override;
   Procedure SetToFirstRecord;     Override;
   Procedure SetToLastRecord;      Override;
   Procedure StoreCurrentRecord;   Override;
   procedure RestoreCurrentRecord; Override;
   Function  CanScrollForward : Boolean; Override;
   Procedure DoScrollForward;            Override;
   Procedure StoreCurrentRecIntoBookmark(Const ABookmark : PRESTDWBookmark); Override;
   Procedure StoreSpareRecIntoBookmark  (Const ABookmark : PRESTDWBookmark); Override;
   Procedure GotoBookmark               (Const ABookmark : PRESTDWBookmark); Override;
   Function CompareBookmarks            (Const ABookmark1,
                                         ABookmark2      : PRESTDWBookmark) : Integer; Override;
   Function SameBookmarks               (Const ABookmark1,
                                         ABookmark2      : PRESTDWBookmark) : Boolean; Override;
   Procedure InitialiseIndex;      Override;
   Procedure InitialiseSpareRecord      (Const ASpareRecord : TRecordBuffer); Override;
   Procedure ReleaseSpareRecord;   Override;
   Procedure BeginUpdate;          Override;
   Procedure AddRecord;            Override;
   Procedure InsertRecordBeforeCurrentRecord(Const ARecord   : TRecordBuffer);   Override;
   Procedure RemoveRecordFromIndex          (Const ABookmark : TRESTDWBookmark); Override;
   Procedure OrderCurrentRecord;   Override;
   Procedure EndUpdate;            Override;
  End;
  TRESTDWDatasetIndex = Class(TIndexDef)
  Private
   FBufferIndex    : TRESTDWIndex;
   FDiscardOnClose : Boolean;
   FIndexType      : TIndexType;
  Public
   Destructor Destroy; Override;
   // Free FBufferIndex;
   Procedure Clearindex;
   // Set TIndexDef properties on FBufferIndex;
   Procedure SetIndexProperties;
   // Return true if the buffer must be built.
   // Default buffer must not be built, custom only when it is not the current.
   Function MustBuild    (aCurrent : TRESTDWDatasetIndex) : Boolean;
   // Return true if the buffer must be updated
   // This are all indexes except custom, unless it is the active index
   Function IsActiveIndex(aCurrent : TRESTDWDatasetIndex) : Boolean;
   // The actual buffer.
   Property BufferIndex : TRESTDWIndex Read FBufferIndex Write FBufferIndex;
   // If the Index is created after Open, then it will be discarded on close.
   Property DiscardOnClose : Boolean Read FDiscardOnClose;
   // Skip build of this index
   Property IndexType : TIndexType Read FIndexType Write FIndexType;
  End;
  TRESTDWDatasetIndexDefs = Class(TIndexDefs)
  Private
   Function GetBufDatasetIndex(AIndex : Integer) : TRESTDWDatasetIndex;
   Function GetBufferIndex(AIndex : Integer)     : TRESTDWIndex;
  Public
   Constructor Create(aDataset : TDataset);  {$IFNDEF FPC}
                                              {$IF CompilerVersion > 21}
                                                Override;
                                              {$IFEND}
                                             {$ELSE}
                                              Override;
                                             {$ENDIF}
   // Does not raise an exception if not found.
   Function FindIndex(const IndexName: string)  : TRESTDWDatasetIndex;
   Property RESTDWIndexdefs [AIndex : Integer]  : TRESTDWDatasetIndex Read GetBufDatasetIndex;
   Property RESTDWIndexes   [AIndex : Integer]  : TRESTDWIndex        Read GetBufferIndex;
  End;
  TRESTDWMemTable = Class(TDataset, IRESTDWMemTable)
  Private
    FSaveLoadState    : TSaveLoadState;
    aFilterRecs,
    FMaxIndexesCount,
    FPacketRecords,
    FRecordFilterPos,
    FRecordPos,
    FRecordSize,
    FBookmarkOfs,
    FBlobOfs,
    FRecBufSize,
    FLastID,
    FRowsOriginal,
    FRowsChanged,
    FRowsAffected     : Integer;
    FOffsets          : TIntArray;
    FAutoInc          : Longint;
    FDeletedValues,
    FIndexList        : TList;
    FSrcAutoIncField  : TField;
    FRecords          : TRecordList;
    FDataSet          : TDataset;
    FAllPacketsFetched,
    FRefreshing,
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
    FIndexFieldNames,
    FIndexName,
    FStatusName,
    FKeyFieldNames    : String;
    FApplyMode        : TApplyMode;
    FBeforeApply,
    FAfterApply       : TApplyEvent;
    FBeforeApplyRecord,
    FAfterApplyRecord : TApplyRecordEvent;
    FNullmaskSize     : Byte;
    FFilterParser     : TExprParser;
    FStorageDataType  : TRESTDWStorageBase;
    FBlobs            : TMemBlobArray;
    FIndexes          : TRESTDWDataSetIndexDefs;
    FDefaultIndex,
    FCurrentIndexDef  : TRESTDWDatasetIndex;
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
    Function FindFieldIndex           (Field           : TField) : Integer;
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
    Procedure SetFilterText(Const Value : String);{$IFNDEF FPC}Override;{$ENDIF}
    Function  ParserGetVariableValue(Sender        : TObject;
                                     Const VarName : String;
                                     Var Value     : Variant)    : Boolean;Virtual;
    Procedure Notification          (AComponent    : TComponent;
                                     Operation     : TOperation);Override;
    Function DataTypeSuported       (datatype      : TFieldType) : Boolean;
    Function DataTypeIsBlobTypes    (datatype      : TFieldType) : Boolean;
    Function GetOffSets             (aField        : TField)     : Word;Overload;
    Function GetOffSets             (Index         : Integer)    : Word;Overload;
    Function GetOffSetsBlobs  : Word;
    Function GetBlobRec             (Field         : TField;
                                     Rec           : TRESTDWMTMemoryRecord) : TMemBlobData;
    Function GetCalcFieldLen        (FieldType     : TFieldType;
                                     Size          : Word)       : Word;
    procedure ClearIndexes;
    Function  GetDataset       : TDataset;
    Procedure SetIndexName(AValue : String);
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
    Function  GetBlob           (aRecNo,
                                 Index        : Integer) : PMemBlobData;
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
                    Options            : TLocateOptions) : Boolean;{$IFNDEF FPC}Override;{$ENDIF}
    Function Lookup(Const KeyFields    : String;
                    Const KeyValues    : Variant;
                    Const ResultFields : String)         : Variant;{$IFNDEF FPC}Override;{$ENDIF}
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
    Function  GetCurrentIndexBuf : TRESTDWIndex;
    Function  GetIndexDefs       : TIndexDefs;
    Function  GetIndexName       : String;
    Function  GetIndexFieldNames : String;
    Function  getnextpacket      : Integer;
    Function  DefaultBufferIndex : TRESTDWIndex;
    Function  DefaultIndex       : TRESTDWDatasetIndex;
    Procedure BuildIndexes;
    Function  GetNewBlobBuffer   : PBlobBuffer;
    Function  LoadField (FieldDef       : TFieldDef;
                         buffer         : Pointer;
                         out CreateBlob : boolean)     : Boolean;
    Function  Fetch              : Boolean;
    Procedure LoadBlobIntoBuffer(FieldDef : TFieldDef;
                                 ABlobBuf : PRESTDWBlobField); Virtual; Abstract;
    Function  LoadBuffer (Buffer : TRecordBuffer)      : TGetResult;
    Procedure BuildIndex (AIndex : TRESTDWIndex);
    Procedure FetchAll;
    Function  IntAllocRecordBuffer : TRecordBuffer;
    Procedure SetIndexFieldNames (Const AValue         : String);
    Procedure InternalCreateIndex(F                    : TRESTDWDataSetIndex);
    Function  InternalAddIndex   (Const AName,
                                  AFields              : String;
                                  AOptions             : TIndexOptions;
                                  Const ADescFields    : String;
                                  Const ACaseInsFields : String)  : TRESTDWDatasetIndex;
    Function  BufferOffset       : Integer;
    Procedure ProcessFieldsToCompareStruct(Const AFields,
                                           ADescFields,
                                           ACInsFields          : TList;
                                           Const AIndexOptions  : TIndexOptions;
                                           Const ALocateOptions : TLocateOptions;
                                           out ACompareStruct   : TDBCompareStruct);
    Procedure InitDefaultIndexes;
    Procedure BuildCustomIndex;
    Procedure SetMaxIndexesCount (Const AValue         : Integer);
    Function  GetBufIndex        (Aindex               : Integer) : TRESTDWIndex;
    Function  GetBufIndexDef     (Aindex               : Integer) : TRESTDWDatasetIndex;
    Property  SaveLoadState          : TSaveLoadState                 Read FSaveLoadState;
    Property  RowsOriginal           : Integer                        Read FRowsOriginal;
    Property  RowsChanged            : Integer                        Read FRowsChanged;
    Property  RowsAffected           : Integer                        Read FRowsAffected;
    Property  Refreshing             : Boolean                        Read FRefreshing;
    Property  StorageDataType        : TRESTDWStorageBase             Read FStorageDataType   Write FStorageDataType;
    Property  RESTDWIndexes  [Aindex : Integer] : TRESTDWIndex        Read GetBufIndex;
    Property  RESTDWIndexDefs[Aindex : Integer] : TRESTDWDatasetIndex Read GetBufIndexDef;
  published
    Property  Capacity           : Integer            Read GetCapacity        Write SetCapacity    Default 0;
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
    Property  IndexDefs         : TIndexDefs         Read GetIndexDefs;
    Property  IndexName         : String             Read GetIndexName       Write SetIndexName;
    Property  IndexFieldNames   : String             Read GetIndexFieldNames Write SetIndexFieldNames;
    Property  MaxIndexesCount   : Integer            Read FMaxIndexesCount   Write SetMaxIndexesCount default 2;
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
   Function  GetBlobSize : Longint;
   Function  GetBlobFromRecord(Field : TField) : TMemBlobData;
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
   Procedure  Truncate;
  End;
  TRESTDWMTMemoryRecord = Class(TPersistent)
  Private
   FMemoryData : TRESTDWMemTable;
   FIndex,
   FID         : Integer;
   FData       : Pointer;
   FBlobs      : TMemBlobArray;
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
   Property    Blobs      : TMemBlobArray   Read FBlobs      Write FBlobs;
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
  {$IF Defined(MSWINDOWS) or Defined(WIN32) or Defined(WIN64) or Defined(WINDOWS)}
   Procedure InternalAddRecord (Buffer      : Pointer;
                                {$IFDEF FPC}aAppend : Boolean{$ELSE}Append : Boolean{$ENDIF});Overload;
  {$IFEND}
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

Function IsNullData(DataList : TRESTDWBytes) : Boolean;
Var
 I : Integer;
Begin
 Result := True;
 For I := 0 to Length(DataList) -1 Do
  Begin
   If DataList[I] <> 0 Then
    Begin
     Result := False;
     Break;
    End;
  End;
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
  Result := 0
 Else If FieldType In ftBlobTypes Then
  Result := SizeOf(Pointer)
 Else
  Begin
   Result := Size;
   vDWFieldType := FieldTypeToDWFieldType(FieldType);    //Gledston - Alterei a partir deste ponto
   Case vDWFieldType of
     dwftString    : Inc (Result, Size);
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
     dwftTime      : Result := SizeOf(LongInt)+ 8;
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
     {$IFNDEF FPC}
      {$IF CompilerVersion >= 20}
      dwftLongWord       : Result := SizeOf(LongWord);
      dwftShortint       : Result := SizeOf(Shortint);
      dwftByte           : Result := SizeOf(Byte);
      //dwftExtended       : Result := SizeOf(Double);  //Gledston
      {$IFEND}
     {$ENDIF}
     dwftADT             : Result := 0;
     dwftFixedChar       : Inc(Result);
     dwftWideString      : Result := Result * SizeOf(WideChar);
     dwftVariant         : Result := SizeOf(Variant);
     dwftGuid            : Result := GuidSize;
     dwftWideMemo,
     dwftBlob,
     dwftMemo,
     dwftBytes,
     dwftVarBytes,
     dwftFmtMemo,
     dwftOraBlob,
     dwftOraClob         : Result := SizeOf(Pointer);
   End;
  End;
 If vDWFieldType      In FieldGroupVariant Then
  Result := SizeOf(Variant)
 Else If vDWFieldType In FieldGroupGUID    Then
  Result := GuidSize + 1;
 If Result > 0 Then
  Result := Result + SizeOf(Boolean);
End;

Procedure CalcDataSize(FieldDef: TFieldDef; Var DataSize: Integer);Overload;
Var
 I : Integer;
Begin
 If FieldDef.datatype in ftSupported - ftBlobTypes then
  Inc(DataSize, CalcFieldLen(FieldDef.datatype, FieldDef.Size));
 If FieldDef.datatype in ftBlobTypes then
  Inc(DataSize, CalcFieldLen(FieldDef.datatype, FieldDef.Size));
// {$IFNDEF FPC}
//  For I := 0 to FieldDef.ChildDefs.Count - 1 do
//   CalcDataSize(FieldDef.ChildDefs[I], DataSize);
// {$ENDIF}
End;

Procedure CalcDataSize(Field: TField; Var DataSize: Integer);Overload;
Begin
 If Field.datatype in ftSupported - ftBlobTypes then
  Inc(DataSize, CalcFieldLen(Field.datatype, Field.Size));
 If Field.datatype in ftBlobTypes then
  Inc(DataSize, CalcFieldLen(Field.datatype, Field.Size));
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
 Finalize(FBlobs);
 SetLength(FBlobs, 0);
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
     If FMemoryData.BlobFieldCount > 0 Then
      Finalize(FBlobs[0], FMemoryData.BlobFieldCount);
     FMemoryData.FRecords.Remove(Self);
     SetLength(FBlobs, 0);
     {$IFDEF FPC}
      ReallocMem(FData, 0);
     {$ELSE}
      FreeMem(FData, SizeOf(FData));
     {$ENDIF}
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
       SetLength(FBlobs, 0);
       SetLength(FBlobs, Value.BlobFieldCount);
      End;
     DataSize := 0;
     For I := 0 to Value.Fields.Count - 1 do
      CalcDataSize(Value.Fields[I], DataSize);
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
 Inherited Create(AOwner);
 FRecordPos         := -1;
 FRecordFilterPos   := -1;
 aFilterRecs        := FRecordFilterPos;
 FLastID            := Low(Integer);
 FAutoInc           := 1;
 FRecords           := TRecordList.Create;
 FStatusName        := STATUSNAME;
 FDeletedValues     := TList.Create;
 FRowsOriginal      := 0;
 FRowsChanged       := 0;
 FRowsAffected      := 0;
 FPacketRecords     := -1;
 FMaxIndexesCount   := 2;
 FSaveLoadState     := slsNone;
 FOneValueInArray   := True;
 FDataSetClosed     := False;
 FRefreshing        := False;
 FAllPacketsFetched := False;
 FTrimEmptyString   := True;
 FStorageDataType   := Nil;
 FIndexes           := TRESTDWDatasetIndexDefs.Create(Self);
End;

destructor TRESTDWMemTable.Destroy;
var
 I        : Integer;
 PFValues : TPVariant;
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
    For I := 0 to (FDeletedValues.Count - 1) do
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
 ClearIndexes;
 FreeAndNil(FIndexes);
 FRecords.Free;
 FOffsets := nil;
 //FreeFieldBuffers;
 FActive := False;
 //FBlobOfs := 0;
 FDataSet := Nil;
 FDataSet.Free;
 inherited Destroy;
End;

Function TRESTDWMemTable.CompareFields(Data1, Data2: Pointer; FieldType: TFieldType;
  CaseInsensitive: Boolean): Integer;
Var
 vData1,
 vData2  : String;
Begin
  Result := 0;
  case FieldType of
    ftString : Begin
                vData1 := StrPas(PAnsiChar(Data1));
                vData2 := StrPas(PAnsiChar(Data2));
                If CaseInsensitive then
                 Result := AnsiCompareText(vData1, vData2)
                Else
                 Result := AnsiCompareStr(PDWString(@Data1)^, PDWString(@Data2)^);
               End;
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
    ftFixedChar : Begin
                   vData1 := StrPas(PAnsiChar(Data1));
                   vData2 := StrPas(PAnsiChar(Data2));
                   If CaseInsensitive then
                    Result := AnsiCompareText(vData1, vData2)
                   Else
                    Result := AnsiCompareStr (vData1, vData2);
                  End;
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
    ftGuid : Begin
              vData1 := StrPas(PAnsiChar(Data1));
              vData2 := StrPas(PAnsiChar(Data2));
              Result := CompareText(vData1, vData2);
             End;
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
    If Result <> Nil Then
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
//  Result := TRESTDWMTMemoryRecord(TRecordList(Pointer(@FRecords)^)[Index]);
End;

Procedure TRESTDWMemTable.InitFieldDefsFromFields;
var
  I        : Integer;
  Offset   : Integer;
  Field    : TField;
  FieldDefsUpdated : Boolean;
  FieldLen : Word;
  Procedure CalcOffSets;
  Var
   I : Integer;
  Begin
   {$IFNDEF FPC}
   If Fields.Count > 0 Then
    Begin
     SetLength(FOffsets, Fields.Count);
     Try
      for I := 0 to Fields.Count - 1 do
       Begin
        FOffsets[I] := Offset;
        If Fields[I].datatype in ftSupported - ftBlobTypes then
        Begin
          FieldLen := CalcFieldLen(Fields[I].datatype, Fields[I].Size);
          If Offset + FieldLen<= high(Offset) then
            Inc(Offset, FieldLen)
          Else
            raise ERangeError.CreateResFmt(@RsEFieldOffsetOverflow, [I]);
        End;
       End;
     Finally
     End;
    End
   Else
    Begin
     {$ENDIF}
     SetLength(FOffsets, FieldDefs.Count);
     FieldDefs.Update;
     FieldDefsUpdated := FieldDefs.Updated;
     Try
      FieldDefs.Updated := True;
      // Performance optimization: FieldDefList.Updated returns False is FieldDefs.Updated is False
      For I := 0 to FieldDefs.Count - 1 do
       Begin
        FOffsets[I] := Offset;
        If FieldDefs[I].datatype in ftSupported - ftBlobTypes then
         Begin
          FieldLen := CalcFieldLen(FieldDefs[I].datatype, FieldDefs[I].Size);
          If Offset + FieldLen<= high(Offset) then
           Inc(Offset, FieldLen)
          Else
           Raise ERangeError.CreateResFmt(@RsEFieldOffsetOverflow, [I]);
         End;
       End;
     Finally
      FieldDefs.Updated := FieldDefsUpdated;
     End;
     {$IFNDEF FPC}
    End;
        {$ENDIF}
  End;
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
  SetLength(FOffsets, Offset);
  inherited InitFieldDefsFromFields;
  { Calculate fields offsets }
  CalcOffSets;
End;

Function TRESTDWMemTable.FindFieldIndex(Field : TField) : Integer;
Var
 I : Integer;
Begin
 REsult := -1;
 For I := 0 To Fields.Count -1 Do
  Begin
   If Fields[I] = Field Then
    Begin
     Result := I;
     Break;
    End;
  End;
End;

Function TRESTDWMemTable.FindFieldData(Buffer: Pointer; Field: TField): Pointer;
var
 Index    : Integer;
 datatype : TFieldType;
Begin
 Result := nil;
 // Index := Field.FieldNo - 1;
 // If Index  < 0 Then
 Index := FindFieldIndex(Field);
 // FieldDefList index (-1 and 0 become less than zero => ignored)
 If (Index  >= 0)   And
    (Buffer <> Nil) Then
  Begin
   datatype := Field.datatype;
   If datatype in ftSupported then
    If datatype in ftBlobTypes then
     Begin
      {$IFDEF FPC}
       Result := Pointer(GetBlobData(Field, Buffer));
      {$ELSE}
       {$IF CompilerVersion <= 22}
        Result := Pointer(@FBlobs[Field.Offset]);
       {$ELSE}
        Result := Pointer(GetBlobData(Field, Buffer));
       {$IFEND}
      {$ENDIF}
     End
    Else
     Begin
      {$IFDEF FPC}
       Result := Pointer(PRESTDWMTMemBuffer(Buffer + FOffsets[Index]));
      {$ELSE}
       Result := Pointer(PRESTDWMTMemBuffer(Buffer) + FOffsets[Index]);
      {$ENDIF}
     End;
  End;
End;

Function TRESTDWMemTable.CalcRecordSize: Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For I := 0 to Fields.Count - 1 do
  CalcDataSize(Fields[I], Result);
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
 FRecordPos       := -1;
 FRecordFilterPos := FRecordPos;
 aFilterRecs      := FRecordFilterPos;
End;

Function TRESTDWMemTable.AllocRecordBuffer: TRecordBuffer;
Begin
 {$IFDEF FPC}
  GetMem(Result, FRecBufSize);
 {$ELSE}
  {$IFDEF DELPHI10_0UP}
   GetMem(Result, FRecBufSize);
  {$ELSE}
   Result := StrAlloc(FRecBufSize);
  {$ENDIF DELPHI10_0UP}
 {$ENDIF}
 SetLength(FBlobs, 0);
 If BlobFieldCount > 0 Then
  SetLength(FBlobs, BlobFieldCount);
End;

Procedure TRESTDWMemTable.FreeRecordBuffer(Var Buffer: TRecordBuffer);
Begin
 If BlobFieldCount > 0 Then
  SetLength(FBlobs, 0);
 {$IFDEF FPC}
  FreeMem(Buffer);
 {$ELSE}
  {$IFDEF DELPHI10_0UP}
   FreeMem(Buffer, 0);
  {$ELSE}
   StrDispose(Buffer);
  {$ENDIF DELPHI10_0UP}
 {$ENDIF}
 Buffer := nil;
End;

Procedure TRESTDWMemTable.ClearCalcFields(Buffer : {$IFDEF NEXTGEN}NativeInt{$ELSE}TRecordBuffer{$ENDIF});
Begin
//{$IFNDEF NEXTGEN}
// FillChar(Buffer[FRecordSize], CalcFieldsSize, 0);
//{$ENDIF !NEXTGEN}
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

Procedure TRESTDWMemTable.InternalInitRecord(Buffer : {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF});
Begin
// {$IFDEF NEXTGEN}
//  FillChar(PChar(Buffer), FBlobOfs, 0);
// {$ELSE}
//  FillChar(Buffer^, FBlobOfs, 0);
// {$ENDIF}
End;

Procedure TRESTDWMemTable.InitRecord(Buffer : {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF});
Var
 vBoolean      : Boolean;
 PActualRecord : PRESTDWMTMemBuffer;
 PData         : {$IFDEF FPC}PAnsiChar{$ELSE}PByte{$ENDIF};
 aFieldCount,
 I, aIndex,
 cLen          : Integer;
 aDataType     : TFieldType;
 aFields       : TFields;
 Fld           : TField; // Else BAD mem leak on 'Field.asString'
Begin
 vBoolean := True;
 {$IFDEF NEXTGEN}
  Inherited InitRecord({$IFDEF RTL250_UP}TRecBuf{$ENDIF}(Buffer));
 {$ELSE}
  // in non-NEXTGEN InitRecord(TRectBuf) calls InitRecord(TRecordBuffer) => Endless recursion
  {$WARN SYMBOL_DEPRECATED OFF} // XE4
   Inherited InitRecord({$IFDEF RTL250_UP}TRecordBuffer{$ENDIF}(Buffer));
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
    aIndex := I;
    If DataTypeSuported(aDataType) Then
     Begin
      If Not DataTypeIsBlobTypes(aDataType) Then
       PData := Pointer(PActualRecord + GetOffSets(aIndex))
      Else
       PData := Pointer(@FBlobs[Fld.Offset]);
      If (PData <> Nil) Then
       Begin
        Case FieldTypeToDWFieldType(aDataType) Of
          dwftFixedChar,
          dwftString,
          dwftWideString,
          dwftFixedWideChar : Begin
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
          dwftByte,
          dwftShortint,
          dwftSmallint,
          dwftWord,
          dwftInteger,
          dwftAutoInc,
          dwftLargeint,
          dwftDate,
          dwftTime,
          dwftDateTime,
          dwftTimeStamp,
          dwftSingle,
          dwftTimeStampOffset,
          dwftFloat,
          dwftFMTBcd,
          dwftCurrency,
          dwftBCD           : Begin
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
          dwftStream,
          dwftBlob,
          dwftBytes,
          dwftMemo,
          dwftWideMemo,
          dwftFmtMemo : SetLength(PRESTDWBytes(PData)^, 0);
        End;
       End;
     End;
   End;
 Finally
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

Function TRESTDWMemTable.GetRecord(Buffer: {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF};
							      GetMode: TGetMode;
								  DoCheck: Boolean): TGetResult;
var
  Accept: Boolean;
Begin
  Result := grOk;
  Accept := True;
  case GetMode of
  gmPrior : Begin
             If FRecordPos <= 0 then
              Begin
               Result := grBOF;
               FRecordPos       := -1;
               FRecordFilterPos := FRecordPos;
              End
             Else
              Begin
//               aFilterRecs := RecordCount;
               Repeat
                Dec(FRecordPos);
                If Filtered then
                 Begin
                  Accept := RecordFilter;
                  If Accept Then
                    Dec(aFilterRecs);
                 End
                Else
                 FRecordFilterPos := FRecordPos;
               Until Accept Or (FRecordPos < 0);
               If Not Accept Then
                Begin
                 Result := grBOF;
                 FRecordPos := -1;
                End;
               FRecordFilterPos := aFilterRecs;
              End;
            End;
  gmCurrent : Begin
               If (FRecordPos < 0) or (FRecordPos >= FRecords.Count) then
                Result := grError
               Else If Filtered Then
                Begin
                 If Not RecordFilter Then
                  Result := grError;
                End;
              End;
  gmNext    : Begin
               If FRecordPos >= FRecords.Count - 1 Then
                Result := grEOF
               Else
                Begin
                 Repeat
                  Inc(FRecordPos);
                  If Filtered Then
                   Begin
                    Accept := RecordFilter;
                    If Accept Then
                     Inc(aFilterRecs);
                   End;
                 Until Accept or (FRecordPos > FRecords.Count - 1);
                 If Not Accept Then
                  Begin
                   Result := grEOF;
                   FRecordPos       := RecordCount - 1;
                  End;
                 FRecordFilterPos := aFilterRecs;
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
  For I := 0 To BlobFieldCount - 1 Do
   FBlobs[I] := Rec.FBlobs[I];
  GetCalcFields({$IFNDEF FPC}{$IFDEF NEXTGEN}TRecBuf{$ELSE}
                             {$IF CompilerVersion <= 22}Pointer{$ELSE}
                             TRecordBuffer{$IFEND}{$ENDIF}
                {$ELSE}TRecordBuffer{$ENDIF}(Buffer));
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
      RecBuf := PRESTDWMTMemBuffer(TempBuffer);//PRESTDWMTMemBuffer(ActiveBuffer);//PRESTDWMTMemBuffer(CalcBuffer);
    dsFilter:
      RecBuf := PRESTDWMTMemBuffer(TempBuffer);
  Else
    RecBuf := nil;
  End;
  Result := RecBuf <> nil;
End;

Function TRESTDWMemTable.InternalGetFieldData(Field       : TField;
                                               Var Buffer : TRESTDWMTValueBuffer) : Boolean;
Var
 aNullData    : Boolean;
 RecBuf       : PRESTDWMTMemBuffer;
 Data         : PByte;
 VarData      : Variant;
 aVarData     : ^TMemBlobData;
 L, cLen      : Integer;
 aDataBytes,
 aBytes       : TRESTDWBytes;
 pBytes       : PRESTDWBytes;
 vDWFieldType : Byte;
Begin
 Result := False;
 If Not GetActiveRecBuf(RecBuf) Then
  Exit;
 If Not IsEmpty         And
   ((Field.FieldNo > 0) Or
    (Field.FieldKind    in [fkCalculated, fkLookup])) Then
  Begin
   Data := FindFieldData(RecBuf, Field);
   If (Data <> nil) Or (Field is TBlobField) then
    Begin
     Result := (Field is TBlobField);
     If Not Result Then
      Result := Data <> Nil;
     cLen      := GetCalcFieldLen(Field.datatype, Field.Size);
     Case Field.datatype Of
      ftGuid      : Result := Result and (StrLen({$IFNDEF FPC}{$IF CompilerVersion <= 22}PAnsiChar(Data)

                                            {$ELSE}PChar(Data){$IFEND}
                                            {$ELSE}PAnsiChar(Data){$ENDIF}) > 0);
      ftString,
      ftFixedChar
      {$IF DEFINED(FPC) OR DEFINED(DELPHI10_0UP)}
       , ftFixedWideChar
       , ftWideString
      {$IFEND}    : Begin
                     SetLength(aDataBytes, cLen);
                     Move(Data^, aDataBytes[0], cLen);
                     Result := Result and (not (Char(aDataBytes[0]) = #0));
                    End;
      ftBoolean : Begin
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
      ftWord,
      {$IFNDEF FPC}
       {$IF CompilerVersion >= 20}
        ftByte,
        ftShortint,
        ftLongWord,
        ftExtended,
        ftSingle,
       {$IFEND}
      {$ENDIF}
      ftAutoInc,
      ftLargeint,
      ftInteger,
      ftSmallint,
      ftFloat,
      ftFMTBCD,
      ftBCD,
      ftCurrency,
      ftTimestamp,
      ftDate,
      ftTime,
      ftDateTime : Begin
                    SetLength(aDataBytes, cLen);
                    Move(Data^, aDataBytes[0], cLen);
                    aNullData := IsNullData(aDataBytes);
                    If Not aNullData then
                     Begin
                      Move(aDataBytes[0], Pointer(@aNullData)^, SizeOf(Boolean));
                      Result := Not(aNullData);
                     End
                    Else
                     Result := Not aNullData;
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
           aBytes := Records[RecNo - 1].Blobs[Field.Offset];
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
           aBytes := Records[RecNo - 1].Blobs[Field.Offset];
           If Length(TRESTDWBytes(Buffer)) > 0 Then
            Begin
             pBytes := Pointer(@PMemBlobArray(Records[RecNo - 1].Blobs[Field.Offset]));
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
         SetLength(aBytes, 0);
        End
       Else
        Begin
         cLen := GetCalcFieldLen(Field.datatype, Field.Size);
         {$IFNDEF FPC}
          {$IF CompilerVersion <= 22}
           If Result Then
            Result := ((Not(aNullData)) and Not(VarIsNull(Data^)));
           If (Field.datatype In [ftLargeint, ftInteger, ftSmallint, ftFloat,
                                  ftFMTBCD, ftBCD, ftCurrency, ftDate, ftTime]) Then
            Result := PRESTDWBytes(@Data)^[1] > 0;
           If Result Then
            Begin
             If (Field.datatype In [ftLargeint, ftInteger, ftSmallint, ftFloat, ftFMTBCD, ftBCD,
                                    ftCurrency, ftDate, ftTime, ftDateTime, ftTimestamp]) Then
              Move(PRESTDWBytes(@Data)^[1], Pointer(Buffer)^, cLen-1)
             Else
              Move(PRESTDWBytes(@Data)^[0], Pointer(Buffer)^, cLen);
            End;
           {$ELSE}
            If Length(TRESTDWBytes(Buffer)) = 0 Then
             SetLength(TRESTDWBytes(Buffer), cLen);
            Result := ((Not(aNullData)) and Not(VarIsNull(Data^)));
            If (Field.datatype In [ftAutoInc, ftLargeint, ftInteger, ftSmallint, ftFloat, ftSingle,
                                   ftFMTBCD, ftBCD, ftCurrency, ftDate, ftTime, ftDateTime, ftTimestamp]) Then
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
         SetLength(aDataBytes, 0);
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
                             {$ENDIF DELPHI10_0UP}{$ENDIF},
                              ftFMTBCD, ftBCD, ftCurrency, ftDate,
                              ftTime, ftDateTime, ftTimestamp]) Then
        Move(aDataBytes[1], Pointer(Buffer)^, cLen-1)
       Else
        Move(aDataBytes[0], Pointer(Buffer)^, cLen);
       SetLength(aDataBytes, 0);
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

Procedure TRESTDWMemTable.InternalSetFieldData(Field                : TField;
                        		       Buffer               : Pointer;
					       Const ValidateBuffer : TRESTDWMTValueBuffer);
Var
  PActualRecord	          : PRESTDWMTMemBuffer;
  Data			  : {$IFDEF FPC}PAnsiChar{$ELSE}PByte{$ENDIF};
  aBytes		  : TRESTDWBytes;
  pBytes		  : PRESTDWBytes;
  VarData		  : Variant;
  aResult,
  vBoolean,
  IsData		  : Boolean;
  aIndex,
  cLen	   	          : Integer;
  aDataType		  : TFieldType;
  Procedure GetDataValue;
  Begin
   // The non-NEXTGEN Pointer version has "TArray<Byte> := Pointer" in it what interprets an untypes pointer as dyn. array. Not good.
   If Field.FieldKind <> fkInternalCalc Then
    Begin
     aIndex := FindFieldIndex(Field);
     Data   := FindFieldData(PActualRecord, Field);
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
                                    {$IF CompilerVersion >= 20}
                                     ftByte, ftShortint, ftLongWord, ftExtended,  ftSingle,
                                    {$IFEND}
                                   {$ENDIF}
                                    ftLargeint, ftInteger, ftSmallint, ftFloat, ftFMTBCD,
                                    ftBCD, ftCurrency, ftDate, ftTime, ftDateTime, ftTimestamp] Then
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
               FillChar(Data^, 1, 'S');
              End;
            End
           Else
            Begin
             cLen := GetCalcFieldLen(Field.datatype, Field.Size);
             Case FieldTypeToDWFieldType(aDataType) of
               dwftWideString,
               dwftFixedWideChar,
               dwftFixedChar,
               dwftString         : Begin
                                     {$IFDEF FPC}
                                      FillChar(Data^, cLen, #0);
                                     {$ELSE}
                                      FillChar(Data^, cLen, 0);
                                     {$ENDIF}
                                     Move(buffer^, data^, cLen);
                                    End;
               dwftWord,
               dwftAutoInc,
               {$IFNDEF FPC}
                {$IF CompilerVersion >= 20}
                 dwftByte, dwftShortint, dwftLongWord, dwftSingle,
                {$IFEND}
               {$ENDIF}
               dwftLargeint,
               dwftInteger,
               dwftSmallint,
               dwftFloat,
               dwftFMTBCD,
               dwftBCD,
               dwftCurrency,
               dwftDate,
               dwftTime,
               dwftDateTime,
               dwftTimestamp,
               dwftBoolean : Begin
                              vBoolean := Length(TRESTDWBytes(Buffer)) = 0;
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
 End;
Begin
 IsData   := False;
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
   GetDataValue;
  End
 Else { fkCalculated, fkLookup }
  GetDataValue;
 If Not(State In [dsCalcFields, dsFilter, dsNewValue]) Then
  DataEvent(deFieldChange, NativeInt(Field));
End;

Function  TRESTDWMemTable.GetBlob(aRecNo, Index    : Integer) : PMemBlobData;
Begin
 If aRecNo > 0 Then
  Begin
   If State in [dsEdit, dsBrowse] then
    Begin
     If Length(frecords[arecNo -1].fblobs) > 0 Then
      Result := @frecords[arecNo -1].fblobs[Index]
     Else
      Result := @fblobs[Index];
    End
   Else If State in [dsInsert] then
    Result := @fblobs[Index];
  End
 Else
  Result := @fblobs[Index];
End;

Procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: TRESTDWMTValueBuffer);
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion <= 22}
   If Length(TRESTDWBytes(Buffer)) > 0 Then
    InternalSetFieldData(Field, {$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer)
   Else
    InternalSetFieldData(Field, {$IFDEF RTL240_UP}PByte(@Buffer){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
  {$ELSE}
   If Length(Buffer) > 0 Then
    InternalSetFieldData(Field, {$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP},TRESTDWMTValueBuffer(Buffer))
   Else
    InternalSetFieldData(Field, {$IFDEF RTL240_UP}PByte(@Buffer){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
  {$IFEND}
 {$ELSE}
  If Length(TRESTDWBytes(Buffer)) > 0 Then
   InternalSetFieldData(Field, {$IFDEF RTL240_UP}PByte(@Buffer[0]){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer)
  Else
   InternalSetFieldData(Field, {$IFDEF RTL240_UP}PByte(@Buffer){$ELSE}Buffer{$ENDIF RTL240_UP}, Buffer);
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
    aFilterRecs := 0;
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
Var
 vElemSize : Integer;
Begin
 If frecords.Count > 0 Then
  Begin
   If frecords.Count > recNo Then
    Begin
     If Length(frecords[recNo -1].fblobs) > 0 Then
      Result := frecords[recNo -1].fblobs[Field.Offset]
     Else
      Result := fblobs[Field.Offset];
    End
   Else
    Begin
     vElemSize := Length(fblobs);
     If (Field.Offset +1) > vElemSize Then
      SetLength(fblobs, Field.Offset +1);
     Result := fblobs[Field.Offset];
    End;
  End
 Else
  Result := FBlobs[Field.Offset];
End;

Procedure TRESTDWMemTable.SetBlobData(Field: TField; Buffer: PRESTDWMTMemBuffer;
  Value: TMemBlobData);
Begin
 If Buffer = PRESTDWMTMemBuffer(ActiveBuffer) then
  Begin
   If State = dsFilter then
    Error('Not Editing...');
   If frecords.Count > recNo Then
    Begin
     If Length(frecords[recNo -1].fblobs) > 0 Then
      Begin
       frecords[recNo -1].fblobs[Field.Offset] := Value;
       fblobs[Field.Offset]                    := Value;
      End
     Else
      fblobs[Field.Offset] := Value;
    End
   Else
    fblobs[Field.Offset] := Value;
  End;
End;

Procedure TRESTDWMemTable.CloseBlob(Field: TField);
Begin
// If (FRecordPos >= 0) and (FRecordPos < FRecords.Count) and (State = dsEdit) then
//  Begin
//   SetLength(Records[FRecordPos].FBlobs[Field.Offset], 0);
//   SetLength(FBlobs[Field.Offset], 0);
//  End
 SetLength(FBlobs[Field.Offset], 0);
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
 FRecordPos       := -1;
 FRecordFilterPos := 0;
 aFilterRecs      := FRecordFilterPos;
End;

Procedure TRESTDWMemTable.InternalLast;
Begin
 FRecordPos       := FRecords.Count;
 FRecordFilterPos := RecordCount;
 aFilterRecs      := FRecordFilterPos;
End;

Function TRESTDWMemTable.GetDataset: TDataset;
Begin
  Result := TDataset(Self);
End;

Procedure TRESTDWMemTable.ClearIndexes;
Var
 i : integer;
Begin
 CheckInactive;
 For I:=0 to FIndexes.Count-1 do
  RESTDWIndexDefs[i].Clearindex;
End;

Function TRESTDWMemTable.GetCalcFieldLen(FieldType: TFieldType; Size: Word): Word;
Begin
  Result := CalcFieldLen(FieldType, Size);
End;

Function TRESTDWMemTable.GetBlobRec(Field: TField; Rec: TRESTDWMTMemoryRecord): TMemBlobData;
Begin
  Result := PMemBlobArray(Rec.FBlobs)^[Field.Offset];
End;

Function TRESTDWMemTable.GetOffSets(aField : TField) : Word;
Begin
 Result := FOffsets[FindFieldIndex(aField)];//FOffsets[index];
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

Function TRESTDWMemTable.GetIndexFieldNames : String;
Var
 i,
 p        : Integer;
 s        : String;
 IndexBuf : TRESTDWIndex;
Begin
 Result   := FIndexFieldNames;
 IndexBuf := GetCurrentIndexBuf;
 If (IndexBuf = Nil) then
  Exit;
 Result:='';
 For I := 1 to WordCount(IndexBuf.FieldsName, [Limiter]) Do
  Begin
   s := ExtractDelimited(i, IndexBuf.FieldsName, [Limiter]);
   p := Pos(s, IndexBuf.DescFields);
   If p > 0 Then
    s := s + Desc;
   Result := Result + Limiter + s;
  End;
 If (Length(Result) > 0)  And
    (Result[1] = Limiter) Then
  system.Delete(Result, 1, 1);
End;

Function TRESTDWMemTable.DefaultIndex: TRESTDWDatasetIndex;
Begin
 Result := FDefaultIndex;
 If Result = Nil then
  If FIndexes <> Nil Then
   Result:=FIndexes.FindIndex(SDefaultIndex);
end;

Function TRESTDWMemTable.DefaultBufferIndex: TRESTDWIndex;
Begin
 If DefaultIndex <> Nil Then
  Result := DefaultIndex.BufferIndex
 Else
  Result := Nil;
End;

function TRESTDWMemTable.Fetch: boolean;
Begin
 Result := False;
End;

Function DBCompareText(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 If [loCaseInsensitive,loPartialKey] = options Then
  Result := AnsiStrLIComp(pchar(subValue),pchar(aValue),length(pchar(subValue)))
 Else If [loPartialKey]              = options Then
  Result := AnsiStrLComp(pchar(subValue),pchar(aValue),length(pchar(subValue)))
 Else If [loCaseInsensitive]         = options then
  Result := AnsiCompareText(pchar(subValue),pchar(aValue))
 Else
  Result := AnsiCompareStr(pchar(subValue),pchar(aValue));
end;

Function DBCompareWideText(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 If [loCaseInsensitive, loPartialKey] = options Then
  Result := WideCompareText(pwidechar(subValue), LeftStr(pwidechar(aValue), Length(pwidechar(subValue))))
 Else If [loPartialKey]               = options Then
  Result := WideCompareStr(pwidechar(subValue),LeftStr(pwidechar(aValue), Length(pwidechar(subValue))))
 Else If [loCaseInsensitive]          = options Then
  Result := WideCompareText(pwidechar(subValue),pwidechar(aValue))
 Else
  Result := WideCompareStr(pwidechar(subValue),pwidechar(aValue));
End;

Function DBCompareByte(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 Result := PByte(subValue)^-PByte(aValue)^;
End;

Function DBCompareSmallInt(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 Result := PSmallInt(subValue)^-PSmallInt(aValue)^;
End;

Function DBCompareInt(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 Result := PInteger(subValue)^-PInteger(aValue)^;
End;

Function DBCompareLargeInt(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 // A simple subtraction doesn't work, since it could be that the result
 // doesn't fit into a LargeInt
 If PInt64(subValue)^       < PInt64(aValue)^ Then
  Result := -1
 Else If PInt64(subValue)^  > PInt64(aValue)^ Then
  Result := 1
 Else
  Result := 0;
End;

Function DBCompareWord(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 Result := PWord(subValue)^-PWord(aValue)^;
End;

Function DBCompareQWord(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
// // A simple subtraction doesn't work, since it could be that the result
// // doesn't fit into a LargeInt
// If PQWord(subValue)^       < PQWord(aValue)^ Then
//  Result := -1
// Else If PQWord(subValue)^  > PQWord(aValue)^ Then
//  Result := 1
// Else
//  Result := 0;
 Raise Exception.Create('Unsupported QWord Type...');
End;

Function DBCompareDouble(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 // A simple subtraction doesn't work, since it could be that the result
 // doesn't fit into a LargeInt
 If PDouble(subValue)^       < PDouble(aValue)^ Then
  Result := -1
 Else If PDouble(subValue)^  > PDouble(aValue)^ Then
  Result := 1
 Else
  Result := 0;
End;

Function DBCompareBCD(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 Result := BCDCompare(PBCD(subValue)^, PBCD(aValue)^);
end;

Function DBCompareBytes(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 Result := CompareByte(subValue^, aValue^, size);
End;

function DBCompareVarBytes(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Var
 len1,
 len2 : LongInt;
Begin
 len1 := PWord(subValue)^;
 len2 := PWord(aValue)^;
 subValue := Pointer(Integer(subValue) + Sizeof(Word));
 aValue   := Pointer(Integer(aValue)   + Sizeof(Word));
// Inc(subValue, Sizeof(Word));
// Inc(aValue,   Sizeof(Word));
 If len1 > len2 then
  Result := CompareByte(subValue^, aValue^, len2)
 Else
  Result := CompareByte(subValue^, aValue^, len1);
 If Result = 0 then
  Result := len1 - len2;
End;

Function TRESTDWMemTable.BufferOffset : Integer;
Begin
  // Returns the offset of data buffer in bufdataset record
 Result := Sizeof(TRESTDWRecLinkItem) * FMaxIndexesCount;
End;

procedure TRESTDWMemTable.ProcessFieldsToCompareStruct(Const AFields,
                                                       ADescFields,
                                                       ACInsFields          : TList;
                                                       Const AIndexOptions  : TIndexOptions;
                                                       Const ALocateOptions : TLocateOptions;
                                                       out ACompareStruct   : TDBCompareStruct);
Var
 i,
 vDataSize   : Integer;
 AField      : TField;
 ACompareRec : TDBCompareRec;
Begin
 vDataSize := 0;
 SetLength(ACompareStruct, AFields.Count);
 For i := 0 To high(ACompareStruct) Do
  Begin
   AField := TField(AFields[i]);
   Case AField.DataType of
     ftString,
     ftFixedChar,
     ftGuid          : ACompareRec.CompareFunc := @DBCompareText;
     ftWideString
     {$IFNDEF FPC}
      {$IF CompilerVersion >= 20}
       , ftFixedWideChar
      {$IFEND}
     {$ELSE}
      , ftFixedWideChar
     {$ENDIF FPC}    : ACompareRec.CompareFunc := @DBCompareWideText;
     ftSmallint      : ACompareRec.CompareFunc := @DBCompareSmallInt;
     ftInteger,
     ftAutoInc       : ACompareRec.CompareFunc := @DBCompareInt;
     ftLargeint,
     ftBCD           : ACompareRec.CompareFunc := @DBCompareLargeInt;
     ftWord          : ACompareRec.CompareFunc := @DBCompareWord;
     ftBoolean       : ACompareRec.CompareFunc := @DBCompareByte;
     ftDate,
     ftTime,
     ftDateTime,
     ftFloat,
     ftCurrency      : ACompareRec.CompareFunc := @DBCompareDouble;
     ftFmtBCD        : ACompareRec.CompareFunc := @DBCompareBCD;
     ftVarBytes      : ACompareRec.CompareFunc := @DBCompareVarBytes;
     ftBytes         : ACompareRec.CompareFunc := @DBCompareBytes;
    Else
     DatabaseErrorFmt(SErrIndexBasedOnInvField, [AField.FieldName,
                                                 Fieldtypenames[AField.DataType]]);
   End;
   ACompareRec.Off      := FOffsets[FindFieldIndex(aField)];
   ACompareRec.NullBOff := BufferOffset;
   ACompareRec.FieldInd := AField.FieldNo-1;
   CalcDataSize(AField, vDataSize);
   ACompareRec.Size     := vDataSize;
//   GetFieldSize(FieldDefs[ACompareRec.FieldInd]);
   ACompareRec.Desc     := ixDescending in AIndexOptions;
   If Assigned(ADescFields) Then
    ACompareRec.Desc    := ACompareRec.Desc or (ADescFields.IndexOf(AField)>-1);
   ACompareRec.Options  := ALocateOptions;
   If Assigned(ACInsFields) And
      (ACInsFields.IndexOf(AField)>-1) then
   ACompareRec.Options  := ACompareRec.Options + [loCaseInsensitive];
   ACompareStruct[i]    := ACompareRec;
  End;
End;

Function GetFieldIsNull(NullMask : pbyte;
                        x        : longint) : boolean; //inline;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   Result := ord(NullMask[x Div 8]) And (1 Shl (x Mod 8)) > 0
  {$ELSE}
   Result := ord(TRESTDWBytes(NullMask)[x Div 8]) And (1 Shl (x Mod 8)) > 0
  {$IFEND}
 {$ELSE}
  Result := ord(NullMask[x Div 8]) And (1 Shl (x Mod 8)) > 0
 {$ENDIF}
End;

Function IndexCompareRecords(Rec1,
                             Rec2           : Pointer;
                             ADBCompareRecs : TDBCompareStruct) : LargeInt;
Var
 IndexFieldNr : Integer;
 IsNull1,
 IsNull2      : Boolean;
Begin
 For IndexFieldNr := 0 To length(ADBCompareRecs)-1 Do
  Begin
   With ADBCompareRecs[IndexFieldNr] Do
    Begin
     IsNull1 := GetFieldIsNull(pbyte(Integer(rec1) + NullBOff), FieldInd);
     IsNull2 := GetFieldIsNull(pbyte(Integer(rec2) + NullBOff), FieldInd);
     If IsNull1 And IsNull2 Then
      Result := 0
     Else If IsNull1 then
      Result := -1
     Else if IsNull2 then
      Result := 1
     Else
      Result := CompareFunc(Pointer(Integer(Rec1) + Off), Pointer(Integer(Rec2) + Off), Size, Options);
     If Result <> 0 Then
      Begin
       If Desc Then
        Result := -Result;
       Break;
      End;
    End;
  End;
End;

Procedure TRESTDWMemTable.BuildIndex(AIndex : TRESTDWIndex);
Var
 PCurRecLinkItem : PRESTDWRecLinkItem;
 p,l,q           : PRESTDWRecLinkItem;
 i,k,psize,qsize,
 myIdx,defIdx,
 MergeAmount     : Integer;
 PlaceQRec       : Boolean;
 IndexFields,
 DescIndexFields,
 CInsIndexFields : TList;
 Index0,
 DblLinkIndex    : TDoubleLinkedBufIndex;
 Procedure PlaceNewRec(Var e     : PRESTDWRecLinkItem;
                       Var esize : Integer);
 Begin
  If DblLinkIndex.FFirstRecBuf = Nil Then
   Begin
    DblLinkIndex.FFirstRecBuf := e;
    {$IFNDEF FPC}
     {$IF CompilerVersion >= 20}
       e[myIdx].prior := Nil;
     {$ELSE}
      e.prior := Nil;
     {$IFEND}
    {$ELSE}
     e[myIdx].prior := Nil;
    {$ENDIF}
    l                         := e;
   End
  Else
   Begin
    {$IFNDEF FPC}
     {$IF CompilerVersion >= 20}
      l[myIdx].next  := e;
      e[myIdx].prior := l;
     {$ELSE}
      l.next  := e;
      e.prior := l;
     {$IFEND}
    {$ELSE}
     l[myIdx].next  := e;
     e[myIdx].prior := l;
    {$ENDIF}
    l              := e;
   End;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   e := e[myIdx].next;
  {$ELSE}
   e := e.next;
  {$IFEND}
 {$ELSE}
  e := e[myIdx].next;
 {$ENDIF}
  dec(esize);
 End;
Begin
  // Build the DBCompareStructure
  // One AS is enough, and makes debugging easier.
 DblLinkIndex := (AIndex as TDoubleLinkedBufIndex);
 Index0       := DefaultIndex.BufferIndex as TDoubleLinkedBufIndex;
 myIdx        := DblLinkIndex.IndNr;
 defIdx       := Index0.IndNr;
 With DblLinkIndex Do
  Begin
   IndexFields := TList.Create;
   DescIndexFields := TList.Create;
   CInsIndexFields := TList.Create;
   try
    GetFieldList(IndexFields,FieldsName);
    GetFieldList(DescIndexFields,DescFields);
    GetFieldList(CInsIndexFields,CaseinsFields);
    If IndexFields.Count = 0 Then
     DatabaseErrorFmt(SNoIndexFieldNameGiven,[DblLinkIndex.Name],Self);
    ProcessFieldsToCompareStruct(IndexFields, DescIndexFields, CInsIndexFields, Options, [], DBCompareStruct);
   Finally
    CInsIndexFields.Free;
    DescIndexFields.Free;
    IndexFields.Free;
   End;
  End;
 // This simply copies the index...
 PCurRecLinkItem := Index0.FFirstRecBuf;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   PCurRecLinkItem[myIdx].next := PCurRecLinkItem[defIdx].next;
   PCurRecLinkItem[myIdx].prior := PCurRecLinkItem[defIdx].prior;
  {$ELSE}
   //TODO XyberX
   PCurRecLinkItem.next  := DblLinkIndex.FFirstRecBuf.next;
   PCurRecLinkItem.prior := DblLinkIndex.FFirstRecBuf.prior;
  {$IFEND}
 {$ELSE}
  PCurRecLinkItem[myIdx].next := PCurRecLinkItem[defIdx].next;
  PCurRecLinkItem[myIdx].prior := PCurRecLinkItem[defIdx].prior;
 {$ENDIF}
 If PCurRecLinkItem <> Index0.FLastRecBuf Then
  Begin
   {$IFNDEF FPC}
    {$IF CompilerVersion >= 20}
     While PCurRecLinkItem[defIdx].next <> Index0.FLastRecBuf do
      Begin
       PCurRecLinkItem:=PCurRecLinkItem[defIdx].next;
       PCurRecLinkItem[myIdx].next := PCurRecLinkItem[defIdx].next;
       PCurRecLinkItem[myIdx].prior := PCurRecLinkItem[defIdx].prior;
      End;
    {$ELSE}
     While PCurRecLinkItem.next <> Index0.FLastRecBuf do
      Begin
       //TODO XyberX
       PCurRecLinkItem       := PCurRecLinkItem.next;
       PCurRecLinkItem.next  := Index0.FLastRecBuf.next;
       PCurRecLinkItem.prior := Index0.FLastRecBuf.prior;
      End;
    {$IFEND}
   {$ELSE}
    While PCurRecLinkItem[defIdx].next <> Index0.FLastRecBuf do
     Begin
      PCurRecLinkItem:=PCurRecLinkItem[defIdx].next;
      PCurRecLinkItem[myIdx].next := PCurRecLinkItem[defIdx].next;
      PCurRecLinkItem[myIdx].prior := PCurRecLinkItem[defIdx].prior;
     End;
   {$ENDIF}
  End
 Else // Empty dataset
  Exit;
 // Set FirstRecBuf and FCurrentRecBuf
 DblLinkIndex.FFirstRecBuf:=Index0.FFirstRecBuf;
 DblLinkIndex.FCurrentRecBuf:=DblLinkIndex.FFirstRecBuf;
 // Link in the FLastRecBuf that belongs to this index
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   PCurRecLinkItem[myIdx].next:=DblLinkIndex.FLastRecBuf;
   DblLinkIndex.FLastRecBuf[myIdx].prior:=PCurRecLinkItem;
  {$ELSE}
   //TODO XyberX
   PCurRecLinkItem.next:=DblLinkIndex.FLastRecBuf;
   DblLinkIndex.FLastRecBuf.prior:=PCurRecLinkItem;
  {$IFEND}
 {$ELSE}
  PCurRecLinkItem[myIdx].next:=DblLinkIndex.FLastRecBuf;
  DblLinkIndex.FLastRecBuf[myIdx].prior:=PCurRecLinkItem;
 {$ENDIF}
 // Mergesort. Used the algorithm as described here by Simon Tatham
 // http://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
 // The comments in the code are from this website.
 // In each pass, we are merging lists of size K into lists of size 2K.
 // (Initially K equals 1.)
 k := 1;
 Repeat
  // So we start by pointing a temporary pointer p at the head of the list,
  // and also preparing an empty list L which we will add elements to the end
  // of as we finish dealing with them.
  p := DblLinkIndex.FFirstRecBuf;
  DblLinkIndex.FFirstRecBuf := nil;
  q := p;
  MergeAmount := 0;
  // Then:
  // * If p is null, terminate this pass.
  While p <> DblLinkIndex.FLastRecBuf Do
   Begin
    //  * Otherwise, there is at least one element in the next pair of length-K
    //    lists, so increment the number of merges performed in this pass.
    Inc(MergeAmount);
    //  * Point another temporary pointer, q, at the same place as p. Step q along
    //    the list by K places, or until the end of the list, whichever comes
    //    first. Let psize be the number of elements you managed to step q past.
    i := 0;
    While (i<k) And (q<>DblLinkIndex.FLastRecBuf) Do
     Begin
      inc(i);
      {$IFNDEF FPC}
       {$IF CompilerVersion >= 20}
        q := q[myIDx].next;
       {$ELSE}
        //TODO XyberX
        q := q.next;
       {$IFEND}
      {$ELSE}
       q := q[myIDx].next;
      {$ENDIF}
     End;
    psize := i;
    //  * Let qsize equal K. Now we need to merge a list starting at p, of length
    //    psize, with a list starting at q of length at most qsize.
    qsize := k;
    //  * So, as long as either the p-list is non-empty (psize > 0) or the q-list
    //    is non-empty (qsize > 0 and q points to something non-null):
    While (psize  > 0) Or
          ((qsize > 0) And
           (q    <> DblLinkIndex.FLastRecBuf)) Do
     Begin
      //  * Choose which list to take the next element from. If either list
      //    is empty, we must choose from the other one. (By assumption, at
      //    least one is non-empty at this point.) If both lists are
      //    non-empty, compare the first element of each and choose the lower
      //    one. If the first elements compare equal, choose from the p-list.
      //    (This ensures that any two elements which compare equal are never
      //    swapped, so stability is guaranteed.)
      If (psize = 0)  Then
       PlaceQRec := true
      Else If (qsize = 0) Or
              (q     = DblLinkIndex.FLastRecBuf) Then
       PlaceQRec := False
      Else If IndexCompareRecords(p,q,DblLinkIndex.DBCompareStruct) <= 0 Then
       PlaceQRec := False
      Else
       PlaceQRec := True;
      //  * Remove that element, e, from the start of its list, by advancing
      //    p or q to the next element along, and decrementing psize or qsize.
      //  * Add e to the end of the list L we are building up.
      If PlaceQRec Then
       PlaceNewRec(q, qsize)
      Else
       PlaceNewRec(p, psize);
     End;
    //  * Now we have advanced p until it is where q started out, and we have
    //    advanced q until it is pointing at the next pair of length-K lists to
    //    merge. So set p to the value of q, and go back to the start of this loop.
    p := q;
   End;
  // As soon as a pass like this is performed and only needs to do one merge, the
  // algorithm terminates, and the output list L is sorted. Otherwise, double the
  // value of K, and go back to the beginning.
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   l[myIdx].next:=DblLinkIndex.FLastRecBuf;
  {$ELSE}
   //TODO XyberX
   l.next:=DblLinkIndex.FLastRecBuf;
  {$IFEND}
 {$ELSE}
  l[myIdx].next:=DblLinkIndex.FLastRecBuf;
 {$ENDIF}
 k:=k*2;
 Until MergeAmount = 1;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   DblLinkIndex.FLastRecBuf[myIdx].next:=DblLinkIndex.FFirstRecBuf;
   DblLinkIndex.FLastRecBuf[myIdx].prior:=l;
  {$ELSE}
   //TODO XyberX
   DblLinkIndex.FLastRecBuf.next  := DblLinkIndex.FFirstRecBuf;
   DblLinkIndex.FLastRecBuf.prior := l;
  {$IFEND}
 {$ELSE}
  DblLinkIndex.FLastRecBuf[myIdx].next  := DblLinkIndex.FFirstRecBuf;
  DblLinkIndex.FLastRecBuf[myIdx].prior := l;
 {$ENDIF}
End;

Procedure TRESTDWMemTable.BuildIndexes;
Var
 i : Integer;
Begin
 For i := 0 To FIndexes.Count -1 Do
  If RESTDWIndexDefs[i].MustBuild(FCurrentIndexDef) Then
   If Assigned(RESTDWIndexes[i]) Then
    BuildIndex(RESTDWIndexes[i])
   Else If RESTDWIndexDefs[i].Fields <> '' Then
    InternalAddIndex(SCustomIndex, RESTDWIndexDefs[i].Fields, [], '', '');
End;

Function TRESTDWMemTable.LoadField(FieldDef       : TFieldDef;
                                   buffer         : Pointer;
                                   out CreateBlob : boolean) : Boolean;
Begin
  // Empty procedure to make it possible to use TCustomBufDataset as a memory dataset
 CreateBlob := False;
 Result := False;
End;

Procedure SetFieldIsNull(NullMask : pbyte;x : longint); //inline;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   NullMask[x div 8] := (NullMask[x div 8]) or (1 shl (x mod 8));
  {$ELSE}
   //TODO XyberX
   TRESTDWBytes(NullMask)[x div 8] := (TRESTDWBytes(NullMask)[x div 8]) or (1 shl (x mod 8));
  {$IFEND}
 {$ELSE}
  NullMask[x div 8] := (NullMask[x div 8]) or (1 shl (x mod 8));
 {$ENDIF}
End;

Function TRESTDWMemTable.GetNewBlobBuffer : PBlobBuffer;
Var
 ABlobBuffer : PBlobBuffer;
Begin
 setlength(FBlobs, Length(FBlobs) +1);
 New(ABlobBuffer);
// Fillbyte(ABlobBuffer^,  Sizeof(ABlobBuffer^), 0);
 ABlobBuffer^.OrgBufID := High(FBlobs);
 ABlobBuffer^.Buffer   := @FBlobs[high(FBlobs)];
 Result := ABlobBuffer;
End;

Function TRESTDWMemTable.LoadBuffer(Buffer : TRecordBuffer): TGetResult;
Var
 vFieldSize      : Integer;
 NullMask        : pbyte;
 x               : longint;
 CreateBlobField : Boolean;
 BufBlob         : PRESTDWBlobField;
Begin
 If Not Fetch Then
  Begin
   Result := grEOF;
   FAllPacketsFetched := True;
    // This code has to be placed elsewhere. At least it should also run when
    // the datapacket is loaded from file ... see IntLoadRecordsFromFile
   BuildIndexes;
   Exit;
  End;
 NullMask := Pointer(buffer);
 Fillchar(Nullmask^, FNullmaskSize, 0);
 Inc     (buffer,    FNullmaskSize);
 For x := 0 To Fields.Count-1 Do
  Begin
   If Not LoadField(FieldDefs[x], buffer, CreateBlobField) Then
    SetFieldIsNull(NullMask, x)
   Else If CreateBlobField Then
    Begin
     BufBlob             := PRESTDWBlobField(Buffer);
     BufBlob^.BlobBuffer := GetNewBlobBuffer;
     LoadBlobIntoBuffer(FieldDefs[x],BufBlob);
    End;
   CalcDataSize(Fields[X], vFieldSize);
   Inc(buffer, vFieldSize);
  End;
 Result := grOK;
End;

Function TRESTDWMemTable.getnextpacket : Integer;
Var
 i  : Integer;
 pb : TRecordBuffer;
 T  : TRESTDWIndex;
Begin
 Result := 0;
 If FAllPacketsFetched Then
  Begin
   Result := 0;
   Exit;
  End;
 T := GetCurrentIndexBuf;
 If T <> Nil Then
  Begin
   T.BeginUpdate;
   I := 0;
   pb := DefaultBufferIndex.SpareBuffer;
   While ((i < FPacketRecords) or (FPacketRecords = -1)) and (LoadBuffer(pb) = grOk) do
    Begin
     With DefaultBufferIndex Do
      Begin
       AddRecord;
       pb := SpareBuffer;
      End;
     Inc(i);
    End;
   T.EndUpdate;
  // FBRecordCount := FBRecordCount + i; //Todo XyberX
   Result := i;
  End;
End;

procedure TRESTDWMemTable.FetchAll;
Begin
 Repeat
 Until (getnextpacket < FPacketRecords) or (FPacketRecords = -1);
End;

Function TUniDirectionalBufIndex.GetCurrentBuffer: Pointer;
Begin
 Result := FSPareBuffer;
End;

Function TUniDirectionalBufIndex.GetCurrentRecord:  TRecordBuffer;
Begin
 Result := Nil;
  //  Result:=inherited GetCurrentRecord;
End;

Function TUniDirectionalBufIndex.GetIsInitialized: boolean;
Begin
 Result := Assigned(FSPareBuffer);
End;

Function TUniDirectionalBufIndex.GetSpareBuffer:  TRecordBuffer;
Begin
 Result := FSPareBuffer;
End;

Function TUniDirectionalBufIndex.GetSpareRecord:  TRecordBuffer;
Begin
 Result := FSPareBuffer;
End;

Function TUniDirectionalBufIndex.ScrollBackward: TGetResult;
Begin
 Result := grError;
End;

Function TUniDirectionalBufIndex.ScrollForward: TGetResult;
Begin
 Result := grOk;
End;

Function TUniDirectionalBufIndex.GetCurrent: TGetResult;
Begin
 Result := grOk;
End;

Function TUniDirectionalBufIndex.ScrollFirst: TGetResult;
Begin
 Result := grError;
End;

Procedure TUniDirectionalBufIndex.ScrollLast;
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TUniDirectionalBufIndex.SetToFirstRecord;
Begin
 // for UniDirectional datasets should be [Internal]First valid method call
 // do nothing
End;

Procedure TUniDirectionalBufIndex.SetToLastRecord;
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TUniDirectionalBufIndex.StoreCurrentRecord;
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TUniDirectionalBufIndex.RestoreCurrentRecord;
Begin
 DatabaseError(SUniDirectional);
End;

Function TUniDirectionalBufIndex.CanScrollForward: Boolean;
Begin
 // should return true if next record is already fetched
 Result := false;
End;

Procedure TUniDirectionalBufIndex.DoScrollForward;
Begin
 // do nothing
End;

Procedure TUniDirectionalBufIndex.StoreCurrentRecIntoBookmark(const ABookmark: PRESTDWBookmark);
Begin
 // do nothing
End;

Procedure TUniDirectionalBufIndex.StoreSpareRecIntoBookmark(const ABookmark: PRESTDWBookmark);
Begin
 // do nothing
End;

Procedure TUniDirectionalBufIndex.GotoBookmark(const ABookmark: PRESTDWBookmark);
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TUniDirectionalBufIndex.InitialiseIndex;
Begin
 // do nothing
End;

Procedure TUniDirectionalBufIndex.InitialiseSpareRecord(const ASpareRecord:  TRecordBuffer);
Begin
 FSPareBuffer := ASpareRecord;
End;

Procedure TUniDirectionalBufIndex.ReleaseSpareRecord;
Begin
 FSPareBuffer := Nil;
End;

Function TUniDirectionalBufIndex.GetRecNo: Longint;
Begin
 Result := -1;
End;

Procedure TUniDirectionalBufIndex.SetRecNo(ARecNo: Longint);
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TUniDirectionalBufIndex.BeginUpdate;
Begin
 // Do nothing
End;

Function TUniDirectionalBufIndex.GetBookmarkSize : Integer;
Begin
 // In principle there are no bookmarks, and the size should be 0.
 // But there is quite some code in TCustomBufDataset that relies on
 // an existing bookmark of the TBufBookmark type.
 // This code could be moved to the TBufIndex but that would make things
 // more complicated and probably slower. So use a 'fake' bookmark of
 // size TBufBookmark.
 // When there are other TBufIndexes which also need special bookmark code
 // this can be adapted.
 Result := Sizeof(TRESTDWBookmark);
End;

Procedure TUniDirectionalBufIndex.AddRecord;
Var
 h, i : Integer;
Begin
 // Release unneeded blob buffers, in order to save memory
 // TDataSet has own buffer of records, so do not release blobs until they can be referenced
 With FDataSet Do
  Begin
   h := Length(FBlobs);
   If h > 0 Then //Free in batches, starting with oldest (at beginning)
    Begin
     For i := 0 To h Do
      SetLength(FBlobs[i], 0);
//     FBlobs[i] := Copy(FBlobBuffers, h+1, high(FBlobBuffers)-h); //Todo XyberX
    End;
  End;
End;

Procedure TUniDirectionalBufIndex.InsertRecordBeforeCurrentRecord(const ARecord:  TRecordBuffer);
Begin
 // Do nothing
End;

Procedure TUniDirectionalBufIndex.RemoveRecordFromIndex(const ABookmark: TRESTDWBookmark);
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TUniDirectionalBufIndex.OrderCurrentRecord;
Begin
 // Do nothing
End;

Procedure TUniDirectionalBufIndex.EndUpdate;
Begin
 // Do nothing
End;

Function TDoubleLinkedBufIndex.GetBookmarkSize : integer;
Begin
 Result := SizeOf(TRESTDWBookmark);
End;

Function TDoubleLinkedBufIndex.GetCurrentBuffer: Pointer;
Begin
// pointer(FLastRecBuf) + FDataset.BufferOffset;
 Result := Pointer(FDataset.ActiveBuffer); //Todo XyberX
End;

Function TDoubleLinkedBufIndex.GetCurrentRecord : TRecordBuffer;
Begin
 Result := TRecordBuffer(FCurrentRecBuf);
End;

Function TDoubleLinkedBufIndex.GetIsInitialized : Boolean;
Begin
 Result := (FFirstRecBuf<>nil);
End;

Function TDoubleLinkedBufIndex.GetSpareBuffer : TRecordBuffer;
Begin
// Pointer(FLastRecBuf) + FDataset.BufferOffset;
 Result := Pointer(FDataset.ActiveBuffer); //Todo XyberX
End;

Function TDoubleLinkedBufIndex.GetSpareRecord : TRecordBuffer;
Begin
 Result := TRecordBuffer(FLastRecBuf);
End;

Function TDoubleLinkedBufIndex.ScrollBackward: TGetResult;
Begin
 If Not assigned({$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FCurrentRecBuf[IndNr]
  {$ELSE}
   //TODO XyberX
   FCurrentRecBuf
  {$IFEND}
 {$ELSE}
  FCurrentRecBuf[IndNr]
 {$ENDIF}.prior) Then
  Begin
   Result := grBOF;
  End
 Else
  Begin
   Result := grOK;
   FCurrentRecBuf := {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FCurrentRecBuf[IndNr]
  {$ELSE}
   //TODO XyberX
   FCurrentRecBuf
  {$IFEND}
 {$ELSE}
  FCurrentRecBuf[IndNr]
 {$ENDIF}.prior;
  End;
End;

Function TDoubleLinkedBufIndex.ScrollForward : TGetResult;
Begin
 If (FCurrentRecBuf = FLastRecBuf)             Or // just opened
    ({$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FCurrentRecBuf[IndNr]
  {$ELSE}
   //TODO XyberX
   FCurrentRecBuf
  {$IFEND}
 {$ELSE}
  FCurrentRecBuf[IndNr]
 {$ENDIF}.next = FLastRecBuf) Then
  Result := grEOF
 Else
  Begin
   FCurrentRecBuf := {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FCurrentRecBuf[IndNr]
  {$ELSE}
   //TODO XyberX
   FCurrentRecBuf
  {$IFEND}
 {$ELSE}
  FCurrentRecBuf[IndNr]
 {$ENDIF}.next;
   Result := grOK;
  End;
End;

Function TDoubleLinkedBufIndex.GetCurrent : TGetResult;
Begin
 If FFirstRecBuf = FLastRecBuf Then
  Result := grError
 Else
  Begin
   Result := grOK;
   If FCurrentRecBuf = FLastRecBuf Then
    FCurrentRecBuf  := {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FCurrentRecBuf[IndNr]
  {$ELSE}
   //TODO XyberX
   FCurrentRecBuf
  {$IFEND}
 {$ELSE}
  FCurrentRecBuf[IndNr]
 {$ENDIF}.prior;
  End;
End;

Function TDoubleLinkedBufIndex.ScrollFirst : TGetResult;
Begin
 FCurrentRecBuf:=FFirstRecBuf;
 If (FCurrentRecBuf = FLastRecBuf) Then
  Result := grEOF
 Else
  Result := grOK;
End;

Procedure TDoubleLinkedBufIndex.ScrollLast;
Begin
 FCurrentRecBuf := FLastRecBuf;
End;

Function TDoubleLinkedBufIndex.GetRecord(ABookmark : PRESTDWBookmark;
                                         GetMode   : TGetMode) : TGetResult;
Var
 ARecord : PRESTDWRecLinkItem;
Begin
 Result := grOK;
 Case GetMode Of
   gmPrior : Begin
              If assigned(ABookmark^.BookmarkData) Then
               ARecord := {$IFNDEF FPC}
                           {$IF CompilerVersion >= 20}
                            ABookmark^.BookmarkData[IndNr]
                           {$ELSE}
                            //TODO XyberX
                            ABookmark^.BookmarkData
                           {$IFEND}
                          {$ELSE}
                           ABookmark^.BookmarkData[IndNr]
                          {$ENDIF}.prior
              Else
               ARecord := Nil;
              If not assigned(ARecord) Then
               Result := grBOF;
             End;
    gmNext : Begin
              If assigned(ABookmark^.BookmarkData) Then
               ARecord := {$IFNDEF FPC}
                           {$IF CompilerVersion >= 20}
                            ABookmark^.BookmarkData[IndNr]
                           {$ELSE}
                            //TODO XyberX
                            ABookmark^.BookmarkData
                           {$IFEND}
                          {$ELSE}
                           ABookmark^.BookmarkData[IndNr]
                          {$ENDIF}.next
              Else
               ARecord := FFirstRecBuf;
             End;
    Else Result := grError;
 End;
 If ARecord = FLastRecBuf then
  Result := grEOF;
 // store into BookmarkData pointer to prior/next record
 ABookmark^.BookmarkData:=ARecord;
End;

Procedure TDoubleLinkedBufIndex.SetToFirstRecord;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FLastRecBuf[IndNr]
  {$ELSE}
   //TODO XyberX
   FLastRecBuf
  {$IFEND}
 {$ELSE}
  FLastRecBuf[IndNr]
 {$ENDIF}.next:=FFirstRecBuf;
 FCurrentRecBuf := FLastRecBuf;
End;

Procedure TDoubleLinkedBufIndex.SetToLastRecord;
Begin
 If FLastRecBuf <> FFirstRecBuf Then
  FCurrentRecBuf := FLastRecBuf;
End;

Procedure TDoubleLinkedBufIndex.StoreCurrentRecord;
Begin
 FStoredRecBuf:=FCurrentRecBuf;
End;

Procedure TDoubleLinkedBufIndex.RestoreCurrentRecord;
Begin
 FCurrentRecBuf:=FStoredRecBuf;
End;

Procedure TDoubleLinkedBufIndex.DoScrollForward;
Begin
 FCurrentRecBuf :=  {$IFNDEF FPC}
                     {$IF CompilerVersion >= 20}
                      FCurrentRecBuf[IndNr]
                     {$ELSE}
                      //TODO XyberX
                      FCurrentRecBuf
                     {$IFEND}
                    {$ELSE}
                     FCurrentRecBuf[IndNr]
                    {$ENDIF}.next;
End;

Procedure TDoubleLinkedBufIndex.StoreCurrentRecIntoBookmark(const ABookmark: PRESTDWBookmark);
Begin
 ABookmark^.BookmarkData := FCurrentRecBuf;
End;

Procedure TDoubleLinkedBufIndex.StoreSpareRecIntoBookmark(Const ABookmark : PRESTDWBookmark);
Begin
 ABookmark^.BookmarkData := FLastRecBuf;
End;

Procedure TDoubleLinkedBufIndex.GotoBookmark(const ABookmark : PRESTDWBookmark);
Begin
 FCurrentRecBuf := ABookmark^.BookmarkData;
End;

Function TDoubleLinkedBufIndex.CompareBookmarks(const ABookmark1,ABookmark2: PRESTDWBookmark) : Integer;
Var
 ARecord1,
 ARecord2 : PRESTDWRecLinkItem;
Begin
 // valid bookmarks expected
 // estimate result using memory addresses of records
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   Result := ABookmark1^.BookmarkData - ABookmark2^.BookmarkData;
  {$ELSE}
   //TODO XyberX
   Result := 0;
  {$IFEND}
 {$ELSE}
  Result := ABookmark1^.BookmarkData - ABookmark2^.BookmarkData;
 {$ENDIF}
 If Result = 0 Then
  Exit
 Else If Result < 0 Then
  Begin
   Result   := -1;
   ARecord1 := ABookmark1^.BookmarkData;
   ARecord2 := ABookmark2^.BookmarkData;
  End
 Else
  Begin
   Result   := +1;
   ARecord1 := ABookmark2^.BookmarkData;
   ARecord2 := ABookmark1^.BookmarkData;
  End;
 // if we need relative position of records with given bookmarks we must
 // traverse through index until we reach lower bookmark or 1st record
 While Assigned(ARecord2)         And
       (ARecord2 <> ARecord1)     And
       (ARecord2 <> FFirstRecBuf) Do
  ARecord2 :=  {$IFNDEF FPC}
                {$IF CompilerVersion >= 20}
                 ARecord2[IndNr]
                {$ELSE}
                 //TODO XyberX
                 ARecord2
                {$IFEND}
               {$ELSE}
                ARecord2[IndNr]
               {$ENDIF}.prior;
 // if we found lower bookmark as first, then estimated position is correct
 If ARecord1 <> ARecord2 Then
  Result := -Result;
End;

Function TDoubleLinkedBufIndex.SameBookmarks(const ABookmark1, ABookmark2: PRESTDWBookmark) : Boolean;
Begin
 Result := Assigned(ABookmark1) And
           Assigned(ABookmark2) And
           (ABookmark1^.BookmarkData = ABookmark2^.BookmarkData);
End;

Procedure TDoubleLinkedBufIndex.InitialiseIndex;
Begin
 // Do nothing
End;

Function TDoubleLinkedBufIndex.CanScrollForward: Boolean;
Begin
 If ({$IFNDEF FPC}
      {$IF CompilerVersion >= 20}
       FCurrentRecBuf[IndNr]
      {$ELSE}
       //TODO XyberX
       FCurrentRecBuf
      {$IFEND}
     {$ELSE}
      FCurrentRecBuf[IndNr]
     {$ENDIF}.next = FLastRecBuf) then
  Result := False
 Else
  Result := True;
End;

Procedure TDoubleLinkedBufIndex.InitialiseSpareRecord(const ASpareRecord : TRecordBuffer);
Begin
 FFirstRecBuf             := Pointer(ASpareRecord);
 FLastRecBuf              := FFirstRecBuf;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FLastRecBuf[IndNr].prior := Nil;
   FLastRecBuf[IndNr].next  := FLastRecBuf;
  {$ELSE}
   //TODO XyberX
   FLastRecBuf.prior := Nil;
   FLastRecBuf.next  := FLastRecBuf;
  {$IFEND}
 {$ELSE}
  FLastRecBuf[IndNr].prior := Nil;
  FLastRecBuf[IndNr].next  := FLastRecBuf;
 {$ENDIF}
 FCurrentRecBuf           := FLastRecBuf;
End;

Procedure TDoubleLinkedBufIndex.ReleaseSpareRecord;
Begin
 FFirstRecBuf := Nil;
End;

Function TDoubleLinkedBufIndex.GetRecNo : Longint;
Var
 ARecord : PRESTDWRecLinkItem;
Begin
 ARecord := FCurrentRecBuf;
 Result := 1;
 While ARecord <> FFirstRecBuf do
  Begin
   Inc(Result);
   {$IFNDEF FPC}
    {$IF CompilerVersion >= 20}
     ARecord := ARecord[IndNr].prior;
    {$ELSE}
     //TODO XyberX
     ARecord := ARecord.prior;
    {$IFEND}
   {$ELSE}
    ARecord := ARecord[IndNr].prior;
   {$ENDIF}
  End;
End;

Procedure TDoubleLinkedBufIndex.SetRecNo(ARecNo: Longint);
Var
 ARecord : PRESTDWRecLinkItem;
Begin
 ARecord := FFirstRecBuf;
 While (ARecNo   > 1)           And
       (ARecord <> FLastRecBuf) Do
  Begin
   dec(ARecNo);
   {$IFNDEF FPC}
    {$IF CompilerVersion >= 20}
     ARecord := ARecord[IndNr].next;
    {$ELSE}
     //TODO XyberX
     ARecord := ARecord.next;
    {$IFEND}
   {$ELSE}
    ARecord := ARecord[IndNr].next;
   {$ENDIF}
  End;
 FCurrentRecBuf := ARecord;
End;

Procedure TDoubleLinkedBufIndex.BeginUpdate;
Begin
 If FCurrentRecBuf = FLastRecBuf Then
  FCursOnFirstRec := True
 Else
  FCursOnFirstRec := False;
End;

Procedure TDoubleLinkedBufIndex.AddRecord;
Var
 ARecord : TRecordBuffer;
Begin
 ARecord                              := FDataset.IntAllocRecordBuffer;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FLastRecBuf[IndNr].next              := Pointer(ARecord);
   FLastRecBuf[IndNr].next[IndNr].prior := FLastRecBuf;
   FLastRecBuf                          := FLastRecBuf[IndNr].next;
  {$ELSE}
    //TODO XyberX
   FLastRecBuf.next       := Pointer(ARecord);
   FLastRecBuf.next.prior := FLastRecBuf;
   FLastRecBuf            := FLastRecBuf.next;
  {$IFEND}
 {$ELSE}
  FLastRecBuf[IndNr].next              := Pointer(ARecord);
  FLastRecBuf[IndNr].next[IndNr].prior := FLastRecBuf;
  FLastRecBuf                          := FLastRecBuf[IndNr].next;
 {$ENDIF}
End;

Procedure TDoubleLinkedBufIndex.InsertRecordBeforeCurrentRecord(Const ARecord : TRecordBuffer);
Var
 ANewRecord : PRESTDWRecLinkItem;
Begin
 ANewRecord              := PRESTDWRecLinkItem(ARecord);
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   ANewRecord[IndNr].prior := FCurrentRecBuf[IndNr].prior;
   ANewRecord[IndNr].Next  := FCurrentRecBuf;
   If FCurrentRecBuf=FFirstRecBuf Then
    Begin
     FFirstRecBuf:=ANewRecord;
     ANewRecord[IndNr].prior:=nil;
    End
   Else
    ANewRecord[IndNr].Prior[IndNr].next:=ANewRecord;
   ANewRecord[IndNr].next[IndNr].prior:=ANewRecord;
  {$ELSE}
    //TODO XyberX
   ANewRecord.prior := FCurrentRecBuf.prior;
   ANewRecord.Next  := FCurrentRecBuf;
   If FCurrentRecBuf=FFirstRecBuf Then
    Begin
     FFirstRecBuf:=ANewRecord;
     ANewRecord.prior:=nil;
    End
   Else
    ANewRecord.Prior.next:=ANewRecord;
   ANewRecord.next.prior:=ANewRecord;
  {$IFEND}
 {$ELSE}
  ANewRecord[IndNr].prior := FCurrentRecBuf[IndNr].prior;
  ANewRecord[IndNr].Next  := FCurrentRecBuf;
  If FCurrentRecBuf=FFirstRecBuf Then
   Begin
    FFirstRecBuf:=ANewRecord;
    ANewRecord[IndNr].prior:=nil;
   End
  Else
   ANewRecord[IndNr].Prior[IndNr].next:=ANewRecord;
  ANewRecord[IndNr].next[IndNr].prior:=ANewRecord;
 {$ENDIF}
End;

procedure TDoubleLinkedBufIndex.RemoveRecordFromIndex(const ABookmark : TRESTDWBookmark);
Var
 ARecord : PRESTDWRecLinkItem;
Begin
 ARecord := ABookmark.BookmarkData;
 If ARecord  = FCurrentRecBuf Then DoScrollForward;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   If ARecord <> FFirstRecBuf   Then
    ARecord[IndNr].prior[IndNr].next := ARecord[IndNr].next
   Else
    Begin
     FFirstRecBuf := ARecord[IndNr].next;
     FLastRecBuf[IndNr].next := FFirstRecBuf;
    End;
   ARecord[IndNr].next[IndNr].prior := ARecord[IndNr].prior;
  {$ELSE}
    //TODO XyberX
   If ARecord <> FFirstRecBuf   Then
    ARecord.prior.next := ARecord.next
   Else
    Begin
     FFirstRecBuf := ARecord.next;
     FLastRecBuf.next := FFirstRecBuf;
    End;
   ARecord.next.prior := ARecord.prior;
  {$IFEND}
 {$ELSE}
  If ARecord <> FFirstRecBuf   Then
   ARecord[IndNr].prior[IndNr].next := ARecord[IndNr].next
  Else
   Begin
    FFirstRecBuf := ARecord[IndNr].next;
    FLastRecBuf[IndNr].next := FFirstRecBuf;
   End;
  ARecord[IndNr].next[IndNr].prior := ARecord[IndNr].prior;
 {$ENDIF}
End;

Procedure TDoubleLinkedBufIndex.OrderCurrentRecord;
Var
 ARecord   : PRESTDWRecLinkItem;
 ABookmark : TRESTDWBookmark;
Begin
 // all records except current are already sorted
 // check prior records
 ARecord := FCurrentRecBuf;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   Repeat
    ARecord := ARecord[IndNr].prior;
   Until Not Assigned(ARecord) Or
             (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) <= 0);
   If assigned(ARecord) Then
    ARecord := ARecord[IndNr].next
   Else
    ARecord := FFirstRecBuf;
   If ARecord = FCurrentRecBuf Then
    Begin
     // prior record is less equal than current
     // check next records
     Repeat
      ARecord := ARecord[IndNr].next;
     Until (ARecord=FLastRecBuf) Or
           (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) >= 0);
     If ARecord = FCurrentRecBuf[IndNr].next Then
     Exit; // current record is on proper position
    End;
  {$ELSE}
    //TODO XyberX
   Repeat
    ARecord := ARecord.prior;
   Until Not Assigned(ARecord) Or
             (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) <= 0);
   If assigned(ARecord) Then
    ARecord := ARecord.next
   Else
    ARecord := FFirstRecBuf;
   If ARecord = FCurrentRecBuf Then
    Begin
     // prior record is less equal than current
     // check next records
     Repeat
      ARecord := ARecord.next;
     Until (ARecord=FLastRecBuf) Or
           (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) >= 0);
     If ARecord = FCurrentRecBuf.next Then
     Exit; // current record is on proper position
    End;
  {$IFEND}
 {$ELSE}
  Repeat
   ARecord := ARecord[IndNr].prior;
  Until Not Assigned(ARecord) Or
            (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) <= 0);
  If assigned(ARecord) Then
   ARecord := ARecord[IndNr].next
  Else
   ARecord := FFirstRecBuf;
  If ARecord = FCurrentRecBuf Then
   Begin
    // prior record is less equal than current
    // check next records
    Repeat
     ARecord := ARecord[IndNr].next;
    Until (ARecord=FLastRecBuf) Or
          (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) >= 0);
    If ARecord = FCurrentRecBuf[IndNr].next Then
    Exit; // current record is on proper position
   End;
 {$ENDIF}
 StoreCurrentRecIntoBookmark(@ABookmark);
 RemoveRecordFromIndex(ABookmark);
 FCurrentRecBuf := ARecord;
 InsertRecordBeforeCurrentRecord(TRecordBuffer(ABookmark.BookmarkData));
 GotoBookmark(@ABookmark);
End;

Procedure TDoubleLinkedBufIndex.EndUpdate;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 20}
   FLastRecBuf[IndNr].next := FFirstRecBuf;
  {$ELSE}
    //TODO XyberX
   FLastRecBuf.next := FFirstRecBuf;
  {$IFEND}
 {$ELSE}
  FLastRecBuf[IndNr].next := FFirstRecBuf;
 {$ENDIF}
 If FCursOnFirstRec Then
  FCurrentRecBuf := FLastRecBuf;
End;

Procedure TRESTDWDatasetIndex.Clearindex;
Begin
 FreeAndNil(FBufferIndex);
End;

Destructor TRESTDWDatasetIndex.Destroy;
Begin
 ClearIndex;
 Inherited Destroy;
End;

Procedure TRESTDWDatasetIndex.SetIndexProperties;
Begin
 If Not Assigned(FBufferIndex) Then
  Exit;
 FBufferIndex.IndNr         := Index;
 FBufferIndex.Name          := Name;
 FBufferIndex.FieldsName    := Fields;
 FBufferIndex.DescFields    := DescFields;
 FBufferIndex.CaseinsFields := CaseInsFields;
 FBufferIndex.Options       := Options;
End;

Function TRESTDWDatasetIndex.MustBuild(aCurrent : TRESTDWDatasetIndex) : Boolean;
Begin
 Result := (FIndexType<>itDefault) And IsActiveIndex(aCurrent);
End;

Function TRESTDWDatasetIndex.IsActiveIndex(aCurrent: TRESTDWDatasetIndex) : Boolean;
Begin
 Result := (FIndexType<>itCustom)  Or (Self=aCurrent);
End;

Function TRESTDWDatasetIndexDefs.GetBufDatasetIndex(AIndex : Integer): TRESTDWDatasetIndex;
Begin
 Result := TRESTDWDatasetIndex(Items[Aindex]);
End;

Function TRESTDWDatasetIndexDefs.GetBufferIndex(AIndex : Integer) : TRESTDWIndex;
Begin
 Result := RESTDWIndexdefs[AIndex].BufferIndex;
End;

Constructor TRESTDWDatasetIndexDefs.Create(aDataset : TDataset);
Begin
 Inherited Create(aDataset);
End;

Function TRESTDWDatasetIndexDefs.FindIndex(const IndexName: string): TRESTDWDatasetIndex;
Var
 I : Integer;
Begin
 I := IndexOf(IndexName);
 If I <> -1 Then
  Result := RESTDWIndexdefs[I]
 Else
  Result := Nil;
End;

Function TRESTDWMemTable.IntAllocRecordBuffer: TRecordBuffer;
Var
 I, DataSize : Integer;
Begin
 // Note: Only the internal buffers of TDataset provide bookmark information
 DataSize := 0;
 For I := 0 to Fields.Count - 1 do
  CalcDataSize(Fields[I], DataSize);
 ReallocMem(Result, DataSize);
End;

procedure TRESTDWMemTable.InternalCreateIndex(F : TRESTDWDataSetIndex);
Var
 B : TRESTDWIndex;
Begin
 If Active and Not Refreshing then
  FetchAll;
  if IsUniDirectional then
    B:=TUniDirectionalBufIndex.Create(self)
  else
    B:=TDoubleLinkedBufIndex.Create(self);
  F.FBufferIndex:=B;
  with B do
    begin
    InitialiseIndex;
    F.SetIndexProperties;
    end;
  if Active  then
    begin
    if not Refreshing then
      B.InitialiseSpareRecord(IntAllocRecordBuffer);
    if (F.Fields<>'') then
      BuildIndex(B);
    end
  else
    if (FIndexes.Count+2>FMaxIndexesCount) then
      FMaxIndexesCount:=FIndexes.Count+2; // Custom+Default order
end;

Function TRESTDWMemTable.InternalAddIndex(Const AName,
                                          AFields              : String;
                                          AOptions             : TIndexOptions;
                                          Const ADescFields    : String;
                                          Const ACaseInsFields : String) : TRESTDWDatasetIndex;
Var
 F : TRESTDWDatasetIndex;
Begin
 F := TRESTDWDatasetIndex(FIndexes.AddIndexDef);
 F.Name:=AName;
 F.Fields:=AFields;
 F.Options:=AOptions;
 F.DescFields:=ADescFields;
 F.CaseInsFields:=ACaseInsFields;
// BuildIndexes;
// InitDefaultIndexes;
 Result := F;
 InternalCreateIndex(F);
End;

Procedure TRESTDWMemTable.InitDefaultIndexes;
{
  This procedure makes sure there are 2 default indexes:
  DEFAULT_ORDER, which is simply the order in which the server records arrived.
  CUSTOM_ORDER, which is an internal index to accomodate the 'IndexFieldNames' property.
}
Var
 FD,
 FC : TRESTDWDatasetIndex;
Begin
  // Default index
 FD := FIndexes.FindIndex(SDefaultIndex);
 If (FD = Nil) Then
  Begin
   FD := InternalAddIndex(SDefaultIndex,'',[],'','');
   FD.IndexType:=itDefault;
   FD.FDiscardOnClose:=True;
  End;
// Not sure about this. For the moment we leave it in comment
{  else if FD.BufferIndex=Nil then
    InternalCreateIndex(FD)}
 FCurrentIndexDef:=FD;
 // Custom index
 If not IsUniDirectional Then
  Begin
   FC := Findexes.FindIndex(SCustomIndex);
   If (FC = Nil) Then
    Begin
     FC := InternalAddIndex(SCustomIndex,'',[],'','');
     FC.IndexType:=itCustom;
     FC.FDiscardOnClose:=True;
    End;
    // Not sure about this. For the moment we leave it in comment
{    else if FD.BufferIndex=Nil then
      InternalCreateIndex(FD)}
  End;
 BookmarkSize := GetCurrentIndexBuf.BookmarkSize;
End;

Procedure TRESTDWMemTable.SetMaxIndexesCount(Const AValue : Integer);
Begin
 CheckInactive;
 If AValue > 1 Then
  FMaxIndexesCount := AValue
 Else
  DatabaseError(SMinIndexes, Self);
End;

Function TRESTDWMemTable.GetBufIndex   (Aindex : Integer) : TRESTDWIndex;
Begin
 Result := FIndexes.RESTDWIndexes[AIndex]
End;

Function TRESTDWMemTable.GetBufIndexDef(Aindex : Integer) : TRESTDWDatasetIndex;
Begin
 Result := FIndexes.RESTDWIndexdefs[AIndex];
End;

Procedure TRESTDWMemTable.BuildCustomIndex;
Var
 i,
 p          : Integer;
 s,
 SortFields,
 DescFields : String;
 F          : TRESTDWDatasetIndex;
Begin
 F :=FIndexes.FindIndex(SCustomIndex);
 If (F = Nil) Then
  InitDefaultIndexes;
  F:=FIndexes.FindIndex(SCustomIndex);
  SortFields := '';
  DescFields := '';
  for i := 1 to WordCount(FIndexFieldNames, [Limiter]) do
    begin
      s := ExtractDelimited(i, FIndexFieldNames, [Limiter]);
      p := Pos(Desc, s);
      if p>0 then
      begin
        system.Delete(s, p, LenDesc);
        DescFields := DescFields + Limiter + s;
      end;
      SortFields := SortFields + Limiter + s;
    end;
  if (Length(SortFields)>0) and (SortFields[1]=Limiter) then
    system.Delete(SortFields,1,1);
  if (Length(DescFields)>0) and (DescFields[1]=Limiter) then
    system.Delete(DescFields,1,1);
  F.Fields:=SortFields;
  F.Options:=[ixCaseInsensitive];
  F.DescFields:=DescFields;
  FCurrentIndexDef:=F;
  F.SetIndexProperties;
  If Active Then
   Begin
    FetchAll;
    BuildIndex(F.BufferIndex);
    Resync([rmCenter]);
   End;
  FPacketRecords := -1;
end;

Procedure TRESTDWMemTable.SetIndexFieldNames(const AValue: String);
Begin
 FIndexFieldNames := AValue;
 If (AValue='') then
  Begin
   FCurrentIndexDef:=FIndexes.FindIndex(SDefaultIndex);
   Exit;
  End;
 If Active then
  BuildCustomIndex;
End;

Function TRESTDWMemTable.GetIndexName: String;
Begin
 If (FIndexes.Count      > 0)   And
    (GetCurrentIndexBuf <> Nil) Then
  Result := GetCurrentIndexBuf.Name
 Else
  Result := FIndexName;
end;

Procedure TRESTDWMemTable.SetIndexName(AValue: String);
Var
 F : TRESTDWDatasetIndex;
 B : TDoubleLinkedBufIndex;
 N : String;
begin
  N:=AValue;
  If (N='') then
    N:=SDefaultIndex;
  F:=FIndexes.FindIndex(N);
  if (F=Nil) and (AValue<>'') and not (csLoading in ComponentState) then
    DatabaseErrorFmt(SIndexNotFound,[AValue],Self);
  FIndexName:=AValue;
  if Assigned(F) then
    begin
    B:=F.BufferIndex as TDoubleLinkedBufIndex;
    if GetCurrentIndexBuf <> Nil then
      B.FCurrentRecBuf:=(GetCurrentIndexBuf as TDoubleLinkedBufIndex).FCurrentRecBuf;
    FCurrentIndexDef:=F;
    if Active then
      Resync([rmCenter]);
    end
  else
    FCurrentIndexDef:=Nil;
end;

Function  TRESTDWMemTable.GetCurrentIndexBuf : TRESTDWIndex;
Begin
 If Assigned(FCurrentIndexDef) Then
  Result := FCurrentIndexDef.BufferIndex
 Else
  Result := Nil;
End;

Function TRESTDWMemTable.GetIndexDefs : TIndexDefs;
Begin
 Result := FIndexes;
End;

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
   If Assigned(FBlobs[I]) Then
    Rec.FBlobs[I] := FBlobs[I];
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
    If FieldCount > 0 then
      FieldDefs.Clear;
    InitFieldDefsFromFields;
  End;
  FActive := True;
  inherited OpenCursor(InfoQuery);
End;

Procedure TRESTDWMemTable.InternalOpen;
 {$IFDEF FPC}
  Procedure CalcOffSets;
  Var
   I, FieldLen,
   Offset : Integer;
  Begin
   Offset := 0;
   If Fields.Count > 0 Then
    Begin
     SetLength(FOffsets, 0);
     SetLength(FOffsets, Fields.Count);
     Try
      For I := 0 to Fields.Count - 1 do
       Begin
        FOffsets[I] := Offset;
        If Fields[I].datatype in ftSupported - ftBlobTypes then
         Begin
          FieldLen := CalcFieldLen(Fields[I].datatype, Fields[I].Size);
          If Offset + FieldLen<= high(Offset) then
           Inc(Offset, FieldLen)
          Else
           Raise ERangeError.CreateResFmt(@RsEFieldOffsetOverflow, [I]);
         End;
       End;
     Finally
     End;
    End;
  End;
 {$ENDIF}
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
 {$IFDEF FPC}
  CalcOffSets;
 {$ENDIF}
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
 Else If Not IsEmpty then
  SortOnFields();
 Inherited DoAfterOpen;
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
Begin
  ClearBuffer;
  FAutoInc := 1;
  BindFields(False);
  If DefaultFields then
   DestroyFields;
  FreeFieldBuffers;
  FActive := False;
  FBlobOfs := 0;
  FDataSetClosed := True;
  DataEvent(deUpdateRecord, 0);
  FDataSet := Nil;
  FDataSet.Free;
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
  If (filtered) And
     (TRESTDWMemTableEx(Self).GetFilteredRecordCount > 0) Then
   Begin
    If (FRecordFilterPos = -1) Then
     Result := 1
    Else
     Result := FRecordFilterPos;
   End
  Else If (FRecordPos = -1) and (RecordCount > 0) then
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

Function TRESTDWMemTable.Locate(const KeyFields : String;
                                const KeyValues : Variant;
                                Options         : TLocateOptions) : Boolean;
Begin
 DoBeforeScroll;
 Result := DataSetLocateThrough(Self, KeyFields, KeyValues, Options);
 If Result then
  Begin
   DataEvent(deDataSetChange, 0);
   DoAfterScroll;
  End;
End;

Function TRESTDWMemTable.Lookup(const KeyFields    : String;
                                const KeyValues    : Variant;
                                const ResultFields : String) : Variant;
Var
 aFieldCount  : Integer;
 {$IFNDEF FPC}
  aFields: TList{$IFDEF RTL240_UP}<TField>{$ENDIF RTL240_UP};
 {$ELSE}
  aFields: TFields;
 {$ENDIF}
 Fld           : TField;
 SaveState     : TDataSetState;
 I             : Integer;
 Matched       : Boolean;
 aPointer      : Pointer;
 aKeyFieldName : String;
 Function CompareField(Field : TField;
                       Value : Variant): Boolean;
 Var
  S : string;
 Begin
  If Field.datatype in [ftString{$IFDEF UNICODE}, ftWideString, ftFixedWideChar{$ENDIF}] Then
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
 Function CompareRecord(KeyFieldnames : String) : Boolean;
 Var
  I, A       : Integer;
  aTemFields,
  aFieldName : String;
 Begin
  aTemFields := KeyFieldnames;
  While aTemFields <> '' Do
   Begin
    If Pos(';', aTemFields) > 0 Then
     Begin
      aFieldName := Trim(Copy(aTemFields, 1, Pos(';', aTemFields)-1));
      DeleteStr(aTemFields, 1, Pos(';', aTemFields));
     End
    Else
     Begin
      aFieldName := Trim(Copy(aTemFields, 1, Length(aTemFields)));
      aTemFields := '';
     End;
    If aFieldCount = 1 then
     Begin
      Fld := TField(Fields.FindField(aFieldName));
      Result := CompareField(Fld, KeyValues);
     End
    Else
     Begin
      Result := True;
      For A := 0 to Length(KeyValues) -1 do
       Begin
        Fld := TField(Fields.FindField(aFieldName));
        Result := Result and CompareField(Fld, KeyValues[A]);
       End;
     End;
   End;
 End;
Begin
 CheckBrowseMode;
 aPointer := @Result;
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
   For I := 0 To aFieldCount -1 Do
    Begin
     If I = 0 Then
      Begin
       aKeyFieldName := {$IFNDEF FPC}
                         {$IF CompilerVersion > 21}
                          aFields[I].FieldName;
                         {$ELSE}
                          TField(aFields.Items[I]).FieldName;
                         {$IFEND}
                        {$ELSE}
                         aFields[I].FieldName;
                        {$ENDIF}
      End
     Else
      aKeyFieldName := aKeyFieldName + ';' + {$IFNDEF FPC}
                                              {$IF CompilerVersion > 21}
                                               aFields[I].FieldName;
                                              {$ELSE}
                                               TField(aFields.Items[I]).FieldName;
                                              {$IFEND}
                                             {$ELSE}
                                              aFields[I].FieldName;
                                             {$ENDIF};
    End;
   Matched := CompareRecord(aKeyFieldName);
   If Matched Then
    Variant(aPointer^) := FieldValues[ResultFields]
   Else
    Begin
     SaveState := SetTempState(dsCalcFields);
     Try
      Try
       For I := 0 To RecordCount - 1 Do
        Begin
         RecordToBuffer(Records[I], PRESTDWMTMemBuffer(TempBuffer));
         CalculateFields(TempBuffer);
         Matched := CompareRecord(aKeyFieldName);
         If Matched Then
          Break;
        End;
      Finally
       If Matched Then
        Variant(aPointer^) := FieldValues[ResultFields];
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
    //If Source.Active and FDataSetClosed then
    //  Source.Close;
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
      //stream.Seek( 0, TSeekOrigin.soBeginning );
      //stream.Position := 0;
      stor.LoadFromStream(Self, stream);
    Finally
      stor.Free;
      //stream := Nil;
      //stream.Free;
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
 If FStorageDataType = Nil then
  Begin
    stor := TRESTDWStorageBin.Create(nil);
    Try
      stor.SaveToStream(Self, stream);
    Finally
      stor.Free;
    End;
  End
 Else
  FStorageDataType.SaveToStream(Self, stream);
End;

Procedure TRESTDWMemTable.SortOnFields(const FieldNames: string = '';
                                       CaseInsensitive : Boolean = True;
                                       Descending      : Boolean = False);
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
    P := TRESTDWMTMemoryRecord(FRecords[(L + R) shr 1]);
//    PRESTDWMTMemBuffer(@Records[(L + R) shr 1]);
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
  CData1, CData2,
  Buffer1, Buffer2: array [0 .. dsMaxStringSize] of Byte;
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
//              Inc(Data1);
//              Inc(Data2);
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

Function TRESTDWIndex.BookmarkValid(const ABookmark : PRESTDWBookmark) : Boolean;
Begin
 Result := assigned(ABookmark) and assigned(ABookmark^.BookmarkData);
End;

Function TRESTDWIndex.CompareBookmarks(const ABookmark1,
                                       ABookmark2   : PRESTDWBookmark) : Integer;
Begin
 Result := 0;
End;

Function TRESTDWIndex.SameBookmarks(const ABookmark1,
                                    ABookmark2      : PRESTDWBookmark) : Boolean;
Begin
 Result := Assigned(ABookmark1) and Assigned(ABookmark2) and (CompareBookmarks(ABookmark1, ABookmark2) = 0);
End;

Function TRESTDWIndex.GetRecord(ABookmark : PRESTDWBookmark;
                                GetMode   : TGetMode) : TGetResult;
Begin
 Result := grError;
End;

constructor TRESTDWIndex.Create(const ADataset: TRESTDWMemtable);
Begin
 Inherited Create;
 FDataset := ADataset;
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
Var
 vPointer : Pointer;
Begin
  // (rom) added inherited Create;
  inherited Create;
  FActualBlob := Nil;
  FMode := Mode;
  FField := Field;
  FDataSet := FField.Dataset as TRESTDWMemTable;
  If Not FDataSet.GetActiveRecBuf(FBuffer) then
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
  vPointer := FDataSet.GetBlob(FField.Dataset.RecNo, FField.Offset);
  FActualBlob := vPointer;
  If (FCached) And (FDataSet.State = dsBrowse) Then
   TRESTDWBytes(vPointer^) := GetBlobFromRecord(FField);
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
  FDataSet := Nil;  
  //FDataSet.Free;
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
        Result := TMemBlobData(Rec.FBlobs[FField.Offset]);
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
       FBlobs := Pointer(@Rec.FBlobs[FField.Offset]);
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
     FActualBlob := FDataSet.GetBlob(FDataSet.RecNo, FField.Offset);
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
 Temp : TMemBlobData;
Begin
  Result := 0;
  If FOpened and FCached and (FMode <> bmRead) then
   Begin
    Temp := FDataSet.GetBlobData(FField, FBuffer);
    If Length(Temp) < FPosition + Count then
     SetLength(Temp, FPosition + Count);
    Move(Buffer, PRESTDWMTMemBuffer(Temp)[FPosition], Count);
	  //SetBlobFromRecord(FField, Temp);
    FDataSet.SetBlobData(FField, FBuffer, Temp);
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
	  SetLength(Temp, 0);
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
      Result := Length(TRESTDWBytes(FActualBlob^));
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
Var
  vItem : PRESTDWMTMemoryRecord;
Begin
 If (Index > -1) Then
  Begin
    Try
     If Assigned(TList(Self).Items[Index]) Then
      Begin
       If Assigned(TRESTDWMTMemoryRecord(TList(Self).Items[Index]^)) Then
        Begin
         {$IFDEF FPC}
          vItem := TList(Self).Items[Index];
          vItem^.Free;
         {$ELSE}
          {$IF CompilerVersion > 33}
           FreeAndNil(TRESTDWMTMemoryRecord(TList(Self).Items[Index]^));
          {$ELSE}
           FreeAndNil(TList(Self).Items[Index]^);
          {$IFEND}
         {$ENDIF}
        End;
      End;
      Dispose(PRESTDWMTMemoryRecord(TList(Self).Items[Index]));
    Except
    End;
    Inherited Delete(Index);
  End;
End;

Procedure TRecordList.ClearAll;
Var
  I: Integer;
Begin
  Try
   For I := Count - 1 Downto 0 Do
    Delete(I);
  Finally
   Self.Clear;
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
    vFileStream := Nil;
    vFileStream.Free;
  End;
End;

Procedure TRESTDWStorageBase.LoadFromStream(Dataset: TDataset; stream: TStream);
Begin
 If Dataset.InheritsFrom(TRESTDWMemTable) then
  LoadDWMemFromStream(TRESTDWMemTable(Dataset), stream)
 Else
  LoadDatasetFromStream(Dataset, stream);
 If Dataset.Active then
  TRESTDWMemTable(Dataset).SortOnFields;
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

{$IF Defined(MSWINDOWS) or Defined(WIN32) or Defined(WIN64) or Defined(WINDOWS)}
Procedure TRESTDWMemTableEx.InternalAddRecord(Buffer: Pointer;
  {$IFDEF FPC}aAppend: Boolean{$ELSE}Append: Boolean{$ENDIF});
Begin
  inherited InternalAddRecord(buffer, {$IFDEF FPC}aAppend{$ELSE}Append{$ENDIF});
  If Active and Filtered then
    inc(fFilteredRecordCount);
End;
{$IFEND}

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
      aFilterRecs := 0;
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
  //  Refresh()
  //Else
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
