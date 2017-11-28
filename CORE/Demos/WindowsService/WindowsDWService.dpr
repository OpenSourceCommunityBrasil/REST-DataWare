program WindowsDWService;

{$ifdef DEBUG}
  {$APPTYPE CONSOLE}
{$endif}

uses
  Vcl.SvcMgr,
  System.SysUtils,
  uRESTDWBase,
  uConsts in 'uConsts.pas',
  uDmService in 'uDmService.pas' {ServerMethodDM: TServerMethodDataModule};

{$R *.RES}

Begin
  RESTServicePooler.ServerMethodClass := TServerMethodDM;
  RESTServicePooler.ServerParams.UserName := vUsername;
  RESTServicePooler.ServerParams.Password := vPassword;
  RESTServicePooler.ServicePort           := vPort;
  RESTServicePooler.SSLPrivateKeyFile     := SSLPrivateKeyFile;
  RESTServicePooler.SSLPrivateKeyPassword := SSLPrivateKeyPassword;
  RESTServicePooler.SSLCertFile           := SSLCertFile;
  RESTServicePooler.EncodeStrings         := EncodedData;
  RESTServicePooler.Active                := True;
  {$ifdef DEBUG}
  Try
   // In debug mode the server acts as a console application.
   WriteLn('REST Dataware - CORE - Server : DEBUG mode. Press enter to exit.');
   // Create the TService descendant manually.
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
  Application.Run;
  {$endif}
End.

