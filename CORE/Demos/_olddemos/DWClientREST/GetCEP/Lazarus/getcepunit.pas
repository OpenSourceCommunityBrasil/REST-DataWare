unit getcepunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DbCtrls,
  Buttons, StdCtrls, ExtCtrls, uDWResponseTranslator, uRESTDWPoolerDB, db,
  LCLType;

type

  { TfrmGetCEP }

  TfrmGetCEP = class(TForm)
    btConsultaCEP: TSpeedButton;
    cbUF: TComboBox;
    dsGetCEP: TDataSource;
    DWClientRESTCEP: TDWClientREST;
    dwGetCEP: TRESTDWClientSQL;
    DWResponseTranslatorCEP: TDWResponseTranslator;
    edBairro: TLabeledEdit;
    edCidade: TLabeledEdit;
    edComplemento: TLabeledEdit;
    edNumero: TLabeledEdit;
    edLogradouro: TLabeledEdit;
    edCEP: TLabeledEdit;
    lbUF: TLabel;
    procedure btConsultaCEPClick(Sender: TObject);
    procedure DWClientRESTCEPBeforeGet(Var AUrl: String;
      Var AHeaders: TStringList);
    procedure edCEPKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edCEPKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmGetCEP: TfrmGetCEP;

implementation

{$R *.lfm}

{ TfrmGetCEP }

procedure TfrmGetCEP.btConsultaCEPClick(Sender: TObject);
begin
  if Length(edCEP.Text) = 8 then
  begin
    Screen.Cursor := crSQLWait;

    dwGetCEP.Close;
    dwGetCEP.Open;

    if (dwGetCEP.FieldCount > 1)  then
    begin
      {
        https://viacep.com.br/ws/%s/json/

        "cep": "88801-530",
        "logradouro": "Rua João Pessoa",
        "complemento": "até 743/744",
        "bairro": "Centro",
        "localidade": "Criciúma",
        "uf": "SC",
        "unidade": "",
        "ibge": "4204608",
        "gia": ""
      }
      edLogradouro.Text := dwGetCEP.FieldByName('logradouro').AsString;
      edComplemento.Text := dwGetCEP.FieldByName('complemento').AsString;
      edBairro.Text := dwGetCEP.FieldByName('bairro').AsString;
      edCidade.Text := dwGetCEP.FieldByName('localidade').AsString;
      cbUF.Text := dwGetCEP.FieldByName('uf').AsString;
    end
    else
      ShowMessage('CEP não encontrado!');

    Screen.Cursor := crDefault;
  end
  else
    ShowMessage('CEP inválido, verifique!');
end;

procedure TfrmGetCEP.DWClientRESTCEPBeforeGet(Var AUrl: String; Var AHeaders: TStringList);
begin
  AUrl := format('https://viacep.com.br/ws/%s/json/',[edCEP.Text]);
end;

procedure TfrmGetCEP.edCEPKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btConsultaCEPClick(self);
end;

procedure TfrmGetCEP.edCEPKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in['0'..'9',#8]) then
    Key := #0;
end;

procedure TfrmGetCEP.FormCreate(Sender: TObject);
begin

end;

end.

