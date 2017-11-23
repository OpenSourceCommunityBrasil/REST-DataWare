unit formMain;

interface

{$DEFINE INTHREAD}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uDWJSONObject, System.JSON,
  DB, Grids, DBGrids, uDWJSONTools, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  JvMemoryDataset, uRESTDWBase, uDWConsts, uDWConstsData;


Type
  { TForm2 }
  TForm2 = class(TForm)
    eHost: TEdit;
    ePort: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    DataSource1: TDataSource;
    RESTClientPooler1: TRESTClientPooler;
    Bevel1: TBevel;
    Label7: TLabel;
    edPasswordDW: TEdit;
    Label6: TLabel;
    edUserNameDW: TEdit;
    Label8: TLabel;
    Bevel2: TBevel;
    Label1: TLabel;
    Bevel3: TBevel;
    Label2: TLabel;
    DBGrid1: TDBGrid;
    mComando1: TMemo;
    Button1: TButton;
    DBGrid2: TDBGrid;
    mComando2: TMemo;
    DataSource2: TDataSource;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    lbret1: TListBox;
    lbret2: TListBox;
    Label3: TLabel;
    cheParams: TCheckBox;
    Bevel4: TBevel;
    Label9: TLabel;
    Image1: TImage;
    cheThread: TCheckBox;

    procedure btnGetClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure ListAlunos(Value : String);
  public
    { Public declarations }
    MemDataset1,
    MemDataset2: TJvMemoryData;
    Procedure CallBack1(lResponse:String;DWParams  : TDWParams);
    Procedure CallBack2(lResponse:String;DWParams  : TDWParams);
    procedure CallBackListAlunos(lResponse : String;DWParams  : TDWParams);
    procedure ExecutarSql(Sql:String {$IFDEF INTHREAD};CallBack:TCallBack {$ENDIF});

  end;

var
  Form2: TForm2;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

