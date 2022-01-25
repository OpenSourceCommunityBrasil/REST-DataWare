program FileServer;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {fServer},
  uDMFileServer in 'uDMFileServer.pas' {dmFileServer: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfServer, fServer);
  Application.Run;
end.
