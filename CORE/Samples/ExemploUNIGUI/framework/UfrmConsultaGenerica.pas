unit UfrmConsultaGenerica;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, UfrmBase, uniEdit, uniLabel, uniGroupBox,
  uniGUIBaseClasses, uniStatusBar, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, uniButton, uniBitBtn,
  System.Actions, Vcl.ActnList, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uniBasicGrid, uniDBGrid, uDWConstsData,
  uRESTDWPoolerDB;

type
  TfrmConsultaGenerica = class(TfrmBase)
    UniGroupBox1: TUniGroupBox;
    lblTitulo: TUniLabel;
    UniLabel1: TUniLabel;
    edtCodigo: TUniEdit;
    edtNome: TUniEdit;
    UniLabel2: TUniLabel;
    dsPesqBase: TDataSource;
    actlstPesquisar: TActionList;
    actFiltrar: TAction;
    actFechar: TAction;
    btnFiltrar: TUniBitBtn;
    btnSair: TUniBitBtn;
    dbgbase: TUniDBGrid;
    adqrypesquisa: TRESTDWClientSQL;
    procedure actFecharExecute(Sender: TObject);
    procedure actFiltrarExecute(Sender: TObject);
    procedure edtCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure edtNomeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UniFormClose(Sender: TObject; var Action: TCloseAction);
    procedure UniFormShow(Sender: TObject);
    procedure dbgbaseDblClick(Sender: TObject);
    procedure dbgbaseKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    // Campos Genericos
    Tabela, CampoCodigo, CampoNome, CampoData, CampoExclusao, Condicaoauxiliar1,
      CampoStatus: string;

    TipoPesquisa: Integer;

    procedure PesquisaBase;
    procedure InseriBase;
  end;

function frmConsultaGenerica: TfrmConsultaGenerica;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication;

function frmConsultaGenerica: TfrmConsultaGenerica;
begin
  Result := TfrmConsultaGenerica
    (UniMainModule.GetFormInstance(TfrmConsultaGenerica));
end;

procedure TfrmConsultaGenerica.actFecharExecute(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmConsultaGenerica.actFiltrarExecute(Sender: TObject);
begin
  inherited;
  PesquisaBase;
  dbgbase.setfocus;
end;

procedure TfrmConsultaGenerica.dbgbaseDblClick(Sender: TObject);
begin
  inherited;
  InseriBase;
end;

procedure TfrmConsultaGenerica.dbgbaseKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if key = VK_RETURN then
    InseriBase;
end;

procedure TfrmConsultaGenerica.edtCodigoKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if key = #13 then
  begin
    Perform (CM_DialogKey, VK_TAB, 0);
    key:=#0;
  end
end;

procedure TfrmConsultaGenerica.edtNomeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if key =VK_RETURN then
    btnFiltrar.setfocus;
end;

procedure TfrmConsultaGenerica.InseriBase;
begin
  if dsPesqBase.DataSet.RecordCount > 0 then
    begin
      // Passa o Valor do Campo Nome pro Campo
      CampoNome :='';
      CampoNome :=  dsPesqBase.DataSet.Fields[1].AsString;
      CampoCodigo :='';
      CampoCodigo := dsPesqBase.DataSet.Fields[0].AsString;

      ModalResult:= mrOk;
    end;
end;

procedure TfrmConsultaGenerica.PesquisaBase;
begin
  with adqrypesquisa do
  Begin
    close;
    SQL.Clear;
    SQL.Add('select ' + CampoCodigo + ', ' + CampoNome + ' from '+ Tabela);

    if CampoData <> '' then
      SQL.Add('where '+ CampoData + ' is null and '+ CampoExclusao+ ' is null');

    if CampoData ='' then
      SQL.Add(' Where ' + CampoCodigo + ' like :campocodigo ')
    else
      SQL.Add(' and ' + CampoCodigo + ' like :campocodigo ');

      SQL.Add(' and ' + CampoNome + ' like :camponome ');

    if Condicaoauxiliar1 <> '' then
      Begin
        SQL.Add(condicaoauxiliar1);
      End;

    // Pesquisa Por Status
    if CampoStatus <> '' then
      Begin
        case TipoPesquisa of
          1 : begin // CLientes Avalistas
                 SQL.Add(' and ' + CampoStatus + ' = "T" ');
             end;
        end;
      end;

    // Faz Ordenação
    SQL.Add(' order by '+ CampoCodigo + ', '+ CampoNome);

    Params[0].Value :=  trim(edtCodigo.Text) + '%';
    Params[1].Value := trim(edtNome.Text) + '%';

    Open;

    UniStatusBar1.Panels[1].Text := IntToStr(Recordcount);
  end;
end;

procedure TfrmConsultaGenerica.UniFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Condicaoauxiliar1 := '';
end;

procedure TfrmConsultaGenerica.UniFormShow(Sender: TObject);
begin
  inherited;
  // Seta Colunas do DbGrid
  dbgBase.Columns[0].FieldName:= StringReplace(CampoCodigo, '"', '', [rfReplaceAll]);
  dbgBase.Columns[1].FieldName:= StringReplace(CampoNome, '"', '', [rfReplaceAll]);
end;

end.
