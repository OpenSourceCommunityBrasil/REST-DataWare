unit uprincipal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, CheckLst, uprincipal, frteste;

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
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lIDESubTitle: TLabel;
    lSubTitle2: TLabel;
    lVersion: TLabel;
    lSubTitle: TLabel;
    lTheme: TLabel;
    pRecursos: TPanel;
    pIDE: TPanel;
    pLanguage: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imIDEBackClick(Sender: TObject);
    procedure imInstallNextClick(Sender: TObject);
    procedure imLanguageBackClick(Sender: TObject);
    procedure imIDENextClick(Sender: TObject);
    procedure imResourcesNextClick(Sender: TObject);
    procedure imThemeClick(Sender: TObject);
  private
    FThemeIndex: integer;
    procedure SetTheme(aThemeIndex: integer);
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
    if (Components[I] is TLabel) and not ((Components[I] as TLabel).Name =
      'lNextButton') then
      (Components[I] as TLabel).Font.Color := Themes[aThemeIndex].FontColor;
  lTheme.Caption := Themes[aThemeIndex].subtitle;
  FThemeIndex := aThemeIndex;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  pLanguage.ControlStyle := pLanguage.ControlStyle - [csOpaque] + [csParentBackground];
  pIDE.ControlStyle := pIDE.ControlStyle - [csOpaque] + [csParentBackground];

  pLanguage.Visible := True;
  //SetTheme(0);
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
