unit uRESTDWShellServicesLazarus;

{$I ..\..\..\Source\Includes\uRESTDWPlataform.inc}

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
   SysUtils, Classes, Db, HTTPDefs, LConvEncoding, Variants, uRESTDWComponentEvents, uRESTDWBasicTypes, uRESTDWJSONObject,
   uRESTDWBasic, uRESTDWBasicDB, uRESTDWParams, uRESTDWMassiveBuffer, uRESTDWBasicClass, uRESTDWComponentBase, uRESTDWTools;

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
  Procedure Command                   (ARequest               : TRequest;
                                       AResponse              : TResponse;
                                       Var Handled            : Boolean);
  Constructor Create                (AOwner                   : TComponent);Override;
  Destructor  Destroy;
 Published
End;

Implementation

Uses uRESTDWJSONInterface;

Procedure TRESTDWShellService.Command(ARequest    : TRequest;
                                      AResponse   : TResponse;
                                      Var Handled : Boolean);
Var
 sCharSet,
 vToken,
 ErrorMessage,
 vAuthRealm,
 vContentType,
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
  AResponse.Code                   := StatusCode;
  mb                               := TStringStream.Create(ErrorMessage{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
  mb.Position                      := 0;
  AResponse.FreeContentStream      := True;
  AResponse.ContentStream          := mb;
  AResponse.ContentStream.Position := 0;
  AResponse.ContentLength          := mb.Size;
  Handled := True;
  AResponse.SendResponse;
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(vResponseHeader) Then
   FreeAndNil(vResponseHeader);
  If Assigned(vStream) Then
   FreeAndNil(vStream);
 End;
 Procedure Redirect(AURL : String);
 Begin
  If Trim(aUrl) <> '' Then
   AResponse.SendRedirect(AUrl);
 End;
Begin
 ResultStream    := TStringStream.Create('');
 vResponseHeader := TStringList.Create;
 vResponseString := '';
 vStream         := Nil;
 vRedirect      := TRedirect(@Redirect);
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
  vAuthRealm := '';//AResponse.Realm;
  vToken     := ARequest.Authorization;
  //ARequest.Connection
  vStream    := TMemoryStream.Create;
  If (Trim(ARequest.Content) <> '') Then
   Begin
    If vStream = Nil Then
     vStream := TStringStream.Create(ARequest.Content);
    vStream.Position := 0;
   End;
  vStream.Position := 0;
  vContentType     := ARequest.ContentType;
  If CommandExec  (TComponent(AResponse),
                   RemoveBackslashCommands(ARequest.PathInfo),
                   ARequest.Method + ' ' + ARequest.{$IFNDEF FPC}{$IF CompilerVersion < 21}PathInfo
                                                        {$ELSE}RawPathInfo
                                                        {$IFEND}
                                           {$ELSE}
                                            PathInfo
                                           {$ENDIF},
                   vContentType,
                   ARequest.{$IFNDEF FPC}{$IF CompilerVersion < 21}RemoteAddr
                                          {$ELSE}RemoteIP
                                          {$IFEND}
                            {$ELSE}
                             RemoteAddr
                            {$ENDIF},
                   ARequest.UserAgent,
                   '',
                   '',
                   vToken,
                   vResponseHeader,
                   -1,
                   ARequest.CustomHeaders,
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
    //AResponse.Realm   := vAuthRealm;
    AResponse.ContentType := vContentType;
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
    AResponse.Code               := StatusCode;
    If (vResponseString <> '') Or
       (ErrorMessage    <> '') Then
     Begin
      If Assigned(ResultStream) Then
       FreeAndNil(ResultStream);
      If (vResponseString <> '') Then
       ResultStream := TStringStream.Create(vResponseString)
      Else
       ResultStream := TStringStream.Create(ErrorMessage);
     End;
    AResponse.ContentStream          := ResultStream;
    AResponse.ContentStream.Position := 0;
    AResponse.ContentLength          := ResultStream.Size;
    AResponse.FreeContentStream      := True;
    For I := 0 To vResponseHeader.Count -1 Do
     AResponse.CustomHeaders.AddPair(vResponseHeader.Names [I],
                                     vResponseHeader.Values[vResponseHeader.Names[I]]);
    AResponse.SendResponse;
    Handled := True;
   End
  Else //Tratamento de Erros.
   Begin
    //AResponse.Realm := vAuthRealm;
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
   AResponse.Code    := StatusCode;
   If ErrorMessage <> '' Then
    Begin
     If Assigned(ResultStream) Then
      FreeAndNil(ResultStream);
     ResultStream := TStringStream.Create(ErrorMessage);
     AResponse.ContentStream          := ResultStream;
     AResponse.ContentStream.Position := 0;
     AResponse.ContentLength          := ResultStream.Size;
     AResponse.FreeContentStream      := True;
     AResponse.SendResponse;
     Handled := True;
    End;
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
 {$IFNDEF FPC}
 Inherited
 {$ENDIF}
End;

End.
