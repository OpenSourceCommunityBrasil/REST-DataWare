unit uRESTDWSynBase;

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

{$I uRESTDW.inc}

interface

Uses
 SysTypes, uDWDatamodule, uRESTDWPoolerDB, uDWJSONTools, uDWJSONObject, uRESTDWServerEvents, uRESTDWServerContext, ServerUtils,
 uDWConsts, uDWConstsData, uDWConstsCharset, uDWConst404HTML, uDWAbout, uSystemEvents, SynCommons, SynCrtSock, uRESTDWHTTPServer, uRESTDWAssets,
 {$IFDEF FPC}
  SysUtils,  Classes, mORMot, mORMotHttpServer, HTTPDefs, LConvEncoding;
 {$ELSE}
  mORMot, mORMotHttpServer,
  {$IFDEF MSWINDOWS}Windows, {$ENDIF}
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, EncdDecd, SyncObjs
  {$ELSE}
   System.SysUtils, System.Classes, system.SyncObjs,
   HTTPApp{$IF Defined(HAS_FMX)}, System.IOUtils{$IFEND}
  {$IFEND};
 {$ENDIF}

Type
 TOnCreate          = Procedure (Sender            : TObject)             Of Object;
 TLastRequest       = Procedure (Value             : String)              Of Object;
 TLastResponse      = Procedure (Value             : String)              Of Object;
 TBeforeUseCriptKey = Procedure (Request           : String;
                                 Var Key           : String)              Of Object;
 TOnBeforeExecute   = Procedure (ASender           : TObject)             Of Object;

Type
 TServerMethodClass = Class(TComponent)
End;

Type
 TRESTDWBodyType    = (bt_xwwwform_urlencoded, bt_multipartformdata, bt_multipartbyteranges,
                       bt_octetstream,         bt_urlparams,         bt_raw, bt_none);

