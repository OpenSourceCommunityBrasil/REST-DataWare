UNIT formMain;

INTERFACE

USES
  DateUtils,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  UDWJSONObject,
  DB,
  Grids,
  DBGrids,
  URESTDWBase,
  UDWJSONTools,
  UDWConsts,
  Vcl.ExtCtrls,
  Vcl.Imaging.Pngimage,
  URESTDWPoolerDB,
  JvMemoryDataset,
  Vcl.ComCtrls,
  IdComponent, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uDWConstsData;

TYPE

  { TForm2 }

  TForm2 = CLASS(TForm)
    EHost: TEdit;
    EPort: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    DataSource1: TDataSource;
    Image1: TImage;
    Bevel1: TBevel;
    Label7: TLabel;
    EdPasswordDW: TEdit;
    Label6: TLabel;
    EdUserNameDW: TEdit;
    Label8: TLabel;
    Bevel2: TBevel;
    Label1: TLabel;
    Bevel3: TBevel;
    Label2: TLabel;
    DBGrid1: TDBGrid;
    MComando: TMemo;
    Button1: TButton;
    CheckBox1: TCheckBox;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    Button2: TButton;
    ProgressBar1: TProgressBar;
    Button3: TButton;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    PROCEDURE Button1Click(Sender: TObject);
    PROCEDURE Button2Click(Sender: TObject);
    PROCEDURE RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    PROCEDURE RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    PROCEDURE RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    PROCEDURE RESTDWClientSQL1GetDataError(Sucess: Boolean; CONST Error: STRING);
    PROCEDURE Button3Click(Sender: TObject);
    PROCEDURE RESTDWDataBase1Status(ASender: TObject; CONST AStatus: TIdStatus; CONST AStatusText: STRING);
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE RESTDWDataBase1Connection(Sucess: Boolean; CONST Error: STRING);
    PROCEDURE RESTDWDataBase1BeforeConnect(Sender: TComponent);
  PRIVATE
    { Private declarations }
    FBytesToTransfer: Int64;
  PUBLIC
    { Public declarations }
  END;

VAR
  Form2: TForm2;

IMPLEMENTATION

{$R *.dfm}

PROCEDURE TForm2.Button1Click(Sender: TObject);
VAR
  INICIO: TdateTime;
  FIM: TdateTime;
BEGIN
  RESTDWDataBase1.Close;
  RESTDWDataBase1.PoolerService := EHost.Text;
  RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
  RESTDWDataBase1.Login         := EdUserNameDW.Text;
  RESTDWDataBase1.Password      := EdPasswordDW.Text;
  RESTDWDataBase1.Compression   := CheckBox1.Checked;
  RESTDWDataBase1.Open;

  INICIO                  := Now;
  DataSource1.DataSet     := RESTDWClientSQL1;
  RESTDWClientSQL1.Active := False;
  RESTDWClientSQL1.SQL.Clear;
  RESTDWClientSQL1.SQL.Add(MComando.Text);
  TRY
    RESTDWClientSQL1.Open;
  EXCEPT
    ON E: Exception DO
    BEGIN
      RAISE Exception.Create('Erro ao executar a consulta: ' + sLineBreak + E.Message);
    END;
  END;
  FIM := Now;
  Showmessage(IntToStr(RESTDWClientSQL1.Recordcount) + ' registro(s) recebido(s) em ' + IntToStr(SecondsBetween(FIM, INICIO)) + ' segundos.');
//  RESTDWClientSQL1.Active := False;
END;

PROCEDURE TForm2.Button2Click(Sender: TObject);
VAR
  VError: STRING;
BEGIN
  RESTDWDataBase1.Close;
  RESTDWDataBase1.PoolerService := EHost.Text;
  RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
  RESTDWDataBase1.Login         := EdUserNameDW.Text;
  RESTDWDataBase1.Password      := EdPasswordDW.Text;
  RESTDWDataBase1.Compression   := CheckBox1.Checked;
  RESTDWDataBase1.Open;
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Clear;
  RESTDWClientSQL1.SQL.Add(MComando.Text);
  IF NOT RESTDWClientSQL1.ExecSQL(VError) THEN
    Application.MessageBox(PChar('Erro executando o comando ' + RESTDWClientSQL1.SQL.Text), 'Erro...', Mb_iconerror + Mb_ok)
  ELSE
    Application.MessageBox('Comando executado com sucesso...', 'Informação !!!', Mb_iconinformation + Mb_ok);
END;

