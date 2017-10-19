program SimpleProject;

uses
  Vcl.Forms,
  uEmployee in 'uEmployee.pas' {fEmployee};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfEmployee, fEmployee);
  Application.Run;
end.
