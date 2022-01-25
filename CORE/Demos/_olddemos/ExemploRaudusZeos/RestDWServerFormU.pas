unit RestDWServerFormU;

//URL para teste http://localhost:8082/TesteAJAX.html

Interface

Uses Winapi.Windows,    Winapi.Messages, System.SysUtils,         System.Variants,
     System.Classes,    Vcl.Graphics,    Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
     winsock,           Winapi.iphlpapi, Winapi.IpTypes, uSock,   System.IniFiles,
     Vcl.AppEvnts,      Vcl.StdCtrls,    Web.HTTPApp,             Vcl.ExtCtrls,
     Vcl.Imaging.jpeg,  Vcl.Imaging.pngimage, Vcl.Mask,           Vcl.Menus,
     uRESTDWBase,
     Vcl.ComCtrls, Data.DB,
     ZAbstractConnection, ZConnection, ZAbstractRODataset, ZAbstractDataset,
    ZDataset, JvMemoryDataset, uRESTDWPoolerDB, uRESTDWDriverZEOS, RaBase,
  RaControlsVCL;

type
  TRestDWForm = class(TRaFormCompatible)
    ButtonStart: TRaButton;
    ButtonStop: TRaButton;
    Label8: TRaLabel;
    lSeguro: TRaLabel;
    cbPoolerState: TRaCheckBox;
    PageControl1: TRaTabControl;
    tsConfigs: TRaTabSheet;
    tsLogs: TRaTabSheet;
    Label1: TRaLabel;
    Label2: TRaLabel;
    Label3: TRaLabel;
    Label7: TRaLabel;
    Label9: TRaLabel;
    Label10: TRaLabel;
    Label11: TRaLabel;
    Label13: TRaLabel;
    Label12: TRaLabel;
    Label14: TRaLabel;
    Label6: TRaLabel;
    Image1: TRaImage;
    Label5: TRaLabel;
    Label4: TRaLabel;
    Label15: TRaLabel;
    Label16: TRaLabel;
    Label17: TRaLabel;
    edPortaDW: TRaEdit;
    edUserNameDW: TRaEdit;
    edPasswordDW: TRaEdit;
    cbAdaptadores: TRaComboBox;
    edPortaBD: TRaEdit;
    edUserNameBD: TRaEdit;
    edPasswordBD: TRaEdit;
    edPasta: TRaEdit;
    edBD: TRaEdit;
    ePrivKeyFile: TRaEdit;
    eCertFile: TRaEdit;
    ePrivKeyPass: TRaEdit;
    memoReq: TRaEdit;
    memoResp: TRaEdit;
    Label19: TRaLabel;
    Label18: TRaLabel;
    ZQuery1: TZQuery;
    cbEncode: TRaCheckBox;
    Server_FDConnection: TZConnection;
    cheAutenticar: TRaCheckBox;
    RESTServicePooler1: TRESTServicePooler;
    RESTDWDriverZeos1: TRESTDWDriverZeos;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbAdaptadoresChange(Sender: TObject);
    procedure ctiPrincipalDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SairdaAplicao1Click(Sender: TObject);
    procedure RestaurarAplicao1Click(Sender: TObject);
    procedure Server_FDConnectionBeforeConnect(Sender: TObject);
  Private
   {Private declarations}
   vDatabaseName,
   FCfgName,
   vDatabaseIP,
   vUsername,
   vPassword  : String;
   Procedure StartServer;
   Function  GetHandleOnTaskBar : THandle;
   Procedure ChangeStatusWindow;
   Procedure HideApplication;
  Public
   {Public declarations}
   Procedure ShowBalloonTips(IconMessage : Integer = 0; MessageValue : String = '');
   Procedure ShowApplication;
   Property  Username   : String Read vUsername   Write vUsername;
   Property  Password   : String Read vPassword   Write vPassword;
   Property  DatabaseIP : String Read vDatabaseIP Write vDatabaseIP;
  End;

var
  RestDWForm : TRestDWForm;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

uses
  Winapi.ShellApi,udm, uMain;

Function TRestDWForm.GetHandleOnTaskBar : THandle;
Begin
End;

Procedure TRestDWForm.ChangeStatusWindow;
Begin
End;

procedure TRestDWForm.ctiPrincipalDblClick(Sender: TObject);
begin
 ShowApplication;
end;

Procedure TRestDWForm.HideApplication;
Begin
 Application.ShowMainForm := False;
 If Self <> Nil Then
  Self.Visible := False;
 Application.Minimize;
 ShowWindow(GetHandleOnTaskBar, SW_HIDE);
 ChangeStatusWindow;
End;

procedure TRestDWForm.RestaurarAplicao1Click(Sender: TObject);
begin
 ShowApplication;
end;

procedure TRestDWForm.SairdaAplicao1Click(Sender: TObject);
begin
 Close;
end;

procedure TRestDWForm.Server_FDConnectionBeforeConnect(Sender: TObject);
Var
 porta_BD,
 servidor,
 pasta,
 usuario_BD,
 senha_BD      : String;
Begin
 servidor      := vDatabaseIP;
 vDatabaseName      := edBD.Text;
 pasta         := IncludeTrailingPathDelimiter(edPasta.Text);
 porta_BD      := edPortaBD.Text;
 usuario_BD    := edUserNameBD.Text;
 senha_BD      := edPasswordBD.Text;
 vDatabaseName := pasta + vDatabaseName;
 //TZConnection(Sender).Params.Clear;
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

 //Server_FDConnection.Params.Add('CharacterSet=ISO8859_1');
 //TFDConnection(Sender).UpdateOptions.CountUpdatedRecords := False;
