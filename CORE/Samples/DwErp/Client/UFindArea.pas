unit UFindArea;

interface

uses
  SysUtils, Variants, Classes, uClasseFindArea;

type
  TcFindArea = class(TClasseFindArea)
  private
  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure novaArea;
    procedure novaArea2;

  published

  end;

implementation


{ ######## TIPOS DE COLUNAS ########
  1: Texto       2: CheckBox    3: Imagem
  4: Increment   5: Rate        6: ComboBox
  7: Progress    8: Numeric     9: Date }

uses Ufuncoes;

{ TcFindArea }

constructor TcFindArea.Create;
var
  TempArea: TAreaCollectionItem;
  TempCampo: TCamposCollectionItem;
begin

  inherited;

  // Cidade
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 1;
    Tabela := 'CIDADE';
    CampoIndice := 'IDCIDADE';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Cidade';
    sql := 'select * from cidade';
    PermitePesqBranco := False;

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idcidade';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Nome';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 25;
      NomeCampo := 'UF';
      Titulo := 'UF';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'COD_MUNICIPIO';
      Titulo := 'Cód. Munc.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Formas de Pagamento
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 2;
    Tabela := 'FORMA_PGTO';
    CampoIndice := 'IDFORMA_PGTO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Formas de Pagamento';
    sql := 'select * from FORMA_PGTO where ( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE  = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDFORMA_PGTO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 300;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Vencimento
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 3;
    Tabela := 'VENCIMENTO';
    CampoIndice := 'IDVENCIMENTO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Vencimentos';
    sql := 'select * from VENCIMENTO  where ( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )  ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idvencimento';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 25;
      NomeCampo := 'STATUS';
      Titulo := 'St';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 300;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Código Tributário
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 4;
    Tabela := 'COD_TRIBUTARIO';
    CampoIndice := 'IDCOD_TRIBUTARIO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Código Tributário';
    sql := 'select * from COD_TRIBUTARIO  where ( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCOD_TRIBUTARIO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 300;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Contas - Crédito
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 5;
    Tabela := 'CAIXA_CONTA';
    CampoIndice := 'IDCAIXA_CONTA';
    CampoLocalizar := 'IDCAIXA_CONTA';

    Titulo := 'Localizando Conta de Crédito (Financeiro)';
    sql := 'SELECT CC.*,' + #13#10 + '(select O_HISTORICO_CONTAPAI from RET_HISTORICO_CAIXACONTA(cc.IDEMPRESA, cc.IDSYS_POINT_CLIENTE, cc.idcaixa_conta))AS FK_PLANOPAI_DESC' + #13#10 + 'FROM CAIXA_CONTA CC' + #13#10 +
      ' where (CC.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') AND (CC.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ') and (CC.ANA_SIN = ' + QuotedStr('A') + ') and (CC.REC_DESP = ' + QuotedStr('R') +
      ') and ( coalesce( cc.status , '''' ) <> ''I'' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 50;
      NomeCampo := 'IDCAIXA_CONTA';
      Titulo := 'Cód. Red.';
      IsFK := True;
      FKCampo := 'CC.IDCAIXA_CONTA';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'CODIGO';
      Titulo := 'Código';
      IsFK := True;
      FKCampo := 'CC.CODIGO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      IsFK := True;
      FKCampo := 'CC.DESCRICAO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'FK_PLANOPAI_DESC';
      Titulo := 'Histórico - Conta Pai';
      CanLocate := False;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Contas - Débito
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 6;
    Tabela := 'CAIXA_CONTA';
    CampoIndice := 'IDCAIXA_CONTA';
    CampoLocalizar := 'IDCAIXA_CONTA';
    Titulo := 'Localizando Conta de débito (Financeiro)';
    sql := 'SELECT CC.*,' + #13#10 + '(select O_HISTORICO_CONTAPAI from RET_HISTORICO_CAIXACONTA(cc.IDEMPRESA, cc.IDSYS_POINT_CLIENTE, cc.idcaixa_conta)) AS FK_PLANOPAI_DESC' + #13#10 + 'FROM CAIXA_CONTA CC' + #13#10 +
      ' where (CC.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') AND (CC.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ') and (CC.ANA_SIN = ' + QuotedStr('A') + ') and (CC.REC_DESP = ' + QuotedStr('D') +
      ')  and ( coalesce( cc.status , '''' ) <> ''I'' )  ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 50;
      NomeCampo := 'IDCAIXA_CONTA';
      Titulo := 'Cód. Red.';
      IsFK := True;
      FKCampo := 'CC.IDCAIXA_CONTA';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'CODIGO';
      Titulo := 'Código';
      IsFK := True;
      FKCampo := 'CC.CODIGO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      IsFK := True;
      FKCampo := 'CC.DESCRICAO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'FK_PLANOPAI_DESC';
      Titulo := 'Histórico - Conta Pai';
      CanLocate := False;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de pessoa
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 7;
    Tabela := 'PESSOA';
    CampoIndice := 'IDPESSOA';
    CampoLocalizar := 'RAZAO_SOCIAL';
    PermitePesqBranco := false;
    Titulo := 'Localizando cadastro de pessoa';
    sql := 'select p.NOME_FANTASIA, p.obs ,p.idpessoa,  p.idrota , p.valorproducao , p.PROFISSAO, p.mei ,p.telefone1, p.FINAN_LIMITE_CREDITO, p.LIBERAVENDA,p.OBSLIBERAVENDA, p.INSCRICAOSUF, ' + #13#10 +
      'p.comissaogerente , p.SUPERVISOR_COMISSAO, p.REPRESENTANTE_IDSUPERVISOR, p.representante_IDGERENTE , ' + #13#10 +
      ' p.IDPESSOATRANS, p.JUR_SUFRAMA , p.JUR_INSC_EST ,  p.idcidade , c.uf as fk_uf  ,  ' + #13#10 +
      ' c.descricao as fk_descrCid, t.descricao as fk_descrtab , p.STATUS, p.RAZAO_SOCIAL, p.JUR_CNPJ, p.FIS_CPF, p.CONF_ISCLIENTE, p.CONF_ISTRANSPORTADORA, p.CONF_ISREPRESENTANTE, p.CONF_ISSUPERVISOR, p.CONF_ISFORNECEDOR,' +
      #13#10 +
      ' p.CONF_ISgerente,P.redespacho, p.idrepresentante , P.IDTABELAPRECO ,  p.CONF_ISFUNCIONARIO, p.CONF_ISFACCIONISTA , p.REPRESENTANTE_COMISSAO, p.IDTABELAPRECO , p.idgrupopessoa , p.SUPERVISOR_COMISSAO ,' + #13#10 +
      ' g.descricao as fk_grupopessoa , p.endereco , c.descricao as fk_nomecidade , p.numero , p.bairro ' + #13#10 + 'from pessoa p' + #13#10 +

    ' left JOIN grupopessoa g ON ( g.idgrupopessoa = p.idgrupopessoa )' + #13#10 +
      ' left join cidade c on  ( c.idcidade = p.idcidade )' + #13#10 + ' left join tabelapreco t on ( t.idtabelapreco = p.idtabelapreco )  and ( t.idsys_point_cliente = p.idsys_point_cliente ) ' + #13#10 +
      ' where ( p.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idpessoa';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'RAZAO_SOCIAL';
      Titulo := 'Razão Social';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);


    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'NOME_FANTASIA';
      Titulo := 'Nome Fantasia';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);




    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 50;
      NomeCampo := 'fk_uf';
      Titulo := 'UF';
      FKCampo := 'c.UF';

      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Mascara := '##.###.###/####-##';
      Tamanho := 160;
      NomeCampo := 'JUR_CNPJ';
      Titulo := 'CNPJ';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 160;
      NomeCampo := 'FIS_CPF';
      Titulo := 'CPF';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISCLIENTE';
      Titulo := 'C';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISTRANSPORTADORA';
      Titulo := 'T';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISREPRESENTANTE';
      Titulo := 'R';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISSUPERVISOR';
      Titulo := 'S';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISFORNECEDOR';
      Titulo := 'F';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISFUNCIONARIO';
      Titulo := 'FU';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISFACCIONISTA';
      Titulo := 'FA';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 18;
      NomeCampo := 'CONF_ISGERENTE';
      Titulo := 'GE';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'fk_grupopessoa';
      FKCampo := 'g.descricao';
      Titulo := 'Grupo Pessoa';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descrCid';
      FKCampo := 'c.descricao';
      Titulo := 'Cidade';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de banco
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 8;
    Tabela := 'BANCO';
    CampoIndice := 'IDBANCO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de banco';
    sql := 'select * from banco where ( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'idbanco';
      Titulo := 'Id:';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 170;
      NomeCampo := 'descricao';
      Titulo := 'Nome';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);

  // cadastro de mensagem
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 9;
    Tabela := 'MENSAGEM';
    CampoIndice := 'IDMENSAGEM';
    CampoLocalizar := 'DESCRICAOMENSAGEM';
    Titulo := 'Localizando cadastro de Mensagem';

    sql := 'select m.idmensagem , m.idempresa,' + #13#10 + 'm.descricaomensagem ,' + #13#10 + 'case m.tipomensagem' + #13#10 + 'when ''1''  then ''Boleta''' + #13#10 + 'when ''2''  then ''Nota de cobrança''' + #13#10 +
      'when ''3''  then ''Aniversário''' + #13#10 + 'when ''4''  then ''Nota fiscal''' + #13#10 + 'when ''5''  then ''Romaneio''  end as fk_tipomensagem,' + #13#10 + 'm.tipomensagem,' + #13#10 + 'm.mensagem' + #13#10 +
      'from mensagem m where ( M.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( m.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDMENSAGEM';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 170;
      NomeCampo := 'DESCRICAOMENSAGEM';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'fk_tipomensagem';
      Titulo := 'TP. Mensagem';
      ShowInFindForm := False;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de natureza operacao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 10;
    Tabela := 'NATUREZA_OPERACAO';
    CampoIndice := 'IDCFOP';
    CampoLocalizar := 'CFOP';
    Titulo := 'Localizando cadastro de CFOP';

    sql := 'select *  from NATUREZA_OPERACAO ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 70;
      NomeCampo := 'IDCFOP';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 25;
      NomeCampo := 'STATUS';
      Titulo := 'St.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 60;
      NomeCampo := 'CFOP';
      Titulo := 'CFOP';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 450;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de cores
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 11;
    Tabela := 'CORES';
    CampoIndice := 'IDCORES';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Cores';

    sql := 'select *  from cores where ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idcores';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'Status';
      Titulo := 'Ativo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de Grupo
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 12;
    Tabela := 'GRUPO';
    CampoIndice := 'IDGRUPO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Grupos';

    sql := 'select g.idgrupo , g.descricao , g.tipogrupo ,' + #13#10 + 'case g.tipogrupo ' + #13#10 + 'when ''P''  then ''Produto''' + #13#10 + 'when ''M''  then ''Matéria Prima''' + #13#10 + 'when ''U''  then ''Uso consumo ''' + #13#10 +
      'when ''A''  then ''Ativo Imobilizado''  end as fk_tipogrupo ' + #13#10 + 'from grupo g where ( g.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( g.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDGRUPO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 170;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 170;
      NomeCampo := 'fk_tipogrupo';
      Titulo := 'TP.Grupo';
      ShowInFindForm := True;
      CanLocate := False;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de Sub Grupo
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 13;
    Tabela := 'SUBGRUPO';
    CampoIndice := 'IDSUBGRUPO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Sub. Grupos';

    sql := 'select sg.idsubgrupo, sg.descricao , sg.tiposubgrupo ,' + #13#10 + 'case sg.tiposubgrupo ' + #13#10 + 'when ''P''  then ''Produto''' + #13#10 + 'when ''M''  then ''Matéria Prima''' + #13#10 + 'when ''U''  then ''Uso consumo '''
      + #13#10 + 'when ''A''  then ''Ativo Imobilizado''  end as fk_tiposubgrupo ' + #13#10 + 'from subgrupo sg where ( SG.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( sg.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDSUBGRUPO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 170;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'fk_tipoSubgrupo';
      Titulo := 'Tp. Sub-Grupo';
      CanLocate := False;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de mercadoria
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 14;
    Tabela := 'MERCADORIA';
    CampoIndice := 'IDMERCADORIA';
    CampoLocalizar := 'referencia';
    Titulo := 'Localizando cadastro de Mercadoria ';

    sql := 'select m.* , m.descricao as fk_descMer , g.descricao  as fk_descGrupo , sg.descricao as fk_descsubGrupo from mercadoria m' + #13#10 +
      'left join grupo  g on ( g.idgrupo = m.idgrupo  ) and ( g.idempresa = m.idempresa  ) and ( g.IDSYS_POINT_CLIENTE = m.IDSYS_POINT_CLIENTE  )' + #13#10 +
      'left join subgrupo  sg on ( sg.idsubgrupo = m.idsubgrupo  ) and ( sg.idempresa = m.idempresa  ) and ( sg.IDSYS_POINT_CLIENTE = m.IDSYS_POINT_CLIENTE  )' + #13#10 + 'where ( M.IDEMPRESA =' + Funcoes.GetIDEmpresa +
      ' ) and ( M.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDMERCADORIA';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'REFERENCIA';
      Titulo := 'Referência';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 360;
      NomeCampo := 'fk_descMer';
      FKCampo := 'M.descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      IsFK := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'CLASSIFICACAO';
      Titulo := 'NCM';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descGrupo';
      FKCampo := 'g.descricao';
      Titulo := 'Descr. Grupo';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descsubGrupo';
      FKCampo := 'sg.descricao';
      Titulo := 'Descr. Sub. Grupo';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'ALIQUOTAIBPT';
      Titulo := 'Aliq. IBPT';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de tamanhos
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 15;
    Tabela := 'TAMANHO';
    CampoIndice := 'IDTAMANHO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Tamanho ';

    sql := 'select * from tamanho where ( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ORDER BY codigotaman ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idtamanho';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'descricao';
      Titulo := 'Tamanho';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de tabela de preco
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 16;
    Tabela := 'TABELAPRECO';
    CampoIndice := 'IDTABELAPRECO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Tabela preço ';

    sql := ' select * from tabelapreco where ( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDTABELAPRECO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 280;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcCheckBox;
      Tamanho := 28;
      NomeCampo := 'TAB_INVENTARIO';
      Titulo := 'Inv?';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 60;
      NomeCampo := 'TAB_INVENTARIO_ANO';
      Titulo := 'Inv. Ano';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de materia prima
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 17;
    Tabela := 'MATERIAPRIMA';
    CampoIndice := 'IDMATERIA';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Matéria prima ';

    sql := 'select * from materiaprima  where ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDMATERIA';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'REFERENCIA';
      Titulo := 'Referência';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'CLASSIFICACAO';
      Titulo := 'NCM';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'unidade';
      Titulo := 'UN';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'Baixa_manual';
      Titulo := 'Baixa manual';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de produto acabado
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 18;
    Tabela := 'PRODUTO';
    CampoIndice := 'IDPRODUTO';
    CampoLocalizar := 'fk_REFERENCIA';
    Titulo := 'Localizando cadastro de Produtos ';

    sql := 'select' + #13#10 + ' m.idmercadoria fk_idmercadoria , p.estoqueloja, p.codigobarra  as codigobarra ,' + #13#10 + 'p.estoqueatual ,' + #13#10 + 'p.estoquemin ,' + #13#10 + 'p.foto ,' + #13#10 + 'p.idcores,' + #13#10 +
      'p.idempresa,' + #13#10 + 'p.idmercadoria,'
      + #13#10 + 'p.idproduto,' + #13#10 + 'p.idtamanho,' + #13#10 + 'p.localizacao,' + #13#10 + 'p.permitedesconto,' + #13#10 + 'p.referencia as fk_referencia ,' + #13#10 + 'p.reservado ,' + #13#10 + 'p.saldodisponivel,' + #13#10 +
      'p.tipoproduto ,' + #13#10 + 'p.unidade ,' + #13#10 + 'm.descricao as fk_descrMer ,' + #13#10 + 't.descricao as fk_desctam ,' + #13#10 + 'c.descricao AS fk_desccor,' + #13#10 + 'case p.tipoproduto' + #13#10 +
      'WHEN ''1''  THEN ''Proprio''' + #13#10 + 'WHEN ''2''  THEN ''Terceiros''' + #13#10 + 'WHEN ''3''  THEN ''Terceiros p/ brinde''' + #13#10 + 'WHEN ''4''  THEN ''Proprio p/ brinde''' + #13#10 + 'END as Tipo,' + #13#10 +
      'case p.permitedesconto' + #13#10 + 'WHEN ''1'' THEN ''Sim''' + #13#10 + 'WHEN ''2'' THEN ''Não''' + #13#10 + 'END as PermiteDesconto' + #13#10 + 'from produto p' + #13#10 + 'left join cores  c on ( c.idcores = p.idcores  )' + #13#10
      + 'left join tamanho  t on ( t.idtamanho = p.idtamanho  ) and ( t.idempresa = p.idempresa  ) and ( t.IDSYS_POINT_CLIENTE = p.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      'left join mercadoria  m on ( m.idmercadoria = p.idmercadoria  ) and ( m.idempresa = p.idempresa  ) and ( m.IDSYS_POINT_CLIENTE = p.IDSYS_POINT_CLIENTE  )' + #13#10 + 'where ( p.IDEMPRESA = ' + Funcoes.GetIDEmpresa +
      ' ) and ( p.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) order by  p.referencia , c.descricao, t.codigotaman ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDPRODUTO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'fk_REFERENCIA';
      FKCampo := 'p.referencia';
      Titulo := 'Referência';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_descrMer';
      FKCampo := 'm.descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'fk_desccor';
      FKCampo := 'c.descricao';
      Titulo := 'Cor';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'fk_desctam';
      FKCampo := '.descricao';
      Titulo := 'UN';
      ShowInFindForm := True;
      CanLocate := False;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'ESTOQUEATUAL';
      Titulo := 'Saldo';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'saldodisponivel';
      Titulo := 'Disponivel';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'estoqueloja';
      Titulo := 'Est. loja';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'reservado';
      Titulo := 'Reservado';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'codigobarra';
      Titulo := 'Cod. barra';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'permitedesconto';
      Titulo := 'Permite desc.';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_IDMERCADORIA';
      FKCampo := 'm.IDMERCADORIA';
      Titulo := 'Id.Merc.';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Itens Matéria prima
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 19;
    Tabela := 'ITENSMATERIAPRIMA';
    CampoIndice := 'IDITENSMATERIAPRIMA';
    CampoLocalizar := 'fk_desccor';
    Titulo := ' Localizando Itens das matérias primas ';

    sql := 'select m.unidade, im.iditensmateriaprima ,' + #13#10 + 'c.IDCORES ,' + #13#10 + 'c.DESCRICAO as fk_desccor ,' + #13#10 + 'im.codbar,' + #13#10 + 'im.preco, im.codbar ,' + #13#10 + 'im.idmateria,' + #13#10 + 'im.quantidade ,' +
      #13#10 +
      'im.disponivel ,' + #13#10 + 'im.reservado' + #13#10 + 'from itensmateriaprima IM' + #13#10 +
      ' left join materiaprima m on ( m.idmateria = im.idmateria )' + #13#10 +
      'left join cores c on ( c.idcores = im.idcores )' + #13#10 + 'where ( im.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( im.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'iditensmateriaprima';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_desccor';
      FKCampo := 'c.DESCRICAO';
      Titulo := 'Cor';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'codbar';
      Titulo := 'Cod. barra';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // consulta de produtos
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 20;
    Tabela := 'PRODUTO';
    CampoIndice := 'IDPRODUTO';
    CampoLocalizar := 'M.REFERENCIA';
    Titulo := ' Localizando Itens dos produtos ';

    sql := '  select' + #13#10 + 'm.idmercadoria ,' + #13#10 + 'm.referencia ,' + #13#10 + 'm.descricao,' + #13#10 + 'g.descricao as fk_descGru,' + #13#10 + 's.descricao as fk_descSub , ct.descricao as fk_descrTrib ' + #13#10 +
      'from mercadoria m' + #13#10 + 'left join grupo  g on ( g.idgrupo = m.idgrupo  ) and ( g.idempresa = m.idempresa  ) and ( g.IDSYS_POINT_CLIENTE = m.IDSYS_POINT_CLIENTE  )' + #13#10 +
      'left join subgrupo  s on ( s.idsubgrupo = m.idsubgrupo  ) and ( s.idempresa = m.idempresa  ) and ( s.IDSYS_POINT_CLIENTE = m.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      'left join cod_tributario  ct on ( ct.idcod_tributario = m.idtributo  ) and ( ct.idempresa = m.idempresa  ) and ( ct.IDSYS_POINT_CLIENTE = m.IDSYS_POINT_CLIENTE  ) ' + #13#10 + 'where ( m.IDEMPRESA = ' + Funcoes.GetIDEmpresa +
      ' ) and ( m.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idmercadoria';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'referencia';
      Titulo := 'Referência';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      IsFK := True;
      FKCampo := 'm.descricao';

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // consulta de Ativo imo / Uso consumo
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 21;
    Tabela := 'USOATIVO';
    CampoIndice := 'IDUSOATIVO';
    CampoLocalizar := 'referencia';
    Titulo := ' Localizando Uso consumo / Ativo imobilizado ';

    sql := 'select u.*,' + #13#10 + 'g.descricao as fk_DesGru ,' + #13#10 + 's.descricao as fk_DescSub , case when u.tipo = ''A'' then ''Ativo Imobilizado'' when u.tipo = ''U'' then ''Uso e consumo'' end as fk_tipo ,' + #13#10 +
      'c.descricao as fk_desctrib' + #13#10 + 'from usoativo u' + #13#10 + 'left join grupo g on ( (  g.idgrupo = u.idgrupo  ) and ( g.idempresa = u.idempresa ) and ( g.IDSYS_POINT_CLIENTE = u.IDSYS_POINT_CLIENTE  )  )' + #13#10 +
      'left join subgrupo s on (( s.idsubgrupo = u.idsubgrupo ) and ( s.idempresa = u.idempresa  ) and ( s.IDSYS_POINT_CLIENTE = u.IDSYS_POINT_CLIENTE  ) )' + #13#10 +
      'left join cod_tributario c on (( c.idcod_tributario = u.idcod_tributario ) and ( c.idempresa = u.idempresa  ) and ( c.IDSYS_POINT_CLIENTE = u.IDSYS_POINT_CLIENTE  )  )' + #13#10 + 'where ( u.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( u.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDUSOATIVO';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'referencia';
      Titulo := 'Referência';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      IsFK := True;
      FKCampo := 'u.descricao';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'fk_tipo';
      Titulo := 'Tipo Produto';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'estoque';
      Titulo := 'Estoque';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Saida de materia prima
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 22;
    Tabela := 'SAIDAMATERIAPRIMA';
    CampoIndice := 'IDSAIDAMATERIA';
    CampoLocalizar := 'DATASAIDA';
    Titulo := ' Localizando Saída matéria prima manual ';

    sql := 'select * from saidamateriaprima where (  idempresa = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDSAIDAMATERIA';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'datasaida';
      Titulo := 'Data de saída';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Saida de Uso e consumo
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 23;
    Tabela := 'SAIDAUSOATIVO';
    CampoIndice := 'IDSAIDAUSOATIVO';
    CampoLocalizar := 'DATA';
    Titulo := ' Localizando Saída Uso e Consumo / Ativo Imobilizado ';

    sql := 'select u.descricao as fk_descricao , u.tipo , s.* from saidausoativo S' + #13#10 +
      'LEFT JOIN usoativo u ON ( u.idusoativo = s.idusoativo ) and ( u.idempresa = s.idempresa ) and ( u.IDSYS_POINT_CLIENTE = s.IDSYS_POINT_CLIENTE  ) ' + #13#10 + 'where ( S.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( s.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDSAIDAUSOATIVO';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'data';
      Titulo := 'Data de saída';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;
      NomeCampo := 'tipo';
      Titulo := 'Ativo/Uso e consumo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'quantidade';
      Titulo := 'Qtd. Saída';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Contas a pagar
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 24;
    Tabela := 'CONTA_PAGAR';
    CampoIndice := 'IDCONTA_PAGAR';
    CampoLocalizar := 'fk_razao_social';
    Titulo := ' Localizando Contas à pagar ';

    sql := 'select  cp.* ,' + #13#10 + 'p.razao_social as fk_razao_social ,' + #13#10 + 'v.descricao    as fk_descr_Venc' + #13#10 + 'from conta_pagar cp' + #13#10 +
      'LEFT JOIN pessoa p ON ( p.idpessoa = cp.idpessoa ) and ( p.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( v.idvencimento = cp.idvencimento ) and ( v.idempresa = cp.idempresa )  and ( v.IDSYS_POINT_CLIENTE = cp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + 'where   ( cp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( cp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_PAGAR';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'nota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_razao_social';
      IsFK := True;
      FKCampo := 'p.razao_social';
      IsFK := True;
      Titulo := 'Nome';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Vlr. C. pagar';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Caixa
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 25;
    Tabela := 'CAIXA';
    CampoIndice := 'IDCAIXA';
    CampoLocalizar := 'FK_CONTA_DESC';
    Titulo := ' Localizando Caixa ';

    sql := 'SELECT C.* , c.idcaixa_conta as fk_idcaixa_conta ,CC.DESCRICAO AS FK_CONTA_DESC ,cc.rec_desp as fk_tipoMov' + #13#10 + 'FROM CAIXA C' + #13#10 +
      'LEFT JOIN CAIXA_CONTA CC ON (CC.IDCAIXA_CONTA = C.IDCAIXA_CONTA) and ( cc.idempresa = c.idempresa )  and ( cc.IDSYS_POINT_CLIENTE = c.IDSYS_POINT_CLIENTE  )  ' + #13#10 + 'where   ( CC.idempresa = ' + Funcoes.GetIDEmpresa +
      ' )  and ( cc.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCAIXA';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'FK_CONTA_DESC';
      FKCampo := 'CC.DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      IsFK := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'historico';
      Titulo := 'Histórico';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'data_mov';
      Titulo := 'Dt. Movimento';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Valor';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'FK_TIPOMOV';
      FKCampo := 'CC.REC_DESP';
      Titulo := 'Tipo Mov.';
      ShowInFindForm := True;
      IsFK := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'FK_idcaixa_conta';
      FKCampo := 'c.IDCAIXA_CONTA';
      Titulo := 'Cod Cxa.Conta';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Contas - Crédito + debito somente analitico
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 26;
    Tabela := 'CAIXA_CONTA';
    CampoIndice := 'IDCAIXA_CONTA';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Conta de Crédito (Financeiro)';
    sql := 'SELECT CC.*,' + #13#10 + '(select O_HISTORICO_CONTAPAI from RET_HISTORICO_CAIXACONTA(cc.IDEMPRESA, cc.IDSYS_POINT_CLIENTE, cc.idcaixa_conta)) AS FK_PLANOPAI_DESC' + #13#10 + 'FROM CAIXA_CONTA CC' + #13#10 +
      ' where (CC.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') AND (CC.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ') and (CC.ANA_SIN = ' + QuotedStr('A') + ')  and ( coalesce( cc.status , '''' ) <> ''I'' )  ';
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 50;
      NomeCampo := 'IDCAIXA_CONTA';
      Titulo := 'Cód. Red.';
      IsFK := True;
      FKCampo := 'CC.IDCAIXA_CONTA';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'CODIGO';
      Titulo := 'Código';
      IsFK := True;
      FKCampo := 'CC.CODIGO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      IsFK := True;
      FKCampo := 'CC.DESCRICAO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 30;
      NomeCampo := 'Rec_Desp';
      Titulo := 'R/D';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'FK_PLANOPAI_DESC';
      Titulo := 'Histórico - Conta Pai';
      CanLocate := False;
    end;
    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);

  // contas a pagar parcelas somente para baixa
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 27;
    Tabela := 'CONTA_PAGAR_PARCELA';
    CampoIndice := 'IDCONTA_PAGAR_PARCELA';
    CampoLocalizar := 'IDCONTA_PAGAR_parcela';
    Titulo := 'Localizando duplicatas do contas pagar ';

    sql := 'SELECT  CPP.* , V.descricao AS FK_VENC_DESC ,f.descricao as fk_descr_pgto' + #13#10 + ' FROM conta_pagar_parcela CPP' + #13#10 +
      ' LEFT JOIN conta_pagar cp ON ( cp.idconta_pagar = CPP.idconta_pagar ) and ( cp.idempresa = cpp.idempresa ) and ( cp.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  )' + #13#10 +
      ' LEFT JOIN forma_pgto f ON ( f.idforma_pgto = CPp.idforma_pgto ) and ( f.idempresa = cpp.idempresa ) and ( f.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( V.idvencimento = CP.idvencimento ) and ( v.idempresa = cpp.idempresa ) and ( v.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + ' where ( cpp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( cpp.status <> ''F'' ) and ( cpp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_PAGAR_parcela';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'no_parcela';
      Titulo := 'Parcela';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_vencimento';
      Titulo := 'Dt. Vencimento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor_pago';
      Titulo := 'Vlr. pago';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 75;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;

      NomeCampo := 'fk_descr_pgto';
      FKCampo := 'f.descricao';
      Titulo := 'Forma Pgto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'juros';
      Titulo := 'Juros';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'abatimento';
      Titulo := 'Abatimento';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // parcelas do contas a pagar que estão baixadas
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 28;
    Tabela := 'CONTA_PAGAR_PARCELA';
    CampoIndice := 'IDCONTA_PAGAR_PARCELA';
    CampoLocalizar := 'IDCONTA_PAGAR_parcela';
    Titulo := 'Localizando duplicatas do contas pagar ';

    sql := 'SELECT  CPP.* , V.descricao AS FK_VENC_DESC ,f.descricao as fk_descr_pgto' + #13#10 + ' FROM conta_pagar_parcela CPP' + #13#10 +
      ' LEFT JOIN conta_pagar cp ON ( cp.idconta_pagar = CPP.idconta_pagar ) and ( cp.idempresa = cpp.idempresa ) and ( cp.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN forma_pgto f ON ( f.idforma_pgto = CPp.idforma_pgto ) and ( f.idempresa = cpp.idempresa ) and ( f.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( V.idvencimento = CP.idvencimento ) and ( v.idempresa = cpp.idempresa ) and ( v.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + ' where ( cpp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( cpp.status <> ''A'' ) and ( cpp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_PAGAR_parcela';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'no_parcela';
      Titulo := 'Parcela';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_vencimento';
      Titulo := 'Dt. Vencimento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor_pago';
      Titulo := 'Vlr. pago';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 75;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;

      NomeCampo := 'fk_descr_pgto';
      FKCampo := 'f.descricao';
      Titulo := 'Forma Pgto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'juros';
      Titulo := 'Juros';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'abatimento';
      Titulo := 'Abatimento';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // parcelas do contas a pagar pag
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 29;
    Tabela := 'CONTA_PAGAR_PAG';
    CampoIndice := 'IDCONTA_PAGAR_PAG';
    CampoLocalizar := 'IDCONTA_PAGAR_PAG';
    Titulo := 'Localizando pagamento duplicatas do contas pagar ';

    sql := 'SELECT  CPP.* , V.descricao AS FK_VENC_DESC ,f.descricao as fk_descr_pgto FROM conta_pagar_pag CPP' + #13#10 +
      ' LEFT JOIN conta_pagar cp ON ( cp.idconta_pagar = CPP.idconta_pagar ) and ( cp.idempresa = cpp.idempresa ) and ( cp.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  )' + #13#10 +
      ' LEFT JOIN forma_pgto f ON ( f.idforma_pgto = CPp.idforma_pgto ) and ( f.idempresa = cpp.idempresa ) and ( f.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( V.idvencimento = CP.idvencimento ) and ( v.idempresa = cpp.idempresa ) and ( v.IDSYS_POINT_CLIENTE = cpp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + ' where ( cpp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( cpp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_PAGAR_pag';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_mov';
      Titulo := 'Dt. pagamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;

      NomeCampo := 'fk_descr_pgto';
      FKCampo := 'f.descricao';
      Titulo := 'Forma Pgto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'juros';
      Titulo := 'Juros';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'abatimento';
      Titulo := 'Abatimento';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'idconta_pagar_parcela';
      Titulo := 'Cod. C.pagar Parc.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // notas de entrada
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 30;
    Tabela := 'NOTAENTRADA';
    CampoIndice := 'IDNOTAENTRADA';
    CampoLocalizar := 'IDNOTAENTRADA';
    Titulo := 'Localizando Notas de entradas ';

    sql := 'select n.*,' + #13#10 + 'p.razao_social as fk_razao_social ,' + #13#10 + 'p.jur_cnpj as fk_jur_cnpj,' + #13#10 + 'p.jur_insc_est_uf as fk_jur_insc_est_uf,' + #13#10 + 'o.cfop as  fk_cfop ,' + #13#10 +
      'o.descricao as fk_descricaoCFOP,' + #13#10 + 'v.descricao as fk_descricao_venc ,' + #13#10 + 'v.num_parcelas as fk_num_parcelas ,' + #13#10 + 'om.cfop as fk_cfopmat,' + #13#10 + 'nop.cfop as fk_cfopNota,' + #13#10 +
      'nop.descricao as fk_descCfopNota,' + #13#10 + 'case' + #13#10 + 'when n.tipo_produto = ''M''   then  ''Matéria prima''' + #13#10 + 'when n.tipo_produto = ''P''   then  ''Produto acabado''' + #13#10 +
      'when n.tipo_produto = ''C''   then  ''Uso consumo''' + #13#10 + 'when n.tipo_produto = ''I''   then  ''Ativo imobilizado''' + #13#10 + 'when n.tipo_produto = ''L''   then  ''NF Complementar''' + #13#10 +
      'when n.tipo_produto = ''S''   then  ''Prestação de serviços''' + #13#10 + 'when n.tipo_produto = ''T''   then  ''Escolher por itens''' + #13#10 + 'when n.tipo_produto = ''O''   then  ''Outras Notas''' + #13#10 +
      'end as fk_tiponota from notaentrada n ' + #13#10 + 'left join pessoa p on ( ( p.idpessoa = n.idpessoa_idfornecedor ) and ( p.idsys_point_cliente = n.idsys_point_cliente ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( v.idvencimento = n.idvencimento ) and ( v.idsys_point_cliente = n.idsys_point_cliente ) and ( v.idempresa = n.idempresa ) )' + #13#10 +
      'left join natureza_operacao O on  ( o.idcfop = n.idcfop_outradesp ) ' + #13#10 + 'left join natureza_operacao Om on  ( om.idcfop = n.idcfopmateria ) ' + #13#10 + 'left join natureza_operacao nop on ( nop.idcfop = n.idcfop ) ' +
      #13#10 + 'where ( n.idempresa = ' + Funcoes.GetIDEmpresa + ' ) and ( n.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDNOTAENTRADA';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATAENTRADA';
      Titulo := 'Dt.Entrada';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'NUMERONOTA';
      Titulo := 'Num. Nota';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;

      NomeCampo := 'fk_razao_social';
      FKCampo := 'p.razao_social';
      Titulo := 'Fornecedor';
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'VALOR_TOTAL_NOTA';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'TIPO_PRODUTO';
      Titulo := 'Tipo Nota';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // conhecimento de frete nota de entrada
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 31;
    Tabela := 'FRETES';
    CampoIndice := 'IDFRETE';
    CampoLocalizar := 'IDFRETE';
    Titulo := 'Localizando Fretes das Notas de entradas ';

    sql := 'select f.*,p.razao_social as fk_razao_social ,p.jur_cnpj as fk_jur_cnpj,' + #13#10 + 'p.jur_insc_est_uf as fk_jur_insc_est_uf, o.cfop as  fk_cfop ,' + #13#10 + 'o.descricao as fk_descricaoCFOP from fretes f' + #13#10 +
      'left join pessoa p on ( ( p.idpessoa = f.idpessoa_transp ) and ( p.idsys_point_cliente = f.idsys_point_cliente ) )' + #13#10 + 'left join natureza_operacao O on ( o.idcfop = f.idcfop ) ' + #13#10 + 'where ( f.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( f.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idfrete';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 100;
      NomeCampo := 'NUMERO_FC';
      Titulo := 'Nº Conhecimento';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'ENTRADA_FC';
      Titulo := 'Dt.Entrada';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_RAZAO_SOCIAL';
      FKCampo := 'p.razao_social';
      Titulo := 'Fornecedor';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'vl_contabil_fc';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 100;
      NomeCampo := 'NOTA_FC';
      Titulo := 'Nº Nota entrada';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  ///
  ///
  /// contas a receber
  ///
  ///

  // contas a receber parcelas somente para baixa
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 37;
    Tabela := 'CONTA_RECEBER_PARCELA';
    CampoIndice := 'IDCONTA_RECEBER_PARCELA';
    CampoLocalizar := 'IDCONTA_RECEBER_parcela';
    Titulo := 'Localizando duplicatas do contas Receber ';

    sql := 'SELECT  CrP.* , crp.valor as fk_valor , crp.valor_pago as fk_valor_pago , V.descricao AS FK_VENC_DESC ,f.descricao as fk_descr_pgto' + #13#10 + ' FROM conta_receber_parcela CrP' + #13#10 +
      ' LEFT JOIN conta_receber cr ON ( cr.idconta_receber = CrP.idconta_receber ) and ( cr.idempresa = crp.idempresa ) and ( cr.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  )' + #13#10 +
      ' LEFT JOIN forma_pgto f ON ( f.idforma_pgto = Crp.idforma_pgto ) and ( f.idempresa = crp.idempresa ) and ( f.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( V.idvencimento = Cr.idvencimento ) and ( v.idempresa = crp.idempresa ) and ( v.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + ' where ( crp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( crp.status <> ''F'' ) and ( crp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_receber_parcela';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'no_parcela';
      Titulo := 'Parcela';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'NOSSONUMEROBANCO';
      Titulo := 'Nosso Num.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_vencimento';
      Titulo := 'Dt. Vencimento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'fk_valor';
      FKCampo := 'crp.valor';
      Titulo := 'Valor';

      Mascara := '###,##0.00';
      IsFK := True;
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin

      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'FK_valor_pago';
      FKCampo := 'crp.valor_pago';
      Titulo := 'Vlr. pago';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
      IsFK := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 75;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;

      NomeCampo := 'fk_descr_pgto';
      FKCampo := 'f.descricao';
      Titulo := 'Forma Pgto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'juros';
      Titulo := 'Juros';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'abatimento';
      Titulo := 'Abatimento';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // parcelas do contas a pagar que estão baixadas
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 38;
    Tabela := 'CONTA_RECEBER_PARCELA';
    CampoIndice := 'IDCONTA_receber_PARCELA';
    CampoLocalizar := 'IDCONTA_receber_parcela';
    Titulo := 'Localizando duplicatas do contas receber ';

    sql := 'SELECT  CrP.* , V.descricao AS FK_VENC_DESC ,f.descricao as fk_descr_pgto' + #13#10 + ' FROM conta_receber_parcela CrP ' + #13#10 +
      ' LEFT JOIN conta_receber cr ON ( cr.idconta_receber = CrP.idconta_receber ) and ( cr.idempresa = crp.idempresa ) and ( cr.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN forma_pgto f ON ( f.idforma_pgto = Crp.idforma_pgto ) and ( f.idempresa = crp.idempresa ) and ( f.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( V.idvencimento = Cr.idvencimento ) and ( v.idempresa = crp.idempresa ) and ( v.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + ' where ( crp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( crp.status <> ''A'' ) and ( crp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_receber_parcela';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'no_parcela';
      Titulo := 'Parcela';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_vencimento';
      Titulo := 'Dt. Vencimento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor_pago';
      Titulo := 'Vlr. pago';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 75;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;

      NomeCampo := 'fk_descr_pgto';
      FKCampo := 'f.descricao';
      Titulo := 'Forma Pgto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'juros';
      Titulo := 'Juros';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'abatimento';
      Titulo := 'Abatimento';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // parcelas do contas a receber pag
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 39;
    Tabela := 'CONTA_recber_PAG';
    CampoIndice := 'IDCONTA_recber_PAG';
    CampoLocalizar := 'IDCONTA_receber_PAG';
    Titulo := 'Localizando pagamento duplicatas do contas receber ';

    sql := 'SELECT  CrP.* , V.descricao AS FK_VENC_DESC ,f.descricao as fk_descr_pgto FROM conta_receber_pag CrP' + #13#10 +
      ' LEFT JOIN conta_receber cr ON ( cr.idconta_receber = CrP.idconta_receber ) and ( cr.idempresa = crp.idempresa ) and ( cr.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  )' + #13#10 +
      ' LEFT JOIN forma_pgto f ON ( f.idforma_pgto = Crp.idforma_pgto ) and ( f.idempresa = crp.idempresa ) and ( f.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( V.idvencimento = Cr.idvencimento ) and ( v.idempresa = crp.idempresa ) and ( v.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + ' where ( crp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( crp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_receber_pag';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_mov';
      Titulo := 'Dt. pagamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;

      NomeCampo := 'fk_descr_pgto';
      FKCampo := 'f.descricao';
      Titulo := 'Forma Pgto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'juros';
      Titulo := 'Juros';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'abatimento';
      Titulo := 'Abatimento';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'Creditousado';
      Titulo := 'Crédito usado';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_receber_parcela';
      Titulo := 'Id. Cr. Parcela';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // parcelas do contas a receber
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 33;
    Tabela := 'CONTA_receber_PAG';
    CampoIndice := 'IDCONTA_receber_PAG';
    CampoLocalizar := 'IDCONTA_receber_PAG';
    Titulo := 'Localizando pagamento duplicatas do contas receber ';

    sql := 'SELECT  CRP.* , V.descricao AS FK_VENC_DESC ,f.descricao as fk_descr_pgto FROM conta_receber_pag CRP' + #13#10 +
      ' LEFT JOIN conta_receber cr ON ( cr.idconta_receber = CRP.idconta_receber ) and ( cr.idempresa = crp.idempresa ) and ( cr.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  )' + #13#10 +
      ' LEFT JOIN forma_pgto f ON ( f.idforma_pgto = Crp.idforma_pgto ) and ( f.idempresa = crp.idempresa ) and ( f.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( V.idvencimento = Cr.idvencimento ) and ( v.idempresa = crp.idempresa ) and ( v.IDSYS_POINT_CLIENTE = crp.IDSYS_POINT_CLIENTE  ) ' + #13#10 + ' where ( crp.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( crp.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_receber_pag';
      Titulo := 'codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_mov';
      Titulo := 'Dt. pagamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'valor';
      Titulo := 'Valor';

      Mascara := '###,##0.00';

      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;

      NomeCampo := 'fk_descr_pgto';
      FKCampo := 'f.descricao';
      Titulo := 'Forma Pgto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'juros';
      Titulo := 'Juros';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'abatimento';
      Titulo := 'Abatimento';
      Mascara := '###,##0.00';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Contas a receber
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 34;
    Tabela := 'CONTA_receber';
    CampoIndice := 'IDCONTA_receber';
    CampoLocalizar := 'FK_razao_social';
    Titulo := ' Localizando Contas à receber ';
    sql := 'select cr.* ,cr.idpessoa as fk_idpessoa, p.razao_social as fk_razao_social ,' + #13#10 + 'v.descricao    as fk_descr_Venc' + #13#10 + 'from conta_receber cr' + #13#10 +
      'LEFT JOIN pessoa p ON ( p.idpessoa = cr.idpessoa ) and ( p.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) ' + #13#10 +
      ' LEFT JOIN vencimento v ON ( v.idvencimento = cr.idvencimento ) and ( v.idempresa = cr.idempresa )  and ( v.IDSYS_POINT_CLIENTE = cr.IDSYS_POINT_CLIENTE  ) ' + #13#10 + 'where   ( cr.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( cr.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCONTA_recebeR';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'nota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'fk_idpessoa';
      IsFK := True;
      FKCampo := 'cr.idpessoa';
      Titulo := 'Cod.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_razao_social';
      IsFK := True;
      FKCampo := 'p.razao_social';
      Titulo := 'Nome do Cliente';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Vlr.C.receber';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDPEDIDO';
      Titulo := 'ID. Pedido';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);

  ///
  ///
  ///
  ///
  ///

  // Pedidos
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 40;
    Tabela := 'pedido';
    CampoIndice := 'fk_idpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos ';

    sql := 'select distinct  ped.IDPESSOAENTREGA,ped.NUMEROPEDIDORELATORIO, ped.protocolo_epec, ped.IDPEDIDOANTIGO, pcli.mei, ped.rejeitado, ped.idpedido as fk_idpedido , ' + #13#10 +
      ' ped.IDORD_PRODUCAO , ped.numeronota, Ped.idpessoa_cliente fk_idpessoa_cliente , ped.ufembarq , ped.locaembarq ,ped.idcaixa , ped.idconta_receber ,' + #13#10 + #13#10 +
      'ped.IDPEDIDO_WEBCONFLEX, ped.idforma_pgto, fo.descricao  as fk_descr_forpgto , ped.notaenviada , ped.envioucontigencia,ped.contigencia , ped.serie,ped.hora,ped.nfe_id ,ped.obs_fiscal,ped.contigencia ,' + #13#10 +
      'pcli.redespacho,ped.datasaida,ped.dtemissao,ped.dtentradafabrica , ped.DTENTREGA,' + #13#10 + 'ped.status ,ped.numeropedido,ped.desmembra ,ped.cobrafrete ,' + #13#10 +
      'ped.bonificacao ,ped.pispasep ,ped.confins,ped.frete , ped.internet, ped.exportado ,' + #13#10
      + ' ped.idpessoa_gerente , ped.idpessoa_supervisor, ped.comissaogerente , ped.comissaosupervisor, ped.comissao , ' + #13#10 + ' ped.programado ,ped.manifesto,ped.dtfaturamento ,' + #13#10 +
      'ped.tipofrete ,ped.opcao,ped.mostruario ,ped.idmensagem,' + #13#10 + ' ped.numeronota as fk_numeronota ,ped.idcfop , ped.valorfrete , ped.valortotal ,ped.valordesconto ,ped.idpessoa_cliente , ' + #13#10 +
      ' ped.idpessoa_representante , ped.idvencimento ,ped.volume ,ped.dadosadicionais ,ped.idcfop_terceiro,ped.idcfop_brinde,ped.pesobruto , ' + #13#10 + ' ped.pesoliquido , ped.liberapedido , ped.especie , ' + #13#10 +
      'B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 + 'pcli.endereco as fk_ENDCLI,' + #13#10 + 'pcli.bairro as fk_cliBAIRRO,'
      +
      #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 + 'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 + 'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 +
      'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' + #13#10 + 'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 +
      'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10 + 'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 +
      'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 +
      'cre.idconta_receber as FK_CONTARECEBER,CAIX.idcaixa as FK_IDCAIXA , pger.razao_social as fk_gerente, psup.razao_social as fk_supervisor  from PEDIDO ped' + #13#10 +
      'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 + 'left join NATUREZA_OPERACAO N on  ( N.idcfop = Ped.idcfop ) ' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente )  and ( pcli.conf_iscliente = ''S'' )  )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( PREP.idpessoa = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente ) and ( prep.conf_isrepresentante = ''S'' ) )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 +
      ' LEFT JOIN forma_pgto fo ON ( ( fo.idforma_pgto = PED.idforma_pgto ) AND ( fo.idsys_point_cliente = PED.IDSYS_POINT_CLIENTE ) AND ( fo.idempresa = PED.IDEMPRESA ) )' + #13#10 +
      ' left join pessoa pger on ( ( Pger.idpessoa = Ped.idpessoa_gerente ) and ( pger.idsys_point_cliente = ped.idsys_point_cliente ) and ( pger.conf_isgerente = ''S'' ) ) ' + #13#10 +
      ' left join pessoa psup on ( ( Psup.idpessoa = Ped.idpessoa_supervisor ) and ( psup.idsys_point_cliente = ped.idsys_point_cliente ) and ( psup.conf_issupervisor = ''S'' ) ) ' + #13#10 + ' where   ( ped.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ( ped.tipopedido = ''PV'' ) or ( ped.tipopedido = ''CU'' ))';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'fk_idpessoa_cliente';
      IsFK := True;
      FKCampo := 'Ped.idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;
      // CanLocate := False;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_DESCCLI';
      IsFK := True;
      FKCampo := 'PCLI.RAZAO_SOCIAL';
      Titulo := 'Nome';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 50;
      NomeCampo := 'fk_CLICNPJ';
      IsFK := True;
      FKCampo := 'pcli.jur_cnpj';
      Titulo := 'CNPJ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;
      NomeCampo := 'NUMEROPEDIDORELATORIO';
      Titulo := 'Num. Ped. Relatório';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtentrega';
      Titulo := 'Dt. entrega';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'IDPEDIDOANTIGO';
      Titulo := 'Ped. original';
      ShowInFindForm := True;
      CanLocate := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'IDORD_PRODUCAO';
      Titulo := 'Ordem prod.';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'Internet';
      Titulo := 'Veio da internet';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'IDPEDIDO_WEBCONFLEX';
      Titulo := 'ID. Web_conflex';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'programado';
      Titulo := '1 Prog 2 não prog';
      ShowInFindForm := True;
      CanLocate := False;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // precos para itens dos produtos
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 41;
    Tabela := 'tabelaprecoitens';
    CampoIndice := 'IDtabelaprecoitens';
    CampoLocalizar := 'idtabelaprecoitens';
    Titulo := ' Localizando preços dos produtos ';

    sql := 'select tab.idtabelaprecoitens , tab.preco  , t.descricao as fk_descrtab from tabelaprecoitens tab' + #13#10 +
      'left join tabelapreco  t on ( t.idtabelapreco = tab.idtabelapreco  ) and ( t.idempresa = tab.idempresa  ) and ( t.idsys_point_cliente = tab.idsys_point_cliente  )' + #13#10 + 'where   ( tab.idempresa =' + Funcoes.GetIDEmpresa +
      ' ) and ( tab.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idtabelaprecoitens';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'preco';
      Titulo := 'Preço';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_DESCrtab';
      FKCampo := 't.descricao';
      Titulo := 'Tabela';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Pedidos  venda diversa
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 42;
    Tabela := 'pedido';
    CampoIndice := 'fk_IDpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos Venda diversa ';

    sql := 'select distinct Ped.*,ped.idpedido as fk_idpedido ,B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 +
      'pcli.endereco as fk_ENDCLI,' + #13#10 + 'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 +
      'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 + 'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' +
      #13#10 + 'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 + 'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10
      + 'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 + 'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 +
      'CAIX.idcaixa as FK_IDCAIXA , pger.razao_social as fk_gerente, psup.razao_social as fk_supervisor from PEDIDO ped' + #13#10 +
      'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 + 'left join NATUREZA_OPERACAO N on ( N.idcfop = Ped.idcfop )' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente ) and ( pcli.conf_iscliente = ''S'' ) )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idpessoa = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente ) and ( prep.conf_isrepresentante = ''S'' ) )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa pger on ( ( Pger.idpessoa = Ped.idpessoa_gerente ) and ( pger.idsys_point_cliente = ped.idsys_point_cliente ) and ( pger.conf_isgerente = ''S'' ) ) ' + #13#10 +
      'left join pessoa psup on ( ( Psup.idpessoa = Ped.idpessoa_supervisor ) and ( psup.idsys_point_cliente = ped.idsys_point_cliente ) and ( psup.conf_issupervisor = ''S'' ) ) ' + #13#10 +

    ' where   ( ped.idempresa = ' + Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ped.tipopedido = ''VD'' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_DESCCLI';
      FKCampo := 'pcli.razao_social';
      Titulo := 'Nome';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  ///
  ///
  /// faccao
  ///

  // servicos faccao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 43;
    Tabela := 'servico';
    CampoIndice := 'IDservico';
    CampoLocalizar := 'idservico';
    Titulo := ' Localizando Serviços';

    sql := ' select  s.*  from servico s   where ( ( s.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( s.idempresa = ' + Funcoes.GetIDEmpresa + ') )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDservico';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'descricao';
      Titulo := 'Descrição ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'preco';
      Titulo := 'Preço ';
      ShowInFindForm := True;
      Mascara := '###,##0.0000';
    end;

    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);

  // Envio faccao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 44;
    Tabela := 'enviofaccao';
    CampoIndice := 'idenviofaccao';
    CampoLocalizar := 'fk_nome';
    Titulo := ' Localizando Envio Facção';

    sql := 'select evf.*,p.razao_social as fk_nome,p.endereco as fk_endereco,' + #13#10 + 'p.telefone1 as fk_telefone from enviofaccao evf' + #13#10 +
      'left join pessoa p on ( p.idpessoa = evf.idpessoa_faccao ) and ( p.idsys_point_cliente = evf.idsys_point_cliente )' + #13#10 + 'where ( evf.idsys_point_cliente =' + Funcoes.GetIDPointCliente + ' ) and ( evf.idempresa = ' +
      Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idenviofaccao';
      Titulo := 'Nº facção';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_nome';
      IsFK := True;
      FKCampo := 'p.razao_social';
      Titulo := 'Nome';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTsaida';
      Titulo := 'Dt. saída';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTENTREGA';
      Titulo := 'Dt. entrega';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'FACCAOSERVPROD';
      Titulo := 'Tipo facção';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // consulta produtos Envio faccao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 45;
    Tabela := 'produtos';
    CampoIndice := 'IDproduto';
    CampoLocalizar := 'idproduto';
    Titulo := ' Localizando produtos Envio Facção';

    sql := 'select p.referencia  as fk_refProd , p.idproduto , m.descricao as fk_descricao ,' + #13#10 + 'M.descricao as fk_descricao ,' + #13#10 + 'c.descricao as fk_desccor ,' + #13#10 +
      't.descricao as fk_desctam , tab.precofaccao as fk_precofac from produto P' + #13#10 +
      'left join mercadoria M on ( M.idmercadoria = p.idmercadoria  ) and ( m.idsys_point_cliente = p.idsys_point_cliente) and ( m.idempresa = p.idempresa )' + #13#10 +
      'left join cores C on ( c.idcores = p.idcores  ) and ( c.idsys_point_cliente = m.idsys_point_cliente )' + #13#10 +
      ' left join tamanho T on ( t.idtamanho = p.idtamanho  ) and ( t.idsys_point_cliente = p.idsys_point_cliente ) and ( t.idempresa = p.idempresa ) ' + #13#10 + ' left join tabelaprecoitens  tab on ( tab.idtabelapreco = ' +
      QuotedStr(Funcoes.GetConfig('idtabelapreco', '0')) + '  ) and ( tab.idsys_point_cliente = m.idsys_point_cliente  ) and ( tab.idempresa = m.idempresa  ) and ( tab.idmercadoria = m.idmercadoria ) ' + #13#10 +
      'where ( p.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ') and ( p.idempresa = ' + Funcoes.GetIDEmpresa + ' ) order by   c.descricao ,m.referencia  , t.codigotaman ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'fk_refprod';
      IsFK := True;
      FKCampo := 'p.referencia';
      Titulo := 'Referência';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;
      NomeCampo := 'fk_descricao';
      IsFK := True;
      FKCampo := 'm.descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'fk_desccor';
      IsFK := True;
      FKCampo := 'c.descricao';
      Titulo := 'Cor';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'fk_desctam';
      IsFK := True;
      FKCampo := 't.descricao';
      Titulo := 'Tamanho';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'fk_precofac';
      IsFK := True;
      FKCampo := 'tab.precofaccao';
      Titulo := 'Preço ';
      ShowInFindForm := True;
      Mascara := '###,##0.000';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Retorno faccao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 46;
    Tabela := 'retornofaccao';
    CampoIndice := 'IDretornofaccao';
    CampoLocalizar := 'idretornofaccao';
    Titulo := ' Localizando Retorno Facção';

    sql := 'select rf.*,p.razao_social as fk_nome,p.endereco as fk_endereco , p.telefone1 as fk_telefone from retornofaccao rF' + #13#10 +
      'left join pessoa p on ( p.idpessoa = rf.idfaccao ) and ( p.idsys_point_cliente = rf.idsys_point_cliente )' + #13#10 + 'where ( rf.idsys_point_cliente =' + Funcoes.GetIDPointCliente + ' ) and ( rf.idempresa = ' +
      Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idretornofaccao';
      Titulo := 'Nº facção';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_nome';
      IsFK := True;
      FKCampo := 'p.razao_social';
      Titulo := 'Nome';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTretorno';
      Titulo := 'Dt. retorno';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  novaArea;

end;

procedure TcFindArea.novaArea;
var
  TempArea: TAreaCollectionItem;
  TempCampo: TCamposCollectionItem;

begin

  // ordem de producao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 47;
    Tabela := 'ORD_PRODUCAO';
    CampoIndice := 'IDORD_PRODUCAO';
    CampoLocalizar := 'IDORD_PRODUCAO';
    Titulo := ' Localizando ordem de produção';

    sql := 'select p.* from ord_producao P ' + #13#10 + 'where ( P.idsys_point_cliente  =' + Funcoes.GetIDPointCliente + ' ) and ( P.idempresa = ' + Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDORD_PRODUCAO';
      IsFK := True;
      FKCampo := 'p.IDORD_PRODUCAO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'CODIGOINTERNO';
      Titulo := 'Cod. Interno';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'STATUS';
      Titulo := 'Status';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATA';
      Titulo := 'Data';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTINI';
      Titulo := 'Dt. inicio';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTFIM';
      Titulo := 'Dt. final';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FOIPARACORTE';
      Titulo := 'Fechado para corte';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // ordem de producao   entrada de pecas
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 48;
    Tabela := 'ORD_PRODUCAO';
    CampoIndice := 'fk_IDORD_PRODUCAO';
    CampoLocalizar := 'fk_IDORD_PRODUCAO';
    Titulo := ' Localizando ordem de produção';

    sql := 'select o.* , o.idord_producao  as fk_IDORD_PRODUCAO from ord_producao o' + #13#10 +
      'left join ord_producao_pedidos ope on ( ope.idord_producao = O.idord_producao ) and ( ope.idsys_point_cliente = o.idsys_point_cliente ) and ( ope.idempresa = o.idempresa )' + #13#10 +
      'left join pedido ped on ( ped.idpedido = Ope.idpedido ) and ( ped.idsys_point_cliente = o.idsys_point_cliente ) and ( ped.idempresa = o.idempresa )' + #13#10 + 'where ( ( o.status = ''E'' ) or ( o.status = ''F'' ) )' + #13#10 +
      'or    ( ( o.status = ''E'' ) or ( o.status = ''F'' ) ) and ( ped.idpedido is null )' + #13#10 + 'and ( o.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( o.idempresa = ' + Funcoes.GetIDEmpresa + ')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_IDORD_PRODUCAO';
      IsFK := True;
      FKCampo := 'o.idord_producao';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'STATUS';
      Titulo := 'Status';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATA';
      Titulo := 'Data';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'CODBARRA';
      Titulo := 'Codigo barra';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTINI';
      Titulo := 'Dt. inicio';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTFIM';
      Titulo := 'Dt. final';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;

    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Pedidos  industrializacao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 49;
    Tabela := 'pedido';
    CampoIndice := 'fk_IDpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos Industrialização ';

    sql := 'select distinct Ped.*, ped.idpedido as fk_idpedido , B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 +
      'pcli.endereco as fk_ENDCLI,' + #13#10 + 'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 +
      'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 + 'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' +
      #13#10 + 'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 + 'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10
      + 'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 + 'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 + 'CAIX.idcaixa as FK_IDCAIXA' + #13#10
      +
      'from PEDIDO ped' + #13#10 + 'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 +
      'left join NATUREZA_OPERACAO N on  ( N.idcfop = Ped.idcfop )' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente ) and ( pcli.conf_iscliente = ''S'' ) )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idrepresentante = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente ) and ( prep.conf_isrepresentante = ''S'' ) )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 + ' where   ( ped.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ped.tipopedido = ''I'' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_DESCCLI';
      FKCampo := 'pcli.razao_social';
      Titulo := 'Nome';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Pedidos  Simples remessa
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 50;
    Tabela := 'pedido';
    CampoIndice := 'fk_IDpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos simples remessa ';

    sql := 'select distinct Ped.*, ped.idpedido as fk_idpedido , B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 +
      'pcli.endereco as fk_ENDCLI,' + #13#10 + 'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 +
      'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 + 'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' +
      #13#10 + 'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 + 'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10
      + 'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 + 'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 + 'CAIX.idcaixa as FK_IDCAIXA' + #13#10
      +
      'from PEDIDO ped' + #13#10 + 'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 +
      'left join NATUREZA_OPERACAO N on  ( N.idcfop = Ped.idcfop ) ' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente )  and ( pcli.conf_iscliente = ''S'' ) )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idrepresentante = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente )  and ( prep.conf_isrepresentante = ''S'' )  )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 + ' where   ( ped.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ( ped.tipopedido = ''SR'' ) or ( ped.tipopedido = ''SF'' ) ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_DESCCLI';
      IsFK := True;
      FKCampo := 'pcli.razao_social';
      Titulo := 'Nome';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 99;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'DESCRICAOTIPOPEDIDO';
      Titulo := 'Tipo Pedido';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------

  // Pedidos  retorno Mercadoria Industrializada
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 51;
    Tabela := 'pedido';
    CampoIndice := 'fk_IDpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos simples remessa ';

    sql := 'select distinct Ped.*, ped.idpedido as fk_idpedido , B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 +
      'pcli.endereco as fk_ENDCLI,' + #13#10 + 'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 +
      'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 + 'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' +
      #13#10 + 'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 + 'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10
      + 'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 + 'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 + 'CAIX.idcaixa as FK_IDCAIXA' + #13#10
      +
      'from PEDIDO ped' + #13#10 + 'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 +
      'left join NATUREZA_OPERACAO N on  ( N.idcfop = Ped.idcfop ) ' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente ) and ( pcli.conf_iscliente = ''S'' )  )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idrepresentante = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente ) and ( prep.conf_isrepresentante = ''S'' ) )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 + ' where   ( ped.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ped.tipopedido = ''MI'' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_DESCCLI';
      IsFK := True;
      FKCampo := 'pcli.razao_social';
      Titulo := 'Nome';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 99;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Pedidos devolucao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 52;
    Tabela := 'pedido';
    CampoIndice := 'fk_IDpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos Devolução ';

    sql := 'select distinct Ped.*,' + #13#10 + 'case' + #13#10 + 'when ped.tipodevolucao = ''C'' then ''Compras/Ativo/Uso consumo  Entrada''' + #13#10 + 'when ped.tipodevolucao = ''V'' then ''Vendas/Mostruários''' + #13#10 +
      'when ped.tipodevolucao = ''D'' then ''Vendas diversas''' + #13#10 + 'when ped.tipodevolucao = ''S'' then ''Simples remessa''' + #13#10 + 'when ped.tipodevolucao = ''I'' then ''Industrialização''' + #13#10 + 'end as fk_tipodevolucao,'
      + #13#10 + ' ped.idpedido as fk_idpedido , B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 + 'pcli.endereco as fk_ENDCLI,'
      +
      #13#10 + 'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 + 'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 +
      'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' + #13#10 +
      'MM.descricaomensagem as fk_DESCMENSAGEM2, V.descricao as fk_DESCPARC,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 + 'CAIX.idcaixa as FK_IDCAIXA' + #13#10 + 'from PEDIDO ped' + #13#10 +
      'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 + 'left join NATUREZA_OPERACAO N on  ( N.idcfop = Ped.idcfop ) ' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente )  )' + #13#10 + 'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 +
      'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' + #13#10 +
      'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idrepresentante = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente ) and ( prep.conf_isrepresentante = ''S'' )  )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 + ' where   ( ped.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ped.tipopedido = ''PD'' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_DESCCLI';
      FKCampo := 'pcli.razao_social';
      Titulo := 'Nome';
      IsFK := True;
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 99;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 70;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_tipodevolucao';
      Titulo := 'Tipo devolução';
      IsFK := True;
      FKCampo := 'ped.tipodevolucao';

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Cheques
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 53;
    Tabela := 'cheque';
    CampoIndice := 'idcheque';
    CampoLocalizar := 'fk_numero';
    Titulo := ' Localizando Cheques ';

    sql := ' select che.* , che.numero as fk_numero, e.descricao as fk_emitente, pcli.razao_social as fk_nomecli  , pre.razao_social as fk_nomerepre ' + #13#10 + ' from cheque che' + #13#10 +
      ' left join pessoa pcli on ( ( pcli.idpessoa = che.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = che.idsys_point_cliente ) )' + #13#10 +
      ' left join pessoa pre  on ( ( pre.idpessoa = che.idpessoa_represe ) and  ( pre.idsys_point_cliente = che.idsys_point_cliente ) )' + #13#10 +
      ' left join emitente e on ( ( e.idemitente = chE.idemitente ) and  ( e.idsys_point_cliente = che.idsys_point_cliente ) and ( e.idempresa = che.idempresa )   ) ' + #13#10 + ' where   ( che.idempresa =' + Funcoes.GetIDEmpresa +
      ' ) and ( che.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'fk_numero';
      Titulo := 'Nº cheque ';
      IsFK := True;
      FKCampo := 'che.numero';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_vencimento';
      Titulo := 'Dt. Vencimento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Vlr. Cheque';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_nomecli';
      Titulo := 'Desc.Cliente ';
      IsFK := True;
      FKCampo := 'pcli.razao_social';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'idpessoa_represe';
      Titulo := 'Representante';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_nomerepre';
      Titulo := 'Desc.repres.';
      IsFK := True;
      FKCampo := 'pre.razao_social';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'idemitente';
      Titulo := 'Emitente ';
      IsFK := True;
      FKCampo := 'che.idemitente';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_emitente';
      Titulo := 'Desc.emitente ';
      IsFK := True;
      FKCampo := 'e.descricao';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idcheque';
      Titulo := 'Cod. cheque';
      IsFK := True;
      FKCampo := 'che.idcheque';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Repasse Cheques
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 54;
    Tabela := 'cheque_repasse';
    CampoIndice := 'IDCHEQUE_REPASSE';
    CampoLocalizar := 'IDCHEQUE_REPASSE';
    Titulo := ' Localizando Repasse Cheques ';

    sql := ' select c.* from  cheque_repasse c  where   ( c.idempresa =' + Funcoes.GetIDEmpresa + ' ) and ( c.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'IDCHEQUE_REPASSE';
      Titulo := 'Cod. Repasse ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data';
      Titulo := 'Dt. Repasse';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor_total';
      Titulo := 'Vlr. Total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'Total_cheques';
      Titulo := 'Tot. Cheques ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'nomefavorecido';
      Titulo := 'Favorecido';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Pedidos  Venda Manifesto
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 55;
    Tabela := 'pedido';
    CampoIndice := 'fk_IDpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos Venda Manifesto ';

    sql := 'select distinct Ped.*, ped.idpedido as fk_idpedido , B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 +
      'pcli.endereco as fk_ENDCLI,' + #13#10 + 'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 +
      'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 + 'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' +
      #13#10 + 'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 + 'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10
      + 'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 + 'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 + 'CAIX.idcaixa as FK_IDCAIXA' + #13#10
      +
      'from PEDIDO ped' + #13#10 + 'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 +
      'left join NATUREZA_OPERACAO N on ( N.idcfop = Ped.idcfop )' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente ) and ( pcli.conf_iscliente = ''S'' ) )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idrepresentante = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente ) and ( prep.conf_isrepresentante = ''S'' ) )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 + ' where   ( ped.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ped.tipopedido = ''VM'' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_DESCCLI';
      FKCampo := 'pcli.razao_social';
      Titulo := 'Nome';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 99;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // nota de complemento
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 56;
    Tabela := 'NFCOMPL';
    CampoIndice := 'IDNFCOMPL';
    CampoLocalizar := 'IDNFCOMPL';
    Titulo := 'Localizando Nota de Complemento';

    sql := ' select * from  nfcompl where   (idempresa =' + Funcoes.GetIDEmpresa + ' ) and (IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 90;
      NomeCampo := 'IDNFCOMPL';
      Titulo := 'Cod.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 40;
      NomeCampo := 'STATUS';
      Titulo := 'St.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'TIPO_NOTA';
      Titulo := 'Tp.N.Cmpl.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 40;
      NomeCampo := 'NUM_NOTA';
      Titulo := 'Nº Nota';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------

  // Pedidos  Retorno manifesto
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 57;
    Tabela := 'pedido';
    CampoIndice := 'fk_IDpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Retorno manifesto ';

    sql := 'select distinct Ped.*, ped.idpedido as fk_idpedido , B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI,' + #13#10 +
      'pcli.endereco as fk_ENDCLI,' + #13#10 + 'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 +
      'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 + 'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' +
      #13#10 + 'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 + 'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10
      + 'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 + 'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 + 'CAIX.idcaixa as FK_IDCAIXA' + #13#10
      +
      'from PEDIDO ped' + #13#10 + 'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 +
      'left join NATUREZA_OPERACAO N on  ( N.idcfop = Ped.idcfop ) ' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente )  and ( pcli.conf_iscliente = ''S'' ) )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idrepresentante = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente )  and ( prep.conf_isrepresentante = ''S'' )  )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 + ' where   ( ped.idempresa = ' +
      Funcoes.GetIDEmpresa + ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ped.tipopedido = ''RM'' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 99;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Processos
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 58;
    Tabela := 'PROCESSOS';
    CampoIndice := 'IDPROCESSO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Processo';
    sql := 'select * from Processos where ( idempresa = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idprocesso';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Nome';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Empresa Sintegra
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 59;
    Tabela := 'SINTEGRA';
    CampoIndice := 'IDSINTEGRA';
    CampoLocalizar := 'RAZAOSOCIAL';
    Titulo := 'Localizando Empresa Sintegra';
    sql := 'select * from sintegra where ( idempresa = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idsintegra';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'razaosocial';
      Titulo := 'Nome';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Pedidos PDV
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 60;
    Tabela := 'cupom';
    CampoIndice := 'idcupom';
    CampoLocalizar := 'idcupom';
    Titulo := ' Localizando Lançamento PDV';

    sql := 'SELECT C.*, pc.razao_social AS FK_CLIENTE_RAZAO,' + #13#10 + ' cid.uf as fk_uf, CF.CFOP AS FK_CFOP, CF.descricao AS FK_CFOP_DESC  FROM CUPOM C ' + #13#10 +
      ' LEFT JOIN pessoa pc ON ( pc.idpessoa = C.idcliente )   and ( pc.idsys_point_cliente = c.idsys_point_cliente ) and ( pc.conf_iscliente = ''S'' )' + #13#10 + ' LEFT JOIN natureza_operacao CF ON ( CF.idcfop = C.idcfop )' + #13#10 +
      ' LEFT JOIN cidade Cid ON ( Cid.idcidade = pc.idcidade )' + #13#10 + ' WHERE ( c.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( c.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idcupom';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_CLIENTE_RAZAO';
      FKCampo := 'pc.razao_social';
      Titulo := 'Nome';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'num_nota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'num_ecf';
      Titulo := 'Nº ECF ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'vlr_total';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data_emissao';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Carta de Cobranca - Texto
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 61;
    Tabela := 'CARTACOB_TEXTO';
    CampoIndice := 'IDCARTACOB_TEXTO';
    CampoLocalizar := 'IDCARTACOB_TEXTO';
    Titulo := ' Localizando Texto para Carta de Cobrança';

    sql := 'SELECT IDSYS_POINT_CLIENTE, IDEMPRESA, IDCARTACOB_TEXTO, STATUS, DESCRICAO, TEXTO' + #13#10 + 'FROM CARTACOB_TEXTO' + #13#10 + 'WHERE (idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and (idempresa = ' +
      Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCARTACOB_TEXTO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 35;
      NomeCampo := 'STATUS';
      Titulo := 'St.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // Transferencia de pecas fabrica para loja

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 62;
    Tabela := 'TRANSFERENCIA';
    CampoIndice := 'IDTRANSFERENCIA';
    CampoLocalizar := 'IDTRANSFERENCIA';
    Titulo := ' Localizando tabela de transferência de peças';

    sql := ' SELECT tr.idtransferencia , tr.IDSYS_POINT_CLIENTE, tr.IDEMPRESA  , tr.responsavel , tr.data , tr.tipo_transferencia ' + #13#10 + ' frOM transferencia tr WHERE ( tr.idsys_point_cliente =' + Funcoes.GetIDPointCliente +
      ') and ( tr.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDTRANSFERENCIA';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 100;
      NomeCampo := 'data';
      Titulo := 'Dt. entrada';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'responsavel';
      Titulo := 'Responsavel';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 50;
      NomeCampo := 'tipo_transferencia';
      Titulo := 'Tp.Transf.';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // -----------------------------------------------------------------------------
  // devolucao PDV
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 63;
    Tabela := 'Devcupom';
    CampoIndice := 'IDDEVCUPOM';
    CampoLocalizar := 'IDDEVCUPOM';
    Titulo := ' Localizando Devolução PDV';

    sql := 'SELECT dC.*, pc.razao_social AS FK_CLIENTE_RAZAO, pc.jur_insc_est_uf as fk_uf , ' + #13#10 + ' CF.CFOP AS FK_CFOP,' + #13#10 +
      'CF.descricao AS FK_CFOP_DESC , pc1.razao_social AS FK_CLIENTE_RAZAO1 , pc1.jur_insc_est_uf as fk_uf1  FROM devCUPOM dC ' + #13#10 +
      ' LEFT JOIN pessoa pc ON ( pc.idpessoa = DC.idcliente )   and ( pc.idsys_point_cliente = Dc.idsys_point_cliente ) and ( pc.conf_iscliente = ''S'' ) ' +
      ' LEFT JOIN pessoa pc1 ON ( pc1.idpessoa = DC.idpessoa )   and ( pc1.idsys_point_cliente = Dc.idsys_point_cliente ) and ( pc1.conf_iscliente = ''S'' ) ' + #13#10 + ' LEFT JOIN natureza_operacao CF ON ( CF.idcfop = DC.idcfop )' +
      #13#10 + ' WHERE ( Dc.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( Dc.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDDEVCUPOM';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_CLIENTE_RAZAO1';
      FKCampo := 'pc1.razao_social';
      IsFK := True;
      Titulo := 'Nome';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'num_ecf';
      Titulo := 'Nº ECF ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'vlr_total';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'nfe_id';
      Titulo := 'Chave NFE';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Processos mercadoria

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 64;
    Tabela := 'operacaoproduto';
    CampoIndice := 'IDoperacaoproduto';
    CampoLocalizar := 'IDoperacaoproduto';
    Titulo := 'Localizando Processo';
    sql := 'SELECT o.* , m.descricao as fk_descricao ,  m.referencia as fk_refere FROM operacaoproduto o  ' + #13#10 +
      'LEFT JOIN mercadoria m ON ( m.idmercadoria = o.idmercadoria ) and ( m.idsys_point_cliente = o.idsys_point_cliente ) and ( m.idempresa = m.idempresa )' + #13#10 + 'WHERE  ( o.idsys_point_cliente = ' + Funcoes.GetIDPointCliente +
      ' ) and ( o.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDoperacaoproduto';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'idmercadoria';
      Titulo := 'Cod.Mercadoria';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'fk_refere';
      FKCampo := 'm.referencia';
      Titulo := 'Ref.';
      ShowInFindForm := True;
      IsFK := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_descricao';
      FKCampo := 'm.descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

  // Pedido serie d

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 65;
    Tabela := 'pedidoseried';
    CampoIndice := 'IDpedidoseried';
    CampoLocalizar := 'IDpedidoseried';
    Titulo := 'Localizando Pedido serie D';
    sql := 'SELECT p.* , c.razao_social as fk_descriCli  FROM pedidoseried p' + #13#10 + 'LEFT JOIN pessoa c ON ( c.idpessoa = p.idcliente ) and ( c.idsys_point_cliente = p.idsys_point_cliente )' + #13#10 +
      'WHERE  ( p.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( p.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDpedidoseried';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_descricli';
      FKCampo := 'c.razao_social';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'status';
      Titulo := 'Status';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

  // grupo de pessoas

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 66;
    Tabela := 'grupopessoa';
    CampoIndice := 'idgrupopessoa';
    CampoLocalizar := 'idgrupopessoa';
    Titulo := 'Localizando Encargos';
    sql := ' select gp.* from grupopessoa gp ' + #13#10 + ' where ( gp.idsys_point_cliente =' + Funcoes.GetIDPointCliente + ' )  and ( gp.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idgrupopessoa';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

  // encargos

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 67;
    Tabela := 'encargos';
    CampoIndice := 'IDencargo';
    CampoLocalizar := 'idencargo';
    Titulo := 'Localizando Encargos';
    sql := 'SELECT e.* FROM encargos e' + #13#10 + 'WHERE  ( e.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( e.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDencargo';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'percentual';
      Titulo := 'Percentual';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

  // Creditodebito
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 68;
    Tabela := 'Creditodebito';
    CampoIndice := 'IDCREDITODEBITO';
    CampoLocalizar := 'IDCREDITODEBITO';
    Titulo := 'Localizando Créditos/Débitos';

    sql := 'select cr.*   , c.razao_social as fk_representante from CREDITODEBITO  cr' + #13#10 +
      'left join pessoa c on ( c.idpessoa =cr.idpessoa_representante ) and ( c.idsys_point_cliente = cr.idsys_point_cliente ) and ( c.conf_isrepresentante = ''S'' )' + #13#10 + 'Where ( cr.idsys_point_cliente =' + Funcoes.GetIDPointCliente
      + ' ) and ( cr.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCreditodebito';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Valor';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'data';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'tipo';
      Titulo := 'Créd/Déb';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDPESSOA_REPRESENTANTE';
      Titulo := 'CodRep';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_representante';
      FKCampo := 'c.razao_social';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // controle de visitas
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 69;
    Tabela := 'visitas';
    CampoIndice := 'IDvisitas';
    CampoLocalizar := 'IDvisitas';
    Titulo := 'Localizando Créditos/Débitos';

    sql := 'select v.*   ,r.razao_social as fk_representante' + #13#10 + 'from visitas  v' + #13#10 +
      'left join pessoa r on ( r.idpessoa = v.idpessoa_representante ) and ( r.idsys_point_cliente = v.idsys_point_cliente ) and ( r.conf_isrepresentante = ''S'' )' + #13#10 + 'Where ( v.idsys_point_cliente =' + Funcoes.GetIDPointCliente +
      ') and ( v.idempresa = ' + Funcoes.GetIDEmpresa + ' ) order by v.idpessoa_representante , v.dtinicio';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDvisitas';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDPESSOA_REPRESENTANTE';
      Titulo := 'Cod. Rep.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_representante';
      FKCampo := 'c.razao_social';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtinicio';
      Titulo := 'Dt. Inicio';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfim';
      Titulo := 'Dt. Fim';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    Areas.Add(TempArea);

  end;

  // Ord Producao Excedente
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 70;
    Tabela := 'ORD_PRODUCAO_EXCEDENTE';
    CampoIndice := 'IDORD_PRODUCAO_EXCEDENTE';
    CampoLocalizar := 'IDORD_PRODUCAO_EXCEDENTE';
    Titulo := 'Localizando Ord. Produção - Excedente';

    sql := 'select OPE.*, M.DESCRICAO as FK_PRODDESC' + #13#10 + 'from ORD_PRODUCAO_EXCEDENTE OPE' + #13#10 +
      'left join PRODUTO P on (P.IDPRODUTO = OPE.IDPRODUTO and P.IDSYS_POINT_CLIENTE = OPE.IDSYS_POINT_CLIENTE and P.IDEMPRESA = OPE.IDEMPRESA)' + #13#10 +
      'left join MERCADORIA M on (M.IDMERCADORIA = P.IDMERCADORIA and M.IDSYS_POINT_CLIENTE = OPE.IDSYS_POINT_CLIENTE and M.IDEMPRESA = OPE.IDEMPRESA)' + #13#10 + 'Where (ope.idsys_point_cliente =' + Funcoes.GetIDPointCliente +
      ') and (ope.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDORD_PRODUCAO_EXCEDENTE';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATA';
      Titulo := 'Data';
      Mascara := 'dd/mm/yyyy';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDORD_PRODUCAO';
      Titulo := 'Cod. Ord. Prod.';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_PRODDESC';
      FKCampo := 'M.DESCRICAO';
      Titulo := 'Descrição - Produto';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'QTDE';
      Titulo := 'Qtde.';
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    Areas.Add(TempArea);

  end;

  // Produtos (Somente descricao, ref. tam e cor
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 71;
    Tabela := 'PRODUTO';
    CampoIndice := 'IDPRODUTO';
    CampoLocalizar := 'IDPRODUTO';
    Titulo := 'Localizando Produto';

    sql := 'select P.idproduto, P.REFERENCIA as FK_REFERENCIA, M.DESCRICAO as FK_DESCRMER, T.DESCRICAO as FK_DESCTAM, C.DESCRICAO as FK_DESCCOR' + #13#10 + 'from PRODUTO P' + #13#10 + 'left join CORES C on (C.IDCORES = P.IDCORES)' + #13#10
      + 'left join TAMANHO T on (T.IDTAMANHO = P.IDTAMANHO) and (T.IDEMPRESA = P.IDEMPRESA) and (T.IDSYS_POINT_CLIENTE = P.IDSYS_POINT_CLIENTE)' + #13#10 +
      'left join MERCADORIA M on (M.IDMERCADORIA = P.IDMERCADORIA) and (M.IDEMPRESA = P.IDEMPRESA) and (M.IDSYS_POINT_CLIENTE = P.IDSYS_POINT_CLIENTE)' + #13#10 + 'where (P.IDPRODUTO in (select OP.IDPRODUTO' + #13#10 +
      'from ORD_PRODUCAO_PRODUTO OP' + #13#10 + 'Where (op.idsys_point_cliente =' + Funcoes.GetIDPointCliente + ') and (op.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDPRODUTO';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'FK_REFERENCIA';
      Titulo := 'Ref.';
      IsFK := True;
      FKCampo := 'P.REFERENCIA';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_DESCRMER';
      Titulo := 'Descrição';
      IsFK := True;
      FKCampo := 'M.DESCRICAO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 35;
      NomeCampo := 'FK_DESCTAM';
      Titulo := 'Tam.';
      IsFK := True;
      FKCampo := 'T.DESCRICAO';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'FK_DESCCOR';
      Titulo := 'Cor';
      IsFK := True;
      FKCampo := 'C.DESCRICAO';
    end;
    Campos.Add(TempCampo);

    Areas.Add(TempArea);

  end;

  // fator de divisao
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 72;
    Tabela := 'FATORDIVISAO';
    CampoIndice := 'IDFATORDIVISAO';
    CampoLocalizar := 'IDFATORDIVISAO';
    Titulo := 'Localizando Fator de divisão';

    sql := 'select * from FATORDIVISAO';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDFATORDIVISAO';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'unidade';
      Titulo := 'UN';

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'divisor';
      Titulo := 'Divisor';
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    Areas.Add(TempArea);

  end;

  // Credito cliente referente as devolucoes
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 73;
    Tabela := 'CREDITOCLIENTE';
    CampoIndice := 'IDCREDITOCLIENTE';
    CampoLocalizar := 'IDCREDITOCLIENTE';
    Titulo := 'Localizando Crédito cliente';

    sql := 'select c.*, P.razao_social as FK_razao_social' + #13#10 + 'from creditocliente c' + #13#10 + 'left join pessoa p on ( p.idpessoa = c.idpessoa ) and ( p.idsys_point_cliente = c.idsys_point_cliente )' + #13#10 +
      'where  ( c.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( c.idempresa = ' + Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCREDITOCLIENTE';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDPESSOA';
      Titulo := 'Cod.';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'FK_razao_social';
      Titulo := 'Nome';
      IsFK := True;
      FKCampo := 'P.razao_social';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Valor';
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATA';
      Titulo := 'Data';
      Mascara := 'dd/mm/yyyy';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'Tipo';
      Titulo := 'Tipo';

    end;
    Campos.Add(TempCampo);

    Areas.Add(TempArea);

  end;

  // Cadastro de Etiquetas
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 74;
    Tabela := 'ETIQUETA';
    CampoIndice := 'IDETIQUETA';
    CampoLocalizar := 'IDETIQUETA';
    Titulo := 'Localizando Etiqueta';

    sql := 'select * from etiqueta';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 60;
      NomeCampo := 'IDETIQUETA';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 30;
      NomeCampo := 'STATUS';
      Titulo := 'St.';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
    end;
    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);

  // CaIXA FACCAO
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 75;
    Tabela := 'caixafaccao';
    CampoIndice := 'IDcaixa';
    CampoLocalizar := 'IDcaixa';
    Titulo := 'Localizando Caixa Facção';

    sql := 'select cxa.*, f.razao_social as fk_nome ,' + #13#10 + 'case   When ( cxa.idcentrocusto = 1 )  then  ''D - Débito''' + #13#10 + 'When ( cxa.idcentrocusto = 2 )  then  ''C - Pagamento Produção''' + #13#10 +
      'When ( cxa.idcentrocusto = 3 )  then  ''D - Compra de matéria Prima''' + #13#10 + 'when  ( cxa.idcentrocusto = 4 )  then  ''D - Compra de maquinas e Equipamento''' + #13#10 +
      'when ( cxa.idcentrocusto = 5 )  then  ''D - Descontos peças pagas com defeito''' + #13#10 + 'when ( cxa.idcentrocusto = 6 )  then  ''C - Créd. de peças''' + #13#10 + 'End as fk_centrocusto' + #13#10 + 'from caixafaccao cxa' + #13#10
      + 'left join pessoa f on ( f.idpessoa  =  cxa.idfaccao ) and ( f.idsys_point_cliente = cxa.idsys_point_cliente )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 60;
      NomeCampo := 'IDCAIXA';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin

      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTLANCAMENTO';
      Titulo := 'Dt. Laçamento';
      Mascara := 'dd/mm/yyyy';

    end;

    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'fk_centrocusto';
      Titulo := 'Centro Custo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Valor';
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // repasse de duplicatas
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 76;
    Tabela := 'repasse';
    CampoIndice := 'IDrepasse';
    CampoLocalizar := 'IDrepasse';
    Titulo := 'Localizando codigo do repasse';

    sql := 'select * from repasse ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 60;
      NomeCampo := 'IDREPASSE';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin

      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATA_REPASSE';
      Titulo := 'Dt. Repasse';
      Mascara := 'dd/mm/yyyy';

    end;

    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Pedidos manifesto
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 77;
    Tabela := 'pedido';
    CampoIndice := 'fk_idpedido';
    CampoLocalizar := 'fk_idpedido';
    Titulo := ' Localizando Pedidos ';

    sql := 'select distinct ped.internet, ped.exportado,ped.protocolo_epec, pcli.mei, ped.IDORD_PRODUCAO , ped.REJEITADO, ped.numeronota, Ped.idpessoa_cliente , ped.ufembarq , ped.locaembarq ,ped.idcaixa , ped.idconta_receber ,' + #13#10 +
      'ped.idforma_pgto, fo.descricao  as fk_descr_forpgto , ped.notaenviada , ped.envioucontigencia,ped.contigencia , ped.serie,ped.hora,ped.nfe_id ,ped.obs_fiscal,ped.contigencia ,' + #13#10 +
      'pcli.redespacho,ped.datasaida,ped.dtemissao,ped.dtentradafabrica,' + #13#10 + 'ped.status ,ped.numeropedido,ped.desmembra ,ped.cobrafrete ,' + #13#10 + 'ped.bonificacao ,ped.pispasep ,ped.confins,ped.frete ,' + #13#10 +
      'ped.programado ,ped.manifesto,ped.dtfaturamento ,ped.idpedido as fk_idpedido ,' + #13#10 + 'ped.tipofrete ,ped.opcao,ped.mostruario ,ped.idmensagem,' + #13#10 +
      ' ped.numeronota as fk_numeronota ,ped.idcfop , ped.valorfrete , ped.valortotal ,ped.valordesconto ,ped.idpessoa_cliente , ' + #13#10 +
      ' ped.idpessoa_representante , ped.idvencimento ,ped.volume ,ped.dadosadicionais ,ped.idcfop_terceiro,ped.idcfop_brinde,ped.pesobruto , ' + #13#10 + ' ped.pesoliquido , ped.liberapedido , ped.especie , ' + #13#10 +
      'B.DESCRICAO as fk_DESCBANCO,' + #13#10 + 'N.descricao as fk_DESCCFOP,' + #13#10 + 'N.cfop as fk_CFOP,' + #13#10 + 'pcli.razao_social as fk_DESCCLI, pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'pcli.endereco as fk_ENDCLI,' + #13#10 +
      'pcli.bairro as fk_cliBAIRRO,' + #13#10 + 'cidcl.uf as fk_CLI_UF,' + #13#10 + 'pcli.cep as fk_CLI_CEP,' + #13#10 + 'pcli.jur_suframa as fk_SUFRAMA,' + #13#10 + 'pcli.jur_insc_est as fk_INSCRICAO,' + #13#10 +
      'pcli.jur_cnpj as fk_CLICNPJ,' + #13#10 + 'CIDcl.descricao as fk_CLI_NOMECIDADE,' + #13#10 + 'pcli.telefone1 as fk_CLI_TELEFONE,' + #13#10 + 'M.descricaomensagem as fk_DESCMENSAGEM,' + #13#10 +
      'MM.descricaomensagem as fk_DESCMENSAGEM2,' + #13#10 + 'prep.razao_social as fk_DESCREPRE,' + #13#10 + 'ptra.razao_social as fk_DESCTRANS,' + #13#10 + 'V.descricao as fk_DESCPARC,' + #13#10 + 'cidrep.uf as fk_REUF,' + #13#10 +
      'prep.jur_insc_est as fk_INSCREPRESEN,' + #13#10 + 'prep.jur_suframa as fk_SUFramaREP,' + #13#10 + 'prep.jur_cnpj as fk_CNPJRE,' + #13#10 + 'cre.idconta_receber as FK_CONTARECEBER,' + #13#10 + 'CAIX.idcaixa as FK_IDCAIXA' + #13#10 +
      'from PEDIDO ped' + #13#10 + 'left join BANCO B on ( ( B.idbanco = Ped.idbanco ) and ( b.idsys_point_cliente = ped.idsys_point_cliente ) and ( b.idempresa = ped.idempresa ) )' + #13#10 +
      'left join NATUREZA_OPERACAO N on  ( N.idcfop = Ped.idcfop ) ' + #13#10 +
      'left join pessoa pcli on ( ( pcli.idpessoa = Ped.idpessoa_cliente ) and  ( pcli.idsys_point_cliente = ped.idsys_point_cliente )  and ( pcli.conf_iscliente = ''S'' )  )' + #13#10 +
      'left join cidade Cidcl on  ( CIDcl.idcidade = pcli.idcidade )' + #13#10 + 'left join MENSAGEM M on ( ( M.IDMENSAGEM = Ped.idmensagem ) and ( m.idsys_point_cliente = ped.idsys_point_cliente ) and ( m.idempresa = ped.idempresa ) )' +
      #13#10 + 'left join MENSAGEM MM on  ( ( MM.IDMENSAGEM = Ped.idmensagem2) and ( mm.idsys_point_cliente = ped.idsys_point_cliente ) and ( mm.idempresa = ped.idempresa ) )' + #13#10 +
      'left join pessoa prep on ( ( prep.idrepresentante = Ped.idpessoa_representante ) and ( prep.idsys_point_cliente = ped.idsys_point_cliente ) and ( prep.conf_isrepresentante = ''S'' ) )' + #13#10 +
      'left join cidade Cidrep on  ( CIDrep.idcidade = prep.idcidade )' + #13#10 +
      'left join pessoa ptra on (( ptra.idpessoa = Ped.idpessoa_transportadora ) and ( ptra.idsys_point_cliente = ped.idsys_point_cliente ) and ( ptra.conf_istransportadora = ''S'' ) )' + #13#10 +
      'left join VENCIMENTO V on ( ( V.IDVENCIMENTO = Ped.idvencimento ) and ( v.idsys_point_cliente = ped.idsys_point_cliente ) and ( v.idempresa = ped.idempresa ) )' + #13#10 +
      'left join CAIXA caix on ( ( CAIX.idcaixa = Ped.idcaixa ) and ( caix.idsys_point_cliente = ped.idsys_point_cliente ) and ( caix.idempresa = ped.idempresa ) )' + #13#10 +
      'left join Conta_receber Cre on ( ( Cre.idconta_receber = Ped.idconta_receber ) and ( cre.idsys_point_cliente = ped.idsys_point_cliente ) and ( cre.idempresa = ped.idempresa ) )' + #13#10 +
      'LEFT JOIN forma_pgto fo ON ( ( fo.idforma_pgto = PED.idforma_pgto ) AND ( fo.idsys_point_cliente = PED.IDSYS_POINT_CLIENTE ) AND ( fo.idempresa = PED.IDEMPRESA ) )' + #13#10 + ' where   ( ped.idempresa = ' + Funcoes.GetIDEmpresa +
      ' ) and ( ped.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( ped.tipopedido = ''PV'' ) and ( ped.manifesto = ''S'' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idpedido';
      IsFK := True;
      FKCampo := 'ped.idpedido';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'numeronota';
      Titulo := 'Nº nota ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'idpessoa_cliente';
      Titulo := 'Cliente ';
      ShowInFindForm := True;
      CanLocate := False;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'FK_DESCCLI';
      IsFK := True;
      FKCampo := 'PCLI.RAZAO_SOCIAL';
      Titulo := 'Nome';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 50;
      NomeCampo := 'fk_CLICNPJ';
      IsFK := True;
      FKCampo := 'pcli.jur_cnpj';
      Titulo := 'CNPJ';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valortotal';
      Titulo := 'Vlr. total';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dtfaturamento';
      Titulo := 'Dt. faturamento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'dtemissao';
      Titulo := 'Dt. tirado no cliente';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 90;
      NomeCampo := 'IDORD_PRODUCAO';
      Titulo := 'Ordem prod.';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Credito cliente referente as devolucoes
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 78;
    Tabela := 'EMITENTE';
    CampoIndice := 'IDEMITENTE';
    CampoLocalizar := 'IDEMITENTE';
    Titulo := 'Localizando Emitente de cheques';

    sql := 'select e.* from emitente e' + #13#10 + 'where  ( e.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( e.idempresa = ' + Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDEMITENTE';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'descricao';
      Titulo := 'Emitente';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 160;
      NomeCampo := 'CNPJ';
      Titulo := 'CNPJ';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 160;
      NomeCampo := 'CNPF';
      Titulo := 'CPF';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Cotas
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 79;
    Tabela := 'COTAS';
    CampoIndice := 'IDcotas';
    CampoLocalizar := 'IDcotas';
    Titulo := 'Localizando Cotas';

    sql := 'select c.* , p.razao_social as fk_razao_social ' + #13#10 + 'from cotas c' + #13#10 + 'LEFT JOIN pessoa p ON  ( p.idpessoa = c.idpessoa )' + #13#10 + 'where  ( c.idsys_point_cliente = ' + Funcoes.GetIDPointCliente +
      ' ) and ( c.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCOTAS';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'fk_razao_social';
      IsFK := True;
      FKCampo := 'P.RAZAO_SOCIAL';
      Titulo := 'Representante';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'dtini';
      Titulo := 'Dt. inicio';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'dtfim';
      Titulo := 'Dt. final';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de materia prima
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 117;
    Tabela := 'MATERIAPRIMA';
    CampoIndice := 'IDMATERIA';
    CampoLocalizar := 'IDMATERIA';
    Titulo := 'Localizando cadastro de Matéria prima ';

    sql := 'select m.* from materiaprima m where ( m.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'm.IDMATERIA';

      Titulo := 'Codigo';

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'REFERENCIA';
      Titulo := 'Referência';

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'CLASSIFICACAO';
      Titulo := 'NCM';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'unidade';
      Titulo := 'UN';

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'Baixa_manual';
      Titulo := 'Baixa Manual';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // Credito cliente referente as devolucoes
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 118;
    Tabela := 'CREDITODEBITO';
    CampoIndice := 'IDCREDITODEBITO';
    CampoLocalizar := 'IDCREDITODEBITO';
    Titulo := 'Localizando Crédito/Débito cliente';

    sql := 'select c.*, P.razao_social as FK_razao_social' + #13#10 + 'from CREDITODEBITO c' + #13#10 + 'left join pessoa p on ( p.idpessoa = c.idpessoa ) and ( p.idsys_point_cliente = c.idsys_point_cliente )' + #13#10 +
      'where  ( c.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) and ( c.idempresa = ' + Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCREDITODEBITO';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDPESSOA';
      Titulo := 'Cod.';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'FK_razao_social';
      Titulo := 'Nome';
      IsFK := True;
      FKCampo := 'P.razao_social';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'valor';
      Titulo := 'Valor';
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATA';
      Titulo := 'Data';
      Mascara := 'dd/mm/yyyy';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'Tipo';
      Titulo := 'Tipo';

    end;
    Campos.Add(TempCampo);

    Areas.Add(TempArea);

  end;

  // Retorno de materia prima
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 119;
    Tabela := 'retornomateriaprima';
    CampoIndice := 'IDretornomateriaprima';
    CampoLocalizar := 'DATAENTRADA';
    Titulo := ' Localizando Entrada matéria prima manual ';

    sql := 'select * from retornomateriaprima where (  idempresa = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDretornomateriaprima';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dataentrada';
      Titulo := 'Data entrada';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

  // cadastro de materia prima
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 120;
    Tabela := 'MATERIAPRIMA';
    CampoIndice := 'M.IDMATERIA';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Matéria prima ';

    sql := 'select * from materiaprima  where ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDMATERIA';
      Titulo := 'Codigo';
      ShowInFindForm := True;
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'REFERENCIA';
      Titulo := 'Referência';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'CLASSIFICACAO';
      Titulo := 'NCM';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'unidade';
      Titulo := 'UN';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'Baixa_manual';
      Titulo := 'Baixa manual';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

