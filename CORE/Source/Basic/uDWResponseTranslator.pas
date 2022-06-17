unit uDWResponseTranslator;

{$I uRESTDW.inc}
{$IFDEF FPC}
 {$mode objfpc}{$H+}
{$ENDIF}
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
 Ivan Cesar                 - Admin - Administrador do CORE do pacote.
 Joanan Mendonça Jr. (jlmj) - Admin - Administrador do CORE do pacote.
 Giovani da Cruz            - Admin - Administrador do CORE do pacote.
 A. Brito                   - Admin - Administrador do CORE do pacote.
 Ico Menezes                - Admin - Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Ari                        - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Alexandre Souza            - Admin - Administrador do Grupo de Organização.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Mizael Rocha               - Member Tester and DEMO Developer.
 Flávio Motta               - Member Tester and DEMO Developer.
 Itamar Gaucho              - Member Tester and DEMO Developer.
}

interface

Uses uDWAbout, uDWConstsCharset,
     {$IFDEF FPC}
      ServerUtils, uDWConsts, SysUtils, Classes,
     {$ELSE}
     {$IF CompilerVersion <= 22}
      SysUtils, Classes,
     {$ELSE}
      System.SysUtils, System.Classes,
     {$IFEND}
      ServerUtils, uDWConsts,
     {$ENDIF}
     {$IFNDEF LAMW}
      IdContext, IdTCPConnection, IdHTTPServer,        IdCustomHTTPServer, IdSSLOpenSSL,  IdSSL,
      IdAuthentication,           IdTCPClient,         IdHTTPHeaderInfo,   IdComponent,   IdBaseComponent,
      IdHTTP,                     IdMultipartFormData, IdMessageCoder,     IdMessage,     IdGlobalProtocols,
      IdGlobal,  IdStack
     {$ELSE} //For Lamw
      IdComponent
     {$ENDIF};

Type
 TOnGetpassword      = Procedure (Var Password      : String)              Of Object;
 TOnWork             = Procedure (ASender           : TObject;
                                  AWorkMode         : TWorkMode;
                                  AWorkCount        : Int64)               Of Object;
 TOnWorkBegin        = Procedure (ASender           : TObject;
                                  AWorkMode         : TWorkMode;
                                  AWorkCountMax     : Int64)               Of Object;
 TOnWorkEnd          = Procedure (ASender           : TObject;
                                  AWorkMode         : TWorkMode)           Of Object;
 TOnStatus           = Procedure (ASender           : TObject;
                                  Const AStatus     : TIdStatus;
                                  Const AStatusText : String)              Of Object;
 TPrepareGet         = Procedure (Var AUrl          : String;
                                  Var AHeaders      : TStringList) Of Object;
 TPrepareEvent       = Procedure (Var AUrl          : String;
                                  Var AHeaders      : TStringList) Of Object;
 TAfterRequest       = Procedure (AUrl              : String;
                                  ResquestType      : TRequestType;
                                  AResponse         : TStream)  Of Object;
 { Evento para obter cabeçalho da resposta http - Ico Menezes 20/05/2019 }
 TOnHeadersAvailable = Procedure (AHeaders: TStringList;
                                 VContinue: Boolean) Of Object;


Type
 TDWFieldDef = Class;
 TDWFieldDef = Class(TCollectionItem)
 Private
  vElementName,
  vFieldName    : String;
  vElementIndex,
  vFieldSize,
  vPrecision    : Integer;
  vDataType     : TObjectValue;
  vRequired     : Boolean;
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Constructor Create        (aCollection : TCollection); Override;
 Published
  Property    FieldName    : String       Read GetDisplayName Write SetDisplayName;
  Property    ElementName  : String       Read vElementName   Write vElementName;
  Property    ElementIndex : Integer      Read vElementIndex  Write vElementIndex;
  Property    FieldSize    : Integer      Read vFieldSize     Write vFieldSize;
  Property    Precision    : Integer      Read vPrecision     Write vPrecision;
  Property    DataType     : TObjectValue Read vDataType      Write vDataType;
  Property    Required     : Boolean      Read vRequired      Write vRequired;
End;

Type
 TDWFieldDefs = Class;
 TDWFieldDefs = Class(TOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TDWFieldDef;  Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWFieldDef);            Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWFieldDef;  Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWFieldDef);            Overload;
 Public
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete        (Index   : Integer);                   Overload;
  Property    Items         [Index   : Integer]   : TDWFieldDef Read GetRec     Write PutRec; Default;
  Property    FieldDefByName[Index   : String ]   : TDWFieldDef Read GetRecName Write PutRecName;
End;

