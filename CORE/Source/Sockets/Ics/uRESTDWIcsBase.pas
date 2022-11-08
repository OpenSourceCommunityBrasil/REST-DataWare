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

// TODO 0
// Portar TODAS as classes;
// Portado TRESTServicePoolerBase;

// TODO 1
// Inserir outras propriedades do SSL no Pooler (SetHttpServerSSL);

// TODO 2
// Passar parâmetros do diretório, página e url padrão (SetParamsHttpConnection);

// TODO 3
// Portar AnonymousThread pra Thread (compatibilidade com Delphi antigo);

// TODO 4
// Portar a propriedade RequestTimeOut para dentro dos Sockets (remover no Pooler Base);

interface

Uses
  System.SysUtils,
  System.Classes,
  Data.Db,
  Variants,
  System.SyncObjs,
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
  OverbyteIcsHttpSrv, OverbyteIcsWSocketS;

Type

  TPoolerHttpConnection = class(THttpAppSrvConnection)
  protected
    RawData: AnsiString;
    RawDataLen: Integer;
  public
    destructor Destroy; override;
  end;

  TOnException = Procedure(Sender: TPoolerHttpConnection; E: ESocketException) Of Object;
  TOnServerStarted = Procedure(Sender: TObject) Of Object;
  TOnServerStopped = Procedure(Sender: TObject) Of Object;
  TOnClientConnect = Procedure(Sender: TPoolerHttpConnection; Error: Word) Of Object;
  TOnClientDisconnect = Procedure(Sender: TPoolerHttpConnection; Error: Word) Of Object;
  TOnDocumentReady = Procedure(Sender: TPoolerHttpConnection; Var Flags: THttpGetFlag)
    Of Object;
  TOnAnswered = Procedure(Sender: TPoolerHttpConnection) Of Object;
  TOnBlackListed = Procedure(IP, Port: string) Of Object;

  TRESTDWIcsServicePooler = Class(TRESTServicePoolerBase)
  Private
    // Events
    vOnException: TOnException;
    vOnServerStarted: TOnServerStarted;
    vOnServerStopped: TOnServerStopped;
    vOnClientConnect: TOnClientConnect;
    vOnClientDisconnect: TOnClientDisconnect;
    vOnDocumentReady: TOnDocumentReady;
    vOnAnswered: TOnAnswered;
    vOnBlackListed: TOnBlackListed;

    // HTTP Server
    HttpAppSrv: TSslHttpAppSrv;

    // SSL Params
    vSSLRootCertFile, vSSLPrivateKeyFile, vSSLPrivateKeyPassword, vSSLCertFile: String;
    vSSLMethod: TSslVersionMethod;
    vSSLVerifyMode: TSslVerifyPeerModes;
    vSSLVerifyDepth: Integer;
    vSSLVerifyPeer: Boolean;
    vSSLCacheModes: TSslSessCacheModes;
    vSSLTimeoutSec: Cardinal;
    vSSLUse: Boolean;
    vSSLCliCertMethod: TSslCliCertMethod;

    // HTTP Params
    vSocketFamily: TSocketFamily;
    vMaxClients: Integer;
    vKeepAliveSec: Cardinal;
    vServiceTimeout: Integer;
    vBuffSizeBytes: Integer;
    vBandWidthLimitBytes: Cardinal;
    vBandWidthSamplingBytes: Cardinal;
    vListenBacklog: Integer;

    // Security
    vIpBlackList: TStrings;
    procedure SetvIpBlackList(Lines: TStrings);

  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; override;

    // Document procedures
    Procedure onDocumentReadyServer(Sender: TObject; Var Flag: THttpGetFlag);
    procedure onPostedDataServer(Sender: TObject; ErrCode: Word);
    procedure ProcessDocument(Sender: TObject; iBodyStream: TStream; iFlag: THttpGetFlag);
    procedure onExceptionServer(Sender: TObject; E: ESocketException);
    procedure onServerStartedServer(Sender: TObject);
    procedure onServerStoppedServer(Sender: TObject);
    procedure onClientDisconnectServer(Sender: TObject; Client: TObject; Error: Word);
    procedure onAnsweredServer(Sender: TObject);

    // Prepare procedures
    procedure SetHttpServerSSL;
    procedure SetHttpServerParams;
    procedure SetSocketServerParams;
    procedure SetHttpConnectionParams(Remote: TPoolerHttpConnection);
    procedure onClientConnectServer(Sender: TObject; Client: TObject; Error: Word);

    // Misc Procedures
    Procedure SetActive(Value: Boolean); Override;
    Procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      Var Pooler, MyIP: String; AccessTag: String; Var InvalidTag: Boolean); Override;

  Published
    // Events
    Property onException: TOnException Read vOnException Write vOnException;
    Property onServerStarted: TOnServerStarted Read vOnServerStarted
      Write vOnServerStarted;
    Property onServerStopped: TOnServerStopped Read vOnServerStopped
      Write vOnServerStopped;
    Property onClientConnect: TOnClientConnect Read vOnClientConnect
      Write vOnClientConnect;
    Property onClientDisconnect: TOnClientDisconnect Read vOnClientDisconnect
      Write vOnClientDisconnect;
    Property onDocumentReady: TOnDocumentReady Read vOnDocumentReady
      Write vOnDocumentReady;
    Property onAnswered: TOnAnswered Read vOnAnswered Write vOnAnswered;
    Property onBlackListed: TOnBlackListed Read vOnBlackListed Write vOnBlackListed;

    // SSL Params
    Property SSLRootCertFile: String Read vSSLRootCertFile Write vSSLRootCertFile;
    Property SSLPrivateKeyFile: String Read vSSLPrivateKeyFile Write vSSLPrivateKeyFile;
    Property SSLPrivateKeyPassword: String Read vSSLPrivateKeyPassword
      Write vSSLPrivateKeyPassword;
    Property SSLCertFile: String Read vSSLCertFile Write vSSLCertFile;
    Property SSLMethod: TSslVersionMethod Read vSSLMethod Write vSSLMethod
      default sslBestVer;
    Property SSLVerifyMode: TSslVerifyPeerModes Read vSSLVerifyMode Write vSSLVerifyMode;
    Property SSLVerifyDepth: Integer Read vSSLVerifyDepth Write vSSLVerifyDepth default 9;
    Property SSLVerifyPeer: Boolean Read vSSLVerifyPeer Write vSSLVerifyPeer
      default false;
    Property SSLCacheModes: TSslSessCacheModes Read vSSLCacheModes Write vSSLCacheModes;
    Property SSLTimeoutSec: Cardinal Read vSSLTimeoutSec Write vSSLTimeoutSec default 60;

    // SSL TimeOut in Seconds
    Property SSLUse: Boolean Read vSSLUse Write vSSLUse default false;
    Property SSLCliCertMethod: TSslCliCertMethod Read vSSLCliCertMethod
      Write vSSLCliCertMethod;

    // HTTP Params
    Property SocketFamily: TSocketFamily Read vSocketFamily Write vSocketFamily
      default sfAny;
    Property MaxClients: Integer Read vMaxClients Write vMaxClients default 0;
    Property KeepAliveSec: Cardinal Read vKeepAliveSec Write vKeepAliveSec default 0;
    Property RequestTimeout: Integer Read vServiceTimeout Write vServiceTimeout
      default 60; // Connection TimeOut in Seconds
    Property BuffSizeBytes: Integer Read vBuffSizeBytes Write vBuffSizeBytes
      default 262144; // 256kb Default
    Property BandWidthLimitBytes: Cardinal Read vBandWidthLimitBytes
      Write vBandWidthLimitBytes default 0;
    Property BandWidthSamplingBytes: Cardinal Read vBandWidthSamplingBytes
      Write vBandWidthSamplingBytes default 1000;
    Property ListenBacklog: Integer Read vListenBacklog Write vListenBacklog default 50;

    // Secutiry
    Property IpBlackList: TStrings Read vIpBlackList Write SetvIpBlackList;
  End;

