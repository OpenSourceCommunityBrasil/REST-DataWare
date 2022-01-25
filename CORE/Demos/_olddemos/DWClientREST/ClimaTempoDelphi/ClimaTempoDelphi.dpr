program ClimaTempoDelphi;

uses
  Vcl.Forms,
  uClimaTempo in 'uClimaTempo.pas' {frmClimaTempo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmClimaTempo, frmClimaTempo);
  Application.Run;
end.
