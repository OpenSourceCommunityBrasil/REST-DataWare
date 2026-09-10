unit uRESTDWHTMLIDECompat;

{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}

interface

uses
 Classes
 {$IFDEF FPC},
 SysUtils, StrUtils, LCLIntf, LazIDEIntf, LazUTF8
 {$ELSE}
 {$IFDEF MSWINDOWS},
 Windows, ShellAPI
 {$ENDIF},
 SysUtils
 {$ENDIF};

function RESTDWActiveProjectDir : String;
function RESTDWEditorConfigDir : String;
function RESTDWOpenDocument(const AFileName : String) : Boolean;
procedure RESTDWCopyDirTree(const ASource, ADest : String);
function RESTDWSystemLanguage : String;

implementation

function RESTDWActiveProjectDir : String;
begin
 Result := '';
 {$IFDEF FPC}
 if (LazarusIDE <> nil) and (LazarusIDE.ActiveProject <> nil) then
  Result := ExtractFilePath(LazarusIDE.ActiveProject.ProjectInfoFile);
 {$ENDIF}
 if Result = '' then
  Result := GetCurrentDir;
 if Result <> '' then
  Result := IncludeTrailingPathDelimiter(Result);
end;

function RESTDWEditorConfigDir : String;
begin
 {$IFDEF FPC}
 Result := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) +
  'RESTDataware' + PathDelim + 'HTMLDesigner';
 {$ELSE}
 {$IFDEF MSWINDOWS}
 Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
  'RESTDataware' + PathDelim + 'HTMLDesigner';
 {$ELSE}
 Result := IncludeTrailingPathDelimiter(GetHomePath) +
  '.restdataware' + PathDelim + 'HTMLDesigner';
 {$ENDIF}
 {$ENDIF}
 if not DirectoryExists(Result) then
  ForceDirectories(Result);
end;

function RESTDWOpenDocument(const AFileName : String) : Boolean;
begin
 {$IFDEF FPC}
 Result := OpenDocument(AFileName);
 {$ELSE}
 {$IFDEF MSWINDOWS}
 Result := ShellExecute(0,'open',PChar(AFileName),nil,nil,SW_SHOWNORMAL) > 32;
 {$ELSE}
 Result := False;
 {$ENDIF}
 {$ENDIF}
end;

procedure RESTDWCopyFile(const ASource, ADest : String);
var
 LSource : TFileStream;
 LDest : TFileStream;
begin
 LSource := TFileStream.Create(ASource,fmOpenRead or fmShareDenyWrite);
 try
  LDest := TFileStream.Create(ADest,fmCreate);
  try
   LDest.CopyFrom(LSource,0);
  finally
   LDest.Free;
  end;
 finally
  LSource.Free;
 end;
end;

procedure RESTDWCopyDirTree(const ASource, ADest : String);
var
 SR : TSearchRec;
 SourceName : String;
 DestName : String;
begin
 if not DirectoryExists(ASource) then
  Exit;
 ForceDirectories(ADest);
 if FindFirst(IncludeTrailingPathDelimiter(ASource) + '*',faAnyFile,SR) = 0 then
 try
  repeat
   if (SR.Name = '.') or (SR.Name = '..') then
    Continue;
   SourceName := IncludeTrailingPathDelimiter(ASource) + SR.Name;
   DestName := IncludeTrailingPathDelimiter(ADest) + SR.Name;
   if (SR.Attr and faDirectory) <> 0 then
    RESTDWCopyDirTree(SourceName,DestName)
   else
    RESTDWCopyFile(SourceName,DestName);
  until FindNext(SR) <> 0;
 finally
  FindClose(SR);
 end;
end;

