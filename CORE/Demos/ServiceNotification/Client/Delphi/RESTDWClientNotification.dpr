program RESTDWClientNotification;

uses
  Vcl.Forms,
  Unit14 in 'Unit14.pas' {Form14};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm14, Form14);
  Application.Run;
end.
