unit uRESTDWDelphiInstall;

interface

{$IFNDEF FPC}
 {$IFDEF CONDITIONALEXPRESSIONS}
  {$IF RTLVersion >= 23.0}
   {$DEFINE RESTDW_UNITSCOPENAMES}
  {$IFEND}
 {$ENDIF}
{$ENDIF}

uses
  Classes, SysUtils, Windows, TlHelp32,
{$IFDEF RESTDW_UNITSCOPENAMES}
  System.Win.Registry,
{$ELSE}
  Registry,
{$ENDIF}
  Contnrs, uRESTDWInstallerCore;

type
  TRESTDWDelphiIDE = class
  public
    Name: String;
    Version: String;
    RootDir: String;
    RegistryRoot: String;
    Compiler: String;
    RSVars: String;
    IDEPath: String;
    IDE64Path: String;
    HasIDE64: Boolean;
    SupportsVCL: Boolean;
    SupportsFMX: Boolean;
  end;

  TRESTDWDelphiInstaller = class
  private
    FCore: TRESTDWInstallerCore;
    FIDEs: TObjectList;
    procedure DetectRegistryRoot(ARoot: HKEY);
    procedure DetectBDSVendorRoot(ARoot: HKEY; const AVendor: String);
    function ReadRegistryString(ARoot: HKEY; const AKey, AName: String): String;
    function FindIDEProcessByPath(const AIDEPath: String; var AProcessID: Cardinal): Boolean;
    function FindIDEProcess(AIDE: TRESTDWDelphiIDE; var AProcessID: Cardinal): Boolean;
    function FindIDE64Process(AIDE: TRESTDWDelphiIDE; var AProcessID: Cardinal): Boolean;
    function CloseProcess(AProcessID: Cardinal): Boolean;
    function IsDesignPackage(const AProject: String): Boolean;
    function ResolveBPLFile(AIDE: TRESTDWDelphiIDE; const AProject, APlatform: String): String;
    function BuildWithMSBuild(AIDE: TRESTDWDelphiIDE; const AProject,
                              APlatform: String): Boolean;
    function BuildWithDCC(AIDE: TRESTDWDelphiIDE; const AProject: String): Boolean;
    procedure AddLibraryPath(AIDE: TRESTDWDelphiIDE; const APlatform,
                             APath: String);
    procedure RemoveLibraryPath(AIDE: TRESTDWDelphiIDE; const APlatform,
                                APath: String);
    procedure RemoveKnownPackages(AIDE: TRESTDWDelphiIDE; const ADestination: String);
  public
    constructor Create(ACore: TRESTDWInstallerCore);
    destructor Destroy; override;
    procedure DetectIDEs;
    function AnySelectedIDEIsRunning(ASelected: TStrings; var AIDEName: String): Boolean;
    function CloseSelectedIDEs(ASelected: TStrings): Boolean;
    function CompilePackage(AIDE: TRESTDWDelphiIDE; const AProject,
                            APlatform: String): Boolean;
    procedure ConfigureSourcePath(AIDE: TRESTDWDelphiIDE; const APlatform,
                                  ASourcePath: String);
    procedure EnumerateIDEPlatforms(AIDE: TRESTDWDelphiIDE; AList: TStrings);
    function SupportsPlatform(AIDE: TRESTDWDelphiIDE; const APlatform: String): Boolean;
    procedure RegisterDesignPackage(AIDE: TRESTDWDelphiIDE; const ABPLFile,
                                    APlatform: String);
    procedure RegisterCompiledDesignPackage(AIDE: TRESTDWDelphiIDE; const AProject, APlatform: String);
    procedure RemoveInstallation(AIDE: TRESTDWDelphiIDE; const ADestination: String);
    property IDEs: TObjectList read FIDEs;
  end;

implementation

