unit uRESTDWLazarusInstall;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, uRESTDWInstallerCore;

type
  TRESTDWLazarusInstaller = class
  private
    FCore: TRESTDWInstallerCore;
    FLazBuild: String;
    FFPC: String;
    function FindTool(const AName: String): String;
    function ReadCompilerTarget(const ACompiler: String; var AOS, ACPU: String): Boolean;
  public
    constructor Create(ACore: TRESTDWInstallerCore);
    function DetectTools: Boolean;
    function IDEIsRunning: Boolean;
    function CloseIDE: Boolean;
    procedure DetectTargets(AList: TStrings);
    function CompilePackage(const APackage, ATarget: String): Boolean;
    function InstallPackages(APackages: TStrings): Boolean;
    function RemovePackages(APackages: TStrings): Boolean;
    function RebuildIDE: Boolean;
    property LazBuild: String read FLazBuild;
    property FPC: String read FFPC;
  end;

implementation

constructor TRESTDWLazarusInstaller.Create(ACore: TRESTDWInstallerCore);
begin
 FCore := ACore;
end;

function TRESTDWLazarusInstaller.FindTool(const AName: String): String;
var
 LProcess: TProcess;
 LOutput: TStringList;
begin
 Result := '';
 LProcess := TProcess.Create(nil);
 LOutput := TStringList.Create;
 Try
  {$IFDEF WINDOWS}
  LProcess.Executable := GetEnvironmentVariable('COMSPEC');
  LProcess.Parameters.Add('/C');
  LProcess.Parameters.Add('where ' + AName);
  {$ELSE}
  LProcess.Executable := '/bin/sh';
  LProcess.Parameters.Add('-c');
  LProcess.Parameters.Add('command -v ' + AName);
  {$ENDIF}
  LProcess.Options := [poUsePipes, poWaitOnExit];
  LProcess.Execute;
  LOutput.LoadFromStream(LProcess.Output);
  If (LProcess.ExitStatus = 0) And (LOutput.Count > 0) Then
   Result := Trim(LOutput[0]);
 Finally
  LOutput.Free;
  LProcess.Free;
 End;
end;

function TRESTDWLazarusInstaller.ReadCompilerTarget(const ACompiler: String;
  var AOS, ACPU: String): Boolean;
var
 LOutput: String;
begin
 Result := False;
 AOS := '';
 ACPU := '';
 If Not FCore.ExecuteCommand(ACompiler, '-iTO', FCore.BasePath, LOutput) Then
  Exit;
 AOS := Trim(LOutput);
 If Not FCore.ExecuteCommand(ACompiler, '-iTP', FCore.BasePath, LOutput) Then
  Exit;
 ACPU := Trim(LOutput);
 Result := (AOS <> '') And (ACPU <> '');
end;

procedure TRESTDWLazarusInstaller.DetectTargets(AList: TStrings);
var
 LDir: String;
 LSearch: TSearchRec;
 LCompiler: String;
 LOS: String;
 LCPU: String;
 LTarget: String;
begin
 AList.Clear;
 If Not DetectTools Then
  Exit;
 If ReadCompilerTarget(FFPC, LOS, LCPU) Then
  Begin
   LTarget := LOS + '/' + LCPU;
   AList.Add(LTarget);
  End;
 LDir := IncludeTrailingPathDelimiter(ExtractFilePath(FFPC));
 {$IFDEF WINDOWS}
 If FindFirst(LDir + 'ppc*.exe', faAnyFile, LSearch) = 0 Then
 {$ELSE}
 If FindFirst(LDir + 'ppc*', faAnyFile, LSearch) = 0 Then
 {$ENDIF}
  Try
   Repeat
    If (LSearch.Attr And faDirectory) = 0 Then
     Begin
      LCompiler := LDir + LSearch.Name;
      If ReadCompilerTarget(LCompiler, LOS, LCPU) Then
       Begin
        LTarget := LOS + '/' + LCPU;
        If AList.IndexOf(LTarget) < 0 Then
         AList.Add(LTarget);
       End;
     End;
   Until FindNext(LSearch) <> 0;
  Finally
   FindClose(LSearch);
  End;
