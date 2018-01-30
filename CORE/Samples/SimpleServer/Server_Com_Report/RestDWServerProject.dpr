program RestDWServerProject;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas' {ServerMethods1: TDataModule},
  uDmService in 'uDmService.pas' {DataModule1: TDataModule};

{$R *.res}

begin
  reportmemoryleaksonshutdown:=true;
  Application.Initialize;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
