unit uLoadJSON;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDWJSONObject, uDWConsts;

type
  TForm3 = class(TForm)
    FDMemTable1: TFDMemTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    Image1: TImage;
    ButtonStart: TButton;
    procedure ButtonStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
   JSONValue     : TJSONValue;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.ButtonStartClick(Sender: TObject);
begin
 JSONValue.WriteToDataset(dtFull, Memo1.Lines.Text, FDMemTable1);
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 JSONValue.Free;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
 JSONValue := TJSONValue.Create;
end;

end.
