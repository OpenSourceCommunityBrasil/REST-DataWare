unit UfrmLstBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, UfrmBase, uniGUIBaseClasses, uniStatusBar,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, uniImageList, System.Actions, Vcl.ActnList,
  Data.DB, FireDAC.Comp.Client, uniTimer, FireDAC.Comp.DataSet, uniBasicGrid,
  uniDBGrid, uniLabel, uniButton, uniBitBtn, uniPageControl, uniImage, uniPanel,
  uniToolBar;

type
  TfrmLstBase = class(TfrmBase)
    pnlerror: TUniPanel;
    imgError: TUniImage;
    pgCadastro: TUniPageControl;
    Tab_Consulta: TUniTabSheet;
    pnlbotoes: TUniPanel;
    lbltitulo: TUniLabel;
    ImageTitle: TUniImage;
    pnlfiltros: TUniPanel;
    GridList: TUniDBGrid;
    Tab_Cadastro: TUniTabSheet;
    PanelBottom: TUniPanel;
    lbltitulocadastro: TUniLabel;
    UniImage1: TUniImage;
    MemtblLogCampos: TFDMemTable;
    MemtblLogCamposcampo: TStringField;
    MemtblLogCamposvalor: TStringField;
    MemtblLogCamposmensagem: TStringField;
    tmrError: TUniTimer;
    qryCadbase: TFDQuery;
    dsCadBase: TDataSource;
    actlstLstBase: TActionList;
    actNovo: TAction;
    actAlterar: TAction;
    actExcluir: TAction;
    actFiltrar: TAction;
    actImprimir: TAction;
    actSalvar: TAction;
    actCancelar: TAction;
    actFechar: TAction;
    qryLstbase: TFDQuery;
    dsLstBase: TDataSource;
    UniToolBar1: TUniToolBar;
    bt_incluir: TUniToolButton;
    bt_editar: TUniToolButton;
    bt_excluir: TUniToolButton;
    bt_salvar: TUniToolButton;
    bt_cancelar: TUniToolButton;
    bt_pesquisar: TUniToolButton;
    bt_anterior: TUniToolButton;
    bt_proximo: TUniToolButton;
    img_32: TUniImageList;
    actProximo: TAction;
    actAnterior: TAction;
    bt_fechar: TUniToolButton;
    UniToolButton1: TUniToolButton;
    bt_imprimir: TUniToolButton;
    procedure dsCadBaseStateChange(Sender: TObject);
    procedure actAnteriorExecute(Sender: TObject);
    procedure actProximoExecute(Sender: TObject);
    procedure actAlterarExecute(Sender: TObject);
    procedure actExcluirExecute(Sender: TObject);
    procedure actFiltrarExecute(Sender: TObject);
    procedure actImprimirExecute(Sender: TObject);
    procedure actCancelarExecute(Sender: TObject);
    procedure actNovoExecute(Sender: TObject);
    procedure actSalvarExecute(Sender: TObject);
    procedure actFecharExecute(Sender: TObject);
    procedure qryCadbaseBeforePost(DataSet: TDataSet);
    procedure tmrErrorTimer(Sender: TObject);
    procedure UniFormCreate(Sender: TObject);
    procedure qryCadbaseAfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
    procedure DCallBack2(Sender: TComponent; Res: Integer);
    procedure HabButoes(status: Boolean);
  public
    { Public declarations }
    Tabela, CampoChave, titulo, TabelaInc, CampoEmpresa : string;
    AutoInc: Boolean;
    procedure Pesquisa_base; virtual;
    procedure Executa_Pesquisa_base; virtual;
    procedure Antes_Pesquisa_base; virtual;
    procedure Depois_Pesquisa_base; virtual;

    procedure Novo_base; virtual;
    procedure Executa_Novo_base; virtual;
    procedure Antes_Novo_base; virtual;
    procedure Depois_Novo_base; virtual;

    procedure Alterar_base; virtual;
    procedure Executa_Alterar_base; virtual;
    procedure Antes_Alterar_base; virtual;
    procedure Depois_Alterar_base; virtual;

    procedure Excluir_base; virtual;
    procedure Executa_Excluir_base; virtual;
    procedure Antes_Excluir_base; virtual;
    procedure Depois_Excluir_base; virtual;

    procedure Imprimir_Base; virtual;
    procedure Executa_Imprimir_base; virtual;
    procedure Antes_Imprimir_base; virtual;
    procedure Depois_Imprimir_base; virtual;

    procedure Salvar_Base; virtual;
    procedure Executa_Salvar_base; virtual;
    procedure Antes_Salvar_base; virtual;
    procedure Depois_Salvar_base; virtual;
    procedure Antes_Salvar_Post_base; virtual;

    procedure Cancelar_Base; virtual;
    procedure Executa_Cancelar_base; virtual;
    procedure Antes_Cancelar_base; virtual;
    procedure Depois_Cancelar_base; virtual;

    procedure Executa_Excluir(Sender: TComponent; Res: Integer);

    procedure Inseri_log(campo,valor, mensagem: string); virtual;

    procedure Atualiza_DataSets(); virtual;
  end;

