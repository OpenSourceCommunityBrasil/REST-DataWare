program RestDWServerProject;
{$APPTYPE GUI}

uses
  Forms,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm},
  uDmService in 'uDmService.pas' {DataModule1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
