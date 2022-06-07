unit uRESTDWBase;

{$I uRESTDW.inc}

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
 A. Brito                   - Admin - Administrador do CORE do pacote.
 Ari                        - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Ico Menezes                - Member Tester and DEMO Developer.
}

interface

//Para saber a versao da IDE do Lazarus
//uses
//  LCLVersion;
//
//{$IF LCL_FullVersion >= 2000000}
//  {$DEFINE Something}
//{$IFEND}

Uses
     {$IFDEF FPC}
     SysUtils,                        Classes,            ServerUtils, {$IFDEF WINDOWS}Windows,{$ENDIF}
     IdContext, IdTCPConnection,      IdHTTPServer,       IdCustomHTTPServer,       IdSSLOpenSSL,      IdSSL,
     IdAuthentication,                IdTCPClient,        IdHTTPHeaderInfo,         IdComponent,       IdBaseComponent,
     IdCustomTCPServer, IdTCPServer,  IdStack,            IdExceptionCore,          IdHTTP,            uDWConsts,
     uDWConstsData,                   IdMessageCoderMIME, IdMultipartFormData,      IdMessageCoder,    IdHashMessageDigest,      IdHash, IdMessage, uDWJSON,
     IdHeaderList,                    uDWJSONObject,      IdGlobal,                 IdGlobalProtocols, IdURI,
     uSystemEvents, uDWConstsCharset, HTTPDefs,           LConvEncoding, uDWAbout;
     {$ELSE}
     {$IF CompilerVersion <= 22}
     SysUtils, Classes, EncdDecd, SyncObjs,
      dwISAPIRunner, dwCGIRunner, IdHeaderList, IdHashMessageDigest,
     {$ELSE}
     System.SysUtils, System.Classes, system.SyncObjs, IdHashMessageDigest, IdHash, IdHeaderList,
     {$IF Defined(HAS_FMX)}
      {$IFDEF WINDOWS}
       dwISAPIRunner, dwCGIRunner,
      {$ELSE}
       {$IFNDEF APPLE}
        dwCGIRunner,
       {$ENDIF}
      {$ENDIF}
      {$ELSE}
       dwISAPIRunner, dwCGIRunner,
      {$IFEND}
     {$IFEND}
     {$IF Defined(HAS_FMX)}FMX.Forms,{$ELSE}{$IF CompilerVersion <= 22}Forms,{$ELSE}VCL.Forms,{$IFEND}{$IFEND}
     ServerUtils, HTTPApp, uDWAbout, idSSLOpenSSL, IdStack, uDWConstsCharset,
     IdCustomTCPServer, IdTCPServer,  IdContext, IdExceptionCore,
     {$IFDEF MSWINDOWS} Windows, {$ENDIF} uDWConsts, uDWConstsData,       IdTCPClient,
     {$IF Defined(HAS_FMX)} System.IOUtils, System.json,{$ELSE} uDWJSON,{$IFEND} IdMultipartFormData,
     IdHTTPServer,          IdCustomHTTPServer,    IdSSL, IdURI,
     IdAuthentication,      IdHTTPHeaderInfo,    IdComponent, IdBaseComponent, IdTCPConnection,
     IdHTTP,                IdMessageCoder,      uDWJSONObject,
     uSystemEvents, IdMessageCoderMIME,    IdMessage,           IdGlobalProtocols,     IdGlobal;
     {$ENDIF}


Type
 TOnCreate          = Procedure (Sender            : TObject)             Of Object;
 TLastRequest       = Procedure (Value             : String)              Of Object;
 TLastResponse      = Procedure (Value             : String)              Of Object;
 TBeforeUseCriptKey = Procedure (Request           : String;
                                 Var Key           : String)              Of Object;
 TEventContext      = Procedure (AContext          : TIdContext;
                                 ARequestInfo      : TIdHTTPRequestInfo;
                                 AResponseInfo     : TIdHTTPResponseInfo) Of Object;
 TOnWork            = Procedure (ASender           : TObject;
                                 AWorkMode         : TWorkMode;
                                 AWorkCount        : Int64)               Of Object;
 TOnBeforeExecute   = Procedure (ASender           : TObject)             Of Object;

 TOnWorkBegin       = Procedure (ASender           : TObject;
                                 AWorkMode         : TWorkMode;
                                 AWorkCountMax     : Int64)               Of Object;
 TOnWorkEnd         = Procedure (ASender           : TObject;
                                 AWorkMode         : TWorkMode)           Of Object;
 TOnStatus          = Procedure (ASender           : TObject;
                                 Const AStatus     : TIdStatus;
                                 Const AStatusText : String)              Of Object;
 TCallBack          = Procedure (Json              : String;
                                 DWParams          : TDWParams) Of Object;
 TCallSendEvent     = Function  (EventData         : String;
                                 Var Params        : TDWParams;
                                 EventType         : TSendEvent = sePOST;
                                 JsonMode          : TJsonMode  = jmDataware;
                                 ServerEventName   : String     = '';
                                 Assyncexec        : Boolean    = False;
                                 CallBack          : TCallBack  = Nil) : String Of Object;
 TRESTDWClientStage = (csNone, csLoggedIn, csRejected);

Type
 TServerMethodClass = Class(TComponent)
End;

Type
 TClassNull= Class(TComponent)
End;

Type
 TIdHTTPAccess = Class(TIdHTTP)
End;

Type
 TRESTDWDataRoute   = Class
 Private
  vDataRoute         : String;
  vServerMethodClass : TComponentClass;
 Public
  Constructor Create;
  Property DataRoute         : String           Read vDataRoute         Write vDataRoute;
  Property ServerMethodClass : TComponentClass  Read vServerMethodClass Write vServerMethodClass;
End;

Type
 PRESTDWDataRoute     = ^TRESTDWDataRoute;
 TRESTDWDataRouteList = Class(TList)
 Private
  Function  GetRec(Index : Integer) : TRESTDWDataRoute; Overload;
  Procedure PutRec(Index : Integer;
                   Item  : TRESTDWDataRoute); Overload;
  Procedure ClearList;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Function    RouteExists(Value : String) : Boolean;
  Procedure   Delete(Index : Integer); Overload;
  Function    Add   (Item  : TRESTDWDataRoute) : Integer; Overload;
  Function    GetServerMethodClass(DataRoute             : String;
                                   Var ServerMethodClass : TComponentClass) : Boolean;
  Property    Items [Index : Integer] : TRESTDWDataRoute Read GetRec Write PutRec; Default;
End;

Type
 TProxyOptions = Class(TPersistent)
 Private
  vServer,                  //Servidor Proxy na Rede
  vLogin,                   //Login do Servidor Proxy
  vPassword     : String;   //Senha do Servidor Proxy
  vPort         : Integer;  //Porta do Servidor Proxy
 Public
  Constructor Create;
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property Server        : String  Read vServer   Write vServer;   //Servidor Proxy na Rede
  Property Port          : Integer Read vPort     Write vPort;     //Porta do Servidor Proxy
  Property Login         : String  Read vLogin    Write vLogin;    //Login do Servidor
  Property Password      : String  Read vPassword Write vPassword; //Senha do Servidor
End;

Type
 TRESTDwSessionData  = Class(TCollectionItem)
End;

Type
 TRESTDwOnSessionData = Procedure (Const Sender       : TRESTDwSessionData)  Of Object;
 TRESTDwAuthError     = Procedure (Sender             : TRESTDwSessionData;
                                   Const Request      : String)              Of Object;
 TRESTDwSessionError  = Procedure (Sender             : TRESTDwSessionData;
                                   Const ErrorCode    : Integer;
                                   Const ErrorMessage : String)              Of Object;
 TConnectionRename    = Procedure (Sender             : TRESTDwSessionData;
                                   OldConnectionName,
                                   NewConnectionName  : String)              Of Object;
 TLastSockRequest     = Procedure (Sender             : TRESTDwSessionData;
                                   Value              : String)              Of Object;
 TLastSockStream      = Procedure (Sender             : TRESTDwSessionData;
                                   Const aStream      : TStream)             Of Object;
 TLastSockResponse    = Procedure (Sender             : TRESTDwSessionData;
                                   Value              : String)              Of Object;

Type
 TRESTDwSession      = Class(TRESTDwSessionData)
 Private
  {$IFNDEF FPC}
   {$IF (DEFINED(OLDINDY))}
    vDataEncoding   : TIdTextEncoding;
   {$ELSE}
    vDataEncoding   : IIdTextEncoding;
   {$IFEND}
  {$ELSE}
   vDataEncoding    : IIdTextEncoding;
  {$ENDIF}
  vRESTDwSessionError : TRESTDwSessionError;
  vClientStage        : TRESTDWClientStage;
  vAContext           : TIdContext;
  vUserGroup,
  vDataSource,
  vSessionToken,
  vLastData           : String;
  vInitalRequest,
  vLastRequest        : TDateTime;
  vLogged             : Boolean;
  Procedure   ProcessMessages;
 Public
  Function    ReceiveString            : String;
  Procedure   SendString(S             : String;
                         WaitReply     : Boolean = False);
  Procedure   SendStream(Var aStream   : TMemoryStream;
                         WaitReply     : Boolean = False);
  Procedure   SendBytes (aBuf          : TIdBytes;
                         WaitReply     : Boolean = False);
  Procedure   Kick      (Gracefully    : Boolean = False);
  Constructor Create;
  Property    Connection     : String              Read vDataSource         Write vDataSource;
  Property    Socket         : TIdContext          Read vAContext           Write vAContext;
  Property    SessionToken   : String              Read vSessionToken       Write vSessionToken;
  Property    SessionData    : String              Read vLastData           Write vLastData;
  Property    UserGroup      : String              Read vUserGroup          Write vUserGroup;
  Property    InitalRequest  : TDateTime           Read vInitalRequest;
  Property    LastRequest    : TDateTime           Read vLastRequest;
  Property    ClientStage    : TRESTDWClientStage  Read vClientStage;
  Property    Logged         : Boolean             Read vLogged;
  Property    OnSessionError : TRESTDwSessionError Read vRESTDwSessionError Write vRESTDwSessionError;
End;

Type
 TRESTDwSessionsList = Class(TDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner               : TPersistent;               Override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TRESTDwSession; Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TRESTDwSession);           Overload;
  Function    GetRecName(Index       : String)  : TRESTDwSession; Overload;
 Public
  Function    Count                  : Integer;
  Function    Add                    : TRESTDwSession;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Property    Items        [Index    : Integer]  : TRESTDwSession Read GetRec Write PutRec;
  Property    ContextByName[Index    : String ]  : TRESTDwSession Read GetRecName;
End;

Type
 TRESTDWServiceNotification = Class(TDWComponent)
 Protected
  Procedure  Execute(AContext    : TIdContext);
 Private
  vLoginMessage                  : String;
  vMultiCORE,
  vForceWelcomeAccess,
  vActive                        : Boolean;
  vServicePort,
  vServiceTimeout                : Integer;
  aServerMethod                  : TComponentClass;
  vIdTCPServer                   : TIdTCPServer;
  vSessions                      : TRESTDwSessionsList;
  vServerAuthOptions             : TRDWServerAuthOptionParams;
  vOnDisconnect,
  vOnConnect,
  vOnAuthAccept                  : TRESTDwOnSessionData;
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
  vRESTDwSessionError            : TRESTDwSessionError;
  vRESTDwAuthError               : TRESTDwAuthError;
  {$IFDEF FPC}
  vDatabaseCharSet               : TDatabaseCharSet;
  {$ENDIF}
  Procedure  ProcessMessages;
  Procedure  SetAccessTag(Value  : String);
  Function   GetAccessTag        : String;
  Function   GetSessions         : TRESTDwSessionsList;
  Procedure  SetActive (Value    : Boolean);
  Procedure  Disconnect(AContext : TIdContext);
  Procedure  Connect   (AContext : TIdContext);
  Procedure  SetServerAuthOptions(AuthenticationOptions : TRDWServerAuthOptionParams);
  Procedure  SetServerMethod(Value                      : TComponentClass);
  Procedure  ClearList;
 Public
  Procedure   Delete             (Index                 : Integer   );Overload;
  Constructor Create             (AOwner                : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override; //Destroy a Classe
  Function    SendMessage     (aUser            : String;
                               aMessage         : String;
                               Var ErrorMessage : String) : Boolean;
  Function    SendStream      (aUserSource,
                               aUserDest        : String;
                               Var aStream      : TMemoryStream;
                               Var ErrorMessage : String) : Boolean;
  Procedure   BroadcastMessage(aMessage : String);Overload;
  Procedure   BroadcastStream (Var aStream    : TMemoryStream);
  Procedure   Kickall;
  Procedure   Kickuser        (aUser          : String);
 Published
  Property Active                : Boolean                    Read vActive                Write SetActive;
  Property ForceWelcomeAccess    : Boolean                    Read vForceWelcomeAccess    Write vForceWelcomeAccess;
  Property AuthenticationOptions : TRDWServerAuthOptionParams Read vServerAuthOptions     Write SetServerAuthOptions;
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
  Property Sessions              : TRESTDwSessionsList        Read GetSessions;
  Property AccessTag             : String                     Read vAccessTag             Write vAccessTag;
  Property LoginMessage          : String                     Read vLoginMessage          Write vLoginMessage;
  Property OnConnect             : TRESTDwOnSessionData       Read vOnConnect             Write vOnConnect;
  Property OnDisconnect          : TRESTDwOnSessionData       Read vOnDisconnect          Write vOnDisconnect;
  Property OnAuthAccept          : TRESTDwOnSessionData       Read vOnAuthAccept          Write vOnAuthAccept;
  Property OnAuthError           : TRESTDwAuthError           Read vRESTDwAuthError       Write vRESTDwAuthError;
  Property OnWelcomeMessage      : TNotifyWelcomeMessage      Read vNotifyWelcomeMessage  Write vNotifyWelcomeMessage;
  Property OnSessionError        : TRESTDwSessionError        Read vRESTDwSessionError    Write vRESTDwSessionError;
  Property OnReceiveMessage      : TLastSockRequest           Read vReceiveMessage        Write vReceiveMessage;
  Property OnReceiveStream       : TLastSockStream            Read vReceiveStream         Write vReceiveStream;
  Property OnLastRequest         : TLastSockRequest           Read vLastRequest           Write vLastRequest;
  Property OnLastResponse        : TLastSockResponse          Read vLastResponse          Write vLastResponse;
  Property OnConnectionRename    : TConnectionRename          Read vOnConnectionRename    Write vOnConnectionRename;
End;

Type
 TRESTServicePooler = Class(TDWComponent)
 Protected
  Procedure aCommandGet  (AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
  Procedure aCommandOther(AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
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
   {$IF Defined(HAS_FMX)}
    {$IFDEF WINDOWS}
     vDWISAPIRunner     : TDWISAPIRunner;
     vDWCGIRunner       : TDWCGIRunner;
    {$ENDIF}
   {$ELSE}
    vDWISAPIRunner      : TDWISAPIRunner;
    vDWCGIRunner        : TDWCGIRunner;
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
  HTTPServer           : TIdHTTPServer;
  vServiceTimeout,
  vServicePort         : Integer;
  vCripto              : TCripto;
  aServerMethod        : TComponentClass;
  vDataRouteList       : TRESTDWDataRouteList;
  vServerAuthOptions   : TRDWServerAuthOptionParams;
  vLastRequest         : TLastRequest;
  vLastResponse        : TLastResponse;
  lHandler             : TIdServerIOHandlerSSLOpenSSL;
  aSSLMethod           : TIdSSLVersion;
  aSSLVersions         : TIdSSLVersions;
  vCipherList,
  vASSLRootCertFile,
  vServerContext,
  ASSLPrivateKeyFile,
  ASSLPrivateKeyPassword,
  FRootPath,
  aDefaultUrl,
  ASSLCertFile         : String;
  vEncoding            : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vSSLVerifyMode       : TIdSSLVerifyModeSet;
  vSSLVerifyDepth      : Integer;
  vSSLMode             : TIdSSLMode;
  vOnCreate            : TOnCreate;
  Procedure SetServerContext(Value : String);
  Procedure SetCORSCustomHeader (Value : TStringList);
  Procedure SetDefaultPage (Value : TStringList);
  Function  SSLVerifyPeer (Certificate : TIdX509; AOk : Boolean; ADepth, AError : Integer) : Boolean;
  Procedure GetSSLPassWord (Var Password              : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                                                     AnsiString
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$IFEND}
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$ENDIF});
  Procedure SetActive      (Value                     : Boolean);
  Function  GetSecure : Boolean;
  Procedure SetServerMethod(Value                     : TComponentClass);
  Procedure Loaded; Override;
  Procedure GetTableNames            (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetFieldNames            (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetKeyFieldNames         (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetPoolerList            (ServerMethodsClass      : TComponent;
                                      Var PoolerList          : String;
                                      AccessTag               : String);
  Function  ServiceMethods           (BaseObject              : TComponent;
                                      AContext                : TIdContext;
                                      Var UriOptions          : TRESTDWUriOptions;
                                      Var DWParams            : TDWParams;
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
                                      AContext                : TIdContext;
                                      Var Pooler, MyIP        : String;
                                      AccessTag               : String;
                                      Var InvalidTag          : Boolean);
  Procedure ExecuteCommandPureJSON   (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandPureJSONTB (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSON       (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSONTB     (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure InsertMySQLReturnID      (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSON         (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSONTB       (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure OpenDatasets             (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryRequest           : Boolean);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdates_MassiveCacheTB(ServerMethodsClass    : TComponent;
                                        Var Pooler            : String;
                                        Var DWParams          : TDWParams;
                                        ConnectionDefs        : TConnectionDefs;
                                        hEncodeStrings        : Boolean;
                                        AccessTag             : String);
  Procedure ProcessMassiveSQLCache   (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetEvents                (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var DWParams            : TDWParams);
  Function ReturnEvent               (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var vResult             : String;
                                      Var DWParams            : TDWParams;
                                      Var JsonMode            : TJsonMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType,
                                      AccessTag               : String;
                                      Const RequestType       : TRequestType;
                                      Var   RequestHeader     : TStringList) : Boolean;
  Procedure GetServerEventsList      (ServerMethodsClass      : TComponent;
                                      Var ServerEventsList    : String;
                                      AccessTag               : String);
  Function  ReturnContext            (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var vResult,
                                      ContentType             : String;
                                      Var ServerContextStream : TMemoryStream;
                                      Var Error               : Boolean;
                                      Var   DWParams          : TDWParams;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      Var ErrorCode           : Integer) : Boolean;

  {$IFDEF FPC}
  {$ELSE}
  {$IF Defined(HAS_FMX)}
   {$IFDEF WINDOWS}
    Procedure SetISAPIRunner(Value : TDWISAPIRunner);
    Procedure SetCGIRunner  (Value : TDWCGIRunner);
   {$ENDIF}
  {$ELSE}
   Procedure SetISAPIRunner(Value : TDWISAPIRunner);
   Procedure SetCGIRunner  (Value : TDWCGIRunner);
  {$IFEND}
  {$ENDIF}
  Procedure CustomOnConnect           (AContext : TIdContext);
  procedure IdHTTPServerQuerySSLPort  (APort       : Word;
                                       Var VUseSSL : Boolean);
  Procedure CreatePostStream          (AContext    : TIdContext;
                                       AHeaders    : TIdHeaderList;
                                       Var VPostStream : TStream);
  Procedure OnParseAuthentication     (AContext    : TIdContext;
                                       Const AAuthType, AAuthData: String;
                                       var VUsername, VPassword: String; Var VHandled: Boolean);
  Procedure SetServerAuthOptions(AuthenticationOptions : TRDWServerAuthOptionParams);
 Public
  Procedure ClearDataRoute;
  Procedure AddDataRoute(DataRoute : String; MethodClass : TComponentClass);
  Constructor Create       (AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                      //Destroy a Classe
 Published
  Property Active                  : Boolean                    Read vActive                  Write SetActive;
  Property CORS                    : Boolean                    Read vCORS                    Write vCORS;
  Property CORS_CustomHeaders      : TStringList                Read vCORSCustomHeaders       Write SetCORSCustomHeader;
  Property DefaultPage             : TStringList                Read vDefaultPage             Write SetDefaultPage;
  Property DefaultBaseContext      : String                     Read aDefaultUrl              Write aDefaultUrl;
  Property Secure                  : Boolean                    Read GetSecure;
  Property PathTraversalRaiseError : Boolean                    Read vPathTraversalRaiseError Write vPathTraversalRaiseError;
  Property RequestTimeout          : Integer                    Read vServiceTimeout          Write vServiceTimeout;
  Property ServicePort             : Integer                    Read vServicePort             Write vServicePort;  //A Porta do Serviço do DataSet
  Property ProxyOptions            : TProxyOptions              Read vProxyOptions            Write vProxyOptions; //Se tem Proxy diz quais as opções
  Property AuthenticationOptions   : TRDWServerAuthOptionParams Read vServerAuthOptions       Write SetServerAuthOptions;
  Property ServerMethodClass       : TComponentClass            Read aServerMethod            Write SetServerMethod;
  Property SSLPrivateKeyFile       : String                     Read aSSLPrivateKeyFile       Write aSSLPrivateKeyFile;
  Property SSLPrivateKeyPassword   : String                     Read aSSLPrivateKeyPassword   Write aSSLPrivateKeyPassword;
  Property SSLCertFile             : String                     Read aSSLCertFile             Write aSSLCertFile;
  Property SSLMethod               : TIdSSLVersion              Read aSSLMethod               Write aSSLMethod;
  Property SSLVersions             : TIdSSLVersions             Read aSSLVersions             Write aSSLVersions;
  Property OnLastRequest           : TLastRequest               Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse              Read vLastResponse            Write vLastResponse;
  Property Encoding                : TEncodeSelect              Read vEncoding                Write vEncoding;          //Encoding da string
  Property ServerContext           : String                     Read vServerContext           Write SetServerContext;
  Property RootPath                : String                     Read FRootPath                Write FRootPath;
  Property SSLRootCertFile         : String                     Read vaSSLRootCertFile        Write vaSSLRootCertFile;
  property SSLVerifyMode           : TIdSSLVerifyModeSet        Read vSSLVerifyMode           Write vSSLVerifyMode;
  property SSLVerifyDepth          : Integer                    Read vSSLVerifyDepth          Write vSSLVerifyDepth;
  property SSLMode                 : TIdSSLMode                 Read vSSLMode                 Write vSSLMode;
  Property ForceWelcomeAccess      : Boolean                    Read vForceWelcomeAccess      Write vForceWelcomeAccess;
  Property OnBeforeUseCriptKey     : TBeforeUseCriptKey         Read vBeforeUseCriptKey       Write vBeforeUseCriptKey;
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  Property CipherList              : String                     Read vCipherList              Write vCipherList;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet           Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
  Property OnCreate                : TOnCreate                  Read vOnCreate                Write vOnCreate;
  {$IFDEF FPC}
  {$ELSE}
  {$IF Defined(HAS_FMX)}
   {$IFDEF WINDOWS}
    Property ISAPIRunner             : TDWISAPIRunner             Read vDWISAPIRunner           Write SetISAPIRunner;
    Property CGIRunner               : TDWCGIRunner               Read vDWCGIRunner             Write SetCGIRunner;
   {$ENDIF}
  {$ELSE}
  Property ISAPIRunner             : TDWISAPIRunner             Read vDWISAPIRunner           Write SetISAPIRunner;
  Property CGIRunner               : TDWCGIRunner               Read vDWCGIRunner             Write SetCGIRunner;
  {$IFEND}
  {$ENDIF}
End;

Type
 TRESTServiceCGI = Class(TDWComponent)
 Private
  vDefaultPage             : TStringList;
  vPathTraversalRaiseError,
  vCORS,
  vForceWelcomeAccess      : Boolean;
  vBeforeUseCriptKey       : TBeforeUseCriptKey;
  vServerContext,
  aDefaultUrl,
  FRootPath                : String;
  vCripto                  : TCripto;
  vServerBaseMethod,
  aServerMethod            : TComponentClass;
  vServerAuthOptions       : TRDWServerAuthOptionParams;
  vDataRouteList           : TRESTDWDataRouteList;
  vLastRequest             : TLastRequest;
  vLastResponse            : TLastResponse;
  vOnCreate                : TOnCreate;
  vEncoding                : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vCORSCustomHeaders       : TStringList;
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
  Procedure Loaded; Override;
  Procedure SetServerMethod       (Value                   : TComponentClass);
  Procedure GetPoolerList         (ServerMethodsClass      : TComponent;
                                   Var PoolerList          : String;
                                   AccessTag               : String);
  Function  ServiceMethods        (BaseObject              : TComponent;
                                   AContext                : String;
                                   Var UriOptions          : TRESTDWUriOptions;
                                   Var DWParams            : TDWParams;
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
                                   Var   RequestHeader     : TStringList;
                                   BinaryEvent             : Boolean;
                                   Metadata                : Boolean;
                                   BinaryCompatibleMode    : Boolean;
                                   CompareContext          : Boolean) : Boolean;
  Procedure EchoPooler            (ServerMethodsClass      : TComponent;
                                   AContext                : String;
                                   Var Pooler, MyIP        : String;
                                   AccessTag               : String;
                                   Var InvalidTag          : Boolean);
  Procedure GetFieldNames         (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String);
  Procedure GetKeyFieldNames      (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String);
  Procedure GetTableNames         (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String);
  Procedure ExecuteCommandPureJSON(ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String;
                                   BinaryEvent             : Boolean;
                                   Metadata                : Boolean;
                                   BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandPureJSONTB(ServerMethodsClass    : TComponent;
                                     Var Pooler            : String;
                                     Var DWParams          : TDWParams;
                                     ConnectionDefs        : TConnectionDefs;
                                     hEncodeStrings        : Boolean;
                                     AccessTag             : String;
                                     BinaryEvent           : Boolean;
                                     Metadata              : Boolean;
                                     BinaryCompatibleMode  : Boolean);
  Procedure ExecuteCommandJSON    (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String;
                                   BinaryEvent             : Boolean;
                                   Metadata                : Boolean;
                                   BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSONTB  (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String;
                                   BinaryEvent             : Boolean;
                                   Metadata                : Boolean;
                                   BinaryCompatibleMode    : Boolean);
  Procedure InsertMySQLReturnID   (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String);
  Procedure ApplyUpdatesJSON      (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String);
  Procedure ApplyUpdatesJSONTB    (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String);
  Procedure OpenDatasets          (ServerMethodsClass      : TComponent;
                                   Var Pooler              : String;
                                   Var DWParams            : TDWParams;
                                   ConnectionDefs          : TConnectionDefs;
                                   hEncodeStrings          : Boolean;
                                   AccessTag               : String;
                                   BinaryRequest           : Boolean);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass   : TComponent;
                                      Var Pooler           : String;
                                      Var DWParams         : TDWParams;
                                      ConnectionDefs       : TConnectionDefs;
                                      hEncodeStrings       : Boolean;
                                      AccessTag            : String);
  Procedure ApplyUpdates_MassiveCacheTB(ServerMethodsClass : TComponent;
                                        Var Pooler         : String;
                                        Var DWParams       : TDWParams;
                                        ConnectionDefs     : TConnectionDefs;
                                        hEncodeStrings     : Boolean;
                                        AccessTag          : String);
  Procedure ProcessMassiveSQLCache   (ServerMethodsClass   : TComponent;
                                      Var Pooler           : String;
                                      Var DWParams         : TDWParams;
                                      ConnectionDefs       : TConnectionDefs;
                                      hEncodeStrings       : Boolean;
                                      AccessTag            : String);
  Procedure GetEvents                (ServerMethodsClass   : TComponent;
                                      Pooler,
                                      urlContext           : String;
                                      Var DWParams         : TDWParams);
  Function ReturnEvent               (ServerMethodsClass   : TComponent;
                                      Pooler,
                                      urlContext           : String;
                                      Var vResult          : String;
                                      Var DWParams         : TDWParams;
                                      Var JsonMode         : TJsonMode;
                                      Var ErrorCode        : Integer;
                                      Var ContentType,
                                      AccessTag            : String;
                                      Const RequestType    : TRequestType;
                                      RequestHeader        : TStringList) : Boolean;
  Procedure GetServerEventsList      (ServerMethodsClass   : TComponent;
                                      Var ServerEventsList : String;
                                      AccessTag            : String);
  Function ReturnContext             (ServerMethodsClass      : TComponent;
                                      Pooler,
                                      urlContext              : String;
                                      Var vResult,
                                      ContentType             : String;
                                      Var ServerContextStream : TMemoryStream;
                                      Var Error               : Boolean;
                                      Var   DWParams          : TDWParams;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      Var ErrorCode           : Integer): Boolean;
   Procedure SetDefaultPage            (Value                 : TStringList);
   Procedure SetServerContext          (Value                 : String);
   Procedure SetCORSCustomHeader       (Value                 : TStringList);
 Protected
   procedure Notification              (AComponent            : TComponent;
                                        Operation             : TOperation); Override;
 Public
  Procedure AddDataRoute               (DataRoute             : String;
                                        MethodClass           : TComponentClass);
  Procedure ClearDataRoute;
  {$IFDEF FPC}
   Procedure Command                   (ARequest              : TRequest;
                                        AResponse             : TResponse;
                                        Var Handled           : Boolean);
  {$ELSE}
   Procedure Command                   (ARequest              : TWebRequest;
                                        AResponse             : TWebResponse;
                                        Var Handled           : Boolean);
  {$ENDIF}
  Constructor Create                   (AOwner                : TComponent); Override; //Cria o Componente
  Destructor  Destroy;Override;                            //Destroy a Classe
 Published
  Property CORS                    : Boolean                    Read vCORS                    Write vCORS;
  Property CORS_CustomHeaders      : TStringList                Read vCORSCustomHeaders       Write SetCORSCustomHeader;
  Property DefaultPage             : TStringList                Read vDefaultPage             Write SetDefaultPage;
  Property DefaultBaseContext      : String                     Read aDefaultUrl              Write aDefaultUrl;
  Property AuthenticationOptions   : TRDWServerAuthOptionParams Read vServerAuthOptions       Write vServerAuthOptions;
  Property ServerMethodClass       : TComponentClass            Read aServerMethod            Write SetServerMethod;
  Property OnLastRequest           : TLastRequest               Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse              Read vLastResponse            Write vLastResponse;
  Property OnCreate                : TOnCreate                  Read vOnCreate                Write vOnCreate;
  Property Encoding                : TEncodeSelect              Read vEncoding                Write vEncoding;          //Encoding da string
  Property ForceWelcomeAccess      : Boolean                    Read vForceWelcomeAccess      Write vForceWelcomeAccess;
  Property ServerContext           : String                     Read vServerContext           Write SetServerContext;
  Property RootPath                : String                     Read FRootPath                Write FRootPath;
  Property OnBeforeUseCriptKey     : TBeforeUseCriptKey         Read vBeforeUseCriptKey       Write vBeforeUseCriptKey;
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet           Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
End;

Type
 TRESTDWConnectionServerCP = Class(TCollectionItem)
 Private
  vTransparentProxy     : TIdProxyConnectionInfo;
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
  vAuthOptionParams     : TRDWClientAuthOptionParams;
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
  Property AuthenticationOptions : TRDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property Authentication        : Boolean                    Read vAuthentication       Write vAuthentication      Default True;
  Property ProxyOptions          : TIdProxyConnectionInfo     Read vTransparentProxy     Write vTransparentProxy;
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
 TFailOverConnections = Class(TDWOwnedCollection)
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
 TRESTClientPooler = Class(TDWComponent) //Novo Componente de Acesso a Requisições REST para o RESTDataware
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  HttpRequest       : TIdHTTP;
  LHandler          : TIdSSLIOHandlerSocketOpenSSL;
  vCripto           : TCripto;
  Procedure SetParams      (Var aHttpRequest    : TIdHTTP;
                            Authentication      : Boolean;
                            TransparentProxy    : TIdProxyConnectionInfo;
                            RequestTimeout      : Integer;
                            ConnectTimeout      : Integer;
                            AuthorizationParams : TRDWClientAuthOptionParams);
  Procedure SetOnWork      (Value             : TOnWork);
  Procedure SetOnWorkBegin (Value             : TOnWorkBegin);
  Procedure SetOnWorkEnd   (Value             : TOnWorkEnd);
  Procedure SetOnStatus    (Value             : TOnStatus);
  Function  GetAllowCookies                   : Boolean;
  Procedure SetAllowCookies(Value             : Boolean);
  Function  GetHandleRedirects                : Boolean;
  Procedure SetHandleRedirects(Value          : Boolean);
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
  vAuthOptionParams    : TRDWClientAuthOptionParams;
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
  vHandleRedirects,
  vBinaryRequest,
  vFailOver,
  vFailOverReplaceDefaults,
  vEncodeStrings,
  vDatacompress,
  vAuthentication      : Boolean;
  vTransparentProxy    : TIdProxyConnectionInfo;
  vRequestTimeOut      : Integer;
  vConnectTimeOut      : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  vFailOverConnections : TFailOverConnections;
  Procedure SetUrlPath (Value : String);
  Procedure ReconfigureConnection(Var Connection        : TRESTClientPooler;
                                  TypeRequest           : Ttyperequest;
                                  WelcomeMessage,
                                  Host                  : String;
                                  Port                  : Integer;
                                  Compression,
                                  EncodeStrings         : Boolean;
                                  Encoding              : TEncodeSelect;
                                  AccessTag             : String;
                                  AuthenticationOptions : TRDWClientAuthOptionParams);
 Public
  //Métodos, Propriedades, Variáveis, Procedures e Funções Publicas
  Procedure   NewToken;
  Function    RenewToken  (Var Params       : TDWParams;
                           Var Error        : Boolean;
                           Var MessageError : String) : String;
  Procedure   SetAccessTag(Value            : String);
  Function    GetAccessTag                  : String;
  Function    SendEvent   (EventData        : String)          : String;Overload;
  Function    SendEvent   (EventData        : String;
                           Var Params       : TDWParams;
                           EventType        : TSendEvent = sePOST;
                           JsonMode         : TJsonMode  = jmDataware;
                           ServerEventName  : String     = '';
                           Assyncexec       : Boolean    = False) : String;Overload;
  Procedure   SetAuthOptionParams(Value     : TRDWClientAuthOptionParams);
  Constructor Create      (AOwner           : TComponent);Override;
  Destructor  Destroy;Override;
  Procedure   Abort;
  Property    ErrorCode            : Integer                    Read vErrorCode;
 Published
  //Métodos e Propriedades
  Property DataCompression         : Boolean                    Read vDatacompress            Write vDatacompress;
  Property UrlPath                 : String                     Read vUrlPath                 Write SetUrlPath;
  Property ServerContext           : String                     Read vServerContext           Write vServerContext;
  Property DataRoute               : String                     Read vDataRoute               Write vDataRoute;
  Property Encoding                : TEncodeSelect              Read vRSCharset               Write vRSCharset;
  Property hEncodeStrings          : Boolean                    Read vEncodeStrings           Write vEncodeStrings;
  Property TypeRequest             : TTypeRequest               Read vTypeRequest             Write vTypeRequest         Default trHttp;
  Property ThreadRequest           : Boolean                    Read vPropThreadRequest       Write vPropThreadRequest;
  Property Host                    : String                     Read vHost                    Write vHost;
  Property Port                    : Integer                    Read vPort                    Write vPort                Default 8082;
  Property AuthenticationOptions   : TRDWClientAuthOptionParams Read vAuthOptionParams        Write SetAuthOptionParams;
  Property ProxyOptions            : TIdProxyConnectionInfo     Read vTransparentProxy        Write vTransparentProxy;
  Property RequestTimeOut          : Integer                    Read vRequestTimeOut          Write vRequestTimeOut;
  Property ConnectTimeOut          : Integer                    Read vConnectTimeOut          Write vConnectTimeOut;
  Property AllowCookies            : Boolean                    Read GetAllowCookies          Write SetAllowCookies;
  Property RedirectMaximum         : Integer                    Read vRedirectMaximum         Write vRedirectMaximum;
  Property HandleRedirects         : Boolean                    Read GetHandleRedirects       Write SetHandleRedirects;
  Property WelcomeMessage          : String                     Read vWelcomeMessage          Write vWelcomeMessage;
  Property AccessTag               : String                     Read vAccessTag               Write vAccessTag;
  Property OnWork                  : TOnWork                    Read vOnWork                  Write SetOnWork;
  Property OnWorkBegin             : TOnWorkBegin               Read vOnWorkBegin             Write SetOnWorkBegin;
  Property OnWorkEnd               : TOnWorkEnd                 Read vOnWorkEnd               Write SetOnWorkEnd;
  Property OnStatus                : TOnStatus                  Read vOnStatus                Write SetOnStatus;
  Property OnFailOverExecute       : TOnFailOverExecute         Read vOnFailOverExecute       Write vOnFailOverExecute;
  Property OnFailOverError         : TOnFailOverError           Read vOnFailOverError         Write vOnFailOverError;
  Property OnBeforeExecute         : TOnBeforeExecute           Read vOnBeforeExecute         Write vOnBeforeExecute;
  Property OnBeforeGetToken        : TOnBeforeGetToken          Read vOnBeforeGetToken        Write vOnBeforeGetToken;
  Property FailOver                : Boolean                    Read vFailOver                Write vFailOver;
  Property FailOverConnections     : TFailOverConnections       Read vFailOverConnections     Write vFailOverConnections;
  Property FailOverReplaceDefaults : Boolean                    Read vFailOverReplaceDefaults Write vFailOverReplaceDefaults;
  Property BinaryRequest           : Boolean                    Read vBinaryRequest           Write vBinaryRequest;
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  Property UserAgent               : String                     Read vUserAgent               Write vUserAgent;
  Property PoolerNotFoundMessage   : String                     Read vPoolerNotFoundMessage   Write vPoolerNotFoundMessage;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet           Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
End;

Function GetTokenString (Value : String) : String;
Function GetBearerString(Value : String) : String;
Function RemoveBackslashCommands(Value : String) : String;
Function GetEventNameX  (Value : String) : String;
{$IFNDEF FPC}
  {$IF CompilerVersion > 22} // Delphi 2010 pra cima
    {$IF DEFINED(iOS) or DEFINED(ANDROID)}
    Procedure SaveLog(Value, FileName : String);
    {$IFEND}
  {$IFEND}
{$ENDIF}

implementation

Uses uDWDatamodule, uRESTDWPoolerDB, SysTypes, uDWJSONTools, uRESTDWServerEvents,
     uRESTDWServerContext, uDWJSONInterface, uDWPoolerMethod;


{$IFNDEF FPC}
  {$IF CompilerVersion > 22} // Delphi 2010 pra cima
    {$IF DEFINED(iOS) or DEFINED(ANDROID)}
    Procedure SaveLog(Value, FileName : String);
    Var
     StringStream : TStringStream;
    Begin
     StringStream := TStringStream.Create(Value);
     Try
      StringStream.Position := 0;
      StringStream.SaveToFile(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetSharedDocumentsPath, FileName)); //Log FMX
     Finally
      FreeAndNil(StringStream);
     End;
    End;
    {$IFEND}
  {$IFEND}
{$ENDIF}

Function GetTokenString(Value : String) : String;
Var
 vPos : Integer;
Begin
 Result := '';
 vPos   := Pos('token=', Lowercase(Value));
 If vPos > 0 Then
  vPos  := vPos + Length('token=')
 Else
  Begin
   vPos := Pos('basic ', Lowercase(Value));
   If vPos > 0 Then
    vPos := vPos + Length('basic ');
  End;
 If vPos > 0 Then
  Result := Trim(Copy(Value, vPos, Length(Value)));
 If Trim(Result) <> '' Then
  Result := StringReplace(Result, '"', '', [rfReplaceAll]);
End;

Function GetEventNameX  (Value : String) : String;
Begin
 Result := Value;
 If Pos('.', Result) > 0 Then
  Result := Copy(Result, Pos('.', Result) + 1, Length(Result));
End;

Function TravertalPathFind(Value : String) : Boolean;
Begin
 Result := Pos('../', Value) > 0;
 If Not Result Then
  Result := Pos('..\', Value) > 0;
End;

Function RemoveBackslashCommands(Value : String) : String;
Begin
 Result := StringReplace(Value, '../', '', [rfReplaceAll]);
 Result := StringReplace(Result, '..\', '', [rfReplaceAll]);
End;

Function GetBearerString(Value : String) : String;
Var
 vPos : Integer;
Begin
 Result := '';
 vPos   := Pos('bearer', Lowercase(Value));
 If vPos > 0 Then
  vPos  := vPos + Length('bearer');
 If vPos > 0 Then
  Result := Trim(Copy(Value, vPos, Length(Value)));
 If Trim(Result) <> '' Then
  Result := StringReplace(Result, '"', '', [rfReplaceAll]);
End;

Procedure DeleteInvalidChar(Var Value : String);
Begin
 If Length(Value) > 0 Then
  If Value[InitStrPos] <> '{' then
   Delete(Value, 1, 1);
 If Length(Value) > 0 Then
  If Value[Length(Value) - FinalStrPos] <> '{' then
   Delete(Value, Length(Value), 1);
End;

Function GetParamsReturn(Params : TDWParams) : String;
Var
 A, I : Integer;
Begin
 A := 0;
 Result := '';
 If Assigned(Params) Then
  Begin
   For I := 0 To Params.Count -1 Do
    Begin
     If TJSONParam(TList(Params).Items[I]^).ObjectDirection in [odOUT, odINOUT] Then
      Begin
       If A = 0 Then
        Result := TJSONParam(TList(Params).Items[I]^).ToJSON
       Else
        Result := Result + ', ' + TJSONParam(TList(Params).Items[I]^).ToJSON;
       Inc(A);
      End;
    End;
  End;
 If Trim(Result) = '' Then
  Result := 'null';
End;

{ TRESTServiceCGI }

{$IFDEF FPC}
procedure TRESTServiceCGI.Command(ARequest: TRequest; AResponse: TResponse;
                                  Var Handled: Boolean);
{$ELSE}
procedure TRESTServiceCGI.Command(ARequest: TWebRequest; AResponse: TWebResponse;
  var Handled: Boolean);
{$ENDIF}
Var
 aParamsCount,
 I, vErrorCode       : Integer;
 JsonMode            : TJsonMode;
 DWParamsD,
 DWParams            : TDWParams;
 vFileName,
 vObjectName,
 vOldMethod,
 vBasePath,
 vWelcomeMessage,
 vAccessTag,
 vIPVersion,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 vTempCmd,
 vCORSOption,
 vTempText,
 Cmd, vmark,
// UrlMethod,
// urlContext,
 tmp, JSONStr,
 sFile,
 authDecode,
 sCharSet,
 aurlContext,
 baseEventUnit,
 ServerEventsName,
 vErrorMessage,
 vContentType,
 vAuthUsername,
 vAuthPassword,
 vUrlToken,
 vAuthenticationString,
 aToken,
 vToken,
 ReturnObject        : String;
 vdwConnectionDefs   : TConnectionDefs;
 RequestType         : TRequestType;
 vTempServerMethods  : TObject;
 newdecoder,
 Decoder             : TIdMessageDecoder;
 JSONParam           : TJSONParam;
 JSONValue           : TJSONValue;
 vAuthTokenParam     : TRDWAuthOptionTokenServer;
 vMetadata,
 vBinaryEvent,
 vBinaryCompatibleMode,
 dwassyncexec,
 vFileExists,
 vServerContextCall,
 vTagReply,
 WelcomeAccept,
 encodestrings,
 compresseddata,
 vdwCriptKey,
 vAcceptAuth,
 vGettoken,
 vTokenValidate,
 vNeedAuthorization,
 msgEnd,
 vCompareContext     : Boolean;
 mb,
 vContentStringStream,
 ms                  : TStringStream;
 mb2                 : TStringStream;
 ServerContextStream : TMemoryStream;
 vUriOptions         : TRESTDWUriOptions;
 vServerMethod       : TComponentClass;
 vRDWAuthOptionParam : TRDWAuthOptionParam;
 vParamList,
 vRequestHeader,
 vLog                : TStringList;
 vTempContext        : TDWContext;
 vTempEvent          : TDWEvent;
 Procedure SaveLog(DebbugValue : String);
 var
  i: integer;
 Begin
  vLog := TStringList.Create;
  vLog.Add(ARequest.ContentFields.Text);
  vLog.Add('**********************');
  vLog.Add('DebbugValue =>> ' + Trim(DebbugValue));
  {$IFNDEF FPC}
   vLog.Add('Cmd = ' + Trim(RemoveBackslashCommands(ARequest.URL)));
  {$ELSE}
   vLog.Add('Cmd =>> ' + Trim(RemoveBackslashCommands(ARequest.CommandLine)));
  {$ENDIF}
  vLog.Add('PathInfo =>> ' + Trim(RemoveBackslashCommands(ARequest.PathInfo)));
  {$IFNDEF FPC}
  vLog.Add('Title = ' + ARequest.Title);
  {$ELSE}
  vLog.Add('HeaderLine =>> ' + ARequest.HeaderLine);
  {$ENDIF}
  vLog.Add('Content =>> ' +  ARequest.Content);
  vLog.Add('Query =>> ' +  ARequest.Query);
  If vServerAuthOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken] Then
   vLog.Add('HasAuthentication =>> true')
  Else
   vLog.Add('HasAuthentication =>> false');
  vLog.Add('Authorization =>> ' +  ARequest.Authorization);
  {$IFNDEF FPC}
  vLog.Add('ContentFields.Count = ' +  IntToStr(ARequest.ContentFields.Count));
  {$ELSE}
  vLog.Add('FieldCount =>> ' +  IntToStr(ARequest.FieldCount));
  for i := 0 to ARequest.FieldCount -1 Do
   vLog.Add(Format('Field[%d] = %s', [I, ARequest.Fields[I]]));
  {$ENDIF}
  vLog.Add('ContentFields =>> ' +  ARequest.ContentFields.Text);
  {$IFNDEF FPC}
  vLog.Add('PathTranslated = ' + ARequest.PathTranslated);
  {$ELSE}
  vLog.Add('LocalPathPrefix =>> ' + ARequest.LocalPathPrefix);
  {$ENDIF}
  vLog.Add('UrlMethod =>> ' + vUriOptions.EventName);
  vLog.Add('urlContext =>> ' + vUriOptions.ServerEvent);
  vLog.Add('Method =>> ' + ARequest.Method);
  vLog.Add('File =>> ' + sFile);
  If DWParams <> Nil Then
   vLog.Add('DWParams =>> ' +  DWParams.ToJSON);
  //vLog.SaveToFile(ExtractFilePath(ParamSTR(0)) + formatdatetime('ddmmyyyyhhmmss', Now) + 'log.txt');
  vLog.SaveToFile('.\' + formatdatetime('ddmmyyyyhhmmss', Now) + 'log.txt');
  vLog.Free;
 End;
 Function ExcludeTag(Value : String) : String;
 Begin
  Result := Value;
  If (UpperCase(Copy (Value, InitStrPos, 3)) = 'GET')    or
     (UpperCase(Copy (Value, InitStrPos, 4)) = 'POST')   or
     (UpperCase(Copy (Value, InitStrPos, 3)) = 'PUT')    or
     (UpperCase(Copy (Value, InitStrPos, 6)) = 'DELETE') or
     (UpperCase(Copy (Value, InitStrPos, 5)) = 'PATCH')  Then
   Begin
    While (Result <> '') And (Result[InitStrPos] <> '/') Do
     Delete(Result, InitStrPos, 1);
   End;
  If Result <> '' Then
   If Result[InitStrPos] = '/' Then
    Delete(Result, InitStrPos, 1);
  Result := Trim(Result);
 End;
 Function GetFileOSDir(Value : String) : String;
 Begin
  Result := vBasePath + Value;
  {$IFDEF MSWINDOWS}
   Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  {$ENDIF}
 End;
 Function GetLastMethod(Value : String) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> '' Then
   Begin
    If Value[Length(Value) - FinalStrPos] <> '/' Then
     Begin
      For I := (Length(Value) - FinalStrPos) Downto InitStrPos Do
       Begin
        If Value[I] <> '/' Then
         Result := Value[I] + Result
        Else
         Break;
       End;
     End;
   End;
 End;
 procedure ReadRawHeaders;
 Var
  I : Integer;
  {$IFNDEF FPC}
  vStringListQuery,
  vStringListForm   : TStringList;
  Procedure ReadHeader(Value : TStringList);
  Var
   I : Integer;
  Begin
   For I := 0 To Value.Count -1 Do
    Begin
     tmp := Value.Names[I];
     If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
      vWelcomeMessage := DecodeStrings(Value.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
     Else If pos('BinaryCompatibleMode', lowercase(tmp)) > 0 Then
      vBinaryCompatibleMode := StringToBoolean(Value.Values[tmp])
     Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
      vAccessTag := DecodeStrings(Value.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
     Else If pos('datacompression', lowercase(tmp)) > 0 Then
      compresseddata := StringToBoolean(Value.Values[tmp])
     Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
      encodestrings  := StringToBoolean(Value.Values[tmp])
     Else If pos('dwusecript', lowercase(tmp)) > 0 Then
      vdwCriptKey    := StringToBoolean(Value.Values[tmp])
     Else If (pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
      dwassyncexec   := StringToBoolean(Value.Values[tmp])
     Else If pos('binaryrequest', lowercase(tmp)) > 0 Then
      vBinaryEvent   := StringToBoolean(Value.Values[tmp])
     Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
      Begin
       vdwConnectionDefs   := TConnectionDefs.Create;
       JSONValue           := TJSONValue.Create;
       Try
        JSONValue.Encoding  := vEncoding;
        JSONValue.Encoded  := True;
        JSONValue.LoadFromJSON(Value.Values[tmp]);
        vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
       Finally
        FreeAndNil(JSONValue);
       End;
      End
     Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
      Begin
       JSONValue           := TJSONValue.Create;
       Try
        JSONValue.Encoding  := vEncoding;
        JSONValue.Encoded  := True;
        {$IFDEF FPC}
        JSONValue.DatabaseCharSet := vDatabaseCharSet;
        {$ENDIF}
        JSONValue.LoadFromJSON(Value.Values[tmp]);
        If ((vUriOptions.BaseServer = '')  And
            (vUriOptions.DataUrl    = '')) And
           (vUriOptions.ServerEvent <> '') Then
         vUriOptions.BaseServer := vUriOptions.ServerEvent
        Else If ((vUriOptions.BaseServer <> '') And
                 (vUriOptions.DataUrl    = '')) And
                (vUriOptions.ServerEvent <> '') And
                 (vServerContext = '')          Then
         Begin
          vUriOptions.DataUrl    := vUriOptions.BaseServer;
          vUriOptions.BaseServer := vUriOptions.ServerEvent;
         End;
        vUriOptions.ServerEvent := JSONValue.Value;
        If Pos('.', vUriOptions.ServerEvent) > 0 Then
         Begin
          baseEventUnit           := Copy(vUriOptions.ServerEvent, InitStrPos, Pos('.', vUriOptions.ServerEvent) - 1 - FinalStrPos);
          vUriOptions.ServerEvent := Copy(vUriOptions.ServerEvent, Pos('.', vUriOptions.ServerEvent) + 1, Length(vUriOptions.ServerEvent));
         End;
       Finally
        FreeAndNil(JSONValue);
       End;
      End
     Else
      Begin
       If Not Assigned(DWParams) Then
        Begin
         aParamsCount := cParamsCount;
         If ServerContext <> '' Then
          Inc(aParamsCount);
         If vDataRouteList.Count > 0 Then
          Inc(aParamsCount);
         TServerUtils.ParseWebFormsParams (ARequest.ContentFields, Cmd, ARequest.Query,
                                           vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
         If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
          vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
          vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         If DWParams.ItemsString['datacompression'] <> Nil Then
          compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
         If DWParams.ItemsString['dwencodestrings'] <> Nil Then
          encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
         If DWParams.ItemsString['dwservereventname'] <> Nil Then
          Begin
           If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
            Begin
             If ((vUriOptions.BaseServer = '')  And
                 (vUriOptions.DataUrl    = '')) And
                (vUriOptions.ServerEvent <> '') Then
              vUriOptions.BaseServer := vUriOptions.ServerEvent
             Else If ((vUriOptions.BaseServer <> '') And
                      (vUriOptions.DataUrl    = '')) And
                     (vUriOptions.ServerEvent <> '') And
                      (vServerContext = '')          Then
              Begin
               vUriOptions.DataUrl    := vUriOptions.BaseServer;
               vUriOptions.BaseServer := vUriOptions.ServerEvent;
              End;
             vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
            End;
          End;
         If DWParams.ItemsString['dwusecript'] <> Nil Then
          vdwCriptKey  := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
         If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
          dwassyncexec  := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
         If DWParams.ItemsString['binaryrequest'] <> Nil Then
          vBinaryEvent   := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
         If DWParams.itemsstring['BinaryCompatibleMode'] <> Nil Then
          vBinaryCompatibleMode := DWParams.itemsstring['BinaryCompatibleMode'].value;
        End;
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ObjectDirection := odIN;
       JSONParam.ParamName       := lowercase(tmp);
       {$IFDEF FPC}
       JSONParam.DatabaseCharSet := vDatabaseCharSet;
       {$ENDIF}
       tmp                       := Value.Values[tmp];
       If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), Lowercase(tmp)) > 0) Then
        JSONParam.FromJSON(tmp)
       Else
        JSONParam.AsString  := StringReplace(StringReplace(tmp, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);//StringReplace(tmp, sLineBreak, '', [rfReplaceAll]);
       DWParams.Add(JSONParam);
      End;
    End;
   If Assigned(DWParams) Then
    DWParams.RequestHeaders.Input.Assign(Value);
  End;
  {$ENDIF}
 begin
  {$IFDEF FPC}
  If (ARequest.CustomHeaders = Nil) Then
   Exit;
  Try
   If (ARequest.CustomHeaders.Count > 0) Then
    Begin
     vRequestHeader.Add(ARequest.CustomHeaders.Text);
     For I := 0 To ARequest.CustomHeaders.Count -1 Do
      Begin
       tmp := ARequest.CustomHeaders.Names[I];
       If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
        vWelcomeMessage := DecodeStrings(ARequest.CustomHeaders.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('BinaryCompatibleMode', lowercase(tmp)) > 0 Then
        vBinaryCompatibleMode := StringToBoolean(ARequest.CustomHeaders.Values[tmp])
       Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
        vAccessTag := DecodeStrings(ARequest.CustomHeaders.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('datacompression', lowercase(tmp)) > 0 Then
        compresseddata := StringToBoolean(ARequest.CustomHeaders.Values[tmp])
       Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
        encodestrings  := StringToBoolean(ARequest.CustomHeaders.Values[tmp])
       Else If pos('dwusecript', lowercase(tmp)) > 0 Then
        vdwCriptKey    := StringToBoolean(ARequest.CustomHeaders.Values[tmp])
       Else If (pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
        dwassyncexec   := StringToBoolean(ARequest.CustomHeaders.Values[tmp])
       Else If pos('binaryrequest', lowercase(tmp)) > 0 Then
        vBinaryEvent   := StringToBoolean(ARequest.CustomHeaders.Values[tmp])
       Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
        Begin
         vdwConnectionDefs   := TConnectionDefs.Create;
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := vEncoding;
          JSONValue.Encoded  := True;
          JSONValue.LoadFromJSON(ARequest.CustomHeaders.Values[tmp]);
          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
         Finally
          FreeAndNil(JSONValue);
         End;
        End
       Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
        Begin
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := vEncoding;
          JSONValue.Encoded  := True;
          {$IFDEF FPC}
          JSONValue.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONValue.LoadFromJSON(ARequest.CustomHeaders.Values[tmp]);
          If ((vUriOptions.BaseServer = '')  And
              (vUriOptions.DataUrl    = '')) And
             (vUriOptions.ServerEvent <> '') Then
           vUriOptions.BaseServer := vUriOptions.ServerEvent
          Else If ((vUriOptions.BaseServer <> '') And
                   (vUriOptions.DataUrl    = '')) And
                  (vUriOptions.ServerEvent <> '') And
                   (vServerContext = '')          Then
           Begin
            vUriOptions.DataUrl    := vUriOptions.BaseServer;
            vUriOptions.BaseServer := vUriOptions.ServerEvent;
           End;
          vUriOptions.ServerEvent  := JSONValue.Value;
          If Pos('.', vUriOptions.ServerEvent) > 0 Then
           Begin
            baseEventUnit           := Copy(vUriOptions.ServerEvent, InitStrPos, Pos('.', vUriOptions.ServerEvent) - 1 - FinalStrPos);
            vUriOptions.ServerEvent := Copy(vUriOptions.ServerEvent, Pos('.', vUriOptions.ServerEvent) + 1, Length(vUriOptions.ServerEvent));
           End;
         Finally
          FreeAndNil(JSONValue);
         End;
        End
       Else
        Begin
         If Not Assigned(DWParams) Then
          Begin
           aParamsCount := cParamsCount;
           If ServerContext <> '' Then
            Inc(aParamsCount);
           If vDataRouteList.Count > 0 Then
            Inc(aParamsCount);
           TServerUtils.ParseWebFormsParams (ARequest.ContentFields, Cmd, ARequest.Query,
                                             vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
           If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
            vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
           If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
            vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
           If DWParams.ItemsString['datacompression'] <> Nil Then
            compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
           If DWParams.ItemsString['dwencodestrings'] <> Nil Then
            encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
           If DWParams.ItemsString['dwservereventname'] <> Nil Then
            Begin
             If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
              Begin
               If ((vUriOptions.BaseServer = '')  And
                   (vUriOptions.DataUrl    = '')) And
                  (vUriOptions.ServerEvent <> '') Then
                vUriOptions.BaseServer := vUriOptions.ServerEvent
               Else If ((vUriOptions.BaseServer <> '') And
                        (vUriOptions.DataUrl    = '')) And
                       (vUriOptions.ServerEvent <> '') And
                        (vServerContext = '')          Then
                Begin
                 vUriOptions.DataUrl    := vUriOptions.BaseServer;
                 vUriOptions.BaseServer := vUriOptions.ServerEvent;
                End;
               vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
              End;
            End;
           If DWParams.ItemsString['dwusecript'] <> Nil Then
            vdwCriptKey  := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
           If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
            dwassyncexec  := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
           If DWParams.ItemsString['binaryrequest'] <> Nil Then
            vBinaryEvent   := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
           If DWParams.itemsstring['BinaryCompatibleMode'] <> Nil Then
            vBinaryCompatibleMode := DWParams.itemsstring['BinaryCompatibleMode'].value;
          End;
         JSONParam                 := TJSONParam.Create(DWParams.Encoding);
         JSONParam.ObjectDirection := odIN;
         JSONParam.ParamName       := lowercase(tmp);
         {$IFDEF FPC}
         JSONParam.DatabaseCharSet := vDatabaseCharSet;
         {$ENDIF}
         tmp                       := ARequest.CustomHeaders.Values[tmp];
         If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), Lowercase(tmp)) > 0) Then
          JSONParam.FromJSON(tmp)
         Else
          JSONParam.AsString  := StringReplace(StringReplace(tmp, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);//StringReplace(tmp, sLineBreak, '', [rfReplaceAll]);
         DWParams.Add(JSONParam);
        End;
      End;
    End;
  Finally
   If Assigned(DWParams) Then
    DWParams.RequestHeaders.Input.Assign(ARequest.CustomHeaders);
   tmp := '';
  End;
  {$ELSE}
   //Comentado por falta de necessidade de uso (XyberX)
//   vStringListQuery  := TStringList.Create;
//   vStringListForm   := TStringList.Create;
//   Try
//    ARequest.ExtractContentFields(vStringListForm);
//    ARequest.ExtractQueryFields(vStringListQuery);
////    ReadHeader(vStringListForm);
////    ReadHeader(vStringListQuery);
//   Finally
//    FreeAndNil(vStringListQuery);
//    FreeAndNil(vStringListForm);
//   End;
  {$ENDIF}
 End;
 Procedure PrepareBasicAuth(AuthenticationString : String; Var AuthUsername, AuthPassword : String);
 Begin
  AuthUsername := Copy(AuthenticationString, InitStrPos, Pos(':', AuthenticationString) -1);
  Delete(AuthenticationString, InitStrPos, Pos(':', AuthenticationString));
  AuthPassword := AuthenticationString;
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(vdwConnectionDefs) Then
   FreeAndNil(vdwConnectionDefs);
  If Assigned(vRequestHeader)    Then
   FreeAndNil(vRequestHeader);
  If Assigned(vRDWAuthOptionParam) Then
   FreeAndNil(vRDWAuthOptionParam);
  If Assigned(vAuthTokenParam)   Then
   FreeAndNil(vAuthTokenParam);
  If Assigned(vServerMethod) Then
   If Assigned(vTempServerMethods) Then
    Begin
     Try
      {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
      {$ELSE}
      FreeAndNil(vTempServerMethods); //.free;
      {$ENDIF}
     Except
     End;
    End;
 End;
 Procedure WriteError;
 Begin
  {$IFDEF FPC}
   If vEncoding = esUtf8 Then
    mb                              := TStringStream.Create(Utf8Encode(vErrorMessage))
   Else
    mb                              := TStringStream.Create(vErrorMessage);
  {$ELSE}
   mb                               := TStringStream.Create(vErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
  {$ENDIF}
  mb.Position                      := 0;
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21}
    AResponse.FreeContentStream      := True;
   {$IFEND}
  {$ELSE}
   AResponse.FreeContentStream       := True;
  {$ENDIF}
   AResponse.ContentStream           := mb;
   AResponse.ContentStream.Position   := 0;
   AResponse.ContentLength            := AResponse.ContentStream.Size;
   {$IFNDEF FPC}
    AResponse.StatusCode              := vErrorCode;
   {$ELSE}
    AResponse.Code                    := vErrorCode;
   {$ENDIF}
   Handled := True;
   {$IFNDEF FPC}
    AResponse.SendResponse;
   {$ELSE}
    AResponse.SendResponse;
   {$ENDIF}
   {$IFNDEF FPC}
    {$IF CompilerVersion < 21}
     If Assigned(mb) Then
      FreeAndNil(mb); // Ico Menezes (retirada de Leaks) 05/02/2020
    {$IFEND}
   {$ENDIF}
 End;
 Function ReturnEventValidation(ServerMethodsClass : TComponent;
                                Pooler,
                                urlContext         : String) : TDWEvent;
 Var
  vTagService : Boolean;
  I           : Integer;
 Begin
  Result        := Nil;
  vTagService   := False;
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TDWServerEvents Then
       Begin
        If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) Or
           (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name))  Or
           (LowerCase(urlContext) = LowerCase(ServerMethodsClass.classname + '.' +
                                              ServerMethodsClass.Components[i].Name))  Then
         vTagService := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
        If vTagService Then
         Begin
          Result   := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler];
          Break;
         End;
       End;
     End;
   End;
 End;
 Function ReturnContextValidation(ServerMethodsClass : TComponent;
                                  Var UriOptions     : TRESTDWUriOptions) : TDWContext;
 Var
  I            : Integer;
  vTagService  : Boolean;
  aEventName,
  aServerEvent,
  vRootContext : String;
 Begin
  Result        := Nil;
  vRootContext  := '';
  aEventName    := UriOptions.EventName;
  aServerEvent  := UriOptions.ServerEvent;
  If (aEventName <> '') And (aServerEvent = '') Then
   Begin
    aServerEvent := aEventName;
    aEventName   := '';
   End;
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TDWServerContext Then
       Begin
        If ((LowerCase(aServerEvent) = LowerCase(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext))) Or
           ((Trim(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext) = '') And (aEventName = '')        And
            (TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aServerEvent] <> Nil))   Then
         Begin
          vRootContext := TDWServerContext(ServerMethodsClass.Components[i]).RootContext;
          If ((aEventName = '')    And (vRootContext <> '')) Then
           aEventName := vRootContext;
          vTagService := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aEventName] <> Nil;
          If vTagService Then
           Begin
            Result := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aEventName];
            Break;
           End;
         End;
       End;
     End;
   End;
 End;
 Function ClearRequestType(Value : String) : String;
 Begin
  Result := Value;
  If (Pos('GET ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'GET ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('POST ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'POST ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PUT ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PUT ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('DELETE ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'DELETE ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PATCH ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PATCH ', '', [rfReplaceAll, rfIgnoreCase]);
 End;
 Function CompareBaseURL(Var Value : String) : Boolean;
 Var
  vTempValue : String;
 Begin
  Result := False;
  If aDefaultUrl <> '' Then
   Begin
    If Value = '/' Then
     Value := aDefaultUrl
    Else
     Begin
      vTempValue := Copy(Value, InitStrPos, Length(aDefaultUrl));
      If Lowercase(vTempValue) <> Lowercase(aDefaultUrl) Then
       Begin
        Value  := aDefaultUrl + Value;
        Result := True;
       End;
     End;
   End;
 End;
Begin
 vRDWAuthOptionParam   := Nil;
 vContentType          := '';
 vAccessTag            := '';
 vErrorMessage         := '';
 vIPVersion            := 'undefined';
 vBasePath             := FRootPath;
 JsonMode              := jmDataware;
 vErrorCode            := 200;
 dwassyncexec          := False;
 baseEventUnit         := '';
 vdwConnectionDefs     := Nil;
 vTempServerMethods    := Nil;
 DWParams              := Nil;
 mb                    := Nil;
 mb2                   := Nil;
 ServerContextStream   := Nil;
 compresseddata        := False;
 encodestrings         := False;
 vdwCriptKey           := False;
 vTagReply             := False;
 vBinaryEvent          := False;
 vBinaryCompatibleMode := False;
 vMetadata             := False;
 vServerContextCall    := False;
 vServerMethod         := Nil;
 vRequestHeader        := TStringList.Create;
 vUriOptions           := TRESTDWUriOptions.Create;
 aParamsCount          := cParamsCount;
 Try
  {$IFNDEF FPC}
  Cmd := RemoveBackslashCommands(Trim(ARequest.PathInfo));
  {$if CompilerVersion > 30}
   If vCORS Then
    Begin
     If vCORSCustomHeaders.Count > 0 Then
      Begin
       For I := 0 To vCORSCustomHeaders.Count -1 Do
        AResponse.CustomHeaders.AddPair(vCORSCustomHeaders.Names[I], vCORSCustomHeaders.ValueFromIndex[I]);
      End
     Else
      AResponse.CustomHeaders.AddPair('Access-Control-Allow-Origin', '*');
    End;
  {$ELSE}
   If vCORS Then
    Begin
     If vCORSCustomHeaders.Count > 0 Then
      Begin
       For I := 0 To vCORSCustomHeaders.Count -1 Do
        AResponse.CustomHeaders.Add(vCORSCustomHeaders[I]);
      End
     Else
      AResponse.CustomHeaders.Add('Access-Control-Allow-Origin=*');
    End;
  {$IFEND}
 {$ELSE}
  Cmd := RemoveBackslashCommands(Trim(ARequest.PathInfo));
  If vCORS Then
   Begin
    If (vCORSCustomHeaders.Count > 0) Then
     Begin
      For I := 0 To vCORSCustomHeaders.Count -1 Do
       AResponse.SetCustomHeader(vCORSCustomHeaders.Names[I], vCORSCustomHeaders.ValueFromIndex[I]);
     End
    Else
     AResponse.SetCustomHeader('Access-Control-Allow-Origin', '*');
   End;
 {$ENDIF}
  sCharSet := '';
  vContentStringStream := Nil;
  Cmd := ClearRequestType(Cmd);
  If Cmd <> '' Then
   TServerUtils.ParseRESTURL (ClearRequestType(Cmd), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
 {$IFNDEF FPC}
  If ARequest.ContentLength > 0 Then
   Begin
   {$IF CompilerVersion > 29}
   ARequest.ReadTotalContent;
   If Length(ARequest.RawContent) > 0 Then
    Begin
     vContentStringStream := TStringStream.Create('');
     vContentStringStream.Write(TBytes(ARequest.RawContent),
                                Length(ARequest.RawContent));
     vContentStringStream.Position := 0;
     vRequestHeader.Text := vContentStringStream.DataString;
     vBinaryEvent := (Pos('"binarydata"', lowercase(vRequestHeader.Text)) > 0);
    End
   Else
   {$IFEND}
 {$ELSE}
 If (Trim(ARequest.Content) <> '') Then
  Begin
 {$ENDIF}
   vRequestHeader.Add(ARequest.Content);
   If vContentStringStream = Nil Then
    vContentStringStream := TStringStream.Create(ARequest.Content);
   vContentStringStream.Position := 0;
   If (pos('--', vContentStringStream.DataString) > 0) Then
    Begin
     vRequestHeader.Text := vContentStringStream.DataString;
     Try
      msgEnd   := False;
      {$IFNDEF FPC}
       {$IF (DEFINED(OLDINDY))}
        boundary := ExtractHeaderSubItem(ARequest.ContentType, 'boundary');
       {$ELSE}
        boundary := ExtractHeaderSubItem(ARequest.ContentType, 'boundary', QuoteHTTP);
       {$IFEND}
      {$ELSE}
       boundary := ExtractHeaderSubItem(ARequest.ContentType, 'boundary', QuoteHTTP);
      {$ENDIF}
      startboundary := '--' + boundary;
      Repeat
       tmp := ReadLnFromStream(vContentStringStream, -1, True);
      until tmp = startboundary;
     Finally
  //    vContentStringStream.Free;
     End;
    End
   Else
    Begin
     vRequestHeader.Text := vContentStringStream.DataString;
     If vEncoding = esUtf8 Then
      vRequestHeader.Text := Utf8decode(vRequestHeader.Text);
     vContentType := ARequest.ContentType;
     TServerUtils.ParseWebFormsParams (vRequestHeader, Cmd, ARequest.Query,
                                       vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF},
                                       DWParams, aParamsCount, rtPost, vContentType);
    End;
  End;
  {$IFNDEF FPC}
   Cmd := Trim(lowercase(ARequest.PathInfo));
   If DefaultBaseContext <> '' Then
    Begin
     sFile     := RemoveBackslashCommands(Cmd);
     vTempText := IncludeTrailingPathDelimiter(DefaultBaseContext);
     {$IFDEF MSWINDOWS}
      vTempText := StringReplace(vTempText, '\', '/', [rfReplaceAll]);
      vTempText := StringReplace(vTempText, '//', '/', [rfReplaceAll]);
     {$ENDIF}
     If Pos(vTempText, sFile) >= InitStrPos Then
      Delete(sFile, Pos(vTempText, sFile) - FinalStrPos, Length(vTempText));
     vFileName := FRootPath + vTempText + sFile;
    End
   Else
    vFileName := FRootPath + Trim(Cmd);
  {$ELSE}
   Cmd := Trim(lowercase(ARequest.PathInfo));
   If Cmd = ''  Then
    Cmd := Trim(lowercase(ARequest.HeaderLine));
   If DefaultBaseContext <> '' Then
    Begin
     sFile     := RemoveBackslashCommands(Cmd);
     vTempText := IncludeTrailingPathDelimiter(DefaultBaseContext);
     {$IFDEF MSWINDOWS}
      vTempText := StringReplace(vTempText, '\', '/', [rfReplaceAll]);
      vTempText := StringReplace(vTempText, '//', '/', [rfReplaceAll]);
     {$ENDIF}
     If Pos(vTempText, sFile) >= InitStrPos Then
      Delete(sFile, Pos(vTempText, sFile) - FinalStrPos, Length(vTempText));
     vFileName := FRootPath + vTempText + sFile;
    End
   Else
    vFileName := FRootPath + Trim(Cmd);
  {$ENDIF}
  {$IFDEF MSWINDOWS}
   vFileName := StringReplace(vFileName, '/', '\', [rfReplaceAll]);
   vFileName := StringReplace(vFileName, '\\', '\', [rfReplaceAll]);
  {$ENDIF}
  vCompareContext := CompareBaseURL(Cmd);
  If (vPathTraversalRaiseError)            And
     ((TravertalPathFind(Trim(Cmd)))       Or
     ((DWFileExists(ExtractFileName(vFileName), ExtractFilePath(vFileName))) And
      (SystemProtectFiles(Trim(vFileName)))))    Then
   Begin
    vErrorCode                   := 404;
    {$IFNDEF FPC}
     AResponse.StatusCode        := vErrorCode;
    {$ELSE}
     AResponse.Code              := vErrorCode;
    {$ENDIF}
    If vEncoding = esUtf8 Then
     AResponse.ContentEncoding   := 'utf-8'
    Else
     AResponse.ContentEncoding   := 'ansi';
    AResponse.ContentLength      := -1; //Length(JSONStr);
    If compresseddata Then
     Begin
      mb2          := TStringStream(ZCompressStreamNew(cEventNotFound));
      mb2.Position := 0;
     End
    Else
     Begin
      {$IFDEF FPC}
       If vEncoding = esUtf8 Then
        mb                             := TStringStream.Create(Utf8Encode(cEventNotFound))
       Else
        mb                             := TStringStream.Create(cEventNotFound);
      {$ELSE}
       mb                               := TStringStream.Create(cEventNotFound{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      {$ENDIF}
      mb.Position                      := 0;
     End;
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      AResponse.FreeContentStream      := True;
     {$IFEND}
    {$ELSE}
     AResponse.FreeContentStream       := True;
    {$ENDIF}
    If compresseddata Then
     AResponse.ContentStream           := mb2
    Else
     AResponse.ContentStream           := mb;
    AResponse.ContentStream.Position   := 0;
    AResponse.ContentLength            := AResponse.ContentStream.Size;
    {$IFNDEF FPC}
     AResponse.StatusCode              := vErrorCode;
    {$ELSE}
     AResponse.Code                    := vErrorCode;
    {$ENDIF}
    Handled := True;
    {$IFNDEF FPC}
     AResponse.SendResponse;
    {$ELSE}
     AResponse.SendResponse;
    {$ENDIF}
    If Assigned(mb) Then
     FreeAndNil(mb);
    Exit;
   End
  Else If ((DWFileExists(ExtractFileName(vFileName), ExtractFilePath(vFileName))) And
           Not(SystemProtectFiles(Trim(Cmd))))  Then
   Begin
    sFile  := vFileName;
    vErrorCode                   := 200;
    {$IFNDEF FPC}
     AResponse.StatusCode        := vErrorCode;
    {$ELSE}
     AResponse.Code              := vErrorCode;
    {$ENDIF}
    If vEncoding = esUtf8 Then
     AResponse.ContentEncoding   := 'utf-8'
    Else
     AResponse.ContentEncoding   := 'ansi';
    AResponse.ContentLength      := -1; //Length(JSONStr);
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      AResponse.FreeContentStream      := True;
     {$IFEND}
    {$ELSE}
     AResponse.FreeContentStream       := True;
    {$ENDIF}
    AResponse.ContentType := GetMIMEType(sFile);
    AResponse.ContentStream            := TIdReadFileExclusiveStream.Create(sFile);
    AResponse.ContentStream.Position   := 0;
    AResponse.ContentLength            := AResponse.ContentStream.Size;
    {$IFNDEF FPC}
     AResponse.StatusCode              := vErrorCode;
    {$ELSE}
     AResponse.Code                    := vErrorCode;
    {$ENDIF}
    Handled := True;
    {$IFNDEF FPC}
     AResponse.SendResponse;
    {$ELSE}
     AResponse.SendResponse;
    {$ENDIF}
    {$IFNDEF FPC}
     {$IF CompilerVersion < 21}
     If Assigned(AResponse.ContentStream) Then
      AResponse.ContentStream.Free;
     {$IFEND}
    {$ENDIF}
    Exit;
   End;
    If Not (vBinaryevent) Then
     If (Trim(ARequest.Content) = '') And (Cmd = '') then
      Exit;
    vRequestHeader.Add(Cmd);
    Cmd := StringReplace(Cmd, lowercase(' HTTP/1.0'), '', [rfReplaceAll]);
    Cmd := StringReplace(Cmd, lowercase(' HTTP/1.1'), '', [rfReplaceAll]);
    Cmd := StringReplace(Cmd, lowercase(' HTTP/2.0'), '', [rfReplaceAll]);
    Cmd := RemoveBackslashCommands(StringReplace(Cmd, lowercase(' HTTP/2.1'), '', [rfReplaceAll]));
    vCORSOption := UpperCase(Copy (Cmd, 1, 7));
    ReadRawHeaders;
    RequestType := rtGet;
    If (UpperCase(Trim(ARequest.Method))      = 'POST')   Then
     RequestType := rtPost
    Else If (UpperCase(Trim(ARequest.Method)) = 'PUT')    Then
     RequestType := rtPut
    Else If (UpperCase(Trim(ARequest.Method)) = 'DELETE') Then
     RequestType := rtDelete
    Else If (UpperCase(Trim(ARequest.Method)) = 'PATCH')  Then
     RequestType := rtPatch;
    If (RequestType In [rtPut, rtPatch]) Then //New Code to Put
     Begin
      If {$IFNDEF FPC}ARequest.ContentFields.Text{$ELSE}ARequest.ContentFields.Text{$ENDIF} <> '' Then
       Begin
        aParamsCount := cParamsCount;
        If ServerContext <> '' Then
         Inc(aParamsCount);
        If vDataRouteList.Count > 0 Then
         Inc(aParamsCount);
        TServerUtils.ParseWebFormsParams (ARequest.ContentFields, Cmd, ARequest.Query,
                                          vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
        If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
         vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
         vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If DWParams.ItemsString['datacompression'] <> Nil Then
         compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
        If DWParams.ItemsString['dwencodestrings'] <> Nil Then
         encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
        If DWParams.ItemsString['dwservereventname'] <> Nil Then
         Begin
          If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
           Begin
            If ((vUriOptions.BaseServer = '')  And
                (vUriOptions.DataUrl    = '')) And
               (vUriOptions.ServerEvent <> '') Then
             vUriOptions.BaseServer := vUriOptions.ServerEvent
            Else If ((vUriOptions.BaseServer <> '') And
                     (vUriOptions.DataUrl    = '')) And
                    (vUriOptions.ServerEvent <> '') And
                     (vServerContext = '')          Then
             Begin
              vUriOptions.DataUrl    := vUriOptions.BaseServer;
              vUriOptions.BaseServer := vUriOptions.ServerEvent;
             End;
            vUriOptions.ServerEvent := DecodeStrings(DWParams.ItemsString['dwservereventname'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
           End;
         End;
        If DWParams.ItemsString['dwusecript'] <> Nil Then
         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
        If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec))  Then
         dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
        If DWParams.ItemsString['BinaryCompatibleMode'] <> Nil Then
         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
       End;
     End;
    {$IFNDEF FPC}
    If RemoveBackslashCommands(ARequest.PathInfo) <> '/favicon.ico' Then
    {$ELSE}
    If {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                     {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                     {$ELSE}RemoveBackslashCommands(ARequest.URI){$ENDIF} <> '/favicon.ico' Then
    {$ENDIF}
     Begin
    {$IFNDEF FPC}
     If (ARequest.QueryFields.Count > 0) And (RequestType In [rtGet, rtDelete]) Then
      Begin
       vTempCmd := Cmd;
       aParamsCount := cParamsCount;
       If ServerContext <> '' Then
        Inc(aParamsCount);
       If vDataRouteList.Count > 0 Then
        Inc(aParamsCount);
       TServerUtils.ParseWebFormsParams (ARequest.QueryFields, vTempCmd,
                                         ARequest.Query,
                                         vUriOptions, vmark, vEncoding,
                                         DWParams, aParamsCount, RequestType);
       If ARequest.Query <> '' Then
        Begin
         vTempCmd := vTempCmd + '?' + ARequest.Query;
         vRequestHeader.Add(vTempCmd);
         vRequestHeader.Add(ARequest.QueryFields.Text);
        End
       Else
        vRequestHeader.Add(vTempCmd);
       Cmd := vTempCmd;
       If DWParams <> Nil Then
        Begin
         If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
          vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
          vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         If DWParams.ItemsString['datacompression'] <> Nil Then
          compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
         If DWParams.ItemsString['dwencodestrings'] <> Nil Then
          encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
         If DWParams.ItemsString['dwservereventname'] <> Nil Then
          Begin
           If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
            Begin
             If ((vUriOptions.BaseServer = '')  And
                 (vUriOptions.DataUrl    = '')) And
                (vUriOptions.ServerEvent <> '') Then
              vUriOptions.BaseServer := vUriOptions.ServerEvent
             Else If ((vUriOptions.BaseServer <> '') And
                      (vUriOptions.DataUrl    = '')) And
                     (vUriOptions.ServerEvent <> '') And
                      (vServerContext = '')          Then
              Begin
               vUriOptions.DataUrl    := vUriOptions.BaseServer;
               vUriOptions.BaseServer := vUriOptions.ServerEvent;
              End;
             vUriOptions.ServerEvent := DecodeStrings(DWParams.ItemsString['dwservereventname'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            End;
          End;
         If DWParams.ItemsString['dwusecript'] <> Nil Then
          vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
         If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec))  Then
          dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
         If DWParams.ItemsString['binaryrequest'] <> Nil Then
          vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
         If DWParams.ItemsString['BinaryCompatibleMode'] <> Nil Then
          vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
        End;
      End
    {$ELSE}
     aParamsCount := cParamsCount;
     If ServerContext <> '' Then
      Inc(aParamsCount);
     If vDataRouteList.Count > 0 Then
      Inc(aParamsCount);
     If (ARequest.FieldCount > 0) And //(Trim(ARequest.ContentFields.Text) <> '')) And
         (Trim(ARequest.Content) = '') Then
      Begin
       vRequestHeader.Add(ARequest.ContentFields.Text);
       vRequestHeader.Add(Cmd);
       vRequestHeader.Add(ARequest.Query);
       TServerUtils.ParseWebFormsParams (ARequest.ContentFields, Cmd, ARequest.Query,
                                         vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
//       SaveLog; //For Debbug Vars
       If DWParams <> Nil Then
        Begin
         If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
          vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
          vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         If DWParams.ItemsString['datacompression'] <> Nil Then
          compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
         If DWParams.ItemsString['dwencodestrings'] <> Nil Then
          encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
         If DWParams.ItemsString['dwservereventname'] <> Nil Then
          Begin
           If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
            Begin
             If ((vUriOptions.BaseServer = '')  And
                 (vUriOptions.DataUrl    = '')) And
                (vUriOptions.ServerEvent <> '') Then
              vUriOptions.BaseServer := vUriOptions.ServerEvent
             Else If ((vUriOptions.BaseServer <> '') And
                      (vUriOptions.DataUrl    = '')) And
                     (vUriOptions.ServerEvent <> '') And
                      (vServerContext = '')          Then
              Begin
               vUriOptions.DataUrl    := vUriOptions.BaseServer;
               vUriOptions.BaseServer := vUriOptions.ServerEvent;
              End;
             vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
            End;
          End;
         If DWParams.ItemsString['dwusecript'] <> Nil Then
          vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
         If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec))  Then
          dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
         If DWParams.ItemsString['binaryrequest'] <> Nil Then
          vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
         If DWParams.ItemsString['BinaryCompatibleMode'] <> Nil Then
          vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
        End;
      End
    {$ENDIF}
      Else
       Begin
        If (((vContentStringStream <> Nil) And (Trim(vContentStringStream.Datastring) <> ''))
            Or (Trim(ARequest.Content) = '')) And (RequestType In [rtGet, rtDelete]) Then
         Begin
//          SaveLog; //For Debbug Vars
          aParamsCount := cParamsCount;
          If ServerContext <> '' Then
           Inc(aParamsCount);
          If vDataRouteList.Count > 0 Then
           Inc(aParamsCount);
          aurlContext := vUriOptions.ServerEvent;
          {$IFDEF FPC}
           If Trim(ARequest.Query) <> '' Then
            Begin
             vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query);
             TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
            End
           Else
            Begin
             vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo));
             TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
            End;
          {$ELSE}
          vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo) + ARequest.Query);
          aParamsCount := cParamsCount;
          If ServerContext <> '' Then
           Inc(aParamsCount);
          If vDataRouteList.Count > 0 Then
           Inc(aParamsCount);
          TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + ARequest.Query, vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
          {$ENDIF}
          If ((vUriOptions.ServerEvent = '') And (aurlContext <> '')) And
              (Not (RequestType In [rtGet, rtDelete])) Then
           vUriOptions.ServerEvent := aurlContext;
          vOldMethod := vUriOptions.EventName;
          If DWParams <> Nil Then
           Begin
            If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
             vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
             vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            If DWParams.ItemsString['datacompression'] <> Nil Then
             compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
            If DWParams.ItemsString['dwencodestrings'] <> Nil Then
             encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
            If DWParams.ItemsString['dwservereventname'] <> Nil Then
             Begin
              If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
               Begin
                If ((vUriOptions.BaseServer = '')  And
                    (vUriOptions.DataUrl    = '')) And
                   (vUriOptions.ServerEvent <> '') Then
                 vUriOptions.BaseServer := vUriOptions.ServerEvent
                Else If ((vUriOptions.BaseServer <> '') And
                         (vUriOptions.DataUrl    = '')) And
                        (vUriOptions.ServerEvent <> '') And
                         (vServerContext = '')          Then
                 Begin
                  vUriOptions.DataUrl    := vUriOptions.BaseServer;
                  vUriOptions.BaseServer := vUriOptions.ServerEvent;
                 End;
                vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
               End;
             End;
            If DWParams.ItemsString['dwusecript'] <> Nil Then
             vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
            If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
             dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
            If DWParams.ItemsString['binaryrequest'] <> Nil Then
             vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
            If DWParams.ItemsString['BinaryCompatibleMode'] <> Nil Then
             vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
           End;
         End
        Else
         Begin
          ServerContextStream := Nil;
          If vContentStringStream = Nil Then
           Begin
            vContentStringStream := TStringStream.Create(ARequest.Content);
            vRequestHeader.Add(ARequest.Content);
            vContentStringStream.Position := 0;
           End;
          If (vContentStringStream.Size > 0) And (boundary <> '') Then
           Begin
       //     Savelog('boundary 3 : ' + boundary);
       //     Savelog(vContentStringStream.DataString);
           {$IFDEF FPC}
            If Trim(ARequest.Query) <> '' Then
             TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount)
            Else
             TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
           {$ELSE}
            If Trim(ARequest.Query) <> '' Then
             TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark, DWParams, aParamsCount)
            Else
             TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
           {$ENDIF}
            Try
             Repeat
              decoder              := TIdMessageDecoderMIME.Create(nil);
              TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
              Try
               decoder.SourceStream := vContentStringStream;
               decoder.FreeSourceStream := False;
              finally
              end;
              decoder.ReadHeader;
              Case Decoder.PartType of
               mcptAttachment,
               mcptText :
                Begin
                 If ((Decoder.PartType = mcptAttachment) And
                     (boundary <> ''))                   Then
                  Begin
                   sFile := '';
                   {$IFDEF FPC}
                    ms := TStringStream.Create('');
                   {$ELSE}
                    ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
                   {$ENDIF}
                   tmp         := Decoder.Headers.Text;
                   newdecoder  := Decoder.ReadBody(ms, msgEnd);
                   ms.Position := 0;
                   FreeAndNil(Decoder);
                   Decoder     := newdecoder;
                   If Decoder <> Nil Then
                    TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                   vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                   vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                   If (lowercase(vObjectName) = 'binarydata') then
                    Begin
                     If (DWParams = Nil) Then
                      Begin
                       aurlContext := vUriOptions.ServerEvent;
                       {$IFNDEF FPC}
                       If (ARequest.QueryFields.Count = 0) Then
                       {$ELSE}
                       If (ARequest.FieldCount = 0) Then
                       {$ENDIF}
                        Begin
                         DWParams           := TDWParams.Create;
                         DWParams.Encoding  := vEncoding;
                        End
                       Else
                        Begin
                         aParamsCount := cParamsCount;
                         If ServerContext <> '' Then
                          Inc(aParamsCount);
                         If vDataRouteList.Count > 0 Then
                          Inc(aParamsCount);
                        End;
                      End;
                     If (vUriOptions.ServerEvent = '') And (aurlContext <> '') Then
                      vUriOptions.ServerEvent := aurlContext;
                     Try
                      ms.Position := 0;
                      DWParams.LoadFromStream(ms);
                      {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                      If Assigned(ms) Then
                       FreeAndNil(ms);
                     Except
                      On E : Exception Do
                       Begin
                        //savelog(vObjectName + ' : ' + e.Message);
                       End;
                     End;
                     If Assigned(ms) Then
                      FreeAndNil(ms);
                     If Assigned(newdecoder) Then
                      FreeAndNil(newdecoder);
                     If DWParams <> Nil Then
                      Begin
                       If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
                        vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                       If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
                        vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                       If DWParams.ItemsString['datacompression'] <> Nil Then
                        compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                       If DWParams.ItemsString['dwencodestrings'] <> Nil Then
                        encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                       If DWParams.ItemsString['dwservereventname'] <> Nil Then
                        Begin
                         If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                          Begin
                           If ((vUriOptions.BaseServer = '')  And
                                (vUriOptions.DataUrl    = '')) And
                               (vUriOptions.ServerEvent <> '') Then
                            vUriOptions.BaseServer := vUriOptions.ServerEvent
                           Else If ((vUriOptions.BaseServer <> '') And
                                    (vUriOptions.DataUrl    = '')) And
                                   (vUriOptions.ServerEvent <> '') And
                                    (vServerContext = '')          Then
                            Begin
                             vUriOptions.DataUrl    := vUriOptions.BaseServer;
                             vUriOptions.BaseServer := vUriOptions.ServerEvent;
                            End;
                           vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
                          End;
                        End;
                       If DWParams.ItemsString['dwusecript'] <> Nil Then
                        vdwCriptKey  := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                       If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
                        dwassyncexec  := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                       If DWParams.ItemsString['binaryrequest'] <> Nil Then
                        vBinaryEvent   := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                       If DWParams.ItemsString['BinaryCompatibleMode'] <> Nil Then
                        vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                      End;
                   //  savelog(DWParams.ToJSON);
                     Continue;
                    End;
                   If (DWParams = Nil) Then
                    Begin
                     aurlContext := vUriOptions.ServerEvent;
                     {$IFNDEF FPC}
                     If (ARequest.QueryFields.Count = 0) Then
                     {$ELSE}
                     If (ARequest.FieldCount = 0) Then
                     {$ENDIF}
                      Begin
                       DWParams           := TDWParams.Create;
                       DWParams.Encoding  := vEncoding;
                      End
                     Else
                      Begin
                       aParamsCount := cParamsCount;
                       If ServerContext <> '' Then
                        Inc(aParamsCount);
                       If vDataRouteList.Count > 0 Then
                        Inc(aParamsCount);
                       {$IFDEF FPC}
                        If Trim(ARequest.Query) <> '' Then
                         TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount)
                        Else
                         TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
                       {$ELSE}
                        If Trim(ARequest.Query) <> '' Then
                         TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark, DWParams, aParamsCount)
                        Else
                         TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
                       {$ENDIF}
                      End;
                     If (vUriOptions.ServerEvent = '') And (aurlContext <> '') Then
                      vUriOptions.ServerEvent := aurlContext;
                    End;
                   If sFile <> '' Then
                    Begin
                     vObjectName := 'dwfilename';
                     JSONParam   := TJSONParam.Create(DWParams.Encoding);
                     JSONParam.ObjectDirection := odIN;
                     JSONParam.ParamName := vObjectName;
                     JSONParam.SetValue(sFile, JSONParam.Encoded);
                     DWParams.Add(JSONParam);
                    End;
                   {$IFDEF FPC}
                   If Not Assigned(DWParams) Then
                    Begin
                     DWParams           := TDWParams.Create;
                     DWParams.Encoding  := vEncoding;
                    End;
                   If (ARequest.ContentFields.Count > 0) Then
                    Begin
                     For I := 0 To ARequest.ContentFields.Count -1 Do
                      Begin
                       JSONParam           := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ObjectDirection := odIN;
                       JSONParam.ParamName := ARequest.ContentFields.Names[I];
                       If vEncoding = esUtf8 Then
                        JSONParam.SetValue(utf8decode(ARequest.ContentFields.Values[JSONParam.ParamName]), JSONParam.Encoded)
                       Else
                        JSONParam.SetValue(ARequest.ContentFields.Values[JSONParam.ParamName], JSONParam.Encoded);
                       DWParams.Add(JSONParam);
                      End;
                    End;
                   {$ELSE}
                   If (ARequest.QueryFields.Count = 0) And
                      (ARequest.ContentFields.Count > 0) Then
                    Begin
                     I := 0;
                     While I <= ARequest.ContentFields.Count -1 Do
                      Begin
                       If (ARequest.ContentFields.Names[0] <> '') Then
                        Break;
                       If (ARequest.ContentFields.Names[I] <> '') Then
                        Begin
                         JSONParam           := TJSONParam.Create(DWParams.Encoding);
                         JSONParam.ObjectDirection := odIN;
                         tmp := ARequest.ContentFields[I];
                         If Pos('; name="', lowercase(tmp)) > 0 Then
                          Begin
                           vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                           vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                           JSONParam.ParamName := vObjectName;
                           If (I+1 <= (ARequest.ContentFields.Count -1)) Then
                            Begin
                             If vEncoding = esUtf8 Then
                              JSONParam.SetValue(utf8decode(ARequest.ContentFields[I +1]), JSONParam.Encoded)
                             Else
                              JSONParam.SetValue(ARequest.ContentFields[I +1], JSONParam.Encoded);
                            End;
                           Inc(I);
                           DWParams.Add(JSONParam);
                          End;
                        End;
                       Inc(I);
                      End;
                     //Quebra de Form-Data
                     For I := 0 To ARequest.ContentFields.Count -1 Do
                      Begin
                       If (ARequest.ContentFields.Names[0] = '') Then
                        Break;
                       JSONParam           := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ObjectDirection := odIN;
                       JSONParam.ParamName := ARequest.ContentFields.Names[I];
                       If vEncoding = esUtf8 Then
                        JSONParam.SetValue(utf8decode(ARequest.ContentFields.Values[JSONParam.ParamName]), JSONParam.Encoded)
                       Else
                        JSONParam.SetValue(ARequest.ContentFields.Values[JSONParam.ParamName], JSONParam.Encoded);
                       DWParams.Add(JSONParam);
                      End;
                    End;
                   {$ENDIF}
                   If Assigned(Decoder) Then
                    FreeAndNil(Decoder);
                  End
                 Else If Boundary <> '' Then
                  Begin
                  {$IFDEF FPC}
                   ms := TStringStream.Create('');
                  {$ELSE}
                   ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
                  {$ENDIF}
                   ms.Position := 0;
                   newdecoder  := Decoder.ReadBody(ms, msgEnd);
                   tmp         := Decoder.Headers.Text;
                   FreeAndNil(Decoder);
                   Decoder     := newdecoder;
//                   SaveLog(tmp);
                   If Decoder <> Nil Then
                    TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                   If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
                    Begin
                     vWelcomeMessage     := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If Not Assigned(DWParams) Then
                      Begin
                       DWParams := TDWParams.Create;
                       DWParams.Encoding := vEncoding;
                       {$IFDEF FPC}
                       DWParams.DatabaseCharSet := DatabaseCharSet;
                       {$ENDIF}
                      End;
                     If DWParams.ItemsString['dwwelcomemessage'] = Nil Then
                      Begin
                       JSONParam           := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ParamName := 'dwwelcomemessage';
                       JSONParam.ObjectDirection := odIN;
                       JSONParam.Encoded   := True;
                       JSONParam.AsString  := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                       DWParams.Add(JSONParam);
                      End
                     Else
                      JSONParam.AsString := vWelcomeMessage;
                    End
                   Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
                    Begin
                     vAccessTag := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If Not Assigned(DWParams) Then
                      Begin
                       DWParams := TDWParams.Create;
                       DWParams.Encoding := vEncoding;
                       {$IFDEF FPC}
                       DWParams.DatabaseCharSet := DatabaseCharSet;
                       {$ENDIF}
                      End;
                     If DWParams.ItemsString['dwaccesstag'] = Nil Then
                      Begin
                       JSONParam           := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ParamName := 'dwaccesstag';
                       JSONParam.ObjectDirection := odIN;
                       JSONParam.Encoded   := True;
                       JSONParam.AsString  := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                       DWParams.Add(JSONParam);
                      End
                     Else
                      JSONParam.AsString := vAccessTag;
                    End
                   Else If Pos('dwusecript', lowercase(tmp)) > 0 Then
                    vdwCriptKey  := StringToBoolean(ms.DataString)
                   Else If pos('datacompression', lowercase(tmp)) > 0 Then
                    compresseddata := StringToBoolean(ms.DataString)
                   Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
                    encodestrings  := StringToBoolean(ms.DataString)
                   Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                    dwassyncexec := StringToBoolean(ms.DataString)
                   Else If Pos('binaryrequest', lowercase(tmp)) > 0 Then
                    vBinaryEvent := StringToBoolean(ms.DataString)
                   Else If Pos('BinaryCompatibleMode', lowercase(tmp)) > 0 Then
                    vBinaryCompatibleMode := StringToBoolean(ms.DataString)
                   Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                    Begin
                     vdwConnectionDefs   := TConnectionDefs.Create;
                     JSONValue           := TJSONValue.Create;
                     Try
                      JSONValue.Encoding  := vEncoding;
                      JSONValue.Encoded  := True;
                      JSONValue.LoadFromJSON(ms.DataString);
                      vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                     Finally
                      FreeAndNil(JSONValue);
                     End;
                    End
                   Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                    Begin
                     //SaveLog(tmp);
                     JSONValue           := TJSONValue.Create;
                     Try
                      JSONValue.Encoding := vEncoding;
                      JSONValue.Encoded  := True;
                      JSONValue.LoadFromJSON(ms.DataString);
                      If ((vUriOptions.BaseServer = '')  And
                          (vUriOptions.DataUrl    = '')) And
                         (vUriOptions.ServerEvent <> '') Then
                       vUriOptions.BaseServer := vUriOptions.ServerEvent
                      Else If ((vUriOptions.BaseServer <> '') And
                               (vUriOptions.DataUrl    = '')) And
                              (vUriOptions.ServerEvent <> '') And
                               (vServerContext = '')          Then
                       Begin
                        vUriOptions.DataUrl    := vUriOptions.BaseServer;
                        vUriOptions.BaseServer := vUriOptions.ServerEvent;
                       End;
                      vUriOptions.ServerEvent := JSONValue.Value;
                      If Pos('.', vUriOptions.ServerEvent) > 0 Then
                       Begin
                        baseEventUnit           := Copy(vUriOptions.ServerEvent, InitStrPos, Pos('.', vUriOptions.ServerEvent) - 1 - FinalStrPos);
                        vUriOptions.ServerEvent := Copy(vUriOptions.ServerEvent, Pos('.', vUriOptions.ServerEvent) + 1, Length(vUriOptions.ServerEvent));
                       End;
                     Finally
                      FreeAndNil(JSONValue);
                     End;
                    End
                   Else
                    Begin
                     aurlContext := vUriOptions.ServerEvent;
                     aParamsCount := cParamsCount;
                     If ServerContext <> '' Then
                      Inc(aParamsCount);
                     If vDataRouteList.Count > 0 Then
                      Inc(aParamsCount);
                     {$IFDEF FPC}
                      If Trim(ARequest.Query) <> '' Then
                       TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount)
                      Else
                       TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
                     {$ELSE}
                      If Trim(ARequest.Query) <> '' Then
                       TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark, DWParams, aParamsCount)
                      Else
                       TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
                     {$ENDIF}
                     If (vUriOptions.ServerEvent = '') And (aurlContext <> '') Then
                      vUriOptions.ServerEvent := aurlContext;
//                     savelog(tmp);
                     vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                     vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                     //savelog('ObjectName : ' + vObjectName);
                     JSONParam   := TJSONParam.Create(DWParams.Encoding);
                     JSONParam.ObjectDirection := odIN;
                     If (lowercase(vObjectName) = 'binarydata') then
                      Begin
                       DWParams.LoadFromStream(ms);
                       If Assigned(JSONParam) Then
                        FreeAndNil(JSONParam);
                       {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                       FreeAndNil(ms);
                       If DWParams <> Nil Then
                        Begin
                         If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
                          vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                         If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
                          vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                         If DWParams.ItemsString['datacompression'] <> Nil Then
                          compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                         If DWParams.ItemsString['dwencodestrings'] <> Nil Then
                          encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                         If DWParams.ItemsString['dwservereventname'] <> Nil Then
                          Begin
                           If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                            Begin
                             If ((vUriOptions.BaseServer = '')  And
                                 (vUriOptions.DataUrl    = '')) And
                                 (vUriOptions.ServerEvent <> '') Then
                              vUriOptions.BaseServer := vUriOptions.ServerEvent
                             Else If ((vUriOptions.BaseServer <> '') And
                                      (vUriOptions.DataUrl    = '')) And
                                     (vUriOptions.ServerEvent <> '') And
                                      (vServerContext = '')          Then
                              Begin
                               vUriOptions.DataUrl    := vUriOptions.BaseServer;
                               vUriOptions.BaseServer := vUriOptions.ServerEvent;
                              End;
                             vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
                            End;
                          End;
                         If DWParams.ItemsString['dwusecript'] <> Nil Then
                          vdwCriptKey  := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                         If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
                          dwassyncexec  := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                         If DWParams.ItemsString['binaryrequest'] <> Nil Then
                          vBinaryEvent   := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                         If DWParams.ItemsString['BinaryCompatibleMode'] <> Nil Then
                          vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                        End;
                       Continue;
                      End;
                     If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                      JSONParam.FromJSON(ms.DataString)
                     Else
                      JSONParam.AsString := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                     JSONParam.ParamName := vObjectName;
                     DWParams.Add(JSONParam);
                     If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
                      vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                    End;
                   {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                   FreeAndNil(ms);
                  End
                 Else
                  Begin
                   aurlContext := vUriOptions.ServerEvent;
                   aParamsCount := cParamsCount;
                   If ServerContext <> '' Then
                    Inc(aParamsCount);
                   If vDataRouteList.Count > 0 Then
                    Inc(aParamsCount);
                   {$IFDEF FPC}
                    If Trim(ARequest.Query) <> '' Then
                     Begin
                      vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query);
                      TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
                     End
                    Else
                     Begin
                      vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo));
                      TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
                     End;
                   {$ELSE}
                    If Trim(ARequest.Query) <> '' Then
                     Begin
                      vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query);
                      TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
                     End
                    Else
                     Begin
                      vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo));
                      TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
                     End;
                   {$ENDIF}
                   If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
                    vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                   If (vUriOptions.ServerEvent = '') And (aurlContext <> '') Then
                    vUriOptions.ServerEvent := aurlContext;
                   FreeAndNil(decoder);
                  End;
                End;
               mcptIgnore :
                Begin
                 Try
                  If decoder <> Nil Then
                   FreeAndNil(decoder);
                  decoder := TIdMessageDecoderMIME.Create(Nil);
                  TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
                 Finally
                 End;
                End;
               {$IFNDEF FPC}
                {$IF Not(DEFINED(OLDINDY))}
                mcptEOF:
                 Begin
                  FreeAndNil(decoder);
                  msgEnd := True
                 End;
                {$IFEND}
               {$ELSE}
               mcptEOF:
                Begin
                 FreeAndNil(decoder);
                 msgEnd := True
                End;
               {$ENDIF}
               End;
             Until (Decoder = Nil) Or (msgEnd);
            Finally
             If decoder <> nil then
              FreeAndNil(decoder);
             If vContentStringStream <> Nil Then
              FreeAndNil(vContentStringStream);
            End;
           End
          Else
           Begin
            aurlContext := vUriOptions.ServerEvent;
            aParamsCount := cParamsCount;
            If ServerContext <> '' Then
             Inc(aParamsCount);
            If vDataRouteList.Count > 0 Then
             Inc(aParamsCount);
            {$IFDEF FPC}
             If Trim(ARequest.Query) <> '' Then
              Begin
               vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query);
               TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
              End
             Else
              Begin
               vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo));
               TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
              End;
            {$ELSE}
             If Trim(ARequest.Query) <> '' Then
              Begin
               vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query);
               TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
              End
             Else
              Begin
               vRequestHeader.Add(RemoveBackslashCommands(ARequest.PathInfo));
               TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
              End;
            {$ENDIF}
            If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
             vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
            If vContentStringStream <> Nil Then
             FreeAndNil(vContentStringStream);
            If (vUriOptions.ServerEvent = '') And (aurlContext <> '') Then
             vUriOptions.ServerEvent := aurlContext;
            {$IFNDEF FPC}
             {$IF CompilerVersion > 30}
              ARequest.ReadTotalContent;
              If vContentStringStream = Nil Then
               If vEncoding = esUtf8 Then
                vContentStringStream := TStringStream.Create(TEncoding.UTF8.GetString(ARequest.RawContent))
               Else
                vContentStringStream := TStringStream.Create(TEncoding.ANSI.GetString(ARequest.RawContent));
              vRequestHeader.Add(vContentStringStream.DataString);
             {$ELSE}
              If vContentStringStream = Nil Then
               vContentStringStream := TStringStream.Create(ARequest.Content);
              vContentStringStream.Position := 0;
              vRequestHeader.Add(ARequest.Content);
             {$IFEND}
            {$ELSE}
             If vContentStringStream = Nil Then
              If vEncoding = esUtf8 Then
               vContentStringStream := TStringStream.Create(Utf8Decode(ARequest.Content))
              Else
               vContentStringStream := TStringStream.Create(ARequest.Content);
             vContentStringStream.Position := 0;
             vRequestHeader.Add(ARequest.Content);
            {$ENDIF}
            If vContentStringStream.Size > 0 Then
             Begin
              vParamList := TStringList.Create;
              vParamList.Text := vContentStringStream.DataString;
              If (Not TServerUtils.ParseDWParamsURL(vContentStringStream.DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})) And
                 (vParamList.Count > 0) Then
               Begin
                For I := 0 To vParamList.Count -1 Do
                 Begin
                  tmp := Trim(vParamList.Names[I]);
                  If tmp = '' Then
                   tmp := cUndefined;
                  If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
                   vWelcomeMessage := DecodeStrings(vParamList.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                  Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
                   vAccessTag := DecodeStrings(vParamList.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                  Else If pos('datacompression', lowercase(tmp)) > 0 Then
                   compresseddata := StringToBoolean(vParamList.Values[tmp])
                  Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
                   encodestrings  := StringToBoolean(vParamList.Values[tmp])
                  Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                   dwassyncexec := StringToBoolean(ms.DataString)
                  Else If Pos('dwusecript', lowercase(tmp)) > 0 Then
                   vdwCriptKey  := StringToBoolean(ms.DataString)
                  Else If Pos('BinaryCompatibleMode', lowercase(tmp)) > 0 Then
                   vBinaryCompatibleMode := StringToBoolean(ms.DataString)
                  Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                   Begin
                    vdwConnectionDefs   := TConnectionDefs.Create;
                    JSONValue           := TJSONValue.Create;
                    Try
                     JSONValue.Encoding  := vEncoding;
                     JSONValue.Encoded  := True;
                     JSONValue.LoadFromJSON(vParamList.Values[tmp]);
                     vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                    Finally
                     FreeAndNil(JSONValue);
                    End;
                   End
                  Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                   Begin
                    JSONValue           := TJSONValue.Create;
                    Try
                     JSONValue.Encoding := vEncoding;
                     JSONValue.Encoded  := True;
                     JSONValue.LoadFromJSON(vParamList.Values[tmp]);
                     If ((vUriOptions.BaseServer = '')  And
                         (vUriOptions.DataUrl    = '')) And
                        (vUriOptions.ServerEvent <> '') Then
                      vUriOptions.BaseServer := vUriOptions.ServerEvent
                     Else If ((vUriOptions.BaseServer <> '') And
                              (vUriOptions.DataUrl    = '')) And
                             (vUriOptions.ServerEvent <> '') And
                              (vServerContext = '')          Then
                      Begin
                       vUriOptions.DataUrl    := vUriOptions.BaseServer;
                       vUriOptions.BaseServer := vUriOptions.ServerEvent;
                      End;
                     vUriOptions.ServerEvent := JSONValue.Value;
                     If Pos('.', vUriOptions.ServerEvent) > 0 Then
                      Begin
                       baseEventUnit           := Copy(vUriOptions.ServerEvent, InitStrPos, Pos('.', vUriOptions.ServerEvent) - 1 - FinalStrPos);
                       vUriOptions.ServerEvent := Copy(vUriOptions.ServerEvent, Pos('.', vUriOptions.ServerEvent) + 1, Length(vUriOptions.ServerEvent));
                      End;
                    Finally
                     FreeAndNil(JSONValue);
                    End;
                   End
                  Else
                   Begin
                    If DWParams = Nil Then
                     Begin
                      DWParams           := TDWParams.Create;
                      DWParams.Encoding  := vEncoding;
                     End;
                    JSONParam                 := TJSONParam.Create(DWParams.Encoding);
                    JSONParam.ObjectDirection := odIN;
                    JSONParam.ParamName       := lowercase(tmp);
                    If (lowercase(JSONParam.ParamName) = 'binarydata') then
                     Begin
                      ms := TStringStream.Create(vParamList.Values[tmp]);
                      ms.Position := 0;
                      DWParams.LoadFromStream(ms);
                      If Assigned(JSONParam) Then
                       FreeAndNil(JSONParam);
                      If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
                       vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                      If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
                       vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                      If DWParams.ItemsString['datacompression'] <> Nil Then
                       compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                      If DWParams.ItemsString['dwencodestrings'] <> Nil Then
                       encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                      If DWParams.ItemsString['dwservereventname'] <> Nil Then
                       Begin
                        If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                         Begin
                          If ((vUriOptions.BaseServer = '')  And
                              (vUriOptions.DataUrl    = '')) And
                             (vUriOptions.ServerEvent <> '') Then
                           vUriOptions.BaseServer := vUriOptions.ServerEvent
                          Else If ((vUriOptions.BaseServer <> '') And
                                   (vUriOptions.DataUrl    = '')) And
                                  (vUriOptions.ServerEvent <> '') And
                                   (vServerContext = '')          Then
                           Begin
                            vUriOptions.DataUrl    := vUriOptions.BaseServer;
                            vUriOptions.BaseServer := vUriOptions.ServerEvent;
                           End;
                          vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
                         End;
                       End;
                      If DWParams.ItemsString['dwusecript'] <> Nil Then
                       vdwCriptKey  := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                      If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
                       dwassyncexec  := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                      If DWParams.ItemsString['binaryrequest'] <> Nil Then
                       vBinaryEvent   := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                      If DWParams.ItemsString['BinaryCompatibleMode'] <> Nil Then
                       vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                      Continue;
                     End
                    Else
                     Begin
                      If tmp = cUndefined Then
                       Begin
                        tmp := vParamList.ValueFromIndex[I];
                        JSONParam.AsString  := tmp;
                       End
                      Else
                       Begin
                        {$IFNDEF FPC}
                         {$IF (DEFINED(OLDINDY))}
                          tmp := TIdURI.URLDecode(StringReplace(vParamList.Values[tmp], '+', ' ', [rfReplaceAll]));
                         {$ELSE}
                          tmp := TIdURI.URLDecode(StringReplace(vParamList.Values[tmp], '+', ' ', [rfReplaceAll]), GetEncodingID(DWParams.Encoding));
                         {$IFEND}
                        {$ELSE}
                         tmp := TIdURI.URLDecode(StringReplace(vParamList.Values[tmp], '+', ' ', [rfReplaceAll]), GetEncodingID(DWParams.Encoding));
                        {$ENDIF}
                        If Pos(LowerCase('{"ObjectType":"toParam", "Direction":"'), LowerCase(tmp)) = InitStrPos Then
                         JSONParam.FromJSON(tmp)
                        Else
                         Begin
                          If vEncoding = esUtf8 Then
                           JSONParam.AsString  := utf8decode(tmp)
                          Else
                           JSONParam.AsString  := tmp;
                         End;
                       End;
                     End;
                    DWParams.Add(JSONParam);
                   End;
                 End;
               End;
               vParamList.Free;
             End;
            If vContentStringStream <> Nil Then
             FreeAndNil(vContentStringStream);
           End;
          If DWParams <> Nil Then
           If DWParams.ItemsString['dwEventNameData'] <> Nil Then
            vUriOptions.EventName := DWParams.ItemsString['dwEventNameData'].Value;
         End;
       End;
      tmp                   := '';
      WelcomeAccept         := True;
      vAuthenticationString := '';
      vToken                := '';
      vAuthUsername         := '';
      vAuthPassword         := '';
      vGettoken             := False;
      vTokenValidate        := False;
      vAcceptAuth           := False;
      If (vDataRouteList.Count > 0) Then
       Begin
        If (vUriOptions.BaseServer = '') And (vUriOptions.DataUrl = '') Then
         vUriOptions.BaseServer := vUriOptions.ServerEvent
       End;
      If (vServerContext <> '') Then
       Begin
        If (vUriOptions.BaseServer = '') And (vUriOptions.ServerEvent <> '') Then
         Begin
          vUriOptions.BaseServer  := vUriOptions.ServerEvent;
          vUriOptions.ServerEvent := '';
         End;
       End;
      If (vDataRouteList.Count > 0) Then
       Begin
        If (vServerContext = '') Then
         Begin
          If vDataRouteList.RouteExists(vUriOptions.BaseServer) Then
           Begin
            vUriOptions.DataUrl    := vUriOptions.BaseServer;
            vUriOptions.BaseServer := '';
           End;
         End;
       End;
      If ((vUriOptions.BaseServer <> vServerContext) And (vServerContext <> '')) Or
          ((vUriOptions.BaseServer <> '') And (vUriOptions.BaseServer <> vUriOptions.ServerEvent) And
         (vServerContext = '')) Then
       Begin
        vErrorCode := 400;
        JSONStr    := GetPairJSON(-5, 'Invalid Server Context');
       End
      Else
       Begin
        If vDataRouteList.Count > 0 Then
         Begin
          If ((vUriOptions.BaseServer <> '') And (vUriOptions.DataUrl = '') And (vServerContext <> '')) or
             ((vServerContext = '') And (vUriOptions.BaseServer <> vUriOptions.ServerEvent) And (vUriOptions.BaseServer <> '')) Then
           Begin
            If Not vDataRouteList.GetServerMethodClass(vUriOptions.BaseServer, vServerMethod) Then
             Begin
              vErrorCode := 400;
              JSONStr    := GetPairJSON(-5, 'Invalid Data Context');
             End;
           End
          Else
           Begin
            If Not vDataRouteList.GetServerMethodClass(vUriOptions.DataUrl, vServerMethod) Then
             Begin
              vErrorCode := 400;
              JSONStr    := GetPairJSON(-5, 'Invalid Data Context');
             End;
           End;
         End
        Else
         Begin
          If (((vUriOptions.BaseServer = '')                    And
              (vServerContext = ''))                            Or
              (vUriOptions.BaseServer = vServerContext))        And
            ((vUriOptions.DataUrl = '')                         Or
             (vUriOptions.DataUrl = vUriOptions.ServerEvent))   Or
            ((vServerContext = '')                              And
             (vUriOptions.BaseServer = vUriOptions.ServerEvent) And
             (vUriOptions.ServerEvent <> ''))                   Then
           vServerMethod := aServerMethod;
         End;
        If Assigned(vServerMethod) Then
         Begin
          If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
           vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
           vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          Try
//           {$IFDEF FPC}
//            InitCriticalSection(vCriticalSection);
//            EnterCriticalSection(vCriticalSection);
//           {$ENDIF}
           vTempServerMethods  := vServerMethod.Create(Nil);
          Finally
//           {$IFDEF FPC}
//            Try
//             LeaveCriticalSection(vCriticalSection);
//             DoneCriticalSection(vCriticalSection);
//            Except
//            End;
//           {$ENDIF}
          End;
          If (vTempServerMethods.ClassType = TServerMethodDatamodule)             Or
                  (vTempServerMethods.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
           Begin
            If TServerMethodDatamodule(vTempServerMethods).QueuedRequest Then
             Begin
              {$IFNDEF FPC}
               {$IF CompilerVersion > 21}
                {$IFDEF WINDOWS}
                 InitializeCriticalSection(vCriticalSection);
                 EnterCriticalSection(vCriticalSection);
                {$ELSE}
                 If Not Assigned(vCriticalSection) Then
                  vCriticalSection := TCriticalSection.Create;
                 vCriticalSection.Acquire;
                {$ENDIF}
               {$ELSE}
                If Not Assigned(vCriticalSection)  Then
                 vCriticalSection := TCriticalSection.Create;
                vCriticalSection.Acquire;
               {$IFEND}
              {$ELSE}
               InitCriticalSection(vCriticalSection);
               EnterCriticalSection(vCriticalSection);
              {$ENDIF}
             End;
            vServerAuthOptions.CopyServerAuthParams(vRDWAuthOptionParam);
            TServerMethodDatamodule(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
            If ARequest.Referer = 'ipv6' Then
             vIPVersion := 'ipv6';
            TServerMethodDatamodule(vTempServerMethods).SetClientInfo(ARequest.RemoteAddr, vIPVersion,
                                                                      ARequest.UserAgent, vUriOptions.EventName, vUriOptions.ServerEvent, 0);
            //Novo Lugar para Autenticação
            If ((vCORS) And (vCORSOption <> 'OPTIONS')) Or
                (vServerAuthOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken]) Then
             Begin
              vAcceptAuth           := False;
              vErrorCode            := 401;
              vErrorMessage         := cInvalidAuth;
              Case vServerAuthOptions.AuthorizationOption Of
               rdwAOBasic  : Begin
                              vNeedAuthorization := False;
                              vTempEvent         := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions.EventName, vUriOptions.ServerEvent);
                              If vTempEvent = Nil Then
                               Begin
                                vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions);
                                If vTempContext <> Nil Then
                                 vNeedAuthorization := vTempContext.NeedAuthorization
                                Else
                                 vNeedAuthorization := True;
                               End
                              Else
                               vNeedAuthorization := vTempEvent.NeedAuthorization;
                              If vNeedAuthorization Then
                               Begin
                                vAuthenticationString := DecodeStrings(StringReplace(ARequest.Authorization, 'Basic ', '', [rfReplaceAll]){$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                                PrepareBasicAuth(vAuthenticationString, vAuthUsername, vAuthPassword);
                                If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth) Then
                                 Begin
                                  TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth(vWelcomeMessage, vAccessTag,
                                                                                              vAuthUsername,
                                                                                              vAuthPassword,
                                                                                              DWParams, vErrorCode, vErrorMessage, vAcceptAuth);
                                  If Not vAcceptAuth Then
                                   Begin
                                    WriteError;
                                    DestroyComponents;
                                    Exit;
                                   End;
                                 End
                                Else If Not ((vAuthUsername = TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username) And
                                             (vAuthPassword = TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password)) Then
                                 Begin
                                  WriteError;
                                  DestroyComponents;
                                  Exit;
                                 End;
                               End
                              Else
                               vNeedAuthorization := False;
                             End;
               rdwAOBearer : Begin
                              vUrlToken := Lowercase(vUriOptions.EventName);
                              If vUrlToken =
                                 Lowercase(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                               Begin
                                vGettoken     := True;
                                vErrorCode    := 404;
                                vErrorMessage := cEventNotFound;
                                If (RequestTypeToRoute(RequestType) In TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                                   (crAll in TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                                 Begin
                                  If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                                   Begin
                                    vTokenValidate  := True;
                                    vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                    vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                    If DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                     vToken         := DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                                    Else
                                     Begin
                                      vToken       := ARequest.Authorization;
                                      aToken       := '';
                                      If Trim(vToken) <> '' Then
                                       Begin
                                        aToken     := GetTokenString(vToken);
                                        If aToken = '' Then
                                         aToken    := GetBearerString(vToken);
                                        vToken     := aToken;
                                       End;
                                     End;
                                    If DWParams.ItemsString['RDWParams'] <> Nil Then
                                     Begin
                                      DWParamsD := TDWParams.Create;
                                      DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                                      TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParamsD,
                                                                                             TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                             vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                      FreeAndNil(DWParamsD);
                                     End
                                    Else
                                     TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParams,
                                                                                            TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                            vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                    If Not vAcceptAuth Then
                                     Begin
                                      WriteError;
                                      DestroyComponents;
                                      Exit;
                                     End;
                                   End
                                  Else
                                   Begin
                                    WriteError;
                                    DestroyComponents;
                                    Exit;
                                   End;
                                 End
                                Else
                                 Begin
                                  WriteError;
                                  DestroyComponents;
                                  Exit;
                                 End;
                               End
                              Else
                               Begin
                                vErrorCode      := 401;
                                vErrorMessage   := cInvalidAuth;
                                vTokenValidate  := True;
                                vNeedAuthorization := False;
                                vTempEvent         := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions.EventName, vUriOptions.ServerEvent);
                                If vTempEvent = Nil Then
                                 Begin
                                  vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions);
                                  If vTempContext <> Nil Then
                                   vNeedAuthorization := vTempContext.NeedAuthorization
                                  Else
                                   vNeedAuthorization := True;
                                 End
                                Else
                                 vNeedAuthorization := vTempEvent.NeedAuthorization;
                                If vNeedAuthorization Then
                                 Begin
                                  vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                  vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                  If DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                   vToken         := DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                                  Else
                                   Begin
                                    vToken       := ARequest.Authorization;
                                    aToken       := '';
                                    If Trim(vToken) <> '' Then
                                     Begin
                                      aToken     := GetTokenString(vToken);
                                      If aToken = '' Then
                                       aToken    := GetBearerString(vToken);
                                      vToken     := aToken;
                                     End;
                                   End;
                                  If Not vAuthTokenParam.FromToken(vToken) Then
                                   Begin
                                    WriteError;
                                    DestroyComponents;
                                    Exit;
                                   End
                                  Else
                                   vTokenValidate := False;
                                  If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth) Then
                                   Begin
                                    TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth(vWelcomeMessage, vAccessTag, DWParams,
                                                                                                TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                                vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                    vTokenValidate := Not(vAcceptAuth);
                                    If Not vAcceptAuth Then
                                     Begin
                                      WriteError;
                                      DestroyComponents;
                                      Exit;
                                     End;
                                   End;
                                 End
                                Else
                                 vTokenValidate := False;
                               End;
                             End;
               rdwAOToken  : Begin
                              vUrlToken := Lowercase(vUriOptions.EventName);
                              If vUrlToken =
                                 Lowercase(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                               Begin
                                vGettoken     := True;
                                vErrorCode    := 404;
                                vErrorMessage := cEventNotFound;
                                If (RequestTypeToRoute(RequestType) In TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                                   (crAll in TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                                 Begin
                                  If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                                   Begin
                                    vTokenValidate := True;
                                    vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                    vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                    If DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                     vToken         := DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                                    Else
                                     Begin
                                      vToken       := ARequest.Authorization;
                                      aToken       := '';
                                      If Trim(vToken) <> '' Then
                                       Begin
                                        aToken     := GetTokenString(vToken);
                                        If aToken = '' Then
                                         aToken    := GetBearerString(vToken);
                                        vToken     := aToken;
                                       End;
                                     End;
                                    If DWParams.ItemsString['RDWParams'] <> Nil Then
                                     Begin
                                      DWParamsD := TDWParams.Create;
                                      DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                                      TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParamsD,
                                                                                             TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                             vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                      FreeAndNil(DWParamsD);
                                     End
                                    Else
                                     TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParams,
                                                                                            TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                            vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                    If Not vAcceptAuth Then
                                     Begin
                                      WriteError;
                                      DestroyComponents;
                                      Exit;
                                     End;
                                   End
                                  Else
                                   Begin
                                    WriteError;
                                    DestroyComponents;
                                    Exit;
                                   End;
                                 End
                                Else
                                 Begin
                                  WriteError;
                                  DestroyComponents;
                                  Exit;
                                 End;
                               End
                              Else
                               Begin
                                vErrorCode      := 401;
                                vErrorMessage   := cInvalidAuth;
                                vTokenValidate  := True;
                                vNeedAuthorization := False;
                                vTempEvent         := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions.EventName, vUriOptions.ServerEvent);
                                If vTempEvent = Nil Then
                                 Begin
                                  vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions);
                                  If vTempContext <> Nil Then
                                   vNeedAuthorization := vTempContext.NeedAuthorization
                                  Else
                                   vNeedAuthorization := True;
                                 End
                                Else
                                 vNeedAuthorization := vTempEvent.NeedAuthorization;
                                If vNeedAuthorization Then
                                 Begin
                                  vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                  vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                  If DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                   vToken         := DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                                  Else
                                   Begin
                                    vToken       := ARequest.Authorization;
                                    aToken       := '';
                                    If Trim(vToken) <> '' Then
                                     Begin
                                      aToken     := GetTokenString(vToken);
                                      If aToken = '' Then
                                       aToken    := GetBearerString(vToken);
                                      vToken     := aToken;
                                     End;
                                   End;
                                  If Not vAuthTokenParam.FromToken(vToken) Then
                                   Begin
                                    WriteError;
                                    DestroyComponents;
                                    Exit;
                                   End
                                  Else
                                   vTokenValidate := False;
                                  If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth) Then
                                   Begin
                                    TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth(vWelcomeMessage, vAccessTag, DWParams,
                                                                                                TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                                vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                    vTokenValidate := Not(vAcceptAuth);
                                    If Not vAcceptAuth Then
                                     Begin
                                      WriteError;
                                      DestroyComponents;
                                      Exit;
                                     End;
                                   End;
                                 End
                                Else
                                 vTokenValidate := False;
                               End;
                             End;
              End;
              vErrorCode            := 200;
              vErrorMessage         := '';
             End;
            If Assigned(TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage) then
             TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage, vAccessTag, vdwConnectionDefs, WelcomeAccept, vContentType, vErrorMessage);
           End;
         End
        Else
         Begin
          If vErrorCode <> 400 Then
           Begin
            vErrorCode := 401;
            JSONStr    := GetPairJSON(-5, 'Server Methods Cannot Assigned');
           End;
         End;
       End;
      Try
       If Assigned(vServerMethod) Then
        Begin
         {$IFNDEF FPC}
         If RemoveBackslashCommands(ARequest.PathInfo) + ARequest.Query <> '' Then
         {$ELSE}
         If {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                          {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                          {$ELSE}RemoveBackslashCommands(ARequest.URI){$ENDIF} <> '' Then
         {$ENDIF}
          Begin
           vOldMethod := vUriOptions.EventName;
           If vUriOptions.EventName = '' Then
            Begin
             If ARequest.Query <> '' Then
              vUriOptions.EventName := Trim(RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query) //Alterações enviadas por "joaoantonio19"
             Else
              vUriOptions.EventName := Trim(RemoveBackslashCommands(ARequest.PathInfo));
             If Pos('/?', vUriOptions.EventName) > InitStrPos Then
              vUriOptions.EventName := vOldMethod;
            End;
          End;
         While (Length(vUriOptions.EventName) > 0) Do
          Begin
           If Pos('/', vUriOptions.EventName) > 0 then
            vUriOptions.EventName := Copy(vUriOptions.EventName, InitStrPos +1, Length(vUriOptions.EventName))
           Else
            Begin
             vUriOptions.EventName := Trim(vUriOptions.EventName);
             If Pos('?', vUriOptions.EventName) > 0 Then
              vUriOptions.EventName := Copy(vUriOptions.EventName, 1, Pos('?', vUriOptions.EventName)-1);
             Break;
            End;
          End;
         If (vUriOptions.EventName = '') And (vUriOptions.ServerEvent = '') Then
          vUriOptions.EventName := vOldMethod;
         If vEncoding = esUtf8 Then
          AResponse.ContentType            := 'application/json;charset=utf-8'
         Else If vEncoding in [esANSI, esASCII] Then
          AResponse.ContentType            := 'application/json;charset=ansi';
         If vTempServerMethods <> Nil Then
          Begin
           JSONStr := ARequest.RemoteAddr;
           If DWParams <> Nil Then
            Begin
             If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
              dwassyncexec := DWParams.ItemsString['dwassyncexec'].AsBoolean;
             If DWParams.ItemsString['dwusecript'] <> Nil Then
              vdwCriptKey  := DWParams.ItemsString['dwusecript'].AsBoolean;
            End;
           {$IFDEF FPC}
           If vUriOptions.EventName = '' Then
            vUriOptions.EventName := StringReplace(RemoveBackslashCommands(ARequest.PathInfo), '/', '', [rfReplaceAll]);
           {$ENDIF}
//           SaveLog; //For Debbug Vars
           If DWParams.itemsstring['binaryRequest'] <> Nil Then
            vBinaryEvent := DWParams.itemsstring['binaryRequest'].value;
           If DWParams.itemsstring['BinaryCompatibleMode'] <> Nil Then
            vBinaryCompatibleMode := DWParams.itemsstring['BinaryCompatibleMode'].Value;
           If DWParams.itemsstring['MetadataRequest'] <> Nil Then
            vMetadata := DWParams.itemsstring['MetadataRequest'].value;
           If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
            dwassyncexec := DWParams.ItemsString['dwassyncexec'].AsBoolean;
           If Assigned(DWParams) Then
            DWParams.SetCriptOptions(vdwCriptKey, vCripto.Key);
           If DWParams.ItemsString['dwservereventname'] <> Nil Then
            Begin
             If (DWParams.ItemsString['dwservereventname'].AsString <> '') And (Trim(vUriOptions.ServerEvent) = '') Then
              Begin
               If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                Begin
                 If ((vUriOptions.BaseServer = '')  And
                     (vUriOptions.DataUrl    = '')) And
                    (vUriOptions.ServerEvent <> '') Then
                  vUriOptions.BaseServer := vUriOptions.ServerEvent
                 Else If ((vUriOptions.BaseServer <> '') And
                          (vUriOptions.DataUrl    = '')) And
                         (vUriOptions.ServerEvent <> '') And
                          (vServerContext = '')          Then
                  Begin
                   vUriOptions.DataUrl    := vUriOptions.BaseServer;
                   vUriOptions.BaseServer := vUriOptions.ServerEvent;
                  End;
                 vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
                End;
              End;
            End
           Else
            Begin
             If (vUriOptions.EventName <> '') and (vUriOptions.ServerEvent = '') Then
              Begin
               aParamsCount := cParamsCount;
               If ServerContext <> '' Then
                Inc(aParamsCount);
               If vDataRouteList.Count > 0 Then
                Inc(aParamsCount);
               {$IFDEF FPC}
                If Trim(ARequest.Query) <> '' Then
                 TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount)
                Else
                 TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
               {$ELSE}
                If Trim(ARequest.Query) <> '' Then
                 TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo) + '?' + ARequest.Query, vEncoding, vUriOptions, vmark, DWParams, aParamsCount)
                Else
                 TServerUtils.ParseRESTURL (RemoveBackslashCommands(ARequest.PathInfo), vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
               {$ENDIF}
              End;
            End;
//           SaveLog('New Line');
           If (vTempServerMethods.ClassType = TServerMethodDatamodule)             Or
              (vTempServerMethods.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
            Begin
             If ARequest.Referer = 'ipv6' Then
              vIPVersion := 'ipv6';
             vServerAuthOptions.CopyServerAuthParams(vRDWAuthOptionParam);
             TServerMethodDatamodule(vTempServerMethods).SetClientInfo(ARequest.RemoteAddr, vIPVersion,
                                                                       ARequest.UserAgent, vUriOptions.EventName, vUriOptions.ServerEvent, 0);
            End;
           If dwassyncexec Then
            Begin
             vErrorCode                   := 200;
             {$IFNDEF FPC}
              AResponse.StatusCode        := vErrorCode;
             {$ELSE}
              AResponse.Code              := vErrorCode;
             {$ENDIF}
             If vEncoding = esUtf8 Then
              AResponse.ContentEncoding   := 'utf-8'
             Else
              AResponse.ContentEncoding   := 'ansi';
             AResponse.ContentLength      := -1; //Length(JSONStr);
             If compresseddata Then
              Begin
               If vBinaryEvent Then
                Begin
                 ms := TStringStream.Create('');
                 If vGettoken Then
                  Begin
                   DWParams.Clear;
                   DWParams.CreateParam('token', vReplyString);
                  End;
                 Try
                  DWParams.SaveToStream(ms, tdwpxt_OUT);
                  ZCompressStreamD(ms, mb2);
                  //SaveLog('Com Compressao');
                 Finally
                  FreeAndNil(ms);
                 End;
                End
               Else
                Begin
                 mb2          := TStringStream(ZCompressStreamNew(AssyncCommandMSG));
                 mb2.Position := 0;
                End;
              End
             Else
              Begin
               If vBinaryEvent Then
                Begin
                 mb := TStringStream.Create('');
                 Try
                  //SaveLog('Sem Compressao');
                  DWParams.SaveToStream(mb, tdwpxt_OUT);
                 Finally

                 End;
                End
               Else
                Begin
                 //SaveLog('Else da Resposta');
                 {$IFDEF FPC}
                  If vEncoding = esUtf8 Then
                   mb                             := TStringStream.Create(Utf8Encode(vReplyStringResult))
                  Else
                   mb                             := TStringStream.Create(vReplyStringResult);
                 {$ELSE}
                 mb                               := TStringStream.Create(vReplyStringResult{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                 {$ENDIF}
                End;
               mb.Position                      := 0;
              End;
             {$IFNDEF FPC}
              {$IF CompilerVersion > 21}
               AResponse.FreeContentStream      := True;
              {$IFEND}
             {$ELSE}
              AResponse.FreeContentStream       := True;
             {$ENDIF}
             If compresseddata Then
              AResponse.ContentStream           := mb2
             Else
              AResponse.ContentStream           := mb;
             AResponse.ContentStream.Position   := 0;
             AResponse.ContentLength            := AResponse.ContentStream.Size;
             {$IFNDEF FPC}
              AResponse.StatusCode              := vErrorCode;
             {$ELSE}
              AResponse.Code                    := vErrorCode;
             {$ENDIF}
             Handled := True;
             {$IFNDEF FPC}
              AResponse.SendResponse;
             {$ELSE}
              AResponse.SendResponse;
             {$ENDIF}
             If Assigned(mb) Then
              FreeAndNil(mb); // Ico Menezes (retirada de Leaks) 05/02/2020
            End;
           If (Not (vGettoken)) And (Not (vTokenValidate)) Then
            Begin
             {$IFDEF FPC}
             If Not ServiceMethods(TComponent(vTempServerMethods), ARequest.LocalPathPrefix, vUriOptions, DWParams, JSONStr, JSONMode, vErrorCode,
                                   vContentType, vServerContextCall, ServerContextStream, vdwConnectionDefs, encodestrings, vAccessTag, WelcomeAccept, RequestType, vMark, vRequestHeader, vBinaryEvent, vMetadata, vBinaryCompatibleMode, vCompareContext) Then
             {$ELSE}
             If Not ServiceMethods(TComponent(vTempServerMethods), ARequest.Method, vUriOptions, DWParams, JSONStr, JsonMode, vErrorCode,
                                   vContentType, vServerContextCall, ServerContextStream, vdwConnectionDefs, encodestrings, vAccessTag, WelcomeAccept, RequestType, vMark, vRequestHeader, vBinaryEvent, vMetadata, vBinaryCompatibleMode, vCompareContext) Then
             {$ENDIF}
              Begin
               If Not dwassyncexec Then
                Begin
                 If Trim(lowercase(RemoveBackslashCommands(ARequest.PathInfo))) <> '' Then
                  sFile := GetFileOSDir(ExcludeTag(Trim(lowercase(RemoveBackslashCommands(ARequest.PathInfo)))))
                 Else
                  sFile := RemoveBackslashCommands(GetFileOSDir(ExcludeTag(Cmd)));
                 vFileExists := DWFileExists(sFile, FRootPath);
                 If Not vFileExists Then
                  Begin
                   tmp := '';
                   If ARequest.Referer <> '' Then
                    tmp := GetLastMethod(ARequest.Referer);
                   If Trim(lowercase(RemoveBackslashCommands(ARequest.PathInfo))) <> '' Then
                    sFile := GetFileOSDir(ExcludeTag(tmp + Trim(lowercase(RemoveBackslashCommands(ARequest.PathInfo)))))
                   Else
                    sFile := GetFileOSDir(ExcludeTag(RemoveBackslashCommands(Cmd)));
                   vFileExists := DWFileExists(sFile, FRootPath);
                  End;
                 vTagReply := vFileExists or scripttags(ExcludeTag(Cmd));
    //               SaveLog;
                 If vTagReply Then
                  Begin
                   AResponse.ContentType := GetMIMEType(sFile);
                   If TEncodeSelect(vEncoding) = esUtf8 Then
                    AResponse.ContentEncoding := 'utf-8'
                   Else If TEncodeSelect(vEncoding) in [esANSI, esASCII] Then
                    AResponse.ContentEncoding := 'ansi';
                   If scripttags(ExcludeTag(Cmd)) and Not vFileExists Then
                    AResponse.ContentStream         := TMemoryStream.Create
                   Else
                    AResponse.ContentStream         := TIdReadFileExclusiveStream.Create(sFile);
                   {$IFNDEF FPC}{$if CompilerVersion > 21}AResponse.FreeContentStream := true;{$IFEND}{$ENDIF}
                   {$IFNDEF FPC}
                    AResponse.StatusCode      := 200;
                   {$ELSE}
                    AResponse.Code            := 200;
                   {$ENDIF}
                   Handled := True;
                  End;
                End;
              End;
            End
           Else
            Begin
             JSONStr    := vToken;
             JsonMode   := jmPureJSON;
             vErrorCode := 200;
            End;
          End;
        End;
       Try
        If Not dwassyncexec Then
         Begin
          If (Not (vTagReply)) Then
           Begin
//            savelog;
            If vEncoding = esUtf8 Then
             AResponse.ContentEncoding := 'utf-8'
            Else
             AResponse.ContentEncoding := 'ansi';
            If vContentType <> '' Then
             AResponse.ContentType := vContentType;
            If Not vServerContextCall Then
             Begin
              If (Assigned(DWParams)) And (vUriOptions.EventName <> '') Then
               Begin
                If JsonMode in [jmDataware, jmUndefined] Then
                 Begin
                  If (Trim(JSONStr) <> '') And (Not (vBinaryEvent)) Then
                   Begin
                    If Not(((Pos('{', JSONStr) > 0)   And
                            (Pos('}', JSONStr) > 0))  Or
                           ((Pos('[', JSONStr) > 0)   And
                            (Pos(']', JSONStr) > 0))) Then
                     Begin
                      If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                       JSONStr := escape_chars(vErrorMessage)
                      Else If Not((JSONStr[InitStrPos] = '"') And
                             (JSONStr[Length(JSONStr)] = '"')) Then
                       JSONStr := '"' + JSONStr + '"';
                     End;
                   End;
                  If vBinaryEvent Then
                   Begin
                    vReplyString := JSONStr;
                    vErrorCode   := 200;
                   End
                  Else
                   Begin
                    If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                     vReplyString := escape_chars(vErrorMessage)
                    Else
                     vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
                   End;
                 End
                Else If JsonMode = jmPureJSON Then
                 Begin
                  If (Trim(JSONStr) = '') And (WelcomeAccept) Then
                   vReplyString := '{}'
                  Else If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                   vReplyString := escape_chars(vErrorMessage)
                  Else
                   vReplyString := JSONStr;
                 End;
               End;
              //SaveLog(DWParams.ToJSON);
              If compresseddata Then
               Begin
                If vBinaryEvent Then
                 Begin
                  //SaveLog('BinaryEvent');
                  ms := TStringStream.Create('');
                  If vGettoken Then
                   Begin
                    DWParams.Clear;
                    DWParams.CreateParam('token', vReplyString);
                   End;
                  Try
                   DWParams.SaveToStream(ms, tdwpxt_OUT);
                   //SaveLog(ms.DataString);
                   ZCompressStreamD(ms, mb2);
                  Finally
                   FreeAndNil(ms);
                  End;
                 End
                Else
                 Begin
                  //SaveLog('No BinaryEvent');
                  mb2 := TStringStream(ZCompressStreamNew(vReplyString));
                 End;
                If Assigned(mb2) Then
                 mb2.Position := 0;
               End
              Else
               Begin
                If (vUriOptions.EventName = '') and (vUriOptions.ServerEvent = '') And (vErrorCode = 404) then
                 Begin
                  If vDefaultPage.Count > 0 Then
                   vReplyString                    := vDefaultPage.Text
                  Else
                   vReplyString                    := TServerStatusHTML;
                  vErrorCode                       := 200;
                  AResponse.ContentType            := 'text/html';
                 End;
                 If (vBinaryEvent) And (Assigned(DWParams)) Then
                  Begin
                   mb := TStringStream.Create('');
                   Try
                    DWParams.SaveToStream(mb, tdwpxt_OUT);
                   Finally
                   End;
                  End
                 Else
                  Begin
                   {$IFDEF FPC}
                    If vEncoding = esUtf8 Then
                     mb                               := TStringStream.Create(Utf8Encode(vReplyString))
                    Else
                     mb                               := TStringStream.Create(vReplyString);
                   {$ELSE}
                    mb                                := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                   {$ENDIF}
                  End;
                 mb.Position                        := 0;
               End;
              If vErrorCode <> 200 Then
               Begin
                If Assigned(mb2) Then
                 FreeAndNil(mb2);
                If Assigned(mb) Then
                 FreeAndNil(mb);
                {$IFNDEF FPC}
                AResponse.ReasonString           := escape_chars(vReplyString);
                {$ELSE}
                AResponse.CodeText               := escape_chars(vReplyString);
                {$ENDIF}
               End
              Else
               Begin
                {$IFNDEF FPC}
                {$IF CompilerVersion > 21}
                AResponse.FreeContentStream      := True;
                {$IFEND}
                {$ELSE}
                 AResponse.FreeContentStream     := True;
                {$ENDIF}
                //SaveLog('New Data');
                If compresseddata Then
                 AResponse.ContentStream         := mb2
                Else
                 AResponse.ContentStream         := mb;
                AResponse.ContentStream.Position := 0;
                AResponse.ContentLength          := AResponse.ContentStream.Size;
               End;
              If Assigned(DWParams) Then
               Begin
                If DWParams.RequestHeaders.Output.Count > 0 Then
                 Begin
                  For I := 0 To DWParams.RequestHeaders.Output.Count -1 Do
                   AResponse.CustomHeaders.Add(DWParams.RequestHeaders.Output[I]);
                 End;
               End;
              If Assigned(DWParams) And
                (Pos(DWParams.Url_Redirect, Cmd) = 0) And
                (DWParams.Url_Redirect <> '') Then
               AResponse.SendRedirect(DWParams.Url_Redirect);
              {$IFNDEF FPC}
               AResponse.StatusCode            := vErrorCode;
              {$ELSE}
               AResponse.Code                  := vErrorCode;
              {$ENDIF}
              //SaveLog(DWParams.ToJSON);
             End
            Else
             Begin
              {$IFNDEF FPC}
               AResponse.StatusCode            := vErrorCode;
              {$ELSE}
               AResponse.Code                  := vErrorCode;
              {$ENDIF}
              If TEncodeSelect(vEncoding) = esUtf8 Then
               AResponse.ContentEncoding := 'utf-8'
              Else If TEncodeSelect(vEncoding) in [esANSI, esASCII] Then
               AResponse.ContentEncoding := 'ansi';
              If vBinaryEvent Then
               Begin
                If compresseddata Then
                 AResponse.ContentStream         := mb2
                Else
                 AResponse.ContentStream         := mb;
                AResponse.ContentStream.Position := 0;
                AResponse.ContentLength          := AResponse.ContentStream.Size;
                {$IFNDEF FPC}
                 AResponse.StatusCode            := vErrorCode;
                {$ELSE}
                 AResponse.Code                  := vErrorCode;
                {$ENDIF}
               End
              Else If ServerContextStream <> Nil Then
               Begin
                {$IFNDEF FPC}{$if CompilerVersion > 21}AResponse.FreeContentStream := true;{$IFEND}{$ENDIF}
                ServerContextStream.Position := 0;
                AResponse.ContentStream      := ServerContextStream;
                AResponse.ContentLength      := ServerContextStream.Size;
               End
              Else
               Begin
                AResponse.ContentLength      := -1; //Length(JSONStr);
                {$IFDEF FPC}
                 If vEncoding = esUtf8 Then
                  AResponse.Content          := Utf8Encode(JSONStr)
                 Else
                AResponse.Content            := JSONStr;
                {$ELSE}
                 AResponse.Content           := JSONStr;
                {$ENDIF}
               End;
             End;
           End;
         End;
       Finally
        {$IFNDEF FPC}
        {$IF CompilerVersion < 21}
        If Assigned(mb) Then
         FreeAndNil(mb);
        If Assigned(mb2) Then
         FreeAndNil(mb2);
        If Assigned(ServerContextStream) Then
         FreeAndNil(ServerContextStream);
        {$IFEND}
        {$ENDIF}
       End;
      Finally
       If Assigned(vServerMethod) Then
        If Assigned(vTempServerMethods) Then
         Begin
          If TServerMethodDatamodule(vTempServerMethods).QueuedRequest Then
           Begin
            {$IFNDEF FPC}
             {$IF CompilerVersion > 21}
              {$IFDEF WINDOWS}
               If Assigned(vCriticalSection) Then
                Begin
                 LeaveCriticalSection(vCriticalSection);
                 DeleteCriticalSection(vCriticalSection);
                End;
              {$ELSE}
               If Assigned(vCriticalSection) Then
                Begin
                 vCriticalSection.Release;
//                 FreeAndNil(vCriticalSection);
                End;
              {$ENDIF}
             {$ELSE}
              If Assigned(vCriticalSection) Then
               Begin
                vCriticalSection.Release;
                FreeAndNil(vCriticalSection);
               End;
             {$IFEND}
            {$ELSE}
             LeaveCriticalSection(vCriticalSection);
             DoneCriticalSection(vCriticalSection);
            {$ENDIF}
           End;
          Try
           FreeAndNil(vTempServerMethods); //.free;
          Except
          End;
         End;
      End;
     End;
 Finally
  //SaveLog('OnFinally');
  If AResponse.ContentLength = 0 Then
   Begin
    {$IFNDEF FPC}
    If AResponse.ReasonString = '' Then
    {$ELSE}
    If AResponse.CodeText = '' Then
    {$ENDIF}
     Begin
      If vDefaultPage.Count > 0 Then
       vReplyString         := vDefaultPage.Text
      Else
       vReplyString         := TServerStatusHTML;
     {$IFNDEF FPC}
      AResponse.StatusCode := 200;
     {$ELSE}
      AResponse.Code       := 200;
     {$ENDIF}
     End;
    AResponse.Content      := vReplyString;
    AResponse.ContentType  := 'text/html';
    If vEncoding = esUtf8 Then
     AResponse.ContentEncoding   := 'utf-8'
    Else
     AResponse.ContentEncoding   := 'ansi';
   End;
  If Not dwassyncexec Then
   Handled := True;
  //SaveLog(DWParams.ToJSON);
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(vdwConnectionDefs) Then
   FreeAndNil(vdwConnectionDefs);
  If Assigned(vRequestHeader) then
   FreeAndNil(vRequestHeader);
  If Assigned(vUriOptions) then
   FreeAndNil(vUriOptions);
  If Assigned(vServerMethod) Then
   If Assigned(vTempServerMethods) Then
    Begin
     Try
      FreeAndNil(vTempServerMethods); //.free;
     Except
     End;
    End;
 End;
End;

Procedure TRESTServiceCGI.SetCORSCustomHeader (Value : TStringList);
Var
 I : Integer;
Begin
 vCORSCustomHeaders.Clear;
 For I := 0 To Value.Count -1 do
  vCORSCustomHeaders.Add(Value[I]);
End;

Procedure TRESTServiceCGI.SetServerContext(Value : String);
Begin
 vServerContext := Lowercase(Value);
End;

Procedure TRESTServiceCGI.SetDefaultPage (Value : TStringList);
Var
 I : Integer;
Begin
 vDefaultPage.Clear;
 For I := 0 To Value.Count -1 do
  vDefaultPage.Add(Value[I]);
End;

Procedure TRESTServiceCGI.Loaded;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

procedure TRESTServiceCGI.SetServerMethod(Value: TComponentClass);
begin
 {$IFNDEF FPC}
  If (Value.InheritsFrom(TServerMethodDatamodule)) Or
     (Value             = TServerMethodDatamodule) Then
   Begin
    aServerMethod := Value;
    vServerBaseMethod := TServerMethodDatamodule;
   End;
 {$ELSE}
 If (Value.ClassType.InheritsFrom(TServerMethodDatamodule)) Or
    (Value             = TServerMethodDatamodule) Then
  Begin
   aServerMethod := Value;
   vServerBaseMethod := TServerMethodDatamodule;
  End;
 {$ENDIF}
end;

procedure TRESTServiceCGI.GetPoolerList(ServerMethodsClass: TComponent;
                                        Var PoolerList    : String;
                                        AccessTag         : String);
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

Procedure TRESTServiceCGI.GetServerEventsList(ServerMethodsClass   : TComponent;
                                              Var ServerEventsList : String;
                                              AccessTag            : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If Trim(TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
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

Function TRESTServiceCGI.ServiceMethods(BaseObject              : TComponent;
                                        AContext                : String;
                                        Var UriOptions          : TRESTDWUriOptions;
                                        Var DWParams            : TDWParams;
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
                                        Var   RequestHeader     : TStringList;
                                        BinaryEvent             : Boolean;
                                        Metadata                : Boolean;
                                        BinaryCompatibleMode    : Boolean;
                                        CompareContext          : Boolean): Boolean;
Var
 vJsonMSG,
 vResult,
 vResultIP,
 vUrlMethod,
 vOldServerEvent : String;
 vError,
 vInvalidTag  : Boolean;
 JSONParam    : TJSONParam;
Begin
 Result       := False;
 vUrlMethod   := UpperCase(UriOptions.EventName);
 If WelcomeAccept Then
  Begin
   If vUrlMethod = UpperCase('GetPoolerList') Then
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
     DWParams.ItemsString['Result'].SetValue(vResult, DWParams.ItemsString['Result'].Encoded);
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
   Else If vUrlMethod = UpperCase('EchoPooler') Then
    Begin
     vResultIP := JSONStr;
     vJsonMSG  := TReplyNOK;
     If DWParams.ItemsString['Pooler'] <> Nil Then
      Begin
       vResult    := DWParams.ItemsString['Pooler'].Value;
       EchoPooler(BaseObject, JSONStr, vResult, vResultIP, AccessTag, vInvalidTag);
      End;
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectValue     := ovString;
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResultIP,
                                             DWParams.ItemsString['Result'].Encoded);
     Result := vResultIP <> '';
     If Result Then
      Begin
       If DWParams.ItemsString['Result'] <> Nil Then
        JSONStr  := TReplyOK
       Else
        JSONStr  := vResultIP;
      End
     Else If vInvalidTag Then
      JSONStr    := TReplyTagError
     Else
      Begin
       JSONStr    := TReplyInvalidPooler;
       ErrorCode  := 405;
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
       Result  := ReturnContext(BaseObject, vUrlMethod, UriOptions.ServerEvent, vResult, ContentType, ServerContextStream, vError, DWParams, RequestType, mark, RequestHeader, ErrorCode);
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
           JSONStr    := vResult;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 404;
          End;
        End
       Else
        Begin
         JsonMode  := jmPureJSON;
         JSONStr   := vResult;
         If (ErrorCode <= 0) Or
            (ErrorCode > 299) Then
          ErrorCode := 200;
         ServerContextCall := True;
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
       If Not WelcomeAccept Then
        Begin
         JSONStr   := TReplyInvalidWelcome;
         ErrorCode := 500;
        End
       Else
        JSONStr := '';
       Result  := JSONStr <> '';
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
    ErrorCode  := 500;
  End;
End;

procedure TRESTServiceCGI.EchoPooler(ServerMethodsClass : TComponent;
                                     AContext           : String;
                                     Var Pooler, MyIP   : String;
                                     AccessTag          : String;
                                     Var InvalidTag     : Boolean);
Var
 I : Integer;
Begin
 MyIP := '';
 InvalidTag := False;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]) Then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             InvalidTag := True;
             Exit;
            End;
          End;
         If AContext <> '' Then
          MyIP := AContext;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceCGI.GetTableNames(ServerMethodsClass   : TComponent;
                                        Var Pooler           : String;
                                        Var DWParams         : TDWParams;
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

Procedure TRESTServiceCGI.GetKeyFieldNames(ServerMethodsClass   : TComponent;
                                           Var Pooler           : String;
                                           Var DWParams         : TDWParams;
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

Procedure TRESTServiceCGI.GetFieldNames(ServerMethodsClass   : TComponent;
                                        Var Pooler           : String;
                                        Var DWParams         : TDWParams;
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

procedure TRESTServiceCGI.ExecuteCommandPureJSON(ServerMethodsClass   : TComponent;
                                                 Var Pooler           : String;
                                                 Var DWParams         : TDWParams;
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
 BinaryBlob    := Nil;
 vRowsAffected := 0;
  try
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
                                                                                                       vExecute, BinaryEvent, Metadata, BinaryCompatibleMode);
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
   if Assigned(BinaryBlob) then
    FreeAndNil(BinaryBlob);
  End;
End;

procedure TRESTServiceCGI.ExecuteCommandPureJSONTB(ServerMethodsClass   : TComponent;
                                                   Var Pooler           : String;
                                                   Var DWParams         : TDWParams;
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
 vTablename,
 vTempJSON,
 vMessageError : String;
 BinaryBlob    : TMemoryStream;
Begin
 BinaryBlob    := Nil;
 vRowsAffected := 0;
  try
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
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename,
                                                                                                         vError,
                                                                                                         vMessageError,
                                                                                                         BinaryBlob,
                                                                                                         vRowsAffected,
                                                                                                         BinaryEvent,
                                                                                                         Metadata,
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
   if Assigned(BinaryBlob) then
    FreeAndNil(BinaryBlob);
  End;
End;

procedure TRESTServiceCGI.ExecuteCommandJSON(ServerMethodsClass   : TComponent;
                                             Var Pooler           : String;
                                             Var DWParams         : TDWParams;
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
 DWParamsD     : TDWParams;
 BinaryBlob    : TMemoryStream;
Begin
 DWParamsD     := Nil;
 BinaryBlob    := Nil;
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
              DWParamsD := TDWParams.Create;
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
                                                                                                        BinaryBlob, vRowsAffected,
                                                                                                        vExecute, BinaryEvent, Metadata, BinaryCompatibleMode);
              End
             Else
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                       vError,
                                                                                                       vMessageError,
                                                                                                       BinaryBlob, vRowsAffected,
                                                                                                       vExecute, BinaryEvent, Metadata, BinaryCompatibleMode);
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
              Else If Not (vError) And (vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON,
                                                       DWParams.ItemsString['Result'].Encoded)
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

procedure TRESTServiceCGI.ExecuteCommandJSONTB(ServerMethodsClass   : TComponent;
                                               Var Pooler           : String;
                                               Var DWParams         : TDWParams;
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
 DWParamsD     : TDWParams;
 BinaryBlob    : TMemoryStream;
Begin
 DWParamsD     := Nil;
 BinaryBlob    := Nil;
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
              DWParamsD := TDWParams.Create;
              DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
             End;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             If DWParamsD <> Nil Then
              Begin
               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, DWParamsD, vError, vMessageError,
                                                                                                          BinaryBlob, vRowsAffected,
                                                                                                          BinaryEvent, Metadata, BinaryCompatibleMode);
              End
             Else
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, vError,
                                                                                                         vMessageError,
                                                                                                         BinaryBlob, vRowsAffected,
                                                                                                         BinaryEvent, Metadata, BinaryCompatibleMode);
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
              Else If Not (vError) And (vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON,
                                                       DWParams.ItemsString['Result'].Encoded)
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

procedure TRESTServiceCGI.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TDWParams;
                                              ConnectionDefs     : TConnectionDefs;
                                              hEncodeStrings     : Boolean;
                                              AccessTag          : String);
Var
 I,
 vTempJSON     : Integer;
 vError        : Boolean;
 vMessageError : String;
 DWParamsD     : TDWParams;
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
             DWParamsD := TDWParams.Create;
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
              DWParams.ItemsString['Result'].SetValue(IntToStr(vTempJSON),
                                                      DWParams.ItemsString['Result'].Encoded)
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

procedure TRESTServiceCGI.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
 inherited Notification(AComponent, Operation);
end;

procedure TRESTServiceCGI.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                           Var Pooler         : String;
                                           Var DWParams       : TDWParams;
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
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
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
             DWParamsD := TDWParams.Create;
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
            If DWParamsD <> Nil Then
             DWParamsD.Free;
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
           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             DWParams.ItemsString['Result'].CriptOptions.Use := False;
             If vTempJSON <> Nil Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON,
                                                      DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

procedure TRESTServiceCGI.ApplyUpdatesJSONTB(ServerMethodsClass : TComponent;
                                             Var Pooler         : String;
                                             Var DWParams       : TDWParams;
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
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
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
             DWParamsD := TDWParams.Create;
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
            If DWParamsD <> Nil Then
             DWParamsD.Free;
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
           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
            Begin
             DWParams.ItemsString['Result'].CriptOptions.Use := False;
             If vTempJSON <> Nil Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON,
                                                      DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Function TRESTServiceCGI.ReturnContext(ServerMethodsClass : TComponent;
                                       Pooler,
                                       urlContext              : String;
                                       Var vResult,
                                       ContentType             : String;
                                       Var ServerContextStream : TMemoryStream;
                                       Var Error               : Boolean;
                                       Var   DWParams          : TDWParams;
                                       Const RequestType       : TRequestType;
                                       mark                    : String;
                                       RequestHeader           : TStringList;
                                       Var ErrorCode           : Integer) : Boolean;
Var
 I             : Integer;
 vRejected,
 vTagService,
 vDefaultPageB : Boolean;
 vBaseHeader,
 vErrorMessage,
 vStrAcceptedRoutes,
 vRootContext  : String;
 vDWRoutes     : TDWRoutes;
Begin
 Result        := False;
 Error         := False;
 vDefaultPageB := False;
 vRejected     := False;
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
     If ServerMethodsClass.Components[i] is TDWServerContext Then
      Begin
       If ((LowerCase(urlContext) = LowerCase(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext))) Or
          ((Trim(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext) = '') And (Pooler = '')        And
           (TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[urlContext] <> Nil))   Then
        Begin
         vRootContext := TDWServerContext(ServerMethodsClass.Components[i]).RootContext;
         If ((Pooler = '')    And (vRootContext <> '')) Then
          Pooler := vRootContext;
         vTagService := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler] <> Nil;
         If Not vTagService Then
          Begin
           Error   := True;
           vResult := cInvalidRequest;
          End;
        End;
       If vTagService Then
        Begin
         Result   := True;
         If (RequestTypeToRoute(RequestType) In TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Or
            (crAll in TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Then
          Begin
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer) Then
            TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer(ServerMethodsClass.Components[i]);
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest) Then
            TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If Not vRejected Then
            Begin
             vResult := '';
             Try
              ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContentType;
              TDWServerContext(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
              TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].CompareParams(DWParams);
              If mark <> '' Then
               Begin
                vResult    := '';
                Result     := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules);
                If Result Then
                 Begin
                  Result   := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark] <> Nil;
                  If Result Then
                   Begin
                    Result := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute);
                    If Result Then
                     Begin
                      ContentType := 'application/json';
                      TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute(DWParams, ContentType, vResult);
                     End;
                   End;
                 End;
               End
              Else If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules) Then
               Begin
                vBaseHeader := '';
                ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.ContentType;
                vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.BuildContext(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader,
                                                                                                                                          TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].IgnoreBaseHeader);
               End
              Else
               Begin
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall) Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler]);
                vDefaultPageB := Not Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest);
                If Not vDefaultPageB Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest(DWParams, ContentType, vResult, RequestType);
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream) Then
                 Begin
                  vDefaultPageB := False;
                  ServerContextStream := TMemoryStream.Create;
                  Try
                   TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream(DWParams, ContentType, ServerContextStream, RequestType, ErrorCode);
                  Finally
                   If ServerContextStream.Size = 0 Then
                    FreeAndNil(ServerContextStream);
                  End;
                 End;
                If vDefaultPageB Then
                 Begin
                  vBaseHeader := '';
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader) Then
                   vBaseHeader := TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader.Text;
                  vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].DefaultHtml.Text;
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer) Then
                   TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer(vBaseHeader, ContentType, vResult, RequestType);
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
                Error := True;
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
           vDWRoutes := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes;
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

Function TRESTServiceCGI.ReturnEvent(ServerMethodsClass : TComponent;
                                     Pooler,
                                     urlContext         : String;
                                     Var vResult        : String;
                                     Var DWParams       : TDWParams;
                                     Var JsonMode       : TJsonMode;
                                     Var ErrorCode      : Integer;
                                     Var ContentType,
                                     AccessTag          : String;
                                     Const RequestType  : TRequestType;
                                     RequestHeader      : TStringList) : Boolean;
Var
 I : Integer;
 vRejected,
 vTagService   : Boolean;
 vStrAcceptedRoutes,
 vErrorMessage : String;
 vDWRoutes: TDWRoutes;
Begin
 Result        := False;
 vRejected     := False;
 vTagService   := Result;
 vErrorMessage := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) Or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name))  Or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.classname + '.' +
                                             ServerMethodsClass.Components[i].Name))  Then
        vTagService := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
       If vTagService Then
        Begin
         Result   := True;
         JsonMode := jmPureJSON;
         If Trim(TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             If DWParams.ItemsString['dwencodestrings'] <> Nil Then
              vResult := EncodeStrings('Invalid Access tag...'{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else
              vResult := 'Invalid Access tag...';
             Result  := True;
             If (ErrorCode <= 0)  Or
                (ErrorCode = 200) Then
              ErrorCode := 500;
             Break;
            End;
          End;
         If (RequestTypeToRoute(RequestType) In TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Or
            (crAll in TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Then
          Begin
           vResult    := '';
           TDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
           If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest) Then
            TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If Not vRejected Then
            Begin
             TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].CompareParams(DWParams);
             Try
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler]);
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType(DWParams, vResult, RequestType, ErrorCode, RequestHeader)
              Else If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
              JsonMode := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].JsonMode;
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
               vResult   := vErrorMessage;
              End
             Else
              vResult   := 'The Requested URL was Rejected';
             If (ErrorCode <= 0)  Or
                (ErrorCode = 200) Then
              ErrorCode := 403;
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          Begin
           vStrAcceptedRoutes := '';
           vDWRoutes := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes;
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
           if vStrAcceptedRoutes <> '' then
            begin
              vResult   := 'Request rejected. Acceptable HTTP methods: '+vStrAcceptedRoutes;
              ErrorCode := 403;
            end
           else
            begin
              vResult   := 'Acceptable HTTP methods not defined on server';
              ErrorCode := 500;
            end;
          End;
         Break;
        End
       Else
         vResult := 'Event not found...';
      End;
    End;
  End;
 If Not vTagService Then
  If (ErrorCode <= 0)  Or
     (ErrorCode = 200) Then
   ErrorCode := 404;
End;

Procedure TRESTServiceCGI.GetEvents(ServerMethodsClass : TComponent;
                                    Pooler,
                                    urlContext         : String;
                                    Var DWParams       : TDWParams);
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
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       iContSE := iContSE + 1;
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) Or
          (LowerCase(urlContext) = LowerCase(Format('%s.%s', [ServerMethodsClass.Classname, ServerMethodsClass.Components[i].Name])))  Then
        Begin
         If vTempJSON = '' Then
          vTempJSON := Format('%s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
         Else
          vTempJSON := vTempJSON + Format(', %s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON]);
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

procedure TRESTServiceCGI.OpenDatasets(ServerMethodsClass   : TComponent;
                                       Var Pooler           : String;
                                       Var DWParams         : TDWParams;
                                       ConnectionDefs       : TConnectionDefs;
                                       hEncodeStrings       : Boolean;
                                       AccessTag            : String;
                                       BinaryRequest        : Boolean);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError    : Boolean;
 vMessageError : String;
 BinaryBlob    : TMemoryStream;
Begin
 BinaryBlob    := Nil;
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
//            DWParams.ItemsString['LinesDataset'].CriptOptions.Use := False;
            Try
             If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
              Raise Exception.Create(cInvalidDriverConnection);
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
                                                                                                    vError, vMessageError,
                                                                                                    BinaryBlob);
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

Procedure TRESTServiceCGI.ProcessMassiveSQLCache(ServerMethodsClass      : TComponent;
                                                 Var Pooler              : String;
                                                 Var DWParams            : TDWParams;
                                                 ConnectionDefs          : TConnectionDefs;
                                                 hEncodeStrings          : Boolean;
                                                 AccessTag               : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
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
               vTempJSON.Free;
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
End;

procedure TRESTServiceCGI.ApplyUpdates_MassiveCacheTB(ServerMethodsClass : TComponent;
                                                      Var Pooler         : String;
                                                      Var DWParams       : TDWParams;
                                                      ConnectionDefs     : TConnectionDefs;
                                                      hEncodeStrings     : Boolean;
                                                      AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
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
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            //DWParams.ItemsString['MassiveCache'].CriptOptions.Use := False;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCacheTB(DWParams.ItemsString['MassiveCache'].AsString,
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
          End;
         Break;
        End;
      End;
    End;
  End;
End;

procedure TRESTServiceCGI.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                    Var Pooler         : String;
                                                    Var DWParams       : TDWParams;
                                                    ConnectionDefs     : TConnectionDefs;
                                                    hEncodeStrings     : Boolean;
                                                    AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
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
           Try
            If Not TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ConnectionSet Then
             Raise Exception.Create(cInvalidDriverConnection);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            //DWParams.ItemsString['MassiveCache'].CriptOptions.Use := False;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].AsString,
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
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceCGI.ClearDataRoute;
Begin
 vDataRouteList.ClearList;
End;

Procedure TRESTServiceCGI.AddDataRoute(DataRoute : String; MethodClass : TComponentClass);
Var
 vDataRoute : TRESTDWDataRoute;
Begin
 vDataRoute.DataRoute         := DataRoute;
 vDataRoute.ServerMethodClass := MethodClass;
 vDataRouteList.Add(vDataRoute);
End;

Constructor TRESTServiceCGI.Create(AOwner: TComponent);
Begin
 Inherited Create(AOwner);
 vDefaultPage       := TStringList.Create;
 vCORSCustomHeaders := TStringList.Create;
 vDataRouteList     := TRESTDWDataRouteList.Create;
 vCORSCustomHeaders.Add('Access-Control-Allow-Origin=*');
 vCORSCustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
 vCORSCustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
 vServerAuthOptions                     := TRDWServerAuthOptionParams.Create(Self);
 vCripto                                := TCripto.Create;
 vServerAuthOptions.AuthorizationOption := rdwAONone;
 vForceWelcomeAccess                    := False;
 vServerContext                         := '';
 vEncoding                              := esUtf8;
 FRootPath                              := '/';
 vCORS                                  := False;
 vPathTraversalRaiseError               := True;
 aDefaultUrl                            := '';
 {$IFDEF FPC}
  vDatabaseCharSet                      := csUndefined;
 {$ENDIF}
End;

destructor TRESTServiceCGI.Destroy;
begin
 FreeAndNil(vDefaultPage);
 FreeAndNil(vCORSCustomHeaders);
 FreeAndNil(vCripto);
 FreeAndNil(vDataRouteList);
 If Assigned(vServerAuthOptions) Then
  FreeAndNil(vServerAuthOptions);
 inherited Destroy;
end;

Procedure TRESTClientPooler.Abort;
Begin
 Try
  HttpRequest.DisconnectNotifyPeer;
  Raise Exception.Create('Request Abort...');
 Except
 End;
End;

Constructor TRESTClientPooler.Create(AOwner: TComponent);
Begin
 Inherited;
 LHandler                              := Nil;
 HttpRequest                           := TIdHTTP.Create(Nil);
 vCripto                               := TCripto.Create;
 HttpRequest.Request.ContentType       := 'application/json';
 HttpRequest.AllowCookies              := False;
 vErrorCode                            := -1;
 HttpRequest.HTTPOptions               := [hoKeepOrigProtocol];
 vTransparentProxy                     := TIdProxyConnectionInfo.Create;
 vHost                                 := 'localhost';
 vServerContext                        := '';
 vDataRoute                            := '';
 vPort                                 := 8082;
 vAuthOptionParams                     := TRDWClientAuthOptionParams.Create(Self);
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
 vHandleRedirects                      := False;
 vPropThreadRequest                    := False;
 vFailOverConnections                  := TFailOverConnections.Create(Self, TRESTDWConnectionServerCP);
 vPoolerNotFoundMessage                := cPoolerNotFound;
End;

Destructor  TRESTClientPooler.Destroy;
Begin
 Try
  If HttpRequest.Connected Then
   HttpRequest.Disconnect;
 Except
 End;
 If Assigned(LHandler) then
  FreeAndNil(LHandler);
 FreeAndNil(HttpRequest);
 FreeAndNil(vTransparentProxy);
 FreeAndNil(vFailOverConnections);
 FreeAndNil(vCripto);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Function TRESTClientPooler.GetAccessTag: String;
Begin
 Result := vAccessTag;
End;

Function TRESTClientPooler.GetAllowCookies: Boolean;
Begin
 Result := HttpRequest.AllowCookies;
End;

Function TRESTClientPooler.GetHandleRedirects : Boolean;
Begin
 Result := vHandleRedirects;
End;

Procedure TRESTClientPooler.SetAuthOptionParams(Value : TRDWClientAuthOptionParams);
Begin
 vAuthOptionParams.Assign(Value);
End;

Function TRESTClientPooler.SendEvent(EventData       : String;
                                     Var Params      : TDWParams;
                                     EventType       : TSendEvent = sePOST;
                                     JsonMode        : TJsonMode  = jmDataware;
                                     ServerEventName : String     = '';
                                     Assyncexec      : Boolean    = False) : String; //Código original VCL e LCL
Var
 vErrorMessage,
 vErrorMessageA,
 vDataPack,
 SResult, vURL,
 vTpRequest       : String;
 I                : Integer;
 vDWParam         : TJSONParam;
 MemoryStream,
 vResultParams    : TStringStream;
 aStringStream,
 bStringStream,
 StringStream     : TStringStream;
 SendParams       : TIdMultipartFormDataStream;
 StringStreamList : TStringStreamList;
 JSONValue        : TJSONValue;
 aBinaryCompatibleMode,
 aBinaryRequest   : Boolean;
 Procedure SetData(Var InputValue : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue    : TDWJSONObject;
  bJsonOBJTemp  : TDWJSONArray;
  JSONParam,
  JSONParamNew  : TJSONParam;
  A, InitPos    : Integer;
  vValue,
  aValue,
  vTempValue    : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Begin
    If (vRSCharset = esUtf8) Then //NativeResult Correções aqui
     Begin
      {$IFDEF FPC}
       ResultJSON := GetStringDecode(InputValue, DatabaseCharSet);
      {$ELSE}
       {$IF (CompilerVersion > 22)}
        ResultJSON := PWidechar(InputValue); //PWidechar(UTF8Decode(InputValue));
       {$ELSE}
        ResultJSON := UTF8Decode(ResultJSON); //Correção para Delphi's Antigos de Charset.
       {$IFEND}
      {$ENDIF}
     End
    Else
     ResultJSON := InputValue;
    Exit;
   End;
  Try
//   InitPos    := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[') ;
   If (Pos(', "RESULT":[{"MESSAGE":"', InputValue) > 0) Then
    InitPos   := Pos(', "RESULT":[{"MESSAGE":"', InputValue) + Length(', "RESULT":[')   //TODO Brito
   Else If (Pos(', "RESULT":[', InputValue) > 0) Then
    InitPos   := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[')
   Else If (Pos('{"PARAMS":[{"', InputValue) > 0)       And
            (Pos('", "RESULT":', InputValue) > 0)       Then
    InitPos   := Pos('", "RESULT":', InputValue) + Length('", "RESULT":');
   aValue   := Copy(InputValue, InitPos,    Length(InputValue) -1);
   If Pos(']}', aValue) > 0 Then
    aValue     := Copy(aValue, InitStrPos, Pos(']}', aValue) -1);
   vTempValue := aValue;
   InputValue := Copy(InputValue, InitStrPos, InitPos-1) + ']}';//Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If (Params <> Nil) And (InputValue <> '{"PARAMS"]}') And (InputValue <> '') Then
    Begin
     {$IFDEF FPC}
      If vRSCharset = esUtf8 Then
       bJsonValue    := TDWJSONObject.Create(PWidechar(UTF8Decode(InputValue)))
      Else
       bJsonValue    := TDWJSONObject.Create(InputValue);
     {$ELSE}
      {$IF (CompilerVersion <= 22)}
       If vRSCharset = esUtf8 Then //Correção para Delphi's Antigos de Charset.
        bJsonValue    := TDWJSONObject.Create(PWidechar(UTF8Decode(InputValue)))
       Else
        bJsonValue    := TDWJSONObject.Create(InputValue);
      {$ELSE}
       bJsonValue    := TDWJSONObject.Create(InputValue);
      {$IFEND}
     {$ENDIF}
     InputValue    := '';
     If bJsonValue.PairCount > 0 Then
      Begin
       bJsonOBJTemp  := TDWJSONArray(bJsonValue.OpenArray(bJsonValue.pairs[0].name));
       If bJsonOBJTemp.ElementCount > 0 Then
        Begin
         For A := 0 To bJsonOBJTemp.ElementCount -1 Do
          Begin
           bJsonOBJ := TDWJSONObject(bJsonOBJTemp.GetObject(A));
           If Length(bJsonOBJ.Pairs[0].Value) = 0 Then
            Begin
             FreeAndNil(bJsonOBJ);
             Continue;
            End;
           If GetObjectName(bJsonOBJ.Pairs[0].Value) <> toParam Then
            Begin
             FreeAndNil(bJsonOBJ);
             Continue;
            End;
           JSONParam := TJSONParam.Create(vRSCharset);
           Try
            JSONParam.ParamName       := bJsonOBJ.Pairs[4].name;
            JSONParam.ObjectValue     := GetValueType(bJsonOBJ.Pairs[3].Value);
            JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.Pairs[1].Value);
            JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.Pairs[2].Value);
            If Not(JSONParam.ObjectValue In [ovBlob, ovStream, ovGraphic, ovOraBlob, ovOraClob]) Then
             Begin
              If (JSONParam.Encoded) Then
               Begin
                {$IFDEF FPC}
                 vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                {$ELSE}
                 vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 {$if CompilerVersion < 21}
                 If vRSCharset = esUtf8 Then
                  vValue := Utf8Decode(vValue);
                 vValue := AnsiString(vValue);
                 {$IFEND}
                {$ENDIF}
               End
              Else If JSONParam.ObjectValue <> ovObject then
               vValue := bJsonOBJ.Pairs[4].Value
              Else                                            //TODO Brito
               Begin
                vValue := bJsonOBJ.Pairs[4].Value;
                DeleteInvalidChar(vValue);
               End;
             End
            Else
             vValue := bJsonOBJ.Pairs[4].Value;
            JSONParam.SetValue(vValue, JSONParam.Encoded);
            //parametro criandos no servidor
            If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
             Begin
              JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
              JSONParamNew.ParamName := JSONParam.ParamName;
              JSONParamNew.ObjectDirection := JSONParam.ObjectDirection;
              JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
              ParamsData.Add(JSONParamNew);
             End
            Else If Not (ParamsData.ItemsString[JSONParam.ParamName].Binary) Then
             ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value
            Else
             ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
           Finally
            FreeAndNil(JSONParam);
            //Magno - 28/08/2018
            FreeAndNil(bJsonOBJ);
           End;
          End;
        End;
      End;
     If Assigned(bJsonValue) Then
      FreeAndNil(bJsonValue);
     If Assigned(bJsonOBJTemp) Then
      FreeAndNil(bJsonOBJTemp);
    End;
  Finally
   If vTempValue <> '' Then
    ResultJSON := vTempValue;
   vTempValue := '';
  End;
 End;
 Function GetParamsValues(Var DWParams : TDWParams{$IFDEF FPC};vDatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
 Var
  I         : Integer;
 Begin
  Result := '';
  JSONValue := Nil;
  If WelcomeMessage <> '' Then
   Result := 'dwwelcomemessage=' + EncodeStrings(WelcomeMessage{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
  If AccessTag <> '' Then
   Begin
    If Result <> '' Then
     Result := Result + '&dwaccesstag=' + EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
    Else
     Result := 'dwaccesstag=' + EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
   End;
  If ServerEventName <> '' Then
   Begin
    If Assigned(DWParams) Then
     Begin
      vDWParam             := DWParams.ItemsString['dwservereventname'];
      If Not Assigned(vDWParam) Then
       Begin
        vDWParam           := TJSONParam.Create(DWParams.Encoding);
        vDWParam.ObjectDirection := odIN;
        DWParams.Add(vDWParam);
       End;
      Try
       vDWParam.Encoded   := True;
       vDWParam.ParamName := 'dwservereventname';
       vDWParam.SetValue(ServerEventName, vDWParam.Encoded);
      Finally
//       FreeAndNil(JSONValue);
      End;
     End
    Else
     Begin
      JSONValue            := TJSONValue.Create;
      Try
       JSONValue.Encoding  := DWParams.Encoding;
       JSONValue.Encoded   := True;
       JSONValue.Tagname   := 'dwservereventname';
       JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
      Finally
       If Result <> '' Then
        Result := Result + '&dwservereventname=' + EncodeStrings(JSONValue.ToJSON{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else
        Result := 'dwservereventname=' + EncodeStrings(JSONValue.ToJSON{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
       FreeAndNil(JSONValue);
      End;
    End;
   End;
  If Result <> '' Then
   Result := Result + '&datacompression=' + BooleanToString(vDatacompress)
  Else
   Result := 'datacompression=' + BooleanToString(vDatacompress);
  If Result <> '' Then
   Result := Result + '&dwassyncexec=' + BooleanToString(Assyncexec)
  Else
   Result := 'dwassyncexec=' + BooleanToString(Assyncexec);
  If Result <> '' Then
   Result := Result + '&dwencodestrings=' + BooleanToString(hEncodeStrings)
  Else
   Result := 'dwencodestrings=' + BooleanToString(hEncodeStrings);
  If Result <> '' Then
   Begin
    If Assigned(vCripto) Then
     If vCripto.Use Then
      Result := Result + '&dwusecript=true';
   End
  Else
   Begin
    If Assigned(vCripto) Then
     If vCripto.Use Then
      Result := 'dwusecript=true';
   End;
  If DWParams <> Nil Then
   Begin
    For I := 0 To DWParams.Count -1 Do
     Begin
      If Result <> '' Then
       Begin
        If DWParams.Items[I].ObjectValue in [ovSmallint, ovInteger, ovWord, ovBoolean, ovByte,
                                             ovAutoInc, ovLargeint, ovLongWord, ovShortint, ovSingle] Then
         Result := Result + Format('&%s=%s', [DWParams.Items[I].ParamName, DWParams.Items[I].Value])
        Else
         Begin
          If vCripto.Use Then
           Result := Result + Format('&%s=%s', [DWParams.Items[I].ParamName, vCripto.Encrypt(DWParams.Items[I].Value)])
          Else
           Result := Result + Format('&%s=%s', [DWParams.Items[I].ParamName, EncodeStrings(DWParams.Items[I].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})]);
         End;
       End
      Else
       Begin
        If DWParams.Items[I].ObjectValue in [ovSmallint, ovInteger, ovWord, ovBoolean, ovByte,
                                             ovAutoInc, ovLargeint, ovLongWord, ovShortint, ovSingle] Then
         Result := Format('%s=%s', [DWParams.Items[I].ParamName, DWParams.Items[I].Value])
        Else
         Begin
          If vCripto.Use Then
           Result := Format('%s=%s', [DWParams.Items[I].ParamName, vCripto.Encrypt(DWParams.Items[I].Value)])
          Else
           Result := Format('%s=%s', [DWParams.Items[I].ParamName, EncodeStrings(DWParams.Items[I].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})]);
         End;
       End;
     End;
   End;
//  If Result <> '' Then
//   Result := '?' + Result;
 End;
 Procedure SetParamsValues(DWParams : TDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I : Integer;
 Begin
  MemoryStream  := Nil;
  If DWParams   <> Nil Then
   Begin
    If Not (Assigned(StringStreamList)) Then
     StringStreamList := TStringStreamList.Create;
    If BinaryRequest Then
     Begin
      {$IFDEF FPC}
       MemoryStream := TStringStream.Create('');
      {$ELSE}
       MemoryStream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
      {$ENDIF}
      DWParams.SaveToStream(MemoryStream);
      Try
       If Assigned(MemoryStream) Then
        Begin
         MemoryStream.Position := 0;
         {$IFNDEF FPC}
          {$IF (DEFINED(OLDINDY))}
           SendParamsData.AddObject( 'binarydata', 'application/octet-stream', MemoryStream); //StringStreamList.Items[StringStreamList.Count-1]);
          {$ELSE}
           SendParamsData.AddObject( 'binarydata', 'application/octet-stream', '', MemoryStream); //StringStreamList.Items[StringStreamList.Count-1]);
          {$IFEND}
         {$ELSE}
          SendParamsData.AddObject( 'binarydata', 'application/octet-stream', '', MemoryStream); //StringStreamList.Items[StringStreamList.Count-1]);
         {$ENDIF}
        End;
      Finally
      End;
     End
    Else
     Begin
      For I := 0 To DWParams.Count -1 Do
       Begin
        If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob, ovStream,
                                             ovMemo,   ovGraphic, ovFmtMemo,  ovOraBlob, ovOraClob] Then
         Begin
          StringStreamList.Add({$IFDEF FPC}
                               TStringStream.Create(DWParams.Items[I].ToJSON)
                               {$ELSE}
                               TStringStream.Create(DWParams.Items[I].ToJSON{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND})
                               {$ENDIF});
          {$IFNDEF FPC}
           {$if CompilerVersion > 21}
            SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
           {$ELSE}
            {$IF (DEFINED(OLDINDY))}
             SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', StringStreamList.Items[StringStreamList.Count-1]);
            {$ELSE}
             SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
            {$IFEND}
           {$IFEND}
          {$ELSE}
           SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
          {$ENDIF}
         End
        Else
         SendParamsData.AddFormField(DWParams.Items[I].ParamName, DWParams.Items[I].ToJSON);
       End;
     End;
   End;
 End;
 Function BuildUrl(TpRequest     : TTypeRequest;
                   Host, UrlPath,
                   aDataRoute,
                   aServerContext : String;
                   Port           : Integer) : String;
 Var
  vTpRequest : String;
 Begin
  Result := '';
  If TpRequest = trHttp Then
   vTpRequest := 'http'
  Else If TpRequest = trHttps Then
   vTpRequest := 'https';
  If (aDataRoute = '') And (aServerContext = '') Then
   Result := LowerCase(Format(UrlBase, [vTpRequest, Host, Port, UrlPath])) + EventData
  Else
   Begin
    If (aDataRoute = '') And (aServerContext <> '') Then
     Result := LowerCase(Format(UrlBase,  [vTpRequest, Host, Port, aServerContext + '/', UrlPath])) + EventData
    Else If (aDataRoute <> '') And (aServerContext = '') Then
     Result := LowerCase(Format(UrlBaseA, [vTpRequest, Host, Port, aDataRoute + '/', UrlPath])) + EventData
    Else
     Result := LowerCase(Format(UrlBaseB, [vTpRequest, Host, Port,
                                           aServerContext + '/',
                                           aDataRoute     + '/',
                                           UrlPath])) + EventData
   End;
 End;
 Procedure SetCharsetRequest(Var HttpRequest : TIdHTTP;
                             Charset         : TEncodeSelect);
 Begin
  If Charset = esUtf8 Then
   Begin
    HttpRequest.Request.ContentType := 'application/json;charset=utf-8';
    HttpRequest.Request.Charset := 'utf-8';
   End
  Else If Charset in [esANSI, esASCII] Then
   HttpRequest.Request.Charset := 'ansi';
 End;
 Function ExecRequest(EventType : TSendEvent;
                      URL,
                      WelcomeMessage,
                      AccessTag       : String;
                      Charset         : TEncodeSelect;
                      Datacompress,
                      hEncodeStrings,
                      BinaryRequest   : Boolean;
                      Var ResultData,
                      ErrorMessage    : String) : Boolean;
 Var
  vAccessURL,
  vWelcomeMessage,
  vUrl             : String;
  Function BuildValue(Name, Value : String) : String;
  Begin
   If vURL = URL + '?' Then
    Result := Format('%s=%s', [Name, Value])
   Else
    Result := Format('&%s=%s', [Name, Value]);
  End;
 Begin
  Result          := True;
  ResultData      := '';
  ErrorMessage    := '';
  vAccessURL      := '';
  vWelcomeMessage := '';
  vUrl            := '';
  {$IFDEF FPC}
   vResultParams   := TStringStream.Create('');
  {$ELSE}
   vResultParams   := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  {$ENDIF}
  Try
   HttpRequest.Request.UserAgent      := vUserAgent;
   HttpRequest.RedirectMaximum        := vRedirectMaximum;
   HttpRequest.HandleRedirects        := vHandleRedirects;
   Case EventType Of
    seGET,
    seDELETE :
     Begin
      HttpRequest.Request.ContentType := 'application/json';
      vURL := URL + '?';
      If WelcomeMessage <> '' Then
       vURL := vURL + BuildValue('dwwelcomemessage', EncodeStrings(WelcomeMessage{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If (AccessTag <> '') Then
       vURL := vURL + BuildValue('dwaccesstag',      EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If vAuthOptionParams.AuthorizationOption    <> rdwAONone Then
       Begin
        Case vAuthOptionParams.AuthorizationOption Of
         rdwAOBearer : Begin
                        If TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).TokenRequestType <> rdwtHeader Then
                         If TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token <> '' Then
                          vURL := vURL + BuildValue(TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Key, TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token);
                       End;
         rdwAOToken  : Begin
                        If TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).TokenRequestType <> rdwtHeader Then
                         If TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Token <> '' Then
                          vURL := vURL + BuildValue(TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Key, TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Token);
                       End;
        End;
       End;
      vURL := vURL + BuildValue('datacompression',   BooleanToString(vDatacompress));
      vURL := vURL + BuildValue('dwassyncexec',      BooleanToString(Assyncexec));
      vURL := vURL + BuildValue('dwencodestrings',   BooleanToString(hEncodeStrings));
      vURL := vURL + BuildValue('binaryrequest',     BooleanToString(vBinaryRequest));
      If aBinaryCompatibleMode Then
       vURL := vURL + BuildValue('BinaryCompatibleMode', BooleanToString(aBinaryCompatibleMode));
      vURL := Format('%s&%s', [vURL, GetParamsValues(Params{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})]);
      If Assigned(vCripto) Then
       vURL := vURL + BuildValue('dwusecript',       BooleanToString(vCripto.Use));
      {$IFDEF FPC}
       aStringStream := TStringStream.Create('');
      {$ELSE}
       aStringStream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
      {$ENDIF}
      Case EventType Of
       seGET    : HttpRequest.Get(vURL, aStringStream);
       seDELETE : Begin
                   {$IFDEF FPC}
                    HttpRequest.Delete(vURL, aStringStream);
                   {$ELSE}
                    {$IFDEF OLDINDY}
                     HttpRequest.Delete(vURL);
                    {$ELSE}
                     //HttpRequest.Delete(AUrl, atempResponse);
                     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, vURL, SendParams, aStringStream, []);
                    {$ENDIF}
                   {$ENDIF}
                  End;
      End;
      If Not Assyncexec Then
       Begin
        If vDatacompress Then
         Begin
          If Assigned(aStringStream) Then
           Begin
            If aStringStream.Size > 0 Then
             StringStream := ZDecompressStreamNew(aStringStream);
            FreeAndNil(aStringStream);
            ResultData := StringStream.DataString;
            FreeAndNil(StringStream);
           End;
         End
        Else
         Begin
          ResultData := aStringStream.DataString;
          FreeAndNil(aStringStream);
         End;
       End;
      If vRSCharset = esUtf8 Then
       ResultData := Utf8Decode(ResultData);
     End;
    sePOST,
    sePUT,
    sePATCH :
     Begin;
      SendParams := TIdMultiPartFormDataStream.Create;
      If WelcomeMessage <> '' Then
       SendParams.AddFormField('dwwelcomemessage', EncodeStrings(WelcomeMessage{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If AccessTag <> '' Then
       SendParams.AddFormField('dwaccesstag',      EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If ServerEventName <> '' Then
       Begin
        If Assigned(Params) Then
         Begin
          vDWParam             := Params.ItemsString['dwservereventname'];
          If Not Assigned(vDWParam) Then
           vDWParam           := TJSONParam.Create(Params.Encoding);
          Try
           vDWParam.Encoded         := True;
           vDWParam.ObjectDirection := odIN;
           vDWParam.ParamName       := 'dwservereventname';
           vDWParam.SetValue(ServerEventName, vDWParam.Encoded);
          Finally
           If Params.ItemsString['dwservereventname'] = Nil Then
            Params.Add(vDWParam);
          End;
         End;
        JSONValue           := TJSONValue.Create;
        Try
         JSONValue.Encoding := Charset;
         JSONValue.Encoded  := True;
         JSONValue.Tagname  := 'dwservereventname';
         JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
        Finally
         SendParams.AddFormField('dwservereventname', JSONValue.ToJSON);
         //Magno - 28/08/2018
         FreeAndNil(JSONValue);
        End;
       End;
      SendParams.AddFormField('datacompression',   BooleanToString(vDatacompress));
      SendParams.AddFormField('dwassyncexec',      BooleanToString(Assyncexec));
      SendParams.AddFormField('dwencodestrings',   BooleanToString(hEncodeStrings));
      SendParams.AddFormField('binaryrequest',     BooleanToString(vBinaryRequest));
      If vAuthOptionParams.AuthorizationOption    <> rdwAONone Then
       Begin
        If Assigned(Params) Then
         Begin
          Case vAuthOptionParams.AuthorizationOption Of
           rdwAOBearer : Begin
                          If TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).TokenRequestType <> rdwtHeader Then
                           Begin
                            If TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token <> '' Then
                             Begin
                              SendParams.AddFormField(TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Key,
                                                      TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token);
                              vDWParam             := Params.ItemsString[TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Key];
                              If Not Assigned(vDWParam) Then
                               vDWParam           := TJSONParam.Create(Params.Encoding);
                              Try
                               vDWParam.Encoded         := True;
                               vDWParam.ObjectDirection := odIN;
                               vDWParam.ParamName       := TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Key;
                               vDWParam.SetValue(TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token, vDWParam.Encoded);
                              Finally
                               If Params.ItemsString[TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Key] = Nil Then
                                Params.Add(vDWParam);
                              End;
                             End;
                           End;
                         End;
           rdwAOToken  : Begin
                          If TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).TokenRequestType <> rdwtHeader Then
                           Begin
                            If TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Token <> '' Then
                             Begin
                              SendParams.AddFormField(TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Key,
                                                      TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Token);
                              vDWParam             := Params.ItemsString[TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Key];
                              If Not Assigned(vDWParam) Then
                               vDWParam           := TJSONParam.Create(Params.Encoding);
                              Try
                               vDWParam.Encoded         := True;
                               vDWParam.ObjectDirection := odIN;
                               vDWParam.ParamName       := TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Key;
                               vDWParam.SetValue(TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Token, vDWParam.Encoded);
                              Finally
                               If Params.ItemsString[TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Key] = Nil Then
                                Params.Add(vDWParam);
                              End;
                             End;
                           End;
                         End;
          End;
         End
        Else
         Begin
          Case vAuthOptionParams.AuthorizationOption Of
           rdwAOBearer : Begin
                          If TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).TokenRequestType <> rdwtHeader Then
                           SendParams.AddFormField(TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Key, TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token);
                         End;
           rdwAOToken  : Begin
                          If TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).TokenRequestType <> rdwtHeader Then
                           SendParams.AddFormField(TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Key,  TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Token);
                         End;
          End;
         End;
       End;
      If aBinaryCompatibleMode Then
       SendParams.AddFormField('BinaryCompatibleMode', BooleanToString(aBinaryCompatibleMode));
      If Assigned(vCripto) Then
       SendParams.AddFormField('dwusecript',       BooleanToString(vCripto.Use));
      If Params <> Nil Then
       SetParamsValues(Params, SendParams);
      If (Params <> Nil) Or (WelcomeMessage <> '') Or (Datacompress) Then
       Begin
        HttpRequest.Request.Accept          := 'application/json';
        HttpRequest.Request.ContentType     := 'application/x-www-form-urlencoded';
        HttpRequest.Request.ContentEncoding := 'multipart/form-data';
        If TEncodeSelect(vRSCharset) = esUtf8 Then
         HttpRequest.Request.Charset        := 'Utf-8'
        Else If TEncodeSelect(vRSCharset) in [esANSI, esASCII] Then
         HttpRequest.Request.Charset        := 'ansi';
        If Not vBinaryRequest Then
         While HttpRequest.Request.CustomHeaders.IndexOfName('binaryrequest') > -1 Do
          HttpRequest.Request.CustomHeaders.Delete(HttpRequest.Request.CustomHeaders.IndexOfName('binaryrequest'));
        If Not aBinaryCompatibleMode Then
         While HttpRequest.Request.CustomHeaders.IndexOfName('BinaryCompatibleMode') > -1 Do
          HttpRequest.Request.CustomHeaders.Delete(HttpRequest.Request.CustomHeaders.IndexOfName('BinaryCompatibleMode'));
        HttpRequest.Request.UserAgent := vUserAgent;
        If vDatacompress Then
         Begin
          {$IFDEF FPC}
           aStringStream := TStringStream.Create('');
          {$ELSE}
           aStringStream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
          {$ENDIF}
          Case EventType Of
           sePUT    : HttpRequest.Put   (URL, SendParams, aStringStream);
           sePATCH  : Begin
                       {$IFNDEF OLDINDY}
                        {$IFDEF INDY_NEW}
                         {$IF CompilerVersion > 26} // Delphi XE6 pra cima
                          HttpRequest.Patch (URL, SendParams, aStringStream);
                         {$IFEND}
                        {$ENDIF}
                       {$ENDIF}
                      End;
           sePOST   : HttpRequest.Post  (URL, SendParams, aStringStream);
          end;
          If Not Assyncexec Then
           Begin
            If Assigned(aStringStream) Then
             Begin
              If aStringStream.Size > 0 Then
               StringStream := ZDecompressStreamNew(aStringStream);
              FreeAndNil(aStringStream);
             End;
           End;
         End
        Else
         Begin
          StringStream   := TStringStream.Create('');
          Case EventType Of
           sePUT    : HttpRequest.Put   (URL, SendParams, StringStream);
           sePATCH  : Begin
                       {$IFNDEF OLDINDY}
                        {$IFDEF INDY_NEW}
                         {$IF CompilerVersion > 26} // Delphi XE6 pra cima
                          HttpRequest.Patch (URL, SendParams, StringStream);
                         {$IFEND}
                        {$ENDIF}
                       {$ENDIF}
                      End;
           sePOST   : HttpRequest.Post  (URL, SendParams, StringStream);
          end;
         End;
        If SendParams <> Nil Then
         Begin
          If Assigned(StringStreamList) Then
           FreeAndNil(StringStreamList);
          {$IFNDEF FPC}
           {$IF Not(DEFINED(OLDINDY))}
            SendParams.Clear;
           {$IFEND}
          {$ENDIF}
          FreeAndNil(SendParams);
         End;
       End
      Else
       Begin
        HttpRequest.Request.ContentType     := 'application/json';
        HttpRequest.Request.ContentEncoding := '';
        HttpRequest.Request.UserAgent       := vUserAgent;
        aStringStream := TStringStream.Create('');
        HttpRequest.Get(URL, aStringStream);
        aStringStream.Position := 0;
        StringStream   := TStringStream.Create('');
        bStringStream  := TStringStream.Create('');
        If Not Assyncexec Then
         Begin
          If vDatacompress Then
           Begin
            bStringStream.CopyFrom(aStringStream, aStringStream.Size);
            bStringStream.Position := 0;
            ZDecompressStreamD(bStringStream, StringStream);
           End
          Else
           Begin
            bStringStream.CopyFrom(aStringStream, aStringStream.Size);
            bStringStream.Position := 0;
            HexToStream(bStringStream.DataString, StringStream);
           End;
         End;
        FreeAndNil(bStringStream);
        FreeAndNil(aStringStream);
       End;
      HttpRequest.Request.Clear;
      If vBinaryRequest Then
       Begin
        If Not Assyncexec Then
         Begin
          StringStream.Position := 0;
          Params.LoadFromStream(StringStream);
          {$IFNDEF FPC}
           {$IF CompilerVersion > 21}
            StringStream.Clear;
           {$IFEND}
           StringStream.Size := 0;
          {$ENDIF}
          FreeAndNil(StringStream);
         End;
        ResultData := TReplyOK;
       End
      Else
       Begin
        If Not Assyncexec Then
         Begin
          StringStream.Position := 0;
          vDataPack := StringStream.DataString;
          {$IFNDEF FPC}
           {$IF CompilerVersion > 21}
            StringStream.Clear;
           {$IFEND}
           StringStream.Size := 0;
          {$ENDIF}
          FreeAndNil(StringStream);
          If BinaryRequest Then
           Begin
            If Pos(TReplyNOK, vDataPack) > 0 Then
             SetData(vDataPack, Params, ResultData)
            Else
             ResultData := vDataPack
           End
          Else
           SetData(vDataPack, Params, ResultData);
         End;
       End;
     End;
   End;
  Except
   On E : EIdHTTPProtocolException Do
    Begin
     Result := False;
     ResultData := '';
     vErrorMessageA := HttpRequest.ResponseText;
     vErrorCode     := e.ErrorCode;
     If Pos(Uppercase(cInvalidInternalError), Uppercase(vErrorMessageA)) = 0 Then
      Begin
       vErrorMessage := Trim(vErrorMessageA);
       vErrorMessage := StringReplace(vErrorMessage, '\\', '\', [rfReplaceAll]);
       If Pos(IntToStr(e.ErrorCode), vErrorMessage) > 0 Then
        Begin
         Delete(vErrorMessage, 1, Pos(IntToStr(e.ErrorCode), vErrorMessage) + Length(IntToStr(e.ErrorCode)));
         vErrorMessage := Trim(vErrorMessage);
        End;
       {$IFDEF FPC}
        vErrorMessage := Unescape_chars(vErrorMessage);
       {$ELSE}
        {$IF CompilerVersion <= 22}
         vErrorMessage := Unescape_chars(vErrorMessage);
        {$ELSE}
         vErrorMessage := vErrorMessage;
        {$IFEND}
       {$ENDIF}
      End;
     If e.ErrorCode = 405 Then
      vErrorMessage := cInvalidPoolerName;
     If e.ErrorCode = 401 Then
      Begin
       vErrorMessage := cInvalidAuth;
       //ClearToken to Auto-Renew
       Case AuthenticationOptions.AuthorizationOption Of
        rdwAOBearer : Begin
                       If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                          (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                        TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                      End;
        rdwAOToken  : Begin
                       If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                          (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                        TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                      End;
       End;
      End;
     {Todo: Acrescentado}
     If Assigned(MemoryStream) Then
      FreeAndNil(MemoryStream);
     If Assigned(aStringStream) Then
      FreeAndNil(aStringStream);
     If Assigned(SendParams) then
      FreeAndNil(SendParams);
     //Alexandre Magno - 24/11/2018
     If Assigned(vResultParams) then
      FreeAndNil(vResultParams);
     //Alexandre Magno - 24/11/2018
     If Assigned(StringStreamList) Then
      FreeAndNil(StringStreamList);
     If Assigned(StringStream) then
      FreeAndNil(StringStream);
     If Assigned(aStringStream) then
      FreeAndNil(aStringStream);
     If Assigned(HttpRequest) Then
      If HttpRequest.Connected Then
       HttpRequest.Disconnect;
     If Not vFailOver then
      Begin
      {$IFNDEF FPC}
       {$IF Defined(HAS_FMX)}
        ErrorMessage := vErrorMessage;
       {$ELSE}
        Raise Exception.Create(vErrorMessage);
       {$IFEND}
      {$ELSE}
       Raise Exception.Create(vErrorMessage);
      {$ENDIF}
      End
     Else
      ErrorMessage := vErrorMessage;
    End;
   On E : Exception Do
    Begin
     Result := False;
     ResultData := GetPairJSON('NOK', vPoolerNotFoundMessage);
     {Todo: Acrescentado}
     If Assigned(SendParams) then
      FreeAndNil(SendParams);
     //Alexandre Magno - 24/11/2018
     If Assigned(vResultParams) then
      FreeAndNil(vResultParams);
     //Alexandre Magno - 24/11/2018
     If Assigned(StringStreamList) Then
      FreeAndNil(StringStreamList);
     If Assigned(StringStream) then
      FreeAndNil(StringStream);
     If Assigned(aStringStream) then
      FreeAndNil(aStringStream);
     If Assigned(MemoryStream) Then
      FreeAndNil(MemoryStream);
     If Assigned(HttpRequest) Then
      If HttpRequest.Connected Then
       HttpRequest.Disconnect;
     If Not vFailOver then
      Begin
       ErrorMessage := E.Message;
      {$IFNDEF FPC}
       {$IF Defined(HAS_FMX)}
        ErrorMessage := vPoolerNotFoundMessage;
       {$ELSE}
        Raise Exception.Create(vPoolerNotFoundMessage);
       {$IFEND}
      {$ELSE}
       Raise Exception.Create(vPoolerNotFoundMessage);
      {$ENDIF}
      End
     Else
      ErrorMessage := e.Message;
    End;
  End;
  If Assigned(vResultParams) Then
   FreeAndNil(vResultParams);
  If Assigned(SendParams) then
   FreeAndNil(SendParams);
  If Assigned(StringStream) then
   FreeAndNil(StringStream);
  If Assigned(MemoryStream) then
   FreeAndNil(MemoryStream);
  If Assigned(aStringStream) Then
   FreeAndNil(aStringStream);
  If Assigned(MemoryStream) Then
   FreeAndNil(MemoryStream);
 End;
Begin
 vDWParam         := Nil;
 MemoryStream     := Nil;
 vResultParams    := Nil;
 aStringStream    := Nil;
 bStringStream    := Nil;
 JSONValue        := Nil;
 SendParams       := Nil;
 StringStreamList := Nil;
 StringStream     := Nil;
 aStringStream    := Nil;
 vResultParams    := Nil;
 aBinaryRequest   := False;
 aBinaryCompatibleMode := False;
 If (Params.ItemsString['BinaryRequest'] <> Nil) Then
  aBinaryRequest  := Params.ItemsString['BinaryRequest'].AsBoolean;
 If (Params.ItemsString['BinaryCompatibleMode'] <> Nil) Then
  aBinaryCompatibleMode := Params.ItemsString['BinaryCompatibleMode'].AsBoolean And aBinaryRequest;
 if Not aBinaryRequest then
  aBinaryRequest  := vBinaryRequest;
 vURL  := BuildUrl(vTypeRequest, vHost, vUrlPath,  DataRoute, ServerContext, vPort);
 If Not Assigned(LHandler)  And
   (vTypeRequest = trHttps) Then
  Begin
   LHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
   LHandler.SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
   HttpRequest.IOHandler := LHandler;
  End;
 HttpRequest.Request.UserAgent := vUserAgent;
 SetCharsetRequest(HttpRequest, vRSCharset);
 SetParams(HttpRequest, vAuthentication, vTransparentProxy, vRequestTimeout, vConnectTimeout, AuthenticationOptions);
 HttpRequest.MaxAuthRetries := 0;
 If vBinaryRequest Then
  If HttpRequest.Request.CustomHeaders.IndexOfName('binaryrequest') = -1 Then
   HttpRequest.Request.CustomHeaders.AddValue('binaryrequest', 'true');
 If aBinaryCompatibleMode Then
  If HttpRequest.Request.CustomHeaders.IndexOfName('BinaryCompatibleMode') = -1 Then
   HttpRequest.Request.CustomHeaders.AddValue('BinaryCompatibleMode', 'true');
 vErrorMessage              := '';
 vErrorCode                 := -1;
 Try
  If Not ExecRequest(EventType, vURL, vWelcomeMessage, vAccessTag, vRSCharset, vDatacompress, vEncodeStrings, aBinaryRequest, Result, vErrorMessage) Then
   Begin
    If vFailOver Then
     Begin
      For I := 0 To vFailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((vFailOverConnections[I].vTypeRequest    = vTypeRequest)    And
              (vFailOverConnections[I].vWelcomeMessage = vWelcomeMessage) And
              (vFailOverConnections[I].vRestWebService = vHost)           And
              (vFailOverConnections[I].vPoolerPort     = vPort)           And
              (vFailOverConnections[I].vCompression    = vDatacompress)   And
              (vFailOverConnections[I].hEncodeStrings  = hEncodeStrings)  And
              (vFailOverConnections[I].Encoding        = vRSCharset)      And
              (vFailOverConnections[I].vAccessTag      = vAccessTag)      And
              (vFailOverConnections[I].Host            = vHost)           And
              (vFailOverConnections[I].vRestURL        = vUrlPath)        And
              (vFailOverConnections[I].vAuthentication = vAuthentication))Or
             (Not (vFailOverConnections[I].Active)) Then
          Continue;
         End;
        If Assigned(vOnFailOverExecute) Then
         vOnFailOverExecute(vFailOverConnections[I]);
        vURL  := BuildUrl(vFailOverConnections[I].vTypeRequest,
                          vFailOverConnections[I].Host,
                          vFailOverConnections[I].vRestURL,
                          vFailOverConnections[I].DataRoute,
                          vFailOverConnections[I].ServerContext,
                          vFailOverConnections[I].Port); //LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
        SetCharsetRequest(HttpRequest, vFailOverConnections[I].Encoding);
        SetParams(HttpRequest,
                  vFailOverConnections[I].vAuthentication,
                  vFailOverConnections[I].vTransparentProxy,
                  vFailOverConnections[I].vTimeOut,
                  vFailOverConnections[I].vConnectTimeOut,
                  vFailOverConnections[I].AuthenticationOptions);
        If ExecRequest(EventType, vURL,
                       vFailOverConnections[I].vWelcomeMessage,
                       vFailOverConnections[I].vAccessTag,
                       vFailOverConnections[I].Encoding,
                       vFailOverConnections[I].vCompression,
                       vFailOverConnections[I].hEncodeStrings,
                       vBinaryRequest,
                       Result, vErrorMessage) Then
         Begin
          If vFailOverReplaceDefaults Then
           Begin
            vTypeRequest    := vFailOverConnections[I].vTypeRequest;
            vWelcomeMessage := vFailOverConnections[I].WelcomeMessage;
            vHost           := vFailOverConnections[I].Host;
            vPort           := vFailOverConnections[I].Port;
            vDatacompress   := vFailOverConnections[I].vCompression;
            vEncodeStrings  := vFailOverConnections[I].hEncodeStrings;
            vRSCharset      := vFailOverConnections[I].Encoding;
            vAccessTag      := vFailOverConnections[I].AccessTag;
            vUrlPath        := vFailOverConnections[I].vRestURL;
            vRequestTimeout := vFailOverConnections[I].vTimeOut;
            vConnectTimeout := vFailOverConnections[I].vConnectTimeOut;
            vDataRoute      := vFailOverConnections[I].DataRoute;
            vServerContext  := vFailOverConnections[I].ServerContext;
           End;
          Break;
         End
        Else
         Begin
          If Assigned(vOnFailOverError) Then
           Begin
            vOnFailOverError(vFailOverConnections[I], vErrorMessage);
            vErrorMessage := '';
           End;
         End;
       End;
     End;
   End;
 Finally
  HttpRequest.Disconnect;
  If (vErrorMessage <> '') Then
   Begin
    Result := vErrorMessage;
    Raise Exception.Create(Result);
   End;
 End;
End;

Procedure TRESTDWConnectionServerCP.SetCripto(Value : TCripto);
Begin
 vCripto.Use := Value.Use;
 vCripto.Key := Value.Key;
End;

Function  TRESTDWConnectionServerCP.GetDisplayName             : String;
Begin
 Result := vListName;
End;

Function  TRESTDWConnectionServerCP.GetPoolerList : TStringList;
Var
 I                : Integer;
 vTempList        : TStringList;
 RESTClientPooler : TRESTClientPooler;
 vConnection      : TDWPoolerMethodClient;
Begin
 Result := Nil;
 RESTClientPooler := TRESTClientPooler.Create(Nil);
 Try
  vConnection                  := TDWPoolerMethodClient.Create(Nil);
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
 FreeAndNil(vTransparentProxy);
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
 vAuthOptionParams  := TRDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vPoolerPort        := 8082;
 vEncodeStrings     := True;
 vTransparentProxy  := TIdProxyConnectionInfo.Create;
 vTimeOut           := 10000;
 vActive            := True;
 vServerEventName   := '';
 vDataRoute         := '';
 vServerContext     := '';
 vCripto            := TCripto.Create;
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

Function TFailOverConnections.Add: TCollectionItem;
Begin
 Result := TRESTDWConnectionServerCP(Inherited Add);
End;

Destructor TFailOverConnections.Destroy;
Begin
 ClearList;
 Inherited;
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

Function TRESTClientPooler.SendEvent(EventData : String) : String;
Var
 Params : TDWParams;
Begin
 Try
  Params := Nil;
  Result := SendEvent(EventData, Params);
 Finally
 End;
End;

Procedure TRESTClientPooler.ReconfigureConnection(Var Connection        : TRESTClientPooler;
                                                  TypeRequest           : Ttyperequest;
                                                  WelcomeMessage,
                                                  Host                  : String;
                                                  Port                  : Integer;
                                                  Compression,
                                                  EncodeStrings         : Boolean;
                                                  Encoding              : TEncodeSelect;
                                                  AccessTag             : String;
                                                  AuthenticationOptions : TRDWClientAuthOptionParams);
Begin

End;

Procedure TRESTClientPooler.NewToken;
Var
 DWParams       : TDWParams;
 vErrorBoolean  : Boolean;
 vMessageError,
 vToken         : String;
Begin
 DWParams := TDWParams.Create;
 Try
  DWParams.Encoding := Encoding;
  If AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
   Begin
    Case AuthenticationOptions.AuthorizationOption Of
     rdwAOBearer : Begin
                    If (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                       (TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token = '') Then
                     Begin
                      If Assigned(OnBeforeGetToken) Then
                       OnBeforeGetToken(WelcomeMessage,
                                        AccessTag, DWParams);
                      vToken :=  RenewToken(DWParams, vErrorBoolean, vMessageError);
                      If Not vErrorBoolean Then
                       TRDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := vToken;
                     End;
                   End;
     rdwAOToken  : Begin
                    If (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                       (TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token = '') Then
                     Begin
                      If Assigned(OnBeforeGetToken) Then
                       OnBeforeGetToken(WelcomeMessage,
                                        AccessTag, DWParams);
                      vToken :=  RenewToken(DWParams, vErrorBoolean, vMessageError);
                      If Not vErrorBoolean Then
                       TRDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := vToken;
                     End;
                   End;
    End;
   End;
 Finally
  FreeAndNil(DWParams);
 End;
End;

Function  TRESTClientPooler.RenewToken(Var Params       : TDWParams;
                                       Var Error        : Boolean;
                                       Var MessageError : String) : String;
Var
 I                    : Integer;
 vTempSend            : String;
 vConnection          : TDWPoolerMethodClient;
 RESTClientPoolerExec : TRESTClientPooler;
 Procedure DestroyComponents;
 Begin
  If Assigned(RESTClientPoolerExec) Then
   FreeAndNil(RESTClientPoolerExec);
 End;
Begin
 //Atualização de Token na autenticação
 Result                       := '';
 RESTClientPoolerExec         := Nil;
 vConnection                  := TDWPoolerMethodClient.Create(Nil);
 vConnection.UserAgent        := vUserAgent;
 vConnection.TypeRequest      := vTypeRequest;
 vConnection.WelcomeMessage   := vWelcomeMessage;
 vConnection.Host             := vHost;
 vConnection.Port             := vPort;
 vConnection.BinaryRequest    := BinaryRequest;
 vConnection.Compression      := vDatacompress;
 vConnection.EncodeStrings    := hEncodeStrings;
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
                     TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                    End;
      rdwAOToken  : Begin
                     vTempSend := vConnection.GetToken(vUrlPath,     '',
                                                       Params,       Error,
                                                       MessageError, vRequestTimeOut, vConnectTimeOut,
                                                       Nil,          RESTClientPoolerExec);
                     vTempSend                                          := GettokenValue(vTempSend);
                     TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
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
              RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
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
                              TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut, vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          RESTClientPoolerExec);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
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
              RESTClientPoolerExec := TRESTClientPooler.Create(Nil);
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
                              TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
                             End;
               rdwAOToken  : Begin
                              vTempSend := vConnection.GetToken(vFailOverConnections[I].vRestURL, '',
                                                                Params,       Error,
                                                                MessageError, vFailOverConnections[I].vTimeOut,  vFailOverConnections[I].vConnectTimeOut,
                                                                Nil,          RESTClientPoolerExec);
                              vTempSend                                          := GettokenValue(vTempSend);
                              TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).FromToken(vTempSend);
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

Procedure TRESTClientPooler.SetAccessTag(Value : String);
Begin
 vAccessTag := Value;
End;

Procedure TRESTClientPooler.SetAllowCookies(Value: Boolean);
Begin
 HttpRequest.AllowCookies    := Value;
End;

Procedure TRESTClientPooler.SetHandleRedirects(Value: Boolean);
Begin
 vHandleRedirects := Value;
End;

Procedure TRESTClientPooler.SetOnStatus(Value : TOnStatus);
Begin
 {$IFDEF FPC}
  vOnStatus            := Value;
  HttpRequest.OnStatus := vOnStatus;
 {$ELSE}
  vOnStatus            := Value;
  HttpRequest.OnStatus := vOnStatus;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetOnWork(Value : TOnWork);
Begin
 {$IFDEF FPC}
  vOnWork            := Value;
  HttpRequest.OnWork := vOnWork;
 {$ELSE}
  vOnWork            := Value;
  HttpRequest.OnWork := vOnWork;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetOnWorkBegin(Value : TOnWorkBegin);
Begin
 {$IFDEF FPC}
  vOnWorkBegin            := Value;
  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ELSE}
  vOnWorkBegin            := Value;
  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
 {$IFDEF FPC}
  vOnWorkEnd            := Value;
  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ELSE}
  vOnWorkEnd            := Value;
  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetParams(Var aHttpRequest    : TIdHTTP;
                                      Authentication      : Boolean;
                                      TransparentProxy    : TIdProxyConnectionInfo;
                                      RequestTimeout      : Integer;
                                      ConnectTimeout      : Integer;
                                      AuthorizationParams : TRDWClientAuthOptionParams);
Begin
 aHttpRequest.Request.CustomHeaders.Clear;
 If AuthorizationParams.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken] Then
  Begin
   HttpRequest.Request.BasicAuthentication := AuthorizationParams.AuthorizationOption = rdwAOBasic;
   Case AuthorizationParams.AuthorizationOption of
    rdwAOBasic  : Begin
                   If aHttpRequest.Request.Authentication = Nil Then
                    aHttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
                   If Assigned(aHttpRequest.Request.Authentication) Then
                    Begin
                     aHttpRequest.Request.Authentication.Password := TRDWAuthOptionBasic(AuthorizationParams.OptionParams).Password;
                     aHttpRequest.Request.Authentication.Username := TRDWAuthOptionBasic(AuthorizationParams.OptionParams).UserName;
                    End;
                  End;
    rdwAOBearer : Begin
                   If Assigned(aHttpRequest.Request.Authentication) Then
                    Begin
                     If Assigned(aHttpRequest.Request.Authentication) Then
                      Begin
                       aHttpRequest.Request.Authentication.Free;
                       aHttpRequest.Request.Authentication := Nil;
                      End;
                    End;
                   If TRDWAuthOptionBearerClient(AuthorizationParams.OptionParams).TokenRequestType = rdwtHeader Then
                    aHttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRDWAuthOptionBearerClient(AuthorizationParams.OptionParams).Token);
                  End;
    rdwAOToken  : Begin
                   If Assigned(aHttpRequest.Request.Authentication) Then
                    Begin
                     aHttpRequest.Request.Authentication.Free;
                     aHttpRequest.Request.Authentication := Nil;
                    End;
                   If TRDWAuthOptionTokenClient(AuthorizationParams.OptionParams).TokenRequestType = rdwtHeader Then
                    aHttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRDWAuthOptionTokenClient(AuthorizationParams.OptionParams).Token]));
                  End;
   End;
  End;
 aHttpRequest.ProxyParams.BasicAuthentication := TransparentProxy.BasicAuthentication;
 aHttpRequest.ProxyParams.ProxyUsername       := TransparentProxy.ProxyUsername;
 aHttpRequest.ProxyParams.ProxyServer         := TransparentProxy.ProxyServer;
 aHttpRequest.ProxyParams.ProxyPassword       := TransparentProxy.ProxyPassword;
 aHttpRequest.ProxyParams.ProxyPort           := TransparentProxy.ProxyPort;
 aHttpRequest.ReadTimeout                     := RequestTimeout;
 aHttpRequest.ConnectTimeout                  := ConnectTimeout;
 aHttpRequest.Request.ContentType             := HttpRequest.Request.ContentType;
 aHttpRequest.AllowCookies                    := HttpRequest.AllowCookies;
 aHttpRequest.HandleRedirects                 := HttpRequest.HandleRedirects;
 aHttpRequest.HTTPOptions                     := HttpRequest.HTTPOptions;
 aHttpRequest.Request.Charset                 := HttpRequest.Request.Charset;
 aHttpRequest.Request.UserAgent               := HttpRequest.Request.UserAgent;
End;

Procedure TRESTClientPooler.SetUrlPath(Value : String);
Begin
 vUrlPath := Value;
 If Length(vUrlPath) > 0 Then
  If vUrlPath[Length(vUrlPath)] <> '/' Then
   vUrlPath := vUrlPath + '/';
End;

Constructor TProxyOptions.Create;
Begin
 Inherited;
 vServer   := '';
 vLogin    := vServer;
 vPassword := vLogin;
 vPort     := 8888;
End;

Procedure TProxyOptions.Assign(Source: TPersistent);
Var
 Src : TProxyOptions;
Begin
 If Source is TProxyOptions Then
  Begin
   Src := TProxyOptions(Source);
   vServer := Src.Server;
   vLogin  := Src.Login;
   vPassword := Src.Password;
   vPort     := Src.Port;
  End
 Else
  Inherited;
End;

Procedure TRESTServicePooler.GetServerEventsList(ServerMethodsClass   : TComponent;
                                                 Var ServerEventsList : String;
                                                 AccessTag            : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If Trim(TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
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

Procedure TRESTServicePooler.GetTableNames(ServerMethodsClass   : TComponent;
                                           Var Pooler           : String;
                                           Var DWParams         : TDWParams;
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

Procedure TRESTServicePooler.GetKeyFieldNames(ServerMethodsClass      : TComponent;
                                              Var Pooler              : String;
                                              Var DWParams            : TDWParams;
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

Procedure TRESTServicePooler.GetFieldNames(ServerMethodsClass   : TComponent;
                                           Var Pooler           : String;
                                           Var DWParams         : TDWParams;
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

Procedure TRESTServicePooler.GetPoolerList(ServerMethodsClass : TComponent;
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

Procedure TRESTServicePooler.EchoPooler(ServerMethodsClass : TComponent;
                                        AContext           : TIdContext;
                                        Var Pooler,
                                            MyIP           : String;
                                        AccessTag          : String;
                                        Var InvalidTag     : Boolean);
Var
 I : Integer;
Begin
 InvalidTag := False;
 MyIP       := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If (ServerMethodsClass.Components[i] is TRESTDWPoolerDB) Then
      Begin
       If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]) Then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             InvalidTag := True;
             Exit;
            End;
          End;
         If AContext <> Nil Then
          MyIP := AContext.Connection.Socket.Binding.PeerIP;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.ExecuteCommandPureJSON(ServerMethodsClass   : TComponent;
                                                    Var Pooler           : String;
                                                    Var DWParams         : TDWParams;
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

Procedure TRESTServicePooler.ExecuteCommandPureJSONTB(ServerMethodsClass   : TComponent;
                                                      Var Pooler           : String;
                                                      Var DWParams         : TDWParams;
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

Procedure TRESTServicePooler.IdHTTPServerQuerySSLPort(APort       : Word;
                                                      var VUseSSL : Boolean);
Begin
 VUseSSL := (APort = Self.ServicePort);
End;

Procedure TRESTServicePooler.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                                 Var Pooler         : String;
                                                 Var DWParams       : TDWParams;
                                                 ConnectionDefs     : TConnectionDefs;
                                                 hEncodeStrings     : Boolean;
                                                 AccessTag          : String);
Var
 I,
 vTempJSON     : Integer;
 vError        : Boolean;
 vMessageError : String;
 DWParamsD     : TDWParams;
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
             DWParamsD := TDWParams.Create;
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

Function   TRESTDWDataRouteList.RouteExists(Value : String) : Boolean;
Var
 I : Integer;
Begin
 Result := False;
 For I := 0 To Count -1 Do
  Begin
   Result := Lowercase(Items[I].DataRoute) = Lowercase(Value);
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

Function TRESTDWDataRouteList.GetServerMethodClass(DataRoute             : String;
                                                   Var ServerMethodClass : TComponentClass) : Boolean;
Var
 I : Integer;
Begin
 Result            := False;
 ServerMethodClass := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   Result := Lowercase(DataRoute) = Lowercase(TRESTDWDataRoute(TList(Self).Items[I]^).DataRoute);
   If (Result) Then
    Begin
     ServerMethodClass := TRESTDWDataRoute(TList(Self).Items[I]^).ServerMethodClass;
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

procedure TRESTServicePooler.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
 If (Operation = opRemove) then
  Begin
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     {$IFDEF WINDOWS}
      If (AComponent = vDWISAPIRunner) then
       vDWISAPIRunner := Nil;
      If (AComponent = vDWCGIRunner) then
       vDWCGIRunner := Nil;
     {$ENDIF}
    {$IFEND}
   {$ENDIF}
  End;
 Inherited Notification(AComponent, Operation);
end;

Procedure TRESTServicePooler.ProcessMassiveSQLCache(ServerMethodsClass      : TComponent;
                                                    Var Pooler              : String;
                                                    Var DWParams            : TDWParams;
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

Procedure TRESTServicePooler.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                       Var Pooler         : String;
                                                       Var DWParams       : TDWParams;
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

Procedure TRESTServicePooler.ApplyUpdates_MassiveCacheTB(ServerMethodsClass : TComponent;
                                                         Var Pooler         : String;
                                                         Var DWParams       : TDWParams;
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

Procedure TRESTServicePooler.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TDWParams;
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
 DWParamsD     : TDWParams;
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
             DWParamsD := TDWParams.Create;
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

Procedure TRESTServicePooler.ApplyUpdatesJSONTB(ServerMethodsClass : TComponent;
                                                Var Pooler         : String;
                                                Var DWParams       : TDWParams;
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
 DWParamsD     : TDWParams;
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
             DWParamsD := TDWParams.Create;
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

Procedure TRESTServicePooler.ExecuteCommandJSON(ServerMethodsClass   : TComponent;
                                                Var Pooler           : String;
                                                Var DWParams         : TDWParams;
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
 DWParamsD     : TDWParams;
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
              DWParamsD := TDWParams.Create;
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

Procedure TRESTServicePooler.ExecuteCommandJSONTB(ServerMethodsClass   : TComponent;
                                                  Var Pooler           : String;
                                                  Var DWParams         : TDWParams;
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
 DWParamsD     : TDWParams;
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
              DWParamsD := TDWParams.Create;
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

Procedure TRESTServicePooler.SetServerContext(Value : String);
Begin
 vServerContext := LowerCase(Value);
End;

Procedure TRESTServicePooler.SetCORSCustomHeader (Value : TStringList);
Var
 I : Integer;
Begin
 vCORSCustomHeaders.Clear;
 For I := 0 To Value.Count -1 do
  vCORSCustomHeaders.Add(Value[I]);
End;

Procedure TRESTServicePooler.SetDefaultPage (Value : TStringList);
Var
 I : Integer;
Begin
 vDefaultPage.Clear;
 For I := 0 To Value.Count -1 do
  vDefaultPage.Add(Value[I]);
End;

Function TRESTServicePooler.ReturnContext(ServerMethodsClass      : TComponent;
                                          Pooler,
                                          urlContext              : String;
                                          Var vResult,
                                          ContentType             : String;
                                          Var ServerContextStream : TMemoryStream;
                                          Var Error               : Boolean;
                                          Var   DWParams          : TDWParams;
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
 vDWRoutes: TDWRoutes;
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
   //uhmano   Pooler     := '';
  End;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerContext Then
      Begin
       If ((LowerCase(urlContext) = LowerCase(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext))) Or
          ((Trim(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext) = '')  {//uhmano And (Pooler = '')}  And
           (TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[urlContext] <> Nil))   Then
        Begin
         vRootContext := TDWServerContext(ServerMethodsClass.Components[i]).RootContext;
         If ((Pooler = '')    And (vRootContext <> '')) Then
          Pooler := vRootContext;
         vTagService := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler] <> Nil;
         If Not vTagService Then
          Begin
           Error   := True;
           vResult := cInvalidRequest;
          End;
        End;
       If vTagService Then
        Begin
         Result   := False;
         If (RequestTypeToRoute(RequestType) In TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Or
            (crAll in TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Then
          Begin
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer) Then
            TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer(ServerMethodsClass.Components[i]);
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest) Then
            TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If Not vRejected Then
            Begin
             Result  := True;
             vResult := '';
             TDWServerContext(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
             TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].CompareParams(DWParams);
             Try
              ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContentType;
              If mark <> '' Then
               Begin
                vResult    := '';
                Result     := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules);
                If Result Then
                 Begin
                  Result   := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark] <> Nil;
                  If Result Then
                   Begin
                    Result := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute);
                    If Result Then
                     Begin
                      ContentType := 'application/json';
                      TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute(DWParams, ContentType, vResult);
//                      vResult := utf8Encode(vResult);
                     End;
                   End;
                 End;
               End
              Else If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules) Then
               Begin
                vBaseHeader := '';
                ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.ContentType;
                vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.BuildContext(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader,
                                                                                                                                          TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].IgnoreBaseHeader);
               End
              Else
               Begin
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall) Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler]);
                vDefaultPageB := Not Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest);
                If Not vDefaultPageB Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest(DWParams, ContentType, vResult, RequestType);
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream) Then
                 Begin
                  vDefaultPageB := False;
                  ServerContextStream := TMemoryStream.Create;
                  Try
                   TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream(DWParams, ContentType, ServerContextStream, RequestType, ErrorCode);
                  Finally
                   If ServerContextStream.Size = 0 Then
                    FreeAndNil(ServerContextStream);
                  End;
                 End;
                If vDefaultPageB Then
                 Begin
                  vBaseHeader := '';
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader) Then
                   vBaseHeader := TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader.Text;
                  vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].DefaultHtml.Text;
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer) Then
                   TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer(vBaseHeader, ContentType, vResult, RequestType);
                 End;
               End;

               //uhmano -- inicio  ServerContext
               if DWParams.ItemsString['ContentType'] <> nil then
                   ContentType := DWParams.ItemsString['ContentType'].asString;

               if DWParams.ItemsString['StatusCode'] <> nil then
                   ErrorCode := DWParams.ItemsString['StatusCode'].asInteger;
               //uhmano -- final

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
           vDWRoutes := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes;
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

Function TRESTServicePooler.ReturnEvent(ServerMethodsClass : TComponent;
                                        Pooler,
                                        urlContext          : String;
                                        Var vResult         : String;
                                        Var DWParams        : TDWParams;
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
 vDWRoutes: TDWRoutes;
Begin
 Result        := False;
 vRejected     := False;
 vTagService   := Result;
 vErrorMessage := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) Or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.classname + '.' +
                                             ServerMethodsClass.Components[i].Name)) Then
        vTagService := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
       If vTagService Then
        Begin
         Result   := True;
         JsonMode := jmPureJSON;
         If Trim(TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
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
         If (RequestTypeToRoute(RequestType) In TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Or
            (crAll in TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Then
          Begin
           vResult := '';
           TDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
           If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest) Then
            TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage, ErrorCode, RequestHeader);
           If Not vRejected Then
            Begin
             TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].CompareParams(DWParams);
             Try
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler]);
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType(DWParams, vResult, RequestType, ErrorCode, RequestHeader)
              Else If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
              JsonMode := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].JsonMode;

              //uhmano -- inicio  ServerEvents
              if DWParams.ItemsString['ContentType'] <> nil then
                  ContentType := DWParams.ItemsString['ContentType'].asString;

              if DWParams.ItemsString['StatusCode'] <> nil then
                  ErrorCode := DWParams.ItemsString['StatusCode'].asInteger;
              //uhmano -- final

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
           vDWRoutes := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes;
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

Procedure TRESTServicePooler.GetEvents(ServerMethodsClass : TComponent;
                                       Pooler,
                                       urlContext         : String;
                                       Var DWParams       : TDWParams);
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
     If (ServerMethodsClass.Components[i] is TDWServerEvents) Then
      Begin
       iContSE := iContSE + 1;
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) Or
          (LowerCase(urlContext) = LowerCase(Format('%s.%s', [ServerMethodsClass.Classname, ServerMethodsClass.Components[i].Name])))  Then
        Begin
         If vTempJSON = '' Then
          vTempJSON := Format('%s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
         Else
          vTempJSON := vTempJSON + Format(', %s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON]);
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

Procedure TRESTServicePooler.OpenDatasets(ServerMethodsClass   : TComponent;
                                          Var Pooler           : String;
                                          Var DWParams         : TDWParams;
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

Function TRESTServicePooler.ServiceMethods(BaseObject              : TComponent;
                                           AContext                : TIdContext;
                                           Var UriOptions          : TRESTDWUriOptions;
                                           Var DWParams            : TDWParams;
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

Procedure TRESTServicePooler.aCommandGet(AContext      : TIdContext;
                                         ARequestInfo  : TIdHTTPRequestInfo;
                                         AResponseInfo : TIdHTTPResponseInfo);
Var
 aParamsCount,
 I, vErrorCode      : Integer;
 JsonMode           : TJsonMode;
 DWParamsD,
 DWParams           : TDWParams;
 vOldMethod,
 vBasePath,
 vObjectName,
 vAccessTag,
 vWelcomeMessage,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 vUrlToken,
 baseEventUnit,
 serverEventsName,
 Cmd, vmark,
 aurlContext,
 tmp, JSONStr,
 ReturnObject,
 vTempText,
 sFile,
 sContentType,
 vContentType,
 LocalDoc,
 vIPVersion,
 vErrorMessage,
 aToken,
 vToken,
 vDataBuff,
 vCORSOption,
 vAuthenticationString,
 sCharSet            : String;
 vAuthTokenParam     : TRDWAuthTokenParam;
 vdwConnectionDefs   : TConnectionDefs;
 vTempServerMethods  : TObject;
 newdecoder,
 Decoder             : TIdMessageDecoder;
 vRDWAuthOptionParam : TRDWAuthOptionParam;
 JSONParam           : TJSONParam;
 JSONValue           : TJSONValue;
 vAcceptAuth,
 vMetadata,
 vBinaryCompatibleMode,
 vBinaryEvent,
 dwassyncexec,
 vFileExists,
 vSpecialServer,
 vServerContextCall,
 vTagReply,
 WelcomeAccept,
 encodestrings,
 compresseddata,
 vdwCriptKey,
 vGettoken,
 vTokenValidate,
 vNeedAuthorization,
 vCompareContext,
 msgEnd              : Boolean;
 vServerBaseMethod   : TComponentClass;
 vServerMethod       : TComponentClass;
 vUriOptions         : TRESTDWUriOptions;
 ServerContextStream : TMemoryStream;
 mb,
 mb2,
 ms                  : TStringStream;
 RequestType         : TRequestType;
 vRequestHeader,
 vDecoderHeaderList  : TStringList;
 vTempContext        : TDWContext;
 vTempEvent          : TDWEvent;
 Function ExcludeTag(Value : String) : String;
 Begin
  Result := Value;
  If (UpperCase(Copy (Value, InitStrPos, 3)) = 'GET')    or
     (UpperCase(Copy (Value, InitStrPos, 4)) = 'POST')   or
     (UpperCase(Copy (Value, InitStrPos, 3)) = 'PUT')    or
     (UpperCase(Copy (Value, InitStrPos, 6)) = 'DELETE') or
     (UpperCase(Copy (Value, InitStrPos, 5)) = 'PATCH')  Then
   Begin
    While (Result <> '') And (Result[InitStrPos] <> '/') Do
     Delete(Result, 1, 1);
   End;
  If Result <> '' Then
   If Result[InitStrPos] = '/' Then
    Delete(Result, 1, 1);
  Result := Trim(Result);
 End;
 Function GetFileOSDir(Value : String) : String;
 Begin
  {$IF Defined(ANDROID) Or Defined(IOS)}
  Result := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, Value);
  {$ELSE}
  Result := vBasePath + Value;
  {$IFEND}
  {$IFDEF MSWINDOWS}
   Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  {$ENDIF}
 End;
 Function GetLastMethod(Value : String) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> '' Then
   Begin
    If Value[Length(Value) - FinalStrPos] <> '/' Then
     Begin
      For I := (Length(Value) - FinalStrPos) Downto InitStrPos Do
       Begin
        If Value[I] <> '/' Then
         Result := Value[I] + Result
        Else
         Break;
       End;
     End;
   End;
 End;
 procedure ReadRawHeaders;
 var
  I: Integer;
  JSONParam : TJSONParam;
 begin
  If ARequestInfo.RawHeaders = Nil Then
   Exit;
  Try
   If ARequestInfo.RawHeaders.Count > 0 Then
    Begin
     vRequestHeader.Add(ARequestInfo.RawHeaders.Text);
     For I := 0 To ARequestInfo.RawHeaders.Count -1 Do
      Begin
       tmp := ARequestInfo.RawHeaders.Names[I];
       If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
        vWelcomeMessage := DecodeStrings(ARequestInfo.RawHeaders.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
        vAccessTag := DecodeStrings(ARequestInfo.RawHeaders.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('datacompression', lowercase(tmp)) > 0 Then
        compresseddata := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
        encodestrings  := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else If pos('dwusecript', lowercase(tmp)) > 0 Then
        vdwCriptKey    := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else If (pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
        dwassyncexec   := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else if pos('binaryrequest', lowercase(tmp)) > 0 Then
        vBinaryEvent   := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
        Begin
         vdwConnectionDefs   := TConnectionDefs.Create;
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := vEncoding;
          JSONValue.Encoded  := True;
          JSONValue.LoadFromJSON(ARequestInfo.RawHeaders.Values[tmp]);
          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
         Finally
          FreeAndNil(JSONValue);
         End;
        End
       Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
        Begin
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := vEncoding;
          JSONValue.Encoded  := True;
          {$IFDEF FPC}
          JSONValue.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONValue.LoadFromJSON(ARequestInfo.RawHeaders.Values[tmp]);
          If ((vUriOptions.BaseServer = '')  And
              (vUriOptions.DataUrl    = '')) And
             (vUriOptions.ServerEvent <> '') Then
           vUriOptions.BaseServer := vUriOptions.ServerEvent
          Else If ((vUriOptions.BaseServer <> '') And
                   (vUriOptions.DataUrl    = '')) And
                  (vUriOptions.ServerEvent <> '') And
                   (vServerContext = '')          Then
           Begin
            vUriOptions.DataUrl    := vUriOptions.BaseServer;
            vUriOptions.BaseServer := vUriOptions.ServerEvent;
           End;
          vUriOptions.ServerEvent := JSONValue.Value;
          If Pos('.', vUriOptions.ServerEvent) > 0 Then
           Begin
            baseEventUnit := Copy(vUriOptions.ServerEvent, InitStrPos, Pos('.', vUriOptions.ServerEvent) - 1 - FinalStrPos);
            vUriOptions.ServerEvent    := Copy(vUriOptions.ServerEvent, Pos('.', vUriOptions.ServerEvent) + 1, Length(vUriOptions.ServerEvent));
           End;
         Finally
          FreeAndNil(JSONValue);
         End;
        End
       Else
        Begin
         aParamsCount := cParamsCount;
         If ServerContext <> '' Then
          Inc(aParamsCount);
         If vDataRouteList.Count > 0 Then
          Inc(aParamsCount);
         If Not Assigned(DWParams) Then
          TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                            ARequestInfo.QueryParams,
                                            vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
         try
          JSONParam                 := TJSONParam.Create(DWParams.Encoding);
          JSONParam.ObjectDirection := odIN;
          JSONParam.ParamName       := lowercase(tmp);
          {$IFDEF FPC}
          JSONParam.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          tmp                       := ARequestInfo.RawHeaders.Values[tmp];
          If (Pos(LowerCase('{"ObjectType":"toParam", "Direction":"'), LowerCase(tmp)) > 0) Then
           JSONParam.FromJSON(tmp)
          Else
           JSONParam.AsString  := tmp;
          DWParams.Add(JSONParam);
         Finally
         End;
        End;
      End;
    End;
  Finally
   If ARequestInfo.RawHeaders <> Nil Then
    DWParams.RequestHeaders.Input.Assign(ARequestInfo.RawHeaders);
   tmp := '';
  End;

          //uhmano
          // remoteIP
          JSONParam                 := TJSONParam.Create(DWParams.Encoding);
          JSONParam.ObjectDirection := odIN;
          JSONParam.ParamName       := 'RemoteIP';
          {$IFDEF FPC}
          JSONParam.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONParam.AsString        := ARequestInfo.RemoteIP;
          DWParams.Add(JSONParam);

          // URI
          JSONParam                 := TJSONParam.Create(DWParams.Encoding);
          JSONParam.ObjectDirection := odIN;
          JSONParam.ParamName       := 'URI';
          {$IFDEF FPC}
          JSONParam.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONParam.AsString        := ARequestInfo.URI;
          DWParams.Add(JSONParam);

          // Document
          JSONParam                 := TJSONParam.Create(DWParams.Encoding);
          JSONParam.ObjectDirection := odIN;
          JSONParam.ParamName       := 'Document';
          {$IFDEF FPC}
          JSONParam.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONParam.AsString        := ARequestInfo.Document;
          DWParams.Add(JSONParam);

          // AuthUsername
          JSONParam                 := TJSONParam.Create(DWParams.Encoding);
          JSONParam.ObjectDirection := odIN;
          JSONParam.ParamName       := 'AuthUsername';
          {$IFDEF FPC}
          JSONParam.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONParam.AsString        := ARequestInfo.AuthUsername;
          DWParams.Add(JSONParam);

    		  //uhmano - final


 end;
 Procedure MyDecodeAndSetParams(ARequestInfo: TIdHTTPRequestInfo);
 Var
  i, j      : Integer;
  value, s  : String;
  {$IFNDEF FPC}
    {$IF (DEFINED(OLDINDY))}
     LEncoding : TIdTextEncoding
    {$ELSE}
     LEncoding : IIdTextEncoding
    {$IFEND}
  {$ELSE}
   LEncoding : IIdTextEncoding
  {$ENDIF};
 Begin
  If ARequestInfo.CharSet <> '' Then
   LEncoding := CharsetToEncoding(ARequestInfo.CharSet)
  Else
  {$IFNDEF FPC}
    {$IF (DEFINED(OLDINDY))}
     LEncoding := enDefault;
    {$ELSE}
     LEncoding := IndyTextEncoding_UTF8;
    {$IFEND}
  {$ELSE}
   LEncoding := IndyTextEncoding_UTF8;
  {$ENDIF};
  value := ARequestInfo.RawHeaders.Text;
  Try
   i := 1;
   While i <= Length(value) Do
    Begin
     j := i;
     While (j <= Length(value)) And (value[j] <> '&') Do
      Inc(j);
     s := StringReplace(Copy(value, i, j-i), '+', ' ', [rfReplaceAll]);
     ARequestInfo.Params.Add(TIdURI.URLDecode(s{$IFNDEF FPC}{$IF Not(DEFINED(OLDINDY))}, LEncoding{$IFEND}{$ELSE}, LEncoding{$ENDIF}));
     i := j + 1;
    End;
  Finally
  End;
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(vUriOptions) Then
   FreeAndNil(vUriOptions);
  If Assigned(vdwConnectionDefs) Then
   FreeAndNil(vdwConnectionDefs);
  If Assigned(vRequestHeader)    Then
   FreeAndNil(vRequestHeader);
  If Assigned(vAuthTokenParam)   Then
   FreeAndNil(vAuthTokenParam);
  If Assigned(vRDWAuthOptionParam) Then
   FreeAndNil(vRDWAuthOptionParam);
  If Assigned(vAuthTokenParam) Then
   FreeAndNil(vAuthTokenParam);
  If Assigned(vServerMethod) Then
   If Assigned(vTempServerMethods) Then
    Begin
     Try
      {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
      {$ELSE}
      FreeAndNil(vTempServerMethods); //.free;
      {$ENDIF}
     Except
     End;
    End;
 End;
 Procedure WriteError;
 Begin
  AResponseInfo.ResponseNo   := vErrorCode;
  {$IFNDEF FPC}
   mb                                  := TStringStream.Create(vErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
   mb.Position                          := 0;
   AResponseInfo.FreeContentStream      := True;
   AResponseInfo.ContentStream          := mb;
   AResponseInfo.ContentStream.Position := 0;
   AResponseInfo.ContentLength          := mb.Size;
   AResponseInfo.WriteContent;
  {$ELSE}
   mb                                  := TStringStream.Create(vErrorMessage);
   mb.Position                          := 0;
   AResponseInfo.FreeContentStream      := True;
   AResponseInfo.ContentStream          := mb;
   AResponseInfo.ContentStream.Position := 0;
   AResponseInfo.ContentLength          := -1;//mb.Size;
   AResponseInfo.WriteContent;
  {$ENDIF}
 End;
 Function ReturnEventValidation(ServerMethodsClass : TComponent;
                                Pooler,
                                urlContext         : String) : TDWEvent;
 Var
  vTagService : Boolean;
  I           : Integer;
 Begin
  Result        := Nil;
  vTagService   := False;
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TDWServerEvents Then
       Begin
        If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) Or
           (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name))  Or
           (LowerCase(urlContext) = LowerCase(ServerMethodsClass.classname + '.' +
                                              ServerMethodsClass.Components[i].Name))  Then
         vTagService := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
        If vTagService Then
         Begin
          Result   := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler];
          Break;
         End;
       End;
     End;
   End;
 End;
 Function ReturnContextValidation(ServerMethodsClass : TComponent;
                                  Var UriOptions     : TRESTDWUriOptions) : TDWContext;
 Var
  I            : Integer;
  vTagService  : Boolean;
  aEventName,
  aServerEvent,
  vRootContext : String;
 Begin
  Result        := Nil;
  vRootContext  := '';
  aEventName    := UriOptions.EventName;
  aServerEvent  := UriOptions.ServerEvent;
  If (aEventName <> '') And (aServerEvent = '') Then
   Begin
    aServerEvent := aEventName;
    aEventName   := '';
   End;
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TDWServerContext Then
       Begin
        If ((LowerCase(aServerEvent) = LowerCase(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext))) Or
           ((Trim(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext) = '') And (aEventName = '')      And
            (TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aServerEvent] <> Nil))   Then
         Begin
          vRootContext := TDWServerContext(ServerMethodsClass.Components[i]).RootContext;
          If ((aEventName = '')    And (vRootContext <> '')) Then
           aEventName := vRootContext;
          vTagService := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aEventName] <> Nil;
          If vTagService Then
           Begin
            Result := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[aEventName];
            Break;
           End;
         End;
       End;
     End;
   End;
 End;
 Function ClearRequestType(Value : String) : String;
 Begin
  Result := Value;
  If (Pos('GET ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'GET ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('POST ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'POST ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PUT ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PUT ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('DELETE ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'DELETE ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PATCH ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PATCH ', '', [rfReplaceAll, rfIgnoreCase]);
 End;
 Function CompareBaseURL(Var Value : String) : Boolean;
 Var
  vTempValue : String;
 Begin
  Result := False;
  If aDefaultUrl <> '' Then
   Begin
    If Value = '/' Then
     Value := aDefaultUrl
    Else
     Begin
      vTempValue := Copy(Value, InitStrPos, Length(aDefaultUrl));
      If Lowercase(vTempValue) <> Lowercase(aDefaultUrl) Then
       Begin
        Value  := aDefaultUrl + Value;
        Result := True;
       End;
     End;
   End;
 End;
Begin
 vRDWAuthOptionParam   := Nil;
 mb2                   := Nil;
 mb                    := Nil;
 ms                    := Nil;
 vAuthTokenParam       := Nil;
 tmp                   := '';
 vIPVersion            := 'ipv4';
 JsonMode              := jmDataware;
 baseEventUnit         := '';
 vAccessTag            := '';
 vErrorMessage         := '';
 vServerMethod         := Nil;
 aParamsCount          := cParamsCount;
 vUriOptions           := TRESTDWUriOptions.Create;
 {$IF Defined(ANDROID) Or Defined(IOS)}
 vBasePath             := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, '/');
 {$ELSE}
 vBasePath             := ExtractFilePath(ParamStr(0));
 {$IFEND}
 vContentType          := vContentType;
 vdwConnectionDefs     := Nil;
 vTempServerMethods    := Nil;
 DWParams              := Nil;
 ServerContextStream   := Nil;
 mb                    := Nil;
 compresseddata        := False;
 encodestrings         := False;
 vTagReply             := False;
 vServerContextCall    := False;
 dwassyncexec          := False;
 vBinaryEvent          := False;
 vBinaryCompatibleMode := False;
 vMetadata             := False;
 vdwCriptKey           := False;
 vGettoken             := False;
 vTokenValidate        := False;
 vErrorCode            := 200;
 vToken                := '';
 vDataBuff             := '';
 vRequestHeader        := TStringList.Create;
 vCompareContext       := False;
 Cmd                   := RemoveBackslashCommands(Trim(ARequestInfo.RawHTTPCommand));
// MyDecodeAndSetParams(ARequestInfo);

 {Try tranferido para este ponto - remoção memory Leaks - Eloy}

 Try
  If vCORS Then
   Begin
    If vCORSCustomHeaders.Count > 0 Then
     Begin
      For I := 0 To vCORSCustomHeaders.Count -1 Do
       AResponseInfo.CustomHeaders.AddValue(vCORSCustomHeaders.Names[I], vCORSCustomHeaders.ValueFromIndex[I]);
     End
    Else
     AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin','*');
   End;
  sCharSet := '';
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET')    Then
   Begin
    If     (Pos('.HTML', UpperCase(Cmd)) > 0) Then
     Begin
      sContentType:='text/html';
      sCharSet := 'utf-8';
     End
    Else If (Pos('.PNG', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/png'
    Else If (Pos('.ICO', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/ico'
    Else If (Pos('.GIF', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/gif'
    Else If (Pos('.JPG', UpperCase(Cmd)) > 0) Then
     sContentType := 'image/jpg'
    Else If (Pos('.JS',  UpperCase(Cmd)) > 0) Then
     sContentType := 'application/javascript'
    Else If (Pos('.PDF', UpperCase(Cmd)) > 0) Then
     sContentType := 'application/pdf'
    Else If (Pos('.CSS', UpperCase(Cmd)) > 0) Then
     sContentType:='text/css';
    {$IFNDEF FPC}
     {$if CompilerVersion > 21}
      If DefaultBaseContext <> '' Then
       Begin
        sFile := RemoveBackslashCommands(ARequestInfo.URI);
        vTempText := IncludeTrailingPathDelimiter(DefaultBaseContext);
        {$IFDEF MSWINDOWS}
         vTempText := StringReplace(vTempText, '\', '/', [rfReplaceAll]);
         vTempText := StringReplace(vTempText, '//', '/', [rfReplaceAll]);
        {$ENDIF}
        If Pos(vTempText, sFile) >= InitStrPos Then
         Delete(sFile, Pos(vTempText, sFile) - FinalStrPos, Length(vTempText));
        sFile := FRootPath + vTempText + sFile;
       End
      Else
       sFile := FRootPath + RemoveBackslashCommands(ARequestInfo.URI);
     {$ELSE}
      If DefaultBaseContext <> '' Then
       Begin
        sFile := RemoveBackslashCommands(ARequestInfo.Command);
        vTempText := IncludeTrailingPathDelimiter(DefaultBaseContext);
        {$IFDEF MSWINDOWS}
         vTempText := StringReplace(vTempText, '\', '/', [rfReplaceAll]);
         vTempText := StringReplace(vTempText, '//', '/', [rfReplaceAll]);
        {$ENDIF}
        If Pos(vTempText, sFile) >= InitStrPos Then
         Delete(sFile, Pos(vTempText, sFile) - FinalStrPos, Length(vTempText));
        sFile := FRootPath + vTempText + sFile;
       End
      Else
       sFile := FRootPath + RemoveBackslashCommands(ARequestInfo.Command);
     {$IFEND}
    {$ELSE}
     sFile := FRootPath  + RemoveBackslashCommands(ARequestInfo.URI);
    {$ENDIF}
    {$IFDEF MSWINDOWS}
     sFile := StringReplace(sFile, '/', '\', [rfReplaceAll]);
     sFile := StringReplace(sFile, '\\', '\', [rfReplaceAll]);
    {$ENDIF}
    If (vPathTraversalRaiseError) And
       (DWFileExists(sFile, FRootPath)) And
       (SystemProtectFiles(sFile)) Then
     Begin
      AResponseInfo.ResponseNo               := 404;
      {$IFNDEF FPC}
       If compresseddata Then
        mb                                  := TStringStream(ZCompressStreamNew(cEventNotFound))
       Else
        mb                                  := TStringStream.Create(cEventNotFound{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
       mb.Position                          := 0;
       AResponseInfo.FreeContentStream      := True;
       AResponseInfo.ContentStream          := mb;
       AResponseInfo.ContentStream.Position := 0;
       AResponseInfo.ContentLength          := mb.Size;
       AResponseInfo.WriteContent;
      {$ELSE}
       If compresseddata Then
        mb                                  := TStringStream(ZCompressStreamNew(cEventNotFound)) //TStringStream.Create(Utf8Encode(vReplyStringResult))
       Else
        mb                                  := TStringStream.Create(cEventNotFound);
       mb.Position                          := 0;
       AResponseInfo.FreeContentStream      := True;
       AResponseInfo.ContentStream          := mb;
       AResponseInfo.ContentStream.Position := 0;
       AResponseInfo.ContentLength          := -1;//mb.Size;
       AResponseInfo.WriteContent;
      {$ENDIF}
      Exit;
     End;
    If DWFileExists(sFile, FRootPath) then
     Begin
      AResponseInfo.ContentType := GetMIMEType(sFile);
      {$IFNDEF FPC}
       {$if CompilerVersion > 21}
        If (sCharSet <> '') Then
         AResponseInfo.CharSet := sCharSet;
       {$IFEND}
      {$ENDIF}
      AResponseInfo.ContentStream := TIdReadFileExclusiveStream.Create(sFile);
      AResponseInfo.WriteContent;
      Exit;
     End;
   End;
  If (vPathTraversalRaiseError) And (TravertalPathFind(Trim(ARequestInfo.RawHTTPCommand))) Then
   Begin
    AResponseInfo.ResponseNo               := 404;
    {$IFNDEF FPC}
     If compresseddata Then
      mb                                  := TStringStream(ZCompressStreamNew(cEventNotFound))
     Else
      mb                                  := TStringStream.Create(cEventNotFound{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
     mb.Position                          := 0;
     AResponseInfo.FreeContentStream      := True;
     AResponseInfo.ContentStream          := mb;
     AResponseInfo.ContentStream.Position := 0;
     AResponseInfo.ContentLength          := mb.Size;
     AResponseInfo.WriteContent;
    {$ELSE}
     If compresseddata Then
      mb                                  := TStringStream(ZCompressStreamNew(cEventNotFound)) //TStringStream.Create(Utf8Encode(vReplyStringResult))
     Else
      mb                                  := TStringStream.Create(cEventNotFound);
     mb.Position                          := 0;
     AResponseInfo.FreeContentStream      := True;
     AResponseInfo.ContentStream          := mb;
     AResponseInfo.ContentStream.Position := 0;
     AResponseInfo.ContentLength          := -1;//mb.Size;
     AResponseInfo.WriteContent;
    {$ENDIF}
    Exit;
   End;
  Cmd := RemoveBackslashCommands(Trim(ARequestInfo.RawHTTPCommand));
  vRequestHeader.Add(Cmd);
  Cmd := StringReplace(Cmd, ' HTTP/1.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/1.1', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.1', '', [rfReplaceAll]);
  vCORSOption := UpperCase(Copy(Cmd, 1, 7));
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET' )   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'POST')   OR
     (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')    OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'DELE')   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'PATC')   Then
   Begin
    RequestType := rtGet;
    If (UpperCase(Copy (Cmd, 1, 4))      = 'POST') Then
     RequestType := rtPost
    Else If (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')  Then
     RequestType := rtPut
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'DELE') Then
     RequestType := rtDelete
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'PATC') Then
     RequestType := rtPatch;
    {$IFNDEF FPC}
     If {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                      {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                      {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} = '/favicon.ico' Then
      Exit;
    {$ELSE}
     If RemoveBackslashCommands(ARequestInfo.URI) = '/favicon.ico' Then
      Exit;
    {$ENDIF}
    Cmd := ClearRequestType(Cmd);
    If (Cmd <> '/') And (Cmd <> '') Then
     ReadRawHeaders;
    vCompareContext := CompareBaseURL(Cmd); // := aDefaultUrl;
    If Cmd <> '' Then
     TServerUtils.ParseRESTURL (ClearRequestType(Cmd), vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
    If ((ARequestInfo.Params.Count > 0) And (RequestType In [rtGet, rtDelete])) Then
     Begin
      {$IFNDEF FPC}
       vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                        {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                        {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF});
      {$ELSE}
       vRequestHeader.Add(RemoveBackslashCommands(ARequestInfo.URI));
      {$ENDIF}
      vRequestHeader.Add(ARequestInfo.Params.Text);
      vRequestHeader.Add(ARequestInfo.QueryParams);
      aParamsCount := cParamsCount;
      If ServerContext <> '' Then
       Inc(aParamsCount);
      If vDataRouteList.Count > 0 Then
       Inc(aParamsCount);
      TServerUtils.ParseWebFormsParams(DWParams, ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                    {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                    {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                       ARequestInfo.QueryParams,
                                       vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, aParamsCount, RequestType);
      If DWParams <> Nil Then
       Begin
        If (DWParams.ItemsString['dwwelcomemessage']     <> Nil)    Then
         vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If (DWParams.ItemsString['dwaccesstag']          <> Nil)    Then
         vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If (DWParams.ItemsString['datacompression']      <> Nil)    Then
         compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
        If (DWParams.ItemsString['dwencodestrings']      <> Nil)    Then
         encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
        If (DWParams.ItemsString['dwusecript']           <> Nil)    Then
         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
        If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil)    Then
         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
        If (DWParams.ItemsString['dwservereventname']    <> Nil)    Then
         Begin
          If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
           Begin
//            vUriOptions.ServerEvent := '';
            If Not (DWParams.ItemsString['dwservereventname'].IsNull) Then
             Begin
              If ((vUriOptions.BaseServer = '')  And
                  (vUriOptions.DataUrl    = '')) And
                 (vUriOptions.ServerEvent <> '') Then
               vUriOptions.BaseServer := vUriOptions.ServerEvent
              Else If ((vUriOptions.BaseServer <> '') And
                       (vUriOptions.DataUrl    = '')) And
                      (vUriOptions.ServerEvent <> '') And
                       (vServerContext = '')          Then
               Begin
                vUriOptions.DataUrl    := vUriOptions.BaseServer;
                vUriOptions.BaseServer := vUriOptions.ServerEvent;
               End;
              vUriOptions.ServerEvent := DecodeStrings(DWParams.ItemsString['dwservereventname'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
           End;
         End;
       End;
     End
    Else
     Begin
      If (RequestType In [rtGet, rtDelete]) Then
       Begin
        aurlContext  := vUriOptions.ServerEvent;
        aParamsCount := cParamsCount;
        If ServerContext <> '' Then
         Inc(aParamsCount);
        If vDataRouteList.Count > 0 Then
         Inc(aParamsCount);
        If Not Assigned(DWParams) Then
         TServerUtils.ParseRESTURL ({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                  {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                  {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF}, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
        vOldMethod := vUriOptions.EventName;
        If ((vUriOptions.BaseServer = '')   And
            (vUriOptions.DataUrl    = ''))  And
           ((vUriOptions.ServerEvent <> '') And
            (vUriOptions.EventName = ''))   Then
         vUriOptions.BaseServer := vUriOptions.ServerEvent
        Else If ((vUriOptions.BaseServer <> '') And
                 (vUriOptions.DataUrl    = '')) And
                (vUriOptions.ServerEvent <> '') And
                 (vServerContext = '')  Then
         Begin
          vUriOptions.DataUrl    := vUriOptions.BaseServer;
          vUriOptions.BaseServer := vUriOptions.ServerEvent;
         End;
        If DWParams <> Nil Then
         Begin
          If DWParams.ItemsString['dwwelcomemessage']      <> Nil  Then
           vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
           vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['datacompression']      <> Nil) Then
           compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
          If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
           encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
          If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
           Begin
            If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
             Begin
              If ((vUriOptions.BaseServer = '')  And
                  (vUriOptions.DataUrl    = '')) And
                 (vUriOptions.ServerEvent <> '') Then
               vUriOptions.BaseServer := vUriOptions.ServerEvent
              Else If ((vUriOptions.BaseServer <> '') And
                       (vUriOptions.DataUrl    = '')) And
                      (vUriOptions.ServerEvent <> '') And
                       (vServerContext = '')          Then
               Begin
                vUriOptions.DataUrl    := vUriOptions.BaseServer;
                vUriOptions.BaseServer := vUriOptions.ServerEvent;
               End;
              vUriOptions.ServerEvent   := DWParams.ItemsString['dwservereventname'].AsString;
             End;
           End;
          If (DWParams.ItemsString['dwusecript']           <> Nil) Then
           vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
          If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
           dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
          If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
           vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
         End;
        If (vUriOptions.ServerEvent = '') And (aurlContext <> '') Then
         vUriOptions.ServerEvent := aurlContext;
       End;
      If (RequestType In [rtPut, rtPatch, rtDelete]) Then //New Code to Put
       Begin
        If ARequestInfo.FormParams <> '' Then
         Begin
          TServerUtils.ParseFormParamsToDWParam(ARequestInfo.FormParams, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
           vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
           vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['datacompression']      <> Nil) Then
           compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
          If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
           encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
          If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
           Begin
            If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
             Begin
              If ((vUriOptions.BaseServer = '')  And
                  (vUriOptions.DataUrl    = '')) And
                 (vUriOptions.ServerEvent <> '') Then
               vUriOptions.BaseServer := vUriOptions.ServerEvent
              Else If ((vUriOptions.BaseServer <> '') And
                       (vUriOptions.DataUrl    = '')) And
                      (vUriOptions.ServerEvent <> '') And
                       (vServerContext = '')          Then
               Begin
                vUriOptions.DataUrl    := vUriOptions.BaseServer;
                vUriOptions.BaseServer := vUriOptions.ServerEvent;
               End;
              vUriOptions.ServerEvent   := DWParams.ItemsString['dwservereventname'].AsString;
             End;
           End;
          If (DWParams.ItemsString['dwusecript']           <> Nil) Then
           vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
          If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
           dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
          If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
           vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
         End;
       End;
      If Assigned(ARequestInfo.PostStream) Then
       Begin
         ARequestInfo.PostStream.Position := 0;
         If Not vBinaryEvent Then
          Begin
           Try
            mb := TStringStream.Create(''); //{$IFNDEF FPC}{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
            try
             mb.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
             ARequestInfo.PostStream.Position := 0;
             mb.Position := 0;
             If (pos('--', mb.DataString) > 0) and (pos('boundary', ARequestInfo.ContentType) > 0) Then
              Begin
                msgEnd   := False;
                {$IFNDEF FPC}
                 {$IF (DEFINED(OLDINDY))}
                  boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary');
                 {$ELSE}
                  boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                 {$IFEND}
                {$ELSE}
                 boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                {$ENDIF}
                startboundary := '--' + boundary;
                Repeat
                 tmp := ReadLnFromStream(ARequestInfo.PostStream, -1, True);
                until tmp = startboundary;
              End;
            finally
             if Assigned(mb) then
              FreeAndNil(mb);
            end;
           Except
           End;
          End;
        If (ARequestInfo.PostStream.Size > 0) And (boundary <> '') Then
         Begin
          Try
           Repeat
//            If Assigned(decoder) Then //Observacao de Memleak XyberX
//             FreeAndNil(decoder);
            decoder := TIdMessageDecoderMIME.Create(nil);
            TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
            decoder.SourceStream := ARequestInfo.PostStream;
            decoder.FreeSourceStream := False;
            decoder.ReadHeader;
            Inc(I);
            Case Decoder.PartType of
             mcptAttachment:
              Begin
               ms := TStringStream.Create('');
               ms.Position := 0;
               NewDecoder := Decoder.ReadBody(ms, MsgEnd);
               vDecoderHeaderList := TStringList.Create;
               vDecoderHeaderList.Assign(Decoder.Headers);
               sFile := ExtractFileName(Decoder.FileName);
               FreeAndNil(Decoder);
               Decoder := NewDecoder;
               If Decoder <> Nil Then
                TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
               aParamsCount := cParamsCount;
               If ServerContext <> '' Then
                Inc(aParamsCount);
               If vDataRouteList.Count > 0 Then
                Inc(aParamsCount);
               If Not Assigned(DWParams) Then
                Begin
                 If (ARequestInfo.Params.Count = 0) Then
                  Begin
                   DWParams           := TDWParams.Create;
                   DWParams.Encoding  := vEncoding;
                  End
                 Else
                  TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                                    ARequestInfo.QueryParams,
                                                    vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
                End;
               JSONParam    := TJSONParam.Create(DWParams.Encoding);
               JSONParam.ObjectDirection := odIN;
               vObjectName  := '';
               sContentType := '';
               For I := 0 To vDecoderHeaderList.Count - 1 Do
                Begin
                 tmp := vDecoderHeaderList.Strings[I];
                 If Pos('; name="', lowercase(tmp)) > 0 Then
                  Begin
                   vObjectName := Copy(lowercase(tmp),
                                       Pos('; name="', lowercase(tmp)) + length('; name="'),
                                       length(lowercase(tmp)));
                   vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                  End;
                 If Pos('content-type=', lowercase(tmp)) > 0 Then
                  Begin
                   sContentType := Copy(lowercase(tmp),
                                       Pos('content-type=', lowercase(tmp)) + length('content-type='),
                                       length(lowercase(tmp)));
                  End;
                End;
                // Correção de FORM-DATA / FILE criar parametros automaticos: ICO 20-09-2019
               If (vObjectName <> '') Then
                JSONParam.ParamName        := vObjectName
               Else
                Begin
                 vObjectName := 'dwfilename';
                 JSONParam.ParamName       := vObjectName
                End;
               If (sContentType =  '') And
                  (sFile        <> '') Then
                vObjectName := GetMIMEType(sFile);
               JSONParam.ParamName        := vObjectName;
               JSONParam.ParamFileName    := sFile;
               JSONParam.ParamContentType := sContentType;
               ms.Position := 0;
               If (sFile <> '') Then
                JSONParam.LoadFromStream(ms)
               Else If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                JSONParam.FromJSON(ms.DataString)
               Else
                JSONParam.AsString := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
               DWParams.Add(JSONParam);
               //Fim da correção - ICO
               ms.Free;
               vDecoderHeaderList.Free;
              End;
             mcptText :
              Begin
               {$IFDEF FPC}
               ms := TStringStream.Create('');
               {$ELSE}
               ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
               {$ENDIF}
               ms.Position := 0;
               newdecoder  := Decoder.ReadBody(ms, msgEnd);
               tmp         := Decoder.Headers.Text;
               FreeAndNil(Decoder);
               Decoder     := newdecoder;
               vObjectName := '';
               If Decoder <> Nil Then
                TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
               If pos('dwwelcomemessage', lowercase(tmp)) > 0      Then
                vWelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else If pos('dwaccesstag', lowercase(tmp)) > 0      Then
                vAccessTag := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else If Pos('dwusecript', lowercase(tmp)) > 0       Then
                vdwCriptKey  := StringToBoolean(ms.DataString)
               Else If pos('datacompression', lowercase(tmp)) > 0  Then
                compresseddata := StringToBoolean(ms.DataString)
               Else If pos('dwencodestrings', lowercase(tmp)) > 0  Then
                encodestrings  := StringToBoolean(ms.DataString)
               Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                dwassyncexec := StringToBoolean(ms.DataString)
               Else If Pos('binaryrequest', lowercase(tmp)) > 0    Then
                vBinaryEvent := StringToBoolean(ms.DataString)
               Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                Begin
                 vdwConnectionDefs   := TConnectionDefs.Create;
                 JSONValue           := TJSONValue.Create;
                 Try
                  JSONValue.Encoding  := vEncoding;
                  JSONValue.Encoded  := True;
                  JSONValue.LoadFromJSON(ms.DataString);
                  vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                 Finally
                  FreeAndNil(JSONValue);
                 End;
                End
               Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                Begin
                 JSONValue           := TJSONValue.Create;
                 Try
                  JSONValue.Encoding := vEncoding;
                  JSONValue.Encoded  := True;
                  JSONValue.LoadFromJSON(ms.DataString);
                  If ((vUriOptions.BaseServer = '')  And
                      (vUriOptions.DataUrl    = '')) And
                     (vUriOptions.ServerEvent <> '') Then
                   vUriOptions.BaseServer := vUriOptions.ServerEvent
                  Else If ((vUriOptions.BaseServer <> '') And
                           (vUriOptions.DataUrl    = '')) And
                          (vUriOptions.ServerEvent <> '') And
                           (vServerContext = '')  Then
                   Begin
                    vUriOptions.DataUrl    := vUriOptions.BaseServer;
                    vUriOptions.BaseServer := vUriOptions.ServerEvent;
                   End;
                  vUriOptions.ServerEvent := JSONValue.Value;
                  If Pos('.', vUriOptions.ServerEvent) > 0 Then
                   Begin
                    baseEventUnit       := Copy(vUriOptions.ServerEvent, InitStrPos, Pos('.', vUriOptions.ServerEvent) - 1 - FinalStrPos);
                    vUriOptions.ServerEvent := Copy(vUriOptions.ServerEvent, Pos('.', vUriOptions.ServerEvent) + 1, Length(vUriOptions.ServerEvent));
                   End;
                 Finally
                  FreeAndNil(JSONValue);
                 End;
                End
               Else
                Begin
                 If DWParams = Nil Then
                  Begin
                   DWParams           := TDWParams.Create;
                   DWParams.Encoding  := vEncoding;
                  End;
                 If (lowercase(vObjectName) = 'binarydata') then
                  Begin
                   DWParams.LoadFromStream(ms);
                   If Assigned(JSONParam) Then
                    FreeAndNil(JSONParam);
                   {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                   FreeAndNil(ms);
                   If DWParams <> Nil Then
                    Begin
                     If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
                      vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
                      vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If (DWParams.ItemsString['datacompression']      <> Nil) Then
                      compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                     If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
                      encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                     If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
                      Begin
                       If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                        Begin
                         If ((vUriOptions.BaseServer = '')  And
                             (vUriOptions.DataUrl    = '')) And
                            (vUriOptions.ServerEvent <> '') Then
                          vUriOptions.BaseServer := vUriOptions.ServerEvent
                         Else If ((vUriOptions.BaseServer <> '') And
                                  (vUriOptions.DataUrl    = '')) And
                                 (vUriOptions.ServerEvent <> '') And
                                  (vServerContext = '')          Then
                          Begin
                           vUriOptions.DataUrl    := vUriOptions.BaseServer;
                           vUriOptions.BaseServer := vUriOptions.ServerEvent;
                          End;
                         vUriOptions.ServerEvent   := DWParams.ItemsString['dwservereventname'].AsString;
                        End;
                      End;
                     If (DWParams.ItemsString['dwusecript']           <> Nil) Then
                      vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                     If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
                      dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                     If (DWParams.ItemsString['binaryrequest']        <> Nil) Then
                      vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                     If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
                      vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                    End;
                   If Assigned(decoder) Then
                    FreeAndNil(decoder);
                   Continue;
                  End;
                 vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                 vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                 JSONParam   := TJSONParam.Create(DWParams.Encoding);
                 JSONParam.ObjectDirection := odIN;
                 If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                  JSONParam.FromJSON(ms.DataString)
                 Else
                  JSONParam.AsString := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                 JSONParam.ParamName := vObjectName;
                 DWParams.Add(JSONParam);
                End;
               {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
               FreeAndNil(ms);
               If Assigned(Newdecoder)  Then
                FreeAndNil(Newdecoder);
              End;
             mcptIgnore :
              Begin
               Try
                If decoder <> Nil Then
                 FreeAndNil(decoder);
                decoder := TIdMessageDecoderMIME.Create(Nil);
                TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
               Finally
               End;
              End;
            {$IFNDEF FPC}
             {$IF Not(DEFINED(OLDINDY))}
             mcptEOF:
              Begin
               FreeAndNil(decoder);
               msgEnd := True
              End;
             {$IFEND}
            {$ELSE}
             mcptEOF:
              Begin
               FreeAndNil(decoder);
               msgEnd := True
              End;
            {$ENDIF}
            End;
           Until (Decoder = Nil) Or (msgEnd);
          Finally
           If Assigned(decoder) then
            FreeAndNil(decoder);
          End;
         End
        Else
         Begin
          If (ARequestInfo.PostStream.Size > 0) And (boundary = '') Then
           Begin
            mb       := TStringStream.Create('');
            Try
             ARequestInfo.PostStream.Position := 0;
             mb.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
             ARequestInfo.PostStream.Position := 0;
             mb.Position  := 0;
             aParamsCount := cParamsCount;
             If ServerContext <> '' Then
              Inc(aParamsCount);
             If vDataRouteList.Count > 0 Then
              Inc(aParamsCount);
             If Not Assigned(DWParams) Then
              TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                   {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                   {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                                ARequestInfo.QueryParams,
                                                vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
             {Alteração feita por Tiago IStuque - 28/12/2018}
             If Assigned(DWParams.ItemsString['dwReadBodyRaw']) And (DWParams.ItemsString['dwReadBodyRaw'].AsString='1') Then
              TServerUtils.ParseBodyRawToDWParam(mb.DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else If (Assigned(DWParams.ItemsString['dwReadBodyBin']) And
                     (DWParams.ItemsString['dwReadBodyBin'].AsString='1')) Then
              TServerUtils.ParseBodyBinToDWParam(mb.DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else If (vBinaryEvent) Then
              Begin
               If (pos('--', mb.DataString) > 0) and (pos('boundary', ARequestInfo.ContentType) > 0) Then
                Begin
                 msgEnd   := False;
                 {$IFNDEF FPC}
                  {$IF (DEFINED(OLDINDY))}
                   boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary');
                  {$ELSE}
                   boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                  {$IFEND}
                 {$ELSE}
                  boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                 {$ENDIF}
                 startboundary := '--' + boundary;
                 Repeat
                  tmp := ReadLnFromStream(ARequestInfo.PostStream, -1, True);
                 Until tmp = startboundary;
                End;
                Try
                 Repeat
                  decoder := TIdMessageDecoderMIME.Create(nil);
                  TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
                  decoder.SourceStream := ARequestInfo.PostStream;
                  decoder.FreeSourceStream := False;
                  decoder.ReadHeader;
                  Inc(I);
                  Case Decoder.PartType of
                   mcptAttachment:
                    Begin
                     ms := TStringStream.Create('');
                     ms.Position := 0;
                     NewDecoder := Decoder.ReadBody(ms, MsgEnd);
                     vDecoderHeaderList := TStringList.Create;
                     vDecoderHeaderList.Assign(Decoder.Headers);
                     sFile := ExtractFileName(Decoder.FileName);
                     FreeAndNil(Decoder);
                     Decoder := NewDecoder;
                     If Decoder <> Nil Then
                      TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                     aParamsCount := cParamsCount;
                     If ServerContext <> '' Then
                      Inc(aParamsCount);
                     If vDataRouteList.Count > 0 Then
                      Inc(aParamsCount);
                     If Not Assigned(DWParams) Then
                      Begin
                       If (ARequestInfo.Params.Count = 0) Then
                        Begin
                         DWParams           := TDWParams.Create;
                         DWParams.Encoding  := vEncoding;
                        End
                       Else
                        TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                             {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                             {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                                          ARequestInfo.QueryParams,
                                                          vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
                      End;
                     JSONParam    := TJSONParam.Create(DWParams.Encoding);
                     JSONParam.ObjectDirection := odIN;
                     vObjectName  := '';
                     sContentType := '';
                     for I := 0 to vDecoderHeaderList.Count - 1 do
                      begin
                       tmp := vDecoderHeaderList.Strings[I];
                       if Pos('; name="', lowercase(tmp)) > 0 then
                        begin
                         vObjectName := Copy(lowercase(tmp),
                                             Pos('; name="', lowercase(tmp)) + length('; name="'),
                                             length(lowercase(tmp)));
                         vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                        end;
                       if Pos('content-type=', lowercase(tmp)) > 0 then
                        begin
                         sContentType := Copy(lowercase(tmp),
                                             Pos('content-type=', lowercase(tmp)) + length('content-type='),
                                             length(lowercase(tmp)));
                        end;
                      end;
                      // Correção de FORM-DATA / FILE criar parametros automaticos: ICO 20-09-2019
                      If (lowercase(vObjectName) = 'binarydata') then
                       Begin
                        DWParams.LoadFromStream(ms);
                        If Assigned(JSONParam) Then
                         FreeAndNil(JSONParam);
                        If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
                         vWelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                        If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
                         vAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                        If (DWParams.ItemsString['datacompression']      <> Nil) Then
                         compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                        If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
                         encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                        If (DWParams.ItemsString['dwservereventname']    <> Nil) Then
                         Begin
                          If (vUriOptions.ServerEvent <> GetEventNameX(Lowercase(DWParams.ItemsString['dwservereventname'].AsString))) Then
                           Begin
                            If ((vUriOptions.BaseServer = '')  And
                                (vUriOptions.DataUrl    = '')) And
                               (vUriOptions.ServerEvent <> '') Then
                             vUriOptions.BaseServer := vUriOptions.ServerEvent
                            Else If ((vUriOptions.BaseServer <> '') And
                                     (vUriOptions.DataUrl    = '')) And
                                    (vUriOptions.ServerEvent <> '') And
                                     (vServerContext = '')          Then
                             Begin
                              vUriOptions.DataUrl    := vUriOptions.BaseServer;
                              vUriOptions.BaseServer := vUriOptions.ServerEvent;
                             End;
                            vUriOptions.ServerEvent := DWParams.ItemsString['dwservereventname'].AsString;
                           End;
                         End;
                        If (DWParams.ItemsString['dwusecript']           <> Nil) Then
                         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                        If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
                         dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                        If (DWParams.ItemsString['binaryrequest']        <> Nil) Then
                         vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                        If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
                         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                        if DWParams.ItemsString['dwConnectionDefs'] <> Nil then
                        begin
                         if not Assigned(vdwConnectionDefs) then
                          vdwConnectionDefs := TConnectionDefs.Create;
                         JSONValue           := TJSONValue.Create;
                         Try
                          JSONValue.Encoding := vEncoding;
                          JSONValue.Encoded  := True;
                          JSONValue.LoadFromJSON(DWParams.ItemsString['dwConnectionDefs'].ToJSON);
                          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                         Finally
                          FreeAndNil(JSONValue);
                         End;
                        end;
                        If Assigned(vDecoderHeaderList) Then
                         FreeAndNil(vDecoderHeaderList);
                        If Assigned(ms) Then
                         FreeAndNil(ms);
                        FreeAndNil(Decoder);
                        Continue;
                       End
                      Else If (vObjectName <> '') Then
                       Begin
                        JSONParam.ParamName        := vObjectName;
                        tmp := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);//ms.DataString;
                        If Copy(tmp, Length(tmp) -1, 2) = sLineBreak Then
                         Delete(tmp, Length(tmp) -1, 2);
                        If vEncoding = esUtf8 Then
                         JSONParam.SetValue(utf8decode(tmp), JSONParam.Encoded)
                        Else
                         JSONParam.SetValue(tmp, JSONParam.Encoded);
                       End
                      Else
                       Begin
                        vObjectName := 'dwfilename';
                        If (sContentType = '') and (sFile <> '') then
                         vObjectName := GetMIMEType(sFile);
                        JSONParam.ParamName        := vObjectName;
                        JSONParam.ParamFileName    := sFile;
                        JSONParam.ParamContentType := sContentType;
                        If vEncoding = esUtf8 Then
                         JSONParam.SetValue(utf8decode(ms.DataString), JSONParam.Encoded)
                        Else If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                         JSONParam.FromJSON(ms.DataString)
                        Else
                         JSONParam.SetValue(ms.DataString, JSONParam.Encoded);
                       End;
                      DWParams.Add(JSONParam);
                     FreeAndNil(ms);
                     FreeAndNil(vDecoderHeaderList);
                    End;
                   mcptText :
                    begin
                     {$IFDEF FPC}
                     ms := TStringStream.Create('');
                     {$ELSE}
                     ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
                     {$ENDIF}
                     ms.Position := 0;
                     newdecoder  := Decoder.ReadBody(ms, msgEnd);
                     tmp         := Decoder.Headers.Text;
                     FreeAndNil(Decoder);
                     Decoder     := newdecoder;
                     vObjectName := '';
                     If Decoder <> Nil Then
                      TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                     If pos('dwwelcomemessage', lowercase(tmp)) > 0      Then
                      vWelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                     Else If pos('dwaccesstag', lowercase(tmp)) > 0      Then
                      vAccessTag := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                     Else If Pos('dwusecript', lowercase(tmp)) > 0       Then
                      vdwCriptKey  := StringToBoolean(ms.DataString)
                     Else If pos('datacompression', lowercase(tmp)) > 0  Then
                      compresseddata := StringToBoolean(ms.DataString)
                     Else If pos('dwencodestrings', lowercase(tmp)) > 0  Then
                      encodestrings  := StringToBoolean(ms.DataString)
                     Else If Pos('binaryrequest', lowercase(tmp)) > 0    Then
                      vBinaryEvent := StringToBoolean(ms.DataString)
                     Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                      dwassyncexec := StringToBoolean(ms.DataString)
                     Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                      Begin
                       vdwConnectionDefs   := TConnectionDefs.Create;
                       JSONValue           := TJSONValue.Create;
                       Try
                        JSONValue.Encoding  := vEncoding;
                        JSONValue.Encoded  := True;
                        JSONValue.LoadFromJSON(ms.DataString);
                        vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                       Finally
                        FreeAndNil(JSONValue);
                       End;
                      End
                     Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                      dwassyncexec := StringToBoolean(ms.DataString)
                     Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                      Begin
                       JSONValue            := TJSONValue.Create;
                       Try
                        JSONValue.Encoding  := vEncoding;
                        JSONValue.Encoded   := True;
                        JSONValue.LoadFromJSON(ms.DataString);
                        If ((vUriOptions.BaseServer = '')  And
                            (vUriOptions.DataUrl    = '')) And
                           (vUriOptions.ServerEvent <> '') Then
                         vUriOptions.BaseServer := vUriOptions.ServerEvent
                        Else If ((vUriOptions.BaseServer <> '') And
                                 (vUriOptions.DataUrl    = '')) And
                                (vUriOptions.ServerEvent <> '') And
                                 (vServerContext = '')          Then
                         Begin
                          vUriOptions.DataUrl    := vUriOptions.BaseServer;
                          vUriOptions.BaseServer := vUriOptions.ServerEvent;
                         End;
                        vUriOptions.ServerEvent := JSONValue.Value;
                        If Pos('.', vUriOptions.ServerEvent) > 0 Then
                         Begin
                          baseEventUnit       := Copy(vUriOptions.ServerEvent, InitStrPos, Pos('.', vUriOptions.ServerEvent) - 1 - FinalStrPos);
                          vUriOptions.ServerEvent := Copy(vUriOptions.ServerEvent, Pos('.', vUriOptions.ServerEvent) + 1, Length(vUriOptions.ServerEvent));
                         End;
                       Finally
                        FreeAndNil(JSONValue);
                       End;
                      End
                     Else
                      Begin
                       If DWParams = Nil Then
                        Begin
                         DWParams           := TDWParams.Create;
                         DWParams.Encoding  := vEncoding;
                        End;
                       vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                       vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                       JSONParam   := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ObjectDirection := odIN;
                       If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                        JSONParam.FromJSON(ms.DataString)
                       Else
                        JSONParam.AsString := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                       JSONParam.ParamName := vObjectName;
                       DWParams.Add(JSONParam);
                      End;
                     {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                     FreeAndNil(ms);
                     FreeAndNil(newdecoder);
                    end;
                   mcptIgnore :
                    Begin
                     Try
                      If decoder <> Nil Then
                       FreeAndNil(decoder);
                     Finally
                     End;
                    End;
                   {$IFNDEF FPC}
                    {$IF Not(DEFINED(OLDINDY))}
                    mcptEOF:
                     Begin
                      FreeAndNil(decoder);
                      msgEnd := True
                     End;
                    {$IFEND}
                   {$ELSE}
                   mcptEOF:
                    Begin
                     FreeAndNil(decoder);
                     msgEnd := True
                    End;
                   {$ENDIF}
                  End;
                 Until (Decoder = Nil) Or (msgEnd);
                Finally
                 If decoder <> nil then
                  FreeAndNil(decoder);
                End;
              End
             Else If (ARequestInfo.Params.Count = 0)
                      {$IFNDEF FPC}
                       {$If Not(DEFINED(OLDINDY))}
                        {$If (CompilerVersion > 23)}
                         And (ARequestInfo.QueryParams.Length = 0)
                        {$IFEND}
                       {$ELSE}
                        And (Length(ARequestInfo.QueryParams) = 0)
                       {$IFEND}
                      {$ELSE}
                       And (ARequestInfo.QueryParams.Length = 0)
                      {$ENDIF}Then
              Begin
               If vEncoding = esUtf8 Then
                TServerUtils.ParseBodyRawToDWParam(utf8decode(mb.DataString), vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else
                TServerUtils.ParseBodyRawToDWParam(mb.DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
              End
             Else
              Begin
               If vEncoding = esUtf8 Then
                Begin
                 TServerUtils.ParseDWParamsURL(utf8decode(mb.DataString), vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 if DWParams.ItemsString['undefined'] = nil then
                  TServerUtils.ParseBodyRawToDWParam(utf8decode(mb.DataString), vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                End
               Else
                Begin
                 TServerUtils.ParseDWParamsURL(mb.DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 if DWParams.ItemsString['undefined'] = nil then
                  TServerUtils.ParseBodyRawToDWParam(mb.DataString, vEncoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                End;
              End;
             {Fim alteração feita por Tiago Istuque - 28/12/2018}
            Finally
             mb.Free;
            End;
           End;
         End;
       End
      Else
       Begin
        aurlContext := vUriOptions.ServerEvent;
        If Not (RequestType In [rtPut, rtPatch, rtDelete]) Then
         Begin
          aParamsCount := cParamsCount;
          If ServerContext <> '' Then
           Inc(aParamsCount);
          If vDataRouteList.Count > 0 Then
           Inc(aParamsCount);
          {$IFDEF FPC}
          If ARequestInfo.FormParams <> '' Then
           Begin
            If Trim(ARequestInfo.QueryParams) <> '' Then
             Begin
              vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.QueryParams + '&' + ARequestInfo.FormParams);
              TServerUtils.ParseRESTURL ({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.QueryParams + '&' + ARequestInfo.FormParams, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
             End
            Else
             Begin
              vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.FormParams);
              TServerUtils.ParseRESTURL ({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.FormParams, vEncoding, vUriOptions, vmark{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount);
              If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then  // Ico Menezes - Post Receber WelcomeMessage   - 20-12-2018
               vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
           End
          Else
           Begin
            vRequestHeader.Add(ARequestInfo.Params.Text);
            vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                             {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                             {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF});
            vRequestHeader.Add(ARequestInfo.QueryParams);

            If Not Assigned(DWParams) Then  //uhmano
            TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                 {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                 {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                              ARequestInfo.QueryParams,
                                              vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
           End;
          {$ELSE}
          If ARequestInfo.FormParams <> '' Then
           Begin
            If Trim(ARequestInfo.QueryParams) <> '' Then
             Begin
              vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.QueryParams + '&' + ARequestInfo.FormParams);
              TServerUtils.ParseRESTURL ({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.QueryParams + '&' + ARequestInfo.FormParams, vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
             End
            Else
             Begin
              vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                               {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.FormParams);
              TServerUtils.ParseRESTURL ({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} + '?' + ARequestInfo.FormParams, vEncoding, vUriOptions, vmark, DWParams, aParamsCount);
              If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then  // Ico Menezes - Post Receber WelcomeMessage   - 20-12-2018
               vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             End;
           End
           Else
            Begin
             vRequestHeader.Add(ARequestInfo.Params.Text);
             vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                              {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                              {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF});
             vRequestHeader.Add(ARequestInfo.QueryParams);
             If Not Assigned(DWParams) Then
              TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                   {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                   {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                                ARequestInfo.QueryParams,
                                                vUriOptions, vmark, vEncoding, DWParams, aParamsCount, RequestType);
            End;
          {$ENDIF}
          If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
           vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         End
        Else
         Begin
          {$IFDEF FPC}
           vRequestHeader.Add(ARequestInfo.Params.Text);
           vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF});
           vRequestHeader.Add(ARequestInfo.QueryParams);
           If Not Assigned(DWParams) Then  //uhmano
           TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                             ARequestInfo.QueryParams,
                                             vUriOptions, vmark, vEncoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams, aParamsCount, RequestType);
          {$ELSE}
           vRequestHeader.Add(ARequestInfo.Params.Text);
           vRequestHeader.Add({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF});
           vRequestHeader.Add(ARequestInfo.QueryParams);
           If Not Assigned(DWParams) Then
            TServerUtils.ParseWebFormsParams (ARequestInfo.Params, {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                                 {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                                 {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF},
                                              ARequestInfo.QueryParams,
                                              vUriOptions, vmark, vEncoding, DWParams, aParamsCount, RequestType);
          {$ENDIF}
         End;
        If ((vUriOptions.ServerEvent = '') And (aurlContext <> '')) And
            (Not (RequestType In [rtGet, rtDelete])) Then
         vUriOptions.ServerEvent := aurlContext;
       End;
     End;
     WelcomeAccept         := True;
     tmp                   := '';
     vAuthenticationString := '';
     vToken                := '';
     vGettoken             := False;
     vAcceptAuth           := False;
     If (vDataRouteList.Count > 0) Then
      Begin
       If (vUriOptions.BaseServer = '') And (vUriOptions.DataUrl = '') Then
        vUriOptions.BaseServer := vUriOptions.ServerEvent
      End;
     If (vServerContext <> '') Then
      Begin
       If (vUriOptions.BaseServer = '') And (vUriOptions.ServerEvent <> '') Then
        Begin
         vUriOptions.BaseServer  := vUriOptions.ServerEvent;
         vUriOptions.ServerEvent := '';
        End;
      End;
     If (vDataRouteList.Count > 0) Then
      Begin
       If (vServerContext = '') Then
        Begin
         If vDataRouteList.RouteExists(vUriOptions.BaseServer) Then
          Begin
           vUriOptions.DataUrl    := vUriOptions.BaseServer;
           vUriOptions.BaseServer := '';
          End;
        End;
      End;
     If ((vUriOptions.BaseServer <> vServerContext) And (vServerContext <> '')) Or
          ((vUriOptions.BaseServer <> '') And (vUriOptions.BaseServer <> vUriOptions.ServerEvent) And
         (vServerContext = '')) Then
      Begin
       vErrorCode := 400;
       JSONStr    := GetPairJSON(-5, 'Invalid Server Context');
      End
     Else
      Begin
       If vDataRouteList.Count > 0 Then
        Begin
         If ((vUriOptions.BaseServer <> '') And (vUriOptions.DataUrl = '') And (vServerContext <> '')) or
            ((vServerContext = '') And (vUriOptions.BaseServer <> vUriOptions.ServerEvent) And (vUriOptions.BaseServer <> '')) Then
          Begin
           If Not vDataRouteList.GetServerMethodClass(vUriOptions.BaseServer, vServerMethod) Then
            Begin
             vErrorCode := 400;
             JSONStr    := GetPairJSON(-5, 'Invalid Data Context');
            End;
          End
         Else
          Begin
           If Not vDataRouteList.GetServerMethodClass(vUriOptions.DataUrl, vServerMethod) Then
            Begin
             vErrorCode := 400;
             JSONStr    := GetPairJSON(-5, 'Invalid Data Context');
            End;
          End;
        End
       Else
        Begin
         If (((vUriOptions.BaseServer = '')                     And
              (vServerContext = ''))                            Or
              (vUriOptions.BaseServer = vServerContext))        And
            ((vUriOptions.DataUrl = '')                         Or
             (vUriOptions.DataUrl = vUriOptions.ServerEvent))   Or
            ((vServerContext = '')                              And
             (vUriOptions.BaseServer = vUriOptions.ServerEvent) And
             (vUriOptions.ServerEvent <> ''))                   Then
          vServerMethod := aServerMethod;
        End;
       If Assigned(vServerMethod) Then
        Begin
         If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
          vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
          vAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
         Try
//          {$IFDEF FPC}
//           InitCriticalSection(vCriticalSection);
//           EnterCriticalSection(vCriticalSection);
//          {$ENDIF}
          vTempServerMethods  := vServerMethod.Create(Nil);
         Finally
//          {$IFDEF FPC}
//           Try
//            LeaveCriticalSection(vCriticalSection);
//            DoneCriticalSection(vCriticalSection);
//           Except
//           End;
//          {$ENDIF}
         End;
         If (vTempServerMethods.ClassType = TServerMethodDatamodule)             Or
            (vTempServerMethods.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
          Begin
           If TServerMethodDatamodule(vTempServerMethods).QueuedRequest Then
            Begin
             {$IFNDEF FPC}
              {$IF CompilerVersion > 21}
               {$IFDEF WINDOWS}
                InitializeCriticalSection(vCriticalSection);
                EnterCriticalSection(vCriticalSection);
               {$ELSE}
                If Not Assigned(vCriticalSection) Then
                 vCriticalSection := TCriticalSection.Create;
                vCriticalSection.Acquire;
               {$ENDIF}
              {$ELSE}
               If Not Assigned(vCriticalSection)  Then
                vCriticalSection := TCriticalSection.Create;
               vCriticalSection.Acquire;
              {$IFEND}
             {$ELSE}
              InitCriticalSection(vCriticalSection);
              EnterCriticalSection(vCriticalSection);
             {$ENDIF}
            End;
           vServerAuthOptions.CopyServerAuthParams(vRDWAuthOptionParam);
           TServerMethodDatamodule(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
           If AContext.Connection.Socket.Binding.IPVersion = Id_IPv6 Then
            vIPVersion := 'ipv6';
           TServerMethodDatamodule(vTempServerMethods).SetClientInfo(AContext.Connection.Socket.Binding.PeerIP, vIPVersion,
                                                                     ARequestInfo.UserAgent, vUriOptions.EventName, vUriOptions.ServerEvent, AContext.Connection.Socket.Binding.PeerPort);
           If (RequestType In [rtGet, rtDelete]) Then
            Begin
             If ((vUriOptions.BaseServer = '')   And
                 (vUriOptions.DataUrl    = ''))  And
                ((vUriOptions.ServerEvent <> '') And
                 (vUriOptions.EventName = ''))   Then
              vUriOptions.BaseServer := vUriOptions.ServerEvent
             Else If ((vUriOptions.BaseServer <> '') And
                      (vUriOptions.DataUrl    = '')) And
                     (vUriOptions.ServerEvent <> '') And
                      (vServerContext = '')  Then
              Begin
               vUriOptions.DataUrl    := vUriOptions.BaseServer;
               vUriOptions.BaseServer := vUriOptions.ServerEvent;
              End;
            End;
           //Novo Lugar para Autenticação
           If ((vCORS) And (vCORSOption <> 'OPTIONS')) Or
               (vServerAuthOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken]) Then
            Begin
             vAcceptAuth           := False;
             vErrorCode            := 401;
             vErrorMessage         := cInvalidAuth;
             Case vServerAuthOptions.AuthorizationOption Of
              rdwAOBasic  : Begin
                             vNeedAuthorization := False;
                             vTempEvent   := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions.EventName, vUriOptions.ServerEvent);
                             If vTempEvent = Nil Then
                              Begin
                               vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions);
                               If vTempContext <> Nil Then
                                vNeedAuthorization := vTempContext.NeedAuthorization
                               Else
                                vNeedAuthorization := True;
                              End
                             Else
                              vNeedAuthorization := vTempEvent.NeedAuthorization;
                             If vNeedAuthorization Then
                              Begin
                               vAuthenticationString := ARequestInfo.RawHeaders.Values['Authorization']; //ARequestInfo.Authentication.Authentication;// RawHeaders.Values['Authorization'];
                               If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth) Then
                                Begin
                                 TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth(vWelcomeMessage, vAccessTag,
                                                                                             ARequestInfo.AuthUsername,
                                                                                             ARequestInfo.AuthPassword,
                                                                                             DWParams, vErrorCode, vErrorMessage, vAcceptAuth);
                                 If Not vAcceptAuth Then
                                  Begin
                                   AResponseInfo.AuthRealm    := AuthRealm;
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End;
                                End
                               Else If Not ((ARequestInfo.AuthUsername = TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username) And
                                            (ARequestInfo.AuthPassword = TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password)) Then
                                Begin
                                 AResponseInfo.AuthRealm := AuthRealm;
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End;
                              End;
                            End;
              rdwAOBearer : Begin
                             vUrlToken := Lowercase(vUriOptions.EventName);
                             If vUrlToken =
                                Lowercase(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                              Begin
                               vGettoken     := True;
                               vErrorCode    := 404;
                               vErrorMessage := cEventNotFound;
                               If (RequestTypeToRoute(RequestType) In TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                                  (crAll in TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                                Begin
                                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                                  Begin
                                   vTokenValidate := True;
                                   vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                   vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                  {$IFNDEF FPC}
                                   {$IF Defined(HAS_FMX)}
                                    {$IFDEF HAS_UTF8}
                                     If Assigned({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}) Then
                                      vToken       := TRDWAuthRequest({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                    {$ELSE}
                                     If Assigned(AContext.Data) Then
                                      vToken       := TRDWAuthRequest(AContext.Data).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                    {$ENDIF}
                                   {$ELSE}
                                    If Assigned(AContext.Data) Then
                                     vToken       := TRDWAuthRequest(AContext.Data).Token
                                    Else
                                     vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                   {$IFEND}
                                  {$ELSE}
                                   If Assigned(AContext.Data) Then
                                    vToken       := TRDWAuthRequest(AContext.Data).Token
                                   Else
                                    vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                  {$ENDIF}
                                   If DWParams.ItemsString['RDWParams'] <> Nil Then
                                    Begin
                                     DWParamsD := TDWParams.Create;
                                     DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                                     TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParamsD,
                                                                                            TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                            vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                     FreeAndNil(DWParamsD);
                                    End
                                   Else
                                    TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParams,
                                                                                           TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                           vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                   If Not vAcceptAuth Then
                                    Begin
                                     WriteError;
                                     DestroyComponents;
                                     Exit;
                                    End;
                                  End
                                 Else
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End;
                                End
                               Else
                                Begin
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End;
                              End
                             Else
                              Begin
                               vErrorCode      := 401;
                               vErrorMessage   := cInvalidAuth;
                               vTokenValidate  := True;
                               vNeedAuthorization := False;
                               vTempEvent   := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions.EventName, vUriOptions.ServerEvent);
                               If vTempEvent = Nil Then
                                Begin
                                 vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions);
                                 If vTempContext <> Nil Then
                                  vNeedAuthorization := vTempContext.NeedAuthorization
                                 Else
                                  vNeedAuthorization := True;
                                End
                               Else
                                vNeedAuthorization := vTempEvent.NeedAuthorization;
                               If vNeedAuthorization Then
                                Begin
                                 vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                 vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                 If DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                  vToken         := DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                                 Else
                                  Begin
                                  {$IFNDEF FPC}
                                   {$IF Defined(HAS_FMX)}
                                    {$IFDEF HAS_UTF8}
                                     If Assigned({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}) Then
                                      vToken       := TRDWAuthRequest({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                     If Trim(vToken) <> '' Then
                                      Begin
                                       aToken      := GetTokenString(vToken);
                                       If aToken = '' Then
                                        aToken     := GetBearerString(vToken);
                                       vToken      := aToken;
                                      End;
                                    {$ELSE}
                                     If Assigned(AContext.DataObject) Then
                                      vToken       := TRDWAuthRequest(AContext.DataObject).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                     If Trim(vToken) <> '' Then
                                      Begin
                                       aToken      := GetTokenString(vToken);
                                       If aToken = '' Then
                                        aToken     := GetBearerString(vToken);
                                       vToken      := aToken;
                                      End;
                                    {$ENDIF}
                                   {$ELSE}
                                    If Assigned(AContext.Data) Then
                                     vToken       := TRDWAuthRequest(AContext.Data).Token
                                    Else
                                     vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                    If Trim(vToken) <> '' Then
                                     Begin
                                      aToken      := GetTokenString(vToken);
                                      If aToken = '' Then
                                       aToken     := GetBearerString(vToken);
                                      vToken      := aToken;
                                     End;
                                   {$IFEND}
                                  {$ELSE}
                                   If Assigned(AContext.Data) Then
                                    vToken       := TRDWAuthRequest(AContext.Data).Token
                                   Else
                                    vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                   If Trim(vToken) <> '' Then
                                    Begin
                                     aToken      := GetTokenString(vToken);
                                     If aToken = '' Then
                                      aToken     := GetBearerString(vToken);
                                     vToken      := aToken;
                                    End;
                                  {$ENDIF}
                                  End;
                                 If Not vAuthTokenParam.FromToken(vToken) Then
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End
                                 Else
                                  vTokenValidate := False;
                                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth) Then
                                  Begin
                                   TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth(vWelcomeMessage, vAccessTag, DWParams,
                                                                                               TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                               vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                   vTokenValidate := Not(vAcceptAuth);
                                   If Not vAcceptAuth Then
                                    Begin
                                     WriteError;
                                     DestroyComponents;
                                     Exit;
                                    End;
                                  End;
                                End
                               Else
                                vTokenValidate := False;
                              End;
                            End;
              rdwAOToken  : Begin
                             vUrlToken := Lowercase(vUriOptions.EventName);
                             If vUrlToken =
                                Lowercase(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                              Begin
                               vGettoken      := True;
                               vErrorCode     := 404;
                               vErrorMessage  := cEventNotFound;
                               If (RequestTypeToRoute(RequestType) In TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                                  (crAll in TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                                Begin
                                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                                  Begin
                                   vTokenValidate := True;
                                   vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                   vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                  {$IFNDEF FPC}
                                   {$IF Defined(HAS_FMX)}
                                    {$IFDEF HAS_UTF8}
                                     If Assigned({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}) Then
                                      vToken       := TRDWAuthRequest({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                    {$ELSE}
                                     If Assigned(AContext.Data) Then
                                      vToken       := TRDWAuthRequest(AContext.Data).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                    {$ENDIF}
                                   {$ELSE}
                                    If Assigned(AContext.Data) Then
                                     vToken       := TRDWAuthRequest(AContext.Data).Token
                                    Else
                                     vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                   {$IFEND}
                                  {$ELSE}
                                   If Assigned(AContext.Data) Then
                                    vToken       := TRDWAuthRequest(AContext.Data).Token
                                   Else
                                    vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                  {$ENDIF}
                                   If DWParams.ItemsString['RDWParams'] <> Nil Then
                                    Begin
                                     DWParamsD := TDWParams.Create;
                                     DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                                     TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParamsD,
                                                                                            TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                            vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                     FreeAndNil(DWParamsD);
                                    End
                                   Else
                                    TServerMethodDatamodule(vTempServerMethods).OnGetToken(vWelcomeMessage, vAccessTag, DWParams,
                                                                                           TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                           vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                   If Not vAcceptAuth Then
                                    Begin
                                     WriteError;
                                     DestroyComponents;
                                     Exit;
                                    End;
                                  End
                                 Else
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End;
                                End
                               Else
                                Begin
                                 WriteError;
                                 DestroyComponents;
                                 Exit;
                                End;
                              End
                             Else
                              Begin
                               vErrorCode      := 401;
                               vErrorMessage   := cInvalidAuth;
                               vTokenValidate  := True;
                               vNeedAuthorization := False;
                               vTempEvent   := ReturnEventValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions.EventName, vUriOptions.ServerEvent);
                               If vTempEvent = Nil Then
                                Begin
                                 vTempContext := ReturnContextValidation(TServerMethodDatamodule(vTempServerMethods), vUriOptions);
                                 If vTempContext <> Nil Then
                                  vNeedAuthorization := vTempContext.NeedAuthorization
                                 Else
                                  vNeedAuthorization := True;
                                End
                               Else
                                vNeedAuthorization := vTempEvent.NeedAuthorization;
                               If vNeedAuthorization Then
                                Begin
                                 vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                 vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                                 If DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                                  vToken         := DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                                 Else
                                  Begin
                                  {$IFNDEF FPC}
                                   {$IF Defined(HAS_FMX)}
                                    {$IFDEF HAS_UTF8}
                                     If Assigned({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}) Then
                                      vToken       := TRDWAuthRequest({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                     If Trim(vToken) <> '' Then
                                      Begin
                                       aToken      := GetTokenString(vToken);
                                       If aToken = '' Then
                                        aToken     := GetBearerString(vToken);
                                       vToken      := aToken;
                                      End;
                                    {$ELSE}
                                     If Assigned(AContext.DataObject) Then
                                      vToken       := TRDWAuthRequest(AContext.DataObject).Token
                                     Else
                                      vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                     If Trim(vToken) <> '' Then
                                      Begin
                                       aToken      := GetTokenString(vToken);
                                       If aToken = '' Then
                                        aToken     := GetBearerString(vToken);
                                       vToken      := aToken;
                                      End;
                                    {$ENDIF}
                                   {$ELSE}
                                    If Assigned(AContext.Data) Then
                                     vToken       := TRDWAuthRequest(AContext.Data).Token
                                    Else
                                     vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                    If Trim(vToken) <> '' Then
                                     Begin
                                      aToken      := GetTokenString(vToken);
                                      If aToken = '' Then
                                       aToken     := GetBearerString(vToken);
                                      vToken      := aToken;
                                     End;
                                   {$IFEND}
                                  {$ELSE}
                                   If Assigned(AContext.Data) Then
                                    vToken       := TRDWAuthRequest(AContext.Data).Token
                                   Else
                                    vToken       := ARequestInfo.RawHeaders.Values['Authorization'];
                                   If Trim(vToken) <> '' Then
                                    Begin
                                     aToken      := GetTokenString(vToken);
                                     If aToken = '' Then
                                      aToken     := GetBearerString(vToken);
                                     vToken      := aToken;
                                    End;
                                  {$ENDIF}
                                  End;
                                 If Not vAuthTokenParam.FromToken(vToken) Then
                                  Begin
                                   WriteError;
                                   DestroyComponents;
                                   Exit;
                                  End
                                 Else
                                  vTokenValidate := False;
                                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth) Then
                                  Begin
                                   TServerMethodDatamodule(vTempServerMethods).OnUserTokenAuth(vWelcomeMessage, vAccessTag, DWParams,
                                                                                               TRDWAuthOptionTokenServer(vAuthTokenParam),
                                                                                               vErrorCode, vErrorMessage, vToken, vAcceptAuth);
                                   vTokenValidate := Not(vAcceptAuth);
                                   If Not vAcceptAuth Then
                                    Begin
                                     WriteError;
                                     DestroyComponents;
                                     Exit;
                                    End;
                                  End;
                                End
                               Else
                                vTokenValidate := False;
                              End;
                            End;
             End;
             vErrorCode            := 200;
             vErrorMessage         := '';
            End;
           If Assigned(TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage) then
            TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage, vAccessTag, vdwConnectionDefs, WelcomeAccept, vContentType, vErrorMessage);
          End;
        End
       Else
        Begin
         If vErrorCode <> 400 Then
          Begin
           vErrorCode := 401;
           JSONStr    := GetPairJSON(-5, 'Server Methods Cannot Assigned');
          End;
        End;
      End;
     Try
      If Assigned(vLastRequest) Then
       Begin
        Try
         If Assigned(vLastRequest) Then
          vLastRequest(ARequestInfo.UserAgent + sLineBreak +
                      ARequestInfo.RawHTTPCommand);
        Finally
        End;
       End;
      If Assigned(vServerMethod) Then
       Begin
        If vUriOptions.EventName = '' Then
         Begin
          If {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                           {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                           {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} <> '' Then
           Begin
            vUriOptions.EventName := Trim({$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF});
            If Pos('/', vUriOptions.EventName) > 0 then
             Begin
              vUriOptions.ServerEvent   := Copy(vUriOptions.EventName, 1, Pos('/', vUriOptions.EventName) -1);
              vUriOptions.EventName := Copy(vUriOptions.EventName, Pos('/', vUriOptions.EventName) +1, Length(vUriOptions.EventName));
             End;
           End
          Else
           Begin
            While (Length(vUriOptions.EventName) > 0) Do
             Begin
              If Pos('/', vUriOptions.EventName) > 0 then
               vUriOptions.EventName := Copy(vUriOptions.EventName, InitStrPos +1, Length(vUriOptions.EventName))
              Else
               Begin
                vUriOptions.EventName := Trim(vUriOptions.EventName);
                Break;
               End;
             End;
           End;
         End;
        If (vUriOptions.EventName = '') And (vUriOptions.ServerEvent = '') Then
         vUriOptions.EventName := vOldMethod;
        vSpecialServer := False;
        If vTempServerMethods <> Nil Then
         Begin
          AResponseInfo.ContentType   := 'application/json'; //'text';//'application/octet-stream';
          If (vUriOptions.EventName = '') And (vUriOptions.ServerEvent = '') Then
           Begin
            If vDefaultPage.Count > 0 Then
             vReplyString  := vDefaultPage.Text
            Else
             vReplyString  := TServerStatusHTML;
            vErrorCode   := 200;
            AResponseInfo.ContentType := 'text/html';
           End
          Else
           Begin
            If vEncoding = esUtf8 Then
             AResponseInfo.ContentEncoding       := 'utf-8'
            Else
             AResponseInfo.ContentEncoding       := 'ansi';
            If DWParams <> Nil Then
             Begin
              If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
               dwassyncexec := DWParams.ItemsString['dwassyncexec'].AsBoolean;
              If DWParams.ItemsString['dwusecript'] <> Nil Then
               vdwCriptKey  := DWParams.ItemsString['dwusecript'].AsBoolean;
             End;
            If dwassyncexec Then
             Begin
              AResponseInfo.ResponseNo               := 200;
              vReplyString                           := AssyncCommandMSG;
              {$IFNDEF FPC}
               If compresseddata Then
                mb                                  := TStringStream(ZCompressStreamNew(vReplyString))
               Else
                mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
               mb.Position                          := 0;
               AResponseInfo.FreeContentStream      := True;
               AResponseInfo.ContentStream          := mb;
               AResponseInfo.ContentStream.Position := 0;
               AResponseInfo.ContentLength          := mb.Size;
               AResponseInfo.WriteContent;
              {$ELSE}
               If compresseddata Then
                mb                                  := TStringStream(ZCompressStreamNew(vReplyString)) //TStringStream.Create(Utf8Encode(vReplyStringResult))
               Else
                mb                                  := TStringStream.Create(vReplyString);
               mb.Position                          := 0;
               AResponseInfo.FreeContentStream      := True;
               AResponseInfo.ContentStream          := mb;
               AResponseInfo.ContentStream.Position := 0;
               AResponseInfo.ContentLength          := -1;//mb.Size;
               AResponseInfo.WriteContent;
              {$ENDIF}
             End;
            If DWParams.itemsstring['binaryRequest']        <> Nil Then
             vBinaryEvent := DWParams.itemsstring['binaryRequest'].Value;
            If DWParams.itemsstring['BinaryCompatibleMode'] <> Nil Then
             vBinaryCompatibleMode := DWParams.itemsstring['BinaryCompatibleMode'].Value;
            If DWParams.itemsstring['MetadataRequest']      <> Nil Then
             vMetadata := DWParams.itemsstring['MetadataRequest'].value;
            If (Assigned(DWParams)) And (Assigned(vCripto))        Then
             DWParams.SetCriptOptions(vdwCriptKey, vCripto.Key);
            If (vTempServerMethods.ClassType = TServerMethodDatamodule)             Or
               (vTempServerMethods.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
             Begin
              vServerAuthOptions.CopyServerAuthParams(vRDWAuthOptionParam);
              If AContext.Connection.Socket.Binding.IPVersion = Id_IPv6 Then
               vIPVersion := 'ipv6';
              TServerMethodDatamodule(vTempServerMethods).SetClientInfo(AContext.Connection.Socket.Binding.PeerIP, vIPVersion,
                                                                        ARequestInfo.UserAgent, vUriOptions.EventName, vUriOptions.ServerEvent, AContext.Connection.Socket.Binding.PeerPort);
             End;
            If (Not (vGettoken)) And (Not (vTokenValidate)) Then
             Begin
              If Not ServiceMethods(TComponent(vTempServerMethods), AContext, vUriOptions, DWParams,
                                    JSONStr, JsonMode, vErrorCode,  vContentType, vServerContextCall, ServerContextStream,
                                    vdwConnectionDefs,  EncodeStrings, vAccessTag, WelcomeAccept, RequestType, vMark,
                                    vRequestHeader, vBinaryEvent, vMetadata, vBinaryCompatibleMode, vCompareContext) Or (lowercase(vContentType) = 'application/php') Then
               Begin
                If Not dwassyncexec Then
                 Begin
                  {$IFNDEF FPC}
                   {$IF Defined(HAS_FMX)}
                    {$IFDEF MSWINDOWS}
                     If Assigned(CGIRunner) Then
                      Begin
                       If Pos('.php', UrlMethod) <> 0 then
                        Begin
                         vContentType := 'text/html';
                         LocalDoc := CGIRunner.PHPIniPath + CGIRunner.PHPModule;
                        End;
                       For I := 0 To CGIRunner.CGIExtensions.Count -1 Do
                        Begin
                         If Pos(LowerCase(CGIRunner.CGIExtensions[I]), LowerCase(aRequestInfo.Document)) <> 0 then
                          Begin
                           LocalDoc := ExpandFilename(FRootPath + aRequestInfo.Document);
                           Break;
                          End;
                        End;
                       If LocalDoc <> '' then
                        Begin
                         vSpecialServer := True;
                         If DWFileExists(LocalDoc) Then
                          Begin
                           CGIRunner.Execute(LocalDoc, AContext, aRequestInfo, aResponseInfo, FRootPath, JSONStr);
                           vTagReply := True;
                          End
                         Else
                          Begin
                           aResponseInfo.ContentText := '<H1><center>Script not found</center></H1>';
                           aResponseInfo.ResponseNo := 404; // Not found
                          End;
                        End;
                       End;
                    {$ENDIF}
                   {$ELSE}
                    If Assigned(CGIRunner) Then
                     Begin
                      If Pos('.php', vUriOptions.EventName) <> 0 then
                       Begin
                        vContentType := 'text/html';
                        LocalDoc := CGIRunner.PHPIniPath + CGIRunner.PHPModule;
                       End;
                      For I := 0 To CGIRunner.CGIExtensions.Count -1 Do
                       Begin
                        If Pos(LowerCase(CGIRunner.CGIExtensions[I]), LowerCase(aRequestInfo.Document)) <> 0 then
                         Begin
                          LocalDoc := ExpandFilename(FRootPath + aRequestInfo.Document);
                          Break;
                         End;
                       End;
                      If (LocalDoc <> '') or (lowercase(vContentType) = 'application/php') then
                       Begin
                        vSpecialServer := True;
                        If DWFileExists(LocalDoc, FRootPath) or (lowercase(vContentType) = 'application/php') Then
                         Begin
                          CGIRunner.Execute(LocalDoc, AContext, aRequestInfo, aResponseInfo, FRootPath, JSONStr);
                          vTagReply := True;
                         End
                        Else
                         Begin
                          aResponseInfo.ContentText := '<H1><center>Script not found</center></H1>';
                          aResponseInfo.ResponseNo := 404; // Not found
                         End;
                       End;
                      End;
                   {$IFEND}
                  {$ENDIF}
                  If Not vSpecialServer Then
                   Begin
                    If {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                     {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                     {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} <> '' Then
                     sFile := GetFileOSDir(ExcludeTag(tmp + {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                          {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                          {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF}))
                    Else
                     sFile := GetFileOSDir(ExcludeTag(Cmd));
                    vFileExists := DWFileExists(sFile, FRootPath);
                    If Not vFileExists Then
                     Begin
                      tmp := '';
                      If ARequestInfo.Referer <> '' Then
                       tmp := GetLastMethod(ARequestInfo.Referer);
                      If {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                       {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} <> '' Then
                       sFile := GetFileOSDir(ExcludeTag(tmp + {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                                                                            {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF}))
                      Else
                       sFile := GetFileOSDir(ExcludeTag(Cmd));
                      vFileExists := DWFileExists(sFile, FRootPath);
                     End;
                    vTagReply := vFileExists or scripttags(ExcludeTag(Cmd));
                    If vTagReply Then
                     Begin
                      AResponseInfo.FreeContentStream      := True;
                      AResponseInfo.ContentType            := GetMIMEType(sFile);
                      If scripttags(ExcludeTag(Cmd)) and Not vFileExists Then
                       AResponseInfo.ContentStream         := TMemoryStream.Create
                      Else
                       AResponseInfo.ContentStream         := TIdReadFileExclusiveStream.Create(sFile);
                      AResponseInfo.ContentStream.Position := 0;
                      AResponseInfo.ResponseNo             := 200;
                      AResponseInfo.WriteContent;
                     End;
                   End;
                 End;
               End;
             End
            Else
             Begin
              JSONStr    := vToken;
              JsonMode   := jmPureJSON;
              vErrorCode := 200;
             End;
           End;
         End;
       End;
      Try
       If Assigned(vRequestHeader) Then
        Begin
         vRequestHeader.Clear;
         FreeAndNil(vRequestHeader);
        End;
       If Assigned(vServerMethod) Then
        If Assigned(vTempServerMethods) Then
         Begin
          If TServerMethodDatamodule(vTempServerMethods).QueuedRequest Then
           Begin
            {$IFNDEF FPC}
             {$IF CompilerVersion > 21}
              {$IFDEF WINDOWS}
               If Assigned(vCriticalSection) Then
                Begin
                 LeaveCriticalSection(vCriticalSection);
                 DeleteCriticalSection(vCriticalSection);
                End;
              {$ELSE}
               If Assigned(vCriticalSection) Then
                Begin
                 vCriticalSection.Release;
//                 FreeAndNil(vCriticalSection);
                End;
              {$ENDIF}
             {$ELSE}
              If Assigned(vCriticalSection) Then
               Begin
                vCriticalSection.Release;
                FreeAndNil(vCriticalSection);
               End;
             {$IFEND}
            {$ELSE}
             LeaveCriticalSection(vCriticalSection);
             DoneCriticalSection(vCriticalSection);
            {$ENDIF}
           End;
          Try
           {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
           vTempServerMethods.free;
           {$ELSE}
           vTempServerMethods.free;
           {$ENDIF}
           vTempServerMethods := Nil;
          Except
          End;
         End;
       If Not dwassyncexec Then
        Begin
         If (Not (vTagReply)) Then
          Begin
           If vEncoding = esUtf8 Then
            AResponseInfo.Charset := 'utf-8'
           Else
            AResponseInfo.Charset := 'ansi';
           If vContentType <> '' Then
            AResponseInfo.ContentType := vContentType;
           If Not vServerContextCall Then
            Begin
             If (vUriOptions.EventName <> '') Then
              Begin
               If JsonMode in [jmDataware, jmUndefined] Then
                Begin
                 If Trim(JSONStr) <> '' Then
                  Begin
                   If Not(((Pos('{', JSONStr) > 0)   And
                           (Pos('}', JSONStr) > 0))  Or
                          ((Pos('[', JSONStr) > 0)   And
                           (Pos(']', JSONStr) > 0))) Then
                    Begin
                     If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                       JSONStr := escape_chars(vErrorMessage)
                     Else If Not((JSONStr[InitStrPos] = '"')  And
                            (JSONStr[Length(JSONStr)] = '"')) Then
                      JSONStr := '"' + JSONStr + '"';
                    End;
                  End;
                 If vBinaryEvent Then
                  Begin
                   vReplyString := JSONStr;
                   vErrorCode   := 200;
                  End
                 Else
                  Begin
                   If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                    vReplyString := escape_chars(vErrorMessage)
                   Else
                    vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
                  End;
                End
               Else If JsonMode = jmPureJSON Then
                Begin
                 If (Trim(JSONStr) = '') And (WelcomeAccept) Then
                  vReplyString := '{}'
                 Else If Not (WelcomeAccept) And (vErrorMessage <> '') Then
                  vReplyString := escape_chars(vErrorMessage)
                 Else
                  vReplyString := JSONStr;
                End;
              End;
             If Assigned(DWParams) Then
              Begin
               If DWParams.RequestHeaders.Output.Count > 0 Then
                Begin
                 For I := 0 To DWParams.RequestHeaders.Output.Count -1 Do
                  AResponseInfo.CustomHeaders.Add(DWParams.RequestHeaders.Output[I]);
                End;
              End;
             AResponseInfo.ResponseNo                 := vErrorCode;
             If Assigned(DWParams) And
               (Pos(DWParams.Url_Redirect, Cmd) = 0) And
               (DWParams.Url_Redirect <> '') Then
              AResponseInfo.Redirect(DWParams.Url_Redirect);
             If compresseddata Then
              Begin
               If vBinaryEvent Then
                Begin
                 ms := TStringStream.Create('');
                 If vGettoken Then
                  Begin
                   DWParams.Clear;
                   DWParams.CreateParam('token', vReplyString);
                  End;
                 Try
                  DWParams.SaveToStream(ms, tdwpxt_OUT);
                  ZCompressStreamD(ms, mb2);
                 Finally
                  FreeAndNil(ms);
                 End;
                End
               Else
                mb2                                   := TStringStream(ZCompressStreamNew(vReplyString));
               If vErrorCode <> 200 Then
                Begin
                 If Assigned(mb2) Then
                  FreeAndNil(mb2);
                 AResponseInfo.ResponseText           := escape_chars(vReplyString);
                End
               Else
                Begin
                 AResponseInfo.FreeContentStream      := True;
                 mb2.Position := 0;
                 AResponseInfo.ContentStream          := mb2; //mb;
                End;
               If Assigned(AResponseInfo.ContentStream) Then
                Begin
                 AResponseInfo.ContentStream.Position := 0;
                 AResponseInfo.ContentLength          := AResponseInfo.ContentStream.Size;
                End
               Else
                AResponseInfo.ContentLength           := 0;
              End
             Else
              Begin
               {$IFNDEF FPC}
                {$IF CompilerVersion > 21}
                 If vBinaryEvent Then
                  Begin
                   mb := TStringStream.Create('');
                   Try
                    DWParams.SaveToStream(mb, tdwpxt_OUT);
                   Finally
                   End;
                  End
                 Else
                  mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                 mb.Position                          := 0;
                 AResponseInfo.FreeContentStream      := True;
                 AResponseInfo.ContentStream          := mb;
                 AResponseInfo.ContentStream.Position := 0;
                 AResponseInfo.ContentLength          := mb.Size;
                {$ELSE}
                 If vBinaryEvent Then
                  Begin
                   mb := TStringStream.Create('');
                   Try
                    DWParams.SaveToStream(mb, tdwpxt_OUT);
                   Finally
                   End;
                   AResponseInfo.FreeContentStream      := True;
                   AResponseInfo.ContentStream          := mb;
                   AResponseInfo.ContentStream.Position := 0;
                   AResponseInfo.ContentLength          := mb.Size;
                  End
                 Else
                  Begin
                   AResponseInfo.ContentLength          := -1;
                   AResponseInfo.ContentText            := vReplyString;
                   AResponseInfo.WriteHeader;
                  End;
                {$IFEND}
               {$ELSE}
                If vBinaryEvent Then
                 Begin
                  mb := TStringStream.Create('');
                  Try
                   DWParams.SaveToStream(mb, tdwpxt_OUT);
                  Finally
                  End;
                  AResponseInfo.FreeContentStream       := True;
                  AResponseInfo.ContentStream           := mb;
                  AResponseInfo.ContentStream.Position  := 0;
                  AResponseInfo.ContentLength           := mb.Size;
                 End
                Else
                 Begin
                  If vEncoding = esUtf8 Then
                   mb                                   := TStringStream.Create(Utf8Encode(vReplyString))
                  Else
                   mb                                   := TStringStream.Create(vReplyString);
                  mb.Position                           := 0;
                  AResponseInfo.FreeContentStream       := True;
                  AResponseInfo.ContentStream           := mb;
                  AResponseInfo.ContentStream.Position  := 0;
                  AResponseInfo.ContentLength           := mb.Size;
                  AResponseInfo.WriteHeader;
                 End;
               {$ENDIF}
              End;
            End
           Else
            Begin
             LocalDoc := '';
             If TEncodeSelect(vEncoding) = esUtf8 Then
              AResponseInfo.Charset := 'utf-8'
              Else If TEncodeSelect(vEncoding) in [esANSI, esASCII] Then
              AResponseInfo.Charset := 'ansi';
             If Not vSpecialServer Then
              Begin
               AResponseInfo.ResponseNo             := vErrorCode;
               If ServerContextStream <> Nil Then
                Begin
                 AResponseInfo.FreeContentStream        := True;
                 AResponseInfo.ContentStream            := ServerContextStream;
                 AResponseInfo.ContentStream.Position   := 0;
                 AResponseInfo.ContentLength            := ServerContextStream.Size;
                End
               Else
                Begin
                 {$IFDEF FPC}
                   If vEncoding = esUtf8 Then
                    mb                                  := TStringStream.Create(Utf8Encode(JSONStr))
                   Else
                    mb                                  := TStringStream.Create(JSONStr);
                  mb.Position                           := 0;
                  AResponseInfo.FreeContentStream       := True;
                  AResponseInfo.ContentStream           := mb;
                  AResponseInfo.ContentStream.Position  := 0;
                  AResponseInfo.ContentLength           := -1;//mb.Size;
                 {$ELSE}
                  {$IF CompilerVersion > 21}
                   mb                                   := TStringStream.Create(JSONStr{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                   mb.Position                          := 0;
                   AResponseInfo.FreeContentStream      := True;
                   AResponseInfo.ContentStream          := mb;
                   AResponseInfo.ContentStream.Position := 0;
                   AResponseInfo.ContentLength          := mb.Size;
                  {$ELSE}
                   AResponseInfo.ContentLength          := -1;
                   AResponseInfo.ContentText            := JSONStr;
                  {$IFEND}
                 {$ENDIF}
                End;
              End;
            End;
            If Not AResponseInfo.HeaderHasBeenWritten Then
             If AResponseInfo.CustomHeaders.Count > 0 Then
              AResponseInfo.WriteHeader;
            If Not (vBinaryEvent) Then
             If (Assigned(AResponseInfo.ContentStream)) Then
              If AResponseInfo.ContentStream.size > 0   Then
               AResponseInfo.WriteContent;
          End;
        End;
      Finally
//        FreeAndNil(mb);
      End;
      If Assigned(vLastResponse) Then
       Begin
        Try
         vLastResponse(vReplyString);
        Finally
        End;
       End;
     Finally
      If Assigned(vServerMethod) Then
       If Assigned(vTempServerMethods) Then
        Begin
         Try
          {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
          {$ELSE}
          FreeAndNil(vTempServerMethods); //.free;
          {$ENDIF}
          vTempServerMethods := Nil;
         Except
         End;
        End;
     End;
   End;
 Finally
  DestroyComponents;
 End;
End;

Procedure TRESTServicePooler.aCommandOther(AContext      : TIdContext;
                                           ARequestInfo  : TIdHTTPRequestInfo;
                                           AResponseInfo : TIdHTTPResponseInfo);
Begin
 aCommandGet(AContext, ARequestInfo, AResponseInfo);
end;

{$IFDEF FPC}
{$ELSE}
{$IF Defined(HAS_FMX)}
{$IFDEF WINDOWS}
Procedure TRESTServicePooler.SetISAPIRunner(Value : TDWISAPIRunner);
Begin
 If Assigned(vDWISAPIRunner) And (Value = Nil) Then
  vDWISAPIRunner.Server := Nil;
 vDWISAPIRunner := Value;
 If Assigned(vDWISAPIRunner) Then
  vDWISAPIRunner.Server := HTTPServer;
 If vDWISAPIRunner <> Nil then
  vDWISAPIRunner.FreeNotification(Self);
End;

Procedure TRESTServicePooler.SetCGIRunner  (Value : TDWCGIRunner);
Begin
 If Assigned(vDWCGIRunner) And (Value = Nil) Then
  vDWCGIRunner.Server := Nil;
 vDWCGIRunner := Value;
 If Assigned(vDWCGIRunner) Then
   vDWCGIRunner.Server := HTTPServer;
 If vDWCGIRunner <> Nil    Then
   vDWCGIRunner.FreeNotification(Self);
End;
{$ENDIF}
{$ELSE}
Procedure TRESTServicePooler.SetISAPIRunner(Value : TDWISAPIRunner);
Begin
 If Assigned(vDWISAPIRunner) And (Value = Nil) Then
  vDWISAPIRunner.Server := Nil;
 vDWISAPIRunner := Value;
 If Assigned(vDWISAPIRunner) Then
  vDWISAPIRunner.Server := HTTPServer;
 If vDWISAPIRunner <> Nil    Then
  vDWISAPIRunner.FreeNotification(Self);
End;

Procedure TRESTServicePooler.SetCGIRunner  (Value : TDWCGIRunner);
Begin
 If Assigned(vDWCGIRunner) And (Value = Nil) Then
  vDWCGIRunner.Server := Nil;
 vDWCGIRunner := Value;
 If Assigned(vDWCGIRunner) Then
  vDWCGIRunner.Server := HTTPServer;
 If vDWCGIRunner <> Nil Then
  vDWCGIRunner.FreeNotification(Self);
End;
{$IFEND}
{$ENDIF}

Procedure TRESTServicePooler.SetServerAuthOptions(AuthenticationOptions : TRDWServerAuthOptionParams);
Begin
 If AuthenticationOptions <> Nil Then
  vServerAuthOptions := AuthenticationOptions;
End;

Procedure TRESTServicePooler.OnParseAuthentication(AContext    : TIdContext;
                                                   Const AAuthType, AAuthData: String;
                                                   Var VUsername, VPassword: String; Var VHandled: Boolean);
Var
 vAuthValue : TRDWAuthRequest;
Begin
  {$IFNDEF FPC}
   {$IF Not Defined(HAS_FMX)}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.Data        = Nil) Then
     Begin
      vAuthValue       := TRDWAuthRequest.Create;
      vAuthValue.Token := AAuthType + ' ' + AAuthData;
      AContext.Data    := vAuthValue;
      VHandled         := vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
   {$ELSE}
    {$IFDEF HAS_UTF8}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       ({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}  = Nil) Then
     Begin
      vAuthValue          := TRDWAuthRequest.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}       := vAuthValue;
      VHandled            := vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ELSE}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.DataObject  = Nil) Then
     Begin
      vAuthValue          := TRDWAuthRequest.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      AContext.DataObject := vAuthValue;
      VHandled            := vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ENDIF}
   {$IFEND}
  {$ELSE}
   If (Lowercase(AAuthType) = Lowercase('bearer')) Or
      (Lowercase(AAuthType) = Lowercase('token'))  And
      (AContext.Data        = Nil) Then
    Begin
     vAuthValue       := TRDWAuthRequest.Create;
     vAuthValue.Token := AAuthType + ' ' + AAuthData;
     AContext.Data    := vAuthValue;
     VHandled         := vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
    End;
  {$ENDIF}
End;

Procedure TRESTServicePooler.CreatePostStream(AContext        : TIdContext;
                                              AHeaders        : TIdHeaderList;
                                              Var VPostStream : TStream);
Var
 headerIndex : Integer;
 vValueAuth  : String;
 vAuthValue  : TRDWAuthRequest;
Begin
 headerIndex := AHeaders.IndexOfName('Authorization');
 If (headerIndex = -1) Then
  Begin
   {$IFNDEF FPC}
    {$IF Not Defined(HAS_FMX)}
     AContext.Data := Nil; // not an Authorization attempt
    {$ELSE}
     {$IFDEF HAS_UTF8}
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := Nil;
     {$ELSE}
      AContext.DataObject := Nil;
     {$ENDIF}
    {$IFEND}
   {$ELSE}
    AContext.Data := Nil; // not an Authorization attempt
   {$ENDIF}
   Exit;
  End
 Else
  Begin
   vValueAuth  := AHeaders[headerIndex];
   If vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken] Then
    Begin
     vAuthValue       := TRDWAuthRequest.Create;
     vAuthValue.Token := vValueAuth;
     {$IFNDEF FPC}
      {$IF Not Defined(HAS_FMX)}
       AContext.Data  := vAuthValue;
      {$ELSE}
       {$IFDEF HAS_UTF8}
        {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := vAuthValue;
       {$ELSE}
        AContext.DataObject := vAuthValue;
       {$ENDIF}
      {$IFEND}
     {$ELSE}
      AContext.Data   := vAuthValue;
     {$ENDIF}
     AHeaders.Delete(headerIndex);
    End;
  End;
End;

Procedure TRESTServicePooler.ClearDataRoute;
Begin
 vDataRouteList.ClearList;
End;

Procedure TRESTServicePooler.AddDataRoute(DataRoute : String; MethodClass : TComponentClass);
Var
 vDataRoute : TRESTDWDataRoute;
Begin
 vDataRoute                   := TRESTDWDataRoute.Create;
 vDataRoute.DataRoute         := DataRoute;
 vDataRoute.ServerMethodClass := MethodClass;
 vDataRouteList.Add(vDataRoute);
End;

Constructor TRESTServicePooler.Create(AOwner: TComponent);
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
 HTTPServer                      := TIdHTTPServer.Create(Nil);
 lHandler                        := TIdServerIOHandlerSSLOpenSSL.Create;
 {$IFDEF FPC}
 HTTPServer.OnQuerySSLPort       := @IdHTTPServerQuerySSLPort;
 HTTPServer.OnCommandGet         := @aCommandGet;
 HTTPServer.OnCommandOther       := @aCommandOther;
 HTTPServer.OnConnect            := @CustomOnConnect;
 HTTPServer.OnCreatePostStream   := @CreatePostStream;
 HTTPServer.OnParseAuthentication := @OnParseAuthentication;
 vDatabaseCharSet                := csUndefined;
 {$ELSE}
 HTTPServer.OnQuerySSLPort       := IdHTTPServerQuerySSLPort;
 HTTPServer.OnCommandGet         := aCommandGet;
 HTTPServer.OnCommandOther       := aCommandOther;
 HTTPServer.OnConnect            := CustomOnConnect;
 HTTPServer.OnCreatePostStream   := CreatePostStream;
 HTTPServer.OnParseAuthentication := OnParseAuthentication;
 {$ENDIF}
 vCipherList                     := '';//'TLSv1:TLSv1.2:SSLv3:!RC4:!NULL-MD5:!NULL-SHA:!NULL-SHA256:!DES-CBC-SHA:!DES-CBC3-SHA:!IDEA-CBC-SHA';
 vServerAuthOptions              := TRDWServerAuthOptionParams.Create(Self);
 vActive                         := False;
 vServerAuthOptions.AuthorizationOption                        := rdwAOBasic;
 TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username := 'testserver';
 TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password := 'testserver';
 vServerContext                  := '';
 vEncoding                       := esUtf8;
 vServicePort                    := 8082;
 vForceWelcomeAccess             := False;
 vCORS                           := False;
 vPathTraversalRaiseError        := True;
 FRootPath                       := '/';
 vASSLRootCertFile               := '';
 aDefaultUrl                     := '';
 HTTPServer.MaxConnections       := -1;
 vServiceTimeout                 := -1;
End;

Procedure TRESTServicePooler.CustomOnConnect(AContext : TIdContext);
Begin
 AContext.Connection.Socket.ReadTimeout := vServiceTimeout;
End;

Destructor TRESTServicePooler.Destroy;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   If Assigned(vCriticalSection) Then
    FreeAndNil(vCriticalSection);
  {$IFEND}
 {$ENDIF}
 HTTPServer.Active := False;
 FreeAndNil(vProxyOptions);
 FreeAndNil(vCripto);
 FreeAndNil(vDefaultPage);
 FreeAndNil(vCORSCustomHeaders);
 FreeAndNil(vDataRouteList);
 If Assigned(vServerAuthOptions) Then
  FreeAndNil(vServerAuthOptions);
 FreeAndNil(lHandler);
 FreeAndNil(HTTPServer);
 Inherited;
End;

Function TRESTServicePooler.GetSecure : Boolean;
Begin
 Result:= vActive And (HTTPServer.IOHandler is TIdServerIOHandlerSSLBase);
End;

Procedure TRESTServicePooler.GetSSLPassWord(var Password: {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                                                     AnsiString
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$IFEND}
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$ENDIF});
Begin
 Password := aSSLPrivateKeyPassword;
End;

Procedure TRESTServicePooler.SetActive(Value : Boolean);
Begin
 If (Value)                   And
    (Not (HTTPServer.Active)) Then
  Begin
   Try
    If (ASSLPrivateKeyFile <> '')     And
       (ASSLPrivateKeyPassword <> '') And
       (ASSLCertFile <> '')           Then
     Begin
      lHandler.SSLOptions.Method                := aSSLMethod;
      {$IFDEF FPC}
      lHandler.SSLOptions.SSLVersions           := aSSLVersions;
      lHandler.OnGetPassword                    := @GetSSLPassword;
      lHandler.OnVerifyPeer                     := @SSLVerifyPeer;
      {$ELSE}
       {$IF Not(DEFINED(OLDINDY))}
        lHandler.SSLOptions.SSLVersions         := aSSLVersions;
        lHandler.OnVerifyPeer                   := SSLVerifyPeer;
       {$IFEND}
      lHandler.OnGetPassword                    := GetSSLPassword;
      {$ENDIF}
      lHandler.SSLOptions.CertFile              := ASSLCertFile;
      lHandler.SSLOptions.KeyFile               := ASSLPrivateKeyFile;
      lHandler.SSLOptions.VerifyMode            := vSSLVerifyMode;
      lHandler.SSLOptions.VerifyDepth           := vSSLVerifyDepth;
      lHandler.SSLOptions.RootCertFile          := vASSLRootCertFile;
      lHandler.SSLOptions.Mode                  := vSSLMode;
      lHandler.SSLOptions.CipherList            := vCipherList;
      HTTPServer.IOHandler := lHandler;
     End
    Else
     HTTPServer.IOHandler  := Nil;
    If HTTPServer.Bindings.Count > 0 Then
     HTTPServer.Bindings.Clear;
    HTTPServer.Bindings.DefaultPort := ServicePort;
    HTTPServer.DefaultPort          := vServicePort;
    HTTPServer.Active               := True;
   Except
    On E : Exception do
     Begin
      Raise Exception.Create(PChar(E.Message));
     End;
   End;
  End
 Else If Not(Value) Then
  Begin
   If HTTPServer.Active Then
    Begin
     HTTPServer.Contexts.LockList;
     Try
      HTTPServer.Contexts.ClearAndFree;
     Finally
      HTTPServer.Contexts.UnlockList;
     End;
    End;
   HTTPServer.Active := False;
  End;
 vActive := HTTPServer.Active;
End;

Procedure TRESTServicePooler.Loaded;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

Procedure TRESTServicePooler.SetServerMethod(Value : TComponentClass);
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

Function  TRESTServicePooler.SSLVerifyPeer (Certificate : TIdX509; AOk : Boolean; ADepth, AError : Integer) : Boolean;

Begin
 If ADepth = 0 Then
  Result := AOk
 Else
  Result := True;
End;

Procedure TRESTDWServiceNotification.Connect(AContext : TIdContext);
Var
 RESTDwSession : TRESTDwSession;
Begin
 RESTDwSession                 := TRESTDwSession.Create;
 RESTDwSession.Connection      := AContext.Connection.Socket.Binding.PeerIP + ':' + IntToStr(AContext.Connection.Socket.Binding.PeerPort);
 RESTDwSession.Socket          := AContext;
 {$IFNDEF FPC}
  {$IF Not Defined(HAS_FMX)}
   AContext.Data               := RESTDwSession;
  {$ELSE}
   {$IFDEF HAS_UTF8}
    {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := RESTDwSession;
   {$ELSE}
    AContext.DataObject        := RESTDwSession;
   {$ENDIF}
  {$IFEND}
 {$ELSE}
  AContext.Data                := RESTDwSession;
 {$ENDIF}
 RESTDwSession.vInitalRequest  := Now;
 RESTDwSession.vLastRequest    := RESTDwSession.vInitalRequest;
 RESTDwSession.OnSessionError  := vRESTDwSessionError;
 RESTDwSession.vLogged         := Not (vServerAuthOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken]);
 If RESTDwSession.vLogged Then
  Begin
   RESTDwSession.vClientStage  := csLoggedIn;
   RESTDwSession.SendString(Format(TTagParams, [cConnectionRename]) + RESTDwSession.Connection);
   If vLoginMessage <> '' Then
    RESTDwSession.SendString(vLoginMessage);
  End
 Else
  RESTDwSession.vClientStage    := csNone;
 If Assigned(vOnConnect) Then
  vOnConnect(TRESTDwSessionData(RESTDwSession));
End;

Procedure TRESTDWServiceNotification.Disconnect(AContext : TIdContext);
Begin
 {$IFNDEF FPC}
  {$IF Not Defined(HAS_FMX)}
 If Assigned(AContext.Data) Then
  {$ELSE}
   {$IFDEF HAS_UTF8}
    If Assigned({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}) Then
   {$ELSE}
    If Assigned(AContext.DataObject) Then
   {$ENDIF}
  {$IFEND}
 {$ELSE}
 If Assigned(AContext.Data) Then
 {$ENDIF}
  Begin
   {$IFNDEF FPC}
    {$IF Not Defined(HAS_FMX)}
     If Assigned(vOnDisconnect) Then
      vOnDisconnect(TRESTDwSessionData(TRESTDwSession(AContext.Data)));
     TRESTDwSession(AContext.Data).Free;
     AContext.Data        := Nil;
    {$ELSE}
     {$IFDEF HAS_UTF8}
      If Assigned(vOnDisconnect) Then
       vOnDisconnect(TRESTDwSessionData(TRESTDwSession({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND})));
      TRESTDwSession({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}).DisposeOf;
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := Nil;
     {$ELSE}
      If Assigned(vOnDisconnect) Then
       vOnDisconnect(TRESTDwSessionData(TRESTDwSession(AContext.DataObject)));
      TRESTDwSession(AContext.DataObject).DisposeOf;
      AContext.DataObject := Nil;
     {$ENDIF}
    {$IFEND}
   {$ELSE}
    If Assigned(vOnDisconnect) Then
     vOnDisconnect(TRESTDwSessionData(TRESTDwSession(AContext.Data)));
    TRESTDwSession(AContext.Data).Free;
    AContext.Data         := Nil;
   {$ENDIF}
  End;
End;

Constructor TRESTDWServiceNotification.Create(AOwner : TComponent);
Begin
 Inherited;
 vGarbageTime               := 60000;
 vServiceTimeout            := 5000;
 vServicePort               := 9092;
 vForceWelcomeAccess        := False;
 vSessions                  := TRESTDwSessionsList.Create(Self, TRESTDwSession);
 vServerAuthOptions         := TRDWServerAuthOptionParams.Create(Self);
 vCripto                    := TCripto.Create;
 vServerAuthOptions.AuthorizationOption := rdwAONone;
 vIdTCPServer               := TIdTCPServer.Create(Nil);
 {$IFDEF FPC}
  vIdTCPServer.OnExecute    := @Execute;
  vIdTCPServer.OnDisconnect := @Disconnect;
  vIdTCPServer.OnConnect    := @Connect;
  vEncoding                 := esUtf8;
  vDatabaseCharSet          := csUndefined;
 {$ELSE}
  vIdTCPServer.OnExecute    := Execute;
  vIdTCPServer.OnDisconnect := Disconnect;
  vIdTCPServer.OnConnect    := Connect;
  {$IF CompilerVersion > 21}
   vEncoding                := esUtf8;
  {$ELSE}
   vEncoding                := esAscii;
  {$IFEND}
 {$ENDIF}
 vLoginMessage              := '';
 vRESTDwAuthError           := Nil;
 vNotifyWelcomeMessage      := Nil;
 vRESTDwSessionError        := Nil;
 vLastRequest               := Nil;
 vLastResponse              := Nil;
End;

Procedure TRESTDWServiceNotification.Delete(Index      : Integer);
Begin
 If (Index < Self.Sessions.Count) And (Index > -1) Then
  TOwnedCollection(Self.Sessions).Delete(Index);
End;

Procedure TRESTDWServiceNotification.BroadcastStream (Var aStream    : TMemoryStream);
Var
 I : Integer;
Begin
 Try
  For I := Sessions.Count - 1 Downto 0 Do
   Begin
    Sessions.Items[I].SendString(Format(TTagParams, [cServerStream]));
    Sessions.Items[I].SendStream(aStream);
   End;
 Finally
  Sessions.Clear;
 End;
End;

Procedure TRESTDWServiceNotification.BroadcastMessage(aMessage: String);
Var
 I : Integer;
Begin
 Try
  For I := Sessions.Count - 1 Downto 0 Do
   Sessions.Items[I].SendString(Format(TTagParams, [cServerMessage]) + aMessage, True);
 Finally
  Sessions.Clear;
 End;
End;

Function TRESTDWServiceNotification.SendMessage(aUser,
                                                aMessage         : String;
                                                Var ErrorMessage : String) : Boolean;
Var
 I            : Integer;
 vDwSession   : TRESTDwSession;
Begin
 Result       := False;
 ErrorMessage := '';
 Try
  For I := Sessions.Count - 1 Downto 0 Do
   Begin
    vDwSession := Sessions.Items[I];
    Result     := aUser = vDwSession.Connection;
    If Result Then
     Begin
      Try
       Sessions.Items[I].SendString(Format(TTagParams, [cServerMessage]) + aMessage, True);
      Except
       ErrorMessage := 'User can''t accept message';
      End;
      Break;
     End;
   End;
 Finally
  Sessions.Clear;
  If (Not (Result) And (ErrorMessage <> '')) Then
   ErrorMessage := 'Invalid user to sendmessage';
 End;
End;

Function TRESTDWServiceNotification.SendStream(aUserSource,
                                               aUserDest        : String;
                                               Var aStream      : TMemoryStream;
                                               Var ErrorMessage : String) : Boolean;
Var
 I            : Integer;
 vDwSession   : TRESTDwSession;
Begin
 Result       := False;
 ErrorMessage := '';
 Try
  For I := Sessions.Count - 1 Downto 0 Do
   Begin
    vDwSession := Sessions.Items[I];
    Result     := aUserDest = vDwSession.Connection;
    If Result Then
     Begin
      Try
       Sessions.Items[I].SendBytes(ToBytes(Format(TTagParams, [cUserStream]) + aUserSource), True);
       aStream.Position := 0;
//       aStream.Read(Pointer(aBuf)^, Length(aBuf));
       Sessions.Items[I].SendStream(aStream);
      Except
       ErrorMessage := 'User can''t accept message';
      End;
      Break;
     End;
   End;
 Finally
  Sessions.Clear;
  If (Not (Result) And (ErrorMessage <> '')) Then
   ErrorMessage := 'Invalid user to sendmessage';
 End;
End;

Procedure TRESTDWServiceNotification.ClearList;
Var
 I : Integer;
Begin
 Try
  For I := Self.Sessions.Count - 1 Downto 0 Do
   Self.Sessions.Delete(I);
 Finally
  Self.Sessions.Clear;
 End;
End;

Destructor TRESTDWServiceNotification.Destroy;
Begin
 vIdTCPServer.Active := False;
 ClearList;
 FreeAndNil(vSessions);
 FreeAndNil(vServerAuthOptions);
 FreeAndNil(vCripto);
 FreeAndNil(vIdTCPServer);
 Inherited;
End;

Procedure TRESTDWServiceNotification.Execute        (AContext : TIdContext);
Var
 vReplyStr,
 vUsername,
 vError,
 vNewName,
 InCmd      : String;
 vDwSession : TRESTDwSession;
 aBuf       : TIdBytes;
 aStream    : TMemoryStream;
 aSize      : DWInt64;
 {$IFNDEF FPC}
   {$IF (DEFINED(OLDINDY))}
    LEncoding : TIdTextEncoding
   {$ELSE}
    LEncoding : IIdTextEncoding
   {$IFEND}
 {$ELSE}
  LEncoding : IIdTextEncoding
 {$ENDIF};
 Function GetConnectionName(Value : String) : String;
 Begin
  Result := StringReplace(Value, Format(TTagParams, [cConnectionRename]), '', [rfReplaceAll]);
 End;
 Procedure ReceiveStreamClient;
 Var
  aBuf  : TIdBytes;
  bSize : DWInt64;
 Begin
  SetLength(aBuf, 0);
  vDwSession.vAContext.Connection.IOHandler.ReadTimeout := -1;
  vDwSession.vAContext.Connection.IOHandler.ReadBytes(aBuf, SizeOf(DWInt64));
  aSize := PDWInt64(@aBuf[0])^;
  bSize := 0;
  While aSize > bSize Do
   Begin
    SetLength(aBuf, 0);
    vDwSession.vAContext.Connection.IOHandler.ReadBytes(aBuf, aSize);
    aStream.Write(aBuf[0], Length(aBuf));
    bSize := aStream.Size;
   End;
  SetLength(aBuf, 0);
  aStream.Position := 0;
 End;
Begin
 ProcessMessages;
 vReplyStr := '';
  {$IFNDEF FPC}
   {$IF (DEFINED(OLDINDY))}
    LEncoding := enDefault;
   {$ELSE}
    LEncoding := IndyTextEncoding_UTF8;
   {$IFEND}
  {$ELSE}
   LEncoding := IndyTextEncoding_UTF8;
  {$ENDIF};
 {$IFNDEF FPC}
  {$IF Not Defined(HAS_FMX)}
   vDwSession := TRESTDwSession(AContext.Data);
  {$ELSE}
   {$IFDEF HAS_UTF8}
    vDwSession := TRESTDwSession({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND});
   {$ELSE}
    vDwSession := TRESTDwSession(AContext.DataObject);
   {$ENDIF}
  {$IFEND}
 {$ELSE}
  vDwSession := TRESTDwSession(AContext.Data);
 {$ENDIF}
 Try
  If Assigned(vDwSession) Then
   Begin
    If vDwSession.Socket.Connection.IOHandler.InputBuffer.Size > 0 Then
     Begin
      vDwSession.Socket.Connection.IOHandler.InputBuffer.ExtractToBytes(aBuf);
      vDwSession.Socket.Connection.IOHandler.InputBuffer.Clear;
      vDwSession.Socket.Connection.IOHandler.ReadTimeout := vServiceTimeout;
      If Length(aBuf) > 0 Then
       Begin
        If Not(Length(aBuf) = 0) Then
         Begin
          InCmd := BytesToString(aBuf, LEncoding);
          SetLength(aBuf, 0);
         End;
       End;
     End;
   End;
  vDwSession.Socket.Connection.IOHandler.ReadTimeout := vServiceTimeout;
  If InCmd <> '' Then
   Begin
    Case vDwSession.ClientStage Of
     csNone     : Begin //LOGIN username password
//                   If (Pos('LOGIN', uppercase(InCmd)) = 1) Then
//                    vDwSession.CMD_LOGIN    (Copy(InCmd, Pos(' ', InCmd) + 1, maxint))
//                   Else
//                    vDwSession.SendString   ('ERROR Not logged in. Can not use "' + InCmd +'" command');
//                    RESTDwSession.vClientStage  := csLoggedIn;
//                    If vLoginMessage = '' Then
//                     RESTDwSession.SendString(Format(cWelcomeUser, [RESTDwSession.Connection]))
//                    Else
//                     RESTDwSession.SendString(vLoginMessage);
                  End;
     csLoggedIn : Begin
                   If Pos(Format(TTagParams, [cPing]), InCmd) > 0 Then
                    vDwSession.SendString (cPong)
                   Else If Pos(Format(TTagParams, [cConnectionRename]), InCmd) > 0 Then
                    Begin
                     vNewName := GetConnectionName(InCmd);
                     If Assigned(vOnConnectionRename) Then
                      vOnConnectionRename(vDwSession, vDwSession.Connection, vNewName);
                     vDwSession.Connection := vNewName;
                     vDwSession.SendString(Format(TTagParams, [cConnectionRename]) + vDwSession.Connection);
                     vNewName := '';
                    End
                   Else If Pos(Format(TTagParams, [cServerMessage]), InCmd) > 0 Then
                    Begin
                     InCmd := StringReplace(InCmd, Format(TTagParams, [cServerMessage]), '', [rfReplaceAll, rfIgnoreCase]);
                     If Assigned(vReceiveMessage) Then
                      vReceiveMessage(vDwSession, InCmd);
                    End
                   Else If Pos(Format(TTagParams, [cUserMessage]), InCmd) > 0 Then
                    Begin
                     InCmd     := StringReplace(InCmd, Format(TTagParams, [cUserMessage]), '', [rfReplaceAll, rfIgnoreCase]);
                     vUsername := Copy(InCmd, InitStrPos, Pos(';', InCmd) -1);
                     System.Delete(InCmd, InitStrPos, Pos(';', InCmd));
                     If Trim(vUsername) <> '' Then
                      Begin
                       If Not(SendMessage(vUsername, InCmd, vError)) Then
                        vDwSession.SendString(Format(cInvalidMessageTo, [vUsername, InCmd, vError]));
                      End;
                    End
                   Else If Pos(Format(TTagParams, [cServerStream]), InCmd) > 0 Then //Receive Stream to Server
                    Begin
                     aStream    := TMemoryStream.Create;
                     Try
                      ReceiveStreamClient;
                      If Assigned(vReceiveStream) Then
                       vReceiveStream(vDwSession, aStream);
                     Finally
                      FreeAndNil(aStream);
                     End;
                    End
                   Else If Pos(Format(TTagParams, [cUserStream]), InCmd) > 0 Then   //Receive Stream to Redirect From other User
                    Begin
                     InCmd     := StringReplace(InCmd, Format(TTagParams, [cUserStream]), '', [rfReplaceAll, rfIgnoreCase]);
                     vUsername := InCmd;
                     aStream    := TMemoryStream.Create;
                     Try
                      ReceiveStreamClient;
                      If Not(SendStream(vDwSession.Connection, vUsername, aStream, vError)) Then
                       vDwSession.SendString(Format(cInvalidMessageTo, [vUsername, InCmd, vError]));
                     Finally
                      FreeAndNil(aStream);
                     End;
                    End
                   Else If Pos(Format(TTagParams, [cQuit]), InCmd) > 0 Then
                    vDwSession.Socket.Connection.Disconnect
                   Else
                    Begin
                     If InCmd <> '' Then
                      If Assigned(vLastRequest) Then
                       vLastRequest(vDwSession, InCmd);
                      vDwSession.SendString   ('ERROR Unknown command "' + InCmd +'"');
                    End;
                  End;
     csRejected : Begin
                   If Assigned(vDwSession)              Then
                    vDwSession.Socket.Connection.DisconnectNotifyPeer;
                  End;
    End;
   End;
  ProcessMessages;
 Except
  On E : EIdSocketError Do
   Begin
//     If pos('10053', E.Message) > 0 Then
//      ThreadLogMessage(lmtInformation, ldNone, 'Client disconnected')
//     Else
//      ThreadLogMessage(lmtError, ldNone, E.Message);
    Raise;
   End;
  On E : EIdReadTimeout Do ;
  On E : Exception      Do
   Begin
    vDwSession.Socket.Connection.IOHandler.CheckForDisconnect;
    If pos('CONNECTION CLOSED GRACEFULLY', uppercase(e.Message)) > 0 Then
     Begin
      Raise;
     End
    Else
     Begin
      Raise;
     End;
   End;
 End;
 InCmd := '';
End;

Function TRESTDWServiceNotification.GetAccessTag              : String;
Begin
 Result := vAccessTag;
End;

Function TRESTDWServiceNotification.GetSessions               : TRESTDwSessionsList;
Var
 I           : Integer;
 vDwSession,
 vbDwSession : TRESTDwSession;
Begin
 vSessions.Clear;
 If Assigned(vIdTCPServer) Then
  Begin
   With vIdTCPServer.Contexts.LockList Do
    Begin
     Try
      For i := 0 to Count - 1 do
       Begin
        {$IFNDEF FPC}
         {$IF Not Defined(HAS_FMX)}
          vDwSession := TRESTDwSession(TIdContext(Items[i]).Data);
         {$ELSE}
          {$IFDEF HAS_UTF8}
           vDwSession := TRESTDwSession({$IF CompilerVersion > 33}TIdContext(Items[I]).Data{$ELSE}TIdContext(Items[I]).DataObject{$IFEND});
          {$ELSE}
           vDwSession := TRESTDwSession(TIdContext(Items[i]).DataObject);
          {$ENDIF}
         {$IFEND}
        {$ELSE}
         vDwSession := TRESTDwSession(TIdContext(Items[i]).Data);
        {$ENDIF}
        If Assigned(vDwSession) Then
         Begin
          vbDwSession := vSessions.Add;
          vbDwSession.OnSessionError := vDwSession.OnSessionError;
          vbDwSession.Connection     := vDwSession.Connection;
          vbDwSession.Socket         := vDwSession.Socket;
          vbDwSession.SessionToken   := vDwSession.SessionToken;
          vbDwSession.SessionData    := vDwSession.SessionData;
          vbDwSession.UserGroup      := vDwSession.UserGroup;
          vbDwSession.vInitalRequest := vDwSession.InitalRequest;
          vbDwSession.vLastRequest   := vDwSession.LastRequest;
          vbDwSession.vClientStage   := vDwSession.ClientStage;
         End;
       End;
     Finally
      vIdTCPServer.Contexts.UnLockList;
     End;
    End;
  End;
 Result := vSessions;
End;

Procedure TRESTDWServiceNotification.Kickall;
Var
 aCount,
 I          : Integer;
 vDwSession : TRESTDwSession;
Begin
 Try
  aCount := Sessions.Count - 1;
  For I := aCount Downto 0 Do
   Begin
    vDwSession := Sessions.Items[I];
    Try
     vDwSession.Kick(True);
    Except
    End;
   End;
 Finally
  Sessions.Clear;
 End;
End;

Procedure TRESTDWServiceNotification.Kickuser(aUser: String);
Var
 aCount,
 I          : Integer;
 vDwSession : TRESTDwSession;
Begin
 Try
  aCount := Sessions.Count - 1;
  For I := aCount Downto 0 Do
   Begin
    vDwSession := Sessions.Items[I];
    If aUser = vDwSession.Connection Then
     Begin
      vDwSession.Kick;
      Break;
     End;
   End;
 Finally
  Sessions.Clear;
 End;
End;

Procedure TRESTDWServiceNotification.ProcessMessages;
Begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}{$IF Not Defined(HAS_UTF8)}FMX.Forms.TApplication.ProcessMessages;{$IFEND}
  {$ELSE}Application.Processmessages;{$IFEND}
 {$ENDIF}
 Sleep(1);
End;

Procedure TRESTDWServiceNotification.SetAccessTag   (Value    : String);
Begin
 vAccessTag := Value;
End;
Procedure TRESTDWServiceNotification.SetServerMethod     (Value                 : TComponentClass);
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

Procedure TRESTDWServiceNotification.SetServerAuthOptions(AuthenticationOptions : TRDWServerAuthOptionParams);
Begin
 If AuthenticationOptions <> Nil Then
  vServerAuthOptions := AuthenticationOptions;
End;

Procedure TRESTDWServiceNotification.SetActive      (Value : Boolean);
Begin
 vIdTCPServer.DefaultPort := vServicePort;
 If (vIdTCPServer.Active) And (Not (Value)) Then
  Kickall
 Else If Value Then
  vIdTCPServer.Bindings.DefaultPort := vServicePort;
 Try
  If (vIdTCPServer.Active) And (Not (Value)) Then
   Begin
    vIdTCPServer.Bindings.Clear;
    vIdTCPServer.Contexts.Clear;
    Try
     vIdTCPServer.StopListening;
    Finally
     ProcessMessages;
     vIdTCPServer.Active := Value;
    End;
   End
  Else
   vIdTCPServer.Active  := Value;
 Except
  On E : Exception Do
   Raise Exception.Create(E.Message);
 End;
 vActive                   := vIdTCPServer.Active;
End;

Constructor TRESTDwSession.Create;
Begin
 vAContext           := Nil;
 vClientStage        := csNone;
 vDataSource         := '';
 vSessionToken       := '';
 vLastData           := '';
 vUserGroup          := 'ALL';
 vLastRequest        := Now;
 vRESTDwSessionError := Nil;
 vLogged             := False;
 {$IFNDEF FPC}
   {$IF (DEFINED(OLDINDY))}
    vDataEncoding := enDefault;
   {$ELSE}
    vDataEncoding := IndyTextEncoding_UTF8;
   {$IFEND}
 {$ELSE}
  vDataEncoding := IndyTextEncoding_UTF8;
 {$ENDIF};
End;

Procedure TRESTDwSession.Kick(Gracefully : Boolean = False);
Begin
 Try
  If Assigned(vAContext) Then
   Begin
    If Not Gracefully Then
     vAContext.Connection.IOHandler.Close
    Else
     Begin
      vAContext.Connection.IOHandler.CloseGracefully;
      vAContext.Connection.IOHandler.CheckForDisconnect(False, False);
     End;
   End;
 Except
  On e : Exception Do
   Begin
   End;
 End;
End;

Function TRESTDwSession.ReceiveString: String;
Begin
 If Assigned(vAContext) then
  Result := vAContext.Connection.IOHandler.ReadLn;
End;

Procedure TRESTDwSession.ProcessMessages;
Begin
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}{$IF Not Defined(HAS_UTF8)}FMX.Forms.TApplication.ProcessMessages;{$IFEND}
  {$ELSE}Application.Processmessages;{$IFEND}
 {$ENDIF}
 Sleep(1);
End;

Procedure TRESTDwSession.SendBytes (aBuf          : TIdBytes;
                                    WaitReply     : Boolean = False);
Begin
 If Assigned(vAContext) then
  Begin
   vAContext.Connection.IOHandler.Write(aBuf);
   If WaitReply Then
    vAContext.Connection.IOHandler.WriteBufferFlush;
   ProcessMessages;
  End;
End;

Procedure TRESTDwSession.SendStream(Var aStream : TMemoryStream;
                                    WaitReply   : Boolean = False);
Var
 aBuf      : TIdBytes;
 vSizeFile : DWInt64;
 bStream   : TMemoryStream;
Begin
 If Assigned(vAContext) then
  Begin
   SetLength(aBuf, aStream.Size);
   vSizeFile := Length(aBuf);
   bStream   := TMemoryStream.Create;
   Try
    bStream.CopyFrom(aStream, aStream.Size);
    bStream.Position := 0;
    bStream.Read(Pointer(aBuf)^, Length(aBuf));
    vAContext.Connection.IOHandler.Write(ToBytes(vSizeFile), SizeOf(DWInt64)); // ToBytes(IntToStr(), vDataEncoding));
    vAContext.Connection.IOHandler.WriteBufferFlush;
    vAContext.Connection.IOHandler.Write(aBuf);
    vAContext.Connection.IOHandler.WriteBufferFlush;
   Finally
    SetLength(aBuf, 0);
    FreeAndNil(bStream);
    ProcessMessages;
   End;
  End;
End;

Procedure TRESTDwSession.SendString(S         : String;
                                    WaitReply : Boolean = False);
Var
 aBuf : TIdBytes;
Begin
 If Assigned(vAContext) then
  Begin
   aBuf := ToBytes(S, vDataEncoding);
   SendBytes (aBuf, WaitReply);
   SetLength(aBuf, 0);
  End;
End;

Function TRESTDwSessionsList.Add : TRESTDwSession;
Begin
 Result := TRESTDwSession(Inherited Add);
End;

Function TRESTDwSessionsList.Count : Integer;
Begin
 Result := 0;
 If Assigned(TRESTDWServiceNotification(fOwner)) Then
  If Assigned(TRESTDWServiceNotification(fOwner).vIdTCPServer) Then
   If Assigned(TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts) Then
    Result := TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts.Count;
End;

Constructor TRESTDwSessionsList.Create(AOwner     : TPersistent;
                                       aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TRESTDwSession);
 Self.fOwner := AOwner;
End;

Destructor TRESTDwSessionsList.Destroy;
Begin
 Inherited;
End;

Function TRESTDwSessionsList.GetOwner : TPersistent;
Begin
 Result := fOwner;
End;

Procedure TRESTDwSessionsList.PutRec(Index : Integer;
                                     Item  : TRESTDwSession);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

Function TRESTDwSessionsList.GetRec(Index : Integer) : TRESTDwSession;
Begin
 Result := Nil;
 If Assigned(TRESTDWServiceNotification(fOwner)) Then
  If Assigned(TRESTDWServiceNotification(fOwner).vIdTCPServer) Then
   If Assigned(TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts) Then
    If (Index > -1) And (Index < TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts.Count) Then
     Begin
      Try
       With TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts.LockList Do
        Begin
        {$IFNDEF FPC}
         {$IF Not Defined(HAS_FMX)}
          If Assigned(TIdContext(Items[Index]).Data) Then
           Result := TRESTDwSession(TIdContext(Items[Index]).Data);
         {$ELSE}
          {$IFDEF HAS_UTF8}
           If Assigned({$IF CompilerVersion > 33}TIdContext(Items[Index]).Data{$ELSE}TIdContext(Items[Index]).DataObject{$IFEND}) Then
            Result := TRESTDwSession({$IF CompilerVersion > 33}TIdContext(Items[Index]).Data{$ELSE}TIdContext(Items[Index]).DataObject{$IFEND});
          {$ELSE}
           If Assigned(TIdContext(Items[Index]).DataObject) Then
            Result := TRESTDwSession(TIdContext(Items[Index]).DataObject);
          {$ENDIF}
         {$IFEND}
        {$ELSE}
         If Assigned(TIdContext(Items[Index]).Data) Then
          Result := TRESTDwSession(TIdContext(Items[Index]).Data);
        {$ENDIF}
        End;
       TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts.UnLockList;
      Except
      End;
     End;
End;

Function TRESTDwSessionsList.GetRecName(Index: String) : TRESTDwSession;
Var
 I : Integer;
Begin
 Result := Nil;
 If Assigned(TRESTDWServiceNotification(fOwner)) Then
  If Assigned(TRESTDWServiceNotification(fOwner).vIdTCPServer) Then
   If Assigned(TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts) Then
    If (Index <> '') Then
     Begin
      Try
       With TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts.LockList Do
        Begin
         For I := Count -1 Downto 0 Do
          Begin
           {$IFNDEF FPC}
            {$IF Not Defined(HAS_FMX)}
            If Assigned(TIdContext(Items[I]).Data) Then
             Begin
              If (Lowercase(TRESTDwSession(TIdContext(Items[I]).Data).vSessionToken) = Lowercase(Index)) Or
                 (Lowercase(TRESTDwSession(TIdContext(Items[I]).Data).vDataSource)   = Lowercase(Index)) Then
               Begin
                Result := TRESTDwSession(TIdContext(Items[I]).Data);
                Break;
               End;
             End;
            {$ELSE}
             {$IFDEF HAS_UTF8}
              If Assigned({$IF CompilerVersion > 33}TIdContext(Items[I]).Data{$ELSE}TIdContext(Items[I]).DataObject{$IFEND}) Then
               Begin
                If (Lowercase(TRESTDwSession({$IF CompilerVersion > 33}TIdContext(Items[I]).Data{$ELSE}TIdContext(Items[I]).DataObject{$IFEND}).vSessionToken) = Lowercase(Index)) Or
                   (Lowercase(TRESTDwSession({$IF CompilerVersion > 33}TIdContext(Items[I]).Data{$ELSE}TIdContext(Items[I]).DataObject{$IFEND}).vDataSource)   = Lowercase(Index)) Then
                 Begin
                  Result := TRESTDwSession({$IF CompilerVersion > 33}TIdContext(Items[I]).Data{$ELSE}TIdContext(Items[I]).DataObject{$IFEND});
                  Break;
                 End;
               End;
             {$ELSE}
              If Assigned(TIdContext(Items[I]).DataObject) Then
               Begin
                If (Lowercase(TRESTDwSession(TIdContext(Items[I]).DataObject).vSessionToken) = Lowercase(Index)) Or
                   (Lowercase(TRESTDwSession(TIdContext(Items[I]).DataObject).vDataSource)   = Lowercase(Index)) Then
                 Begin
                  Result := TRESTDwSession(TIdContext(Items[I]).DataObject);
                  Break;
                 End;
               End;
             {$ENDIF}
            {$IFEND}
           {$ELSE}
            If Assigned(TIdContext(Items[I]).Data) Then
             Begin
              If (Lowercase(TRESTDwSession(TIdContext(Items[I]).Data).vSessionToken) = Lowercase(Index)) Or
                 (Lowercase(TRESTDwSession(TIdContext(Items[I]).Data).vDataSource)   = Lowercase(Index)) Then
               Begin
                Result := TRESTDwSession(TIdContext(Items[I]).Data);
                Break;
               End;
             End;
           {$ENDIF}
          End;
        End;
       TRESTDWServiceNotification(fOwner).vIdTCPServer.Contexts.UnLockList;
      Except
      End;
     End;
End;

End.


