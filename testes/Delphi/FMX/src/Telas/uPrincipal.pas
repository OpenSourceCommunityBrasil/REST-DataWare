unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.DateUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FMX.Objects, FMX.ListBox,
  REST.Types,

  uRESTDWAbout, uRESTDWBasicClass, uRESTDWConsts,

  uRESTDAO, uRDWRESTDAO, uRESTDWServerEvents, uRESTDWBasic, uRESTDWIdBase;

type
  TfPrincipal = class(TForm)
    FlowLayout1: TFlowLayout;
    eServidor: TEdit;
    Label1: TLabel;
    ePorta: TEdit;
    Label2: TLabel;
    eEndpoint: TEdit;
    Label3: TLabel;
    Memo1: TMemo;
    Layout1: TLayout;
    Image1: TImage;
    FlowLayout2: TFlowLayout;
    eUsuario: TEdit;
    Label4: TLabel;
    eSenha: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    ComboBox1: TComboBox;
    Layout2: TLayout;
    Button2: TButton;
    FlowLayout3: TFlowLayout;
    lVersao: TLabel;
    Button3: TButton;
    RESTDWIdClientPooler1: TRESTDWIdClientPooler;
    RESTDWClientEvents1: TRESTDWClientEvents;
    procedure IniciarClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    REST: TRESTDAO;
    RDWREST: TRDWRESTDAO;
    inicio, fim: Double;
    pass, fail: integer;
    procedure TesteAB(aMemo: TMemo);
    procedure TesteRESTRequest(aMemo: TMemo);
    procedure TesteRDWRequest(aMemo: TMemo);
    procedure LogMessage(aMemo: TMemo; aMessage: string);
    procedure TesteEndpointREST(metodo: string; count: integer);
    procedure TesteEndpointRDW(metodo: string; count: integer);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.fmx}

