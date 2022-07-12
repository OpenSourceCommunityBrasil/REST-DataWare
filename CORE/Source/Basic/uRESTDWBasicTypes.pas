unit uRESTDWBasicTypes;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
 uRESTDWConsts, FMTBcd, uRESTDWEncodeClass, uRESTDWCharset,
 {$IFDEF FPC}
  SysUtils,  Classes, Db, uRESTDWAbout
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   System.SysUtils, System.Classes, Data.DB, uRESTDWAbout
  {$ELSE}
   SysUtils, Classes, Db, DbTables, uRESTDWAbout
  {$IFEND}
 {$ENDIF}
 {$IFDEF FPC}
  {$IFDEF RESTDWMEMTABLE}
   , uRESTDWDataset
  {$ENDIF}
  {$IFDEF RESTDWLAZDRIVER}
   , memds
  {$ENDIF}
  {$IFDEF RESTDWUNIDACMEM}
  , DADump, UniDump, VirtualTable, MemDS
  {$ENDIF}
 {$ELSE}
   {$IFDEF RESTDWMEMTABLE}
    , uRESTDWDataset
   {$ENDIF}
   {$IFDEF RESTDWCLIENTDATASET}
    ,  DBClient
   {$ENDIF}
   {$IFDEF RESTDWUNIDACMEM}
   , DADump, UniDump, VirtualTable, MemDS
   {$ENDIF}
   {$IFDEF RESTKBMMEMTABLE}
    , kbmmemtable
   {$ENDIF}
   {$IF CompilerVersion > 22} // Delphi 2010 pra cima
    {$IFDEF RESTDWFDMEMTABLE}
     , FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
     FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
     FireDAC.Comp.DataSet, FireDAC.Comp.Client
     {$IFNDEF FPC}
      {$IF CompilerVersion > 26} // Delphi XE6 pra cima
       , FireDAC.Stan.StorageBin
      {$IFEND}
     {$ENDIF}
    {$ENDIF}
    {$IFDEF RESTDWADMEMTABLE}
     , uADStanIntf, uADStanOption, uADStanParam,
     uADStanError, uADPhysIntf, uADDAptIntf,
     uADCompDataSet, uADCompClient
     {$IFNDEF FPC}
      {$IF CompilerVersion > 26} // Delphi XE6 pra cima
       , uADStanStorageBin
      {$IFEND}
     {$ENDIF}
    {$ENDIF}
   {$IFEND}
 {$ENDIF};

 Const
  dwftColor       = Integer(255);
  RESTDWHexPrefix = '0x';
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
  {$IFDEF REGION}{$ENDREGION}{$ENDIF}
 {$IFDEF COMPILER10_UP}
  FieldTypeIdents : Array[dwftColor..dwftColor] Of TIdentMapEntry = ((Value: dwftColor; Name: 'ftColor'));
 {$ELSE}
  FieldTypeIdents : Array[0..7]                 Of TIdentMapEntry = ((Value: dwftTimeStampOffset; Name: 'ftTimeStampOffset'),
                                                                     (Value: dwftStream;          Name: 'ftStream'),
                                                                     (Value: dwftSingle;          Name: 'ftSingle'),
                                                                     (Value: dwftExtended;        Name: 'ftExtended'),
                                                                     (Value: dwftByte;            Name: 'ftByte'),
                                                                     (Value: dwftShortint;        Name: 'ftShortint'),
                                                                     (Value: dwftLongWord;        Name: 'ftLongWord'),
                                                                     (Value: dwftColor;           Name: 'ftColor'));
 {$ENDIF}

 Type
 {$IFDEF FPC}
  DWInteger       = Longint;
  DWInt16         = Integer;
  DWInt64         = Int64;
  DWInt32         = Int32;
  DWFloat         = Real;
  DWFieldTypeSize = Longint;
  DWBufferSize    = Longint;
  DWUInt16        = Word;
  DWUInt32        = LongWord;
  DWWideChar      = Char;
 {$ELSE}
  DWInteger       = Integer;
  DWInt16         = Integer;
  DWInt64         = Int64;
  DWInt32         = Longint;
  DWFloat         = Real;
  DWFieldTypeSize = Integer;
  DWBufferSize    = Longint;
  DWUInt16        = Word;
  DWUInt32        = LongWord;
  DWWideChar      = WideChar;
 {$ENDIF}
 DWInt8           = Integer;
 DWUInt8          = DWInt8;
 PDWInt32         = ^DWInt32;
 PDWInt64         = ^DWInt64;
 PDWUInt32        = ^DWInt32;
 PDWUInt16        = ^DWUInt16;
 PDWInt16         = ^DWUInt16;
 TRESTDWWideChars = Array Of DWWideChar;
 {$IFDEF HAS_UInt64}
  {$DEFINE UInt64_IS_NATIVE}
  {$IFNDEF BROKEN_UINT64_HPPEMIT}
  Type
   TRESTDWUInt64 = UInt64;
  {$ENDIF}
 {$ELSE}
  {$IFDEF HAS_QWord}
   {$DEFINE UInt64_IS_NATIVE}
   Type
    UInt64 = QWord;
    {$NODEFINE UInt64}
    TRESTDWUInt64 = QWord;
    {$ELSE}
    Type
     UInt64 = Int64;
     TRESTDWUInt64 = UInt64;
    {$NODEFINE UInt64}
   {$ENDIF}
 {$ENDIF}
 TRESTDWIPv6Address = Array [0..7] Of DWUInt16;
 {$IFDEF STRING_IS_UNICODE}
  PDWWideChar = PChar;
 {$ELSE}
  PDWWideChar = PWideChar;
 {$ENDIF}
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    DWString     = String;
    DWWideString = String;
   {$ELSE}
    DWString     = Utf8String;
    DWWideString = Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    DWString     = Utf8String;
    DWWideString = Utf8String;
   {$ELSE}
    DWString     = AnsiString;
    DWWideString = WideString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  DWString     = AnsiString;
  DWWideString = WideString;
 {$ENDIF}
 PArrayData    = ^TArrayData;
 TArrayData    = Array of Variant;
 Type
  TWorkMode = (wmRead, wmWrite);
  TWorkInfo = Record
   Current,
   Max     : Int64;
   Level   : Integer;
 End;

 {$IFDEF STREAM_SIZE_64}
  TRESTDWStreamSize = Int64;
 {$ELSE}
  TRESTDWStreamSize = DWInt32;
 {$ENDIF}

 Type
  TFieldDefinition = Class
  Public
   FieldName : String;
   DataType  : TFieldType;
   Size,
   Precision : Integer;
   Required  : Boolean;
 End;

 Type
  TResultErro = Record
   Status,
   MessageText: String;
 End;

 Type
  TRESTDWParamsHeader = Packed Record
   VersionNumber,
   RecordCount,
   ParamsCount    : DWInteger; //new for ver15
   DataSize       : DWInt64; //new for ver15
 End;

 Type
  TMimeTable = Class(TObject)
  Protected
   FLoadTypesFromOS : Boolean;
   FOnBuildCache    : TNotifyEvent;
   FMIMEList,
   FFileExt         : TStrings;
   Procedure BuildDefaultCache;Virtual;
  Public
   Procedure BuildCache;       Virtual;
   Procedure AddMimeType      (Const Ext, MIMEType : String;
                               Const ARaiseOnError : Boolean = True);
   Function  GetFileMIMEType  (Const AFileName     : String) : String;
   Function  GetDefaultFileExt(Const MIMEType      : String) : String;
   Procedure LoadFromStrings  (Const AStrings      : TStrings;
                               Const MimeSeparator : Char    = '=');
   Procedure SaveToStrings    (Const AStrings      : TStrings;
                               Const MimeSeparator : Char    = '=');
   Constructor Create         (Const AutoFill      : Boolean = True); Reintroduce; Virtual;
   Destructor  Destroy;        Override;
   Property    OnBuildCache    : TNotifyEvent Read FOnBuildCache    Write FOnBuildCache;
   Property    LoadTypesFromOS : Boolean      Read FLoadTypesFromOS Write FLoadTypesFromOS;
 End;

 Type
  TClassNull= Class(TComponent)
 End;

 Type
  TRESTDWHeaderQuotingType    = (QuotePlain, QuoteRFC822, QuoteMIME, QuoteHTTP);
  TRESTDWMessageCoderPartType = (mcptText, mcptAttachment, mcptIgnore, mcptEOF);
  RESTDWArrayError            = Class (Exception);
  RESTDWTableError            = Class (Exception);
  RESTDWDatabaseError         = Class (Exception);
  TFieldsList                 = Array of TFieldDefinition;
  TConnStatus                 = (hsResolving, hsConnecting, hsConnected,
                                 hsDisconnecting, hsDisconnected, hsStatusText);
  TRESTDWClientStage          = (csNone, csLoggedIn, csRejected);
  TDataAttributes             = Set of (dwCalcField,    dwNotNull, dwLookup,
                                        dwInternalCalc, dwAggregate);
  TSendEvent                  = (seGET,       sePOST,
                                 sePUT,       seDELETE,
                                 sePatch);
  TTypeRequest                = (trHttp,      trHttps);
  TDatasetEvents              = Procedure (DataSet : TDataSet) Of Object;
  TRESTDwSessionData          = Class(TCollectionItem);
  TRESTDWDatabaseType         = (dbtUndefined, dbtAccess, dbtDbase, dbtFirebird, dbtInterbase, dbtMySQL,
                                 dbtSQLLite,   dbtOracle, dbtMsSQL, dbtODBC,     dbtParadox,  dbtPostgreSQL,
                                 dbtAdo);
  TWideChars                  = Array of WideChar;
  TRESTDWBytes                = Array of Byte;
  PRESTDWBytes                = ^TRESTDWBytes;
  TOnWriterProcess            = Procedure(DataSet               : TDataSet;
                                          RecNo, RecordCount    : Integer;
                                          Var AbortProcess      : Boolean) Of Object;

 Type
  TProxyConnectionInfo = Class(TPersistent)
 Protected
  FPassword,
  FServer,
  FUsername : String;
  FPort     : Integer;
  Procedure AssignTo      (Destination : TPersistent); Override;
  Procedure SetProxyPort  (Const Value : Integer);
  Procedure SetProxyServer(Const Value : String);
 Public
  Procedure   AfterConstruction; Override;
  Constructor Create;
  Procedure   Clear;
  Destructor  Destroy; Override;
 Published
  property ProxyPassword : String  Read FPassword Write FPassword;
  property ProxyPort     : Integer Read FPort     Write SetProxyPort;
  property ProxyServer   : String  Read FServer   Write SetProxyServer;
  property ProxyUsername : String  Read FUsername Write FUserName;
 End;


 Type
  TConnectionDefs = Class(TPersistent)
  Private
   votherDetails,
   vCharset,
   vDatabaseName,
   vHostName,
   vUsername,
   vPassword,
   vProtocol,
   vDriverID,
   vDataSource       : String;
   vdbPort         : Integer;
   vDWDatabaseType : TRESTDWDatabaseType;
  Private
   Function GetDatabaseType(Value : String)          : TRESTDWDatabaseType;Overload;
   Function GetDatabaseType(Value : TRESTDWDatabaseType) : String;         Overload;
  Public
   Constructor Create; //Cria o Componente
   Destructor  Destroy;Override;//Destroy a Classe
   Procedure   Assign(Source : TPersistent); Override;
   Function    ToJSON : String;
   Procedure   LoadFromJSON(Value : String);
  Published
   Property DriverType   : TRESTDWDatabaseType Read vDWDatabaseType Write vDWDatabaseType;
   Property Charset      : String          Read vCharset        Write vCharset;
   Property DriverID     : String          Read vDriverID       Write vDriverID;
   Property DatabaseName : String          Read vDatabaseName   Write vDatabaseName;
   Property HostName     : String          Read vHostName       Write vHostName;
   Property Username     : String          Read vUsername       Write vUsername;
   Property Password     : String          Read vPassword       Write vPassword;
   Property Protocol     : String          Read vProtocol       Write vProtocol;
   Property DBPort       : Integer         Read vdbPort         Write vdbPort;
   Property DataSource   : String          Read vDataSource     Write vDataSource;
   Property OtherDetails : String          Read votherDetails   Write votherDetails;
  End;

  Type
   TRESTDWDataRoute   = Class
   Private
    vDataRoute         : String;
    vServerMethodClass : TComponentClass;
    Procedure SetDataRoute(Value : String);
   Public
    Constructor Create;
    Property DataRoute         : String           Read vDataRoute         Write SetDataRoute;
    Property ServerMethodClass : TComponentClass  Read vServerMethodClass Write vServerMethodClass;
  End;

  Type
   PRESTDWDataRoute     = ^TRESTDWDataRoute;
   TRESTDWDataRouteList = Class(TList)
   Private
    Function  GetRec(Index : Integer) : TRESTDWDataRoute; Overload;
    Procedure PutRec(Index : Integer;
                     Item  : TRESTDWDataRoute); Overload;
   Public
    Procedure ClearList;
    Constructor Create;
    Destructor  Destroy; Override;
    Function    RouteExists(Var Value : String) : Boolean;
    Procedure   Delete(Index : Integer); Overload;
    Function    Add   (Item  : TRESTDWDataRoute) : Integer; Overload;
    Function    GetServerMethodClass(Var DataRoute,
                                     FullRequest           : String;
                                     Var ServerMethodClass : TComponentClass) : Boolean;
    Property    Items [Index : Integer] : TRESTDWDataRoute Read GetRec Write PutRec; Default;
  End;

 Type
  TArguments = Array Of String;

 Type
  TStreamType = (stMetaData, stAll);

 Type
  TPrivateClass = Class
 End;

 Type
  TRESTDWAppendFileStream           = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;
  TRESTDWReadFileExclusiveStream    = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;
  TRESTDWReadFileNonExclusiveStream = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;
  TRESTDWFileCreateStream           = Class(TFileStream)
 Public
  Constructor Create(Const AFile    : String);
 End;

 Type
  TRESTDWStreamHelper = Class
 Public
  Class Function ReadBytes(Const AStream : TStream;
                           Var   VBytes  : TRESTDWBytes;
                           Const ACount  : Integer = -1;
                           Const AOffset : Integer = 0) : Integer;
  Class Function Write    (Const AStream : TStream;
                           Const ABytes  : TRESTDWBytes;
                           Const ACount  : Integer = -1;
                           Const AOffset : Integer = 0) : Integer;
  Class Function Seek     (Const AStream : TStream;
                           Const AOffset : TRESTDWStreamSize;
                           Const AOrigin : TSeekOrigin) : TRESTDWStreamSize;
 End;

 Type
  {$IFDEF FPC}
   {$IFDEF RESTDWLAZDRIVER}
    TRESTDWClientSQLBase   = Class(TMemDataset)                   //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWUNIDACMEM}
    TRESTDWClientSQLBase   = Class(TVirtualTable)
   {$ENDIF}
   {$IFDEF RESTDWMEMTABLE}
    TRESTDWClientSQLBase   = Class(TRESTDWMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
  {$ELSE}
   {$IFDEF RESTDWCLIENTDATASET}
    TRESTDWClientSQLBase   = Class(TClientDataSet)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWKBMMEMTABLE}
    TRESTDWClientSQLBase   = Class(TKbmMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWUNIDACMEM}
    TRESTDWClientSQLBase   = Class(TVirtualTable)
   {$ENDIF}
   {$IFDEF RESTDWFDMEMTABLE}
    TRESTDWClientSQLBase   = Class(TFDMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWADMEMTABLE}
    TRESTDWClientSQLBase   = Class(TADMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWMEMTABLE}
    TRESTDWClientSQLBase   = Class(TRESTDWMemtable)             //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
  {$ENDIF}
  Private
   fsAbout                            : TRESTDWAboutInfo;
   vComponentTag,
   vSequenceField,
   vSequenceName                      : String;
   vLoadFromStream,
   vBinaryCompatibleMode,
   vOnLoadStream,
   vBinaryLoadRequest                 : Boolean;
   vOnWriterProcess                   : TOnWriterProcess;
   {$IFDEF FPC}
   vDatabaseCharSet                   : TDatabaseCharSet;
   Procedure SetDatabaseCharSet(Value : TDatabaseCharSet);
   Function  GetDatabaseCharSet : TDatabaseCharSet;
   {$ENDIF}
   Function  OnEditingState : Boolean;
   Class Procedure SaveRecordToStream(Dataset : TDataset;
                                      Stream  : TStream);
   Class Procedure SaveToStreamFromDataset(Dataset           : TDataset;
                                           Const StreamValue : TMemoryStream);
   Procedure LoadFromStreamToDataset      (Const StreamValue : TMemoryStream;
                                           DataType          : TStreamType = stAll);
  Public
   Procedure   BaseOpen;
   Procedure   BaseClose;
   Procedure   ForceInternalCalc;
   Procedure   SetComponentTAG;
   Procedure   SaveToStream     (Var Value   : TMemoryStream);Overload;
   Class Procedure SaveToStream (Dataset     : TDataset;
                                 Var Value   : TMemoryStream);Overload;
   Procedure   LoadFromStream   (Value       : TMemoryStream;
                                 DataType    : TStreamType = stAll);
   Procedure   SetInDesignEvents(Const Value : Boolean);Virtual;Abstract;
   Procedure   SetInBlockEvents (Const Value : Boolean);Virtual;Abstract;
   Procedure   SetInitDataset   (Const Value : Boolean);Virtual;Abstract;
   Procedure   PrepareDetailsNew;                       Virtual;Abstract;
   Procedure   PrepareDetails(ActiveMode : Boolean);    Virtual;Abstract;
   Constructor Create(AOwner: TComponent);Override;
   Property    InLoadFromStream  : Boolean       Read vLoadFromStream;
   Property    BinaryLoadRequest : Boolean       Read vBinaryLoadRequest;
   Property    OnLoadStream      : Boolean       Read vOnLoadStream       Write vOnLoadStream;
   Property    Componenttag      : String        Read vComponentTag;
   {$IFDEF FPC}
   Property DatabaseCharSet      : TDatabaseCharSet Read GetDatabaseCharSet Write SetDatabaseCharSet;
   {$ENDIF}
  Published
   Property BinaryCompatibleMode : Boolean          Read vBinaryCompatibleMode  Write vBinaryCompatibleMode;
   Property    SequenceName      : String           Read vSequenceName          Write vSequenceName;
   Property    SequenceField     : String           Read vSequenceField         Write vSequenceField;
   Property    OnWriterProcess   : TOnWriterProcess Read vOnWriterProcess       Write vOnWriterProcess;
   Property    AboutInfo         : TRESTDWAboutInfo Read fsAbout                Write fsAbout Stored False;
 End;

