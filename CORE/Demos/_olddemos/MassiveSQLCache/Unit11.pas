unit Unit11;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, uRESTDWPoolerDB, uDWAbout, uDWMassiveBuffer, uDWConstsData,
  uDWConstsCharSet, ServerUtils;

type
  TForm11 = class(TForm)
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    Label7: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Image1: TImage;
    eHost: TEdit;
    ePort: TEdit;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    CheckBox1: TCheckBox;
    chkhttps: TCheckBox;
    DWMassiveSQLCache1: TDWMassiveSQLCache;
    RESTDWDataBase1: TRESTDWDataBase;
    mComando: TMemo;
    labSql: TLabel;
    btnExecute: TButton;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Memo2: TMemo;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Image2: TImage;
    Label3: TLabel;
    Label9: TLabel;
    Memo3: TMemo;
    procedure btnExecuteClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form11: TForm11;

implementation

{$R *.dfm}

procedure TForm11.btnExecuteClick(Sender: TObject);
Var
 vError        : Boolean;
 vMessageError : String;
begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := EHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
 //Adicionar no Uses (serverutils.pas)
 //RESTDWDataBase1.Login         := EdUserNameDW.Text;
 //RESTDWDataBase1.Password      := EdPasswordDW.Text;
 RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
 TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username:=EdUserNameDW.Text;
 TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password:=EdPasswordDW.Text;

 RESTDWDataBase1.Compression   := CheckBox1.Checked;

 //Adicionar no Uses (uDWConstsCharSet)
 If chkhttps.Checked then
   RESTDWDataBase1.TypeRequest  := TTyperequest.trHttps
 Else
  RESTDWDataBase1.TypeRequest  := TTyperequest.trHttp;

 RESTDWDataBase1.ProcessMassiveSQLCache(DWMassiveSQLCache1, vError, vMessageError);
 If vError Then
  Showmessage(vMessageError)
 Else
  Showmessage('Operação executada com sucesso...');
end;

procedure TForm11.Button1Click(Sender: TObject);
Var
 vEmpNo,
 vFirstName,
 vLastname   : String;
 vMassiveCacheSQLValue : TDWMassiveCacheSQLValue;
begin
 vEmpNo := InputBox('Insira o Empno', 'Insira o empno', '');
 If trim(vEmpNo) = '' Then
  Exit;
 vFirstName := InputBox('Insira o Primeiro Nome', 'Insira o Nome', 'Primeiro');
 If Trim(vFirstName) = '' Then
  Exit;
 vLastname := InputBox('Insira o Primeiro Nome', 'Insira o Nome', 'Segundo');
 If Trim(vLastname) = '' Then
  Exit;
 vMassiveCacheSQLValue := TDWMassiveCacheSQLValue(DWMassiveSQLCache1.CachedList.Add);
 vMassiveCacheSQLValue.SQL.Text := mComando.Text;
 vMassiveCacheSQLValue.ParamByName('EMP_NO').AsInteger    := StrToInt(vEmpNo);
 vMassiveCacheSQLValue.ParamByName('FIRST_NAME').AsString := vFirstName;
 vMassiveCacheSQLValue.ParamByName('LAST_NAME').AsString  := vLastname;
end;

procedure TForm11.Button2Click(Sender: TObject);
Var
 vMassiveCacheSQLValue : TDWMassiveCacheSQLValue;
begin
    if trim(memo1.Text) = '' then
       exit;


    vMassiveCacheSQLValue := TDWMassiveCacheSQLValue(DWMassiveSQLCache1.CachedList.Add);
    vMassiveCacheSQLValue.SQL.Text := memo1.Text;

    memo2.Lines.Add( memo1.Text );
    memo2.Lines.Add('-----------------------------------');

end;

procedure TForm11.Button3Click(Sender: TObject);
Var
 vError        : Boolean;
 vMessageError : String;
begin

 if trim(memo2.Text) = '' then
    exit;

 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := EHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
 //RESTDWDataBase1.Login         := EdUserNameDW.Text;
 //RESTDWDataBase1.Password      := EdPasswordDW.Text;

 //Adicionar no Uses (serverutils.pas)
 RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
 TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username:=EdUserNameDW.Text;
 TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password:=EdPasswordDW.Text;

 RESTDWDataBase1.Compression   := CheckBox1.Checked;

 //Adicionar no Uses (uDWConstsCharSet)
 If chkhttps.Checked then
   RESTDWDataBase1.TypeRequest  := TTyperequest.trHttps
 Else
  RESTDWDataBase1.TypeRequest  := TTyperequest.trHttp;


 RESTDWDataBase1.ProcessMassiveSQLCache(DWMassiveSQLCache1, vError, vMessageError);

 If vError Then
 begin
  Showmessage(vMessageError);
  if MessageDlg('Deseja limpar a lista de comandos ou você acha que dá pra salvar alguma coisa? rsrsrs',mtWarning,[mbno,mbyes],0) = mryes then
  begin
     memo2.Lines.Clear;
     DWMassiveSQLCache1.Clear;
  end;
 end
 Else
 begin
      Showmessage('Operação executada com sucesso...');
      memo2.Lines.Clear;
      DWMassiveSQLCache1.Clear;
 end;

end;

end.
