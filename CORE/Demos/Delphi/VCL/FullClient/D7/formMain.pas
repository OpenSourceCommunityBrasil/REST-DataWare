unit formMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uDWJSONObject, uLkJSON,
  DB, Grids, DBGrids, uRESTDWBase, uDWJSONTools, uDWConsts, idComponent,
  ExtCtrls, DBClient, uRESTDWPoolerDB, ComCtrls,
  uDWConstsData, uRESTDWServerEvents, DateUtils, uDWDataset, uDWAbout,
  ActnList, jpeg, ServerUtils;

type

  { TForm2 }

  TForm2 = class(TForm)
    labResult: TLabel;
    labSql: TLabel;
    labRepsonse: TLabel;
    labConexao: TLabel;
    labVersao: TLabel;
    DBGrid1: TDBGrid;
    mComando: TMemo;
    btnOpen: TButton;
    btnExecute: TButton;
    ProgressBar1: TProgressBar;
    btnGet: TButton;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    btnApply: TButton;
    btnMassive: TButton;
    btnServerTime: TButton;
    DataSource1: TDataSource;
    RESTDWDataBase1: TRESTDWDataBase;
    ActionList1: TActionList;
    DWClientEvents1: TDWClientEvents;
    RESTClientPooler1: TRESTClientPooler;
    DWClientEvents2: TDWClientEvents;
    paTopo: TPanel;
    Image1: TImage;
    labSistema: TLabel;
    paPortugues: TPanel;
    Image3: TImage;
    paEspanhol: TPanel;
    Image4: TImage;
    paIngles: TPanel;
    Image2: TImage;
    RESTDWClientSQL1: TRESTDWClientSQL;
    labHost: TLabel;
    labPorta: TLabel;
    labAcesso: TLabel;
    labWelcome: TLabel;
    labExtras: TLabel;
    Label11: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    cbxCompressao: TCheckBox;
    chkhttps: TCheckBox;
    eAccesstag: TEdit;
    eWelcomemessage: TEdit;
    cbBinaryRequest: TCheckBox;
    cbUseCripto: TCheckBox;
    cbBinaryCompatible: TCheckBox;
    cbAuthOptions: TComboBox;
    pBasicAuth: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    pTokenAuth: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    lTokenBegin: TLabel;
    lTokenEnd: TLabel;
    Label21: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    eTokenID: TEdit;
    EdPasswordAuth: TEdit;
    EdUserNameAuth: TEdit;
    Button2: TButton;
    eUpdateTableName: TEdit;
    Label1: TLabel;
    Button1: TButton;
    procedure RESTDWDataBase1WorkBegin(ASender: TObject;
      AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject;
      AWorkMode: TWorkMode);
    procedure RESTDWDataBase1BeforeConnect(Sender: TComponent);
    procedure RESTDWDataBase1Connection(Sucess: Boolean;
      const Error: String);
    procedure RESTDWDataBase1Status(ASender: TObject;
      const AStatus: TIdStatus; const AStatusText: String);
    procedure btnOpenClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnServerTimeClick(Sender: TObject);
    procedure btnMassiveClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure cbUseCriptoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbAuthOptionsChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
   vSecresString    : String;
   FBytesToTransfer : Int64;
   Procedure SetLoginOptions;
   Procedure GetLoginOptionsClientPooler;
   Function  GetSecret : String;
  public
    { Public declarations }
   Property SecresString : String Read vSecresString;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

Procedure TForm2.GetLoginOptionsClientPooler;
Begin
 If RESTClientPooler1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTClientPooler1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     eTokenID.Text       := TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Secrets;
    End
   Else
    Begin
     eTokenID.Text       := TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Secrets;
    End;
  End;
End;

Function  TForm2.GetSecret : String;
Begin
 Result := '';
 If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Result := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets
   Else
    Result := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets;
  End;
End;

