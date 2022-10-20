unit uRESTDWIcsBase;

{$I ..\..\Includes\uRESTDWPlataform.inc}

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
 A. Brito                   - Admin - Administrador do desenvolvimento.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

Uses
   System.SysUtils,
   System.Classes,
   Data.Db,
   Variants,
   system.SyncObjs,
   uRESTDWComponentEvents,
   uRESTDWBasicTypes,
   uRESTDWJSONObject,
   uRESTDWBasic,
   uRESTDWBasicDB,
   uRESTDWParams,
   uRESTDWBasicClass,
   uRESTDWComponentBase,
   uRESTDWCharset,
   uRESTDWConsts,
   uRESTDWEncodeClass,
   uRESTDWDataUtils,
   uRESTDWTools,
   OverbyteIcsWinSock,
   OverbyteIcsWSocket,
   OverbyteIcsWndControl,
   OverbyteIcsHttpAppServer,
   OverbyteIcsUtils,
   OverbyteIcsFormDataDecoder,
   OverbyteIcsMimeUtils,
   OverbyteIcsSSLEAY,
   OverbyteIcsHttpSrv;



Type

  TMyHttpConnection = class(THttpConnection)
  protected
  public
  end;

 TRESTDWIcsServicePooler = Class(TRESTServicePoolerBase)
 Private
  // HTTP Server
  HttpAppSrv       : TSslHttpServer;

  // SSL Params
  vSSLContext                       : TSslContext;
  vSSLRootCertFile,
  vSSLPrivateKeyFile,
  vSSLPrivateKeyPassword,
  vSSLCertFile                     : String;
  vSSLMethod                       : TSslVersionMethod;
  vSSLVerifyMode                   : TSslVerifyPeerModes;
  vSSLVerifyDepth                  : Integer;
  vSSLVerifyPeer                   : Boolean;
  vSSLCacheModes                   : TSslSessCacheModes;
  vSSLTimeout                      : Cardinal;
  vSSLUse                          : Boolean;
  vSSLCliCertMethod                : TSslCliCertMethod;

  // HTTP Params
  vSocketFamily                    : TSocketFamily;
  vMaxClients                      : Integer;
  vKeepAliveSec                    : Cardinal;
  vServiceTimeout                  : Integer;
  vBuffSize                        : Integer;
  vBandWidthLimit                  : Cardinal;
  vBandWidthSample                 : Cardinal;

  Procedure onDocumentReady         (Sender,
                                     Client             : TObject;
                                     Var Flags          : THttpGetFlag);

  Procedure SetActive               (Value              : Boolean);Override;
  Procedure EchoPooler              (ServerMethodsClass : TComponent;
                                     AContext           : TComponent;
                                     Var Pooler, MyIP   : String;
                                     AccessTag          : String;
                                     Var InvalidTag     : Boolean);Override;

  procedure SetSSL;
  procedure SetParams;
  procedure onPostedData(Sender: TObject; Client: TObject; ErrCode: Word);
  procedure ProcessDocument(Sender, Client: TObject; BodyStream : TStream);
  procedure onClientConnect(Sender, Client: TObject; Error: Word);
 Public
  Constructor Create                (AOwner           : TComponent);Override;
  Destructor  Destroy; override;
 Published
  //SSL Params
  Property SSLRootCertFile : String Read vSSLRootCertFile Write vSSLRootCertFile;
  Property SSLPrivateKeyFile : String Read vSSLPrivateKeyFile Write vSSLPrivateKeyFile;
  Property SSLPrivateKeyPassword : String Read vSSLPrivateKeyPassword Write vSSLPrivateKeyPassword;
  Property SSLCertFile : String Read vSSLCertFile Write vSSLCertFile;
  Property SSLMethod : TSslVersionMethod Read vSSLMethod Write vSSLMethod default sslBestVer;
  Property SSLVerifyMode : TSslVerifyPeerModes Read vSSLVerifyMode Write vSSLVerifyMode;
  Property SSLVerifyDepth : Integer Read vSSLVerifyDepth Write vSSLVerifyDepth default 9;
  Property SSLVerifyPeer : Boolean Read vSSLVerifyPeer Write vSSLVerifyPeer default false;
  Property SSLCacheModes : TSslSessCacheModes Read vSSLCacheModes Write vSSLCacheModes;
  Property SSLTimeout : Cardinal Read vSSLTimeout Write vSSLTimeout default 60000;
  Property SSLUse : Boolean Read vSSLUse Write vSSLUse default false;
  Property SSLCliCertMethod : TSslCliCertMethod Read vSSLCliCertMethod Write vSSLCliCertMethod;
  // HTTP Params
  Property SocketFamily : TSocketFamily Read vSocketFamily Write vSocketFamily default sfAny;
  Property MaxClients : Integer Read vMaxClients Write vMaxClients default 0;
  Property KeepAliveSec : Cardinal Read vKeepAliveSec Write vKeepAliveSec default 0;
  Property RequestTimeout : Integer Read vServiceTimeout Write vServiceTimeout default 60000;
  Property BuffSize : Integer Read vBuffSize Write vBuffSize default 5120;
  Property BandWidthLimit : Cardinal Read vBandWidthLimit Write vBandWidthLimit default 0;
  Property BandWidthSample : Cardinal Read vBandWidthSample Write vBandWidthSample default 1000;