{$REGION '121 Industrialização de materia prima interna'}
  // Industrialização de materia prima interna
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 121;
    Tabela := 'INDUSTRIALIZACAO';
    CampoIndice := 'IDINDUSTRIALIZACAO';
    CampoLocalizar := 'IDINDUSTRIALIZACAO';
    Titulo := 'Localizando Industrialização de Matéria prima ';

    sql := 'select * from industrializacao  where ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') and ( idempresa = ' + Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDINDUSTRIALIZACAO';
      Titulo := 'Codigo';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'RESPONSAVEL';
      Titulo := 'Responsavel';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'DATAINDUSTR';
      Titulo := 'Dt. industrialização';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}
{$REGION '122 - Cadastro de Rotas'}
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 122;
    Tabela := 'ROTA';
    CampoIndice := 'IDROTA';
    CampoLocalizar := 'IDROTA';
    Titulo := 'Localizando Rota';

    sql := 'select * from rota  where (IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') and ( idempresa = ' + Funcoes.GetIDEmpresa + '  ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDROTA';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
    end;
    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);

{$ENDREGION}
{$REGION '123 - Cadastro de Arquivo de retorno'}
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 123;
    Tabela := 'ARQ_RETORNO';
    CampoIndice := 'IDARQ_RETORNO';
    CampoLocalizar := 'IDARQ_RETORNO';
    Titulo := 'Localizando Arquivos de Retorno';

    sql := 'Select a.*, cc.descricao fk_caixa_conta_cre, b.descricao fk_banco, cd.descricao fk_caixa_conta_deb' + #13#10 +
      'from arq_retorno a' + #13#10 +
      'inner join banco b on (b.idbanco=a.idbanco and b.idsys_point_cliente=a.idsys_point_cliente and b.idempresa=a.idempresa)' + #13#10 +
      'inner join caixa_conta Cc on ( cc.idcaixa_conta=a.idcaixa_conta_cre and cc.idsys_point_cliente= a.idsys_point_cliente and cc.idempresa=a.idempresa )' + #13#10 +
      'inner join caixa_conta Cd on (cd.idcaixa_conta=a.idcaixa_conta_deb  and cd.idsys_point_cliente=a.idsys_point_cliente and cd.idempresa=a.idempresa )' + #13#10 +
      ' where ( a.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente +
      ' ) AND ( a.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDARQ_RETORNO';
      Titulo := 'Codigo';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Dt. Cadastro';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_banco';
      Titulo := 'Banco';
      ShowInFindForm := True;
      IsFK := True;
      FKCampo := 'b.descricao';

    end;
    Campos.Add(TempCampo);
    Areas.Add(TempArea);
  end;

