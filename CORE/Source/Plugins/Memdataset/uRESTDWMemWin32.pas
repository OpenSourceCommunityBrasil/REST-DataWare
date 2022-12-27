unit uRESTDWMemWin32;
interface
{$I ..\..\Includes\uRESTDWPlataform.inc}
{$I ..\..\Includes\windowsonly.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFDEF FPC}
 {$MODE Delphi}
 {$ASMMode Intel}
{$ENDIF}

{$MINENUMSIZE 4}
{$ALIGN ON}
uses
  {$IFDEF HAS_UNITSCOPE}
  Winapi.Windows, System.SysUtils,
  {$IFNDEF FPC}
  Winapi.AccCtrl, Winapi.ActiveX,
  {$ENDIF ~FPC}
  {$ELSE ~HAS_UNITSCOPE}
  Windows, SysUtils,
  {$IFNDEF FPC}
  AccCtrl,
  {$ENDIF ~FPC}
  ActiveX,
  {$ENDIF ~HAS_UNITSCOPE}
  uRESTDWMemBase;
{$HPPEMIT '#include <WinDef.h>'}
{$HPPEMIT '#include <WinNT.h>'}
{$HPPEMIT '#include <WinBase.h>'}
{$HPPEMIT '#include <BaseTsd.h>'}
{$HPPEMIT '#include <ImageHlp.h>'}
{$HPPEMIT '#include <lm.h>'}
{$HPPEMIT '#include <Nb30.h>'}
{$HPPEMIT '#include <RasDlg.h>'}
{$HPPEMIT '#include <Reason.h>'}
{$HPPEMIT '#include <ShlWApi.h>'}
{$HPPEMIT '#include <WinError.h>'}
{$HPPEMIT '#include <WinIoCtl.h>'}
{$HPPEMIT '#include <WinUser.h>'}
//{$HPPEMIT '#include <Powrprof.h>'}
{$HPPEMIT '#include <delayimp.h>'}
{$HPPEMIT '#include <propidl.h>'}
{$HPPEMIT '#include <msidefs.h>'}
{$HPPEMIT '#include <shlguid.h>'}
{$IFNDEF COMPILER14_UP}
{$HPPEMIT '#include <imgguids.h>'}
{$ENDIF ~COMPILER14_UP}
{$HPPEMIT '#include <objbase.h>'}
{$HPPEMIT '#include <ntsecapi.h>'}
{$HPPEMIT ''}
{$IFDEF RTL230_UP}
{$HPPEMIT '// To avoid ambiguity between IMAGE_LOAD_CONFIG_DIRECTORY32 and  Winapi::Windows::IMAGE_LOAD_CONFIG_DIRECTORY32'}
{$HPPEMIT '#define IMAGE_LOAD_CONFIG_DIRECTORY32 ::IMAGE_LOAD_CONFIG_DIRECTORY32'}
{$HPPEMIT ''}
{$HPPEMIT '// To avoid ambiguity between IMAGE_LOAD_CONFIG_DIRECTORY64 and  Winapi::Windows::IMAGE_LOAD_CONFIG_DIRECTORY64'}
{$HPPEMIT '#define IMAGE_LOAD_CONFIG_DIRECTORY64 ::IMAGE_LOAD_CONFIG_DIRECTORY64'}
{$HPPEMIT ''}
{$ENDIF RTL230_UP}
// EJclWin32Error
{$IFDEF MSWINDOWS}
type
  EJclWin32Error = class(EJclError)
  private
    FLastError: DWORD;
    FLastErrorMsg: string;
  public
    constructor Create(const Msg: string);
    constructor CreateFmt(const Msg: string; const Args: array of const);
    constructor CreateRes(Ident: Integer); overload;
    constructor CreateRes(ResStringRec: PResStringRec); overload;
    property LastError: DWORD read FLastError;
    property LastErrorMsg: string read FLastErrorMsg;
  end;
{$ENDIF MSWINDOWS}
//DOM-IGNORE-BEGIN
{$I win32api\WinDef.int}
{$I win32api\WinNT.int}
{$I win32api\WinBase.int}
{$I win32api\AclApi.int}
{$I win32api\ImageHlp.int}
{$I win32api\IoAPI.int}
{$I win32api\LmErr.int}
{$I win32api\LmCons.int}
{$I win32api\LmAccess.int}
{$I win32api\LmApiBuf.int}
{$I win32api\Lmwksta.int}
{$I win32api\Nb30.int}
{$I win32api\RasDlg.int}
{$I win32api\Reason.int}
{$I win32api\ShlObj.int}
{$I win32api\ShlWApi.int}
{$I win32api\WinError.int}
{$I win32api\WinIoctl.int}
{$I win32api\WinNLS.int}
{$I win32api\WinUser.int}
{$I win32api\PowrProf.int}
{$I win32api\DelayImp.int}
{$I win32api\MsiDefs.int}
{$I win32api\ShlGuid.int}
{$I win32api\imgguids.int}
{$I win32api\ObjBase.int}
{$I win32api\PropIdl.int}
{$I win32api\NtSecApi.int}
{$I win32api\TlHelp32.int}
{$I win32api\Winternl.int}
//DOM-IGNORE-END
{$IFDEF MSWINDOWS}
const
  RtdlSetNamedSecurityInfoW: function(pObjectName: LPWSTR; ObjectType: SE_OBJECT_TYPE;
    SecurityInfo: SECURITY_INFORMATION; psidOwner, psidGroup: PSID;
    pDacl, pSacl: PACL): DWORD stdcall = SetNamedSecurityInfoW;
  RtdlSetWaitableTimer: function(hTimer: THandle; var lpDueTime: TLargeInteger;
    lPeriod: Longint; pfnCompletionRoutine: TFNTimerAPCRoutine;
    lpArgToCompletionRoutine: Pointer; fResume: BOOL): BOOL stdcall = SetWaitableTimer;
  RtdlNetUserAdd: function(servername: LPCWSTR; level: DWORD;
    buf: PByte; parm_err: PDWord): NET_API_STATUS stdcall = NetUserAdd;
  RtdlNetUserDel: function(servername: LPCWSTR;
    username: LPCWSTR): NET_API_STATUS stdcall = NetUserDel;
  RtdlNetGroupAdd: function(servername: LPCWSTR; level: DWORD; buf: PByte;
    parm_err: PDWord): NET_API_STATUS stdcall = NetGroupAdd;
  RtdlNetGroupEnum: function(servername: LPCWSTR; level: DWORD;
    out bufptr: PByte; prefmaxlen: DWORD; out entriesread, totalentries: DWORD;
    resume_handle: PDWORD_PTR): NET_API_STATUS stdcall = NetGroupEnum;
  RtdlNetGroupDel: function(servername: LPCWSTR;
    groupname: LPCWSTR): NET_API_STATUS stdcall = NetGroupDel;
  RtdlNetLocalGroupAdd: function(servername: LPCWSTR; level: DWORD;
    buf: PByte; parm_err: PDWord): NET_API_STATUS stdcall = NetLocalGroupAdd;
  RtdlNetLocalGroupEnum: function(servername: LPCWSTR; level: DWORD;
    out bufptr: PByte; prefmaxlen: DWORD; out entriesread, totalentries: DWORD;
    resumehandle: PDWORD_PTR): NET_API_STATUS stdcall = NetLocalGroupEnum;
  RtdlNetLocalGroupDel: function(servername: LPCWSTR;
    groupname: LPCWSTR): NET_API_STATUS stdcall = NetLocalGroupDel;
  RtdlNetLocalGroupAddMembers: function(servername: LPCWSTR; groupname: LPCWSTR;
    level: DWORD; buf: PByte;
    totalentries: DWORD): NET_API_STATUS stdcall = NetLocalGroupAddMembers;
  RtdlNetApiBufferFree: function(Buffer: Pointer): NET_API_STATUS stdcall = NetApiBufferFree;
  RtdlGetCalendarInfoA: function(Locale: LCID; Calendar: CALID; CalType: CALTYPE;
    lpCalData: PAnsiChar; cchData: Integer;
    lpValue: PDWORD): Integer stdcall = GetCalendarInfoA;
  RtdlGetCalendarInfoW: function(Locale: LCID; Calendar: CALID; CalType: CALTYPE;
    lpCalData: PWideChar; cchData: Integer;
    lpValue: PDWORD): Integer stdcall = GetCalendarInfoW;
  RtdlEnumCalendarInfoExW: function(lpCalInfoEnumProc: TCalInfoEnumProcExW;
    Locale: LCID; Calendar: CALID; CalType: CALTYPE): BOOL stdcall = EnumCalendarInfoExW;
  RtdlGetVolumeNameForVolumeMountPointW: function(lpszVolumeMountPoint: LPCWSTR;
    lpszVolumeName: LPWSTR; cchBufferLength: DWORD): BOOL stdcall = GetVolumeNameForVolumeMountPointW;
  RtdlSetVolumeMountPointW: function(lpszVolumeMountPoint: LPCWSTR;
    lpszVolumeName: LPCWSTR): BOOL stdcall = SetVolumeMountPointW;
  RtdlDeleteVolumeMountPointW: function(lpszVolumeMountPoint: LPCWSTR): BOOL
    stdcall = DeleteVolumeMountPointW;
  RtdlNetBios: function(P: PNCB): UCHAR stdcall = NetBios;
{$ENDIF MSWINDOWS}
implementation
uses
  uRESTDWMemResources;

