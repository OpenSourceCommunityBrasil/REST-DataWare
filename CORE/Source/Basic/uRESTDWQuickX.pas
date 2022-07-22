unit uRESTDWQuickX;

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
 A. Brito                   - Admin - Administrador  do pacote.
 Ari                        - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
}

{$I uRESTDW.inc}

interface

Uses
 uDWJSONTools, uDWJSONObject, ServerUtils, SysTypes,
 uDWConsts, uDWConstsCharset, uDWConst404HTML, IdContext,
 {$IFDEF FPC}
  SysUtils,  Classes, LConvEncoding;
 {$ELSE}
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, EncdDecd
  {$ELSE}
   System.SysUtils, System.Classes
   {$IF Defined(HAS_FMX)}, System.IOUtils{$IFEND}
  {$IFEND};
 {$ENDIF}

Type
 TOnCreate                   = Procedure(Sender                : TObject)         Of Object;
 TLastRequest                = Procedure(Value                 : String)          Of Object;
 TLastResponse               = Procedure(Value                 : String)          Of Object;
 TBeforeUseCriptKey          = Procedure(Request               : String;
                                         Var Key               : String)          Of Object;
 TOnBeforeExecute            = Procedure(ASender               : TObject)         Of Object;
 TWelcomeMessage             = Procedure(Welcomemsg,
                                         AccessTag             : String;
                                         Var Accept            : Boolean;
                                         Var ContentType,
                                         ErrorMessage          : String)          Of Object;
 TRESTDWQXAuthRequest        = Procedure(Sender                : TObject;
                                         RequestHeader         : TStringList;
                                         Const Params          : TDWParams;
                                         Var   Rejected        : Boolean;
                                         Var   ResultError     : String;
                                         Var   StatusCode      : Integer;
                                         Var   OutCustomHeader : TStringList)     Of Object;
 TRESTDWQXReplyRequest       = Procedure(Sender                : TObject;
                                         RequestHeader         : TStringList;
                                         Const Params          : TDWParams;
                                         Var   ContentType     : String;
                                         Var   Result          : String;
                                         Const RequestType     : TRequestType;
                                         Var   StatusCode      : Integer;
                                         Var   ErrorMessage    : String;
                                         Var   OutCustomHeader : TStringList);
 TRESTDWQXReplyRequestStream = Procedure(Sender                : TObject;
                                         RequestHeader         : TStringList;
                                         Const Params          : TDWParams;
                                         Var   ContentType     : String;
                                         Const Result          : TMemoryStream;
                                         Const RequestType     : TRequestType;
                                         Var   StatusCode      : Integer;
                                         Var   ErrorMessage    : String;
                                         Var   OutCustomHeader : TStringList);

Type
 TRESTDWQXBodyType    = (bt_xwwwform_urlencoded, bt_multipartformdata, bt_multipartbyteranges,
                         bt_octetstream,         bt_urlparams,         bt_raw, bt_none);

Type
 TClassNull = Class(TComponent)
End;

Type
 TRESTDWQXDataRoute      = Class
 Private
  vNeedAuthorization     : Boolean;
  vDataRoute             : String;
  vRoutes                : TDWRoutes;
  vOnAuthRequest         : TRESTDWQXAuthRequest;
  vOnReplyRequest        : TRESTDWQXReplyRequest;
  vOnReplyRequestStream  : TRESTDWQXReplyRequestStream;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Property    DataRoute            : String                      Read vDataRoute            Write vDataRoute;
  Property    Routes               : TDWRoutes                   Read vRoutes               Write vRoutes;
  Property    NeedAuthorization    : Boolean                     Read vNeedAuthorization    Write vNeedAuthorization;
  Property    OnAuthRequest        : TRESTDWQXAuthRequest        Read vOnAuthRequest        Write vOnAuthRequest;
//  Property    OnReplyRequest       : TRESTDWQXReplyRequest       Read vOnReplyRequest       Write vOnReplyRequest;
//  Property    OnReplyRequestStream : TRESTDWQXReplyRequestStream Read vOnReplyRequestStream Write vOnReplyRequestStream;
End;

Type
 PRESTDWQXDataRoute      = ^TRESTDWQXDataRoute;
 TRESTDWQXDataRouteList  = Class(TList)
 Private
  Function  GetRec(Index : Integer) : TRESTDWQXDataRoute; Overload;
  Procedure PutRec(Index : Integer;
                   Item  : TRESTDWQXDataRoute); Overload;
  Procedure ClearList;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Function    RouteExists(Value : String) : Boolean;
  Procedure   Delete(Index : Integer); Overload;
  Function    Add   (Item  : TRESTDWQXDataRoute) : Integer; Overload;
  Function    GetServerMethodClass(DataRoute         : String;
                                   Var DataRouteItem : TRESTDWQXDataRoute) : Boolean;
  Property    Items [Index : Integer] : TRESTDWQXDataRoute Read GetRec Write PutRec; Default;
End;

Type
 TRESTDWComponent = Class(TComponent)
 Public
  OutHeaders,
  InHeaders        : TStringList;
  DWParams         : TDWParams;
  ConnectionID     : Integer;
  Method           : TRequestType;
  WelcomeAccept    : Boolean;
  AccessTag,
  UserAgent,
  WelcomeMessage,
  ErrorMessage,
  RequestID,
  RemoteIP,
  OutContent,
  URL,
  OutContentType,
  InContentType    : String;
  StatusCode       : Integer;
  JsonMode         : TJsonMode;
  OutContentStream : TMemoryStream;
  DataRoute        : TRESTDWQXDataRoute;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                    //Destroy a Classe
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
 TDWReplyEventqx  = Procedure(Var   Params      : TDWParams;
                              Var   Result      : String)          Of Object;
 TUserBasicAuth   = Procedure(Welcomemsg, AccessTag,
                              Username, Password : String;
                              Var Params         : TDWParams;
                              Var ErrorCode      : Integer;
                              Var ErrorMessage   : String;
                              Var Accept         : Boolean) Of Object;
 TUserTokenAuth   = Procedure(Welcomemsg,
                              AccessTag          : String;
                              Params             : TDWParams;
                              AuthOptions        : TRDWAuthTokenParam;
                              Var ErrorCode      : Integer;
                              Var ErrorMessage   : String;
                              Var TokenID        : String;
                              Var Accept         : Boolean) Of Object;

