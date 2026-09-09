{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2014 by Joost van der Sluis and other members of the
    Free Pascal development team

    MemoryDataset implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

Unit uRESTDWMemoryDataset;

{$I uRESTDW.inc}

{$IFDEF FPC}
{$MODE OBJFPC}
{$ENDIF}
{$h+}

Interface

Uses Classes,SysUtils,DB,Variants,
{$IFNDEF FPC}SqlTimSt,{$ENDIF}
uRESTDWMemoryDatasetParser, uRESTDWTools, uRESTDWProtoTypes, uRESTDWConsts;

{$IFNDEF FPC}
resourcestring
  SInvPacketRecordsValue = 'PacketRecords has to be larger than 0';
  SInvPacketRecordsValueFieldNames = 'PacketRecords must be -1 if IndexFieldNames is set';
  SInvPacketRecordsValueUniDirectional = 'PacketRecords must not be -1 on an unidirectional dataset';
  SNoIndexFieldNameGiven = 'Cannot create index "%s": No fields available.';
  SErrNoDataset = 'Missing (compatible) underlying dataset, can not open';
  SErrIndexBasedOnInvField = 'Field "%s" has an invalid field type (%s) to base index on.';
  SMaxIndexes = 'The maximum amount of indexes is reached';
  SMinIndexes = 'The minimum amount of indexes is 1';
  SUnsupportedFieldType = 'Fieldtype %s is not supported';
  SReadOnlyField = 'Field %s cannot be modified, it is read-only.';
  SNoSuchRecord = 'Could not find the requested record.';
  SStreamNotRecognised = 'The data-stream format is not recognized';
  SFieldIsNull = 'The field is null';
  SNoReaderClassRegistered = 'There is no TDatapacketReaderClass registered for this kind of data-stream';
  SErrNoFieldsDefined = 'Can not create a dataset when there are no fielddefinitions or fields defined';
  SErrApplyUpdBeforeRefresh = 'Must apply updates before refreshing data';
  SInvalidBookmark = 'Invalid bookmark';
  SUniDirectional = 'Operation cannot be performed on an unidirectional dataset';
{$ENDIF}

Type
{$IFDEF FPC}
  TRESTDWPtrInt = PtrInt;
{$ELSE}
  TRESTDWPtrInt = NativeInt;
{$ENDIF}
  TRESTDWMemBytes = array Of Byte;
  TRESTDWQWord = UInt64;
  PRESTDWQWord = ^TRESTDWQWord;
{$IFNDEF FPC}
  PLargeInt = ^LargeInt;
{$ENDIF}

  TRESTDWCustomMemTable = Class;

  TRESTDWMemDataReferenceKind = (drData, drDelta);

  TRESTDWMemDataReference = Class(TObject)
  Private
    FDataSet : TRESTDWCustomMemTable;
    FKind    : TRESTDWMemDataReferenceKind;
  Public
    Constructor Create(ADataSet: TRESTDWCustomMemTable; AKind: TRESTDWMemDataReferenceKind);
    Procedure AssignTo(ADataSet: TRESTDWCustomMemTable);
    Property DataSet : TRESTDWCustomMemTable Read FDataSet;
    Property Kind : TRESTDWMemDataReferenceKind Read FKind;
  End;

  { TRESTDWMemBlobBuffer }

  PRESTDWMemBlobBuffer = ^TRESTDWMemBlobBuffer;
  TRESTDWMemBlobBuffer = Record
    FieldNo : integer;
    OrgBufID: integer;
    Buffer  : pointer;
    Size    : TRESTDWPtrInt;
  End;

  PRESTDWMemBlobField = ^TRESTDWMemBlobField;
  TRESTDWMemBlobField = Record
    ConnBlobBuffer : array[0..11] Of byte; // DB specific data is stored here
    BlobBuffer     : PRESTDWMemBlobBuffer;
  End;

  { TRESTDWMemBlobStream }

  TRESTDWMemBlobStream = Class(TStream)
  Private
    FField      : TBlobField;
    FDataSet    : TRESTDWCustomMemTable;
    FBlobBuffer : PRESTDWMemBlobBuffer;
    FPosition   : TRESTDWPtrInt;
    FModified   : boolean;
  Protected
    Function Seek(Offset: Longint; Origin: Word): Longint; override;
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
  Public
    Constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    Destructor Destroy; override;
  End;


  PRESTDWMemRecLinkItem = ^TRESTDWMemRecLinkItem;
  TRESTDWMemRecLinkItem = Record
    prior   : PRESTDWMemRecLinkItem;
    next    : PRESTDWMemRecLinkItem;
  End;

  PRESTDWMemBookmark = ^TRESTDWMemBookmark;
  TRESTDWMemBookmark = Record
    BookmarkData : PRESTDWMemRecLinkItem;
    BookmarkInt  : integer; // was used by TRESTDWMemArrayIndex
    BookmarkFlag : TBookmarkFlag;
  End;

  TRESTDWMemRecUpdateBuffer = Record
    UpdateKind         : TUpdateKind;
{  BookMarkData:
     - Is -1 if the update has canceled out. For example: an appended record has been deleted again
     - If UpdateKind is ukInsert, it contains a bookmark to the newly created record
     - If UpdateKind is ukModify, it contains a bookmark to the record with the new data
     - If UpdateKind is ukDelete, it contains a bookmark to the deleted record (ie: the record is still there)
}
    BookmarkData       : TRESTDWMemBookmark;
{  NextBookMarkData:
     - If UpdateKind is ukDelete, it contains a bookmark to the record just after the deleted record
}
    NextBookmarkData   : TRESTDWMemBookmark;
{  OldValuesBuffer:
     - If UpdateKind is ukModify, it contains a record buffer which contains the old data
     - If UpdateKind is ukDelete, it contains a record buffer with the data of the deleted record
}
    OldValuesBuffer    : TRecordBuffer;
  End;
  TRESTDWMemRecordsUpdateBuffer = array Of TRESTDWMemRecUpdateBuffer;

  TRESTDWMemCompareFunc = Function(subValue, aValue: pointer; size: integer; options: TLocateOptions): int64;

  TRESTDWMemCompareRec = Record
                   CompareFunc : TRESTDWMemCompareFunc;
                   Off         : TRESTDWPtrInt;
                   NullBOff    : TRESTDWPtrInt;
                   FieldInd    : longint;
                   Size        : integer;
                   Options     : TLocateOptions;
                   Desc        : Boolean;
                  End;
  TRESTDWMemCompareStruct = array Of TRESTDWMemCompareRec;

  { TRESTDWMemInternalIndex }

  TRESTDWMemInternalIndex = Class(TObject)
  Private
    FDataset : TRESTDWCustomMemTable;
  Protected
    Function GetBookmarkSize: integer; virtual; abstract;
    Function GetCurrentBuffer: Pointer; virtual; abstract;
    Function GetCurrentRecord: TRecordBuffer; virtual; abstract;
    Function GetIsInitialized: boolean; virtual; abstract;
    Function GetSpareBuffer: TRecordBuffer; virtual; abstract;
    Function GetSpareRecord: TRecordBuffer; virtual; abstract;
    Function GetRecNo: Longint; virtual; abstract;
    Procedure SetRecNo(ARecNo: Longint); virtual; abstract;
  Public
    DBCompareStruct : TRESTDWMemCompareStruct;
    Name            : String;
    FieldsName      : String;
    CaseinsFields   : String;
    DescFields      : String;
    Options         : TIndexOptions;
    IndNr           : integer;

    Constructor Create(Const ADataset : TRESTDWCustomMemTable); virtual;
    Function ScrollBackward : TGetResult; virtual; abstract;
    Function ScrollForward : TGetResult;  virtual; abstract;
    Function GetCurrent : TGetResult;  virtual; abstract;
    Function ScrollFirst : TGetResult;  virtual; abstract;
    Procedure ScrollLast; virtual; abstract;
    // Gets prior/next record relative to given bookmark; does not change current record
    Function GetRecord(ABookmark: PRESTDWMemBookmark; GetMode: TGetMode): TGetResult; virtual;

    Procedure SetToFirstRecord; virtual; abstract;
    Procedure SetToLastRecord; virtual; abstract;

    Procedure StoreCurrentRecord;  virtual; abstract;
    Procedure RestoreCurrentRecord;  virtual; abstract;

    Function CanScrollForward : Boolean;  virtual; abstract;
    Procedure DoScrollForward;  virtual; abstract;

    Procedure StoreCurrentRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark);  virtual; abstract;
    Procedure StoreSpareRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark);  virtual; abstract;
    Procedure GotoBookmark(Const ABookmark : PRESTDWMemBookmark); virtual; abstract;
    Function BookmarkValid(Const ABookmark: PRESTDWMemBookmark): boolean; virtual;
    Function CompareBookmarks(Const ABookmark1, ABookmark2 : PRESTDWMemBookmark) : integer; virtual;
    Function SameBookmarks(Const ABookmark1, ABookmark2 : PRESTDWMemBookmark) : boolean; virtual;

    Procedure InitialiseIndex; virtual; abstract;

    Procedure InitialiseSpareRecord(Const ASpareRecord : TRecordBuffer); virtual; abstract;
    Procedure ReleaseSpareRecord; virtual; abstract;

    Procedure BeginUpdate; virtual; abstract;
    // Adds a record to the end of the index as the new last record (spare record)
    // Normally only used in GetNextPacket
    Procedure AddRecord; virtual; abstract;
    // Inserts a record before the current record, or if the record is sorted,
    // inserts it in the proper position
    Procedure InsertRecordBeforeCurrentRecord(Const ARecord : TRecordBuffer); virtual; abstract;
    Procedure RemoveRecordFromIndex(Const ABookmark : TRESTDWMemBookmark); virtual; abstract;
    Procedure OrderCurrentRecord; virtual; abstract;
    Procedure EndUpdate; virtual; abstract;

    property SpareRecord : TRecordBuffer read GetSpareRecord;
    property SpareBuffer : TRecordBuffer read GetSpareBuffer;
    property CurrentRecord : TRecordBuffer read GetCurrentRecord;
    property CurrentBuffer : Pointer read GetCurrentBuffer;
    property IsInitialized : boolean read GetIsInitialized;
    property BookmarkSize : integer read GetBookmarkSize;
    property RecNo : Longint read GetRecNo write SetRecNo;
  End;

  { TRESTDWMemDoubleLinkedIndex }

  TRESTDWMemDoubleLinkedIndex = Class(TRESTDWMemInternalIndex)
  Private
    FCursOnFirstRec : boolean;

    FStoredRecBuf  : PRESTDWMemRecLinkItem;
    FCurrentRecBuf  : PRESTDWMemRecLinkItem;
  Protected
    Function GetBookmarkSize: integer; override;
    Function GetCurrentBuffer: Pointer; override;
    Function GetCurrentRecord: TRecordBuffer; override;
    Function GetIsInitialized: boolean; override;
    Function GetSpareBuffer: TRecordBuffer; override;
    Function GetSpareRecord: TRecordBuffer; override;
    Function GetRecNo: Longint; override;
    Procedure SetRecNo(ARecNo: Longint); override;
  Public
    FLastRecBuf     : PRESTDWMemRecLinkItem;
    FFirstRecBuf    : PRESTDWMemRecLinkItem;
    FNeedScroll     : Boolean;

    Function ScrollBackward : TGetResult; override;
    Function ScrollForward : TGetResult; override;
    Function GetCurrent : TGetResult; override;
    Function ScrollFirst : TGetResult; override;
    Procedure ScrollLast; override;
    Function GetRecord(ABookmark: PRESTDWMemBookmark; GetMode: TGetMode): TGetResult; override;

    Procedure SetToFirstRecord; override;
    Procedure SetToLastRecord; override;

    Procedure StoreCurrentRecord; override;
    Procedure RestoreCurrentRecord; override;

    Function CanScrollForward : Boolean; override;
    Procedure DoScrollForward; override;

    Procedure StoreCurrentRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark); override;
    Procedure StoreSpareRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark); override;
    Procedure GotoBookmark(Const ABookmark : PRESTDWMemBookmark); override;
    Function CompareBookmarks(Const ABookmark1, ABookmark2: PRESTDWMemBookmark): integer; override;
    Function SameBookmarks(Const ABookmark1, ABookmark2 : PRESTDWMemBookmark) : boolean; override;
    Procedure InitialiseIndex; override;

    Procedure InitialiseSpareRecord(Const ASpareRecord : TRecordBuffer); override;
    Procedure ReleaseSpareRecord; override;

    Procedure BeginUpdate; override;
    Procedure AddRecord; override;
    Procedure InsertRecordBeforeCurrentRecord(Const ARecord : TRecordBuffer); override;
    Procedure RemoveRecordFromIndex(Const ABookmark : TRESTDWMemBookmark); override;
    Procedure OrderCurrentRecord; override;
    Procedure EndUpdate; override;
  End;

  { TRESTDWMemUniDirectionalIndex }

  TRESTDWMemUniDirectionalIndex = Class(TRESTDWMemInternalIndex)
  Private
    FSPareBuffer:  TRecordBuffer;
  Protected
    Function GetBookmarkSize: integer; override;
    Function GetCurrentBuffer: Pointer; override;
    Function GetCurrentRecord: TRecordBuffer; override;
    Function GetIsInitialized: boolean; override;
    Function GetSpareBuffer: TRecordBuffer; override;
    Function GetSpareRecord: TRecordBuffer; override;
    Function GetRecNo: Longint; override;
    Procedure SetRecNo(ARecNo: Longint); override;
  Public
    Function ScrollBackward : TGetResult; override;
    Function ScrollForward : TGetResult; override;
    Function GetCurrent : TGetResult; override;
    Function ScrollFirst : TGetResult; override;
    Procedure ScrollLast; override;

    Procedure SetToFirstRecord; override;
    Procedure SetToLastRecord; override;

    Procedure StoreCurrentRecord; override;
    Procedure RestoreCurrentRecord; override;

    Function CanScrollForward : Boolean; override;
    Procedure DoScrollForward; override;

    Procedure StoreCurrentRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark); override;
    Procedure StoreSpareRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark); override;
    Procedure GotoBookmark(Const ABookmark : PRESTDWMemBookmark); override;

    Procedure InitialiseIndex; override;
    Procedure InitialiseSpareRecord(Const ASpareRecord : TRecordBuffer); override;
    Procedure ReleaseSpareRecord; override;

    Procedure BeginUpdate; override;
    Procedure AddRecord; override;
    Procedure InsertRecordBeforeCurrentRecord(Const ARecord : TRecordBuffer); override;
    Procedure RemoveRecordFromIndex(Const ABookmark : TRESTDWMemBookmark); override;
    Procedure OrderCurrentRecord; override;
    Procedure EndUpdate; override;
  End;


  { TRESTDWMemArrayIndex }

  TRESTDWMemArrayIndex = Class(TRESTDWMemInternalIndex)
  Private
    FStoredRecBuf  : integer;

    FInitialBuffers,
    FGrowBuffer     : integer;
    Function GetRecordFromBookmark(ABookmark: TRESTDWMemBookmark) : integer;
  Protected
    Function GetBookmarkSize: integer; override;
    Function GetCurrentBuffer: Pointer; override;
    Function GetCurrentRecord: TRecordBuffer; override;
    Function GetIsInitialized: boolean; override;
    Function GetSpareBuffer: TRecordBuffer; override;
    Function GetSpareRecord: TRecordBuffer; override;
    Function GetRecNo: Longint; override;
    Procedure SetRecNo(ARecNo: Longint); override;
  Public
    FRecordArray    : array Of Pointer;
    FCurrentRecInd  : integer;
    FLastRecInd     : integer;
    FNeedScroll     : Boolean;
    Constructor Create(Const ADataset: TRESTDWCustomMemTable); override;
    Function ScrollBackward : TGetResult; override;
    Function ScrollForward : TGetResult; override;
    Function GetCurrent : TGetResult; override;
    Function ScrollFirst : TGetResult; override;
    Procedure ScrollLast; override;

    Procedure SetToFirstRecord; override;
    Procedure SetToLastRecord; override;

    Procedure StoreCurrentRecord; override;
    Procedure RestoreCurrentRecord; override;

    Function CanScrollForward : Boolean; override;
    Procedure DoScrollForward; override;

    Procedure StoreCurrentRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark); override;
    Procedure StoreSpareRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark); override;
    Procedure GotoBookmark(Const ABookmark : PRESTDWMemBookmark); override;

    Procedure InitialiseIndex; override;

    Procedure InitialiseSpareRecord(Const ASpareRecord : TRecordBuffer); override;
    Procedure ReleaseSpareRecord; override;

    Procedure BeginUpdate; override;
    Procedure AddRecord; override;
    Procedure InsertRecordBeforeCurrentRecord(Const ARecord : TRecordBuffer); override;
    Procedure RemoveRecordFromIndex(Const ABookmark : TRESTDWMemBookmark); override;
    Procedure EndUpdate; override;
  End;


  { TRESTDWMemTableReader }

  TRESTDWMemRowStateValue = (rsvOriginal, rsvDeleted, rsvInserted, rsvUpdated, rsvDetailUpdates);
  TRESTDWMemRowState = set Of TRESTDWMemRowStateValue;


  { TRESTDWMemDataPacketReader }

  TRESTDWMemDataPacketFormat = (dfBinary,dfXML,dfXMLUTF8,dfAny,dfDefault);

  TRESTDWMemDataPacketReader = Class;
  TRESTDWMemDataPacketReaderClass = Class Of TRESTDWMemDataPacketReader;
  TRESTDWMemDataPacketReader = Class(TObject)
    FDataSet: TRESTDWCustomMemTable;
    FStream : TStream;
  Protected
    Class Function RowStateToByte(Const ARowState : TRESTDWMemRowState) : byte;
    Class Function ByteToRowState(Const AByte : Byte) : TRESTDWMemRowState;
    Procedure RestoreBlobField(AField: TField; ASource: pointer; ASize: integer);
    property DataSet: TRESTDWCustomMemTable read FDataSet;
    property Stream: TStream read FStream;
  Public
    Constructor Create(ADataSet: TRESTDWCustomMemTable; AStream : TStream); virtual;
    // Load a dataset from stream:
    // Load the field definitions from a stream.
    Procedure LoadFieldDefs(Var AnAutoIncValue : integer); virtual; abstract;
    // Is called before the records are loaded
    Procedure InitLoadRecords; virtual; abstract;
    // Returns if there is at least one more record available in the stream
    Function GetCurrentRecord : boolean; virtual; abstract;
    // Return the RowState of the current record, and the order of the update
    Function GetRecordRowState(out AUpdOrder : Integer) : TRESTDWMemRowState; virtual; abstract;
    // Store a record from stream in the current record buffer
    Procedure RestoreRecord; virtual; abstract;
    // Move the stream to the next record
    Procedure GotoNextRecord; virtual; abstract;

    // Store a dataset to stream:
    // Save the field definitions to a stream.
    Procedure StoreFieldDefs(AnAutoIncValue : integer); virtual; abstract;
    // Save a record from the current record buffer to the stream
    Procedure StoreRecord(ARowState : TRESTDWMemRowState; AUpdOrder : integer = 0); virtual; abstract;
    // Is called after all records are stored
    Procedure FinalizeStoreRecords; virtual; abstract;
    // Checks if the provided stream is of the right format for this class
    Class Function RecognizeStream(AStream : TStream) : boolean; virtual; abstract;
  End;

  { TRESTDWTBinaryDatapacketReader }

  { Data layout:
     Header section:
       Identification: 16 bytes: 'BinRESTDWDataSet'
       Version: 1 byte
     Columns section:
       Number of Fields: 2 bytes
       For each FieldDef: Name, DisplayName, Size: 2 bytes, DataType: 2 bytes, ReadOnlyAttr: 1 byte
     Parameter section:
       AutoInc Value: 4 bytes
     Rows section:
       Row header: each row begins with $fe: 1 byte
                   row state: 1 byte (original, deleted, inserted, modified)
                   update order: 4 bytes
                   null bitmap: 1 byte per each 8 fields (if field is null corresponding bit is 1)
       Row data: variable length data are prefixed with 4 byte length indicator
                 null fields are not stored (see: null bitmap)
  }

  TRESTDWTBinaryDatapacketReader = Class(TRESTDWMemDataPacketReader)
  Private
    Const
      RESTDWBinaryIdent = 'BinRESTDWDataSet';
      StringFieldTypes = [ftString,ftFixedChar,ftWideString,ftFixedWideChar];
      BlobFieldTypes = [ftBlob,ftMemo,ftGraphic,ftWideMemo];
      VarLenFieldTypes = StringFieldTypes + BlobFieldTypes + [ftBytes,ftVarBytes];
    Var
      FNullBitmapSize: integer;
      FNullBitmap: TRESTDWMemBytes;
      FWireFieldTypes: Array Of Byte;
    Function ReadByteValue: Byte;
    Function ReadWordValue: Word;
    Function ReadDWordValue: LongWord;
    Function ReadAnsiStringValue: AnsiString;
    Function GetFixedWireSize(AWireType: Byte; AField: TField): Cardinal;
    Procedure WriteByteValue(AValue: Byte);
    Procedure WriteWordValue(AValue: Word);
    Procedure WriteDWordValue(AValue: LongWord);
    Procedure WriteAnsiStringValue(Const AValue: AnsiString);
  Protected
    Var
      FVersion: byte;
  Public
    Constructor Create(ADataSet: TRESTDWCustomMemTable; AStream : TStream); override;
    Procedure LoadFieldDefs(Var AnAutoIncValue : integer); override;
    Procedure StoreFieldDefs(AnAutoIncValue : integer); override;
    Procedure InitLoadRecords; override;
    Function GetCurrentRecord : boolean; override;
    Function GetRecordRowState(out AUpdOrder : Integer) : TRESTDWMemRowState; override;
    Procedure RestoreRecord; override;
    Procedure GotoNextRecord; override;
    Procedure StoreRecord(ARowState : TRESTDWMemRowState; AUpdOrder : integer = 0); override;
    Procedure FinalizeStoreRecords; override;
    Class Function RecognizeStream(AStream : TStream) : boolean; override;
  End;

  TRESTDWBinaryFieldDef = Record
    Name: String;
    DisplayName: String;
    Size: Word;
    DataType: TFieldType;
    ReadOnly: Boolean;
  End;

  TRESTDWBinaryPacketWriter = Class
  Private
    FStream: TStream;
    FFields: array Of TRESTDWBinaryFieldDef;
    FNullBitmap: TRESTDWMemBytes;
    FNullBitmapSize: Integer;
    FNullBitmapPosition: Int64;
{$IFDEF RESTDWLAZARUS}
    FDatabaseCharSet : TDatabaseCharSet;
{$ENDIF}
    Procedure WriteAnsiString(Const AValue: AnsiString);
    Class Function IsStringField(AType: TFieldType): Boolean;
    Class Function IsVariableField(AType: TFieldType): Boolean;
  Public
    Constructor Create(AStream: TStream);
    Procedure ClearFieldDefs;
    Procedure AddFieldDef(Const AName, ADisplayName: String; ASize: Word;
      ADataType: TFieldType; AReadOnly: Boolean);
    Procedure StoreFieldDefs(AnAutoIncValue: Integer);
    Procedure BeginRecord;
    Procedure StoreNull(AFieldIndex: Integer);
    Procedure StoreField(AFieldIndex: Integer; ABuffer: Pointer; ASize: LongWord);
    Procedure EndRecord;
{$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet : TDatabaseCharSet Read FDatabaseCharSet Write FDatabaseCharSet;
{$ENDIF}
  End;

  { TRESTDWCustomMemTable }

{$IFDEF FPC}
  TRESTDWDBDataSet = TDBDataSet;
{$ELSE}
  TRESTDWDBDataSet = TDataSet;
{$ENDIF}

  TRESTDWCustomMemTable = Class(TRESTDWDBDataSet)
  Private
    Type

      { TRESTDWMemTableIndex }
      TRESTDWMemIndexType = (itNormal,itDefault,itCustom);
      TRESTDWMemTableIndex = Class(TIndexDef)
      Private
        FBufferIndex: TRESTDWMemInternalIndex;
        FDiscardOnClose: Boolean;
        FIndexType : TRESTDWMemIndexType;
      Public
        Destructor Destroy; override;
        // Free FBufferIndex;
        Procedure Clearindex;
        // Set TIndexDef properties on FBufferIndex;
        Procedure SetIndexProperties;
        // Return true if the buffer must be built.
        // Default buffer must not be built, custom only when it is not the current.
        Function MustBuild(aCurrent : TRESTDWMemTableIndex) : Boolean;
        // Return true if the buffer must be updated
        // This are all indexes except custom, unless it is the active index
        Function IsActiveIndex(aCurrent : TRESTDWMemTableIndex) : Boolean;
        // The actual buffer.
        Property BufferIndex : TRESTDWMemInternalIndex Read FBufferIndex Write FBufferIndex;
        // If the Index is created after Open, then it will be discarded on close.
        Property DiscardOnClose : Boolean Read FDiscardOnClose;
        // Skip build of this index
        Property IndexType : TRESTDWMemIndexType Read FIndexType Write FIndexType;
      End;

      { TRESTDWMemTableIndexDefs }
      TRESTDWMemTableIndexDefs = Class(TIndexDefs)
      Private
        Function GetMemDatasetIndex(AIndex : Integer): TRESTDWMemTableIndex;
        Function GetBufferIndex(AIndex : Integer): TRESTDWMemInternalIndex;
      Public
        Constructor Create(aDataset : TDataset); override;
        // Does not raise an exception if not found.
        Function FindIndex(Const IndexName: string): TRESTDWMemTableIndex;
        Function AddMemTableIndexDef : TRESTDWMemTableIndex;
        Property BufIndexdefs [AIndex : Integer] : TRESTDWMemTableIndex Read GetMemDatasetIndex;
        Property BufIndexes [AIndex : Integer] : TRESTDWMemInternalIndex Read GetBufferIndex;
      End;

    Procedure BuildCustomIndex;
    Function GetBufIndex(Aindex : Integer): TRESTDWMemInternalIndex;
    Function GetBufIndexDef(Aindex : Integer): TRESTDWMemTableIndex;
    Function GetCurrentIndexBuf: TRESTDWMemInternalIndex;
    Procedure InitUserIndexes;
  Private
    FFileName: TFileName;
    FReadFromFile   : boolean;
    FFileStream     : TFileStream;
    FDatasetReader  : TRESTDWMemDataPacketReader;
    FMaxIndexesCount: integer;
    FDefaultIndex,
    FCurrentIndexDef : TRESTDWMemTableIndex;
    FFilterBuffer   : TRecordBuffer;
    FBRecordCount   : integer;
    FReadOnly       : Boolean;
    FSavedState     : TDatasetState;
    FPacketRecords  : integer;
    FRecordSize     : Integer;
    FIndexFieldNames : String;
    FIndexName      : String;
    FNullmaskSize   : byte;
    FOpen           : Boolean;
    FUpdateBuffer   : TRESTDWMemRecordsUpdateBuffer;
    FDataReference  : TRESTDWMemDataReference;
    FDeltaReference : TRESTDWMemDataReference;
    FCurrentUpdateBuffer : integer;
{$IFDEF FPC}
    FAutoIncValue   : Longint;
{$ELSE}
    FAutoIncValue   : Integer;
{$ENDIF}
    FAutoIncField   : TAutoIncField;
    FIndexes        : TRESTDWMemTableIndexDefs;
    FRuntimeIndexes : TRESTDWMemTableIndexDefs;
    FParser         : TRESTDWMemParser;
    FFieldBufPositions : array Of longint;
    FAllPacketsFetched : boolean;
{$IFDEF RESTDWLAZARUS}
    FDatabaseCharSet : TDatabaseCharSet;
{$ENDIF}

    FBlobBuffers      : array Of PRESTDWMemBlobBuffer;
    FUpdateBlobBuffers: array Of PRESTDWMemBlobBuffer;
    FRefreshing : Boolean;

    Procedure ProcessFieldsToCompareStruct(Const AFields, ADescFields, ACInsFields: TList;
      Const AIndexOptions: TIndexOptions; Const ALocateOptions: TLocateOptions; out ACompareStruct: TRESTDWMemCompareStruct);
    Function BufferOffset: integer;
    Function GetFieldSize(FieldDef : TFieldDef) : longint;
    Procedure CalcRecordSize;
    Function  IntAllocRecordBuffer: TRecordBuffer;
    Procedure InitFieldDefsFromPersistentFields;
{$IFDEF FPC}
    Procedure NormalizeNumericFieldRanges;
    Procedure NormalizeFieldDisplayWidths;
{$ENDIF}
    Procedure IntLoadFieldDefsFromFile;
    Procedure IntLoadRecordsFromFile;
    Function  GetCurrentBuffer: TRecordBuffer;
    Procedure CurrentRecordToBuffer(Buffer: TRecordBuffer);
    Function LoadBuffer(Buffer : TRecordBuffer): TGetResult;
    Procedure FetchAll;
    Function GetRecordUpdateBuffer(Const ABookmark : TRESTDWMemBookmark; IncludePrior : boolean = false; AFindNext : boolean = false) : boolean;
    Function GetRecordUpdateBufferCached(Const ABookmark : TRESTDWMemBookmark; IncludePrior : boolean = false) : boolean;
    Function GetActiveRecordUpdateBuffer : boolean;
    Procedure CancelRecordUpdateBuffer(AUpdateBufferIndex: integer; Var ABookmark: TRESTDWMemBookmark);
    Procedure ParseFilter(Const AFilter: string);
    Procedure RemoveUnnamedFields;

    Function GetDataReference: TRESTDWMemDataReference;
    Function GetDeltaReference: TRESTDWMemDataReference;
    Procedure SetDataReference(AValue: TRESTDWMemDataReference);
    Procedure SaveDeltaToStream(AStream: TStream);
    Function GetBufUniDirectional: boolean;
    // indexes handling
    Procedure SetMaxIndexesCount(Const AValue: Integer);
    Procedure SetBufUniDirectional(Const AValue: boolean);
    Function DefaultIndex : TRESTDWMemTableIndex;
    Function DefaultBufferIndex : TRESTDWMemInternalIndex;
    Procedure InitDefaultIndexes;
    Procedure BuildIndex(AIndex : TRESTDWMemInternalIndex);
    Procedure BuildIndexes;
    Procedure RemoveRecordFromIndexes(Const ABookmark : TRESTDWMemBookmark);
    Procedure InternalCreateIndex(F: TRESTDWMemTableIndex); virtual;
    Property CurrentIndexBuf : TRESTDWMemInternalIndex Read GetCurrentIndexBuf;
    Property CurrentIndexDef : TRESTDWMemTableIndex Read FCurrentIndexDef;
    Property BufIndexDefs[Aindex : Integer] : TRESTDWMemTableIndex Read GetBufIndexDef;
    Property BufIndexes[Aindex : Integer] : TRESTDWMemInternalIndex Read GetBufIndex;
  Protected
    // abstract & virtual methods of TDataset
    Class Function DefaultReadFileFormat : TRESTDWMemDataPacketFormat; virtual;
    Class Function DefaultWriteFileFormat : TRESTDWMemDataPacketFormat; virtual;
    Class Function DefaultPacketClass : TRESTDWMemDataPacketReaderClass ; virtual;
    Function CreateDefaultPacketReader(aStream : TStream): TRESTDWMemDataPacketReader ; virtual;
    Procedure SetPacketRecords(aValue : integer); virtual;
{$IFDEF FPC}
    Procedure SetRecNo(Value: Longint); override;
    Function  GetRecNo: Longint; override;
{$ELSE}
    Procedure SetRecNo(Value: Integer); override;
    Function  GetRecNo: Integer; override;
{$ENDIF}
    Function GetChangeCount: integer; virtual;
    Function  AllocRecordBuffer: TRecordBuffer; override;
    Procedure FreeRecordBuffer(Var Buffer: TRecordBuffer); override;
    Procedure ClearCalcFields(Buffer: TRecordBuffer); override;
    Procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    Function  GetCanModify: Boolean; override;
    Function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    Procedure DoBeforeClose; override;
    Procedure InternalInitFieldDefs; override;
    Procedure InternalOpen; override;
    Procedure InternalClose; override;
    Function GetRecordSize: Word; override;
    Procedure InternalPost; override;
    Procedure InternalCancel; Override;
    Procedure InternalDelete; override;
    Procedure InternalFirst; override;
    Procedure InternalLast; override;
    Procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    Procedure InternalGotoBookmark(ABookmark: Pointer); override;
    Procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    Procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    Procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    Function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    Function IsCursorOpen: Boolean; override;
{$IFDEF FPC}
    Function  GetRecordCount: Longint; override;
{$ELSE}
    Function  GetRecordCount: Integer; override;
{$ENDIF}
    Procedure SetFilterText(Const Value: String); override; {virtual;}
    Procedure SetFiltered(Value: Boolean); override; {virtual;}
    Procedure InternalRefresh; override;
{$IFNDEF FPC}
    Procedure InternalHandleException; override;
{$ENDIF}
    Procedure DataEvent(Event: TDataEvent; Info: TRESTDWPtrInt); override;
    // virtual or methods, which can be used by descendants
    Function GetNewBlobBuffer : PRESTDWMemBlobBuffer;
    Function GetNewWriteBlobBuffer : PRESTDWMemBlobBuffer;
    Procedure FreeBlobBuffer(Var ABlobBuffer: PRESTDWMemBlobBuffer);
    Function InternalAddIndex(Const AName, AFields : string; AOptions : TIndexOptions; Const ADescFields: string;
      Const ACaseInsFields: string) : TRESTDWMemTableIndex; virtual;
    Procedure BeforeRefreshOpenCursor; virtual;
    Procedure DoFilterRecord(out Acceptable: Boolean); virtual;
    Procedure SetReadOnly(AValue: Boolean); virtual;
    Function IsReadFromPacket : Boolean;
    Function getnextpacket : integer;
    Function GetPacketReader(Const Format: TRESTDWMemDataPacketFormat; Const AStream: TStream): TRESTDWMemDataPacketReader; virtual;
    // abstracts, must be overidden by descendents
    Function Fetch : boolean; virtual;
    Function LoadField(FieldDef : TFieldDef;buffer : pointer; out CreateBlob : boolean) : boolean; virtual;
    Procedure LoadBlobIntoBuffer(FieldDef: TFieldDef;ABlobBuf: PRESTDWMemBlobField); virtual;
    Function DoLocate(Const KeyFields: string; Const KeyValues: Variant; Options: TLocateOptions; DoEvents : Boolean) : boolean;
    Property Refreshing : Boolean Read FRefreshing;
  Public
    Function GetIndexDefs : TIndexDefs;
    Procedure SetIndexDefs(Value : TIndexDefs);
    Function GetIndexFieldNames : String;
    Function GetIndexName : String;
    Procedure SetIndexFieldNames(Const AValue : String);
    Procedure SetIndexName(AValue : String);
    Function IsSequenced : Boolean; Override;
    Constructor Create(AOwner: TComponent); override;
    Function GetFieldDataPtr(Field: TField; Buffer: Pointer): Boolean;
    Procedure SetFieldDataPtr(Field: TField; Buffer: Pointer);
{$IFDEF FPC}
    Function GetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean): Boolean; override;
    Function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    Procedure SetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean); override;
    Procedure SetFieldData(Field: TField; Buffer: Pointer); override;
{$ELSE}
 {$IFDEF DELPHIXEUP}
    Function GetFieldData(Field: TField; Var Buffer: TValueBuffer): Boolean; overload; override;
    Procedure SetFieldData(Field: TField; Buffer: TValueBuffer); overload; override;
  {$IFDEF RTL240_UP}
    Function GetFieldData(Field: TField; Buffer: Pointer): Boolean; overload; override;
    Procedure SetFieldData(Field: TField; Buffer: Pointer); overload; override;
  {$ENDIF}
 {$ELSE}
    Function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    Procedure SetFieldData(Field: TField; Buffer: Pointer); override;
 {$ENDIF}
{$ENDIF}
    Procedure MergeChangeLog;
    Procedure RevertRecord;
    Procedure CancelUpdates; virtual;
    Procedure EmptyTable;
    Destructor Destroy; override;
    Function Locate(Const KeyFields: string; Const KeyValues: Variant; Options: TLocateOptions) : boolean; override;
    Function Lookup(Const KeyFields: string; Const KeyValues: Variant; Const ResultFields: string): Variant; override;
    Function UpdateStatus: TUpdateStatus; override;
    Function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    Procedure AddIndex(Const AName, AFields : string; AOptions : TIndexOptions; Const ADescFields: string = '';
      Const ACaseInsFields: string = ''); virtual;
    Procedure ClearIndexes;

    Procedure SetDatasetPacket(AReader : TRESTDWMemDataPacketReader);
    Procedure GetDatasetPacket(AWriter : TRESTDWMemDataPacketReader);
    Procedure LoadFromStream(AStream : TStream; Format: TRESTDWMemDataPacketFormat = dfDefault);
    Procedure SaveToStream(AStream : TStream; Format: TRESTDWMemDataPacketFormat = dfDefault);
    Procedure LoadFromFile(AFileName: string = ''; Format: TRESTDWMemDataPacketFormat = dfDefault);
    Procedure SaveToFile(AFileName: string = ''; Format: TRESTDWMemDataPacketFormat = dfBinary);
    Procedure CreateDataset;
    Property Data : TRESTDWMemDataReference Read GetDataReference Write SetDataReference;
    Property Delta : TRESTDWMemDataReference Read GetDeltaReference;
    Procedure Clear; // Will close and remove all field definitions.
    Function BookmarkValid(ABookmark: TBookmark): Boolean; override;
{$IFDEF FPC}
    Function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Longint; override;
{$ELSE}
    Function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
{$ENDIF}
    Procedure CopyFromDataset(DataSet : TDataSet;CopyData : Boolean=True);
    property ChangeCount : Integer read GetChangeCount;
    property MaxIndexesCount : Integer read FMaxIndexesCount write SetMaxIndexesCount default 2;
    property ReadOnly : Boolean read FReadOnly write SetReadOnly default false;
  Published
    property FileName : TFileName read FFileName write FFileName;
    property PacketRecords : Integer read FPacketRecords write SetPacketRecords default 10;
    property IndexDefs : TIndexDefs read GetIndexDefs write SetIndexDefs;
    property IndexName : String read GetIndexName write SetIndexName;
    property IndexFieldNames : String read GetIndexFieldNames write SetIndexFieldNames;
    property UniDirectional: boolean read GetBufUniDirectional write SetBufUniDirectional default False;
{$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet : TDatabaseCharSet Read FDatabaseCharSet Write FDatabaseCharSet Default csUndefined;
{$ENDIF}
  End;

  TRESTDWMemTable = Class(TRESTDWCustomMemTable)
  Published
    Property FileName;
    Property PacketRecords;
    Property IndexDefs;
    Property IndexName;
    Property IndexFieldNames;
    Property UniDirectional;
{$IFDEF RESTDWLAZARUS}
    Property DatabaseCharSet;
{$ENDIF}
    Property MaxIndexesCount;
    Property FieldDefs;
    Property Active;
    Property AutoCalcFields;
    Property Filter;
    Property Filtered;
    Property FilterOptions;
{$IFNDEF FPC}
    Property ObjectView Default False;
{$ENDIF}
    Property ReadOnly;
    Property AfterCancel;
    Property AfterClose;
    Property AfterDelete;
    Property AfterEdit;
    Property AfterInsert;
    Property AfterOpen;
    Property AfterPost;
    Property AfterScroll;
    Property BeforeCancel;
    Property BeforeClose;
    Property BeforeDelete;
    Property BeforeEdit;
    Property BeforeInsert;
    Property BeforeOpen;
    Property BeforePost;
    Property BeforeScroll;
    Property OnCalcFields;
    Property OnDeleteError;
    Property OnEditError;
    Property OnFilterRecord;
    Property OnNewRecord;
    Property OnPostError;
  End;


Procedure RegisterDatapacketReader(ADatapacketReaderClass : TRESTDWMemDataPacketReaderClass; AFormat : TRESTDWMemDataPacketFormat);

Implementation

Uses
{$IFDEF FPC}
 dbconst,
{$ELSE}
 DBConsts,
{$ENDIF}
 FmtBCD, strutils, uRESTDWStorageBin;

{$IFNDEF FPC}
Procedure RESTDWSetFieldValues(ADataSet : TDataSet; Const KeyFields : String; Const KeyValues : Variant);
Var
 L : TList;
 I : Integer;
Begin
 L := TList.Create;
 Try
 ADataSet.GetFieldList(L, KeyFields);
 If VarIsArray(KeyValues) Then
  For I := 0 To L.Count - 1 Do
  TField(L[I]).Value := KeyValues[I]
 Else If L.Count > 0 Then
  TField(L[0]).Value := KeyValues;
 Finally
 L.Free;
End;
End;

{$ENDIF}

Function RESTDWWordCount(Const S : String; Const Delimiters : TSysCharSet) : Integer;
Var
 I      : Integer;
 InWord : Boolean;
Begin
 Result := 0;
 InWord := False;
 For I := 1 To Length(S) Do
 If S[I] In Delimiters Then
  InWord := False
 Else If Not InWord Then
  Begin
   Inc(Result);
   InWord := True;
  End;
End;

Function RESTDWExtractDelimited(N : Integer; Const S : String; Const Delimiters : TSysCharSet) : String;
Var
 I,
 W,
 StartPos : Integer;
 InWord   : Boolean;
Begin
 Result := '';
 W := 0;
 InWord := False;
 StartPos := 0;
 For I := 1 To Length(S) + 1 Do
  Begin
   If (I > Length(S)) Or ((I <= Length(S)) And (S[I] In Delimiters)) Then
    Begin
     If InWord Then
      Begin
       Inc(W);
       If W = N Then
        Begin
         Result := Copy(S, StartPos, I - StartPos);
         Exit;
        End;
       InWord := False;
      End;
    End
   Else If Not InWord Then
    Begin
     StartPos := I;
     InWord := True;
    End;
  End;
End;


Const
 SDefaultIndex = 'DEFAULT_ORDER';
 SCustomIndex = 'CUSTOM_ORDER';
 Desc=' DESC';     //leading space is important
 LenDesc : integer = Length(Desc);
 Limiter=';';

Type
 TRESTDWMemDataPacketReaderRegistration = Record
  ReaderClass : TRESTDWMemDataPacketReaderClass;
  Format      : TRESTDWMemDataPacketFormat;
 End;

Var
 RegisteredDatapacketReaders : Array Of TRESTDWMemDataPacketReaderRegistration;

Procedure RegisterDatapacketReader(ADatapacketReaderClass : TRESTDWMemDataPacketReaderClass; AFormat : TRESTDWMemDataPacketFormat);

Begin
 setlength(RegisteredDatapacketReaders,length(RegisteredDatapacketReaders)+1);
 With RegisteredDatapacketReaders[length(RegisteredDatapacketReaders)-1] Do
  Begin
   Readerclass := ADatapacketReaderClass;
   Format      := AFormat;
  End;
End;

Function GetRegisterDatapacketReader(AStream : TStream; AFormat : TRESTDWMemDataPacketFormat; out ADataReaderClass : TRESTDWMemDataPacketReaderRegistration) : boolean;

Var
 i : integer;

Begin
 Result := False;
 For i := 0 To length(RegisteredDatapacketReaders)-1 Do
  If ((AFormat=dfAny) or (AFormat=RegisteredDatapacketReaders[i].Format)) Then
   Begin
    If (AStream=nil) or (RegisteredDatapacketReaders[i].ReaderClass.RecognizeStream(AStream)) Then
     Begin
      ADataReaderClass := RegisteredDatapacketReaders[i];
      Result := True;
      If (AStream <> nil) Then
       AStream.Seek(0,soFromBeginning);
      Break;
     End;
    AStream.Seek(0,soFromBeginning);
   End;
End;

Function DBCompareText(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;

Begin
 If [loCaseInsensitive,loPartialKey]=options Then
  Result := AnsiStrLIComp(pchar(subValue),pchar(aValue),length(pchar(subValue)))
 Else If [loPartialKey] = options Then
  Result := AnsiStrLComp(pchar(subValue),pchar(aValue),length(pchar(subValue)))
 Else If [loCaseInsensitive] = options Then
  Result := AnsiCompareText(pchar(subValue),pchar(aValue))
 Else
  Result := AnsiCompareStr(pchar(subValue),pchar(aValue));
End;

Function DBCompareWideText(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;

Begin
 If [loCaseInsensitive,loPartialKey]=options Then
  Result := WideCompareText(pwidechar(subValue),LeftStr(pwidechar(aValue), Length(pwidechar(subValue))))
 Else If [loPartialKey] = options Then
   Result := WideCompareStr(pwidechar(subValue),LeftStr(pwidechar(aValue), Length(pwidechar(subValue))))
  Else If [loCaseInsensitive] = options Then
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
 If PLargeInt(subValue)^ < PLargeInt(aValue)^ Then
  result := -1
 Else If PLargeInt(subValue)^  > PLargeInt(aValue)^ Then
  result := 1
 Else
  result := 0;
End;

Function DBCompareWord(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;

Begin
 Result := PWord(subValue)^-PWord(aValue)^;
End;

Function DBCompareQWord(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;

Begin
 // A simple subtraction doesn't work, since it could be that the result
 // doesn't fit into a LargeInt
 If PRESTDWQWord(subValue)^ < PRESTDWQWord(aValue)^ Then
  result := -1
 Else If PRESTDWQWord(subValue)^  > PRESTDWQWord(aValue)^ Then
  result := 1
 Else
  result := 0;
End;

Function DBCompareDouble(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 // A simple subtraction doesn't work, since it could be that the result
 // doesn't fit into a LargeInt
 If PDouble(subValue)^ < PDouble(aValue)^ Then
  result := -1
 Else If PDouble(subValue)^  > PDouble(aValue)^ Then
  result := 1
 Else
  result := 0;
End;

{$IFDEF DELPHI2010UP}
Function DBCompareSingle(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 If PSingle(subValue)^ < PSingle(aValue)^ Then
  Result := -1
 Else If PSingle(subValue)^ > PSingle(aValue)^ Then
  Result := 1
 Else
  Result := 0;
End;

Function DBCompareExtended(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 If PExtended(subValue)^ < PExtended(aValue)^ Then
  Result := -1
 Else If PExtended(subValue)^ > PExtended(aValue)^ Then
  Result := 1
 Else
  Result := 0;
End;
{$ENDIF}

Function DBCompareBCD(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 result:=BCDCompare(PBCD(subValue)^, PBCD(aValue)^);
End;

Function RESTDWCompareByte(A, B: Pointer; ASize: Integer): Integer;
Var I: Integer; PA, PB: PByte;
Begin
 PA := A;
 PB := B;
 For I := 0 To ASize - 1 Do
  Begin
   If PA^ < PB^ Then
    Begin
     Result := -1;
     Exit;
    End;
   If PA^ > PB^ Then
    Begin
     Result := 1;
     Exit;
    End;
   Inc(PA);
   Inc(PB);
  End;
 Result := 0;
End;

Function DBCompareBytes(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Begin
 Result := RESTDWCompareByte(subValue, aValue, size);
End;

Function DBCompareVarBytes(subValue, aValue: pointer; size: integer; options: TLocateOptions): LargeInt;
Var len1, len2: LongInt;
Begin
 len1 := PWord(subValue)^;
 len2 := PWord(aValue)^;
 subValue := Pointer(TRESTDWPtrInt(subValue) + SizeOf(Word));
 aValue := Pointer(TRESTDWPtrInt(aValue) + SizeOf(Word));
 If len1 > len2 Then
  Result := RESTDWCompareByte(subValue, aValue, len2)
 Else
  Result := RESTDWCompareByte(subValue, aValue, len1);
 If Result = 0 Then
  Result := len1 - len2;
End;

Procedure unSetFieldIsNull(NullMask : pbyte;x : longint); //inline;
Begin
 NullMask[x div 8] := (NullMask[x div 8]) and not (1 shl (x mod 8));
End;

Procedure SetFieldIsNull(NullMask : pbyte;x : longint); //inline;
Begin
 NullMask[x div 8] := (NullMask[x div 8]) or (1 shl (x mod 8));
End;

Function GetFieldIsNull(NullMask : pbyte;x : longint) : boolean; //inline;
Begin
 result := ord(NullMask[x div 8]) and (1 shl (x mod 8)) > 0
End;

Function IndexCompareRecords(Rec1,Rec2 : pointer; ADBCompareRecs : TRESTDWMemCompareStruct) : LargeInt;
Var IndexFieldNr : Integer;
  IsNull1, IsNull2 : boolean;
Begin
 For IndexFieldNr:=0 To length(ADBCompareRecs)-1 Do With ADBCompareRecs[IndexFieldNr] Do
  Begin
   IsNull1:=GetFieldIsNull(PByte(TRESTDWPtrInt(rec1)+NullBOff),FieldInd);
   IsNull2:=GetFieldIsNull(PByte(TRESTDWPtrInt(rec2)+NullBOff),FieldInd);
   If IsNull1 and IsNull2 Then
   Result := 0
   Else If IsNull1 Then
   Result := -1
   Else If IsNull2 Then
   Result := 1
   Else
   Result := CompareFunc(Pointer(TRESTDWPtrInt(Rec1)+Off), Pointer(TRESTDWPtrInt(Rec2)+Off), Size, Options);

   If Result <> 0 Then
    Begin
     If Desc Then
     Result := -Result;
     Break;
    End;
  End;
End;

{ TRESTDWCustomMemTable.TRESTDWMemTableIndex }

Destructor TRESTDWCustomMemTable.TRESTDWMemTableIndex.Destroy;
Begin
 ClearIndex;
 Inherited Destroy;
End;

Procedure TRESTDWCustomMemTable.TRESTDWMemTableIndex.Clearindex;
Begin
 FreeAndNil(FBufferIndex);
End;

Procedure TRESTDWCustomMemTable.TRESTDWMemTableIndex.SetIndexProperties;
Begin
 If not Assigned(FBufferIndex) Then
  Exit;
 FBufferIndex.IndNr:=Index;
 FBufferIndex.Name:=Name;
 FBufferIndex.FieldsName:=Fields;
 FBufferIndex.DescFields:=DescFields;
 FBufferIndex.CaseinsFields:=CaseInsFields;
 FBufferIndex.Options:=Options;
End;

Function TRESTDWCustomMemTable.TRESTDWMemTableIndex.MustBuild(aCurrent: TRESTDWMemTableIndex): Boolean;
Begin
 Result:=(FIndexType<>itDefault) and IsActiveIndex(aCurrent);
End;

Function TRESTDWCustomMemTable.TRESTDWMemTableIndex.IsActiveIndex(aCurrent: TRESTDWMemTableIndex): Boolean;
Begin
 Result:=(FIndexType<>itCustom) or (Self=aCurrent);
End;


{ TRESTDWCustomMemTable.TRESTDWMemTableIndexDefs }

Function TRESTDWCustomMemTable.TRESTDWMemTableIndexDefs.GetMemDatasetIndex(AIndex : Integer): TRESTDWMemTableIndex;
Begin
 Result:=Items[Aindex] as TRESTDWMemTableIndex;
End;

Function TRESTDWCustomMemTable.TRESTDWMemTableIndexDefs.GetBufferIndex(AIndex : Integer): TRESTDWMemInternalIndex;
Begin
 Result:=BufIndexdefs[AIndex].BufferIndex;
End;

Constructor TRESTDWCustomMemTable.TRESTDWMemTableIndexDefs.Create(aDataset: TDataset);
Begin
{$IFDEF FPC}
 Inherited Create(aDataset,aDataset,TRESTDWMemTableIndex);
{$ELSE}
 Inherited Create(aDataset);
{$ENDIF}
End;

Function TRESTDWCustomMemTable.TRESTDWMemTableIndexDefs.FindIndex(Const IndexName: string): TRESTDWMemTableIndex;

Var
 I: Integer;

Begin
 I:=IndexOf(IndexName);
 If I<>-1 Then
  Result:=BufIndexdefs[I]
 Else
  Result:=Nil;
End;

Function TRESTDWCustomMemTable.TRESTDWMemTableIndexDefs.AddMemTableIndexDef : TRESTDWMemTableIndex;
Begin
{$IFDEF FPC}
 Result:=Inherited AddIndexDef as TRESTDWMemTableIndex;
{$ELSE}
 Result:=TRESTDWMemTableIndex.Create(Self,'','',[]);
{$ENDIF}
End;

{ ---------------------------------------------------------------------
  TRESTDWCustomMemTable
 ---------------------------------------------------------------------}

Constructor TRESTDWCustomMemTable.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 FMaxIndexesCount:=2;
 FIndexes:=TRESTDWMemTableIndexDefs.Create(Self);
 FRuntimeIndexes:=TRESTDWMemTableIndexDefs.Create(Self);
 FAutoIncValue:=-1;
 SetLength(FUpdateBuffer,0);
 SetLength(FBlobBuffers,0);
 SetLength(FUpdateBlobBuffers,0);
 FParser := nil;
 FPacketRecords := 10;
{$IFDEF RESTDWLAZARUS}
 FDatabaseCharSet := csUndefined;
{$ENDIF}
End;

Procedure TRESTDWCustomMemTable.SetPacketRecords(aValue : integer);
Begin
 If (aValue = -1) or (aValue > 0) Then
  Begin
   If (IndexFieldNames<>'') and (aValue<>-1) Then
   DatabaseError(SInvPacketRecordsValueFieldNames)
   Else
   If UniDirectional and (aValue=-1) Then
   DatabaseError(SInvPacketRecordsValueUniDirectional)
   Else
   FPacketRecords := aValue
  End
 Else
  DatabaseError(SInvPacketRecordsValue);
End;

Destructor TRESTDWCustomMemTable.Destroy;

Begin
 FreeAndNil(FDataReference);
 FreeAndNil(FDeltaReference);
 If Active Then
  Close;
 SetLength(FUpdateBuffer,0);
 SetLength(FBlobBuffers,0);
 SetLength(FUpdateBlobBuffers,0);
 ClearIndexes;
 FreeAndNil(FRuntimeIndexes);
 FreeAndNil(FIndexes);
 Inherited destroy;
End;

Procedure TRESTDWCustomMemTable.FetchAll;
Begin
 Repeat
 Until (getnextpacket < FPacketRecords) or (FPacketRecords = -1);
End;

{
// Code to dump raw dataset data, including indexes information, useful for debugging
 Procedure DumpRawMem(const Data: pointer; ALength: TRESTDWPtrInt);
 Var
  b: integer;
  s1,s2: string;
 Begin
  s1 := '';
  s2 := '';
  For b := 0 to ALength-1 do
   Begin
    s1 := s1 + ' ' + hexStr(pbyte(Data)[b],2);
    If pchar(Data)[b] in ['a'..'z','A'..'Z','1'..'9',' '..'/',':'..'@'] then
    s2 := s2 + pchar(Data)[b]
    Else
    s2 := s2 + '.';
    If length(s2)=16 then
     Begin
      write('    ',s1,'    ');
      writeln(s2);
      s1 := '';
      s2 := '';
     End;
   End;
  write('    ',s1,'    ');
  writeln(s2);
 End;

 Procedure DumpRecord(Dataset: TRESTDWCustomMemTable; RecBuf: PRESTDWMemRecLinkItem; RawData: boolean = false);
 Var ptr: pointer;
   NullMask: pointer;
   FieldData: pointer;
   NullMaskSize: integer;
   i: integer;
 Begin
  If RawData then
   DumpRawMem(RecBuf,Dataset.RecordSize)
  Else
   Begin
    ptr := RecBuf;
    NullMask:= ptr + (sizeof(TRESTDWMemRecLinkItem)*Dataset.MaxIndexesCount);
    NullMaskSize := 1+(Dataset.Fields.Count-1) div 8;
    FieldData:= ptr + (sizeof(TRESTDWMemRecLinkItem)*Dataset.MaxIndexesCount) +NullMaskSize;
    write('record: $',hexstr(ptr),'  nullmask: $');
    For i := 0 to NullMaskSize-1 do
    write(hexStr(byte((NullMask+i)^),2));
    write('=');
    For i := 0 to NullMaskSize-1 do
    write(binStr(byte((NullMask+i)^),8));
    writeln('%');
    For i := 0 to Dataset.MaxIndexesCount-1 do
    writeln('  ','Index ',inttostr(i),' Prior rec: ' + hexstr(pointer((ptr+(i*2)*sizeof(ptr))^)) + ' Next rec: ' + hexstr(pointer((ptr+((i*2)+1)*sizeof(ptr))^)));
    DumpRawMem(FieldData,Dataset.RecordSize-((sizeof(TRESTDWMemRecLinkItem)*Dataset.MaxIndexesCount) +NullMaskSize));
   End;
 End;

 Procedure DumpDataset(AIndex: TRESTDWMemInternalIndex;RawData: boolean = false);
 Var RecBuf: PRESTDWMemRecLinkItem;
 Begin
  writeln('Dump records, order based on index ',AIndex.IndNr);
  writeln('Current record:',hexstr(AIndex.CurrentRecord));

  RecBuf:=(AIndex as TRESTDWMemDoubleLinkedIndex).FFirstRecBuf;
  While RecBuf<>(AIndex as TRESTDWMemDoubleLinkedIndex).FLastRecBuf do
   Begin
    DumpRecord(AIndex.FDataset,RecBuf,RawData);
    RecBuf:=RecBuf[(AIndex as TRESTDWMemDoubleLinkedIndex).IndNr].next;
   End;
 End;
}

Procedure TRESTDWCustomMemTable.BuildIndex(AIndex: TRESTDWMemInternalIndex);

Var PCurRecLinkItem : PRESTDWMemRecLinkItem;
  p,l,q           : PRESTDWMemRecLinkItem;
  i,k,psize,qsize : integer;
  myIdx,defIdx    : Integer;
  MergeAmount     : integer;
  PlaceQRec       : boolean;

  IndexFields     : TList;
  DescIndexFields : TList;
  CInsIndexFields : TList;

  Index0,
  DblLinkIndex    : TRESTDWMemDoubleLinkedIndex;

 Procedure PlaceNewRec(Var e: PRESTDWMemRecLinkItem; Var esize: integer);
 Begin
  If DblLinkIndex.FFirstRecBuf=nil Then
   Begin
    DblLinkIndex.FFirstRecBuf:=e;
    e[myIdx].prior:=nil;
    l:=e;
   End
  Else
   Begin
    l[myIdx].next:=e;
    e[myIdx].prior:=l;
    l:=e;
   End;
  e := e[myIdx].next;
  dec(esize);
 End;

Begin
 // Build the DBCompareStructure
 // One AS is enough, and makes debugging easier.
 DblLinkIndex:=(AIndex as TRESTDWMemDoubleLinkedIndex);
 Index0:=DefaultIndex.BufferIndex as TRESTDWMemDoubleLinkedIndex;
 myIdx:=DblLinkIndex.IndNr;
 defIdx:=Index0.IndNr;
 With DblLinkIndex Do
  Begin
   IndexFields := TList.Create;
   DescIndexFields := TList.Create;
   CInsIndexFields := TList.Create;
   Try
   GetFieldList(IndexFields,FieldsName);
   GetFieldList(DescIndexFields,DescFields);
   GetFieldList(CInsIndexFields,CaseinsFields);
   If IndexFields.Count=0 Then
    DatabaseErrorFmt(SNoIndexFieldNameGiven,[DblLinkIndex.Name],Self);
   ProcessFieldsToCompareStruct(IndexFields, DescIndexFields, CInsIndexFields, Options, [], DBCompareStruct);
   Finally
   CInsIndexFields.Free;
   DescIndexFields.Free;
   IndexFields.Free;
  End;
End;

 // This simply copies the index...
 PCurRecLinkItem:=Index0.FFirstRecBuf;
 PCurRecLinkItem[myIdx].next := PCurRecLinkItem[defIdx].next;
 PCurRecLinkItem[myIdx].prior := PCurRecLinkItem[defIdx].prior;

 If PCurRecLinkItem <> Index0.FLastRecBuf Then
  Begin
   While PCurRecLinkItem[defIdx].next<>Index0.FLastRecBuf Do
    Begin
     PCurRecLinkItem:=PCurRecLinkItem[defIdx].next;
 
     PCurRecLinkItem[myIdx].next := PCurRecLinkItem[defIdx].next;
     PCurRecLinkItem[myIdx].prior := PCurRecLinkItem[defIdx].prior;
    End;
  End
 Else
  // Empty dataset
  Exit;

 // Set FirstRecBuf and FCurrentRecBuf
 DblLinkIndex.FFirstRecBuf:=Index0.FFirstRecBuf;
 DblLinkIndex.FCurrentRecBuf:=DblLinkIndex.FFirstRecBuf;
 // Link in the FLastRecBuf that belongs to this index
 PCurRecLinkItem[myIdx].next:=DblLinkIndex.FLastRecBuf;
 DblLinkIndex.FLastRecBuf[myIdx].prior:=PCurRecLinkItem;

 // Mergesort. Used the algorithm as described here by Simon Tatham
 // http://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
 // The comments in the code are from this website.

 // In each pass, we are merging lists of size K into lists of size 2K.
 // (Initially K equals 1.)
 k:=1;

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
   inc(MergeAmount);

  //  * Point another temporary pointer, q, at the same place as p. Step q along
  //    the list by K places, or until the end of the list, whichever comes
  //    first. Let psize be the number of elements you managed to step q past.
   i:=0;
   While (i<k) and (q<>DblLinkIndex.FLastRecBuf) Do
    Begin
     inc(i);
     q := q[myIDx].next;
    End;
   psize :=i;

  //  * Let qsize equal K. Now we need to merge a list starting at p, of length
  //    psize, with a list starting at q of length at most qsize.
   qsize:=k;

  //  * So, as long as either the p-list is non-empty (psize > 0) or the q-list
  //    is non-empty (qsize > 0 and q points to something non-null):
   While (psize>0) or ((qsize>0) and (q <> DblLinkIndex.FLastRecBuf)) Do
    Begin
    //  * Choose which list to take the next element from. If either list
    //    is empty, we must choose from the other one. (By assumption, at
    //    least one is non-empty at this point.) If both lists are
    //    non-empty, compare the first element of each and choose the lower
    //    one. If the first elements compare equal, choose from the p-list.
    //    (This ensures that any two elements which compare equal are never
    //    swapped, so stability is guaranteed.)
     If (psize=0)  Then
     PlaceQRec := true
     Else If (qsize=0) or (q = DblLinkIndex.FLastRecBuf) Then
     PlaceQRec := False
     Else If IndexCompareRecords(p,q,DblLinkIndex.DBCompareStruct) <= 0 Then
     PlaceQRec := False
     Else
     PlaceQRec := True;
 
    //  * Remove that element, e, from the start of its list, by advancing
    //    p or q to the next element along, and decrementing psize or qsize.
    //  * Add e to the end of the list L we are building up.
     If PlaceQRec Then
     PlaceNewRec(q,qsize)
     Else
     PlaceNewRec(p,psize);
    End;

  //  * Now we have advanced p until it is where q started out, and we have
  //    advanced q until it is pointing at the next pair of length-K lists to
  //    merge. So set p to the value of q, and go back to the start of this loop.
   p:=q;
  End;

 // As soon as a pass like this is performed and only needs to do one merge, the
 // algorithm terminates, and the output list L is sorted. Otherwise, double the
 // value of K, and go back to the beginning.

 l[myIdx].next:=DblLinkIndex.FLastRecBuf;

 k:=k*2;

 Until MergeAmount = 1;
 DblLinkIndex.FLastRecBuf[myIdx].next:=DblLinkIndex.FFirstRecBuf;
 DblLinkIndex.FLastRecBuf[myIdx].prior:=l;
End;

Procedure TRESTDWCustomMemTable.BuildIndexes;

Var
 i: integer;

Begin
 For i:=0 To FIndexes.Count-1 Do
  If BufIndexDefs[i].MustBuild(FCurrentIndexDef) Then
   BuildIndex(BufIndexes[i]);
End;

Procedure TRESTDWCustomMemTable.ClearIndexes;

Var
 i:integer;

Begin
 CheckInactive;
 For I:=0 To FIndexes.Count-1 Do
  BufIndexDefs[i].Clearindex;
End;

Procedure TRESTDWCustomMemTable.RemoveRecordFromIndexes(Const ABookmark: TRESTDWMemBookmark);

Var
 i: integer;
 F : TRESTDWMemTableIndex;

Begin
 For i:=0 To FIndexes.Count-1 Do
  Begin
   F:=BufIndexDefs[i];
   If F.IsActiveIndex(FCurrentIndexDef) Then
   F.BufferIndex.RemoveRecordFromIndex(ABookmark);
  End;
End;

Function TRESTDWCustomMemTable.GetIndexDefs : TIndexDefs;
Begin
 If Active Then
  Result := FRuntimeIndexes
 Else
  Result := FIndexes;
End;

Procedure TRESTDWCustomMemTable.SetIndexDefs(Value : TIndexDefs);
Var
 I         : Integer;
 vIndexDef : TIndexDef;
Begin
 If Value = GetIndexDefs Then
  Exit;
 If Active Then
  Begin
   FRuntimeIndexes.Clear;
   For I := 0 To Value.Count - 1 Do
    Begin
     FRuntimeIndexes.Add(Value[I].Name,
                         Value[I].Fields,
                         Value[I].Options);
     vIndexDef:=FRuntimeIndexes[FRuntimeIndexes.Count-1];
     vIndexDef.DescFields:=Value[I].DescFields;
     vIndexDef.Expression:=Value[I].Expression;
     vIndexDef.Source:=Value[I].Source;
{$IFNDEF FPC}
     vIndexDef.GroupingLevel:=Value[I].GroupingLevel;
{$ENDIF}
    End;
   Exit;
  End;
 FIndexes.Clear;
 For I := 0 To Value.Count - 1 Do
  Begin
   If FIndexes.IndexOf(Value[I].Name) = -1 Then
    Begin
     vIndexDef                := FIndexes.AddMemTableIndexDef;
     vIndexDef.Name           := Value[I].Name;
     vIndexDef.Fields         := Value[I].Fields;
     vIndexDef.DescFields     := Value[I].DescFields;
     vIndexDef.Expression     := Value[I].Expression;
     vIndexDef.Options        := Value[I].Options;
     vIndexDef.Source         := Value[I].Source;
{$IFNDEF FPC}
     vIndexDef.GroupingLevel := Value[I].GroupingLevel;
{$ENDIF}
    End;
  End;
End;

Function TRESTDWCustomMemTable.GetCanModify: Boolean;
Begin
 Result:=not (UniDirectional or ReadOnly);
End;

Function TRESTDWCustomMemTable.BufferOffset: integer;
Begin
 // Returns the offset of data buffer in MemoryDataset record
 Result := sizeof(TRESTDWMemRecLinkItem) * FMaxIndexesCount;
End;

Function TRESTDWCustomMemTable.IntAllocRecordBuffer: TRecordBuffer;
Begin
 // Note: Only the internal buffers of TDataset provide bookmark information
 result := AllocMem(FRecordSize+BufferOffset);
End;

Function TRESTDWCustomMemTable.AllocRecordBuffer: TRecordBuffer;
Begin
 result := AllocMem(FRecordSize + BookmarkSize + CalcFieldsSize);
 // The records are initialised, or else the fields of an empty, just-opened dataset
 // are not null
 InitRecord(result);
End;

Procedure TRESTDWCustomMemTable.FreeRecordBuffer(Var Buffer: TRecordBuffer);
Begin
 ReAllocMem(Buffer,0);
End;

Procedure TRESTDWCustomMemTable.ClearCalcFields(Buffer: TRecordBuffer);
Begin
 If CalcFieldsSize > 0 Then
  FillChar((Buffer+RecordSize)^,CalcFieldsSize,0);
End;

Procedure TRESTDWCustomMemTable.InternalInitFieldDefs;
Begin
 If FileName<>'' Then
  Begin
   IntLoadFieldDefsFromFile;
   FreeAndNil(FDatasetReader);
   FreeAndNil(FFileStream);
  End;
End;

Procedure TRESTDWCustomMemTable.InitUserIndexes;

Var
 i : integer;

Begin
 For I:=0 To FIndexes.Count-1 Do
  If BufIndexDefs[i].IndexType=itNormal Then
    InternalCreateIndex(BufIndexDefs[i]);
End;

Procedure TRESTDWCustomMemTable.InternalOpen;

Var
 IndexNr : Integer;
 I       : Integer;

Begin
 If Assigned(FDatasetReader) or (FileName<>'') Then
  IntLoadFieldDefsFromFile;

 If (Fields.Count>0) and (FieldDefs.Count=0) Then
  Begin
   InitFieldDefsFromPersistentFields;
   BindFields(True);
  End;
 If (Fields.Count=0) or (FieldDefs.Count=0) Then
  DatabaseError(SErrNoDataset);

{$IFDEF FPC}
 NormalizeNumericFieldRanges;
 NormalizeFieldDisplayWidths;
{$ENDIF}

 FAutoIncField:=Nil;
 If FAutoIncValue>-1 Then
  Begin
   For I:=0 To Fields.Count-1 Do
    If Fields[I] is TAutoIncField Then
     Begin
      FAutoIncField:=TAutoIncField(Fields[I]);
      Break;
     End;
  End;

 InitDefaultIndexes;
 InitUserIndexes;

 FRuntimeIndexes.Clear;
 For IndexNr:=0 To FIndexes.Count-1 Do
  If BufIndexDefs[IndexNr].IndexType=itNormal Then
   Begin
    FRuntimeIndexes.Add(BufIndexDefs[IndexNr].Name,
                        BufIndexDefs[IndexNr].Fields,
                        BufIndexDefs[IndexNr].Options);
    With FRuntimeIndexes[FRuntimeIndexes.Count-1] Do
     Begin
      DescFields:=BufIndexDefs[IndexNr].DescFields;
      Expression:=BufIndexDefs[IndexNr].Expression;
      Source:=BufIndexDefs[IndexNr].Source;
{$IFNDEF FPC}
      GroupingLevel:=BufIndexDefs[IndexNr].GroupingLevel;
{$ENDIF}
     End;
   End;

 CalcRecordSize;

 FBRecordCount:=0;

 For IndexNr:=0 To FIndexes.Count-1 Do
  If Assigned(BufIndexDefs[IndexNr]) Then
   With BufIndexes[IndexNr] Do
    InitialiseSpareRecord(IntAllocRecordBuffer);

 FAllPacketsFetched:=False;
 FOpen:=True;

 ParseFilter(Filter);

 If Assigned(FDatasetReader) Then
  IntLoadRecordsFromFile;

 If FIndexName<>'' Then
  SetIndexName(FIndexName)
 Else If FIndexFieldNames<>'' Then
  BuildCustomIndex;
End;

Procedure TRESTDWCustomMemTable.DoBeforeClose;
Begin
 Inherited DoBeforeClose;
 If (FFileName<>'') Then
  SaveToFile(FFileName,dfDefault);
End;

Procedure TRESTDWCustomMemTable.RemoveUnnamedFields;

Var
 I : Integer;

Begin
 For I := Fields.Count - 1 Downto 0 Do
  If Trim(Fields[I].Name) = '' Then
   Fields[I].Free;
End;

Procedure TRESTDWCustomMemTable.InternalClose;

Var
 i,r  : integer;
 iGetResult : TGetResult;
 pc : TRecordBuffer;
 CurBufIndex: TRESTDWMemTableIndex;

Begin
 FOpen:=False;
 FReadFromFile:=False;
 FBRecordCount:=0;

 If (FIndexName<>'') and
    (FRuntimeIndexes.IndexOf(FIndexName)<>-1) Then
  FIndexName:='';
 FIndexFieldNames:='';
 FRuntimeIndexes.Clear;

 If (FIndexes.Count>0) Then
  With DefaultBufferIndex Do
   If IsInitialized Then
    Begin
     iGetResult:=ScrollFirst;
     While iGetResult = grOK Do
      Begin
       pc:=pointer(CurrentRecord);
       iGetResult:=ScrollForward;
       FreeRecordBuffer(pc);
      End;
    End;

 For r := 0 To FIndexes.Count-1 Do
  With FIndexes.BufIndexes[r] Do
   If IsInitialized Then
    Begin
     pc:=SpareRecord;
     ReleaseSpareRecord;
     FreeRecordBuffer(pc);
    End;

 If Length(FUpdateBuffer) > 0 Then
  Begin
   For r := 0 To length(FUpdateBuffer)-1 Do With FUpdateBuffer[r] Do
    Begin
     If assigned(OldValuesBuffer) Then
     FreeRecordBuffer(OldValuesBuffer);
     If (UpdateKind = ukDelete) and assigned(BookmarkData.BookmarkData) Then
     FreeRecordBuffer(TRecordBuffer(BookmarkData.BookmarkData));
    End;
  End;
 SetLength(FUpdateBuffer,0);

 For r := 0 To High(FBlobBuffers) Do
  FreeBlobBuffer(FBlobBuffers[r]);
 For r := 0 To High(FUpdateBlobBuffers) Do
  FreeBlobBuffer(FUpdateBlobBuffers[r]);
 SetLength(FBlobBuffers,0);
 SetLength(FUpdateBlobBuffers,0);
 SetLength(FFieldBufPositions,0);
 If FAutoIncValue>-1 Then
  FAutoIncValue:=1;
 If assigned(FParser) Then
  FreeAndNil(FParser);
 For I:=FIndexes.Count-1 Downto 0 Do
  Begin
   CurBufIndex:=BufIndexDefs[i];
   If (CurBufIndex.IndexType in [itDefault,itCustom]) or (CurBufIndex.DiscardOnClose) Then
    Begin
     If FCurrentIndexDef=CurBufIndex Then
     FCurrentIndexDef:=nil;
     CurBufIndex.Free;
    End
   Else
   FreeAndNil(CurBufIndex.FBufferIndex);
  End;
 RemoveUnnamedFields;
End;

Procedure TRESTDWCustomMemTable.InternalFirst;

Begin
 With CurrentIndexBuf Do
  // if FCurrentRecBuf = FLastRecBuf then the dataset is just opened and empty
  // in which case InternalFirst should do nothing (bug 7211)
  SetToFirstRecord;
End;

Procedure TRESTDWCustomMemTable.InternalLast;
Begin
 FetchAll;
 With CurrentIndexBuf Do
  SetToLastRecord;
End;

Procedure TRESTDWCustomMemTable.CopyFromDataset(DataSet: TDataSet; CopyData: Boolean);

Const
 UseStreams = [ftBlob,ftMemo,ftGraphic,ftWideMemo];

Var
 I  : Integer;
 F,F1,F2 : TField;
 L1,L2  : TList;
 N : String;
 OriginalPosition: TBookMark;
 S : TMemoryStream;

Begin
 Close;
 Fields.Clear;
 FieldDefs.Clear;
 For I:=0 To Dataset.FieldCount-1 Do
  Begin
   F:=Dataset.Fields[I];
   TFieldDef.Create(FieldDefs,F.FieldName,F.DataType,F.Size,F.Required,F.FieldNo);
  End;
 CreateDataset;
 L1:=Nil;
 L2:=Nil;
 S:=Nil;
 If CopyData Then
  Try
   L1:=TList.Create;
   L2:=TList.Create;
   Open;
   For I:=0 To FieldDefs.Count-1 Do
    Begin
     N:=FieldDefs[I].Name;
     F1:=FieldByName(N);
     F2:=DataSet.FieldByName(N);
     L1.Add(F1);
     L2.Add(F2);
     If (FieldDefs[I].DataType in UseStreams) and (S=Nil) Then
     S:=TMemoryStream.Create;
    End;
   DisableControls;
   Dataset.DisableControls;
   OriginalPosition:=Dataset.GetBookmark;
   Try
    Dataset.Open;
    Dataset.First;
    While not Dataset.EOF Do
     Begin
      Append;
      For I:=0 To L1.Count-1 Do
       Begin
        F1:=TField(L1[i]);
        F2:=TField(L2[I]);
        If Not F2.IsNull Then
        Case F1.DataType Of
          ftFixedChar,
          ftString   : F1.AsString:=F2.AsString;
          ftFixedWideChar,
          ftWideString : F1.AsWideString:=F2.AsWideString;
          ftBoolean  : F1.AsBoolean:=F2.AsBoolean;
          ftFloat    : F1.AsFloat:=F2.AsFloat;
          ftAutoInc,
          ftSmallInt,
          ftInteger  : F1.AsInteger:=F2.AsInteger;
          ftLargeInt : F1.AsLargeInt:=F2.AsLargeInt;
          ftDate     : F1.AsDateTime:=F2.AsDateTime;
          ftTime     : F1.AsDateTime:=F2.AsDateTime;
          ftTimestamp,
          ftDateTime : F1.AsDateTime:=F2.AsDateTime;
          ftCurrency : F1.AsCurrency:=F2.AsCurrency;
          ftBCD,
          ftFmtBCD   : F1.AsBCD:=F2.AsBCD;
        Else
        If (F1.DataType in UseStreams) Then
         Begin
          S.Clear;
          TBlobField(F2).SaveToStream(S);
          S.Position:=0;
          TBlobField(F1).LoadFromStream(S);
         End
        Else
         F1.AsString:=F2.AsString;
       End;
     End;
     Try
      Post;
     Except
      Cancel;
      Raise;
End;
     Dataset.Next;
     End;
   Finally
    DataSet.GotoBookmark(OriginalPosition); //Return to original record
    Dataset.EnableControls;
    EnableControls;
   End;
  Finally
   L2.Free;
   l1.Free;
   S.Free;
  End;
End;

{ TRESTDWMemInternalIndex }

Constructor TRESTDWMemInternalIndex.Create(Const ADataset: TRESTDWCustomMemTable);
Begin
 Inherited create;
 FDataset := ADataset;
End;

Function TRESTDWMemInternalIndex.BookmarkValid(Const ABookmark: PRESTDWMemBookmark): boolean;
Begin
 Result := assigned(ABookmark) and assigned(ABookmark^.BookmarkData);
End;

Function TRESTDWMemInternalIndex.CompareBookmarks(Const ABookmark1, ABookmark2: PRESTDWMemBookmark): integer;
Begin
 Result := 0;
End;

Function TRESTDWMemInternalIndex.SameBookmarks(Const ABookmark1, ABookmark2: PRESTDWMemBookmark): boolean;
Begin
 Result := Assigned(ABookmark1) and Assigned(ABookmark2) and (CompareBookmarks(ABookmark1, ABookmark2) = 0);
End;

Function TRESTDWMemInternalIndex.GetRecord(ABookmark: PRESTDWMemBookmark; GetMode: TGetMode): TGetResult;
Begin
 Result := grError;
End;

{ TRESTDWMemDoubleLinkedIndex }

Function TRESTDWMemDoubleLinkedIndex.GetBookmarkSize: integer;
Begin
 Result:=sizeof(TRESTDWMemBookmark);
End;

Function TRESTDWMemDoubleLinkedIndex.GetCurrentBuffer: Pointer;
Begin
 Result := Pointer(TRESTDWPtrInt(FCurrentRecBuf) + FDataset.BufferOffset);
End;

Function TRESTDWMemDoubleLinkedIndex.GetCurrentRecord: TRecordBuffer;
Begin
 Result := TRecordBuffer(FCurrentRecBuf);
End;

Function TRESTDWMemDoubleLinkedIndex.GetIsInitialized: boolean;
Begin
 Result := (FFirstRecBuf<>nil);
End;

Function TRESTDWMemDoubleLinkedIndex.GetSpareBuffer: TRecordBuffer;
Begin
 Result := Pointer(TRESTDWPtrInt(FLastRecBuf) + FDataset.BufferOffset);
End;

Function TRESTDWMemDoubleLinkedIndex.GetSpareRecord: TRecordBuffer;
Begin
 Result := TRecordBuffer(FLastRecBuf);
End;

Function TRESTDWMemDoubleLinkedIndex.ScrollBackward: TGetResult;
Begin
 If not assigned(FCurrentRecBuf[IndNr].prior) Then
  Begin
   Result := grBOF;
  End
 Else
  Begin
   Result := grOK;
   FCurrentRecBuf := FCurrentRecBuf[IndNr].prior;
  End;
End;

Function TRESTDWMemDoubleLinkedIndex.ScrollForward: TGetResult;
Begin
 If (FCurrentRecBuf = FLastRecBuf) or // just opened
   (FCurrentRecBuf[IndNr].next = FLastRecBuf) Then
  result := grEOF
 Else
  Begin
   FCurrentRecBuf := FCurrentRecBuf[IndNr].next;
   Result := grOK;
  End;
End;

Function TRESTDWMemDoubleLinkedIndex.GetCurrent: TGetResult;
Begin
 If FFirstRecBuf = FLastRecBuf Then
  Result := grError
 Else
  Begin
   Result := grOK;
   If FCurrentRecBuf = FLastRecBuf Then
   FCurrentRecBuf:=FLastRecBuf[IndNr].prior;
  End;
End;

Function TRESTDWMemDoubleLinkedIndex.ScrollFirst: TGetResult;
Begin
 FCurrentRecBuf:=FFirstRecBuf;
 If (FCurrentRecBuf = FLastRecBuf) Then
  result := grEOF
 Else
  result := grOK;
End;

Procedure TRESTDWMemDoubleLinkedIndex.ScrollLast;
Begin
 FCurrentRecBuf:=FLastRecBuf;
End;

Function TRESTDWMemDoubleLinkedIndex.GetRecord(ABookmark: PRESTDWMemBookmark; GetMode: TGetMode): TGetResult;
Var ARecord : PRESTDWMemRecLinkItem;
Begin
 Result := grOK;
 Case GetMode Of
  gmPrior:
   Begin
    If assigned(ABookmark^.BookmarkData) Then
    ARecord := ABookmark^.BookmarkData[IndNr].prior
    Else
    ARecord := nil;
    If not assigned(ARecord) Then
    Result := grBOF;
   End;
  gmNext:
   Begin
    If assigned(ABookmark^.BookmarkData) Then
    ARecord := ABookmark^.BookmarkData[IndNr].next
    Else
    ARecord := FFirstRecBuf;
   End;
  Else
   Result := grError;
End;

 If ARecord = FLastRecBuf Then
  Result := grEOF;
 // store into BookmarkData pointer to prior/next record
 ABookmark^.BookmarkData:=ARecord;
End;

Procedure TRESTDWMemDoubleLinkedIndex.SetToFirstRecord;
Begin
 FLastRecBuf[IndNr].next:=FFirstRecBuf;
 FCurrentRecBuf := FLastRecBuf;
End;

Procedure TRESTDWMemDoubleLinkedIndex.SetToLastRecord;
Begin
 If FLastRecBuf <> FFirstRecBuf Then
  FCurrentRecBuf := FLastRecBuf;
End;

Procedure TRESTDWMemDoubleLinkedIndex.StoreCurrentRecord;
Begin
 FStoredRecBuf:=FCurrentRecBuf;
End;

Procedure TRESTDWMemDoubleLinkedIndex.RestoreCurrentRecord;
Begin
 FCurrentRecBuf:=FStoredRecBuf;
End;

Procedure TRESTDWMemDoubleLinkedIndex.DoScrollForward;
Begin
 FCurrentRecBuf := FCurrentRecBuf[IndNr].next;
End;

Procedure TRESTDWMemDoubleLinkedIndex.StoreCurrentRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark);
Begin
 ABookmark^.BookmarkData:=FCurrentRecBuf;
End;

Procedure TRESTDWMemDoubleLinkedIndex.StoreSpareRecIntoBookmark(
 Const ABookmark: PRESTDWMemBookmark);
Begin
 ABookmark^.BookmarkData:=FLastRecBuf;
End;

Procedure TRESTDWMemDoubleLinkedIndex.GotoBookmark(Const ABookmark : PRESTDWMemBookmark);
Begin
 FCurrentRecBuf := ABookmark^.BookmarkData;
End;

Function TRESTDWMemDoubleLinkedIndex.CompareBookmarks(Const ABookmark1,ABookmark2: PRESTDWMemBookmark): integer;
Var ARecord1, ARecord2 : PRESTDWMemRecLinkItem;
Begin
 // valid bookmarks expected
 // estimate result using memory addresses of records
 Result := ABookmark1^.BookmarkData - ABookmark2^.BookmarkData;
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
 While assigned(ARecord2) and (ARecord2 <> ARecord1) and (ARecord2 <> FFirstRecBuf) Do
  ARecord2 := ARecord2[IndNr].prior;
 // if we found lower bookmark as first, then estimated position is correct
 If ARecord1 <> ARecord2 Then
  Result := -Result;
End;

Function TRESTDWMemDoubleLinkedIndex.SameBookmarks(Const ABookmark1, ABookmark2: PRESTDWMemBookmark): boolean;
Begin
 Result := Assigned(ABookmark1) and Assigned(ABookmark2) and (ABookmark1^.BookmarkData = ABookmark2^.BookmarkData);
End;

Procedure TRESTDWMemDoubleLinkedIndex.InitialiseIndex;
Begin
 // Do nothing
End;

Function TRESTDWMemDoubleLinkedIndex.CanScrollForward: Boolean;
Begin
 If (FCurrentRecBuf[IndNr].next = FLastRecBuf) Then
  Result := False
 Else
  Result := True;
End;

Procedure TRESTDWMemDoubleLinkedIndex.InitialiseSpareRecord(Const ASpareRecord : TRecordBuffer);
Begin
 FFirstRecBuf := pointer(ASpareRecord);
 FLastRecBuf := FFirstRecBuf;
 FLastRecBuf[IndNr].prior:=nil;
 FLastRecBuf[IndNr].next:=FLastRecBuf;
 FCurrentRecBuf := FLastRecBuf;
End;

Procedure TRESTDWMemDoubleLinkedIndex.ReleaseSpareRecord;
Begin
 FFirstRecBuf:= nil;
End;

Function TRESTDWMemDoubleLinkedIndex.GetRecNo: Longint;
Var ARecord : PRESTDWMemRecLinkItem;
Begin
 ARecord := FCurrentRecBuf;
 Result := 1;
 While ARecord <> FFirstRecBuf Do
  Begin
   inc(Result);
   ARecord := ARecord[IndNr].prior;
  End;
End;

Procedure TRESTDWMemDoubleLinkedIndex.SetRecNo(ARecNo: Longint);
Var ARecord : PRESTDWMemRecLinkItem;
Begin
 ARecord := FFirstRecBuf;
 While (ARecNo > 1) and (ARecord <> FLastRecBuf) Do
  Begin
   dec(ARecNo);
   ARecord := ARecord[IndNr].next;
  End;
 FCurrentRecBuf := ARecord;
End;

Procedure TRESTDWMemDoubleLinkedIndex.BeginUpdate;
Begin
 If FCurrentRecBuf = FLastRecBuf Then
  FCursOnFirstRec := True
 Else
  FCursOnFirstRec := False;
End;

Procedure TRESTDWMemDoubleLinkedIndex.AddRecord;
Var ARecord: TRecordBuffer;
Begin
 ARecord := FDataset.IntAllocRecordBuffer;
 FLastRecBuf[IndNr].next := pointer(ARecord);
 FLastRecBuf[IndNr].next[IndNr].prior := FLastRecBuf;

 FLastRecBuf := FLastRecBuf[IndNr].next;
End;

Procedure TRESTDWMemDoubleLinkedIndex.InsertRecordBeforeCurrentRecord(Const ARecord: TRecordBuffer);
Var ANewRecord : PRESTDWMemRecLinkItem;
Begin
 ANewRecord:=PRESTDWMemRecLinkItem(ARecord);
 ANewRecord[IndNr].prior:=FCurrentRecBuf[IndNr].prior;
 ANewRecord[IndNr].Next:=FCurrentRecBuf;

 If FCurrentRecBuf=FFirstRecBuf Then
  Begin
   FFirstRecBuf:=ANewRecord;
   ANewRecord[IndNr].prior:=nil;
  End
 Else
  ANewRecord[IndNr].Prior[IndNr].next:=ANewRecord;
 ANewRecord[IndNr].next[IndNr].prior:=ANewRecord;
End;

Procedure TRESTDWMemDoubleLinkedIndex.RemoveRecordFromIndex(Const ABookmark : TRESTDWMemBookmark);
Var ARecord : PRESTDWMemRecLinkItem;
Begin
 ARecord := ABookmark.BookmarkData;
 If ARecord = FCurrentRecBuf Then
  DoScrollForward;
 If ARecord <> FFirstRecBuf Then
  ARecord[IndNr].prior[IndNr].next := ARecord[IndNr].next
 Else
  Begin
   FFirstRecBuf := ARecord[IndNr].next;
   FLastRecBuf[IndNr].next := FFirstRecBuf;
  End;
 ARecord[IndNr].next[IndNr].prior := ARecord[IndNr].prior;
End;

Procedure TRESTDWMemDoubleLinkedIndex.OrderCurrentRecord;
Var ARecord: PRESTDWMemRecLinkItem;
  ABookmark: TRESTDWMemBookmark;
Begin
 // all records except current are already sorted
 // check prior records
 ARecord := FCurrentRecBuf;
 Repeat
  ARecord := ARecord[IndNr].prior;
 Until not assigned(ARecord) or (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) <= 0);
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
   Until (ARecord=FLastRecBuf) or (IndexCompareRecords(ARecord, FCurrentRecBuf, DBCompareStruct) >= 0);
   If ARecord = FCurrentRecBuf[IndNr].next Then
    Exit; // current record is on proper position
  End;
 StoreCurrentRecIntoBookmark(@ABookmark);
 RemoveRecordFromIndex(ABookmark);
 FCurrentRecBuf := ARecord;
 InsertRecordBeforeCurrentRecord(TRecordBuffer(ABookmark.BookmarkData));
 GotoBookmark(@ABookmark);
End;

Procedure TRESTDWMemDoubleLinkedIndex.EndUpdate;
Begin
 FLastRecBuf[IndNr].next := FFirstRecBuf;
 If FCursOnFirstRec Then
  FCurrentRecBuf:=FLastRecBuf;
End;

Procedure TRESTDWCustomMemTable.CurrentRecordToBuffer(Buffer: TRecordBuffer);
Var ABookMark : PRESTDWMemBookmark;
Begin
 With CurrentIndexBuf Do
  Begin
   move(CurrentBuffer^,buffer^,FRecordSize);
   ABookMark:=PRESTDWMemBookmark(Buffer + FRecordSize);
   ABookmark^.BookmarkFlag:=bfCurrent;
   StoreCurrentRecIntoBookmark(ABookMark);
  End;

 GetCalcFields(Buffer);
End;

Procedure TRESTDWCustomMemTable.SetBufUniDirectional(Const AValue: boolean);
Begin
 CheckInactive;
 If (AValue<>IsUniDirectional) Then
  Begin
   SetUniDirectional(AValue);
   ClearIndexes;
   FPacketRecords := 1; // temporary
  End;
End;

Function TRESTDWCustomMemTable.DefaultIndex: TRESTDWMemTableIndex;
Begin
 Result:=FDefaultIndex;
 If Result=Nil Then
  Result:=FIndexes.FindIndex(SDefaultIndex);
End;

Function TRESTDWCustomMemTable.DefaultBufferIndex: TRESTDWMemInternalIndex;
Begin
 If DefaultIndex <> Nil Then
  Result:=DefaultIndex.BufferIndex
 Else
  Result:=Nil;
End;

Procedure TRESTDWCustomMemTable.SetReadOnly(AValue: Boolean);
Begin
 FReadOnly:=AValue;
End;

Function TRESTDWCustomMemTable.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;

Var Acceptable : Boolean;
  SavedState : TDataSetState;

Begin
 Result := grOK;
 With CurrentIndexBuf Do
  Repeat
  Acceptable := True;
  Case GetMode Of
   gmPrior : Result := ScrollBackward;
   gmCurrent : Result := GetCurrent;
   gmNext : Begin
        If not CanScrollForward and (getnextpacket = 0) Then
         Result := grEOF
        Else
         Begin
          Result := grOK;
          DoScrollForward;
         End;
End;
  End;

  If Result = grOK Then
   Begin
    CurrentRecordToBuffer(Buffer);

    If Filtered Then
     Begin
      FFilterBuffer := Buffer;
      SavedState := SetTempState(dsFilter);
      DoFilterRecord(Acceptable);
      If (GetMode = gmCurrent) and not Acceptable Then
       Begin
        Acceptable := True;
        Result := grError;
       End;
      RestoreState(SavedState);
     End;
   End
  Else If (Result = grError) and DoCheck Then
   DatabaseError('No record');
  Until Acceptable;
End;

Function TRESTDWCustomMemTable.GetActiveRecordUpdateBuffer : boolean;

Var ABookmark : TRESTDWMemBookmark;

Begin
 GetBookmarkData(TRecordBuffer(ActiveBuffer),@ABookmark);
 result := GetRecordUpdateBufferCached(ABookmark);
End;

Function TRESTDWCustomMemTable.GetCurrentIndexBuf: TRESTDWMemInternalIndex;
Begin
 If Assigned(FCurrentIndexDef) Then
  Result:=FCurrentIndexDef.BufferIndex
 Else
  Result:=Nil;
End;

Function TRESTDWCustomMemTable.GetBufIndex(Aindex : Integer): TRESTDWMemInternalIndex;
Begin
 Result:=FIndexes.BufIndexes[AIndex]
End;

Function TRESTDWCustomMemTable.GetBufIndexDef(Aindex : Integer): TRESTDWMemTableIndex;
Begin
 Result:=FIndexes.BufIndexdefs[AIndex]
End;

Procedure TRESTDWCustomMemTable.ProcessFieldsToCompareStruct(Const AFields, ADescFields, ACInsFields: TList;
   Const AIndexOptions: TIndexOptions; Const ALocateOptions: TLocateOptions; out ACompareStruct: TRESTDWMemCompareStruct);
Var i: integer;
  AField: TField;
  ACompareRec: TRESTDWMemCompareRec;
Begin
 SetLength(ACompareStruct, AFields.Count);
 For i:=0 To high(ACompareStruct) Do
  Begin
   AField := TField(AFields[i]);

   Case AField.DataType Of
   ftString, ftFixedChar, ftGuid:
    ACompareRec.CompareFunc := @DBCompareText;
   ftWideString, ftFixedWideChar:
    ACompareRec.CompareFunc := @DBCompareWideText;
   ftSmallint:
    ACompareRec.CompareFunc := @DBCompareSmallInt;
   ftInteger, ftAutoInc:
    ACompareRec.CompareFunc := @DBCompareInt;
   ftLargeint, ftBCD:
    ACompareRec.CompareFunc := @DBCompareLargeInt;
   ftWord:
    ACompareRec.CompareFunc := @DBCompareWord;
   ftBoolean:
    ACompareRec.CompareFunc := @DBCompareByte;
   ftDate, ftTime, ftDateTime,
   ftFloat, ftCurrency:
    ACompareRec.CompareFunc := @DBCompareDouble;
{$IFDEF DELPHI2010UP}
   ftSingle:
    ACompareRec.CompareFunc := @DBCompareSingle;
   ftExtended:
    ACompareRec.CompareFunc := @DBCompareExtended;
{$ENDIF}
   ftFmtBCD:
    ACompareRec.CompareFunc := @DBCompareBCD;
   ftVarBytes:
    ACompareRec.CompareFunc := @DBCompareVarBytes;
   ftBytes:
    ACompareRec.CompareFunc := @DBCompareBytes;
   Else
   DatabaseErrorFmt(SErrIndexBasedOnInvField, [AField.FieldName,Fieldtypenames[AField.DataType]]);
  End;

  ACompareRec.Off:=BufferOffset + FFieldBufPositions[AField.FieldNo-1];
  ACompareRec.NullBOff:=BufferOffset;

  ACompareRec.FieldInd:=AField.FieldNo-1;
  ACompareRec.Size:=GetFieldSize(FieldDefs[ACompareRec.FieldInd]);

  ACompareRec.Desc := ixDescending in AIndexOptions;
  If assigned(ADescFields) Then
   ACompareRec.Desc := ACompareRec.Desc or (ADescFields.IndexOf(AField)>-1);

  ACompareRec.Options := ALocateOptions;
  If (ixCaseInsensitive in AIndexOptions) or
     (assigned(ACInsFields) and (ACInsFields.IndexOf(AField)>-1)) Then
   ACompareRec.Options := ACompareRec.Options + [loCaseInsensitive];

  ACompareStruct[i] := ACompareRec;
End;
End;


Procedure TRESTDWCustomMemTable.InitDefaultIndexes;

{
 This procedure makes sure there are 2 default indexes:
 DEFAULT_ORDER, which is simply the order in which the server records arrived.
 CUSTOM_ORDER, which is an internal index to accomodate the 'IndexFieldNames' property.
}

Var
 FD,FC : TRESTDWMemTableIndex;

Begin
 // Default index
 FD:=FIndexes.FindIndex(SDefaultIndex);
 If (FD=Nil) Then
  Begin
   FD:=InternalAddIndex(SDefaultIndex,'',[],'','');
   FD.IndexType:=itDefault;
   FD.FDiscardOnClose:=True;
  End
// Not sure about this. For the moment we leave it in comment
{  else if FD.BufferIndex=Nil then
  InternalCreateIndex(FD)}
  ;

 FCurrentIndexDef:=FD;
 // Custom index
 If not IsUniDirectional Then
  Begin
   FC:=Findexes.FindIndex(SCustomIndex);
   If (FC=Nil) Then
    Begin
     FC:=InternalAddIndex(SCustomIndex,'',[],'','');
     FC.IndexType:=itCustom;
     FC.FDiscardOnClose:=True;
    End
  // Not sure about this. For the moment we leave it in comment
{    else if FD.BufferIndex=Nil then
   InternalCreateIndex(FD)}
   ;
  End;
 BookmarkSize:=CurrentIndexBuf.BookmarkSize;
End;

Procedure TRESTDWCustomMemTable.AddIndex(Const AName, AFields : string; AOptions : TIndexOptions; Const ADescFields: string = '';
 Const ACaseInsFields: string = '');

Var
 F : TRESTDWMemTableIndex;
 D : TIndexDef;
 I : Integer;

Begin
 CheckBiDirectional;
 If (AFields='') Then
  DatabaseError(SNoIndexFieldNameGiven,Self);
 If Active Then
  Begin
   I:=FRuntimeIndexes.IndexOf(AName);
   If I=-1 Then
    Begin
     FRuntimeIndexes.Add(AName,AFields,AOptions);
     D:=FRuntimeIndexes[FRuntimeIndexes.Count-1];
    End
   Else
    D:=FRuntimeIndexes[I];
   D.Name:=AName;
   D.Fields:=AFields;
   D.Options:=AOptions;
   D.DescFields:=ADescFields;
   Exit;
  End;
 // If not all packets are fetched, you can not sort properly.
 FPacketRecords:=-1;
 F:=InternalAddIndex(AName,AFields,AOptions,ADescFields,ACaseInsFields);
 F.FDiscardOnClose:=False;
End;

Function TRESTDWCustomMemTable.InternalAddIndex(Const AName, AFields : string; AOptions : TIndexOptions; Const ADescFields: string;
                     Const ACaseInsFields: string) : TRESTDWMemTableIndex;

Var
 F : TRESTDWMemTableIndex;

Begin
 F:=FIndexes.AddMemTableIndexDef;
 F.Name:=AName;
 F.Fields:=AFields;
 F.Options:=AOptions;
 F.DescFields:=ADescFields;
 F.CaseInsFields:=ACaseInsFields;
 InternalCreateIndex(F);
 Result:=F;
End;

Procedure TRESTDWCustomMemTable.InternalCreateIndex(F : TRESTDWMemTableIndex);

Var
 B : TRESTDWMemInternalIndex;
Begin
 If Active and not Refreshing Then
  FetchAll;
 If IsUniDirectional Then
  B:=TRESTDWMemUniDirectionalIndex.Create(self)
 Else
  B:=TRESTDWMemDoubleLinkedIndex.Create(self);
 F.FBufferIndex:=B;
 With B Do
  Begin
   InitialiseIndex;
   F.SetIndexProperties;
  End;
 If Active  Then
  Begin
   If not Refreshing Then
   B.InitialiseSpareRecord(IntAllocRecordBuffer);
   If (F.Fields<>'') Then
   BuildIndex(B);
  End
 Else
  If (FIndexes.Count+2>FMaxIndexesCount) Then
   FMaxIndexesCount:=FIndexes.Count+2; // Custom+Default order
End;

Class Function TRESTDWCustomMemTable.DefaultReadFileFormat: TRESTDWMemDataPacketFormat;
Begin
 Result:=dfAny;
End;

Class Function TRESTDWCustomMemTable.DefaultWriteFileFormat: TRESTDWMemDataPacketFormat;
Begin
 Result:=dfBinary;
End;

Class Function TRESTDWCustomMemTable.DefaultPacketClass: TRESTDWMemDataPacketReaderClass;
Begin
 Result:=TRESTDWTBinaryDatapacketReader;
End;

Function TRESTDWCustomMemTable.CreateDefaultPacketReader(aStream : TStream): TRESTDWMemDataPacketReader;
Begin
 Result:=DefaultPacketClass.Create(Self,aStream);
End;


Procedure TRESTDWCustomMemTable.SetIndexFieldNames(Const AValue: String);

Begin
 FIndexFieldNames:=AValue;
 If (AValue='') Then
  Begin
   FCurrentIndexDef:=FIndexes.FindIndex(SDefaultIndex);
   Exit;
  End;
 If Active Then
  BuildCustomIndex;
End;

Procedure TRESTDWCustomMemTable.BuildCustomIndex;

Var
 i, p: integer;
 s: string;
 SortFields, DescFields: string;
 F : TRESTDWMemTableIndex;

Begin
 F:=FIndexes.FindIndex(SCustomIndex);
 If (F=Nil) Then
  InitDefaultIndexes;
 F:=FIndexes.FindIndex(SCustomIndex);
 SortFields := '';
 DescFields := '';
 For i := 1 To RESTDWWordCount(FIndexFieldNames, [Limiter]) Do
  Begin
   s := RESTDWExtractDelimited(i, FIndexFieldNames, [Limiter]);
   p := Pos(Desc, s);
   If p>0 Then
    Begin
     system.Delete(s, p, LenDesc);
     DescFields := DescFields + Limiter + s;
    End;
   SortFields := SortFields + Limiter + s;
  End;
 If (Length(SortFields)>0) and (SortFields[1]=Limiter) Then
  system.Delete(SortFields,1,1);
 If (Length(DescFields)>0) and (DescFields[1]=Limiter) Then
  system.Delete(DescFields,1,1);
 F.Fields:=SortFields;
 F.Options:=[];
 F.DescFields:=DescFields;
 FCurrentIndexDef:=F;
 F.SetIndexProperties;
 If Active Then
  Begin
   FetchAll;
   BuildIndex(F.BufferIndex);
   Resync([rmCenter]);
  End;
 FPacketRecords:=-1;
End;

Procedure TRESTDWCustomMemTable.SetIndexName(AValue: String);

Var
 F : TRESTDWMemTableIndex;
 C : TRESTDWMemTableIndex;
 D : TIndexDef;
 B : TRESTDWMemDoubleLinkedIndex;
 N : String;
 I : Integer;

Begin
 N:=AValue;
 If (N='') Then
  N:=SDefaultIndex;
 F:=FIndexes.FindIndex(N);
 D:=Nil;
 If (F=Nil) and Active and (AValue<>'') Then
  Begin
   I:=FRuntimeIndexes.IndexOf(N);
   If I<>-1 Then
    D:=FRuntimeIndexes[I];
  End;
 If (F=Nil) and (D=Nil) and (AValue<>'') and not (csLoading in ComponentState) Then
  DatabaseErrorFmt(SIndexNotFound,[AValue],Self);
 FIndexName:=AValue;
 If Assigned(D) Then
  Begin
   C:=FIndexes.FindIndex(SCustomIndex);
   If C=Nil Then
    Begin
     InitDefaultIndexes;
     C:=FIndexes.FindIndex(SCustomIndex);
    End;
   C.Fields:=D.Fields;
   C.Options:=D.Options;
   C.DescFields:=D.DescFields;
   C.SetIndexProperties;
   FCurrentIndexDef:=C;
   FetchAll;
   BuildIndex(C.BufferIndex);
   Resync([rmCenter]);
   Exit;
  End;
 If Assigned(F) Then
  Begin
   If Assigned(F.BufferIndex) Then
    Begin
     B:=TRESTDWMemDoubleLinkedIndex(F.BufferIndex);
     If Assigned(CurrentIndexBuf) and
        (CurrentIndexBuf is TRESTDWMemDoubleLinkedIndex) Then
      B.FCurrentRecBuf:=TRESTDWMemDoubleLinkedIndex(CurrentIndexBuf).FCurrentRecBuf;
    End;
   FCurrentIndexDef:=F;
   If Active Then
    Resync([rmCenter]);
  End
 Else
  FCurrentIndexDef:=Nil;
End;

Procedure TRESTDWCustomMemTable.SetMaxIndexesCount(Const AValue: Integer);
Begin
 CheckInactive;
 If AValue > 1 Then
  FMaxIndexesCount:=AValue
 Else
  DatabaseError(SMinIndexes,Self);
End;

Procedure TRESTDWCustomMemTable.InternalSetToRecord(Buffer: TRecordBuffer);
Begin
 CurrentIndexBuf.GotoBookmark(PRESTDWMemBookmark(Buffer+FRecordSize));
End;

Procedure TRESTDWCustomMemTable.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
Begin
 PRESTDWMemBookmark(Buffer + FRecordSize)^ := PRESTDWMemBookmark(Data)^;
End;

Procedure TRESTDWCustomMemTable.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
Begin
 PRESTDWMemBookmark(Buffer + FRecordSize)^.BookmarkFlag := Value;
End;

Procedure TRESTDWCustomMemTable.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
Begin
 PRESTDWMemBookmark(Data)^ := PRESTDWMemBookmark(Buffer + FRecordSize)^;
End;

Function TRESTDWCustomMemTable.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
Begin
 Result := PRESTDWMemBookmark(Buffer + FRecordSize)^.BookmarkFlag;
End;

Procedure TRESTDWCustomMemTable.InternalGotoBookmark(ABookmark: Pointer);
Begin
 // note that ABookMark should be a PRESTDWMemBookmark. But this way it can also be
 // a pointer to a TRESTDWMemRecLinkItem
 CurrentIndexBuf.GotoBookmark(ABookmark);
End;

Function TRESTDWCustomMemTable.getnextpacket : integer;

Var i : integer;
  pb : TRecordBuffer;
  T : TRESTDWMemInternalIndex;

Begin
 If FAllPacketsFetched Then
  Begin
   result := 0;
   Exit;
  End;
 T:=CurrentIndexBuf;
 T.BeginUpdate;

 i := 0;
 pb := DefaultBufferIndex.SpareBuffer;
 While ((i < FPacketRecords) or (FPacketRecords = -1)) and (LoadBuffer(pb) = grOk) Do
  Begin
   With DefaultBufferIndex Do
    Begin
     AddRecord;
     pb := SpareBuffer;
    End;
   inc(i);
  End;

 T.EndUpdate;
 FBRecordCount := FBRecordCount + i;
 result := i;
End;

Function TRESTDWCustomMemTable.GetFieldSize(FieldDef : TFieldDef) : longint;

Begin
 Case FieldDef.DataType Of
  ftUnknown    : result := 0;
  ftString,
   ftGuid,
   ftFixedChar:
{$IFDEF FPC}
    result := FieldDef.Size*FieldDef.CharSize + 1;
{$ELSE}
    result := FieldDef.Size*SizeOf(AnsiChar) + 1;
{$ENDIF}
  ftFixedWideChar,
   ftWideString:
{$IFDEF FPC}
    result := (FieldDef.Size + 1)*FieldDef.CharSize;
{$ELSE}
    result := (FieldDef.Size + 1)*SizeOf(WideChar);
{$ENDIF}
  ftSmallint,
   ftInteger,
   ftAutoInc,
   ftword     : result := sizeof(longint);
  ftBoolean    : result := sizeof(wordbool);
  ftBCD        : result := sizeof(currency);
  ftFmtBCD     : result := sizeof(TBCD);
  ftFloat,
   ftCurrency : result := sizeof(double);
  ftLargeInt   : result := sizeof(largeint);
{$IFDEF DELPHI2010UP}
  ftLongWord   : result := sizeof(Cardinal);
  ftShortint   : result := sizeof(ShortInt);
  ftByte       : result := sizeof(Byte);
  ftSingle     : result := sizeof(Single);
  ftExtended   : result := sizeof(Extended);
{$ENDIF}
  ftTime,
   ftDate,
   ftDateTime : result := sizeof(TDateTime);
  ftTimeStamp :
{$IFDEF FPC}
    result := sizeof(Double);
{$ELSE}
    result := sizeof(TSQLTimeStamp);
{$ENDIF}
  ftBytes      : result := FieldDef.Size;
  ftVarBytes   : result := FieldDef.Size + 2;
  ftVariant    : result := sizeof(variant);
  ftBlob,
   ftMemo,
   ftGraphic,
   ftFmtMemo,
   ftParadoxOle,
   ftDBaseOle,
   ftTypedBinary,
   ftOraBlob,
   ftOraClob,
   ftWideMemo : result := sizeof(TRESTDWMemBlobField)
 Else
  DatabaseErrorFmt(SUnsupportedFieldType,[Fieldtypenames[FieldDef.DataType]]);
End;
{$IFDEF FPC_REQUIRES_PROPER_ALIGNMENT}
 result:=Align(result,4);
{$ENDIF}
End;

Function TRESTDWCustomMemTable.GetRecordUpdateBuffer(Const ABookmark : TRESTDWMemBookmark; IncludePrior : boolean = false; AFindNext : boolean = false): boolean;

Var x        : integer;
  StartBuf : integer;

Begin
 If AFindNext Then
  StartBuf := FCurrentUpdateBuffer + 1
 Else
  StartBuf := 0;
 Result := False;
 For x := StartBuf To high(FUpdateBuffer) Do
  If CurrentIndexBuf.SameBookmarks(@FUpdateBuffer[x].BookmarkData,@ABookmark) or
   (IncludePrior and (FUpdateBuffer[x].UpdateKind=ukDelete) and CurrentIndexBuf.SameBookmarks(@FUpdateBuffer[x].NextBookmarkData,@ABookmark)) Then
  Begin
   FCurrentUpdateBuffer := x;
   Result := True;
   Break;
  End;
End;

Function TRESTDWCustomMemTable.GetRecordUpdateBufferCached(Const ABookmark: TRESTDWMemBookmark;
 IncludePrior: boolean): boolean;
Begin
 // if the current update buffer matches, immediately return true
 If (FCurrentUpdateBuffer < length(FUpdateBuffer)) and (
   CurrentIndexBuf.SameBookmarks(@FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData,@ABookmark) or
   (IncludePrior
    and (FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind=ukDelete)
    and  CurrentIndexBuf.SameBookmarks(@FUpdateBuffer[FCurrentUpdateBuffer].NextBookmarkData,@ABookmark))) Then
   Begin
    Result := True;
   End
 Else
  Result := GetRecordUpdateBuffer(ABookmark,IncludePrior);
End;

Function TRESTDWCustomMemTable.LoadBuffer(Buffer : TRecordBuffer): TGetResult;

Var NullMask        : pbyte;
  x               : longint;
  CreateBlobField : boolean;
  BufBlob         : PRESTDWMemBlobField;

Begin
 If not Fetch Then
  Begin
   Result := grEOF;
   FAllPacketsFetched := True;
  // This code has to be placed elsewhere. At least it should also run when
  // the datapacket is loaded from file ... see IntLoadRecordsFromFile
   BuildIndexes;
   Exit;
  End;

 NullMask := pointer(buffer);
 fillchar(Nullmask^,FNullmaskSize,0);
 buffer := Pointer(TRESTDWPtrInt(buffer) + FNullmaskSize);

 For x := 0 To FieldDefs.Count-1 Do
  Begin
   If not LoadField(FieldDefs[x],buffer,CreateBlobField) Then
   SetFieldIsNull(NullMask,x)
   Else If CreateBlobField Then
    Begin
     BufBlob := PRESTDWMemBlobField(Buffer);
     BufBlob^.BlobBuffer := GetNewBlobBuffer;
     LoadBlobIntoBuffer(FieldDefs[x],BufBlob);
    End;
   buffer := Pointer(TRESTDWPtrInt(buffer) + GetFieldSize(FieldDefs[x]));
  End;
 Result := grOK;
End;

Function TRESTDWCustomMemTable.GetCurrentBuffer: TRecordBuffer;
Begin
 Case State Of
  dsFilter:        Result := FFilterBuffer;
  dsCalcFields:    Result := TRecordBuffer(CalcBuffer);
{$IFDEF FPC}
  dsRefreshFields: Result := CurrentIndexBuf.CurrentBuffer;
{$ENDIF}
  Else             Result := TRecordBuffer(ActiveBuffer);
End;
End;


Function TRESTDWCustomMemTable.GetFieldDataPtr(Field: TField; Buffer: Pointer): Boolean;

Var
 CurrBuff : TRecordBuffer;

Begin
 Result := False;
 If State = dsOldValue Then
  Begin
   If FSavedState = dsInsert Then
    CurrBuff := nil // old values = null
   Else If GetActiveRecordUpdateBuffer Then
    CurrBuff := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer
   Else
    // There is no UpdateBuffer for ActiveRecord, so there are no explicit old values available
    // then we can assume, that old values = current values
    CurrBuff := CurrentIndexBuf.CurrentBuffer;
  End
 Else
  CurrBuff := GetCurrentBuffer;

 If not assigned(CurrBuff) Then Exit; //Null value

 If Field.FieldNo > 0 Then // If =-1, then calculated/lookup field or =0 unbound field
  Begin
   If GetFieldIsNull(pbyte(CurrBuff),Field.FieldNo-1) Then
   Exit;
   If assigned(Buffer) Then
    Begin
     CurrBuff := Pointer(TRESTDWPtrInt(CurrBuff) + FFieldBufPositions[Field.FieldNo-1]);
     If Field.IsBlob Then // we need GetFieldSize for BLOB but Field.DataSize for others - #36747
     Move(CurrBuff^, Buffer^, GetFieldSize(FieldDefs[Field.FieldNo-1]))
     Else
     Move(CurrBuff^, Buffer^, Field.DataSize);
    End;
   Result := True;
  End
 Else
  Begin
   CurrBuff := Pointer(TRESTDWPtrInt(CurrBuff) + GetRecordSize + Field.Offset);
   Result := Boolean(CurrBuff^);
   If Result and assigned(Buffer) Then
    Begin
     CurrBuff := Pointer(TRESTDWPtrInt(CurrBuff) + 1);
     Move(CurrBuff^, Buffer^, Field.DataSize);
    End;
  End;
End;

Procedure TRESTDWCustomMemTable.SetFieldDataPtr(Field: TField; Buffer: Pointer);

Var CurrBuff : pointer;
  NullMask : pbyte;

Begin
 If not (State in dsWriteModes) Then
  DatabaseErrorFmt(SNotEditing, [Name], Self);
 CurrBuff := GetCurrentBuffer;
 If Field.FieldNo > 0 Then // If =-1, then calculated/lookup field or =0 unbound field
  Begin
  {$IFDEF FPC}
   If Field.ReadOnly and not (State in [dsSetKey, dsFilter, dsRefreshFields]) Then
{$ELSE}
   If Field.ReadOnly and not (State in [dsSetKey, dsFilter]) Then
{$ENDIF}
   DatabaseErrorFmt(SReadOnlyField, [Field.DisplayName]);
   If State in [dsEdit, dsInsert, dsNewValue] Then
   Field.Validate(Buffer);
   NullMask := CurrBuff;

   CurrBuff := Pointer(TRESTDWPtrInt(CurrBuff) + FFieldBufPositions[Field.FieldNo-1]);
   If assigned(buffer) Then
    Begin
     If Field.IsBlob Then // we need GetFieldSize for BLOB but Field.DataSize for others - #36747
     Move(Buffer^, CurrBuff^, GetFieldSize(FieldDefs[Field.FieldNo-1]))
     Else
     Move(Buffer^, CurrBuff^, Field.DataSize);
     unSetFieldIsNull(NullMask,Field.FieldNo-1);
    End
   Else
   SetFieldIsNull(NullMask,Field.FieldNo-1);
  End
 Else
  Begin
   CurrBuff := Pointer(TRESTDWPtrInt(CurrBuff) + GetRecordSize + Field.Offset);
   Boolean(CurrBuff^) := Buffer <> nil;
   CurrBuff := Pointer(TRESTDWPtrInt(CurrBuff) + 1);
   If assigned(Buffer) Then
   Move(Buffer^, CurrBuff^, Field.DataSize);
  End;
 If not (State in [dsCalcFields, dsFilter, dsNewValue]) Then
  DataEvent(deFieldChange, TRESTDWPtrInt(Field));
End;

{$IFDEF FPC}
Function TRESTDWCustomMemTable.GetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean): Boolean;
Begin
 Result := GetFieldDataPtr(Field, Buffer);
End;
Function TRESTDWCustomMemTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
Begin
 Result := GetFieldDataPtr(Field, Buffer);
End;
Procedure TRESTDWCustomMemTable.SetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean);
Begin
 SetFieldDataPtr(Field, Buffer);
End;
Procedure TRESTDWCustomMemTable.SetFieldData(Field: TField; Buffer: Pointer);
Begin
 SetFieldDataPtr(Field, Buffer);
End;
{$ELSE}
 {$IFDEF DELPHIXEUP}
Function TRESTDWCustomMemTable.GetFieldData(Field: TField; Var Buffer: TValueBuffer): Boolean;
Var P: Pointer;
Begin
 If Length(Buffer) < Field.DataSize Then
  SetLength(Buffer, Field.DataSize);
 If Length(Buffer) > 0 Then P := @Buffer[0] Else P := nil;
 Result := GetFieldDataPtr(Field, P);
End;
Procedure TRESTDWCustomMemTable.SetFieldData(Field: TField; Buffer: TValueBuffer);
Var P: Pointer;
Begin
 If Length(Buffer) > 0 Then P := @Buffer[0] Else P := nil;
 SetFieldDataPtr(Field, P);
End;
 {$IFDEF RTL240_UP}
Function TRESTDWCustomMemTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
Begin
 Result := GetFieldDataPtr(Field, Buffer);
End;
Procedure TRESTDWCustomMemTable.SetFieldData(Field: TField; Buffer: Pointer);
Begin
 SetFieldDataPtr(Field, Buffer);
End;
 {$ENDIF}
 {$ELSE}
Function TRESTDWCustomMemTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
Begin
 Result := GetFieldDataPtr(Field, Buffer);
End;
Procedure TRESTDWCustomMemTable.SetFieldData(Field: TField; Buffer: Pointer);
Begin
 SetFieldDataPtr(Field, Buffer);
End;
 {$ENDIF}
{$ENDIF}
Function TRESTDWCustomMemTable.IsSequenced : Boolean;
Begin
 Result := Not Filtered;
End;

Procedure TRESTDWCustomMemTable.InternalDelete;
        Var RemRec : pointer;
        RemRecBookmrk : TRESTDWMemBookmark;
        Begin
         InternalSetToRecord(TRecordBuffer(ActiveBuffer));
 // Remove the record from all active indexes
         CurrentIndexBuf.StoreCurrentRecIntoBookmark(@RemRecBookmrk);
         RemRec := CurrentIndexBuf.CurrentBuffer;
         RemoveRecordFromIndexes(RemRecBookmrk);

         If not GetActiveRecordUpdateBuffer Then
          Begin
           FCurrentUpdateBuffer := length(FUpdateBuffer);
           SetLength(FUpdateBuffer,FCurrentUpdateBuffer+1);
           FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := IntAllocRecordBuffer;
           move(RemRec^, FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer^,FRecordSize);
          End
         Else
          Begin
           If FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind <> ukModify Then
            Begin
             FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := nil;  //this 'disables' the updatebuffer
     // Do NOT release record buffer (pointed to by RemRecBookmrk.BookmarkData) here
     //  - When record is inserted and deleted (and memory released) and again inserted then the same memory block can be returned
     //    which leads to confusion, because we get the same BookmarkData for distinct records
     //  - In CancelUpdates when records are restored, it is expected that deleted records still exist in memory
     // There also could be record(s) in the update buffer that is linked to this record.
            End;
          End;
         CurrentIndexBuf.StoreCurrentRecIntoBookmark(@FUpdateBuffer[FCurrentUpdateBuffer].NextBookmarkData);
         FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := RemRecBookmrk;
         FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukDelete;
         dec(FBRecordCount);
        End;


Procedure TRESTDWCustomMemTable.CancelRecordUpdateBuffer(AUpdateBufferIndex: integer; Var ABookmark: TRESTDWMemBookmark);
Var
ARecordBuffer: TRecordBuffer;
NBookmark    : TRESTDWMemBookmark;
i            : integer;
Begin
 With FUpdateBuffer[AUpdateBufferIndex] Do
 If Assigned(BookmarkData.BookmarkData) Then // this is used to exclude buffers which are already handled
 Begin
  Case UpdateKind Of
  ukModify:
  Begin
   CurrentIndexBuf.GotoBookmark(@BookmarkData);
   move(TRecordBuffer(OldValuesBuffer)^, TRecordBuffer(CurrentIndexBuf.CurrentBuffer)^, FRecordSize);
   FreeRecordBuffer(OldValuesBuffer);
  End;
  ukDelete:
  If (assigned(OldValuesBuffer)) Then
   Begin
    CurrentIndexBuf.GotoBookmark(@NextBookmarkData);
    CurrentIndexBuf.InsertRecordBeforeCurrentRecord(TRecordBuffer(BookmarkData.BookmarkData));
    CurrentIndexBuf.ScrollBackward;
    move(TRecordBuffer(OldValuesBuffer)^, TRecordBuffer(CurrentIndexBuf.CurrentBuffer)^, FRecordSize);
    FreeRecordBuffer(OldValuesBuffer);
    inc(FBRecordCount);
   End;
  ukInsert:
  Begin
   CurrentIndexBuf.GotoBookmark(@BookmarkData);
   ARecordBuffer := CurrentIndexBuf.CurrentRecord;

     // Find next record's bookmark
   CurrentIndexBuf.DoScrollForward;
   CurrentIndexBuf.StoreCurrentRecIntoBookmark(@NBookmark);
     // Process (re-link) all update buffers linked to this record before this record is removed
     //  Modified record #1, which is later deleted can be linked to another inserted record #2. In this case deleted record #1 precedes inserted #2 in update buffer.
     //  Deleted records, which are deleted after this record is inserted are in update buffer after this record.
     //  if we need revert inserted record which is linked from another deleted records, then we must re-link these records
   For i:=0 To high(FUpdateBuffer) Do
   If (FUpdateBuffer[i].UpdateKind = ukDelete) and
   (FUpdateBuffer[i].NextBookmarkData.BookmarkData = BookmarkData.BookmarkData) Then
   FUpdateBuffer[i].NextBookmarkData := NBookmark;

     // ReSync won't work if the CurrentBuffer is freed ... so in this case move to next/prior record
   If CurrentIndexBuf.SameBookmarks(@BookmarkData,@ABookmark) Then
   With CurrentIndexBuf Do
    Begin
     GotoBookmark(@ABookmark);
     If ScrollForward = grEOF Then
     If ScrollBackward = grBOF Then
     ScrollLast;  // last record will be removed from index, so move to spare record
     StoreCurrentRecIntoBookmark(@ABookmark);
    End;

   RemoveRecordFromIndexes(BookmarkData);
   FreeRecordBuffer(ARecordBuffer);
   dec(FBRecordCount);
  End;
 End;
 BookmarkData.BookmarkData := nil;
End;
       End;

Procedure TRESTDWCustomMemTable.RevertRecord;
Var
ABookmark : TRESTDWMemBookmark;
Begin
 CheckBrowseMode;

 If GetActiveRecordUpdateBuffer Then
  Begin
   CurrentIndexBuf.StoreCurrentRecIntoBookmark(@ABookmark);
 
   CancelRecordUpdateBuffer(FCurrentUpdateBuffer, ABookmark);
 
   // remove update record of current record from update-buffer array
   Move(FUpdateBuffer[FCurrentUpdateBuffer+1], FUpdateBuffer[FCurrentUpdateBuffer], (High(FUpdateBuffer)-FCurrentUpdateBuffer)*SizeOf(TRESTDWMemRecUpdateBuffer));
   SetLength(FUpdateBuffer, High(FUpdateBuffer));
 
   CurrentIndexBuf.GotoBookmark(@ABookmark);
 
   Resync([]);
  End;
End;

Procedure TRESTDWCustomMemTable.CancelUpdates;
Var
ABookmark : TRESTDWMemBookmark;
r         : Integer;
Begin
 CheckBrowseMode;

 If Length(FUpdateBuffer) > 0 Then
  Begin
   CurrentIndexBuf.StoreCurrentRecIntoBookmark(@ABookmark);
 
   For r := High(FUpdateBuffer) Downto 0 Do
   CancelRecordUpdateBuffer(r, ABookmark);
   SetLength(FUpdateBuffer, 0);
 
   CurrentIndexBuf.GotoBookmark(@ABookmark);
 
   Resync([]);
  End;
End;

Procedure TRESTDWCustomMemTable.EmptyTable;
Var
AFileName      : TFileName;
ADatasetReader : TRESTDWMemDataPacketReader;
Begin
 If not Active Then
 Exit;

 CheckBrowseMode;
 AFileName := FFileName;
 ADatasetReader := FDatasetReader;
 FFileName := '';
 FDatasetReader := nil;
 DisableControls;
 Try
 FreeFieldBuffers;
 ClearBuffers;
 InternalClose;
 InternalOpen;
 FAllPacketsFetched := True;
 Finally
 FDatasetReader := ADatasetReader;
 FFileName := AFileName;
 EnableControls;
End;
DataEvent(deDataSetChange, 0);
      End;

Procedure TRESTDWCustomMemTable.MergeChangeLog;

Var r            : Integer;

Begin
 For r:=0 To length(FUpdateBuffer)-1 Do
 If assigned(FUpdateBuffer[r].OldValuesBuffer) Then
 FreeMem(FUpdateBuffer[r].OldValuesBuffer);
 SetLength(FUpdateBuffer,0);

 If assigned(FUpdateBlobBuffers) Then For r:=0 To length(FUpdateBlobBuffers)-1 Do
 If assigned(FUpdateBlobBuffers[r]) Then
  Begin
    // update blob buffer is already referenced from record buffer (see InternalPost)
   If FUpdateBlobBuffers[r]^.OrgBufID >= 0 Then
    Begin
     FreeBlobBuffer(FBlobBuffers[FUpdateBlobBuffers[r]^.OrgBufID]);
     FBlobBuffers[FUpdateBlobBuffers[r]^.OrgBufID] := FUpdateBlobBuffers[r];
    End
   Else
    Begin
     setlength(FBlobBuffers,length(FBlobBuffers)+1);
     FUpdateBlobBuffers[r]^.OrgBufID := high(FBlobBuffers);
     FBlobBuffers[high(FBlobBuffers)] := FUpdateBlobBuffers[r];
    End;
  End;
 SetLength(FUpdateBlobBuffers,0);
End;


Procedure TRESTDWCustomMemTable.InternalCancel;

Var i            : integer;

Begin
 If assigned(FUpdateBlobBuffers) Then For i:=0 To high(FUpdateBlobBuffers) Do
 If assigned(FUpdateBlobBuffers[i]) and (FUpdateBlobBuffers[i]^.FieldNo>0) Then
 FreeBlobBuffer(FUpdateBlobBuffers[i]);
End;

Procedure TRESTDWCustomMemTable.InternalPost;

Var ABuff        : TRecordBuffer;
i            : integer;
ABookmark    : PRESTDWMemBookmark;

Begin
 Inherited InternalPost;

 If assigned(FUpdateBlobBuffers) Then For i:=0 To high(FUpdateBlobBuffers) Do
 If assigned(FUpdateBlobBuffers[i]) and (FUpdateBlobBuffers[i]^.FieldNo>0) Then
 FUpdateBlobBuffers[i]^.FieldNo := -1;

 If State = dsInsert Then
  Begin
   If assigned(FAutoIncField) Then
    Begin
     FAutoIncField.AsInteger := FAutoIncValue;
     inc(FAutoIncValue);
    End;
   // The active buffer is the newly created TDataSet record,
   // from which the bookmark is set to the record where the new record should be
   // inserted
   ABookmark := PRESTDWMemBookmark(TRESTDWPtrInt(ActiveBuffer) + FRecordSize);
   // Create the new record buffer
   ABuff := IntAllocRecordBuffer;
 
   // Add new record to all active indexes
   For i := 0 To FIndexes.Count-1 Do
   If BufIndexdefs[i].IsActiveIndex(FCurrentIndexDef) Then
    Begin
     If (FBRecordCount = 0) Or
        (ABookmark^.BookmarkFlag = bfEOF) Or
        (Not Assigned(ABookmark^.BookmarkData)) Then
 // append at end
      BufIndexes[i].ScrollLast
     Else
 // insert (before current record)
      BufIndexes[i].GotoBookmark(ABookmark);
  
// insert new record before current record
     BufIndexes[i].InsertRecordBeforeCurrentRecord(ABuff);
// newly inserted record becomes current record
     BufIndexes[i].ScrollBackward;
    End;
 
   // Link the newly created record buffer to the newly created TDataSet record
   CurrentIndexBuf.StoreCurrentRecIntoBookmark(ABookmark);
   ABookmark^.BookmarkFlag := bfInserted;
 
   inc(FBRecordCount);
  End
 Else
 InternalSetToRecord(TRecordBuffer(ActiveBuffer));

 // If there is no updatebuffer already, add one
 If not GetActiveRecordUpdateBuffer Then
  Begin
   // Add a new updatebuffer
   FCurrentUpdateBuffer := length(FUpdateBuffer);
   SetLength(FUpdateBuffer,FCurrentUpdateBuffer+1);
 
   // Store a bookmark of the current record into the updatebuffer's bookmark
   CurrentIndexBuf.StoreCurrentRecIntoBookmark(@FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData);
 
   If State = dsEdit Then
    Begin
     // Create an OldValues buffer with the old values of the record
     FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukModify;
     FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := IntAllocRecordBuffer;
     // Move only the real data
     move(CurrentIndexBuf.CurrentBuffer^, FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer^, FRecordSize);
    End
   Else
    Begin
     FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukInsert;
     FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := nil;
    End;
  End;

 Move(TRecordBuffer(ActiveBuffer)^, CurrentIndexBuf.CurrentBuffer^, FRecordSize);

 // new data are now in current record so reorder current record if needed
 For i := 0 To FIndexes.Count-1 Do
 If BufIndexDefs[i].MustBuild(FCurrentIndexDef) Then
 BufIndexes[i].OrderCurrentRecord;
End;

Procedure TRESTDWCustomMemTable.CalcRecordSize;

Var x : longint;

Begin
 FNullmaskSize := (FieldDefs.Count+7) div 8;
{$IFDEF FPC_REQUIRES_PROPER_ALIGNMENT}
 FNullmaskSize:=Align(FNullmaskSize,4);
{$ENDIF}
 FRecordSize := FNullmaskSize;
 SetLength(FFieldBufPositions,FieldDefs.count);
 For x := 0 To FieldDefs.count-1 Do
  Begin
   FFieldBufPositions[x] := FRecordSize;
   inc(FRecordSize, GetFieldSize(FieldDefs[x]));
  End;
End;

Function TRESTDWCustomMemTable.GetIndexFieldNames: String;

Var
i, p: integer;
s: string;
IndexBuf: TRESTDWMemInternalIndex;

Begin
 Result := FIndexFieldNames;
 IndexBuf:=CurrentIndexBuf;
 If (IndexBuf=Nil) Then
 Exit;
 Result:='';
 For i := 1 To RESTDWWordCount(IndexBuf.FieldsName, [Limiter]) Do
  Begin
   s := RESTDWExtractDelimited(i, IndexBuf.FieldsName, [Limiter]);
   p := Pos(s, IndexBuf.DescFields);
   If p>0 Then
   s := s + Desc;
   Result := Result + Limiter + s;
  End;
 If (Length(Result)>0) and (Result[1]=Limiter) Then
 system.Delete(Result, 1, 1);
End;

Function TRESTDWCustomMemTable.GetIndexName: String;

Begin
 If FIndexName<>'' Then
  Result:=FIndexName
 Else If (FIndexes.Count>0) and (CurrentIndexBuf<>Nil) Then
  Result:=CurrentIndexBuf.Name
 Else
  Result:='';
End;

Function TRESTDWCustomMemTable.GetBufUniDirectional: boolean;
Begin
 result := IsUniDirectional;
End;

Function TRESTDWCustomMemTable.GetPacketReader(Const Format: TRESTDWMemDataPacketFormat; Const AStream: TStream): TRESTDWMemDataPacketReader;

Var
APacketReader: TRESTDWMemDataPacketReader;
APacketReaderReg: TRESTDWMemDataPacketReaderRegistration;
Fmt : TRESTDWMemDataPacketFormat;
Begin
 fmt:=Format;
 If (Fmt=dfDefault) Then
 fmt:=DefaultReadFileFormat;
 If fmt=dfDefault Then
 APacketReader := CreateDefaultPacketReader(AStream)
 Else If GetRegisterDatapacketReader(AStream, fmt, APacketReaderReg) Then
 APacketReader := APacketReaderReg.ReaderClass.Create(Self, AStream)
 Else If TRESTDWTBinaryDatapacketReader.RecognizeStream(AStream) Then
  Begin
   AStream.Seek(0, soFromBeginning);
   APacketReader := TRESTDWTBinaryDatapacketReader.Create(Self, AStream)
  End
 Else
 DatabaseError(SStreamNotRecognised,Self);
 Result:=APacketReader;
End;

Function TRESTDWCustomMemTable.GetRecordSize : Word;

Begin
 result := FRecordSize + BookmarkSize;
End;

Function TRESTDWCustomMemTable.GetChangeCount: integer;

Begin
 result := length(FUpdateBuffer);
End;


Procedure TRESTDWCustomMemTable.InternalInitRecord(Buffer:  TRecordBuffer);

Begin
 FillChar(Buffer^, FRecordSize, #0);

 fillchar(Buffer^,FNullmaskSize,255);
End;

{$IFDEF FPC}
Procedure TRESTDWCustomMemTable.SetRecNo(Value: Longint);
{$ELSE}
Procedure TRESTDWCustomMemTable.SetRecNo(Value: Integer);
{$ENDIF}

Var ABookmark : TRESTDWMemBookmark;

Begin
 CheckBrowseMode;
 If Value > RecordCount Then
 Repeat Until (getnextpacket < FPacketRecords) or (Value <= RecordCount) or (FPacketRecords = -1);

 If (Value > RecordCount) or (Value < 1) Then
  Begin
   DatabaseError(SNoSuchRecord, Self);
   Exit;
  End;

 CurrentIndexBuf.RecNo:=Value;
 CurrentIndexBuf.StoreCurrentRecIntoBookmark(@ABookmark);
 InternalGotoBookmark(@ABookmark);
End;

{$IFDEF FPC}
Function TRESTDWCustomMemTable.GetRecNo: Longint;
{$ELSE}
Function TRESTDWCustomMemTable.GetRecNo: Integer;
{$ENDIF}

Begin
 If IsUniDirectional Then
 Result := -1
 Else If (FBRecordCount = 0) or (State = dsInsert) Then
 Result := 0
 Else
  Begin
   UpdateCursorPos;
   Result := CurrentIndexBuf.RecNo;
  End;
End;

Function TRESTDWCustomMemTable.IsCursorOpen: Boolean;

Begin
 Result := FOpen;
End;

{$IFDEF FPC}
Function TRESTDWCustomMemTable.GetRecordCount: Longint;
{$ELSE}
Function TRESTDWCustomMemTable.GetRecordCount: Integer;
{$ENDIF}
Begin
 If Active Then
 Result := FBRecordCount
 Else
 Result:=0;
End;

Function TRESTDWCustomMemTable.UpdateStatus: TUpdateStatus;

Begin
 Result:=usUnmodified;
 If GetActiveRecordUpdateBuffer Then
 Case FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind Of
 ukModify : Result := usModified;
 ukInsert : Result := usInserted;
 ukDelete : Result := usDeleted;
End;
     End;

Function TRESTDWCustomMemTable.GetNewBlobBuffer : PRESTDWMemBlobBuffer;

Var ABlobBuffer : PRESTDWMemBlobBuffer;

Begin
 setlength(FBlobBuffers,length(FBlobBuffers)+1);
 new(ABlobBuffer);
 FillChar(ABlobBuffer^,SizeOf(ABlobBuffer^),0);
 ABlobBuffer^.OrgBufID := high(FBlobBuffers);
 FBlobBuffers[high(FBlobBuffers)] := ABlobBuffer;
 result := ABlobBuffer;
End;

Function TRESTDWCustomMemTable.GetNewWriteBlobBuffer : PRESTDWMemBlobBuffer;

Var ABlobBuffer : PRESTDWMemBlobBuffer;

Begin
 setlength(FUpdateBlobBuffers,length(FUpdateBlobBuffers)+1);
 new(ABlobBuffer);
 FillChar(ABlobBuffer^,SizeOf(ABlobBuffer^),0);
 FUpdateBlobBuffers[high(FUpdateBlobBuffers)] := ABlobBuffer;
 result := ABlobBuffer;
End;

Procedure TRESTDWCustomMemTable.FreeBlobBuffer(Var ABlobBuffer: PRESTDWMemBlobBuffer);

Begin
 If not Assigned(ABlobBuffer) Then
  Exit;
 FreeMem(ABlobBuffer^.Buffer, ABlobBuffer^.Size);
 Dispose(ABlobBuffer);
 ABlobBuffer := Nil;
End;

{ TRESTDWMemBlobStream }

Function TRESTDWMemBlobStream.Seek(Offset: Longint; Origin: Word): Longint;

Begin
 Case Origin Of
 soFromBeginning : FPosition:=Offset;
 soFromEnd       : FPosition:=FBlobBuffer^.Size+Offset;
 soFromCurrent   : FPosition:=FPosition+Offset;
End;
Result:=FPosition;
    End;


Function TRESTDWMemBlobStream.Read(Var Buffer; Count: Longint): Longint;

Var ptr : pointer;

Begin
 If FPosition + Count > FBlobBuffer^.Size Then
 Count := FBlobBuffer^.Size-FPosition;
 ptr := Pointer(TRESTDWPtrInt(FBlobBuffer^.Buffer)+FPosition);
 move(ptr^, Buffer, Count);
 inc(FPosition, Count);
 result := Count;
End;

Function TRESTDWMemBlobStream.Write(Const Buffer; Count: Longint): Longint;

Var ptr : pointer;

Begin
 ReAllocMem(FBlobBuffer^.Buffer, FPosition+Count);
 ptr := Pointer(TRESTDWPtrInt(FBlobBuffer^.Buffer)+FPosition);
 move(buffer, ptr^, Count);
 inc(FBlobBuffer^.Size, Count);
 inc(FPosition, Count);
 FModified := True;
 Result := Count;
End;

Constructor TRESTDWMemDataReference.Create(ADataSet: TRESTDWCustomMemTable;
 AKind: TRESTDWMemDataReferenceKind);
Begin
 Inherited Create;
 FDataSet := ADataSet;
 FKind := AKind;
End;

Procedure TRESTDWMemDataReference.AssignTo(ADataSet: TRESTDWCustomMemTable);
Var
 AStream : TMemoryStream;
Begin
 If not Assigned(ADataSet) or not Assigned(FDataSet) Then
  Exit;
 If ADataSet = FDataSet Then
  Exit;
 If ADataSet.Active Then
  DatabaseError('DataSet must be inactive', ADataSet);
 AStream := TMemoryStream.Create;
 Try
  If FKind = drDelta Then
   FDataSet.SaveDeltaToStream(AStream)
  Else
   FDataSet.SaveToStream(AStream, dfBinary);
  AStream.Position := 0;
  ADataSet.LoadFromStream(AStream, dfBinary);
 Finally
  AStream.Free;
 End;
End;

Constructor TRESTDWMemBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);

Var bufblob : TRESTDWMemBlobField;
CurrBuff : TRecordBuffer;

Begin
 FField := Field;
 FDataSet := Field.DataSet as TRESTDWCustomMemTable;
 With FDataSet Do
 If Mode = bmRead Then
  Begin
   If not Field.GetData(@bufblob) Then
   DatabaseError(SFieldIsNull);
   If not assigned(bufblob.BlobBuffer) Then
    Begin
     bufblob.BlobBuffer := GetNewBlobBuffer;
     LoadBlobIntoBuffer(FieldDefs[Field.FieldNo-1], @bufblob);
    End;
   FBlobBuffer := bufblob.BlobBuffer;
  End
 Else If Mode=bmWrite Then
  Begin
   FBlobBuffer := GetNewWriteBlobBuffer;
   FBlobBuffer^.FieldNo := Field.FieldNo;
   If Field.GetData(@bufblob) and assigned(bufblob.BlobBuffer) Then
   FBlobBuffer^.OrgBufID := bufblob.BlobBuffer^.OrgBufID
   Else
   FBlobBuffer^.OrgBufID := -1;
   bufblob.BlobBuffer := FBlobBuffer;
 
   CurrBuff := GetCurrentBuffer;
// unset null flag for blob field
   unSetFieldIsNull(PByte(CurrBuff), Field.FieldNo-1);
// redirect pointer in current record buffer to new write blob buffer
   CurrBuff := Pointer(TRESTDWPtrInt(CurrBuff) + FDataSet.FFieldBufPositions[Field.FieldNo-1]);
   Move(bufblob, CurrBuff^, FDataSet.GetFieldSize(FDataSet.FieldDefs[Field.FieldNo-1]));
   FModified := True;
  End;
End;

Destructor TRESTDWMemBlobStream.Destroy;
Begin
 If FModified Then
  Begin
   // if TRESTDWMemBlobStream was requested, but no data was written, then Size = 0;
   //  used by TBlobField.Clear, so in this case set Field to null
   //FField.Modified := True; // should be set to True, but TBlobField.Modified is never reset
 
   If not (FDataSet.State in [dsFilter, dsCalcFields, dsNewValue]) Then
    Begin
     If FBlobBuffer^.Size = 0 Then // empty blob = IsNull
  // blob stream should be destroyed while DataSet is in write state
     SetFieldIsNull(PByte(FDataSet.GetCurrentBuffer), FField.FieldNo-1);
     FDataSet.DataEvent(deFieldChange, TRESTDWPtrInt(FField));
    End;
  End;
 Inherited Destroy;
End;

Function TRESTDWCustomMemTable.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;

Var bufblob : TRESTDWMemBlobField;

Begin
 Result := nil;
 Case Mode Of
 bmRead:
 If not Field.GetData(@bufblob) Then
  Exit;
 bmWrite:
 Begin
  If not (State in [dsEdit, dsInsert, dsFilter, dsCalcFields]) Then
  DatabaseErrorFmt(SNotEditing, [Name], Self);
  If Field.ReadOnly and not (State in [dsSetKey, dsFilter]) Then
  DatabaseErrorFmt(SReadOnlyField, [Field.DisplayName]);
 End;
End;
Result := TRESTDWMemBlobStream.Create(Field as TBlobField, Mode);
   End;

Function TRESTDWCustomMemTable.GetDataReference: TRESTDWMemDataReference;
Begin
 If not Assigned(FDataReference) Then
  FDataReference := TRESTDWMemDataReference.Create(Self, drData);
 Result := FDataReference;
End;

Function TRESTDWCustomMemTable.GetDeltaReference: TRESTDWMemDataReference;
Begin
 If not Assigned(FDeltaReference) Then
  FDeltaReference := TRESTDWMemDataReference.Create(Self, drDelta);
 Result := FDeltaReference;
End;

Procedure TRESTDWCustomMemTable.SetDataReference(AValue: TRESTDWMemDataReference);
Begin
 If not Assigned(AValue) Then
  Exit;
 AValue.AssignTo(Self);
End;

Procedure TRESTDWCustomMemTable.SaveDeltaToStream(AStream: TStream);
Var
 AWriter        : TRESTDWTBinaryDatapacketReader;
 ASavedState    : TDataSetState;
 ASavedBuffer   : TRecordBuffer;
 ASavedUpdIndex : Integer;
 I              : Integer;
Begin
 CheckBiDirectional;
 AWriter := TRESTDWTBinaryDatapacketReader.Create(Self, AStream);
 ASavedState := SetTempState(dsFilter);
 ASavedBuffer := FFilterBuffer;
 ASavedUpdIndex := FCurrentUpdateBuffer;
 Try
  AWriter.StoreFieldDefs(FAutoIncValue);
  For I := 0 To High(FUpdateBuffer) Do
   Begin
    If Assigned(FUpdateBuffer[I].BookmarkData.BookmarkData) Then
     Begin
      FCurrentUpdateBuffer := I;
      Case FUpdateBuffer[I].UpdateKind Of
       ukModify:
        Begin
         If Assigned(FUpdateBuffer[I].OldValuesBuffer) Then
          Begin
           FFilterBuffer := FUpdateBuffer[I].OldValuesBuffer;
           AWriter.StoreRecord([rsvOriginal], I);
          End;
         CurrentIndexBuf.GotoBookmark(@FUpdateBuffer[I].BookmarkData);
         FFilterBuffer := CurrentIndexBuf.CurrentBuffer;
         AWriter.StoreRecord([rsvUpdated], I);
        End;
       ukInsert:
        Begin
         CurrentIndexBuf.GotoBookmark(@FUpdateBuffer[I].BookmarkData);
         FFilterBuffer := CurrentIndexBuf.CurrentBuffer;
         AWriter.StoreRecord([rsvInserted], I);
        End;
       ukDelete:
        Begin
         If Assigned(FUpdateBuffer[I].OldValuesBuffer) Then
          Begin
           FFilterBuffer := FUpdateBuffer[I].OldValuesBuffer;
           AWriter.StoreRecord([rsvDeleted], I);
          End;
        End;
      End;
     End;
   End;
  AWriter.FinalizeStoreRecords;
 Finally
  FCurrentUpdateBuffer := ASavedUpdIndex;
  FFilterBuffer := ASavedBuffer;
  RestoreState(ASavedState);
  AWriter.Free;
 End;
End;

Procedure TRESTDWCustomMemTable.SetDatasetPacket(AReader: TRESTDWMemDataPacketReader);
Var
 ADefaultFields : Boolean;
Begin
 ADefaultFields := DefaultFields;
 If Active Then
  Close;
 If ADefaultFields Then
  Fields.Clear;
 FieldDefs.Clear;
 FDatasetReader := AReader;
 Try
  Open;
 Finally
  FDatasetReader := nil;
 End;
End;

Procedure TRESTDWCustomMemTable.GetDatasetPacket(AWriter: TRESTDWMemDataPacketReader);

Procedure StoreUpdateBuffer(AUpdBuffer : TRESTDWMemRecUpdateBuffer; Var ARowState: TRESTDWMemRowState);
Var AThisRowState : TRESTDWMemRowState;
 AStoreUpdBuf  : Integer;
Begin
 If AUpdBuffer.UpdateKind = ukModify Then
  Begin
   AThisRowState := [rsvOriginal];
   ARowState:=[rsvUpdated];
  End
 Else If AUpdBuffer.UpdateKind = ukDelete Then
  Begin
   AStoreUpdBuf:=FCurrentUpdateBuffer;
   If GetRecordUpdateBuffer(AUpdBuffer.BookmarkData,True,False) Then
   Repeat
    If CurrentIndexBuf.SameBookmarks(@FUpdateBuffer[FCurrentUpdateBuffer].NextBookmarkData, @AUpdBuffer.BookmarkData) Then
     StoreUpdateBuffer(FUpdateBuffer[FCurrentUpdateBuffer], ARowState);
   Until not GetRecordUpdateBuffer(AUpdBuffer.BookmarkData,True,True);
   FCurrentUpdateBuffer:=AStoreUpdBuf;
   AThisRowState := [rsvDeleted];
  End
 Else // ie: UpdateKind = ukInsert
 ARowState := [rsvInserted];

 FFilterBuffer:=AUpdBuffer.OldValuesBuffer;
// OldValuesBuffer is nil if the record is either inserted or inserted and then deleted
 If assigned(FFilterBuffer) Then
 FDatasetReader.StoreRecord(AThisRowState,FCurrentUpdateBuffer);
End;

Procedure HandleUpdateBuffersFromRecord(AFindNext : boolean; ARecBookmark : TRESTDWMemBookmark; Var ARowState: TRESTDWMemRowState);
Var StoreUpdBuf1,StoreUpdBuf2 : Integer;
Begin
 If not AFindNext Then
  ARowState:=[];
 If GetRecordUpdateBuffer(ARecBookmark,True,AFindNext) Then
  Begin
   If FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind=ukDelete Then
    Begin
     StoreUpdBuf1:=FCurrentUpdateBuffer;
     HandleUpdateBuffersFromRecord(True,ARecBookmark,ARowState);
     StoreUpdBuf2:=FCurrentUpdateBuffer;
     FCurrentUpdateBuffer:=StoreUpdBuf1;
     StoreUpdateBuffer(FUpdateBuffer[StoreUpdBuf1], ARowState);
     FCurrentUpdateBuffer:=StoreUpdBuf2;
    End
   Else
    Begin
     StoreUpdateBuffer(FUpdateBuffer[FCurrentUpdateBuffer], ARowState);
     HandleUpdateBuffersFromRecord(True,ARecBookmark,ARowState);
    End;
  End
End;

Var ScrollResult   : TGetResult;
SavedState     : TDataSetState;
ABookMark      : PRESTDWMemBookmark;
ATBookmark     : TRESTDWMemBookmark;
RowState       : TRESTDWMemRowState;

Begin
 FDatasetReader := AWriter;
 Try
//  CheckActive;
 ABookMark:=@ATBookmark;
 FDatasetReader.StoreFieldDefs(FAutoIncValue);

 SavedState:=SetTempState(dsFilter);
 ScrollResult:=CurrentIndexBuf.ScrollFirst;
 While ScrollResult=grOK Do
  Begin
   RowState:=[];
   CurrentIndexBuf.StoreCurrentRecIntoBookmark(ABookmark);
  // updates related to current record are stored first
   HandleUpdateBuffersFromRecord(False,ABookmark^,RowState);
  // now store current record
   FFilterBuffer:=CurrentIndexBuf.CurrentBuffer;
   If RowState=[] Then
   FDatasetReader.StoreRecord([])
   Else
   FDatasetReader.StoreRecord(RowState,FCurrentUpdateBuffer);
 
   ScrollResult:=CurrentIndexBuf.ScrollForward;
   If ScrollResult<>grOK Then
    Begin
     If getnextpacket>0 Then
     ScrollResult := CurrentIndexBuf.ScrollForward;
    End;
  End;
// There could be an update buffer linked to the last (spare) record
 CurrentIndexBuf.StoreSpareRecIntoBookmark(ABookmark);
 HandleUpdateBuffersFromRecord(False,ABookmark^,RowState);

 RestoreState(SavedState);

 FDatasetReader.FinalizeStoreRecords;
 Finally
 FDatasetReader := nil;
End;
 End;

Procedure TRESTDWCustomMemTable.LoadFromStream(AStream : TStream;
                                                 Format  : TRESTDWMemDataPacketFormat);
Var
 APacketReader : TRESTDWMemDataPacketReader;
 AStorage      : TRESTDWStorageBin;
 APosition     : Int64;
Begin
 CheckBiDirectional;
 If Format = dfDefault Then
  Begin
   APosition := AStream.Position;
   AStream.Position := 0;
   If TRESTDWTBinaryDatapacketReader.RecognizeStream(AStream) Then
    Begin
     AStream.Position := 0;
     APacketReader := TRESTDWTBinaryDatapacketReader.Create(Self,AStream);
     Try
      SetDatasetPacket(APacketReader);
     Finally
      APacketReader.Free;
     End;
     Exit;
    End;
   AStream.Position := APosition;
   AStorage := TRESTDWStorageBin.Create(Nil);
   Try
    AStorage.LoadDWMemFromStream(Self,AStream);
   Finally
    AStorage.Free;
   End;
   Exit;
  End;
 APacketReader := GetPacketReader(Format,AStream);
 Try
  SetDatasetPacket(APacketReader);
 Finally
  APacketReader.Free;
 End;
End;

Procedure TRESTDWCustomMemTable.SaveToStream(AStream : TStream;
                                               Format  : TRESTDWMemDataPacketFormat);
Var
 APacketReaderReg : TRESTDWMemDataPacketReaderRegistration;
 APacketWriter    : TRESTDWMemDataPacketReader;
 AStorage         : TRESTDWStorageBin;
 Fmt              : TRESTDWMemDataPacketFormat;
Begin
 CheckBiDirectional;
 If Format = dfDefault Then
  Begin
   AStorage := TRESTDWStorageBin.Create(Nil);
   Try
    AStorage.SaveDWMemToStream(Self,AStream);
   Finally
    AStorage.Free;
   End;
   Exit;
  End;
 Fmt := Format;
 If GetRegisterDatapacketReader(Nil,Fmt,APacketReaderReg) Then
  APacketWriter := APacketReaderReg.ReaderClass.Create(Self,AStream)
 Else If Fmt = dfBinary Then
  APacketWriter := TRESTDWTBinaryDatapacketReader.Create(Self,AStream)
 Else
  DatabaseError(SNoReaderClassRegistered,Self);
 Try
  GetDatasetPacket(APacketWriter);
 Finally
  APacketWriter.Free;
 End;
End;

Procedure TRESTDWCustomMemTable.LoadFromFile(AFileName: string; Format: TRESTDWMemDataPacketFormat);

Var
 AFileStream : TFileStream;

Begin
 If AFileName='' Then
   AFileName := FFileName;
 AFileStream := TFileStream.Create(AFileName,fmOpenRead);
 Try
  LoadFromStream(AFileStream, Format);
 Finally
  AFileStream.Free;
End;
End;

Procedure TRESTDWCustomMemTable.SaveToFile(AFileName: string; Format: TRESTDWMemDataPacketFormat);

Var
 AFileStream : TFileStream;

Begin
 If AFileName='' Then
  AFileName := FFileName;
 AFileStream := TFileStream.Create(AFileName,fmCreate);
 Try
  SaveToStream(AFileStream, Format);
 Finally
  AFileStream.Free;
End;
End;

Procedure TRESTDWCustomMemTable.CreateDataset;

Var
 AStoreFileName : String;
 I              : Integer;
 J              : Integer;

Begin
 CheckInactive;
 If ((Fields.Count = 0) Or (FieldDefs.Count = 0)) Then
  Begin
   If (FieldDefs.Count > 0) Then
    Begin
     CreateFields;
     For I := 0 To Fields.Count - 1 Do
      For J := 0 To FieldDefs.Count - 1 Do
       If SameText(Fields[I].FieldName, FieldDefs[J].Name) Then
        Begin
         Case Fields[I].DataType Of
          ftString,
          ftFixedChar,
          ftWideString,
          ftFixedWideChar,
          ftBytes,
          ftVarBytes:
           If FieldDefs[J].Size > 0 Then
            Begin
             If Fields[I].DataSize <= 0 Then
              Fields[I].Size := 1;
             If Fields[I].Size <> FieldDefs[J].Size Then
              Fields[I].Size := FieldDefs[J].Size;
            End;
         End;
         Break;
        End;
     BindFields(True);
    End
   Else If (Fields.Count > 0) Then
    Begin
     InitFieldDefsFromPersistentFields;
     BindFields(True);
    End
   Else
    Raise Exception.Create(SErrNoFieldsDefined);
  End;
 If FAutoIncValue < 0 Then
  FAutoIncValue := 1;
 AStoreFileName := FFileName;
 FFileName := '';
 Try
  Open;
 Finally
  FFileName := AStoreFileName;
 End;
End;

Procedure TRESTDWCustomMemTable.Clear;
Begin
 Close;
 FieldDefs.Clear;
 Fields.Clear;
End;

Function TRESTDWCustomMemTable.BookmarkValid(ABookmark: TBookmark): Boolean;
Begin
 Result:=Assigned(CurrentIndexBuf) and CurrentIndexBuf.BookmarkValid(pointer(ABookmark));
End;

{$IFDEF FPC}
Function TRESTDWCustomMemTable.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Longint;
{$ELSE}
Function TRESTDWCustomMemTable.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
{$ENDIF}
Begin
 If Bookmark1 = Bookmark2 Then
  Result := 0
 Else If not assigned(Bookmark1) Then
  Result := 1
 Else If not assigned(Bookmark2) Then
  Result := -1
 Else If assigned(CurrentIndexBuf) Then
  Result := CurrentIndexBuf.CompareBookmarks(pointer(Bookmark1),pointer(Bookmark2))
 Else
  Result := -1;
End;

Procedure TRESTDWCustomMemTable.InitFieldDefsFromPersistentFields;

Var
 I : Integer;
 F : TField;

Begin
 FieldDefs.Clear;
 For I := 0 To Fields.Count - 1 Do
  Begin
   F := Fields[I];
   If F.FieldKind = fkData Then
    TFieldDef.Create(FieldDefs,
                     F.FieldName,
                     F.DataType,
                     F.Size,
                     F.Required,
                     F.FieldNo);
  End;
End;

{$IFDEF FPC}
Procedure TRESTDWCustomMemTable.NormalizeNumericFieldRanges;

Var
 I         : Integer;
 Precision : Integer;
 Scale     : Integer;
 IntDigits : Integer;
 SMin      : String;
 SMax      : String;
 S         : String;
 V         : Extended;
 CMin      : Currency;
 CMax      : Currency;
 F         : TField;

 Function IsZeroValue(Const AValue : String) : Boolean;
 Var
  Z : String;
 Begin
  Z:=Trim(AValue);
  If Z='' Then
   Begin
    Result:=True;
    Exit;
   End;
  Z:=StringReplace(Z,'.',DecimalSeparator,[rfReplaceAll]);
  Z:=StringReplace(Z,',',DecimalSeparator,[rfReplaceAll]);
  Result:=TryStrToFloat(Z,V) and (V=0);
 End;

 Function BuildFMTBCDMax(AField : TFMTBCDField) : String;
 Begin
  Precision:=AField.Precision;
  If Precision<=0 Then
   Precision:=32;
  If Precision>32 Then
   Precision:=32;
  Scale:=AField.Size;
  If Scale<0 Then
   Scale:=0;
  If Scale>Precision Then
   Scale:=Precision;
  IntDigits:=Precision-Scale;
  If IntDigits>0 Then
   Result:=StringOfChar('9',IntDigits)
  Else
   Result:='0';
  If Scale>0 Then
   Result:=Result+DecimalSeparator+StringOfChar('9',Scale);
 End;

Begin
 For I:=0 To Fields.Count-1 Do
  Begin
   F:=Fields[I];
   If F.FieldKind<>fkData Then
    Continue;

   If F is TFMTBCDField Then
    Begin
     SMin:=TFMTBCDField(F).MinValue;
     SMax:=TFMTBCDField(F).MaxValue;
     If IsZeroValue(SMin) and IsZeroValue(SMax) Then
      Begin
       SMax:=BuildFMTBCDMax(TFMTBCDField(F));
       TFMTBCDField(F).MaxValue:=SMax;
       TFMTBCDField(F).MinValue:='-'+SMax;
      End;
    End
   Else If F is TBCDField Then
    Begin
     If (TBCDField(F).MinValue=0) and
        (TBCDField(F).MaxValue=0) Then
      Begin
       S:='922337203685477'+DecimalSeparator+'5807';
       CMax:=StrToCurr(S);
       CMin:=-CMax;
       TBCDField(F).MinValue:=CMin;
       TBCDField(F).MaxValue:=CMax;
      End;
    End
   Else If F is TCurrencyField Then
    Begin
     If (TCurrencyField(F).MinValue=0) and
        (TCurrencyField(F).MaxValue=0) Then
      Begin
       S:='922337203685477'+DecimalSeparator+'5807';
       CMax:=StrToCurr(S);
       CMin:=-CMax;
       TCurrencyField(F).MinValue:=CMin;
       TCurrencyField(F).MaxValue:=CMax;
      End;
    End
   Else If F is TFloatField Then
    Begin
     If (TFloatField(F).MinValue=0) and
        (TFloatField(F).MaxValue=0) Then
      Begin
       TFloatField(F).MinValue:=-1.7976931348623157E308;
       TFloatField(F).MaxValue:=1.7976931348623157E308;
      End;
    End
   Else If F is TLargeintField Then
    Begin
     If (TLargeintField(F).MinValue=0) and
        (TLargeintField(F).MaxValue=0) Then
      Begin
       TLargeintField(F).MinValue:=-9223372036854775808;
       TLargeintField(F).MaxValue:=9223372036854775807;
      End;
    End
   Else If F is TLongintField Then
    Begin
     If (TLongintField(F).MinValue=0) and
        (TLongintField(F).MaxValue=0) Then
      Begin
       Case F.DataType Of
        ftSmallint:
         Begin
          TLongintField(F).MinValue:=-32768;
          TLongintField(F).MaxValue:=32767;
         End;
        ftWord:
         Begin
          TLongintField(F).MinValue:=0;
          TLongintField(F).MaxValue:=65535;
         End;
       Else
        Begin
         TLongintField(F).MinValue:=Low(LongInt);
         TLongintField(F).MaxValue:=High(LongInt);
        End;
       End;
      End;
    End;
  End;
End;
{$ENDIF}

{$IFDEF FPC}
Procedure TRESTDWCustomMemTable.NormalizeFieldDisplayWidths;

Const
 CMaxDisplayWidth = 255;

Var
 I : Integer;
 F : TField;

Begin
 For I:=0 To Fields.Count-1 Do
  Begin
   F:=Fields[I];
   If F.FieldKind<>fkData Then
    Continue;
   Case F.DataType Of
    ftString,
    ftFixedChar,
    ftWideString,
    ftFixedWideChar,
    ftMemo,
    ftWideMemo:
     Begin
      If F.DisplayWidth>CMaxDisplayWidth Then
       F.DisplayWidth:=CMaxDisplayWidth;
     End;
   End;
  End;
End;
{$ENDIF}

Procedure TRESTDWCustomMemTable.IntLoadFieldDefsFromFile;

Begin
 FReadFromFile := True;
 If not assigned(FDatasetReader) Then
  Begin
   FFileStream := TFileStream.Create(FileName, fmOpenRead);
   FDatasetReader := GetPacketReader(dfDefault, FFileStream);
  End;

 FieldDefs.Clear;
 FDatasetReader.LoadFieldDefs(FAutoIncValue);
 If (FieldDefs.Count = 0) and (Fields.Count > 0) Then
  InitFieldDefsFromPersistentFields;
 If DefaultFields Then
  Begin
   CreateFields;
{$IFNDEF FPC}
   BindFields(True);
{$ENDIF}
  End
 Else
  BindFields(True);
End;

Procedure TRESTDWCustomMemTable.IntLoadRecordsFromFile;

Var
 SavedState      : TDataSetState;
 ARowState       : TRESTDWMemRowState;
 AUpdOrder       : integer;
 i               : integer;
 DefIdx : TRESTDWMemInternalIndex;

Begin
 CheckBiDirectional;
 DefIdx:=DefaultBufferIndex;
 FDatasetReader.InitLoadRecords;
 SavedState:=SetTempState(dsFilter);

 While FDatasetReader.GetCurrentRecord Do
  Begin
   ARowState := FDatasetReader.GetRecordRowState(AUpdOrder);
   If rsvOriginal in ARowState Then
    Begin
     If length(FUpdateBuffer) < (AUpdOrder+1) Then
     SetLength(FUpdateBuffer,AUpdOrder+1);
 
     FCurrentUpdateBuffer:=AUpdOrder;
 
     FFilterBuffer:=IntAllocRecordBuffer;
     fillchar(FFilterBuffer^,FNullmaskSize,0);
     FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := FFilterBuffer;
     FDatasetReader.RestoreRecord;
 
     FDatasetReader.GotoNextRecord;
     If not FDatasetReader.GetCurrentRecord Then
     DatabaseError(SStreamNotRecognised,Self);
     ARowState := FDatasetReader.GetRecordRowState(AUpdOrder);
     If rsvUpdated in ARowState Then
     FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind:= ukModify
     Else
     DatabaseError(SStreamNotRecognised,Self);
 
     FFilterBuffer:=DefIdx.SpareBuffer;
     DefIdx.StoreSpareRecIntoBookmark(@FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData);
     fillchar(FFilterBuffer^,FNullmaskSize,0);
 
     FDatasetReader.RestoreRecord;
     DefIdx.AddRecord;
     inc(FBRecordCount);
    End
   Else If rsvDeleted in ARowState Then
    Begin
     If length(FUpdateBuffer) < (AUpdOrder+1) Then
     SetLength(FUpdateBuffer,AUpdOrder+1);
 
     FCurrentUpdateBuffer:=AUpdOrder;
 
     FFilterBuffer:=IntAllocRecordBuffer;
     fillchar(FFilterBuffer^,FNullmaskSize,0);
 
     FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := FFilterBuffer;
     FDatasetReader.RestoreRecord;
 
     FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind:= ukDelete;
     DefIdx.StoreSpareRecIntoBookmark(@FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData);
     DefIdx.AddRecord;
     DefIdx.RemoveRecordFromIndex(FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData);
     DefIdx.StoreSpareRecIntoBookmark(@FUpdateBuffer[FCurrentUpdateBuffer].NextBookmarkData);
 
     For i := FCurrentUpdateBuffer+1 To high(FUpdateBuffer) Do
     If DefIdx.SameBookmarks(@FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData, @FUpdateBuffer[i].NextBookmarkData) Then
      DefIdx.StoreSpareRecIntoBookmark(@FUpdateBuffer[i].NextBookmarkData);
    End
   Else
    Begin
     FFilterBuffer:=DefIdx.SpareBuffer;
     fillchar(FFilterBuffer^,FNullmaskSize,0);
     FDatasetReader.RestoreRecord;
     If rsvInserted in ARowState Then
      Begin
       If length(FUpdateBuffer) < (AUpdOrder+1) Then
       SetLength(FUpdateBuffer,AUpdOrder+1);
       FCurrentUpdateBuffer:=AUpdOrder;
       FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind:= ukInsert;
       DefIdx.StoreSpareRecIntoBookmark(@FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData);
      End;
 
     DefIdx.AddRecord;
     inc(FBRecordCount);
    End;

   FDatasetReader.GotoNextRecord;
  End;

 RestoreState(SavedState);
 DefIdx.SetToFirstRecord;
 FAllPacketsFetched:=True;
 If assigned(FFileStream) Then
  Begin
   FreeAndNil(FFileStream);
   FreeAndNil(FDatasetReader);
  End;

 // rebuild indexes
 BuildIndexes;
End;

Procedure TRESTDWCustomMemTable.DoFilterRecord(out Acceptable: Boolean);
Begin
 Acceptable := true;
 // check user filter
 If Assigned(OnFilterRecord) Then
  OnFilterRecord(Self, Acceptable);

 // check filtertext
 If Acceptable and (Length(Filter) > 0) Then
  Acceptable := Boolean((FParser.ExtractFromBuffer(GetCurrentBuffer))^);
End;

Procedure TRESTDWCustomMemTable.SetFilterText(Const Value: String);
Begin
 If Value = Filter Then
  Exit;

 // parse
 ParseFilter(Value);

 // call dataset method
 Inherited;

 // refilter dataset if filtered
 If IsCursorOpen and Filtered Then
  Resync([]);
End;

Procedure TRESTDWCustomMemTable.SetFiltered(Value: Boolean); {override;}
Begin
 If Value = Filtered Then
  Exit;

 // pass on to ancestor
 Inherited;

 // only refresh if active
 If IsCursorOpen Then
  Resync([]);
End;

Procedure TRESTDWCustomMemTable.InternalRefresh;

Var
 StoreDefaultFields: boolean;

Begin
 If length(FUpdateBuffer)>0 Then
  DatabaseError(SErrApplyUpdBeforeRefresh,Self);
 FRefreshing:=True;
 Try
  StoreDefaultFields:=DefaultFields;
  SetDefaultFields(False);
  FreeFieldBuffers;
  ClearBuffers;
  InternalClose;
  BeforeRefreshOpenCursor;
  InternalOpen;
  SetDefaultFields(StoreDefaultFields);
 Finally
  FRefreshing:=False;
End;
End;

Procedure TRESTDWCustomMemTable.BeforeRefreshOpenCursor;
Begin
 // Do nothing
End;

Procedure TRESTDWCustomMemTable.DataEvent(Event: TDataEvent; Info: TRESTDWPtrInt);
Begin
 If Event = deUpdateState Then
  // Save DataSet.State set by DataSet.SetState (filter out State set by DataSet.SetTempState)
  FSavedState := State;
 Inherited;
End;

Function TRESTDWCustomMemTable.Fetch: boolean;
Begin
 // Empty procedure to make it possible to use TRESTDWCustomMemTable as a memory dataset
 Result := False;
End;

Procedure TRESTDWCustomMemTable.LoadBlobIntoBuffer(FieldDef: TFieldDef;
 ABlobBuf: PRESTDWMemBlobField);
Begin
End;

{$IFNDEF FPC}
Procedure TRESTDWCustomMemTable.InternalHandleException;
Begin
 If ExceptObject Is Exception Then
  Raise Exception.Create(Exception(ExceptObject).Message);
End;
{$ENDIF}

Function TRESTDWCustomMemTable.LoadField(FieldDef: TFieldDef; buffer: pointer; out
 CreateBlob: boolean): boolean;
Begin
 // Empty procedure to make it possible to use TRESTDWCustomMemTable as a memory dataset
 CreateBlob := False;
 Result := False;
End;

Function TRESTDWCustomMemTable.IsReadFromPacket: Boolean;
Begin
 Result := (FDatasetReader<>nil) or (FFileName<>'') or FReadFromFile;
End;

Procedure TRESTDWCustomMemTable.ParseFilter(Const AFilter: string);
Begin
 // parser created?
 If Length(AFilter) > 0 Then
  Begin
   If (FParser = nil) and IsCursorOpen Then
    Begin
     FParser := TRESTDWMemParser.Create(Self);
    End;
   // is there a parser now?
   If FParser <> nil Then
    Begin
     // set options
     FParser.PartialMatch := not (foNoPartialCompare in FilterOptions);
     FParser.CaseInsensitive := foCaseInsensitive in FilterOptions;
     // parse expression
     FParser.ParseExpression(AFilter);
    End;
  End;
End;

Function TRESTDWCustomMemTable.Locate(Const KeyFields: string; Const KeyValues: Variant; Options: TLocateOptions): boolean;

Begin
 Result:=DoLocate(keyfields,KeyValues,Options,True);
End;

Function TRESTDWCustomMemTable.DoLocate(Const KeyFields: string; Const KeyValues: Variant; Options: TLocateOptions; DoEvents : Boolean) : boolean;


Var SearchFields    : TList;
  DBCompareStruct : TRESTDWMemCompareStruct;
  ABookmark       : TRESTDWMemBookmark;
  SavedState      : TDataSetState;
  FilterRecord    : TRecordBuffer;
  FilterAcceptable: boolean;

Begin
 // Call inherited to make sure the dataset is bi-directional
 Result := Inherited Locate(KeyFields,KeyValues,Options);
 CheckActive;
 If IsEmpty Then
  exit;

 // Build the DBCompare structure
 SearchFields := TList.Create;
 Try
  GetFieldList(SearchFields,KeyFields);
  If SearchFields.Count=0 Then
   exit;
  ProcessFieldsToCompareStruct(SearchFields, nil, nil, [], Options, DBCompareStruct);
 Finally
  SearchFields.Free;
End;

 // Set the filter buffer
 SavedState:=SetTempState(dsFilter);
 FilterRecord:=IntAllocRecordBuffer;
 FFilterBuffer:=FilterRecord + BufferOffset;
{$IFDEF FPC}
 SetFieldValues(KeyFields,KeyValues);
{$ELSE}
 RESTDWSetFieldValues(Self, KeyFields, KeyValues);
{$ENDIF}

 // Iterate through the records until a match is found
 ABookmark.BookmarkData:=nil;
 While true Do
  Begin
  // try get next record
   If CurrentIndexBuf.GetRecord(@ABookmark, gmNext) <> grOK Then
   // for grEOF ABookmark points to SpareRecord, which is used for storing next record(s)
   If getnextpacket = 0 Then
    Break;
   If IndexCompareRecords(FilterRecord, ABookmark.BookmarkData, DBCompareStruct) = 0 Then
    Begin
     If Filtered Then
      Begin
       FFilterBuffer:=Pointer(TRESTDWPtrInt(ABookmark.BookmarkData) + BufferOffset);
      // The dataset state is still dsFilter at this point, so we don't have to set it.
       DoFilterRecord(FilterAcceptable);
       If FilterAcceptable Then
        Begin
         Result := True;
         Break;
        End;
      End
     Else
      Begin
       Result := True;
       Break;
      End;
    End;
  End;

 RestoreState(SavedState);
 FreeRecordBuffer(FilterRecord);

 // If a match is found, jump to the found record
 If Result Then
  Begin
   ABookmark.BookmarkFlag := bfCurrent;
   If DoEvents Then
    Begin
     InternalGotoBookmark(@ABookmark);
     Resync([rmExact,rmCenter]);
    End
   Else
    Begin
     InternalGotoBookMark(@ABookmark);
     Resync([rmExact,rmCenter]);
    End;
  End;
End;

Function TRESTDWCustomMemTable.Lookup(Const KeyFields: string;
 Const KeyValues: Variant; Const ResultFields: string): Variant;
Var
 bm:TBookmark;
Begin
 result:=Null;
 If IsEmpty Then
  Exit;
 bm:=GetBookmark;
 DisableControls;
 Try
  If DoLocate(KeyFields,KeyValues,[],False) Then
   Begin
   //  CalculateFields(ActiveBuffer); // not needed, done by Locate more than once
    result:=FieldValues[ResultFields];
   End;
  InternalGotoBookMark(pointer(bm));
  Resync([rmExact,rmCenter]);
  FreeBookmark(bm);
 Finally
  EnableControls;
End;
End;

{ TRESTDWMemArrayIndex }

Function TRESTDWMemArrayIndex.GetBookmarkSize: integer;
Begin
 Result:=Sizeof(TRESTDWMemBookmark);
End;

Function TRESTDWMemArrayIndex.GetCurrentBuffer: Pointer;
Begin
 Result:=TRecordBuffer(FRecordArray[FCurrentRecInd]);
End;

Function TRESTDWMemArrayIndex.GetCurrentRecord:  TRecordBuffer;
Begin
 Result:=GetCurrentBuffer;
End;

Function TRESTDWMemArrayIndex.GetIsInitialized: boolean;
Begin
 Result:=Length(FRecordArray)>0;
End;

Function TRESTDWMemArrayIndex.GetSpareBuffer:  TRecordBuffer;
Begin
 If FLastRecInd>-1 Then
  Result:= TRecordBuffer(FRecordArray[FLastRecInd])
 Else
  Result := nil;
End;

Function TRESTDWMemArrayIndex.GetSpareRecord:  TRecordBuffer;
Begin
 Result := GetSpareBuffer;
End;

Constructor TRESTDWMemArrayIndex.Create(Const ADataset: TRESTDWCustomMemTable);
Begin
 Inherited create(ADataset);
 FInitialBuffers:=10000;
 FGrowBuffer:=1000;
End;

Function TRESTDWMemArrayIndex.ScrollBackward: TGetResult;
Begin
 If FCurrentRecInd>0 Then
  Begin
   dec(FCurrentRecInd);
   Result := grOK;
  End
 Else
  Result := grBOF;
End;

Function TRESTDWMemArrayIndex.ScrollForward: TGetResult;
Begin
 If FCurrentRecInd = FLastRecInd-1 Then
  result := grEOF
 Else
  Begin
   Result:=grOK;
   inc(FCurrentRecInd);
  End;
End;

Function TRESTDWMemArrayIndex.GetCurrent: TGetResult;
Begin
 If FLastRecInd=0 Then
  Result := grError
 Else
  Begin
   Result := grOK;
   If FCurrentRecInd = FLastRecInd Then
   dec(FCurrentRecInd);
  End;
End;

Function TRESTDWMemArrayIndex.ScrollFirst: TGetResult;
Begin
 FCurrentRecInd:=0;
 If (FCurrentRecInd = FLastRecInd) Then
  result := grEOF
 Else
  result := grOk;
End;

Procedure TRESTDWMemArrayIndex.ScrollLast;
Begin
 FCurrentRecInd:=FLastRecInd;
End;

Procedure TRESTDWMemArrayIndex.SetToFirstRecord;
Begin
 // if FCurrentRecBuf = FLastRecBuf then the dataset is just opened and empty
 // in which case InternalFirst should do nothing (bug 7211)
 If FCurrentRecInd <> FLastRecInd Then
  FCurrentRecInd := -1;
End;

Procedure TRESTDWMemArrayIndex.SetToLastRecord;
Begin
 If FLastRecInd <> 0 Then
  FCurrentRecInd := FLastRecInd;
End;

Procedure TRESTDWMemArrayIndex.StoreCurrentRecord;
Begin
 FStoredRecBuf := FCurrentRecInd;
End;

Procedure TRESTDWMemArrayIndex.RestoreCurrentRecord;
Begin
 FCurrentRecInd := FStoredRecBuf;
End;

Function TRESTDWMemArrayIndex.CanScrollForward: Boolean;
Begin
 Result := (FCurrentRecInd < FLastRecInd-1);
End;

Procedure TRESTDWMemArrayIndex.DoScrollForward;
Begin
 inc(FCurrentRecInd);
End;

Procedure TRESTDWMemArrayIndex.StoreCurrentRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark);
Begin
 With ABookmark^ Do
  Begin
   BookmarkInt := FCurrentRecInd;
   BookmarkData := FRecordArray[FCurrentRecInd];
  End;
End;

Procedure TRESTDWMemArrayIndex.StoreSpareRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark
 );
Begin
 With ABookmark^ Do
  Begin
   BookmarkInt := FLastRecInd;
   BookmarkData := FRecordArray[FLastRecInd];
  End;
End;

Function TRESTDWMemArrayIndex.GetRecordFromBookmark(ABookmark: TRESTDWMemBookmark): integer;
Begin
 // ABookmark.BookMarkBuf is nil if SetRecNo calls GotoBookmark
 If (ABookmark.BookmarkData<>nil) and (FRecordArray[ABookmark.BookmarkInt]<>ABookmark.BookmarkData) Then
  Begin
  // Start searching two records before the expected record
   If ABookmark.BookmarkInt > 2 Then
   Result := ABookmark.BookmarkInt-2
   Else
   Result := 0;

   While (Result<FLastRecInd) Do
    Begin
     If (FRecordArray[Result] = ABookmark.BookmarkData) Then
      exit;
     inc(Result);
    End;

   Result:=0;
   While (Result<ABookmark.BookmarkInt) Do
    Begin
     If (FRecordArray[Result] = ABookmark.BookmarkData) Then
      exit;
     inc(Result);
    End;

   DatabaseError(SInvalidBookmark,Self.FDataset)
  End
 Else
  Result := ABookmark.BookmarkInt;
End;

Procedure TRESTDWMemArrayIndex.GotoBookmark(Const ABookmark : PRESTDWMemBookmark);
Begin
 FCurrentRecInd:=GetRecordFromBookmark(ABookmark^);
End;

Procedure TRESTDWMemArrayIndex.InitialiseIndex;
Begin
 //  FRecordArray:=nil;
 setlength(FRecordArray,FInitialBuffers);
 FCurrentRecInd:=-1;
 FLastRecInd:=-1;
End;

Procedure TRESTDWMemArrayIndex.InitialiseSpareRecord(Const ASpareRecord:  TRecordBuffer);
Begin
 FLastRecInd := 0;
 // FCurrentRecInd := 0;
 FRecordArray[0] := ASpareRecord;
End;

Procedure TRESTDWMemArrayIndex.ReleaseSpareRecord;
Begin
 SetLength(FRecordArray,FInitialBuffers);
End;

Function TRESTDWMemArrayIndex.GetRecNo: Longint;
Begin
 Result := FCurrentRecInd+1;
End;

Procedure TRESTDWMemArrayIndex.SetRecNo(ARecNo: Longint);
Begin
 FCurrentRecInd := ARecNo-1;
End;

Procedure TRESTDWMemArrayIndex.InsertRecordBeforeCurrentRecord(Const ARecord:  TRecordBuffer);
Begin
 inc(FLastRecInd);
 If FLastRecInd >= length(FRecordArray) Then
  SetLength(FRecordArray,length(FRecordArray)+FGrowBuffer);

 Move(FRecordArray[FCurrentRecInd],FRecordArray[FCurrentRecInd+1],sizeof(Pointer)*(FLastRecInd-FCurrentRecInd));
 FRecordArray[FCurrentRecInd]:=ARecord;
 inc(FCurrentRecInd);
End;

Procedure TRESTDWMemArrayIndex.RemoveRecordFromIndex(Const ABookmark : TRESTDWMemBookmark);
Var ARecordInd : integer;
Begin
 ARecordInd:=GetRecordFromBookmark(ABookmark);
 Move(FRecordArray[ARecordInd+1],FRecordArray[ARecordInd],sizeof(Pointer)*(FLastRecInd-ARecordInd));
 dec(FLastRecInd);
End;

Procedure TRESTDWMemArrayIndex.BeginUpdate;
Begin
 //  inherited BeginUpdate;
End;

Procedure TRESTDWMemArrayIndex.AddRecord;
Var ARecord:  TRecordBuffer;
Begin
 ARecord := FDataset.IntAllocRecordBuffer;
 inc(FLastRecInd);
 If FLastRecInd >= length(FRecordArray) Then
  SetLength(FRecordArray,length(FRecordArray)+FGrowBuffer);
 FRecordArray[FLastRecInd]:=ARecord;
End;

Procedure TRESTDWMemArrayIndex.EndUpdate;
Begin
 //  inherited EndUpdate;
End;


{ TRESTDWMemDataPacketReader }

Class Function TRESTDWMemDataPacketReader.RowStateToByte(Const ARowState: TRESTDWMemRowState
 ): byte;
Var RowStateInt : Byte;
Begin
 RowStateInt:=0;
 If rsvOriginal in ARowState Then
  RowStateInt := RowStateInt+1;
 If rsvDeleted in ARowState Then
  RowStateInt := RowStateInt+2;
 If rsvInserted in ARowState Then
  RowStateInt := RowStateInt+4;
 If rsvUpdated in ARowState Then
  RowStateInt := RowStateInt+8;
 Result := RowStateInt;
End;

Class Function TRESTDWMemDataPacketReader.ByteToRowState(Const AByte: Byte): TRESTDWMemRowState;
Begin
 result := [];
 If (AByte and 1)=1 Then
  Result := Result+[rsvOriginal];
 If (AByte and 2)=2 Then
  Result := Result+[rsvDeleted];
 If (AByte and 4)=4 Then
  Result := Result+[rsvInserted];
 If (AByte and 8)=8 Then
  Result := Result+[rsvUpdated];
End;

Procedure TRESTDWMemDataPacketReader.RestoreBlobField(AField: TField; ASource: pointer; ASize: integer);
Var
 ABufBlobField: TRESTDWMemBlobField;
Begin
 ABufBlobField.BlobBuffer:=FDataSet.GetNewBlobBuffer;
 ABufBlobField.BlobBuffer^.Size:=ASize;
 ReAllocMem(ABufBlobField.BlobBuffer^.Buffer, ASize);
 move(ASource^, ABufBlobField.BlobBuffer^.Buffer^, ASize);
 AField.SetData(@ABufBlobField);
End;

Constructor TRESTDWMemDataPacketReader.Create(ADataSet: TRESTDWCustomMemTable; AStream: TStream);
Begin
 FDataSet := ADataSet;
 FStream := AStream;
End;


{ TRESTDWBinaryPacketWriter }

Constructor TRESTDWBinaryPacketWriter.Create(AStream: TStream);
Begin
 Inherited Create;
 FStream := AStream;
{$IFDEF RESTDWLAZARUS}
 FDatabaseCharSet := csUndefined;
{$ENDIF}
End;

Procedure TRESTDWBinaryPacketWriter.ClearFieldDefs;
Begin
 SetLength(FFields, 0);
 SetLength(FNullBitmap, 0);
 FNullBitmapSize := 0;
End;

Procedure TRESTDWBinaryPacketWriter.AddFieldDef(Const AName, ADisplayName: String;
 ASize: Word; ADataType: TFieldType; AReadOnly: Boolean);
Var
 I: Integer;
Begin
 I := Length(FFields);
 SetLength(FFields, I + 1);
 FFields[I].Name := AName;
 FFields[I].DisplayName := ADisplayName;
 FFields[I].Size := ASize;
 If FieldTypeToDWFieldType(ADataType) In [dwftTimeStamp, dwftOraTimeStamp,
                                          dwftTimeStampOffset] Then
  FFields[I].DataType := ftDateTime
 Else
  FFields[I].DataType := ADataType;
 FFields[I].ReadOnly := AReadOnly;
End;

Procedure TRESTDWBinaryPacketWriter.WriteAnsiString(Const AValue: AnsiString);
Var
 L: LongWord;
Begin
 L := Length(AValue);
 FStream.WriteBuffer(L, SizeOf(L));
 If L > 0 Then
  FStream.WriteBuffer(AValue[1], L);
End;

Class Function TRESTDWBinaryPacketWriter.IsStringField(AType: TFieldType): Boolean;
Begin
 Result := AType in [ftString, ftFixedChar, ftWideString, ftFixedWideChar];
End;

Class Function TRESTDWBinaryPacketWriter.IsVariableField(AType: TFieldType): Boolean;
Begin
 Result := IsStringField(AType) or
  (AType in [ftBlob, ftMemo, ftGraphic, ftWideMemo, ftBytes, ftVarBytes]);
End;

Procedure TRESTDWBinaryPacketWriter.StoreFieldDefs(AnAutoIncValue: Integer);
Const
 Ident: AnsiString = 'BinRESTDWDataSet';
Var
 I: Integer;
 W: Word;
 B: Byte;
Begin
 FStream.WriteBuffer(Ident[1], Length(Ident));
 B := 20;
 FStream.WriteBuffer(B, SizeOf(B));
 W := Length(FFields);
 FStream.WriteBuffer(W, SizeOf(W));
 For I := 0 To Length(FFields) - 1 Do
  Begin
   WriteAnsiString(AnsiString(FFields[I].Name));
   WriteAnsiString(AnsiString(FFields[I].DisplayName));
   FStream.WriteBuffer(FFields[I].Size, SizeOf(Word));
   B := 0;
   W := FieldTypeToDWFieldType(FFields[I].DataType);
   Case W Of
    dwftTimeStamp,
    dwftOraTimeStamp,
    dwftTimeStampOffset: W := dwftDateTime;
   End;
   FStream.WriteBuffer(W, SizeOf(W));
   If FFields[I].ReadOnly Then
    B := 1;
   FStream.WriteBuffer(B, SizeOf(B));
  End;
 FStream.WriteBuffer(AnAutoIncValue, SizeOf(AnAutoIncValue));
 FNullBitmapSize := (Length(FFields) + 7) div 8;
 SetLength(FNullBitmap, FNullBitmapSize);
End;

Procedure TRESTDWBinaryPacketWriter.BeginRecord;
Var
 B: Byte;
Begin
 B := $FE;
 FStream.WriteBuffer(B, SizeOf(B));
 B := 0;
 FStream.WriteBuffer(B, SizeOf(B));
 If FNullBitmapSize > 0 Then
  Begin
   FillChar(FNullBitmap[0], FNullBitmapSize, 0);
   FNullBitmapPosition := FStream.Position;
   FStream.WriteBuffer(FNullBitmap[0], FNullBitmapSize);
  End;
End;

Procedure TRESTDWBinaryPacketWriter.StoreNull(AFieldIndex: Integer);
Begin
 If (AFieldIndex >= 0) and (AFieldIndex < Length(FFields)) and
   (FNullBitmapSize > 0) Then
  FNullBitmap[AFieldIndex div 8] := FNullBitmap[AFieldIndex div 8] or
   Byte(1 shl (AFieldIndex mod 8));
End;

Procedure TRESTDWBinaryPacketWriter.StoreField(AFieldIndex: Integer;
 ABuffer: Pointer; ASize: LongWord);
Var
 L: LongWord;
{$IFDEF RESTDWLAZARUS}
 S: AnsiString;
{$ENDIF}
Begin
 If (AFieldIndex < 0) or (AFieldIndex >= Length(FFields)) Then
  Exit;
{$IFDEF RESTDWLAZARUS}
 If FFields[AFieldIndex].DataType In [ftString, ftFixedChar, ftWideString, ftFixedWideChar, ftMemo, ftWideMemo] Then
  Begin
   SetLength(S, ASize);
   If (ASize > 0) And (ABuffer <> Nil) Then
    Move(ABuffer^, S[1], ASize);
   S := AnsiString(GetStringEncode(String(S), FDatabaseCharSet));
   ASize := Length(S);
   If ASize > 0 Then
    ABuffer := @S[1]
   Else
    ABuffer := Nil;
  End;
{$ENDIF}
 If IsVariableField(FFields[AFieldIndex].DataType) Then
  Begin
   L := ASize;
   FStream.WriteBuffer(L, SizeOf(L));
  End;
 If (ASize > 0) and (ABuffer <> nil) Then
  FStream.WriteBuffer(ABuffer^, ASize);
End;

Procedure TRESTDWBinaryPacketWriter.EndRecord;
Var
 P: Int64;
Begin
 If FNullBitmapSize = 0 Then
  Exit;
 P := FStream.Position;
 FStream.Position := FNullBitmapPosition;
 FStream.WriteBuffer(FNullBitmap[0], FNullBitmapSize);
 FStream.Position := P;
End;

{ TRESTDWTBinaryDatapacketReader }

Function TRESTDWTBinaryDatapacketReader.ReadByteValue: Byte;
Begin
 Stream.ReadBuffer(Result, SizeOf(Result));
End;
Function TRESTDWTBinaryDatapacketReader.ReadWordValue: Word;
Begin
 Stream.ReadBuffer(Result, SizeOf(Result));
End;

Function TRESTDWTBinaryDatapacketReader.ReadDWordValue: LongWord;
Begin
 Stream.ReadBuffer(Result, SizeOf(Result));
End;

Function TRESTDWTBinaryDatapacketReader.ReadAnsiStringValue: AnsiString;
Var
 L         : LongWord;
 LRemaining: Int64;
Begin
 L := ReadDWordValue;
 LRemaining := Stream.Size - Stream.Position;
 If Int64(L) > LRemaining Then
  Raise Exception.Create('Invalid binary packet string length ' + IntToStr(L) +
                         ' at position ' + IntToStr(Stream.Position - SizeOf(L)) +
                         ', remaining ' + IntToStr(LRemaining));
 SetLength(Result,L);
 If L > 0 Then
  Stream.ReadBuffer(Result[1],L);
End;
Function TRESTDWTBinaryDatapacketReader.GetFixedWireSize(AWireType: Byte; AField: TField): Cardinal;
Begin
 Case AWireType Of
  dwftSmallint: Result := SizeOf(SmallInt);
  dwftInteger: Result := SizeOf(Integer);
  dwftWord: Result := SizeOf(Word);
  dwftBoolean: Result := SizeOf(WordBool);
  dwftFloat: Result := SizeOf(Double);
  dwftCurrency,
  dwftBCD: Result := SizeOf(Currency);
  dwftDate,
  dwftTime: Result := SizeOf(Integer);
  dwftDateTime,
  dwftTimeStamp,
  dwftOraTimeStamp,
  dwftTimeStampOffset: Result := SizeOf(TDateTime);
  dwftLargeint,
  dwftAutoInc: Result := SizeOf(Int64);
  dwftExtended: Result := SizeOf(Double);
  dwftFMTBcd: Result := SizeOf(TBcd);
  dwftGuid: Result := SizeOf(TGUID);
 Else
  Result := AField.DataSize;
 End;
End;
Procedure TRESTDWTBinaryDatapacketReader.WriteByteValue(AValue: Byte);
Begin
 Stream.WriteBuffer(AValue, SizeOf(AValue));
End;
Procedure TRESTDWTBinaryDatapacketReader.WriteWordValue(AValue: Word);
Begin
 Stream.WriteBuffer(AValue, SizeOf(AValue));
End;
Procedure TRESTDWTBinaryDatapacketReader.WriteDWordValue(AValue: LongWord);
Begin
 Stream.WriteBuffer(AValue, SizeOf(AValue));
End;
Procedure TRESTDWTBinaryDatapacketReader.WriteAnsiStringValue(Const AValue: AnsiString);
Var L: LongWord;
Begin
 L := Length(AValue);
 WriteDWordValue(L);
 If L > 0 Then
  Stream.WriteBuffer(AValue[1], L);
End;

Constructor TRESTDWTBinaryDatapacketReader.Create(ADataSet: TRESTDWCustomMemTable; AStream: TStream);
Begin
 Inherited;
 FVersion := 20; // default version 2.0
End;

Procedure TRESTDWTBinaryDatapacketReader.LoadFieldDefs(Var AnAutoIncValue: integer);

Var FldCount : word;
i        : integer;
W        : Word;
s        : AnsiString;
{$IFNDEF FPC}
AFieldDef : TFieldDef;
{$ENDIF}

Begin
 // Identify version
 SetLength(s, Length(RESTDWBinaryIdent));
 If (Stream.Read(s[1], Length(RESTDWBinaryIdent)) = Length(RESTDWBinaryIdent)) And
    (s = RESTDWBinaryIdent) Then
  FVersion := ReadByteValue
 Else
  DatabaseError(SStreamNotRecognised,Self.FDataset);

 // Read FieldDefs
 FldCount := ReadWordValue;
 If (Stream.Size - Stream.Position) < (Int64(FldCount) * 13 + SizeOf(Integer)) Then
  Raise Exception.Create('Invalid binary packet field count ' + IntToStr(FldCount) +
                         ' at position ' + IntToStr(Stream.Position - SizeOf(FldCount)) +
                         ', remaining ' + IntToStr(Stream.Size - Stream.Position));
 DataSet.FieldDefs.Clear;
 SetLength(FWireFieldTypes, FldCount);
 For i := 0 To FldCount - 1 Do
  Begin
{$IFDEF FPC}
   With DataSet.FieldDefs.AddFieldDef Do
{$ELSE}
   AFieldDef := TFieldDef.Create(DataSet.FieldDefs,'',ftUnknown,0,False,i + 1);
   With AFieldDef Do
{$ENDIF}
    Begin
     Name := ReadAnsiStringValue;
     Displayname := ReadAnsiStringValue;
     Size := ReadWordValue;
     W := ReadWordValue;
     If W > 255 Then
      Raise Exception.Create('Invalid binary packet field type ' + IntToStr(W) +
                             ' at position ' + IntToStr(Stream.Position - SizeOf(W)));
     FWireFieldTypes[I] := Byte(W);
     Case FWireFieldTypes[I] Of
      dwftTimeStamp,
      dwftOraTimeStamp,
      dwftTimeStampOffset: DataType := ftDateTime;
     Else
      DataType := DWFieldTypeToFieldType(FWireFieldTypes[I]);
     End;
{$IFNDEF FPC}
      Case DataType Of
       ftBCD:
        Begin
         Precision := 18;
        End;
       ftFMTBcd:
        Begin
         Precision := 32;
        End;
      End;
{$ENDIF}

     If ReadByteValue = 1 Then
     Attributes := Attributes + [faReadonly];
    End;
  End;
 Stream.ReadBuffer(i,sizeof(i));
 AnAutoIncValue := i;

 FNullBitmapSize := (FldCount + 7) div 8;
 SetLength(FNullBitmap, FNullBitmapSize);
End;

Procedure TRESTDWTBinaryDatapacketReader.StoreFieldDefs(AnAutoIncValue: integer);
Var i : integer;
Begin
 Stream.Write(RESTDWBinaryIdent[1], Length(RESTDWBinaryIdent));
 WriteByteValue(FVersion);

 WriteWordValue(DataSet.FieldDefs.Count);
 SetLength(FWireFieldTypes, DataSet.FieldDefs.Count);
 For i := 0 To DataSet.FieldDefs.Count - 1 Do With DataSet.FieldDefs[i] Do
  Begin
   WriteAnsiStringValue(Name);
   WriteAnsiStringValue(DisplayName);
   WriteWordValue(Size);
   FWireFieldTypes[I] := FieldTypeToDWFieldType(DataType);
   Case FWireFieldTypes[I] Of
    dwftTimeStamp,
    dwftOraTimeStamp,
    dwftTimeStampOffset: FWireFieldTypes[I] := dwftDateTime;
   End;
   WriteWordValue(FWireFieldTypes[I]);
 
   If faReadonly in Attributes Then
   WriteByteValue(1)
   Else
   WriteByteValue(0);
  End;
 i := AnAutoIncValue;
 Stream.WriteBuffer(i,sizeof(i));

 FNullBitmapSize := (DataSet.FieldDefs.Count + 7) div 8;
 SetLength(FNullBitmap, FNullBitmapSize);
End;

Procedure TRESTDWTBinaryDatapacketReader.InitLoadRecords;
Begin
 //  Do nothing
End;

Function TRESTDWTBinaryDatapacketReader.GetCurrentRecord: boolean;
Var
 Buf      : Byte;
 ReadSize : Integer;
Begin
 ReadSize := Stream.Read(Buf, 1);
 Result := ReadSize = 1;
 If Not Result Then
  Exit;
 If Buf <> $FE Then
  Raise Exception.Create('Invalid binary packet record marker ' + IntToStr(Buf) +
                         ' at position ' + IntToStr(Stream.Position - 1) +
                         ', remaining ' + IntToStr(Stream.Size - Stream.Position));
End;

Function TRESTDWTBinaryDatapacketReader.GetRecordRowState(out AUpdOrder : Integer) : TRESTDWMemRowState;
Var Buf : byte;
Begin
 Stream.Read(Buf,1);
 Result := ByteToRowState(Buf);
 If Result<>[] Then
 Stream.ReadBuffer(AUpdOrder,sizeof(integer))
 Else
 AUpdOrder := 0;
End;

Procedure TRESTDWTBinaryDatapacketReader.GotoNextRecord;
Begin
 //  Do Nothing
End;

Procedure TRESTDWTBinaryDatapacketReader.RestoreRecord;

Var
 AField    : TField;
 I         : Integer;
 J         : Integer;
 L         : Cardinal;
 B         : TRESTDWMemBytes;
 VDateTime : TDateTime;
 VDouble   : Double;
 VCurrency : Currency;
 VBcd      : TBcd;
{$IFDEF FPC}
 VWireValue : Integer;
{$ENDIF}
{$IFDEF DELPHI2010UP}
 VTimeStamp       : TSQLTimeStamp;
 VTimeStampOffset : TSQLTimeStampOffset;
{$ENDIF}
{$IFDEF RESTDWLAZARUS}
 SText : AnsiString;
{$ENDIF}

Begin
 With DataSet Do
  Case FVersion Of
   10:
    Stream.ReadBuffer(GetCurrentBuffer^, FRecordSize);
   20:
    Begin
     Stream.ReadBuffer(FNullBitmap[0], FNullBitmapSize);
     For I:=0 To FieldDefs.Count-1 Do
      Begin
       AField:=Fields.FieldByNumber(FieldDefs[I].FieldNo);
       If AField=Nil Then
        Continue;
       If GetFieldIsNull(PByte(FNullBitmap),I) Then
        SetFieldDataPtr(AField,Nil)
       Else If AField.DataType in StringFieldTypes Then
{$IFDEF RESTDWLAZARUS}
        AField.AsString:=GetStringEncode(String(ReadAnsiStringValue),DatabaseCharSet)
{$ELSE}
        AField.AsString:=ReadAnsiStringValue
{$ENDIF}
       Else If (I<Length(FWireFieldTypes)) and
               (FWireFieldTypes[I]=dwftBCD) Then
        Begin
         Stream.ReadBuffer(VCurrency,SizeOf(VCurrency));
         AField.AsCurrency:=VCurrency;
        End
       Else If (I<Length(FWireFieldTypes)) and
               (FWireFieldTypes[I]=dwftFMTBcd) Then
        Begin
         Stream.ReadBuffer(VBcd,SizeOf(VBcd));
         AField.AsBCD:=VBcd;
        End
{$IFDEF FPC}
       Else If (I<Length(FWireFieldTypes)) and
               (FWireFieldTypes[I]=dwftDate) Then
        Begin
         Stream.ReadBuffer(VWireValue,SizeOf(VWireValue));
         AField.AsDateTime:=TDateTime(VWireValue-693594);
        End
       Else If (I<Length(FWireFieldTypes)) and
               (FWireFieldTypes[I]=dwftTime) Then
        Begin
         Stream.ReadBuffer(VWireValue,SizeOf(VWireValue));
         AField.AsDateTime:=VWireValue/86400000.0;
        End
{$ENDIF}
       Else If (I<Length(FWireFieldTypes)) and
               (FWireFieldTypes[I]=dwftExtended) Then
        Begin
         Stream.ReadBuffer(VDouble,SizeOf(VDouble));
{$IFDEF FPC}
         AField.AsFloat:=VDouble;
{$ELSE}
 {$IFDEF DELPHI2010UP}
         If AField.DataType=ftExtended Then
          AField.AsExtended:=VDouble
         Else
 {$ENDIF}
         AField.AsFloat:=VDouble;
{$ENDIF}
        End
       Else If (I<Length(FWireFieldTypes)) and
               (FWireFieldTypes[I] in [dwftDateTime,
                                        dwftTimeStamp,
                                        dwftOraTimeStamp,
                                        dwftTimeStampOffset]) Then
        Begin
         Stream.ReadBuffer(VDateTime,SizeOf(VDateTime));
{$IFDEF DELPHI2010UP}
         Case AField.DataType Of
          ftTimeStamp,
          ftOraTimeStamp:
           Begin
            VTimeStamp:=DateTimeToSQLTimeStamp(VDateTime);
            SetFieldDataPtr(AField,@VTimeStamp);
           End;
          ftTimeStampOffset:
           Begin
            VTimeStampOffset:=DateTimeToSQLTimeStampOffset(VDateTime);
            SetFieldDataPtr(AField,@VTimeStampOffset);
           End;
         Else
          AField.AsDateTime:=VDateTime;
         End;
{$ELSE}
         AField.AsDateTime:=VDateTime;
{$ENDIF}
        End
       Else
        Begin
         If AField.DataType in VarLenFieldTypes Then
          L:=ReadDWordValue
         Else
          L:=GetFixedWireSize(FWireFieldTypes[I],AField);
         If Int64(L)>(Stream.Size-Stream.Position) Then
          Raise Exception.Create('Invalid binary packet field size '+IntToStr(L)+
                                 ' at position '+IntToStr(Stream.Position)+
                                 ', remaining '+IntToStr(Stream.Size-Stream.Position));
         SetLength(B,L);
         If L>0 Then
          Stream.ReadBuffer(B[0],L);
         If AField.DataType in BlobFieldTypes Then
          Begin
{$IFDEF RESTDWLAZARUS}
           If AField.DataType in [ftMemo,ftWideMemo] Then
            Begin
             SetLength(SText,L);
             If L>0 Then
              Move(B[0],SText[1],L);
             SText:=AnsiString(GetStringEncode(String(SText),DatabaseCharSet));
             If Length(SText)>0 Then
              RestoreBlobField(AField,@SText[1],Length(SText))
             Else
              RestoreBlobField(AField,Nil,0);
            End
           Else
{$ENDIF}
            If L>0 Then
             RestoreBlobField(AField,@B[0],L)
            Else
             RestoreBlobField(AField,Nil,0);
          End
         Else If L>0 Then
          SetFieldDataPtr(AField,@B[0])
         Else
          SetFieldDataPtr(AField,Nil);
        End;
      End;
    End;
  End;
End;

Procedure TRESTDWTBinaryDatapacketReader.StoreRecord(ARowState : TRESTDWMemRowState; AUpdOrder : Integer);
Var
AField    : TField;
I         : Integer;
L         : Cardinal;
B         : TRESTDWMemBytes;
VDateTime : TDateTime;
VDouble   : Double;
VCurrency  : Currency;
VBcd       : TBcd;
{$IFDEF FPC}
VWireValue : Integer;
VDateStamp : TTimeStamp;
{$ENDIF}
{$IFDEF RESTDWLAZARUS}
SText     : AnsiString;
{$ENDIF}
Begin
 WriteByteValue($FE);
 WriteByteValue(RowStateToByte(ARowState));
 If ARowState <> [] Then
 Stream.WriteBuffer(AUpdOrder, SizeOf(Integer));

 With DataSet Do
 Case FVersion Of
 10 : Stream.WriteBuffer(GetCurrentBuffer^, FRecordSize);
 20 : Begin
 FillChar(FNullBitmap[0], FNullBitmapSize, 0);
 For I := 0 To FieldDefs.Count - 1 Do
  Begin
   AField := Fields.FieldByNumber(FieldDefs[I].FieldNo);
   If Assigned(AField) And AField.IsNull Then
   SetFieldIsNull(PByte(FNullBitmap), I);
  End;
 Stream.WriteBuffer(FNullBitmap[0], FNullBitmapSize);

 For I := 0 To FieldDefs.Count - 1 Do
  Begin
   AField := Fields.FieldByNumber(FieldDefs[I].FieldNo);
   If Not Assigned(AField) Or AField.IsNull Then
   Continue;
   If AField.DataType In StringFieldTypes Then
{$IFDEF RESTDWLAZARUS}
   WriteAnsiStringValue(AnsiString(GetStringEncode(AField.AsString, DatabaseCharSet)))
{$ELSE}
   WriteAnsiStringValue(AField.AsString)
{$ENDIF}
    Else If (I < Length(FWireFieldTypes)) And
            (FWireFieldTypes[I] = dwftBCD) Then
     Begin
      VCurrency := AField.AsCurrency;
      Stream.WriteBuffer(VCurrency, SizeOf(VCurrency));
     End
    Else If (I < Length(FWireFieldTypes)) And
            (FWireFieldTypes[I] = dwftFMTBcd) Then
     Begin
      VBcd := AField.AsBCD;
      Stream.WriteBuffer(VBcd, SizeOf(VBcd));
     End
{$IFDEF FPC}
    Else If (I < Length(FWireFieldTypes)) And
            (FWireFieldTypes[I] = dwftDate) Then
     Begin
      VWireValue := Trunc(AField.AsDateTime) + 693594;
      Stream.WriteBuffer(VWireValue, SizeOf(VWireValue));
     End
    Else If (I < Length(FWireFieldTypes)) And
            (FWireFieldTypes[I] = dwftTime) Then
     Begin
      VDateStamp := DateTimeToTimeStamp(AField.AsDateTime);
      VWireValue := VDateStamp.Time;
      Stream.WriteBuffer(VWireValue, SizeOf(VWireValue));
     End
{$ENDIF}

   Else If (I < Length(FWireFieldTypes)) And
           (FWireFieldTypes[I] = dwftExtended) Then
    Begin
{$IFDEF FPC}
     VDouble := AField.AsFloat;
{$ELSE}
 {$IFDEF DELPHI2010UP}
     If AField.DataType = ftExtended Then
      VDouble := AField.AsExtended
     Else
 {$ENDIF}
     VDouble := AField.AsFloat;
{$ENDIF}
     Stream.WriteBuffer(VDouble, SizeOf(VDouble));
    End
   Else If (I < Length(FWireFieldTypes)) And
           (FWireFieldTypes[I] = dwftDateTime) Then
    Begin
     VDateTime := AField.AsDateTime;
     Stream.WriteBuffer(VDateTime, SizeOf(VDateTime));
    End
   Else
    Begin
     L := Length(AField.AsBytes);
     SetLength(B, L);
     If L > 0 Then
      Move(AField.AsBytes[0], B[0], L);
{$IFDEF RESTDWLAZARUS}
     If AField.DataType In [ftMemo, ftWideMemo] Then
      Begin
       SetLength(SText, L);
       If L > 0 Then
        Move(B[0], SText[1], L);
       SText := AnsiString(GetStringEncode(String(SText), DatabaseCharSet));
       L := Length(SText);
       SetLength(B, L);
       If L > 0 Then
        Move(SText[1], B[0], L);
      End;
{$ENDIF}
     If AField.DataType In VarLenFieldTypes Then
     WriteDWordValue(L);
     If L > 0 Then
     Stream.WriteBuffer(B[0], L);
    End;
  End;
End;
    End;
   End;

Procedure TRESTDWTBinaryDatapacketReader.FinalizeStoreRecords;
Begin
 //  Do nothing
End;

Class Function TRESTDWTBinaryDatapacketReader.RecognizeStream(AStream: TStream): boolean;
Var
 s         : AnsiString;
 APosition : Int64;
Begin
 Result := False;
 APosition := AStream.Position;
 Try
  SetLength(s, Length(RESTDWBinaryIdent));
  If AStream.Read(s[1], Length(RESTDWBinaryIdent)) = Length(RESTDWBinaryIdent) Then
   Result := s = RESTDWBinaryIdent;
 Finally
  AStream.Position := APosition;
 End;
End;

{ TRESTDWMemUniDirectionalIndex }

Function TRESTDWMemUniDirectionalIndex.GetBookmarkSize: integer;
Begin
 // In principle there are no bookmarks, and the size should be 0.
 // But there is quite some code in TRESTDWCustomMemTable that relies on
 // an existing bookmark of the TRESTDWMemBookmark type.
 // This code could be moved to the TRESTDWMemInternalIndex but that would make things
 // more complicated and probably slower. So use a 'fake' bookmark of
 // size TRESTDWMemBookmark.
 // When there are other TRESTDWMemIndexes which also need special bookmark code
 // this can be adapted.
 Result:=sizeof(TRESTDWMemBookmark);
End;

Function TRESTDWMemUniDirectionalIndex.GetCurrentBuffer: Pointer;
Begin
 result := FSPareBuffer;
End;

Function TRESTDWMemUniDirectionalIndex.GetCurrentRecord:  TRecordBuffer;
Begin
 Result:=Nil;
 //  Result:=inherited GetCurrentRecord;
End;

Function TRESTDWMemUniDirectionalIndex.GetIsInitialized: boolean;
Begin
 Result := Assigned(FSPareBuffer);
End;

Function TRESTDWMemUniDirectionalIndex.GetSpareBuffer:  TRecordBuffer;
Begin
 result := FSPareBuffer;
End;

Function TRESTDWMemUniDirectionalIndex.GetSpareRecord:  TRecordBuffer;
Begin
 result := FSPareBuffer;
End;

Function TRESTDWMemUniDirectionalIndex.ScrollBackward: TGetResult;
Begin
 result := grError;
End;

Function TRESTDWMemUniDirectionalIndex.ScrollForward: TGetResult;
Begin
 result := grOk;
End;

Function TRESTDWMemUniDirectionalIndex.GetCurrent: TGetResult;
Begin
 result := grOk;
End;

Function TRESTDWMemUniDirectionalIndex.ScrollFirst: TGetResult;
Begin
 Result:=grError;
End;

Procedure TRESTDWMemUniDirectionalIndex.ScrollLast;
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TRESTDWMemUniDirectionalIndex.SetToFirstRecord;
Begin
 // for UniDirectional datasets should be [Internal]First valid method call
 // do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.SetToLastRecord;
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TRESTDWMemUniDirectionalIndex.StoreCurrentRecord;
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TRESTDWMemUniDirectionalIndex.RestoreCurrentRecord;
Begin
 DatabaseError(SUniDirectional);
End;

Function TRESTDWMemUniDirectionalIndex.CanScrollForward: Boolean;
Begin
 // should return true if next record is already fetched
 result := false;
End;

Procedure TRESTDWMemUniDirectionalIndex.DoScrollForward;
Begin
 // do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.StoreCurrentRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark);
Begin
 // do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.StoreSpareRecIntoBookmark(Const ABookmark: PRESTDWMemBookmark);
Begin
 // do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.GotoBookmark(Const ABookmark: PRESTDWMemBookmark);
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TRESTDWMemUniDirectionalIndex.InitialiseIndex;
Begin
 // do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.InitialiseSpareRecord(Const ASpareRecord:  TRecordBuffer);
Begin
 FSPareBuffer:=ASpareRecord;
End;

Procedure TRESTDWMemUniDirectionalIndex.ReleaseSpareRecord;
Begin
 FSPareBuffer:=nil;
End;

Function TRESTDWMemUniDirectionalIndex.GetRecNo: Longint;
Begin
 Result := -1;
End;

Procedure TRESTDWMemUniDirectionalIndex.SetRecNo(ARecNo: Longint);
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TRESTDWMemUniDirectionalIndex.BeginUpdate;
Begin
 // Do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.AddRecord;
Var
h,i: integer;
Begin
 // Release unneeded blob buffers, in order to save memory
 // TDataSet has own buffer of records, so do not release blobs until they can be referenced
 With FDataSet Do
  Begin
   h := high(FBlobBuffers) - BufferCount*BlobFieldCount;
   If h > 10 Then //Free in batches, starting with oldest (at beginning)
   Begin
    For i := 0 To h Do
    FreeBlobBuffer(FBlobBuffers[i]);
    FBlobBuffers := Copy(FBlobBuffers, h+1, high(FBlobBuffers)-h);
   End;
  End;
End;

Procedure TRESTDWMemUniDirectionalIndex.InsertRecordBeforeCurrentRecord(Const ARecord:  TRecordBuffer);
Begin
 // Do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.RemoveRecordFromIndex(Const ABookmark: TRESTDWMemBookmark);
Begin
 DatabaseError(SUniDirectional);
End;

Procedure TRESTDWMemUniDirectionalIndex.OrderCurrentRecord;
Begin
 // Do nothing
End;

Procedure TRESTDWMemUniDirectionalIndex.EndUpdate;
Begin
 // Do nothing
End;


Initialization
   setlength(RegisteredDatapacketReaders,0);
Finalization
   setlength(RegisteredDatapacketReaders,0);
End.