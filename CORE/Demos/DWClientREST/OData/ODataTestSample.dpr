program ODataTestSample;

uses
  Vcl.Forms,
  uODataTest in 'uODataTest.pas' {fODataTest};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfODataTest, fODataTest);
  Application.Run;
end.
