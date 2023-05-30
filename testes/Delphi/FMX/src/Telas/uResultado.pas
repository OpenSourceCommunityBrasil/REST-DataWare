unit uResultado;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Layouts;

type
  TfResultado = class(TForm)
    Memo1: TMemo;
    Layout1: TLayout;
    Button3: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LogMessage(aMessage: string);
  end;

implementation

{$R *.fmx}

procedure TfResultado.Button1Click(Sender: TObject);
begin
  Self.Hide;
end;

procedure TfResultado.Button3Click(Sender: TObject);
begin
  Memo1.Lines.SaveToFile(ExtractFileDir(ParamStr(0)) + '\logRDWTestTool.txt');
  LogMessage('Log salvo no arquivo: ' + ExtractFileDir(ParamStr(0)) +
    '\logRDWTestTool.txt');
end;

procedure TfResultado.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Self := nil;
  Action := TCloseAction.caFree;
end;

procedure TfResultado.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TfResultado.FormShow(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TfResultado.LogMessage(aMessage: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      Memo1.Lines.Add(aMessage);
      Memo1.GoToTextEnd;
    end);
end;

end.
