unit uRESTDWLazarusWizard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, CheckLst, ImgList, Buttons, FileUtil, uRESTDWInstallerCore, uRESTDWInstallerConfig,
  uRESTDWLazarusInstall;

type
  TfrmRESTDWInstaller = class(TForm)
  private
    FCore: TRESTDWInstallerCore;
    FConfig: TRESTDWInstallerConfig;
    FLazarus: TRESTDWLazarusInstaller;
    FPage: Integer;
    FInstallSource: TRESTDWInstallSource;
    FInstallAction: TRESTDWInstallAction;
    FExistingInstallPath: String;
    FNewInstall: TRadioButton;
    FModifyInstall: TRadioButton;
    FRemoveInstall: TRadioButton;
    FPagePanel: TPanel;
    FSidePanel: TPanel;
    FSideImage: TImage;
    FTitle: TLabel;
    FDescription: TLabel;
    FBack: TSpeedButton;
    FNext: TSpeedButton;
    FCancel: TSpeedButton;
    FPackages: TScrollBox;
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
    FSelectedPackages: TStringList;
    FPackageFiles: TStringList;
    FPackageCheckBoxes: TList;
    FInstallerImages: TImageList;
    FCurrentPackage: Integer;
    procedure BuildChrome;
    procedure ClearPage;
    procedure ShowPage(APage: Integer);
    procedure ShowWelcome;
    procedure ShowLazarusInfo;
    procedure ShowPackages;
    procedure ShowDestination;
    procedure ShowSource;
    procedure ShowReady;
    procedure StartInstall;
    procedure LoadSideImage;
    procedure LoadSlides;
    function PackagePlatforms(const APackage: String): String;
    procedure BackClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure LoadInstallerImages;
    function PackageIconIndex(const AName: String): Integer;
    function PlatformIconIndex(const AName: String): Integer;
    procedure SlideTimer(Sender: TObject);
    procedure CoreProgress(AValue, AMaximum: Integer; const AText: String);
    procedure CoreLog(const AText: String);
    function SelectedSource: TRESTDWInstallSource;
    function BaseRoot: String;
    function RelativeToBase(const AFileName: String): String;
    procedure FormCloseQueryHandler(Sender: TObject; var CanClose: Boolean);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmRESTDWInstaller: TfrmRESTDWInstaller;

implementation

constructor TfrmRESTDWInstaller.Create(TheOwner: TComponent);
begin
 inherited Create(TheOwner);
 Caption := 'REST Dataware Installer - Lazarus';
 ClientWidth := 1100;
 ClientHeight := 650;
 Position := poScreenCenter;
 BorderStyle := bsDialog;
 FSelectedPackages := TStringList.Create;
 FPackageFiles := TStringList.Create;
 FPackageCheckBoxes := TList.Create;
 FInstallerImages := TImageList.Create(Self);
 LoadInstallerImages;
 FSlideFiles := TStringList.Create;
 FCore := TRESTDWInstallerCore.Create(BaseRoot);
 FConfig := TRESTDWInstallerConfig.Create(BaseRoot + 'RESTDWInstaller.ini');
 FConfig.Load;
 FCore.OnProgress := @CoreProgress;
 FCore.OnLog := @CoreLog;
 FLazarus := TRESTDWLazarusInstaller.Create(FCore);
 BuildChrome;
 OnCloseQuery := @FormCloseQueryHandler;
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
 FPage := 0;
 ShowPage(FPage);
end;

destructor TfrmRESTDWInstaller.Destroy;
begin
 FLazarus.Free;
 FConfig.Free;
 FCore.Free;
 FSlideFiles.Free;
 FPackageCheckBoxes.Free;
 FPackageFiles.Free;
 FSelectedPackages.Free;
 inherited Destroy;
end;

function TfrmRESTDWInstaller.BaseRoot: String;
var
 LPath: String;
begin
 LPath := ExpandFileName(ExtractFilePath(ParamStr(0)));
 If DirectoryExists(LPath + 'Source') Or FileExists(LPath + 'CORE.CAB') Or
    FileExists(LPath + 'CORE.tar.gz') Then
  Result := IncludeTrailingPathDelimiter(LPath)
 Else
  Result := ExpandFileName(LPath + '..' + PathDelim + '..' + PathDelim);
end;

