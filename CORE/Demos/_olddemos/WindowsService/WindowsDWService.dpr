program WindowsDWService;

{$ifdef DEBUG}
  {$APPTYPE CONSOLE}
{$endif}

uses
  Vcl.SvcMgr,
  System.SysUtils,
  uRESTDWBase,
  uConsts in 'uConsts.pas',
  uDmService in 'uDmService.pas' {ServerMethodDM: TServerMethodDataModule},
  undmsrv in 'undmsrv.pas' {RestDWsrv: TDataModule};

{$R *.RES}

Begin
  {$ifdef DEBUG}
   // In debug mode the server acts as a console application.
  Try
   WriteLn('REST Dataware - CORE - Server : DEBUG mode. Press enter to exit.');
   // Create the TService descendant manually.
   If Not Application.DelayInitialize Or Application.Installing Then
    Application.Initialize;
   Application.CreateForm(TRestDWsrv, RestDWsrv);
   Application.Run;
   ReadLn;
  Except
   On E: Exception Do
    Begin
     Writeln(E.ClassName, ': ', E.Message);
     WriteLn('Press enter to exit.');
     ReadLn;
    End;
  End;
  {$else}
   // Run as a true windows service (release).
   If Not Application.DelayInitialize Or Application.Installing Then
    Application.Initialize;
    Application.CreateForm(TRestDWsrv, RestDWsrv);
    Application.Run;
  {$endif}
End.

