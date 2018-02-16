unit uRESTDWBase;

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha) - Admin - Criador e Administrador do CORE do pacote.
 Ivan Cesar              - Admin - Administrador do CORE do pacote.
 Cristiano Barbosa       - Admin - Administrador do CORE do pacote.
 Giovani da Cruz         - Admin - Administrador do CORE do pacote.
 Alexandre Abbade        - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Mizael Rocha            - Member Tester and DEMO Developer.
 Flávio Motta            - Member Tester and DEMO Developer.
 Itamar Gaucho           - Member Tester and DEMO Developer.
}

interface

Uses
     {$IFDEF FPC}
     SysUtils,                      Classes,            ServerUtils, {$IFDEF WINDOWS}Windows,{$ENDIF}
     IdContext, IdTCPConnection,    IdHTTPServer,       IdCustomHTTPServer,  IdSSLOpenSSL,    IdSSL,
     IdAuthentication,              IdTCPClient,        IdHTTPHeaderInfo,    IdComponent, IdBaseComponent,
     IdHTTP,                        uDWConsts, uDWConstsData,  IdMultipartFormData, IdMessageCoder,
     IdMessageCoderMIME, IdMessage, uDWJSON,            uDWJSONObject, IdGlobal, IdGlobalProtocols,
     HTTPDefs, LConvEncoding;
     {$ELSE}
     {$IF CompilerVersion < 21}
     SysUtils, Classes, EncdDecd, SyncObjs,
     {$ELSE}
     System.SysUtils, System.Classes, system.SyncObjs,
     {$IFEND}
     ServerUtils, HTTPApp,
     {$IFDEF WINDOWS} Windows, {$ENDIF} uDWConsts, uDWConstsData,       IdTCPClient,
     {$IF Defined(ANDROID) OR Defined(IOS)} System.json,{$ELSE} uDWJSON,{$IFEND} IdMultipartFormData,
     IdContext,             IdHTTPServer,        IdCustomHTTPServer,    IdSSLOpenSSL,    IdSSL,
     IdAuthentication,      IdHTTPHeaderInfo,    IdComponent, IdBaseComponent, IdTCPConnection,
     IdHTTP,                IdMessageCoder,      uDWJSONObject,
     IdMessageCoderMIME,    IdMessage,           IdGlobalProtocols,     IdGlobal;
     {$ENDIF}

Type
 TLastRequest  = Procedure (Value             : String)              Of Object;
 TLastResponse = Procedure (Value             : String)              Of Object;
 TEventContext = Procedure (AContext          : TIdContext;
                            ARequestInfo      : TIdHTTPRequestInfo;
                            AResponseInfo     : TIdHTTPResponseInfo) Of Object;
 TOnWork       = Procedure (ASender           : TObject;
                            AWorkMode         : TWorkMode;
                            AWorkCount        : Int64)               Of Object;
 TOnWorkBegin  = Procedure (ASender           : TObject;
                            AWorkMode         : TWorkMode;
                            AWorkCountMax     : Int64)               Of Object;
 TOnWorkEnd    = Procedure (ASender           : TObject;
                            AWorkMode         : TWorkMode)           Of Object;
 TOnStatus     = Procedure (ASender           : TObject;
                            Const AStatus     : TIdStatus;
                            Const AStatusText : String)              Of Object;

Type
 TCallBack      = Procedure (JSon : String; DWParams : TDWParams) Of Object;
 TCallSendEvent = Function (EventData  : String;
                            Var Params : TDWParams;
                            EventType  : TSendEvent = sePOST;
                            CallBack   : TCallBack  = Nil) : String Of Object;

Type
 TServerMethodClass = Class(TComponent)
End;

