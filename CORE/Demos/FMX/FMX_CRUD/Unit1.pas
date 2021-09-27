unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  System.Messaging, FMX.Platform,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Objects, FMX.Effects, FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uDWConstsData, uRESTDWPoolerDB, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FMX.DialogService, System.Actions, FMX.ActnList,
  FMX.StdActns, FMX.MediaLibrary.Actions ;

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
    btndel: TButton;
    actlst1: TActionList;
    TakePhotoFromLibraryAction1: TTakePhotoFromLibraryAction;
    procedure btnconnectClick(Sender: TObject);
    procedure btnokClick(Sender: TObject);
    procedure btncancelarClick(Sender: TObject);
    procedure btnapllyClick(Sender: TObject);
    procedure TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);
    procedure btndelClick(Sender: TObject);
    procedure btnpostClick(Sender: TObject);
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




procedure TForm1.TakePhotoFromLibraryAction1DidFinishTaking(Image: TBitmap);
  var
    ScaleFactor: Single;
    bl: TmemoryStream;
  begin
    if Image.Width > 1024 then
    begin
      ScaleFactor := Image.Width / 1024;
      Image.Resize(Round(Image.Width / ScaleFactor), Round(Image.Height / ScaleFactor));
    end;

    if not (RESTDWClientSQL1.State in [dsEdit, dsInsert]) then
      RESTDWClientSQL1.Edit;
      bl:=Tmemorystream.Create;
      image.SaveToStream(bl);
      TBlobField(RESTDWClientSQL1BLOBIMAGE).LoadFromStream(bl);
      bl.Clear;
      freeandnil(bl);
      RESTDWClientSQL1.Post;

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

procedure TForm1.btndelClick(Sender: TObject);
begin
  if not (RESTDWClientSQL1.State in [dsEdit, dsInsert]) then
  RESTDWClientSQL1.Delete
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


procedure TForm1.btnpostClick(Sender: TObject);
begin
 RESTDWClientSQL1.post;
end;

end.
