unit uRESTDWIcsBase;

{$I ..\..\Includes\uRESTDW.inc}
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
  Flávio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}

// TODO 0
// Inserir outras propriedades do SSL no Pooler (SetHttpServerSSL);

// TODO 1
// Passar parâmetros do diretório, página e url padrão (SetParamsHttpConnection);

interface

uses
  SysUtils, Classes, DateUtils, SyncObjs, System.Generics.Collections, Vcl.ExtCtrls,

  uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject, uRESTDWBasic,
  uRESTDWBasicDB, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
  uRESTDWConsts, uRESTDWDataUtils, uRESTDWTools, uRESTDWAuthenticators,

  OverbyteIcsWinSock, OverbyteIcsWSocket, OverbyteIcsWndControl,
  OverbyteIcsHttpAppServer, OverbyteIcsUtils, OverbyteIcsFormDataDecoder,
  OverbyteIcsMimeUtils, OverbyteIcsSSLEAY, OverbyteIcsHttpSrv,
  OverbyteIcsWSocketS, OverbyteIcsSslX509Utils, OverbyteIcsSslBase;

type
  TPoolerHttpConnection = class(THttpAppSrvConnection)
  private
    vResponseHeader: TStringList;
    vRawData: AnsiString;
    vRawDataLen: Integer;
    vBytesIn, vBytesOut: Int64;
    vThreadID: cardinal;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetTrafficInBytes: Int64;
    function GetTrafficOutBytes: Int64;
  end;

  TIcsSelfAssignedCert = class(TPersistent)
  private
    vAutoGenerateOnStart: boolean;
    vCountry: string;
    vState: string;
    vLocality: string;
    vOrganization: string;
    vOrgUnit: string;
    vExpireDays: Integer;
    vEmail: string;
    vCommonName: string;
    vPrivKeyType: TSslPrivKeyType;
    vCertDigest: TEvpDigest;
    vCert: TSslCertTools;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CreateCertificate;
    function CertificateString: string;
    function PrivateKeyString: string;
  published
    property AutoGenerateOnStart: boolean read vAutoGenerateOnStart
      write vAutoGenerateOnStart default false;
    property Country: string read vCountry write vCountry;
    property State: string read vState write vState;
    property Locality: string read vLocality write vLocality;
    property Organization: string read vOrganization write vOrganization;
    property OrganizationUnit: string read vOrgUnit write vOrgUnit;
    property Email: string read vEmail write vEmail;
    property ExpireDays: Integer read vExpireDays write vExpireDays default 365;
    property CommonName: string read vCommonName write vCommonName;
    property PrivateKeyType: TSslPrivKeyType read vPrivKeyType write vPrivKeyType
      default PrivKeyRsa4096;
    property CertificateDigestType: TEvpDigest read vCertDigest write vCertDigest
      default Digest_sha512;
  end;

  TIcsBruteForceProtection = class(TPersistent)
  private type
    TBruteForceInfo = record
      Tries: Integer;
      LastAccess: TDateTime;
    end;
  private
    vBruteForceCS: TCriticalSection;
    vBruteForceSampleMin: Integer;
    vBruteForceTry: Integer;
    vBruteForceExpirationMin: Integer;
    vBruteForceDictionary: TDictionary<string, TBruteForceInfo>;
    vBruteForceProtectionStatus: boolean;
    vBruteForceTimer: TTimer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearBruteForceList;
    procedure StartBruteForce;
    procedure StopBruteForce;
    procedure SampleBruteForce(Sender: TObject);
    procedure BruteForceAttempt(IP: string);
    function BruteForceAllow(IP: string): boolean;
  published
    property BruteForceProtectionStatus: boolean read vBruteForceProtectionStatus
      write vBruteForceProtectionStatus default true;
    property BruteForceSampleMin: Integer read vBruteForceSampleMin
      write vBruteForceSampleMin default 1;
    // Sampling time in minutes to clear blocked IP
    property BruteForceTry: Integer read vBruteForceTry write vBruteForceTry default 3;
    // Attempt times before block
    property BruteForceExpirationMin: Integer read vBruteForceExpirationMin
      write vBruteForceExpirationMin default 30; // Blocked IP expiration time in minutes
  end;

  TRESTDWIcsServicePooler = class(TRESTServicePoolerBase)
    // Service Pooler private types
  private type
    TProcessDocumentThread = class(TThread)
    private
      vBodyStream: TStream;
      vRemoteRequestContentType: string;
      vStatusCode: Integer;
      vServicePooler: TRESTDWIcsServicePooler;
      vRemote: TPoolerHttpConnection;
    protected
      procedure Execute; override;
    public
      constructor Create(Remote: TPoolerHttpConnection;
        ServicePooler: TRESTDWIcsServicePooler);
      destructor Destroy; override;
      procedure onThreadTerminate(Sender: TObject);
    end;

    TThreadDictionaryRecord = record
      vCriticalSection: TCriticalSection;
      vThread: TProcessDocumentThread;
      vRemote: TPoolerHttpConnection;
    end;

    TOnException = procedure(Sender: TPoolerHttpConnection; Error: string) of object;
    TOnServerStarted = procedure(Sender: TObject) of object;
    TOnServerStopped = procedure(Sender: TObject) of object;
    TOnClientConnect = procedure(Sender: TPoolerHttpConnection; Error: Word) of object;
    TOnClientDisconnect = procedure(Sender: TPoolerHttpConnection; Error: Word) of object;
    TOnDocumentReady = procedure(Sender: TPoolerHttpConnection; var Flags: THttpGetFlag)
      of object;
    TOnAnswered = procedure(Sender: TPoolerHttpConnection) of object;
    TOnTimeout = procedure(Sender: TPoolerHttpConnection; Reason: TTimeoutReason)
      of object;
    TOnBlackListBlock = procedure(IP, Port: string) of object;
    TOnBruteForceBlock = procedure(IP, Port: string) of object;
    TOnServerStatusCheckBlock = procedure(IP, Port: string) of object;
  private
    // Events
    vOnException: TOnException;
    vOnServerStarted: TOnServerStarted;
    vOnServerStopped: TOnServerStopped;
    vOnClientConnect: TOnClientConnect;
    vOnClientDisconnect: TOnClientDisconnect;
    vOnDocumentReady: TOnDocumentReady;
    vOnAnswered: TOnAnswered;
    vOnTimeout: TOnTimeout;
    vOnBlackListBlock: TOnBlackListBlock;
    vOnBruteForceBlock: TOnBruteForceBlock;
    vOnServerStatusCheckBlock: TOnServerStatusCheckBlock;

    // HTTP Server
    HttpAppSrv: TSslHttpAppSrv;

    // SSL Params
    vSSLRootCertFile, vSSLPrivateKeyFile, vSSLPrivateKeyPassword, vSSLCertFile: string;
    vSSLVerMethodMin, vSSLVerMethodMax: TSslVerMethod;
    vSSLVerifyMode: TSslVerifyPeerModes;
    vSSLVerifyDepth: Integer;
    vSSLVerifyPeer: boolean;
    vSSLCacheModes: TSslSessCacheModes;
    vSSLTimeoutSec: cardinal;
    vSSLUse: boolean;
    vSSLCliCertMethod: TSslCliCertMethod;
    vIcsSelfAssignedCert: TIcsSelfAssignedCert;

    // HTTP Params
    vMaxClients: Integer;
    vServiceTimeout: Integer;
    vBuffSizeBytes: Integer;
    vBandWidthLimitBytes: cardinal;
    vBandWidthSampleSec: cardinal;
    vListenBacklog: Integer;

    // Security
    vBruteForceProtection: TIcsBruteForceProtection;
    vIpBlackList: TStrings;
    vServerStatusCheck: boolean;

    // Thread related
    vThreadDictionary: TDictionary<cardinal, TThreadDictionaryRecord>;
    vThreadDictionaryCS: TCriticalSection;

    // Misc procedures
    procedure CustomDisconnectClient(Remote: TPoolerHttpConnection);
    procedure SendOnException(Remote: TPoolerHttpConnection; Step: string;
      ErrorMessage: string);
    function IsConnectionDestroyed(Remote: TPoolerHttpConnection): boolean;
    procedure SetActive(Value: boolean); override;
    procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      var Pooler, MyIP: string; AccessTag: string; var InvalidTag: boolean); override;

    // Remote HTTP Connection procedures
    procedure onServerStartedServer(Sender: TObject);
    procedure onServerStoppedServer(Sender: TObject);
    procedure onClientTimeout(Sender: TObject; Reason: TTimeoutReason);
    procedure onClientConnectServer(Sender: TObject; Client: TObject; Error: Word);
    procedure onClientDisconnectServer(Sender: TObject; Client: TObject; Error: Word);
    procedure onDocumentReadyServer(Sender: TObject; var Flag: THttpGetFlag);
    procedure onPostedDataServer(Sender: TObject; ErrCode: Word);
    procedure onExceptionServer(Sender: TObject; E: ESocketException);
    procedure onAnsweredServer(Sender: TObject);
    procedure CustomAnswerStream(Remote: TPoolerHttpConnection; StatusCode: Integer;
      ContentType, Header: string);
    procedure onChangeStateServer(Sender: TObject; OldState, NewState: TSocketState);
    procedure onDestroyingConnection(Sender: TObject);

    // Prepare procedures
    procedure SetHttpServerSSL;
    procedure SetHttpServerParams;
    procedure SetSocketServerParams;
    procedure SetHttpConnectionParams(Remote: TPoolerHttpConnection);

    // Thread related procedures
    procedure ClearThreadDictionary;
    function GetFromThreadDictionary(vThreadID: cardinal): TCriticalSection;
    procedure RemoveFromThreadDictionary(vThreadID: cardinal);
    procedure InsertToThreadDictionary(vThreadID: cardinal;
      vThread: TProcessDocumentThread; vRemote: TPoolerHttpConnection);
    function TryEnterFromThreadDictionary(vThreadID: cardinal): boolean;
    procedure AcquireFromThreadDictionary(vThreadID: cardinal);
    procedure ReleaseFromThreadDictionary(vThreadID: cardinal);
    function ThreadCreate(Remote: TPoolerHttpConnection; Start: boolean)
      : TProcessDocumentThread;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Misc procedures
    function ClientCount: Integer;

  published
    // Events
    property OnException: TOnException read vOnException write vOnException;
    property OnServerStarted: TOnServerStarted read vOnServerStarted
      write vOnServerStarted;
    property OnServerStopped: TOnServerStopped read vOnServerStopped
      write vOnServerStopped;
    property OnClientConnect: TOnClientConnect read vOnClientConnect
      write vOnClientConnect;
    property OnClientDisconnect: TOnClientDisconnect read vOnClientDisconnect
      write vOnClientDisconnect;
    property OnDocumentReady: TOnDocumentReady read vOnDocumentReady
      write vOnDocumentReady;
    property OnAnswered: TOnAnswered read vOnAnswered write vOnAnswered;
    property OnTimeout: TOnTimeout read vOnTimeout write vOnTimeout;
    property OnBlackListBlock: TOnBlackListBlock read vOnBlackListBlock
      write vOnBlackListBlock;
    property OnBruteForceBlock: TOnBruteForceBlock read vOnBruteForceBlock
      write vOnBruteForceBlock;
    property OnServerStatusCheckBlock: TOnServerStatusCheckBlock
      read vOnServerStatusCheckBlock write vOnServerStatusCheckBlock;

    // SSL params
    property SSLRootCertFile: string read vSSLRootCertFile write vSSLRootCertFile;
    property SSLPrivateKeyFile: string read vSSLPrivateKeyFile write vSSLPrivateKeyFile;
    property SSLPrivateKeyPassword: string read vSSLPrivateKeyPassword
      write vSSLPrivateKeyPassword;
    property SSLCertFile: string read vSSLCertFile write vSSLCertFile;
    property SSLVersionMin: TSslVerMethod read vSSLVerMethodMin write vSSLVerMethodMin
      default sslVerTLS1_2;
    property SSLVersionMax: TSslVerMethod read vSSLVerMethodMax write vSSLVerMethodMax
      default sslVerMax;
    property SSLVerifyMode: TSslVerifyPeerModes read vSSLVerifyMode write vSSLVerifyMode;
    property SSLVerifyDepth: Integer read vSSLVerifyDepth write vSSLVerifyDepth default 9;
    property SSLVerifyPeer: boolean read vSSLVerifyPeer write vSSLVerifyPeer
      default false;
    property SSLCacheModes: TSslSessCacheModes read vSSLCacheModes write vSSLCacheModes;
    property SSLTimeoutSec: cardinal read vSSLTimeoutSec write vSSLTimeoutSec default 60;
    property SelfAssignedCert: TIcsSelfAssignedCert read vIcsSelfAssignedCert
      write vIcsSelfAssignedCert;

    // SSL TimeOut in Seconds
    property SSLUse: boolean read vSSLUse write vSSLUse default false;
    property SSLCliCertMethod: TSslCliCertMethod read vSSLCliCertMethod
      write vSSLCliCertMethod;

    // HTTP params
    property MaxClients: Integer read vMaxClients write vMaxClients default 0;
    property RequestTimeout: Integer read vServiceTimeout write vServiceTimeout
      default 60000; // Connection TimeOut in Milliseconds
    property BuffSizeBytes: Integer read vBuffSizeBytes write vBuffSizeBytes
      default 262144;
    // 256kb Default
    property BandWidthLimitBytes: cardinal read vBandWidthLimitBytes
      write vBandWidthLimitBytes default 0;
    property BandWidthSamplingSec: cardinal read vBandWidthSampleSec
      write vBandWidthSampleSec default 1;
    property ListenBacklog: Integer read vListenBacklog write vListenBacklog default 50;

    // Secutiry params
    procedure SetvIpBlackList(Lines: TStrings);
    property IpBlackList: TStrings read vIpBlackList write SetvIpBlackList;
    property BruteForceProtection: TIcsBruteForceProtection read vBruteForceProtection
      write vBruteForceProtection;
    property ServerStatusCheck: boolean read vServerStatusCheck write vServerStatusCheck
      default true;
  end;

