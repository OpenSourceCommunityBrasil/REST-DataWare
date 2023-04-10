unit uRESTDWShellServicesDelphi;

{$I ..\Includes\uRESTDW.inc}

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


interface

Uses
  {$IFNDEF DELPHIXEUP}
    uRESTDWMassiveBuffer,
  {$ENDIF}
  SysUtils, Classes, Db, Variants, HTTPApp, SyncObjs,
  uRESTDWBasic, uRESTDWJSONObject, uRESTDWBasicTypes, uRESTDWComponentEvents,
  uRESTDWAbout, uRESTDWBasicClass, uRESTDWParams, uRESTDWBasicDB,
  uRESTDWTools, uRESTDWConsts;

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
  Procedure Redirect                  (Url                    : String;
                                       AResponse              : TObject);
  Procedure Command                   (ARequest               : TWebRequest;
                                       AResponse              : TWebResponse;
                                       Var Handled            : Boolean);
  Constructor Create                (AOwner                   : TComponent);Override;
  Destructor  Destroy;
 Published
End;

Implementation

Uses uRESTDWJSONInterface;

Procedure TRESTDWShellService.Redirect(Url : String;
                                       AResponse   : TObject);
Begin
 If Trim(Url) <> '' Then
  TWebResponse(AResponse).SendRedirect(Url);
End;

