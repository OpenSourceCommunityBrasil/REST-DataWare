program DwTableSample;

uses
  Vcl.Forms,
  Unit13 in 'Unit13.pas' {Form13};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm13, Form13);
  Application.Run;
end.