procedure TForm2.RESTDWDataBase1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
 FBytesToTransfer      := AWorkCountMax;
 ProgressBar1.Max      := FBytesToTransfer;
 ProgressBar1.Position := 0;
end;

procedure TForm2.RESTDWDataBase1Work(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  If FBytesToTransfer = 0 Then // No Update File
   Exit;
  ProgressBar1.Position := AWorkCount;
end;

procedure TForm2.RESTDWDataBase1WorkEnd(ASender: TObject;
  AWorkMode: TWorkMode);
begin
 ProgressBar1.Position := FBytesToTransfer;
 FBytesToTransfer      := 0;
end;

procedure TForm2.RESTDWDataBase1BeforeConnect(Sender: TComponent);
begin
  Memo1.Lines.Add(' ');
  Memo1.Lines.Add('**********');
  Memo1.Lines.Add(' ');
end;

procedure TForm2.RESTDWDataBase1Connection(Sucess: Boolean;
  const Error: String);
begin
  IF Sucess THEN
  BEGIN
    Memo1.Lines.Add(DateTimeToStr(Now) + ' - Database conectado com sucesso.');
  END
  ELSE
  BEGIN
    Memo1.Lines.Add(DateTimeToStr(Now) + ' - Falha de conexão ao Database: ' + Error);
  END;
end;

procedure TForm2.RESTDWDataBase1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
 if Self = Nil then
  Exit;
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
        if StatusBar1.Panels.count > 0 then
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
end;

Procedure TForm2.SetLoginOptions;
Begin
  Case cbAuthOptions.ItemIndex Of
   0 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAONone;
   1 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
   2 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOBearer;
   3 : RESTDWDataBase1.AuthenticationOptions.AuthorizationOption := rdwAOToken;
  End;
 RESTClientPooler1.AuthenticationOptions.AuthorizationOption := RESTDWDataBase1.AuthenticationOptions.AuthorizationOption;
 If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType := rdwtRequest;
     TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
     TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).TokenRequestType := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType;
     TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
    End
   Else
    Begin
     TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType := rdwtRequest;
     TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
     TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).TokenRequestType := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).TokenRequestType;
     TRDWAuthOptionTokenClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
    End;
  End
 Else If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBasic Then
  Begin
   TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username := edUserNameDW.Text;
   TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password := edPasswordDW.Text;
   TRDWAuthOptionBasic(RESTClientPooler1.AuthenticationOptions.OptionParams).Username := TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username;
   TRDWAuthOptionBasic(RESTClientPooler1.AuthenticationOptions.OptionParams).Password := TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password;
  End;
End;

procedure TForm2.btnOpenClick(Sender: TObject);
Var
 INICIO,
 FIM        : TDateTime;
 I          : Integer;
 vKeyFields : TStringList;
Begin
 RESTDWDataBase1.Active            := False;
 If Not RESTDWDataBase1.Active Then
  Begin
   RESTDWDataBase1.PoolerService   := EHost.Text;
   RESTDWDataBase1.PoolerPort      := StrToInt(EPort.Text);
   SetLoginOptions;
   RESTDWDataBase1.Compression     := cbxCompressao.Checked;
   RESTDWDataBase1.AccessTag       := eAccesstag.Text;
   RESTDWDataBase1.WelcomeMessage  := eWelcomemessage.Text;
   If chkhttps.Checked Then
    RESTDWDataBase1.TypeRequest    := trHttps
   Else
    RESTDWDataBase1.TypeRequest    := trHttp;
  End;
 INICIO                            := Now;
 DataSource1.DataSet               := RESTDWClientSQL1;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add(MComando.Text);
 RESTDWClientSQL1.UpdateTableName  := Trim(eUpdateTableName.Text);
 Try
  RESTDWClientSQL1.Active          := True;
 Except
  On E: Exception Do
   Begin
    Raise Exception.Create('Erro ao executar a consulta: ' + sLineBreak + E.Message);
   End;
 End;
 FIM := Now;
 EHost.Text            := RESTDWDataBase1.PoolerService;
 EPort.Text            := IntToStr(RESTDWDataBase1.PoolerPort);
 cbxCompressao.Checked := RESTDWDataBase1.Compression;
 eAccesstag.Text       := RESTDWDataBase1.AccessTag;
 eWelcomemessage.Text  := RESTDWDataBase1.WelcomeMessage;
 If RESTDWClientSQL1.FindField('FULL_NAME') <> Nil Then
  RESTDWClientSQL1.FindField('FULL_NAME').ProviderFlags := [];
 If RESTDWClientSQL1.FindField('UF') <> Nil Then
  RESTDWClientSQL1.FindField('UF').ProviderFlags       := [];
 If RESTDWClientSQL1.Active Then
  Showmessage(IntToStr(RESTDWClientSQL1.Recordcount) + ' registro(s) recebido(s) em ' + IntToStr(MilliSecondsBetween(FIM, INICIO)) + ' Milis.');
