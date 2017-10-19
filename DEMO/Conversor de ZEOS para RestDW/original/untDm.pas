unit untDM;

interface

uses
  SysUtils, Classes, ZConnection, DB, ZAbstractRODataset, ZDataset,
  ZAbstractDataset, IniFiles, mkm_Funcs, ZStoredProcedure, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdFTP, Windows, wininet, Dialogs, mmsystem,
  xprocs, IdAntiFreezeBase, IdAntiFreeze, ZAbstractConnection,
  IdExplicitTLSClientServerBase, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  Tdm = class(TDataModule)
    ZConnection: TZConnection;
    dsFormaPagto: TDataSource;
    zQryFormasPagto: TZQuery;
    dsTiposPagto: TDataSource;
    zQryTiposPagto: TZQuery;
    dsLogin: TDataSource;
    zQryLogin: TZQuery;
    dsCentroCusto: TDataSource;
    zQryCentroCusto: TZQuery;
    dsBancos: TDataSource;
    zQryBancos: TZQuery;
    dsUsuarios: TDataSource;
    zQryUsuarios: TZQuery;
    dsGrupos: TDataSource;
    zQryGrupos: TZQuery;
    dsSubGrupos: TDataSource;
    zQrySubGrupos: TZQuery;
    dsFretes: TDataSource;
    zQryFretes: TZQuery;
    dsProdForn: TDataSource;
    zQryProdForn: TZQuery;
    dsProdutos: TDataSource;
    zQryProdutos: TZQuery;
    dsClientes: TDataSource;
    zQryClientes: TZQuery;
    dsFornecedores: TDataSource;
    zQryFornecedores: TZQuery;
    dsFuncionarios: TDataSource;
    zQryFuncionarios: TZQuery;
    dsCargos: TDataSource;
    zQryCargos: TZQuery;
    zQryTransportadoras: TZQuery;
    dsTransportadoras: TDataSource;
    dsMontadoras: TDataSource;
    zQryMontadoras: TZQuery;
    dsCarros: TDataSource;
    zQryCarros: TZQuery;
    dsCombustiveis: TDataSource;
    zQryCombustiveis: TZQuery;
    dsFuracoes: TDataSource;
    zQryFuracoes: TZQuery;
    dsAros: TDataSource;
    zQryTamAros: TZQuery;
    dsTipoPneus: TDataSource;
    zQryTipoPneus: TZQuery;
    dsCustos: TDataSource;
    zQryCustos: TZQuery;
    dsProdCustos: TDataSource;
    zQryProdCustos: TZQuery;
    dsEmpresas: TDataSource;
    zQryEmpresas: TZQuery;
    dsConvenios: TDataSource;
    zQryConvenios: TZQuery;
    dsProdEstoque: TDataSource;
    zQryProdEstoque: TZQuery;
    dsProdAplic: TDataSource;
    zQryProdAplic: TZQuery;
    zQryServicos: TZQuery;
    dsServicos: TDataSource;
    zQryServCustos: TZQuery;
    dsServCustos: TDataSource;
    dsParametros: TDataSource;
    zQryParametros: TZQuery;
    dsASCII: TDataSource;
    zQryASCII: TZQuery;
    zQryCadGeral: TZQuery;
    dsCadGeral: TDataSource;
    dsCliVeiculos: TDataSource;
    zQryCliVeiculos: TZQuery;
    zQryCliVeiculosPLACA: TStringField;
    zQryCliVeiculosMONTADORA: TStringField;
    zQryCliVeiculosCARRO: TStringField;
    zQryCliVeiculosCOMBUSTIVEL: TStringField;
    zQryCliVeiculosANO: TIntegerField;
    zQryCliVeiculosMODELO: TIntegerField;
    zQryCliVeiculosCODIGO: TIntegerField;
    zQryCliVeiculosCODICARRO: TIntegerField;
    zQryCliVeiculosDESCRICAO: TStringField;
    zQryCliVeiculosUSUARIO: TStringField;
    zQryCliVeiculosCHASSIS: TStringField;
    zQryCliVeiculosCODICLI: TIntegerField;
    zQryCliVeiculosCODICOMBUSTIVEL: TIntegerField;
    dsOSes: TDataSource;
    zQryOSes: TZQuery;
    zQrySeguradoras: TZQuery;
    dsSeguradoras: TDataSource;
    dsOSesPecas: TDataSource;
    zQryOSesPecas: TZQuery;
    dsOSesServicos: TDataSource;
    zQryOSesServicos: TZQuery;
    zQryConsultaGeral: TZQuery;
    dsConsultaGeral: TDataSource;
    dsOSesPagto: TDataSource;
    zQryOSesPagto: TZQuery;
    dsSessoes: TDataSource;
    zQrySessoes: TZQuery;
    dsMarcas: TDataSource;
    zQryMarcas: TZQuery;
    zQryFunc_Prod: TZQuery;
    dsFunc_Prod: TDataSource;
    zQryFunc_Serv: TZQuery;
    dsFunc_Serv: TDataSource;
    zQryFunc_ProdPRODUTO: TStringField;
    zQryFunc_ProdCODIGO: TIntegerField;
    zQryFunc_ProdCOMISSAO: TFloatField;
    zQryFunc_ServSERVICO: TStringField;
    zQryFunc_ServCODIGO: TIntegerField;
    zQryFunc_ServCOMISSAO: TFloatField;
    zQryContasReceber: TZQuery;
    dsContasReceber: TDataSource;
    zQryPlanoContas: TZQuery;
    dsPlanoContas: TDataSource;
    dsCFOPs: TDataSource;
    zQryCFOPs: TZQuery;
    dsProdComposicao: TDataSource;
    zQryProdComposicao: TZQuery;
    dsCompras: TDataSource;
    zQryCompras: TZQuery;
    dsComprasPecas: TDataSource;
    zQryComprasPecas: TZQuery;
    dsComprasServicos: TDataSource;
    zQryComprasServicos: TZQuery;
    dsComprasPagto: TDataSource;
    zQryComprasPagto: TZQuery;
    zQryHistoricoReceber: TZQuery;
    dsHistoricoReceber: TDataSource;
    zQryContasPagar: TZQuery;
    dsContasPagar: TDataSource;
    zQryHistoricoPagar: TZQuery;
    dsHistoricoPagar: TDataSource;
    zQryMovDia: TZQuery;
    dsMovDia: TDataSource;
    dsRecibos: TDataSource;
    zQryRecibos: TZQuery;
    dsProventos: TDataSource;
    zQryProventos: TZQuery;
    zQryNFSPecas: TZQuery;
    zQryNFSservicos: TZQuery;
    dsNFSservicos: TDataSource;
    dsNFSpecas: TDataSource;
    zQryGeral: TZQuery;
    dsGeral: TDataSource;
    zQryNFsItens: TZQuery;
    dszQryNFsItens: TDataSource;
    zQryECFs: TZQuery;
    dsECFs: TDataSource;
    zQryECFsPEcas: TZQuery;
    zQryECFsServicos: TZQuery;
    dsECFsServicos: TDataSource;
    dsECFsPecas: TDataSource;
    dsMovFunc: TDataSource;
    zQryMovFunc: TZQuery;
    dsAvisos: TDataSource;
    zQryAvisos: TZQuery;
    dsAgenda: TDataSource;
    zQryAgenda: TZQuery;
    zQryRestricoes: TZQuery;
    dsRestricoes: TDataSource;
    dsContasPagar_Anexos: TDataSource;
    zQryContasPagar_Anexos: TZQuery;
    zQryContasReceber_Anexos: TZQuery;
    dsContasReceber_Anexos: TDataSource;
    zQryAgendaItens: TZQuery;
    dsAgendaItens: TDataSource;
    dsCliDescontos: TDataSource;
    zQryCliDescontos: TZQuery;
    ZQuery1: TZQuery;
    DataSource1: TDataSource;
    dsMovCaixa: TDataSource;
    zQryMovCaixa: TZQuery;
    zQryCliVeiculosVENDIDO: TStringField;
    zQryCheques: TZQuery;
    dsCheques: TDataSource;
    dsAcertos_Estoque: TDataSource;
    zQryAcertos_Estoque: TZQuery;
    dsAcertos_Estoque_Pecas: TDataSource;
    zQryAcertos_Estoque_Pecas: TZQuery;
    zQryAtualizar: TZQuery;
    dsAtualizar: TDataSource;
    zQryRotas: TZQuery;
    dsRotas: TDataSource;
    dsCli_Prod: TDataSource;
    zQryCli_Prod: TZQuery;
    dsRefCusto: TDataSource;
    zQryRefCusto: TZQuery;
    zQryTipoUso: TZQuery;
    dsTipoUso: TDataSource;
    zQryTipoSuperficie: TZQuery;
    dsTipoSuperficie: TDataSource;
    zQryTipoAplicacao: TZQuery;
    dsTipoAplicacao: TDataSource;
    dsMovTransf: TDataSource;
    zQryMovTransf: TZQuery;
    dsMeta_Comissao: TDataSource;
    zQryMeta_Comissao: TZQuery;
    zQryExtintores: TZQuery;
    dsExtintores: TDataSource;
    zQryFrota: TZQuery;
    dsFrota: TDataSource;
    zQryFrotaDesp: TZQuery;
    dsFrotaDesp: TDataSource;
    dsClassifCli: TDataSource;
    zQryClassifCli: TZQuery;
    dsTipos_Cheques: TDataSource;
    zQryTipos_Cheques: TZQuery;
    zQryTiposReclamacao: TZQuery;
    dsTiposReclamacao: TDataSource;
    zQryPosVenda: TZQuery;
    dsPosVenda: TDataSource;
    zQryTab_Icms: TZQuery;
    dsTab_Icms: TDataSource;
    zQryProdLotes: TZQuery;
    dsProdLotes: TDataSource;
    zQryContrato_Fornecimento: TZQuery;
    dsContrato_Fornecimento: TDataSource;
    zQryContrato_Fornec_Pecas: TZQuery;
    dsContrato_Fornec_Pecas: TDataSource;
    dsLimitesdeCredito: TDataSource;
    zQryLimitesdeCredito: TZQuery;
    zQryProdSeriais: TZQuery;
    dsProdSeriais: TDataSource;
    zQryProdFotos: TZQuery;
    dsProdFotos: TDataSource;
    zQryComprasSeriais: TZQuery;
    dsComprasSeriais: TDataSource;
    zQryMedicos: TZQuery;
    dsMedicos: TDataSource;
    zQryPacientes: TZQuery;
    dsPacientes: TDataSource;
    dsContratos: TDataSource;
    zQryContratos: TZQuery;
    dsContratosPecas: TDataSource;
    zQryContratosPecas: TZQuery;
    dsContratosPagto: TDataSource;
    zQryContratosPagto: TZQuery;
    zQryTiposClientes: TZQuery;
    dsTiposClientes: TDataSource;
    zQryMov_Aparelhos: TZQuery;
    dsMov_Aparelhos: TDataSource;
    zQryEspecialidades: TZQuery;
    dsEspecialidades: TDataSource;
    zQryFabricantes: TZQuery;
    dsFabricantes: TDataSource;
    zQryOSesSeriais: TZQuery;
    dsOSesSeriais: TDataSource;
    dsContratos_Seriais: TDataSource;
    zQryContratosSeriais: TZQuery;
    zQryContasRec_Locm: TZQuery;
    zQryHistoricoReceber_Locm: TZQuery;
    dsHistoricoReceber_Locm: TDataSource;
    dsContasRec_Locm: TDataSource;
    zQryContasRec_Locm_Anexos: TZQuery;
    dsContasRec_Locm_Anexos: TDataSource;
    zQryAcertos_Precos_Pecas: TZQuery;
    zQryAcertos_Precos: TZQuery;
    dsAcertos_Precos: TDataSource;
    dsAcertos_Precos_Pecas: TDataSource;
    zQrySMS_Enviados: TZQuery;
    dsSMS_Enviados: TDataSource;
    zQryConfere_Estoque_Pecas: TZQuery;
    zQryConfere_Estoque: TZQuery;
    dsConfere_Estoque: TDataSource;
    dsConfere_Estoque_Pecas: TDataSource;
    dsBoletos: TDataSource;
    zQryBoletos: TZQuery;
    zQryCotacoes: TZQuery;
    dsCotacoes: TDataSource;
    dsMoedas: TDataSource;
    zQryMoedas: TZQuery;
    IdFTP_plugin: TIdFTP;
    zQryPromocoes: TZQuery;
    dsPromocoes: TDataSource;
    zQryVenda_PorQtde: TZQuery;
    dsVenda_PorQtde: TDataSource;
    IdFTP_netrevenda: TIdFTP;
    zQryGarantias_Cral: TZQuery;
    dsGarantias_Cral: TDataSource;
    zQryUnidades: TZQuery;
    dsUnidades: TDataSource;
    zQryEmp: TZQuery;
    dsEmp: TDataSource;
    zQryPesquisaDIEF: TZQuery;
    DataSource2: TDataSource;
    zQryIncluiDIEF: TZQuery;
    DataSource3: TDataSource;
    zQryTabComDia: TZQuery;
    dsTabComDia: TDataSource;
    zQrySucatas_Cral: TZQuery;
    dsSucatas_CRAL: TDataSource;
    zQryAidfs: TZQuery;
    dsAidfs: TDataSource;
    zQryEstagios: TZQuery;
    dsEstagios: TDataSource;
    zQryBina_Mem: TZQuery;
    dsBina_Mem: TDataSource;
    zQryCorretores: TZQuery;
    dsCorretores: TDataSource;
    zQryNFs: TZQuery;
    dsNFs: TDataSource;
    zQryNFE: TZQuery;
    dsNFE: TDataSource;
    zQryNFEPecas: TZQuery;
    dsNFEPecas: TDataSource;
    zQryNFEServicos: TZQuery;
    dsNFEServicos: TDataSource;
    IdFTP_hostnet: TIdFTP;
    zQryMetasVendas: TZQuery;
    dsMetasVendas: TDataSource;
    zQryMetasTotais: TZQuery;
    dsMetasTotais: TDataSource;
    zQryMetasTotaisCODIMETA: TIntegerField;
    zQryMetasTotaisTIPO: TStringField;
    zQryMetasTotaisDIA_INI: TIntegerField;
    zQryMetasTotaisDIA_FIM: TIntegerField;
    zQryMetasTotaisMES: TIntegerField;
    zQryMetasTotaisANO: TIntegerField;
    zQryMetasTotaisDEBITO_ACUMULADO: TFloatField;
    zQryMetasTotaisCODIFUNC: TIntegerField;
    zQryMetasTotaisBRONZE: TFloatField;
    zQryMetasTotaisPRATA: TFloatField;
    zQryMetasTotaisOURO: TFloatField;
    zQryMetasTotaisDIAMANTE: TFloatField;
    zQryMetasTotaisREALIZADO: TFloatField;
    zQryMetasTotaisMETA_ATINGIDA: TStringField;
    zQryMetasTotaisDEBITO_SEMANA: TFloatField;
    zQryMetasTotaisTICKET_MEDIO: TFloatField;
    zQryMetasTotaisNUM_VENDAS: TIntegerField;
    zQryMetasTotaisVENDEDOR: TStringField;
    zQryMetasTotaisMensal: TZQuery;
    IntegerField1: TIntegerField;
    StringField1: TStringField;
    IntegerField2: TIntegerField;
    IntegerField3: TIntegerField;
    IntegerField4: TIntegerField;
    IntegerField5: TIntegerField;
    FloatField1: TFloatField;
    IntegerField6: TIntegerField;
    FloatField2: TFloatField;
    FloatField3: TFloatField;
    FloatField4: TFloatField;
    FloatField5: TFloatField;
    FloatField6: TFloatField;
    StringField2: TStringField;
    FloatField7: TFloatField;
    FloatField8: TFloatField;
    IntegerField7: TIntegerField;
    StringField3: TStringField;
    dsMetasTotaisMensal: TDataSource;
    zQryHistoricoPagarFORMAPAGTO: TStringField;
    zQryHistoricoPagarDTPAGTO: TDateField;
    zQryHistoricoPagarNUMDOCUMENTO: TStringField;
    zQryHistoricoPagarVALORPAGO: TFloatField;
    zQryHistoricoPagarVALORCORRIGIDO: TFloatField;
    zQryHistoricoPagarVALORJUROS: TFloatField;
    zQryHistoricoPagarVALORMULTA: TFloatField;
    zQryHistoricoPagarVALORDESCONTO: TFloatField;
    zQryHistoricoPagarTIPOPAGTO: TIntegerField;
    zQryHistoricoPagarCODICONTASAIDA: TIntegerField;
    zQryHistoricoPagarCODICONTADESPREC: TIntegerField;
    zQryHistoricoPagarCODIEMP: TIntegerField;
    zQryHistoricoPagarCODIGO: TIntegerField;
    zQryHistoricoPagarAPOIO: TStringField;
    zQryHistoricoPagarCONTA_BAIXA: TStringField;
    zQryHistoricoPagarCONTA_DESP: TStringField;
    zQryNFsDI: TZQuery;
    dsNFSDi: TDataSource;
    zQryPromocoesProds: TZQuery;
    dsPromocoesProds: TDataSource;
    zQryPromocoesProdsCODIGO: TIntegerField;
    zQryPromocoesProdsCODIPROMOCAO: TIntegerField;
    zQryPromocoesProdsCODIPROD: TIntegerField;
    zQryPromocoesProdsVALOR_PROD: TFloatField;
    zQryPromocoesProdsDESC_PROD: TFloatField;
    zQryPromocoesProdsPECA: TStringField;
    zQryPromocoesProdsREFERENCIA: TStringField;
    zQryProdRefer: TZQuery;
    dsProdRefer: TDataSource;
    zQryProds_Servs: TZQuery;
    dsProds_Servs: TDataSource;
    zQryOSesConferenciaPecas: TZQuery;
    dsOSesConferenciaPecas: TDataSource;
    zQryOSesConferencia: TZQuery;
    dsOSesConferencia: TDataSource;
    zQryCores: TZQuery;
    dsCores: TDataSource;
    zQryMensagensSMS: TZQuery;
    dsMensagensSMS: TDataSource;
    zQryParametros_Texto_OS: TZQuery;
    dsParametros_Texto_OS: TDataSource;
    zQryParametros_Texto_OS2: TZQuery;
    dsParametros_Texto_OS2: TDataSource;
    zQryHistoricos: TZQuery;
    dsHistoricos: TDataSource;
    zQrySql: TZQuery;
    zQrySqlECF: TZQuery;
    zQryContador: TZQuery;
    zQryContador2: TZQuery;
    zQryTB_ECF: TZQuery;
    dsTB_ECF: TDataSource;
    zQryNaturezaOp: TZQuery;
    dsNaturezaOp: TDataSource;
    zQryNFsPagto: TZQuery;
    dsNFsPagto: TDataSource;
    dsPlanosTelefonia: TDataSource;
    zQryPlanosTelefonia: TZQuery;
    IdFTP_conexao: TIdFTP;
    IdAntiFreeze: TIdAntiFreeze;
    IdFTP_KingHost: TIdFTP;
    IdServerIOHandlerSSLOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    IdFTP_conexao_SSL: TIdFTP;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm: Tdm;

  IniFile      : TiniFile; //criará o arquivo ini
  BaseDeDados,
  Letra,
  Servidor     : String; //vai armazenar a leitura do arquivo ini


