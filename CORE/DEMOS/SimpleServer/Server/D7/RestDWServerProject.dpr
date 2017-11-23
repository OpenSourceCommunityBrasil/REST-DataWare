program RestDWServerProject;
{$APPTYPE GUI}

uses
  Forms,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas' {ServerMethods1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
