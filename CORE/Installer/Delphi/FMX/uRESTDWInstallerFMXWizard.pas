unit uRESTDWInstallerFMXWizard;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, FMX.Objects, FMX.Edit, FMX.ListBox,
  uRESTDWInstallerCore, uRESTDWInstallerConfig, uRESTDWDelphiInstall;

type
  TRESTDWFMXTarget = class
  public
    IDE: TRESTDWDelphiIDE;
    Framework: String;
  end;

  TfrmRESTDWInstallerFMX = class(TForm)
  private
    FCore: TRESTDWInstallerCore;
    FConfig: TRESTDWInstallerConfig;
    FDelphi: TRESTDWDelphiInstaller;
    FPage: Integer;
    FInstallSource: TRESTDWInstallSource;
    FInstallAction: TRESTDWInstallAction;
    FExistingInstallPath: String;
    FNewInstall: TRadioButton;
    FModifyInstall: TRadioButton;
    FRemoveInstall: TRadioButton;
    FSide: TLayout;
    FSideImage: TImage;
    FContent: TLayout;
    FBottom: TLayout;
    FBack: TSpeedButton;
    FNext: TSpeedButton;
    FCancel: TSpeedButton;
    FTargets: TListBox;
    FPackages: TListBox;
    FPlatforms: TListBox;
    FDestination: TEdit;
    FBrowse: TSpeedButton;
    FSourceLocal: TRadioButton;
    FSourceCab: TRadioButton;
    FSourceTrunk: TRadioButton;
    FSourceBranch: TRadioButton;
    FProgress: TProgressBar;
    FStatus: TLabel;
    FSlide: TImage;
    FSlideTimer: TTimer;
    FSlideFiles: TStringList;
    FSlideIndex: Integer;
    FSelectedTargets: TStringList;
    FSelectedPackages: TStringList;
    FPackageFiles: TStringList;
    FCurrentPackage: Integer;
    procedure BuildChrome;
    procedure ClearContent;
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
    procedure FormCloseQueryHandler(Sender: TObject; var CanClose: Boolean);
    procedure PackageClick(Sender: TObject);
    procedure SlideTimerHandler(Sender: TObject);
    procedure CoreProgress(AValue, AMaximum: Integer; const AText: String);
    procedure CoreLog(const AText: String);
    procedure SavePackagePlatforms;
    procedure LoadPackagePlatforms(AIndex: Integer);
    procedure CollectTargets;
    procedure CollectPackages;
    procedure StartInstall;
    procedure LoadSlides;
    procedure EnumerateDemoProjects(const ARoot: String; AList: TStrings);
    procedure GenerateProjectGroups(AIDE: TRESTDWDelphiIDE; AInstalledProjects: TStrings);
    function BaseRoot: String;
    function RelativeToBase(const AFileName: String): String;
    function SelectedSource: TRESTDWInstallSource;
    function PackagePlatforms(const APackage: String): String;
    function PackageIconFile(const AName: String): String;
    function PlatformIconFile(const AName: String): String;
    procedure AddItemIcon(AItem: TListBoxItem; const AFileName: String);
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
  frmRESTDWInstallerFMX: TfrmRESTDWInstallerFMX;

implementation

constructor TfrmRESTDWInstallerFMX.Create(AOwner: TComponent);
begin
 inherited CreateNew(AOwner);
 Caption := 'REST Dataware Installer - Delphi FMX';
 Width := 1100;
 Height := 650;
 Position := TFormPosition.ScreenCenter;
 FSlideFiles := TStringList.Create;
 FSelectedTargets := TStringList.Create;
 FSelectedPackages := TStringList.Create;
 FPackageFiles := TStringList.Create;
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

destructor TfrmRESTDWInstallerFMX.Destroy;
begin
 FDelphi.Free;
 FConfig.Free;
 FCore.Free;
 FPackageFiles.Free;
 FSelectedPackages.Free;
 FSelectedTargets.Free;
 FSlideFiles.Free;
 inherited Destroy;
end;

function TfrmRESTDWInstallerFMX.BaseRoot: String;
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

