Unit uRESTDWMemVCLUtils;
{$I uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
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

Const
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


Function MsgBox(Handle: THandle; Const Caption, Text: string; Flags: Integer): Integer; overload;
// returns True if user clicked Yes
Function MsgYesNo(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// returns True if user clicked Retry
Function MsgRetryCancel(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// returns IDABORT, IDRETRY or IDIGNORE
Function MsgAbortRetryIgnore(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Integer;
// returns IDYES, IDNO or IDCANCEL
Function MsgYesNoCancel(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Integer;
// returns True if user clicked OK
Function MsgOKCancel(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Boolean;
// dialog without icon
Procedure MsgOK(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
// dialog with info icon
Procedure MsgInfo(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
// dialog with warning icon
Procedure MsgWarn(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
// dialog with question icon
Procedure MsgQuestion(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
// dialog with error icon
Procedure MsgError(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);

Implementation

Function MsgBox(Handle: THandle; Const Caption, Text: string; Flags: Integer): Integer;
Begin
  {$IFDEF MSWINDOWS}
  Result := Windows.MessageBox(Handle, PChar(Text), PChar(Caption), Flags);
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  Result := MsgBox(Caption, Text, Flags);
  {$ENDIF UNIX}
End;
Function MsgYesNo(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Boolean;
Begin
{$IFNDEF LINUX}
  Result := MsgBox(Handle, Caption, Msg, MB_YESNO or Flags) = IDYES;
 {$ENDIF}
End;
Function MsgRetryCancel(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Boolean;
Begin
{$IFNDEF LINUX}
  Result := MsgBox(Handle, Caption, Msg, MB_RETRYCANCEL or Flags) = IDRETRY;
  {$ENDIF}
End;
Function MsgAbortRetryIgnore(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Integer;
Begin
  Result := MsgBox(Handle, Caption, Msg, MB_ABORTRETRYIGNORE or Flags);
End;
Function MsgYesNoCancel(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Integer;
Begin
  Result := MsgBox(Handle, Caption, Msg, MB_YESNOCANCEL or Flags);
End;
Function MsgOKCancel(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0): Boolean;
Begin
{$IFNDEF LINUX}
  Result := MsgBox(Handle, Caption, Msg, MB_OKCANCEL or Flags) = IDOK;
{$ENDIF}
End;
Procedure MsgOK(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
Begin
  MsgBox(Handle, Caption, Msg, MB_OK or Flags);
End;
Procedure MsgInfo(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
Begin
  MsgOK(Handle, Msg, Caption, MB_ICONINFORMATION or Flags);
End;
Procedure MsgWarn(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
Begin
  MsgOK(Handle, Msg, Caption, MB_ICONWARNING or Flags);
End;
Procedure MsgQuestion(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
Begin
  MsgOK(Handle, Msg, Caption, MB_ICONQUESTION or Flags);
End;
Procedure MsgError(Handle: Integer; Const Msg, Caption: string; Flags: DWORD = 0);
Begin
  MsgOK(Handle, Msg, Caption, MB_ICONERROR or Flags);
End;

End.
