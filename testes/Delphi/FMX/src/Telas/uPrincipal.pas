unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.DateUtils, System.Rtti,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FMX.Objects, FMX.ListBox, FMX.TabControl, FMX.Grid.Style,
  FMX.Grid,
  REST.Types,

  uConsts, uResultado, uRESTDAO, uRDWRESTDAO,

  uRESTDWAbout, uRESTDWBasicClass, uRESTDWConsts

    ;

type
  TfPrincipal = class(TForm)
    Layout1: TLayout;
    Image1: TImage;
    lVersao: TLabel;
    TabControl1: TTabControl;
    tiSimples: TTabItem;
    tiAvancado: TTabItem;
    FlowLayout1: TFlowLayout;
    eServidor: TEdit;
    Label1: TLabel;
    ePorta: TEdit;
    Label2: TLabel;
    eEndpoint: TEdit;
    Label3: TLabel;
    FlowLayout2: TFlowLayout;
    ComboBox1: TComboBox;
    Label4: TLabel;
    eUsuario: TEdit;
    Label5: TLabel;
    eSenha: TEdit;
    Label6: TLabel;
    FlowLayout3: TFlowLayout;
    Button1: TButton;
    Button2: TButton;
    Layout2: TLayout;
    StringGrid1: TStringGrid;
    FlowLayout5: TFlowLayout;
    cbMetodoAv: TComboBox;
    Label10: TLabel;
    eUsuarioAv: TEdit;
    Label11: TLabel;
    eSenhaAv: TEdit;
    Label12: TLabel;
    FlowLayout4: TFlowLayout;
    eServidorAv: TEdit;
    Label7: TLabel;
    ePortaAv: TEdit;
    Label8: TLabel;
    eEndpointAv: TEdit;
    Label9: TLabel;
    bAdicionar: TButton;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    FlowLayout6: TFlowLayout;
    Button5: TButton;
    Layout3: TLayout;
    Layout4: TLayout;
    gbVerbos: TGroupBox;
    cbGET: TCheckBox;
    cbPOST: TCheckBox;
    cbPUT: TCheckBox;
    cbPATCH: TCheckBox;
    cbDELETE: TCheckBox;
    eRequisicoes: TEdit;
    Label13: TLabel;
    gbClientes: TGroupBox;
    cbRESTNativo: TCheckBox;
    cbRDWIdClientREST: TCheckBox;
    cbRDWIdClientRESTBin: TCheckBox;
    bRemover: TButton;
    GroupBox1: TGroupBox;
    rbSequencial: TRadioButton;
    rbParalelo: TRadioButton;
    procedure IniciarClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Rectangle1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Rectangle2Click(Sender: TObject);
    procedure bAdicionarClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure bRemoverClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    REST: TRESTDAO;
    RDWREST, RDWBinary: TRDWRESTDAO;
    inicio, fim: Double;
    pass, fail: integer;
    procedure IniciaTestes;
    procedure EncerraTeste;
    procedure TesteRESTRequest(aClient: TRESTDAO);
    procedure TesteRDWRequest(aClient: TRDWRESTDAO);
    procedure TesteEndpointREST(aEndpoint: string; metodo: TTestRequestMethod;
      count: integer; aClient: TRESTDAO);
    procedure TesteEndpointRDW(aEndpoint: string; metodo: TTestRequestMethod;
      count: integer; aClient: TRDWRESTDAO);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.fmx}

procedure TfPrincipal.bAdicionarClick(Sender: TObject);
begin
  with StringGrid1 do
  begin
    RowCount := RowCount + 1;
    Cells[0, pred(RowCount)] := eServidorAv.Text;
    Cells[1, pred(RowCount)] := ePortaAv.Text;
    Cells[2, pred(RowCount)] := eEndpointAv.Text;
    if cbMetodoAv.ItemIndex <> -1 then
    begin
      Cells[3, pred(RowCount)] := cbMetodoAv.Selected.Text;
      Cells[4, pred(RowCount)] := eUsuarioAv.Text;
      Cells[5, pred(RowCount)] := eSenhaAv.Text;
    end;
  end;
end;

procedure TfPrincipal.bRemoverClick(Sender: TObject);
begin
  if StringGrid1.RowCount > 0 then
    StringGrid1.RowCount := StringGrid1.RowCount - 1;
end;

