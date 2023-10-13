unit uRESTDWHttpDefBase;

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


interface

uses
  SysUtils, Classes, DateUtils, SyncObjs, ExtCtrls, sslbase,
  uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject, uRESTDWBasic,
  uRESTDWBasicDB, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
  uRESTDWConsts, uRESTDWDataUtils, uRESTDWTools, uRESTDWAuthenticators,
  fphttpapp, httpdefs, httpprotocol, httproute, CustApp, base64;

type
  TRESTDWHttpDefServicePooler = class;

  { TRESTDWHttpDefThread }

  TRESTDWHttpDefThread = class(TThread)
  private
    FParent: TRESTDWHttpDefServicePooler;
    FMustDie: boolean;
    FPort: integer;
    FServer: THTTPApplication;
    FStartServer: boolean;
    FEvent: TSimpleEvent;
    procedure SetPort(AValue: integer);
  protected
    procedure Execute; override;

    procedure ExecRequest(
       ARequest: TRequest;
       AResponse: TResponse);

    function getActive: boolean;
    //  function getCertificateData: TCertificateData;

    //  function getUseSSL: boolean;
    procedure setActive(AValue: boolean);

    //  procedure setUseSSL(AValue: boolean);
  public
    constructor Create(AOwner: TRESTDWHttpDefServicePooler);
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
  published
    //  property UseSSL : boolean read getUseSSL write setUseSSL;
    property Active: boolean read getActive write setActive;
    property Port: integer read FPort write SetPort;
    // property CertificateData : TCertificateData read getCertificateData;
  end;

  { TRESTDWHttpDefServicePooler }

  TRESTDWHttpDefServicePooler = class(TRESTServicePoolerBase)
  private
    FFpServer: TRESTDWHttpDefThread;

    // SSL Params
   { vSSLRootCertFile, vSSLPrivateKeyFile, vSSLPrivateKeyPassword, vSSLCertFile: string;
    vSSLVerMethodMin, vSSLVerMethodMax: TSSLVersion;
    vSSLVerifyDepth: integer;
    vSSLVerifyPeer: boolean;
    vSSLTimeoutSec: cardinal;    }

    // HTTP Params
    {vMaxClients: integer;
    vServiceTimeout: integer;
    vBuffSizeBytes: integer;
    vBandWidthLimitBytes: cardinal;
    vBandWidthSampleSec: cardinal;
    vListenBacklog: integer;   }

    procedure ExecRequest(ARequest: TRequest;
      AResponse: TResponse);
  protected
   { function getUseSSL: boolean;
    procedure setUseSSL(AValue: boolean);   }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetActive(Value: boolean); override;

    procedure EchoPooler(ServerMethodsClass: TComponent; AContext: TComponent;
      var Pooler, MyIP: string; AccessTag: string; var InvalidTag: boolean); override;
  published
   { // SSL Params
    Property SSLRootCertFile: String Read vSSLRootCertFile Write vSSLRootCertFile;
    Property SSLPrivateKeyFile: String Read vSSLPrivateKeyFile Write vSSLPrivateKeyFile;
    Property SSLPrivateKeyPassword: String Read vSSLPrivateKeyPassword Write vSSLPrivateKeyPassword;
    Property SSLCertFile: String Read vSSLCertFile Write vSSLCertFile;
    Property SSLVerifyDepth: Integer Read vSSLVerifyDepth Write vSSLVerifyDepth default 9;
    Property SSLVerifyPeer: boolean Read vSSLVerifyPeer Write vSSLVerifyPeer default false;
    Property SSLVersionMin: TSSLVersion Read vSSLVerMethodMin Write vSSLVerMethodMin default svTLSv12;
    // SSL TimeOut in Seconds
    property UseSSL : boolean Read getUseSSL Write setUseSSL;  }
  end;


implementation

uses uRESTDWJSONInterface, Dialogs;

{ TRESTDWHttpDefThread }
{
function TRESTDWHttpDefThread.getUseSSL: boolean;
begin
  Result := FServer.UseSSL;
end; }

function TRESTDWHttpDefThread.getActive: boolean;
begin
  Result := FServer.Terminated;
end;

 {
function TRESTDWHttpDefThread.getCertificateData: TCertificateData;
begin
  Result := FServer.CertificateData;
end;
     }


