unit uRESTDWDataset;

{$I ..\..\..\Source\Includes\uRESTDWPlataform.inc}
{$IFDEF FPC}
{$mode Delphi}
{$ENDIF}
{$UNDEF SUPPORTS_INLINE}{$UNDEF SUPPORTS_FOR_IN}

interface

Uses
 SysConst, TypInfo, uRESTDWConsts, {$IFNDEF FPC}DBConsts, SqlTimSt, {$ELSE}Masks, {$ENDIF}IniFiles, DateUtils, Math, FMTBcd,
 StrUtils, Types, Variants,
 {$IFDEF FPC}
  Graphics, Db, contnrs, LConvEncoding,
 {$ELSE}{$IF CompilerVersion <= 22}
         contnrs, Graphics, DBCommon, Db,
        {$ELSE}
         System.UIConsts, System.UITypes, System.Generics.Collections,
         System.VarCmplx, DBCommon, Data.Db,
        {$IFEND}
 {$ENDIF}
 SysUtils, Classes, uRESTDWCharset, uRESTDWEncodeClass, uZlibLaz;

{$IFDEF REGION}
{$REGION ' For init '}
{$ENDIF}

Const
 MaxFloatLaz       = 15;
 LazDigitsSize     = 6;
 sDate_dwdb        = 41941.5705324074;
 DWDB_VERSION_INFO = '3.50';
 NTAVersion        = 0;
 MAXSHORT          = 32767;
{Supported types}
  dwftString          = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftString);
  dwftSmallint        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftSmallint);
  dwftInteger         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftInteger);
  dwftWord            = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftWord);
  dwftBoolean         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftBoolean);
  dwftFloat           = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftFloat);
  dwftCurrency        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftCurrency);
  dwftBCD             = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftBCD);
  dwftDate            = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftDate);
  dwftTime            = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftTime);
  dwftDateTime        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftDateTime);
  dwftBytes           = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftBytes);
  dwftVarBytes        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftVarBytes);
  dwftAutoInc         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftAutoInc);
  dwftBlob            = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftBlob);
  dwftMemo            = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftMemo);
  dwftGraphic         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftGraphic);
  dwftFmtMemo         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftFmtMemo);
  dwftParadoxOle      = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftParadoxOle);
  dwftDBaseOle        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftDBaseOle);
  dwftTypedBinary     = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftTypedBinary);
  dwftFixedChar       = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftFixedChar);
  dwftWideString      = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftWideString);
  dwftLargeint        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftLargeint);
  dwftOraBlob         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftOraBlob);
  dwftOraClob         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftOraClob);
  dwftVariant         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftVariant);
  dwftInterface       = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftInterface);
  dwftIDispatch       = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftIDispatch);
  dwftGuid            = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftGuid);
  dwftTimeStamp       = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftTimeStamp);
  dwftFMTBcd          = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftFMTBcd);
  {$IFDEF COMPILER10_UP}
  dwftFixedWideChar   = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftFixedWideChar);
  dwftWideMemo        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftWideMemo);
  dwftOraTimeStamp    = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftOraTimeStamp);
  dwftOraInterval     = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftOraInterval);
  {$ELSE}
  dwftFixedWideChar   = Integer(38);
  dwftWideMemo        = Integer(39);
  dwftOraTimeStamp    = Integer(40);
  dwftOraInterval     = Integer(41);
  {$ENDIF}
  {$IFDEF COMPILER14_UP}
  dwftLongWord        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftLongWord); //42
  dwftShortint        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftShortint); //43
  dwftByte            = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftByte); //44
  dwftExtended        = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftExtended); //45
  dwftStream          = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftStream); //48
  dwftTimeStampOffset = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftTimeStampOffset); //49
  dwftSingle          = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftSingle); //51
  {$ELSE}
  dwftLongWord        = Integer(42);
  dwftShortint        = Integer(43);
  dwftByte            = Integer(44);
  dwftExtended        = Integer(45);
  dwftStream          = Integer(48);
  dwftTimeStampOffset = Integer(49);
  dwftSingle          = Integer(51);
  {$ENDIF}

  {Unsupported types}
  dwftUnknown         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftUnknown);
  dwftCursor          = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftCursor);
  dwftADT             = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftADT);
  dwftArray           = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftArray);
  dwftReference       = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftReference);
  dwftDataSet         = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftDataSet);
  {Unknown newest types for support in future}

  {$IFDEF COMPILER14_UP}
  dwftConnection      = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftConnection); //46
  dwftParams          = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftParams); //47
  dwftObject          = Integer({$IFNDEF FPC}{$IF CompilerVersion > 22}Data.{$IFEND}{$ENDIF}DB.ftObject); //50
  {$ENDIF}
  dwftColor           = Integer(255);
  {$IFDEF REGION}{$ENDREGION}{$ENDIF}

const
  // Stream Markers.
 MarkerSize           = SizeOf(Integer);
 smEOF                = 0;
 smFieldDefs          = 1;
 smData               = 2;
 stkAutoInc           = 0;
 stkIndexes           = 1;
 stkLookupInf         = 2;
 stkForeignKey        = 3;
 MaxIndexDataListSize = MaxInt div 16;
 SupportFieldTypes    = [ftString, ftWideString,    ftBoolean, ftSmallint, ftInteger,   ftLargeint,  ftWord, ftAutoInc,
                         ftFloat,  ftCurrency,      ftDate,    ftTime,     ftDateTime,  ftTimeStamp, ftBlob, ftMemo,
                         ftGuid,   ftBCD,           ftFmtBcd,  ftBytes,    ftVarBytes,  ftVariant,   ftFixedChar
                         {$IFNDEF FPC}
                           {$IF CompilerVersion > 21}
                            ,ftByte,   ftShortInt,   ftExtended,  ftSingle, ftLongWord, ftWideMemo
                           {$IFEND}
                         {$ENDIF}];
 SNotSupportFieldType = 'Field type is not supported.';

Type
 TOnWriterProcess    = Procedure (DataSet : TDataSet; RecNo, RecordCount : Integer; Var AbortProcess : Boolean) Of Object;
 TRESTDWBRSourceSide = (dwDelphi, dwLazarus);

Type
 {$IFDEF FPC}
  DWInteger       = Longint;
  DWInt64         = Int64;
  DWString        = String;
  DWFloat         = Real;
  DWFieldTypeSize = Longint;
 {$ELSE}
  DWInteger       = Integer;
  DWInt64         = Int64;
  DWString        = String;
  DWFloat         = Real;
  DWFieldTypeSize = Integer;
 {$ENDIF}

 Type
  TRESTDWDbTableHeader = Packed record
   VersionNumber,
   RecordCount,
   CheckRecCount,
   IndexCount     : DWInteger; //new for ver15
   DataSize,
   HashData,
   AutoIncVal     : DWInt64; //new for ver15
   SourceSide     : TRESTDWBRSourceSide;
 End;


Type
 TRESTDWCustomDataSet         = Class;
 TIndexList               = Class;
 TRESTDWAboutInfoDS           = (DWAboutDS);
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF CompilerVersion < 21}
   TRecordBuffer          = PChar;
   {$ELSE}
   TRecordBuffer          = PByte;
   {$IFEND}
  {$ELSE}
   {$IF CompilerVersion < 20}
    TRecordBuffer         = PChar;
   {$IFEND}
  {$IFEND}
 {$ENDIF}
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Defined(HAS_UTF8)}
    pdwAnsiString            = ^String;
   {$ELSE}
    pdwAnsiString            = ^AnsiString;
   {$IFEND}
  {$ELSE}
   pdwAnsiString            = ^AnsiString;
  {$IFEND}
 {$ELSE}
  pdwAnsiString            = ^AnsiString;
 {$ENDIF}
 TDataAttributes          = Set of (dwCalcField,    dwNotNull, dwLookup,
                                    dwInternalCalc, dwAggregate);
 TRestrictLength          = Set of (dwRangeChecking, dwRestrict);
 TIndexDataSortCompare    = Function(Item1, Item2 : Integer)         : Integer;
 TVariantArraySortCompare = Function(Const Value1, Value2 : Variant) : Integer;
 PVariantArray            = ^TVariantArray;
 TVariantArrayField       = Packed Record
  Attributes : TDataAttributes;
  FieldType  : TFieldType;
  Size,
  Precision,
  FieldDef,
  Order      : Integer;
 End;
{$IFDEF SUPPORTS_FOR_IN}
 TVariantArrayEnumerator = class
 Private
  FRow   : Integer;
  FArray : PVariantArray;
 Public
  Constructor Create(vArray : PVariantArray);
  Function GetCurrent : Integer;{$IFDEF COMPILER10_UP}{$IFDEF SUPPORTS_INLINE}Inline;{$ENDIF}{$ENDIF}
  Function MoveNext   : Boolean;
  Property Current    : Integer Read GetCurrent;
End;
{$ENDIF}

 { TVariantArray }
 PArrayData    = ^TArrayData;
 TArrayData    = Array of Variant;
 TVariantArray = {$IFNDEF FPC}{$IFDEF SUPPORTS_ENHANCED_RECORDS}Packed Record{$ELSE}class{$ENDIF}
                 {$ELSE}class{$ENDIF}
 Private
  vOnWriterProcess : TOnWriterProcess;
  FPrecision,
  FCursor         : Integer;
  FData           : TArrayData;
  FIsCancelDelete : Boolean;
  FRestrictLength : TRestrictLength;
  FSaveCapacity   : Int64;
  FTable          : TComponent;
  SourceSide      : TRESTDWBRSourceSide;
  {$IFDEF FPC}
   vDatabaseCharSet : TDatabaseCharSet;
   Function  GetDataAnsiString(Index             : Integer) : AnsiString;
  {$ELSE}
   {$IF CompilerVersion < 25}
    Function  GetDataAnsiString(Index            : Integer) : AnsiString;
   {$ELSE}
    Function  GetDataAnsiString(Index            : Integer) : String;
   {$IFEND}
  {$ENDIF}
  {$IFDEF FPC}
   Function  GetDataWideString(Index             : Integer)  : Unicodestring;
  {$ELSE}
   {$IF CompilerVersion < 25}
    Function  GetDataWideString(Index            : Integer) : String;
   {$ELSE}
    Function  GetDataWideString(Index            : Integer) : Unicodestring;
   {$IFEND}
  {$ENDIF}
  Function  GetCalcField     (Index              : Integer) : Boolean;
  Function  GetData          (Index              : Integer) : Variant;
  Function  GetDataByCell    (Index, Row         : Integer) : Variant;
  Function  GetDataByName    (Const Name         : String)  : Variant;
  Function  GetDataPtr       (Index              : Integer) : PVariant;
  Function  GetDataResult    (RecNo              : Integer;
                              Const ResultFields : String)  : Variant;
  Function  GetFieldIndex    (Const Name         : String)  : Integer;
  Function  GetFieldName     (Index              : Integer) : String;
  Function  GetFieldType     (Index              : Integer) : TFieldType;
  Function  GetOrder         (Index              : Integer) : Integer;
  Function  GetRecCount     : Integer;
  Function  GetRecNo        : Integer;
  Function  GetRequired      (Index              : Integer) : Boolean;
  Function  GetSize          (Index              : Integer) : Integer;
  Function  GetPrecision     (Index              : Integer) : Integer;
  Procedure ParseKeyFields   (KeyFields          : String;
                              var Fields);
  Procedure QuickSort        (L, R               : Integer;
                              SCompare           : TIndexDataSortCompare);
  Procedure SetData          (Index              : Integer;
                              Const AValue       : Variant);
  Procedure SetDataB         (Index              : Integer;
                              Const AValue       : Variant;
                              FieldIndex         : Integer = 0);
  Procedure SetDataByCell    (Index, Row         : Integer;
                              Const AValue       : Variant);
  Procedure SetDataByName    (Const Name         : String;
                              Const AValue       : Variant);
  Procedure SetFieldType     (Index              : Integer;
                              AValue             : Integer);
  Procedure SetLoadModified;
  Procedure LoadRecordFromStream(Stream          : TStream;
                                 Row             : Integer);
  Procedure SaveRecordToStream  (Stream          : TStream);
  Procedure SaveToStream        (Stream          : TStream);
  Procedure LoadFromStream      (Stream          : TStream);
  Procedure SetRecNo            (AValue          : Integer);
  {$IFDEF SUPPORTS_STRICT}Strict{$ENDIF}
 Private
  FDataType   : Array Of TFieldType;
  FFieldCount : Integer;
  FFieldName  : Array Of String;
  FFields     : Array Of TVariantArrayField;
  FModified   : Boolean;
  procedure PutOrder(Index           : Integer; AValue: Integer);
  Function  GetIndexCount               : Integer;
  Procedure RemoveIndex         (List   : TIndexList);
  Function  GetIndexes          (Index  : Integer) : TIndexList;
  {$IFDEF FPC}
  Procedure SetDatabaseCharSet  (Value  : TDatabaseCharSet);
  {$ENDIF}
 Public
  FIndexes: TList;
  {
  Constructor Create;
  Destructor  Destroy;Override;
  }
  Procedure DoneIndexes;
  Function  AppendField(FieldDef, Size,
                        Precision : Integer;
                        Attributes      : TDataAttributes;
                        Const Name, At  : String) : Integer;
  Procedure Add        (Const Args      : Array of const);
  Procedure Append;
  Procedure Assign     (Const Source    : TVariantArray);
  Function  Bof : Boolean;
  Procedure Clear;
  Procedure CopyFrom   (DataSet         : TDataSet;
                        ACount          : Integer);
  Procedure CustomSort (Const Name      : String;
                        SCompare        : TIndexDataSortCompare;
                        Const Descs     : Array Of Boolean;
                        CaseInsensitive : Boolean = False);
  Procedure Delete;
  Procedure Done;
  Function  Eof : Boolean;
  Procedure Exchange   (RecNo1, RecNo2  : Integer);
  Function  FindOrder  (Order           : Integer) : Integer;
  Procedure First;
  Procedure AddIndex(List: TIndexList);
  Function  GetAutoIncField : Integer;
  Function  GetDataType(Index           : Integer) : TFieldType;
  {$IFDEF FPC}
   Function  GetDefinitions  : AnsiString;
  {$ELSE}
   {$IF CompilerVersion < 25}
    Function  GetDefinitions  : AnsiString;
   {$ELSE}
    Function  GetDefinitions  : String;
   {$IFEND}
  {$ENDIF}
  {$IFDEF SUPPORTS_FOR_IN}
  Function  GetEnumerator   : TVariantArrayEnumerator;
  {$ENDIF}
  Function  GetFieldDef(Index             : Integer) : Integer;
  Function  GetIsEmpty (Index, Row        : Integer) : Boolean;
  Procedure Init       (Const Args        : Array Of Const); Overload;
  {$IFDEF FPC}
   Procedure Init       (Const Definitions : AnsiString); Overload;
   Procedure Init       (Const Definitions : WideString); Overload;
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    Procedure Init       (Const Definitions : String); Overload;
   {$ELSE}
    Procedure Init       (Const Definitions : AnsiString); Overload;
    Procedure Init       (Const Definitions : WideString); Overload;
   {$IFEND}
  {$ENDIF}
  Procedure Insert;
  Function  IsLookup   (Index             : Integer) : Boolean;
  Procedure Last;
  Function  Locate(Const KeyFields        : String;
                   Const KeyValues        : Variant;
                   Options                : TLocateOptions;
                   Index                  : Integer = -1) : Boolean;
  Function  Lookup(Const KeyFields        : String;
                   Const KeyValues        : Variant;
                   Const ResultFields     : String;
                   Index                  : Integer = -1): Variant;
  Procedure Next;
  Function  NewField(Const Name           : String;
                     FieldDef             : Integer;
                     Size                 : Integer = 0;
                     Attributes           : TDataAttributes = []) : Integer;
  Procedure Prior;
  Procedure Save       (DataSet           : TDataSet;
                        ACount            : Integer);
  Procedure SaveToBlobStream(Const AFieldName : String;
                             Stream           : TStream;
                             Decompress       : Boolean = False);
  Procedure SetRecordCount  (AValue           : Integer);
  Procedure Sort            (Const Name       : String;
                             Const Descs      : Array Of Boolean;
                             CaseInsensitive  : Boolean = False);
  Property Calculated[Index      : Integer]   : Boolean    Read GetCalcField;
  Property Data      [Index      : Integer]   : Variant    Read GetData           Write SetData;
  Property DataByCell[Index, Row : Integer]   : Variant    Read GetDataByCell     Write SetDataByCell;
  Property DataByName[Const Name : String]    : Variant    Read GetDataByName     Write SetDataByName; Default;
  {$IFDEF FPC}
   Property DatabaseCharSet      : TDatabaseCharSet        Read vDatabaseCharSet  Write SetDatabaseCharSet;
   Property DataString[Index     : Integer]   : AnsiString Read GetDataAnsiString;
  {$ELSE}
   {$IF CompilerVersion < 25}
    Property DataString[Index      : Integer]   : AnsiString Read GetDataAnsiString;
   {$ELSE}
    Property DataString[Index      : Integer]   : String Read GetDataAnsiString;
   {$IFEND}
  {$ENDIF}
//  Property DataWideString[Index  : Integer]   : String     Read GetDataWideString;
  Property FieldCount            : Integer                 Read FFieldCount;
  Property FieldIndex[Const Name : String]    : Integer    Read GetFieldIndex;
  Property FieldName[Index       : Integer]   : String     Read GetFieldName;
  Property FieldType[Index       : Integer]   : TFieldType Read GetFieldType;
  Property LoadModified          : Boolean                 Read FModified;
  Property Order[Index           : Integer]   : Integer    Read GetOrder          Write PutOrder;
  Property RecCount              : Integer                 Read GetRecCount;
  Property RecNo                 : Integer                 Read GetRecNo          Write SetRecNo;
  Property Required[Index        : Integer]   : Boolean    Read GetRequired;
  Property Size[Index            : Integer]   : Integer    Read GetSize;
  Property Precision[Index       : Integer]   : Integer    Read GetPrecision;
  Property IndexCount : Integer Read GetIndexCount;
  Property Indexes[Index: Integer]: TIndexList read GetIndexes;
  Property OnWriterProcess       : TOnWriterProcess        Read vOnWriterProcess  Write vOnWriterProcess;
  Class {$IFNDEF FPC}{$IFDEF SUPPORTS_ENHANCED_RECORDS}Operator{$ELSE}Function{$ENDIF}
        {$ELSE}Function{$ENDIF}
  Implicit(const AValue: TDataSet): TVariantArray;
//  Class Function Implicit(Const AValue : TDataSet) : TVariantArray;
End;

  TRESTDWTableStorage = Class(TObject)
  Private
   {$IFDEF SUPPORTS_CLASS_FIELDS}
   Class Var
    FStaticBias        : Double;
    FSwapDebugDataMode : Boolean;
   {$ENDIF}
   Class Function  GetDbResource(Const Name : String) : TStream; {$IFDEF SUPPORTS_STATIC}static;{$ENDIF}
   Class Procedure GetTimeZoneBias; {$IFDEF SUPPORTS_STATIC}Static;{$ENDIF}
   {$IFDEF SUPPORTS_STRICT}strict{$ENDIF}
  Protected
   Class Function OutputDirectory : String; virtual;
  Protected
   {$IFDEF SUPPORTS_CLASS_FIELDS}
   Class Var
   {$ENDIF}
   DisabledCheckSynchronizing,
   LoadArrayDefinitions,
   FastestLoadingMode,
   CheckIndexMode,
   TypicalSortingAutoInc               : Boolean;
   StreamDefaultBufferSize             : Integer;
   Class Function GetDefaultExt        : String; Virtual;
   Class Function GetProductInfo       : Int64;
   Class Procedure LoadArray(Stream    : TStream;
                            Var VArray : TVariantArray); virtual;
   Class Procedure LoadTable(const TableName: string; var VArray: TVariantArray); virtual;
   Class Procedure SaveTable(const TableName: string; var VArray: TVariantArray); virtual;
   Class Function SupportTimeStampOffset: Boolean; virtual;
  Public
   Class Function CheckForName(const AName: string): Boolean; virtual;
   Class Function GetColorIdentsStrings: TStrings;
   Class Function GetHeaderVersion: Integer;
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     {$IF Defined(HAS_UTF8)}
      Class Function GetTableDefs(DataSet: TDataSet): String; virtual;
     {$ELSE}
      Class Function GetTableDefs(DataSet: TDataSet): AnsiString; virtual;
     {$IFEND}
    {$ELSE}
    Class Function GetTableDefs(DataSet: TDataSet): AnsiString; virtual;
    {$IFEND}
   {$ELSE}
    Class Function GetTableDefs(DataSet: TDataSet): AnsiString; virtual;
   {$ENDIF}
   Class Function IsSystemData(DataSet: TDataSet; TableName: string = ''): Boolean; virtual;
   Class Function OutputFileName(const FileName: string): string;
  End;
  TRESTDWTableStorageClass = class of TRESTDWTableStorage;
  {$IFDEF REGION}{$REGION ' TIndexList '}{$ENDIF}
  PIndexDataList      = ^TIndexDataList;
  TIndexDataList      = Array[0..MaxIndexDataListSize - 1] of Integer;
  TIndexListOptions   = Set Of (iloUnique = 0, iloInactive = 1);
  TIndexList          = Class(TObject)
  Private
   FList              : PIndexDataList;
   FCount,
   FCapacity          : Integer;
   FArray             : PVariantArray;
   FCaseInsensitive   : Boolean;
   FKeyFields         : String;
   FOptions           : TIndexListOptions;
   FFields            : Array of Integer;
   FModified          : Boolean;
   FName              : String;
   Function Add(Item  : Integer): Integer;
   Function Get(Index : Integer): Integer;
   Function GetText   : String;
   Procedure Grow;
   Procedure SetCapacity(NewCapacity  : Integer);
   Procedure SetCount   (NewCount     : Integer);
   Procedure SetName    (Const AValue : String);
  Protected
   Procedure DoDelete   (Index        : Integer);
   Procedure DoInsert   (RecNo        : Integer;
                         IsUpdate     : Boolean);
   Class Procedure Error(Msg          : PResStringRec;
                         Data         : Integer);
   Procedure MarkModified;
   Procedure SetText    (AValue       : String);
   Procedure Sort       (Compare      : TIndexDataSortCompare);
   Property  Capacity                 : Integer Read FCapacity Write SetCapacity;
  Public
   Constructor Create   (const AName      : String;
                         vArray           : PVariantArray;
                         Const AKeyFields : String);
   Destructor Destroy; Override;
   Procedure  Clear;
   Procedure  Delete(RecNo       : Integer);
   Function   Empty              : Boolean;
   Procedure  Eval (Force        : Boolean = True);
   Function   Find (Const AValue : Variant;
                    Var RecNo    : Integer;
                    PartialKey   : Boolean)       : Boolean;
   Function  GetData(RecNo       : Integer;
                     Const ResultFields : String) : Variant;
   Function  InDataset(Dataset   : TComponent)    : Boolean;
   Function  IndexOf(RecNo       : Integer)       : Integer;
   Procedure Insert (RecNo       : Integer);
   Procedure LoadFromStream(Stream : TStream);
   Procedure SaveToStream  (Stream : TStream);
   Procedure Update        (RecNo  : Integer);
   Property CaseInsensitive : Boolean            Read FCaseInsensitive Write FCaseInsensitive;
   Property Count           : Integer            Read FCount;
   Property Data            : PVariantArray      Read FArray;
   Property Name            : String             Read FName;
   Property KeyFields       : String             Read FKeyFields;
   Property Items[Index     : Integer] : Integer Read Get; Default;
   Property List            : PIndexDataList     Read FList;
   Property Modified        : Boolean            Read FModified;
   Property Options         : TIndexListOptions  Read FOptions         Write FOptions;
   Property Text            : String             Read GetText;
  End;
  TCustomIndexList = Class(TIndexList)
  Private
   FEvalProc : TVariantArraySortCompare;
   FFindProc : TVariantArraySortCompare;
  Public
   Constructor Create(Const AKeyField : String;
                      AEvalProc,
                      AFindProc       : TVariantArraySortCompare);
   Property EvalProc                  : TVariantArraySortCompare Read FEvalProc;
   Property FindProc                  : TVariantArraySortCompare Read FFindProc;
  End;

  TDataSetIndexList = Class(TIndexList)
  Private
   FDataSet : TDataSet;
   Procedure ParseKeyFieldsDataSet(KeyFields : String;
                                   Var Fields);
  Public
   Constructor Create(Const AKeyField  : String;
                      ADataSet         : TDataSet;
                      ACaseInsensitive : Boolean = False);
   Destructor  Destroy; Override;
   Procedure   Delete; Reintroduce;
   Procedure   Insert; Reintroduce;
   Function    Locate (Const KeyValues : Variant;
                       Options         : TLocateOptions)    : Boolean;
   Function    LocateNext(Const KeyValues : Variant;
                          Options         : TLocateOptions) : Boolean;
   Procedure   Update; Reintroduce;
   Property    DataSet : TDataSet Read FDataSet;
  End;

  TBufferedStream = Class(TStream)
  Private
   FBuffer                 : Array of Byte;
   FBufferCurrentSize,
   FBufferMaxModifiedPos,
   FBufferSize             : Longint;
   FBufferStart,
   FPosition               : Int64;
   FStream                 : TStream;
  Protected
   Function  BufferHit     : Boolean;
   Function  GetCalcedSize : Int64;   Virtual;
   Function  LoadBuffer    : Boolean; Virtual;
   Function  ReadFromBuffer(Var Buffer;
                            Count, Start  : Longint) : Longint;
   Procedure SetSize       (NewSize       : Longint); Overload; Override;
   Procedure SetSize       (Const NewSize : Int64);   Overload; Override;
   Function  WriteToBuffer (Const Buffer;
                            Count, Start  : Longint) : Longint;
   Property  BufferSize   : Longint Read FBufferSize Write FBufferSize;
   Property  Stream       : TStream Read FStream;
  Public
   Constructor Create(Const AFileName : String;
                      Mode            : Word);     Overload;
   Constructor Create(Const AFileName : String;
                      Mode            : Word;
                      Rights          : Cardinal); Overload;
   Destructor Destroy; Override;
   Procedure  Flush; Virtual;
   Function   Read   (Var Buffer;
                      Count           : Longint)     : Longint; Override;
   Function   Seek   (Offset          : Longint;
                      Origin          : Word)        : Longint; Overload; Override;
   Function   Seek   (Const Offset    : Int64;
                      Origin          : TSeekOrigin) : Int64;   Overload; Override;
   Function   Write  (Const Buffer;
                      Count           : Longint)     : Longint; Override;
  End;
 {$IFDEF REGION}{$ENDREGION}{$ENDIF}
  DwArrayError    = Class (Exception);
  DwTableError    = Class (Exception);
  DwDatabaseError = Class (Exception);
 {$IFDEF REGION}{$REGION ' Any Fields '}{$ENDIF}
 {$IFDEF SUPPORTS_CLASS_HELPERS}
 {$IFNDEF COMPILER10_UP}
  TExtendedFieldHelper = Class helper For TField
  Protected
   Function GetAsExtendedHelper: Extended;
   Procedure SetAsExtendedHelper(const AValue: Extended);
  Public
   Property AsExtended: Extended Read GetAsExtendedHelper Write SetAsExtendedHelper;
  End;
{$ENDIF}
{$ENDIF}

{$IFNDEF FPC}
  {$IF CompilerVersion > 24}
  TExtendedField = Class(TNumericField)
  Protected
   Function  GetAsExtended : Extended;
   Function  GetAsString   : String;  Override;
   Function  GetAsVariant  : Variant; Override;
   Procedure SetAsExtended(Const AValue : Extended);
   Procedure SetAsString  (Const AValue : String);  Override;
   Procedure SetVarValue  (Const AValue : Variant); Override;
  Public
   {$IFNDEF SUPPORTS_CLASS_HELPERS}
   Property  AsExtended    : Extended Read GetAsExtended Write SetAsExtended;
   {$ENDIF}
   Property  Value         : Extended Read GetAsExtended Write SetAsExtended;
  End;
  {$ELSE}
  TExtendedField = Class(TNumericField)
  Protected
   {$IFDEF COMPILER17_UP}
   Function GetAsExtended : Extended; Override;
   {$ENDIF}
   Function GetAsVariant  : Variant;  Override;
  End;
  {$IFEND}
{$ELSE}
TExtendedField = Class(TNumericField)
Protected
 Function GetAsVariant  : Variant;  Override;
End;
{$ENDIF}

{$IFNDEF FPC}
  TSQLTimeStampOffsetField = Class(TSQLTimeStampField)
  Protected
   {$IF CompilerVersion < 25}
   Procedure GetText    (Var Text     : String;
                         DisplayText  : Boolean); Override;
   {$IFEND}
   {$IFDEF FPC}
   Procedure SetAsString(const Value: string); override;
   {$ELSE}
   {$IF CompilerVersion < 25}
   Procedure SetAsString(const Value: string); override;
   {$ELSE}
   Procedure SetAsString(Const AValue : String);  Override;
   {$IFEND}
   {$ENDIF}
  End;
{$ENDIF}

{ TStreamField }
  TStreamField = Class(TBlobField)
  Private
   FStream               : TStream;
   Function GetAsStream  : TStream;
  Public
   Constructor Create(AOwner : TComponent); Override;
   Destructor  Destroy; Override;
   Procedure   Put;
   Property    Value         : TStream    Read GetAsStream;
  End;

  TRESTDWcolorOptions = Set Of (dwcoAllowedSharp, dwcoShowWebSharp, dwcoSysColors);
  TColorField = class(TIntegerField)
  Private
   FOptions : TRESTDWcolorOptions;
  Protected
   Function    GetIdentText    (AValue       : Integer;
                                Var Text     : String) : Boolean; Virtual;
   Procedure   GetText         (Var Text     : String;
                                DisplayText  : Boolean);          Override;
   Function    SetAsIdentString(Const AValue : String) : Boolean; Virtual;
   Procedure   SetAsString     (Const AValue : String);           Override;
  Public
   Constructor Create          (AOwner       : TComponent);       Override;
  Published
   Property    MaxValue Stored False;
   Property    MinValue Stored False;
   Property    Options : TRESTDWcolorOptions Read FOptions Write FOptions Default [dwcoAllowedSharp];
  End;
{$IFDEF REGION}{$ENDREGION}{$ENDIF}
  TRESTDWMemtableState   = Set Of (dwsOpening,      dwsOpen,
                               dwsConvertError, dwsCheckFilter);
  TRESTDWMemtableOptions = Set Of (dwoCanConvert,   dwoFileReadOnly, dwoShowWaitForm);
  TVarRecInfo        = Record
   Bookmark     : Longint;
   BookmarkFlag : TBookmarkFlag;
  End;
  PVarRecInfo  = ^TVarRecInfo;
  {$IFNDEF COMPILER12_UP}
  TBytes        = Array of Byte;
  {$ENDIF}
  {$IFNDEF COMPILER16_UP}
  {$IFNDEF FPC}
   NativeInt = Longint;
  {$ELSE}
   NativeInt = PtrInt;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF SUPPORTS_FOR_IN}
  TRESTDWCustomDatasetEnumerator = Class
  Private
   FRow     : Integer;
   FDataset : TRESTDWCustomDataSet;
  Public
   Constructor Create(Dataset : TRESTDWCustomDataSet);
   Function    GetCurrent     : Integer;
   {$IFDEF COMPILER10_UP}{$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}{$ENDIF}
   Function    MoveNext       : Boolean;
   Property    Current        : Integer Read GetCurrent;
  End;
  {$ENDIF}
  TRESTDWMemtableOptionD  = (dwPersistentData, dwStored, dwSetEmptyStrToNull, dwSkipUnSupportedFieldTypes);
  TRESTDWMemtableOptionsD = Set Of TRESTDWMemtableOptionD;
  TRESTDWCustomDataSet    = Class(TDataSet)
  Private
   aRecordCount,
   FRecSize            : Integer;
   FArray              : TVariantArray;
   FFieldDefClass      : TFieldClass;
   FDsgnFieldName,
   FKeyField           : String;
   FKeyValue           : Variant;
   FMemoDataType       : TFieldType;
   FOnOperation,
   FIsCurrentFirst,
   FModified,
   FNativeFormatParam  : Boolean;
   FTableDefs,
   FNewDefaults        : TStrings;
   FOnFiltered         : TDataSetNotifyEvent;
   FOptions            : TRESTDWMemtableOptionsD;
   FState              : TRESTDWMemtableState;
   fsAbout             : TRESTDWAboutInfoDS;
   vOnWriterProcess    : TOnWriterProcess;
   vEncoding           : TEncodeSelect;
   {$IFDEF FPC}
   vDatabaseCharSet    : TDatabaseCharSet;
   {$ENDIF}
   Function  GetDataByCell (Const FieldName    : String;
                            RecNo              : Integer)    : Variant;
   Function  GetDataByName (Const Name         : String)     : Variant;
   Function  GetRestrictLength                 : TRestrictLength;
   Procedure SetDataByName (Const Name         : String;
                            Const Value        : Variant);
   Procedure SetKeyField   (Const Value        : String);
   Procedure SetNewDefaults(Const Value        : TStrings);
   Procedure SetRestrictLength(Const AValue    : TRestrictLength);
   Procedure SetTableDefs     (Const AValue    : TStrings);
   Procedure TableDefsChange  (Sender          : TObject);
   Procedure TableDefsChanging(Sender          : TObject);
   Procedure Done;
   {$IFDEF FPC}
   Procedure SetDatabaseCharSet(Value          : TDatabaseCharSet);
   {$ENDIF}
   Procedure SetEncoding(bValue : TEncodeSelect);
  Protected
   {$IFDEF NEXTGEN}
    Function AllocRecBuf : TRecBuf; Override;
    Procedure FreeRecBuf(Var Buffer: TRecBuf); Override;
   {$ENDIF}
   Function  AllocRecordBuffer                 : TRecordBuffer;{$IFNDEF NEXTGEN}Override;{$ENDIF}
   Function  CanSetData                        : Boolean;       Virtual;
   Procedure CheckDefaults;
   Procedure CheckFieldCompatibility(Field     : TField;
                                     FieldDef  : TFieldDef);{$IFNDEF FPC}Override;{$ENDIF}
   Procedure CheckInactive; Override;
   Procedure CopyFrom               (DataSet   : TDataSet;
                                     ACount    : Integer);      Virtual; Abstract;
   {$IFDEF COMPILER10_UP}{$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}{$ENDIF}
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     {$IF Defined(HAS_UTF8)}
     Procedure GetBookmarkData(Buffer : TRecBuf;
                               Data   : TBookmark); Override;
     Function GetRecNo                : Integer;        Override;
     Function GetRecordCount          : Integer;        Override;
     {$ELSE}
     Procedure GetBookmarkData(Buffer : TRecordBuffer;
                                                Data   : Pointer); Override;
     {$IFEND}
     Function GetBookmarkFlag   (Buffer          : TRecBuf)       : TBookmarkFlag; Override;
     Function GetRecord         (Buffer          : TRecBuf;
                                 GetMode         : TGetMode;
                                 DoCheck         : Boolean)       : TGetResult;    Override;
     Procedure FreeRecordBuffer (Var Buffer      : TRecordBuffer);{$IFNDEF NEXTGEN}Override;{$ENDIF}
     Procedure InternalGotoBookmark(Bookmark     : Pointer);       Overload;{$IFNDEF NEXTGEN}Override;{$ENDIF}
     Procedure InternalInitRecord  (Buffer       : TRecBuf);       Override;
     Procedure InternalLoadCurrentRecord(Buffer  : TRecBuf);
     Procedure InternalSetToRecord      (Buffer  : TRecBuf);       Override;
     Procedure SetBookmarkData          (Buffer  : TRecBuf;
                                         Data    : TBookmark);     Override;
     Procedure SetBookmarkFlag          (Buffer  : TRecBuf;
                                         Value   : TBookmarkFlag); Override;
     {$ELSE}
      Procedure GetBookmarkData  (Buffer          : TRecordBuffer;
                                  Data            : Pointer);     Override;
      Function GetBookmarkFlag   (Buffer          : TRecordBuffer) : TBookmarkFlag; Override;
      Function GetRecord         (Buffer          : TRecordBuffer;
                                  GetMode         : TGetMode;
                                  DoCheck         : Boolean)       : TGetResult;Override;
      Procedure InternalGotoBookmark(Bookmark     : Pointer);       Override;
      Procedure InternalInitRecord  (Buffer       : TRecordBuffer); Override;
      Procedure InternalLoadCurrentRecord(Buffer  : TRecordBuffer);
      Procedure InternalSetToRecord      (Buffer  : TRecordBuffer); Override;
      Procedure SetBookmarkData          (Buffer  : TRecordBuffer;
                                          Data    : Pointer);       Override;
      Procedure SetBookmarkFlag          (Buffer  : TRecordBuffer;
                                          Value   : TBookmarkFlag); Override;
      Procedure FreeRecordBuffer (Var Buffer      : TRecordBuffer);Override;
      Function  GetRecNo                          : Longint;        Override;
      Function  GetRecordCount                    : Longint;        Override;
     {$IFEND}
    {$ELSE}
    Procedure GetBookmarkData  (Buffer          : TRecordBuffer;
                                Data            : Pointer);       Override;
    Function GetBookmarkFlag   (Buffer          : TRecordBuffer) : TBookmarkFlag; Override;
    Function GetRecord         (Buffer          : TRecordBuffer;
                                GetMode         : TGetMode;
                                DoCheck         : Boolean)       : TGetResult;    Override;
    Procedure FreeRecordBuffer (Var Buffer      : TRecordBuffer); Override;
    Procedure InternalGotoBookmark(Bookmark     : Pointer);       Override;
    Procedure InternalInitRecord  (Buffer       : TRecordBuffer); Override;
    Procedure InternalLoadCurrentRecord(Buffer  : TRecordBuffer);
    Procedure InternalSetToRecord      (Buffer  : TRecordBuffer); Override;
    Procedure SetBookmarkData          (Buffer  : TRecordBuffer;
                                        Data    : Pointer);       Override;
    Procedure SetBookmarkFlag          (Buffer  : TRecordBuffer;
                                        Value   : TBookmarkFlag); Override;
    Function GetRecNo                           : Longint;        Override;
    Function  GetRecordCount                    : Longint;        Override;
   {$ENDIF}
   Function GetControlInterface                : IInterface;     Virtual;
   Function GetFieldClass     (FieldType       : TFieldType)    : TFieldClass;   Override;
   Procedure InternalFirst; Override;
   Procedure InternalInitFieldDefs; Override;
   Procedure InternalLast; Override;
   Function  IsCursorOpen                      : Boolean;        Override;
   Procedure SetBlobStream            (Stream  : TStream);
   {$IFNDEF FPC}
   {$IF CompilerVersion < 25}
   Procedure SetFieldData             (Field   : TField;
                                       Buffer  : Pointer);Overload; Override;
   {$ELSE}
   Procedure SetFieldData             (Field  : TField;
                                       Buffer : TValueBuffer);Overload; Override;
   {$IFEND}
   {$ELSE}
   Procedure SetFieldData             (Field   : TField;
                                       Buffer  : Pointer);Overload; Override;
   {$ENDIF}
   Procedure SetFiltered              (Value        : Boolean);  Override;
   Procedure SetRecNo                 (Value        : Integer);  Override;
   Procedure RaiseError               (Fmt          : String;
                                       Args         : Array of const);
   Procedure SaveDataToStream         (F            : TStream;
                                       SaveData     : Boolean);
   Procedure LoadDataFromStream       (F            : TStream);
   Procedure CheckMarker              (F            : TStream;
                                       Marker       : Integer);
   Procedure WriteMarker              (F            : TStream;
                                       Marker       : Integer);
   Procedure ReadFieldDefsFromStream  (F            : TStream);
   Procedure SaveFieldDefsToStream    (F            : TStream);
   Property Defaults         : TStrings                Read FNewDefaults      Write SetNewDefaults;
   //Property NullDefaults: TStrings Read FNewDefaults Write SetNewDefaults stored False;
   //backward compatibility
   Property KeyField         : String                  Read FKeyField         Write SetKeyField;
   Property RestrictLength   : TRestrictLength         Read GetRestrictLength Write SetRestrictLength;
  Public
   Constructor Create(AOwner : TComponent); Override;
   Destructor  Destroy; Override;
   Procedure   Loaded; Override;
   Procedure   AcceptCustomIndex(List               : TCustomIndexList);
   Procedure   Assign           (Source             : TPersistent); Reintroduce;  Overload; Override;
   Function    BookmarkValid    (Bookmark           : TBookmark)  : Boolean;      Override;
   Function    CompareBookmarks (Bookmark1,
                                 Bookmark2          : TBookmark)  : Integer;      Override;
   Function    CreateBlobStream (Field              : TField;
                                 Mode               : TBlobStreamMode): TStream;  Override;
   Procedure   DesignNotify(Const AFieldName        : String;
                            Dummy                   : Integer); Virtual;
   {$IFDEF SUPPORTS_FOR_IN}
   Function    GetEnumerator : TRESTDWCustomDatasetEnumerator;
   {$ENDIF}
   {$IFNDEF FPC}
    {$IF NOT Defined(HAS_FMX)}
     {$IF CompilerVersion < 25}
      Function    GetFieldData     (Field              : TField;
                                    Buffer             : Pointer)      : Boolean;   Overload; Override;
     {$ELSE}
      Function    GetFieldData    (AField             : TField;
                                   Var ABuffer        : TValueBuffer) : Boolean;   Overload; Override;
     {$IFEND}
    {$ELSE}
     Function    GetFieldData    (AField             : TField;
                                  Var ABuffer        : TValueBuffer) : Boolean;   Overload; Override;
    {$IFEND}
   {$ELSE}
    Function    GetFieldData     (Field              : TField;
                                  Buffer             : Pointer)      : Boolean;   Overload; Override;
   {$ENDIF}
   Procedure   LoadFromFile     (Const FileName     : String);
   Procedure   SaveToStream     (F                  : TStream);      {$IFNDEF FPC}Overload; {$ENDIF}
   Procedure   LoadFromStream   (Stream             : TStream);
   Function    Locate           (Const KeyFields    : String;
                                 Const KeyValues    : Variant;
                                 Options            : TLocateOptions) : Boolean;  Override;
   Function    LocateNext       (Const KeyFields    : String;
                                 Const KeyValues    : Variant;
                                 Options            : TLocateOptions) : Boolean;
   Function    Lookup           (Const KeyFields    : String;
                                 Const KeyValues    : Variant;
                                 Const ResultFields : String)         : Variant;  Override;
   Procedure SetRecordCount     (AValue             : Integer);
   Procedure SortLocal          (Const Name         : String;
                                 Const Descs        : Array of Boolean;
                                 CaseInsensitive    : Boolean = False);
   Property DataByCell[Const FieldName              : String;
                       RecNo                        : Integer] : Variant Read GetDataByCell;
   Property DataByName[Const Name                   : String]  : Variant Read GetDataByName       Write SetDataByName; Default;
   Property Options         : TRESTDWMemtableOptionsD                        Read FOptions            Write FOptions;
   Property TableDefs       : TStrings                                   Read FTableDefs          Write SetTableDefs;
   Property TableState      : TRESTDWMemtableState                           Read FState;
   Property OnFiltered      : TDataSetNotifyEvent                        Read FOnFiltered         Write FOnFiltered;
   {$IFDEF FPC}
   Property DatabaseCharSet : TDatabaseCharSet                           Read vDatabaseCharSet    Write SetDatabaseCharSet;
   {$ENDIF}
   {$IFNDEF FPC}
   Property Encoding        : TEncodeSelect                              Read vEncoding           Write SetEncoding;
   {$ENDIF}
  Published
   // redeclared data set properties
   Property Active;
   Property BeforeOpen;
   Property AfterOpen;
   Property BeforeClose;
   Property AfterClose;
   Property BeforeInsert;
   Property BeforeEdit;
   Property AfterEdit;
   Property AfterPost;
   Property BeforeCancel;
   Property AfterCancel;
   Property BeforeDelete;
   Property AfterDelete;
   Property BeforeScroll;
   Property AfterScroll;
   Property OnCalcFields;
   Property OnDeleteError;
   Property OnEditError;
   Property OnNewRecord;
   Property OnPostError;
   {$IFDEF FPC}
   Property Encoding        : TEncodeSelect    Read vEncoding        Write SetEncoding;
   {$ENDIF}
   Property OnWriterProcess : TOnWriterProcess Read vOnWriterProcess Write vOnWriterProcess;
   Property AboutInfo       : TRESTDWAboutInfoDS   Read fsAbout          Write fsAbout Stored False;
  End;
  TRESTDWMemtable   = Class(TRESTDWCustomDataSet)
  Private
   FNameList    : TStrings;
   FTableName   : String;
   Function  GetDataByName            (Const Name   : String) : Variant;
   {$IFDEF SUPPORTS_STRICT}Strict{$ENDIF}
  Private
   Procedure ReadDefaults     (Reader : TReader);
   Procedure WriteDefaults    (Writer : TWriter);
   Procedure InitArrayFields; //Create all Fields to listactions
  Protected
   // create, close, and so on
   Procedure Clear;
   Procedure DeleteFields;
   Procedure CreateFields;            Override;
   Procedure InternalInitFieldDefs;   Override;
   Procedure InternalOpen;            Override;
   Procedure InternalClose;           Override;
   Procedure InternalRevert;          Virtual;
   // editing (dummy vesions)
   Procedure InternalCancel;          Override;
   Procedure InternalDelete;          Override;
   Procedure OpenCursor    (InfoQuery : Boolean = False); Override;
   // other
   Procedure InternalHandleException; Override;
   Procedure DataEvent     (Event     : TDataEvent;
                            Info      : NativeInt);       Override;
   Procedure DefineProperties(Filer   : TFiler);          Override;
   Procedure DoAfterDelete;           Override;
   Procedure DoAfterPost;             Override;
   Procedure DoAfterOpen;             Override;
   Procedure DoBeforeDelete;          Override;
   Procedure DoBeforeOpen;            Override;
   Procedure DoBeforePost;            Override;
   Procedure DoOnNewRecord;           Override;
   Function  GetControlInterface : IInterface;            Override;
   {$IFNDEF FPC}
    {$IF NOT Defined(HAS_FMX)}
     Procedure InternalAddRecord(Buffer : Pointer;
                                 Append : Boolean);       Override;
    {$ELSE}
     Procedure InternalAddRecord(Buffer : TRecBuf;
                                 Append : Boolean);       Override;
    {$IFEND}
   {$ELSE}
    Procedure InternalAddRecord(Buffer : Pointer;
                                Append : Boolean);       Override;
   {$ENDIF}
   Procedure InternalEdit;            Override;
   Procedure InternalInsert;          Override;
   Procedure InternalPost;            Override;
   Procedure Loaded;                  Override;
   Procedure Notification     (AComponent : TComponent;
                               Operation  : TOperation);    Override;
  Public
   Constructor Create         (AOwner     : TComponent);    Override;
   Destructor  Destroy; Override;
   Procedure   Assign         (Source     : TVariantArray); Reintroduce; Overload; Virtual;
   Procedure   Assign         (Source     : TDataSet;
                               IgnoreData : Boolean = False);      Overload;
   Class Procedure Cast       (Source,
                               DataSet    : TDataset;
                               ACount     : Integer = -1);
   Procedure CopyFrom         (DataSet    : TDataSet;
                               ACount     : Integer);       Override;
   Procedure CopyRecordFrom   (DataSet    : TDataSet);
   Procedure CreateTable;
   Procedure DesignNotify     (Const AFieldName : String;
                               Dummy            : Integer); Override;
   Procedure Lock;
   Procedure InsertRecordInto (DataSet          : TDataSet);
   Procedure Revert;
   Procedure Unlock;
   Property  DataByName[Const Name : String]    : Variant   Read GetDataByName Write SetDataByName;
   Property  Defaults;
   Property  TableDefs;
   Property  Fields;
  Published
   {$IFDEF FPC}
   Property  DatabaseCharSet;
   {$ENDIF}
   Property  AfterInsert;
   Property  BeforePost;
   Property  FieldDefs;
  //  Property NullDefaults;
//   Property  Options        Default [];
   Property  OnFiltered;
  End;
  TUpdateKinds = set of TUpdateKind;

Var
 DefaultFieldClasses : Array[TFieldType] Of TFieldClass = (nil,                      { ftUnknown }
                                                           TStringField,             { ftString }
                                                           TSmallintField,           { ftSmallint }
                                                           TIntegerField,            { ftInteger }
                                                           TWordField,               { ftWord }
                                                           TBooleanField,            { ftBoolean }
                                                           TFloatField,              { ftFloat }
                                                           TCurrencyField,           { ftCurrency }
                                                           TBCDField,                { ftBCD }
                                                           TDateField,               { ftDate }
                                                           TTimeField,               { ftTime }
                                                           TDateTimeField,           { ftDateTime }
                                                           TBytesField,              { ftBytes }
                                                           TVarBytesField,           { ftVarBytes }
                                                           TAutoIncField,            { ftAutoInc }
                                                           TBlobField,               { ftBlob }
                                                           TMemoField,               { ftMemo }
                                                           TGraphicField,            { ftGraphic }
                                                           TBlobField,               { ftFmtMemo }
                                                           TBlobField,               { ftParadoxOle }
                                                           TBlobField,               { ftDBaseOle }
                                                           TBlobField,               { ftTypedBinary }
                                                           nil,                      { ftCursor }
                                                           TStringField,             { ftFixedChar }
                                                           TWideStringField,         { ftWideString }
                                                           TLargeIntField,           { ftLargeInt }
                                                           {$IFNDEF FPC}TADTField,{ ftADT }{$ELSE}Nil,{$ENDIF}
                                                           {$IFNDEF FPC}TArrayField,{ ftArray }{$ELSE}Nil,{$ENDIF}
                                                           {$IFNDEF FPC}TReferenceField,{ ftReference }{$ELSE}Nil,{$ENDIF}
                                                           {$IFNDEF FPC}TDataSetField,{ ftDataSet }{$ELSE}Nil,{$ENDIF}
                                                           TBlobField,               { ftOraBlob }
                                                           TMemoField,               { ftOraClob }
                                                           TVariantField,            { ftVariant }
                                                           {$IFNDEF FPC}TInterfaceField,{ ftInterface }{$ELSE}Nil,{$ENDIF}
                                                           {$IFNDEF FPC}TIDispatchField,{ ftIDispatch }{$ELSE}Nil,{$ENDIF}
                                                           TGuidField,{ ftGuid }
                                                           {$IFNDEF FPC}TSQLTimeStampField,       { ftTimeStamp }{$ELSE}Nil,{$ENDIF}
                                                           TFMTBcdField              { ftFMTBcd }
                                                           {$IFNDEF FPC}
                                                           {$IFDEF COMPILER10_UP},
                                                           TWideStringField,         { ftFixedWideChar }
                                                           TWideMemoField,           { ftWideMemo }
                                                           TSQLTimeStampField,       { ftOraTimeStamp }
                                                           TStringField              { ftOraInterval }
                                                           {$ENDIF}
                                                           {$ELSE},
                                                           TStringField              { ftOraInterval }
                                                           {$ENDIF}
                                                           {$IFNDEF FPC}
                                                           {$IFDEF COMPILER12_UP},
                                                           TLongWordField,           { ftLongWord }
                                                           TShortintField,           { ftShortint }
                                                           TByteField,               { ftByte }
                                                           TExtendedField,
                                                           nil,                      { ftConnection }
                                                           nil,                      { ftParams }
                                                           TStreamField              { ftStream }
                                                           {$ENDIF}
                                                           {$ELSE},
                                                           TStreamField              { ftStream }
                                                           {$ENDIF}
                                                           {$IFDEF COMPILER14_UP},
                                                           TSQLTimeStampOffsetField, { ftTimeStampOffset }
                                                           nil,                      { ftObject }
                                                           TSingleField              { ftSingle }{$ENDIF});

Function FieldTypeToString(AValue  : TFieldType) : String;
Function StringToFieldType(const S : string)  : Integer;


{$IFNDEF FPC}
 {$IF NOT Defined(HAS_FMX)}
  Function StrToHash(Const AValue : AnsiString): Int64;
 {$ELSE}
  Function StrToHash(Const AValue : String)    : Int64;
 {$IFEND}
{$ENDIF}

Resourcestring
 SForeignKeyIndexMustExists = 'FOREIGN KEY index must exists on field "%s".';
 SIntListCapacityError      = 'IntList capacity out of bounds (%d)';
 SIntListCountError         = 'IntList count out of bounds (%d)';
 SIntListIndexError         = 'IntList index out of bounds (%d)';
 SDuplicateFieldName        = 'A field named ''%s'' already exists';
 SInvalidColor              = '''%s'' is not a valid color value';
 SMoveBytesError            = 'Stream move butes error';
 SIllegalFileVersion        = 'Illegal File Version';
 SCorruptedFileHeader       = 'Corrupted File Header';
 SCorruptedDefinitions      = 'Corrupted Table Definitions, or Illegal Login';
 SFileSAlreadyExists        = 'File %s already exists';
 SIsDatafileReadOnly        = 'Is Datafile Read only';
 SIsDatafileHasStream       = 'Datafile has stream event';
 SWarnNextDefinitions       = 'Warning! Next table definitions.';
 SInvalidRecord             = 'GetRecord: Invalid record';
 SNotSupported              = 'AddRecord: not supported';
 SBookmarkDNotFound         = 'Bookmark %d not found';
 SUnsupportedTypeField      = '%s: unsupported type of field %s';
 SDbIsCurrentlyOpen         = 'Cannot perform operation -- Db is currently open';
 SCantAssingOpenTable       = 'Cannot assing an open table to a new file';
 SFieldsMustUnique          = 'Fields ''%s'' must have a unique value';
 SIsTableOpened             = 'Is Table opened';
 STableNotExists            = 'Table not exists';
 SDifferentDbOrNotAssigned  = 'Different Database or not assigned';
 STableAlreadyExists        = 'Table already exists';
 SIllegalLogin              = 'Illegal Login';
 SIllegalLoginFmt           = 'Illegal Login %s';
 SZerroFieldCount           = 'InitFieldsDefs: 0 fields?';
 SInitFieldsDefsNoType      = 'InitFieldsDefs: No type for field %d';
 SInitFieldsDefsNoName      = 'InitFieldsDefs: No name for field %d';
 SStructureOfIndexBroken    = 'Structure of index is broken, it is required automatic a recreation of an index';
 STheTableDontHaveName      = 'The table dont have name.';
 STheTableHaveIllegal       = 'The table have illegal symbol of name.';
 SLengthOutOfBounds         = 'Length out of bounds (%d)';
 SIndexNamedAlredyExists    = 'Index named "%s" already exists.';
 SEmptyIndexName            = 'Empty index name';
 SViolationOfForeignKey     = 'Violation of FOREIGN KEY constraint on field "' +
                              '%s".' + sLineBreak + 'Foreign key references are present for the record.';
 SViolationOfForeignKey2    = 'Violation of FOREIGN KEY constraint on field "' +
                              '%s".' + sLineBreak + 'Foreign key reference target does not exist.';
 SErrInvalidDataStream      = 'Error in data stream at position %d';
 SErrInvalidMarkerAtPos     = 'Wrong data stream marker at position %d. Got %d, expected %d';

 Var
  {$IFDEF SUPPORTS_CLASS_FIELDS}
  vTableStorage : TRESTDWTableStorageClass = TRESTDWTableStorage;
  {$ELSE}
  vTableStorage : TRESTDWTableStorage = nil;
  {$ENDIF}

Function GetFieldTypeB(FieldType : String)     : TFieldType;overload;
Function GetFieldTypeB(FieldType : TFieldType) : String;    overload;


Implementation

uses uRESTDWTools;

Const
 HeaderVersion      = 15;
 WindowsStopsAt1601 = 1602;
 HtmlColorPrefix    = '#';
{$IFNDEF COMPILER9_UP}
 LineBreak          = sLineBreak;
{$ENDIF}


{$IFDEF FPC}
type
{ TSQLTimeStamp }
  PSQLTimeStamp = ^TSQLTimeStamp;
  TSQLTimeStamp = packed record
    Year: Word;
    Month: Word;
    Day: Word;
    Hour: Word;
    Minute: Word;
    Second: Word;
    Fractions: LongWord;
  end;
{$ENDIF}

Type
  PTimeStamp = ^TTimeStamp;
  {$IFDEF COMPILER14_UP}
  PSQLTimeStampOffset = ^TSQLTimeStampOffset;
  {$ELSE}
  PSQLTimeStampOffset = PSQLTimeStamp;
  {$ENDIF}
  TSymbolType = (stBlank, stLet, stNum, stSym);

  TVariantArraySupport = class
  public
    class Function ConvertFrom(Source: PVariantArray; DataSet: TComponent): Boolean;
    class Function GetArray(DataSet: TComponent): PVariantArray;
    class Function GetCanConvert(DataSet: TComponent): Boolean;
    class function GetTableName(DataSet: TComponent): string;
    {$IFNDEF FPC}
     {$IF NOT Defined(HAS_FMX)}
      Class Function GetTableDefs(DataSet : TComponent) : AnsiString;
     {$ELSE}
      Class Function GetTableDefs(DataSet : TComponent) : String;
     {$IFEND}
    {$ELSE}
    Class Function GetTableDefs(DataSet : TComponent) : AnsiString;
    {$ENDIF}
  end;

  TBlobStream = class(TMemoryStream)
  private
    FFieldIndex: Integer;
    FRecNo: Integer;
    FDataSet: TRESTDWCustomDataSet;
  public
    destructor Destroy; Override;
  end;


/// <summary>
///   Extended is real type but is less portable.
///   Be careful using Extended if you are creating data files
///   to share across platforms.
/// </summary><summary> a := _VarFromReal(0.11111111111222333);
/// </summary><summary> b := a + _VarFromReal(1);
/// </summary><summary> a := _VarFromReal(_VarToReal(b));
/// </summary>
  TRealVariantType = class(TPublishableVariantType)
  protected
    Function GetInstance(Const V        : TVarData): TObject; Override;
  public
    Procedure Clear   (Var   V          : TVarData);          Override;
    Procedure Copy    (Var   Dest       : TVarData;
                       Const Source     : TVarData;
                       Const Indirect   : Boolean);           Override;
    Procedure Cast    (Var   Dest       : TVarData;
                       Const Source     : TVarData);          Override;
    Procedure CastTo  (Var   Dest       : TVarData;
                       Const Source     : TVarData;
                       Const AVarType   : TVarType);          Override;
    Procedure BinaryOp(Var   Left       : TVarData;
                       Const Right      : TVarData;
                       Const Operator   : TVarOp);            Override;
    Procedure Compare (Const Left,
                             Right      : TVarData;
                       Var Relationship : TVarCompareResult); Override;
  End;

{ Helper record that Peek At extended }

  PRealVarData = ^TRealVarData;
  TRealVarData = Packed Record
    VType: TVarType;
    {$IFDEF DELPHI64_TEMPORARY}
    Reserved1, Reserved2, Reserved3: Word;
    case Integer of
    0: (VExtended: Extended);
    1: (VLargest: TLargestVarData);
    {$ELSE}
    Reserved1, Reserved2: Word;
    VExtended: Extended;
    {$ENDIF}
  end;

  TTableObject = class(TObject)
  private
    FBase: Int64;
    FIndex: Integer;
    FName: string;
  end;

{$IFNDEF SUPPORTS_CLASS_FIELDS}
var
  FStaticBias: Double;
  FSwapDebugDataMode: Boolean;
{$ENDIF}

threadvar
  IndexDataSortRec: record
    vArray: PVariantArray;
    vFields: array of Integer;
    SCompare: array of TVariantArraySortCompare;
    fCaseInsensitive: Boolean;
    fSortDescs: array of Boolean;
    fOptions: TIndexListOptions;
    fAutoInc: Integer;
  end;

const
{$IFDEF COMPILER10_UP}
  FieldTypeIdents: array[dwftColor..dwftColor] of TIdentMapEntry = (
    (Value: dwftColor; Name: 'ftColor'));
{$ELSE}
  FieldTypeIdents: array[0..7] of TIdentMapEntry = (
    (Value: dwftTimeStampOffset; Name: 'ftTimeStampOffset'),
    (Value: dwftStream; Name: 'ftStream'),
    (Value: dwftSingle; Name: 'ftSingle'),
    (Value: dwftExtended; Name: 'ftExtended'),                   (* ftDouble *)
    (Value: dwftByte; Name: 'ftByte'),
    (Value: dwftShortint; Name: 'ftShortint'),
    (Value: dwftLongWord; Name: 'ftLongWord'),
    (Value: dwftColor; Name: 'ftColor'));
{$ENDIF}

{$IFDEF REGION}{$REGION ' Color idents '}{$ENDIF}

const
  clWebSnow = TColor($FAFAFF);
  clWebFloralWhite = TColor($F0FAFF);
  clWebLavenderBlush = TColor($F5F0FF);
  clWebOldLace = TColor($E6F5FD);
  clWebIvory = TColor($F0FFFF);
  clWebCornSilk = TColor($DCF8FF);
  clWebBeige = TColor($DCF5F5);
  clWebAntiqueWhite = TColor($D7EBFA);
  clWebWheat = TColor($B3DEF5);
  clWebAliceBlue = TColor($FFF8F0);
  clWebGhostWhite = TColor($FFF8F8);
  clWebLavender = TColor($FAE6E6);
  clWebSeashell = TColor($EEF5FF);
  clWebLightYellow = TColor($E0FFFF);
  clWebPapayaWhip = TColor($D5EFFF);
  clWebNavajoWhite = TColor($ADDEFF);
  clWebMoccasin = TColor($B5E4FF);
  clWebBurlywood = TColor($87B8DE);
  clWebAzure = TColor($FFFFF0);
  clWebMintcream = TColor($FAFFF5);
  clWebHoneydew = TColor($F0FFF0);
  clWebLinen = TColor($E6F0FA);
  clWebLemonChiffon = TColor($CDFAFF);
  clWebBlanchedAlmond = TColor($CDEBFF);
  clWebBisque = TColor($C4E4FF);
  clWebPeachPuff = TColor($B9DAFF);
  clWebTan = TColor($8CB4D2);
  // yellows/reds yellow -> rosybrown
  clWebYellow = TColor($00FFFF);
  clWebDarkOrange = TColor($008CFF);
  clWebRed = TColor($0000FF);
  clWebDarkRed = TColor($00008B);
  clWebMaroon = TColor($000080);
  clWebIndianRed = TColor($5C5CCD);
  clWebSalmon = TColor($7280FA);
  clWebCoral = TColor($507FFF);
  clWebGold = TColor($00D7FF);
  clWebTomato = TColor($4763FF);
  clWebCrimson = TColor($3C14DC);
  clWebBrown = TColor($2A2AA5);
  clWebChocolate = TColor($1E69D2);
  clWebSandyBrown = TColor($60A4F4);
  clWebLightSalmon = TColor($7AA0FF);
  clWebLightCoral = TColor($8080F0);
  clWebOrange = TColor($00A5FF);
  clWebOrangeRed = TColor($0045FF);
  clWebFirebrick = TColor($2222B2);
  clWebSaddleBrown = TColor($13458B);
  clWebSienna = TColor($2D52A0);
  clWebPeru = TColor($3F85CD);
  clWebDarkSalmon = TColor($7A96E9);
  clWebRosyBrown = TColor($8F8FBC);
  // greens palegoldenrod -> darkseagreen
  clWebPaleGoldenrod = TColor($AAE8EE);
  clWebLightGoldenrodYellow = TColor($D2FAFA);
  clWebOlive = TColor($008080);
  clWebForestGreen = TColor($228B22);
  clWebGreenYellow = TColor($2FFFAD);
  clWebChartreuse = TColor($00FF7F);
  clWebLightGreen = TColor($90EE90);
  clWebAquamarine = TColor($D4FF7F);
  clWebSeaGreen = TColor($578B2E);
  clWebGoldenRod = TColor($20A5DA);
  clWebKhaki = TColor($8CE6F0);
  clWebOliveDrab = TColor($238E6B);
  clWebGreen = TColor($008000);
  clWebYellowGreen = TColor($32CD9A);
  clWebLawnGreen = TColor($00FC7C);
  clWebPaleGreen = TColor($98FB98);
  clWebMediumAquamarine = TColor($AACD66);
  clWebMediumSeaGreen = TColor($71B33C);
  clWebDarkGoldenRod = TColor($0B86B8);
  clWebDarkKhaki = TColor($6BB7BD);
  clWebDarkOliveGreen = TColor($2F6B55);
  clWebDarkgreen = TColor($006400);
  clWebLimeGreen = TColor($32CD32);
  clWebLime = TColor($00FF00);
  clWebSpringGreen = TColor($7FFF00);
  clWebMediumSpringGreen = TColor($9AFA00);
  clWebDarkSeaGreen = TColor($8FBC8F);
  // greens/blues lightseagreen -> navy
  clWebLightSeaGreen = TColor($AAB220);
  clWebPaleTurquoise = TColor($EEEEAF);
  clWebLightCyan = TColor($FFFFE0);
  clWebLightBlue = TColor($E6D8AD);
  clWebLightSkyBlue = TColor($FACE87);
  clWebCornFlowerBlue = TColor($ED9564);
  clWebDarkBlue = TColor($8B0000);
  clWebIndigo = TColor($82004B);
  clWebMediumTurquoise = TColor($CCD148);
  clWebTurquoise = TColor($D0E040);
  clWebCyan = TColor($FFFF00);
  clWebAqua = TColor($FFFF00);
  clWebPowderBlue = TColor($E6E0B0);
  clWebSkyBlue = TColor($EBCE87);
  clWebRoyalBlue = TColor($E16941);
  clWebMediumBlue = TColor($CD0000);
  clWebMidnightBlue = TColor($701919);
  clWebDarkTurquoise = TColor($D1CE00);
  clWebCadetBlue = TColor($A09E5F);
  clWebDarkCyan = TColor($8B8B00);
  clWebTeal = TColor($808000);
  clWebDeepskyBlue = TColor($FFBF00);
  clWebDodgerBlue = TColor($FF901E);
  clWebBlue = TColor($FF0000);
  clWebNavy = TColor($800000);
  // violets/pinks darkviolet -> pink
  clWebDarkViolet = TColor($D30094);
  clWebDarkOrchid = TColor($CC3299);
  clWebMagenta = TColor($FF00FF);
  clWebFuchsia = TColor($FF00FF);
  clWebDarkMagenta = TColor($8B008B);
  clWebMediumVioletRed = TColor($8515C7);
  clWebPaleVioletRed = TColor($9370DB);
  clWebBlueViolet = TColor($E22B8A);
  clWebMediumOrchid = TColor($D355BA);
  clWebMediumPurple = TColor($DB7093);
  clWebPurple = TColor($800080);
  clWebDeepPink = TColor($9314FF);
  clWebLightPink = TColor($C1B6FF);
  clWebViolet = TColor($EE82EE);
  clWebKatyPerry = TColor($DEEDFC);
  clWebOrchid = TColor($D670DA);
  clWebPlum = TColor($DDA0DD);
  clWebThistle = TColor($D8BFD8);
  clWebHotPink = TColor($B469FF);
  clWebPink = TColor($CBC0FF);
  // blue/gray/black lightsteelblue -> black
  clWebLightSteelBlue = TColor($DEC4B0);
  clWebMediumSlateBlue = TColor($EE687B);
  clWebLightSlateGray  = TColor($998877);
  clWebWhite           = TColor($FFFFFF);
  clWebLightgrey       = TColor($D3D3D3);
  clWebGray            = TColor($808080);
  clWebSteelBlue     = TColor($B48246);
  clWebSlateBlue     = TColor($CD5A6A);
  clWebSlateGray     = TColor($908070);
  clWebWhiteSmoke    = TColor($F5F5F5);
  clWebSilver        = TColor($C0C0C0);
  clWebDimGray       = TColor($696969);
  clWebMistyRose     = TColor($E1E4FF);
  clWebDarkSlateBlue = TColor($8B3D48);
  clWebDarkSlategray = TColor($4F4F2F);
  clWebGainsboro     = TColor($DCDCDC);
  clWebDarkGray      = TColor($A9A9A9);
  clWebBlack         = TColor($000000);
  clAqua             = TColor($FFFF00);
  clBlack            = clWebBlack;
  clBlue             = TColor($FF0000);
  clFuchsia          = TColor($FF00FF);
  clGray             = TColor($808080);
  clGreen            = TColor($008000);
  clLime             = TColor($00FF00);
  clMaroon           = TColor($000080);
  clNavy             = TColor($800000);
  clOlive            = TColor($008080);
  clPurple           = TColor($800080);
  clRed              = TColor($0000FF);
  clSilver           = TColor($C0C0C0);
  clTeal             = TColor($808000);
  clWhite            = TColor($FFFFFF);
  clYellow           = TColor($00FFFF);


const
  ColorIdents: array[0..139] of TIdentMapEntry = (
    (Value: clWebAliceBlue; Name: 'Aliceblue'),
    (Value: clWebAntiqueWhite; Name: 'Antiquewhite'),
    (Value: clAqua; Name: 'Aqua'),
    (Value: clWebAquamarine; Name: 'Aquamarine'),
    (Value: clWebAzure; Name: 'Azure'),
    (Value: clWebBeige; Name: 'Beige'),
    (Value: clWebBisque; Name: 'Bisque'),
    (Value: clBlack; Name: 'Black'),
    (Value: clWebBlanchedAlmond; Name: 'Blanchedalmond'),
    (Value: clBlue; Name: 'Blue'),
    (Value: clWebBlueViolet; Name: 'Blueviolet'),
    (Value: clWebBrown; Name: 'Brown'),
    (Value: clWebBurlyWood; Name: 'Burlywood'),
    (Value: clWebCadetBlue; Name: 'Cadetblue'),
    (Value: clWebChartreuse; Name: 'Chartreuse'),
    (Value: clWebChocolate; Name: 'Chocolate'),
    (Value: clWebCoral; Name: 'Coral'),
    (Value: clWebCornflowerBlue; Name: 'Cornflowerblue'),
    (Value: clWebCornSilk; Name: 'Cornsilk'),
    (Value: clWebCrimson; Name: 'Crimson'),
    (Value: clWebCyan; Name: 'Cyan'),
    (Value: clWebDarkBlue; Name: 'Darkblue'),
    (Value: clWebDarkCyan; Name: 'Darkcyan'),
    (Value: clWebDarkGoldenrod; Name: 'Darkgoldenrod'),
    (Value: clWebDarkGray; Name: 'Darkgray'),
    (Value: clWebDarkGreen; Name: 'Darkgreen'),
    (Value: clWebDarkKhaki; Name: 'Darkkhaki'),
    (Value: clWebDarkMagenta; Name: 'Darkmagenta'),
    (Value: clWebDarkOliveGreen; Name: 'Darkolivegreen'),
    (Value: clWebDarkOrange; Name: 'Darkorange'),
    (Value: clWebDarkOrchid; Name: 'Darkorchid'),
    (Value: clWebDarkRed; Name: 'Darkred'),
    (Value: clWebDarkSalmon; Name: 'Darksalmon'),
    (Value: clWebDarkSeagreen; Name: 'Darkseagreen'),
    (Value: clWebDarkSlateBlue; Name: 'Darkslateblue'),
    (Value: clWebDarkSlateGray; Name: 'Darkslategray'),
    (Value: clWebDarkTurquoise; Name: 'Darkturquoise'),
    (Value: clWebDarkViolet; Name: 'Darkviolet'),
    (Value: clWebDeepPink; Name: 'Deeppink'),
    (Value: clWebDeepSkyblue; Name: 'Deepskyblue'),
    (Value: clWebDimgray; Name: 'Dimgray'),
    (Value: clWebDodgerBlue; Name: 'Dodgerblue'),
    (Value: clWebFirebrick; Name: 'Firebrick'),
    (Value: clWebFloralWhite; Name: 'Floralwhite'),
    (Value: clWebForestGreen; Name: 'Forestgreen'),
    (Value: clFuchsia; Name: 'Fuchsia'),
    (Value: clWebGainsboro; Name: 'Gainsboro'),
    (Value: clWebGhostWhite; Name: 'Ghostwhite'),
    (Value: clWebGold; Name: 'Gold'),
    (Value: clWebGoldenrod; Name: 'Goldenrod'),
    (Value: clGray; Name: 'Gray'),
    (Value: clGreen; Name: 'Green'),
    (Value: clWebGreenYellow; Name: 'Greenyellow'),
    (Value: clWebHoneydew; Name: 'Honeydew'),
    (Value: clWebHotPink; Name: 'Hotpink'),
    (Value: clWebIndianRed; Name: 'Indianred'),
    (Value: clWebIndigo; Name: 'Indigo'),
    (Value: clWebIvory; Name: 'Ivory'),
    (Value: clWebKhaki; Name: 'Khaki'),
    (Value: clWebLavender; Name: 'Lavender'),
    (Value: clWebLavenderBlush; Name: 'Lavenderblush'),
    (Value: clWebLawnGreen; Name: 'Lawngreen'),
    (Value: clWebLemonChiffon; Name: 'Lemonchiffon'),
    (Value: clWebLightBlue; Name: 'Lightblue'),
    (Value: clWebLightCoral; Name: 'Lightcoral'),
    (Value: clWebLightCyan; Name: 'Lightcyan'),
    (Value: clWebLightGoldenrodYellow; Name: 'Lightgoldenrodyellow'),
    (Value: clWebLightGreen; Name: 'Lightgreen'),
    (Value: clWebLightGrey; Name: 'Lightgrey'),
    (Value: clWebLightPink; Name: 'Lightpink'),
    (Value: clWebLightSalmon; Name: 'Lightsalmon'),
    (Value: clWebLightSeagreen; Name: 'Lightseagreen'),
    (Value: clWebLightSkyblue; Name: 'Lightskyblue'),
    (Value: clWebLightSlateGray; Name: 'Lightslategray'),
    (Value: clWebLightSteelBlue; Name: 'Lightsteelblue'),
    (Value: clWebLightYellow; Name: 'Lightyellow'),
    (Value: clLime; Name: 'Lime'),
    (Value: clWebLimeGreen; Name: 'Limegreen'),
    (Value: clWebLinen; Name: 'Linen'),
    (Value: clWebMagenta; Name: 'Magenta'),
    (Value: clMaroon; Name: 'Maroon'),
    (Value: clWebMediumAquamarine; Name: 'Mediumaquamarine'),
    (Value: clWebMediumBlue; Name: 'Mediumblue'),
    (Value: clWebMediumOrchid; Name: 'Mediumorchid'),
    (Value: clWebMediumPurple; Name: 'Mediumpurple'),
    (Value: clWebMediumSeagreen; Name: 'Mediumseagreen'),
    (Value: clWebMediumSlateBlue; Name: 'Mediumslateblue'),
    (Value: clWebMediumSpringGreen; Name: 'Mediumspringgreen'),
    (Value: clWebMediumTurquoise; Name: 'Mediumturquoise'),
    (Value: clWebMediumVioletRed; Name: 'Mediumvioletred'),
    (Value: clWebMidnightBlue; Name: 'Midnightblue'),
    (Value: clWebMintCream; Name: 'Mintcream'),
    (Value: clWebMistyRose; Name: 'Mistyrose'),
    (Value: clWebMoccasin; Name: 'Moccasin'),
    (Value: clWebNavajoWhite; Name: 'Navajowhite'),
    (Value: clNavy; Name: 'Navy'),
    (Value: clWebOldLace; Name: 'Oldlace'),
    (Value: clOlive; Name: 'Olive'),
    (Value: clWebOliveDrab; Name: 'Olivedrab'),
    (Value: clWebOrange; Name: 'Orange'),
    (Value: clWebOrangeRed; Name: 'Orangered'),
    (Value: clWebOrchid; Name: 'Orchid'),
    (Value: clWebPaleGoldenrod; Name: 'Palegoldenrod'),
    (Value: clWebPaleGreen; Name: 'Palegreen'),
    (Value: clWebPaleTurquoise; Name: 'Paleturquoise'),
    (Value: clWebPaleVioletRed; Name: 'Palevioletred'),
    (Value: clWebPapayaWhip; Name: 'Papayawhip'),
    (Value: clWebPeachPuff; Name: 'Peachpuff'),
    (Value: clWebPeru; Name: 'Peru'),
    (Value: clWebPink; Name: 'Pink'),
    (Value: clWebPlum; Name: 'Plum'),
    (Value: clWebPowderBlue; Name: 'Powderblue'),
    (Value: clPurple; Name: 'Purple'),
    (Value: clRed; Name: 'Red'),
    (Value: clWebRosyBrown; Name: 'Rosybrown'),
    (Value: clWebRoyalBlue; Name: 'Royalblue'),
    (Value: clWebSaddleBrown; Name: 'Saddlebrown'),
    (Value: clWebSalmon; Name: 'Salmon'),
    (Value: clWebSandyBrown; Name: 'Sandybrown'),
    (Value: clWebSeagreen; Name: 'Seagreen'),
    (Value: clWebSeashell; Name: 'Seashell'),
    (Value: clWebSienna; Name: 'Sienna'),
    (Value: clSilver; Name: 'Silver'),
    (Value: clWebSkyblue; Name: 'Skyblue'),
    (Value: clWebSlateBlue; Name: 'Slateblue'),
    (Value: clWebSlateGray; Name: 'Slategray'),
    (Value: clWebSnow; Name: 'Snow'),
    (Value: clWebSpringGreen; Name: 'Springgreen'),
    (Value: clWebSteelBlue; Name: 'Steelblue'),
    (Value: clWebTan; Name: 'Tan'),
    (Value: clTeal; Name: 'Teal'),
    (Value: clWebThistle; Name: 'Thistle'),
    (Value: clWebTomato; Name: 'Tomato'),
    (Value: clWebTurquoise; Name: 'Turquoise'),
    (Value: clWebViolet; Name: 'Violet'),
    (Value: clWebWheat; Name: 'Wheat'),
    (Value: clWhite; Name: 'White'),
    (Value: clWebWhiteSmoke; Name: 'Whitesmoke'),
    (Value: clYellow; Name: 'Yellow'),
    (Value: clWebYellowGreen; Name: 'Yellowgreen'));
{$IFDEF REGION}{$ENDREGION}{$ENDIF}

{$IFDEF REGION}{$REGION ' DCC Version '}{$ENDIF}
const

{ Version Numbers }

  VER130     = 130; //5
  VER140     = 140; //6
  VER150     = 150; //7
  VER160     = 160; //8
  VER170     = 170; //2005
  VER180     = 180; //2006
  VER185     = 185; //2007
  VER200     = 200; //2009
  VER210     = 210; //2010
  VER220     = 220; //XE
  VER230     = 230; //XE2
  VER240     = 240; //XE3
  VER250     = 250; //XE4
  VER260     = 260; //XE5
  VER270     = 270; //XE6
  VER280     = 280; //XE7

Function GetFieldTypeB(FieldType     : TFieldType)     : String;
Begin
 Result := 'ftUnknown';
 Case FieldType Of
  ftUnknown         : Result := 'ftUnknown';
  ftString          : Result := 'ftString';
  ftSmallint        : Result := 'ftSmallint';
  ftInteger         : Result := 'ftInteger';
  ftWord            : Result := 'ftWord';
  ftBoolean         : Result := 'ftBoolean';
  ftFloat           : Result := 'ftFloat';
  ftCurrency        : Result := 'ftCurrency';
  ftBCD             : Result := 'ftFloat';
  ftDate            : Result := 'ftDate';
  ftTime            : Result := 'ftTime';
  ftDateTime        : Result := 'ftDateTime';
  ftBytes           : Result := 'ftBytes';
  ftVarBytes        : Result := 'ftVarBytes';
  ftAutoInc         : Result := 'ftAutoInc';
  ftBlob            : Result := 'ftBlob';
  ftMemo            : Result := 'ftMemo';
  ftGraphic         : Result := 'ftGraphic';
  ftFmtMemo         : Result := 'ftFmtMemo';
  ftParadoxOle      : Result := 'ftParadoxOle';
  ftDBaseOle        : Result := 'ftDBaseOle';
  ftTypedBinary     : Result := 'ftTypedBinary';
  ftCursor          : Result := 'ftCursor';
  ftFixedChar       :
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := 'ftFixedChar';
   {$ELSE}
    Result := 'ftString';
   {$IFEND}
  {$ELSE}
   Result := 'ftString';
  {$ENDIF}
  ftWideString      :
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := 'ftWideString';
   {$ELSE}
    Result := 'ftString';
   {$IFEND}
  {$ELSE}
   Result := 'ftString';
  {$ENDIF}
  ftLargeint        : Result := 'ftLargeint';
  ftADT             : Result := 'ftADT';
  ftArray           : Result := 'ftArray';
  ftReference       : Result := 'ftReference';
  ftDataSet         : Result := 'ftDataSet';
  ftOraBlob         : Result := 'ftOraBlob';
  ftOraClob         : Result := 'ftOraClob';
  ftVariant         : Result := 'ftVariant';
  ftInterface       : Result := 'ftInterface';
  ftIDispatch       : Result := 'ftIDispatch';
  ftGuid            : Result := 'ftGuid';
  ftTimeStamp       : Result := 'ftTimeStamp';
  ftFMTBcd          : Result := 'ftFloat';
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
    ftSingle          : Result := 'ftSingle';
    ftWideMemo        : Result := 'ftWideMemo';
    ftFixedWideChar   : Result := 'ftFixedWideChar';
    ftOraTimeStamp    : Result := 'ftOraTimeStamp';
    ftOraInterval     : Result := 'ftOraInterval';
    ftLongWord        : Result := 'ftLongWord';
    ftShortint        : Result := 'ftShortint';
    ftExtended        : Result := 'ftFloat';
    ftByte            : Result := 'ftByte';
    ftConnection      : Result := 'ftConnection';
    ftParams          : Result := 'ftParams';
    ftStream          : Result := 'ftStream';
    ftTimeStampOffset : Result := 'ftTimeStampOffset';
    ftObject          : Result := 'ftObject';
   {$IFEND}
  {$ELSE}
   ftWideMemo         : Result := 'ftWideMemo';
   ftFixedWideChar    : Result := 'ftFixedWideChar';
  {$ENDIF}
 End;
End;

Function GetFieldTypeB(FieldType : String) : TFieldType;
Var
 vFieldType : String;
Begin
 Result     := ftString;
 vFieldType := Uppercase(FieldType);
 If vFieldType      = Uppercase('ftUnknown')         Then
  Result := ftUnknown
 Else If vFieldType = Uppercase('ftString')          Then
  Result := ftString
 Else If vFieldType = Uppercase('ftSmallint')        Then
  Result := ftSmallint
 Else If vFieldType = Uppercase('ftInteger')         Then
  Result := ftInteger
 Else If vFieldType = Uppercase('ftWord')            Then
  Result := ftWord
 Else If vFieldType = Uppercase('ftBoolean')         Then
  Result := ftBoolean
 Else If vFieldType = Uppercase('ftFloat')           Then
  Result := ftFloat
 Else If vFieldType = Uppercase('ftCurrency')        Then
  Result := ftCurrency
 Else If vFieldType = Uppercase('ftBCD')             Then
  Result := ftFloat
 Else If vFieldType = Uppercase('ftDate')            Then
  Result := ftDate
 Else If vFieldType = Uppercase('ftTime')            Then
  Result := ftTime
 Else If vFieldType = Uppercase('ftDateTime')        Then
  Result := ftDateTime
 Else If vFieldType = Uppercase('ftBytes')           Then
  Result := ftBytes
 Else If vFieldType = Uppercase('ftVarBytes')        Then
  Result := ftVarBytes
 Else If vFieldType = Uppercase('ftAutoInc')         Then
  Result := ftAutoInc
 Else If vFieldType = Uppercase('ftBlob')            Then
  Result := ftBlob
 Else If vFieldType = Uppercase('ftMemo')            Then
  Result := ftMemo
{$IFNDEF FPC}
 {$if CompilerVersion < 21} // delphi 7   compatibilidade enter Sever no XE e Client no D7
 Else If vFieldType = Uppercase('ftWideMemo')        Then
  Result := ftMemo
{$IFEND}
{$ENDIF}
 Else If vFieldType = Uppercase('ftGraphic')         Then
  Result := ftGraphic
 Else If vFieldType = Uppercase('ftFmtMemo')         Then
  Result := ftFmtMemo
 Else If vFieldType = Uppercase('ftParadoxOle')      Then
  Result := ftParadoxOle
 Else If vFieldType = Uppercase('ftDBaseOle')        Then
  Result := ftDBaseOle
 Else If vFieldType = Uppercase('ftTypedBinary')     Then
  Result := ftTypedBinary
 Else If vFieldType = Uppercase('ftCursor')          Then
  Result := ftCursor
 Else If vFieldType = Uppercase('ftFixedChar')       Then
  Result := ftFixedChar
 Else If vFieldType = Uppercase('ftWideString')      Then
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := ftWideString
   {$ELSE}
    Result := ftString
   {$IFEND}
  {$ELSE}
   Result := ftString
  {$ENDIF}
 Else If vFieldType = Uppercase('ftLargeint')        Then
  Result := ftLargeint
 Else If vFieldType = Uppercase('ftADT')             Then
  Result := ftADT
 Else If vFieldType = Uppercase('ftArray')           Then
  Result := ftArray
 Else If vFieldType = Uppercase('ftReference')       Then
  Result := ftReference
 Else If vFieldType = Uppercase('ftDataSet')         Then
  Result := ftDataSet
 Else If vFieldType = Uppercase('ftOraBlob')         Then
  Result := ftOraBlob
 Else If vFieldType = Uppercase('ftOraClob')         Then
  Result := ftOraClob
 Else If vFieldType = Uppercase('ftVariant')         Then
  Result := ftVariant
 Else If vFieldType = Uppercase('ftInterface')       Then
  Result := ftInterface
 Else If vFieldType = Uppercase('ftIDispatch')       Then
  Result := ftIDispatch
 Else If vFieldType = Uppercase('ftGuid')            Then
  Result := ftGuid
 Else If vFieldType = Uppercase('ftTimeStamp')       Then
  Begin
  {$IFNDEF FPC}
   Result := ftTimeStamp;
  {$ELSE}
   Result := ftDateTime;
  {$ENDIF}
  End
 Else If vFieldType = Uppercase('ftSingle')       Then
  Begin
  {$IFNDEF FPC}
   {$if CompilerVersion > 21} // Delphi 2010 pra cima
    Result := ftSingle;
   {$ELSE}
    Result := ftFloat;
   {$IFEND}
  {$ELSE}
   Result := ftFloat;
  {$ENDIF}
  End
 Else If vFieldType = Uppercase('ftFMTBcd')          Then
   Result := ftFloat
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
    Else If vFieldType = Uppercase('ftFixedWideChar')   Then
     Result := ftFixedWideChar
    Else If vFieldType = Uppercase('ftWideMemo')        Then
     Result := ftWideMemo
    Else If vFieldType = Uppercase('ftOraTimeStamp')    Then
     Result := ftOraTimeStamp
    Else If vFieldType = Uppercase('ftOraInterval')     Then
     Result := ftOraInterval
    Else If vFieldType = Uppercase('ftLongWord')        Then
     Result := ftLongWord
    Else If vFieldType = Uppercase('ftShortint')        Then
     Result := ftShortint
    Else If vFieldType = Uppercase('ftByte')            Then
     Result := ftByte
    Else If vFieldType = Uppercase('ftExtended')        Then
     Result := ftFloat
    Else If vFieldType = Uppercase('ftConnection')      Then
     Result := ftConnection
    Else If vFieldType = Uppercase('ftParams')          Then
     Result := ftParams
    Else If vFieldType = Uppercase('ftStream')          Then
     Result := ftStream
    Else If vFieldType = Uppercase('ftTimeStampOffset') Then
     Result := ftTimeStampOffset
    Else If vFieldType = Uppercase('ftObject')          Then
     Result := ftObject
   {$IFEND}
  (* {$if CompilerVersion =15}
   Else If vFieldType = Uppercase('ftWideMemo')   Then
     Result := ftMemo
   {$IFEND}
   *)
   {$ENDIF};
End;

Function ReadInteger(S : TStream) : Integer;
Begin
 S.ReadBuffer(Result, SizeOf(Result));
End;

Function ReadString(S : TStream) : String;
Var
 L : Integer;
 vTempString : String;
 Function GetAnsiString(Value : String) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  For I := InitStrPos To Length(Value) - FinalStrPos Do
   Begin
    If Value[I] <> #0 Then
     Result := Result + Value[I];
   End;
 End;
begin
 L := ReadInteger(S);
 Setlength(vTempString, L);
 If (L <> 0) then
  S.ReadBuffer(Pointer(vTempString)^, L);
 Result := GetAnsiString(vTempString);
End;

Procedure WriteInteger(S : TStream; Value : Integer);
Begin
 S.Write(Value, SizeOf(Value));
End;

Procedure WriteString(S : TStream; Value : String);
Var
 L : Integer;
Begin
 L := Length(Value) * SizeOf(Char);
 WriteInteger(S, L);
 If (L <> 0) Then
  S.WriteBuffer(Pointer(Value)^, L);
End;

Function dwBufferLen(Value : tBytes): Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For I := 0 To Length(Value) -1 Do
  Begin
   If Value[I] <> 0 Then
    Inc(Result)
   Else
    Break;
  End;
End;

{$IFDEF FPC}
Function IsSQLTimeStampBlank(Const TimeStamp : TSQLTimeStamp) : Boolean;
Begin
 Result := (TimeStamp.Year      = 0) And
           (TimeStamp.Month     = 0) And
           (TimeStamp.Day       = 0) And
           (TimeStamp.Hour      = 0) and
           (TimeStamp.Minute    = 0) and
           (TimeStamp.Second    = 0) and
           (TimeStamp.Fractions = 0);
End;

Function DateTimeToSQLTimeStamp(Const DateTime : TDateTime) : TSQLTimeStamp;
Var
 F : Word;
Begin
 DecodeDate(DateTime, Result.Year, Result.Month, Result.Day);
 DecodeTime(DateTime, Result.Hour, Result.Minute, Result.Second, F);
 Result.Fractions := F;
End;

Function SQLTimeStampToDateTime(Const DateTime : TSQLTimeStamp) : TDateTime;
Begin
 If IsSQLTimeStampBlank(DateTime) Then
  Result := 0
 Else
  Begin
   Result := EncodeDate(DateTime.Year, DateTime.Month, DateTime.Day);
   If Result >= 0 Then
    Result := Result + EncodeTime(DateTime.Hour, DateTime.Minute, DateTime.Second, DateTime.Fractions)
   Else
    Result := Result - EncodeTime(DateTime.Hour, DateTime.Minute, DateTime.Second, DateTime.Fractions);
  End;
End;
{$ENDIF}

Procedure ErrorFileVersion;
begin
  raise DwDatabaseError.Create(SIllegalFileVersion);
end;

Function FieldTypeToString(AValue: TFieldType): string;
Begin
 Result := GetFieldType(AValue);
End;

Function StringToFieldType(const S: string): Integer;
begin
  if not IdentToInt(S, Result, FieldTypeIdents) then
   Begin
    Result := Integer(GetFieldTypeB(S));
//    Result := GetEnumValue(TypeInfo(TFieldType), S);
//     Result := GetEnumValue(TypeInfo(TFieldType), S);
   End
  Else
   Result := Integer(GetFieldTypeB(S));
  If TFieldType(Result) = ftWideString Then
   Result := Integer(ftString);
end;

{$IFDEF REGION}{$REGION ' Misc routines '}{$ENDIF}
Function VariantAnsiSortCompareStr(const Value1, Value2: Variant): Integer;
const
  NullCmp: array[Boolean, Boolean] of ShortInt = ((2, -1),(1, 0));
begin
  Result := NullCmp[VarIsNull(Value1), VarIsNull(Value2)];
  if Result <> 2 then Exit;
  Result := AnsiCompareStr(Value1, Value2);
end;

Function VariantAnsiSortCompareText(const Value1, Value2: Variant): Integer;
const
  NullCmp: array[Boolean, Boolean] of ShortInt = ((2, -1),(1, 0));
begin
  Result := NullCmp[VarIsNull(Value1), VarIsNull(Value2)];
  if Result <> 2 then Exit;
  Result := AnsiCompareText(Value1, Value2);
end;

Function VariantArraySortCompare(const Value1, Value2: Variant): Integer;
begin
  if Value1 > Value2 then
    Result := 1 else
  if Value1 < Value2 then
    Result := -1 else
    Result := 0;
end;

Function VariantRealSortCompare(const Value1, Value2: Variant): Integer;
begin
  if PRealVarData(@Value1).VExtended > PRealVarData(@Value2).VExtended then
    Result := 1 else
  if PRealVarData(@Value1).VExtended < PRealVarData(@Value2).VExtended then
    Result := -1 else
    Result := 0;
end;

Function VariantIntSortCompare(const Value1, Value2: Variant): Integer;
begin
  if not VarIsType(Value1, varInteger) or
    not VarIsType(Value2, varInteger)
  then begin
    Result := VariantArraySortCompare(Value1, Value2);
    Exit;
  end;
  if TVarData(Value1).VInteger > TVarData(Value2).VInteger then
    Result := 1 else
  if TVarData(Value1).VInteger < TVarData(Value2).VInteger then
    Result := -1 else
    Result := 0;
end;

Function VariantKeySortCompare(const Value, Key: Variant): Integer;
var
  Value1, Value2: string;
begin
  Value2 := VarToStrDef(Key, '');
  Value1 := Copy(VarToStrDef(Value, ''), 1, Length(Value2));
  if IndexDataSortRec.fCaseInsensitive then
    Result := AnsiCompareText(Value1, Value2) else
  if Value1 > Value2 then
    Result := 1 else
  if Value1 < Value2 then
    Result := -1 else
    Result := 0;
end;

Function VariantMemSortCompare(const Value1, Value2: Variant): Integer;
var
  V1, V2: PVarData;
  I1, I2: Integer;
begin
  if not VarIsArray(Value1) or
    not VarIsArray(Value2)
  then begin
    Result := VariantArraySortCompare(Value1, Value2);
    Exit;
  end;
  V1 := PVarData(@Value1);
  V2 := PVarData(@Value2);
  I1 := V1.VArray.Bounds[0].ElementCount;
  I2 := V2.VArray.Bounds[0].ElementCount;
  if I1 > I2 then
    Result := 1 else
  if I1 < I2 then
    Result := -1 else
    Result := 0;
end;

Procedure QuickSort3(SortList: PIndexDataList; L, R: Integer;
  SCompare: TIndexDataSortCompare);
var
  I, J, P, T: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;

(*
  The Description of speedup of algorithm QuickSort. The Speedup is
  reached at the expense of two additional comparisons for calculation
  best median (element - handhold). In sorted data a median already
  best - additional comparisons do not bring any profits. I has added
  the counter on sorted given in Procedure of comparison.

  The Results of test for sorted data:
    63544056 - comparisons with my algorithm;
    63478522 - comparisons of standard algorithm QuickSort;
    65534 - considered difference. - useless comparisons - median did not move.

  Now for chaotic data (volume given same, only string by back forward):
    79811590 - comparisons with my algorithm;
    89129019 - comparisons of standard algorithm;
    -9317429 - considered difference.

  That is to say I win approximately 9 millions on chaotic data and lose
  65 thousands on already sorted. On small amounts difference data
  not essential. But as in my event - more 3õ millions, that 15 seconds
  I seem important.
*)

// Begining modification -->

    T := (P - I) shr 2;
    if T > 16 then
    begin
      if SCompare(SortList[P - T], SortList[P]) < 0 then
      begin
        if SCompare(SortList[P], SortList[P + T]) > 0 then
        begin
          if SCompare(SortList[P - T], SortList[P + T]) < 0 then
            Inc(P, T)
          else
            Dec(P, T);
        end;
      end else
      begin
        if SCompare(SortList[P], SortList[P + T]) < 0 then
        begin
          if SCompare(SortList[P - T], SortList[P + T]) > 0 then
            Inc(P, T)
          else
            Dec(P, T);
        end;
      end;
    end;

// End of modification <--

    repeat
      while SCompare(SortList[I], SortList[P]) < 0 do
      begin
        Inc(I);
        if I = P then
          Break;
      end;
      while SCompare(SortList[J], SortList[P]) > 0 do
      begin
        Dec(J);
        if J = P then
          Break;
      end;
      if I <= J then
      begin
        if I <> J then
        begin
          T := SortList[I];
          SortList[I] := SortList[J];
          SortList[J] := T;
          if P = I then
            P := J
          else if P = J then
            P := I;
          Inc(I);
          Dec(J);
        end else
        begin
          Inc(I);
          Dec(J);
          Break;
        end;
      end;
    until I > J;
    if L < J then
      QuickSort3(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

Function IndexDataSortCompare(Item1, Item2: Integer): Integer;
var
  I, N: Integer;
begin
  with IndexDataSortRec do
  begin
    N := vFields[0];
    Result := SCompare[0](
      vArray.DataByCell[N, Item1],
      vArray.DataByCell[N, Item2]);
    if fSortDescs[0] then
      Result := -Result;
    if Result <> 0 then
      Exit;
    for I := 1 to Length(vFields) - 1 do
    begin
      N := vFields[I];
      Result := SCompare[I](
        vArray.DataByCell[N, Item1],
        vArray.DataByCell[N, Item2]);
      if fSortDescs[I] then
        Result := -Result;
      if Result <> 0 then
        Exit;
    end;
    if (Result = 0) and (Item1 <> Item2) and (iloUnique in fOptions) then
      raise DwTableError.Create('Find not unique values');
    if Item1 > Item2 then
      Result := 1 else
    if Item1 < Item2 then
      Result := -1 else
      Result := 0;
  end;
end;

Function LocalSortCompare(Item1, Item2: Integer): Integer;
var
  I, N: Integer;
begin
  with IndexDataSortRec do
  begin
    N := vFields[0];
    Result := SCompare[0](
      vArray.DataByCell[N, Item1],
      vArray.DataByCell[N, Item2]);
    if fSortDescs[0] then
      Result := -Result;
    if Result <> 0 then
      Exit;
    for I := 1 to Length(vFields) - 1 do
    begin
      N := vFields[I];
      Result := SCompare[I](
        vArray.DataByCell[N, Item1],
        vArray.DataByCell[N, Item2]);
      if fSortDescs[I] then
        Result := -Result;
      if Result <> 0 then
        Exit;
    end;
    if fAutoInc >= 0 then
      Result := VariantIntSortCompare(
        vArray.DataByCell[fAutoInc, Item1],
        vArray.DataByCell[fAutoInc, Item2]);
  end;
end;

Procedure DynArrayToBinVariant(var V: Variant; const DynArray; Len: Integer);
var
{$IFDEF COMPILER16_UP}
  LVarBounds : Array of Integer;
{$ELSE}
  {$IFNDEF FPC}
   LVarBounds : Array of NativeInt;
  {$ELSE}
   LVarBounds : Array of SizeInt;
  {$ENDIF}
{$ENDIF}
begin
  LVarBounds := nil;

  { This resets the Variant to VT_EMPTY - flag which is used to determine whether the }
  { the cast to Variant succeeded or not }
  VarClear(V);

  { Get Variant-style Bounds (lo/hi pair) of Dynamic Array }
  SetLength(LVarBounds, 2);
  LVarBounds[0] := 0;
  LVarBounds[1] := Len - 1;

  { Create Variant of SAFEARRAY }
  V := VarArrayCreate(LVarBounds, varByte);
  Assert(VarArrayDimCount(V) = 1);

  { Keep the data around for a bit }
  VarArrayLock(V);
  try
    Move(Pointer(DynArray)^, PVarData(@V).VArray.Data^, Len);

  { Let go of the data }
  finally
    VarArrayUnlock(V);
  end;
end;

Function VariantCmp(const Left, Right: Variant): Boolean;
var
  B: Boolean;
  I, H: Integer;
begin
  Result := VarIsArray(Left);
  B := VarIsArray(Right);
  if Result and B then
  begin
    H := VarArrayHighBound(Left, 1);
    Result := H = VarArrayHighBound(Right, 1);
    if Result then
      for I := 0 to H do
      begin
        Result := Left[I] = Right[I];
        if not Result then
          Break;
      end;
  end else
  if not Result and not B then
    Result := Left = Right
  else
    Result := False;
end;

Function FindTable(List: TList; const Name: string): TTableObject;
  {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
var
  T: TTableObject;
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
  begin
    T := TTableObject(List[I]);
    if SameText(Name, T.FName) then
    begin
      Result := T;
      Exit;
    end;
  end;
  Result := nil;
end;

{$IFDEF FPC}
Function SameDefinitions(const S1, S2 : AnsiString) : Boolean;
{$ELSE}
{$IF CompilerVersion < 25}
Function SameDefinitions(const S1, S2 : AnsiString) : Boolean;
{$ELSE}
Function SameDefinitions(const S1, S2 : String)     : Boolean;
{$IFEND}
{$ENDIF}
  Procedure IgnoreCalc(L: TStringList);
    {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
  var
    I, P: Integer;
  begin
    for I := L.Count - 1 downto 0 do
    begin
      P := Pos(':calc', L.ValueFromIndex[I]);
      if P = 0 then
        P := Pos(':lookup', L.ValueFromIndex[I]);
      if P = 0 then Continue;
      L.Delete(I);
    end;
  end;

var
  L1, L2: TStringList;
begin
  L1 := TStringList.Create;
  try
    L1.Text := LowerCase(string(S1));
    IgnoreCalc(L1);
    L2 := TStringList.Create;
    try
      L2.Text := LowerCase(string(S2));
      IgnoreCalc(L2);
      Result := Trim(L1.Text) = Trim(L2.Text);
    finally
      L2.Free;
    end;
  finally
    L1.Free;
  end;
end;

{$IFDEF REGION}{$REGION ' Stream routines '}{$ENDIF}
Procedure MoveBytesInStream(Stream: TStream; const Offset, Count: Int64);

  Procedure RaiseException;
  begin
    raise EStreamError.Create(SMoveBytesError);
  end;

var
  Buffer: array[0..24*1024-1] of Byte;
  I, RPos, WPos: Int64;
  Len: Integer;
begin
  RPos := Stream.Position;
  if Offset > 0 then
  begin
    Inc(RPos, Count);
    if RPos > Stream.Size then RaiseException;
  end;
  WPos := RPos + Offset;
  if WPos < 0 then RaiseException;
  Len := SizeOf(Buffer);
  I := Count div Len;
  while I > 0 do
  begin
    if Offset > 0 then Dec(RPos, Len);
    Stream.Position := RPos;
    Stream.ReadBuffer(Buffer, Len);
    if Offset < 0 then Inc(RPos, Len) else
      Dec(WPos, Len);
    Stream.Position := WPos;
    Stream.WriteBuffer(Buffer, Len);
    if Offset < 0 then Inc(WPos, Len);
    Dec(I);
  end;
  Len := Count mod Len;
  if Offset > 0 then Dec(RPos, Len);
  Stream.Position := RPos;
  Stream.ReadBuffer(Buffer, Len);
  if Offset > 0 then Dec(WPos, Len);
  Stream.Position := WPos;
  Stream.WriteBuffer(Buffer, Len);
end;

Procedure AddBytesInStreamPosition(Stream: TStream; const Count: Int64);
var
  Delta, OldPos: Int64;
begin
  if Count > 0 then
  begin
    OldPos := Stream.Position;
    Delta := Stream.Size - OldPos;
    if Delta > 0 then
    begin
      MoveBytesInStream(Stream, Count, Delta);
      Stream.Position := OldPos;
    end else
      Stream.Size := OldPos + Count;
  end;
end;

Procedure DeleteBytesInStreamPosition(Stream: TStream; const Count: Int64);
var
  Delta, NewPos, OldPos: Int64;
begin
  if Count > 0 then
  begin
    OldPos := Stream.Position;
    NewPos := OldPos + Count;
    Delta := Stream.Size - NewPos;
    if Delta > 0 then
    begin
      Stream.Position := NewPos;
      MoveBytesInStream(Stream, -Count, Delta);
      Stream.Size := OldPos + Delta;
      Stream.Position := OldPos;
    end else
      Stream.Size := OldPos;
  end;
end;

Function pkAdler32(adler: LongWord; Buf: PByte; Len: LongWord): LongWord;
// adler32.c -- compute the Adler-32 checksum of a data stream
// Copyright (C) 1995-1998 Mark Adler
// For conditions of distribution and use, see copyright notice in zlib.h
const
  BASE = 65521;
  NMAX = 5552;
var
  s1, s2: LongWord;
  K: Integer;
begin
  if Buf = nil then
  begin
    Result := 1;
    exit;
  end;
  s1 := adler and $FFFF;
  s2 :=(adler shr 16) and $FFFF;
  while (Len > 0) do
  begin
    if Len < NMAX then K := Len else K := NMAX;
    Dec(Len, K);
    while (K > 0) do
    begin
      Inc(s1, Buf^);
      Inc(Buf);
      Inc(s2, s1);
      Dec(K);
    end;
    s1 := s1 mod BASE;
    s2 := s2 mod BASE;
  end;
  Result := (s2 shl 16) or s1;
end;

Function pkCRC32(CRC: LongWord; Buf: PByte; Len: LongWord): LongWord;
const
  CRCTable: array[0..255] of LongWord = (
    $00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F,
    $E963A535, $9E6495A3, $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
    $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91, $1DB71064, $6AB020F2,
    $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9,
    $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
    $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B, $35B5A8FA, $42B2986C,
    $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116, $21B4F4B5, $56B3C423,
    $CFBA9599, $B8BDA50F, $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190, $01DB7106,
    $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
    $7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB, $086D3D2D,
    $91646C97, $E6635C01, $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
    $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457, $65B0D9C6, $12B7E950,
    $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7,
    $A4D1C46D, $D3D6F4FB, $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA,
    $BE0B1010, $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81,
    $B7BD5C3B, $C0BA6CAD, $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
    $EAD54739, $9DD277AF, $04DB2615, $73DC1683, $E3630B12, $94643B84,
    $0D6D6A3E, $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
    $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5, $D6D6A3E8, $A1D1937E,
    $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60, $DF60EFC3, $A867DF55,
    $316E8EEF, $4669BE79, $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE, $B2BD0B28,
    $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
    $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F,
    $72076785, $05005713, $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
    $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21, $86D3D2D4, $F1D4E242,
    $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF, $F862AE69,
    $616BFFD3, $166CCF45, $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
    $A7672661, $D06016F7, $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC,
    $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693,
    $54DE5729, $23D967BF, $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
    $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);
begin
  if Buf = nil then
  begin
    Result := 0;
    exit;
  end;
  CRC := CRC xor $FFFFFFFF;
  while Len > 0 do
  begin
    CRC := CRCTable[(Integer(CRC) xor Buf^) and $FF] xor (CRC shr 8); Inc(Buf);
    Dec(Len);
  end;
  Result := CRC xor $FFFFFFFF;
end;

{$IFDEF FPC}
Function pkStrHash(const AValue: AnsiString) : Int64;
{$ELSE}
{$IF CompilerVersion < 25}
Function pkStrHash(const AValue: AnsiString) : Int64;
{$ELSE}
Function pkStrHash(const AValue: String)     : Int64;
{$IFEND}
{$ENDIF}
begin
  Result := pkAdler32(pkAdler32(0, nil, 0), PByte(@AValue[1]), Length(AValue));
  Result:= (Result shl 32) or pkCRC32(pkCRC32(0, nil, 0), PByte(@AValue[1]),
    Length(AValue));
end;

const
  _WBITS = 15; // 32K LZ77 window

var
  _BLOBW: Word;

Function _Bits(var Value: LongWord): LongWord;
  {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
label
  l0,l1,l2,l3,l4,l5,l6,l7,l8,l9,le;
begin
  goto l9; l0: Result := Result + Value - 1;
  goto le; l1: Result := Result shl Value;
  goto l0; l2: Value := Value shl Value;
  goto l1; l3: Dec(Value, Value and 1);
  goto l2; l4: Inc(Result, Byte(Result)+Value);
  goto l3; l5: Result := Swap(Word(Result));
  goto l4; l6: Inc(Result, 31 - (Result mod 31));
  goto l5; l7: Result := (Result shl 8) or (Value shl 6);
  goto l6; l8: Value := 3;
  goto l7; l9: Result := (Value - 8)*16 + 8;
  goto l8; le:
end;

Function pkBits(Value: LongWord
  {$IFDEF SUPPORTS_DEFAULTPARAMS} = _WBITS{$ENDIF}): LongWord;
label
  l0,l1,l2,l3,l4,l5,le;
begin
  goto l5; l0: Inc(Result, 3);
  goto le; l1: Result := Value + (Byte(Result) shr 1);
  goto l0; l2: Value := Result - Byte(Result);
  goto l1; l3: Result := Value - 8;
  goto l2; l4: Value := Result shr Value;
  goto l3; l5: Result := _Bits(Value);
  goto l4; le:
end;

{$IFDEF FPC}
Function SecondKeyBits(AValue: AnsiString): Integer;
{$ELSE}
{$IF CompilerVersion < 25}
Function SecondKeyBits(AValue: AnsiString): Integer;
{$ELSE}
Function SecondKeyBits(AValue: String): Integer;
{$IFEND}
{$ENDIF}
var
  x: packed record
    case Byte of
      0: (x: Integer);
      1: (w: array[0..1] of Word);
    end;
  w: Word;
  I: Integer;
begin
  x.x := 0;
  for I := 1 to Length(AValue) do
  begin
    x.x := x.x + (Byte(AValue[I]) * I);
    w := x.w[0];
    x.w[0] := x.w[1];
    x.w[1] := w shl 1;
  end;
  Result := x.x;
end;

Destructor TBlobStream.Destroy;
begin
  if Assigned(FDataSet) then
    FDataSet.SetBlobStream(Self);
  inherited Destroy;
end;

{$IFDEF REGION}{$REGION ' Char routines '}{$ENDIF}
{$IFDEF FPC}
Function GetSymbolType(C: AnsiChar): TSymbolType;
{$ELSE}
{$IF CompilerVersion < 25}
Function GetSymbolType(C: AnsiChar): TSymbolType;
{$ELSE}
Function GetSymbolType(C: Char): TSymbolType;
{$IFEND}
{$ENDIF}
begin
  case C of
    #0..#32: Result := stBlank;
    '0'..'9': Result := stNum;
    '!'..'/',':'..'@', '['..'^', '`', '{'..'~': Result := stSym;
  else
    Result := stLet;
  end;
end;

{$IFDEF FPC}
Procedure ParseWords(const S: AnsiString; L: TStrings);
{$ELSE}
{$IF CompilerVersion < 25}
Procedure ParseWords(const S: AnsiString; L: TStrings);
{$ELSE}
Procedure ParseWords(const S: String; L: TStrings);
{$IFEND}
{$ENDIF}
var
  I: Integer;
  st1, st2: TSymbolType;
  s2: string;
begin
  L.Clear;
  s2 := '';
  st1 := stBlank;
  for I := 1 to Length(S) do
  begin
    st2 := GetSymbolType(S[I]);
    if st1 <> st2 then
    begin
      if (s2 <> '') and (st1 = stLet) then
        L.Add(s2)
      else if (s2 <> '') and (st1 = stNum) then
        L.Add(s2);
      s2 := string(S[I]);
    end else
      s2 := s2 + string(S[I]);
    st1 := st2;
  end;
  if (s2 <> '') and (st1 = stLet) then
    L.Add(s2)
  else if (s2 <> '') and (st1 = stNum) then
    L.Add(s2);
end;

{$IFNDEF FPC}
{$IF NOT Defined(HAS_FMX)}
Function StrToHash(Const AValue : AnsiString): Int64;
{$ELSE}
Function StrToHash(Const AValue : String)    : Int64;
{$IFEND}
{$ELSE}
Function StrToHash(Const AValue : AnsiString): Int64;
{$ENDIF}
begin
  Result := pkAdler32(pkAdler32(0, nil, 0), PByte(@AValue[1]), Length(AValue));
  Result:= (Result shl 32) or pkCRC32(pkCRC32(0, nil, 0), PByte(@AValue[1]),
    Length(AValue));
  Result:= (Result shr 8) xor
          ((Result shl 56) xor -1);
end;

Function RPos(const Substr, S: string): Integer;
var
  I, X, Len: Integer;
begin
  Len := Length(SubStr);
  I := Length(S) - Len + 1;
  if (I <= 0) or (Len = 0) then
  begin
    RPos := 0;
    Exit;
  end else
  begin
    while I > 0 do
    begin
      if S[I] = SubStr[InitStrPos] then
      begin
        X := InitStrPos;
        while (X < Len) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = Len) then
        begin
          RPos := I;
          exit;
        end;
      end;
      Dec(I);
    end;
    RPos := 0;
  end;
end;

{$IFDEF FPC}
Procedure SwapShortString(var Value: ShortString);
{$ELSE}
{$IF CompilerVersion < 25}
Procedure SwapShortString(var Value: ShortString);
{$ELSE}
Procedure SwapShortString(var Value: String);
{$IFEND}
{$ENDIF}
var
  I, L, Len: Integer;
 {$IFDEF FPC}
  C: AnsiChar;
 {$ELSE}
  {$IF CompilerVersion < 25}
   C: AnsiChar;
  {$ELSE}
   C: Char;
  {$IFEND}
 {$ENDIF}
begin
  Len := Length(Value);
  L := Len;
  for I := 1 to Len div 2 do
  begin
   {$IFDEF FPC}
    C := AnsiChar(Ord(Value[L]) xor Byte(-I));
    Value[L] := AnsiChar(Ord(Value[I]) xor Byte(-I));
   {$ELSE}
    {$IF CompilerVersion < 25}
    C := AnsiChar(Ord(Value[L]) xor Byte(-I));
    Value[L] := AnsiChar(Ord(Value[I]) xor Byte(-I));
    {$ELSE}
    C := Char(Ord(Value[L]) xor Byte(-I));
    Value[L] := Char(Ord(Value[I]) xor Byte(-I));
    {$IFEND}
   {$ENDIF}
    Value[I] := C;
    Dec(L);
  end;
  if Len mod 2 = 1 then
  begin
    I := (Len div 2) + 1;
    {$IFDEF FPC}
    Value[I] := AnsiChar(Ord(Value[I]) xor Byte(-I));
    {$ELSE}
     {$IF CompilerVersion < 25}
      Value[I] := AnsiChar(Ord(Value[I]) xor Byte(-I));
     {$ELSE}
      Value[I] := Char(Ord(Value[I]) xor Byte(-I));
     {$IFEND}
    {$ENDIF}
  end;
end;

{$IFDEF FPC}
Procedure SwapString(var Value: AnsiString);
{$ELSE}
{$IF Defined(HAS_FMX)}
Procedure SwapString(var Value: String);
{$ELSE}
Procedure SwapString(var Value: AnsiString);
{$IFEND}
{$ENDIF}
var
  I, L, Len: Integer;
 {$IFDEF FPC}
  C: AnsiChar;
 {$ELSE}
  {$IF NOT Defined(HAS_FMX)}
   C: AnsiChar;
  {$ELSE}
   C: Char;
  {$IFEND}
 {$ENDIF}
begin
  Len := Length(Value);
  L := Len;
  for I := 1 to Len div 2 do
  begin
   {$IFDEF FPC}
    C := AnsiChar(Ord(Value[L]) xor Byte(-I));
    Value[L] := AnsiChar(Ord(Value[I]) xor Byte(-I));
   {$ELSE}
    {$IF NOT Defined(HAS_FMX)}
    C := AnsiChar(Ord(Value[L]) xor Byte(-I));
    Value[L] := AnsiChar(Ord(Value[I]) xor Byte(-I));
    {$ELSE}
    C := Char(Ord(Value[L]) xor Byte(-I));
    Value[L] := Char(Ord(Value[I]) xor Byte(-I));
    {$IFEND}
   {$ENDIF}
    Value[I] := C;
    Dec(L);
  end;
  if Len mod 2 = 1 then
  begin
    I := (Len div 2) + 1;
   {$IFDEF FPC}
    Value[I] := AnsiChar(Ord(Value[I]) xor Byte(-I));
   {$ELSE}
    {$IF NOT Defined(HAS_FMX)}
    Value[I] := AnsiChar(Ord(Value[I]) xor Byte(-I));
    {$ELSE}
    Value[I] := Char(Ord(Value[I]) xor Byte(-I));
    {$IFEND}
   {$ENDIF}
  end;
end;

{$IFNDEF COMPILER12_UP}
Function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean;
{$IFDEF SUPPORTS_OVERLOAD}
  overload;{$ENDIF} {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
begin
  Result := C in CharSet;
end;

{$IFDEF SUPPORTS_OVERLOAD}
Function CharInSet(C: WideChar; const CharSet: TSysCharSet): Boolean;
  overload; {$IFDEF SUPPORTS_INLINE}inline;{$ENDIF}
begin
  if (Ord(C) and $FF) = Ord(C) then
    Result := AnsiChar(C) in CharSet
  else
    Result := False;
end;
{$ENDIF}
{$ENDIF}
{$IFDEF REGION}{$ENDREGION}{$ENDIF}

{$IFDEF REGION}{$REGION ' Real variant type '}{$ENDIF}
var
 RealVariantType : TRealVariantType = nil;

Function _VarFromFloat(const AValue: Double): Variant;
begin
  VarClear(Result);
  PRealVarData(@Result).VType := RealVariantType.VarType;
  PRealVarData(@Result).VExtended :=
    StrToFloat(FloatToStrF(AValue, ffGeneral, 15, 0));
end;

Function _VarFromReal(const AValue: Extended): Variant;
begin
  VarClear(Result);
  PRealVarData(@Result).VType := RealVariantType.VarType;
  PRealVarData(@Result).VExtended := AValue;
end;

Function _VarIsReal(const AValue: Variant): Boolean;
begin
  Result := PRealVarData(@AValue).VType = RealVariantType.VarType;
end;

Function _VarToReal(const AValue: Variant): Extended;
var
  Dest: TVarData;
begin
  if PRealVarData(@AValue).VType = RealVariantType.VarType then
    Result := PRealVarData(@AValue).VExtended else
  begin
    RealVariantType.Cast(Dest, PVarData(@AValue)^);
    Result := PRealVarData(@Dest).VExtended;
  end;
end;

Function StrToFloatEx(Source: string; General: Boolean = False): Extended;
const
  DefaultDecimalSeparator = '.';
var
  P: Integer;
begin
  if General then
  begin
    P := Pos(DefaultDecimalSeparator, Source);
    if P > 0 then
      Source[P] := {$IFDEF COMPILER16_UP}FormatSettings.{$ENDIF}DecimalSeparator;
  end;
  if Source <> '' then
    Result := StrToFloat(Source) else
    Result := NaN;
end;

{ TRealVariantType }

Procedure TRealVariantType.BinaryOp(var Left: TVarData;
  const Right: TVarData; const Operator: TVarOp);
begin
 {$IFDEF FPC}
  with Left do
  case Operator of
    opAdd      : PRealVarData(@Left).VExtended := PRealVarData(@Left).VExtended + PRealVarData(@Right).VExtended;
    opSubtract : PRealVarData(@Left).VExtended := PRealVarData(@Left).VExtended - PRealVarData(@Right).VExtended;
    opMultiply : PRealVarData(@Left).VExtended := PRealVarData(@Left).VExtended * PRealVarData(@Right).VExtended;
    opDivide   : PRealVarData(@Left).VExtended := PRealVarData(@Left).VExtended / PRealVarData(@Right).VExtended;
  else
    RaiseInvalidOp;
  end;
 {$ELSE}
  {$IF CompilerVersion < 25}
   with TRealVarData(Left) do
    case Operator of
      opAdd: VExtended := VExtended + PRealVarData(@Right).VExtended;
      opSubtract: VExtended := VExtended - PRealVarData(@Right).VExtended;
      opMultiply: VExtended := VExtended * PRealVarData(@Right).VExtended;
      opDivide: VExtended := VExtended / PRealVarData(@Right).VExtended;
    else
      RaiseInvalidOp;
    end;
  {$ELSE}
    case Operator of
      opAdd: Variant(Left) := Variant(Left) + PRealVarData(@Right).VExtended;
      opSubtract: Variant(Left) := Variant(Left) - PRealVarData(@Right).VExtended;
      opMultiply: Variant(Left) := Variant(Left) * PRealVarData(@Right).VExtended;
      opDivide: Variant(Left) := Variant(Left) / PRealVarData(@Right).VExtended;
    else
      RaiseInvalidOp;
    end;
  {$IFEND}
 {$ENDIF}
end;

Procedure TRealVariantType.Cast(Var Dest : TVarData; Const Source : TVarData);
Var
 LSource : TVarData;
Begin
 VarDataInit(LSource);
 Try
  VarDataCopyNoInd(LSource, Source);
  If VarDataIsStr(LSource) then
   Begin
    {$IFDEF FPC}
     PRealVarData(@Dest).VExtended := StrToFloatEx(VarDataToStr(LSource));
    {$ELSE}
     {$IF CompilerVersion < 25}
     TRealVarData(Dest).VExtended  := StrToFloatEx(VarDataToStr(LSource));
     {$IFEND}
     Variant(Dest)                 := StrToFloatEx(VarDataToStr(LSource));
    {$ENDIF}
    Dest.VType                    := VarType;
   End;
 Finally
  VarDataClear(LSource);
 End;
End;

Procedure TRealVariantType.CastTo(Var   Dest     : TVarData;
                                  Const Source   : TVarData;
                                  Const AVarType : TVarType);
Var
 LTemp : TVarData;
Begin
 If Source.VType = VarType Then
   Case AVarType Of
    {$IFNDEF NEXTGEN}
      varOleStr : VarDataFromOleStr(Dest, WideString(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
    {$ENDIF !NEXTGEN}
    {$IFDEF COMPILER14_UP}
     {$IFDEF FPC}
      varString  : VarDataFromLStr(Dest, AnsiString(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
      varUString : VarDataFromStr(Dest, WideString(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
     {$ELSE}
      {$IF CompilerVersion < 25}
      varString  : VarDataFromLStr(Dest, AnsiString(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
      varUString : VarDataFromStr(Dest, WideString(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
      {$ELSE}
      varString  : Begin
                    {$IF (CompilerVersion = 29) or Defined(HAS_FMX)}  // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
                     VarDataFromStr(Dest, String(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
                    {$ELSE}
                     VarDataFromLStr(Dest, String(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
                    {$IFEND}
                   End;
      varUString : VarDataFromStr(Dest, String(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
      {$IFEND}
     {$ENDIF}
    {$ELSE}
      varString  : VarDataFromStr(Dest, AnsiString(FloatToStrF(PRealVarData(@Source).VExtended, ffGeneral, 19, 0)));
    {$ENDIF}
    Else
     VarDataInit(LTemp);
      try
        LTemp.VType := varDouble;
        LTemp.VDouble := PRealVarData(@Source).VExtended;
        VarDataCastTo(Dest, LTemp, AVarType);
      finally
        VarDataClear(LTemp);
      end;
   End
 Else
  Inherited;
end;

Procedure TRealVariantType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
end;

Procedure TRealVariantType.Compare(const Left, Right: TVarData;
  var Relationship: TVarCompareResult);
begin
  if PRealVarData(@Left).VExtended > PRealVarData(@Right).VExtended
  then
    Relationship := crGreaterThan else
  if PRealVarData(@Left).VExtended < PRealVarData(@Right).VExtended
  then
    Relationship := crLessThan else
    Relationship := crEqual;
end;

Procedure TRealVariantType.Copy(var Dest: TVarData; const Source: TVarData;
  const Indirect: Boolean);
begin
  PRealVarData(@Dest)^ := PRealVarData(@Source)^;
end;

Function TRealVariantType.GetInstance(const V: TVarData): TObject;
begin
  Result := nil;
end;
{$IFDEF REGION}{$ENDREGION}{$ENDIF}

{ TVariantArrayEnumerator }

{$IFDEF SUPPORTS_FOR_IN}
Constructor TVariantArrayEnumerator.Create(vArray: PVariantArray);
Begin
 Inherited Create;
 FRow   := -1;
 FArray := vArray;
End;

Function TVariantArrayEnumerator.GetCurrent: Integer;
begin
  Result := FRow;
end;

Function TVariantArrayEnumerator.MoveNext: Boolean;
begin
  Result := FRow < FArray.RecCount - 1;
  if Result then
    Inc(FRow);
end;
{$ENDIF}

{ TVariantArray }

procedure TVariantArray.Add(const Args: array of const);
var
  I: Integer;
  PValue: PVarRec;
  E1: Extended;
  E2: Double;
  E3: TBcd;
{$IFDEF COMPILER10_UP}
  E4: Single;
{$ENDIF}
  B: array of Byte;
begin
  Assert(Length(Args) = FieldCount, SVarArrayBounds);
  Append;
  PValue := PVarRec(@Args);
  for I := 0 to High(Args) do
  begin
    case FDataType[I] of
      ftString   : Data[I] := {$IFNDEF FPC}
                               {$IF Defined(HAS_FMX)}
                                String(PChar(PValue.VUnicodeString));
                               {$ELSE}
                                String(PChar(PValue.VString));
                               {$IFEND}
                               {$ELSE}
                                String(PChar(PValue.VString));
                               {$ENDIF}
      ftSmallint : Data[I] := SmallInt(PValue.VInteger);
{$IFDEF COMPILER12_UP}
      ftLongWord : Data[I] := LongWord(PValue.VInteger);
      ftShortint : Data[I] := Shortint(PValue.VInteger);
      ftByte     : Data[I] := Byte(PValue.VInteger);
      ftExtended : Data[I] := Extended(PValue.VExtended^);
{$ENDIF}
{$IFDEF COMPILER14_UP}
      ftSingle:
        begin
         E4 := PValue.VExtended^;
         Data[I] := E4;
        end;
      ftTimeStampOffset:
        begin
         E2 := PValue.VExtended^;
         Data[I] := TDateTime(E2);
        end;
{$ENDIF}
      ftInteger,
      ftDate     : Data[I] := Integer(PValue.VInteger);
      ftWord     : Data[I] := Word(PValue.VInteger);
      ftBoolean  : Data[I] := WordBool(PValue.VBoolean);
      ftFloat    :
       Begin
        E2 := PValue.VExtended^;
        Data[I] := E2;
       End;
      ftCurrency : Data[I] := PValue.VCurrency^;
      ftBCD:
        begin E1 := PValue.VExtended^; Data[I] := E1; end;
      ftFMTBcd:
        begin DoubleToBcd(PValue.VExtended^, E3); Data[I] := VarFMTBcdCreate(E3); end;
      ftLargeint: Data[I] := Int64(PValue.VInt64^);
      ftVariant: Data[I] := Variant(PValue.VVariant^);
      ftInterface: Data[I] := IUnknown(PValue.VInterface);
      ftIDispatch: Data[I] := IDispatch(PValue.VInterface);
      ftWideString:
        Data[I] := {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                    String(PChar(PValue.VUnicodeString));
                    {$ELSE}
                    WideString(PWideChar(PValue.VString));
                    {$IFEND}
                   {$ELSE}
                    WideString(PWideChar(PValue.VString));
                   {$ENDIF}
      ftBytes:
        begin
          Pointer(B) := PValue.VPointer;
          DynArrayToBinVariant(FData[FCursor + I], B, Length(B));
          Pointer(B) := nil;
        end;
    else
      Assert(False, SVarInvalid);
    end;
    Inc(PValue);
  end;
end;

procedure TVariantArray.Append;
var
  I: Integer;
begin
  FCursor := Length(FData);
  SetLength(FData, Length(FData) + FieldCount);
  For I := 0 To FieldCount - 1 Do
   If not (dwNotNull in FFields[I].Attributes) then
     PVarData(@FData[FCursor + I]).VType := varNull;
end;

procedure TVariantArray.RemoveIndex(List: TIndexList);
Begin
 If Assigned(FIndexes) then
  FIndexes.Remove(List);
End;

{$IFDEF FPC}
Procedure TVariantArray.SetDatabaseCharSet  (Value  : TDatabaseCharSet);
Begin
 vDatabaseCharSet := Value;
End;
{$ENDIF}

function TVariantArray.GetIndexes(Index: Integer): TIndexList;
Begin
 If Assigned(FIndexes) Then
  Result := FIndexes[Index]
 Else
  Result := nil;
End;

function TVariantArray.AppendField(FieldDef, Size, Precision: Integer;
  Attributes: TDataAttributes; const Name, At: String): Integer;
 Function FieldExists(FieldName : String; Var FieldIndex : Integer) : Boolean;
 Var
  I : Integer;
 Begin
  Result     := False;
  FieldIndex := -1;
  For I := 0 to Length(FFieldName) -1 Do
   Begin
    Result     := Lowercase(FFieldName[I]) = Lowercase(FieldName);
    If Result Then
     Begin
      FieldIndex := I;
      Break;
     End;
   End;
 End;
Var
 vFieldIndex : Integer;
begin
 If FieldExists(Name, vFieldIndex) Then
  Begin
   Result := vFieldIndex;
   Exit;
  End;
  Result := FFieldCount;
  Assert(FieldIndex[Name] < 0, Format(SDuplicateFieldName, [Name]));
  case FieldDef of
    dwftUnknown, dwftCursor, dwftADT, dwftArray, dwftReference, dwftDataSet:
      raise DwArrayError.CreateFmt(SUnsupportedTypeField, [At, Name]);
  else
    if FieldDef > Integer(High(TFieldType)) then
      case FieldDef of
        dwftExtended, dwftStream, dwftTimeStampOffset, dwftColor: ;
      else
        raise DwArrayError.CreateFmt(SUnsupportedTypeField, [At, Name]);
      end;
  end;
  Inc(FFieldCount);
  SetLength(FFieldName, FieldCount);
  SetLength(FDataType, FieldCount);
  SetLength(FFields, FieldCount);
  FFieldName[Result] := Name;
  SetFieldType(Result, FieldDef);
  case FieldDef of
{$IFNDEF COMPILER9_UP}
    dwftBytes, dwftVarBytes,
{$ENDIF}
    dwftString, dwftWideString:
      if Size = 0 then
        Size := $FF;
    dwftGuid:
      Size := 38;
  end;
  FFields[Result].Size := Size;
  FFields[Result].Attributes := Attributes;
  If FFields[Result].FieldType = ftFloat Then
   Begin
    If Size > LazDigitsSize Then
     FFields[Result].Size       := LazDigitsSize;
    If (Precision > MaxFloatLaz) Or
       (Precision = 0)           Then
     FFields[Result].Precision  := MaxFloatLaz
    Else
     FFields[Result].Precision  := Precision;
   End;
end;

procedure TVariantArray.Assign(const Source: TVariantArray);
var
  I: Integer;
begin
  FData := nil;
  vOnWriterProcess := Source.OnWriterProcess;
  SetLength(FData, Length(Source.FData));
  for I := 0 to Length(FData) - 1 do
    FData[I] := Source.FData[I];
  FCursor := Source.FCursor;
  FFieldCount := Source.FFieldCount;
  SetLength(FFieldName, Length(Source.FFieldName));
  for I := 0 to Length(FFieldName) - 1 do
    FFieldName[I] := Source.FFieldName[I];
  FDataType := Source.FDataType;
  FFields := Source.FFields;
  FRestrictLength := Source.FRestrictLength;
end;

function TVariantArray.Bof: Boolean;
begin
  Result := FCursor <= 0;
end;

procedure TVariantArray.Clear;
begin
 If RecCount > 0 Then
  SetLength(FData, 0);
 FCursor := -1;
end;

procedure TVariantArray.CopyFrom(DataSet: TDataSet; ACount: Integer);
var
  I, F2, Temp: Integer;
  F1: TField;
begin
  Temp := DataSet.RecNo;
  if ACount < 0 then
  begin
    DataSet.Last;
    DataSet.First;
    ACount := DataSet.RecordCount;
  end;
  Clear;
  SetLength(FData, FieldCount * ACount);
  FCursor := 0;
  if ACount = 0 then
  begin
    DataSet.RecNo := Temp;
    Exit;
  end;
  try
    while not DataSet.Eof do
    begin
      for I := 0 to DataSet.FieldCount - 1 do
      begin
        F1 := DataSet.Fields[I];
        F2 := FieldIndex[F1.FieldName];
        if not ((F2 < 0) or Calculated[F2]) then
          Data[F2] := F1.Value;
      end;
      DataSet.Next;
      RecNo := RecNo + 1;
    end;
  except on E: Exception do
    begin
      Clear;
      Assert(False, E.Message);
    end;
  end;
  DataSet.RecNo := Temp;
  RecNo := Temp;
end;

{
constructor TVariantArray.Create;
Begin
 Inherited;
 FPrecision := MaxFloatLaz;
End;
}

procedure TVariantArray.CustomSort(const Name: String;
  SCompare: TIndexDataSortCompare; const Descs: array of Boolean;
  CaseInsensitive: Boolean);
var
  fld: array of Integer;
  I: Integer;
begin
  if RecCount < 2 then Exit;
  ParseKeyFields(Name, fld);
  Assert(Length(fld) > 0, SVarArrayBounds);
  Assert(Length(fld) = Length(Descs), SVarArrayBounds);
  SetLength(IndexDataSortRec.fSortDescs, Length(Descs));
  for I := 0 to High(Descs) do
    IndexDataSortRec.fSortDescs[I] := Descs[I];
  IndexDataSortRec.fCaseInsensitive := CaseInsensitive;
  QuickSort(0, RecCount - 1, SCompare);
  SetLength(IndexDataSortRec.fSortDescs, 0);
end;

procedure TVariantArray.Delete;
var
  I: Integer;
  V: PVarData;
//  List: TIndexList;
begin
  try
    Assert((FCursor >= 0) and (Length(FData) > FCursor), SVarArrayBounds);
    for I := 0 to FieldCount - 1 do
      FData[FCursor + I] := NULL;
    Move(FData[FCursor + FieldCount], FData[FCursor],
      (Length(FData) - FCursor - FieldCount) * Sizeof(TVarData));
    FillChar(FData[Length(FData) - FieldCount], FieldCount * Sizeof(Variant), 0);
    for I := Length(FData) - FieldCount to Length(FData) - 1 do
    begin
      V := PVarData(@FData[I]);
      V.VType := varEmpty;
    end;
    SetLength(FData, Length(FData) - FieldCount);
    if Length(FData) = 0 then FCursor := -1;
  except on E: Exception do
    FIsCancelDelete := False;
  end;
end;

{
destructor TVariantArray.Destroy;
Begin
 Done;
 Inherited;
End;
}

procedure TVariantArray.DoneIndexes;
Begin
 FreeAndNil(FIndexes);
End;

procedure TVariantArray.Done;
begin
  Try
   Clear;
  Except

  End;
  Finalize(FDataType);
  Finalize(FFieldName);
  Finalize(FFields);
  FFieldCount := 0;
  FTable := nil;
  FRestrictLength := [];
  FIndexes := Nil;
  FSaveCapacity := 32*1024;
  FCursor := -1;
end;

function TVariantArray.Eof: Boolean;
begin
  Result := (FCursor < 0) or (FCursor = Length(FData));
end;

procedure TVariantArray.Exchange(RecNo1, RecNo2: Integer);
var
  Temp: Pointer;
begin
  if RecNo1 = RecNo2 then Exit;
  Assert((RecNo1 >= 0) and (Length(FData) > RecNo1 * FieldCount)
    and (RecNo2 >= 0) and (Length(FData) > RecNo2 * FieldCount), SVarArrayBounds);
  GetMem(Temp, FieldCount * Sizeof(Variant));
  try
    Move(FData[RecNo1 * FieldCount], Temp^, FieldCount * Sizeof(Variant));
    Move(FData[RecNo2 * FieldCount], FData[RecNo1 * FieldCount], FieldCount * Sizeof(Variant));
    Move(Temp^, FData[RecNo2 * FieldCount], FieldCount * Sizeof(Variant));
  finally
    FreeMem(Temp);
  end;
end;

function TVariantArray.FindOrder(Order: Integer): Integer;
begin
  for Result := 0 to FieldCount - 1 do
    if FFields[Result].Order = Order then
      Exit;
  Result := -1
end;

procedure TVariantArray.First;
begin
  if Length(FData) > 0 then FCursor := 0 else FCursor := -1;
end;

function TVariantArray.GetAutoIncField: Integer;
begin
  for Result := 0 to FieldCount - 1 do
    if FFields[Result].FieldType = ftAutoInc then
      Exit;
  Result := -1
end;

Function TVariantArray.GetCalcField(Index : Integer): Boolean;
Begin
 Result := dwCalcField in FFields[Index].Attributes;
End;

Procedure TVariantArray.LoadFromStream(Stream : TStream);
Var
 TableHeader    : TRESTDWDbTableHeader;
 AutoIncVal     : Int64;
 RecordCount,
 VersionNumber,
 I              : Integer;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    S, Definitions : String;
   {$ELSE}
    S, Definitions : Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    S, Definitions : Utf8String;
   {$ELSE}
    S, Definitions : AnsiString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  S, Definitions : AnsiString;
 {$ENDIF}
 StartPos       : Int64;
 OldHeader,
 AbortProcess   : Boolean;
 T              : TComponent;
 Idx            : TList;
 Temp           : TVariantArray;
Begin
 AbortProcess  := False;
 StartPos      := Stream.Position;
 // initialize local data (loading the header)
 Stream.ReadBuffer(TableHeader, Sizeof(TRESTDWDbTableHeader));
 //canceled version
 If TableHeader.VersionNumber = 16 Then
  TableHeader.VersionNumber := 15;
 OldHeader     := TableHeader.VersionNumber = HeaderVersion - 1;
 RecordCount   := TableHeader.RecordCount;
 VersionNumber := TableHeader.VersionNumber;
 SourceSide    := TableHeader.SourceSide;
 If RecordCount <> -TableHeader.CheckRecCount Then
  Raise DwTableError.Create(Format(cInvalidBinaryRequest, ['Invalid Header.']));
 If VersionNumber <> HeaderVersion Then
  ErrorFileVersion;
 S := '';
 Stream.ReadBuffer(I, SizeOf(I));
 If (I > TableHeader.DataSize) Or
    (I > MAXSHORT)             Or
    (I < 0)                    Then
  Raise DWTableError.Create(Format(cInvalidBinaryRequest, ['Invalid table size']));
 SetLength(S, I);
// Stream.ReadBuffer(S[1], I);
 {$IFDEF FPC}
  If I <> 0 Then
   Stream.ReadBuffer(Pointer(S)^, I);
  S := GetStringEncode(S, vDatabaseCharSet);
 {$ELSE}
  If I <> 0 Then
   Stream.Read(S[InitStrPos], I);
 {$ENDIF}
// SwapString(S);
 Definitions := '';
// T := FTable;
// Idx := FIndexes;
 If (S <> '') Then
  Begin
   Try
    Init(S);
    If vTableStorage.LoadArrayDefinitions then
     Exit;
    Definitions := S;
   Finally
  //  FTable := T;
  //  FIndexes := Idx;
   End;
  End;
 If Not SameDefinitions(S, Definitions) Then
  Begin
   If Not TVariantArraySupport.GetCanConvert(T) Then
    Raise DWTableError.Create(SWarnNextDefinitions)
   Else
    Begin
     Stream.Position := StartPos;
     {$IFNDEF FPC}{$IFNDEF SUPPORTS_ENHANCED_RECORDS}Temp := TVariantArray.Create;{$ENDIF}
     {$ELSE}Temp := TVariantArray.Create;{$ENDIF}
     Temp.Init(S);
     Temp.LoadFromStream(Stream);
     FModified := OldHeader or TVariantArraySupport.ConvertFrom(@Temp, T);
     Temp.Done;
     {$IFNDEF FPC}{$IFNDEF SUPPORTS_ENHANCED_RECORDS}Temp.Free;{$ENDIF}
     {$ELSE}Temp.Free;{$ENDIF}
     Exit;
    End;
  End;
 Clear;
 SetLength(FData, FieldCount * TableHeader.RecordCount);
 vTableStorage.GetTimeZoneBias;
 For I := 0 To RecordCount - 1 Do
  Begin
   FCursor := 0;
   LoadRecordFromStream(Stream, I);
   If Assigned(OnWriterProcess) Then
    OnWriterProcess(TRESTDWCustomDataSet(FTable), I +1, RecordCount, AbortProcess);
   If AbortProcess Then
    Break;
  End;
 First;
 FModified := OldHeader;
End;

Procedure TVariantArray.SaveToStream(Stream: TStream);
Var
 TableHeader : TRESTDWDbTableHeader;
 I, Temp     : Integer;
 EndPos,
 StartPos    : Int64;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Defined(HAS_UTF8)} //TODO
    {$IF CompilerVersion < 31}
    S        : String;
    {$ELSE}
    S        : Utf8String;
    {$IFEND}
   {$ELSE}
    S        : AnsiString;
   {$IFEND}
  {$ELSE}
   S         : AnsiString;
  {$IFEND}
 {$ELSE}
  S          : AnsiString;
 {$ENDIF}
Begin
 StartPos := Stream.Position;
 With TableHeader Do
  Begin
   VersionNumber := HeaderVersion;
   DataSize      := 0;
   RecordCount   := RecCount;
   CheckRecCount := -TableHeader.RecordCount;
   HashData      := 0;
   AutoIncVal    := 0; // used later
   If Assigned(FIndexes) Then
    IndexCount   := FIndexes.Count
   Else
    IndexCount   := 0; // used later
   {$IFNDEF FPC}
   SourceSide    := dwDelphi;
   {$ELSE}
   SourceSide    := dwLazarus;
   {$ENDIF}
  End;
 SourceSide      := TableHeader.SourceSide;
 Stream.WriteBuffer(TableHeader, SizeOf(TableHeader));
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Defined(HAS_UTF8)} //TODO
    S := String(GetDefinitions);
   {$ELSE}
    S := AnsiString(GetDefinitions);
   {$IFEND}
  {$ELSE}
   S := AnsiString(GetDefinitions);
  {$IFEND}
 {$ELSE}
  S := AnsiString(GetDefinitions);
 {$ENDIF}
// SwapString(S);
 I := Length(S);
 Stream.WriteBuffer(I, SizeOf(I));
 Stream.WriteBuffer(S[InitStrPos], I);
 Temp := RecNo;
 First;
 vTableStorage.GetTimeZoneBias;
 For I := 0 To TableHeader.RecordCount - 1 Do
  Begin
   SaveRecordToStream(Stream);
   Next;
  End;
 RecNo := Temp;
 EndPos := Stream.Position;
 TableHeader.DataSize := EndPos - StartPos - SizeOf(TableHeader);
 Stream.Position := StartPos;
 Stream.WriteBuffer(TableHeader, SizeOf(TableHeader));
 Stream.Position := EndPos;
End;

function TVariantArray.GetData(Index: Integer): Variant;
begin
  Assert((Index < FieldCount) and (Index >= 0) and (FCursor >= 0), SVarArrayBounds);
  Inc(Index, FCursor);
  Assert(Length(FData) > Index, SVarArrayBounds); //<-- need if not AV...
  Result := FData[Index];
end;

{$IFDEF FPC}
function TVariantArray.GetDataAnsiString(Index: Integer): AnsiString;
{$ELSE}
{$IF CompilerVersion < 25}
Function TVariantArray.GetDataAnsiString(Index : Integer) : AnsiString;
{$ELSE}
Function TVariantArray.GetDataAnsiString(Index : Integer) : String;
{$IFEND}
{$ENDIF}
Begin
 Assert((Index < FieldCount) and (Index >= 0), SVarArrayBounds);
 If Eof then
  Result := ''
 Else
  Begin
   {$IFDEF COMPILER14}
   {$WARNINGS OFF}
    Result := UnicodeString(PVarData(@FData[FCursor + Index]).VUString);
   {$WARNINGS ON}
    {$ELSE}
     Result := {$IFNDEF FPC}
                {$IF Defined(HAS_FMX)}
                 {$IF Defined(HAS_UTF8)}
                  {$IF (CompilerVersion = 29) or Defined(HAS_FMX)} // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
                  UnicodeString(PVarData(@FData[FCursor + Index]).VUString);
                  {$ELSE}
                  UnicodeString(RawByteString(PVarData(@FData[FCursor + Index]).VUString));
                  {$IFEND}
                 {$ELSE}
                  PAnsiChar(PVarData(@FData[FCursor + Index]).VString);
                 {$IFEND}
                {$ELSE}
                 {$IF (CompilerVersion > 22)} // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
                  UnicodeString(RawByteString(PVarData(@FData[FCursor + Index]).VUString));
                 {$ELSE}
                  PAnsiChar(PVarData(@FData[FCursor + Index]).VString);
                 {$IFEND}
                {$IFEND}
               {$ELSE}
                PAnsiChar(PVarData(@FData[FCursor + Index]).VString);
               {$ENDIF}
    {$ENDIF}
  End;
End;

function TVariantArray.GetDataByCell(Index, Row: Integer): Variant;
begin
 If (Index > -1) And (Index < FieldCount)    And
    (Row >= 0)   And (Length(FData) > Index) Then
  Begin
   Assert((Index < FieldCount) and (Index >= 0) and (Row >= 0), SVarArrayBounds);
   Inc(Index, Row * FieldCount);
   If (Length(FData) > Index) Then
    Begin
     Assert(Length(FData) > Index, SVarArrayBounds);
     Result := FData[Index];
    End;
  End
 Else
  Result := Null;
end;

function TVariantArray.GetDataByName(const Name: String): Variant;
begin
  Result := Data[FieldIndex[Name]];
end;

function TVariantArray.GetDataPtr(Index: Integer): PVariant;
begin
 If (Index >= 0) And (Index < FieldCount) Then
  Begin
   Assert((Index < FieldCount) and (Index >= 0), SVarArrayBounds);
   If Eof Then
    Result := Nil
   Else
    Result := @FData[FCursor + Index];
  End
 Else
  Result := Nil;
end;

function TVariantArray.GetDataResult(RecNo: Integer; const ResultFields: String
  ): Variant;
var
  {$IFDEF COMPILER16_UP}
    fld : Array of Integer;
  {$ELSE}
   {$IFNDEF FPC}
    fld : Array of NativeInt;
   {$ELSE}
    fld : Array of SizeInt;
   {$ENDIF}
  {$ENDIF}
  I, N: Integer;
begin
  Result := NULL;
  ParseKeyFields(ResultFields, fld);
  if Length(fld) < 1 then
    Exit;
  N := RecNo * FieldCount;
  if Length(fld) > 1 then
  begin
    Result := VarArrayCreate([0, High(fld)], varVariant);
    for I := 0 to High(fld) do
      Result[I] := FData[N + fld[I]];
  end else
    Result := FData[N + fld[0]];
  SetLength(fld, 0);
end;

procedure TVariantArray.AddIndex(List: TIndexList);
Begin
 If FIndexes = Nil Then
  FIndexes := TList.Create;
 FIndexes.Add(List);
End;

function TVariantArray.GetDataType(Index: Integer): TFieldType;
begin
  Result := FDataType[Index];
end;

{$IFDEF FPC}
Function TVariantArray.GetDataWideString(Index : Integer) : Unicodestring;
{$ELSE}
{$IF CompilerVersion < 25}
Function TVariantArray.GetDataWideString(Index : Integer) : String;
{$ELSE}
Function TVariantArray.GetDataWideString(Index : Integer) : Unicodestring;
{$IFEND}
{$ENDIF}
begin
 Assert((Index < FieldCount) and (Index >= 0), SVarArrayBounds);
 If Eof then
  Result := ''
 Else
  Begin
   {$IFDEF COMPILER14}
   {$WARNINGS OFF}
    Result := UnicodeString(PVarData(@FData[FCursor + Index]).VUString);
   {$WARNINGS ON}
    {$ELSE}
     Result := {$IFNDEF FPC}
                {$IF Defined(HAS_FMX)}
                 {$IF Defined(HAS_UTF8)}
                  {$IF (CompilerVersion = 29) or Defined(HAS_FMX)} // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
                  UnicodeString(PVarData(@FData[FCursor + Index]).VUString);
                  {$ELSE}
                  UnicodeString(RawByteString(PVarData(@FData[FCursor + Index]).VUString));
                  {$IFEND}
                 {$ELSE}
                  PWideChar(PVarData(@FData[FCursor + Index]).VString);
                 {$IFEND}
                {$ELSE}
                 {$IF CompilerVersion < 25}
                  String(PVarData(@FData[FCursor + Index]).VString);
                 {$ELSE}
                  UnicodeString(PVarData(@FData[FCursor + Index]).VString);
                 {$IFEND}
                {$IFEND}
               {$ELSE}
                PWideChar(PVarData(@FData[FCursor + Index]).VString);
               {$ENDIF}
    {$ENDIF}
  End;
end;

{$IFDEF FPC}
function TVariantArray.GetDefinitions: AnsiString;
{$ELSE}
{$IF CompilerVersion < 25}
Function TVariantArray.GetDefinitions  : AnsiString;
{$ELSE}
Function TVariantArray.GetDefinitions  : String;
{$IFEND}
{$ENDIF}
Var
 I : Integer;
 S, S2: string;
 L : TStrings;
begin
  L := TStringList.Create;
  try
    for I := 0 to FieldCount - 1 do
    begin
      S := FFieldName[I] + '=' + GetFieldTypeB(FieldType[I]);
      if dwLookup in FFields[I].Attributes then
        S := S + ':lookup'
      else if dwCalcField in FFields[I].Attributes then
        S := S + ':calc';
      if (FFields[I].Size > 0) and (FFields[I].FieldType <> ftGuid) then
        S2 := IntToStr(FFields[I].Size) else
        S2 := '';
      if dwNotNull in FFields[I].Attributes then
      begin
        if S2 <> '' then
          S := S + ',' + S2 + ':nn' else
          S := S + ',nn';
      end else
        if S2 <> '' then
          S := S + ',' + S2;
      L.Add(S);
    end;
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     Result := String(L.Text);
    {$ELSE}
     Result := AnsiString(L.Text);
    {$IFEND}
   {$ELSE}
    Result := AnsiString(L.Text);
   {$ENDIF}
  finally
    L.Free;
  end;
end;

{$IFDEF SUPPORTS_FOR_IN}
Function TVariantArray.GetEnumerator: TVariantArrayEnumerator;
begin
  Result := TVariantArrayEnumerator.Create(@Self);
end;
{$ENDIF}

function TVariantArray.GetFieldDef(Index: Integer): Integer;
begin
 Result := -1;
 If length(FFields) > 0 Then
  Result := FFields[Index].FieldDef;
end;

function TVariantArray.GetFieldIndex(const Name: String): Integer;
var
  L: Integer;
begin
  L := Length(Name);
  for Result := 0 to FieldCount - 1 do
    if (Length(FFieldName[Result]) = L) and
      (AnsiCompareText(FFieldName[Result], Name) = 0) then
      Exit;
  Result := -1
end;

function TVariantArray.GetFieldName(Index: Integer): String;
begin
  Result := FFieldName[Index];
end;

function TVariantArray.GetFieldType(Index: Integer): TFieldType;
begin
 Result := ftUnknown;
 if Length(FFields) > 0 then
  Result := FFields[Index].FieldType;
end;

function TVariantArray.GetIsEmpty(Index, Row: Integer): Boolean;
var
  P: PVariant;
  I: Integer;
begin
  if Eof then
  begin
    Result := True;
    Exit;
  end;
  if dwNotNull in FFields[Index].Attributes then
  begin
    Result := False;
    Exit;
  end;
  I := Row * FieldCount + Index;
  P := @FData[I];
  case FDataType[Index] of
    ftDate:
      Result := FData[I] = 0.0;
    ftString:
    {$IFDEF COMPILER14}
    {$WARNINGS OFF}
      Result := Length(UnicodeString(PVarData(P).VUString)) = 0;
    {$WARNINGS ON}
    {$ELSE}
     {$IFNDEF FPC}
      {$IF Defined(HAS_FMX)}
       Result := Length(PChar(PVarData(P).VString)) = 0;
      {$ELSE}
       Result := Length(PAnsiChar(PVarData(P).VString)) = 0;
      {$IFEND}
     {$ELSE}
      Result := Length(PAnsiChar(PVarData(P).VString)) = 0;
     {$ENDIF}
    {$ENDIF}
    ftWideString:
      Result := Length(PWideChar(PVarData(P).VString)) = 0;
    ftBytes:
      if VarIsArray(P^) then
      begin
        VarArrayLock(P^);
        try
          Result := PVarData(P).VArray.Bounds[0].ElementCount = 0;
        finally
          VarArrayUnlock(P^);
        end;
      end else
        Result := True;
  else
    Result := False;
  end;
end;

function TVariantArray.GetOrder(Index: Integer): Integer;
begin
  Result := FFields[Index].Order;
end;

function TVariantArray.GetRecCount: Integer;
begin
 Result := -1;
 If FieldCount > 0 Then
  Result := Length(FData) div FieldCount;
end;

function TVariantArray.GetRecNo: Integer;
begin
  if Length(FData) > 0 then Result := FCursor div FieldCount else
    Result := 0;
end;

function TVariantArray.GetRequired(Index: Integer): Boolean;
begin
  Result := dwNotNull in FFields[Index].Attributes;
end;

function TVariantArray.GetSize(Index: Integer): Integer;
begin
  Result := FFields[Index].Size;
end;

Function TVariantArray.GetPrecision(Index : Integer) : Integer;
Begin
 Result := FFields[Index].Precision;
End;

function TVariantArray.GetIndexCount: Integer;
Begin
 If Assigned(FIndexes) Then
  Result := FIndexes.Count
 Else
  Result := 0;
End;

Class function TRESTDWTableStorage.GetDbResource(Const Name : string): TStream;
Begin
 Result := nil;
End;

Class procedure TRESTDWTableStorage.GetTimeZoneBias;
Begin
 FStaticBias := 0.0;
End;

Class Function TRESTDWTableStorage.OutputDirectory     : String;
Begin
 Result := ExtractFilePath(ParamStr(0));
End;

Class Function TRESTDWTableStorage.GetDefaultExt       : String;
Begin
 Result := '.dwtb';
End;

Class function TRESTDWTableStorage.GetHeaderVersion: Integer;
Begin
 Result := HeaderVersion;
End;

Class Function TRESTDWTableStorage.OutputFileName(Const FileName : String) : String;
Begin
 If ExtractFileDrive(FileName) <> '' Then
  Result := FileName
 Else
  Result := OutputDirectory + FileName;
End;

Class Function TRESTDWTableStorage.IsSystemData(DataSet   : TDataSet;
                                            TableName : String)   : Boolean;
Begin
 If TVariantArraySupport.GetTableName(DataSet) <> '' Then
  TableName := TVariantArraySupport.GetTableName(DataSet);
 Result := Pos('sys.', TableName) = 1;
End;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
{$IF Defined(HAS_UTF8)}
Class Function TRESTDWTableStorage.GetTableDefs(DataSet: TDataSet) : String;
{$ELSE}
Class Function TRESTDWTableStorage.GetTableDefs(DataSet: TDataSet) : AnsiString;
{$IFEND}
{$ELSE}
Class Function TRESTDWTableStorage.GetTableDefs(DataSet: TDataSet) : AnsiString;
{$IFEND}
{$ELSE}
Class Function TRESTDWTableStorage.GetTableDefs(DataSet: TDataSet) : AnsiString;
{$ENDIF}
Var
 I  : Integer;
 S,
 S2 : String;
 F  : TField;
 L  : TStrings;
Begin
 If TVariantArraySupport.GetTableDefs(DataSet) <> '' Then
  Begin
   Result := TVariantArraySupport.GetTableDefs(DataSet);
   Exit;
  End;
 L := TStringList.Create;
 Try
  For I := 0 To DataSet.FieldCount - 1 Do
   Begin
    F := DataSet.Fields[I];
    {$IFNDEF FPC}
    If F.FieldKind = fkAggregate Then Continue;
    {$ENDIF}
    S := F.FieldName + '=' + GetEnumName(TypeInfo(TFieldType), Integer(F.DataType));
    If F.FieldKind       = fkLookup Then
     S := S + ':lookup'
    Else If F.FieldKind <> fkData   Then
     S := S + ':calc';
    If (F.Size > 0)           And
       (F.DataType <> ftGuid) Then
     S2 := IntToStr(F.Size)
    Else
     S2 := '';
    If F.Required Then
     Begin
      If S2 <> '' Then
       S := S + ',' + S2 + ':nn'
      Else
       S := S + ',nn';
     End
    Else
     Begin
      If S2 <> '' Then
       S := S + ',' + S2;
     End;
    L.Add(S);
   End;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Defined(HAS_UTF8)} //TODO
    Result := String(L.Text);
   {$ELSE}
    Result := AnsiString(L.Text);
   {$IFEND}
  {$ELSE}
   Result := AnsiString(L.Text);
  {$IFEND}
 {$ELSE}
  Result := AnsiString(L.Text);
 {$ENDIF}
 Finally
  L.Free;
 End;
end;

Class Function TRESTDWTableStorage.GetProductInfo: Int64;
Var
 InfoRec : Packed Record
 Case Integer Of
  0 : (Date     : Integer;
       Ntav     : Word;
       Reserved : Word);
  1 : (RawData  : Int64);
 End;
Begin
 With InfoRec do
  Begin
   Date := Trunc(sDate_dwdb);
   Ntav := NTAVersion;
   Reserved := 0;
  End;
 Result := InfoRec.RawData;
End;

Class procedure TRESTDWTableStorage.LoadArray(Stream     : TStream;
                                          Var VArray : TVariantArray);
Begin
 Stream.Position      := 0;
 VArray.FSaveCapacity := Stream.Size + 32 * 1024;
 VArray.LoadFromStream(Stream);
End;

Class Procedure TRESTDWTableStorage.LoadTable(Const TableName : String;
                                          Var   VArray    : TVariantArray);
Var
 Stream : TMemoryStream;
Begin
 Stream := TMemoryStream.Create;
 Try
  Stream.LoadFromFile(TableName);
  LoadArray(Stream, VArray);
 Finally
  Stream.Free;
 End;
End;

Class Procedure TRESTDWTableStorage.SaveTable(Const TableName : String;
                                          Var   VArray    : TVariantArray);
Var
 Stream : TMemoryStream;
Begin
 Stream := TMemoryStream.Create;
 Try
  Stream.SetSize(VArray.FSaveCapacity);
  VArray.SaveToStream(Stream);
  If VArray.FSaveCapacity > Stream.Position Then
   Stream.SetSize(Stream.Position);
  Stream.SaveToFile(TableName);
 Finally
  Stream.Free;
 End;
End;

Class Function TRESTDWTableStorage.SupportTimeStampOffset: Boolean;
Begin
 Result := True;
End;

Class Function TRESTDWTableStorage.CheckForName(Const AName : String) : Boolean;
Const
 cIllegalChar = '=()+-*/%;:?''';
 Function Illegal : Boolean;
 Var
  I : Integer;
 Begin
  For I := 1 To Length(cIllegalChar) Do
   Begin
    If Pos(cIllegalChar[I], AName) > 0 Then
     Begin
      Result := True;
      Exit;
     End;
   End;
  For I := 1 To Length(AName) Do
   Begin
    If AName[I] <= #32 Then
     Begin
      Result := True;
      Exit;
     End;
   End;
  Result := False;
 End;
Begin
 Result := Illegal;
End;

Class Function TRESTDWTableStorage.GetColorIdentsStrings : TStrings;
Var
 I : Integer;
Begin
 Result := TStringList.Create;
 For I := Low(ColorIdents) To High(ColorIdents) Do
  Result.AddObject(ColorIdents[I].Name, Pointer(ColorIdents[I].Value));
End;

Class {$IFNDEF FPC}{$IFDEF SUPPORTS_ENHANCED_RECORDS}Operator{$ELSE}Function{$ENDIF}
      {$ELSE}Function{$ENDIF}TVariantArray.Implicit(const AValue: TDataSet): TVariantArray;
begin
 {$IFNDEF FPC}{$IFNDEF SUPPORTS_ENHANCED_RECORDS}TVariantArray.Create;{$ENDIF}
 {$ELSE}TVariantArray.Create;{$ENDIF}
  if TVariantArraySupport.GetArray(AValue) <> nil then
  begin
    Result.Assign(TVariantArraySupport.GetArray(AValue)^);
    Result.FTable := nil;
    Result.FIndexes := nil;
  end else
  begin
    Result.Init(vTableStorage.GetTableDefs(AValue));
    Result.CopyFrom(AValue, -1);
  end;
end;

procedure TVariantArray.Init(const Args: array of const);
var
  I: Integer;
  PValue: PVarRec;
  S: string;
begin
  Assert(Length(Args) mod 3 = 0, SVarInvalid);
  FFieldCount := Length(Args) div 3;
  SetLength(FData, 0);
  FTable := nil;
  FIndexes := nil;
  SetLength(FFieldName, FieldCount);
  SetLength(FDataType, FieldCount);
  SetLength(FFields, FieldCount);
  FRestrictLength := [];
  FSaveCapacity := 32*1024;
  PValue := PVarRec(@Args);
  for I := 0 to High(Args) do
  begin
    case I mod 3 of
      0: begin
         {$IFNDEF FPC}
          {$IF Defined(HAS_FMX)}
           S := PChar(PValue.VUnicodeString);
          {$ELSE}
           S := PChar(PValue.VString);
          {$IFEND}
         {$ELSE}
          S := PChar(PValue.VString);
         {$ENDIF}
        Assert(FieldIndex[S] < 0, Format(SDuplicateFieldName, [S]));
        FFieldName[I div 3] := S;
        FFields[I div 3].Attributes := [dwNotNull];
      end;
      1: case TFieldType(PValue.VInteger) of
        ftUnknown, ftCursor, ftADT, ftArray, ftReference, ftDataSet:
          raise DwArrayError.CreateFmt(SUnsupportedTypeField,
            ['Init', FFieldName[I div 3]]);
      else
        SetFieldType(I div 3, PValue.VInteger);
      end;
    else
      case FFields[I div 3].FieldType of
        ftString, ftWideString:
          if PValue.VInteger > 0 then
            FFields[I div 3].Size := PValue.VInteger else
            FFields[I div 3].Size := $FF;
        ftGuid:
          FFields[I div 3].Size := 38;
        ftFloat: Begin
                  FFields[I div 3].Size      := PValue.VInteger;
                  If FFields[I div 3].Size > LazDigitsSize Then
                   FFields[I div 3].Size := LazDigitsSize;
                  If FFields[I div 3].Precision > MaxFloatLaz Then
                   FFields[I div 3].Precision := MaxFloatLaz;
                 End;
      else
        FFields[I div 3].Size := PValue.VInteger;
      end;
    end;
    Inc(PValue);
  end;
  FCursor := -1;
end;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Procedure TVariantArray.Init(const Definitions: String);
{$ELSE}
Procedure TVariantArray.Init(const Definitions: AnsiString);
{$IFEND}
{$ELSE}
procedure TVariantArray.Init(const Definitions: AnsiString);
{$ENDIF}
var
  I, P, Sz: Integer;
  N, S1, S2: string;
  B: Boolean;
  A: TDataAttributes;
  L: TStrings;
begin
 Done;
  L := TStringList.Create;
  try
    L.Text := string(Definitions);
    for I := 0 to L.Count - 1 do
    begin
      if Pos('=', L[I]) = 0 then Continue;
      N := L.Names[I];
      S1 := Trim(L.ValueFromIndex[I]);
      P := Pos(',', S1);
      if P > 0 then
      begin
        S2 := Trim(LowerCase(Copy(S1, P + 1, MaxInt)));
        SetLength(S1, P - 1);
        S1 := Trim(S1);
        B := Pos('nn:', S2) = 1;
        if B then
          {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(S2, 1, 3)
        else
        begin
          P := RPos(':nn', S2);
          B := P > 0;
          if B then
            {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(S2, P, 3)
          else
          begin
            B := S2 = 'nn';
            if B then
              S2 := '';
          end;
        end;
        Sz := StrToIntDef(S2, 0);
      end else
      begin
        B := False;
        Sz := 0;
      end;
      if B then
        A := [dwNotNull] else
        A := [];
      P := RPos(':calc', LowerCase(S1));
      if P > 0 then
      begin
        SetLength(S1, P - 1);
        S1 := Trim(S1);
        Include(A, dwCalcField);
      end else
      begin
        P := RPos(':lookup', LowerCase(S1));
        if P > 0 then
        begin
          SetLength(S1, P - 1);
          S1 := Trim(S1);
          Include(A, dwCalcField);
          Include(A, dwLookup);
        end;
      end;
      AppendField(StringToFieldType(S1), Sz, FPrecision, A, N, 'Init');
    end;
  finally
    L.Free;
  end;
end;

{$IFNDEF FPC}
{$IF NOT Defined(HAS_FMX)}
Procedure TVariantArray.Init(const Definitions: WideString);
begin
  Init(AnsiString(Definitions));
end;
{$IFEND}
{$ELSE}
procedure TVariantArray.Init(const Definitions: WideString);
begin
  Init(AnsiString(Definitions));
end;
{$ENDIF}

procedure TVariantArray.Insert;
var
  I: Integer;
begin
  SetLength(FData, Length(FData) + FieldCount);
  if FCursor < 0 then FCursor := 0;
  I := (Length(FData) - FCursor - FieldCount) * Sizeof(Variant);
  if I > 0 then
    Move(FData[FCursor], FData[FCursor + FieldCount], I);
  FillChar(FData[FCursor], FieldCount * Sizeof(Variant), 0);
  for I := 0 to FieldCount - 1 do
    if dwNotNull in FFields[I].Attributes then
      PVarData(@FData[FCursor + I]).VType := varEmpty else
      PVarData(@FData[FCursor + I]).VType := varNull;
end;

function TVariantArray.IsLookup(Index: Integer): Boolean;
begin
  Result := [dwCalcField, dwLookup] * FFields[Index].Attributes =
    [dwCalcField, dwLookup];
end;

procedure TVariantArray.Last;
begin
  if Length(FData) > 0 then
    FCursor := Length(FData)
  else FCursor := -1;
end;

Procedure TVariantArray.LoadRecordFromStream(Stream : TStream;
                                             Row    : Integer);
Var
  I, J,
  L, LA    : Integer;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    S, W   : String;
   {$ELSE}
    S, W   : Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    S, W   : Utf8String;
   {$ELSE}
    S, W   : AnsiString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  S, W     : AnsiString;
 {$ENDIF}
  V1       : SmallInt;
  V2       : Integer;
  V3       : Word;
  V4       : WordBool;
  V5       : Double;
  V6       : DWFloat;
  V7       : Extended;
  V8       : Int64;
  V9       : TBcd;
  {$IFDEF COMPILER12_UP}
  V0       : Byte;
  {$ENDIF}
  {$IFDEF COMPILER10_UP}
  V10      : Single;
  {$IFDEF DELPHI64_TEMPORARY}
  V11      : TExtended80Rec;
  {$ENDIF}
 {$ENDIF}
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Defined(HAS_UTF8)} //TODO
    Buffer : PWideChar;
   {$ELSE}
    Buffer : PAnsiChar;
   {$IFEND}
  {$ELSE}
   Buffer  : PAnsiChar;
  {$IFEND}
 {$ELSE}
  Buffer   : PAnsiChar;
 {$ENDIF}
 B         : Array of Byte;
 T         : DWFieldTypeSize;
Begin
 Row := Row * FieldCount;
 For I := 0 To FieldCount -1 Do
  Begin
   Setlength(S, 0);
//   Case FFields[I].FieldType Of
//    ftInterface,
//    ftIDispatch : Continue;
//   End;
   J := Row + I;
   If dwCalcField in FFields[I].Attributes Then
    Begin
     SetDataB(J, Null, I);
     //FData[J] := NULL;
     Continue;
    End;
   Stream.Read(T, Sizeof(DWFieldTypeSize));
   If TFieldType(T) = ftUnknown Then
    Begin
     SetDataB(J, Null, I);
     Continue;
    End;
   LA := 0;
   If TFieldType(T) = ftWideString Then
    Begin
     LA := Sizeof(WideChar);
     T := DWFieldTypeSize(ftString);
    End;
   S := '';
   Case TFieldType(T) Of
      ftString : Begin
                  Stream.Read(L, Sizeof(L));
                  If L > 0 Then
                   Begin
                    SetLength(S, L);
                    {$IFDEF FPC}
                     If L <> 0 Then
                      Stream.ReadBuffer(Pointer(S)^, L);
                     S := GetStringEncode(S, vDatabaseCharSet);
                    {$ELSE}
                     If L <> 0 Then
                      Stream.Read(S[InitStrPos], L);
                    {$ENDIF}
                   End;
                  If (Length(S) > FFields[I].Size) And
                     (FFields[I].FieldType In [ftString, ftFixedChar]) Then
                    Begin
                     If dwRestrict In FRestrictLength Then
                      SetLength(S, FFields[I].Size)
                     Else
                      Begin
                       If dwRangeChecking in FRestrictLength Then
                        Raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[I].Size]);
                      End;
                    End;
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     {$IFDEF WINDOWS}
                      If SourceSide = dwDelphi Then
                       SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}, I)
                      Else If SourceSide = dwLazarus Then
                       SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}, I);
                     {$ELSE}
                       SetDataB(J, S, I);
                     {$ENDIF}
                    {$ELSE}
                     SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}, I);
                    {$IFEND}
                   {$ELSE}
                    SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}, I);
                   {$ENDIF}
                 End;
      ftSmallint : Begin
                    Stream.Read(V1, Sizeof(V1));
                    SetDataB(J, V1, I);
                   End;
      {$IFDEF COMPILER12_UP}
      ftLongWord : Begin
                    Stream.Read(V2, Sizeof(V2));
                    SetDataB(J, LongWord(V2), I);
                   End;
      ftByte,
      ftShortint : Begin
                    Stream.Read(V0, Sizeof(V0));
                    SetDataB(J, Shortint(V0), I);
                   End;
      ftExtended : Begin
                    Stream.Read(L, Sizeof(L));
                    SetLength(S, L);
                    If L <> 0 Then
                     Begin
                      Stream.ReadBuffer(Pointer(S)^, L);
                      If S = TDecimalChar Then
                       v7 := Null
                      Else
                       Begin
                        S  := BuildFloatString(S);
                        v7 := StrToFloat(S);
                       End;
                      SetDataB(J, v7, I);
                     End;
                   End;
      {$ENDIF}
      {$IFDEF COMPILER14_UP}
      ftSingle   : Begin
                    Stream.Read(V10, Sizeof(V10));
                    SetDataB(J, V10, I);
                   End;
      ftTimeStampOffset : Begin
                           Stream.Read(V5, Sizeof(V5));
                           SetDataB(J, TDateTime(V5), I);
                          End;
      {$ENDIF}
      ftInteger,
      ftAutoInc: Begin
                  Stream.Read(V2, Sizeof(V2));
                  SetDataB(J, V2, I);
                 End;
      ftWord   : Begin
                  Stream.Read(V3, Sizeof(V3));
                  SetDataB(J, V3, I);
                 End;
      ftBoolean: Begin
                   Stream.Read(V4, Sizeof(V4));
                   SetDataB(J, V4, I);
                 End;
      ftFloat  : Begin
                  V6 := 0;
                  Stream.Read(V6, Sizeof(DWFloat));
                  SetDataB(J, V6, I);
//                  Stream.Read(L, Sizeof(L));
//                  SetLength(S, L);
//                  If L <> 0 Then
//                   Begin
//                    Stream.ReadBuffer(Pointer(S)^, L);
//                    S := Stringreplace(S, TNullString, '', [rfReplaceAll]);
//                    If S = TDecimalChar Then
//                     v5 := Null
//                    Else
//                     Begin
//                      S  := BuildFloatString(S);
//                      v5 := StrToFloat(S);
//                     End;
//                    SetDataB(J, v5, I);
//                   End;
                 End;
      ftCurrency: Begin
                   Stream.Read(L, Sizeof(L));
                   SetLength(S, L);
                   If L <> 0 Then
                    Begin
                     Stream.ReadBuffer(Pointer(S)^, L);
                     If S = TDecimalChar Then
                      v6 := Null
                     Else
                      Begin
                       S  := BuildFloatString(S);
                       v6 := StrToFloat(S);
                      End;
                     SetDataB(J, v6, I);
                    End;
                  End;
      ftBCD     : Begin
                   Stream.Read(L, Sizeof(L));
                   SetLength(S, L);
                   If L <> 0 Then
                    Begin
                     Stream.ReadBuffer(Pointer(S)^, L);
                     If S = TDecimalChar Then
                      v7 := Null
                     Else
                      Begin
                       S  := BuildFloatString(S);
                       v7 := StrToFloat(S);
                      End;
                     SetDataB(J, v7, I);
                    End;
                  End;
      ftFMTBcd  : Begin
                   Stream.Read(L, Sizeof(L));
                   SetLength(S, L);
                   If L <> 0 Then
                    Begin
                     Stream.ReadBuffer(Pointer(S)^, L);
                     If S = TDecimalChar Then
                      v7 := Null
                     Else
                      Begin
                       S  := BuildFloatString(S);
                       v7 := StrToFloat(S);
                      End;
                     SetDataB(J, v7, I);
                    End;
                  End;
      ftDate,
      ftTime,
      ftDateTime,
      ftTimeStamp: Begin
                    Stream.Read(V5, Sizeof(V5));
                    SetDataB(J, TDateTime(V5), I);
                   End;
      ftLargeint : Begin
                    Stream.Read(V8, Sizeof(V8));
                    SetDataB(J, V8, I);
                   End;
      ftVariant,
      ftInterface,
      ftIDispatch,
      ftGuid  :  Begin
                  Stream.Read(L, Sizeof(L));
                  If L > 0 Then
                   Begin
                    SetLength(S, L);
                    {$IFDEF FPC}
                     If L <> 0 Then
                      Stream.ReadBuffer(Pointer(S)^, L);
                     S := GetStringEncode(S, vDatabaseCharSet);
                    {$ELSE}
                     If L <> 0 Then
                      Stream.Read(S[InitStrPos], L);
                    {$ENDIF}
                   End;
                  If (Length(S) > FFields[I].Size) And
                     (FFields[I].FieldType In [ftString, ftFixedChar]) Then
                    Begin
                     If dwRestrict In FRestrictLength Then
                      SetLength(S, FFields[I].Size)
                     Else
                      Begin
                       If dwRangeChecking in FRestrictLength Then
                        Raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[I].Size]);
                      End;
                    End;
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     {$IFDEF WINDOWS}
                      If SourceSide = dwDelphi Then
                       SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}, I)
                      Else If SourceSide = dwLazarus Then
                       SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}, I);
                     {$ELSE}
                       SetDataB(J, S, I);
                     {$ENDIF}
                    {$ELSE}
                     SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}, I);
                    {$IFEND}
                   {$ELSE}
                    SetDataB(J, {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}, I);
                   {$ENDIF}
                 End;
      ftWideString : Begin
                      Stream.Read(L, Sizeof(L));
//                      LA := L div Sizeof(WideChar);
                      SetLength(W, L);
                      If L <> 0 Then
                       Stream.Read(W[InitStrPos], L);
                      If (Length(W) > FFields[I].Size) And
                         {$IFDEF COMPILER10_UP}
                         (FFields[I].FieldType in [ftWideString, ftFixedWideChar])
                         {$ELSE}
                         (FFields[I].FieldType = ftWideString)
                         {$ENDIF}Then
                       Begin
                        If dwRestrict In FRestrictLength Then
                         SetLength(W, FFields[I].Size)
                        Else
                         Begin
                          If dwRangeChecking In FRestrictLength Then
                           Raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[I].Size]);
                         End;
                       End;
                     {$IFNDEF FPC}
                      {$IF Defined(HAS_FMX)}
                       {$IFDEF WINDOWS}
                        If SourceSide = dwDelphi Then
                         SetDataB(J, W  + #0, I)
                        Else If SourceSide = dwLazarus Then
                         SetDataB(J, Utf8Decode(W)  + #0, I);
                       {$ELSE}
                         SetDataB(J, W  + #0, I);
                       {$ENDIF}
                      {$ELSE}
                       If SourceSide = dwDelphi Then
                        SetDataB(J, W  + #0, I)
                       Else If SourceSide = dwLazarus Then
                        SetDataB(J, Utf8Decode(W)  + #0, I);
                      {$IFEND}
                     {$ELSE}
                      If SourceSide = dwDelphi Then
                       SetDataB(J, W  + #0, I)
                      Else If SourceSide = dwLazarus Then
                       SetDataB(J, Utf8Decode(W)  + #0, I);
                     {$ENDIF}
                     End;
      ftBytes      : Begin
                       Stream.Read(L, Sizeof(L));
                       SetLength(B, L);
                       If L <> 0 Then
                        Begin
                         Stream.Read(B[0], L);
                         DynArrayToBinVariant(FData[J], B, L);
                        End;
                       B := nil;
                     End;
      Else
       Begin
        {$IFNDEF COMPILER11_UP}
        Case FFields[I].FieldDef Of
          dwftExtended : Begin
                          Stream.Read(L, Sizeof(L));
                          SetLength(S, L);
                          If L <> 0 Then
                           Begin
                            Stream.ReadBuffer(Pointer(S)^, L);
                            If S = TDecimalChar Then
                             v7 := Null
                            Else
                             Begin
                              S  := BuildFloatString(S);
                              v7 := StrToFloat(S);
                             End;
                            SetDataB(J, v7, I);
                           End;
                         End;
          dwftTimeStampOffset : Begin
                                 Stream.Read(V5, Sizeof(V5));
                                 SetDataB(J, TDateTime(V5), I);
                                End;
        End;
        {$ENDIF}
       End;
   End;
  End;
End;

procedure TVariantArray.ParseKeyFields(KeyFields: String; var Fields);
var
  I, P: Integer;
  fld: array of Integer absolute Fields;
  Field: string;
begin
  SetLength(fld, 0);
  while KeyFields <> '' do
  begin
    P := Pos(';', KeyFields);
    if P > 0 then
    begin
      Field := Copy(KeyFields, 1, Pred(P));
      I := FieldIndex[Field];
      {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(KeyFields, 1, P);
    end else
    begin
      Field := KeyFields;
      I := FieldIndex[Field];
      KeyFields := '';
    end;
    if I < 0 then
    begin
      SetLength(fld, 0);
      raise DwArrayError.CreateFmt('File not found.', [Field]);
      Exit;
    end;
    P := Length(fld);
    SetLength(fld, Succ(P));
    fld[P] := I;
  end;
end;

function TVariantArray.Locate(const KeyFields: String;
  const KeyValues: Variant; Options: TLocateOptions; Index: Integer): Boolean;
var
  fld: array of Integer;

  Function EqualKeyValues(N: Integer): Boolean;
  var
    I, F: Integer;
    S1, S2: string;
  begin
    for F := 1 to High(fld) do
    begin
      I := fld[F];
      if FDataType[I] in [ftString, ftWideString] then
      begin
        S1 := VarToStr(KeyValues[F]);
        S2 := VarToStr(FData[N + I]);
        if loCaseInsensitive in Options then
        begin
          S1 := AnsiLowerCase(S1);
          S2 := AnsiLowerCase(S2);
        end;
        if loPartialKey in Options then
          Result := Pos(S1, S2) = 1
        else
          Result := S1 = S2;
      end else
        Result := KeyValues[F] = FData[N + I];
      if not Result then
        Exit;
    end;
    Result := True;
  end;

var
  I, N: Integer;
  val: Variant;
  S: string;
  B: Boolean;
//  List: TIndexList;
begin
  Result := False;
  if Length(FData) = 0 then
    Exit;
  ParseKeyFields(KeyFields, fld);
  if Length(fld) < 1 then
    Exit;
  if VarIsArray(KeyValues, False) then
    val := KeyValues[0] else
    val := KeyValues;
  if Index < 0 then
    Index := 0;
  I := fld[0];
  N := Index * FieldCount;
  if (Options <> []) and
    (FDataType[I] in [ftString, ftWideString]) then
  begin
    S := VarToStr(val);
    if loCaseInsensitive in Options then
      S := AnsiLowerCase(S);
    while N < Length(FData) do
    begin
      if [loCaseInsensitive] = Options then
        B := S = AnsiLowerCase(VarToStr(FData[N + I]))
      else if [loPartialKey] = Options then
        B := Pos(S, VarToStr(FData[N + I])) = 1
      else if [loCaseInsensitive, loPartialKey] = Options then
        B := Pos(S, AnsiLowerCase(VarToStr(FData[N + I]))) = 1
      else
        B := S = VarToStr(FData[N + I]);
      if B and (not VarIsArray(KeyValues, False) or EqualKeyValues(N)) then
      begin
        RecNo := N div FieldCount;
        Result := True;
        Break;
      end;
      Inc(N, FieldCount);
    end
  end else
    while N < Length(FData) do
    begin
      if (val = FData[N + I]) and
        (not VarIsArray(KeyValues, False) or EqualKeyValues(N)) then
      begin
        RecNo := N div FieldCount;
        Result := True;
        Break;
      end;
      Inc(N, FieldCount);
    end;
  SetLength(fld, 0);
end;

function TVariantArray.Lookup(const KeyFields: String;
  const KeyValues: Variant; const ResultFields: String; Index: Integer
  ): Variant;
var
  fld: array of Integer;

  Function EqualKeyValues(N: Integer): Boolean;
  var
    I, F: Integer;
  begin
    for F := 1 to High(fld) do
    begin
      I := fld[F];
      Result := KeyValues[F] = FData[N + I];
      if not Result then
        Exit;
    end;
    Result := True;
  end;

var
  I, N: Integer;
  val: Variant;
//  List: TIndexList;
begin
  Result := NULL;
  if Length(FData) = 0 then
    Exit;
  ParseKeyFields(KeyFields, fld);
  if Length(fld) < 1 then
    Exit;
  if VarIsArray(KeyValues, False) then
    val := KeyValues[0] else
    val := KeyValues;
  if Index < 0 then
    Index := 0;
  I := fld[0];
  N := Index * FieldCount;
  while N < Length(FData) do
  begin
    if (val = FData[N + I]) and
      (not VarIsArray(KeyValues, False) or EqualKeyValues(N)) then
    begin
      Result := GetDataResult(N div FieldCount, ResultFields);
      Break;
    end;
    Inc(N, FieldCount);
  end;
  SetLength(fld, 0);
end;

function TVariantArray.NewField(const Name: String; FieldDef: Integer;
  Size: Integer; Attributes: TDataAttributes): Integer;
var
  I, J: Integer;
  T: Word;
begin
  if FieldCount = 0 then
  begin
    Result := AppendField(FieldDef, Size, FPrecision, Attributes, Name, 'NewField');
    Exit;
  end;
  I := Length(FData) div FieldCount;
  Result := AppendField(FieldDef, Size, FPrecision, Attributes, Name, 'NewField');
  SetLength(FData, I * FieldCount);
  if dwNotNull in Attributes then
    T := varEmpty
  else
    T := varNull;
  J := (I - 1) * Result;
  I := (I - 1) * FieldCount;
  while I >= 0 do
  begin
    if I > 0 then
      Move(FData[J], FData[I], Result * Sizeof(Variant));
    FillChar(FData[I + Result], Sizeof(Variant), 0);
    PVarData(@FData[I + Result]).VType := T;
    Dec(J, Result);
    Dec(I, FieldCount);
  end;
end;

procedure TVariantArray.Next;
begin
 if not Eof then
   Inc(FCursor, FieldCount);
end;

procedure TVariantArray.Prior;
begin
 if not Bof then
   Dec(FCursor, FieldCount);
end;

procedure TVariantArray.PutOrder(Index, AValue: Integer);
begin
  Assert((Index < FieldCount) and (Index >= 0), SVarArrayBounds);
  FFields[Index].Order := AValue;
end;

procedure TVariantArray.QuickSort(L, R: Integer; SCompare: TIndexDataSortCompare
  );
var
  I, J, P, T: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;

// Begining modification -->

    T := (P - I) shr 2;
    if T > 32 then
    begin
      if SCompare(P - T, P) < 0 then
      begin
        if SCompare(P, P + T) > 0 then
        begin
          if SCompare(P - T, P + T) < 0 then
            Inc(P, T)
          else
            Dec(P, T);
        end;
      end else
      begin
        if SCompare(P, P + T) < 0 then
        begin
          if SCompare(P - T, P + T) > 0 then
            Inc(P, T)
          else
            Dec(P, T);
        end;
      end;
    end;

// End of modification <--

    repeat
      while SCompare(I, P) < 0 do
      begin
        Inc(I);
        if I = P then
          Break;
      end;
      while SCompare(J, P) > 0 do
      begin
        Dec(J);
        if J = P then
          Break;
      end;
      if I <= J then
      begin
        if I <> J then
        begin
          Exchange(I, J);
          if P = I then
            P := J
          else if P = J then
            P := I;
          Inc(I);
          Dec(J);
        end else
        begin
          Inc(I);
          Dec(J);
          Break;
        end;
      end;
    until I > J;
    if L < J then QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TVariantArray.Save(DataSet: TDataSet; ACount: Integer);
var
  I, F2, Temp: Integer;
  F1: TField;
begin
  Temp := FCursor;
  if ACount < 0 then
  begin
    FCursor := 0;
    ACount := RecCount;
  end;
  if ACount = 0 then
  begin
    FCursor := Temp;
    Exit;
  end;
  try
    while not Eof do
    begin
      Dec(ACount);
      if ACount < 0 then
        Break;
      DataSet.Append;
      for I := 0 to DataSet.FieldCount - 1 do
      begin
        F1 := DataSet.Fields[I];
        F2 := FieldIndex[F1.FieldName];
        if not ((F2 < 0) or (F1.FieldKind <> fkData)) then
         F1.Value := Data[F2];
      end;
      DataSet.Post;
      Next;
    end;
  except on E: Exception do
    begin
      Assert(False, E.Message);
      Exit;
    end;
  end;
  FCursor := Temp;
end;

Procedure TVariantArray.SaveRecordToStream(Stream : TStream);
Var
 I, J, L : Integer;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    S, W    : String;
   {$ELSE}
    S, W    : Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    S, W    : String;
   {$ELSE}
    S, W    : AnsiString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  S, W     : AnsiString;
 {$ENDIF}
 E       : Extended;
 v6      : DWFloat;
 B       : TBcd;
 P       : PVariant;
 T       : DWFieldTypeSize;
 D       : TDateTime;
Begin
 For I := 0 to FieldCount - 1 do
  Begin
   If dwCalcField in FFields[I].Attributes Then Continue;
//   Case FFields[I].FieldType Of
//    ftInterface,
//    ftIDispatch : Continue;
//   End;
   J := FCursor + I;
   If VarIsNull(FData[J]) Then
    T := DWFieldTypeSize(ftUnknown)
   Else
    T := DWFieldTypeSize(FDataType[I]);
   Stream.Write(T, Sizeof(DWFieldTypeSize));
   Case TFieldType(T) Of
      ftString : Begin
                  {$IFDEF COMPILER14}
                  {$WARNINGS OFF}
                   S := UnicodeString(PVarData(@FData[J]).VUString);
                  {$WARNINGS ON}
                  {$ELSE}
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     S := UnicodeString(PVarData(@FData[J]).VUString); //PChar(PVarData(@FData[J]).VString);
                    {$ELSE}
                     S := PAnsiChar(PVarData(@FData[J]).VString);
                    {$IFEND}
                   {$ELSE}
                    S := PAnsiChar(PVarData(@FData[J]).VString);
                   {$ENDIF}
                  {$ENDIF}
                  If (Length(S) > FFields[I].Size) And
                     (FFields[I].FieldType         In [ftString, ftFixedChar]) Then
                   Begin
                    If dwRestrict in FRestrictLength Then
                     SetLength(S, FFields[I].Size)
                    Else
                     Begin
                      If dwRangeChecking in FRestrictLength Then
                       Raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[I].Size]);
                     End;
                   End;
                  {$IFDEF FPC}
                  S := Utf8Encode(S);
                  {$ELSE}
                   {$IF Not Defined(HAS_FMX)}
                    S := Utf8Encode(S);
                   {$IFEND}
                  {$ENDIF}
                  L := Length(S);
                  Stream.Write(L, Sizeof(L));
                  If L <> 0 Then Stream.Write(S[InitStrPos], L);
                 End;
      ftSmallint : Stream.Write(PVarData(@FData[J]).VSmallInt, Sizeof(SmallInt));
      {$IFDEF COMPILER12_UP}
      ftLongWord : Stream.Write(PVarData(@FData[J]).VInteger, Sizeof(Integer));
      ftShortint : Stream.Write(PVarData(@FData[J]).VShortInt, Sizeof(ShortInt));
      ftByte     : Stream.Write(PVarData(@FData[J]).VByte, Sizeof(Byte));
      ftExtended : Begin
                    If Not varIsNull(PVarData(@FData[J]).VCurrency) Then
                     Begin
                      S := BuildStringFloat(FloatToStr(PVarData(@FData[J]).VCurrency));
                      L := Length(S);
                      Stream.Write(L, Sizeof(L));
                      If L <> 0 then
                       Stream.Write(S[InitStrPos], L);
                     End
                    Else
                     Begin
                      S := TNullString;
                      L := Length(S);
                      Stream.Write(L, 1);
                      If L <> 0 then
                       Stream.WriteBuffer(S[InitStrPos], L);
                     End;
                   End;
      {$ENDIF}
      {$IFDEF COMPILER14_UP}
      ftSingle  : Stream.Write(PVarData(@FData[J]).VSingle, Sizeof(Single));
      ftTimeStampOffset: Begin
                          D := PVarData(@FData[J]).VDate;
                          Stream.Write(D, Sizeof(TDateTime));
                         End;
      {$ENDIF}
      ftInteger,
      ftAutoInc : Stream.Write(PVarData(@FData[J]).VInteger, Sizeof(Integer));
      ftWord    : Stream.Write(PVarData(@FData[J]).VWord, Sizeof(Word));
      ftBoolean : Stream.Write(PVarData(@FData[J]).VBoolean, Sizeof(WordBool));
      ftFloat   : Begin
                   V6 := PVarData(@FData[J]).VDouble;
                   Stream.Write(V6, Sizeof(DWFloat));
//                   If Not varIsNull(PVarData(@FData[J]).VDouble) Then
//                    Begin
//                     S := BuildStringFloat(FloatToStr(PVarData(@FData[J]).VDouble));
//                     L := Length(S);
//                     Stream.Write(L, Sizeof(L));
//                     If L <> 0 then
//                      Stream.WriteBuffer(S[InitStrPos], L);
//                    End
//                   Else
//                    Begin
//                     S := TNullString;
//                     L := Length(S);
//                     Stream.Write(L, 1);
//                     If L <> 0 then
//                      Stream.WriteBuffer(S[InitStrPos], L);
//                    End;
////                   Stream.Write(PVarData(@FData[J]).VDouble, Sizeof(Double));
                  End;
      ftCurrency: Begin
                   If Not varIsNull(PVarData(@FData[J]).VCurrency) Then
                    Begin
                     S := BuildStringFloat(FloatToStr(PVarData(@FData[J]).VCurrency));
                     L := Length(S);
                     Stream.Write(L, Sizeof(L));
                     If L <> 0 then
                      Stream.WriteBuffer(S[InitStrPos], L);
                    End
                   Else
                    Begin
                     S := TNullString;
                     L := Length(S);
                     Stream.Write(L, 1);
                     If L <> 0 then
                      Stream.WriteBuffer(S[InitStrPos], L);
                    End;
                   //Stream.Write(PVarData(@FData[J]).VCurrency, Sizeof(Currency));
                  End;
      ftBCD     : Begin
                   E := FData[J];
                   If Not varIsNull(E) Then
                    Begin
                     S := BuildStringFloat(FloatToStr(E));
                     L := Length(S);
                     Stream.Write(L, Sizeof(L));
                     If L <> 0 then
                      Stream.Write(S[InitStrPos], L);
                    End
                   Else
                    Begin
                     S := TNullString;
                     L := Length(S);
                     Stream.Write(L, 1);
                     If L <> 0 then
                      Stream.WriteBuffer(S[InitStrPos], L);
                    End;
//                   Stream.Write(E, Sizeof(E));
                  End;
      ftFMTBcd  : Begin
                   //B := VarToBcd(FData[J]);
                   E := FData[J];
                   If Not varIsNull(E) Then
                    Begin
                     S := BuildStringFloat(FloatToStr(E));
                     L := Length(S);
                     Stream.Write(L, Sizeof(L));
                     If L <> 0 then
                      Stream.Write(S[InitStrPos], L);
                    End
                   Else
                    Begin
                     S := TNullString;
                     L := Length(S);
                     Stream.Write(L, 1);
                     If L <> 0 then
                      Stream.WriteBuffer(S[InitStrPos], L);
                    End;
                  // Stream.Write(B, Sizeof(B));
                  End;
      ftDate,
      ftTime,
      ftDateTime,
      ftTimeStamp : Begin
                     D := PVarData(@FData[J]).VDate;
                     Stream.Write(D, Sizeof(TDateTime));
                    End;
      ftLargeint  : Stream.Write(PVarData(@FData[J]).VInt64, Sizeof(Int64));
      ftVariant,
      ftInterface,
      ftIDispatch,
      ftGuid  :  Begin
                  {$IFDEF COMPILER14}
                  {$WARNINGS OFF}
                   S := UnicodeString(PVarData(@FData[J]).VString);
                  {$WARNINGS ON}
                  {$ELSE}
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     S := UnicodeString(PVarData(@FData[J]).VString);
                    {$ELSE}
                     S := PAnsiChar(PVarData(@FData[J]).VString);
                    {$IFEND}
                   {$ELSE}
                    S := PAnsiChar(PVarData(@FData[J]).VString);
                   {$ENDIF}
                  {$ENDIF}
                  S := Utf8Encode(S);
                  L := Length(S);
                  If L > 0 Then
                   SetLength(S, L);
                  Stream.Write(L, Sizeof(L));
                  {$IFNDEF FPC}
                  If L <> 0 Then Stream.Write(S[InitStrPos], L);
                  {$ELSE}
                  If L <> 0 Then Stream.Write(S[1], L);
                  {$ENDIF}
                 End;
      ftWideString: Begin
                     W := PWideChar(PVarData(@FData[J]).VString);
                     If (Length(W) > FFields[I].Size) And
                        {$IFDEF COMPILER10_UP}
                        (FFields[I].FieldType in [ftWideString, ftFixedWideChar])
                        {$ELSE}
                        (FFields[I].FieldType = ftWideString)
                        {$ENDIF}Then
                      Begin
                       If dwRestrict in FRestrictLength Then
                        SetLength(W, FFields[I].Size)
                       Else
                        Begin
                         If dwRangeChecking in FRestrictLength Then
                          Raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[I].Size]);
                        End;
                      End;
//                     L := Length(W) * Sizeof(WideChar);
                     Stream.Write(L, Sizeof(L));
                     If L <> 0 Then
                      Stream.Write(W[InitStrPos], L);
                    End;
      ftBytes : Begin
                 P := GetDataPtr(I);
                 If VarIsArray(P^) Then
                  Begin
                   VarArrayLock(P^);
                   Try
                    L := PVarData(P).VArray.Bounds[0].ElementCount;
                    Stream.Write(L, Sizeof(L));
                    If L <> 0 then
                     Stream.Write(PVarData(P).VArray.Data^, L);
                   Finally
                    VarArrayUnlock(P^);
                   End;
                  End
                 Else
                  Begin
                   L := 0;
                   Stream.Write(L, Sizeof(L));
                  End;
                End;
      Else
       Begin
       {$IFNDEF COMPILER11_UP}
        If VarIsNull(FData[J]) Then Continue;
        Case FFields[I].FieldDef Of
         dwftExtended : Begin
                         If Not varIsNull(PVarData(@FData[J]).VCurrency) Then
                          Begin
                           S := BuildStringFloat(FloatToStr(PVarData(@FData[J]).VCurrency));
                           L := Length(S);
                           Stream.Write(L, Sizeof(L));
                           If L <> 0 then
                            Stream.Write(S[InitStrPos], L);
                          End
                         Else
                          Begin
                           S := TNullString;
                           L := Length(S);
                           Stream.Write(L, 1);
                           If L <> 0 then
                            Stream.WriteBuffer(S[InitStrPos], L);
                          End;
                        End;
         dwftTimeStampOffset : Begin
                                D := PVarData(@FData[J]).VDate;
                                Stream.Write(D, Sizeof(TDateTime));
                               End;
        End;
       {$ENDIF}
       End;
   End;
  End;
End;

procedure TVariantArray.SaveToBlobStream(const AFieldName: String;
  Stream: TStream; Decompress: Boolean);
var
  V: Variant;
  I: Integer;
  P: PVariant;
  M: TMemoryStream;
begin
  I := FieldIndex[AFieldName];
  if I < 0 then
    Exit;
  case FieldType[I] of
    ftMemo, ftFmtMemo, ftOraClob: begin
      V := Data[I];
      if VarIsStr(V) then
       {$IFNDEF FPC}
        {$IF Defined(HAS_FMX)}
         Stream.WriteBuffer(String(V)[InitStrPos], Length(V));
        {$ELSE}
         Stream.WriteBuffer(AnsiString(V)[InitStrPos], Length(V));
        {$IFEND}
       {$ELSE}
        Stream.WriteBuffer(AnsiString(V)[InitStrPos], Length(V));
       {$ENDIF}
    end;
{$IFDEF COMPILER10_UP}
    ftWideMemo: begin
      V := Data[I];
      if VarIsStr(V) then
       {$IFNDEF FPC}
        {$IF Defined(HAS_FMX)}
         Stream.WriteBuffer(String(V)[InitStrPos], Length(V) * Sizeof(WideChar));
        {$ELSE}
         Stream.WriteBuffer(WideString(V)[InitStrPos], Length(V) * Sizeof(WideChar));
        {$IFEND}
       {$ELSE}
        Stream.WriteBuffer(WideString(V)[InitStrPos], Length(V) * Sizeof(WideChar));
       {$ENDIF}
    end;
{$ENDIF}
  else
    if FDataType[I] <> ftBytes then
      Exit;
    P := GetDataPtr(I);
    if not VarIsArray(P^) then
      Exit;
    VarArrayLock(P^);
    try
      if Decompress then
      begin
        M := TMemoryStream.Create;
        try
          M.WriteBuffer(PVarData(P).VArray.Data^,
            PVarData(P).VArray.Bounds[0].ElementCount);
          if (M.Size >= Sizeof(_BLOBW) + Sizeof(I)) and (PWord(M.Memory)^ = _BLOBW) then
          begin
            M.Position := Sizeof(_BLOBW);
            M.ReadBuffer(I, Sizeof(I));
            ZDecompressStream(M, Stream);
          end else
            Stream.WriteBuffer(PVarData(P).VArray.Data^,
              PVarData(P).VArray.Bounds[0].ElementCount);
        finally
          M.Free;
        end;
      end else
        Stream.WriteBuffer(PVarData(P).VArray.Data^,
          PVarData(P).VArray.Bounds[0].ElementCount);
    finally
      VarArrayUnlock(P^);
    end;
  end;
end;

Procedure TVariantArray.SetDataB(Index        : Integer;
                                 Const AValue : Variant;
                                 FieldIndex   : Integer = 0);
var
  I       : Integer;
  vTimeOf : Real;
  {$IFNDEF FPC}
   {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
    {$IF Defined(HAS_FMX)}
     S, W    : String;
    {$ELSE}
     S, W    : Utf8String;
    {$IFEND}
   {$ELSE}
    {$IF Defined(HAS_FMX)}
     S, W    : String;
    {$ELSE}
     S : AnsiString;
     W : WideString;
    {$IFEND}
   {$IFEND}
  {$ELSE}
  S: AnsiString;
  W: WideString;
  {$ENDIF}
begin
//  Assert((Index < FieldCount) and (Index >= 0) and (FCursor >= 0), SVarArrayBounds);
  I := FCursor + Index;
  Assert(Length(FData) > I, SVarArrayBounds);
  if VarIsNull(AValue) then
    FData[I] := NULL
  else
  case FDataType[FieldIndex] of
      ftString:
        begin
         {$IFNDEF FPC}
          {$IF Defined(HAS_FMX)}
           {$IF Defined(HAS_UTF8)}
            S := AValue; //d14,d15
           {$ELSE}
            S := AnsiString(AValue); //d14,d15
           {$IFEND}
          {$ELSE}
           S := AnsiString(AValue); //d14,d15
          {$IFEND}
         {$ELSE}
          S := GetStringDecode(AnsiString(AValue), DatabaseCharSet); //d14,d15
         {$ENDIF}
          if (Length(S) > FFields[FieldIndex].Size) and
            (FFields[FieldIndex].FieldType in [ftString, ftFixedChar]) then
          begin
            if dwRangeChecking in FRestrictLength then
              raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[FieldIndex].Size])
            else
            if dwRestrict in FRestrictLength then
              SetLength(S, FFields[FieldIndex].Size);
          end;
          FData[I] := S;
        end;
      ftSmallint: FData[I] := SmallInt(AValue);
{$IFDEF COMPILER14_UP}
      ftLongWord: FData[I] := LongWord(AValue);
      ftShortint: FData[I] := Shortint(AValue);
      ftByte: FData[I] := Byte(AValue);
      ftExtended: FData[I] := AValue;
      ftSingle: FData[I] := Single(AValue);
      ftTimeStampOffset: FData[I] := TDateTime(AValue);
{$ELSE}
{$WARNINGS OFF}
  {$IFDEF LCL_FULLVERSION < 2010000}
      TFieldType(dwftLongWord): FData[I] := LongWord(AValue);
      TFieldType(dwftShortint): FData[I] := Shortint(AValue);
      TFieldType(dwftByte): FData[I] := Byte(AValue);
      TFieldType(dwftExtended), TFieldType(dwftSingle):
        FData[I] := AValue;
      TFieldType(dwftTimeStampOffset): FData[I] := TDateTime(AValue);
  {$ENDIF}
{$WARNINGS ON}
{$ENDIF}
      ftInteger,
      ftAutoInc,
      ftTime,
      ftDate : Begin
                                   Case FFields[FieldIndex].FieldType of
                                     ftDate: FData[I] := DateOf(AValue);
                                    Else
                                     FData[I] := Integer(AValue);
                                   End;
                                  End;
      ftWord: FData[I] := Word(AValue);
      ftBoolean: FData[I] := WordBool(AValue);
      ftFloat: FData[I] := Double(AValue);
      ftCurrency: FData[I] := Currency(AValue);
      ftBCD: FData[I] := Extended(AValue);
      ftFMTBcd: FData[I] := AValue;
      ftDateTime,
      ftTimeStamp          : FData[I] := AValue;
      ftLargeint: FData[I] := AValue;
      ftVariant: FData[I] := AValue;
      ftInterface: FData[I] := IUnknown(AValue);
      ftIDispatch: FData[I] := IDispatch(AValue);
      ftWideString:
        begin
         {$IFNDEF FPC}
          {$IF Defined(HAS_FMX)}
           W := String(AValue);
          {$ELSE}
           W := WideString(AValue);
          {$IFEND}
         {$ELSE}
          W := WideString(AValue);
         {$ENDIF}
          if (Length(W) > FFields[FieldIndex].Size) and
{$IFDEF COMPILER10_UP}
            (FFields[FieldIndex].FieldType in [ftWideString, ftFixedWideChar])
{$ELSE}
            (FFields[FieldIndex].FieldType = ftWideString)
{$ENDIF}  then
          begin
            if dwRangeChecking in FRestrictLength then
              raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[FieldIndex].Size])
            else
            if dwRestrict in FRestrictLength then
              SetLength(W, FFields[FieldIndex].Size);
          end;
          FData[I] := W;
        end;
      ftBytes: FData[I] := AValue;
  else
    FData[I] := AValue;
  end;
end;

procedure TVariantArray.SetData(Index : Integer; const AValue: Variant);
var
  I: Integer;
  {$IFNDEF FPC}
   {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
    {$IF Defined(HAS_FMX)}
     S, W    : String;
    {$ELSE}
     S, W    : Utf8String;
    {$IFEND}
   {$ELSE}
    {$IF Defined(HAS_FMX)}
     S, W    : Utf8String;
    {$ELSE}
     S : AnsiString;
     W : WideString;
    {$IFEND}
   {$IFEND}
  {$ELSE}
  S: AnsiString;
  W: WideString;
  {$ENDIF}
begin
  Assert((Index < FieldCount) and (Index >= 0) and (FCursor >= 0), SVarArrayBounds);
  I := FCursor + Index;
  Assert(Length(FData) > I, SVarArrayBounds);
  if VarIsNull(AValue) then
    FData[I] := NULL
  else
  case FDataType[Index] of
      ftString:
        begin
         {$IFNDEF FPC}
          {$IF Defined(HAS_FMX)}
           {$IF Defined(HAS_UTF8)}
            S := AValue; //d14,d15
           {$ELSE}
            S := AnsiString(AValue); //d14,d15
           {$IFEND}
          {$ELSE}
           S := AnsiString(AValue); //d14,d15
          {$IFEND}
         {$ELSE}
          S := AnsiString(AValue); //d14,d15
         {$ENDIF}
          if (Length(S) > FFields[Index].Size) and
            (FFields[Index].FieldType in [ftString, ftFixedChar]) then
          begin
            if dwRangeChecking in FRestrictLength then
              raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[Index].Size])
            else
            if dwRestrict in FRestrictLength then
              SetLength(S, FFields[Index].Size);
          end;
          FData[I] := S;
        end;
      ftSmallint: FData[I] := SmallInt(AValue);
{$IFDEF COMPILER14_UP}
      ftLongWord: FData[I] := LongWord(AValue);
      ftShortint: FData[I] := Shortint(AValue);
      ftByte: FData[I] := Byte(AValue);
      ftExtended: FData[I] := AValue;
      ftSingle: FData[I] := Single(AValue);
      ftTimeStampOffset: FData[I] := TDateTime(AValue);
{$ELSE}
{$WARNINGS OFF}
     {$IFDEF LCL_FULLVERSION < 2010000}
      TFieldType(dwftLongWord): FData[I] := LongWord(AValue);
      TFieldType(dwftShortint): FData[I] := Shortint(AValue);
      TFieldType(dwftByte): FData[I] := Byte(AValue);
      TFieldType(dwftExtended), TFieldType(dwftSingle):
        FData[I] := AValue;
      TFieldType(dwftTimeStampOffset): FData[I] := TDateTime(AValue);
     {$ENDIF}
{$WARNINGS ON}
{$ENDIF}
      ftInteger, ftDate : FData[I] := Integer(AValue);
      ftWord: FData[I] := Word(AValue);
      ftBoolean: FData[I] := WordBool(AValue);
      ftFloat: FData[I] := Double(AValue);
      ftCurrency: FData[I] := Currency(AValue);
      ftBCD: FData[I] := Extended(AValue);
      ftFMTBcd: FData[I] := AValue;
      ftDateTime,
      ftTimeStamp,
      ftTime : FData[I] := AValue;
      ftLargeint: FData[I] := AValue;
      ftVariant: FData[I] := AValue;
      ftInterface: FData[I] := IUnknown(AValue);
      ftIDispatch: FData[I] := IDispatch(AValue);
      ftWideString:
        begin
         {$IFNDEF FPC}
          {$IF Defined(HAS_FMX)}
           W := String(AValue);
          {$ELSE}
           W := WideString(AValue);
          {$IFEND}
         {$ELSE}
          W := WideString(AValue);
         {$ENDIF}
          if (Length(W) > FFields[Index].Size) and
{$IFDEF COMPILER10_UP}
            (FFields[Index].FieldType in [ftWideString, ftFixedWideChar])
{$ELSE}
            (FFields[Index].FieldType = ftWideString)
{$ENDIF}  then
          begin
            if dwRangeChecking in FRestrictLength then
              raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[Index].Size])
            else
            if dwRestrict in FRestrictLength then
              SetLength(W, FFields[Index].Size);
          end;
          FData[I] := W;
        end;
      ftBytes: FData[I] := AValue;
  else
    FData[I] := AValue;
  end;
end;

procedure TVariantArray.SetDataByCell(Index, Row: Integer; const AValue: Variant
  );
var
  I: Integer;
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   S, W: String;
  {$ELSE}
   S: AnsiString;
   W: WideString;
  {$IFEND}
 {$ELSE}
  S: AnsiString;
  W: WideString;
 {$ENDIF}
begin
  Assert((Index < FieldCount) and (Index >= 0) and (Row >= 0), SVarArrayBounds);
  I := Row * FieldCount + Index;
  Assert(Length(FData) > I, SVarArrayBounds);
  if VarIsNull(AValue) then
    FData[I] := NULL
  else
  case FDataType[Index] of
      ftString:
        begin
         {$IFNDEF FPC}
          {$IF Defined(HAS_FMX)}
           S := String(AValue); //d14,d15
          {$ELSE}
           S := AnsiString(AValue); //d14,d15
          {$IFEND}
         {$ELSE}
          S := AnsiString(AValue); //d14,d15
         {$ENDIF}
          if (Length(S) > FFields[Index].Size) and
            (FFields[Index].FieldType in [ftString, ftFixedChar]) then
          begin
            if dwRangeChecking in FRestrictLength then
              raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[Index].Size])
            else
            if dwRestrict in FRestrictLength then
              SetLength(S, FFields[Index].Size);
          end;
          FData[I] := S;
        end;
      ftSmallint: FData[I] := SmallInt(AValue);
{$IFDEF COMPILER14_UP}
      ftLongWord: FData[I] := LongWord(AValue);
      ftShortint: FData[I] := Shortint(AValue);
      ftByte: FData[I] := Byte(AValue);
      ftExtended: FData[I] := AValue;
      ftSingle: FData[I] := Single(AValue);
      ftTimeStampOffset: FData[I] := TDateTime(AValue);
{$ELSE}
{$WARNINGS OFF}
     {$IFDEF LCL_FULLVERSION < 2010000}
      TFieldType(dwftLongWord): FData[I] := LongWord(AValue);
      TFieldType(dwftShortint): FData[I] := Shortint(AValue);
      TFieldType(dwftByte): FData[I] := Byte(AValue);
      TFieldType(dwftExtended), TFieldType(dwftSingle): FData[I] := AValue;
      TFieldType(dwftTimeStampOffset): FData[I] := TDateTime(AValue);
     {$ENDIF}
{$WARNINGS ON}
{$ENDIF}
      ftInteger,
      ftDate,
      ftTime: FData[I] := Integer(AValue);
      ftWord: FData[I] := Word(AValue);
      ftBoolean: FData[I] := WordBool(AValue);
      ftFloat: FData[I] := Double(AValue);
      ftCurrency: FData[I] := Currency(AValue);
      ftBCD: FData[I] := Extended(AValue);
      ftFMTBcd: FData[I] := AValue;
      ftLargeint: FData[I] := AValue;
      ftVariant: FData[I] := AValue;
      ftInterface: FData[I] := IUnknown(AValue);
      ftIDispatch: FData[I] := IDispatch(AValue);
      ftWideString:
        begin
         {$IFNDEF FPC}
          {$IF Defined(HAS_FMX)}
           W := String(AValue);
          {$ELSE}
           W := WideString(AValue);
          {$IFEND}
         {$ELSE}
          W := WideString(AValue);
         {$ENDIF}
          if (Length(W) > FFields[Index].Size) and
{$IFDEF COMPILER10_UP}
            (FFields[Index].FieldType in [ftWideString, ftFixedWideChar])
{$ELSE}
            (FFields[Index].FieldType = ftWideString)
{$ENDIF}  then
          begin
            if dwRangeChecking in FRestrictLength then
              raise ERangeError.CreateFmt(SLengthOutOfBounds, [FFields[Index].Size])
            else
            if dwRestrict in FRestrictLength then
              SetLength(W, FFields[Index].Size);
          end;
          FData[I] := W;
        end;
      ftBytes: FData[I] := AValue;
  else
    FData[I] := AValue;
  end;
end;

procedure TVariantArray.SetDataByName(const Name: String; const AValue: Variant
  );
begin
  Data[FieldIndex[Name]] := AValue;
end;

procedure TVariantArray.SetFieldType(Index: Integer; AValue: Integer);
begin
  FFields[Index].FieldDef := AValue;
  If TFieldType(AValue) = ftWideString Then
   AValue := Integer(ftString);
  if AValue <= Integer(High(TFieldType)) then
    FFields[Index].FieldType := TFieldType(AValue)
  else
    FFields[Index].FieldType := ftUnknown;
  case AValue of
{$IFNDEF COMPILER11_UP}
    dwftExtended, dwftTimeStampOffset:
      begin
        FDataType[Index] := TFieldType(AValue);
        Exit;
      end;
{$ENDIF}
    dwftStream:
      begin
        FDataType[Index] := ftBytes;
        Exit;
      end;
    dwftColor:
      begin
        FDataType[Index] := ftInteger;
        Exit;
      end;
  end;
  case TFieldType(AValue) of
    ftString, ftMemo, ftFmtMemo, ftFixedChar, ftOraClob,
    ftGuid:
      FDataType[Index] := ftString;
{$IFDEF COMPILER10_UP}
    ftOraInterval:
      FDataType[Index] := ftString;
    ftOraTimeStamp: {$IFDEF FPC}
                     FDataType[Index] := ftDateTime;
                    {$ELSE}
                     FDataType[Index] := ftTimeStamp;
                    {$ENDIF}
    ftFixedWideChar, ftWideMemo:
      FDataType[Index] := ftWideString;
{$ENDIF}
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      Begin
       Case TFieldType(AValue) Of
        ftDate, ftTime : FDataType[Index] := TFieldType(AValue);
        ftDateTime,
        ftTimeStamp    : Begin
                           {$IFDEF FPC}
                            FDataType[Index] := ftDateTime;
                           {$ELSE}
                            FDataType[Index] := ftTimeStamp;
                           {$ENDIF}
                         End;
       End;
      End;
    ftInteger, ftAutoInc:
      FDataType[Index] := ftInteger;
    ftWideString:
      FDataType[Index] := ftWideString;
    ftBytes, ftVarBytes, ftBlob, ftGraphic, ftParadoxOle, ftDBaseOle,
    ftTypedBinary, ftOraBlob:
      FDataType[Index] := ftBytes;
    ftBCD, ftFMTBcd         :
      FDataType[Index] := ftFloat; //Fix para ftFMTBcd TODO XyberX
  else
    Begin
     FDataType[Index] := TFieldType(AValue);
     If FDataType[Index] = ftFloat Then
      Begin
       If FFields[Index].Size > LazDigitsSize Then
        FFields[Index].Size       := LazDigitsSize;
       If (FFields[Index].Precision > MaxFloatLaz) Or
          (FFields[Index].Precision = 0)           Then
        FFields[Index].Precision  := MaxFloatLaz;
      End;
    End;
  end;
end;

procedure TVariantArray.SetLoadModified;
begin
  FModified := True;
end;

procedure TVariantArray.SetRecNo(AValue: Integer);
begin
  if FCursor = -1 then Exit;
  Assert((AValue >= 0) and (Length(FData) >= AValue * FieldCount), SVarArrayBounds);
  FCursor := AValue * FieldCount;
end;

procedure TVariantArray.SetRecordCount(AValue: Integer);
begin
  AValue := FieldCount * AValue;
  SetLength(FData, AValue);
  if AValue = 0 then
    FCursor := -1 else
    FCursor := 0;
end;

procedure TVariantArray.Sort(const Name: String; const Descs: array of Boolean;
  CaseInsensitive: Boolean);
var
  I, N, L, D: Integer;
begin
  if RecCount < 2 then Exit;
  with IndexDataSortRec do
  begin
    ParseKeyFields(Name, vFields);
    L := Length(vFields);
    if L = 0 then
      Exit;
    D := Length(Descs);
    if (D <> L) and (D <> 0) then
      Exit;
    vArray := @Self;
    SetLength(SCompare, L);
    for I := 0 to L - 1 do
    begin
      N := vFields[I];
      if vArray.GetDataType(N) = ftBytes then
        SCompare[I] := VariantMemSortCompare
      else
      if Integer(vArray.GetDataType(N)) = dwftExtended then
        SCompare[I] := VariantRealSortCompare
      else
      if vArray.GetDataType(N) = ftInteger then
        SCompare[I] := VariantIntSortCompare
      else
      if vArray.GetDataType(N) in [ftString, ftWideString] then
      begin
        if CaseInsensitive then
          SCompare[I] := VariantAnsiSortCompareText
        else
          SCompare[I] := VariantAnsiSortCompareStr;
      end
      else
        SCompare[I] := VariantArraySortCompare;
    end;
    if D = 0 then
    begin
      SetLength(fSortDescs, L);
      for I := 0 to High(fSortDescs) do
        fSortDescs[I] := False;
    end else
    begin
      SetLength(fSortDescs, Length(Descs));
      for I := 0 to High(Descs) do
        fSortDescs[I] := Descs[I];
    end;
    fAutoInc := -1;
  end;
  QuickSort(0, RecCount - 1, LocalSortCompare);
  with IndexDataSortRec do
  begin
    SetLength(vFields, 0);
    SetLength(SCompare, 0);
    SetLength(fSortDescs, 0);
  end;
end;

{$IFDEF REGION}{$REGION ' TVariantArraySupport '}{$ENDIF}

{ TVariantArraySupport }

class Function TVariantArraySupport.ConvertFrom(Source: PVariantArray;
  DataSet: TComponent): Boolean;
var
  T: TRESTDWCustomDataSet absolute DataSet;
  I, J: Integer;
  FN  : string;
begin
  Exclude(T.FState, dwsConvertError);
  try
    T.FArray.Clear;
    SetLength(T.FArray.FData, T.FArray.FieldCount * Source.RecCount);
    T.FArray.FCursor := 0;
    Source.First;
    while not Source.Eof do
    begin
      for I := 0 to T.FArray.FieldCount - 1 do
      begin
        if T.FArray.Calculated[I] then Continue;
        FN := T.FArray.FieldName[I];
        J := Source.FieldIndex[FN];
        if J < 0 then Continue;
        T.FArray.Data[I] := Source.Data[J];
      end;
      T.FArray.Next;
      Source.Next;
    end;
  except on E: Exception do
    begin
      T.FArray.Clear;
      Include(T.FState, dwsConvertError);
      T.SetState(dsOpening);
      Assert(True, E.Message);
    end;
  end;
  T.FArray.First;
  Result := not (dwsConvertError in T.FState);
end;

class Function TVariantArraySupport.GetArray(
  DataSet: TComponent): PVariantArray;
begin
  if DataSet is TRESTDWCustomDataSet then
    Result := @TRESTDWCustomDataSet(DataSet).FArray
  else
    Result := nil;
end;

Class Function TVariantArraySupport.GetTableName(DataSet : TComponent) : String;
Begin
 Result := '';
End;

class Function TVariantArraySupport.GetCanConvert(DataSet: TComponent): Boolean;
begin
  if DataSet is TRESTDWCustomDataSet then
   Result := dwPersistentData in TRESTDWCustomDataSet(DataSet).Options
  else
    Result := False;
end;

{$IFNDEF FPC}
{$IF NOT Defined(HAS_FMX)}
Class Function TVariantArraySupport.GetTableDefs(DataSet : TComponent) : AnsiString;
{$ELSE}
Class Function TVariantArraySupport.GetTableDefs(DataSet : TComponent) : String;
{$IFEND}
{$ELSE}
Class Function TVariantArraySupport.GetTableDefs(DataSet : TComponent) : AnsiString;
{$ENDIF}
begin
  If DataSet is TRESTDWCustomDataSet then
   Begin
    {$IFNDEF FPC}
     {$IF NOT Defined(HAS_FMX)}
     Result := AnsiString(TRESTDWCustomDataSet(DataSet).TableDefs.Text)
     {$ELSE}
     Result := String(TRESTDWCustomDataSet(DataSet).TableDefs.Text);
     {$IFEND}
    {$ELSE}
     Result := AnsiString(TRESTDWCustomDataSet(DataSet).TableDefs.Text);
    {$ENDIF}
   End
  Else
   Result := ''
End;

{$IFDEF REGION}{$ENDREGION}{$ENDIF}

{ TIndexList }

Function TIndexList.Add(Item: Integer): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

Procedure TIndexList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

constructor TIndexList.Create(const AName: string; vArray: PVariantArray;
  const AKeyFields: string);
begin
  FName := AName;
  FArray := vArray;
  FKeyFields := AKeyFields;
end;

Procedure TIndexList.Delete(RecNo: Integer);
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if FList^[I] > RecNo then
      Dec(FList^[I])
    else
    if FList^[I] = RecNo then
      DoDelete(I);
  MarkModified;
end;

destructor TIndexList.Destroy;
begin
  Clear;
end;

Procedure TIndexList.DoDelete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(PResStringRec(@SIntListIndexError), Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Integer));
end;

Procedure TIndexList.DoInsert(RecNo: Integer; IsUpdate: Boolean);

  Procedure DoInsert(Index, Item: Integer);
  begin
    if (Index < 0) or (Index > FCount) then
      Error(PResStringRec(@SIntListIndexError), Index);
    if FCount = FCapacity then
      Grow;
    if Index < FCount then
      System.Move(FList^[Index], FList^[Index + 1],
        (FCount - Index) * SizeOf(Integer));
    FList^[Index] := Item;
    Inc(FCount);
  end;

var
  L, H, I, J, C, D, F: Integer;
  Fields: array of Integer;
  SCompare: array of TVariantArraySortCompare;
  AValue: Variant;
begin
  FArray.ParseKeyFields(FKeyFields, Fields);
  L := Length(Fields);
  if L = 0 then
    Exit;
  SetLength(SCompare, L);
  for I := 0 to L - 1 do
  begin
    F := Fields[I];
    if FArray.GetDataType(F) = ftBytes then
      SCompare[I] := VariantMemSortCompare
    else
    if Integer(FArray.GetDataType(F)) = dwftExtended then
      SCompare[I] := VariantRealSortCompare
    else
    if FArray.GetDataType(F) = ftInteger then
      SCompare[I] := VariantIntSortCompare
    else
    if FArray.GetDataType(F) in [ftString, ftWideString] then
    begin
      if CaseInsensitive then
        SCompare[I] := VariantAnsiSortCompareText
      else
        SCompare[I] := VariantAnsiSortCompareStr;
    end
    else
      SCompare[I] := VariantArraySortCompare;
  end;
  F := Fields[0];
  L := 0;
  H := Count - 1;
  AValue := FArray.FData[RecNo * FArray.FieldCount + F];
  while L <= H do
  begin
    I := (L + H) shr 1;
    D := FList[I];
    C := SCompare[0](FArray.FData[D * FArray.FieldCount + F], AValue);
    if C = 0 then
      for J := 1 to Length(Fields) - 1 do
      begin
        C := SCompare[J](FArray.FData[D * FArray.FieldCount + Fields[J]],
          FArray.FData[RecNo * FArray.FieldCount + Fields[J]]);
        if C <> 0 then
          Break;
      end;
    if C = 0 then
    begin
      if D > RecNo then
        C := 1 else
      if D < RecNo then
        C := -1;
    end;
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
    end;
  end;
  if not IsUpdate then
    for I := 0 to Count - 1 do
      if FList^[I] >= RecNo then
        Inc(FList^[I]);
  DoInsert(L, RecNo);
  MarkModified;
  SetLength(Fields, 0);
  SetLength(SCompare, 0);
end;

Function TIndexList.Empty: Boolean;
begin
  Result := (Count = 0) or (Length(FArray.FData) = 0);
end;

class Procedure TIndexList.Error(Msg: PResStringRec; Data: Integer);
begin
  raise EListError.CreateFmt(LoadResString(Msg), [Data]);
end;

Procedure TIndexList.Eval(Force: Boolean);
var
  I, N, L: Integer;
begin
  with IndexDataSortRec do
  begin
    FArray.ParseKeyFields(FKeyFields, vFields);
    L := Length(vFields);
    if L = 0 then
      Exit;
    vArray := FArray;
    SetLength(SCompare, L);
    if (L = 1) and InheritsFrom(TCustomIndexList) then
      SCompare[0] := TCustomIndexList(Self).EvalProc
    else
    for I := 0 to L - 1 do
    begin
      N := vFields[I];
      if vArray.GetDataType(N) = ftBytes then
        SCompare[I] := VariantMemSortCompare
      else
      if Integer(vArray.GetDataType(N)) = dwftExtended then
        SCompare[I] := VariantRealSortCompare
      else
      if vArray.GetDataType(N) = ftInteger then
        SCompare[I] := VariantIntSortCompare
      else
      if vArray.GetDataType(N) in [ftString, ftWideString] then
      begin
        if CaseInsensitive then
          SCompare[I] := VariantAnsiSortCompareText
        else
          SCompare[I] := VariantAnsiSortCompareStr;
      end
      else
        SCompare[I] := VariantArraySortCompare;
    end;
    SetLength(fSortDescs, L);
    for I := 0 to L - 1 do
      IndexDataSortRec.fSortDescs[I] := False;
    fOptions := Options;
  end;
  if not Force or (Count > FArray.RecCount) then
    N := 0
  else
    N := Count;
  SetCount(FArray.RecCount);
  for I := N to Count - 1 do
    FList[I] := I;
  Sort(IndexDataSortCompare);
  with IndexDataSortRec do
  begin
    fOptions := [];
    SetLength(vFields, 0);
    SetLength(SCompare, 0);
    SetLength(fSortDescs, 0);
  end;
end;

Function TIndexList.Find(const AValue: Variant; var RecNo: Integer;
  PartialKey: Boolean): Boolean;
var
  L, H, I, J, C, F: Integer;
  SCompare: array of TVariantArraySortCompare;
  val: Variant;
begin
  if Length(FFields) = 0 then
    FArray.ParseKeyFields(FKeyFields, FFields);
  Assert(RecNo > -2, SVarArrayBounds);
  Result := False;
  L := Length(FFields);
  if L = 0 then
    Exit;
  SetLength(SCompare, L);
  if (L = 1) and InheritsFrom(TCustomIndexList) then
    SCompare[0] := TCustomIndexList(Self).FindProc
  else
  for I := 0 to L - 1 do
  begin
    F := FFields[I];
    if FArray.GetDataType(F) = ftBytes then
      SCompare[I] := VariantMemSortCompare
    else
    if Integer(FArray.GetDataType(F)) = dwftExtended then
      SCompare[I] := VariantRealSortCompare
    else
    if FArray.GetDataType(F) = ftInteger then
      SCompare[I] := VariantIntSortCompare
    else
    if PartialKey and
      (FArray.GetDataType(F) in [ftString, ftWideString]) then
    begin
      IndexDataSortRec.fCaseInsensitive := CaseInsensitive;
      SCompare[I] := VariantKeySortCompare;
    end else
    if FArray.GetDataType(F) in [ftString, ftWideString] then
    begin
      if CaseInsensitive then
        SCompare[I] := VariantAnsiSortCompareText
      else
        SCompare[I] := VariantAnsiSortCompareStr;
    end
    else
      SCompare[I] := VariantArraySortCompare;
  end;
  F := FFields[0];
  if (RecNo >= 0) then
    L := IndexOf(RecNo) + 1
  else
    L := 0;
  H := FArray.RecCount - 1;
  if VarIsArray(AValue, False) then
    val := AValue[0] else
    val := AValue;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := SCompare[0](FArray.FData[FList[I] * FArray.FieldCount + F], val);
    if C = 0 then
      for J := 1 to Length(FFields) - 1 do
      begin
        C := SCompare[J](FArray.FData[FList[I] * FArray.FieldCount +
          FFields[J]], AValue[J]);
        if C <> 0 then
          Break;
      end;
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
        Result := True;
    end;
  end;
  RecNo := FList[L];
  SetLength(SCompare, 0);
end;

Function TIndexList.Get(Index: Integer): Integer;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(PResStringRec(@SIntListIndexError), Index);
  Result := FList^[Index];
end;

Function TIndexList.GetData(RecNo: Integer;
  const ResultFields: string): Variant;
begin
  Result := FArray.GetDataResult(RecNo, ResultFields);
end;

Function TIndexList.GetText: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
    if Result = '' then
      Result := IntToStr(Items[I])
    else
      Result := Result + ',' + IntToStr(Items[I]);
end;

Procedure TIndexList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

Function TIndexList.InDataset(Dataset: TComponent): Boolean;
begin
  Result := FArray = TVariantArraySupport.GetArray(Dataset);
end;

Function TIndexList.IndexOf(RecNo : Integer) : Integer;
Begin
 Result := -1;
End;

Procedure TIndexList.Insert(RecNo: Integer);
begin
  DoInsert(RecNo, False);
end;

Procedure TIndexList.LoadFromStream(Stream: TStream);
var
  Cnt: Integer;
begin
  Stream.Read(Cnt, Sizeof(Cnt));
  SetCount(Cnt);
  Stream.Read(List^, Cnt * Sizeof(Integer));
end;

Procedure TIndexList.MarkModified;
begin
  FModified := True;
end;

Procedure TIndexList.SaveToStream(Stream: TStream);
var
  Cnt: Integer;
begin
  Cnt := Count;
  Stream.Write(Cnt, Sizeof(Cnt));
  Stream.Write(List^, Cnt * Sizeof(Integer));
end;

Procedure TIndexList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxIndexDataListSize) then
    Error(PResStringRec(@SIntListCapacityError), NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Integer));
    FCapacity := NewCapacity;
  end;
end;

Procedure TIndexList.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxIndexDataListSize) then
    Error(PResStringRec(@SIntListCountError), NewCount);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Integer), 0)
  else
    for I := FCount - 1 downto NewCount do
      DoDelete(I);
  FCount := NewCount;
end;

Procedure TIndexList.SetName(const AValue: string);
begin
  FName := AValue;
end;

Procedure TIndexList.SetText(AValue: string);
var
  I: Integer;
  S: string;
begin
  Clear;
  while AValue <> ''
  do
  begin
    I := Pos(',', AValue);
    if I > 0
    then begin
      S := Trim(Copy(AValue, 1, I-1));
      System.Delete(AValue, 1, I);
    end
    else begin
      S := Trim(AValue);
      AValue := '';
    end;
    if Length(S) = 1
    then begin
      I := Ord(S[InitStrPos]) - Ord('0');
      if (I >= 0) and (I < 10) then Add(I);
    end
    else begin
      I := StrToIntDef(S, 0);
      if I > 0 then Add(I);
    end;
  end;
end;

Procedure TIndexList.Sort(Compare: TIndexDataSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSort3(FList, 0, Count - 1, Compare);
end;

Procedure TIndexList.Update(RecNo: Integer);
var
  Index: Integer;
begin
  Index := IndexOf(RecNo);
  if Index >= 0 then
  begin
    DoDelete(Index);
    DoInsert(RecNo, True);
  end;
end;

{ TCustomIndexList }

constructor TCustomIndexList.Create(const AKeyField: string;
  AEvalProc, AFindProc: TVariantArraySortCompare);
begin
  inherited Create('', nil, AKeyField);
  FEvalProc := AEvalProc;
  FFindProc := AFindProc;
end;

{ TDataSetIndexList }

constructor TDataSetIndexList.Create(const AKeyField: string;
  ADataSet: TDataSet; ACaseInsensitive: Boolean = False);
var
  I, N: Integer;
  fld: array of TField;
  AArray: TVariantArray;
begin
  inherited Create('', nil, AKeyField);
  CaseInsensitive := ACaseInsensitive;
  ADataSet.CheckBrowseMode;
  FDataSet := ADataSet;
  ParseKeyFieldsDataSet(FKeyFields, fld);
  {$IFNDEF FPC}
  {$IFDEF SUPPORTS_ENHANCED_RECORDS}
  New(FArray);
  {$ELSE}
  AArray := TVariantArray.Create;
  FArray := @AArray;
  {$ENDIF}
  {$ELSE}
  AArray := TVariantArray.Create;
  FArray := @AArray;
  {$ENDIF}
  FArray.Init([]);
  for I := 0 to Length(fld) - 1 do
    FArray.NewField(fld[I].FieldName, Integer(fld[I].DataType));
  N := DataSet.RecNo;
  DataSet.DisableControls;
  DataSet.First;
  try
    while not DataSet.Eof do
    begin
      FArray.Append;
      for I := 0 to Length(fld) - 1 do
        FArray^[fld[I].FieldName] := fld[I].Value;
      DataSet.Next;
    end;
  finally
    DataSet.RecNo := N;
    DataSet.EnableControls;
  end;
  SetLength(fld, 0);
  Eval;
end;

// For FIBPlus component use CloseOpen(true) after delete.

Procedure TDataSetIndexList.Delete;
begin
  FArray.RecNo := DataSet.RecNo - 1;
  FArray.Delete;
end;

destructor TDataSetIndexList.Destroy;
begin
  FArray.FIndexes.Extract(Self);
  FArray.DoneIndexes;
  FArray.Done;
  {$IFNDEF FPC}
  {$IFDEF SUPPORTS_ENHANCED_RECORDS}
  Dispose(FArray);
  {$ELSE}
  FArray.Free;
  FArray := nil;
  {$ENDIF}
  {$ELSE}
  FArray.Free;
  FArray := nil;
  {$ENDIF}
  inherited Destroy;
end;

Procedure TDataSetIndexList.Insert;
var
  I: Integer;
  fld: array of TField;
begin
  ParseKeyFieldsDataSet(FKeyFields, fld);
  FArray.RecNo := DataSet.RecNo - 1;
  FArray.Insert;
  for I := 0 to Length(fld) - 1 do
    FArray^[fld[I].FieldName] := fld[I].Value;
  inherited Insert(FArray.RecNo);
end;

Function TDataSetIndexList.Locate(const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  Result := FArray.Locate(FKeyFields, KeyValues, Options);
  if Result then
    DataSet.RecNo := FArray.RecNo + 1;
end;

Function TDataSetIndexList.LocateNext(const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  Result := FArray.Locate(FKeyFields, KeyValues, Options, DataSet.RecNo);
  if Result then
    DataSet.RecNo := FArray.RecNo + 1;
end;

Procedure TDataSetIndexList.ParseKeyFieldsDataSet(KeyFields: string;
  var Fields);
var
  P: Integer;
  F: TField;
  fld: array of TField absolute Fields;
  Field: string;
begin
  SetLength(fld, 0);
  while KeyFields <> '' do
  begin
    P := Pos(';', KeyFields);
    if P > 0 then
    begin
      Field := Copy(KeyFields, 1, Pred(P));
      F := DataSet.FindField(Field);
      {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(KeyFields, 1, P);
    end else
    begin
      Field := KeyFields;
      F := DataSet.FindField(Field);
      KeyFields := '';
    end;
    if F = nil then
    begin
      SetLength(fld, 0);
      raise DwArrayError.CreateFmt('File Not Found.', [Field]);
      Exit;
    end;
    P := Length(fld);
    SetLength(fld, Succ(P));
    fld[P] := F;
  end;
end;

Procedure TDataSetIndexList.Update;
var
  I: Integer;
  fld: array of TField;
begin
  ParseKeyFieldsDataSet(FKeyFields, fld);
  FArray.RecNo := DataSet.RecNo - 1;
  for I := 0 to Length(fld) - 1 do
    FArray^[fld[I].FieldName] := fld[I].Value;
  inherited Update(FArray.RecNo);
end;

Function TBufferedStream.BufferHit: Boolean;
begin
  Result := (FBufferStart <= FPosition) and (FPosition < (FBufferStart + FBufferCurrentSize));
end;

constructor TBufferedStream.Create(const AFileName: string; Mode: Word);
begin
  inherited Create;
  FStream := TFileStream.Create(AFileName, Mode);
  FPosition := Stream.Position;
  LoadBuffer;
end;

constructor TBufferedStream.Create(const AFileName: string; Mode: Word;
  Rights: Cardinal);
begin
  inherited Create;
  FStream := TFileStream.Create(AFileName, Mode, Rights);
  FPosition := Stream.Position;
  LoadBuffer;
end;

destructor TBufferedStream.Destroy;
begin
  Flush;
  FStream.Free;
  inherited Destroy;
end;

Procedure TBufferedStream.Flush;
begin
  if (Stream <> nil) and (FBufferMaxModifiedPos > 0) then
  begin
    Stream.Position := FBufferStart;
    Stream.WriteBuffer(FBuffer[0], FBufferMaxModifiedPos);
    FBufferMaxModifiedPos := 0;
  end;
end;

Function TBufferedStream.GetCalcedSize: Int64;
begin
  if Assigned(Stream) then
    Result := Stream.Size
  else
    Result := 0;
  if Result < FBufferMaxModifiedPos + FBufferStart then
    Result := FBufferMaxModifiedPos + FBufferStart;
end;

Function TBufferedStream.LoadBuffer: Boolean;
begin
  Flush;
  if Length(FBuffer) <> FBufferSize then
    SetLength(FBuffer, FBufferSize);
  if Stream <> nil then
  begin
    Stream.Position := FPosition;
    FBufferCurrentSize := Stream.Read(FBuffer[0], FBufferSize);
  end
  else
    FBufferCurrentSize := 0;
  FBufferStart := FPosition;
  Result := (FBufferCurrentSize > 0);
end;

Function TBufferedStream.Read(var Buffer; Count: Longint): Longint;
const
  Offset = 0;
begin
  Result := Count + Offset;
  while Count > 0 do
  begin
    if not BufferHit then
      if not LoadBuffer then
        Break;
    Dec(Count, ReadFromBuffer(Buffer, Count, Result - Count));
  end;
  Result := Result - Count - Offset;
end;

Function TBufferedStream.ReadFromBuffer(var Buffer; Count, Start: Longint): Longint;
var
  BufPos: Longint;
  {$IFNDEF FPC}
   {$IF Defined(HAS_FMX)}
    P: PChar;
   {$ELSE}
    P: PAnsiChar;
   {$IFEND}
  {$ELSE}
   P: PAnsiChar;
  {$ENDIF}
begin
  Result := Count;
  BufPos := FPosition - FBufferStart;
  if Result > FBufferCurrentSize - BufPos then
    Result := FBufferCurrentSize - BufPos;
  P := @Buffer;
  Move(FBuffer[BufPos], P[Start], Result);
  Inc(FPosition, Result);
end;

Function TBufferedStream.Seek(Offset: Longint; Origin: Word): Longint;
var
  Result64: Int64;
begin
  case Origin of
    soFromBeginning:
      Result64 := Seek(Int64(Offset), soBeginning);
    soFromCurrent:
      Result64 := Seek(Int64(Offset), soCurrent);
    soFromEnd:
      Result64 := Seek(Int64(Offset), soEnd);
  else
    Result64 := -1;
  end;
  if (Result64 < 0) or (Result64 > High(Longint)) then
    Result64 := -1;
  Result := Result64;
end;

Function TBufferedStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  NewPos: Int64;
begin
  NewPos := FPosition;
  case Origin of
    soBeginning:
      NewPos := Offset;
    soCurrent:
      Inc(NewPos, Offset);
    soEnd:
      NewPos := GetCalcedSize + Offset;
  else
    NewPos := -1;
  end;
  if NewPos < 0 then
    NewPos := -1
  else
    FPosition := NewPos;
  Result := NewPos;
end;

Procedure TBufferedStream.SetSize(NewSize: Longint);
begin
  SetSize(Int64(NewSize));
end;

Procedure TBufferedStream.SetSize(const NewSize: Int64);
begin
  if Assigned(FStream) then
    Stream.Size := NewSize;
  if NewSize < (FBufferStart + FBufferMaxModifiedPos) then
  begin
    FBufferMaxModifiedPos := NewSize - FBufferStart;
    if FBufferMaxModifiedPos < 0 then
      FBufferMaxModifiedPos := 0;
  end;
  if NewSize < (FBufferStart + FBufferCurrentSize) then
  begin
    FBufferCurrentSize := NewSize - FBufferStart;
    if FBufferCurrentSize < 0 then
      FBufferCurrentSize := 0;
  end;
  // fix from Marcelo Rocha
  if Stream <> nil then
    FPosition := Stream.Position;
end;

Function TBufferedStream.Write(const Buffer; Count: Longint): Longint;
const
  Offset = 0;
begin
  Result := Count + Offset;
  while Count > 0 do
  begin
    if (FBufferStart > FPosition) or (FPosition >= (FBufferStart + FBufferSize)) then
      LoadBuffer;
    Dec(Count, WriteToBuffer(Buffer, Count, Result - Count));
  end;
  Result := Result - Count - Offset;
end;

Function TBufferedStream.WriteToBuffer(const Buffer; Count, Start: Longint): Longint;
var
  BufPos: Longint;
  {$IFNDEF FPC}
   {$IF Defined(HAS_FMX)}
    P: PChar;
   {$ELSE}
    P: PAnsiChar;
   {$IFEND}
  {$ELSE}
   P: PAnsiChar;
  {$ENDIF}
begin
  Result := Count;
  BufPos := FPosition - FBufferStart;
  if Result > Length(FBuffer) - BufPos then
    Result := Length(FBuffer) - BufPos;
  if FBufferCurrentSize < BufPos + Result then
    FBufferCurrentSize := BufPos + Result;
  P := @Buffer;
  Move(P[Start], FBuffer[BufPos], Result);
  if FBufferMaxModifiedPos < BufPos + Result then
    FBufferMaxModifiedPos := BufPos + Result;
  Inc(FPosition, Result);
end;

{$IFNDEF FPC}
{$IFDEF SUPPORTS_CLASS_HELPERS}
{$IFNDEF COMPILER10_UP}
Function TExtendedFieldHelper.GetAsExtendedHelper: Extended;
Begin
 If Self Is TExtendedField Then
  Result := TExtendedField(Self).GetAsExtended
 Else
  Result := Self.AsFloat;
End;

Procedure TExtendedFieldHelper.SetAsExtendedHelper(Const Value: Extended);
Begin
 If Self is TExtendedField then
  TExtendedField(Self).SetAsExtended(Value)
 Else
  Self.AsFloat := Value;
End;
{$ENDIF}
{$ENDIF}
{$IF CompilerVersion > 24}
Function TExtendedField.GetAsExtended: Extended;
Var
 Data : TValueBuffer;
Begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   SetLength(Data, SizeOf(Extended));
   If not GetData(Data, True) then
    Result := NaN
   Else
    Result := TBitConverter.InTo<Extended>(Data);
  {$ELSE}
   If not GetData(@Result, True) then
    Result := NaN;
  {$IFEND}
 {$ELSE}
  If not GetData(@Result, True) then
   Result := NaN;
 {$ENDIF}
End;

Function TExtendedField.GetAsString: string;
Var
 x : Extended;
{$IFDEF COMPILER17_UP}
  Data: TValueBuffer;
{$ENDIF}
Begin
 {$IFNDEF COMPILER17_UP}
 If GetData(@x, True) then
  Begin
 {$ELSE}
  SetLength(Data, SizeOf(Extended));
  If GetData(Data, True) then
  Begin
   {$IF CompilerVersion > 28}
   x := TBitConverter.InTo<Extended>(Data);
   {$ELSE}
   x := TBitConverter.ToExtended(Data);
   {$IFEND}
//   x := TBitConverter.InTo<Extended>(Data);
  {$ENDIF}
  Result := FloatToStrF(x, ffGeneral, 19, 0)
  End
 Else
  Result := '';
End;

Function TExtendedField.GetAsVariant : Variant;
Begin
 Result := GetAsExtended;
// Result := _RealSupportManager._VarFromReal(GetAsExtended);
End;

Procedure TExtendedField.SetAsExtended(Const AValue : Extended);
Begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   {$IF Defined(HAS_UTF8)}
    SetData(TValueBuffer(@AValue), True);
   {$ELSE}
    SetData(@AValue, True);
   {$IFEND}
  {$ELSE}
   SetData(@AValue, True);
  {$IFEND}
 {$ELSE}
  SetData(@AValue, True);
 {$ENDIF}
End;

Procedure TExtendedField.SetAsString(Const AValue : String);
Var
 x : Extended;
Begin
 If AValue = '' Then
  Clear
 Else
  Begin
   x := StrToFloat(AValue);
   SetAsExtended(x);
  End;
End;

Procedure TExtendedField.SetVarValue(Const AValue : Variant);
Begin
 SetAsExtended(AValue);
End;
{$ELSE}
Function TExtendedField.GetAsVariant : Variant;
Begin
 Result := Extended(Value);//_RealSupportManager._VarFromReal(Value);
End;
{$IFEND}
{$ENDIF}

{$IFNDEF FPC}
{$IF CompilerVersion < 25}
Procedure TSQLTimeStampOffsetField.GetText(var Text: string;
  DisplayText: Boolean);
Var
 S  : String;
 D  : TSQLTimeStamp;
Begin
 If GetData(@D, False) then
  Begin
   If DisplayText and (DisplayFormat <> '') Then
    S := DisplayFormat
   Else
    S := '';
   Text := SQLTimeStampToStr(S, D);
  End
 Else
  Text := '';
End;
{$IFEND}
{$ENDIF}

{$IFNDEF FPC}
{$IF CompilerVersion < 25}
Procedure TSQLTimeStampOffsetField.SetAsString(Const Value: string);
{$ELSE}
Procedure TSQLTimeStampOffsetField.SetAsString(Const AValue: string);
{$IFEND}
Var
 S : String;
 P : Integer;
Begin
 {$IF CompilerVersion < 25}
  S := Value;
 {$ELSE}
  S := AValue;
 {$IFEND}
 P := RPos(' ', S);
 If (P < 8) or (P = Length(S)) Then Exit;
 If (Pos(S[P + 1], '-+') > 0)  Then
  SetLength(S, P - 1);
 Inherited SetAsString(S);
End;
{$ENDIF}

{$IFDEF FPC}
Function TExtendedField.GetAsVariant : Variant;
Begin
 Result := Extended(Value); //_RealSupportManager._VarFromReal(Value);
End;
{$ENDIF}

{ TStreamField }

constructor TStreamField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStream := TBlobStream.Create;
  TBlobStream(FStream).FDataSet := TRESTDWCustomDataSet(AOwner);
end;

destructor TStreamField.Destroy;
begin
  TBlobStream(FStream).FDataSet := nil;
  FStream.Free;
  inherited Destroy;
end;

Function TStreamField.GetAsStream: TStream;
Var
  ZLibLevel: Integer;
begin
 ZLibLevel := 0;
  if not DataSet.IsEmpty then
  begin
    Result := FStream;
    with (DataSet as TRESTDWCustomDataSet), TBlobStream(FStream) do
    begin
      Clear;
      FFieldIndex := FArray.FieldIndex[FieldName];
      FRecNo := FArray.RecNo;
      if FArray.GetDataType(FFieldIndex) = ftBytes then
       ZLibLevel := 0;
      FArray.SaveToBlobStream(FieldName, Result, ZLibLevel <> 0);
    end;
    Result.Position := 0;
  end else
    Result := nil;
end;

Procedure TStreamField.Put;
begin
  if not DataSet.IsEmpty then
    with (DataSet as TRESTDWCustomDataSet), TBlobStream(FStream) do
    begin
      FFieldIndex := FArray.FieldIndex[FieldName];
      FRecNo := FArray.RecNo;
      SetBlobStream(FStream);
    end;
end;

{ TColorField }

constructor TColorField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [dwcoAllowedSharp];
  ValidChars := ['#'..'z'];
end;

Function TColorField.GetIdentText(AValue: Integer; var Text: string): Boolean;
begin
  Result := IntToIdent(AValue, Text, ColorIdents);
end;

Procedure TColorField.GetText(var Text: string; DisplayText: Boolean);
var
  x: Integer;
{$IFDEF COMPILER17_UP}
  Data: TValueBuffer;
{$ENDIF}
begin
{$IFNDEF COMPILER17_UP}
  if GetData(@x, True) then
  begin
{$ELSE}
  SetLength(Data, SizeOf(Integer));
  if GetData(Data, True) then
  begin
  {$IF CompilerVersion > 28}
   x := TBitConverter.InTo<Integer>(Data);
  {$ELSE}
   x := TBitConverter.ToInteger(Data);
  {$IFEND}
     //  x := TBitConverter.ToInteger(Data);
{$ENDIF}
    if not GetIdentText(x, Text) then
    begin
     {$IFNDEF FPC}
      {$IF Defined(HAS_FMX)}
       x := TAlphaColorRec(x).Color;
      {$ELSE}
       {$IF CompilerVersion > 22}
        x := TAlphaColorRec(x).Color;
       {$ELSE}
        x := ColorToRGB(x);
       {$IFEND} 
      {$IFEND}
     {$ELSE}
      x := ColorToRGB(x);
     {$ENDIF}
      if dwcoShowWebSharp in Options then
      begin
        x := ((x and $FF) shl 16) or (x and $FF00) or ((x shr 16) and $FF);
        FmtStr(Text, '%s%0.6x', [HtmlColorPrefix, x]);
      end else
        FmtStr(Text, '%s%0.8x', [HexDisplayPrefix, x]);
    end;
    if (Text <> '') and CharInSet(Text[InitStrPos], ['A'..'Z','a'..'z']) then
    begin
      Text := LowerCase(Text);
      Text[InitStrPos] := UpCase(Text[InitStrPos]);
    end;
  end else
    Text := '';
end;

Function TColorField.SetAsIdentString(const AValue: string): Boolean;
var
  x, E: Integer;
begin
  Result := (dwcoAllowedSharp in Options) and (AValue <> '')
    and (AValue[InitStrPos] = HtmlColorPrefix);
  if Result then
  begin
    Val('$' + Copy(AValue, 2, 6), x, E);
    if E <> 0 then
      raise EConvertError.CreateResFmt(PResStringRec(@SInvalidColor), [AValue]);
    x := ((x and $FF) shl 16) or (x and $FF00) or ((x shr 16) and $FF);
  end else
    Result := IdentToInt(AValue, x, ColorIdents);
  if Result then
    inherited SetAsInteger(x);
end;

Procedure TColorField.SetAsString(const AValue: string);
var
  x, E: Integer;
begin
  if not SetAsIdentString(AValue) then
  begin
    Val(AValue, x, E);
    if E <> 0 then
      raise EConvertError.CreateResFmt(PResStringRec(@SInvalidColor), [AValue]);
    inherited SetAsInteger(x);
  end;
end;

{ TRESTDWCustomDatasetEnumerator }

{$IFDEF SUPPORTS_FOR_IN}
constructor TRESTDWCustomDatasetEnumerator.Create(Dataset: TRESTDWCustomDataSet);
begin
  inherited Create;
  FRow := 0;
  FDataset := Dataset;
end;

Function TRESTDWCustomDatasetEnumerator.GetCurrent: Integer;
begin
  Result := FRow;
end;

Function TRESTDWCustomDatasetEnumerator.MoveNext: Boolean;
begin
  Result := FRow < FDataset.FArray.RecCount;
  if Result then
    Inc(FRow);
end;
{$ENDIF}

{ TRESTDWCustomDataSet }

Procedure TRESTDWCustomDataSet.AcceptCustomIndex(List: TCustomIndexList);
begin
  CheckActive;
  List.FArray := @FArray;
end;

Function TRESTDWCustomDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  GetMem(Result, sizeof(TVarRecInfo));
end;

Procedure TRESTDWCustomDataSet.Assign(Source: TPersistent);
begin
  if Source is TDataSet then
    CopyFrom(TDataSet(Source), -1)
  else
    inherited Assign(Source);
end;

Function TRESTDWCustomDataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  if Assigned(Bookmark) then
    Result := PInteger(Bookmark)^ <= FArray.RecCount
  else
    Result := False;
end;

Function TRESTDWCustomDataSet.CanSetData: Boolean;
begin
  Result := True;
end;

Procedure TRESTDWCustomDataSet.CheckDefaults;
const
  DefaultDecimalSeparator = '.';
var
  I, J, P: Integer;
  F: TField;
  V: Variant;
  S: string;
begin
  for I := 0 to FieldCount - 1 do
  begin
    F := Fields[I];
    J := Defaults.IndexOfName(F.FieldName);
    if J >= 0 then
    begin
      if F is TNumericField then
      begin
        S := Defaults.Values[F.FieldName];
        P := Pos(DefaultDecimalSeparator, S);
        if P > 0 then
          S[P] := {$IFDEF COMPILER16_UP}FormatSettings.{$ENDIF}DecimalSeparator;
        FArray[F.FieldName] := S;
      end else
      if (F is TDateTimeField) {$IFNDEF FPC}or (F is TSQLTimeStampField){$ENDIF} then
      begin
        S := Defaults.Values[F.FieldName];
        if SameText(S, 'now') then
          FArray[F.FieldName] := Now else
          FArray[F.FieldName] := S;
      end else
      begin
        if FArray.GetDataType(FArray.FieldIndex[F.FieldName]) = ftBytes then
          raise DwTableError.Create('Bytes field must be without default');
        V := Defaults.Values[F.FieldName];
        FArray[F.FieldName] := V;
      end;
    end;
  end;
end;

Procedure TRESTDWCustomDataSet.CheckFieldCompatibility(Field: TField;
  FieldDef: TFieldDef);
begin
{$IFDEF COMPILER10_UP}
  case FieldDef.DataType of
    ftOraTimeStamp:
      if Field.DataType = ftTimeStamp then Exit;
    ftOraInterval:
      if Field.DataType = ftString then Exit;
  end;
{$ENDIF}
  case FArray.GetFieldDef(FArray.FieldIndex[Field.FieldName]) of
    dwftStream:
      if Field.DataType in [ftMemo, ftBlob] then Exit;
{$IFNDEF COMPILER11_UP}
    dwftExtended:
      if Field.DataType = {$IFDEF COMPILER12}ftExtended{$ELSE}
        ftUnknown{$ENDIF} then Exit;
    dwftTimeStampOffset:
      if Field.DataType = ftTimeStamp then Exit;
{$ENDIF}
    dwftColor:
      if Field.DataType = ftInteger then Exit;
  end;
  {$IFNDEF FPC}
  inherited CheckFieldCompatibility(Field, FieldDef);
  {$ENDIF}
end;

Procedure TRESTDWCustomDataSet.CheckInactive;
begin
  if dwsCheckFilter in FState then
    Exit;
  inherited CheckInactive;
end;

Function TRESTDWCustomDataSet.CompareBookmarks(Bookmark1,
  Bookmark2: TBookmark): Integer;
const
  NilCmp: array[Boolean, Boolean] of ShortInt = ((2, -1),(1, 0));
begin
  Result := NilCmp[Bookmark1 = nil, Bookmark2 = nil];
  if Result = 2 then
  begin
    if PInteger(Bookmark1)^ > PInteger(Bookmark2)^ then
      Result := 1 else
    if PInteger(Bookmark1)^ < PInteger(Bookmark2)^ then
      Result := -1 else
      Result := 0;
  end;
end;

constructor TRESTDWCustomDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFNDEF FPC}
  {$IFNDEF SUPPORTS_ENHANCED_RECORDS}
  FArray := TVariantArray.Create;
  {$ENDIF}
  {$ELSE}
  FArray := TVariantArray.Create;
  {$ENDIF}
  FNewDefaults := TStringList.Create;
  FTableDefs := TStringList.Create;
  FRecSize   := 0;
  with TStringList(FTableDefs) do
  begin
    OnChange := TableDefsChange;
    OnChanging := TableDefsChanging;
  end;
  AutoCalcFields := True;
  FNativeFormatParam := False;
  FOnOperation       := False;
  aRecordCount       := 0;
  vOnWriterProcess   := Nil;
end;

Function TRESTDWCustomDataSet.CreateBlobStream(Field: TField;
  Mode: TBlobStreamMode): TStream;
var
  I, Temp: Integer;
  ZLibLevel: Integer;
begin
  Result := TBlobStream.Create;
  if not IsEmpty and (Field.FieldNo > 0) then
  begin
    I := FArray.FieldIndex[Field.FieldName];
    if (Mode = bmWrite) or (Mode = bmReadWrite) then
    begin
      TBlobStream(Result).FDataSet := Self;
      TBlobStream(Result).FFieldIndex := I;
      if Mode = bmWrite then
      begin
        TBlobStream(Result).FRecNo := PVarRecInfo(ActiveBuffer).Bookmark;
        Exit;
      end;
    end;
    Temp := FArray.RecNo;
    FArray.RecNo := PVarRecInfo(ActiveBuffer).Bookmark;
    if FArray.Calculated[I] then
      Inherited DoOnCalcFields;
    if FArray.GetDataType(I) = ftBytes then
      ZLibLevel := 0;
    FArray.SaveToBlobStream(Field.FieldName, Result, ZLibLevel <> 0);
    FArray.RecNo := Temp;
    Result.Position := 0;
  end;
end;

Procedure TRESTDWCustomDataSet.DesignNotify(const AFieldName: string; Dummy: Integer);
var
  Field: TField;
begin
  if not (csDesigning in ComponentState) then Exit;
  case Dummy of
    104:
      if FArray.IsLookup(FArray.FieldIndex[AFieldName]) then
      begin
        Field := FieldByName(AFieldName);
        Field.FieldKind := fkLookup;
      end;
    106:
      try
        InternalInitFieldDefs;
      except
      end;
  else
    FDsgnFieldName := AFieldName;
  end;
end;

procedure TRESTDWCustomDataSet.Loaded;
Begin
 Inherited Loaded;
 Try
  If Not (csDesigning in ComponentState) then
   FArray.OnWriterProcess := vOnWriterProcess;
 Except
  If Not (csDesigning in ComponentState) Then
   Raise;
 End;
End;

Destructor TRESTDWCustomDataSet.Destroy;
Begin
  Active := False;
//  If Assigned(FArray) Then
  If Assigned(FNewDefaults) Then
   FreeAndNil(FNewDefaults);
  If Assigned(FTableDefs) Then
   FreeAndNil(FTableDefs);
  {$IFNDEF FPC}
  {$IFDEF SUPPORTS_ENHANCED_RECORDS}
//  FArray := Null;
  {$ELSE}
  If Assigned(FArray) Then
   Begin
    FArray.Done;
    FArray.Free;
   End;
  FArray := nil;
  {$ENDIF}
  {$ELSE}
  If Assigned(FArray) Then
   Begin
    FArray.Done;
    FArray.Free;
   End;
  FArray := nil;
  {$ENDIF}
 Inherited;
End;

{$IFDEF NEXTGEN}
Function TRESTDWCustomDataSet.AllocRecBuf : TRecBuf;
Begin
 Result := TRecBuf(AllocRecordBuffer);
End;

Procedure TRESTDWCustomDataSet.FreeRecBuf(Var Buffer: TRecBuf);
Begin
 FreeRecordBuffer(TRecordBuffer(Buffer));
End;
{$ENDIF}

Procedure TRESTDWCustomDataSet.FreeRecordBuffer(Var Buffer: TRecordBuffer);
Begin
  {$IFNDEF FPC}
   {$IFDEF SUPPORTS_ENHANCED_RECORDS}
    FreeMem(Buffer);  //  Buffer := Null;  //TODO Revision XyberX
   {$ELSE}
    FreeMem(Buffer);
   {$ENDIF}
  {$ELSE}
   FreeMem(Buffer);
  {$ENDIF}
 Buffer := nil;
End;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
{$IF Defined(HAS_UTF8)}
Procedure TRESTDWCustomDataSet.GetBookmarkData(Buffer : TRecBuf;
                                           Data   : TBookmark);
{$ELSE}
Procedure TRESTDWCustomDataSet.GetBookmarkData(Buffer : TRecordBuffer;
                                           Data   : Pointer);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.GetBookmarkData(Buffer : TRecordBuffer;
                                           Data   : Pointer);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.GetBookmarkData(Buffer : TRecordBuffer;
                                           Data   : Pointer);
{$ENDIF}
begin
  {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
//  Inherited GetBookmarkData(Buffer, Data);
   {$IF Defined(HAS_UTF8)}
    LongInt(TRecordBuffer(Data)) := PVarRecInfo(Buffer).Bookmark;
//    Integer(Data)  := PVarRecInfo(Buffer).Bookmark;
   {$ELSE}
    Integer(Data^) := PVarRecInfo(Buffer).Bookmark;
   {$IFEND}
  {$ELSE}
  Integer(Data^) := PVarRecInfo(Buffer).Bookmark;
  {$IFEND}
  {$ELSE}
  Integer(Data^) := PVarRecInfo(Buffer).Bookmark;
  {$ENDIF}
end;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Function TRESTDWCustomDataSet.GetBookmarkFlag(Buffer : TRecBuf)      : TBookmarkFlag;
{$ELSE}
Function TRESTDWCustomDataSet.GetBookmarkFlag(Buffer : TRecordBuffer): TBookmarkFlag;
{$IFEND}
{$ELSE}
Function TRESTDWCustomDataSet.GetBookmarkFlag(Buffer : TRecordBuffer): TBookmarkFlag;
{$ENDIF}
Begin
 Result := PVarRecInfo(Buffer).BookmarkFlag;
End;

Function TRESTDWCustomDataSet.GetControlInterface: IInterface;
begin
  Result := nil;
end;

Function TRESTDWCustomDataSet.GetDataByCell(const FieldName: string;
  RecNo: Integer): Variant;
begin
  Result := FArray.DataByCell[FArray.FieldIndex[FieldName], RecNo - 1];
end;

Function TRESTDWCustomDataSet.GetDataByName(const Name: string): Variant;
begin
  Result := FieldByName(Name).Value;
end;

{$IFDEF SUPPORTS_FOR_IN}
Function TRESTDWCustomDataSet.GetEnumerator: TRESTDWCustomDatasetEnumerator;
begin
  Result := TRESTDWCustomDatasetEnumerator.Create(Self);
end;
{$ENDIF}

Function TRESTDWCustomDataSet.GetFieldClass(FieldType: TFieldType): TFieldClass;
var
  I: Integer;
begin
  if (csDesigning in ComponentState) and (FDsgnFieldName <> '') then
  begin
    Result := nil;
    I := FArray.FieldIndex[FDsgnFieldName];
    if I >= 0 then
      case FArray.GetFieldDef(I) of
        dwftStream: Result := TStreamField;
        dwftExtended: Result := TExtendedField;
        {$IFNDEF FPC}
        dwftTimeStampOffset: Result := TSQLTimeStampOffsetField;
        {$ENDIF}
        dwftColor: Result := TColorField;
      end;
    if Result <> nil then
      Exit;
  end;
  if FFieldDefClass = nil then
    Result := DefaultFieldClasses[FieldType] else
    Result := FFieldDefClass;
end;

{$IFNDEF FPC}
{$IF NOT Defined(HAS_FMX)}
{$IF CompilerVersion < 25}
Function TRESTDWCustomDataSet.GetFieldData (Field              : TField;
                                        Buffer             : Pointer)      : Boolean;
{$ELSE}
Function TRESTDWCustomDataSet.GetFieldData (AField             : TField;
                                        Var ABuffer        : TValueBuffer) : Boolean;
{$IFEND}

 Function DoCalcLookup(Index: Integer): Boolean;
 Var
  V: Variant;
  B: Boolean;
 Begin
  {$IF CompilerVersion < 25}
   V := Field.LookupDataSet.Lookup(Field.LookupKeyFields,
   FArray.GetDataResult(FArray.RecNo, Field.KeyFields), Field.LookupResultField);
  {$ELSE}
   V := aField.LookupDataSet.Lookup(aField.LookupKeyFields,
   FArray.GetDataResult(FArray.RecNo, aField.KeyFields), aField.LookupResultField);
  {$IFEND}
  Result := not VarIsNull(V);
  If Result Then
   Begin
    If State <> dsBrowse Then
     B := FArray.Data[Index] <> V
    Else
     B := False;
    FArray.Data[Index] := V;
    If B Then
     {$IFDEF FPC}
      DataEvent(deFieldChange, NativeInt(Field));
     {$ELSE}
      {$IF CompilerVersion < 25}
       DataEvent(deFieldChange, Longint(Field));
      {$ELSE}
       DataEvent(deFieldChange, Longint(aField));
      {$IFEND}
     {$ENDIF}
   End;
 End;
Var
  I, P, Row, Sc, Temp: Integer;
  S : AnsiString;
 {$IFDEF FPC}
  W : UnicodeString;
 {$ELSE}
  {$IF CompilerVersion < 25}
   W : String;
  {$ELSE}
   W : UnicodeString;
  {$IFEND}
 {$ENDIF}
  D: TDateTime;
begin
  Result := False;
{$MESSAGE Hint 'Todo: switch off window Local Variables when debug...'}
  {$IF CompilerVersion < 25}
  if not IsEmpty and ((Field.FieldNo > 0) or
    (Field.FieldKind in [fkCalculated, fkLookup])) then
  {$ELSE}
  if not IsEmpty and ((aField.FieldNo > 0) or
    (aField.FieldKind in [fkCalculated, fkLookup])) then
  {$IFEND}
  begin
    Temp := FArray.RecNo;
    Row := PVarRecInfo(ActiveBuffer).Bookmark;
    FArray.RecNo := Row;
    {$IF CompilerVersion < 25}
    I := FArray.FieldIndex[Field.FieldName];
    case Field.FieldKind of
    {$ELSE}
    I := FArray.FieldIndex[aField.FieldName];
    case aField.FieldKind of
    {$IFEND}
//      fkCalculated, fkInternalCalc:
//        Inherited DoOnCalcFields;
      fkLookup:
        if not DoCalcLookup(I) then
        begin
          FArray.RecNo := Temp;
          Exit;
        end;
    end;
    {$IF CompilerVersion < 25}
    if Assigned (Buffer) then
    {$ELSE}
    if Assigned (aBuffer) then
    {$IFEND}
    begin
      if VarIsNull(FArray.DataByCell[I, Row])
        or VarIsClear(FArray.DataByCell[I, Row]) then
      begin
        FArray.RecNo := Temp;
        Exit;
      end;
      case FArray.FieldType[I] of
{$IFDEF COMPILER10_UP}
        ftOraInterval,
{$ENDIF}
        ftString, ftFixedChar, ftGuid: begin
          S := FArray.GetDataAnsiString(I);
//          If Length(S) > 0 Then
//           If S[Length(S)] <> #0 Then
          S := S + #0;
         {$IF Defined(HAS_UTF8)}
          aBuffer := TValueBuffer(TEncoding.ANSI.GetBytes(S)); //TEncoding.ANSI.GetBytes(S));
         {$ELSE}
          {$IF CompilerVersion < 25}
           Move(Pointer(@S[InitStrPos])^, Buffer^, Length(S));
          {$ELSE}
           aBuffer := TEncoding.ANSI.GetBytes(S);
          {$IFEND}
         {$IFEND}
        end;
        ftSmallint:
          {$IF CompilerVersion < 25}
          PSmallint(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PSmallint(aBuffer)^ := FArray.Data[I];
          {$IFEND}
{$IFDEF COMPILER12_UP}
        ftLongWord:
          {$IF CompilerVersion < 25}
          PLongWord(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PLongWord(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftShortint, ftByte:
          {$IF CompilerVersion < 25}
          PByte(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PByte(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftExtended:
          {$IF CompilerVersion < 25}
          PExtended(Buffer)^ := Extended(FArray.Data[I]); //_RealSupportManager._VarToReal(FArray.Data[I]);
          {$ELSE}
          PExtended(aBuffer)^ := FArray.Data[I];
          {$IFEND}
{$ENDIF}
{$IFDEF COMPILER14_UP}
        ftSingle:
          {$IF CompilerVersion < 25}
          PSingle(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PSingle(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftTimeStampOffset: begin
          D := FArray.Data[I];
          if WindowsStopsAt1601 > YearOf(D) then
            D := IncYear(D, WindowsStopsAt1601 - YearOf(D));
          {$IF CompilerVersion < 25}
          PSQLTimeStampOffset(Buffer)^ := DateTimeToSQLTimeStampOffset(D);
          {$ELSE}
          PSQLTimeStampOffset(aBuffer)^ := DateTimeToSQLTimeStampOffset(D);
          {$IFEND}
        end;
{$ENDIF}
        ftInteger, ftAutoInc, ftTime, ftDate:
          {$IF CompilerVersion < 25}
          PInteger(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PInteger(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftWord:
          {$IF CompilerVersion < 25}
          PWord(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PWord(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftBoolean:
          {$IF CompilerVersion < 25}
          PWordBool(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PWordBool(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftFloat, ftCurrency,
        ftBCD, ftFMTBcd:
          {$IF CompilerVersion < 25}
          PDouble(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PDouble(aBuffer)^ := FArray.Data[I];
          {$IFEND}
//        ftBCD: begin
//          {$IF CompilerVersion < 25}
//          P := TBCDField(Field).Precision;
//          if P = 0 then P := MaxFMTBcdDigits;
//          Sc := Field.Size;
//          if Sc = 0 then Sc := MaxBcdScale;
//          CurrToBCD(FArray.Data[I], PBCD(Buffer)^, P, Sc);
//          {$ELSE}
//          P := TBCDField(aField).Precision;
//          if P = 0 then P := MaxFMTBcdDigits;
//          Sc := TBCDField(aField).Size;
//          if Sc = 0 then Sc := MaxBcdScale;
//          CurrToBCD(FArray.Data[I], PBCD(aBuffer)^, P, Sc);
//          {$IFEND}
//        end;
//        ftFMTBcd:
//          {$IF CompilerVersion < 25}
//          PBCD(Buffer)^ := VarToBcd(FArray.Data[I]);
//          {$ELSE}
//          PBCD(aBuffer)^ := VarToBcd(FArray.Data[I]);
//          {$IFEND}
        ftDateTime: Begin
                     D := FArray.Data[I];
                     {$IF CompilerVersion < 25}
                     PSQLTimeStamp(Buffer)^ := DateTimeToSQLTimeStamp(D);
                     {$ELSE}
                     PSQLTimeStamp(aBuffer)^ := DateTimeToSQLTimeStamp(D);
                     {$IFEND}
                    End;
        ftLargeint:
          {$IF CompilerVersion < 25}
          PInt64(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PInt64(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftVariant:
          {$IF CompilerVersion < 25}
          PVariant(Buffer)^ := FArray.Data[I];
          {$ELSE}
          PVariant(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        ftInterface: ;
        ftIDispatch: ;
{$IFDEF COMPILER10_UP}
        ftOraTimeStamp,
{$ENDIF}
        ftTimeStamp: begin
          D := FArray.Data[I];
          {$IF CompilerVersion < 25}
          PSQLTimeStamp(Buffer)^ := DateTimeToSQLTimeStamp(D);
          {$ELSE}
          PSQLTimeStamp(aBuffer)^ := DateTimeToSQLTimeStamp(D);
          {$IFEND}
        end;
{$IFDEF COMPILER10_UP}
        ftFixedWideChar,
{$ENDIF}
        ftWideString: begin
          W := FArray.GetDataWideString(I);
         {$IF Defined(HAS_UTF8)}
          aBuffer := TValueBuffer(W);
         {$ELSE}
          {$IF CompilerVersion < 25}
          Move(Pointer(@W[InitStrPos])^, Buffer^, Length(W) * sizeof(char));
          {$ELSE}
          aBuffer := TValueBuffer(W);
          {$IFEND}
         {$IFEND}
        end;
      else
        case FArray.GetFieldDef(I) of
{$IFNDEF COMPILER11_UP}
          dwftExtended:
            PExtended(Buffer)^ := Extended(FArray.Data[I]);//_RealSupportManager._VarToReal(FArray.Data[I]);
          dwftTimeStampOffset: begin
            D := FArray.Data[I];
            if WindowsStopsAt1601 > YearOf(D) then
              D := IncYear(D, WindowsStopsAt1601 - YearOf(D));
            PSQLTimeStampOffset(Buffer)^ := DateTimeToSQLTimeStamp(D);
          end;
{$ENDIF}  dwftColor:
          {$IF CompilerVersion < 25}
            PInteger(Buffer)^ := FArray.Data[I];
          {$ELSE}
            PInteger(aBuffer)^ := FArray.Data[I];
          {$IFEND}
        end;
      end;
      FArray.RecNo := Temp;
    end else
    begin
      FArray.RecNo := Temp;
      // This Field IsNull?
      if VarIsNull(FArray.DataByCell[I, Row]) or
        FArray.GetIsEmpty(I, Row) then
        Exit;
    end;
    Result := True;
  end;
End;
{$ELSE}
Function TRESTDWCustomDataSet.GetFieldData (AField             : TField;
                                        Var ABuffer        : TValueBuffer) : Boolean;
 Function DoCalcLookup(Index: Integer): Boolean;
 Var
  V: Variant;
  B: Boolean;
 Begin
  V := aField.LookupDataSet.Lookup(aField.LookupKeyFields,
  FArray.GetDataResult(FArray.RecNo, aField.KeyFields),
  aField.LookupResultField);
  Result := not VarIsNull(V);
  If Result Then
   Begin
    If State <> dsBrowse Then
     B := FArray.Data[Index] <> V
    Else
     B := False;
    FArray.Data[Index] := V;
    If B Then
     {$IFDEF FPC}
      DataEvent(deFieldChange, NativeInt(aField));
     {$ELSE}
      DataEvent(deFieldChange, LongInt(aField));
     {$ENDIF}
   End;
 End;
Var
  I, P, Row, Sc, Temp: Integer;
 {$IFNDEF FPC}
   {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
    {$IF Defined(HAS_FMX)}
     S, W    : String;
    {$ELSE}
     S, W    : Utf8String;
    {$IFEND}
   {$ELSE}
    {$IF Defined(HAS_FMX)}
     S, W    : Utf8String;
    {$ELSE}
     W, S : AnsiString;
    {$IFEND}
   {$IFEND}
  {$ELSE}
  W, S : AnsiString;
 {$ENDIF}
{$IFNDEF DELPHI17_UP}
  T: TTimeStamp;
{$ENDIF}
  D: TDateTime;
begin
  Result := False;
  if not IsEmpty and ((aField.FieldNo > 0) or
    (aField.FieldKind in [fkCalculated, fkLookup])) then
  begin
    Temp := FArray.RecNo;
    Row := PVarRecInfo(ActiveBuffer).Bookmark;
    FArray.RecNo := Row;
    I := FArray.FieldIndex[aField.FieldName];

    case aField.FieldKind of
      fkCalculated, fkInternalCalc:
        Inherited DoOnCalcFields;
      fkLookup:
        if not DoCalcLookup(I) then
        begin
          FArray.RecNo := Temp;
          Exit;
        end;
    end;

    if Assigned (aBuffer) then
    begin
      if VarIsNull(FArray.DataByCell[I, Row])
        or VarIsClear(FArray.DataByCell[I, Row]) then
      begin
        FArray.RecNo := Temp;
        Exit;
      end;
      case FArray.FieldType[I] of
{$IFDEF COMPILER10_UP}
        ftOraInterval,
{$ENDIF}
        ftString, ftFixedChar, ftGuid: begin
          S := FArray.GetDataAnsiString(I) + #0;
         {$IF Defined(HAS_UTF8)}
          aBuffer := TValueBuffer(TEncoding.ANSI.GetBytes(S));
         {$ELSE}
          aBuffer := TValueBuffer(TEncoding.ANSI.GetBytes(S));
         {$IFEND}
        end;
        ftSmallint:
          PSmallint(aBuffer)^ := FArray.Data[I];
{$IFDEF COMPILER12_UP}
        ftLongWord:
          PLongWord(aBuffer)^ := FArray.Data[I];
        ftShortint, ftByte:
          PByte(aBuffer)^ := FArray.Data[I];
        ftExtended:
          PExtended(aBuffer)^ := Extended(FArray.Data[I]);//_RealSupportManager._VarToReal(FArray.Data[I]);
{$ENDIF}
{$IFDEF COMPILER14_UP}
        ftSingle:
          PSingle(aBuffer)^ := FArray.Data[I];
        ftTimeStampOffset: begin
          D := FArray.Data[I];
          if WindowsStopsAt1601 > YearOf(D) then
            D := IncYear(D, WindowsStopsAt1601 - YearOf(D));
          PSQLTimeStampOffset(aBuffer)^ := DateTimeToSQLTimeStampOffset(D);
        end;
{$ENDIF}
        ftInteger, ftAutoInc, ftDate, ftTime:
          PInteger(aBuffer)^ := FArray.Data[I];
        ftWord:
          PWord(aBuffer)^ := FArray.Data[I];
        ftBoolean:
          PWordBool(aBuffer)^ := FArray.Data[I];
        ftFloat, ftCurrency:
          PDouble(aBuffer)^ := FArray.Data[I];
        ftBCD: begin
          P := TBCDField(aField).Precision;
          if P = 0 then P := MaxFMTBcdDigits;
          Sc := aField.Size;
          if Sc = 0 then Sc := MaxBcdScale;
          CurrToBCD(FArray.Data[I], PBCD(aBuffer)^, P, Sc);
        end;
        ftFMTBcd:
          PBCD(aBuffer)^ := VarToBcd(FArray.Data[I]);
        ftDateTime: begin
          D := FArray.Data[I];
          PSQLTimeStamp(aBuffer)^ := DateTimeToSQLTimeStamp(D);
        end;
        ftLargeint:
          PInt64(aBuffer)^ := FArray.Data[I];
        ftVariant:
          PVariant(aBuffer)^ := FArray.Data[I];
        ftInterface: ;
        ftIDispatch: ;
{$IFDEF COMPILER10_UP}
        ftOraTimeStamp,
{$ENDIF}
        ftTimeStamp: begin
          D := FArray.Data[I];
          PSQLTimeStamp(aBuffer)^ := DateTimeToSQLTimeStamp(D);
        end;
{$IFDEF COMPILER10_UP}
        ftFixedWideChar,
{$ENDIF}
        ftWideString: begin
          W := FArray.GetDataWideString(I) + #0;
         {$IF Defined(HAS_UTF8)}
          aBuffer := TValueBuffer(TEncoding.ANSI.GetBytes(W));
         {$ELSE}
          aBuffer := TValueBuffer(TEncoding.ANSI.GetBytes(W));
         {$IFEND}
        end;
      else
        case FArray.GetFieldDef(I) of
{$IFNDEF COMPILER11_UP}
          dwftExtended:
            PExtended(Buffer)^ := _RealSupportManager._VarToReal(FArray.Data[I]);
          dwftTimeStampOffset: begin
            D := FArray.Data[I];
            if WindowsStopsAt1601 > YearOf(D) then
              D := IncYear(D, WindowsStopsAt1601 - YearOf(D));
            PSQLTimeStampOffset(Buffer)^ := DateTimeToSQLTimeStamp(D);
          end;
{$ENDIF}  dwftColor:
            PInteger(aBuffer)^ := FArray.Data[I];
        end;
      end;
      FArray.RecNo := Temp;
    end else
    begin
      FArray.RecNo := Temp;
      // This Field IsNull?
      if VarIsNull(FArray.DataByCell[I, Row]) or
        FArray.GetIsEmpty(I, Row) then
        Exit;
    end;
    Result := True;
  end;
End;
{$IFEND}
{$ELSE}
Function TRESTDWCustomDataSet.GetFieldData(Field: TField;
                                       Buffer: Pointer): Boolean;
 Function DoCalcLookup(Index: Integer): Boolean;
 Var
  V: Variant;
  B: Boolean;
 Begin
  V := Field.LookupDataSet.Lookup(Field.LookupKeyFields,
  FArray.GetDataResult(FArray.RecNo, Field.KeyFields),
  Field.LookupResultField);
  Result := not VarIsNull(V);
  If Result Then
   Begin
    If State <> dsBrowse Then
     B := FArray.Data[Index] <> V
    Else
     B := False;
    FArray.Data[Index] := V;
    If B Then
     {$IFDEF FPC}
      DataEvent(deFieldChange, NativeInt(Field));
     {$ELSE}
      DataEvent(deFieldChange, Longint(Field));
     {$ENDIF}
   End;
 End;
Var
  I, P, Row, Sc, Temp: Integer;
  S: AnsiString;
  W: WideString;
{$IFNDEF DELPHI17_UP}
  T: TTimeStamp;
{$ENDIF}
  D: TDateTime;
begin
  Result := False;
{$MESSAGE Hint 'Todo: switch off window Local Variables when debug...'}
  if not IsEmpty and ((Field.FieldNo > 0) or
    (Field.FieldKind in [fkCalculated, fkLookup])) then
  begin
    Temp := FArray.RecNo;
    Row := PVarRecInfo(ActiveBuffer).Bookmark;
    FArray.RecNo := Row;
    I := FArray.FieldIndex[Field.FieldName];

    case Field.FieldKind of
      fkCalculated, fkInternalCalc:
        Inherited DoOnCalcFields;
      fkLookup:
        if not DoCalcLookup(I) then
        begin
          FArray.RecNo := Temp;
          Exit;
        end;
    end;

    if Assigned (Buffer) then
    begin
      if VarIsNull(FArray.DataByCell[I, Row])
        or VarIsClear(FArray.DataByCell[I, Row]) then
      begin
        FArray.RecNo := Temp;
        Exit;
      end;
      case FArray.FieldType[I] of
{$IFDEF COMPILER10_UP}
        ftOraInterval,
{$ENDIF}
        ftString, ftFixedChar, ftGuid: begin
          S := FArray.GetDataAnsiString(I) + #0;
          Move(Pointer(@S[InitStrPos])^, Buffer^, Length(S));
        end;
        ftSmallint:
          PSmallint(Buffer)^ := FArray.Data[I];
{$IFDEF COMPILER12_UP}
        ftLongWord:
          PLongWord(Buffer)^ := FArray.Data[I];
        ftShortint, ftByte:
          PByte(Buffer)^ := FArray.Data[I];
        ftExtended:
          PExtended(Buffer)^ := _RealSupportManager._VarToReal(FArray.Data[I]);
{$ENDIF}
{$IFDEF COMPILER14_UP}
        ftSingle:
          PSingle(Buffer)^ := FArray.Data[I];
        ftTimeStampOffset: begin
          D := FArray.Data[I];
          if WindowsStopsAt1601 > YearOf(D) then
            D := IncYear(D, WindowsStopsAt1601 - YearOf(D));
          PSQLTimeStampOffset(Buffer)^ := DateTimeToSQLTimeStampOffset(D);
        end;
{$ENDIF}
        ftInteger, ftAutoInc, ftDate, ftTime:
          PInteger(Buffer)^ := FArray.Data[I];
        ftWord:
          PWord(Buffer)^ := FArray.Data[I];
        ftBoolean:
          PWordBool(Buffer)^ := FArray.Data[I];
{Eloy}
        ftFloat, ftCurrency, ftBCD, ftFMTBcd:
         Begin
          PDouble(Buffer)^ := FArray.Data[I];
         End;
        //ftBCD: begin
        //  P := TBCDField(Field).Precision;
        //  if P = 0 then P := MaxFMTBcdDigits;
        //  Sc := Field.Size;
        //  if Sc = 0 then Sc := MaxBcdScale;
        //  CurrToBCD(FArray.Data[I], PBCD(Buffer)^, P, Sc);
        //end;
        //ftFMTBcd:
        //  PBCD(Buffer)^ := VarToBcd(FArray.Data[I]);
{Eloy}
        ftDateTime: begin
          {$IFDEF FPC}
           D := TDateTime(FArray.Data[I]);
          {$ELSE}
          D := FArray.Data[I];
          {$ENDIF}
{$IFDEF DELPHI17_UP}
          PDateTime(Buffer)^ := D;
{$ELSE}   DataConvert(Field, @D, Buffer, True);
{$ENDIF}
        end;
        ftLargeint:
          PInt64(Buffer)^ := FArray.Data[I];
        ftVariant:
          PVariant(Buffer)^ := FArray.Data[I];
        ftInterface: ;
        ftIDispatch: ;
{$IFDEF COMPILER10_UP}
        ftOraTimeStamp,
{$ENDIF}
        ftTimeStamp: begin
          D := FArray.Data[I];
          PSQLTimeStamp(Buffer)^ := DateTimeToSQLTimeStamp(D);
        end;
{$IFDEF COMPILER10_UP}
        ftFixedWideChar,
{$ENDIF}
        ftWideString: begin
          W := FArray.GetDataWideString(I) + #0;
         {$IF Defined(HAS_UTF8)}
          aBuffer := TValueBuffer(W);
         {$ELSE}
           {$IFDEF FPC}
            Move(Pointer(@S[InitStrPos])^, Buffer^, Length(S));
           {$ELSE}
            aBuffer := TValueBuffer(W);
           {$ENDIF}
         {$IFEND}
        end;
      else
        case FArray.GetFieldDef(I) of
{$IFNDEF COMPILER11_UP}
          dwftExtended:
            PExtended(Buffer)^ := Extended(FArray.Data[I]);//_RealSupportManager._VarToReal(FArray.Data[I]);
          dwftTimeStampOffset: begin
            D := FArray.Data[I];
            if WindowsStopsAt1601 > YearOf(D) then
              D := IncYear(D, WindowsStopsAt1601 - YearOf(D));
            PSQLTimeStampOffset(Buffer)^ := DateTimeToSQLTimeStamp(D);
          end;
{$ENDIF}  dwftColor:
            PInteger(Buffer)^ := FArray.Data[I];
        end;
      end;
      FArray.RecNo := Temp;
    end else
    begin
      FArray.RecNo := Temp;
      // This Field IsNull?
      if VarIsNull(FArray.DataByCell[I, Row]) or
        FArray.GetIsEmpty(I, Row) then
        Exit;
    end;
    Result := True;
  end;
End;
{$ENDIF}

Function TRESTDWCustomDataSet.GetRecNo: Integer;
begin
  UpdateCursorPos;
  If FArray.RecCount > 0 Then
   Result := FArray.RecNo + 1
  Else
   Result := 0;
end;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Function TRESTDWCustomDataSet.GetRecord(Buffer   : TRecBuf;
                                    GetMode  : TGetMode;
                                    DoCheck  : Boolean) : TGetResult;
{$ELSE}
Function TRESTDWCustomDataSet.GetRecord(Buffer   : TRecordBuffer;
                                    GetMode  : TGetMode;
                                    DoCheck  : Boolean) : TGetResult;
{$IFEND}
{$ELSE}
Function TRESTDWCustomDataSet.GetRecord(Buffer   : TRecordBuffer;
                                    GetMode  : TGetMode;
                                    DoCheck  : Boolean) : TGetResult;
{$ENDIF}
begin
  Result := grOK; // default
  case GetMode of
    gmNext: // move on
      if FArray.RecNo < FArray.RecCount - 1 then
        begin if not FIsCurrentFirst then FArray.Next end
      else
        if not FIsCurrentFirst or (FArray.RecCount = 0) then
          Result := grEOF; // end of file
    gmPrior: // move back
      if FArray.RecNo > 0 then
        begin if not FIsCurrentFirst then FArray.Prior end
      else
        Result := grBOF; // begin of file
    gmCurrent: // check if empty
      if FArray.RecNo >= FArray.RecCount then
        Result := grError;
  end;

  FIsCurrentFirst := False;
  // load the data
  if Result = grOK then
    InternalLoadCurrentRecord (Buffer)
  else
    if (Result = grError) and DoCheck then
      raise DwTableError.Create (SInvalidRecord);
end;

Function TRESTDWCustomDataSet.GetRecordCount: Integer;
begin
  CheckActive;
  Result := FArray.RecCount;
end;

Function TRESTDWCustomDataSet.GetRestrictLength: TRestrictLength;
begin
  Result := FArray.FRestrictLength;
end;

Procedure TRESTDWCustomDataSet.InternalFirst;
begin
  FArray.First;
  FIsCurrentFirst := True;
end;

Procedure TRESTDWCustomDataSet.InternalGotoBookmark(Bookmark: Pointer);
var
  ReqBookmark: Integer;
begin
  ReqBookmark := Integer (Bookmark^);
  if (ReqBookmark >= -1) and (ReqBookmark <= FArray.RecCount) then
  begin
    FIsCurrentFirst := ReqBookmark = -1;
    if FIsCurrentFirst then
      FArray.RecNo := 0 else
      FArray.RecNo := ReqBookmark;
  end
  else
    raise DwTableError.CreateFmt (SBookmarkDNotFound, [ReqBookmark]);
end;

Procedure TRESTDWCustomDataSet.InternalInitFieldDefs;
Var
 FieldName  : String;
 vFieldSize,
 I          : Integer;
 FieldType  : TFieldType;
Begin
 If (TableDefs.Text = '')         And
    (FArray.GetDefinitions <> '') Then
  TableDefs.Text := String(FArray.GetDefinitions);
 FieldDefs.Clear;
 If (FArray.FieldCount > 0) And
    (FieldDefs.count = 0)   Then
  Begin
   For I := 0 to FArray.FieldCount - 1 do
    Begin
     // create the field
     FieldType  := FArray.FieldType[I];
     vFieldSize := FArray.Size[I];
     If FArray.GetFieldDef(I) = 0 Then
      raise DwTableError.CreateFmt(SInitFieldsDefsNoType, [I]);
     FieldName := FArray.FieldName[I];
     If FieldName = '' Then
      raise DwTableError.CreateFmt(SInitFieldsDefsNoName, [I]);
     FFieldDefClass := nil;
      case FieldType of
        ftString, ftMemo, ftFmtMemo, ftFixedChar, ftOraClob,
        ftWideString,
        ftGuid: ;
        ftSmallint: ;
  {$IFDEF COMPILER14_UP}
        ftLongWord, ftShortint, ftByte, ftExtended,
        ftSingle: ;
        ftStream: ;
        ftTimeStampOffset: ;
  {$ENDIF}
        ftInteger, ftAutoInc,
        ftDate, ftTime: ;
        ftWord, ftBoolean, ftCurrency: ;
        ftFloat,
        ftBCD, ftFMTBcd : Begin
                           vFieldSize := 0;
                           FieldType := ftFloat;
                          End;
        ftTimeStamp,
        ftDateTime      : Begin
                           If FieldType = ftDateTime Then
                            Begin
                             {$IFDEF FPC}
                              FieldType := ftDateTime;
                             {$ELSE}
                              FieldType := ftTimeStamp;
                             {$ENDIF}
                            End;
                          End;
        ftLargeint: ;
        ftVariant: ;
        ftInterface, ftIDispatch:
          Continue;
  {$IFDEF COMPILER10_UP}
        ftOraInterval, ftOraTimeStamp, ftFixedWideChar, ftWideMemo,
  {$ENDIF}
        ftBytes, ftVarBytes, ftBlob, ftGraphic, ftParadoxOle, ftDBaseOle,
        ftTypedBinary, ftOraBlob: ;
      else
        case FArray.GetFieldDef(I) of
  {$IFNDEF COMPILER11_UP}
          dwftLongWord, dwftShortint, dwftByte, dwftSingle: ;
          dwftExtended: FFieldDefClass := TExtendedField;
          dwftStream: FFieldDefClass := TStreamField;
          {$IFNDEF FPC}
          dwftTimeStampOffset: FFieldDefClass := TSQLTimeStampOffsetField;
          {$ENDIF}
  {$ENDIF}
          dwftColor: FFieldDefClass := TColorField;
        else
          raise DwTableError.CreateFmt(SUnsupportedTypeField,
            ['InitFieldsDefs', FieldName]);
        end;
      end;
      // Helper old type that Peek At design (subrange false)
      if (csDesigning in ComponentState) then
        FieldDefs.Add(FieldName, FieldType, vFieldSize, False)
      else
        FieldDefs.Add(FieldName, FieldType, vFieldSize, False);
      If FieldDefs.Count > I Then
       Begin
        FieldDefs[I].InternalCalcField := FArray.Calculated[I];
        FieldDefs[I].Required  := FArray.Required[I];
        FieldDefs[I].Precision := FArray.Precision[I];
       End;
    end;
   End;
  FFieldDefClass := nil;
end;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Procedure TRESTDWCustomDataSet.InternalInitRecord(Buffer: TRecBuf);
{$ELSE}
Procedure TRESTDWCustomDataSet.InternalInitRecord(Buffer: TRecordBuffer);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.InternalInitRecord(Buffer: TRecordBuffer);
{$ENDIF}
begin
  {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
  FillChar(PChar(Buffer), sizeof (TVarRecInfo), 0);
  {$ELSE}
  FillChar(Buffer^, sizeof (TVarRecInfo), 0);
  {$IFEND}
  {$ELSE}
  FillChar(Buffer^, sizeof (TVarRecInfo), 0);
  {$ENDIF}
end;

Procedure TRESTDWCustomDataSet.InternalLast;
begin
  FArray.Last;
  FIsCurrentFirst := False;
end;


{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Procedure TRESTDWCustomDataSet.InternalLoadCurrentRecord(Buffer  : TRecBuf);
{$ELSE}
Procedure TRESTDWCustomDataSet.InternalLoadCurrentRecord(Buffer: TRecordBuffer);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.InternalLoadCurrentRecord(Buffer: TRecordBuffer);
{$ENDIF}
begin
  with PVarRecInfo(Buffer)^ do
  begin
    BookmarkFlag := bfCurrent;
    if FIsCurrentFirst then
      Bookmark := -1 else
      Bookmark := FArray.RecNo;
  end;
end;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Procedure TRESTDWCustomDataSet.InternalSetToRecord(Buffer: TRecBuf);
{$ELSE}
Procedure TRESTDWCustomDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
{$ENDIF}
var
  ReqBookmark: Integer;
begin
  ReqBookmark := PVarRecInfo(Buffer).Bookmark;
  InternalGotoBookmark(@ReqBookmark);
end;

Function TRESTDWCustomDataSet.IsCursorOpen: Boolean;
begin
  Result := dwsOpen in FState;
end;

Procedure TRESTDWCustomDataSet.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TBufferedStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

Procedure TRESTDWCustomDataSet.SaveToStream(F : TStream);
Begin
 FArray.SaveToStream(F);
End;

Procedure TRESTDWMemtable.Clear;
Begin
 If State In [dsInsert, dsEdit] Then
  Cancel;
 Close;
 If Active Then
  Begin
   Open;
   Resync([]);
  End;
End;

Procedure TRESTDWMemtable.DeleteFields;
Begin
 Clear;
 FieldDefs.Clear;
 Fields.Clear;
End;

Procedure TRESTDWMemtable.Assign       (Source     : TDataSet;
                                    IgnoreData : Boolean = False);
 Procedure InternalCreateFieldDefs (Fields    : TFields;
                                    FieldDefs : TFieldDefs);
 Var
  I,
  FieldDefIndex  : Integer;
  Field          : TField;
  FieldDef,
  SourceFieldDef : TFieldDef;
  NewDataType    : TFieldType;
 Begin
  FieldDefs.BeginUpdate;
  Try
   For I := 0 To Fields.Count - 1 Do
    Begin
     Field := Fields[I];
     FieldDefIndex := FieldDefs.IndexOf(Field.FieldName);
     If FieldDefIndex <> -1 Then
      SourceFieldDef := Source.FieldDefs[FieldDefIndex]
     Else
      SourceFieldDef := Nil;
     Case Field.DataType Of
      ftOraBlob        : NewDataType := ftBlob;
      ftOraClob        : NewDataType := ftMemo;
      {$IFNDEF FPC}
       {$IF CompilerVersion > 22}
        ftSingle         : NewDataType := ftFloat; //Wesley eu que coloquei isso aqui
        ftWideMemo       : NewDataType := ftWideString; //Wesley eu que coloquei isso aqui
        ftOraTimeStamp : NewDataType := ftTimeStamp;
       {$IFEND}
      {$ENDIF}
      Else If Field.DataType in [ftFloat, ftBCD, ftFmtBCD{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftExtended{$IFEND}{$ENDIF}] Then
       NewDataType := ftFloat
      Else
       NewDataType := Field.DataType;
     End;
     If NewDataType in SupportFieldTypes Then
      Begin
       FieldDef := FieldDefs.AddFieldDef;
       If vEncoding = esUtf8 Then
        Begin
        {$IFDEF FPC}
         FieldDef.Name   := Field.FieldName;
        {$ELSE}
         FieldDef.Name   := UTF8Encode(Field.FieldName);
        {$ENDIF}
        End
       Else
        FieldDef.Name    := Field.FieldName;
//       FieldDef.Name := Field.FieldName;
       FieldDef.DataType := NewDataType;
       If FieldDef.DataType = ftFloat Then
        FieldDef.Size := 0
       Else
        FieldDef.Size := Field.Size;
       If Field.Required Then
        FieldDef.Attributes := [faRequired];
       If SourceFieldDef <> Nil Then
        If faFixed in SourceFieldDef.Attributes Then
         FieldDef.Attributes := FieldDef.Attributes + [faFixed];
       If (Field.DataType = ftBCD)      And
          (Field          Is TBCDField) Then
        FieldDef.Precision := TBCDField(Field).Precision;
       {$IFDEF FPC}
       If (Field.DataType = ftLargeint) And
          (Field is TLargeIntField)     Then
        FieldDef.Precision := 0;
       {$ELSE}
       If Field Is TObjectField Then
        InternalCreateFieldDefs(TObjectField(Field).Fields, FieldDef.ChildDefs);
       {$ENDIF}
      End
     Else
      Begin
       If Not (dwSkipUnSupportedFieldTypes in FOptions) Then
        DatabaseError(SNotSupportFieldType);
      End;
    End;
  Finally
   FieldDefs.EndUpdate;
  End;
 End;
Var
 I         : Integer;
 OldActive : Boolean;
 Bookmark  :{$IFNDEF FPC}
             {$IF CompilerVersion > 22}TBytes
             {$ELSE}String
             {$IFEND}
            {$ELSE}
             TBytes
            {$ENDIF};
 SourceField : TField;
 FieldsRO,
 FieldsRQ    : Array Of Boolean;
 Value       : Variant;
 FieldsMap   : Array of TField;
Begin
 OldActive := Active;
 Close;
 Clear;
 DeleteFields;
 InternalCreateFieldDefs(Source.Fields, FieldDefs);
 If Source.Active Then
  Begin
   DisableControls;
   Source.DisableControls;
//   Bookmark := Source.Bookmark;
   Source.First;
   Open;
   SetLength(FieldsRO, Fields.Count);
   SetLength(FieldsRQ, Fields.Count);
   For I := 0 To Fields.Count - 1 Do
    Begin
     FieldsRO[I]        := Fields[i].ReadOnly;
     Fields[I].ReadOnly := False;
     FieldsRQ[I]        := Fields[i].Required;
     Fields[i].Required := False;
    End;
   Try
    SetLength(FieldsMap, Fields.Count);
    For i := 0 To Fields.Count - 1 Do
     FieldsMap[i] := Source.FieldByName(Fields[i].FieldName);
    While (Not (Source.EOF)) And (Not (IgnoreData)) Do
     Begin
      Append;
      For I := 0 To Fields.Count - 1 Do
       Begin
        SourceField := FieldsMap[I];
        Value       := Null;
        If Not SourceField.IsNull Then
         Begin
          If (Fields[I] Is TLargeIntField) And (Trim(SourceField.AsString) <> '') Then
           TLargeIntField(Fields[I]).AsLargeInt := TLargeIntField(SourceField).AsLargeInt
          {$IFDEF FPC}
          Else
           If (Fields[I] is TTimeField) And (Trim(SourceField.AsString) <> '')  Then
            TTimeField(Fields[I]).AsString := TTimeField(SourceField).AsString
           Else
            If Fields[I] is TBinaryField Then
             Fields[I].AsString := SourceField.AsString
          {$ENDIF}
          Else
           Begin
            Value            := SourceField.Value;
            {$IFDEF FPC}
             Value           := GetStringEncode(Value, vDatabaseCharSet);
            {$ENDIF}
            If Fields[I].DataType in [ftFloat, ftBCD, ftFmtBCD] Then
             {$IFDEF FPC}
             Begin
              If SourceField.DataType in [ftBCD, ftFmtBCD] Then
               Value           := TBCDField(SourceField).Value
              Else
               Value           := SourceField.AsFloat;
              Fields[I].AsFloat := Value;
             End
             {$ELSE}
              Begin
              {$IF Defined(HAS_FMX)}
              If Pos('<', SourceField.AsString) > 0 Then
               Fields[I].Value := StrToFloat(StringReplace(SourceField.AsString, '<',
                                             {$IFDEF COMPILER16_UP}FormatSettings.{$ENDIF}DecimalSeparator,
                                             [rfReplaceAll]))
              Else
              {$IFEND}
               Fields[I].Value := SourceField.Value;
              End
             {$ENDIF}
            Else
             Fields[I].Value := Value;
           End;
         End
        Else
         Fields[I].Value := Value;
       End;
      Post;
      Source.Next;
     End;
   Finally
    First;
    For I := 0 To Fields.Count - 1 Do
     Begin
      Fields[I].ReadOnly := FieldsRO[I];
      Fields[I].Required := FieldsRQ[I];
     End;
    Source.EnableControls;
    EnableControls;
   End;
  End;
End;

Procedure TRESTDWCustomDataSet.SaveDataToStream(F: TStream; SaveData: Boolean);
Var
 OwnerData : OleVariant;
 P         : Pointer;
 vSizeOff  : Integer;
Begin
 If SaveData Then
  Begin
   WriteMarker (F, smData);
   OwnerData := FArray.FData;
   vSizeOff  := VarArrayHighBound(OwnerData, 1);
   P         := VarArrayLock(OwnerData);
   WriteInteger(F, vSizeOff); //FStream.Size);
//   FStream.Position := 0;
   F.WriteBuffer(PArrayData(P), vSizeOff);
   VarArrayUnLock(OwnerData);
//   F.CopyFrom  (FStream, FStream.Size);
//   FFileModified := False;
  End
 Else
  Begin
   WriteMarker(F,smData);
   WriteInteger(F,0);
  End;
End;

Procedure TRESTDWCustomDataSet.LoadFromStream(Stream : TStream);
Begin
 Close;
 Try
 {$IFNDEF FPC}
  {$IFNDEF SUPPORTS_ENHANCED_RECORDS}
  FreeAndNil(FArray);
  FArray := TVariantArray.Create;
  {$ENDIF}
 {$ELSE}
  FreeAndNil(FArray);
  FArray := TVariantArray.Create;
  FArray.DatabaseCharSet := DatabaseCharSet;
 {$ENDIF}
  FArray.Init([]);
  FArray.OnWriterProcess := vOnWriterProcess;
  FArray.FTable := Self;
  With TStringList(FTableDefs) Do
   Begin
    OnChange := nil;
    Text := String(FArray.GetDefinitions);
    FArray.LoadFromStream(Stream);
    OnChange := TableDefsChange;
   End;
  Open;
 Except
  On E : Exception Do
   Raise Exception.Create(Format(cInvalidBinaryRequest, [E.Message]));
 End;
End;

Function TRESTDWCustomDataSet.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  Result := FArray.Locate(KeyFields, KeyValues, Options);
  if Result then
    Resync([]);
end;

Function TRESTDWCustomDataSet.LocateNext(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  Result := FArray.Locate(KeyFields, KeyValues, Options, RecNo);
  if Result then
    Resync([]);
end;

Function TRESTDWCustomDataSet.Lookup(const KeyFields: string; const KeyValues: Variant;
  const ResultFields: string): Variant;
begin
  Result := FArray.Lookup(KeyFields, KeyValues, ResultFields);
end;

Procedure TRESTDWCustomDataSet.SetBlobStream(Stream: TStream);
var
  I, Sz, Temp: Integer;
  {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   S, W: String;
  {$ELSE}
   S: AnsiString;
   W: WideString;
  {$IFEND}
  {$ELSE}
   S: AnsiString;
   W: WideString;
  {$ENDIF}
  B: array of Byte;
  V: Variant;
  F, T: TFieldType;
  ZLibLevel: Integer;
  M: TMemoryStream;
begin
  if not (State in dsEditModes) then
    Edit;
  I := (Stream as TBlobStream).FFieldIndex;
  Temp := FArray.RecNo;
  FArray.RecNo := TBlobStream(Stream).FRecNo;
  TBlobStream(Stream).Position := 0;
  try
    F := FArray.GetFieldType(I);
    T := FArray.GetDataType(I);
{$IFDEF COMPILER10_UP}
    if (T = ftString) and (FMemoDataType = ftWideMemo) then
    begin
      F := ftWideMemo;
      FMemoDataType := ftUnknown;
    end;
{$ENDIF}
    case F of
      ftMemo, ftFmtMemo, ftOraClob: begin
        SetLength(S, Stream.Size);
        Stream.Position := 0;
        Stream.Read(S[InitStrPos], Length(S));
        FArray.Data[I] := S;
        if State = dsEdit then
          FModified := True;
      end;
{$IFDEF COMPILER10_UP}
      ftWideMemo: begin
        SetLength(W, Stream.Size div Sizeof(WideChar));
        Stream.Position := 0;
        Stream.Read(W[InitStrPos], Length(W) * Sizeof(WideChar));
        // InterBase helper when F1.BlobType equal ftMemo.
        if T = ftString then
         {$IFNDEF FPC}
         {$IF Defined(HAS_FMX)}
          FArray.Data[I] := String(W)
         {$ELSE}
          FArray.Data[I] := AnsiString(W)
         {$IFEND}
         {$ELSE}
          FArray.Data[I] := AnsiString(W)
         {$ENDIF}
        else
          FArray.Data[I] := W;
        if State = dsEdit then
          FModified := True;
      end;
{$ENDIF}
    else
      if T = ftBytes then
      begin
        ZLibLevel := 0;
        M := nil;
        if ZLibLevel <> 0 then
        begin
          Sz := Stream.Size;
          if Sz = 0 then
          begin
            FArray.Data[I] := NULL;
            Exit;
          end;
          M := TMemoryStream.Create;
          M.WriteBuffer(_BLOBW, Sizeof(_BLOBW));
          M.WriteBuffer(Sz, Sizeof(Sz));
          Stream.Position := 0;
          ZCompressStream(Stream, M);
          Stream := M;
        end;
        SetLength(B, Stream.Size);
        Stream.Position := 0;
        Stream.Read(B[0], Length(B));
        M.Free;
        DynArrayToBinVariant(V, B, Length(B));
        FArray.Data[I] := V;
        if State = dsEdit then
          FModified := True;
        B := nil;
      end;
    end;
  finally
    FArray.RecNo := Temp;
  end;
end;


{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Procedure TRESTDWCustomDataSet.SetBookmarkData(Buffer  : TRecBuf;
                                           Data    : TBookmark);
{$ELSE}
Procedure TRESTDWCustomDataSet.SetBookmarkData(Buffer  : TRecordBuffer;
                                           Data    : Pointer);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.SetBookmarkData(Buffer  : TRecordBuffer;
                                           Data    : Pointer);
{$ENDIF}
begin
 {$IFNDEF FPC}
 {$IF Defined(HAS_FMX)}
  PVarRecInfo(Buffer).Bookmark := Integer(Data);
 {$ELSE}
  PVarRecInfo(Buffer).Bookmark := Integer(Data^);
 {$IFEND}
 {$ELSE}
  PVarRecInfo(Buffer).Bookmark := Integer(Data^);
 {$ENDIF}
end;

{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
Procedure TRESTDWCustomDataSet.SetBookmarkFlag(Buffer : TRecBuf;
                                           Value  : TBookmarkFlag);
{$ELSE}
Procedure TRESTDWCustomDataSet.SetBookmarkFlag(Buffer : TRecordBuffer;
                                           Value  : TBookmarkFlag);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.SetBookmarkFlag(Buffer : TRecordBuffer;
                                           Value  : TBookmarkFlag);
{$ENDIF}
begin
  PVarRecInfo(Buffer).BookmarkFlag := Value;
  if Value = bfInserted then
    PVarRecInfo(Buffer).Bookmark := FArray.RecCount;
end;

Procedure TRESTDWCustomDataSet.SetDataByName(const Name: string;
  const Value: Variant);
begin
  FieldByName(Name).Value := Value;
end;


{$IFNDEF FPC}
{$IF CompilerVersion < 25}
Procedure TRESTDWCustomDataSet.SetFieldData(Field   : TField;
                                        Buffer  : Pointer);
{$ELSE}
Procedure TRESTDWCustomDataSet.SetFieldData(Field  : TField;
                                        Buffer : TValueBuffer);
{$IFEND}
{$ELSE}
Procedure TRESTDWCustomDataSet.SetFieldData(Field   : TField;
                                        Buffer  : Pointer);
{$ENDIF}
var
  Size, I, P, Sc, Temp: Integer;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    S, W    : String;
   {$ELSE}
    S, W    : Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    S, W    : String;
   {$ELSE}
    S, W    : AnsiString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  S, W     : AnsiString;
 {$ENDIF}
  T: TTimeStamp;
  vTime : Integer;
  D: TDateTime;
  B: TBcd;
  C: Currency;
Begin
  If Not CanSetData And Not (Field.FieldKind In [fkCalculated, fkLookup]) Then
   Exit;
  If (Field.FieldNo >= 0) Or
     (Field.FieldKind In [fkCalculated, fkLookup]) Then
   Begin
    Temp := FArray.RecNo;
    I := PVarRecInfo(ActiveBuffer).Bookmark;
    FArray.RecNo := I;
    I := FArray.FieldIndex[Field.FieldName];
    If Assigned (Buffer) Then
      Case FArray.FieldType[I] of
        {$IFDEF COMPILER10_UP}
        ftOraInterval,
        {$ENDIF}
        ftString,
        ftFixedChar,
        ftGuid               : Begin
                                {$IFNDEF FPC}
                                 {$IF Defined(HAS_FMX)}
                                 {$IF Defined(HAS_UTF8)}
                                  Size := dwBufferLen(tBytes(pdwAnsiString(Buffer)));
                                  S := Copy(TEncoding.Ansi.GetString(BytesOf(Buffer, Size)), 1, Size); //Copy(UTF8String(Buffer), 1, Size);
                                  FArray.Data[I] := S;
                                 {$ELSE}
                                  Size := dwBufferLen(tBytes(pdwAnsiString(Buffer)));
                                  S := Copy(TEncoding.Ansi.GetString(BytesOf(Buffer, Size)), 1, Size);
                                  FArray.Data[I] := S;
                                 {$IFEND}
                                {$ELSE}
                                 {$IF CompilerVersion < 25}
                                  SetLength(S, Length(PAnsiChar(Buffer)));
                                  Move(Buffer^, S[InitStrPos], Length(S));
                                  FArray.Data[I] := S;
                                 {$ELSE}
                                  Size := dwBufferLen(tBytes(pdwAnsiString(Buffer))) * sizeof(char);
                                  S := Copy(TEncoding.Ansi.GetString(BytesOf(Buffer, Size)), 1, Size);
                                  FArray.Data[I] := S;
                                 {$IFEND}
                                {$IFEND}
                                {$ELSE}
                                 SetLength(S, Length(PAnsiChar(Buffer)));
                                 Move(Buffer^, S[InitStrPos], Length(S));
                                 FArray.Data[I] := S;
                                {$ENDIF}
                               End;
        ftSmallint           : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PSmallint(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PSmallint(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PSmallint(Buffer)^;
                                {$ENDIF}
                               End;
                               {$IFDEF COMPILER12_UP}
        ftLongWord           : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PLongWord(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PLongWord(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PLongWord(Buffer)^;
                                {$ENDIF}
                               End;
        ftByte,
        ftShortint           : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PShortint(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PShortint(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PShortint(Buffer)^;
                                {$ENDIF}
                               End;
        ftExtended           : Begin
                                FArray.Data[I] := PExtended(Buffer)^;
                               End;
                               {$ENDIF}
                               {$IFDEF COMPILER14_UP}
        ftSingle             : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PSingle(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PSingle(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PSingle(Buffer)^;
                                {$ENDIF}
                               End;
        ftTimeStampOffset    : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 D := SQLTimeStampOffsetToDateTime(PSQLTimeStampOffset(Buffer)^);
                                {$ELSE}
                                 D := SQLTimeStampOffsetToDateTime(PSQLTimeStampOffset(Buffer)^);
                                {$IFEND}
                                {$ELSE}
                                 D := SQLTimeStampOffsetToDateTime(PSQLTimeStampOffset(Buffer)^);
                                {$ENDIF}
                                // LocalToUTC has a number of the hour a day greater
                                // several thousand. Sensibly +
                                if WindowsStopsAt1601 > YearOf(D) then
                                  raise EConvertError.CreateRes(PResStringRec(@STimeEncodeError));
                                FArray.Data[I] := D;
                               End;
                               {$ENDIF}
        ftInteger, ftAutoInc,
        ftDate, ftTime       : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PInteger(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PInteger(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PInteger(Buffer)^;
                                {$ENDIF}
                               End;
        ftWord               : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PWord(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PWord(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PWord(Buffer)^;
                                {$ENDIF}
                               End;
        ftBoolean            : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PBoolean(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PBoolean(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PBoolean(Buffer)^;
                                {$ENDIF}
                               End;
        ftFloat, ftCurrency,
        ftBCD, ftFMTBcd      : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PDouble(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PDouble(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PDouble(Buffer)^;
                                {$ENDIF}
                               End;
//        ftBCD                 : Begin
//                                {$IFNDEF FPC}
//                                {$IF Defined(HAS_FMX)}
//                                 BCDToCurr(PBCD(Buffer)^, C);
//                                {$ELSE}
//                                 BCDToCurr(PBCD(Buffer)^, C);
//                                {$IFEND}
//                                {$ELSE}
//                                 BCDToCurr(PBCD(Buffer)^, C);
//                                {$ENDIF}
//                                //FArray.Data[I] := C;
//                                FArray.Data[I] := C;
//                               End;
//        ftFMTBcd             : Begin
//                                P := TFMTBCDField(Field).Precision;
//                                if P = 0 then P := MaxFMTBcdDigits;
//                                Sc := Field.Size;
//                                if Sc = 0 then Sc := DefaultFMTBcdScale;
//                                {$IFNDEF FPC}
//                                {$IF Defined(HAS_FMX)}
//                                If Not NormalizeBcd(PBCD(Buffer)^, B, P, Sc) then
//                                 B := PBCD(Buffer)^;
//                                {$ELSE}
//                                If Not NormalizeBcd(PBCD(Buffer)^, B, P, Sc) then
//                                 B := PBCD(Buffer)^;
//                                {$IFEND}
//                                {$ELSE}
//                                If Not NormalizeBcd(PBCD(Buffer)^, B, P, Sc) then
//                                 B := PBCD(Buffer)^;
//                                {$ENDIF}
//                                FArray.Data[I] := VarFMTBcdCreate(B);
//                               End;
        ftDateTime           : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 D := SQLTimeStampToDateTime(PSQLTimeStamp(Buffer)^);
                                {$ELSE}
                                 D := SQLTimeStampToDateTime(PSQLTimeStamp(Buffer)^);
                                {$IFEND}
                                {$ELSE}
                                 DataConvert(Field, Buffer, @D, False);
                                {$ENDIF}
                                FArray.Data[I] := D;
                               End;
        ftLargeint           : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PInt64(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PInt64(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PInt64(Buffer)^;
                                {$ENDIF}
                               End;
        ftVariant            : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PVariant(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PVariant(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PVariant(Buffer)^;
                                {$ENDIF}
                               End;
        ftInterface: ;
        ftIDispatch: ;
//        ftGuid            : Begin
//                                {$IFNDEF FPC}
//                                {$IF Defined(HAS_FMX)}
//                                 SetLength(S, Length(PChar(Buffer)));
//                                 Move(Buffer, S[InitStrPos], Length(S));
//                                {$ELSE}
//                                 SetLength(S, Length(PAnsiChar(Buffer)));
//                                 Move(Buffer, S[InitStrPos], Length(S));
//                                {$IFEND}
//                                {$ELSE}
//                                 SetLength(S, Length(PAnsiChar(Buffer)));
//                                 Move(Buffer, S[InitStrPos], Length(S));
//                                {$ENDIF}
//                                Try
//                                 If S <> '' Then
//                                  StringToGUID(string(S));
//                                Except
//                                 S := '||';
//                                End;
//                                If S <> '||' then
//                                 FArray.Data[I] := S;
//                               End;
        {$IFDEF COMPILER10_UP}
        ftOraTimeStamp,
        {$ENDIF}
        ftTimeStamp          : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 D := SQLTimeStampToDateTime(PSQLTimeStamp(Buffer)^);
                                {$ELSE}
                                 D := SQLTimeStampToDateTime(PSQLTimeStamp(Buffer)^);
                                {$IFEND}
                                {$ELSE}
                                 D := SQLTimeStampToDateTime(PSQLTimeStamp(Buffer)^);
                                {$ENDIF}
                                FArray.Data[I] := D;
                               End;
        {$IFDEF COMPILER10_UP}
        ftFixedWideChar,
        {$ENDIF}
        ftWideString             : Begin
                                {$IFNDEF FPC}
                                 {$IF Defined(HAS_FMX)}
                                 {$IF Defined(HAS_UTF8)}
                                  Size := Length(PWideChar(Buffer))* SizeOf(Char);;
                                  S := StringReplace(Copy(TEncoding.Ansi.GetString(BytesOf(Buffer, Size)), 1, Size), #0, '', [rfREplaceAll]);
                                  FArray.Data[I] := S;
                                 {$ELSE}
                                  Size := Length(PWideChar(Buffer))* SizeOf(Char);;
                                  S := StringReplace(Copy(TEncoding.Ansi.GetString(BytesOf(Buffer, Size)), 1, Size), #0, '', [rfREplaceAll]);
                                  FArray.Data[I] := S + #0
                                 {$IFEND}
                                {$ELSE}
                                 {$IF CompilerVersion < 25}
                                  Size := Length(PWideChar(Buffer))* SizeOf(Char);;
                                  //Correção para XE2
                                  S := StringReplace(Copy(PWideChar(Buffer), 1, Size), #0, '', [rfREplaceAll]); //utf8decode(StringReplace(Copy(PWideChar(Buffer), 1, Size), #0, '', [rfREplaceAll]));
                                  FArray.Data[I] := S + #0
                                 {$ELSE}
                                  Size := Length(PWideChar(Buffer))* SizeOf(Char);
                                  S := StringReplace(Copy(TEncoding.Ansi.GetString(BytesOf(Buffer, Size)), 1, Size), #0, '', [rfREplaceAll]);
                                  FArray.Data[I] := S + #0;
                                 {$IFEND}
                                {$IFEND}
                                {$ELSE}
                                 SetLength(S, Length(PWideChar(Buffer)));
                                 Move(Buffer^, S[InitStrPos], Length(S));
                                 FArray.Data[I] := S;
                                {$ENDIF}
                               End;
      Else
       Case FArray.GetFieldDef(I) Of
        {$IFNDEF COMPILER11_UP}
          dwftExtended        : FArray.Data[I] := PExtended(Buffer)^;//_RealSupportManager._VarFromReal(PExtended(Buffer)^);
          dwftTimeStampOffset : Begin
                                 D := SQLTimeStampToDateTime(PSQLTimeStampOffset(Buffer)^);
                                 FArray.Data[I] := D;
                                End;
        {$ENDIF}
         dwftColor           : Begin
                                {$IFNDEF FPC}
                                {$IF Defined(HAS_FMX)}
                                 FArray.Data[I] := PInteger(Buffer)^;
                                {$ELSE}
                                 FArray.Data[I] := PInteger(Buffer)^;
                                {$IFEND}
                                {$ELSE}
                                 FArray.Data[I] := PInteger(Buffer)^;
                                {$ENDIF}
                               End;
       End;
      End
    Else
     If Field.Required and (GetControlInterface = nil) then
      Begin
       FArray.RecNo := Temp;
        // Very bad error in TRESTDWMemtable.SetField data
       Raise DwTableError.CreateFmt ('Field %s is Required', [Field.FieldName]);
      End
     Else
      FArray.Data[I] := NULL;
    FArray.RecNo := Temp;
    If Field.FieldKind in [fkData, fkLookup] then
     Begin
      if Field.FieldKind = fkData then
        FModified := True;
      {$IFDEF FPC}
       DataEvent(deFieldChange, NativeInt(Field));
      {$ELSE}
       DataEvent(deFieldChange, Longint(Field));
      {$ENDIF}
     End;
   End;
End;

Procedure TRESTDWCustomDataSet.SetFiltered(Value: Boolean);
begin
  inherited SetFiltered(Value);
  if Assigned(OnFiltered) then
    OnFiltered(Self);
end;

Procedure TRESTDWCustomDataSet.SetKeyField(const Value: string);
begin
  CheckInactive;
  FKeyField := Value;
end;

Procedure TRESTDWCustomDataSet.SetNewDefaults(const Value: TStrings);
begin
  FNewDefaults.Assign(Value);
end;

Procedure TRESTDWCustomDataSet.RaiseError(Fmt: String; Args: array of const);
Begin
 Raise DwDatabaseError.CreateFmt(Fmt, Args);
End;

Procedure TRESTDWCustomDataSet.LoadDataFromStream(F : TStream);
Var
 Size      : Integer;
 OwnerData : OleVariant;
 P         : Pointer;
Begin
 CheckMarker(F, smData);
 Size := ReadInteger(F);
 OwnerData := VarArrayCreate([1, Size], varByte);
 P         := VarArrayLock(OwnerData);
 F.ReadBuffer(P^, Size);
 FArray.FData := TArrayData(P);
 VarArrayUnLock(OwnerData);
// F.ReadBuffer(FArray.FData, Size);
// FArray.SetRecordCount(Size div FArray.FieldCount);
// FArray.RecNo    := -1;
end;

Procedure TRESTDWCustomDataSet.SetEncoding(bValue : TEncodeSelect);
Begin
 vEncoding := bValue;
End;

Procedure TRESTDWCustomDataSet.WriteMarker(F: TStream; Marker: Integer);
Begin
 Writeinteger(F, Marker);
End;

procedure TRESTDWCustomDataSet.CheckMarker(F: TStream; Marker: Integer);
Var
 I, P : Integer;
Begin
 P := F.Position;
 I := 0;
 Try
  F.ReadBuffer(I, MarkerSize);
 Except
  If (I <> Marker) Then RaiseError(SErrInvalidMarkerAtPos, [P, I, Marker]);
 End;
End;

Procedure TRESTDWCustomDataSet.ReadFieldDefsFromStream(F : TStream);
Var
 FS,
 I, ACount : Integer;
 FN        : String;
 B         : Boolean;
 FT        : TFieldType;
 DataAttributes : TDataAttributes;
 FieldDef  : TFieldDef;
Begin
 CheckMarker(F, smFieldDefs);
 FieldDefs.Clear;
 FieldDefs.BeginUpdate;
 Try
  ACount := ReadInteger(F);
  For I := 1 to ACount do
   Begin
    FN := ReadString(F);
    If vEncoding = esUtf8 Then
     Begin
     {$IFDEF FPC}
      FN   := PWidechar(UTF8Encode(FN));
     {$ELSE}
      FN   := UTF8Encode(FN);
     {$ENDIF}
     End;
    FS := ReadInteger(F);
    FT := TFieldType(ReadInteger(F));
    B  := ReadInteger(F)<>0;
    FieldDef := TFieldDef.Create(FieldDefs, FN, ft, FS, B, I);
    DataAttributes := [];
    If FieldDef.Required Then
     DataAttributes := DataAttributes + [dwNotNull];
    FArray.AppendField(Integer(FieldDef.DataType), FieldDef.Size, FieldDef.Precision, DataAttributes, FieldDef.Name, 'Init');
   End;
 Finally
  FieldDefs.Endupdate;
 End;
End;

Procedure TRESTDWCustomDataSet.SaveFieldDefsToStream   (F : TStream);
Var
 I  : Integer;
 FD : TFieldDef;
Begin
 WriteMarker (F, smFieldDefs);
 WriteInteger(F, FieldDefs.Count);
 For I := 1 to FieldDefs.Count do
  Begin
   FD         := FieldDefs[I-1];
   WriteString (F, FD.Name);
   WriteInteger(F, FD.Size);
   WriteInteger(F, Ord(FD.DataType));
   WriteInteger(F, Ord(FD.Required));
  End;
End;

Procedure TRESTDWCustomDataSet.SetRecNo(Value: Integer);
begin
  CheckBrowseMode;
  if (Value >= 1) and (Value <= FArray.RecCount) then
  begin
    FArray.RecNo := Value - 1;
    Resync([]);
    UpdateCursorPos;
  end;
end;

Procedure TRESTDWCustomDataSet.SetRecordCount(AValue: Integer);
var
  I: Integer;
  List: TIndexList;
begin
  CheckActive;
  FArray.SetRecordCount(AValue);
  FModified := True;
  Resync([]);
end;

Procedure TRESTDWCustomDataSet.SetRestrictLength(const AValue: TRestrictLength);
begin
  FArray.FRestrictLength := AValue;
end;

Procedure TRESTDWCustomDataSet.SetTableDefs(const AValue: TStrings);
begin
  FTableDefs.Assign(AValue);
end;

Procedure TRESTDWCustomDataSet.SortLocal(const Name: string;
  const Descs: array of Boolean; CaseInsensitive: Boolean);
var
  Intf: IInterface;
begin
  FArray.Sort(Name, Descs, CaseInsensitive);
  Resync([]);
end;

Procedure TRESTDWCustomDataSet.TableDefsChange(Sender: TObject);
begin
  if not (dwsOpening in FState) and
    not (csLoading in ComponentState) then
  begin
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
    FArray.Init(String(TableDefs.Text));
    {$ELSE}
    FArray.Init(AnsiString(TableDefs.Text));
    {$IFEND}
   {$ELSE}
    FArray.Init(AnsiString(TableDefs.Text));
   {$ENDIF}
    FArray.FTable := Self;
    if (dwsConvertError in FState) and (State = dsOpening) then
      SetState(dsInactive);
  end;
end;

{$IFDEF FPC}
Procedure TRESTDWCustomDataSet.SetDatabaseCharSet(Value : TDatabaseCharSet);
Begin
 vDatabaseCharSet       := Value;
 FArray.DatabaseCharSet := vDatabaseCharSet;
End;
{$ENDIF}

Procedure TRESTDWCustomDataSet.Done;
Begin
 FArray.Done;
End;

Procedure TRESTDWCustomDataSet.TableDefsChanging(Sender: TObject);
begin
  if not (csLoading in ComponentState) then
    CheckInactive;
end;

Procedure TRESTDWMemtable.Assign(Source: TVariantArray);
begin
  if not (dwsOpen in FState) and (TableDefs.Text = '') then
    TableDefs.Text := string(Source.GetDefinitions);
  FArray.Assign(Source);
  if dwsOpen in FState then
  begin
    FModified := True;
    Resync([]);
  end;
end;

class Procedure TRESTDWMemtable.Cast(Source, DataSet: TDataset; ACount: Integer);
var
  v: TVariantArray;
begin
 If not (Source is TRESTDWMemtable) then
  Begin
   {$IFDEF SUPPORTS_ENHANCED_RECORDS}
   {$ELSE}
   {$ENDIF}
   {$IFNDEF FPC}
   {$IFDEF SUPPORTS_ENHANCED_RECORDS}
   v := Source;
   v.Save(DataSet, ACount);
   {$ELSE}
   v := TVariantArray.Implicit(Source);
   v.Save(DataSet, ACount);
   v.Free;
   {$ENDIF}
   {$ELSE}
   v := TVariantArray.Implicit(Source);
   v.Save(DataSet, ACount);
   v.Free;
   {$ENDIF}
  End
 Else
  TRESTDWMemtable(Source).FArray.Save(DataSet, ACount);
end;

Procedure TRESTDWMemtable.CopyFrom(DataSet: TDataSet; ACount: Integer);
var
  Temp: Integer;
begin
  Temp := DataSet.RecNo;
  if ACount < 0 then
  begin
    DataSet.Last;
    DataSet.First;
    ACount := DataSet.RecordCount;
  end;
//  Close;
//  FArray.Clear;
  SetLength(FArray.FData, FArray.FieldCount * ACount);
  FArray.FCursor := 0;
  if ACount = 0 then
  begin
    Open;
    Resync([]);
    Exit;
  end;
  try
    Open;
    while not DataSet.Eof do
    begin
      CopyRecordFrom(DataSet);
      DataSet.Next;
      RecNo := RecNo + 1;
    end;
  except on E: Exception do
    begin
      FArray.Clear;
      Assert(False, E.Message);
    end;
  end;
  DataSet.RecNo := Temp;
  RecNo := Temp;
  Resync([]);
end;

Procedure TRESTDWMemtable.CopyRecordFrom(DataSet: TDataSet);
var
  I: Integer;
  F1, F2: TField;
begin
  for I := 0 to DataSet.FieldCount - 1 do
  begin
    F1 := DataSet.Fields[I];
    F2 := FindField(F1.FieldName);
{$IFDEF COMPILER10_UP}
    if F1 is TWideMemoField then
      FMemoDataType := ftWideMemo else
{$ENDIF}
      FMemoDataType := F1.DataType;
    if Assigned(F2) and (F2.FieldKind = fkData) then
      F2.Assign(F1);
  end;
end;

constructor TRESTDWMemtable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNameList := TStringList.Create;
end;

Procedure TRESTDWMemtable.InitArrayFields;//Create all Fields to listactions
var
  I : Integer;
  DataAttributes : TDataAttributes;
 Function FieldExists(FieldNameD : String) : Boolean;
 Var
  I : Integer;
 Begin
  Result := False;
  For I := 0 To FArray.FieldCount -1 Do
   Begin
    Result := Uppercase(FArray.FieldName[I]) = Uppercase(FieldNameD);
    If Result Then
     Break;
   End;
 End;
Begin
 If FArray.FieldCount = 0 Then //Criando campos a partir dos fielddefs
  Begin
   {$IFNDEF FPC}
   For I := 0 to FieldDefList.Count - 1 do
   {$ELSE}
   For I := 0 to FieldDefs.Count - 1 do
   {$ENDIF}
    Begin
     DataAttributes := [];
     If FieldDefs[I].Required Then
      DataAttributes := DataAttributes + [dwNotNull];
     FArray.AppendField(Integer(FieldDefs[I].DataType), FieldDefs[I].Size, FieldDefs[I].Precision, DataAttributes, FieldDefs[I].Name, 'Init');
    End;
  End;
 For I := 0 to Fields.Count -1 Do //Criando campos diferentes de campos tipo data
  Begin
   If Fields[I].FieldKind in [fkCalculated,   fkLookup,
                              fkInternalCalc{$IFNDEF FPC}, fkAggregate{$ENDIF}] Then
    Begin
     If FArray.FieldIndex[Fields[I].FieldName] = -1 Then
      Begin
       DataAttributes := [];
       If Fields[I].FieldKind      = fkCalculated   Then
        DataAttributes := DataAttributes + [dwCalcField]
       Else If Fields[I].FieldKind = fkLookup       Then
        DataAttributes := DataAttributes + [dwLookup]
       Else If Fields[I].FieldKind = fkInternalCalc Then
        DataAttributes := DataAttributes + [dwInternalCalc]
       {$IFNDEF FPC}
       Else If Fields[I].FieldKind = fkAggregate    Then
        DataAttributes := DataAttributes + [dwAggregate]
       {$ENDIF};
       FArray.AppendField(Integer(Fields[I].DataType), Fields[I].Size, LazDigitsSize, DataAttributes, Fields[I].FieldName, 'Init');
      End;
    End
   Else
    Begin
     If Not FieldExists(Fields[I].FieldName) Then
      FArray.AppendField(Integer(Fields[I].DataType), Fields[I].Size, LazDigitsSize, DataAttributes, Fields[I].FieldName, 'Init');
    End;
  End;
End;

Procedure TRESTDWMemtable.CreateFields;
Var
 I : Integer;
 {$IFDEF FPC}
 vField : TField;
 {$ENDIF}
begin
 {$IFNDEF FPC}
  if ObjectView then
    raise Exception.Create('Error create objects')
  else
   Begin
   {$ENDIF}
    If Fields.Count = 0 Then
   {$IFNDEF FPC}
    For I := 0 to FieldDefList.Count - 1 Do
   {$ELSE}
    For I := 0 to FieldDefs.Count - 1 Do
   {$ENDIF}
    begin
      {$IFNDEF FPC}
      With FieldDefList[I] do
      {$ELSE}
      With FieldDefs[I] do
      {$ENDIF}
        if {$IFNDEF FPC}not (DataType in ObjectFieldTypes) and{$ENDIF}
          not ((faHiddenCol in Attributes) and not FIeldDefs.HiddenFields) then
        begin
          If FArray.FieldCount > 0 Then
           Begin
            case FArray.GetFieldDef(I) of
              {$IFNDEF COMPILER11_UP}
              dwftExtended: FFieldDefClass := TExtendedField;
              dwftStream: FFieldDefClass := TStreamField;
              {$IFNDEF FPC}
              dwftTimeStampOffset: FFieldDefClass := TSQLTimeStampOffsetField;
              {$ENDIF}
              {$ENDIF}
              dwftColor: FFieldDefClass := TColorField;
            end;
           End;
          {$IFNDEF FPC}
          If FindField(FieldDefList[I].Name) = Nil Then
           CreateField(Self, nil, FieldDefList.Strings[I]);
          {$ELSE}
           If FindField(FieldDefs[I].Name) = Nil Then
            Begin
             vField := CreateField(Self);
             vField.FieldName := FieldDefs[I].Name;
             If vField.DataType = ftFloat Then
              Begin
               If TFloatField(vField).Size > LazDigitsSize Then
                TFloatField(vField).Size       := LazDigitsSize;
               If (TFloatField(vField).Precision > MaxFloatLaz) Or
                  (TFloatField(vField).Precision = 0)           Then
                TFloatField(vField).Precision  := MaxFloatLaz;
              End;
            End;
          {$ENDIF}
          FFieldDefClass := nil;
        end;
    end;
   {$IFNDEF FPC}
   End;
   {$ENDIF}
end;

Procedure TRESTDWMemtable.CreateTable;
begin
  CheckInactive;
end;

Procedure TRESTDWMemtable.DataEvent(Event: TDataEvent; Info: NativeInt);
Begin
 Case Event Of
  deConnectChange : If Active {$IFDEF FPC}And Not Boolean(Info)
                              {$ELSE}And Not Boolean(Info){$ENDIF} Then
                     Close;
 End;
 Inherited;
End;

Procedure TRESTDWMemtable.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
end;

Procedure TRESTDWMemtable.DesignNotify(const AFieldName: string; Dummy: Integer);
var
  Stream: TStream;
  VArray: TVariantArray;
begin
  if not (csDesigning in ComponentState) then Exit;
  case Dummy of
    100: begin
         end;
   else
     inherited DesignNotify(AFieldName, Dummy);
  end;
end;

Destructor TRESTDWMemtable.Destroy;
Begin
  // destroy field object (if not persistent)
 {$IFDEF HAS_AUTOMATIC_DB_FIELDS}
 If Not (lcPersistent in Fields.LifeCycles) Then
 {$ELSE}
 If DefaultFields Then
 {$ENDIF}
  DestroyFields;
 If FNameList <> Nil Then
  FreeAndNil(FNameList);
 Inherited;
End;

Procedure TRESTDWMemtable.DoAfterDelete;
begin
  inherited DoAfterDelete;
end;

Procedure TRESTDWMemtable.DoAfterOpen;
begin
  inherited DoAfterOpen;
end;

Procedure TRESTDWMemtable.DoAfterPost;
begin
  inherited DoAfterPost;
  if (KeyField <> '') and not VarIsClear(FKeyValue) then
  begin
    UpdateCursorPos;
  end;
end;

Procedure TRESTDWMemtable.DoBeforeDelete;
begin
  inherited DoBeforeDelete;
end;

Procedure TRESTDWMemtable.DoBeforeOpen;
begin
  InitArrayFields; //Initialize Array Fields
  inherited DoBeforeOpen;
end;

Procedure TRESTDWMemtable.DoBeforePost;
begin
  inherited DoBeforePost;
end;

Procedure TRESTDWMemtable.DoOnNewRecord;
var
  I: Integer;
  List: TIndexList;
begin
  CheckDefaults;
  inherited DoOnNewRecord;
  for I := 0 to FArray.IndexCount - 1 do
  begin
    List := FArray.Indexes[I];
    List.Insert(FArray.RecNo);
  end;
end;

Function TRESTDWMemtable.GetControlInterface: IInterface;
begin
 Result := nil;
end;

Function TRESTDWMemtable.GetDataByName(const Name: string): Variant;
begin
  Result := FArray[Name];
end;

Procedure TRESTDWMemtable.InsertRecordInto(DataSet: TDataSet);
var
  I: Integer;
  F1, F2: TField;
begin
  DataSet.Append;
  for I := 0 to DataSet.FieldCount - 1 do
  begin
    F1 := DataSet.Fields[I];
    F2 := FindField(F1.FieldName);
    if Assigned(F2) and (F1.FieldKind = fkData) then
      F1.Assign(F2);
  end;
  DataSet.Post;
end;

{$IFNDEF FPC}
 {$IF NOT Defined(HAS_FMX)}
  Procedure TRESTDWMemtable.InternalAddRecord(Buffer : Pointer;
                              Append : Boolean);
 {$ELSE}
  Procedure TRESTDWMemtable.InternalAddRecord(Buffer : TRecBuf;
                              Append : Boolean);
 {$IFEND}
{$ELSE}
 Procedure TRESTDWMemtable.InternalAddRecord(Buffer : Pointer;
                                         Append : Boolean);
{$ENDIF}
begin
  // don't used from Grid
  raise DwTableError.Create (SNotSupported);
end;

Procedure TRESTDWMemtable.InternalCancel;
var
  I: Integer;
begin
 If State = dsInsert then
  Begin
   FArray.FIsCancelDelete := True;
   FArray.Delete;
   Exit;
  End;
{
  if State = dsEdit then
  begin
    for I := 0 to FArray.FieldCount - 1 do
      FArray.Data[I] := FOldArray.FData[I];
  end;
}
end;

Procedure TRESTDWMemtable.InternalClose;
var
  Intf: IInterface;
begin
  // disconnet field objects
  BindFields(False);
  // destroy field object (if not persistent)
  {$IFDEF HAS_AUTOMATIC_DB_FIELDS}
  If Not (lcPersistent in Fields.LifeCycles) Then
  {$ELSE}
  If DefaultFields Then
  {$ENDIF}
   Begin
    DestroyFields;
    Done;
   End
  Else
   Done;
  // close the file
  Exclude(FState, dwsOpen);
//  FArray.Clear;
{
  if FModified then
  begin
    if FileExists(TableFileName) then
      DeleteFile(TableFileName);
    CreateTable;
  end;
}
end;

Procedure TRESTDWMemtable.InternalDelete;
var
  I: Integer;
begin
  if KeyField <> '' then
    I := FArray.FieldIndex[KeyField] else
    I := -1;
  if I >= 0 then
    FKeyValue := FArray.Data[I] else
    VarClear(FKeyValue);
  FArray.Delete;
  FModified := True;
end;

Procedure TRESTDWMemtable.InternalEdit;
begin
  FKeyValue := FArray.GetDataResult(FArray.RecNo, KeyField);
  if VarIsNull(FKeyValue) then
    VarClear(FKeyValue);
end;

Procedure TRESTDWMemtable.InternalHandleException;
begin
  // special purpose exception handling
  // do nothing
end;

Procedure TRESTDWMemtable.InternalInitFieldDefs;
begin
  if (csDesigning in ComponentState)
    {$IFNDEF FPC}and Assigned(Designer){$ENDIF}
    and not (dwsOpen in FState) then
      TRESTDWMemtable(Self).DesignNotify('', 102);
  inherited InternalInitFieldDefs;
end;

Procedure TRESTDWMemtable.InternalInsert;
begin
 If Not FOnOperation Then
  Begin
   If (PVarRecInfo(ActiveBuffer).BookmarkFlag = bfEOF) then
    Begin
     // Buffer is not used for additional caching.
     // While need in bookmark did not exist.
     If FArray.RecCount > 1 Then
      Begin
       UpdateCursorPos;
       FArray.Append;
       FOnOperation := False;
      End
     Else
     {$IFNDEF FPC}
      FArray.Append;
     {$ELSE}
      FArray.Insert;
     {$ENDIF}
    End
   Else
    Begin
     {$IFNDEF FPC}
      FArray.Insert;
     {$ELSE}
      FArray.Append;
     {$ENDIF}
     FOnOperation := False;
    End;
   Resync([]);
  End;
end;

Procedure TRESTDWMemtable.InternalOpen;
var
  M: Boolean;
begin
  if dwsOpen in FState then
    Exit;

  M := (FArray.FieldCount <> 0) and (FArray.RecCount <> 0);

  Include(FState, dwsOpening);
  try
    Exclude(FState, dwsConvertError);
    if not M then
      InternalRevert;
    if dwsConvertError in FState then
    begin
      SetState(dsOpening);
      Exit;
    end;
    InternalInitFieldDefs;
    BindFields (False);
    {$IFDEF HAS_AUTOMATIC_DB_FIELDS}
    If not (lcPersistent in Fields.LifeCycles) Then
    {$ELSE}
    If DefaultFields then
    {$ENDIF}
    CreateFields;
    // connect the TField objects with the actual fields
    BindFields (True);
    FModified := M or FArray.LoadModified;
    // sets cracks and record position and size
    FIsCurrentFirst := True;
    BookmarkSize := sizeOf (Integer);
  finally
    Exclude(FState, dwsOpening);
  end;
  // everything OK: table is now open
  Include(FState, dwsOpen);
end;

Procedure TRESTDWMemtable.InternalPost;
var
  I: Integer;
  List: TIndexList;
begin
  CheckActive;
  // mark modified
  FModified := True;
  if State = dsInsert then
    VarClear(FKeyValue);
end;

Procedure TRESTDWMemtable.InternalRevert;
var
  n: Integer;
begin
  n := FArray.RecNo;
  Lock;
  try
   FArray.Clear;
   FModified := FArray.LoadModified;
  finally
    FArray.RecNo := n;
    Unlock;
  end;
end;

Procedure TRESTDWMemtable.Loaded;
begin
 If (TableDefs.Count > 0) Then
  Begin
   {$IFNDEF FPC}
   {$IF Defined(HAS_FMX)}
    FArray.Init(String(TableDefs.Text));
   {$ELSE}
    FArray.Init(AnsiString(TableDefs.Text));
   {$IFEND}
   {$ELSE}
    FArray.Init(AnsiString(TableDefs.Text));
   {$ENDIF}
    FArray.FTable := Self;
  End;
 Inherited Loaded;
end;

Procedure TRESTDWMemtable.Lock;
Begin
End;

Procedure TRESTDWMemtable.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

Procedure TRESTDWMemtable.OpenCursor(InfoQuery: Boolean);
begin
  inherited OpenCursor(InfoQuery);
  if not InfoQuery and (FArray.RecCount = 1) then
    Resync([]);
end;

Procedure TRESTDWMemtable.ReadDefaults(Reader: TReader);
begin
  FNewDefaults.Text := Reader.ReadString;
end;

Procedure TRESTDWMemtable.Revert;
begin
  InternalRevert;
  if dwsOpen in FState then
    Resync([]);
end;

Procedure TRESTDWMemtable.Unlock;
Begin
End;

Procedure TRESTDWMemtable.WriteDefaults(Writer: TWriter);
begin
  Writer.WriteString(FNewDefaults.Text);
end;

{$IFDEF REGION}{$ENDREGION}{$ENDIF}

Initialization
 {$IFNDEF SUPPORTS_CLASS_FIELDS}
  vTableStorage := TRESTDWTableStorage.Create;
 {$ENDIF}

Finalization
 {$IFNDEF SUPPORTS_CLASS_FIELDS}
  FreeAndNil(vTableStorage);
 {$ENDIF}
end.
