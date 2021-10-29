unit uRESTDWBaseIDQX;

{$I uRESTDW.inc}

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
 A. Brito                   - Admin - Administrador do CORE do pacote.
 Ari                        - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Ico Menezes                - Member Tester and DEMO Developer.
}

interface

Uses
   uRESTDWQuickX,               ServerUtils,    uDWConsts, uDWJSONTools,
   SysTypes,
   {$IFDEF FPC}
   SysUtils,                    Classes,
   IdHash, IdHeaderList,        IdContext,               IdHTTPServer,
   IdCustomHTTPServer,          IdSSLOpenSSL,            IdSSL,
   IdAuthentication,            IdHTTPHeaderInfo,
   IdMessageCoderMIME,          IdMultipartFormData,     IdMessageCoder,
   IdHashMessageDigest,         IdMessage, uDWJSON,      IdStack,    uDWJSONObject,
   IdGlobal, IdGlobalProtocols, IdURI, uDWConstsCharset, LConvEncoding;
   {$ELSE}
   {$IF CompilerVersion <= 22}
    SysUtils, Classes, EncdDecd,
   {$ELSE}
    System.SysUtils, System.Classes,
   {$IFEND}
   IdHash, IdHeaderList,  IdContext,           IdHTTPServer,
   IdCustomHTTPServer,    idSSLOpenSSL,        IdSSL,
   IdAuthentication,      IdHTTPHeaderInfo,    IdMessageCoder,
   IdMessageCoderMIME,    IdMultipartFormData, IdHashMessageDigest,
   IdMessage,             uDWJSON, IdStack,    uDWJSONObject,
   IdGlobal, IdGlobalProtocols, IdURI,         uDWConstsCharset;
   {$ENDIF}