{$ENDREGION}
{$REGION '124 cadastro de Coleção'}
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 124;
    Tabela := 'COLECAO';
    CampoIndice := 'IDCOLECAO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Coleção';

    sql := 'select *  from COLECAO where ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idCOLECAO';
      Titulo := 'Código';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'Status';
      Titulo := 'Ativo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    Areas.Add(TempArea);
  end;

{$ENDREGION}
{$REGION '325 cadastro registro sped E110'}
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 325;
    Tabela := 'E110';
    CampoIndice := 'IDE110';
    CampoLocalizar := 'DT_inicial';
    Titulo := 'Localizando cadastro E110';

    sql := 'select *  from e110 where (  idempresa = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ') ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'ide110';
      Titulo := 'Código';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'Dt_inicial';
      Titulo := 'Data inicial';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'dt_final';
      Titulo := 'Data final';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    Areas.Add(TempArea);
  end;

{$ENDREGION}

{$REGION '126 cadastro Maquinario processo'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 126;
    Tabela := 'MAQUINARIOPROCESSO';
    CampoIndice := 'IDMAQUINARIOPROCESSO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Maquinários de processos';
    sql := 'select * from MAQUINARIOPROCESSO where ( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE  = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDMAQUINARIOPROCESSO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 300;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    Areas.Add(TempArea);
  end;

{$ENDREGION}
{$REGION '127 Evento descricao processo'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 127;
    Tabela := 'EVENTODESCRICAOPROCESSO';
    CampoIndice := 'IDEVENTODESCPROCESSO';
    CampoLocalizar := 'DESCEVENTOPROCESSO';
    Titulo := 'Localizando Descrição Evento processo';
    SQL := ' select *  from EVENTODESCRICAOPROCESSO ';
    SQL := SQL + ' where (  IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( IDSYS_POINT_CLIENTE  = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDEVENTODESCPROCESSO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 300;
      NomeCampo := 'DESCEVENTOPROCESSO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    Areas.Add(TempArea);
  end;

{$ENDREGION}

{$REGION '128 cadastro Cronoanalise'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 128;
    Tabela := 'CRONOANALISE';
    CampoIndice := 'IDCRONOANALISE';
    CampoLocalizar := 'IDCRONOANALISE';
    Titulo := 'Localizando Cronoanalise';
    SQL := 'select m.idmercadoria  as fk_idrefere ,C.idcronoanalise , c.data , m.referencia as refere , ';
    SQL := SQL + ' m.descricao as descri , ';
    SQL := SQL + ' case ';
    SQL := SQL + ' when c.tipo = ''1'' then ''Peça inteira''   ';
    SQL := SQL + ' when c.tipo = ''2'' then ''Parte de cima''  ';
    SQL := SQL + ' when c.tipo = ''3'' then ''Parte de baixo'' ';
    SQL := SQL + ' end fk_tipo';
    SQL := SQL + ' from cronoanalise c ';
    SQL := SQL + ' left join MERCADORIA  M on ( M.idmercadoria = c.idproduto  )';
    SQL := SQL + ' where ( c.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( c.IDSYS_POINT_CLIENTE  = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCRONOANALISE';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'DATA';
      Titulo := 'Data Criação';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'fk_idrefere';
      Titulo := 'Cord. Ref.';
      IsFK := True;
      FKCampo := 'm.idmercadoria';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'refere';
      Titulo := 'Referência';
      IsFK := True;
      FKCampo := 'm.referencia';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'descri';
      Titulo := 'Descrição';
      IsFK := True;
      FKCampo := 'm.Descricao';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 120;
      NomeCampo := 'fk_tipo';
      Titulo := 'Tipo';
      ShowInFindForm := True;
      CanLocate := False;

    end;
    Campos.Add(TempCampo);

    Areas.Add(TempArea);
  end;

{$ENDREGION}

{$REGION '129 Balaco produtivo'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 129;
    Tabela := 'BALANCEAMENTOPRODUTIVO';
    CampoIndice := 'IDBALANCEAMENTOPRODUTIVO';
    CampoLocalizar := 'DATA';
    Titulo := 'Localizando Balanço Produtivo';
    SQL := 'select b.*  from BALANCEAMENTOPRODUTIVO b ';
    SQL := SQL + ' where ( b.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' ) and ( b.IDSYS_POINT_CLIENTE  = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDBALANCEAMENTOPRODUTIVO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'DATA';
      Titulo := 'Data Produção';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'HORADIA';
      Titulo := 'Hora';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'HORATRABALHADA';
      Titulo := 'Hora Trab.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
    Areas.Add(TempArea);

  end;

{$ENDREGION}
  novaArea2;

end;

procedure TcFindArea.novaArea2;
var
  TempArea: TAreaCollectionItem;
  TempCampo: TCamposCollectionItem;

begin

{$REGION '130 OCORRENCIADESCONTO'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 130;
    Tabela := 'OCORRENCIADESCONTO';
    CampoIndice := 'IDOCORRENCIADESCONTO';
    CampoLocalizar := 'fk_funcionario';
    Titulo := 'Localizando Ocorrência Desconto';

    SQL := 'select o.* , pe.razao_social as fk_funcionario from ocorrenciaDesconto o' + #13#10 +
      'LEFT JOIN pessoa pe ON ( pe.idpessoa = o.idpessoa ) and ( pe.IDSYS_POINT_CLIENTE = o.idsys_point_cliente ) and' + #13#10 +
      '( o.idempresa = o.idempresa )' + #13#10 +
      'where  ( o.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + '  ) and' + #13#10 +
      '( o.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDOCORRENCIADESCONTO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'DATA';
      Titulo := 'Data Ocorrência / Desconto';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'IDPESSOA';
      Titulo := 'Cod. Func.';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_funcionario';
      FKCampo := 'pe.razao_social';
      Titulo := 'Funcionário';
      ShowInFindForm := True;
      IsFK := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'ocorrencia';
      Titulo := 'Ocorrência';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'desconto';
      Titulo := 'Desconto';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '131 chaometa'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 131;
    Tabela := 'CHAOMETA';
    CampoIndice := 'IDCHAOMETA';
    CampoLocalizar := 'IDCHAOMETA';
    Titulo := 'Localizando Metas';

    SQL := 'select chao.*  from chaometa chao ' + #13#10 +
      'where  ( chao.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + '  ) and' + #13#10 +
      '( chao.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCHAOMETA';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'META';
      Titulo := 'Meta';
      ShowInFindForm := True;
      Mascara := '###,##0.00%';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'VALOR';
      Titulo := 'Valor';
      ShowInFindForm := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '132 servidor smtp'}
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 132;
    Tabela := 'servidorsmtp';
    CampoIndice := 'IDservidorsmtp';
    CampoLocalizar := 'DESCRICAOSERVIDOR';
    Titulo := 'Localizando Servidores SMTP';

    SQL := 'select *  from servidorsmtp  ' + #13#10 +
      'where  ( idsys_point_cliente = ' + Funcoes.GetIDPointCliente + '  ) and' + #13#10 +
      '( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDservidorsmtp';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'DESCRICAOSERVIDOR';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '133 Pedido entrega'}
  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 133;
    Tabela := 'pedidoentrega';
    CampoIndice := 'IDpedidoentrega';
    CampoLocalizar := 'idpedidoentrega';
    Titulo := 'Localizando Entregas';

    SQL := 'select *  from pedidoentrega  ' + #13#10 +
      'where  ( idsys_point_cliente = ' + Funcoes.GetIDPointCliente + '  ) and' + #13#10 +
      '( IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDpedidoentrega';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 180;
      NomeCampo := 'Responsavel';
      Titulo := 'Responsavel';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'dataentrega';
      Titulo := 'Dt. Entrega';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '134 corte da produção'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 134;
    Tabela := 'CORTE';
    CampoIndice := 'IDCORTE';
    CampoLocalizar := 'IDCORTE';
    Titulo := 'Localizando Cortes';

    SQL := 'select distinct  c.*, ic.idord_producao fk_idordem_prod , ' + #13#10 +
      ' ( select count( coalesce(icc.idfaccao, 0 ) )  from itens_corte  icc where  ' + #13#10 +
      ' ( icc.idcorte  = c.idcorte ) and (  coalesce( icc.idfaccao , 0 ) = 0 )  ) fk_qtd  ' + #13#10 +
      ' from corte c ' + #13#10 +
      ' left join itens_corte  ic on ( ic.idcorte  = c.idcorte  ) and ( ic.idsys_point_cliente = c.idsys_point_cliente ) and ( ic.idempresa = c.idempresa ) ' + #13#10 +
      ' where  ( c.idsys_point_cliente = ' + Funcoes.GetIDPointCliente + '  ) and' + #13#10 +
      ' ( c.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCORTE';
      Titulo := 'Codigo';
      ShowInFindForm := true;
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'dtcorte';
      Titulo := 'Dt. Corte';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
      TDatetime := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'responsavel';
      Titulo := 'Responsavel';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 130;
      NomeCampo := 'fk_idordem_prod';
      Titulo := 'Id. Ordem Produção';
      ShowInFindForm := True;
      IsFK := True;
      FKCampo := 'ic.idord_producao';

    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;

    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'fk_qtd';
      Titulo := 'Aberto';
      ShowInFindForm := False;
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);

