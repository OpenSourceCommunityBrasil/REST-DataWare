unit uidefunctions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  uconsts;

type
  TIDEObject = class
  private
    FIcon: TIcon;
    FName: string;
    FInstallDir: string;
    FRegKey: string;
    FVersion: string;
  public
    constructor Create;
    destructor Destroy; override;

    property Version: string read FVersion write FVersion;
    property InstallPath: string read FInstallDir write FInstallDir;
    property Name: string read FName write FName;
    property Icon: TIcon read FIcon write FIcon;
    property RegKey: string read FRegKey;
  end;

  { TLazInstaller }

  TLazInstaller = class
  private
    FLazarus: TIDEObject;
    function FindLazarusInstallDir: TIDEObject;
    procedure RebuildIDE;
    procedure Install;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TDelphiInstaller = class
  private
    procedure AddLibraryPathToDelphi(const APath: string);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TLazInstaller }

function TLazInstaller.FindLazarusInstallDir: TIDEObject;
begin

end;

procedure TLazInstaller.RebuildIDE;
const
  C_BUFSIZE = 2048;
var
  AProcess: TProcess;
  Buffer: pointer;
  SStream: TStringStream;
  nread: longint;
begin
  outputScreen.Clear;
  AProcess := TProcess.Create(nil);
  AProcess.Executable := IncludeTrailingPathDelimiter(FLazarus.InstallPath) +
    'lazbuild';
  AProcess.Parameters.Add('--build-ide=');
  AProcess.Options := [poUsePipes, poStdErrToOutput];

  AProcess.ShowWindow := swoHIDE;
  Getmem(Buffer, C_BUFSIZE);
  SStream := TStringStream.Create('');
  ///
  AProcess.Execute;
  // fazer o processo abaixo dentro de uma thread pra atualizar o log
  while AProcess.Running do
  begin
    nread := AProcess.Output.Read(Buffer^, C_BUFSIZE);
    if nread = 0 then
      sleep(100)
    else
    begin
      SStream.size := 0;
      SStream.Write(Buffer^, nread);
      outputScreen.Lines.Append(SStream.DataString);
    end;
  end;
  repeat
    nread := AProcess.Output.Read(Buffer^, C_BUFSIZE);
    if nread > 0 then
    begin
      SStream.size := 0;
      SStream.Write(Buffer^, nread);
      outputScreen.Lines.Append(SStream.DataString);
    end;
  until nread = 0;
  ///
  AProcess.Free;
  Freemem(buffer);
  SStream.Free;
end;

procedure TLazInstaller.Install;
const
  C_BUFSIZE = 2048;
var
  AProcess: TProcess;
  Buffer: pointer;
  SStream: TStringStream;
  nread: longint;
  i: integer;
  fPath: string;
begin
  fPath := IncludeTrailingPathDelimiter(edtPathLazarus.Text) + 'lazbuild';

  for i := 0 to strListACBr.Count - 1 do
  begin
    AProcess := TProcess.Create(nil);
    try
      AProcess.CommandLine := concat(fPath, ' --add-package-link ',
        strListACBr.Strings[i]);
      AProcess.Options := [poUsePipes, poStdErrToOutput];
      AProcess.ShowWindow := swoHIDE;
      ///
      Getmem(Buffer, C_BUFSIZE);
      SStream := TStringStream.Create('');
      ///
      AProcess.Execute;
      // acrescentar thread no processo abaixo
      while AProcess.Running do
      begin
        nread := AProcess.Output.Read(Buffer^, C_BUFSIZE);
        if nread = 0 then
          sleep(100)
        else
        begin
          SStream.size := 0;
          SStream.Write(Buffer^, nread);
          { ...to do - verificar o porque nao esta dando saida em outputscreen}
          outputScreen.Lines.Append(SStream.DataString);
          outputScreen.Lines.Append(strListACBr.Strings[i]);
        end;
      end;

      repeat
        nread := AProcess.Output.Read(Buffer^, C_BUFSIZE);
        if nread > 0 then
        begin
          SStream.size := 0;
          SStream.Write(Buffer^, nread);
          outputScreen.Lines.Append(strListACBr.Strings[i]);
        end
      until nread = 0;

    finally
      AProcess.Free;
      Freemem(buffer);
      SStream.Free;
      Application.ProcessMessages;
    end;
  end; /// for in
end;

constructor TLazInstaller.Create;
begin
  FindLazarusInstallDir;
end;

destructor TLazInstaller.Destroy;
begin
  inherited Destroy;
end;

{ TIDEObject }

constructor TIDEObject.Create;
begin
  Icon := nil;
end;

destructor TIDEObject.Destroy;
begin
  Icon.Free;
end;

end.