const
  cIcsHTTPServerNotFound = 'No HTTP server found.';

Implementation

Uses uRESTDWJSONInterface, Vcl.Dialogs, OverbyteIcsWSockBuf, Vcl.Forms;

Procedure TRESTDWIcsServicePooler.SetHttpServerSSL;
begin
  if Assigned(HttpAppSrv) then
  begin
    if vSSLUse then
    begin
      HttpAppSrv.SSLContext := TSslContext.Create(HttpAppSrv);

      HttpAppSrv.SSLContext.SslSessionTimeout := vSSLTimeoutSec;
      HttpAppSrv.SSLContext.SslSessionCacheModes := vSSLCacheModes;
      HttpAppSrv.SSLContext.SSLVerifyPeer := vSSLVerifyPeer;
      HttpAppSrv.SSLContext.SSLVerifyDepth := vSSLVerifyDepth;
      HttpAppSrv.SSLContext.SslVerifyPeerModes := vSSLVerifyMode;
      HttpAppSrv.SSLContext.SslVersionMethod := vSSLMethod;
      HttpAppSrv.SSLContext.SSLCertFile := vSSLCertFile;
      HttpAppSrv.SSLContext.SslPrivKeyFile := vSSLPrivateKeyFile;
      HttpAppSrv.SSLContext.SslPassPhrase := vSSLPrivateKeyPassword;

      // TODO 1
      HttpAppSrv.SSLContext.SslMaxVersion := TSslVerMethod.sslVerMax;
      HttpAppSrv.SSLContext.SslMinVersion := TSslVerMethod.sslVerSSL3;
      HttpAppSrv.SSLContext.SslCliSecurity := TSslCliSecurity.sslCliSecIgnore;
      HttpAppSrv.SSLContext.SslSecLevel := TSslSecLevel.sslSecLevelAny;

      HttpAppSrv.RootCA := vSSLRootCertFile;

      HttpAppSrv.SslEnable := true;
    end
    else
    begin
      HttpAppSrv.SSLContext := nil;
      HttpAppSrv.SslEnable := false;
    end;
  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.SetSocketServerParams;