Type
 TThread_Request = class(TThread)
  FHttpRequest      : TIdHTTP;
  vUserName,
  vPassword,
  vHost             : String;
  vUrlPath          : String;
  vPort             : Integer;
  vAuthentication   : Boolean;
  vTransparentProxy : TIdProxyConnectionInfo;
  vRequestTimeOut   : Integer;
  vTypeRequest      : TTypeRequest;
  vRSCharset        : TEncodeSelect;
  EventData         : String;
  //RBody     : TStringStream;
  Params            : TDWParams;
  EventType         : TSendEvent;
  FCallBack         : TCallBack;
  FCallSendEvent    : TCallSendEvent;
 Private
  Procedure SetParams(HttpRequest : TIdHTTP);
  Function  GetHttpRequest : TIdHTTP;
 Protected
  Procedure Execute;  Override;
 Public
  Constructor Create;
  Destructor Destroy; Override;
  Property CallBack:TCallBack  Read FCallBack Write FCallBack;
  Property HttpRequest:TIdHTTP Read GetHttpRequest;
 End;

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
 TRESTServicePooler = Class(TComponent)
 Protected
  Procedure aCommandGet  (AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
  Procedure aCommandOther(AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
 Private
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
  {$ELSE}
   vCriticalSection : TRTLCriticalSection;
  {$ENDIF}
  vActive          : Boolean;
  vProxyOptions    : TProxyOptions;
  HTTPServer       : TIdHTTPServer;
  vServicePort     : Integer;
  vServerBaseMethod,
  vServerMethod    : TComponentClass;
  vServerParams    : TServerParams;
  vLastRequest     : TLastRequest;
  vLastResponse    : TLastResponse;
  lHandler         : TIdServerIOHandlerSSLOpenSSL;
  aSSLMethod       : TIdSSLVersion;
  aSSLVersions     : TIdSSLVersions;
  vServerContext,
  ASSLPrivateKeyFile,
  ASSLPrivateKeyPassword,
  FRootPath,
  ASSLCertFile     : String;
  VEncondig        : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vSSLVerifyMode      : TIdSSLVerifyModeSet;
  vSSLVerifyDepth     : integer;
  Function SSLVerifyPeer(Certificate: TIdX509;
                         AOk: Boolean; ADepth, AError: Integer): Boolean;
  Procedure GetSSLPassWord (Var Password              : String);
  Procedure SetActive      (Value                     : Boolean);
  Function  GetSecure : Boolean;
  Procedure SetServerMethod(Value                     : TComponentClass);
  Procedure GetPoolerList(ServerMethodsClass          : TComponent;
                          Var PoolerList              : String);
  Function  ServiceMethods(BaseObject                 : TComponent;
                           AContext                   : TIdContext;
                           UrlMethod                  : String;
                           Var DWParams               : TDWParams;
                           Var JSONStr                : String;
                           Var JsonMode               : TJsonMode;
                           hEncodeStrings             : Boolean) : Boolean;
  Procedure EchoPooler    (ServerMethodsClass         : TComponent;
                           AContext                   : TIdContext;
                           Var Pooler, MyIP           : String);
  Procedure ExecuteCommandPureJSON(ServerMethodsClass : TComponent;
                                   Var Pooler         : String;
                                   Var DWParams       : TDWParams;
                                   hEncodeStrings     : Boolean);
  Procedure ExecuteCommandJSON(ServerMethodsClass     : TComponent;
                               Var Pooler             : String;
                               Var DWParams           : TDWParams;
                               hEncodeStrings         : Boolean);
  Procedure InsertMySQLReturnID(ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                hEncodeStrings        : Boolean);
  Procedure ApplyUpdatesJSON   (ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                hEncodeStrings        : Boolean);
  Procedure OpenDatasets       (ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                hEncodeStrings        : Boolean);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                      Var Pooler         : String;
                                      Var DWParams       : TDWParams;
                                      hEncodeStrings     : Boolean);
  Procedure GetEvents                (ServerMethodsClass : TComponent;
                                      Var Pooler         : String;
                                      Var DWParams       : TDWParams);
  Function ReturnEvent               (ServerMethodsClass : TComponent;
                                      Var Pooler,
                                      vResult            : String;
                                      Var DWParams       : TDWParams;
                                      Var JsonMode       : TJsonMode) : Boolean;
 Public
  Constructor Create           (AOwner                : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property Active                : Boolean         Read vActive                Write SetActive;
  Property Secure                : Boolean         Read GetSecure;
  Property ServicePort           : Integer         Read vServicePort           Write vServicePort;  //A Porta do Serviço do DataSet
  Property ProxyOptions          : TProxyOptions   Read vProxyOptions          Write vProxyOptions; //Se tem Proxy diz quais as opções
  Property ServerParams          : TServerParams   Read vServerParams          Write vServerParams;
  Property ServerMethodClass     : TComponentClass Read vServerMethod          Write SetServerMethod;
  Property SSLPrivateKeyFile     : String          Read aSSLPrivateKeyFile     Write aSSLPrivateKeyFile;
  Property SSLPrivateKeyPassword : String          Read aSSLPrivateKeyPassword Write aSSLPrivateKeyPassword;
  Property SSLCertFile           : String          Read aSSLCertFile           Write aSSLCertFile;
  Property SSLMethod             : TIdSSLVersion   Read aSSLMethod             Write aSSLMethod;
  Property SSLVersions           : TIdSSLVersions  Read aSSLVersions           Write aSSLVersions;
  Property OnLastRequest         : TLastRequest    Read vLastRequest           Write vLastRequest;
  Property OnLastResponse        : TLastResponse   Read vLastResponse          Write vLastResponse;
  Property Encoding              : TEncodeSelect   Read VEncondig              Write VEncondig;          //Encoding da string
  Property ServerContext         : String          Read vServerContext         Write vServerContext;
  {TODO CRISTIANO BARBOSA}
  Property RootPath              : String          Read FRootPath              Write FRootPath;
  property SSLVerifyMode: TIdSSLVerifyModeSet read vSSLVerifyMode write vSSLVerifyMode;
  property SSLVerifyDepth: Integer read vSSLVerifyDepth write vSSLVerifyDepth;
End;


Type
 TRESTServiceCGI = Class(TComponent)
 Protected
 Private
  vServerContext,
  FRootPath        : String;
  vServerBaseMethod,
  vServerMethod    : TComponentClass;
  vServerParams    : TServerParams;
  vLastRequest     : TLastRequest;
  vLastResponse    : TLastResponse;
  VEncondig        : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  Procedure SetServerMethod(Value                     : TComponentClass);
  Procedure GetPoolerList(ServerMethodsClass          : TComponent;
                          Var PoolerList              : String);
  Function  ServiceMethods(BaseObject                 : TComponent;
                           AContext,
                           UrlMethod                  : String;
                           Var DWParams               : TDWParams;
                           Var JSONStr                : String;
                           Var JsonMode               : TJsonMode;
                           hEncodeStrings             : Boolean) : Boolean;
  Procedure EchoPooler    (ServerMethodsClass         : TComponent;
                           AContext                   : String;
                           Var Pooler, MyIP           : String);
  Procedure ExecuteCommandPureJSON(ServerMethodsClass : TComponent;
                                   Var Pooler         : String;
                                   Var DWParams       : TDWParams;
                                   hEncodeStrings     : Boolean);
  Procedure ExecuteCommandJSON(ServerMethodsClass     : TComponent;
                               Var Pooler             : String;
                               Var DWParams           : TDWParams;
                                   hEncodeStrings     : Boolean);
  Procedure InsertMySQLReturnID(ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                   hEncodeStrings     : Boolean);
  Procedure ApplyUpdatesJSON   (ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                   hEncodeStrings     : Boolean);
  Procedure OpenDatasets       (ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                   hEncodeStrings     : Boolean);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                      Var Pooler         : String;
                                      Var DWParams       : TDWParams;
                                      hEncodeStrings     : Boolean);
  Procedure GetEvents                (ServerMethodsClass : TComponent;
                                      Var Pooler         : String;
                                      Var DWParams       : TDWParams);
  Function ReturnEvent               (ServerMethodsClass : TComponent;
                                      Var Pooler,
                                      vResult            : String;
                                      Var DWParams       : TDWParams;
                                      Var JsonMode       : TJsonMode): Boolean;
 Public
  {$IFDEF FPC}
   Procedure Command(ARequest: TRequest;    AResponse: TResponse;   Var Handled: Boolean);
  {$ELSE}
   Procedure Command(ARequest: TWebRequest; AResponse: TWebResponse; var Handled: Boolean);
  {$ENDIF}
  Constructor Create           (AOwner                : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property ServerParams          : TServerParams   Read vServerParams          Write vServerParams;
  Property ServerMethodClass     : TComponentClass Read vServerMethod          Write SetServerMethod;
  Property OnLastRequest         : TLastRequest    Read vLastRequest           Write vLastRequest;
  Property OnLastResponse        : TLastResponse   Read vLastResponse          Write vLastResponse;
  Property Encoding              : TEncodeSelect   Read VEncondig              Write VEncondig;          //Encoding da string
  Property ServerContext         : String          Read vServerContext         Write vServerContext;
End;

Type
 TRESTClientPooler = Class(TComponent) //Novo Componente de Acesso a Requisições REST para o RESTDataware
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  HttpRequest       : TIdHTTP;
  Procedure SetParams      (Var aHttpRequest : TIdHTTP);
  Procedure SetOnWork      (Value            : TOnWork);
  Procedure SetOnWorkBegin (Value            : TOnWorkBegin);
  Procedure SetOnWorkEnd   (Value            : TOnWorkEnd);
  Procedure SetOnStatus    (Value            : TOnStatus);
  Function  GetAllowCookies                  : Boolean;
  Procedure SetAllowCookies(Value            : Boolean);
  Function  GetHandleRedirects               : Boolean;
  Procedure SetHandleRedirects(Value         : Boolean);
 Private
  //Variáveis, Procedures e Funções Privadas
  vOnWork           : TOnWork;
  vOnWorkBegin      : TOnWorkBegin;
  vOnWorkEnd        : TOnWorkEnd;
  vOnStatus         : TOnStatus;
  vTypeRequest      : TTypeRequest;
  vRSCharset        : TEncodeSelect;
  vWelcomeMessage,
  vUrlPath,
  vUserName,
  vPassword,
  vHost             : String;
  vPort             : Integer;
  vEncodeStrings,
  vDatacompress,
  vThreadRequest,
  vAuthentication   : Boolean;
  vThreadExecuting  : Boolean;
  vTransparentProxy : TIdProxyConnectionInfo;
  vRequestTimeOut   : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet  : TDatabaseCharSet;
  {$ENDIF}
  Procedure SetUserName(Value : String);
  Procedure SetPassword(Value : String);
  Procedure SetUrlPath (Value : String);
 Public
  //Métodos, Propriedades, Variáveis, Procedures e Funções Publicas
  Function    SendEvent(EventData  : String)           : String;Overload;
  Function    SendEvent(EventData  : String;
                        Var Params : TDWParams;
                        EventType  : TSendEvent = sePOST;
                        CallBack   : TCallBack  = Nil) : String;Overload;
  Constructor Create   (AOwner     : TComponent);Override;
  Destructor  Destroy;Override;
 Published
  //Métodos e Propriedades
  Property DataCompression  : Boolean                Read vDatacompress      Write vDatacompress;
  Property UrlPath          : String                 Read vUrlPath           Write SetUrlPath;
  Property Encoding         : TEncodeSelect          Read vRSCharset         Write vRSCharset;
  Property hEncodeStrings   : Boolean                Read vEncodeStrings     Write vEncodeStrings;
  Property TypeRequest      : TTypeRequest           Read vTypeRequest       Write vTypeRequest       Default trHttp;
  Property Host             : String                 Read vHost              Write vHost;
  Property Port             : Integer                Read vPort              Write vPort              Default 8082;
  Property UserName         : String                 Read vUserName          Write SetUserName;
  Property Password         : String                 Read vPassword          Write SetPassword;
  Property Authentication   : Boolean                Read vAuthentication    Write vAuthentication      Default True;
  Property ProxyOptions     : TIdProxyConnectionInfo Read vTransparentProxy  Write vTransparentProxy;
  Property RequestTimeOut   : Integer                Read vRequestTimeOut    Write vRequestTimeOut;
  Property ThreadRequest    : Boolean                Read vThreadRequest     Write vThreadRequest;
  Property AllowCookies     : Boolean                Read GetAllowCookies    Write SetAllowCookies;
  Property HandleRedirects  : Boolean                Read GetHandleRedirects Write SetHandleRedirects;
  Property WelcomeMessage   : String                 Read vWelcomeMessage    Write vWelcomeMessage;
  Property OnWork           : TOnWork                Read vOnWork            Write SetOnWork;
  Property OnWorkBegin      : TOnWorkBegin           Read vOnWorkBegin       Write SetOnWorkBegin;
  Property OnWorkEnd        : TOnWorkEnd             Read vOnWorkEnd         Write SetOnWorkEnd;
  Property OnStatus         : TOnStatus              Read vOnStatus          Write SetOnStatus;
  {$IFDEF FPC}
  Property DatabaseCharSet  : TDatabaseCharSet       Read vDatabaseCharSet   Write vDatabaseCharSet;
  {$ENDIF}
End;

implementation

Uses uDWDatamodule, uRESTDWPoolerDB, SysTypes, uDWJSONTools, uRESTDWServerEvents;

{ TRESTServiceCGI }

{$IFDEF FPC}
procedure TRESTServiceCGI.Command(ARequest: TRequest; AResponse: TResponse;
  Var Handled: Boolean);
{$ELSE}
procedure TRESTServiceCGI.Command(ARequest: TWebRequest; AResponse: TWebResponse;
  var Handled: Boolean);
{$ENDIF}
Var
 JsonMode           : TJsonMode;
 DWParams           : TDWParams;
 vWelcomeMessage,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 Cmd , UrlMethod,
 tmp, JSONStr,
 sFile, sContentType,
 authDecode,
 sCharSet,
 ReturnObject       : String;
 vTempServerMethods : TObject;
 newdecoder,
 Decoder            : TIdMessageDecoder;
 JSONParam          : TJSONParam;
 encodestrings,
 compresseddata,
 msgEnd             : Boolean;
 mb,
 vContentStringStream,
 ms                 : TStringStream;
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
 End;
Begin
 JsonMode           := jmDataware;
 vTempServerMethods := Nil;
 DWParams           := Nil;
 compresseddata     := False;
 encodestrings      := False;
 {$IFNDEF FPC}
   Cmd := Trim(ARequest.PathInfo);
   AResponse.CustomHeaders.Add('Access-Control-Allow-Origin=*');
 {$ELSE}
  Cmd := Trim(ARequest.HeaderLine);
  AResponse.CustomHeaders.Add('Access-Control-Allow-Origin=*');
 {$ENDIF}
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
    sFile := FRootPath + ARequest.PathInfo;
   {$ELSE}
    sFile := FRootPath + ARequest.Command;
   {$ENDIF}
   If FileExists(sFile) then
    Begin
     AResponse.ContentType := sContentType;
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
     	 If (sCharSet <> '') Then
        AResponse.ContentEncoding := sCharSet;
      {$IFEND}
     {$ENDIF}
     AResponse.ContentStream := TIdReadFileExclusiveStream.Create(sFile);
     {$IFNDEF FPC}{$if CompilerVersion > 21}AResponse.FreeContentStream := true;{$IFEND}{$ENDIF}
     Handled := True;
     Exit;
    End;
  End;
 If ARequest.Content <> '' Then
  Begin
   vContentStringStream := TStringStream.Create(ARequest.Content);
   Try
    vContentStringStream.Position := 0;
    msgEnd   := False;
    boundary := ExtractHeaderSubItem(ARequest.ContentType, 'boundary', QuoteHTTP);
    startboundary := '--' + boundary;
    Repeat
     tmp := ReadLnFromStream(vContentStringStream, -1, True);
    until tmp = startboundary;
   finally
    vContentStringStream.Free;
   end;
  End;
 Try
  {$IFNDEF FPC}
  Cmd := stringreplace(Trim(lowercase(ARequest.PathInfo)), lowercase(vServerContext) + '/', '', [rfReplaceAll]);
  {$ELSE}
  Cmd := stringreplace(Trim(lowercase(ARequest.HeaderLine)), lowercase(vServerContext) + '/', '', [rfReplaceAll]);
  {$ENDIF}
  if (Trim(ARequest.Content) = '') And (Cmd = '') then
   Exit;
  Cmd := StringReplace(Cmd, lowercase(' HTTP/1.0'), '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, lowercase(' HTTP/1.1'), '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, lowercase(' HTTP/2.0'), '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, lowercase(' HTTP/2.1'), '', [rfReplaceAll]);
  If (vServerParams.HasAuthentication) Then
   Begin
    If ARequest.Authorization <> '' Then
     Begin
      authDecode := DecodeStrings(StringReplace(ARequest.Authorization, 'Basic ', '', [rfReplaceAll])
                                  {$IFDEF FPC}, csUndefined{$ENDIF});
      If Not ((Pos(vServerParams.Username, authDecode) > 0) And
              (Pos(vServerParams.Password, authDecode) > 0)) Then
       Begin
        Handled := False;
        Exit;
       End;
     End;
   End;
    {$IFNDEF FPC}
    If ARequest.PathInfo <> '/favicon.ico' Then
    {$ELSE}
    If ARequest.URI <> '/favicon.ico' Then
    {$ENDIF}
     Begin
    {$IFNDEF FPC}
     If (ARequest.QueryFields.Count > 0) And (Trim(ARequest.Content) = '') Then
      DWParams  := TServerUtils.ParseWebFormsParams (ARequest.QueryFields, Cmd,
                                                     UrlMethod, VEncondig,
                                                     ARequest.Method)
    {$ELSE}
     If (ARequest.FieldCount > 0) And (Trim(ARequest.Content) = '') Then
      DWParams  := TServerUtils.ParseWebFormsParams (ARequest.ContentFields, Cmd,
                                                     UrlMethod, VEncondig)
    {$ENDIF}
      Else
       Begin
        If Trim(ARequest.Content) = '' Then
         {$IFNDEF FPC}
         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + ARequest.Query, VEncondig)
         {$ELSE}
         DWParams  := TServerUtils.ParseRESTURL (ARequest.URI, VEncondig)
         {$ENDIF}
        Else
         Begin
          Try
           vContentStringStream := TStringStream.Create(ARequest.Content);
           Repeat
            decoder              := TIdMessageDecoderMIME.Create(nil);
            TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
            Try
             decoder.SourceStream := vContentStringStream;
             decoder.FreeSourceStream := False;
            finally
            end;
            decoder.ReadHeader;
//            Inc(I);
            Case Decoder.PartType of
             mcptAttachment,
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
               If Decoder <> Nil Then
                TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
               If pos('dwwelcomemessage', tmp) > 0 Then
                vWelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, csUndefined{$ENDIF})
               Else If pos('datacompression', tmp) > 0 Then
                compresseddata := StringToBoolean(ms.DataString)
               Else If pos('dwencodestrings', tmp) > 0 Then
                encodestrings  := StringToBoolean(ms.DataString)
               Else
                Begin
                 If Not Assigned(DWParams) Then
                  Begin
                   DWParams           := TDWParams.Create;
                   DWParams.Encoding  := VEncondig;
                  End;
                 JSONParam   := TJSONParam.Create(DWParams.Encoding);
                 JSONParam.FromJSON(ms.DataString);
                 DWParams.Add(JSONParam);
                End;
               {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
               FreeAndNil(ms);
               {ico}
               FreeAndNil(newdecoder);
               {ico}
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
             mcptEOF:
              Begin
               FreeAndNil(decoder);
               msgEnd := True
              End;
             End;
           Until (Decoder = Nil) Or (msgEnd);
          Finally
           If decoder <> nil then
            FreeAndNil(decoder);
           If vContentStringStream <> Nil Then
            FreeAndNil(vContentStringStream);
          End;
          If DWParams <> Nil Then
           If DWParams.ItemsString['dwEventNameData'] <> Nil Then
            UrlMethod := DWParams.ItemsString['dwEventNameData'].Value;
         End;
       End;
      If Assigned(vServerMethod) Then
       Begin
        vTempServerMethods:=vServerMethod.Create(nil);
        If vServerBaseMethod = TServerMethods Then
         Begin
          If Trim(vWelcomeMessage) <> '' Then
           Begin
            If Assigned(TServerMethods(vTempServerMethods).OnWelcomeMessage) then
             TServerMethods(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage);
           End;
         End
        Else If vServerBaseMethod = TServerMethodDatamodule Then
         Begin
          If Trim(vWelcomeMessage) <> '' Then
           Begin
            If Assigned(TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage) then
             TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage);
           End;
         End;
       End
      Else
       JSONStr := GetPairJSON(-5, 'Server Methods Cannot Assigned');
      Try
       If Assigned(vServerMethod) Then
        Begin
         {$IFNDEF FPC}
         If ARequest.PathInfo + ARequest.Query <> '' Then
         {$ELSE}
         If ARequest.URI <> '' Then
         {$ENDIF}
          Begin
           {$IFNDEF FPC}
            UrlMethod := Trim(ARequest.PathInfo + ARequest.Query);
           {$ELSE}
            UrlMethod := Trim(ARequest.URI);
           {$ENDIF}
          End;
         While (Length(UrlMethod) > 0) Do
          Begin
           If Pos('/', UrlMethod) > 0 then
            Delete(UrlMethod, 1, 1)
           Else
            Begin
             UrlMethod := Trim(UrlMethod);
             If Pos('?', UrlMethod) > 0 Then
              UrlMethod := Copy(UrlMethod, 1, Pos('?', UrlMethod)-1);
             Break;
            End;
          End;
         If vTempServerMethods <> Nil Then
          Begin
           JSONStr := ARequest.RemoteAddr;
           {$IFDEF FPC}
           If Not ServiceMethods(TComponent(vTempServerMethods), ARequest.LocalPathPrefix, UrlMethod, DWParams, JSONStr, JSONMode, encodestrings) Then
           {$ELSE}
           If Not ServiceMethods(TComponent(vTempServerMethods), ARequest.Method, UrlMethod, DWParams, JSONStr, JsonMode, encodestrings) Then
           {$ENDIF}
            Begin
             If Trim(ARequest.Content) = '' Then
              Begin
               If vServerBaseMethod = TServerMethods Then
                Begin
                 If Assigned(TServerMethods(vTempServerMethods).OnReplyEvent) then
                  TServerMethods(vTempServerMethods).OnReplyEvent(seGET, UrlMethod, DWParams, JSONStr);
                End
               Else If vServerBaseMethod = TServerMethodDatamodule Then
                Begin
                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnReplyEvent) then
                  TServerMethodDatamodule(vTempServerMethods).OnReplyEvent(seGET, UrlMethod, DWParams, JSONStr);
                End;
              End
             Else
              Begin
               If vServerBaseMethod = TServerMethods Then
                Begin
                 If Assigned(TServerMethods(vTempServerMethods).OnReplyEvent) then
                  TServerMethods(vTempServerMethods).OnReplyEvent(sePOST, UrlMethod, DWParams, JSONStr);
                End
               Else If vServerBaseMethod = TServerMethodDatamodule Then
                Begin
                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnReplyEvent) then
                  TServerMethodDatamodule(vTempServerMethods).OnReplyEvent(sePOST, UrlMethod, DWParams, JSONStr);
                End;
              End;
            End;
          End;
        End;
       Try
        If Assigned(DWParams) Then
         Begin
          If JsonMode = jmDataware Then
           Begin
            If Trim(JSONStr) <> '' Then
             Begin
              If Not(((Pos('{', JSONStr) > 0)   And
                      (Pos('}', JSONStr) > 0))  Or
                     ((Pos('[', JSONStr) > 0)   And
                      (Pos(']', JSONStr) > 0))) Then
               Begin
                If Not((JSONStr[InitStrPos] = '"') And
                       (JSONStr[Length(JSONStr)] = '"')) Then
                 JSONStr := '"' + JSONStr + '"';
               End;
             End;
            vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
           End
          Else If JsonMode in [jmPureJSON, jmMongoDB] Then
           Begin
            If DWParams.CountOutParams < 2 Then
             ReturnObject := '%s'
            Else
             ReturnObject := '[%s]';
            vReplyString                        := Format(ReturnObject, [GetParamsReturn(DWParams)]);
            If vReplyString = '' Then
             vReplyString                       := JSONStr;
           End;
         End
        Else
         vReplyString := 'Message (Internal Error)';
        If compresseddata Then
         Begin
          ZCompressStr(vReplyString, vReplyStringResult);
          mb                                 := TStringStream.Create(vReplyStringResult{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
         End
        Else
         mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
        mb.Position                          := 0;
        {$IFNDEF FPC}
        {$IF CompilerVersion > 21}
        AResponse.FreeContentStream          := True;
        {$IFEND}
        {$ENDIF}
        If VEncondig = esUtf8 Then
         AResponse.ContentType            := 'application/json;charset=utf-8'
        Else If VEncondig = esASCII Then
         AResponse.ContentType            := 'application/json;charset=ansi';
        AResponse.ContentStream           := mb;
        AResponse.ContentStream.Position := 0;
        AResponse.ContentLength          := mb.Size;
       Finally
        {$IFNDEF FPC}
        {$IF CompilerVersion < 21}
        FreeAndNil(mb);
        {$IFEND}
        {$ENDIF}
       End;
      Finally
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
 Finally
  If AResponse.ContentLength = 0 Then
   AResponse.Content := '{"ServerStarus":"REST Dataware - Server CGI - Online!"}';
  Handled:= True;
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
 End;
End;

procedure TRESTServiceCGI.SetServerMethod(Value: TComponentClass);
begin
 If (Value.ClassParent      = TServerMethods) Or
    (Value                  = TServerMethods) Then
  Begin
   vServerMethod     := Value;
   vServerBaseMethod := TServerMethods;
  End
 Else If (Value.ClassParent = TServerMethodDatamodule) Or
         (Value             = TServerMethodDatamodule) Then
  Begin
   vServerMethod := Value;
   vServerBaseMethod := TServerMethodDatamodule;
  End;
end;

procedure TRESTServiceCGI.GetPoolerList(ServerMethodsClass: TComponent;
  Var PoolerList: String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If PoolerList = '' then
        PoolerList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        PoolerList := PoolerList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

function TRESTServiceCGI.ServiceMethods(BaseObject     : TComponent;
                                        AContext,
                                        UrlMethod      : String;
                                        Var DWParams   : TDWParams;
                                        Var JSONStr    : String;
                                        Var JsonMode   : TJsonMode;
                                        hEncodeStrings : Boolean): Boolean;
Var
 vResult,
 vResultIP,
 vUrlMethod   : String;
 JSONParam    : TJSONParam;
Begin
 Result       := False;
 vUrlMethod   := UpperCase(UrlMethod);
 If vUrlMethod = UpperCase('GetPoolerList') Then
  Begin
   Result     := True;
   GetPoolerList(BaseObject, vResult);
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
 Else If vUrlMethod = UpperCase('EchoPooler') Then
  Begin
   vResultIP := JSONStr;
   If DWParams.ItemsString['Pooler'] <> Nil Then
    vResult    := DWParams.ItemsString['Pooler'].Value
   Else If DWParams.count > 0 Then
    JSONStr := DWParams.Items[0].Value
   Else
    vResult    := JSONStr;
   EchoPooler(BaseObject, JSONStr, vResult, vResultIP);
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
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ExecuteCommandPureJSON') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ExecuteCommandPureJSON(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ExecuteCommandJSON') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ExecuteCommandJSON(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ApplyUpdates') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ApplyUpdatesJSON(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCache') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ApplyUpdates_MassiveCache(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('InsertMySQLReturnID_PARAMS') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   InsertMySQLReturnID(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('InsertMySQLReturnID') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   InsertMySQLReturnID(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('OpenDatasets') Then
  Begin
   vResult     := DWParams.ItemsString['Pooler'].Value;
   OpenDatasets(BaseObject, vResult, DWParams, hEncodeStrings);
   Result      := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('GETEVENTS') Then
  Begin
   GetEvents(BaseObject, vResult, DWParams);
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
   Result      := JSONStr = TReplyOK;
  End
 Else
  Begin
   If ReturnEvent(BaseObject, vUrlMethod, vResult, DWParams, JsonMode) Then
    Result := vResult = TReplyOK;
  End;
End;

procedure TRESTServiceCGI.EchoPooler(ServerMethodsClass: TComponent;
                                     AContext: String; Var Pooler, MyIP: String);
Var
 I : Integer;
Begin
 MyIP := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]) Then
        Begin
         If AContext <> '' Then
          MyIP := AContext;
         Break;
        End;
      End;
    End;
  End;
End;

procedure TRESTServiceCGI.ExecuteCommandPureJSON(ServerMethodsClass : TComponent;
                                                 Var Pooler         : String;
                                                 Var DWParams       : TDWParams;
                                                 hEncodeStrings     : Boolean);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError,
 vExecute  : Boolean;
 vMessageError : String;
Begin
  try
   If ServerMethodsClass <> Nil Then
    Begin
     For I := 0 To ServerMethodsClass.ComponentCount -1 Do
      Begin
       If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
        Begin
         If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
            Begin
             vExecute := DWParams.ItemsString['Execute'].AsBoolean;
             vError   := DWParams.ItemsString['Error'].AsBoolean;
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      vError,
                                                                                                      vMessageError,
                                                                                                      vExecute);
             If vMessageError <> '' Then
              DWParams.ItemsString['MessageError'].AsString := vMessageError;
             DWParams.ItemsString['Error'].AsBoolean := vError;
             If DWParams.ItemsString['Result'] <> Nil Then
              Begin
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
  finally
  {Ico}
   FreeAndNil(vTempJSON);
  {Ico}
  end;
End;

procedure TRESTServiceCGI.ExecuteCommandJSON(ServerMethodsClass : TComponent;
                                             Var Pooler         : String;
                                             Var DWParams       : TDWParams;
                                             hEncodeStrings     : Boolean);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError,
 vExecute  : Boolean;
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vExecute := DWParams.ItemsString['Execute'].AsBoolean;
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParamsD <> Nil Then
            Begin
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      DWParamsD, vError, vMessageError,
                                                                                                      vExecute);
             DWParamsD.Free;
            End
           Else
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                     vError,
                                                                                                     vMessageError,
                                                                                                     vExecute);
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON,
                                                       DWParams.ItemsString['Result'].Encoded);
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
End;

