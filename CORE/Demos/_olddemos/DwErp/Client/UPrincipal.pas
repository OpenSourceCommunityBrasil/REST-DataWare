unit UPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uDWJSONObject,
  DB, Grids, DBGrids, uRESTDWBase, uDWJSONTools,
  uDWConsts, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  uRESTDWPoolerDB, JvMemoryDataset, Vcl.ComCtrls,
  idComponent, uDWConstsData, Ufuncoes,
  System.ImageList ,JvLED, JvExComCtrls, JvStatusBar, Vcl.Menus, JvExControls;

type

  { TForm2 }

  TFrmPrincipal = class(TForm)
    StatusBar: TJvStatusBar;
    JvLED1: TJvLED;
    TimerAgenda: TTimer;
    mnuPrincipal: TMainMenu;
    Arquivo1: TMenuItem;
    FinalizarAplicao1: TMenuItem;
    Cadastros1: TMenuItem;
    C1: TMenuItem;
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure RESTDWDataBase1Connection(Sucess: Boolean; const Error: string);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FinalizarAplicao1Click(Sender: TObject);
    procedure TimerAgendaTimer(Sender: TObject);
    procedure C1Click(Sender: TObject);

  private
    { Private declarations }
    FBytesToTransfer: Int64;
  public
    { Public declarations }
    JSONValue: TJSONValue;
    _vfinalisa_sistema: string;


  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses UDM, uSplashConexao, UCad_banco;

procedure TFrmPrincipal.C1Click(Sender: TObject);
begin

 Funcoes.VerificaForm(tfrmCad_Banco, FrmCad_Banco);


end;

procedure TFrmPrincipal.FinalizarAplicao1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  if Assigned(Funcoes) then
    FreeAndNil(Funcoes);

  if Assigned(FindArea) then
    FindArea.Free;


end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  Funcoes := TFuncoes.Create;
  Funcoes.Fversao := Funcoes.pegaversao;
  Top := 0;
  Left := 0;
  WindowState := wsMaximized;
  DoubleBuffered := True;
  StatusBar.Panels.Items[5].Text := 'Versão 2017/2018';

end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
var
  _vsql: string;

begin

  _vfinalisa_sistema := 'N';
 // Funcoes.CurrentUser.MainMenu := mnuPrincipal;

  // chamando a tela de login
  Funcoes.CurrentUser.Login(True, EmptyStr, EmptyStr);

  FrmSplashConexao := TFrmSplashConexao.Create(nil);
  try
    FrmSplashConexao.JvGradientHeaderPanel1.LabelCaption := 'Aguarde ...';
    FrmSplashConexao.Memo1.Text := ' concluindo as configurações ...';
    FrmSplashConexao.Memo1.Visible := True;
    FrmSplashConexao.Show;
    FrmSplashConexao.Repaint;
    if _vfinalisa_sistema = 'S' then
      exit;

    if not Funcoes.Empty(Funcoes.CurrentUser.UserID) then
    begin // Efetuou o login
      Caption := Caption + ' - ' + dm.CdsEmpresa.FieldByName('RAZAO_SOCIAL').AsString + '  [' + string(Funcoes.Fversao) + ']';
      StatusBar.Panels.Items[2].Text := Funcoes.CurrentUser.UserLogin;
      StatusBar.Panels.Items[3].Text := dm.CdsEmpresa.FieldByName('RAZAO_SOCIAL').AsString;

    end;


    StatusBar.Panels.Items[1].Text := FormatDateTime('dd/mm/yyyy hh:mm', Now);

  finally
    FrmSplashConexao.Free;

  end;




end;

procedure TFrmPrincipal.RESTDWDataBase1Connection(Sucess: Boolean; const Error: string);
begin
  if not Sucess then
  begin
    Application.MessageBox('Servidor está fora do ar ' + #13#10 + 'entre em contato com o suporte.', PChar(Application.Title),
      MB_OK + mb_iconinformation);

  end;

end;

procedure TFrmPrincipal.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  If FBytesToTransfer = 0 Then // No Update File
    exit;

end;

procedure TFrmPrincipal.TimerAgendaTimer(Sender: TObject);
begin
StatusBar.Panels.Items[1].Text := FormatDateTime('dd/mm/yyyy hh:mm', Now);
end;

end.