procedure TfPrincipal.Button2Click(Sender: TObject);
begin
  if not Assigned(FResultado) then
    Application.CreateForm(TFResultado, FResultado);
  FResultado.Show;
  inicio := now;

  FResultado.LogMessage('Teste de 1000 requests sequenciais iniciados às ' +
    TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  RDWREST := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text, false);
  RDWBinary := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text, true);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
  begin
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWREST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWBinary.SetBasicAuth(eUsuario.Text, eSenha.Text);
  end;

  TThread.CreateAnonymousThread(
    procedure
    begin
      pass := 0;
      fail := 0;
      FResultado.LogMessage('Iniciando testes com REST Nativos...');
      TesteEndpointREST(eEndpoint.Text, rtmGET, 1000, REST);
      FResultado.LogMessage('Iniciando testes com RDW ClientREST...');
      TesteEndpointRDW(eEndpoint.Text, rtmGET, 1000, RDWREST);
      FResultado.LogMessage('Iniciando testes binários com RDW ClientREST...');
      TesteEndpointRDW(eEndpoint.Text, rtmGET, 1000, RDWBinary);

      EncerraTeste;

      REST.Free;
      RDWREST.Free;
      RDWBinary.Free;
    end).Start;
end;

procedure TfPrincipal.Button5Click(Sender: TObject);
begin
  if not Assigned(FResultado) then
    Application.CreateForm(TFResultado, FResultado);
  FResultado.Show;
  TThread.CreateAnonymousThread(IniciaTestes).Start;
end;

procedure TfPrincipal.EncerraTeste;
begin
  fim := now;
  FResultado.LogMessage('Testes finalizados após ' +
    FormatDateTime('hh:nn:ss:zzz', (fim - inicio)) + ' (hor:min:seg:mil)');
  FResultado.LogMessage(Format(' - Total: %d, Sucesso: %d, Falha: %d',
    [pass + fail, pass, fail]));
  FResultado.LogMessage('=======================================');
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
begin
  lVersao.Text := Format('Versão componentes: %s', [RESTDWVERSAO]);
  StringGrid1.RowCount := 0;
end;

procedure TfPrincipal.FormDestroy(Sender: TObject);
begin
  try
    if Assigned(FResultado) then // vai dar erro de Pointer Exception aqui
      FResultado.Free; // Porque? Porque o assigned não funciona
  except // basta ignorar o erro ou rodar em modo release
  end;
end;

procedure TfPrincipal.IniciarClick(Sender: TObject);
begin
  if not Assigned(FResultado) then
    Application.CreateForm(TFResultado, FResultado);
  FResultado.Show;
  inicio := now;

  FResultado.LogMessage('Testes sequenciais iniciados às ' + TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  RDWREST := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text, false);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
  begin
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWREST.SetBasicAuth(eUsuario.Text, eSenha.Text);
  end;
  TThread.CreateAnonymousThread(
    procedure
    begin
      TesteRESTRequest(REST);
      TesteRDWRequest(RDWREST);

      EncerraTeste;
    end).Start;
end;

procedure TfPrincipal.IniciaTestes;
var
  I: integer;
  RESTClient: TRESTDAO;
  RDWRESTClient, RDWRESTClientBin: TRDWRESTDAO;
