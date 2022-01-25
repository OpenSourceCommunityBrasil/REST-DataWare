program ArrayDatasetProcess;

uses
  Forms,
  Unit8 in 'Unit8.pas' {fPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
