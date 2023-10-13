unit uRESTDWMemVCLUtils;
{$I ..\..\Includes\uRESTDW.inc}
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

interface

uses
  Variants,
  {$IFDEF MSWINDOWS}
  Windows, Messages,
  {$ENDIF MSWINDOWS}
  Types,
  {$IFDEF HAS_UNIT_SYSTEM_UITYPES}
  System.UITypes,
  {$ENDIF}
  SysUtils,
  Classes,
  uRESTDWMemBase,
  uRESTDWMemTypes;

const
  MB_OK               = $00000000;
  MB_OKCANCEL         = $00000001;
  MB_ABORTRETRYIGNORE = $00000002;
  MB_YESNOCANCEL      = $00000003;
  MB_YESNO            = $00000004;
  MB_RETRYCANCEL      = $00000005;
  MB_ICONHAND         = $00000010;
  MB_ICONQUESTION     = $00000020;
  MB_ICONEXCLAMATION  = $00000030;
  MB_ICONASTERISK     = $00000040;
  MB_USERICON         = $00000080;
  MB_ICONWARNING      = MB_ICONEXCLAMATION;
  MB_ICONERROR        = MB_ICONHAND;
  MB_ICONINFORMATION  = MB_ICONASTERISK;
  MB_ICONSTOP         = MB_ICONHAND;


function MsgBox(Handle: THandle; const Caption, Text: string; Flags: Integer): Integer; overload;
// returns True if user clicked Yes
function MsgYesNo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// returns True if user clicked Retry
function MsgRetryCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// returns IDABORT, IDRETRY or IDIGNORE
function MsgAbortRetryIgnore(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
// returns IDYES, IDNO or IDCANCEL
function MsgYesNoCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
// returns True if user clicked OK
function MsgOKCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// dialog without icon
procedure MsgOK(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with info icon
procedure MsgInfo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with warning icon
procedure MsgWarn(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with question icon
procedure MsgQuestion(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
// dialog with error icon
procedure MsgError(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);

implementation

function MsgBox(Handle: THandle; const Caption, Text: string; Flags: Integer): Integer;
begin
  {$IFDEF MSWINDOWS}
  Result := Windows.MessageBox(Handle, PChar(Text), PChar(Caption), Flags);
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  Result := MsgBox(Caption, Text, Flags);
  {$ENDIF UNIX}
end;
function MsgYesNo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_YESNO or Flags) = IDYES;
end;
function MsgRetryCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_RETRYCANCEL or Flags) = IDRETRY;
end;
function MsgAbortRetryIgnore(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_ABORTRETRYIGNORE or Flags);
end;
function MsgYesNoCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Integer;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_YESNOCANCEL or Flags);
end;
function MsgOKCancel(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0): Boolean;
begin
  Result := MsgBox(Handle, Caption, Msg, MB_OKCANCEL or Flags) = IDOK;
end;
procedure MsgOK(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgBox(Handle, Caption, Msg, MB_OK or Flags);
end;
procedure MsgInfo(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONINFORMATION or Flags);
end;
procedure MsgWarn(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONWARNING or Flags);
end;
procedure MsgQuestion(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONQUESTION or Flags);
end;
procedure MsgError(Handle: Integer; const Msg, Caption: string; Flags: DWORD = 0);
begin
  MsgOK(Handle, Msg, Caption, MB_ICONERROR or Flags);
end;

end.