end;

function TRESTDWLazarusInstaller.CompilePackage(const APackage,
  ATarget: String): Boolean;
var
 LOutput: String;
 LPos: Integer;
 LOS: String;
 LCPU: String;
 LParameters: String;
begin
 Result := DetectTools;
 If Not Result Then
  Exit;
 LPos := Pos('/', ATarget);
 If LPos > 0 Then
  Begin
   LOS := Copy(ATarget, 1, LPos - 1);
   LCPU := Copy(ATarget, LPos + 1, MaxInt);
   LParameters := '--os=' + LOS + ' --cpu=' + LCPU + ' "' + APackage + '"';
  End
 Else
  LParameters := '"' + APackage + '"';
 Result := FCore.ExecuteCommand(FLazBuild, LParameters,
                                ExtractFilePath(APackage), LOutput);
end;

function TRESTDWLazarusInstaller.DetectTools: Boolean;
begin
 FLazBuild := FindTool('lazbuild');
 FFPC := FindTool('fpc');
 Result := (FLazBuild <> '') And (FFPC <> '');
end;

function TRESTDWLazarusInstaller.IDEIsRunning: Boolean;
var
 LProcess: TProcess;
begin
 Result := False;
 LProcess := TProcess.Create(nil);
 Try
  {$IFDEF WINDOWS}
  LProcess.Executable := GetEnvironmentVariable('COMSPEC');
  LProcess.Parameters.Add('/C');
  LProcess.Parameters.Add('tasklist /FI "IMAGENAME eq lazarus.exe" | find /I "lazarus.exe" >nul');
  {$ELSE}
  LProcess.Executable := '/bin/sh';
  LProcess.Parameters.Add('-c');
  LProcess.Parameters.Add('pgrep -x lazarus >/dev/null 2>&1');
  {$ENDIF}
  LProcess.Options := [poWaitOnExit];
  LProcess.Execute;
  Result := LProcess.ExitStatus = 0;
 Finally
  LProcess.Free;
 End;
end;

function TRESTDWLazarusInstaller.CloseIDE: Boolean;
var
 LOutput: String;
begin
 {$IFDEF WINDOWS}
 Result := FCore.ExecuteCommand('taskkill.exe', '/IM lazarus.exe', FCore.BasePath, LOutput);
 {$ELSE}
 Result := FCore.ExecuteCommand('/usr/bin/pkill', '-TERM -x lazarus', FCore.BasePath, LOutput);
 {$ENDIF}
end;

function TRESTDWLazarusInstaller.InstallPackages(APackages: TStrings): Boolean;
var
 I: Integer;
 LOutput: String;
begin
 Result := DetectTools;
 If Not Result Then
  Exit;
 FCore.SortPackagesByDependencies(APackages);
 For I := 0 To APackages.Count - 1 Do
  Begin
   Result := FCore.ExecuteCommand(FLazBuild,
                                  '--add-package-link="' + APackages[I] + '"',
                                  ExtractFilePath(APackages[I]), LOutput);
   If Not Result Then
    Exit;
  End;
 Result := RebuildIDE;
end;


function TRESTDWLazarusInstaller.RemovePackages(APackages: TStrings): Boolean;
var
 I       : Integer;
 LOutput : String;
begin
 Result := False;
 If Not DetectTools Then
  Exit;
 If IDEIsRunning Then
  Exit;
 Result := True;
 For I := 0 To APackages.Count - 1 Do
  If Not FCore.ExecuteCommand(FLazBuild,
                              '--remove-package-link="' + APackages[I] + '"',
                              ExtractFilePath(APackages[I]), LOutput) Then
   Result := False;
 If Result Then
  Result := RebuildIDE;
end;

function TRESTDWLazarusInstaller.RebuildIDE: Boolean;
var
 LOutput: String;
begin
 Result := FCore.ExecuteCommand(FLazBuild, '--build-ide=', FCore.BasePath, LOutput);
end;

end.