procedure TfrmRESTDWInstaller.BuildChrome;
var
 LBottom: TPanel;
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
 LoadSideImage;

 LBottom := TPanel.Create(Self);
 LBottom.Parent := Self;
 LBottom.Align := alBottom;
 LBottom.Height := 64;
 LBottom.BevelOuter := bvNone;

 FBack := TSpeedButton.Create(Self);
 FBack.Parent := LBottom;
 FBack.Caption := '< Voltar';
 FBack.SetBounds(740, 15, 105, 34);
 FBack.OnClick := @BackClick;

 FNext := TSpeedButton.Create(Self);
 FNext.Parent := LBottom;
 FNext.Caption := 'Avançar >';
 FNext.SetBounds(852, 15, 105, 34);
 FNext.OnClick := @NextClick;

 FCancel := TSpeedButton.Create(Self);
 FCancel.Parent := LBottom;
 FCancel.Caption := 'Cancelar';
 FCancel.SetBounds(964, 15, 105, 34);
 FCancel.OnClick := @CancelClick;

 FPagePanel := TPanel.Create(Self);
 FPagePanel.Parent := Self;
 FPagePanel.Align := alClient;
 FPagePanel.BevelOuter := bvNone;
end;

procedure TfrmRESTDWInstaller.LoadSideImage;
var
 LFile: String;
begin
 LFile := BaseRoot + 'Installer' + PathDelim + 'Resources' + PathDelim + 'dwScreen.bmp';
 If FileExists(LFile) Then
  FSideImage.Picture.LoadFromFile(LFile);
end;

procedure TfrmRESTDWInstaller.ClearPage;
var
 I: Integer;
begin
 If Assigned(FSlideTimer) Then
  FreeAndNil(FSlideTimer);

 FPackageCheckBoxes.Clear;
 FPackages := nil;
 FCurrentPackage := -1;

 For I := FPagePanel.ControlCount - 1 Downto 0 Do
  FPagePanel.Controls[I].Free;
 FTitle := nil;
 FDescription := nil;
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

procedure TfrmRESTDWInstaller.ShowPage(APage: Integer);
begin
 ClearPage;
 FPage := APage;
 FBack.Enabled := FPage > 0;
 FNext.Enabled := True;
 Case FPage Of
  0: ShowWelcome;
  1: ShowLazarusInfo;
  2: ShowPackages;
  3: ShowDestination;
  4: ShowSource;
  5: ShowReady;
 End;
end;


procedure TfrmRESTDWInstaller.ShowWelcome;
begin
 FTitle := TLabel.Create(Self);
 FTitle.Parent := FPagePanel;
 FTitle.Caption := 'Bem vindo a Instalação do REST Dataware';
 FTitle.Font.Size := 18;
 FTitle.Font.Style := [fsBold];
 FTitle.SetBounds(34, 30, 620, 40);

 FDescription := TLabel.Create(Self);
 FDescription.Parent := FPagePanel;
 FDescription.WordWrap := True;
 If FExistingInstallPath = '' Then
  FDescription.Caption := 'Nenhuma instalação do REST Dataware foi localizada neste computador.'
 Else
  FDescription.Caption := 'Foi localizada uma instalação do REST Dataware em: ' +
                          FExistingInstallPath;
 FDescription.SetBounds(34, 88, 620, 60);

 FNewInstall := TRadioButton.Create(Self);
 FNewInstall.Parent := FPagePanel;
 FNewInstall.Caption := 'Nova instalação';
 FNewInstall.SetBounds(54, 170, 520, 28);

 If FExistingInstallPath <> '' Then
  Begin
   FNewInstall.Visible := False;
   FModifyInstall := TRadioButton.Create(Self);
   FModifyInstall.Parent := FPagePanel;
   FModifyInstall.Caption := 'Modificar instalação';
   FModifyInstall.Checked := True;
   FModifyInstall.SetBounds(54, 170, 520, 28);

   FRemoveInstall := TRadioButton.Create(Self);
   FRemoveInstall.Parent := FPagePanel;
   FRemoveInstall.Caption := 'Remover';
   FRemoveInstall.SetBounds(54, 214, 520, 28);
  End
 Else
  FNewInstall.Checked := True;
end;