function DelphiFriendlyName(AMajor: Integer): String;
begin
 Case AMajor Of
  2: Result := 'Delphi 8';
  3: Result := 'Delphi 2005';
  4: Result := 'Delphi 2006';
  5: Result := 'Delphi 2007';
  6: Result := 'Delphi 2009';
  7: Result := 'Delphi 2010';
  8: Result := 'Delphi XE';
  9: Result := 'Delphi XE2';
  10: Result := 'Delphi XE3';
  11: Result := 'Delphi XE4';
  12: Result := 'Delphi XE5';
  14: Result := 'Delphi XE6';
  15: Result := 'Delphi XE7';
  16: Result := 'Delphi XE8';
  17: Result := 'Delphi 10 Seattle';
  18: Result := 'Delphi 10.1 Berlin';
  19: Result := 'Delphi 10.2 Tokyo';
  20: Result := 'Delphi 10.3 Rio';
  21: Result := 'Delphi 10.4 Sydney';
  22: Result := 'Delphi 11 Alexandria';
  23: Result := 'Delphi 12 Athens';
  37: Result := 'Delphi 13.1';
 Else
  Result := 'Delphi ' + IntToStr(AMajor);
 End;
end;

function DelphiDisplayName(AMajor: Integer;
  const AProductVersion: String): String;
var
 LVersion: String;
 LValue: Integer;
 LDot: Integer;
begin
 Result := DelphiFriendlyName(AMajor);
 LVersion := Trim(AProductVersion);
 If LVersion = '' Then
  Exit;
 LDot := Pos('.', LVersion);
 If LDot > 0 Then
  Begin
   LValue := StrToIntDef(Copy(LVersion, 1, LDot - 1), 0);
   If (LValue > 0) And (LValue < 30) And (LValue <> AMajor) Then
    Result := 'Delphi ' + LVersion;
  End;
end;

constructor TRESTDWDelphiInstaller.Create(ACore: TRESTDWInstallerCore);
begin
 FCore := ACore;
 FIDEs := TObjectList.Create(True);
end;

destructor TRESTDWDelphiInstaller.Destroy;
begin
 FIDEs.Free;
 inherited Destroy;
end;

function TRESTDWDelphiInstaller.ReadRegistryString(ARoot: HKEY;
  const AKey, AName: String): String;
var
 LRegistry: TRegistry;
begin
 Result := '';
 LRegistry := TRegistry.Create;
 Try
  LRegistry.RootKey := ARoot;
  If LRegistry.OpenKeyReadOnly(AKey) Then
   Begin
    If LRegistry.ValueExists(AName) Then
     Result := LRegistry.ReadString(AName);
    LRegistry.CloseKey;
   End;
 Finally
  LRegistry.Free;
 End;
end;

procedure TRESTDWDelphiInstaller.DetectBDSVendorRoot(ARoot: HKEY;
  const AVendor: String);
var
 I: Integer;
 J: Integer;
 LKey: String;
 LRootDir: String;
 LIDE: TRESTDWDelphiIDE;
 LMajor: Integer;
 LExists: Boolean;
begin
 For I := 1 To 40 Do
  Begin
   LKey := 'Software\' + AVendor + '\BDS\' + IntToStr(I) + '.0';
   LRootDir := ReadRegistryString(ARoot, LKey, 'RootDir');
   If LRootDir <> '' Then
    Begin
     LExists := False;
     For J := 0 To FIDEs.Count - 1 Do
      If SameText(TRESTDWDelphiIDE(FIDEs[J]).RootDir,
                  IncludeTrailingPathDelimiter(LRootDir)) Then
       Begin
        LExists := True;
        Break;
       End;
     If LExists Then
      Continue;
     LIDE := TRESTDWDelphiIDE.Create;
     LIDE.Version := IntToStr(I) + '.0';
     LIDE.Name := DelphiFriendlyName(I);
     LIDE.RootDir := IncludeTrailingPathDelimiter(LRootDir);
     LIDE.RegistryRoot := LKey;
     LIDE.Compiler := LIDE.RootDir + 'bin\dcc32.exe';
     LIDE.RSVars := LIDE.RootDir + 'bin\rsvars.bat';
     LIDE.IDEPath := ReadRegistryString(ARoot, LKey, 'App');
     If LIDE.IDEPath = '' Then
      LIDE.IDEPath := LIDE.RootDir + 'bin\bds.exe';
     LIDE.IDE64Path := ReadRegistryString(ARoot, LKey, 'App x64');
     LIDE.HasIDE64 := (LIDE.IDE64Path <> '') And FileExists(LIDE.IDE64Path);
     LIDE.SupportsVCL := True;
     LMajor := I;
     LIDE.SupportsFMX := LMajor >= 9;
     FIDEs.Add(LIDE);
    End;
  End;