begin
  inicio := now;
  FResultado.LogMessage('Testes sequenciais iniciados às ' + TimeToStr(inicio));
  FResultado.LogMessage('-------------------------------------');
  for I := 0 to pred(StringGrid1.RowCount) do
  begin
    if cbRESTNativo.IsChecked then
    begin
      RESTClient := TRESTDAO.Create(StringGrid1.Cells[0, I],
        StringGrid1.Cells[1, I]);
      if (cbMetodoAv.ItemIndex = 1) and
        ((eUsuarioAv.Text <> EmptyStr) and (eSenhaAv.Text <> EmptyStr)) then
        RESTClient.SetBasicAuth(eUsuarioAv.Text, eSenhaAv.Text);
    end;

    if cbRDWIdClientREST.IsChecked then
    begin
      RDWRESTClient := TRDWRESTDAO.Create(StringGrid1.Cells[0, I],
        StringGrid1.Cells[1, I], false);
      if (cbMetodoAv.ItemIndex = 1) and
        ((eUsuarioAv.Text <> EmptyStr) and (eSenhaAv.Text <> EmptyStr)) then
        RDWRESTClient.SetBasicAuth(eUsuarioAv.Text, eSenhaAv.Text);
    end;

    if cbRDWIdClientRESTBin.IsChecked then
    begin
      RDWRESTClientBin := TRDWRESTDAO.Create(StringGrid1.Cells[0, I],
        StringGrid1.Cells[1, I], true);
      if (cbMetodoAv.ItemIndex = 1) and
        ((eUsuarioAv.Text <> EmptyStr) and (eSenhaAv.Text <> EmptyStr)) then
        RDWRESTClientBin.SetBasicAuth(eUsuarioAv.Text, eSenhaAv.Text);
    end;

    if cbGET.IsChecked then
    begin
      if cbRESTNativo.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com REST Nativos...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo GET...');
        TesteEndpointREST(StringGrid1.Cells[2, I], rtmGET,
          eRequisicoes.Text.ToInteger, RESTClient);
      end;

      if cbRDWIdClientREST.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo GET...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmGET,
          eRequisicoes.Text.ToInteger, RDWRESTClient);
      end;

      if cbRDWIdClientRESTBin.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST Binário...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo GET...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmGET,
          eRequisicoes.Text.ToInteger, RDWRESTClientBin);
      end;
    end;

    if cbPOST.IsChecked then
    begin
      if cbRESTNativo.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com REST Nativos...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo POST...');
        TesteEndpointREST(StringGrid1.Cells[2, I], rtmPOST,
          eRequisicoes.Text.ToInteger, RESTClient);
      end;

      if cbRDWIdClientREST.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo POST...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmPOST,
          eRequisicoes.Text.ToInteger, RDWRESTClient);
      end;

      if cbRDWIdClientRESTBin.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST Binário...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo POST...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmPOST,
          eRequisicoes.Text.ToInteger, RDWRESTClientBin);
      end;
    end;

    if cbPUT.IsChecked then
    begin
      if cbRESTNativo.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com REST Nativos...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo PUT...');
        TesteEndpointREST(StringGrid1.Cells[2, I], rtmPUT,
          eRequisicoes.Text.ToInteger, RESTClient);
      end;

      if cbRDWIdClientREST.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo PUT...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmPUT,
          eRequisicoes.Text.ToInteger, RDWRESTClient);
      end;

      if cbRDWIdClientRESTBin.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST Binário...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo PUT...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmPUT,
          eRequisicoes.Text.ToInteger, RDWRESTClientBin);
      end;
    end;

    if cbPATCH.IsChecked then
    begin
      if cbRESTNativo.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com REST Nativos...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo PATCH...');
        TesteEndpointREST(StringGrid1.Cells[2, I], rtmPATCH,
          eRequisicoes.Text.ToInteger, RESTClient);
      end;

      if cbRDWIdClientREST.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo PATCH...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmPATCH,
          eRequisicoes.Text.ToInteger, RDWRESTClient);
      end;

      if cbRDWIdClientRESTBin.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST Binário...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo PATCH...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmPATCH,
          eRequisicoes.Text.ToInteger, RDWRESTClientBin);
      end;
    end;

    if cbDELETE.IsChecked then
    begin
      if cbRESTNativo.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com REST Nativos...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo DELETE...');
        TesteEndpointREST(StringGrid1.Cells[2, I], rtmDELETE,
          eRequisicoes.Text.ToInteger, RESTClient);
      end;

      if cbRDWIdClientREST.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo DELETE...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmDELETE,
          eRequisicoes.Text.ToInteger, RDWRESTClient);
      end;

      if cbRDWIdClientRESTBin.IsChecked then
      begin
        FResultado.LogMessage
          (Format('Testando servidor %s:%s com RESTDW ClientREST Binário...',
          [StringGrid1.Cells[0, I], StringGrid1.Cells[1, I]]));
        FResultado.LogMessage('Testando verbo DELETE...');
        TesteEndpointRDW(StringGrid1.Cells[2, I], rtmDELETE,
          eRequisicoes.Text.ToInteger, RDWRESTClientBin);
      end;
    end;

    if Assigned(RESTClient) then
      RESTClient.Free;
    if Assigned(RDWRESTClient) then
      RDWRESTClient.Free;
    if Assigned(RDWRESTClientBin) then
      RDWRESTClientBin.Free;
  end;
  EncerraTeste;
end;

procedure TfPrincipal.Rectangle1MouseDown(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Single);
begin
  StartWindowDrag;
end;

procedure TfPrincipal.Rectangle2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TfPrincipal.TesteEndpointREST(aEndpoint: string;
metodo: TTestRequestMethod; count: integer; aClient: TRESTDAO);
var
  I: integer;
  ini, fim: Double;
  erro: string;
begin
  ini := now;
  FResultado.LogMessage('Testando ' + count.ToString + ' requisições...');
  for I := 0 to count do
    if not aClient.TesteEndpoint(aEndpoint, metodo, erro) then
    begin
      FResultado.LogMessage(Format('%s após %d requisições', [erro, I]));
      inc(fail);
      break;
    end;
  fim := now;
  inc(pass);

  FResultado.LogMessage(' - finalizado após ' + FormatDateTime('nn:ss:zzz',
    (fim - ini)) + ' (min:seg:mil)');
  FResultado.LogMessage('=======================================');
end;