const
  cIcsTimeoutSamplingMili = 1000;
  cIcsInvalidThreadID = 'Invalid ThreadID';
  cIcsHTTPServerNotFound = 'No HTTP server found';
  cIcsHTTPConnectionClosed = 'Closed HTTP connection';
  cIcsHTTPConnectionWritingValues = 'Writing values to Remote HTTP Connection';
  cIcsHTTPConnectionReadingValues = 'Reading values from Remote HTTP Connection';
  cIcsSSLLibNotFoundForSSLDisabled =
    'OpenSSL libs are required by ICS to digest AuthTypes Token and OAuth even if SSL is disabled';

implementation

uses uRESTDWJSONInterface, Vcl.Dialogs, OverbyteIcsWSockBuf;

procedure TRESTDWIcsServicePooler.SetHttpServerSSL;
var
  x: Integer;
begin
  if Assigned(HttpAppSrv) then
  begin
    if vSSLUse then
    begin
      HttpAppSrv.SSLContext := TSslContext.Create(HttpAppSrv);

      HttpAppSrv.SslEnable := true;

      for x := 0 to HttpAppSrv.MultiListenSockets.Count - 1 do
        HttpAppSrv.MultiListenSockets[x].SslEnable := true;

      HttpAppSrv.SSLContext.SslSessionTimeout := vSSLTimeoutSec;
      HttpAppSrv.SSLContext.SslSessionCacheModes := vSSLCacheModes;
      HttpAppSrv.SSLContext.SSLVerifyPeer := vSSLVerifyPeer;
      HttpAppSrv.SSLContext.SSLVerifyDepth := vSSLVerifyDepth;
      HttpAppSrv.SSLContext.SslVerifyPeerModes := vSSLVerifyMode;
      HttpAppSrv.SSLContext.SslMinVersion := vSSLVerMethodMin;
      HttpAppSrv.SSLContext.SslMaxVersion := vSSLVerMethodMax;

      if vIcsSelfAssignedCert.vAutoGenerateOnStart then
      begin
        vIcsSelfAssignedCert.CreateCertificate;

        HttpAppSrv.SSLContext.SslPrivKeyLines.Text :=
          vIcsSelfAssignedCert.PrivateKeyString;
        HttpAppSrv.SSLContext.SslCertLines.Text := vIcsSelfAssignedCert.CertificateString;
      end
      else
      begin
        HttpAppSrv.SSLContext.SSLCertFile := vSSLCertFile;
        HttpAppSrv.SSLContext.SslPrivKeyFile := vSSLPrivateKeyFile;
        HttpAppSrv.SSLContext.SslPassPhrase := vSSLPrivateKeyPassword;
        HttpAppSrv.RootCA := vSSLRootCertFile;
      end;

      // TODO 1
      HttpAppSrv.SSLContext.SslCliSecurity := TSslCliSecurity.sslCliSecIgnore;
      HttpAppSrv.SSLContext.SslSecLevel := TSslSecLevel.sslSecLevelAny;
    end
    else
    begin
      HttpAppSrv.SslEnable := false;

      for x := 0 to HttpAppSrv.MultiListenSockets.Count - 1 do
        HttpAppSrv.MultiListenSockets[x].SslEnable := false;

      // Destroy old SSL Context
      if Assigned(HttpAppSrv.SSLContext) then
      begin
        HttpAppSrv.SSLContext.Free;
        HttpAppSrv.SSLContext := nil;
      end;

      // OpenSSL libs are required by ICS to digest
      // AuthTypes rdwAOBearer, rdwAOToken and rdwOAuth even if SSL is disabled
      try
        if atDigest in HttpAppSrv.AuthTypes then
        begin
          HttpAppSrv.SSLContext := TSslContext.Create(HttpAppSrv);

          HttpAppSrv.SSLContext.InitializeSsl;
        end;
      except
        on E: Exception do
        begin
          raise Exception.Create(cIcsSSLLibNotFoundForSSLDisabled + #10#10 + E.Message);
        end;
      end;
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

procedure TRESTDWIcsServicePooler.SetHttpServerParams;
var
  x: Integer;
  vAuxServiceTimeout: Integer;
begin
  if Assigned(HttpAppSrv) then
  begin
    HttpAppSrv.ClientClass := TPoolerHttpConnection;

    HttpAppSrv.MaxClients := vMaxClients;
    HttpAppSrv.MaxSessions := 0;

    if vServiceTimeout > 0 then
      vAuxServiceTimeout := vServiceTimeout
    else
      vAuxServiceTimeout := -1;

    HttpAppSrv.KeepAliveTimeSec := 0;
    HttpAppSrv.KeepAliveTimeXferSec := 0;
    HttpAppSrv.MaxRequestsKeepAlive := 0;

    HttpAppSrv.MaxBlkSize := vBuffSizeBytes;

    HttpAppSrv.BandwidthLimit := vBandWidthLimitBytes;

    if vBandWidthSampleSec < 1 then
      HttpAppSrv.BandwidthSampling := 1000
    else
      HttpAppSrv.BandwidthSampling := vBandWidthSampleSec * 1000;

    HttpAppSrv.OnClientConnect := onClientConnectServer;
    HttpAppSrv.OnClientDisconnect := onClientDisconnectServer;
    HttpAppSrv.OnServerStarted := onServerStartedServer;
    HttpAppSrv.OnServerStopped := onServerStoppedServer;

    if Authenticator <> nil then
    begin
      if Authenticator is TRESTDWAuthBasic then
        HttpAppSrv.AuthTypes := [atBasic]
      else if (Authenticator is TRESTDWAuthToken) or (Authenticator is TRESTDWAuthOAuth)
      then
        HttpAppSrv.AuthTypes := [atDigest];
    end
    else
      HttpAppSrv.AuthTypes := [atNone];

    if ((ServerIPVersionConfig.ServerIpVersion = sivBoth) or
      (ServerIPVersionConfig.ServerIpVersion = sivIPv4)) then
    begin

      HttpAppSrv.Port := IntToStr(ServicePort);
      HttpAppSrv.ListenBacklog := vListenBacklog;
      HttpAppSrv.SocketFamily := sfAnyIPv4;
      HttpAppSrv.Addr := ServerIPVersionConfig.IPv4Address;

      HttpAppSrv.MultiListenSockets.Clear;

      if (ServerIPVersionConfig.ServerIpVersion = sivBoth) then
      begin
        with HttpAppSrv.MultiListenSockets.Add do
        begin

          Port := IntToStr(ServicePort);
          ListenBacklog := vListenBacklog;
          SocketFamily := sfAnyIPv6;
          Addr := ServerIPVersionConfig.IPv6Address;

        end;
      end;
    end
    else if (ServerIPVersionConfig.ServerIpVersion = sivIPv6) then
    begin

      HttpAppSrv.Port := IntToStr(ServicePort);
      HttpAppSrv.ListenBacklog := vListenBacklog;
      HttpAppSrv.SocketFamily := sfAnyIPv6;
      HttpAppSrv.Addr := ServerIPVersionConfig.IPv6Address;

      HttpAppSrv.MultiListenSockets.Clear;
    end;

  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.onExceptionServer(Sender: TObject; E: ESocketException);
var
  Remote: TPoolerHttpConnection;
begin
  try
    Remote := Sender as TPoolerHttpConnection;

    SendOnException(Remote, 'onExceptionServer', E.Message);
  finally
    Remote := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.onServerStartedServer(Sender: TObject);
begin
  if Assigned(vOnServerStarted) then
    vOnServerStarted(Sender);
end;

procedure TRESTDWIcsServicePooler.onServerStoppedServer(Sender: TObject);
begin
  if Assigned(vOnServerStopped) then
    vOnServerStopped(Sender);
end;

procedure TRESTDWIcsServicePooler.SetvIpBlackList(Lines: TStrings);
begin
  vIpBlackList.Assign(Lines);
end;

procedure TRESTDWIcsServicePooler.onClientTimeout(Sender: TObject;
  Reason: TTimeoutReason);
var
  Remote: TPoolerHttpConnection;
begin
  try
    Remote := Sender as TPoolerHttpConnection;

    try
      if Assigned(vOnTimeout) then
        vOnTimeout(Remote, Reason);
    finally
      CustomDisconnectClient(Remote);
    end;
  finally
    Remote := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.SetHttpConnectionParams(Remote: TPoolerHttpConnection);
begin
  Remote.TimeoutIdle := vServiceTimeout;
  Remote.TimeoutConnect := vServiceTimeout;
  Remote.TimeoutSampling := cIcsTimeoutSamplingMili;
  Remote.TimeoutKeepThreadAlive := false;

  Remote.LineMode := true;
  Remote.LineLimit := MaxInt;
  Remote.LineEnd := sLineBreak;

  Remote.OnTimeout := onClientTimeout;
  Remote.OnGetDocument := onDocumentReadyServer;
  Remote.OnPostDocument := onDocumentReadyServer;
  Remote.OnPutDocument := onDocumentReadyServer;
  Remote.OnDeleteDocument := onDocumentReadyServer;
  Remote.OnPatchDocument := onDocumentReadyServer;
  Remote.OnOptionsDocument := onDocumentReadyServer;
  Remote.OnPostedData := onPostedDataServer;
  Remote.OnException := onExceptionServer;
  Remote.OnAfterAnswer := onAnsweredServer;
  Remote.OnChangeState := onChangeStateServer;
  Remote.OnDestroying := onDestroyingConnection;

  if vServiceTimeout > 0 then
    Remote.TimeoutStartSampling;
end;

function TRESTDWIcsServicePooler.IsConnectionDestroyed
  (Remote: TPoolerHttpConnection): boolean;
begin
  try
    if ((Assigned(Remote) = false) or (Remote.State = TSocketState.wsClosed) or
      (csDestroying in Remote.ComponentState) or (HttpAppSrv.IsClient(Remote) = false))
    then
      Result := true
    else
      Result := false;
  except
    Result := true
  end;
end;

procedure TRESTDWIcsServicePooler.onChangeStateServer(Sender: TObject;
  OldState, NewState: TSocketState);
var
  Remote: TPoolerHttpConnection;
begin
  try
    Remote := (Sender as TPoolerHttpConnection);

    if ((NewState = TSocketState.wsClosed) and (OldState <> TSocketState.wsClosed)) then
    begin
      try
        AcquireFromThreadDictionary(Remote.vThreadID);
      except
      end;
    end;
  finally
    Remote := nil;
  end;
end;

function TRESTDWIcsServicePooler.ClientCount: Integer;
begin
  try
    if Assigned(HttpAppSrv) then
      Result := HttpAppSrv.ClientCount;
  except
    Result := -1;
  end;
end;

constructor TRESTDWIcsServicePooler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  vThreadDictionaryCS := TCriticalSection.Create;
  vThreadDictionary := TDictionary<cardinal, TThreadDictionaryRecord>.Create;
  ClearThreadDictionary;

  HttpAppSrv := TSslHttpAppSrv.Create(nil);

  // Allow OPTIONS, DELETE e PUT
  HttpAppSrv.Options := [hoAllowOptions, hoAllowDelete, hoAllowPut];

  if Assigned(HttpAppSrv.SSLContext) then
  begin
    HttpAppSrv.SSLContext.Free;
    HttpAppSrv.SSLContext := nil;
  end;

  // TODO 1
  HttpAppSrv.DocDir := '';
  HttpAppSrv.TemplateDir := '';
  HttpAppSrv.DefaultDoc := '';

  vSSLVerMethodMin := sslVerTLS1_2;
  vSSLVerMethodMax := sslVerMax;
  vSSLVerifyDepth := 9;
  vSSLVerifyPeer := false;
  vSSLTimeoutSec := 60; // SSL TimeOut in Seconds
  vSSLUse := false;
  vIcsSelfAssignedCert := TIcsSelfAssignedCert.Create;

  vMaxClients := 0;
  vServiceTimeout := 60000; // TimeOut in Milliseconds
  vBuffSizeBytes := 262144; // 256kb Default
  vBandWidthLimitBytes := 0;
  vBandWidthSampleSec := 1;
  vListenBacklog := 50;

  vIpBlackList := TStringList.Create;
  vIpBlackList.Clear;
  vServerStatusCheck := true;

  vBruteForceProtection := TIcsBruteForceProtection.Create;
end;

procedure TRESTDWIcsServicePooler.onAnsweredServer(Sender: TObject);
var
  Remote: TPoolerHttpConnection;
begin
  try
    Remote := Sender as TPoolerHttpConnection;

    if Assigned(Remote.FDocStream) then
      Remote.vBytesOut := Remote.FDocStream.Size;

    if Assigned(vOnAnswered) then
      vOnAnswered(Remote);
  finally
    Remote := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.onClientConnectServer(Sender: TObject; Client: TObject;
  Error: Word);
var
  Remote: TPoolerHttpConnection;
  i: Integer;
begin
  try
    try
      Remote := Client as TPoolerHttpConnection;

      // Check for Brute Force exploit
      if not(vBruteForceProtection.BruteForceAllow(Remote.PeerAddr)) then
      begin
        try
          if Assigned(vOnClientConnect) then
            vOnClientConnect(Remote, Remote.LastError);

          if Assigned(vOnBruteForceBlock) then
            vOnBruteForceBlock(Remote.PeerAddr, Remote.PeerPort);
        finally
          CustomDisconnectClient(Remote);
        end;

        exit;
      end;

      // Blocking the black list IPs
      if vIpBlackList.Count > 0 then
      begin
        if vIpBlackList.IndexOf(Remote.PeerAddr) <> -1 then
        begin
          try
            if Assigned(vOnClientConnect) then
              vOnClientConnect(Remote, Remote.LastError);

            if Assigned(vOnBlackListBlock) then
              vOnBlackListBlock(Remote.PeerAddr, Remote.PeerPort);
          finally
            CustomDisconnectClient(Remote);
          end;

          exit;
        end;
      end;

      SetHttpConnectionParams(Remote);

      if Assigned(vOnClientConnect) then
        vOnClientConnect(Remote, Error);
    except
      CustomDisconnectClient(Remote);
    end;
  finally
    Remote := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.onClientDisconnectServer(Sender: TObject;
  Client: TObject; Error: Word);
var
  Remote: TPoolerHttpConnection;
begin
  try
    Remote := Client as TPoolerHttpConnection;

    if Assigned(vOnClientDisconnect) then
      vOnClientDisconnect(Remote, Error);
  finally
    Remote := nil;
  end;
end;

destructor TRESTDWIcsServicePooler.Destroy;
begin
  try
    if Active then
    begin
      if HttpAppSrv.ListenAllOK then
        HttpAppSrv.Stop;
    end;
  except
    //
  end;

  if Assigned(HttpAppSrv) then
  begin
    if Assigned(HttpAppSrv.SSLContext) then
    begin
      HttpAppSrv.SSLContext.Free;
      HttpAppSrv.SSLContext := nil;
    end;

    FreeAndNil(HttpAppSrv);
  end;

  if Assigned(vBruteForceProtection) then
    FreeAndNil(vBruteForceProtection);

  if Assigned(vIcsSelfAssignedCert) then
    FreeAndNil(vIcsSelfAssignedCert);

  if Assigned(vIpBlackList) then
    FreeAndNil(vIpBlackList);

  ClearThreadDictionary;

  if Assigned(vThreadDictionaryCS) then
    FreeAndNil(vThreadDictionaryCS);

  if Assigned(vThreadDictionary) then
    FreeAndNil(vThreadDictionary);

  inherited Destroy;
end;

procedure TRESTDWIcsServicePooler.EchoPooler(ServerMethodsClass, AContext: TComponent;
  var Pooler, MyIP: string; AccessTag: string; var InvalidTag: boolean);
var
  Remote: THttpAppSrvConnection;
  i: Integer;
begin
  try
    inherited;

    InvalidTag := false;

    MyIP := '';

    if ServerMethodsClass <> nil then
    begin
      for i := 0 to ServerMethodsClass.ComponentCount - 1 do
      begin
        if (ServerMethodsClass.Components[i].ClassType = TRESTDWPoolerDB) or
          (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) then
        begin
          if Pooler = Format('%s.%s', [ServerMethodsClass.ClassName,
            ServerMethodsClass.Components[i].Name]) then
          begin
            if Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> ''
            then
            begin
              if TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag
              then
              begin
                InvalidTag := true;

                exit;
              end;
            end;
            if AContext <> nil then
            begin
              Remote := THttpAppSrvConnection(AContext);

              MyIP := Remote.PeerAddr;
            end;
            Break;
          end;
        end;
      end;
    end;

    if MyIP = '' then
      raise Exception.Create(cInvalidPoolerName);
  finally
    Remote := nil;
  end;
end;

function TRESTDWIcsServicePooler.ThreadCreate(Remote: TPoolerHttpConnection;
  Start: boolean): TProcessDocumentThread;
var
  vAuxThread: TProcessDocumentThread;
  vAuxThreadID: cardinal;
begin
  try
    Result := nil;
    vAuxThreadID := 0;
    vAuxThread := nil;

    vAuxThread := TProcessDocumentThread.Create(Remote, Self);

    vAuxThreadID := vAuxThread.ThreadID;

    Remote.vThreadID := vAuxThreadID;

    InsertToThreadDictionary(vAuxThreadID, vAuxThread, Remote);

    if Start = true then
      vAuxThread.Start;

    Result := vAuxThread;
  except
    on E: Exception do
    begin
      Result := nil;

      Remote.vThreadID := 0;

      RemoveFromThreadDictionary(vAuxThreadID);

      raise Exception.Create(E.Message);
    end;
  end;
end;

procedure TRESTDWIcsServicePooler.onPostedDataServer(Sender: TObject; ErrCode: Word);
var
  vAuxThread: TProcessDocumentThread;
  Remote: TPoolerHttpConnection;
  Len: Integer;
  lCount: Integer;
  RawDataTemp: AnsiString;
  Stream: TStream;
begin
  try
    try
      Remote := (Sender as TPoolerHttpConnection);

      repeat
      begin
        SetLength(RawDataTemp, Remote.BufSize);

        lCount := Remote.Receive(@RawDataTemp[1], Remote.BufSize);

        if lCount > 0 then
        begin
          SetLength(RawDataTemp, lCount);
          Remote.vRawData := Remote.vRawData + RawDataTemp;
          Remote.vRawDataLen := Remote.vRawDataLen + lCount;
        end
        else
          lCount := 0;

        SetLength(RawDataTemp, 0);
      end
      until lCount <= 0;

      if Remote.RequestContentLength = Remote.vRawDataLen then
      begin
        Remote.PostedDataReceived;

        // Process Thread creation
        vAuxThread := ThreadCreate(Remote, false);

        vAuxThread.vBodyStream := TStringStream.Create(Remote.vRawData);

        vAuxThread.vBodyStream.Position := 0;

        if (Remote.RequestContentLength <> vAuxThread.vBodyStream.Size) then
        begin
          FreeAndNil(vAuxThread);
          CustomAnswerStream(Remote, 400, '', '');
        end
        else
          vAuxThread.Start;
      end;
    except
      on E: Exception do
      begin
        try
          SendOnException(Remote, 'onPostedDataServer', E.Message);
        finally
          CustomDisconnectClient(Remote);
        end;
      end;
    end;
  finally
    Remote := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.CustomDisconnectClient(Remote: TPoolerHttpConnection);
begin
  try
    // Try disconnecting gracefully
    if Self.IsConnectionDestroyed(Remote) = false then
      Remote.Close;
  except
    try
      // Forced disconnection from server
      if Self.HttpAppSrv.IsClient(Remote) then
        Self.HttpAppSrv.WSocketServer.Disconnect(Remote);
    except
      on E: Exception do
      begin
        SendOnException(Remote, 'DisconnectClient', E.Message);
      end;
    end;
  end;
end;

procedure TRESTDWIcsServicePooler.CustomAnswerStream(Remote: TPoolerHttpConnection;
  StatusCode: Integer; ContentType: string; Header: string);
var
  vFlag: THttpGetFlag;
  vAuxHeader: TStringList;
  vStringBuilder: TStringBuilder;      
  i: Integer;
begin
  try
    try
      vAuxHeader := nil;
      vStringBuilder := nil;
      vFlag := hgWillSendMySelf;

      vStringBuilder := TStringBuilder.Create;

      vAuxHeader := TStringList.Create;

      vAuxHeader.Text := Header;

      for i := 0 to vAuxHeader.Count - 1 do
      begin
        if Pos('=', vAuxHeader[i]) > 0 then
        begin
          vStringBuilder.Append(Copy(vAuxHeader[i], 1, Pos('=', vAuxHeader[i]) - 1));
          vStringBuilder.Append(': ');
          vStringBuilder.Append(Copy(vAuxHeader[i], Pos('=', vAuxHeader[i]) + 1));
        end;

        vAuxHeader[i] := vStringBuilder.ToString;

        vStringBuilder.Clear;
      end;

      Header := vAuxHeader.Text;

      case StatusCode of
        400:
          Remote.Answer400;
        401:
          begin
            vBruteForceProtection.BruteForceAttempt(Remote.PeerAddr);

            if vBruteForceProtection.BruteForceAllow(Remote.PeerAddr) then
            begin
              if ((Assigned(Self.Authenticator)) and
                (Self.Authenticator is TRESTDWAuthBasic) and
                (Self.Authenticator.AuthDialog = true)) then
                Remote.Answer401
              else
                Remote.Answer403;
            end
            else
              Remote.Answer403;
          end;
        403:
          Remote.Answer403;
        404:
          begin
            if Assigned(Remote.FDocStream) then
              Remote.AnswerStream(vFlag, IntToStr(StatusCode), ContentType, Header, 0)
            else
              Remote.Answer404;
          end;
      else
        Remote.AnswerStream(vFlag, IntToStr(StatusCode), ContentType, Header, 0);
      end;
    except
      on E: Exception do
      begin
        try
          SendOnException(Remote, 'CustomAnswerStream', E.Message);
        finally
          raise Exception.Create(E.Message);
        end;
      end;
    end;
  finally
    FreeAndNil(vAuxHeader);
    FreeAndNil(vStringBuilder);
  end;
end;

procedure TRESTDWIcsServicePooler.onDocumentReadyServer(Sender: TObject;
  var Flag: THttpGetFlag);
var
  Remote: TPoolerHttpConnection;
begin
  try
    Remote := (Sender as TPoolerHttpConnection);

    try
      Remote.OnDataSent := nil;
      Remote.KeepAlive := false;

      Remote.vBytesIn := Remote.RequestContentLength;

      if Assigned(vOnDocumentReady) then
        vOnDocumentReady(Remote, Flag);
    finally
      try
        if (Remote.RequestContentLength = 0) then
        begin
          if ((Remote.RequestContentType = cContentTypeFormUrl) or
            (Remote.RequestMethod in [THttpMethod.httpMethodPut,
            THttpMethod.httpMethodPost, THttpMethod.httpMethodPatch])) then
            Flag := hg400
          else
          begin
            Flag := hgWillSendMySelf;

            // Process Thread creation
            ThreadCreate(Remote, true);
          end;
        end
        else
        begin
          if (Remote.RequestMethod in [THttpMethod.httpMethodGet,
            THttpMethod.httpMethodDelete, THttpMethod.httpMethodOptions]) then
            Flag := hg400
          else
            Flag := hgAcceptData;
        end;
      except
        on E: Exception do
        begin
          try
            SendOnException(Remote, 'onDocumentReadyServer', E.Message);
          finally
            CustomDisconnectClient(Remote);
          end;
        end;
      end;
    end;
  finally
    Remote := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.SendOnException(Remote: TPoolerHttpConnection;
  Step: string; ErrorMessage: string);
begin
  if Assigned(vOnException) then
  begin
    if HttpAppSrv.IsClient(Remote) then
      vOnException(Remote, Step + ' - ' + ErrorMessage)
    else
      vOnException(nil, Step + ' - ' + cIcsHTTPConnectionClosed + ' - ' + ErrorMessage);
  end;
end;

procedure TRESTDWIcsServicePooler.onDestroyingConnection(Sender: TObject);
var
  Remote: TPoolerHttpConnection;
begin
  try
    Remote := (Sender as TPoolerHttpConnection);

    Self.RemoveFromThreadDictionary(Remote.vThreadID);
  finally
    Remote := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.SetActive(Value: boolean);
begin
  if (Value) then
  begin
    try
      if not(Assigned(ServerMethodClass)) and (Self.GetDataRouteCount = 0) then
        raise Exception.Create(cServerMethodClassNotAssigned);

      if not(HttpAppSrv.ListenAllOK) then
      begin
        SetHttpServerParams;

        SetHttpServerSSL;

        HttpAppSrv.Start;

        SetSocketServerParams;

        vBruteForceProtection.StartBruteForce;
      end;
    except
      on E: Exception do
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end
  else if not(Value) then
  begin
    try
      if HttpAppSrv.ListenAllOK then
        HttpAppSrv.Stop;

      HttpAppSrv.MultiListenSockets.Clear;

      vBruteForceProtection.StopBruteForce;

      ClearThreadDictionary;
    except
    end;
  end;
  inherited SetActive(Value);
end;

{ TPoolerHttpConnection }

constructor TPoolerHttpConnection.Create(AOwner: TComponent);
begin
  FDocStream := nil;
  vResponseHeader := nil;

  FDocStream := TStringStream.Create;

  vResponseHeader := TStringList.Create;

  Finalize(vRawData);
  vRawDataLen := 0;
  vBytesIn := 0;
  vBytesOut := 0;
  vThreadID := 0;

  inherited Create(AOwner);
end;

destructor TPoolerHttpConnection.Destroy;
begin
  try
    try
      FreeAndNil(vResponseHeader);

      Finalize(vRawData);
      vRawDataLen := 0;
      vBytesIn := 0;
      vBytesOut := 0;
    except
    end;
  finally
    inherited Destroy;
  end;
end;

function TPoolerHttpConnection.GetTrafficInBytes: Int64;
begin
  Result := vBytesIn;
end;

function TPoolerHttpConnection.GetTrafficOutBytes: Int64;
begin
  Result := vBytesOut;
end;

{ TIcsBruteForceProtection }

function TIcsBruteForceProtection.BruteForceAllow(IP: string): boolean;
begin
  try
    try
      vBruteForceCS.Acquire;

      if vBruteForceProtectionStatus = true then
      begin
        if vBruteForceDictionary.ContainsKey(IP) then
        begin
          if ((vBruteForceDictionary.Items[IP].Tries > vBruteForceTry) and
            (IncMinute(vBruteForceDictionary.Items[IP].LastAccess,
            vBruteForceExpirationMin) > now)) then
            Result := false
          else
          begin
            if (IncMinute(vBruteForceDictionary.Items[IP].LastAccess,
              vBruteForceExpirationMin) < now) then
              vBruteForceDictionary.Remove(IP);

            Result := true;
          end;
        end
        else
          Result := true;
      end
      else
        Result := true;
    except
      Result := false;
    end;
  finally
    vBruteForceCS.Release;
  end;
end;

procedure TIcsBruteForceProtection.SampleBruteForce(Sender: TObject);
var
  x: Integer;
begin
  try
    vBruteForceCS.Acquire;

    for x := 0 to vBruteForceDictionary.Count - 1 do
    begin
      if (IncMinute(vBruteForceDictionary.ToArray[x].Value.LastAccess,
        vBruteForceExpirationMin) < now) then
        vBruteForceDictionary.Remove(vBruteForceDictionary.ToArray[x].Key);
    end;
  finally
    vBruteForceCS.Release;
  end;
end;

procedure TIcsBruteForceProtection.StartBruteForce;
begin
  if Assigned(vBruteForceTimer) then
  begin
    vBruteForceTimer.Enabled := false;

    FreeAndNil(vBruteForceTimer);
  end;

  if vBruteForceProtectionStatus then
  begin
    vBruteForceTimer := TTimer.Create(nil);

    vBruteForceTimer.Enabled := false;

    vBruteForceTimer.Interval := vBruteForceSampleMin * 60 * 1000;

    vBruteForceTimer.OnTimer := SampleBruteForce;

    vBruteForceTimer.Enabled := true;
  end;
end;

procedure TIcsBruteForceProtection.StopBruteForce;
begin
  if Assigned(vBruteForceTimer) then
  begin
    vBruteForceTimer.Enabled := false;

    FreeAndNil(vBruteForceTimer);
  end;

  ClearBruteForceList;
end;

procedure TIcsBruteForceProtection.BruteForceAttempt(IP: string);
var
  OldTries: Integer;
  auxBruteForceInfo: TBruteForceInfo;
begin
  try
    try
      vBruteForceCS.Acquire;

      if vBruteForceProtectionStatus then
      begin
        if vBruteForceDictionary.ContainsKey(IP) then
        begin
          OldTries := vBruteForceDictionary.ExtractPair(IP).Value.Tries;

          auxBruteForceInfo.Tries := OldTries + 1;
          auxBruteForceInfo.LastAccess := now;

          vBruteForceDictionary.Add(IP, auxBruteForceInfo);
        end
        else
        begin
          auxBruteForceInfo.Tries := 1;
          auxBruteForceInfo.LastAccess := now;

          vBruteForceDictionary.Add(IP, auxBruteForceInfo);
        end;
      end;
    except
      //
    end;
  finally
    vBruteForceCS.Release;
  end;
end;

procedure TIcsBruteForceProtection.ClearBruteForceList;
begin
  try
    vBruteForceCS.Acquire;

    if Assigned(vBruteForceDictionary) then
      vBruteForceDictionary.Clear;
  finally
    vBruteForceCS.Release;
  end;
end;

constructor TIcsBruteForceProtection.Create;
begin
  vBruteForceCS := TCriticalSection.Create;

  vBruteForceSampleMin := 1;
  vBruteForceTry := 3;
  vBruteForceExpirationMin := 30;
  vBruteForceProtectionStatus := true;

  vBruteForceDictionary := TDictionary<string, TBruteForceInfo>.Create;
  Self.ClearBruteForceList;
end;

destructor TIcsBruteForceProtection.Destroy;
begin
  StopBruteForce;

  if Assigned(vBruteForceDictionary) then
    FreeAndNil(vBruteForceDictionary);

  if Assigned(vBruteForceCS) then
    FreeAndNil(vBruteForceCS);

  inherited Destroy;
end;

{ TIcsSelfAssignedCert }

function TIcsSelfAssignedCert.CertificateString: string;
begin
  Result := vCert.SaveCertToText;
end;

constructor TIcsSelfAssignedCert.Create;
begin
  if Assigned(vCert) then
    FreeAndNil(vCert);

  vCert := TSslCertTools.Create(nil);

  vAutoGenerateOnStart := false;
  vPrivKeyType := TSslPrivKeyType.PrivKeyRsa4096;
  vCertDigest := TEvpDigest.Digest_sha512;
  vExpireDays := 365;
end;

procedure TIcsSelfAssignedCert.CreateCertificate;
begin
  vCert.DoClearCerts;
  vCert.DoClearCA;
  vCert.ClearAll;

  vCert.Country := vCountry;
  vCert.State := vState;
  vCert.Locality := vLocality;
  vCert.Organization := vOrganization;
  vCert.OrgUnit := vOrgUnit;
  vCert.Email := vEmail;
  vCert.CommonName := vCommonName;
  vCert.PrivKeyType := vPrivKeyType;
  vCert.CertDigest := vCertDigest;
  vCert.ExpireDays := vExpireDays;

  vCert.DoKeyPair;
  vCert.DoSelfSignCert;
end;

destructor TIcsSelfAssignedCert.Destroy;
begin
  if Assigned(vCert) then
    FreeAndNil(vCert);

  inherited Destroy;
end;

function TIcsSelfAssignedCert.PrivateKeyString: string;
begin
  Result := vCert.SavePKeyToText;
end;

{ TProcessDocumentThread }

constructor TRESTDWIcsServicePooler.TProcessDocumentThread.Create
  (Remote: TPoolerHttpConnection; ServicePooler: TRESTDWIcsServicePooler);
begin
  vRemote := nil;
  vServicePooler := nil;
  vBodyStream := nil;

  vStatusCode := 0;

  vRemote := Remote;
  vServicePooler := ServicePooler;

  inherited Create(true);

  OnTerminate := onThreadTerminate;

  FreeOnTerminate := true;
end;

destructor TRESTDWIcsServicePooler.TProcessDocumentThread.Destroy;
begin
  FreeAndNil(vBodyStream);

  vStatusCode := 0;
  Finalize(vRemoteRequestContentType);

  inherited Destroy;
end;

procedure TRESTDWIcsServicePooler.TProcessDocumentThread.Execute;
var
  vCharSet: string;
  vRemoteAuthDigestUri: string;
  vErrorMessage: string;
  vResponseString: string;
  vRemoteAuthRealm: string;
  vRemotePath: string;
  vRemoteMethod: string;
  vRemotePeerAddr: string;
  vRemotePeerPort: string;
  vRemoteRequestUserAgent: string;
  vRemoteAuthUserName: string;
  vRemoteAuthPassword: string;

  vCORSHeader: TStringList;
  vRemoteParams: TStringList;
  vRemoteRequestHeader: TStringList;
  vRemoteResponseHeader: TStringList;

  vResultStream: TStream;

  vRedirect: TRedirect;

  procedure FinalizeVars;
  begin
    FreeAndNil(vCORSHeader);
    FreeAndNil(vRemoteParams);
    FreeAndNil(vRemoteRequestHeader);
    FreeAndNil(vRemoteResponseHeader);

    FreeAndNil(vResultStream);

    Finalize(vCharSet);
    Finalize(vRemoteAuthDigestUri);
    Finalize(vErrorMessage);
    Finalize(vResponseString);
    Finalize(vRemoteAuthRealm);
    Finalize(vRemotePath);
    Finalize(vRemoteMethod);
    Finalize(vRemotePeerAddr);
    Finalize(vRemotePeerPort);
    Finalize(vRemoteRequestUserAgent);
    Finalize(vRemoteAuthUserName);
    Finalize(vRemoteAuthPassword);
  end;

  procedure InitializeVars;
  begin
    vCORSHeader := nil;
    vRemoteParams := nil;
    vRemoteRequestHeader := nil;
    vRemoteResponseHeader := nil;

    vResultStream := nil;

    Finalize(vCharSet);
    Finalize(vRemoteAuthDigestUri);
    Finalize(vErrorMessage);
    Finalize(vResponseString);
    Finalize(vRemoteAuthRealm);
    Finalize(vRemotePath);
    Finalize(vRemoteMethod);
    Finalize(vRemotePeerAddr);
    Finalize(vRemotePeerPort);
    Finalize(vRemoteRequestUserAgent);
    Finalize(vRemoteAuthUserName);
    Finalize(vRemoteAuthPassword);
  end;

  procedure Redirect(Url: string);
  begin
    vRemote.WebRedirectURL := Url;
  end;

  procedure SetReplyCORS;
  var
    i: Integer;
  begin
    if vServicePooler.CORS then
    begin
      if vServicePooler.CORS_CustomHeaders.Count > 0 then
      begin
        for i := 0 to vServicePooler.CORS_CustomHeaders.Count - 1 do
          vRemoteResponseHeader.AddPair(vServicePooler.CORS_CustomHeaders.Names[i],
            vServicePooler.CORS_CustomHeaders.ValueFromIndex[i]);
      end
      else
        vRemoteResponseHeader.AddPair('Access-Control-Allow-Origin', '*');

      if Assigned(vCORSHeader) then
      begin
        if vCORSHeader.Count > 0 then
        begin
          for i := 0 to vCORSHeader.Count - 1 do
            vRemoteResponseHeader.AddPair(vCORSHeader.Names[i],
              vCORSHeader.ValueFromIndex[i]);
        end;
      end;

    end;
  end;

begin
  try
    // Initialize local vars
    InitializeVars;

    try
      try
        // Var creation
        vCORSHeader := TStringList.Create;
        vRemoteParams := TStringList.Create;
        vRemoteRequestHeader := TStringList.Create;
        vRemoteResponseHeader := TStringList.Create;

        if ((vServicePooler.IsConnectionDestroyed(vRemote) = false) and
          (vServicePooler.TryEnterFromThreadDictionary(Self.ThreadID))) then
        begin
          try
            // Get values from Remote
            vRemotePath := vRemote.Path;
            vRemoteMethod := vRemote.Method;
            vRemotePeerAddr := vRemote.PeerAddr;
            vRemotePeerPort := vRemote.PeerPort;
            vRemoteRequestContentType := vRemote.RequestContentType;
            vRemoteAuthRealm := vRemote.AuthRealm;
            vRemoteAuthDigestUri := vRemote.AuthDigestUri;

            vRemoteParams.Delimiter := '&';
            vRemoteParams.DelimitedText := vRemote.Params;
            vRemoteRequestHeader.Assign(vRemote.RequestHeader);
          finally
            vServicePooler.ReleaseFromThreadDictionary(Self.ThreadID);
          end;
        end
        else
          raise Exception.Create(cIcsHTTPConnectionReadingValues);

        @vRedirect := @Redirect;

        // Server status check protection
        if ((vServicePooler.vServerStatusCheck = false) and
          ((vRemotePath = '') or (vRemotePath = '/'))) then
        begin
          try
            if Assigned(vServicePooler.vOnServerStatusCheckBlock) then
              vServicePooler.vOnServerStatusCheckBlock(vRemotePeerAddr, vRemotePeerPort);
          finally
            vServicePooler.CustomDisconnectClient(vRemote);
          end;
        end
        else
        begin
          try
            vServicePooler.CommandExec(TComponent(vRemote),
              RemoveBackslashCommands(vRemotePath), vRemoteMethod + ' ' + vRemotePath,
              vRemoteRequestContentType, vRemotePeerAddr, vRemoteRequestUserAgent,
              vRemoteAuthUserName, vRemoteAuthPassword, vRemoteAuthDigestUri,
              vRemoteRequestHeader, vRemotePeerPort.ToInteger, vRemoteRequestHeader,
              vRemoteParams, vRemoteParams.Text, vBodyStream, vRemoteAuthRealm, vCharSet,
              vErrorMessage, vStatusCode, vRemoteResponseHeader, vResponseString,
              vResultStream, TStrings(vCORSHeader), vRedirect);
          except
            on E: Exception do
            begin
              raise Exception.Create('CommandExec - ' + E.Message);
            end;
          end;

          SetReplyCORS;

          if (vResponseString <> '') or (vErrorMessage <> '') then
          begin
            FreeAndNil(vResultStream);

            if (vResponseString <> '') then
              vResultStream := TStringStream.Create(vResponseString)
            else
              vResultStream := TStringStream.Create(vErrorMessage);
          end;

          if ((vServicePooler.IsConnectionDestroyed(vRemote) = false) and
            (vServicePooler.TryEnterFromThreadDictionary(Self.ThreadID))) then
          begin
            try
              vRemote.AuthRealm := vRemoteAuthRealm;

              vRemote.vResponseHeader.Assign(vRemoteResponseHeader);

              if (vResultStream <> nil) then
                vRemote.FDocStream.CopyFrom(vResultStream);
            finally
              vServicePooler.ReleaseFromThreadDictionary(Self.ThreadID);
            end;
          end
          else
            raise Exception.Create(cIcsHTTPConnectionWritingValues);
        end;
      except
        on E: Exception do
        begin
          vServicePooler.SendOnException(vRemote, 'ProcessDocumentThread', E.Message);
        end;
      end;
    finally
      FinalizeVars;
    end;
  except
  end;
end;

procedure TRESTDWIcsServicePooler.TProcessDocumentThread.onThreadTerminate
  (Sender: TObject);
begin
  try
    try
      if (vServicePooler.TryEnterFromThreadDictionary(Self.ThreadID)) then
      begin
        try
          vServicePooler.CustomAnswerStream(vRemote, vStatusCode,
            vRemoteRequestContentType, vRemote.vResponseHeader.Text);
        finally
          vServicePooler.ReleaseFromThreadDictionary(Self.ThreadID);
        end;
      end;
    except
      on E: Exception do
      begin
        try
          vServicePooler.SendOnException(vRemote, 'onThreadTerminate', E.Message);
        finally
          vServicePooler.CustomDisconnectClient(vRemote);
        end;
      end;
    end;
  except
  end;
end;

// Critical Section for threads

procedure TRESTDWIcsServicePooler.ClearThreadDictionary;
var
  x: Integer;
begin
  try
    vThreadDictionaryCS.Acquire;

    for x := 0 to vThreadDictionary.Count - 1 do
    begin
      FreeAndNil(vThreadDictionary.ToArray[x].Value.vCriticalSection);
    end;

    vThreadDictionary.Clear;
  finally
    vThreadDictionaryCS.Release;
  end;
end;

function TRESTDWIcsServicePooler.GetFromThreadDictionary(vThreadID: cardinal)
  : TCriticalSection;
begin
  try
    Result := nil;

    if vThreadID > 0 then
      Result := vThreadDictionary.Items[vThreadID].vCriticalSection;
  except
    Result := nil;
  end;
end;

procedure TRESTDWIcsServicePooler.InsertToThreadDictionary(vThreadID: cardinal;
  vThread: TProcessDocumentThread; vRemote: TPoolerHttpConnection);
var
  AuxRec: TThreadDictionaryRecord;
begin
  try
    vThreadDictionaryCS.Acquire;

    if vThreadID > 0 then
    begin
      AuxRec.vCriticalSection := TCriticalSection.Create;
      AuxRec.vThread := vThread;
      AuxRec.vRemote := vRemote;

      vThreadDictionary.Add(vThreadID, AuxRec);
    end
    else
      raise Exception.Create(cIcsInvalidThreadID);
  finally
    vThreadDictionaryCS.Release;
  end;
end;

procedure TRESTDWIcsServicePooler.RemoveFromThreadDictionary(vThreadID: cardinal);
begin
  try
    vThreadDictionaryCS.Acquire;

    try
      if ((vThreadID > 0) and
        (Assigned(vThreadDictionary.Items[vThreadID].vCriticalSection))) then
      begin
        FreeAndNil(vThreadDictionary.Items[vThreadID].vCriticalSection);

        vThreadDictionary.Remove(vThreadID);
      end;
    except
    end;
  finally
    vThreadDictionaryCS.Release;
  end;
end;

function TRESTDWIcsServicePooler.TryEnterFromThreadDictionary
  (vThreadID: cardinal): boolean;
begin
  try
    if vThreadID > 0 then
      Result := vThreadDictionary.Items[vThreadID].vCriticalSection.TryEnter
    else
      Result := false;
  except
    Result := false;
  end;
end;

procedure TRESTDWIcsServicePooler.AcquireFromThreadDictionary(vThreadID: cardinal);
begin
  if vThreadID > 0 then
    vThreadDictionary.Items[vThreadID].vCriticalSection.Acquire;
end;

procedure TRESTDWIcsServicePooler.ReleaseFromThreadDictionary(vThreadID: cardinal);
begin
  if vThreadID > 0 then
    vThreadDictionary.Items[vThreadID].vCriticalSection.Release;
end;

end.