end;

procedure TRESTDWDelphiInstaller.DetectRegistryRoot(ARoot: HKEY);
var
 J: Integer;
 LKey: String;
 LRootDir: String;
 LIDE: TRESTDWDelphiIDE;
 LExists: Boolean;
begin
 DetectBDSVendorRoot(ARoot, 'Embarcadero');
 DetectBDSVendorRoot(ARoot, 'CodeGear');
 DetectBDSVendorRoot(ARoot, 'Borland');
 LKey := 'Software\Borland\Delphi\7.0';
 LRootDir := ReadRegistryString(ARoot, LKey, 'RootDir');
 If LRootDir <> '' Then
  Begin
   LExists := False;
   For J := 0 To FIDEs.Count - 1 Do
    If SameText(TRESTDWDelphiIDE(FIDEs[J]).RootDir,
                IncludeTrailingPathDelimiter(LRootDir)) Then
     Begin
      LExists := True;
      Break;
     End;
   If Not LExists Then
    Begin
     LIDE := TRESTDWDelphiIDE.Create;
     LIDE.Version := '7.0';
     LIDE.Name := 'Delphi 7';
     LIDE.RootDir := IncludeTrailingPathDelimiter(LRootDir);
     LIDE.RegistryRoot := LKey;
     LIDE.Compiler := LIDE.RootDir + 'Bin\dcc32.exe';
     LIDE.RSVars := '';
     LIDE.IDEPath := LIDE.RootDir + 'Bin\delphi32.exe';
     LIDE.IDE64Path := '';
     LIDE.HasIDE64 := False;
     LIDE.SupportsVCL := True;
     LIDE.SupportsFMX := False;
     FIDEs.Add(LIDE);
    End;
  End;
end;

procedure TRESTDWDelphiInstaller.DetectIDEs;
begin
 FIDEs.Clear;
 DetectRegistryRoot(HKEY_CURRENT_USER);
 DetectRegistryRoot(HKEY_LOCAL_MACHINE);
end;

function TRESTDWDelphiInstaller.FindIDEProcessByPath(const AIDEPath: String;
  var AProcessID: Cardinal): Boolean;
var
 LSnapshot: THandle;
 LProcess: TProcessEntry32;
 LModuleSnapshot: THandle;
 LModule: TModuleEntry32;
 LExpected: String;
 LProcessPath: String;
 LProcessName: String;
begin
 Result := False;
 AProcessID := 0;
 If AIDEPath = '' Then
  Exit;
 LExpected := LowerCase(ExpandFileName(AIDEPath));
 LProcessName := ExtractFileName(AIDEPath);
 LSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
 If LSnapshot = INVALID_HANDLE_VALUE Then
  Exit;
 Try
  FillChar(LProcess, SizeOf(LProcess), 0);
  LProcess.dwSize := SizeOf(LProcess);
  If Process32First(LSnapshot, LProcess) Then
   Repeat
    If SameText(ExtractFileName(LProcess.szExeFile), LProcessName) Then
     Begin
      LModuleSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,
                                                 LProcess.th32ProcessID);
      If LModuleSnapshot <> INVALID_HANDLE_VALUE Then
       Try
        FillChar(LModule, SizeOf(LModule), 0);
        LModule.dwSize := SizeOf(LModule);
        If Module32First(LModuleSnapshot, LModule) Then
         Begin
          LProcessPath := LowerCase(ExpandFileName(LModule.szExePath));
          If SameText(LProcessPath, LExpected) Then
           Begin
            AProcessID := LProcess.th32ProcessID;
            Result := True;
            Exit;
           End;
         End;
       Finally
        CloseHandle(LModuleSnapshot);
       End;
     End;
   Until Not Process32Next(LSnapshot, LProcess);
 Finally
  CloseHandle(LSnapshot);
 End;
