unit uRESTDWjClientLAMWBase;

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

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

Uses
  {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
  {$IFNDEF RESTDWLAZARUS}SyncObjs,{$ENDIF}
  {$IF not Defined(RESTDWLAZARUS) AND not Defined(RESTDWLAMW) AND not Defined(DELPHIXEUP)}uRESTDWMassiveBuffer,{$IFEND}
  SysUtils, Classes, Db, Variants,
  uRESTDWBasic, uRESTDWBasicDB, uRESTDWComponentEvents, uRESTDWBasicTypes,
  uRESTDWJSONObject, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
  uRESTDWConsts, uRESTDWProtoTypes, uRESTDWDataUtils, uRESTDWTools, uRESTDWZlib,
  uRESTDWAuthenticators, And_jni, Laz_And_Controls;

Type
 TRESTDWjClientLAMWClientHttpBase = Class(TRESTDWClientHttpBase)
 Private
  HttpRequest      : jHttpClient;
  vVerifyCert      : Boolean;
  vAUrl            : String;
  vOnGetpassword   : TOnGetpassword;
  Procedure SetParams;
  Procedure SetHeaders        (AHeaders           : TStringList);Overload;Override;
  Procedure SetOnWorkEnd      (Value              : TOnWorkEnd);Override;
  Procedure SetOnStatus       (Value              : TOnStatus); Override;
  Procedure DestroyClient;Override;
  Procedure SetInternalEvents;
 Public
  Constructor Create(AOwner : TComponent);Override;
  Destructor  Destroy;Override;
  Function   Get       (AUrl                 : String          = '';
                        Const CustomHeaders  : TStringList     = Nil;
                        Const AResponse      : TStream         = Nil;
                        Const AResponseError : TStream         = Nil) : Integer;Override;
  Function   Post      (AUrl                 : String          = '';
                        Const CustomHeaders  : TStringList     = Nil;
                        Const CustomParams   : TStringList     = Nil;
                        Const CustomBody     : TStream         = Nil;
                        Const AResponse      : TStream         = Nil;
                        Const AResponseError : TStream         = Nil) : Integer;Override;
  Function   Delete    (AUrl                 : String;
                        Const CustomHeaders  : TStringList     = Nil;
                        Const CustomParams   : TStringList     = Nil;
                        Const AResponse      : TStream         = Nil;
                        Const AResponseError : TStream         = Nil) : Integer;Override;
End;


 TRESTDWjClientLAMWClientREST = Class(TRESTDWClientRESTBase)
 Private
  HttpRequest      : jHttpClient;
  vVerifyCert      : Boolean;
  vAUrl            : String;
  Procedure SetRawHeaders     (AHeaders           : TStringList;
                               Var clientConn     : jObject);
  Procedure SetParams;Overload;
  Procedure SetParams(stream : TStream);
  Procedure SetHeaders        (AHeaders           : TStringList;
                               Var clientConn     : jObject);
  Procedure SetOnStatus       (Value              : TOnStatus); Override;
  Procedure DestroyClient;Override;
 Public
  Constructor Create(AOwner : TComponent);Override;
  Destructor  Destroy;Override;
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
  Function   Post      (AUrl            : String         = '';
                        CustomHeaders   : TStringList    = Nil;
                        CustomBody      : TStringList    = Nil;
                        Const AResponse : TStringStream  = Nil;
                        IgnoreEvents    : Boolean        = False;
                        RawHeaders      : Boolean        = False):Integer;Overload;

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
  Function   Delete    (AUrl              : String         = '';
                        CustomHeaders     : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
  Function   Delete    (AUrl              : String;
                        CustomHeaders     : TStringList    = Nil;
                        CustomParams      : TStringList    = Nil;
                        Const AResponse   : TStream        = Nil;
                        IgnoreEvents      : Boolean        = False):Integer;Overload;Override;
End;

 TRESTDWjClientLAMWDatabase = Class(TRESTDWDatabasebaseBase)
 Private
 Public
  Constructor Create               (AOwner       : TComponent);Override;
  Destructor  Destroy;Override;
  Function    IsServerLive         (Aip          : String;
                                    Aport        : Integer;
                                    AMessageErro : String): Boolean; Override;
End;

 TRESTDWjClientLAMWClientPooler = Class(TRESTClientPoolerBase)
 Private
  HttpRequest                      : TRESTDWjClientLAMWClientREST;
  Function    SendEvent            (EventData              : String;
                                    Var Params             : TRESTDWParams;
                                    EventType              : TSendEvent = sePOST;
                                    DataMode               : TDataMode  = dmDataware;
                                    ServerEventName        : String     = '';
                                    Assyncexec             : Boolean    = False) : String;Override;
  Procedure   SetParams            (TransparentProxy       : TProxyConnectionInfo;
                                    aRequestTimeout,
                                    aConnectTimeout        : Integer;
                                    AuthorizationParams    : TRESTDWClientAuthOptionParams);
 Public
  Constructor Create               (AOwner                 : TComponent);Override;
  Destructor  Destroy;Override;
  Procedure   ReconfigureConnection(aTypeRequest           : Ttyperequest;
                                    aWelcomeMessage,
                                    aHost                  : String;
                                    aPort                  : Integer;
                                    Compression,
                                    EncodeStrings          : Boolean;
                                    aEncoding              : TEncodeSelect;
                                    aAccessTag             : String;
                                    aAuthenticationOptions : TRESTDWClientAuthOptionParams);Override;
  Function    IsServerLive         (Aip          : String;
                                    Aport        : Integer;
                                    AMessageErro : String): Boolean;
  Procedure Abort;Override;
End;

  TRESTDWjClientLAMWPoolerList = Class(TRESTDWPoolerListBase)
  Public
    Constructor Create(AOwner  : TComponent);Override; //Cria o Componente
    Destructor  Destroy;Override;
  End;

//Fix to Indy Request Patch and Put
Type
 jHttpClientAccess = class(jHttpClient)
End;

Implementation

Uses uRESTDWJSONInterface;

Destructor TRESTDWjClientLAMWClientREST.Destroy;
Begin
 If Assigned(HttpRequest) then
  Begin
   Try
    HttpRequest.Disconnect(HttpRequest);
    HttpRequest.Free;
   Except
   End;
  End;
 Inherited;
End;

Procedure TRESTDWjClientLAMWClientREST.DestroyClient;
Begin
 {$IFNDEF RESTDWLAZARUS}
  {$IFNDEF FPC}
   Inherited;
  {$ENDIF}
 {$ELSE}
  {$IFNDEF FPC}
   Inherited;
  {$ENDIF}
 {$ENDIF}
 If Assigned(HttpRequest) Then
  Begin
   HttpRequest.Disconnect(HttpRequest);
   //FreeAndNil(HttpRequest);
  End;
End;

Procedure TRESTDWjClientLAMWClientREST.SetParams(stream : TStream);
Begin

End;

Procedure TRESTDWjClientLAMWClientREST.SetParams;
begin
 Try
  If Not Assigned(HttpRequest) Then
   HttpRequest := jHttpClient.Create(Nil);
 Finally
  If RequestCharset = esUtf8 Then
   HttpRequest.CharSet                  := 'utf-8';
  HttpRequest.ClearNameValueData;
  HttpRequest.SetRequestProperty(HttpRequest, 'Accept',          Accept);
  HttpRequest.SetRequestProperty(HttpRequest, 'AcceptEncoding',  AcceptEncoding);
  HttpRequest.SetRequestProperty(HttpRequest, 'ContentType',     ContentType);
  HttpRequest.SetRequestProperty(HttpRequest, 'ContentEncoding', ContentEncoding);
  HttpRequest.SetRequestProperty(HttpRequest, 'UserAgent',       UserAgent);
 End;
End;

Function TRESTDWjClientLAMWClientREST.Get(AUrl            : String         = '';
                                          CustomHeaders   : TStringList    = Nil;
                                          Const AResponse : TStream        = Nil;
                                          IgnoreEvents    : Boolean        = False) : Integer;
Var
 aString      : String;
 vTempHeaders : TStringList;
 atempResponse: TStream;
 clientConn   : jObject;
Begin
 Result:= 200;     // o novo metodo recebe sempre 200 como code inicial;
 Try
  AUrl  := StringReplace(AUrl, #012, '', [rfReplaceAll]);
  vAUrl := AUrl;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  Try
   SetHeaders(TStringList(DefaultCustomHeader), clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeGet(AUrl, vTempHeaders)
    Else
     OnBeforeGet(AUrl, CustomHeaders);
   //Copy New Headers
   CopyStringList(CustomHeaders, vTempHeaders);
   If RequestCharset = esUtf8 Then
    atempResponse := TStringStream.Create(utf8Decode(HttpRequest.Get(AUrl)))
   Else
    atempResponse := TStringStream.Create(HttpRequest.Get(AUrl));
   Result:= HttpRequest.GetResponseCode;
   atempResponse.Position := 0;
   If Not IgnoreEvents Then
    If Assigned(OnAfterRequest) then
     OnAfterRequest(AUrl, rtGet, atempResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(HttpRequest);
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWjClientLAMWClientREST.Get(AUrl            : String         = '';
                                            CustomHeaders   : TStringList    = Nil;
                                            IgnoreEvents    : Boolean        = False) : String;
Var
 temp          : TStringStream;
 vTempHeaders  : TStringList;
 clientConn    : jObject;
Begin
 Try
  AUrl  := StringReplace(AUrl, #012, '', [rfReplaceAll]);
  vAUrl := AUrl;
  Result       := '';
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  Try
   SetHeaders(TStringList(DefaultCustomHeader), clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforeGet) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeGet(AUrl, vTempHeaders)
    Else
     OnBeforeGet(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   Result := HttpRequest.Get(AUrl);
  Finally
   vTempHeaders.Free;
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(HttpRequest);
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWjClientLAMWClientREST.Post(AUrl             : String         = '';
                                             CustomHeaders    : TStringList    = Nil;
                                             Const CustomBody : TStream        = Nil;
                                             IgnoreEvents     : Boolean        = False;
                                             RawHeaders       : Boolean        = False) : Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse: TStringStream;
 aString,
 sResponse    : string;
 clientConn   : jObject;
Begin
 Result:= 200;
 Try
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  atempResponse := TStringStream.Create('');
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader), clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   SetRawHeaders(vTempHeaders, clientConn);
   clientConn := HttpRequest.OpenConnection(AUrl);
   If Not Assigned(CustomBody) Then
    Begin
     atempResponse := TStringStream.Create(HttpRequest.Post(clientConn));
     Result:= HttpRequest.GetResponseCode;
     atempResponse.Position := 0;
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, atempResponse);
     FreeAndNil(atempResponse);
    End
   Else
    Begin
     atempResponse := TStringStream.Create(HttpRequest.Post(clientConn));
     Result:= HttpRequest.GetResponseCode;
     atempResponse.Position := 0;
     CustomBody.CopyFrom(atempResponse, atempResponse.Size);
     CustomBody.Position := 0;
     FreeAndNil(atempResponse);
     If Not IgnoreEvents Then
     If Assigned(OnAfterRequest) then
      OnAfterRequest(AUrl, rtPost, CustomBody);
    End;
  Finally
   vTempHeaders.Free;
   If Assigned(atempResponse) Then
    FreeAndNil(atempResponse);
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(clientConn);
   End;
 End;
 DestroyClient;
End;


Function   TRESTDWjClientLAMWClientREST.Post(AUrl            : String         = '';
                                             CustomHeaders   : TStringList    = Nil;
                                             CustomBody      : TStringList    = Nil;
                                             Const AResponse : TStringStream  = Nil;
                                             IgnoreEvents    : Boolean        = False;
                                             RawHeaders      : Boolean        = False):Integer;
Var
 temp         : TStringStream;
 vTempHeaders : TStringList;
 atempResponse: TStringStream;
 clientConn   : jObject;
Begin
 Result:= 200;
 Try
  atempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
   SetHeaders(CustomHeaders, clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   clientConn := HttpRequest.OpenConnection(AUrl);
   If RequestCharset = esUtf8 Then
    atempResponse := TStringStream.Create(utf8Decode(HttpRequest.Post(clientConn)))
   Else
    atempResponse := TStringStream.Create(HttpRequest.Post(clientConn));
   Result:= HttpRequest.GetResponseCode;
   atempResponse.Position := 0;
   atempResponse.Position := 0;
   If RequestCharset = esUtf8 Then
    AResponse.WriteString(utf8Decode(atempResponse.DataString))
   Else
    AResponse.WriteString(atempResponse.DataString);
   FreeAndNil(atempResponse);
   AResponse.Position := 0;
   If Not IgnoreEvents Then
    If Assigned(OnAfterRequest) then
     OnAfterRequest(AUrl, rtPost, AResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
   If Assigned(temp) Then
    temp.Free;
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(clientConn);
   End;
 End;
End;

Function   TRESTDWjClientLAMWClientREST.Post(AUrl            : String         = '';
                                    CustomHeaders   : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Var
 vTempHeaders : TStringList;
 aString      : String;
 clientConn   : jObject;
Begin
 Result:= 200;
 Try
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
   SetHeaders(CustomHeaders, clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   clientConn := HttpRequest.OpenConnection(AUrl);
   aString    := GetTempFileName;
   Try
    TMemoryStream(FileStream).SaveToFile(aString);
    HttpRequest.UploadFile('upload_file', aString);
   Finally
    DeleteFile(aString);
   End;
   Result := HttpRequest.GetResponseCode;
  Finally
   vTempHeaders.Free;
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(clientConn);
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWjClientLAMWClientREST.Post(AUrl              : String;
                                    Var AResponseText : String;
                                    CustomHeaders     : TStringList    = Nil;
                                    CustomParams      : TStringList    = Nil;
                                    Const CustomBody  : TStream       = Nil;
                                    Const AResponse   : TStream        = Nil;
                                    IgnoreEvents      : Boolean        = False;
                                    RawHeaders        : Boolean        = False) : Integer;
Var
 vTempHeaders : TStringList;
 atempResponse: TStringStream;
 aString,
 sResponse    : string;
 clientConn   : jObject;
Begin
 Result:= 200;
 Try
  atempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader), clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   If Assigned(CustomBody) Then
    SetParams(CustomBody)
   Else
    SetRawHeaders(vTempHeaders, clientConn);
   clientConn := HttpRequest.OpenConnection(AUrl);
   If RequestCharset = esUtf8 Then
    atempResponse := TStringStream.Create(utf8Decode(HttpRequest.Post(clientConn)))
   Else
    atempResponse := TStringStream.Create(HttpRequest.Post(clientConn));
   Result:= HttpRequest.GetResponseCode;
   atempResponse.Position := 0;
   If Not IgnoreEvents Then
    If Assigned(OnAfterRequest) then
     OnAfterRequest(AUrl, rtPost, atempResponse);
  Finally
   vTempHeaders.Free;
   If Assigned(atempResponse) Then
    FreeAndNil(atempResponse);
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(clientConn);
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWjClientLAMWClientREST.Post(AUrl            : String;
                                    CustomHeaders   : TStringList    = Nil;
                                    CustomParams    : TStringList    = Nil;
                                    FileName        : String         = '';
                                    FileStream      : TStream        = Nil;
                                    Const AResponse : TStream        = Nil;
                                    IgnoreEvents    : Boolean        = False;
                                    RawHeaders      : Boolean        = False):Integer;
Var
 aString       : String;
 vTempHeaders  : TStringList;
 clientConn    : jObject;
Begin
 Result:= 200;
 Try
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  vAUrl := AUrl;
  Try
   //Copy Custom Headers
   SetHeaders(CustomHeaders, clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforePost) then
    If Not Assigned(CustomHeaders) Then
     OnBeforePost(AUrl, vTempHeaders)
    Else
     OnBeforePost(AUrl, CustomHeaders);
   clientConn := HttpRequest.OpenConnection(AUrl);
   aString    := GetTempFileName;
   Try
    TMemoryStream(FileStream).SaveToFile(aString);
    HttpRequest.UploadFile('upload_file', aString);
   Finally
    DeleteFile(aString);
   End;
   Result := HttpRequest.GetResponseCode;
  Finally
   vTempHeaders.Free;
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(clientConn);
   End;
 End;
 DestroyClient;
End;


Function   TRESTDWjClientLAMWClientREST.Delete(AUrl            : String         = '';
                                      CustomHeaders   : TStringList    = Nil;
                                      Const AResponse : TStream        = Nil;
                                      IgnoreEvents    : Boolean        = False):Integer;
Var
 vTempHeaders  : TStringList;
 SendParams,
 atempResponse : TStringStream;
 aString       : String;
 clientConn    : jObject;
Begin
 Result:= 200;
 Try
  atempResponse := Nil;
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader), clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeDelete(AUrl, vTempHeaders)
    Else
     OnBeforeDelete(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   HttpRequest.DeleteStateful(AUrl, vTempHeaders.Text);
   Result:= HttpRequest.GetResponseCode;
  Finally
   vTempHeaders.Free;
   If Assigned(SendParams) Then
    SendParams.Free;
   If Assigned(atempResponse) Then
    atempResponse.Free;
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(HttpRequest);
   End;
 End;
 DestroyClient;
End;

Function   TRESTDWjClientLAMWClientREST.Delete(AUrl              : String;
                                      CustomHeaders     : TStringList  = Nil;
                                      CustomParams      : TStringList  = Nil;
                                      Const AResponse   : TStream      = Nil;
                                      IgnoreEvents      : Boolean      = False):Integer;
Var
 vTempHeaders : TStringList;
 aString      : String;
 clientConn   : jObject;
Begin
 Result:= 200;
 Try
  SetParams;
  SetUseSSL(UseSSL);
  vTempHeaders := TStringList.Create;
  vAUrl := AUrl;
  Try
   SetHeaders(TStringList(DefaultCustomHeader), clientConn);
   If Not IgnoreEvents Then
   If Assigned(OnBeforeDelete) then
    If Not Assigned(CustomHeaders) Then
     OnBeforeDelete(AUrl, vTempHeaders)
    Else
     OnBeforeDelete(AUrl, CustomHeaders);
   CopyStringList(CustomHeaders, vTempHeaders);
   HttpRequest.DeleteStateful(AUrl, vTempHeaders.Text);
   Result:= HttpRequest.GetResponseCode;
  Finally
   vTempHeaders.Free;
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(E.Message);
    HttpRequest.Disconnect(HttpRequest);
   End;
 End;
 DestroyClient;
End;

Constructor TRESTDWjClientLAMWClientREST.Create(AOwner: TComponent);
Begin
 Inherited;
 //application/json
 ContentType                    := cContentTypeFormUrl;
 ContentEncoding                := cDefaultContentEncoding;
 Accept                         := cDefaultAccept;
 AcceptEncoding                 := '';
 MaxAuthRetries                 := 0;
 UserAgent                      := cUserAgent;
 AccessControlAllowOrigin       := '*';
 ActiveRequest                  := '';
 RedirectMaximum                := 1;
 RequestTimeOut                 := 5000;
 ConnectTimeOut                 := 5000;
End;

Procedure TRESTDWjClientLAMWClientREST.SetRawHeaders(AHeaders       : TStringList;
                                                     Var clientConn : jObject);
Var
 I : Integer;
Begin
 HttpRequest.ClearNameValueData;
 If AccessControlAllowOrigin <> '' Then
  HttpRequest.SetRequestProperty(clientConn, 'Access-Control-Allow-Origin', AccessControlAllowOrigin);
 If Assigned(AHeaders) Then
  Begin
   If AHeaders.Count > 0 Then
    Begin
     For i := 0 to AHeaders.Count-1 do
      Begin
       If RequestCharset = esUtf8 Then
        HttpRequest.SetRequestProperty(clientConn, AHeaders.Names[i],  utf8Decode(AHeaders.ValueFromIndex[i]))
       Else
        HttpRequest.SetRequestProperty(clientConn, AHeaders.Names[i],  AHeaders.ValueFromIndex[i]);
      End;
    End;
  End;
End;

Procedure TRESTDWjClientLAMWClientREST.SetHeaders(AHeaders       : TStringList;
                                                  Var clientConn : jObject);
Var
 I           : Integer;
 vmark       : String;
 DWParams    : TRESTDWParams;
Begin
 vmark       := '';
 DWParams    := Nil;
 HttpRequest.ClearNameValueData;
 HttpRequest.SetRequestProperty(clientConn, AcceptEncoding, AcceptEncoding);
 If AccessControlAllowOrigin <> '' Then
  HttpRequest.SetRequestProperty(clientConn, 'Access-Control-Allow-Origin', AccessControlAllowOrigin);
 If Assigned(AHeaders) Then
  If AHeaders.Count > 0 Then
   For i := 0 to AHeaders.Count-1 do
    HttpRequest.SetRequestProperty(clientConn, AHeaders.Names[i], AHeaders.ValueFromIndex[i]);
 If AuthenticationOptions.AuthorizationOption in [rdwAOBasic, rdwAOBearer, rdwAOToken, rdwOAuth] Then
  Begin
   {
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
                   TRESTDWDataUtils.ParseRESTURL(ActiveRequest, RequestCharset, vmark{$IFDEF FPC}, csUndefined{$ENDIF}, DWParams);
                   If Assigned(DWParams) Then
                    FreeAndNil(DWParams);
                     Case TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).TokenType Of
                      rdwOATBasic  : Begin
                                     End;
                      rdwOATBearer : HttpRequest.Request.CustomHeaders.Add('Authorization: Bearer ' + TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).Token);
                      rdwOATToken  : HttpRequest.Request.CustomHeaders.Add('Authorization: Token ' + Format('token="%s"', [TRESTDWAuthOAuth(AuthenticationOptions.OptionParams).Token]));
                     End;
                  End;
   End;
   }
  End;
End;

Procedure TRESTDWjClientLAMWClientREST.SetOnStatus(Value : TOnStatus);
Begin
 Inherited SetOnStatus(Value);
End;

{ TRESTDWjClientLAMWClientPooler }


Procedure TRESTDWjClientLAMWClientPooler.SetParams(TransparentProxy    : TProxyConnectionInfo;
                                          aRequestTimeout      : Integer;
                                          aConnectTimeout      : Integer;
                                          AuthorizationParams : TRESTDWClientAuthOptionParams);
Begin
 HttpRequest.DefaultCustomHeader.Clear;
// HttpRequest.DefaultCustomHeader.NameValueSeparator := cNameValueSeparator;
 HttpRequest.Accept                      := Accept;
 HttpRequest.AcceptEncoding              := AcceptEncoding;
 HttpRequest.AuthenticationOptions       := AuthorizationParams;
 HttpRequest.ProxyOptions.ProxyUsername  := TransparentProxy.ProxyUsername;
 HttpRequest.ProxyOptions.ProxyServer    := TransparentProxy.ProxyServer;
 HttpRequest.ProxyOptions.ProxyPassword  := TransparentProxy.ProxyPassword;
 HttpRequest.ProxyOptions.ProxyPort      := TransparentProxy.ProxyPort;
 HttpRequest.RequestTimeout              := aRequestTimeout;
 HttpRequest.ConnectTimeout              := aConnectTimeout;
 HttpRequest.ContentType                 := ContentType;
 HttpRequest.ContentEncoding             := ContentEncoding;
 HttpRequest.AllowCookies                := AllowCookies;
 HttpRequest.HandleRedirects             := HandleRedirects;
 HttpRequest.Charset                     := Charset;
 HttpRequest.UserAgent                   := UserAgent;
 HttpRequest.OnWork                      := Self.OnWork;
 HttpRequest.OnWorkBegin                 := Self.OnWorkBegin;
 HttpRequest.OnWorkEnd                   := Self.OnWorkEnd;
 HttpRequest.OnStatus                    := Self.OnStatus;
End;

procedure TRESTDWjClientLAMWClientPooler.Abort;
begin
 {$IFNDEF RESTDWLAZARUS}
  {$IFNDEF FPC}
   Inherited;
  {$ENDIF}
 {$ENDIF}
end;

Constructor TRESTDWjClientLAMWClientPooler.Create(AOwner : TComponent);
Begin
 Inherited;
 HttpRequest            := Nil;
 ContentType            := cContentTypeFormUrl;
 ContentEncoding        := cDefaultContentEncoding;
 End;

Destructor TRESTDWjClientLAMWClientPooler.Destroy;
Begin
 If Assigned(HttpRequest) Then
  FreeAndNil(HttpRequest);
 Inherited;
End;

function TRESTDWjClientLAMWClientPooler.IsServerLive(Aip: String; Aport: Integer;
  AMessageErro: String): Boolean;
begin
  Result := True;
end;

Procedure TRESTDWjClientLAMWClientPooler.ReconfigureConnection(aTypeRequest           : Ttyperequest;
                                                      aWelcomeMessage,
                                                      aHost                  : String;
                                                      aPort                  : Integer;
                                                      Compression,
                                                      EncodeStrings          : Boolean;
                                                      aEncoding              : TEncodeSelect;
                                                      aAccessTag             : String;
                                                      aAuthenticationOptions : TRESTDWClientAuthOptionParams);
Begin
 {$IFNDEF RESTDWLAZARUS}
  {$IFNDEF FPC}
   Inherited;
  {$ENDIF}
 {$ENDIF}
End;

Function TRESTDWjClientLAMWClientPooler.SendEvent(EventData       : String;
                                         Var Params      : TRESTDWParams;
                                         EventType       : TSendEvent;
                                         DataMode        : TDataMode;
                                         ServerEventName : String;
                                         Assyncexec      : Boolean) : String;
Var
 vErrorMessage,
 vErrorMessageA,
 vDataPack,
 SResult, vURL,
 vResponse,
 vTpRequest       : String;
 vErrorCode,
 I                : Integer;
 vDWParam         : TRESTDWJSONParam;
 vResultParams    : TStringStream;
 MemoryStream,
 aStringStream,
 bStringStream,
 StringStream     : TStream;
 StringStreamList : TStringStreamList;
 JSONValue        : TRESTDWJSONValue;
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
  JSONParamNew  : TRESTDWJSONParam;
  A, InitPos    : Integer;
  vValue,
  aValue,
  vTempValue    : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Begin
    If (Encoding = esUtf8) Then //NativeResult Correções aqui
     Begin
      {$IF Defined(DELPHIXEUP)}
      //ResultJSON := PWidechar(UTF8Decode(InputValue));
      ResultJSON := PWidechar(InputValue);
      {$ELSEIF Defined(RESTDWLAZARUS)}
      ResultJSON := GetStringDecode(InputValue, DatabaseCharSet);
      {$ELSE} // delphi velho
      ResultJSON := UTF8Decode(ResultJSON);
      {$IFEND}
     End
    Else
     ResultJSON := InputValue;
    Exit;
   End;
  Try
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
   InputValue := Copy(InputValue, InitStrPos, InitPos-1) + ']}';
   If (Params <> Nil) And (InputValue <> '{"PARAMS"]}') And (InputValue <> '') Then
    Begin
     If Pos(', "RESULT":[]}', InputValue) > 0 Then
      InputValue := StringReplace(InputValue, ', "RESULT":[]}', '}', []);
     {$IFDEF DELPHIXEUP}
      bJsonValue    := TRESTDWJSONInterfaceObject.Create(InputValue);
     {$ELSE}
      If Encoding = esUtf8 Then
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(PWidechar(UTF8Decode(InputValue)))
      Else
       bJsonValue    := TRESTDWJSONInterfaceObject.Create(InputValue);
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
           JSONParam := TRESTDWJSONParam.Create(Encoding);
           Try
            JSONParam.ParamName       := bJsonOBJ.Pairs[4].name;
            JSONParam.ObjectValue     := GetValueType(bJsonOBJ.Pairs[3].Value);
            JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.Pairs[1].Value);
            JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.Pairs[2].Value);
            If Not(JSONParam.ObjectValue In [ovBlob, ovStream, ovGraphic, ovOraBlob, ovOraClob]) Then
             Begin
              If (JSONParam.Encoded) Then
               Begin
                {$IF Defined(FPC)}
                 vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value, DatabaseCharSet);
                {$ELSE}
                 vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value);
                 If Encoding = esUtf8 Then
                  vValue := Utf8Decode(vValue);
                {$IFEND}
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
              JSONParamNew           := TRESTDWJSONParam.Create(ParamsData.Encoding);
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
       If Assigned(bJsonOBJTemp) Then
        FreeAndNil(bJsonOBJTemp);
       If Assigned(bJsonOBJ) Then
        FreeAndNil(bJsonOBJ);
      End;
     {$IFNDEF FPC} //TODO XyberX
     If Assigned(bJsonValue) Then
      FreeAndNil(bJsonValue);
     {$ENDIF}
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
        vDWParam           := TRESTDWJSONParam.Create(DWParams.Encoding);
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
      JSONValue            := TRESTDWJSONValue.Create;
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
         Result := Result + Format('&%s=%s', [DWParams.Items[I].ParamName, EncodeStrings(DWParams.Items[I].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})])
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
 End;
 Procedure SetParamsValues(DWParams : TRESTDWParams); //TODO envio de parametros XyberX
 Var
  I            : Integer;
  vCharsset    : String;
 Begin
  MemoryStream  := Nil;
  If DWParams   <> Nil Then
   Begin
    If Not (Assigned(StringStreamList)) Then
     StringStreamList := TStringStreamList.Create;
    If BinaryRequest Then
     Begin
      DWParams.SaveToStream(MemoryStream);
      Try
       If Assigned(MemoryStream) Then
        Begin
         MemoryStream.Position := 0;
//         SendParamsData.AddObject( 'binarydata', 'application/octet-stream', '', MemoryStream);
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
          StringStreamList.Add({$IFDEF DELPHIXEUP}
                               TStringStream.Create(DWParams.Items[I].ToJSON, TEncoding.UTF8)
                               {$ELSE}
                               TStringStream.Create(DWParams.Items[I].ToJSON)
                               {$ENDIF});
//           SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', vCharsset, StringStreamList.Items[StringStreamList.Count-1]);
         End
        Else
         Begin
//          SendParamsData.AddFormField(DWParams.Items[I].ParamName, DWParams.Items[I].ToJSON);
         End;
       End;
     End;
   End;
 End;
 Function BuildUrl(TpRequest  : TTypeRequest;
                   Host,
                   aDataRoute : String;
                   Port       : Integer) : String;
 Var
  vTpRequest : String;
 Begin
  Result := '';

  If TpRequest = trHttp Then
   vTpRequest := 'http'
  Else If TpRequest = trHttps Then
   vTpRequest := 'https';

  if ClientIpVersion = civIPv6 then
   Host := '[' + Host + ']';

  If (aDataRoute = '') Then
   Result := LowerCase(Format(UrlBaseA, [vTpRequest, Host, Port, '/'])) + EventData
  Else
   Result := LowerCase(Format(UrlBaseA, [vTpRequest, Host, Port, aDataRoute])) + EventData;

 End;
 Procedure SetCharsetRequest(Var HttpRequest : TRESTDWjClientLAMWClientREST;
                             Charset         : TEncodeSelect);
 Begin
  If Charset = esUtf8 Then
   Begin
    If HttpRequest.ContentType = '' Then
     HttpRequest.ContentType := 'application/json;charset=utf-8';
    If HttpRequest.Charset = '' Then
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
  {$IFDEF DELPHIXEUP}
   vResultParams   := TStringStream.Create('', TEncoding.UTF8);
   //vResultParams   := TStringStream.Create('');
  {$ELSE}
   vResultParams   := TStringStream.Create('');
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
       vURL := vURL + BuildValue('dwwelcomemessage', EncodeStrings(WelcomeMessage{$IFDEF FPC}, DatabaseCharSet{$ENDIF}));
      If (AccessTag <> '') Then
       vURL := vURL + BuildValue('dwaccesstag',      EncodeStrings(AccessTag{$IFDEF FPC}, DatabaseCharSet{$ENDIF}));
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
      vURL := Format('%s&%s', [vURL, GetParamsValues(Params{$IFDEF FPC}, DatabaseCharSet{$ENDIF})]);
      If Assigned(vCripto) Then
       vURL := vURL + BuildValue('dwusecript',       BooleanToString(vCripto.Use));
      {$IFDEF DELPHIXEUP}
       aStringStream := TStringStream.Create('',TEncoding.UTF8);
      {$ELSE}
       aStringStream := TStringStream.Create('');
      {$ENDIF}
      Case EventType Of
       seGET    : vErrorCode := HttpRequest.Get(vURL, TStringList(HttpRequest.DefaultCustomHeader), aStringStream);
       seDELETE : Begin
                   //Delete do ClientPooler TODO
//                   jHttpClientAccess(HttpRequest).DoRequest(Id_HTTPMethodDelete, vURL, SendParams, aStringStream, []);
//                   vErrorCode := jHttpClientAccess(HttpRequest).ResponseCode;
                  End;
      End;
      If Not Assyncexec Then
       Begin
        If Datacompress Then
         Begin
          If Assigned(aStringStream) Then
           Begin
            aStringStream.Position:=0;
            If aStringStream.Size > 0 Then
             StringStream := ZDecompressStreamNew(aStringStream);
             If aBinaryRequest Then
              Begin
               Params.LoadFromStream(StringStream);
               If not (Params.ItemsString['MessageError'] = Nil) Then
                Begin
                 If trim(Params.ItemsString['MessageError'].AsString) = '' Then
                  ResultData   := TReplyOK
                 Else
                  ResultData := Params.ItemsString['MessageError'].AsString;
                End;
              End
             Else
              ResultData := TStringStream(aStringStream).DataString;
            FreeAndNil(aStringStream);
           // ResultData :=TStringStream(StringStream).DataString;
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
      //Envio de parametros do RESTDW TODO
//      If WelcomeMessage <> '' Then
//       SendParams.AddFormField('dwwelcomemessage', EncodeStrings(WelcomeMessage{$IFDEF FPC}, DatabaseCharSet{$ENDIF}));
//      If AccessTag <> '' Then
//       SendParams.AddFormField('dwaccesstag',      EncodeStrings(AccessTag{$IFDEF FPC}, DatabaseCharSet{$ENDIF}));
      If ServerEventName <> '' Then
       Begin
        If Assigned(Params) Then
         Begin
           vDWParam             := Params.ItemsString['dwservereventname'];
          If Not Assigned(vDWParam) Then
           vDWParam           := TRESTDWJSONParam.Create(Params.Encoding);

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
        JSONValue           := TRESTDWJSONValue.Create;
        Try
         JSONValue.Encoding := Charset;
         JSONValue.Encoded  := True;
         JSONValue.Tagname  := 'dwservereventname';
         JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
        Finally
         //Envio de parametros do RESTDW TODO
   //         SendParams.AddFormField('dwservereventname', JSONValue.ToJSON);
         FreeAndNil(JSONValue);
        End;
       End;
      //Envio de parametros do RESTDW TODO
//      SendParams.AddFormField('datacompression',   BooleanToString(Datacompress));
//      SendParams.AddFormField('dwassyncexec',      BooleanToString(Assyncexec));
//      SendParams.AddFormField('dwencodestrings',   BooleanToString(EncodedStrings));
//      SendParams.AddFormField('binaryrequest',     BooleanToString(BinaryRequest));
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
                              //Envio de parametros do RESTDW TODO
                              //SendParams.AddFormField(TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key,
                              //                        TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token);
                              vDWParam             := Params.ItemsString[TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key];
                              If Not Assigned(vDWParam) Then
                               vDWParam           := TRESTDWJSONParam.Create(Params.Encoding);
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
                              //Envio de parametros do RESTDW TODO
                              //SendParams.AddFormField(TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key,
                              //                        TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token);
                              vDWParam             := Params.ItemsString[TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key];
                              If Not Assigned(vDWParam) Then
                               vDWParam           := TRESTDWJSONParam.Create(Params.Encoding);
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
                          //Envio de parametros do RESTDW TODO
                          //If TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                            // SendParams.AddFormField(TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Key, TRESTDWAuthOptionBearerClient(AuthenticationOptions.OptionParams).Token);
                         End;
           rdwAOToken  : Begin
                          //Envio de parametros do RESTDW TODO
                          //If TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).TokenRequestType <> rdwtHeader Then
                             //SendParams.AddFormField(TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Key,  TRESTDWAuthOptionTokenClient(AuthenticationOptions.OptionParams).Token);
                         End;
          End;
         End;
       End;
      //Envio de parametros do RESTDW TODO
//      If aBinaryCompatibleMode Then
//       SendParams.AddFormField('BinaryCompatibleMode', BooleanToString(aBinaryCompatibleMode));
//      If Assigned(vCripto) Then
//       SendParams.AddFormField('dwusecript',       BooleanToString(vCripto.Use));
//      If Params <> Nil Then
//       SetParamsValues(Params, SendParams);
      If (Params <> Nil) Or (WelcomeMessage <> '') Or (Datacompress) Then
       Begin
        If HttpRequest.Accept = '' Then
         HttpRequest.Accept         := cDefaultContentType;
        If HttpRequest.AcceptEncoding = '' Then
         HttpRequest.AcceptEncoding := AcceptEncoding;
        If HttpRequest.ContentType = '' Then
         HttpRequest.ContentType     := cContentTypeFormUrl;
        If HttpRequest.ContentEncoding = '' Then
         HttpRequest.ContentEncoding := cContentTypeMultiPart;
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
          {$IFDEF DELPHIXEUP}
           aStringStream := TStringStream.Create('', TEncoding.UTF8);
           //aStringStream := TStringStream.Create('');
          {$ELSE}
           aStringStream := TStringStream.Create('');
          {$ENDIF}
          //Envio de Requisicao RESTDW TODO
//          Case EventType Of
//           sePUT    : vErrorCode := HttpRequest.Put(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
//           sePATCH  : vErrorCode := HttpRequest.Patch(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
//           sePOST   : vErrorCode := HttpRequest.Post(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
//          end;
          If Not Assyncexec Then
           Begin
            If Assigned(aStringStream) Then
             Begin
              If (aStringStream.Size > 0) And
                 ((vErrorCode = 200) or (vErrorCode = 201))      Then
               StringStream := ZDecompressStreamNew(aStringStream)
              Else
               StringStream := TStringStream.Create(TStringStream(aStringStream).DataString);
              FreeAndNil(aStringStream);
             End;
           End;
         End
        Else
         Begin
          {$IFDEF DELPHIXEUP}
           StringStream := TStringStream.Create('', TEncoding.UTF8);
          {$ELSE}
           StringStream := TStringStream.Create('');
          {$ENDIF}
          //Envio de Requisicao RESTDW TODO
          //Case EventType Of
          // sePUT    : vErrorCode := HttpRequest.Put(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, StringStream);
          // sePATCH  : vErrorCode := HttpRequest.Patch(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, aStringStream);
          // sePOST   : vErrorCode := HttpRequest.Post(URL, TStringList(HttpRequest.DefaultCustomHeader), SendParams, StringStream);
          //end;
         End;
         //        If SendParams <> Nil Then
         //Begin
         // If Assigned(StringStreamList) Then
         //  FreeAndNil(StringStreamList);
         // FreeAndNil(SendParams);
         //End;
       End
      Else
       Begin
        HttpRequest.ContentType     := cDefaultContentType;
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
          If (vErrorCode = 200) or (vErrorCode = 201) Then
           Begin
            StringStream.Position := 0;
            Params.LoadFromStream(StringStream);
             {$IFDEF DELPHIXEUP}
             TStringStream(StringStream).Clear;
             {$ENDIF}
             {$IFNDEF RESTDWLAZARUS}
             StringStream.Size := 0;
             {$ENDIF}
             If not (Params.ItemsString['MessageError'] = Nil) Then
             Begin
              if Params.ItemsString['MessageError'].AsString = trim('') then
               ResultData   := TReplyOK
              else
               ResultData := Params.ItemsString['MessageError'].AsString;

             end;
           End
          Else
           Begin
            ErrorMessage := TStringStream(StringStream).DataString;
            ResultData   := TReplyNOK;
           End;
          FreeAndNil(StringStream);
         End;
       End
      Else
       Begin
        If Not Assyncexec Then
         Begin
          If Assigned(StringStream) Then
           Begin
            StringStream.Position := 0;
            If Datacompress Then
             vDataPack := BytesToString(StreamToBytes(TMemoryStream(StringStream)))
            Else
             vDataPack := TStringStream(StringStream).DataString;
             {$IFDEF DELPHIXEUP}
             TStringStream(StringStream).Clear;
             {$ENDIF}
             {$IFNDEF RESTDWLAZARUS}
             StringStream.Size := 0;
             {$ENDIF}
            FreeAndNil(StringStream);
            SetData(vDataPack, Params, ResultData);
           End
          Else
           Begin
            SetData(vDataPack, Params, ResultData);
           End;
          If not (vErrorCode in [200,201]) Then
           Begin
            ErrorMessage := ResultData;
            ResultData   := TReplyNOK;
           End;
         End;
       End;
     End;
   End;
   // Eloy
   case vErrorCode of
     401: ErrorMessage := cInvalidAuth;
     404: ErrorMessage := cEventNotFound;
     405: ErrorMessage := cInvalidPoolerName;
   end;
  Except
   On E : Exception Do
    Begin
     Result := False;
     ResultData := GetPairJSONStr('NOK', PoolerNotFoundMessage);
//     If Assigned(SendParams) then
//      FreeAndNil(SendParams);
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
       {$IFDEF RESTDWFMX}
       ErrorMessage := PoolerNotFoundMessage;
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
//  If Assigned(SendParams) then
//   FreeAndNil(SendParams);
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
// SendParams       := Nil;
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
 vURL  := BuildUrl(TypeRequest, Host, DataRoute, Port);
 If Assigned(HttpRequest) Then
  FreeAndNil(HttpRequest);
 HttpRequest      := TRESTDWjClientLAMWClientREST.Create(Nil);
// If (TypeRequest = trHttps) Then
//  HttpRequest.SSLVersions := PIdSSLVersions(@SSLVersions)^;
 HttpRequest.UserAgent := UserAgent;
 SetCharsetRequest(HttpRequest, Encoding);
 SetParams(ProxyOptions, RequestTimeout, ConnectTimeout, AuthenticationOptions);
 HttpRequest.MaxAuthRetries := 0;
// HttpRequest.DefaultCustomHeader.NameValueSeparator := cNameValueSeparator;
 If BinaryRequest Then
  If HttpRequest.DefaultCustomHeader.IndexOfName('binaryrequest') = -1 Then
    HttpRequest.DefaultCustomHeader.Add('binaryrequest=true');

 If aBinaryCompatibleMode Then
  If HttpRequest.DefaultCustomHeader.IndexOfName('BinaryCompatibleMode') = -1 Then
    HttpRequest.DefaultCustomHeader.Add('BinaryCompatibleMode=true');

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
              (FailOverConnections[I].DataRoute       = DataRoute))        Or
             (Not (FailOverConnections[I].Active)) Then
          Continue;
         End;
        If Assigned(OnFailOverExecute) Then
         OnFailOverExecute(FailOverConnections[I]);
        vURL  := BuildUrl(FailOverConnections[I].TypeRequest,
                          FailOverConnections[I].Host,
                          FailOverConnections[I].DataRoute,
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
  If Assigned(HttpRequest) Then
   FreeAndNil(HttpRequest);

  If (vErrorMessage <> '') Then
   Begin
    //Result := unescape_chars(vErrorMessage);
    Result := vErrorMessage;
    Raise Exception.Create(Result);
   End;
 End;
End;

{ TRESTDWjClientLAMWDatabase }

Constructor TRESTDWjClientLAMWDatabase.Create(AOwner: TComponent);
Begin
 Inherited;
 RESTClientPooler                                        := TRESTDWjClientLAMWClientPooler.Create(Self);
 ContentType                                             := cContentTypeFormUrl;
 ContentEncoding                                         := cDefaultContentEncoding;
 TRESTDWjClientLAMWClientPooler(RESTClientPooler).ClientIpVersion := ClientIpVersion;
End;

Destructor TRESTDWjClientLAMWDatabase.Destroy;
Begin
 DestroyClientPooler;

 Inherited;
End;


function TRESTDWjClientLAMWDatabase.IsServerLive(Aip: String; Aport: Integer; AMessageErro: String): Boolean;
begin
 Result := True;
end;

{ TRESTDWjClientLAMWPoolerList }

constructor TRESTDWjClientLAMWPoolerList.Create(AOwner: TComponent);
begin
  Inherited;

  RESTClientPooler := TRESTDWjClientLAMWClientPooler.Create(Self);
end;

destructor TRESTDWjClientLAMWPoolerList.Destroy;
begin

  Inherited;
end;

{ TRESTDWjClientLAMWClientHttpBase }

Constructor TRESTDWjClientLAMWClientHttpBase.Create(AOwner : TComponent);
Begin
 Inherited;
 ContentType                    := cContentTypeFormUrl;
 ContentEncoding                := cDefaultContentEncoding;
 Accept                         := cDefaultAccept;
 AcceptEncoding                 := '';
 MaxAuthRetries                 := 0;
 UserAgent                      := cUserAgent;
 AccessControlAllowOrigin       := '*';
 ActiveRequest                  := '';
 RedirectMaximum                := 1;
 RequestTimeOut                 := 5000;
 ConnectTimeOut                 := 5000;
End;

Function TRESTDWjClientLAMWClientHttpBase.Delete(AUrl                 : String;
                                        Const CustomHeaders  : TStringList     = Nil;
                                        Const CustomParams   : TStringList     = Nil;
                                        Const AResponse      : TStream         = Nil;
                                        Const AResponseError : TStream         = Nil): Integer;
Begin

End;

Destructor TRESTDWjClientLAMWClientHttpBase.Destroy;
Begin
 If Assigned(HttpRequest) then
  Begin
   Try
    If Assigned(HttpRequest) Then
     Begin
      HttpRequest.Disconnect(HttpRequest);
     End;
   Except
   End;
   FreeAndNil(HttpRequest);
  End;
 Inherited;
End;

Procedure TRESTDWjClientLAMWClientHttpBase.DestroyClient;
Begin
 //
End;

Function TRESTDWjClientLAMWClientHttpBase.Get(AUrl                 : String          = '';
                                     Const CustomHeaders  : TStringList     = Nil;
                                     Const AResponse      : TStream         = Nil;
                                     Const AResponseError : TStream         = Nil) : Integer;
Begin

End;

Function TRESTDWjClientLAMWClientHttpBase.Post(AUrl                 : String          = '';
                                      Const CustomHeaders  : TStringList     = Nil;
                                      Const CustomParams   : TStringList     = Nil;
                                      Const CustomBody     : TStream         = Nil;
                                      Const AResponse      : TStream         = Nil;
                                      Const AResponseError : TStream         = Nil) : Integer;
Begin

End;

Procedure TRESTDWjClientLAMWClientHttpBase.SetHeaders(AHeaders : TStringList);
Begin

End;

Procedure TRESTDWjClientLAMWClientHttpBase.SetInternalEvents;
Begin

End;

Procedure TRESTDWjClientLAMWClientHttpBase.SetOnStatus(Value : TOnStatus);
Begin
 Inherited;

End;

Procedure TRESTDWjClientLAMWClientHttpBase.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
 Inherited;

End;

Procedure TRESTDWjClientLAMWClientHttpBase.SetParams;
Begin

End;

End.
