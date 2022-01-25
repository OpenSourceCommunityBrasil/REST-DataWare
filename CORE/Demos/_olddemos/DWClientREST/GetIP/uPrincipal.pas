unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uDWAbout, uRESTDWBase,
  Data.DB, Vcl.Grids, Vcl.DBGrids, uDWDataset, uDWConstsData, uRESTDWPoolerDB,
  uDWResponseTranslator, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfClientREST = class(TForm)
    DWClientREST1: TDWClientREST;
    Button1: TButton;
    Button2: TButton;
    DWResponseTranslator1: TDWResponseTranslator;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    edCNPJ: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DWClientREST1BeforeGet(var AUrl: string;
      var AHeaders: TStringList);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fClientREST: TfClientREST;

implementation

{$R *.dfm}

procedure TfClientREST.Button1Click(Sender: TObject);
begin
 RESTDWClientSQL1.Open;
end;

procedure TfClientREST.Button2Click(Sender: TObject);
Var
 vStringStream : TStringStream;
begin
 vStringStream := TStringStream.Create('');
 Try
  DWClientREST1.Get('https://api.ipify.org?format=json', Nil, vStringStream, True);
  Showmessage('URL : https://api.ipify.org?format=json' + #13 +
              'Resquest Type : Get' + #13 +
              'Response : ' + vStringStream.DataString);

 Finally
  vStringStream.Free;
 End;
end;

procedure TfClientREST.DWClientREST1BeforeGet(var AUrl: string;
  var AHeaders: TStringList);
begin
 AUrl := 'https://www.receitaws.com.br/v1/cnpj/' + edCNPJ.Text;
end;

end.
