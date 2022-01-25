program WebpascalSyn;

uses
  Vcl.Forms,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm},
  uDmService in '..\uDmService.pas' {ServerMethodDM: TServerMethodDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.CreateForm(TServerMethodDM, ServerMethodDM);
  Application.Run;
end.