Type
 TDWClientREST = Class(TDWComponent) //Novo Componente de Acesso a Requisições REST para o Servidores Diversos
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  HttpRequest          : TIdHTTP;
  vRSCharset           : TEncodeSelect;
  vRedirectMaximum     : Integer;
  Procedure SetParams         (Const aHttpRequest : TIdHTTP);
  Procedure SetOnWork         (Value              : TOnWork);
  Procedure SetOnWorkBegin    (Value              : TOnWorkBegin);
  Procedure SetOnWorkEnd      (Value              : TOnWorkEnd);
  Procedure SetOnStatus       (Value              : TOnStatus);
  Function  GetAllowCookies                       : Boolean;
  Procedure SetAllowCookies   (Value              : Boolean);
  Function  GetHandleRedirects                    : Boolean;
  Procedure SetHandleRedirects(Value              : Boolean);
 Private
  //Variáveis, Procedures e Funções Privadas
  vDefaultCustomHeader : TStrings;
  aSSLMethod           : TIdSSLVersion;
  vSSLVersions         : TIdSSLVersions;
  ssl                  : TIdSSLIOHandlerSocketOpenSSL;
  vOnWork              : TOnWork;
  vOnWorkBegin         : TOnWorkBegin;
  vOnWorkEnd           : TOnWorkEnd;
  vOnStatus            : TOnStatus;
  vAuthOptionParams    : TRDWClientAuthOptionParams;
  vMaxAuthRetries      : Integer;
  vAUrl,
  vContentEncoding,
  vAccept,
  vAccessControlAllowOrigin,
  vUserAgent,
  vAcceptEncoding,
  vContentType         : String;
  vUseSSL,
  vVerifyCert          : Boolean;
  vTransparentProxy    : TIdProxyConnectionInfo;
  vConnectTimeOut,
  vRequestTimeOut      : Integer;
  vOnBeforeGet         : TPrepareGet;
  vOnBeforePost,
  vOnBeforePut,
  vOnBeforeDelete,
  vOnBeforePatch       : TPrepareEvent;
  vOnAfterRequest      : TAfterRequest;
  vOnHeadersAvailable  : TOnHeadersAvailable;
  vCertFile,
  vKeyFile,
  vRootCertFile,
  vHostCert            : String;
  vPortCert            : Integer;
  vOnGetpassword       : TOnGetpassword;
  vCertMode            : TIdSSLMode;
  Procedure SetCertOptions;
  Procedure Getpassword  (Var Password : String);
  Function  GetVerifyCert              : Boolean;
  Procedure SetVerifyCert(aValue       : Boolean);
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
  Procedure SetHeaders (AHeaders         : TStringList;
                        Var SendParams   : TIdMultipartFormDataStream);Overload;
  Procedure SetHeaders (AHeaders         : TStringList);Overload;
  Procedure SetRawHeaders(AHeaders       : TStringList;
                          Var SendParams : TIdMultipartFormDataStream);
  Procedure SetUseSSL    (Value          : Boolean);
  Procedure CopyStringList(Const Source, Dest : TStringList);
  Procedure SetDefaultCustomHeader(Value : TStrings);
  Procedure SetAuthOptionParams(Value    : TRDWClientAuthOptionParams);
 Public
  Constructor Create           (AOwner   : TComponent);Override;
  Destructor  Destroy;Override;
  { Alteração feita por Ico Menezes - Foi necessario mudar todos os metodos de requisicao
  para FUNCTION, haja vista que o Result sera sempre o Status Code da requisicao !!!
  Data da alteracao : 12-05-2019 }
  Function   Get       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Get       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Get       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        IgnoreEvents    : Boolean        = False):String; Overload;
  Function   Get       (AUrl            : String;
                        var AResponseText : String;
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStream        = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        FileName        : String         = '';
                        FileStream      : TMemoryStream  = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;
  Function   Post      (AUrl            : String;
                        var AResponseText : String;
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;
  Function   Put       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Put       (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Put       (AUrl            : String;
                        var AResponseText : String;
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Patch     (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Patch     (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Patch     (AUrl            : String;
                        var AResponseText : String;
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer;Overload;
  Function   Delete    (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False):Integer; Overload;
  Function   Delete    (AUrl              : String;
                        var AResponseText : String;
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStringStream  = Nil;
                        IgnoreEvents      : Boolean        = False):Integer; Overload;
 Published
  Property UseSSL                   : Boolean                     Read vUseSSL                   Write vUseSSL;
  Property CertMode                 : TIdSSLMode                  Read vCertMode                 Write vCertMode;
  Property SSLMethod                : TIdSSLVersion               Read aSSLMethod                Write aSSLMethod;
  Property SSLVersions              : TIdSSLVersions              Read vSSLVersions              Write vSSLVersions;
  Property CertFile                 : String                      Read vCertFile                 Write vCertFile;
  Property KeyFile                  : String                      Read vKeyFile                  Write vKeyFile;
  Property RootCertFile             : String                      Read vRootCertFile             Write vRootCertFile;
  Property HostCert                 : String                      Read vHostCert                 Write vHostCert;
  Property PortCert                 : Integer                     Read vPortCert                 Write vPortCert;
  Property OnGetpassword            : TOnGetpassword              Read vOnGetpassword            Write vOnGetpassword;
  Property UserAgent                : String                      Read vUserAgent                Write vUserAgent;
  Property Accept                   : String                      Read vAccept                   Write vAccept;
  Property AcceptEncoding           : String                      Read vAcceptEncoding           Write vAcceptEncoding;
  Property ContentEncoding          : String                      Read vContentEncoding          Write vContentEncoding;
  Property MaxAuthRetries           : Integer                     Read vMaxAuthRetries           Write vMaxAuthRetries;
  Property ContentType              : String                      Read vContentType              Write vContentType;
  Property RequestCharset           : TEncodeSelect               Read vRSCharset                Write vRSCharset;
  Property DefaultCustomHeader      : TStrings                    Read vDefaultCustomHeader      Write SetDefaultCustomHeader;
  Property ProxyOptions             : TIdProxyConnectionInfo      Read vTransparentProxy         Write vTransparentProxy;
  Property RequestTimeOut           : Integer                     Read vRequestTimeOut           Write vRequestTimeOut;
  Property ConnectTimeOut           : Integer                     Read vConnectTimeOut           Write vConnectTimeOut;
  Property AllowCookies             : Boolean                     Read GetAllowCookies           Write SetAllowCookies;
  Property HandleRedirects          : Boolean                     Read GetHandleRedirects        Write SetHandleRedirects;
  Property RedirectMaximum          : Integer                     Read vRedirectMaximum          Write vRedirectMaximum;
  Property VerifyCert               : Boolean                     Read GetVerifyCert             Write SetVerifyCert;
  Property AuthenticationOptions    : TRDWClientAuthOptionParams  Read vAuthOptionParams         Write SetAuthOptionParams;
  Property AccessControlAllowOrigin : String                      Read vAccessControlAllowOrigin Write vAccessControlAllowOrigin;
  Property OnWork                   : TOnWork                     Read vOnWork                   Write SetOnWork;
  Property OnWorkBegin              : TOnWorkBegin                Read vOnWorkBegin              Write SetOnWorkBegin;
  Property OnWorkEnd                : TOnWorkEnd                  Read vOnWorkEnd                Write SetOnWorkEnd;
  Property OnStatus                 : TOnStatus                   Read vOnStatus                 Write SetOnStatus;
  Property OnBeforeGet              : TPrepareGet                 Read vOnBeforeGet              Write vOnBeforeGet;
  Property OnBeforePost             : TPrepareEvent               Read vOnBeforePost             Write vOnBeforePost;
  Property OnBeforePut              : TPrepareEvent               Read vOnBeforePut              Write vOnBeforePut;
  Property OnBeforeDelete           : TPrepareEvent               Read vOnBeforeDelete           Write vOnBeforeDelete;
  Property OnBeforePatch            : TPrepareEvent               Read vOnBeforePatch            Write vOnBeforePatch;
  Property OnAfterRequest           : TAfterRequest               Read vOnAfterRequest           Write vOnAfterRequest;
  // Add event OnHeaders - Ico Menezes
  Property OnHeadersAvailable       : TOnHeadersAvailable         Read vOnHeadersAvailable       Write vOnHeadersAvailable;
End;

Type
 TDWResponseTranslator = Class(TDWComponent)
 Private
  vOpenRequest,
  vInsertRequest,
  vEditRequest,
  vDeleteRequest        : TRequestType;
  vRequestOpenUrl,
  vRequestInsertUrl,
  vRequestEditUrl,
  vRequestDeleteUrl,
  vElementBaseName,
  aValue                : String;
  fOwner                : TPersistent;
  vDWClientREST         : TDWClientREST;
  vDWFieldDefs          : TDWFieldDefs;
  vElementBaseIndex     : Integer;
  vAutoReadElementIndex : Boolean;
  vJSONEditor           : TStringList;
  Procedure   ReadData    (Value  : String);
  procedure SetJSONEditor(const Value: TStringList);
  function GetDWClientREST: TDWClientREST;
  procedure SetDWClientREST(const Value: TDWClientREST);
 Protected
  procedure Notification(AComponent: TComponent; Operation: TOperation); override;
 Public
  Constructor Create      (AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
  Function    Open        (ResquestType : TRequestType;
                           RequestURL   : String) : String;
  Procedure   ApplyUpdates(ResquestType : TRequestType);
  Procedure   GetFieldDefs(JSONBase : String = '');
 Published
  Property ElementAutoReadRootIndex : Boolean       Read vAutoReadElementIndex Write vAutoReadElementIndex;
  Property ElementRootBaseIndex     : Integer       Read vElementBaseIndex     Write vElementBaseIndex;
  Property ElementRootBaseName      : String        Read vElementBaseName      Write vElementBaseName;
  Property RequestOpen              : TRequestType  Read vOpenRequest          Write vOpenRequest;
  Property RequestInsert            : TRequestType  Read vInsertRequest        Write vInsertRequest;
  Property RequestEdit              : TRequestType  Read vEditRequest          Write vEditRequest;
  Property RequestDelete            : TRequestType  Read vDeleteRequest        Write vDeleteRequest;
  Property RequestOpenUrl           : String        Read vRequestOpenUrl       Write vRequestOpenUrl;
  Property RequestInsertUrl         : String        Read vRequestInsertUrl     Write vRequestInsertUrl;
  Property RequestEditUrl           : String        Read vRequestEditUrl       Write vRequestEditUrl;
  Property RequestDeleteUrl         : String        Read vRequestDeleteUrl     Write vRequestDeleteUrl;
  Property FieldDefs                : TDWFieldDefs  Read vDWFieldDefs          Write vDWFieldDefs;
  Property ClientREST               : TDWClientREST Read GetDWClientREST       Write SetDWClientREST;
  Property JSONEditor               : TStringList   Read vJSONEditor           Write SetJSONEditor;
End;

Type
 TIdHTTPAccess = class(TIdHTTP)
End;

Implementation

Uses uDWJSONTools, uDWJSONObject, SysTypes;

{ TDWResponseTranslator }

Procedure TDWResponseTranslator.ApplyUpdates(ResquestType : TRequestType);
Begin

End;

Constructor TDWResponseTranslator.Create(AOwner : TComponent);
Begin
 Inherited;
 fOwner                := AOwner;
 vElementBaseIndex     := -1;
 vElementBaseName      := '';
 vAutoReadElementIndex := True;
 vDWFieldDefs          := TDWFieldDefs.Create(Self, TDWFieldDef);
 vOpenRequest          := rtGet;
 vInsertRequest        := rtPost;
 vEditRequest          := rtPost;
 vDeleteRequest        := rtDelete;
 vJSONEditor           := TStringList.Create;
End;

Destructor TDWResponseTranslator.Destroy;
begin
 FreeAndNil(vDWFieldDefs);
 FreeAndNil(vJSONEditor);
 Inherited;
end;

function TDWResponseTranslator.GetDWClientREST: TDWClientREST;
begin
  Result := vDWClientREST;
end;

Procedure TDWResponseTranslator.GetFieldDefs(JSONBase : String = '');
Var
 vValue       : String;
 LDataSetList : TJSONValue;
Begin
 vValue := JSONBase;
 If Trim(vValue) = '' Then
  vValue := Open(RequestOpen, RequestOpenUrl);
 LDataSetList := TJSONValue.Create;
 Try
  LDataSetList.Encoded  := False;
  If Assigned(ClientREST) Then
   LDataSetList.Encoding := ClientREST.RequestCharset;
  LDataSetList.WriteToFieldDefs(vValue, Self);
 Finally
  FreeAndNil(LDataSetList);
 End;
End;

procedure TDWResponseTranslator.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = vDWClientREST) then
  begin
    vDWClientREST := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

Function TDWResponseTranslator.Open(ResquestType : TRequestType;
                                    RequestURL   : String) : String;
Var
 vResult : TStringStream;
Begin
 Result  := '';
 {$IFDEF FPC}
  vResult  := TStringStream.Create('');
 {$ELSE}
  {$if CompilerVersion > 21}
   vResult := TStringStream.Create;
  {$ELSE}
   vResult := TStringStream.Create('');
  {$IFEND}
 {$ENDIF}
 Try
  Case ResquestType Of
   rtGet  : ClientREST.Get (RequestURL, Nil, vResult);
   rtPost : ClientREST.Post(RequestURL, Nil, vResult);
  End;
 Finally
  {$IFDEF FPC}
   Result  := StringReplace(vResult.DataString, #10, '', [rfReplaceAll]);
  {$ELSE}
   Result  := StringReplace(vResult.DataString, #$A, '', [rfReplaceAll]);
  {$ENDIF}
  FreeAndNil(vResult);
 End;
End;

Procedure TDWResponseTranslator.ReadData(Value : String);
Begin
 aValue := Value;
End;

Procedure TDWResponseTranslator.SetDWClientREST(const Value: TDWClientREST);
Begin
 If vDWClientREST <> Value Then
  vDWClientREST := Value;
 If vDWClientREST <> nil then
  vDWClientREST.FreeNotification(Self);
End;

procedure TDWResponseTranslator.SetJSONEditor(const Value: TStringList);
Var
 I : Integer;
Begin
 vJSONEditor.Clear;
 For I := 0 To Value.Count -1 do
  vJSONEditor.Add(Value[I]);
end;

{ TDWFieldDefs }

Procedure TDWFieldDefs.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TDWFieldDefs.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWFieldDef);
 Self.fOwner := AOwner;
End;

Procedure TDWFieldDefs.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
End;

Destructor TDWFieldDefs.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TDWFieldDefs.GetRec(Index: Integer): TDWFieldDef;
Begin
 Result := TDWFieldDef(inherited GetItem(Index));
End;

Function TDWFieldDefs.GetRecName(Index: String): TDWFieldDef;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FieldName))   Or
      (Uppercase(Index) = Uppercase(Self.Items[I].ElementName)) Then
    Begin
     Result := TDWFieldDef(Self.Items[I]);
     Break;
    End;
  End;
End;

Procedure TDWFieldDefs.PutRec(Index: Integer; Item: TDWFieldDef);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

Procedure TDWFieldDefs.PutRecName(Index: String; Item: TDWFieldDef);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FieldName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
    End;
  End;
End;

{ TDWFieldDef }

Constructor TDWFieldDef.Create(aCollection: TCollection);
Begin
 Inherited;
 vFieldName    :=  'dwFieldDef' + IntToStr(aCollection.Count);
 vElementName  := vFieldName;
 vDataType     := ovString;
 vFieldSize    := 20;
 vPrecision    := 0;
 vElementIndex := -1;
 vRequired     := False;
End;

Function TDWFieldDef.GetDisplayName: String;
Begin
 Result := vFieldName;
End;

Procedure TDWFieldDef.SetDisplayName(const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid FieldName')
 Else
  Begin
   vFieldName := Trim(Value);
   Inherited;
  End;
End;

Constructor TDWClientREST.Create(AOwner: TComponent);
Begin
 Inherited;
 HttpRequest                     := TIdHTTP.Create(Nil);
 vContentType                    := 'application/json';
 vContentEncoding                := 'multipart/form-data';
 vAccept                         := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
 vAcceptEncoding                 := 'gzip, deflate, br';
 vMaxAuthRetries                 := 0;
 vUserAgent                      := cUserAgent;
 HttpRequest.Request.UserAgent   := vUserAgent;
 HttpRequest.Request.ContentType := vContentType;
 HttpRequest.AllowCookies        := False;
 HttpRequest.HTTPOptions         := [hoKeepOrigProtocol]; //, hoNoProtocolErrorException{$IFNDEF FPC}{$if CompilerVersion > 30}, hoWantProtocolErrorContent{$IFEND}{$ELSE}, hoWantProtocolErrorContent{$ENDIF}];
 vTransparentProxy               := TIdProxyConnectionInfo.Create;
 vAuthOptionParams               := TRDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vAccessControlAllowOrigin       := '*';
 vAUrl                           := '';
 vRedirectMaximum                := 1;
 vDefaultCustomHeader            := TStringList.Create;
 //vOnHeadersAvailable             := OnHeadersAvailable;
 {$IFDEF FPC}
  vRSCharset                     := esUtf8;
 {$ELSE}
   {$IF CompilerVersion < 21}
    vRSCharset                   := esAnsi;
   {$ELSE}
    vRSCharset                   := esUtf8;
   {$IFEND}
 {$ENDIF}
 vVerifyCert                     := False;
 vRequestTimeOut                 := 5000;
 vConnectTimeOut                 := 5000;
 {$if Defined(FPC)}
  vSSLVersions                   := [sslvTLSv1];
 {$ifend}
 {$if Defined(DELPHI_7)    Or Defined(DELPHI_2007) Or
      Defined(DELPHI_2009) Or Defined(DELPHI_2010)}
  vSSLVersions                   := [sslvTLSv1];
 {$ifend}
 {$if defined(DELPHI_XE) or defined(DELPHI_XE2)}
  vSSLVersions                   := [sslvTLSv1];
 {$ifend}
 {$IFDEF DELPHI_XE3_UP}
  vSSLVersions                   := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
 {$ENDIF}
 vCertFile     := '';
 vKeyFile      := '';
 vRootCertFile := '';
 vHostCert     := '';
 vPortCert     := 0;
End;

Procedure TDWClientREST.SetAuthOptionParams(Value : TRDWClientAuthOptionParams);
Begin
 vAuthOptionParams.Assign(Value);
End;

Procedure TDWClientREST.SetCertOptions;
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

Procedure TDWClientREST.SetDefaultCustomHeader(Value: TStrings);
Begin
 vDefaultCustomHeader.Assign(value);
End;

procedure TDWClientREST.Getpassword(Var Password : String);
Begin
 If Assigned(vOnGetpassword) Then
  vOnGetpassword(Password);
End;

Function TDWClientREST.GetVerifyCert : boolean;
Begin
 Result := vVerifyCert;
End;

Procedure TDWClientREST.SetVerifyCert(aValue : Boolean);
Begin
 vVerifyCert := aValue;
End;

Procedure TDWClientREST.SetUseSSL(Value : Boolean);
Begin
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

Function TDWClientREST.Delete(AUrl            : String        = '';
                               CustomHeaders   : TStringList   = Nil;
                               Const AResponse : TStringStream = Nil;
                               IgnoreEvents    : Boolean       = False):Integer;
Var
 Temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TStringStream;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
  // CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforeDelete(AUrl, vTempHeaders)
    Else
     vOnBeforeDelete(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   //SetHeaders(vTempHeaders, SendParams);
   //SetRawHeaders(vTempHeaders, SendParams);
   {$IFDEF FPC}
    HttpRequest.Delete(AUrl, atempResponse);
   {$ELSE}
    {$IFDEF OLDINDY}
     HttpRequest.Delete(AUrl);
    {$ELSE}
     //HttpRequest.Delete(AUrl, atempResponse);
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, AUrl, SendParams, atempResponse, []);
    {$ENDIF}
   {$ENDIF}
   Result:= HttpRequest.ResponseCode;
   If Assigned(atempResponse) Then
    atempResponse.Position := 0;
   If vRSCharset = esUtf8 Then
     AResponse.WriteString(utf8Decode(atempResponse.DataString))
   Else
     AResponse.WriteString(atempResponse.DataString);
   FreeAndNil(atempResponse);
   If Not IgnoreEvents Then
   If Assigned(vOnAfterRequest) then
    vOnAfterRequest(AUrl, rtDelete, tempResponse);
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
End;

function TDWClientREST.Delete(AUrl: String;
                              var AResponseText: String;
                              CustomHeaders    : TStringList   = Nil;
                              const AResponse  : TStringStream = Nil;
                              IgnoreEvents     : Boolean       = False): Integer;
Var
 Temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TStringStream;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
  // CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforeDelete(AUrl, vTempHeaders)
    Else
     vOnBeforeDelete(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
   //SetHeaders(vTempHeaders, SendParams);
   //SetRawHeaders(vTempHeaders, SendParams);
   {$IFDEF FPC}
    HttpRequest.Delete(AUrl, atempResponse);
   {$ELSE}
    {$IFDEF OLDINDY}
     HttpRequest.Delete(AUrl);
    {$ELSE}
     //HttpRequest.Delete(AUrl, atempResponse);
     TIdHTTPAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, AUrl, SendParams, atempResponse, []);
    {$ENDIF}
   {$ENDIF}
   Result:= HttpRequest.ResponseCode;
   AResponseText := HttpRequest.ResponseText;
   If Assigned(atempResponse) Then
    atempResponse.Position := 0;
   If vRSCharset = esUtf8 Then
     AResponse.WriteString(utf8Decode(atempResponse.DataString))
   Else
     AResponse.WriteString(atempResponse.DataString);
   FreeAndNil(atempResponse);
   If Not IgnoreEvents Then
   If Assigned(vOnAfterRequest) then
    vOnAfterRequest(AUrl, rtDelete, tempResponse);
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
end;

Destructor TDWClientREST.Destroy;
Begin
 FreeAndNil(HttpRequest);
 FreeAndNil(vTransparentProxy);
 FreeAndNil(vDefaultCustomHeader);
 If Assigned(vAuthOptionParams) Then
  FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Procedure TDWClientREST.CopyStringList(Const Source, Dest : TStringList);
Var
 I : Integer;
Begin
 If Assigned(Source) And Assigned(Dest) Then
  For I := 0 To Source.Count -1 Do
   Dest.Add(Source[I]);
End;

Function TDWClientREST.Get(AUrl            : String         = '';
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
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
  vTempHeaders := TStringList.Create;
  Try
   //Copy Custom Headers
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforeGet(AUrl, vTempHeaders)
    Else
     vOnBeforeGet(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   Result := HttpRequest.Get(AUrl);
//   Result:= HttpRequest.ResponseCode;
   If Assigned(vOnHeadersAvailable) Then
    vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
  Finally
   vTempHeaders.Free;
  End;
 Except
   { Ico - receber erros do servidor no verbo GET }
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
End;


Function TDWClientREST.Get(AUrl            : String        = '';
                            CustomHeaders   : TStringList   = Nil;
                            Const AResponse : TStringStream = Nil;
                            IgnoreEvents    : Boolean       = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;     // o novo metodo recebe sempre 200 como code inicial;
 Try
  AUrl  := StringReplace(AUrl, #012, '', [rfReplaceAll]);
  vAUrl := AUrl;
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforeGet(AUrl, vTempHeaders)
    Else
     vOnBeforeGet(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Get(AUrl, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtGet, tempResponse);
    End
   Else
    Begin
     HttpRequest.Get(AUrl, atempResponse); // AResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtGet, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
   { Ico - receber erros do servidor no verbo GET }
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;         // tratamos o status dentro do except da requisicao
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
End;

Function TDWClientREST.Get(AUrl            : String;
                            CustomHeaders   : TStringList;
                            Const AResponse : TStream;
                            IgnoreEvents    : Boolean):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TMemoryStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;
 Try
  AUrl := StringReplace(AUrl, #012, '', [rfReplaceAll]);
  vAUrl := AUrl;
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
  vTempHeaders := TStringList.Create;
  atempResponse  := TMemoryStream.Create;
  If Not Assigned(AResponse) Then
   tempResponse  := TMemoryStream.Create;
  Try
   //Copy Custom Headers
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforeGet(AUrl, vTempHeaders)
    Else
     vOnBeforeGet(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Get(AUrl, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     tempResponse.CopyFrom(atempResponse, atempResponse.Size);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtGet, tempResponse);
    End
   Else
    Begin
     HttpRequest.Get(AUrl, atempResponse); // AResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     AResponse.CopyFrom(atempResponse, atempResponse.Size);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtGet, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  { Ico - receber erros do servidor no verbo GET }
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
End;

function TDWClientREST.GetAllowCookies: Boolean;
begin
 Result := HttpRequest.AllowCookies;
end;

function TDWClientREST.GetHandleRedirects: Boolean;
begin
 Result := HttpRequest.HandleRedirects;
end;

{$IFNDEF FPC}
{$IFNDEF DELPHI_10TOKYO_UP}
Function TDWClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                              AOk         : Boolean) : Boolean;
Begin
 Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, -1);
End;

Function TDWClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                              AOk         : Boolean;
                                                              ADepth      : Integer) : Boolean;
Begin
 Result := IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate, AOk, ADepth, -1);
End;
{$ENDIF}
{$ENDIF}
Function TDWClientREST.IdSSLIOHandlerSocketOpenSSL1VerifyPeer(Certificate : TIdX509;
                                                              AOk         : Boolean;
                                                              ADepth,
                                                              AError      : Integer) : Boolean;
Begin
 Result := AOk;
 If Not vVerifyCert then
  Result := True;
End;

Function TDWClientREST.Patch(AUrl            : String        = '';
                              CustomHeaders   : TStringList   = Nil;
                              Const AResponse : TStringStream = Nil;
                              IgnoreEvents    : Boolean       = False) : Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;//TIdMultipartFormDataStream.Create;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePatch) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePatch(AUrl, vTempHeaders)
    Else
     vOnBeforePatch(AUrl, CustomHeaders);
   //Copy New Headers
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
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPatch, tempResponse);
    End
   Else
    Begin
     temp := TStringStream.Create(StringReplace(vTempHeaders.Text, sLineBreak, '', [rfReplaceAll]));
     temp.Position := 0;
//     HttpRequest.Request.RawHeaders.AddValue('data', vTempHeaders.Text);
 //    temp := TStringStream.Create(vTempHeaders.Text);
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
       If vRSCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(atempResponse.DataString))
       Else
        AResponse.WriteString(atempResponse.DataString);
       AResponse.Position := 0;
       If Not IgnoreEvents Then
       If Assigned(vOnAfterRequest) then
        vOnAfterRequest(AUrl, rtPatch, AResponse);
      End
     Else
      Begin
       If vRSCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(HttpRequest.ResponseText))
       Else
        AResponse.WriteString(HttpRequest.ResponseText);
       AResponse.Position := 0;
       If Not IgnoreEvents Then
       If Assigned(vOnAfterRequest) then
        vOnAfterRequest(AUrl, rtPatch, AResponse);
      End;
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
End;

Function TDWClientREST.Post(AUrl            : String;
                             CustomHeaders   : TStringList;
                             Const AResponse : TStream;
                             IgnoreEvents,
                             RawHeaders      : Boolean):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TMemoryStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
  vTempHeaders := TStringList.Create;
  atempResponse  := TMemoryStream.Create;
  If Not Assigned(AResponse) Then
   tempResponse  := TMemoryStream.Create;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePost(AUrl, vTempHeaders)
    Else
     vOnBeforePost(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   If Not RawHeaders Then
    SetHeaders(vTempHeaders, SendParams)
   Else
    Begin
     FreeAndNil(SendParams);
     SetRawHeaders(vTempHeaders, SendParams);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     tempResponse.CopyFrom(atempResponse, atempResponse.Size);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Post(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     AResponse.CopyFrom(atempResponse, atempResponse.Size);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, AResponse);
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
End;

Function TDWClientREST.Post(AUrl            : String         = '';
                            CustomHeaders   : TStringList    = Nil;
                            FileName        : String         = '';
                            FileStream      : TMemoryStream  = Nil;
                            Const AResponse : TStringStream  = Nil;
                            IgnoreEvents    : Boolean        = False;
                            RawHeaders      : Boolean        = False):Integer;
Var
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
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
   If Assigned(vOnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePost(AUrl, vTempHeaders)
    Else
     vOnBeforePost(AUrl, CustomHeaders);
   If FileStream <> Nil Then
    Begin
     FileStream.Position := 0;
     SendParams.AddFormField('upload_file', 'application/octet-stream', '', FileStream, FileName);
    End;
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomHeaders) Then
      temp         := TStringStream.Create(CustomHeaders.Text);
     HttpRequest.Post(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
//     HttpRequest.Post(AUrl, SendParams, atempResponse);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, AResponse);
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
End;

Function TDWClientREST.Post(AUrl            : String        = '';
                            CustomHeaders   : TStringList   = Nil;
                            CustomBody      : TStringList   = Nil;
                            Const AResponse : TStringStream = Nil;
                            IgnoreEvents    : Boolean       = False;
                            RawHeaders      : Boolean       = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 sResponse    : String;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
   If Assigned(vOnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePost(AUrl, vTempHeaders)
    Else
     vOnBeforePost(AUrl, CustomHeaders);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, CustomBody, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If atempResponse.Size = 0 Then
      Begin
       If vRSCharset = esUtf8 Then
        tempResponse.WriteString(utf8Decode(HttpRequest.Response.RawHeaders.Text))
       Else
        tempResponse.WriteString(HttpRequest.Response.RawHeaders.Text);
      End
     Else
      Begin
       If vRSCharset = esUtf8 Then
        tempResponse.WriteString(utf8Decode(atempResponse.DataString))
       Else
        tempResponse.WriteString(atempResponse.DataString);
      End;
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
     temp := Nil;
     If Assigned(CustomBody) Then
      temp         := TStringStream.Create(CustomBody.Text);
     sResponse := HttpRequest.Post(AUrl, temp);
//     HttpRequest.Post(AUrl, temp, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     If Length(sResponse) = 0 Then
      Begin
       If Length(HttpRequest.ResponseText) > 0 Then
        AResponse.WriteString(utf8Decode(HttpRequest.ResponseText))
       Else If vRSCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(HttpRequest.Response.RawHeaders.Text))
       Else
        AResponse.WriteString(HttpRequest.Response.RawHeaders.Text);
      End
     Else
      Begin
       If vRSCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(sResponse))
       Else
        AResponse.WriteString(sResponse);
      End;
//     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, AResponse);
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
End;

Function TDWClientREST.Post(AUrl            : String        = '';
                             CustomHeaders   : TStringList   = Nil;
                             Const AResponse : TStringStream = Nil;
                             IgnoreEvents    : Boolean       = False;
                             RawHeaders      : Boolean       = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 sResponse    : string;
Begin
 Result:= 200;
 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePost(AUrl, vTempHeaders)
    Else
     vOnBeforePost(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetRawHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
      temp := Nil;
      //If Assigned(CustomHeaders) Then
      //temp         := TStringStream.Create(CustomHeaders.Text);
      //HttpRequest.Post(AUrl, temp, atempResponse);
     // ** alteração Ico Menezes - 15/07/2020 - Gerar os paramentros para x-www-urlencode
     sResponse := HttpRequest.Post(AUrl, CustomHeaders);
     // ** alteração Ico Menezes - 15/07/2020 - Resquest anterior
     Result:= HttpRequest.ResponseCode;
     If (HttpRequest.ResponseCode > 299) Then
      If Trim(sResponse) = '' Then
       sResponse := HttpRequest.ResponseText;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
//     HttpRequest.Post(AUrl, SendParams, atempResponse);
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(sResponse))
     Else
      AResponse.WriteString(sResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, AResponse);
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
End;

Function   TDWClientREST.Patch     (AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomBody      : TStringList    = Nil;
                                    Const AResponse : TStringStream  = Nil;
                                    IgnoreEvents    : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;
 Try
  tempResponse := Nil;
  SendParams   := Nil;//TIdMultipartFormDataStream.Create;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePatch) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePatch(AUrl, vTempHeaders)
    Else
     vOnBeforePatch(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   HttpRequest.Request.Date := Now;
   If Not Assigned(AResponse) Then
    Begin
     temp := TStringStream.Create(vTempHeaders.Text);
     If Assigned(CustomBody) Then
      temp         := TStringStream.Create(CustomBody.Text);
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
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPatch, tempResponse);
    End
   Else
    Begin
     temp := TStringStream.Create(StringReplace(vTempHeaders.Text, sLineBreak, '', [rfReplaceAll]));
     temp.Position := 0;
//     HttpRequest.Request.RawHeaders.AddValue('data', vTempHeaders.Text);
 //    temp := TStringStream.Create(vTempHeaders.Text);
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
       If vRSCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(atempResponse.DataString))
       Else
        AResponse.WriteString(atempResponse.DataString);
       AResponse.Position := 0;
       If Not IgnoreEvents Then
       If Assigned(vOnAfterRequest) then
        vOnAfterRequest(AUrl, rtPatch, AResponse);
      End
     Else
      Begin
       If vRSCharset = esUtf8 Then
        AResponse.WriteString(utf8Decode(HttpRequest.ResponseText))
       Else
        AResponse.WriteString(HttpRequest.ResponseText);
       AResponse.Position := 0;
       If Not IgnoreEvents Then
       If Assigned(vOnAfterRequest) then
        vOnAfterRequest(AUrl, rtPatch, AResponse);
      End;
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
End;

Function TDWClientREST.Put(AUrl            : String        = '';
                           CustomHeaders   : TStringList   = Nil;
                           CustomBody      : TStringList   = Nil;
                           Const AResponse : TStringStream = Nil;
                           IgnoreEvents    : Boolean       = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;
 Try
  temp         := Nil;
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
   If Assigned(vOnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePut(AUrl, vTempHeaders)
    Else
     vOnBeforePut(AUrl, CustomHeaders);
   If Assigned(CustomBody) Then
    temp         := TStringStream.Create(CustomBody.Text);
   HttpRequest.Put(AUrl, temp, atempResponse);
   Result:= HttpRequest.ResponseCode;
   If Assigned(temp) Then
    FreeAndNil(temp);
   atempResponse.Position := 0;
   If atempResponse.Size = 0 Then
    Begin
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(HttpRequest.Response.RawHeaders.Text))
     Else
      AResponse.WriteString(HttpRequest.Response.RawHeaders.Text);
    End
   Else
    Begin
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
    End;
   FreeAndNil(atempResponse);
   AResponse.Position := 0;
   If Not IgnoreEvents Then
   If Assigned(vOnAfterRequest) then
    vOnAfterRequest(AUrl, rtPut, AResponse);
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
End;

Function TDWClientREST.Put(AUrl            : String        = '';
                            CustomHeaders   : TStringList   = Nil;
                            Const AResponse : TStringStream = Nil;
                            IgnoreEvents    : Boolean       = False):Integer;
Var
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
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePut(AUrl, vTempHeaders)
    Else
     vOnBeforePut(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
 //  SetHeaders(vTempHeaders, SendParams);
//   SetRawHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPut, AResponse);
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
End;

procedure TDWClientREST.SetAllowCookies(Value: Boolean);
begin
 HttpRequest.AllowCookies    := Value;
end;

procedure TDWClientREST.SetHandleRedirects(Value: Boolean);
begin
 HttpRequest.HandleRedirects := Value;
end;

procedure TDWClientREST.SetHeaders(AHeaders: TStringList);
Var
 I           : Integer;
 vUriOptions : TRESTDWUriOptions;
 vmark       : String;
 DWParams    : TDWParams;
Begin
 vUriOptions := TRESTDWUriOptions.Create;
 vmark       := '';
 DWParams    := Nil;
 HttpRequest.Request.AcceptEncoding := vAcceptEncoding;
 HttpRequest.Request.CustomHeaders.Clear;
 If Assigned(AHeaders) Then
  If AHeaders.Count > 0 Then
   HttpRequest.Request.CustomHeaders.FoldLines := False;
 If (vAuthOptionParams.AuthorizationOption in [rdwAOBearer, rdwAOToken]) Then
  HttpRequest.Request.CustomHeaders.FoldLines := False;
 If vAccessControlAllowOrigin <> '' Then
  Begin
   {$IFNDEF FPC}
    {$if CompilerVersion > 21}
     HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', vAccessControlAllowOrigin);
    {$ELSE}                                    // Ico Menezes 30/07/2018 - para compatibilidade com delphis velhos !
     HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', vAccessControlAllowOrigin);
    {$IFEND}
   {$ELSE}
    HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin',  vAccessControlAllowOrigin);
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
 If vAuthOptionParams.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken, rdwOAuth] Then
  Begin
   HttpRequest.Request.BasicAuthentication := vAuthOptionParams.AuthorizationOption = rdwAOBasic;
   Case vAuthOptionParams.AuthorizationOption of
    rdwAOBasic  : Begin
                   If HttpRequest.Request.Authentication = Nil Then
                    HttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
                   HttpRequest.Request.Authentication.Password := TRDWAuthOptionBasic(vAuthOptionParams.OptionParams).Password;
                   HttpRequest.Request.Authentication.Username := TRDWAuthOptionBasic(vAuthOptionParams.OptionParams).UserName;
                  End;
    rdwAOBearer : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   HttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRDWAuthOptionBearerClient(vAuthOptionParams.OptionParams).Token);
                  End;
    rdwAOToken  : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   HttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRDWAuthOptionTokenClient(vAuthOptionParams.OptionParams).Token]));
                  End;
    rdwOAuth    : Begin
                   If Assigned(HttpRequest.Request.Authentication) Then
                    Begin
                     HttpRequest.Request.Authentication.Free;
                     HttpRequest.Request.Authentication := Nil;
                    End;
                   vAUrl := Stringreplace(lowercase(vAUrl), 'http://', '', [rfReplaceAll]);
                   vAUrl := Stringreplace(lowercase(vAUrl), 'https://', '', [rfReplaceAll]);
                   TServerUtils.ParseRESTURL(vAUrl, vRSCharset, vUriOptions, vmark{$IFDEF FPC}, csUndefined{$ENDIF}, DWParams, 2);
                   If Assigned(DWParams) Then
                    FreeAndNil(DWParams);
                   If (Lowercase(TRDWAuthOAuth(vAuthOptionParams.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.EventName))   Or
                      (Lowercase(TRDWAuthOAuth(vAuthOptionParams.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent))  Or
                      (Lowercase(TRDWAuthOAuth(vAuthOptionParams.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.EventName))  Or
                      (Lowercase(TRDWAuthOAuth(vAuthOptionParams.OptionParams).GrantCodeEvent) = Lowercase(vUriOptions.ServerEvent)) Then
                    Begin
                     If (Lowercase(TRDWAuthOAuth(vAuthOptionParams.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.EventName))  Or
                        (Lowercase(TRDWAuthOAuth(vAuthOptionParams.OptionParams).GetTokenEvent)  = Lowercase(vUriOptions.ServerEvent)) Then
                      Begin
                       If TRDWAuthOAuth(vAuthOptionParams.OptionParams).AutoBuildHex Then
                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientID + ':' +
                                                                                                               TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientSecret
                                                                                                               {$IFDEF FPC}, csUndefined{$ENDIF})]))
                       Else
                        HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientID + ':' +
                                                                                                               TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientSecret
                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]));
                      End;
                    End
                   Else
                    Begin
                     Case TRDWAuthOAuth(vAuthOptionParams.OptionParams).TokenType Of
                      rdwOATBasic  : Begin
                                      If TRDWAuthOAuth(vAuthOptionParams.OptionParams).AutoBuildHex Then
                                       HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientID + ':' +
                                                                                                                              TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientSecret
                                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]))
                                      Else
                                       HttpRequest.Request.CustomHeaders.Add(Format('Authorization: Basic %s', [EncodeStrings(TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientID + ':' +
                                                                                                                              TRDWAuthOAuth(vAuthOptionParams.OptionParams).ClientSecret
                                                                                                                              {$IFDEF FPC}, csUndefined{$ENDIF})]));
                                     End;
                      rdwOATBearer : HttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRDWAuthOAuth(vAuthOptionParams.OptionParams).Token);
                      rdwOATToken  : HttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRDWAuthOAuth(vAuthOptionParams.OptionParams).Token]));
                     End;
                    End;
                  End;
   End;
  End;
