unit uRESTDWInstallerCore;

{$IFDEF FPC}
 {$mode objfpc}{$H+}
{$ENDIF}

interface

{$IFNDEF FPC}
 {$IFDEF CONDITIONALEXPRESSIONS}
  {$IF RTLVersion >= 23.0}
   {$DEFINE RESTDW_UNITSCOPENAMES}
  {$IFEND}
 {$ENDIF}
{$ENDIF}

uses
  Classes, SysUtils, IniFiles
  {$IFDEF FPC}, Process{$ENDIF}
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

type
  TRESTDWInstallSource = (isLocal, isCab, isSVNTrunk, isSVNBranch);
  TRESTDWInstallAction = (iaNewInstall, iaModifyInstall, iaRemoveInstall);

  TRESTDWDistributionVersion = record
    VersionInfo: String;
    Release: String;
    CodeProject: String;
    FullVersion: String;
    DialogTitle: String;
    LicenseStatus: String;
    SVNRevision: String;
  end;

  TRESTDWInstallerLogEvent = procedure(const AText: String) of object;
  TRESTDWInstallerProgressEvent = procedure(AValue, AMaximum: Integer;
                                             const AText: String) of object;

  TRESTDWInstallerCore = class
  private
    FBasePath: String;
    FWorkPath: String;
    FSourcePath: String;
    FDestinationPath: String;
    FOnLog: TRESTDWInstallerLogEvent;
    FOnProgress: TRESTDWInstallerProgressEvent;
    FVersion: TRESTDWDistributionVersion;
    FCommandProgressText: String;
    FCommandProgressStart: Integer;
    FCommandProgressEnd: Integer;
    FCommandProgressValue: Integer;
    FCommandProgressCounter: Integer;
    procedure DoLog(const AText: String);
    procedure DoProgress(AValue, AMaximum: Integer; const AText: String);
    procedure BeginCommandProgress(const AText: String; AStart, AEnd: Integer);
    procedure CommandProgressPulse;
    procedure EndCommandProgress;
    function Quote(const AValue: String): String;
    function FindExecutable(const AName: String): String;
    function ExtractConstValue(const AText, AConstName: String): String;
    function ResolveDistributionRoot(const APath: String): String;
    function ResolveSourceDirectory(const AName: String): String;
    function CountFiles(const APath: String): Integer;
    function RemoveDirectoryTree(const APath: String): Boolean;
    function InstallationStateFile: String;
    procedure CopyDirectory(const ASource, ADestination: String;
                            var ACurrent: Integer; ATotal: Integer);
  public
    constructor Create(const ABasePath: String);
    function ExecuteCommand(const AExecutable, AParameters, AWorkingDirectory: String;
                            var AOutput: String): Boolean;
    function PrepareSource(ASource: TRESTDWInstallSource): Boolean;
    function ReadDistributionVersion: TRESTDWDistributionVersion;
    function DetectPackedSource: TRESTDWInstallSource;
    function CopyDistribution: Boolean;
    function DetectInstallation(out ADestination: String): Boolean;
    procedure SaveInstallationState;
    procedure ClearInstallationState;
    function RemoveInstalledDistribution: Boolean;
    procedure EnumeratePackages(AList: TStrings; const APackageRoot: String);
    procedure EnumeratePlatforms(const AProjectFile: String; AList: TStrings);
    procedure SortPackagesByDependencies(AList: TStrings);
    procedure BuildDelphiProjectGroup(const AFileName: String; AProjects: TStrings);
    procedure BuildLazarusProjectGroup(const AFileName: String; AProjects: TStrings);
    property BasePath: String read FBasePath;
    property WorkPath: String read FWorkPath;
    property SourcePath: String read FSourcePath;
    property DestinationPath: String read FDestinationPath write FDestinationPath;
    property Version: TRESTDWDistributionVersion read FVersion;
    property OnLog: TRESTDWInstallerLogEvent read FOnLog write FOnLog;
    property OnProgress: TRESTDWInstallerProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

procedure RESTDWFindClose(var ASearchRec: TSearchRec);
begin
{$IFDEF FPC}
  SysUtils.FindClose(ASearchRec);
{$ELSE}
 {$IFDEF RESTDW_UNITSCOPENAMES}
  System.SysUtils.FindClose(ASearchRec);
 {$ELSE}
  SysUtils.FindClose(ASearchRec);
 {$ENDIF}
{$ENDIF}
end;


const
  cDistributionDirectories: Array[0..4] Of String =
   ('Source', 'Packages', 'Images', 'Extras', 'Demos');
  cSVNTrunkURL = 'https://svn.code.sf.net/p/rest-dataware-componentes/dataware/trunk';
  cSVNBranchURL = 'https://svn.code.sf.net/p/rest-dataware-componentes/dataware/branch';

constructor TRESTDWInstallerCore.Create(const ABasePath: String);
begin
 FBasePath := IncludeTrailingPathDelimiter(ExpandFileName(ABasePath));
 FWorkPath := IncludeTrailingPathDelimiter(FBasePath + '.RESTDWInstallerWork');
 FSourcePath := FBasePath;
 FillChar(FVersion, SizeOf(FVersion), 0);
