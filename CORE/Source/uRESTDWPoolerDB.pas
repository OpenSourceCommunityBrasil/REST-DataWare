{
 Esse pacote de Componentes foi desenhado com o Objetivo de ajudar as pessoas a desenvolverem
com WebServices REST o mais próximo possível do desenvolvimento local DB, com componentes de
fácil configuração para que todos tenham acesso as maravilhas dos WebServices REST/JSON DataSnap.

Desenvolvedor Principal : Gilberto Rocha da Silva (XyberX)
Empresa : XyberPower Desenvolvimento
}

unit uRESTDWPoolerDB;

{$I uRESTDW.inc}

interface

uses SysUtils,  Classes,      uDWJSONObject,
     DB,        uRESTDWBase,  uDWPoolerMethod,
     uRESTDWMasterDetailData, uDWConstsData,
     uDWMassiveBuffer,        SyncObjs, uDWJSONTools, udwjson
     {$IFDEF FPC}
     , uDWConsts,             memds;
     {$ELSE}
       {$IFDEF CLIENTDATASET}
        ,  DBClient
       {$ENDIF}
       {$IFDEF RESJEDI}
       , JvMemoryDataset
       {$ENDIF}
       {$IFDEF RESTKBMMEMTABLE}
       , kbmmemtable
       {$ENDIF}
       {$IF CompilerVersion > 21} // Delphi 2010 pra cima
        {$IFDEF RESTFDMEMTABLE}
        , FireDAC.Stan.Intf,  FireDAC.Stan.Option,  FireDAC.Stan.Param,
        FireDAC.Stan.Error,   FireDAC.DatS,         FireDAC.Phys.Intf,
        FireDAC.DApt.Intf,    FireDAC.Comp.DataSet, FireDAC.Comp.Client
        {$ENDIF}
       {$IFEND}, uDWConsts;
     {$ENDIF}

Type
 TOnEventDB               = Procedure (DataSet       : TDataSet)   of Object;
 TOnAfterScroll           = Procedure (DataSet       : TDataSet)   of Object;
 TOnAfterOpen             = Procedure (DataSet       : TDataSet)   of Object;
 TOnAfterClose            = Procedure (DataSet       : TDataSet)   of Object;
 TOnAfterCancel           = Procedure (DataSet       : TDataSet)   of Object;
 TOnAfterInsert           = Procedure (DataSet       : TDataSet)   of Object;
 TOnBeforeDelete          = Procedure (DataSet       : TDataSet)   of Object;
 TOnBeforePost            = Procedure (DataSet       : TDataSet)   of Object;
 TOnAfterPost             = Procedure (DataSet       : TDataSet)   of Object;
 TOnEventConnection       = Procedure (Sucess        : Boolean;
                                       Const Error   : String)     of Object;
 TOnEventBeforeConnection = Procedure (Sender        : TComponent) of Object;
 TOnEventTimer            = Procedure of Object;
 TBeforeGetRecords        = Procedure (Sender        : TObject;
                                       Var OwnerData : OleVariant) of Object;
{$IFDEF  UP_BARBOSA1}
 TOnInBlockEvent          = Procedure (Sender        : TObject;
                                       Const BlockEvent : Boolean) of Object;
{$ENDIF}
Type
 TTimerData = Class(TThread)
 Private
  FValue : Integer;          //Milisegundos para execução
  FLock  : TCriticalSection; //Seção crítica
  vEvent : TOnEventTimer;    //Evento a ser executado
 Public
  Property OnEventTimer : TOnEventTimer Read vEvent Write vEvent; //Evento a ser executado
 Protected
  Constructor Create(AValue: Integer; ALock: TCriticalSection);   //Construtor do Evento
  Procedure   Execute; Override;                                  //Procedure de Execução automática
End;

Type
 TAutoCheckData = Class(TPersistent)
 Private
  vAutoCheck : Boolean;                            //Se tem Autochecagem
  vInTime    : Integer;                            //Em milisegundos o timer
  Timer      : TTimerData;                         //Thread do temporizador
  vEvent     : TOnEventTimer;                      //Evento a executar
  FLock      : TCriticalSection;                   //CriticalSection para execução segura
  Procedure  SetState(Value : Boolean);            //Ativa ou desativa a classe
  Procedure  SetInTime(Value : Integer);           //Diz o Timeout
  Procedure  SetEventTimer(Value : TOnEventTimer); //Seta o Evento a ser executado
 Public
  Constructor Create; //Cria o Componente
  Destructor  Destroy;Override;//Destroy a Classe
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property AutoCheck    : Boolean       Read vAutoCheck Write SetState;      //Se tem Autochecagem
  Property InTime       : Integer       Read vInTime    Write SetInTime;     //Em milisegundos o timer
  Property OnEventTimer : TOnEventTimer Read vEvent     Write SetEventTimer; //Evento a executar
End;


 TProxyOptions = Class(TPersistent)
 Private
  vServer,              //Servidor Proxy na Rede
  vLogin,               //Login do Servidor Proxy
  vPassword : String;   //Senha do Servidor Proxy
  vPort     : Integer;  //Porta do Servidor Proxy
 Public
  Constructor Create;
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property Server   : String  Read vServer   Write vServer;   //Servidor Proxy na Rede
  Property Port     : Integer Read vPort     Write vPort;     //Porta do Servidor Proxy
  Property Login    : String  Read vLogin    Write vLogin;    //Login do Servidor Proxy
  Property Password : String  Read vPassword Write vPassword; //Senha do Servidor Proxy
End;

Type
 TRESTDWDataBase = Class(TComponent)
 Private
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  vOnWork              : TOnWork;
  vOnWorkBegin         : TOnWorkBegin;
  vOnWorkEnd           : TOnWorkEnd;
  vOnStatus            : TOnStatus;
  vWelcomeMessage,
  vLogin,                                            //Login do Usuário caso haja autenticação
  vPassword,                                         //Senha do Usuário caso haja autenticação
  vRestWebService,                                   //Rest WebService para consultas
  vRestURL,                                          //URL do WebService REST
  vRestModule,                                       //Classe Principal do Servidor a ser utilizada
  vMyIP,                                             //Meu IP vindo do Servidor
  vRestPooler          : String;                     //Qual o Pooler de Conexão do DataSet
  vPoolerPort          : Integer;                    //A Porta do Pooler
  vProxy               : Boolean;                    //Diz se tem servidor Proxy
  vProxyOptions        : TProxyOptions;              //Se tem Proxy diz quais as opções
  vEncodeStrings,
  vCompression,                                      //Se Vai haver compressão de Dados
  vConnected           : Boolean;                    //Diz o Estado da Conexão
  vOnEventConnection   : TOnEventConnection;         //Evento de Estado da Conexão
  vOnBeforeConnection  : TOnEventBeforeConnection;   //Evento antes de Connectar o Database
  vAutoCheckData       : TAutoCheckData;             //Autocheck de Conexão
  vTimeOut             : Integer;
  VEncondig            : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vContentex           : String;                    //RestContexto - Alexandre Abade
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len        : Boolean;
  vParamCreate         : Boolean;
  vTypeRequest         : Ttyperequest;
  Procedure SetOnWork     (Value : TOnWork);
  Procedure SetOnWorkBegin(Value : TOnWorkBegin);
  Procedure SetOnWorkEnd  (Value : TOnWorkEnd);
  Procedure SetOnStatus   (Value : TOnStatus);
  Procedure SetConnection (Value : Boolean);          //Seta o Estado da Conexão
  Procedure SetRestPooler (Value : String);           //Seta o Restpooler a ser utilizado
  Procedure SetPoolerPort (Value : Integer);          //Seta a Porta do Pooler a ser usada
  Function  TryConnect : Boolean;                    //Tenta Conectar o Servidor para saber se posso executar comandos
  Procedure ExecuteCommand(Var SQL          : TStringList;
                           Var Params       : TParams;
                           Var Error        : Boolean;
                           Var MessageError : String;
                           Var Result       : TJSONValue;
                           Execute          : Boolean = False;
                           RESTClientPooler : TRESTClientPooler = Nil);
  Procedure ExecuteProcedure(ProcName         : String;
                             Params           : TParams;
                             Var Error        : Boolean;
                             Var MessageError : String);
  Function InsertMySQLReturnID(Var SQL          : TStringList;
                               Var Params       : TParams;
                               Var Error        : Boolean;
                               Var MessageError : String;
                               RESTClientPooler : TRESTClientPooler = Nil) : Integer;
  Procedure ApplyUpdates  (Massive          : TMassiveDatasetBuffer;
                           SQL              : TStringList;
                           Var Params       : TParams;
                           Var Error        : Boolean;
                           Var MessageError : String;
                           Var Result       : TJSONValue;
                           RESTClientPooler : TRESTClientPooler = Nil);Overload;
  Function  GetStateDB : Boolean;
  Procedure SetMyIp(Value : String);
 Public
  Function    GetRestPoolers : TStringList;          //Retorna a Lista de DataSet Sources do Pooler
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
  Procedure   Close;
  Procedure   Open;
  Procedure   ApplyUpdates(Var MassiveCache   : TDWMassiveCache;
                           Var   Error        : Boolean;
                           Var   MessageError : String);Overload;
  Procedure   OpenDatasets(Var   Datasets     : TRESTDWDatasetArray;
                           Var   Error        : Boolean;
                           Var   MessageError : String);Overload;
  Property    Connected       : Boolean                  Read GetStateDB          Write SetConnection;
 Published
  Property OnConnection       : TOnEventConnection       Read vOnEventConnection  Write vOnEventConnection; //Evento relativo a tudo que acontece quando tenta conectar ao Servidor
  Property OnBeforeConnect    : TOnEventBeforeConnection Read vOnBeforeConnection Write vOnBeforeConnection; //Evento antes de Connectar o Database
  Property Active             : Boolean                  Read vConnected          Write SetConnection;      //Seta o Estado da Conexão
  Property Compression        : Boolean                  Read vCompression        Write vCompression;       //Compressão de Dados
  Property MyIP               : String                   Read vMyIP               Write SetMyIp;
  Property Login              : String                   Read vLogin              Write vLogin;             //Login do Usuário caso haja autenticação
  Property Password           : String                   Read vPassword           Write vPassword;          //Senha do Usuário caso haja autenticação
  Property Proxy              : Boolean                  Read vProxy              Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions       : TProxyOptions            Read vProxyOptions       Write vProxyOptions;      //Se tem Proxy diz quais as opções
  Property PoolerService      : String                   Read vRestWebService     Write vRestWebService;    //Host do WebService REST
  Property PoolerURL          : String                   Read vRestURL            Write vRestURL;           //URL do WebService REST
  Property PoolerPort         : Integer                  Read vPoolerPort         Write SetPoolerPort;      //A Porta do Pooler do DataSet
  Property PoolerName         : String                   Read vRestPooler         Write SetRestPooler;      //Qual o Pooler de Conexão ligado ao componente
  Property RestModule         : String                   Read vRestModule         Write vRestModule;        //Classe do Servidor REST Principal
  Property StateConnection    : TAutoCheckData           Read vAutoCheckData      Write vAutoCheckData;     //Autocheck da Conexão
  Property RequestTimeOut     : Integer                  Read vTimeOut            Write vTimeOut;           //Timeout da Requisição
  Property EncodeStrings      : Boolean                  Read vEncodeStrings      Write vEncodeStrings;
  Property Encoding           : TEncodeSelect            Read VEncondig           Write VEncondig;          //Encoding da string
  Property Context            : string                   Read vContentex          Write vContentex;         //Contexto
  Property StrsTrim           : Boolean                  Read vStrsTrim           Write vStrsTrim;
  Property StrsEmpty2Null     : Boolean                  Read vStrsEmpty2Null     Write vStrsEmpty2Null;
  Property StrsTrim2Len       : Boolean                  Read vStrsTrim2Len       Write vStrsTrim2Len;
  Property WelcomeMessage     : String                   Read vWelcomeMessage     Write vWelcomeMessage;
  Property OnWork             : TOnWork                  Read vOnWork             Write SetOnWork;
  Property OnWorkBegin        : TOnWorkBegin             Read vOnWorkBegin        Write SetOnWorkBegin;
  Property OnWorkEnd          : TOnWorkEnd               Read vOnWorkEnd          Write SetOnWorkEnd;
  Property OnStatus           : TOnStatus                Read vOnStatus           Write SetOnStatus;
  {$IFDEF FPC}
  Property DatabaseCharSet    : TDatabaseCharSet         Read vDatabaseCharSet    Write vDatabaseCharSet;
  {$ENDIF}
  Property ParamCreate        : Boolean                  read vParamCreate        write vParamCreate;
  Property TypeRequest        : TTypeRequest             Read vTypeRequest        Write vTypeRequest       Default trHttp;
