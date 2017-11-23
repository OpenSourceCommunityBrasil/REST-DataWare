{
 Esse pacote de Componentes foi desenhado com o Objetivo de ajudar as pessoas a desenvolverem
com WebServices REST o mais próximo possível do desenvolvimento local DB, com componentes de
fácil configuração para que todos tenham acesso as maravilhas dos WebServices REST/JSON DataSnap.

Desenvolvedor Principal : Gilberto Rocha da Silva (XyberX)
Empresa : XyberPower Desenvolvimento
}

unit uRestPoolerDB;

interface

uses System.SysUtils,         System.Classes,
     FireDAC.Stan.Intf,       FireDAC.Stan.Option,     FireDAC.Stan.Param,
     FireDAC.Stan.Error,      FireDAC.DatS,            FireDAC.Stan.Async,
     FireDAC.DApt,            FireDAC.UI.Intf,         FireDAC.Stan.Def,
     FireDAC.Stan.Pool,       FireDAC.Comp.Client,     FireDAC.Comp.UI,
     FireDAC.Comp.DataSet,    FireDAC.DApt.Intf,       Data.DBXJSON,
     Data.DB,                 Data.FireDACJSONReflect, Data.DBXJSONReflect,
     IPPeerClient,            Datasnap.DSClientRest,   System.SyncObjs,
     uPoolerMethod,            Data.DBXPlatform
      {$IFDEF MSWINDOWS},      Datasnap.DSServer,
     Datasnap.DSAuth,         Datasnap.DSProxyRest     {$ENDIF},
     Soap.EncdDecd,           uMasterDetailData,
     DbxCompressionFilter,    uRestCompressTools,      System.ZLib,
     uPoolerServerMethods
     {$if CompilerVersion >= 28}
       ,System.NetEncoding, System.JSON, FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin
     {$endif};

Type
 TEncodeSelect            = (esASCII, esUtf8);
 TOnEventDB               = Procedure (DataSet : TDataSet)         of Object;
 TOnAfterScroll           = Procedure (DataSet : TDataSet)         of Object;
 TOnAfterOpen             = Procedure (DataSet : TDataSet)         of Object;
 TOnAfterClose            = Procedure (DataSet : TDataSet)         of Object;
 TOnAfterInsert           = Procedure (DataSet : TDataSet)         of Object;
 TOnBeforeDelete          = Procedure (DataSet : TDataSet)         of Object;
 TOnBeforePost            = Procedure (DataSet : TDataSet)         of Object;
 TOnAfterPost             = Procedure (DataSet : TDataSet)         of Object;
 TExecuteProc             = Reference to Procedure;
 TOnEventConnection       = Procedure (Sucess  : Boolean;
                                       Const Error : String)       of Object;
 TOnEventBeforeConnection = Procedure (Sender  : TComponent)       of Object;
 TOnEventTimer            = Procedure of Object;
 TBeforeGetRecords        = Procedure (Sender  : TObject;
                                       Var OwnerData : OleVariant) of Object;

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

