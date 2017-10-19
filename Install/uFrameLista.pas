{ ****************************************************************************** }
{ Projeto: Componentes REST Dataware }
{ ******************************************************************************
  |* Historico
  |*
  |* 10/10/2017: Paulo Tenório
  |*  - Adaptação do instalador ACBr
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
    RestEasyObjects_dpk: TCheckBox;
    RESTDriverZEOS_dpk: TCheckBox;
    RESTDriverFD_dpk: TCheckBox;
    RESTDriverUniDAC_dpk: TCheckBox;
    BtnPacotesDesmarcarTodos: TSpeedButton;
    BtnPacotesMarcarTodos: TSpeedButton;
    Label27: TLabel;
    Label28: TLabel;
    RestEasyObjectsCORE_dpk: TCheckBox;
    RESTDWDriverFD_dpk: TCheckBox;
    Label8: TLabel;
    Label21: TLabel;
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
      // quando não for selecionada uma versão, devemos desmarcar seus conectores
      if not RestEasyObjects_dpk.Checked then
      begin
        RESTDriverFD_dpk.Checked     := False;
        RESTDriverZEOS_dpk.Checked   := False;
        RESTDriverUniDAC_dpk.Checked := False;
      end;

      if not RestEasyObjectsCORE_dpk.Checked then
      begin
        RESTDWDriverFD_dpk.Checked := False;
      end;
    finally
      FUtilizarBotoesMarcar := False;
    end;
  end;
end;

end.