function frmLstBase: TfrmLstBase;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, UFuncoesDB;

function frmLstBase: TfrmLstBase;
begin
  Result := TfrmLstBase(UniMainModule.GetFormInstance(TfrmLstBase));
end;

procedure TfrmLstBase.HabButoes(status: Boolean);
begin
  if bt_incluir.Tag = 0 then
     bt_incluir.Visible := status;
  if bt_editar.Tag = 0 then
     bt_editar.Visible := status;
  if bt_excluir.Tag = 0 then
     bt_excluir.Visible := status;
  if bt_salvar.Tag = 0 then
     bt_salvar.Visible := not status;
  if bt_cancelar.Tag = 0 then
     bt_cancelar.Visible := not status;
  if bt_pesquisar.Tag = 0 then
     bt_pesquisar.Visible := status;
  if bt_anterior.Tag = 0 then
     bt_anterior.Visible := status;
  if bt_proximo.Tag = 0 then
     bt_proximo.Visible := status;
  if bt_imprimir.Tag = 0 then
     bt_imprimir.Visible := status;

end;

procedure TfrmLstBase.actAlterarExecute(Sender: TObject);
begin
  inherited;
  Executa_Alterar_base;
end;

procedure TfrmLstBase.actAnteriorExecute(Sender: TObject);
begin
  inherited;
  if Not dsLstBase.DataSet.IsEmpty then
     dsLstBase.DataSet.Prior;
end;

procedure TfrmLstBase.actCancelarExecute(Sender: TObject);
begin
  inherited;
  Executa_Cancelar_base;
end;

procedure TfrmLstBase.actExcluirExecute(Sender: TObject);
begin
  inherited;
  Executa_Excluir_base;
end;

