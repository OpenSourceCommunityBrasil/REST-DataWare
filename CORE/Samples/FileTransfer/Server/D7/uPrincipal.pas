unit uPrincipal;

interface

uses
  Windows, Forms, uRESTDWBase, pngimage, SMDWCore, StdCtrls, Controls, ExtCtrls, acPNG,
  SysUtils, Classes;

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
Var
 SRec : TSearchRec;
 Res  : Integer;
Begin
 If Not Assigned(List) Then
  Begin
   Result := False;
   Exit;
  End;
 Res := FindFirst(IncludeTrailingPathDelimiter(StartDir) + '*.*', faAnyfile, SRec);
 If Res = 0 Then
  Begin
   Try
    While res = 0 do
     Begin
      If (SRec.Attr And faDirectory <> faDirectory) Then
       List.Add(SRec.Name);
      Res := FindNext(SRec);
     End;
   Finally
    FindClose(SRec)
   End;
  End;
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