{$ENDREGION}

  {NFCe}

{$REGION '135 cartoes'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 135;
    Tabela := 'CARTOES';
    CampoIndice := 'IDCARTOES';
    CampoLocalizar := 'IDCARTOES';
    Titulo := 'Localizando Cartões';

    SQL := 'SELECT c.* FROM cartoes c ' + #13#10 +
      ' where ( c.IDSYS_POINT_CLIENTE =' + Funcoes.GetIDPointCliente + ' ) AND ( c.idempresa = ' + Funcoes.GetIDEmpresa + ')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCARTOES';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 1;
      NomeCampo := 'bandeira';
      Titulo := 'Bandeira';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 1;
      NomeCampo := 'TIPOCARTAO';
      Titulo := 'Tipo Cartão';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 160;
      NomeCampo := 'CNPJ';
      Titulo := 'CNPJ';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '136 Gnre'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 136;
    Tabela := 'GNRE';
    CampoIndice := 'IDGNRE';
    CampoLocalizar := 'IDGNRE';
    Titulo := 'Localizando Lançamento GNRE';

    SQL := 'SELECT g.* FROM gnre g ' + #13#10 +
      ' where ( g.IDSYS_POINT_CLIENTE =' + Funcoes.GetIDPointCliente + ' ) AND ( g.idempresa = ' + Funcoes.GetIDEmpresa + ')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDGNRE';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 110;
      NomeCampo := 'DATA_VENCIMENTO';
      Titulo := 'Dt. Vencimento';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'numerognre';
      Titulo := 'Num. GNRE';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}