end;

procedure TRESTDWInstallerCore.DoLog(const AText: String);
begin
 If Assigned(FOnLog) Then
  FOnLog(AText);
end;

procedure TRESTDWInstallerCore.DoProgress(AValue, AMaximum: Integer;
  const AText: String);
begin
 If Assigned(FOnProgress) Then
  FOnProgress(AValue, AMaximum, AText);
end;

procedure TRESTDWInstallerCore.BeginCommandProgress(const AText: String;
  AStart, AEnd: Integer);
begin
 FCommandProgressText := AText;
 FCommandProgressStart := AStart;
 FCommandProgressEnd := AEnd;
 FCommandProgressValue := AStart;
 FCommandProgressCounter := 0;
 DoProgress(FCommandProgressValue, 100, FCommandProgressText);
end;

procedure TRESTDWInstallerCore.CommandProgressPulse;
begin
 If FCommandProgressText = '' Then
  Exit;
 Inc(FCommandProgressCounter);
 If FCommandProgressCounter < 20 Then
  Exit;
 FCommandProgressCounter := 0;
 If FCommandProgressValue < FCommandProgressEnd - 1 Then
  Inc(FCommandProgressValue);
 DoProgress(FCommandProgressValue, 100, FCommandProgressText);
end;

procedure TRESTDWInstallerCore.EndCommandProgress;
begin
 If FCommandProgressText <> '' Then
  DoProgress(FCommandProgressEnd, 100, FCommandProgressText);
 FCommandProgressText := '';
 FCommandProgressStart := 0;
 FCommandProgressEnd := 0;
 FCommandProgressValue := 0;
 FCommandProgressCounter := 0;
end;

function TRESTDWInstallerCore.Quote(const AValue: String): String;
begin
 Result := '"' + AValue + '"';
end;

function TRESTDWInstallerCore.FindExecutable(const AName: String): String;
var
 LPath: String;
 LOutput: String;