End;






Implementation

Uses uRESTDWJSONInterface, Vcl.Dialogs, OverbyteIcsWSockBuf;

Procedure TRESTDWIcsServicePooler.SetSSL;
begin
  if Assigned(HttpAppSrv) then
  begin
    if vSSLUse then
    begin
      vSSLContext := TSslContext.Create(HttpAppSrv);

      vSSLContext.SslSessionTimeout := vSSLTimeout;
      vSSLContext.SslSessionCacheModes := vSSLCacheModes;
      vSSLContext.SslVerifyPeer := vSSLVerifyPeer;
      vSSLContext.SslVerifyDepth := vSSLVerifyDepth;
      vSSLContext.SslVerifyPeerModes := vSSLVerifyMode;
      vSSLContext.SslVersionMethod := vSSLMethod;
      vSSLContext.SslCertFile := vSSLCertFile;
      vSSLContext.SslPrivKeyFile := vSSLPrivateKeyFile;
      vSSLContext.SslPassPhrase := vSSLPrivateKeyPassword;

      //TODO
      vSSLContext.SslMaxVersion := TSslVerMethod.sslVerMax;
      vSSLContext.SslMinVersion := TSslVerMethod.sslVerSSL3;
      vSSLContext.SslCliSecurity := TSslCliSecurity.sslCliSecIgnore;
      vSSLContext.SslSecLevel := TSslSecLevel.sslSecLevelAny;

      HttpAppSrv.RootCA := vSSLRootCertFile;
      HttpAppSrv.SslContext := vSSLContext;

      HttpAppSrv.SslEnable := true;
    end
    else
    begin
      HttpAppSrv.SslContext := nil;
      HttpAppSrv.SslEnable := false;
    end;
    end
    else
      raise Exception.Create('No HTTP server found.');
end;

Procedure TRESTDWIcsServicePooler.SetParams;
begin
  if Assigned(HttpAppSrv) then
  begin
    HttpAppSrv.ClientClass := TMyHttpConnection;

    HttpAppSrv.SocketFamily := vSocketFamily;
    HttpAppSrv.MaxClients := vMaxClients;
    HttpAppSrv.KeepAliveTimeSec := vKeepAliveSec;

    if vServiceTimeout > 0 then
    begin
      HttpAppSrv.LingerOnOff := wsLingerOn;
      HttpAppSrv.LingerTimeout := vServiceTimeout;
    end
    else
    begin
      HttpAppSrv.LingerOnOff := wsLingerOff;
      HttpAppSrv.LingerTimeout := 0;
    end;

    HttpAppSrv.MaxBlkSize := vBuffSize;

 end
  else
    raise Exception.Create('No HTTP server found.');
end;


Constructor TRESTDWIcsServicePooler.Create(AOwner: TComponent);
Begin
  HttpAppSrv := TSslHttpServer.Create(nil);

  if Assigned(vSSLContext) then
    FreeAndNil(vSSLContext);

  HttpAppSrv.OnGetDocument     := onDocumentReady;
  HttpAppSrv.OnPostDocument    := onDocumentReady;
  HttpAppSrv.OnPutDocument     := onDocumentReady;
  HttpAppSrv.OnDeleteDocument  := onDocumentReady;
  HttpAppSrv.OnPatchDocument   := onDocumentReady;
  HttpAppSrv.OnPostedData      := onPostedData;
  HttpAppSrv.OnClientConnect   := onClientConnect;

  HttpAppSrv.DocDir := '';
  HttpAppSrv.TemplateDir := '';
  HttpAppSrv.DefaultDoc := '';

  vSSLMethod := sslBestVer;
  vSSLVerifyDepth := 9;
  vSSLVerifyPeer := false;
  vSSLTimeout := 60000;
  vSSLUse := false;
  vSocketFamily := sfAny;
  vMaxClients := 0;
  vKeepAliveSec := 0;
  vServiceTimeout := 60000;
  vBuffSize := 5120;
  vBandWidthLimit := 0;
  vBandWidthSample := 1000;

  Inherited;
