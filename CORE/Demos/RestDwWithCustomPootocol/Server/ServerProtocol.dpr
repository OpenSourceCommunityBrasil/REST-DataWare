program ServerProtocol;

uses
  Vcl.Forms,
  ProtocolServer in 'ProtocolServer.pas' {Form1},
  ServerModuleUnit in 'ServerModuleUnit.pas' {ServerModule: TDataModule},
  MyServerMethods in 'MyServerMethods.pas',
  ServerDataModuleUnit in 'ServerDataModuleUnit.pas' {ServerDataModule: TDataModule},
  FireDacUnit in 'FireDacUnit.pas' {FireDac: TDataModule},
  Protocol in '..\Protocol.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
