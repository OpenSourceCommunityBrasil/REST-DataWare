unit uJSONDatasetSample;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDWJSONObject, Vcl.Bind.GenData,
  Data.Bind.Controls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Bind.Navigator, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZAbstractConnection,
  ZConnection, Vcl.StdCtrls, Vcl.Imaging.pngimage,
   IniFiles, uSock;

type
  TForm1 = class(TForm)
    DataSource1: TDataSource;
    Server_FDConnection: TZConnection;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Bevel2: TBevel;
    Label12: TLabel;
    Label14: TLabel;
    Image1: TImage;
    Label5: TLabel;
    cbAdaptadores: TComboBox;
    edPortaBD: TEdit;
    edUserNameBD: TEdit;
    edPasswordBD: TEdit;
    edPasta: TEdit;
    edBD: TEdit;
    Memo1: TMemo;
    ButtonStart: TButton;
    FDQuery1: TZQuery;
    FDQuery1JOB_CODE: TWideStringField;
    FDQuery1JOB_GRADE: TSmallintField;
    FDQuery1JOB_COUNTRY: TWideStringField;
    FDQuery1JOB_TITLE: TWideStringField;
    FDQuery1MIN_SALARY: TFloatField;
    FDQuery1MAX_SALARY: TFloatField;
    FDQuery1JOB_REQUIREMENT: TWideMemoField;
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
    procedure cbAdaptadoresChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonStartClick(Sender: TObject);
  private
    { Private declarations }
   FCfgName,
   vDatabaseIP,
   vDatabaseName : String;
   JSONValue     : TJSONValue;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ButtonStartClick(Sender: TObject);
Var
 ini       : TIniFile;
Begin
 If FileExists(FCfgName) Then
  DeleteFile(FCfgName);
 ini       := TIniFile.Create(FCfgName);
 ini.WriteString('BancoDados', 'Servidor',  cbAdaptadores.Text);//  '127.0.0.1');
 ini.WriteString('BancoDados', 'BD',        edBD.Text);
 ini.WriteString('BancoDados', 'Pasta',     edPasta.Text);
 ini.WriteString('BancoDados', 'PortaDB',   edPortaBD.Text);
 ini.WriteString('BancoDados', 'UsuarioBD', edUserNameBD.Text);
 ini.WriteString('BancoDados', 'SenhaBD',   edPasswordBD.Text);
 ini.Free;
 Server_FDConnection.Connected := True;
 FDQuery1.Open;
 JSONValue.LoadFromDataset('employee', FDQuery1);
 Memo1.Lines.Add(JSONValue.Value);
End;

procedure TForm1.cbAdaptadoresChange(Sender: TObject);
begin
 vDatabaseIP := Trim(Copy(cbAdaptadores.Text, Pos('-' , cbAdaptadores.Text ) + 1 , 100));
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 JSONValue.Free;
 Release;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 FCfgName := StringReplace(ExtractFileName(ParamStr(0) ), '.exe' , '' , [rfReplaceAll]);
 FCfgName := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini' ;
 JSONValue := TJSONValue.Create;
end;

procedure TForm1.FormShow(Sender: TObject);
Var
 porta_fb,
 porta_dw,
 servidor,
 database,
 pasta,
 usuarioDW,
 senhaDW,
 usuarioBD,
 senhaBD           : String;
 ini               : TIniFile;
 vTag, i           : Integer;
 aNetInterfaceList : tNetworkInterfaceList;
 Function ServerIpIndex(Items : TStrings; ChooseIP : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Items.Count -1 Do
   Begin
    If Pos(ChooseIP, Items[I]) > 0 Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
 vTag := 0;
 If (GetNetworkInterfaces(aNetInterfaceList)) THen
  Begin
   cbAdaptadores.Items.Clear;
   For i := 0 to High (aNetInterfaceList) do
    Begin
     cbAdaptadores.Items.Add( 'Placa #' + IntToStr( i ) + ' - ' + aNetInterfaceList[i].AddrIP);
     If ( i <= 1 ) or ( Pos( '127.0.0.1' , aNetInterfaceList[i].AddrIP ) > 0 ) then
      Begin
       vDatabaseIP := aNetInterfaceList[i].AddrIP;
       vTag        := 1;
      End;
    End;
   cbAdaptadores.ItemIndex := vTag;
  End;
 ini                     := TIniFile.Create(FCfgName);
 cbAdaptadores.ItemIndex := ServerIpIndex(cbAdaptadores.Items,
                            ini.ReadString('BancoDados', 'Servidor',  '127.0.0.1'));
 edBD.Text               := ini.ReadString('BancoDados', 'BD',        'EMPLOYEE.FDB');
 edPasta.Text            := ini.ReadString('BancoDados', 'Pasta',     ExtractFilePath(ParamSTR(0)) + '..\');
 edPortaBD.Text          := ini.ReadString('BancoDados', 'PortaBD',   '3050');
 edUserNameBD.Text       := ini.ReadString('BancoDados', 'UsuarioBD', 'SYSDBA');
 edPasswordBD.Text       := ini.ReadString('BancoDados', 'SenhaBD',   'masterkey');
 ini.Free;
End;

procedure TForm1.Server_FDConnectionBeforeConnect(Sender: TObject);
Var
 porta_BD,
 servidor,
 database,
 pasta,
 usuario_BD,
 senha_BD      : String;
Begin
 servidor      := vDatabaseIP;
 database      := edBD.Text;
 pasta         := IncludeTrailingPathDelimiter(edPasta.Text);
 porta_BD      := edPortaBD.Text;
 usuario_BD    := edUserNameBD.Text;
 senha_BD      := edPasswordBD.Text;
 vDatabaseName := pasta + database;

 with TZConnection(Sender) do
 begin
    //HostName := Servidor;
    Port := strtoint(porta_BD);
    Database :=Servidor+'/'+porta_BD+':'+vDatabaseName;
    User := usuario_BD;
    Password := senha_BD;
    Protocol := 'firebird-2.5';
    Port:=strtoint(porta_BD);
    LibraryLocation:='C:\Windows\SysWOW64\fbclient.dll';
 end;

{ TFDConnection(Sender).Params.Clear;
 TFDConnection(Sender).Params.Add('DriverID=FB');
 TFDConnection(Sender).Params.Add('Server='    + Servidor);
 TFDConnection(Sender).Params.Add('Port='      + porta_BD);
 TFDConnection(Sender).Params.Add('Database='  + vDatabaseName);
 TFDConnection(Sender).Params.Add('User_Name=' + usuario_BD);
 TFDConnection(Sender).Params.Add('Password='  + senha_BD);
 TFDConnection(Sender).Params.Add('Protocol=TCPIP');
 }
 //Server_FDConnection.Params.Add('CharacterSet=ISO8859_1');
 //TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
end;

end.