{$REGION '326  sped E115'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 326;
    Tabela := 'E115';
    CampoIndice := 'IDE115';
    CampoLocalizar := 'IDE115';
    Titulo := 'Localizando Lançamento E115';

    SQL := 'SELECT e.* FROM E115 e ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDE115';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'COD_INF_ADIC';
      Titulo := 'COD_INF_ADIC';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'VL_INF_ADIC';
      Titulo := 'VL_INF_ADIC';
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'DESCR_COMPL_AJ';
      Titulo := 'DESCR_COMPL_AJ';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '327  detalhe Mercadoria cronoanalise'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 327;
    Tabela := 'MERCADORIADETALHE';
    CampoIndice := 'IDMERCADORIADETALHE';
    CampoLocalizar := 'IDMERCADORIADETALHE';
    Titulo := 'Localizando Detalhe mercadoria Crinoanalise';

    SQL := 'SELECT md.* FROM MERCADORIADETALHE md ' + #13#10 +
      ' where ( md.IDSYS_POINT_CLIENTE =' + Funcoes.GetIDPointCliente + ' ) AND ( md.idempresa = ' + Funcoes.GetIDEmpresa + ')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDMERCADORIADETALHE';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 130;
      NomeCampo := 'ACOMPANHAMENTO';
      Titulo := 'Acompanhamento';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '328  SpedPisCofins0500'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 328;
    Tabela := 'PISCOFINS500';
    CampoIndice := 'IDPISCOFINS500';
    CampoLocalizar := 'IDPISCOFINS500';
    Titulo := 'Localizando 0500 Pis Cofins';

    SQL := 'SELECT s.*' + #13#10 +
      'FROM piscofins500 s' + #13#10 +
      'where ( s.IDSYS_POINT_CLIENTE =' + Funcoes.GetIDPointCliente + ') AND ( s.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDPISCOFINS500';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'NOME_CTA';
      Titulo := 'Nome da conta';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '329  Kit Mercadoria'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin
    Area := 329;
    Tabela := 'KITMERCADORIAO';
    CampoIndice := 'IDKITMERCADORIAO';
    CampoLocalizar := 'IDKITMERCADORIAO';
    Titulo := 'Localizando Kit para mercadorias';

    SQL := 'SELECT k.*' + #13#10 +
      'FROM KITMERCADORIAO k' + #13#10 +
      'where ( k.IDSYS_POINT_CLIENTE =' + Funcoes.GetIDPointCliente + ') AND ( k.idempresa = ' + Funcoes.GetIDEmpresa + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDKITMERCADORIAO';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

  end;

  Areas.Add(TempArea);

{$ENDREGION}

{$REGION '330  Kit Mercadoria pa pedido'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 330;
    Tabela := 'kitmercadoriao';
    CampoIndice := 'idkitmercadoriao';
    CampoLocalizar := 'referencia';
    Titulo := 'Localizando cadastro de Kit Mercadoria ';

    sql := 'select idkitmercadoriao ,' + #13#10 +
      '''KT'' referencia ,' + #13#10 +
      'descricao as descricao ,' + #13#10 +
      '''KITSL204''  fk_descGrupo ' + #13#10 +
      'from kitmercadoriao' + #13#10 +
      'where ( coalesce( status , ''A'' )  = ''A'' ) and ( IDEMPRESA =' + Funcoes.GetIDEmpresa +
      ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idkitmercadoriao';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'REFERENCIA';
      Titulo := 'Referência';
      ShowInFindForm := True;
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'Tipo';
      Titulo := 'Tipo';
      ShowInFindForm := False;
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 360;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;

    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}

{$REGION '331  Endereços de entrega'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 331;
    Tabela := 'PESSOAENTREGA';
    CampoIndice := 'idPESSOAENTREGA';
    CampoLocalizar := 'ENDERECO';
    Titulo := 'Localizando cadastro de Entregas ';

    sql := 'select pe.idPESSOAENTREGA , pe.endereco  ,' + #13#10 +
      ' pe.bairro , ci.descricao fk_descricao , ci.uf fk_uf ,' + #13#10 +
      ' re.descricao fk_descreg , pe.numero , pe.complemento ' + #13#10 +
      ' from PESSOAENTREGA pe' + #13#10 +
      ' left join cidade ci on ( ci.idcidade = pe.idcidade )' + #13#10 +
      ' left join regiao re on ( re.idregiao = pe.idregiao ) and ( re.idsys_point_cliente = pe.idsys_point_cliente ) and' + #13#10 +
      ' ( re.idempresa = pe.idempresa )' + #13#10 +
      ' where ( pe.IDEMPRESA = ' + Funcoes.GetIDEmpresa + ' )' + #13#10 +
      ' and ( pe.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' )';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idPESSOAENTREGA';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 250;
      NomeCampo := 'endereco';
      Titulo := 'Endereço';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'bairro';
      Titulo := 'Bairro';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 60;
      NomeCampo := 'Numero';
      Titulo := 'Numero';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'Complemento';
      Titulo := 'Complemento';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descricao';
      Titulo := 'Cidade';
      IsFK := True;
      FKCampo := 'ci.descricao';
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 40;
      NomeCampo := 'fk_uf';
      Titulo := 'UF';
      IsFK := True;
      FKCampo := 'ci.uf';
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descreg';
      Titulo := 'Região';
      IsFK := True;
      FKCampo := 're.descricao';
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}

