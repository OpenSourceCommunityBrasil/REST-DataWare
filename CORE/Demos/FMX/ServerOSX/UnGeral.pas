unit UnGeral;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uRESTDWBase,
  FMX.Objects, FMX.Layouts, FMX.TabControl, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Edit, FMX.ScrollBox, FMX.Memo, System.Actions, FMX.ActnList;

type
  TFrmGeral = class(TForm)
    RESTServicePooler1: TRESTServicePooler;
    tbcs: TTabControl;
    tabconfiguração: TTabItem;
    Tablog: TTabItem;
    Layout1: TLayout;
    img1: TImage;
    tupdatelogs: TTimer;
    grp1: TGroupBox;
    edportaDW: TEdit;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    Text1: TText;
    Text2: TText;
    Text3: TText;
    cbencode: TCheckBox;
    cbcompress: TCheckBox;
    Layout2: TLayout;
    grpbase: TGroupBox;
    edip: TEdit;
    edportabd: TEdit;
    EdUserNameBD: TEdit;
    edpasswordbd: TEdit;
    Text4: TText;
    Text5: TText;
    Text6: TText;
    Text7: TText;
    edpastabd: TEdit;
    edbd: TEdit;
    Text8: TText;
    Text9: TText;
    MemoReq: TMemo;
    grp2: TGroupBox;
    Layout3: TLayout;
    Layout4: TLayout;
    btniniciar: TButton;
    btnparar: TButton;
    cbPoolerState: TCheckBox;
    Text10: TText;
    Layout5: TLayout;
    Text11: TText;
    Layout6: TLayout;
    Text12: TText;
    MemoResp: TMemo;
    grpssh: TGroupBox;
    Lseguro: TLabel;
    ePrivKeyFile: TEdit;
    ePrivKeyPass: TEdit;
    eCertFile: TEdit;
    Text13: TText;
    Text14: TText;
    Text15: TText;
    actlst1: TActionList;
    ChangeTablog: TChangeTabAction;
    ChangeTabconfig: TChangeTabAction;
    procedure tupdatelogsTimer(Sender: TObject);
    procedure RESTServicePooler1LastRequest(Value: string);
    procedure RESTServicePooler1LastResponse(Value: string);
    procedure FormCreate(Sender: TObject);
    procedure btniniciarClick(Sender: TObject);
  private
    VLastRequest, VLastRequestB, VDatabaseName, FCfgName, VDatabaseIP, VUsername, VPassword: string;
    procedure StartServer;
    { Private declarations }
  public
    Property Username: string
      Read   VUsername
      Write  VUsername;
    Property Password: string
      Read   VPassword
      Write  VPassword;
    Property DatabaseIP: string
      Read   VDatabaseIP
      Write  VDatabaseIP;
    Property DatabaseName: string
      Read   VDatabaseName
      Write  VDatabaseName;
    { Public declarations }
  end;

var
  FrmGeral: TFrmGeral;

implementation

uses
  uDmService;


{$R *.fmx}

procedure TFrmGeral.StartServer;
Begin
  If Not RESTServicePooler1.Active Then
  Begin
    RESTServicePooler1.ServerParams.UserName := EdUserNameDW.Text;
    RESTServicePooler1.ServerParams.Password := EdPasswordDW.Text;
    RESTServicePooler1.ServicePort           := StrToInt(EdPortaDW.Text);
    RESTServicePooler1.SSLPrivateKeyFile     := EPrivKeyFile.Text;
    RESTServicePooler1.SSLPrivateKeyPassword := EPrivKeyPass.Text;
    RESTServicePooler1.SSLCertFile           := ECertFile.Text;
    RESTServicePooler1.EncodeStrings         := CbEncode.isChecked;
    RESTServicePooler1.Active                := True;
    RESTServicePooler1.DataCompression       := cbcompress.IsChecked;
    If Not RESTServicePooler1.Active Then
      Exit;
   changetablog.Execute;
    tupdatelogs.Enabled := True;
  End;
  If RESTServicePooler1.Secure Then
  Begin
    LSeguro.TextSettings.FontColor := TAlphaColorRec.Blue;
    LSeguro.Text    := 'Seguro : Sim';
  End
  Else
  Begin
    LSeguro.TextSettings.FontColor := TAlphaColorRec.Red;
    LSeguro.Text    := 'Seguro : Não';
  End;
End;

procedure TFrmGeral.btniniciarClick(Sender: TObject);
begin
  VUsername := EdUserNameDW.Text;
  VPassword := EdPasswordDW.Text;
  StartServer;
end;

procedure TFrmGeral.FormCreate(Sender: TObject);
begin
  Tupdatelogs.Enabled       := True;
  RESTServicePooler1.Active := False;
  RESTServicePooler1.ServerMethodClass := TServerMethodDM;
  ChangeTabconfig.Execute;
end;

procedure TFrmGeral.RESTServicePooler1LastRequest(Value: string);
begin
  VLastRequest := Value;
end;

procedure TFrmGeral.RESTServicePooler1LastResponse(Value: string);
begin
  VLastRequestB := Value;
end;

procedure TFrmGeral.tupdatelogsTimer(Sender: TObject);
var
  VTempLastRequest, VTempLastRequestB: string;
Begin
  Tupdatelogs.Enabled := False;
  Try
    VTempLastRequest  := VLastRequest;
    VTempLastRequestB := VLastRequestB;
    If (VTempLastRequest <> '') Then
    Begin
      If MemoReq.Lines.Count > 0 Then
        If MemoReq.Lines[MemoReq.Lines.Count - 1] = VTempLastRequest Then
          Exit;
      If MemoReq.Lines.Count = 0 Then
        MemoReq.Lines.Add(Copy(VTempLastRequest, 1, 100))
      Else
        MemoReq.Lines[MemoReq.Lines.Count - 1] := Copy(VTempLastRequest, 1, 100);
      If Length(VTempLastRequest) > 1000 Then
        MemoReq.Lines[MemoReq.Lines.Count - 1] := MemoReq.Lines[MemoReq.Lines.Count - 1] + '...';
      If MemoResp.Lines.Count > 0 Then
        If MemoResp.Lines[MemoResp.Lines.Count - 1] = VTempLastRequestB Then
          Exit;
      If MemoResp.Lines.Count = 0 Then
        MemoResp.Lines.Add(Copy(VTempLastRequestB, 1, 100))
      Else
        MemoResp.Lines[MemoResp.Lines.Count - 1] := Copy(VTempLastRequestB, 1, 100);
      If Length(VTempLastRequest) > 1000 Then
        MemoResp.Lines[MemoResp.Lines.Count - 1] := MemoResp.Lines[MemoResp.Lines.Count - 1] + '...';
    End;
  Finally
    Tupdatelogs.Enabled := True;
  End;

end;

end.
