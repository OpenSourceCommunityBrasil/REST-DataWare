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

// TODO 5
// Analisar possibilidade de criar uma Thread para cada SocketClient aberto pelo SocketServer;

interface

Uses
<<<<<<< .mine
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
||||||| .r3282
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
=======
   SysUtils, Classes, Db, Variants, SyncObjs,
   uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject, uRESTDWBasic,
   uRESTDWBasicDB, uRESTDWParams, uRESTDWBasicClass, uRESTDWComponentBase,
   uRESTDWCharset, uRESTDWConsts, uRESTDWEncodeClass, uRESTDWDataUtils,
   uRESTDWTools,
   OverbyteIcsWinSock, OverbyteIcsWSocket, OverbyteIcsWndControl, OverbyteIcsHttpAppServer,
   OverbyteIcsUtils, OverbyteIcsFormDataDecoder, OverbyteIcsMimeUtils, OverbyteIcsSSLEAY,
   OverbyteIcsHttpSrv;
>>>>>>> .r3289

Type

  TMyHttpConnection = class(THttpConnection)
  protected
    RawData: AnsiString;
    RawDataLen: Integer;
    Processing: Boolean;
  public
  end;

  TRESTDWIcsServicePooler = Class(TRESTServicePoolerBase)
  Private
    // HTTP Server
    HttpAppSrv: TSslHttpServer;

<<<<<<< .mine
    // SSL Params
    vSSLContext: TSslContext;
    vSSLRootCertFile, vSSLPrivateKeyFile, vSSLPrivateKeyPassword, vSSLCertFile: String;
    vSSLMethod: TSslVersionMethod;
    vSSLVerifyMode: TSslVerifyPeerModes;
    vSSLVerifyDepth: Integer;
    vSSLVerifyPeer: Boolean;
    vSSLCacheModes: TSslSessCacheModes;
    vSSLTimeoutSec: Cardinal;
    vSSLUse: Boolean;
    vSSLCliCertMethod: TSslCliCertMethod;
||||||| .r3282
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
=======
  // SSL Params
  vSSLContext                      : TSslContext;
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
>>>>>>> .r3289

    // HTTP Params
    vSocketFamily: TSocketFamily;
    vMaxClients: Integer;
    vKeepAliveSec: Cardinal;
    vServiceTimeout: Integer;
    vBuffSizeBytes: Integer;
    vBandWidthLimitBytes: Cardinal;
    vBandWidthSamplingBytes: Cardinal;

  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; override;

    // Document procedures
    Procedure onDocumentReady(Sender: TObject; Var Flags: THttpGetFlag);
    procedure onPostedData(Sender: TObject; ErrCode: Word);
    procedure ProcessDocument(Sender: TObject; BodyStream: TStream);

    // Prepare procedures
    procedure SetHttpServerSSL;
    procedure SetHttpServerParams;
    procedure SetSocketServerParams;
    procedure SetParamsHttpConnection(Remote: TMyHttpConnection);
    procedure onClientConnect(Sender, Client: TObject; Error: Word);

<<<<<<< .mine
    // Misc Procedures
    Procedure SetActive(Value: Boolean); Override;
    Procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      Var Pooler, MyIP: String; AccessTag: String; Var InvalidTag: Boolean); Override;
  Published
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

||||||| .r3282

=======
>>>>>>> .r3289
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
  End;

<<<<<<< .mine
const
  cIcsHTTPServerNotFound = 'No HTTP server found.';

||||||| .r3282





=======
  const
    cIcsHTTPServerNotFound = 'No HTTP server found.';
>>>>>>> .r3289
Implementation

Uses uRESTDWJSONInterface, Vcl.Dialogs, OverbyteIcsWSockBuf;

Procedure TRESTDWIcsServicePooler.SetHttpServerSSL;
begin
  if Assigned(HttpAppSrv) then
  begin
    if vSSLUse then
    begin
      vSSLContext := TSslContext.Create(HttpAppSrv);

      vSSLContext.SslSessionTimeout := vSSLTimeoutSec;
      vSSLContext.SslSessionCacheModes := vSSLCacheModes;
      vSSLContext.SSLVerifyPeer := vSSLVerifyPeer;
      vSSLContext.SSLVerifyDepth := vSSLVerifyDepth;
      vSSLContext.SslVerifyPeerModes := vSSLVerifyMode;
      vSSLContext.SslVersionMethod := vSSLMethod;
      vSSLContext.SSLCertFile := vSSLCertFile;
      vSSLContext.SslPrivKeyFile := vSSLPrivateKeyFile;
      vSSLContext.SslPassPhrase := vSSLPrivateKeyPassword;

      // TODO 1
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
<<<<<<< .mine
  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
||||||| .r3282
    end
    else
      raise Exception.Create('No HTTP server found.');
=======
    end
    else
      raise Exception.Create(cIcsHTTPServerNotFound);
>>>>>>> .r3289
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

    HttpAppSrv.MaxBlkSize := vBuffSizeBytes;

    HttpAppSrv.BandwidthLimit := vBandWidthLimitBytes;
    HttpAppSrv.BandwidthSampling := vBandWidthSamplingBytes;

    HttpAppSrv.MultiThreaded := true;
  end
  else
    raise Exception.Create(cIcsHTTPServerNotFound);
end;

procedure TRESTDWIcsServicePooler.SetParamsHttpConnection(Remote: TMyHttpConnection);
begin
  Remote.OnGetDocument := onDocumentReady;
  Remote.OnPostDocument := onDocumentReady;
  Remote.OnPutDocument := onDocumentReady;
  Remote.OnDeleteDocument := onDocumentReady;
  Remote.OnPatchDocument := onDocumentReady;
  Remote.onPostedData := onPostedData;
