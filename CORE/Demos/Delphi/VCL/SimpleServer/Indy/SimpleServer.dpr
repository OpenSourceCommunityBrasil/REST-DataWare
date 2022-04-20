program SimpleServer;

uses
  Vcl.Forms,
  uPrincipal in 'src\uPrincipal.pas' {Form1},
  RDWDM in 'src\RDWDM.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