End;

procedure TForm2.btnApplyClick(Sender: TObject);
Var
 vError : String;
begin
 If Not RESTDWClientSQL1.ApplyUpdates(vError) Then
  MessageDlg(vError, mtError, [mbOK], 0);
end;

procedure TForm2.btnServerTimeClick(Sender: TObject);
Var
 dwParams      : TDWParams;
 vNativeResult,
 vErrorMessage : String;
Begin
 RESTClientPooler1.Host            := EHost.Text;
 RESTClientPooler1.Port            := StrToInt(EPort.Text);
 SetLoginOptions;
 RESTClientPooler1.DataCompression := cbxCompressao.Checked;
 RESTClientPooler1.AccessTag       := eAccesstag.Text;
 RESTClientPooler1.WelcomeMessage  := eWelcomemessage.Text;
 RESTClientPooler1.BinaryRequest   := cbBinaryRequest.Checked;
 If chkhttps.Checked then
  RESTClientPooler1.TypeRequest    := trHttps
 Else
  RESTClientPooler1.TypeRequest    := trHttp;
 DWClientEvents1.CreateDWParams('servertime', dwParams);
 DWClientEvents1.SendEvent('servertime', dwParams, vErrorMessage, vNativeResult);
 If vErrorMessage = '' Then
  Begin
   GetLoginOptionsClientPooler;
   If dwParams.ItemsString['result'] <> Nil Then
    Begin
     If dwParams.ItemsString['result'].AsString <> '' Then
      Showmessage('Server Date/Time is : ' + dwParams.ItemsString['result'].AsString)
     Else
      Showmessage(vErrorMessage);
    End
   Else
    Begin
     If vNativeResult <> '' Then
      Begin
       If vNativeResult <> '' Then
        Showmessage(vNativeResult)
       Else
        Showmessage(vErrorMessage);
      End;
    End;
  End
 Else
  Showmessage(vErrorMessage);
 dwParams.Free;
End;

procedure TForm2.btnMassiveClick(Sender: TObject);
begin
 If RESTDWClientSQL1.MassiveCount > 0 Then
  Showmessage(RESTDWClientSQL1.MassiveToJSON);
end;

procedure TForm2.btnGetClick(Sender: TObject);
Var
 dwParams       : TDWParams;
 vErrorMessage,
 vNativeResult  : String;
