program IHTTPServer;

uses
  Forms,
  MainForm in 'Forms\MainForm.pas' {frmMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Indy HTTP Server';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
