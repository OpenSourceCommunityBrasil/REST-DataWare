unit undmsrv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Win.Registry, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, uConsts;

type
  TRestDWsrv = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
  end;

var
  RestDWsrv: TRestDWsrv;

implementation

uses
  uDmService;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ Tdmsrv }

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  RestDWsrv.Controller(CtrlCode);
end;

function TRestDWsrv.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;


procedure TRestDWsrv.ServiceAfterInstall(Sender: TService);
//Var
// Reg : TRegistry;
Begin
 {Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
 Try
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  If Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, false) Then
   Begin
    Reg.WriteString('Description', 'RestDataware Server Service Application.');
    Reg.CloseKey;
   End;
 Finally
  Reg.Free;
 End;}
end;

procedure TRestDWsrv.ServiceCreate(Sender: TObject);
begin
  RESTServicePooler.ServerMethodClass     := TServerMethodDM;
  RESTServicePooler.ServerParams.UserName := vUsername;
  RESTServicePooler.ServerParams.Password := vPassword;
  RESTServicePooler.ServicePort           := vPort;
  RESTServicePooler.SSLPrivateKeyFile     := SSLPrivateKeyFile;
  RESTServicePooler.SSLPrivateKeyPassword := SSLPrivateKeyPassword;
  RESTServicePooler.SSLCertFile           := SSLCertFile;
  RESTServicePooler.EncodeStrings         := EncodedData;
  RESTServicePooler.Active                := True;
end;

end.
