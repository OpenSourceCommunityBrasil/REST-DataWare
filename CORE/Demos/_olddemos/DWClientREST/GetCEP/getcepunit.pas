unit getcepunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, uDWResponseTranslator, uDWAbout, DB, uDWDataset,
  uDWConstsData, uRESTDWPoolerDB, StdCtrls;

type
  TfrmGetCEP = class(TForm)
    dsGetCEP: TDataSource;
    dwGetCEP: TRESTDWClientSQL;
    DWResponseTranslatorCEP: TDWResponseTranslator;
    DWClientRESTCEP: TDWClientREST;
    btConsultaCEP: TSpeedButton;
    Label1: TLabel;
    edCEP: TEdit;
    edLogradouro: TEdit;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    edComplemento: TEdit;
    Label4: TLabel;
    edBairro: TEdit;
    Label5: TLabel;
    edCidade: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    cbUF: TComboBox;
    procedure btConsultaCEPClick(Sender: TObject);
    procedure DWClientRESTCEPBeforeGet(var AUrl: String;
      var AHeaders: TStringList);
    procedure edCEPKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edCEPKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGetCEP: TfrmGetCEP;

implementation

{$R *.dfm}

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
      cbUF.ItemIndex := cbUF.Items.IndexOf(dwGetCEP.FieldByName('uf').AsString);
    end
    else
      ShowMessage('CEP não encontrado!');

    Screen.Cursor := crDefault;
  end
  else
    ShowMessage('CEP inválido, verifique!');
end;

procedure TfrmGetCEP.DWClientRESTCEPBeforeGet(var AUrl: String;
  var AHeaders: TStringList);
begin
 AUrl := format('https://viacep.com.br/ws/%s/json/', [edCEP.Text]);
end;

procedure TfrmGetCEP.edCEPKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btConsultaCEPClick(self);
end;

procedure TfrmGetCEP.edCEPKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in['0'..'9',#8]) then
    Key := #0;
end;

end.