//  HttpRequest.Request.CustomHeaders.Values['Authorization'] := vServerParams.Authentication;
 If Assigned(vUriOptions) Then
  FreeAndnil(vUriOptions);
End;

Procedure TDWClientREST.SetHeaders(AHeaders       : TStringList;
                                   Var SendParams : TIdMultipartFormDataStream);
Var
 I : Integer;
Begin
// HttpRequest.Request.CustomHeaders.Clear;
 HttpRequest.Request.AcceptEncoding := vAcceptEncoding;
 If vAccessControlAllowOrigin <> '' Then
  Begin
   If SendParams <> Nil Then
    Begin
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
       HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', vAccessControlAllowOrigin);
      {$ELSE}                                    // Ico Menezes 30/07/2018 - para compatibilidade com delphis velhos !
       HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin', vAccessControlAllowOrigin);
      {$IFEND}
     {$ELSE}
      HttpRequest.Request.CustomHeaders.AddValue('Access-Control-Allow-Origin',  vAccessControlAllowOrigin);
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
           If vRSCharset = esUtf8 Then
            HttpRequest.Request.CustomHeaders.AddValue(AHeaders.Names[i], utf8Decode(AHeaders.ValueFromIndex[i]))
           Else
            HttpRequest.Request.CustomHeaders.AddValue(AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
          End;
        End
       Else
        Begin
         If (AHeaders.Names[i] <> '') Or (AHeaders.ValueFromIndex[i] <> '') Then
          Begin
           If vRSCharset = esUtf8 Then
            SendParams.AddFormField(AHeaders.Names[i],  utf8Decode(AHeaders.ValueFromIndex[i]))
           Else
            SendParams.AddFormField(AHeaders.Names[i],  AHeaders.ValueFromIndex[i]);
          End;
        End;
      End;
    End;
  End;
End;

procedure TDWClientREST.SetOnStatus(Value: TOnStatus);
begin
 {$IFDEF FPC}
  vOnStatus            := Value;
  HttpRequest.OnStatus := vOnStatus;
 {$ELSE}
  vOnStatus            := Value;
  HttpRequest.OnStatus := vOnStatus;
 {$ENDIF}
end;

procedure TDWClientREST.SetOnWork(Value: TOnWork);
begin
 {$IFDEF FPC}
  vOnWork            := Value;
  HttpRequest.OnWork := vOnWork;
 {$ELSE}
  vOnWork            := Value;
  HttpRequest.OnWork := vOnWork;
 {$ENDIF}
end;

procedure TDWClientREST.SetOnWorkBegin(Value: TOnWorkBegin);
begin
 {$IFDEF FPC}
  vOnWorkBegin            := Value;
  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ELSE}
  vOnWorkBegin            := Value;
  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ENDIF}