procedure TfPrincipal.Button2Click(Sender: TObject);
begin
  inicio := now;
  Memo1.Lines.Clear;
  LogMessage(Memo1, 'Teste de 1000 requests iniciados às ' + TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  RDWREST := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
  begin
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWREST.SetBasicAuth(eUsuario.Text, eSenha.Text);
  end;
  TThread.CreateAnonymousThread(
    procedure
    begin
      pass := 0;
      fail := 0;
      LogMessage(Memo1, 'Iniciando testes com REST Nativos...');
      TesteEndpointREST('GET', 1000);
      LogMessage(Memo1, 'Iniciando testes com RDW ClientREST....');
      TesteEndpointRDW('GET', 1000);

      fim := now;
      LogMessage(Memo1, '=======================================');
      LogMessage(Memo1, 'Testes finalizados após ' +
        FormatDateTime('hh:nn:ss:zzz', (fim - inicio)) + ' (hor:min:seg:mil)');
      LogMessage(Memo1, Format(' - Total: %d, Sucesso: %d, Falha: %d',
        [pass + fail, pass, fail]));
      REST.Free;
      RDWREST.Free;
    end).Start;
end;

procedure TfPrincipal.Button3Click(Sender: TObject);
begin
  Memo1.Lines.SaveToFile(ExtractFileDir(ParamStr(0)) + '\logRDWTestTool.txt');
  LogMessage(Memo1, 'Log salvo no arquivo: ' + ExtractFileDir(ParamStr(0)) +
    '\logRDWTestTool.txt');
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
var
  I: integer;
begin
  lVersao.Text := Format('Versão componentes: %s', [RESTDWVERSAO]);
  for I := 0 to pred(ComponentCount) do
    if Components[I] is TLabel then
    begin
      (Components[I] as TLabel).StyledSettings := [];
      (Components[I] as TLabel).TextSettings.FontColor := $FFC7C7C7;
    end;
end;

procedure TfPrincipal.IniciarClick(Sender: TObject);
begin
  inicio := now;
  Memo1.Lines.Clear;
  LogMessage(Memo1, 'Testes iniciados às ' + TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  RDWREST := TRDWRESTDAO.Create(eServidor.Text, ePorta.Text);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
  begin
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
    RDWREST.SetBasicAuth(eUsuario.Text, eSenha.Text);
  end;
  TThread.CreateAnonymousThread(
    procedure
    begin
      // TesteAB(Memo1);
      TesteRESTRequest(Memo1);
      TesteRDWRequest(Memo1);

      fim := now;
      LogMessage(Memo1, '=======================================');
      LogMessage(Memo1, 'Testes finalizados após ' +
        FormatDateTime('hh:nn:ss:zzz', (fim - inicio)) + ' (hor:min:seg:mil)');
    end).Start;
end;

procedure TfPrincipal.LogMessage(aMemo: TMemo; aMessage: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      aMemo.Lines.Add(aMessage);
      aMemo.GoToTextEnd;
    end);
end;

procedure TfPrincipal.TesteAB(aMemo: TMemo);
begin
  LogMessage(aMemo, 'Realizando testes A/B...');
end;

procedure TfPrincipal.TesteEndpointREST(metodo: string; count: integer);
var
  I: integer;
  ini, fim: Double;
begin
  ini := now;
  if pos('GET', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not REST.TesteEndpointGET(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método GET falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('POST', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not REST.TesteEndpointPOST(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método POST falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('PUT', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not REST.TesteEndpointPUT(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método PUT falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('PATCH', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not REST.TesteEndpointPATCH(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método PATCH falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('DELETE', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not REST.TesteEndpointDELETE(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método DELETE falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;
end;

procedure TfPrincipal.TesteEndpointRDW(metodo: string; count: integer);
var
  I: integer;
  ini, fim: Double;
begin
  ini := now;
  if pos('GET', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not RDWREST.TesteEndpointGET(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método GET falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('POST', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not RDWREST.TesteEndpointPOST(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método POST falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('PUT', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not RDWREST.TesteEndpointPUT(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método PUT falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('PATCH', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not RDWREST.TesteEndpointPATCH(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método PATCH falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;

  ini := now;
  if pos('DELETE', metodo) > 0 then
  begin
    LogMessage(Memo1, 'Testando ' + count.ToString + ' requisições...');
    for I := 0 to count do
      if not RDWREST.TesteEndpointDELETE(eEndpoint.Text) then
      begin
        LogMessage(Memo1, 'Método DELETE falhou após ' + I.ToString +
          ' requisições');
        inc(fail);
        break;
      end;
    fim := now;
    inc(pass);
    LogMessage(Memo1, ' - finalizado após ' + FormatDateTime('nn:ss:zzz',
      (fim - ini)) + ' (min:seg:mil)');
  end;
end;

procedure TfPrincipal.TesteRDWRequest(aMemo: TMemo);
var
  I: integer;
  thread: TThread;
begin
  pass := 0;
  fail := 0;
  LogMessage(aMemo, 'Realizando testes de Requisição com RDW RESTClient...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    LogMessage(aMemo, 'Erro: Configurações de servidor ou porta inválidas');
    exit;
  end
  else
  begin
    if not RDWREST.TesteEndpointGET(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método GET falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método GET disponível');
      TesteEndpointRDW('GET', 100);
      TesteEndpointRDW('GET', 1000);
      TesteEndpointRDW('GET', 10000);

      // LogMessage(aMemo, 'Teste de requisições GET concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método GET falhou!');

      LogMessage(aMemo, 'Teste GET concluído');
    end;

    if not RDWREST.TesteEndpointPOST(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método POST falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método POST disponível');
      TesteEndpointRDW('POST', 100);
      TesteEndpointRDW('POST', 1000);
      TesteEndpointRDW('POST', 10000);

      // LogMessage(aMemo, 'Teste de requisições POST concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método POST falhou!');

      LogMessage(aMemo, 'Teste POST concluído');
    end;

    if not RDWREST.TesteEndpointPUT(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método PUT falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método PUT disponível');
      TesteEndpointRDW('PUT', 100);
      TesteEndpointRDW('PUT', 1000);
      TesteEndpointRDW('PUT', 10000);

      // LogMessage(aMemo, 'Teste de requisições PUT concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método PUT falhou!');

      LogMessage(aMemo, 'Teste PUT concluído');
    end;

    if not RDWREST.TesteEndpointPATCH(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método PATCH falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método PATCH disponível');
      TesteEndpointRDW('PATCH', 100);
      TesteEndpointRDW('PATCH', 1000);
      TesteEndpointRDW('PATCH', 10000);

      // LogMessage(aMemo, 'Teste de requisições PATCH concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método PATCH falhou!');

      LogMessage(aMemo, 'Teste PATCH concluído');
    end;

    if not RDWREST.TesteEndpointDELETE(eEndpoint.Text) then
    begin
      aMemo.Lines.Add('Teste método DELETE falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método DELETE disponível');
      TesteEndpointRDW('DELETE', 100);
      TesteEndpointRDW('DELETE', 1000);
      TesteEndpointRDW('DELETE', 10000);

      // LogMessage(aMemo, 'Teste de requisições DELETE concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 100000)
      // then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método DELETE falhou!');

      LogMessage(aMemo, 'Teste DELETE concluído');
    end;
  end;
  LogMessage(aMemo, 'Fim de testes de Requisição com RDW RESTClient...');
  LogMessage(aMemo, Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

procedure TfPrincipal.TesteRESTRequest(aMemo: TMemo);
var
  I: integer;
  thread: TThread;
begin
  pass := 0;
  fail := 0;
  LogMessage(aMemo, 'Realizando testes de Requisição com REST nativos...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    LogMessage(aMemo, 'Erro: Configurações de servidor ou porta inválidas');
    exit;
  end
  else
  begin
    if not REST.TesteEndpointGET(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método GET falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método GET disponível');
      TesteEndpointREST('GET', 100);
      TesteEndpointREST('GET', 1000);
      TesteEndpointREST('GET', 10000);

      // LogMessage(aMemo, 'Teste de requisições GET concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método GET falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmGET, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método GET falhou!');

      LogMessage(aMemo, 'Teste GET concluído');
    end;

    if not REST.TesteEndpointPOST(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método POST falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método POST disponível');
      TesteEndpointREST('POST', 100);
      TesteEndpointREST('POST', 1000);
      TesteEndpointREST('POST', 10000);

      // LogMessage(aMemo, 'Teste de requisições POST concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método POST falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPOST, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método POST falhou!');

      LogMessage(aMemo, 'Teste POST concluído');
    end;

    if not REST.TesteEndpointPUT(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método PUT falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método PUT disponível');
      TesteEndpointREST('PUT', 100);
      TesteEndpointREST('PUT', 1000);
      TesteEndpointREST('PUT', 10000);

      // LogMessage(aMemo, 'Teste de requisições PUT concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método PUT falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPUT, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método PUT falhou!');

      LogMessage(aMemo, 'Teste PUT concluído');
    end;

    if not REST.TesteEndpointPATCH(eEndpoint.Text) then
    begin
      LogMessage(aMemo, 'Teste método PATCH falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método PATCH disponível');
      TesteEndpointREST('PATCH', 100);
      TesteEndpointREST('PATCH', 1000);
      TesteEndpointREST('PATCH', 10000);

      // LogMessage(aMemo, 'Teste de requisições PATCH concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método PATCH falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmPATCH, 100000) then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método PATCH falhou!');

      LogMessage(aMemo, 'Teste PATCH concluído');
    end;

    if not REST.TesteEndpointDELETE(eEndpoint.Text) then
    begin
      aMemo.Lines.Add('Teste método DELETE falhou!');
      inc(fail);
    end
    else
    begin
      LogMessage(aMemo, 'Método DELETE disponível');
      TesteEndpointREST('DELETE', 100);
      TesteEndpointREST('DELETE', 1000);
      TesteEndpointREST('DELETE', 10000);

      // LogMessage(aMemo, 'Teste de requisições DELETE concorrentes...');
      // if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 1000) then
      // LogMessage(aMemo,
      // 'Teste 1000 requisições concorrentes em método DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 10000) then
      // LogMessage(aMemo,
      // 'Teste 10000 requisições concorrentes em método DELETE falhou!')
      // else if not REST.TesteAssyncEndpoint(eEndpoint.Text, rmDELETE, 100000)
      // then
      // LogMessage(aMemo,
      // 'Teste 100000 requisições concorrentes em método DELETE falhou!');

      LogMessage(aMemo, 'Teste DELETE concluído');
    end;
  end;
  LogMessage(aMemo, 'Fim de testes de Requisição com REST nativos...');
  LogMessage(aMemo, Format('Testes realizados: %d, Sucesso: %d, Falhas: %d',
    [pass + fail, pass, fail]));
end;

end.
