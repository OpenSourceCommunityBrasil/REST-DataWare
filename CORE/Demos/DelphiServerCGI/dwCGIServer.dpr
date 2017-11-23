program dwCGIServer;

{$APPTYPE CONSOLE}

uses
  WebBroker,
  CGIApp,
  dmdwcgiserver in 'dmdwcgiserver.pas' {dwCGIService: TWebModule},
  uDmService in 'uDmService.pas' {ServerMethodDM: TServerMethodDataModule},
  uConsts in 'uConsts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.WebModuleClass := TdwCGIService;
//  Application.WebModuleClass              := Nil;
//  Application.CreateForm(TdwCGIService, dwCGIService);
  Application.Run;
end.