begin
  HttpAppSrv.WSocketServer.BufSize := vBuffSizeBytes;
  HttpAppSrv.WSocketServer.SocketRcvBufSize := vBuffSizeBytes;
  HttpAppSrv.WSocketServer.SocketSndBufSize := vBuffSizeBytes;
end;

Procedure TRESTDWIcsServicePooler.SetHttpServerParams;
begin
  if Assigned(HttpAppSrv) then
  begin
    HttpAppSrv.ClientClass := TPoolerHttpConnection;

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

    HttpAppSrv.MaxBlkSize := vBuffSizeBytes;

    HttpAppSrv.BandwidthLimit := vBandWidthLimitBytes;
    HttpAppSrv.BandwidthSampling := vBandWidthSamplingBytes;

    HttpAppSrv.ListenBacklog := vListenBacklog;

    HttpAppSrv.onClientConnect := onClientConnectServer;
    HttpAppSrv.onClientDisconnect := onClientDisconnectServer;
    HttpAppSrv.onServerStarted := onServerStartedServer;
    HttpAppSrv.onServerStopped := onServerStoppedServer;
  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.onExceptionServer(Sender: TObject; E: ESocketException);
var
  Remote: TPoolerHttpConnection;
begin
  if Assigned(vOnException) then
  begin
    Remote := Sender as TPoolerHttpConnection;

    vOnException(Remote, E);
  end;
end;

procedure TRESTDWIcsServicePooler.onServerStartedServer(Sender: TObject);
begin
  if Assigned(vOnServerStarted) then
  begin
    vOnServerStarted(Sender);
  end;
end;

procedure TRESTDWIcsServicePooler.onServerStoppedServer(Sender: TObject);
begin
  if Assigned(vOnServerStopped) then
  begin
    vOnServerStopped(Sender);
  end;
end;

procedure TRESTDWIcsServicePooler.SetvIpBlackList(Lines: TStrings);
begin
  vIpBlackList.Assign(Lines);
