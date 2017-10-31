unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  Androidapi.JNI.Interfaces, System.Messaging,
  FMX.Platform.Android,
  Androidapi.Helpers, Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Objects, FMX.Effects, FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDWConstsData, uRESTDWPoolerDB, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FMX.DialogService ;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    lyt1: TLayout;
    lyt2: TLayout;
    lyt3: TLayout;
    tlb1: TToolBar;
    lytconfig: TLayout;
    Rectangle2: TRectangle;
    Rectangle1: TRectangle;
    lyt4: TLayout;
    btnok: TButton;
    btncancelar: TButton;
    ShadowEffect1: TShadowEffect;
    edtporta: TEdit;
    edtip: TEdit;
    Text2: TText;
    Text3: TText;
    edtuser: TEdit;
    edtpass: TEdit;
    Text4: TText;
    Text5: TText;
    btnsair: TButton;
    btnconnect: TButton;
    lv1: TListView;
    btnpost: TButton;
    RESTDWDataBase1: TRESTDWDataBase;
    RESTDWClientSQL1: TRESTDWClientSQL;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    RESTDWClientSQL1ID: TIntegerField;
    RESTDWClientSQL1BLOBIMAGE: TBlobField;
    RESTDWClientSQL1DESCRICAO: TStringField;
    LinkListControlToField1: TLinkListControlToField;
    img1: TImage;
    LinkPropertyToFieldBitmap: TLinkPropertyToField;
    LinkControlToField1: TLinkControlToField;
    btnaplly: TButton;
    procedure Button1Click(Sender: TObject);
    procedure btnconnectClick(Sender: TObject);
    procedure btnokClick(Sender: TObject);
    procedure btncancelarClick(Sender: TObject);
    procedure btnapllyClick(Sender: TObject);
  private
    const ScanRequestCode = 0;
    var FMessageSubscriptionID: Integer;
    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    function OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


function ShowMessageOKCancel(AMessage: string): string;
var
  lResultStr: string;
begin
  lResultStr := '';
  TDialogService.PreferredMode := TDialogService.TPreferredMode.platform;
  TDialogService.MessageDialog(AMessage, TMsgDlgType.mtConfirmation, FMX.Dialogs.mbOKCancel, TMsgDlgBtn.mbOK, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrOK:
          lResultStr := 'O';
        mrCancel:
          lResultStr := 'C';
      end;
    end);

  Result := lResultStr;
end;
procedure TForm1.HandleActivityMessage(const Sender: TObject; const M: TMessage);
begin
  if M is TMessageResultNotification then
    OnActivityResult(TMessageResultNotification(M).RequestCode, TMessageResultNotification(M).ResultCode,
      TMessageResultNotification(M).Value);
end;

function TForm1.OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
var
  filename : string;
begin
  Result := False;

  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, FMessageSubscriptionID);
  FMessageSubscriptionID := 0;

  // For more info see https://github.com/zxing/zxing/wiki/Scanning-Via-Intent
  if RequestCode = ScanRequestCode then
  begin
    if ResultCode = TJActivity.JavaClass.RESULT_OK then
    begin
      if Assigned(Data) then
      begin
        filename := JStringToString(Data.getStringExtra(StringToJString('RESULT_PATH')));

        if not (RESTDWClientSQL1.State in [dsEdit, dsInsert]) then
          RESTDWClientSQL1.Edit;
        TBlobField(RESTDWClientSQL1BLOBIMAGE).LoadFromFile(filename);
        RESTDWClientSQL1.Post;

        //Toast(Format('Found %s format barcode:'#10'%s', [ScanFormat, ScanContent]), LongToast);
      end;
    end
    else if ResultCode = TJActivity.JavaClass.RESULT_CANCELED then
    begin
      //Toast('You cancelled the scan', ShortToast);
    end;
    Result := True;
  end;
end;

procedure TForm1.btnapllyClick(Sender: TObject);
var
  vError: string;
begin
  if not RESTDWClientSQL1.ApplyUpdates(vError) then
    ShowMessageOKCancel(vError);

end;

procedure TForm1.btncancelarClick(Sender: TObject);
begin
  lytconfig.visible := false;
end;

procedure TForm1.btnconnectClick(Sender: TObject);
begin
lytconfig.Visible:=true;
end;

procedure TForm1.btnokClick(Sender: TObject);
begin
  lytconfig.visible := false;
  if RESTDWDataBase1.active then
    RESTDWDataBase1.active := false;
  RESTDWDataBase1.poolerservice := edtip.text;
  RESTDWDataBase1.poolerport := strtoint(edtporta.text);
  RESTDWDataBase1.login := edtuser.text;
  RESTDWDataBase1.password := edtpass.text;
  RESTDWDataBase1.active := true;
  RESTDWClientSQL1.active := true;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Intent: JIntent; // JFileDialog;
begin
  FMessageSubscriptionID := TMessageManager.DefaultManager.SubscribeToMessage
    (TMessageResultNotification, HandleActivityMessage);

  Intent := TJIntent.JavaClass.init;
  Intent.setClassName(SharedActivityContext, StringToJString('com.lamerman.FileDialog'));
  SharedActivity.startActivityForResult(Intent, 0);
end;

end.
