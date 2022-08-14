unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons,
  ComCtrls, CheckLst, ufrIDEItem;

type

  { TfPrincipal }

  TfPrincipal = class(TForm)
    CheckListBox1: TCheckListBox;
    CheckListBox2: TCheckListBox;
    CheckListBox3: TCheckListBox;
    FlowPanel1: TFlowPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    ScrollBox1: TScrollBox;
    tsIDE: TTabSheet;
    tsRecursos: TTabSheet;
    tsStatus: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure Panel14Click(Sender: TObject);
    procedure Panel15Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure Panel8Click(Sender: TObject);
  private

  public

  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.lfm}

{ TfPrincipal }

procedure TfPrincipal.Panel4Click(Sender: TObject);
begin
  PageControl1.ActivePage := tsRecursos;
end;

procedure TfPrincipal.Panel14Click(Sender: TObject);
begin
  PageControl1.ActivePage := tsIDE;
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePage := tsIDE;
end;

procedure TfPrincipal.Panel15Click(Sender: TObject);
begin
  PageControl1.ActivePage := tsRecursos;
end;

procedure TfPrincipal.Panel8Click(Sender: TObject);
begin
  PageControl1.ActivePage := tsStatus;
end;

end.
