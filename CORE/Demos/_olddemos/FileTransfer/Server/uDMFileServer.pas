unit uDMFileServer;

interface

uses
  System.SysUtils, System.Classes, Winapi.ShellAPI, uDWAbout, uRESTDWServerEvents, uDWJSONObject, uDWDatamodule;

type
  TdmFileServer = class(TServerMethodDataModule)
    dwSEArquivos: TDWServerEvents;
    procedure dwSEArquivosEventsFileListReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure dwSEArquivosEventsSendReplicationFileReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure dwSEArquivosEventsDownloadFileReplyEvent(var Params: TDWParams;
      var Result: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmFileServer: TdmFileServer;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uPrincipal;

{$R *.dfm}

procedure TdmFileServer.dwSEArquivosEventsSendReplicationFileReplyEvent(
  var Params: TDWParams; var Result: string);
Var
 vArquivo, vDiretorio: String;
 JSONValue    : TJSONValue;
 vFileIn,
 vFile        : TMemoryStream;
 Procedure DelFilesFromDir(Directory, FileMask : String; Const DelSubDirs: Boolean = False);
 Var
  SourceLst: string;
  FOS: TSHFileOpStruct;
 Begin
  FillChar(FOS, SizeOf(FOS), 0);
  FOS.Wnd   := 0;
  FOS.wFunc := FO_DELETE;
  SourceLst := IncludeTrailingPathDelimiter(Directory) + FileMask + #0;
  FOS.pFrom := PChar(SourceLst);
  If Not DelSubDirs Then
   FOS.fFlags := FOS.fFlags OR FOF_FILESONLY;
  // Remove the next line if you want a confirmation dialog box
  FOS.fFlags := FOS.fFlags OR FOF_NOCONFIRMATION;
  // Add the next line for a "silent operation" (no progress box)
  // FOS.fFlags := FOS.fFlags OR FOF_SILENT;
  SHFileOperation(FOS);
 End;
Begin
 If (Params.ItemsString['Arquivo']     <> Nil) Then
  Begin
   vDiretorio := '';
   If (Params.ItemsString['Diretorio'] <> Nil) Then
   begin
     if Params.ItemsString['Diretorio'].AsString <> '' then
     begin
       vDiretorio := IncludeTrailingPathDelimiter(Params.ItemsString['Diretorio'].AsString);
       ForceDirectories(fServer.DirName + vDiretorio);
     end;
   end;
   JSONValue          := TJSONValue.Create;
   JSONValue.Encoding := Encoding;
   vArquivo           := fServer.DirName + vDiretorio + Trim(ExtractFileName(Params.ItemsString['Arquivo'].AsString));
   If FileExists(vArquivo) Then
    DeleteFile(vArquivo);
   vFileIn            := TMemoryStream.Create;
   Params.ItemsString['FileSend'].SaveToStream(vFileIn);
   Try
    vFileIn.Position   := 0;
    vFileIn.SaveToFile(vArquivo);
    fServer.LoadLocalFiles;
   Finally
    If Params.ItemsString['Result'] <> Nil Then
     Params.ItemsString['Result'].AsBoolean := (vFileIn.Size > 0);
    vFileIn.Clear;
    vFileIn.Free;
   End;
  End;
End;

procedure TdmFileServer.dwSEArquivosEventsDownloadFileReplyEvent(
  var Params: TDWParams; var Result: string);
Var
 vFile        : TMemoryStream;
 vArquivo     : String;
 vFileExport  : TStringStream;
Begin
 If (Params.ItemsString['Arquivo']     <> Nil) Then
  Begin
   vArquivo              := fServer.DirName + Trim(Params.ItemsString['Arquivo'].AsString);
   If (vArquivo     <> '') Then
    Begin
     Try
      If FileExists(vArquivo) Then
       Begin
        vFile := TMemoryStream.Create;
        Try
         vFile.LoadFromFile(vArquivo);
         vFile.Position  := 0;
        Except

        End;
        Params.ItemsString['result'].LoadFromStream(vFile);
       End;
     Finally
      FreeAndNil(vFile);
     End;
    End;
  End;
End;

procedure TdmFileServer.dwSEArquivosEventsFileListReplyEvent(
  var Params: TDWParams; var Result: string);
Var
 vArquivo    : String;
 vFileExport : TStringStream;
 List        : TStringList;
Begin
 List               := TStringList.Create;
 GetFilesServer(List);
 Try
  vFileExport       := TStringStream.Create(List.Text);
  vFileExport.Position := 0;
  Params.ItemsString['result'].LoadFromStream(vFileExport);
 Finally
  FreeAndNil(vFileExport);
  FreeAndNil(List);
 End;
End;

end.