implementation

uses untMain, untPopUp;

{$R *.dfm}

procedure Tdm.DataModuleCreate(Sender: TObject);
VAR
  flags : LongWord;

  _TEMNET : BOOLEAN;

  _sql,  sufixo, varC_Cnpj_Local ,
  _versionLOCAL, _versionONLINE,
  _versionLOCAL1, _versionONLINE1,
  _versionLOCAL2, _versionONLINE2,
  _versionLOCAL3, _versionONLINE3,
  _versionLOCAL4, _versionONLINE4 : String;

  _dataLOCAL, _dataONLINE : TDateTime;

  nodetails : TStringList;

  indice, k,
  tam_1,
  tam_2 : Integer;
  //myPopUp: TfPopUp;

   _num_ibexpert,
   _num_nautilus_cfg,
   _num_mkmdatafile : integer;

   _mc,
   _bloq, _trava, _ged, _mes, _dia : String;

   bloq ,  trava,varC_NumMicros, varC_DiaCob, varC_GED, varC_Nome,
   DIA, MES, ANO, retorno : string;

begin

     //_senha_ftp_srv1 := '5@t1r0d1@5377101cpWHM' ;//'M1kromundoM@4gy@';//'14mT7xyl6Q';//
     //_senha_ftp_srv2 := '@r@c@tik@rdecTianguA';
     //_senha_ftp_srv3 := '1q2w3e4r5t';
     _senha_ftp_srv1   := '5@t1r0d1@5377101cpWHM';//'14mT7xyl6Q';//
     _senha_ftp_srv2   := '@r@c@tik@rdecTianguA';
     _senha_ftp_srv3   := '5@t1ro377';//'5@t1r0d1@5';//'1q2w3e4r5t';

     //saber qual versao do FB está rodando
     zQryGeral.SQL.Text := ' SELECT rdb$get_context(''SYSTEM'', ''ENGINE_VERSION'') as version ' +
                           ' from rdb$database ';

     zQryGeral.Open;

     If Copy( zQryGeral.FieldByName('version').AsString, 1, 3 ) <> '2.5' then
     begin

          frmMain.mkmErro( 'O Firebird instalado neste micro não é compatível com o Sistema NAUTILUS.'+
                           'Contate a Mikroundo.( Versão deve ser 2.5' );
          Halt;
          Exit;
     end;

     //saber qual a porta está ativa


     //Se nao existir o CFG, criar dinamicamente um padrão
     //====================================================

     if not FileExists( 'c:\mkmSistemas\mkmCfgNautilus_Commerce_Erp.Ini' ) then
     begin
       IniFile          := TiniFile.Create   ('c:\mkmSistemas\mkmCfgNautilus_COMMERCE_ERP.Ini'); //criará o arquivo ini e armazenará no variável IniFile

       //sistema
       IniFile.WriteString( 'sistema'     , 'titulo     '       , ' NAUTILUS PDV' ) ;
       IniFile.WriteString( 'sistema'     , 'versao     '       , ' 02.01.00.00' ) ;
       IniFile.WriteString( 'sistema'     , 'aplicacao  '       , ' PDV - Ponto de Venda' ) ;
       IniFile.WriteString( 'sistema'     , 'splash     '       , ' 51' ) ;
       IniFile.WriteString( 'sistema'     , 'licencas   '       , ' 3ST7I6AJU2DH0QPNWMER1C85FKV4GBO#L9BF' ) ;
       IniFile.WriteString( 'sistema'     , 'atuacao    '       , '' ) ;
       IniFile.WriteString( 'sistema'     , 'Atuacao_Idx'       , ' 0' ) ;

       IniFile.WriteString( 'sistema'     , 'hst1       '       , ' U7GESWA1JKBDVMH2ORP0CLN#I68F43QT59' ) ;
       IniFile.WriteString( 'sistema'     , 'hst2       '       , ' IGVMKBQ75ENSPDJFH0ALWU2O8R413C#T69' ) ;
       IniFile.WriteString( 'sistema'     , 'hst3       '       , ' NTWPIUB4VAK27C38RMOJFS5#HQEG1DL069CQC1' ) ;

       //acesso
       IniFile.WriteString( 'acesso'      , 'drive      '       , ' C' ) ;
       IniFile.WriteString( 'acesso'      , 'pasta      '       , ' \mkmdados' ) ;
       IniFile.WriteString( 'acesso'      , 'Hostname   '       , '' ) ;
       IniFile.WriteString( 'acesso'      , 'Porta      '       , ' 3050' ) ;
       IniFile.WriteString( 'acesso'      , 'bd_user    '       , ' 5DWNAUGIJO8TKPB7H3FC#S64REM2V0LQ19CCAWD' ) ;
       IniFile.WriteString( 'acesso'      , 'bd_pass    '       , ' A2J74TQHNVC0G61ODBRLP8S#E3K5FIMUW9' ) ;
       IniFile.WriteString( 'acesso'      , 'bd_name    '       , ' 1HL35G#8TFPMJB6UC7N0QDEIWV2RS4KAO9' ) ;
       IniFile.WriteString( 'acesso'      , 'terminal   '       , Cripta('SERVIDOR') ) ;
       IniFile.WriteString( 'acesso'      , 'Servidor   '       , ' S' ) ;
       IniFile.WriteString( 'acesso'      , 'Remoto     '       , ' N' ) ;

       //nf
       IniFile.WriteString( 'nf'          , 'modelo     '       , '' ) ;
       IniFile.WriteString( 'nf'          , 'ecfdescr   '       , ' 29' ) ;

       //ecf
       IniFile.WriteString( 'ecf'         , 'imprime    '       , ' N' ) ;
       IniFile.WriteString( 'ecf'         , 'Paf        '       , ' N' ) ;

       //etq
       IniFile.WriteString( 'etq'         , 'temperatura'       , ' 10' ) ;
       IniFile.WriteString( 'etq'         , ';logo      '       , ' c:\mkmdados\extras\imagens\logo.pcx' ) ;
       IniFile.WriteString( 'etq'         , 'porta      '       , ' \\127.0.0.1\IMP_ARGOX' ) ;


       IniFile.Free; //libera a variável da memória
     end;



     If Not DirectoryExists( 'C:\Windows' ) Then
        MkDir( 'C:\Windows' );

     // RECURSO PARA GERAR SENHA PELO PROPRIO SISTEMA  ,
     // DESSA FORMA, SE TIVER INTERNET, SEMPRE ESTARÁ COM
     // COM O ARQ DE CLIENTES MAIS RECENTE PARA TESTAR NA
     // HORA DE GERAR A SENHA.
     if FileExists( 'c:\mkmutils\mkm_contratos.ini' ) then
        DeleteFile( 'c:\mkmutils\mkm_contratos.ini' );


     //===================================================
     //VERIFICAR SE HÁ NOVA VERSAO DISPONIVEL PRA DOWNLOAD
     //===================================================

     sufixo := WinVersion;

     if ( sufixo <> 'Windows 95' ) and
        ( sufixo <> 'Windows 98' ) then
     begin

         sufixo := '';

         Try
              _TEMNET := frmMain.TemInternet;
         except
             _TEMNET := False;
         end;


         //if WinsockEnabled then
         begin

             //=====================================
             //VERIFICA CONEXAO COM INTERNET
             //=====================================
           if not _TEMNET then//   Not InternetGetConnectedState( @Flags, 0 ) then
           begin
              frmMain.mkmMensagem( 'O sistema não detectou conexão com internet.' );
              //Exit;
           end;
             //=====================================




            //pega informacoes do FTP utilizado
            {
            IniFile         := TiniFile.Create   ('c:\mkmSistemas\mkmCfgNautilus_COMMERCE_ERP.Ini');
                 //@r@c@tik@rdecTianguA
            // todos os dados estao criptografados....
            IdFTP_netrevenda.Host         := IniFile.ReadString( 'sistema' , 'hst1' ,  '' ) ;// NetRevenda //'U7GESWA1JKBDVMH2ORP0CLN#I68F43QT59'
            IdFTP_netrevenda.Username     := IniFile.ReadString( 'sistema' , 'hst2' ,  '' ) ;           //'IGVMKBQ75ENSPDJFH0ALWU2O8R413C#T69'
            IdFTP_netrevenda.Password     := IniFile.ReadString( 'sistema' , 'hst3' ,  '' ) ;   //'NTWPIUB4VAK27C38RMOJFS5#HQEG1DL069CQC1'

            if IdFTP_netrevenda.Host      = '' then
               IdFTP_netrevenda.Host      := DeCripta('U7GESWA1JKBDVMH2ORP0CLN#I68F43QT59' ) ;// NetRevenda //'U7GESWA1JKBDVMH2ORP0CLN#I68F43QT59'

            if IdFTP_netrevenda.Username  = '' then
               IdFTP_netrevenda.Username  := DeCripta('IGVMKBQ75ENSPDJFH0ALWU2O8R413C#T69' ) ;           //'IGVMKBQ75ENSPDJFH0ALWU2O8R413C#T69'

            if IdFTP_netrevenda.Password  = '' then
               IdFTP_netrevenda.Password  := DeCripta('NTWPIUB4VAK27C38RMOJFS5#HQEG1DL069CQC1' ) ;   //'NTWPIUB4VAK27C38RMOJFS5#HQEG1DL069CQC1'

            IniFile.Free;
            }
             //efetua a conexão ao FTP


             If _TEMNET then
             begin

                 if IdFTP_netrevenda.Connected then
                    IdFTP_netrevenda.Disconnect;

                 if IdFTP_conexao.Connected then
                    IdFTP_conexao.Disconnect;




                 //_TEMNET := True;
                 try
                   //IdFTP_netrevenda.Connect();
                   //_provedor := 'netrevenda';
                   //_provedor := 'argohost';
                   _provedor := 'locaweb';



                   IdFTP_conexao.Host        := IdFTP_netrevenda.Host; //IdDNSResolver.Resolve( 'ftp.mikromundo.com' );//
                   IdFTP_conexao.Username    := IdFTP_netrevenda.Username;
                   IdFTP_conexao.Password    := _senha_ftp_srv1;//'M1kromundoM@4gy@';//IdFTP_netrevenda.Password;//'aa';//
                   IdFTP_conexao.ReadTimeout := IdFTP_netrevenda.ReadTimeout;

                        {
                    if ( frmStatus = nil ) then
                      frmStatus := TfrmStatus.Create(Application);

                    frmStatus.lbl1.Caption      := 'Aguarde processamento';
                    frmStatus.lblStatus.Caption := 'Processando Dados: Comunicando com Servidor Externo...';
                    frmStatus.Show;
                    frmStatus.BringToFront;
                    Application.ProcessMessages;
                         }

                       //try
                          //IdFTP_conexao.InputBuffer.Clear;
                          IdFTP_conexao.Connect;
                       //except
                       //    frmMain.mkmMensagem( 'Problema na conexão com servidor externo. Verifique a conexão com internet.');
                       //    _TEMNET := False;
                       //end;

                   //if IdFTP_conexao.Connected then
                   //   ShowMessage( 'conectado ' + _provedor );

                 except

                   On E:Exception Do
                   begin

                       //if ( frmStatus <> nil ) then
                       //  frmStatus.Hide;
                       //ShowMessage('Não há conexão com o servidor da Mikromundo. Isso impede de checarmos se há atualizações.');
                       //frmMain.mkmMensagem( E.Message );
                       //_TEMNET := False;

                       frmMain.mkmMensagem( 'Houve falha na comunicação com SERVIDOR 1( LocaWeb ). Tentando com o SERVIDOR ( KingHost ).' );

                       varB_sim := True;

                       if varB_sim then
                       begin

                           if IdFTP_conexao.Connected then
                              IdFTP_conexao.Disconnect;

                           //_TEMNET := True;
                           try
                             //IdFTP_hostnet.Connect();
                             _provedor := 'kinghost';

                             IdFTP_conexao.Host        := IdFTP_KingHost.Host;//IdDNSResolver.Resolve( 'ftp.flaviomotta.com' );//
                             IdFTP_conexao.Username    := IdFTP_KingHost.Username;
                             IdFTP_conexao.Password    := _senha_ftp_srv3;//IdFTP_KingHost.Password;
                             IdFTP_conexao.ReadTimeout := IdFTP_KingHost.ReadTimeout;

                             IdFTP_conexao.Connect;

                             //if IdFTP_conexao.Connected then
                             //   ShowMessage( 'conectado ' + _provedor );

                           except

                             On E:Exception Do
                             begin
                                 //ShowMessage('Não há conexão com o servidor da Mikromundo. Isso impede de checarmos se há atualizações.');
                                 frmMain.mkmMensagem( 'Não há conexão com o servidor da Mikromundo( KingHost ).' + sLineBreak +
                                                      E.Message );
                                 //_TEMNET := False;
                             end;

                           end;

                       end
                       else
                       begin
                           _TEMNET := False;
                           //if ( frmStatus <> nil ) then
                           //  frmStatus.Hide;
                       end;

                   end;

                 end;

             end;

         end;

         varC_NumMicros   := '15';
         varC_TempString  := 'OK';

         //---------------------------------------------------------------------------------------------------------------------------------
         //VERIFICA DADOS DA ULT. CONEXÃO - Se o mês atual, for diferente do mês da últ. conexão, é preciso atualizar( ON Line ou manual )
         //---------------------------------------------------------------------------------------------------------------------------------

         if ( not FileExists('c:\mkmdados\extras\nautilus_integrity.ini') ) or
            ( not FileExists('c:\mkmutils\nautilus_controler.ini') ) then
         begin

            DeleteFile( 'c:\mkmutils\nautilus_controler.ini' );
            DeleteFile( 'c:\mkmsistemas\nautilus_cfgintegridade.ini' );
            DeleteFile( 'c:\mkmdados\extras\nautilus_integrity.ini' );

            varC_TempString := '';
            varC_Ctrl_MES   := '99';

         end;


         if varC_TempString <> '' then
         begin

             IniFile         := TiniFile.Create   ('c:\mkmutils\nautilus_controler.ini');

             // todos os dados estao criptografados....
             varC_Trava       := IniFile.ReadString( 'sistema' , 'TR' , 'S') ;
             varC_Bloq        := IniFile.ReadString( 'sistema' , 'BQ' , 'S') ;
             varC_NFe2        := IniFile.ReadString( 'sistema' , 'NF' , 'N') ;
             varC_Boleto      := IniFile.ReadString( 'sistema' , 'BL' , 'N') ;
             varI_DiaCobranca := StrToIntDef( IniFile.ReadString( 'sistema' , 'DC' , '1'), 0) ;
             varC_NumMicros   := IniFile.ReadString( 'sistema' , 'MC' , '50') ;
             varC_GED         := IniFile.ReadString( 'sistema' , 'GD' , 'N') ;
             varC_TempString  := IniFile.ReadString( 'sistema' , 'CT' , '112') ;

             //varC_Cnpj_Local  := Decripta( IniFile.ReadString( 'sistema' , 'PJ' , varC_Cnpj_Local ) ) ;

             varC_Ctrl_DIA    := Copy( varC_TempString, 1, 1 );   // dia para calculo
             varC_Ctrl_MES    := Copy( varC_TempString, 2, 10 );  // mes que foi gerada a senha


                   //===================================================================
                   // DESCriptografar os dados de liberacao com nova técnica
                   //===================================================================

                   varC_Temp2       := frmMain.DescriptografarDadosCliente( varC_Trava, varC_Bloq, varC_NFe2, varC_Boleto, varC_NumMicros, varC_TempString, varC_GED );

                   varC_TempString  := varC_Temp2;

                   varC_Ctrl_DIA    := Copy( varC_Temp2 , 1 , 1  );
                   varC_Ctrl_MES    := Copy( varC_Temp2 , 2 , Pos( '.', varC_TempString ) - 1  );

                   if ( length( varC_Ctrl_MES ) = 2 ) and ( Pos( '.', varC_TempString ) > 0 ) then
                      varC_Ctrl_MES := Copy( varC_Ctrl_MES, 1, 1 )
                   else
                   if ( length( varC_Ctrl_MES ) = 3 ) and ( Pos( '.', varC_TempString ) > 0 ) then
                      varC_Ctrl_MES := Copy( varC_Ctrl_MES, 1, 2 );


                   varC_TempString  := Copy( varC_TempString , Pos( '.', varC_TempString ) + 1 , 100 );

                   varC_Trava       := Copy( varC_TempString, 3, 1 );

                   varC_TempString  := Copy( varC_TempString, Pos( 'BQ', varC_TempString ) , 100 );

                   varC_Bloq        := Copy( varC_TempString, 3, 1 );

                   varC_TempString  := Copy( varC_TempString, Pos( 'NF', varC_TempString) , 100 );

                   varC_NFe2        := Copy( varC_TempString, 3, 1 );

                   varC_TempString  := Copy( varC_TempString, Pos( 'BL', varC_TempString ) , 100 );

                   varC_Boleto      := Copy( varC_TempString, 3, 1 );

                   varC_TempString  := Copy( varC_TempString, Pos( 'MC', varC_TempString ) , 100 );

                   varC_NumMicros   := Copy( varC_TempString, 3, Pos( 'GD', varC_TempString ) - 3 );

                   varC_TempString  := Copy( varC_TempString, Pos( 'GD', varC_TempString ) , 100 );

                   varC_GED         := Copy( varC_TempString, 3, 1 );

                   varC_TempString  := Copy( varC_TempString, Pos( '-', varC_TempString ) + 1 , 100 );

                   //edSenhaFinal.Text:= Copy( varC_TempString, 1, 20 );
                   //===================================================================


             IniFile.Free; //libera a variável da memória

         end;

         // Todo mês trava o sistema para controlar os clientes que nao tem internet
         // uma nova senha deve ser gerada( manualmente ), claro, se estiverem inadimplentes
         // não terão acesso

         if IntToStr( dateMonth( date ) ) <> varC_Ctrl_MES then //varC_TempString then
         begin

            //Verificar se está EM DIAS( com acesso a NET ), se nao BLOQUEAR o SISTEMA

              //===========================================================================================================
              //Rotina que traz do servidor uma leitura da posicao do cliente
              //===========================================================================================================

              if _TEMNET then
              begin

                  try

                    varC_Temp15 := frmMain.GetDadosPHP( 'getStatus', varC_Cnpj_Local, '','' );

                    if ( varC_Cnpj_Local <> '' ) and ( varC_Temp15 = '' ) then
                    begin

                        //SERVIDOR DE CONEXAO MKM
                        if ( _provedor = 'locaweb' ) then
                           _provedor := 'kinghost'
                        else
                        if ( _provedor = 'kinghost' ) then
                           _provedor := 'locaweb';

                        varC_Temp15 := frmMain.GetDadosPHP( 'getStatus', varC_Cnpj_Local, '','' );

                    end;

                    //prob. migracao
                    varC_Temp15    := strRight( Copy( varC_Temp15, 1, Pos( '|', varC_Temp15 ) - 1), 1 );

                    if varC_Temp15 = '' then
                       varC_Temp15 := '4';

                    if varC_Temp15 = '4' then
                       trava  := 'S'
                    else
                       trava  := 'N';

                    if ( trava = 'S' ) or ( varC_Temp15 = '2' ) then //and ( trava = 'N' ) then
                       bloq  := 'S'
                    else
                       bloq  := 'N';

                  except
                        frmMain.mkmMensagem('Não foi possível obter dados do cliente.');
                        raise;

                  end;

              end;

              if ( ( _TEMNET ) and ( trava = 'S' ) ) or ( not _TEMNET ) then
              begin

                  DeleteFile( 'c:\mkmutils\nautilus_controler.ini' );
                  DeleteFile( 'c:\mkmsistemas\nautilus_cfgintegridade.ini' );
                  DeleteFile( 'c:\mkmdados\extras\nautilus_integrity.ini' );

                  varC_TempString := '';

              end;

         end;
         //--------------------------------------------------------------------------------------------------------------------------------

         // Se tem NET, atualiza as informacoes e gera o arq de controle novamente

         if _TEMNET then
         begin

             begin

                 IniFile        := TiniFile.Create   ('c:\mkmSistemas\mkmNautilus.Ini'); //criará o arquivo ini e armazenará no variável IniFile

                 varC_Nome_Sistema   := IniFile.ReadString( 'sistema' , 'nome' , '') ;

                 sufixo := LowerCase( Trim( Copy( varC_Nome_Sistema, 10, 20 ) ) );

                 IniFile.Free; //libera a variável da memória

                try

                     tam_1 := 0;
                     tam_2 := 1;

                     if FileExists( 'c:\mkmutils\nautilus_atualizador.exe' ) then
                     begin


                     end;

                     // comparar VERSOES local e online pra definir NOVA VERSAO
                     _versionLOCAL   := GetFileVersion( 'c:\mkmsistemas\mkmnautilus_commerce_pdv\nautilus_pdv.exe' );

                     //varC_Versao    := GetFileVersion( Application.ExeName ); //'9.7'; //IniFile.ReadString( 'sistema' , 'versao' , '') ;
                     varC_Temp15     := _versionLOCAL;

                     varI_Temp1      := Pos( '.', _versionLOCAL )  ;
                     varC_TempString := strPadZeroL( Copy ( _versionLOCAL, 1, varI_Temp1 -1  ), 2 );
                     _versionLOCAL   := Copy ( _versionLOCAL, varI_Temp1 + 1, 20 );

                     varI_Temp2      := Pos( '.', _versionLOCAL )  ;
                     varC_Temp2      := strPadZeroL( Copy ( _versionLOCAL, 1, varI_Temp2 - 1  ), 2 );
                     _versionLOCAL   := Copy ( _versionLOCAL, varI_Temp2 + 1, 20 );

                     varI_Temp3      := Pos( '.', _versionLOCAL )  ;
                     varC_Temp3      := strPadZeroL( Copy ( _versionLOCAL, 1, varI_Temp3 - 1  ), 2 );
                     _versionLOCAL   := strPadZeroL( Copy ( _versionLOCAL, varI_Temp3 + 1, 20 ), 2 );

                     _versionLOCAL   := varC_TempString + varC_Temp2 + varC_Temp3 + _versionLOCAL;

                     _versionLOCAL1  := varC_TempString;
                     _versionLOCAL2  := varC_Temp2;
                     _versionLOCAL3  := varC_Temp3;
                     _versionLOCAL4  := _versionLOCAL;

                     _dataLOCAL     :=  fileDate( 'c:\mkmSistemas\mkmNautilus_COMMERCE_ERP\versaoonline.ini' );

                     //IdFTP_netrevenda.Get ( '/www/contratos/commerce_erp/versaoonline.ini', 'c:\mkmSistemas\mkmNautilus_COMMERCE_ERP\versaoonline.ini'  ,  true );

                     try
                     IdFTP_conexao.Get ( '/www/contratos/commerce_erp/versaoonline.ini', 'c:\mkmSistemas\mkmNautilus_COMMERCE_ERP\versaoonline.ini'  ,  true );
                     except
                         on e:Exception do
                         begin
                              frmMain.mkmMensagem( 'Falha ao conectar com nosso servidor( controle de versão )' + sLineBreak +
                                                   'Verifique sua conexão com internet.' );
                         end;
                     end;

                     _dataONLINE   := fileDate( 'c:\mkmSistemas\mkmNautilus_COMMERCE_ERP\versaoonline.ini' );// IdFTP_netrevenda.FileDate ( '/www/contratos/commerce_erp/Nautilus_Atualizador.exe' )

                     IniFile        := TiniFile.Create   ('c:\mkmSistemas\mkmNautilus_COMMERCE_ERP\versaoonline.ini');

                     _versionONLINE := IniFile.ReadString( 'sistema' , 'versao' , '') ;

                     varI_Temp1      := Pos( '.', _versionONLINE )  ;
                     varC_TempString := strPadZeroL( Copy ( _versionONLINE, 1, varI_Temp1 -1  ), 2 );
                     _versionONLINE  := Copy ( _versionONLINE, varI_Temp1 + 1, 20 );

                     varI_Temp2      := Pos( '.', _versionONLINE )  ;
                     varC_Temp2      := strPadZeroL( Copy ( _versionONLINE, 1, varI_Temp2 - 1  ), 2 );
                     _versionONLINE  := Copy ( _versionONLINE, varI_Temp2 + 1, 20 );

                     varI_Temp3      := Pos( '.', _versionONLINE )  ;
                     varC_Temp3      := strPadZeroL( Copy ( _versionONLINE, 1, varI_Temp3 - 1  ), 2 );
                     _versionONLINE  := strPadZeroL( Copy ( _versionONLINE, varI_Temp3 + 1, 20 ), 2 );

                     _versionONLINE  := varC_TempString + varC_Temp2 + varC_Temp3  + _versionONLINE;

                     _versionONLINE1 := varC_TempString;
                     _versionONLINE2 := varC_Temp2;
                     _versionONLINE3 := varC_Temp3;
                     _versionONLINE4 := _versionONLINE;

                     IniFile.Free; //libera a variável da memória

                     dm.tag := 0;// 999;

                     //if _versionLOCAL < _versionONLINE then
                     if _dataLOCAL < _dataONLINE then
                     begin

                          //dm.tag := 999;

                     end;

                     // 9.8.2.8
                     // 9.9.4.1

                     if ( _versionLOCAL < _versionONLINE ) then
                     begin

                          dm.tag := 999;

                     end;



                     indice := 0;

                     //BLOQUEIA O CLIENTE
                     //VERIFICA SE CLIENTE ESTÁ BLOQUEADO

                     tam_1 := 0;
                     tam_2 := 1;

                     if FileExists( 'c:\mkmutils\mkm_contratos.ini' ) then
                     begin

                         DeleteFile( 'c:\mkmutils\mkm_contratos.ini' );

                     end;

                     //abre arquivo e procura por cliente/ CNPJ

                     //pega o CNPJ LOCAL do cliente
                      IniFile         := TiniFile.Create   ('c:\mkmdados\extras\nautilus_integrity.ini'); //criará o arquivo ini e armazenará no variável IniFile

                      varC_Cnpj_Local := ( IniFile.ReadString( 'integridade' , 'controle' , '') ) ;

                      IniFile.Free; //libera a variável da memória

                      varC_Boleto_2aVia := '';

                      if varC_Cnpj_Local <> '' then
                      begin

                          //if varC_TempString = '' then
                          begin

                              //varC_Temp15 := frmMain.GetStatusCli( varC_Cnpj_Local );  // 1 Ativo, 2 - Bloqueado, 3 - Inativo, 4 - Travado

                              varC_Temp15 := frmMain.GetDadosPHP( 'getStatus', varC_Cnpj_Local, '','' );

                              if varC_Temp15 = '' then
                              begin

                                  if ( _provedor = 'locaweb' ) then
                                     _provedor := 'kinghost'
                                  else
                                  if ( _provedor = 'kinghost' ) then
                                     _provedor := 'locaweb';

                                  varC_Temp15 := frmMain.GetDadosPHP( 'getStatus', varC_Cnpj_Local, '','' );

                              end;

                              //$status.'|'.$razsoc.'#'.$num_licencas.'%'.$nfe.'^'.$boleto.'}'.$diacob

                              // só atualiza se realmente tiver lido as informacoes corretas
                              if varC_Temp15 <> '' then
                              begin

                                  varC_Temp3  := varC_Temp15;

                                  varC_NumMicros   := retornanumeros( Copy( varC_Temp15,  Pos( '{', varC_Temp15 ) + 1, Pos( '|', varC_Temp15 ) ) );//- 1);

                                  varI_DiaCobranca := StrToIntDef(Trim( Copy( varC_Temp15,  Pos( '}', varC_Temp15 ) + 1, 5 ) ) ,0 );
                                  varC_Boleto      := Copy( varC_Temp15,  Pos( '^', varC_Temp15 ) + 1, 1 );
                                  varC_NFe2        := Copy( varC_Temp15,  Pos( '%', varC_Temp15 ) + 1, 1 );
                                  varC_GED         := 'S';//Copy( varC_Temp15,  Pos( '#', varC_Temp15 ) + 1, 1 );

                                  varC_Temp15    := Copy( varC_Temp15, 1, Pos( '|', varC_Temp15 ) - 1);

                                  if varC_Temp15 = '' then
                                     varC_Temp15 := '1';

                                  if varC_Temp15 = '4' then
                                     varC_Trava  := 'S'
                                  else
                                     varC_Trava  := 'N';

                                  if varC_NFe2 = '' then
                                     varC_NFe2 := 'N';

                                  if varC_GED = '' then
                                     varC_GED := 'N';

                                  if varC_Boleto = '' then
                                     varC_Boleto := 'N';

                                  if varI_DiaCobranca = 0 then
                                     varI_DiaCobranca := 0;

                                  if varC_NumMicros = '' then
                                     varC_NumMicros := '50';

                                  //---------------------------------
                                  //SALVAR OS DADOS DA ULTIMA CONEXAO
                                  //---------------------------------
                                  //
                                  // Esses dados só valem por 1 Mes
                                  //---------------------------------
                                  DeleteFile('c:\mkmutils\nautilus_controler.ini');

                                  varC_Temp15 := frmMain.CriptografarDadosCliente( varC_Temp15,
                                                                                   varC_NFe2,
                                                                                   varC_Boleto,
                                                                                   varC_NumMicros,
                                                                                   IntToStr(dateMonth( date ) ) ,
                                                                                   varC_GED ) + '-' + 'senha' ;

                                 varC_TempString  := varC_Temp15;

                                 //edDia.Text       := Copy( varC_Temp15 , 1 , Pos( '.', varC_TempString ) - 1  );

                                 varC_TempString  := Copy( varC_TempString , Pos( '.', varC_TempString ) + 1 , 100 );

                                 varC_Trava       := Copy( varC_TempString, 1, Pos( 'BQ', varC_TempString ) - 1 );

                                 varC_TempString  := Copy( varC_TempString, Pos( 'BQ', varC_TempString ) , 100 );

                                 varC_Bloq        := Copy( varC_TempString, 1, Pos( 'NF', varC_TempString ) - 1 );

                                 varC_TempString  := Copy( varC_TempString, Pos( 'NF', varC_TempString) , 100 );

                                 varC_NFe2        := Copy( varC_TempString, 1, Pos( 'BL', varC_TempString) - 1 );

                                 varC_TempString  := Copy( varC_TempString, Pos( 'BL', varC_TempString ) , 100 );

                                 varC_Boleto      := Copy( varC_TempString, 1, Pos( 'MC', varC_TempString ) - 1 );

                                 varC_TempString  := Copy( varC_TempString, Pos( 'MC', varC_TempString ) , 100 );

                                 varC_NumMicros   := Copy( varC_TempString, 1, Pos( 'GD', varC_TempString ) - 1 );

                                 varC_TempString  := Copy( varC_TempString, Pos( 'GD', varC_TempString ) , 100 );

                                 varC_GED         := Copy( varC_TempString, 1, Pos( '-', varC_TempString ) - 1  );

                                 varC_TempString  := Copy( varC_TempString, Pos( '-', varC_TempString ) + 1 , 100 );

                                 //edSenhaFinal.Text:= Copy( varC_TempString, 1, 20 );
                                 //===================================================================


                                  IniFile          := TiniFile.Create   ('c:\mkmutils\nautilus_controler.ini'); //criará o arquivo ini e armazenará no variável IniFile

                                  IniFile.WriteString( 'sistema' , 'TR'        , ( ( varC_Trava  ) ) ) ;  //trava
                                  IniFile.WriteString( 'sistema' , 'BQ'        , ( ( varC_Bloq  ) ) ) ;  //bloq
                                  IniFile.WriteString( 'sistema' , 'NF'        , ( ( varC_NFe2   ) ) ) ; //nfe
                                  IniFile.WriteString( 'sistema' , 'BL'        , ( ( varC_Boleto   ) ) ) ; //boleto
                                  IniFile.WriteString( 'sistema' , 'DC'        , IntToStr ( ( varI_DiaCobranca   ) ) ) ;
                                  IniFile.WriteString( 'sistema' , 'MC'        , ( ( varC_NumMicros   ) ) ) ; // micros
                                  IniFile.WriteString( 'sistema' , 'GD'        , ( ( varC_GED   ) ) ) ; // ged
                                  IniFile.WriteString( 'sistema' , 'PJ'        , ( cripta( varC_Cnpj_Local   ) ) ) ;  //cnpj
                                  IniFile.WriteString( 'sistema' , 'CT'        , ( Copy( varC_Temp15 , 1 , Pos( '.', varC_Temp15 ) - 1  ) ) ) ;     //control
                                  //IniFile.WriteString( 'sistema' , 'CT'        , ( Copy( varC_Temp15 , 1 , Pos( '.', varC_TempString ) - 1  ) ) ) ;     //control

                                  IniFile.Free; //libera a variável da memória

                                  varC_Temp15    := Copy( varC_Temp3, 1, Pos( '|', varC_Temp3 ) - 1);

                                   IniFile         := TiniFile.Create   ('c:\mkmutils\nautilus_controler.ini');

                                   // todos os dados estao criptografados....
                                   varC_Trava       := IniFile.ReadString( 'sistema' , 'TR' , 'S') ;
                                   varC_Bloq        := IniFile.ReadString( 'sistema' , 'BQ' , 'S') ;
                                   varC_NFe2        := IniFile.ReadString( 'sistema' , 'NF' , 'N') ;
                                   varC_Boleto      := IniFile.ReadString( 'sistema' , 'BL' , 'N') ;
                                   varI_DiaCobranca := StrToIntDef( IniFile.ReadString( 'sistema' , 'DC' , '1'), 0) ;
                                   varC_NumMicros   := IniFile.ReadString( 'sistema' , 'MC' , '50') ;
                                   varC_GED         := IniFile.ReadString( 'sistema' , 'GD' , 'N') ;
                                   varC_TempString  := IniFile.ReadString( 'sistema' , 'CT' , '112') ;

                                   //varC_Cnpj_Local  := Decripta( IniFile.ReadString( 'sistema' , 'PJ' , varC_Cnpj_Local ) ) ;

                                   varC_Ctrl_DIA    := Copy( varC_TempString, 1, 1 );   // dia para calculo
                                   varC_Ctrl_MES    := Copy( varC_TempString, 2, 10 );  // mes que foi gerada a senha


                                         //===================================================================
                                         // DESCriptografar os dados de liberacao com nova técnica
                                         //===================================================================

                                         varC_Temp2       := frmMain.DescriptografarDadosCliente( varC_Trava, varC_Bloq, varC_NFe2, varC_Boleto, varC_NumMicros, varC_TempString, varC_GED );

                                         varC_TempString  := varC_Temp2;

                                         varC_Ctrl_DIA    := Copy( varC_Temp2 , 1 , 1  );
                                         varC_Ctrl_MES    := Copy( varC_Temp2 , 2 , Pos( '.', varC_TempString ) - 1  );

                                         if ( length( varC_Ctrl_MES ) = 2 ) and ( Pos( '.', varC_TempString ) > 0 ) then
                                            varC_Ctrl_MES := Copy( varC_Ctrl_MES, 1, 1 )
                                         else
                                         if ( length( varC_Ctrl_MES ) = 3 ) and ( Pos( '.', varC_TempString ) > 0 ) then
                                            varC_Ctrl_MES := Copy( varC_Ctrl_MES, 1, 2 );


                                         varC_TempString  := Copy( varC_TempString , Pos( '.', varC_TempString ) + 1 , 100 );

                                         varC_Trava       := Copy( varC_TempString, 3, 1 );

                                         varC_TempString  := Copy( varC_TempString, Pos( 'BQ', varC_TempString ) , 100 );

                                         varC_Bloq        := Copy( varC_TempString, 3, 1 );

                                         varC_TempString  := Copy( varC_TempString, Pos( 'NF', varC_TempString) , 100 );

                                         varC_NFe2        := Copy( varC_TempString, 3, 1 );

                                         varC_TempString  := Copy( varC_TempString, Pos( 'BL', varC_TempString ) , 100 );

                                         varC_Boleto      := Copy( varC_TempString, 3, 1 );

                                         varC_TempString  := Copy( varC_TempString, Pos( 'MC', varC_TempString ) , 100 );

                                         varC_NumMicros   := Copy( varC_TempString, 3, Pos( 'GD', varC_TempString ) - 3 );

                                         varC_TempString  := Copy( varC_TempString, Pos( 'GD', varC_TempString ) , 100 );

                                         varC_GED         := Copy( varC_TempString, 3, 1 );

                                         varC_TempString  := Copy( varC_TempString, Pos( '-', varC_TempString ) + 1 , 100 );

                                         //edSenhaFinal.Text:= Copy( varC_TempString, 1, 20 );
                                         //===================================================================


                                   IniFile.Free; //libera a variável da memória


                              end;

                          end;


                         if ( varC_TempString = '' )  then//( varC_Trava = 'S' ) or ( varC_TempString = '' )  then if ( varC_Trava = 'S' ) then //or ( varC_TempString = '' )  then
                         begin

                              DeleteFile( 'c:\mkmsistemas\nautilus_cfgintegridade.ini' );
                              DeleteFile( 'c:\mkmdados\extras\nautilus_integrity.ini' );

                         end;

                      end
                      else
                      begin

                            DeleteFile( 'c:\mkmsistemas\nautilus_cfgintegridade.ini' );
                            DeleteFile( 'c:\mkmdados\extras\nautilus_integrity.ini' );

                      end;

                finally
                   //desconecta
                   //IdFTP_netrevenda.Disconnect;
                   IdFTP_conexao.Disconnect;

                end;

             end;


         end

         else

         begin

               //abre arquivo e procura por cliente/ CNPJ

               //pega o CNPJ LOCAL do cliente
                IniFile         := TiniFile.Create   ('c:\mkmdados\extras\nautilus_integrity.ini'); //criará o arquivo ini e armazenará no variável IniFile

                varC_Cnpj_Local := ( IniFile.ReadString( 'integridade' , 'controle' , '') ) ;

                IniFile.Free; //libera a variável da memória

                varC_Boleto_2aVia := '';

                if varC_Cnpj_Local <> '' then
                begin

                    if varC_Temp15 = '' then
                       varC_Temp15 := '1';

                    if varC_Temp15 = '4' then
                       varC_Trava  := 'S'
                    else
                       varC_Trava  := 'N';

                    if varC_NFe2 = '' then
                       varC_NFe2 := 'N';

                    if varC_GED = '' then
                       varC_GED := 'N';

                    if varC_Boleto = '' then
                       varC_Boleto := 'N';

                    if varI_DiaCobranca = 0 then
                       varI_DiaCobranca := 0;

                    if varC_NumMicros = '' then
                       varC_NumMicros := '50';

                   if ( varC_Trava = 'S' ) or ( varC_TempString = '' )  then
                   begin

                        //DeleteFile( 'c:\mkmsistemas\nautilus_cfgintegridade.ini' );
                        //DeleteFile( 'c:\mkmdados\extras\nautilus_integrity.ini' );

                   end;


                end
                else
                begin

                      DeleteFile( 'c:\mkmsistemas\nautilus_cfgintegridade.ini' );
                      DeleteFile( 'c:\mkmdados\extras\nautilus_integrity.ini' );

                end;

         end;

     end
     else
     begin

          frmMain.mkmMensagem( 'A Mikromundo não recomenda o uso do Windows 95 ou 98 por suas ' +
                               'conhecidas falhas e má utilização dos recursos. ' + #13 + #10 +
                               'Recomendamos o Windows XP ou superior.' );

     end;

     //===================================================


     //varC_TempString := LeDoRegistro('SystemBiosDate', 'HARDWARE/DESCRIPTION/SYSTEM', '');

     // Só prossegue se este terminal foi configurado

     if ( Not FileExists( 'c:\mkmdados\extras\nautilus_integrity.ini' ) ) or
        ( not FileExists( 'c:\mkmutils\nautilus_controler.ini' ) ) then
     begin

          ShowMessage( 'Inexistência dos arqs. de controle. Desbloqueio necessário' );
          //Halt;

     end;

     zConnection.Connected := false;

     varC_Nome_Sistema := 'Nautilus_COMMERCE_PDV';


     //varC_TempString := LeDoRegistro('SystemBiosDate', 'HARDWARE/DESCRIPTION/SYSTEM', '');

     //if not frmMain.ServerIsRunning( 'localhost', 3050 ) then
     //begin
     //   frmMain.mkmMensagem( 'O Servidor/Cliente FIREBIRD não está ' + #13+#10 +
    //                         'rodando/instalado nesta máquina!' );
    //    halt;
    // end;

     //showmessagE( 'ANTES CONEXAO...passou!' ) ;

     With Zconnection do
     begin

         Connected := False;

         zQryParametros.Close;

         IniFile     := TiniFile.Create   ('c:\mkmSistemas\mkmCfgNautilus_Commerce_ERP.Ini'); //criará o arquivo ini e armazenará no variável IniFile

         Letra           := IniFile.ReadString( 'acesso' , 'drive' , '') ; //Lê o arquivo INI e armazena na var letra
         varC_IP_CONEXAO := IniFile.ReadString( 'acesso' , 'hostname' , '') ; //Lê o arquivo INI e armazena na var letra
         BaseDeDados     := IniFile.ReadString( 'acesso' , 'pasta' , '') ; //Lê o arquivo INI e armazena na var BaseDeDados
         varC_PORTA_SERVIDOR := IniFile.ReadString( 'acesso' , 'porta' , '') ; //Lê o arquivo INI e armazena na var BaseDeDados

         // para bancos REMOTOS, vao variar os dados de login
         varc_temp10 := trim( IniFile.ReadString( 'acesso' , 'bd_pass' , '') );
         if ( varc_temp10 = '' ) or ( varc_temp10 = 'masterkey' ) then //M1kromund0
            varc_temp10 := 'masterkey'
         else
            varc_temp10 := DeCripta( varc_temp10 );

            //192.168.5.200/3051:E:\DB.DAT
         Port        := StrToIntDef( varC_PORTA_SERVIDOR, 3050 );

         if ( varC_IP_CONEXAO = '' ) or ( lowercase(varC_IP_CONEXAO) = 'localhost' ) then
         begin
             HostName    := 'localhost';//'localhost' ;
             varC_IP_CONEXAO := '';//   'localhost' + '/' + varC_PORTA_SERVIDOR;
             letra       := 'C' ;// varC_IP_CONEXAO + ':C';
             Database    := Letra + ':' + BaseDeDados + '\mkmDataFile.FDB' ; //aplica o caminho da base de dados no IBDATABASE
         end
         else
         begin
             HostName    := '';
             varC_IP_CONEXAO := varC_IP_CONEXAO  ;// + '/' + varC_PORTA_SERVIDOR;
             letra       := varC_IP_CONEXAO + ':C';
             Database    := Letra + ':' + BaseDeDados + '\mkmDataFile.FDB' ; //aplica o caminho da base de dados no IBDATABASE
         end;


         //=====================

         ECF_Descr   := StrToInt( IniFile.ReadString( 'nf' , 'ecfdescr' , '') );

         IniFile.Free; //libera a variável da memória

         Try

            Connected   := True;

            //conta adiantamento
            dm.zQrySQL.SQL.Text := ' select * ' +
                                   ' from rdb$relation_fields ' +
                                   ' where RDB$RELATION_FIELDS.rdb$relation_name = ''PARAMETROS'' ' +
                                   ' AND   RDB$RELATION_FIELDS.RDB$FIELD_NAME = ''CONTA_ADIANTAMENTOS'' ' ;

            dm.zQrySQL.open;

            if dm.zQrySQL.IsEmpty then
            begin

                  zQryGeral.Sql.text := ' ALTER TABLE PARAMETROS ' +
                                         ' ADD CONTA_ADIANTAMENTOS INTEGER ';

                  Try
                    zQryGeral.ExecSql;
                  except
                         dm.ZConnection.Rollback;
                         varC_SQL_ERRO := zQryGeral.sql.Text;//Problema na execução do sistema(1336)';
                         //Assert(False, '');
                         raise;
                         exit;

                  end;
                  dm.ZConnection.Commit;

            end;


         Except


               On e:exception do
               begin
                   frmMain.mkmErro( 'Falha na conexão com o Banco de Dados: ' + Database + sLineBreak + sLineBreak +
                                        ' 1. Se este micro for o servidor do sistema, pode ser que o FIREBIRD tenha sido parado ou desinstalado. ' + #13+#10 + #13+#10 +
                                        ' 2. Se este micro for estação do sistema, além da causa (1), pode ser que o IP do servidor não está configurado no arquivo "C:\mkmSistemas\mkmCfgNautilus_COMMERCE_ERP.Ini", na linha "HOSTNAME = ''IP do Servidor'' "' + #13+#10 + #13+#10 +
                                        ' 3. Se este micro for estação do sistema, além das causas anteriores, pode ser que a PORTA ' + varC_PORTA_SERVIDOR + ' não tenha sido aberta no FIREWALL do Servidor' + #13+#10 + #13+#10 +
                                        ' 4. Verifique ( ou solicite um técnico ) se os IPs da sua rede estão FIXOS, IPs dinâmicos podem trazer instabilidade ao sistema' + sLineBreak + sLineBreak +
                                        ' 5. Ainda há o problema com incompatibilidade entre versões do FIREBIRD e INTERBASE, comunique-se com a Mikromundo( nautilussuporte@mikromundo.com )' + sLineBreak + sLineBreak +
                                        'Erro: ' + E.Message );
                   Halt;
                   //Exit;
               end;
         End;

         //showmessagE( 'CONECTOU...passou!' ) ;

         //PEGA NOME DA ESTACAO
         IniFile     := TiniFile.Create   ('c:\mkmSistemas\mkmCfgEstacao_erp.Ini'); //criará o arquivo ini e armazenará no variável IniFile

         varC_Maquina:= Decripta( IniFile.ReadString( 'estacao' , 'nome'  , '') );

         IniFile.Free; //libera a variável da memória


         Try
            varI_Temp1 := StrToIntDef( varC_NumMicros, 15 );
         except

             if ( varC_NumMicros <> '' ) and ( varC_NumMicros <> '0' ) then
                varI_Temp1 := StrToInt( varC_NumMicros )
             else
                varI_Temp1 := 20 ;

         end;

         //GRAVA NUMERO DE LICENCAS PADRÃO
         IniFile     := TiniFile.Create   ('c:\mkmSistemas\mkmCfgNautilus_Commerce_Erp.Ini'); //criará o arquivo ini e armazenará no variável IniFile

         IniFile.WriteString( 'sistema' , 'licencas'  , cripta( IntToStr(varI_Temp1) ) ) ;

         IniFile.Free; // libera a variável da memória


        //=========== CONECTOU - [ INICIO ] ==========//
        zQryGeral.SQL.Text := ' SELECT ATT.MON$REMOTE_PROCESS as PG, ATT.MON$ATTACHMENT_NAME as BD, ATT.MON$REMOTE_ADDRESS as IP, STMT.MON$TIMESTAMP as HORA_CONEXAO , ATT.MON$ATTACHMENT_ID as ID, CURRENT_DATE as DT '+

                              ' FROM MON$ATTACHMENTS ATT ' +

                              ' JOIN MON$STATEMENTS STMT ' +
                              ' ON ATT.MON$ATTACHMENT_ID = STMT.MON$ATTACHMENT_ID ' +

                              ' WHERE STMT.MON$STATE = 1 ' +
                              ' and ATT.MON$ATTACHMENT_ID = CURRENT_CONNECTION ' +
                              ' and ( ( position( ''NAUTILUS.EXE'', upper( ATT.MON$REMOTE_PROCESS ) ) > 0  ) ' +
                              ' OR    ( position( ''NAUTILUS_PDV.EXE'', upper( ATT.MON$REMOTE_PROCESS ) ) > 0  ) ) ' ;
        zQryGeral.open;

        _mc             := frmMain.GetMacAddress;

        // Apaga as conexoes do IP para o BD listados acima
           zQrySQL.SQL.Text   := ' Delete from TB_CONEXOES ' +
                                 ' Where ( BD = ' + QuotedStr( zQryGeral.FieldByName('BD').AsString ) +  //' And     IP = ' + QuotedStr( zQryGeral.FieldByName('IP').AsString ) + ' ) ' +
                                 ' And     MC = ' + QuotedStr( _mc ) + ' ) ' +
                                 ' Or    DT <> ' + QuotedStr( FormatDateTime( 'dd.mm.yyyy', Date ) ) ;

                                 //GetMacAddress
           Try
             zQrySQL.ExecSql;
           except
                 raise;
           end;
           dm.ZConnection.Commit;

           varC_IP_CONEXAO := zQryGeral.FieldByName('IP').AsString;
           varC_BD_CONEXAO := zQryGeral.FieldByName('BD').AsString;


              zQrySQL.SQL.Text   := ' Insert Into TB_CONEXOES (  ID ,  IP ,  PG ,  BD ,  DT, MC ) ' +
                                    '             Values      ( :ID , :IP , :PG , :BD , :DT, :MC ) ';

              zQrySQL.ParamByName('ID').AsInteger  := zQryGeral.FieldByName('ID').AsInteger ;
              zQrySQL.ParamByName('IP').AsString   := zQryGeral.FieldByName('IP').AsString ;
              zQrySQL.ParamByName('PG').AsString   := zQryGeral.FieldByName('PG').AsString ;
              zQrySQL.ParamByName('BD').AsString   := zQryGeral.FieldByName('BD').AsString ;
              zQrySQL.ParamByName('DT').AsDateTime := zQryGeral.FieldByName('DT').AsDateTime ;//date ;
              zQrySQL.ParamByName('MC').AsString   := _mc;

              Try
                zQrySQL.ExecSql;
              except
                    raise;
              end;
              dm.ZConnection.Commit;


              //GRAVA AS CONEXOES ATIVAS
              DeleteFile( 'c:\mkmDados\Extras\conexoes_ativas.ini' );
              IniFile     := TiniFile.Create   ( 'c:\mkmDados\Extras\conexoes_ativas.ini' ); //criará o arquivo ini e armazenará no variável IniFile

              While not zQryGeral.eof do
              begin

                   //frmMain.mkmMensagem( 'ID = ' + zQryGeral.FieldByName('ID').AsString + #13#10 +
                   //                     'IP = ' + zQryGeral.FieldByName('IP').AsString + #13#10 +
                   //                     'PG = ' + zQryGeral.FieldByName('PROGRAMA').AsString + #13#10 +
                   //                     'BD = ' + zQryGeral.FieldByName('BD').AsString  );


                   IniFile.WriteString( zQryGeral.FieldByName('ID').AsString , 'MC'  , _mc  ) ;
                   IniFile.WriteString( zQryGeral.FieldByName('ID').AsString , 'IP'  , zQryGeral.FieldByName('IP').AsString  ) ;
                   IniFile.WriteString( zQryGeral.FieldByName('ID').AsString , 'PG'  , zQryGeral.FieldByName('PG').AsString  ) ;
                   IniFile.WriteString( zQryGeral.FieldByName('ID').AsString , 'BD'  , zQryGeral.FieldByName('BD').AsString  ) ;

                   zQryGeral.next;

              end;

              IniFile.Free; // libera a variável da memória

              zQryGeral.First;

              zQrySQL.SQL.Text   := ' Select * from TB_CONEXOES ' +
                                    ' Where ID = ' + zQryGeral.FieldByName('ID').AsString;
              zQrySQL.open;

              //GRAVA AS CONEXOES GRAVADAS NA TABELA TB_CONEXOES
              DeleteFile( 'c:\mkmDados\Extras\conexoes_gravadas.ini' );
              IniFile     := TiniFile.Create   ( 'c:\mkmDados\Extras\conexoes_gravadas.ini' ); //criará o arquivo ini e armazenará no variável IniFile

              While not zQrySQL.eof do
              begin

                   //frmMain.mkmMensagem( 'ID = ' + zQryGeral.FieldByName('ID').AsString + #13#10 +
                   //                     'IP = ' + zQryGeral.FieldByName('IP').AsString + #13#10 +
                   //                     'PG = ' + zQryGeral.FieldByName('PROGRAMA').AsString + #13#10 +
                   //                     'BD = ' + zQryGeral.FieldByName('BD').AsString  );

                   IniFile.WriteString( zQrySQL.FieldByName('ID').AsString , 'MC'  , zQrySQL.FieldByName('MC').AsString  ) ;
                   IniFile.WriteString( zQrySQL.FieldByName('ID').AsString , 'IP'  , zQrySQL.FieldByName('IP').AsString  ) ;
                   IniFile.WriteString( zQrySQL.FieldByName('ID').AsString , 'PG'  , zQrySQL.FieldByName('PG').AsString  ) ;
                   IniFile.WriteString( zQrySQL.FieldByName('ID').AsString , 'BD'  , zQrySQL.FieldByName('BD').AsString  ) ;

                   zQrySQL.next;

              end;

              IniFile.Free; // libera a variável da memória

              zQrySQL.first;

              //=========== CONECTOU - [ FINAL ] ==========//

             if ( varC_NumMicros <> '' ) and ( varC_NumMicros <> '0' ) then
             begin


                 zQryGeral.SQL.Text := ' Select count(*) as Conexoes from tb_conexoes ' ;
                 zQryGeral.Open;

                 _num_mkmdatafile   := zQryGeral.FieldByName('Conexoes').AsInteger;

                 if ( _num_mkmdatafile ) > varI_Temp1 then
                 begin

                      frmMain.mkmMensagem( 'Número máximo de Licenças ultrapassado( ' + IntToStr( ( _num_mkmdatafile ) ) + '/' + IntToStr( varI_Temp1 ) + '. Contacte a MIKROMUNDO( 85 3023.5931 / financeiro@mikromundo.com.br )' );
                      zQryGeral.Close;

                      //=========== CONECTOU - [ INICIO ] ==========//

                      // Apaga as conexoes do IP para o BD listados acima
                         dm.zQrySQL.SQL.Text   := ' Delete from TB_CONEXOES ' +
                                                  ' Where ( BD = ' + QuotedStr( varC_BD_CONEXAO ) +  //' And     IP = ' + QuotedStr( varC_IP_CONEXAO ) + ' ) ' +
                                                  ' And     MC = ' + QuotedStr( _mc ) + ' ) ' +
                                                  ' Or    DT <> ' + QuotedStr( FormatDateTime( 'dd.mm.yyyy', Date ) ) ;
                         Try
                           dm.zQrySQL.ExecSql;
                         except
                               raise;
                         end;
                         dm.ZConnection.Commit;

                      Connected   := false;
                      Halt;


                 end;

             end;

     end;
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin

     Zconnection.Connected := False;

end;

end.