procedure TRESTServiceCGI.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TDWParams;
                                              hEncodeStrings     : Boolean);
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
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
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
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

procedure TRESTServiceCGI.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                           Var Pooler         : String;
                                           Var DWParams       : TDWParams;
                                           hEncodeStrings     : Boolean);
Var
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vSQL,
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
          If DWParams.ItemsString['SQL'] <> Nil Then
           vSQL := DWParams.ItemsString['SQL'].Value;
          vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(DWParams.ItemsString['Massive'].Value,
                                                                                                  vSQL,
                                                                                                  DWParamsD, vError, vMessageError);
           If DWParamsD <> Nil Then
            DWParamsD.Free;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON,
                                                       DWParams.ItemsString['Result'].Encoded);
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

Function TRESTServiceCGI.ReturnEvent(ServerMethodsClass : TComponent;
                                     Var Pooler,
                                     vResult            : String;
                                     Var DWParams       : TDWParams;
                                     Var JsonMode       : TJsonMode) : Boolean;
Var
 I : Integer;
Begin
 Result    := False;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       Result := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
       If Result Then
        Begin
         TDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
         If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
          TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
         JsonMode           := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].JsonMode;
         If Trim(vResult) = '' Then
          vResult := TReplyOK;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServiceCGI.GetEvents(ServerMethodsClass : TComponent;
                                       Var Pooler         : String;
                                       Var DWParams       : TDWParams);
Var
 I         : Integer;
 vError    : Boolean;
 vTempJSON : String;
Begin
 vTempJSON := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If vTempJSON = '' Then
        vTempJSON := Format('%s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
       Else
        vTempJSON := vTempJSON + Format(', %s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
      End;
    End;
   vError := vTempJSON = '';
   If vError Then
    DWParams.ItemsString['MessageError'].AsString := 'Events Not Found';
   DWParams.ItemsString['Error'].AsBoolean        := vError;
   If DWParams.ItemsString['Result'] <> Nil Then
    Begin
     If vTempJSON <> '' Then
      DWParams.ItemsString['Result'].SetValue(Format('[%s]', [vTempJSON]),
                                              DWParams.ItemsString['Result'].Encoded)
     Else
      DWParams.ItemsString['Result'].SetValue('');
    End;
  End;
End;

procedure TRESTServiceCGI.OpenDatasets(ServerMethodsClass : TComponent;
                                       Var Pooler         : String;
                                       Var DWParams       : TDWParams;
                                       hEncodeStrings     : Boolean);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError    : Boolean;
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
                                                                                                  vError, vMessageError);
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON,
                                                       DWParams.ItemsString['Result'].Encoded);
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
End;

procedure TRESTServiceCGI.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                    Var Pooler         : String;
                                                    Var DWParams       : TDWParams;
                                                    hEncodeStrings     : Boolean);
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].Value,
                                                                                                  vError,  vMessageError);
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

constructor TRESTServiceCGI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  vServerParams := TServerParams.Create(Self);
  vServerParams.HasAuthentication := True;
  vServerParams.UserName          := 'testserver';
  vServerParams.Password          := 'testserver';
  vServerContext                  := 'restdataware';
  VEncondig                       := esUtf8;
end;

destructor TRESTServiceCGI.Destroy;
begin
  vServerParams.Free;
  inherited Destroy;
end;

Constructor TRESTClientPooler.Create(AOwner: TComponent);
Begin
 Inherited;
 HttpRequest                     := TIdHTTP.Create(Nil);
 HttpRequest.Request.ContentType := 'application/json';
 HttpRequest.AllowCookies        := False;
 //HttpRequest.HandleRedirects     := False;
 HttpRequest.HTTPOptions         := [hoKeepOrigProtocol];
 vTransparentProxy               := TIdProxyConnectionInfo.Create;
 vHost                           := 'localhost';
 vPort                           := 8082;
 vUserName                       := 'testserver';
 vPassword                       := 'testserver';
 vRSCharset                      := esUtf8;
 vAuthentication                   := True;
 vRequestTimeOut                 := 10000;
 vThreadRequest                  := False;
 vDatacompress                   := True;
 vEncodeStrings                  := True;
 {$IFDEF FPC}
 vDatabaseCharSet                := csUndefined;
 {$ENDIF}
End;

Destructor  TRESTClientPooler.Destroy;
Begin
 Try
  If HttpRequest.Connected Then
   HttpRequest.Disconnect;
 Except
 End;
 HttpRequest.Free;
 FreeAndNil(vTransparentProxy);
 Inherited;
End;

Function TRESTClientPooler.GetAllowCookies: Boolean;
Begin
 Result := HttpRequest.AllowCookies;
End;

Function TRESTClientPooler.GetHandleRedirects : Boolean;
Begin
 Result := HttpRequest.HandleRedirects;
End;

{$IFNDEF FPC}
{$if CompilerVersion > 21} // Delphi 2010 pra cima
{$IF Defined(ANDROID) or Defined(IOS)} //Alteardo para IOS Brito
Function TRESTClientPooler.SendEvent(EventData  : String;
                                     Var Params : TDWParams;
                                     EventType  : TSendEvent = sePOST;
                            		     CallBack   : TCallBack  = Nil) : String;
