program FileServer;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {fServer},
  SMDWCore in 'SMDWCore.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfServer, fServer);
  Application.Run;
end.