end;

Constructor TRESTDWIcsServicePooler.Create(AOwner: TComponent);
Begin
  HttpAppSrv := TSslHttpServer.Create(self);

  if Assigned(vSSLContext) then
    FreeAndNil(vSSLContext);

  HttpAppSrv.onClientConnect := onClientConnect;

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

  Inherited;
End;

procedure TRESTDWIcsServicePooler.onClientConnect(Sender: TObject; Client: TObject;
  Error: Word);
var
  Remote: TMyHttpConnection;
begin
  Remote := Client as TMyHttpConnection;

  Remote.MultiThreaded := true;

  SetParamsHttpConnection(Remote);

  Remote.LineMode := true;
  Remote.LineLimit := MaxInt;
  Remote.LineEnd := sLineBreak;

  Remote.SetBufSize(vBuffSizeBytes);
  Remote.SetSocketRcvBufSize(vBuffSizeBytes);
  Remote.SetSocketSndBufSize(vBuffSizeBytes);

  Remote.RawData := '';
  Remote.RawDataLen := 0;
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

Procedure TRESTDWIcsServicePooler.EchoPooler(ServerMethodsClass, AContext: TComponent;
  Var Pooler, MyIP: String; AccessTag: String; Var InvalidTag: Boolean);
Var
  Remote: THttpAppSrvConnection;
  I: Integer;
Begin
  Inherited;

  InvalidTag := false;
  MyIP := '';
  If ServerMethodsClass <> Nil Then
  Begin
    For I := 0 To ServerMethodsClass.ComponentCount - 1 Do
    Begin
      If (ServerMethodsClass.Components[I].ClassType = TRESTDWPoolerDB) Or
        (ServerMethodsClass.Components[I].InheritsFrom(TRESTDWPoolerDB)) Then
      Begin
        If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName,
          ServerMethodsClass.Components[I].Name]) Then
        Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[I]).AccessTag) <> '' Then
          Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[I]).AccessTag <>
              AccessTag Then
            Begin
              InvalidTag := true;
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

procedure TRESTDWIcsServicePooler.onPostedData(Sender: TObject; ErrCode: Word);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      Len: Integer;
      Remote: TMyHttpConnection;
      Stream: TStringStream;
      RawDataTemp: AnsiString;
      lCount: Integer;
    begin
      Remote := TMyHttpConnection(Sender);

      if Not(Remote.Processing) then
      begin
        Remote.Processing := true;

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
        end
        until lCount <= 0;

        if Remote.RequestContentLength = Remote.RawDataLen then
        begin
          Remote.PostedDataReceived;

          Stream := TStringStream.Create(Remote.RawData);

          Stream.Position := 0;

          ProcessDocument(Sender, Stream);
        end;

        Remote.Processing := false;

      end;
    end).Start;

end;

procedure TRESTDWIcsServicePooler.ProcessDocument(Sender: TObject; BodyStream: TStream);
Var
  Remote: TMyHttpConnection;
  sCharSet, vToken, ErrorMessage, vAuthRealm, vContentType, vResponseString: String;
  I, StatusCode: Integer;
  ResultStream: TStream;
  vResponseHeader: TStringList;
  mb: TStringStream;
  vRedirect: TRedirect;
  vParams: TStringList;
  Flags: THttpGetFlag;

<<<<<<< .mine
  Procedure WriteError;
  Begin
    mb := TStringStream.Create(ErrorMessage{$IF CompilerVersion > 21},
      TEncoding.UTF8{$IFEND});
    mb.Position := 0;
    Remote.DocStream := mb;
    Remote.AnswerStream(Flags, IntToStr(StatusCode), '', '');
  End;
||||||| .r3282
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
=======
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
>>>>>>> .r3289

  Procedure DestroyComponents;
  Begin
    If Assigned(vResponseHeader) Then
      FreeAndNil(vResponseHeader);
    If Assigned(vParams) Then
      FreeAndNil(vParams);
  End;

  Procedure Redirect(Url: String);
  Begin
    Remote.WebRedirectURL := Url;
  End;

begin
  Remote := TMyHttpConnection(Sender);

  if BodyStream = nil then
    BodyStream := TMemoryStream.Create;

  Flags := hgWillSendMySelf;

  vResponseHeader := TStringList.Create;
  vResponseString := '';
  @vRedirect := @Redirect;
  Try
    If CORS Then
    Begin
      If CORS_CustomHeaders.Count > 0 Then
      Begin
        For I := 0 To CORS_CustomHeaders.Count - 1 Do
          vResponseHeader.AddPair(CORS_CustomHeaders.Names[I],
            CORS_CustomHeaders.ValueFromIndex[I]);
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
        Remote.AnswerStream(Flags, IntToStr(StatusCode), vContentType,
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
        Remote.AnswerStream(Flags, IntToStr(StatusCode), vContentType,
          vResponseHeader.Text);
      End;
    End;
  Finally
    DestroyComponents;
  End;

end;

Procedure TRESTDWIcsServicePooler.onDocumentReady(Sender: TObject;
Var Flags: THttpGetFlag);
Var
  Remote: TMyHttpConnection;
begin
  Remote := Sender as TMyHttpConnection;

  if not(Remote.RequestMethod in [THttpMethod.httpMethodGet, THttpMethod.httpMethodDelete])
  then
    Flags := hgAcceptData
  else
    TThread.CreateAnonymousThread(
      procedure
      begin
        ProcessDocument(Sender, nil);
      end).Start;
End;

Procedure TRESTDWIcsServicePooler.SetActive(Value: Boolean);
var
  x: Integer;
Begin
  If (Value) Then
  Begin
    Try
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