Var
 vURL,
 vTpRequest    : String;
 aStringStream : TStringStream;
 vResultParams : TMemoryStream;
 bStringStream,
 StringStream  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 thd           : TThread_Request;
 StringStreamList : TStringStreamList;
 vDataPack,
 SResult : String;
 Procedure SetData(Var InputValue : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue    : TJsonObject;
  bJsonOBJTemp  : TJSONArray;
  JSONParam,
  JSONParamNew  : TJSONParam;
  A, InitPos    : Integer;
  vValue,
  aValue,
  vTempValue    : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Exit;
  Try
   InitPos     := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[') ;
   aValue   := Copy(InputValue, InitPos,    Length(InputValue) -1);
   If Pos(']}', aValue) > 0 Then
    aValue     := Copy(aValue, 0, Pos(']}', aValue) -1);
   vTempValue := aValue;
   InputValue := Copy(InputValue, 0, InitPos-1) + ']}'; //Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If (Params <> Nil) And (InputValue <> '{"PARAMS"]}') Then
    Begin
     bJsonValue:= TJSONObject.ParseJSONValue(InputValue) as TJSONObject;
     InputValue    := '';
     bJsonOBJTemp:= bJsonValue.GetValue('PARAMS') as TJSONArray;
     If bJsonOBJTemp.count > 0 Then
      Begin
       For A := 0 To bJsonOBJTemp.count -1 Do
        Begin
         bJsonOBJ :=  bJsonOBJTemp.get(A) as TJSONObject;
         If bJsonOBJ.count = 0 Then
          Begin
           FreeAndNil(bJsonOBJ);
           Continue;
          End;
         If GetObjectName(bJsonOBJ.Getvalue('ObjectType').value ) <> toParam Then
          Begin
           FreeAndNil(bJsonOBJ);
           Continue;
          End;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := stringreplace(bJsonOBJ.pairs[4].JsonString.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]);
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.getvalue('ValueType').value);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.getvalue('Direction').value);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.GetValue('Encoded').value);
          If JSONParam.Encoded Then
           vValue := DecodeStrings(stringreplace(bJsonOBJ.pairs[4].JsonValue.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]) )
          Else
           vValue := bJsonOBJ.pairs[4].JsonValue.tostring;
          JSONParam.SetValue(vValue, JSONParam.Encoded);
          //bJsonOBJ.clean;
          FreeAndNil(bJsonOBJ);
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value //, JSONParam.Encoded);
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
         Finally
          FreeAndNil(JSONParam);
          If Assigned(bJsonOBJ) Then
           Begin
            //bJsonOBJ.clean;
            FreeAndNil(bJsonOBJ);
           End;
         End;
        End;
      End;
     //bJsonValue.Clean;
     FreeAndNil(bJsonValue);
     FreeAndNil(bJsonOBJTemp);
    End;
  Finally
   If vTempValue <> '' Then
    ResultJSON := vTempValue;
   vTempValue := '';
  End;
 End;
 Procedure SetParamsValues(DWParams : TDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I         : Integer;
  JSONParam : TJSONParam;
 Begin
  If DWParams <> Nil Then
   Begin
     If Not (Assigned(StringStreamList)) Then
     StringStreamList := TStringStreamList.Create;
     For I := 0 To DWParams.Count -1 Do
     Begin
            If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob,
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
          SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
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
Begin
 SendParams := Nil;
 StringStreamList := Nil;
 // INICIO BLOCO PARA USA thread   CRISTIANO BABSOSA
 If vThreadRequest and (not vThreadExecuting) then
  Begin
   thd := TThread_Request.Create;
   Try
    thd.FreeOnTerminate := true;
    thd.Priority        := tpHighest;
    thd.EventData       := EventData;
    {TODO CRISTIANO BARBOSA}
    thd.Params.CopyFrom(Params);
    thd.EventType       := EventType;
    thd.vUserName       := vUserName;
    thd.vPassword       := vPassword;
    thd.vUrlPath        := vUrlPath;
    thd.vHost           :=   vHost;
    thd.vPort           :=   vPort;
    thd.vAuthentication   :=   vAuthentication;
    thd.vTransparentProxy:=   vTransparentProxy;
    thd.vRequestTimeOut :=   vRequestTimeOut;
    thd.vTypeRequest    :=   vTypeRequest;
    thd.vRSCharset      :=   vRSCharset;
    thd.FCallBack       :=  CallBack;
    thd.FCallSendEvent   :=   self.SendEvent;
    vThreadExecuting:=True;
   Finally
    thd.Execute;
   End;
   Exit;
  End;
 // FIM BLOCO PARA USA thread   CRISTIANO BABSOSA
 vResultParams := TMemoryStream.Create;
 If vTypeRequest = trHttp Then
  vTpRequest := 'http'
 Else If vTypeRequest = trHttps Then
  vTpRequest := 'https';
 Try
  vURL := LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
  If vRSCharset = esUtf8 Then
   HttpRequest.Request.Charset := 'utf-8'
  Else If vRSCharset = esASCII Then
   HttpRequest.Request.Charset := 'ansi';
  SetParams(HttpRequest);
  HttpRequest.MaxAuthRetries := 0;
  Case EventType Of
   seGET :
    Begin
     HttpRequest.Request.ContentType := 'application/json';

     //CRSITIANO BARBOSA - BLOCO PARA USAR TRHEAD
     If not vThreadRequest Then
       Result := HttpRequest.Get(EventData)
     else
     begin
       SResult := HttpRequest.Get(EventData);
       If Assigned(CallBack) Then
         CallBack(SResult, Params);
     end;
    End;
   sePOST,
   sePUT,
   seDELETE :
    Begin;
     If EventType = sePOST Then
      Begin
       SendParams := TIdMultiPartFormDataStream.Create;
       If Params <> Nil Then
        SetParamsValues(Params, SendParams);
       If vWelcomeMessage <> '' Then
        SendParams.AddFormField('dwwelcomemessage', EncodeStrings(vWelcomeMessage));
       SendParams.AddFormField('datacompression',   BooleanToString(vDatacompress));
       SendParams.AddFormField('dwencodestrings',   BooleanToString(vEncodeStrings));
       If (Params <> Nil) Or (vWelcomeMessage <> '') Then
        Begin
         HttpRequest.Request.ContentType     := 'application/x-www-form-urlencoded';
         HttpRequest.Request.ContentEncoding := 'multipart/form-data';
         If vDatacompress Then
          Begin
           aStringStream := TStringStream.Create(HttpRequest.Post(vURL, SendParams), TEncoding.UTF8);
           ZDecompressStreamD(aStringStream, StringStream);
           FreeAndNil(aStringStream);
          End
         Else
          Begin
           StringStream                      := TStringStream.Create('');
           HttpRequest.Post(vURL, SendParams, StringStream);
          End;
         StringStream.Position := 0;
         If SendParams <> Nil Then
          Begin
           If Assigned(StringStreamList) Then
            FreeAndNil(StringStreamList);
           SendParams.Clear;
           FreeAndNil(SendParams);
          End;
        End
       Else
        Begin
         HttpRequest.Request.ContentType     := 'application/json';
         HttpRequest.Request.ContentEncoding := '';
         aStringStream := TStringStream.Create('');
         HttpRequest.Get(EventData, aStringStream);
         aStringStream.Position := 0;
         StringStream   := TStringStream.Create('');
         bStringStream  := TStringStream.Create('');
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
         FreeAndNil(bStringStream);
         FreeAndNil(aStringStream);
        End;
       HttpRequest.Request.Clear;
       StringStream.Position := 0;
       vDataPack := StringStream.DataString;
       If Not vThreadRequest Then
        Begin
         StringStream.Clear;
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, Result);
        End
       Else
        Begin
         //vDataPack := StringStream.DataString;
          StringStream.Clear;
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, SResult);
         If Assigned(CallBack) Then
          CallBack(SResult, Params);
        End;
      End
     Else If EventType = sePUT Then
      Begin
       HttpRequest.Request.ContentType := 'application/x-www-form-urlencoded';
       StringStream  := TStringStream.Create('');
       HttpRequest.Post(vURL, SendParams, StringStream);
       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       vDataPack := StringStream.DataString;
       StringStream.Clear;
       FreeAndNil(StringStream);
       If not vThreadRequest Then
        SetData(vDataPack, Params, Result)
       Else
        Begin
         SetData(vDataPack, Params, SResult);
         If Assigned(CallBack) Then
           CallBack(SResult, Params);
        End;
      End
     Else If EventType = seDELETE Then
      Begin
       Try
        HttpRequest.Request.ContentType := 'application/json';
        HttpRequest.Delete(vURL);
        If not vThreadRequest Then
          Result := GetPairJSON('OK', 'DELETE COMMAND OK')
        else
        begin
           SResult := GetPairJSON('OK', 'DELETE COMMAND OK');
           If Assigned(CallBack) Then
             CallBack(SResult, Params);
        end;
       Except
        On e:exception Do
         Begin
           If not vThreadRequest Then
             Result := GetPairJSON('NOK', e.Message)
           else
           Begin
              SResult := GetPairJSON('NOK', e.Message);
              If Assigned(CallBack) Then
                CallBack(SResult, Params);
           End;
         End;
       End;
      End;
    End;
  End;
 Except
  On E : Exception Do
   Begin
    {Todo: Acrescentado}
    If Assigned(vResultParams) Then
     FreeAndNil(vResultParams);
    vThreadExecuting:=False;
    Raise Exception.Create(e.Message);
    Exit;
   End;
 End;
 FreeAndNil(vResultParams);
 vThreadExecuting:=False;
End;
{$IFEND}
{$IFEND}
{$IF NOT (Defined(ANDROID) or Defined(IOS))} //Alteardo para IOS Brito
Function TRESTClientPooler.SendEvent(EventData  : String;
                                     Var Params : TDWParams;
                                     EventType  : TSendEvent = sePOST;
                            		     CallBack   : TCallBack  = Nil) : String;
Var
 vURL,
 vTpRequest,
 vDataPack     : String;
 aStringStream : TStringStream;
 vResultParams : TMemoryStream;
 bStringStream,
 StringStream  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 thd           : TThread_Request;
 SResult : String;
 StringStreamList : TStringStreamList;
 Procedure SetData(Var InputValue : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue    : TJsonObject;
  bJsonOBJTemp  : TJSONArray;
  JSONParam,
  JSONParamNew  : TJSONParam;
  A, InitPos    : Integer;
  vValue,
  aValue,
  vTempValue    : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Exit;
  Try
   InitPos    := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[') ;
   aValue     := Copy(InputValue, InitPos, Length(InputValue));
   If Pos(']}', aValue) > 0 Then
    aValue    := Copy(aValue, 1, length(aValue)-2); //Copy(aValue, 1, Pos(']}', aValue) -1);      //CRISTIANO BARBOSA -
   vTempValue := aValue;
   InputValue := Copy(InputValue, 1, InitPos -1) + ']}'; //Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If (Params <> Nil) And (InputValue <> '{"PARAMS"]}') Then
    Begin
     {$IFNDEF FPC}
     {$IF CompilerVersion < 21}
     If vRSCharset = esUtf8 Then
      bJsonValue    := TJsonObject.Create(UTF8Decode(InputValue))
     Else
      bJsonValue    := TJsonObject.Create(InputValue);
     {$ELSE}
      bJsonValue    := TJsonObject.Create(InputValue);
     {$IFEND}
     {$ENDIF}
     InputValue    := '';
     bJsonOBJTemp  := bJsonValue.getJSONArray(bJsonValue.names.get(0).ToString); //TJSONArray.Create(bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
     If bJsonOBJTemp.length > 0 Then
      Begin
       For A := 0 To bJsonOBJTemp.length -1 Do
        Begin
         bJsonOBJ := bJsonOBJTemp.getJSONObject(A); //TJsonObject.Create(bJsonOBJTemp.get(A).ToString);
         If Length(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) = 0 Then
          Begin
//           FreeAndNil(bJsonOBJ);
           Continue;
          End;
         If GetObjectName(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) <> toParam Then
          Begin
//           FreeAndNil(bJsonOBJ);
           Continue;
          End;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := bJsonOBJ.names.get(4).ToString;
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString);
          If Not(JSONParam.ObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
           Begin
            If (JSONParam.Encoded) Then
             vValue := DecodeStrings(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString)
            Else
             vValue := bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString;
           End
          Else
           vValue := bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString;
//          bJsonOBJ.clean;
//          FreeAndNil(bJsonOBJ);
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(vValue, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded)
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue,
                                                                (JSONParam.Encoded And
                                                                 Not(JSONParam.ObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob])));
         Finally
          vValue := '';
          FreeAndNil(JSONParam);
{
          If Assigned(bJsonOBJ) Then
           Begin
            bJsonOBJ.clean;
            FreeAndNil(bJsonOBJ);
           End;
}
         End;
        End;
      End;
     bJsonValue.Clean;
     FreeAndNil(bJsonValue);