procedure TfrmRESTDWInstaller.ShowLazarusInfo;
begin
 FTitle := TLabel.Create(Self);
 FTitle.Parent := FPagePanel;
 FTitle.Caption := 'Instalação no Lazarus';
 FTitle.Font.Size := 18;
 FTitle.Font.Style := [fsBold];
 FTitle.SetBounds(34, 30, 620, 40);

 FDescription := TLabel.Create(Self);
 FDescription.Parent := FPagePanel;
 FDescription.WordWrap := True;
 FDescription.Caption :=
  'Este assistente instalará os componentes usando o Lazarus/FPC disponível no sistema. ' +
  'A IDE deverá permanecer fechada durante a instalação e será recompilada ao final.';
 FDescription.SetBounds(34, 88, 620, 92);
end;

procedure TfrmRESTDWInstaller.LoadInstallerImages;
const
 CFiles: Array[0..13] Of String = (
  'pkg_core.bmp', 'pkg_database.bmp', 'pkg_native.bmp', 'pkg_client.bmp',
  'pkg_visual.bmp', 'pkg_report.bmp', 'pkg_web.bmp', 'pkg_tools.bmp',
  'os_windows.bmp', 'os_linux.bmp', 'os_macos.bmp', 'os_android.bmp',
  'os_ios.bmp', 'os_fpc.bmp');
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
    LFile := BaseRoot + 'Installer' + PathDelim + 'Resources' + PathDelim +
             'InstallerIcons' + PathDelim + CFiles[I];
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

function TfrmRESTDWInstaller.PackageIconIndex(const AName: String): Integer;
var
 LName: String;
begin
 LName := LowerCase(AName);
 If Pos('native', LName) > 0 Then
  Result := 2
 Else If (Pos('driver', LName) > 0) Or (Pos('dac', LName) > 0) Or
         (Pos('zeos', LName) > 0) Or (Pos('fire', LName) > 0) Then
  Result := 1
 Else If (Pos('client', LName) > 0) Or (Pos('pooler', LName) > 0) Then
  Result := 3
 Else If Pos('report', LName) > 0 Then
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

function TfrmRESTDWInstaller.PlatformIconIndex(const AName: String): Integer;
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
 Else If (Pos('darwin', LName) > 0) Or (Pos('osx', LName) > 0) Or
         (Pos('mac', LName) > 0) Then
  Result := 10
 Else
  Result := 13;
end;

procedure TfrmRESTDWInstaller.ShowPackages;
var
 LList: TStringList;
 I: Integer;
 LRelative: String;
 LRow: TPanel;
 LCheck: TCheckBox;
 LImage: TImage;
 LLabel: TLabel;
 LIconIndex: Integer;
begin
 FTitle := TLabel.Create(Self);
 FTitle.Parent := FPagePanel;
 FTitle.Caption := 'Pacotes';
 FTitle.Font.Size := 18;
 FTitle.Font.Style := [fsBold];
 FTitle.SetBounds(34, 28, 730, 38);

 FDescription := TLabel.Create(Self);
 FDescription.Parent := FPagePanel;
 FDescription.Caption := 'Selecione os pacotes. A lista já está na ordem correta de instalação.';
 FDescription.SetBounds(34, 70, 730, 38);

 FPackages := TScrollBox.Create(Self);
 FPackages.Parent := FPagePanel;
 FPackages.SetBounds(34, 112, 732, 448);
 FPackages.BorderStyle := bsSingle;
 FPackages.VertScrollBar.Visible := True;
 FPackages.HorzScrollBar.Visible := False;

 FPackageFiles.Clear;
 FPackageCheckBoxes.Clear;

 LList := TStringList.Create;
 Try
  FCore.EnumeratePackages(LList, BaseRoot + 'Packages' + PathDelim + 'Lazarus');
  FCore.SortPackagesByDependencies(LList);

  For I := 0 To LList.Count - 1 Do
   Begin
    LRelative := RelativeToBase(LList[I]);
    FPackageFiles.Add(LRelative);

    LRow := TPanel.Create(FPackages);
    LRow.Parent := FPackages;
    LRow.BevelOuter := bvNone;
    LRow.SetBounds(0, I * 30, 706, 30);

    LCheck := TCheckBox.Create(LRow);
    LCheck.Parent := LRow;
    LCheck.Caption := '';
    LCheck.SetBounds(4, 5, 18, 20);
    If Not FConfig.Loaded Then
     LCheck.Checked := True
    Else
     LCheck.Checked := FConfig.GetPackagePlatforms(LRelative) <> '';
    FPackageCheckBoxes.Add(LCheck);

    LImage := TImage.Create(LRow);
    LImage.Parent := LRow;
    LImage.SetBounds(24, 3, 24, 24);
    LImage.Stretch := True;
    LImage.Proportional := True;

    LIconIndex := PackageIconIndex(LRelative);
    If Assigned(FInstallerImages) And
       (LIconIndex >= 0) And
       (LIconIndex < FInstallerImages.Count) Then
     FInstallerImages.GetBitmap(LIconIndex, LImage.Picture.Bitmap);

    LLabel := TLabel.Create(LRow);
    LLabel.Parent := LRow;
    LLabel.Caption := Format('%.2d  %s',
                             [I + 1,
                              ChangeFileExt(ExtractFileName(LRelative), '')]);
    LLabel.SetBounds(54, 7, 630, 18);
   End;
 Finally
  LList.Free;
 End;