procedure GetProcedureAddress(var P: Pointer; const ModuleName, ProcName: string);
var
  ModuleHandle: HMODULE;
begin
  if not Assigned(P) then
  begin
    ModuleHandle := GetModuleHandle(PChar(ModuleName));
    if ModuleHandle = 0 then
    begin
      ModuleHandle := SafeLoadLibrary(PChar(ModuleName));
      if ModuleHandle = 0 then
        raise EJclError.CreateResFmt(@RsELibraryNotFound, [ModuleName]);
    end;
    P := GetProcAddress(ModuleHandle, PChar(ProcName));
    if not Assigned(P) then
      raise EJclError.CreateResFmt(@RsEFunctionNotFound, [ModuleName, ProcName]);
  end;
end;
//== { EJclWin32Error } ======================================================
{$IFDEF MSWINDOWS}
constructor EJclWin32Error.Create(const Msg: string);
begin
  FLastError := GetLastError;
  FLastErrorMsg := SysErrorMessage(FLastError);
  inherited CreateResFmt(@RsWin32Error, [FLastErrorMsg, FLastError, NativeLineBreak, Msg]);
end;
constructor EJclWin32Error.CreateFmt(const Msg: string; const Args: array of const);
begin
  FLastError := GetLastError;
  FLastErrorMsg := SysErrorMessage(FLastError);
  inherited CreateResFmt(@RsWin32Error, [FLastErrorMsg, FLastError, NativeLineBreak, Format(Msg, Args)]);
