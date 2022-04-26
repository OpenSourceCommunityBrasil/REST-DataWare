unit uRESTDWIdBase;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
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
 {$IFDEF FPC}
 SysUtils,      Classes, Db, Variants, {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
 uRESTDWBasic, uRESTDWBasicDB, uRESTDWConsts, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
 uRESTDWParams, uRESTDWAbout
 {$ELSE}
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, Db, Variants, EncdDecd, SyncObjs, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWAbout
  {$ELSE}
   System.SysUtils, System.Classes, Data.Db, Variants, system.SyncObjs, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWAbout,
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
 ,DataUtils, IdContext, IdHeaderList,   IdTCPConnection,     IdHTTPServer,       IdCustomHTTPServer, IdSSLOpenSSL,  IdSSL,
 IdAuthentication,           IdTCPClient,         IdHTTPHeaderInfo,   IdComponent,        IdBaseComponent,
 IdHTTP,                     IdMultipartFormData, IdMessageCoder,     IdMessage,          IdGlobalProtocols,
 IdGlobal,  IdStack;

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
  Procedure GetSSLPassWord (Var Password              : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                                                     AnsiString
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$IFEND}
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$ENDIF});
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
 TRESTDWIdServiceCGI = Class(TRESTServiceShareBase)
End;

Type
 TRESTDWIdDatabase = Class(TRESTDWDatabasebaseBase)
End;

Type
 TRESTDWIdClientPooler = Class(TRESTClientPoolerBase)
End;

Type
 TRESTDWIdClientREST = Class(TRESTDWClientRESTBase)
 Private
  HttpRequest      : TIdHTTP;
  vVerifyCert      : Boolean;
  vCertFile,
  vKeyFile,
  vRootCertFile,
  vHostCert        : String;
  vPortCert        : Integer;
  vOnGetpassword   : TOnGetpassword;
  vSSLVersions     : TIdSSLVersions;
  ssl              : TIdSSLIOHandlerSocketOpenSSL;
  vCertMode        : TIdSSLMode;
  vTransparentProxy                               : TIdProxyConnectionInfo;
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
  Function  GetAllowCookies                       : Boolean;
  Procedure SetAllowCookies   (Value              : Boolean);
  Function  GetHandleRedirects                    : Boolean;
  Procedure SetHandleRedirects(Value              : Boolean);
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
  Property AllowCookies             : Boolean                     Read GetAllowCookies           Write SetAllowCookies;
  Property HandleRedirects          : Boolean                     Read GetHandleRedirects        Write SetHandleRedirects;
  Property VerifyCert               : Boolean                     Read GetVerifyCert             Write SetVerifyCert;
  Property SSLVersions              : TIdSSLVersions              Read vSSLVersions              Write vSSLVersions;
  Property CertMode                 : TIdSSLMode                  Read vCertMode                 Write vCertMode;
  Property CertFile                 : String                      Read vCertFile                 Write vCertFile;
  Property KeyFile                  : String                      Read vKeyFile                  Write vKeyFile;
  Property RootCertFile             : String                      Read vRootCertFile             Write vRootCertFile;
  Property HostCert                 : String                      Read vHostCert                 Write vHostCert;
  Property PortCert                 : Integer                     Read vPortCert                 Write vPortCert;
  Property ProxyOptions             : TIdProxyConnectionInfo      Read vTransparentProxy         Write vTransparentProxy;
  Property OnGetpassword            : TOnGetpassword              Read vOnGetpassword            Write vOnGetpassword;
End;

implementation

Uses uRESTDWTools;

{ TRESTDWIdClientREST }

Destructor TRESTDWIdClientREST.Destroy;
Begin
 FreeAndNil(HttpRequest);
 FreeAndNil(vTransparentProxy);
 Inherited;
End;

Function TRESTDWIdClientREST.Get(AUrl            : String         = '';
                                 CustomHeaders   : TStringList    = Nil;
                                 Const AResponse : TStream        = Nil;
                                 IgnoreEvents    : Boolean        = False) : Integer;
Begin

End;

Function   TRESTDWIdClientREST.Get(AUrl            : String         = '';
                                   CustomHeaders   : TStringList    = Nil;
                                   IgnoreEvents    : Boolean        = False) : String;
Begin

End;

