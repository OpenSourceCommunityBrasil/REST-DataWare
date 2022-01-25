unit uODataTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uDWConstsData, uRESTDWPoolerDB,
  uDWResponseTranslator, uDWAbout, uDWDataset;

type
  TfODataTest = class(TForm)
    DWClientREST1: TDWClientREST;
    DWResponseTranslator1: TDWResponseTranslator;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Button1: TButton;
    RESTDWClientSQL1UserName: TStringField;
    RESTDWClientSQL1FirstName: TStringField;
    RESTDWClientSQL1LastName: TStringField;
    RESTDWClientSQL1MiddleName: TStringField;
    RESTDWClientSQL1Gender: TStringField;
    RESTDWClientSQL1Age: TStringField;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fODataTest: TfODataTest;

implementation

{$R *.dfm}

procedure TfODataTest.Button1Click(Sender: TObject);
begin
 RESTDWClientSQL1.Open;
end;

end.
