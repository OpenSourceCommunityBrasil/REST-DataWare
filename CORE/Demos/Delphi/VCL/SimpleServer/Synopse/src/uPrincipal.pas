unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDWAbout, uRESTDWSynBase, Vcl.WinXCtrls;

type
  TForm1 = class(TForm)
    RESTDWServiceSynPooler1: TRESTDWServiceSynPooler;
    ToggleSwitch1: TToggleSwitch;
    procedure FormCreate(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  RDWDM;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  RESTDWServiceSynPooler1.ServerMethodClass := TDM;
end;

procedure TForm1.ToggleSwitch1Click(Sender: TObject);
begin
  RESTDWServiceSynPooler1.Active := ToggleSwitch1.State = tssOn;
end;

end.
