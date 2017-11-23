unit uSplashConexao;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, StdCtrls, JvExStdCtrls, JvButton, JvCtrls,
  JvExControls, JvGradientHeaderPanel, ExtCtrls,
  IdBaseComponent, IdComponent, IdRawBase, IdRawClient, IdIcmpClient, JvExExtCtrls, JvImage;

type
  TFrmSplashConexao = class(TForm)
    Bevel1: TBevel;
    JvGradientHeaderPanel1: TJvGradientHeaderPanel;
    Button1: TButton;
    BtnReconnect: TButton;
    IdIcmpClient1: TIdIcmpClient;
    JvImage1: TJvImage;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure IdIcmpClient1Reply(ASender: TComponent;
      const AReplyStatus: TReplyStatus);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    pingou : boolean;
  end;

var
  FrmSplashConexao: TFrmSplashConexao;

implementation

{$R *.dfm}

uses uDM, uPrincipal, UFuncoes;

procedure TFrmSplashConexao.Button1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmSplashConexao.FormCreate(Sender: TObject);
begin
  Button1.Visible := False;
  BtnReconnect.Visible := False;



end;

procedure TFrmSplashConexao.FormShow(Sender: TObject);
begin
//  if BtnReconnect.Visible = true then
//     BtnReconnect.SetFocus;
end;

procedure TFrmSplashConexao.IdIcmpClient1Reply(ASender: TComponent;
  const AReplyStatus: TReplyStatus);
begin
 //  if AReplyStatus.ReplyStatusType = rsTimeOut then
 //     pingou := false;
end;

end.

