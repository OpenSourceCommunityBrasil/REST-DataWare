unit uRESTDWInstallerVCLWizard;

interface

uses
  Windows, Messages, Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, CheckLst, FileCtrl, Contnrs, ImgList, Buttons,
  uRESTDWInstallerCore, uRESTDWInstallerConfig, uRESTDWDelphiInstall;

type
  TRESTDWDelphiTargetItem = class
  public
    IDE: TRESTDWDelphiIDE;
    Framework: String;
  end;

  TfrmRESTDWInstallerVCL = class(TForm)
  private
    FCore: TRESTDWInstallerCore;
    FConfig: TRESTDWInstallerConfig;
    FDelphi: TRESTDWDelphiInstaller;
    FTargetItems: TObjectList;
    FSelectedTargets: TStringList;
    FSelectedPackages: TStringList;
    FPackageFiles: TStringList;
    FInstallerImages: TImageList;
    FCurrentPackage: Integer;
    FPage: Integer;
    FInstallSource: TRESTDWInstallSource;
    FInstallAction: TRESTDWInstallAction;
    FExistingInstallPath: String;
    FNewInstall: TRadioButton;
    FModifyInstall: TRadioButton;
    FRemoveInstall: TRadioButton;
    FSidePanel: TPanel;
    FSideImage: TImage;
    FPagePanel: TPanel;
    FBottomPanel: TPanel;
    FBack: TSpeedButton;
    FNext: TSpeedButton;
    FCancel: TSpeedButton;
    FTargets: TCheckListBox;
    FPackages: TCheckListBox;
    FPlatforms: TCheckListBox;
    FDestination: TEdit;
    FBrowse: TButton;
    FSourceLocal: TRadioButton;
    FSourceCab: TRadioButton;
    FSourceSVNTrunk: TRadioButton;
    FSourceSVNBranch: TRadioButton;
    FProgress: TProgressBar;
    FStatus: TLabel;
    FSlideImage: TImage;
    FSlideTimer: TTimer;
    FSlideFiles: TStringList;
    FSlideIndex: Integer;
    procedure BuildChrome;
    procedure ClearPage;
    procedure ShowPage(APage: Integer);
    procedure ShowWelcome;
    procedure ShowTargets;
    procedure ShowPackages;
    procedure ShowDestination;
    procedure ShowSource;
    procedure ShowReady;
    procedure BackClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure PackageClick(Sender: TObject);
    procedure TargetDrawItem(Control: TWinControl; Index: Integer;
                             Rect: TRect; State: TOwnerDrawState);
    procedure PackageDrawItem(Control: TWinControl; Index: Integer;
                              Rect: TRect; State: TOwnerDrawState);
    procedure PlatformDrawItem(Control: TWinControl; Index: Integer;
                               Rect: TRect; State: TOwnerDrawState);
    procedure LoadInstallerImages;
    function PackageIconIndex(const AName: String): Integer;
    function PlatformIconIndex(const AName: String): Integer;
    procedure SlideTimerHandler(Sender: TObject);
    procedure FormCloseQueryHandler(Sender: TObject; var CanClose: Boolean);
    procedure CoreProgress(AValue, AMaximum: Integer; const AText: String);
    procedure CoreLog(const AText: String);
    procedure SaveCurrentPackagePlatforms;
    procedure LoadPackagePlatforms(AIndex: Integer);
    procedure CollectSelectedTargets;
    procedure CollectSelectedPackages;
    procedure StartInstall;
    procedure LoadSlides;
    procedure GenerateProjectGroups(AIDE: TRESTDWDelphiIDE;
                                    AInstalledProjects: TStrings);
    procedure EnumerateDemoProjects(const ARoot: String; AList: TStrings);
    function BaseRoot: String;
    function RelativeToBase(const AFileName: String): String;
    function SelectedSource: TRESTDWInstallSource;
    function PackageSelectedPlatforms(const APackage: String): String;
    function TargetSelected(AIDE: TRESTDWDelphiIDE;
                            const AFramework: String): Boolean;
    function PackageSupportsFramework(const AFileName,
                                      AFramework: String): Boolean;
    function PlatformSupportedBySelectedIDE(const APlatform: String): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmRESTDWInstallerVCL: TfrmRESTDWInstallerVCL;

implementation

constructor TfrmRESTDWInstallerVCL.Create(AOwner: TComponent);
begin
 inherited CreateNew(AOwner);
 Caption := 'REST Dataware Installer - Delphi';
 ClientWidth := 1100;
 ClientHeight := 650;
 Position := poScreenCenter;
 BorderStyle := bsDialog;
 FTargetItems := TObjectList.Create(True);
 FSelectedTargets := TStringList.Create;
 FSelectedPackages := TStringList.Create;
 FPackageFiles := TStringList.Create;
 FInstallerImages := TImageList.Create(Self);
 LoadInstallerImages;
 FSlideFiles := TStringList.Create;
 FCore := TRESTDWInstallerCore.Create(BaseRoot);
 FCore.OnProgress := CoreProgress;
 FCore.OnLog := CoreLog;
 FConfig := TRESTDWInstallerConfig.Create(BaseRoot + 'RESTDWInstaller.ini');
 FConfig.Load;
 FDelphi := TRESTDWDelphiInstaller.Create(FCore);
 FDelphi.DetectIDEs;
 FCurrentPackage := -1;
 FExistingInstallPath := '';
 If FCore.DetectInstallation(FExistingInstallPath) Then
  Begin
   FInstallAction := iaModifyInstall;
   FCore.DestinationPath := FExistingInstallPath;
  End
 Else
  FInstallAction := iaNewInstall;
 If FileExists(BaseRoot + 'CORE.CAB') Or FileExists(BaseRoot + 'CORE.tar.gz') Then
  FInstallSource := isCab
 Else
  FInstallSource := isLocal;
 If FConfig.Loaded Then
  FInstallSource := TRESTDWInstallSource(FConfig.SourceMode);
 BuildChrome;
 OnCloseQuery := FormCloseQueryHandler;
 ShowPage(0);
