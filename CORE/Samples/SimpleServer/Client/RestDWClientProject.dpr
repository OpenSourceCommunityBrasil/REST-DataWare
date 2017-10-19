program RestDWClientProject;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  formMain in 'formMain.pas' {Form2},
  uDmClientDW in 'uDmClientDW.pas' {DataModule2: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TDataModule2, DataModule2);
  Application.Run;
end.
