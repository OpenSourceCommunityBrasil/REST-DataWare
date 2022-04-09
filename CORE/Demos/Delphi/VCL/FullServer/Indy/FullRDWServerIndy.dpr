program FullRDWServerIndy;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  uFullRDWServerIndy in 'uFullRDWServerIndy.pas' {RestDWForm},
  uDmService in 'uDmService.pas' {ServerMethodDM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
