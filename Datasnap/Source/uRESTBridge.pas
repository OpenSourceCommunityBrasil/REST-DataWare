unit uRESTBridge;

interface

uses
 System.Classes, System.SysUtils, Datasnap.DSSession, IdSSLOpenSSL, IdSSL, IdHTTPWebBrokerBridge;

//WebBroker Componente para uso do Datasnap
Type
 TRESTBridge  = Class(TComponent)
 Private
  vDwServicePort          : Integer;
  lHandler                : TIdServerIOHandlerSSLOpenSSL;
  FServer                 : TObject;
  aSSLVersion             : TIdSSLVersion;
  ASSLPrivateKeyFile,
  ASSLPrivateKeyPassword,
  ASSLCertFile            : String;
  Procedure TerminateThreads;
  Procedure StartServer;
  Procedure StopServer;
  Function  GetActiveState : Boolean;
  Procedure SetActiveState(Value : Boolean);
  Procedure GetSSLPassWord(Var Password: String);
  Function  GetSecure : Boolean;
 Public
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                     //Destroy a Classe
 Published
  Property ServicePort           : Integer       Read vDwServicePort         Write vDwServicePort;
  Property Active                : Boolean       Read GetActiveState         Write SetActiveState;
  Property SSLPrivateKeyFile     : String        Read aSSLPrivateKeyFile     Write aSSLPrivateKeyFile;
  Property SSLPrivateKeyPassword : String        Read aSSLPrivateKeyPassword Write aSSLPrivateKeyPassword;
  Property SSLCertFile           : String        Read aSSLCertFile           Write aSSLCertFile;
  Property SSLVersion            : TIdSSLVersion Read aSSLVersion            Write aSSLVersion;
  Property Secure                : Boolean       Read GetSecure;
End;

Var
 FServer : TRESTBridge;

implementation

Constructor TRESTBridge.Create(AOwner: TComponent);
Begin
  inherited;
 lHandler    := TIdServerIOHandlerSSLOpenSSL.Create;
 FServer     := TIdHTTPWebBrokerBridge.Create(Nil);
 aSSLVersion := sslvSSLv23;
End;

Destructor TRESTBridge.Destroy;
Begin
 StopServer;
 lHandler.DisposeOf;
 FServer.Free; //Correção enviada por fabricio1970 no Forum.
 Inherited;
End;

Function TRESTBridge.GetActiveState: Boolean;
Begin
 Result := TIdHTTPWebBrokerBridge(FServer).Active;
End;

Procedure TRESTBridge.SetActiveState(Value : Boolean);
Begin
 StopServer;
 If Value Then
  StartServer;
End;

Function TRESTBridge.GetSecure : Boolean;
Begin
 Result:= TIdHTTPWebBrokerBridge(FServer).Active and (TIdHTTPWebBrokerBridge(FServer).IOHandler is TIdServerIOHandlerSSLBase);
End;

Procedure TRESTBridge.GetSSLPassWord(Var Password: String);
Begin
 Password := aSSLPrivateKeyPassword;
End;

Procedure TRESTBridge.StartServer;
Begin
 Try
  If Not TIdHTTPWebBrokerBridge(FServer).Active Then
   Begin
    If (ASSLPrivateKeyFile <> '')     And
       (ASSLPrivateKeyPassword <> '') And
       (ASSLCertFile <> '')           Then
     Begin
      lHandler.SSLOptions.Method                := aSSLVersion;
      lHandler.OnGetPassword                    := GetSSLPassword;
      lHandler.SSLOptions.CertFile              := ASSLCertFile;
      lHandler.SSLOptions.KeyFile               := ASSLPrivateKeyFile;
      TIdHTTPWebBrokerBridge(FServer).IOHandler := lHandler;
     End
    Else
     TIdHTTPWebBrokerBridge(FServer).IOHandler  := Nil;
    TIdHTTPWebBrokerBridge(FServer).Bindings.Clear;
    TIdHTTPWebBrokerBridge(FServer).DefaultPort := vDwServicePort;
    TIdHTTPWebBrokerBridge(FServer).Active      := True;
   End;
 Except
  On E : Exception do
   Begin
    Raise Exception.Create(PChar(E.Message));
   End;
 End;
End;

Procedure TRESTBridge.StopServer;
Begin
 If TIdHTTPWebBrokerBridge(FServer).Active Then
  Begin
   TerminateThreads;
   TIdHTTPWebBrokerBridge(FServer).Active := False;
   TIdHTTPWebBrokerBridge(FServer).Bindings.Clear;
  End;
End;

Procedure TRESTBridge.TerminateThreads;
Begin
 If TDSSessionManager.Instance <> Nil Then
  TDSSessionManager.Instance.TerminateAllSessions;
End;

Initialization
 FServer := TRESTBridge.Create(Nil);

Finalization
 FServer.DisposeOf;

end.
