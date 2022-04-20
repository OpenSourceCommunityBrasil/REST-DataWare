program FullRDWServerSynopse;



uses
  Vcl.Forms,
  uFullRDWServerSynopse in 'uFullRDWServerSynopse.pas' {RestDWForm},
  uDmService in 'uDmService.pas' {ServerMethodDM: TServerMethodDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