//     FreeAndNil(bJsonOBJTemp);
    End;
  Finally
   If vTempValue <> '' Then
    ResultJSON := vTempValue;
   vTempValue := '';
  End;
 End;
 Procedure SetParamsValues(DWParams : TDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I         : Integer;
 Begin
  If DWParams <> Nil Then
   Begin
    If Not (Assigned(StringStreamList)) Then
     StringStreamList := TStringStreamList.Create;
    For I := 0 To DWParams.Count -1 Do
     Begin
      If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob,
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
          SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
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
Begin
 SendParams := Nil;
 StringStreamList := Nil;
 // INICIO BLOCO PARA USA thread   CRISTIANO BABSOSA
 If vThreadRequest and (not vThreadExecuting) then
  Begin
   thd := TThread_Request.Create;
   Try
    thd.FreeOnTerminate := true;
    thd.Priority        := tpHighest;
    thd.EventData       := EventData;
    {TODO CRISTIANO BARBOSA}
    thd.Params.CopyFrom(Params);
    thd.EventType       := EventType;
    thd.vUserName       := vUserName;
    thd.vPassword       := vPassword;
    thd.vUrlPath        := vUrlPath;
    thd.vHost           :=   vHost;
    thd.vPort           :=   vPort;
    thd.vAuthentication   :=  vAuthentication;
    thd.vTransparentProxy := vTransparentProxy;
    thd.vRequestTimeOut :=   vRequestTimeOut;
    thd.vTypeRequest    :=   vTypeRequest;
    thd.vRSCharset      :=   vRSCharset;
    thd.FCallBack       :=  CallBack;
    thd.FCallSendEvent   :=   self.SendEvent;
   vThreadExecuting:=True;
   Finally
    thd.Execute;
   End;
   Exit;
  End;
   // FIM BLOCO PARA USA thread   CRISTIANO BABSOSA
 vResultParams := TMemoryStream.Create;
 If vTypeRequest = trHttp Then
  vTpRequest := 'http'
 Else If vTypeRequest = trHttps Then
  vTpRequest := 'https';
 Try
  vURL := LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
  If vRSCharset = esUtf8 Then
   HttpRequest.Request.Charset := 'utf-8'
  Else If vRSCharset = esASCII Then
   HttpRequest.Request.Charset := 'ansi';
  SetParams(HttpRequest);
  HttpRequest.MaxAuthRetries := 0;
  Case EventType Of
   {
   seGET :
    Begin
     HttpRequest.Request.ContentType := 'application/json';
     Result := HttpRequest.Get(EventData);
    End;
   }
   seGET,
   sePOST,
   sePUT,
   seDELETE :
    Begin;
     If EventType In [seGET, sePOST] Then
      Begin
       SendParams := TIdMultiPartFormDataStream.Create;
       If Params <> Nil Then
        SetParamsValues(Params, SendParams);
       If vWelcomeMessage <> '' Then
        SendParams.AddFormField('dwwelcomemessage', EncodeStrings(vWelcomeMessage));
       SendParams.AddFormField('datacompression',   BooleanToString(vDatacompress));
       SendParams.AddFormField('dwencodestrings',   BooleanToString(vEncodeStrings));
       If (Params <> Nil) Or (vWelcomeMessage <> '') Or (vDatacompress) Then
        Begin
         HttpRequest.Request.ContentType     := 'application/x-www-form-urlencoded';
         HttpRequest.Request.ContentEncoding := 'multipart/form-data';
         If vDatacompress Then
          Begin
           {$IFDEF FPC}
            aStringStream := TStringStream.Create(HttpRequest.Post(vURL, SendParams));
           {$ELSE}
            aStringStream := TStringStream.Create(HttpRequest.Post(vURL, SendParams){$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
           {$ENDIF}
           ZDecompressStreamD(aStringStream, StringStream);
           FreeAndNil(aStringStream);
          End
         Else
          Begin
           StringStream                      := TStringStream.Create('');
           HttpRequest.Post(vURL, SendParams, StringStream);
          End;
         StringStream.Position := 0;
         If SendParams <> Nil Then
          Begin
           If Assigned(StringStreamList) Then
            FreeAndNil(StringStreamList);
           {$IFNDEF FPC}SendParams.Clear;{$ENDIF}
           FreeAndNil(SendParams);
          End;
        End
       Else
        Begin
         HttpRequest.Request.ContentType     := 'application/json';
         HttpRequest.Request.ContentEncoding := '';
         aStringStream := TStringStream.Create('');
         HttpRequest.Get(vURL, aStringStream);
         aStringStream.Position := 0;
         StringStream   := TStringStream.Create('');
         bStringStream  := TStringStream.Create('');
         If vDatacompress Then
          Begin
           bStringStream.CopyFrom(aStringStream, aStringStream.Size);
           bStringStream.Position := 0;
           ZDecompressStreamD(bStringStream, StringStream);
          End
         Else
          Begin
//           bStringStream.CopyFrom(aStringStream, aStringStream.Size);
//           bStringStream.Position := 0;
           StringStream.CopyFrom(aStringStream, aStringStream.Size);
           StringStream.Position := 0;
//           HexToStream(bStringStream.DataString, StringStream);
          End;
         FreeAndNil(bStringStream);
         FreeAndNil(aStringStream);
        End;
       HttpRequest.Request.Clear;
       StringStream.Position := 0;
       vDataPack := StringStream.DataString;
       If Not vThreadRequest Then
        Begin
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, Result);
        End
       Else
        Begin
         vDataPack := StringStream.DataString;
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
          StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, SResult);
         If Assigned(CallBack) Then
          CallBack(SResult, Params);
        End;
      End
     Else If EventType = sePUT Then
      Begin
       HttpRequest.Request.ContentType := 'application/x-www-form-urlencoded';
       StringStream  := TStringStream.Create('');
       HttpRequest.Post(vURL, SendParams, StringStream);
       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       vDataPack := StringStream.DataString;
       {$IFNDEF FPC}
       {$IF CompilerVersion > 21}
        StringStream.Clear;
       {$IFEND}
       StringStream.Size := 0;
       {$ENDIF}
       FreeAndNil(StringStream);
       If not vThreadRequest Then
        SetData(vDataPack, Params, Result)
       Else
        Begin
         SetData(vDataPack, Params, SResult);
         If Assigned(CallBack) Then
           CallBack(SResult, Params);
        End;
      End
     Else If EventType = seDELETE Then
      Begin
       Try
        HttpRequest.Request.ContentType := 'application/json';
        HttpRequest.Delete(vURL);
        If not vThreadRequest Then
          Result := GetPairJSON('OK', 'DELETE COMMAND OK')
        else
        begin
           SResult := GetPairJSON('OK', 'DELETE COMMAND OK');
           If Assigned(CallBack) Then
             CallBack(SResult, Params);
        end;
       Except
        On e:exception Do
         Begin
          If not vThreadRequest Then
             Result := GetPairJSON('NOK', e.Message)
          else
           Begin
              SResult := GetPairJSON('NOK', e.Message);
              If Assigned(CallBack) Then
                CallBack(SResult, Params);
           End;
         End;
       End;
      End;
    End;
  End;
 Except
  On E : Exception Do
   Begin
    {Todo: Acrescentado}
    If Assigned(SendParams) Then
     SendParams.Free;
    If Assigned(vResultParams) Then
     vResultParams.Free;
    If Assigned(StringStreamList) Then
     StringStreamList.Free;
    Raise Exception.Create(e.Message);
    Exit;
   End;
 End;
 FreeAndNil(vResultParams);
 vThreadExecuting:=false;
End;
{$IFEND}
{$ELSE}
Function TRESTClientPooler.SendEvent(EventData  : String;
                                     Var Params : TDWParams;
                                     EventType  : TSendEvent = sePOST;
                            	       CallBack   : TCallBack  = Nil) : String; //Código original VCL e LCL
Var
 vURL,
 vTpRequest    : String;
 aStringStream : TStringStream;
 vResultParams : TMemoryStream;
 bStringStream,
 StringStream  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 thd           : TThread_Request;
 vDataPack,
 SResult : String;
 StringStreamList : TStringStreamList;
 Procedure SetData(Var InputValue     : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue    : TJsonObject;
  bJsonOBJTemp  : TJSONArray;
  JSONParam,
  JSONParamNew  : TJSONParam;
  A, InitPos    : Integer;
  vValue,
  aValue,
  vTempValue    : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Exit;
  Try
   InitPos    := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[') ;
   {$IFDEF ANDROID} //Android}
   aValue    := Copy(InputValue, InitPos, Length(InputValue)-1);
   {$ELSE}
   aValue    := Copy(InputValue, InitPos, Length(InputValue));
   {$ENDIF}
   If Pos(']}', aValue) > 0 Then
    {$IFDEF ANDROID} //Android}
    aValue     := Copy(aValue, 0, Pos(']}', aValue)-1 );
    {$ELSE}
    aValue     := Copy(aValue, 1, Pos(']}', aValue) -1);
    {$ENDIF}
   vTempValue := aValue;
   {$IFDEF ANDROID} //Android}
   InputValue := Copy(InputValue, 0, InitPos12) + ']}'; //Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   {$ELSE}
   InputValue := Copy(InputValue, 1, InitPos -1) + ']}'; //Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   {$ENDIF}
   If (Params <> Nil) And (InputValue <> '{"PARAMS"]}') Then
    Begin
//     bJsonValue    := TJsonObject.Create({$IFDEF FPC}GetStringEncode({$ENDIF}InputValue{$IFDEF FPC}, vDatabaseCharSet){$ENDIF});
     {$IFDEF FPC}
      If vRSCharset = esUtf8 Then
       bJsonValue    := TJsonObject.Create(PWidechar(UTF8Decode(InputValue)))
      Else
       bJsonValue    := TJsonObject.Create(InputValue);
     {$ELSE}
      bJsonValue    := TJsonObject.Create(InputValue);
     {$ENDIF}
     InputValue    := '';
     bJsonOBJTemp  := bJsonValue.getJSONArray(bJsonValue.names.get(0).ToString); //TJSONArray.Create(bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
     If bJsonOBJTemp.length > 0 Then
      Begin
       For A := 0 To bJsonOBJTemp.length -1 Do
        Begin
         bJsonOBJ := bJsonOBJTemp.getJSONObject(A); //TJsonObject.Create(bJsonOBJTemp.get(A).ToString);
//         bJsonOBJ := TJsonObject.Create(bJsonOBJTemp.get(A).ToString);
         If Length(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) = 0 Then
          Begin
//           FreeAndNil(bJsonOBJ);
           Continue;
          End;
         If GetObjectName(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) <> toParam Then
          Begin
//           FreeAndNil(bJsonOBJ);
           Continue;
          End;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := bJsonOBJ.names.get(4).ToString;
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString);
          If JSONParam.Encoded Then
           vValue := DecodeStrings(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
          Else
           vValue := bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString;
          JSONParam.SetValue(vValue, JSONParam.Encoded);
{
          bJsonOBJ.clean;
          FreeAndNil(bJsonOBJ);
}
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value //, JSONParam.Encoded);
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
         Finally
          FreeAndNil(JSONParam);
{
          If Assigned(bJsonOBJ) Then
           Begin
            bJsonOBJ.clean;
            FreeAndNil(bJsonOBJ);
           End;
}
         End;
        End;
      End;
     bJsonValue.Clean;
     FreeAndNil(bJsonValue);
//     FreeAndNil(bJsonOBJTemp);
    End;
  Finally
   If vTempValue <> '' Then
    ResultJSON := vTempValue;
   vTempValue := '';
  End;
 End;
 Procedure SetParamsValues(DWParams : TDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I : Integer;
 Begin
  If DWParams <> Nil Then
   Begin
    If Not (Assigned(StringStreamList)) Then
     StringStreamList := TStringStreamList.Create;
    For I := 0 To DWParams.Count -1 Do
     Begin
      If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob,
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
          SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
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
Begin
 SendParams := Nil;
 StringStreamList := Nil;
 // INICIO BLOCO PARA USA thread   CRISTIANO BABSOSA
 If vThreadRequest and (not vThreadExecuting) then
  Begin
   thd := TThread_Request.Create;
   Try
    thd.FreeOnTerminate := true;
    thd.Priority        := tpHighest;
    thd.EventData       := EventData;
    {TODO CRISTIANO BARBOSA}
    thd.Params.CopyFrom(Params);
    thd.EventType       := EventType;
    thd.vUserName       := vUserName;
    thd.vPassword       := vPassword;
    thd.vUrlPath        := vUrlPath;
    thd.vHost           :=   vHost;
    thd.vPort           :=   vPort;
    thd.vAuthentication   :=   vAuthentication;
    thd.vTransparentProxy:=   vTransparentProxy;
    thd.vRequestTimeOut :=   vRequestTimeOut;
    thd.vTypeRequest    :=   vTypeRequest;
    thd.vRSCharset      :=   vRSCharset;
    thd.FCallBack       :=  CallBack;
    {$IFDEF FPC}
    thd.FCallSendEvent  :=  @self.SendEvent;
    {$ELSE}
    thd.FCallSendEvent  :=  self.SendEvent;
    {$ENDIF}
    vThreadExecuting:=True;
   Finally
    thd.Execute;
   End;
   Exit;
  End;
 vResultParams := TMemoryStream.Create;
 If vTypeRequest = trHttp Then
  vTpRequest := 'http'
 Else If vTypeRequest = trHttps Then
  vTpRequest := 'https';
 Try
  vURL := LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
  If vRSCharset = esUtf8 Then
   HttpRequest.Request.Charset := 'utf-8'
  Else If vRSCharset = esASCII Then
   HttpRequest.Request.Charset := 'ansi';
  SetParams(HttpRequest);
  HttpRequest.MaxAuthRetries := 0;
  Case EventType Of
   seGET :
    Begin
     HttpRequest.Request.ContentType := 'application/json';
     //CRSITIANO BARBOSA - BLOCO PARA USAR TRHEAD
     If not vThreadRequest Then
       Result := HttpRequest.Get(EventData)
     else
     begin
       SResult := HttpRequest.Get(EventData);
       If Assigned(CallBack) Then
         CallBack(SResult, Params);
     end;
    End;
   sePOST,
   sePUT,
   seDELETE :
    Begin;
     If EventType = sePOST Then
      Begin
       SendParams := TIdMultiPartFormDataStream.Create;
       If Params <> Nil Then
        SetParamsValues(Params, SendParams);
       If vWelcomeMessage <> '' Then
        SendParams.AddFormField('dwwelcomemessage', EncodeStrings(vWelcomeMessage, vDatabaseCharSet));
       SendParams.AddFormField('datacompression',   BooleanToString(vDatacompress));
       SendParams.AddFormField('dwencodestrings',   BooleanToString(vEncodeStrings));
       If (Params <> Nil) Or (vWelcomeMessage <> '') Then
        Begin
         HttpRequest.Request.ContentType     := 'application/x-www-form-urlencoded';
         HttpRequest.Request.ContentEncoding := 'multipart/form-data';
         If vDatacompress Then
          Begin
           {$IFDEF FPC}
            aStringStream := TStringStream.Create(HttpRequest.Post(vURL, SendParams));
           {$ELSE}
            aStringStream := TStringStream.Create(HttpRequest.Post(vURL, SendParams){$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
           {$ENDIF}
           ZDecompressStreamD(aStringStream, StringStream);
           FreeAndNil(aStringStream);
          End
         Else
          Begin
           StringStream                      := TStringStream.Create('');
           HttpRequest.Post(vURL, SendParams, StringStream);
          End;
         StringStream.Position := 0;
         If SendParams <> Nil Then
          Begin
           If Assigned(StringStreamList) Then
            FreeAndNil(StringStreamList);
           {$IFNDEF FPC}SendParams.Clear;{$ENDIF}
           FreeAndNil(SendParams);
          End;
        End
       Else
        Begin
         HttpRequest.Request.ContentType     := 'application/json';
         HttpRequest.Request.ContentEncoding := '';
         aStringStream := TStringStream.Create('');
         HttpRequest.Get(EventData, aStringStream);
         aStringStream.Position := 0;
         StringStream   := TStringStream.Create('');
         bStringStream  := TStringStream.Create('');
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
         FreeAndNil(bStringStream);
         FreeAndNil(aStringStream);
        End;
       HttpRequest.Request.Clear;
       StringStream.Position := 0;
       vDataPack := StringStream.DataString;
       If not vThreadRequest Then
        Begin
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, Result);
        End
       Else
        Begin
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, SResult);
         If Assigned(CallBack) Then
          CallBack(SResult, Params);
        End;
      End
     Else If EventType = sePUT Then
      Begin
       HttpRequest.Request.ContentType := 'application/x-www-form-urlencoded';
       StringStream  := TStringStream.Create('');
       HttpRequest.Post(vURL, SendParams, StringStream);
       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       vDataPack := StringStream.DataString;
       If not vThreadRequest Then
        Begin
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, Result);
        End
       Else
        Begin
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, SResult);
         If Assigned(CallBack) Then
          CallBack(SResult, Params);
        End;
      End
     Else If EventType = seDELETE Then
      Begin
       Try
        HttpRequest.Request.ContentType := 'application/json';
        HttpRequest.Delete(vURL);
        If not vThreadRequest Then
          Result := GetPairJSON('OK', 'DELETE COMMAND OK')
        else
        begin
           SResult := GetPairJSON('OK', 'DELETE COMMAND OK');
           If Assigned(CallBack) Then
             CallBack(SResult, Params);
        end;
       Except
        On e:exception Do
         Begin
          If not vThreadRequest Then
             Result := GetPairJSON('NOK', e.Message)
           else
           Begin
              SResult := GetPairJSON('NOK', e.Message);
              If Assigned(CallBack) Then
                CallBack(SResult, Params);
           End;
         End;
       End;
      End;
    End;
  End;
 Except
  On E : Exception Do
   Begin
    {Todo: Acrescentado}
    Raise Exception.Create(e.Message);
   End;
 End;
 FreeAndNil(vResultParams);
 vThreadExecuting:=false;
End;
{$ENDIF}

{
Function TRESTClientPooler.SendEvent(EventData : String;
                                     CallBack  : TCallBack = Nil) : String;
Var
 RBody      : TStringStream;
 vTpRequest : String;
 Params     : TDWParams;
Begin
 Params  := Nil;
 RBody   := TStringStream.Create('');
 Try
  If vTypeRequest = trHttp Then
   vTpRequest := 'http'
  Else If vTypeRequest = trHttps Then
   vTpRequest := 'https';
  Result := SendEvent(LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData, Params, sePOST, CallBack);
 Except
 End;
 RBody.Free;
End;
}

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

Procedure TRESTClientPooler.SetAllowCookies(Value: Boolean);
Begin
 HttpRequest.AllowCookies    := Value;
End;

Procedure TRESTClientPooler.SetHandleRedirects(Value: Boolean);
Begin
 HttpRequest.HandleRedirects := Value;
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

Procedure TRESTClientPooler.SetParams(Var aHttpRequest  : TIdHTTP);
Begin
 aHttpRequest.Request.BasicAuthentication := vAuthentication;
 If aHttpRequest.Request.BasicAuthentication Then
  Begin
   If aHttpRequest.Request.Authentication = Nil Then
    aHttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
   aHttpRequest.Request.Authentication.Password := vPassword;
   aHttpRequest.Request.Authentication.Username := vUserName;
  End;
 aHttpRequest.ProxyParams.BasicAuthentication := vTransparentProxy.BasicAuthentication;
 aHttpRequest.ProxyParams.ProxyUsername       := vTransparentProxy.ProxyUsername;
 aHttpRequest.ProxyParams.ProxyServer         := vTransparentProxy.ProxyServer;
 aHttpRequest.ProxyParams.ProxyPassword       := vTransparentProxy.ProxyPassword;
 aHttpRequest.ProxyParams.ProxyPort           := vTransparentProxy.ProxyPort;
 aHttpRequest.ReadTimeout         := vRequestTimeout;
 aHttpRequest.Request.ContentType := HttpRequest.Request.ContentType;
 aHttpRequest.AllowCookies        := HttpRequest.AllowCookies;
 aHttpRequest.HandleRedirects     := HttpRequest.HandleRedirects;
 aHttpRequest.HTTPOptions         := HttpRequest.HTTPOptions;
 aHttpRequest.Request.Charset     := HttpRequest.Request.Charset;
End;

procedure TRESTClientPooler.SetPassword(Value : String);
begin
 vPassword := Value;
 HttpRequest.Request.Password := vPassword;
end;

Procedure TRESTClientPooler.SetUrlPath(Value : String);
Begin
 vUrlPath := Value;
 If Length(vUrlPath) > 0 Then
  If vUrlPath[Length(vUrlPath)] <> '/' Then
   vUrlPath := vUrlPath + '/';
End;

procedure TRESTClientPooler.SetUserName(Value : String);
begin
 vUsername := Value;
end;

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

Procedure TRESTServicePooler.GetPoolerList(ServerMethodsClass : TComponent;
                                           Var PoolerList     : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
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
                                            MyIP           : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]) Then
        Begin
         If AContext <> Nil Then
          MyIP := AContext.Connection.Socket.Binding.IP;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.ExecuteCommandPureJSON(ServerMethodsClass : TComponent;
                                                    Var Pooler         : String;
                                                    Var DWParams       : TDWParams;
                                                    hEncodeStrings     : Boolean);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vEncoded,
 vError,
 vExecute  : Boolean;
 vMessageError : String;
Begin
 Try
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                     vError,
                                                                                                     vMessageError,
                                                                                                     vExecute);
            If vMessageError <> '' Then
             DWParams.ItemsString['MessageError'].AsString := vMessageError;
            DWParams.ItemsString['Error'].AsBoolean := vError;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              vEncoded := DWParams.ItemsString['Result'].Encoded;
              If vTempJSON <> Nil Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, vEncoded)
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
  FreeAndNil(vTempJSON);
 End;