procedure TfPrincipal.TesteEndpointRDW(aEndpoint: string;
metodo: TTestRequestMethod; count: integer; aClient: TRDWRESTDAO);
var
  I: integer;
  ini, fim: Double;
  erro: string;
begin
  ini := now;
  FResultado.LogMessage('Testando ' + count.ToString + ' requisições...');
  for I := 0 to count do
    if not aClient.TesteEndpoint(aEndpoint, metodo, erro) then
    begin
      FResultado.LogMessage(Format('%s após %d requisições', [erro, I]));
      inc(fail);
      break;
    end;

  fim := now;
  inc(pass);
  FResultado.LogMessage(' - finalizado após ' + FormatDateTime('nn:ss:zzz',
    (fim - ini)) + ' (min:seg:mil)');
  FResultado.LogMessage('=======================================');
end;

procedure TfPrincipal.TesteRDWRequest(aClient: TRDWRESTDAO);
var
  erro: string;
begin
  pass := 0;
  fail := 0;
  FResultado.LogMessage
    ('Realizando testes de Requisição com RDW RESTClient...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    FResultado.LogMessage('Erro: Configurações de servidor ou porta inválidas');
    exit;
  end
  else
  begin
    if not aClient.TesteEndpoint(eEndpoint.Text, rtmGET, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método GET disponível');
      TesteEndpointRDW(eEndpoint.Text, rtmGET, 100, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmGET, 1000, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmGET, 10000, aClient);

      FResultado.LogMessage('Teste GET concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmPOST, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método POST disponível');
      TesteEndpointRDW(eEndpoint.Text, rtmPOST, 100, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmPOST, 1000, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmPOST, 10000, aClient);

      FResultado.LogMessage('Teste POST concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmPUT, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método PUT disponível');
      TesteEndpointRDW(eEndpoint.Text, rtmPUT, 100, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmPUT, 1000, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmPUT, 10000, aClient);

      FResultado.LogMessage('Teste PUT concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmPATCH, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método PATCH disponível');
      TesteEndpointRDW(eEndpoint.Text, rtmPATCH, 100, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmPATCH, 1000, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmPATCH, 10000, aClient);

      FResultado.LogMessage('Teste PATCH concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmDELETE, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método DELETE disponível');
      TesteEndpointRDW(eEndpoint.Text, rtmDELETE, 100, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmDELETE, 1000, aClient);
      TesteEndpointRDW(eEndpoint.Text, rtmDELETE, 10000, aClient);

      FResultado.LogMessage('Teste DELETE concluído');
    end;
  end;
  FResultado.LogMessage('Fim de testes de Requisição com RDW RESTClient...');
  FResultado.LogMessage(Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

procedure TfPrincipal.TesteRESTRequest(aClient: TRESTDAO);
var
  erro: string;
begin
  pass := 0;
  fail := 0;
  FResultado.LogMessage('Realizando testes de Requisição com REST nativos...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    FResultado.LogMessage('Erro: Configurações de servidor ou porta inválidas');
    exit;
  end
  else
  begin
    if not aClient.TesteEndpoint(eEndpoint.Text, rtmGET, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método GET disponível');
      TesteEndpointREST(eEndpoint.Text, rtmGET, 100, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmGET, 1000, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmGET, 10000, aClient);

      FResultado.LogMessage('Teste GET concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmPOST, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método POST disponível');
      TesteEndpointREST(eEndpoint.Text, rtmPOST, 100, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmPOST, 1000, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmPOST, 10000, aClient);

      FResultado.LogMessage('Teste POST concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmPUT, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método PUT disponível');
      TesteEndpointREST(eEndpoint.Text, rtmPUT, 100, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmPUT, 1000, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmPUT, 10000, aClient);

      FResultado.LogMessage('Teste PUT concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmPATCH, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método PATCH disponível');
      TesteEndpointREST(eEndpoint.Text, rtmPATCH, 100, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmPATCH, 1000, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmPATCH, 10000, aClient);

      FResultado.LogMessage('Teste PATCH concluído');
    end;

    if not aClient.TesteEndpoint(eEndpoint.Text, rtmDELETE, erro) then
    begin
      FResultado.LogMessage(Format('Teste %s', [erro]));
      inc(fail);
    end
    else
    begin
      FResultado.LogMessage('Método DELETE disponível');
      TesteEndpointREST(eEndpoint.Text, rtmDELETE, 100, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmDELETE, 1000, aClient);
      TesteEndpointREST(eEndpoint.Text, rtmDELETE, 10000, aClient);

      FResultado.LogMessage('Teste DELETE concluído');
    end;
  end;
  FResultado.LogMessage('Fim de testes de Requisição com REST nativos...');
  FResultado.LogMessage(Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

end.
