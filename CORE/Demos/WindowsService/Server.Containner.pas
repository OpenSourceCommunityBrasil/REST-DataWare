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
   Procedure ServiceCreate                   (Sender               : TObject);
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
  End;

Var
 RESTDWServer : TRESTDWServer;
 Threadvar remoteIP : AnsiString;   //Criar para retornar o IP do Cliente

Implementation

{$R *.dfm}

Uses Winapi.Windows;

Procedure ServiceController(CtrlCode: DWord); stdcall;
Begin
 RESTDWServer.Controller(CtrlCode);
End;

Function TRESTDWServer.GetServiceController: TServiceController;
Begin
 Result := ServiceController;
End;

Function TRESTDWServer.DoContinue: Boolean;
Begin
 Result := inherited;
 RESTServicePooler.Active := True;
End;

Procedure TRESTDWServer.DoInterrogate;
Begin
 Inherited;
End;

Function TRESTDWServer.DoPause: Boolean;
Begin
 RESTServicePooler.Active := False;
 Result := inherited;
End;

Function TRESTDWServer.DoStop: Boolean;
Begin
 RESTServicePooler.Active := False;
 Result := inherited;
End;

Procedure TRESTDWServer.ServiceCreate(Sender : TObject);
Begin
 Log := TStringList.Create;
 Application.ProcessMessages;
end;

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
end;

end.

