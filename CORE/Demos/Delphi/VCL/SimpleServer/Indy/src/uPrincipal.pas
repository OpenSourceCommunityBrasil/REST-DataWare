unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDWAbout, uRESTDWBase, Vcl.WinXCtrls;

type
  TForm1 = class(TForm)
    ToggleSwitch1: TToggleSwitch;
    RESTServicePooler1: TRESTServicePooler;
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
  RESTServicePooler1.ServerMethodClass := TDM;
end;

procedure TForm1.ToggleSwitch1Click(Sender: TObject);
begin
  RESTServicePooler1.Active := ToggleSwitch1.State = tssOn;
end;

end.