end;

procedure TDWClientREST.SetOnWorkEnd(Value: TOnWorkEnd);
begin
 {$IFDEF FPC}
  vOnWorkEnd            := Value;
  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ELSE}
  vOnWorkEnd            := Value;
  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ENDIF}
end;

Procedure TDWClientREST.SetParams(Const aHttpRequest: TIdHTTP);
begin
 If aHttpRequest.Request.BasicAuthentication Then
  Begin
   If aHttpRequest.Request.Authentication = Nil Then
    aHttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
  End;
 aHttpRequest.ProxyParams.BasicAuthentication   := vTransparentProxy.BasicAuthentication;
 aHttpRequest.ProxyParams.ProxyUsername         := vTransparentProxy.ProxyUsername;
 aHttpRequest.ProxyParams.ProxyServer           := vTransparentProxy.ProxyServer;
 aHttpRequest.ProxyParams.ProxyPassword         := vTransparentProxy.ProxyPassword;
 aHttpRequest.ProxyParams.ProxyPort             := vTransparentProxy.ProxyPort;
 aHttpRequest.ReadTimeout                       := vRequestTimeout;
 aHttpRequest.Request.ContentType               := HttpRequest.Request.ContentType;
 aHttpRequest.AllowCookies                      := HttpRequest.AllowCookies;
 aHttpRequest.HandleRedirects                   := HttpRequest.HandleRedirects;
 aHttpRequest.RedirectMaximum                   := vRedirectMaximum;
 aHttpRequest.HTTPOptions                       := HttpRequest.HTTPOptions;
 If vRSCharset = esUtf8 Then
  Begin
   aHttpRequest.Request.Charset                  := 'utf-8';
   aHttpRequest.Request.AcceptCharSet            := aHttpRequest.Request.Charset;
  End
 Else If vRSCharset = esASCII Then
  Begin
   aHttpRequest.Request.Charset                  := 'ascii';
   aHttpRequest.Request.AcceptCharSet            := aHttpRequest.Request.Charset;
  End
 Else If vRSCharset = esANSI Then
  Begin
   aHttpRequest.Request.Charset                  := 'ansi';
   aHttpRequest.Request.AcceptCharSet            := aHttpRequest.Request.Charset;
  End;
 aHttpRequest.Request.ContentType               := vContentType;
 aHttpRequest.Request.Accept                    := vAccept;
 aHttpRequest.Request.ContentEncoding           := vContentEncoding;
 aHttpRequest.Request.UserAgent                 := vUserAgent;
 aHttpRequest.MaxAuthRetries                    := vMaxAuthRetries;
