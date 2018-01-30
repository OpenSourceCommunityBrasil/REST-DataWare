unit MainFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRESTDWBase, Datasnap.DSClientRest,
  Vcl.StdCtrls, Vcl.Mask, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    RESTServicePooler1: TRESTServicePooler;
    PageControl1: TPageControl;
    tsConfigs: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label12: TLabel;
    Label14: TLabel;
    Label6: TLabel;
    Image1: TImage;
    Label5: TLabel;
    Bevel4: TBevel;
    Label4: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    edPortaDW: TEdit;
    edUserNameDW: TEdit;
    edPasswordDW: TEdit;
    cbAdaptadores: TComboBox;
    edPortaBD: TEdit;
    edUserNameBD: TEdit;
    edPasswordBD: TEdit;
    edPasta: TEdit;
    edBD: TEdit;
    ePrivKeyFile: TEdit;
    eCertFile: TEdit;
    ePrivKeyPass: TMaskEdit;
    cbEncode: TCheckBox;
    CheckBox1: TCheckBox;
    tsLogs: TTabSheet;
    Label19: TLabel;
    Label18: TLabel;
    memoReq: TMemo;
    memoResp: TMemo;
    ButtonStart: TButton;
    procedure RESTServicePooler1LastResponse(Value: string);
    procedure RESTServicePooler1LastRequest(Value: string);
    procedure ButtonStartClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses MyServerMethods;

procedure TForm1.ButtonStartClick(Sender: TObject);
begin
  if ButtonStart.Tag = 0 then begin
    RESTServicePooler1.ServerParams.UserName := edUserNameDW.Text;
    RESTServicePooler1.ServerParams.Password := edPasswordDW.Text;
    RESTServicePooler1.ServicePort := StrToInt(edPortaDW.Text);
    RESTServicePooler1.ServerMethodClass := TMyServerMethods;
    RESTServicePooler1.Active := True;
    ButtonStart.Tag := 1;
    ButtonStart.Caption := 'Parar';
  end else begin
    RESTServicePooler1.Active := False;
    ButtonStart.Tag := 0;
    ButtonStart.Caption := 'Iniciar';
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  RESTServicePooler1.Active := False;
end;

procedure TForm1.RESTServicePooler1LastRequest(Value: string);
begin
  memoReq.Lines.Add(Value);
end;

procedure TForm1.RESTServicePooler1LastResponse(Value: string);
begin
  memoResp.Lines.Clear;
  memoResp.Lines.Add(Value);
end;

end.