End;

procedure TRESTDWIcsServicePooler.onClientConnect(Sender, Client: TObject; Error: Word);
var
  Remote: TMyHttpConnection;
begin
  Remote := Client as TMyHttpConnection;

  Remote.LineMode := true;

  Remote.LineLimit := 0;

  Remote.LineEnd :=  sLineBreak;
end;

Destructor TRESTDWIcsServicePooler.Destroy;
Begin
 Try
  If Active Then
   Begin
    If HttpAppSrv.ListenAllOK Then
     HttpAppSrv.Stop;
   End;
 Except
 End;
 If Assigned(HttpAppSrv) Then
 begin
  FreeAndNil(vSSLContext);
  FreeAndNil(HttpAppSrv);
 end;
 Inherited;
End;

Procedure TRESTDWIcsServicePooler.EchoPooler(ServerMethodsClass,
                                             AContext            : TComponent;
                                             Var Pooler,
                                             MyIP                : String;
                                             AccessTag           : String;
                                             Var InvalidTag      : Boolean);
Var
 Remote : THttpAppSrvConnection;
 I         : Integer;
Begin
 Inherited;

 InvalidTag := False;
 MyIP       := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If (ServerMethodsClass.Components[i].ClassType  = TRESTDWPoolerDB)  Or
        (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) Then
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
           Remote := THttpAppSrvConnection(AContext);
           MyIP := Remote.PeerAddr;
          End;
         Break;
        End;
      End;
    End;
  End;
 If MyIP = '' Then
  Raise Exception.Create(cInvalidPoolerName);
End;


procedure TRESTDWIcsServicePooler.onPostedData(Sender: TObject; Client: TObject; ErrCode: Word);
var
    Len     : Integer;
    Remote  : TMyHttpConnection;
    Stream  : TStringStream;
    RawData,
    RawDataTemp : AnsiString;
    lCount  : Integer;
begin
  Remote := TMyHttpConnection(Client);

  RawData := Remote.ReceiveStrA;

  Remote.PostedDataReceived;

  Stream := TStringStream.Create(RawData);

  Stream.Position := 0;

  ProcessDocument(Sender, Client, Stream);
end;


procedure TRESTDWIcsServicePooler.ProcessDocument(Sender,
                                                  Client     : TObject;
                                                  BodyStream : TStream);