Procedure TRESTDWShellService.Command(ARequest    : TWebRequest;
                                      AResponse   : TWebResponse;
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
 vCORSHeader     : TStrings;
 vRawHeader,
 vResponseHeader : TStringList;
 mb              : TStringStream;
 vStream         : TStream;
 vRedirect       : TRedirect;
 Procedure WriteError;
 Begin
   AResponse.StatusCode             := StatusCode;
   mb                               := TStringStream.Create(ErrorMessage{$IFDEF DELPHIXEUP}, TEncoding.UTF8{$ENDIF});
   mb.Position                      := 0;
   {$IFDEF DELPHIXEUP}
   AResponse.FreeContentStream      := True;
   {$ENDIF}
   AResponse.ContentStream          := mb;
   AResponse.ContentStream.Position := 0;
   AResponse.ContentLength          := mb.Size;
   Handled := True;
   AResponse.SendResponse;
   {$IFNDEF DELPHIXEUP}
   If Assigned(mb) Then
     FreeAndNil(mb);
   {$ENDIF}
 End;
 Procedure DestroyComponents;
 Begin
  If Assigned(vResponseHeader) Then
   FreeAndNil(vResponseHeader);
  If Assigned(vStream) Then
   FreeAndNil(vStream);
  If Assigned(vRawHeader) Then
   FreeAndNil(vRawHeader);
  If Assigned(vCORSHeader) Then
   FreeAndNil(vCORSHeader);
 End;
 Procedure SetReplyCORS;
 Var
  I : Integer;
 Begin
  If CORS Then
   Begin
    If CORS_CustomHeaders.Count > 0 Then
     Begin
      For I := 0 To CORS_CustomHeaders.Count -1 Do
       Begin
        {$IFDEF DELPHI10_1UP}
         AResponse.CustomHeaders.AddPair(CORS_CustomHeaders.Names[I], CORS_CustomHeaders.ValueFromIndex[I]);
        {$ELSE}
         AResponse.CustomHeaders.Add(CORS_CustomHeaders.Names[I] + cNameValueSeparator + CORS_CustomHeaders.ValueFromIndex[I]);
        {$ENDIF}
       End;
     End
    Else
     Begin
      {$IFDEF DELPHI10_1UP}
       AResponse.CustomHeaders.AddPair('Access-Control-Allow-Origin','*');
      {$ELSE}
       AResponse.CustomHeaders.Add('Access-Control-Allow-Origin' + cNameValueSeparator + '*');
      {$ENDIF}
     End;
    If Assigned(vCORSHeader) Then
     Begin
      If vCORSHeader.Count > 0 Then
       Begin
        For I := 0 To vCORSHeader.Count -1 Do
         Begin
          {$IFDEF DELPHI10_1UP}
           AResponse.CustomHeaders.AddPair(vCORSHeader.Names[I], vCORSHeader.ValueFromIndex[I]);
          {$ELSE}
           AResponse.CustomHeaders.Add(vCORSHeader.Names[I] + cNameValueSeparator + vCORSHeader.ValueFromIndex[I]);
          {$ENDIF}
         End;
       End;
     End;
   End;
 End;
Begin
 ResultStream    := TStringStream.Create('');
 vCORSHeader     := TStringList.Create;
 vResponseHeader := TStringList.Create;
 vResponseString := '';
 vStream         := Nil;
 vRedirect       := Redirect;
 {$IFDEF DELPHIXE6UP}
  ARequest.ReadTotalContent;
 {$ENDIF}
 Try
  vAuthRealm := AResponse.Realm;
  vToken     := ARequest.Authorization;
  //ARequest.Connection
  vRawHeader := TStringList.Create;
  If vToken <> '' Then
   vRawHeader.Add('Authorization:' + vToken);
  If ARequest.ContentLength > 0 Then
   Begin
    {$IFDEF DELPHI10_0UP}
     ARequest.ReadTotalContent;
     vStream    := TMemoryStream.Create;
     vStream.Write(TBytes(ARequest.RawContent), Length(ARequest.RawContent));
    {$ELSE}
    If (Trim(ARequest.Content) <> '') Then
     Begin
      If vStream = Nil Then
       vStream := TStringStream.Create(ARequest.Content);
     End;
    {$ENDIF}
   End
  Else
   vStream         := TMemoryStream.Create;
  vStream.Position := 0;
  vContentType     := ARequest.ContentType;
  If CommandExec  (TComponent(AResponse),
                   RemoveBackslashCommands(ARequest.PathInfo),
                   ARequest.Method + ' ' + ARequest.{$IFNDEF DELPHIXEUP}PathInfo{$ELSE}RawPathInfo{$ENDIF},
                   vContentType,
                   ARequest.{$IFNDEF DELPHIXEUP}RemoteAddr{$ELSE}RemoteIP{$ENDIF},
                   ARequest.UserAgent,
                   '',
                   '',
                   vToken,
                   vResponseHeader,
                   -1,
                   vRawHeader,
                   ARequest.QueryFields,
                   ARequest.QueryFields.Text,
                   vStream,
                   vAuthRealm,
                   sCharSet,
                   ErrorMessage,
                   StatusCode,
                   vResponseHeader,
                   vResponseString,
                   ResultStream,
                   vCORSHeader,
                   vRedirect) Then
   Begin
    SetReplyCORS;
    AResponse.Realm       := vAuthRealm;
    AResponse.ContentType := vContentType;
    {$IFDEF DELPHIXEUP}
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
    {$ENDIF}
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
      {$IFDEF DELPHIXEUP}
       AResponse.FreeContentStream     := True;
      {$ENDIF}
     End;
    For I := 0 To vResponseHeader.Count -1 Do
     Begin
       {$IFDEF DELPHI10_1UP}
        AResponse.CustomHeaders.AddPair(vResponseHeader.Names [I],
                                        vResponseHeader.Values[vResponseHeader.Names[I]]);
       {$ELSE}
        AResponse.CustomHeaders.Add(vResponseHeader.Names[I] + cNameValueSeparator
                            + vResponseHeader.Values[vResponseHeader.Names[I]]);
       {$ENDIF}
     End;
    Handled := True;
    AResponse.SendResponse;
    {$IFNDEF DELPHIXEUP}
     If Assigned(ResultStream) Then
      FreeAndNil(ResultStream);
    {$ENDIF}
   End
  Else //Tratamento de Erros.
   Begin
    SetReplyCORS;
    AResponse.Realm := vAuthRealm;
    {$IFDEF DELPHIXEUP}
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
    {$ENDIF}
    AResponse.StatusCode    := StatusCode;
    If AResponse.StatusCode <> 200 Then
     Begin
      If ErrorMessage <> '' Then
       AResponse.ReasonString := ErrorMessage
      Else
       Begin
        AResponse.ReasonString := TStringStream(ResultStream).DataString;
        FreeAndNil(ResultStream);
       End;
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
        (ServerMethodsClass.Components[i].InheritsFrom(TRESTDWPoolerDB)) Then
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
          Begin
           MyIP := TWebRequest(AContext).RemoteAddr;
           If MyIP = '' Then
            MyIP := '127.0.0.1';
          End;
         Break;
        End;
      End;
    End;
  End;
 If MyIP = '' Then
  Raise Exception.Create(cInvalidPoolerName);
End;

End.