procedure TRESTDWHttpDefThread.setActive(AValue: boolean);
var
  a : Boolean;
begin
  a := AValue;
//  FServer.active := AValue;
end;


 {
procedure TRESTDWHttpDefThread.setUseSSL(AValue: boolean);
begin
  FServer.UseSSL := AValue;
end;
     }
procedure TRESTDWHttpDefThread.SetPort(AValue: integer);
begin
  if FPort = AValue then Exit;
  FPort := AValue;
end;

procedure TRESTDWHttpDefThread.Execute;
begin
  while not Terminated do
  begin
    FEvent.WaitFor(INFINITE);

    if FMustDie then
    begin
      Terminate;
      Break;
    end;

    if (FStartServer) {and (not FServer.Terminated)} then
    begin
      FServer.Port := FPort;
      FServer.Initialize;
      FServer.Run;
    end;
  end;
end;

procedure TRESTDWHttpDefThread.ExecRequest(
  ARequest: TRequest; AResponse: TResponse);
begin
    FParent.ExecRequest(ARequest, AResponse);
end;

constructor TRESTDWHttpDefThread.Create(AOwner: TRESTDWHttpDefServicePooler);
begin
  FParent := AOwner;

  FreeOnTerminate := False;
  FMustDie := False;
  FEvent := TSimpleEvent.Create;
  FEvent.ResetEvent;

  FServer := THTTPApplication.Create(nil);
  if not assigned(CustomApplication) then
    CustomApplication := FServer;
  HTTPRouter.RegisterRoute('*', @ExecRequest);
  FServer.QueueSize := 15;
  FServer.Threaded := False;

  inherited Create(False);
end;

destructor TRESTDWHttpDefThread.Destroy;
begin
  FMustDie := True;
  FEvent.SetEvent;

  FEvent.Free;
  FServer.Free;
end;

procedure TRESTDWHttpDefThread.Start;
begin
  FMustDie := False;
  FStartServer := True;
  FEvent.SetEvent;
end;

procedure TRESTDWHttpDefThread.Stop;
begin
  FStartServer := False;
  FServer.Terminate;
  FEvent.ResetEvent;
end;

{TRESTDWHttpDefServicePooler}

procedure TRESTDWHttpDefServicePooler.ExecRequest(
   ARequest: TRequest;
   AResponse: TResponse);
var
  vContentType, vAuthRealm, sCharSet, ErrorMessage, vResponseString: string;
  StatusCode, I: integer;
  vResponseHeader, HeaderList, CORSCustomHeaders: TStringList;
  ResultStream, ContentStringStream: TStream;
  mb: TStringStream;
  vRedirect: TRedirect;

  aUserName, aPassword: string;

  procedure ParseHeader;
  var
    I: integer;
    s: string;
    sl: TStringList;

  begin
    sl := nil;

    HeaderList.NameValueSeparator := ':';
    for I := 0 to Pred(ARequest.FieldCount) do
      HeaderList.AddPair(ARequest.FieldNames[I], ARequest.FieldValues[I]);

    for I := 0 to Pred(ARequest.CustomHeaders.Count) do
      HeaderList.AddPair(ARequest.CustomHeaders.Names[I],
        ARequest.CustomHeaders.ValueFromIndex[I]);

    s := ARequest.GetHTTPVariable(hvQuery);
    sl := TStringList.Create;
    try
      if (Pos('?', s) > 0) then
      begin
        s := StringReplace(s, '?', '', [rfReplaceAll]);
        s := StringReplace(s, '/', '', []);
        sl.Delimiter := '&';
        sl.StrictDelimiter := True;
        sl.DelimitedText := s;
        for i := 0 to sl.Count - 1 do
        begin
          s := sl[i];
          if Pos('=', s) > 0 then
            HeaderList.AddPair(Copy(s, 1, Pos('=', s) - 1),
              Copy(s, Pos('=', s) + 1, Length(s) - Pos('=', s)));
        end;
      end;
    finally
      FreeAndNil(sl);
    end;
  end;

  procedure SetReplyCORS;
  var
    i: integer;
  begin
    if ARequest.CustomHeaders.Count > 0 then
    begin
      for i := 0 to ARequest.CustomHeaders.Count - 1 do
        vResponseHeader.AddPair(ARequest.CustomHeaders.Names[i],
          ARequest.CustomHeaders.ValueFromIndex[i]);
    end
    else
      vResponseHeader.AddPair('Access-Control-Allow-Origin', '*');

    if Assigned(CORSCustomHeaders) then
    begin
      if CORSCustomHeaders.Count > 0 then
      begin
        for i := 0 to CORSCustomHeaders.Count - 1 do
          vResponseHeader.AddPair(CORSCustomHeaders.Names[i],
            CORSCustomHeaders.ValueFromIndex[i]);
      end;
    end;
  end;

  procedure DestroyComponents;
  begin
    vResponseHeader.Free;
    ResultStream.Free;
    CORSCustomHeaders.Free;
    ContentStringStream.Free;
    HeaderList.Free;
  end;

  procedure Redirect(Url: string);
  begin
    AResponse.SendRedirect(Url);
  end;

  procedure WriteError;
  begin
    mb := TStringStream.Create(ErrorMessage);
    try
      AResponse.Code := StatusCode;
      mb.Position := 0;
      AResponse.FreeContentStream := True;
      AResponse.ContentStream := mb;
      AResponse.ContentStream.Position := 0;
      AResponse.ContentLength := -1;//mb.Size;
      AResponse.SendContent;
    finally
      if assigned(mb) then
        FreeAndNil(mb);
    end;
  end;

