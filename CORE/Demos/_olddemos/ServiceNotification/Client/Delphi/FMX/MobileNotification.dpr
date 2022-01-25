program MobileNotification;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit15 in 'Unit15.pas' {Form15};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm15, Form15);
  Application.Run;
end.