Type
 TRESTDWServerQXID = Class(TRESTDWQXBasePooler)
 Private
  vOnCreate : TOnCreate;
  vASSLRootCertFile,
  ASSLPrivateKeyFile,
  ASSLPrivateKeyPassword,
  ASSLCertFile         : String;
  vConsoleMode,
  vForceWelcomeAccess,
  vActive              : Boolean;
  vServicePort         : Integer;
  HTTPServer           : TIdHTTPServer;
  aSSLMethod           : TIdSSLVersion;
  aSSLVersions         : TIdSSLVersions;
  vLastRequest         : TLastRequest;
  vLastResponse        : TLastResponse;
  vSSLVerifyMode       : TIdSSLVerifyModeSet;
  lHandler             : TIdServerIOHandlerSSLOpenSSL;
  vSSLVerifyDepth      : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet     : TDatabaseCharSet;
  {$ENDIF}
  Procedure SetActive      (Value  : Boolean);Override;
  Function  SSLVerifyPeer (Certificate : TIdX509; AOk : Boolean; ADepth, AError : Integer) : Boolean;
  Procedure GetSSLPassWord (Var Password              : {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
                                                                                     AnsiString
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$IFEND}
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$ENDIF});
  Function  GetSecure : Boolean;
  Procedure Loaded; Override;
  Procedure IdHTTPServerQuerySSLPort  (APort           : Word;
                                       Var VUseSSL     : Boolean);
  Procedure CreatePostStream          (AContext        : TIdContext;
                                       AHeaders        : TIdHeaderList;
                                       Var VPostStream : TStream);
  Procedure OnParseAuthentication     (AContext        : TIdContext;
                                       Const AAuthType,
                                       AAuthData       : String;
                                       Var VUsername,
                                       VPassword       : String;
                                       Var VHandled    : Boolean);
  Procedure CustomOnConnect           (AContext        : TIdContext);
  Procedure aCommandGet  (AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
  Procedure aCommandOther(AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
 Public
  Constructor Create       (AOwner : TComponent);Override; //Cria o Componente
  Destructor  Destroy; Override;                           //Destroy a Classe
  Procedure   Bind         (Port        : Integer = 9092;
                            ConsoleMode : Boolean = True);Override;
 Published
  Property Secure                  : Boolean                    Read GetSecure;
  Property ServicePort             : Integer                    Read vServicePort             Write vServicePort;  //A Porta do Serviço do DataSet
  Property SSLPrivateKeyFile       : String                     Read aSSLPrivateKeyFile       Write aSSLPrivateKeyFile;
  Property SSLPrivateKeyPassword   : String                     Read aSSLPrivateKeyPassword   Write aSSLPrivateKeyPassword;
  Property SSLCertFile             : String                     Read aSSLCertFile             Write aSSLCertFile;
  Property SSLMethod               : TIdSSLVersion              Read aSSLMethod               Write aSSLMethod;
  Property SSLVersions             : TIdSSLVersions             Read aSSLVersions             Write aSSLVersions;
  Property OnLastRequest           : TLastRequest               Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse              Read vLastResponse            Write vLastResponse;
  Property SSLRootCertFile         : String                     Read vaSSLRootCertFile        Write vaSSLRootCertFile;
  property SSLVerifyMode           : TIdSSLVerifyModeSet        Read vSSLVerifyMode           Write vSSLVerifyMode;
  property SSLVerifyDepth          : Integer                    Read vSSLVerifyDepth          Write vSSLVerifyDepth;
  {$IFDEF FPC}
  Property DatabaseCharSet         : TDatabaseCharSet           Read vDatabaseCharSet         Write vDatabaseCharSet;
  {$ENDIF}
  Property OnCreate                : TOnCreate                  Read vOnCreate                Write vOnCreate;
End;

implementation

Function TRESTDWServerQXID.GetSecure : Boolean;
Begin
 Result:= vActive And (HTTPServer.IOHandler is TIdServerIOHandlerSSLBase);
End;

Procedure TRESTDWServerQXID.Loaded;
Begin
 Inherited;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

Procedure TRESTDWServerQXID.IdHTTPServerQuerySSLPort(APort       : Word;
                                                     Var VUseSSL : Boolean);
Begin
 VUseSSL := (APort = Self.ServicePort);
End;

Procedure TRESTDWServerQXID.CustomOnConnect(AContext : TIdContext);
Begin
 AContext.Connection.Socket.ReadTimeout := RequestTimeout;
End;

Procedure TRESTDWServerQXID.OnParseAuthentication(AContext         : TIdContext;
                                                  Const AAuthType,
                                                  AAuthData        : String;
                                                  Var VUsername,
                                                  VPassword        : String;
                                                  Var VHandled     : Boolean);
Var
 vAuthValue : TRDWAuthRequest;
Begin
  {$IFNDEF FPC}
   {$IF Not Defined(HAS_FMX)}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.Data        = Nil) Then
     Begin
      vAuthValue       := TRDWAuthRequest.Create;
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
      VHandled            := vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
     End;
    {$ELSE}
    If (Lowercase(AAuthType) = Lowercase('bearer')) Or
       (Lowercase(AAuthType) = Lowercase('token'))  And
       (AContext.DataObject  = Nil) Then
     Begin
      vAuthValue          := TRDWAuthRequest.Create;
      vAuthValue.Token    := AAuthType + ' ' + AAuthData;
      AContext.DataObject := vAuthValue;
      VHandled            := vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
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
     VHandled         := vServerAuthOptions.AuthorizationOption In [rdwAOBearer, rdwAOToken];
    End;
  {$ENDIF}
End;

Procedure TRESTDWServerQXID.CreatePostStream(AContext        : TIdContext;
                                             AHeaders        : TIdHeaderList;
                                             Var VPostStream : TStream);
Var
 headerIndex : Integer;
 vValueAuth  : String;
 vAuthValue  : TRDWAuthRequest;
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
     vAuthValue       := TRDWAuthRequest.Create;
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

Procedure TRESTDWServerQXID.aCommandGet(AContext      : TIdContext;
                                        ARequestInfo  : TIdHTTPRequestInfo;
                                        AResponseInfo : TIdHTTPResponseInfo);
Var
 I                  : Integer;
 DWParamsD,
 DWParams           : TDWParams;
 vBasePath,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 vParamsUrl,
 aCmd,
 Cmd,
 tmp, JSONStr,
 sFile,
 sContentType,
 vContentType,
 LocalDoc,
 vIPVersion,
 vDataBuff,
 vCORSOption,
 vAuthenticationString,
 vObjectName,
 sCharSet            : String;
 vAuthTokenParam     : TRDWAuthTokenParam;
 newdecoder,
 Decoder             : TIdMessageDecoder;
 vRDWQXDataRoute     : TRESTDWQXDataRoute;
 JSONParam           : TJSONParam;
 JSONValue           : TJSONValue;
 vTagReply,
 vdwCriptKey,
 vMetadata,
 vBinaryCompatibleMode,
 vBinaryEvent,
 dwassyncexec,
 vFileExists,
 encodestrings,
 compresseddata,
 vNeedAuthorization,
 msgEnd              : Boolean;
 ServerContextStream : TMemoryStream;
 mb,
 mb2,
 ms                  : TStringStream;
 RequestType         : TRequestType;
 vDecoderHeaderList  : TStringList;
 Ctxt                : TRESTDWComponent;
 Function ExcludeTag(Value : String) : String;
 Begin
  Result := Value;
  If (UpperCase(Copy (Value, InitStrPos, 3)) = 'GET')    or
     (UpperCase(Copy (Value, InitStrPos, 4)) = 'POST')   or
     (UpperCase(Copy (Value, InitStrPos, 3)) = 'PUT')    or
     (UpperCase(Copy (Value, InitStrPos, 6)) = 'DELETE') or
     (UpperCase(Copy (Value, InitStrPos, 5)) = 'PATCH')  Then
   Begin
    While (Result <> '') And (Result[InitStrPos] <> '/') Do
     Delete(Result, 1, 1);
   End;
  If Result <> '' Then
   If Result[InitStrPos] = '/' Then
    Delete(Result, 1, 1);
  Result := Trim(Result);
 End;
 Function GetFileOSDir(Value : String) : String;
 Begin
  {$IF Defined(ANDROID) Or Defined(IOS)}
  Result := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, Value);
  {$ELSE}
  Result := vBasePath + Value;
  {$IFEND}
  {$IFDEF MSWINDOWS}
   Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  {$ENDIF}
 End;
 Function GetLastMethod(Value : String) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> '' Then
   Begin
    If Value[Length(Value) - FinalStrPos] <> '/' Then
     Begin
      For I := (Length(Value) - FinalStrPos) Downto InitStrPos Do
       Begin
        If Value[I] <> '/' Then
         Result := Value[I] + Result
        Else
         Break;
       End;
     End;
   End;
 End;
 Procedure ReadRawHeaders;
 Var
  I: Integer;
 Begin
  Ctxt.InHeaders.Text := '';
  If ARequestInfo.RawHeaders = Nil Then
   Exit;
  Try
   If ARequestInfo.RawHeaders.Count > 0 Then
    Begin
     For I := 0 To ARequestInfo.RawHeaders.Count -1 Do
      Begin
       tmp := ARequestInfo.RawHeaders.Names[I];
       Ctxt.InHeaders.Add(Format('%s=%s', [ARequestInfo.RawHeaders.Names[I], ARequestInfo.RawHeaders.Values[tmp]]));
       If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
        Ctxt.WelcomeMessage := DecodeStrings(ARequestInfo.RawHeaders.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('dwaccesstag', lowercase(tmp)) > 0 Then
        Ctxt.AccessTag := DecodeStrings(ARequestInfo.RawHeaders.Values[tmp]{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
       Else If pos('datacompression', lowercase(tmp)) > 0 Then
        compresseddata := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
        encodestrings  := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else If pos('dwusecript', lowercase(tmp)) > 0 Then
        vdwCriptKey    := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else If (pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
        dwassyncexec   := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
       Else if pos('binaryrequest', lowercase(tmp)) > 0 Then
        vBinaryEvent   := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
//       Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
//        Begin
//         vdwConnectionDefs   := TConnectionDefs.Create;
//         JSONValue           := TJSONValue.Create;
//         Try
//          JSONValue.Encoding  := VEncondig;
//          JSONValue.Encoded  := True;
//          JSONValue.LoadFromJSON(ARequestInfo.RawHeaders.Values[tmp]);
//          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
//         Finally
//          FreeAndNil(JSONValue);
//         End;
//        End
       Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
        Begin
         JSONValue           := TJSONValue.Create;
         Try
          JSONValue.Encoding  := Encoding;
          JSONValue.Encoded  := True;
          {$IFDEF FPC}
          JSONValue.DatabaseCharSet := vDatabaseCharSet;
          {$ENDIF}
          JSONValue.LoadFromJSON(ARequestInfo.RawHeaders.Values[tmp]);
         Finally
          FreeAndNil(JSONValue);
         End;
        End;
      End;
    End;
  Finally
   tmp := '';
  End;
 End;
 Procedure MyDecodeAndSetParams(ARequestInfo: TIdHTTPRequestInfo);
 Var
  i, j      : Integer;
  value, s  : String;
  {$IFNDEF FPC}
    {$IF (DEFINED(OLDINDY))}
     LEncoding : TIdTextEncoding
    {$ELSE}
     LEncoding : IIdTextEncoding
    {$IFEND}
  {$ELSE}
   LEncoding : IIdTextEncoding
  {$ENDIF};
 Begin
  If ARequestInfo.CharSet <> '' Then
   LEncoding := CharsetToEncoding(ARequestInfo.CharSet)
  Else
  {$IFNDEF FPC}
    {$IF (DEFINED(OLDINDY))}
     LEncoding := enDefault;
    {$ELSE}
     LEncoding := IndyTextEncoding_UTF8;
    {$IFEND}
  {$ELSE}
   LEncoding := IndyTextEncoding_UTF8;
  {$ENDIF};
  value := ARequestInfo.RawHeaders.Text;
  Try
   i := 1;
   While i <= Length(value) Do
    Begin
     j := i;
     While (j <= Length(value)) And (value[j] <> '&') Do
      Inc(j);
     s := StringReplace(Copy(value, i, j-i), '+', ' ', [rfReplaceAll]);
     ARequestInfo.Params.Add(TIdURI.URLDecode(s{$IFNDEF FPC}{$IF Not(DEFINED(OLDINDY))}, LEncoding{$IFEND}{$ELSE}, LEncoding{$ENDIF}));
     i := j + 1;
    End;
  Finally
  End;
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(Ctxt) Then
   FreeAndNil(Ctxt);
  If Assigned(vAuthTokenParam)   Then
   FreeAndNil(vAuthTokenParam);
  If Assigned(vAuthTokenParam) Then
   FreeAndNil(vAuthTokenParam);
 End;
 Procedure WriteError;
 Begin
  AResponseInfo.ResponseNo   := Ctxt.StatusCode;
  {$IFNDEF FPC}
   mb                                  := TStringStream.Create(Ctxt.ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
   mb.Position                          := 0;
   AResponseInfo.FreeContentStream      := True;
   AResponseInfo.ContentStream          := mb;
   AResponseInfo.ContentStream.Position := 0;
   AResponseInfo.ContentLength          := mb.Size;
   AResponseInfo.WriteContent;
  {$ELSE}
   mb                                  := TStringStream.Create(Ctxt.ErrorMessage);
   mb.Position                          := 0;
   AResponseInfo.FreeContentStream      := True;
   AResponseInfo.ContentStream          := mb;
   AResponseInfo.ContentStream.Position := 0;
   AResponseInfo.ContentLength          := -1;//mb.Size;
   AResponseInfo.WriteContent;
  {$ENDIF}
 End;
 Function ClearRequestType(Value : String) : String;
 Begin
  Result := Value;
  If (Pos('GET ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'GET ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('POST ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'POST ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PUT ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PUT ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('DELETE ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'DELETE ', '', [rfReplaceAll, rfIgnoreCase])
  Else If (Pos('PATCH ', UpperCase(Result)) > 0)   Then
   Result := StringReplace(Result, 'PATCH ', '', [rfReplaceAll, rfIgnoreCase]);
 End;
Begin
 mb2                   := Nil;
 mb                    := Nil;
 ms                    := Nil;
 vAuthTokenParam       := Nil;
 tmp                   := '';
 vIPVersion            := 'ipv4';
 vRDWQXDataRoute       := Nil;
 vObjectName           := '';
 Ctxt                  := TRESTDWComponent.Create(Nil);
 Ctxt.JsonMode         := jmPureJSON;
 Ctxt.WelcomeAccept    := True;
 Ctxt.AccessTag        := '';
 vParamsUrl            := '';
 vContentType          := vContentType;
 DWParams              := Nil;
 ServerContextStream   := Nil;
 mb                    := Nil;
 vTagReply             := False;
 compresseddata        := False;
 encodestrings         := False;
 dwassyncexec          := False;
 vBinaryEvent          := False;
 vBinaryCompatibleMode := False;
 vMetadata             := False;
 vdwCriptKey           := False;
 Ctxt.StatusCode       := 200;
 vDataBuff             := '';
 Cmd                   := RemoveBackslashCommands(Trim(ARequestInfo.RawHTTPCommand));
 sCharSet              := '';
 If (UpperCase(Copy (Cmd, 1, 3)) = 'GET')    Then
  Begin
   If     (Pos('.HTML', UpperCase(Cmd)) > 0) Then
    Begin
     sContentType:='text/html';
	   sCharSet := 'utf-8';
    End
   Else If (Pos('.PNG', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/png'
   Else If (Pos('.ICO', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/ico'
   Else If (Pos('.GIF', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/gif'
   Else If (Pos('.JPG', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/jpg'
   Else If (Pos('.JS',  UpperCase(Cmd)) > 0) Then
    sContentType := 'application/javascript'
   Else If (Pos('.PDF', UpperCase(Cmd)) > 0) Then
    sContentType := 'application/pdf'
   Else If (Pos('.CSS', UpperCase(Cmd)) > 0) Then
    sContentType:='text/css';
   {$IFNDEF FPC}
    {$if CompilerVersion > 21}
     sFile := RootPath + RemoveBackslashCommands(ARequestInfo.URI);
    {$ELSE}
     sFile := RootPath + RemoveBackslashCommands(ARequestInfo.Command);
    {$IFEND}
   {$ELSE}
    sFile := RootPath  + RemoveBackslashCommands(ARequestInfo.URI);
   {$ENDIF}
   If DWFileExists(sFile, RootPath) then
    Begin
     AResponseInfo.ContentType := GetMIMEType(sFile);
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
     	 If (sCharSet <> '') Then
        AResponseInfo.CharSet := sCharSet;
      {$IFEND}
     {$ENDIF}
     AResponseInfo.ContentStream := TIdReadFileExclusiveStream.Create(sFile);
     AResponseInfo.WriteContent;
     Exit;
    End;
  End;
 Try
  Cmd := RemoveBackslashCommands(Trim(ARequestInfo.RawHTTPCommand));
//  vRequestHeader.Add(Cmd);
  Cmd := StringReplace(Cmd, ' HTTP/1.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/1.1', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.1', '', [rfReplaceAll]);
  vCORSOption := UpperCase(Copy(Cmd, 1, 7));
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET' )   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'POST')   OR
     (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')    OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'DELE')   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'PATC')   OR
     (UpperCase(Copy (Cmd, 1, 3)) = 'OPT' )   Then
   Begin
    RequestType := rtGet;
    If (UpperCase(Copy (Cmd, 1, 4))      = 'POST') Then
     RequestType := rtPost
    Else If (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')  Then
     RequestType := rtPut
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'DELE') Then
     RequestType := rtDelete
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'PATC') Then
     RequestType := rtPatch;
    {$IFNDEF FPC}
     If {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}RemoveBackslashCommands(ARequestInfo.Command)
                                      {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$IFEND}
                                      {$ELSE}RemoveBackslashCommands(ARequestInfo.URI){$ENDIF} = '/favicon.ico' Then
      Exit;
    {$ELSE}
     If RemoveBackslashCommands(ARequestInfo.URI) = '/favicon.ico' Then
      Exit;
    {$ENDIF}
    ReadRawHeaders;
    AResponseInfo.CustomHeaders.Clear;
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
    Ctxt.URL := ClearRequestType(Cmd);
    If Ctxt.URL <> '' Then
     Begin
      aCmd            := Ctxt.URL;
      vRDWQXDataRoute := FindRoute(aCmd, vParamsUrl);
      Ctxt.DataRoute  := vRDWQXDataRoute;
      If vRDWQXDataRoute <> Nil Then
       Begin
        TServerUtils.ParseRESTURL (vParamsUrl, Encoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, DWParams);
        Ctxt.URL := vRDWQXDataRoute.DataRoute;
       End
      Else
       Begin
        {$IFDEF FPC}
         If (Ctxt.URL = '/') Then
          Begin
           If vDefaultPage.Count > 0 Then
            vReplyString  := vDefaultPage.Text
           Else
            vReplyString    := TServerStatusHTMLQX;
           Ctxt.StatusCode  := 200;
           AResponseInfo.ContentType := 'text/html';
           If VEncondig = esUtf8 Then
            mb                                   := TStringStream.Create(Utf8Encode(vReplyString))
           Else
            mb                                   := TStringStream.Create(vReplyString);
          End
         Else
          Begin
           If VEncondig = esUtf8 Then
            mb                                   := TStringStream.Create(Utf8Encode(cInvalidRequest))
           Else
            mb                                   := TStringStream.Create(cInvalidRequest);
          End;
         mb.Position                           := 0;
         AResponseInfo.FreeContentStream       := True;
         AResponseInfo.ContentStream           := mb;
         AResponseInfo.ContentStream.Position  := 0;
         AResponseInfo.ContentLength           := -1;
        {$ELSE}
         {$IF CompilerVersion > 21}
          If (Ctxt.URL = '/') Then
           Begin
            If DefaultPage.Count > 0 Then
             vReplyString  := DefaultPage.Text
            Else
             vReplyString    := TServerStatusHTMLQX;
            Ctxt.StatusCode  := 200;
            AResponseInfo.ContentType := 'text/html';
            If Encoding = esUtf8 Then
             mb                                   := TStringStream.Create(Utf8Encode(vReplyString))
            Else
             mb                                   := TStringStream.Create(vReplyString);
           End
          Else
           mb                                   := TStringStream.Create(cInvalidRequest{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
          mb.Position                          := 0;
          AResponseInfo.FreeContentStream      := True;
          AResponseInfo.ContentStream          := mb;
          AResponseInfo.ContentStream.Position := 0;
          AResponseInfo.ContentLength          := mb.Size;
         {$ELSE}
          AResponseInfo.ContentLength          := -1;
          If (Ctxt.URL = '/') Then
           Begin
            If vDefaultPage.Count > 0 Then
             vReplyString  := vDefaultPage.Text
            Else
             vReplyString    := TServerStatusHTMLQX;
            Ctxt.StatusCode  := 200;
            AResponseInfo.ContentType := 'text/html';
            If VEncondig = esUtf8 Then
             AResponseInfo.ContentText            := Utf8Encode(vReplyString)
            Else
             AResponseInfo.ContentText            := vReplyString;
           End
          Else
           AResponseInfo.ContentText            := cInvalidRequest;
         {$IFEND}
        {$ENDIF}
        Exit;
       End;
     End;
    If ((ARequestInfo.Params.Count > 0) And (RequestType In [rtGet, rtPost, rtDelete])) Then
     Begin
      TServerUtils.ParseWebFormsParams(DWParams, ARequestInfo.Params, Encoding
                                       {$IFDEF FPC}, vDatabaseCharSet{$ENDIF}, RequestTypeToString(RequestType));
      If DWParams <> Nil Then
       Begin
        If (DWParams.ItemsString['dwwelcomemessage']     <> Nil)    Then
         Ctxt.WelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If (DWParams.ItemsString['dwaccesstag']          <> Nil)    Then
         Ctxt.AccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
        If (DWParams.ItemsString['datacompression']      <> Nil)    Then
         compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
        If (DWParams.ItemsString['dwencodestrings']      <> Nil)    Then
         encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
        If (DWParams.ItemsString['dwusecript']           <> Nil)    Then
         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
        If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil)    Then
         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
       End;
     End
    Else
     Begin
      If (RequestType In [rtGet, rtDelete]) Then
       Begin
        If (DWParams.ItemsString['dwusecript']           <> Nil) Then
         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
        If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
         dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
        If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
       End;
      If (RequestType In [rtPut, rtPatch, rtDelete]) Then //New Code to Put
       Begin
        If ARequestInfo.FormParams <> '' Then
         Begin
          TServerUtils.ParseFormParamsToDWParam(ARequestInfo.FormParams, Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
           Ctxt.WelcomeMessage    := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
           Ctxt.AccessTag         := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
          If (DWParams.ItemsString['datacompression']      <> Nil) Then
           compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
          If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
           encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
          If (DWParams.ItemsString['dwusecript']           <> Nil) Then
           vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
          If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
           dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
          If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
           vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
         End;
       End;
      If Assigned(ARequestInfo.PostStream) Then
       Begin
         ARequestInfo.PostStream.Position := 0;
         If Not vBinaryEvent Then
          Begin
           Try
            mb := TStringStream.Create(''); //{$IFNDEF FPC}{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
            try
             mb.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
             ARequestInfo.PostStream.Position := 0;
             mb.Position := 0;
             If (pos('--', mb.DataString) > 0) and (pos('boundary', ARequestInfo.ContentType) > 0) Then
              Begin
                msgEnd   := False;
                {$IFNDEF FPC}
                 {$IF (DEFINED(OLDINDY))}
                  boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary');
                 {$ELSE}
                  boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                 {$IFEND}
                {$ELSE}
                 boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                {$ENDIF}
                startboundary := '--' + boundary;
                Repeat
                 tmp := ReadLnFromStream(ARequestInfo.PostStream, -1, True);
                until tmp = startboundary;
              End;
            finally
             if Assigned(mb) then
              FreeAndNil(mb);
            end;
           Except
           End;
          End;
        If (ARequestInfo.PostStream.Size > 0) And (boundary <> '') Then
         Begin
          Try
           Repeat
            decoder := TIdMessageDecoderMIME.Create(nil);
            TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
            decoder.SourceStream := ARequestInfo.PostStream;
            decoder.FreeSourceStream := False;
            decoder.ReadHeader;
            Inc(I);
            Case Decoder.PartType of
             mcptAttachment:
              Begin
               ms := TStringStream.Create('');
               ms.Position := 0;
               NewDecoder := Decoder.ReadBody(ms, MsgEnd);
               vDecoderHeaderList := TStringList.Create;
               vDecoderHeaderList.Assign(Decoder.Headers);
               sFile := ExtractFileName(Decoder.FileName);
               FreeAndNil(Decoder);
               Decoder := NewDecoder;
               If Decoder <> Nil Then
                TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
//               If vDataRouteList.Count > 0 Then
//                Inc(aParamsCount);
               If Not Assigned(DWParams) Then
                Begin
                 If (ARequestInfo.Params.Count = 0) Then
                  Begin
                   DWParams           := TDWParams.Create;
                   DWParams.Encoding  := Encoding;
                  End
                 Else
                  TServerUtils.ParseWebFormsParams(DWParams, ARequestInfo.Params, Encoding{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                End;
               JSONParam    := TJSONParam.Create(DWParams.Encoding);
               JSONParam.ObjectDirection := odIN;
               vObjectName  := '';
               sContentType := '';
               For I := 0 To vDecoderHeaderList.Count - 1 Do
                Begin
                 tmp := vDecoderHeaderList.Strings[I];
                 If Pos('; name="', lowercase(tmp)) > 0 Then
                  Begin
                   vObjectName := Copy(lowercase(tmp),
                                       Pos('; name="', lowercase(tmp)) + length('; name="'),
                                       length(lowercase(tmp)));
                   vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                  End;
                 If Pos('content-type=', lowercase(tmp)) > 0 Then
                  Begin
                   sContentType := Copy(lowercase(tmp),
                                       Pos('content-type=', lowercase(tmp)) + length('content-type='),
                                       length(lowercase(tmp)));
                  End;
                End;
                // Correção de FORM-DATA / FILE criar parametros automaticos: ICO 20-09-2019
               If (vObjectName <> '') Then
                JSONParam.ParamName        := vObjectName
               Else
                Begin
                 vObjectName := 'dwfilename';
                 JSONParam.ParamName       := vObjectName
                End;
               If (sContentType =  '') And
                  (sFile        <> '') Then
                vObjectName := GetMIMEType(sFile);
               JSONParam.ParamName        := vObjectName;
               JSONParam.ParamFileName    := sFile;
               JSONParam.ParamContentType := sContentType;
               ms.Position := 0;
               If (sFile <> '') Then
                JSONParam.LoadFromStream(ms)
               Else If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                JSONParam.FromJSON(ms.DataString)
               Else
                JSONParam.AsString := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
               DWParams.Add(JSONParam);
               //Fim da correção - ICO
               ms.Free;
               vDecoderHeaderList.Free;
              End;
             mcptText :
              Begin
               {$IFDEF FPC}
               ms := TStringStream.Create('');
               {$ELSE}
               ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
               {$ENDIF}
               ms.Position := 0;
               newdecoder  := Decoder.ReadBody(ms, msgEnd);
               tmp         := Decoder.Headers.Text;
               FreeAndNil(Decoder);
               Decoder     := newdecoder;
               vObjectName := '';
               If Decoder <> Nil Then
                TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
               If pos('dwwelcomemessage', lowercase(tmp)) > 0      Then
                Ctxt.WelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else If pos('dwaccesstag', lowercase(tmp)) > 0      Then
                Ctxt.AccessTag := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else If Pos('dwusecript', lowercase(tmp)) > 0       Then
                vdwCriptKey  := StringToBoolean(ms.DataString)
               Else If pos('datacompression', lowercase(tmp)) > 0  Then
                compresseddata := StringToBoolean(ms.DataString)
               Else If pos('dwencodestrings', lowercase(tmp)) > 0  Then
                encodestrings  := StringToBoolean(ms.DataString)
               Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                dwassyncexec := StringToBoolean(ms.DataString)
               Else If Pos('binaryrequest', lowercase(tmp)) > 0    Then
                vBinaryEvent := StringToBoolean(ms.DataString)
//               Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
//                Begin
//                 vdwConnectionDefs   := TConnectionDefs.Create;
//                 JSONValue           := TJSONValue.Create;
//                 Try
//                  JSONValue.Encoding  := VEncondig;
//                  JSONValue.Encoded  := True;
//                  JSONValue.LoadFromJSON(ms.DataString);
//                  vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
//                 Finally
//                  FreeAndNil(JSONValue);
//                 End;
//                End
               Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                Begin
                 JSONValue           := TJSONValue.Create;
                 Try
                  JSONValue.Encoding := Encoding;
                  JSONValue.Encoded  := True;
                  JSONValue.LoadFromJSON(ms.DataString);
                 Finally
                  FreeAndNil(JSONValue);
                 End;
                End
               Else
                Begin
                 If DWParams = Nil Then
                  Begin
                   DWParams           := TDWParams.Create;
                   DWParams.Encoding  := Encoding;
                  End;
                 If (lowercase(vObjectName) = 'binarydata') then
                  Begin
                   DWParams.LoadFromStream(ms);
                   If Assigned(JSONParam) Then
                    FreeAndNil(JSONParam);
                   {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                   FreeAndNil(ms);
                   If DWParams <> Nil Then
                    Begin
                     If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
                      Ctxt.WelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
                      Ctxt.AccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                     If (DWParams.ItemsString['datacompression']      <> Nil) Then
                      compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                     If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
                      encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                     If (DWParams.ItemsString['dwusecript']           <> Nil) Then
                      vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                     If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
                      dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                     If (DWParams.ItemsString['binaryrequest']        <> Nil) Then
                      vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                     If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
                      vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
                    End;
                   If Assigned(decoder) Then
                    FreeAndNil(decoder);
                   Continue;
                  End;
                 vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                 vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                 JSONParam   := TJSONParam.Create(DWParams.Encoding);
                 JSONParam.ObjectDirection := odIN;
                 If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                  JSONParam.FromJSON(ms.DataString)
                 Else
                  JSONParam.AsString := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                 JSONParam.ParamName := vObjectName;
                 DWParams.Add(JSONParam);
                End;
               {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
               FreeAndNil(ms);
               If Assigned(Newdecoder)  Then
                FreeAndNil(Newdecoder);
              End;
             mcptIgnore :
              Begin
               Try
                If decoder <> Nil Then
                 FreeAndNil(decoder);
                decoder := TIdMessageDecoderMIME.Create(Nil);
                TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
               Finally
               End;
              End;
            {$IFNDEF FPC}
             {$IF Not(DEFINED(OLDINDY))}
             mcptEOF:
              Begin
               FreeAndNil(decoder);
               msgEnd := True
              End;
             {$IFEND}
            {$ELSE}
             mcptEOF:
              Begin
               FreeAndNil(decoder);
               msgEnd := True
              End;
            {$ENDIF}
            End;
           Until (Decoder = Nil) Or (msgEnd);
          Finally
           If Assigned(decoder) then
            FreeAndNil(decoder);
          End;
         End
        Else
         Begin
          If (ARequestInfo.PostStream.Size > 0) And (boundary = '') Then
           Begin
            mb       := TStringStream.Create('');
            Try
             ARequestInfo.PostStream.Position := 0;
             mb.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
             ARequestInfo.PostStream.Position := 0;
             mb.Position  := 0;
//             If vDataRouteList.Count > 0 Then
//              Inc(aParamsCount);
             If Not Assigned(DWParams) Then
              TServerUtils.ParseWebFormsParams (DWParams, ARequestInfo.Params, Encoding
                                                {$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             {Alteração feita por Tiago IStuque - 28/12/2018}
             If Assigned(DWParams.ItemsString['dwReadBodyRaw']) And (DWParams.ItemsString['dwReadBodyRaw'].AsString='1') Then
              TServerUtils.ParseBodyRawToDWParam(mb.DataString, Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else If (Assigned(DWParams.ItemsString['dwReadBodyBin']) And
                     (DWParams.ItemsString['dwReadBodyBin'].AsString='1')) Then
              TServerUtils.ParseBodyBinToDWParam(mb.DataString, Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
             Else If (vBinaryEvent) Then
              Begin
               If (pos('--', mb.DataString) > 0) and (pos('boundary', ARequestInfo.ContentType) > 0) Then
                Begin
                 msgEnd   := False;
                 {$IFNDEF FPC}
                  {$IF (DEFINED(OLDINDY))}
                   boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary');
                  {$ELSE}
                   boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                  {$IFEND}
                 {$ELSE}
                  boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
                 {$ENDIF}
                 startboundary := '--' + boundary;
                 Repeat
                  tmp := ReadLnFromStream(ARequestInfo.PostStream, -1, True);
                 Until tmp = startboundary;
                End;
                Try
                 Repeat
                  decoder := TIdMessageDecoderMIME.Create(nil);
                  TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
                  decoder.SourceStream := ARequestInfo.PostStream;
                  decoder.FreeSourceStream := False;
                  decoder.ReadHeader;
                  Inc(I);
                  Case Decoder.PartType of
                   mcptAttachment:
                    Begin
                     ms := TStringStream.Create('');
                     ms.Position := 0;
                     NewDecoder := Decoder.ReadBody(ms, MsgEnd);
                     vDecoderHeaderList := TStringList.Create;
                     vDecoderHeaderList.Assign(Decoder.Headers);
                     sFile := ExtractFileName(Decoder.FileName);
                     FreeAndNil(Decoder);
                     Decoder := NewDecoder;
                     If Decoder <> Nil Then
                      TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                     If Not Assigned(DWParams) Then
                      Begin
                       If (ARequestInfo.Params.Count = 0) Then
                        Begin
                         DWParams           := TDWParams.Create;
                         DWParams.Encoding  := Encoding;
                        End
                       Else
                        TServerUtils.ParseWebFormsParams (DWParams, ARequestInfo.Params, Encoding
                                                          {$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                      End;
                     JSONParam    := TJSONParam.Create(DWParams.Encoding);
                     JSONParam.ObjectDirection := odIN;
                     vObjectName  := '';
                     sContentType := '';
                     for I := 0 to vDecoderHeaderList.Count - 1 do
                      begin
                       tmp := vDecoderHeaderList.Strings[I];
                       if Pos('; name="', lowercase(tmp)) > 0 then
                        begin
                         vObjectName := Copy(lowercase(tmp),
                                             Pos('; name="', lowercase(tmp)) + length('; name="'),
                                             length(lowercase(tmp)));
                         vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                        end;
                       if Pos('content-type=', lowercase(tmp)) > 0 then
                        begin
                         sContentType := Copy(lowercase(tmp),
                                             Pos('content-type=', lowercase(tmp)) + length('content-type='),
                                             length(lowercase(tmp)));
                        end;
                      end;
                      // Correção de FORM-DATA / FILE criar parametros automaticos: ICO 20-09-2019
                      If (lowercase(vObjectName) = 'binarydata') then
                       Begin
                        DWParams.LoadFromStream(ms);
                        If Assigned(JSONParam) Then
                         FreeAndNil(JSONParam);
                        If (DWParams.ItemsString['dwwelcomemessage']     <> Nil) Then
                         Ctxt.WelcomeMessage       := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                        If (DWParams.ItemsString['dwaccesstag']          <> Nil) Then
                         Ctxt.AccessTag            := DecodeStrings(DWParams.ItemsString['dwaccesstag'].AsString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                        If (DWParams.ItemsString['datacompression']      <> Nil) Then
                         compresseddata        := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
                        If (DWParams.ItemsString['dwencodestrings']      <> Nil) Then
                         encodestrings         := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
                        If (DWParams.ItemsString['dwusecript']           <> Nil) Then
                         vdwCriptKey           := StringToBoolean(DWParams.ItemsString['dwusecript'].AsString);
                        If (DWParams.ItemsString['dwassyncexec']         <> Nil) And (Not (dwassyncexec)) Then
                         dwassyncexec          := StringToBoolean(DWParams.ItemsString['dwassyncexec'].AsString);
                        If (DWParams.ItemsString['binaryrequest']        <> Nil) Then
                         vBinaryEvent          := StringToBoolean(DWParams.ItemsString['binaryrequest'].AsString);
                        If (DWParams.ItemsString['BinaryCompatibleMode'] <> Nil) Then
                         vBinaryCompatibleMode := DWParams.ItemsString['BinaryCompatibleMode'].Value;
//                        if DWParams.ItemsString['dwConnectionDefs'] <> Nil then
//                        begin
//                         if not Assigned(vdwConnectionDefs) then
//                          vdwConnectionDefs := TConnectionDefs.Create;
//                         JSONValue           := TJSONValue.Create;
//                         Try
//                          JSONValue.Encoding := VEncondig;
//                          JSONValue.Encoded  := True;
//                          JSONValue.LoadFromJSON(DWParams.ItemsString['dwConnectionDefs'].ToJSON);
//                          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
//                         Finally
//                          FreeAndNil(JSONValue);
//                         End;
//                        end;
                        If Assigned(vDecoderHeaderList) Then
                         FreeAndNil(vDecoderHeaderList);
                        If Assigned(ms) Then
                         FreeAndNil(ms);
                        FreeAndNil(Decoder);
                        Continue;
                       End
                      Else If (vObjectName <> '') Then
                       Begin
                        JSONParam.ParamName        := vObjectName;
                        tmp := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);//ms.DataString;
                        If Copy(tmp, Length(tmp) -1, 2) = sLineBreak Then
                         Delete(tmp, Length(tmp) -1, 2);
                        If Encoding = esUtf8 Then
                         JSONParam.SetValue(utf8decode(tmp), JSONParam.Encoded)
                        Else
                         JSONParam.SetValue(tmp, JSONParam.Encoded);
                       End
                      Else
                       Begin
                        vObjectName := 'dwfilename';
                        If (sContentType = '') and (sFile <> '') then
                         vObjectName := GetMIMEType(sFile);
                        JSONParam.ParamName        := vObjectName;
                        JSONParam.ParamFileName    := sFile;
                        JSONParam.ParamContentType := sContentType;
                        If Encoding = esUtf8 Then
                         JSONParam.SetValue(utf8decode(ms.DataString), JSONParam.Encoded)
                        Else If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                         JSONParam.FromJSON(ms.DataString)
                        Else
                         JSONParam.SetValue(ms.DataString, JSONParam.Encoded);
                       End;
                      DWParams.Add(JSONParam);
                     FreeAndNil(ms);
                     FreeAndNil(vDecoderHeaderList);
                    End;
                   mcptText :
                    begin
                     {$IFDEF FPC}
                     ms := TStringStream.Create('');
                     {$ELSE}
                     ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
                     {$ENDIF}
                     ms.Position := 0;
                     newdecoder  := Decoder.ReadBody(ms, msgEnd);
                     tmp         := Decoder.Headers.Text;
                     FreeAndNil(Decoder);
                     Decoder     := newdecoder;
                     vObjectName := '';
                     If Decoder <> Nil Then
                      TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                     If pos('dwwelcomemessage', lowercase(tmp)) > 0      Then
                      Ctxt.WelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                     Else If pos('dwaccesstag', lowercase(tmp)) > 0      Then
                      Ctxt.AccessTag := DecodeStrings(ms.DataString{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                     Else If Pos('dwusecript', lowercase(tmp)) > 0       Then
                      vdwCriptKey  := StringToBoolean(ms.DataString)
                     Else If pos('datacompression', lowercase(tmp)) > 0  Then
                      compresseddata := StringToBoolean(ms.DataString)
                     Else If pos('dwencodestrings', lowercase(tmp)) > 0  Then
                      encodestrings  := StringToBoolean(ms.DataString)
                     Else If Pos('binaryrequest', lowercase(tmp)) > 0    Then
                      vBinaryEvent := StringToBoolean(ms.DataString)
                     Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                      dwassyncexec := StringToBoolean(ms.DataString)
//                     Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
//                      Begin
//                       vdwConnectionDefs   := TConnectionDefs.Create;
//                       JSONValue           := TJSONValue.Create;
//                       Try
//                        JSONValue.Encoding  := VEncondig;
//                        JSONValue.Encoded  := True;
//                        JSONValue.LoadFromJSON(ms.DataString);
//                        vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
//                       Finally
//                        FreeAndNil(JSONValue);
//                       End;
//                      End
                     Else If (Pos('dwassyncexec', lowercase(tmp)) > 0) And (Not (dwassyncexec)) Then
                      dwassyncexec := StringToBoolean(ms.DataString)
                     Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                      Begin
                       JSONValue            := TJSONValue.Create;
                       Try
                        JSONValue.Encoding  := Encoding;
                        JSONValue.Encoded   := True;
                        JSONValue.LoadFromJSON(ms.DataString);
                       Finally
                        FreeAndNil(JSONValue);
                       End;
                      End
                     Else
                      Begin
                       If DWParams = Nil Then
                        Begin
                         DWParams           := TDWParams.Create;
                         DWParams.Encoding  := Encoding;
                        End;
                       vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                       vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                       JSONParam   := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ObjectDirection := odIN;
                       If (Pos(Lowercase('{"ObjectType":"toParam", "Direction":"'), lowercase(ms.DataString)) > 0) Then
                        JSONParam.FromJSON(ms.DataString)
                       Else
                        JSONParam.AsString := StringReplace(StringReplace(ms.DataString, sLineBreak, '', [rfReplaceAll]), #13, '', [rfReplaceAll]);
                       JSONParam.ParamName := vObjectName;
                       DWParams.Add(JSONParam);
                      End;
                     {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                     FreeAndNil(ms);
                     FreeAndNil(newdecoder);
                    end;
                   mcptIgnore :
                    Begin
                     Try
                      If decoder <> Nil Then
                       FreeAndNil(decoder);
                     Finally
                     End;
                    End;
                   {$IFNDEF FPC}
                    {$IF Not(DEFINED(OLDINDY))}
                    mcptEOF:
                     Begin
                      FreeAndNil(decoder);
                      msgEnd := True
                     End;
                    {$IFEND}
                   {$ELSE}
                   mcptEOF:
                    Begin
                     FreeAndNil(decoder);
                     msgEnd := True
                    End;
                   {$ENDIF}
                  End;
                 Until (Decoder = Nil) Or (msgEnd);
                Finally
                 If decoder <> nil then
                  FreeAndNil(decoder);
                End;
              End
             Else If (ARequestInfo.Params.Count = 0)
                      {$IFNDEF FPC}
                       {$If Not(DEFINED(OLDINDY))}
                        {$If (CompilerVersion > 23)}
                         And (ARequestInfo.QueryParams.Length = 0)
                        {$IFEND}
                       {$ELSE}
                        And (Length(ARequestInfo.QueryParams) = 0)
                       {$IFEND}
                      {$ELSE}
                       And (ARequestInfo.QueryParams.Length = 0)
                      {$ENDIF}Then
              Begin
               If Encoding = esUtf8 Then
                TServerUtils.ParseBodyRawToDWParam(utf8decode(mb.DataString), Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
               Else
                TServerUtils.ParseBodyRawToDWParam(mb.DataString, Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
              End
             Else
              Begin
               If Encoding = esUtf8 Then
                Begin
                 TServerUtils.ParseDWParamsURL(utf8decode(mb.DataString), Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 if DWParams.ItemsString['undefined'] = nil then
                  TServerUtils.ParseBodyRawToDWParam(utf8decode(mb.DataString), Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                End
               Else
                Begin
                 TServerUtils.ParseDWParamsURL(mb.DataString, Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 if DWParams.ItemsString['undefined'] = nil then
                  TServerUtils.ParseBodyRawToDWParam(mb.DataString, Encoding, DWParams{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                End;
              End;
             {Fim alteração feita por Tiago Istuque - 28/12/2018}
            Finally
             mb.Free;
            End;
           End;
         End;
       End;
     End;
     Try
      AResponseInfo.ContentType   := 'application/json'; //'text';//'application/octet-stream';
      If (Ctxt.URL = '') Or (Ctxt.URL = '/') Then
       Begin
        If DefaultPage.Count > 0 Then
         vReplyString  := DefaultPage.Text
        Else
         vReplyString    := TServerStatusHTMLQX;
        Ctxt.StatusCode  := 200;
        AResponseInfo.ContentType := 'text/html';
       End
      Else
       Begin
        Ctxt.DWParams.CopyFrom(DWParams);
        Ctxt.Method         := RequestType;
        Ctxt.RequestID      := IntToStr(AContext.Binding.PeerPort);
        Ctxt.RemoteIP       := AContext.Binding.PeerIP;
        Ctxt.ConnectionID   := AContext.Binding.Port;
        Ctxt.InContentType  := ARequestInfo.ContentType;
        Ctxt.OutContentType := Ctxt.InContentType;
        Ctxt.UserAgent      := ARequestInfo.UserAgent;
        ExecProcess(Ctxt, AContext);
        JSONStr             := Ctxt.OutContent;
//        For I := 0 To CORS_CustomHeaders.Count -1 Do
//         AResponseInfo.CustomHeaders.AddValue(CORS_CustomHeaders.Names[I], CORS_CustomHeaders.ValueFromIndex[I]);
        For I := 0 To Ctxt.OutHeaders.Count -1 Do
         AResponseInfo.CustomHeaders.AddValue(Ctxt.OutHeaders.Names[I], Ctxt.OutHeaders.ValueFromIndex[I]);
        If Encoding = esUtf8 Then
         AResponseInfo.ContentEncoding       := 'utf-8'
        Else
         AResponseInfo.ContentEncoding       := 'ansi';
        If dwassyncexec Then
         Begin
          AResponseInfo.ResponseNo               := 200;
          vReplyString                           := AssyncCommandMSG;
          {$IFNDEF FPC}
           If compresseddata Then
            mb                                  := TStringStream(ZCompressStreamNew(vReplyString))
           Else
            mb                                  := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
           mb.Position                          := 0;
           AResponseInfo.FreeContentStream      := True;
           AResponseInfo.ContentStream          := mb;
           AResponseInfo.ContentStream.Position := 0;
           AResponseInfo.ContentLength          := mb.Size;
           AResponseInfo.WriteContent;
          {$ELSE}
           If compresseddata Then
            mb                                  := TStringStream(ZCompressStreamNew(vReplyString)) //TStringStream.Create(Utf8Encode(vReplyStringResult))
           Else
            mb                                  := TStringStream.Create(vReplyString);
           mb.Position                          := 0;
           AResponseInfo.FreeContentStream      := True;
           AResponseInfo.ContentStream          := mb;
           AResponseInfo.ContentStream.Position := 0;
           AResponseInfo.ContentLength          := -1;//mb.Size;
           AResponseInfo.WriteContent;
          {$ENDIF}
         End;
       End;
      Try
       If Not dwassyncexec Then
        Begin
         If (Not (vTagReply)) Then
          Begin
           If Encoding = esUtf8 Then
            AResponseInfo.Charset := 'utf-8'
           Else
            AResponseInfo.Charset := 'ansi';
           If Ctxt.OutContentType <> '' Then
            AResponseInfo.ContentType := Ctxt.OutContentType;
           If (Trim(Ctxt.URL) <> '') Then
            Begin
             If Ctxt.JsonMode in [jmDataware, jmUndefined] Then
              Begin
               If Trim(JSONStr) <> '' Then
                Begin
                 If Not(((Pos('{', JSONStr) > 0)   And
                         (Pos('}', JSONStr) > 0))  Or
                        ((Pos('[', JSONStr) > 0)   And
                         (Pos(']', JSONStr) > 0))) Then
                  Begin
                   If Not (Ctxt.WelcomeAccept) And (Ctxt.ErrorMessage <> '') Then
                     JSONStr := escape_chars(Ctxt.ErrorMessage)
                   Else If Not((JSONStr[InitStrPos] = '"')  And
                          (JSONStr[Length(JSONStr)] = '"')) Then
                    JSONStr := '"' + JSONStr + '"';
                  End;
                End;
               If vBinaryEvent Then
                Begin
                 vReplyString    := JSONStr;
                 Ctxt.StatusCode := 200;
                End
               Else
                Begin
                 If Not (Ctxt.WelcomeAccept) And (Ctxt.ErrorMessage <> '') Then
                  vReplyString := escape_chars(Ctxt.ErrorMessage)
                 Else
                  vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
                End;
              End
             Else If Ctxt.JsonMode = jmPureJSON Then
              Begin
               If (Trim(JSONStr) = '') And (Ctxt.WelcomeAccept) Then
                vReplyString := '{}'
               Else If Not (Ctxt.WelcomeAccept) And (Ctxt.ErrorMessage <> '') Then
                Begin
                 If Ctxt.Outcontent <> '' Then
                  Begin
                   AResponseInfo.ContentType := Ctxt.OutContentType;
                   vReplyString := Ctxt.Outcontent;
                  End
                 Else
                  vReplyString := escape_chars(Ctxt.ErrorMessage);
                End
               Else
                vReplyString := JSONStr;
              End;
            End;
           AResponseInfo.ResponseNo                 := Ctxt.StatusCode;
           If compresseddata Then
            Begin
             If vBinaryEvent Then
              Begin
               ms := TStringStream.Create('');
               Try
                DWParams.SaveToStream(ms, tdwpxt_OUT);
                ZCompressStreamD(ms, mb2);
               Finally
                FreeAndNil(ms);
               End;
              End
             Else
              mb2                                   := TStringStream(ZCompressStreamNew(vReplyString));
             If Ctxt.StatusCode <> 200 Then
              Begin
               If Assigned(mb2) Then
                FreeAndNil(mb2);
               AResponseInfo.ResponseText           := escape_chars(vReplyString);
              End
             Else
              Begin
               AResponseInfo.FreeContentStream      := True;
               mb2.Position := 0;
               AResponseInfo.ContentStream          := mb2; //mb;
              End;
             If Assigned(AResponseInfo.ContentStream) Then
              Begin
               AResponseInfo.ContentStream.Position := 0;
               AResponseInfo.ContentLength          := AResponseInfo.ContentStream.Size;
              End
             Else
              AResponseInfo.ContentLength           := 0;
            End
           Else
            Begin
             {$IFNDEF FPC}
              {$IF CompilerVersion > 21}
               If vBinaryEvent Then
                Begin
                 mb := TStringStream.Create('');
                 Try
                  DWParams.SaveToStream(mb, tdwpxt_OUT);
                 Finally
                 End;
                End
               Else
                Begin
                 If Ctxt.OutContentStream.Size > 0 Then
                  Begin
                   mb                               := TStringStream.Create(''{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                   mb.CopyFrom(Ctxt.OutContentStream, Ctxt.OutContentStream.Size);
                  End
                 Else
                  mb                                := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                End;
               mb.Position                          := 0;
               AResponseInfo.FreeContentStream      := True;
               AResponseInfo.ContentStream          := mb;
               AResponseInfo.ContentStream.Position := 0;
               AResponseInfo.ContentLength          := mb.Size;
              {$ELSE}
               If vBinaryEvent Then
                Begin
                 mb := TStringStream.Create('');
                 Try
                  DWParams.SaveToStream(mb, tdwpxt_OUT);
                 Finally
                 End;
                 AResponseInfo.FreeContentStream      := True;
                 AResponseInfo.ContentStream          := mb;
                 AResponseInfo.ContentStream.Position := 0;
                 AResponseInfo.ContentLength          := mb.Size;
                End
               Else
                Begin
                 If Ctxt.OutContentStream.Size > 0 Then
                  Begin
                   mb                                   := TStringStream.Create(''{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                   mb.CopyFrom(Ctxt.OutContentStream, Ctxt.OutContentStream.Size);
                   AResponseInfo.FreeContentStream      := True;
                   AResponseInfo.ContentStream          := mb;
                   AResponseInfo.ContentStream.Position := 0;
                   AResponseInfo.ContentLength          := mb.Size;
                  End
                 Else
                  Begin
                   AResponseInfo.ContentLength          := -1;
                   AResponseInfo.ContentText            := vReplyString;
                   AResponseInfo.WriteHeader;
                  End;
                End;
              {$IFEND}
             {$ELSE}
              If vBinaryEvent Then
               Begin
                mb := TStringStream.Create('');
                Try
                 DWParams.SaveToStream(mb, tdwpxt_OUT);
                Finally
                End;
                AResponseInfo.FreeContentStream       := True;
                AResponseInfo.ContentStream           := mb;
                AResponseInfo.ContentStream.Position  := 0;
                AResponseInfo.ContentLength           := mb.Size;
               End
              Else
               Begin
                If Ctxt.OutContentStream.Size > 0 Then
                 Begin
                  mb                               := TStringStream.Create(''{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                  mb.CopyFrom(Ctxt.OutContentStream, Ctxt.OutContentStream.Size);
                 End
                Else
                 Begin
                  If VEncondig = esUtf8 Then
                   mb                                   := TStringStream.Create(Utf8Encode(vReplyString))
                  Else
                   mb                                   := TStringStream.Create(vReplyString);
                 End;  
                mb.Position                           := 0;
                AResponseInfo.FreeContentStream       := True;
                AResponseInfo.ContentStream           := mb;
                AResponseInfo.ContentStream.Position  := 0;
                AResponseInfo.ContentLength           := mb.Size;
                AResponseInfo.WriteHeader;
               End;
             {$ENDIF}
            End;
           If Not AResponseInfo.HeaderHasBeenWritten Then
            If AResponseInfo.CustomHeaders.Count > 0 Then
             AResponseInfo.WriteHeader;
           If Not (vBinaryEvent) Then
            If (Assigned(AResponseInfo.ContentStream)) Then
             If AResponseInfo.ContentStream.size > 0   Then
              AResponseInfo.WriteContent;
          End;
        End;
      Finally
//        FreeAndNil(mb);
      End;
      If Assigned(vLastResponse) Then
       Begin
        Try
         vLastResponse(vReplyString);
        Finally
        End;
       End;
     Finally
     End;
   End;
 Finally
  DestroyComponents;
 End;
End;

Procedure TRESTDWServerQXID.aCommandOther(AContext      : TIdContext;
                                          ARequestInfo  : TIdHTTPRequestInfo;
                                          AResponseInfo : TIdHTTPResponseInfo);
Begin
 aCommandGet(AContext, ARequestInfo, AResponseInfo);
End;

Procedure TRESTDWServerQXID.Bind(Port        : Integer = 9092;
                                 ConsoleMode : Boolean = True);
Begin
 Inherited;
 vServicePort := Port;
 vConsoleMode := ConsoleMode;
 SetActive(True);
End;

Constructor TRESTDWServerQXID.Create(AOwner: TComponent);
Begin
 Inherited;
 HTTPServer                             := TIdHTTPServer.Create(Nil);
 lHandler                               := TIdServerIOHandlerSSLOpenSSL.Create;
 {$IFDEF FPC}
 HTTPServer.OnQuerySSLPort              := @IdHTTPServerQuerySSLPort;
 HTTPServer.OnCommandGet                := @aCommandGet;
 HTTPServer.OnCommandOther              := @aCommandOther;
 HTTPServer.OnConnect                   := @CustomOnConnect;
 HTTPServer.OnCreatePostStream          := @CreatePostStream;
 HTTPServer.OnParseAuthentication       := @OnParseAuthentication;
 vDatabaseCharSet                       := csUndefined;
 {$ELSE}
 HTTPServer.OnQuerySSLPort              := IdHTTPServerQuerySSLPort;
 HTTPServer.OnCommandGet                := aCommandGet;
 HTTPServer.OnCommandOther              := aCommandOther;
 HTTPServer.OnConnect                   := CustomOnConnect;
 HTTPServer.OnCreatePostStream          := CreatePostStream;
 HTTPServer.OnParseAuthentication       := OnParseAuthentication;
 {$ENDIF}
 vActive                                := False;
 vServicePort                           := 9092;
 vForceWelcomeAccess                    := False;
 vConsoleMode                           := False;
 vASSLRootCertFile                      := '';
 HTTPServer.MaxConnections              := -1;
End;

Destructor TRESTDWServerQXID.Destroy;
Begin
 HTTPServer.Active := False;
 FreeAndNil(lHandler);
 FreeAndNil(HTTPServer);
 Inherited;
End;

Function  TRESTDWServerQXID.SSLVerifyPeer (Certificate : TIdX509; AOk : Boolean; ADepth, AError : Integer) : Boolean;

Begin
 If ADepth = 0 Then
  Result := AOk
 Else
  Result := True;
End;

Procedure TRESTDWServerQXID.GetSSLPassWord(var Password: {$IFNDEF FPC}{$IF (DEFINED(OLDINDY))}
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

Procedure TRESTDWServerQXID.SetActive      (Value  : Boolean);
Begin
 If Assigned(HTTPServer) Then
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
        HTTPServer.IOHandler := lHandler;
       End
      Else
       HTTPServer.IOHandler  := Nil;
      If HTTPServer.Bindings.Count > 0 Then
       HTTPServer.Bindings.Clear;
      HTTPServer.Bindings.DefaultPort := vServicePort;
      HTTPServer.DefaultPort          := vServicePort;
      HTTPServer.Active               := True;
     Except
      On E : Exception do
       Begin
        Raise Exception.Create(PChar(E.Message));
       End;
     End;
    End
   Else If Not(Value) Then
    HTTPServer.Active := False;
   vActive := HTTPServer.Active;
  End;
 If vConsoleMode Then
  Begin
   WriteLn('Start REST Dataware QuickX Server');
   WriteLn('Listem : ' + IntToStr(vServicePort));
   Repeat
    Sleep(1);
   Until Not vActive;
  End;
End;

end.