PROCEDURE TForm2.Button3Click(Sender: TObject);
VAR
  Cliente: TRESTDWClientSQL;
  INICIO: TdateTime;
  FIM: TdateTime;
BEGIN
  RESTDWDataBase1.Close;
  RESTDWDataBase1.PoolerService := EHost.Text;
  RESTDWDataBase1.PoolerPort    := StrToInt(EPort.Text);
  RESTDWDataBase1.Login         := EdUserNameDW.Text;
  RESTDWDataBase1.Password      := EdPasswordDW.Text;
  RESTDWDataBase1.Compression   := CheckBox1.Checked;
  RESTDWDataBase1.Open;

  INICIO              := Now;
  Cliente             := TRESTDWClientSQL.Create(NIL);
  DataSource1.DataSet := Cliente;
  WITH Cliente DO
  BEGIN
    DataBase := RESTDWDataBase1;
    SQL.Add(MComando.Text);
    TRY
      Open;
    EXCEPT
      ON E: Exception DO
      BEGIN
        RAISE Exception.Create('Erro ao executar a consulta: ' + sLineBreak + E.Message);
      END;
    END;
    FIM := Now;
    Showmessage(IntToStr(Recordcount) + ' registro(s) recebido(s) em ' + IntToStr(SecondsBetween(FIM, INICIO)) + ' segundos.');
    Close;
  END;
  FreeAndNil(Cliente);
END;

PROCEDURE TForm2.FormCreate(Sender: TObject);
BEGIN
  Memo1.Lines.Clear;
END;

PROCEDURE TForm2.RESTDWClientSQL1GetDataError(Sucess: Boolean; CONST Error: STRING);
BEGIN
  Showmessage(Error);
END;

PROCEDURE TForm2.RESTDWDataBase1BeforeConnect(Sender: TComponent);
BEGIN
  Memo1.Lines.Add(' ');
  Memo1.Lines.Add('**********');
  Memo1.Lines.Add(' ');
END;

PROCEDURE TForm2.RESTDWDataBase1Connection(Sucess: Boolean; CONST Error: STRING);
BEGIN
  IF Sucess THEN
  BEGIN
    Memo1.Lines.Add(DateTimeToStr(Now) + ' - Database conectado com sucesso.');
  END
  ELSE
  BEGIN
    Memo1.Lines.Add(DateTimeToStr(Now) + ' - Falha de conexão ao Database: ' + Error);
  END;
END;

PROCEDURE TForm2.RESTDWDataBase1Status(ASender: TObject; CONST AStatus: TIdStatus; CONST AStatusText: STRING);
BEGIN
  CASE AStatus OF
    hsResolving:
      BEGIN
        StatusBar1.Panels[0].Text := 'hsResolving...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    hsConnecting:
      BEGIN
        StatusBar1.Panels[0].Text := 'hsConnecting...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    hsConnected:
      BEGIN
        StatusBar1.Panels[0].Text := 'hsConnected...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    hsDisconnecting:
      BEGIN
        StatusBar1.Panels[0].Text := 'hsDisconnecting...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    hsDisconnected:
      BEGIN
        StatusBar1.Panels[0].Text := 'hsDisconnected...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    hsStatusText:
      BEGIN
        StatusBar1.Panels[0].Text := 'hsStatusText...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    // These are to eliminate the TIdFTPStatus and the coresponding event These can be use din the other protocols to.
    ftpTransfer:
      BEGIN
        StatusBar1.Panels[0].Text := 'ftpTransfer...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    ftpReady:
      BEGIN
        StatusBar1.Panels[0].Text := 'ftpReady...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
    ftpAborted:
      BEGIN
        StatusBar1.Panels[0].Text := 'ftpAborted...';
        Memo1.Lines.Add(DateTimeToStr(Now) + ' - ' + AStatusText);
      END;
  END;
END;

PROCEDURE TForm2.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
BEGIN
  IF FBytesToTransfer = 0 THEN // No Update File
    Exit;
  ProgressBar1.Position := AWorkCount;
  ProgressBar1.Update;
END;

PROCEDURE TForm2.RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
BEGIN
  FBytesToTransfer      := AWorkCountMax;
  ProgressBar1.Max      := FBytesToTransfer;
  ProgressBar1.Position := 0;
  ProgressBar1.Update;
END;

PROCEDURE TForm2.RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
BEGIN
  ProgressBar1.Position := FBytesToTransfer;
  Application.ProcessMessages;

  FBytesToTransfer := 0;
END;

END.
