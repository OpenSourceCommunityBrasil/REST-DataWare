program ClientSlides;

{$MODE Delphi}

uses
  Forms, Interfaces,
  Unit6 in 'Unit6.pas' {Form6};

{.$R *.res}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