End;

Type
 { TRESTDWClientSQL }
 TRESTDWClientSQL     = Class(TRESTDWClientSQLBase) //Classe com as funcionalidades de um DBQuery
 Protected
  vActive,
  vInactive            : Boolean;
  {$IFDEF  UP_BARBOSA1}
  Procedure   ProcInBlockEvents  (Const BlockEvent : Boolean);virtual;
  {$ENDIF}
 Private
  vRESTClientPooler    : TRESTClientPooler;
  vMassiveCache        : TDWMassiveCache;
  vOldStatus           : TDatasetState;
  vDataSource          : TDataSource;
  vOnAfterScroll       : TOnAfterScroll;
  vOnAfterOpen         : TOnAfterOpen;
  vOnAfterClose        : TOnAfterClose;
  OldData              : TMemoryStream;
  {$IFDEF  UP_BARBOSA1}
  vOnInBlockEvent      : TOnInBlockEvent;
  {$ENDIF}
  vNewRecord,
  vBeforeOpen,
  vBeforeEdit,
  vBeforeInsert,
  vBeforePost,
  vBeforeDelete,
  vAfterEdit,
  vAfterInsert,
  vAfterPost,
  vAfterCancel         : TDatasetEvents;
  vAutoCommitData,
  vAutoRefreshAfterCommit,
  vInBlockEvents       : Boolean;
  vDatapacks,
  vMaxBufferRegs,
  vActualRec           : Integer;
  vOldSQL,
  vLastBuffer,
  vMasterFields,
  vUpdateTableName     : String;                            //Tabela que será feito Update no Servidor se for usada Reflexão de Dados
  vActiveCursor,
  vOnOpenCursor,
  vCacheUpdateRecords,
  vReadData,
  vCascadeDelete,
  vBeforeClone,
  vDataCache,                                               //Se usa cache local
  vConnectedOnce,                                           //Verifica se foi conectado ao Servidor
  vCommitUpdates,
  vCreateDS,
  GetNewData,
  vErrorBefore         : Boolean;                           //Estado do Dataset
  vSQL                 : TStringList;                       //SQL a ser utilizado na conexão
  vParams              : TParams;                           //Parametros de Dataset
  vCacheDataDB         : TDataset;                          //O Cache de Dados Salvo para utilização rápida
  vOnGetDataError      : TOnEventConnection;                //Se deu erro na hora de receber os dados ou não
  vRESTDataBase        : TRESTDWDataBase;                   //RESTDataBase do Dataset
  vOnAfterDelete       : TDataSetNotifyEvent;
  FieldDefsUPD         : TFieldDefs;
  vMasterDataSet       : TRESTDWClientSQL;
  vMasterDetailList    : TMasterDetailList;                 //DataSet MasterDetail Function
  vMassiveDataset      : TMassiveDataset;
  {$IFDEF FPC}
  Procedure CloneDefinitions     (Source  : TMemDataset;
                                  aSelf   : TMemDataset);   //Fields em Definições
  {$ELSE}
  {$IFDEF CLIENTDATASET}
  Procedure  CloneDefinitions    (Source  : TClientDataset;
                                  aSelf   : TClientDataset); //Fields em Definições
  {$ENDIF}
  {$IFDEF RESJEDI}
  Procedure  CloneDefinitions    (Source  : TJvMemoryData;
                                  aSelf   : TJvMemoryData); //Fields em Definições
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
  Procedure  CloneDefinitions    (Source  : TKbmMemtable;
                                  aSelf   : TKbmMemtable); //Fields em Definições
  {$ENDIF}
  {$IFDEF RESTFDMEMTABLE}
  Procedure  CloneDefinitions    (Source  : TFdMemtable;
                                  aSelf   : TFdMemtable); //Fields em Definições
  {$ENDIF}
  {$ENDIF}
  Procedure   OnChangingSQL      (Sender  : TObject);       //Quando Altera o SQL da Lista
  Procedure   OnBeforeChangingSQL(Sender  : TObject);
  Procedure   SetActiveDB        (Value   : Boolean);       //Seta o Estado do Dataset
  Procedure   SetSQL             (Value   : TStringList);   //Seta o SQL a ser usado
  Procedure   CreateParams;                                 //Cria os Parametros na lista de Dataset
  Procedure   SetDataBase        (Value   : TRESTDWDataBase); //Diz o REST Database
  Function    GetData(DataSet  : TJSONValue = Nil) : Boolean;                            //Recebe os Dados da Internet vindo do Servidor REST
  Procedure   SetUpdateTableName (Value   : String);        //Diz qual a tabela que será feito Update no Banco
  Procedure   OldAfterPost       (DataSet : TDataSet);      //Eventos do Dataset para realizar o AfterPost
  Procedure   OldAfterDelete     (DataSet : TDataSet);      //Eventos do Dataset para realizar o AfterDelete
  Procedure   SetMasterDataSet     (Value : TRESTDWClientSQL);
  Procedure   SetCacheUpdateRecords(Value : Boolean);
  Function    FirstWord          (Value     : String) : String;
  Procedure   ProcAfterScroll    (DataSet   : TDataSet);
  Procedure   ProcBeforeOpen     (DataSet   : TDataSet);
  Procedure   ProcAfterOpen      (DataSet   : TDataSet);
  Procedure   ProcAfterClose     (DataSet   : TDataSet);
  Procedure   ProcBeforeInsert   (DataSet   : TDataSet);
  Procedure   ProcAfterInsert    (DataSet   : TDataSet);
  Procedure   ProcNewRecord      (DataSet   : TDataSet);
  Procedure   ProcBeforeDelete   (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcBeforeEdit     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterEdit      (DataSet   : TDataSet);
  Procedure   ProcBeforePost     (DataSet   : TDataSet); //Evento para Delta
  Procedure   ProcAfterCancel    (DataSet   : TDataSet);
  procedure   CreateMassiveDataset;
  procedure   SetParams(const Value: TParams);
  procedure   SetInBlockEvents(const Value: Boolean);
 Public
  //Métodos
  Procedure   Newtable;
  Procedure   PrepareDetailsNew;
  Procedure   PrepareDetails     (ActiveMode : Boolean);
  Procedure   FieldDefsToFields;
  Function    FieldDefExist      (Value   : String) : TFieldDef;
  Function    FieldExist         (Value   : String) : TField;
  Procedure   Open;Overload; Virtual;                     //Método Open que será utilizado no Componente
  Procedure   Open               (SQL     : String);Overload; Virtual;//Método Open que será utilizado no Componente
  Procedure   ExecOrOpen;                                 //Método Open que será utilizado no Componente
  Procedure   Close;Virtual;                              //Método Close que será utilizado no Componente
  Procedure   CreateDataSet; virtual;
  Function    ExecSQL          (Var Error : String) : Boolean;   //Método ExecSQL que será utilizado no Componente
  Function    InsertMySQLReturnID : Integer;                     //Método de ExecSQL com retorno de Incremento
  Function    ParamByName          (Value : String) : TParam;    //Retorna o Parametro de Acordo com seu nome
  Function    ApplyUpdates     (Var Error : String) : Boolean;   //Aplica Alterações no Banco de Dados
  Constructor Create              (AOwner : TComponent);Override;//Cria o Componente
  Destructor  Destroy;Override;                                  //Destroy a Classe
  Procedure   Loaded; Override;
  procedure   OpenCursor       (InfoQuery : Boolean); Override;  //Subscrevendo o OpenCursor para não ter erros de ADD Fields em Tempo de Design
  Procedure   GotoRec       (Const aRecNo : Integer);
  Function    ParamCount    : Integer;
  Procedure   DynamicFilter(cFields : Array of String;
                            Value   : String;
                            InText  : Boolean;
                            AndOrOR : String);
  Procedure   Refresh;
  Procedure   SaveToStream    (Var Stream : TMemoryStream);
  Procedure   ClearMassive;
  Function    MassiveCount  : Integer;
  Function    MassiveToJSON : String; //Transporte de MASSIVE em formato JSON
  Procedure   DWParams        (Var Value  : TDWParams);
  Procedure   RebuildMassiveDataset;
 Published
  Property MasterDataSet          : TRESTDWClientSQL    Read vMasterDataSet            Write SetMasterDataSet;
  Property MasterCascadeDelete    : Boolean             Read vCascadeDelete            Write vCascadeDelete;
  Property Inactive               : Boolean             Read vInactive                 Write vInactive;
  Property Datapacks              : Integer             Read vDatapacks                Write vDatapacks;
  Property OnGetDataError         : TOnEventConnection  Read vOnGetDataError           Write vOnGetDataError;         //Recebe os Erros de ExecSQL ou de GetData
  Property AfterScroll            : TOnAfterScroll      Read vOnAfterScroll            Write vOnAfterScroll;
  Property AfterOpen              : TOnAfterOpen        Read vOnAfterOpen              Write vOnAfterOpen;
  {$IFDEF  UP_BARBOSA1}
  Property OnInBlockEvent         : TOnInBlockEvent     Read vOnInBlockEvent           Write vOnInBlockEvent;
  {$ENDIF}
  Property AfterClose             : TOnAfterClose       Read vOnAfterClose             Write vOnAfterClose;
  Property Active                 : Boolean             Read vActive                   Write SetActiveDB;             //Estado do Dataset
  Property DataCache              : Boolean             Read vDataCache                Write vDataCache;              //Diz se será salvo o último Stream do Dataset
  Property Params                 : TParams             Read vParams                   Write SetParams;                 //Parametros de Dataset
  Property DataBase               : TRESTDWDataBase     Read vRESTDataBase             Write SetDataBase;             //Database REST do Dataset
  Property SQL                    : TStringList         Read vSQL                      Write SetSQL;                  //SQL a ser Executado
  Property UpdateTableName        : String              Read vUpdateTableName          Write SetUpdateTableName;      //Tabela que será usada para Reflexão de Dados
  Property CacheUpdateRecords     : Boolean             Read vCacheUpdateRecords       Write SetCacheUpdateRecords;
  Property AutoCommitData         : Boolean             Read vAutoCommitData           Write vAutoCommitData;
  Property AutoRefreshAfterCommit : Boolean             Read vAutoRefreshAfterCommit   Write vAutoRefreshAfterCommit;
  Property MasterFields           : String              Read vMasterFields             Write vMasterFields;
  Property BeforeOpen             : TDatasetEvents      Read vBeforeOpen               Write vBeforeOpen;
  Property BeforeEdit             : TDatasetEvents      Read vBeforeEdit               Write vBeforeEdit;
  Property BeforeInsert           : TDatasetEvents      Read vBeforeInsert             Write vBeforeInsert;
  Property BeforePost             : TDatasetEvents      Read vBeforePost               Write vBeforePost;
  Property BeforeDelete           : TDatasetEvents      Read vBeforeDelete             Write vBeforeDelete;
  Property AfterEdit              : TDatasetEvents      Read vAfterEdit                Write vAfterEdit;
  Property AfterInsert            : TDatasetEvents      Read vAfterInsert              Write vAfterInsert;
  Property AfterPost              : TDatasetEvents      Read vAfterPost                Write vAfterPost;
  Property AfterCancel            : TDatasetEvents      Read vAfterCancel              Write vAfterCancel;
  Property OnNewRecord            : TDatasetEvents      Read vNewRecord                Write vNewRecord;
  Property InBlockEvents          : Boolean             Read vInBlockEvents            Write SetInBlockEvents;
  Property MassiveCache           : TDWMassiveCache     Read vMassiveCache             Write vMassiveCache;
End;

Type
 TRESTDWStoredProc = Class(TComponent)
 Private
  vParams       : TParams;
  vProcName     : String;
  vRESTDataBase : TRESTDWDataBase;
  procedure SetDataBase(Const Value : TRESTDWDataBase);
 Public
  Constructor Create   (AOwner      : TComponent);Override; //Cria o Componente
  Function    ExecProc (Var Error   : String) : Boolean;
  Destructor  Destroy;Override;                             //Destroy a Classe
  Function    ParamByName(Value : String) : TParam;
 Published
  Property DataBase            : TRESTDWDataBase     Read vRESTDataBase Write SetDataBase;             //Database REST do Dataset
  Property Params              : TParams             Read vParams       Write vParams;                 //Parametros de Dataset
  Property ProcName            : String              Read vProcName     Write vProcName;               //Procedure a ser Executada
End;

Type
 TRESTDWPoolerList = Class(TComponent)
 Private
  vWelcomeMessage,
  vPoolerPrefix,                                     //Prefixo do WS
  vLogin,                                            //Login do Usuário caso haja autenticação
  vPassword,                                         //Senha do Usuário caso haja autenticação
  vRestWebService,                                   //Rest WebService para consultas
  vRestURL             : String;                     //Qual o Pooler de Conexão do DataSet
  vPoolerPort          : Integer;                    //A Porta do Pooler
  vConnected,
  vProxy               : Boolean;                    //Diz se tem servidor Proxy
  vProxyOptions        : TProxyOptions;              //Se tem Proxy diz quais as opções
  vPoolerList          : TStringList;
  Procedure SetConnection(Value : Boolean);          //Seta o Estado da Conexão
  Procedure SetPoolerPort(Value : Integer);          //Seta a Porta do Pooler a ser usada
  Function  TryConnect : Boolean;                    //Tenta Conectar o Servidor para saber se posso executar comandos
//  Procedure SetConnectionOptions(Var Value : TRESTClientPooler); //Seta as Opções de Conexão
 Public
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property Active             : Boolean                  Read vConnected          Write SetConnection;      //Seta o Estado da Conexão
  Property Login              : String                   Read vLogin              Write vLogin;             //Login do Usuário caso haja autenticação
  Property Password           : String                   Read vPassword           Write vPassword;          //Senha do Usuário caso haja autenticação
  Property WelcomeMessage     : String                   Read vWelcomeMessage     Write vWelcomeMessage;    //Welcome Message Event
  Property Proxy              : Boolean                  Read vProxy              Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions       : TProxyOptions            Read vProxyOptions       Write vProxyOptions;      //Se tem Proxy diz quais as opções
  Property PoolerService      : String                   Read vRestWebService     Write vRestWebService;    //Host do WebService REST
  Property PoolerURL          : String                   Read vRestURL            Write vRestURL;           //URL do WebService REST
  Property PoolerPort         : Integer                  Read vPoolerPort         Write SetPoolerPort;      //A Porta do Pooler do DataSet
  Property PoolerPrefix       : String                   Read vPoolerPrefix       Write vPoolerPrefix;      //Prefixo do WebService REST
  Property Poolers            : TStringList              Read vPoolerList;
 End;

Type
 TRESTDWDriver    = Class(TComponent)
 Private
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vEncodeStrings,
  vCompression       : Boolean;
  vEncoding          : TEncodeSelect;
  vCommitRecords     : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet   : TDatabaseCharSet;
  {$ENDIF}
  vParamCreate       : Boolean;
 Public
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Function ApplyUpdates         (Massive,
                                 SQL               : String;
                                 Params            : TDWParams;
                                 Var Error         : Boolean;
                                 Var MessageError  : String) : TJSONValue;Virtual; Abstract;
  Procedure ApplyUpdates_MassiveCache(MassiveCache : String;
                                      Var Error    : Boolean;
                                      Var MessageError  : String);Virtual; Abstract;
  Function ExecuteCommand       (SQL        : String;
                                 Var Error  : Boolean;
                                 Var MessageError : String;
                                 Execute    : Boolean = False) : TJSONValue;Overload;Virtual;abstract;
  Function ExecuteCommand       (SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Execute          : Boolean = False) : TJSONValue;Overload;Virtual;abstract;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Virtual;abstract;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Virtual;abstract;
  Procedure ExecuteProcedure    (ProcName         : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Virtual;abstract;
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Virtual;abstract;
  Function  OpenDatasets        (DatasetsLine     : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : TJSONValue;Virtual;abstract;
  Procedure Close;Virtual;abstract;
 Public
  Property StrsTrim          : Boolean          Read vStrsTrim        Write vStrsTrim;
  Property StrsEmpty2Null    : Boolean          Read vStrsEmpty2Null  Write vStrsEmpty2Null;
  Property StrsTrim2Len      : Boolean          Read vStrsTrim2Len    Write vStrsTrim2Len;
  Property Compression       : Boolean          Read vCompression     Write vCompression;
  Property EncodeStringsJSON : Boolean          Read vEncodeStrings   Write vEncodeStrings;
  Property Encoding          : TEncodeSelect    Read vEncoding        Write vEncoding;
  property ParamCreate       : Boolean          Read vParamCreate     Write vParamCreate;
 Published
 {$IFDEF FPC}
  Property DatabaseCharSet   : TDatabaseCharSet Read vDatabaseCharSet Write vDatabaseCharSet;
 {$ENDIF}
  Property CommitRecords     : Integer          Read vCommitRecords   Write vCommitRecords;
End;

//PoolerDB Control
Type
 TRESTDWPoolerDBP = ^TComponent;
 TRESTDWPoolerDB  = Class(TComponent)
 Private
  FLock          : TCriticalSection;
  vRESTDriverBack,
  vRESTDriver    : TRESTDWDriver;
  vActive,
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vCompression   : Boolean;
  vEncoding      : TEncodeSelect;
  vMessagePoolerOff : String;
  vParamCreate   : Boolean;
  Procedure SetConnection(Value : TRESTDWDriver);
  Function  GetConnection  : TRESTDWDriver;
 Public
  Function ExecuteCommand(SQL        : String;
                          Var Error  : Boolean;
                          Var MessageError : String;
                          Execute    : Boolean = False) : TJSONValue;Overload;
  Function ExecuteCommand(SQL              : String;
                          Params           : TDWParams;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Execute          : Boolean = False) : TJSONValue;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Params           : TDWParams;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Procedure ExecuteProcedure  (ProcName         : String;
                               Params           : TDWParams;
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
  Property    ParamCreate      : Boolean       Read vParamCreate      Write vParamCreate;
End;

 Function GetDWParams(Params : TParams; Encondig : TEncodeSelect) : TDWParams;

implementation


Function GetDWParams(Params : TParams; Encondig : TEncodeSelect) : TDWParams;
Var
 I         : Integer;
 JSONParam : TJSONParam;
Begin
 Result := Nil;
 If Params <> Nil Then
  Begin
   If Params.Count > 0 Then
    Begin
     Result := TDWParams.Create;
     Result.Encoding := Encondig;
     For I := 0 To Params.Count -1 Do
      Begin
       JSONParam         := TJSONParam.Create(Result.Encoding);
       JSONParam.ParamName := Params[I].Name;
       JSONParam.Encoded   := True;
       JSONParam.LoadFromParam(Params[I]);
       Result.Add(JSONParam);
      End;
    End;
  End;
End;

Procedure TAutoCheckData.Assign(Source: TPersistent);
Var
 Src : TAutoCheckData;
Begin
 If Source is TAutoCheckData Then
  Begin
   Src        := TAutoCheckData(Source);
   vAutoCheck := Src.AutoCheck;
   vInTime    := Src.InTime;
//   vEvent     := Src.OnEventTimer;
  End
 Else
  Inherited;
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

Function  TRESTDWPoolerDB.GetConnection : TRESTDWDriver;
Begin
 Result := vRESTDriverBack;
End;

Procedure TRESTDWPoolerDB.SetConnection(Value : TRESTDWDriver);
Begin
 vRESTDriverBack := Value;
 If Value <> Nil Then
  vRESTDriver     := vRESTDriverBack
 Else
  Begin
   If vRESTDriver <> Nil Then
    vRESTDriver.Close;
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

Function TRESTDWPoolerDB.InsertMySQLReturnID(SQL              : String;
                                           Params           : TDWParams;
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

Function TRESTDWPoolerDB.ExecuteCommand(SQL        : String;
                                      Var Error  : Boolean;
                                      Var MessageError : String;
                                      Execute    : Boolean = False) : TJSONValue;
Begin
  Result := nil;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Error, MessageError, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Function TRESTDWPoolerDB.ExecuteCommand(SQL              : String;
                                        Params           : TDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean = False) : TJSONValue;
Begin
 Result := Nil;
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   Result := vRESTDriver.ExecuteCommand(SQL, Params, Error, MessageError, Execute);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
End;

Procedure TRESTDWPoolerDB.ExecuteProcedure(ProcName         : String;
                                         Params           : TDWParams;
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
  vEncoding         := esASCII;
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

Constructor TAutoCheckData.Create;
Begin
 Inherited;
 vAutoCheck := False;
 vInTime    := 1000;
 vEvent     := Nil;
 Timer      := Nil;
 FLock      := TCriticalSection.Create;
End;

Destructor  TAutoCheckData.Destroy;
Begin
 SetState(False);
 FLock.Release;
 FLock.Free;
 Inherited;
End;

Procedure  TAutoCheckData.SetState(Value : Boolean);
Begin
 vAutoCheck := Value;
 If vAutoCheck Then
  Begin
   If Timer <> Nil Then
    Begin
     Timer.Terminate;
     Timer := Nil;
    End;
   Timer              := TTimerData.Create(vInTime, FLock);
   Timer.OnEventTimer := vEvent;
  End
 Else
  Begin
   If Timer <> Nil Then
    Begin
     Timer.Terminate;
     Timer := Nil;
    End;
  End;
End;

Procedure  TAutoCheckData.SetInTime(Value : Integer);
Begin
 vInTime    := Value;
 SetState(vAutoCheck);
End;

Procedure  TAutoCheckData.SetEventTimer(Value : TOnEventTimer);
Begin
 vEvent := Value;
 SetState(vAutoCheck);
End;

Constructor TTimerData.Create(AValue: Integer; ALock: TCriticalSection);
Begin
 FValue := AValue;
 FLock := ALock;
 Inherited Create(False);
End;

Procedure TTimerData.Execute;
Begin
 While Not Terminated do
  Begin
   Sleep(FValue);
   FLock.Acquire;
   if Assigned(vEvent) then
    vEvent;
   FLock.Release;
  End;
End;

Constructor TProxyOptions.Create;
Begin
 Inherited;
 vServer   := '';
 vLogin    := vServer;
 vPassword := vLogin;
 vPort     := 8888;
End;

{
Procedure TRESTDWPoolerList.SetConnectionOptions(Var Value : TRESTClientPooler);
Begin
 Value                   := TRESTClientPooler.Create(Nil);
 Value.TypeRequest       := trHttp;
 Value.Host              := vRestWebService;
 Value.Port              := vPoolerPort;
 Value.UrlPath           := vRestURL;
 Value.UserName          := vLogin;
 Value.Password          := vPassword;
 if vProxy then
  Begin
   Value.ProxyOptions.ProxyServer   := vProxyOptions.vServer;
   Value.ProxyOptions.ProxyPort     := vProxyOptions.vPort;
   Value.ProxyOptions.ProxyUsername := vProxyOptions.vLogin;
   Value.ProxyOptions.ProxyPassword := vProxyOptions.vPassword;
  End
 Else
  Begin
   Value.ProxyOptions.ProxyServer   := '';
   Value.ProxyOptions.ProxyPort     := 0;
   Value.ProxyOptions.ProxyUsername := '';
   Value.ProxyOptions.ProxyPassword := '';
  End;
End;
}

Procedure TRESTDWDataBase.SetOnStatus(Value : TOnStatus);
Begin
 {$IFDEF FPC}
  vOnStatus            := Value;
 {$ELSE}
  vOnStatus            := Value;
 {$ENDIF}
End;

Procedure TRESTDWDataBase.SetOnWork(Value : TOnWork);
Begin
 {$IFDEF FPC}
  vOnWork            := Value;
 {$ELSE}
  vOnWork            := Value;
 {$ENDIF}
End;

Procedure TRESTDWDataBase.SetOnWorkBegin(Value : TOnWorkBegin);
Begin
 {$IFDEF FPC}
  vOnWorkBegin            := Value;
 {$ELSE}
  vOnWorkBegin            := Value;
 {$ENDIF}
End;

Procedure TRESTDWDataBase.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
 {$IFDEF FPC}
  vOnWorkEnd            := Value;
 {$ELSE}
  vOnWorkEnd            := Value;
 {$ENDIF}
End;

Procedure TRESTDWDataBase.ApplyUpdates(Massive          : TMassiveDatasetBuffer;
                                       SQL              : TStringList;
                                       Var Params       : TParams;
                                       Var Error        : Boolean;
                                       Var MessageError : String;
                                       Var Result       : TJSONValue;
                                       RESTClientPooler : TRESTClientPooler = Nil);
Var
 vRESTConnectionDB : TDWPoolerMethodClient;
 LDataSetList      : TJSONValue;
 DWParams          : TDWParams;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
// Result := Nil;
 if vRestPooler = '' then
  Exit;
 ParseParams;
 vRESTConnectionDB                := TDWPoolerMethodClient.Create(Nil);
 vRESTConnectionDB.WelcomeMessage := vWelcomeMessage;
 vRESTConnectionDB.Host           := vRestWebService;
 vRESTConnectionDB.Port           := vPoolerPort;
 vRESTConnectionDB.Compression    := vCompression;
 vRESTConnectionDB.TypeRequest     := VtypeRequest;
 vRESTConnectionDB.Encoding      := VEncondig;
 vRESTConnectionDB.OnWork        := vOnWork;
 vRESTConnectionDB.OnWorkBegin   := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd     := vOnWorkEnd;
 vRESTConnectionDB.OnStatus      := vOnStatus;
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := vDatabaseCharSet;
 {$ENDIF}
 Try
  If Params.Count > 0 Then
   DWParams     := GetDWParams(Params, vEncondig)
  Else
   DWParams     := Nil;
  LDataSetList := vRESTConnectionDB.ApplyUpdates(Massive,      vRestPooler,
                                                 vRestURL,  GetLineSQL(SQL),
                                                 DWParams,     Error,
                                                 MessageError, vTimeOut,
                                                 vLogin,       vPassword,
                                                 RESTClientPooler);
  If Params.Count > 0 Then
   If DWParams <> Nil Then
    FreeAndNil(DWParams);
  If (LDataSetList <> Nil) Then
   Begin
    Result := Nil;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> Nil) And
       (Not (Error))        Then
     Begin
      Try
       Result          := TJSONValue.Create;
       {$IFNDEF FPC}
        {$if CompilerVersion > 21}
        Result.Encoding := LDataSetList.Encoding;
        {$IFEND}
       {$ENDIF}
       Result.Encoded  := LDataSetList.Encoded;
       Result.SetValue(LDataSetList.ToJson, Result.Encoded);
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ApplyUpdates Ok');
     End
    Else
     Begin
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError)
      Else
       Raise Exception.Create(PChar(MessageError));
     End;
   End
  Else
   Begin
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
 if Assigned(LDataSetList) then
   FreeAndNil(LDataSetList);
End;

Function TRESTDWDataBase.InsertMySQLReturnID(Var SQL          : TStringList;
                                             Var Params       : TParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String;
                                             RESTClientPooler : TRESTClientPooler = Nil) : Integer;
Var
 vRESTConnectionDB : TDWPoolerMethodClient;
 LDataSetList      : Integer;
 DWParams          : TDWParams;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
  If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
 Result := -1;
 if vRestPooler = '' then
  Exit;
 ParseParams;
 vRESTConnectionDB                := TDWPoolerMethodClient.Create(Nil);
 vRESTConnectionDB.WelcomeMessage := vWelcomeMessage;
 vRESTConnectionDB.Host           := vRestWebService;
 vRESTConnectionDB.Port           := vPoolerPort;
 vRESTConnectionDB.Compression    := vCompression;
 vRESTConnectionDB.TypeRequest     := VtypeRequest;
 vRESTConnectionDB.Encoding      := VEncondig;
 vRESTConnectionDB.OnWork        := vOnWork;
 vRESTConnectionDB.OnWorkBegin   := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd     := vOnWorkEnd;
 vRESTConnectionDB.OnStatus      := vOnStatus;
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := vDatabaseCharSet;
 {$ENDIF}
 Try
  If Params.Count > 0 Then
   Begin
    DWParams     := GetDWParams(Params, vEncondig);
    LDataSetList := vRESTConnectionDB.InsertValue(vRestPooler,
                                                  vRestURL, GetLineSQL(SQL),
                                                  DWParams, Error,
                                                  MessageError, vTimeOut, vLogin, vPassword, RESTClientPooler);
    FreeAndNil(DWParams);
   End
  Else
   LDataSetList := vRESTConnectionDB.InsertValuePure (vRestPooler,
                                                      vRestURL,
                                                      GetLineSQL(SQL), Error,
                                                      MessageError, vTimeOut, vLogin, vPassword, RESTClientPooler);
  If (LDataSetList <> -1) Then
   Begin
//    If Not Assigned(Result) Then //Correção fornecida por romyllldo no Forum
    Result := -1;
    Error  := Trim(MessageError) <> '';
    If (LDataSetList <> -1) And
       (Not (Error))        Then
     Begin
      Try
       Result := LDataSetList;
      Finally
      End;
     End;
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'InsertValue Ok');
     End
    Else
     Begin
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError)
      Else
       Raise Exception.Create(PChar(MessageError));
     End;
   End
  Else
   Begin
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 FreeAndNil(vRESTConnectionDB);
 FreeAndNil(LDataSetList);
End;

Procedure TRESTDWDataBase.Open;
Begin
 SetConnection(True);
End;

Procedure TRESTDWDataBase.OpenDatasets(Var Datasets     : TRESTDWDatasetArray;
                                       Var Error        : Boolean;
                                       Var MessageError : String);
Var
 vJsonLine,
 vLinesDS          : String;
 I                 : Integer;
 vRESTConnectionDB : TDWPoolerMethodClient;
 DWParams          : TDWParams;
 JSONValue         : TJSONValue;
 bJsonValue        : TJsonObject;
 bJsonArray        : TJsonArray;
Begin
 vLinesDS := '';
 For I := 0 To Length(Datasets) -1 Do
  Begin
   TRESTDWClientSQL(Datasets[I]).ProcBeforeOpen(Datasets[I]);
   If I = 0 Then
    vLinesDS := DatasetRequestToJSON(Datasets[I])
   Else
    vLinesDS := Format('%s, %s', [vLinesDS, DatasetRequestToJSON(Datasets[I])]);
  End;
 If vLinesDS <> '' Then
  vLinesDS := Format('[%s]', [vLinesDS])
 Else
  vLinesDS := '[]';
 if vRestPooler = '' then
  Exit;
 vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
 vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
 vRESTConnectionDB.Host             := vRestWebService;
 vRESTConnectionDB.Port             := vPoolerPort;
 vRESTConnectionDB.Compression      := vCompression;
 vRESTConnectionDB.TypeRequest      := VtypeRequest;
 {$IFNDEF FPC}
  vRESTConnectionDB.OnWork          := vOnWork;
  vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
  vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
  vRESTConnectionDB.OnStatus        := vOnStatus;
  {$if CompilerVersion > 21}
  vRESTConnectionDB.Encoding        := VEncondig;
  {$IFEND}
 {$ELSE}
  vRESTConnectionDB.OnWork          := vOnWork;
  vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
  vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
  vRESTConnectionDB.OnStatus        := vOnStatus;
  vRESTConnectionDB.DatabaseCharSet := vDatabaseCharSet;
 {$ENDIF}
 Try
  vLinesDS := vRESTConnectionDB.OpenDatasets(vLinesDS, vRestPooler,  vRestModule,
                                             Error,    MessageError, vTimeOut,
                                             vLogin,   vPassword);
  If Not Error Then
   Begin
    JSONValue := TJSONValue.Create;
    Try
     JSONValue.Encoded := True;
     JSONValue.LoadFromJSON(vLinesDS);
     vJsonLine := JSONValue.value;
     FreeAndNil(JSONValue);
     bJsonArray := udwjson.TJsonArray.create(vJsonLine);
     For I := 0 To bJsonArray.Length - 1 Do
      Begin
       JSONValue := TJSONValue.Create;
       JSONValue.LoadFromJSON(bJsonArray.optJSONObject(I).ToString);
       JSONValue.Encoded := True;
       JSONValue.WriteToDataset(dtFull, JSONValue.ToJSON, TRESTDWClientSQL(Datasets[I]));
       TRESTDWClientSQL(Datasets[I]).CreateMassiveDataset;
      End;
    Finally
     If bJsonArray <> Nil Then
      FreeAndNil(bJsonArray);
     FreeAndNil(JSONValue);
    End;
   End;
 Finally
  FreeAndNil(vRESTConnectionDB);
 End;
End;

Procedure TRESTDWDataBase.ExecuteCommand(Var SQL          : TStringList;
                                         Var Params       : TParams;
                                         Var Error        : Boolean;
                                         Var MessageError : String;
                                         Var Result       : TJSONValue;
                                         Execute          : Boolean = False;
                                         RESTClientPooler : TRESTClientPooler = Nil);
Var
 vRESTConnectionDB : TDWPoolerMethodClient;
 LDataSetList      : TJSONValue;
 DWParams          : TDWParams;
 vTempValue        : String;
 Function GetLineSQL(Value : TStringList) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> Nil Then
   For I := 0 To Value.Count -1 do
    Begin
     If I = 0 then
      Result := Value[I]
     Else
      Result := Result + ' ' + Value[I];
    End;
 End;
 Procedure ParseParams;
 Var
  I : Integer;
 Begin
 If Params <> Nil Then
   For I := 0 To Params.Count -1 Do
    Begin
     If Params[I].DataType = ftUnknown then
      Params[I].DataType := ftString;
    End;
 End;
Begin
// Result := Nil;
 If vRestPooler = '' Then
  Exit;
 ParseParams;
 vRESTConnectionDB                := TDWPoolerMethodClient.Create(Nil);
 vRESTConnectionDB.WelcomeMessage := vWelcomeMessage;
 vRESTConnectionDB.Host           := vRestWebService;
 vRESTConnectionDB.Port           := vPoolerPort;
 vRESTConnectionDB.Compression    := vCompression;
 vRESTConnectionDB.TypeRequest     := VtypeRequest;
 vRESTConnectionDB.Encoding      := VEncondig;
 vRESTConnectionDB.OnWork        := vOnWork;
 vRESTConnectionDB.OnWorkBegin   := vOnWorkBegin;
 vRESTConnectionDB.OnWorkEnd     := vOnWorkEnd;
 vRESTConnectionDB.OnStatus      := vOnStatus;
 {$IFDEF FPC}
  vRESTConnectionDB.DatabaseCharSet := vDatabaseCharSet;
 {$ENDIF}
 Try
  If Params.Count > 0 Then
   Begin
    DWParams     := GetDWParams(Params, vEncondig);
    LDataSetList := vRESTConnectionDB.ExecuteCommandJSON(vRestPooler,
                                                         vRestURL, GetLineSQL(SQL),
                                                         DWParams, Error,
                                                         MessageError, Execute, vTimeOut, vLogin, vPassword, RESTClientPooler);
    FreeAndNil(DWParams);
   End
  Else
   LDataSetList := vRESTConnectionDB.ExecuteCommandPureJSON(vRestPooler,
                                                            vRestURL,
                                                            GetLineSQL(SQL), Error,
                                                            MessageError, Execute, vTimeOut, vLogin, vPassword, RESTClientPooler);

  If (LDataSetList <> Nil) Then
   Begin
//    If Not Assigned(Result) Then //Correção fornecida por romyllldo no Forum
    Result := TJSONValue.Create;
    Result.Encoding := vRESTConnectionDB.Encoding;
    Error  := Trim(MessageError) <> '';
    vTempValue := LDataSetList.ToJSON;
    If (Trim(vTempValue) <> '{}') And
       (Trim(vTempValue) <> '')    And
       (Not (Error))                       Then
     Begin
      Try
       {$IFDEF  ANDROID}
       Result.Free;
       Result := LDataSetList;
       {$ELSE}
       Result.LoadFromJSON(vTempValue); //Esse código server para criar o Objeto, nao pode ser removido
       {$ENDIF}
      Finally
      End;
     End;
    vTempValue := '';
    If (Not (Error)) Then
     Begin
      If Assigned(vOnEventConnection) Then
       vOnEventConnection(True, 'ExecuteCommand Ok');
     End
    Else
     Begin
      If Assigned(vOnEventConnection) then
       vOnEventConnection(False, MessageError)
      Else
       Raise Exception.Create(PChar(MessageError));
     End;
   End
  Else
   Begin
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(False, MessageError);
   End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 If LDataSetList <> Nil Then
  FreeAndNil(LDataSetList);
 FreeAndNil(vRESTConnectionDB);
End;

Procedure TRESTDWDataBase.ExecuteProcedure(ProcName         : String;
                                           Params           : TParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String);
Begin
End;

Function TRESTDWDataBase.GetRestPoolers : TStringList;
Var
 vTempList   : TStringList;
 vConnection : TDWPoolerMethodClient;
 I           : Integer;
Begin
 vConnection                := TDWPoolerMethodClient.Create(Nil);
 vConnection.WelcomeMessage := vWelcomeMessage;
 vConnection.Host           := vRestWebService;
 vConnection.Port           := vPoolerPort;
 vConnection.Compression    := vCompression;
 vConnection.TypeRequest    := VtypeRequest;
 Result := TStringList.Create;
 Try
  vTempList := vConnection.GetPoolerList(vRestURL, vTimeOut, vLogin, vPassword);
  Try
    For I := 0 To vTempList.Count -1 do
     Result.Add(vTempList[I]);
    If Assigned(vOnEventConnection) Then
     vOnEventConnection(True, 'GetRestPoolers Ok');
  Finally
   vTempList.Free;
  End;
 Except
  On E : Exception do
   Begin
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
End;

Function TRESTDWDataBase.GetStateDB: Boolean;
Begin
 Result := vConnected;
End;

Constructor TRESTDWPoolerList.Create(AOwner : TComponent);
Begin
 Inherited;
 vLogin                    := '';
 vPassword                 := vLogin;
 vPoolerPort               := 8082;
 vProxy                    := False;
 vProxyOptions             := TProxyOptions.Create;
 vPoolerList               := TStringList.Create;
End;

Constructor TRESTDWDataBase.Create(AOwner : TComponent);
Begin
 Inherited;
 vLogin                    := 'testserver';
 vMyIP                     := '0.0.0.0';
 vRestWebService           := '127.0.0.1';
 vCompression              := True;
 vPassword                 := vLogin;
 vRestModule               := '';
 vRestPooler               := '';
 vPoolerPort               := 8082;
 vProxy                    := False;
 vEncodeStrings            := True;
 vProxyOptions             := TProxyOptions.Create;
 vAutoCheckData            := TAutoCheckData.Create;
 vAutoCheckData.vAutoCheck := False;
 vAutoCheckData.vInTime    := 1000;
 vTimeOut                  := 10000;
// vAutoCheckData.vEvent     := CheckConnection;
 vEncondig                 := esASCII;
 vContentex                := '';
 vStrsTrim                 := False;
 vStrsEmpty2Null           := False;
 vStrsTrim2Len             := True;
 {$IFDEF FPC}
 vDatabaseCharSet := csUndefined;
 {$ENDIF}
 vParamCreate              := True;
End;

Destructor  TRESTDWPoolerList.Destroy;
Begin
 vProxyOptions.Free;
 If vPoolerList <> Nil Then
  vPoolerList.Free;
 Inherited;
End;

Destructor  TRESTDWDataBase.Destroy;
Begin
 vAutoCheckData.vAutoCheck := False;
 FreeAndNil(vProxyOptions);
 FreeAndNil(vAutoCheckData);
 Inherited;
End;

Procedure TRESTDWDataBase.ApplyUpdates(Var MassiveCache : TDWMassiveCache;
                                       Var Error        : Boolean;
                                       Var MessageError : String);
Var
 vUpdateLine       : String;
 vRESTConnectionDB : TDWPoolerMethodClient;
Begin
 If MassiveCache.MassiveCount > 0 Then
  Begin
   vUpdateLine := MassiveCache.ToJSON;
   If vRestPooler = '' Then
    Exit;
   If Not vConnected Then
    SetConnection(True);
   If vConnected Then
    Begin
     vRESTConnectionDB                  := TDWPoolerMethodClient.Create(Nil);
     vRESTConnectionDB.WelcomeMessage   := vWelcomeMessage;
     vRESTConnectionDB.Host             := vRestWebService;
     vRESTConnectionDB.Port             := vPoolerPort;
     vRESTConnectionDB.Compression      := vCompression;
     vRESTConnectionDB.TypeRequest      := VtypeRequest;
     {$IFNDEF FPC}
     vRESTConnectionDB.OnWork          := vOnWork;
     vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
     vRESTConnectionDB.OnStatus        := vOnStatus;
     {$if CompilerVersion > 21}
     vRESTConnectionDB.Encoding        := VEncondig;
     {$IFEND}
     {$ELSE}
     vRESTConnectionDB.OnWork          := vOnWork;
     vRESTConnectionDB.OnWorkBegin     := vOnWorkBegin;
     vRESTConnectionDB.OnWorkEnd       := vOnWorkEnd;
     vRESTConnectionDB.OnStatus        := vOnStatus;
     vRESTConnectionDB.DatabaseCharSet := vDatabaseCharSet;
     {$ENDIF}
     Try
      vRESTConnectionDB.ApplyUpdates_MassiveCache(vUpdateLine, vRestPooler,  vRestModule,
                                                  Error,       MessageError, vTimeOut,
                                                  vLogin,      vPassword);
      If Not Error Then
       MassiveCache.Clear;
     Finally
      FreeAndNil(vRESTConnectionDB);
     End;
    End;
  End;
End;

Procedure TRESTDWDataBase.Close;
Begin
 SetConnection(False);
End;

Function  TRESTDWPoolerList.TryConnect : Boolean;
Var
 vConnection : TDWPoolerMethodClient;
Begin
 Result                     := False;
 vConnection                := TDWPoolerMethodClient.Create(Nil);
 vConnection.WelcomeMessage := vWelcomeMessage;
 vConnection.Host           := vRestWebService;
 vConnection.Port           := vPoolerPort;
 Try
  vPoolerList.Clear;
  vPoolerList.Assign(vConnection.GetPoolerList(vPoolerPrefix, 3000, vLogin, vPassword));
  Result      := True;
 Except
 End;
 vConnection.Free;
End;

Function  TRESTDWDataBase.TryConnect : Boolean;
Var
 vTempSend   : String;
 vConnection : TDWPoolerMethodClient;
Begin
 vConnection                := TDWPoolerMethodClient.Create(Nil);
 vConnection.TypeRequest    := vTypeRequest;
 vConnection.WelcomeMessage := vWelcomeMessage;
 vConnection.Host           := vRestWebService;
 vConnection.Port           := vPoolerPort;
 vConnection.Compression    := vCompression;
 {$IFNDEF FPC}
  vConnection.OnWork        := vOnWork;
  vConnection.OnWorkBegin   := vOnWorkBegin;
  vConnection.OnWorkEnd     := vOnWorkEnd;
  vConnection.OnStatus      := vOnStatus;
  {$if CompilerVersion > 21}
  vConnection.Encoding      := VEncondig;
  {$IFEND}
 {$ELSE}
  vConnection.OnWork          := vOnWork;
  vConnection.OnWorkBegin     := vOnWorkBegin;
  vConnection.OnWorkEnd       := vOnWorkEnd;
  vConnection.OnStatus        := vOnStatus;
  vConnection.DatabaseCharSet := vDatabaseCharSet;
 {$ENDIF}
 Try
  Try
   vTempSend   := vConnection.EchoPooler(vRestURL, vRestPooler, vTimeOut, vLogin, vPassword);
   Result      := Trim(vTempSend) <> '';
   If Result Then
    vMyIP       := vTempSend
   Else
    vMyIP       := '';
   If csDesigning in ComponentState Then
    If Not Result Then Raise Exception.Create(PChar('Error : ' + #13 + 'Authentication Error...'));
   If Trim(vMyIP) = '' Then
    Begin
     Result      := False;
     If Assigned(vOnEventConnection) Then
      vOnEventConnection(False, 'Authentication Error...');
    End;
  Except
   On E : Exception do
    Begin
     Result      := False;
     vMyIP       := '';
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(E.Message));
     If Assigned(vOnEventConnection) Then
      vOnEventConnection(False, E.Message)
     Else
      Raise Exception.Create(E.Message);
    End;
  End;
 Finally
  If vConnection <> Nil Then
   FreeAndNil(vConnection);
 End;
End;

Procedure TRESTDWDataBase.SetConnection(Value : Boolean);
Begin
 If (Value) And
    (Trim(vRestPooler) = '') Then
  Exit;
 if (Value) And Not(vConnected) then
  If Assigned(vOnBeforeConnection) Then
   vOnBeforeConnection(Self);
 If Not(vConnected) And (Value) Then
  Begin
   If Value then
    vConnected := TryConnect
   Else
    vMyIP := '';
  End
 Else If Not (Value) Then
  Begin
   vConnected := Value;
   vMyIP := '';
  End;
End;

Procedure TRESTDWPoolerList.SetConnection(Value : Boolean);
Begin
 vConnected := Value;
 If vConnected Then
  vConnected := TryConnect;
End;

Procedure TRESTDWDataBase.SetPoolerPort(Value : Integer);
Begin
 vPoolerPort := Value;
End;

Procedure TRESTDWPoolerList.SetPoolerPort(Value : Integer);
Begin
 vPoolerPort := Value;
End;

Procedure TRESTDWDataBase.SetRestPooler(Value : String);
Begin
 vRestPooler := Value;
End;

procedure TRESTDWClientSQL.SetDataBase(Value: TRESTDWDataBase);
Begin
 if Value is TRESTDWDataBase then
  vRESTDataBase := Value
 Else
  vRESTDataBase := Nil;
End;

procedure TRESTDWClientSQL.SetInBlockEvents(const Value: Boolean);
begin
{$IFDEF  UP_BARBOSA1}
  ProcInBlockEvents(Value);
{$ENDIF}
  vInBlockEvents:=Value;
end;

procedure TRESTDWClientSQL.SetMasterDataSet(Value: TRESTDWClientSQL);
Var
 MasterDetailItem : TMasterDetailItem;
Begin
 If (vMasterDataSet <> Nil) Then
  TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 If (Value = Self) And (Value <> Nil) Then
  Begin
   vMasterDataSet := Nil;
   MasterFields   := '';
   Exit;
  End;
 vMasterDataSet := Value;
 If (vMasterDataSet <> Nil) Then
  Begin
   MasterDetailItem         := TMasterDetailItem.Create;
   MasterDetailItem.DataSet := TRESTClient(Self);
   TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.Add(MasterDetailItem);
   vDataSource.DataSet := Value;
  End
 Else
  Begin
   MasterFields := '';
  End;
End;

procedure TRESTDWClientSQL.SetParams(const Value: TParams);
begin
  vParams.Assign(Value);
end;

constructor TRESTDWClientSQL.Create(AOwner: TComponent);
Begin
 Inherited;
 vInactive                         := False;
 vInBlockEvents                    := False;
 vOnOpenCursor                     := False;
 vRESTClientPooler                 := TRESTClientPooler.Create(Nil);
 vDataCache                        := False;
 vAutoCommitData                   := False;
 vAutoRefreshAfterCommit           := False;
 vConnectedOnce                    := True;
 GetNewData                        := True;
 vActive                           := False;
 vCacheUpdateRecords               := True;
 vBeforeClone                      := False;
 vReadData                         := False;
 vActiveCursor                     := False;
 vDatapacks                        := -1;
 vCascadeDelete                    := True;
 vSQL                              := TStringList.Create;
 {$IFDEF FPC}
  vSQL.OnChanging                  := @OnBeforeChangingSQL;
  vSQL.OnChange                    := @OnChangingSQL;
 {$ELSE}
  vSQL.OnChanging                  := OnBeforeChangingSQL;
  vSQL.OnChange                    := OnChangingSQL;
 {$ENDIF}
 vParams                           := TParams.Create(Self);
// vCacheDataDB                      := Self.CloneSource;
 vUpdateTableName                  := '';
 FieldDefsUPD                      := TFieldDefs.Create(Self);
 FieldDefs                         := FieldDefsUPD;
 vMasterDetailList                 := TMasterDetailList.Create;
 OldData                           := TMemoryStream.Create;
 vMasterDataSet                    := Nil;
 vDataSource                       := TDataSource.Create(Nil);
 {$IFDEF FPC}
 TDataset(Self).AfterScroll        := @ProcAfterScroll;
 TDataset(Self).BeforeOpen         := @ProcBeforeOpen;
 TDataset(Self).AfterOpen          := @ProcAfterOpen;
 TDataset(Self).AfterClose         := @ProcAfterClose;
 TDataset(Self).BeforeInsert       := @ProcBeforeInsert;
 TDataset(Self).AfterInsert        := @ProcAfterInsert;
 TDataset(Self).BeforeEdit         := @ProcBeforeEdit;
 TDataset(Self).AfterEdit          := @ProcAfterEdit;
 TDataset(Self).BeforePost         := @ProcBeforePost;
 TDataset(Self).AfterCancel        := @ProcAfterCancel;
 TDataset(Self).BeforeDelete       := @ProcBeforeDelete;
 TDataset(Self).OnNewRecord        := @ProcNewRecord;
 Inherited AfterPost               := @OldAfterPost;
 Inherited AfterDelete             := @OldAfterDelete;
 {$ELSE}
 TDataset(Self).AfterScroll        := ProcAfterScroll;
 TDataset(Self).BeforeOpen         := ProcBeforeOpen;
 TDataset(Self).AfterOpen          := ProcAfterOpen;
 TDataset(Self).AfterClose         := ProcAfterClose;
 TDataset(Self).BeforeInsert       := ProcBeforeInsert;
 TDataset(Self).AfterInsert        := ProcAfterInsert;
 TDataset(Self).BeforeEdit         := ProcBeforeEdit;
 TDataset(Self).AfterEdit          := ProcAfterEdit;
 TDataset(Self).BeforePost         := ProcBeforePost;
 TDataset(Self).BeforeDelete       := ProcBeforeDelete;
 TDataset(Self).AfterCancel        := ProcAfterCancel;
 TDataset(Self).OnNewRecord        := ProcNewRecord;
 Inherited AfterPost               := OldAfterPost;
 Inherited AfterDelete             := OldAfterDelete;
 {$ENDIF}
 vMassiveDataset                   := TMassiveDatasetBuffer.Create(Self);
 {$IFDEF FPC}
//  TBufDataset(Self).PacketRecords  := 1;
 {$ENDIF}
End;

destructor TRESTDWClientSQL.Destroy;
Begin
 FreeAndNil(vSQL);
 FreeAndNil(vParams);
 FreeAndNil(FieldDefsUPD);
 If (vMasterDataSet <> Nil) Then
  TRESTDWClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 FreeAndNil(vMasterDetailList);
 FreeAndNil(vDataSource);
 If Assigned(vCacheDataDB) Then
  FreeAndNil(vCacheDataDB);
 FreeAndNil(OldData);
 FreeAndNil(vRESTClientPooler);
 vInactive := False;
 FreeAndNil(vMassiveDataset);
 Inherited;
End;

Procedure TRESTDWClientSQL.DWParams(Var Value : TDWParams);
Begin
 Value := Nil;
 If vRESTDataBase <> Nil Then
  If Params.Count > 0 Then
   Value := GetDWParams(Params, vRESTDataBase.Encoding);
End;

Procedure TRESTDWClientSQL.DynamicFilter(cFields  : Array of String;
                                         Value   : String;
                                         InText  : Boolean;
                                         AndOrOR : String);
Var
 I : Integer;
begin
 ExecOrOpen;
 Filter := '';
 If vActive Then
  Begin
   If Length(Value) > 0 Then
    Begin
     Filtered := False;
     For I := 0 to High(cFields) do
      Begin
       If I = High(cFields) Then
        AndOrOR := '';
       If InText Then
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], '%' + Value + '%', AndOrOR])
       Else
        Filter := Filter + Format('%s Like ''%s'' %s ', [cFields[I], Value + '%', AndOrOR]);
      End;
     If Not (Filtered) Then
      Filtered := True;
    End
   Else
    Begin
     Filter   := '';
     Filtered := False;
    End;
  End;