Var
 Remote : TMyHttpConnection;
 sCharSet,
 vToken,
 ErrorMessage,
 vAuthRealm,
 vContentType,
 vResponseString : String;
 I,
 StatusCode      : Integer;
 ResultStream    : TStream;
 vResponseHeader : TStringList;
 mb              : TStringStream;
 vRedirect       : TRedirect;
 vParams         : TStringList;
 Flags: THttpGetFlag;

 Procedure WriteError;
 Begin
  mb                                   := TStringStream.Create(ErrorMessage{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  mb.Position                          := 0;
  Remote.DocStream := mb;
  Remote.AnswerStream(Flags,
                         IntToStr(StatusCode),
                         '',
                         '');
 End;

 Procedure DestroyComponents;
 Begin
  If Assigned(vResponseHeader) Then
   FreeAndNil(vResponseHeader);
  If Assigned(vParams) Then
   FreeAndNil(vParams);
 End;

 Procedure Redirect(Url : String);
 Begin
  Remote.WebRedirectURL := Url;
 End;

begin
  Remote := TMyHttpConnection(Client);

  if BodyStream = nil then
    BodyStream := TMemoryStream.Create;

  Flags := hgWillSendMySelf;

 vResponseHeader := TStringList.Create;
 vResponseString := '';
 @vRedirect     := @Redirect;
 Try
  If CORS Then
   Begin
    If CORS_CustomHeaders.Count > 0 Then
     Begin
      For I := 0 To CORS_CustomHeaders.Count -1 Do
       vResponseHeader.AddPair(CORS_CustomHeaders.Names[I], CORS_CustomHeaders.ValueFromIndex[I]);
     End
    Else
     vResponseHeader.AddPair('Access-Control-Allow-Origin','*');
   End;
  vToken       := Remote.AuthDigestUri;
  vAuthRealm   := Remote.AuthRealm;
  vContentType := Remote.RequestContentType;
  vParams      := TStringList.Create;
  vParams.Text := Remote.Params;


  If CommandExec  (TComponent(Remote),
                   RemoveBackslashCommands(Remote.Path),
                   Remote.Method + ' ' + Remote.Path,
                   vContentType,
                   Remote.PeerAddr,
                   Remote.RequestUserAgent,
                   Remote.AuthUserName,
                   Remote.AuthPassword,
                   vToken,
                   Remote.RequestHeader,
                   StrToInt(Remote.PeerPort),
                   Remote.RequestHeader,
                   vParams,
                   Remote.Params,
                   BodyStream,
                   vAuthRealm,
                   sCharSet,
                   ErrorMessage,
                   StatusCode,
                   vResponseHeader,
                   vResponseString,
                   ResultStream,
                   vRedirect) Then
   Begin
    Remote.AuthRealm   := vAuthRealm;
    If (vResponseString <> '')   Or
       (ErrorMessage    <> '')   Then
     Begin
      If Assigned(ResultStream)  Then
       FreeAndNil(ResultStream);
      If (vResponseString <> '') Then
       ResultStream  := TStringStream.Create(vResponseString)
      Else
       ResultStream  := TStringStream.Create(ErrorMessage);
     End;
    If Assigned(ResultStream)    Then
     Begin
      ResultStream.Position := 0;
      Remote.DocStream := ResultStream;
      Remote.AnswerStream(Flags,
                             IntToStr(StatusCode),
                             vContentType,
                             vResponseHeader.Text);
     End;
   End
  Else //Tratamento de Erros.
   Begin
    Remote.AuthRealm   := vAuthRealm;
    If (vResponseString <> '')   Or
       (ErrorMessage    <> '')   Then
     Begin
      If Assigned(ResultStream)  Then
       FreeAndNil(ResultStream);
      If (vResponseString <> '') Then
       ResultStream  := TStringStream.Create(vResponseString)
      Else
       ResultStream  := TStringStream.Create(ErrorMessage);
     End;
    If Assigned(ResultStream)    Then
     Begin
      ResultStream.Position := 0;
      Remote.DocStream := ResultStream;
      Remote.AnswerStream(Flags,
                             IntToStr(StatusCode),
                             vContentType,
                             vResponseHeader.Text);
     End;
   End;
 Finally
  DestroyComponents;
 End;

end;


Procedure TRESTDWIcsServicePooler.onDocumentReady(Sender,
                                              Client    : TObject;
                                              Var Flags : THttpGetFlag);
Var
 Remote : TMyHttpConnection;
begin
 Remote := Client as TMyHttpConnection;

 if not(Remote.RequestMethod in [THttpMethod.httpMethodGet, THttpMethod.httpMethodDelete]) then
   Flags := hgAcceptData
 else
   ProcessDocument(Sender, Client, nil);

End;

Procedure TRESTDWIcsServicePooler.SetActive(Value: Boolean);
Begin
 If (Value) Then
  Begin
   Try
    SetParams;

    SetSSL;

    If Not HttpAppSrv.ListenAllOK Then
     Begin
      HttpAppSrv.Port := IntToStr(ServicePort);
      If AuthenticationOptions.AuthorizationOption <> rdwAONone Then
       Begin
        Case AuthenticationOptions.AuthorizationOption Of
         rdwAOBasic  : HttpAppSrv.AuthTypes := [atBasic];
         rdwAOBearer,
         rdwAOToken,
         rdwOAuth    : Begin
                        HttpAppSrv.AuthTypes := [atDigest];
                       End;
        End;
       End
      Else
       HttpAppSrv.AuthTypes := [atNone];

      HttpAppSrv.Start;
     End;
   Except
    On E : Exception do
     Begin
      Raise Exception.Create(PChar(E.Message));
     End;
   End;
  End
 Else If Not(Value) Then
  Begin
   Try
    If HttpAppSrv.ListenAllOK Then
     HttpAppSrv.Stop;
   Except
   End;
  End;
 Inherited SetActive(Value);
End;


End.

