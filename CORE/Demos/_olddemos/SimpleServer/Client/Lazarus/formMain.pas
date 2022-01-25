unit formMain;

interface

uses
  Lcl, uDWJSON, uDWJSONObject, DateUtils, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, fpjson, DB, sqldb, DBGrids, ExtCtrls,
  ComCtrls, ActnList, uRESTDWPoolerDB, uRESTDWServerEvents, uRESTDWBase,
  uDWDataset, IdComponent, uDWConstsData, LConvEncoding, ServerUtils, uDWConstsCharset;

type

  { TForm2 }

  TForm2 = class(TForm)
    ActionList1: TActionList;
    btnApply: TButton;
    btnExecute: TButton;
    btnGet: TButton;
    btnMassive: TButton;
    btnOpen: TButton;
    btnServerTime: TButton;
    Button1: TButton;
    Button2: TButton;
    cbAuthOptions: TComboBox;
    cbBinaryCompatible: TCheckBox;
    cbBinaryRequest: TCheckBox;
    cbUseCripto: TCheckBox;
    cbxCompressao: TCheckBox;
    chkhttps: TCheckBox;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DWClientEvents1: TDWClientEvents;
    eAccesstag: TEdit;
    EdPasswordAuth: TEdit;
    edPasswordDW: TEdit;
    EdUserNameAuth: TEdit;
    edUserNameDW: TEdit;
    eHost: TEdit;
    ePort: TEdit;
    eTokenID: TEdit;
    eUpdateTableName: TEdit;
    eWelcomemessage: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    labAcesso: TLabel;
    labConexao: TLabel;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label21: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    labExtras: TLabel;
    labHost: TLabel;
    labPorta: TLabel;
    labRepsonse: TLabel;
    labResult: TLabel;
    labSistema: TLabel;
    labSql: TLabel;
    labVersao: TLabel;
    labWelcome: TLabel;
    lTokenBegin: TLabel;
    lTokenEnd: TLabel;
    mComando: TMemo;
    Memo1: TMemo;
    paEspanhol: TPanel;
    paIngles: TPanel;
    paPortugues: TPanel;
    paTopo: TPanel;
    pBasicAuth: TPanel;
    ProgressBar1: TProgressBar;
    pTokenAuth: TPanel;
    RESTClientPooler1: TRESTClientPooler;
    RESTDWClientSQL1DEPT_NO1: TStringField;
    RESTDWClientSQL1EMP_NO1: TSmallintField;
    RESTDWClientSQL1FIRST_NAME1: TStringField;
    RESTDWClientSQL1FULL_NAME1: TStringField;
    RESTDWClientSQL1JOB_CODE1: TStringField;
    RESTDWClientSQL1JOB_COUNTRY1: TStringField;
    RESTDWClientSQL1JOB_GRADE1: TSmallintField;
    RESTDWClientSQL1LAST_NAME1: TStringField;
    RESTDWClientSQL1PHONE_EXT1: TStringField;
    RESTDWClientSQL1SALARY1: TFloatField;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    RESTDWUpdateSQL1: TRESTDWUpdateSQL;
    StatusBar1: TStatusBar;
    procedure btnApplyClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
    procedure btnMassiveClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnServerTimeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbAuthOptionsChange(Sender: TObject);
    procedure cbUseCriptoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure RESTClientPooler1BeforeGetToken(Welcomemsg, AccessTag: String;
      Params: TDWParams);
    procedure RESTDWClientSQL1AfterInsert(DataSet: TDataSet);
    procedure RESTDWDataBase1BeforeConnect(Sender: TComponent);
    procedure RESTDWDataBase1BeforeGetToken(Welcomemsg, AccessTag: String;
      Params: TDWParams);
    procedure RESTDWDataBase1Connection(Sucess: Boolean; const Error: String);
    procedure RESTDWDataBase1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: String);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  private
    { Private declarations }
   FBytesToTransfer : Int64;
   vSecresString    : String;
   Procedure SetLoginOptions;
   Procedure GetLoginOptionsClientPooler;
   Procedure GetLoginOptionsDatabase;
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

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 Form2 := Nil;
 Release;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  vSecresString := '';
end;

procedure TForm2.RESTClientPooler1BeforeGetToken(Welcomemsg, AccessTag: String;
  Params: TDWParams);
begin
 Params.Createparam('username', EdUserNameAuth.Text);
 Params.Createparam('password', EdPasswordAuth.Text);
end;

Procedure TForm2.GetLoginOptionsDatabase;
Begin
 If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption in [rdwAOBearer, rdwAOToken] Then
  Begin
   If RESTDWDataBase1.AuthenticationOptions.AuthorizationOption = rdwAOBearer Then
    Begin
     eTokenID.Text       := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets;
    End
   Else
    Begin
     eTokenID.Text       := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
     lTokenBegin.Caption := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).BeginTime);
     lTokenEnd.Caption   := FormatDateTime('dd/mm/yyyy hh:mm:ss', TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).EndTime);
     vSecresString       := TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Secrets;
    End;
  End;
