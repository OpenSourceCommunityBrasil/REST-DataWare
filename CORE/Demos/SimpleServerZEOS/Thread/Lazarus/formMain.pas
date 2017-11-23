unit formMain;
{$DEFINE INTHREAD}
interface

uses
  {$IFDEF WINDOWS}Windows, {$ELSE}LCLType, {$ENDIF}Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, fpjson, jsonparser,
  DB, BufDataset, memds, Grids, DBGrids, ExtCtrls, uRESTDWBase,
  uDWConsts, uDWJSONObject, uDWJSONTools;

type

  { TForm2 }

  TForm2 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cheParams: TCheckBox;
    cheThread: TCheckBox;
    DataSource2: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    eHost: TEdit;
    ePort: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbret1: TListBox;
    lbret2: TListBox;
    mComando1: TMemo;
    mComando2: TMemo;
    MemDataset1: TMemDataset;
    DataSource1: TDataSource;
    MemDataset2: TMemDataset;
    RESTClientPooler1: TRESTClientPooler;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    procedure CallBack1(lResponse: String; DWParams: TDWParams);
    procedure CallBack2(lResponse: String; DWParams: TDWParams);
    procedure ExecutarSql1(Sql: String; CallBack: TCallBack);
    procedure ExecutarSql2(Sql: String; CallBack: TCallBack);
    { Private declarations }
    procedure ListAlunos(Value : String);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$IFDEF LCL}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}