end;

Procedure TRestDWForm.ShowApplication;
Begin
 Application.ShowMainForm    := True;
 If Self <> Nil Then
  Begin
   Self.Visible     := True;
   Self.WindowState := wsNormal;
  End;
 ShowWindow(GetHandleOnTaskBar, SW_SHOW);
 ChangeStatusWindow;
End;

Procedure TRestDWForm.ShowBalloonTips(IconMessage : Integer = 0; MessageValue : String = '');
Begin
End;

Procedure TRestDWForm.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
Begin

 edPortaDW.Enabled     := ButtonStart.Enabled;
 edUserNameDW.Enabled  := ButtonStart.Enabled;
 edPasswordDW.Enabled  := ButtonStart.Enabled;
 cbAdaptadores.Enabled := ButtonStart.Enabled;
 edPortaBD.Enabled     := ButtonStart.Enabled;
 edPasta.Enabled       := ButtonStart.Enabled;
 edBD.Enabled          := ButtonStart.Enabled;
 edUserNameBD.Enabled  := ButtonStart.Enabled;
 edPasswordBD.Enabled  := ButtonStart.Enabled;
 ePrivKeyFile.Enabled  := ButtonStart.Enabled;
 ePrivKeyPass.Enabled  := ButtonStart.Enabled;
 eCertFile.Enabled     := ButtonStart.Enabled;
End;

procedure TRestDWForm.ButtonStartClick(Sender: TObject);
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
 ini.WriteString('BancoDados', 'PortaDW',   edPortaDW.Text);
 ini.WriteString('BancoDados', 'UsuarioBD', edUserNameBD.Text);
 ini.WriteString('BancoDados', 'SenhaBD',   edPasswordBD.Text);
 ini.WriteString('BancoDados', 'UsuarioDW', edUserNameDW.Text);
 ini.WriteString('BancoDados', 'SenhaDW',   edPasswordDW.Text);
 ini.WriteString('BancoDados', 'Libray',    'C:\Windows\SysWOW64\fbclient.dll');

 ini.WriteString('SSL',        'PKF',       ePrivKeyFile.Text);
 ini.WriteString('SSL',        'PKP',       ePrivKeyPass.Text);
 ini.WriteString('SSL',        'CF',        eCertFile.Text);
 ini.Free;
 vUsername := edUserNameDW.Text;
 vPassword := edPasswordDW.Text;


 StartServer;
End;

procedure TRestDWForm.ButtonStopClick(Sender: TObject);
begin
 Server_FDConnection.Connected := False;
 PageControl1.ActiveTab := tsConfigs;
 ShowApplication;
end;

Procedure TRestDWForm.cbAdaptadoresChange(Sender: TObject);
Begin
 vDatabaseIP := Trim(Copy(cbAdaptadores.Text, Pos('-' , cbAdaptadores.Text ) + 1 , 100));
End;

procedure TRestDWForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

 If Not CanClose Then
  Begin
   CanClose := Not Self.Visible;
   If CanClose Then
    CanClose := Application.MessageBox('Você deseja realmente sair do programa ?',
                                       'Pergunta ?', mb_IconQuestion + mb_YesNo) = mrYes
   Else
    HideApplication;
  End;
end;

Procedure TRestDWForm.FormCreate(Sender: TObject);
Begin
 // define o nome do .ini de acordo c o EXE
 // dessa forma se quiser testar várias instâncias do servidor em
 // portas diferentes os arquivos não irão conflitar
 FCfgName := StringReplace(ExtractFileName(ParamStr(0) ), '.exe' , '' , [rfReplaceAll]);
 FCfgName := ExtractFilePath(ParamSTR(0)) + 'Config_' + FCfgName + '.ini' ;


 PageControl1.Activetab              := tsConfigs;
End;

procedure TRestDWForm.FormShow(Sender: TObject);
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
 edPortaDW.Text          := ini.ReadString('BancoDados', 'PortaDW',   '8082' );
 edUserNameBD.Text       := ini.ReadString('BancoDados', 'UsuarioBD', 'SYSDBA');
 edPasswordBD.Text       := ini.ReadString('BancoDados', 'SenhaBD',   'masterkey');
 edUserNameDW.Text       := ini.ReadString('BancoDados', 'UsuarioDW', 'testserver');
 edPasswordDW.Text       := ini.ReadString('BancoDados', 'SenhaDW',   'testserver');
 ePrivKeyFile.Text       := ini.ReadString('SSL',        'PKF',       '');
 ePrivKeyPass.Text       := ini.ReadString('SSL',        'PKP',       '');
 eCertFile.Text          := ini.ReadString('SSL',        'CF',        '');
 ini.Free;
End;

procedure TRestDWForm.StartServer;
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
 //TZConnection(Sender).Params.Clear;
 with dm.sqlDb do
 begin
    //HostName := Servidor;
    //Port := strtoint(porta_BD);
    dm.sqlDb.Database :=Servidor+'/'+porta_BD+':'+vDatabaseName;
    User := usuario_BD;
    Password := senha_BD;
    Protocol := 'firebird-2.5';
    Port:=strtoint(porta_BD);
    LibraryLocation:='C:\Windows\SysWOW64\fbclient.dll';
 end;
   with dm do
   begin

  ZQuery2.Active:=false;
  ZQuery1.Active:=false;
  sqlDb.Connected :=false;

  sqlDb.Connected :=true;
  ZQuery1.Active:=True;
  ZQuery2.Active:=True;
  end;
  Form2.ShowModalNonBlocking;

end;

end.

