unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.DateUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Layouts, FMX.Objects, FMX.ListBox,
  REST.Types,
  uRESTDAO;

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
    procedure IniciarClick(Sender: TObject);
  private
    { Private declarations }
    REST: TRESTDAO;
    inicio, fim: Double;
    procedure TesteAB(aMemo: TMemo);
    procedure TesteRequest(aMemo: TMemo);
    procedure TesteDBWare(aMemo: TMemo);
    procedure LogMessage(aMemo: TMemo; aMessage: string);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.fmx}

procedure TfPrincipal.IniciarClick(Sender: TObject);
begin
  inicio := now;
  Memo1.Lines.Clear;
  LogMessage(Memo1, 'Testes iniciados às' + TimeToStr(inicio));
  REST := TRESTDAO.Create(eServidor.Text, ePorta.Text);
  if (ComboBox1.ItemIndex = 1) and
    ((eUsuario.Text <> EmptyStr) and (eSenha.Text <> EmptyStr)) then
    REST.SetBasicAuth(eUsuario.Text, eSenha.Text);
  TThread.CreateAnonymousThread(
    procedure
    begin
      // TesteAB(Memo1);
      TesteRequest(Memo1);
      // TesteDBWare(Memo1);

      fim := now;
      LogMessage(Memo1, 'Teste finalizado após ' + MinutesBetween(fim, inicio)
        .ToString + ' minutos');
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

procedure TfPrincipal.TesteDBWare(aMemo: TMemo);
begin
  LogMessage(aMemo, 'Realizando testes DBWare...');
end;

procedure TfPrincipal.TesteRequest(aMemo: TMemo);
var
  I: integer;
  thread: TThread;

  procedure TesteEndpoint(metodo: string; count: integer);
  var
    I: integer;
  begin
    if pos('GET', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisições...');
      for I := 0 to count do
        if not REST.TesteEndpointGET(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'Método GET falhou após ' + I.ToString +
            ' requisições');
          abort;
        end;
    end;

    if pos('POST', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisições...');
      for I := 0 to count do
        if not REST.TesteEndpointPOST(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'Método POST falhou após ' + I.ToString +
            ' requisições');
          abort;
        end;
    end;

    if pos('PUT', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisições...');
      for I := 0 to count do
        if not REST.TesteEndpointPUT(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'Método PUT falhou após ' + I.ToString +
            ' requisições');
          abort;
        end;
    end;

    if pos('PATCH', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisições...');
      for I := 0 to count do
        if not REST.TesteEndpointPATCH(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'Método PATCH falhou após ' + I.ToString +
            ' requisições');
          abort;
        end;
    end;

    if pos('DELETE', metodo) > 0 then
    begin
      LogMessage(aMemo, 'Testando ' + count.ToString + ' requisições...');
      for I := 0 to count do
        if not REST.TesteEndpointDELETE(eEndpoint.Text) then
        begin
          LogMessage(aMemo, 'Método DELETE falhou após ' + I.ToString +
            ' requisições');
          abort;
        end;
    end;
  end;

begin
  LogMessage(aMemo, 'Realizando testes de Requisição com REST nativos...');
  if (eServidor.Text = EmptyStr) or (ePorta.Text = EmptyStr) then
  begin
    LogMessage(aMemo, 'Erro: Configurações de servidor ou porta inválidas');
    exit;
  end
  else
  begin
    if not REST.TesteEndpointGET(eEndpoint.Text) then
      LogMessage(aMemo, 'Teste método GET falhou!')
    else
    begin
      LogMessage(aMemo, 'Método GET disponível');
      TesteEndpoint('GET', 100);
      TesteEndpoint('GET', 1000);
      TesteEndpoint('GET', 10000);

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
      LogMessage(aMemo, 'Teste método POST falhou!')
    else
    begin
      LogMessage(aMemo, 'Método POST disponível');
      TesteEndpoint('POST', 100);
      TesteEndpoint('POST', 1000);
      TesteEndpoint('POST', 10000);

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
      LogMessage(aMemo, 'Teste método PUT falhou!')
    else
    begin
      LogMessage(aMemo, 'Método PUT disponível');
      TesteEndpoint('PUT', 100);
      TesteEndpoint('PUT', 1000);
      TesteEndpoint('PUT', 10000);

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
      LogMessage(aMemo, 'Teste método PATCH falhou!')
    else
    begin
      LogMessage(aMemo, 'Método PATCH disponível');
      TesteEndpoint('PATCH', 100);
      TesteEndpoint('PATCH', 1000);
      TesteEndpoint('PATCH', 10000);

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
      aMemo.Lines.Add('Teste método DELETE falhou!')
    else
    begin
      LogMessage(aMemo, 'Método DELETE disponível');
      TesteEndpoint('DELETE', 100);
      TesteEndpoint('DELETE', 1000);
      TesteEndpoint('DELETE', 10000);

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
end;

end.