begin
 Result := '';
 LPath := FBasePath + AName;
 If FileExists(LPath) Then
  Begin
   Result := LPath;
   Exit;
  End;
 {$IFDEF MSWINDOWS}
 If ExecuteCommand('where.exe', AName, FBasePath, LOutput) Then
 {$ELSE}
 If ExecuteCommand('/usr/bin/env', 'which ' + AName, FBasePath, LOutput) Then
 {$ENDIF}
  Begin
   LOutput := Trim(LOutput);
   If Pos(#10, LOutput) > 0 Then
    LOutput := Copy(LOutput, 1, Pos(#10, LOutput) - 1);
   If FileExists(LOutput) Then
    Result := LOutput;
  End;
end;

function TRESTDWInstallerCore.ExecuteCommand(const AExecutable, AParameters,
  AWorkingDirectory: String; var AOutput: String): Boolean;
{$IFDEF FPC}
var
 LProcess: TProcess;
 LBuffer: Array[0..2047] Of Byte;
 LCount: LongInt;
 LStream: TMemoryStream;
{$ELSE}
{$IFDEF MSWINDOWS}
var
 LStartup: TStartupInfo;
 LProcessInfo: TProcessInformation;
 LSecurity: TSecurityAttributes;
 LReadPipe: THandle;
 LWritePipe: THandle;
 LCommand: String;
 LExitCode: Cardinal;
 LBuffer: Array[0..2047] Of AnsiChar;
 LRead: Cardinal;
 LAvailable: Cardinal;
 LChunk: AnsiString;
{$ENDIF}
{$ENDIF}
begin
 Result := False;
 AOutput := '';
 {$IFDEF FPC}
 LProcess := TProcess.Create(nil);
 LStream := TMemoryStream.Create;
 Try
  {$IFDEF MSWINDOWS}
  LProcess.Executable := SysUtils.GetEnvironmentVariable('COMSPEC');
  LProcess.Parameters.Add('/C');
  LProcess.Parameters.Add(Quote(AExecutable) + ' ' + AParameters);
  {$ELSE}
  LProcess.Executable := '/bin/sh';
  LProcess.Parameters.Add('-c');
  LProcess.Parameters.Add(Quote(AExecutable) + ' ' + AParameters);
  {$ENDIF}
  LProcess.CurrentDirectory := AWorkingDirectory;
  LProcess.Options := [poUsePipes, poStderrToOutPut];
  LProcess.Execute;
  While LProcess.Running Or (LProcess.Output.NumBytesAvailable > 0) Do
   Begin
    While LProcess.Output.NumBytesAvailable > 0 Do
     Begin
      LCount := LProcess.Output.Read(LBuffer, SizeOf(LBuffer));
      If LCount > 0 Then
       LStream.WriteBuffer(LBuffer, LCount);
     End;
    CommandProgressPulse;
    Sleep(10);
   End;
  LStream.Position := 0;
  SetLength(AOutput, LStream.Size);
  If LStream.Size > 0 Then
   LStream.ReadBuffer(AOutput[1], LStream.Size);
  Result := LProcess.ExitStatus = 0;
 Finally
  LStream.Free;
  LProcess.Free;
 End;
 {$ELSE}
 {$IFDEF MSWINDOWS}
 FillChar(LSecurity, SizeOf(LSecurity), 0);
 LSecurity.nLength := SizeOf(LSecurity);
 LSecurity.bInheritHandle := True;
 If Not CreatePipe(LReadPipe, LWritePipe, @LSecurity, 0) Then
  Exit;
 Try
  SetHandleInformation(LReadPipe, HANDLE_FLAG_INHERIT, 0);
  FillChar(LStartup, SizeOf(LStartup), 0);
  FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);
  LStartup.cb := SizeOf(LStartup);
  LStartup.dwFlags := STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW;
  LStartup.wShowWindow := SW_HIDE;
  LStartup.hStdOutput := LWritePipe;
  LStartup.hStdError := LWritePipe;
  LStartup.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
  LCommand := Quote(AExecutable) + ' ' + AParameters;
  UniqueString(LCommand);
  If CreateProcess(nil, PChar(LCommand), nil, nil, True, CREATE_NO_WINDOW, nil,
                   PChar(AWorkingDirectory), LStartup, LProcessInfo) Then
   Begin
    CloseHandle(LWritePipe);
    LWritePipe := 0;
    Repeat
     LAvailable := 0;
     If PeekNamedPipe(LReadPipe, nil, 0, nil, @LAvailable, nil) And
        (LAvailable > 0) Then
      Begin
       If LAvailable > SizeOf(LBuffer) Then
        LAvailable := SizeOf(LBuffer);
       If ReadFile(LReadPipe, LBuffer, LAvailable, LRead, nil) And (LRead > 0) Then
        Begin
         SetString(LChunk, PAnsiChar(@LBuffer[0]), LRead);
         AOutput := AOutput + String(LChunk);
        End;
      End
     Else
      Sleep(10);
     CommandProgressPulse;
    Until WaitForSingleObject(LProcessInfo.hProcess, 0) <> WAIT_TIMEOUT;
    Repeat
     LAvailable := 0;
     If Not PeekNamedPipe(LReadPipe, nil, 0, nil, @LAvailable, nil) Then
      Break;
     If LAvailable = 0 Then
      Break;
     If LAvailable > SizeOf(LBuffer) Then
      LAvailable := SizeOf(LBuffer);
     If ReadFile(LReadPipe, LBuffer, LAvailable, LRead, nil) And (LRead > 0) Then
      Begin
       SetString(LChunk, PAnsiChar(@LBuffer[0]), LRead);
       AOutput := AOutput + String(LChunk);
      End;
    Until False;
    GetExitCodeProcess(LProcessInfo.hProcess, LExitCode);
    CloseHandle(LProcessInfo.hThread);
    CloseHandle(LProcessInfo.hProcess);
    Result := LExitCode = 0;
   End;
 Finally
  If LWritePipe <> 0 Then
   CloseHandle(LWritePipe);
  CloseHandle(LReadPipe);
 End;
 {$ENDIF}
 {$ENDIF}
end;

function TRESTDWInstallerCore.DetectPackedSource: TRESTDWInstallSource;
begin
 If FileExists(FBasePath + 'CORE.CAB') Then
  Result := isCab
 Else
  If FileExists(FBasePath + 'CORE.tar.gz') Then
   Result := isCab
  Else
   Result := isLocal;
end;

function TRESTDWInstallerCore.ResolveDistributionRoot(const APath: String): String;
var
 LRoot: String;
begin
 LRoot := IncludeTrailingPathDelimiter(APath);
 If DirectoryExists(LRoot + 'Source') And DirectoryExists(LRoot + 'Packages') Then
  Result := LRoot
 Else
  If DirectoryExists(LRoot + 'CORE' + PathDelim + 'Source') And
     DirectoryExists(LRoot + 'CORE' + PathDelim + 'Packages') Then
   Result := IncludeTrailingPathDelimiter(LRoot + 'CORE')
  Else
   Result := LRoot;
end;

function TRESTDWInstallerCore.ResolveSourceDirectory(const AName: String): String;
var
 LRoot: String;
begin
 LRoot := IncludeTrailingPathDelimiter(FSourcePath);
 Result := LRoot + AName;
 If DirectoryExists(Result) Then
  Exit;
 If SameText(AName, 'Demos') Then
  Begin
   If DirectoryExists(LRoot + 'demos') Then
    Result := LRoot + 'demos';
  End;
end;

function TRESTDWInstallerCore.PrepareSource(ASource: TRESTDWInstallSource): Boolean;
var
 LExecutable: String;
 LParameters: String;
 LOutput: String;
 LURL: String;
begin
 Result := False;
 DoLog('Preparando fonte da instalação...');
 DoProgress(2, 100, 'Preparando fonte da instalação...');
 If ASource = isLocal Then
  Begin
   FSourcePath := ResolveDistributionRoot(FBasePath);
   Result := DirectoryExists(FSourcePath + 'Source') And
             DirectoryExists(FSourcePath + 'Packages');
   If Result Then
    DoProgress(20, 100, 'Fonte local validada.');
  End
 Else
  If ASource = isCab Then
   Begin
    ForceDirectories(FWorkPath);
    BeginCommandProgress('Extraindo pacote da distribuição...', 4, 20);
    {$IFDEF MSWINDOWS}
    If FileExists(FBasePath + 'CORE.CAB') Then
     Begin
      LExecutable := FindExecutable('expand.exe');
      If LExecutable <> '' Then
       Result := ExecuteCommand(LExecutable,
                                '-F:* ' + Quote(FBasePath + 'CORE.CAB') + ' ' + Quote(FWorkPath),
                                FBasePath, LOutput);
     End
    Else
    {$ENDIF}
     Begin
      LExecutable := FindExecutable('tar');
      If LExecutable <> '' Then
       Result := ExecuteCommand(LExecutable,
                                '-xzf ' + Quote(FBasePath + 'CORE.tar.gz') + ' -C ' + Quote(FWorkPath),
                                FBasePath, LOutput);
     End;
    EndCommandProgress;
    If Result Then
     Begin
      FSourcePath := ResolveDistributionRoot(FWorkPath);
      DoProgress(20, 100, 'Distribuição extraída.');
     End;
   End
 Else
  Begin
   If ASource = isSVNTrunk Then
    LURL := cSVNTrunkURL
   Else
    LURL := cSVNBranchURL;
   LExecutable := FindExecutable('svn');
   If LExecutable = '' Then
    Begin
     DoLog('Cliente SVN não localizado. Coloque svn/svn.exe junto ao instalador ou no PATH.');
     Exit;
    End;
   If DirectoryExists(FWorkPath) Then
    Begin
     {$IFDEF MSWINDOWS}
     ExecuteCommand('cmd.exe', '/C rmdir /S /Q ' + Quote(ExcludeTrailingPathDelimiter(FWorkPath)),
                    FBasePath, LOutput);
     {$ELSE}
     ExecuteCommand('/bin/rm', '-rf ' + Quote(ExcludeTrailingPathDelimiter(FWorkPath)),
                    FBasePath, LOutput);
     {$ENDIF}
    End;
   ForceDirectories(FWorkPath);
   LParameters := 'checkout ' + Quote(LURL) + ' ' + Quote(FWorkPath) + ' --non-interactive';
   BeginCommandProgress('Baixando distribuição do SVN...', 4, 20);
   Result := ExecuteCommand(LExecutable, LParameters, FBasePath, LOutput);
   EndCommandProgress;
   DoLog(LOutput);
   If Result Then
    Begin
     FSourcePath := ResolveDistributionRoot(FWorkPath);
     LParameters := 'info --show-item revision ' + Quote(FSourcePath);
     If ExecuteCommand(LExecutable, LParameters, FSourcePath, LOutput) Then
      FVersion.SVNRevision := Trim(LOutput)
     Else
      Begin
       LParameters := 'info ' + Quote(FSourcePath);
       If ExecuteCommand(LExecutable, LParameters, FSourcePath, LOutput) Then
        Begin
         If Pos('Revision:', LOutput) > 0 Then
          Begin
           LOutput := Copy(LOutput, Pos('Revision:', LOutput) + Length('Revision:'), MaxInt);
           If Pos(#13, LOutput) > 0 Then
            LOutput := Copy(LOutput, 1, Pos(#13, LOutput) - 1);
           If Pos(#10, LOutput) > 0 Then
            LOutput := Copy(LOutput, 1, Pos(#10, LOutput) - 1);
          End;
         FVersion.SVNRevision := Trim(LOutput);
        End;
      End;
    End;
  End;
 If Result Then
  FVersion := ReadDistributionVersion;
end;

function TRESTDWInstallerCore.ExtractConstValue(const AText,
  AConstName: String): String;
var
 LPos: Integer;
 LEnd: Integer;
 LLine: String;
 LEqual: Integer;
begin
 Result := '';
 LPos := Pos(AConstName, AText);
 If LPos = 0 Then
  Exit;
 LEnd := LPos;
 While (LEnd <= Length(AText)) And Not (AText[LEnd] In [#10, #13]) Do
  Inc(LEnd);
 LLine := Copy(AText, LPos, LEnd - LPos);
 LEqual := Pos('=', LLine);
 If LEqual = 0 Then
  Exit;
 LLine := Trim(Copy(LLine, LEqual + 1, MaxInt));
 If Pos(';', LLine) > 0 Then
  LLine := Copy(LLine, 1, Pos(';', LLine) - 1);
 LLine := Trim(LLine);
 If (Length(LLine) >= 2) And (LLine[1] = '''') Then
  Begin
   Delete(LLine, 1, 1);
   If Pos('''', LLine) > 0 Then
    LLine := Copy(LLine, 1, Pos('''', LLine) - 1);
  End;
 Result := LLine;
end;

function TRESTDWInstallerCore.ReadDistributionVersion: TRESTDWDistributionVersion;
var
 LFile: String;
 LStrings: TStringList;
 LText: String;
 LSVNRevision: String;
begin
 FillChar(Result, SizeOf(Result), 0);
 LSVNRevision := FVersion.SVNRevision;
 LFile := IncludeTrailingPathDelimiter(FSourcePath) +
          'Source' + PathDelim + 'Consts' + PathDelim + 'uRESTDWConsts.pas';
 If Not FileExists(LFile) Then
  Exit;
 LStrings := TStringList.Create;
 Try
  LStrings.LoadFromFile(LFile);
  LText := LStrings.Text;
  Result.VersionInfo := ExtractConstValue(LText, 'RESTDWVersionINFO');
  Result.Release := ExtractConstValue(LText, 'RESTDWRelease');
  Result.CodeProject := ExtractConstValue(LText, 'RESTDWCodeProject');
  Result.FullVersion := Result.VersionInfo + Result.Release + '(' + Result.CodeProject + ')';
  Result.DialogTitle := 'REST Dataware Components ' + Result.FullVersion;
  Result.LicenseStatus := ExtractConstValue(LText, 'RESTDWSobreLicencaStatus');
  Result.SVNRevision := LSVNRevision;
 Finally
  LStrings.Free;
 End;
 FVersion := Result;
end;

function TRESTDWInstallerCore.CountFiles(const APath: String): Integer;
var
 LSearch: TSearchRec;
 LFileName: String;
begin
 Result := 0;
 If Not DirectoryExists(APath) Then
  Exit;
 If FindFirst(IncludeTrailingPathDelimiter(APath) + '*', faAnyFile, LSearch) = 0 Then
  Try
   Repeat
    If (LSearch.Name <> '.') And (LSearch.Name <> '..') Then
     Begin
      LFileName := IncludeTrailingPathDelimiter(APath) + LSearch.Name;
      If (LSearch.Attr And faDirectory) <> 0 Then
       Inc(Result, CountFiles(LFileName))
      Else
       Inc(Result);
     End;
   Until FindNext(LSearch) <> 0;
  Finally
   RESTDWFindClose(LSearch);
  End;
end;

procedure TRESTDWInstallerCore.CopyDirectory(const ASource, ADestination: String;
  var ACurrent: Integer; ATotal: Integer);
var
 LSearch: TSearchRec;
 LSourceFile: String;
 LDestinationFile: String;
 LInput: TFileStream;
 LOutput: TFileStream;
 LValue: Integer;
begin
 If Not DirectoryExists(ASource) Then
  Exit;
 ForceDirectories(ADestination);
 If FindFirst(IncludeTrailingPathDelimiter(ASource) + '*', faAnyFile, LSearch) = 0 Then
  Try
   Repeat
    If (LSearch.Name <> '.') And (LSearch.Name <> '..') Then
     Begin
      LSourceFile := IncludeTrailingPathDelimiter(ASource) + LSearch.Name;
      LDestinationFile := IncludeTrailingPathDelimiter(ADestination) + LSearch.Name;
      If (LSearch.Attr And faDirectory) <> 0 Then
       CopyDirectory(LSourceFile, LDestinationFile, ACurrent, ATotal)
      Else
       Begin
        LInput := TFileStream.Create(LSourceFile, fmOpenRead Or fmShareDenyWrite);
        Try
         LOutput := TFileStream.Create(LDestinationFile, fmCreate);
         Try
          LOutput.CopyFrom(LInput, 0);
         Finally
          LOutput.Free;
         End;
        Finally
         LInput.Free;
        End;
        Inc(ACurrent);
        If ATotal > 0 Then
         Begin
          LValue := 20 + ((ACurrent * 40) Div ATotal);
          If LValue > 60 Then
           LValue := 60;
          DoProgress(LValue, 100, 'Copiando ' + LSearch.Name + '...');
         End;
       End;
     End;
   Until FindNext(LSearch) <> 0;
  Finally
   RESTDWFindClose(LSearch);
  End;
end;

function TRESTDWInstallerCore.CopyDistribution: Boolean;
var
 I: Integer;
 LSource: String;
 LDestination: String;
 LTotal: Integer;
 LCurrent: Integer;
begin
 Result := False;
 If FDestinationPath = '' Then
  Exit;
 ForceDirectories(FDestinationPath);
 LTotal := 0;
 For I := Low(cDistributionDirectories) To High(cDistributionDirectories) Do
  Begin
   LSource := ResolveSourceDirectory(cDistributionDirectories[I]);
   Inc(LTotal, CountFiles(LSource));
  End;
 LCurrent := 0;
 DoProgress(20, 100, 'Preparando cópia da distribuição...');
 For I := Low(cDistributionDirectories) To High(cDistributionDirectories) Do
  Begin
   LSource := ResolveSourceDirectory(cDistributionDirectories[I]);
   LDestination := IncludeTrailingPathDelimiter(FDestinationPath) + cDistributionDirectories[I];
   CopyDirectory(LSource, LDestination, LCurrent, LTotal);
  End;
 DoProgress(60, 100, 'Distribuição copiada.');
 Result := True;
end;


function TRESTDWInstallerCore.InstallationStateFile: String;
var
 LRoot : String;
begin
{$IFDEF MSWINDOWS}
 LRoot := GetEnvironmentVariable('LOCALAPPDATA');
 If LRoot = '' Then
  LRoot := GetEnvironmentVariable('APPDATA');
 If LRoot = '' Then
  LRoot := GetEnvironmentVariable('USERPROFILE');
 Result := IncludeTrailingPathDelimiter(LRoot) + 'REST Dataware' + PathDelim +
           'RESTDWInstaller.ini';
{$ELSE}
 LRoot := GetEnvironmentVariable('HOME');
 Result := IncludeTrailingPathDelimiter(LRoot) + '.config' + PathDelim +
           'restdataware' + PathDelim + 'RESTDWInstaller.ini';
{$ENDIF}
end;

function TRESTDWInstallerCore.DetectInstallation(out ADestination: String): Boolean;
var
 LIni      : TIniFile;
 LState    : String;
 LDest     : String;
begin
 Result := False;
 ADestination := '';
 LState := InstallationStateFile;
 If Not FileExists(LState) Then
  Exit;
 LIni := TIniFile.Create(LState);
 Try
  LDest := Trim(LIni.ReadString('Install', 'Destination', ''));
 Finally
  LIni.Free;
 End;
 If LDest = '' Then
  Exit;
 LDest := IncludeTrailingPathDelimiter(ExpandFileName(LDest));
 If Not DirectoryExists(LDest) Then
  Exit;
 If Not DirectoryExists(LDest + 'Source') Then
  Exit;
 If Not DirectoryExists(LDest + 'Packages') Then
  Exit;
 ADestination := ExcludeTrailingPathDelimiter(LDest);
 Result := True;
end;

procedure TRESTDWInstallerCore.SaveInstallationState;
var
 LIni   : TIniFile;
 LState : String;
begin
 If Trim(FDestinationPath) = '' Then
  Exit;
 LState := InstallationStateFile;
 ForceDirectories(ExtractFilePath(LState));
 LIni := TIniFile.Create(LState);
 Try
  LIni.WriteString('Install', 'Destination', ExpandFileName(FDestinationPath));
 Finally
  LIni.Free;
 End;
end;

procedure TRESTDWInstallerCore.ClearInstallationState;
var
 LState : String;
begin
 LState := InstallationStateFile;
 If FileExists(LState) Then
  DeleteFile(LState);
end;

function TRESTDWInstallerCore.RemoveDirectoryTree(const APath: String): Boolean;
var
 LSearch : TSearchRec;
 LName   : String;
begin
 Result := True;
 If Not DirectoryExists(APath) Then
  Exit;
 If FindFirst(IncludeTrailingPathDelimiter(APath) + '*', faAnyFile, LSearch) = 0 Then
  Try
   Repeat
    If (LSearch.Name <> '.') And (LSearch.Name <> '..') Then
     Begin
      LName := IncludeTrailingPathDelimiter(APath) + LSearch.Name;
      If (LSearch.Attr And faDirectory) <> 0 Then
       Begin
        If Not RemoveDirectoryTree(LName) Then
         Result := False;
       End
      Else
       Begin
        FileSetAttr(LName, 0);
        If Not DeleteFile(LName) Then
         Result := False;
       End;
     End;
   Until FindNext(LSearch) <> 0;
  Finally
   RESTDWFindClose(LSearch);
  End;
 If Not RemoveDir(APath) Then
  Result := False;
end;

function TRESTDWInstallerCore.RemoveInstalledDistribution: Boolean;
var
 LDestination : String;
 I            : Integer;
begin
 Result := False;
 If Not DetectInstallation(LDestination) Then
  Exit;
 For I := Low(cDistributionDirectories) To High(cDistributionDirectories) Do
  If Not RemoveDirectoryTree(IncludeTrailingPathDelimiter(LDestination) +
                             cDistributionDirectories[I]) Then
   Exit;
 ClearInstallationState;
 Result := True;
end;

procedure TRESTDWInstallerCore.EnumeratePackages(AList: TStrings;
  const APackageRoot: String);
var
 LSearch: TSearchRec;
 LPath: String;
 LExt: String;
begin
 If Not DirectoryExists(APackageRoot) Then
  Exit;
 If FindFirst(IncludeTrailingPathDelimiter(APackageRoot) + '*', faAnyFile, LSearch) = 0 Then
  Try
   Repeat
    If (LSearch.Name <> '.') And (LSearch.Name <> '..') Then
     Begin
      LPath := IncludeTrailingPathDelimiter(APackageRoot) + LSearch.Name;
      If (LSearch.Attr And faDirectory) <> 0 Then
       EnumeratePackages(AList, LPath)
      Else
       Begin
        LExt := LowerCase(ExtractFileExt(LSearch.Name));
        If (LExt = '.dpk') Or (LExt = '.dproj') Or (LExt = '.lpk') Then
         If AList.IndexOf(LPath) < 0 Then
          AList.Add(LPath);
       End;
     End;
   Until FindNext(LSearch) <> 0;
  Finally
   RESTDWFindClose(LSearch);
  End;
end;

procedure TRESTDWInstallerCore.EnumeratePlatforms(const AProjectFile: String;
  AList: TStrings);
const
 cPlatforms: Array[0..15] Of String =
  ('Win32', 'Win64', 'Win64x', 'OSX32', 'OSX64', 'OSXARM64',
   'Android', 'Android64', 'iOSDevice32', 'iOSDevice64', 'iOSSimulator',
   'iOSSimARM64', 'Linux64', 'Linux', 'FreeBSD', 'FreeBSD64');
var
 LStrings: TStringList;
 LText: String;
 I: Integer;
begin
 AList.Clear;
 If Not FileExists(AProjectFile) Then
  Exit;
 LStrings := TStringList.Create;
 Try
  LStrings.LoadFromFile(AProjectFile);
  LText := LStrings.Text;
  For I := Low(cPlatforms) To High(cPlatforms) Do
   If Pos(cPlatforms[I], LText) > 0 Then
    AList.Add(cPlatforms[I]);
 Finally
  LStrings.Free;
 End;
end;


procedure TRESTDWInstallerCore.SortPackagesByDependencies(AList: TStrings);
var
 LNames: TStringList;
 LDependencies: TStringList;
 LSorted: TStringList;
 LVisiting: TStringList;
 LVisited: TStringList;
 I: Integer;

 function PackageNameFromFile(const AFileName: String): String;
 var
  L: TStringList;
  LText: String;
  LPos: Integer;
  LEnd: Integer;
 begin
  Result := LowerCase(ChangeFileExt(ExtractFileName(AFileName), ''));
  If LowerCase(ExtractFileExt(AFileName)) <> '.lpk' Then
   Exit;
  L := TStringList.Create;
  Try
   L.LoadFromFile(AFileName);
   LText := L.Text;
   LPos := Pos('<Name Value="', LText);
   If LPos > 0 Then
    Begin
     Inc(LPos, Length('<Name Value="'));
     LEnd := Pos('"', Copy(LText, LPos, MaxInt));
     If LEnd > 0 Then
      Result := LowerCase(Copy(LText, LPos, LEnd - 1));
    End;
  Finally
   L.Free;
  End;
 end;

 procedure AddDependency(var AValue: String; const AName: String);
 begin
  If AName = '' Then
   Exit;
  If Pos(',' + LowerCase(AName) + ',', ',' + LowerCase(AValue) + ',') = 0 Then
   Begin
    If AValue <> '' Then
     AValue := AValue + ',';
    AValue := AValue + LowerCase(AName);
   End;
 end;

 function ReadDependencies(const AFileName: String): String;
 var
  L: TStringList;
  LText: String;
  LLow: String;
  LPart: String;
  LToken: String;
  LPos: Integer;
  LEnd: Integer;
  LStart: Integer;
  LQuote: Integer;
  J: Integer;
 begin
  Result := '';
  L := TStringList.Create;
  Try
   L.LoadFromFile(AFileName);
   LText := L.Text;
   LLow := LowerCase(LText);
   If LowerCase(ExtractFileExt(AFileName)) = '.dpk' Then
    Begin
     LPos := Pos('requires', LLow);
     If LPos = 0 Then
      Exit;
     LPart := Copy(LText, LPos + Length('requires'), MaxInt);
     LEnd := Pos('contains', LowerCase(LPart));
     If LEnd > 0 Then
      LPart := Copy(LPart, 1, LEnd - 1);
     LToken := '';
     For J := 1 To Length(LPart) Do
      Begin
       If LPart[J] In ['A'..'Z', 'a'..'z', '0'..'9', '_'] Then
        LToken := LToken + LPart[J]
       Else
        Begin
         If LToken <> '' Then
          AddDependency(Result, LToken);
         LToken := '';
        End;
      End;
     If LToken <> '' Then
      AddDependency(Result, LToken);
    End
   Else
    Begin
     LStart := 1;
     Repeat
      LPos := Pos('<PackageName Value="', Copy(LText, LStart, MaxInt));
      If LPos = 0 Then
       Break;
      Inc(LPos, LStart - 1 + Length('<PackageName Value="'));
      LQuote := Pos('"', Copy(LText, LPos, MaxInt));
      If LQuote = 0 Then
       Break;
      AddDependency(Result, Copy(LText, LPos, LQuote - 1));
      LStart := LPos + LQuote;
     Until False;
    End;
  Finally
   L.Free;
  End;
 end;

 procedure Visit(AIndex: Integer);
 var
  LDepList: TStringList;
  LDepName: String;
  LDepIndex: Integer;
  J: Integer;
 begin
  If LVisited.IndexOf(IntToStr(AIndex)) >= 0 Then
   Exit;
  If LVisiting.IndexOf(IntToStr(AIndex)) >= 0 Then
   Exit;
  LVisiting.Add(IntToStr(AIndex));
  LDepList := TStringList.Create;
  Try
   LDepList.CommaText := LDependencies[AIndex];
   For J := 0 To LDepList.Count - 1 Do
    Begin
     LDepName := LowerCase(Trim(LDepList[J]));
     LDepIndex := LNames.IndexOf(LDepName);
     If LDepIndex >= 0 Then
      Visit(LDepIndex);
    End;
  Finally
   LDepList.Free;
  End;
  LVisiting.Delete(LVisiting.IndexOf(IntToStr(AIndex)));
  LVisited.Add(IntToStr(AIndex));
  If LSorted.IndexOf(AList[AIndex]) < 0 Then
   LSorted.Add(AList[AIndex]);
 end;

begin
 If AList.Count < 2 Then
  Exit;
 LNames := TStringList.Create;
 LDependencies := TStringList.Create;
 LSorted := TStringList.Create;
 LVisiting := TStringList.Create;
 LVisited := TStringList.Create;
 Try
  LNames.CaseSensitive := False;
  LNames.Sorted := False;
  For I := 0 To AList.Count - 1 Do
   Begin
    LNames.Add(PackageNameFromFile(AList[I]));
    LDependencies.Add(ReadDependencies(AList[I]));
   End;
  For I := 0 To AList.Count - 1 Do
   Visit(I);
  AList.Assign(LSorted);
 Finally
  LVisited.Free;
  LVisiting.Free;
  LSorted.Free;
  LDependencies.Free;
  LNames.Free;
 End;
end;

procedure TRESTDWInstallerCore.BuildDelphiProjectGroup(const AFileName: String;
  AProjects: TStrings);
var
 L: TStringList;
 I: Integer;
 LName: String;
 LTargets: String;
begin
 L := TStringList.Create;
 Try
  ForceDirectories(ExtractFilePath(AFileName));
  If SameText(ExtractFileExt(AFileName), '.bpg') Then
   Begin
    L.Add('#------------------------------------------------------------------------------');
    L.Add('VERSION = BWS.01');
    L.Add('#------------------------------------------------------------------------------');
    L.Add('!ifndef ROOT');
    L.Add('ROOT = $(MAKEDIR)\..');
    L.Add('!endif');
    L.Add('#------------------------------------------------------------------------------');
    L.Add('DCC = $(ROOT)\bin\dcc32.exe $**');
    L.Add('#------------------------------------------------------------------------------');
    LTargets := '';
    For I := 0 To AProjects.Count - 1 Do
     Begin
      LName := ChangeFileExt(AProjects[I], '');
      If LTargets <> '' Then
       LTargets := LTargets + ' ';
      LTargets := LTargets + '"' + LName + '"';
     End;
    L.Add('PROJECTS = ' + LTargets);
    L.Add('default: $(PROJECTS)');
    L.Add('#------------------------------------------------------------------------------');
    For I := 0 To AProjects.Count - 1 Do
     Begin
      LName := ChangeFileExt(AProjects[I], '');
      L.Add('"' + LName + '": "' + AProjects[I] + '"');
      L.Add(#9 + '$(DCC)');
     End;
   End
  Else
   Begin
    L.Add('<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">');
    L.Add('    <PropertyGroup>');
    L.Add('        <ProjectGuid>{B7FA5A4C-DA22-4DCB-9E21-473CF2C1E001}</ProjectGuid>');
    L.Add('    </PropertyGroup>');
    L.Add('    <ItemGroup>');
    For I := 0 To AProjects.Count - 1 Do
     Begin
      L.Add('        <Projects Include="' + AProjects[I] + '">');
      L.Add('            <Dependencies/>');
      L.Add('        </Projects>');
     End;
    L.Add('    </ItemGroup>');
    LTargets := '';
    For I := 0 To AProjects.Count - 1 Do
     Begin
      LName := 'Project' + IntToStr(I + 1);
      L.Add('    <Target Name="' + LName + '">');
      L.Add('        <MSBuild Projects="' + AProjects[I] + '"/>');
      L.Add('    </Target>');
      L.Add('    <Target Name="' + LName + ':Clean">');
      L.Add('        <MSBuild Projects="' + AProjects[I] + '" Targets="Clean"/>');
      L.Add('    </Target>');
      L.Add('    <Target Name="' + LName + ':Make">');
      L.Add('        <MSBuild Projects="' + AProjects[I] + '" Targets="Make"/>');
      L.Add('    </Target>');
      If LTargets <> '' Then
       LTargets := LTargets + ';';
      LTargets := LTargets + LName;
     End;
    L.Add('    <Target Name="Build">');
    L.Add('        <CallTarget Targets="' + LTargets + '"/>');
    L.Add('    </Target>');
    L.Add('    <Import Project="$(BDS)\Bin\CodeGear.Group.Targets" Condition="Exists(''$(BDS)\Bin\CodeGear.Group.Targets'')"/>');
    L.Add('</Project>');
   End;
  L.SaveToFile(AFileName);
 Finally
  L.Free;
 End;
end;

procedure TRESTDWInstallerCore.BuildLazarusProjectGroup(const AFileName: String;
  AProjects: TStrings);
var
 L: TStringList;
 I: Integer;
begin
 L := TStringList.Create;
 Try
  L.Add('[RESTDWProjectGroup]');
  For I := 0 To AProjects.Count - 1 Do
   L.Add('Project' + IntToStr(I + 1) + '=' + AProjects[I]);
  ForceDirectories(ExtractFilePath(AFileName));
  L.SaveToFile(AFileName);
 Finally
  L.Free;
 End;
end;

end.
