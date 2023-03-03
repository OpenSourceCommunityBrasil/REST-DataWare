unit uprincipal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, CheckLst, ValEdit, Buttons, fpJSON, jsonparser,
  urestfunctions, uconsts, lclfunctions, utesteanim;

type
  TSplashFormStyle = record
    Background: string;
    Banner: string;
    subtitle: string;
    Theme: string;
    FontColor: TColor;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbIDEVersion: TComboBox;
    clbDataEngine: TCheckListBox;
    clbDBDrivers: TCheckListBox;
    clbResources: TCheckListBox;
    clbPlatforms: TCheckListBox;
    cbSources: TComboBox;
    cbInstallType: TComboBox;
    Image1: TImage;
    imLogoAnim: TImage;
    ImageList1: TImageList;
    imConfirmBack: TImage;
    imInstallBack: TImage;
    imConfirmNext: TImage;
    imInstallClose: TImage;
    imLazarus: TImage;
    imDelphi: TImage;
    imIDEBack: TImage;
    imlogoBG: TImage;
    imResourceBack: TImage;
    imLanguageNext: TImage;
    imBanner: TImage;
    imLangBR: TImage;
    imLangUS: TImage;
    imLangES: TImage;
    imBackground: TImage;
    imIDENext: TImage;
    imResourceNext: TImage;
    imTheme: TImage;
    lSourceVersion: TLabel;
    lInstallType: TLabel;
    lIDEVersion: TLabel;
    lbedFolder: TLabeledEdit;
    lDataEngine: TLabel;
    lDBWare: TLabel;
    lOtherResources: TLabel;
    lPlatforms: TLabel;
    lResourcesNext: TLabel;
    lConfirmNext: TLabel;
    lInstallClose: TLabel;
    lResourcesPrevious: TLabel;
    lLanguageNext: TLabel;
    lIDEPrevious: TLabel;
    lIDESubTitle: TLabel;
    lIDENext: TLabel;
    lConfirmBack: TLabel;
    lInstallBack: TLabel;
    lResourcesSubTitle: TLabel;
    lConfirmSubTitle: TLabel;
    lInstallSubTitle: TLabel;
    lVersion: TLabel;
    lLanguageSubTitle: TLabel;
    lTheme: TLabel;
    mmConfirm: TMemo;
    mmLogInstall: TMemo;
    pConfirmaRecursos: TPanel;
    pInstall: TPanel;
    pRecursos: TPanel;
    pIDE: TPanel;
    pLanguage: TPanel;
    FolderDialog: TSelectDirectoryDialog;
    selectionbox: TShape;
    IDESelector: TShape;
    SpeedButton1: TSpeedButton;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ConfigureInstallOptions(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure imBannerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure imBannerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure imBannerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure imConfirmBackClick(Sender: TObject);
    procedure imConfirmNextClick(Sender: TObject);
    procedure imResourceBackClick(Sender: TObject);
    procedure imResourceNextClick(Sender: TObject);
    procedure imIDEBackClick(Sender: TObject);
    procedure imLanguageNextClick(Sender: TObject);
    procedure imIDENextClick(Sender: TObject);
    procedure imThemeClick(Sender: TObject);
    procedure ImageSelect(Sender: TObject);
    procedure IDESelect(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FThemeIndex: integer;
    FIDE: integer;
    IgnoredLabels: TStrings;
    FMouseClick: TPoint;
    procedure SetTheme(aThemeIndex: integer);
    procedure ConfigThemes;
    procedure SetIgnoredLabels;
    procedure Translate(aLangIndex: integer);
    procedure ShowStep(aStepIndex: integer);
    procedure PreparaVersoes;
    procedure ConfiguraOpcoes;
    procedure RevisarConfiguracoes;

  public

  end;

var
  Form1: TForm1;
  Themes: array of TSplashFormStyle;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.imThemeClick(Sender: TObject);
begin
  if FThemeIndex = 0 then
    SetTheme(1)
  else
    SetTheme(0);
end;

procedure TForm1.SetTheme(aThemeIndex: integer);
var
  I: integer;
begin
  imBanner.Picture.LoadFromResourceName(HInstance, Themes[aThemeIndex].Banner);
  imBackground.Picture.LoadFromResourceName(HInstance, Themes[aThemeIndex].Background);
  imTheme.Picture.LoadFromResourceName(HInstance, Themes[aThemeIndex].Theme);
  for I := 0 to pred(ComponentCount) do
  begin
    if (Components[I] is TLabel) and (IgnoredLabels.IndexOf(
      TLabel(Components[I]).Name) < 0) then
      TLabel(Components[I]).Font.Color := Themes[aThemeIndex].FontColor;
    if (Components[I] is TLabeledEdit) and (IgnoredLabels.IndexOf(
      TLabeledEdit(Components[I]).Name) < 0) then
      TLabeledEdit(Components[I]).EditLabel.Font.Color := Themes[aThemeIndex].FontColor;
  end;
  lTheme.Caption := Themes[aThemeIndex].subtitle;
  FThemeIndex := aThemeIndex;
end;

procedure TForm1.ConfigThemes;
var
  theme: TSplashFormStyle;
begin
  SetLength(Themes, 2);
  // light
  theme.Background := 'LIGHTBG';
  theme.Banner := 'LIGHTBANNER';
  theme.FontColor := clBlack;
  theme.Theme := 'LIGHTICON';
  theme.subtitle := 'Light';
  Themes[0] := theme;

  // dark
  theme.Background := 'DARKBG';
  theme.Banner := 'DARKBANNER';
  theme.FontColor := clWhite;
  theme.Theme := 'DARKICON';
  theme.subtitle := 'Dark';
  Themes[1] := theme;
end;

procedure TForm1.SetIgnoredLabels;
var
  I: integer;
begin
  if not Assigned(IgnoredLabels) then
    IgnoredLabels := TStringList.Create
  else
    IgnoredLabels.Clear;
  for I := 0 to pred(ComponentCount) do
    if (Components[I] is TLabel) and (TLabel(Components[I]).Tag = 1) then
      IgnoredLabels.Add(TLabel(Components[I]).Name);
end;

procedure TForm1.Translate(aLangIndex: integer);
begin
  case aLangIndex of
    0: begin //PT-BR
      //títulos
      lVersion.Caption := 'Versão';
      lLanguageSubTitle.Caption := 'Escolha o idioma';
      lIDESubTitle.Caption := 'Escolha a IDE';
      lResourcesSubTitle.Caption := 'Escolha os recursos a instalar';
      //botões
      lLanguageNext.Caption := 'Próximo >';
      lIDENext.Caption := 'Próximo >';
      lResourcesNext.Caption := 'Próximo >';
      lIDEPrevious.Caption := '< Anterior';
      lResourcesPrevious.Caption := '< Anterior';
      //outros
      lDataEngine.Caption := 'Motor de Dados';
      lDBWare.Caption := 'Drivers de Banco (DBWare)';
      lOtherResources.Caption := 'Outros Recursos';
    end;

    1: begin //EN-US
      //títulos
      lVersion.Caption := 'Version';
      lLanguageSubTitle.Caption := 'Choose your language';
      lIDESubTitle.Caption := 'Choose an IDE';
      lResourcesSubTitle.Caption := 'Choose which resources to install';
      //botões
      lLanguageNext.Caption := 'Next >';
      lIDENext.Caption := 'Next >';
      lResourcesNext.Caption := 'Next >';
      lIDEPrevious.Caption := '< Back';
      lResourcesPrevious.Caption := '< Back';
      //outros
      lDataEngine.Caption := 'Data Engine';
      lDBWare.Caption := 'Database Drivers (DBWare)';
      lOtherResources.Caption := 'Other Resources';
    end;

    2: begin //ES-ES
      //títulos
      lVersion.Caption := 'Versión';
      lLanguageSubTitle.Caption := 'Seleccione su idioma';
      lIDESubTitle.Caption := 'Seleccione su IDE';
      lResourcesSubTitle.Caption := 'Elija las características para instalar';
      //botões
      lLanguageNext.Caption := 'Próximo >';
      lIDENext.Caption := 'Próximo >';
      lResourcesNext.Caption := 'Próximo >';
      lIDEPrevious.Caption := '< Anterior';
      lResourcesPrevious.Caption := '< Anterior';
      //outros
      lDataEngine.Caption := 'Motor de Datos';
      lDBWare.Caption := 'Drivers de Banco (DBWare)';
      lOtherResources.Caption := 'Otros Recursos';
    end;
  end;
end;

procedure TForm1.ShowStep(aStepIndex: integer);
begin
  pInstall.Visible := False;
  pConfirmaRecursos.Visible := False;
  pLanguage.Visible := False;
  pIDE.Visible := False;
  pRecursos.Visible := False;
  pConfirmaRecursos.Visible := False;

  case aStepIndex of
    0: pLanguage.Visible := True;
    1: pIDE.Visible := True;
    2: pRecursos.Visible := True;
    3: pConfirmaRecursos.Visible := True;
    4: pInstall.Visible := True;
  end;
end;

procedure TForm1.PreparaVersoes;
var
  RESTClient: TRESTClient;
begin
  RESTClient := TRESTClient.Create;
  try
    cbSources.Items.Clear;
    cbSources.Items.AddDelimitedtext('--- Branches ---');
    cbSources.Items.AddDelimitedtext(RESTClient.getBranchesList);
    cbSources.Items.AddDelimitedtext('--- Tags ---');
    cbSources.Items.AddDelimitedtext(RESTClient.getTagsList);
  finally
    RESTClient.Free;
  end;
end;

procedure TForm1.ConfiguraOpcoes;
begin
  clbDataEngine.Items.Clear;
  clbDBDrivers.Items.Clear;
  clbResources.Items.Clear;
  if FIDE = 1 then
  begin
    clbDataEngine.Items.AddDelimitedtext(DelphiSocketsList);
    clbDBDrivers.Items.AddDelimitedtext(DelphiDBWareList);
    clbResources.Items.AddDelimitedtext(DelphiResourceList);
    cbIDEVersion.Visible := True;
  end
  else
  begin
    clbDataEngine.Items.AddDelimitedtext(LazarusSocketsList);
    clbDBDrivers.Items.AddDelimitedtext(LazarusDBWareList);
    clbResources.Items.AddDelimitedtext(LazarusResourceList);
    clbPlatforms.Visible := False;
    cbIDEVersion.Visible := False;
  end;
  lIDEVersion.Visible := cbIDEVersion.Visible;
  lPlatforms.Visible := clbPlatforms.Visible;
end;

procedure TForm1.RevisarConfiguracoes;
begin

end;

procedure TForm1.ImageSelect(Sender: TObject);
begin
  selectionbox.Visible := True;
  selectionbox.Left := TImage(Sender).Left - 2;
  selectionbox.Top := TImage(Sender).Top + 13;
  selectionbox.Visible := True;
  Translate(TImage(Sender).Tag);
  lLanguageNext.Enabled := True;
end;

procedure TForm1.IDESelect(Sender: TObject);
begin
  IDESelector.Visible := True;
  IDESelector.Left := TImage(Sender).Left + 3;
  IDESelector.Top := TImage(Sender).Top;
  IDESelector.Visible := True;
  FIde := TImage(Sender).Tag;
  lIDENext.Enabled := FIde > -1;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if FolderDialog.Execute then
    lbedFolder.Text := FolderDialog.FileName;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if imLogoAnim.Height < imlogoBG.Height then
    imLogoAnim.Height := imLogoAnim.Height + 3
  else
  begin
    Timer1.Enabled := False;
    lInstallClose.Enabled := True;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFNDEF MSWindows}
  imDelphi.Enabled := False;
  imDelphi.Visible := False;
  {$ENDIF}
  SetIgnoredLabels;
  ConfigThemes;
  FIDE := -1;
  LCLFunc.DesativaControles([lIDENext, lLanguageNext, lInstallClose,
    clbResources, clbPlatforms, clbDBDrivers, clbDataEngine]);
  LCLFunc.EscondeControles([IDESelector, selectionbox]);
  imLogoAnim.Height := 0;

  ShowStep(0);
  SetTheme(0);
end;

procedure TForm1.FormClick(Sender: TObject);
begin
  ShowMessage('formclick');
end;

procedure TForm1.ConfigureInstallOptions(Sender: TObject);
begin
{
Padrão - Indy
TLS 1.3
Full
Custom
}
  case cbInstallType.ItemIndex of
    3: LCLFunc.AtivaControles([clbDataEngine, clbDBDrivers, clbPlatforms, clbResources]);
    else
      LCLFunc.DesativaControles([clbDataEngine, clbDBDrivers, clbPlatforms, clbResources]);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  imLogoAnim.Height := 0;
  lInstallClose.Enabled := False;
  Timer1.Enabled := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Application.CreateForm(TfTesteAnim, fTesteAnim);
  fTesteAnim.Show;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(IgnoredLabels) then
    IgnoredLabels.Free;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.imBannerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  FMouseClick := Mouse.CursorPos;
  imBanner.Tag := 1;
end;

procedure TForm1.imBannerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  if imBanner.Tag = 1 then
  begin
    Self.Left := Self.Left + (Mouse.CursorPos.X - FMouseClick.X);
    Self.Top := Self.Top + (Mouse.CursorPos.Y - FMouseClick.Y);
    FMouseClick := Mouse.CursorPos;
  end;
end;

procedure TForm1.imBannerMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  imBanner.Tag := 0;
end;

procedure TForm1.imConfirmBackClick(Sender: TObject);
begin
  ShowStep(2);
end;

procedure TForm1.imConfirmNextClick(Sender: TObject);
begin
  ShowStep(4);
end;

procedure TForm1.imResourceBackClick(Sender: TObject);
begin
  ShowStep(1);
end;

procedure TForm1.imResourceNextClick(Sender: TObject);
begin
  RevisarConfiguracoes;
  ShowStep(3);
end;

procedure TForm1.imIDEBackClick(Sender: TObject);
begin
  ShowStep(0);
end;

procedure TForm1.imLanguageNextClick(Sender: TObject);
begin
  ShowStep(1);
end;

procedure TForm1.imIDENextClick(Sender: TObject);
begin
  PreparaVersoes;
  ConfiguraOpcoes;
  ShowStep(2);
end;

end.
