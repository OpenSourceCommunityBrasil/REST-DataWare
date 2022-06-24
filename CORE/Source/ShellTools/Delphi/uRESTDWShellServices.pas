unit uRESTDWShellServices;

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
  {$IF CompilerVersion <= 22}
   SysUtils, Classes, Db, HTTPApp, Variants, EncdDecd, SyncObjs, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWBasicClass, uRESTDWAbout,
  {$ELSE}
   System.SysUtils, System.Classes, Data.Db, Variants, HTTPApp, system.SyncObjs, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWBasicClass, uRESTDWAbout,
   uRESTDWCharset, uRESTDWConsts,
  {$IFEND}uRESTDWTools;

Type
 TRESTDWShellService = Class(TRESTShellServicesBase)
 Private
  Procedure EchoPooler               (ServerMethodsClass      : TComponent;
                                      AContext                : TComponent;
                                      Var Pooler, MyIP        : String;
                                      AccessTag               : String;
                                      Var InvalidTag          : Boolean);Override;
  Property Active;
 Public
  Procedure Command                   (ARequest               : TWebRequest;
                                       AResponse              : TWebResponse;
                                       Var Handled            : Boolean);
  Constructor Create                (AOwner                   : TComponent);Override;
  Destructor  Destroy;
 Published
End;

Implementation

Uses uRESTDWJSONInterface;

Procedure TRESTDWShellService.Command(ARequest    : TWebRequest;
                                      AResponse   : TWebResponse;
                                      Var Handled : Boolean);
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
 vStream         : TStream;
 vRedirect       : TRedirect;
 Procedure WriteError;
 Begin
  AResponse.StatusCode              := StatusCode;
  mb                               := TStringStream.Create(ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
  mb.Position                      := 0;
  AResponse.FreeContentStream      := True;
  AResponse.ContentStream          := mb;
  AResponse.ContentStream.Position := 0;
  AResponse.ContentLength          := mb.Size;
  Handled := True;
  {$IFNDEF FPC}
   AResponse.SendResponse;
  {$ELSE}
   AResponse.SendResponse;
  {$ENDIF}
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(vResponseHeader) Then
   FreeAndNil(vResponseHeader);
  If Assigned(vStream) Then
   FreeAndNil(vStream);
 End;
 Procedure Redirect(Url : String);
 Begin
  If Trim(Url) <> '' Then
   AResponse.SendRedirect(Url);
 End;
Begin
 ResultStream    := TStringStream.Create('');
 vResponseHeader := TStringList.Create;
 vResponseString := '';
 vStream         := Nil;
 @vRedirect      := @Redirect;
 Try
  If CORS Then
   Begin
    If CORS_CustomHeaders.Count > 0 Then
     Begin
      For I := 0 To CORS_CustomHeaders.Count -1 Do
       AResponse.CustomHeaders.AddPair(CORS_CustomHeaders.Names[I], CORS_CustomHeaders.ValueFromIndex[I]);
     End
    Else
     AResponse.CustomHeaders.AddPair('Access-Control-Allow-Origin','*');
   End;
  vAuthRealm := AResponse.Realm;
  vToken     := ARequest.Authorization;
  //ARequest.Connection
  vStream    := TMemoryStream.Create;
  If ARequest.ContentLength > 0 Then
   Begin
    {$IF CompilerVersion > 29}
     ARequest.ReadTotalContent;
    {$IFEND}
    vStream.Write(TBytes(ARequest.RawContent), Length(ARequest.RawContent));
   End;
  vStream.Position := 0;
  If CommandExec  (TComponent(AResponse),
                   RemoveBackslashCommands(ARequest.PathInfo),
                   ARequest.Method + ' ' + ARequest.RawPathInfo,
                   ARequest.ContentType,
                   ARequest.RemoteIP,
                   ARequest.UserAgent,
                   '',
                   '',
                   vToken,
                   vResponseHeader,
                   -1,
                   Nil,
                   ARequest.ContentFields,
                   ARequest.QueryFields.Text,
                   vStream,
                   vAuthRealm,
                   sCharSet,
                   ErrorMessage,
                   StatusCode,
                   vResponseHeader,
                   vResponseString,
                   ResultStream,
                   vRedirect) Then
   Begin
    AResponse.Realm   := vAuthRealm;
    {$if CompilerVersion > 21}
     If (sCharSet <> '') Then
      Begin
       If Pos('utf8', Lowercase(sCharSet)) > 0 Then
        Begin
         If Pos('utf8', lowercase(AResponse.ContentType)) = 0 Then
          AResponse.ContentType := AResponse.ContentType + ';charset=utf-8';
        End
       Else If Pos('ansi', Lowercase(sCharSet)) > 0 Then
        Begin
         If Pos('ansi', lowercase(AResponse.ContentType)) = 0 Then
          AResponse.ContentType := AResponse.ContentType + ';charset=ansi';
        End;
      End;
    {$IFEND}
    AResponse.StatusCode               := StatusCode;
    If (vResponseString <> '') Or
       (ErrorMessage    <> '') Then
     Begin
      If Assigned(ResultStream) Then
       FreeAndNil(ResultStream);
      AResponse.ContentLength          := -1;
      If ErrorMessage <> '' Then
       AResponse.ReasonString          := ErrorMessage
      Else
       AResponse.ReasonString          := vResponseString;
     End
    Else
     Begin
      AResponse.ContentStream          := ResultStream;
      AResponse.ContentStream.Position := 0;
      AResponse.ContentLength          := ResultStream.Size;
      {$IF CompilerVersion > 21}
       AResponse.FreeContentStream      := True;
      {$IFEND}
     End;
    For I := 0 To vResponseHeader.Count -1 Do
     AResponse.CustomHeaders.AddPair(vResponseHeader.Names [I],
                                     vResponseHeader.Values[vResponseHeader.Names[I]]);
//    If vResponseHeader.Count > 0 Then
//     AResponse.HTTPRequest.WriteHeaders()
    Handled := True;
    {$IFNDEF FPC}
     AResponse.SendResponse;
    {$ELSE}
     AResponse.SendResponse;
    {$ENDIF}
   End
  Else //Tratamento de Erros.
   Begin
    AResponse.Realm := vAuthRealm;
    {$if CompilerVersion > 21}
     If (sCharSet <> '') Then
      Begin
       If Pos('utf8', Lowercase(sCharSet)) > 0 Then
        Begin
         If Pos('utf8', lowercase(AResponse.ContentType)) = 0 Then
          AResponse.ContentType := AResponse.ContentType + ';charset=utf-8';
        End
       Else If Pos('ansi', Lowercase(sCharSet)) > 0 Then
        Begin
         If Pos('ansi', lowercase(AResponse.ContentType)) = 0 Then
          AResponse.ContentType := AResponse.ContentType + ';charset=ansi';
        End;
      End;
    {$IFEND}
    AResponse.StatusCode    := StatusCode;
    If ErrorMessage <> '' Then
     AResponse.ReasonString := ErrorMessage;
   End;
 Finally
  DestroyComponents;
 End;
End;

Constructor TRESTDWShellService.Create(AOwner: TComponent);
Begin
 Inherited Create(AOwner);
End;

Destructor TRESTDWShellService.Destroy;
Begin
 Inherited Destroy;
End;

Procedure TRESTDWShellService.EchoPooler(ServerMethodsClass,
                                         AContext             : TComponent;
                                         Var Pooler, MyIP     : String;
                                         AccessTag            : String;
                                         Var InvalidTag       : Boolean);
Begin
 Inherited;

End;

End.