end;

function TfrmRESTDWInstaller.PackagePlatforms(const APackage: String): String;
var
 LTargets: TStringList;
begin
 Result := FConfig.GetPackagePlatforms(APackage);
 If (Result <> '') Or FConfig.Loaded Then
  Exit;
 LTargets := TStringList.Create;
 Try
  FLazarus.DetectTargets(LTargets);
  Result := LTargets.CommaText;
 Finally
  LTargets.Free;
 End;
end;

procedure TfrmRESTDWInstaller.ShowDestination;
begin
 FTitle := TLabel.Create(Self);
 FTitle.Parent := FPagePanel;
 FTitle.Caption := 'Diretório de destino';
 FTitle.Font.Size := 18;
 FTitle.Font.Style := [fsBold];
 FTitle.SetBounds(34, 28, 730, 38);

 FDescription := TLabel.Create(Self);
 FDescription.Parent := FPagePanel;
 FDescription.Caption := 'Informe a pasta raiz onde Source, Packages, Images, Extras e Demos serão instalados.';
 FDescription.WordWrap := True;
 FDescription.SetBounds(34, 82, 620, 58);

 FDestination := TEdit.Create(Self);
 FDestination.Parent := FPagePanel;
 FDestination.SetBounds(34, 154, 535, 30);
 If FExistingInstallPath <> '' Then
  FDestination.Text := FExistingInstallPath
 Else If FConfig.Destination <> '' Then
  FDestination.Text := FConfig.Destination
 Else
  FDestination.Text := ExpandFileName(GetUserDir + 'RESTDataWare');

 FBrowse := TButton.Create(Self);
 FBrowse.Parent := FPagePanel;
 FBrowse.Caption := '...';
 FBrowse.SetBounds(580, 154, 48, 30);
 FBrowse.OnClick := @BrowseClick;
end;

procedure TfrmRESTDWInstaller.ShowSource;
begin
 FTitle := TLabel.Create(Self);
 FTitle.Parent := FPagePanel;
 FTitle.Caption := 'Fonte da instalação';
 FTitle.Font.Size := 18;
 FTitle.Font.Style := [fsBold];
 FTitle.SetBounds(34, 28, 730, 38);

 FSourceLocal := TRadioButton.Create(Self);
 FSourceLocal.Parent := FPagePanel;
 FSourceLocal.Caption := 'Local - usar as pastas ao lado do instalador';
 FSourceLocal.SetBounds(34, 100, 600, 28);

 FSourceCab := TRadioButton.Create(Self);
 FSourceCab.Parent := FPagePanel;
 FSourceCab.Caption := 'Pacote pré-empacotado - CORE.CAB / CORE.tar.gz';
 FSourceCab.SetBounds(34, 140, 600, 28);
 FSourceCab.Enabled := FileExists(BaseRoot + 'CORE.CAB') Or FileExists(BaseRoot + 'CORE.tar.gz');
 FSourceSVNTrunk := TRadioButton.Create(Self);
 FSourceSVNTrunk.Parent := FPagePanel;
 FSourceSVNTrunk.Caption := 'SVN - Trunk (Versão estável)';
 FSourceSVNTrunk.SetBounds(34, 180, 600, 28);

 FSourceSVNBranch := TRadioButton.Create(Self);
 FSourceSVNBranch.Parent := FPagePanel;
 FSourceSVNBranch.Caption := 'SVN - Branch (Desenvolvimento)';
 FSourceSVNBranch.SetBounds(34, 220, 600, 28);
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

procedure TfrmRESTDWInstaller.ShowReady;
var
 LTextPanel: TPanel;