end;

procedure TRESTDWIcsServicePooler.SetHttpConnectionParams(Remote: TPoolerHttpConnection);
begin
  Remote.LineMode := true;
  Remote.LineLimit := MaxInt;
  Remote.LineEnd := sLineBreak;

  Remote.RawData := '';
  Remote.RawDataLen := 0;

  Remote.OnGetDocument := onDocumentReadyServer;
  Remote.OnPostDocument := onDocumentReadyServer;
  Remote.OnPutDocument := onDocumentReadyServer;
  Remote.OnDeleteDocument := onDocumentReadyServer;
  Remote.OnPatchDocument := onDocumentReadyServer;
  Remote.onPostedData := onPostedDataServer;
  Remote.onException := onExceptionServer;
  Remote.OnAfterAnswer := onAnsweredServer;
end;

Constructor TRESTDWIcsServicePooler.Create(AOwner: TComponent);
Begin
  HttpAppSrv := TSslHttpAppSrv.Create(nil);

  If Assigned(HttpAppSrv.SSLContext) Then
    HttpAppSrv.SSLContext.Free;

  // TODO 2
  HttpAppSrv.DocDir := '';
  HttpAppSrv.TemplateDir := '';
  HttpAppSrv.DefaultDoc := '';

  vSSLMethod := sslBestVer;
  vSSLVerifyDepth := 9;
  vSSLVerifyPeer := false;
  vSSLTimeoutSec := 60; // SSL TimeOut in Seconds
  vSSLUse := false;
  vSocketFamily := sfAny;

  vMaxClients := 0;
  vKeepAliveSec := 0;
  vServiceTimeout := 60; // TimeOut in Seconds
  vBuffSizeBytes := 262144; // 256kb Default
  vBandWidthLimitBytes := 0;
  vBandWidthSamplingBytes := 1000;
  vListenBacklog := 50;

  vIpBlackList := TStringList.Create;
  vIpBlackList.Clear;

  Inherited;
End;

procedure TRESTDWIcsServicePooler.onAnsweredServer(Sender: TObject);
var
  Remote: TPoolerHttpConnection;
begin
  if Assigned(vOnAnswered) then
  begin
    Remote := Sender as TPoolerHttpConnection;

    vOnAnswered(Remote);
  end;
end;

procedure TRESTDWIcsServicePooler.onClientConnectServer(Sender: TObject; Client: TObject;
  Error: Word);
var
  Remote: TPoolerHttpConnection;
  i: Integer;
begin
  Remote := Client as TPoolerHttpConnection;

  // Blocking the black list IPs
  if vIpBlackList.Count > 0 then
  begin
    if vIpBlackList.IndexOf(Remote.PeerAddr) <> -1 then
    begin
      Remote.Close;

      if Assigned(vOnBlackListed) then
        vOnBlackListed(Remote.PeerAddr, Remote.PeerPort);
    end;
  end;

  SetHttpConnectionParams(Remote);

  if Assigned(vOnClientConnect) then
    vOnClientConnect(Remote, Error);
end;

procedure TRESTDWIcsServicePooler.onClientDisconnectServer(Sender: TObject;
  Client: TObject; Error: Word);
var
  Remote: TPoolerHttpConnection;
begin

  Remote := Client as TPoolerHttpConnection;

  if Assigned(vOnClientDisconnect) then
  begin
    vOnClientDisconnect(Remote, Error);
  end;

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
    If Assigned(HttpAppSrv.SSLContext) Then
      HttpAppSrv.SSLContext.Free;
    FreeAndNil(HttpAppSrv);
  end;
  Inherited;
End;

Procedure TRESTDWIcsServicePooler.EchoPooler(ServerMethodsClass, AContext: TComponent;
  Var Pooler, MyIP: String; AccessTag: String; Var InvalidTag: Boolean);
Var
  Remote: THttpAppSrvConnection;
  i: Integer;
