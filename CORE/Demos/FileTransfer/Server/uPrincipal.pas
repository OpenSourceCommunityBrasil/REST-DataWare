unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRESTDWBase, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, SMDWCore;

type
  TfServer = class(TForm)
    rspServerFiles: TRESTServicePooler;
    lbLocalFiles: TListBox;
    Image1: TImage;
    cbEncode: TCheckBox;
    edPasswordDW: TEdit;
    Label3: TLabel;
    Bevel1: TBevel;
    Label7: TLabel;
    edUserNameDW: TEdit;
    Label2: TLabel;
    edPortaDW: TEdit;
    Label4: TLabel;
    ButtonStart: TButton;
    Label13: TLabel;
    Bevel2: TBevel;
    cbPoolerState: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
   DirName : String;
   Procedure LoadLocalFiles;
  end;

 Function GetFilesServer(Const List : TStrings) : Boolean;

var
  fServer: TfServer;
  StartDir : String;

implementation

{$R *.dfm}

Function GetFilesServer(Const List : TStrings) : Boolean;
  procedure ScanFolder(const Path: String; List: TStrings);
  var
    sPath: string;
    rec : TSearchRec;
  begin
    sPath := IncludeTrailingPathDelimiter(Path);
    if FindFirst(sPath + '*.*', faAnyFile, rec) = 0 then
    begin
      repeat
        if (rec.Attr and faDirectory) <> 0 then
        begin
          if (rec.Name <> '.') and (rec.Name <> '..') then
            ScanFolder(IncludeTrailingPathDelimiter(sPath + rec.Name), List);
        end
        else
        begin
          if pos(StartDir, Path) > 0 then
            List.Add(copy(Path, length(StartDir) + 1, length(path)) + rec.Name)
          else
            List.Add(Path + rec.Name);
        end;
      until FindNext(rec) <> 0;
      FindClose(rec);
    end;
  end;
Begin
 If Not Assigned(List) Then
  Begin
    Result := False;
    Exit;
  end;
  ScanFolder(StartDir, List);
  Result := (List.Count > 0);
End;

Procedure TfServer.LoadLocalFiles;
Var
 List    : TStringList;
 I       : Integer;
Begin
 lbLocalFiles.Clear;
 List     := TStringList.Create;
 DirName  := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
             IncludeTrailingPathDelimiter('filelist');
 StartDir := DirName;
 If Not DirectoryExists(DirName) Then
  ForceDirectories(DirName);
  If GetFilesServer(List) Then
  Begin
   For I := 0 To List.Count -1 Do
    lbLocalFiles.AddItem(List[I], Nil);
  End;
 List.Free;
End;

procedure TfServer.ButtonStartClick(Sender: TObject);
begin
 If Not rspServerFiles.Active Then
  Begin
   rspServerFiles.ServerParams.HasAuthentication := True;
   rspServerFiles.ServerParams.UserName := edUserNameDW.Text;
   rspServerFiles.ServerParams.Password := edPasswordDW.Text;
   rspServerFiles.ServicePort := StrToInt(edPortaDW.Text);
   rspServerFiles.Active      := True;
   If Not rspServerFiles.Active Then
    Exit;
   ButtonStart.Caption        := 'Desativar';
   LoadLocalFiles;
  End
 Else
  Begin
   rspServerFiles.Active      := False;
   ButtonStart.Caption        := 'Ativar';
   lbLocalFiles.Clear;
  End;
end;

procedure TfServer.FormCreate(Sender: TObject);
begin
 rspServerFiles.ServerMethodClass := TSMDWCore;
end;

end.