Type
 TRESTDWQXBasePooler = Class(TComponent)
 Protected
 Private
  {$IFDEF FPC}
   vCriticalSection    : TRTLCriticalSection;
   vDatabaseCharSet    : TDatabaseCharSet;
  {$ENDIF}
  vRESTDWClientInfo    : TRESTDWClientInfo;
  vReplyEvent          : TDWReplyEventQX;
  vWelcomeMessage      : TWelcomeMessage;
  vUserBasicAuth       : TUserBasicAuth;
  vUserTokenAuth       : TUserTokenAuth;
  vOnGetToken          : TOnGetToken;
  vOnMassiveBegin,
  vOnMassiveAfterStartTransaction,
  vOnMassiveAfterBeforeCommit,
  vOnMassiveAfterAfterCommit,
  vBeforeUseCriptKey   : TBeforeUseCriptKey;
  vCORSCustomHeaders,
  vDefaultPage         : TStringList;
  vPathTraversalRaiseError,
  vConsoleMode,
  vForceWelcomeAccess,
  vUseSSL,
  vCORS,
  vActive              : Boolean;
  vProxyOptions        : TProxyOptions;
  vServiceTimeout,
  vServerThreadPoolCount,
  vServicePort         : Integer;
  vCripto              : TCripto;
  vDataRouteList       : TRESTDWQXDataRouteList;
  vServerAuthOptions   : TRDWServerAuthOptionParams;
  vLastRequest         : TLastRequest;
  vLastResponse        : TLastResponse;
  vAccessTag,
  vClientWelcomeMessage,
  vRootUser,
  FRootPath            : String;
  VEncondig            : TEncodeSelect;
  vOnCreate            : TOnCreate;
  Procedure SetClientWelcomeMessage  (Value                   : String);
  Procedure SetClientInfo            (ip,
                                      ipVersion,
                                      UserAgent,
                                      BaseRequest,
                                      Request                 : String;
                                      port                    : Integer);
  Function  AddValue                 (cName,
                                      Value                   : String;
                                      Separator               : String = ':') : String;
  Function  RemoveBackslashCommands  (Value                   : String)       : String;
  Procedure SetCORSCustomHeader      (Value                   : TStringList);
  Procedure SetDefaultPage           (Value                   : TStringList);
  Procedure Loaded; Override;
  Procedure GetTableNames            (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetFieldNames            (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetKeyFieldNames         (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Function  ServiceMethods           (AContext                : TComponent;
                                      Var DWParams            : TDWParams;
                                      Var JSONStr             : String;
                                      Var JsonMode            : TJsonMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType         : String;
                                      Var ServerContextCall   : Boolean;
                                      Const ServerContextStream : TStream;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      WelcomeAccept           : Boolean;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean) : Boolean;
  Procedure GetPoolerList            (Var PoolerList          : String;
                                      AccessTag               : String);
  Procedure EchoPooler               (AContext                : TComponent;
                                      Var Pooler, MyIP        : String;
                                      AccessTag               : String;
                                      Var InvalidTag          : Boolean);
  Procedure ExecuteCommandPureJSON   (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandPureJSONTB (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSON       (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure ExecuteCommandJSONTB     (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean);
  Procedure InsertMySQLReturnID      (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSON         (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSONTB       (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure OpenDatasets             (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      BinaryRequest           : Boolean);
  Procedure ApplyUpdates_MassiveCache(Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdates_MassiveCacheTB(Var Pooler            : String;
                                        Var DWParams          : TDWParams;
                                        hEncodeStrings        : Boolean;
                                        AccessTag             : String);
  Procedure ProcessMassiveSQLCache   (Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Function  ReturnEvent              (Var BaseComponent       : TRESTDWComponent) : Boolean;
  Procedure OnParseAuthentication    (AContext                : TComponent;
                                      Const AAuthType,
                                      AAuthData               : String;
                                      var VUsername,
                                      VPassword               : String; Var VHandled: Boolean);
  Procedure SetupRequest             (RequestHeader           : TStringlist;
                                      Var BodyType            : TRESTDWQXBodyType;
                                      Var Boundary            : String);
  Procedure ReadParams               (Source                  : TStringlist;
                                      Var InitPos             : Integer;
                                      Var ParamType           : TRESTDWQXBodyType;
                                      Var Paramname,
                                      ParamValue              : String;
                                      Boundary                : String);
  Procedure CreateStrings            (Source                  : String;
                                      Var Dest                : TStringlist;
                                      Boundary                : String);
  Procedure GetEvents                (Pooler,
                                      urlContext              : String;
                                      Var DWParams            : TDWParams);
  Procedure GetServerEventsList      (Var ServerEventsList    : String;
                                      AccessTag               : String);
  Procedure   AddDataRoute(DataRoute : String);
 Public
  Procedure   SetActive              (Value                   : Boolean);Virtual;Abstract;
  Procedure   Bind                   (Port                    : Integer = 9092;
                                      ConsoleMode             : Boolean = True);Virtual;
  Function    ExecProcess            (Ctxt                    : TRESTDWComponent;
                                      AContext                : TIdContext) : Cardinal;
  Procedure   ClearDataRoute;
  Function    FindRoute              (Url                     : String;
                                      Var ParamsUrl           : String) : TRESTDWQXDataRoute;
  Procedure   AddUrl                 (Url                     : String;
                                      Routes                  : TDWRoutes;
                                      ReplyRequest            : TRESTDWQXReplyRequest;
                                      NeedAuthorization       : Boolean = True);Overload;
  Procedure   AddUrl                 (Url                     : String;
                                      Routes                  : TDWRoutes;
                                      ReplyRequestStream      : TRESTDWQXReplyRequestStream;
                                      NeedAuthorization       : Boolean = True);Overload;
  Constructor Create                 (AOwner                  : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                      //Destroy a Classe
 Published
  Property Active                         : Boolean                    Read vActive                         Write SetActive;
  Property AccessTag                      : String                     Read vAccessTag                      Write vAccessTag;
  Property ServerThreadPoolCount          : Integer                    Read vServerThreadPoolCount          Write vServerThreadPoolCount;
  Property CORS                           : Boolean                    Read vCORS                           Write vCORS;
  Property CORS_CustomHeaders             : TStringList                Read vCORSCustomHeaders              Write SetCORSCustomHeader;
  Property DefaultPage                    : TStringList                Read vDefaultPage                    Write SetDefaultPage;
  Property UseSSL                         : Boolean                    Read vUseSSL                         Write vUseSSL;
  Property RequestTimeout                 : Integer                    Read vServiceTimeout                 Write vServiceTimeout;
  Property ServicePort                    : Integer                    Read vServicePort                    Write vServicePort;  //A Porta do Serviço do DataSet
  Property ProxyOptions                   : TProxyOptions              Read vProxyOptions                   Write vProxyOptions; //Se tem Proxy diz quais as opções
  Property AuthenticationOptions          : TRDWServerAuthOptionParams Read vServerAuthOptions              Write vServerAuthOptions;
  Property OnLastRequest                  : TLastRequest               Read vLastRequest                    Write vLastRequest;
  Property OnLastResponse                 : TLastResponse              Read vLastResponse                   Write vLastResponse;
  Property Encoding                       : TEncodeSelect              Read VEncondig                       Write VEncondig;          //Encoding da string
  Property RootPath                       : String                     Read FRootPath                       Write FRootPath;
  Property RootUser                       : String                     Read vRootUser                       Write vRootUser;
  Property ForceWelcomeAccess             : Boolean                    Read vForceWelcomeAccess             Write vForceWelcomeAccess;
  Property OnBeforeUseCriptKey            : TBeforeUseCriptKey         Read vBeforeUseCriptKey              Write vBeforeUseCriptKey;
  Property CriptOptions                   : TCripto                    Read vCripto                         Write vCripto;
  Property WelcomeMessage                 : String                     Read vClientWelcomeMessage           Write SetClientWelcomeMessage;
  {$IFDEF FPC}
  Property DatabaseCharSet                : TDatabaseCharSet           Read vDatabaseCharSet                Write vDatabaseCharSet;
  {$ENDIF}
  Property OnCreate                       : TOnCreate                  Read vOnCreate                       Write vOnCreate;
  Property OnReplyEvent                   : TDWReplyEventQX            Read vReplyEvent                     Write vReplyEvent;
  Property OnWelcomeMessage               : TWelcomeMessage            Read vWelcomeMessage                 Write vWelcomeMessage;
  Property OnUserBasicAuth                : TUserBasicAuth             Read vUserBasicAuth                  Write vUserBasicAuth;
  Property OnUserTokenAuth                : TUserTokenAuth             Read vUserTokenAuth                  Write vUserTokenAuth;
  Property OnGetToken                     : TOnGetToken                Read vOnGetToken                     Write vOnGetToken;
End;

Function RemoveBackslashCommands(Value  : String)    : String;
Function GetEventNameX          (Value  : String)    : String;
Function GetTokenString         (Value  : String)    : String;
Function GetBearerString        (Value  : String)    : String;
Function GetParamsReturn        (Params : TDWParams) : String;

implementation

Constructor TRESTDWQXDataRoute.Create;
Begin
 vDataRoute             := '';
 vRoutes                := [crAll];
 vOnReplyRequest        := Nil;
 vOnReplyRequestStream  := Nil;
 vNeedAuthorization     := True;
End;

Function GetBodyType(ContentType : String) : TRESTDWQXBodyType;
Begin
 Result := bt_none;
 ContentType := Lowercase(ContentType);
 If Pos('form-data', ContentType) > 0                  Then
  Result := bt_multipartformdata
 Else If Pos('byteranges', ContentType) > 0            Then
  Result := bt_multipartbyteranges
 Else If Pos('x-www-form-urlencoded', ContentType) > 0 Then
  Result := bt_xwwwform_urlencoded
 Else If Pos('octet-stream', ContentType) > 0          Then
  Result := bt_octetstream
 Else If Pos('raw', ContentType) > 0                   Then
  Result := bt_raw;
End;

Function RemoveBackslashCommands(Value : String) : String;
Begin
 Result := StringReplace(Value,  '../', '', [rfReplaceAll]);
 Result := StringReplace(Result, '..\', '', [rfReplaceAll]);
End;

Function TravertalPathFind(Value : String) : Boolean;
Begin
 Result := Pos('../', Value) > 0;
 If Not Result Then
  Result := Pos('..\', Value) > 0;
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

Function GetTokenString(Value : String) : String;
Var
 vPos : Integer;
Begin
 Result := '';
 vPos   := Pos('token=', Lowercase(Value));
 If vPos > 0 Then
  vPos  := vPos + Length('token=');
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

Function TRESTDWQXDataRouteList.Add(Item: TRESTDWQXDataRoute): Integer;
Var
 vItem : PRESTDWQXDataRoute;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TRESTDWQXDataRouteList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TRESTDWQXDataRouteList.Create;
Begin
 Inherited;
End;

Procedure TRESTDWQXDataRouteList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     {$IFDEF FPC}
     FreeAndNil(TList(Self).Items[Index]^);
     {$ELSE}
      {$IF CompilerVersion > 33}
       FreeAndNil(TRESTDWQXDataRoute(TList(Self).Items[Index]^));
      {$ELSE}
       FreeAndNil(TList(Self).Items[Index]^);
      {$IFEND}
     {$ENDIF}
     {$IFDEF FPC}
      Dispose(PRESTDWQXDataRoute(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TRESTDWQXDataRouteList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TRESTDWQXDataRouteList.GetRec(Index: Integer): TRESTDWQXDataRoute;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWQXDataRoute(TList(Self).Items[Index]^);
End;

Function TRESTDWQXDataRouteList.GetServerMethodClass(DataRoute         : String;
                                                     Var DataRouteItem : TRESTDWQXDataRoute) : Boolean;
Var
 I : Integer;
Begin
 Result        := False;
 DataRouteItem := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   Result := Lowercase(DataRoute) = Lowercase(TRESTDWQXDataRoute(TList(Self).Items[I]^).DataRoute);
   If (Result) Then
    Begin
     DataRouteItem := TRESTDWQXDataRoute(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Procedure TRESTDWQXDataRouteList.PutRec(Index: Integer; Item: TRESTDWQXDataRoute);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWQXDataRoute(TList(Self).Items[Index]^) := Item;
End;

Function TRESTDWQXDataRouteList.RouteExists(Value: String): Boolean;
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

{ TProxyOptions }

procedure TProxyOptions.Assign(Source: TPersistent);
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

Constructor TProxyOptions.Create;
Begin
 Inherited;
 vServer   := '';
 vLogin    := vServer;
 vPassword := vLogin;
 vPort     := 8888;
End;

Procedure TRESTDWQXBasePooler.SetupRequest(RequestHeader : TStringlist;
                                               Var BodyType  : TRESTDWQXBodyType;
                                               Var Boundary  : String);
Const
 cContentType = 'content-type';
Var
 I, A  : Integer;
 vLine : String;
Begin
 For I := 0 To RequestHeader.Count -1 Do
  Begin
   vLine := Lowercase(RequestHeader[I]);
   If Pos(cContentType, vLine) > 0 Then
    Begin
     vLine    := Copy(vLine, Pos(':', vLine) + 2, Length(vLine) - Pos(':', vLine));
     BodyType := GetBodyType(Copy(vLine, 1, Pos(';', vLine) -1));
     Delete(vLine, 1, Pos(';', vLine));
     A        := Pos('=', vLine) + 1;
     Boundary := Copy(vLine, A, Length(vLine) - A);
     A        := Pos(';', Boundary);
     If A > 0 Then
      Boundary  := Copy(Boundary, 1, A -1);
     Break;
    End;
  End;
End;

Procedure TRESTDWQXBasePooler.CreateStrings(Source      : String;
                                                Var Dest    : TStringlist;
                                                Boundary    : String);
Const
 cContentTransferEncoding = 'content-transfer-encoding:';
Var
 vline,
 vTempline,
 vTempline2 : String;
 vFlagPos   : Integer;
 vOnbynary  : Boolean;
 bSource    : String;
Begin
 Dest.Clear;
 vFlagPos  := 0;
 vOnBynary := False;
 bSource   := '';
 If Length(sLineBreak) > 1 Then
  vFlagPos := 1;
 vline     := Source;
 While Pos(sLineBreak, vline) > 0 Do
  Begin
   vTempline := Copy(vLine, 1, Pos(sLineBreak, vline) -1);
   If Pos(cContentTransferEncoding, lowercase(vTempline)) = 1 Then
    Begin
     vTempline2 := lowercase(Trim(StringReplace(vTempline, cContentTransferEncoding, '', [])));
     vOnbynary  := Pos('binary', vTempline2) > 0;
     Delete(vLine, 1, Pos(sLineBreak, vline) + vFlagPos);
    End
   Else If vOnbynary Then
    Begin
     bSource   := Copy(vline, 1, Pos(Boundary, vline) -1);
     Delete(vline, 1, Length(bSource));
     If Length(bSource) > 0 Then
      Begin
       While bSource[Length(bSource) - FinalStrPos] = '-' Do
        Delete(bSource, Length(bSource), 1);
       If Copy(bSource, Length(bSource) - vFlagPos, Length(sLineBreak)) = sLineBreak Then
        Delete(bSource, Length(bSource) - vFlagPos, Length(sLineBreak));
       If Copy(bSource, 1, Length(sLineBreak)) = sLineBreak Then
        Delete(bSource, 1, Length(sLineBreak));
      End;
     Dest.Add(bSource);
     bSource   := '';
     vOnbynary := False;
    End
   Else
    Begin
     Delete(vLine, 1, Pos(sLineBreak, vline) + vFlagPos);
     Dest.Add(vTempline);
    End;
  End;
 If Trim(vLine) <> '' then
  Dest.Add(vLine);
End;

Procedure TRESTDWQXBasePooler.ReadParams(Source         : TStringlist;
                                             Var InitPos    : Integer;
                                             Var ParamType  : TRESTDWQXBodyType;
                                             Var Paramname,
                                             ParamValue     : String;
                                             Boundary       : String);
Const
 cContentTransferEncoding = 'content-transfer-encoding';
 cContentType             = 'content-type';
Var
 X, A           : Integer;
 vTempLine,
 vTempData,
 vTempFileName,
 vValue,
 vValueData     : String;
 vInitBoundary  : Boolean;
Begin
 X             := InitPos;
 vTempLine     := '';
 vTempData     := '';
 vTempFileName := '';
 vValue        := '';
 vValueData    := '';
 vInitBoundary := False;
 While X <= Source.Count -1 Do
  Begin
   vTempLine := Source[X];
   If Not vInitBoundary Then
    vInitBoundary := Pos(Boundary, vTempLine) > 0
   Else
    Begin
     If Pos(lowercase('Content-Disposition'), lowercase(vTempLine)) > 0 Then
      Begin
       vTempData := StringReplace(Copy(vTempLine, Pos('name=', vTempLine) + Length('name='), Length(vTempLine) - Pos('name=', vTempLine)), '"', '', [rfReplaceAll]);
       Paramname := vTempData;
       vValue    := Paramname;
      End
     Else If vValue <> '' Then
      Begin
       If (Pos(cContentTransferEncoding, Lowercase(vTempLine)) = 0) And
          (Pos(cContentType, Lowercase(vTempLine)) = 0)             Then
        Begin
         If Pos(Boundary, vTempLine) = 0 Then
          Begin
           If vValueData = '' Then
            Begin
             If ParamType <> bt_octetstream Then
              vValueData := vValueData + StringReplace(vTempLine, sLineBreak, '', [rfReplaceAll, rfIgnoreCase])
             Else
              vValueData := vTempLine;
            End
           Else
            Begin
             If vValueData[length(vValueData) - FinalStrPos] = '=' Then
              Delete(vValueData, Length(vValueData), 1);
             If ParamType <> bt_octetstream Then
              vValueData := vValueData + StringReplace(vTempLine, sLineBreak, '', [rfReplaceAll, rfIgnoreCase])
             Else
              vValueData := vTempLine;
            End;
          End
         Else
          Break;
        End
       Else
        Begin
         If (Pos(cContentType, Lowercase(vTempLine)) > 0) Then
          ParamType := GetBodyType(vTempLine);
        End;
      End;
    End;
   Inc(X);
  End;
 If vValue <> '' Then
  Begin
   ParamValue := StringReplace(vValueData, '=3D', '=', [rfReplaceAll]);
   InitPos    := X -1;
  End;
End;

Function CountExpression(Value      : String;
                         Expression : Char): Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For I := InitStrPos To Length(Value) - FinalStrPos Do
  Begin
   If Value[I] = Expression Then
    Inc(Result);
  End;
End;

Function TRESTDWQXBasePooler.RemoveBackslashCommands(Value : String) : String;
Begin
 Result := StringReplace(Value, '../', '', [rfReplaceAll]);
End;

Function  TRESTDWQXBasePooler.FindRoute(Url : String;
                                        Var ParamsUrl : String) : TRESTDWQXDataRoute;
Var
 I,
 SizeURL    : Integer;
 vActualURL,
 vActualCopyURL : String;
Begin
 Result := Nil;
 For I := 0 To vDataRouteList.Count -1 Do
  Begin
   If vDataRouteList[I].DataRoute[Length(vDataRouteList[I].DataRoute) - FinalStrPos] <> '/' Then
    vActualURL     := vDataRouteList[I].DataRoute + '/'
   Else
    vActualURL     := vDataRouteList[I].DataRoute;
   SizeURL        := Length(vActualURL);
   If Length(Url) <= SizeURL Then
    Begin
     vActualCopyURL := Url;
     If vActualCopyURL[Length(vActualCopyURL) - FinalStrPos] <> '/' Then
      vActualCopyURL := vActualCopyURL + '/';
    End
   Else
    Begin
     vActualCopyURL := Copy(Url, InitStrPos, SizeURL);
     If vActualCopyURL[Length(vActualCopyURL) - FinalStrPos] = '?' Then
      vActualCopyURL := StringReplace(vActualCopyURL, '?', '/', [rfReplaceAll]);
    End;
   If vActualCopyURL = vActualURL Then
    Begin
     ParamsUrl := Copy(Url, SizeURL + InitStrPos, Length(Url) - SizeURL);
     Result    := vDataRouteList[I];
     Break;
    End;
  End;
End;

Procedure TRESTDWQXBasePooler.AddUrl(Url               : String;
                                     Routes            : TDWRoutes;
                                     ReplyRequest      : TRESTDWQXReplyRequest;
                                     NeedAuthorization : Boolean = True);
Var
 DataRoute : TRESTDWQXDataRoute;
 aUrl      : String;
Begin
 aUrl      := Url;
 If Trim(aUrl) <> '' Then
  Begin
   If aUrl[InitStrPos] <> '/' Then
    aUrl := '/' + aUrl;
   DataRoute := TRESTDWQXDataRoute.Create;
   DataRoute.DataRoute := aUrl;
   DataRoute.Routes := Routes;
   DataRoute.NeedAuthorization := NeedAuthorization;
   DataRoute.vOnReplyRequest   := ReplyRequest;
   vDataRouteList.Add(DataRoute);
  End;
End;

Procedure TRESTDWQXBasePooler.AddUrl(Url                : String;
                                     Routes             : TDWRoutes;
                                     ReplyRequestStream : TRESTDWQXReplyRequestStream;
                                     NeedAuthorization  : Boolean = True);
Var
 DataRoute : TRESTDWQXDataRoute;
 aUrl      : String;
Begin
 aUrl := Url;
 If Trim(aUrl) <> '' Then
  Begin
   If aUrl[InitStrPos] <> '/' Then
    aUrl := '/' + aUrl;
   DataRoute := TRESTDWQXDataRoute.Create;
   DataRoute.DataRoute := aUrl;
   DataRoute.Routes := Routes;
   DataRoute.NeedAuthorization     := NeedAuthorization;
   DataRoute.vOnReplyRequestStream := ReplyRequestStream;
   vDataRouteList.Add(DataRoute);
  End;
End;

Function  TRESTDWQXBasePooler.AddValue(cName, Value : String;
                                           Separator   : String = ':') : String;
Begin
 Result := Format('%s%s%s', [Name, Value, Separator]);
End;

Function  TRESTDWQXBasePooler.ExecProcess(Ctxt     : TRESTDWComponent;
                                          AContext : TIdContext) : Cardinal;
Var
 I                  : Integer;
 DWParamsD,
 DWParams           : TDWParams;
 vOldMethod,
 vBasePath,
 vObjectName,
 vLocAccessTag,
 vLocWelcomeMessage,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 vUrlToken,
 baseEventUnit,
 serverEventsName,
 vCmd,
 Cmd, vmark,
 aurlContext,
 JSONStr,
 ReturnObject,
 sFile,
 sContentType,
 vContentType,
 LocalDoc,
 vIPVersion,
 aToken,
 vToken,
 vDataBuff,
 vCORSOption,
 vAuthenticationString,
 vAuthUsername,
 vAuthPassword,
 sCharSet,
 vBoundary,
 tmp, tmpvalue       : String;
 vAuthTokenParam     : TRDWAuthTokenParam;
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
 msgEnd              : Boolean;
 ServerContextStream,
 mb,
 mb2,
 ms                  : TStringStream;
 BodyType            : TRESTDWQXBodyType;
 RequestType         : TRequestType;
 vDecoderHeaderList  : TStringList;
 vNewParam           : Boolean;
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
 Procedure DestroyComponents;
 Begin
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(vAuthTokenParam)   Then
   FreeAndNil(vAuthTokenParam);
 End;
 Procedure WriteError(Title, Body, Footer : String);Overload;
 Begin
  Result  := Ctxt.StatusCode;
  mb                                   := TStringStream.Create(Ctxt.ErrorMessage);
  mb.Position                          := 0;
  Ctxt.OutHeaders.Text                 := mb.DataString;
  Ctxt.OutContent                      := Get404Error(Title, Body, Footer);
  Ctxt.OutContentType                  := 'text/html';
  FreeAndNil(mb);
 End;
 Procedure WriteError(AuthMessage, Value : String);Overload;
 Begin
  mb                                    := Nil;
  Result  := Ctxt.StatusCode;
  If AuthMessage <> '' Then
   Begin
    Ctxt.ErrorMessage := AuthMessage;
    mb                                 := TStringStream.Create(Ctxt.ErrorMessage);
    mb.Position                        := 0;
    Ctxt.OutHeaders.Text               := mb.DataString;
   End;
  Ctxt.OutContent                      := Value;
  If AuthMessage <> '' Then
   FreeAndNil(mb);
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
 Procedure PrepareBasicAuth(AuthenticationString : String; Var AuthUsername, AuthPassword : String);
 Var
  vAuthenticationString : String;
 Begin
  AuthPassword := '';
  AuthUsername := '';
  vAuthenticationString := AuthenticationString;
  If pos('basic', lowercase(vAuthenticationString)) > 0 Then
   Begin
    vAuthenticationString := DecodeStrings(Trim(StringReplace(AuthenticationString, 'basic', '', [rfIgnorecase]))
                                                {$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
    AuthUsername := Copy(vAuthenticationString, InitStrPos, Pos(':', vAuthenticationString) -1);
    Delete(vAuthenticationString, InitStrPos, Pos(':', vAuthenticationString));
    AuthPassword := vAuthenticationString;
   End;
 End;
Begin
 tmp                := '';
 vIPVersion         := 'ipv4';
 baseEventUnit      := '';
 vLocAccessTag         := '';
 vLocWelcomeMessage    := Ctxt.WelcomeMessage;
 {$IF Defined(ANDROID) Or Defined(IOS)}
 vBasePath          := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, '/');
 {$ELSE}
 vBasePath          := ExtractFilePath(ParamStr(0));
 {$IFEND}
 vContentType          := '';
 DWParams              := TDWParams.Create;
 DWParams.CopyFrom(Ctxt.DWParams);
 ServerContextStream   := Nil;
 mb                    := Nil;
 mb2                   := Nil;
 ms                    := Nil;
 vAuthTokenParam       := Nil;
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
 vToken                := '';
 vDataBuff             := '';
 vCmd                  := '';
 Result                := Ctxt.StatusCode;
 Cmd                   := Trim(Ctxt.URL);
 BodyType              := bt_none;
 sCharSet              := '';
 Try
  If Ctxt.Method = rtGet Then
   Begin
    vCmd := Ctxt.URL;
    {$IFDEF MSWINDOWS}
    If vCmd <> '' Then
     If vCmd[InitStrPos] = '\' Then
      Delete(vCmd, 1, 1);
     vCmd := StringReplace(vCmd, '/', '\', [rfReplaceAll]);
    {$ENDIF}
    sFile := FRootPath + vCmd;
    If Pos('?', sFile) > 0 Then
     sFile := Copy(sFile, 1, Pos('?', sFile) -1);
    If     (Pos('.HTML', UpperCase(sFile)) > 0) Then
     Begin
      sContentType:='text/html';
 	   sCharSet := 'utf-8';
     End
    Else If (Pos('.PNG', UpperCase(sFile)) > 0) Then
     sContentType := 'image/png'
    Else If (Pos('.ICO', UpperCase(sFile)) > 0) Then
     sContentType := 'image/ico'
    Else If (Pos('.GIF', UpperCase(sFile)) > 0) Then
     sContentType := 'image/gif'
    Else If (Pos('.JPG', UpperCase(sFile)) > 0) Then
     sContentType := 'image/jpg'
    Else If (Pos('.JS',  UpperCase(sFile)) > 0) Then
     sContentType := 'application/javascript'
    Else If (Pos('.PDF', UpperCase(sFile)) > 0) Then
     sContentType := 'application/pdf'
    Else If (Pos('.CSS', UpperCase(sFile)) > 0) Then
     sContentType:='text/css';
    If (vPathTraversalRaiseError) And
       (DWFileExists(sFile, FRootPath)) And
       (SystemProtectFiles(sFile)) Then
     Begin
      Try
       Ctxt.OutContentType := 'application/json';
       Ctxt.OutContent     := escape_chars(cEventNotFound);
       Result              := 404;
       Exit;
      Finally
       DestroyComponents;
      End;
     End;
    If DWFileExists(sFile, FRootPath) then
     Begin
      Ctxt.OutContentType := GetMIMEType(sFile);
      mb     := TStringStream.Create('');
      Try
       {$IFNDEF FPC}
        {$if CompilerVersion < 21}
         TMemoryStream(mb).LoadFromFile(sFile);
        {$ELSE}
         mb.LoadFromFile(sFile);
        {$IFEND}
       {$ELSE}
        TMemoryStream(mb).LoadFromFile(sFile);
       {$ENDIF}
       Ctxt.OutContent := String(mb.DataString);
      Finally
       FreeAndNil(mb);
      End;
      Exit;
     End;
   End;
  vCORSOption := '';
  If Ctxt.InHeaders.IndexOf('OPTIONS') = 1 Then
   vCORSOption := Ctxt.InHeaders.Values['OPTIONS'];
  RequestType := Ctxt.Method;
  vBoundary := '';
  SetupRequest(Ctxt.InHeaders, BodyType, vBoundary);
  If DWParams <> Nil Then
   Begin
    If DWParams.ItemsString['dwwelcomemessage']      <> Nil  Then
     vLocWelcomeMessage    := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
    If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
     vLocAccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
    If (DWParams.ItemsString['datacompression']      <> Nil) Then
     compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
    If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
     encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
    If (DWParams.ItemsString['dwusecript']           <> Nil) Then
     vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
    If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
     dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
    If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
     vBinaryCompatibleMode := StringToBoolean(DWParams.ItemsString['BinaryCompatibleMode'].AsString);
   End;
  WelcomeAccept         := Ctxt.WelcomeAccept;
  tmp                   := '';
  vAuthenticationString := '';
  vToken                := '';
  vGettoken             := False;
  vAcceptAuth           := False;
  If (vPathTraversalRaiseError) And (TravertalPathFind(Trim(Ctxt.URL))) Then
   Begin
    Try
     Ctxt.OutContentType := 'application/json';
     Ctxt.OutContent     := escape_chars(cEventNotFound);
     Result              := 404;
     Exit;
    Finally
     DestroyComponents;
    End;
   End;
  If Assigned(Ctxt.DataRoute) Then
   Begin
    If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
     vLocWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
    If (DWParams.ItemsString['dwaccesstag'] <> Nil) Then
     vLocAccessTag := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
    SetClientWelcomeMessage(vLocWelcomeMessage);
    vIPVersion := 'undefined';
    SetClientInfo(Ctxt.RemoteIP, vIPVersion, Ctxt.UserAgent, Ctxt.URL, '', StrToInt(Ctxt.RequestID));
    If ((vCORS) And (vCORSOption <> 'OPTIONS')) Or
        (vServerAuthOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken]) Then
     Begin
      vAcceptAuth           := False;
      Ctxt.StatusCode       := 401;
      Ctxt.ErrorMessage     := cInvalidAuth;
      Case vServerAuthOptions.AuthorizationOption Of
       rdwAOBasic  : Begin
                      vNeedAuthorization := False;
                      If Not(Ctxt.DataRoute = Nil) Then
                       vNeedAuthorization := Ctxt.DataRoute.NeedAuthorization;
                      If vNeedAuthorization Then
                       Begin
                        vAuthenticationString := Ctxt.InHeaders.Values['Authorization'];
                        PrepareBasicAuth(vAuthenticationString, vAuthUsername, vAuthPassword);
                        If Assigned(OnUserBasicAuth) Then
                         Begin
                          OnUserBasicAuth(vLocWelcomeMessage, vLocAccessTag, vAuthUsername,
                                          vAuthPassword, DWParams, Ctxt.StatusCode, Ctxt.ErrorMessage, vAcceptAuth);
                          If Not vAcceptAuth Then
                           Begin
                            Ctxt.StatusCode := 401;
                            Result          := Ctxt.StatusCode;
                            If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).AuthDialog Then
                             Begin
                              Ctxt.ErrorMessage := Format(AuthRealm, ['Basic', TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, '']);
                              If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError(Ctxt.ErrorMessage, TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError(TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                          TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                          TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                             End
                            Else
                             Begin
                              If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError('', TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError('', cInvalidAuth);
                             End;
                            DestroyComponents;
                            Exit;
                           End;
                         End
                        Else If Not ((vAuthUsername = TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username) And
                                     (vAuthPassword = TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password)) Then
                         Begin
                          Ctxt.StatusCode := 401;
                          Result          := Ctxt.StatusCode;
                          If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).AuthDialog Then
                           Begin
                            If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                             WriteError(Ctxt.ErrorMessage, TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                            Else
                             WriteError(TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                        TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                        TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                           End
                          Else
                           Begin
                            If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                             WriteError('', TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                            Else
                             WriteError('', cInvalidAuth);
                           End;
                          Ctxt.OutHeaders.Add(Format(AuthRealm, ['Basic', TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, '']));
                          DestroyComponents;
                          Exit;
                         End;
                       End;
                     End;
       rdwAOBearer : Begin
                      vUrlToken := Ctxt.URL;
                      If vUrlToken =
                         Lowercase(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                       Begin
                        vGettoken       := True;
                        Ctxt.StatusCode := 404;
                        Ctxt.ErrorMessage := cEventNotFound;
                        If (RequestTypeToRoute(RequestType) In TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                           (crAll in TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                         Begin
                          vToken       := '';
                          If DWParams <> Nil Then
                           If DWParams.ItemsString['Authorization'] <> Nil Then
                            vToken      := DWParams.ItemsString['Authorization'].AsString;
                          If Trim(vToken) <> '' Then
                           Begin
                            aToken      := GetTokenString(vToken);
                            If aToken = '' Then
                             aToken     := GetBearerString(vToken);
                            vToken      := aToken;
                           End;
                          If Assigned(OnGetToken) Then
                           Begin
                            vTokenValidate := True;
                            vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                            vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                            If DWParams.ItemsString['RDWParams'] <> Nil Then
                             Begin
                              DWParamsD := TDWParams.Create;
                              DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                              OnGetToken(vLocWelcomeMessage, vLocAccessTag, DWParamsD,
                                         TRDWAuthOptionTokenServer(vAuthTokenParam),
                                         Ctxt.StatusCode, Ctxt.ErrorMessage, vToken, vAcceptAuth);
                              FreeAndNil(DWParamsD);
                             End
                            Else
                             OnGetToken(vLocWelcomeMessage, vLocAccessTag, DWParams,
                                        TRDWAuthOptionTokenServer(vAuthTokenParam),
                                        Ctxt.StatusCode, Ctxt.ErrorMessage, vToken, vAcceptAuth);
                            If Not vAcceptAuth Then
                             Begin
                              Result        := Ctxt.StatusCode;
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                               End
                              Else
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError('', cInvalidAuth);
                               End;
                              Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                              DestroyComponents;
                              Exit;
                             End;
                           End
                          Else
                           Begin
                            Result        := Ctxt.StatusCode;
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                             End
                            Else
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError('', cInvalidAuth);
                             End;
                            Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                            DestroyComponents;
                            Exit;
                           End;
                         End
                        Else
                         Begin
                          Result          := Ctxt.StatusCode;
                          If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                           Begin
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                             WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                            Else
                             WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                        TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                        TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                           End
                          Else
                           Begin
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                             WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                            Else
                             WriteError('', cInvalidAuth);
                           End;
                          Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                          DestroyComponents;
                          Exit;
                         End;
                       End
                      Else
                       Begin
                        Ctxt.StatusCode   := 401;
                        Ctxt.ErrorMessage := cInvalidAuth;
                        vTokenValidate    := True;
                        vNeedAuthorization := False;
                        If Not(Ctxt.DataRoute = Nil) Then
                         vNeedAuthorization := Ctxt.DataRoute.NeedAuthorization;
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
                              vToken       := Ctxt.InHeaders.Values['Authorization'];
                            {$ELSE}
                             If Assigned(AContext.Data) Then
                              vToken       := TRDWAuthRequest(AContext.Data).Token
                             Else
                              vToken       := Ctxt.InHeaders.Values['Authorization'];
                            {$ENDIF}
                           {$ELSE}
                            If Assigned(AContext.Data) Then
                             vToken       := TRDWAuthRequest(AContext.Data).Token
                            Else
                             vToken       := Ctxt.InHeaders.Values['Authorization'];
                           {$IFEND}
                          {$ELSE}
                           If Assigned(AContext.Data) Then
                            vToken       := TRDWAuthRequest(AContext.Data).Token
                           Else
                            vToken       := Ctxt.InHeaders.Values['Authorization'];
                          {$ENDIF}
                            If Trim(vToken) <> '' Then
                             Begin
                              aToken      := GetTokenString(vToken);
                              If aToken = '' Then
                               aToken     := GetBearerString(vToken);
                              vToken      := aToken;
                             End;
                           End;
                          If Not vAuthTokenParam.FromToken(vToken) Then
                           Begin
                            Result        := Ctxt.StatusCode;
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                             End
                            Else
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError('', cInvalidAuth);
                             End;
                            Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                            DestroyComponents;
                            Exit;
                           End
                          Else
                           vTokenValidate := False;
                          If Assigned(OnUserTokenAuth) Then
                           Begin
                            OnUserTokenAuth(vLocWelcomeMessage, vLocAccessTag, DWParams,
                                            TRDWAuthOptionTokenServer(vAuthTokenParam),
                                            Ctxt.StatusCode, Ctxt.ErrorMessage, vToken, vAcceptAuth);
                            vTokenValidate := Not(vAcceptAuth);
                            If Not vAcceptAuth Then
                             Begin
                              Result        := Ctxt.StatusCode;
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                               End
                              Else
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError('', cInvalidAuth);
                               End;
                              Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
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
                      vUrlToken := Ctxt.URL;
                      If vUrlToken =
                         Lowercase(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenEvent) Then
                       Begin
                        vGettoken      := True;
                        Ctxt.StatusCode     := 404;
                        Ctxt.ErrorMessage  := cEventNotFound;
                        If (RequestTypeToRoute(RequestType) In TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Or
                           (crAll in TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).GetTokenRoutes) Then
                         Begin
                          vToken       := '';
                          If DWParams <> Nil Then
                           If DWParams.ItemsString['Authorization'] <> Nil Then
                            vToken      := DWParams.ItemsString['Authorization'].AsString;
                          If Trim(vToken) <> '' Then
                           Begin
                            aToken      := GetTokenString(vToken);
                            If aToken = '' Then
                             aToken     := GetBearerString(vToken);
                            vToken      := aToken;
                           End;
                          If Assigned(OnGetToken) Then
                           Begin
                            vTokenValidate := True;
                            vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                            vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                            If DWParams.ItemsString['RDWParams'] <> Nil Then
                             Begin
                              DWParamsD := TDWParams.Create;
                              DWParamsD.FromJSON(DWParams.ItemsString['RDWParams'].Value);
                              OnGetToken(vLocWelcomeMessage, vLocAccessTag, DWParamsD,
                                         TRDWAuthOptionTokenServer(vAuthTokenParam),
                                         Ctxt.StatusCode, Ctxt.ErrorMessage, vToken, vAcceptAuth);
                              FreeAndNil(DWParamsD);
                             End
                            Else
                             OnGetToken(vLocWelcomeMessage, vLocAccessTag, DWParams,
                                        TRDWAuthOptionTokenServer(vAuthTokenParam),
                                        Ctxt.StatusCode, Ctxt.ErrorMessage, vToken, vAcceptAuth);
                            If Not vAcceptAuth Then
                             Begin
                              Result        := Ctxt.StatusCode;
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                               End
                              Else
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError('', cInvalidAuth);
                               End;
                              Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                              DestroyComponents;
                              Exit;
                             End;
                           End
                          Else
                           Begin
                            Result        := Ctxt.StatusCode;
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                             End
                            Else
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError('', cInvalidAuth);
                             End;
                            Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                            DestroyComponents;
                            Exit;
                           End;
                         End
                        Else
                         Begin
                          Result        := Ctxt.StatusCode;
                          If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                           Begin
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                             WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                            Else
                             WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                        TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                        TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                           End
                          Else
                           Begin
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                             WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                            Else
                             WriteError('', cInvalidAuth);
                           End;
                          Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                          DestroyComponents;
                          Exit;
                         End;
                       End
                      Else
                       Begin
                        Ctxt.StatusCode      := 401;
                        Ctxt.ErrorMessage   := cInvalidAuth;
                        vTokenValidate  := True;
                        vNeedAuthorization := False;
                        If Not(Ctxt.DataRoute = Nil) Then
                         vNeedAuthorization := Ctxt.DataRoute.NeedAuthorization;
                        If vNeedAuthorization Then
                         Begin
                          vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                          vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
                          If DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key] <> Nil Then
                           vToken         := DWParams.ItemsString[TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Key].AsString
                          Else
                           Begin
                            vToken       := Ctxt.InHeaders.Values['Authorization'];
                            If Trim(vToken) <> '' Then
                             Begin
                              aToken      := GetTokenString(vToken);
                              If aToken = '' Then
                               aToken     := GetBearerString(vToken);
                              vToken      := aToken;
                             End;
                           End;
                          If Not vAuthTokenParam.FromToken(vToken) Then
                           Begin
                            Result        := Ctxt.StatusCode;
                            If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                          TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                             End
                            Else
                             Begin
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                               WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                              Else
                               WriteError('', cInvalidAuth);
                             End;
                            Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
                            DestroyComponents;
                            Exit;
                           End
                          Else
                           vTokenValidate := False;
                          If Assigned(OnUserTokenAuth) Then
                           Begin
                            OnUserTokenAuth(vLocWelcomeMessage, vLocAccessTag, DWParams,
                                            TRDWAuthOptionTokenServer(vAuthTokenParam),
                                            Ctxt.StatusCode, Ctxt.ErrorMessage, vToken, vAcceptAuth);
                            vTokenValidate := Not(vAcceptAuth);
                            If Not vAcceptAuth Then
                             Begin
                              Result        := Ctxt.StatusCode;
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError(Ctxt.ErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404TitleMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404BodyMessage,
                                            TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).Custom404FooterMessage);
                               End
                              Else
                               Begin
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError('', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
                                Else
                                 WriteError('', cInvalidAuth);
                               End;
                              Ctxt.OutHeaders.Add(Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']));
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
      Ctxt.StatusCode            := 200;
      Ctxt.ErrorMessage         := '';
     End;
    If Assigned(OnWelcomeMessage) then
     OnWelcomeMessage(vLocWelcomeMessage, vLocAccessTag, WelcomeAccept, vContentType, Ctxt.ErrorMessage);
   End;
  If Assigned(vLastRequest) Then
   Begin
    If Assigned(vLastRequest) Then
     vLastRequest(Ctxt.UserAgent + sLineBreak + Ctxt.URL);
   End;
  If Assigned(Ctxt.DataRoute) Then
   Begin
    vSpecialServer := False;
    Ctxt.OutContentType := 'application/json';
    If (Trim(Ctxt.URL) = '') Then
     Begin
      If vDefaultPage.Count > 0 Then
       vReplyString  := vDefaultPage.Text
      Else
       vReplyString  := TServerStatusHTML;
      Ctxt.StatusCode   := 200;
      Ctxt.OutContentType := 'text/html';
     End
    Else
     Begin
      If DWParams <> Nil Then
       Begin
        If (DWParams.ItemsString['dwassyncexec'] <> Nil) And (Not (dwassyncexec)) Then
         dwassyncexec := DWParams.ItemsString['dwassyncexec'].AsBoolean;
        If DWParams.ItemsString['dwusecript'] <> Nil Then
         vdwCriptKey  := DWParams.ItemsString['dwusecript'].AsBoolean;
       End;
      If dwassyncexec Then
       Begin
        Result                                := 200;
        vReplyString                          := AssyncCommandMSG;
        If compresseddata Then
         mb                                  := ZCompressStreamSS(vReplyString)
        Else
         mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
        mb.Position                          := 0;
        Ctxt.OutContent                      := String(mb.DataString);
        FreeAndNil(mb);
       End;
      If DWParams.itemsstring['MetadataRequest']      <> Nil Then
       vMetadata := DWParams.itemsstring['MetadataRequest'].AsBoolean;
      If (Assigned(DWParams)) And (Assigned(vCripto))        Then
       DWParams.SetCriptOptions(vdwCriptKey, vCripto.Key);
      If (Not (vGettoken)) And (Not (vTokenValidate)) Then
       Begin
        ServerContextStream := TStringStream.Create('');
        If Not ServiceMethods(Ctxt, DWParams,
                              JSONStr, TRESTDWComponent(Ctxt).JsonMode, Ctxt.StatusCode,  vContentType, vServerContextCall, ServerContextStream,
                              EncodeStrings, vLocAccessTag, WelcomeAccept, RequestType, vMark,
                              Ctxt.InHeaders, vBinaryEvent, vMetadata, vBinaryCompatibleMode) Or (lowercase(vContentType) = 'application/php') Then
         Begin
          If Not dwassyncexec Then
           Begin
            If Not vSpecialServer Then
             Begin
              If RemoveBackslashCommands(Ctxt.URL) <> '' Then
               sFile := GetFileOSDir(ExcludeTag(tmp + RemoveBackslashCommands(Ctxt.URL)))
              Else
               sFile := GetFileOSDir(ExcludeTag(Cmd));
              vFileExists := DWFileExists(sFile, FRootPath);
              vTagReply   := vFileExists or scripttags(ExcludeTag(Cmd));
              If vTagReply Then
               Begin
               {$IFNDEF FPC}
                mb     := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
               {$ELSE}
                mb     := TStringStream.Create('');
               {$ENDIF}
                Try
                 {$IFNDEF FPC}
                  {$if CompilerVersion < 21}
                   TMemoryStream(mb).LoadFromFile(sFile);
                  {$ELSE}
                   mb.LoadFromFile(sFile);
                  {$IFEND}
                 {$ELSE}
                  TMemoryStream(mb).LoadFromFile(sFile);
                 {$ENDIF}
                 Ctxt.OutContent := String(mb.DataString);
                Finally
                 FreeAndNil(mb);
                End;
                Result := 200;
               End;
             End;
           End;
         End;
       End
      Else
       Begin
        JSONStr                         := vToken;
        TRESTDWComponent(Ctxt).JsonMode := jmPureJSON;
        Ctxt.StatusCode                      := 200;
       End;
     End;
   End;
  If Not dwassyncexec Then
   Begin
    If (Not (vTagReply)) Then
     Begin
      If vContentType <> '' Then
       Ctxt.OutContentType := vContentType;
//      If VEncondig = esUtf8 Then
//       Ctxt.OutContentType := Ctxt.OutContentType + ';utf-8'
//      Else
//       Ctxt.OutContentType := Ctxt.OutContentType + ';ansi';
      If Not vServerContextCall Then
       Begin
        If (Ctxt.URL <> '') Then
         Begin
          If Ctxt.JsonMode in [jmDataware, jmUndefined] Then
           Begin
            If Trim(JSONStr) <> '' Then
             Begin
              If Not(((Pos('{', JSONStr) > 0)   And
                      (Pos('}', JSONStr) > 0))  Or
                     ((Pos('[', JSONStr) > 0)   And
                      (Pos(']', JSONStr) > 0))) Then
               Begin
                If Not (WelcomeAccept) And (Ctxt.ErrorMessage <> '') Then
                  JSONStr := escape_chars(Ctxt.ErrorMessage)
                Else If Not((JSONStr[InitStrPos] = '"')  And
                       (JSONStr[Length(JSONStr)] = '"')) Then
                 JSONStr := '"' + JSONStr + '"';
               End;
             End;
            If vBinaryEvent Then
             Begin
              vReplyString := JSONStr;
              Ctxt.StatusCode   := 200;
             End
            Else
             Begin
              If Not (WelcomeAccept) And (Ctxt.ErrorMessage <> '') Then
               vReplyString := escape_chars(Ctxt.ErrorMessage)
              Else
               vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
             End;
           End
          Else If Ctxt.JsonMode = jmPureJSON Then
           Begin
            If (Trim(JSONStr) = '') And (WelcomeAccept) Then
             vReplyString := '{}'
            Else If Not (WelcomeAccept) And (Ctxt.ErrorMessage <> '') Then
             vReplyString := escape_chars(Ctxt.ErrorMessage)
            Else
             vReplyString := JSONStr;
           End;
         End;
        Result := Ctxt.StatusCode;
        If compresseddata Then
         Begin
          If vBinaryEvent Then
           Begin
            {$IFNDEF FPC}
             ms     := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
            {$ELSE}
             ms     := TStringStream.Create('');
            {$ENDIF}
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
           mb2                                   := ZCompressStreamSS(vReplyString);
          If Ctxt.StatusCode <> 200 Then
           Begin
            If Assigned(mb2) Then
             FreeAndNil(mb2);
            Ctxt.OutContent := escape_chars(vReplyString);
           End
          Else
           Begin
            mb2.Position := 0;
            Ctxt.OutContent := mb2.DataString;
            FreeAndNil(mb2);
           End;
         End
        Else
         Begin
          If Ctxt.OutContentStream.Size = 0 Then
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
               mb             := TStringStream.Create(vReplyString);
              mb.Position     := 0;
              Ctxt.OutContent := mb.datastring;
              FreeAndNil(mb);
             {$ELSE}
              If vBinaryEvent Then
               Begin
                mb := TStringStream.Create('');
                Try
                 DWParams.SaveToStream(mb, tdwpxt_OUT);
                Finally
                End;
                Ctxt.OutContent := mb.DataString;
                FreeAndNil(mb);
               End
              Else
               Ctxt.OutContent := vReplyString;
             {$IFEND}
            {$ELSE}
             If vBinaryEvent Then
              Begin
               mb := TStringStream.Create('');
               Try
                DWParams.SaveToStream(mb, tdwpxt_OUT);
               Finally
               End;
               Ctxt.OutContent := mb.DataString;
               FreeAndNil(mb);
              End
             Else
              Begin
               If VEncondig = esUtf8 Then
                Ctxt.OutContent := Utf8Encode(vReplyString)
               Else
                Ctxt.OutContent := vReplyString;
              End;
            {$ENDIF}
           End;
         End;
       End
      Else
       Begin
        LocalDoc := '';
        If Not vSpecialServer Then
         Begin
          Result             := Ctxt.StatusCode;
          If ServerContextStream <> Nil Then
           Begin
            Ctxt.OutContent := ServerContextStream.DataString;
            FreeAndNil(ServerContextStream);
           End
          Else
           Begin
            If VEncondig = esUtf8 Then
             Ctxt.OutContent := Utf8Encode(JSONStr)
            Else
             Ctxt.OutContent := JSONStr;
           End;
         End;
       End;
     End;
   End;
  If Assigned(vLastResponse) Then
   vLastResponse(vReplyString);
 Finally
//  If Assigned(vdwConnectionDefs) Then
//   FreeAndNil(vdwConnectionDefs);
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(ServerContextStream) Then
   FreeAndNil(ServerContextStream);
  If Assigned(mb) Then
   FreeAndNil(mb);
  If Assigned(mb2) Then
   FreeAndNil(mb2);
  If Assigned(ms) Then
   FreeAndNil(ms);
  If Assigned(vAuthTokenParam) Then
   FreeAndNil(vAuthTokenParam);
  Result := Ctxt.StatusCode;
 End;
End;

Procedure TRESTDWQXBasePooler.AddDataRoute(DataRoute   : String);
Var
 vDataRoute : TRESTDWQXDataRoute;
Begin
 vDataRoute                   := TRESTDWQXDataRoute.Create;
 vDataRoute.DataRoute         := DataRoute;
 vDataRouteList.Add(vDataRoute);
End;

Procedure TRESTDWQXBasePooler.ApplyUpdatesJSON(Var Pooler         : String;
                                                    Var DWParams       : TDWParams;
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
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           If DWParams.ItemsString['Params'] <> Nil Then
//            Begin
//             DWParamsD := TDWParams.Create;
//             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
//            End;
//           If DWParams.ItemsString['SQL'] <> Nil Then
//            vSQL := DWParams.ItemsString['SQL'].Value;
//           Try
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            DWParams.ItemsString['Massive'].CriptOptions.Use := False;
//            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(DWParams.ItemsString['Massive'].AsString,
//                                                                                                    vSQL,
//                                                                                                    DWParamsD, vError, vMessageError, vRowsAffected);
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           If DWParamsD <> Nil Then
//            DWParamsD.Free;
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean        := vError;
//           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
//            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
//           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
//            Begin
//             DWParams.ItemsString['Result'].CriptOptions.Use := False;
//             If vTempJSON <> Nil Then
//              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded)
//             Else
//              DWParams.ItemsString['Result'].SetValue('');
//            End;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWQXBasePooler.ApplyUpdatesJSONTB(Var Pooler         : String;
                                                      Var DWParams       : TDWParams;
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
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           If DWParams.ItemsString['Params'] <> Nil Then
//            Begin
//             DWParamsD := TDWParams.Create;
//             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
//            End;
//           If DWParams.ItemsString['SQL'] <> Nil Then
//            vSQL := DWParams.ItemsString['SQL'].Value;
//           Try
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            DWParams.ItemsString['Massive'].CriptOptions.Use := False;
//            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdatesTB(DWParams.ItemsString['Massive'].AsString,
//                                                                                                     DWParamsD, vError, vMessageError, vRowsAffected);
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           If DWParamsD <> Nil Then
//            DWParamsD.Free;
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean        := vError;
//           If (DWParams.ItemsString['RowsAffected'] <> Nil) Then
//            DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
//           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
//            Begin
//             DWParams.ItemsString['Result'].CriptOptions.Use := False;
//             If vTempJSON <> Nil Then
//              DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded)
//             Else
//              DWParams.ItemsString['Result'].SetValue('');
//            End;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWQXBasePooler.ApplyUpdates_MassiveCache(Var Pooler         : String;
                                                             Var DWParams       : TDWParams;
                                                             hEncodeStrings     : Boolean;
                                                             AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           Try
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
////            DWParams.ItemsString['MassiveCache'].CriptOptions.Use := False;
//            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].AsString,
//                                                                                                   vError,  vMessageError);
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean        := vError;
//           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
//            Begin
//             If Assigned(vTempJSON) Then
//              DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded)
//             Else
//              DWParams.ItemsString['Result'].SetValue('');
//            End;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWQXBasePooler.ApplyUpdates_MassiveCacheTB(Var Pooler         : String;
                                                               Var DWParams       : TDWParams;
                                                               hEncodeStrings     : Boolean;
                                                               AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           Try
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
////            DWParams.ItemsString['MassiveCache'].CriptOptions.Use := False;
//            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCacheTB(DWParams.ItemsString['MassiveCache'].AsString,
//                                                                                                                  vError,  vMessageError);
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean        := vError;
//           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
//            Begin
//             If Assigned(vTempJSON) Then
//              DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded)
//             Else
//              DWParams.ItemsString['Result'].SetValue('');
//            End;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWQXBasePooler.Bind(Port        : Integer = 9092;
                                   ConsoleMode : Boolean = True);
Begin
 vServicePort := Port;
 vConsoleMode := ConsoleMode;
End;

Procedure TRESTDWQXBasePooler.ClearDataRoute;
Begin
 vDataRouteList.ClearList;
End;

Constructor TRESTDWQXBasePooler.Create(AOwner: TComponent);
Begin
 Inherited;
 vUseSSL := False;
 vProxyOptions                   := TProxyOptions.Create;
 vDefaultPage                    := TStringList.Create;
 vCORSCustomHeaders              := TStringList.Create;
 vDataRouteList                  := TRESTDWQXDataRouteList.Create;
 vCORSCustomHeaders.Add('Access-Control-Allow-Origin=*');
 vCORSCustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
 vCORSCustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
 vCripto                         := TCripto.Create;
 vClientWelcomeMessage           := '';
 vServerAuthOptions              := TRDWServerAuthOptionParams.Create(Self);
 vActive                         := False;
 vServerAuthOptions.AuthorizationOption                        := rdwAOBasic;
 TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username := 'testserver';
 TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password := 'testserver';
 VEncondig                       := esUtf8;
 vServicePort                    := 8082;
 vServerThreadPoolCount          := 32;
 vForceWelcomeAccess             := False;
 vPathTraversalRaiseError        := True;
 vCORS                           := False;
 FRootPath                       := '/';
 vRootUser                       := 'root';
 vServiceTimeout                 := -1;
 vConsoleMode                    := False;
 vRESTDWClientInfo               := TRESTDWClientInfo.Create;
 vAccessTag                      := '';
 vClientWelcomeMessage           := '';
End;

Destructor TRESTDWQXBasePooler.Destroy;
Begin
 SetActive(False);
 If Assigned(vProxyOptions) Then
  FreeAndNil(vProxyOptions);
 If Assigned(vCripto)       Then
  FreeAndNil(vCripto);
 If Assigned(vDefaultPage) Then
  FreeAndNil(vDefaultPage);
 If Assigned(vCORSCustomHeaders) Then
  FreeAndNil(vCORSCustomHeaders);
 If Assigned(vDataRouteList) Then
  FreeAndNil(vDataRouteList);
 If Assigned(vServerAuthOptions) Then
  FreeAndNil(vServerAuthOptions);
 If Assigned(vRESTDWClientInfo) Then
  FreeAndNil(vRESTDWClientInfo);
 Inherited;
End;

procedure TRESTDWQXBasePooler.EchoPooler(AContext           : TComponent;
                                              Var Pooler,
                                                  MyIP           : String;
                                              AccessTag          : String;
                                              Var InvalidTag     : Boolean);
Var
 I : Integer;
Begin
 InvalidTag := False;
 MyIP       := '';

End;

Procedure TRESTDWQXBasePooler.ExecuteCommandJSON(Var Pooler           : String;
                                                      Var DWParams         : TDWParams;
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
//  If ServerMethodsClass <> Nil Then
//   Begin
//    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//     Begin
//      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//       Begin
//        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//         Begin
//          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//           Begin
//            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//             Begin
//              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//              DWParams.ItemsString['Error'].AsBoolean       := True;
//              Exit;
//             End;
//           End;
//          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//           Begin
//            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
//            vError   := DWParams.ItemsString['Error'].AsBoolean;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//            If DWParams.ItemsString['Params'] <> Nil Then
//             Begin
//              DWParamsD := TDWParams.Create;
//              DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
//             End;
//            Try
//             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//             If DWParamsD <> Nil Then
//              Begin
//               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
//                                                                                                        DWParamsD, vError, vMessageError,
//                                                                                                        BinaryBlob,
//                                                                                                        vRowsAffected,
//                                                                                                        vExecute, BinaryEvent, Metadata,
//                                                                                                        BinaryCompatibleMode);
//               DWParamsD.Free;
//              End
//             Else
//              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
//                                                                                                       vError,
//                                                                                                       vMessageError,
//                                                                                                       BinaryBlob,
//                                                                                                       vRowsAffected,
//                                                                                                       vExecute, BinaryEvent, Metadata);
//            Except
//             On E : Exception Do
//              Begin
//               vMessageError := e.Message;
//               vError := True;
//              End;
//            End;
//            If vMessageError <> '' Then
//             Begin
//              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//             End;
//            DWParams.ItemsString['Error'].AsBoolean        := vError;
//            If DWParams.ItemsString['RowsAffected'] <> Nil Then
//             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              If (BinaryEvent) And (Not (vError)) Then
//               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
//              Else If Not(vError) And(vTempJSON <> '') Then
//               DWParams.ItemsString['Result'].SetValue(vTempJSON, DWParams.ItemsString['Result'].Encoded)
//              Else
//               DWParams.ItemsString['Result'].SetValue('');
//             End;
//           End;
//          Break;
//         End;
//       End;
//     End;
//   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTDWQXBasePooler.ExecuteCommandJSONTB(Var Pooler           : String;
                                                        Var DWParams         : TDWParams;
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
//  If ServerMethodsClass <> Nil Then
//   Begin
//    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//     Begin
//      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//       Begin
//        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//         Begin
//          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//           Begin
//            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//             Begin
//              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//              DWParams.ItemsString['Error'].AsBoolean       := True;
//              Exit;
//             End;
//           End;
//          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//           Begin
//            vError     := DWParams.ItemsString['Error'].AsBoolean;
//            vTablename := DWParams.ItemsString['rdwtablename'].AsString;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//            If DWParams.ItemsString['Params'] <> Nil Then
//             Begin
//              DWParamsD := TDWParams.Create;
//              DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
//             End;
//            Try
//             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//             If DWParamsD <> Nil Then
//              Begin
//               vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, DWParamsD, vError, vMessageError,
//                                                                                                          BinaryBlob,
//                                                                                                          vRowsAffected,
//                                                                                                          BinaryEvent, Metadata,
//                                                                                                          BinaryCompatibleMode);
//               DWParamsD.Free;
//              End
//             Else
//              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, vError,
//                                                                                                         vMessageError,
//                                                                                                         BinaryBlob,
//                                                                                                         vRowsAffected,
//                                                                                                         BinaryEvent, Metadata);
//            Except
//             On E : Exception Do
//              Begin
//               vMessageError := e.Message;
//               vError := True;
//              End;
//            End;
//            If vMessageError <> '' Then
//             Begin
//              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//             End;
//            DWParams.ItemsString['Error'].AsBoolean        := vError;
//            If DWParams.ItemsString['RowsAffected'] <> Nil Then
//             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              If (BinaryEvent) And (Not (vError)) Then
//               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
//              Else If Not(vError) And(vTempJSON <> '') Then
//               DWParams.ItemsString['Result'].SetValue(vTempJSON, DWParams.ItemsString['Result'].Encoded)
//              Else
//               DWParams.ItemsString['Result'].SetValue('');
//             End;
//           End;
//          Break;
//         End;
//       End;
//     End;
//   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTDWQXBasePooler.ExecuteCommandPureJSON(Var Pooler           : String;
                                                          Var DWParams         : TDWParams;
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
//  If ServerMethodsClass <> Nil Then
//   Begin
//    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//     Begin
//      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//       Begin
//        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//         Begin
//          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//           Begin
//            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//             Begin
//              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//              DWParams.ItemsString['Error'].AsBoolean       := True;
//              Exit;
//             End;
//           End;
//          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//           Begin
//            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
//            vError   := DWParams.ItemsString['Error'].AsBoolean;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//            Try
//             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
//                                                                                                      vError,
//                                                                                                      vMessageError,
//                                                                                                      BinaryBlob,
//                                                                                                      vRowsAffected,
//                                                                                                      vExecute, BinaryEvent, Metadata,
//                                                                                                      BinaryCompatibleMode);
//            Except
//             On E : Exception Do
//              Begin
//               vMessageError := e.Message;
//               vError := True;
//              End;
//            End;
//            If vMessageError <> '' Then
//             Begin
//              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//             End;
//            DWParams.ItemsString['Error'].AsBoolean := vError;
//            If DWParams.ItemsString['RowsAffected'] <> Nil Then
//             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              vEncoded := DWParams.ItemsString['Result'].Encoded;
//              If (BinaryEvent) And (Not (vError)) Then
//               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
//              Else If Not(vError) And (vTempJSON <> '') Then
//               DWParams.ItemsString['Result'].SetValue(vTempJSON, vEncoded)
//              Else
//               DWParams.ItemsString['Result'].SetValue('');
//             End;
//           End;
//          Break;
//         End;
//       End;
//     End;
//   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;


Procedure TRESTDWQXBasePooler.ExecuteCommandPureJSONTB(Var Pooler           : String;
                                                            Var DWParams         : TDWParams;
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
//  If ServerMethodsClass <> Nil Then
//   Begin
//    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//     Begin
//      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//       Begin
//        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//         Begin
//          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//           Begin
//            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//             Begin
//              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//              DWParams.ItemsString['Error'].AsBoolean       := True;
//              Exit;
//             End;
//           End;
//          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//           Begin
//            vError     := DWParams.ItemsString['Error'].AsBoolean;
//            vTablename := DWParams.ItemsString['rdwtablename'].AsString;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//            Try
//             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommandTB(vTablename, vError,
//                                                                                                        vMessageError,
//                                                                                                        BinaryBlob,
//                                                                                                        vRowsAffected,
//                                                                                                        BinaryEvent, Metadata,
//                                                                                                        BinaryCompatibleMode);
//            Except
//             On E : Exception Do
//              Begin
//               vMessageError := e.Message;
//               vError := True;
//              End;
//            End;
//            If vMessageError <> '' Then
//             Begin
//              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//             End;
//            DWParams.ItemsString['Error'].AsBoolean := vError;
//            If DWParams.ItemsString['RowsAffected'] <> Nil Then
//             DWParams.ItemsString['RowsAffected'].AsInteger := vRowsAffected;
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              vEncoded := DWParams.ItemsString['Result'].Encoded;
//              If (BinaryEvent) And (Not (vError)) Then
//               DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob)
//              Else If Not(vError) And (vTempJSON <> '') Then
//               DWParams.ItemsString['Result'].SetValue(vTempJSON, vEncoded)
//              Else
//               DWParams.ItemsString['Result'].SetValue('');
//             End;
//           End;
//          Break;
//         End;
//       End;
//     End;
//   End;
 Finally
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTDWQXBasePooler.GetEvents(Pooler,
                                             urlContext         : String;
                                             Var DWParams       : TDWParams);
Var
 I         : Integer;
 vError    : Boolean;
 vTempJSON : String;
 iContSE   : Integer;
Begin
 vTempJSON := '';
End;

Procedure TRESTDWQXBasePooler.GetFieldNames(Var Pooler         : String;
                                                 Var DWParams       : TDWParams;
                                                 hEncodeStrings     : Boolean;
                                                 AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vTableName,
 vMessageError : String;
 vStrings      : TStringList;
Begin
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
////           vStrings := TStringList.Create;
//           Try
//            DWParams.ItemsString['TableName'].CriptOptions.Use := False;
//            vTableName := DWParams.ItemsString['TableName'].AsString;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetFieldNames(vTableName, vStrings, vError, vMessageError);
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              DWParams.ItemsString['Result'].CriptOptions.Use := False;
//              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
//             End;
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           FreeAndNil(vStrings);
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean := vError;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
End;

Procedure TRESTDWQXBasePooler.GetKeyFieldNames(Var Pooler         : String;
                                                    Var DWParams       : TDWParams;
                                                    hEncodeStrings     : Boolean;
                                                    AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vTableName,
 vMessageError : String;
 vStrings      : TStringList;
Begin
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
////           vStrings := TStringList.Create;
//           Try
//            DWParams.ItemsString['TableName'].CriptOptions.Use := False;
//            vTableName := DWParams.ItemsString['TableName'].AsString;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetKeyFieldNames(vTableName, vStrings, vError, vMessageError);
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              DWParams.ItemsString['Result'].CriptOptions.Use := False;
//              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
//             End;
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           FreeAndNil(vStrings);
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean := vError;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
End;

Procedure TRESTDWQXBasePooler.GetPoolerList(Var PoolerList     : String;
                                                 AccessTag          : String);
Begin
End;

Procedure TRESTDWQXBasePooler.GetServerEventsList(Var ServerEventsList : String;
                                                       AccessTag            : String);
Begin

End;

Procedure TRESTDWQXBasePooler.GetTableNames(Var Pooler         : String;
                                                 Var DWParams       : TDWParams;
                                                 hEncodeStrings     : Boolean;
                                                 AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vStrings      : TStringList;
Begin
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
////           vStrings := TStringList.Create;
//           Try
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.GetTableNames(vStrings, vError, vMessageError);
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              DWParams.ItemsString['Result'].CriptOptions.Use := False;
//              DWParams.ItemsString['Result'].SetValue(vStrings.Text, DWParams.ItemsString['Result'].Encoded);
//             End;
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           FreeAndNil(vStrings);
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean := vError;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
End;

Procedure TRESTDWQXBasePooler.InsertMySQLReturnID(Var Pooler         : String;
                                                       Var DWParams       : TDWParams;
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
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           If DWParams.ItemsString['Params'] <> Nil Then
//            Begin
//             DWParamsD := TDWParams.Create;
//             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
//            End;
//           Try
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            If DWParamsD <> Nil Then
//             Begin
//              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
//                                                                                                            DWParamsD, vError, vMessageError);
//              DWParamsD.Free;
//             End
//            Else
//             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
//                                                                                                           vError,
//                                                                                                           vMessageError);
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean := vError;
//           If DWParams.ItemsString['Result'] <> Nil Then
//            Begin
//             If vTempJSON <> -1 Then
//              DWParams.ItemsString['Result'].SetValue(IntToStr(vTempJSON), DWParams.ItemsString['Result'].Encoded)
//             Else
//              DWParams.ItemsString['Result'].SetValue('-1');
//            End;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
End;

Procedure TRESTDWQXBasePooler.Loaded;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

//Procedure TRESTDWQXBasePooler.Notification(AComponent : TComponent;
//                                               Operation  : TOperation);
//Begin
// If (Operation = opRemove) then
//  Begin
//   {$IFNDEF FPC}
//    {$IF Defined(HAS_FMX)}
//     {$IFDEF MSWINDOWS}
//
//     {$ENDIF}
//    {$IFEND}
//   {$ENDIF}
////    if (AComponent = vRESTServiceNotification) then
////      vRESTServiceNotification := nil;
//  End;
// Inherited Notification(AComponent, Operation);
//End;

Procedure TRESTDWQXBasePooler.OnParseAuthentication(AContext       : TComponent;
                                                        Const AAuthType,
                                                        AAuthData      : String;
                                                        Var VUsername,
                                                        VPassword      : String;
                                                        Var VHandled   : Boolean);
Begin
End;

Procedure TRESTDWQXBasePooler.OpenDatasets(Var Pooler           : String;
                                                Var DWParams         : TDWParams;
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
 Try
//  If ServerMethodsClass <> Nil Then
//   Begin
//    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//     Begin
//      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//       Begin
//        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//         Begin
//          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//           Begin
//            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//             Begin
//              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//              DWParams.ItemsString['Error'].AsBoolean       := True;
//              Exit;
//             End;
//           End;
//          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//           Begin
//            vError   := DWParams.ItemsString['Error'].AsBoolean;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//            Try
////             DWParams.ItemsString['LinesDataset'].CriptOptions.Use := False;
//             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
//                                                                                                    vError, vMessageError, BinaryBlob);
//            Except
//             On E : Exception Do
//              Begin
//               vMessageError := e.Message;
//               vError := True;
//              End;
//            End;
//            If vMessageError <> '' Then
//             Begin
//              DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//              DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//             End;
//            DWParams.ItemsString['Error'].AsBoolean        := vError;
//            If DWParams.ItemsString['Result'] <> Nil Then
//             Begin
//              If BinaryRequest Then
//               Begin
//                If Not Assigned(BinaryBlob) Then
//                 BinaryBlob  := TMemoryStream.Create;
//                If Not vTempJSON.IsNull Then //vTempJSON <> Nil Then
//                 Begin
//                  vTempJSON.SaveToStream(BinaryBlob);
//                  DWParams.ItemsString['Result'].LoadFromStream(BinaryBlob);
//                  FreeAndNil(vTempJSON);
//                 End
//                Else
//                 DWParams.ItemsString['Result'].SetValue('');
//                FreeAndNil(BinaryBlob);
//               End
//              Else
//               Begin
//                If Not vTempJSON.IsNull Then //vTempJSON <> Nil Then
//                 DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON)
//                Else
//                 DWParams.ItemsString['Result'].SetValue('');
//               End;
//             End;
//           End;
//          Break;
//         End;
//       End;
//     End;
//   End;
 Finally
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
  If Assigned(BinaryBlob) Then
   FreeAndNil(BinaryBlob);
 End;
End;

Procedure TRESTDWQXBasePooler.ProcessMassiveSQLCache(Var Pooler              : String;
                                                          Var DWParams            : TDWParams;
                                                          hEncodeStrings          : Boolean;
                                                          AccessTag               : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
 vTempJSON     : TJSONValue;
Begin
// If ServerMethodsClass <> Nil Then
//  Begin
//   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
//    Begin
//     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
//      Begin
//       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
//        Begin
//         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
//          Begin
//           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
//            Begin
//             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
//             DWParams.ItemsString['Error'].AsBoolean       := True;
//             Exit;
//            End;
//          End;
//         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
//          Begin
//           vError   := DWParams.ItemsString['Error'].AsBoolean;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
//           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
//           Try
//            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
//            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ProcessMassiveSQLCache(DWParams.ItemsString['MassiveSQLCache'].AsString,
//                                                                                                   vError,  vMessageError);
//           Except
//            On E : Exception Do
//             Begin
//              vMessageError := e.Message;
//              vError := True;
//             End;
//           End;
//           If vMessageError <> '' Then
//            Begin
//             DWParams.ItemsString['MessageError'].CriptOptions.Use := False;
//             DWParams.ItemsString['MessageError'].AsString := EncodeStrings(vMessageError{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
//            End;
//           DWParams.ItemsString['Error'].AsBoolean        := vError;
//           If (DWParams.ItemsString['Result'] <> Nil) And Not(vError) Then
//            Begin
//             If vTempJSON <> Nil Then
//              Begin
//               DWParams.ItemsString['Result'].SetValue(vTempJSON.Value, DWParams.ItemsString['Result'].Encoded);
//               vTempJSON.Free;
//              End
//             Else
//              DWParams.ItemsString['Result'].SetValue('');
//            End;
//          End;
//         Break;
//        End;
//      End;
//    End;
//  End;
End;

Function TRESTDWQXBasePooler.ReturnEvent(Var BaseComponent : TRESTDWComponent) : Boolean;
Var
 vRejected,
 vTagService        : Boolean;
 vErrorMessage,
 vStrAcceptedRoutes : String;
 vDWRoutes: TDWRoutes;
Begin
 Result        := False;
 vRejected     := False;
 vTagService   := Result;
 vErrorMessage := '';
 Result   := True;
 If Trim(Self.AccessTag) <> '' Then
  Begin
   If AccessTag <> TRESTDWComponent(BaseComponent).AccessTag Then
    Begin
     If TRESTDWComponent(BaseComponent).DWParams.ItemsString['dwencodestrings'] <> Nil Then
      TRESTDWComponent(BaseComponent).ErrorMessage := EncodeStrings('Invalid Access tag...'{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
     Else
      TRESTDWComponent(BaseComponent).ErrorMessage := 'Invalid Access tag...';
     TRESTDWComponent(BaseComponent).StatusCode := 401;
     Result  := True;
    End;
  End;
 If (RequestTypeToRoute(TRESTDWComponent(BaseComponent).Method) In TRESTDWComponent(BaseComponent).DataRoute.Routes) Or
    (crAll in TRESTDWComponent(BaseComponent).DataRoute.Routes) Then
  Begin
   TRESTDWComponent(BaseComponent).ErrorMessage := '';
   If Assigned(TRESTDWComponent(BaseComponent).DataRoute.OnAuthRequest) Then
    TRESTDWComponent(BaseComponent).DataRoute.OnAuthRequest(BaseComponent, TRESTDWComponent(BaseComponent).InHeaders,
                                                            TRESTDWComponent(BaseComponent).DWParams, vRejected,
                                                            TRESTDWComponent(BaseComponent).ErrorMessage,
                                                            TRESTDWComponent(BaseComponent).StatusCode,
                                                            TRESTDWComponent(BaseComponent).OutHeaders);
   If Not vRejected Then
    Begin
     Try
      If Assigned(TRESTDWComponent(BaseComponent).DataRoute.vOnReplyRequestStream) Then
       TRESTDWComponent(BaseComponent).DataRoute.vOnReplyRequestStream(BaseComponent, TRESTDWComponent(BaseComponent).InHeaders,
                                                                       TRESTDWComponent(BaseComponent).DWParams,
                                                                       TRESTDWComponent(BaseComponent).OutContentType,
                                                                       TRESTDWComponent(BaseComponent).OutContentStream,
                                                                       TRESTDWComponent(BaseComponent).Method,
                                                                       TRESTDWComponent(BaseComponent).StatusCode,
                                                                       TRESTDWComponent(BaseComponent).ErrorMessage,
                                                                       TRESTDWComponent(BaseComponent).OutHeaders)
      Else If Assigned(TRESTDWComponent(BaseComponent).DataRoute.vOnReplyRequest) Then
       TRESTDWComponent(BaseComponent).DataRoute.vOnReplyRequest(BaseComponent, TRESTDWComponent(BaseComponent).InHeaders,
                                                                 TRESTDWComponent(BaseComponent).DWParams,
                                                                 TRESTDWComponent(BaseComponent).OutContentType,
                                                                 TRESTDWComponent(BaseComponent).OutContent,
                                                                 TRESTDWComponent(BaseComponent).Method,
                                                                 TRESTDWComponent(BaseComponent).StatusCode,
                                                                 TRESTDWComponent(BaseComponent).ErrorMessage,
                                                                 TRESTDWComponent(BaseComponent).OutHeaders);
     Except
      On E : Exception Do
       Begin
        If TRESTDWComponent(BaseComponent).DWParams.ItemsString['dwencodestrings'] <> Nil Then
         TRESTDWComponent(BaseComponent).ErrorMessage := EncodeStrings(e.Message{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
        Else
         TRESTDWComponent(BaseComponent).ErrorMessage := e.Message;
        If (TRESTDWComponent(BaseComponent).StatusCode <= 0)  Or
           (TRESTDWComponent(BaseComponent).StatusCode = 200) Then
        TRESTDWComponent(BaseComponent).StatusCode := 500;
        Result  := True;
       End;
     End;
    End
   Else
    Begin
     If TRESTDWComponent(BaseComponent).ErrorMessage <> '' Then
      TRESTDWComponent(BaseComponent).OutContentType := 'text/html'
     Else
      TRESTDWComponent(BaseComponent).ErrorMessage   := 'The Requested URL was Rejected';
     If (TRESTDWComponent(BaseComponent).StatusCode <= 0)  Or
        (TRESTDWComponent(BaseComponent).StatusCode = 200) Then
      TRESTDWComponent(BaseComponent).StatusCode     := 401;
    End;
   If (Trim(TRESTDWComponent(BaseComponent).ErrorMessage) = '')   And
      (TRESTDWComponent(BaseComponent).OutContent = '')           And
      (TRESTDWComponent(BaseComponent).OutContentStream.Size = 0) Then
    TRESTDWComponent(BaseComponent).ErrorMessage := TReplyOK;
  End
 Else
  Begin
   vStrAcceptedRoutes := '';
   vDWRoutes := TRESTDWComponent(BaseComponent).DataRoute.Routes;
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
     TRESTDWComponent(BaseComponent).ErrorMessage := 'Request rejected. Acceptable HTTP methods: '+vStrAcceptedRoutes;
     TRESTDWComponent(BaseComponent).StatusCode := 403;
    End
   Else
    Begin
     TRESTDWComponent(BaseComponent).ErrorMessage := 'Acceptable HTTP methods not defined on server';
     TRESTDWComponent(BaseComponent).StatusCode := 500;
    End;
  End;
End;

Function TRESTDWQXBasePooler.ServiceMethods(AContext                : TComponent;
                                            Var DWParams            : TDWParams;
                                            Var JSONStr             : String;
                                            Var JsonMode            : TJsonMode;
                                            Var ErrorCode           : Integer;
                                            Var ContentType         : String;
                                            Var ServerContextCall   : Boolean;
                                            Const ServerContextStream : TStream;
                                            hEncodeStrings          : Boolean;
                                            AccessTag               : String;
                                            WelcomeAccept           : Boolean;
                                            Const RequestType       : TRequestType;
                                            mark                    : String;
                                            RequestHeader           : TStringList;
                                            BinaryEvent,
                                            Metadata,
                                            BinaryCompatibleMode    : Boolean) : Boolean;
Var
 vJsonMSG,
 vResultIP,
 vUrlMethod   :  String;
 vError,
 vInvalidTag  : Boolean;
 JSONParam    : TJSONParam;
Begin
 Result       := False;
 vUrlMethod   := TRESTDWComponent(AContext).URL;
 If WelcomeAccept Then
  Begin
   If (vUrlMethod = UpperCase('GetPoolerList')) Then
    Begin
     Result     := True;
     GetPoolerList(TRESTDWComponent(AContext).OutContent, AccessTag);
     JSONParam                   := DWParams.ItemsString['Result'];
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End
     Else
      JSONParam.ObjectDirection := odOut;
     DWParams.ItemsString['Result'].SetValue(TRESTDWComponent(AContext).OutContent,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If (vUrlMethod = UpperCase('GetServerEventsList')) Then
    Begin
     Result     := True;
     GetServerEventsList(TRESTDWComponent(AContext).OutContent, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(TRESTDWComponent(AContext).OutContent,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If (vUrlMethod = UpperCase('EchoPooler')) And (TRESTDWComponent(AContext).URL = '') Then
    Begin
     vJsonMSG := TReplyNOK;
     If DWParams.ItemsString['Pooler'] <> Nil Then
      Begin
       TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
       EchoPooler(AContext, TRESTDWComponent(AContext).OutContent, vResultIP, AccessTag, vInvalidTag);
       JSONParam  := DWParams.ItemsString['Result'];
       If JSONParam <> Nil Then
        Begin
         JSONParam.ObjectDirection := odOut;
         JSONParam.SetValue(vResultIP, JSONParam.Encoded);
        End;
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
     TRESTDWComponent(AContext).OutContent  := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSON(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandPureJSONTB') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSONTB(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSON') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSON(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSONTB') Then
    Begin
     TRESTDWComponent(AContext).OutContent   := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSONTB(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag, BinaryEvent, Metadata, BinaryCompatibleMode);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSON(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdatesTB') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSONTB(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCache') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCache(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCacheTB') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCacheTB(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('ProcessMassiveSQLCache') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     ProcessMassiveSQLCache(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetTableNames') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     GetTableNames(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetFieldNames') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     GetFieldNames(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('GetKeyFieldNames') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     GetKeyFieldNames(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID_PARAMS') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID') Then
    Begin
     TRESTDWComponent(AContext).OutContent    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      JSONStr   := TReplyNOK;
    End
   Else If vUrlMethod = UpperCase('OpenDatasets') Then
    Begin
     TRESTDWComponent(AContext).OutContent     := DWParams.ItemsString['Pooler'].Value;
     OpenDatasets(TRESTDWComponent(AContext).OutContent, DWParams, hEncodeStrings, AccessTag, BinaryEvent);
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
     GetEvents(TRESTDWComponent(AContext).OutContent, TRESTDWComponent(AContext).URL, DWParams);
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
     If ReturnEvent(TRESTDWComponent(AContext)) Then
      Begin
       JSONStr := TRESTDWComponent(AContext).OutContent;
       Result  := (JSONStr <> '') Or (TRESTDWComponent(AContext).OutContentStream.Size > 0);
       vError  := (TRESTDWComponent(AContext).ErrorMessage <> '');
       If vError Then
        Begin
         JsonMode   := jmPureJSON;
         ErrorCode  := TRESTDWComponent(AContext).StatusCode;
         JSONStr    := TRESTDWComponent(AContext).ErrorMessage;
         Result     := False;
        End;
      End
     Else
      Begin
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
           JSONStr    := TRESTDWComponent(AContext).OutContent;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 404;
          End;
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
   GetEvents(TRESTDWComponent(AContext).OutContent, TRESTDWComponent(AContext).URL, DWParams);
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
     If ReturnEvent(TRESTDWComponent(AContext)) Then
      Begin
       JSONStr := TRESTDWComponent(AContext).OutContent;
       Result  := JSONStr <> '';
      End
     Else
      Begin
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
           JSONStr := TRESTDWComponent(AContext).ErrorMessage;
           If (ErrorCode <= 0) Or
              (ErrorCode = 200) Then
            ErrorCode  := 404;
           Result  := False;
          End;
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

Procedure TRESTDWQXBasePooler.SetClientInfo(ip,
                                            ipVersion,
                                            UserAgent,
                                            BaseRequest,
                                            Request      : String;
                                            port         : Integer);
Begin

End;

procedure TRESTDWQXBasePooler.SetClientWelcomeMessage(Value: String);
Begin
 vClientWelcomeMessage := Value;
End;

procedure TRESTDWQXBasePooler.SetCORSCustomHeader(Value: TStringList);
Var
 I : Integer;
Begin
 vCORSCustomHeaders.Clear;
 For I := 0 To Value.Count -1 do
  vCORSCustomHeaders.Add(Value[I]);
End;

Procedure TRESTDWQXBasePooler.SetDefaultPage(Value: TStringList);
Var
 I : Integer;
Begin
 vDefaultPage.Clear;
 For I := 0 To Value.Count -1 do
  vDefaultPage.Add(Value[I]);
End;

Constructor TRESTDWComponent.Create(AOwner: TComponent);
Begin
 Inherited;
 OutHeaders       := TStringList.Create;
 InHeaders        := TStringList.Create;
 DWParams         := TDWParams.Create;
 OutContentStream := TMemoryStream.Create;
 DataRoute        := Nil;
 InContentType    := '';
 OutContentType   := '';
 UserAgent        := '';
 Method           := rtGet;
 URL              := '';
 RemoteIP         := '';
 ConnectionID     := 0;
 StatusCode       := 200;
 ErrorMessage     := '';
 WelcomeAccept    := False;
 JsonMode         := jmPureJSON;
End;

Destructor TRESTDWComponent.Destroy;
Begin
 FreeAndNil(OutHeaders);
 FreeAndNil(InHeaders);
 FreeAndNil(DWParams);
 OutContentStream.Clear;
 FreeAndNil(OutContentStream);
 Inherited;
End;

{ TDWEventQX }

Destructor TRESTDWQXDataRoute.Destroy;
Begin

 Inherited;
End;

end.