end;

procedure TDWClientREST.SetRawHeaders(AHeaders: TStringList;
  var SendParams: TIdMultipartFormDataStream);
Var
 I : Integer;
Begin
 HttpRequest.Request.AcceptEncoding := vAcceptEncoding;
 HttpRequest.Request.RawHeaders.Clear;
// HttpRequest.Request.CustomHeaders.Clear;
 If vAccessControlAllowOrigin <> '' Then
  Begin
   If SendParams <> Nil Then
    Begin
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
       SendParams.AddFormField('Access-Control-Allow-Origin', vAccessControlAllowOrigin);
      {$ELSE}                                    // Ico Menezes 30/07/2018 - para compatibilidade com delphis velhos !
       SendParams.AddFormField('Access-Control-Allow-Origin', vAccessControlAllowOrigin);
      {$IFEND}
     {$ELSE}
      SendParams.AddFormField('Access-Control-Allow-Origin',  vAccessControlAllowOrigin);
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
         If vRSCharset = esUtf8 Then
          HttpRequest.Request.RawHeaders.Add(utf8Decode(AHeaders[i]))
         Else
          HttpRequest.Request.RawHeaders.Add(AHeaders[i]);
        End
       Else
        Begin
         If vRSCharset = esUtf8 Then
          SendParams.AddFormField(AHeaders.Names[i],  utf8Decode(AHeaders.ValueFromIndex[i]))
         Else
          SendParams.AddFormField(AHeaders.Names[i],  AHeaders.ValueFromIndex[i]);
        End;
      End;
    End;
  End;
