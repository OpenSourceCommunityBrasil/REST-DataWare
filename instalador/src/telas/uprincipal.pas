unit uprincipal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, CheckLst, ValEdit;

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
    CheckListBox1: TCheckListBox;
    CheckListBox2: TCheckListBox;
    CheckListBox3: TCheckListBox;
    CheckListBox4: TCheckListBox;
    ComboBox1: TComboBox;
    cbInstallType: TComboBox;
    Image1: TImage;
    imConfirmBack: TImage;
    imInstallBack: TImage;
    imConfirmNext: TImage;
    imInstallClose: TImage;
    imLazarus: TImage;
    imDelphi: TImage;
    imIDEBack: TImage;
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
    Label1: TLabel;
    Label2: TLabel;
    LabeledEdit1: TLabeledEdit;
    lDataEngine: TLabel;
    lDBWare: TLabel;
    lOtherResources: TLabel;
    lOtherResources1: TLabel;
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
    selectionbox: TShape;
    IDESelector: TShape;
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
    if (Components[I] is TLabel) and (IgnoredLabels.IndexOf(
      (Components[I] as TLabel).Name) < 0) then
      (Components[I] as TLabel).Font.Color := Themes[aThemeIndex].FontColor;
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

procedure TForm1.ImageSelect(Sender: TObject);
begin
  selectionbox.Left := TImage(Sender).Left - 2;
  selectionbox.Top := TImage(Sender).Top + 13;
  selectionbox.Visible := True;
  Translate(TImage(Sender).Tag);
end;

procedure TForm1.IDESelect(Sender: TObject);
begin
  IDESelector.Left := TImage(Sender).Left + 3;
  IDESelector.Top := TImage(Sender).Top;
  IDESelector.Visible := True;
  FIde := TImage(Sender).Tag;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFNDEF MSWindows}
  imDelphi.Enabled := False;
  imDelphi.Visible := False;
  {$ENDIF}
  SetIgnoredLabels;
  ConfigThemes;

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
    0: ;
  end;
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
  ShowStep(2);
end;

end.