Type
 TRESTDWDatasetArray = Array of TRESTDWClientSQLBase;

Var
 RESTDWHexDigits   : Array [0..15] Of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
 RESTDWOctalDigits : Array [0..7]  Of Char = ('0', '1', '2', '3', '4', '5', '6', '7');

Implementation

Uses uRESTDWTools, uRESTDWDataJSON, uRESTDWJSONInterface, uRESTDWBasicDB;

Class Function TRESTDWStreamHelper.ReadBytes(Const AStream : TStream;
                                             Var   VBytes  : TRESTDWBytes;
                                             Const ACount,
                                             AOffset       : Integer): Integer;
Var
 LActual : Integer;
Begin
 Assert(AStream<>nil);
 Result := 0;
 If VBytes = Nil Then
  SetLength(VBytes, 0);
 LActual := ACount;
 If LActual < 0 Then
  LActual := AStream.Size - AStream.Position;
 If LActual = 0 Then
  Exit;
 If Length(VBytes) < (AOffset+LActual) Then
  SetLength(VBytes, AOffset+LActual);
 Assert(VBytes<>nil);
 Result := AStream.Read(VBytes[AOffset], LActual);
End;

Class Function TRESTDWStreamHelper.Write(Const AStream : TStream;
                                         Const ABytes  : TRESTDWBytes;
                                         Const ACount  : Integer;
                                         Const AOffset : Integer) : Integer;
Var
 LActual : Integer;
Begin
 Result := 0;
 Assert(AStream<>nil);
 If ABytes <> Nil Then
  Begin
   LActual := restdwLength(ABytes, ACount, AOffset);
   If LActual > 0 Then
    Result := AStream.Write(ABytes[AOffset], LActual);
  End;
End;

Class Function TRESTDWStreamHelper.Seek(Const AStream : TStream;
                                        Const AOffset : TRESTDWStreamSize;
                                        Const AOrigin : TSeekOrigin) : TRESTDWStreamSize;
{$IFNDEF STREAM_SIZE_64}
Const
 cOrigins: array[TSeekOrigin] of Word = (soFromBeginning, soFromCurrent, soFromEnd);
{$ENDIF}
Begin
 {$IFDEF STREAM_SIZE_64}
  Result := AStream.Seek(AOffset, AOrigin);
 {$ELSE}
  Result := AStream.Seek(AOffset, cOrigins[AOrigin]);
 {$ENDIF}
End;

Procedure TProxyConnectionInfo.SetProxyPort(Const Value : Integer);
Begin
 FPort := Value;
End;

Procedure TProxyConnectionInfo.SetProxyServer(Const Value : String);
Begin
 FServer := Value;
End;

Procedure TProxyConnectionInfo.AssignTo(Destination : TPersistent);
Var
 LDest : TProxyConnectionInfo;
Begin
 If Destination Is TProxyConnectionInfo Then
  Begin
   LDest := TProxyConnectionInfo(Destination);
   LDest.FPassword := FPassword;
   LDest.FPort := FPort;
   LDest.FServer := FServer;
   LDest.FUsername := FUsername;
  End
 Else
  Inherited AssignTo(Destination);
End;

Procedure TProxyConnectionInfo.Clear;
Begin
 FServer := '';
 FUsername := '';
 FPassword := '';
 FPort := 0;
End;

Constructor TProxyConnectionInfo.Create;
Begin
 Inherited Create;
End;

Procedure TProxyConnectionInfo.AfterConstruction;
Begin
 Inherited AfterConstruction;
 Clear;
End;

Destructor TProxyConnectionInfo.Destroy;
Begin
 Inherited Destroy;
End;

Constructor TRESTDWFileCreateStream.Create(const AFile : String);
Begin
 Inherited Create(AFile, fmCreate or fmOpenReadWrite or fmShareDenyWrite);
End;

Constructor TRESTDWAppendFileStream.Create(const AFile : String);
Var
 LFlags: Word;
Begin
 LFlags := fmOpenReadWrite or fmShareDenyWrite;
 If Not FileExists(AFile) Then
  LFlags := LFLags or fmCreate;
 Inherited Create(AFile, LFlags);
 If (LFlags and fmCreate) = 0 Then
  TRESTDWStreamHelper.Seek(Self, 0, soEnd);
End;

Constructor TRESTDWReadFileNonExclusiveStream.Create(const AFile : String);
Begin
 Inherited Create(AFile, fmOpenRead or fmShareDenyNone);
End;

Constructor TRESTDWReadFileExclusiveStream.Create(Const AFile : String);
Begin
 Inherited Create(AFile, fmOpenRead or fmShareDenyWrite);
End;

Constructor TConnectionDefs.Create;
Begin
 Inherited;
 vdbPort          := -1;
 vDWDatabaseType  := dbtUndefined;
End;

Destructor  TConnectionDefs.Destroy;
Begin
 Inherited;
End;

Function TConnectionDefs.GetDatabaseType(Value : String)          : TRESTDWDatabaseType;
Begin
 Result := dbtUndefined;
 If LowerCase(Value) = LowerCase('dbtUndefined')       Then
  Result := dbtUndefined
 Else If LowerCase(Value) = LowerCase('dbtAccess')     Then
  Result := dbtAccess
 Else If LowerCase(Value) = LowerCase('dbtDbase')      Then
  Result := dbtDbase
 Else If LowerCase(Value) = LowerCase('dbtFirebird')   Then
  Result := dbtFirebird
 Else If LowerCase(Value) = LowerCase('dbtInterbase')  Then
  Result := dbtInterbase
 Else If LowerCase(Value) = LowerCase('dbtMySQL')      Then
  Result := dbtMySQL
 Else If LowerCase(Value) = LowerCase('dbtMsSQL')      Then
  Result := dbtMsSQL
 Else If LowerCase(Value) = LowerCase('dbtOracle')     Then
  Result := dbtOracle
 Else If LowerCase(Value) = LowerCase('dbtODBC')       Then
  Result := dbtODBC
 Else If LowerCase(Value) = LowerCase('dbtParadox')    Then
  Result := dbtParadox
 Else If LowerCase(Value) = LowerCase('dbtPostgreSQL') Then
  Result := dbtPostgreSQL
 Else If LowerCase(Value) = LowerCase('dbtSQLLite')    Then
  Result := dbtSQLLite
 Else If LowerCase(Value) = LowerCase('dbtAdo')    Then
  Result := dbtAdo;
End;

Function TConnectionDefs.GetDatabaseType(Value : TRESTDWDatabaseType) : String;
Begin
 Case Value Of
  dbtUndefined  : Result := LowerCase('dbtUndefined');
  dbtAccess     : Result := LowerCase('dbtAccess');
  dbtDbase      : Result := LowerCase('dbtDbase');
  dbtFirebird   : Result := LowerCase('dbtFirebird');
  dbtInterbase  : Result := LowerCase('dbtInterbase');
  dbtMySQL      : Result := LowerCase('dbtMySQL');
  dbtSQLLite    : Result := LowerCase('dbtSQLLite');
  dbtOracle     : Result := LowerCase('dbtOracle');
  dbtMsSQL      : Result := LowerCase('dbtMsSQL');
  dbtParadox    : Result := LowerCase('dbtParadox');
  dbtPostgreSQL : Result := LowerCase('dbtPostgreSQL');
  dbtODBC       : Result := LowerCase('dbtODBC');
  dbtAdo        : Result := LowerCase('dbtAdo');
 End;
End;

Procedure   TConnectionDefs.Assign(Source : TPersistent);
Var
 Src : TConnectionDefs;
Begin
 If Source is TConnectionDefs Then
  Begin
   Src           := TConnectionDefs(Source);
   votherDetails := Src.votherDetails;
   vDatabaseName := Src.vDatabaseName;
   vHostName     := Src.vHostName;
   vUsername     := Src.vUsername;
   vPassword     := Src.vPassword;
   vdbPort       := Src.vdbPort;
   vDriverID     := Src.vDriverID;
   vDataSource   := Src.vDataSource;
  End
 Else
  Inherited;
End;