begin
  aUserName := EmptyStr;
  aPassword := EmptyStr;
  HeaderList := nil;
  vResponseHeader := nil;
  ResultStream := nil;
  CORSCustomHeaders := nil;
  ContentStringStream := nil;

  HeaderList := TStringList.Create;


  ParseHeader;

  vRedirect := TRedirect(@Redirect);
  vContentType := ARequest.ContentType;
  vAuthRealm := AResponse.WWWAuthenticate;
  sCharSet := aRequest.AcceptCharset;
  ErrorMessage := '';
  vResponseString := '';
  StatusCode := 200;

  vResponseHeader := TStringList.Create;
  ResultStream := TStream.Create;
  CORSCustomHeaders := TStringList.Create;
  ContentStringStream := TStringStream.Create(ARequest.GetHTTPVariable(hvContent));
  try
    if CommandExec(TComponent(aRequest),                              //AContext
      RemoveBackslashCommands(ARequest.GetHTTPVariable(hvPathInfo)),  //Url
      ARequest.GetHTTPVariable(hvMethod) + ' ' +
      ARequest.GetHTTPVariable(hvURL) + ' HTTP/' +
      ARequest.GetHTTPVariable(hvHTTPVersion),                        //RawHTTPCommand
      vContentType,                                                   //ContentType
      ARequest.GetHTTPVariable(hvRemoteAddress),                      //ClientIP
      aRequest.GetFieldByName('User-Agent'),                          //UserAgent
      aUserName,                                                      //AuthUsername
      aPassword,                                                      //AuthPassword
      '',                                                             //Token
      aRequest.CustomHeaders,                                         //RequestHeaders
      StrToInt(aRequest.GetHTTPVariable(hvServerPort)),               //ClientPort
      HeaderList,                                                     //RawHeaders
      aRequest.CustomHeaders,                                         //Params
      aRequest.GetHTTPVariable(hvQuery),                              //QueryParams
      ContentStringStream,                                            //ContentStringStream
      vAuthRealm,                                                     //AuthRealm
      sCharSet,                                                       //sCharSet
      ErrorMessage,                                                   //ErrorMessage
      StatusCode,                                                     //StatusCode
      vResponseHeader,                                                //ResponseHeaders
      vResponseString,                                                //ResponseString
      ResultStream,                                                   //ResultStream
      TStrings(CORSCustomHeaders),                                    //CORSCustomHeaders
      vRedirect                                                       //Redirect
      ) then
    begin
      SetReplyCORS;

      if (vAuthRealm <> '') then
        AResponse.SetHeader(hhWWWAuthenticate, 'Basic realm="API"');
      // Aqui estava o vAuthRealm, mas no caso do FPHTTP precisa ser diferente do Indy

      AResponse.ContentType := vContentType;

      if Encoding = esUtf8 then
        AResponse.AcceptCharset := 'utf-8'
      else
        AResponse.AcceptCharset := 'ansi';

      AResponse.Code := StatusCode;



      if (vResponseString <> '') or (ErrorMessage <> '') then
      begin
        if Assigned(ResultStream) then
          FreeAndNil(ResultStream);

        if (vResponseString <> '') then
          ResultStream := TStringStream.Create(vResponseString)
        else
          ResultStream := TStringStream.Create(ErrorMessage);
      end;


      for I := 0 to vResponseHeader.Count - 1 do
        AResponse.CustomHeaders.AddPair(vResponseHeader.Names[I],
          vResponseHeader.Values[vResponseHeader.Names[I]]);

      if vResponseHeader.Count > 0 then
        AResponse.SendHeaders;
      //AResponse.WriteContent;

      if Assigned(ResultStream) then
      begin
        AResponse.ContentStream := ResultStream;
        AResponse.SendContent;  //SendContent é necessário para devolver o conteúdo
        AResponse.ContentStream := nil;
        AResponse.ContentLength := ResultStream.Size;
      end;
    end
    else
    begin
      SetReplyCORS;

      if (vAuthRealm <> '') then
        AResponse.SetHeader(hhWWWAuthenticate, 'Basic realm="API"');

      AResponse.Code := StatusCode;

      if Assigned(ResultStream) then
      begin
        AResponse.ContentStream := ResultStream;
        AResponse.SendContent;  //SendContent é necessário para devolver o conteúdo
        AResponse.ContentStream := nil;
        AResponse.ContentLength := ResultStream.Size;
      end;
    end;
  finally
    DestroyComponents;
  end;
