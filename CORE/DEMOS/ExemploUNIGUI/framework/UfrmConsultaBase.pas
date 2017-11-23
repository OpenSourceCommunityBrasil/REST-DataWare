unit UfrmConsultaBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, UfrmBase, uniGUIBaseClasses, uniStatusBar, uniPanel,
  acPNG, uniImage, uniLabel, uniButton, uniBitBtn, uniGroupBox, uniBasicGrid,
  uniDBGrid, Data.DB;

type
  TfrmConsultaBase = class(TfrmBase)
    UniPanel1: TUniPanel;
    UniImage1: TUniImage;
    lbDescTela: TUniLabel;
    UniPanel3: TUniPanel;
    btnCancelar: TUniBitBtn;
    btnConfirmar: TUniBitBtn;
    UniGroupBox1: TUniGroupBox;
    UniPanel2: TUniPanel;
    GridList: TUniDBGrid;
    btnConsultar: TUniBitBtn;
    dsPesquisa: TDataSource;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure GridListDblClick(Sender: TObject);
    procedure GridListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UniFormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ListaGrid: TStringList ;

    procedure ConsultaBase; virtual;
    procedure ConfiguraGrid(GridList: TUniDBGrid; DataSet: TDataSet); virtual;
  end;

function frmConsultaBase: TfrmConsultaBase;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication;

function frmConsultaBase: TfrmConsultaBase;
begin
  Result := TfrmConsultaBase(UniMainModule.GetFormInstance(TfrmConsultaBase));
end;

procedure TfrmConsultaBase.btnCancelarClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmConsultaBase.btnConfirmarClick(Sender: TObject);
begin
  inherited;
  if not dsPesquisa.DataSet.IsEmpty then
  begin
     ModalResult := mrOk;
  end;
end;

procedure TfrmConsultaBase.btnConsultarClick(Sender: TObject);
begin
  inherited;
  ConsultaBase;
end;

procedure TfrmConsultaBase.ConsultaBase;
begin

end;

procedure TfrmConsultaBase.GridListDblClick(Sender: TObject);
begin
  inherited;
  btnConfirmar.Click;
end;

procedure TfrmConsultaBase.GridListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = VK_RETURN then
     btnConfirmar.Click;
end;

procedure TfrmConsultaBase.UniFormCreate(Sender: TObject);
begin
  inherited;
  ListaGrid := TStringList.Create;
end;

procedure TfrmConsultaBase.ConfiguraGrid(GridList: TUniDBGrid; DataSet: TDataSet);
var
  Linha: TStringList;
  i, j: Integer;
begin
  if Assigned(ListaGrid) then
  begin
    try
      Linha := TStringList.Create;

      while GridList.Columns.Count-1 >= 0 do
      begin
        GridList.Columns.Delete(GridList.Columns.Count-1);
      end;

      for I := 0 to ListaGrid.Count - 1 do
      begin
        Linha.Delimiter := ';';
        Linha.StrictDelimiter := True;
        Linha.DelimitedText := ListaGrid.Strings[i];

        with GridList.Columns.Add do
        begin
          FieldName := Linha.Strings[0];
          Title.Caption := Linha.Strings[1];
          Width := StrToIntDef(Linha.Strings[2], 10);
          Visible := True;
        end;

        if DataSet.Active then
        begin
           if DataSet.FindField(Linha.Strings[0]) <> nil then
           begin
              if Linha.Count = 4 then
              begin
                if Trim(Linha.Strings[3]) <> '' then
                begin
                   TFloatField(DataSet.FieldByName(Linha.Strings[0])).DisplayFormat := Linha.Strings[3];
                end;
              end;
           end;
        end;

      end;

    finally
      Linha.Free;
    end;
  end;
end;

end.