function RESTDWSystemLanguage : String;
{$IFDEF FPC}
var
 LConfigFile,
 LConfigPath,
 LText,
 LLower,
 LValue,
 LFallback : String;
 LList : TStringList;
 P1,
 P2,
 I : Integer;
 function ReadLanguageFromFile(
  const AFileName : String) : String;
 var
  LLocalList : TStringList;
  LLocalText,
  LLocalLower : String;
  Q1,
  Q2,
  QLang : Integer;
 begin
  Result := '';
  if not FileExists(AFileName) then
   Exit;
  LLocalList := TStringList.Create;
  try
   LLocalList.LoadFromFile(AFileName);
   LLocalText := LLocalList.Text;
   LLocalLower := LowerCase(LLocalText);
   QLang := Pos('<language',LLocalLower);
   if QLang > 0 then
   begin
    Q1 := PosEx('<id value="',LLocalLower,QLang);
    if Q1 > 0 then
    begin
     Inc(Q1,Length('<id value="'));
     Q2 := PosEx('"',LLocalText,Q1);
     if Q2 > Q1 then
      Result := Copy(LLocalText,Q1,Q2-Q1);
    end;
   end;
   if Result = '' then
   begin
    Q1 := Pos('language value="',LLocalLower);
    if Q1 > 0 then
    begin
     Inc(Q1,Length('language value="'));
     Q2 := PosEx('"',LLocalText,Q1);
     if Q2 > Q1 then
      Result := Copy(LLocalText,Q1,Q2-Q1);
    end;
   end;
  finally
   LLocalList.Free;
  end;
 end;
 function SystemLanguage : String;
 var
  LLang : String;
 begin
  LLang := '';
  LFallback := '';
  LazGetLanguageIDs(LLang,LFallback);
  if Trim(LLang) <> '' then
   Result := LLang
  else
   Result := LFallback;
  if Trim(Result) = '' then
   Result := GetEnvironmentVariableUTF8('LANG');
 end;
begin
 Result := '';
 if LazarusIDE <> nil then
 begin
  LConfigPath := LazarusIDE.GetPrimaryConfigPath;
  LConfigFile :=
   IncludeTrailingPathDelimiter(LConfigPath) +
   'environmentoptions.xml';
  Result := ReadLanguageFromFile(LConfigFile);
 end;
 if Result = '' then
 begin
  LConfigFile :=
   IncludeTrailingPathDelimiter(GetAppConfigDir(False)) +
   'environmentoptions.xml';
  Result := ReadLanguageFromFile(LConfigFile);
 end;
 if Result = '' then
  for I := 1 to ParamCount do
  begin
   LText := ParamStr(I);
   LLower := LowerCase(LText);
   P1 := Pos('--primary-config-path=',LLower);
   if P1 = 1 then
   begin
    LValue := Copy(
     LText,
     Length('--primary-config-path=') + 1,
     MaxInt
    );
    Result := ReadLanguageFromFile(
     IncludeTrailingPathDelimiter(LValue) +
     'environmentoptions.xml'
    );
   end
   else
   begin
    P1 := Pos('--pcp=',LLower);
    if P1 = 1 then
    begin
     LValue := Copy(LText,Length('--pcp=') + 1,MaxInt);
     Result := ReadLanguageFromFile(
      IncludeTrailingPathDelimiter(LValue) +
      'environmentoptions.xml'
     );
    end;
   end;
   if Result <> '' then
    Break;
  end;
 if (Trim(Result) = '') or
    SameText(Trim(Result),'default') or
    SameText(Trim(Result),'auto') or
    SameText(Trim(Result),'automatic') or
    SameText(Trim(Result),'system') then
  Result := SystemLanguage;
 if Pos('.',Result) > 0 then
  Result := Copy(Result,1,Pos('.',Result)-1);
 if Pos(':',Result) > 0 then
  Result := Copy(Result,1,Pos(':',Result)-1);
 Result := StringReplace(Result,'-','_',[rfReplaceAll]);
 if Pos('pt_br',LowerCase(Result)) = 1 then
  Result := 'pt_BR'
 else if Pos('pt_',LowerCase(Result)) = 1 then
  Result := 'pt'
 else if SameText(Result,'pt') then
  Result := 'pt'
 else if Result = '' then
  Result := 'en';
end;
{$ELSE}
var
 Buffer : array[0..31] of Char;
begin
 Result := '';
 {$IFDEF MSWINDOWS}
 if GetLocaleInfo(
     LOCALE_USER_DEFAULT,
     LOCALE_SISO639LANGNAME,
     Buffer,
     Length(Buffer)
    ) > 0 then
  Result := Buffer;
 {$ENDIF}
 if Result = '' then
  Result := 'en';
end;
{$ENDIF}

end.
