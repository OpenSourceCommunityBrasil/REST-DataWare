unit uODATATest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, uDWDataset, uDWConstsData, uRESTDWPoolerDB,
  uDWResponseTranslator, uDWAbout, StdCtrls, Grids, DBGrids;

type
  TForm1 = class(TForm)
    DBGrid1: TDBGrid;
    Button1: TButton;
    DWClientREST1: TDWClientREST;
    DWResponseTranslator1: TDWResponseTranslator;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DataSource1: TDataSource;
    procedure Button1Click(Sender: TObject);
    procedure DWClientREST1BeforeGet(var AUrl: String;
      var AHeaders: TStringList);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
 RESTDWClientSQL1.Open;
end;

procedure TForm1.DWClientREST1BeforeGet(var AUrl: String;
  var AHeaders: TStringList);
begin
 AUrl := 'http://services.odata.org/TripPinRESTierService/(S(ajrvp01flke4mgq0jsunxkm3))/People';
end;

end.
