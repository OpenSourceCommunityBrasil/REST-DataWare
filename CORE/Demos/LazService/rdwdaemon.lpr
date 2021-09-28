program rdwdaemon;

{$mode objfpc}{$H+}

uses
{$IFDEF UNIX}CThreads,
{$ENDIF}
 Classes,
 SysUtils,
 EventLog,
 DaemonApp,
 uDmServiceBase;

Type
 TRDWDaemon = class(TCustomDaemon)
 Private
 Public
  Function Install   : Boolean; Override;
  Function UnInstall : Boolean; Override;
  Function Start     : Boolean; Override;
  Function Stop      : Boolean; Override;
  Function Pause     : Boolean; Override;
  Function Continue  : Boolean; Override;
  Function Execute   : Boolean; Override;
  Function ShutDown  : Boolean; Override;
 End;
 TRDWDaemonMapper = class(TCustomDaemonMapper)
 Private
 Public
  Constructor Create         (AOwner : TComponent); Override;
  Procedure   ToDoOnInstall  (Sender : TObject);
  Procedure   ToDoOnRun      (Sender : TObject);
  Procedure   ToDoOnUninstall(Sender : TObject);
  Procedure   ToDoOnDestroy  (Sender : TObject);
 End;

Function BoolToStr(AVal: Boolean): String;
Begin
 If AVal Then
  Result := 'true'
 Else
  Result := 'false';
End;

Function TRDWDaemon.Install: boolean;
Begin
 Result := inherited Install;
 Application.Log(etDebug, 'RDWDaemon.installed: ' + BoolToStr(result));
End;

Function TRDWDaemon.UnInstall: boolean;
Begin
 Result := inherited UnInstall;
 Application.Log(etDebug, 'RDWDaemon.Uninstall: ' + BoolToStr(result));
End;

Function TRDWDaemon.Start: boolean;
Begin
 Result := inherited Start;
 Application.Log(etDebug, 'RDWDaemon.Start: ' + BoolToStr(result));
 rdwDaemonDM.StartServer;
End;

Function TRDWDaemon.Stop: boolean;
Begin
 Result := inherited Stop;
 Application.Log(etDebug, 'RDWDaemon.Stop: ' + BoolToStr(result));
 rdwDaemonDM.StopServer;
 FreeAndNil(rdwDaemonDM);
End;

Function TRDWDaemon.Pause: boolean;
Begin
 Result := inherited Pause;
 Application.Log(etDebug, 'RDWDaemon.Pause: ' + BoolToStr(result));
 rdwDaemonDM.StopServer;
End;

Function TRDWDaemon.Continue: boolean;
Begin
 Result := inherited Continue;
 Application.Log(etDebug, 'RDWDaemon.Continue: ' + BoolToStr(result));
 rdwDaemonDM.StartServer;
end;

Function TRDWDaemon.Execute: boolean;
Begin
 Result := inherited Execute;
 Application.Log(etDebug, 'RDWDaemon.Execute: ' + BoolToStr(result));
End;

Function TRDWDaemon.ShutDown: boolean;
Begin
 rdwDaemonDM.StopServer;
 Application.Log(etDebug, 'RDWDaemon.ShutDown: ' + BoolToStr(result));
 Result := inherited ShutDown;
End;

Constructor TRDWDaemonMapper.Create(AOwner: TComponent);
Begin
 Application.Log(etDebug, 'rdwdaemon.Create');
 Inherited Create(AOwner);
 With DaemonDefs.Add as TDaemonDef do
  Begin
   DaemonClassName := 'TRDWDaemon';
   Name            := 'rdwdaemon';
   Description     := 'REST Dataware - Daemon Sample';
   DisplayName     := 'rdwdaemon';
   RunArguments    := '--run';
   Options         := [doAllowStop, doAllowPause];
   Enabled         := true;
   With WinBindings Do
    Begin
     StartType     := stAuto; //stBoot;
     WaitHint      := 0;
     IDTag         := 0;
     ServiceType   := stWin32; // stDevice, stFileSystem;
     ErrorSeverity := esIgnore; //esNormal;
    End;
   LogStatusReport := false;
  End;
 OnInstall   := @Self.ToDoOnInstall;
 OnRun       := @Self.ToDoOnRun;
 OnUnInstall := @Self.ToDoOnUninstall;
 OnDestroy   := @Self.ToDoOnDestroy;
 Application.Log(etDebug, 'rdwdaemon.Createted');
End;

Procedure TRDWDaemonMapper.ToDoOnInstall(Sender: TObject);
Begin
 Application.Log(etDebug, 'rdwdaemon.Install');
End;

Procedure TRDWDaemonMapper.ToDoOnRun(Sender: TObject);
Begin
 Application.Log(etDebug, 'rdwdaemon.Run');
End;

Procedure TRDWDaemonMapper.ToDoOnUnInstall(Sender: TObject);
Begin
 Application.Log(etDebug, 'rdwdaemon.Uninstall');
End;

Procedure TRDWDaemonMapper.ToDoOnDestroy(Sender: TObject);
Begin
 //doesn't comes here
 rdwDaemonDM.StopServer;
 Application.Log(etDebug, 'rdwdaemon.Destroy');
End;

Begin
 RegisterDaemonClass(TRDWDaemon);
 RegisterDaemonMapper(TRDWDaemonMapper);
 RegisterDaemonApplicationClass(TCustomDaemonApplication);
 With Application Do
  Begin
   Title := 'REST Dataware - Daemon Application';
   EventLog.LogType          := ltFile;
   EventLog.DefaultEventType := etDebug;
   EventLog.AppendContent    := true;
   EventLog.FileName := ChangeFileExt(ParamStr(0), '.log');
   Application.CreateForm(TrdwDaemonDM, rdwDaemonDM);
   Initialize;
   Run;
  End;
End.
