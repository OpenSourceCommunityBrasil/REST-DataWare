program ServerProtocol;

uses
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  MyServerMethods in 'MyServerMethods.pas',
  ServerDataModuleUnit in 'ServerDataModuleUnit.pas' {ServerDataModule: TDataModule},
  Protocol in '..\Protocol.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
