unit UFrameLstTransportadora;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIFrame, UframeLstBase, uniBasicGrid, uniDBGrid, uniLabel,
  uniPanel, uniPageControl, uniToolBar, uniGUIBaseClasses, uniEdit, uniDBEdit,
  uniMultiItem, uniComboBox, uniDBComboBox, uniButton, Data.DB;

type
  TFrameLstTransportadora = class(TframeLstBase)
    UniLabel34: TUniLabel;
    dtNome: TUniEdit;
    dtCPFCNPJ: TUniEdit;
    UniLabel36: TUniLabel;
    UniPanel2: TUniPanel;
    unlbl1: TUniLabel;
    ID: TUniDBEdit;
    NOME: TUniDBEdit;
    UniLabel4: TUniLabel;
    UniLabel6: TUniLabel;
    CNPJ: TUniDBEdit;
    IE: TUniDBEdit;
    UniLabel7: TUniLabel;
    UniPanel3: TUniPanel;
    UniLabel8: TUniLabel;
    CEP: TUniDBEdit;
    btnBuscaCEP: TUniButton;
    UniLabel9: TUniLabel;
    CIDADE: TUniDBEdit;
    ESTADO: TUniDBComboBox;
    UniLabel10: TUniLabel;
    UniPanel4: TUniPanel;
    UniLabel11: TUniLabel;
    LOGRADOURO: TUniDBEdit;
    NUMERO: TUniDBEdit;
    UniLabel12: TUniLabel;
    COMPLEMENTO: TUniDBEdit;
    UniLabel13: TUniLabel;
    UniPanel5: TUniPanel;
    UniLabel15: TUniLabel;
    TELEFONE: TUniDBEdit;
    CONTATO: TUniDBEdit;
    UniLabel16: TUniLabel;
    procedure UniFrameCreate(Sender: TObject);
    procedure btnBuscaCEPClick(Sender: TObject);
    procedure bt_fecharClick(Sender: TObject);
    procedure UniFrameDestroy(Sender: TObject);
  private
    procedure validacpf;
    procedure validaie;
    { Private declarations }
  public
    { Public declarations }
    procedure ConfiguraGrid(GridList: TUniDBGrid; frame: TUniFrame); override;
    procedure Pesquisa_base; override;
    procedure Depois_Novo_base; override;
    procedure Depois_Pesquisa_base; override;

    procedure ACBrCEP2BuscaEfetuada(Sender: TObject);

    procedure Antes_Salvar_base; override;

    procedure AfterInsert(DataSet: TDataSet); override;
  end;

implementation

uses
  UDmLstTransportadora, MainModule, ACBrCEP, UMensagens, UFuncoesDB,
  ACBrValidador, Main;

{$R *.dfm}



