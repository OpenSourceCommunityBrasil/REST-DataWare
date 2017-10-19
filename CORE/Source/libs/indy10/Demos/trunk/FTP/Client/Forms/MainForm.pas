{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  23026: MainForm.pas 
{
{   Rev 1.3    09/11/2003 3:39:46 PM  Jeremy Darling
{ Completed front end changes and tested against both local and remote windows
{ ftp systems.  Still looking for a Linux box to test against.
}
{
{   Rev 1.2    09/11/2003 3:21:02 PM  Jeremy Darling
{ Completed Log Color customization.
}
{
{   Rev 1.1    09/11/2003 2:12:02 PM  Jeremy Darling
{ Updated some of the site configuration stuff and made it so that you can add,
{ edit and delete sites from your site list.  Also added a Site Name so that
{ you don't have to see the address when selecting a site.
}
{
{   Rev 1.0    09/11/2003 12:49:20 PM  Jeremy Darling
{ Project Added to TC
}
unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, StdCtrls, ComCtrls, ToolWin, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTP,
  Buttons, ExtCtrls, Commctrl, ActnList, ShellAPI, IniFiles, FTPSiteInfo,
  ConfigureApplicationForm, ConfigureSiteForm, ApplicationConfiguration,
  Menus, IdFTPCommon;

type
  TfrmMain = class(TForm)
    FTP: TIdFTP;
    sbMain: TStatusBar;
    ilNormalImages: TImageList;
    ControlBar1: TControlBar;
    ToolBar7: TToolBar;
    btnConnect: TToolButton;
    btnBack: TToolButton;
    btnUpAFolder: TToolButton;
    btnHome: TToolButton;
    ToolBar9: TToolBar;
    Panel5: TPanel;
    cbFTPAddress: TComboBox;
    btnSiteOptions: TToolButton;
    ToolBar10: TToolBar;
    Panel6: TPanel;
    edUserName: TEdit;
    ToolBar11: TToolBar;
    Panel7: TPanel;
    edPassword: TEdit;
    ToolBar12: TToolBar;
    btnNewFolder: TToolButton;
    btnDeleteFolder: TToolButton;
    ToolButton20: TToolButton;
    btnUploadFile: TToolButton;
    btnDownloadFile: TToolButton;
    ToolBar13: TToolBar;
    btnAbout: TToolButton;
    ToolBar14: TToolBar;
    btnViewingStyle: TToolButton;
    Panel8: TPanel;
    edFolder: TEdit;
    btnGo: TBitBtn;
    ActionList1: TActionList;
    actConnectDisconnect: TAction;
    lbStatus: TListBox;
    pbProgress: TProgressBar;
    lbDirectory: TListBox;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    SaveFile: TSaveDialog;
    lvFiles: TListView;
    actChangeDirUP: TAction;
    actHome: TAction;
    actBack: TAction;
    actCreateFolder: TAction;
    actDeleteFileFolder: TAction;
    ToolButton1: TToolButton;
    actDownloadFile: TAction;
    actUploadFile: TAction;
    actAbout: TAction;
    actHelp: TAction;
    actConfigureSite: TAction;
    actConfigureApplication: TAction;
    OpenDialog: TOpenDialog;
    tvFolders: TTreeView;
    puUpload: TPopupMenu;
    puDownload: TPopupMenu;
    Active1: TMenuItem;
    BinaryNottext1: TMenuItem;
    ASCIIText1: TMenuItem;
    BinaryNottext2: TMenuItem;
    procedure FTPAfterClientLogin(Sender: TObject);
    procedure FTPDisconnected(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FTPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: String);
    procedure actConnectDisconnectExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure edFolderKeyPress(Sender: TObject; var Key: Char);
    procedure lbStatusDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FTPWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCountMax: Integer);
    procedure FTPWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
    procedure FTPWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
    procedure actChangeDirUPExecute(Sender: TObject);
    procedure actDownloadFileExecute(Sender: TObject);
    procedure lbDirectoryDblClick(Sender: TObject);
    procedure actDeleteFileFolderExecute(Sender: TObject);
    procedure actCreateFolderExecute(Sender: TObject);
    procedure actUploadFileExecute(Sender: TObject);
    procedure lbDirectoryKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure actBackExecute(Sender: TObject);
    procedure actHomeExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actConfigureSiteExecute(Sender: TObject);
    procedure actConfigureApplicationExecute(Sender: TObject);
    procedure cbFTPAddressChange(Sender: TObject);
    procedure BinaryNottext1Click(Sender: TObject);
  private
    { Private declarations }
    FLastDirStack : TStringList;
    FRootDir      : String;
    FHelpFile     : String;
    Sites         : TFTPSiteList;
    ApplicationConfig : TApplicationConfig;

    procedure DisplayFTP;
    function GetHelpFile: String;
    procedure LoadDefaultValues;
    procedure StoreDefaultValues;
    procedure InitLogColors;
  public
    { Public declarations }
    procedure SetControls;
    procedure Log(Msg : String; Color : TColor = clBlack);
    procedure ChangeFTPDir(NewDir : String);
    property HelpFile : String read GetHelpFile;
  end;

var
  frmMain: TfrmMain;
  Ini    : TIniFile;

implementation

uses
  AboutForm;

{$R *.DFM}

{ TfrmMain }

procedure TfrmMain.SetControls;
begin
  if FTP.Connected then
    begin
      actConnectDisconnect.Caption := 'Disconnect';
      sbMain.Panels[0].Text := 'Online';
    end
  else
    begin
      actConnectDisconnect.Caption := 'Connect';
      sbMain.Panels[0].Text := 'Offline';
    end;

  actConnectDisconnect.Hint := actConnectDisconnect.Caption;
  
  actConnectDisconnect.Checked := FTP.Connected;
  btnGo.Enabled                := FTP.Connected;
  actChangeDirUP.Enabled       := FTP.Connected;
  actBack.Enabled              := FTP.Connected and (FLastDirStack.Count > 0);
  actHome.Enabled              := FTP.Connected;
  actCreateFolder.Enabled      := FTP.Connected;
  actDeleteFileFolder.Enabled  := FTP.Connected;
  actUploadFile.Enabled        := FTP.Connected;
  actDownloadFile.Enabled      := FTP.Connected;
  actConfigureSite.Enabled     := (not FTP.Connected) and (cbFTPAddress.Text <> '');
  edFolder.Enabled             := FTP.Connected;
  cbFTPAddress.Enabled         := not FTP.Connected;
  edUserName.Enabled           := not FTP.Connected;
  edPassword.Enabled           := not FTP.Connected;
  actConnectDisconnect.Enabled := (cbFTPAddress.Text <> '');
end;

procedure TfrmMain.FTPAfterClientLogin(Sender: TObject);
begin
  SetControls;
  FLastDirStack.Clear;

  if cbFTPAddress.ItemIndex > -1 then
    begin
      ChangeFTPDir(Sites[cbFTPAddress.ItemIndex].RootDir);
    end;

  DisplayFtp;
  FRootDir := FTP.RetrieveCurrentDir;
end;

procedure TfrmMain.FTPDisconnected(Sender: TObject);
begin
  SetControls;
  lvFiles.Items.Clear;
  tvFolders.Items.Clear;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  r: TRect;
begin
  sbMain.ControlStyle := sbMain.ControlStyle + [csAcceptsControls];

  sbMain.Perform(SB_GETRECT, 1, Integer(@R));

  pbProgress.Parent := sbMain;
  pbProgress.Top    := r.Top;
  pbProgress.Left   := r.Left;
  pbProgress.Width  := r.Right - r.Left;
  pbProgress.Height := r.Bottom - r.Top;
  pbProgress.Visible:= false;
end;

procedure TfrmMain.FTPStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: String);
var
  Clr : TColor;
begin
  sbMain.Panels[2].Text := AStatusText;
  clr := ApplicationConfig.LogColors.Colors['Default'];
  case AStatus of
    hsStatusText    : Clr := ApplicationConfig.LogColors.Colors['hsStatusText'];
    hsResolving     : Clr := ApplicationConfig.LogColors.Colors['hsResolving'];
    hsConnecting    : Clr := ApplicationConfig.LogColors.Colors['hsConnecting'];
    hsDisconnecting : Clr := ApplicationConfig.LogColors.Colors['hsDisconnecting'];
    hsConnected     : Clr := ApplicationConfig.LogColors.Colors['hsConnected'];
    hsDisconnected  : Clr := ApplicationConfig.LogColors.Colors['hsDisconnected'];
    ftpTransfer     : Clr := ApplicationConfig.LogColors.Colors['ftpTransfer'];
    ftpReady        : Clr := ApplicationConfig.LogColors.Colors['ftpReady'];
    ftpAborted      : Clr := ApplicationConfig.LogColors.Colors['ftpAborted'];
  end;
  Log(AStatusText, clr);
end;

procedure TfrmMain.actConnectDisconnectExecute(Sender: TObject);
begin
  if FTP.Connected then
    begin
      FTP.Disconnect;
    end
  else
    begin
      lbStatus.Items.Clear;
      if cbFTPAddress.ItemIndex = -1 then
        FTP.Host := cbFTPAddress.Text
      else
        FTP.Host := TFTPSiteInfo(cbFTPAddress.Items.Objects[cbFTPAddress.ItemIndex]).Address;
      FTP.Username := edUserName.Text;
      FTP.Password := edPassword.Text;

      FTP.Connect;
    end;
end;

procedure TfrmMain.DisplayFTP;
var
  i, c : Integer;
  s : String;
begin
  lbDirectory.Items.Clear;
  FTP.List(lbDirectory.Items, '', false);

  edFolder.Text := FTP.RetrieveCurrentDir;

  tvFolders.Items.Clear;
  lvFiles.Items.Clear;

  for c := 0 to lbDirectory.Items.Count -1 do
    begin
      s := lbDirectory.Items[c];
      i := FTP.Size(s);
      if i = -1 then
        begin
        // Directory
          tvFolders.Items.Add(nil, s);
        end
      else
        begin
        // File
          lvFiles.Items.Add.Caption := s;
        end;
    end;
  SetControls;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  ApplicationConfig := TApplicationConfig.Create;

  Sites := TFTPSiteList.Create;

  LoadDefaultValues;

  FLastDirStack := TStringList.Create;
  edFolder.Text := '/';
  lbDirectory.Visible := false;
  SetControls;
  actHelp.Enabled := FileExists(HelpFile);
end;

procedure TfrmMain.btnGoClick(Sender: TObject);
begin
  if btnGo.Enabled then
    begin
      ChangeFTPDir(edFolder.Text);
    end;
end;

procedure TfrmMain.edFolderKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
    begin
      btnGo.Click;
      Key := #0;
    end;
end;

procedure TfrmMain.Log(Msg: String; Color: TColor);
begin
  lbStatus.Items.AddObject(Msg, Pointer(Color));
  lbStatus.ItemIndex := lbStatus.Items.Count -1;
end;

procedure TfrmMain.lbStatusDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
// This draws the items in the Process Log in colors to allow quick
// visual inspection
  with Control as TListBox do
  begin
    Canvas.Brush.Color := Color;

    Canvas.FillRect(Rect); 
    Canvas.Font.Color := TColor(Items.Objects[Index]);
    Canvas.TextOut(Rect.Left + 2, Rect.Top, Items[Index]);
  end;
end;

procedure TfrmMain.FTPWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCountMax: Integer);
begin
  pbProgress.Max := AWorkCountMax;
  pbProgress.Position := 0;
  pbProgress.Visible := true;
  Log('Work begin ' + IntToStr(AWorkCountMax), clPurple);
end;

procedure TfrmMain.FTPWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin
  pbProgress.Visible := false;
  Log('Work end', clPurple);
end;

procedure TfrmMain.FTPWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
begin
  pbProgress.Position := AWorkCount;
  Log('Work ' + IntToStr(AWorkCount), clPurple);
end;

procedure TfrmMain.ChangeFTPDir(NewDir: String);
begin
  FLastDirStack.Add(FTP.RetrieveCurrentDir);
  FTP.ChangeDir(NewDir);
  DisplayFTP;
end;

procedure TfrmMain.actChangeDirUPExecute(Sender: TObject);
begin
  FTP.ChangeDirUp;
  DisplayFTP;
end;

procedure TfrmMain.actDownloadFileExecute(Sender: TObject);
var
  i : Integer;
  ext,
  s : String;
  b : boolean;
begin
  if lvFiles.Focused then
    begin
      if Assigned(lvFiles.Selected) then
        lbDirectory.ItemIndex := lbDirectory.Items.IndexOf(lvFiles.Selected.Caption)
      else
        lbDirectory.ItemIndex := -1;
    end
  else
      if Assigned(tvFolders.Selected) then
        lbDirectory.ItemIndex := lbDirectory.Items.IndexOf(tvFolders.Selected.Text)
      else
        lbDirectory.ItemIndex := -1;

  i := lbDirectory.ItemIndex;
  if i <> -1 then
    begin
      s := lbDirectory.Items[i];
      i := FTP.Size(s);
      if i = -1 then
        begin
        // Directory
          ChangeFTPDir(s);
        end
      else
        begin
        // File
          ext := ExtractFileExt(s);
          SaveFile.Filter := ext + ' files|*' + ext + '|All Files|*.*';
          SaveFile.FileName := s;
          if SaveFile.Execute then
            begin
              b := true;
              if FileExists(SaveFile.FileName) then
                if MessageDlg('File exists overwrite?', mtWarning, [mbYes,mbNo], 0) = mrYes then
                  DeleteFile(SaveFile.FileName);

              if ASCIIText1.Checked then
                FTP.TransferType := ftASCII
              else
                FTP.TransferType := ftBinary;

              if b then
                FTP.Get(s, SaveFile.FileName, True, false);//FTP.ResumeSupported);
            end;
        end;
    end
  else
    MessageDlg('You must first select a file to download from the site.', mtWarning, [mbOK], 0);
end;

procedure TfrmMain.lbDirectoryDblClick(Sender: TObject);
begin
  actDownloadFile.Execute;
end;

procedure TfrmMain.actDeleteFileFolderExecute(Sender: TObject);
var
  i : Integer;
  s : String;
begin
  i := lbDirectory.ItemIndex;
  if i <> -1 then
    begin
      s := lbDirectory.Items[i];
      if MessageDlg('Are you sure you want to delete %s?', mtWarning, [mbYes,mbNo], 0) = mrYes then
        FTP.Delete(s);
      DisplayFTP;
    end
  else
    MessageDlg('You must first select a file or folder to delete from the site.', mtWarning, [mbOK], 0);
end;

procedure TfrmMain.actCreateFolderExecute(Sender: TObject);
var
  s : String;
begin
  s := 'New Folder';
  if InputQuery('New folder', 'New folder name:', s) then
    begin
      FTP.MakeDir(s);
      ChangeFTPDir(s);
    end;
end;

procedure TfrmMain.actUploadFileExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
    begin
      if BinaryNottext1.Checked then
        FTP.TransferType := ftASCII
      else
        FTP.TransferType := ftBinary;
      FTP.Put(OpenDialog.FileName, ExtractFileName(OpenDialog.FileName));
      DisplayFTP;
    end;
end;

procedure TfrmMain.lbDirectoryKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #13:
      actDownloadFile.Execute;
    #8:
      actBack.Execute;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FLastDirStack.Free;
  StoreDefaultValues;
  Ini.Free;
  Sites.Free;
  ApplicationConfig.Free;
end;

procedure TfrmMain.actBackExecute(Sender: TObject);
var
  s : String;
begin
  if FLastDirStack.Count > 0 then
    begin
      s := FLastDirStack[FLastDirStack.Count -1];
      ChangeFTPDir(s);
      // Delete S
      FLastDirStack.Delete(FLastDirStack.Count -1);
      // Delete the jump from S
      FLastDirStack.Delete(FLastDirStack.Count -1);
      SetControls;
    end;
end;

procedure TfrmMain.actHomeExecute(Sender: TObject);
begin
  ChangeFTPDir(FRootDir);
end;

procedure TfrmMain.actHelpExecute(Sender: TObject);
begin
  if actHelp.Enabled then
    frmAbout.ShowModal;
    //ShellExecute(handle, 'OPEN', PChar(HelpFile), '', '', SW_SHOWNORMAL);
end;

function TfrmMain.GetHelpFile: String;
begin
  if FHelpFile = '' then
    FHelpFile := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\Help\index.htm');
  Result := FHelpFile;
end;

procedure TfrmMain.LoadDefaultValues;
var
  i, c : Integer;
  s : String;
  site : TFTPSiteInfo;
begin
  InitLogColors;
  ApplicationConfig.LoadFromIni(Ini);

  Sites.Clear;
  c := Ini.ReadInteger('SITES', 'Count', 0);
  for i := 0 to c -1 do
    begin
      site := TFTPSiteInfo.Create;
      s := 'Site' + IntToStr(i) + '.';
      site.Name     := Ini.ReadString('SITES', s + 'Name', '');
      site.Address  := Ini.ReadString('SITES', s + 'Address', '');
      site.UserName := Ini.ReadString('SITES', s + 'UserName', '');
      site.Password := Ini.ReadString('SITES', s + 'Password', '');
      site.RootDir  := Ini.ReadString('SITES', s + 'RootDir', '');
      Sites.Add(Site);
    end;

  cbFTPAddress.Items.Clear;
  for i := 0 to Sites.Count -1 do
    begin
      cbFTPAddress.Items.AddObject(Sites[i].Name, Sites[i]);
    end;
end;

procedure TfrmMain.StoreDefaultValues;
var
  i : Integer;
  s : String;
  site : TFTPSiteInfo;
begin
  for i := 0 to Sites.Count -1 do
    begin
      site := Sites[i];
      s := 'Site' + IntToStr(i) + '.';
      Ini.WriteString('SITES', s + 'Name', site.Name);
      Ini.WriteString('SITES', s + 'Address', site.Address);
      Ini.WriteString('SITES', s + 'UserName', site.UserName);
      Ini.WriteString('SITES', s + 'Password', site.Password);
      Ini.WriteString('SITES', s + 'RootDir', site.RootDir);
    end;

  ApplicationConfig.SaveToIni(Ini);

  Ini.WriteInteger('SITES', 'Count', Sites.Count);
  s := cbFTPAddress.Text;
  cbFTPAddress.OnChange := nil;
  try
    cbFTPAddress.ItemIndex := sites.IndexOfName(s);
    if cbFTPAddress.ItemIndex = -1 then
      cbFTPAddress.ItemIndex := sites.IndexOfAddress(s);
  finally
    cbFTPAddress.OnChange := cbFTPAddressChange;
  end;
end;

procedure TfrmMain.actConfigureSiteExecute(Sender: TObject);
begin
  if ConfigureSite(cbFTPAddress.ItemIndex, Sites) then
    begin
      StoreDefaultValues;
      LoadDefaultValues;
    end;
end;

procedure TfrmMain.actConfigureApplicationExecute(Sender: TObject);
begin
  if ConfigureApplication(ApplicationConfig) then
    StoreDefaultValues;
end;

procedure TfrmMain.cbFTPAddressChange(Sender: TObject);
var
  i : Integer;
begin
  i := cbFTPAddress.ItemIndex;
  if i = -1 then
    begin
      edUserName.Text := '';
      edPassword.Text := '';
    end
  else
    begin
      edUserName.Text := TFTPSiteInfo(cbFTPAddress.Items.Objects[i]).UserName;
      edPassword.Text := TFTPSiteInfo(cbFTPAddress.Items.Objects[i]).Password;
    end;

  actConfigureSite.Enabled     := (cbFTPAddress.Text <> '');
  actConnectDisconnect.Enabled := (cbFTPAddress.Text <> '');
end;

procedure TfrmMain.InitLogColors;
begin
  with ApplicationConfig.LogColors do
    begin
      Colors['Default']         := clBlack;
      Colors['hsStatusText']    := clBlack;
      Colors['hsResolving']     := clBlack;
      Colors['hsConnecting']    := clBlack;
      Colors['hsDisconnecting'] := clBlack;
      Colors['hsConnected']     := clBlue;
      Colors['hsDisconnected']  := clBlue;
      Colors['ftpTransfer']     := clBlue;
      Colors['ftpReady']        := clGreen;
      Colors['ftpAborted']      := clRed;
    end;
end;

procedure TfrmMain.BinaryNottext1Click(Sender: TObject);
begin
  TMenuItem(Sender).Checked := true;
end;

end.