Type
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
 TRESTDataBase = Class(TComponent)
 Private
  Owner                : TComponent;                 //Proprietario do Componente
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
  vCompression,                                      //Se Vai haver compressão de Dados
  vConnected           : Boolean;                    //Diz o Estado da Conexão
  vOnEventConnection   : TOnEventConnection;         //Evento de Estado da Conexão
  vOnBeforeConnection  : TOnEventBeforeConnection;   //Evento antes de Connectar o Database
  vAutoCheckData       : TAutoCheckData;             //Autocheck de Conexão
  vTimeOut             : Integer;
  VEncondig            : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vContentex           : String ;                    //Contexto - Alexandre Abade
  vRESTContext         : String ;                    //RestContexto - Alexandre Abade
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len        : Boolean;
  vParamCreate         : Boolean;
  Procedure SetConnection(Value : Boolean);          //Seta o Estado da Conexão
  Procedure SetRestPooler(Value : String);           //Seta o Restpooler a ser utilizado
  Procedure SetPoolerPort(Value : Integer);          //Seta a Porta do Pooler a ser usada
  Procedure CheckConnection;                         //Checa o Estado automatico da Conexão
  Function  TryConnect : Boolean;                    //Tenta Conectar o Servidor para saber se posso executar comandos
  Procedure SetConnectionOptions(Var Value : TDSRestConnection); //Seta as Opções de Conexão
  Function  ExecuteCommand  (Var SQL    : TStringList;
                             Var Params : TParams;
                             Var Error  : Boolean;
                             Var MessageError : String;
                             Execute    : Boolean = False) : TFDJSONDataSets;
  Procedure ExecuteProcedure(ProcName         : String;
                             Params           : TParams;
                             Var Error        : Boolean;
                             Var MessageError : String);
  Procedure ApplyUpdates(Var SQL          : TStringList;
                         Var Params       : TParams;
                         ADeltaList       : TFDJSONDeltas;
                         TableName        : String;
                         Var Error        : Boolean;
                         Var MessageError : String);
  Function InsertMySQLReturnID(Var SQL          : TStringList;
                               Var Params       : TParams;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;
  Function GetStateDB : Boolean;
 Public
  Function    GetRestPoolers : TStringList;          //Retorna a Lista de DataSet Sources do Pooler
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
  Procedure   Close;
  Procedure   Open;
  Property    Connected       : Boolean                  Read GetStateDB          Write SetConnection;
 Published
  Property OnConnection       : TOnEventConnection       Read vOnEventConnection  Write vOnEventConnection; //Evento relativo a tudo que acontece quando tenta conectar ao Servidor
  Property OnBeforeConnect    : TOnEventBeforeConnection Read vOnBeforeConnection Write vOnBeforeConnection; //Evento antes de Connectar o Database
  Property Active             : Boolean                  Read vConnected          Write SetConnection;      //Seta o Estado da Conexão
  Property Compression        : Boolean                  Read vCompression        Write vCompression;       //Compressão de Dados
  Property MyIP               : String                   Read vMyIP;
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
  Property Encoding           : TEncodeSelect            Read VEncondig           Write VEncondig;          //Encoding da string
  Property Context            : string                   Read vContentex          Write vContentex;         //Contexto
  Property RESTContext        : string                   Read vRESTContext        Write vRESTContext;       //Rest Contexto
  Property StrsTrim           : Boolean                  Read vStrsTrim           Write vStrsTrim;
  Property StrsEmpty2Null     : Boolean                  Read vStrsEmpty2Null     Write vStrsEmpty2Null;
  Property StrsTrim2Len       : Boolean                  Read vStrsTrim2Len       Write vStrsTrim2Len;
  Property ParamCreate        : Boolean                  read vParamCreate        write vParamCreate;
End;

Type
 TRESTClientSQL   = Class(TFDMemTable)                    //Classe com as funcionalidades de um DBQuery
 Private
  vOldStatus           : TDatasetState;
  vDataSource          : TDataSource;
  vOnAfterScroll       : TOnAfterScroll;
  vOnAfterOpen         : TOnAfterOpen;
  vOnAfterClose        : TOnAfterClose;
  vOnAfterInsert       : TOnAfterInsert;
  vOnBeforeDelete      : TOnBeforeDelete;
  vOnBeforePost        : TOnBeforePost;
  vOnAfterPost         : TOnAfterPost;
  Owner                : TComponent;
  OldData              : TMemoryStream;
  vActualRec           : Integer;
  vUpdateTableName     : String;                          //Tabela que será feito Update no Servidor se for usada Reflexão de Dados
  vCacheUpdateRecords,
  vReadData,
  vCascadeDelete,
  vBeforeClone,
  vDataCache,                                             //Se usa cache local
  vConnectedOnce,                                         //Verifica se foi conectado ao Servidor
  vCommitUpdates,
  vCreateDS,
  vErrorBefore,
  vActive              : Boolean;                         //Estado do Dataset
  vSQL                 : TStringList;                     //SQL a ser utilizado na conexão
  vParams              : TParams;                         //Parametros de Dataset
  vCacheDataDB         : TFDDataset;                      //O Cache de Dados Salvo para utilização rápida
  vOnGetDataError      : TOnEventConnection;              //Se deu erro na hora de receber os dados ou não
  vRESTDataBase        : TRESTDataBase;                   //RESTDataBase do Dataset
  vOnAfterDelete       : TDataSetNotifyEvent;
  FieldDefsUPD         : TFieldDefs;
  vMasterDataSet       : TRESTClientSQL;
  vMasterDetailList    : TMasterDetailList;               //DataSet MasterDetail Function
  Procedure CloneDefinitions(Source : TFDMemTable;
                             aSelf  : TRESTClientSQL);    //Fields em Definições
  Procedure OnChangingSQL(Sender: TObject);               //Quando Altera o SQL da Lista
  Procedure SetActiveDB(Value : Boolean);                 //Seta o Estado do Dataset
  Procedure SetSQL(Value : TStringList);                  //Seta o SQL a ser usado
  Procedure CreateParams;                                 //Cria os Parametros na lista de Dataset
  Procedure SetDataBase(Value : TRESTDataBase);           //Diz o REST Database
  Function  GetData : Boolean;                            //Recebe os Dados da Internet vindo do Servidor REST
  Procedure SetUpdateTableName(Value : String);           //Diz qual a tabela que será feito Update no Banco
  Procedure OldAfterPost(DataSet: TDataSet);              //Eventos do Dataset para realizar o AfterPost
  Procedure OldAfterDelete(DataSet: TDataSet);            //Eventos do Dataset para realizar o AfterDelete
  Procedure SetMasterDataSet(Value : TRESTClientSQL);
  Procedure PrepareDetails(ActiveMode : Boolean);
  Procedure SetCacheUpdateRecords(Value : Boolean);
  Procedure PrepareDetailsNew;
  Function  FirstWord(Value : String) : String;
  Property  MasterSource;
  Procedure ProcAfterScroll (DataSet : TDataSet);
  Procedure ProcAfterOpen   (DataSet : TDataSet);
  Procedure ProcAfterClose  (DataSet : TDataSet);
  Procedure ProcAfterInsert (DataSet : TDataSet);
  Procedure ProcBeforeDelete(DataSet : TDataSet);
  Procedure ProcBeforePost  (DataSet : TDataSet);
  Procedure ProcAfterPost   (DataSet : TDataSet);
 Protected
  Function  CanObserve(const ID: Integer): Boolean; Override;
 Public
  //Métodos
  Procedure   Open;Overload; Virtual;                     //Método Open que será utilizado no Componente
  Procedure   Open(SQL: String);Overload; Virtual;        //Método Open que será utilizado no Componente
  Procedure   ExecOrOpen;                                 //Método Open que será utilizado no Componente
  Procedure   Close;Virtual;                              //Método Close que será utilizado no Componente
  Procedure   CreateDataSet; virtual;
  Function    ExecSQL(Var Error : String) : Boolean;      //Método ExecSQL que será utilizado no Componente
  Function    InsertMySQLReturnID : Integer;              //Método de ExecSQL com retorno de Incremento
  Function    ParamByName(Value : String) : TParam;       //Retorna o Parametro de Acordo com seu nome
  Function    ApplyUpdates(var Error : String) : Boolean; //Aplica Alterações no Banco de Dados
  Constructor Create(AOwner : TComponent);Override;       //Cria o Componente
  Destructor  Destroy;Override;                           //Destroy a Classe
  Procedure   Loaded; Override;
  procedure   OpenCursor(InfoQuery: Boolean); Override;   //Subscrevendo o OpenCursor para não ter erros de ADD Fields em Tempo de Design
  Procedure   GotoRec(Const RecNo : Integer);
  Function    ParamCount : Integer;
  Procedure   DynamicFilter(Field, Value : String; InText : Boolean = False);
  procedure   Refresh;
 Published
  Property MasterDataSet       : TRESTClientSQL      Read vMasterDataSet            Write SetMasterDataSet;
  Property MasterCascadeDelete : Boolean             Read vCascadeDelete            Write vCascadeDelete;
  Property AfterDelete         : TDataSetNotifyEvent Read vOnAfterDelete            Write vOnAfterDelete;
  Property OnGetDataError      : TOnEventConnection  Read vOnGetDataError           Write vOnGetDataError;         //Recebe os Erros de ExecSQL ou de GetData
  Property AfterScroll         : TOnAfterScroll      Read vOnAfterScroll            Write vOnAfterScroll;
  Property AfterOpen           : TOnAfterOpen        Read vOnAfterOpen              Write vOnAfterOpen;
  Property AfterClose          : TOnAfterClose       Read vOnAfterClose             Write vOnAfterClose;
  Property AfterInsert         : TOnAfterInsert      Read vOnAfterInsert            Write vOnAfterInsert;
  Property BeforeDelete        : TOnBeforeDelete     Read vOnBeforeDelete           Write vOnBeforeDelete;
  Property BeforePost          : TOnBeforePost       Read vOnBeforePost             Write vOnBeforePost;
  Property AfterPost           : TOnAfterPost        Read vOnAfterPost              Write vOnAfterPost;
  Property Active              : Boolean             Read vActive                   Write SetActiveDB;             //Estado do Dataset
  Property DataCache           : Boolean             Read vDataCache                Write vDataCache;              //Diz se será salvo o último Stream do Dataset
  Property Params              : TParams             Read vParams                   Write vParams;                 //Parametros de Dataset
  Property DataBase            : TRESTDataBase       Read vRESTDataBase             Write SetDataBase;             //Database REST do Dataset
  Property SQL                 : TStringList         Read vSQL                      Write SetSQL;                  //SQL a ser Executado
  Property UpdateTableName     : String              Read vUpdateTableName          Write SetUpdateTableName;      //Tabela que será usada para Reflexão de Dados
  Property CacheUpdateRecords  : Boolean             Read vCacheUpdateRecords       Write SetCacheUpdateRecords;
End;

Type
 TRESTStoredProc = Class(TComponent)
 Private
  Owner         : TComponent;
  vParams       : TParams;
  vProcName     : String;
  vRESTDataBase : TRESTDataBase;
  procedure SetDataBase(Const Value : TRESTDataBase);
 Public
  Constructor Create   (AOwner      : TComponent);Override; //Cria o Componente
  Function    ExecProc (Var Error   : String) : Boolean;
  Destructor  Destroy;Override;                             //Destroy a Classe
  Function    ParamByName(Value : String) : TParam;
 Published
  Property DataBase            : TRESTDataBase       Read vRESTDataBase Write SetDataBase;             //Database REST do Dataset
  Property Params              : TParams             Read vParams       Write vParams;                 //Parametros de Dataset
  Property ProcName            : String              Read vProcName     Write vProcName;               //Procedure a ser Executada
End;

Type
 TRESTPoolerList = Class(TComponent)
 Private
  Owner                : TComponent;                 //Proprietario do Componente
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
  Procedure SetConnectionOptions(Var Value : TDSRestConnection); //Seta as Opções de Conexão
 Public
  Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property Active             : Boolean                  Read vConnected          Write SetConnection;      //Seta o Estado da Conexão
  Property Login              : String                   Read vLogin              Write vLogin;             //Login do Usuário caso haja autenticação
  Property Password           : String                   Read vPassword           Write vPassword;          //Senha do Usuário caso haja autenticação
  Property Proxy              : Boolean                  Read vProxy              Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions       : TProxyOptions            Read vProxyOptions       Write vProxyOptions;      //Se tem Proxy diz quais as opções
  Property PoolerService      : String                   Read vRestWebService     Write vRestWebService;    //Host do WebService REST
  Property PoolerURL          : String                   Read vRestURL            Write vRestURL;           //URL do WebService REST
  Property PoolerPort         : Integer                  Read vPoolerPort         Write SetPoolerPort;      //A Porta do Pooler do DataSet
  Property PoolerPrefix       : String                   Read vPoolerPrefix       Write vPoolerPrefix;      //Prefixo do WebService REST
  Property Poolers            : TStringList              Read vPoolerList;
End;

{$IFDEF MSWINDOWS}
Type
 TRESTDriver    = Class(TComponent)
 Private
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vCompression       : Boolean;
  vEncoding          : TEncodeSelect;
  vParamCreate       : Boolean;
 Public
  Procedure ApplyChanges        (TableName,
                                 SQL               : String;
                                 Params            : TParams;
                                 Var Error         : Boolean;
                                 Var MessageError  : String;
                                 Const ADeltaList  : TFDJSONDeltas);Overload;Virtual; abstract;
  Procedure ApplyChanges        (TableName,
                                 SQL               : String;
                                 Var Error         : Boolean;
                                 Var MessageError  : String;
                                 Const ADeltaList  : TFDJSONDeltas);Overload;Virtual; abstract;
  Function ExecuteCommand       (SQL        : String;
                                 Var Error  : Boolean;
                                 Var MessageError : String;
                                 Execute    : Boolean = False) : TFDJSONDataSets;Overload;Virtual;abstract;
  Function ExecuteCommand       (SQL              : String;
                                 Params           : TParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Execute          : Boolean = False) : TFDJSONDataSets;Overload;Virtual;abstract;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Virtual;abstract;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Params           : TParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Virtual;abstract;
  Procedure ExecuteProcedure    (ProcName         : String;
                                 Params           : TParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Virtual;abstract;
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Virtual;abstract;
  Procedure Close;Virtual;abstract;
 Public
  Property StrsTrim       : Boolean       Read vStrsTrim       Write vStrsTrim;
  Property StrsEmpty2Null : Boolean       Read vStrsEmpty2Null Write vStrsEmpty2Null;
  Property StrsTrim2Len   : Boolean       Read vStrsTrim2Len   Write vStrsTrim2Len;
  Property Compression    : Boolean       Read vCompression    Write vCompression;
  Property Encoding       : TEncodeSelect Read vEncoding       Write vEncoding;
  property ParamCreate    : Boolean       read vParamCreate    write vParamCreate;
End;
//PoolerDB Control
Type
 TRESTPoolerDBP = ^TComponent;
 TRESTPoolerDB  = Class(TComponent)
 Private
  Owner          : TComponent;
  FLock          : TCriticalSection;
  vRESTDriverBack,
  vRESTDriver    : TRESTDriver;
  vActive,
  vStrsTrim,
  vStrsEmpty2Null,
  vStrsTrim2Len,
  vCompression   : Boolean;
  vEncoding      : TEncodeSelect;
  vMessagePoolerOff : String;
  vParamCreate   : Boolean;
  Procedure SetConnection(Value : TRESTDriver);
  Function  GetConnection  : TRESTDriver;
 Public
  Procedure ApplyChanges(TableName,
                         SQL               : String;
                         Params            : TParams;
                         Var Error         : Boolean;
                         Var MessageError  : String;
                         Const ADeltaList  : TFDJSONDeltas);Overload;
  Procedure ApplyChanges(TableName,
                         SQL               : String;
                         Var Error         : Boolean;
                         Var MessageError  : String;
                         Const ADeltaList  : TFDJSONDeltas);Overload;
  Function ExecuteCommand(SQL        : String;
                          Var Error  : Boolean;
                          Var MessageError : String;
                          Execute    : Boolean = False) : TFDJSONDataSets;Overload;
  Function ExecuteCommand(SQL              : String;
                          Params           : TParams;
                          Var Error        : Boolean;
                          Var MessageError : String;
                          Execute          : Boolean = False) : TFDJSONDataSets;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Function InsertMySQLReturnID(SQL              : String;
                               Params           : TParams;
                               Var Error        : Boolean;
                               Var MessageError : String) : Integer;Overload;
  Procedure ExecuteProcedure  (ProcName         : String;
                               Params           : TParams;
                               Var Error        : Boolean;
                               Var MessageError : String);
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                     //Destroy a Classe
 Published
  Property    RESTDriver       : TRESTDriver   Read GetConnection     Write SetConnection;
  Property    Compression      : Boolean       Read vCompression      Write vCompression;
  Property    Encoding         : TEncodeSelect Read vEncoding         Write vEncoding;
  Property    StrsTrim         : Boolean       Read vStrsTrim         Write vStrsTrim;
  Property    StrsEmpty2Null   : Boolean       Read vStrsEmpty2Null   Write vStrsEmpty2Null;
  Property    StrsTrim2Len     : Boolean       Read vStrsTrim2Len     Write vStrsTrim2Len;
  Property    Active           : Boolean       Read vActive           Write vActive;
  Property    PoolerOffMessage : String        Read vMessagePoolerOff Write vMessagePoolerOff;
  Property    ParamCreate      : Boolean       Read vParamCreate      Write vParamCreate;
End;
{$ENDIF}

Function DecodeStrings(Value : String;Encoding:TEncoding) : String;
Function GetEncoding(Avalue : TEncodeSelect) : TEncoding;
Function EncodeStrings(Value : String) : String;
Procedure doUnGZIP(Input, gZipped : TMemoryStream);//helper function
Procedure doGZIP  (Input, gZipped : TMemoryStream);//helper function

implementation

Procedure doGZIP(Input, gZipped : TMemoryStream);//helper function
Const
 GZIP = 31;//very important because gzip is a linux zip format
Var
 CompactadorGZip : TZCompressionStream;
Begin
 Input.Position   := 0;
 CompactadorGZip  := TZCompressionStream.Create(gZipped, zcMax, GZIP);
 CompactadorGZip.CopyFrom(Input, Input.Size);
 CompactadorGZip.Free;
 gZipped.Position := 0;
End;

Procedure doUnGZIP(Input, gZipped : TMemoryStream);//helper function
Const
 GZIP = 31;//very important because gzip is a linux zip format
Var
 CompactadorGZip : TZDecompressionStream;
Begin
 Input.Position   := 0;
 CompactadorGZip  := TZDecompressionStream.Create(Input, GZIP);
 gZipped.CopyFrom(CompactadorGZip, CompactadorGZip.Size);
 CompactadorGZip.Free;
 gZipped.Position := 0;
End;

Function GetEncoding(Avalue : TEncodeSelect) : TEncoding;
Begin
 Result := TEncoding.utf8; // definido como padrão para suprimir Warn no delphi
 Case Avalue of
  esUtf8  : Result := TEncoding.utf8;
  esASCII : Result := TEncoding.ASCII;
 End;
End;

Function EncodeStrings(Value : String) : String;
Var
 Input,
 Output : TStringStream;
Begin
 Input := TStringStream.Create(Value, TEncoding.ASCII);
 Try
  Input.Position := 0;
  Output := TStringStream.Create('', TEncoding.ASCII);
  Try
   Soap.EncdDecd.EncodeStream(Input, Output);
   Result := Output.DataString;
  Finally
   Output.Free;
  End;
 Finally
  Input.Free;
 End;
End;

Function DecodeStrings(Value : String;Encoding:TEncoding) : String;
Var
 Input,
 Output : TStringStream;
Begin
 If Length(Value) > 0 Then
  Begin
   Input := TStringStream.Create(Value, Encoding);
   Try
    Output := TStringStream.Create('', Encoding);
    Try
     Soap.EncdDecd.DecodeStream(Input, Output);
     Output.Position := 0;
     Try
      Result := Output.DataString;
     Except
      Raise;
     End;
    Finally
     Output.Free;
    End;
   Finally
    Input.Free;
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

{$IFDEF MSWINDOWS}
Function  TRESTPoolerDB.GetConnection : TRESTDriver;
Begin
 Result := vRESTDriverBack;
End;

Procedure TRESTPoolerDB.SetConnection(Value : TRESTDriver);
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

Function TRESTPoolerDB.InsertMySQLReturnID(SQL              : String;
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

Function TRESTPoolerDB.InsertMySQLReturnID(SQL              : String;
                                           Params           : TParams;
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

Function TRESTPoolerDB.ExecuteCommand(SQL        : String;
                                      Var Error  : Boolean;
                                      Var MessageError : String;
                                      Execute    : Boolean = False) : TFDJSONDataSets;
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

Function TRESTPoolerDB.ExecuteCommand(SQL              : String;
                                      Params           : TParams;
                                      Var Error        : Boolean;
                                      Var MessageError : String;
                                      Execute          : Boolean = False) : TFDJSONDataSets;
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

Procedure TRESTPoolerDB.ExecuteProcedure(ProcName         : String;
                                         Params           : TParams;
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

Procedure TRESTPoolerDB.ExecuteProcedurePure(ProcName         : String;
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

Procedure TRESTPoolerDB.ApplyChanges(TableName,
                                     SQL               : String;
                                     Var Error         : Boolean;
                                     Var MessageError  : String;
                                     Const ADeltaList  : TFDJSONDeltas);
begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   vRESTDriver.ApplyChanges(TableName, SQL, Error, MessageError, ADeltaList);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
end;

Procedure TRESTPoolerDB.ApplyChanges(TableName,
                                     SQL               : String;
                                     Params            : TParams;
                                     Var Error         : Boolean;
                                     Var MessageError  : String;
                                     Const ADeltaList  : TFDJSONDeltas);
begin
 If vRESTDriver <> Nil Then
  Begin
   vRESTDriver.vStrsTrim          := vStrsTrim;
   vRESTDriver.vStrsEmpty2Null    := vStrsEmpty2Null;
   vRESTDriver.vStrsTrim2Len      := vStrsTrim2Len;
   vRESTDriver.vCompression       := vCompression;
   vRESTDriver.vEncoding          := vEncoding;
   vRESTDriver.vParamCreate       := vParamCreate;
   vRESTDriver.ApplyChanges(TableName, SQL, Params, Error, MessageError, ADeltaList);
  End
 Else
  Begin
   Error        := True;
   MessageError := 'Selected Pooler Does Not Have a Driver Set';
  End;
end;

Constructor TRESTPoolerDB.Create(AOwner : TComponent);
Begin
 Inherited;
 Owner             := aOwner;
 FLock             := TCriticalSection.Create;
 vCompression      := True;
 vStrsTrim         := False;
 vStrsEmpty2Null   := False;
 vStrsTrim2Len     := True;
 vActive           := True;
 vEncoding         := esUtf8;
 vMessagePoolerOff := 'RESTPooler not active.';
 vParamCreate      := True;
End;

Destructor  TRESTPoolerDB.Destroy;
Begin
 FLock.Release;
 FLock.DisposeOf;
 Inherited;
End;
{$ENDIF}

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
 FLock.DisposeOf;
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

Procedure TRESTPoolerList.SetConnectionOptions(Var Value : TDSRestConnection);
Begin
 Value                   := TDSRestConnection.Create(Nil);
 Value.LoginPrompt       := False;
 Value.PreserveSessionID := False;
 Value.Protocol          := 'http';
 Value.Host              := vRestWebService;
 Value.Port              := vPoolerPort;
 Value.UrlPath           := vRestURL;
 Value.UserName          := vLogin;
 Value.Password          := vPassword;
 if vProxy then
  Begin
   Value.ProxyHost     := vProxyOptions.vServer;
   Value.ProxyPort     := vProxyOptions.vPort;
   Value.ProxyUsername := vProxyOptions.vLogin;
   Value.ProxyPassword := vProxyOptions.vPassword;
  End
 Else
  Begin
   Value.ProxyHost     := '';
   Value.ProxyPort     := 0;
   Value.ProxyUsername := '';
   Value.ProxyPassword := '';
  End;
End;

Procedure TRESTDataBase.SetConnectionOptions(Var Value : TDSRestConnection);
Begin
 Value                     := TDSRestConnection.Create(Nil);
 Value.LoginPrompt         := False;
 Value.PreserveSessionID   := False;
 Value.Protocol            := 'http';
 Value.Host                := vRestWebService;
 Value.Port                := vPoolerPort;
 Value.UrlPath             := vRestURL;
 Value.UserName            := vLogin;
 Value.Password            := vPassword;
 {$if CompilerVersion >= 28}
 Value.HTTP.ConnectTimeout := vTimeOut;
 {$endif}
 Value.RESTContext         := vRESTContext;
 Value.Context             := vContentex;
 If vProxy Then
  Begin
   Value.ProxyHost     := vProxyOptions.vServer;
   Value.ProxyPort     := vProxyOptions.vPort;
   Value.ProxyUsername := vProxyOptions.vLogin;
   Value.ProxyPassword := vProxyOptions.vPassword;
  End
 Else
  Begin
   Value.ProxyHost     := '';
   Value.ProxyPort     := 0;
   Value.ProxyUsername := '';
   Value.ProxyPassword := '';
  End;
End;

Procedure TRESTDataBase.ApplyUpdates(Var SQL          : TStringList;
                                     Var Params       : TParams;
                                     ADeltaList       : TFDJSONDeltas;
                                     TableName        : String;
                                     Var Error        : Boolean;
                                     Var MessageError : String);
Var
 vDSRConnection    : TDSRestConnection;
 vRESTConnectionDB : TSMPoolerMethodClient;
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
Begin
 if vRestPooler = '' then
  Exit;
 SetConnectionOptions(vDSRConnection);
 vRESTConnectionDB := TSMPoolerMethodClient.Create(vDSRConnection, True);
 vRESTConnectionDB.Compression := vCompression;
 vRESTConnectionDB.Encoding    := GetEncoding(VEncondig);
 Try
  If Params.Count > 0 Then
   vRESTConnectionDB.ApplyChanges(vRestPooler,
                                  vRestModule,
                                  TableName,
                                  GetLineSQL(SQL),
                                  Params,
                                  ADeltaList,
                                  Error,
                                  MessageError, '',
                                  vTimeOut, vLogin, vPassword)
  Else
   vRESTConnectionDB.ApplyChangesPure(vRestPooler,
                                      vRestModule,
                                      TableName,
                                      GetLineSQL(SQL),
                                      ADeltaList,
                                      Error,
                                      MessageError, '',
                                      vTimeOut, vLogin, vPassword);
  If Assigned(vOnEventConnection) Then
   vOnEventConnection(True, 'ApplyUpdates Ok')
 Except
  On E : Exception do
   Begin
    vDSRConnection.SessionID := '';
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 vDSRConnection.DisposeOf;
 vRESTConnectionDB.DisposeOf;
End;

Function TRESTDataBase.InsertMySQLReturnID(Var SQL          : TStringList;
                                           Var Params       : TParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String) : Integer;
Var
 vDSRConnection    : TDSRestConnection;
 vRESTConnectionDB : TSMPoolerMethodClient;
 oJsonObject       : Integer;
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
Begin
 Result := -1;
 Error  := False;
 if vRestPooler = '' then
  Exit;
 SetConnectionOptions(vDSRConnection);
 vRESTConnectionDB := TSMPoolerMethodClient.Create(vDSRConnection, True);
 vRESTConnectionDB.Compression := vCompression;
 vRESTConnectionDB.Encoding    := GetEncoding(VEncondig);
 Try
  If Params.Count > 0 Then
   oJsonObject := vRESTConnectionDB.InsertValue(vRestPooler,
                                                vRestModule,
                                                GetLineSQL(SQL),
                                                Params,
                                                Error, MessageError, '',
                                                vTimeOut, vLogin, vPassword)
  Else
   oJsonObject := vRESTConnectionDB.InsertValuePure(vRestPooler,
                                                    vRestModule,
                                                    GetLineSQL(SQL),
                                                    Error, MessageError, '',
                                                    vTimeOut, vLogin, vPassword);
  Result := oJsonObject;
  If Assigned(vOnEventConnection) Then
   vOnEventConnection(True, 'ExecuteCommand Ok');
 Except
  On E : Exception do
   Begin
    vDSRConnection.SessionID := '';
    Error                    := True;
    MessageError             := E.Message;
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 vDSRConnection.DisposeOf;
 vRESTConnectionDB.DisposeOf;
End;

Procedure TRESTDataBase.Open;
Begin
 SetConnection(True);
End;

Function TRESTDataBase.ExecuteCommand(Var SQL    : TStringList;
                                      Var Params : TParams;
                                      Var Error  : Boolean;
                                      Var MessageError : String;
                                      Execute    : Boolean = False) : TFDJSONDataSets;
Var
 vDSRConnection    : TDSRestConnection;
 vRESTConnectionDB : TSMPoolerMethodClient;
 oJsonObject       : TJSONObject;
 Original,
 gZIPStream        : TMemoryStream;
 MemTable          : TFDMemTable;
 LDataSetList      : TFDJSONDataSets;
 vTempWriter       : TFDJSONDataSetsWriter;
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
 Result := Nil;
 if vRestPooler = '' then
  Exit;
 SetConnectionOptions(vDSRConnection);
 ParseParams;
 vRESTConnectionDB := TSMPoolerMethodClient.Create(vDSRConnection, True);
 vRESTConnectionDB.Compression := vCompression;
 vRESTConnectionDB.Encoding    := GetEncoding(VEncondig);
 Try
  If Params.Count > 0 Then
   oJsonObject := vRESTConnectionDB.ExecuteCommandJSON(vRestPooler,
                                                       vRestModule, GetLineSQL(SQL),
                                                       Params, Error,
                                                       MessageError, Execute, '', vTimeOut, vLogin, vPassword)
  Else
   oJsonObject := vRESTConnectionDB.ExecuteCommandPureJSON(vRestPooler,
                                                           vRestModule,
                                                           GetLineSQL(SQL), Error,
                                                           MessageError, Execute, '', vTimeOut, vLogin, vPassword);
  Result := TFDJSONDataSets.Create;
  If (oJsonObject <> Nil) Then
   Begin
    If (Trim(oJsonObject.ToString) <> '{}') And
       (Trim(oJsonObject.ToString) <> '')   Then
     Begin
      If vCompression Then
       Begin
        Original     := TMemoryStream.Create;
        gZIPStream   := TMemoryStream.Create;
        MemTable     := TFDMemTable.Create(Nil);
        LDataSetList := TFDJSONDataSets.Create;
        vTempWriter       := TFDJSONDataSetsWriter.Create(Result);
        Try
         TFDJSONInterceptor.JSONObjectToDataSets(oJsonObject, LDataSetList);
         Assert(TFDJSONDataSetsReader.GetListCount(LDataSetList) = 1);
         MemTable.AppendData(TFDJSONDataSetsReader.GetListValue(LDataSetList, 0));
         MemTable.First;
         TBlobField(MemTable.FieldByName('compress')).SaveToStream(Original);
         MemTable.Close;
         Original.Position := 0;
         doUnGZIP(Original, gZIPStream);
         {$if CompilerVersion >= 28}
         MemTable.LoadFromStream(gZIPStream, sfJSON);
         {$else}
         MemTable.LoadFromStream(gZIPStream);
         {$ifend}
         vTempWriter.ListAdd(Result, MemTable);
        Finally
         Original.DisposeOf;
         gZIPStream.DisposeOf;
         vTempWriter.DisposeOf;
         LDataSetList.DisposeOf;
        End;
       End
      Else
       TFDJSONInterceptor.JSONObjectToDataSets(oJsonObject, Result);
     End;
   End;
  If Assigned(vOnEventConnection) Then
   vOnEventConnection(True, 'ExecuteCommand Ok');
 Except
  On E : Exception do
   Begin
    vDSRConnection.SessionID := '';
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 vDSRConnection.DisposeOf;
 vRESTConnectionDB.DisposeOf;
End;

Procedure TRESTDataBase.ExecuteProcedure(ProcName         : String;
                                         Params           : TParams;
                                         Var Error        : Boolean;
                                         Var MessageError : String);
Var
 vDSRConnection    : TDSRestConnection;
 vRESTConnectionDB : TSMPoolerMethodClient;
Begin
 if vRestPooler = '' then
  Exit;
 If Trim(ProcName) = '' Then
  Begin
   Error := True;
   MessageError := 'ProcName Cannot is Empty';
  End
 Else
  Begin
   SetConnectionOptions(vDSRConnection);
   vRESTConnectionDB             := TSMPoolerMethodClient.Create(vDSRConnection, True);
   vRESTConnectionDB.Compression := vCompression;
   vRESTConnectionDB.Encoding    := GetEncoding(VEncondig);
   Try
    If Params.Count > 0 Then
     vRESTConnectionDB.ExecuteProcedure(vRestPooler, vRestModule, ProcName, Params, Error, MessageError)
    Else
     vRESTConnectionDB.ExecuteProcedurePure(vRestPooler, vRestModule, ProcName, Error, MessageError);
   Except
    On E : Exception do
     Begin
      vDSRConnection.SessionID := '';
      if Assigned(vOnEventConnection) then
       vOnEventConnection(False, E.Message);
     End;
   End;
  vDSRConnection.DisposeOf;
  vRESTConnectionDB.DisposeOf;
 End;
End;

Function TRESTDataBase.GetRestPoolers : TStringList;
Var
 I                 : Integer;
 vTempList         : TStringList;
 vDSRConnection    : TDSRestConnection;
 vRESTConnectionDB : TSMPoolerMethodClient;
Begin
 SetConnectionOptions(vDSRConnection);
 vRESTConnectionDB := TSMPoolerMethodClient.Create(vDSRConnection, True);
 vRESTConnectionDB.Compression := vCompression;
 vRESTConnectionDB.Encoding    := GetEncoding(VEncondig);
  Result           := TStringList.Create;
 Try
  vTempList        := vRESTConnectionDB.PoolersDataSet(vRestModule, '', vTimeOut, vLogin, vPassword);
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
    vDSRConnection.SessionID := '';
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;

 vDSRConnection.DisposeOf;
 vRESTConnectionDB.DisposeOf;
End;

Function TRESTDataBase.GetStateDB: Boolean;
Begin
 Result := vConnected;
End;

Constructor TRESTPoolerList.Create(AOwner : TComponent);
Begin
 Inherited;
 Owner                     := AOwner;
 vLogin                    := '';
 vPassword                 := vLogin;
 vPoolerPort               := 8082;
 vProxy                    := False;
 vProxyOptions             := TProxyOptions.Create;
 vPoolerList               := TStringList.Create;
End;

Constructor TRESTDataBase.Create(AOwner : TComponent);
Begin
 Inherited;
 Owner                     := AOwner;
 vLogin                    := '';
 vMyIP                     := '0.0.0.0';
 vCompression              := True;
 vPassword                 := vLogin;
 vRestModule               := 'TServerMethods1';
 vRestPooler               := vPassword;
 vPoolerPort               := 8081;
 vProxy                    := False;
 vProxyOptions             := TProxyOptions.Create;
 vAutoCheckData            := TAutoCheckData.Create;
 vAutoCheckData.vAutoCheck := False;
 vAutoCheckData.vInTime    := 1000;
 vTimeOut                  := 10000;
 vAutoCheckData.vEvent     := CheckConnection;
 VEncondig                 := esUtf8;
 vContentex                := 'Datasnap';
 vRESTContext              := 'rest/';
 vStrsTrim                 := False;
 vStrsEmpty2Null           := False;
 vStrsTrim2Len             := True;
 vParamCreate              := True;
End;

Destructor  TRESTPoolerList.Destroy;
Begin
 vProxyOptions.DisposeOf;
 If vPoolerList <> Nil Then
  vPoolerList.DisposeOf;
 Inherited;
End;

Destructor  TRESTDataBase.Destroy;
Begin
 vAutoCheckData.vAutoCheck := False;
 vProxyOptions.DisposeOf;
 vAutoCheckData.DisposeOf;
 Inherited;
End;

Procedure TRESTDataBase.CheckConnection;
Begin
 vConnected := TryConnect;
End;

Procedure TRESTDataBase.Close;
Begin
 SetConnection(False);
End;

Function  TRESTPoolerList.TryConnect : Boolean;
Var
 vTempResult       : String;
 vDSRConnection    : TDSRestConnection;
 vRESTConnectionDB : TSMPoolerMethodClient;
Begin
 Result := False;
 SetConnectionOptions(vDSRConnection);
 vRESTConnectionDB           := TSMPoolerMethodClient.Create(vDSRConnection, True);
 vRESTConnectionDB.Encoding  := TEncoding.ASCII;
 Try
  vPoolerList.Clear;
  vPoolerList.Assign(vRESTConnectionDB.PoolersDataSet(vPoolerPrefix, vTempResult, 3000, vLogin, vPassword));
  Result      := True;
 Except
  On E : Exception do
   Begin
    vDSRConnection.SessionID := '';
   End;
 End;
 vDSRConnection.DisposeOf;
 vRESTConnectionDB.DisposeOf;
End;

Function  TRESTDataBase.TryConnect : Boolean;
Var
 vTempSend,
 vTempResult       : String;
 vDSRConnection    : TDSRestConnection;
 vRESTConnectionDB : TSMPoolerMethodClient;
Begin
 If vRestPooler = '' Then
  vTempSend := 'ping'
 Else
  vTempSend := vRestPooler;
 SetConnectionOptions(vDSRConnection);
 vRESTConnectionDB := TSMPoolerMethodClient.Create(vDSRConnection, True);
 vRESTConnectionDB.Encoding := GetEncoding(VEncondig);
 Try
  vTempResult := vRESTConnectionDB.EchoPooler(vTempSend, vRestModule, '', vTimeOut, vLogin, vPassword);
  vMyIP       := vTempResult;
  If csDesigning in ComponentState Then
   If Trim(vTempResult) = '' Then Raise Exception.Create(PChar('Error : ' + #13 + 'Authentication Error...'));
  If Trim(vMyIP) = '' Then
   If Assigned(vOnEventConnection) Then
    vOnEventConnection(False, 'Authentication Error...');
 Except
  On E : Exception do
   Begin
    If csDesigning in ComponentState Then
     Raise Exception.Create(PChar(E.Message));
    vDSRConnection.SessionID := '';
    if Assigned(vOnEventConnection) then
     vOnEventConnection(False, E.Message);
   End;
 End;
 Result      := Trim(vTempResult) <> '';
 vDSRConnection.DisposeOf;
 vRESTConnectionDB.DisposeOf;
End;

Procedure TRESTDataBase.SetConnection(Value : Boolean);
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

Procedure TRESTPoolerList.SetConnection(Value : Boolean);
Begin
 vConnected := Value;
 If vConnected Then
  vConnected := TryConnect;
End;

Procedure TRESTDataBase.SetPoolerPort(Value : Integer);
Begin
 vPoolerPort := Value;
End;

Procedure TRESTPoolerList.SetPoolerPort(Value : Integer);
Begin
 vPoolerPort := Value;
End;

Procedure TRESTDataBase.SetRestPooler(Value : String);
Begin
 vRestPooler := Value;
End;

Procedure TRESTClientSQL.SetDataBase(Value : TRESTDataBase);
Begin
 if Value is TRESTDataBase then
  vRESTDataBase := Value
 Else
  vRESTDataBase := Nil;
End;

Procedure TRESTClientSQL.SetMasterDataSet(Value : TRESTClientSQL);
Var
 MasterDetailItem : TMasterDetailItem;
Begin
 If (vMasterDataSet <> Nil) Then
  TRESTClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 If (Value = Self) And (Value <> Nil) Then
  Begin
   vMasterDataSet := Nil;
   MasterSource   := Nil;
   MasterFields   := '';
   Exit;
  End;
 vMasterDataSet := Value;
 If (vMasterDataSet <> Nil) Then
  Begin
   MasterDetailItem         := TMasterDetailItem.Create;
   MasterDetailItem.DataSet := TRESTClient(Self);
   TRESTClientSQL(vMasterDataSet).vMasterDetailList.Add(MasterDetailItem);
   vDataSource.DataSet := Value;
   Try
    MasterSource := vDataSource;
   Except
    vMasterDataSet := Nil;
    MasterSource   := Nil;
    MasterFields   := '';
   End;
  End
 Else
  Begin
   MasterSource := Nil;
   MasterFields := '';
  End;
End;



Constructor TRESTClientSQL.Create(AOwner : TComponent);
Begin
 Inherited;
 Owner                             := AOwner;
 vDataCache                        := False;
 vConnectedOnce                    := True;
 vActive                           := False;
 vCacheUpdateRecords               := True;
 UpdateOptions.CountUpdatedRecords := vCacheUpdateRecords;
 vBeforeClone                      := False;
 vReadData                         := False;
 vCascadeDelete                    := True;
 vSQL                              := TStringList.Create;
 vSQL.OnChange                     := OnChangingSQL;
 vParams                           := TParams.Create;
 vCacheDataDB                      := Self.CloneSource;
 vUpdateTableName                  := '';
 FieldDefsUPD                      := TFieldDefs.Create(Self);
 FieldDefs                         := FieldDefsUPD;
 vMasterDetailList                 := TMasterDetailList.Create;
 OldData                           := TMemoryStream.Create;
 vMasterDataSet                    := Nil;
 vDataSource                       := TDataSource.Create(Nil);
 TFDMemTable(Self).AfterScroll     := ProcAfterScroll;
 TFDMemTable(Self).AfterOpen       := ProcAfterOpen;
 TFDMemTable(Self).AfterInsert     := ProcAfterInsert;
 TFDMemTable(Self).BeforeDelete    := ProcBeforeDelete;
 TFDMemTable(Self).AfterClose      := ProcAfterClose;
 TFDMemTable(Self).BeforePost      := ProcBeforePost;
 TFDMemTable(Self).AfterPost       := ProcAfterPost;
 Inherited AfterPost               := OldAfterPost;
 Inherited AfterDelete             := OldAfterDelete;
End;

Destructor  TRESTClientSQL.Destroy;
Begin
 vSQL.DisposeOf;
 vParams.DisposeOf;
 FieldDefsUPD.DisposeOf;
 If (vMasterDataSet <> Nil) Then
  TRESTClientSQL(vMasterDataSet).vMasterDetailList.DeleteDS(TRESTClient(Self));
 vMasterDetailList.DisposeOf;
 vDataSource.DisposeOf;
 If vCacheDataDB <> Nil Then
  vCacheDataDB.DisposeOf;
 OldData.DisposeOf;
 Inherited;
End;

Procedure TRESTClientSQL.DynamicFilter(Field, Value : String; InText : Boolean = False);
Begin
 ExecOrOpen;
 If vActive Then
  Begin
   If Length(Value) > 0 Then
    Begin
     If InText Then
      Filter := Format('%s Like ''%s''', [Field, '%' + Value + '%'])
     Else
      Filter := Format('%s Like ''%s''', [Field, Value + '%']);
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
    if CharInSet(vOldChar,[' ', '=', '-', '+', '<', '>', '(', ')', ':', '|']) then
     Begin
      While Not (FCurrentPos^ = #0) Do
       Begin
        if CharInSet(FCurrentPos^,['0'..'9', 'A'..'Z','a'..'z', '_']) then

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
   If Not CharInSet(FCurrentPos^, [#0..' ', ',',
                           '''', '"',
                           '0'..'9', 'A'..'Z',
                           'a'..'z', '_',
                           '$', #127..#255]) Then


    Begin
     vParamName := GetParamName;
     If Trim(vParamName) <> '' Then
      Begin
       If Result.IndexOf(Uppercase(vParamName)) = -1 Then
        Result.Add(Uppercase(vParamName));
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

Procedure TRESTClientSQL.CreateParams;
Var
 I         : Integer;
 ParamList : TStringList;
 Procedure CreateParam(Value : String);
 Var
  FieldDef : TField;
 Begin
  FieldDef := FindField(Value);
  If FieldDef <> Nil Then
   vParams.CreateParam(FieldDef.DataType, Value, ptUnknown)
  Else
   vParams.CreateParam(ftUnknown, Value, ptUnknown);
 End;
Begin
 vParams.Clear;
 ParamList := ReturnParams(vSQL.Text);
 If ParamList <> Nil Then
 For I := 0 to ParamList.Count -1 Do
  CreateParam(ParamList[I]);
 ParamList.Free;
End;

Procedure TRESTClientSQL.ProcAfterScroll(DataSet: TDataSet);
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

Procedure TRESTClientSQL.GotoRec(Const RecNo: Integer);
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

Procedure TRESTClientSQL.ProcBeforeDelete(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTClientSQL;
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
   SaveToStream(OldData, TFDStorageFormat.sfBinary);
   If Assigned(vOnBeforeDelete) Then
    vOnBeforeDelete(DataSet);
   If vCascadeDelete Then
    Begin
     For I := 0 To vMasterDetailList.Count -1 Do
      Begin
       vMasterDetailList.Items[I].ParseFields(TRESTClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
       vDetailClient        := TRESTClientSQL(vMasterDetailList.Items[I].DataSet);
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
   vReadData := False;
  End;
End;

procedure TRESTClientSQL.ProcBeforePost(DataSet: TDataSet);
Var
 vOldState : TDatasetState;
Begin
 If Not vReadData Then
  Begin
   vActualRec := -1;
   vReadData  := True;
   vOldState  := State;
   OldData.Clear;
   SaveToStream(OldData, TFDStorageFormat.sfBinary);
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
   If Assigned(vOnBeforePost) Then
    vOnBeforePost(DataSet);
  End;
End;

procedure TRESTClientSQL.Refresh;
var
  Curso:integer;
begin
    Curso := 0;
    if Active then
    begin
      if RecordCount > 0 then
      Curso:= self.CurrentRecord;
      close;
      Open;
      if Active then
      begin
        if RecordCount > 0 then
        MoveBy(Curso);
      end;
    end;

end;

Procedure TRESTClientSQL.ProcAfterClose(DataSet: TDataSet);
Var
 I : Integer;
 vDetailClient : TRESTClientSQL;
Begin
 If Assigned(vOnAfterClose) then
  vOnAfterClose(Dataset);
 If vCascadeDelete Then
  Begin
   For I := 0 To vMasterDetailList.Count -1 Do
    Begin
     vMasterDetailList.Items[I].ParseFields(TRESTClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
     vDetailClient        := TRESTClientSQL(vMasterDetailList.Items[I].DataSet);
     If vDetailClient <> Nil Then
      vDetailClient.Close;
    End;
  End;
End;

Procedure TRESTClientSQL.ProcAfterInsert(DataSet: TDataSet);
Var
 I : Integer;
 vFields       : TStringList;
 vDetailClient : TRESTClientSQL;
 Procedure CloneDetails(Value : TRESTClientSQL; FieldName : String);
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
   vFields.DisposeOf;
  End;
 If Assigned(vOnAfterInsert) Then
  vOnAfterInsert(Dataset);
End;

Procedure TRESTClientSQL.ProcAfterOpen(DataSet: TDataSet);
Begin
 If Assigned(vOnAfterOpen) Then
  vOnAfterOpen(Dataset);
End;

Procedure TRESTClientSQL.ProcAfterPost(DataSet : TDataSet);
Begin
 If Not vReadData Then
  Begin
   If Assigned(vOnAfterPost) Then
    vOnAfterPost(Dataset);
  End;
End;

Function  TRESTClientSQL.ApplyUpdates(Var Error : String) : Boolean;
var
 LDeltaList    : TFDJSONDeltas;
 vError        : Boolean;
 vMessageError : String;
 oJsonObject   : TJSONObject;
 MemTable      : TFDMemTable;
 Original      : TStringStream;
 gZIPStream    : TMemoryStream;
 Function GetDeltas : TFDJSONDeltas;
 Begin
  UpdateOptions.CountUpdatedRecords := vCacheUpdateRecords;
  If State In [dsEdit, dsInsert] Then
   Post;
  Result := TFDJSONDeltas.Create;
  TFDJSONDeltasWriter.ListAdd(Result, vUpdateTableName, TFDMemTable(Self));
 End;
Begin
 If vReadData Then
  Begin
   Result := True;
   Exit;
  End;
 LDeltaList := GetDeltas;
 If vRESTDataBase <> Nil Then
  Begin
   If vRESTDataBase.vCompression Then
    Begin
     oJsonObject   := TJSONObject.Create;
      TFDJSONInterceptor.DataSetsToJSONObject(LDeltaList, oJsonObject);
      LDeltaList.DisposeOf;
      LDeltaList   := TFDJSONDeltas.Create;
      MemTable     := TFDMemTable.Create(Nil);
      Original     := TStringStream.Create(oJsonObject.ToString);
      gZIPStream   := TMemoryStream.Create;
     Try
       //make it gzip
      doGZIP(Original, gZIPStream);
      MemTable.FieldDefs.Add('compress', ftBlob);
      MemTable.CreateDataSet;
      MemTable.CachedUpdates := True;
      MemTable.Insert;
      TBlobField(MemTable.FieldByName('compress')).LoadFromStream(gZIPStream);
      MemTable.Post;
      TFDJSONDeltasWriter.ListAdd(LDeltaList, 'TempTable', MemTable);
     Finally
      MemTable.DisposeOf;
      Original.DisposeOf;
      gZIPStream.DisposeOf;
     End;
    End;
  End
 Else
  Begin
   Raise Exception.Create(PChar('Empty Database Property'));
   Exit;
  End;
 If Assigned(vRESTDataBase) And (Trim(UpdateTableName) <> '') Then
  vRESTDataBase.ApplyUpdates(vSQL, vParams, LDeltaList, Trim(vUpdateTableName), vError, vMessageError)
 Else
  Begin
   vError := True;
   If Not Assigned(vRESTDataBase) Then
    vMessageError := 'No RESTDatabase defined'
   Else
    vMessageError := 'No UpdateTableName defined';
  End;
 Result       := Not vError;
 Error        := vMessageError;
 vErrorBefore := vError;
 If (Result) And (Not(vError)) Then
  Begin
   TFDMemTable(Self).ApplyUpdates(-1);
   If Not (vErrorBefore)     Then
    TFDMemTable(Self).CommitUpdates;
  End
 Else If vError Then
  Begin
   TFDMemTable(Self).Close;
   OldData.Position := 0;
   LoadFromStream(OldData, TFDStorageFormat.sfBinary);
   vReadData  := False;
  End;
 Try
  If vActualRec > -1 Then
   GoToRec(vActualRec);
 Except
 End;
End;

Function  TRESTClientSQL.ParamByName(Value : String) : TParam;
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

Function TRESTClientSQL.ParamCount: Integer;
Begin
 Result := vParams.Count;
End;

Function TRESTClientSQL.FirstWord(Value : String) : String;
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

Procedure TRESTClientSQL.ExecOrOpen;
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

Function TRESTClientSQL.ExecSQL(Var Error : String) : Boolean;
Var
 vError        : Boolean;
 vMessageError : String;
Begin
 Result := False;
 Try
  If vRESTDataBase <> Nil Then
   Begin
    vRESTDataBase.ExecuteCommand(vSQL, vParams, vError, vMessageError, True);
    Result := Not vError;
    Error  := vMessageError;
   End
  Else
   Raise Exception.Create(PChar('Empty Database Property'));
 Except
 End;
End;

Function TRESTClientSQL.InsertMySQLReturnID : Integer;
Var
 vError        : Boolean;
 vMessageError : String;
Begin
 Result := -1;
 Try
  If vRESTDataBase <> Nil Then
   Result := vRESTDataBase.InsertMySQLReturnID(vSQL, vParams, vError, vMessageError)
  Else 
   Raise Exception.Create(PChar('Empty Database Property')); 
 Except
 End;
End;

Procedure TRESTClientSQL.OnChangingSQL(Sender: TObject);
Begin
 CreateParams;
End;

Procedure TRESTClientSQL.SetSQL(Value : TStringList);
Var
 I : Integer;
Begin
 vSQL.Clear;
 For I := 0 To Value.Count -1 do
  vSQL.Add(Value[I]);
End;

Procedure TRESTClientSQL.CreateDataSet;
Begin
 vCreateDS := True;
 Inherited CreateDataSet;
 vCreateDS := False;
 vActive   := Self.Active;
End;

Procedure TRESTClientSQL.Close;
Begin
 vActive := False;
 Inherited Close;
 If TFDMemTable(Self).Fields.Count = 0 Then
  TFDMemTable(Self).FieldDefs.Clear;
End;

Function TRESTClientSQL.CanObserve(const ID: Integer): Boolean;
begin
  case ID of
    TObserverMapping.EditLinkID,      { EditLinkID is the observer that is used for control-to-field links }
    TObserverMapping.ControlValueID:
      Result := True;
  else
    Result := False;
  end;
end;

Procedure TRESTClientSQL.Open;
Begin
 If Not vActive Then
  SetActiveDB(True);
 If vActive Then
  Inherited Open;
End;

Procedure TRESTClientSQL.Open(SQL : String);
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

Procedure TRESTClientSQL.OpenCursor(InfoQuery: Boolean);
Begin
 If Not vBeforeClone Then
  Begin
   vBeforeClone := True;
   If vRESTDataBase <> Nil Then
    Begin
     vRESTDataBase.Active := True;
     If vRESTDataBase.Active Then
      Begin
       Try
        Try
         If Not (vActive) And (Not (vCreateDS)) Then
          Begin
           If GetData Then
            Begin
             If Not (csDesigning in ComponentState) Then
              vActive := True;
             Inherited OpenCursor(InfoQuery);
            End;
          End
         Else
          Inherited OpenCursor(InfoQuery);
        Except
         On E : Exception do
          Begin
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
       Finally
        vBeforeClone := False;
       End;
      End;
    End
   Else
    Raise Exception.Create(PChar('Empty Database Property'));  
  End;
End;

Procedure TRESTClientSQL.OldAfterPost(DataSet: TDataSet);
Begin
 vErrorBefore := False;
 If Not vReadData Then
  Begin
   If Assigned(vOnAfterPost) Then
    vOnAfterPost(Self);
  End;
End;

Procedure TRESTClientSQL.OldAfterDelete(DataSet: TDataSet);
Begin
 vErrorBefore := False;
 Try
  If Assigned(vOnAfterDelete) Then
   vOnAfterDelete(Self);
  If Not vErrorBefore Then
   TFDMemTable(Self).CommitUpdates;
 Finally
  vReadData := False;
 End;
End;

Procedure TRESTClientSQL.SetUpdateTableName(Value : String);
Begin
 vCommitUpdates                  := Trim(Value) <> '';
 TFDMemTable(Self).CachedUpdates := vCommitUpdates;
 vUpdateTableName                := Value;
End;

Procedure TRESTClientSQL.Loaded;
Begin
 Inherited Loaded;
End;

Procedure ExecMethod(Execute : TExecuteProc = Nil);
Var
 EffectThread : TThread;
Begin
 EffectThread.CreateAnonymousThread(Procedure
                                    Begin
                                     //Se precisar interagir com a Thread da Interface
                                     If Assigned(Execute) Then
                                      TThread.Synchronize (TThread.CurrentThread,
                                                           Procedure
                                                           Begin
                                                            Execute;
                                                            EffectThread.DisposeOf;
                                                           End);
                                    End).Start;
End;

Procedure TRESTClientSQL.CloneDefinitions(Source : TFDMemTable; aSelf : TRESTClientSQL);
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
   With aSelf.FieldDefs.AddFieldDef Do
    Begin
     Name     := Source.FieldDefs[I].Name;
     DataType := Source.FieldDefs[I].DataType;
     Size     := Source.FieldDefs[I].Size;
     Required := Source.FieldDefs[I].Required;
    End;
  End;
 If aSelf.FieldDefs.Count > 0 Then
  aSelf.CreateDataSet;
End;

Procedure TRESTClientSQL.PrepareDetailsNew;
Var
 I : Integer;
 vDetailClient : TRESTClientSQL;
Begin
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
   vDetailClient        := TRESTClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     If vDetailClient.Active Then
      Begin
       vDetailClient.EmptyDataSet;
       vDetailClient.ProcAfterScroll(vDetailClient);
      End;
    End;
  End;
End;

Procedure TRESTClientSQL.PrepareDetails(ActiveMode : Boolean);
Var
 I : Integer;
 vDetailClient : TRESTClientSQL;
 Procedure CloneDetails(Value : TRESTClientSQL);
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
 For I := 0 To vMasterDetailList.Count -1 Do
  Begin
   vMasterDetailList.Items[I].ParseFields(TRESTClientSQL(vMasterDetailList.Items[I].DataSet).MasterFields);
   vDetailClient        := TRESTClientSQL(vMasterDetailList.Items[I].DataSet);
   If vDetailClient <> Nil Then
    Begin
     vDetailClient.Active := False;
     CloneDetails(vDetailClient);
     vDetailClient.Active := ActiveMode;
    End;
  End;
End;

Function TRESTClientSQL.GetData : Boolean;
Var
 LDataSetList  : TFDJSONDataSets;
 vError        : Boolean;
 vMessageError : String;
 vTempTable    : TFDMemTable;
Begin
 Result := False;
 LDataSetList := nil;
 Self.Close;
 If Assigned(vRESTDataBase) Then
  Begin
   Try
    LDataSetList := vRESTDataBase.ExecuteCommand(vSQL, vParams, vError, vMessageError, False);
    If (LDataSetList <> Nil) And (Not (vError)) Then
     Begin
      vTempTable := TFDMemTable.Create(Nil);
      vTempTable.UpdateOptions.CountUpdatedRecords := False;
      Try
       Assert(TFDJSONDataSetsReader.GetListCount(LDataSetList) = 1);
       vTempTable.AppendData(TFDJSONDataSetsReader.GetListValue(LDataSetList, 0));
       CloneDefinitions(vTempTable, Self);
       If LDataSetList <> Nil Then
        Begin
         AppendData(TFDJSONDataSetsReader.GetListValue(LDataSetList, 0));
         Result := True;
        End;
      Except
      End;
      vTempTable.DisposeOf;
     End;
   Except
    If LDataSetList <> Nil Then
     LDataSetList.DisposeOf;
   End;
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
 Else
  Raise Exception.Create(PChar('Empty Database Property'));  
End;

Procedure TRESTClientSQL.SetActiveDB(Value : Boolean);
Begin
 vActive := False;
 If (vRESTDataBase <> Nil) And (Value) Then
  Begin
   If vRESTDataBase <> Nil Then
    If Not vRESTDataBase.Active Then
     vRESTDataBase.Active := True;
   If Not vRESTDataBase.Active then
    Exit;
   Try
    If Not(vActive) And (Value) Then
     Begin
      Filter                       := '';
      Filtered                     := False;
      FormatOptions.StrsTrim       := vRESTDataBase.StrsTrim;
      FormatOptions.StrsEmpty2Null := vRESTDataBase.StrsEmpty2Null;
      FormatOptions.StrsTrim2Len   := vRESTDataBase.StrsTrim2Len;
      vActive                      := GetData;
     End;
    If State = dsBrowse Then
     PrepareDetails(True)
    Else If State = dsInactive Then
     PrepareDetails(False);
   Except
    On E : Exception do
     Begin
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
   If vRESTDataBase = Nil Then
    Raise Exception.Create(PChar('Empty Database Property'));
  End;
End;

Procedure TRESTClientSQL.SetCacheUpdateRecords(Value: Boolean);
Begin
 vCacheUpdateRecords               := Value;
 UpdateOptions.CountUpdatedRecords := vCacheUpdateRecords;
End;


{ TRESTStoredProc }

constructor TRESTStoredProc.Create(AOwner: TComponent);
begin
 Inherited;
 vParams   := TParams.Create;
 Owner     := AOwner;
 vParams   := Nil;
 vProcName := '';
end;

destructor TRESTStoredProc.Destroy;
begin
 vParams.DisposeOf;
 Inherited;
end;

Function TRESTStoredProc.ExecProc(Var Error : String) : Boolean;
Begin
 If vRESTDataBase <> Nil Then
  Begin
   If vParams.Count > 0 Then
    vRESTDataBase.ExecuteProcedure(vProcName, vParams, Result, Error);
  End
 Else
  Raise Exception.Create(PChar('Empty Database Property'));
End;

Function TRESTStoredProc.ParamByName(Value: String): TParam;
Begin
 Result := Params.ParamByName(Value);
End;

procedure TRESTStoredProc.SetDataBase(const Value: TRESTDataBase);
begin
 vRESTDataBase := Value;
end;

end.