procedure TFrameLstTransportadora.ACBrCEP2BuscaEfetuada(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  if DmTransportadora.ACBrCEP2.Enderecos.Count < 1 then
  begin
    raise Exception.Create(Kernel_Aviso_TabelaVazia + '  ');
  end
  else
  begin
    For i := 0 to DmTransportadora.ACBrCEP2.Enderecos.Count - 1 do
    begin
      with DmTransportadora.ACBrCEP2.Enderecos[i], DmLstCadastro do
      begin
        qryCadbase.FieldByName('LOGRADOURO').AsString :=
          UpperCase(Kernel_Remove_Caracteres_Especiais(Tipo_Logradouro)) + ' '
          + UpperCase(Kernel_Remove_Caracteres_Especiais(Logradouro));
        qryCadbase.FieldByName('COMPLEMENTO').AsString :=
          UpperCase(Kernel_Remove_Caracteres_Especiais(Complemento));
        qryCadbase.FieldByName('BAIRRO').AsString :=
          UpperCase(Kernel_Remove_Caracteres_Especiais(Bairro));
        qryCadbase.FieldByName('CIDADE').AsString :=
          UpperCase(Kernel_Remove_Caracteres_Especiais(Municipio));
        qryCadbase.FieldByName('ESTADO').AsString := UpperCase(UF);
        Self.LOGRADOURO.SetFocus;

      end;
    end;
  end;
end;

procedure TFrameLstTransportadora.AfterInsert(DataSet: TDataSet);
begin
  if DataSet.State in [dsinsert] then
  begin
     DataSet.FieldByName('ESTADO').AsString := 'AC';
  end;
  inherited;
end;

procedure TFrameLstTransportadora.Antes_Salvar_base;
begin
  inherited;
  validacpf;

  validaie;
end;

procedure TFrameLstTransportadora.btnBuscaCEPClick(Sender: TObject);
begin
  inherited;
  with DmTransportadora do
  begin
    ACBrCEP2.WebService := TACBrCEPWebService(wsViaCep);

    ACBrCEP2.ProxyHost := '';
    ACBrCEP2.ProxyPort := '';
    ACBrCEP2.ProxyUser := '';
    ACBrCEP2.ProxyPass := '';
    ACBrCEP2.ChaveAcesso := '1STa9eKhhfKvc7Ljh6W6CO5Kr/bFOl.';

    try
      ACBrCEP2.BuscarPorCEP(qryCadbase.FieldByName('CEP').AsString);
    except
      On E: Exception do
      begin
        ShowMessage(E.Message);
      end;
    end;
  end;
end;

procedure TFrameLstTransportadora.bt_fecharClick(Sender: TObject);
begin
  inherited;
  MainForm.AbreVisaoInicial;
end;

procedure TFrameLstTransportadora.validacpf;
begin
  with DmLstTransportadora do
  begin
    if trim(CNPJ.Text) <> '' then
    begin
      ACBrValidador1.Documento := CNPJ.Text;
      ACBrValidador1.TipoDocto := docCNPJ;

      if not ACBrValidador1.Validar then
      begin
        MessageDlg('CNPJ Invalido, favor corrigir!', mtWarning, [mbOK]);
        CNPJ.SetFocus;
        Abort;
      end;
    end;
  end;
end;

procedure TFrameLstTransportadora.validaie;
begin
  with DmLstTransportadora do
  begin
    if trim(IE.Text) <> '' then
    begin
      if Trim(Cep.Text) <> '' then
      begin
        ACBrValidador1.Documento := IE.Text;
        ACBrValidador1.TipoDocto := docInscEst;
        ACBrValidador1.Complemento := ESTADO.Text;

        if not ACBrValidador1.Validar then
        begin
          MessageDlg('Inscrição Estadual Invalida, favor corrigir!', mtWarning, [mbOK]);
          IE.SetFocus;
          Abort;
        end;
      end;
    end;
  end;
end;

procedure TFrameLstTransportadora.ConfiguraGrid(GridList: TUniDBGrid;
  frame: TUniFrame);
begin
  inherited;
  ListaGrid.Clear;
  ListaGrid.Add('ID;Id;80');
  ListaGrid.Add('NOME;Nome;280');
  ListaGrid.Add('CNPJ;Cnpj;120');
  ListaGrid.Add('IE;Inscrição Estadual;160');
  ListaGrid.Add('CIDADE;Cidade;220');
  ListaGrid.Add('ESTADO;Estado;80');
  ListaGrid.Add('LOGRADOURO;Endereço;400');
  ListaGrid.Add('BAIRRO;Bairro;180');
  ListaGrid.Add('NUMERO;Numero;100');
  ListaGrid.Add('CEP;Cep;100');
  ListaGrid.Add('TELEFONE;Telefone;100');
  ListaGrid.Add('CONTATO;Contato;320');

  ListaCadastro.Clear;
  ListaCadastro.Add('ID;MSG_PADRAO;N;Id;0;');
  ListaCadastro.Add('NOME;MSG_PADRAO;S;Nome;0;');
  ListaCadastro.Add('CNPJ;MSG_PADRAO;S;Cnpj;0;');
  ListaCadastro.Add('IE;MSG_PADRAO;N;Inscrição Estadual;0;');
  ListaCadastro.Add('CEP;MSG_PADRAO;S;Cep;0;');
  ListaCadastro.Add('CIDADE;MSG_PADRAO;S;Cidade;0;');
  ListaCadastro.Add('ESTADO;MSG_PADRAO;S;Estado;0;');
  ListaCadastro.Add('LOGRADOURO;MSG_PADRAO;S;Endereço;0;');
  ListaCadastro.Add('NUMERO;MSG_PADRAO;S;Numero;0;');
  ListaCadastro.Add('COMPLEMENTO;MSG_PADRAO;N;Complemento;0;');
  ListaCadastro.Add('TELEFONE;MSG_PADRAO;N;Telefone;0;');
  ListaCadastro.Add('CONTATO;MSG_PADRAO;N;Contato;0;');

  inherited ConfiguraGrid(GridList, Self);
end;

procedure TFrameLstTransportadora.Depois_Novo_base;
begin
  inherited;
  NOME.SetFocus;
end;

procedure TFrameLstTransportadora.Depois_Pesquisa_base;
begin
  inherited;
  inherited ConfiguraGrid(GridList, Self);
end;

procedure TFrameLstTransportadora.Pesquisa_base;
begin
  inherited;
  with DmLstCadastro do
  begin
    qryLstbase.Close;
    qryLstbase.Params[0].AsString := '%' + dtNome.Text + '%';
    qryLstbase.Params[1].AsString := '%' + dtCPFCNPJ.Text + '%';
    qryLstbase.Open;
  end;
end;

procedure TFrameLstTransportadora.UniFrameCreate(Sender: TObject);
begin
  DmLstCadastro := DmLstTransportadora;

  inherited;

  GridList.DataSource := DmLstCadastro.dsLstBase;

  ConfiguraGrid(GridList, Self);

  DmLstTransportadora.ACBrCEP2.OnBuscaEfetuada := ACBrCEP2BuscaEfetuada;
end;

procedure TFrameLstTransportadora.UniFrameDestroy(Sender: TObject);
begin
  inherited;
  if Assigned(DmLstCadastro) then
     FreeAndNil(DmLstCadastro);
end;

end.
