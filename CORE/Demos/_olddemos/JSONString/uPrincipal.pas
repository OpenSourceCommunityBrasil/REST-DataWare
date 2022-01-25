unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, uDWDataset, uDWConstsData, uRESTDWPoolerDB, uDWAbout,
  uDWResponseTranslator;

type
  TfJSONStringSample = class(TForm)
    DWResponseTranslator1: TDWResponseTranslator;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    Executar: TButton;
    procedure ExecutarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fJSONStringSample: TfJSONStringSample;

implementation

{$R *.dfm}

procedure TfJSONStringSample.ExecutarClick(Sender: TObject);
begin
 RESTDWClientSQL1.OpenJson(Memo1.lines.text);
end;

end.
