unit UCad_banco;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UBasicRO, System.ImageList, Vcl.ImgList,
  JvImageList, Data.DB, Datasnap.DBClient, System.Actions, Vcl.ActnList,
   Vcl.ComCtrls, Vcl.ToolWin, JvExComCtrls, JvToolBar,
  JvExControls, JvLabel, Vcl.ExtCtrls, JvMemoryDataset, uRESTDWPoolerDB,
  JvExMask, JvToolEdit, JvDBControls, Vcl.StdCtrls, JvExExtCtrls,
  JvExtComponent, JvDBRadioPanel, JvExStdCtrls, JvCombobox, JvDBCombobox,
  Vcl.DBCtrls, Vcl.Mask;

type
  TFrmCad_banco = class(TFrmBasic)
    Panel1: TPanel;
    Label1: TLabel;
    Label5: TLabel;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label10: TLabel;
    Label11: TLabel;
    Label25: TLabel;
    Label18: TLabel;
    Label8: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    Label20: TLabel;
    Label31: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    DBEdit49: TDBEdit;
    DBEdit59: TDBEdit;
    DBEdit62: TDBEdit;
    DBMemo2: TDBMemo;
    JvDBComboBox2: TJvDBComboBox;
    DBEdit10: TDBEdit;
    JvDBComboBox3: TJvDBComboBox;
    DBEdit11: TDBEdit;
    DBEdit12: TDBEdit;
    DBEdit14: TDBEdit;
    DBEdit15: TDBEdit;
    DBEdit16: TDBEdit;
    DBEdit17: TDBEdit;
    DBMemo1: TDBMemo;
    DBEdit18: TDBEdit;
    GroupBox3: TGroupBox;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    DBEdit19: TDBEdit;
    DBEdit20: TDBEdit;
    DBEdit21: TDBEdit;
    GroupBox4: TGroupBox;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    DBEdit22: TDBEdit;
    DBEdit23: TDBEdit;
    DBEdit24: TDBEdit;
    JvDBComboEdit1: TJvDBComboEdit;
    JvDBComboBox1: TJvDBComboBox;
    JvDBComboBox4: TJvDBComboBox;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    JvDBComboBox5: TJvDBComboBox;
    JvDBComboBox6: TJvDBComboBox;
    DBEdit5: TDBEdit;
    JvDBComboBox7: TJvDBComboBox;
    JvDBComboBox8: TJvDBComboBox;

    cdsprincipalIDSYS_POINT_CLIENTE: TStringField;
    cdsprincipalIDEMPRESA: TStringField;
    cdsprincipalIDBANCO: TIntegerField;
    cdsprincipalDESCRICAO: TStringField;
    cdsprincipalINSTRUCOES: TMemoField;
    cdsprincipalB_CODIGO_CEDENTE: TStringField;
    cdsprincipalB_CODIGO_CEDENTE_DIG: TStringField;
    cdsprincipalB_AGENCIA: TStringField;
    cdsprincipalB_AGENCIA_DIG: TStringField;
    cdsprincipalB_CARACTITULO: TStringField;
    cdsprincipalB_CARTEIRA: TStringField;
    cdsprincipalB_CONVENIO: TStringField;
    cdsprincipalB_CEDENTE: TStringField;
    cdsprincipalB_CPF: TStringField;
    cdsprincipalB_CNPJ: TStringField;
    cdsprincipalB_NUM_INICIO: TIntegerField;
    cdsprincipalB_NUM_MEIO: TIntegerField;
    cdsprincipalB_NUM_FIM: TIntegerField;
    cdsprincipalB_BAIRRO: TStringField;
    cdsprincipalB_CEP: TStringField;
    cdsprincipalB_CIDADE: TStringField;
    cdsprincipalB_CODTRANSMISSAO: TStringField;
    cdsprincipalB_COMPLEMENTO: TStringField;
    cdsprincipalB_CONTA: TStringField;
    cdsprincipalB_CONTADIGITO: TStringField;
    cdsprincipalB_LOGRADOURO: TStringField;
    cdsprincipalB_MODALIDAE: TStringField;
    cdsprincipalB_NOME: TStringField;
    cdsprincipalB_NUMERORES: TStringField;
    cdsprincipalB_TELEFONE: TStringField;
    cdsprincipalB_TIPOCARTEIRA: TStringField;
    cdsprincipalB_TIPOINSCRICAO: TStringField;
    cdsprincipalB_RESPONEMISSAO: TStringField;
    cdsprincipalB_UF: TStringField;
    cdsprincipalB_ORIENTACOESBANCO: TBlobField;
    cdsprincipalBLOCALPAGTO: TStringField;
    cdsprincipalB_FASTREPORTFILE: TStringField;
    cdsprincipalB_LAYOUT: TStringField;
    cdsprincipalB_FILTRO: TStringField;
    cdsprincipalB_CAMINHOLOGO: TStringField;
    cdsprincipalB_TPLOGO: TStringField;
    cdsprincipalBANCO_TIPOCOBRANCA: TStringField;
    cdsprincipalBANCO_DIGITO: TStringField;
    cdsprincipalBANCO_NOME: TStringField;
    cdsprincipalBANCO_NUMERO: TStringField;
    cdsprincipalBANCO_TAMAXNOSSONUM: TStringField;
    cdsprincipalLICENCA: TStringField;
    cdsprincipalCODIGO: TStringField;
    cdsprincipalCOD_CONFIGURACAO1: TStringField;
    cdsprincipalCOD_CONFIGURACAO2: TStringField;
    cdsprincipalLAYOUT: TStringField;
    cdsprincipalSEQUENCIA: TIntegerField;
    cdsprincipalTIPOIMPRESSAO: TStringField;
    cdsprincipalDIAS_PROTESTO: TIntegerField;
    cdsprincipalLICENCA_DESCONTO: TStringField;
    cdsprincipalTAXA_DEVOLUCAO: TBCDField;
    cdsprincipalMORA_DIA: TBCDField;
    cdsprincipalMULTA_ATRAZO: TBCDField;
    cdsprincipalJUROS_DESCONTO: TBCDField;
    cdsprincipalIOF_DESCONTO: TBCDField;
    cdsprincipalTAXA_DESCONTO: TBCDField;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCad_banco: TFrmCad_banco;

implementation

{$R *.dfm}

uses UDM;

procedure TFrmCad_banco.FormCreate(Sender: TObject);
begin
  inherited;
  Area := 8;

  cdsprincipal.DataBase := dm.Coneccao;

end;

end.
