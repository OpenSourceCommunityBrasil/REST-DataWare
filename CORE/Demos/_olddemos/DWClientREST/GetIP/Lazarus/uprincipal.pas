unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, uRESTDWBase, uDWResponseTranslator, uRESTDWPoolerDB;

type

  { TfClientREST }

  TfClientREST = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DWClientREST1: TDWClientREST;
    DWResponseTranslator1: TDWResponseTranslator;
    edCNPJ: TEdit;
    Label1: TLabel;
    RESTDWClientSQL1: TRESTDWClientSQL;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DWClientREST1BeforeGet(Var AUrl: String; Var AHeaders: TStringList
      );
  private

  public

  end;

var
  fClientREST: TfClientREST;

implementation

{$R *.lfm}

{ TfClientREST }

procedure TfClientREST.DWClientREST1BeforeGet(Var AUrl: String;
  Var AHeaders: TStringList);
begin
 AUrl := 'https://www.receitaws.com.br/v1/cnpj/' + edCNPJ.Text;
end;

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

end.