end;

{
function TRESTDWHttpDefServicePooler.getUseSSL: boolean;
begin
  Result := FFpServer.UseSSL;
end;
  } {
procedure TRESTDWHttpDefServicePooler.setUseSSL(AValue: boolean);
begin
  FFpServer.UseSSL := AValue;
end;
    }
constructor TRESTDWHttpDefServicePooler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFpServer := TRESTDWHttpDefThread.Create(Self);
  FSocketKind := 'FPHTTPApplication';
end;


destructor TRESTDWHttpDefServicePooler.Destroy;
begin
  FFpServer.Stop;
  FFpServer.Free;
  inherited Destroy;
end;

procedure TRESTDWHttpDefServicePooler.EchoPooler(ServerMethodsClass: TComponent;
  AContext: TComponent; var Pooler, MyIP: string; AccessTag: string;
  var InvalidTag: boolean);
var
  Remote: THTTPHeader;
  i: integer;
begin
  InvalidTag := False;
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
          if Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' then
          begin
            if TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <>
              AccessTag then
            begin
              InvalidTag := True;
              exit;
            end;
          end;
          if AContext <> nil then
          begin
            Remote := THTTPHeader(AContext);
            MyIP := Remote.RemoteAddress;
          end;
          Break;
        end;
      end;
    end;
  end;
  if MyIP = '' then
    raise Exception.Create(cInvalidPoolerName);
end;

procedure TRESTDWHttpDefServicePooler.SetActive(Value: boolean);
begin
  if (Value) then
  begin
    try
      if not (Assigned(ServerMethodClass)) and (Self.GetDataRouteCount = 0) then
        raise Exception.Create(cServerMethodClassNotAssigned);

      FFpServer.Port := ServicePort;

       {if UseSSL and (SSLRootCertFile <> EmptyStr) then begin
         FFpServer.CertificateData.KeyPassword          := SSLPrivateKeyPassword;//fCertificatePassword;
         FFpServer.CertificateData.HostName             := SSLRootCertFile;//fCertificateHostName;
         FFpServer.CertificateData.Certificate.FileName := SSLCertFile;//fCertificateFileName;
         FFpServer.CertificateData.PrivateKey.FileName  := SSLPrivateKeyFile;//fCertificatePrivateKey;
       end;
        }
      FFpServer.Start;
    except
      On E: Exception do
      begin
        raise Exception.Create(E.Message);
      end;
    end;
  end
  else
  if not (Value) then
  begin
    try
      if not FFpServer.getActive then
        FFpServer.Stop;
    except
    end;
  end;
  inherited SetActive(Value);
end;

end.
