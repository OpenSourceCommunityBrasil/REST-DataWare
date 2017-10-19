program WindowsDWService;

{$ifdef DEBUG}
  {$APPTYPE CONSOLE}
{$endif}

uses
  Vcl.SvcMgr,
  System.SysUtils,
  Server.Containner in 'Server.Containner.pas' {RESTDWServer: TService},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas' {ServerMethods1: TDataModule},
  uConsts in 'uConsts.pas';

{$R *.RES}

Begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  // Application.DelayInitialize := True;
  {$ifdef DEBUG}
  Try
   // In debug mode the server acts as a console application.
   WriteLn('REST Dataware - Server : DEBUG mode. Press enter to exit.');
   // Create the TService descendant manually.
   RESTDWServer   := TRESTDWServer.Create  (Nil);
   ServerMethods1 := TServerMethods1.Create(Nil);
   ReadLn;
   RESTDWServer.DisposeOf;
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
   Application.CreateForm(TRESTDWServer,   RESTDWServer);
   Application.CreateForm(TServerMethods1, ServerMethods1);
   Application.Run;
  {$endif}
End.

