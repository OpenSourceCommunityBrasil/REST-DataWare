program GetCEP;

uses
  Forms,
  getcepunit in 'getcepunit.pas' {frmGetCEP};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGetCEP, frmGetCEP);
  Application.Run;
end.
