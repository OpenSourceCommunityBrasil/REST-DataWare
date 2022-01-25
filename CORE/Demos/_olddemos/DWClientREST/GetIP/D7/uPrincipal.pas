unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uDWAbout, uRESTDWBase, StdCtrls, uDWResponseTranslator, DB,
  uDWDataset, uDWConstsData, uRESTDWPoolerDB, Grids, DBGrids;

type
  TfClientREST = class(TForm)
    Button2: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DWResponseTranslator1: TDWResponseTranslator;
    DWClientREST1: TDWClientREST;
    Button1: TButton;
    edCNPJ: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DWClientREST1BeforeGet(var AUrl: String;
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

procedure TfClientREST.DWClientREST1BeforeGet(var AUrl: String;
  var AHeaders: TStringList);
begin
 AUrl := 'https://www.receitaws.com.br/v1/cnpj/' + edCNPJ.Text;
end;

end.