procedure TfrmRESTDWInstallerFMX.BuildChrome;
begin
 FSide := TLayout.Create(Self);
 FSide.Parent := Self;
 FSide.Align := TAlignLayout.Left;
 FSide.Width := 300;

 FSideImage := TImage.Create(Self);
 FSideImage.Parent := FSide;
 FSideImage.Align := TAlignLayout.Client;
 FSideImage.WrapMode := TImageWrapMode.Fit;
 If FileExists(BaseRoot + 'Installer\Resources\dwScreen.bmp') Then
  FSideImage.Bitmap.LoadFromFile(BaseRoot + 'Installer\Resources\dwScreen.bmp');

 FBottom := TLayout.Create(Self);
 FBottom.Parent := Self;
 FBottom.Align := TAlignLayout.Bottom;
 FBottom.Height := 64;

 FBack := TSpeedButton.Create(Self);
 FBack.Parent := FBottom;
 FBack.Text := '< Voltar';
 FBack.SetBounds(740, 15, 105, 34);
 FBack.OnClick := BackClick;

 FNext := TSpeedButton.Create(Self);
 FNext.Parent := FBottom;
 FNext.Text := 'Avançar >';
 FNext.SetBounds(852, 15, 105, 34);
 FNext.OnClick := NextClick;

 FCancel := TSpeedButton.Create(Self);
 FCancel.Parent := FBottom;
 FCancel.Text := 'Cancelar';
 FCancel.SetBounds(964, 15, 105, 34);
 FCancel.OnClick := CancelClick;

 FContent := TLayout.Create(Self);
 FContent.Parent := Self;
 FContent.Align := TAlignLayout.Client;
end;

procedure TfrmRESTDWInstallerFMX.ClearContent;
var
 I: Integer;
begin
 If Assigned(FSlideTimer) Then
  FreeAndNil(FSlideTimer);
 For I := FContent.ChildrenCount - 1 Downto 0 Do
  FContent.Children[I].Free;
 FTargets := nil;
 FPackages := nil;
 FPlatforms := nil;
 FDestination := nil;
 FBrowse := nil;
 FSourceLocal := nil;
 FSourceCab := nil;
 FSourceTrunk := nil;
 FSourceBranch := nil;
 FProgress := nil;
 FStatus := nil;
 FSlide := nil;
end;

procedure TfrmRESTDWInstallerFMX.ShowPage(APage: Integer);
begin
 ClearContent;
 FPage := APage;
 FBack.Enabled := FPage > 0;
 FNext.Enabled := True;
 FNext.Text := 'Avançar >';
 Case FPage Of
  0: ShowWelcome;
  1: ShowTargets;
  2: ShowPackages;
  3: ShowDestination;
  4: ShowSource;
  5: ShowReady;
 End;
end;


