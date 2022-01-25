unit climatempounit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  EditBtn, StdCtrls, Buttons, DBGrids, uDWResponseTranslator, uRESTDWPoolerDB,
  db;

type

  { TfrmClimaTempo }

  TfrmClimaTempo = class(TForm)
    btPrevisao: TButton;
    cbUF: TComboBox;
    dsCidade: TDataSource;
    dsClima: TDataSource;
    DWClientRESTCidade: TDWClientREST;
    DWClientRESTClima: TDWClientREST;
    dwClima: TRESTDWClientSQL;
    DWResponseTranslatorCidade: TDWResponseTranslator;
    DWResponseTranslatorClima: TDWResponseTranslator;
    edCidade: TLabeledEdit;
    edCodCidade: TLabeledEdit;
    edData: TLabeledEdit;
    edSensacao: TLabeledEdit;
    edTemperatura: TLabeledEdit;
    edPressao: TLabeledEdit;
    edCondicao: TLabeledEdit;
    edVento: TLabeledEdit;
    edVentoVelocidade: TLabeledEdit;
    edToken: TLabeledEdit;
    edUmidade: TLabeledEdit;
    imPrevisao: TImage;
    Label1: TLabel;
    btCidade: TSpeedButton;
    dwCidade: TRESTDWClientSQL;
    procedure btCidadeClick(Sender: TObject);
    procedure btPrevisaoClick(Sender: TObject);
    procedure DWClientRESTCidadeBeforeGet(Var AUrl: String; Var AHeaders: TStringList
      );
    procedure DWClientRESTClimaBeforeGet(Var AUrl: String;
      Var AHeaders: TStringList);
  private

  public

  end;

const
  vToken = '';

var
  frmClimaTempo: TfrmClimaTempo;

implementation

{$R *.lfm}

{ TfrmClimaTempo }

procedure TfrmClimaTempo.btPrevisaoClick(Sender: TObject);
begin
  if StrToIntDef(edCodCidade.Text,0) > 0 then
  begin
    Screen.Cursor := crSQLWait;

    dwClima.Close;
    dwClima.Open;

    if (dwClima.FieldCount > 1) then
    begin
      // DWResponseTranslatorClima - ElementRootBaseName := data
      // {"id":4898,"name":"Crici\u00fama","state":"SC","country":"BR  ","data":{"temperature":13,"wind_direction":"WSW","wind_velocity":9,"humidity":69,"condition":"Muitas nuvens","pressure":1015,"icon":"2r","sensation":13,"date":"2018-06-06 09:17:11"}}

      edTemperatura.Text := dwClima.FieldByName('temperature').AsString;
      edVento.Text := dwClima.FieldByName('wind_direction').AsString;
      edVentoVelocidade.Text := dwClima.FieldByName('wind_velocity').AsString;
      edUmidade.Text := dwClima.FieldByName('humidity').AsString;
      edCondicao.Text := dwClima.FieldByName('condition').AsString;
      edPressao.Text := dwClima.FieldByName('pressure').AsString;
      edSensacao.Text := dwClima.FieldByName('sensation').AsString;
      edData.Text := dwClima.FieldByName('date').AsString;

      imPrevisao.Picture.LoadFromFile(PAnsiChar(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))))+'imagens'+PathDelim+dwClima.FieldByName('icon').AsString+'.png');
    end;

    Screen.Cursor := crDefault;
  end
  else
    ShowMessage('Cidade inválida, verifique!');
end;

procedure TfrmClimaTempo.DWClientRESTCidadeBeforeGet(Var AUrl: String; Var AHeaders: TStringList);
begin
  AUrl := format('http://apiadvisor.climatempo.com.br/api/v1/locale/city?name=%s&state=%s&token=%s',[edCidade.Text,cbUF.Text,edToken.Text]);
end;

procedure TfrmClimaTempo.btCidadeClick(Sender: TObject);
begin
  if trim(edCidade.Text) <> '' then
  begin
    Screen.Cursor := crSQLWait;

    dwCidade.Close;
    dwCidade.Open;

    if (dwCidade.FieldCount > 1) then
    begin
      // [{"id":4898,"name":"Crici\u00fama","state":"SC","country":"BR  "}]

      edCidade.Text := dwCidade.FieldByName('name').AsString;
      edCodCidade.Text := dwCidade.FieldByName('id').AsString;
      cbUF.Text := dwCidade.FieldByName('state').AsString;
    end;

    Screen.Cursor := crDefault;
  end
  else
    ShowMessage('Cidade inválida, verifique!');
end;

procedure TfrmClimaTempo.DWClientRESTClimaBeforeGet(Var AUrl: String; Var AHeaders: TStringList);
begin
  AUrl := format('http://apiadvisor.climatempo.com.br/api/v1/weather/locale/%s/current?token=%s',[edCodCidade.Text,edToken.Text]);
end;

end.