{$REGION '332  Regioes de entrega'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 332;
    Tabela := 'REGIAO';
    CampoIndice := 'IDREGIAO';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando cadastro de Regiões ';

    sql := 'select idregiao , descricao ' + #13#10 +
      ' from regiao ' + #13#10 +
      ' where ( IDEMPRESA =' + Funcoes.GetIDEmpresa +
      ' ) and ( IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idregiao';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 300;
      NomeCampo := 'descricao';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}

{$REGION '333  Remessa Banco '}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 333;
    Tabela := 'REMESSA';
    CampoIndice := 'IDREMESSA';
    CampoLocalizar := 'DATAENVIO';
    Titulo := 'Localizando cadastro de Remessas';

    sql := 'select' + #13#10 +
      'r.* , b.descricao fk_descrBanco' + #13#10 +
      'from remessa r' + #13#10 +
      'inner join banco b on ( b.idbanco = r.idbanco )' + #13#10 +
      ' where ( r.IDEMPRESA =' + Funcoes.GetIDEmpresa +
      ' ) and ( r.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( r.tipo = ''E'')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idremessa';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 150;
      NomeCampo := 'DATAENVIO';
      Titulo := 'Data de envio';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descrBanco';
      Titulo := 'Banco';
      IsFK := True;
      FKCampo := 'b.descricao';
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}