end;

function TRESTDWDelphiInstaller.FindIDEProcess(AIDE: TRESTDWDelphiIDE;
  var AProcessID: Cardinal): Boolean;
begin
 Result := FindIDEProcessByPath(AIDE.IDEPath, AProcessID);
end;

function TRESTDWDelphiInstaller.FindIDE64Process(AIDE: TRESTDWDelphiIDE;
  var AProcessID: Cardinal): Boolean;
begin
 Result := False;
 AProcessID := 0;
 If Not AIDE.HasIDE64 Then
  Exit;
 Result := FindIDEProcessByPath(AIDE.IDE64Path, AProcessID);
end;

function TRESTDWDelphiInstaller.CloseProcess(AProcessID: Cardinal): Boolean;
var
 LOutput: String;
begin
 Result := FCore.ExecuteCommand('taskkill.exe', '/PID ' + IntToStr(AProcessID),
                                FCore.BasePath, LOutput);
end;

function TRESTDWDelphiInstaller.IsDesignPackage(const AProject: String): Boolean;
var
 LFile: String;
 L: TStringList;
begin
 LFile := AProject;
 If LowerCase(ExtractFileExt(LFile)) = '.dproj' Then
  LFile := ChangeFileExt(LFile, '.dpk');
 Result := False;
 If Not FileExists(LFile) Then
  Exit;
 L := TStringList.Create;
 Try
  L.LoadFromFile(LFile);
  Result := Pos('{$DESIGNONLY}', UpperCase(L.Text)) > 0;
 Finally
  L.Free;
 End;
end;

function TRESTDWDelphiInstaller.ResolveBPLFile(AIDE: TRESTDWDelphiIDE;
  const AProject, APlatform: String): String;
var
 LOutput: String;
 LName: String;
 LCandidate: String;
 LCommand: String;
begin
 Result := '';
 LName := ChangeFileExt(ExtractFileName(AProject), '.bpl');
 If AIDE.RSVars <> '' Then
  Begin
   If SameText(APlatform, 'Win64') And AIDE.HasIDE64 Then
    LCommand := '/C call "' + AIDE.RSVars +
                '" && echo %BDSCOMMONDIR%\Bpl\Win64\' + LName
   Else
    LCommand := '/C call "' + AIDE.RSVars +
                '" && echo %BDSCOMMONDIR%\Bpl\' + LName;
   If FCore.ExecuteCommand('cmd.exe', LCommand, ExtractFilePath(AProject), LOutput) Then
    Begin
     LCandidate := Trim(LOutput);
     If FileExists(LCandidate) Then
      Begin
       Result := LCandidate;
       Exit;
      End;
    End;
  End;
 LCandidate := ExtractFilePath(AProject) + APlatform + '\Release\' + LName;
 If FileExists(LCandidate) Then
  Begin
   Result := LCandidate;
   Exit;
  End;
 LCandidate := ExtractFilePath(AProject) + LName;
 If FileExists(LCandidate) Then
  Result := LCandidate;
end;

function TRESTDWDelphiInstaller.AnySelectedIDEIsRunning(ASelected: TStrings;
  var AIDEName: String): Boolean;
