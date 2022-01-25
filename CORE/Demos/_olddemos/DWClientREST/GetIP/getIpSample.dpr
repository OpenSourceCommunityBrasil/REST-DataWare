program getIpSample;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {fClientREST};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfClientREST, fClientREST);
  Application.Run;
end.
