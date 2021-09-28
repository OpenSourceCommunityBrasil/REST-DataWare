unit uLoadJSON;

{$mode objfpc}{$H+}

interface

uses
  LCL, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uDWJSONObject, uRESTDWBase, uRESTDWServerEvents, uDWConstsData,
  uDWConsts, DB, StdCtrls, DBGrids, ExtCtrls, ActnList, uDWDataset;

type

  { TForm1 }

  TForm1 = class(TForm)
    dwmDados: TDWMemtable;
    Image1: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    Label7: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label1: TLabel;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    ButtonStart: TButton;
    eHost: TEdit;
    ePort: TEdit;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    CheckBox1: TCheckBox;
    chkhttps: TCheckBox;
    DataSource1: TDataSource;
    ActionList1: TActionList;
    DWClientEvents1: TDWClientEvents;
    RESTClientPooler1: TRESTClientPooler;
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.ButtonStartClick(Sender: TObject);
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
  RESTClientPooler1.TypeRequest := trHttps
 Else
  RESTClientPooler1.TypeRequest := trHttp;
 DWClientEvents1.CreateDWParams('loaddatasetevent', dwParams);
 dwParams.ItemsString['sql'].AsString := Memo1.Text;
 DWClientEvents1.SendEvent('loaddatasetevent', dwParams, vErrorMessage);
 dwmDados.Close;
 If vErrorMessage = '' Then
  JSONValue.WriteToDataset(dtFull, dwParams.ItemsString['result'].Value, dwmDados)
 Else
  Showmessage(vErrorMessage);
 dwParams.Free;
 JSONValue.Free;
end;

end.
