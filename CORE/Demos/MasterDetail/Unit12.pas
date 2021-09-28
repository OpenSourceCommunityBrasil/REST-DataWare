unit Unit12;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  uDWAbout, uRESTDWPoolerDB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDWConstsData, uDWMassiveBuffer, uDWConsts, Vcl.DBCtrls;

type
  TForm12 = class(TForm)
    labHost: TLabel;
    labPorta: TLabel;
    labSenha: TLabel;
    labUsuario: TLabel;
    labAcesso: TLabel;
    labWelcome: TLabel;
    labExtras: TLabel;
    labConexao: TLabel;
    labVersao: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    cbxCompressao: TCheckBox;
    chkhttps: TCheckBox;
    eAccesstag: TEdit;
    eWelcomemessage: TEdit;
    paTopo: TPanel;
    Image1: TImage;
    labSistema: TLabel;
    paPortugues: TPanel;
    Image3: TImage;
    paEspanhol: TPanel;
    Image4: TImage;
    paIngles: TPanel;
    Image2: TImage;
    cbBinaryRequest: TCheckBox;
    cbUseCripto: TCheckBox;
    btnOpen: TButton;
    btnApply: TButton;
    DBGrid1: TDBGrid;
    labResult: TLabel;
    DBGrid2: TDBGrid;
    Label1: TLabel;
    dwcsqlVendas: TRESTDWClientSQL;
    dwcsqlVendasIt: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    dsVendas: TDataSource;
    dsVendasIt: TDataSource;
    dwmcMasterDetail: TDWMassiveCache;
    dwcsqlEmployee: TRESTDWClientSQL;
    dsEmployee: TDataSource;
    dwcsqlEmployeeEMP_NO: TSmallintField;
    dwcsqlEmployeeFULL_NAME: TStringField;
    dwcsqlVendasID: TIntegerField;
    dwcsqlVendasEMP_NO: TSmallintField;
    dwcsqlVendasDATA: TSQLTimeStampField;
    dwcsqlVendasTOTAL: TFloatField;
    dwcsqlVendasEMPLOYEE: TStringField;
    dwcsqlVendasItID_ITEMS: TSmallintField;
    dwcsqlVendasItID_VENDA: TIntegerField;
    dwcsqlVendasItPRODUTO: TStringField;
    dwcsqlVendasItVALOR: TFloatField;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    cbReflectChanges: TCheckBox;
    procedure dwcsqlVendasAfterInsert(DataSet: TDataSet);
    procedure btnOpenClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form12: TForm12;

implementation

{$R *.dfm}

procedure TForm12.btnApplyClick(Sender: TObject);
Var
 vError        : Boolean;
 vMessageError : String;
begin
 RESTDWDataBase1.ApplyUpdates(dwmcMasterDetail, vError, vMessageError);
 If vError Then
  Showmessage(vMessageError)
 Else
  Showmessage('Dados Aplicados com sucesso...');
end;

procedure TForm12.btnOpenClick(Sender: TObject);
begin
 If Not RESTDWDataBase1.Active Then
  Begin
   RESTDWDataBase1.PoolerService  := EHost.Text;
   RESTDWDataBase1.PoolerPort     := StrToInt(EPort.Text);
   RESTDWDataBase1.Login          := EdUserNameDW.Text;
   RESTDWDataBase1.Password       := EdPasswordDW.Text;
   RESTDWDataBase1.Compression    := cbxCompressao.Checked;
   RESTDWDataBase1.AccessTag      := eAccesstag.Text;
   RESTDWDataBase1.WelcomeMessage := eWelcomemessage.Text;
   If chkhttps.Checked Then
    RESTDWDataBase1.TypeRequest   := TTyperequest.trHttps
   Else
    RESTDWDataBase1.TypeRequest   := TTyperequest.trHttp;
   RESTDWDataBase1.Open;
  End;
 dwcsqlEmployee.Close;
 dwcsqlVendas.Close;
 dwcsqlVendas.ReflectChanges      := cbReflectChanges.Checked;
 dwcsqlVendasIt.ReflectChanges    := dwcsqlVendas.ReflectChanges;
 dwmcMasterDetail.ReflectChanges  := dwcsqlVendasIt.ReflectChanges;
 dwcsqlEmployee.BinaryRequest     := cbBinaryRequest.Checked;
 dwcsqlVendas.BinaryRequest       := dwcsqlEmployee.BinaryRequest;
 dwcsqlVendasIt.BinaryRequest     := dwcsqlVendas.BinaryRequest;
 RESTDWDataBase1.OpenDatasets([dwcsqlEmployee, dwcsqlVendas]);
end;

procedure TForm12.dwcsqlVendasAfterInsert(DataSet: TDataSet);
begin
  dwcsqlVendasDATA.AsDateTime := Now;
end;

procedure TForm12.FormCreate(Sender: TObject);
begin
 labVersao.Caption := DWVERSAO;
end;

end.
