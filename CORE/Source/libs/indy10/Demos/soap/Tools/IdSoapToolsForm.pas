{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16680: IdSoapToolsForm.pas 
{
{   Rev 1.0    25/2/2003 14:02:18  GGrieve
}
{
Version History:
  27-Aug 2002   Grahame Grieve                  Move some code out to ToolsUtils for Linux availability
  26-Aug 2002   Andrew Cumming                  Fixed ShellExec bug and added hint to Execute
  25-Aug 2002   Grahame Grieve                  Remove wordwrap
  22-Aug 2002   Grahame Grieve                  Set Current Directory when reopening a file
  06-Aug 2002   Grahame Grieve                  First implemented
}

unit IdSoapToolsForm;

interface

uses Windows, Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, StdActns,
  IdSoapWsdl, IniFiles, ActnList, ToolWin, Registry;

type
  TIndySoapToolsForm = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ActionList1: TActionList;
    FileNewBlank1: TAction;
    FileOpen1: TAction;
    FileSave1: TAction;
    FileSaveAs1: TAction;
    FileSend1: TAction;
    FileExit1: TAction;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    HelpAbout1: TAction;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    N1: TMenuItem;
    FileSendItem: TMenuItem;
    N2: TMenuItem;
    FileExitItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    FileNewWSDL: TAction;
    FileNewITI: TAction;
    New1: TMenuItem;
    ITIBuilder1: TMenuItem;
    WSDLParser1: TMenuItem;
    Execute1: TAction;
    Tools1: TMenuItem;
    Execute2: TMenuItem;
    Reopen1: TMenuItem;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    Timer1: TTimer;
    Memo1: TMemo;
    procedure FileNewBlank1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileSaveAs1Execute(Sender: TObject);
    procedure FileSend1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileNewITIExecute(Sender: TObject);
    procedure FileNewWSDLExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Execute1Execute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FFileName: String;
    FRegistry : TRegistry;
    function CheckSave : boolean;
    procedure Execute(AFileName : string);
    procedure AddMRU;
    procedure DeleteMRU;
    procedure LoadMRUMenu;
    procedure ReOpenClick(ASender : TObject);
  public
    { Public declarations }
  end;

var
  IndySoapToolsForm: TIndySoapToolsForm;

implementation

uses
  IdGlobal,
  IdHTTP,
  IdSoapAbout,
  IdSoapITIBuilder,
  IdSoapToolsUtils,
  IdSoapUtilities,
  IdSoapWsdlPascal,
  IdSoapWsdlXML,
  IdStrings,
  Mapi,
  ShellAPI,
  SysUtils;

{$R *.DFM}

resourcestring
  SUntitled  = 'Untitled';
  SOverwrite = 'OK to overwrite %s';
  SSendError = 'Error sending mail';

procedure TIndySoapToolsForm.FileNewBlank1Execute(Sender: TObject);
begin
  if CheckSave then
    begin
    AddMRU;
    FFileName := SUntitled;
    Caption := 'IndySoap Tools - '+FFileName;
    memo1.Lines.Clear;
    memo1.Modified := False;
    end;
end;

procedure TIndySoapToolsForm.FileOpen1Execute(Sender: TObject);
begin
  if CheckSave and OpenDialog.Execute then
  begin
    AddMRU;
    memo1.Lines.Clear;
    memo1.Lines.LoadFromFile(OpenDialog.FileName);
    FFileName := OpenDialog.FileName;
    Caption := 'IndySoap Tools - '+FFileName;
    DeleteMRU;
    memo1.SetFocus;
    memo1.Modified := False;
  end;
end;

procedure TIndySoapToolsForm.FileSave1Execute(Sender: TObject);
begin
  if FFileName = SUntitled then
    FileSaveAs1Execute(Sender)
  else
  begin
    memo1.Lines.SaveToFile(FFileName);
    memo1.Modified := False;
  end;
end;

procedure TIndySoapToolsForm.FileSaveAs1Execute(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    if FileExists(SaveDialog.FileName) then
      if MessageDlg(Format(SOverwrite, [SaveDialog.FileName]),
        mtConfirmation, mbYesNoCancel, 0) <> idYes then Exit;
    memo1.Lines.SaveToFile(SaveDialog.FileName);
    AddMRU;
    FFileName := SaveDialog.FileName;
    DeleteMRU;
    Caption := 'IndySoap Tools - '+FFileName;
    memo1.Modified := False;
  end;
end;

procedure TIndySoapToolsForm.FileSend1Execute(Sender: TObject);
var
  MapiMessage: TMapiMessage;
  MError: Cardinal;
begin
  with MapiMessage do
  begin
    ulReserved := 0;
    lpszSubject := nil;
    lpszNoteText := PChar(memo1.Lines.Text);
    lpszMessageType := nil;
    lpszDateReceived := nil;
    lpszConversationID := nil;
    flFlags := 0;
    lpOriginator := nil;
    nRecipCount := 0;
    lpRecips := nil;
    nFileCount := 0;
    lpFiles := nil;
  end;

  MError := MapiSendMail(0, 0, MapiMessage,
    MAPI_DIALOG or MAPI_LOGON_UI or MAPI_NEW_SESSION, 0);
  if MError <> 0 then MessageDlg(SSendError, mtError, [mbOK], 0);
end;

procedure TIndySoapToolsForm.FileExit1Execute(Sender: TObject);
begin
  if CheckSave then
    begin
    Close;
    end;
end;

procedure TIndySoapToolsForm.HelpAbout1Execute(Sender: TObject);
begin
  IndySoapToolsAbout.ShowModal;
end;

procedure TIndySoapToolsForm.FileNewITIExecute(Sender: TObject);
begin
  if CheckSave then
    begin
    AddMRU;
    FFileName := SUntitled;
    Caption := 'IndySoap Tools - '+FFileName;
    memo1.Lines.Clear;
    memo1.Lines.text := EXAMPLE_ITI_CONFIG;
    memo1.Modified := False;
    end;
end;

procedure TIndySoapToolsForm.FileNewWSDLExecute(Sender: TObject);
begin
  if CheckSave then
    begin
    AddMRU;
    FFileName := SUntitled;
    Caption := 'IndySoap Tools - '+FFileName;
    memo1.Lines.Clear;
    memo1.Lines.text := EXAMPLE_WSDL_CONFIG;
    memo1.Modified := False;
    end;
end;

procedure TIndySoapToolsForm.FormCreate(Sender: TObject);
begin
  FFileName := SUntitled;
  FRegistry := TRegistry.create;
  FRegistry.OpenKey('\Software\IndySoap\Tools\MRU', true);
  LoadMRUMenu;
  FileNewBlank1Execute(self);
end;

function TIndySoapToolsForm.CheckSave: boolean;
begin
  result := true;
  if memo1.Modified then
    begin
    case MessageDlg('File '+FFileName+' has changed. Do you want to save?', mtConfirmation, mbYesNoCancel, 0) of
      mrYes    : FileSave1Execute(self);
      mrCancel : result := false;
    end;
  end;
end;

procedure TIndySoapToolsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CheckSave;
  AddMRU;
end;

procedure TIndySoapToolsForm.Execute1Execute(Sender: TObject);
begin
  if CheckSave then
    begin
    Execute(FFileName);
    end;
end;

procedure TIndySoapToolsForm.AddMRU;
var
  LList : TStringList;
begin
  if FFileName <> SUntitled then
    begin
    LList := TStringList.create;
    try
      FRegistry.GetValueNames(LList);
      if LList.count > 20 then
        begin
        FRegistry.DeleteValue(LList[0]);
        LList.delete(0);
        end;
      FRegistry.WriteString(FFileName, '');
    finally
      FreeAndNil(LList);
    end;
    LoadMRUMenu;
    end;
end;

type
  TNamedMenuItem = Class (TMenuItem)
  private
    FFileName : string;
  end;

procedure TIndySoapToolsForm.LoadMRUMenu;
var
  LList : TStringList;
  i : integer;
  LItem : TNamedMenuItem;
begin
  LList := TStringList.create;
  try
    FRegistry.GetValueNames(LList);
    Reopen1.Clear;
    for i := LList.count - 1 downto 0 do
      begin
      LItem := TNamedMenuItem.create(self);
      LItem.Caption := LList[i];
      LItem.FFileName := LList[i];
      LItem.OnClick := ReOpenClick;
      Reopen1.Add(LItem);
      end;
  finally
    FreeAndNil(LList);
  end;
  Reopen1.enabled := Reopen1.Count > 0;
end;

procedure TIndySoapToolsForm.ReOpenClick(ASender: TObject);
var
  LFileName : string;
begin
  if CheckSave then
  begin
    LFileName := (ASender as TNamedMenuItem).FFileName;
    AddMRU;
    memo1.Lines.Clear;
    memo1.Lines.LoadFromFile(LFileName);
    FFileName := LFileName;
    SetCurrentDir(ExtractFilePath(FFileName));
    Caption := 'IndySoap Tools - '+FFileName;
    DeleteMRU;
    memo1.SetFocus;
    memo1.Modified := False;
  end;
end;

procedure TIndySoapToolsForm.DeleteMRU;
var
  LList : TStringList;
begin
  if FFileName <> SUntitled then
    begin
    LList := TStringList.create;
    try
      if FRegistry.ValueExists(FFileName) then
        begin
        FRegistry.DeleteValue(FFileName);
        LoadMRUMenu;
        end;
    finally
      FreeAndNil(LList);
    end;
    LoadMRUMenu;
    end;
end;


procedure TIndySoapToolsForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FRegistry);
end;

procedure TIndySoapToolsForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if (ParamStr(1) <> '') then
    begin
    if FileExists(ParamStr(1)) then
      begin
      FFileName := ParamStr(1);
      memo1.Lines.Clear;
      memo1.Lines.LoadFromFile(FFileName);
      Caption := 'IndySoap Tools - '+FFileName;
      SetCurrentDir(ExtractFilePath(FFileName));
      DeleteMRU;
      memo1.SetFocus;
      memo1.Modified := False;
      if lowercase(Paramstr(2)) = '-g' then
        begin
        Execute(FFileName);
        Close;
        end;
      end
    else
      begin
      MessageDlg('File '+ParamStr(1)+' not found', mtError, [mbOK], 0);
      end
    end;
end;

procedure TIndySoapToolsForm.Execute(AFileName : string);
var
  LOldCursor: TCursor;
begin
  LOldCursor := Screen.Cursor;
  try
    ExecuteScript(AFileName);
  finally
    Screen.Cursor := LOldCursor;
  end;
end;


end.
