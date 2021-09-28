unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDWAbout, uDWResponseTranslator,
  Data.DB, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, uDWDataset, uDWConstsData,
  uRESTDWPoolerDB;

type
  TfBlueCosmos = class(TForm)
    DWClientREST1: TDWClientREST;
    DWResponseTranslator1: TDWResponseTranslator;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fBlueCosmos: TfBlueCosmos;

implementation

{$R *.dfm}

procedure TfBlueCosmos.Button1Click(Sender: TObject);
begin
 RESTDWClientSQL1.Open;
end;

end.
