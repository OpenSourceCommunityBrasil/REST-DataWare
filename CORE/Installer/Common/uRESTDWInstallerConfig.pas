unit uRESTDWInstallerConfig;

{$IFDEF FPC}
 {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, IniFiles;

type
  TRESTDWInstallerConfig = class
  private
    FFileName: String;
    FDestination: String;
    FSourceMode: Integer;
    FIDEs: TStringList;
    FPackagePlatforms: TStringList;
    FLoaded: Boolean;
  public
    constructor Create(const AFileName: String);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    function GetPackagePlatforms(const APackage: String): String;
    procedure SetPackagePlatforms(const APackage, APlatforms: String);
    property Destination: String read FDestination write FDestination;
    property SourceMode: Integer read FSourceMode write FSourceMode;
    property IDEs: TStringList read FIDEs;
    property PackagePlatforms: TStringList read FPackagePlatforms;
    property Loaded: Boolean read FLoaded;
  end;

implementation

constructor TRESTDWInstallerConfig.Create(const AFileName: String);
begin
 FFileName := AFileName;
 FIDEs := TStringList.Create;
 FPackagePlatforms := TStringList.Create;
 FPackagePlatforms.NameValueSeparator := '=';
 FLoaded := False;
end;

destructor TRESTDWInstallerConfig.Destroy;
begin
 FPackagePlatforms.Free;
 FIDEs.Free;
 inherited Destroy;
end;

procedure TRESTDWInstallerConfig.Load;
var
 LIni: TIniFile;
begin
 If Not FileExists(FFileName) Then
  Exit;
 FLoaded := True;
 LIni := TIniFile.Create(FFileName);
 Try
  FDestination := LIni.ReadString('Install', 'Destination', '');
  FSourceMode := LIni.ReadInteger('Install', 'SourceMode', 0);
  LIni.ReadSection('IDEs', FIDEs);
  LIni.ReadSectionValues('PackagePlatforms', FPackagePlatforms);
 Finally
  LIni.Free;
 End;
end;

procedure TRESTDWInstallerConfig.Save;
var
 LIni: TIniFile;
 I: Integer;
begin
 LIni := TIniFile.Create(FFileName);
 Try
  LIni.EraseSection('Install');
  LIni.EraseSection('IDEs');
  LIni.EraseSection('PackagePlatforms');
  LIni.WriteString('Install', 'Destination', FDestination);
  LIni.WriteInteger('Install', 'SourceMode', FSourceMode);
  For I := 0 To FIDEs.Count - 1 Do
   LIni.WriteBool('IDEs', FIDEs[I], True);
  For I := 0 To FPackagePlatforms.Count - 1 Do
   LIni.WriteString('PackagePlatforms',
                    FPackagePlatforms.Names[I],
                    FPackagePlatforms.ValueFromIndex[I]);
 Finally
  LIni.Free;
 End;
end;

function TRESTDWInstallerConfig.GetPackagePlatforms(
  const APackage: String): String;
begin
 Result := FPackagePlatforms.Values[APackage];
end;

procedure TRESTDWInstallerConfig.SetPackagePlatforms(const APackage,
  APlatforms: String);
begin
 FPackagePlatforms.Values[APackage] := APlatforms;
end;

end.
