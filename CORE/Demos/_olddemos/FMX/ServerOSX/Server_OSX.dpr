program Server_OSX;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnGeral in 'UnGeral.pas' {FrmGeral},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas',
  uDmService in 'uDmService.pas' {ServerMethodDM: TServerMethodDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmGeral, FrmGeral);
 // Application.CreateForm(TServerMethodDM, ServerMethodDM);
  Application.Run;
end.
