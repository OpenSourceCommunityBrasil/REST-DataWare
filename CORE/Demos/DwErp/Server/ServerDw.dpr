program ServerDw;

uses
  MidasLib,
  Vcl.Forms,
  Windows,
  System.UITypes,
  uPrincipal in 'uPrincipal.pas' {FrmServer},
  uClassePonto in 'Libs\uClassePonto.pas',
  uUpdateDB in 'Libs\uUpdateDB.pas' {$R *.res},
  Vcl.Dialogs,
  System.SysUtils,
  UDmService in 'UDmService.pas' {ServerMetodDM: TDataModule},
  NFDXML in '..\lib\NFDXML.pas';

{$R *.res}

var
  MutexHandle: THandle;
  hwind: HWND;


begin

  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  FormatSettings.LongDateFormat := 'dd/mm/yyyy';

  MutexHandle := CreateMutex(nil, True, 'ServerDw');
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin

    MessageBeep(MB_ICONERROR);
    MessageDlg('Este aplicativo já está sendo executado!', mtError, [mbOK], 0);
    CloseHandle(MutexHandle);
    hwind := 0;

    repeat
      hwind := Windows.FindWindowEx(0, hwind, 'TApplication', 'ServerDw');
    until (hwind <> Application.Handle);
    if (hwind <> 0) then
    begin
      Windows.ShowWindow(hwind, SW_SHOWNORMAL);
      Windows.SetForegroundWindow(hwind);
    end;
    Application.Terminate;
    abort;
  end;

  try
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    if FindCmdLineSwitch('updatedb', ['-', '\', '/'], True) then
      Funcoes.UpdateDB := True
    else
      Funcoes.UpdateDB := false;

    Application.CreateForm(TDM_UpdateDB, DM_UpdateDB);
  Application.CreateForm(TFrmServer, FrmServer);
  Application.Run;
  finally
    if LongBool(MutexHandle) then
      CloseHandle(MutexHandle);
  end;

end.