end;

destructor TfrmRESTDWInstallerVCL.Destroy;
begin
 FDelphi.Free;
 FConfig.Free;
 FCore.Free;
 FSlideFiles.Free;
 FPackageFiles.Free;
 FSelectedPackages.Free;
 FSelectedTargets.Free;
 FTargetItems.Free;
 inherited Destroy;
end;

function TfrmRESTDWInstallerVCL.BaseRoot: String;
var
 LPath: String;
begin
 LPath := IncludeTrailingPathDelimiter(ExpandFileName(ExtractFilePath(ParamStr(0))));
 If DirectoryExists(LPath + 'Source') Or FileExists(LPath + 'CORE.CAB') Or
    FileExists(LPath + 'CORE.tar.gz') Then
  Result := LPath
 Else
  Result := IncludeTrailingPathDelimiter(ExpandFileName(LPath + '..\..\..\'));
end;

procedure TfrmRESTDWInstallerVCL.BuildChrome;
begin
 FSidePanel := TPanel.Create(Self);
 FSidePanel.Parent := Self;
 FSidePanel.Align := alLeft;
 FSidePanel.Width := 300;
 FSidePanel.BevelOuter := bvNone;

 FSideImage := TImage.Create(Self);
 FSideImage.Parent := FSidePanel;
 FSideImage.Align := alClient;
 FSideImage.Stretch := True;
 FSideImage.Proportional := True;
 FSideImage.Center := True;
 If FileExists(BaseRoot + 'Installer\Resources\dwScreen.bmp') Then
  FSideImage.Picture.LoadFromFile(BaseRoot + 'Installer\Resources\dwScreen.bmp');

 FBottomPanel := TPanel.Create(Self);
 FBottomPanel.Parent := Self;
 FBottomPanel.Align := alBottom;
 FBottomPanel.Height := 64;
 FBottomPanel.BevelOuter := bvNone;

 FBack := TSpeedButton.Create(Self);
 FBack.Parent := FBottomPanel;
 FBack.Caption := '< Voltar';
 FBack.SetBounds(740, 15, 105, 34);
 FBack.Flat := True;
 FBack.OnClick := BackClick;

 FNext := TSpeedButton.Create(Self);
 FNext.Parent := FBottomPanel;
 FNext.Caption := 'Avançar >';
 FNext.SetBounds(852, 15, 105, 34);
 FNext.Flat := True;
 FNext.OnClick := NextClick;

 FCancel := TSpeedButton.Create(Self);
 FCancel.Parent := FBottomPanel;
 FCancel.Caption := 'Cancelar';
 FCancel.SetBounds(964, 15, 105, 34);
 FCancel.Flat := True;
 FCancel.OnClick := CancelClick;

 FPagePanel := TPanel.Create(Self);
 FPagePanel.Parent := Self;
 FPagePanel.Align := alClient;
 FPagePanel.BevelOuter := bvNone;
end;

procedure TfrmRESTDWInstallerVCL.ClearPage;
var
 I: Integer;
begin
 If Assigned(FSlideTimer) Then
  FreeAndNil(FSlideTimer);
 For I := FPagePanel.ControlCount - 1 Downto 0 Do
  FPagePanel.Controls[I].Free;
 FTargets := nil;
 FPackages := nil;
 FPlatforms := nil;
 FDestination := nil;
 FBrowse := nil;
 FSourceLocal := nil;
 FSourceCab := nil;
 FSourceSVNTrunk := nil;
 FSourceSVNBranch := nil;
 FProgress := nil;
 FStatus := nil;
 FSlideImage := nil;
end;

procedure TfrmRESTDWInstallerVCL.ShowPage(APage: Integer);
begin
 ClearPage;
 FPage := APage;
 FBack.Enabled := FPage > 0;
 FNext.Enabled := True;
 FNext.Caption := 'Avançar >';
 Case FPage Of
  0: ShowWelcome;
  1: ShowTargets;
  2: ShowPackages;
  3: ShowDestination;
  4: ShowSource;
  5: ShowReady;
 End;
end;


procedure TfrmRESTDWInstallerVCL.ShowWelcome;
var
 LTitle : TLabel;
 LInfo  : TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FPagePanel;
 LTitle.Caption := 'Bem vindo a Instalação do REST Dataware';
 LTitle.Font.Size := 18;
 LTitle.Font.Style := [fsBold];
 LTitle.SetBounds(34, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FPagePanel;
 LInfo.WordWrap := True;
 If FExistingInstallPath = '' Then
  LInfo.Caption := 'Nenhuma instalação do REST Dataware foi localizada neste computador.'
 Else
  LInfo.Caption := 'Foi localizada uma instalação do REST Dataware em: ' +
                   FExistingInstallPath;
 LInfo.SetBounds(34, 76, 730, 58);

 FNewInstall := TRadioButton.Create(Self);
 FNewInstall.Parent := FPagePanel;
 FNewInstall.Caption := 'Nova instalação';
 FNewInstall.SetBounds(54, 160, 600, 28);

 If FExistingInstallPath <> '' Then
  Begin
   FNewInstall.Visible := False;
   FModifyInstall := TRadioButton.Create(Self);
   FModifyInstall.Parent := FPagePanel;
   FModifyInstall.Caption := 'Modificar instalação';
   FModifyInstall.Checked := True;
   FModifyInstall.SetBounds(54, 160, 600, 28);

   FRemoveInstall := TRadioButton.Create(Self);
   FRemoveInstall.Parent := FPagePanel;
   FRemoveInstall.Caption := 'Remover';
   FRemoveInstall.SetBounds(54, 204, 600, 28);
  End
 Else
  FNewInstall.Checked := True;
end;

procedure TfrmRESTDWInstallerVCL.ShowTargets;
var
 LTitle: TLabel;
 LInfo: TLabel;
 I: Integer;
 LIDE: TRESTDWDelphiIDE;
 LItem: TRESTDWDelphiTargetItem;
 LIndex: Integer;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FPagePanel;
 LTitle.Caption := 'Selecione o Delphi';
 LTitle.Font.Size := 18;
 LTitle.Font.Style := [fsBold];
 LTitle.SetBounds(34, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FPagePanel;
 LInfo.Caption := 'Selecione uma ou mais versões do Delphi e o framework desejado.';
 LInfo.SetBounds(34, 72, 730, 42);

 FTargets := TCheckListBox.Create(Self);
 FTargets.Parent := FPagePanel;
 FTargets.SetBounds(34, 122, 730, 450);
 FTargets.Style := lbOwnerDrawFixed;
 FTargets.ItemHeight := 30;
 FTargets.OnDrawItem := TargetDrawItem;
 FTargetItems.Clear;
 For I := 0 To FDelphi.IDEs.Count - 1 Do
  Begin
   LIDE := TRESTDWDelphiIDE(FDelphi.IDEs[I]);
   If LIDE.SupportsVCL Then
    Begin
     LItem := TRESTDWDelphiTargetItem.Create;
     LItem.IDE := LIDE;
     LItem.Framework := 'VCL';
     FTargetItems.Add(LItem);
     LIndex := FTargets.Items.Add(LIDE.Name + ' - VCL');
     FTargets.Items.Objects[LIndex] := LItem;
     FTargets.Checked[LIndex] := (Not FConfig.Loaded) Or
                                 (FConfig.IDEs.IndexOf(LIDE.Version + '|VCL') >= 0);
    End;
   If LIDE.SupportsFMX Then
    Begin
     LItem := TRESTDWDelphiTargetItem.Create;
     LItem.IDE := LIDE;
     LItem.Framework := 'FMX';
     FTargetItems.Add(LItem);
     LIndex := FTargets.Items.Add(LIDE.Name + ' - FMX');
     FTargets.Items.Objects[LIndex] := LItem;
     FTargets.Checked[LIndex] := (Not FConfig.Loaded) Or
                                 (FConfig.IDEs.IndexOf(LIDE.Version + '|FMX') >= 0);
    End;
  End;
end;

procedure TfrmRESTDWInstallerVCL.LoadInstallerImages;
const
 CFiles: Array[0..14] Of String = (
  'pkg_core.bmp', 'pkg_database.bmp', 'pkg_native.bmp', 'pkg_client.bmp',
  'pkg_visual.bmp', 'pkg_report.bmp', 'pkg_web.bmp', 'pkg_tools.bmp',
  'os_windows.bmp', 'os_linux.bmp', 'os_macos.bmp', 'os_android.bmp',
  'os_ios.bmp', 'os_fpc.bmp', 'ide_delphi.bmp');
var
 I: Integer;
 B: TBitmap;
 LFile: String;
begin
 FInstallerImages.Width := 24;
 FInstallerImages.Height := 24;
 For I := Low(CFiles) To High(CFiles) Do
  Begin
   B := TBitmap.Create;
   Try
    LFile := BaseRoot + 'Installer\Resources\InstallerIcons\' + CFiles[I];
    If FileExists(LFile) Then
     B.LoadFromFile(LFile)
    Else
     Begin
      B.Width := 24;
      B.Height := 24;
      B.Canvas.Brush.Color := clWhite;
      B.Canvas.FillRect(Rect(0, 0, 24, 24));
     End;
    FInstallerImages.AddMasked(B, clWhite);
   Finally
    B.Free;
   End;
  End;
end;

function TfrmRESTDWInstallerVCL.PackageIconIndex(const AName: String): Integer;
var
 LName: String;
begin
 LName := LowerCase(AName);
 If (Pos('native', LName) > 0) Then
  Result := 2
 Else If (Pos('driver', LName) > 0) Or (Pos('dac', LName) > 0) Or
         (Pos('zeos', LName) > 0) Or (Pos('fire', LName) > 0) Then
  Result := 1
 Else If (Pos('client', LName) > 0) Or (Pos('pooler', LName) > 0) Then
  Result := 3
 Else If (Pos('report', LName) > 0) Then
  Result := 5
 Else If (Pos('html', LName) > 0) Or (Pos('web', LName) > 0) Then
  Result := 6
 Else If (Pos('design', LName) > 0) Or (Pos('visual', LName) > 0) Or
         (Pos('component', LName) > 0) Then
  Result := 4
 Else If (Pos('tool', LName) > 0) Or (Pos('util', LName) > 0) Then
  Result := 7
 Else
  Result := 0;
end;

function TfrmRESTDWInstallerVCL.PlatformIconIndex(const AName: String): Integer;
var
 LName: String;
begin
 LName := LowerCase(AName);
 If Pos('win', LName) > 0 Then
  Result := 8
 Else If Pos('linux', LName) > 0 Then
  Result := 9
 Else If Pos('android', LName) > 0 Then
  Result := 11
 Else If Pos('ios', LName) > 0 Then
  Result := 12
 Else If (Pos('osx', LName) > 0) Or (Pos('mac', LName) > 0) Then
  Result := 10
 Else
  Result := 13;
end;

procedure TfrmRESTDWInstallerVCL.TargetDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 LList: TCheckListBox;
 LBitmap: TBitmap;
 LIconFile: String;
begin
 LList := TCheckListBox(Control);
 LList.Canvas.FillRect(Rect);
 If (Index >= 0) And (Index < LList.Items.Count) Then
  Begin
   LIconFile := BaseRoot +
                'Installer\Resources\InstallerIcons\ide_delphi.bmp';
   If FileExists(LIconFile) Then
    Begin
     LBitmap := TBitmap.Create;
     Try
      LBitmap.LoadFromFile(LIconFile);
      LList.Canvas.Draw(Rect.Left + 24, Rect.Top + 3, LBitmap);
     Finally
      LBitmap.Free;
     End;
    End
   Else
    If FInstallerImages.Count > 14 Then
     FInstallerImages.Draw(LList.Canvas, Rect.Left + 24, Rect.Top + 3, 14);
   LList.Canvas.TextOut(Rect.Left + 54, Rect.Top + 7, LList.Items[Index]);
  End;
end;

procedure TfrmRESTDWInstallerVCL.PackageDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 LList: TCheckListBox;
begin
 LList := TCheckListBox(Control);
 LList.Canvas.FillRect(Rect);
 If (Index >= 0) And (Index < LList.Items.Count) Then
  Begin
   FInstallerImages.Draw(LList.Canvas, Rect.Left + 4, Rect.Top + 3,
                         PackageIconIndex(LList.Items[Index]));
   LList.Canvas.TextOut(Rect.Left + 36, Rect.Top + 7, LList.Items[Index]);
  End;
end;

procedure TfrmRESTDWInstallerVCL.PlatformDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 LList: TCheckListBox;
begin
 LList := TCheckListBox(Control);
 LList.Canvas.FillRect(Rect);
 If (Index >= 0) And (Index < LList.Items.Count) Then
  Begin
   FInstallerImages.Draw(LList.Canvas, Rect.Left + 4, Rect.Top + 3,
                         PlatformIconIndex(LList.Items[Index]));
   LList.Canvas.TextOut(Rect.Left + 36, Rect.Top + 7, LList.Items[Index]);
  End;
end;

procedure TfrmRESTDWInstallerVCL.ShowPackages;
var
 LTitle: TLabel;
 LInfo: TLabel;
 LList: TStringList;
 I: Integer;
 LRelative: String;
 LSaved: String;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FPagePanel;
 LTitle.Caption := 'Pacotes e plataformas';
 LTitle.Font.Size := 18;
 LTitle.Font.Style := [fsBold];
 LTitle.SetBounds(34, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FPagePanel;
 LInfo.Caption := 'Selecione os pacotes na ordem de instalação. Para cada pacote, escolha as plataformas.';
 LInfo.SetBounds(34, 72, 730, 42);

 FPackages := TCheckListBox.Create(Self);
 FPackages.Parent := FPagePanel;
 FPackages.SetBounds(34, 122, 500, 450);
 FPackages.Style := lbOwnerDrawFixed;
 FPackages.ItemHeight := 30;
 FPackages.OnDrawItem := PackageDrawItem;
 FPackages.OnClick := PackageClick;

 FPlatforms := TCheckListBox.Create(Self);
 FPlatforms.Parent := FPagePanel;
 FPlatforms.SetBounds(552, 122, 214, 450);
 FPlatforms.Style := lbOwnerDrawFixed;
 FPlatforms.ItemHeight := 30;
 FPlatforms.OnDrawItem := PlatformDrawItem;

 LList := TStringList.Create;
 Try
  FCore.EnumeratePackages(LList, BaseRoot + 'Packages\Delphi');
  For I := LList.Count - 1 DownTo 0 Do
   If LowerCase(ExtractFileExt(LList[I])) = '.dproj' Then
    LList.Delete(I);
  FCore.SortPackagesByDependencies(LList);
  FPackageFiles.Clear;
  For I := 0 To LList.Count - 1 Do
   Begin
    LRelative := RelativeToBase(LList[I]);
    FPackageFiles.Add(LRelative);
    FPackages.Items.Add(Format('%.2d  %s',
                               [FPackages.Items.Count + 1,
                                ChangeFileExt(ExtractFileName(LRelative), '')]));
    LSaved := FConfig.GetPackagePlatforms(LRelative);
    FPackages.Checked[FPackages.Items.Count - 1] :=
     (Not FConfig.Loaded) Or (LSaved <> '');
   End;
 Finally
  LList.Free;
 End;
 If FPackages.Items.Count > 0 Then
  Begin
   FPackages.ItemIndex := 0;
   FCurrentPackage := 0;
   LoadPackagePlatforms(0);
  End;
end;

procedure TfrmRESTDWInstallerVCL.SaveCurrentPackagePlatforms;
var
 I: Integer;
 LValue: String;
begin
 If (FPlatforms = nil) Or (FPackages = nil) Or
    (FCurrentPackage < 0) Or (FCurrentPackage >= FPackages.Items.Count) Then
  Exit;
 LValue := '';
 For I := 0 To FPlatforms.Items.Count - 1 Do
  If FPlatforms.Checked[I] Then
   Begin
    If LValue <> '' Then
     LValue := LValue + ',';
    LValue := LValue + FPlatforms.Items[I];
   End;
 If FPackages.Checked[FCurrentPackage] Then
  FConfig.SetPackagePlatforms(FPackageFiles[FCurrentPackage], LValue)
 Else
  FConfig.SetPackagePlatforms(FPackageFiles[FCurrentPackage], '');
end;

procedure TfrmRESTDWInstallerVCL.LoadPackagePlatforms(AIndex: Integer);
var
 LProject: String;
 LList: TStringList;
 LSaved: String;
 I: Integer;
begin
 If (AIndex < 0) Or (AIndex >= FPackages.Items.Count) Then
  Exit;
 FPlatforms.Clear;
 LProject := BaseRoot + FPackageFiles[AIndex];
 If FileExists(ChangeFileExt(LProject, '.dproj')) Then
  LProject := ChangeFileExt(LProject, '.dproj');
 LList := TStringList.Create;
 Try
  FCore.EnumeratePlatforms(LProject, LList);
  If LList.Count = 0 Then
   LList.Add('Win32');
  LSaved := FConfig.GetPackagePlatforms(FPackageFiles[AIndex]);
  For I := 0 To LList.Count - 1 Do
   If PlatformSupportedBySelectedIDE(LList[I]) Then
    Begin
     FPlatforms.Items.Add(LList[I]);
     If Not FConfig.Loaded Then
      FPlatforms.Checked[FPlatforms.Items.Count - 1] := True
     Else
      FPlatforms.Checked[FPlatforms.Items.Count - 1] :=
       Pos(',' + LList[I] + ',', ',' + LSaved + ',') > 0;
    End;
 Finally
  LList.Free;
 End;
end;

procedure TfrmRESTDWInstallerVCL.PackageClick(Sender: TObject);
begin
 SaveCurrentPackagePlatforms;
 FCurrentPackage := FPackages.ItemIndex;
 LoadPackagePlatforms(FCurrentPackage);
end;

procedure TfrmRESTDWInstallerVCL.ShowDestination;
var
 LTitle: TLabel;
 LInfo: TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FPagePanel;
 LTitle.Caption := 'Diretório de destino';
 LTitle.Font.Size := 18;
 LTitle.Font.Style := [fsBold];
 LTitle.SetBounds(34, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FPagePanel;
 LInfo.WordWrap := True;
 LInfo.Caption := 'A pasta Source instalada será usada para configurar o Library Path dos Delphis selecionados.';
 LInfo.SetBounds(34, 78, 620, 50);

 FDestination := TEdit.Create(Self);
 FDestination.Parent := FPagePanel;
 FDestination.SetBounds(34, 150, 535, 28);
 If FExistingInstallPath <> '' Then
  FDestination.Text := FExistingInstallPath
 Else If FConfig.Destination <> '' Then
  FDestination.Text := FConfig.Destination
 Else
  FDestination.Text := ExpandFileName(BaseRoot + '..\RESTDataWare');

 FBrowse := TButton.Create(Self);
 FBrowse.Parent := FPagePanel;
 FBrowse.Caption := '...';
 FBrowse.SetBounds(580, 149, 48, 30);
 FBrowse.OnClick := BrowseClick;
end;

procedure TfrmRESTDWInstallerVCL.ShowSource;
var
 LTitle: TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FPagePanel;
 LTitle.Caption := 'Fonte da instalação';
 LTitle.Font.Size := 18;
 LTitle.Font.Style := [fsBold];
 LTitle.SetBounds(34, 28, 730, 36);

 FSourceLocal := TRadioButton.Create(Self);
 FSourceLocal.Parent := FPagePanel;
 FSourceLocal.Caption := 'Local - Source, Packages, Images, Extras e Demos';
 FSourceLocal.SetBounds(34, 100, 600, 26);

 FSourceCab := TRadioButton.Create(Self);
 FSourceCab.Parent := FPagePanel;
 FSourceCab.Caption := 'CORE.CAB / CORE.tar.gz ao lado do instalador';
 FSourceCab.SetBounds(34, 140, 600, 26);
 FSourceCab.Enabled := FileExists(BaseRoot + 'CORE.CAB') Or FileExists(BaseRoot + 'CORE.tar.gz');

 FSourceSVNTrunk := TRadioButton.Create(Self);
 FSourceSVNTrunk.Parent := FPagePanel;
 FSourceSVNTrunk.Caption := 'SVN - Trunk (Versão estável)';
 FSourceSVNTrunk.SetBounds(34, 180, 600, 26);

 FSourceSVNBranch := TRadioButton.Create(Self);
 FSourceSVNBranch.Parent := FPagePanel;
 FSourceSVNBranch.Caption := 'SVN - Branch (Desenvolvimento)';
 FSourceSVNBranch.SetBounds(34, 220, 600, 26);

 Case Ord(FInstallSource) Of
  1:
   Begin
    If FSourceCab.Enabled Then
     FSourceCab.Checked := True
    Else
     FSourceLocal.Checked := True;
   End;
  2: FSourceSVNTrunk.Checked := True;
  3: FSourceSVNBranch.Checked := True;
 Else
  If FSourceCab.Enabled Then
   FSourceCab.Checked := True
  Else
   FSourceLocal.Checked := True;
 End;
end;

procedure TfrmRESTDWInstallerVCL.ShowReady;
var
 LTitle: TLabel;
 LInfo: TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FPagePanel;
 LTitle.Caption := 'Pronto para instalar';
 LTitle.Font.Size := 18;
 LTitle.Font.Style := [fsBold];
 LTitle.SetBounds(34, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FPagePanel;
 LInfo.WordWrap := True;
 LInfo.Caption :=
  'O instalador verificará se alguma IDE selecionada está aberta, copiará a distribuição, ' +
  'configurará paths, compilará os pacotes com o compilador de cada Delphi e registrará os componentes.';
 LInfo.SetBounds(34, 88, 620, 96);
 FNext.Caption := 'Iniciar';
end;

procedure TfrmRESTDWInstallerVCL.BackClick(Sender: TObject);
begin
 If FPage = 2 Then
  SaveCurrentPackagePlatforms;
 If FPage > 0 Then
  ShowPage(FPage - 1);
end;

procedure TfrmRESTDWInstallerVCL.CollectSelectedTargets;
var
 I: Integer;
 LItem: TRESTDWDelphiTargetItem;
begin
 FSelectedTargets.Clear;
 For I := 0 To FTargets.Items.Count - 1 Do
  If FTargets.Checked[I] Then
   Begin
    LItem := TRESTDWDelphiTargetItem(FTargets.Items.Objects[I]);
    FSelectedTargets.Add(LItem.IDE.Version + '|' + LItem.Framework);
   End;
end;

procedure TfrmRESTDWInstallerVCL.CollectSelectedPackages;
var
 I: Integer;
begin
 SaveCurrentPackagePlatforms;
 FSelectedPackages.Clear;
 For I := 0 To FPackages.Items.Count - 1 Do
  If FPackages.Checked[I] Then
   FSelectedPackages.Add(FPackageFiles[I]);
end;

procedure TfrmRESTDWInstallerVCL.NextClick(Sender: TObject);
var
 I : Integer;
begin
 If FPage = 0 Then
  Begin
   If FExistingInstallPath = '' Then
    FInstallAction := iaNewInstall
   Else
    If Assigned(FRemoveInstall) And FRemoveInstall.Checked Then
     FInstallAction := iaRemoveInstall
    Else
     FInstallAction := iaModifyInstall;
   If FInstallAction = iaRemoveInstall Then
    Begin
     If MessageDlg('Deseja remover a instalação do REST Dataware?', mtConfirmation,
                   [mbYes, mbNo], 0) <> mrYes Then
      Exit;
     For I := 0 To FDelphi.IDEs.Count - 1 Do
      FDelphi.RemoveInstallation(TRESTDWDelphiIDE(FDelphi.IDEs[I]),
                                FExistingInstallPath);
     If FCore.RemoveInstalledDistribution Then
      Begin
       MessageDlg('REST Dataware removido com sucesso.', mtInformation, [mbOK], 0);
       Close;
      End
     Else
      MessageDlg('Não foi possível remover a instalação do REST Dataware.', mtError,
                 [mbOK], 0);
     Exit;
    End;
  End;
 If FPage = 1 Then
  Begin
   CollectSelectedTargets;
   If FSelectedTargets.Count = 0 Then
    Begin
     MessageDlg('Selecione pelo menos um Delphi/framework.', mtWarning, [mbOK], 0);
     Exit;
    End;
  End;
 If FPage = 2 Then
  Begin
   CollectSelectedPackages;
   If FSelectedPackages.Count = 0 Then
    Begin
     MessageDlg('Selecione pelo menos um pacote.', mtWarning, [mbOK], 0);
     Exit;
    End;
  End;
 If FPage = 3 Then
  Begin
   If Trim(FDestination.Text) = '' Then
    Exit;
   FCore.DestinationPath := ExpandFileName(FDestination.Text);
   FConfig.Destination := FCore.DestinationPath;
  End;
 If FPage = 4 Then
  Begin
   FInstallSource := SelectedSource;
   FConfig.SourceMode := Ord(FInstallSource);
  End;
 If FPage < 5 Then
  ShowPage(FPage + 1)
 Else
  StartInstall;
end;

procedure TfrmRESTDWInstallerVCL.CancelClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmRESTDWInstallerVCL.FormCloseQueryHandler(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose := MessageDlg('Deseja sair da instalação?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TfrmRESTDWInstallerVCL.BrowseClick(Sender: TObject);
var
 LDirectory: String;
begin
 LDirectory := FDestination.Text;
 If SelectDirectory('Selecione o destino', '', LDirectory) Then
  FDestination.Text := LDirectory;
end;

function TfrmRESTDWInstallerVCL.SelectedSource: TRESTDWInstallSource;
begin
 If Assigned(FSourceCab) And FSourceCab.Checked Then
  FInstallSource := isCab
 Else
  If Assigned(FSourceSVNTrunk) And FSourceSVNTrunk.Checked Then
   FInstallSource := isSVNTrunk
  Else
   If Assigned(FSourceSVNBranch) And FSourceSVNBranch.Checked Then
    FInstallSource := isSVNBranch
   Else
    If Assigned(FSourceLocal) And FSourceLocal.Checked Then
     FInstallSource := isLocal;
 Result := FInstallSource;
end;

function TfrmRESTDWInstallerVCL.RelativeToBase(const AFileName: String): String;
begin
 Result := AFileName;
 If Pos(LowerCase(BaseRoot), LowerCase(Result)) = 1 Then
  Delete(Result, 1, Length(BaseRoot));
end;

function TfrmRESTDWInstallerVCL.PackageSelectedPlatforms(
  const APackage: String): String;
var
 LProject: String;
 LPlatforms: TStringList;
 I: Integer;
begin
 Result := FConfig.GetPackagePlatforms(APackage);
 If (Result <> '') Or FConfig.Loaded Then
  Exit;
 LProject := BaseRoot + APackage;
 If FileExists(ChangeFileExt(LProject, '.dproj')) Then
  LProject := ChangeFileExt(LProject, '.dproj');
 LPlatforms := TStringList.Create;
 Try
  FCore.EnumeratePlatforms(LProject, LPlatforms);
  For I := LPlatforms.Count - 1 Downto 0 Do
   If Not PlatformSupportedBySelectedIDE(LPlatforms[I]) Then
    LPlatforms.Delete(I);
  If LPlatforms.Count = 0 Then
   LPlatforms.Add('Win32');
  Result := LPlatforms.CommaText;
 Finally
  LPlatforms.Free;
 End;
end;

function TfrmRESTDWInstallerVCL.TargetSelected(AIDE: TRESTDWDelphiIDE;
  const AFramework: String): Boolean;
begin
 Result := FSelectedTargets.IndexOf(AIDE.Version + '|' + AFramework) >= 0;
end;

function TfrmRESTDWInstallerVCL.PackageSupportsFramework(const AFileName,
  AFramework: String): Boolean;
var
 LStrings: TStringList;
 LText: String;
begin
 Result := True;
 If Not FileExists(AFileName) Then
  Exit;
 LStrings := TStringList.Create;
 Try
  LStrings.LoadFromFile(AFileName);
  LText := UpperCase(LStrings.Text);
  If Pos('FMX.', LText) > 0 Then
   Result := UpperCase(AFramework) = 'FMX'
  Else
   If Pos('VCL.', LText) > 0 Then
    Result := UpperCase(AFramework) = 'VCL';
 Finally
  LStrings.Free;
 End;
end;

function TfrmRESTDWInstallerVCL.PlatformSupportedBySelectedIDE(
  const APlatform: String): Boolean;
var
 I: Integer;
 LIDE: TRESTDWDelphiIDE;
 LPlatforms: TStringList;
begin
 Result := False;
 LPlatforms := TStringList.Create;
 Try
  For I := 0 To FDelphi.IDEs.Count - 1 Do
   Begin
    LIDE := TRESTDWDelphiIDE(FDelphi.IDEs[I]);
    If (FSelectedTargets.IndexOf(LIDE.Version + '|VCL') < 0) And
       (FSelectedTargets.IndexOf(LIDE.Version + '|FMX') < 0) Then
     Continue;
    FDelphi.EnumerateIDEPlatforms(LIDE, LPlatforms);
    If LPlatforms.IndexOf(APlatform) >= 0 Then
     Begin
      Result := True;
      Exit;
     End;
   End;
 Finally
  LPlatforms.Free;
 End;
end;


procedure TfrmRESTDWInstallerVCL.CoreProgress(AValue, AMaximum: Integer;
  const AText: String);
begin
 If Assigned(FProgress) Then
  Begin
   FProgress.Max := AMaximum;
   FProgress.Position := AValue;
  End;
 If Assigned(FStatus) Then
  FStatus.Caption := AText;
 Application.ProcessMessages;
end;

procedure TfrmRESTDWInstallerVCL.CoreLog(const AText: String);
begin
 If Assigned(FStatus) Then
  FStatus.Caption := AText;
 Application.ProcessMessages;
end;

procedure TfrmRESTDWInstallerVCL.LoadSlides;
var
 LRoot: String;

 procedure AddImages(const APath: String);
 var
  LSearch: TSearchRec;
  LFile: String;
  LExt: String;
 begin
  If Not DirectoryExists(APath) Then
   Exit;
  If FindFirst(IncludeTrailingPathDelimiter(APath) + '*.*', faAnyFile, LSearch) = 0 Then
   Try
    Repeat
     If (LSearch.Name <> '.') And (LSearch.Name <> '..') Then
      Begin
       LFile := IncludeTrailingPathDelimiter(APath) + LSearch.Name;
       If (LSearch.Attr And faDirectory) <> 0 Then
        AddImages(LFile)
       Else
        Begin
         LExt := LowerCase(ExtractFileExt(LFile));
         If (LExt = '.png') Or (LExt = '.jpg') Or (LExt = '.jpeg') Or
            (LExt = '.bmp') Then
          FSlideFiles.Add(LFile);
        End;
      End;
    Until FindNext(LSearch) <> 0;
   Finally
    FindClose(LSearch);
   End;
 end;

begin
 FSlideFiles.Clear;
 LRoot := IncludeTrailingPathDelimiter(FCore.SourcePath) + 'Images\icons';
 AddImages(LRoot + '\package');
 AddImages(LRoot + '\components');
 If (FSlideFiles.Count = 0) And
    FileExists(BaseRoot + 'Installer\Resources\dwScreen.bmp') Then
  FSlideFiles.Add(BaseRoot + 'Installer\Resources\dwScreen.bmp');
end;

procedure TfrmRESTDWInstallerVCL.SlideTimerHandler(Sender: TObject);
begin
 If (FSlideImage = nil) Or (FSlideFiles.Count = 0) Then
  Exit;
 Inc(FSlideIndex);
 If FSlideIndex >= FSlideFiles.Count Then
  FSlideIndex := 0;
 Try
  FSlideImage.Picture.LoadFromFile(FSlideFiles[FSlideIndex]);
 Except
 End;
end;

procedure TfrmRESTDWInstallerVCL.EnumerateDemoProjects(const ARoot: String;
  AList: TStrings);
var
 LSearch: TSearchRec;
 LPath: String;
 LExt: String;
begin
 If Not DirectoryExists(ARoot) Then
  Exit;
 If FindFirst(IncludeTrailingPathDelimiter(ARoot) + '*.*', faAnyFile, LSearch) = 0 Then
  Try
   Repeat
    If (LSearch.Name <> '.') And (LSearch.Name <> '..') Then
     Begin
      LPath := IncludeTrailingPathDelimiter(ARoot) + LSearch.Name;
      If (LSearch.Attr And faDirectory) <> 0 Then
       EnumerateDemoProjects(LPath, AList)
      Else
       Begin
        LExt := LowerCase(ExtractFileExt(LSearch.Name));
        If (LExt = '.dproj') Or (LExt = '.dpr') Then
         If AList.IndexOf(LPath) < 0 Then
          AList.Add(LPath);
       End;
     End;
   Until FindNext(LSearch) <> 0;
  Finally
   FindClose(LSearch);
  End;
end;

procedure TfrmRESTDWInstallerVCL.GenerateProjectGroups(AIDE: TRESTDWDelphiIDE;
  AInstalledProjects: TStrings);
var
 LDemos: TStringList;
 LPackageGroup: String;
 LDemoGroup: String;
begin
 LDemos := TStringList.Create;
 Try
  EnumerateDemoProjects(IncludeTrailingPathDelimiter(FCore.DestinationPath) +
                        'Demos\Delphi', LDemos);
  If AIDE.Version = '7.0' Then
   Begin
    LPackageGroup := IncludeTrailingPathDelimiter(FCore.DestinationPath) +
                     'Packages\RESTDWPackages_Delphi7.bpg';
    LDemoGroup := IncludeTrailingPathDelimiter(FCore.DestinationPath) +
                  'Demos\RESTDWDemos_Delphi7.bpg';
   End
  Else
   Begin
    LPackageGroup := IncludeTrailingPathDelimiter(FCore.DestinationPath) +
                     'Packages\RESTDWPackages_Delphi_' +
                     StringReplace(AIDE.Version, '.', '_', [rfReplaceAll]) + '.groupproj';
    LDemoGroup := IncludeTrailingPathDelimiter(FCore.DestinationPath) +
                  'Demos\RESTDWDemos_Delphi_' +
                  StringReplace(AIDE.Version, '.', '_', [rfReplaceAll]) + '.groupproj';
   End;
  FCore.BuildDelphiProjectGroup(LPackageGroup, AInstalledProjects);
  FCore.BuildDelphiProjectGroup(LDemoGroup, LDemos);
 Finally
  LDemos.Free;
 End;
end;

procedure TfrmRESTDWInstallerVCL.StartInstall;
var
 LIDEName: String;
 LIDE: TRESTDWDelphiIDE;
 LProject: String;
 LPlatforms: TStringList;
 LInstalled: TStringList;
 LBuildProjects: TStringList;
 LVersion: TRESTDWDistributionVersion;
 LValue: String;
 LPlatform: String;
 I: Integer;
 J: Integer;
 K: Integer;
 LFrameworkOK: Boolean;
begin
 CollectSelectedPackages;
 If FDelphi.AnySelectedIDEIsRunning(FSelectedTargets, LIDEName) Then
  Begin
   If MessageDlg(LIDEName + ' está aberto. Deseja que o instalador feche a IDE agora?',
                 mtConfirmation, [mbYes, mbNo], 0) <> mrYes Then
    Exit;
   If Not FDelphi.CloseSelectedIDEs(FSelectedTargets) Then
    Begin
     MessageDlg('Não foi possível fechar todas as IDEs selecionadas.', mtError, [mbOK], 0);
     Exit;
    End;
  End;
 ClearPage;
 FBack.Enabled := False;
 FNext.Enabled := False;
 FCancel.Enabled := False;

 FSlideImage := TImage.Create(Self);
 FSlideImage.Parent := FPagePanel;
 FSlideImage.SetBounds(35, 24, 550, 320);
 FSlideImage.Stretch := True;
 FSlideImage.Proportional := True;

 FStatus := TLabel.Create(Self);
 FStatus.Parent := FPagePanel;
 FStatus.SetBounds(35, 360, 550, 42);
 FStatus.Caption := 'Preparando a instalação...';

 FProgress := TProgressBar.Create(Self);
 FProgress.Parent := FPagePanel;
 FProgress.SetBounds(35, 410, 550, 28);

 FProgress.Max := 100;
 FProgress.Position := 0;
 LoadSlides;
 FSlideIndex := -1;
 FSlideTimer := TTimer.Create(Self);
 FSlideTimer.Interval := 2800;
 FSlideTimer.OnTimer := SlideTimerHandler;
 FSlideTimer.Enabled := True;
 SlideTimerHandler(nil);

 If Not FCore.PrepareSource(SelectedSource) Then
  Begin
   MessageDlg('Não foi possível preparar a fonte da instalação.', mtError, [mbOK], 0);
   FCancel.Enabled := True;
   Exit;
  End;
 LoadSlides;
 SlideTimerHandler(nil);

 If Not FCore.CopyDistribution Then
  Begin
   MessageDlg('Falha ao copiar a distribuição.', mtError, [mbOK], 0);
   FCancel.Enabled := True;
   Exit;
  End;

 LPlatforms := TStringList.Create;
 LInstalled := TStringList.Create;
 LBuildProjects := TStringList.Create;
 Try
  For J := 0 To FSelectedPackages.Count - 1 Do
   LBuildProjects.Add(IncludeTrailingPathDelimiter(FCore.DestinationPath) +
                      FSelectedPackages[J]);
  FCore.SortPackagesByDependencies(LBuildProjects);
  For I := 0 To FDelphi.IDEs.Count - 1 Do
   Begin
    LIDE := TRESTDWDelphiIDE(FDelphi.IDEs[I]);
    If (Not TargetSelected(LIDE, 'VCL')) And (Not TargetSelected(LIDE, 'FMX')) Then
     Continue;
    LInstalled.Clear;
    For J := 0 To LBuildProjects.Count - 1 Do
     Begin
      LProject := LBuildProjects[J];
      LFrameworkOK :=
       (TargetSelected(LIDE, 'VCL') And PackageSupportsFramework(LProject, 'VCL')) Or
       (TargetSelected(LIDE, 'FMX') And PackageSupportsFramework(LProject, 'FMX'));
      If Not LFrameworkOK Then
       Continue;
      LValue := PackageSelectedPlatforms(Copy(LProject,
       Length(IncludeTrailingPathDelimiter(FCore.DestinationPath)) + 1, MaxInt));
      LPlatforms.CommaText := LValue;
      For K := 0 To LPlatforms.Count - 1 Do
       Begin
        LPlatform := Trim(LPlatforms[K]);
        If LPlatform = '' Then
         Continue;
        If Not FDelphi.SupportsPlatform(LIDE, LPlatform) Then
         Continue;
        FProgress.Position := 60 +
                              ((I * LBuildProjects.Count + J + 1) * 30) Div
                              ((FDelphi.IDEs.Count * LBuildProjects.Count) + 1);
        FStatus.Caption := 'Compilando ' + ExtractFileName(LProject) +
                           ' - ' + LIDE.Name + ' - ' + LPlatform;
        Application.ProcessMessages;
        FDelphi.ConfigureSourcePath(LIDE, LPlatform,
                                    IncludeTrailingPathDelimiter(FCore.DestinationPath) + 'Source');
        If Not FDelphi.CompilePackage(LIDE, LProject, LPlatform) Then
         Begin
          MessageDlg('Falha ao compilar ' + LProject + ' para ' + LIDE.Name +
                     ' / ' + LPlatform + '.', mtError, [mbOK], 0);
          FCancel.Enabled := True;
          Exit;
         End;
        FDelphi.RegisterCompiledDesignPackage(LIDE, LProject, LPlatform);
       End;
      If LInstalled.IndexOf(LProject) < 0 Then
       LInstalled.Add(LProject);
     End;
    FProgress.Position := 92;
    FStatus.Caption := 'Gerando grupos de projetos para ' + LIDE.Name + '...';
    Application.ProcessMessages;
    GenerateProjectGroups(LIDE, LInstalled);
   End;
 Finally
  LBuildProjects.Free;
  LInstalled.Free;
  LPlatforms.Free;
 End;

 FProgress.Position := 97;
 FStatus.Caption := 'Finalizando configuração...';
 Application.ProcessMessages;
 FConfig.IDEs.Assign(FSelectedTargets);
 FConfig.SourceMode := Ord(SelectedSource);
 FConfig.Destination := FCore.DestinationPath;
 FConfig.Save;
 FCore.SaveInstallationState;
 LVersion := FCore.ReadDistributionVersion;
 FProgress.Max := 100;
 FProgress.Position := 100;
 FStatus.Caption := 'Instalação concluída - REST Dataware ' + LVersion.FullVersion;
 If LVersion.SVNRevision <> '' Then
  FStatus.Caption := FStatus.Caption + ' - SVN r' + LVersion.SVNRevision;
 MessageDlg('Instalação concluída com sucesso.', mtInformation, [mbOK], 0);
 FCancel.Caption := 'Fechar';
 FCancel.Enabled := True;
end;

end.