var
 I: Integer;
 LIDE: TRESTDWDelphiIDE;
 LProcessID: Cardinal;
begin
 Result := False;
 AIDEName := '';
 For I := 0 To FIDEs.Count - 1 Do
  Begin
   LIDE := TRESTDWDelphiIDE(FIDEs[I]);
   If (ASelected.IndexOf(LIDE.Version + '|VCL') >= 0) Or
      (ASelected.IndexOf(LIDE.Version + '|FMX') >= 0) Then
    If FindIDEProcess(LIDE, LProcessID) Or
       FindIDE64Process(LIDE, LProcessID) Then
     Begin
      AIDEName := LIDE.Name;
      Result := True;
      Exit;
     End;
  End;
end;

function TRESTDWDelphiInstaller.CloseSelectedIDEs(ASelected: TStrings): Boolean;
var
 I: Integer;
 LIDE: TRESTDWDelphiIDE;
 LProcessID: Cardinal;
begin
 Result := True;
 For I := 0 To FIDEs.Count - 1 Do
  Begin
   LIDE := TRESTDWDelphiIDE(FIDEs[I]);
   If (ASelected.IndexOf(LIDE.Version + '|VCL') >= 0) Or
      (ASelected.IndexOf(LIDE.Version + '|FMX') >= 0) Then
    Begin
     If FindIDEProcess(LIDE, LProcessID) Then
      If Not CloseProcess(LProcessID) Then
       Begin
        Result := False;
        Exit;
       End;
     If FindIDE64Process(LIDE, LProcessID) Then
      If Not CloseProcess(LProcessID) Then
       Begin
        Result := False;
        Exit;
       End;
    End;
  End;
end;

function TRESTDWDelphiInstaller.BuildWithMSBuild(AIDE: TRESTDWDelphiIDE;
  const AProject, APlatform: String): Boolean;
var
 LOutput: String;
 LCommand: String;
begin
 LCommand := '/C call "' + AIDE.RSVars + '" && msbuild "' + AProject +
             '" /t:Build /p:Config=Release /p:Platform=' + APlatform;
 Result := FCore.ExecuteCommand('cmd.exe', LCommand,
                                ExtractFilePath(AProject), LOutput);
end;

function TRESTDWDelphiInstaller.BuildWithDCC(AIDE: TRESTDWDelphiIDE;
  const AProject: String): Boolean;
var
 LOutput: String;
begin
 Result := FCore.ExecuteCommand(AIDE.Compiler, '"' + AProject + '"',
                                ExtractFilePath(AProject), LOutput);
end;

function TRESTDWDelphiInstaller.CompilePackage(AIDE: TRESTDWDelphiIDE;
  const AProject, APlatform: String): Boolean;
var
 LProject: String;
begin
 LProject := AProject;
 If (AIDE.RSVars <> '') And FileExists(ChangeFileExt(AProject, '.dproj')) Then
  Result := BuildWithMSBuild(AIDE, ChangeFileExt(AProject, '.dproj'), APlatform)
 Else
  Begin
   If LowerCase(ExtractFileExt(LProject)) = '.dproj' Then
    LProject := ChangeFileExt(LProject, '.dpk');
   Result := BuildWithDCC(AIDE, LProject);
  End;
end;

procedure TRESTDWDelphiInstaller.AddLibraryPath(AIDE: TRESTDWDelphiIDE;
  const APlatform, APath: String);
var
 LRegistry: TRegistry;
 LKey: String;
 LValue: String;
