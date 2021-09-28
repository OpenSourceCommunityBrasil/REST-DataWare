program getIpSample;

uses
  Forms,
  uPrincipal in 'uPrincipal.pas' {fClientREST};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfClientREST, fClientREST);
  Application.Run;
end.
