program ClientDw;
{$APPTYPE GUI}

uses


  Dialogs,
  Windows,
  System.SysUtils,
  Vcl.Forms,
  UPrincipal in 'UPrincipal.pas' {FrmPrincipal},
  Ufuncoes in 'libs\Ufuncoes.pas',
  UDM in 'UDM.pas' {DM: TDataModule},
  uLogin in 'uLogin.pas' {FrmLogin},
  uSplashConexao in 'uSplashConexao.pas' {FrmSplashConexao},
  UFindArea in 'libs\UFindArea.pas',
  uClasseFindArea in 'libs\uClasseFindArea.pas',
  NFDXML in '..\lib\NFDXML.pas' ,
  UBasicRO in 'libs\UBasicRO.pas' {FrmBasic},
  ULocalizar in 'libs\ULocalizar.pas' {FrmLocalizar},
  UCad_banco in 'cadastro\UCad_banco.pas' {FrmCad_banco};

{$R *.res}

var
  MutexHandle: THandle;
  hwind: HWND;

begin


  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  FormatSettings.LongDateFormat := 'dd/mm/yyyy';

  MutexHandle := CreateMutex(nil, True, 'ClientDw');

  if GetLastError = ERROR_ALREADY_EXISTS then
  begin

    MessageBeep(MB_ICONERROR);
    MessageDlg('Este aplicativo já está sendo executado!', mtError, [mbOK], 0);
    CloseHandle(MutexHandle);
    hwind := 0;

    repeat
      hwind := Windows.FindWindowEx(0, hwind, 'TApplication', 'ClientDw');
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
    Application.Title := 'ClientDw';
    Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TFrmLocalizar, FrmLocalizar);
  Application.Run;
  finally
    if LongBool(MutexHandle) then
      CloseHandle(MutexHandle);
  end;

end.
