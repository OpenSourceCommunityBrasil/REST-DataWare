program getBlueCosmos;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {fBlueCosmos};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfBlueCosmos, fBlueCosmos);
  Application.Run;
end.
