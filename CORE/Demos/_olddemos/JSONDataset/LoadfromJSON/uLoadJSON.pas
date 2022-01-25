unit uLoadJSON;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDWJSONObject, uDWConsts, uRESTDWBase, uRESTDWServerEvents, System.Actions,
  uDWConstsData, Vcl.ActnList, uDWDataset, uDWAbout;

type
  TForm3 = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    Image1: TImage;
    ButtonStart: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    Label7: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label1: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    CheckBox1: TCheckBox;
    chkhttps: TCheckBox;
    ActionList1: TActionList;
    DWClientEvents1: TDWClientEvents;
    RESTClientPooler1: TRESTClientPooler;
    DWMemtable1: TDWMemtable;
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.ButtonStartClick(Sender: TObject);
Var
 JSONValue     : TJSONValue;
 dwParams      : TDWParams;
 vErrorMessage : String;
begin
 JSONValue     := TJSONValue.Create;
 RESTClientPooler1.Host            := EHost.Text;
 RESTClientPooler1.Port            := StrToInt(EPort.Text);
 RESTClientPooler1.UserName        := EdUserNameDW.Text;
 RESTClientPooler1.Password        := EdPasswordDW.Text;
 RESTClientPooler1.DataCompression := CheckBox1.Checked;
 If chkhttps.Checked then
  RESTClientPooler1.TypeRequest := TTyperequest.trHttps
 Else
  RESTClientPooler1.TypeRequest := TTyperequest.trHttp;
 DWClientEvents1.CreateDWParams('loaddatasetevent', dwParams);
 dwParams.ItemsString['sql'].AsString := Memo1.Text;
 DWClientEvents1.SendEvent('loaddatasetevent', dwParams, vErrorMessage);
 DWMemtable1.Close;
 If vErrorMessage = '' Then
  JSONValue.WriteToDataset(dtFull, dwParams.ItemsString['result'].Value, DWMemtable1) //FDMemTable1)
 Else
  Showmessage(vErrorMessage);
 dwParams.Free;
 JSONValue.Free;
end;

end.
