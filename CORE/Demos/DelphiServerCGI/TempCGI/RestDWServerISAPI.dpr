library RestDWServerISAPI;

uses
  Winapi.ActiveX,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  dmdwcgiserver in '..\dmdwcgiserver.pas' {dwCGIService: TWebModule},
  uDmService in '..\uDmService.pas' {ServerMethodDM: TServerMethodDataModule},
  uConsts in '..\uConsts.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

procedure TerminateThreads;
begin
end;

begin
  CoInitFlags                             := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass              := Nil;
  TISAPIApplication(Application).OnTerminate := TerminateThreads;
  Application.CreateForm(TdwCGIService, dwCGIService);
  Application.Run;
end.