begin
 LRegistry := TRegistry.Create;
 Try
  LRegistry.RootKey := HKEY_CURRENT_USER;
  If AIDE.Version = '7.0' Then
   LKey := AIDE.RegistryRoot + '\Library'
  Else
   LKey := AIDE.RegistryRoot + '\Library\' + APlatform;
  If LRegistry.OpenKey(LKey, True) Then
   Begin
    If LRegistry.ValueExists('Search Path') Then
     LValue := LRegistry.ReadString('Search Path')
    Else
     LValue := '';
    If Pos(';' + LowerCase(APath) + ';', ';' + LowerCase(LValue) + ';') = 0 Then
     Begin
      If (LValue <> '') And (LValue[Length(LValue)] <> ';') Then
       LValue := LValue + ';';
      LValue := LValue + APath;
      LRegistry.WriteString('Search Path', LValue);
     End;
    LRegistry.CloseKey;
   End;
 Finally
  LRegistry.Free;
 End;
end;



procedure TRESTDWDelphiInstaller.RemoveLibraryPath(AIDE: TRESTDWDelphiIDE;
  const APlatform, APath: String);
var
 LRegistry : TRegistry;
 LKey      : String;
 LValue    : String;
 LParts    : TStringList;
 I         : Integer;
 LNewValue : String;
begin
 LRegistry := TRegistry.Create;
 LParts := TStringList.Create;
 Try
  LRegistry.RootKey := HKEY_CURRENT_USER;
  If AIDE.Version = '7.0' Then
   LKey := AIDE.RegistryRoot + '\Library'
  Else
   LKey := AIDE.RegistryRoot + '\Library\' + APlatform;
  If Not LRegistry.OpenKey(LKey, False) Then
   Exit;
  If Not LRegistry.ValueExists('Search Path') Then
   Exit;
  LValue := LRegistry.ReadString('Search Path');
  LParts.Delimiter := ';';
  LParts.StrictDelimiter := True;
  LParts.DelimitedText := LValue;
  LNewValue := '';
  For I := 0 To LParts.Count - 1 Do
   If (Trim(LParts[I]) <> '') And Not SameText(ExcludeTrailingPathDelimiter(Trim(LParts[I])),
                                               ExcludeTrailingPathDelimiter(APath)) Then
    Begin
     If LNewValue <> '' Then
      LNewValue := LNewValue + ';';
     LNewValue := LNewValue + LParts[I];
    End;
  LRegistry.WriteString('Search Path', LNewValue);
 Finally
  LParts.Free;
  LRegistry.Free;
 End;
end;

procedure TRESTDWDelphiInstaller.RemoveKnownPackages(AIDE: TRESTDWDelphiIDE;
  const ADestination: String);
var
 LRegistry : TRegistry;
 LNames    : TStringList;
 LKey      : String;
 LRoot     : String;
 I         : Integer;
 J         : Integer;
begin
 LRoot := LowerCase(IncludeTrailingPathDelimiter(ExpandFileName(ADestination)));
 LNames := TStringList.Create;
 LRegistry := TRegistry.Create;
 Try
  LRegistry.RootKey := HKEY_CURRENT_USER;
  For J := 0 To 1 Do
   Begin
    If J = 0 Then
     LKey := AIDE.RegistryRoot + '\Known Packages'
    Else
     LKey := AIDE.RegistryRoot + '\Known Packages x64';
    If LRegistry.OpenKey(LKey, False) Then
     Begin
      LNames.Clear;
      LRegistry.GetValueNames(LNames);
      For I := LNames.Count - 1 Downto 0 Do
       If Pos(LRoot, LowerCase(ExpandFileName(LNames[I]))) = 1 Then
        LRegistry.DeleteValue(LNames[I]);
      LRegistry.CloseKey;
     End;
   End;
 Finally
  LRegistry.Free;
  LNames.Free;
 End;
end;

procedure TRESTDWDelphiInstaller.RemoveInstallation(AIDE: TRESTDWDelphiIDE;
  const ADestination: String);
var
 LPlatforms : TStringList;
 LSource    : String;
 I          : Integer;