end;
constructor EJclWin32Error.CreateRes(Ident: Integer);
begin
  FLastError := GetLastError;
  FLastErrorMsg := SysErrorMessage(FLastError);
  inherited CreateResFmt(@RsWin32Error, [FLastErrorMsg, FLastError, NativeLineBreak, LoadStr(Ident)]);
end;
constructor EJclWin32Error.CreateRes(ResStringRec: PResStringRec);
begin
  FLastError := GetLastError;
  FLastErrorMsg := SysErrorMessage(FLastError);
  inherited CreateResFmt(@RsWin32Error, [FLastErrorMsg, FLastError, NativeLineBreak, LoadResString(ResStringRec)]);
end;
{$ENDIF MSWINDOWS}
{$I win32api\AclApi.imp}
{$I win32api\ImageHlp.imp}
{$I win32api\IoAPI.imp}
{$I win32api\LmAccess.imp}
{$I win32api\LmApiBuf.imp}
{$I win32api\Lmwksta.imp}
{$I win32api\Nb30.imp}
{$I win32api\WinBase.imp}
{$I win32api\WinNLS.imp}
{$I win32api\WinUser.imp}
{$I win32api\WinNT.imp}
{$I win32api\PowrProf.imp}
{$I win32api\ObjBase.imp}
{$I win32api\PropIdl.imp}
{$I win32api\NtSecApi.imp}
{$I win32api\TlHelp32.imp}
{$I win32api\Winternl.imp}
{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);
finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
end.