Begin
  Inherited;

  InvalidTag := false;
  MyIP := '';
  If ServerMethodsClass <> Nil Then
  Begin
    For i := 0 To ServerMethodsClass.ComponentCount - 1 Do
    Begin
      If (ServerMethodsClass.Components[i].ClassType = TRESTDWPoolerDB) Or
        (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) Then
      Begin
        If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName,
          ServerMethodsClass.Components[i].Name]) Then
        Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <>
              AccessTag Then
            Begin
              InvalidTag := true;
              exit;
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

procedure TRESTDWIcsServicePooler.onPostedDataServer(Sender: TObject; ErrCode: Word);
var
  Remote: TPoolerHttpConnection;
  Len: Integer;
  Stream: TStringStream;
  lCount: Integer;
  RawDataTemp: AnsiString;
begin
  Remote := Sender as TPoolerHttpConnection;

  repeat
  begin
    SetLength(RawDataTemp, Remote.BufSize);

    lCount := Remote.Receive(@RawDataTemp[1], Remote.BufSize);

    if lCount > 0 then
    begin
      SetLength(RawDataTemp, lCount);
      Remote.RawData := Remote.RawData + RawDataTemp;
      Remote.RawDataLen := Remote.RawDataLen + lCount;
    end
    else
      lCount := 0;

    SetLength(RawDataTemp, 0);
  end
  until lCount <= 0;

  if Remote.RequestContentLength = Remote.RawDataLen then
  begin
    try
      Remote.PostedDataReceived;

      Stream := TStringStream.Create(Remote.RawData);

      Stream.Position := 0;

      ProcessDocument(Sender, Stream, hgWillSendMySelf);
    finally
      FreeAndNil(Stream);
    end;
  end;
end;

procedure TRESTDWIcsServicePooler.ProcessDocument(Sender: TObject; iBodyStream: TStream;
  iFlag: THttpGetFlag);
var
  BodyStream: TStream;
begin
  if iBodyStream = nil then
    iBodyStream := TMemoryStream.Create;

  BodyStream := TStringStream.Create;

  BodyStream.CopyFrom(iBodyStream, iBodyStream.Size);

  BodyStream.Position := 0;

  TThread.CreateAnonymousThread(
    procedure
    Var
      Remote: TPoolerHttpConnection;
      sCharSet, vToken, ErrorMessage, vAuthRealm, vContentType, vResponseString: String;
      i, StatusCode: Integer;
      ResultStream: TStream;
      vResponseHeader: TStringList;
      mb: TStringStream;
      vRedirect: TRedirect;
      vParams: TStringList;

      Procedure WriteError;
      Begin
        mb := TStringStream.Create(ErrorMessage{$IF CompilerVersion > 21},
          TEncoding.UTF8{$IFEND});
        mb.Position := 0;
        Remote.DocStream := mb;
        Remote.AnswerStream(iFlag, IntToStr(StatusCode), '', '');
      End;

      Procedure DestroyComponents;
      Begin
        If Assigned(vResponseHeader) Then
          FreeAndNil(vResponseHeader);

        If Assigned(vParams) Then
          FreeAndNil(vParams);

        if Assigned(BodyStream) then
          FreeAndNil(BodyStream);
      End;

      Procedure Redirect(Url: String);
      Begin
        Remote.WebRedirectURL := Url;
      End;

    begin
      try
        Remote := Sender as TPoolerHttpConnection;

        vResponseHeader := TStringList.Create;
        vResponseString := '';
        @vRedirect := @Redirect;

        If CORS Then
        Begin
          If CORS_CustomHeaders.Count > 0 Then
          Begin
            For i := 0 To CORS_CustomHeaders.Count - 1 Do
              vResponseHeader.AddPair(CORS_CustomHeaders.Names[i],
                CORS_CustomHeaders.ValueFromIndex[i]);
          End
          Else
            vResponseHeader.AddPair('Access-Control-Allow-Origin', '*');
        End;
        vToken := Remote.AuthDigestUri;
        vAuthRealm := Remote.AuthRealm;
        vContentType := Remote.RequestContentType;
        vParams := TStringList.Create;
        vParams.Text := Remote.Params;

        If CommandExec(TComponent(Remote), RemoveBackslashCommands(Remote.Path),
          Remote.Method + ' ' + Remote.Path, vContentType, Remote.PeerAddr,
          Remote.RequestUserAgent, Remote.AuthUserName, Remote.AuthPassword, vToken,
          Remote.RequestHeader, StrToInt(Remote.PeerPort), Remote.RequestHeader, vParams,
          Remote.Params, BodyStream, vAuthRealm, sCharSet, ErrorMessage, StatusCode,
          vResponseHeader, vResponseString, ResultStream, vRedirect) Then
        Begin
          Remote.AuthRealm := vAuthRealm;
          If (vResponseString <> '') Or (ErrorMessage <> '') Then
          Begin
            If Assigned(ResultStream) Then
              FreeAndNil(ResultStream);
            If (vResponseString <> '') Then
              ResultStream := TStringStream.Create(vResponseString)
            Else
              ResultStream := TStringStream.Create(ErrorMessage);
          End;
          If Assigned(ResultStream) Then
          Begin
            ResultStream.Position := 0;
            Remote.DocStream := ResultStream;
            Remote.AnswerStream(iFlag, IntToStr(StatusCode), vContentType,
              vResponseHeader.Text);
          End;
        End
        Else // Tratamento de Erros.
        Begin
          Remote.AuthRealm := vAuthRealm;
          If (vResponseString <> '') Or (ErrorMessage <> '') Then
          Begin
            If Assigned(ResultStream) Then
              FreeAndNil(ResultStream);
            If (vResponseString <> '') Then
              ResultStream := TStringStream.Create(vResponseString)
            Else
              ResultStream := TStringStream.Create(ErrorMessage);
          End;
          If Assigned(ResultStream) Then
          Begin
            ResultStream.Position := 0;
            Remote.DocStream := ResultStream;
            Remote.AnswerStream(iFlag, IntToStr(StatusCode), vContentType,
              vResponseHeader.Text);
          End;
        End;
      finally
        DestroyComponents;
      end;

    end).Start;