End;

function TDWClientREST.Post(AUrl : String; var AResponseText: String;
     CustomHeaders: TStringList; const AResponse: TStringStream;
                              IgnoreEvents,  RawHeaders: Boolean): Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
 sResponse    : string;
Begin
 Result:= 200;
 AResponseText := '';

 SendParams   := TIdMultipartFormDataStream.Create;
 Try
  tempResponse := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePost(AUrl, vTempHeaders)
    Else
     vOnBeforePost(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetRawHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Post(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, tempResponse);
    End
   Else
    Begin
      temp := Nil;
      //If Assigned(CustomHeaders) Then
      //temp         := TStringStream.Create(CustomHeaders.Text);
      //HttpRequest.Post(AUrl, temp, atempResponse);

     // ** alteração Ico Menezes - 15/07/2020 - Gerar os paramentros para x-www-urlencode
     sResponse:= HttpRequest.Post(AUrl, CustomHeaders);
     // ** alteração Ico Menezes - 15/07/2020 - Resquest anterior
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
//     HttpRequest.Post(AUrl, SendParams, atempResponse);
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(sResponse))
     Else
      AResponse.WriteString(sResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPost, AResponse);
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
end;

function TDWClientREST.Get(AUrl: String; var AResponseText: String;
  CustomHeaders: TStringList; const AResponse: TStringStream;
  IgnoreEvents: Boolean): Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse : TStringStream;
 SendParams   : TIdMultipartFormDataStream;
