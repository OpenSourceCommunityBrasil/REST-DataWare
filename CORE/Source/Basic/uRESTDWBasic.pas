unit uRESTDWBasic;

{$I ..\Source\Includes\uRESTDWPlataform.inc}

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

interface

Uses
 {$IFDEF FPC}
 SysUtils,      Classes, Db, Variants, {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
 uRESTDWConsts, DataUtils, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
 uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWAbout
 {$ELSE}
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, Db, Variants, EncdDecd, SyncObjs, DataUtils, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWAbout
  {$ELSE}
   System.SysUtils, System.Classes, Data.Db, Variants, system.SyncObjs, DataUtils, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWAbout,
   {$IF Defined(RESTDWFMX)}{$IFNDEF RESTDWAndroidService}FMX.Forms,{$ENDIF}
   {$ELSE}
    {$IF CompilerVersion <= 22}Forms,
     {$ELSE}VCL.Forms,
    {$IFEND}
   {$IFEND}
   uRESTDWCharset
   {$IFDEF RESTDWWINDOWS}
    , Windows
   {$ENDIF}
   , uRESTDWConsts
  {$IFEND}
 {$ENDIF};

 Type
  TServerMethodClass = Class(TComponent)
 End;

 Type
  TClassNull= Class(TComponent)
 End;

Type
 TRESTDWDriver    = Class(TRESTDWComponent)
 Private
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vEncodeStrings,
  vCompression         : Boolean;
  vEncoding            : TEncodeSelect;
  vCommitRecords       : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  vParamCreate         : Boolean;
  vOnPrepareConnection : TOnPrepareConnection;
  vOnTableBeforeOpen   : TOnTableBeforeOpen;
  vOnQueryBeforeOpen   : TOnQueryBeforeOpen;
  vOnQueryException    : TOnQueryException;
 Public
  Function  ConnectionSet                                   : Boolean;         Virtual;Abstract;
  Function  GetGenID                  (Query                : TComponent;
                                       GenName              : String): Integer;Virtual;Abstract;
  Constructor Create                  (AOwner               : TComponent);Override; //Cria o Componente
  Function ApplyUpdates               (Massive,
                                       SQL                  : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var RowsAffected     : Integer) : TJSONValue;     Virtual;Abstract;
  Function ApplyUpdates_MassiveCache  (MassiveCache         : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String) : TJSONValue;     Virtual;Abstract;
  Function ProcessMassiveSQLCache     (MassiveSQLCache      : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String) : TJSONValue;     Virtual;Abstract;
  Function ApplyUpdatesTB             (Massive              : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var RowsAffected     : Integer) : TJSONValue;     Virtual;Abstract;
  Function ApplyUpdates_MassiveCacheTB(MassiveCache         : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String) : TJSONValue;     Virtual;Abstract;
  Function ExecuteCommandTB           (Tablename            : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function ExecuteCommandTB           (Tablename            : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function ExecuteCommand             (SQL                  : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       Execute              : Boolean = False;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function ExecuteCommand             (SQL                  : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream;
                                       Var RowsAffected     : Integer;
                                       Execute              : Boolean = False;
                                       BinaryEvent          : Boolean = False;
                                       MetaData             : Boolean = False;
                                       BinaryCompatibleMode : Boolean = False) : String;Overload;Virtual;Abstract;
  Function InsertMySQLReturnID        (SQL                  : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String)        : Integer;Overload;Virtual;Abstract;
  Function InsertMySQLReturnID        (SQL                  : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String)        : Integer;Overload;Virtual;Abstract;
  Procedure ExecuteProcedure          (ProcName             : String;
                                       Params               : TRESTDWParams;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure ExecuteProcedurePure      (ProcName             : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Function  OpenDatasets              (DatasetsLine         : String;
                                       Var Error            : Boolean;
                                       Var MessageError     : String;
                                       Var BinaryBlob       : TMemoryStream) : TJSONValue; Virtual;Abstract;
  Procedure GetTableNames             (Var TableNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetFieldNames             (TableName            : String;
                                       Var FieldNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetKeyFieldNames          (TableName            : String;
                                       Var FieldNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetProcNames              (Var ProcNames        : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Procedure GetProcParams             (ProcName             : String;
                                       Var ParamNames       : TStringList;
                                       Var Error            : Boolean;
                                       Var MessageError     : String);                  Virtual;Abstract;
  Class Procedure CreateConnection    (Const ConnectionDefs : TConnectionDefs;
                                       Var Connection       : TObject);                 Virtual;Abstract;
  Procedure PrepareConnection         (Var ConnectionDefs   : TConnectionDefs);         Virtual;Abstract;
  Procedure Close;Virtual;abstract;
  Procedure BuildDatasetLine          (Var Query            : TDataset;
                                       Massivedataset       : TMassivedatasetBuffer;
                                       MassiveCache         : Boolean = False);
  Property StrsTrim                  : Boolean              Read vStrsTrim              Write vStrsTrim;
  Property StrsEmpty2Null            : Boolean              Read vStrsEmpty2Null        Write vStrsEmpty2Null;
  Property StrsTrim2Len              : Boolean              Read vStrsTrim2Len          Write vStrsTrim2Len;
  Property Compression               : Boolean              Read vCompression           Write vCompression;
  Property EncodeStringsJSON         : Boolean              Read vEncodeStrings         Write vEncodeStrings;
  Property Encoding                  : TEncodeSelect        Read vEncoding              Write vEncoding;
  property ParamCreate               : Boolean              Read vParamCreate           Write vParamCreate;
 Published
 {$IFDEF FPC}
  Property DatabaseCharSet           : TDatabaseCharSet     Read vDatabaseCharSet       Write vDatabaseCharSet;
 {$ENDIF}
  Property CommitRecords             : Integer              Read vCommitRecords         Write vCommitRecords;
  Property OnPrepareConnection       : TOnPrepareConnection Read vOnPrepareConnection   Write vOnPrepareConnection;
  Property OnTableBeforeOpen         : TOnTableBeforeOpen   Read vOnTableBeforeOpen     Write vOnTableBeforeOpen;
  Property OnQueryBeforeOpen         : TOnQueryBeforeOpen   Read vOnQueryBeforeOpen     Write vOnQueryBeforeOpen;
  Property OnQueryException          : TOnQueryException    Read vOnQueryException      Write vOnQueryException;
End;

Type
 TRESTDWConnectionServerCP = Class(TCollectionItem)
 Private
  vAuthentication,
  vEncodeStrings,
  vCompression,
  vActive               : Boolean;
  vTimeOut,
  vConnectTimeOut,
  vPoolerPort           : Integer;
  vDataRoute,
  vServerContext,
  vServerEventName,
  vListName,
  vAccessTag,
  vWelcomeMessage,
  vRestURL,
  vRestWebService       : String;
  vAuthOptionParams     : TRESTDWClientAuthOptionParams;
  vEncoding             : TEncodeSelect;
  {$IFDEF FPC}
  vDatabaseCharSet      : TDatabaseCharSet;
  {$ENDIF}
  vTypeRequest          : TTypeRequest;
  vCripto               : TCripto;
  Procedure SetCripto(Value : TCripto);
 Public
  Function    GetDisplayName             : String;      Override;
  Procedure   SetDisplayName(Const Value : String);     Override;
  Function    GetPoolerList : TStringList;
  Constructor Create        (aCollection : TCollection);Override;
  Destructor  Destroy;Override;//Destroy a Classe
 Published
  Property Active                : Boolean                    Read vActive               Write vActive;            //Seta o Estado da Conexão
  Property Compression           : Boolean                    Read vCompression          Write vCompression;       //Compressão de Dados
  Property CriptOptions          : TCripto                    Read vCripto               Write SetCripto;
  Property AuthenticationOptions : TRESTDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property Authentication        : Boolean                    Read vAuthentication       Write vAuthentication      Default True;
  Property Host                  : String                     Read vRestWebService       Write vRestWebService;    //Host do WebService REST
  Property UrlPath               : String                     Read vRestURL              Write vRestURL;           //URL do WebService REST
  Property Port                  : Integer                    Read vPoolerPort           Write vPoolerPort;        //A Porta do Pooler do DataSet
  Property RequestTimeOut        : Integer                    Read vTimeOut              Write vTimeOut;           //Timeout da Requisição
  Property ConnectTimeOut        : Integer                    Read vConnectTimeOut       Write vConnectTimeOut;
  Property hEncodeStrings        : Boolean                    Read vEncodeStrings        Write vEncodeStrings;
  Property Encoding              : TEncodeSelect              Read vEncoding             Write vEncoding;          //Encoding da string
  Property WelcomeMessage        : String                     Read vWelcomeMessage       Write vWelcomeMessage;
  {$IFDEF FPC}
  Property DatabaseCharSet       : TDatabaseCharSet           Read vDatabaseCharSet      Write vDatabaseCharSet;
  {$ENDIF}
  Property Name                  : String                     Read vListName             Write vListName;
  Property AccessTag             : String                     Read vAccessTag            Write vAccessTag;
  Property TypeRequest           : TTypeRequest               Read vTypeRequest          Write vTypeRequest       Default trHttp;
  Property ServerEventName       : String                     Read vServerEventName      Write vServerEventName;
  Property DataRoute             : String                     Read vDataRoute            Write vDataRoute;
  Property ServerContext         : String                     Read vServerContext        Write vServerContext;
End;

Type
 TOnFailOverExecute       = Procedure (ConnectionServer   : TRESTDWConnectionServerCP) Of Object;
 TOnFailOverError         = Procedure (ConnectionServer   : TRESTDWConnectionServerCP;
                                       MessageError       : String)                  Of Object;

Type
 TFailOverConnections = Class(TRESTDWOwnedCollection)
 Private
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec     (Index       : Integer) : TRESTDWConnectionServerCP;  Overload;
  Procedure   PutRec     (Index       : Integer;
                          Item        : TRESTDWConnectionServerCP);            Overload;
  Function    GetRecName(Index        : String)  : TRESTDWConnectionServerCP;  Overload;
  Procedure   PutRecName(Index        : String;
                         Item         : TRESTDWConnectionServerCP);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    Add                     : TCollectionItem;
  Procedure   Delete     (Index       : Integer);  Overload;
  Procedure   Delete     (Index       : String);   Overload;
  Property    Items      [Index       : Integer] : TRESTDWConnectionServerCP Read GetRec     Write PutRec; Default;
  Property    ItemsByName[Index       : String ] : TRESTDWConnectionServerCP Read GetRecName Write PutRecName;
End;

Type
 TRESTClientPoolerBase = Class(TRESTDWComponent) //Novo Componente de Acesso a Requisições REST para o RESTDataware
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  vCripto           : TCripto;
  Procedure SetOnWork      (Value             : TOnWork);
  Procedure SetOnWorkBegin (Value             : TOnWorkBegin);
  Procedure SetOnWorkEnd   (Value             : TOnWorkEnd);
  Procedure SetOnStatus    (Value             : TOnStatus);
  Function  GetAllowCookies                   : Boolean;
  Procedure SetAllowCookies(Value             : Boolean);
 Private
  //Variáveis, Procedures e Funções Privadas
  vOnWork              : TOnWork;
  vOnWorkBegin         : TOnWorkBegin;
  vOnWorkEnd           : TOnWorkEnd;
  vOnStatus            : TOnStatus;
  vOnFailOverExecute   : TOnFailOverExecute;
  vOnFailOverError     : TOnFailOverError;
  vOnBeforeExecute     : TOnBeforeExecute;
  vOnBeforeGetToken    : TOnBeforeGetToken;
  vTypeRequest         : TTypeRequest;
  vRSCharset           : TEncodeSelect;
  vAuthOptionParams    : TRESTDWClientAuthOptionParams;
  vDataRoute,
  vUserAgent,
  vAccessTag,
  vWelcomeMessage,
  vPoolerNotFoundMessage,
  vServerContext,
  vUrlPath,
  vHost                : String;
  vRedirectMaximum,
  vErrorCode,
  vPort                : Integer;
  vPropThreadRequest,
  vBinaryRequest,
  vFailOver,
  vFailOverReplaceDefaults,
  vEncodeStrings,
  vDatacompress,
  vAuthentication      : Boolean;
  vRequestTimeOut      : Integer;
  vConnectTimeOut      : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  vFailOverConnections : TFailOverConnections;
  Procedure SetUrlPath (Value : String);
  Procedure ReconfigureConnection(Var Connection        : TRESTClientPoolerBase;
                                  TypeRequest           : Ttyperequest;
                                  WelcomeMessage,
                                  Host                  : String;
                                  Port                  : Integer;
                                  Compression,
                                  EncodeStrings         : Boolean;
                                  Encoding              : TEncodeSelect;
                                  AccessTag             : String;
                                  AuthenticationOptions : TRESTDWClientAuthOptionParams);
 Public
  //Métodos, Propriedades, Variáveis, Procedures e Funções Publicas
  Procedure   NewToken;
  Function    RenewToken  (Var Params       : TRESTDWParams;
                           Var Error        : Boolean;
                           Var MessageError : String) : String;
  Procedure   SetAccessTag(Value            : String);
  Function    GetAccessTag                  : String;
  Function    SendEvent   (EventData        : String)          : String;Overload;
  Function    SendEvent   (EventData        : String;
                           Var Params       : TRESTDWParams;
                           EventType        : TSendEvent = sePOST;
                           JsonMode         : TJsonMode  = jmDataware;
                           ServerEventName  : String     = '';
                           Assyncexec       : Boolean    = False) : String;Overload;
  Procedure   SetAuthOptionParams(Value     : TRESTDWClientAuthOptionParams);
  Constructor Create      (AOwner           : TComponent);Override;
  Destructor  Destroy;Override;
  Procedure   Abort;Virtual;Abstract;
  Property    ErrorCode            : Integer                    Read vErrorCode;
 Published
  //Métodos e Propriedades
  Property DataCompression         : Boolean                       Read vDatacompress            Write vDatacompress;
  Property UrlPath                 : String                        Read vUrlPath                 Write SetUrlPath;
  Property ServerContext           : String                        Read vServerContext           Write vServerContext;
  Property DataRoute               : String                        Read vDataRoute               Write vDataRoute;
  Property Encoding                : TEncodeSelect                 Read vRSCharset               Write vRSCharset;
  Property EncodedStrings          : Boolean                       Read vEncodeStrings           Write vEncodeStrings;
  Property TypeRequest             : TTypeRequest                  Read vTypeRequest             Write vTypeRequest         Default trHttp;
  Property ThreadRequest           : Boolean                       Read vPropThreadRequest       Write vPropThreadRequest;
  Property Host                    : String                        Read vHost                    Write vHost;
  Property Port                    : Integer                       Read vPort                    Write vPort                Default 8082;
  Property AuthenticationOptions   : TRESTDWClientAuthOptionParams Read vAuthOptionParams        Write SetAuthOptionParams;
  Property RequestTimeOut          : Integer                       Read vRequestTimeOut          Write vRequestTimeOut;
  Property ConnectTimeOut          : Integer                       Read vConnectTimeOut          Write vConnectTimeOut;
  Property AllowCookies            : Boolean                       Read GetAllowCookies          Write SetAllowCookies;
  Property RedirectMaximum         : Integer                       Read vRedirectMaximum         Write vRedirectMaximum;
  Property WelcomeMessage          : String                        Read vWelcomeMessage          Write vWelcomeMessage;
  Property AccessTag               : String                        Read vAccessTag               Write vAccessTag;
  Property OnWork                  : TOnWork                       Read vOnWork                  Write SetOnWork;
  Property OnWorkBegin             : TOnWorkBegin                  Read vOnWorkBegin             Write SetOnWorkBegin;
  Property OnWorkEnd               : TOnWorkEnd                    Read vOnWorkEnd               Write SetOnWorkEnd;
  Property OnStatus                : TOnStatus                     Read vOnStatus                Write SetOnStatus;
  Property OnFailOverExecute       : TOnFailOverExecute            Read vOnFailOverExecute       Write vOnFailOverExecute;
  Property OnFailOverError         : TOnFailOverError              Read vOnFailOverError         Write vOnFailOverError;
  Property OnBeforeExecute         : TOnBeforeExecute              Read vOnBeforeExecute         Write vOnBeforeExecute;
  Property OnBeforeGetToken        : TOnBeforeGetToken             Read vOnBeforeGetToken        Write vOnBeforeGetToken;
  Property FailOver                : Boolean                       Read vFailOver                Write vFailOver;
  Property FailOverConnections     : TFailOverConnections          Read vFailOverConnections     Write vFailOverConnections;
  Property FailOverReplaceDefaults : Boolean                       Read vFailOverReplaceDefaults Write vFailOverReplaceDefaults;
  Property BinaryRequest           : Boolean                       Read vBinaryRequest           Write vBinaryRequest;
  Property CriptOptions            : TCripto                       Read vCripto                  Write vCripto;
  Property UserAgent               : String                        Read vUserAgent               Write vUserAgent;
  Property PoolerNotFoundMessage   : String                        Read vPoolerNotFoundMessage   Write vPoolerNotFoundMessage;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet              Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
End;

 Type
  TRESTDWServiceNotificationBase = Class(TRESTDWComponent)
  Private
   vLoginMessage                  : String;
   vMultiCORE,
   vForceWelcomeAccess,
   vActive                        : Boolean;
   vServicePort,
   vServiceTimeout                : Integer;
   aServerMethod                  : TComponentClass;
   vServerAuthOptions             : TRESTDWServerAuthOptionParams;
   vOnDisconnect,
   vOnConnect,
   vOnAuthAccept                  : TRESTDWOnSessionData;
   vReceiveMessage,
   vLastRequest                   : TLastSockRequest;
   vReceiveStream                 : TLastSockStream;
   vLastResponse                  : TLastSockResponse;
   vOnConnectionRename            : TConnectionRename;
   vEncoding                      : TEncodeSelect;
   vCripto                        : TCripto;
   vProxyOptions                  : TProxyOptions;
   vAccessTag                     : String;
   vGarbageTime                   : Integer;
   vNotifyWelcomeMessage          : TNotifyWelcomeMessage;
   vRESTDwAuthError               : TRESTDWAuthError;
   {$IFDEF FPC}
   vDatabaseCharSet               : TDatabaseCharSet;
   {$ENDIF}
   Procedure  ProcessMessages;
   Procedure  SetAccessTag(Value  : String);
   Function   GetAccessTag        : String;
   Procedure  SetActive (Value    : Boolean);Virtual;Abstract;
   Procedure  Disconnect(AContext : TComponent);Virtual;Abstract;
   Procedure  Connect   (AContext : TComponent);Virtual;Abstract;
   Procedure  SetServerAuthOptions(AuthenticationOptions : TRESTDWServerAuthOptionParams);
   Procedure  SetServerMethod(Value                      : TComponentClass);
  Public
   Procedure   Execute            (AContext      : TComponent);Virtual;Abstract;
   Constructor Create             (AOwner        : TComponent);Override; //Cria o Componente
   Destructor  Destroy;Override; //Destroy a Classe
   Function    SendMessage     (aUser            : String;
                                aMessage         : String;
                                Var ErrorMessage : String) : Boolean;Virtual;Abstract;
   Function    SendStream      (aUserSource,
                                aUserDest        : String;
                                Var aStream      : TMemoryStream;
                                Var ErrorMessage : String) : Boolean;Virtual;Abstract;
   Procedure   BroadcastMessage(aMessage : String);Overload;Virtual;Abstract;
   Procedure   BroadcastStream (Var aStream    : TMemoryStream);Virtual;Abstract;
   Procedure   Kickall;Virtual;Abstract;
   Procedure   Kickuser        (aUser          : String);Virtual;Abstract;
  Published
   Property Active                : Boolean                    Read vActive                Write SetActive;
   Property ForceWelcomeAccess    : Boolean                    Read vForceWelcomeAccess    Write vForceWelcomeAccess;
   Property AuthenticationOptions : TRESTDWServerAuthOptionParams Read vServerAuthOptions     Write SetServerAuthOptions;
   Property ServerMethodClass     : TComponentClass            Read aServerMethod          Write SetServerMethod;
   Property Encoding              : TEncodeSelect              Read vEncoding              Write vEncoding;          //Encoding da string
   {$IFDEF FPC}
   Property DatabaseCharSet       : TDatabaseCharSet           Read vDatabaseCharSet       Write vDatabaseCharSet;
   {$ENDIF}
   Property CriptOptions          : TCripto                    Read vCripto                Write vCripto;
   Property MultiCORE             : Boolean                    Read vMultiCORE             Write vMultiCORE;
   Property RequestTimeout        : Integer                    Read vServiceTimeout        Write vServiceTimeout;
   Property ServicePort           : Integer                    Read vServicePort           Write vServicePort;  //A Porta do Serviço do DataSet
   Property ProxyOptions          : TProxyOptions              Read vProxyOptions          Write vProxyOptions; //Se tem Proxy diz quais as opções
   Property GarbageTime           : Integer                    Read vGarbageTime           Write vGarbageTime;
   Property AccessTag             : String                     Read vAccessTag             Write vAccessTag;
   Property LoginMessage          : String                     Read vLoginMessage          Write vLoginMessage;
   Property OnConnect             : TRESTDWOnSessionData       Read vOnConnect             Write vOnConnect;
   Property OnDisconnect          : TRESTDWOnSessionData       Read vOnDisconnect          Write vOnDisconnect;
   Property OnAuthAccept          : TRESTDWOnSessionData       Read vOnAuthAccept          Write vOnAuthAccept;
   Property OnAuthError           : TRESTDWAuthError           Read vRESTDwAuthError       Write vRESTDwAuthError;
   Property OnWelcomeMessage      : TNotifyWelcomeMessage      Read vNotifyWelcomeMessage  Write vNotifyWelcomeMessage;
   Property OnReceiveMessage      : TLastSockRequest           Read vReceiveMessage        Write vReceiveMessage;
   Property OnReceiveStream       : TLastSockStream            Read vReceiveStream         Write vReceiveStream;
   Property OnLastRequest         : TLastSockRequest           Read vLastRequest           Write vLastRequest;
   Property OnLastResponse        : TLastSockResponse          Read vLastResponse          Write vLastResponse;
   Property OnConnectionRename    : TConnectionRename          Read vOnConnectionRename    Write vOnConnectionRename;
 End;

Type
 TRESTServiceBase = Class(TRESTDWComponent)
 Protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Private
  {$IFDEF FPC}
   vCriticalSection    : TRTLCriticalSection;
   vDatabaseCharSet    : TDatabaseCharSet;
  {$ELSE}
   {$IF CompilerVersion > 21}
    {$IFDEF WINDOWS}
     vCriticalSection : TRTLCriticalSection;
    {$ELSE}
     vCriticalSection : TCriticalSection;
    {$ENDIF}
   {$ELSE}
    vCriticalSection : TCriticalSection;
   {$IFEND}
  {$ENDIF}
  vBeforeUseCriptKey   : TBeforeUseCriptKey;
  vCORSCustomHeaders,
  vDefaultPage         : TStringList;
  vPathTraversalRaiseError,
  vForceWelcomeAccess,
  vCORS,
  vActive              : Boolean;
  vProxyOptions        : TProxyOptions;
  vServiceTimeout,
  vServicePort         : Integer;
  vCripto              : TCripto;
  aServerMethod        : TComponentClass;
  vDataRouteList       : TRESTDWDataRouteList;
  vServerAuthOptions   : TRESTDWServerAuthOptionParams;
  vLastRequest         : TLastRequest;
  vLastResponse        : TLastResponse;
  vServerContext,
  FRootPath,
  aDefaultUrl          : String;
  vEncoding            : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vOnCreate            : TOnCreate;
  Procedure SetServerContext(Value : String);
  Procedure SetCORSCustomHeader (Value : TStringList);
  Procedure SetDefaultPage (Value : TStringList);
  Procedure SetActive      (Value                     : Boolean);Virtual;Abstract;
  Procedure SetServerMethod(Value                     : TComponentClass);
  Procedure Loaded; Override;
  Procedure GetTableNames            (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetFieldNames            (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetKeyFieldNames         (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetPoolerList            (ServerMethodsClass      : TComponent;
                                      Var PoolerList          : String;
                                      AccessTag               : String);
  Function  ServiceMethods           (BaseObject              : TComponent;
                                      AContext                : TComponent;
                                      Var UriOptions          : TRESTDWUriOptions;
                                      Var DWParams            : TRESTDWParams;
                                      Var JSONStr             : String;
                                      Var JsonMode            : TJsonMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType         : String;
                                      Var ServerContextCall   : Boolean;
                                      Var ServerContextStream : TMemoryStream;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      WelcomeAccept           : Boolean;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean;
                                      CompareContext          : Boolean) : Boolean;
  Procedure EchoPooler               (ServerMethodsClass      : TComponent;
                                      AContext                : TComponent;
                                      Var Pooler, MyIP        : String;
                                      AccessTag               : String;
                                      Var InvalidTag          : Boolean);Virtual;Abstract;
  Procedure ExecuteCommandPureJSON   (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandPureJSONTB (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSON       (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSONTB     (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure InsertMySQLReturnID      (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSON         (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSONTB       (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure OpenDatasets             (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryRequest           : Boolean);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdates_MassiveCacheTB(ServerMethodsClass    : TComponent;
                                        Var Pooler            : String;
                                        Var DWParams          : TRESTDWParams;
                                        ConnectionDefs        : TConnectionDefs;
                                        hEncodeStrings        : Boolean;
                                        AccessTag             : String);
  Procedure   ProcessMassiveSQLCache (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TRESTDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure   GetEvents              (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var DWParams            : TRESTDWParams);
  Function    ReturnEvent            (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var vResult             : String;
                                      Var DWParams            : TRESTDWParams;
                                      Var JsonMode            : TJsonMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType,
                                      AccessTag               : String;
                                      Const RequestType       : TRequestType;
                                      Var   RequestHeader     : TStringList) : Boolean;
  Procedure   GetServerEventsList    (ServerMethodsClass      : TComponent;
                                      Var ServerEventsList    : String;
                                      AccessTag               : String);
  Function    ReturnContext          (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var vResult,
                                      ContentType             : String;
                                      Var ServerContextStream : TMemoryStream;
                                      Var Error               : Boolean;
                                      Var   DWParams          : TRESTDWParams;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      Var ErrorCode           : Integer) : Boolean;
  Procedure   SetServerAuthOptions   (AuthenticationOptions   : TRESTDWServerAuthOptionParams);
 Public
  Procedure   CommandExec  (AContext      : TObject;
                            ARequestInfo  : TObject;
                            AResponseInfo : TObject);Virtual;Abstract;
  Procedure   ClearDataRoute;
  Procedure   AddDataRoute(DataRoute : String; MethodClass : TComponentClass);
  Constructor Create       (AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                      //Destroy a Classe
 Published
  Property Active                  : Boolean                    Read vActive                  Write SetActive;
  Property CORS                    : Boolean                    Read vCORS                    Write vCORS;
  Property CORS_CustomHeaders      : TStringList                Read vCORSCustomHeaders       Write SetCORSCustomHeader;
  Property DefaultPage             : TStringList                Read vDefaultPage             Write SetDefaultPage;
  Property DefaultBaseContext      : String                     Read aDefaultUrl              Write aDefaultUrl;
  Property PathTraversalRaiseError : Boolean                    Read vPathTraversalRaiseError Write vPathTraversalRaiseError;
  Property RequestTimeout          : Integer                    Read vServiceTimeout          Write vServiceTimeout;
  Property ServicePort             : Integer                    Read vServicePort             Write vServicePort;  //A Porta do Serviço do DataSet
  Property ProxyOptions            : TProxyOptions              Read vProxyOptions            Write vProxyOptions; //Se tem Proxy diz quais as opções
  Property AuthenticationOptions   : TRESTDWServerAuthOptionParams Read vServerAuthOptions       Write SetServerAuthOptions;
  Property ServerMethodClass       : TComponentClass            Read aServerMethod            Write SetServerMethod;
  Property OnLastRequest           : TLastRequest               Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse              Read vLastResponse            Write vLastResponse;
  Property Encoding                : TEncodeSelect              Read vEncoding                Write vEncoding;          //Encoding da string
  Property ServerContext           : String                     Read vServerContext           Write SetServerContext;
  Property RootPath                : String                     Read FRootPath                Write FRootPath;
  Property ForceWelcomeAccess      : Boolean                    Read vForceWelcomeAccess      Write vForceWelcomeAccess;
  Property OnBeforeUseCriptKey     : TBeforeUseCriptKey         Read vBeforeUseCriptKey       Write vBeforeUseCriptKey;
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet           Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
  Property OnCreate                : TOnCreate                  Read vOnCreate                Write vOnCreate;
End;

//Heranças para Servidores Standalone
Type
 TRESTServicePoolerBase = Class(TRESTServiceBase)
 Protected
 Private
 Public
 Published
End;

//Heranças para Servidores CGI/Isapi
Type
 TRESTServiceShareBase    = Class(TRESTServiceBase)
 Protected
  Property ServicePort;
  Property ProxyOptions;
  Property Active;
 Private
 Public
  Constructor Create(AOwner: TComponent);Override;
 Published
End;

//PoolerDB Control
Type
 TRESTDWPoolerDBP = ^TRESTDWComponent;
 TRESTDWPoolerDB  = Class(TRESTDWComponent)
 Private
  FLock          : TCriticalSection;
  vRESTDriver    : TRESTDWDriver;
  vActive,
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vCompression   : Boolean;
  vEncoding      : TEncodeSelect;
  vAccessTag,
  vMessagePoolerOff : String;
  vParamCreate   : Boolean;
  Procedure SetConnection(Value : TRESTDWDriver);
  Function  GetConnection  : TRESTDWDriver;
 protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Function ExecuteCommand(SQL              : String;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Var BinaryBlob   : TMemoryStream;
                          Var RowsAffected : Integer;
                          Execute          : Boolean = False) : String;Overload;
  Function ExecuteCommand(SQL              : String;
                          Params           : TRESTDWParams;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Var BinaryBlob   : TMemoryStream;
                          Var RowsAffected : Integer;
                          Execute          : Boolean = False) : String;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Params           : TRESTDWParams;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Procedure ExecuteProcedure  (ProcName         : String;
                               Params           : TRESTDWParams;
                               Var Error        : Boolean;
                               Var MessageError : String);
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                     //Destroy a Classe
 Published
  Property    RESTDriver       : TRESTDWDriver Read GetConnection     Write SetConnection;
  Property    Compression      : Boolean       Read vCompression      Write vCompression;
  Property    Encoding         : TEncodeSelect Read vEncoding         Write vEncoding;
  Property    StrsTrim         : Boolean       Read vStrsTrim         Write vStrsTrim;
  Property    StrsEmpty2Null   : Boolean       Read vStrsEmpty2Null   Write vStrsEmpty2Null;
  Property    StrsTrim2Len     : Boolean       Read vStrsTrim2Len     Write vStrsTrim2Len;
  Property    Active           : Boolean       Read vActive           Write vActive;
  Property    PoolerOffMessage : String        Read vMessagePoolerOff Write vMessagePoolerOff;
  Property    AccessTag        : String        Read vAccessTag        Write vAccessTag;
  Property    ParamCreate      : Boolean       Read vParamCreate      Write vParamCreate;
End;

Implementation

Uses uRESTDWDatamodule, uRESTDWPoolermethod, uRESTDWTools, uRESTDWServerEvents, uRESTDWServerContext;

Procedure TRESTDWServiceNotificationBase.ProcessMessages;
Begin
 {$IFNDEF FPC}
  {$IF Defined(RESTDWFMX)}
   {$IF Defined(RESTDWWINDOWS)}
    FMX.Forms.TApplication.ProcessMessages;
   {$IFEND}
  {$ELSE}{$IF Defined(RESTDWWINDOWS)}Application.Processmessages;{$IFEND}{$IFEND}
 {$ENDIF}
 Sleep(1);
End;

Procedure TRESTDWServiceNotificationBase.SetAccessTag   (Value    : String);
Begin
 vAccessTag := Value;
End;

Function TRESTDWServiceNotificationBase.GetAccessTag              : String;
Begin
 Result := vAccessTag;
End;

Procedure TRESTDWServiceNotificationBase.SetServerAuthOptions(AuthenticationOptions : TRESTDWServerAuthOptionParams);
Begin
 If AuthenticationOptions <> Nil Then
  vServerAuthOptions := AuthenticationOptions;
End;

Procedure TRESTDWServiceNotificationBase.SetServerMethod     (Value                 : TComponentClass);
Begin
 {$IFNDEF FPC}
  If (Value.InheritsFrom(TServerMethodDatamodule))           Or
     (Value            = TServerMethodDatamodule)            Then
 {$ELSE}
  If (Value.ClassType.InheritsFrom(TServerMethodDatamodule)) Or
     (Value             = TServerMethodDatamodule)           Then
 {$ENDIF}
 aServerMethod := Value;
End;

Constructor TRESTDWServiceNotificationBase.Create(AOwner : TComponent);
Begin
 Inherited;
 vGarbageTime               := 60000;
 vServiceTimeout            := 5000;
 vServicePort               := 9092;
 vForceWelcomeAccess        := False;
 vServerAuthOptions         := TRESTDWServerAuthOptionParams.Create(Self);
 vCripto                    := TCripto.Create;
 vServerAuthOptions.AuthorizationOption := rdwAONone;
 vLoginMessage              := '';
 vRESTDwAuthError           := Nil;
 vNotifyWelcomeMessage      := Nil;
 vLastRequest               := Nil;
 vLastResponse              := Nil;
End;

Destructor TRESTDWServiceNotificationBase.Destroy;
Begin
 FreeAndNil(vServerAuthOptions);
 FreeAndNil(vCripto);
 Inherited;
End;

Function  TRESTDWConnectionServerCP.GetDisplayName             : String;
Begin
 Result := vListName;
End;

Function  TRESTDWConnectionServerCP.GetPoolerList : TStringList;
Var
 I                : Integer;
 vTempList        : TStringList;
 RESTClientPooler : TRESTClientPoolerBase;
 vConnection      : TRESTDWPoolerMethodClient;
Begin
 Result := Nil;
 RESTClientPooler := TRESTClientPoolerBase.Create(Nil);
 Try
  vConnection                  := TRESTDWPoolerMethodClient.Create(Nil);
  vConnection.WelcomeMessage   := vWelcomeMessage;
  vConnection.Host             := vRestWebService;
  vConnection.Port             := vPoolerPort;
  vConnection.Compression      := vCompression;
  vConnection.TypeRequest      := vTypeRequest;
  vConnection.AccessTag        := vAccessTag;
  vConnection.CriptOptions.Use := CriptOptions.Use;
  vConnection.CriptOptions.Key := CriptOptions.Key;
  vConnection.DataRoute        := DataRoute;
  vConnection.ServerContext    := ServerContext;
  vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
  Result := TStringList.Create;
  Try
   vTempList := vConnection.GetServerEvents(vRestURL, vTimeOut);
   Try
    For I := 0 To vTempList.Count -1 do
     Result.Add(vTempList[I]);
   Finally
    If Assigned(vTempList) Then
     vTempList.Free;
   End;
  Except
   On E : Exception do
    Begin
     Raise Exception.Create(cInvalidRDWServer);
    End;
  End;
  FreeAndNil(vConnection);
 Finally
  FreeAndNil(RESTClientPooler);
 End;
End;

Procedure TRESTDWConnectionServerCP.SetDisplayName(Const Value : String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create(cInvalidConnectionName)
 Else
  Begin
   vListName := Trim(Value);
   Inherited;
  End;
End;

Destructor TRESTDWConnectionServerCP.Destroy;
Begin
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 If Assigned(vCripto) Then
  FreeAndNil(vCripto);
 Inherited;
End;

Constructor TRESTDWConnectionServerCP.Create(aCollection: TCollection);
Begin
 Inherited;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
  vDatabaseCharSet  := csUndefined;
 {$ENDIF}
 vListName          :=  Format('server(%d)', [aCollection.Count]);
 vRestWebService    := '127.0.0.1';
 vCompression       := True;
 vAuthentication    := True;
 vAuthOptionParams  := TRESTDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vPoolerPort        := 8082;
 vEncodeStrings     := True;
 vTimeOut           := 10000;
 vActive            := True;
 vServerEventName   := '';
 vDataRoute         := '';
 vServerContext     := '';
 vCripto            := TCripto.Create;
End;

Procedure TRESTDWConnectionServerCP.SetCripto(Value : TCripto);
Begin
 vCripto.Use := Value.Use;
 vCripto.Key := Value.Key;
End;

Function TFailOverConnections.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

Function TFailOverConnections.GetRec(Index : Integer) : TRESTDWConnectionServerCP;
Begin
 Result := TRESTDWConnectionServerCP(Inherited GetItem(Index));
End;

Procedure TFailOverConnections.PutRec(Index: Integer; Item: TRESTDWConnectionServerCP);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

Function  TFailOverConnections.GetRecName(Index : String)  : TRESTDWConnectionServerCP;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Result := TRESTDWConnectionServerCP(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TFailOverConnections.PutRecName(Index        : String;
                                          Item         : TRESTDWConnectionServerCP);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vListName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
    End;
  End;
End;

Procedure TFailOverConnections.ClearList;
Var
 I      : Integer;
Begin
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
 End;
End;

Constructor TFailOverConnections.Create(AOwner      : TPersistent;
                                        aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDWConnectionServerCP);
 fOwner  := AOwner;
End;

Destructor TFailOverConnections.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TFailOverConnections.Add: TCollectionItem;
Begin
 Result := TRESTDWConnectionServerCP(Inherited Add);
End;

Procedure TFailOverConnections.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Procedure TFailOverConnections.Delete(Index : String);
Begin
 If ItemsByName[Index] <> Nil Then
  TOwnedCollection(Self).Delete(ItemsByName[Index].Index);
End;

Procedure TRESTClientPoolerBase.SetOnWork(Value : TOnWork);
Begin
 {$IFDEF FPC}
  vOnWork            := Value;
//  HttpRequest.OnWork := vOnWork;
 {$ELSE}
  vOnWork            := Value;
//  HttpRequest.OnWork := vOnWork;
 {$ENDIF}
End;

Procedure TRESTClientPoolerBase.SetOnWorkBegin(Value : TOnWorkBegin);
Begin
 {$IFDEF FPC}
  vOnWorkBegin            := Value;
//  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ELSE}
  vOnWorkBegin            := Value;
//  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ENDIF}
End;

Procedure TRESTClientPoolerBase.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
 {$IFDEF FPC}
  vOnWorkEnd            := Value;
//  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ELSE}
  vOnWorkEnd            := Value;
//  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ENDIF}
End;

Procedure TRESTClientPoolerBase.SetOnStatus(Value : TOnStatus);
Begin
 {$IFDEF FPC}
  vOnStatus            := Value;
//  HttpRequest.OnStatus := vOnStatus;
 {$ELSE}
  vOnStatus            := Value;
//  HttpRequest.OnStatus := vOnStatus;
 {$ENDIF}
End;

Function TRESTClientPoolerBase.GetAllowCookies: Boolean;
Begin
// Result := HttpRequest.AllowCookies;
End;

Procedure TRESTClientPoolerBase.SetAllowCookies(Value: Boolean);
Begin
// HttpRequest.AllowCookies    := Value;
End;

Procedure TRESTClientPoolerBase.SetUrlPath(Value : String);
Begin
 vUrlPath := Value;
 If Length(vUrlPath) > 0 Then
  If vUrlPath[Length(vUrlPath)] <> '/' Then
   vUrlPath := vUrlPath + '/';
End;

Procedure TRESTClientPoolerBase.ReconfigureConnection(Var Connection        : TRESTClientPoolerBase;
                                                  TypeRequest           : Ttyperequest;
                                                  WelcomeMessage,
                                                  Host                  : String;
                                                  Port                  : Integer;
                                                  Compression,
                                                  EncodeStrings         : Boolean;
                                                  Encoding              : TEncodeSelect;
                                                  AccessTag             : String;
                                                  AuthenticationOptions : TRESTDWClientAuthOptionParams);
Begin

End;

Procedure TRESTClientPoolerBase.NewToken;
Var
 DWParams       : TRESTDWParams;
 vErrorBoolean  : Boolean;
 vMessageError,
 vToken         : String;
Begin
 DWParams := TRESTDWParams.Create;
 Try
  DWParams.Encoding := Encoding;
  If AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
   Begin
    Case AuthenticationOptions.AuthorizationOption Of
     rdwAOBearer : Begin
                    If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                       (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token = '') Then
                     Begin
                      If Assigned(OnBeforeGetToken) Then
                       OnBeforeGetToken(WelcomeMessage,
                                        AccessTag, DWParams);
                      vToken :=  RenewToken(DWParams, vErrorBoolean, vMessageError);
                      If Not vErrorBoolean Then
                       TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := vToken;
                     End;
                   End;
     rdwAOToken  : Begin
                    If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                       (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token = '') Then
                     Begin
                      If Assigned(OnBeforeGetToken) Then
                       OnBeforeGetToken(WelcomeMessage,
                                        AccessTag, DWParams);
                      vToken :=  RenewToken(DWParams, vErrorBoolean, vMessageError);
                      If Not vErrorBoolean Then
                       TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := vToken;
                     End;
                   End;
    End;
   End;
 Finally
  FreeAndNil(DWParams);
 End;
End;

Function  TRESTClientPoolerBase.RenewToken(Var Params       : TRESTDWParams;
                                       Var Error        : Boolean;
                                       Var MessageError : String) : String;
Var
 I                    : Integer;
 vTempSend            : String;
 vConnection          : TRESTDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPoolerBase;
 Procedure DestroyComponents;
 Begin
  If Assigned(RESTClientPoolerExec) Then
   FreeAndNil(RESTClientPoolerExec);
 End;
Begin
 //Atualização de Token na autenticação
 Result                       := '';
 RESTClientPoolerExec         := Nil;
 vConnection                  := TRESTDWPoolerMethodClient.Create(Nil);
 vConnection.UserAgent        := vUserAgent;
 vConnection.TypeRequest      := vTypeRequest;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vHost;
 vConnection.Port             := vPort;
 vConnection.BinaryRequest    := BinaryRequest;
 vConnection.Compression      := vDatacompress;
 vConnection.EncodeStrings    := EncodedStrings;
 vConnection.Encoding         := Encoding;
 vConnection.AccessTag        := vAccessTag;
 vConnection.CriptOptions.Use := vCripto.Use;
 vConnection.CriptOptions.Key := vCripto.Key;
 vConnection.DataRoute        := DataRoute;
 vConnection.ServerContext    := ServerContext;
 vConnection.AuthenticationOptions.Assign(AuthenticationOptions);
 {$IFNDEF FPC}
  vConnection.Encoding      := vRSCharset;
 {$ELSE}
  vConnection.DatabaseCharSet := csUndefined;
 {$ENDIF}
 If vAuthOptionParams.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   Try
    Try
     Case vAuthOptionParams.AuthorizationOption Of
      rdwAOBearer : Begin
                     vTempSend := vConnection.GetToken(vUrlPath,     '',
                                                       Params,       Error,
                                                       MessageError, vRequestTimeOut, vConnectTimeOut,
                                                       Nil,          RESTClientPoolerExec);
                     vTempSend                                           := GettokenValue(vTempSend);
                     TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
      rdwAOToken  : Begin
                     vTempSend := vConnection.GetToken(vUrlPath,     '',
                                                       Params,       Error,
                                                       MessageError, vRequestTimeOut, vConnectTimeOut,
                                                       Nil,          RESTClientPoolerExec);
                     vTempSend                                          := GettokenValue(vTempSend);
                     TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
     End;
     Result      := vTempSend;
     If csDesigning in ComponentState Then
      If Error Then Raise Exception.Create(PChar(cAuthenticationError));
     If Error Then
      Begin
       If vFailOver Then
        Begin
         If vFailOverConnections.Count = 0 Then
          Begin
           Result      := '';
           If csDesigning in ComponentState Then
            Raise Exception.Create(PChar(cInvalidConnection))
           Else
            Raise Exception.Create(cInvalidConnection);
          End
         Else
          Begin
           For I := 0 To vFailOverConnections.Count -1 Do
            Begin
             If I = 0 Then
              Begin
               If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                   (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                   (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                   (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                   (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                   (vFailOverConnections[I].hEncodeStrings  = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
//                   (vFailOverConnections[I].vRestURL        = vRestPooler)                And
                   (vFailOverConnections[I].vRestURL        = vHost))                  Or
                 (Not (vFailOverConnections[I].Active))                                   Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             If Not Assigned(RESTClientPoolerExec) Then
              RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
             ReconfigureConnection(RESTClientPoolerExec,
                                   vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].hEncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut, vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          RESTClientPoolerExec);
                              vTempSend                                           := GettokenValue(vTempSend);
                              TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut, vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          RESTClientPoolerExec);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := GettokenValue(vTempSend);
              If Not(Error) Then
               Begin
//                vMyIP     := vTempSend;
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vHost             := vConnection.Host;
                  vPort             := vConnection.Port;
                  vDatacompress     := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vRSCharset        := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vUrlPath          := vFailOverConnections[I].vRestURL;
                  vRequestTimeOut   := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams := vFailOverConnections[I].AuthenticationOptions;
                 End;
               End;
              If csDesigning in ComponentState Then
               If Not(Result = '') Then
                Raise Exception.Create(PChar(cAuthenticationError))
               Else
                Break;
             Except
              On E : Exception do
               Begin
                If Assigned(vOnFailOverError) Then
                 vOnFailOverError(vFailOverConnections[I], E.Message);
               End;
             End;
            End;
          End;
        End;
      End;
    Except
     On E : Exception do
      Begin
       DestroyComponents;
       If vFailOver Then
        Begin
         If vFailOverConnections.Count > 0 Then
          Begin
           If Assigned(vFailOverConnections) Then
           For I := 0 To vFailOverConnections.Count -1 Do
            Begin
             DestroyComponents;
             If I = 0 Then
              Begin
               If ((vFailOverConnections[I].vTypeRequest    = vConnection.TypeRequest)    And
                   (vFailOverConnections[I].vWelcomeMessage = vConnection.WelcomeMessage) And
                   (vFailOverConnections[I].vRestWebService = vConnection.Host)           And
                   (vFailOverConnections[I].vPoolerPort     = vConnection.Port)           And
                   (vFailOverConnections[I].vCompression    = vConnection.Compression)    And
                   (vFailOverConnections[I].hEncodeStrings  = vConnection.EncodeStrings)  And
                   (vFailOverConnections[I].Encoding        = vConnection.Encoding)       And
                   (vFailOverConnections[I].vAccessTag      = vConnection.AccessTag)      And
//                   (vFailOverConnections[I].vRestPooler     = vRestPooler)                And
                   (vFailOverConnections[I].vRestURL        = vHost))                  Or
                   (Not (vFailOverConnections[I].Active))                                 Then
               Continue;
              End;
             If Assigned(vOnFailOverExecute) Then
              vOnFailOverExecute(vFailOverConnections[I]);
             If Not Assigned(RESTClientPoolerExec) Then
              RESTClientPoolerExec := TRESTClientPoolerBase.Create(Nil);
             ReconfigureConnection(RESTClientPoolerExec,
                                   vFailOverConnections[I].vTypeRequest,
                                   vFailOverConnections[I].vWelcomeMessage,
                                   vFailOverConnections[I].vRestWebService,
                                   vFailOverConnections[I].vPoolerPort,
                                   vFailOverConnections[I].vCompression,
                                   vFailOverConnections[I].hEncodeStrings,
                                   vFailOverConnections[I].Encoding,
                                   vFailOverConnections[I].vAccessTag,
                                   vFailOverConnections[I].AuthenticationOptions);
             Try
              Case vAuthOptionParams.AuthorizationOption Of
               rdwAOBearer : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut, vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          RESTClientPoolerExec);
                              vTempSend                                           := GettokenValue(vTempSend);
                              TRESTDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,  vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          RESTClientPoolerExec);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRESTDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
              End;
              Result      := GettokenValue(vTempSend);
              If Not(Error) Then
               Begin
                If vFailOverReplaceDefaults Then
                 Begin
                  vTypeRequest      := vConnection.TypeRequest;
                  vWelcomeMessage   := vConnection.WelcomeMessage;
                  vHost             := vConnection.Host;
                  vPort             := vConnection.Port;
                  vDatacompress     := vConnection.Compression;
                  vEncodeStrings    := vConnection.EncodeStrings;
                  vRSCharset        := vConnection.Encoding;
                  vAccessTag        := vConnection.AccessTag;
                  vUrlPath          := vFailOverConnections[I].vRestURL;
                  vRequestTimeOut   := vFailOverConnections[I].vTimeOut;
                  vConnectTimeOut   := vFailOverConnections[I].vConnectTimeOut;
                  vAuthOptionParams := vFailOverConnections[I].AuthenticationOptions;
                 End;
               End;
              If csDesigning in ComponentState Then
               If Not (Result = '') Then
                Raise Exception.Create(PChar(cAuthenticationError))
               Else
                Break;
             Except
              On E : Exception do
               Begin
                If Assigned(vOnFailOverError) Then
                 vOnFailOverError(vFailOverConnections[I], E.Message);
               End;
             End;
            End;
          End
         Else
          Begin
           Result      := '';
           If csDesigning in ComponentState Then
            Raise Exception.Create(PChar(E.Message))
           Else
            Raise Exception.Create(E.Message);
          End;
        End
       Else
        Begin
         Result      := '';
         If csDesigning in ComponentState Then
          Raise Exception.Create(PChar(E.Message))
         Else
          Raise Exception.Create(E.Message);
        End;
      End;
    End;
   Finally
    DestroyComponents;
    If vConnection <> Nil Then
     FreeAndNil(vConnection);
   End;
  End;
End;

Procedure TRESTClientPoolerBase.SetAccessTag(Value : String);
Begin
 vAccessTag := Value;
End;

Function TRESTClientPoolerBase.GetAccessTag: String;
Begin
 Result := vAccessTag;
End;

Function TRESTClientPoolerBase.SendEvent(EventData : String) : String;
Var
 Params : TRESTDWParams;
Begin
 Try
  Params := Nil;
  Result := SendEvent(EventData, Params);
 Finally
 End;
End;

Function TRESTClientPoolerBase.SendEvent(EventData        : String;
                                     Var Params       : TRESTDWParams;
                                     EventType        : TSendEvent = sePOST;
                                     JsonMode         : TJsonMode  = jmDataware;
                                     ServerEventName  : String     = '';
                                     Assyncexec       : Boolean    = False) : String;
Begin
 //
End;

Procedure TRESTClientPoolerBase.SetAuthOptionParams(Value : TRESTDWClientAuthOptionParams);
Begin
 vAuthOptionParams.Assign(Value);
End;

Constructor TRESTClientPoolerBase.Create(AOwner: TComponent);
Begin
 Inherited;
// HttpRequest                           := TIdHTTP.Create(Nil);
 vCripto                               := TCripto.Create;
// HttpRequest.Request.ContentType       := 'application/json';
// HttpRequest.AllowCookies              := False;
 vErrorCode                            := -1;
// HttpRequest.HTTPOptions               := [hoKeepOrigProtocol];
// vTransparentProxy                     := TIdProxyConnectionInfo.Create;
 vHost                                 := 'localhost';
 vServerContext                        := '';
 vDataRoute                            := '';
 vPort                                 := 8082;
 vAuthOptionParams                     := TRESTDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vRSCharset                            := esUtf8;
 vAuthentication                       := True;
 vRequestTimeOut                       := 10000;
 vConnectTimeOut                       := 3000;
 vRedirectMaximum                      := 0;
 vDatacompress                         := True;
 vEncodeStrings                        := True;
 vBinaryRequest                        := False;
 vUserAgent                            := cUserAgent;
 {$IFDEF FPC}
 vDatabaseCharSet                      := csUndefined;
 {$ENDIF}
 vFailOver                             := False;
 vFailOverReplaceDefaults              := False;
 vPropThreadRequest                    := False;
 vFailOverConnections                  := TFailOverConnections.Create(Self, TRESTDWConnectionServerCP);
 vPoolerNotFoundMessage                := cPoolerNotFound;
End;

Destructor  TRESTClientPoolerBase.Destroy;
Begin
 Try
//  If HttpRequest.Connected Then
//   HttpRequest.Disconnect;
 Except
 End;
// FreeAndNil(HttpRequest);
 FreeAndNil(vFailOverConnections);
 FreeAndNil(vCripto);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Procedure TRESTServiceBase.SetServerContext(Value : String);
Begin
 vServerContext := LowerCase(Value);
End;

Procedure TRESTServiceBase.SetCORSCustomHeader (Value : TStringList);
Var
 I : Integer;
Begin
 vCORSCustomHeaders.Clear;
 For I := 0 To Value.Count -1 do
  vCORSCustomHeaders.Add(Value[I]);
End;

Procedure TRESTServiceBase.SetDefaultPage (Value : TStringList);
Var
 I : Integer;
Begin
 vDefaultPage.Clear;
 For I := 0 To Value.Count -1 do
  vDefaultPage.Add(Value[I]);
End;

Procedure TRESTServiceBase.SetServerMethod(Value : TComponentClass);
Begin
 {$IFNDEF FPC}
  If (Value.InheritsFrom(TServerMethodDatamodule)) Or
     (Value            = TServerMethodDatamodule) Then
   aServerMethod := Value;
 {$ELSE}
  If (Value.ClassType.InheritsFrom(TServerMethodDatamodule)) Or
     (Value             = TServerMethodDatamodule) Then
   aServerMethod := Value;
 {$ENDIF}
End;

Procedure TRESTServiceBase.Loaded;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

procedure TRESTServiceBase.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
 If (Operation = opRemove) then
  Begin
  End;
 Inherited Notification(AComponent, Operation);
end;

Procedure TRESTServiceBase.GetTableNames(ServerMethodsClass   : TComponent;
                                           Var Pooler           : String;
                                           Var DWParams         : TRESTDWParams;
                                           ConnectionDefs       : TConnectionDefs;
                                           hEncodeStrings       : Boolean;
                                           AccessTag            : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vStrings      : TStringList;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           vStrings := TStringList.Create;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetTableNames(vStrings, vError, vMessageError);
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              DWParams.ItemsString['Result'].CriptOptions.Use := False;
              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
             End;
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           FreeAndNil(vStrings);
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Constructor TRESTDWDriver.Create(AOwner: TComponent);
Begin
 Inherited;
 vEncodeStrings       := True;
 {$IFDEF FPC}
 vDatabaseCharSet     := csUndefined;
 {$ENDIF}
 vCommitRecords       := 100;
 vOnTableBeforeOpen   := Nil;
 vOnPrepareConnection := Nil;
 vParamCreate         := False;
 vStrsTrim            := vParamCreate;
 vStrsEmpty2Null      := vParamCreate;
 vStrsTrim2Len        := vParamCreate;
 vEncodeStrings       := vParamCreate;
 vCompression         := vParamCreate;
End;

Procedure TRESTDWDriver.BuildDatasetLine(Var Query      : TDataset;
                                         Massivedataset : TMassivedatasetBuffer;
                                         MassiveCache   : Boolean = False);
Var
 I, A              : Integer;
 vMasterField,
 vTempValue        : String;
 vStringStream     : TMemoryStream;
 MassiveField      : TMassiveField;
 MassiveReplyValue : TMassiveReplyValue;
 MassiveReplyCache : TMassiveReplyCache;
Begin
 vTempValue    := '';
 vStringStream := Nil;
 If Massivedataset.MassiveMode = mmUpdate Then
  Begin
   For I := 0 To Massivedataset.AtualRec.UpdateFieldChanges.Count -1 Do
    Begin
     MassiveField  := MassiveDataset.Fields.FieldByName(Massivedataset.AtualRec.UpdateFieldChanges[I]);
     If (Lowercase(MassiveField.FieldName) = Lowercase(RESTDWFieldBookmark)) then
      Continue;
     If (MassiveField <> Nil) Then
      Begin
       If MassiveField.IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveField.Value;
       If MassiveCache Then
        Begin
         If (MassiveField.KeyField) And (Not (MassiveField.ReadOnly)) Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveField.IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, MassiveField.OldValue, MassiveField.Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag, MassiveField.FieldName, Null, MassiveField.OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, Null);
              End;
             If Not MassiveField.IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             If Not MassiveField.IsNull Then
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.OldValue)
             Else
              MassiveReplyValue            := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveField.FieldName;
               If Not MassiveField.IsNull Then
                MassiveReplyValue.OldValue := MassiveField.Value
               Else
                MassiveReplyValue.OldValue := MassiveField.OldValue;
               MassiveReplyValue.NewValue  := Null;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End
             Else
              Begin
               MassiveField.Value := MassiveReplyValue.NewValue;
               If Not MassiveField.IsNull Then
                vTempValue := MassiveField.Value;
              End;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(MassiveField.FieldName, MassiveField.Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveField.IsNull Then
            vTempValue := MassiveField.Value;
          End;
        End;
       If ((vTempValue = 'null')  Or
           (Query.FieldByName(MassiveField.FieldName).ReadOnly) Or
           (MassiveField.IsNull)) Then
        Begin
         If Not (Query.FieldByName(MassiveField.FieldName).ReadOnly) Then
          Query.FieldByName(MassiveField.FieldName).Clear;
         Continue;
        End;
       If MassiveField.IsNull Then
        Continue;
       If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                 ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                 ftString,    ftWideString,
                                                                 ftMemo, ftFmtMemo {$IFNDEF FPC}
                                                                         {$IF CompilerVersion > 21}
                                                                                 , ftWideMemo
                                                                          {$IFEND}
                                                                         {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And (vTempValue <> '') And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.FieldByName(MassiveField.FieldName).Size > 0 Then
            Query.FieldByName(MassiveField.FieldName).AsString := Copy(vTempValue, 1, Query.FieldByName(MassiveField.FieldName).Size)
           Else
            Query.FieldByName(MassiveField.FieldName).AsString := vTempValue;
          End
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End
       Else
        Begin
         If Query.FieldByName(MassiveField.FieldName).DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).Value := vTempValue
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.FieldByName(MassiveField.FieldName).FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.FieldByName(MassiveField.FieldName).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                  {$ELSE} Query.FieldByName(MassiveField.FieldName).AsInteger                    := StrToInt64(vTempValue);
                  {$IFEND}
                 {$ELSE}
                  Query.FieldByName(MassiveField.FieldName).AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.FieldByName(MassiveField.FieldName).AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsFloat  := StrToFloat(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And (vTempValue <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.FieldByName(MassiveField.FieldName).AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.FieldByName(MassiveField.FieldName).Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.FieldByName(MassiveField.FieldName).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                        ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.FieldByName(MassiveField.FieldName)).LoadFromStream(vStringStream);
             End
            Else
             Query.FieldByName(MassiveField.FieldName).Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Query.FieldByName(MassiveField.FieldName).Value := vTempValue
         Else
          Query.FieldByName(MassiveField.FieldName).Clear;
        End;
      End;
    End;
  End
 Else
  Begin
   For I := 0 To Query.Fields.Count -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName) <> Nil) Then
      Begin
       If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
        Begin
         A := -1;
         If (MassiveDataset.SequenceName <> '') Then
          A := GetGenID(Query, MassiveDataset.SequenceName);
         If A > -1 Then
          Query.Fields[I].Value := A;
         Continue;
        End
       Else If (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).isNull) Or
               (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly) Then
        Begin
         If ((Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).ReadOnly)) And
             (Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue))) Then
          Query.Fields[I].Clear;
         Continue;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        vTempValue := ''
       Else
        vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
       If MassiveCache Then
        Begin
         If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).KeyField Then
          Begin
           MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag];
           If MassiveReplyCache = Nil Then
            Begin
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
              End
             Else
              Begin
               MassiveDataset.MassiveReply.AddBufferValue(Massivedataset.MyCompTag,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                          Null,
                                                          MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).OldValue);
               MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(Query.Fields[I].FieldName,
                                                                                                                              Null);
              End;
             If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
              vTempValue                   := MassiveReplyValue.NewValue
             Else
              vTempValue                   := MassiveReplyValue.OldValue;
            End
           Else
            Begin
             MassiveReplyValue             := MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].ItemByValue(MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName,
                                                                                                                            MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue = Nil Then
              Begin
               MassiveReplyValue           := TMassiveReplyValue.Create;
               MassiveReplyValue.ValueName := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).FieldName;
               MassiveReplyValue.OldValue  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
               MassiveReplyValue.NewValue  := MassiveReplyValue.OldValue;
               MassiveDataset.MassiveReply.ItemsString[Massivedataset.MyCompTag].Add(MassiveReplyValue);
               vTempValue                  := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
              End;
            End;
           vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
           If vMasterField <> '' Then
            Begin
             MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
             If MassiveReplyValue <> Nil Then
              vTempValue := MassiveReplyValue.NewValue;
            End;
          End
         Else
          Begin
           If Trim(MassiveDataset.MasterCompTag) <> '' Then
            Begin
             MassiveReplyCache := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag];
             If MassiveReplyCache <> Nil Then
              Begin
               vMasterField := MassiveDataset.MasterFieldFromDetail(Query.Fields[I].FieldName);
               If vMasterField = '' Then
                vMasterField := Query.Fields[I].FieldName;
               MassiveReplyValue := MassiveDataset.MassiveReply.ItemsString[MassiveDataset.MasterCompTag].ItemByValue(vMasterField, MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value);
               If MassiveReplyValue <> Nil Then
                vTempValue := MassiveReplyValue.NewValue;
              End;
            End
           Else If Not MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
            vTempValue := MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).Value;
          End;
        End;
       If MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).IsNull Then
        Continue;
       If Query.Fields[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                             ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                             ftString,    ftWideString,
                             ftMemo, ftFmtMemo {$IFNDEF FPC}
                                     {$IF CompilerVersion > 21}
                                      , ftWideMemo
                                     {$IFEND}
                                    {$ENDIF}]    Then
        Begin
         If (vTempValue <> Null) And
            (Trim(vTempValue) <> 'null') Then
          Begin
           If Query.Fields[I].Size > 0 Then
            Query.Fields[I].AsString := Copy(vTempValue, 1, Query.Fields[I].Size)
           Else
            Query.Fields[I].AsString := vTempValue;
          End
         Else
          Query.Fields[I].Clear;
        End
       Else
        Begin
         If Query.Fields[I].DataType in [ftBoolean] Then
          Begin
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Query.Fields[I].Value := vTempValue
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftInteger, ftSmallInt, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
          Begin
           If Lowercase(Query.Fields[I].FieldName) = Lowercase(Massivedataset.SequenceField) Then
            Continue;
           If (Trim(vTempValue) <> '') And
              (Trim(vTempValue) <> 'null') Then
            Begin
             If vTempValue <> Null Then
              Begin
               If Query.Fields[I].DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                Begin
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}Query.Fields[I].AsLargeInt := StrToInt64(vTempValue)
                  {$ELSE} Query.Fields[I].AsInteger                    := StrToInt64(vTempValue)
                  {$IFEND}
                 {$ELSE}
                  Query.Fields[I].AsLargeInt := StrToInt64(vTempValue);
                 {$ENDIF}
                End
               Else
                Query.Fields[I].AsInteger  := StrToInt(vTempValue);
              End;
            End
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle, ftExtended{$IFEND}{$ENDIF}] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsFloat := StrToFloat(BuildFloatString(vTempValue))
           Else
            Query.Fields[I].Clear;
          End
         Else If Query.Fields[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
          Begin
           If (vTempValue <> Null) And
              (Trim(vTempValue) <> 'null') And
              (Trim(vTempValue) <> '') Then
            Query.Fields[I].AsDateTime  := StrToDatetime(vTempValue)
           Else
            Query.Fields[I].Clear;
          End  //Tratar Blobs de Parametros...
         Else If Query.Fields[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                              ftGraphic, ftOraBlob, ftOraClob] Then
          Begin
           Try
            If (vTempValue <> 'null') And
               (vTempValue <> '') Then
             Begin
              vStringStream := DecodeStream(vTempValue);
              vStringStream.Position := 0;
              TBlobfield(Query.Fields[I]).LoadFromStream(vStringStream);
             End
            Else
             Query.Fields[I].Clear;
           Finally
            If Assigned(vStringStream) Then
             FreeAndNil(vStringStream);
           End;
          End
         Else If (vTempValue <> Null) And
                 (Trim(vTempValue) <> 'null') Then
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Value := vTempValue;
          End
         Else
          Begin
           If Not (MassiveDataset.Fields.FieldByName(Query.Fields[I].FieldName).AutoGenerateValue) Then
            Query.Fields[I].Clear;
          End;
        End;
      End;
    End;
  End;
end;

Procedure TRESTServiceBase.GetFieldNames(ServerMethodsClass   : TComponent;
                                           Var Pooler           : String;
                                           Var DWParams         : TRESTDWParams;
                                           ConnectionDefs       : TConnectionDefs;
                                           hEncodeStrings       : Boolean;
                                           AccessTag            : String);
Var
 I             : Integer;
 vError        : Boolean;
 vTableName,
 vMessageError : String;
 vStrings      : TStringList;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           vStrings := TStringList.Create;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            DWParams.ItemsString['TableName'].CriptOptions.Use := False;
            vTableName := DWParams.ItemsString['TableName'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetFieldNames(vTableName, vStrings, vError, vMessageError);
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              DWParams.ItemsString['Result'].CriptOptions.Use := False;
              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
             End;
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           FreeAndNil(vStrings);
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.GetKeyFieldNames(ServerMethodsClass      : TComponent;
                                              Var Pooler              : String;
                                              Var DWParams            : TRESTDWParams;
                                              ConnectionDefs          : TConnectionDefs;
                                              hEncodeStrings          : Boolean;
                                              AccessTag               : String);
Var
 I             : Integer;
 vError        : Boolean;
 vTableName,
 vMessageError : String;
 vStrings      : TStringList;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           vStrings := TStringList.Create;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            DWParams.ItemsString['TableName'].CriptOptions.Use := False;
            vTableName := DWParams.ItemsString['TableName'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetKeyFieldNames(vTableName, vStrings, vError, vMessageError);
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              DWParams.ItemsString['Result'].CriptOptions.Use := False;
              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
             End;
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           FreeAndNil(vStrings);
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.GetPoolerList(ServerMethodsClass : TComponent;
                                           Var PoolerList     : String;
                                           AccessTag          : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If PoolerList = '' then
        PoolerList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        PoolerList := PoolerList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Function TRESTServiceBase.ServiceMethods(BaseObject              : TComponent;
                                           AContext                : TComponent;
                                           Var UriOptions          : TRESTDWUriOptions;
                                           Var DWParams            : TRESTDWParams;
                                           Var JSONStr             : String;
                                           Var JsonMode            : TJsonMode;
                                           Var ErrorCode           : Integer;
                                           Var ContentType         : String;
                                           Var ServerContextCall   : Boolean;
                                           Var ServerContextStream : TMemoryStream;
                                           ConnectionDefs          : TConnectionDefs;
                                           hEncodeStrings          : Boolean;
                                           AccessTag               : String;
                                           WelcomeAccept           : Boolean;
                                           Const RequestType       : TRequestType;
                                           mark                    : String;
                                           RequestHeader           : TStringList;
                                           BinaryEvent             : Boolean;
                                           Metadata                : Boolean;
                                           BinaryCompatibleMode    : Boolean;
                                           CompareContext          : Boolean) : Boolean;
Var
 vJsonMSG,
 vResult,
 vResultIP,
 vUrlMethod,
 vOldServerEvent :  String;
 vError,
 vInvalidTag  : Boolean;
 JSONParam    : TJSONParam;
Begin
 Result       := False;
 vUrlMethod   := UpperCase(UriOptions.EventName);
 If WelcomeAccept Then
  Begin
   If (vUrlMethod = UpperCase('GetPoolerList')) Then
    Begin
     Result     := True;
     GetPoolerList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If (vUrlMethod = UpperCase('GetServerEventsList')) Then
    Begin
     Result     := True;
     GetServerEventsList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If (vUrlMethod = UpperCase('EchoPooler')) Then
    Begin
     vJsonMSG := TReplyNOK;
     If DWParams.ItemsString['Pooler'] <> Nil Then
      Begin
       vResult    := DWParams.ItemsString['Pooler'].Value;
       EchoPooler(BaseObject, AContext, vResult, vResultIP, AccessTag, vInvalidTag);
       If DWParams.ItemsString['Result'] <> Nil Then
        DWParams.ItemsString['Result'].SetValue(vResultIP,
                                                DWParams.ItemsString['Result'].Encoded);
      End;
     Result     := vResultIP <> '';
     If Result Then
      JSONStr    := TReplyOK
     Else
      Begin
       If vInvalidTag Then
        JSONStr    := TReplyTagError
       Else
        JSONStr    := TReplyInvalidPooler;
       ErrorCode   := 405;
      End;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandPureJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandPureJSONTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSONTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSONTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSONTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdatesTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSONTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCache') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCache(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCacheTB') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCacheTB(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ProcessMassiveSQLCache') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ProcessMassiveSQLCache(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetTableNames') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     GetTableNames(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetFieldNames') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     GetFieldNames(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetKeyFieldNames') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     GetKeyFieldNames(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID_PARAMS') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('OpenDatasets') Then
    Begin
     vResult     := DWParams.ItemsString['Pooler'].Value;
     OpenDatasets(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag, BinaryEvent);
     Result      := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GETEVENTS') Then
    Begin
     If DWParams.ItemsString['Error'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Error';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['MessageError'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'MessageError';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     GetEvents(BaseObject, vResult, UriOptions.ServerEvent, DWParams);
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
     Result      := JSONStr = TReplyOK;
    End
   Else
    Begin
     If CompareContext Then
      Begin
       vOldServerEvent := UriOptions.ServerEvent;
       UriOptions.ServerEvent := '';
      End;
     If ReturnEvent(BaseObject, vUrlMethod, UriOptions.ServerEvent, vResult, DWParams, JsonMode, ErrorCode, ContentType, Accesstag, RequestType, RequestHeader) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       ErrorCode := 200;
       If CompareContext Then
        UriOptions.ServerEvent := vOldServerEvent;
       Result  := ReturnContext(BaseObject, vUrlMethod, UriOptions.ServerEvent, vResult, ContentType, ServerContextStream, vError, DWParams, RequestType, Mark, RequestHeader, ErrorCode);
       If Not (Result) Or (vError) Then
        Begin
         If Not WelcomeAccept Then
          Begin
           JsonMode    := jmPureJSON;
           JSONStr     := TReplyInvalidWelcome;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 500;
          End
         Else
          Begin
           JsonMode   := jmPureJSON;
           JSONStr    := vResult;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 404;
          End;
        End
       Else
        Begin
         ServerContextCall := True;
         JsonMode  := jmPureJSON;
         JSONStr   := vResult;
        End;
      End;
    End;
  End
 Else If (vUrlMethod = UpperCase('GETEVENTS')) And (Not (vForceWelcomeAccess)) Then
  Begin
   If DWParams.ItemsString['Error'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Error';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['MessageError'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'MessageError';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['Result'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Result';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   GetEvents(BaseObject, vResult, UriOptions.ServerEvent, DWParams);
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      JSONStr   := DWParams.ItemsString['MessageError'].AsString
     Else
      Begin
       JSONStr   := TReplyNOK;
       ErrorCode  := 500;
      End;
    End;
   Result      := JSONStr = TReplyOK;
  End
 Else If (Not (vForceWelcomeAccess)) Then
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    Begin
     If ReturnEvent(BaseObject, vUrlMethod, UriOptions.ServerEvent, vResult, DWParams, JsonMode, ErrorCode, ContentType, Accesstag, RequestType, RequestHeader) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       ErrorCode := 200;
       Result  := ReturnContext(BaseObject, vUrlMethod, UriOptions.ServerEvent, vResult, ContentType, ServerContextStream, vError, DWParams, RequestType, Mark, RequestHeader, ErrorCode);
       If Not (Result) Or (vError) Then
        Begin
         If Not WelcomeAccept Then
          Begin
           JsonMode   := jmPureJSON;
           JSONStr    := TReplyInvalidWelcome;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 500;
          End
         Else
          Begin
           JsonMode   := jmPureJSON;
           JSONStr := vResult;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 404;
           Result  := False;
          End;
        End
       Else
        Begin
         JsonMode  := jmPureJSON;
         JSONStr   := vResult;
         If (ErrorCode <= 0)  Or
            (ErrorCode > 299) Then
          ErrorCode := 200;
        End;
      End;
    End;
  End
 Else
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    JSONStr := TReplyNOK;
   Result  := False;
   If DWParams.ItemsString['Error']        <> Nil Then
    DWParams.ItemsString['Error'].AsBoolean := True;
   If DWParams.ItemsString['MessageError'] <> Nil Then
    DWParams.ItemsString['MessageError'].AsString := 'Invalid welcomemessage...'
   Else
    Begin
     If (ErrorCode <= 0)  Or
        (ErrorCode = 200) Then
      ErrorCode  := 500;
    End;
  End;
End;

Procedure TRESTServiceBase.ExecuteCommandPureJSON(ServerMethodsClass   : TComponent;
                                                    Var Pooler           : String;
                                                    Var DWParams         : TRESTDWParams;
                                                    ConnectionDefs       : TConnectionDefs;
                                                    hEncodeStrings       : Boolean;
                                                    AccessTag            : String;
                                                    BinaryEvent          : Boolean;
                                                    Metadata             : Boolean;
                                                    BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vEncoded,
 vError,
 vExecute      : Boolean;
 vTempJSON,
 vMessageError : String;
 BinaryBlob    : TMemoryStream;
Begin
 vRowsAffected := 0;
 BinaryBlob    := Nil;
 Try
  vTempJSON := '';
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      vError,
                                                                                                      vMessageError,
                                                                                                      BinaryBlob,
                                                                                                      vRowsAffected,
                                                                                                      vExecute, BinaryEvent, Metadata,
                                                                                                      BinaryCompatibleMode);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              vEncoded := DWParams.ItemsString['Result'].Encoded;
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
              Else If Not(vError) And (vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, vEncoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ExecuteCommandPureJSONTB(ServerMethodsClass   : TComponent;
                                                      Var Pooler           : String;
                                                      Var DWParams         : TRESTDWParams;
                                                      ConnectionDefs       : TConnectionDefs;
                                                      hEncodeStrings       : Boolean;
                                                      AccessTag            : String;
                                                      BinaryEvent          : Boolean;
                                                      Metadata             : Boolean;
                                                      BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vEncoded,
 vError        : Boolean;
 vTempJSON,
 vTablename,
 vMessageError : String;
 BinaryBlob    : TMemoryStream;
Begin
 vRowsAffected := 0;
 BinaryBlob    := Nil;
 Try
  vTempJSON := '';
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vError     := DWParams.ItemsString['Error'].AsBoolean;
            vTablename := DWParams.ItemsString['rdwtablename'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, vError,
                                                                                                        vMessageError,
                                                                                                        BinaryBlob,
                                                                                                        vRowsAffected,
                                                                                                        BinaryEvent, Metadata,
                                                                                                        BinaryCompatibleMode);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              vEncoded := DWParams.ItemsString['Result'].Encoded;
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
              Else If Not(vError) And (vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, vEncoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ExecuteCommandJSON(ServerMethodsClass   : TComponent;
                                                Var Pooler           : String;
                                                Var DWParams         : TRESTDWParams;
                                                ConnectionDefs       : TConnectionDefs;
                                                hEncodeStrings       : Boolean;
                                                AccessTag            : String;
                                                BinaryEvent          : Boolean;
                                                Metadata             : Boolean;
                                                BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vError,
 vExecute      : Boolean;
 vTempJSON,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
 BinaryBlob    : TMemoryStream;
Begin
 DWParamsD     := Nil;
 BinaryBlob    := Nil;
 vTempJSON     := '';
 vRowsAffected := 0;
 Try
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            If DWParams.ItemsString['Params'] <> Nil Then
             Begin
              DWParamsD := TRESTDWParams.Create;
              DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
             End;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             If DWParamsD <> Nil Then
              Begin
               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                        DWParamsD, vError, vMessageError,
                                                                                                        BinaryBlob,
                                                                                                        vRowsAffected,
                                                                                                        vExecute, BinaryEvent, Metadata,
                                                                                                        BinaryCompatibleMode);
               DWParamsD.Free;
              End
             Else
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                       vError,
                                                                                                       vMessageError,
                                                                                                       BinaryBlob,
                                                                                                       vRowsAffected,
                                                                                                       vExecute, BinaryEvent, Metadata);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean        := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
              Else If Not(vError) And(vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, DWParams.ItemsString['Result'].Encoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ExecuteCommandJSONTB(ServerMethodsClass   : TComponent;
                                                  Var Pooler           : String;
                                                  Var DWParams         : TRESTDWParams;
                                                  ConnectionDefs       : TConnectionDefs;
                                                  hEncodeStrings       : Boolean;
                                                  AccessTag            : String;
                                                  BinaryEvent          : Boolean;
                                                  Metadata             : Boolean;
                                                  BinaryCompatibleMode : Boolean);
Var
 vRowsAffected,
 I             : Integer;
 vError        : Boolean;
 vTempJSON,
 vTablename,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
 BinaryBlob    : TMemoryStream;
Begin
 DWParamsD     := Nil;
 BinaryBlob    := Nil;
 vTempJSON     := '';
 vRowsAffected := 0;
 Try
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vError     := DWParams.ItemsString['Error'].AsBoolean;
            vTablename := DWParams.ItemsString['rdwtablename'].AsString;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            If DWParams.ItemsString['Params'] <> Nil Then
             Begin
              DWParamsD := TRESTDWParams.Create;
              DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
             End;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             If DWParamsD <> Nil Then
              Begin
               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, DWParamsD, vError, vMessageError,
                                                                                                          BinaryBlob,
                                                                                                          vRowsAffected,
                                                                                                          BinaryEvent, Metadata,
                                                                                                          BinaryCompatibleMode);
               DWParamsD.Free;
              End
             Else
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, vError,
                                                                                                         vMessageError,
                                                                                                         BinaryBlob,
                                                                                                         vRowsAffected,
                                                                                                         BinaryEvent, Metadata);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean        := vError;
            If DWParams.ItemsString['RowsAffected'] <> Nil Then
             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              If (BinaryEvent) And (Not (vError)) Then
               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
              Else If Not(vError) And(vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, DWParams.ItemsString['Result'].Encoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                                 Var Pooler         : String;
                                                 Var DWParams       : TRESTDWParams;
                                                 ConnectionDefs     : TConnectionDefs;
                                                 hEncodeStrings     : Boolean;
                                                 AccessTag          : String);
Var
 I,
 vTempJSON     : Integer;
 vError        : Boolean;
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
Begin
 DWParamsD := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TRESTDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            If DWParamsD <> Nil Then
             Begin
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                            DWParamsD, vError, vMessageError);
              DWParamsD.Free;
             End
            Else
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                           vError,
                                                                                                           vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> -1 Then
              DWParams.ItemsString['Result'].SetValue(IntToStr(vTempJSON), DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('-1');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TRESTDWParams;
                                              ConnectionDefs     : TConnectionDefs;
                                              hEncodeStrings     : Boolean;
                                              AccessTag          : String);
Var
 vRowsAffected,
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vSQL,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
Begin
 DWParamsD     := Nil;
 vTempJSON     := Nil;
 vRowsAffected := 0;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TRESTDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParams.ItemsString['SQL'] <> Nil Then
            vSQL := DWParams.ItemsString['SQL'].Value;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            DWParams.ItemsString['Massive'].CriptOptions.Use := False;
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(DWParams.ItemsString['Massive'].AsString,
                                                                                                    vSQL,
                                                                                                    DWParamsD, vError, vMessageError, vRowsAffected);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If DWParamsD <> Nil Then
            DWParamsD.Free;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             DWParams.ItemsString['Result'].CriptOptions.Use := False;
             If vTempJSON <> Nil Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.ApplyUpdatesJSONTB(ServerMethodsClass : TComponent;
                                                Var Pooler         : String;
                                                Var DWParams       : TRESTDWParams;
                                                ConnectionDefs     : TConnectionDefs;
                                                hEncodeStrings     : Boolean;
                                                AccessTag          : String);
Var
 vRowsAffected,
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vSQL,
 vMessageError : String;
 DWParamsD     : TRESTDWParams;
Begin
 DWParamsD     := Nil;
 vTempJSON     := Nil;
 vRowsAffected := 0;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TRESTDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParams.ItemsString['SQL'] <> Nil Then
            vSQL := DWParams.ItemsString['SQL'].Value;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            DWParams.ItemsString['Massive'].CriptOptions.Use := False;
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdatesTB(DWParams.ItemsString['Massive'].AsString,
                                                                                                     DWParamsD, vError, vMessageError, vRowsAffected);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If DWParamsD <> Nil Then
            DWParamsD.Free;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             DWParams.ItemsString['Result'].CriptOptions.Use := False;
             If vTempJSON <> Nil Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.OpenDatasets(ServerMethodsClass   : TComponent;
                                          Var Pooler           : String;
                                          Var DWParams         : TRESTDWParams;
                                          ConnectionDefs       : TConnectionDefs;
                                          hEncodeStrings       : Boolean;
                                          AccessTag            : String;
                                          BinaryRequest        : Boolean);
Var
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vMessageError : String;
 BinaryBlob    : TMemoryStream;
Begin
 BinaryBlob    := Nil;
 vTempJSON     := Nil;
 Try
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            Try
//             DWParams.ItemsString['LinesDataset'].CriptOptions.Use := False;
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
                                                                                                    vError, vMessageError, BinaryBlob);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError := True;
              End;
            End;
            If vMessageError <> '' Then
             Begin
              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
            DWParams.ItemsString['Error'].AsBoolean        := vError;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              If BinaryRequest Then
               Begin
                If Not Assigned(BinaryBlob) Then
                 BinaryBlob  := TMemoryStream.Create;
                If Not vTempJSON.IsNull Then //vTempJSON <> Nil Then
                 Begin
                  vTempJSON.SaveToStream(BinaryBlob);
                  DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob);
                  FreeAndNil(vTempJSON);
                 End
                Else
                 DWParams.ItemsString['Result'].SetValue('');
                FreeAndNil(BinaryBlob);
               End
              Else
               Begin
                If Not vTempJSON.IsNull Then //vTempJSON <> Nil Then
                 DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON)
                Else
                 DWParams.ItemsString['Result'].SetValue('');
               End;
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTServiceBase.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                       Var Pooler         : String;
                                                       Var DWParams       : TRESTDWParams;
                                                       ConnectionDefs     : TConnectionDefs;
                                                       hEncodeStrings     : Boolean;
                                                       AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
 vTempJSON     := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            DWParams.ItemsString['MassiveCache'].CriptOptions.Use := False;
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].AsString,
                                                                                                   vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             If Assigned(vTempJSON) Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.ApplyUpdates_MassiveCacheTB(ServerMethodsClass : TComponent;
                                                         Var Pooler         : String;
                                                         Var DWParams       : TRESTDWParams;
                                                         ConnectionDefs     : TConnectionDefs;
                                                         hEncodeStrings     : Boolean;
                                                         AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
 vTempJSON     := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            DWParams.ItemsString['MassiveCache'].CriptOptions.Use := False;
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCacheTB(DWParams.ItemsString['MassiveCache'].AsString,
                                                                                                                  vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             If Assigned(vTempJSON) Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.ProcessMassiveSQLCache(ServerMethodsClass      : TComponent;
                                                    Var Pooler              : String;
                                                    Var DWParams            : TRESTDWParams;
                                                    ConnectionDefs          : TConnectionDefs;
                                                    hEncodeStrings          : Boolean;
                                                    AccessTag               : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
 vTempJSON     := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ProcessMassiveSQLCache(DWParams.ItemsString['MassiveSQLCache'].AsString,
                                                                                                   vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError := True;
             End;
           End;
           If vMessageError <> '' Then
            Begin
             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded);
               FreeAndNil(vTempJSON);
              End
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Assigned(vTempJSON) Then
  FreeAndNil(vTempJSON);
End;

Procedure TRESTServiceBase.GetEvents(ServerMethodsClass : TComponent;
                                       Pooler,
                                       urlContext         : String;
                                       Var DWParams       : TRESTDWParams);
Var
 I         : Integer;
 vError    : Boolean;
 vTempJSON : String;
 iContSE   : Integer;
Begin
 vTempJSON := '';
 If ServerMethodsClass <> Nil Then
  Begin
   iContSE := 0;
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ((ServerMethodsClass.Components[i].InheritsFrom(TRESTDWServerEvents)) Or
         (ServerMethodsClass.Components[i] is TRESTDWServerEvents)) Then
      Begin
       iContSE := iContSE + 1;
       If (LowerCase(urlContext) = LowerCase(TRESTDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) Or
          (LowerCase(urlContext) = LowerCase(Format('%s.%s', [ServerMethodsClass.Classname, ServerMethodsClass.Components[i].Name])))  Then
        Begin
         If vTempJSON = '' Then
          vTempJSON := Format('%s', [TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
         Else
          vTempJSON := vTempJSON + Format(', %s', [TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON]);
         Break;
        End;
      End;
    End;
   vError := vTempJSON = '';
   If vError Then
    Begin
     DWParams.ItemsString['MessageError'].AsString := 'Event Not Found';
     If iContSE > 1 then
      DWParams.ItemsString['MessageError'].AsString := 'There is more than one ServerEvent.'+ sLineBreak +
                                                       'Choose the desired ServerEvent in the ServerEventName property.';
    End;
   DWParams.ItemsString['Error'].AsBoolean        := vError;
   If DWParams.ItemsString['Result'] <> Nil Then
    Begin
     If vTempJSON <> '' Then
      DWParams.ItemsString['Result'].SetValue(Format('[%s]', [vTempJSON]), DWParams.ItemsString['Result'].Encoded)
     Else
      DWParams.ItemsString['Result'].SetValue('');
    End;
  End;
End;

Function TRESTServiceBase.ReturnEvent(ServerMethodsClass : TComponent;
                                        Pooler,
                                        urlContext          : String;
                                        Var vResult         : String;
                                        Var DWParams        : TRESTDWParams;
                                        Var JsonMode        : TJsonMode;
                                        Var ErrorCode       : Integer;
                                        Var ContentType,
                                        AccessTag           : String;
                                        Const RequestType   : TRequestType;
                                        Var   RequestHeader : TStringList) : Boolean;
Var
 I             : Integer;
 vRejected,
 vTagService   : Boolean;
 vErrorMessage : String;
 vStrAcceptedRoutes: string;
 vDWRoutes: TRESTDWRoutes;
Begin
 Result        := False;
 vRejected     := False;
 vTagService   := Result;
 vErrorMessage := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWServerEvents Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TRESTDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) Or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.classname + '.' +
                                             ServerMethodsClass.Components[i].Name)) Then
        vTagService := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
       If vTagService Then
        Begin
         Result   := True;
         JsonMode := jmPureJSON;
         If Trim(TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             If DWParams.ItemsString['dwencodestrings'] <> Nil Then
              vResult := EncodeStrings('Invalid Access tag...'{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else
              vResult := 'Invalid Access tag...';
             ErrorCode := 401;
             Result  := True;
             Break;
            End;
          End;
         If (RequestTypeToRoute(RequestType) In TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Or
            (crAll in TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Then
          Begin
           vResult := '';
           TRESTDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
           If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest) Then
            TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If Not vRejected Then
            Begin
             TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].CompareParams(DWParams);
             Try
              If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute) Then
               TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler]);
              If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType) Then
               TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType(DWParams, vResult, RequestType, ErrorCode, RequestHeader)
              Else If Assigned(TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
               TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
              JsonMode := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].JsonMode;
             Except
              On E : Exception Do
               Begin
                 //Alexandre Magno - 22/01/2019
                 If DWParams.ItemsString['dwencodestrings'] <> Nil Then
                  vResult := EncodeStrings(e.Message{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                 Else
                  vResult := e.Message;
                Result  := True;
                If (ErrorCode <= 0)  Or
                   (ErrorCode = 200) Then
                 ErrorCode := 500;
//                Exit;
               End;
             End;
            End
           Else
            Begin
             If vErrorMessage <> '' Then
              Begin
               ContentType := 'text/html';
               vResult     := vErrorMessage;
              End
             Else
              vResult   := 'The Requested URL was Rejected';
             If (ErrorCode <= 0)  Or
                (ErrorCode = 200) Then
              ErrorCode := 401;
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          Begin
           vStrAcceptedRoutes := '';
           vDWRoutes := TRESTDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes;
           If crGet in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', GET'
             Else
              vStrAcceptedRoutes := 'GET';
            End;
           If crPost in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', POST'
             Else
              vStrAcceptedRoutes := 'POST';
            End;
           If crPut in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PUT'
             Else
              vStrAcceptedRoutes := 'PUT';
            End;
           If crPatch in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PATCH'
             Else
              vStrAcceptedRoutes := 'PATCH';
            End;
           If crDelete in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', DELETE'
             Else
              vStrAcceptedRoutes := 'DELETE';
            End;
           If vStrAcceptedRoutes <> '' then
            Begin
             vResult   := 'Request rejected. Acceptable HTTP methods: '+vStrAcceptedRoutes;
             ErrorCode := 403;
            End
           Else
            Begin
             vResult   := 'Acceptable HTTP methods not defined on server';
             ErrorCode := 500;
            End;
          End;
         Break;
        End
       Else
        Begin
         vResult := 'Event not found...';
        End;
      End;
    End;
  End;
 If Not vTagService Then
  If (ErrorCode <= 0)  Or
     (ErrorCode = 200) Then
   ErrorCode := 404;
End;

Procedure TRESTServiceBase.GetServerEventsList(ServerMethodsClass   : TComponent;
                                                 Var ServerEventsList : String;
                                                 AccessTag            : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWServerEvents Then
      Begin
       If Trim(TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TRESTDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If ServerEventsList = '' then
        ServerEventsList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        ServerEventsList := ServerEventsList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Function TRESTServiceBase.ReturnContext(ServerMethodsClass      : TComponent;
                                          Pooler,
                                          urlContext              : String;
                                          Var vResult,
                                          ContentType             : String;
                                          Var ServerContextStream : TMemoryStream;
                                          Var Error               : Boolean;
                                          Var   DWParams          : TRESTDWParams;
                                          Const RequestType       : TRequestType;
                                          mark                    : String;
                                          RequestHeader           : TStringList;
                                          Var ErrorCode           : Integer) : Boolean;
Var
 I            : Integer;
 vRejected,
 vTagService,
 vDefaultPageB : Boolean;
 vErrorMessage,
 vBaseHeader,
 vRootContext : String;
 vStrAcceptedRoutes: string;
 vDWRoutes: TRESTDWRoutes;
Begin
 Result        := False;
 vDefaultPageB  := False;
 vRejected     := False;
 Error         := False;
 vTagService   := Result;
 vRootContext  := '';
 vErrorMessage := '';
 If (Pooler <> '') And (urlContext = '') Then
  Begin
   urlContext := Pooler;
   Pooler     := '';
  End;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWServerContext Then
      Begin
       If ((LowerCase(urlContext) = LowerCase(TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseContext))) Or
          ((Trim(TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseContext) = '') And (Pooler = '')        And
           (TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[urlContext] <> Nil))   Then
        Begin
         vRootContext := TRESTDWServerContext(ServerMethodsClass.Components[i]).RootContext;
         If ((Pooler = '')    And (vRootContext <> '')) Then
          Pooler := vRootContext;
         vTagService := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler] <> Nil;
         If Not vTagService Then
          Begin
           Error   := True;
           vResult := cInvalidRequest;
          End;
        End;
       If vTagService Then
        Begin
         Result   := False;
         If (RequestTypeToRoute(RequestType) In TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Or
            (crAll in TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Then
          Begin
           If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer) Then
            TRESTDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer(ServerMethodsClass.Components[i]);
           If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest) Then
            TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If Not vRejected Then
            Begin
             Result  := True;
             vResult := '';
             TRESTDWServerContext(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
             TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].CompareParams(DWParams);
             Try
              ContentType := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContentType;
              If mark <> '' Then
               Begin
                vResult    := '';
                Result     := Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules);
                If Result Then
                 Begin
                  Result   := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark] <> Nil;
                  If Result Then
                   Begin
                    Result := Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute);
                    If Result Then
                     Begin
                      ContentType := 'application/json';
                      TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute(DWParams, ContentType, vResult);
//                      vResult := utf8Encode(vResult);
                     End;
                   End;
                 End;
               End
              Else If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules) Then
               Begin
                vBaseHeader := '';
                ContentType := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.ContentType;
                vResult := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.BuildContext(TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseHeader,
                                                                                                                                          TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].IgnoreBaseHeader);
               End
              Else
               Begin
                If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall) Then
                 TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler]);
                vDefaultPageB := Not Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest);
                If Not vDefaultPageB Then
                 TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest(DWParams, ContentType, vResult, RequestType);
                If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream) Then
                 Begin
                  vDefaultPageB := False;
                  ServerContextStream := TMemoryStream.Create;
                  Try
                   TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream(DWParams, ContentType, ServerContextStream, RequestType, ErrorCode);
                  Finally
                   If ServerContextStream.Size = 0 Then
                    FreeAndNil(ServerContextStream);
                  End;
                 End;
                If vDefaultPageB Then
                 Begin
                  vBaseHeader := '';
                  If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseHeader) Then
                   vBaseHeader := TRESTDWServerContext(ServerMethodsClass.Components[i]).BaseHeader.Text;
                  vResult := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].DefaultHtml.Text;
                  If Assigned(TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer) Then
                   TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer(vBaseHeader, ContentType, vResult, RequestType);
                 End;
               End;
             Except
              On E : Exception Do
               Begin
                 //Alexandre Magno - 22/01/2019
                If DWParams.ItemsString['dwencodestrings'] <> Nil Then
                 vResult := EncodeStrings(e.Message{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                Else
                 vResult := e.Message;
                Error   := True;
                Exit;
               End;
             End;
            End
           Else
            Begin
             If vErrorMessage <> '' Then
              Begin
               ContentType := 'text/html';
               vResult     := vErrorMessage;
              End
             Else
              vResult   := cRequestRejected;
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          Begin
           vStrAcceptedRoutes := '';
           vDWRoutes := TRESTDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes;
           If crGet in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', GET'
             Else
              vStrAcceptedRoutes := 'GET';
            End;
           If crPost in vDWRoutes Then
            Begin
               If vStrAcceptedRoutes <> '' Then
                vStrAcceptedRoutes := vStrAcceptedRoutes + ', POST'
               Else
                vStrAcceptedRoutes := 'POST';
            End;
           If crPut in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PUT'
             Else
              vStrAcceptedRoutes := 'PUT';
            End;
           If crPatch in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', PATCH'
             Else
              vStrAcceptedRoutes := 'PATCH';
            End;
           If crDelete in vDWRoutes Then
            Begin
             If vStrAcceptedRoutes <> '' Then
              vStrAcceptedRoutes := vStrAcceptedRoutes + ', DELETE'
             Else
              vStrAcceptedRoutes := 'DELETE';
            End;
           If vStrAcceptedRoutes <> '' Then
            Begin
             vResult   := cRequestRejectedMethods + vStrAcceptedRoutes;
             ErrorCode := 403;
            End
           Else
            Begin
             vResult   := cRequestAcceptableMethods;
             ErrorCode := 500;
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceBase.SetServerAuthOptions(AuthenticationOptions : TRESTDWServerAuthOptionParams);
Begin
 If AuthenticationOptions <> Nil Then
  vServerAuthOptions := AuthenticationOptions;
End;

Procedure TRESTServiceBase.ClearDataRoute;
Begin
 vDataRouteList.ClearList;
End;

Procedure TRESTServiceBase.AddDataRoute(DataRoute : String; MethodClass : TComponentClass);
Var
 vDataRoute : TRESTDWDataRoute;
Begin
 vDataRoute                   := TRESTDWDataRoute.Create;
 vDataRoute.DataRoute         := DataRoute;
 vDataRoute.ServerMethodClass := MethodClass;
 vDataRouteList.Add(vDataRoute);
End;

Constructor TRESTServiceBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vProxyOptions                   := TProxyOptions.Create;
 vDefaultPage                    := TStringList.Create;
 vCORSCustomHeaders              := TStringList.Create;
 vDataRouteList                  := TRESTDWDataRouteList.Create;
 vCORSCustomHeaders.Add('Access-Control-Allow-Origin=*');
 vCORSCustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
 vCORSCustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
 vCripto                         := TCripto.Create;
 {$IFDEF FPC}
 vDatabaseCharSet                := csUndefined;
 {$ELSE}
 {$ENDIF}
 vServerAuthOptions              := TRESTDWServerAuthOptionParams.Create(Self);
 vActive                         := False;
 vServerAuthOptions.AuthorizationOption                        := rdwAOBasic;
 TRESTDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username := 'testserver';
 TRESTDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password := 'testserver';
 vServerContext                  := '';
 vEncoding                       := esUtf8;
 vServicePort                    := 8082;
 vForceWelcomeAccess             := False;
 vCORS                           := False;
 vPathTraversalRaiseError        := True;
 FRootPath                       := '/';
 aDefaultUrl                     := '';
 vServiceTimeout                 := -1;
End;

Destructor TRESTServiceBase.Destroy;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   If Assigned(vCriticalSection) Then
    FreeAndNil(vCriticalSection);
  {$IFEND}
 {$ENDIF}
 FreeAndNil(vProxyOptions);
 FreeAndNil(vCripto);
 FreeAndNil(vDefaultPage);
 FreeAndNil(vCORSCustomHeaders);
 FreeAndNil(vDataRouteList);
 If Assigned(vServerAuthOptions) Then
  FreeAndNil(vServerAuthOptions);
 Inherited;
End;

Procedure TRESTDWPoolerDB.SetConnection(Value : TRESTDWDriver);
Begin
 If vRESTDriver <> Value Then
  vRESTDriver := Value;
 If vRESTDriver <> Nil   Then
  vRESTDriver.FreeNotification(Self);
End;

Function  TRESTDWPoolerDB.GetConnection : TRESTDWDriver;
Begin
 Result := vRESTDriver;
End;

Procedure TRESTDWPoolerDB.Notification(AComponent: TComponent; Operation: TOperation);
Begin
 If (Operation  = opRemove)    And
    (AComponent = vRESTDriver) Then
  vRESTDriver := Nil;
 inherited Notification(AComponent, Operation);
End;

Function TRESTDWPoolerDB.ExecuteCommand(SQL              : String;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var BinaryBlob   : TMemoryStream;
                                        Var RowsAffected : Integer;
                                        Execute          : Boolean = False) : String;
Begin
  Result := '';
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Error, MessageError, BinaryBlob, RowsAffected, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Function TRESTDWPoolerDB.ExecuteCommand(SQL              : String;
                                        Params           : TRESTDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Var BinaryBlob   : TMemoryStream;
                                        Var RowsAffected : Integer;
                                        Execute          : Boolean = False) : String;
Begin
 Result := '';
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Params, Error, MessageError, BinaryBlob, RowsAffected, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Procedure TRESTDWPoolerDB.ExecuteProcedure(ProcName       : String;
                                         Params           : TRESTDWParams;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   vRESTDriver.ExecuteProcedure(ProcName, Params, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Procedure TRESTDWPoolerDB.ExecuteProcedurePure(ProcName         : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String);
Begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   vRESTDriver.ExecuteProcedurePure(ProcName, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Function TRESTDWPoolerDB.InsertMySQLReturnID(SQL              : String;
                                           Var Error        : Boolean;
                                           Var MessageError : String) : Integer;
Begin
 Result := -1;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.InsertMySQLReturnID(SQL, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Function TRESTDWPoolerDB.InsertMySQLReturnID(SQL            : String;
                                           Params           : TRESTDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String) : Integer;
Begin
 Result := -1;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.InsertMySQLReturnID(SQL, Params, Error, MessageError);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Constructor TRESTDWPoolerDB.Create(AOwner : TComponent);
Begin
 Inherited;
 FLock             := TCriticalSection.Create;
 FLock.Acquire;
 vCompression      := True;
 vStrsTrim         := False;
 vStrsEmpty2Null   := False;
 vStrsTrim2Len     := True;
 vActive           := True;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
 {$ENDIF}
 vMessagePoolerOff := 'RESTPooler not active.';
 vParamCreate      := True;
End;

Destructor  TRESTDWPoolerDB.Destroy;
Begin
 If Assigned(FLock) Then
  Begin
   {.$IFNDEF POSIX}
   FLock.Release;
   {.$ENDIF}
   FreeAndNil(FLock);
  End;
 Inherited;
End;

{ TRESTServiceShareBase }

Constructor TRESTServiceShareBase.Create(AOwner: TComponent);
Begin
 Inherited;
 Active      := True;
 ServicePort := 0;
End;

end.
