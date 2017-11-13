unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniButton,
  uniBitBtn, uniPanel, uniPageControl, uniLabel, Vcl.Imaging.pngimage, uniImage,
  uniHTMLFrame, uniMemo, uniHTMLMemo, uniTreeView, dxGDIPlusClasses, uniGUIFrame,
  uniTimer;

type
  TMainForm = class(TUniForm)
    UniPanel1: TUniPanel;
    UniPanel14: TUniPanel;
    UniPanel15: TUniPanel;
    UniImage2: TUniImage;
    UniLabel11: TUniLabel;
    UniImage4: TUniImage;
    UniLabel13: TUniLabel;
    UniPanel16: TUniPanel;
    UniPanel5: TUniPanel;
    NavPage: TUniPageControl;
    tbDados: TUniTabSheet;
    UniPanel2: TUniPanel;
    UniImage1: TUniImage;
    NavTree: TUniTreeView;
    UniContainerPanel1: TUniContainerPanel;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    UniPanel4: TUniPanel;
    procedure UniFormShow(Sender: TObject);
    procedure NavTreeClick(Sender: TObject);
    procedure UniLabel13Click(Sender: TObject);
  private
    FFrameName: string;
    FCurrentFrame: TUniFrame;
    procedure InsertFrameTab(Name, Titulo: string);
    { Private declarations }
  public
    { Public declarations }
    procedure AbreVisaoInicial;
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, UfrmLstBase, IWSystem,
  UFrameInicial, UFrameLstTransportadora;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.AbreVisaoInicial;
begin
  InsertFrameTab('TframeInicial', 'Visão Inicial');
end;

procedure TMainForm.InsertFrameTab(Name, Titulo: string);
begin
  //FechaTodasAbas;
  FreeAndNil(FCurrentFrame);

  NavPage.Visible:= True;
//  if FFrameName = Name then
//    Exit;
  FFrameName := Name;
  NavPage.TabIndex := 0;

  if Name <> 'Main' then
  begin
    FCurrentFrame := TUniFrameClass(FindClass(Name)).Create(Self);
 //   FCurrentFrame.Align := alClient;
    FCurrentFrame.Parent := tbDados;
    tbDados.Caption := Titulo;
  end;
  //goto last page...
  NavPage.ActivePageIndex := NavPage.PageCount - 1;

end;

procedure TMainForm.UniFormShow(Sender: TObject);
begin
  InsertFrameTab('TframeInicial', 'Visão Inicial');
end;

procedure TMainForm.UniLabel13Click(Sender: TObject);
begin
  UniSession.AddJS('location.reload(); ');
end;

procedure TMainForm.NavTreeClick(Sender: TObject);
var
  Nd: TUniTreeNode;
begin
  Nd := NavTree.Selected;
  if Nd.Count = 0 then
  begin
    if Nd.Text = 'Transportadoras' then
    begin
      InsertFrameTab('TFrameLstTransportadora', 'Cadastro de Transportadora');
    end;
  end;

end;

initialization


RegisterClasses([ TframeInicial,
                  TFrameLstTransportadora ]);

RegisterAppFormClass(TMainForm);

end.
