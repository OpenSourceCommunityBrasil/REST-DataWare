program ClientBLOB;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form5};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
