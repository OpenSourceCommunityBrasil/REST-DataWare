unit Server.Containner;

interface

uses System.SysUtils, System.Classes, Vcl.SvcMgr, DataSnap.DSProviderDataModuleAdapter,
     Datasnap.DSTCPServerTransport,   Datasnap.DSHTTPCommon, Datasnap.DSHTTP,
     Datasnap.DSServer, Datasnap.DSCommonServer, Datasnap.DSClientMetadata,
     Datasnap.DSHTTPServiceProxyDispatcher, Datasnap.DSProxyJavaAndroid,
     Datasnap.DSProxyJavaBlackBerry, Datasnap.DSProxyObjectiveCiOS,
     Datasnap.DSProxyCsharpSilverlight, Datasnap.DSProxyFreePascal_iOS,
     Datasnap.DSAuth, IPPeerServer, Datasnap.DSMetadata, Datasnap.DSServerMetadata,
     Datasnap.DSProxyJavaScript,Datasnap.DSReflect,Datasnap.DSNames,forms,
     Web.HTTPApp, Datasnap.DSHTTPWebBroker, Web.HTTPProd,Datasnap.DSSession,
     IdContext, System.JSON, Data.DBXCommon, IPPeerClient, Datasnap.DSCommon,
     Data.DB, Datasnap.DBClient, Datasnap.Win.MConnect, Datasnap.Win.SConnect, uConsts,
     URestPoolerDBMethod;

 Type
  TSimpleServerClass = class(TDSServerClass)
  Private
   FPersistentClass: TPersistentClass;
  Protected
   Function GetDSClass: TDSClass; override;
  Public
   Constructor Create(AOwner     : TComponent;
                      AServer    : TDSCustomServer;
                      AClass     : TPersistentClass;
                      ALifeCycle : String); Reintroduce; Overload;
 End;
 Procedure RegisterServerClasses(AOwner: TComponent; AServer: TDSServer);

 Type
  TRESTDWServer = Class(TService)
    DSServer                 : TDSServer;
    DSHTTPService1           : TDSHTTPService;
    DSServerClass1           : TDSServerClass;
    DSAuthenticationManager1 : TDSAuthenticationManager;
    Procedure ServiceCreate                   (Sender               : TObject);
    Procedure WebFileDispatcher1BeforeDispatch(Sender               : TObject;
                                               Const AFileName      : String;
                                               Request              : TWebRequest;
                                               Response             : TWebResponse;
                                               Var Handled          : Boolean);
    Procedure DSServerConnect                 (DSConnectEventObject : TDSConnectEventObject);
    Procedure DSServerDisconnect              (DSConnectEventObject : TDSConnectEventObject);
    Procedure DoParseAuthentication           (AContext             : TIdContext;
                                               Const AAuthType,
                                               AAuthData            : String;
                                               Var VUsername,
                                               VPassword            : String;
                                               Var VHandled         : Boolean);
    Procedure WebModuleBeforeDispatch         (Sender               : TObject;
                                               Request              : TWebRequest;
                                               Response             : TWebResponse;
                                               Var Handled          : Boolean);
    Procedure DSHTTPService1FormatResult      (Sender               : TObject;
                                               Var ResultVal        : TJSONValue;
                                               Const Command        : TDBXCommand;
                                               Var Handled          : Boolean);
    Procedure DSHTTPService1HTTPTrace         (Sender               : TObject;
                                               AContext             : TDSHTTPContext;
                                               ARequest             : TDSHTTPRequest;
                                               AResponse            : TDSHTTPResponse);
    Procedure DSServerClass1GetClass          (DSServerClass        : TDSServerClass;
                                               Var PersistentClass  : TPersistentClass);
    Procedure DSAuthenticationManager1UserAuthenticate(Sender       : TObject;
                                                       Const Protocol,
                                                       Context,
                                                       User,
                                                       Password     : String;
                                                       Var valid    : Boolean;
                                                       UserRoles    : TStrings);
  Private
   { Private declarations }
   LOG : TStrings;
  Protected
   Function  DoStop     : Boolean; Override;
   Function  DoPause    : Boolean; Override;
   Function  DoContinue : Boolean; Override;
   Procedure DoInterrogate;        Override;
  Public
   Function GetServiceController : TServiceController; Override;
   Function IsTokenValid(tk : String) : Boolean;
  End;

Var
 RESTDWServer : TRESTDWServer;
 Threadvar remoteIP : AnsiString;   //Criar para retornar o IP do Cliente

Implementation

{$R *.dfm}

Uses Winapi.Windows, DSServerClass, WebModuleUnit1, ServerMethodsUnit1;

Procedure ServiceController(CtrlCode: DWord); stdcall;
Begin
 RESTDWServer.Controller(CtrlCode);
End;

Function TRESTDWServer.GetServiceController: TServiceController;
Begin
 Result := ServiceController;
End;

Function TRESTDWServer.IsTokenValid(tk: string): boolean;
Begin
 Result := True;
End;

