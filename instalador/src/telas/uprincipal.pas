unit uprincipal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, CheckLst;

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
    Image1: TImage;
    imLazarus: TImage;
    imDelphi: TImage;
    imLanguageBack: TImage;
    imIDEBack: TImage;
    imIDENext: TImage;
    imBanner: TImage;
    imLangBR: TImage;
    imLangUS: TImage;
    imLangES: TImage;
    imBackground: TImage;
    imResourcesNext: TImage;
    imInstallNext: TImage;
    imTheme: TImage;
    lDataEngine: TLabel;
    lDBWare: TLabel;
    lOtherResources: TLabel;
    lResourcesNext: TLabel;
    lResourcesPrevious: TLabel;
    lLanguageNext: TLabel;
    lIDEPrevious: TLabel;
    lIDESubTitle: TLabel;
    lIDENext: TLabel;
    lResourcesSubTitle: TLabel;
    lVersion: TLabel;
    lLanguageSubTitle: TLabel;
    lTheme: TLabel;
    pRecursos: TPanel;
    pIDE: TPanel;
    pLanguage: TPanel;
    selectionbox: TShape;
    IDESelector: TShape;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure imBannerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure imBannerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure imBannerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure imIDEBackClick(Sender: TObject);
    procedure imInstallNextClick(Sender: TObject);
    procedure imLanguageBackClick(Sender: TObject);
    procedure imIDENextClick(Sender: TObject);
    procedure imResourcesNextClick(Sender: TObject);
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
begin
  if not Assigned(IgnoredLabels) then
    IgnoredLabels := TStringList.Create
  else
    IgnoredLabels.Clear;
  IgnoredLabels.Add('lLanguageNext');
  IgnoredLabels.Add('lIDEPrevious');
  IgnoredLabels.Add('lIDENext');
  IgnoredLabels.Add('lResourcesNext');
  IgnoredLabels.Add('lResourcesPrevious');
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
  //pLanguage.ControlStyle := pLanguage.ControlStyle - [csOpaque] + [csParentBackground];
  //pIDE.ControlStyle := pIDE.ControlStyle - [csOpaque] + [csParentBackground];
  SetIgnoredLabels;
  ConfigThemes;

  pLanguage.Visible := True;
  selectionbox.Visible := False;
  IDESelector.Visible := False;
  SetTheme(0);
end;

procedure TForm1.FormClick(Sender: TObject);
begin
  ShowMessage('formclick');
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
  //ShowMessage(Format('X: %d, Y: %d | FMouseClick.X: %d. FMouseClick.Y: %d',
  //[Mouse.CursorPos.X, Mouse.CursorPos.Y, FMouseClick.X, FMouseClick.Y]));
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

procedure TForm1.imIDEBackClick(Sender: TObject);
begin
  pLanguage.Visible := False;
  pRecursos.Visible := False;
  pIDE.Visible := True;
end;

procedure TForm1.imInstallNextClick(Sender: TObject);
begin
  pLanguage.Visible := False;
  pRecursos.Visible := False;
  pIDE.Visible := False;
end;

procedure TForm1.imLanguageBackClick(Sender: TObject);
begin
  pLanguage.Visible := True;
  pRecursos.Visible := False;
  pIDE.Visible := False;
end;

procedure TForm1.imIDENextClick(Sender: TObject);
begin
  pLanguage.Visible := False;
  pRecursos.Visible := False;
  pIDE.Visible := True;
  //Application.CreateForm(TfPrincipal, fPrincipal);
  //fPrincipal.Show;
  //Self.Hide;
end;

procedure TForm1.imResourcesNextClick(Sender: TObject);
begin
  pLanguage.Visible := False;
  pRecursos.Visible := True;
  pIDE.Visible := False;
end;

end.
