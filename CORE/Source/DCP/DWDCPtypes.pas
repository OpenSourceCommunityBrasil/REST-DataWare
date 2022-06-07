unit DWDCPtypes;

{$INCLUDE 'uRESTDW.inc'}

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
{$IFNDEF COMPILER11_UP}
  TBytes = array of Byte;
{$ENDIF ~COMPILER11_UP}
{$IFNDEF SUPPORTS_UINT32}
  UInt32 = Integer;
{$ENDIF ~SUPPORTS_UINT32}
{$IFNDEF SUPPORTS_UINT64}
  UInt64 = Int64;
{$ENDIF ~SUPPORTS_UINT64}
 dword = UInt32;
 Tdwordarray = array [0..8191] of dword;


type
{$IFNDEF COMPILER16_UP}
  NativeUInt = {$IFDEF CPU64} UInt64 {$ELSE} Cardinal {$ENDIF};
{$ENDIF}
  PointerToInt = {$IFDEF COMPILER16_UP} PByte {$ELSE} NativeUInt {$ENDIF};
{$IFNDEF FPC}
{$IF Defined(HAS_FMX)}
 {$IF Defined(HAS_UTF8)}
  {$IF (CompilerVersion = 29) or Defined(HAS_FMX)} // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
  DWDCPRawString     = UnicodeString;
  DWDCPUtf8String    = UnicodeString;
  DWDCPUnicodeString = UnicodeString;
  {$ELSE}
  DWDCPRawString     = RawByteString;
  DWDCPUtf8String    = Utf8String;
  DWDCPUnicodeString = UnicodeString;
  {$IFEND}
 {$ELSE}
  DWDCPRawString     = RawByteString;
  DWDCPUtf8String    = Utf8String;
  DWDCPUnicodeString = UnicodeString;
 {$IFEND}
{$ELSE}
 DWDCPRawString     = RawByteString;
 DWDCPUtf8String    = Utf8String;
 {$IF (CompilerVersion < 29)} // Feito para  contornar BUG do Delphi XE8 - Somente no XE8
  DWDCPUnicodeString = Utf8String;
 {$ELSE}
  DWDCPUnicodeString = UnicodeString;
 {$IFEND}
{$IFEND}
{$ELSE}
DWDCPRawString     = RawByteString;
DWDCPUtf8String    = Utf8String;
DWDCPUnicodeString = UnicodeString;
{$ENDIF}


implementation

end.