Function TRESTDWServer.DoContinue: Boolean;
Begin
 Result := inherited;
 DSHTTPService1.HttpPort := vPort;
 DSServer.Start;
End;

Procedure TRESTDWServer.DoInterrogate;
Begin
 Inherited;
End;

Procedure TRESTDWServer.DoParseAuthentication(AContext     : TIdContext;
                                              Const AAuthType,
                                              AAuthData    : String;
                                              var VUsername,
                                              VPassword    : String;
                                              Var VHandled : Boolean);
Begin
 VHandled := AAuthType.Equals('Bearer') and IsTokenValid(AAuthData);
End;

Function TRESTDWServer.DoPause: Boolean;
Begin
 DSServer.Stop;
 Result := inherited;
End;

Function TRESTDWServer.DoStop: Boolean;
Begin
 DSServer.Stop;
 Result := inherited;
End;

procedure TRESTDWServer.DSAuthenticationManager1UserAuthenticate(Sender         : TObject;
                                                                 Const Protocol,
                                                                 Context,
                                                                 User, Password : String;
                                                                 Var valid      : Boolean;
                                                                 UserRoles      : TStrings);
Begin
 //Adicionada Autenticação de Usuário
 valid := (((User = vUsername)     And
            (vUsername <> ''))     And
           ((Password = vPassword) And
            (vPassword <> '')));
End;

Procedure TRESTDWServer.DSHTTPService1FormatResult(Sender        : TObject;
                                                   Var ResultVal : TJSONValue;
                                                   Const Command : TDBXCommand;
                                                   Var Handled   : Boolean);
Var
 str : String;
Begin
 str:= Command.Text;
End;

Procedure TRESTDWServer.DSHTTPService1HTTPTrace(Sender    : TObject;
                                                AContext  : TDSHTTPContext;
                                                ARequest  : TDSHTTPRequest;
                                                AResponse : TDSHTTPResponse);
Begin
 remoteIP := (ARequest as TDSHTTPRequest).RemoteIP;
 If AResponse Is TDSHTTPResponseIndy Then
  (AResponse as TDSHTTPResponseIndy).ResponseInfo.CustomHeaders.AddValue('access-control-allow-origin', '*') ;
End;

Procedure TRESTDWServer.DSServerClass1GetClass(DSServerClass       : TDSServerClass;
                                               Var PersistentClass : TPersistentClass);
Begin
 PersistentClass := ServerMethodsUnit1.TServerMethods1;
End;

procedure TRESTDWServer.DSServerConnect(DSConnectEventObject : TDSConnectEventObject);
Begin
 TDSSessionManager.GetThreadSession.PutData('RemoteAddr', String(remoteIP));
End;

procedure TRESTDWServer.DSServerDisconnect(DSConnectEventObject : TDSConnectEventObject);
Begin
 remoteIP := '';
End;

Procedure TRESTDWServer.ServiceCreate(Sender : TObject);
Begin
 Log := TStringList.Create;
 Try
  RegisterServerClasses(Application, DSServer);
 Except
  On E :Exception Do
   Begin
    log.Add(e.Message) ;
    log.SaveToFile(LogFile);
   End;
 End;
 Try
  DSHTTPService1.HttpPort := vPort;
  DSServer.start;
 Except
  On E :Exception Do
   Begin
    log.Add(e.Message);
    log.SaveToFile(LogFile);
   End;
 End;
 Application.ProcessMessages;
end;

Procedure TRESTDWServer.WebFileDispatcher1BeforeDispatch(Sender          : TObject;
                                                         Const AFileName : String;
                                                         Request         : TWebRequest;
                                                         Response        : TWebResponse;
                                                         Var Handled     : Boolean);
Begin
 Request.WriteHeaders(200,'Access-Control-Allow-Origin','*') ;
End;

Procedure TRESTDWServer.WebModuleBeforeDispatch(Sender      : TObject;
                                                Request     : TWebRequest;
                                                Response    : TWebResponse;
                                                Var Handled : Boolean);
Begin
 Response.SetCustomHeader('Access-Control-Allow-Origin','*');
 If Trim(Request.GetFieldByName('Access-Control-Request-Headers')) <> '' then
  begin
   Response.SetCustomHeader('Access-Control-Allow-Headers', Request.GetFieldByName('Access-Control-Request-Headers'));
   Handled := True;
  End;
End;

Constructor TSimpleServerClass.Create(AOwner: TComponent;
                                      AServer: TDSCustomServer;
                                      AClass: TPersistentClass;
                                      ALifeCycle: String);
Begin
 Inherited Create(AOwner);
 FPersistentClass := AClass;
 Self.Server      := AServer;
 Self.LifeCycle   := ALifeCycle;
end;

Function TSimpleServerClass.GetDSClass: TDSClass;
Begin
 Result := TDSClass.Create(FPersistentClass, False);
End;

Procedure RegisterServerClasses(AOwner: TComponent; AServer: TDSServer);
begin
// TSimpleServerClass.Create(AOwner, AServer, TDataModule, TDSLifeCycle.Session);
end;

end.

