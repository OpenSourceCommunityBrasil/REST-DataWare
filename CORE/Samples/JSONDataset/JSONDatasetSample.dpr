program JSONDatasetSample;

uses
  Vcl.Forms,
  uJSONDatasetSample in 'uJSONDatasetSample.pas' {Form1},
  uSock in 'uSock.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