procedure TfrmLstBase.actFecharExecute(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmLstBase.actFiltrarExecute(Sender: TObject);
begin
  inherited;
  Executa_Pesquisa_base;
end;

procedure TfrmLstBase.actImprimirExecute(Sender: TObject);
begin
  inherited;
  Executa_Imprimir_base;
end;

procedure TfrmLstBase.actNovoExecute(Sender: TObject);
begin
  inherited;
  Executa_Novo_base;
end;

procedure TfrmLstBase.actProximoExecute(Sender: TObject);
begin
  inherited;
  if Not dsLstBase.DataSet.IsEmpty then
     dsLstBase.DataSet.Next;
end;

procedure TfrmLstBase.actSalvarExecute(Sender: TObject);
begin
  inherited;
  Executa_Salvar_base;
end;

procedure TfrmLstBase.Alterar_base;
begin
  // Implementado nos filhos
  qryCadbase.Close;
  qryCadbase.Params[0].AsInteger :=
    qryLstbase.FieldByName(CampoChave).AsInteger;
  if qryCadbase.ParamCount > 1 then
     qryCadbase.Params[1].AsInteger := UniMainModule.ID_EMPRESA;
  qryCadbase.Open;

  qryCadbase.edit;

  Atualiza_DataSets;

  Tab_Cadastro.TabVisible := True;
  Tab_Consulta.TabVisible := False;
  pgCadastro.ActivePageIndex := 1;
  HabButoes(False);
end;

procedure TfrmLstBase.Antes_Alterar_base;
begin
  if qryLstbase.IsEmpty then
  begin
    MessageDlg('Impossível Alterar: Nenhum registro encontrado com o filtro utilizado!', mtInformation, [mbOK]);
    Abort;
  end;
end;

procedure TfrmLstBase.Antes_Cancelar_base;
begin

end;

procedure TfrmLstBase.Antes_Excluir_base;
begin
  if qryLstbase.IsEmpty then
  begin
    MessageDlg('Impossível Excluir: Nenhum registro encontrado com o filtro utilizado!', mtInformation, [mbOK]);
    Abort;
  end;

end;

procedure TfrmLstBase.Antes_Imprimir_base;
begin

end;

procedure TfrmLstBase.Antes_Novo_base;
begin
   Atualiza_DataSets;
end;

procedure TfrmLstBase.Antes_Pesquisa_base;
begin

end;

procedure TfrmLstBase.Antes_Salvar_base;
begin

end;

procedure TfrmLstBase.Antes_Salvar_Post_base;
begin

end;

procedure TfrmLstBase.Atualiza_DataSets;
begin

end;

procedure TfrmLstBase.Cancelar_Base;
begin
  qryCadbase.Cancel;
end;

procedure TfrmLstBase.DCallBack2(Sender: TComponent; Res: Integer);
begin

end;

procedure TfrmLstBase.Depois_Alterar_base;
begin

end;

procedure TfrmLstBase.Depois_Cancelar_base;
begin
  pnlerror.Visible := False;
  Tab_Cadastro.TabVisible := False;
  Tab_Consulta.TabVisible := True;
  pgCadastro.ActivePageIndex := 0;
  HabButoes(True);
end;

procedure TfrmLstBase.Depois_Excluir_base;
begin

end;

procedure TfrmLstBase.Depois_Imprimir_base;
begin

end;

procedure TfrmLstBase.Depois_Novo_base;
begin

end;

procedure TfrmLstBase.Depois_Pesquisa_base;
begin

end;

procedure TfrmLstBase.Depois_Salvar_base;
begin
  pnlerror.Visible := False;
  Tab_Cadastro.TabVisible := False;
  Tab_Consulta.TabVisible := True;
  pgCadastro.ActivePageIndex := 0;
  HabButoes(True);
  Executa_Pesquisa_base;
end;

procedure TfrmLstBase.dsCadBaseStateChange(Sender: TObject);
begin
  inherited;
  if dsCadBase.DataSet.Active then
  begin

    if dsCadBase.DataSet.State in [dsInsert] then
    begin
      pgCadastro.ActivePage := Tab_Cadastro;

      UniStatusBar1.Panels.Items[0].Text := 'Incluindo...';
    end;

    if dsCadBase.DataSet.State in [dsEdit] then
    begin
      UniStatusBar1.Panels.Items[0].Text := 'Alterando...';

      pgCadastro.ActivePage := Tab_Cadastro;
    end;

    if not (dsCadBase.DataSet.State in [dsInsert, dsEdit]) then
    begin
      UniStatusBar1.Panels.Items[0].Text := '';
    end;

  end;
end;

procedure TfrmLstBase.Excluir_base;
begin
  MessageDlg('Tem certeza que deseja excluir esse registro?', mtConfirmation, mbYesNo, Executa_Excluir);
end;

procedure TfrmLstBase.Executa_Alterar_base;
begin
  Antes_Alterar_base;
  Alterar_base;
  Depois_Alterar_base;
end;

procedure TfrmLstBase.Executa_Cancelar_base;
begin
  Antes_Cancelar_base;
  Cancelar_base;
  Depois_Cancelar_base;
end;

procedure TfrmLstBase.Executa_Excluir(Sender: TComponent; Res: Integer);
var
  vErros: string;
begin
  case Res of
    mrYes :
     begin
       // excluir o registro na tabela
       UniMainModule.conConexao.StartTransaction;
       try
         Kernel_Apaga_Rergistro(Tabela, CampoChave, CampoEmpresa, qryLstbase.FieldByName(CampoChave).AsInteger, UniMainModule.ID_EMPRESA, vErros);
         UniMainModule.conConexao.commit;
         Depois_Excluir_base;
         // Implementado nos filhos
         Executa_Pesquisa_base;
       except
         UniMainModule.conConexao.Rollback;
       end;

     end;
  end;
end;

procedure TfrmLstBase.Executa_Excluir_base;
begin
  Antes_Excluir_base;
  Excluir_base;
end;

procedure TfrmLstBase.Executa_Imprimir_base;
begin
  Antes_Imprimir_base;
  Imprimir_base;
  Depois_Imprimir_base;
end;

procedure TfrmLstBase.Executa_Novo_base;
begin
  Antes_Novo_base;
  Novo_base;
  Depois_Novo_base;
end;

procedure TfrmLstBase.Executa_Pesquisa_base;
begin
  Antes_Pesquisa_base;
  Pesquisa_base;
  Depois_Pesquisa_base;
end;

procedure TfrmLstBase.Executa_Salvar_base;
begin
  Antes_Salvar_base;
  Salvar_base;
  Depois_Salvar_base;
end;

procedure TfrmLstBase.Imprimir_Base;
begin

end;

procedure TfrmLstBase.Inseri_log(campo, valor, mensagem: string);
begin
  MemtblLogCampos.Append;
  MemtblLogCamposcampo.AsString := campo;
  MemtblLogCamposvalor.AsString := valor;
  MemtblLogCamposmensagem.AsString := mensagem;
  MemtblLogCampos.Post;
end;

procedure TfrmLstBase.Novo_base;
begin
  qryCadbase.Close;
  qryCadbase.Params[0].AsInteger := -1;
  if qryCadbase.ParamCount > 1 then
     qryCadbase.Params[1].AsInteger := -1;
  qryCadbase.Open;
  qryCadbase.Append;

  Tab_Cadastro.TabVisible := True;
  Tab_Consulta.TabVisible := False;
  pgCadastro.ActivePageIndex := 1;
  HabButoes(false);
end;

procedure TfrmLstBase.Pesquisa_base;
begin

end;

procedure TfrmLstBase.qryCadbaseAfterInsert(DataSet: TDataSet);
begin
  inherited;
  if DataSet.State in [dsinsert] then
  begin
    if not AutoInc then
    begin
       DataSet.FieldByName(CampoChave).value:= Kernel_Incrementa(TabelaInc,CampoChave);
    end;
  end;
end;

procedure TfrmLstBase.qryCadbaseBeforePost(DataSet: TDataSet);
begin
  inherited;
  // Faz autoincremto do campo chave
  if DataSet.State in [dsinsert] then
  begin
    if not AutoInc then
    begin
       DataSet.FieldByName(CampoChave).value:= Kernel_Incrementa(TabelaInc,CampoChave);
    end;
  end;
end;

procedure TfrmLstBase.Salvar_Base;
begin
  UniMainModule.conConexao.StartTransaction;
  try
    Antes_Salvar_Post_base;
    qryCadbase.Post;
    UniMainModule.conConexao.Commit;
  except
    UniMainModule.conConexao.Rollback;
  end;
end;

procedure TfrmLstBase.tmrErrorTimer(Sender: TObject);
begin
  inherited;
  pnlerror.Visible := True;
  tmrError.Enabled :=false;
end;

procedure TfrmLstBase.UniFormCreate(Sender: TObject);
begin
  inherited;
  Tab_Cadastro.TabVisible := False;
  Tab_Consulta.TabVisible := True;
  pgCadastro.ActivePageIndex := 0;
  Self.Caption := 'Formulario de ' + titulo;
  lbltitulo.Caption := 'Listagem de ' + titulo;
  lbltitulocadastro.Caption := 'Manutenção de ' + titulo;
  HabButoes(True);
  AutoInc := False;

  if MemtblLogCampos.Active then
    MemtblLogCampos.EmptyDataSet
   else
    MemtblLogCampos.CreateDataSet;
end;

end.
