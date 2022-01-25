program ExemploRaudusDW;

{$APPTYPE CONSOLE}

uses
  RaApplication,
  RaApplicationExe,
  RaConfig,
  SysUtils,
  uMain in 'uMain.pas' {Form2},
  udm in 'udm.pas' {dm: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  WriteLn('http://localhost:9090/ - open in browser');
  Application.Config.Port := 9090;

  {$IFDEF MSWINDOWS}
    Application.Config.WwwDiskDirectory := 'C:\Raudus\www';
    Application.Config.PathToZLib := 'C:\Raudus\requisite\zlib1.dll';
  {$ELSE}
    Application.Config.WwwDiskDirectory := '../../www';
    Application.Config.PathToZLib := '../../requisite/libz.so';
  {$ENDIF}

  Application.Config.SchedulerMode := rsmRunInSuperThread;
  Application.Config.CachePolicy := cpCacheNothing;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