Begin
 Result:= 200;     // o novo metodo recebe sempre 200 como code inicial;
 AResponseText := '';

 Try
  AUrl  := StringReplace(AUrl, #012, '', [rfReplaceAll]);
  vAUrl := AUrl;
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforeGet(AUrl, vTempHeaders)
    Else
     vOnBeforeGet(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SetHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Get(AUrl, atempResponse);
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtGet, tempResponse);
    End
   Else
    Begin
     HttpRequest.Get(AUrl, atempResponse); // AResponse);
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     if Assigned(vOnHeadersAvailable) then
      vOnHeadersAvailable(HttpRequest.Response.RawHeaders, True);
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtGet, AResponse);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(tempResponse) Then
    tempResponse.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
   { Ico - receber erros do servidor no verbo GET }
  On E: EIdHTTPProtocolException Do
   Begin
    If (Length(E.ErrorMessage) > 0) or (E.ErrorCode <> 0) Then
     Begin
      Result:= E.ErrorCode;         // tratamos o status dentro do except da requisicao
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
end;

function TDWClientREST.Put(AUrl: String; var AResponseText: String;
  CustomHeaders, CustomBody: TStringList; const AResponse: TStringStream;
  IgnoreEvents: Boolean): Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse,
 SendParams   : TStringStream;
