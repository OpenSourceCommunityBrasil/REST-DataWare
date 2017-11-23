program ArrayDatasetProcess;

uses
  Vcl.Forms,
  Unit8 in 'Unit8.pas' {fPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