{$REGION '334  Remessa Banco Ratificaçao'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 334;
    Tabela := 'REMESSA';
    CampoIndice := 'IDREMESSA';
    CampoLocalizar := 'DATAENVIO';
    Titulo := 'Localizando cadastro de Reenvio Remessas ';

    sql := 'select' + #13#10 +
      'r.* , b.descricao fk_descrBanco' + #13#10 +
      'from remessa r' + #13#10 +
      'inner join banco b on ( b.idbanco = r.idbanco )' + #13#10 +
      ' where ( r.IDEMPRESA =' + Funcoes.GetIDEmpresa +
      ' ) and ( r.IDSYS_POINT_CLIENTE = ' + Funcoes.GetIDPointCliente + ' ) and ( r.tipo = ''R'')';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idremessa';
      Titulo := 'Codigo';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 150;
      NomeCampo := 'DATAENVIO';
      Titulo := 'Data de envio';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_descrBanco';
      Titulo := 'Banco';
      IsFK := True;
      FKCampo := 'b.descricao';
      CanLocate := false;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}

{$REGION '335  Itens Remessa Banco Ratificaçao'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 335;
    Tabela := 'ITENSREMESSA';
    CampoIndice := 'IDITENSREMESSA';
    CampoLocalizar := 'NOSSONUMERO';
    Titulo := 'Localizando  Reenvio Remessas ';

    sql := 'select i.idconta_receber,i.idconta_receber_parcela,p.razao_social fk_razao_social,' + #13#10 +
      'crp.data_vencimento fk_dtvenc ,crp.valor fk_valor ,crp.IDITENSREMESSA ,crp.no_parcela ,' + #13#10 +
      'p.jur_cnpj,p.fis_cpf,p.numero,c.descricao as fk_descid ,p.bairro,' + #13#10 +
      'p.cep ,c.uf ,p.endereco,r.idbanco,i.nossonumero from itensremessa i' + #13#10 +
      'inner join remessa r on  ( r.idremessa = i.idremessa ) and' + #13#10 +
      '( r.idsys_point_cliente = i.idsys_point_cliente ) and ( r.idempresa = i.idempresa )' + #13#10 +
      'inner join conta_receber_parcela crp on  ( crp.idconta_receber_parcela = i.idconta_receber_parcela ) and' + #13#10 +
      '( crp.idsys_point_cliente = i.idsys_point_cliente ) and ( crp.idempresa = i.idempresa )' + #13#10 +
      'inner join Conta_Receber cr on ( cr.idconta_receber = crp.idconta_receber ) and' + #13#10 +
      '( cr.idsys_point_cliente = crp.idsys_point_cliente ) and ( cr.idempresa = crp.idempresa )' + #13#10 +
      'inner join pessoa p on ( p.idpessoa = cr.idpessoa ) and ( p.idsys_point_cliente = crp.idsys_point_cliente )' + #13#10 +
      'inner join cidade c on ( c.idcidade =p.idcidade ) Where  ( coalesce( r.tipo, ''E'' ) = ''E'' ) and not ( i.DTGERACAOREMESSA is null )  ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 80;
      NomeCampo := 'NOSSONUMERO';
      Titulo := 'Nosso numero';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_razao_social';
      Titulo := 'Cliente';
      IsFK := True;
      FKCampo := 'p.razao_social';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'no_parcela';
      Titulo := 'Nº Parc.';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 150;
      NomeCampo := 'fk_valor';
      Titulo := 'Valor';
      IsFK := True;
      FKCampo := 'crp.valor';
      CanLocate := True;
      Mascara := '###,##0.00';
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 150;
      NomeCampo := 'fk_dtvenc';
      Titulo := 'Dt.Venc.';
      IsFK := True;
      FKCampo := 'crp.data_vencimento';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

  end;
  Areas.Add(TempArea);
{$ENDREGION}

  // chao de fabrica


  {$REGION '336  chao de fabrica'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 336;
    Tabela := 'CHAOPRODUTO';
    CampoIndice := 'idCHAOPRODUTO';
    CampoLocalizar := 'IDCHAOPRODUTO';
    Titulo := 'Localizando Chao de fábrica';

    sql := 'SELECT chao.* from  CHAOPRODUTO chao ' ;


    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDCHAOPRODUTO';
      Titulo := 'Id. Chão';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DTGERACAO';
      Titulo := 'Dt. Geração';
      Mascara := 'dd/mm/yyyy';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);
  end;
  Areas.Add(TempArea);
{$ENDREGION}



{$REGION '337  produtos chao de fabrica'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 337;
    Tabela := 'cronoanalise';
    CampoIndice := 'idcronoanalise';
    CampoLocalizar := 'fk_referencia';
    Titulo := 'Localizando Referência para distribuição dos serviços';

    sql := 'SELECT cr.idcronoanalise, m.idmercadoria as fk_idmercadoria , t.codigotaman ,p.idproduto as fk_idproduto ,' + #13#10 +
      'm.referencia as fk_referencia ,' + #13#10 +
      'm.descricao as fk_desc_me ,t.descricao as fk_tamanho ,' + #13#10 +
      'c.descricao as fk_cores ,' + #13#10 +
      'case' + #13#10 +
      'when cr.tipo = ''1'' then ''Peça inteira''' + #13#10 +
      'when cr.tipo = ''2'' then ''Parte de cima''' + #13#10 +
      'when cr.tipo = ''3'' then ''Parte de baixo''' + #13#10 +
      'end tipo' + #13#10 +
      'from  cronoanalise cr' + #13#10 +
      'left JOIN produto p ON ( p.idproduto = cr.idproduto ) and ( p.idsys_point_cliente = cr.idsys_point_cliente )' + #13#10 +
      'and ( p.idempresa = cr.idempresa )' + #13#10 +
      'left JOIN mercadoria m ON ( m.idmercadoria = P.idmercadoria ) and ( m.idsys_point_cliente = cr.idsys_point_cliente )' + #13#10 +
      'and ( m.idempresa = cr.idempresa )' + #13#10 +
      'left JOIN tamanho t ON ( t.idtamanho = p.idtamanho ) and ( t.idsys_point_cliente = cr.idsys_point_cliente )' + #13#10 +
      'and ( t.idempresa = cr.idempresa )' + #13#10 +
      'LEFT JOIN cores c ON ( c.idcores = p.idcores ) and ( c.idsys_point_cliente = cr.idsys_point_cliente )' + #13#10 +
      'WHERE ( cr.idsys_point_cliente = :pidsys_point_cliente  )' + #13#10 +
      'and ( cr.idempresa = :pidempresa )' + #13#10 +
      'order by m.idmercadoria , t.codigotaman,c.descricao';
    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'idcronoanalise';
      Titulo := 'Id. Cronoanalise';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'fk_idmercadoria';
      Titulo := 'Id. merc.';
      IsFK := True;
      FKCampo := 'm.idmercadoria';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'fk_referencia';
      Titulo := 'Referência';
      IsFK := True;
      FKCampo := 'm.referencia';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 150;
      NomeCampo := 'fk_desc_me';
      Titulo := 'Descrição';
      IsFK := True;
      FKCampo := 'm.descricao';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'fk_cores';
      Titulo := 'Cor';
      IsFK := True;
      FKCampo := 'c.descricao';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 70;
      NomeCampo := 'fk_tamanho';
      Titulo := 'TM';
      IsFK := True;
      FKCampo := 't.descricao';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);


    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 100;
      NomeCampo := 'tipo';
      Titulo := 'Tipo';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);


  end;
  Areas.Add(TempArea);
{$ENDREGION}



