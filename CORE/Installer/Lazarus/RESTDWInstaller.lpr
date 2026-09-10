program RESTDWInstaller;

{$mode objfpc}{$H+}

{$R *.res}

uses
  Interfaces, Forms, SysUtils, uRESTDWLazarusWizard
  {$IFDEF WINDOWS}
  , Windows, ShellApi
  {$ENDIF}
  ;

{$IFDEF WINDOWS}
function RelaunchElevated: Boolean;
var
 LResult: HINST;
begin
 Result := False;
 If (ParamCount > 0) And SameText(ParamStr(1), '--elevated') Then
  Exit;
 LResult := ShellExecute(0, 'runas', PChar(ParamStr(0)), PChar('--elevated'),
                         PChar(ExtractFilePath(ParamStr(0))), SW_SHOWNORMAL);
 Result := LResult > 32;
end;
{$ENDIF}

begin
 {$IFDEF WINDOWS}
 If (ParamCount = 0) Or Not SameText(ParamStr(1), '--elevated') Then
  Begin
   If RelaunchElevated Then
    Halt(0)
   Else
    Halt(1);
  End;
 {$ENDIF}
 RequireDerivedFormResource := False;
 Application.Initialize;
 Application.CreateForm(TfrmRESTDWInstaller, frmRESTDWInstaller);
 Application.Run;
end.