{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
begin
  ExecutarSql1(mComando1.Text {$IFDEF INTHREAD},@CallBack1{$ENDIF});

  ExecutarSql2(mComando2.Text{$IFDEF INTHREAD},@CallBack2{$ENDIF});
  DBGrid1.SetFocus;

end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  mComando1.Lines.Text:= 'SELECT FIRST 1 * FROM EMPLOYEE';
  mComando2.Lines.Text:= 'SELECT FIRST 1 * FROM EMPLOYEE';
  Button1.Click;

end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  mComando1.Lines.Text:= 'SELECT FIRST 5 * FROM EMPLOYEE';
  mComando2.Lines.Text:= 'SELECT * FROM EMPLOYEE';

end;

procedure TForm2.CallBack1(lResponse:String;DWParams  : TDWParams);
var
JSONValue : uDWJSONObject.TJSONValue;
sb:TStringList;
i:integer;
begin
  If lResponse <> '' Then
  Begin
   JSONValue := uDWJSONObject.TJSONValue.Create;
   Try
    DBGrid1.DataSource := Nil;
    DBGrid1.Columns.Clear;
    MemDataset1.Clear;   //corrige bug no TMemDataset
    JSONValue.WriteToDataset(dtFull, lResponse, MemDataset1);
    DBGrid1.DataSource := DataSource1;
   Finally
    JSONValue.Free;
   End;
  End;

  sb:=TStringList.Create;
  for i:=0 to DWParams.Count-1 do
    sb.Append(Format('"%s" = "%s" %s',[DWParams.Items[i].ParamName,DWParams.Items[i].Value,#13]));

   lbret1.Items.Add(Format('"%s" - %d',[{sb.ToString}DWParams.ItemsString['TESTPARAM'].Value,lbret1.Items.Count]));
  if cheParams.Checked then
    Showmessage(Format('Mostrando os Parametros %s %s',   [#13,sb.Text]));
  sb.Free;

end;

procedure TForm2.CallBack2(lResponse:String;DWParams  : TDWParams);
var
JSONValue : uDWJSONObject.TJSONValue;
sb:TStringList;
i:integer;
begin
  If lResponse <> '' Then
  Begin
   JSONValue := uDWJSONObject.TJSONValue.Create;
   Try
    DBGrid2.DataSource := Nil;
    DBGrid2.Columns.Clear;
    MemDataset2.Clear;   //corrige bug no TMemDataset
    JSONValue.WriteToDataset(dtFull, lResponse, MemDataset2);
    DBGrid2.DataSource := DataSource2;
   Finally
    JSONValue.Free;
   End;
  End;

  sb:=TStringList.Create;
  for i:=0 to DWParams.Count-1 do
    sb.Append(Format('"%s" = "%s" %s',[DWParams.Items[i].ParamName,DWParams.Items[i].Value,#13]));

   lbret2.Items.Add(Format('"%s" - %d',[{sb.ToString}DWParams.ItemsString['TESTPARAM'].Value,lbret1.Items.Count]));
  if cheParams.Checked then
    Showmessage(Format('Mostrando os Parametros %s %s',   [#13,sb.Text]));
  sb.Free;

end;

procedure TForm2.ExecutarSql1(Sql:String;CallBack:TCallBack);

Var
 lResponse: String;
 //SQL : String;
 JSONValue : TJSONValue;
 DWParams  : TDWParams;
 JSONParam : TJSONParam;
Begin
 {$IFDEF UNIX}
 DateSeparator    := '/';
 ShortDateFormat  := 'd/m/yy';
 LongDateFormat   := 'd mmmm yyyy';
 DecimalSeparator := ',';
 CurrencyDecimals := 2;
 {$ENDIF}
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;

 RESTClientPooler1.ThreadRequest :=  cheThread.Checked;

 SQL                        := mComando1.Text;
 DWParams                   := TDWParams.Create;
 DWParams.Encoding          := GetEncoding(RESTClientPooler1.Encoding);
 JSONParam                  := TJSONParam.Create(DWParams.Encoding);
 JSONParam.ParamName        := 'SQL';
 JSONParam.SetValue(SQL);
 DWParams.Add(JSONParam);
 JSONParam                  := TJSONParam.Create(DWParams.Encoding);
 JSONParam.ParamName        := 'TESTPARAM';
 JSONParam.SetValue('');
 DWParams.Add(JSONParam);
 If SQL <> '' Then
  Begin
   Try
    RESTClientPooler1.Host := eHost.Text;
    RESTClientPooler1.Port := StrToInt(ePort.Text);
    lResponse := RESTClientPooler1.SendEvent('ConsultaBanco', DWParams,sePOST,CallBack);

    if cheThread.Checked then exit;

    JSONValue := TJSONValue.Create;
    Try
     DBGrid1.DataSource := Nil;
     DBGrid1.Columns.Clear;
     MemDataset1.Clear;
     JSONValue.WriteToDataset(dtFull, lResponse, MemDataset1);
     DBGrid1.DataSource := DataSource1;
    Finally
     JSONValue.Free;
    End;
    Showmessage(Format('Mostrando o Parametro "TESTPARAM" Retornando o valor "%s" do Servidor',
                       [DWParams.ItemsString['TESTPARAM'].Value]));

   Except
   End;
  End;
End;
procedure TForm2.ExecutarSql2(Sql:String;CallBack:TCallBack);

Var
 lResponse: String;
 //SQL : String;
 JSONValue : TJSONValue;
 DWParams  : TDWParams;
 JSONParam : TJSONParam;
Begin
 {$IFDEF UNIX}
 DateSeparator    := '/';
 ShortDateFormat  := 'd/m/yy';
 LongDateFormat   := 'd mmmm yyyy';
 DecimalSeparator := ',';
 CurrencyDecimals := 2;
 {$ENDIF}
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 RESTClientPooler1.ThreadRequest :=  cheThread.Checked;
 SQL                        := mComando2.Text;
 DWParams                   := TDWParams.Create;
 DWParams.Encoding          := GetEncoding(RESTClientPooler1.Encoding);
 JSONParam                  := TJSONParam.Create(DWParams.Encoding);
 JSONParam.ParamName        := 'SQL';
 JSONParam.SetValue(SQL);
 DWParams.Add(JSONParam);
 JSONParam                  := TJSONParam.Create(DWParams.Encoding);
 JSONParam.ParamName        := 'TESTPARAM';
 JSONParam.SetValue('');
 DWParams.Add(JSONParam);
 If SQL <> '' Then
  Begin
   Try
    RESTClientPooler1.Host := eHost.Text;
    RESTClientPooler1.Port := StrToInt(ePort.Text);
    lResponse := RESTClientPooler1.SendEvent('ConsultaBanco', DWParams,sePOST,CallBack);

    if cheThread.Checked then exit;

    JSONValue := TJSONValue.Create;
    Try
     MemDataset2.Clear;
     DBGrid2.DataSource := Nil;
     DBGrid2.Columns.Clear;
     JSONValue.WriteToDataset(dtFull, lResponse, MemDataset2);
     DBGrid2.DataSource := DataSource1;
    Finally
     JSONValue.Free;
    End;
    Showmessage(Format('Mostrando o Parametro "TESTPARAM" Retornando o valor "%s" do Servidor',
                       [DWParams.ItemsString['TESTPARAM'].Value]));

   Except
   End;
  End;
end;
procedure TForm2.ListAlunos(Value: String);
begin

end;

end.
