{
Esse editor SQL foi desenvolvido para integrar mais um recurso ao pacote de
componentes REST Dataware, a intenção é ajudar na produtividade.

Desenvolvedor : Julio César Andrade dos Anjos
Data : 19/02/2018
}

unit uDWSqlEditor;

interface

uses
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.DBGrids,
  uRESTDWPoolerDB, DesignIntf, DesignEditors, Data.DB, Vcl.Grids, Vcl.Controls,
  System.Classes;

type
  TFrmDWSqlEditor = class(TForm)
    PnlSQL: TPanel;
    PnlButton: TPanel;
    BtnExecute: TButton;
    PageControl: TPageControl;
    TabSheetSQL: TTabSheet;
    Memo: TMemo;
    PnlAction: TPanel;
    BtnOk: TButton;
    BtnCancelar: TButton;
    Splitter1: TSplitter;
    PageControlResult: TPageControl;
    TabSheetTable: TTabSheet;
    DBGridRecord: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
  private
    { Private declarations }
    DataSource : TDataSource;
    RESTDWClientSQL : TRESTDWClientSQL;
  public
    { Public declarations }
  end;

  TSQLProperty = class(TStringProperty)
  private
  protected
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  published
  end;

procedure Register;

implementation

uses
  System.SysUtils, Vcl.Dialogs;

{$R *.dfm}

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TStrings), TRESTDWClientSQL, 'SQL', TSQLProperty);
end;

{ TSQLProperty }

procedure TSQLProperty.Edit;
var
  FrmDWSqlEditor : TFrmDWSqlEditor;
begin
  FrmDWSqlEditor := TFrmDWSqlEditor.Create(Application);
  with FrmDWSqlEditor do
  try
    RESTDWClientSQL.DataBase := TRESTDWClientSQL(GetComponent(0)).DataBase;

    Memo.Lines.Clear;
    Memo.Lines.Text := TRESTDWClientSQL(GetComponent(0)).SQL.Text;
    if ShowModal = mrOK then
      TRESTDWClientSQL(GetComponent(0)).SQL.Text := Memo.Lines.Text;
  finally
    Free;
  end;
end;

function TSQLProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
end;

procedure TFrmDWSqlEditor.BtnExecuteClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    RESTDWClientSQL.Close;
    RESTDWClientSQL.SQL.Clear;
    RESTDWClientSQL.SQL.Add(Memo.Lines.Text);
    RESTDWClientSQL.Open;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmDWSqlEditor.FormCreate(Sender: TObject);
begin
  RESTDWClientSQL := TRESTDWClientSQL.Create(Self);

  DataSource := TDataSource.Create(Self);
  DataSource.DataSet := RESTDWClientSQL;
  DBGridRecord.DataSource := DataSource;
end;

procedure TFrmDWSqlEditor.FormDestroy(Sender: TObject);
begin
  RESTDWClientSQL.DataBase := nil;
  FreeAndNil(DataSource);
  FreeAndNil(RESTDWClientSQL);
end;

end.