begin
 FTitle := TLabel.Create(Self);
 FTitle.Parent := FPagePanel;
 FTitle.Caption := 'Pronto para instalar';
 FTitle.Font.Size := 18;
 FTitle.Font.Style := [fsBold];
 FTitle.SetBounds(34, 28, 730, 38);

 LTextPanel := TPanel.Create(Self);
 LTextPanel.Parent := FPagePanel;
 LTextPanel.BevelOuter := bvNone;
 LTextPanel.SetBounds(34, 78, 700, 130);

 FDescription := TLabel.Create(Self);
 FDescription.Parent := LTextPanel;
 FDescription.Align := alClient;
 FDescription.AutoSize := False;
 FDescription.WordWrap := True;
 FDescription.Layout := tlTop;
 FDescription.Caption :=
  'Clique em Iniciar para copiar a distribuição, registrar os pacotes e recompilar a IDE Lazarus. ' +
  'Se a IDE estiver aberta, o instalador solicitará autorização para fechá-la.';

 FNext.Caption := 'Iniciar';
end;

procedure TfrmRESTDWInstaller.BackClick(Sender: TObject);
begin
 If FPage > 0 Then
  ShowPage(FPage - 1);
end;

procedure TfrmRESTDWInstaller.NextClick(Sender: TObject);
var
 I         : Integer;
 LPackages : TStringList;
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
     LPackages := TStringList.Create;
     Try
      FCore.EnumeratePackages(LPackages,
       IncludeTrailingPathDelimiter(FExistingInstallPath) + 'Packages' + PathDelim + 'Lazarus');
      If (LPackages.Count > 0) And Not FLazarus.RemovePackages(LPackages) Then
       Begin
        MessageDlg('Não foi possível remover os pacotes do Lazarus.', mtError, [mbOK], 0);
        Exit;
       End;
     Finally
      LPackages.Free;
     End;
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
 If FPage = 2 Then
  Begin
   FSelectedPackages.Clear;
   For I := 0 To FPackageCheckBoxes.Count - 1 Do
    If I < FPackageFiles.Count Then
     If TCheckBox(FPackageCheckBoxes[I]).Checked Then
      FSelectedPackages.Add(FPackageFiles[I]);
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
  Begin
   I := FPage + 1;
   ShowPage(I);
  End
 Else
  StartInstall;
end;

