unit DWDCPtypes;

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

{ ************************************ }
{ A few predefined types to help out }
{ ************************************ }

type
  Pbyte = ^byte;
  Pword = ^word;
  Pdword = ^dword;
  Pint64 = ^int64;
  Pwordarray = ^Twordarray;
  Twordarray = array [0..19383] of word;
  Pdwordarray = ^Tdwordarray;
  {$IFNDEF SUPPORTS_UNICODE_STRING}
  RawByteString = AnsiString;
  {$ENDIF}
  {$IFNDEF DELPHI2007UP}
  TBytes = array of Byte;
  {$ENDIF}
  {$IFNDEF SUPPORTS_UINT32}
  UInt32 = Integer;
  {$ENDIF ~SUPPORTS_UINT32}
  {$IFNDEF SUPPORTS_UINT64}
  UInt64 = Int64;
  {$ENDIF ~SUPPORTS_UINT64}
 dword = UInt32;
 Tdwordarray = array [0..8191] of dword;

type
{$IFNDEF DELPHIXE2UP}
  NativeUInt = {$IFDEF CPU64} UInt64 {$ELSE} Cardinal {$ENDIF};
{$ENDIF}
  PointerToInt = {$IFDEF DELPHIXE2UP} PByte {$ELSE} NativeUInt {$ENDIF};
{$IFNDEF RESTDWLAZARUS}
{$IFDEF RESTDWFMX}
 {$IFDEF HAS_UTF8}
  {$IFDEF DELPHIXE8UP} // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
  DWDCPRawString     = Utf8String;
  DWDCPUtf8String    = UnicodeString;
  DWDCPUnicodeString = UnicodeString;
  {$ELSE}
  DWDCPRawString     = RawByteString;
  DWDCPUtf8String    = Utf8String;
  DWDCPUnicodeString = UnicodeString;
  {$ENDIF}
 {$ELSE}
  DWDCPRawString     = RawByteString;
  DWDCPUtf8String    = Utf8String;
  DWDCPUnicodeString = UnicodeString;
 {$ENDIF}
{$ELSE}
 DWDCPRawString     = RawByteString;
 DWDCPUtf8String    = Utf8String;
 {$IFNDEF DELPHIXE8UP} // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
  DWDCPUnicodeString = Utf8String;
 {$ELSE}
  DWDCPUnicodeString = UnicodeString;
 {$ENDIF}
{$ENDIF}
{$ELSE}
DWDCPRawString     = RawByteString;
DWDCPUtf8String    = Utf8String;
DWDCPUnicodeString = UnicodeString;
{$ENDIF}


implementation

end.
