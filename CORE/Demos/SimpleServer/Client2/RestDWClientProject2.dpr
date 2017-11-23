program RestDWClientProject2;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  formMain in 'formMain.pas' {Form2},
  uDmClientDW in 'uDmClientDW.pas' {DataModule2: TDataModule},
  StopWatch in '..\..\..\..\..\StopWatch.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TDataModule2, DataModule2);
  Application.Run;
end.