{$REGION '338  maquinas fabrica'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 338;
    Tabela := 'maquinas';
    CampoIndice := 'IDMAQUINAS';
    CampoLocalizar := 'DESCRICAO';
    Titulo := 'Localizando Maquinas';

    sql := 'select *  from maquinas ';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDMAQUINAS';
      Titulo := 'Id. Maquina';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);



    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'DESCRICAO';
      Titulo := 'Descrição';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);


  end;
  Areas.Add(TempArea);
{$ENDREGION}



{$REGION '339  Industrializacao Kit'}

  TempArea := TAreaCollectionItem.Create;
  with TempArea do
  begin

    Area := 339;
    Tabela := 'INDUSTPRODUTO';
    CampoIndice := 'IDINDUSTPRODUTO';
    CampoLocalizar := 'DATAINDUSTR';
    Titulo := 'Localizando Industrialização Produto Kit.';

    sql := 'select * from INDUSTPRODUTO';

    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcNumber;
      Tamanho := 80;
      NomeCampo := 'IDINDUSTPRODUTO';
      Titulo := 'Id. Kit';
      ShowInFindForm := True;
    end;
    Campos.Add(TempCampo);



    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcText;
      Tamanho := 200;
      NomeCampo := 'RESPONSAVEL';
      Titulo := 'Responsavel';
      ShowInFindForm := True;
      CanLocate := True;
    end;
    Campos.Add(TempCampo);


    TempCampo := TCamposCollectionItem.Create;
    with TempCampo do
    begin
      Tipo := tcDate;
      Tamanho := 90;
      NomeCampo := 'DATAINDUSTR';
      Titulo := 'Data';
      Mascara := 'dd/mm/yyyy';
    end;
    Campos.Add(TempCampo);




  end;
  Areas.Add(TempArea);
{$ENDREGION}

end;

destructor TcFindArea.Destroy;
begin

  inherited;
end;

end.

