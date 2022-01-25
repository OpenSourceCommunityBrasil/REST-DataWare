program FileServer;

uses
  Forms,
  uPrincipal in 'uPrincipal.pas' {fServer},
  uDMFileServer in 'uDMFileServer.pas' {dmFileServer: TServerMethodDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfServer, fServer);
  Application.Run;
end.
