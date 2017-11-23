// Procurem os comentarios "Criar para retornar o IP do Cliente"
//para saber os códigos a acrescentar.
//Gilberto Rocha da Silva

unit WebModuleUnit1;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Datasnap.DSHTTPCommon,
  Datasnap.DSHTTPWebBroker, Datasnap.DSServer,
  Datasnap.DSAuth, IPPeerServer, Datasnap.DSCommonServer, Datasnap.DSHTTP,
  Datasnap.DSSession, Web.HTTPProd, URestPoolerDBMethod, uConsts;

type
  TWebModule1 = class(TWebModule)
    DSHTTPWebDispatcher1: TDSHTTPWebDispatcher;
    DSServer1: TDSServer;
    DSServerClass1: TDSServerClass;
    DSAuthenticationManager1: TDSAuthenticationManager;
    ServerFunctionInvoker: TPageProducer;
    WebFileDispatcher1: TWebFileDispatcher;
    DSRESTWebDispatcher1: TDSRESTWebDispatcher;
    procedure DSServerClass1GetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure DSServer1Connect(DSConnectEventObject: TDSConnectEventObject);
    procedure DSServer1Disconnect(DSConnectEventObject: TDSConnectEventObject);
    procedure DSAuthenticationManager1UserAuthenticate(Sender: TObject;
      const Protocol, Context, User, Password: string; var valid: Boolean;
      UserRoles: TStrings);
    procedure ServerFunctionInvokerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
  private
    { Private declarations }
   function AllowServerFunctionInvoker: Boolean;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;
  threadvar remoteIP : AnsiString;   //Criar para retornar o IP do Cliente

implementation

uses ServerMethodsUnit1, Web.WebReq;

{$R *.dfm}

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if (Request.InternalPathInfo = '') or (Request.InternalPathInfo = '/') then
   Response.Content := ServerFunctionInvoker.Content
  Else
   Response.SendRedirect(Request.InternalScriptName + '/');
end;

//Criar para retornar o IP do Cliente
procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
 remoteIP := Request.RemoteAddr;
end;

function TWebModule1.AllowServerFunctionInvoker: Boolean;
begin
  Result := (Request.RemoteAddr = '127.0.0.1') or
    (Request.RemoteAddr = '0:0:0:0:0:0:0:1') or (Request.RemoteAddr = '::1');
end;

procedure TWebModule1.DSAuthenticationManager1UserAuthenticate(Sender: TObject;
  const Protocol, Context, User, Password: string; var valid: Boolean;
  UserRoles: TStrings);
begin
 //Adicionada Autenticação de Usuário
  valid := (((User = vUsername)     And
            (vUsername <> ''))     And
           ((Password = vPassword) And
            (vPassword <> '')));
end;

//Criar para retornar o IP do Cliente
procedure TWebModule1.DSServer1Connect(
  DSConnectEventObject: TDSConnectEventObject);
begin
 TDSSessionManager.GetThreadSession.PutData('RemoteAddr', String(remoteIP));
end;

//Criar para retornar o IP do Cliente
procedure TWebModule1.DSServer1Disconnect(
  DSConnectEventObject: TDSConnectEventObject);
begin
 remoteIP := '';
end;

procedure TWebModule1.DSServerClass1GetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := ServerMethodsUnit1.TServerMethods1;
end;

procedure TWebModule1.ServerFunctionInvokerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if SameText(TagString, 'urlpath') then
    ReplaceText := string(Request.InternalScriptName)
  else if SameText(TagString, 'port') then
    ReplaceText := IntToStr(Request.ServerPort)
  else if SameText(TagString, 'host') then
    ReplaceText := string(Request.Host)
  else if SameText(TagString, 'classname') then
    ReplaceText := ServerMethodsUnit1.TServerMethods1.ClassName
  else if SameText(TagString, 'loginrequired') then
    if DSRESTWebDispatcher1.AuthenticationManager <> nil then
      ReplaceText := 'true'
    else
      ReplaceText := 'false'
  else if SameText(TagString, 'serverfunctionsjs') then
    ReplaceText := string(Request.InternalScriptName) + '/js/serverfunctions.js'
  else if SameText(TagString, 'servertime') then
    ReplaceText := DateTimeToStr(Now)
  else if SameText(TagString, 'serverfunctioninvoker') then
    if AllowServerFunctionInvoker then
      ReplaceText :=
      '<div><a href="' + string(Request.InternalScriptName) +
      '/ServerFunctionInvoker" target="_blank">Server Functions</a></div>'
    else
      ReplaceText := '';
end;

initialization
finalization
  Web.WebReq.FreeWebModules;

end.