procedure TForm2.CallBack1(lResponse:String;DWParams  : TDWParams);
var
JSONValue : uDWJSONObject.TJSONValue;
sb:TStringBuilder;
i:integer;
begin
  If lResponse <> '' Then
  Begin
   JSONValue := uDWJSONObject.TJSONValue.Create;
   Try
    JSONValue.WriteToDataset(dtFull, lResponse, MemDataset1);
   Finally
    JSONValue.Free;
   End;
  End;

  sb:=TStringBuilder.Create;
  for i:=0 to DWParams.Count-1 do
    sb.Append(Format('"%s" = "%s" %s',[DWParams.Items[i].ParamName,DWParams.Items[i].Value,#13]));

   lbret1.Items.Add(Format('"%s" - %d',[{sb.ToString}DWParams.ItemsString['TESTPARAM'].Value,lbret1.Items.Count]));
  if cheParams.Checked then
    Showmessage(Format('Mostrando os Parametros %s %s',   [#13,sb.ToString]));
  sb.Free;

end;

procedure TForm2.CallBack2(lResponse:String;DWParams  : TDWParams);
var
JSONValue : uDWJSONObject.TJSONValue;
sb:TStringBuilder;
i:integer;
begin
  If lResponse <> '' Then
  Begin
   JSONValue := uDWJSONObject.TJSONValue.Create;
   Try
    JSONValue.WriteToDataset(dtFull, lResponse, MemDataset2);
   Finally
    JSONValue.Free;
   End;
  End;

  sb:=TStringBuilder.Create;
  for i:=0 to DWParams.Count-1 do
    sb.Append(Format('"%s" = "%s" %s',[DWParams.Items[i].ParamName,DWParams.Items[i].Value,#13]));

  if cheParams.Checked then
    Showmessage(Format('Mostrando os Parametros %s %s',  [#13,sb.ToString]));
   lbret2.Items.Add(Format('"%s" - %d',[{sb.ToString}DWParams.ItemsString['TESTPARAM'].Value,lbret2.Items.Count]));

  sb.Free;


//   lbret2.Items.Add(Format('"%s" - %d',[DWParams.ItemsString['TESTPARAM'].Value,lbret2.Items.Count]));
   {TODO Cristiano Barbosa - Destroi parametros informados}
   {For I := Params.Count -1 downto 0 Do
     Params.Items[I].Free ;}
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  ExecutarSql(mComando1.Text {$IFDEF INTHREAD},CallBack1{$ENDIF});

  ExecutarSql(mComando2.Text{$IFDEF INTHREAD},CallBack2{$ENDIF});
  DBGrid1.SetFocus;
end;

procedure TForm2.ExecutarSql(Sql:String{$IFDEF INTHREAD};CallBack:TCallBack{$ENDIF});
Var
 lResponse: String;
//QL : String;
 JSONValue : uDWJSONObject.TJSONValue;
 DWParams  : TDWParams;
 JSONParam : TJSONParam;
 i:integer;
 sb:TStringBuilder;
Begin
 If trim(SQL) = '' Then exit;

 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 RESTClientPooler1.ThreadRequest :=  cheThread.Checked;

 DWParams            := TDWParams.Create;
 DWParams.Encoding   := GetEncoding(RESTClientPooler1.Encoding);
 JSONParam           := TJSONParam.Create(DWParams.Encoding);
 JSONParam.ParamName := 'SQL';

 JSONParam.SetValue(SQL);
 DWParams.Add(JSONParam);

 JSONParam           := TJSONParam.Create(DWParams.Encoding);
 JSONParam.ParamName := 'TESTPARAM';
 JSONParam.SetValue('');
 DWParams.Add(JSONParam);

 lResponse := RESTClientPooler1.SendEvent('ConsultaBanco', DWParams {$IFDEF INTHREAD}, sePOST, CallBack {$ENDIF});// {$IFDEF INTHREAD},CallBack {$ENDIF});

 if not cheThread.Checked then
 begin
   If lResponse <> '' Then
        Begin
         JSONValue := uDWJSONObject.TJSONValue.Create;
         Try
          JSONValue.WriteToDataset(dtFull, lResponse, MemDataset1);
         Finally
          JSONValue.Free;
         End;
        End;

    sb:=TStringBuilder.Create;
    for i:=0 to DWParams.Count-1 do
      sb.Append(Format('"%s" = "%s" %s',[DWParams.Items[i].ParamName,DWParams.Items[i].Value,#13]));

    Showmessage(Format('Mostrando os Parametros %s %s',       [#13,sb.ToString]));
    sb.Free;
 end ;

 freeAndnil(DWParams);
End;

procedure TForm2.Button2Click(Sender: TObject);
begin
  mComando1.Lines.Text:= 'SELECT FIRST 1 * FROM EMPLOYEE';
  mComando2.Lines.Text:= 'SELECT FIRST 1 * FROM EMPLOYEE';
  Button1.Click;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  mComando1.Lines.Text:= 'SELECT FIRST 5 * FROM EMPLOYEE';
  mComando2.Lines.Text:= 'SELECT   * FROM EMPLOYEE';

end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  MemDataset1:= TJvMemoryData.Create(SELF);
  DataSource1.DataSet:=MemDataset1;

  MemDataset2:= TJvMemoryData.Create(SELF);
  DataSource2.DataSet:=MemDataset2;

  //ehost.Text:='achadoouperdido.com.br';
  mComando1.Lines.Text:='SELECT FIRST 1 * FROM EMPLOYEE';
  mComando2.Lines.Text:='SELECT FIRST 1 * FROM EMPLOYEE';
end;

procedure TForm2.CallBackListAlunos(lResponse : String;DWParams  : TDWParams);
Var
 s:  String;
 JSonValue    : TJSonValue;
 I            : Integer;
begin
 Try

 Finally
  If lResponse <> '' Then
   Begin
    JSonValue   := TJsonObject.ParseJSONValue(lResponse);
    JSonValue   := (JsonValue as TJSONObject).Get('Alunos').JSONValue;
    MemDataset1.DisableControls;
    MemDataset1.Close;
    //MemDataset1.CreateDataSet;
    with MemDataset1 do
    begin
     MemDataset1.FieldDefs.Add('Alunos',ftString,100);
     MemDataset1.FieldDefs.Create(self);
    end;

    MemDataset1.Open;
    If (JSONValue is TJSONArray) Then
     Begin
      For I := 0 To (JSONValue as TJSONArray).Count -1 Do
       Begin
        MemDataset1.Append;
        s := ((JSONValue as TJSONArray).Items[I] as TJSonObject).Get('NomeAluno').JSONValue.Value;
        MemDataset1.FieldByName('Alunos').AsString := s;
        MemDataset1.Post;
       End;
     End;
    MemDataset1.EnableControls;
    MemDataset1.First;
   End;
 end;
end;

procedure TForm2.ListAlunos(Value : String);
Var
 s, lResponse : String;
 JSonValue    : TJSonValue;
 I            : Integer;
begin
 Try
  Try
   lResponse := RESTClientPooler1.SendEvent('GetListaAlunos/' + Value{$IFDEF INTHREAD},CallBackListAlunos {$ENDIF});
  Except
   Exit;
  End;
 Finally

 end;

end;


procedure TForm2.btnGetClick(Sender: TObject);
Begin

End;
{
procedure TForm2.btnPostClick(Sender: TObject);
Var
 eventData,
 lResponse,
 Aluno,
 NomeNovo  : String;
 RBody     : TStringList;
 SendEvent : TSendEvent;
Begin
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 RBody := TStringList.Create;
 RBody.Add('json');
 Aluno := InputBox('Rest Client', 'Nome do aluno', '');
 If Aluno <> '' Then
  Begin
   NomeNovo := InputBox('Rest Client', 'Alterar Nome para', '');
   If NomeNovo <> '' Then
    Begin
     Try
      RESTClientPooler1.Host := eHost.Text;
      RESTClientPooler1.Port := StrToInt(ePort.Text);
      eventData              := 'AtualizaAluno/' + Aluno + '/' + NomeNovo;
      SendEvent              := sePost;
      lResponse              := RESTClientPooler1.SendEvent(eventData, RBody, SendEvent);
      ListAlunos(lResponse);
     Except
     End;
    End;
  End;
 RBody.Free;
End;

procedure TForm2.btnPutClick(Sender: TObject);
Var
 lResponse,
 Aluno : String;
 RBody : TStringList;
Begin
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 RBody := TStringList.Create;
 RBody.Add('json');
 Aluno := InputBox('Rest Client', 'Nome do aluno', '');
 If Aluno <> '' Then
  Begin
   Try
    RESTClientPooler1.Host := eHost.Text;
    RESTClientPooler1.Port := StrToInt(ePort.Text);
    lResponse := RESTClientPooler1.SendEvent('InsereAluno/' + Aluno, RBody, sePut);
    ListAlunos(lResponse);
   Except
   End;
  End;
 RBody.Free;
End;


procedure TForm2.btnDeleteClick(Sender: TObject);
Var
 lResponse,
 Aluno : String;
Begin
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 Aluno := InputBox('Rest Client', 'Nome do aluno', '');
 If Aluno <> '' Then
  Begin
   Try
    RESTClientPooler1.Host := eHost.Text;
    RESTClientPooler1.Port := StrToInt(ePort.Text);
    lResponse       := RESTClientPooler1.SendEvent('ExcluiAluno/' + Aluno, Nil, seDelete);
    ListAlunos(lResponse);
   Except
   End;
  End;
End;

procedure TForm2.btnIDHttpGetTestClick(Sender: TObject);
Var
 Response : String;
Begin
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 Memo2.Lines.Clear;
 Try
  // Passando parâmetros no formato antigo (QueryString)
  RESTClientPooler1.Host := eHost.Text;
  RESTClientPooler1.Port := StrToInt(ePort.Text);
  Response        := RESTClientPooler1.SendEvent('ConsultaAluno?Nome=AlunoTeste');
  Memo2.Lines.Add(Response);
  // Passando parâmetros no formato novo (REST URL)
  Response        := RESTClientPooler1.SendEvent('ConsultaAluno/AlunoTeste');
  Memo2.Lines.Add(Response);
  ListAlunos(Response);
 Finally
 End;
End;

procedure TForm2.btnIDHttpPostTesteClick(Sender: TObject);
Var
 Response : String;
 lParams  : TStringList;
Begin
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 Memo2.Lines.Clear;
 lParams := TStringList.Create;
 Try
  //Aqui o parâmetro é passado no header da requisição e não na URL
  //da mesma forma que todos os navegadores o fazem
  //ou seja é possivel que voce tenha um client em HTML puro
  //dando POST no navegador num WebService em Lazarus
  lParams.Add('NomeAtual=Fulano');
  lParams.Add('NomeNovo=Cicrano');
  RESTClientPooler1.Host := eHost.Text;
  RESTClientPooler1.Port := StrToInt(ePort.Text);
  Response        := RESTClientPooler1.SendEvent('AtualizaAluno', lParams, sePOST);
  Memo2.Lines.Add(Response);
  ListAlunos(Response);
 Finally
  lParams.Free;
 End;
End;
}
end.
