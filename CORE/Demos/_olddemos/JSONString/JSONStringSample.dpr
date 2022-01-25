program JSONStringSample;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {fJSONStringSample};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfJSONStringSample, fJSONStringSample);
  Application.Run;
end.