begin
 If AIDE = Nil Then
  Exit;
 LSource := IncludeTrailingPathDelimiter(ADestination) + 'Source';
 LPlatforms := TStringList.Create;
 Try
  EnumerateIDEPlatforms(AIDE, LPlatforms);
  If AIDE.Version = '7.0' Then
   RemoveLibraryPath(AIDE, '', LSource)
  Else
   For I := 0 To LPlatforms.Count - 1 Do
    RemoveLibraryPath(AIDE, LPlatforms[I], LSource);
  RemoveKnownPackages(AIDE, ADestination);
 Finally
  LPlatforms.Free;
 End;
end;

procedure TRESTDWDelphiInstaller.EnumerateIDEPlatforms(AIDE: TRESTDWDelphiIDE;
  AList: TStrings);
var
 LBin: String;
 procedure AddIfCompiler(const APlatform, ACompiler: String);
 begin
  If FileExists(LBin + ACompiler) Then
   If AList.IndexOf(APlatform) < 0 Then
    AList.Add(APlatform);
 end;
begin
 AList.Clear;
 LBin := IncludeTrailingPathDelimiter(AIDE.RootDir + 'bin');
 AddIfCompiler('Win32', 'dcc32.exe');
 AddIfCompiler('Win64', 'dcc64.exe');
 AddIfCompiler('Android', 'dccaarm.exe');
 AddIfCompiler('Android64', 'dccaarm64.exe');
 AddIfCompiler('iOSDevice32', 'dcciosarm.exe');
 AddIfCompiler('iOSDevice64', 'dcciosarm64.exe');
 AddIfCompiler('iOSSimARM64', 'dcciossimarm64.exe');
 AddIfCompiler('OSX32', 'dccosx.exe');
 AddIfCompiler('OSX64', 'dccosx64.exe');
 AddIfCompiler('OSXARM64', 'dccosxarm64.exe');
 AddIfCompiler('Linux64', 'dcclinux64.exe');
 If (AIDE.Version = '7.0') And (AList.IndexOf('Win32') < 0) Then
  If FileExists(AIDE.Compiler) Then
   AList.Add('Win32');
end;

function TRESTDWDelphiInstaller.SupportsPlatform(AIDE: TRESTDWDelphiIDE;
  const APlatform: String): Boolean;
var
 LPlatforms: TStringList;
begin
 LPlatforms := TStringList.Create;
 Try
  EnumerateIDEPlatforms(AIDE, LPlatforms);
  Result := LPlatforms.IndexOf(APlatform) >= 0;
 Finally
  LPlatforms.Free;
 End;
end;

procedure TRESTDWDelphiInstaller.ConfigureSourcePath(AIDE: TRESTDWDelphiIDE;
  const APlatform, ASourcePath: String);
begin
 AddLibraryPath(AIDE, APlatform, ASourcePath);
end;

procedure TRESTDWDelphiInstaller.RegisterDesignPackage(AIDE: TRESTDWDelphiIDE;
  const ABPLFile, APlatform: String);
var
 LRegistry: TRegistry;
 LKey: String;
begin
 LRegistry := TRegistry.Create;
 Try
  LRegistry.RootKey := HKEY_CURRENT_USER;
  If SameText(APlatform, 'Win64') And AIDE.HasIDE64 Then
   LKey := AIDE.RegistryRoot + '\Known Packages x64'
  Else
   LKey := AIDE.RegistryRoot + '\Known Packages';
  If LRegistry.OpenKey(LKey, True) Then
   Begin
    LRegistry.WriteString(ABPLFile, 'REST Dataware Components');
    LRegistry.CloseKey;
   End;
 Finally
  LRegistry.Free;
 End;
end;


procedure TRESTDWDelphiInstaller.RegisterCompiledDesignPackage(
  AIDE: TRESTDWDelphiIDE; const AProject, APlatform: String);
var
 LBPL: String;
begin
 If Not IsDesignPackage(AProject) Then
  Exit;
 LBPL := ResolveBPLFile(AIDE, AProject, APlatform);
 If LBPL <> '' Then
  RegisterDesignPackage(AIDE, LBPL, APlatform);
end;

end.