procedure TfrmRESTDWInstallerFMX.ShowWelcome;
var
 LTitle : TLabel;
 LInfo  : TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FContent;
 LTitle.Text := 'Bem vindo a Instalação do REST Dataware';
 LTitle.TextSettings.Font.Size := 22;
 LTitle.SetBounds(32, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FContent;
 LInfo.WordWrap := True;
 If FExistingInstallPath = '' Then
  LInfo.Text := 'Nenhuma instalação do REST Dataware foi localizada neste computador.'
 Else
  LInfo.Text := 'Foi localizada uma instalação do REST Dataware em: ' +
                FExistingInstallPath;
 LInfo.SetBounds(32, 76, 730, 58);

 FNewInstall := TRadioButton.Create(Self);
 FNewInstall.Parent := FContent;
 FNewInstall.Text := 'Nova instalação';
 FNewInstall.SetBounds(52, 160, 600, 30);

 If FExistingInstallPath <> '' Then
  Begin
   FNewInstall.Visible := False;
   FModifyInstall := TRadioButton.Create(Self);
   FModifyInstall.Parent := FContent;
   FModifyInstall.Text := 'Modificar instalação';
   FModifyInstall.IsChecked := True;
   FModifyInstall.SetBounds(52, 160, 600, 30);

   FRemoveInstall := TRadioButton.Create(Self);
   FRemoveInstall.Parent := FContent;
   FRemoveInstall.Text := 'Remover';
   FRemoveInstall.SetBounds(52, 204, 600, 30);
  End
 Else
  FNewInstall.IsChecked := True;
end;

procedure TfrmRESTDWInstallerFMX.ShowTargets;
var
 LTitle: TLabel;
 LInfo: TLabel;
 LIDE: TRESTDWDelphiIDE;
 LItem: TListBoxItem;
 LTarget: TRESTDWFMXTarget;
 I: Integer;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FContent;
 LTitle.Text := 'Selecione o Delphi';
 LTitle.TextSettings.Font.Size := 22;
 LTitle.SetBounds(32, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FContent;
 LInfo.Text := 'Selecione as versões do Delphi e os frameworks VCL/FMX.';
 LInfo.SetBounds(32, 72, 730, 42);

 FTargets := TListBox.Create(Self);
 FTargets.Parent := FContent;
 FTargets.ShowCheckboxes := True;
 FTargets.SetBounds(32, 108, 730, 388);
 For I := 0 To FDelphi.IDEs.Count - 1 Do
  Begin
   LIDE := TRESTDWDelphiIDE(FDelphi.IDEs[I]);
   If LIDE.SupportsVCL Then
    Begin
     LItem := TListBoxItem.Create(FTargets);
     LItem.Parent := FTargets;
     LItem.Text := LIDE.Name + ' - VCL';
     AddItemIcon(LItem,
                 BaseRoot + 'Installer\Resources\InstallerIcons\ide_delphi.bmp');
     LItem.IsChecked := (Not FConfig.Loaded) Or
                        (FConfig.IDEs.IndexOf(LIDE.Version + '|VCL') >= 0);
     LTarget := TRESTDWFMXTarget.Create;
     LTarget.IDE := LIDE;
     LTarget.Framework := 'VCL';
     LItem.TagObject := LTarget;
    End;
   If LIDE.SupportsFMX Then
    Begin
     LItem := TListBoxItem.Create(FTargets);
     LItem.Parent := FTargets;
     LItem.Text := LIDE.Name + ' - FMX';
     AddItemIcon(LItem,
                 BaseRoot + 'Installer\Resources\InstallerIcons\ide_delphi.bmp');
     LItem.IsChecked := (Not FConfig.Loaded) Or
                        (FConfig.IDEs.IndexOf(LIDE.Version + '|FMX') >= 0);
     LTarget := TRESTDWFMXTarget.Create;
     LTarget.IDE := LIDE;
     LTarget.Framework := 'FMX';
     LItem.TagObject := LTarget;
    End;
  End;
end;

procedure TfrmRESTDWInstallerFMX.AddItemIcon(AItem: TListBoxItem;
  const AFileName: String);
var
 LImage: TImage;
begin
 If (AItem = nil) Or Not FileExists(AFileName) Then
  Exit;

 AItem.Height := 30;
 AItem.TextSettings.HorzAlign := TTextAlign.Leading;
 AItem.Text := '          ' + TrimLeft(AItem.Text);

 LImage := TImage.Create(AItem);
 LImage.Parent := AItem;
 LImage.SetBounds(28, 3, 24, 24);
 LImage.HitTest := False;
 LImage.WrapMode := TImageWrapMode.Fit;
 LImage.Bitmap.LoadFromFile(AFileName);
end;

function TfrmRESTDWInstallerFMX.PackageIconFile(const AName: String): String;
var
 LName: String;
 LFile: String;
begin
 LName := LowerCase(AName);
 If Pos('native', LName) > 0 Then
  LFile := 'pkg_native.bmp'
 Else If (Pos('driver', LName) > 0) Or (Pos('dac', LName) > 0) Or
         (Pos('zeos', LName) > 0) Or (Pos('fire', LName) > 0) Then
  LFile := 'pkg_database.bmp'
 Else If (Pos('client', LName) > 0) Or (Pos('pooler', LName) > 0) Then
  LFile := 'pkg_client.bmp'
 Else If Pos('report', LName) > 0 Then
  LFile := 'pkg_report.bmp'
 Else If (Pos('html', LName) > 0) Or (Pos('web', LName) > 0) Then
  LFile := 'pkg_web.bmp'
 Else If (Pos('design', LName) > 0) Or (Pos('visual', LName) > 0) Or
         (Pos('component', LName) > 0) Then
  LFile := 'pkg_visual.bmp'
 Else If (Pos('tool', LName) > 0) Or (Pos('util', LName) > 0) Then
  LFile := 'pkg_tools.bmp'
 Else
  LFile := 'pkg_core.bmp';
 Result := BaseRoot + 'Installer\Resources\InstallerIcons\' + LFile;
end;

function TfrmRESTDWInstallerFMX.PlatformIconFile(const AName: String): String;
var
 LName: String;
 LFile: String;
begin
 LName := LowerCase(AName);
 If Pos('win', LName) > 0 Then
  LFile := 'os_windows.bmp'
 Else If Pos('linux', LName) > 0 Then
  LFile := 'os_linux.bmp'
 Else If Pos('android', LName) > 0 Then
  LFile := 'os_android.bmp'
 Else If Pos('ios', LName) > 0 Then
  LFile := 'os_ios.bmp'
 Else If (Pos('osx', LName) > 0) Or (Pos('mac', LName) > 0) Then
  LFile := 'os_macos.bmp'
 Else
  LFile := 'os_fpc.bmp';
 Result := BaseRoot + 'Installer\Resources\InstallerIcons\' + LFile;
end;

procedure TfrmRESTDWInstallerFMX.ShowPackages;
var
 LTitle: TLabel;
 LInfo: TLabel;
 LList: TStringList;
 LItem: TListBoxItem;
 LRelative: String;
 LIcon: String;
 I: Integer;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FContent;
 LTitle.Text := 'Pacotes e plataformas';
 LTitle.TextSettings.Font.Size := 22;
 LTitle.SetBounds(32, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FContent;
 LInfo.AutoSize := False;
 LInfo.WordWrap := True;
 LInfo.Text := 'Selecione os pacotes na ordem de instalação. Para cada pacote, escolha as plataformas.';
 LInfo.SetBounds(32, 70, 730, 42);

 FPackages := TListBox.Create(Self);
 FPackages.Parent := FContent;
 FPackages.ShowCheckboxes := True;
 FPackages.SetBounds(32, 122, 500, 410);
 FPackages.OnChange := PackageClick;

 FPlatforms := TListBox.Create(Self);
 FPlatforms.Parent := FContent;
 FPlatforms.ShowCheckboxes := True;
 FPlatforms.SetBounds(550, 122, 216, 410);

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
    LItem := TListBoxItem.Create(FPackages);
    LItem.Text := Format('%.2d  %s',
                         [I + 1,
                          ChangeFileExt(ExtractFileName(LRelative), '')]);
    LItem.Parent := FPackages;
    LItem.IsChecked := (Not FConfig.Loaded) Or
                       (FConfig.GetPackagePlatforms(LRelative) <> '');
    LIcon := PackageIconFile(LRelative);
    AddItemIcon(LItem, LIcon);
   End;
 Finally
  LList.Free;
 End;
 If FPackages.Count > 0 Then
  Begin
   FPackages.ItemIndex := 0;
   FCurrentPackage := 0;
   LoadPackagePlatforms(0);
  End;
end;

procedure TfrmRESTDWInstallerFMX.SavePackagePlatforms;
var
 LValue: String;
 LItem: TListBoxItem;
 I: Integer;
begin
 If (FCurrentPackage < 0) Or (FPackages = nil) Or (FPlatforms = nil) Then
  Exit;
 LValue := '';
 For I := 0 To FPlatforms.Count - 1 Do
  Begin
   LItem := FPlatforms.ListItems[I];
   If LItem.IsChecked Then
    Begin
     If LValue <> '' Then
      LValue := LValue + ',';
     LValue := LValue + Trim(LItem.Text);
    End;
  End;
 If FPackages.ListItems[FCurrentPackage].IsChecked Then
  FConfig.SetPackagePlatforms(FPackageFiles[FCurrentPackage], LValue)
 Else
  FConfig.SetPackagePlatforms(FPackageFiles[FCurrentPackage], '');
end;

procedure TfrmRESTDWInstallerFMX.LoadPackagePlatforms(AIndex: Integer);
var
 LProject: String;
 LList: TStringList;
 LSaved: String;
 LItem: TListBoxItem;
 I: Integer;
begin
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
     LItem := TListBoxItem.Create(FPlatforms);
     LItem.Parent := FPlatforms;
     LItem.Text := LList[I];
      AddItemIcon(LItem, PlatformIconFile(LList[I]));
     If Not FConfig.Loaded Then
      LItem.IsChecked := True
     Else
      LItem.IsChecked := Pos(',' + LList[I] + ',', ',' + LSaved + ',') > 0;
    End;
 Finally
  LList.Free;
 End;
end;

procedure TfrmRESTDWInstallerFMX.PackageClick(Sender: TObject);
begin
 SavePackagePlatforms;
 FCurrentPackage := FPackages.ItemIndex;
 If FCurrentPackage >= 0 Then
  LoadPackagePlatforms(FCurrentPackage);
end;

procedure TfrmRESTDWInstallerFMX.ShowDestination;
var
 LTitle: TLabel;
 LInfo: TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FContent;
 LTitle.Text := 'Diretório de destino';
 LTitle.TextSettings.Font.Size := 22;
 LTitle.SetBounds(32, 28, 730, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FContent;
 LInfo.AutoSize := False;
 LInfo.WordWrap := True;
 LInfo.Text := 'A pasta Source instalada será usada para configurar o Library Path dos Delphis selecionados.';
 LInfo.SetBounds(32, 78, 700, 56);

 FDestination := TEdit.Create(Self);
 FDestination.Parent := FContent;
 FDestination.SetBounds(32, 150, 535, 34);
 If FExistingInstallPath <> '' Then
  FDestination.Text := FExistingInstallPath
 Else If FConfig.Destination <> '' Then
  FDestination.Text := FConfig.Destination
 Else
  FDestination.Text := ExpandFileName(BaseRoot + '..\RESTDataware');

 FBrowse := TSpeedButton.Create(Self);
 FBrowse.Parent := FContent;
 FBrowse.Text := '...';
 FBrowse.SetBounds(580, 150, 48, 34);
 FBrowse.OnClick := BrowseClick;
end;

procedure TfrmRESTDWInstallerFMX.ShowSource;
var
 LTitle: TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FContent;
 LTitle.Text := 'Fonte da instalação';
 LTitle.TextSettings.Font.Size := 22;
 LTitle.SetBounds(32, 28, 560, 36);

 FSourceLocal := TRadioButton.Create(Self);
 FSourceLocal.Parent := FContent;
 FSourceLocal.Text := 'Local - pastas da distribuição';
 FSourceLocal.SetBounds(32, 92, 540, 30);

 FSourceCab := TRadioButton.Create(Self);
 FSourceCab.Parent := FContent;
 FSourceCab.Text := 'CORE.CAB / CORE.tar.gz';
 FSourceCab.SetBounds(32, 132, 540, 30);
 FSourceCab.Enabled := FileExists(BaseRoot + 'CORE.CAB') Or FileExists(BaseRoot + 'CORE.tar.gz');

 FSourceTrunk := TRadioButton.Create(Self);
 FSourceTrunk.Parent := FContent;
 FSourceTrunk.Text := 'SVN - Trunk (Versão estável)';
 FSourceTrunk.SetBounds(32, 172, 540, 30);

 FSourceBranch := TRadioButton.Create(Self);
 FSourceBranch.Parent := FContent;
 FSourceBranch.Text := 'SVN - Branch (Desenvolvimento)';
 FSourceBranch.SetBounds(32, 212, 540, 30);

 Case Ord(FInstallSource) Of
  1:
   Begin
    If FSourceCab.Enabled Then
     FSourceCab.IsChecked := True
    Else
     FSourceLocal.IsChecked := True;
   End;
  2: FSourceTrunk.IsChecked := True;
  3: FSourceBranch.IsChecked := True;
 Else
  If FSourceCab.Enabled Then
   FSourceCab.IsChecked := True
  Else
   FSourceLocal.IsChecked := True;
 End;
end;

procedure TfrmRESTDWInstallerFMX.ShowReady;
var
 LTitle: TLabel;
 LInfo: TLabel;
begin
 LTitle := TLabel.Create(Self);
 LTitle.Parent := FContent;
 LTitle.Text := 'Pronto para instalar';
 LTitle.TextSettings.Font.Size := 22;
 LTitle.SetBounds(32, 28, 560, 36);

 LInfo := TLabel.Create(Self);
 LInfo.Parent := FContent;
 LInfo.AutoSize := False;
 LInfo.Text :=
  'A IDE será verificada, os dados serão copiados e os pacotes serão compilados com cada Delphi selecionado.';
 LInfo.WordWrap := True;
 LInfo.SetBounds(32, 82, 700, 120);
 FNext.Text := 'Iniciar';
end;

procedure TfrmRESTDWInstallerFMX.BackClick(Sender: TObject);
begin
 If FPage = 2 Then
  SavePackagePlatforms;
 If FPage > 0 Then
  ShowPage(FPage - 1);
end;

procedure TfrmRESTDWInstallerFMX.CollectTargets;
var
 LItem: TListBoxItem;
 LTarget: TRESTDWFMXTarget;
 I: Integer;
begin
 FSelectedTargets.Clear;
 For I := 0 To FTargets.Count - 1 Do
  Begin
   LItem := FTargets.ListItems[I];
   If LItem.IsChecked Then
    Begin
     LTarget := TRESTDWFMXTarget(LItem.TagObject);
     FSelectedTargets.Add(LTarget.IDE.Version + '|' + LTarget.Framework);
    End;
  End;
end;

procedure TfrmRESTDWInstallerFMX.CollectPackages;
var
 LItem: TListBoxItem;
 I: Integer;
begin
 SavePackagePlatforms;
 FSelectedPackages.Clear;
 For I := 0 To FPackages.Count - 1 Do
  Begin
   LItem := FPackages.ListItems[I];
   If LItem.IsChecked Then
    FSelectedPackages.Add(LItem.Text);
  End;
end;

procedure TfrmRESTDWInstallerFMX.NextClick(Sender: TObject);
var
 I : Integer;
begin
 If FPage = 0 Then
  Begin
   If FExistingInstallPath = '' Then
    FInstallAction := iaNewInstall
   Else
    If Assigned(FRemoveInstall) And FRemoveInstall.IsChecked Then
     FInstallAction := iaRemoveInstall
    Else
     FInstallAction := iaModifyInstall;
   If FInstallAction = iaRemoveInstall Then
    Begin
     If MessageDlg('Deseja remover a instalação do REST Dataware?', TMsgDlgType.mtConfirmation,
                   [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes Then
      Exit;
     For I := 0 To FDelphi.IDEs.Count - 1 Do
      FDelphi.RemoveInstallation(TRESTDWDelphiIDE(FDelphi.IDEs[I]),
                                FExistingInstallPath);
     If FCore.RemoveInstalledDistribution Then
      Begin
       MessageDlg('REST Dataware removido com sucesso.', TMsgDlgType.mtInformation,
                  [TMsgDlgBtn.mbOK], 0);
       Close;
      End
     Else
      MessageDlg('Não foi possível remover a instalação do REST Dataware.',
                 TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
     Exit;
    End;
  End;
 If FPage = 1 Then
  Begin
   CollectTargets;
   If FSelectedTargets.Count = 0 Then
    Begin
     MessageDlg('Selecione pelo menos um Delphi/framework.', TMsgDlgType.mtWarning,
                [TMsgDlgBtn.mbOK], 0);
     Exit;
    End;
  End;
 If FPage = 2 Then
  Begin
   CollectPackages;
   If FSelectedPackages.Count = 0 Then
    Begin
     MessageDlg('Selecione pelo menos um pacote.', TMsgDlgType.mtWarning,
                [TMsgDlgBtn.mbOK], 0);
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

procedure TfrmRESTDWInstallerFMX.CancelClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmRESTDWInstallerFMX.FormCloseQueryHandler(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose := MessageDlg('Deseja sair da instalação?',
                        TMsgDlgType.mtConfirmation,
                        [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes;
end;

procedure TfrmRESTDWInstallerFMX.BrowseClick(Sender: TObject);
var
 LDirectory: String;
begin
 LDirectory := FDestination.Text;
 If SelectDirectory('Selecione o destino', '', LDirectory) Then
  FDestination.Text := LDirectory;
end;

function TfrmRESTDWInstallerFMX.SelectedSource: TRESTDWInstallSource;
begin
 If Assigned(FSourceCab) And FSourceCab.IsChecked Then
  FInstallSource := isCab
 Else
  If Assigned(FSourceTrunk) And FSourceTrunk.IsChecked Then
   FInstallSource := isSVNTrunk
  Else
   If Assigned(FSourceBranch) And FSourceBranch.IsChecked Then
    FInstallSource := isSVNBranch
   Else
    If Assigned(FSourceLocal) And FSourceLocal.IsChecked Then
     FInstallSource := isLocal;
 Result := FInstallSource;
end;

function TfrmRESTDWInstallerFMX.RelativeToBase(const AFileName: String): String;
begin
 Result := AFileName;
 If Pos(LowerCase(BaseRoot), LowerCase(Result)) = 1 Then
  Delete(Result, 1, Length(BaseRoot));
end;

function TfrmRESTDWInstallerFMX.PackagePlatforms(const APackage: String): String;
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

function TfrmRESTDWInstallerFMX.TargetSelected(AIDE: TRESTDWDelphiIDE;
  const AFramework: String): Boolean;
begin
 Result := FSelectedTargets.IndexOf(AIDE.Version + '|' + AFramework) >= 0;
end;

function TfrmRESTDWInstallerFMX.PackageSupportsFramework(const AFileName,
  AFramework: String): Boolean;
var
 L: TStringList;
 LText: String;
begin
 Result := True;
 If Not FileExists(AFileName) Then
  Exit;
 L := TStringList.Create;
 Try
  L.LoadFromFile(AFileName);
  LText := UpperCase(L.Text);
  If Pos('FMX.', LText) > 0 Then
   Result := SameText(AFramework, 'FMX')
  Else
   If Pos('VCL.', LText) > 0 Then
    Result := SameText(AFramework, 'VCL');
 Finally
  L.Free;
 End;
end;

function TfrmRESTDWInstallerFMX.PlatformSupportedBySelectedIDE(
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


procedure TfrmRESTDWInstallerFMX.LoadSlides;
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

procedure TfrmRESTDWInstallerFMX.SlideTimerHandler(Sender: TObject);
begin
 If (FSlide = nil) Or (FSlideFiles.Count = 0) Then
  Exit;
 Inc(FSlideIndex);
 If FSlideIndex >= FSlideFiles.Count Then
  FSlideIndex := 0;
 If FileExists(FSlideFiles[FSlideIndex]) Then
  FSlide.Bitmap.LoadFromFile(FSlideFiles[FSlideIndex]);
end;

procedure TfrmRESTDWInstallerFMX.CoreProgress(AValue, AMaximum: Integer;
  const AText: String);
begin
 If Assigned(FProgress) Then
  Begin
   FProgress.Max := AMaximum;
   FProgress.Value := AValue;
  End;
 If Assigned(FStatus) Then
  FStatus.Text := AText;
 Application.ProcessMessages;
end;

procedure TfrmRESTDWInstallerFMX.CoreLog(const AText: String);
begin
 If Assigned(FStatus) Then
  FStatus.Text := AText;
 Application.ProcessMessages;
end;

procedure TfrmRESTDWInstallerFMX.EnumerateDemoProjects(const ARoot: String;
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

procedure TfrmRESTDWInstallerFMX.GenerateProjectGroups(AIDE: TRESTDWDelphiIDE;
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

procedure TfrmRESTDWInstallerFMX.StartInstall;
var
 LIDEName: String;
 LIDE: TRESTDWDelphiIDE;
 LProject: String;
 LPlatforms: TStringList;
 LValue: String;
 LPlatform: String;
 LVersion: TRESTDWDistributionVersion;
 LBuildProjects: TStringList;
 LInstalled: TStringList;
 LFrameworkOK: Boolean;
 I: Integer;
 J: Integer;
 K: Integer;
begin
 CollectPackages;
 If FDelphi.AnySelectedIDEIsRunning(FSelectedTargets, LIDEName) Then
  Begin
   If MessageDlg(LIDEName + ' está aberto. Deseja que o instalador feche a IDE?',
                 TMsgDlgType.mtConfirmation,
                 [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes Then
    Exit;
   If Not FDelphi.CloseSelectedIDEs(FSelectedTargets) Then
    Begin
     ShowMessage('Não foi possível fechar todas as IDEs selecionadas.');
     Exit;
    End;
  End;
 ClearContent;
 FBack.Enabled := False;
 FNext.Enabled := False;
 FCancel.Enabled := False;

 FSlide := TImage.Create(Self);
 FSlide.Parent := FContent;
 FSlide.SetBounds(32, 22, 550, 320);
 FSlide.WrapMode := TImageWrapMode.Fit;

 FStatus := TLabel.Create(Self);
 FStatus.Parent := FContent;
 FStatus.SetBounds(32, 356, 550, 42);
 FStatus.Text := 'Preparando instalação...';

 FProgress := TProgressBar.Create(Self);
 FProgress.Parent := FContent;
 FProgress.SetBounds(32, 410, 550, 28);

 FProgress.Max := 100;
 FProgress.Value := 0;
 LoadSlides;
 FSlideIndex := -1;
 FSlideTimer := TTimer.Create(Self);
 FSlideTimer.Interval := 2800;
 FSlideTimer.OnTimer := SlideTimerHandler;
 FSlideTimer.Enabled := True;
 SlideTimerHandler(nil);

 If Not FCore.PrepareSource(SelectedSource) Then
  Begin
   ShowMessage('Não foi possível preparar a fonte da instalação.');
   FCancel.Enabled := True;
   Exit;
  End;
 LoadSlides;
 SlideTimerHandler(nil);

 If Not FCore.CopyDistribution Then
  Begin
   ShowMessage('Falha ao copiar a distribuição.');
   FCancel.Enabled := True;
   Exit;
  End;

 LPlatforms := TStringList.Create;
 LBuildProjects := TStringList.Create;
 LInstalled := TStringList.Create;
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
      LValue := PackagePlatforms(Copy(LProject,
       Length(IncludeTrailingPathDelimiter(FCore.DestinationPath)) + 1, MaxInt));
      LPlatforms.CommaText := LValue;
      For K := 0 To LPlatforms.Count - 1 Do
       Begin
        LPlatform := Trim(LPlatforms[K]);
        If LPlatform = '' Then
         Continue;
        If Not FDelphi.SupportsPlatform(LIDE, LPlatform) Then
         Continue;
        FProgress.Value := 60 +
                           ((I * LBuildProjects.Count + J + 1) * 30) Div
                           ((FDelphi.IDEs.Count * LBuildProjects.Count) + 1);
        FStatus.Text := 'Compilando ' + ExtractFileName(LProject) + ' - ' +
                        LIDE.Name + ' - ' + LPlatform;
        Application.ProcessMessages;
        FDelphi.ConfigureSourcePath(LIDE, LPlatform,
                                    IncludeTrailingPathDelimiter(FCore.DestinationPath) + 'Source');
        If Not FDelphi.CompilePackage(LIDE, LProject, LPlatform) Then
         Begin
          ShowMessage('Falha ao compilar ' + ExtractFileName(LProject) + '.');
          FCancel.Enabled := True;
          Exit;
         End;
        FDelphi.RegisterCompiledDesignPackage(LIDE, LProject, LPlatform);
       End;
      If LInstalled.IndexOf(LProject) < 0 Then
       LInstalled.Add(LProject);
     End;
    FProgress.Value := 92;
    FStatus.Text := 'Gerando grupos de projetos para ' + LIDE.Name + '...';
    Application.ProcessMessages;
    GenerateProjectGroups(LIDE, LInstalled);
   End;
 Finally
  LInstalled.Free;
  LBuildProjects.Free;
  LPlatforms.Free;
 End;

 FProgress.Value := 97;
 FStatus.Text := 'Finalizando configuração...';
 Application.ProcessMessages;
 FConfig.IDEs.Assign(FSelectedTargets);
 FConfig.SourceMode := Ord(SelectedSource);
 FConfig.Destination := FCore.DestinationPath;
 FConfig.Save;
 FCore.SaveInstallationState;
 LVersion := FCore.ReadDistributionVersion;
 FProgress.Max := 100;
 FProgress.Value := 100;
 FStatus.Text := 'Instalação concluída - REST Dataware ' + LVersion.FullVersion;
 If LVersion.SVNRevision <> '' Then
  FStatus.Text := FStatus.Text + ' - SVN r' + LVersion.SVNRevision;
 ShowMessage('Instalação concluída com sucesso.');
 FCancel.Text := 'Fechar';
 FCancel.Enabled := True;
end;

end.
