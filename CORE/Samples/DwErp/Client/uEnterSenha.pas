unit uEnterSenha;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFrmEnterSenha = class(TForm)
    Label1: TLabel;
    EdSenha: TEdit;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmEnterSenha: TFrmEnterSenha;

implementation

{$R *.dfm}

end.
