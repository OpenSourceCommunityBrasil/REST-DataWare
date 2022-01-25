program ServiceServer;

uses
  Vcl.Forms,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
