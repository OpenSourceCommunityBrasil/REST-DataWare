program WebpascalRetaguarda;

uses
  Vcl.Forms,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm},
  uConsts in 'uConsts.pas',
  uDmService in 'uDmService.pas' {ServerMethodDM: TServerMethodDataModule},
  uSock in 'uSock.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
