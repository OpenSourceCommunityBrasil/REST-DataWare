program FileClient;

{$MODE Delphi}

uses
  Forms, Interfaces,
  uFileClient in 'uFileClient.pas' {Form4};

{.$R *.res}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