End;

Procedure TRESTServicePooler.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                                 Var Pooler         : String;
                                                 Var DWParams       : TDWParams;
                                                 hEncodeStrings     : Boolean);
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
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
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
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

Procedure TRESTServicePooler.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                       Var Pooler         : String;
                                                       Var DWParams       : TDWParams;
                                                       hEncodeStrings     : Boolean);
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].Value,
                                                                                                  vError,  vMessageError);
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TDWParams;
                                              hEncodeStrings     : Boolean);
Var
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vSQL,
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
          If DWParams.ItemsString['SQL'] <> Nil Then
           vSQL := DWParams.ItemsString['SQL'].Value;
          vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(DWParams.ItemsString['Massive'].Value,
                                                                                                  vSQL,
                                                                                                  DWParamsD, vError, vMessageError);
           If DWParamsD <> Nil Then
            DWParamsD.Free;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded);
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

Procedure TRESTServicePooler.ExecuteCommandJSON(ServerMethodsClass : TComponent;
                                                Var Pooler         : String;
                                                Var DWParams       : TDWParams;
                                                hEncodeStrings     : Boolean);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError,
 vExecute  : Boolean;
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vExecute := DWParams.ItemsString['Execute'].AsBoolean;
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParamsD <> Nil Then
            Begin
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      DWParamsD, vError, vMessageError,
                                                                                                      vExecute);
             DWParamsD.Free;
            End
           Else
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                     vError,
                                                                                                     vMessageError,
                                                                                                     vExecute);
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded);
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
End;


Function TRESTServicePooler.ReturnEvent(ServerMethodsClass : TComponent;
                                        Var Pooler,
                                        vResult            : String;
                                        Var DWParams       : TDWParams;
                                        Var JsonMode       : TJsonMode) : Boolean;
Var
 I : Integer;
Begin
 Result    := False;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       Result := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
       If Result Then
        Begin
         TDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
         If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
          TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
         JsonMode := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].JsonMode;
         If Trim(vResult) = '' Then
          vResult := TReplyOK;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.GetEvents(ServerMethodsClass : TComponent;
                                       Var Pooler         : String;
                                       Var DWParams       : TDWParams);
Var
 I         : Integer;
 vError    : Boolean;
 vTempJSON : String;
Begin
 vTempJSON := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If vTempJSON = '' Then
        vTempJSON := Format('%s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
       Else
        vTempJSON := vTempJSON + Format(', %s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
      End;
    End;
   vError := vTempJSON = '';
   If vError Then
    DWParams.ItemsString['MessageError'].AsString := 'Events Not Found';
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

Procedure TRESTServicePooler.OpenDatasets(ServerMethodsClass : TComponent;
                                          Var Pooler         : String;
                                          Var DWParams       : TDWParams;
                                          hEncodeStrings     : Boolean);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError    : Boolean;
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
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
                                                                                                  vError, vMessageError);
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].StringToBytes(vTempJSON.ToJSON, True);
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
End;

Function TRESTServicePooler.ServiceMethods(BaseObject     : TComponent;
                                           AContext       : TIdContext;
                                           UrlMethod      : String;
                                           Var DWParams   : TDWParams;
                                           Var JSONStr    : String;
                                           Var JsonMode   : TJsonMode;
                                           hEncodeStrings : Boolean) : Boolean;
Var
 vResult,
 vResultIP,
 vUrlMethod   :  String;
