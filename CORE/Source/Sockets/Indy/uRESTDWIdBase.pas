unit uRESTDWIdBase;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware vers�o CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

Uses
 {$IFDEF FPC}
 SysUtils,      Classes, Db, Variants, {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
 uRESTDWBasic, uRESTDWBasicDB, uRESTDWConsts, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
 uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout
 {$ELSE}
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, Db, Variants, EncdDecd, SyncObjs, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWBasicClass, uRESTDWAbout
  {$ELSE}
   System.SysUtils, System.Classes, Data.Db, Variants, system.SyncObjs, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
   {$IF Defined(RESTDWFMX)}{$IFNDEF RESTDWAndroidService}FMX.Forms,{$ENDIF}
   {$ELSE}
    {$IF CompilerVersion <= 22}Forms,
     {$ELSE}VCL.Forms,
    {$IFEND}
   {$IFEND}
   uRESTDWCharset
   {$IFDEF RESTDWWINDOWS}
    , Windows
   {$ENDIF}
   , uRESTDWConsts
  {$IFEND}
 {$ENDIF}
 ,DataUtils, IdContext, IdHeaderList,        IdTCPConnection,  IdHTTPServer, IdCustomHTTPServer, IdSSLOpenSSL,  IdSSL,
 IdAuthentication,      IdTCPClient,         IdHTTPHeaderInfo, IdComponent,  IdBaseComponent,
 IdHTTP,                IdMultipartFormData, IdMessageCoder,   IdMessage,    IdGlobalProtocols,
 IdGlobal,              IdStack,             uRESTDWTools;

Type
 TRESTDWIdServicePooler = Class(TRESTServicePoolerBase)
 Private
  vCipherList,
  vaSSLRootCertFile,
  ASSLPrivateKeyFile,
  ASSLPrivateKeyPassword,
  ASSLCertFile                     : String;
  aSSLMethod                       : TIdSSLVersion;
  aSSLVersions                     : TIdSSLVersions;
  HTTPServer                       : TIdHTTPServer;
  lHandler                         : TIdServerIOHandlerSSLOpenSSL;
  vSSLVerifyMode                   : TIdSSLVerifyModeSet;
  vSSLVerifyDepth                  : Integer;
  vSSLMode                         : TIdSSLMode;
  Procedure aCommandGet             (AContext         : TIdContext;
                                     ARequestInfo     : TIdHTTPRequestInfo;
                                     AResponseInfo    : TIdHTTPResponseInfo);
  Procedure aCommandOther           (AContext         : TIdContext;
                                     ARequestInfo     : TIdHTTPRequestInfo;
                                     AResponseInfo    : TIdHTTPResponseInfo);
  Procedure CustomOnConnect         (AContext         : TIdContext);
  procedure IdHTTPServerQuerySSLPort(APort            : Word;
                                     Var VUseSSL      : Boolean);
  Procedure CreatePostStream        (AContext         : TIdContext;
                                     AHeaders         : TIdHeaderList;
                                     Var VPostStream  : TStream);
  Procedure OnParseAuthentication   (AContext         : TIdContext;
                                     Const AAuthType,
                                     AAuthData        : String;
                                     var VUsername,
                                     VPassword        : String;
                                     Var VHandled     : Boolean);
  Procedure SetActive               (Value            : Boolean);Override;
  Function  SSLVerifyPeer           (Certificate      : TIdX509;
                                     AOk              : Boolean;
                                     ADepth, AError   : Integer) : Boolean;
  Procedure GetSSLPassWord          (Var Password     : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                         AnsiString
                                                        {$ELSE}
                                                         String
                                                        {$IFEND}
                                                        {$ELSE}
                                                         String
                                                        {$ENDIF});
  Procedure EchoPooler               (ServerMethodsClass      : TComponent;
                                      AContext                : TComponent;
                                      Var Pooler, MyIP        : String;
                                      AccessTag               : String;
                                      Var InvalidTag          : Boolean);Override;
 Public
  Constructor Create                (AOwner           : TComponent);Override;
  Destructor  Destroy;
 Published
  Property SSLPrivateKeyFile       : String              Read aSSLPrivateKeyFile       Write aSSLPrivateKeyFile;
  Property SSLPrivateKeyPassword   : String              Read aSSLPrivateKeyPassword   Write aSSLPrivateKeyPassword;
  Property SSLCertFile             : String              Read aSSLCertFile             Write aSSLCertFile;
  Property SSLRootCertFile         : String              Read vaSSLRootCertFile        Write vaSSLRootCertFile;
  Property SSLVerifyMode           : TIdSSLVerifyModeSet Read vSSLVerifyMode           Write vSSLVerifyMode;
  Property SSLVerifyDepth          : Integer             Read vSSLVerifyDepth          Write vSSLVerifyDepth;
  Property SSLMode                 : TIdSSLMode          Read vSSLMode                 Write vSSLMode;
  Property CipherList              : String              Read vCipherList              Write vCipherList;
End;

Type
 TRESTDWIdClientREST = Class(TRESTDWClientRESTBase)
 Private
  HttpRequest      : TIdHTTP;
  vVerifyCert      : Boolean;
  vAUrl,
  vCertFile,
  vKeyFile,
  vRootCertFile,
  vHostCert        : String;
  vPortCert        : Integer;
  vOnGetpassword   : TOnGetpassword;
  vSSLVersions     : TIdSSLVersions;
  ssl              : TIdSSLIOHandlerSocketOpenSSL;
  vCertMode        : TIdSSLMode;
  Procedure SetParams;
  Procedure SetUseSSL         (Value              : Boolean);Override;
  Procedure SetHeaders        (AHeaders           : TStringList);Overload;Override;
  Procedure SetHeaders        (AHeaders           : TStringList;
                               Var SendParams     : TIdMultipartFormDataStream);Overload;
  Procedure SetRawHeaders     (AHeaders           : TStringList;
                               Var SendParams     : TIdMultipartFormDataStream);
  Procedure pOnWork           (ASender            : TObject;
                               AWorkMode          : TWorkMode;
                               AWorkCount         : Int64);
  Procedure SetOnWork         (Value              : TOnWork);Override;
  Procedure pOnWorkBegin      (ASender            : TObject;
                               AWorkMode          : TWorkMode;
                               AWorkCount         : Int64);
  Procedure SetOnWorkBegin    (Value              : TOnWork);   Override;
  Procedure pOnWorkEnd        (ASender            : TObject;
                               AWorkMode          : TWorkMode);
  Procedure SetOnWorkEnd      (Value              : TOnWorkEnd);Override;
  Procedure pOnStatus         (ASender            : TObject;
                               Const AStatus      : TIdStatus;
                               Const AStatusText  : String);
  Procedure SetOnStatus       (Value              : TOnStatus); Override;
  Procedure DestroyClient;Override;
  Procedure SetCertOptions;
  Procedure Getpassword       (Var Password       : String);
  Function  GetVerifyCert                         : Boolean;
  Procedure SetVerifyCert     (aValue             : Boolean);
  {$IFNDEF FPC}
  {$IFNDEF DELPHI_10TOKYO_UP}
  Function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                  AOk         : Boolean): Boolean;Overload;
  Function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                  AOk         : Boolean;
                                                  ADepth      : Integer): Boolean;Overload;
  {$ENDIF}
  {$ENDIF}
  Function IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                  AOk         : Boolean;
                                                  ADepth,
                                                  AError      : Integer) : Boolean;Overload;
 Public
  Constructor Create(AOwner : TComponent);Override;
  Destructor  Destroy;
  Function   Get       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Get       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        IgnoreEvents      : Boolean        = False):String; Overload;Override;
  Function   Post      (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Post      (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const CustomBody  : TIdMultipartFormDataStream = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;
  Function   Post      (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Post      (AUrl              : String;
                        var AResponseText : String;
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Post      (AUrl              : String;
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False;
                        RawHeaders        : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        Const CustomBody  : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Put       (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomBody        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        CustomBody        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Patch     (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        FileName          : String         = '';
                        FileStream        : TStream        = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Delete    (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Delete    (AUrl              : String;
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
 Published
  Property VerifyCert               : Boolean                     Read GetVerifyCert             Write SetVerifyCert;
  Property SSLVersions              : TIdSSLVersions              Read vSSLVersions              Write vSSLVersions;
  Property CertMode                 : TIdSSLMode                  Read vCertMode                 Write vCertMode;
  Property CertFile                 : String                      Read vCertFile                 Write vCertFile;
  Property KeyFile                  : String                      Read vKeyFile                  Write vKeyFile;
  Property RootCertFile             : String                      Read vRootCertFile             Write vRootCertFile;
  Property HostCert                 : String                      Read vHostCert                 Write vHostCert;
  Property PortCert                 : Integer                     Read vPortCert                 Write vPortCert;
  Property OnGetpassword            : TOnGetpassword              Read vOnGetpassword            Write vOnGetpassword;
End;

Type
 TRESTDWIdDatabase = Class(TRESTDWDatabasebaseBase)
 Private
  vCipherList                      : String;
  aSSLMethod                       : TIdSSLVersion;
  aSSLVersions                     : TIdSSLVersions;
  HttpRequest                      : TRESTDWIdClientREST;
  vSSLVersions                     : TIdSSLVersions;
  vSSLMode                         : TIdSSLMode;
  Procedure   SetParams            (TransparentProxy      : TProxyConnectionInfo;
                                    RequestTimeout,
                                    ConnectTimeout        : Integer;
                                    AuthorizationParams   : TRESTDWClientAuthOptionParams);
 Public
  Constructor Create               (AOwner  : TComponent);Override;
  Destructor  Destroy;Override;
 Published
  Property SSLMode                 : TIdSSLMode          Read vSSLMode                 Write vSSLMode;
  Property SSLVersions             : TIdSSLVersions      Read vSSLVersions             Write vSSLVersions;
  Property CipherList              : String              Read vCipherList              Write vCipherList;
End;

Type
 TRESTDWIdClientPooler = Class(TRESTClientPoolerBase)
 Private
  vCipherList                      : String;
  aSSLMethod                       : TIdSSLVersion;
  aSSLVersions                     : TIdSSLVersions;
  HttpRequest                      : TRESTDWIdClientREST;
  vSSLVersions                     : TIdSSLVersions;
  vSSLMode                         : TIdSSLMode;
  Function    SendEvent            (EventData             : String;
                                    Var Params            : TRESTDWParams;
                                    EventType             : TSendEvent = sePOST;
                                    JsonMode              : TJsonMode  = jmDataware;
                                    ServerEventName       : String     = '';
                                    Assyncexec            : Boolean    = False) : String;Override;
  Procedure   SetParams            (TransparentProxy      : TProxyConnectionInfo;
                                    RequestTimeout,
                                    ConnectTimeout        : Integer;
                                    AuthorizationParams   : TRESTDWClientAuthOptionParams);
 Public
  Constructor Create               (AOwner                : TComponent);Override;
  Destructor  Destroy;Override;
  Procedure   ReconfigureConnection(Var Connection        : TRESTClientPoolerBase;
                                    TypeRequest           : Ttyperequest;
                                    WelcomeMessage,
                                    Host                  : String;
                                    Port                  : Integer;
                                    Compression,
                                    EncodeStrings         : Boolean;
                                    Encoding              : TEncodeSelect;
                                    AccessTag             : String;
                                    AuthenticationOptions : TRESTDWClientAuthOptionParams);Override;
 Published
  Property SSLMode                 : TIdSSLMode          Read vSSLMode                 Write vSSLMode;
  Property SSLVersions             : TIdSSLVersions      Read vSSLVersions             Write vSSLVersions;
  Property CipherList              : String              Read vCipherList              Write vCipherList;
End;

//Fix to Indy Request Patch and Put
Type
 TIdHTTPAccess = class(TIdHTTP)
End;

Implementation

Uses uRESTDWJSONInterface;

Destructor TRESTDWIdClientREST.Destroy;
Begin
 FreeAndNil(HttpRequest);
 Inherited;
End;

Procedure TRESTDWIdClientREST.DestroyClient;
Begin
 Inherited;
 If Assigned(HttpRequest) Then
  Begin
   Try
    If HttpRequest.Connected Then
     HttpRequest.Disconnect(False);
   Finally
//    FreeAndNil(HttpRequest);
   End;
  End;
End;

Procedure TRESTDWIdClientREST.SetParams;
begin
 If Not Assigned(HttpRequest) Then
  HttpRequest := TIdHTTP.Create;
 If HttpRequest.Request.BasicAuthentication Then
  Begin
   If HttpRequest.Request.Authentication = Nil Then
    HttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
  End;
 HttpRequest.ProxyParams.ProxyUsername         := ProxyOptions.ProxyUsername;
 HttpRequest.ProxyParams.ProxyServer           := ProxyOptions.ProxyServer;
 HttpRequest.ProxyParams.ProxyPassword         := ProxyOptions.ProxyPassword;
 HttpRequest.ProxyParams.ProxyPort             := ProxyOptions.ProxyPort;
 HttpRequest.ReadTimeout                       := RequestTimeout;
 HttpRequest.Request.ContentType               := HttpRequest.Request.ContentType;
 HttpRequest.AllowCookies                      := HttpRequest.AllowCookies;
 HttpRequest.HandleRedirects                   := HttpRequest.HandleRedirects;
 HttpRequest.RedirectMaximum                   := RedirectMaximum;
 HttpRequest.HTTPOptions                       := HttpRequest.HTTPOptions;
 If RequestCharset = esUtf8 Then
  Begin
   HttpRequest.Request.Charset                  := 'utf-8';
   HttpRequest.Request.AcceptCharSet            := HttpRequest.Request.Charset;
  End
 Else If RequestCharset = esASCII Then
  Begin
   HttpRequest.Request.Charset                  := 'ascii';
   HttpRequest.Request.AcceptCharSet            := HttpRequest.Request.Charset;
  End
 Else If RequestCharset = esANSI Then
  Begin
   HttpRequest.Request.Charset                  := 'ansi';
   HttpRequest.Request.AcceptCharSet            := HttpRequest.Request.Charset;
  End;
 HttpRequest.Request.ContentType               := ContentType;
 HttpRequest.Request.Accept                    := Accept;
 HttpRequest.Request.ContentEncoding           := ContentEncoding;
 HttpRequest.Request.AcceptEncoding            := AcceptEncoding;
 HttpRequest.Request.UserAgent                 := UserAgent;
 HttpRequest.MaxAuthRetries                    := MaxAuthRetries;
End;

Function TRESTDWIdClientREST.Get(AUrl            : String         = '';
                                 CustomHeaders   : TStringList    = Nil;
                                 Const AResponse : TStream        = Nil;
                                 IgnoreEvents    : Boolean        = False) : Integer;
Var
 aString      : String;
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;     // o novo metodo recebe sempre 200 como code inicial;
 Try
  AUrl  := StringReplace(AUrl, #012, '', [rfReplaceAll]);
  vAUrl := AUrl;
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  Try
   //Copy Custom Headers
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeGet(AUrl, vTempHeaders)
    Else
     OnBeforeGet(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Get(AUrl, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(TStringStream(atempResponse).DataString)
     Else
      aString := TStringStream(atempResponse).DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtGet, tempResponse);
    End
   Else
    Begin
     HttpRequest.Get(AUrl, atempResponse); // AResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(TStringStream(atempResponse).DataString)
     Else
      aString := TStringStream(atempResponse).DataString;
     StringToStream(AResponse, aString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtGet, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(false);
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Get(AUrl            : String         = '';
                                   CustomHeaders   : TStringList    = Nil;
                                   IgnoreEvents    : Boolean        = False) : String;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 SendParams    : TIdMultipartFormDataStream;
Begin
 Try
  AUrl  := StringReplace(AUrl, #012, '', [rfReplaceAll]);
  vAUrl := AUrl;
  Result       := '';
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeGet(AUrl, vTempHeaders)
    Else
     OnBeforeGet(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   Result := HttpRequest.Get(AUrl);
   If Assigned(OnHeadersAvailable) Then
    OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
  Finally
   vTempHeaders.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result := E.ErrorMessage;
      Raise;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Post(AUrl             : String         = '';
                                    CustomHeaders    : TStringList    = Nil;
                                    Const CustomBody : TStream        = Nil;
                                    IgnoreEvents     : Boolean        = False;
                                    RawHeaders       : Boolean        = False) : Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 aString,
 sResponse    : string;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  {$IFDEF FPC}
   tempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    tempResponse := TStringStream.Create('');
   {$ELSE}
    tempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SetRawHeaders(vTempHeaders, SendParams);
   HttpRequest.Post(AUrl, SendParams, atempResponse);
   Result:= HttpRequest.ResponseCode;
   If Assigned(OnHeadersAvailable) Then
    OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
   atempResponse.Position := 0;
   If RequestCharset = esUtf8 Then
    aString := utf8Decode(atempResponse.DataString)
   Else
    aString := atempResponse.DataString;
   StringToStream(tempResponse, aString);
   FreeAndNil(atempResponse);
   tempResponse.Position := 0;
   If Not IgnoreEvents Then
   If Assigned(OnAfterRequest) then
    OnAfterRequest(AUrl, rtPost, tempResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    FreeAndNil(tempResponse);
   If Assigned(atempResponse) Then
    FreeAndNil(atempResponse);
   SendParams.Free;
   If Assigned(temp) Then
    FreeAndNil(temp);
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      If E.ErrorMessage <> '' Then
       temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF})
      Else
       temp := TStringStream.Create(E.Message{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Post(AUrl              : String                     = '';
                                    CustomHeaders     : TStringList                = Nil;
                                    Const CustomBody  : TIdMultipartFormDataStream = Nil;
                                    Const AResponse   : TStream                    = Nil;
                                    IgnoreEvents      : Boolean                    = False;
                                    RawHeaders        : Boolean                    = False) : Integer;
Var
 temp           : TStringStream;
 vTempHeaders   : TStringList;
 atempResponse,
 tempResponse   : TStringStream;
 SendParams     : TIdMultipartFormDataStream;
 aString,
 sResponse      : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   If Not Assigned(CustomBody) Then
    SetRawHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := tempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     If Assigned(CustomBody) Then
      HttpRequest.Post(AUrl, CustomBody, AResponse)
     Else if Assigned(SendParams) Then
      HttpRequest.Post(AUrl, SendParams, AResponse)
     Else
      HttpRequest.Post(AUrl, CustomHeaders, AResponse);
     Result:= HttpRequest.ResponseCode;
     If (HttpRequest.ResponseCode > 299) Then
      If Trim(sResponse) = '' Then
       sResponse := HttpRequest.ResponseText;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     If Trim(sResponse) <> '' Then
      Begin
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(sResponse)
       Else
        aString := sResponse;
      End;
//     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    FreeAndNil(tempResponse);
   If Assigned(atempResponse) Then
    FreeAndNil(atempResponse);
   SendParams.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      If E.ErrorMessage <> '' Then
       temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF})
      Else
       temp := TStringStream.Create(E.Message{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Post(AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 aString      : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Post(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Post(AUrl              : String;
                                    Var AResponseText : String;
                                    CustomHeaders     : TStringList    = Nil;
                                    CustomParams      : TStringList    = Nil;
                                    Const CustomBody  : TStream       = Nil;
                                    Const AResponse   : TStream        = Nil;
                                    IgnoreEvents      : Boolean        = False;
                                    RawHeaders        : Boolean        = False) : Integer;
Var
 temp         : TMemoryStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 aString,
 sResponse    : string;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 temp         := Nil;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   If Assigned(CustomBody) Then
    Begin
     SendParams.Clear;
     SendParams.Write(CustomBody, CustomBody.Size);
    End
   Else
    SetRawHeaders(vTempHeaders, SendParams);
//   If Assigned(CustomBody) Then
//    Begin
//     temp         := TMemoryStream.Create;
//     temp.CopyFrom(CustomBody, CustomBody.Size - CustomBody.Position);
//     temp.Position := 0;
//    End;
   If Not Assigned(AResponse) Then
    Begin
//     If Assigned(temp) Then
//      HttpRequest.Post(AUrl, Temp, atempResponse)
//     Else
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := tempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     If Assigned(CustomBody) Then
      HttpRequest.Post(AUrl, SendParams, AResponse)
     Else
      HttpRequest.Post(AUrl, CustomHeaders, AResponse);
     Result:= HttpRequest.ResponseCode;
     If (HttpRequest.ResponseCode > 299) Then
      If Trim(sResponse) = '' Then
       sResponse := HttpRequest.ResponseText;
     if Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(sResponse)
     Else
      aString := sResponse;
//     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    FreeAndNil(tempResponse);
   If Assigned(atempResponse) Then
    FreeAndNil(atempResponse);
   SendParams.Free;
   If Assigned(temp) Then
    FreeAndNil(temp);
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      If E.ErrorMessage <> '' Then
       temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF})
      Else
       temp := TStringStream.Create(E.Message{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Post(AUrl            : String;
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomParams    : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Var
 aString      : String;
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Post(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function  TRESTDWIdClientREST.Put(AUrl            : String         = '';
                                  CustomHeaders   : TStringList    = Nil;
                                  Const AResponse : TStream        = Nil;
                                  IgnoreEvents    : Boolean        = False):Integer;
Var
 aString      : String;
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse,
 SendParams   : TStringStream;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(AResponse, aString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl            : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   Const CustomBody : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 aString      : String;
Begin
 Result:= 200;
 Try
  temp         := Nil;
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   If Assigned(CustomBody) Then
    temp         := TStringStream.Create(TStringStream(CustomBody).DataString);
   HttpRequest.Put(AUrl, temp, atempResponse);
   Result:= HttpRequest.ResponseCode;
   If Assigned(temp) Then
    FreeAndNil(temp);
   atempResponse.Position := 0;
   If atempResponse.Size = 0 Then
    Begin
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(HttpRequest.Response.RawHeaders.Text)
     Else
      aString := HttpRequest.Response.RawHeaders.Text;
    End
   Else
    Begin
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
    End;
   FreeAndNil(atempResponse);
   StringToStream(AResponse, aString);
   AResponse.Position := 0;
   If Not IgnoreEvents Then
   If Assigned(OnAfterRequest) then
    OnAfterRequest(AUrl, rtPut, AResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   FileName         : String         = '';
                                   FileStream       : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 aString      : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(tempResponse, aString);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Put(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   CustomParams     : TStringList    = Nil;
                                   Const CustomBody : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(AResponse, aString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   CustomParams     : TStringList    = Nil;
                                   FileName         : String         = '';
                                   FileStream       : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   If Assigned(CustomHeaders) Then
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Put(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;//TIdMultipartFormDataStream.Create;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePatch) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePatch(AUrl, vTempHeaders)
    Else
     OnBeforePatch(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   HttpRequest.Request.Date := Now;
   If Not Assigned(AResponse) Then
    Begin
     temp := TStringStream.Create(vTempHeaders.Text);
     {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
      {$IFNDEF OLDINDY}
       {$IFDEF INDY_NEW}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
        If Assigned(SendParams) Then
         Begin
          If SendParams.Size = 0 Then
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
          Else
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
         End
        Else
         TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, []);
        {$IFEND}
       {$ENDIF}
      {$ENDIF}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPatch, tempResponse);
    End
   Else
    Begin
     temp := TStringStream.Create(StringReplace(vTempHeaders.Text, sLineBreak, '', [rfReplaceAll]));
     temp.Position := 0;
     {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
      {$IFNDEF OLDINDY}
       {$IFDEF INDY_NEW}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
         If Assigned(SendParams) Then
          Begin
           If SendParams.Size = 0 Then
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
           Else
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
          End
         Else
          TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, Nil, []);
        {$IFEND}
       {$ENDIF}
      {$ENDIF}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     If atempResponse.Size > 0 Then
      Begin
       atempResponse.Position := 0;
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(atempResponse.DataString)
       Else
        aString := atempResponse.DataString;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End
     Else
      Begin
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(HttpRequest.ResponseText)
       Else
        aString := HttpRequest.ResponseText;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End;
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Assigned(atempResponse) Then
      FreeAndNil(atempResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function  TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomBody      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;//TIdMultipartFormDataStream.Create;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePatch) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePatch(AUrl, vTempHeaders)
    Else
     OnBeforePatch(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   HttpRequest.Request.Date := Now;
   If Not Assigned(AResponse) Then
    Begin
     temp := TStringStream.Create(vTempHeaders.Text);
     If Assigned(CustomBody) Then
      temp         := TStringStream.Create(TStringStream(CustomBody).DataString);
     {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
      {$IFNDEF OLDINDY}
       {$IFDEF INDY_NEW}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
        If Assigned(SendParams) Then
         Begin
          If SendParams.Size = 0 Then
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
          Else
           TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
         End
        Else
         TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, []);
        {$IFEND}
       {$ENDIF}
      {$ENDIF}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(tempResponse, aString);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPatch, tempResponse);
    End
   Else
    Begin
     temp := TStringStream.Create(StringReplace(vTempHeaders.Text, sLineBreak, '', [rfReplaceAll]));
     temp.Position := 0;
     {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
     //TODO
     {$ELSE}
      {$IFNDEF OLDINDY}
       {$IFDEF INDY_NEW}
        {$IF CompilerVersion > 26} // Delphi XE6 pra cima
         If Assigned(SendParams) Then
          Begin
           If SendParams.Size = 0 Then
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, [])
           Else
            TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
          End
         Else
          TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, Nil, []);
        {$IFEND}
       {$ENDIF}
      {$ENDIF}
     {$IFEND}
     {$ENDIF}
     FreeAndNil(temp);
     Result:= HttpRequest.ResponseCode;
     If atempResponse.Size > 0 Then
      Begin
       atempResponse.Position := 0;
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(atempResponse.DataString)
       Else
        aString := atempResponse.DataString;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End
     Else
      Begin
       If RequestCharset = esUtf8 Then
        aString := utf8Decode(HttpRequest.ResponseText)
       Else
        aString := HttpRequest.ResponseText;
       If Not IgnoreEvents Then
       If Assigned(OnAfterRequest) then
        OnAfterRequest(AUrl, rtPatch, AResponse);
      End;
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Assigned(atempResponse) Then
      FreeAndNil(atempResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     CustomParams    : TStringList    = Nil;
                                     CustomBody      : TStream        = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePut(AUrl, vTempHeaders)
    Else
     OnBeforePut(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   If Not Assigned(AResponse) Then
    Begin
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(tempResponse, aString);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(AResponse, aString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPut, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(SendParams) Then
    FreeAndNil(SendParams);
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError Do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     CustomParams    : TStringList    = Nil;
                                     FileName        : String         = '';
                                     FileStream      : TStream        = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 atempResponse,
 tempResponse  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 aString       : String;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(CustomHeaders);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, SendParams, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     StringToStream(tempResponse, aString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodPatch, AUrl, temp, atempResponse, []);
     Result:= HttpRequest.ResponseCode;
     If Assigned(OnHeadersAvailable) then
      OnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If RequestCharset = esUtf8 Then
      aString := utf8Decode(atempResponse.DataString)
     Else
      aString := atempResponse.DataString;
     FreeAndNil(atempResponse);
     StringToStream(AResponse, aString);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   SendParams.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E: EIdHTTPProtocolException do
   Begin
    If (Length(E.ErrorMessage) > 0) Or (E.ErrorCode > 0) then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      temp.Free;
     End;
   End;
  On E: EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise;
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Delete(AUrl            : String         = '';
                                      CustomHeaders   : TStringList    = Nil;
                                      Const AResponse : TStream        = Nil;
                                      IgnoreEvents    : Boolean        = False):Integer;
Var
 vTempHeaders  : TStringList;
 Temp,
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeDelete(AUrl, vTempHeaders)
    Else
     OnBeforeDelete(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   {$IFDEF FPC}
    HttpRequest.Delete(AUrl, atempResponse);
   {$ELSE}
    {$IFDEF OLDINDY}
     HttpRequest.Delete(AUrl);
    {$ELSE}
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, AUrl, SendParams, atempResponse, []);
    {$ENDIF}
   {$ENDIF}
   Result:= HttpRequest.ResponseCode;
   If Assigned(atempResponse) Then
    atempResponse.Position := 0;
   If RequestCharset = esUtf8 Then
    aString := utf8Decode(atempResponse.DataString)
   Else
    aString := atempResponse.DataString;
   StringToStream(tempResponse, aString);
   tempResponse.Position := 0;
   FreeAndNil(atempResponse);
   If Not IgnoreEvents Then
   If Assigned(OnAfterRequest) then
    OnAfterRequest(AUrl, rtDelete, tempResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(SendParams) Then
    SendParams.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      Temp.Free;
     End;
   End;
  On E : EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWIdClientREST.Delete(AUrl              : String;
                                      CustomHeaders     : TStringList  = Nil;
                                      CustomParams      : TStringList  = Nil;
                                      Const AResponse   : TStream      = Nil;
                                      IgnoreEvents      : Boolean      = False):Integer;
Var
 vTempHeaders : TStringList;
 Temp,
 atempResponse,
 tempResponse,
 SendParams    : TStringStream;
 aString       : String;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  {$IFDEF FPC}
   atempResponse  := TStringStream.Create('');
  {$ELSE}
   {$IF CompilerVersion < 21}
    atempResponse := TStringStream.Create('');
   {$ELSE}
    atempResponse := TStringStream.Create;
   {$IFEND}
  {$ENDIF}
  If Not Assigned(AResponse) Then
   Begin
    {$IFDEF FPC}
     tempResponse  := TStringStream.Create('');
    {$ELSE}
     {$IF CompilerVersion < 21}
      tempResponse := TStringStream.Create('');
     {$ELSE}
      tempResponse := TStringStream.Create;
     {$IFEND}
    {$ENDIF}
   End;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(OnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeDelete(AUrl, vTempHeaders)
    Else
     OnBeforeDelete(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   {$IFDEF FPC}
    HttpRequest.Delete(AUrl, atempResponse);
   {$ELSE}
    {$IFDEF OLDINDY}
     HttpRequest.Delete(AUrl);
    {$ELSE}
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, AUrl, SendParams, atempResponse, []);
    {$ENDIF}
   {$ENDIF}
   Result:= HttpRequest.ResponseCode;
   If Assigned(atempResponse) Then
    atempResponse.Position := 0;
   If RequestCharset = esUtf8 Then
    aString := utf8Decode(atempResponse.DataString)
   Else
    aString := atempResponse.DataString;
   StringToStream(AResponse, aString);
   AResponse.Position := 0;
   FreeAndNil(atempResponse);
   If Not IgnoreEvents Then
   If Assigned(OnAfterRequest) then
    OnAfterRequest(AUrl, rtDelete, tempResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(SendParams) Then
    SendParams.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;
      temp := TStringStream.Create(E.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
      AResponse.CopyFrom(temp, temp.Size);
      Temp.Free;
     End;
   End;
  On E : EIdSocketError do
   Begin
    HttpRequest.Disconnect(false);
    Raise
   End;
 End;
 DestroyClient;
End;

Constructor TRESTDWIdClientREST.Create(AOwner: TComponent);
Begin
 Inherited;
 ContentType                    := 'application/json';
 ContentEncoding                := 'multipart/form-data';
 Accept                         := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
 AcceptEncoding                 := 'gzip, deflate, br';
 MaxAuthRetries                 := 0;
 UserAgent                      := cUserAgent;
 AccessControlAllowOrigin       := '*';
 ActiveRequest                   := '';
 RedirectMaximum                := 1;
 RequestTimeOut                 := 5000;
 ConnectTimeOut                 := 5000;
 ssl                            := Nil;
End;

{$IFNDEF FPC}
{$IFNDEF DELPHI_10TOKYO_UP}
Function TRESTDWIdClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                                    AOk         : Boolean) : Boolean;
Begin
 Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, -1);
End;

Function TRESTDWIdClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                                    AOk         : Boolean;
                                                                    ADepth      : Integer) : Boolean;
Begin
 Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, ADepth, -1);
End;
{$ENDIF}
{$ENDIF}
Function TRESTDWIdClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                                    AOk         : Boolean;
                                                                    ADepth,
                                                                    AError      : Integer) : Boolean;
Begin
 Result := AOk;
 If Not vVerifyCert then
  Result := True;
End;

Procedure TRESTDWIdClientREST.pOnWork(ASender    : TObject;
                                      AWorkMode  : TWorkMode;
                                      AWorkCount : Int64);
Begin
 OnWork(ASender, AWorkCount);
End;

Procedure TRESTDWIdClientREST.Getpassword(Var Password : String);
Begin
 If Assigned(vOnGetpassword) Then
  vOnGetpassword(Password);
End;

Function TRESTDWIdClientREST.GetVerifyCert : boolean;
Begin
 Result := vVerifyCert;
End;

Procedure TRESTDWIdClientREST.SetVerifyCert(aValue : Boolean);
Begin
 vVerifyCert := aValue;
End;

Procedure TRESTDWIdClientREST.SetCertOptions;
Begin
 If Assigned(ssl) Then
  Begin
   {$IFDEF FPC}
    ssl.OnGetPassword          := @Getpassword;
   {$ELSE}
    ssl.OnGetPassword          := Getpassword;
   {$ENDIF}
   ssl.SSLOptions.CertFile     := vCertFile;
   ssl.SSLOptions.KeyFile      := vKeyFile;
   ssl.SSLOptions.RootCertFile := vRootCertFile;
   ssl.Host                    := vHostCert;
   ssl.Port                    := vPortCert;
   ssl.SSLOptions.Mode         := vCertMode;
  End;
End;

Procedure TRESTDWIdClientREST.pOnStatus(ASender           : TObject;
                                        Const AStatus     : TIdStatus;
                                        Const AStatusText : String);
Begin
 OnStatus(ASender, TConnStatus(AStatus), AStatusText);
End;

Procedure TRESTDWIdClientREST.pOnWorkEnd (ASender    : TObject;
                                          AWorkMode  : TWorkMode);
Begin
 OnWorkEnd(ASender);
End;

Procedure TRESTDWIdClientREST.pOnWorkBegin(ASender    : TObject;
                                           AWorkMode  : TWorkMode;
                                           AWorkCount : Int64);
Begin
 OnWorkBegin(ASender, AWorkCount);
End;

Procedure TRESTDWIdClientREST.SetHeaders(AHeaders       : TStringList;
                                         Var SendParams : TIdMultipartFormDataStream);
Var
 I : Integer;
Begin
// HttpRequest.Request.CustomHeaders.Clear;
 HttpRequest.Request.AcceptEncoding := AcceptEncoding;
 If AccessControlAllowOrigin <> '' Then
  Begin
   If SendParams <> Nil Then
    Begin
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
       HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', AccessControlAllowOrigin);
      {$ELSE}
       HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', AccessControlAllowOrigin);
      {$IFEND}
     {$ELSE}
      HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin',  AccessControlAllowOrigin);
     {$ENDIF}
    End;
  End;
 If Assigned(AHeaders) Then
  Begin
   If AHeaders.Count > 0 Then
    Begin
     For i := 0 to AHeaders.Count-1 do
      Begin
       If SendParams = Nil Then
        Begin
         If (AHeaders.Names[i] <> '') Or (AHeaders.ValueFromIndex[i] <> '') Then
          Begin
           If RequestCharset = esUtf8 Then
            HttpRequest.Request.CustomHeaders.AddValue(AHeaders.Names[i], utf8Decode(AHeaders.ValueFromIndex[i]))
           Else
            HttpRequest.Request.CustomHeaders.AddValue(AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
          End;
        End
       Else
        Begin
         If (AHeaders.Names[i] <> '') Or (AHeaders.ValueFromIndex[i] <> '') Then
          Begin
           If RequestCharset = esUtf8 Then
            SendParams.AddFormField(AHeaders.Names[i],  utf8Decode(AHeaders.ValueFromIndex[i]))
           Else
            SendParams.AddFormField(AHeaders.Names[i],  AHeaders.ValueFromIndex[i]);
          End;
        End;
      End;
    End;
  End;
End;

Procedure TRESTDWIdClientREST.SetRawHeaders(AHeaders       : TStringList;
                                            Var SendParams : TIdMultipartFormDataStream);
Var
 I : Integer;
Begin
 HttpRequest.Request.AcceptEncoding := AcceptEncoding;
 HttpRequest.Request.RawHeaders.Clear;
// HttpRequest.Request.CustomHeaders.Clear;
 If AccessControlAllowOrigin <> '' Then
  Begin
   If SendParams <> Nil Then
    Begin
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
       SendParams.AddFormField('Access-Control-Allow-Origin', AccessControlAllowOrigin);
      {$ELSE}
       SendParams.AddFormField('Access-Control-Allow-Origin', AccessControlAllowOrigin);
      {$IFEND}
     {$ELSE}
      SendParams.AddFormField('Access-Control-Allow-Origin',  AccessControlAllowOrigin);
     {$ENDIF}
    End;
  End;
 If Assigned(AHeaders) Then
  Begin
   If AHeaders.Count > 0 Then
    Begin
     For i := 0 to AHeaders.Count-1 do
      Begin
       If SendParams = Nil Then
        Begin
         If RequestCharset = esUtf8 Then
          HttpRequest.Request.RawHeaders.Add(utf8Decode(AHeaders[i]))
         Else
          HttpRequest.Request.RawHeaders.Add(AHeaders[i]);
        End
       Else
        Begin
         If RequestCharset = esUtf8 Then
          SendParams.AddFormField(AHeaders.Names[i],  utf8Decode(AHeaders.ValueFromIndex[i]))
         Else
          SendParams.AddFormField(AHeaders.Names[i],  AHeaders.ValueFromIndex[i]);
        End;
      End;
    End;
  End;
End;

Procedure TRESTDWIdClientREST.SetUseSSL(Value : Boolean);
Begin
 Inherited;
 If Assigned(HttpRequest) Then
  HttpRequest.IOHandler := Nil;
 If Value Then
  Begin
   If ssl = Nil Then
    Begin
     ssl               := TIdSSLIOHandlerSocketOpenSSL.Create(HttpRequest);
     {$IFDEF FPC}
      ssl.OnVerifyPeer := @IdSSLIOHandlerSocketOpenSSL1VerifyPeer;
     {$ELSE}
      ssl.OnVerifyPeer := IdSSLIOHandlerSocketOpenSSL1VerifyPeer;
     {$ENDIF}
    End;
   {$IFDEF FPC}
    ssl.SSLOptions.SSLVersions := vSSLVersions;
   {$ELSE}
    {$IF Not(DEFINED(OLDINDY))}
     ssl.SSLOptions.SSLVersions := vSSLVersions;
    {$ELSE}
     ssl.SSLOptions.Method      := aSSLMethod;
    {$IFEND}
   {$ENDIF}
   SetCertOptions;
   HttpRequest.IOHandler := ssl;
  End
 Else
  Begin
   If Assigned(ssl) Then
    FreeAndNil(ssl);
  End;
End;

Procedure TRESTDWIdClientREST.SetHeaders(AHeaders : TStringList);
Var
 I           : Integer;
 vmark       : String;
 DWParams    : TRESTDWParams;
Begin
 Inherited;
 vmark       := '';
 DWParams    := Nil;
 HttpRequest.Request.AcceptEncoding := AcceptEncoding;
 HttpRequest.Request.CustomHeaders.Clear;
 HttpRequest.Request.CustomHeaders.NameValueSeparator := cNameValueSeparator;
 If Assigned(AHeaders) Then
  If AHeaders.Count > 0 Then
   HttpRequest.Request.CustomHeaders.FoldLines := False;
 If (AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken]) Then
  HttpRequest.Request.CustomHeaders.FoldLines := False;
 If AccessControlAllowOrigin <> '' Then
  Begin
   {$IFNDEF FPC}
    {$if CompilerVersion > 21}
     HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', AccessControlAllowOrigin);
    {$ELSE}
     HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', AccessControlAllowOrigin);
    {$IFEND}
   {$ELSE}
    HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin',  AccessControlAllowOrigin);
   {$ENDIF}
  End;
 If Assigned(AHeaders) Then
  Begin
   If AHeaders.Count > 0 Then
    Begin
     For i := 0 to AHeaders.Count-1 do
      HttpRequest.Request.CustomHeaders.AddValue(AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
    End;
  End;
 If AuthenticationOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken, rdwOAuth] Then
  Begin
   HttpRequest.Request.BasicAuthentication := AuthenticationOptions.AuthorizationOption = rdwAOBasic;
   Case AuthenticationOptions.AuthorizationOption of
    rdwAOBasic  : Begin
                   If HttpRequest.Request.Authentication = Nil Then
                    HttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
                   HttpRequest.Request.Authentication.Password := TRESTDWAuthOptionBasic(AuthenticationOptions.OptionParams).Password;
                   HttpRequest.Request.Authentication.Username := TRESTDWAuthOptionBasic(AuthenticationOptions.OptionParams).UserName;
                  End;
    rdwAOBearer : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   HttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token);
                  End;
    rdwAOToken  : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   HttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token]));
                  End;
    rdwOAuth    : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   ActiveRequest := Stringreplace(lowercase(ActiveRequest), 'http://', '', [rfReplaceAll]);
                   ActiveRequest := Stringreplace(lowercase(ActiveRequest), 'https://', '', [rfReplaceAll]);
                   TDataUtils.ParseRESTURL(ActiveRequest, RequestCharset, vmark{$IFDEF FPC}, csUndefined{$ENDIF}, DWParams);
                   If Assigned(DWParams) Then
                    FreeAndNil(DWParams);
//                   If (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(UriOptions.EventName))   Or
//                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent))  Or
//                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.EventName))  Or
//                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.ServerEvent)) Then
//                    Begin
//                     If (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.EventName))  Or
//                        (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent)) Then
//                      Begin
//                       If TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).AutoBuildHex Then
//                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
//                                                                                                               TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
//                                                                                                               {$IFDEF FPC}, csUndefined{$ENDIF})]))
//                       Else
//                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
//                                                                                                               TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
//                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]));
//                      End;
//                    End
//                   Else
//                    Begin
                     Case TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).TokenType Of
                      rdwOATBasic  : Begin
                                      If TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).AutoBuildHex Then
                                       HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
                                                                                                                              TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
                                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]))
                                      Else
                                       HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
                                                                                                                              TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
                                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]));
                                     End;
                      rdwOATBearer : HttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).Token);
                      rdwOATToken  : HttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).Token]));
                     End;
//                    End;
                  End;
   End;
  End;
End;

Procedure TRESTDWIdClientREST.SetOnStatus(Value : TOnStatus);
Begin
 Inherited;
 HttpRequest.OnStatus := pOnStatus;
End;

Procedure TRESTDWIdClientREST.SetOnWork  (Value : TOnWork);
Begin
 Inherited;
 HttpRequest.OnWork := pOnWork;
End;

Procedure TRESTDWIdClientREST.SetOnWorkBegin(Value : TOnWork);
Begin
 Inherited;
 HttpRequest.OnWorkBegin := pOnWorkBegin;
End;

Procedure TRESTDWIdClientREST.SetOnWorkEnd  (Value : TOnWorkEnd);
Begin
 Inherited;
 HttpRequest.OnWorkEnd := pOnWorkEnd;
End;

Procedure TRESTDWIdServicePooler.aCommandGet(AContext      : TIdContext;
                                             ARequestInfo  : TIdHTTPRequestInfo;
                                             AResponseInfo : TIdHTTPResponseInfo);
Var
 sCharSet,
 vToken,
 ErrorMessage,
 vAuthRealm,
 vResponseString : String;
 I,
 StatusCode      : Integer;
 ResultStream    : TStream;
 vResponseHeader : TStringList;
 mb              : TStringStream;
 vRedirect       : TRedirect;
 Procedure WriteError;
 Begin
  AResponseInfo.ResponseNo              := StatusCode;
  {$IFNDEF FPC}
   mb                                   := TStringStream.Create(ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
   mb.Position                          := 0;
   AResponseInfo.FreeContentStream      := True;
   AResponseInfo.ContentStream          := mb;
   AResponseInfo.ContentStream.Position := 0;
   AResponseInfo.ContentLength          := mb.Size;
   AResponseInfo.WriteContent;
  {$ELSE}
   mb                                  := TStringStream.Create(ErrorMessage);
   mb.Position                          := 0;
   AResponseInfo.FreeContentStream      := True;
   AResponseInfo.ContentStream          := mb;
   AResponseInfo.ContentStream.Position := 0;
   AResponseInfo.ContentLength          := -1;//mb.Size;
   AResponseInfo.WriteContent;
  {$ENDIF}
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(vResponseHeader) Then
   FreeAndNil(vResponseHeader);
 End;
 Procedure Redirect(Url : String);
 Begin
  AResponseInfo.Redirect(Url);
 End;
Begin
 ResultStream    := TStringStream.Create('');
 vResponseHeader := TStringList.Create;
 vResponseString := '';
 @vRedirect      := @Redirect;
 Try
  If CORS Then
   Begin
    If CORS_CustomHeaders.Count > 0 Then
     Begin
      For I := 0 To CORS_CustomHeaders.Count -1 Do
       AResponseInfo.CustomHeaders.AddValue(CORS_CustomHeaders.Names[I], CORS_CustomHeaders.ValueFromIndex[I]);
     End
    Else
     AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin','*');
   End;
  {$IFNDEF FPC}
   {$IF Defined(HAS_FMX)}
    {$IFDEF HAS_UTF8}
     If Assigned({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}) Then
      vToken       := TRESTDWAuthRequest({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}).Token;
    {$ELSE}
     If Assigned(AContext.Data) Then
      vToken       := TRESTDWAuthRequest(AContext.Data).Token;
    {$ENDIF}
   {$ELSE}
    If Assigned(AContext.Data) Then
     vToken       := TRESTDWAuthRequest(AContext.Data).Token;
   {$IFEND}
  {$ELSE}
   If Assigned(AContext.Data) Then
    vToken       := TRESTDWAuthRequest(AContext.Data).Token;
  {$ENDIF}
  vAuthRealm := AResponseInfo.AuthRealm;
  If CommandExec  (TComponent(AContext),
                   RemoveBackslashCommands(ARequestInfo.URI),
                   ARequestInfo.RawHTTPCommand,
                   ARequestInfo.ContentType,
                   AContext.Binding.PeerIP,
                   ARequestInfo.UserAgent,
                   ARequestInfo.Username,
                   ARequestInfo.Password,
                   vToken,
                   ARequestInfo.CustomHeaders,
                   AContext.Binding.PeerPort,
                   ARequestInfo.RawHeaders,
                   ARequestInfo.Params,
                   ARequestInfo.QueryParams,
                   ARequestInfo.PostStream,
                   vAuthRealm,
                   sCharSet,
                   ErrorMessage,
                   StatusCode,
                   vResponseHeader,
                   vResponseString,
                   ResultStream,
                   vRedirect) Then
   Begin
    AResponseInfo.AuthRealm   := vAuthRealm;
    {$IFNDEF FPC}
     {$if CompilerVersion > 21}
      If (sCharSet <> '') Then
       AResponseInfo.CharSet := sCharSet;
     {$IFEND}
    {$ENDIF}
    AResponseInfo.ResponseNo               := StatusCode;
    If (vResponseString <> '') Or
       (ErrorMessage    <> '') Then
     Begin
      If Assigned(ResultStream) Then
       FreeAndNil(ResultStream);
      AResponseInfo.ContentLength          := -1;
      If ErrorMessage <> '' Then
       AResponseInfo.ResponseText          := ErrorMessage
      Else
       AResponseInfo.ResponseText          := vResponseString;
     End
    Else
     Begin
      AResponseInfo.FreeContentStream      := True;
      AResponseInfo.ContentStream          := ResultStream;
      AResponseInfo.ContentStream.Position := 0;
      {$IFNDEF FPC}
       AResponseInfo.ContentLength         := ResultStream.Size;
      {$ELSE}
       AResponseInfo.ContentLength         := -1;
      {$ENDIF}
     End;
    For I := 0 To vResponseHeader.Count -1 Do
     AResponseInfo.CustomHeaders.AddValue(vResponseHeader.Names [I],
                                          vResponseHeader.Values[vResponseHeader.Names[I]]);
    If vResponseHeader.Count > 0 Then
     AResponseInfo.WriteHeader;
    AResponseInfo.WriteContent;
   End
  Else //Tratamento de Erros.
   Begin
    AResponseInfo.AuthRealm := vAuthRealm;
    {$IFNDEF FPC}
     {$if CompilerVersion > 21}
      If (sCharSet <> '') Then
       AResponseInfo.CharSet := sCharSet;
     {$IFEND}
    {$ENDIF}
    AResponseInfo.ResponseNo               := StatusCode;
    If ErrorMessage <> '' Then
     AResponseInfo.ResponseText            := ErrorMessage
    Else
     Begin
      AResponseInfo.FreeContentStream      := True;
      AResponseInfo.ContentStream          := ResultStream;
      AResponseInfo.ContentStream.Position := 0;
      {$IFNDEF FPC}
       AResponseInfo.ContentLength         := ResultStream.Size;
      {$ELSE}
       AResponseInfo.ContentLength         := -1;
      {$ENDIF}
     End;
   End;
 Finally
  DestroyComponents;
 End;
End;

Procedure TRESTDWIdServicePooler.aCommandOther(AContext      : TIdContext;
                                               ARequestInfo  : TIdHTTPRequestInfo;
                                               AResponseInfo : TIdHTTPResponseInfo);
Begin
 aCommandGet(AContext, ARequestInfo, AResponseInfo);
End;

Procedure TRESTDWIdServicePooler.CustomOnConnect(AContext : TIdContext);
Begin
 AContext.Connection.Socket.ReadTimeout := RequestTimeout;
End;

Procedure TRESTDWIdServicePooler.IdHTTPServerQuerySSLPort(APort       : Word;
                                                          Var VUseSSL : Boolean);
Begin
 VUseSSL := (APort = Self.ServicePort);
End;

Constructor TRESTDWIdServicePooler.Create(AOwner: TComponent);
Begin
 Inherited;
 HTTPServer                      := TIdHTTPServer.Create(Nil);
 lHandler                        := TIdServerIOHandlerSSLOpenSSL.Create;
 {$IFDEF FPC}
 HTTPServer.OnQuerySSLPort       := @IdHTTPServerQuerySSLPort;
 HTTPServer.OnCommandGet         := @aCommandGet;
 HTTPServer.OnCommandOther       := @aCommandOther;
 HTTPServer.OnConnect            := @CustomOnConnect;
 HTTPServer.OnCreatePostStream   := @CreatePostStream;
 HTTPServer.OnParseAuthentication := @OnParseAuthentication;
 vDatabaseCharSet                := csUndefined;
 {$ELSE}
 HTTPServer.OnQuerySSLPort       := IdHTTPServerQuerySSLPort;
 HTTPServer.OnCommandGet         := aCommandGet;
 HTTPServer.OnCommandOther       := aCommandOther;
 HTTPServer.OnConnect            := CustomOnConnect;
 HTTPServer.OnCreatePostStream   := CreatePostStream;
 HTTPServer.OnParseAuthentication := OnParseAuthentication;
 {$ENDIF}
 HTTPServer.MaxConnections      := -1;
End;

Destructor TRESTDWIdServicePooler.Destroy;
Begin
 Try
  If HTTPServer.Active Then
   HTTPServer.Active := False;
 Except

 End;
 FreeAndNil(lHandler);
 FreeAndNil(HTTPServer);
 Inherited;
End;

Procedure TRESTDWIdServicePooler.EchoPooler(ServerMethodsClass,
                                            AContext            : TComponent;
                                            Var Pooler,
                                            MyIP                : String;
                                            AccessTag           : String;
                                            Var InvalidTag      : Boolean);
Var
 I : Integer;
Begin
 Inherited;
 InvalidTag := False;
 MyIP       := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If (ServerMethodsClass.Components[i].ClassType  = TRESTDWPoolerDB)  Or
        (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) Or
        (UpperCase(ServerMethodsClass.Components[i].ClassName) = 'TRESTDWPOOLERDB') Then
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
          MyIP := TIdContext(AContext).Connection.Socket.Binding.PeerIP;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTDWIdServicePooler.CreatePostStream(AContext        : TIdContext;
                                                  AHeaders        : TIdHeaderList;
                                                  Var VPostStream : TStream);
Var
 headerIndex : Integer;
 vValueAuth  : String;
 vAuthValue  : TRESTDWAuthOAuth;
Begin
 headerIndex := AHeaders.IndexOfName('Authorization');
 If (headerIndex = -1) Then
  Begin
   {$IFNDEF FPC}
    {$IF Not Defined(HAS_FMX)}
     AContext.Data := Nil; // not an Authorization attempt
    {$ELSE}
     {$IFDEF HAS_UTF8}
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := Nil;
     {$ELSE}
      AContext.DataObject := Nil;
     {$ENDIF}
    {$IFEND}
   {$ELSE}
    AContext.Data := Nil; // not an Authorization attempt
   {$ENDIF}
   Exit;
  End
 Else
  Begin
   vValueAuth  := AHeaders[headerIndex];
   If AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken] Then
    Begin
     vAuthValue       := TRESTDWAuthOAuth.Create;
     vAuthValue.Token := vValueAuth;
     {$IFNDEF FPC}
      {$IF Not Defined(HAS_FMX)}
       AContext.Data  := vAuthValue;
      {$ELSE}
       {$IFDEF HAS_UTF8}
        {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND} := vAuthValue;
       {$ELSE}
        AContext.DataObject := vAuthValue;
       {$ENDIF}
      {$IFEND}
     {$ELSE}
      AContext.Data   := vAuthValue;
     {$ENDIF}
     AHeaders.Delete(headerIndex);
    End;
  End;
End;

Procedure TRESTDWIdServicePooler.OnParseAuthentication(AContext    : TIdContext;
                                                   Const AAuthType, AAuthData: String;
                                                   Var VUsername, VPassword: String; Var VHandled: Boolean);
Var
 vAuthValue : TRESTDWAuthOAuth;
Begin
  {$IFNDEF FPC}
   {$IF Not Defined(HAS_FMX)}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.Data        = Nil) Then
     Begin
      vAuthValue       := TRESTDWAuthOAuth.Create;
      vAuthValue.Token := AAuthType + ' ' + AAuthData;
      AContext.Data    := vAuthValue;
      VHandled         := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
   {$ELSE}
    {$IFDEF HAS_UTF8}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       ({$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}  = Nil) Then
     Begin
      vAuthValue          := TRESTDWAuthRequest.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}       := vAuthValue;
      VHandled            := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ELSE}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.DataObject  = Nil) Then
     Begin
      vAuthValue          := TRESTDWAuthRequest.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      AContext.DataObject := vAuthValue;
      VHandled            := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ENDIF}
   {$IFEND}
  {$ELSE}
   If (Lowercase(AAuthType) = Lowercase('bearer')) Or
      (Lowercase(AAuthType) = Lowercase('token'))  And
      (AContext.Data        = Nil) Then
    Begin
     vAuthValue       := TRESTDWAuthRequest.Create;
     vAuthValue.Token := AAuthType + ' ' + AAuthData;
     AContext.Data    := vAuthValue;
     VHandled         := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
    End;
  {$ENDIF}
End;

Function  TRESTDWIdServicePooler.SSLVerifyPeer(Certificate : TIdX509;
                                               AOk         : Boolean;
                                               ADepth,
                                               AError      : Integer) : Boolean;

Begin
 If ADepth = 0 Then
  Result := AOk
 Else
  Result := True;
End;

Procedure TRESTDWIdServicePooler.SetActive(Value: Boolean);
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
      {$IFDEF FPC}
      lHandler.SSLOptions.SSLVersions           := aSSLVersions;
      lHandler.OnGetPassword                    := @GetSSLPassword;
      lHandler.OnVerifyPeer                     := @SSLVerifyPeer;
      {$ELSE}
       {$IF Not(DEFINED(OLDINDY))}
        lHandler.SSLOptions.SSLVersions         := aSSLVersions;
        lHandler.OnVerifyPeer                   := SSLVerifyPeer;
       {$IFEND}
      lHandler.OnGetPassword                    := GetSSLPassword;
      {$ENDIF}
      lHandler.SSLOptions.CertFile              := ASSLCertFile;
      lHandler.SSLOptions.KeyFile               := ASSLPrivateKeyFile;
      lHandler.SSLOptions.VerifyMode            := vSSLVerifyMode;
      lHandler.SSLOptions.VerifyDepth           := vSSLVerifyDepth;
      lHandler.SSLOptions.RootCertFile          := vASSLRootCertFile;
      lHandler.SSLOptions.Mode                  := vSSLMode;
      lHandler.SSLOptions.CipherList            := vCipherList;
      HTTPServer.IOHandler := lHandler;
     End
    Else
     HTTPServer.IOHandler  := Nil;
    If HTTPServer.Bindings.Count > 0 Then
     HTTPServer.Bindings.Clear;
    HTTPServer.Bindings.DefaultPort := ServicePort;
    HTTPServer.DefaultPort          := ServicePort;
    HTTPServer.Active               := True;
   Except
    On E : Exception do
     Begin
      Raise Exception.Create(PChar(E.Message));
     End;
   End;
  End
 Else If Not(Value) Then
  Begin
   If HTTPServer.Active Then
    Begin
     HTTPServer.Contexts.LockList;
     Try
      HTTPServer.Contexts.ClearAndFree;
     Finally
      HTTPServer.Contexts.UnlockList;
     End;
    End;
   HTTPServer.Active := False;
  End;
 Inherited SetActive(HTTPServer.Active);
End;

Procedure TRESTDWIdServicePooler.GetSSLPassWord(var Password: {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                                                     AnsiString
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$IFEND}
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$ENDIF});
Begin
 Password := aSSLPrivateKeyPassword;
End;

{ TRESTDWIdClientPooler }

Procedure TRESTDWIdClientPooler.SetParams(TransparentProxy    : TProxyConnectionInfo;
                                          RequestTimeout      : Integer;
                                          ConnectTimeout      : Integer;
                                          AuthorizationParams : TRESTDWClientAuthOptionParams);
Begin
 HttpRequest.DefaultCustomHeader.Clear;
 HttpRequest.DefaultCustomHeader.NameValueSeparator := cNameValueSeparator;
 HttpRequest.AcceptEncoding              := AcceptEncoding;
 HttpRequest.AuthenticationOptions       := AuthorizationParams;
 HttpRequest.ProxyOptions.ProxyUsername  := TransparentProxy.ProxyUsername;
 HttpRequest.ProxyOptions.ProxyServer    := TransparentProxy.ProxyServer;
 HttpRequest.ProxyOptions.ProxyPassword  := TransparentProxy.ProxyPassword;
 HttpRequest.ProxyOptions.ProxyPort      := TransparentProxy.ProxyPort;
 HttpRequest.RequestTimeout              := RequestTimeout;
 HttpRequest.ConnectTimeout              := ConnectTimeout;
 HttpRequest.ContentType                 := ContentType;
 HttpRequest.AllowCookies                := AllowCookies;
 HttpRequest.HandleRedirects             := HandleRedirects;
 HttpRequest.Charset                     := Charset;
 HttpRequest.UserAgent                   := UserAgent;
End;

Constructor TRESTDWIdClientPooler.Create(AOwner : TComponent);
Begin
 Inherited;
 HttpRequest            := Nil;
 vCipherList            := '';
End;

Destructor TRESTDWIdClientPooler.Destroy;
Begin
 If Assigned(HttpRequest) Then
  FreeAndNil(HttpRequest);
 Inherited;
End;

Procedure TRESTDWIdClientPooler.ReconfigureConnection(Var Connection        : TRESTClientPoolerBase;
                                                      TypeRequest           : Ttyperequest;
                                                      WelcomeMessage,
                                                      Host                  : String;
                                                      Port                  : Integer;
                                                      Compression,
                                                      EncodeStrings         : Boolean;
                                                      Encoding              : TEncodeSelect;
                                                      AccessTag             : String;
                                                      AuthenticationOptions : TRESTDWClientAuthOptionParams);
Begin
 Inherited;
 If (UseSSL) Then
  Begin
   HttpRequest.CertMode              := vSSLMode;
   {$IFDEF FPC}
   HttpRequest.SSLVersions           := aSSLVersions;
   {$ELSE}
    {$IF Not(DEFINED(OLDINDY))}
     HttpRequest.SSLVersions         := aSSLVersions;
    {$IFEND}
   {$ENDIF}
  End;
End;

Function TRESTDWIdClientPooler.SendEvent(EventData       : String;
                                         Var Params      : TRESTDWParams;
                                         EventType       : TSendEvent;
                                         JsonMode        : TJsonMode;
                                         ServerEventName : String;
                                         Assyncexec      : Boolean) : String;
Var
 vErrorMessage,
 vErrorMessageA,
 vDataPack,
 SResult, vURL,
 vResponse,
 vTpRequest       : String;
 I                : Integer;
 vDWParam         : TJSONParam;
 MemoryStream,
 vResultParams    : TStringStream;
 aStringStream,
 bStringStream,
 StringStream     : TStream;
 SendParams       : TIdMultipartFormDataStream;
 StringStreamList : TStringStreamList;
 JSONValue        : TJSONValue;
 aBinaryCompatibleMode,
 aBinaryRequest   : Boolean;
 Procedure SetData(Var InputValue : String;
                   Var ParamsData : TRESTDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue    : TRESTDWJSONInterfaceObject;
  bJsonOBJTemp  : TRESTDWJSONInterfaceArray;
  JSONParam,
  JSONParamNew  : TJSONParam;
  A, InitPos    : Integer;
  vValue,
  aValue,
  vTempValue    : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Begin
    If (Encoding = esUtf8) Then //NativeResult Corre��es aqui
     Begin
      {$IFDEF FPC}
       ResultJSON := GetStringDecode(InputValue, DatabaseCharSet);
      {$ELSE}
       {$IF (CompilerVersion > 22)}
        ResultJSON := PWidechar(InputValue); //PWidechar(UTF8Decode(InputValue));
       {$ELSE}
        ResultJSON := UTF8Decode(ResultJSON); //Corre��o para Delphi's Antigos de Charset.
       {$IFEND}
      {$ENDIF}
     End
    Else
     ResultJSON := InputValue;
    Exit;
   End;
  Try
//   InitPos    := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[') ;
   If (Pos(', "RESULT":[{"MESSAGE":"', InputValue) > 0) Then
    InitPos   := Pos(', "RESULT":[{"MESSAGE":"', InputValue) + Length(', "RESULT":[')   //TODO Brito
   Else If (Pos(', "RESULT":[', InputValue) > 0) Then
    InitPos   := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[')
   Else If (Pos('{"PARAMS":[{"', InputValue) > 0)       And
            (Pos('", "RESULT":', InputValue) > 0)       Then
    InitPos   := Pos('", "RESULT":', InputValue) + Length('", "RESULT":');
   aValue   := Copy(InputValue, InitPos,    Length(InputValue) -1);
   If Pos(']}', aValue) > 0 Then
    aValue     := Copy(aValue, InitStrPos, Pos(']}', aValue) -1);
   vTempValue := aValue;
   InputValue := Copy(InputValue, InitStrPos, InitPos-1) + ']}';//Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If (Params <> Nil) And (InputValue <> '{"PARAMS"]}') And (InputValue <> '') Then
    Begin
     {$IFDEF FPC}
      If Encoding = esUtf8 Then
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(PWidechar(UTF8Decode(InputValue)))
      Else
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(InputValue);
     {$ELSE}
      {$IF (CompilerVersion <= 22)}
       If Encoding = esUtf8 Then //Corre��o para Delphi's Antigos de Charset.
        bJsonValue    := TRESTDWJSONInterfaceObject.Create(PWidechar(UTF8Decode(InputValue)))
       Else
        bJsonValue    := TRESTDWJSONInterfaceObject.Create(InputValue);
      {$ELSE}
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(InputValue);
      {$IFEND}
     {$ENDIF}
     InputValue    := '';
     If bJsonValue.PairCount > 0 Then
      Begin
       bJsonOBJTemp  := TRESTDWJSONInterfaceArray(bJsonValue.OpenArray(bJsonValue.pairs[0].name));
       If bJsonOBJTemp.ElementCount > 0 Then
        Begin
         For A := 0 To bJsonOBJTemp.ElementCount -1 Do
          Begin
           bJsonOBJ := TRESTDWJSONInterfaceObject(bJsonOBJTemp.GetObject(A));
           If Length(bJsonOBJ.Pairs[0].Value) = 0 Then
            Begin
             FreeAndNil(bJsonOBJ);
             Continue;
            End;
           If GetObjectName(bJsonOBJ.Pairs[0].Value) <> toParam Then
            Begin
             FreeAndNil(bJsonOBJ);
             Continue;
            End;
           JSONParam := TJSONParam.Create(Encoding);
           Try
            JSONParam.ParamName       := bJsonOBJ.Pairs[4].name;
            JSONParam.ObjectValue     := GetValueType(bJsonOBJ.Pairs[3].Value);
            JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.Pairs[1].Value);
            JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.Pairs[2].Value);
            If Not(JSONParam.ObjectValue In [ovBlob, ovStream, ovGraphic, ovOraBlob, ovOraClob]) Then
             Begin
              If (JSONParam.Encoded) Then
               Begin
                {$IFDEF FPC}
                 vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                {$ELSE}
                 vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 {$if CompilerVersion < 21}
                 If Encoding = esUtf8 Then
                  vValue := Utf8Decode(vValue);
                 vValue := AnsiString(vValue);
                 {$IFEND}
                {$ENDIF}
               End
              Else If JSONParam.ObjectValue <> ovObject then
               vValue := bJsonOBJ.Pairs[4].Value
              Else                                            //TODO Brito
               Begin
                vValue := bJsonOBJ.Pairs[4].Value;
                DeleteInvalidChar(vValue);
               End;
             End
            Else
             vValue := bJsonOBJ.Pairs[4].Value;
            JSONParam.SetValue(vValue, JSONParam.Encoded);
            //parametro criandos no servidor
            If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
             Begin
              JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
              JSONParamNew.ParamName := JSONParam.ParamName;
              JSONParamNew.ObjectDirection := JSONParam.ObjectDirection;
              JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
              ParamsData.Add(JSONParamNew);
             End
            Else If Not (ParamsData.ItemsString[JSONParam.ParamName].Binary) Then
             ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value
            Else
             ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
           Finally
            FreeAndNil(JSONParam);
            FreeAndNil(bJsonOBJ);
           End;
          End;
        End;
      End;
     If Assigned(bJsonValue) Then
      FreeAndNil(bJsonValue);
     If Assigned(bJsonOBJTemp) Then
      FreeAndNil(bJsonOBJTemp);
    End;
  Finally
   If vTempValue <> '' Then
    ResultJSON := vTempValue;
   vTempValue := '';
  End;
 End;
 Function GetParamsValues(Var DWParams : TRESTDWParams{$IFDEF FPC};vDatabaseCharSet : TDatabaseCharSet{$ENDIF}) : String;
 Var
  I         : Integer;
 Begin
  Result := '';
  JSONValue := Nil;
  If WelcomeMessage <> '' Then
   Result := 'dwwelcomemessage=' + EncodeStrings(WelcomeMessage{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
  If AccessTag <> '' Then
   Begin
    If Result <> '' Then
     Result := Result + '&dwaccesstag=' + EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
    Else
     Result := 'dwaccesstag=' + EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
   End;
  If ServerEventName <> '' Then
   Begin
    If Assigned(DWParams) Then
     Begin
      vDWParam             := DWParams.ItemsString['dwservereventname'];
      If Not Assigned(vDWParam) Then
       Begin
        vDWParam           := TJSONParam.Create(DWParams.Encoding);
        vDWParam.ObjectDirection := odIN;
        DWParams.Add(vDWParam);
       End;
      Try
       vDWParam.Encoded   := True;
       vDWParam.ParamName := 'dwservereventname';
       vDWParam.SetValue(ServerEventName, vDWParam.Encoded);
      Finally
//       FreeAndNil(JSONValue);
      End;
     End
    Else
     Begin
      JSONValue            := TJSONValue.Create;
      Try
       JSONValue.Encoding  := DWParams.Encoding;
       JSONValue.Encoded   := True;
       JSONValue.Tagname   := 'dwservereventname';
       JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
      Finally
       If Result <> '' Then
        Result := Result + '&dwservereventname=' + EncodeStrings(JSONValue.ToJSON{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else
        Result := 'dwservereventname=' + EncodeStrings(JSONValue.ToJSON{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
       FreeAndNil(JSONValue);
      End;
    End;
   End;
  If Result <> '' Then
   Result := Result + '&datacompression=' + BooleanToString(DataCompression)
  Else
   Result := 'datacompression=' + BooleanToString(DataCompression);
  If Result <> '' Then
   Result := Result + '&dwassyncexec=' + BooleanToString(Assyncexec)
  Else
   Result := 'dwassyncexec=' + BooleanToString(Assyncexec);
  If Result <> '' Then
   Result := Result + '&dwencodestrings=' + BooleanToString(EncodedStrings)
  Else
   Result := 'dwencodestrings=' + BooleanToString(EncodedStrings);
  If Result <> '' Then
   Begin
    If Assigned(vCripto) Then
     If vCripto.Use Then
      Result := Result + '&dwusecript=true';
   End
  Else
   Begin
    If Assigned(vCripto) Then
     If vCripto.Use Then
      Result := 'dwusecript=true';
   End;
  If DWParams <> Nil Then
   Begin
    For I := 0 To DWParams.Count -1 Do
     Begin
      If Result <> '' Then
       Begin
        If DWParams.Items[I].ObjectValue in [ovSmallint, ovInteger, ovWord, ovBoolean, ovByte,
                                             ovAutoInc, ovLargeint, ovLongWord, ovShortint, ovSingle] Then
         Result := Result + Format('&%s=%s', [DWParams.Items[I].ParamName, DWParams.Items[I].Value])
        Else
         Begin
          If vCripto.Use Then
           Result := Result + Format('&%s=%s', [DWParams.Items[I].ParamName, vCripto.Encrypt(DWParams.Items[I].Value)])
          Else
           Result := Result + Format('&%s=%s', [DWParams.Items[I].ParamName, EncodeStrings(DWParams.Items[I].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})]);
         End;
       End
      Else
       Begin
        If DWParams.Items[I].ObjectValue in [ovSmallint, ovInteger, ovWord, ovBoolean, ovByte,
                                             ovAutoInc, ovLargeint, ovLongWord, ovShortint, ovSingle] Then
         Result := Format('%s=%s', [DWParams.Items[I].ParamName, DWParams.Items[I].Value])
        Else
         Begin
          If vCripto.Use Then
           Result := Format('%s=%s', [DWParams.Items[I].ParamName, vCripto.Encrypt(DWParams.Items[I].Value)])
          Else
           Result := Format('%s=%s', [DWParams.Items[I].ParamName, EncodeStrings(DWParams.Items[I].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})]);
         End;
       End;
     End;
   End;
//  If Result <> '' Then
//   Result := '?' + Result;
 End;
 Procedure SetParamsValues(DWParams : TRESTDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I         : Integer;
  vCharsset : String;
 Begin
  MemoryStream  := Nil;
  If DWParams   <> Nil Then
   Begin
    If Not (Assigned(StringStreamList)) Then
     StringStreamList := TStringStreamList.Create;
    If BinaryRequest Then
     Begin
      {$IFDEF FPC}
       MemoryStream := TStringStream.Create('');
      {$ELSE}
       MemoryStream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
      {$ENDIF}
      DWParams.SaveToStream(MemoryStream);
      Try
       If Assigned(MemoryStream) Then
        Begin
         MemoryStream.Position := 0;
         {$IFNDEF FPC}
          {$IF (DEFINED(OLDINDY))}
           SendParamsData.AddObject( 'binarydata', 'application/octet-stream', MemoryStream); //StringStreamList.Items[StringStreamList.Count-1]);
          {$ELSE}
           SendParamsData.AddObject( 'binarydata', 'application/octet-stream', '', MemoryStream); //StringStreamList.Items[StringStreamList.Count-1]);
          {$IFEND}
         {$ELSE}
          SendParamsData.AddObject( 'binarydata', 'application/octet-stream', '', MemoryStream); //StringStreamList.Items[StringStreamList.Count-1]);
         {$ENDIF}
        End;
      Finally
      End;
     End
    Else
     Begin
      vCharsset := 'ASCII';
      If Encoding = esUtf8 Then
       vCharsset := 'UTF8';
      For I := 0 To DWParams.Count -1 Do
       Begin
        If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob, ovStream,
                                             ovMemo,   ovGraphic, ovFmtMemo,  ovOraBlob, ovOraClob] Then
         Begin
          StringStreamList.Add({$IFDEF FPC}
                               TStringStream.Create(DWParams.Items[I].ToJSON)
                               {$ELSE}
                               TStringStream.Create(DWParams.Items[I].ToJSON{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND})
                               {$ENDIF});
          {$IFNDEF FPC}
           {$if CompilerVersion > 21}
            SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', vCharsset, StringStreamList.Items[StringStreamList.Count-1]);
           {$ELSE}
            {$IF (DEFINED(OLDINDY))}
             SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', StringStreamList.Items[StringStreamList.Count-1]);
            {$ELSE}
             SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', vCharsset, StringStreamList.Items[StringStreamList.Count-1]);
            {$IFEND}
           {$IFEND}
          {$ELSE}
           SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', vCharsset, StringStreamList.Items[StringStreamList.Count-1]);
          {$ENDIF}
         End
        Else
         SendParamsData.AddFormField(DWParams.Items[I].ParamName, DWParams.Items[I].ToJSON);
       End;
     End;
   End;
 End;
 Function BuildUrl(TpRequest     : TTypeRequest;
                   Host, UrlPath,
                   aDataRoute,
                   aServerContext : String;
                   Port           : Integer) : String;
 Var
  vTpRequest : String;
 Begin
  Result := '';
  If TpRequest = trHttp Then
   vTpRequest := 'http'
  Else If TpRequest = trHttps Then
   vTpRequest := 'https';
  If (aDataRoute = '') And (aServerContext = '') Then
   Result := LowerCase(Format(UrlBase, [vTpRequest, Host, Port, UrlPath])) + EventData
  Else
   Begin
    If (aDataRoute = '') And (aServerContext <> '') Then
     Result := LowerCase(Format(UrlBase,  [vTpRequest, Host, Port, aServerContext + '/', UrlPath])) + EventData
    Else If (aDataRoute <> '') And (aServerContext = '') Then
     Result := LowerCase(Format(UrlBaseA, [vTpRequest, Host, Port, aDataRoute + '/', UrlPath])) + EventData
    Else
     Result := LowerCase(Format(UrlBaseB, [vTpRequest, Host, Port,
                                           aServerContext + '/',
                                           aDataRoute     + '/',
                                           UrlPath])) + EventData
   End;
 End;
 Procedure SetCharsetRequest(Var HttpRequest : TRESTDWIdClientREST;
                             Charset         : TEncodeSelect);
 Begin
  If Charset = esUtf8 Then
   Begin
    HttpRequest.ContentType := 'application/json;charset=utf-8';
    HttpRequest.Charset := 'utf-8';
   End
  Else If Charset in [esANSI, esASCII] Then
   HttpRequest.Charset := 'ansi';
 End;
 Function ExecRequest(EventType : TSendEvent;
                      URL,
                      WelcomeMessage,
                      AccessTag       : String;
                      Charset         : TEncodeSelect;
                      Datacompress,
                      hEncodeStrings,
                      BinaryRequest   : Boolean;
                      Var ResultData,
                      ErrorMessage    : String) : Boolean;
 Var
  vAccessURL,
  vWelcomeMessage,
  vUrl             : String;
  A                : Integer;
  Function BuildValue(Name, Value : String) : String;
  Begin
   If vURL = URL + '?' Then
    Result := Format('%s=%s', [Name, Value])
   Else
    Result := Format('&%s=%s', [Name, Value]);
  End;
 Begin
  Result          := True;
  ResultData      := '';
  ErrorMessage    := '';
  vAccessURL      := '';
  vWelcomeMessage := '';
  vUrl            := '';
  {$IFDEF FPC}
   vResultParams   := TStringStream.Create('');
  {$ELSE}
   vResultParams   := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
  {$ENDIF}
  Try
   HttpRequest.UserAgent       := UserAgent;
   HttpRequest.RedirectMaximum := RedirectMaximum;
   HttpRequest.HandleRedirects := HandleRedirects;
   Case EventType Of
    seGET,
    seDELETE :
     Begin
      HttpRequest.ContentType := 'application/json';
      vURL := URL + '?';
      If WelcomeMessage <> '' Then
       vURL := vURL + BuildValue('dwwelcomemessage', EncodeStrings(WelcomeMessage{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If (AccessTag <> '') Then
       vURL := vURL + BuildValue('dwaccesstag',      EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If AuthenticationOptions.AuthorizationOption    <> rdwAONone Then
       Begin
        Case AuthenticationOptions.AuthorizationOption Of
         rdwAOBearer : Begin
                        If TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                         If TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '' Then
                          vURL := vURL + BuildValue(TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key, TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token);
                       End;
         rdwAOToken  : Begin
                        If TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                         If TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token <> '' Then
                          vURL := vURL + BuildValue(TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key, TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token);
                       End;
        End;
       End;
      vURL := vURL + BuildValue('datacompression',   BooleanToString(Datacompress));
      vURL := vURL + BuildValue('dwassyncexec',      BooleanToString(Assyncexec));
      vURL := vURL + BuildValue('dwencodestrings',   BooleanToString(EncodedStrings));
      vURL := vURL + BuildValue('binaryrequest',     BooleanToString(BinaryRequest));
      If aBinaryCompatibleMode Then
       vURL := vURL + BuildValue('BinaryCompatibleMode', BooleanToString(aBinaryCompatibleMode));
      vURL := Format('%s&%s', [vURL, GetParamsValues(Params{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})]);
      If Assigned(vCripto) Then
       vURL := vURL + BuildValue('dwusecript',       BooleanToString(vCripto.Use));
      {$IFDEF FPC}
       aStringStream := TStringStream.Create('');
      {$ELSE}
       aStringStream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
      {$ENDIF}
      Case EventType Of
       seGET    : HttpRequest.Get(vURL, TStringList(HttpRequest.DefaultCustomHeader), aStringStream);
       seDELETE : Begin
                   {$IFDEF FPC}
                    HttpRequest.Delete(vURL, aStringStream);
                   {$ELSE}
                    {$IFDEF OLDINDY}
                     HttpRequest.Delete(vURL);
                    {$ELSE}
                     //HttpRequest.Delete(AUrl, atempResponse);
                     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, vURL, SendParams, aStringStream, []);
                    {$ENDIF}
                   {$ENDIF}
                  End;
      End;
      If Not Assyncexec Then
       Begin
        If Datacompress Then
         Begin
          If Assigned(aStringStream) Then
           Begin
            If aStringStream.Size > 0 Then
             StringStream := ZDecompressStreamNew(aStringStream);
            FreeAndNil(aStringStream);
            ResultData := TStringStream(StringStream).DataString;
            FreeAndNil(StringStream);
           End;
         End
        Else
         Begin
          ResultData := TStringStream(aStringStream).DataString;
          FreeAndNil(aStringStream);
         End;
       End;
      If Encoding = esUtf8 Then
       ResultData := Utf8Decode(ResultData);
     End;
    sePOST,
    sePUT,
    sePATCH :
     Begin;
      SendParams := TIdMultiPartFormDataStream.Create;
      If WelcomeMessage <> '' Then
       SendParams.AddFormField('dwwelcomemessage', EncodeStrings(WelcomeMessage{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If AccessTag <> '' Then
       SendParams.AddFormField('dwaccesstag',      EncodeStrings(AccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
      If ServerEventName <> '' Then
       Begin
        If Assigned(Params) Then
         Begin
          vDWParam             := Params.ItemsString['dwservereventname'];
          If Not Assigned(vDWParam) Then
           vDWParam           := TJSONParam.Create(Params.Encoding);
          Try
           vDWParam.Encoded         := True;
           vDWParam.ObjectDirection := odIN;
           vDWParam.ParamName       := 'dwservereventname';
           vDWParam.SetValue(ServerEventName, vDWParam.Encoded);
          Finally
           If Params.ItemsString['dwservereventname'] = Nil Then
            Params.Add(vDWParam);
          End;
         End;
        JSONValue           := TJSONValue.Create;
        Try
         JSONValue.Encoding := Charset;
         JSONValue.Encoded  := True;
         JSONValue.Tagname  := 'dwservereventname';
         JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
        Finally
         SendParams.AddFormField('dwservereventname', JSONValue.ToJSON);
         FreeAndNil(JSONValue);
        End;
       End;
//      Else
//       Begin
//        If Assigned(Params) Then
//         Begin
//          For A := 0 To Params.Count -1 Do
//           SendParams.AddFormField(Params[A].ParamName, Params[A].AsString);
//         End;
//       End;
      SendParams.AddFormField('datacompression',   BooleanToString(Datacompress));
      SendParams.AddFormField('dwassyncexec',      BooleanToString(Assyncexec));
      SendParams.AddFormField('dwencodestrings',   BooleanToString(EncodedStrings));
      SendParams.AddFormField('binaryrequest',     BooleanToString(BinaryRequest));
      If AuthenticationOptions.AuthorizationOption    <> rdwAONone Then
       Begin
        If Assigned(Params) Then
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                           Begin
                            If TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '' Then
                             Begin
                              SendParams.AddFormField(TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key,
                                                      TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token);
                              vDWParam             := Params.ItemsString[TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key];
                              If Not Assigned(vDWParam) Then
                               vDWParam           := TJSONParam.Create(Params.Encoding);
                              Try
                               vDWParam.Encoded         := True;
                               vDWParam.ObjectDirection := odIN;
                               vDWParam.ParamName       := TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key;
                               vDWParam.SetValue(TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token, vDWParam.Encoded);
                              Finally
                               If Params.ItemsString[TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key] = Nil Then
                                Params.Add(vDWParam);
                              End;
                             End;
                           End;
                         End;
           rdwAOToken  : Begin
                          If TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                           Begin
                            If TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token <> '' Then
                             Begin
                              SendParams.AddFormField(TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key,
                                                      TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token);
                              vDWParam             := Params.ItemsString[TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key];
                              If Not Assigned(vDWParam) Then
                               vDWParam           := TJSONParam.Create(Params.Encoding);
                              Try
                               vDWParam.Encoded         := True;
                               vDWParam.ObjectDirection := odIN;
                               vDWParam.ParamName       := TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key;
                               vDWParam.SetValue(TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token, vDWParam.Encoded);
                              Finally
                               If Params.ItemsString[TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key] = Nil Then
                                Params.Add(vDWParam);
                              End;
                             End;
                           End;
                         End;
          End;
         End
        Else
         Begin
          Case AuthenticationOptions.AuthorizationOption Of
           rdwAOBearer : Begin
                          If TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                           SendParams.AddFormField(TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key, TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token);
                         End;
           rdwAOToken  : Begin
                          If TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                           SendParams.AddFormField(TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key,  TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token);
                         End;
          End;
         End;
       End;
      If aBinaryCompatibleMode Then
       SendParams.AddFormField('BinaryCompatibleMode', BooleanToString(aBinaryCompatibleMode));
      If Assigned(vCripto) Then
       SendParams.AddFormField('dwusecript',       BooleanToString(vCripto.Use));
      If Params <> Nil Then
       SetParamsValues(Params, SendParams);
      If (Params <> Nil) Or (WelcomeMessage <> '') Or (Datacompress) Then
       Begin
        HttpRequest.Accept          := 'application/json';
        HttpRequest.ContentType     := 'application/x-www-form-urlencoded';
        HttpRequest.ContentEncoding := 'multipart/form-data';
        If TEncodeSelect(Encoding) = esUtf8 Then
         HttpRequest.Charset        := 'Utf-8'
        Else If TEncodeSelect(Encoding) in [esANSI, esASCII] Then
         HttpRequest.Charset        := 'ansi';
        If Not BinaryRequest Then
         While HttpRequest.DefaultCustomHeader.IndexOfName('binaryrequest') > -1 Do
          HttpRequest.DefaultCustomHeader.Delete(HttpRequest.DefaultCustomHeader.IndexOfName('binaryrequest'));
        If Not aBinaryCompatibleMode Then
         While HttpRequest.DefaultCustomHeader.IndexOfName('BinaryCompatibleMode') > -1 Do
          HttpRequest.DefaultCustomHeader.Delete(HttpRequest.DefaultCustomHeader.IndexOfName('BinaryCompatibleMode'));
        HttpRequest.UserAgent := UserAgent;
        If Datacompress Then
         Begin
          {$IFDEF FPC}
           aStringStream := TStringStream.Create('');
          {$ELSE}
           aStringStream := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
          {$ENDIF}
          Case EventType Of
           sePUT    : HttpRequest.Put   (URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
           sePATCH  : Begin
                       {$IFNDEF OLDINDY}
                        {$IFDEF INDY_NEW}
                         {$IF CompilerVersion > 26} // Delphi XE6 pra cima
                          HttpRequest.Patch (URL, SendParams, aStringStream);
                         {$IFEND}
                        {$ENDIF}
                       {$ENDIF}
                      End;
           sePOST   : HttpRequest.Post  (URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
          end;
          If Not Assyncexec Then
           Begin
            If Assigned(aStringStream) Then
             Begin
              If aStringStream.Size > 0 Then
               StringStream := ZDecompressStreamNew(aStringStream);
              FreeAndNil(aStringStream);
             End;
           End;
         End
        Else
         Begin
          StringStream   := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
          Case EventType Of
           sePUT    : HttpRequest.Put   (URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, StringStream);
           sePATCH  : Begin
                       {$IFNDEF OLDINDY}
                        {$IFDEF INDY_NEW}
                         {$IF CompilerVersion > 26} // Delphi XE6 pra cima
                          HttpRequest.Patch (URL, SendParams, StringStream);
                         {$IFEND}
                        {$ENDIF}
                       {$ENDIF}
                      End;
           sePOST   : HttpRequest.Post  (URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, StringStream);
          end;
         End;
        If SendParams <> Nil Then
         Begin
          If Assigned(StringStreamList) Then
           FreeAndNil(StringStreamList);
          {$IFNDEF FPC}
           {$IF Not(DEFINED(OLDINDY))}
            SendParams.Clear;
           {$IFEND}
          {$ENDIF}
          FreeAndNil(SendParams);
         End;
       End
      Else
       Begin
        HttpRequest.ContentType     := 'application/json';
        HttpRequest.ContentEncoding := '';
        HttpRequest.UserAgent       := UserAgent;
        aStringStream               := TStringStream.Create('');
        HttpRequest.Get(URL, TStringList(HttpRequest.DefaultCustomHeader), aStringStream);
        aStringStream.Position := 0;
        StringStream   := TStringStream.Create('');
        bStringStream  := TStringStream.Create('');
        If Not Assyncexec Then
         Begin
          If Datacompress Then
           Begin
            bStringStream.CopyFrom(aStringStream, aStringStream.Size);
            bStringStream.Position := 0;
            ZDecompressStreamD(TStringStream(bStringStream), TStringStream(StringStream));
           End
          Else
           Begin
            bStringStream.CopyFrom(aStringStream, aStringStream.Size);
            bStringStream.Position := 0;
            HexToStream(TStringStream(bStringStream).DataString, TStringStream(StringStream));
           End;
         End;
        FreeAndNil(bStringStream);
        FreeAndNil(aStringStream);
       End;
      If BinaryRequest Then
       Begin
        If Not Assyncexec Then
         Begin
          StringStream.Position := 0;
          Params.LoadFromStream(StringStream);
          {$IFNDEF FPC}
           {$IF CompilerVersion > 21}
            TStringStream(StringStream).Clear;
           {$IFEND}
           StringStream.Size := 0;
          {$ENDIF}
          FreeAndNil(StringStream);
         End;
        ResultData := TReplyOK;
       End
      Else
       Begin
        If Not Assyncexec Then
         Begin
          StringStream.Position := 0;
          If Datacompress Then
           vDataPack := BytesToString(StreamToBytes(TMemoryStream(StringStream)))
          Else
           vDataPack := TStringStream(StringStream).DataString;
          {$IFNDEF FPC}
           {$IF CompilerVersion > 21}
            TStringStream(StringStream).Clear;
           {$IFEND}
           StringStream.Size := 0;
          {$ENDIF}
          FreeAndNil(StringStream);
          If BinaryRequest Then
           Begin
            If Pos(TReplyNOK, vDataPack) > 0 Then
             SetData(vDataPack, Params, ResultData)
            Else
             ResultData := vDataPack
           End
          Else
           SetData(vDataPack, Params, ResultData);
         End;
       End;
     End;
   End;
  Except
   On E : EIdHTTPProtocolException Do
    Begin
     Result := False;
     ResultData := '';
     LastErrorMessage := HttpRequest.LastErrorMessage;
     LastErrorCode    := e.ErrorCode;
     If Pos(Uppercase(cInvalidInternalError), Uppercase(vErrorMessageA)) = 0 Then
      Begin
       vErrorMessage := Trim(vErrorMessageA);
       vErrorMessage := StringReplace(vErrorMessage, '\\', '\', [rfReplaceAll]);
       If Pos(IntToStr(e.ErrorCode), vErrorMessage) > 0 Then
        Begin
         Delete(vErrorMessage, 1, Pos(IntToStr(e.ErrorCode), vErrorMessage) + Length(IntToStr(e.ErrorCode)));
         vErrorMessage := Trim(vErrorMessage);
        End;
       {$IFDEF FPC}
        vErrorMessage := Unescape_chars(vErrorMessage);
       {$ELSE}
        {$IF CompilerVersion <= 22}
         vErrorMessage := Unescape_chars(vErrorMessage);
        {$ELSE}
         vErrorMessage := vErrorMessage;
        {$IFEND}
       {$ENDIF}
      End;
     If e.ErrorCode = 405 Then
      vErrorMessage := cInvalidPoolerName;
     If e.ErrorCode = 401 Then
      Begin
       vErrorMessage := cInvalidAuth;
       //ClearToken to Auto-Renew
       Case AuthenticationOptions.AuthorizationOption Of
        rdwAOBearer : Begin
                       If (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).AutoGetToken) And
                          (TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token <> '')  Then
                        TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token := '';
                      End;
        rdwAOToken  : Begin
                       If (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).AutoGetToken)  And
                          (TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token  <> '')  Then
                        TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token := '';
                      End;
       End;
      End;
     If Assigned(MemoryStream) Then
      FreeAndNil(MemoryStream);
     If Assigned(aStringStream) Then
      FreeAndNil(aStringStream);
     If Assigned(SendParams) then
      FreeAndNil(SendParams);
     If Assigned(vResultParams) then
      FreeAndNil(vResultParams);
     If Assigned(StringStreamList) Then
      FreeAndNil(StringStreamList);
     If Assigned(StringStream) then
      FreeAndNil(StringStream);
     If Assigned(aStringStream) then
      FreeAndNil(aStringStream);
     If Not FailOver then
      Begin
      {$IFNDEF FPC}
       {$IF Defined(HAS_FMX)}
        ErrorMessage := vErrorMessage;
       {$ELSE}
        Raise Exception.Create(vErrorMessage);
       {$IFEND}
      {$ELSE}
       Raise Exception.Create(vErrorMessage);
      {$ENDIF}
      End
     Else
      ErrorMessage := vErrorMessage;
    End;
   On E : Exception Do
    Begin
     Result := False;
     ResultData := GetPairJSONStr('NOK', PoolerNotFoundMessage);
     If Assigned(SendParams) then
      FreeAndNil(SendParams);
     If Assigned(vResultParams) then
      FreeAndNil(vResultParams);
     If Assigned(StringStreamList) Then
      FreeAndNil(StringStreamList);
     If Assigned(StringStream) then
      FreeAndNil(StringStream);
     If Assigned(aStringStream) then
      FreeAndNil(aStringStream);
     If Assigned(MemoryStream) Then
      FreeAndNil(MemoryStream);
     If Not FailOver then
      Begin
       ErrorMessage := E.Message;
      {$IFNDEF FPC}
       {$IF Defined(HAS_FMX)}
        ErrorMessage := PoolerNotFoundMessage;
       {$ELSE}
        Raise Exception.Create(PoolerNotFoundMessage);
       {$IFEND}
      {$ELSE}
       Raise Exception.Create(PoolerNotFoundMessage);
      {$ENDIF}
      End
     Else
      ErrorMessage := e.Message;
    End;
  End;
  If Assigned(vResultParams) Then
   FreeAndNil(vResultParams);
  If Assigned(SendParams) then
   FreeAndNil(SendParams);
  If Assigned(StringStream) then
   FreeAndNil(StringStream);
  If Assigned(MemoryStream) then
   FreeAndNil(MemoryStream);
  If Assigned(aStringStream) Then
   FreeAndNil(aStringStream);
  If Assigned(MemoryStream) Then
   FreeAndNil(MemoryStream);
 End;
Begin
 vDWParam         := Nil;
 MemoryStream     := Nil;
 vResultParams    := Nil;
 aStringStream    := Nil;
 bStringStream    := Nil;
 JSONValue        := Nil;
 SendParams       := Nil;
 StringStreamList := Nil;
 StringStream     := Nil;
 aStringStream    := Nil;
 vResultParams    := Nil;
 aBinaryRequest   := False;
 aBinaryCompatibleMode := False;
 If (Params.ItemsString['BinaryRequest'] <> Nil) Then
  aBinaryRequest  := Params.ItemsString['BinaryRequest'].AsBoolean;
 If (Params.ItemsString['BinaryCompatibleMode'] <> Nil) Then
  aBinaryCompatibleMode := Params.ItemsString['BinaryCompatibleMode'].AsBoolean And aBinaryRequest;
 if Not aBinaryRequest then
  aBinaryRequest  := BinaryRequest;
 vURL  := BuildUrl(TypeRequest, Host, UrlPath,  DataRoute, '', Port);
 If Assigned(HttpRequest) Then
  FreeAndNil(HttpRequest);
 HttpRequest      := TRESTDWIdClientREST.Create(Nil);
 If (TypeRequest = trHttps) Then
  HttpRequest.SSLVersions := SSLVersions;
 HttpRequest.UserAgent := UserAgent;
 SetCharsetRequest(HttpRequest, Encoding);
 SetParams(ProxyOptions, RequestTimeout, ConnectTimeout, AuthenticationOptions);
 HttpRequest.MaxAuthRetries := 0;
 HttpRequest.DefaultCustomHeader.NameValueSeparator := cNameValueSeparator;
 If BinaryRequest Then
  If HttpRequest.DefaultCustomHeader.IndexOfName('binaryrequest') = -1 Then
   HttpRequest.DefaultCustomHeader.AddPair('binaryrequest', 'true');
 If aBinaryCompatibleMode Then
  If HttpRequest.DefaultCustomHeader.IndexOfName('BinaryCompatibleMode') = -1 Then
   HttpRequest.DefaultCustomHeader.AddPair('BinaryCompatibleMode', 'true');
 LastErrorMessage := '';
 LastErrorCode    := -1;
 Try
  If Not ExecRequest(EventType, vURL, WelcomeMessage, AccessTag, Encoding, DataCompression, EncodedStrings, aBinaryRequest, Result, vErrorMessage) Then
   Begin
    If FailOver Then
     Begin
      For I := 0 To FailOverConnections.Count -1 Do
       Begin
        If I = 0 Then
         Begin
          If ((FailOverConnections[I].TypeRequest     = TypeRequest)     And
              (FailOverConnections[I].WelcomeMessage  = WelcomeMessage)  And
              (FailOverConnections[I].Host            = Host)            And
              (FailOverConnections[I].Port            = Port)            And
              (FailOverConnections[I].Compression     = DataCompression) And
              (FailOverConnections[I].hEncodeStrings  = EncodedStrings)  And
              (FailOverConnections[I].Encoding        = Encoding)        And
              (FailOverConnections[I].AccessTag       = AccessTag)       And
              (FailOverConnections[I].UrlPath         = UrlPath))        Or
             (Not (FailOverConnections[I].Active)) Then
          Continue;
         End;
        If Assigned(OnFailOverExecute) Then
         OnFailOverExecute(FailOverConnections[I]);
        vURL  := BuildUrl(FailOverConnections[I].TypeRequest,
                          FailOverConnections[I].Host,
                          FailOverConnections[I].UrlPath,
                          FailOverConnections[I].DataRoute,
                          '',
                          FailOverConnections[I].Port); //LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
        SetCharsetRequest(HttpRequest, FailOverConnections[I].Encoding);
        SetParams(FailOverConnections[I].ProxyOptions,
                  FailOverConnections[I].RequestTimeOut,
                  FailOverConnections[I].ConnectTimeOut,
                  FailOverConnections[I].AuthenticationOptions);
        If ExecRequest(EventType, vURL,
                       FailOverConnections[I].WelcomeMessage,
                       FailOverConnections[I].AccessTag,
                       FailOverConnections[I].Encoding,
                       FailOverConnections[I].Compression,
                       FailOverConnections[I].hEncodeStrings,
                       BinaryRequest,
                       Result, vErrorMessage) Then
         Begin
          If FailOverReplaceDefaults Then
           Begin
            TypeRequest     := FailOverConnections[I].TypeRequest;
            WelcomeMessage  := FailOverConnections[I].WelcomeMessage;
            Host            := FailOverConnections[I].Host;
            Port            := FailOverConnections[I].Port;
            DataCompression := FailOverConnections[I].Compression;
            ProxyOptions    := FailOverConnections[I].ProxyOptions;
            EncodedStrings  := FailOverConnections[I].hEncodeStrings;
            Encoding        := FailOverConnections[I].Encoding;
            AccessTag       := FailOverConnections[I].AccessTag;
            UrlPath         := FailOverConnections[I].UrlPath;
            RequestTimeout  := FailOverConnections[I].RequestTimeOut;
            ConnectTimeout  := FailOverConnections[I].ConnectTimeOut;
            DataRoute       := FailOverConnections[I].DataRoute;
           End;
          Break;
         End
        Else
         Begin
          If Assigned(OnFailOverError) Then
           Begin
            OnFailOverError(FailOverConnections[I], vErrorMessage);
            vErrorMessage := '';
           End;
         End;
       End;
     End;
   End;
 Finally
  If (vErrorMessage <> '') Then
   Begin
    Result := vErrorMessage;
    Raise Exception.Create(Result);
   End;
  If Assigned(HttpRequest) Then
   FreeAndNil(HttpRequest);
 End;
End;

{ TRESTDWIdDatabase }

Constructor TRESTDWIdDatabase.Create(AOwner: TComponent);
Begin
 Inherited;
 HttpRequest            := Nil;
 vCipherList            := '';
 RESTClientPooler       := TRESTDWIdClientPooler.Create(Self);
End;

Destructor TRESTDWIdDatabase.Destroy;
Begin
 If Assigned(HttpRequest) Then
  FreeAndNil(HttpRequest);
 DestroyClientPooler;
 Inherited;
End;

Procedure TRESTDWIdDatabase.SetParams(TransparentProxy    : TProxyConnectionInfo;
                                      RequestTimeout      : Integer;
                                      ConnectTimeout      : Integer;
                                      AuthorizationParams : TRESTDWClientAuthOptionParams);
Begin
 HttpRequest.DefaultCustomHeader.Clear;
 HttpRequest.AcceptEncoding              := AcceptEncoding;
 HttpRequest.AuthenticationOptions       := AuthorizationParams;
 HttpRequest.ProxyOptions.ProxyUsername  := TransparentProxy.ProxyUsername;
 HttpRequest.ProxyOptions.ProxyServer    := TransparentProxy.ProxyServer;
 HttpRequest.ProxyOptions.ProxyPassword  := TransparentProxy.ProxyPassword;
 HttpRequest.ProxyOptions.ProxyPort      := TransparentProxy.ProxyPort;
 HttpRequest.RequestTimeout              := RequestTimeout;
 HttpRequest.ConnectTimeout              := ConnectTimeout;
 HttpRequest.ContentType                 := ContentType;
// HttpRequest.AllowCookies                := AllowCookies;
 HttpRequest.HandleRedirects             := HandleRedirects;
 HttpRequest.Charset                     := Charset;
 HttpRequest.UserAgent                   := UserAgent;
End;

End.