End;

Function ScanParams(SQL : String) : TStringList;
Var
 vTemp        : String;
 FCurrentPos  : PChar;
 vOldChar     : Char;
 vParamName   : String;
 Function GetParamName : String;
 Begin
  Result := '';
  If FCurrentPos^ = ':' Then
   Begin
    Inc(FCurrentPos);
    if vOldChar in [' ', '=', '-', '+', '<', '>', '(', ')', ':', '|'] then
     Begin
      While Not (FCurrentPos^ = #0) Do
       Begin
        if FCurrentPos^ in ['0'..'9', 'A'..'Z','a'..'z', '_'] then

         Result := Result + FCurrentPos^
        Else
         Break;
        Inc(FCurrentPos);
       End;
     End;
   End
  Else
   Inc(FCurrentPos);
  vOldChar := FCurrentPos^;
 End;
Begin
 Result := TStringList.Create;
 vTemp  := SQL;
 FCurrentPos := PChar(vTemp);
 While Not (FCurrentPos^ = #0) do
  Begin
   If Not (FCurrentPos^ in [#0..' ', ',',
                           '''', '"',
                           '0'..'9', 'A'..'Z',
                           'a'..'z', '_',
                           '$', #127..#255]) Then


    Begin
     vParamName := GetParamName;
     If Trim(vParamName) <> '' Then
      Begin
       Result.Add(vParamName);
       Inc(FCurrentPos);
      End;
    End
   Else
    Begin
     vOldChar := FCurrentPos^;
     Inc(FCurrentPos);
    End;
  End;
End;

Function ReturnParams(SQL : String) : TStringList;
Begin
 Result := ScanParams(SQL);
End;

Function ReturnParamsAtual(ParamsList : TParams) : TStringList;
Var
 I : Integer;
Begin
 Result := Nil;
 If ParamsList.Count > 0 Then
  Begin
   Result := TStringList.Create;
   For I := 0 To ParamsList.Count -1 Do
    Result.Add(ParamsList[I].Name);
  End;
End;

procedure TRESTDWClientSQL.CreateParams;
Var
 I         : Integer;
 ParamsListAtual,
 ParamList : TStringList;
 Procedure CreateParam(Value : String);
  Function ParamSeek (Name : String) : Boolean;
  Var
   I : Integer;
  Begin
   Result := False;
   For I := 0 To vParams.Count -1 Do
    Begin
     Result := LowerCase(vParams.items[i].Name) = LowerCase(Name);
     If Result Then
      Break;
    End;
  End;
 Var
  FieldDef : TField;
 Begin
  FieldDef := FindField(Value);
  If FieldDef <> Nil Then
   Begin
    If Not (ParamSeek(Value)) Then
     Begin
      vParams.CreateParam(FieldDef.DataType, Value, ptInput);
      vParams.ParamByName(Value).Size := FieldDef.Size;
//      If FieldDef.DataType in [ftSmallint, ftInteger, ftLargeint, ftWord,
//                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord,{$IFEND}{$ENDIF}
//                               ftBoolean, ftFloat, ftCurrency, ftBCD, ftFMTBcd] Then
//       vParams.ParamByName(Value).Value := -1;
     End;
   End
  Else If Not(ParamSeek(Value)) Then
   vParams.CreateParam(ftString, Value, ptInput);
 End;
 Function CompareParams(A, B : TStringList) : Boolean;
 Var
  I, X : Integer;
 Begin
  Result := (A <> Nil) And (B <> Nil);
  If Result Then
   Begin
    For I := 0 To A.Count -1 Do
     Begin
      For X := 0 To B.Count -1 Do
       Begin
        Result := lowercase(A[I]) = lowercase(B[X]);
        If Result Then
         Break;
       End;
      If Not Result Then
       Break;
     End;
   End;
  If Result Then
   Result := B.Count > 0;
 End;
Begin
 ParamList       := ReturnParams(vSQL.Text);
 ParamsListAtual := ReturnParamsAtual(vParams);
 If Not CompareParams(ParamsListAtual, ParamList) Then
  vParams.Clear;
 If ParamList <> Nil Then
 For I := 0 to ParamList.Count -1 Do
  CreateParam(ParamList[I]);
 ParamList.Free;
  if Assigned(ParamsListAtual) then
   FreeAndNil(ParamsListAtual);
End;

procedure TRESTDWClientSQL.ProcAfterScroll(DataSet: TDataSet);
Begin
 If State = dsBrowse Then
  Begin
   If Not Active Then
    PrepareDetailsNew
   Else
    Begin
     If RecordCount = 0 Then
      PrepareDetailsNew
     Else
      PrepareDetails(True)
    End;
  End
 Else If State = dsInactive Then
  PrepareDetails(False)
 Else If State = dsInsert Then
  PrepareDetailsNew;
 If Assigned(vOnAfterScroll) Then
  vOnAfterScroll(Dataset);
End;

procedure TRESTDWClientSQL.GotoRec(const aRecNo: Integer);
Var
 ActiveRecNo,
 Distance     : Integer;
Begin
 If (RecNo > 0) Then
  Begin
   ActiveRecNo := Self.RecNo;
   If (RecNo <> ActiveRecNo) Then
    Begin
     Self.DisableControls;
     Try
      Distance := RecNo - ActiveRecNo;
      Self.MoveBy(Distance);
     Finally
      Self.EnableControls;
     End;
    End;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeDelete(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQL;
Begin
 If Not vReadData Then
  Begin
   vReadData := True;
   vOldStatus   := State;
   Try
    vActualRec   := RecNo;
   Except
    vActualRec   := -1;
   End;
   OldData.Clear;
   SaveToStream(OldData);
   If vCascadeDelete Then
    Begin
     For I := 0 To vMasterDetailList.Count -1 Do
      Begin
       vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
       vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
       If vDetailClient <> Nil Then
        Begin
         Try
          vDetailClient.First;
          While Not vDetailClient.Eof Do
           vDetailClient.Delete;
         Finally
          vReadData := False;
         End;
        End;
      End;
    End;
   If Not vInBlockEvents Then
    Begin
     If Trim(vUpdateTableName) <> '' Then
      Begin
       TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmDelete);
       TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self);
       If vMassiveCache <> Nil Then
        Begin
         vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON);
         TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
        End;
      End;
     If Assigned(vBeforeDelete) Then
      vBeforeDelete(DataSet);
    End;
   vReadData := False;
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeEdit(DataSet: TDataSet);
Begin
 If Not vInBlockEvents Then
  Begin
   If Trim(vUpdateTableName) <> '' Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer  (Self, mmUpdate);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmUpdate);
    End;
   If Assigned(vBeforeEdit) Then
    vBeforeEdit(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcBeforeInsert(DataSet: TDataSet);
Begin
 If Not vInBlockEvents Then
  If Assigned(vBeforeInsert) Then
   vBeforeInsert(Dataset);
End;

procedure TRESTDWClientSQL.ProcBeforeOpen(DataSet: TDataSet);
Begin
 If Not vInBlockEvents Then
  If Assigned(vBeforeOpen) Then
   vBeforeOpen(Dataset);
End;

procedure TRESTDWClientSQL.ProcBeforePost(DataSet: TDataSet);
Var
 vOldState : TDatasetState;
Begin
 If Not vReadData Then
  Begin
   vActualRec := -1;
   vReadData  := True;
   vOldState  := State;
   OldData.Clear;
   SaveToStream(OldData);
   vOldStatus   := State;
   Try
    If vOldState = dsInsert then
     vActualRec  := RecNo + 1
    Else
     vActualRec  := RecNo;
   Except
    vActualRec   := -1;
   End;
   Edit;
   vReadData     := False;
   If Not vInBlockEvents Then
    Begin
     If Assigned(vBeforePost) Then
      vBeforePost(DataSet);
     If Trim(vUpdateTableName) <> '' Then
      Begin
       TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, DatasetStateToMassiveType(vOldState), vOldState = dsEdit);
       If vOldState = dsEdit Then
        Begin
         If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer <> Nil Then
          Begin
           If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges <> Nil Then
            Begin
             If TMassiveDatasetBuffer(vMassiveDataset).TempBuffer.UpdateFieldChanges.Count = 0 Then
              TMassiveDatasetBuffer(vMassiveDataset).ClearLine
             Else
              TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self);
            End
           Else
            TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
          End
         Else
          TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
        End
       Else
        TMassiveDatasetBuffer(vMassiveDataset).SaveBuffer(Self);
       If vMassiveCache <> Nil Then
        Begin
         vMassiveCache.Add(TMassiveDatasetBuffer(vMassiveDataset).ToJSON);
         TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
        End;
      End;
    End;
  End;
End;

{$IFDEF  UP_BARBOSA1}
procedure TRESTDWClientSQL.ProcInBlockEvents(const BlockEvent: Boolean);
begin
  if Assigned(vOnInBlockEvent) then
    vOnInBlockEvent(Self,BlockEvent);
end;
{$ENDIF}


procedure TRESTDWClientSQL.ProcNewRecord(DataSet: TDataSet);
begin
 If Not vInBlockEvents Then
  Begin
   If Assigned(vNewRecord) Then
    vNewRecord(Dataset);
  End;
end;

Procedure TRESTDWClientSQL.RebuildMassiveDataset;
Begin
 CreateMassiveDataset;
End;

Procedure TRESTDWClientSQL.Refresh;
Var
 Cursor : Integer;
Begin
 Cursor := 0;
 If Active then
  Begin
   If RecordCount > 0 then
    Cursor := Self.CurrentRecord;
   Close;
   Open;
   If Active then
    Begin
     If RecordCount > 0 Then
      MoveBy(Cursor);
    End;
  End;
End;

procedure TRESTDWClientSQL.ProcAfterClose(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQL;
Begin
 If Assigned(vOnAfterClose) then
  vOnAfterClose(Dataset);
 If vCascadeDelete Then
  Begin
   For I := 0 To vMasterDetailList.Count -1 Do
    Begin
     vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
     vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
     If vDetailClient <> Nil Then
      vDetailClient.Close;
    End;
  End;
End;

procedure TRESTDWClientSQL.ProcAfterEdit(DataSet: TDataSet);
Begin
 If Not vInBlockEvents Then
  If Assigned(vAfterEdit) Then
   vAfterEdit(Dataset);
End;

procedure TRESTDWClientSQL.ProcAfterInsert(DataSet: TDataSet);
Var
 I : Integer;
 vFields       : TStringList;
 vDetailClient : TRESTDWClientSQL;
 Procedure CloneDetails(Value : TRESTDWClientSQL; FieldName : String);
 Begin
  If (FindField(FieldName) <> Nil) And (Value.FindField(FieldName) <> Nil) Then
   FindField(FieldName).Value := Value.FindField(FieldName).Value;
 End;
 Procedure ParseFields(Value : String);
 Var
  vTempFields : String;
 Begin
  vFields.Clear;
  vTempFields := Value;
  While (vTempFields <> '') Do
   Begin
    If Pos(';', vTempFields) > 0 Then
     Begin
      vFields.Add(UpperCase(Trim(Copy(vTempFields, 1, Pos(';', vTempFields) -1))));
      System.Delete(vTempFields, 1, Pos(';', vTempFields));
     End
    Else
     Begin
      vFields.Add(UpperCase(Trim(vTempFields)));
      vTempFields := '';
     End;
    vTempFields := Trim(vTempFields);
   End;
 End;
Begin
 vDetailClient := vMasterDataSet;
 If (vDetailClient <> Nil) And (Fields.Count > 0) Then
  Begin
   vFields     := TStringList.Create;
   ParseFields(MasterFields);
   For I := 0 To vFields.Count -1 Do
    Begin
     If vDetailClient.FindField(vFields[I]) <> Nil Then
      CloneDetails(vDetailClient, vFields[I]);
    End;
   vFields.Free;
  End;
 If Not vInBlockEvents Then
  Begin
   If Trim(vUpdateTableName) <> '' Then
    Begin
     TMassiveDatasetBuffer(vMassiveDataset).NewBuffer(mmInsert);
     TMassiveDatasetBuffer(vMassiveDataset).BuildBuffer(Self, mmInsert);
    End;
   If Assigned(vAfterInsert) Then
    vAfterInsert(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterOpen(DataSet: TDataSet);
Begin
 If Not vInBlockEvents Then
  Begin
   If Assigned(vOnAfterOpen) Then
    vOnAfterOpen(Dataset);
  End;
End;

procedure TRESTDWClientSQL.ProcAfterCancel(DataSet: TDataSet);
Begin
 If Not vInBlockEvents Then
  Begin
   If Trim(vUpdateTableName) <> '' Then
    TMassiveDatasetBuffer(vMassiveDataset).ClearLine;
   If Assigned(vAfterCancel) Then
    vAfterCancel(Dataset);
  End;
End;

function TRESTDWClientSQL.ApplyUpdates(Var Error: String): Boolean;
Var
 vError       : Boolean;
 vErrorMSG,
 vMassiveJSON : String;
 vResult      : TJSONValue;
Begin
 Result  := False;
 vResult := Nil;
 If TMassiveDatasetBuffer(vMassiveDataset).RecordCount = 0 Then
  Error := 'No have data to "Applyupdates"...'
 Else
  Begin
   vMassiveJSON := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
   Result       := vMassiveJSON <> '';
   If Result Then
    Begin
     Result     := False;
     If vRESTDataBase <> Nil Then
      Begin
       If vAutoRefreshAfterCommit Then
        vRESTDataBase.ApplyUpdates(TMassiveDatasetBuffer(vMassiveDataset), vSQL, vParams, vError, vErrorMSG, vResult, vRESTClientPooler)
       Else
        vRESTDataBase.ApplyUpdates(TMassiveDatasetBuffer(vMassiveDataset), Nil,  vParams, vError, vErrorMSG, vResult, vRESTClientPooler);
       Result := Not vError;
       Error  := vErrorMSG;
       If Assigned(vResult) And (vAutoRefreshAfterCommit) Then
        Begin
         Try
          vActive := False;
          ProcBeforeOpen(Self);
          vInBlockEvents := True;
          Filter         := '';
          Filtered       := False;
          vActive        := GetData(vResult);
          If State = dsBrowse Then
           Begin
            If Trim(vUpdateTableName) <> '' Then
             TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
            PrepareDetails(True);
           End
          Else If State = dsInactive Then
           PrepareDetails(False);
         Except
          On E : Exception do
           Begin
            vInBlockEvents := False;
            If csDesigning in ComponentState Then
             Raise Exception.Create(PChar(E.Message))
            Else
             Begin
              If Assigned(vOnGetDataError) Then
               vOnGetDataError(False, E.Message)
              Else
               Raise Exception.Create(PChar(E.Message));
             End;
           End;
         End;
        End;
       If Assigned(vResult) Then
        FreeAndNil(vResult);
      End
     Else
      Error := 'Empty Database Property';
    End;
   If Result Then
    TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer
   Else
    Error := vErrorMSG;
  End;
End;

function TRESTDWClientSQL.ParamByName(Value: String): TParam;
Var
 I : Integer;
 vParamName,
 vTempParam : String;
 Function CompareValue(Value1, Value2 : String) : Boolean;
 Begin
   Result := Value1 = Value2;
 End;
Begin
 Result := Nil;
 For I := 0 to vParams.Count -1 do
  Begin
   vParamName := UpperCase(vParams[I].Name);
   vTempParam := UpperCase(Trim(Value));
   if CompareValue(vTempParam, vParamName) then
    Begin
     Result := vParams[I];
     Break;
    End;
  End;
End;

function TRESTDWClientSQL.ParamCount: Integer;
Begin
 Result := vParams.Count;
End;

procedure TRESTDWClientSQL.FieldDefsToFields;
Var
 I          : Integer;
 FieldValue : TField;
Begin
 For I := 0 To FieldDefs.Count -1 Do
  Begin
   FieldValue           := TField.Create(Self);
   FieldValue.DataSet   := Self;
   FieldValue.FieldName := FieldDefs[I].Name;
   FieldValue.SetFieldType(FieldDefs[I].DataType);
   FieldValue.Size      := FieldDefs[I].Size;
//   FieldValue.Offset    := FieldDefs[I].Precision;
   Fields.Add(FieldValue);
  End;
End;

function TRESTDWClientSQL.FirstWord(Value: String): String;
Var
 vTempValue : PChar;
Begin
 vTempValue := PChar(Trim(Value));
 While Not (vTempValue^ = #0) Do
  Begin
   If (vTempValue^ <> ' ') Then
    Result := Result + vTempValue^
   Else
    Break;
   Inc(vTempValue);
  End;
End;

procedure TRESTDWClientSQL.ExecOrOpen;
Var
 vError : String;
 Function OpenSQL : Boolean;
 Var
  vSQLText : String;
 Begin
  vSQLText := UpperCase(Trim(vSQL.Text));
  Result := FirstWord(vSQLText) = 'SELECT';
 End;
Begin
 If OpenSQL Then
  Open
 Else
  Begin
   If Not ExecSQL(vError) Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(False, vError)
       Else
        Raise Exception.Create(PChar(vError));
      End;
    End;
  End;
End;

function TRESTDWClientSQL.ExecSQL(Var Error: String): Boolean;
Var
 vError        : Boolean;
 vMessageError : String;
 vResult       : TJSONValue;
Begin
 Result := False;
 Try
  If vRESTDataBase <> Nil Then
   Begin
    vRESTDataBase.ExecuteCommand(vSQL, vParams, vError, vMessageError, vResult, True, vRESTClientPooler);
    Result := Not vError;
    Error  := vMessageError;
    If Assigned(vResult) Then
     FreeAndNil(vResult);
   End
  Else
   Raise Exception.Create(PChar('Empty Database Property'));
 Except
 End;
End;

function TRESTDWClientSQL.InsertMySQLReturnID: Integer;
Var
 vError        : Boolean;
 vMessageError : String;
Begin
 Result := -1;
 Try
  If vRESTDataBase <> Nil Then
   Result := vRESTDataBase.InsertMySQLReturnID(vSQL, vParams, vError, vMessageError, vRESTClientPooler)
  Else 
   Raise Exception.Create(PChar('Empty Database Property')); 
 Except
 End;
End;

procedure TRESTDWClientSQL.OnBeforeChangingSQL(Sender: TObject);
begin
 vOldSQL := vSQL.Text;
end;

procedure TRESTDWClientSQL.OnChangingSQL(Sender: TObject);
Begin
 GetNewData := vSQL.Text <> vOldSQL;
 CreateParams;
End;

procedure TRESTDWClientSQL.SetSQL(Value: TStringList);
Var
 I : Integer;
Begin
 vSQL.Clear;
 For I := 0 To Value.Count -1 do
  vSQL.Add(Value[I]);
End;

procedure TRESTDWClientSQL.CreateDataSet;
Begin
 vCreateDS := True;
 {$IFDEF FPC}
  TMemDataset(Self).Open;
 {$ELSE}
 {$IFDEF CLIENTDATASET}
     TClientDataset(Self).Open;
 {$ENDIF}
 {$IFDEF RESJEDI}
     TJvMemoryData(Self).Open;
 {$ENDIF}
 {$IFDEF RESTKBMMEMTABLE}
     Tkbmmemtable(self).open;
 {$ENDIF}
 {$IFDEF RESTFDMEMTABLE}
     TFDmemtable(self).open;
 {$ENDIF}

 {$ENDIF}
 vActive   := True;
 vCreateDS := False;
End;

procedure TRESTDWClientSQL.ClearMassive;
Begin
 If Trim(vUpdateTableName) <> '' Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   TMassiveDatasetBuffer(vMassiveDataset).ClearBuffer;
End;

procedure TRESTDWClientSQL.Close;
Begin
 vActive := False;
 vInactive := False;
 Inherited Close;
End;

procedure TRESTDWClientSQL.Open;
Begin
 Try
  If Not vInactive Then
   Begin
    If Not vActive Then
     SetActiveDB(True);
   End;
//  vInBlockEvents := True;
  If vActive Then
   Begin
    ProcAfterOpen(Self);
    Inherited Open;
   End;
 Finally
  vInBlockEvents := False;
 End;
End;

procedure TRESTDWClientSQL.Open(SQL: String);
Begin
 If Not vActive Then
  Begin
   Close;
   vSQL.Clear;
   vSQL.Add(SQL);
   SetActiveDB(True);
   Inherited Open;
  End;
End;

procedure TRESTDWClientSQL.OpenCursor(InfoQuery: Boolean);
Begin
 Try
  If (vRESTDataBase <> Nil) Then
   Begin
    vRESTDataBase.Active := True;
    If vRESTDataBase.Active Then
     Begin
      If csDesigning in ComponentState Then
       Begin
        If Not vActiveCursor then
         Begin
          Try
           SetActiveDB(True);
          Except
           vActiveCursor := False;
          End;
         End;
       End;
     End;
    If vRESTDataBase.Active Then
    begin
       Inherited OpenCursor(InfoQuery)
    end
    Else If csDesigning in ComponentState Then
     Raise Exception.Create(Name+': '+'Database Inactive...');
   End
  Else If csDesigning in ComponentState Then
   Raise Exception.Create(Name+': '+'Database not found...');
 Except
  On E : Exception do
   Begin
    If csDesigning in ComponentState Then
     Raise Exception.Create(Name+': '+PChar(E.Message))
    Else
     Begin
      If Assigned(vOnGetDataError) Then
       vOnGetDataError(False, Name+': '+E.Message)
      Else
       Raise Exception.Create(PChar(Name+': '+E.Message));
     End;
   End;
 End;
End;

procedure TRESTDWClientSQL.OldAfterPost(DataSet: TDataSet);
Var
 vError : String;
Begin
 vErrorBefore := False;
 If Not vReadData Then
  Begin
   If Not vInBlockEvents Then
    Begin
     Try
      If Trim(vUpdateTableName) <> '' Then
       If vAutoCommitData Then
        ApplyUpdates(vError);
      If vError <> '' Then
       Raise Exception.Create(vError)
      Else
       Begin
        If Assigned(vAfterPost) Then
         vAfterPost(Dataset);
        ProcAfterScroll(Dataset);
       End;
     Except

     End;
    End;
  End;
End;

procedure TRESTDWClientSQL.OldAfterDelete(DataSet: TDataSet);
Begin
 vErrorBefore := False;
 Try
  If Assigned(vOnAfterDelete) Then
   vOnAfterDelete(Self);
 Finally
  vReadData := False;
 End;
End;

procedure TRESTDWClientSQL.SetUpdateTableName(Value: String);
Begin
 vCommitUpdates    := Trim(Value) <> '';
 vUpdateTableName  := Value;
End;

procedure TRESTDWClientSQL.Loaded;
Begin
 Inherited Loaded;
End;

Function TRESTDWClientSQL.MassiveCount: Integer;
Begin
 Result := 0;
 If Trim(vUpdateTableName) <> '' Then
  Result := TMassiveDatasetBuffer(vMassiveDataset).RecordCount;
End;

Function TRESTDWClientSQL.MassiveToJSON : String;
Begin
 Result := '';
 If vMassiveDataset <> Nil Then
  If TMassiveDatasetBuffer(vMassiveDataset).RecordCount > 0 Then
   Result := TMassiveDatasetBuffer(vMassiveDataset).ToJSON;
End;

Procedure TRESTDWClientSQL.Newtable;
Begin
 TRESTDWClientSQL(Self).Inactive   := True;
 Try
 {$IFNDEF FPC}
  Self.Close;
  Self.Open;
 {$ELSE}
  If Self is TMemDataset Then
   TMemDataset(Self).CreateTable;
  Self.Open;
  TRESTDWClientSQL(Self).Active     := True;
 {$ENDIF}
 Finally
  TRESTDWClientSQL(Self).Inactive   := False;
 End;
end;

{$IFDEF FPC}
procedure TRESTDWClientSQL.CloneDefinitions(Source: TMemDataset;
  aSelf: TMemDataset);
{$ELSE}
{$IFDEF CLIENTDATASET}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TClientDataset; aSelf : TClientDataset);
{$ENDIF}
{$IFDEF RESJEDI}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TJvMemoryData; aSelf : TJvMemoryData);
{$ENDIF}
{$IFDEF RESTKBMMEMTABLE}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TKbmmemtable; aSelf : TKbmmemtable);
{$ENDIF}
{$IFDEF RESTFDMEMTABLE}
Procedure TRESTDWClientSQL.CloneDefinitions(Source : TFDmemtable; aSelf : TFDmemtable);
{$ENDIF}
{$ENDIF}
Var
 I, A : Integer;
Begin
 aSelf.Close;
 For I := 0 to Source.FieldDefs.Count -1 do
  Begin
   For A := 0 to aSelf.FieldDefs.Count -1 do
    If Uppercase(Source.FieldDefs[I].Name) = Uppercase(aSelf.FieldDefs[A].Name) Then
     Begin
      aSelf.FieldDefs.Delete(A);
      Break;
     End;
  End;
 For I := 0 to Source.FieldDefs.Count -1 do
  Begin
   If Trim(Source.FieldDefs[I].Name) <> '' Then
    Begin
     With aSelf.FieldDefs.AddFieldDef Do
      Begin
       Name     := Source.FieldDefs[I].Name;
       DataType := Source.FieldDefs[I].DataType;
       Size     := Source.FieldDefs[I].Size;
       Required := Source.FieldDefs[I].Required;
       CreateField(aSelf);
      End;
    End;
  End;
 If aSelf.FieldDefs.Count > 0 Then
  aSelf.Open;
End;

procedure TRESTDWClientSQL.PrepareDetailsNew;
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQL;
 vOldInBlock   : Boolean;
Begin
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     If vDetailClient.Active Then
      Begin
       vOldInBlock   := vDetailClient.InBlockEvents;
       Try
        vDetailClient.InBlockEvents := True;
        If Self.State = dsInsert Then
         vDetailClient.Newtable;
       Finally
        vDetailClient.InBlockEvents := vOldInBlock;
       End;
       vDetailClient.ProcAfterScroll(vDetailClient);
      End
     Else
      Begin
       If vDetailClient.Fields.Count > 0 Then
        Begin
         vOldInBlock   := vDetailClient.InBlockEvents;
         Try
          vDetailClient.InBlockEvents := True;
          vDetailClient.Active := True;
         Finally
          vDetailClient.InBlockEvents := vOldInBlock;
         End;
        End;
      End;
    End;
  End;
End;

procedure TRESTDWClientSQL.PrepareDetails(ActiveMode: Boolean);
Var
 I : Integer;
 vDetailClient : TRESTDWClientSQL;
 Procedure CloneDetails(Value : TRESTDWClientSQL);
 Var
  I : Integer;
 Begin
  For I := 0 To Value.Params.Count -1 Do
   Begin
    If FindField(Value.Params[I].Name) <> Nil Then
     Begin
      Value.Params[I].DataType := FindField(Value.Params[I].Name).DataType;
      Value.Params[I].Size     := FindField(Value.Params[I].Name).Size;
      Value.Params[I].Value    := FindField(Value.Params[I].Name).Value;
     End;
   End;
 End;
Begin
 If vReadData Then
  Exit;
 If vMasterDetailList <> Nil Then
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
   vDetailClient        := TRESTDWClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     vDetailClient.Active := False;
     CloneDetails(vDetailClient);
     vDetailClient.Active := ActiveMode;
    End;
  End;
End;

function TRESTDWClientSQL.GetData(DataSet: TJSONValue): Boolean;
Var
 LDataSetList  : TJSONValue;
 vError        : Boolean;
 vValue,
 vMessageError : String;
Begin
 Result := False;
 LDataSetList := nil;
 Self.Close;
 vActiveCursor := True;
 If Assigned(vRESTDataBase) Then
  Begin
   Try
    If DataSet = Nil Then
     Begin
      vRESTDataBase.ExecuteCommand(vSQL, vParams, vError, vMessageError, LDataSetList, False, vRESTClientPooler);
      If LDataSetList <> Nil Then
       Begin
        LDataSetList.Encoded := vRESTDataBase.EncodeStrings;
        vValue := LDataSetList.ToJSON;
       End;
     End
    Else
     Begin
      LDataSetList         := DataSet;
      vError               := False;
      vValue               := LDataSetList.Value;
     End;
    If (Assigned(LDataSetList)) And (Not (vError)) Then
     Begin
      Try
       LDataSetList.WriteToDataset(dtFull, vValue, Self);
       Result := True;
      Except
      End;
     End;
   Except
   End;
   If (LDataSetList <> Nil) And
      (DataSet = Nil) Then
    FreeAndNil(LDataSetList);
   If vError Then
    Begin
     If csDesigning in ComponentState Then
      Raise Exception.Create(PChar(vMessageError))
     Else
      Begin
       If Assigned(vOnGetDataError) Then
        vOnGetDataError(Not(vError), vMessageError)
       Else
        Raise Exception.Create(PChar(vMessageError));
      End;
    End;
  End
 Else If csDesigning in ComponentState Then
  Raise Exception.Create(PChar('Empty Database Property'));
 vActiveCursor := False;
End;

procedure TRESTDWClientSQL.SaveToStream(Var Stream: TMemoryStream);
Begin

End;

Procedure TRESTDWClientSQL.CreateMassiveDataset;
Begin
 If Trim(vUpdateTableName) <> '' Then
  TMassiveDatasetBuffer(vMassiveDataset).BuildDataset(Self, Trim(vUpdateTableName));
End;

procedure TRESTDWClientSQL.SetActiveDB(Value: Boolean);
Begin
 If vInactive then
  Begin
   vActive := Value;
   If vActive Then
    Begin
     {$IFDEF FPC}
      TMemDataset(Self).Open;
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
     {$IFDEF RESTFDMEMTABLE}
      TFDmemtable(Self).Open;
     {$ENDIF}
     {$ENDIF}
    End
   Else
    Begin
     {$IFDEF FPC}
      TMemDataset(Self).Close;
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
     {$IFDEF RESTFDMEMTABLE}
      TFDmemtable(Self).Close;
     {$ENDIF}
     {$ENDIF}
     TRESTDWClientSQL(Self).Close;
    End;
   Exit;
  End;
 vActive := False;
 If (vRESTDataBase <> Nil) And (Value) Then
  Begin
   If vRESTDataBase <> Nil Then
    If Not vRESTDataBase.Active Then
     vRESTDataBase.Active := True;
   If Not vRESTDataBase.Active then
    Begin
     vActive := False;
     Exit;
    End;
   Try
    If (Not(vActive) And (Value)) Or (GetNewData) Then
     Begin
      ProcBeforeOpen(Self);
      vInBlockEvents := True;
      Filter         := '';
      Filtered       := False;
      vActive        := GetData;
      GetNewData     := Not vActive;
     End;
    If State = dsBrowse Then
     Begin
      CreateMassiveDataset;
      PrepareDetails(True);
     End
    Else If State = dsInactive Then
     PrepareDetails(False);
   Except
    On E : Exception do
     Begin
      vInBlockEvents := False;
      If csDesigning in ComponentState Then
       Raise Exception.Create(PChar(E.Message))
      Else
       Begin
        If Assigned(vOnGetDataError) Then
         vOnGetDataError(False, E.Message)
        Else
         Raise Exception.Create(PChar(E.Message));
       End;
     End;
   End;
  End
 Else
  Begin
   vActive := False;
   Close;
   If Value Then
    If vRESTDataBase = Nil Then
     Raise Exception.Create(PChar('Empty Database Property'));
  End;
End;

procedure TRESTDWClientSQL.SetCacheUpdateRecords(Value: Boolean);
Begin
 vCacheUpdateRecords := Value;
End;

constructor TRESTDWStoredProc.Create(AOwner: TComponent);
begin
 Inherited;
 vParams   := TParams.Create(Self);
 vProcName := '';
end;

destructor TRESTDWStoredProc.Destroy;
begin
 vParams.Free;
 Inherited;
end;

Function TRESTDWStoredProc.ExecProc(Var Error : String) : Boolean;
Begin
 If vRESTDataBase <> Nil Then
  Begin
   If vParams.Count > 0 Then
    vRESTDataBase.ExecuteProcedure(vProcName, vParams, Result, Error);
  End
 Else
  Raise Exception.Create(PChar('Empty Database Property'));
End;

Function TRESTDWStoredProc.ParamByName(Value: String): TParam;
Begin
 Result := Params.ParamByName(Value);
End;

procedure TRESTDWStoredProc.SetDataBase(const Value: TRESTDWDataBase);
begin
 vRESTDataBase := Value;
end;

Procedure TRESTDWDataBase.SetMyIp(Value: String);
Begin
End;

function TRESTDWClientSQL.FieldDefExist(Value: String): TFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To FieldDefs.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(FieldDefs[I].Name) Then
    Begin
     Result := FieldDefs[I];
     Break;
    End;
  End;
End;

Function TRESTDWClientSQL.FieldExist(Value: String): TField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Fields.Count -1 Do
  Begin
   If UpperCase(Value) = UpperCase(Fields[I].Name) Then
    Begin
     Result := Fields[I];
     Break;
    End;
  End;
End;

{ TRESTDWDriver }

Constructor TRESTDWDriver.Create(AOwner: TComponent);
Begin
 Inherited;
 vEncodeStrings   := True;
 {$IFDEF FPC}
 vDatabaseCharSet := csUndefined;
 {$ENDIF}
 vCommitRecords   := 100;
End;

end.
