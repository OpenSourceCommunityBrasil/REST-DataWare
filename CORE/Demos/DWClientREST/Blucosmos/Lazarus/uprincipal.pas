unit UPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, uDWResponseTranslator, uRESTDWPoolerDB;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DWClientREST1: TDWClientREST;
    DWResponseTranslator1: TDWResponseTranslator;
    RESTDWClientSQL1: TRESTDWClientSQL;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
 RESTDWClientSQL1.Open;
end;

end.

