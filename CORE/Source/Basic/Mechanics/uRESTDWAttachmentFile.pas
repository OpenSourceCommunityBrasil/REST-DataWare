unit uRESTDWAttachmentFile;

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
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
 Classes,
 uRESTDWAttachment, uRESTDWMessageParts, uRESTDWTools, uRESTDWMimeTypes;

 Type
  TRESTDWAttachmentFile = Class(TRESTDWAttachment)
 Protected
  FTempFileStream: TFileStream;
  FStoredPathName: String;
  FFileIsTempFile: Boolean;
  FAttachmentBlocked: Boolean;
 Public
  Constructor Create(aCollection     : TRESTDWMessageParts;
                     Const AFileName : String = ''); Reintroduce;
  Destructor  Destroy; Override;
  Function    OpenLoadStream    : TStream; Override;
  Procedure   CloseLoadStream;             Override;
  Function    PrepareTempStream : TStream; Override;
  Procedure   FinishTempStream;            Override;
  Procedure   SaveToFile(Const aFileName : String); Override;
  Property    FileIsTempFile    : Boolean Read FFileIsTempFile    Write FFileIsTempFile;
  Property    StoredPathName    : String  Read FStoredPathName    Write FStoredPathName;
  Property    AttachmentBlocked : Boolean Read FAttachmentBlocked;
 End;

Implementation

Uses
//  {$IFDEF USE_VCL_POSIX}
//  Posix.Unistd,
//  {$ENDIF}
//  {$IFDEF WINDOWS}
//   Windows,
//  {$ENDIF}
  uRESTDWException,
  uRESTDWMessage,
  uRESTDWConsts,
  uRESTDWBasicTypes,
  SysUtils;

Procedure TRESTDWAttachmentFile.CloseLoadStream;
Begin
 FreeAndNil(FTempFileStream);
End;

Constructor TRESTDWAttachmentFile.Create(aCollection      : TRESTDWMessageParts;
                                         Const AFileName : String = '');
Begin
 Inherited Create(aCollection);
 FFilename := ExtractFileName(AFilename);
 FTempFileStream := nil;
 FStoredPathName := AFileName;
 FFileIsTempFile := False;
 If FFilename <> '' Then
  ContentType := TRESTDWMimeType.GetMIMEType(FFilename);
End;

Destructor TRESTDWAttachmentFile.Destroy;
Begin
 If FileIsTempFile Then
  SysUtils.DeleteFile(StoredPathName);
 Inherited Destroy;
End;

Procedure TRESTDWAttachmentFile.FinishTempStream;
Var
 LMsg : TRESTDWMessage;
Begin
 FreeAndNil(FTempFileStream);
 FAttachmentBlocked := Not FileExists(StoredPathName);
 If FAttachmentBlocked Then
  Begin
   LMsg := TRESTDWMessage(OwnerMessage);
   If Assigned(LMsg) And
     (Not LMsg.ExceptionOnBlockedAttachments) Then
    Exit;
   Raise eRESTDWMessageCannotLoad.CreateFmt(cMessageErrorAttachmentBlocked, [StoredPathName]);
  End;
end;

function TRESTDWAttachmentFile.OpenLoadStream: TStream;
begin
  FTempFileStream := TRESTDWReadFileExclusiveStream.Create(StoredPathName);
  Result := FTempFileStream;
end;

function TRESTDWAttachmentFile.PrepareTempStream: TStream;
var
  LMsg: TRESTDWMessage;
begin
  LMsg := TRESTDWMessage(OwnerMessage);
  if Assigned(LMsg) then begin
    FStoredPathName := MakeTempFilename(LMsg.AttachmentTempDirectory);
  end else begin
    FStoredPathName := MakeTempFilename;
  end;
  FTempFileStream := TRESTDWFileCreateStream.Create(FStoredPathName);
  FFileIsTempFile := True;
  Result := FTempFileStream;
end;

procedure TRESTDWAttachmentFile.SaveToFile(const aFileName: String);
Begin
 If Not CopyFileTo(StoredPathname, aFileName) Then
  Raise eRESTDWException.Create(cMessageErrorSavingAttachment);
End;

Initialization
//  MtW: Shouldn't be neccessary??
//  RegisterClass(TRESTDWAttachmentFile);

End.