Begin
 Result       := False;
 vUrlMethod   := UpperCase(UrlMethod);
 If vUrlMethod = UpperCase('GetPoolerList') Then
  Begin
   Result     := True;
   GetPoolerList(BaseObject, vResult);
   DWParams.ItemsString['Result'].SetValue(vResult,
                                           DWParams.ItemsString['Result'].Encoded);
   JSONStr    := TReplyOK;
  End
 Else If vUrlMethod = UpperCase('EchoPooler') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   EchoPooler(BaseObject, AContext, vResult, vResultIP);
   DWParams.ItemsString['Result'].SetValue(vResultIP,
                                           DWParams.ItemsString['Result'].Encoded);
   Result     := vResultIP <> '';
   If Result Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ExecuteCommandPureJSON') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ExecuteCommandPureJSON(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ExecuteCommandJSON') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ExecuteCommandJSON(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ApplyUpdates') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ApplyUpdatesJSON(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCache') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   ApplyUpdates_MassiveCache(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('InsertMySQLReturnID_PARAMS') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   InsertMySQLReturnID(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('InsertMySQLReturnID') Then
  Begin
   vResult    := DWParams.ItemsString['Pooler'].Value;
   InsertMySQLReturnID(BaseObject, vResult, DWParams, hEncodeStrings);
   Result     := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('OpenDatasets') Then
  Begin
   vResult     := DWParams.ItemsString['Pooler'].Value;
   OpenDatasets(BaseObject, vResult, DWParams, hEncodeStrings);
   Result      := True;
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
  End
 Else If vUrlMethod = UpperCase('GETEVENTS') Then
  Begin
   GetEvents(BaseObject, vResult, DWParams);
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    JSONStr    := TReplyNOK;
   Result      := JSONStr = TReplyOK;
  End
 Else
  Begin
   If ReturnEvent(BaseObject, vUrlMethod, vResult, DWParams, JsonMode) Then
    Begin
     JSONStr := vResult;
     Result  := JSONStr <> '';
    End;
  End;
End;

Function GetMIMEType(sFile: TFileName) : string;
Var
 aMIMEMap : TIdMIMETable;
Begin
 aMIMEMap:= TIdMIMETable.Create(true);
 Try
  Result:= aMIMEMap.GetFileMIMEType(sFile);
 Finally
  aMIMEMap.Free;
 End;
End;

Procedure TRESTServicePooler.aCommandGet(AContext      : TIdContext;
                                         ARequestInfo  : TIdHTTPRequestInfo;
                                         AResponseInfo : TIdHTTPResponseInfo);
Var
 JsonMode           : TJsonMode;
 DWParams           : TDWParams;
 vWelcomeMessage,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 Cmd , UrlMethod,
 tmp, JSONStr,
 ReturnObject,
 sFile, sContentType, sCharSet       : String;
 vTempServerMethods : TObject;
 newdecoder,
 Decoder            : TIdMessageDecoder;
 JSONParam          : TJSONParam;
 encodestrings,
 compresseddata,
 msgEnd             : Boolean;
 mb,
 ms                 : TStringStream;
 Function GetParamsReturn(Params : TDWParams) : String;
 Var
  A, I : Integer;
 Begin
  A := 0;
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
 End;
Begin
 JsonMode           := jmDataware;
 vTempServerMethods := Nil;
 DWParams           := Nil;
 compresseddata     := False;
 encodestrings      := False;
 Cmd := Trim(ARequestInfo.RawHTTPCommand);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin','*');
  {$ELSE}
   AResponseInfo.CustomHeaders.Add     ('Access-Control-Allow-Origin=*');
  {$IFEND}
 {$ELSE}
  AResponseInfo.CustomHeaders.AddValue ('Access-Control-Allow-Origin','*');
 {$ENDIF}
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
     sFile := FRootPath+ARequestInfo.URI;
    {$ELSE}
     sFile := FRootPath+ARequestInfo.Command;
    {$IFEND}
   {$ELSE}
    sFile := FRootPath+ARequestInfo.URI;
   {$ENDIF}
   If FileExists(sFile) then
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
 If ARequestInfo.PostStream <> Nil Then
  Begin
   ARequestInfo.PostStream.Position := 0;
   msgEnd   := False;
   boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
   startboundary := '--' + boundary;
   Repeat
    tmp := ReadLnFromStream(ARequestInfo.PostStream, -1, True);
   until tmp = startboundary;
  End;
 Try
  Cmd := Trim(ARequestInfo.RawHTTPCommand);
  Cmd := StringReplace(Cmd, ' HTTP/1.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/1.1', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.1', '', [rfReplaceAll]);
  If (vServerParams.HasAuthentication) Then
   Begin
    If Not ((ARequestInfo.AuthUsername = vServerParams.Username)  And
            (ARequestInfo.AuthPassword = vServerParams.Password)) Then
     Begin
      AResponseInfo.AuthRealm := AuthRealm;
      AResponseInfo.WriteContent;
      Exit;
     End;
   End;
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET' ) OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'POST') OR
     (UpperCase(Copy (Cmd, 1, 3)) = 'HEAD') Then
   Begin
    If ARequestInfo.URI <> '/favicon.ico' Then
     Begin
      If ARequestInfo.Params.Count > 0 Then
       DWParams  := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                      UrlMethod, VEncondig)
      Else
       Begin
        If Copy(Cmd, 1, 3) = 'GET' Then
         DWParams  := TServerUtils.ParseRESTURL (ARequestInfo.URI, VEncondig)
        Else
         Begin
          Try
           Repeat
            decoder              := TIdMessageDecoderMIME.Create(nil);
            TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
            decoder.SourceStream := ARequestInfo.PostStream;
            decoder.FreeSourceStream := False;
            decoder.ReadHeader;
//            Inc(I);
            Case Decoder.PartType of
             mcptAttachment,
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
               If Decoder <> Nil Then
                TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
               If pos('dwwelcomemessage', tmp) > 0 Then
                vWelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, csUndefined{$ENDIF})
               Else If pos('datacompression', tmp) > 0 Then
                compresseddata := StringToBoolean(ms.DataString)
               Else If pos('dwencodestrings', tmp) > 0 Then
                encodestrings  := StringToBoolean(ms.DataString)
               Else
                Begin
                 If DWParams = Nil Then
                  Begin
                   DWParams           := TDWParams.Create;
                   DWParams.Encoding  := VEncondig;
                  End;
                 JSONParam   := TJSONParam.Create(DWParams.Encoding);
                 JSONParam.FromJSON(ms.DataString);
                 DWParams.Add(JSONParam);
                End;
               {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
               FreeAndNil(ms);
               {ico}
               FreeAndNil(newdecoder);
               {ico}
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
             mcptEOF:
              Begin
               FreeAndNil(decoder);
               msgEnd := True
              End;
             End;
           Until (Decoder = Nil) Or (msgEnd);
          Finally
           If decoder <> nil then
            FreeAndNil(decoder);
          End;
         End;
       End;
      If Assigned(vServerMethod) Then
       Begin
        vTempServerMethods:=vServerMethod.Create(nil);
        If vServerBaseMethod = TServerMethods Then
         Begin
          If Trim(vWelcomeMessage) <> '' Then
           Begin
            If Assigned(TServerMethods(vTempServerMethods).OnWelcomeMessage) then
             TServerMethods(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage);
           End;
         End
        Else If vServerBaseMethod = TServerMethodDatamodule Then
         Begin
          If Trim(vWelcomeMessage) <> '' Then
           Begin
            If Assigned(TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage) then
             TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage);
           End;
         End;
       End
      Else
       JSONStr := GetPairJSON(-5, 'Server Methods Cannot Assigned');
      Try
       If Assigned(vLastRequest) Then
        Begin
        {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
          {$IFDEF WINDOWS}
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
          Try
          vLastRequest(ARequestInfo.UserAgent + #13#10 +
                      ARequestInfo.RawHTTPCommand);
         Finally
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
       If Assigned(vServerMethod) Then
        Begin
         If UrlMethod = '' Then
          Begin
           If ARequestInfo.URI <> '' Then
            Begin
             UrlMethod := Trim(ARequestInfo.URI);
             If UrlMethod <> '' Then
              If UrlMethod[1] = '/' then
               Delete(UrlMethod, 1, 1);
             If Pos('/', UrlMethod) > 0 then
              UrlMethod := Copy(UrlMethod, 1, Pos('/', UrlMethod) -1);
            End
           Else
            Begin
             While (Length(UrlMethod) > 0) Do
              Begin
               If Pos('/', UrlMethod) > 0 then
                Delete(UrlMethod, 1, 1)
               Else
                Begin
                 UrlMethod := Trim(UrlMethod);
                 Break;
                End;
              End;
            End;
          End;
         If vTempServerMethods <> Nil Then
          Begin
           If Not ServiceMethods(TComponent(vTempServerMethods), AContext, UrlMethod, DWParams, JSONStr, JsonMode, EncodeStrings) Then
            Begin
             If UpperCase(Copy (Cmd, 1, 3)) = 'GET' Then
              Begin
               If vServerBaseMethod = TServerMethods Then
                Begin
                 If Assigned(TServerMethods(vTempServerMethods).OnReplyEvent) then
                  TServerMethods(vTempServerMethods).OnReplyEvent(seGET, UrlMethod, DWParams, JSONStr);
                End
               Else If vServerBaseMethod = TServerMethodDatamodule Then
                Begin
                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnReplyEvent) then
                  TServerMethodDatamodule(vTempServerMethods).OnReplyEvent(seGET, UrlMethod, DWParams, JSONStr);
                End;
              End
             Else If UpperCase(Copy (Cmd, 1, 4)) = 'POST' Then
              Begin
               If vServerBaseMethod = TServerMethods Then
                Begin
                 If Assigned(TServerMethods(vTempServerMethods).OnReplyEvent) then
                  TServerMethods(vTempServerMethods).OnReplyEvent(sePOST, UrlMethod, DWParams, JSONStr);
                End
               Else If vServerBaseMethod = TServerMethodDatamodule Then
                Begin
                 If Assigned(TServerMethodDatamodule(vTempServerMethods).OnReplyEvent) then
                  TServerMethodDatamodule(vTempServerMethods).OnReplyEvent(sePOST, UrlMethod, DWParams, JSONStr);
                End;
              End;
            End;
          End;
        End;
       Try
        If JsonMode = jmDataware Then
         Begin
          If Trim(JSONStr) <> '' Then
           Begin
            If Not(((Pos('{', JSONStr) > 0)   And
                    (Pos('}', JSONStr) > 0))  Or
                   ((Pos('[', JSONStr) > 0)   And
                    (Pos(']', JSONStr) > 0))) Then
             Begin
              If Not((JSONStr[InitStrPos] = '"') And
                     (JSONStr[Length(JSONStr)] = '"')) Then
               JSONStr := '"' + JSONStr + '"';
             End;
           End;
          vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
         End
        Else If JsonMode in [jmPureJSON, jmMongoDB] Then
         Begin
          If DWParams.CountOutParams < 2 Then
           ReturnObject := '%s'
          Else
           ReturnObject := '[%s]';
          vReplyString                        := Format(ReturnObject, [GetParamsReturn(DWParams)]);
          If vReplyString = '' Then
           vReplyString                       := JSONStr;
         End;
        If compresseddata Then
         Begin
          ZCompressStr(vReplyString, vReplyStringResult);
          mb                                 := TStringStream.Create(vReplyStringResult{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
         End
        Else
         mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
        mb.Position                          := 0;
        AResponseInfo.FreeContentStream      := True;
        AResponseInfo.ContentType            := 'application/json'; //'text';//'application/octet-stream';
        AResponseInfo.ResponseNo             := 200;
        If TEncodeSelect(VEncondig) = esUtf8 Then
         AResponseInfo.Charset := 'utf-8'
        Else If TEncodeSelect(VEncondig) = esASCII Then
         AResponseInfo.Charset := 'ansi';
        AResponseInfo.ContentStream          := mb;
        AResponseInfo.ContentStream.Position := 0;
        AResponseInfo.ContentLength          := mb.Size;
//        AResponseInfo.ContentText            := mb.Datastring;
//        AResponseInfo.WriteHeader;
        AResponseInfo.WriteContent;
       Finally
//        FreeAndNil(mb);
       End;
       If Assigned(vLastResponse) Then
        Begin
         {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
          {$IFDEF WINDOWS}
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
         Try
          vLastResponse(vReplyString);
         Finally
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
      Finally
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
     End;
   End;
 Finally
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
 End;
End;

Procedure TRESTServicePooler.aCommandOther(AContext      : TIdContext;
                                           ARequestInfo  : TIdHTTPRequestInfo;
                                           AResponseInfo : TIdHTTPResponseInfo);
Var
 DWParams           : TDWParams;
 vReplyString,
 Cmd, JSONStr       : String;
 vTempServerMethods : TObject;
Begin
 vTempServerMethods := Nil;
 Cmd := ARequestInfo.RawHTTPCommand;
 If (vServerParams.HasAuthentication) Then
  Begin
   If Not ((ARequestInfo.AuthUsername = vServerParams.Username)  And
           (ARequestInfo.AuthPassword = vServerParams.Password)) Then
    Begin
     AResponseInfo.AuthRealm := AuthRealm;
     AResponseInfo.WriteContent;
     Exit;
    End;
  End;
 If (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')    OR
    (UpperCase(Copy (Cmd, 1, 6)) = 'DELETE') Then
  Begin
   DWParams := TServerUtils.ParseRESTURL (ARequestInfo.URI, VEncondig);
   If Assigned(vServerMethod) Then
    vTempServerMethods := vServerMethod.Create(Nil)
   Else
    JSONStr := GetPairJSON(-5, 'Server Methods Cannot Assigned');
   Try
    If Assigned(vLastRequest) Then
     Begin
      {$IFDEF WINDOWS}
       InitializeCriticalSection(vCriticalSection);
       EnterCriticalSection(vCriticalSection);
      {$ENDIF}
      Try
       vLastRequest(ARequestInfo.UserAgent + #13#10 +
                    ARequestInfo.RawHTTPCommand);
      Finally
       {$IFDEF WINDOWS}
        LeaveCriticalSection(vCriticalSection);
        DeleteCriticalSection(vCriticalSection);
       {$ENDIF}
      End;
     End;
    If Assigned(vServerMethod) Then
     Begin
      If vTempServerMethods <> Nil Then
       Begin
        If UpperCase(Copy (Cmd, 1, 3)) = 'PUT' Then
         TServerMethods(vTempServerMethods).OnReplyEvent(sePUT, '', DWParams, JSONStr);
        If UpperCase(Copy (Cmd, 1, 6)) = 'DELETE' Then
         TServerMethods(vTempServerMethods).OnReplyEvent(seDELETE, '', DWParams, JSONStr);
       End;
     End;
    Try
     vReplyString                    := Format(TValueDisp, ['', JSONStr]);
     AResponseInfo.FreeContentStream := True;
     AResponseInfo.ContentStream     := TStringStream.Create(vReplyString);
     AResponseInfo.ContentStream.Position := 0;
     AResponseInfo.ContentLength     := AResponseInfo.ContentStream.Size;
     AResponseInfo.WriteHeader;
    Finally
    End;
    If Assigned(vLastResponse) Then
     Begin
      {$IFDEF WINDOWS}
       InitializeCriticalSection(vCriticalSection);
       EnterCriticalSection(vCriticalSection);
      {$ENDIF}
      Try
       vLastResponse(DecodeStrings(JSONStr{$IFDEF FPC}, csUndefined{$ENDIF}));
      Finally
       {$IFDEF WINDOWS}
        LeaveCriticalSection(vCriticalSection);
        DeleteCriticalSection(vCriticalSection);
       {$ENDIF}
      End;
     End;
    AResponseInfo.WriteContent;
   Finally
    If Assigned(vServerMethod) Then
     vTempServerMethods.Free;
   End;
  End;
end;

Constructor TRESTServicePooler.Create(AOwner: TComponent);
Begin
 Inherited;
 vProxyOptions                   := TProxyOptions.Create;
 HTTPServer                      := TIdHTTPServer.Create(Nil);
 lHandler                        := TIdServerIOHandlerSSLOpenSSL.Create;
 {$IFDEF FPC}
 HTTPServer.OnCommandGet         := @aCommandGet;
 HTTPServer.OnCommandOther       := @aCommandOther;
 {$ELSE}
 HTTPServer.OnCommandGet         := aCommandGet;
 HTTPServer.OnCommandOther       := aCommandOther;
 {$ENDIF}
 vServerParams                   := TServerParams.Create(Self);
 vActive                         := False;
 vServerParams.HasAuthentication := True;
 vServerParams.UserName          := 'testserver';
 vServerParams.Password          := 'testserver';
 vServerContext                  := 'restdataware';
 VEncondig                       := esUtf8;
 vServicePort                    := 8082;
End;

Destructor TRESTServicePooler.Destroy;
Begin
 vProxyOptions.Free;
 HTTPServer.Active := False;
 HTTPServer.Free;
 vServerParams.Free;
 lHandler.Free;
 Inherited;
End;

Function TRESTServicePooler.GetSecure : Boolean;
Begin
 Result:= vActive And (HTTPServer.IOHandler is TIdServerIOHandlerSSLBase);
End;

Procedure TRESTServicePooler.GetSSLPassWord(var Password: String);
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
      lHandler.SSLOptions.SSLVersions           :=aSSLVersions;
      {$IFDEF FPC}
      lHandler.OnGetPassword                    := @GetSSLPassword;
      lHandler.OnVerifyPeer                     := @SSLVerifyPeer;
      {$ELSE}
      lHandler.OnGetPassword                    := GetSSLPassword;
      lHandler.OnVerifyPeer                     := SSLVerifyPeer;
      {$ENDIF}
      lHandler.SSLOptions.CertFile              := ASSLCertFile;
      lHandler.SSLOptions.KeyFile               := ASSLPrivateKeyFile;
      lHandler.SSLOptions.VerifyMode            := vSSLVerifyMode;
      lHandler.SSLOptions.VerifyDepth           := vSSLVerifyDepth;
      HTTPServer.IOHandler := lHandler;
     End
    Else
     HTTPServer.IOHandler  := Nil;
    HTTPServer.DefaultPort := vServicePort;
    HTTPServer.Active      := True;
   Except
    On E : Exception do
     Begin
      Raise Exception.Create(PChar(E.Message));
     End;
   End;
  End
 Else If Not(Value) Then
  HTTPServer.Active := False;
 vActive := HTTPServer.Active;
End;


Procedure TRESTServicePooler.SetServerMethod(Value : TComponentClass);
Begin
 If (Value.ClassParent      = TServerMethods) Or
    (Value                  = TServerMethods) Then
  Begin
   vServerMethod     := Value;
   vServerBaseMethod := TServerMethods;
  End
 Else If (Value.ClassParent = TServerMethodDatamodule) Or
         (Value             = TServerMethodDatamodule) Then
  Begin
   vServerMethod := Value;
   vServerBaseMethod := TServerMethodDatamodule;
  End;
End;

function TRESTServicePooler.SSLVerifyPeer(Certificate: TIdX509; AOk: Boolean;
  ADepth, AError: Integer): Boolean;
begin
  if ADepth = 0 then
  begin
    Result := AOk;
  end
  else
  begin
    Result := True;
  end
end;

{TThread_Request}
constructor TThread_Request.Create;
begin
inherited Create(True);
FHttpRequest:=TIdHTTP.Create(NIL);
FreeOnTerminate := True;
vTransparentProxy               := TIdProxyConnectionInfo.Create;
//RBody :=TStringStream.Create;
Params := TDWParams.Create;
end;

destructor TThread_Request.Destroy; //override;
begin
  FHttpRequest.Free;
  //RBody.free;
  Params.Free;
  //vTransparentProxy.Free;
  //vTransparentProxy:=nil;
  inherited Destroy;

end;


Procedure TThread_Request.SetParams(HttpRequest:TIdHTTP);
Begin
 HttpRequest.Request.BasicAuthentication := vAuthentication;
 If HttpRequest.Request.BasicAuthentication Then
  Begin
   If HttpRequest.Request.Authentication = Nil Then
    HttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
   HttpRequest.Request.Authentication.Password := vPassword;
   HttpRequest.Request.Authentication.Username := vUserName;
  End;
 HttpRequest.ProxyParams := vTransparentProxy;
 HttpRequest.ReadTimeout := vRequestTimeout;
End;

Function TThread_Request.GetHttpRequest : TIdHTTP;
Begin
 Result := FHttpRequest;
End;

procedure TThread_Request.Execute;
Var
 SResult,
 vResult,
 vURL,
 vTpRequest    : String;
 vResultParams : TMemoryStream;
 StringStream  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 ss            : TStringStream;
 {$IF Defined(ANDROID) OR Defined(IOS)} //Alterado para IOS Brito
 Procedure SetData( InputValue     : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue   : TJsonObject;
  bJsonOBJTemp : TJSONArray;
  JSONParam,
  JSONParamNew : TJSONParam;
  A, InitPos   : Integer;
  vValue,
  vTempValue   : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Exit;
  Try
   InitPos    := Pos('"RESULT":[', InputValue) + 10;
   vTempValue := Copy(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If Params <> Nil Then
    Begin
      bJsonValue:= TJSONObject.ParseJSONValue(InputValue) as TJSONObject;
      bJsonOBJTemp:= bJsonValue.GetValue('PARAMS') as TJSONArray;
     If bJsonOBJTemp.count > 0 Then
      Begin
       For A := 0 To bJsonValue.count -1 Do
        Begin
         bJsonOBJ :=  bJsonOBJTemp.get(A) as TJSONObject;
         If bJsonOBJ.count = 0 Then
          Continue;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := stringreplace(bJsonOBJ.pairs[4].JsonString.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]);
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.getvalue('ValueType').value);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.getvalue('Direction').value);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.GetValue('Encoded').value);
          If JSONParam.Encoded Then
           DecodeStrings(stringreplace(bJsonOBJ.pairs[4].JsonValue.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]) )
          Else
           vValue := stringreplace(bJsonOBJ.pairs[4].JsonValue.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]);
          JSONParam.SetValue(vValue, JSONParam.Encoded);
          bJsonOBJ.Free;
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value //, JSONParam.Encoded);
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
         Finally
          JSONParam.Free;
         End;
        End;
      End;
     bJsonValue.Free;
    End;
  Finally
   If vTempValue <> '' Then
    Begin
     ResultJSON := vTempValue;
    End;
  End;
 End;
 {$ELSE}
 Procedure SetData(InputValue     : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue   : TJsonObject;
  bJsonOBJTemp : TJSONArray;
  JSONParam,
  JSONParamNew : TJSONParam;
  A, InitPos   : Integer;
  vValue,
  vTempValue   : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Exit;
  Try
   InitPos    := Pos('"RESULT":[', InputValue) + 10;
   vTempValue := Copy(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If Params <> Nil Then
    Begin
     bJsonValue    := TJsonObject.Create(InputValue);
     InputValue    := '';
     bJsonOBJTemp  := bJsonValue.getJSONArray(bJsonValue.names.get(0).ToString); //TJSONArray.Create(bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
     If bJsonOBJTemp.length > 0 Then
      Begin
       For A := 0 To bJsonValue.names.length -1 Do
        Begin
         bJsonOBJ := bJsonOBJTemp.getJSONObject(A); //TJsonObject.Create(bJsonOBJTemp.get(A).ToString);
         If Length(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) = 0 Then
          Continue;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := bJsonOBJ.names.get(4).ToString;
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString);
          If JSONParam.Encoded Then
           vValue := DecodeStrings(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString{$IFDEF FPC}, csUndefined{$ENDIF})
          Else
           vValue := bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString;
          JSONParam.SetValue(vValue, JSONParam.Encoded);
//          bJsonOBJ.Free;
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value //, JSONParam.Encoded);
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
         Finally
          JSONParam.Free;
         End;
        End;
      End;
     bJsonValue.Free;
    End;
  Finally
   If vTempValue <> '' Then
    Begin
     ResultJSON := vTempValue;
    End;
  End;
 End;
 {$IFEND}
 Procedure SetParamsValues(DWParams : TDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I : Integer;
 Begin
  If DWParams <> Nil Then
   Begin
    For I := 0 To DWParams.Count -1 Do
     Begin
      If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob,
                                           ovMemo,   ovGraphic, ovFmtMemo,  ovOraBlob, ovOraClob] Then
       Begin
        ss := TStringStream.Create(DWParams.Items[I].ToJSON);
        SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, ss);
       End
      Else
       SendParamsData.AddFormField(DWParams.Items[I].ParamName, DWParams.Items[I].ToJSON);
     End;
   End;
 End;
Begin
 If Assigned(FCallSendEvent) Then
      {$IFDEF FPC}
       FCallSendEvent(EventData  ,
                        Params ,
                       EventType  ,
                       FCallBack  );
      {$ELSE}
       {$if CompilerVersion > 21}
        Synchronize(CurrentThread, Procedure ()
                                 Begin
                                     FCallSendEvent(EventData  ,
                                                      Params ,
                                                     EventType  ,
                                                     FCallBack  );
                                 End);
       {$ELSE}
               FCallSendEvent(EventData  ,
                        Params ,
                       EventType  ,
                       FCallBack  );
       {$IFEND}
      {$ENDIF}
     Terminate;
     exit;

 // INICIO   TThread_Request
 ss            := Nil;
 SendParams    := Nil;
 vResultParams := TMemoryStream.Create;
 If vTypeRequest = trHttp Then
  vTpRequest := 'http'
 Else If vTypeRequest = trHttps Then
  vTpRequest := 'https';
 SetParams(FHttpRequest);
 Try
  vURL := LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
  If vRSCharset = esUtf8 Then
   HttpRequest.Request.Charset := 'utf-8'
  Else If vRSCharset = esASCII Then
   HttpRequest.Request.Charset := 'ansi';
  Case EventType Of
   seGET :
    Begin
     HttpRequest.Request.ContentType := 'application/json';
     SResult := HttpRequest.Get(EventData);
     If Assigned(FCallBack) Then
      {$IFDEF FPC}
       FCallBack(SResult, Params);
      {$ELSE}
       {$if CompilerVersion > 21}
        Synchronize(CurrentThread, Procedure ()
                                 Begin
                                  FCallBack(SResult,Params)
                                 End);
       {$ELSE}
        FCallBack(SResult, Params);
       {$IFEND}
      {$ENDIF}
     Terminate;
    End;
   sePOST,
   sePUT,
   seDELETE :
    Begin;
     If EventType = sePOST Then
      Begin
       If Params <> Nil Then
        Begin
         SendParams := TIdMultiPartFormDataStream.Create;
         SetParamsValues(Params, SendParams);
         HttpRequest.Request.ContentType     := 'application/x-www-form-urlencoded';
         HttpRequest.Request.ContentEncoding := 'multipart/form-data';
         StringStream          := TStringStream.Create('');
         HttpRequest.Post(vURL, SendParams, StringStream);
         StringStream.Position := 0;
        End
       Else
        Begin
         HttpRequest.Request.ContentType := 'application/json';
         HttpRequest.Request.ContentEncoding := '';
         vResult      := HttpRequest.Get(EventData);
         StringStream := TStringStream.Create(vResult);
        End;
//       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       Try
        SetData(StringStream.DataString, Params, SResult);
        If Assigned(FCallBack) Then
         {$IFDEF FPC}
          FCallBack(SResult, Params);
         {$ELSE}
          {$if CompilerVersion > 21}
           Synchronize(CurrentThread, Procedure
                                      Begin
                                       FCallBack(SResult,Params)
                                      End);
          {$ELSE}
           FCallBack(SResult, Params);
          {$IFEND}
         {$ENDIF}
        Terminate;
       Finally
        StringStream.Free;
       End;
      End
     Else If EventType = sePUT Then
      Begin
       If SendParams = Nil Then
        SendParams := TIdMultiPartFormDataStream.Create;
       HttpRequest.Request.ContentType := 'application/x-www-form-urlencoded';
       StringStream  := TStringStream.Create('');
       HttpRequest.Post(vURL, SendParams, StringStream);
       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       Try
        SetData(StringStream.DataString, Params, SResult);
        If Assigned(FCallBack) Then
         {$IFDEF FPC}
          FCallBack(SResult, Params);
         {$ELSE}
          {$if CompilerVersion > 21}
           Synchronize(CurrentThread, Procedure
                                      Begin
                                       FCallBack(SResult,Params)
                                      End);
          {$ELSE}
           FCallBack(SResult, Params);
          {$IFEND}
         {$ENDIF}
        Terminate;
       Finally
        StringStream.Free;
       End;
      End
     Else If EventType = seDELETE Then
      Begin
       Try
         HttpRequest.Request.ContentType := 'application/json';
         HttpRequest.Delete(vURL);
         SResult := GetPairJSON('OK', 'DELETE COMMAND OK');
         If Assigned(FCallBack) Then
          {$IFDEF FPC}
           FCallBack(SResult, Params);
          {$ELSE}
           {$if CompilerVersion > 21}
            Synchronize(CurrentThread, Procedure
                                       Begin
                                        FCallBack(SResult,Params)
                                       End);
           {$IFEND}
          {$ENDIF}
         Terminate;
       Except
        On e:exception Do
         Begin
          SResult := GetPairJSON('NOK', e.Message);
          If Assigned(FCallBack) Then
           {$IFDEF FPC}
            FCallBack(SResult, Params);
           {$ELSE}
            {$if CompilerVersion > 21}
             Synchronize(CurrentThread, Procedure
                                        Begin
                                         FCallBack(SResult,Params);
                                        End);
            {$IFEND}
           {$ENDIF}
          Terminate;
         End;
       End;
      End;
    End;
  End;
 Except
  On E : Exception Do
   Begin
    {Todo: Acrescentado}
    Raise Exception.Create(e.Message);
   End;
 End;
 vResultParams.Free;

end;


end.