procedure TfrmRESTDWInstaller.CancelClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmRESTDWInstaller.FormCloseQueryHandler(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose := MessageDlg('Deseja sair da instalação?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TfrmRESTDWInstaller.BrowseClick(Sender: TObject);
var
 LDirectory: String;
begin
 LDirectory := FDestination.Text;
 If SelectDirectory('Selecione o destino', '', LDirectory) Then
  FDestination.Text := LDirectory;
end;

function TfrmRESTDWInstaller.SelectedSource: TRESTDWInstallSource;
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

function TfrmRESTDWInstaller.RelativeToBase(const AFileName: String): String;
begin
 Result := AFileName;
 If Pos(BaseRoot, Result) = 1 Then
  Delete(Result, 1, Length(BaseRoot));
end;

procedure TfrmRESTDWInstaller.LoadSlides;
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
 LRoot := IncludeTrailingPathDelimiter(FCore.SourcePath) + 'Images' + PathDelim + 'icons';
 AddImages(LRoot + PathDelim + 'package');
 AddImages(LRoot + PathDelim + 'components');
 If (FSlideFiles.Count = 0) And
    FileExists(BaseRoot + 'Installer' + PathDelim + 'Resources' + PathDelim +
               'dwScreen.bmp') Then
  FSlideFiles.Add(BaseRoot + 'Installer' + PathDelim + 'Resources' + PathDelim +
                  'dwScreen.bmp');
end;

procedure TfrmRESTDWInstaller.SlideTimer(Sender: TObject);
begin
 If (FSlideImage = nil) Or (FSlideFiles.Count = 0) Then
  Exit;
 Inc(FSlideIndex);
 If FSlideIndex >= FSlideFiles.Count Then
  FSlideIndex := 0;
 If FileExists(FSlideFiles[FSlideIndex]) Then
  FSlideImage.Picture.LoadFromFile(FSlideFiles[FSlideIndex]);
end;

procedure TfrmRESTDWInstaller.CoreProgress(AValue, AMaximum: Integer;
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

procedure TfrmRESTDWInstaller.CoreLog(const AText: String);
begin
 If Assigned(FStatus) Then
  FStatus.Caption := AText;
 Application.ProcessMessages;
end;

procedure TfrmRESTDWInstaller.StartInstall;
var
 I: Integer;
 LPackages: TStringList;
 LRelative: String;
 LVersion: TRESTDWDistributionVersion;
 LTargets: TStringList;
 LTarget: String;
 J: Integer;
begin
 If FLazarus.IDEIsRunning Then
  Begin
   If MessageDlg('O Lazarus está aberto. Deseja que o instalador feche a IDE agora?',
                 mtConfirmation, [mbYes, mbNo], 0) <> mrYes Then
    Exit;
   If Not FLazarus.CloseIDE Then
    Begin
     MessageDlg('Não foi possível fechar o Lazarus.', mtError, [mbOK], 0);
     Exit;
    End;
  End;
 ClearPage;
 FBack.Enabled := False;
 FNext.Enabled := False;
 FCancel.Enabled := False;

 FSlideImage := TImage.Create(Self);
 FSlideImage.Parent := FPagePanel;
 FSlideImage.SetBounds(35, 24, 530, 310);
 FSlideImage.Stretch := True;
 FSlideImage.Proportional := True;

 FStatus := TLabel.Create(Self);
 FStatus.Parent := FPagePanel;
 FStatus.SetBounds(35, 350, 530, 44);
 FStatus.Caption := 'Preparando instalação...';

 FProgress := TProgressBar.Create(Self);
 FProgress.Parent := FPagePanel;
 FProgress.SetBounds(35, 404, 530, 28);
 FProgress.Max := 100;
 FProgress.Position := 0;
 LoadSlides;
 FSlideIndex := -1;
 FSlideTimer := TTimer.Create(FPagePanel);
 FSlideTimer.Interval := 2800;
 FSlideTimer.OnTimer := @SlideTimer;
 SlideTimer(nil);

 If Not FCore.PrepareSource(SelectedSource) Then
  Begin
   MessageDlg('Não foi possível preparar a fonte da instalação.', mtError, [mbOK], 0);
   FCancel.Enabled := True;
   Exit;
  End;
 LoadSlides;
 SlideTimer(nil);

 If Not FCore.CopyDistribution Then
  Begin
   MessageDlg('Falha durante a cópia da distribuição.', mtError, [mbOK], 0);
   FCancel.Enabled := True;
   Exit;
  End;

 LPackages := TStringList.Create;
 Try
  For I := 0 To FSelectedPackages.Count - 1 Do
   Begin
    LRelative := FSelectedPackages[I];
    LPackages.Add(IncludeTrailingPathDelimiter(FCore.DestinationPath) + LRelative);
   End;
  FCore.SortPackagesByDependencies(LPackages);
  LTargets := TStringList.Create;
  Try
   For I := 0 To LPackages.Count - 1 Do
    Begin
     LRelative := Copy(LPackages[I], Length(IncludeTrailingPathDelimiter(FCore.DestinationPath)) + 1, MaxInt);
     LTargets.CommaText := PackagePlatforms(LRelative);
     For J := 0 To LTargets.Count - 1 Do
      Begin
       LTarget := Trim(LTargets[J]);
       If LTarget = '' Then
        Continue;
       If LPackages.Count > 0 Then
        FProgress.Position := 60 + ((I + 1) * 30) Div LPackages.Count;
       FStatus.Caption := 'Compilando ' + ExtractFileName(LPackages[I]) + ' - ' + LTarget;
       Application.ProcessMessages;
       If Not FLazarus.CompilePackage(LPackages[I], LTarget) Then
        Begin
         MessageDlg('Falha ao compilar ' + ExtractFileName(LPackages[I]) +
                    ' para ' + LTarget + '.', mtError, [mbOK], 0);
         FCancel.Enabled := True;
         Exit;
        End;
      End;
    End;
  Finally
   LTargets.Free;
  End;
  FProgress.Position := 94;
  FStatus.Caption := 'Registrando pacotes e recompilando o Lazarus...';
  Application.ProcessMessages;
  If Not FLazarus.InstallPackages(LPackages) Then
   Begin
    MessageDlg('Falha ao instalar/recompilar os pacotes Lazarus.', mtError, [mbOK], 0);
    FCancel.Enabled := True;
    Exit;
   End;
 Finally
  LPackages.Free;
 End;
 FProgress.Position := 97;
 FStatus.Caption := 'Finalizando configuração...';
 Application.ProcessMessages;
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