Begin
 Result:= 200;
 AResponseText := '';

 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePut(AUrl, vTempHeaders)
    Else
     vOnBeforePut(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
 //  SetHeaders(vTempHeaders, SendParams);
//   SetRawHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPut, AResponse);
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
end;

function TDWClientREST.Patch(AUrl: String; var AResponseText: String;
  CustomHeaders: TStringList; const AResponse: TStringStream;
  IgnoreEvents: Boolean): Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse,
 tempResponse,
 SendParams   : TStringStream;
Begin
 Result:= 200;
 AResponseText := '';

 Try
  tempResponse := Nil;
  SendParams   := Nil;
  SetParams(HttpRequest);
  SetUseSSL(vUseSSL);
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
//   CopyStringList(TStringList(vDefaultCustomHeader), vTempHeaders);
   SetHeaders(TStringList(vDefaultCustomHeader));
   If Not IgnoreEvents Then
   If Assigned(vOnBeforePut) then
    If Not Assigned(CustomHeaders) Then
     vOnBeforePut(AUrl, vTempHeaders)
    Else
     vOnBeforePut(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   SendParams := TStringStream.Create(vTempHeaders.Text);
 //  SetHeaders(vTempHeaders, SendParams);
//   SetRawHeaders(vTempHeaders, SendParams);
   If Not Assigned(AResponse) Then
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      tempResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      tempResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     tempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPut, tempResponse);
    End
   Else
    Begin
     HttpRequest.Put(AUrl, SendParams, atempResponse);
     Result:= HttpRequest.ResponseCode;
     AResponseText := HttpRequest.ResponseText;
     atempResponse.Position := 0;
     If vRSCharset = esUtf8 Then
      AResponse.WriteString(utf8Decode(atempResponse.DataString))
     Else
      AResponse.WriteString(atempResponse.DataString);
     FreeAndNil(atempResponse);
     AResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(vOnAfterRequest) then
      vOnAfterRequest(AUrl, rtPut, AResponse);
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

end;

end.