End;

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
    RESTDWDataBase1.TypeRequest    := TTyperequest.trHttps
   Else
    RESTDWDataBase1.TypeRequest    := TTyperequest.trHttp;
  End;
 INICIO                            := Now;
 DataSource1.DataSet               := RESTDWClientSQL1;
 RESTDWClientSQL1.BinaryRequest    := cbBinaryRequest.Checked;
 RESTDWClientSQL1.BinaryCompatibleMode := cbBinaryCompatible.Checked;
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
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttps
 Else
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttp;
 DWClientEvents1.GetEvents         := True;
 DWClientEvents1.CreateDWParams('servertime', dwParams);
 DWClientEvents1.SendEvent('servertime', dwParams, vErrorMessage, vNativeResult);
 If vErrorMessage = '' Then
  Begin
   GetLoginOptionsClientPooler;
   If dwParams.ItemsString['result'] <> Nil Then
    Begin
     If dwParams.ItemsString['result'].AsString <> '' Then
      Showmessage('Server Date/Time is : ' + DateTimeToStr(dwParams.ItemsString['result'].Value))
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
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttps
 Else
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttp;
 DWClientEvents1.SendEvent('assyncevent', dwParams, vErrorMessage, sePOST, True);
 If vErrorMessage = '' Then
  Begin
   GetLoginOptionsClientPooler;
   Showmessage('Assyncevent Executed...');
  End
 Else
  Showmessage(vErrorMessage);
End;

procedure TForm2.cbAuthOptionsChange(Sender: TObject);
begin
 pTokenAuth.Visible := cbAuthOptions.ItemIndex > 1;
 pBasicAuth.Visible := cbAuthOptions.ItemIndex = 1;
end;

procedure TForm2.cbUseCriptoClick(Sender: TObject);
begin
 RESTDWDataBase1.CriptOptions.Use   := cbUseCripto.Checked;
 RESTClientPooler1.CriptOptions.Use := RESTDWDataBase1.CriptOptions.Use;
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
     TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
     TRDWAuthOptionBearerClient(RESTClientPooler1.AuthenticationOptions.OptionParams).Token := TRDWAuthOptionBearerClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token;
    End
   Else
    Begin
     TRDWAuthOptionTokenClient(RESTDWDataBase1.AuthenticationOptions.OptionParams).Token   := eTokenID.Text;
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
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttps
 Else
  RESTClientPooler1.TypeRequest    := TTyperequest.trHttp;
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

procedure TForm2.btnMassiveClick(Sender: TObject);
begin
 If RESTDWClientSQL1.MassiveCount > 0 Then
  Showmessage(RESTDWClientSQL1.MassiveToJSON);
end;

procedure TForm2.btnExecuteClick(Sender: TObject);
VAR
  VError: STRING;
BEGIN
  RESTDWDataBase1.Close;
  RESTDWDataBase1.PoolerService  := EHost.Text;
  RESTDWDataBase1.PoolerPort     := StrToInt(EPort.Text);
  SetLoginOptions;
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
    ShowMessage('Erro executando o comando ' + RESTDWClientSQL1.SQL.Text)
  ELSE
    ShowMessage('Comando executado com sucesso...');
END;

procedure TForm2.btnApplyClick(Sender: TObject);
Var
 vError : String;
begin
 If Not RESTDWClientSQL1.ApplyUpdates(vError) Then
  MessageDlg(vError, mtError, [mbOK], 0);
end;

procedure TForm2.RESTDWClientSQL1AfterInsert(DataSet: TDataSet);
begin

end;

procedure TForm2.RESTDWDataBase1BeforeConnect(Sender: TComponent);
begin
  Memo1.Lines.Add(' ');
  Memo1.Lines.Add('**********');
  Memo1.Lines.Add(' ');
end;

procedure TForm2.RESTDWDataBase1BeforeGetToken(Welcomemsg, AccessTag: String;
  Params: TDWParams);
begin
 Params.Createparam('username', EdUserNameAuth.Text);
 Params.Createparam('password', EdPasswordAuth.Text);
end;

procedure TForm2.RESTDWDataBase1Connection(Sucess: Boolean; const Error: String
  );
begin
 IF Sucess THEN
 BEGIN
  GetLoginOptionsDatabase;
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

procedure TForm2.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
 If FBytesToTransfer = 0 Then // No Update File
  Exit;
 ProgressBar1.Position := AWorkCount;
end;

procedure TForm2.RESTDWDataBase1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
 FBytesToTransfer      := AWorkCountMax;
 ProgressBar1.Max      := FBytesToTransfer;
 ProgressBar1.Position := 0;
end;

procedure TForm2.RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
 ProgressBar1.Position := FBytesToTransfer;
 FBytesToTransfer      := 0;
end;

end.