end;

Procedure TRESTDWIcsServicePooler.onDocumentReadyServer(Sender: TObject;
Var Flag: THttpGetFlag);
var
  Remote: TPoolerHttpConnection;
begin
  Remote := Sender as TPoolerHttpConnection;

  if Assigned(vOnDocumentReady) then
    vOnDocumentReady(Remote, Flag);

  if not(Remote.RequestMethod in [THttpMethod.httpMethodGet, THttpMethod.httpMethodDelete])
  then
    Flag := hgAcceptData
  else
  begin
    Flag := hgWillSendMySelf;

    ProcessDocument(Sender, nil, Flag);
  end;
End;

Procedure TRESTDWIcsServicePooler.SetActive(Value: Boolean);
var
  x: Integer;
Begin
  If (Value) Then
  Begin
    Try
      if not(Assigned(ServerMethodClass)) and (Self.GetDataRouteCount = 0) then
        raise Exception.Create(cServerMethodClassNotAssigned);

      SetHttpServerParams;

      SetHttpServerSSL;

      If Not HttpAppSrv.ListenAllOK Then
      Begin
        HttpAppSrv.Port := IntToStr(ServicePort);
        If AuthenticationOptions.AuthorizationOption <> rdwAONone Then
        Begin
          Case AuthenticationOptions.AuthorizationOption Of
            rdwAOBasic:
              HttpAppSrv.AuthTypes := [atBasic];
            rdwAOBearer, rdwAOToken, rdwOAuth:
              Begin
                HttpAppSrv.AuthTypes := [atDigest];
              End;
          End;
        End
        Else
          HttpAppSrv.AuthTypes := [atNone];

        HttpAppSrv.Start;

        SetSocketServerParams;
      End;
    Except
      On E: Exception do
      Begin
        Raise Exception.Create(E.Message);
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

{ TMyHttpConnection }

destructor TPoolerHttpConnection.Destroy;
begin
  if Length(RawData) > 0 then
    SetLength(RawData, 0);

  RawDataLen := 0;
  inherited Destroy;
end;

End.
