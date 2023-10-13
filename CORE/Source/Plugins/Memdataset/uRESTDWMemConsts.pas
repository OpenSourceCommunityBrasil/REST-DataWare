unit uRESTDWMemConsts;

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
  SysUtils, Classes, TypInfo;
const
  {$IFDEF FPC}
  CM_BASE = $B000;
  {$ELSE}
   {$IFNDEF COMPILER9_UP}
    CM_BASE = $B000;
   {$ENDIF !COMPILER9_UP}
  {$ENDIF}
  { JvEditor }
  JvEditorCompletionChars = #8'0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm_';
  { Various units }
  DigitSymbols = ['0'..'9'];
  SignSymbols = ['+', '-'];
  IdentifierUppercaseLetters = ['A'..'Z'];
  IdentifierLowercaseLetters = ['a'..'z'];
  HexadecimalUppercaseLetters = ['A'..'F'];
  HexadecimalLowercaseLetters = ['a'..'f'];
  IdentifierLetters = IdentifierUppercaseLetters + IdentifierLowercaseLetters;
  IdentifierFirstSymbols = ['_'] + IdentifierLetters;
  IdentifierSymbols = IdentifierFirstSymbols + DigitSymbols;
  HexadecimalSymbols = DigitSymbols + HexadecimalUppercaseLetters + HexadecimalLowercaseLetters;
  {$IFDEF DELPHI6}
  SDelphiKey = 'Software\Borland\Delphi\6.0';
  {$ENDIF DELPHI6}
  {$IFDEF BCB6}
  SDelphiKey = 'Software\Borland\C++Builder\6.0';
  {$ENDIF BCB6}
  {$IFDEF DELPHI7}
  SDelphiKey = 'Software\Borland\Delphi\7.0';
  {$ENDIF DELPHI7}
  {$IFDEF DELPHI8}
  SDelphiKey = 'Software\Borland\BDS\2.0';
  {$ENDIF DELPHI8}
  {$IFDEF DELPHI9}
  SDelphiKey = 'Software\Borland\BDS\3.0';
  {$ENDIF DELPHI9}
  {$IFDEF DELPHI10}
  SDelphiKey = 'Software\Borland\BDS\4.0';
  {$ENDIF DELPHI10}
  {$IFDEF DELPHI11}
  SDelphiKey = 'Software\Borland\BDS\5.0';
  {$ENDIF DELPHI11}
  {$IFDEF DELPHI12}
  SDelphiKey = 'Software\CodeGear\BDS\6.0';
  {$ENDIF DELPHI12}
  {$IFDEF DELPHI14}
  SDelphiKey = 'Software\CodeGear\BDS\7.0';
  {$ENDIF DELPHI14}
  {$IFDEF DELPHI15}
  SDelphiKey = 'Software\Embarcadero\BDS\8.0';
  {$ENDIF DELPHI15}
  {$IFDEF DELPHI16}
  SDelphiKey = 'Software\Embarcadero\BDS\9.0';
  {$ENDIF DELPHI16}
  {$IFDEF DELPHI17}
  SDelphiKey = 'Software\Embarcadero\BDS\10.0';
  {$ENDIF DELPHI17}
  {$IFDEF DELPHI18}
  SDelphiKey = 'Software\Embarcadero\BDS\11.0';
  {$ENDIF DELPHI18}
  {$IFDEF DELPHI19}
  SDelphiKey = 'Software\Embarcadero\BDS\12.0';
  {$ENDIF DELPHI19}
  {$IFDEF DELPHI20}
  SDelphiKey = 'Software\Embarcadero\BDS\14.0';
  {$ENDIF DELPHI20}
  {$IFDEF DELPHI21}
  SDelphiKey = 'Software\Embarcadero\BDS\15.0';
  {$ENDIF DELPHI21}
  {$IFDEF DELPHI22}
  SDelphiKey = 'Software\Embarcadero\BDS\16.0';
  {$ENDIF DELPHI22}
  {$IFDEF DELPHI23}
  SDelphiKey = 'Software\Embarcadero\BDS\17.0';
  {$ENDIF DELPHI23}
  {$IFDEF DELPHI24}
  SDelphiKey = 'Software\Embarcadero\BDS\18.0';
  {$ENDIF DELPHI24}
  {$IFDEF DELPHI25}
  SDelphiKey = 'Software\Embarcadero\BDS\19.0';
  {$ENDIF DELPHI25}
  {$IFDEF DELPHI26}
  SDelphiKey = 'Software\Embarcadero\BDS\20.0';
  {$ENDIF DELPHI26}
  {$IFDEF DELPHI27}
  SDelphiKey = 'Software\Embarcadero\BDS\21.0';
  {$ENDIF DELPHI27}
  {$IFDEF DELPHI28}
  SDelphiKey = 'Software\Embarcadero\BDS\22.0';
  {$ENDIF DELPHI27}

  { JvDataProvider constants }
  { Consumer attributes }
  DPA_RenderDisabledAsGrayed = 1;
  DPA_RendersSingleItem = 2;
  DPA_ConsumerDisplaysList = 3;
  { Define command message that did not exist in earlier VCL versions }
  {$IFNDEF COMPILER9_UP}
  CM_INVALIDATEDOCKHOST = CM_BASE + 70;
  {$ENDIF !COMPILER9_UP}
  { Values for WParam for CM_SPEEDBARCHANGED message }
  SBR_CHANGED        = 0; { change buttons properties  }
  SBR_DESTROYED      = 1; { destroy SpeedBar           }
  SBR_BTNSELECT      = 2; { select button in SpeedBar  }
  SBR_BTNSIZECHANGED = 3; { button size changed        }
  { TBitmap.GetTransparentColor from GRAPHICS.PAS use this value }
  PaletteMask = $02000000;
  sLineBreakStr = string(sLineBreak); // "native string" line break constant
  sLineBreakLen = Length(sLineBreak);
  CrLf = #13#10;
  Cr = #13;
  Lf = #10;
  Backspace = #8;
  Tab = #9;
  Esc = #27;
  Del = #127;
  CtrlC = ^C;
  CtrlH = ^H;
  CtrlI = ^I;
  CtrlJ = ^J;
  CtrlM = ^M;
  CtrlV = ^V;
  CtrlX = ^X;
  {$IFDEF MSWINDOWS}
  RegPathDelim = '\';
  PathDelim = '\';
  DriveDelim = ':';
  PathSep = ';';
  AllFilePattern = '*.*';
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  RegPathDelim = '_';
  PathDelim = '/';
  AllFilePattern = '*';
  {$ENDIF UNIX}
  {const Separators is used in GetWordOnPos, JvUtils.ReplaceStrings and SubWord}
  Separators: TSysCharSet = [#00, ' ', '-', #13, #10, '.', ',', '/', '\', '#', '"', '''',
    ':', '+', '%', '*', '(', ')', ';', '=', '{', '}', '[', ']', '<', '>'];
  DigitChars = ['0'..'9'];
const
  ROP_DSPDxax = $00E20746;
const
  FOURCC_ACON = 'ACON';
  FOURCC_IART = 'IART';
  FOURCC_INAM = 'INAM';
  FOURCC_INFO = 'INFO';
  FOURCC_LIST = 'LIST';
  FOURCC_RIFF = 'RIFF';
  FOURCC_anih = 'anih';
  FOURCC_fram = 'fram';
  FOURCC_icon = 'icon';
  FOURCC_rate = 'rate';
  FOURCC_seq  = 'seq ';
  AF_ICON     = $00000001;
  AF_SEQUENCE = $00000002;
const
  KeyboardShiftStates = [ssShift, ssAlt, ssCtrl];
  MouseShiftStates = [ssLeft, ssRight, ssMiddle, ssDouble];
  tkStrings: set of TTypeKind = [tkString, tkLString, {$IFDEF UNICODE} tkUString, {$ENDIF} tkWString];
{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JVCL\run'
  );
{$ENDIF UNITVERSIONING}
implementation
{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);
finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
end.
