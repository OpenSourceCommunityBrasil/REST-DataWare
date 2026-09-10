program RESTDWInstallerFPC;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, uRESTDWInstallerCore, uRESTDWLazarusInstall;

function ParamValue(const AName: String): String;
var
 I: Integer;
 LPrefix: String;
begin
 Result := '';
 LPrefix := '--' + AName + '=';
 For I := 1 To ParamCount Do
  If Pos(LPrefix, ParamStr(I)) = 1 Then
   Begin
    Result := Copy(ParamStr(I), Length(LPrefix) + 1, MaxInt);
    Exit;
   End;
end;

function HasParam(const AName: String): Boolean;
var
 I: Integer;
begin
 Result := False;
 For I := 1 To ParamCount Do
  If SameText(ParamStr(I), '--' + AName) Then
   Begin
    Result := True;
    Exit;
   End;
end;

function ParseSource(const AValue: String): TRESTDWInstallSource;
begin
 If SameText(AValue, 'cab') Then
  Result := isCab
 Else
  If SameText(AValue, 'trunk') Then
   Result := isSVNTrunk
  Else
   If SameText(AValue, 'branch') Then
    Result := isSVNBranch
   Else
    Result := isLocal;
end;

procedure Log(const AText: String);
begin
 Writeln(AText);
end;

procedure Progress(AValue, AMaximum: Integer; const AText: String);
begin
 Writeln('[', AValue, '/', AMaximum, '] ', AText);
end;

var
 LCore: TRESTDWInstallerCore;
 LLazarus: TRESTDWLazarusInstaller;
 LPackages: TStringList;
 LSource: TRESTDWInstallSource;
 LDestination: String;
 LRoot: String;
 LVersion: TRESTDWDistributionVersion;
begin
 LRoot := IncludeTrailingPathDelimiter(ExpandFileName(ExtractFilePath(ParamStr(0))));
 LDestination := ParamValue('dest');
 If LDestination = '' Then
  Begin
   Writeln('Uso: RESTDWInstallerFPC --dest=/caminho [--source=local|cab|trunk|branch] [--close-ide]');
   Halt(1);
  End;
 LSource := ParseSource(ParamValue('source'));
 LCore := TRESTDWInstallerCore.Create(LRoot);
 LLazarus := TRESTDWLazarusInstaller.Create(LCore);
 LPackages := TStringList.Create;
 Try
  LCore.OnLog := @Log;
  LCore.OnProgress := @Progress;
  LCore.DestinationPath := ExpandFileName(LDestination);
  If LLazarus.IDEIsRunning Then
   Begin
    If Not HasParam('close-ide') Then
     Begin
      Writeln('Lazarus está aberto. Feche a IDE ou use --close-ide.');
      Halt(2);
     End;
    If Not LLazarus.CloseIDE Then
     Begin
      Writeln('Não foi possível fechar o Lazarus.');
      Halt(3);
     End;
   End;
  If Not LCore.PrepareSource(LSource) Then
   Begin
    Writeln('Não foi possível preparar a fonte.');
    Halt(4);
   End;
  If Not LCore.CopyDistribution Then
   Begin
    Writeln('Falha ao copiar a distribuição.');
    Halt(5);
   End;
  LCore.EnumeratePackages(LPackages,
   IncludeTrailingPathDelimiter(LCore.DestinationPath) + 'Packages' + PathDelim + 'Lazarus');
  If Not LLazarus.InstallPackages(LPackages) Then
   Begin
    Writeln('Falha ao instalar os pacotes Lazarus.');
    Halt(6);
   End;
  LVersion := LCore.ReadDistributionVersion;
  Writeln('Instalação concluída: ', LVersion.FullVersion);
  If LVersion.SVNRevision <> '' Then
   Writeln('SVN revision: ', LVersion.SVNRevision);
 Finally
  LPackages.Free;
  LLazarus.Free;
  LCore.Free;
 End;
end.