Function    TConnectionDefs.ToJSON : String;
Begin
 Result := Format('{"databasename":"%s","hostname":"%s",'+
                  '"username":"%s","password":"%s","dbPort":%d,'+
                  '"otherDetails":"%s","charset":"%s","databasetype":"%s","protocol":"%s",'+
                  '"driverID":"%s","datasource":"%s"}',
                  [EncodeStrings(vDatabaseName{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vHostName{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vUsername{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vPassword{$IFDEF FPC}, csUndefined{$ENDIF}),
                   vdbPort,
                   EncodeStrings(votherDetails{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vCharset{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(GetDatabaseType(vDWDatabaseType){$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vProtocol{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vDriverID{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vDataSource{$IFDEF FPC}, csUndefined{$ENDIF})]);
End;

Procedure TConnectionDefs.LoadFromJSON(Value : String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
Begin
 bJsonValue := TRESTDWJSONInterfaceObject.Create(Value);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vDatabaseName   := DecodeStrings(bJsonValue.Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vHostName       := DecodeStrings(bJsonValue.Pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vUsername       := DecodeStrings(bJsonValue.Pairs[2].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vPassword       := DecodeStrings(bJsonValue.Pairs[3].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    If bJsonValue.Pairs[4].Value <> '' Then
     vdbPort        := StrToInt(bJsonValue.Pairs[4].Value)
    Else
     vdbPort        := -1;
    votherDetails   := DecodeStrings(bJsonValue.Pairs[5].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vCharset        := DecodeStrings(bJsonValue.Pairs[6].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDWDatabaseType := GetDatabaseType(DecodeStrings(bJsonValue.Pairs[7].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vProtocol       := DecodeStrings(bJsonValue.Pairs[8].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDriverID       := DecodeStrings(bJsonValue.Pairs[9].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDataSource     := DecodeStrings(bJsonValue.Pairs[10].Value{$IFDEF FPC}, csUndefined{$ENDIF});
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Function RPos(const Substr, S: string): Integer;
Var
 I, X, Len: Integer;
Begin
 Len := Length(SubStr);
 I := Length(S) - Len + 1;
 If (I <= 0) Or (Len = 0) Then
  Begin
   RPos := 0;
   Exit;
  End
 Else
  Begin
   While I > 0 Do
    Begin
     If S[I] = SubStr[1] Then
      Begin
       X := 1;
       While (X < Len) And (S[I + X] = SubStr[X + 1]) Do
        Inc(X);
       If (X = Len) Then
        Begin
         RPos := I;
         exit;
        End;
      End;
     Dec(I);
    End;
   RPos := 0;
  End;
End;

Procedure TRESTDWClientSQLBase.BaseClose;
Begin
  {$IFDEF FPC}
   {$IFDEF RESTDWMEMTABLE}
    TRESTDWMemtable(Self).Close;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    TVirtualTable(Self).Close;
   {$ENDIF}
   {$IFDEF LAZDRIVER}
    TMemDataset(Self).Close;
   {$ENDIF}
  {$ELSE}
  {$IFDEF CLIENTDATASET}
   TClientDataset(Self).Close;
  {$ENDIF}
  {$IFDEF RESJEDI}
   TJvMemoryData(Self).Close;
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
   Tkbmmemtable(Self).Close;
  {$ENDIF}
  {$IFDEF RESTDWFDMEMTABLE}
   TFDmemtable(Self).Close;
  {$ENDIF}
  {$IFDEF RESTADMEMTABLE}
   TADmemtable(Self).Close;
  {$ENDIF}
  {$IFDEF RESTDWMEMTABLE}
   TRESTDWMemtable(Self).Close;
  {$ENDIF}
  {$IFDEF UNIDACMEM}
   TVirtualTable(Self).Close;
  {$ENDIF}
  {$ENDIF}
End;

Procedure TRESTDWClientSQLBase.BaseOpen;
Begin
  {$IFDEF FPC}
   {$IFDEF RESTDWMEMTABLE}
    TRESTDWMemtable(Self).Open;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    TVirtualTable(Self).Open;
   {$ENDIF}
   {$IFDEF LAZDRIVER}
    TMemDataset(Self).Open;
   {$ENDIF}
  {$ELSE}
  {$IFDEF CLIENTDATASET}
   TClientDataset(Self).Open;
  {$ENDIF}
  {$IFDEF RESJEDI}
   TJvMemoryData(Self).Open;
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
   TKbmmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTDWFDMEMTABLE}
   TFDmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTADMEMTABLE}
   TADmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTDWMEMTABLE}
   TRESTDWMemtable(Self).Open;
  {$ENDIF}
  {$IFDEF UNIDACMEM}
   TVirtualTable(Self).Open;
  {$ENDIF}
  {$ENDIF}
End;

Constructor TRESTDWClientSQLBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vOnWriterProcess      := Nil;
 vBinaryCompatibleMode := False;
 vLoadFromStream       := False;
 {$IFDEF RESTDWMEMTABLE}
  vBinaryCompatibleMode := True;
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21}
    Encoding            := esUtf8;
   {$ELSE}
    Encoding            := esAscii;
   {$IFEND}
  {$ELSE}
   Encoding             := esUtf8;
  {$ENDIF}
 {$ENDIF}
End;

{$IFDEF FPC}
Function  TRESTDWClientSQLBase.GetDatabaseCharSet : TDatabaseCharSet;
Begin
 Result := vDatabaseCharSet;
End;

Procedure TRESTDWClientSQLBase.SetDatabaseCharSet(Value : TDatabaseCharSet);
Begin
 vDatabaseCharSet := Value;
 {$IFDEF RESTDWMEMTABLE}
  TRESTDWMemtable(Self).DatabaseCharSet := Value; //Classe com as funcionalidades de um DBQuery
 {$ENDIF}
End;
{$ENDIF}

Function TRESTDWClientSQLBase.OnEditingState: Boolean;
Begin
 Result := (State in [dsEdit, dsInsert]);
 If Result then
  Edit;
End;

Procedure TRESTDWClientSQLBase.SaveToStream (Var Value   : TMemoryStream);
Begin
 If Not Assigned(Value) Then
  Value := TMemoryStream.Create;
 TRESTDWClientSQLBase.SaveToStreamFromDataset(Self, Value);
 Value.Position := 0;
End;

Class Procedure TRESTDWClientSQLBase.SaveToStream(Dataset    : TDataset;
                                                  Var Value  : TMemoryStream);
Begin
 If Not Assigned(Value) Then
  Value := TMemoryStream.Create;
 TRESTDWClientSQLBase.SaveToStreamFromDataset(Dataset, Value);
 Value.Position := 0;
End;

Class Procedure TRESTDWClientSQLBase.SaveRecordToStream(Dataset : TDataset;
                                                        Stream  : TStream);
Var
 X, I    : Integer;
 J, L    : DWInt64;
 S       : DWString;
 E       : Extended;
 F       : DWFloat;
 Bool    : Boolean;
 B       : TBcd;
 P       : TMemoryStream;
 T       : DWFieldTypeSize;
 D       : TDateTime;
Begin
 P := Nil;
 For I := 0 to Dataset.FieldCount - 1 do
  Begin
   If fkCalculated = Dataset.Fields[I].FieldKind Then Continue;
   T := DWFieldTypeSize(Dataset.Fields[I].DataType);
   Stream.Write(T, Sizeof(DWFieldTypeSize));
   Case TFieldType(T) Of
      ftMemo,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}
         ftWideMemo,{$ENDIF}
      ftFmtMemo,
      ftFixedChar,
      ftWideString,
      ftString : Begin
                  {$IFDEF COMPILER14}
                  {$WARNINGS OFF}
                   S := UnicodeString(Dataset.Fields[I].AsString);
                  {$WARNINGS ON}
                  {$ELSE}
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     S := Dataset.Fields[I].AsString;
                    {$ELSE}
                     S := Dataset.Fields[I].AsString;
                    {$IFEND}
                   {$ELSE}
                    S := Dataset.Fields[I].AsString;
                   {$ENDIF}
                  {$ENDIF}
                  If (Length(S) > Dataset.Fields[I].Size) And
                     (Dataset.Fields[I].DataType In [ftString, ftFixedChar]) Then
                   SetLength(S, Dataset.Fields[I].Size);
                  S := Utf8Encode(S);
                  L := Length(S);
                  Stream.Write(L, Sizeof(L));
                  {$IFNDEF FPC}
                  If L <> 0 Then Stream.Write(S[InitStrPos], L);
                  {$ELSE}
                  If L <> 0 Then Stream.Write(S[1], L);
                  {$ENDIF}
                 End;
      {$IFDEF COMPILER12_UP}
      ftByte,
      ftShortint : Begin
                    J := Dataset.Fields[I].AsInteger;
                    Stream.Write(J, Sizeof(DWInteger));
                   End;
      {$ENDIF}
      ftSmallint : Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      X := Dataset.Fields[I].AsInteger;
                      Stream.Write(X, Sizeof(DWInteger));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftWord,
      ftInteger,
      ftAutoInc :  Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      J := Dataset.Fields[I].AsInteger;
                      Stream.Write(J, Sizeof(DWInteger));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftFloat,
      ftFMTBcd,
      ftCurrency,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftExtended, ftSingle, {$IFEND}{$ENDIF}
      ftBCD     : Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      F := Dataset.Fields[I].AsFloat;
                      Stream.Write(F, Sizeof(DWFloat));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                  End;
      ftDate,
      ftTime,
      ftDateTime,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftTimeStampOffset, {$IFEND}{$ENDIF}
      ftTimeStamp : Begin
                     If Not Dataset.Fields[I].IsNull Then
                      J := DateTimeToUnix(Dataset.Fields[I].AsDateTime)
                     Else
                      J := 0;
                     Stream.Write(J, Sizeof(DWInt64));
                    End;
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord,{$IFEND}{$ENDIF}
      ftLargeint : Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      {$IFNDEF FPC}
                       {$IF CompilerVersion > 21}
                        J := Dataset.Fields[I].AsLargeInt;
                       {$ELSE}
                        J := Dataset.Fields[I].AsInteger;
                       {$IFEND}
                      {$ELSE}
                       J := Dataset.Fields[I].AsLargeInt;
                      {$ENDIF}
                      Stream.Write(J, Sizeof(DWInt64));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftBoolean  : Begin
                    If Dataset.Fields[I].isnull Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                     End
                    Else
                     Begin
                      Bool := Dataset.Fields[I].AsBoolean;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftVariant,
      ftInterface,
      ftIDispatch,
      ftGuid  :  Begin
                  {$IFDEF COMPILER14}
                  {$WARNINGS OFF}
                   S := UnicodeString(Dataset.Fields[I].AsString);
                  {$WARNINGS ON}
                  {$ELSE}
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     S := Dataset.Fields[I].AsString;
                    {$ELSE}
                     S := Dataset.Fields[I].AsString;
                    {$IFEND}
                   {$ELSE}
                    S := Dataset.Fields[I].AsString;
                   {$ENDIF}
                  {$ENDIF}
                  If (Length(S) > Dataset.Fields[I].Size) And
                     (Dataset.Fields[I].DataType In [ftString, ftFixedChar]) Then
                   SetLength(S, Dataset.Fields[I].Size);
                  S := Utf8Encode(S);
                  L := Length(S);
                  Stream.Write(L, Sizeof(L));
                  {$IFNDEF FPC}
                  If L <> 0 Then Stream.Write(S[InitStrPos], L);
                  {$ELSE}
                  If L <> 0 Then Stream.Write(S[1], L);
                  {$ENDIF}
                 End;
      ftBlob,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftStream,{$IFEND}{$ENDIF}
      ftBytes : Begin
                 P := TMemoryStream.Create;
                 Try
                  If Not Dataset.Fields[I].isnull Then
                   TBlobField(Dataset.Fields[I]).SaveToStream(P);
                  If Assigned(P) Then
                   Begin
                    L := P.Size;
                    Stream.Write(L, Sizeof(DWInt64));
                    P.Position := 0;
                    If L <> 0 then
                     Stream.CopyFrom(P, L);
                   End
                  Else
                   Begin
                    L := 0;
                    Stream.Write(L, Sizeof(DWInt64));
                   End;
                 Finally
                  FreeAndNil(P);
                 End;
                End;
      Else
       Begin
       {$IFNDEF COMPILER11_UP}
        If Not Dataset.Fields[I].isnull Then Continue;
        Case Integer(Dataset.Fields[I].DataType) Of
         dwftLongWord : Begin
                         J := Dataset.Fields[I].AsInteger;
                         Stream.Write(J, Sizeof(DWInteger));
                        End;
         dwftExtended,
         dwftSingle   : Begin
                         If Not(Dataset.Fields[I].IsNull) Then
                          Begin
                           Bool := False;
                           Stream.Write(Bool, Sizeof(Byte));
                           F := Dataset.Fields[I].AsFloat;
                           Stream.Write(F, Sizeof(DWFloat));
                          End
                         Else
                          Begin
                           Bool := True;
                           Stream.Write(Bool, Sizeof(Byte));
                          End;
                        End;
         dwftTimeStampOffset: Begin
                              If Not Dataset.Fields[I].IsNull Then
                               J := DateTimeToUnix(Dataset.Fields[I].AsDateTime)
                              Else
                               J := 0;
                              Stream.Write(J, Sizeof(DWInt64));
                             End;
        End;
       {$ENDIF}
       End;
   End;
  End;
End;

Class Procedure TRESTDWClientSQLBase.SaveToStreamFromDataset(Dataset           : TDataset;
                                                             Const StreamValue : TMemoryStream);
Var
 ParamsHeader : TRESTDWParamsHeader;
 {$IFNDEF FPC}
  {$if CompilerVersion < 21}
   aStream    : TMemoryStream;
  {$IFEND}
 {$ENDIF}
 I, Temp      : Integer;
 EndPos,
 StartPos     : Int64;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    S, W : String;
   {$ELSE}
    S, W : Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    S, W : Utf8String;
   {$ELSE}
    S, W : AnsiString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  S, W   : AnsiString;
 {$ENDIF}
 {$IFDEF FPC}
 Function GetDefinitions(Dataset : TDataset) : AnsiString;
 {$ELSE}
 {$IF CompilerVersion < 25}
 Function GetDefinitions(Dataset : TDataset) : AnsiString;
 {$ELSE}
 Function GetDefinitions(Dataset : TDataset) : String;
 {$IFEND}
 {$ENDIF}
 Var
  I : Integer;
  S, S2: string;
  L : TStrings;
 Begin
  L := TStringList.Create;
  Try
   For I := 0 To Dataset.FieldCount - 1 Do
    Begin
     S := Dataset.Fields[I].FieldName + '=' + GetFieldTypeB(Dataset.Fields[I].DataType);
     If fkLookup = Dataset.Fields[I].FieldKind then
      S := S + ':lookup'
     Else If fkCalculated = Dataset.Fields[I].FieldKind then
      S := S + ':calc';
     If (Dataset.Fields[I].Size > 0) and (Dataset.Fields[I].DataType <> ftGuid) Then
      S2 := IntToStr(Dataset.Fields[I].Size)
     Else
      S2 := '';
     If Dataset.Fields[I].Required Then
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
     Result := String(L.Text);
    {$ELSE}
     Result := AnsiString(L.Text);
    {$IFEND}
   {$ELSE}
    Result := AnsiString(L.Text);
   {$ENDIF}
  Finally
   L.Free;
  End;
 End;
Begin
 Try
  If Not Dataset.Active Then
   Dataset.Active := True;
  Dataset.DisableControls;
  Dataset.First;
  {$IFNDEF FPC}
   {$if CompilerVersion < 21}
    aStream := TMemoryStream.Create;
    Try
     If Not Assigned(StreamValue) Then
      Exit;
     //Write init Header
     StartPos := StreamValue.Position;
     With ParamsHeader Do
      Begin
       VersionNumber := RESTDWParamsHeaderVersion;
       DataSize      := 0;
       ParamsCount   := Dataset.FieldCount;
       RecordCount   := Dataset.RecordCount;
      End;
     //Write dwParamsBinList
     {$IFNDEF FPC}
      {$IF Defined(HAS_FMX)}
       {$IF Defined(HAS_UTF8)} //TODO
        S := String(GetDefinitions(Dataset));
       {$ELSE}
        S := AnsiString(GetDefinitions(Dataset));
       {$IFEND}
      {$ELSE}
       S := AnsiString(GetDefinitions(Dataset));
      {$IFEND}
     {$ELSE}
      S := AnsiString(GetDefinitions(Dataset));
     {$ENDIF}
    // SwapString(S);
     I := Length(S);
     StreamValue.WriteBuffer(I, SizeOf(I));
     StreamValue.WriteBuffer(S[InitStrPos], I);
     For I := 0 To ParamsHeader.RecordCount - 1 Do
      Begin
       SaveRecordToStream(Dataset, StreamValue);
       Dataset.Next;
      End;
     //Remap Bin size
     EndPos := aStream.Size;
     ParamsHeader.DataSize    := EndPos;
     ParamsHeader.ParamsCount := Dataset.FieldCount;
     ParamsHeader.RecordCount := Dataset.RecordCount;
     //Rewrite init Header
     StreamValue.Position := 0;
     aStream.Position := 0;
     StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
     StreamValue.CopyFrom(aStream, aStream.Size);
     StreamValue.Position := 0;
    Finally
     FreeAndNil(aStream);
    End;
   {$ELSE}
    If Not Assigned(StreamValue) Then
     Exit;
    //Write init Header
    StartPos := StreamValue.Position;
    With ParamsHeader Do
     Begin
      VersionNumber := RESTDWParamsHeaderVersion;
      DataSize      := 0;
      ParamsCount   := Dataset.FieldCount;
      RecordCount   := Dataset.RecordCount;
     End;
    StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
    {$IFNDEF FPC}
     {$IF Defined(HAS_FMX)}
      {$IF Defined(HAS_UTF8)} //TODO
       S := String(GetDefinitions(Dataset));
      {$ELSE}
       S := AnsiString(GetDefinitions(Dataset));
      {$IFEND}
     {$ELSE}
      S := AnsiString(GetDefinitions(Dataset));
     {$IFEND}
    {$ELSE}
     S := AnsiString(GetDefinitions(Dataset));
    {$ENDIF}
    I := Length(S);
    StreamValue.WriteBuffer(I, SizeOf(I));
    StreamValue.WriteBuffer(S[InitStrPos], I);
    For I := 0 To ParamsHeader.RecordCount - 1 Do
     Begin
      SaveRecordToStream(Dataset, StreamValue);
      Dataset.Next;
     End;
    //Remap Bin size
    EndPos := StreamValue.Position;
    ParamsHeader.DataSize    := EndPos - StartPos - SizeOf(ParamsHeader);
    ParamsHeader.ParamsCount := Dataset.FieldCount;
    ParamsHeader.RecordCount := Dataset.RecordCount;
    //Rewrite init Header
    StreamValue.Position := StartPos;
    StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
    StreamValue.Position := 0;
   {$IFEND}
  {$ELSE}
  If Not Assigned(StreamValue) Then
   Exit;
  //Write init Header
  StartPos := StreamValue.Position;
  With ParamsHeader Do
   Begin
    VersionNumber := RESTDWParamsHeaderVersion;
    DataSize      := 0;
    ParamsCount   := Dataset.FieldCount;
    RecordCount   := Dataset.RecordCount;
   End;
  StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
  {$IFNDEF FPC}
   {$IF Defined(HAS_FMX)}
    {$IF Defined(HAS_UTF8)} //TODO
     S := String(GetDefinitions(Dataset));
    {$ELSE}
     S := AnsiString(GetDefinitions(Dataset));
    {$IFEND}
   {$ELSE}
    S := AnsiString(GetDefinitions(Dataset));
   {$IFEND}
  {$ELSE}
   S := AnsiString(GetDefinitions(Dataset));
  {$ENDIF}
  I := Length(S);
  StreamValue.WriteBuffer(I, SizeOf(I));
  StreamValue.WriteBuffer(S[InitStrPos], I);
  For I := 0 To ParamsHeader.RecordCount - 1 Do
   Begin
    SaveRecordToStream(Dataset, StreamValue);
    Dataset.Next;
   End;
  //Remap Bin size
  EndPos := StreamValue.Position;
  ParamsHeader.DataSize    := EndPos - StartPos - SizeOf(ParamsHeader);
  ParamsHeader.ParamsCount := Dataset.FieldCount;
  ParamsHeader.RecordCount := Dataset.RecordCount;
  //Rewrite init Header
  StreamValue.Position := StartPos;
  StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
  StreamValue.Position := 0;
  {$ENDIF}
 Finally
  If Dataset.Active Then
   Begin
    Dataset.First;
    Dataset.EnableControls;
   End;
 End;
End;

Procedure TRESTDWClientSQLBase.LoadFromStreamToDataset(Const StreamValue : TMemoryStream;
                                                       DataType          : TStreamType = stAll);
Var
 ParamsHeader   : TRESTDWParamsHeader;
 AbortProcess   : Boolean;
 FPrecision,
 I, VersionNumber,
 RecordsCount,
 ParamsCount,
 L              : Integer;
 S              : DWString;
 vAllListFields,
 vFieldList     : TStringList;
 DataSize,
 aSize,
 StartPos       : Int64;
 Function AppendField(FieldDef,
                      Size, Precision : Integer;
                      Attributes      : TDataAttributes;
                      Const Name      : String) : Integer;
 Var
  vFieldDef : TFieldDef;
 Begin
  Result := FieldDefs.Count;
  If (FieldDefs.IndexOf(Name) > -1) Then
   Begin
    Result := FieldDefs.IndexOf(Name);
    Exit;
   End;
//  If (Fields.Count > 0) Then
//   Begin
//    If (FindField(Name) <> Nil) Then
//     Begin
//      Result := FieldByName(Name).Index;
//      Exit;
//     End;
//   End;
  vFieldDef            := FieldDefs.AddFieldDef;
  vFieldDef.Name       := Name;
  vFieldDef.DataType   := ObjectValueToFieldType(TObjectValue(FieldDef));
  If (Not(vFieldDef.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd
                                 {$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}])) Then
   vFieldDef.Size      := Size
  Else
   vFieldDef.Size      := 0;
  If (vFieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                             {$IFEND}{$ENDIF} ftFMTBcd]) Then
   vFieldDef.Precision := Precision;
   If dwNotNull in Attributes Then
    vFieldDef.Required          := True;
   If dwInternalCalc in Attributes Then
    vFieldDef.InternalCalcField := True;
//  vFieldDef.CreateField(Self);
 End;
 {$IFNDEF FPC}
 {$IF Defined(HAS_FMX)}
 Procedure Init(const Definitions : String);
 {$ELSE}
 Procedure Init(const Definitions : AnsiString);
 {$IFEND}
 {$ELSE}
 Procedure Init(const Definitions : AnsiString);
 {$ENDIF}
 Var
  X, I, P, Sz : Integer;
  N, S1, S2   : string;
  B: Boolean;
  A: TDataAttributes;
  vFieldDefinition : TFieldDefinition;
 Begin
  FieldDefs.Clear;
  FieldDefs.BeginUpdate;
  Try
   vAllListFields.Text := String(Definitions);
   For I := 0 to vAllListFields.Count - 1 do
    Begin
     If Pos('=', vAllListFields[I]) = 0 Then Continue;
     N := vAllListFields.Names[I];
     S1 := Trim(vAllListFields.ValueFromIndex[I]);
     P := Pos(',', S1);
     If P > 0 Then
      Begin
       S2 := Trim(LowerCase(Copy(S1, P + 1, MaxInt)));
       SetLength(S1, P - 1);
       S1 := Trim(S1);
       B := Pos('nn:', S2) = 1;
       If B Then
        {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(S2, 1, 3)
       Else
        Begin
         P := RPos(':nn', S2);
         B := P > 0;
         If B Then
          {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(S2, P, 3)
         Else
          Begin
           B := S2 = 'nn';
           If B Then
            S2 := '';
          End;
        End;
       Sz := StrToIntDef(S2, 0);
      End
     Else
      Begin
       B := False;
       Sz := 0;
      End;
     If B Then
      A := [dwNotNull]
     Else
      A := [];
     P := RPos(':calc', LowerCase(S1));
     If P > 0 Then
      Begin
       SetLength(S1, P - 1);
       S1 := Trim(S1);
       Include(A, dwCalcField);
      End
     Else
      Begin
       P := RPos(':lookup', LowerCase(S1));
       If P > 0 Then
        Begin
         SetLength(S1, P - 1);
         S1 := Trim(S1);
         Include(A, dwCalcField);
         Include(A, dwLookup);
        End;
      End;
     vFieldDefinition               := TFieldDefinition.Create;
     vFieldDefinition.FieldName     := N;
     vFieldDefinition.DataType      := TFieldType(StringToFieldType(S1));
     If (Not(vFieldDefinition.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd
                                          {$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}])) Then
      vFieldDefinition.Size         := Sz
     Else
      vFieldDefinition.Size         := 0;
     If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                                       {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                       {$IFEND}{$ENDIF} ftFMTBcd]) Then
      vFieldDefinition.Precision    := FPrecision;
     vFieldDefinition.Required      := B;
     TRESTDWClientSQL(Self).NewDataField(vFieldDefinition);
     If TRESTDWClientSQL(Self).Fields.Count = 0 Then
      vFieldList.Add(N);
     AppendField(StringToFieldType(S1), Sz, FPrecision, A, N);
     FreeAndNil(vFieldDefinition);
    End;
  Finally
   FieldDefs.EndUpdate;
   TRESTDWClientSQL(Self).SetInBlockEvents(True);
   TRESTDWClientSQL(Self).Inactive := True;
   TRESTDWClientSQL(Self).CreateDataSet;
   If Not TRESTDWClientSQL(Self).Active Then
    TRESTDWClientSQL(Self).Open;
   TRESTDWClientSQL(Self).Inactive := False;
  End;
 End;
 Procedure LoadRecordFromStream(FieldList : TStringList;
                                Stream    : TStream);
 Var
  X, I       : Integer;
  J, L       : DWInt64;
  S, W       : DWString;
  E          : Extended;
  F          : DWFloat;
  Bool       : Boolean;
  B          : TBcd;
  P          : TMemoryStream;
  T          : DWFieldTypeSize;
  D          : TDateTime;
  vField     : TField;
  vFieldName : String;
  Function IsFieldValue : Boolean;
  Var
   Z : Integer;
  Begin
   Result := False;
   {$IFDEF FPC}
   Z := FieldList.IndexOf(vFieldName);
   If Not(vFieldName = FieldList[Z]) Then
    Z := -1;
   {$ELSE}
   FieldList.Find(vFieldName, Z);
   {$ENDIF}
   Result := Z > -1;
   If Result Then
    Begin
     vField := FindField(vFieldName);
     If vField = Nil Then
      Result := False
     Else If (fkCalculated = vField.FieldKind) Or
             (fkLookup     = vField.FieldKind) Then
      Result := False;
    End;
  End;
 Begin
  For I := 0 To vAllListFields.Count -1 Do
   Begin
    S := '';
    L := 0;
    J := 0;
    vFieldName := vAllListFields.Names[I];
    Stream.ReadBuffer(T, Sizeof(DWFieldTypeSize));
//    T := Integer(vField.DataType);
    Case TFieldType(T) Of
      ftMemo,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}
         ftWideMemo,{$ENDIF}
      ftFmtMemo,
      ftFixedChar,
      ftWideString,
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
                  If IsFieldValue Then
                   Begin
                    If (Length(S) > vField.Size) And
                       (vField.DataType In [ftString, ftFixedChar]) Then
                      vField.AsString := S;
                     {$IFNDEF FPC}
                      {$IF Defined(HAS_FMX)}
                       {$IFDEF WINDOWS}
                        If SourceSide = dwDelphi Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}
                        Else If SourceSide = dwLazarus Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}
                       {$ELSE}
                         vField.AsString := S;
                       {$ENDIF}
                      {$ELSE}
                       vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                      {$IFEND}
                     {$ELSE}
                      vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                     {$ENDIF}
                   End;
                 End;
      {$IFDEF COMPILER12_UP}
      ftByte,
      ftShortint : Begin
                    Stream.ReadBuffer(J, Sizeof(DWInteger));
                    If IsFieldValue Then
                     vField.AsInteger := J;
                   End;
      {$ENDIF}
      ftSmallint : Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If Not Bool Then
                     Begin
                      Stream.ReadBuffer(X, Sizeof(DWInteger));
                      If IsFieldValue Then
                       vField.AsInteger := X;
                     End;
                   End;
      ftWord,
      ftInteger,
      ftAutoInc :  Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If Not Bool Then
                     Begin
                      Stream.ReadBuffer(J, Sizeof(DWInteger));
                      If IsFieldValue Then
                       vField.AsInteger := J;
                     End;
                   End;
      ftFloat,
      ftFMTBcd,
      ftCurrency,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftExtended, ftSingle, {$IFEND}{$ENDIF}
      ftBCD     : Begin
                   F := 0;
                   Stream.ReadBuffer(Bool, Sizeof(Byte));
                   If Not Bool Then
                    Begin
                     Stream.ReadBuffer(F, Sizeof(DWFloat));
                     If IsFieldValue Then
                      vField.Value := F;
                    End;
                  End;
      ftDate,
      ftTime,
      ftDateTime,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftTimeStampOffset, {$IFEND}{$ENDIF}
      ftTimeStamp : Begin
                     Stream.ReadBuffer(J, Sizeof(DWInt64));
                     If J <> 0 Then
                      If IsFieldValue Then
                       vField.AsDateTime := UnixToDateTime(J);
                    End;
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord,{$IFEND}{$ENDIF}
      ftLargeint : Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If Not Bool Then
                     Begin
                     Stream.ReadBuffer(J, Sizeof(DWInt64));
                     If IsFieldValue Then
                      Begin
                       {$IFNDEF FPC}
                        {$IF CompilerVersion > 21}
                         vField.AsLargeInt := J;
                        {$ELSE}
                         vField.AsInteger := J;
                        {$IFEND}
                       {$ELSE}
                        vField.AsLargeInt := J;
                       {$ENDIF}
                      End;
                     End;
                   End;
      ftBoolean  : Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If IsFieldValue Then
                     vField.AsBoolean := Bool;
                   End;
      ftVariant,
      ftInterface,
      ftIDispatch,
      ftGuid   : Begin
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
                  If IsFieldValue Then
                   Begin
                    If (Length(S) > vField.Size) And
                       (vField.DataType In [ftString, ftFixedChar]) Then
                     vField.AsString := S;
                     {$IFNDEF FPC}
                      {$IF Defined(HAS_FMX)}
                       {$IFDEF WINDOWS}
                        If SourceSide = dwDelphi Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}
                        Else If SourceSide = dwLazarus Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}
                       {$ELSE}
                         vField.AsString := S;
                       {$ENDIF}
                      {$ELSE}
                       vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                      {$IFEND}
                     {$ELSE}
                      vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                     {$ENDIF}
                   End;
                 End;
      ftBlob,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftStream,{$IFEND}{$ENDIF}
      ftBytes : Begin
                 Stream.ReadBuffer(J, Sizeof(DWInt64));
                 If J > 0 Then
                  Begin
                   P := TMemoryStream.Create;
                   Try
                    P.CopyFrom(Stream, J);
                    P.position := 0;
                    If IsFieldValue Then
                     Begin
                      If P.Size > 0 Then
                       TBlobField(vField).LoadFromStream(P)
                      Else
                       TBlobField(vField).Clear;
                     End;
                   Finally
                    P.Free;
                   End;
                  End;
                End;
      Else
       Begin
       {$IFNDEF COMPILER11_UP}
        Case Integer(T) Of
         dwftWideMemo : Begin
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
                         If IsFieldValue Then
                          Begin
                           If (Length(S) > vField.Size) And
                              (vField.DataType In [ftString, ftFixedChar]) Then
                            vField.AsString := S;
                           {$IFNDEF FPC}
                            {$IF Defined(HAS_FMX)}
                             {$IFDEF WINDOWS}
                              If SourceSide = dwDelphi Then
                               vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}
                              Else If SourceSide = dwLazarus Then
                               vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}
                             {$ELSE}
                               vField.AsString := S;
                             {$ENDIF}
                            {$ELSE}
                             vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                            {$IFEND}
                           {$ELSE}
                            vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                           {$ENDIF}
                          End;
                        End;
         dwftLongWord : Begin
                         Stream.ReadBuffer(J, Sizeof(DWInteger));
                         If IsFieldValue Then
                          vField.AsInteger := J;
                        End;
         dwftExtended,
         dwftSingle   : Begin
                         F := 0;
                         Stream.ReadBuffer(Bool, Sizeof(Byte));
                         If Not Bool Then
                          Begin
                           Stream.ReadBuffer(F, Sizeof(DWFloat));
                           If IsFieldValue Then
                            vField.Value := F;
                          End;
                        End;
         dwftTimeStampOffset: Begin
                               Stream.ReadBuffer(J, Sizeof(DWInt64));
                               If J <> 0 Then
                                If IsFieldValue Then
                                 vField.AsDateTime := UnixToDateTime(J);
                              End;
        End;
       {$ENDIF}
       End;
    End;
   End;
 End;
Begin
 FPrecision           := 0;
 StreamValue.Position := FPrecision;
 AbortProcess         := False;
 vFieldList           := Nil;
 vAllListFields       := Nil;
 If StreamValue.Size > 0 Then
  Begin
   StreamValue.ReadBuffer(ParamsHeader, Sizeof(TRESTDWParamsHeader));
   VersionNumber   := ParamsHeader.VersionNumber;
   ParamsCount     := ParamsHeader.ParamsCount;
   RecordsCount    := ParamsHeader.RecordCount;
   DataSize        := ParamsHeader.DataSize;
   StartPos        := StreamValue.Position;
   aSize           := StreamValue.Size;
   S := '';
   StreamValue.ReadBuffer(I, SizeOf(I));
   If (I > ParamsHeader.DataSize) Or
      (I > MAXSHORT)              Or
      (I < 0)                     Then
    Raise RESTDWTableError.Create(SCorruptedDefinitions);
   SetLength(S, I);
   {$IFDEF FPC}
    If I <> 0 Then
     StreamValue.ReadBuffer(Pointer(S)^, I);
    S := GetStringEncode(S, vDatabaseCharSet);
   {$ELSE}
    If I <> 0 Then
     StreamValue.Read(S[InitStrPos], I);
   {$ENDIF}
   //Init FieldDefs
   vFieldList     := TStringList.Create;
   vAllListFields := TStringList.Create;
   //Load Data
   DisableControls;
   TRESTDWClientSQL(Self).SetInBlockEvents(True);
   Init(S);
   If DataType = stAll Then
    Begin
     Try
      For I := 0 To RecordsCount - 1 Do
       Begin
        If StreamValue.Position = StreamValue.Size Then
         Break;
        Append;
        LoadRecordFromStream(vFieldList, StreamValue);
        If Assigned(OnWriterProcess) Then
         OnWriterProcess(Self, I +1, RecordsCount, AbortProcess);
        If AbortProcess Then
         Break;
        Post;
       End;
     Finally
      First;
      EnableControls;
      TRESTDWClientSQL(Self).SetInBlockEvents(False);
     End;
    End;
  End
 Else
  Raise Exception.Create(Format(cInvalidBinaryRequest, ['None data came from server.']));
 If Assigned(vFieldList) Then
  FreeAndNil(vFieldList);
 If Assigned(vAllListFields) Then
  FreeAndNil(vAllListFields);
// If Assigned(OnCalcFields) Then
//  OnCalcFields(Self);
End;

Procedure TRESTDWClientSQLBase.LoadFromStream(Value    : TMemoryStream;
                                              DataType : TStreamType = stAll);
Var
 I : Integer;
 //TODO XyberX
//{$IFNDEF RESTDWMEMTABLE}
// vMemBRequest :  TRESTDWMemtable;
// Procedure CopyData;
// Begin
//  vMemBRequest.First;
//  {$IFDEF UNIDACMEM}
//   AssignDataSet(vMemBRequest);
//  {$ELSE}
//   {$IFDEF CLIENTDATASET}
//    LoadFromStream(Value);
//   {$ELSE}
//    Try
//     While Not vMemBRequest.Eof Do
//      Begin
//       Append;
//       CopyRecord(vMemBRequest);
//       Post;
//       vMemBRequest.Next;
//      End;
//    Finally
//    End;
//   {$ENDIF}
//  {$ENDIF}
// End;
//{$ENDIF}
Begin
 vLoadFromStream := True;
 Try
  Try
 //  SetInitDataset(True);
  {$IFDEF FPC}
   {$IFDEF RESTDWMEMTABLE}
    vBinaryLoadRequest := True;
    DisableControls;
    Close;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TRESTDWMemtable(Self).Encoding        := TRESTDWClientSQL(Self).Encoding;
       TRESTDWMemtable(Self).OnWriterProcess := vOnWriterProcess;
       If Value.Size > 0 Then
        Begin
         TRESTDWMemtable(Self).LoadFromStream(Value);
         TRESTDWMemtable(Self).Active := True;
        End;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream     := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    vBinaryLoadRequest := True;
    DisableControls;
    Close;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TVirtualTable(Self).LoadFromStream(Value);
       TVirtualTable(Self).Active := True;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream      := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
  {$ELSE}
   {$IFDEF CLIENTDATASET}
    vBinaryLoadRequest := True;
    DisableControls;
    Close;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TClientDataset(Self).LoadFromStream(Value);
       TClientDataset(Self).Active := True;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream      := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTKBMMEMTABLE}
    Raise Exception.Create(Format(cInvalidBinaryRequest, ['Invalid dataset driver.']));
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    DisableControls;
    Close;
    vBinaryLoadRequest := True;
    Try
     Value.Position := 0;
     If vBinaryCompatibleMode Then
      LoadFromStreamToDataset(Value, DataType)
     Else
      Begin
       If Value.Size > 0 Then
        Begin
         TVirtualTable(Self).LoadFromStream(Value, TVirtualTable(Self).Fields.Count = 0);
         TVirtualTable(Self).Active := True;
        End;
      End;
    Finally
     vOnLoadStream     := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTDWFDMEMTABLE}
    DisableControls;
    Close;
    Try
     vBinaryLoadRequest := True;
     If vBinaryCompatibleMode Then
      LoadFromStreamToDataset(Value, DataType)
     Else
      Begin
       Try
        If Value.Size > 0 Then
         Begin
          If DataType = stAll Then
           TFDMemtable(Self).ResourceOptions.StoreItems := [siMeta, siData, siDelta]
          Else
           TFDMemtable(Self).ResourceOptions.StoreItems := [siMeta, siDelta];
          TFDMemtable(Self).LoadFromStream(Value, sfBinary);
         End;
        vOnLoadStream     := True;
       Finally
        vOnLoadStream     := False;
        vBinaryLoadRequest := False;
       End;
      End;
    Finally
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTADMEMTABLE}
    DisableControls;
    Close;
    Try
     vBinaryLoadRequest := True;
     If vBinaryCompatibleMode Then
      LoadFromStreamToDataset(Value, DataType)
     Else
      Begin
       Try
        If Value.Size > 0 Then
         Begin
          If DataType = stAll Then
           TADMemtable(Self).ResourceOptions.StoreItems := [siMeta, siData, siDelta]
          Else
           TADMemtable(Self).ResourceOptions.StoreItems := [siMeta, siDelta];
          TADMemtable(Self).LoadFromStream(Value, sfBinary);
         End;
        vOnLoadStream     := True;
       Finally
        vOnLoadStream     := False;
        vBinaryLoadRequest := False;
       End;
      End;
    Finally
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTDWMEMTABLE}
    DisableControls;
    vBinaryLoadRequest := True;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TRESTDWMemtable(Self).Encoding        := TRESTDWClientSQL(Self).Encoding;
       TRESTDWMemtable(Self).OnWriterProcess := vOnWriterProcess;
       If Value.Size > 0 Then
        Begin
         TRESTDWMemtable(Self).LoadFromStream(Value);
         TRESTDWMemtable(Self).Active := True;
        End;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream     := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
  {$ENDIF}
  Finally
   vLoadFromStream := False;
 //  SetInitDataset(False);
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(Format(cInvalidBinaryRequest, [E.Message]));
   End;
 End
End;

Procedure TRESTDWClientSQLBase.SetComponentTAG;
Begin
 vComponentTag := EncodeStrings(RandomString(10){$IFDEF FPC}, csUndefined{$ENDIF});
End;

Procedure TRESTDWClientSQLBase.ForceInternalCalc;
Var
 needsPost : Boolean;
 saveState : TDataSetState;
Begin
 needsPost := OnEditingState;
 saveState := setTempState(dsInternalCalc);
 Try
  RefreshInternalCalcFields(ActiveBuffer);
 Finally
  RestoreState(saveState);
 End;
 If needsPost Then
  Post;
End;

Procedure TRESTDWDataRoute.SetDataRoute(Value : String);
Begin
 vDataRoute := Value;
 If Trim(vDataRoute) = '' Then
  vDataRoute := '/'
 Else
  Begin
   If Copy(vDataRoute, 1, 1) <> '/' Then
    vDataRoute := '/' + vDataRoute;
   If Copy(vDataRoute, Length(vDataRoute), 1) <> '/' Then
    vDataRoute := vDataRoute + '/';
  End;
End;

Constructor TRESTDWDataRoute.Create;
Begin
 vDataRoute         := '';
 vServerMethodClass := TClassNull;
End;

Function TRESTDWDataRouteList.GetRec(Index : Integer) : TRESTDWDataRoute;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWDataRoute(TList(Self).Items[Index]^);
End;

Procedure TRESTDWDataRouteList.PutRec(Index : Integer;
                                      Item  : TRESTDWDataRoute);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWDataRoute(TList(Self).Items[Index]^) := Item;
End;

Procedure TRESTDWDataRouteList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TRESTDWDataRouteList.Create;
Begin
 Inherited;
End;

Function   TRESTDWDataRouteList.RouteExists(Var Value : String) : Boolean;
Var
 I          : Integer;
 vTempRoute,
 vTempValue : String;
Begin
 Result := False;
 If Length(Value) = 0 Then
  Exit;
 For I := 0 To Count -1 Do
  Begin
   vTempRoute := Lowercase(Items[I].DataRoute);
   vTempValue := Lowercase(Value);
   Result     := vTempRoute = Copy(vTempValue, 1, Length(vTempRoute));
   If Result Then
    Break;
  End;
End;

Destructor TRESTDWDataRouteList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Procedure TRESTDWDataRouteList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     {$IFDEF FPC}
     FreeAndNil(TList(Self).Items[Index]^);
     {$ELSE}
      {$IF CompilerVersion > 33}
       FreeAndNil(TRESTDWDataRoute(TList(Self).Items[Index]^));
      {$ELSE}
       FreeAndNil(TList(Self).Items[Index]^);
      {$IFEND}
     {$ENDIF}
     {$IFDEF FPC}
      Dispose(PRESTDWDataRoute(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Function TRESTDWDataRouteList.GetServerMethodClass(Var DataRoute,
                                                   FullRequest           : String;
                                                   Var ServerMethodClass : TComponentClass) : Boolean;
Var
 I           : Integer;
 vTempRoute,
 vTempValue  : String;
Begin
 Result            := False;
 ServerMethodClass := Nil;
 Result := False;
 If Length(DataRoute) = 0 Then
  Exit;
 For I := 0 To Self.Count -1 Do
  Begin
   vTempRoute := Lowercase(TRESTDWDataRoute(TList(Self).Items[I]^).DataRoute);
   vTempValue := Lowercase(DataRoute);
   Result     := vTempRoute = Copy(vTempValue, 1, Length(vTempRoute));
   If (Result) Then
    Begin
     ServerMethodClass := TRESTDWDataRoute(TList(Self).Items[I]^).ServerMethodClass;
     DataRoute         := Copy(vTempValue,  Length(vTempRoute), Length(DataRoute) - (Length(vTempRoute) -1));
     FullRequest       := Copy(FullRequest, Length(vTempRoute), Length(FullRequest) - (Length(vTempRoute) -1));
     Break;
    End;
  End;
End;

Function TRESTDWDataRouteList.Add(Item : TRESTDWDataRoute) : Integer;
Var
 vItem : PRESTDWDataRoute;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMimeTable.LoadFromStrings(Const AStrings      : TStrings;
                                     Const MimeSeparator : Char = '=');    {Do not Localize}
Var
 I, P   : Integer;
 S, Ext : String;
Begin
InitializeStrings;
 Assert(AStrings <> nil);
 FFileExt.Clear;
 FMIMEList.Clear;
 For I := 0 To AStrings.Count - 1 Do
  Begin
   S := AStrings[I];
   For P := InitStrPos To Length(S) - FinalStrPos Do
    Begin
     If S[P] = MimeSeparator Then
      Begin
       Ext := LowerCase(Copy(S, 1, P - 1));
       AddMimeType(Ext, Copy(S, P + 1, MaxInt), False);
       Break;
      End;
    End;
  End;
End;

Procedure TMimeTable.SaveToStrings(Const AStrings      : TStrings;
                                   Const MimeSeparator : Char);
Var
 I : Integer;
Begin
 Assert(AStrings <> nil);
 AStrings.BeginUpdate;
 Try
  AStrings.Clear;
  For I := 0 To FFileExt.Count - 1 Do
   AStrings.Add(FFileExt[I] + MimeSeparator + FMIMEList[I]);
 Finally
  AStrings.EndUpdate;
 End;
End;

Function TMimeTable.GetDefaultFileExt(Const MIMEType : String) : String;
Var
 Index     : Integer;
 LMimeType : String;
Begin
 LMimeType := LowerCase(MIMEType);
 Index     := FMIMEList.IndexOf(LMimeType);
 If Index = -1 Then
  Begin
   BuildCache;
   Index := FMIMEList.IndexOf(LMIMEType);
  End;
 If Index <> -1 Then
  Result := FFileExt[Index]
 Else
  Result := '';    {Do not Localize}
End;

Function TMimeTable.GetFileMIMEType(Const AFileName : String) : String;
Var
 Index : Integer;
 LExt  : String;
Begin
 LExt  := LowerCase(ExtractFileExt(AFileName));
 Index := FFileExt.IndexOf(LExt);
 If Index = -1 Then
  Begin
   BuildCache;
   Index := FFileExt.IndexOf(LExt);
  End;
 If Index <> -1 Then
  Result := FMIMEList[Index]
 Else
  Result := 'application/octet-stream' {do not localize}
End;

Procedure TMimeTable.AddMimeType(Const Ext,
                                 MIMEType            : String;
                                 Const ARaiseOnError : Boolean = True);
Var
 LExt,
 LMIMEType : String;
Begin
 { Check and fix extension }
 LExt := Lowercase(Ext);
 If Length(LExt) = 0 Then
  Begin
   If ARaiseOnError Then
    Raise Exception.Create(cMIMETypeEmpty);
   Exit;
  End;
  { Check and fix MIMEType }
 LMIMEType := Lowercase(MIMEType);
 If Length(LMIMEType) = 0 Then
  Begin
   If ARaiseOnError Then
    Raise Exception.Create(cMIMETypeEmpty);
   Exit;
  End;
 If LExt[1] <> '.' Then
  LExt := '.' + LExt;      {do not localize}
 { Check list }
 If FFileExt.IndexOf(LExt) = -1 Then
  Begin
   FFileExt.Add(LExt);
   FMIMEList.Add(LMIMEType);
  End
 Else
  Begin
   If ARaiseOnError Then
    Raise Exception.Create(cMIMETypeAlreadyExists);
   Exit;
  End;
End;

Procedure TMimeTable.BuildCache;
Begin
 If Assigned(FOnBuildCache) Then
  FOnBuildCache(Self)
 Else
  Begin
   If FFileExt.Count = 0 Then
    BuildDefaultCache;
  End;
End;

Procedure TMimeTable.BuildDefaultCache;
Var
 LKeys : TStringList;
 Procedure FillMimeTable(Const AMIMEList   : TStrings;
                         Const ALoadFromOS : Boolean = True);
 {$IFNDEF FPC}
 {$IFDEF WINDOWS}
 Var
  reg     : TRegistry;
  KeyList : TStringList;
  i       : Integer;
  s, LExt : String;
 {$ENDIF}
 {$ENDIF}
 Begin
  If Not Assigned(AMIMEList) Then
   Exit;
  If AMIMEList.Count > 0     Then
   Exit;
  { Animation }
  AMIMEList.Add('.nml=animation/narrative');    {Do not Localize}
  { Audio }
  AMIMEList.Add('.aac=audio/mp4');
  AMIMEList.Add('.aif=audio/x-aiff');    {Do not Localize}
  AMIMEList.Add('.aifc=audio/x-aiff');    {Do not Localize}
  AMIMEList.Add('.aiff=audio/x-aiff');    {Do not Localize}
  AMIMEList.Add('.au=audio/basic');    {Do not Localize}
  AMIMEList.Add('.gsm=audio/x-gsm');    {Do not Localize}
  AMIMEList.Add('.kar=audio/midi');    {Do not Localize}
  AMIMEList.Add('.m3u=audio/mpegurl');    {Do not Localize}
  AMIMEList.Add('.m4a=audio/x-mpg');    {Do not Localize}
  AMIMEList.Add('.mid=audio/midi');    {Do not Localize}
  AMIMEList.Add('.midi=audio/midi');    {Do not Localize}
  AMIMEList.Add('.mpega=audio/x-mpg');    {Do not Localize}
  AMIMEList.Add('.mp2=audio/x-mpg');    {Do not Localize}
  AMIMEList.Add('.mp3=audio/x-mpg');    {Do not Localize}
  AMIMEList.Add('.mpga=audio/x-mpg');    {Do not Localize}
  AMIMEList.Add('.m3u=audio/x-mpegurl');    {Do not Localize}
  AMIMEList.Add('.pls=audio/x-scpls');   {Do not Localize}
  AMIMEList.Add('.qcp=audio/vnd.qcelp');    {Do not Localize}
  AMIMEList.Add('.ra=audio/x-realaudio');    {Do not Localize}
  AMIMEList.Add('.ram=audio/x-pn-realaudio');    {Do not Localize}
  AMIMEList.Add('.rm=audio/x-pn-realaudio');    {Do not Localize}
  AMIMEList.Add('.sd2=audio/x-sd2');    {Do not Localize}
  AMIMEList.Add('.sid=audio/prs.sid');   {Do not Localize}
  AMIMEList.Add('.snd=audio/basic');   {Do not Localize}
  AMIMEList.Add('.wav=audio/x-wav');    {Do not Localize}
  AMIMEList.Add('.wax=audio/x-ms-wax');    {Do not Localize}
  AMIMEList.Add('.wma=audio/x-ms-wma');    {Do not Localize}
  AMIMEList.Add('.mjf=audio/x-vnd.AudioExplosion.MjuiceMediaFile');    {Do not Localize}
  { Image }
  AMIMEList.Add('.art=image/x-jg');    {Do not Localize}
  AMIMEList.Add('.bmp=image/bmp');    {Do not Localize}
  AMIMEList.Add('.cdr=image/x-coreldraw');    {Do not Localize}
  AMIMEList.Add('.cdt=image/x-coreldrawtemplate');    {Do not Localize}
  AMIMEList.Add('.cpt=image/x-corelphotopaint');    {Do not Localize}
  AMIMEList.Add('.djv=image/vnd.djvu');    {Do not Localize}
  AMIMEList.Add('.djvu=image/vnd.djvu');    {Do not Localize}
  AMIMEList.Add('.gif=image/gif');    {Do not Localize}
  AMIMEList.Add('.ief=image/ief');    {Do not Localize}
  AMIMEList.Add('.ico=image/x-icon');    {Do not Localize}
  AMIMEList.Add('.jng=image/x-jng');    {Do not Localize}
  AMIMEList.Add('.jpg=image/jpeg');    {Do not Localize}
  AMIMEList.Add('.jpeg=image/jpeg');    {Do not Localize}
  AMIMEList.Add('.jpe=image/jpeg');    {Do not Localize}
  AMIMEList.Add('.pat=image/x-coreldrawpattern');   {Do not Localize}
  AMIMEList.Add('.pcx=image/pcx');    {Do not Localize}
  AMIMEList.Add('.pbm=image/x-portable-bitmap');    {Do not Localize}
  AMIMEList.Add('.pgm=image/x-portable-graymap');    {Do not Localize}
  AMIMEList.Add('.pict=image/x-pict');    {Do not Localize}
  AMIMEList.Add('.png=image/x-png');    {Do not Localize}
  AMIMEList.Add('.pnm=image/x-portable-anymap');    {Do not Localize}
  AMIMEList.Add('.pntg=image/x-macpaint');    {Do not Localize}
  AMIMEList.Add('.ppm=image/x-portable-pixmap');    {Do not Localize}
  AMIMEList.Add('.psd=image/x-psd');    {Do not Localize}
  AMIMEList.Add('.qtif=image/x-quicktime');    {Do not Localize}
  AMIMEList.Add('.ras=image/x-cmu-raster');    {Do not Localize}
  AMIMEList.Add('.rf=image/vnd.rn-realflash');    {Do not Localize}
  AMIMEList.Add('.rgb=image/x-rgb');    {Do not Localize}
  AMIMEList.Add('.rp=image/vnd.rn-realpix');    {Do not Localize}
  AMIMEList.Add('.sgi=image/x-sgi');    {Do not Localize}
  AMIMEList.Add('.svg=image/svg+xml');    {Do not Localize}
  AMIMEList.Add('.svgz=image/svg+xml');    {Do not Localize}
  AMIMEList.Add('.targa=image/x-targa');    {Do not Localize}
  AMIMEList.Add('.tif=image/x-tiff');    {Do not Localize}
  AMIMEList.Add('.wbmp=image/vnd.wap.wbmp');    {Do not Localize}
  AMIMEList.Add('.webp=image/webp'); {Do not localize}
  AMIMEList.Add('.xbm=image/xbm');    {Do not Localize}
  AMIMEList.Add('.xbm=image/x-xbitmap');    {Do not Localize}
  AMIMEList.Add('.xpm=image/x-xpixmap');    {Do not Localize}
  AMIMEList.Add('.xwd=image/x-xwindowdump');    {Do not Localize}
  { Text }
  AMIMEList.Add('.323=text/h323');    {Do not Localize}
  AMIMEList.Add('.xml=text/xml');    {Do not Localize}
  AMIMEList.Add('.uls=text/iuls');    {Do not Localize}
  AMIMEList.Add('.txt=text/plain');    {Do not Localize}
  AMIMEList.Add('.rtx=text/richtext');    {Do not Localize}
  AMIMEList.Add('.wsc=text/scriptlet');    {Do not Localize}
  AMIMEList.Add('.rt=text/vnd.rn-realtext');    {Do not Localize}
  AMIMEList.Add('.htt=text/webviewhtml');    {Do not Localize}
  AMIMEList.Add('.htc=text/x-component');    {Do not Localize}
  AMIMEList.Add('.vcf=text/x-vcard');    {Do not Localize}
  { Video }
  AMIMEList.Add('.asf=video/x-ms-asf');    {Do not Localize}
  AMIMEList.Add('.asx=video/x-ms-asf');    {Do not Localize}
  AMIMEList.Add('.avi=video/x-msvideo');    {Do not Localize}
  AMIMEList.Add('.dl=video/dl');    {Do not Localize}
  AMIMEList.Add('.dv=video/dv');  {Do not Localize}
  AMIMEList.Add('.flc=video/flc');    {Do not Localize}
  AMIMEList.Add('.fli=video/fli');    {Do not Localize}
  AMIMEList.Add('.gl=video/gl');    {Do not Localize}
  AMIMEList.Add('.lsf=video/x-la-asf');    {Do not Localize}
  AMIMEList.Add('.lsx=video/x-la-asf');    {Do not Localize}
  AMIMEList.Add('.mng=video/x-mng');    {Do not Localize}
  AMIMEList.Add('.mp2=video/mpeg');    {Do not Localize}
  AMIMEList.Add('.mp3=video/mpeg');    {Do not Localize}
  AMIMEList.Add('.mp4=video/mpeg');    {Do not Localize}
  AMIMEList.Add('.mpeg=video/x-mpeg2a');    {Do not Localize}
  AMIMEList.Add('.mpa=video/mpeg');    {Do not Localize}
  AMIMEList.Add('.mpe=video/mpeg');    {Do not Localize}
  AMIMEList.Add('.mpg=video/mpeg');    {Do not Localize}
  AMIMEList.Add('.ogv=video/ogg');    {Do not Localize}
  AMIMEList.Add('.moov=video/quicktime');     {Do not Localize}
  AMIMEList.Add('.mov=video/quicktime');    {Do not Localize}
  AMIMEList.Add('.mxu=video/vnd.mpegurl');   {Do not Localize}
  AMIMEList.Add('.qt=video/quicktime');    {Do not Localize}
  AMIMEList.Add('.qtc=video/x-qtc'); {Do not loccalize}
  AMIMEList.Add('.rv=video/vnd.rn-realvideo');    {Do not Localize}
  AMIMEList.Add('.ivf=video/x-ivf');    {Do not Localize}
  AMIMEList.Add('.webm=video/webm');    {Do not Localize}
  AMIMEList.Add('.wm=video/x-ms-wm');    {Do not Localize}
  AMIMEList.Add('.wmp=video/x-ms-wmp');    {Do not Localize}
  AMIMEList.Add('.wmv=video/x-ms-wmv');    {Do not Localize}
  AMIMEList.Add('.wmx=video/x-ms-wmx');    {Do not Localize}
  AMIMEList.Add('.wvx=video/x-ms-wvx');    {Do not Localize}
  AMIMEList.Add('.rms=video/vnd.rn-realvideo-secure');    {Do not Localize}
  AMIMEList.Add('.asx=video/x-ms-asf-plugin');    {Do not Localize}
  AMIMEList.Add('.movie=video/x-sgi-movie');    {Do not Localize}
  { Application }
  AMIMEList.Add('.7z=application/x-7z-compressed');   {Do not Localize}
  AMIMEList.Add('.a=application/x-archive');   {Do not Localize}
  AMIMEList.Add('.aab=application/x-authorware-bin');    {Do not Localize}
  AMIMEList.Add('.aam=application/x-authorware-map');    {Do not Localize}
  AMIMEList.Add('.aas=application/x-authorware-seg');    {Do not Localize}
  AMIMEList.Add('.abw=application/x-abiword');    {Do not Localize}
  AMIMEList.Add('.ace=application/x-ace-compressed');  {Do not Localize}
  AMIMEList.Add('.ai=application/postscript');    {Do not Localize}
  AMIMEList.Add('.alz=application/x-alz-compressed');    {Do not Localize}
  AMIMEList.Add('.ani=application/x-navi-animation');   {Do not Localize}
  AMIMEList.Add('.arj=application/x-arj');    {Do not Localize}
  AMIMEList.Add('.asf=application/vnd.ms-asf');    {Do not Localize}
  AMIMEList.Add('.bat=application/x-msdos-program');    {Do not Localize}
  AMIMEList.Add('.bcpio=application/x-bcpio');    {Do not Localize}
  AMIMEList.Add('.boz=application/x-bzip2');     {Do not Localize}
  AMIMEList.Add('.bz=application/x-bzip');
  AMIMEList.Add('.bz2=application/x-bzip2');    {Do not Localize}
  AMIMEList.Add('.cab=application/vnd.ms-cab-compressed');    {Do not Localize}
  AMIMEList.Add('.cat=application/vnd.ms-pki.seccat');    {Do not Localize}
  AMIMEList.Add('.ccn=application/x-cnc');    {Do not Localize}
  AMIMEList.Add('.cco=application/x-cocoa');    {Do not Localize}
  AMIMEList.Add('.cdf=application/x-cdf');    {Do not Localize}
  AMIMEList.Add('.cer=application/x-x509-ca-cert');    {Do not Localize}
  AMIMEList.Add('.chm=application/vnd.ms-htmlhelp');    {Do not Localize}
  AMIMEList.Add('.chrt=application/vnd.kde.kchart');    {Do not Localize}
  AMIMEList.Add('.cil=application/vnd.ms-artgalry');    {Do not Localize}
  AMIMEList.Add('.class=application/java-vm');    {Do not Localize}
  AMIMEList.Add('.com=application/x-msdos-program');    {Do not Localize}
  AMIMEList.Add('.clp=application/x-msclip');    {Do not Localize}
  AMIMEList.Add('.cpio=application/x-cpio');    {Do not Localize}
  AMIMEList.Add('.cpt=application/mac-compactpro');    {Do not Localize}
  AMIMEList.Add('.cqk=application/x-calquick');    {Do not Localize}
  AMIMEList.Add('.crd=application/x-mscardfile');    {Do not Localize}
  AMIMEList.Add('.crl=application/pkix-crl');    {Do not Localize}
  AMIMEList.Add('.csh=application/x-csh');    {Do not Localize}
  AMIMEList.Add('.dar=application/x-dar');    {Do not Localize}
  AMIMEList.Add('.dbf=application/x-dbase');    {Do not Localize}
  AMIMEList.Add('.dcr=application/x-director');    {Do not Localize}
  AMIMEList.Add('.deb=application/x-debian-package');    {Do not Localize}
  AMIMEList.Add('.dir=application/x-director');    {Do not Localize}
  AMIMEList.Add('.dist=vnd.apple.installer+xml');    {Do not Localize}
  AMIMEList.Add('.distz=vnd.apple.installer+xml');    {Do not Localize}
  AMIMEList.Add('.dll=application/x-msdos-program');    {Do not Localize}
  AMIMEList.Add('.dmg=application/x-apple-diskimage');    {Do not Localize}
  AMIMEList.Add('.doc=application/msword');    {Do not Localize}
  AMIMEList.Add('.dot=application/msword');    {Do not Localize}
  AMIMEList.Add('.dvi=application/x-dvi');    {Do not Localize}
  AMIMEList.Add('.dxr=application/x-director');    {Do not Localize}
  AMIMEList.Add('.ebk=application/x-expandedbook');    {Do not Localize}
  AMIMEList.Add('.eps=application/postscript');    {Do not Localize}
  AMIMEList.Add('.evy=application/envoy');    {Do not Localize}
  AMIMEList.Add('.exe=application/x-msdos-program');    {Do not Localize}
  AMIMEList.Add('.fdf=application/vnd.fdf');    {Do not Localize}
  AMIMEList.Add('.fif=application/fractals');    {Do not Localize}
  AMIMEList.Add('.flm=application/vnd.kde.kivio');    {Do not Localize}
  AMIMEList.Add('.fml=application/x-file-mirror-list');    {Do not Localize}
  AMIMEList.Add('.gzip=application/x-gzip');  {Do not Localize}
  AMIMEList.Add('.gnumeric=application/x-gnumeric');    {Do not Localize}
  AMIMEList.Add('.gtar=application/x-gtar');    {Do not Localize}
  AMIMEList.Add('.gz=application/x-gzip');    {Do not Localize}
  AMIMEList.Add('.hdf=application/x-hdf');    {Do not Localize}
  AMIMEList.Add('.hlp=application/winhlp');    {Do not Localize}
  AMIMEList.Add('.hpf=application/x-icq-hpf');    {Do not Localize}
  AMIMEList.Add('.hqx=application/mac-binhex40');    {Do not Localize}
  AMIMEList.Add('.hta=application/hta');    {Do not Localize}
  AMIMEList.Add('.ims=application/vnd.ms-ims');    {Do not Localize}
  AMIMEList.Add('.ins=application/x-internet-signup');    {Do not Localize}
  AMIMEList.Add('.iii=application/x-iphone');    {Do not Localize}
  AMIMEList.Add('.iso=application/x-iso9660-image');    {Do not Localize}
  AMIMEList.Add('.jar=application/java-archive');    {Do not Localize}
  AMIMEList.Add('.karbon=application/vnd.kde.karbon');    {Do not Localize}
  AMIMEList.Add('.kfo=application/vnd.kde.kformula');    {Do not Localize}
  AMIMEList.Add('.kon=application/vnd.kde.kontour');    {Do not Localize}
  AMIMEList.Add('.kpr=application/vnd.kde.kpresenter');    {Do not Localize}
  AMIMEList.Add('.kpt=application/vnd.kde.kpresenter');    {Do not Localize}
  AMIMEList.Add('.kwd=application/vnd.kde.kword');    {Do not Localize}
  AMIMEList.Add('.kwt=application/vnd.kde.kword');    {Do not Localize}
  AMIMEList.Add('.latex=application/x-latex');    {Do not Localize}
  AMIMEList.Add('.lha=application/x-lzh');    {Do not Localize}
  AMIMEList.Add('.lcc=application/fastman');    {Do not Localize}
  AMIMEList.Add('.lrm=application/vnd.ms-lrm');    {Do not Localize}
  AMIMEList.Add('.lz=application/x-lzip');    {Do not Localize}
  AMIMEList.Add('.lzh=application/x-lzh');    {Do not Localize}
  AMIMEList.Add('.lzma=application/x-lzma');  {Do not Localize}
  AMIMEList.Add('.lzo=application/x-lzop'); {Do not Localize}
  AMIMEList.Add('.lzx=application/x-lzx');
  AMIMEList.Add('.m13=application/x-msmediaview');    {Do not Localize}
  AMIMEList.Add('.m14=application/x-msmediaview');    {Do not Localize}
  AMIMEList.Add('.mpp=application/vnd.ms-project');    {Do not Localize}
  AMIMEList.Add('.mvb=application/x-msmediaview');    {Do not Localize}
  AMIMEList.Add('.man=application/x-troff-man');    {Do not Localize}
  AMIMEList.Add('.mdb=application/x-msaccess');    {Do not Localize}
  AMIMEList.Add('.me=application/x-troff-me');    {Do not Localize}
  AMIMEList.Add('.ms=application/x-troff-ms');    {Do not Localize}
  AMIMEList.Add('.msi=application/x-msi');    {Do not Localize}
  AMIMEList.Add('.mpkg=vnd.apple.installer+xml');    {Do not Localize}
  AMIMEList.Add('.mny=application/x-msmoney');    {Do not Localize}
  AMIMEList.Add('.nix=application/x-mix-transfer');    {Do not Localize}
  AMIMEList.Add('.o=application/x-object');    {Do not Localize}
  AMIMEList.Add('.oda=application/oda');    {Do not Localize}
  AMIMEList.Add('.odb=application/vnd.oasis.opendocument.database');    {Do not Localize}
  AMIMEList.Add('.odc=application/vnd.oasis.opendocument.chart');    {Do not Localize}
  AMIMEList.Add('.odf=application/vnd.oasis.opendocument.formula');    {Do not Localize}
  AMIMEList.Add('.odg=application/vnd.oasis.opendocument.graphics');    {Do not Localize}
  AMIMEList.Add('.odi=application/vnd.oasis.opendocument.image');    {Do not Localize}
  AMIMEList.Add('.odm=application/vnd.oasis.opendocument.text-master');    {Do not Localize}
  AMIMEList.Add('.odp=application/vnd.oasis.opendocument.presentation');    {Do not Localize}
  AMIMEList.Add('.ods=application/vnd.oasis.opendocument.spreadsheet');    {Do not Localize}
  AMIMEList.Add('.ogg=application/ogg');    {Do not Localize}
  AMIMEList.Add('.odt=application/vnd.oasis.opendocument.text');    {Do not Localize}
  AMIMEList.Add('.otg=application/vnd.oasis.opendocument.graphics-template');    {Do not Localize}
  AMIMEList.Add('.oth=application/vnd.oasis.opendocument.text-web');    {Do not Localize}
  AMIMEList.Add('.otp=application/vnd.oasis.opendocument.presentation-template');    {Do not Localize}
  AMIMEList.Add('.ots=application/vnd.oasis.opendocument.spreadsheet-template');    {Do not Localize}
  AMIMEList.Add('.ott=application/vnd.oasis.opendocument.text-template');    {Do not Localize}
  AMIMEList.Add('.p10=application/pkcs10');    {Do not Localize}
  AMIMEList.Add('.p12=application/x-pkcs12');    {Do not Localize}
  AMIMEList.Add('.p7b=application/x-pkcs7-certificates');    {Do not Localize}
  AMIMEList.Add('.p7m=application/pkcs7-mime');    {Do not Localize}
  AMIMEList.Add('.p7r=application/x-pkcs7-certreqresp');    {Do not Localize}
  AMIMEList.Add('.p7s=application/pkcs7-signature');    {Do not Localize}
  AMIMEList.Add('.package=application/vnd.autopackage');    {Do not Localize}
  AMIMEList.Add('.pfr=application/font-tdpfr');    {Do not Localize}
  AMIMEList.Add('.pkg=vnd.apple.installer+xml');    {Do not Localize}
  AMIMEList.Add('.pdf=application/pdf');    {Do not Localize}
  AMIMEList.Add('.pko=application/vnd.ms-pki.pko');    {Do not Localize}
  AMIMEList.Add('.pl=application/x-perl');    {Do not Localize}
  AMIMEList.Add('.pnq=application/x-icq-pnq');    {Do not Localize}
  AMIMEList.Add('.pot=application/mspowerpoint');    {Do not Localize}
  AMIMEList.Add('.pps=application/mspowerpoint');    {Do not Localize}
  AMIMEList.Add('.ppt=application/mspowerpoint');    {Do not Localize}
  AMIMEList.Add('.ppz=application/mspowerpoint');    {Do not Localize}
  AMIMEList.Add('.ps=application/postscript');    {Do not Localize}
  AMIMEList.Add('.pub=application/x-mspublisher');    {Do not Localize}
  AMIMEList.Add('.qpw=application/x-quattropro');    {Do not Localize}
  AMIMEList.Add('.qtl=application/x-quicktimeplayer');    {Do not Localize}
  AMIMEList.Add('.rar=application/rar');    {Do not Localize}
  AMIMEList.Add('.rdf=application/rdf+xml');    {Do not Localize}
  AMIMEList.Add('.rjs=application/vnd.rn-realsystem-rjs');    {Do not Localize}
  AMIMEList.Add('.rm=application/vnd.rn-realmedia');    {Do not Localize}
  AMIMEList.Add('.rmf=application/vnd.rmf');    {Do not Localize}
  AMIMEList.Add('.rmp=application/vnd.rn-rn_music_package');    {Do not Localize}
  AMIMEList.Add('.rmx=application/vnd.rn-realsystem-rmx');    {Do not Localize}
  AMIMEList.Add('.rnx=application/vnd.rn-realplayer');    {Do not Localize}
  AMIMEList.Add('.rpm=application/x-redhat-package-manager');
  AMIMEList.Add('.rsml=application/vnd.rn-rsml');    {Do not Localize}
  AMIMEList.Add('.rtsp=application/x-rtsp');    {Do not Localize}
  AMIMEList.Add('.rss=application/rss+xml');    {Do not Localize}
  AMIMEList.Add('.scm=application/x-icq-scm');    {Do not Localize}
  AMIMEList.Add('.ser=application/java-serialized-object');    {Do not Localize}
  AMIMEList.Add('.scd=application/x-msschedule');    {Do not Localize}
  AMIMEList.Add('.sda=application/vnd.stardivision.draw');    {Do not Localize}
  AMIMEList.Add('.sdc=application/vnd.stardivision.calc');    {Do not Localize}
  AMIMEList.Add('.sdd=application/vnd.stardivision.impress');    {Do not Localize}
  AMIMEList.Add('.sdp=application/x-sdp');    {Do not Localize}
  AMIMEList.Add('.setpay=application/set-payment-initiation');    {Do not Localize}
  AMIMEList.Add('.setreg=application/set-registration-initiation');    {Do not Localize}
  AMIMEList.Add('.sh=application/x-sh');    {Do not Localize}
  AMIMEList.Add('.shar=application/x-shar');    {Do not Localize}
  AMIMEList.Add('.shw=application/presentations');    {Do not Localize}
  AMIMEList.Add('.sit=application/x-stuffit');    {Do not Localize}
  AMIMEList.Add('.sitx=application/x-stuffitx');  {Do not localize}
  AMIMEList.Add('.skd=application/x-koan');    {Do not Localize}
  AMIMEList.Add('.skm=application/x-koan');    {Do not Localize}
  AMIMEList.Add('.skp=application/x-koan');    {Do not Localize}
  AMIMEList.Add('.skt=application/x-koan');    {Do not Localize}
  AMIMEList.Add('.smf=application/vnd.stardivision.math');    {Do not Localize}
  AMIMEList.Add('.smi=application/smil');    {Do not Localize}
  AMIMEList.Add('.smil=application/smil');    {Do not Localize}
  AMIMEList.Add('.spl=application/futuresplash');    {Do not Localize}
  AMIMEList.Add('.ssm=application/streamingmedia');    {Do not Localize}
  AMIMEList.Add('.sst=application/vnd.ms-pki.certstore');    {Do not Localize}
  AMIMEList.Add('.stc=application/vnd.sun.xml.calc.template');    {Do not Localize}
  AMIMEList.Add('.std=application/vnd.sun.xml.draw.template');    {Do not Localize}
  AMIMEList.Add('.sti=application/vnd.sun.xml.impress.template');    {Do not Localize}
  AMIMEList.Add('.stl=application/vnd.ms-pki.stl');    {Do not Localize}
  AMIMEList.Add('.stw=application/vnd.sun.xml.writer.template');    {Do not Localize}
  AMIMEList.Add('.svi=application/softvision');    {Do not Localize}
  AMIMEList.Add('.sv4cpio=application/x-sv4cpio');    {Do not Localize}
  AMIMEList.Add('.sv4crc=application/x-sv4crc');    {Do not Localize}
  AMIMEList.Add('.swf=application/x-shockwave-flash');    {Do not Localize}
  AMIMEList.Add('.swf1=application/x-shockwave-flash');    {Do not Localize}
  AMIMEList.Add('.sxc=application/vnd.sun.xml.calc');    {Do not Localize}
  AMIMEList.Add('.sxi=application/vnd.sun.xml.impress');    {Do not Localize}
  AMIMEList.Add('.sxm=application/vnd.sun.xml.math');    {Do not Localize}
  AMIMEList.Add('.sxw=application/vnd.sun.xml.writer');    {Do not Localize}
  AMIMEList.Add('.sxg=application/vnd.sun.xml.writer.global');    {Do not Localize}
  AMIMEList.Add('.t=application/x-troff');    {Do not Localize}
  AMIMEList.Add('.tar=application/x-tar');    {Do not Localize}
  AMIMEList.Add('.tcl=application/x-tcl');    {Do not Localize}
  AMIMEList.Add('.tex=application/x-tex');    {Do not Localize}
  AMIMEList.Add('.texi=application/x-texinfo');    {Do not Localize}
  AMIMEList.Add('.texinfo=application/x-texinfo');    {Do not Localize}
  AMIMEList.Add('.tbz=application/x-bzip-compressed-tar');   {Do not Localize}
  AMIMEList.Add('.tbz2=application/x-bzip-compressed-tar');   {Do not Localize}
  AMIMEList.Add('.tgz=application/x-compressed-tar');    {Do not Localize}
  AMIMEList.Add('.tlz=application/x-lzma-compressed-tar');    {Do not Localize}
  AMIMEList.Add('.tr=application/x-troff');    {Do not Localize}
  AMIMEList.Add('.trm=application/x-msterminal');    {Do not Localize}
  AMIMEList.Add('.troff=application/x-troff');    {Do not Localize}
  AMIMEList.Add('.tsp=application/dsptype');    {Do not Localize}
  AMIMEList.Add('.torrent=application/x-bittorrent');    {Do not Localize}
  AMIMEList.Add('.ttz=application/t-time');    {Do not Localize}
  AMIMEList.Add('.txz=application/x-xz-compressed-tar'); {Do not localize}
  AMIMEList.Add('.udeb=application/x-debian-package');    {Do not Localize}
  AMIMEList.Add('.uin=application/x-icq');    {Do not Localize}
  AMIMEList.Add('.urls=application/x-url-list');    {Do not Localize}
  AMIMEList.Add('.ustar=application/x-ustar');    {Do not Localize}
  AMIMEList.Add('.vcd=application/x-cdlink');    {Do not Localize}
  AMIMEList.Add('.vor=application/vnd.stardivision.writer');    {Do not Localize}
  AMIMEList.Add('.vsl=application/x-cnet-vsl');    {Do not Localize}
  AMIMEList.Add('.wcm=application/vnd.ms-works');    {Do not Localize}
  AMIMEList.Add('.wb1=application/x-quattropro');    {Do not Localize}
  AMIMEList.Add('.wb2=application/x-quattropro');    {Do not Localize}
  AMIMEList.Add('.wb3=application/x-quattropro');    {Do not Localize}
  AMIMEList.Add('.wdb=application/vnd.ms-works');    {Do not Localize}
  AMIMEList.Add('.wks=application/vnd.ms-works');    {Do not Localize}
  AMIMEList.Add('.wmd=application/x-ms-wmd');    {Do not Localize}
  AMIMEList.Add('.wms=application/x-ms-wms');    {Do not Localize}
  AMIMEList.Add('.wmz=application/x-ms-wmz');    {Do not Localize}
  AMIMEList.Add('.wp5=application/wordperfect5.1');    {Do not Localize}
  AMIMEList.Add('.wpd=application/wordperfect');    {Do not Localize}
  AMIMEList.Add('.wpl=application/vnd.ms-wpl');    {Do not Localize}
  AMIMEList.Add('.wps=application/vnd.ms-works');    {Do not Localize}
  AMIMEList.Add('.wri=application/x-mswrite');    {Do not Localize}
  AMIMEList.Add('.xfdf=application/vnd.adobe.xfdf');    {Do not Localize}
  AMIMEList.Add('.xls=application/x-msexcel');    {Do not Localize}
  AMIMEList.Add('.xlb=application/x-msexcel');     {Do not Localize}
  AMIMEList.Add('.xpi=application/x-xpinstall');    {Do not Localize}
  AMIMEList.Add('.xps=application/vnd.ms-xpsdocument');    {Do not Localize}
  AMIMEList.Add('.xsd=application/vnd.sun.xml.draw');    {Do not Localize}
  AMIMEList.Add('.xul=application/vnd.mozilla.xul+xml');    {Do not Localize}
  AMIMEList.Add('.z=application/x-compress');    {Do not Localize}
  AMIMEList.Add('.zoo=application/x-zoo');    {Do not Localize}
  AMIMEList.Add('.zip=application/x-zip-compressed');    {Do not Localize}
  { WAP }
  AMIMEList.Add('.wbmp=image/vnd.wap.wbmp');    {Do not Localize}
  AMIMEList.Add('.wml=text/vnd.wap.wml');    {Do not Localize}
  AMIMEList.Add('.wmlc=application/vnd.wap.wmlc');    {Do not Localize}
  AMIMEList.Add('.wmls=text/vnd.wap.wmlscript');    {Do not Localize}
  AMIMEList.Add('.wmlsc=application/vnd.wap.wmlscriptc');    {Do not Localize}
  //of course, we have to add this :-).
  AMIMEList.Add('.asm=text/x-asm');   {Do not Localize}
  AMIMEList.Add('.p=text/x-pascal');    {Do not Localize}
  AMIMEList.Add('.pas=text/x-pascal');    {Do not Localize}
  AMIMEList.Add('.cs=text/x-csharp'); {Do not Localize}
  AMIMEList.Add('.c=text/x-csrc');    {Do not Localize}
  AMIMEList.Add('.c++=text/x-c++src');    {Do not Localize}
  AMIMEList.Add('.cpp=text/x-c++src');    {Do not Localize}
  AMIMEList.Add('.cxx=text/x-c++src');    {Do not Localize}
  AMIMEList.Add('.cc=text/x-c++src');    {Do not Localize}
  AMIMEList.Add('.h=text/x-chdr'); {Do not localize}
  AMIMEList.Add('.h++=text/x-c++hdr');    {Do not Localize}
  AMIMEList.Add('.hpp=text/x-c++hdr');    {Do not Localize}
  AMIMEList.Add('.hxx=text/x-c++hdr');    {Do not Localize}
  AMIMEList.Add('.hh=text/x-c++hdr');    {Do not Localize}
  AMIMEList.Add('.java=text/x-java');    {Do not Localize}
  { WEB }
  AMIMEList.Add('.css=text/css');    {Do not Localize}
  AMIMEList.Add('.js=text/javascript');    {Do not Localize}
  AMIMEList.Add('.htm=text/html');    {Do not Localize}
  AMIMEList.Add('.html=text/html');    {Do not Localize}
  AMIMEList.Add('.xhtml=application/xhtml+xml'); {Do not localize}
  AMIMEList.Add('.xht=application/xhtml+xml'); {Do not localize}
  AMIMEList.Add('.rdf=application/rdf+xml'); {Do not localize}
  AMIMEList.Add('.rss=application/rss+xml'); {Do not localize}
  AMIMEList.Add('.ls=text/javascript');    {Do not Localize}
  AMIMEList.Add('.mocha=text/javascript');    {Do not Localize}
  AMIMEList.Add('.shtml=server-parsed-html');    {Do not Localize}
  AMIMEList.Add('.xml=text/xml');    {Do not Localize}
  AMIMEList.Add('.sgm=text/sgml');    {Do not Localize}
  AMIMEList.Add('.sgml=text/sgml');    {Do not Localize}
  { Message }
  AMIMEList.Add('.mht=message/rfc822');    {Do not Localize}
  If not ALoadFromOS Then
   Exit;
  {$IFNDEF FPC}
  {$IFDEF WINDOWS}
  // Build the file type/MIME type map
  Reg := TRegistry.Create;
  Try
   KeyList := TStringList.create;
   Try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    If Reg.OpenKeyReadOnly('\') Then
     Begin  {do not localize}
      Reg.GetKeyNames(KeyList);
      Reg.Closekey;
     End;
    // get a list of registered extentions
    For i := 0 To KeyList.Count - 1 Do
     Begin
      LExt := KeyList[i];
      If TextStartsWith(LExt, '.') Then
       Begin  {do not localize}
        If Reg.OpenKeyReadOnly(LExt) Then
         Begin
          s := Reg.ReadString('Content Type');  {do not localize}
          If Length(s) > 0 Then
           AMIMEList.Values[Lowercase(LExt)] := Lowercase(s);
          Reg.CloseKey;
         End;
       End;
      If Reg.OpenKeyReadOnly('\MIME\Database\Content Type') Then
       Begin {do not localize}
        // get a list of registered MIME types
        KeyList.Clear;
        Reg.GetKeyNames(KeyList);
        Reg.CloseKey;
        For i := 0 To KeyList.Count - 1 Do
         Begin
          If Reg.OpenKeyReadOnly('\MIME\Database\Content Type\' + KeyList[i]) Then
           Begin {do not localize}
            LExt := Lowercase(Reg.ReadString('Extension'));  {do not localize}
            If Length(LExt) > 0 Then
             Begin
              If LExt[1] <> '.' Then
               LExt := '.' + LExt; {do not localize}
              AMIMEList.Values[LExt] := Lowercase(KeyList[i]);
             End;
            Reg.CloseKey;
           End;
         End;
       End;
     End;
   Finally
    KeyList.Free;
   End;
  Finally
   Reg.Free;
  End;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF UNIX}
   LoadMIME('/etc/mime.types', AMIMEList);                   {do not localize}
   LoadMIME('/etc/htdig/mime.types', AMIMEList);             {do not localize}
   LoadMIME('/etc/usr/share/webmin/mime.types', AMIMEList);  {do not localize}
  {$ENDIF}
 End;
Begin
 LKeys := TStringList.Create;
 Try
  FillMIMETable(LKeys, LoadTypesFromOS);
  LoadFromStrings(LKeys);
 Finally
  FreeAndNil(LKeys);
 End;
End;

Constructor TMimeTable.Create(Const AutoFill : Boolean);
Begin
 Inherited Create;
 FLoadTypesFromOS := True;
 FFileExt := TStringList.Create;
 FMIMEList := TStringList.Create;
 If AutoFill Then
  BuildCache;
End;

Destructor TMimeTable.Destroy;
Begin
 FreeAndNil(FMIMEList);
 FreeAndNil(FFileExt);
 Inherited Destroy;
End;

end.
