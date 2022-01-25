program DWRotasGoogle;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {Form10};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm10, Form10);
  Application.Run;
end.
