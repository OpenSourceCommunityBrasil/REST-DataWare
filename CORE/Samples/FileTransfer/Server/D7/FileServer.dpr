program FileServer;

uses
  Forms,
  uPrincipal in 'uPrincipal.pas' {fServer},
  SMDWCore in 'SMDWCore.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfServer, fServer);
  Application.Run;
end.
