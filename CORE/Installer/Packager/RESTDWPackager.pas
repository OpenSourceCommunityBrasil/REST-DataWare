program RESTDWPackager;

{$IFDEF FPC}
 {$mode objfpc}{$H+}
{$ENDIF}

uses
  Classes, SysUtils
  {$IFDEF FPC}, Process{$ENDIF}
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

const
  cDirectories: Array[0..4] Of String =
   ('Source', 'Packages', 'Images', 'Extras', 'Demos');

function ResolveDirectory(const ARoot, AName: String): String;
begin
 Result := IncludeTrailingPathDelimiter(ARoot) + AName;
 If DirectoryExists(Result) Then
  Exit;
 If SameText(AName, 'Demos') And
    DirectoryExists(IncludeTrailingPathDelimiter(ARoot) + 'demos') Then
  Result := IncludeTrailingPathDelimiter(ARoot) + 'demos';
end;

procedure CollectFiles(const ARoot, APath: String; AFiles: TStrings);
var
 LSearch: TSearchRec;
 LFullPath: String;
begin
 If FindFirst(IncludeTrailingPathDelimiter(APath) + '*', faAnyFile, LSearch) = 0 Then
  Try
   Repeat
    If (LSearch.Name <> '.') And (LSearch.Name <> '..') Then
     Begin
      LFullPath := IncludeTrailingPathDelimiter(APath) + LSearch.Name;
      If (LSearch.Attr And faDirectory) <> 0 Then
       CollectFiles(ARoot, LFullPath, AFiles)
      Else
       AFiles.Add(LFullPath);
     End;
   Until FindNext(LSearch) <> 0;
  Finally
   FindClose(LSearch);
  End;
end;

function RunCommand(const AExecutable, AParameters, AWorkingDirectory: String): Boolean;
{$IFDEF FPC}
var
 LProcess: TProcess;
{$ELSE}
{$IFDEF MSWINDOWS}
var
 LStartup: TStartupInfo;
 LProcessInfo: TProcessInformation;
 LCommand: String;
 LExitCode: Cardinal;
{$ENDIF}
{$ENDIF}
begin
 Result := False;
 {$IFDEF FPC}
 LProcess := TProcess.Create(nil);
 Try
  {$IFDEF MSWINDOWS}
  LProcess.Executable := GetEnvironmentVariable('COMSPEC');
  LProcess.Parameters.Add('/C');
  LProcess.Parameters.Add('"' + AExecutable + '" ' + AParameters);
  {$ELSE}
  LProcess.Executable := '/bin/sh';
  LProcess.Parameters.Add('-c');
  LProcess.Parameters.Add('"' + AExecutable + '" ' + AParameters);
  {$ENDIF}
  LProcess.CurrentDirectory := AWorkingDirectory;
  LProcess.Options := [poWaitOnExit];
  LProcess.Execute;
  Result := LProcess.ExitStatus = 0;
 Finally
  LProcess.Free;
 End;
 {$ELSE}
 {$IFDEF MSWINDOWS}
 FillChar(LStartup, SizeOf(LStartup), 0);
 FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);
 LStartup.cb := SizeOf(LStartup);
 LCommand := '"' + AExecutable + '" ' + AParameters;
 UniqueString(LCommand);
 If CreateProcess(nil, PChar(LCommand), nil, nil, False, 0, nil,
                  PChar(AWorkingDirectory), LStartup, LProcessInfo) Then
  Begin
   WaitForSingleObject(LProcessInfo.hProcess, INFINITE);
   GetExitCodeProcess(LProcessInfo.hProcess, LExitCode);
   CloseHandle(LProcessInfo.hThread);
   CloseHandle(LProcessInfo.hProcess);
   Result := LExitCode = 0;
  End;
 {$ENDIF}
 {$ENDIF}
end;

{$IFDEF MSWINDOWS}
function BuildCab(const ARoot: String): Boolean;
var
 LFiles: TStringList;
 LDDF: TStringList;
 I: Integer;
 J: Integer;
 LRelative: String;
 LDirectory: String;
 LCurrentDirectory: String;
 LMakeCab: String;
begin
 Result := False;
 LFiles := TStringList.Create;
 LDDF := TStringList.Create;
 Try
  For I := Low(cDirectories) To High(cDirectories) Do
   If DirectoryExists(ResolveDirectory(ARoot, cDirectories[I])) Then
    CollectFiles(ARoot, ResolveDirectory(ARoot, cDirectories[I]), LFiles);
  LDDF.Add('.OPTION EXPLICIT');
  LDDF.Add('.Set CabinetNameTemplate=CORE.CAB');
  LDDF.Add('.Set DiskDirectoryTemplate=' + ARoot);
  LDDF.Add('.Set CompressionType=MSZIP');
  LDDF.Add('.Set Cabinet=on');
  LDDF.Add('.Set Compress=on');
  LCurrentDirectory := '';
  For J := 0 To LFiles.Count - 1 Do
   Begin
    LRelative := Copy(LFiles[J], Length(IncludeTrailingPathDelimiter(ARoot)) + 1, MaxInt);
    LDirectory := ExtractFilePath(LRelative);
    If LDirectory <> LCurrentDirectory Then
     Begin
      LCurrentDirectory := LDirectory;
      LDDF.Add('.Set DestinationDir=' + StringReplace(ExcludeTrailingPathDelimiter(LDirectory), '/', '\', [rfReplaceAll]));
     End;
    LDDF.Add('"' + LFiles[J] + '" "' + ExtractFileName(LFiles[J]) + '"');
   End;
  LDDF.SaveToFile(IncludeTrailingPathDelimiter(ARoot) + 'CORE.ddf');
  LMakeCab := IncludeTrailingPathDelimiter(GetEnvironmentVariable('SystemRoot')) +
              'System32\makecab.exe';
  If Not FileExists(LMakeCab) Then
   LMakeCab := 'makecab.exe';
  Result := RunCommand(LMakeCab,
                       '/F "' + IncludeTrailingPathDelimiter(ARoot) + 'CORE.ddf"',
                       ARoot);
 Finally
  LDDF.Free;
  LFiles.Free;
 End;
end;
{$ELSE}
function BuildTarGz(const ARoot: String): Boolean;
var
 I: Integer;
 LParameters: String;
begin
 LParameters := '-czf CORE.tar.gz';
 For I := Low(cDirectories) To High(cDirectories) Do
  If DirectoryExists(ResolveDirectory(ARoot, cDirectories[I])) Then
   LParameters := LParameters + ' "' + ExtractFileName(ExcludeTrailingPathDelimiter(ResolveDirectory(ARoot, cDirectories[I]))) + '"';
 Result := RunCommand('tar', LParameters, ARoot);
end;
{$ENDIF}

var
 LRoot: String;
begin
 If ParamCount > 0 Then
  LRoot := ExpandFileName(ParamStr(1))
 Else
  LRoot := ExpandFileName(ExtractFilePath(ParamStr(0)));
 Writeln('REST Dataware Distribution Packager');
 Writeln('Root: ', LRoot);
 {$IFDEF MSWINDOWS}
 If BuildCab(LRoot) Then
  Writeln('CORE.CAB criado com sucesso.')
 Else
  Begin
   Writeln('Falha ao criar CORE.CAB.');
   Halt(1);
  End;
 {$ELSE}
 If BuildTarGz(LRoot) Then
  Writeln('CORE.tar.gz criado com sucesso.')
 Else
  Begin
   Writeln('Falha ao criar CORE.tar.gz.');
   Halt(1);
  End;
 {$ENDIF}
end.
