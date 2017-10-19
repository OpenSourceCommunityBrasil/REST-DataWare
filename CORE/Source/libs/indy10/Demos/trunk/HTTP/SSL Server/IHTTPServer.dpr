program IHTTPServer;

uses
  Forms,
  MainForm in 'Forms\MainForm.pas' {frmMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Indy SSL HTTP Server';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