Function   TRESTDWIdClientREST.Post(AUrl             : String         = '';
                                    CustomHeaders    : TStringList    = Nil;
                                    Const CustomBody : TStream        = Nil;
                                    IgnoreEvents     : Boolean        = False;
                                    RawHeaders       : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Post(AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Post(AUrl            : String;
                                    Var AResponseText : String;
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomParams    : TStringList    = Nil;
                                    Const CustomBody : TStream       = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Post(AUrl            : String;
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomParams    : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Put(AUrl            : String         = '';
                                  CustomHeaders   : TStringList    = Nil;
                                  Const AResponse : TStream        = Nil;
                                  IgnoreEvents    : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Put(AUrl            : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   Const CustomBody : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   FileName         : String         = '';
                                   FileStream       : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   CustomParams     : TStringList    = Nil;
                                   Const CustomBody : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Put(AUrl             : String         = '';
                                   CustomHeaders    : TStringList    = Nil;
                                   CustomParams     : TStringList    = Nil;
                                   FileName         : String         = '';
                                   FileStream       : TStream        = Nil;
                                   Const AResponse  : TStream        = Nil;
                                   IgnoreEvents     : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomBody      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     CustomParams    : TStringList    = Nil;
                                     CustomBody      : TStream        = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Patch(AUrl            : String         = '';
                                     CustomHeaders   : TStringList    = Nil;
                                     CustomParams    : TStringList    = Nil;
                                     FileName        : String         = '';
                                     FileStream      : TStream        = Nil;
                                     Const AResponse : TStream        = Nil;
                                     IgnoreEvents    : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Delete(AUrl            : String         = '';
                                      CustomHeaders   : TStringList    = Nil;
                                      Const AResponse : TStream        = Nil;
                                      IgnoreEvents    : Boolean        = False):Integer;
Begin

End;

Function   TRESTDWIdClientREST.Delete(AUrl              : String;
                                      CustomHeaders     : TStringList  = Nil;
                                      CustomParams      : TStringList  = Nil;
                                      Const AResponse   : TStream      = Nil;
                                      IgnoreEvents      : Boolean      = False):Integer;
Begin

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

Function TRESTDWIdClientREST.GetAllowCookies : Boolean;
Begin
 Result := HttpRequest.AllowCookies;
End;

Function TRESTDWIdClientREST.GetHandleRedirects : Boolean;
begin
 Result := HttpRequest.HandleRedirects;
End;

Procedure TRESTDWIdClientREST.SetAllowCookies(Value: Boolean);
Begin
 HttpRequest.AllowCookies    := Value;
End;

Procedure TRESTDWIdClientREST.SetHandleRedirects(Value: Boolean);
Begin
 HttpRequest.HandleRedirects := Value;
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
 vUriOptions : TRESTDWUriOptions;
 vmark       : String;
 DWParams    : TRESTDWParams;
Begin
 Inherited;
 vUriOptions := TRESTDWUriOptions.Create;
 vmark       := '';
 DWParams    := Nil;
 HttpRequest.Request.AcceptEncoding := AcceptEncoding;
 HttpRequest.Request.CustomHeaders.Clear;
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
                   TDataUtils.ParseRESTURL(ActiveRequest, RequestCharset, vUriOptions, vmark{$IFDEF FPC}, csUndefined{$ENDIF}, DWParams, 2);
                   If Assigned(DWParams) Then
                    FreeAndNil(DWParams);
                   If (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.EventName))   Or
                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent))  Or
                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.EventName))  Or
                      (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.ServerEvent)) Then
                    Begin
                     If (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.EventName))  Or
                        (Lowercase(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent)) Then
                      Begin
                       If TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).AutoBuildHex Then
                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
                                                                                                               TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
                                                                                                               {$IFDEF FPC}, csUndefined{$ENDIF})]))
                       Else
                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientID + ':' +
                                                                                                               TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).ClientSecret
                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]));
                      End;
                    End
                   Else
                    Begin
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
                    End;
                  End;
   End;
  End;
//  HttpRequest.Request.CustomHeaders.Values['Authorization'] := vServerParams.Authentication;
 If Assigned(vUriOptions) Then
  FreeAndnil(vUriOptions);
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
 ResultStream    : TMemoryStream;
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
 ResultStream    := TMemoryStream.Create;
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
  If CommandExec  (RemoveBackslashCommands(ARequestInfo.URI),
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
      AResponseInfo.FreeContentStream        := True;
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
     AResponseInfo.ResponseText            := ErrorMessage;
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
      vAuthValue          := TRDWAuthRequest.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      {$IF CompilerVersion > 33}AContext.Data{$ELSE}AContext.DataObject{$IFEND}       := vAuthValue;
      VHandled            := AuthenticationOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ELSE}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.DataObject  = Nil) Then
     Begin
      vAuthValue          := TRDWAuthRequest.Create;
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
     vAuthValue       := TRDWAuthRequest.Create;
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

End.
