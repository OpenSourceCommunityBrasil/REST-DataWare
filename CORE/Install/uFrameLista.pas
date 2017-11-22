{ ****************************************************************************** }
{ Projeto: Componentes DW }
{ Biblioteca multiplataforma de componentes Delphi para interação com equipa- }
{ mentos de Automação Comercial utilizados no Brasil }
{ }
{ Direitos Autorais Reservados (c) 2009   Isaque Pinheiro }
{ }
{ Colaboradores nesse arquivo: }
{ }
{ Você pode obter a última versão desse arquivo na pagina do  Projeto DW }
{ Componentes localizado em      http://www.sourceforge.net/projects/DW }
{ }
{ Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la }
{ sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela }
{ Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério) }
{ qualquer versão posterior. }
{ }
{ Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM }
{ NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU }
{ ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor }
{ do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT) }
{ }
{ Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto }
{ com esta biblioteca; se não, escreva para a Free Software Foundation, Inc., }
{ no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA. }
{ Você também pode obter uma copia da licença em: }
{ http://www.opensource.org/licenses/lgpl-license.php }
{ }
{ Daniel Simões de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br }
{ Praça Anita Costa, 34 - Tatuí - SP - 18270-410 }
{ }
{ ****************************************************************************** }

{ ******************************************************************************
  |* Historico
  |*
  |* 29/03/2012: Isaque Pinheiro / Régys Borges da Silveira
  |*  - Criação e distribuição da Primeira Versao
  ******************************************************************************* }
unit uFrameLista;

interface

uses
  Generics.Collections,
  Generics.Defaults,

  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Buttons,
  ExtCtrls,
  StdCtrls,
  ComCtrls;

type
  TPacotes = TList<TCheckBox>;

  TframePacotes = class(TFrame)
    Label2: TLabel;
    Label3: TLabel;
    BtnPacotesDesmarcarTodos: TSpeedButton;
    BtnPacotesMarcarTodos: TSpeedButton;
    Label27: TLabel;
    Label28: TLabel;
    Label8: TLabel;
    Label21: TLabel;
    RestEasyObjects_dpk: TCheckBox;
    RESTDriverZEOS_dpk: TCheckBox;
    RESTDriverFD_dpk: TCheckBox;
    RESTDriverUniDAC_dpk: TCheckBox;
    RestDatawareCORE_dpk: TCheckBox;
    RESTDWDriverFD_dpk: TCheckBox;
    procedure BtnPacotesMarcarTodosClick(Sender: TObject);
    procedure BtnPacotesDesmarcarTodosClick(Sender: TObject);
    procedure VerificarCheckboxes(Sender: TObject);
  private
    FPacotes:              TPacotes;
    FUtilizarBotoesMarcar: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Pacotes: TPacotes
      read   FPacotes
      write  FPacotes;
  end;

implementation

uses
  StrUtils;

{$R *.dfm}

constructor TframePacotes.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;

  // variavel para controle do verificar checkboxes
  // utilizada para evitar estouro de pilha por conta da redundância
  // e também para que pacotes dependentes não atrapalhem a rotina
  FUtilizarBotoesMarcar := False;

  // lista de pacotes (checkboxes) disponiveis
  FPacotes := TPacotes.Create;

  // popular a lista de pacotes com os pacotes disponíveis
  // colocar todos os checkboxes disponíveis na lista
  FPacotes.Clear;
  for I := 0 to Self.ComponentCount - 1 do
  begin
    if Self.Components[I] is TCheckBox then
      FPacotes.Add(TCheckBox(Self.Components[I]));
  end;
  FPacotes.Sort(TComparer<TCheckBox>.Construct(
    function(const Dpk1, Dpk2: TCheckBox): Integer
    begin
      Result := CompareStr(FormatFloat('0000', Dpk1.TabOrder), FormatFloat('0000', Dpk2.TabOrder));
    end));
end;

destructor TframePacotes.Destroy;
begin
  FreeAndNil(FPacotes);

  inherited;
end;

// botão para marcar todos os checkboxes
procedure TframePacotes.BtnPacotesMarcarTodosClick(Sender: TObject);
var
  I: Integer;
begin
  FUtilizarBotoesMarcar := True;
  try
    for I := 0 to Self.ComponentCount - 1 do
    begin
      if Self.Components[I] is TCheckBox then
      begin
        if TCheckBox(Self.Components[I]).Enabled then
          TCheckBox(Self.Components[I]).Checked := True;
      end;
    end;
  finally
    FUtilizarBotoesMarcar := False;
    VerificarCheckboxes(Sender);
  end;
end;

// botão para desmarcar todos os checkboxes
procedure TframePacotes.BtnPacotesDesmarcarTodosClick(Sender: TObject);
var
  I: Integer;
begin
  FUtilizarBotoesMarcar := True;
  try
    for I := 0 to Self.ComponentCount - 1 do
    begin
      if Self.Components[I] is TCheckBox then
      begin
        if TCheckBox(Self.Components[I]).Enabled then
          TCheckBox(Self.Components[I]).Checked := False;
      end;
    end;
  finally
    FUtilizarBotoesMarcar := False;
    VerificarCheckboxes(Sender);
  end;
end;

// rotina de verificação de dependência e marcação dos pacotes base
procedure TframePacotes.VerificarCheckboxes(Sender: TObject);
begin
  if not FUtilizarBotoesMarcar then
  begin
    FUtilizarBotoesMarcar := True;

    /// caso algum evento abaixo dispare novamente
    try
      // quando não for selecionada a versão Datasnap, devemos desmarcar os conectores
      if not RestEasyObjects_dpk.Checked then
      begin
        RESTDriverFD_dpk.Checked     := False;
        RESTDriverZEOS_dpk.Checked   := False;
        RESTDriverUniDAC_dpk.Checked := False;
      end;

      // quando não for selecionada a versão CORE, devemos desmarcar
      if not RestDatawareCORE_dpk.Checked then
      begin
        RESTDWDriverFD_dpk.Checked := False;
      end;
    finally
      FUtilizarBotoesMarcar := False;
    end;
  end;
end;

end.