Begin
 RESTClientPooler1.Host            := EHost.Text;
 RESTClientPooler1.Port            := StrToInt(EPort.Text);
 SetLoginOptions;
 RESTClientPooler1.DataCompression := cbxCompressao.Checked;
 RESTClientPooler1.AccessTag       := eAccesstag.Text;
 RESTClientPooler1.WelcomeMessage  := eWelcomemessage.Text;
 If chkhttps.Checked then
  RESTClientPooler1.TypeRequest    := trHttps
 Else
  RESTClientPooler1.TypeRequest    := trHttp;
 DWClientEvents1.CreateDWParams('getemployee', dwParams);
 DWClientEvents1.SendEvent('getemployee', dwParams, vErrorMessage, vNativeResult);
 If RESTClientPooler1.BinaryRequest then
  Begin
   If vErrorMessage <> '' Then
    Showmessage(vErrorMessage)
   Else
    Begin
     GetLoginOptionsClientPooler;
     Showmessage(dwParams.ItemsString['result'].AsString);
    End;
  End
 Else
  Begin
   If vNativeResult <> '' Then
    Begin
     GetLoginOptionsClientPooler;
     Showmessage(vNativeResult);
    End
   Else
    Showmessage(vErrorMessage);
  End;
 dwParams.Free;
End;

procedure TForm2.btnExecuteClick(Sender: TObject);
VAR
  VError: STRING;
BEGIN
  RESTDWDataBase1.Close;
  SetLoginOptions;
  RESTDWDataBase1.PoolerService  := EHost.Text;
  RESTDWDataBase1.PoolerPort     := StrToInt(EPort.Text);
  TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Username := EdUserNameDW.Text;
  TRDWAuthOptionBasic(RESTDWDataBase1.AuthenticationOptions.OptionParams).Password := EdPasswordDW.Text;
  RESTDWDataBase1.Compression    := cbxCompressao.Checked;
  RESTDWDataBase1.AccessTag      := eAccesstag.Text;
  RESTDWDataBase1.WelcomeMessage := eWelcomemessage.Text;
  If chkhttps.Checked Then
   RESTDWDataBase1.TypeRequest   := trHttps
  Else
   RESTDWDataBase1.TypeRequest   := trHttp;
  RESTDWDataBase1.Open;
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Clear;
  RESTDWClientSQL1.SQL.Add(MComando.Text);
  IF NOT RESTDWClientSQL1.ExecSQL(VError) THEN
    Application.MessageBox(PChar('Erro executando o comando ' + RESTDWClientSQL1.SQL.Text), 'Erro...', Mb_iconerror + Mb_ok)
  ELSE
    Application.MessageBox('Comando executado com sucesso...', 'Informação !!!', Mb_iconinformation + Mb_ok);
END;

procedure TForm2.cbUseCriptoClick(Sender: TObject);
begin
 RESTDWDataBase1.CriptOptions.Use   := cbUseCripto.Checked;
 RESTClientPooler1.CriptOptions.Use := RESTDWDataBase1.CriptOptions.Use;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
 labVersao.Caption := DWVERSAO;
end;

procedure TForm2.cbAuthOptionsChange(Sender: TObject);
begin
 pTokenAuth.Visible := cbAuthOptions.ItemIndex > 1;
 pBasicAuth.Visible := cbAuthOptions.ItemIndex = 1;
end;

procedure TForm2.Button1Click(Sender: TObject);
Var
 vErrorMessage : String;
 dwParams      : TdwParams;
Begin
 dwParams      := Nil;
 RESTClientPooler1.Host            := EHost.Text;
 RESTClientPooler1.Port            := StrToInt(EPort.Text);
 SetLoginOptions;
 RESTClientPooler1.DataCompression := cbxCompressao.Checked;
 RESTClientPooler1.AccessTag       := eAccesstag.Text;
 RESTClientPooler1.WelcomeMessage  := eWelcomemessage.Text;
 If chkhttps.Checked then
  RESTClientPooler1.TypeRequest    := trHttps
 Else
  RESTClientPooler1.TypeRequest    := trHttp;
 DWClientEvents1.SendEvent('assyncevent', dwParams, vErrorMessage, sePOST, True);
 If vErrorMessage = '' Then
  Begin
   GetLoginOptionsClientPooler;
   Showmessage('Assyncevent Executed...');
  End
 Else
  Showmessage(vErrorMessage);
End;

end.