Type
 TClassNull= Class(TComponent)
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
 TRESTDWServiceSynPooler = Class(TDWComponent)
 Protected
  Function  aCommandGet  (Ctxt       : THttpServerRequest) : Cardinal;
 Private
  Model                : TSQLModel;
  Server               : TSQLRestServer;
  fOnRequest           : TOnHttpServerRequest;
  HTTPServer           : TRESTDWHTTPServer;
  {$IFDEF FPC}
   vCriticalSection    : TRTLCriticalSection;
   vDatabaseCharSet    : TDatabaseCharSet;
  {$ENDIF}
  vBeforeUseCriptKey   : TBeforeUseCriptKey;
  vCORSCustomHeaders,
  vDefaultPage         : TStringList;
  vPathTraversalRaiseError,
  vMultiCORE,
  vForceWelcomeAccess,
  vUseSSL,
  vCORS,
  vActive              : Boolean;
  vProxyOptions        : TProxyOptions;
  vServiceTimeout,
  vServerThreadPoolCount,
  vServicePort         : Integer;
  vCripto              : TCripto;
  aServerMethod        : TComponentClass;
  vDataRouteList       : TRESTDWDataRouteList;
  vServerAuthOptions   : TRDWServerAuthOptionParams;
  vLastRequest         : TLastRequest;
  vLastResponse        : TLastResponse;
  vRootUser,
  vServerContext,
  FRootPath            : String;
  VEncondig            : TEncodeSelect;
  vOnCreate            : TOnCreate;
  Function  AddValue(cName, Value : String;
                     Separator   : String = ':') : String;
  Function  RemoveBackslashCommands  (Value                   : String) : String;
  Procedure SetServerContext         (Value                   : String);
  Procedure SetCORSCustomHeader      (Value                   : TStringList);
  Procedure SetDefaultPage           (Value                   : TStringList);
  Procedure SetActive                (Value                   : Boolean);
  Procedure SetServerMethod          (Value                   : TComponentClass);
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
                                      AContext                : THttpServerRequest;
                                      Var UriOptions          : TRESTDWUriOptions;
                                      Var DWParams            : TDWParams;
                                      Var JSONStr             : String;
                                      Var JsonMode            : TJsonMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType         : String;
                                      Var ServerContextCall   : Boolean;
                                      Const ServerContextStream : TStream;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      WelcomeAccept           : Boolean;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      BinaryEvent             : Boolean;
                                      Metadata                : Boolean;
                                      BinaryCompatibleMode    : Boolean) : Boolean;
  Procedure EchoPooler               (ServerMethodsClass      : TComponent;
                                      AContext                : THttpServerRequest;
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
                                      Const ServerContextStream : TStream;
                                      Var Error               : Boolean;
                                      Var   DWParams          : TDWParams;
                                      Const RequestType       : TRequestType;
                                      mark                    : String;
                                      RequestHeader           : TStringList;
                                      Var ErrorCode           : Integer) : Boolean;
  Procedure OnParseAuthentication    (AContext                : THttpServerRequest;
                                      Const AAuthType,
                                      AAuthData               : String;
                                      var VUsername,
                                      VPassword               : String; Var VHandled: Boolean);
  Procedure SetupRequest             (RequestHeader           : TStringlist;
                                      Var BodyType            : TRESTDWBodyType;
                                      Var Boundary            : SockString);
  Procedure ReadParams               (Source                  : TStringlist;
                                      Var InitPos             : Integer;
                                      Var ParamType           : TRESTDWBodyType;
                                      Var Paramname,
                                      ParamValue              : SockString;
                                      Boundary                : SockString);
  Procedure CreateStrings            (Source                  : SockString;
                                      Var Dest                : TStringlist;
                                      Boundary                : SockString);
 Public
  Procedure ClearDataRoute;
  Procedure AddDataRoute(DataRoute : String; MethodClass : TComponentClass);
  Constructor Create       (AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                      //Destroy a Classe
 Published
  Property Active                  : Boolean                    Read vActive                  Write SetActive;
  Property ServerThreadPoolCount   : Integer                    Read vServerThreadPoolCount   Write vServerThreadPoolCount;
  Property PathTraversalRaiseError : Boolean                    Read vPathTraversalRaiseError Write vPathTraversalRaiseError;
  Property CORS                    : Boolean                    Read vCORS                    Write vCORS;
  Property CORS_CustomHeaders      : TStringList                Read vCORSCustomHeaders       Write SetCORSCustomHeader;
  Property DefaultPage             : TStringList                Read vDefaultPage             Write SetDefaultPage;
  Property UseSSL                  : Boolean                    Read vUseSSL                  Write vUseSSL;
  Property RequestTimeout          : Integer                    Read vServiceTimeout          Write vServiceTimeout;
  Property ServicePort             : Integer                    Read vServicePort             Write vServicePort;  //A Porta do Serviço do DataSet
  Property ProxyOptions            : TProxyOptions              Read vProxyOptions            Write vProxyOptions; //Se tem Proxy diz quais as opções
  Property AuthenticationOptions   : TRDWServerAuthOptionParams Read vServerAuthOptions       Write vServerAuthOptions;
  Property ServerMethodClass       : TComponentClass            Read aServerMethod            Write SetServerMethod;
  Property OnLastRequest           : TLastRequest               Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse              Read vLastResponse            Write vLastResponse;
  Property Encoding                : TEncodeSelect              Read VEncondig                Write VEncondig;          //Encoding da string
  Property ServerContext           : String                     Read vServerContext           Write SetServerContext;
  Property RootPath                : String                     Read FRootPath                Write FRootPath;
  Property RootUser                : String                     Read vRootUser                Write vRootUser;
  Property ForceWelcomeAccess      : Boolean                    Read vForceWelcomeAccess      Write vForceWelcomeAccess;
  Property OnBeforeUseCriptKey     : TBeforeUseCriptKey         Read vBeforeUseCriptKey       Write vBeforeUseCriptKey;
  Property CriptOptions            : TCripto                    Read vCripto                  Write vCripto;
  Property MultiCORE               : Boolean                    Read vMultiCORE               Write vMultiCORE;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet           Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
  Property OnCreate                : TOnCreate                  Read vOnCreate                Write vOnCreate;
End;

Function GetEventNameX  (Value  : String)    : String;
Function GetTokenString (Value  : String)    : String;
Function GetBearerString(Value  : String)    : String;
Function GetParamsReturn(Params : TDWParams) : String;

implementation

Constructor TRESTDWDataRoute.Create;
Begin
 vDataRoute         := '';
 vServerMethodClass := TClassNull;
End;

Function GetBodyType(ContentType : String) : TRESTDWBodyType;
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

Function TRESTDWDataRouteList.Add(Item: TRESTDWDataRoute): Integer;
Var
 vItem : PRESTDWDataRoute;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
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

Destructor TRESTDWDataRouteList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TRESTDWDataRouteList.GetRec(Index: Integer): TRESTDWDataRoute;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWDataRoute(TList(Self).Items[Index]^);
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

Procedure TRESTDWDataRouteList.PutRec(Index: Integer; Item: TRESTDWDataRoute);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWDataRoute(TList(Self).Items[Index]^) := Item;
End;

Function TRESTDWDataRouteList.RouteExists(Value: String): Boolean;
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

Procedure TRESTDWServiceSynPooler.SetupRequest(RequestHeader : TStringlist;
                                               Var BodyType  : TRESTDWBodyType;
                                               Var Boundary  : SockString);
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
     If Pos(';', vLine) > 0 Then
      Begin
       BodyType := GetBodyType(Copy(vLine, 1, Pos(';', vLine) -1));
       Delete(vLine, 1, Pos(';', vLine));
       A        := Pos('=', vLine) + 1;
       Boundary := Copy(vLine, A, Length(vLine) - A);
       A        := Pos(';', Boundary);
       If A > 0 Then
        Boundary  := Copy(Boundary, 1, A -1);
       Break;
      End
     Else
      Begin
       BodyType := GetBodyType(vLine);
       vLine    := '';
      End;
    End;
  End;
End;

Procedure TRESTDWServiceSynPooler.CreateStrings(Source      : SockString;
                                                Var Dest    : TStringlist;
                                                Boundary    : SockString);
Const
 cContentTransferEncoding = 'content-transfer-encoding:';
Var
 vline,
 vTempline,
 vTempline2 : String;
 vFlagPos   : Integer;
 vOnbynary  : Boolean;
 bSource    : SockString;
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
     If vTempline <> '' Then
      Dest.Add(vTempline);
    End;
  End;
 If Trim(vLine) <> '' then
  Dest.Add(vLine);
End;

Procedure TRESTDWServiceSynPooler.ReadParams(Source         : TStringlist;
                                             Var InitPos    : Integer;
                                             Var ParamType  : TRESTDWBodyType;
                                             Var Paramname,
                                             ParamValue     : SockString;
                                             Boundary       : SockString);
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
 vInitBoundary := (X <= 1);
 While X <= Source.Count -1 Do
  Begin
   vTempLine := Source[X];
   If (Not (vInitBoundary)) Then
    Begin
     vInitBoundary := Pos(Boundary, vTempLine) > 0;
     If Not (vInitBoundary) Then
      Begin
       If X > 0 Then
        Begin
         vTempLine := Source[X -1];
         vInitBoundary := Pos(Boundary, vTempLine) > 0;
         If Not(vInitBoundary) Then
          vTempLine := Source[X]
         Else
          Dec(X);
        End;
      End;
    End
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
         If (Pos(Boundary, vTempLine) = 0) Then
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

Function TRESTDWServiceSynPooler.RemoveBackslashCommands(Value : String) : String;
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

Function  TRESTDWServiceSynPooler.AddValue(cName, Value : String;
                                           Separator   : String = ':') : String;
Begin
 //Example: cName = Access-Control-Allow-Methods   Value = GET, POST, PATCH, PUT, DELETE, OPTIONS
 Result := Format('%s%s%s', [cName, Separator, Value]);
End;

Function  TRESTDWServiceSynPooler.aCommandGet(Ctxt: THttpServerRequest) : Cardinal;
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
 vErrorMessage,
 aToken,
 vToken,
 vDataBuff,
 vCORSOption,
 vAuthenticationString,
 vAuthUsername,
 vAuthPassword,
 sCharSet            : String;
 vBoundary,
 tmp, tmpvalue       : SockString;
 vAuthTokenParam     : TRDWAuthTokenParam;
 vdwConnectionDefs   : TConnectionDefs;
 vTempServerMethods  : TObject;
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
 vServerBaseMethod   : TComponentClass;
 vServerMethod       : TComponentClass;
 vUriOptions         : TRESTDWUriOptions;
 ServerContextStream,
 mb,
 mb2,
 ms                  : TStringStream;
 BodyType            : TRESTDWBodyType;
 RequestType         : TRequestType;
 vRequestHeader,
 vRequestContent,
 vDecoderHeaderList  : TStringList;
 vTempContext        : TDWContext;
 vTempEvent          : TDWEvent;
 vRDWAuthOptionParam : TRDWAuthOptionParam;
 vNewParam           : Boolean;
 {$IFNDEF FPC}
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
 begin
  If (Ctxt.InHeaders) = '' Then
   Exit;
  Try
   If Ctxt.InHeaders <> '' Then
    Begin
     vRequestHeader.NameValueSeparator := ':';
     vRequestHeader.Text := Ctxt.InHeaders;
     For I := 0 To vRequestHeader.Count -1 Do
      Begin
       tmp := vRequestHeader.Names[I];
       If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
        vWelcomeMessage := DecodeStrings(vRequestHeader.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
        vAccessTag := DecodeStrings(vRequestHeader.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('datacompression', lowercase(tmp)) > 0 Then
        compresseddata := StringToBoolean(vRequestHeader.Values[tmp])
       Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
        encodestrings  := StringToBoolean(vRequestHeader.Values[tmp])
       Else If pos('dwusecript', lowercase(tmp)) > 0 Then
        vdwCriptKey    := StringToBoolean(vRequestHeader.Values[tmp])
       Else If (pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
        dwassyncexec   := StringToBoolean(vRequestHeader.Values[tmp])
       Else if pos('binaryrequest', lowercase(tmp)) > 0 Then
        vBinaryEvent   := StringToBoolean(vRequestHeader.Values[tmp])
       Else If pos('binarycompatiblemode', lowercase(tmp)) > 0 Then
        vBinaryCompatibleMode := StringToBoolean(vRequestHeader.Values[tmp])
       Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
        Begin
         vdwConnectionDefs   := TConnectionDefs.Create;
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := VEncondig;
          JSONValue.Encoded  := True;
          JSONValue.LoadFromJSON(vRequestHeader.Values[tmp]);
          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
         Finally
          FreeAndNil(JSONValue);
         End;
        End
       Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
        Begin
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := VEncondig;
          JSONValue.Encoded  := True;
          {$IFDEF FPC}
          JSONValue.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONValue.LoadFromJSON(vRequestHeader.Values[tmp]);
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
          TServerUtils.ParseRESTURL(Ctxt.URL, VEncondig, vUriOptions, vmark, {$IFDEF FPC}vDatabaseCharSet,{$ENDIF} DWParams, aParamsCount);
         try
          JSONParam                 := TJSONParam.Create(DWParams.Encoding);
          JSONParam.ObjectDirection := odIN;
          JSONParam.ParamName       := lowercase(tmp);
          {$IFDEF FPC}
          JSONParam.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          If (tmpvalue <> '') Or (tmp <> '') Then
           Begin
            If (Trim(tmpvalue) = '') And (tmp <> '') Then
             tmpvalue                := Trim(StringReplace(vRequestHeader[I], tmp + ':', '', [rfReplaceAll]));
            tmp                      := tmpvalue;
           End
          Else
           Begin
            tmp                     := vRequestHeader[I];
            If Trim(tmp) = '' Then
             Begin
              FreeAndNil(JSONParam);
              Continue;
             End;
           End;
          If (Pos(LowerCase('{"ObjectType":"toParam", "Direction":"'), LowerCase(tmp)) > 0) Then
           JSONParam.FromJSON(tmp)
          Else
           JSONParam.AsString  := tmp;
          tmp      := '';
          tmpvalue := '';
          DWParams.Add(JSONParam);
         finally
         end;
        End;
      End;
    End;
  Finally
   tmp := '';
  End;
 end;
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
 Procedure WriteError(Title, Body, Footer : String);Overload;
 Begin
  Result  := vErrorCode;
  mb                                   := TStringStream.Create(vErrorMessage);
  mb.Position                          := 0;
  Ctxt.OutCustomHeaders                := mb.DataString;
  Ctxt.OutContent                      := Get404Error(Title, Body, Footer);
  FreeAndNil(mb);
 End;
 Procedure WriteError(AuthMessage, Value : String);Overload;
 Begin
  mb                                    := Nil;
  Result  := vErrorCode;
  If AuthMessage <> '' Then
   Begin
    vErrorMessage := AuthMessage;
    mb                                 := TStringStream.Create(vErrorMessage);
    mb.Position                        := 0;
    Ctxt.OutCustomHeaders              := mb.DataString;
   End;
  Ctxt.OutContent                      := Value;
  If AuthMessage <> '' Then
   FreeAndNil(mb);
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
 vRDWAuthOptionParam := Nil;
 vIPVersion         := 'ipv4';
 JsonMode           := jmDataware;
 baseEventUnit      := '';
 vAccessTag         := '';
 vErrorMessage      := '';
 aParamsCount       := cParamsCount;
 vUriOptions        := TRESTDWUriOptions.Create;
 {$IFNDEF FPC}
 vCriticalSection   := Nil;
 {$ENDIF}
 {$IF Defined(ANDROID) Or Defined(IOS)}
 vBasePath          := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, '/');
 {$ELSE}
 vBasePath          := ExtractFilePath(ParamStr(0));
 {$IFEND}
 vContentType          := vContentType;
 vRequestContent       := Nil;
 vdwConnectionDefs     := Nil;
 vTempServerMethods    := Nil;
 DWParams              := Nil;
 ServerContextStream   := Nil;
 mb                    := Nil;
 mb2                   := Nil;
 ms                    := Nil;
 vAuthTokenParam       := Nil;
 vServerMethod         := Nil;
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
 vCmd                  := '';
 vRequestHeader        := TStringList.Create;
 Result                := vErrorCode;
 Cmd                   := RemoveBackslashCommands(Trim(Ctxt.Method + ' ' + Ctxt.URL));
 If (vPathTraversalRaiseError) And (TravertalPathFind(Trim(Cmd))) Then
  Begin
   Ctxt.OutContentType := 'application/json';
   Try
    Ctxt.OutContent     := escape_chars(cEventNotFound);
    vErrorCode          := 404;
    Result              := vErrorCode;
    Exit;
   Finally
    DestroyComponents;
   End;
  End;
 BodyType              := bt_none;
 ReadRawHeaders;
 Try
  If vCORS Then
   Begin
    If vCORSCustomHeaders.Count > 0 Then
     Begin
      //Incluímos um ENTER, para evitar que tudo seja concatenado dentro de VARY
      For I := 0 To vCORSCustomHeaders.Count -1 Do
       Ctxt.OutCustomHeaders := Ctxt.OutCustomHeaders + #13#10 + AddValue(vCORSCustomHeaders.Names[I], vCORSCustomHeaders.ValueFromIndex[I]);
     End
    Else
     Ctxt.OutCustomHeaders := Ctxt.OutCustomHeaders + #13#10 + AddValue('Access-Control-Allow-Origin','*');
   End;
   sCharSet := '';
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET')    Then
   Begin
    vCmd := RemoveBackslashCommands(Ctxt.URL);
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
       Ctxt.OutContent := SockString(mb.DataString);
      Finally
       FreeAndNil(mb);
      End;
      Exit;
     End;
   End;
  vCORSOption := '';
  If vRequestHeader.IndexOf('OPTIONS') = 1 Then
   vCORSOption := vRequestHeader.Values['OPTIONS'];
  If (UpperCase(Ctxt.Method) = 'GET' )   OR
     (UpperCase(Ctxt.Method) = 'POST')   OR
     (UpperCase(Ctxt.Method) = 'PUT')    OR
     (UpperCase(Ctxt.Method) = 'DELETE')   OR
     (UpperCase(Ctxt.Method) = 'PATCH')   Then
   Begin
    RequestType := rtGet;
    If (UpperCase(Ctxt.Method)      = 'POST') Then
     RequestType := rtPost
    Else If (UpperCase(Ctxt.Method) = 'PUT')  Then
     RequestType := rtPut
    Else If (UpperCase(Ctxt.Method) = 'DELETE') Then
     RequestType := rtDelete
    Else If (UpperCase(Ctxt.Method) = 'PATCH') Then
     RequestType := rtPatch;
    If RemoveBackslashCommands(Cmd) = '/favicon.ico' Then
     Exit;
   End;
  vRequestContent := TStringlist.Create;
  vRequestContent.NameValueSeparator := ':';
  vBoundary := '';
  SetupRequest(vRequestHeader, BodyType, vBoundary);
  CreateStrings(Ctxt.InContent, vRequestContent, vBoundary);
  If BodyType = bt_none Then
   BodyType := bt_raw;
  vRequestContent.NameValueSeparator := '=';
  If ((vRequestHeader.Count > 0) And (RequestType In [rtGet, rtDelete])) Then
   Begin
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
    aurlContext := vUriOptions.ServerEvent;
    aParamsCount := cParamsCount;
    If ServerContext <> '' Then
     Inc(aParamsCount);
    If vDataRouteList.Count > 0 Then
     Inc(aParamsCount);
    vOldMethod := vUriOptions.EventName;
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
       vBinaryCompatibleMode := StringToBoolean(DWParams.ItemsString['BinaryCompatibleMode'].AsString);
     End;
    If (vUriOptions.ServerEvent = '') And (aurlContext <> '') Then
     vUriOptions.ServerEvent := aurlContext;
    I := 0;
    If vRequestContent.Count > 0 Then
    While I <= vRequestContent.Count -1 Do
     Begin
      tmp := vRequestContent.Names[I];
      If tmp <> '' Then
       Begin
        tmpvalue := '';
        If lowercase(tmp) = TFormdataParamName Then
         ReadParams(vRequestContent, I, BodyType, tmp, tmpvalue, vBoundary)
        Else
         Begin
          If tmp = '' Then
           ReadParams(vRequestContent, I, BodyType, tmp, tmpvalue, vBoundary)
          Else
           tmpvalue := vRequestContent.Values[tmp];
         End;
       End
      Else
       tmpvalue := vRequestContent[I];
      If (Lowercase(tmp) = 'binarydata') And
         (BodyType =  bt_octetstream)    Then
       Begin
        {$IFDEF FPC}
         ms := TStringStream.Create('');
        {$ELSE}
         ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
        {$ENDIF}
        {$IFNDEF FPC}
         {$if CompilerVersion < 24}
          ms.Write(Pointer(tmpvalue)^, Length(tmpvalue));
         {$ELSE}
          ms.WriteData(tbytes(tmpvalue), Length(tmpvalue));
         {$IFEND}
        {$ELSE}
         ms.Write(tbytes(tmpvalue), Length(tmpvalue));
        {$ENDIF}
        ms.Position := 0;
        DWParams.LoadFromStream(ms);
        FreeAndNil(ms);
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
         vBinaryCompatibleMode := StringToBoolean(DWParams.ItemsString['BinaryCompatibleMode'].AsString);
        Inc(I);
        Continue;
       End;
      If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
       vWelcomeMessage := DecodeStrings(tmpvalue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
      Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
       vAccessTag := DecodeStrings(tmpvalue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
      Else If pos('datacompression', lowercase(tmp)) > 0 Then
       compresseddata := StringToBoolean(tmpvalue)
      Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
       encodestrings  := StringToBoolean(tmpvalue)
      Else If pos('dwusecript', lowercase(tmp)) > 0 Then
       vdwCriptKey    := StringToBoolean(tmpvalue)
      Else If (pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
       dwassyncexec   := StringToBoolean(tmpvalue)
      Else if pos('binaryrequest', lowercase(tmp)) > 0 Then
       vBinaryEvent   := StringToBoolean(tmpvalue)
      Else If pos('binarycompatiblemode', lowercase(tmp)) > 0 Then
       vBinaryCompatibleMode := StringToBoolean(tmpvalue)
      Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
       Begin
        vdwConnectionDefs   := TConnectionDefs.Create;
        JSONValue           := TJSONValue.Create;
        Try
         JSONValue.Encoding  := VEncondig;
         JSONValue.Encoded  := True;
         JSONValue.LoadFromJSON(tmpvalue);
         vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
        Finally
         FreeAndNil(JSONValue);
        End;
       End
      Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
       Begin
        JSONValue           := TJSONValue.Create;
        Try
         JSONValue.Encoding  := VEncondig;
         JSONValue.Encoded  := True;
         {$IFDEF FPC}
         JSONValue.DatabaseCharSet := vDatabaseCharSet;
         {$ENDIF}
         JSONValue.LoadFromJSON(tmpvalue);
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
         TServerUtils.ParseRESTURL(Ctxt.URL, VEncondig,
                                   vUriOptions, vmark, {$IFDEF FPC}vDatabaseCharSet,{$ENDIF} DWParams, aParamsCount);
        try
         vNewParam                 := False;
         If Trim(tmp) = '' Then
          tmp := 'undefined';
         JSONParam                 := DWParams.ItemsString[tmp];
         If JSONParam = Nil Then
          Begin
           JSONParam               := TJSONParam.Create(DWParams.Encoding);
           vNewParam               := True;
          End;
         JSONParam.ObjectDirection := odIN;
         JSONParam.ParamName       := lowercase(tmp);
         {$IFDEF FPC}
         JSONParam.DatabaseCharSet := vDatabaseCharSet;
         {$ENDIF}
         If (tmpvalue <> '') Or (tmp <> '') Then
          tmp                      := tmpvalue
         Else
          Begin
           tmp                     := vRequestContent[I];
           If Trim(tmp) = '' Then
            Begin
             If vNewParam Then
              Begin
               vNewParam           := False;
               FreeAndNil(JSONParam);
              End;
             Inc(I);
             Continue;
            End;
          End;
         If (Pos(LowerCase('{"ObjectType":"toParam", "Direction":"'), LowerCase(tmp)) > 0) Then
          JSONParam.FromJSON(tmp)
         Else
          JSONParam.AsString  := tmp;
         If vNewParam Then
          DWParams.Add(JSONParam);
        Finally
        End;
       End;
      Inc(I);
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
     vUriOptions.BaseServer := vUriOptions.ServerEvent;
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
       {$IFDEF FPC}
        InitCriticalSection(vCriticalSection);
        EnterCriticalSection(vCriticalSection);
       {$ENDIF}
       vTempServerMethods  := vServerMethod.Create(Nil);
      Finally
       {$IFDEF FPC}
        Try
         LeaveCriticalSection(vCriticalSection);
         DoneCriticalSection(vCriticalSection);
        Except
        End;
       {$ENDIF}
      End;
      If (vTempServerMethods.ClassType = TServerMethodDatamodule)             Or
         (vTempServerMethods.ClassType.InheritsFrom(TServerMethodDatamodule)) Then
       Begin
        vServerAuthOptions.CopyServerAuthParams(vRDWAuthOptionParam);
        TServerMethodDatamodule(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
        vIPVersion := 'undefined';
        TServerMethodDatamodule(vTempServerMethods).SetClientInfo(Ctxt.RemoteIP, vIPVersion,
                                                                  vRequestHeader.Values['User-Agent'], vUriOptions.EventName,
                                                                  vUriOptions.ServerEvent, Ctxt.RequestID);
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
                            vAuthenticationString := vRequestHeader.Values['Authorization']; //ARequestInfo.Authentication.Authentication;// RawHeaders.Values['Authorization'];
                            PrepareBasicAuth(vAuthenticationString, vAuthUsername, vAuthPassword);
                            If Assigned(TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth) Then
                             Begin
                              TServerMethodDatamodule(vTempServerMethods).OnUserBasicAuth(vWelcomeMessage, vAccessTag,
                                                                                          vAuthUsername,
                                                                                          vAuthPassword,
                                                                                          DWParams, vErrorCode, vErrorMessage, vAcceptAuth);
                              If Not vAcceptAuth Then
                               Begin
                                vErrorCode    := 401;
                                Result        := vErrorCode;
                                If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).AuthDialog Then
                                 Begin
                                  vErrorMessage := Format(AuthRealm, ['Basic', TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, '']);
                                  If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                   WriteError(vErrorMessage, TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                              vErrorCode    := 401;
                              Result        := vErrorCode;
                              If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).AuthDialog Then
                               Begin
                                vErrorMessage := Format(AuthRealm, ['Basic', TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, '']);
                                If TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError(vErrorMessage, TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                              If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                               Begin
                                vTokenValidate := True;
                                vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
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
                                  Result        := vErrorCode;
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                   Begin
                                    vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                    If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                     WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                  DestroyComponents;
                                  Exit;
                                 End;
                               End
                              Else
                               Begin
                                Result        := vErrorCode;
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                 Begin
                                  vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                   WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                DestroyComponents;
                                Exit;
                               End;
                             End
                            Else
                             Begin
                              Result          := vErrorCode;
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                               Begin
                                vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                vToken       := vRequestHeader.Values['Authorization'];
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
                                Result        := vErrorCode;
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                 Begin
                                  vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                   WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                  Result        := vErrorCode;
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                   Begin
                                    vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                    If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                     WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                              If Assigned(TServerMethodDatamodule(vTempServerMethods).OnGetToken) Then
                               Begin
                                vTokenValidate := True;
                                vAuthTokenParam := TRDWAuthOptionTokenServer.Create;
                                vAuthTokenParam.Assign(TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams));
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
                                  Result        := vErrorCode;
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                   Begin
                                    vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                    If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                     WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                  DestroyComponents;
                                  Exit;
                                 End;
                               End
                              Else
                               Begin
                                Result        := vErrorCode;
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                 Begin
                                  vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                   WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                DestroyComponents;
                                Exit;
                               End;
                             End
                            Else
                             Begin
                              Result        := vErrorCode;
                              If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                               Begin
                                vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                 WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                vToken       := vRequestHeader.Values['Authorization'];
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
                                Result        := vErrorCode;
                                If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                 Begin
                                  vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                   WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
                                  Result        := vErrorCode;
                                  If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).AuthDialog Then
                                   Begin
                                    vErrorMessage := Format(AuthRealm, ['Digest', TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomDialogAuthMessage, 'auth-style=modal, ']);
                                    If TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text <> '' Then
                                     WriteError(vErrorMessage, TRDWAuthOptionTokenServer(vServerAuthOptions.OptionParams).CustomAuthErrorPage.Text) //cInvalidAuth,
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
  If Assigned(vLastRequest) Then
   Begin
    If Not vMultiCORE Then
     Begin
      {$IFNDEF FPC}
       {$IF CompilerVersion > 21}
        {$IFDEF WINDOWS}
         if Not Assigned(vCriticalSection) Then
          vCriticalSection := TCriticalSection.Create;
         InitializeCriticalSection(vCriticalSection);
         EnterCriticalSection(vCriticalSection);
        {$ELSE}
         if Not Assigned(vCriticalSection) Then
          vCriticalSection := TCriticalSection.Create;
         vCriticalSection.Acquire;
        {$ENDIF}
       {$ELSE}
       if Not Assigned(vCriticalSection) Then
        vCriticalSection := TCriticalSection.Create;
       vCriticalSection.Acquire;
       {$IFEND}
      {$ELSE}
       InitCriticalSection(vCriticalSection);
       EnterCriticalSection(vCriticalSection);
      {$ENDIF}
     End;
    Try
     If Assigned(vLastRequest) Then
      vLastRequest(vRequestHeader.Values['User-Agent'] + sLineBreak + Ctxt.URL);
    Finally
    If Not vMultiCORE Then
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
           FreeAndNil(vCriticalSection);
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
    End;
   End;
  If Assigned(vServerMethod) Then
   Begin
    vSpecialServer := False;
    If vTempServerMethods <> Nil Then
     Begin
      Ctxt.OutContentType := 'application/json';
      If (vUriOptions.EventName = '') And (vUriOptions.ServerEvent = '') Then
       Begin
        If vDefaultPage.Count > 0 Then
         vReplyString  := vDefaultPage.Text
        Else
         vReplyString  := TServerStatusHTML;
        vErrorCode   := 200;
        Ctxt.OutContentType := 'text/html';
       End
      Else
       Begin
//        If VEncondig = esUtf8 Then
//         Ctxt.OutContentType := Ctxt.OutContentType + ';utf-8'
//        Else
//         Ctxt.OutContentType := Ctxt.OutContentType + ';ansi';
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
          Ctxt.OutContent                      := SockString(mb.DataString);
          FreeAndNil(mb);
          //TODO AssyncRequest
         End;
        If DWParams.itemsstring['MetadataRequest']      <> Nil Then
         vMetadata := DWParams.itemsstring['MetadataRequest'].AsBoolean;
        If (Assigned(DWParams)) And (Assigned(vCripto))        Then
         DWParams.SetCriptOptions(vdwCriptKey, vCripto.Key);
        If (Not (vGettoken)) And (Not (vTokenValidate)) Then
         Begin
          ServerContextStream := TStringStream.Create('');
          If Not ServiceMethods(TComponent(vTempServerMethods), Ctxt, vUriOptions, DWParams,
                                JSONStr, JsonMode, vErrorCode,  vContentType, vServerContextCall, ServerContextStream,
                                vdwConnectionDefs,  EncodeStrings, vAccessTag, WelcomeAccept, RequestType, vMark,
                                vRequestHeader, vBinaryEvent, vMetadata, vBinaryCompatibleMode) Or (lowercase(vContentType) = 'application/php') Then
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
                   Ctxt.OutContent := SockString(mb.DataString);
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
          JSONStr    := vToken;
          JsonMode   := jmPureJSON;
          vErrorCode := 200;
         End;
       End;
     End;
   End;
  If Assigned(vRequestHeader) Then
   Begin
    vRequestHeader.Clear;
    FreeAndNil(vRequestHeader);
   End;
  If Assigned(vServerMethod) Then
   Begin
    If Assigned(vTempServerMethods) Then
     Begin
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
        Result := vErrorCode;
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
          If vErrorCode <> 200 Then
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
       End
      Else
       Begin
        LocalDoc := '';
        If Not vSpecialServer Then
         Begin
          Result             := vErrorCode;
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
   Begin
    If Not vMultiCORE Then
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
    Try
     vLastResponse(vReplyString);
    Finally
     If Not vMultiCORE Then
      Begin
       {$IFNDEF FPC}
        {$IF CompilerVersion > 21}
         {$IFDEF WINDOWS}
          LeaveCriticalSection(vCriticalSection);
          DeleteCriticalSection(vCriticalSection);
         {$ELSE}
          vCriticalSection.Release;
          FreeAndNil(vCriticalSection);
         {$ENDIF}
        {$ELSE}
          vCriticalSection.Release;
          FreeAndNil(vCriticalSection);
        {$IFEND}
       {$ELSE}
        LeaveCriticalSection(vCriticalSection);
        DoneCriticalSection(vCriticalSection);
       {$ENDIF}
      End;
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
  DestroyComponents;
  If Assigned(vdwConnectionDefs) Then
   FreeAndNil(vdwConnectionDefs);
  If Assigned(vTempServerMethods) Then
   FreeAndNil(vTempServerMethods);
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
  If Assigned(vRequestContent) Then
   FreeAndNil(vRequestContent);
  Result := vErrorCode;
 End;
End;

Procedure TRESTDWServiceSynPooler.AddDataRoute(DataRoute   : String;
                                               MethodClass : TComponentClass);
Var
 vDataRoute : TRESTDWDataRoute;
Begin
 vDataRoute                   := TRESTDWDataRoute.Create;
 vDataRoute.DataRoute         := DataRoute;
 vDataRoute.ServerMethodClass := MethodClass;
 vDataRouteList.Add(vDataRoute);
End;

Procedure TRESTDWServiceSynPooler.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
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
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWServiceSynPooler.ApplyUpdatesJSONTB(ServerMethodsClass : TComponent;
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
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWServiceSynPooler.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
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
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWServiceSynPooler.ApplyUpdates_MassiveCacheTB(ServerMethodsClass : TComponent;
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
 If Not(vError) Then
  If Assigned(vTempJSON) Then
   FreeAndNil(vTempJSON);
End;

Procedure TRESTDWServiceSynPooler.ClearDataRoute;
Begin
 vDataRouteList.ClearList;
End;

Constructor TRESTDWServiceSynPooler.Create(AOwner: TComponent);
Begin
 Inherited;
 vUseSSL := False;
 vProxyOptions                   := TProxyOptions.Create;
 vDefaultPage                    := TStringList.Create;
 vCORSCustomHeaders              := TStringList.Create;
 vDataRouteList                  := TRESTDWDataRouteList.Create;
 vCORSCustomHeaders.Add('Access-Control-Allow-Origin=*');
 vCORSCustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
 vCORSCustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
 vCripto                         := TCripto.Create;
 HTTPServer                      := Nil;
 vServerAuthOptions              := TRDWServerAuthOptionParams.Create(Self);
 vActive                         := False;
 vServerAuthOptions.AuthorizationOption                        := rdwAOBasic;
 TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Username := 'testserver';
 TRDWAuthOptionBasic(vServerAuthOptions.OptionParams).Password := 'testserver';
 vServerContext                  := '';
 VEncondig                       := esUtf8;
 vServicePort                    := 8082;
 vServerThreadPoolCount          := 32;
 vForceWelcomeAccess             := False;
 vCORS                           := False;
 vMultiCORE                      := False;
 vPathTraversalRaiseError        := True;
 FRootPath                       := '/';
 vRootUser                       := 'root';
 vServiceTimeout                 := -1;
End;

Destructor TRESTDWServiceSynPooler.Destroy;
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
// If Assigned(HTTPServer) Then
//  FreeAndNil(HTTPServer);
 Inherited;
End;

procedure TRESTDWServiceSynPooler.EchoPooler(ServerMethodsClass : TComponent;
                                             AContext           : THttpServerRequest;
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
          Begin
           MyIP := AContext.RemoteIP;
           If MyIP = '' Then
            MyIP := '127.0.0.1';
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTDWServiceSynPooler.ExecuteCommandJSON(ServerMethodsClass   : TComponent;
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

Procedure TRESTDWServiceSynPooler.ExecuteCommandJSONTB(ServerMethodsClass   : TComponent;
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

Procedure TRESTDWServiceSynPooler.ExecuteCommandPureJSON(ServerMethodsClass   : TComponent;
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


Procedure TRESTDWServiceSynPooler.ExecuteCommandPureJSONTB(ServerMethodsClass   : TComponent;
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

Procedure TRESTDWServiceSynPooler.GetEvents(ServerMethodsClass : TComponent;
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

Procedure TRESTDWServiceSynPooler.GetFieldNames(ServerMethodsClass : TComponent;
                                                Var Pooler         : String;
                                                Var DWParams       : TDWParams;
                                                ConnectionDefs     : TConnectionDefs;
                                                hEncodeStrings     : Boolean;
                                                AccessTag          : String);
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

Procedure TRESTDWServiceSynPooler.GetKeyFieldNames(ServerMethodsClass : TComponent;
                                                   Var Pooler         : String;
                                                   Var DWParams       : TDWParams;
                                                   ConnectionDefs     : TConnectionDefs;
                                                   hEncodeStrings     : Boolean;
                                                   AccessTag          : String);
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

Procedure TRESTDWServiceSynPooler.GetPoolerList(ServerMethodsClass : TComponent;
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

Procedure TRESTDWServiceSynPooler.GetServerEventsList(ServerMethodsClass   : TComponent;
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

Procedure TRESTDWServiceSynPooler.GetTableNames(ServerMethodsClass : TComponent;
                                                Var Pooler         : String;
                                                Var DWParams       : TDWParams;
                                                ConnectionDefs     : TConnectionDefs;
                                                hEncodeStrings     : Boolean;
                                                AccessTag          : String);
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

Procedure TRESTDWServiceSynPooler.InsertMySQLReturnID(ServerMethodsClass : TComponent;
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

Procedure TRESTDWServiceSynPooler.Loaded;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

//Procedure TRESTDWServiceSynPooler.Notification(AComponent : TComponent;
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

Procedure TRESTDWServiceSynPooler.OnParseAuthentication(AContext       : THttpServerRequest;
                                                        Const AAuthType,
                                                        AAuthData      : String;
                                                        Var VUsername,
                                                        VPassword      : String;
                                                        Var VHandled   : Boolean);
Begin
End;

Procedure TRESTDWServiceSynPooler.OpenDatasets(ServerMethodsClass   : TComponent;
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

Procedure TRESTDWServiceSynPooler.ProcessMassiveSQLCache(ServerMethodsClass      : TComponent;
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

Function TRESTDWServiceSynPooler.ReturnContext(ServerMethodsClass      : TComponent;
                                               Pooler,
                                               urlContext              : String;
                                               Var vResult,
                                               ContentType             : String;
                                               Const ServerContextStream : TStream;
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
                  Try
                   TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream(DWParams, ContentType, TMemoryStream(ServerContextStream), RequestType, ErrorCode);
                  Finally
//                   If ServerContextStream.Size = 0 Then
//                    FreeAndNil(ServerContextStream);
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

Function TRESTDWServiceSynPooler.ReturnEvent(ServerMethodsClass      : TComponent;
                                             Pooler,
                                             urlContext              : String;
                                             Var vResult             : String;
                                             Var DWParams            : TDWParams;
                                             Var JsonMode            : TJsonMode;
                                             Var ErrorCode           : Integer;
                                             Var ContentType,
                                             AccessTag               : String;
                                             Const RequestType       : TRequestType;
                                             Var RequestHeader       : TStringList) : Boolean;
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
Function TRESTDWServiceSynPooler.ServiceMethods(BaseObject              : TComponent;
                                                AContext                : THttpServerRequest;
                                                Var UriOptions          : TRESTDWUriOptions;
                                                Var DWParams            : TDWParams;
                                                Var JSONStr             : String;
                                                Var JsonMode            : TJsonMode;
                                                Var ErrorCode           : Integer;
                                                Var ContentType         : String;
                                                Var ServerContextCall   : Boolean;
                                                Const ServerContextStream : TStream;
                                                ConnectionDefs          : TConnectionDefs;
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
 vResult,
 vResultIP,
 vUrlMethod   :  String;
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
     If ReturnEvent(BaseObject, vUrlMethod, UriOptions.ServerEvent, vResult, DWParams, JsonMode, ErrorCode, ContentType, Accesstag, RequestType, RequestHeader) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       ErrorCode := 200;
       Result  := ReturnContext(BaseObject, vUrlMethod, UriOptions.ServerEvent, vResult, ContentType, TMemoryStream(ServerContextStream), vError, DWParams, RequestType, Mark, RequestHeader, ErrorCode);
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

procedure TRESTDWServiceSynPooler.SetActive(Value: Boolean);
Var
 vActiveTemp : Boolean;
begin
 vActiveTemp := vActive;
 Try
  If (Value)          And
     (Not (vActive))  Then
   Begin
    Try
     Model                := TSQLModel.Create([]);
     Model.Root           := vRootUser;
     Server               := TSQLRestServer.Create(Model);
     If vUseSSL Then
      HTTPServer           := TRESTDWHTTPServer.Create(IntToStr(vServicePort), Server, '+', HTTP_DEFAULT_MODE, vServerThreadPoolCount, secSSL, '/')
     Else
      HTTPServer           := TRESTDWHTTPServer.Create(IntToStr(vServicePort), Server, '+', HTTP_DEFAULT_MODE, vServerThreadPoolCount, secNone, '/');
     {$IFDEF FPC}
      HTTPServer.OnRequest := @aCommandGet;
     {$ELSE}
      HTTPServer.OnRequest := aCommandGet;
     {$ENDIF}
     vActiveTemp          := True;
    Except
     On E : Exception Do
      Begin
       Raise Exception.Create(PChar(E.Message));
      End;
    End;
   End
  Else If Not(Value)  Then
   Begin
    vActiveTemp := False;
    If Assigned(HTTPServer) Then
     Begin
      FreeAndNil(HTTPServer);
      FreeAndNil(Model);
      FreeAndNil(Server);
     End;
   End;
 Finally
  vActive := vActiveTemp;
 End;
End;

procedure TRESTDWServiceSynPooler.SetCORSCustomHeader(Value: TStringList);
Var
 I : Integer;
Begin
 vCORSCustomHeaders.Clear;
 For I := 0 To Value.Count -1 do
  vCORSCustomHeaders.Add(Value[I]);
End;

Procedure TRESTDWServiceSynPooler.SetDefaultPage(Value: TStringList);
Var
 I : Integer;
Begin
 vDefaultPage.Clear;
 For I := 0 To Value.Count -1 do
  vDefaultPage.Add(Value[I]);
End;

Procedure TRESTDWServiceSynPooler.SetServerContext(Value: String);
Begin
 vServerContext := LowerCase(Value);
End;

Procedure TRESTDWServiceSynPooler.SetServerMethod(Value: TComponentClass);
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

end.
