program SimpleServer;

uses
  Vcl.Forms,
  uPrincipal in 'src\uPrincipal.pas' {Form1},
  RDWDM in 'src\RDWDM.pas' {DM: TDataModule};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
