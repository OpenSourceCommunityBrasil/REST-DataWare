program RESTDWInstalador;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
   {$ENDIF} {$IFDEF HASAMIGA}
  athreads,
   {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  uconsts in 'src\funcoes\uconsts.pas',
  ulocale in 'src\funcoes\ulocale.pas',
  uprincipal in 'src\telas\uprincipal.pas',
  urestfunctions in 'src\funcoes\urestfunctions.pas';

{$R *.res}

begin
  SetHeapTraceOutput('debug.trc');
  {$if declared(UseHeapTrace)}
  GlobalSkipIfNoLeaks := True; // supported as of debugger version 3.2.0
  {$endIf}
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  //Application.CreateForm(TfPrincipal, fPrincipal);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
