program RestDWServerProject;

uses
  {$IFDEF UNIX}
  cthreads, cmem,
  {$ENDIF}
  Forms, Interfaces,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm},
  uDmService in 'uDmService.pas' {DataModule1: TDataModule};

{.$R *.res}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
