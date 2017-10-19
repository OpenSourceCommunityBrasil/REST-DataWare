{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16400: IdSoapInterfaceTestsIntfImpl.pas 
{
{   Rev 1.2    19/6/2003 21:36:10  GGrieve
{ Version #1
}
{
{   Rev 1.1    18/3/2003 11:15:56  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:27:52  GGrieve
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  Better test children
  18-Mar 2003   Grahame Grieve                  QName, RawXML, Schema extensibility, Kylix compile fixes
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Andrew Cumming                  Many more tests for class properties
  26-Aug 2002   Grahame Grieve                  D4 Compiler fixes
  17-Jul 2002   Andrew Cumming                  Fixed leak in ProcParamVarStreamArray test (leak was in test not IndySoap)
  29-May 2002   Grahame Grieve                  Added Binary Array tests + move type registration
   4-May 2002   Andrew Cumming                  Added small test to assist in property array bug search
  25-Apr 2002   Andrew Cumming                  Added more testing for classes with dynamic array members
  09-Apr 2002   Andrew Cumming                  Added tests for nil classes and empty arrays
  08-Apr 2002   Grahame Grieve                  Binary Properties and Objects by reference tests
  06-Apr 2002   Andrew Cumming                  Added date/time tests
  05-Apr 2002   Andrew Cumming                  Added more tests for arrays of classes
  29-Mar 2002   Grahame Grieve                  Add tests relating to object lifetime management (will force fix of server leaks)
  27-Mar 2002   Andrew Cumming                  Added code for missing tests
  27-Mar 2002   Grahame Grieve                  Add Tests for Arrays of objects
  26-Mar 2002   Andrew Cumming                  Change type registration
  19-Mar 2002   Andrew Cumming                  Added extra namespace info for D4/D5 support
  14-Mar 2002   Grahame Grieve                  Fix String tests (char #12 illegal). Change Widestring tests (still failing though)
  12-Mar 2002   Grahame Grieve                  Added Binary Tests
   8-Mar 2002   Andrew Cumming                  Added code for Boolean tests
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
   3-Mar 2002   Andrew Cumming                  Added code fo SETs testing
   1-Mar 2002   Andrew Cumming                  Added polymorphic class tests
  28-Feb 2002   Andrew Cumming                  First version of classes completed
  24-Feb 2002   Andrew Cumming                  Added dynamic array result tests
  24-Feb 2002   Andrew Cumming                  More dynamic array tests
  23-Feb 2002   Andrew Cumming                  Added some missing logic to tests
  22-Feb 2002   Andrew Cumming                  More dynamic array tests + ASCII string escape test
  11-Feb 2002   Andrew Cumming                  First added file
}

unit IdSoapInterfaceTestsIntfImpl;

interface

{$I IdSoapDefines.inc}


implementation

uses
  Classes,
  IdGlobal,
  IdSoapDateTime,
  IdSoapInterfaceTestsIntfDefn,
  IdSoapInterfaceTestsServer,
  IdSoapIntfRegistry,
  IdSoapRawXml,
  IdSoapTypeRegistry,
  IdSoapTestingUtils,
  IdSoapUtilities,
  IdSoapXml,
  SysUtils,
  TypInfo;

var
  gToggle: Boolean;

type
  EServerFailed = class(Exception);

  TIdSoapInterfaceTestsInterface = class(TIdSoapBaseImplementation, IIdSoapInterfaceTestsInterface)
  Private
    FMessage: String;
    procedure Check(ACondition: Boolean; AMessage: String);
  Published
    procedure ProcCall; StdCall;
    procedure TestServerFailureReporter; StdCall;
    procedure TestPassed; StdCall;
    procedure DefineString(AStringType: TTypeKind); StdCall;
    procedure DefineValues(AForceCardinal: Boolean; AOrdType: TOrdType; ATestValues1: Boolean); StdCall;
    procedure DefineInt64(ATestValues1: Boolean); StdCall;
    procedure DefineReal(AFloatType: TFloatType; ATestValues1: Boolean); StdCall;
    // misc tests
    procedure TestFullAsciiSet(AString: String); StdCall;
    // BOOLEAN tests
    function FuncRetBoolToggle: Boolean; StdCall;
    function FuncBoolRetBool(ABool: Boolean): Boolean; StdCall;
    function FuncVarBoolRetBool(var ABool: Boolean): Boolean; StdCall;
    function FuncBoolBoolRetBool(ABool1, ABool2: Boolean): Boolean; StdCall;
    function FuncVarBoolBoolRetBool(var ABool1: Boolean; ABool2: Boolean): Boolean; StdCall;
    function FuncBoolVarBoolRetBool(ABool1: Boolean; var ABool2: Boolean): Boolean; StdCall;
    function FuncVarBoolVarBoolRetBool(var ABool1: Boolean; var ABool2: Boolean): Boolean; StdCall;
    function FuncConstBoolBoolRetBool(const ABool1: Boolean; ABool2: Boolean): Boolean; StdCall;
    function FuncBoolConstBoolRetBool(ABool1: Boolean; const ABool2: Boolean): Boolean; StdCall;
    function FuncConstBoolConstBoolRetBool(const ABool1: Boolean; const ABool2: Boolean): Boolean; StdCall;
    function FuncOutBoolBoolRetBool(out ABool1: Boolean; ABool2: Boolean): Boolean; StdCall;
    function FuncBoolOutBoolRetBool(ABool1: Boolean; out ABool2: Boolean): Boolean; StdCall;
    function FuncOutBoolOutBoolRetBool(out ABool1: Boolean; out ABool2: Boolean): Boolean; StdCall;
    // BYTE tests
    function FuncRetByteToggle: Byte; StdCall;
    function FuncByteRetByte(AByte: Byte): Byte; StdCall;
    function FuncVarByteRetByte(var AByte: Byte): Byte; StdCall;
    function FuncByteByteRetByte(AByte1, AByte2: Byte): Byte; StdCall;
    function FuncVarByteByteRetByte(var AByte1: Byte; AByte2: Byte): Byte; StdCall;
    function FuncByteVarByteRetByte(AByte1: Byte; var AByte2: Byte): Byte; StdCall;
    function FuncVarByteVarByteRetByte(var AByte1: Byte; var AByte2: Byte): Byte; StdCall;
    function FuncConstByteByteRetByte(const AByte1: Byte; AByte2: Byte): Byte; StdCall;
    function FuncByteConstByteRetByte(AByte1: Byte; const AByte2: Byte): Byte; StdCall;
    function FuncConstByteConstByteRetByte(const AByte1: Byte; const AByte2: Byte): Byte; StdCall;
    function FuncOutByteByteRetByte(out AByte1: Byte; AByte2: Byte): Byte; StdCall;
    function FuncByteOutByteRetByte(AByte1: Byte; out AByte2: Byte): Byte; StdCall;
    function FuncOutByteOutByteRetByte(out AByte1: Byte; out AByte2: Byte): Byte; StdCall;
    // CHAR tests
    function FuncRetCharToggle: Char; StdCall;
    function FuncCharRetChar(AChar: Char): Char; StdCall;
    function FuncVarCharRetChar(var AChar: Char): Char; StdCall;
    function FuncCharCharRetChar(AChar1, AChar2: Char): Char; StdCall;
    function FuncVarCharCharRetChar(var AChar1: Char; AChar2: Char): Char; StdCall;
    function FuncCharVarCharRetChar(AChar1: Char; var AChar2: Char): Char; StdCall;
    function FuncVarCharVarCharRetChar(var AChar1: Char; var AChar2: Char): Char; StdCall;
    function FuncConstCharCharRetChar(const AChar1: Char; AChar2: Char): Char; StdCall;
    function FuncCharConstCharRetChar(AChar1: Char; const AChar2: Char): Char; StdCall;
    function FuncConstCharConstCharRetChar(const AChar1: Char; const AChar2: Char): Char; StdCall;
    function FuncOutCharCharRetChar(out AChar1: Char; AChar2: Char): Char; StdCall;
    function FuncCharOutCharRetChar(AChar1: Char; out AChar2: Char): Char; StdCall;
    function FuncOutCharOutCharRetChar(out AChar1: Char; out AChar2: Char): Char; StdCall;
    // WIDECHAR TESTS
    function FuncRetWideCharToggle: WideChar; StdCall;
    function FuncWideCharRetWideChar(AWideChar: WideChar): WideChar; StdCall;
    function FuncVarWideCharRetWideChar(var AWideChar: WideChar): WideChar; StdCall;
    function FuncWideCharWideCharRetWideChar(AWideChar1, AWideChar2: WideChar): WideChar; StdCall;
    function FuncVarWideCharWideCharRetWideChar(var AWideChar1: WideChar; AWideChar2: WideChar): WideChar; StdCall;
    function FuncWideCharVarWideCharRetWideChar(AWideChar1: WideChar; var AWideChar2: WideChar): WideChar; StdCall;
    function FuncVarWideCharVarWideCharRetWideChar(var AWideChar1: WideChar; var AWideChar2: WideChar): WideChar; StdCall;
    function FuncConstWideCharWideCharRetWideChar(const AWideChar1: WideChar; AWideChar2: WideChar): WideChar; StdCall;
    function FuncWideCharConstWideCharRetWideChar(AWideChar1: WideChar; const AWideChar2: WideChar): WideChar; StdCall;
    function FuncConstWideCharConstWideCharRetWideChar(const AWideChar1: WideChar; const AWideChar2: WideChar): WideChar; StdCall;
    function FuncOutWideCharWideCharRetWideChar(out AWideChar1: WideChar; AWideChar2: WideChar): WideChar; StdCall;
    function FuncWideCharOutWideCharRetWideChar(AWideChar1: WideChar; out AWideChar2: WideChar): WideChar; StdCall;
    function FuncOutWideCharOutWideCharRetWideChar(out AWideChar1: WideChar; out AWideChar2: WideChar): WideChar; StdCall;
    // SHORTINT TESTS
    function FuncRetShortIntToggle: ShortInt; StdCall;
    function FuncShortIntRetShortInt(AShortInt: ShortInt): ShortInt; StdCall;
    function FuncVarShortIntRetShortInt(var AShortInt: ShortInt): ShortInt; StdCall;
    function FuncShortIntShortIntRetShortInt(AShortInt1, AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncVarShortIntShortIntRetShortInt(var AShortInt1: ShortInt; AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncShortIntVarShortIntRetShortInt(AShortInt1: ShortInt; var AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncVarShortIntVarShortIntRetShortInt(var AShortInt1: ShortInt; var AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncConstShortIntShortIntRetShortInt(const AShortInt1: ShortInt; AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncShortIntConstShortIntRetShortInt(AShortInt1: ShortInt; const AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncConstShortIntConstShortIntRetShortInt(const AShortInt1: ShortInt; const AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncOutShortIntShortIntRetShortInt(out AShortInt1: ShortInt; AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncShortIntOutShortIntRetShortInt(AShortInt1: ShortInt; out AShortInt2: ShortInt): ShortInt; StdCall;
    function FuncOutShortIntOutShortIntRetShortInt(out AShortInt1: ShortInt; out AShortInt2: ShortInt): ShortInt; StdCall;
    // WORD TESTS
    function FuncRetWordToggle: Word; StdCall;
    function FuncWordRetWord(AWord: Word): Word; StdCall;
    function FuncVarWordRetWord(var AWord: Word): Word; StdCall;
    function FuncWordWordRetWord(AWord1, AWord2: Word): Word; StdCall;
    function FuncVarWordWordRetWord(var AWord1: Word; AWord2: Word): Word; StdCall;
    function FuncWordVarWordRetWord(AWord1: Word; var AWord2: Word): Word; StdCall;
    function FuncVarWordVarWordRetWord(var AWord1: Word; var AWord2: Word): Word; StdCall;
    function FuncConstWordWordRetWord(const AWord1: Word; AWord2: Word): Word; StdCall;
    function FuncWordConstWordRetWord(AWord1: Word; const AWord2: Word): Word; StdCall;
    function FuncConstWordConstWordRetWord(const AWord1: Word; const AWord2: Word): Word; StdCall;
    function FuncOutWordWordRetWord(out AWord1: Word; AWord2: Word): Word; StdCall;
    function FuncWordOutWordRetWord(AWord1: Word; out AWord2: Word): Word; StdCall;
    function FuncOutWordOutWordRetWord(out AWord1: Word; out AWord2: Word): Word; StdCall;
    // SMALLINT TESTS
    function FuncRetSmallintToggle: Smallint; StdCall;
    function FuncSmallintRetSmallint(ASmallint: Smallint): Smallint; StdCall;
    function FuncVarSmallintRetSmallint(var ASmallint: Smallint): Smallint; StdCall;
    function FuncSmallintSmallintRetSmallint(ASmallint1, ASmallint2: Smallint): Smallint; StdCall;
    function FuncVarSmallintSmallintRetSmallint(var ASmallint1: Smallint; ASmallint2: Smallint): Smallint; StdCall;
    function FuncSmallintVarSmallintRetSmallint(ASmallint1: Smallint; var ASmallint2: Smallint): Smallint; StdCall;
    function FuncVarSmallintVarSmallintRetSmallint(var ASmallint1: Smallint; var ASmallint2: Smallint): Smallint; StdCall;
    function FuncConstSmallintSmallintRetSmallint(const ASmallint1: Smallint; ASmallint2: Smallint): Smallint; StdCall;
    function FuncSmallintConstSmallintRetSmallint(ASmallint1: Smallint; const ASmallint2: Smallint): Smallint; StdCall;
    function FuncConstSmallintConstSmallintRetSmallint(const ASmallint1: Smallint; const ASmallint2: Smallint): Smallint; StdCall;
    function FuncOutSmallintSmallintRetSmallint(out ASmallint1: Smallint; ASmallint2: Smallint): Smallint; StdCall;
    function FuncSmallintOutSmallintRetSmallint(ASmallint1: Smallint; out ASmallint2: Smallint): Smallint; StdCall;
    function FuncOutSmallintOutSmallintRetSmallint(out ASmallint1: Smallint; out ASmallint2: Smallint): Smallint; StdCall;
    // CARDINAL TESTS
    function FuncRetCardinalToggle: Cardinal; StdCall;
    function FuncCardinalRetCardinal(ACardinal: Cardinal): Cardinal; StdCall;
    function FuncVarCardinalRetCardinal(var ACardinal: Cardinal): Cardinal; StdCall;
    function FuncCardinalCardinalRetCardinal(ACardinal1, ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncVarCardinalCardinalRetCardinal(var ACardinal1: Cardinal; ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncCardinalVarCardinalRetCardinal(ACardinal1: Cardinal; var ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncVarCardinalVarCardinalRetCardinal(var ACardinal1: Cardinal; var ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncConstCardinalCardinalRetCardinal(const ACardinal1: Cardinal; ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncCardinalConstCardinalRetCardinal(ACardinal1: Cardinal; const ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncConstCardinalConstCardinalRetCardinal(const ACardinal1: Cardinal; const ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncOutCardinalCardinalRetCardinal(out ACardinal1: Cardinal; ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncCardinalOutCardinalRetCardinal(ACardinal1: Cardinal; out ACardinal2: Cardinal): Cardinal; StdCall;
    function FuncOutCardinalOutCardinalRetCardinal(out ACardinal1: Cardinal; out ACardinal2: Cardinal): Cardinal; StdCall;
    // INTEGER TESTS
    function FuncRetIntegerToggle: Integer; StdCall;
    function FuncIntegerRetInteger(AInteger: Integer): Integer; StdCall;
    function FuncVarIntegerRetInteger(var AInteger: Integer): Integer; StdCall;
    function FuncIntegerIntegerRetInteger(AInteger1, AInteger2: Integer): Integer; StdCall;
    function FuncVarIntegerIntegerRetInteger(var AInteger1: Integer; AInteger2: Integer): Integer; StdCall;
    function FuncIntegerVarIntegerRetInteger(AInteger1: Integer; var AInteger2: Integer): Integer; StdCall;
    function FuncVarIntegerVarIntegerRetInteger(var AInteger1: Integer; var AInteger2: Integer): Integer; StdCall;
    function FuncConstIntegerIntegerRetInteger(const AInteger1: Integer; AInteger2: Integer): Integer; StdCall;
    function FuncIntegerConstIntegerRetInteger(AInteger1: Integer; const AInteger2: Integer): Integer; StdCall;
    function FuncConstIntegerConstIntegerRetInteger(const AInteger1: Integer; const AInteger2: Integer): Integer; StdCall;
    function FuncOutIntegerIntegerRetInteger(out AInteger1: Integer; AInteger2: Integer): Integer; StdCall;
    function FuncIntegerOutIntegerRetInteger(AInteger1: Integer; out AInteger2: Integer): Integer; StdCall;
    function FuncOutIntegerOutIntegerRetInteger(out AInteger1: Integer; out AInteger2: Integer): Integer; StdCall;
    // INT64 TESTS
    function FuncRetInt64Toggle: Int64; StdCall;
    function FuncInt64RetInt64(AInt64: Int64): Int64; StdCall;
    function FuncVarInt64RetInt64(var AInt64: Int64): Int64; StdCall;
    function FuncInt64Int64RetInt64(AInt641, AInt642: Int64): Int64; StdCall;
    function FuncVarInt64Int64RetInt64(var AInt641: Int64; AInt642: Int64): Int64; StdCall;
    function FuncInt64VarInt64RetInt64(AInt641: Int64; var AInt642: Int64): Int64; StdCall;
    function FuncVarInt64VarInt64RetInt64(var AInt641: Int64; var AInt642: Int64): Int64; StdCall;
    function FuncConstInt64Int64RetInt64(const AInt641: Int64; AInt642: Int64): Int64; StdCall;
    function FuncInt64ConstInt64RetInt64(AInt641: Int64; const AInt642: Int64): Int64; StdCall;
    function FuncConstInt64ConstInt64RetInt64(const AInt641: Int64; const AInt642: Int64): Int64; StdCall;
    function FuncOutInt64Int64RetInt64(out AInt641: Int64; AInt642: Int64): Int64; StdCall;
    function FuncInt64OutInt64RetInt64(AInt641: Int64; out AInt642: Int64): Int64; StdCall;
    function FuncOutInt64OutInt64RetInt64(out AInt641: Int64; out AInt642: Int64): Int64; StdCall;
    // SINGLE TESTS
    function FuncRetSingleToggle: Single; StdCall;
    function FuncSingleRetSingle(ASingle: Single): Single; StdCall;
    function FuncVarSingleRetSingle(var ASingle: Single): Single; StdCall;
    function FuncSingleSingleRetSingle(ASingle1, ASingle2: Single): Single; StdCall;
    function FuncVarSingleSingleRetSingle(var ASingle1: Single; ASingle2: Single): Single; StdCall;
    function FuncSingleVarSingleRetSingle(ASingle1: Single; var ASingle2: Single): Single; StdCall;
    function FuncVarSingleVarSingleRetSingle(var ASingle1: Single; var ASingle2: Single): Single; StdCall;
    function FuncConstSingleSingleRetSingle(const ASingle1: Single; ASingle2: Single): Single; StdCall;
    function FuncSingleConstSingleRetSingle(ASingle1: Single; const ASingle2: Single): Single; StdCall;
    function FuncConstSingleConstSingleRetSingle(const ASingle1: Single; const ASingle2: Single): Single; StdCall;
    function FuncOutSingleSingleRetSingle(out ASingle1: Single; ASingle2: Single): Single; StdCall;
    function FuncSingleOutSingleRetSingle(ASingle1: Single; out ASingle2: Single): Single; StdCall;
    function FuncOutSingleOutSingleRetSingle(out ASingle1: Single; out ASingle2: Single): Single; StdCall;
    // DOUBLE TESTS
    function FuncRetDoubleToggle: Double; StdCall;
    function FuncDoubleRetDouble(ADouble: Double): Double; StdCall;
    function FuncVarDoubleRetDouble(var ADouble: Double): Double; StdCall;
    function FuncDoubleDoubleRetDouble(ADouble1, ADouble2: Double): Double; StdCall;
    function FuncVarDoubleDoubleRetDouble(var ADouble1: Double; ADouble2: Double): Double; StdCall;
    function FuncDoubleVarDoubleRetDouble(ADouble1: Double; var ADouble2: Double): Double; StdCall;
    function FuncVarDoubleVarDoubleRetDouble(var ADouble1: Double; var ADouble2: Double): Double; StdCall;
    function FuncConstDoubleDoubleRetDouble(const ADouble1: Double; ADouble2: Double): Double; StdCall;
    function FuncDoubleConstDoubleRetDouble(ADouble1: Double; const ADouble2: Double): Double; StdCall;
    function FuncConstDoubleConstDoubleRetDouble(const ADouble1: Double; const ADouble2: Double): Double; StdCall;
    function FuncOutDoubleDoubleRetDouble(out ADouble1: Double; ADouble2: Double): Double; StdCall;
    function FuncDoubleOutDoubleRetDouble(ADouble1: Double; out ADouble2: Double): Double; StdCall;
    function FuncOutDoubleOutDoubleRetDouble(out ADouble1: Double; out ADouble2: Double): Double; StdCall;
    // COMP TESTS
    function FuncRetCompToggle: Comp; StdCall;
    function FuncCompRetComp(AComp: Comp): Comp; StdCall;
    function FuncVarCompRetComp(var AComp: Comp): Comp; StdCall;
    function FuncCompCompRetComp(AComp1, AComp2: Comp): Comp; StdCall;
    function FuncVarCompCompRetComp(var AComp1: Comp; AComp2: Comp): Comp; StdCall;
    function FuncCompVarCompRetComp(AComp1: Comp; var AComp2: Comp): Comp; StdCall;
    function FuncVarCompVarCompRetComp(var AComp1: Comp; var AComp2: Comp): Comp; StdCall;
    function FuncConstCompCompRetComp(const AComp1: Comp; AComp2: Comp): Comp; StdCall;
    function FuncCompConstCompRetComp(AComp1: Comp; const AComp2: Comp): Comp; StdCall;
    function FuncConstCompConstCompRetComp(const AComp1: Comp; const AComp2: Comp): Comp; StdCall;
    function FuncOutCompCompRetComp(out AComp1: Comp; AComp2: Comp): Comp; StdCall;
    function FuncCompOutCompRetComp(AComp1: Comp; out AComp2: Comp): Comp; StdCall;
    function FuncOutCompOutCompRetComp(out AComp1: Comp; out AComp2: Comp): Comp; StdCall;
    // EXTENDED TESTS
    function FuncRetExtendedToggle: Extended; StdCall;
    function FuncExtendedRetExtended(AExtended: Extended): Extended; StdCall;
    function FuncVarExtendedRetExtended(var AExtended: Extended): Extended; StdCall;
    function FuncExtendedExtendedRetExtended(AExtended1, AExtended2: Extended): Extended; StdCall;
    function FuncVarExtendedExtendedRetExtended(var AExtended1: Extended; AExtended2: Extended): Extended; StdCall;
    function FuncExtendedVarExtendedRetExtended(AExtended1: Extended; var AExtended2: Extended): Extended; StdCall;
    function FuncVarExtendedVarExtendedRetExtended(var AExtended1: Extended; var AExtended2: Extended): Extended; StdCall;
    function FuncConstExtendedExtendedRetExtended(const AExtended1: Extended; AExtended2: Extended): Extended; StdCall;
    function FuncExtendedConstExtendedRetExtended(AExtended1: Extended; const AExtended2: Extended): Extended; StdCall;
    function FuncConstExtendedConstExtendedRetExtended(const AExtended1: Extended; const AExtended2: Extended): Extended; StdCall;
    function FuncOutExtendedExtendedRetExtended(out AExtended1: Extended; AExtended2: Extended): Extended; StdCall;
    function FuncExtendedOutExtendedRetExtended(AExtended1: Extended; out AExtended2: Extended): Extended; StdCall;
    function FuncOutExtendedOutExtendedRetExtended(out AExtended1: Extended; out AExtended2: Extended): Extended; StdCall;
    // CURRENCY TESTS
    function FuncRetCurrencyToggle: Currency; StdCall;
    function FuncCurrencyRetCurrency(ACurrency: Currency): Currency; StdCall;
    function FuncVarCurrencyRetCurrency(var ACurrency: Currency): Currency; StdCall;
    function FuncCurrencyCurrencyRetCurrency(ACurrency1, ACurrency2: Currency): Currency; StdCall;
    function FuncVarCurrencyCurrencyRetCurrency(var ACurrency1: Currency; ACurrency2: Currency): Currency; StdCall;
    function FuncCurrencyVarCurrencyRetCurrency(ACurrency1: Currency; var ACurrency2: Currency): Currency; StdCall;
    function FuncVarCurrencyVarCurrencyRetCurrency(var ACurrency1: Currency; var ACurrency2: Currency): Currency; StdCall;
    function FuncConstCurrencyCurrencyRetCurrency(const ACurrency1: Currency; ACurrency2: Currency): Currency; StdCall;
    function FuncCurrencyConstCurrencyRetCurrency(ACurrency1: Currency; const ACurrency2: Currency): Currency; StdCall;
    function FuncConstCurrencyConstCurrencyRetCurrency(const ACurrency1: Currency; const ACurrency2: Currency): Currency; StdCall;
    function FuncOutCurrencyCurrencyRetCurrency(out ACurrency1: Currency; ACurrency2: Currency): Currency; StdCall;
    function FuncCurrencyOutCurrencyRetCurrency(ACurrency1: Currency; out ACurrency2: Currency): Currency; StdCall;
    function FuncOutCurrencyOutCurrencyRetCurrency(out ACurrency1: Currency; out ACurrency2: Currency): Currency; StdCall;
    // SHORTSTRING TESTS
    function FuncRetShortStringToggle: ShortString; StdCall;
    function FuncShortStringRetShortString(AShortString: ShortString): ShortString; StdCall;
    function FuncVarShortStringRetShortString(var AShortString: ShortString): ShortString; StdCall;
    function FuncShortStringShortStringRetShortString(AShortString1, AShortString2: ShortString): ShortString; StdCall;
    function FuncVarShortStringShortStringRetShortString(var AShortString1: ShortString; AShortString2: ShortString): ShortString; StdCall;
    function FuncShortStringVarShortStringRetShortString(AShortString1: ShortString; var AShortString2: ShortString): ShortString; StdCall;
    function FuncVarShortStringVarShortStringRetShortString(var AShortString1: ShortString; var AShortString2: ShortString): ShortString; StdCall;
    function FuncConstShortStringShortStringRetShortString(const AShortString1: ShortString; AShortString2: ShortString): ShortString; StdCall;
    function FuncShortStringConstShortStringRetShortString(AShortString1: ShortString; const AShortString2: ShortString): ShortString; StdCall;
    function FuncConstShortStringConstShortStringRetShortString(const AShortString1: ShortString; const AShortString2: ShortString): ShortString; StdCall;
    function FuncOutShortStringShortStringRetShortString(out AShortString1: ShortString; AShortString2: ShortString): ShortString; StdCall;
    function FuncShortStringOutShortStringRetShortString(AShortString1: ShortString; out AShortString2: ShortString): ShortString; StdCall;
    function FuncOutShortStringOutShortStringRetShortString(out AShortString1: ShortString; out AShortString2: ShortString): ShortString; StdCall;
    // LONGSTRING TESTS
    function FuncRetStringToggle: String; StdCall;
    function FuncStringRetString(AString: String): String; StdCall;
    function FuncVarStringRetString(var AString: String): String; StdCall;
    function FuncStringStringRetString(AString1, AString2: String): String; StdCall;
    function FuncVarStringStringRetString(var AString1: String; AString2: String): String; StdCall;
    function FuncStringVarStringRetString(AString1: String; var AString2: String): String; StdCall;
    function FuncVarStringVarStringRetString(var AString1: String; var AString2: String): String; StdCall;
    function FuncConstStringStringRetString(const AString1: String; AString2: String): String; StdCall;
    function FuncStringConstStringRetString(AString1: String; const AString2: String): String; StdCall;
    function FuncConstStringConstStringRetString(const AString1: String; const AString2: String): String; StdCall;
    function FuncOutStringStringRetString(out AString1: String; AString2: String): String; StdCall;
    function FuncStringOutStringRetString(AString1: String; out AString2: String): String; StdCall;
    function FuncOutStringOutStringRetString(out AString1: String; out AString2: String): String; StdCall;
    // WIDESTRING TESTS
    function FuncRetWideStringToggle: WideString; StdCall;
    function FuncWideStringRetWideString(AWideString: WideString): WideString; StdCall;
    function FuncVarWideStringRetWideString(var AWideString: WideString): WideString; StdCall;
    function FuncWideStringWideStringRetWideString(AWideString1, AWideString2: WideString): WideString; StdCall;
    function FuncVarWideStringWideStringRetWideString(var AWideString1: WideString; AWideString2: WideString): WideString; StdCall;
    function FuncWideStringVarWideStringRetWideString(AWideString1: WideString; var AWideString2: WideString): WideString; StdCall;
    function FuncVarWideStringVarWideStringRetWideString(var AWideString1: WideString; var AWideString2: WideString): WideString; StdCall;
    function FuncConstWideStringWideStringRetWideString(const AWideString1: WideString; AWideString2: WideString): WideString; StdCall;
    function FuncWideStringConstWideStringRetWideString(AWideString1: WideString; const AWideString2: WideString): WideString; StdCall;
    function FuncConstWideStringConstWideStringRetWideString(const AWideString1: WideString; const AWideString2: WideString): WideString; StdCall;
    function FuncOutWideStringWideStringRetWideString(out AWideString1: WideString; AWideString2: WideString): WideString; StdCall;
    function FuncWideStringOutWideStringRetWideString(AWideString1: WideString; out AWideString2: WideString): WideString; StdCall;
    function FuncOutWideStringOutWideStringRetWideString(out AWideString1: WideString; out AWideString2: WideString): WideString; StdCall;
    // ENUMERATION TESTS
    function FuncRetEnumToggle: TLargeEnum; StdCall;
    function FuncEnumRetEnum(AEnum: TLargeEnum): TLargeEnum; StdCall;
    function FuncVarEnumRetEnum(var AEnum: TLargeEnum): TLargeEnum; StdCall;
    function FuncEnumEnumRetEnum(AEnum1, AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncVarEnumEnumRetEnum(var AEnum1: TLargeEnum; AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncEnumVarEnumRetEnum(AEnum1: TLargeEnum; var AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncVarEnumVarEnumRetEnum(var AEnum1: TLargeEnum; var AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncConstEnumEnumRetEnum(const AEnum1: TLargeEnum; AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncEnumConstEnumRetEnum(AEnum1: TLargeEnum; const AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncConstEnumConstEnumRetEnum(const AEnum1: TLargeEnum; const AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncOutEnumEnumRetEnum(out AEnum1: TLargeEnum; AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncEnumOutEnumRetEnum(AEnum1: TLargeEnum; out AEnum2: TLargeEnum): TLargeEnum; StdCall;
    function FuncOutEnumOutEnumRetEnum(out AEnum1: TLargeEnum; out AEnum2: TLargeEnum): TLargeEnum; StdCall;
    // ENUMERATION TESTS
    function FuncBooleanRetBoolean(ABoolean: Boolean): Boolean; StdCall;
    function FuncVarBooleanRetBoolean(var ABoolean: Boolean): Boolean; StdCall;
    function FuncBooleanBooleanRetBoolean(ABoolean1, ABoolean2: Boolean): Boolean; StdCall;
    function FuncVarBooleanBooleanRetBoolean(var ABoolean1: Boolean; ABoolean2: Boolean): Boolean; StdCall;
    function FuncBooleanVarBooleanRetBoolean(ABoolean1: Boolean; var ABoolean2: Boolean): Boolean; StdCall;
    function FuncVarBooleanVarBooleanRetBoolean(var ABoolean1: Boolean; var ABoolean2: Boolean): Boolean; StdCall;
    function FuncConstBooleanBooleanRetBoolean(const ABoolean1: Boolean; ABoolean2: Boolean): Boolean; StdCall;
    function FuncBooleanConstBooleanRetBoolean(ABoolean1: Boolean; const ABoolean2: Boolean): Boolean; StdCall;
    function FuncConstBooleanConstBooleanRetBoolean(const ABoolean1: Boolean; const ABoolean2: Boolean): Boolean; StdCall;
    function FuncOutBooleanBooleanRetBoolean(out ABoolean1: Boolean; ABoolean2: Boolean): Boolean; StdCall;
    function FuncBooleanOutBooleanRetBoolean(ABoolean1: Boolean; out ABoolean2: Boolean): Boolean; StdCall;
    function FuncOutBooleanOutBooleanRetBoolean(out ABoolean1: Boolean; out ABoolean2: Boolean): Boolean; StdCall;
    // SETS tests
    function  FuncRetSet: TSmallSet; StdCall;
    procedure ProcSet(ASet: TSmallSet); StdCall;
    procedure ProcConstSet(const ASet: TSmallSet); StdCall;
    procedure ProcOutSet(out ASet: TSmallSet); StdCall;
    procedure ProcVarSet(var ASet: TSmallSet); StdCall;
    // DYNAMIC ARRAY tests
    procedure ProcDynCurrency1Arr(ADynArr: TTestDynCurrency1Arr); StdCall;
    procedure ProcDynInteger2Arr(ADynArr: TTestDynInteger2Arr); StdCall;
    procedure ProcDynString3Arr(ADynArr: TTestDynString3Arr); StdCall;
    procedure ProcDynByte4Arr(ADynArr: TTestDynByte4Arr); StdCall;
    procedure ProcDynVarByte4Arr(var ADynArr: TTestDynByte4Arr); StdCall;
    procedure ProcDynVarCurrency1Arr(Var ADynArr: TTestDynCurrency1Arr); StdCall;
    procedure ProcDynOutInteger2Arr(out ADynArr: TTestDynInteger2Arr); StdCall;
    function  FuncRetDynInteger2Arr: TTestDynInteger2Arr; StdCall;
    function  FuncRetDynCurrency1Arr: TTestDynCurrency1Arr; StdCall;
    procedure ProcDynObject1Arr(ADynArr : TTestDynObj1Arr); StdCall;
    procedure ProcDynObject2Arr(ADynArr : TTestDynObj2Arr); StdCall;
    procedure ProcDynObject3Arr(ADynArr : TTestDynObj3Arr); StdCall;
    procedure ProcOutDynObject1Arr(out ADynArr : TTestDynObj1Arr); StdCall;
    procedure ProcOutDynObject2Arr(out ADynArr : TTestDynObj2Arr); StdCall;
    function  FuncRetDynObject1Arr : TTestDynObj1Arr; StdCall;
    function  FuncRetDynObject2Arr : TTestDynObj2Arr; StdCall;
    procedure ProcDynArrNil(ADynArr: TTestDynCurrency1Arr); stdcall;
    procedure ProcConstDynArrNil(const ADynArr: TTestDynCurrency1Arr); stdcall;
    procedure ProcOutDynArrNil(Out ADynArr: TTestDynCurrency1Arr); stdcall;
    procedure ProcVarDynArrNil(Var ADynArr: TTestDynCurrency1Arr); stdcall;
    function  FuncRetDynArrNil: TTestDynCurrency1Arr; stdcall;

    // CLASS tests
    procedure ProcClass(Var AClass: TSoapTestClass); StdCall;
    procedure ProcClassFieldArr(Var AClass: TSoapFieldArrClass); StdCall;
    function  FuncRetClass: TSoapSimpleTestClass; StdCall;
    function  FuncRetVirtualClass(AWantChild : Boolean): TSoapVirtualClassTestBase; StdCall;
    procedure ProcVarVirtualClass(Var VClass: TSoapVirtualClassTestBase); StdCall;
    procedure ProcVirtualClass(AClass: TSoapVirtualClassTestBase); StdCall;
    procedure ProcReferenceTesting1(ASame : boolean; AObj1, AObj2 : TReferenceTestingObject); stdcall;
    procedure ProcReferenceTesting2(out VObj1, VObj2 : TReferenceTestingObject); stdcall;
    procedure ProcNilClass(AClass: TSoapSimpleTestClass); stdcall;
    procedure ProcConstNilClass(const AClass: TSoapSimpleTestClass); stdcall;
    procedure ProcOutNilClass(Out AClass: TSoapSimpleTestClass); stdcall;
    procedure ProcVarNilClass(Var AClass: TSoapSimpleTestClass); stdcall;
    function  FuncRetNilClass: TSoapSimpleTestClass; stdcall;
    function  FuncRetNilPropClass: TSoapNilPropClass; stdcall;

    // CLASS property/ordering tests

    procedure ProcSimple3StringPropClass(Var AClass: TSoap3StringProperties); stdcall;
    procedure ProcSimple3ShortStringPropClass(Var AClass: TSoap3ShortStringProperties); stdcall;
    procedure ProcSimple3WideStringPropClass(Var AClass: TSoap3WideStringProperties); stdcall;
    procedure ProcSimple3CharPropClass(Var AClass: TSoap3CharProperties); stdcall;
    procedure ProcSimple3WideCharPropClass(Var AClass: TSoap3WideCharProperties); stdcall;
    procedure ProcSimple3BytePropClass(Var AClass: TSoap3ByteProperties); stdcall;
    procedure ProcSimple3ShortIntPropClass(Var AClass: TSoap3ShortIntProperties); stdcall;
    procedure ProcSimple3SmallIntPropClass(Var AClass: TSoap3SmallIntProperties); stdcall;
    procedure ProcSimple3WordPropClass(Var AClass: TSoap3WordProperties); stdcall;
    procedure ProcSimple3IntegerPropClass(Var AClass: TSoap3IntegerProperties); stdcall;
{$IFNDEF DELPHI4}
    procedure ProcSimple3CardinalPropClass(Var AClass: TSoap3CardinalProperties); stdcall;
{$ENDIF}
    procedure ProcSimple3Int64PropClass(Var AClass: TSoap3Int64Properties); stdcall;
    procedure ProcSimple3SinglePropClass(Var AClass: TSoap3SingleProperties); stdcall;
    procedure ProcSimple3DoublePropClass(Var AClass: TSoap3DoubleProperties); stdcall;
    procedure ProcSimple3ExtendedPropClass(Var AClass: TSoap3ExtendedProperties); stdcall;
    procedure ProcSimple3CompPropClass(Var AClass: TSoap3CompProperties); stdcall;
    procedure ProcSimple3CurrPropClass(Var AClass: TSoap3CurrProperties); stdcall;
    procedure ProcSimple3EnumPropClass(Var AClass: TSoap3EnumProperties); stdcall;
    procedure ProcSimple3SetPropClass(Var AClass: TSoap3SetProperties); stdcall;
    procedure ProcSimple3ClassPropClass(Var AClass: TSoap3ClassProperties); stdcall;
    procedure ProcSimple3DynArrPropClass(Var AClass: TSoap3DynArrProperties); stdcall;

    // BINARY Tests
    procedure ProcParamStream(AStream : TStream; ACheckDigit : byte); stdcall;
    function  FuncParamStreamRetStream(AStream : TStream) : TStream; stdcall;
    procedure ProcParamOutStream(AStream : TStream; out VStream : TStream); stdcall;
    procedure ProcParamVarStream(AStream : TStream; var VStream : TStream); stdcall;
    procedure ProcParamPropStream(ABinary : TBinaryTestClass); stdcall;
    function  FuncParamPropStreamRetStream(ABinary : TBinaryTestClass) : TBinaryTestClass; stdcall;
    procedure ProcParamPropOutStream(ABinary : TBinaryTestClass; out VBinary : TBinaryTestClass); stdcall;
    procedure ProcParamPropVarStream(ABinary : TBinaryTestClass; var VBinary : TBinaryTestClass); stdcall;
    procedure ProcParamStreamArray(ALen : integer; ACheckDigits : TTestDynByteArr; AArray : TTestDynStreamArray); stdcall;
    procedure ProcParamOutStreamArray(out VLen : integer; out VCheckDigits : TTestDynByteArr; out VArray : TTestDynStreamArray); stdcall;
    procedure ProcParamVarStreamArray(var VLen : integer; var VCheckDigits : TTestDynByteArr; var VArray : TTestDynStreamArray); stdcall;
    procedure ProcParamHexStream(AStream : THexStream; ACheckDigit : byte); stdcall;
    function  FuncParamHexStreamRetHexStream(AStream : THexStream) : THexStream; stdcall;
    procedure ProcParamOutHexStream(AStream : THexStream; out VStream : THexStream); stdcall;
    procedure ProcParamVarHexStream(AStream : THexStream; var VStream : THexStream); stdcall;
    procedure ProcParamPropHexStream(ABinary : THexBinaryTestClass); stdcall;
    function  FuncParamPropHexStreamRetHexStream(ABinary : THexBinaryTestClass) : THexBinaryTestClass; stdcall;
    procedure ProcParamPropOutHexStream(ABinary : THexBinaryTestClass; out VBinary : THexBinaryTestClass); stdcall;
    procedure ProcParamPropVarHexStream(ABinary : THexBinaryTestClass; var VBinary : THexBinaryTestClass); stdcall;
    procedure ProcParamHexStreamArray(ALen : integer; ACheckDigits : TTestDynByteArr; AArray : TTestDynHexStreamArray); stdcall;
    procedure ProcParamOutHexStreamArray(out VLen : integer; out VCheckDigits : TTestDynByteArr; out VArray : TTestDynHexStreamArray); stdcall;
    procedure ProcParamVarHexStreamArray(var VLen : integer; var VCheckDigits : TTestDynByteArr; var VArray : TTestDynHexStreamArray); stdcall;

    // DATE tests
    procedure ProcParamDateTime(ADateTime : TIdSoapDateTime); stdcall;
    function  FuncParamDateTimeRetDateTime(ADateTime : TIdSoapDateTime) : TIdSoapDateTime; stdcall;
    procedure ProcParamOutDateTime(Out ADateTime : TIdSoapDateTime); stdcall;
    procedure ProcParamVarDateTime(Var ADateTime : TIdSoapDateTime); stdcall;
    procedure ProcParamDate(ADate : TIdSoapDate); stdcall;
    function  FuncParamDateRetDate(ADate : TIdSoapDate) : TIdSoapDate; stdcall;
    procedure ProcParamOutDate(Out ADate : TIdSoapDate); stdcall;
    procedure ProcParamVarDate(Var ADate : TIdSoapDate); stdcall;
    procedure ProcParamTime(ATime : TIdSoapTime); stdcall;
    function  FuncParamTimeRetTime(ATime : TIdSoapTime) : TIdSoapTime; stdcall;
    procedure ProcParamOutTime(Out ATime : TIdSoapTime); stdcall;
    procedure ProcParamVarTime(Var ATime : TIdSoapTime); stdcall;

    // Tests for special classes
    function  FuncSpBoolean(ABool : TIdSoapBoolean): TIdSoapBoolean;  stdcall;
    procedure ProcSpBoolean(var VBool : TIdSoapBoolean);  stdcall;
    function  FuncSpInteger(AInt : TIdSoapInteger): TIdSoapInteger;  stdcall;
    procedure ProcSpInteger(var VInt : TIdSoapInteger);  stdcall;
    function  FuncSpDouble(ADouble : TIdSoapDouble): TIdSoapDouble;  stdcall;
    procedure ProcSpDouble(var VDouble : TIdSoapDouble);  stdcall;
    function  FuncSpString(AStr : TIdSoapString): TIdSoapString;  stdcall;
    procedure ProcSpString(var VStr : TIdSoapString);  stdcall;
    function  FuncQName(AQname : TIdSoapQName): TIdSoapQname;  stdcall;
    procedure ProcQName(var VQName : TIdSoapQName);  stdcall;
    function  FuncRawXML(AXml : TIdSoapRawXML): TIdSoapRawXML;  stdcall;
    procedure ProcRawXML(var VXml : TIdSoapRawXML);  stdcall;
  end;

  { TIdDevTests }

procedure TIdSoapInterfaceTestsInterface.DefineValues(AForceCardinal: Boolean; AOrdType: TOrdType; ATestValues1: Boolean);
begin
  IdSoapInterfaceTestsIntfDefn.DefineValues(AForceCardinal,AOrdType, ATestValues1);
end;

procedure TIdSoapInterfaceTestsInterface.DefineString(AStringType: TTypeKind);
begin
  IdSoapInterfaceTestsIntfDefn.DefineString(AStringType);
end;


procedure TIdSoapInterfaceTestsInterface.DefineInt64(ATestValues1: Boolean);
begin
  IdSoapInterfaceTestsIntfDefn.DefineInt64(ATestValues1);
end;

procedure TIdSoapInterfaceTestsInterface.DefineReal(AFloatType: TFloatType; ATestValues1: Boolean);
begin
  IdSoapInterfaceTestsIntfDefn.DefineReal(AFloatType, ATestValues1);
end;

function SameReal(AReal1, AReal2: Extended): Boolean;
begin
  Result := Abs(AReal1 - AReal2) < 0.001;
end;

procedure TIdSoapInterfaceTestsInterface.TestFullAsciiSet(AString: String);
var
  LInt: Integer;
begin
  if length(AString) <> 256 - 32 then
    Raise Exception.Create('Length = ' + inttostr(length(AString)) + '. It should be 224');
  for LInt:= 32 to 255 do
    if AString[(LInt - 32)+1] <> chr(LInt) then
      Raise Exception.Create('Char ' + IntToStr(LInt) + ' failed to get through');
end;

function TIdSoapInterfaceTestsInterface.FuncBoolBoolRetBool(ABool1, ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
end;

function TIdSoapInterfaceTestsInterface.FuncBoolRetBool(ABool: Boolean): Boolean;
begin
  Result := not ABool;
end;

function TIdSoapInterfaceTestsInterface.FuncBoolConstBoolRetBool(ABool1: Boolean; const ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
end;

function TIdSoapInterfaceTestsInterface.FuncBoolVarBoolRetBool(ABool1: Boolean; var ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
  ABool2 := not ABool2;
end;

function TIdSoapInterfaceTestsInterface.FuncBoolOutBoolRetBool(ABool1: Boolean; out ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
  ABool2 := not ABool2;
end;

function TIdSoapInterfaceTestsInterface.FuncRetBoolToggle: Boolean;
begin
  gToggle := not gToggle;
  Result := gToggle;
end;

function TIdSoapInterfaceTestsInterface.FuncConstBoolBoolRetBool(const ABool1: Boolean; ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
end;

function TIdSoapInterfaceTestsInterface.FuncVarBoolBoolRetBool(var ABool1: Boolean; ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
  ABool1 := not ABool1;
end;

function TIdSoapInterfaceTestsInterface.FuncOutBoolBoolRetBool(out ABool1: Boolean; ABool2: Boolean): Boolean;
begin
  Check(not ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := not ABool1 and not ABool2;
  ABool1 := not ABool1;
end;

function TIdSoapInterfaceTestsInterface.FuncVarBoolRetBool(var ABool: Boolean): Boolean;
begin
  ABool := not ABool;
  Result := gToggle;
end;

function TIdSoapInterfaceTestsInterface.FuncVarBoolVarBoolRetBool(var ABool1, ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
  ABool1 := not ABool1;
  ABool2 := not ABool2;
end;

function TIdSoapInterfaceTestsInterface.FuncConstBoolConstBoolRetBool(const ABool1, ABool2: Boolean): Boolean;
begin
  Check(ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := ABool1 and not ABool2;
end;

procedure TIdSoapInterfaceTestsInterface.ProcCall;
begin
end;

function TIdSoapInterfaceTestsInterface.FuncOutBoolOutBoolRetBool(out ABool1, ABool2: Boolean): Boolean;
begin
  Check(not ABool1, 'Bool1 failed');
  Check(not ABool2, 'Bool2 failed');
  Result := not ABool1 and not ABool2;
  ABool1 := not ABool1;
  ABool2 := not ABool2;
end;

procedure TIdSoapInterfaceTestsInterface.TestPassed;
var
  LMessage: String;
begin
  if FMessage = '' then
    exit;
  LMessage := FMessage;
  FMessage := '';
  raise EServerFailed.Create(LMessage);
end;

procedure TIdSoapInterfaceTestsInterface.TestServerFailureReporter;
begin
  raise EServerFailed.Create('Testing server error reporting exception');
end;

procedure TIdSoapInterfaceTestsInterface.Check(ACondition: Boolean; AMessage: String);
begin
  if not ACondition then
    raise EServerFailed.Create('Server Error: ' + AMessage);
end;

// BYTE tests

function TIdSoapInterfaceTestsInterface.FuncRetByteToggle: Byte;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := $55;
    end
  else
    begin
    Result := $AA;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncByteRetByte(AByte: Byte): Byte;
begin
  Check(AByte = 12, 'AByte has wrong value');
  Result := 22;
end;

function TIdSoapInterfaceTestsInterface.FuncVarByteRetByte(var AByte: Byte): Byte;
begin
  Check(AByte = 12, 'AByte has wrong value');
  AByte := 21;
  Result := 22;
end;

function TIdSoapInterfaceTestsInterface.FuncByteByteRetByte(AByte1, AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarByteByteRetByte(var AByte1: Byte; AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  AByte1 := 56;
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncByteVarByteRetByte(AByte1: Byte; var AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  AByte2 := 78;
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarByteVarByteRetByte(var AByte1: Byte; var AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  AByte1 := 56;
  AByte2 := 78;
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstByteByteRetByte(const AByte1: Byte; AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncByteConstByteRetByte(AByte1: Byte; const AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstByteConstByteRetByte(const AByte1: Byte; const AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutByteByteRetByte(out AByte1: Byte; AByte2: Byte): Byte;
begin
  Check(AByte1 = 0, 'Byte1 has wrong value');
  Check(AByte2 = 34, 'Byte2 has wrong value');
  AByte1 := 56;
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncByteOutByteRetByte(AByte1: Byte; out AByte2: Byte): Byte;
begin
  Check(AByte1 = 12, 'Byte1 has wrong value');
  Check(AByte2 = 0, 'Byte2 has wrong value');
  AByte2 := 78;
  Result := 90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutByteOutByteRetByte(out AByte1: Byte; out AByte2: Byte): Byte;
begin
  Check(AByte1 = 0, 'Byte1 has wrong value');
  Check(AByte2 = 0, 'Byte2 has wrong value');
  AByte1 := 56;
  AByte2 := 78;
  Result := 90;
end;

// CHAR tests

function TIdSoapInterfaceTestsInterface.FuncRetCharToggle: Char;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := #$55;
    end
  else
    begin
    Result := #$AA;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncCharRetChar(AChar: Char): Char;
begin
  Check(AChar = #42, 'AChar invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCharRetChar(var AChar: Char): Char;
begin
  Check(AChar = #42, 'AChar invalid');
  AChar := #56;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncCharCharRetChar(AChar1, AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'Char1 invalid');
  Check(AChar2 = #34, 'Char2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCharCharRetChar(var AChar1: Char; AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'AChar1 invalid');
  Check(AChar2 = #34, 'AChar2 invalid');
  AChar1 := #56;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncCharVarCharRetChar(AChar1: Char; var AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'AChar1 invalid');
  Check(AChar2 = #34, 'AChar2 invalid');
  AChar2 := #78;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCharVarCharRetChar(var AChar1: Char; var AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'AChar1 invalid');
  Check(AChar2 = #34, 'AChar2 invalid');
  AChar1 := #56;
  AChar2 := #78;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCharCharRetChar(const AChar1: Char; AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'AChar1 invalid');
  Check(AChar2 = #34, 'AChar2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncCharConstCharRetChar(AChar1: Char; const AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'AChar1 invalid');
  Check(AChar2 = #34, 'AChar2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCharConstCharRetChar(const AChar1: Char; const AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'AChar1 invalid');
  Check(AChar2 = #34, 'AChar2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCharCharRetChar(out AChar1: Char; AChar2: Char): Char;
begin
  Check(AChar1 = #0, 'AChar1 invalid');
  Check(AChar2 = #34, 'AChar2 invalid');
  AChar1 := #56;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncCharOutCharRetChar(AChar1: Char; out AChar2: Char): Char;
begin
  Check(AChar1 = #42, 'AChar1 invalid');
  Check(AChar2 = #0, 'AChar2 invalid');
  AChar2 := #78;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCharOutCharRetChar(out AChar1: Char; out AChar2: Char): Char;
begin
  Check(AChar1 = #0, 'AChar1 invalid');
  Check(AChar2 = #0, 'AChar2 invalid');
  AChar1 := #56;
  AChar2 := #78;
  Result := #90;
end;

// WIDECHAR tests

function TIdSoapInterfaceTestsInterface.FuncRetWideCharToggle: WideChar;
var
  LWide1: Word;
  LWide2: Word;
begin
  LWide1 := 5432;
  LWide2 := 9876;
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := Widechar(LWide1);
    end
  else
    begin
    Result := Widechar(LWide2);
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncWideCharRetWideChar(AWideChar: WideChar): WideChar;
begin
  Check(AWideChar = #42, 'AWideChar invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWideCharRetWideChar(var AWideChar: WideChar): WideChar;
begin
  Check(AWideChar = #42, 'AWideChar invalid');
  AWideChar := #56;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncWideCharWideCharRetWideChar(AWideChar1, AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'WideChar1 invalid');
  Check(AWideChar2 = #34, 'WideChar2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWideCharWideCharRetWideChar(var AWideChar1: WideChar; AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'AWideChar1 invalid');
  Check(AWideChar2 = #34, 'AWideChar2 invalid');
  AWideChar1 := #56;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncWideCharVarWideCharRetWideChar(AWideChar1: WideChar; var AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'AWideChar1 invalid');
  Check(AWideChar2 = #34, 'AWideChar2 invalid');
  AWideChar2 := #78;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWideCharVarWideCharRetWideChar(var AWideChar1: WideChar; var AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'AWideChar1 invalid');
  Check(AWideChar2 = #34, 'AWideChar2 invalid');
  AWideChar1 := #56;
  AWideChar2 := #78;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstWideCharWideCharRetWideChar(const AWideChar1: WideChar; AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'AWideChar1 invalid');
  Check(AWideChar2 = #34, 'AWideChar2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncWideCharConstWideCharRetWideChar(AWideChar1: WideChar; const AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'AWideChar1 invalid');
  Check(AWideChar2 = #34, 'AWideChar2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstWideCharConstWideCharRetWideChar(const AWideChar1: WideChar; const AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'AWideChar1 invalid');
  Check(AWideChar2 = #34, 'AWideChar2 invalid');
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutWideCharWideCharRetWideChar(out AWideChar1: WideChar; AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #0, 'AWideChar1 invalid');
  Check(AWideChar2 = #34, 'AWideChar2 invalid');
  AWideChar1 := #56;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncWideCharOutWideCharRetWideChar(AWideChar1: WideChar; out AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #42, 'AWideChar1 invalid');
  Check(AWideChar2 = #0, 'AWideChar2 invalid');
  AWideChar2 := #78;
  Result := #90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutWideCharOutWideCharRetWideChar(out AWideChar1: WideChar; out AWideChar2: WideChar): WideChar;
begin
  Check(AWideChar1 = #0, 'AWideChar1 invalid');
  Check(AWideChar2 = #0, 'AWideChar2 invalid');
  AWideChar1 := #56;
  AWideChar2 := #78;
  Result := #90;
end;

// SHORTINT tests

function TIdSoapInterfaceTestsInterface.FuncRetShortIntToggle: ShortInt;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := g1;
    end
  else
    begin
    Result := g2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncShortIntRetShortInt(AShortInt: ShortInt): ShortInt;
begin
  Check(AShortInt = g1, 'AShortint invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarShortIntRetShortInt(var AShortInt: ShortInt): ShortInt;
begin
  Check(AShortint = g1, 'AShortint invalid');
  AShortInt := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortIntShortIntRetShortInt(AShortInt1, AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarShortIntShortIntRetShortInt(var AShortInt1: ShortInt; AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  AShortint1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortIntVarShortIntRetShortInt(AShortInt1: ShortInt; var AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  AShortint2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarShortIntVarShortIntRetShortInt(var AShortInt1: ShortInt; var AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  AShortint1 := g3;
  AShortint2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstShortIntShortIntRetShortInt(const AShortInt1: ShortInt; AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortIntConstShortIntRetShortInt(AShortInt1: ShortInt; const AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstShortIntConstShortIntRetShortInt(const AShortInt1: ShortInt; const AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutShortIntShortIntRetShortInt(out AShortInt1: ShortInt; AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = 0, 'Shortint1 invalid');
  Check(AShortint2 = g2, 'Shortint2 invalid');
  AShortint1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortIntOutShortIntRetShortInt(AShortInt1: ShortInt; out AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = g1, 'Shortint1 invalid');
  Check(AShortint2 = 0, 'Shortint2 invalid');
  AShortint2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutShortIntOutShortIntRetShortInt(out AShortInt1: ShortInt; out AShortInt2: ShortInt): ShortInt;
begin
  Check(AShortint1 = 0, 'Shortint1 invalid');
  Check(AShortint2 = 0, 'Shortint2 invalid');
  AShortint1 := g3;
  AShortint2 := g4;
  Result := g5;
end;

// WORD TESTS
function TIdSoapInterfaceTestsInterface.FuncRetWordToggle: Word;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := g1;
    end
  else
    begin
    Result := g2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncWordRetWord(AWord: Word): Word;
begin
  Check(AWord = g1, 'AWord invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWordRetWord(var AWord: Word): Word;
begin
  Check(AWord = g1, 'AWord invalid');
  AWord := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncWordWordRetWord(AWord1, AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWordWordRetWord(var AWord1: Word; AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  AWord1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncWordVarWordRetWord(AWord1: Word; var AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  AWord2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWordVarWordRetWord(var AWord1: Word; var AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  AWord1 := g3;
  AWord2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstWordWordRetWord(const AWord1: Word; AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncWordConstWordRetWord(AWord1: Word; const AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstWordConstWordRetWord(const AWord1: Word; const AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutWordWordRetWord(out AWord1: Word; AWord2: Word): Word;
begin
  Check(AWord1 = 0, 'Word1 invalid');
  Check(AWord2 = g2, 'Word2 invalid');
  AWord1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncWordOutWordRetWord(AWord1: Word; out AWord2: Word): Word;
begin
  Check(AWord1 = g1, 'Word1 invalid');
  Check(AWord2 = 0, 'Word2 invalid');
  AWord2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutWordOutWordRetWord(out AWord1: Word; out AWord2: Word): Word;
begin
  Check(AWord1 = 0, 'Word1 invalid');
  Check(AWord2 = 0, 'Word2 invalid');
  AWord1 := g3;
  AWord2 := g4;
  Result := g5;
end;

// SMALLINT TESTS

function TIdSoapInterfaceTestsInterface.FuncRetSmallintToggle: Smallint;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := g1;
    end
  else
    begin
    Result := g2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncSmallintRetSmallint(ASmallint: Smallint): Smallint;
begin
  Check(ASmallint = g1, 'ASmallint invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarSmallintRetSmallint(var ASmallint: Smallint): Smallint;
begin
  Check(ASmallint = g1, 'ASmallint invalid');
  ASmallint := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncSmallintSmallintRetSmallint(ASmallint1, ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarSmallintSmallintRetSmallint(var ASmallint1: Smallint; ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  ASmallint1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncSmallintVarSmallintRetSmallint(ASmallint1: Smallint; var ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  ASmallint2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarSmallintVarSmallintRetSmallint(var ASmallint1: Smallint; var ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  ASmallint1 := g3;
  ASmallint2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstSmallintSmallintRetSmallint(const ASmallint1: Smallint; ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncSmallintConstSmallintRetSmallint(ASmallint1: Smallint; const ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstSmallintConstSmallintRetSmallint(const ASmallint1: Smallint; const ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutSmallintSmallintRetSmallint(out ASmallint1: Smallint; ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = 0, 'Smallint1 invalid');
  Check(ASmallint2 = g2, 'Smallint2 invalid');
  ASmallint1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncSmallintOutSmallintRetSmallint(ASmallint1: Smallint; out ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = g1, 'Smallint1 invalid');
  Check(ASmallint2 = 0, 'Smallint2 invalid');
  ASmallint2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutSmallintOutSmallintRetSmallint(out ASmallint1: Smallint; out ASmallint2: Smallint): Smallint;
begin
  Check(ASmallint1 = 0, 'Smallint1 invalid');
  Check(ASmallint2 = 0, 'Smallint2 invalid');
  ASmallint1 := g3;
  ASmallint2 := g4;
  Result := g5;
end;

// CARDINAL TESTS

function TIdSoapInterfaceTestsInterface.FuncRetCardinalToggle: Cardinal; StdCall;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := g1;
    end
  else
    begin
    Result := g2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncCardinalRetCardinal(ACardinal: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal = g1, 'ACardinal invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCardinalRetCardinal(var ACardinal: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal = g1, 'ACardinal invalid');
  ACardinal := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncCardinalCardinalRetCardinal(ACardinal1, ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCardinalCardinalRetCardinal(var ACardinal1: Cardinal; ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  ACardinal1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncCardinalVarCardinalRetCardinal(ACardinal1: Cardinal; var ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  ACardinal2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCardinalVarCardinalRetCardinal(var ACardinal1: Cardinal; var ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  ACardinal1 := g3;
  ACardinal2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCardinalCardinalRetCardinal(const ACardinal1: Cardinal; ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncCardinalConstCardinalRetCardinal(ACardinal1: Cardinal; const ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCardinalConstCardinalRetCardinal(const ACardinal1: Cardinal; const ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCardinalCardinalRetCardinal(out ACardinal1: Cardinal; ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = 0, 'Cardinal1 invalid');
  Check(ACardinal2 = g2, 'Cardinal2 invalid');
  ACardinal1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncCardinalOutCardinalRetCardinal(ACardinal1: Cardinal; out ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = g1, 'Cardinal1 invalid');
  Check(ACardinal2 = 0, 'Cardinal2 invalid');
  ACardinal2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCardinalOutCardinalRetCardinal(out ACardinal1: Cardinal; out ACardinal2: Cardinal): Cardinal; StdCall;
begin
  Check(ACardinal1 = 0, 'Cardinal1 invalid');
  Check(ACardinal2 = 0, 'Cardinal2 invalid');
  ACardinal1 := g3;
  ACardinal2 := g4;
  Result := g5;
end;

// INTEGER TESTS

function TIdSoapInterfaceTestsInterface.FuncRetIntegerToggle: Integer;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := g1;
    end
  else
    begin
    Result := g2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncIntegerRetInteger(AInteger: Integer): Integer;
begin
  Check(AInteger = g1, 'AInteger invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarIntegerRetInteger(var AInteger: Integer): Integer;
begin
  Check(AInteger = g1, 'AInteger invalid');
  AInteger := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncIntegerIntegerRetInteger(AInteger1, AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarIntegerIntegerRetInteger(var AInteger1: Integer; AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  AInteger1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncIntegerVarIntegerRetInteger(AInteger1: Integer; var AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  AInteger2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarIntegerVarIntegerRetInteger(var AInteger1: Integer; var AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  AInteger1 := g3;
  AInteger2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstIntegerIntegerRetInteger(const AInteger1: Integer; AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncIntegerConstIntegerRetInteger(AInteger1: Integer; const AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstIntegerConstIntegerRetInteger(const AInteger1: Integer; const AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutIntegerIntegerRetInteger(out AInteger1: Integer; AInteger2: Integer): Integer;
begin
  Check(AInteger1 = 0, 'Integer1 invalid');
  Check(AInteger2 = g2, 'Integer2 invalid');
  AInteger1 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncIntegerOutIntegerRetInteger(AInteger1: Integer; out AInteger2: Integer): Integer;
begin
  Check(AInteger1 = g1, 'Integer1 invalid');
  Check(AInteger2 = 0, 'Integer2 invalid');
  AInteger2 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutIntegerOutIntegerRetInteger(out AInteger1: Integer; out AInteger2: Integer): Integer;
begin
  Check(AInteger1 = 0, 'Integer1 invalid');
  Check(AInteger2 = 0, 'Integer2 invalid');
  AInteger1 := g3;
  AInteger2 := g4;
  Result := g5;
end;

// INT64 TESTS

function TIdSoapInterfaceTestsInterface.FuncRetInt64Toggle: Int64;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := g1;
    end
  else
    begin
    Result := g2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncInt64RetInt64(AInt64: Int64): Int64;
begin
  Check(AInt64 = g1, 'AInt64 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarInt64RetInt64(var AInt64: Int64): Int64;
begin
  Check(AInt64 = g1, 'AInt64 invalid');
  AInt64 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncInt64Int64RetInt64(AInt641, AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarInt64Int64RetInt64(var AInt641: Int64; AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  AInt641 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncInt64VarInt64RetInt64(AInt641: Int64; var AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  AInt642 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarInt64VarInt64RetInt64(var AInt641: Int64; var AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  AInt641 := g3;
  AInt642 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstInt64Int64RetInt64(const AInt641: Int64; AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncInt64ConstInt64RetInt64(AInt641: Int64; const AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstInt64ConstInt64RetInt64(const AInt641: Int64; const AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutInt64Int64RetInt64(out AInt641: Int64; AInt642: Int64): Int64;
begin
  Check(AInt641 = 0, 'Int641 invalid');
  Check(AInt642 = g2, 'Int642 invalid');
  AInt641 := g3;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncInt64OutInt64RetInt64(AInt641: Int64; out AInt642: Int64): Int64;
begin
  Check(AInt641 = g1, 'Int641 invalid');
  Check(AInt642 = 0, 'Int642 invalid');
  AInt642 := g4;
  Result := g5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutInt64OutInt64RetInt64(out AInt641: Int64; out AInt642: Int64): Int64;
begin
  Check(AInt641 = 0, 'Int641 invalid');
  Check(AInt642 = 0, 'Int642 invalid');
  AInt641 := g3;
  AInt642 := g4;
  Result := g5;
end;

// SINGLE TESTS

function TIdSoapInterfaceTestsInterface.FuncRetSingleToggle: Single;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gR1;
    end
  else
    begin
    Result := gR2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncSingleRetSingle(ASingle: Single): Single;
begin
  ASingle := ASingle;
  Check(SameReal(ASingle, gR1), 'ASingle invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarSingleRetSingle(var ASingle: Single): Single;
begin
  Check(SameReal(ASingle, gR1), 'ASingle invalid');
  ASingle := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncSingleSingleRetSingle(ASingle1, ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarSingleSingleRetSingle(var ASingle1: Single; ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  ASingle1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncSingleVarSingleRetSingle(ASingle1: Single; var ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  ASingle2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarSingleVarSingleRetSingle(var ASingle1: Single; var ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  ASingle1 := gR3;
  ASingle2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstSingleSingleRetSingle(const ASingle1: Single; ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncSingleConstSingleRetSingle(ASingle1: Single; const ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstSingleConstSingleRetSingle(const ASingle1: Single; const ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutSingleSingleRetSingle(out ASingle1: Single; ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, 0), 'Single1 invalid');
  Check(SameReal(ASingle2, gR2), 'Single2 invalid');
  ASingle1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncSingleOutSingleRetSingle(ASingle1: Single; out ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, gR1), 'Single1 invalid');
  Check(SameReal(ASingle2, 0), 'Single2 invalid');
  ASingle2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutSingleOutSingleRetSingle(out ASingle1: Single; out ASingle2: Single): Single;
begin
  Check(SameReal(ASingle1, 0), 'Single1 invalid');
  Check(SameReal(ASingle2, 0), 'Single2 invalid');
  ASingle1 := gR3;
  ASingle2 := gR4;
  Result := gR5;
end;

// DOUBLE TESTS

function TIdSoapInterfaceTestsInterface.FuncRetDoubleToggle: Double;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gR1;
    end
  else
    begin
    Result := gR2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncDoubleRetDouble(ADouble: Double): Double;
begin
  ADouble := ADouble;
  Check(SameReal(ADouble, gR1), 'ADouble invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarDoubleRetDouble(var ADouble: Double): Double;
begin
  Check(SameReal(ADouble, gR1), 'ADouble invalid');
  ADouble := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncDoubleDoubleRetDouble(ADouble1, ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarDoubleDoubleRetDouble(var ADouble1: Double; ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  ADouble1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncDoubleVarDoubleRetDouble(ADouble1: Double; var ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  ADouble2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarDoubleVarDoubleRetDouble(var ADouble1: Double; var ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  ADouble1 := gR3;
  ADouble2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstDoubleDoubleRetDouble(const ADouble1: Double; ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncDoubleConstDoubleRetDouble(ADouble1: Double; const ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstDoubleConstDoubleRetDouble(const ADouble1: Double; const ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutDoubleDoubleRetDouble(out ADouble1: Double; ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, 0), 'Double1 invalid');
  Check(SameReal(ADouble2, gR2), 'Double2 invalid');
  ADouble1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncDoubleOutDoubleRetDouble(ADouble1: Double; out ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, gR1), 'Double1 invalid');
  Check(SameReal(ADouble2, 0), 'Double2 invalid');
  ADouble2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutDoubleOutDoubleRetDouble(out ADouble1: Double; out ADouble2: Double): Double;
begin
  Check(SameReal(ADouble1, 0), 'Double1 invalid');
  Check(SameReal(ADouble2, 0), 'Double2 invalid');
  ADouble1 := gR3;
  ADouble2 := gR4;
  Result := gR5;
end;

// COMP TESTS

function TIdSoapInterfaceTestsInterface.FuncRetCompToggle: Comp;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gR1;
    end
  else
    begin
    Result := gR2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncCompRetComp(AComp: Comp): Comp;
begin
  AComp := AComp;
  Check(SameReal(AComp, gR1), 'AComp invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCompRetComp(var AComp: Comp): Comp;
begin
  Check(SameReal(AComp, gR1), 'AComp invalid');
  AComp := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCompCompRetComp(AComp1, AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCompCompRetComp(var AComp1: Comp; AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  AComp1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCompVarCompRetComp(AComp1: Comp; var AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  AComp2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCompVarCompRetComp(var AComp1: Comp; var AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  AComp1 := gR3;
  AComp2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCompCompRetComp(const AComp1: Comp; AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCompConstCompRetComp(AComp1: Comp; const AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCompConstCompRetComp(const AComp1: Comp; const AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCompCompRetComp(out AComp1: Comp; AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, 0), 'Comp1 invalid');
  Check(SameReal(AComp2, gR2), 'Comp2 invalid');
  AComp1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCompOutCompRetComp(AComp1: Comp; out AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, gR1), 'Comp1 invalid');
  Check(SameReal(AComp2, 0), 'Comp2 invalid');
  AComp2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCompOutCompRetComp(out AComp1: Comp; out AComp2: Comp): Comp;
begin
  Check(SameReal(AComp1, 0), 'Comp1 invalid');
  Check(SameReal(AComp2, 0), 'Comp2 invalid');
  AComp1 := gR3;
  AComp2 := gR4;
  Result := gR5;
end;

// EXTENDED TESTS

function TIdSoapInterfaceTestsInterface.FuncRetExtendedToggle: Extended;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gR1;
    end
  else
    begin
    Result := gR2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncExtendedRetExtended(AExtended: Extended): Extended;
begin
  AExtended := AExtended;
  Check(SameReal(AExtended, gR1), 'AExtended invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarExtendedRetExtended(var AExtended: Extended): Extended;
begin
  Check(SameReal(AExtended, gR1), 'AExtended invalid');
  AExtended := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncExtendedExtendedRetExtended(AExtended1, AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarExtendedExtendedRetExtended(var AExtended1: Extended; AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  AExtended1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncExtendedVarExtendedRetExtended(AExtended1: Extended; var AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  AExtended2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarExtendedVarExtendedRetExtended(var AExtended1: Extended; var AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  AExtended1 := gR3;
  AExtended2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstExtendedExtendedRetExtended(const AExtended1: Extended; AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncExtendedConstExtendedRetExtended(AExtended1: Extended; const AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstExtendedConstExtendedRetExtended(const AExtended1: Extended; const AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutExtendedExtendedRetExtended(out AExtended1: Extended; AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, 0), 'Extended1 invalid');
  Check(SameReal(AExtended2, gR2), 'Extended2 invalid');
  AExtended1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncExtendedOutExtendedRetExtended(AExtended1: Extended; out AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, gR1), 'Extended1 invalid');
  Check(SameReal(AExtended2, 0), 'Extended2 invalid');
  AExtended2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutExtendedOutExtendedRetExtended(out AExtended1: Extended; out AExtended2: Extended): Extended;
begin
  Check(SameReal(AExtended1, 0), 'Extended1 invalid');
  Check(SameReal(AExtended2, 0), 'Extended2 invalid');
  AExtended1 := gR3;
  AExtended2 := gR4;
  Result := gR5;
end;

// CURRENCY TESTS

function TIdSoapInterfaceTestsInterface.FuncRetCurrencyToggle: Currency;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gR1;
    end
  else
    begin
    Result := gR2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncCurrencyRetCurrency(ACurrency: Currency): Currency;
begin
  ACurrency := ACurrency;
  Check(SameReal(ACurrency, gR1), 'ACurrency invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCurrencyRetCurrency(var ACurrency: Currency): Currency;
begin
  Check(SameReal(ACurrency, gR1), 'ACurrency invalid');
  ACurrency := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCurrencyCurrencyRetCurrency(ACurrency1, ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCurrencyCurrencyRetCurrency(var ACurrency1: Currency; ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  ACurrency1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCurrencyVarCurrencyRetCurrency(ACurrency1: Currency; var ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  ACurrency2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarCurrencyVarCurrencyRetCurrency(var ACurrency1: Currency; var ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  ACurrency1 := gR3;
  ACurrency2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCurrencyCurrencyRetCurrency(const ACurrency1: Currency; ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCurrencyConstCurrencyRetCurrency(ACurrency1: Currency; const ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstCurrencyConstCurrencyRetCurrency(const ACurrency1: Currency; const ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCurrencyCurrencyRetCurrency(out ACurrency1: Currency; ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, 0), 'Currency1 invalid');
  Check(SameReal(ACurrency2, gR2), 'Currency2 invalid');
  ACurrency1 := gR3;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncCurrencyOutCurrencyRetCurrency(ACurrency1: Currency; out ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, gR1), 'Currency1 invalid');
  Check(SameReal(ACurrency2, 0), 'Currency2 invalid');
  ACurrency2 := gR4;
  Result := gR5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutCurrencyOutCurrencyRetCurrency(out ACurrency1: Currency; out ACurrency2: Currency): Currency;
begin
  Check(SameReal(ACurrency1, 0), 'Currency1 invalid');
  Check(SameReal(ACurrency2, 0), 'Currency2 invalid');
  ACurrency1 := gR3;
  ACurrency2 := gR4;
  Result := gR5;
end;

// SHORTSTRING TESTS

function TIdSoapInterfaceTestsInterface.FuncRetShortStringToggle: ShortString;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gS1;
    end
  else
    begin
    Result := gS2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncShortStringRetShortString(AShortString: ShortString): ShortString;
begin
  AShortString := AShortString;
  Check(AShortString = gS1, 'AShortString invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarShortStringRetShortString(var AShortString: ShortString): ShortString;
begin
  Check(AShortString = gS1, 'AShortString invalid');
  AShortString := gS3;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortStringShortStringRetShortString(AShortString1, AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarShortStringShortStringRetShortString(var AShortString1: ShortString; AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  AShortString1 := gS3;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortStringVarShortStringRetShortString(AShortString1: ShortString; var AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  AShortString2 := gS4;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarShortStringVarShortStringRetShortString(var AShortString1: ShortString; var AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  AShortString1 := gS3;
  AShortString2 := gS4;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstShortStringShortStringRetShortString(const AShortString1: ShortString; AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortStringConstShortStringRetShortString(AShortString1: ShortString; const AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstShortStringConstShortStringRetShortString(const AShortString1: ShortString; const AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutShortStringShortStringRetShortString(out AShortString1: ShortString; AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = '', 'ShortString1 invalid');
  Check(AShortString2 = gS2, 'ShortString2 invalid');
  AShortString1 := gS3;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncShortStringOutShortStringRetShortString(AShortString1: ShortString; out AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = gS1, 'ShortString1 invalid');
  Check(AShortString2 = '', 'ShortString2 invalid');
  AShortString2 := gS4;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutShortStringOutShortStringRetShortString(out AShortString1: ShortString; out AShortString2: ShortString): ShortString;
begin
  Check(AShortString1 = '', 'ShortString1 invalid');
  Check(AShortString2 = '', 'ShortString2 invalid');
  AShortString1 := gS3;
  AShortString2 := gS4;
  Result := gS5;
end;

// LONGSTRING TESTS

function TIdSoapInterfaceTestsInterface.FuncRetStringToggle: String;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gS1;
    end
  else
    begin
    Result := gS2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncStringRetString(AString: String): String;
begin
  AString := AString;
  Check(AString = gS1, 'AString invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarStringRetString(var AString: String): String;
begin
  Check(AString = gS1, 'AString invalid');
  AString := gS3;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncStringStringRetString(AString1, AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarStringStringRetString(var AString1: String; AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  AString1 := gS3;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncStringVarStringRetString(AString1: String; var AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  AString2 := gS4;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarStringVarStringRetString(var AString1: String; var AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  AString1 := gS3;
  AString2 := gS4;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstStringStringRetString(const AString1: String; AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncStringConstStringRetString(AString1: String; const AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstStringConstStringRetString(const AString1: String; const AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutStringStringRetString(out AString1: String; AString2: String): String;
begin
  Check(AString1 = '', 'String1 invalid');
  Check(AString2 = gS2, 'String2 invalid');
  AString1 := gS3;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncStringOutStringRetString(AString1: String; out AString2: String): String;
begin
  Check(AString1 = gS1, 'String1 invalid');
  Check(AString2 = '', 'String2 invalid');
  AString2 := gS4;
  Result := gS5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutStringOutStringRetString(out AString1: String; out AString2: String): String;
begin
  Check(AString1 = '', 'String1 invalid');
  Check(AString2 = '', 'String2 invalid');
  AString1 := gS3;
  AString2 := gS4;
  Result := gS5;
end;

// WIDESTRING TESTS

function TIdSoapInterfaceTestsInterface.FuncRetWideStringToggle: WideString;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := gWS1;
    end
  else
    begin
    Result := gWS2;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncWideStringRetWideString(AWideString: WideString): WideString;
begin
  AWideString := AWideString;
  Check(AWideString = gWS1, 'AWideString invalid');
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWideStringRetWideString(var AWideString: WideString): WideString;
begin
  Check(AWideString = gWS1, 'AWideString invalid');
  AWideString := gWS3;
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncWideStringWideStringRetWideString(AWideString1, AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWideStringWideStringRetWideString(var AWideString1: WideString; AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  AWideString1 := gWS3;
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncWideStringVarWideStringRetWideString(AWideString1: WideString; var AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  AWideString2 := gWS4;
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncVarWideStringVarWideStringRetWideString(var AWideString1: WideString; var AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  AWideString1 := gWS3;
  AWideString2 := gWS4;
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstWideStringWideStringRetWideString(const AWideString1: WideString; AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncWideStringConstWideStringRetWideString(AWideString1: WideString; const AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncConstWideStringConstWideStringRetWideString(const AWideString1: WideString; const AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutWideStringWideStringRetWideString(out AWideString1: WideString; AWideString2: WideString): WideString;
begin
  Check(AWideString1 = '', 'WideString1 invalid');
  Check(AWideString2 = gWS2, 'WideString2 invalid');
  AWideString1 := gWS3;
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncWideStringOutWideStringRetWideString(AWideString1: WideString; out AWideString2: WideString): WideString;
begin
  Check(AWideString1 = gWS1, 'WideString1 invalid');
  Check(AWideString2 = '', 'WideString2 invalid');
  AWideString2 := gWS4;
  Result := gWS5;
end;

function TIdSoapInterfaceTestsInterface.FuncOutWideStringOutWideStringRetWideString(out AWideString1: WideString; out AWideString2: WideString): WideString;
begin
  Check(AWideString1 = '', 'WideString1 invalid');
  Check(AWideString2 = '', 'WideString2 invalid');
  AWideString1 := gWS3;
  AWideString2 := gWS4;
  Result := gWS5;
end;

// ENUMERATION TESTS

function TIdSoapInterfaceTestsInterface.FuncRetEnumToggle: TLargeEnum;
begin
  gToggle := not gToggle;
  if gToggle then
    begin
    Result := le12;
    end
  else
    begin
    Result := le34;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncEnumRetEnum(AEnum: TLargeEnum): TLargeEnum;  // checks for large enum
begin
  AEnum := AEnum;
  Check(AEnum = le258, 'Large enumeration failed');
  Result := le283;
end;

function TIdSoapInterfaceTestsInterface.FuncVarEnumRetEnum(var AEnum: TLargeEnum): TLargeEnum;
begin
  Check(AEnum = le12, 'AEnum invalid');
  AEnum := le56;
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncEnumEnumRetEnum(AEnum1, AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarEnumEnumRetEnum(var AEnum1: TLargeEnum; AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  AEnum1 := le56;
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncEnumVarEnumRetEnum(AEnum1: TLargeEnum; var AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  AEnum2 := le78;
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncVarEnumVarEnumRetEnum(var AEnum1: TLargeEnum; var AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  AEnum1 := le56;
  AEnum2 := le78;
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstEnumEnumRetEnum(const AEnum1: TLargeEnum; AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncEnumConstEnumRetEnum(AEnum1: TLargeEnum; const AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncConstEnumConstEnumRetEnum(const AEnum1: TLargeEnum; const AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutEnumEnumRetEnum(out AEnum1: TLargeEnum; AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le0, 'Enum1 invalid');
  Check(AEnum2 = le34, 'Enum2 invalid');
  AEnum1 := le56;
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncEnumOutEnumRetEnum(AEnum1: TLargeEnum; out AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le12, 'Enum1 invalid');
  Check(AEnum2 = le0, 'Enum2 invalid');
  AEnum2 := le78;
  Result := le90;
end;

function TIdSoapInterfaceTestsInterface.FuncOutEnumOutEnumRetEnum(out AEnum1: TLargeEnum; out AEnum2: TLargeEnum): TLargeEnum;
begin
  Check(AEnum1 = le0, 'Enum1 invalid');
  Check(AEnum2 = le0, 'Enum2 invalid');
  AEnum1 := le56;
  AEnum2 := le78;
  Result := le90;
end;

// BOOLEAN TESTS

function TIdSoapInterfaceTestsInterface.FuncBooleanRetBoolean(ABoolean: Boolean): Boolean;  // checks for large Boolean
begin
  Check(ABoolean = true, 'Boolean failed');
  Result := False;
end;

function TIdSoapInterfaceTestsInterface.FuncVarBooleanRetBoolean(var ABoolean: Boolean): Boolean;
begin
  Check(ABoolean = False, 'ABoolean invalid');
  ABoolean := True;
  Result := False;
end;

function TIdSoapInterfaceTestsInterface.FuncBooleanBooleanRetBoolean(ABoolean1, ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = False, 'Boolean1 invalid');
  Check(ABoolean2 = True, 'Boolean2 invalid');
  Result := True;
end;

function TIdSoapInterfaceTestsInterface.FuncVarBooleanBooleanRetBoolean(var ABoolean1: Boolean; ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = true, 'Boolean1 invalid');
  Check(ABoolean2 = false, 'Boolean2 invalid');
  ABoolean1 := false;
  Result := false;
end;

function TIdSoapInterfaceTestsInterface.FuncBooleanVarBooleanRetBoolean(ABoolean1: Boolean; var ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = true, 'Boolean1 invalid');
  Check(ABoolean2 = false, 'Boolean2 invalid');
  ABoolean2 := true;
  Result := true;
end;

function TIdSoapInterfaceTestsInterface.FuncVarBooleanVarBooleanRetBoolean(var ABoolean1: Boolean; var ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = True, 'Boolean1 invalid');
  Check(ABoolean2 = false, 'Boolean2 invalid');
  ABoolean1 := false;
  ABoolean2 := true;
  Result := false;
end;

function TIdSoapInterfaceTestsInterface.FuncConstBooleanBooleanRetBoolean(const ABoolean1: Boolean; ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = false, 'Boolean1 invalid');
  Check(ABoolean2 = true, 'Boolean2 invalid');
  Result := true;
end;

function TIdSoapInterfaceTestsInterface.FuncBooleanConstBooleanRetBoolean(ABoolean1: Boolean; const ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = true, 'Boolean1 invalid');
  Check(ABoolean2 = false, 'Boolean2 invalid');
  Result := true;
end;

function TIdSoapInterfaceTestsInterface.FuncConstBooleanConstBooleanRetBoolean(const ABoolean1: Boolean; const ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = true, 'Boolean1 invalid');
  Check(ABoolean2 = true, 'Boolean2 invalid');
  Result := true;
end;

function TIdSoapInterfaceTestsInterface.FuncOutBooleanBooleanRetBoolean(out ABoolean1: Boolean; ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = false, 'Boolean1 invalid');
  Check(ABoolean2 = false, 'Boolean2 invalid');
  ABoolean1 := true;
  Result := false;
end;

function TIdSoapInterfaceTestsInterface.FuncBooleanOutBooleanRetBoolean(ABoolean1: Boolean; out ABoolean2: Boolean): Boolean;
begin
  Check(ABoolean1 = true, 'Boolean1 invalid');
  ABoolean2 := false;
  Result := true;
end;

function TIdSoapInterfaceTestsInterface.FuncOutBooleanOutBooleanRetBoolean(out ABoolean1: Boolean; out ABoolean2: Boolean): Boolean;
begin
  ABoolean1 := true;
  ABoolean2 := false;
  Result := false;
end;

// SETS tests

function TIdSoapInterfaceTestsInterface.FuncRetSet: TSmallSet;
begin
  result := [seOne,seThree,seFive,seTen];
end;

procedure TIdSoapInterfaceTestsInterface.ProcSet(ASet: TSmallSet);
begin
  Check(ASet = [seOne,seThree,seFive,seTen],'Set incorrect');
end;

procedure TIdSoapInterfaceTestsInterface.ProcConstSet(const ASet: TSmallSet);
begin
  Check(ASet = [seOne,seThree,seFive,seTen],'Set incorrect');
end;

procedure TIdSoapInterfaceTestsInterface.ProcOutSet(out ASet: TSmallSet);
begin
  ASet := [seOne,seThree,seFive,seNine,seTen]
end;

procedure TIdSoapInterfaceTestsInterface.ProcVarSet(var ASet: TSmallSet);
begin
  Check(ASet = [seOne,seThree,seFive,seNine,seTen],'Set incorrect');
  ASet := ASet + [seNine];
end;

// DYNAMIC ARRAY tests

procedure TIdSoapInterfaceTestsInterface.ProcDynCurrency1Arr(ADynArr: TTestDynCurrency1Arr);
begin
  Check(length(ADynArr) = 4,'Length currency of array incorrect');
  Check(ADynArr[0] = 123.456,'Currency array at [0] invalid');
  Check(ADynArr[1] = 234.567,'Currency array at [0] invalid');
  Check(ADynArr[2] = 345.678,'Currency array at [0] invalid');
  Check(ADynArr[3] = 456.789,'Currency array at [0] invalid');
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynInteger2Arr(ADynArr: TTestDynInteger2Arr);
begin
  // verify array was passed over correctly
  Check(Length(ADynArr) = 3,'1st dimension is incorrect');  // no data beyond ADynArr[2]
  Check(Length(ADynArr[0]) = 3,'length[0] incorrect');
  Check(Length(ADynArr[1]) = 0,'length[1] incorrect');
  Check(Length(ADynArr[2]) = 5,'length[2] incorrect');
  Check(ADynArr[0,0] = 100,'[0,0] incorrect');
  Check(ADynArr[0,1] = 101,'[0,1] incorrect');
  Check(ADynArr[0,2] = 102,'[0,2] incorrect');
  Check(ADynArr[2,0] = 120,'[2,0] incorrect');
  Check(ADynArr[2,1] = 121,'[2,1] incorrect');
  Check(ADynArr[2,2] = 122,'[2,2] incorrect');
  Check(ADynArr[2,3] = 123,'[2,3] incorrect');
  Check(ADynArr[2,4] = 124,'[2,4] incorrect');
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynString3Arr(ADynArr: TTestDynString3Arr);
begin
  Check(ADynArr[2,4,5] = 'Hello World','String array at [2,4,5] invalid');
  Check(ADynArr[2,4,7] = 'I''m the seven''th','String array at [2,4,7] invalid');
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynByte4Arr(ADynArr: TTestDynByte4Arr);
begin
  Check(ADynArr[3,3,9,12] = 123,'Byte array at [3,3,9,12] invalid');
  Check(ADynArr[7,0,0,10] = 234,'Byte array at [7,0,0,10] invalid');
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynVarByte4Arr(var ADynArr: TTestDynByte4Arr);
begin
  SetLength(ADynArr,0);
  SetLength(ADynArr,8);
  SetLength(ADynArr[7],9);
  SetLength(ADynArr[7,0],1);
  SetLength(ADynArr[7,0,0],18);
  ADynArr[7,0,0,10] := 214;
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynVarCurrency1Arr(Var ADynArr: TTestDynCurrency1Arr);
begin
  Check(ADynArr[0]=987.654,'Svr [0] incorrect');
  Check(ADynArr[1]=876.543,'Svr [1] incorrect');
  Check(ADynArr[2]=765.432,'Svr [2] incorrect');
  Check(ADynArr[3]=0.0    ,'Svr [3] incorrect');
  Check(ADynArr[4]=0.0    ,'Svr [4] incorrect');
  SetLength(ADynArr,7);
  ADynArr[2] := 123.456;
  ADynArr[3] := 234.567;
  ADynArr[4] := 345.678;
  ADynArr[6] := 456.789;
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynOutInteger2Arr(out ADynArr: TTestDynInteger2Arr);
begin
  Check(Length(ADynArr)=0,'Array should have 0 length at this point');
  SetLength(ADynArr,3);
  SetLength(ADynArr[1],3);
  ADynArr[1,1] := 43210;
end;

function  TIdSoapInterfaceTestsInterface.FuncRetDynInteger2Arr: TTestDynInteger2Arr;
begin
  Check(Length(Result)=0,'Result array should have length=0');
  SetLength(Result,5);
  SetLength(Result[3],10);
  Result[3,5] := 1122;
end;

function TIdSoapInterfaceTestsInterface.FuncRetDynCurrency1Arr: TTestDynCurrency1Arr;
begin
  Check(Length(Result)=0,'Result array should have length=0');
  SetLength(Result,5);
  Result[3] := 1122;
end;

function TIdSoapInterfaceTestsInterface.FuncRetDynObject1Arr: TTestDynObj1Arr;
var
  i: integer;
begin
  SetLength(Result, 3);
  for i := Low(Result) to High(Result) do
    begin
    Result[i] := TSoapSimpleTestClass.create;
    Result[i].FieldString := 'Return Value '+inttostr(i);
    end;
  GServerObject := Result[1];
  if GTestServerKeepAlive then
    begin
    Result[1].ServerLeaveAlive := true;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncRetDynObject2Arr: TTestDynObj2Arr;
var
  i: integer;
begin
  SetLength(Result, 6);
  SetLength(Result[1],2);
  for i := Low(Result[1]) to High(Result[1]) do
    begin
    Result[1][i] := TSoapSimpleTestClass.create;
    Result[1][i].FieldString := 'Return Value 1,'+inttostr(i);
    end;
  SetLength(Result[4],3);
  for i := Low(Result[4]) to High(Result[4]) do
    begin
    Result[4][i] := TSoapSimpleTestClass.create;
    Result[4][i].FieldString := 'Return Value 4,'+inttostr(i);
    end;
  GServerObject := Result[4][0];
  if GTestServerKeepAlive then
    begin
    Result[4][0].ServerLeaveAlive := true;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynObject1Arr(ADynArr: TTestDynObj1Arr);
var
  i : integer;
begin
  check(Length(ADynArr) = 3, 'Length should be 3');
  for i := Low(ADynArr) to High(ADynArr) do
    check(ADynArr[i].FieldString = 'Value '+inttostr(i), 'Value '+inttostr(i)+' is wrong');
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynObject2Arr(ADynArr: TTestDynObj2Arr);
var
  i,j : integer;
begin
  check(Length(ADynArr) = 4, 'Length should be 4');
  Check(Length(ADynArr[2]) = 2,'Length Arr[2] should be 2');
  Check(Length(ADynArr[3]) = 3,'Length Arr[3] should be 3');
  for i := 2 to 3 do
    begin
    for j:=0 to length(ADynArr[i])-1 do
      begin
      check(ADynArr[i][j].FieldString = 'Value '+inttostr(i)+','+inttostr(j), 'Value '+inttostr(i)+inttostr(j)+' is wrong');
      end;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynObject3Arr(ADynArr: TTestDynObj3Arr);
var
  i,j,k : integer;
begin
  check(Length(ADynArr) = 3, 'Length should be 3');
  Check(Length(ADynArr[0]) = 2,'Length Arr[2] should be 2');
  Check(Length(ADynArr[2]) = 1,'Length Arr[3] should be 1');
  Check(Length(ADynArr[0][0]) = 2,'Length Arr[0][0] should be 2');
  Check(Length(ADynArr[0][1]) = 2,'Length Arr[0][0] should be 2');
  Check(Length(ADynArr[2][0]) = 3,'Length Arr[2][0] should be 3');
  for i := 0 to Length(ADynArr)-1 do
    begin
    for j:=0 to length(ADynArr[i])-1 do
      begin
      for k:=0 to length(ADynArr[i][j])-1 do
        begin
        check(ADynArr[i][j][k].FieldString = 'Value '+inttostr(i)+','+inttostr(j)+','+inttostr(k), 'Value '+inttostr(i)+','+inttostr(j)+','+inttostr(k)+' is wrong');
        end;
      end;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcOutDynObject1Arr(out ADynArr: TTestDynObj1Arr);
var
  i : integer;
begin
  SetLength(ADynArr, 3);
  for i := Low(ADynArr) to High(ADynArr) do
    begin
    ADynArr[i] := TSoapSimpleTestClass.create;
    ADynArr[i].FieldString := 'Return Value '+inttostr(i);
    end;
  GServerObject := ADynArr[1];
  if GTestServerKeepAlive then
    begin
    ADynArr[1].ServerLeaveAlive := true;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcOutDynObject2Arr(out ADynArr: TTestDynObj2Arr);
var
  i : integer;
begin
  SetLength(ADynArr, 4);
  SetLength(ADynArr[1],3);
  for i := Low(ADynArr[1]) to High(ADynArr[1]) do
    begin
    ADynArr[1][i] := TSoapSimpleTestClass.create;
    ADynArr[1][i].FieldString := 'Return Value 1,'+inttostr(i);
    end;
  SetLength(ADynArr[3],5);
  for i := Low(ADynArr[3]) to High(ADynArr[3]) do
    begin
    ADynArr[3][i] := TSoapSimpleTestClass.create;
    ADynArr[3][i].FieldString := 'Return Value 3,'+inttostr(i);
    end;
  GServerObject := ADynArr[1][1];
  if GTestServerKeepAlive then
    begin
    ADynArr[1][1].ServerLeaveAlive := true;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcDynArrNil(ADynArr: TTestDynCurrency1Arr);
begin
  check(Length(ADynArr)=0,'Array should have 0 length');
end;

procedure TIdSoapInterfaceTestsInterface.ProcConstDynArrNil(const ADynArr: TTestDynCurrency1Arr);
begin
  check(Length(ADynArr)=0,'Array should have 0 length');
end;

procedure TIdSoapInterfaceTestsInterface.ProcOutDynArrNil(Out ADynArr: TTestDynCurrency1Arr);
begin
  check(Length(ADynArr)=0,'Array should have 0 length');
end;

procedure TIdSoapInterfaceTestsInterface.ProcVarDynArrNil(Var ADynArr: TTestDynCurrency1Arr);
begin
  check(Length(ADynArr)=0,'Array should have 0 length');
end;

function TIdSoapInterfaceTestsInterface.FuncRetDynArrNil: TTestDynCurrency1Arr;
begin
  check(Length(result)=0,'Array should have 0 length');
end;

// CLASS tests

function SingleTrunc3(LValue: Single): Single;
begin
  result := int(LValue * 1000.0) / 1000.0;
end;

function DoubleTrunc3(LValue: Double): Double;
begin
  result := int(LValue * 1000.0) / 1000.0;
end;

function ExtendedTrunc3(LValue: Extended): Extended;
begin
  result := int(LValue * 1000.0) / 1000.0;
end;

function DoubleEqual(ADouble1,ADouble2: Double): Boolean;
begin
  result := ADouble1 = ADouble2;
end;

procedure TIdSoapInterfaceTestsInterface.ProcClass(Var AClass: TSoapTestClass);
var
  fa: TTestDynCurrency1Arr;
begin
//  AClass := TSoapTestClass.Create;

  Check(AClass.FieldInteger=123,'FieldInteger failed on server RX');
  Check(AClass.StaticInteger=234,'StaticInteger failed on server RX');
  Check(AClass.VirtualInteger=345,'VirtualInteger failed on server RX');
  Check(AClass.FieldAnsiString='Field AnsiString','FieldAnsiString failed on server RX');
  Check(AClass.StaticAnsiString='Static AnsiString','StaticAnsiString failed on server RX');
  Check(AClass.VirtualAnsiString='Virtual AnsiString','VirtualAnsiString failed on server RX');
  Check(AClass.FieldShortString='Field ShortString','FieldShortString failed on server RX');
  Check(AClass.StaticShortString='Static ShortString','StaticShortString failed on server RX');
  Check(AClass.VirtualShortString='Virtual ShortString','VirtualShortString failed on server RX');
  Check(AClass.FieldWideString='Field WideString','FieldWideString failed on server RX');
  Check(AClass.StaticWideSTring='Static WideString','StaticWideSTring failed on server RX');
  Check(AClass.VirtualWideString='Virtual WideString','VirtualWideString failed on server RX');
  Check(AClass.FieldInt64=1234567,'FieldInt64 failed on server RX');
  Check(AClass.StaticInt64=2345678,'StaticInt64 failed on server RX');
  Check(AClass.VirtualInt64=3456789,'VirtualInt64 failed on server RX');
  Check(AClass.FieldChar='F','FieldChar failed on server RX');
  Check(AClass.StaticChar='S','StaticChar failed on server RX');
  Check(AClass.VirtualChar='V','VirtualChar failed on server RX');
  Check(AClass.FieldWideChar='f','FieldWideChar failed on server RX');
  Check(AClass.StaticWideChar='s','StaticWideChar failed on server RX');
  Check(AClass.VirtualWideChar='v','VirtualWideChar failed on server RX');
  // tests like this are due to floating point rounoff errors in XML encoding
  Check(AClass.FieldSingle=SingleTrunc3(123.456),'FieldSingle failed on server RX');
  Check(AClass.StaticSingle=SingleTrunc3(234.567),'StaticSingle failed on server RX');
  Check(AClass.VirtualSingle=SingleTrunc3(345.678),'VirtualSingle failed on server RX');
  Check(DoubleEqual(AClass.FieldDouble,1123.456),'FieldDouble failed on server RX');
  Check(AClass.StaticDouble=DoubleTrunc3(1234.567),'StaticDouble failed on server RX');
  Check(AClass.VirtualDouble=DoubleTrunc3(1345.678),'VirtualDouble failed on server RX');
  Check(AClass.FieldExtended=ExtendedTrunc3(2123.456),'FieldExtended failed on server RX');
  Check(AClass.StaticExtended=ExtendedTrunc3(2234.567),'StaticExtended failed on server RX');
  Check(AClass.VirtualExtended=ExtendedTrunc3(2345.678),'VirtualExtended failed on server RX');
  Check(AClass.FieldComp=3123,'FieldComp failed on server RX');
  // it was rounded up on the client
  Check(AClass.StaticComp=3235,'StaticComp failed on server RX');
  // it was rounded up on the client
  Check(AClass.VirtualComp=3346,'VirtualComp failed on server RX');
  Check(AClass.FieldCurrency=4123.456,'FieldCurrency failed on server RX');
  Check(AClass.StaticCurrency=4234.567,'StaticCurrency failed on server RX');
  Check(AClass.VirtualCurrency=4345.678,'VirtualCurrency failed on server RX');

  Check(Length(AClass.FieldArray)=3,'AClass.FieldArray wrong length on server RX');
  Check(AClass.FieldArray[0]=1,'AClass.FieldArray[0] has wrong value on server RX');
  Check(AClass.FieldArray[1]=2,'AClass.FieldArray[1] has wrong value on server RX');
  Check(AClass.FieldArray[2]=3,'AClass.FieldArray[2] has wrong value on server RX');

  Check(Length(AClass.StaticArray)=3,'AClass.StaticArray has wrong length on server RX');
  Check(AClass.StaticArray[0]=2,'AClass.StaticArray[0] has wrong value on server RX');
  Check(AClass.StaticArray[1]=3,'AClass.StaticArray[1] has wrong value on server RX');
  Check(AClass.StaticArray[2]=4,'AClass.StaticArray[2] has wrong value on server RX');

  Check(Length(AClass.VirtualArray)=3,'AClass.VirtualArray has wrong length on server RX');
  Check(AClass.VirtualArray[0]=3,'AClass.VirtualArray[0] has wrong value on server RX');
  Check(AClass.VirtualArray[1]=4,'AClass.VirtualArray[1] has wrong value on server RX');
  Check(AClass.VirtualArray[2]=5,'AClass.VirtualArray[2] has wrong value on server RX');

  Check(AClass.FieldEnum=seOne,'AClass.FieldEnum has wrong value on server RX');
  Check(AClass.StaticEnum=seTwo,'AClass.StaticEnum has wrong value on server RX');
  Check(AClass.VirtualEnum=seThree,'AClass.VirtualEnum has wrong value on server RX');
  Check(AClass.FieldSet=[seOne,seTwo,seThree],'AClass.FieldSet has wrong value on server RX');
  Check(AClass.StaticSet=[seTwo,seThree,seFour],'AClass.StaticSet has wrong value on server RX');
  Check(AClass.VirtualSet=[seThree,seFour,seFive],'AClass.VirtualSet has wrong value on server RX');

  AClass.StaticExtended := 321;
  Check(AClass.FieldSet=[seOne,seTwo,seThree],'SET invalid');
  Check(AClass.StaticSet=[seTwo,seThree,seFour],'SET invalid');
  Check(AClass.VirtualSet=[seThree,seFour,seFive],'SET invalid');
  AClass.FieldSet := AClass.FieldSet + [seSeven];
  AClass.StaticSet := AClass.StaticSet + [seEight];
  AClass.VirtualSet := AClass.VirtualSet + [seNine];
  GServerObject := AClass;
  if GTestServerKeepAlive then
    begin
    AClass.ServerLeaveAlive := true;
    end;
/////check this... 0 length messes it up too
  SetLength(fa,1);
  AClass.FieldArray := copy(fa);
end;

procedure TIdSoapInterfaceTestsInterface.ProcClassFieldArr(Var AClass: TSoapFieldArrClass);
begin
  Check(AClass.FieldArray[0] = 123.456,'Server RX failed class field property of array');
  Check(AClass.FieldArray[1] = 234.567,'Server RX failed class field property of array');
  Check(AClass.FieldArray[2] = 345.678,'Server RX failed class field property of array');
  AClass.FieldArray[0] := 654.321;
  AClass.FieldArray[1] := 765.432;
  AClass.FieldArray[2] := 876.543;
end;

function TIdSoapInterfaceTestsInterface.FuncRetClass: TSoapSimpleTestClass;
begin
  Result := TSoapSimpleTestClass.Create;
  Result.FieldSTring := 'Result FieldString';
  GServerObject := Result;
  if GTestServerKeepAlive then
    begin
    Result.ServerLeaveAlive := true;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncRetVirtualClass(AWantChild : Boolean): TSoapVirtualClassTestBase;
begin
  if AWantChild then
    begin
    result := TSoapVirtualClassTestChild.Create;
    (result as TSoapVirtualClassTestChild).AInt := 3;
    end
  else
    begin
    result := TSoapVirtualClassTestBase.Create;
    end;
  result.AByte := 4;
end;

procedure TIdSoapInterfaceTestsInterface.ProcVarVirtualClass(Var VClass: TSoapVirtualClassTestBase);
var
  LIsChild : boolean;
begin
  LIsChild := VClass is TSoapVirtualClassTestChild;
  check(VClass.AByte = 7, 'wrong value');
  if LIsChild then
    begin
    check((VClass as TSoapVirtualClassTestChild).AInt = 345, 'wrong value');
    end;
  FreeAndNil(VClass);
  // return other type
  if LIsChild then
    begin
    VClass := TSoapVirtualClassTestBase.create;
    VClass.AByte := 9;
    end
  else
    begin
    VClass := TSoapVirtualClassTestChild.create;
    VClass.AByte := 13;
    (VClass as TSoapVirtualClassTestChild).AInt := -5;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcVirtualClass(AClass: TSoapVirtualClassTestBase);
begin
  if AClass.AByte = 4 then
    begin
    Check(AClass is TSoapVirtualClassTestChild,'Wrong class type');
    end
  else
    begin
    Check(not (AClass is TSoapVirtualClassTestChild),'Wrong class type');
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncParamStreamRetStream(AStream: TStream): TStream;
begin
  if AStream = nil then
    begin
    result := nil;
    end
  else
    begin
    result := TIdMemoryStream.create;
    result.CopyFrom(AStream, 0);
    result.position := 0;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamOutStream(AStream: TStream; out VStream: TStream);
begin
  if AStream = nil then
    begin
    VStream := nil;
    end
  else
    begin
    VStream := TIdMemoryStream.create;
    VStream.CopyFrom(AStream, 0);
    VStream.position := 0;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamStream(AStream: TStream; ACheckDigit: byte);
begin
  if ACheckDigit = 0 then
    begin
    if assigned(AStream) then
      raise exception.create('Stream should be nil');
    end
  else
    begin
    if not GetStreamCheckDigit(AStream) = ACheckDigit then
      raise exception.create('Stream Check Digit failed');
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamVarStream(AStream: TStream; var VStream: TStream);
begin
  if AStream = nil then
    begin
    VStream := nil;
    end
  else
    begin
    VStream := TIdMemoryStream.create;
    VStream.CopyFrom(AStream, 0);
    VStream.position := 0;
    end;
end;

function TIdSoapInterfaceTestsInterface.FuncParamPropStreamRetStream(ABinary: TBinaryTestClass): TBinaryTestClass;
begin
  result := TBinaryTestClass.create;
  result.Stream := TIdMemoryStream.create;
  result.Stream.CopyFrom(ABinary.Stream, 0);
  result.Stream.Position := 0;
  result.Size := ABinary.Size;
  result.CheckDigit := ABinary.CheckDigit;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamPropOutStream(ABinary: TBinaryTestClass; out VBinary: TBinaryTestClass);
begin
  VBinary := TBinaryTestClass.create;
  VBinary.Stream := TIdMemoryStream.create;
  VBinary.Stream.CopyFrom(ABinary.Stream, 0);
  VBinary.Stream.Position := 0;
  VBinary.Size := ABinary.Size;
  VBinary.CheckDigit := ABinary.CheckDigit;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamPropStream(ABinary: TBinaryTestClass);
begin
  if ABinary.Stream.Size <> ABinary.Size then
    raise exception.create('Stream size failed');
  if GetStreamCheckDigit(ABinary.Stream) <> ABinary.CheckDigit then
    raise exception.create('Stream Check Digit failed');
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamPropVarStream(ABinary: TBinaryTestClass; var VBinary: TBinaryTestClass);
begin
  if VBinary <> nil then
    raise exception.create('Binary should be nil');
  VBinary := TBinaryTestClass.create;
  VBinary.Stream := TIdMemoryStream.create;
  VBinary.Stream.CopyFrom(ABinary.Stream, 0);
  VBinary.Size := ABinary.Size;
  VBinary.CheckDigit := ABinary.CheckDigit;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamStreamArray(ALen : integer; ACheckDigits: TTestDynByteArr; AArray: TTestDynStreamArray);
var
  i : integer;
begin
  if Length(ACheckDigits) <> ALen then
    raise exception.create('CheckDigit Array Length wrong ('+IntToStr(Length(ACheckDigits))+'/'+IntToStr(ALen)+')');
  if Length(AArray) <> ALen then
    raise exception.create('Stream Array Length wrong ('+IntToStr(Length(AArray))+'/'+IntToStr(ALen)+')');
  for i := Low(ACheckDigits) to High(ACheckDigits) do
    begin
    if ACheckDigits[i] = 0 then
      begin
      if assigned(AArray[i]) then
        raise exception.create('Stream should be nil');
      end
    else
      begin
        case i of
         1:check(AArray[i].Size = 0, 'length of stream 1 wrong');
         2:check(AArray[i].Size = 100, 'length of stream 2 wrong');
         3:check(AArray[i].Size = 10000, 'length of stream 3 wrong');
        end;
      if not GetStreamCheckDigit(AArray[i]) = ACheckDigits[i] then
        raise exception.create('Stream Check Digit failed');
      end;
   end;
end;

function BuildTestStream(AFillCount:integer):TStream;
begin
  result := TIdMemoryStream.create;
  FillTestingStream(Result, AFillCount);
  result.Position := 0;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamOutStreamArray(out VLen: integer; out VCheckDigits: TTestDynByteArr; out VArray: TTestDynStreamArray);
begin
  VLen := 4;
  SetLength(VCheckDigits, VLen);
  SetLength(VArray, VLen);
  VArray[0] := nil;
  VCheckDigits[0] := 0;
  VArray[1] := BuildTestStream(0);
  VCheckDigits[1] := GetStreamCheckDigit(VArray[1]);
  VArray[1].Position := 0;
  VArray[2] := BuildTestStream(200);
  VCheckDigits[2] := GetStreamCheckDigit(VArray[2]);
  VArray[2].Position := 0;
  VArray[3] := BuildTestStream(20000);
  VCheckDigits[3] := GetStreamCheckDigit(VArray[3]);
  VArray[3].Position := 0;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamVarStreamArray(var VLen: integer; var VCheckDigits: TTestDynByteArr; var VArray: TTestDynStreamArray);
var
  i: integer;
begin
  ProcParamStreamArray(VLen, VCheckDigits, VArray);
  for i:=0 to length(VArray)-1 do
    begin
    FreeAndNil(VArray[i]);
    end;
  ProcParamOutStreamArray(VLen, VCheckDigits, VArray);
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamHexStream(AStream : THexStream; ACheckDigit : byte); stdcall;
begin
  if ACheckDigit = 0 then
    begin
    if assigned(AStream) then
      raise exception.create('Stream should be nil');
    end
  else
    begin
    if not GetStreamCheckDigit(AStream) = ACheckDigit then
      raise exception.create('Stream Check Digit failed');
    end;
end;

function  TIdSoapInterfaceTestsInterface.FuncParamHexStreamRetHexStream(AStream : THexStream) : THexStream; stdcall;
begin
  if AStream = nil then
    begin
    result := nil;
    end
  else
    begin
    result := THexStream.create;
    result.CopyFrom(AStream, 0);
    result.position := 0;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamOutHexStream(AStream : THexStream; out VStream : THexStream); stdcall;
begin
  if AStream = nil then
    begin
    VStream := nil;
    end
  else
    begin
    VStream := THexStream.create;
    VStream.CopyFrom(AStream, 0);
    VStream.position := 0;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamVarHexStream(AStream : THexStream; var VStream : THexStream); stdcall;
begin
  if AStream = nil then
    begin
    VStream := nil;
    end
  else
    begin
    VStream := THexStream.create;
    VStream.CopyFrom(AStream, 0);
    VStream.position := 0;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamPropHexStream(ABinary : THexBinaryTestClass); stdcall;
begin
  if ABinary.HexStream.Size <> ABinary.Size then
    raise exception.create('Stream size failed');
  if GetStreamCheckDigit(ABinary.HexStream) <> ABinary.CheckDigit then
    raise exception.create('Stream Check Digit failed');
end;

function  TIdSoapInterfaceTestsInterface.FuncParamPropHexStreamRetHexStream(ABinary : THexBinaryTestClass) : THexBinaryTestClass; stdcall;
begin
  result := THexBinaryTestClass.create;
  result.HexStream := THexStream.create;
  result.HexStream.CopyFrom(ABinary.HexStream, 0);
  result.HexStream.Position := 0;
  result.Size := ABinary.Size;
  result.CheckDigit := ABinary.CheckDigit;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamPropOutHexStream(ABinary : THexBinaryTestClass; out VBinary : THexBinaryTestClass); stdcall;
begin
  VBinary := THexBinaryTestClass.create;
  VBinary.HexStream := THexStream.create;
  VBinary.HexStream.CopyFrom(ABinary.HexStream, 0);
  VBinary.HexStream.Position := 0;
  VBinary.Size := ABinary.Size;
  VBinary.CheckDigit := ABinary.CheckDigit;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamPropVarHexStream(ABinary : THexBinaryTestClass; var VBinary : THexBinaryTestClass); stdcall;
begin
  if VBinary <> nil then
    raise exception.create('Binary should be nil');
  VBinary := THexBinaryTestClass.create;
  VBinary.HexStream := THexStream.create;
  VBinary.HexStream.CopyFrom(ABinary.HexStream, 0);
  VBinary.Size := ABinary.Size;
  VBinary.CheckDigit := ABinary.CheckDigit;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamHexStreamArray(ALen : integer; ACheckDigits : TTestDynByteArr; AArray : TTestDynHexStreamArray); stdcall;
var
  i : integer;
begin
  if Length(ACheckDigits) <> ALen then
    raise exception.create('CheckDigit Array Length wrong ('+IntToStr(Length(ACheckDigits))+'/'+IntToStr(ALen)+')');
  if Length(AArray) <> ALen then
    raise exception.create('Stream Array Length wrong ('+IntToStr(Length(AArray))+'/'+IntToStr(ALen)+')');
  for i := Low(ACheckDigits) to High(ACheckDigits) do
    begin
    if ACheckDigits[i] = 0 then
      begin
      if assigned(AArray[i]) then
        raise exception.create('Stream should be nil');
      end
    else
      begin
        case i of
         1:check(AArray[i].Size = 0, 'length of stream 1 wrong');
         2:check(AArray[i].Size = 100, 'length of stream 2 wrong');
         3:check(AArray[i].Size = 10000, 'length of stream 3 wrong');
        end;
      if not GetStreamCheckDigit(AArray[i]) = ACheckDigits[i] then
        raise exception.create('Stream Check Digit failed');
      end;
   end;
end;

function BuildTestHexStream(AFillCount:integer):THexStream;
begin
  result := THexStream.create;
  FillTestingStream(Result, AFillCount);
  result.Position := 0;
end;


procedure TIdSoapInterfaceTestsInterface.ProcParamOutHexStreamArray(out VLen : integer; out VCheckDigits : TTestDynByteArr; out VArray : TTestDynHexStreamArray); stdcall;
begin
  VLen := 4;
  SetLength(VCheckDigits, VLen);
  SetLength(VArray, VLen);
  VArray[0] := nil;
  VCheckDigits[0] := 0;
  VArray[1] := BuildTestHexStream(0);
  VCheckDigits[1] := GetStreamCheckDigit(VArray[1]);
  VArray[1].Position := 0;
  VArray[2] := BuildTestHexStream(200);
  VCheckDigits[2] := GetStreamCheckDigit(VArray[2]);
  VArray[2].Position := 0;
  VArray[3] := BuildTestHexStream(20000);
  VCheckDigits[3] := GetStreamCheckDigit(VArray[3]);
  VArray[3].Position := 0;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamVarHexStreamArray(var VLen : integer; var VCheckDigits : TTestDynByteArr; var VArray : TTestDynHexStreamArray); stdcall;
var
  i: integer;
begin
  ProcParamHexStreamArray(VLen, VCheckDigits, VArray);
  for i:=0 to length(VArray)-1 do
    begin
    FreeAndNil(VArray[i]);
    end;
  ProcParamOutHexStreamArray(VLen, VCheckDigits, VArray);
end;


// DATE tests

procedure TIdSoapInterfaceTestsInterface.ProcParamDateTime(ADateTime : TIdSoapDateTime);
begin
  Check(ADateTime.Year = 1234,'Year failed');
  Check(ADateTime.Month = 5,'Month failed');
  Check(ADateTime.Day = 30,'Day failed');
  Check(ADateTime.Hour = 12,'Hour failed');
  Check(ADateTime.Minute = 18,'Minute failed');
  Check(ADateTime.Second = 29,'Second failed');
  Check(ADateTime.Nanosecond = 987654321,'Nanoseconds failed');
end;

function  TIdSoapInterfaceTestsInterface.FuncParamDateTimeRetDateTime(ADateTime : TIdSoapDateTime) : TIdSoapDateTime;
begin
  Check(ADateTime.Year = 1234,'Year failed');
  Check(ADateTime.Month = 5,'Month failed');
  Check(ADateTime.Day = 30,'Day failed');
  Check(ADateTime.Hour = 12,'Hour failed');
  Check(ADateTime.Minute = 18,'Minute failed');
  Check(ADateTime.Second = 29,'Second failed');
  Check(ADateTime.Nanosecond = 987654321,'Nanoseconds failed');
  Result := TIdSoapDateTime.Create;
  Result.Year := 4321;
  Result.Month := 7;
  Result.Day := 20;
  Result.Hour := 9;
  Result.Minute := 28;
  Result.Second := 39;
  Result.Nanosecond := 987654322;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamOutDateTime(Out ADateTime : TIdSoapDateTime);
begin
  ADateTime := TIdSoapDateTime.Create;
  ADateTime.Year := 4321;
  ADateTime.Month := 7;
  ADateTime.Day := 20;
  ADateTime.Hour := 9;
  ADateTime.Minute := 28;
  ADateTime.Second := 39;
  ADateTime.Nanosecond := 987654322;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamVarDateTime(Var ADateTime : TIdSoapDateTime);
begin
  Check(ADateTime.Year = 1234,'Year failed');
  Check(ADateTime.Month = 5,'Month failed');
  Check(ADateTime.Day = 30,'Day failed');
  Check(ADateTime.Hour = 12,'Hour failed');
  Check(ADateTime.Minute = 18,'Minute failed');
  Check(ADateTime.Second = 29,'Second failed');
  Check(ADateTime.Nanosecond = 987654321,'Nanoseconds failed');
  ADateTime.Year := 4321;
  ADateTime.Month := 7;
  ADateTime.Day := 20;
  ADateTime.Hour := 9;
  ADateTime.Minute := 28;
  ADateTime.Second := 39;
  ADateTime.Nanosecond := 987654322;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamDate(ADate : TIdSoapDate);
begin
  Check(ADate.Year = 1234,'Year failed');
  Check(ADate.Month = 5,'Month failed');
  Check(ADate.Day = 30,'Day failed');
end;

function TIdSoapInterfaceTestsInterface.FuncParamDateRetDate(ADate : TIdSoapDate) : TIdSoapDate;
begin
  Check(ADate.Year = 1234,'Year failed');
  Check(ADate.Month = 5,'Month failed');
  Check(ADate.Day = 30,'Day failed');
  Result := TIdSoapDate.Create;
  Result.Year := 4321;
  Result.Month := 7;
  Result.Day := 20;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamOutDate(Out ADate : TIdSoapDate);
begin
  ADate := TIdSoapDate.Create;
  ADate.Year := 4321;
  ADate.Month := 7;
  ADate.Day := 20;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamVarDate(Var ADate : TIdSoapDate);
begin
  Check(ADate.Year = 1234,'Year failed');
  Check(ADate.Month = 5,'Month failed');
  Check(ADate.Day = 30,'Day failed');
  ADate.Year := 4321;
  ADate.Month := 7;
  ADate.Day := 20;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamTime(ATime : TIdSoapTime);
begin
  Check(ATime.Hour = 12,'Hour failed');
  Check(ATime.Minute = 18,'Minute failed');
  Check(ATime.Second = 29,'Second failed');
  Check(ATime.Nanosecond = 987654321,'Nanoseconds failed');
end;

function TIdSoapInterfaceTestsInterface.FuncParamTimeRetTime(ATime : TIdSoapTime) : TIdSoapTime;
begin
  Check(ATime.Hour = 12,'Hour failed');
  Check(ATime.Minute = 18,'Minute failed');
  Check(ATime.Second = 29,'Second failed');
  Check(ATime.Nanosecond = 987654321,'Nanoseconds failed');
  Result := TIdSoapTime.Create;
  Result.Hour := 9;
  Result.Minute := 28;
  Result.Second := 39;
  Result.Nanosecond := 987654322;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamOutTime(Out ATime : TIdSoapTime);
begin
  ATime := TIdSoapTime.Create;
  ATime.Hour := 9;
  ATime.Minute := 28;
  ATime.Second := 39;
  ATime.Nanosecond := 987654322;
end;

procedure TIdSoapInterfaceTestsInterface.ProcParamVarTime(Var ATime : TIdSoapTime);
begin
  Check(ATime.Hour = 12,'Hour failed');
  Check(ATime.Minute = 18,'Minute failed');
  Check(ATime.Second = 29,'Second failed');
  Check(ATime.Nanosecond = 987654321,'Nanoseconds failed');
  ATime.Hour := 9;
  ATime.Minute := 28;
  ATime.Second := 39;
  ATime.Nanosecond := 987654322;
end;

procedure TIdSoapInterfaceTestsInterface.ProcReferenceTesting1(ASame: boolean; AObj1, AObj2: TReferenceTestingObject);
begin
  if ASame then
    begin
    check(AObj1 = AObj2, 'Objects are different');
    end
  else
    begin
    check(AObj1 <> AObj2, 'Objects are not different');
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcReferenceTesting2(out VObj1, VObj2: TReferenceTestingObject);
begin
  VObj1 := TReferenceTestingObject.create;
  VObj1.Child := TReferenceTestingObject.create;
  VObj2 := VObj1.child;
end;

procedure TIdSoapInterfaceTestsInterface.ProcNilClass(AClass: TSoapSimpleTestClass);
begin
  check(AClass = nil,'AClass should be nil');
end;

procedure TIdSoapInterfaceTestsInterface.ProcConstNilClass(const AClass: TSoapSimpleTestClass);
begin
  check(AClass = nil,'AClass should be nil');
end;

procedure TIdSoapInterfaceTestsInterface.ProcOutNilClass(Out AClass: TSoapSimpleTestClass);
begin
  AClass := nil;
end;

procedure TIdSoapInterfaceTestsInterface.ProcVarNilClass(Var AClass: TSoapSimpleTestClass);
begin
  check(AClass = nil,'AClass should be nil');
end;

function  TIdSoapInterfaceTestsInterface.FuncRetNilClass: TSoapSimpleTestClass;
begin
  result := nil;
end;

function  TIdSoapInterfaceTestsInterface.FuncRetNilPropClass: TSoapNilPropClass;
begin
  result := TSoapNilPropClass.create;
  result.AClass := nil;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3StringPropClass(Var AClass: TSoap3StringProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 'Field1','Field1 is invalid');
  Check(AClass.Field2 = 'Field2','Field2 is invalid');
  Check(AClass.Field3 = 'Field3','Field3 is invalid');
  AClass.Field1 := AClass.Field1 + '|RET1';
  AClass.Field2 := AClass.Field2 + '|RET2';
  AClass.Field3 := AClass.Field3 + '|RET3';
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3ShortStringPropClass(Var AClass: TSoap3ShortStringProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 'SS1','Field1 is invalid');
  Check(AClass.Field2 = 'SS2','Field2 is invalid');
  Check(AClass.Field3 = 'SS3','Field3 is invalid');
  AClass.Field1 := AClass.Field1 + '|1';
  AClass.Field2 := AClass.Field2 + '|2';
  AClass.Field3 := AClass.Field3 + '|3';
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3WideStringPropClass(Var AClass: TSoap3WideStringProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 'WS1','Field1 is invalid');
  Check(AClass.Field2 = 'WS2','Field2 is invalid');
  Check(AClass.Field3 = 'WS3','Field3 is invalid');
  AClass.Field1 := AClass.Field1 + '|1';
  AClass.Field2 := AClass.Field2 + '|2';
  AClass.Field3 := AClass.Field3 + '|3';
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3CharPropClass(Var AClass: TSoap3CharProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 'A','Field1 is invalid');
  Check(AClass.Field2 = 'B','Field2 is invalid');
  Check(AClass.Field3 = 'C','Field3 is invalid');
  AClass.Field1 := 'a';
  AClass.Field2 := 'b';
  AClass.Field3 := 'c';
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3WideCharPropClass(Var AClass: TSoap3WideCharProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = '1','Field1 is invalid');
  Check(AClass.Field2 = '2','Field2 is invalid');
  Check(AClass.Field3 = '3','Field3 is invalid');
  AClass.Field1 := 'A';
  AClass.Field2 := 'B';
  AClass.Field3 := 'C';
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3BytePropClass(Var AClass: TSoap3ByteProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 1,'Field1 is invalid');
  Check(AClass.Field2 = 2,'Field2 is invalid');
  Check(AClass.Field3 = 3,'Field3 is invalid');
  AClass.Field1 := $11;
  AClass.Field2 := $22;
  AClass.Field3 := $33;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3ShortIntPropClass(Var AClass: TSoap3ShortIntProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 12,'Field1 is invalid');
  Check(AClass.Field2 = 13,'Field2 is invalid');
  Check(AClass.Field3 = 14,'Field3 is invalid');
  AClass.Field1 := -21;
  AClass.Field2 := -32;
  AClass.Field3 := -43;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3SmallIntPropClass(Var AClass: TSoap3SmallIntProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = -1,'Field1 is invalid');
  Check(AClass.Field2 = -2,'Field2 is invalid');
  Check(AClass.Field3 = -3,'Field3 is invalid');
  AClass.Field1 := -11;
  AClass.Field2 := -22;
  AClass.Field3 := -33;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3WordPropClass(Var AClass: TSoap3WordProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 123,'Field1 is invalid');
  Check(AClass.Field2 = 456,'Field2 is invalid');
  Check(AClass.Field3 = 789,'Field3 is invalid');
  AClass.Field1 := 111;
  AClass.Field2 := 222;
  AClass.Field3 := 333;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3IntegerPropClass(Var AClass: TSoap3IntegerProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 1111,'Field1 is invalid');
  Check(AClass.Field2 = 2222,'Field2 is invalid');
  Check(AClass.Field3 = 3333,'Field3 is invalid');
  AClass.Field1 := 11111;
  AClass.Field2 := 22222;
  AClass.Field3 := 33333;
end;

{$IFNDEF DELPHI4}
procedure TIdSoapInterfaceTestsInterface.ProcSimple3CardinalPropClass(Var AClass: TSoap3CardinalProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 5555,'Field1 is invalid');
  Check(AClass.Field2 = 6666,'Field2 is invalid');
  Check(AClass.Field3 = 7777,'Field3 is invalid');
  AClass.Field1 := 55555;
  AClass.Field2 := 66666;
  AClass.Field3 := 77777;
end;
{$ENDIF}

procedure TIdSoapInterfaceTestsInterface.ProcSimple3Int64PropClass(Var AClass: TSoap3Int64Properties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 1000000001,'Field1 is invalid');
  Check(AClass.Field2 = 1000000002,'Field2 is invalid');
  Check(AClass.Field3 = 1000000003,'Field3 is invalid');
  AClass.Field1 := 10000000011;
  AClass.Field2 := 10000000022;
  AClass.Field3 := 10000000033;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3SinglePropClass(Var AClass: TSoap3SingleProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 123.0,'Field1 is invalid');
  Check(AClass.Field2 = 456.0,'Field2 is invalid');
  Check(AClass.Field3 = 789.0,'Field3 is invalid');
  AClass.Field1 := 111.0;
  AClass.Field2 := 222.0;
  AClass.Field3 := 333.0;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3DoublePropClass(Var AClass: TSoap3DoubleProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(SameReal(AClass.Field1,111.1),'Field1 is invalid');
  Check(SameReal(AClass.Field2,222.2),'Field2 is invalid');
  Check(SameReal(AClass.Field3,333.3),'Field3 is invalid');
  AClass.Field1 := 111.11;
  AClass.Field2 := 222.22;
  AClass.Field3 := 333.33;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3ExtendedPropClass(Var AClass: TSoap3ExtendedProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(SameReal(AClass.Field1,123.111),'Field1 is invalid');
  Check(SameReal(AClass.Field2,456.222),'Field2 is invalid');
  Check(SameReal(AClass.Field3,789.333),'Field3 is invalid');
  AClass.Field1 := 111.111;
  AClass.Field2 := 222.222;
  AClass.Field3 := 333.333;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3CompPropClass(Var AClass: TSoap3CompProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 1,'Field1 is invalid');
  Check(AClass.Field2 = 2,'Field2 is invalid');
  Check(AClass.Field3 = 3,'Field3 is invalid');
  AClass.Field1 := 11;
  AClass.Field2 := 22;
  AClass.Field3 := 33;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3CurrPropClass(Var AClass: TSoap3CurrProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = 123456.78,'Field1 is invalid');
  Check(AClass.Field2 = 234567.89,'Field2 is invalid');
  Check(AClass.Field3 = 345678.90,'Field3 is invalid');
  AClass.Field1 := -111.11;
  AClass.Field2 := -222.22;
  AClass.Field3 := -333.33;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3EnumPropClass(Var AClass: TSoap3EnumProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = s3eOne,'Field1 is invalid');
  Check(AClass.Field2 = s3eTwo,'Field2 is invalid');
  Check(AClass.Field3 = s3eThree,'Field3 is invalid');
  AClass.Field1 := s3eFour;
  AClass.Field2 := s3eFive;
  AClass.Field3 := s3eSix;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3SetPropClass(Var AClass: TSoap3SetProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1 = [s3eOne],'Field1 is invalid');
  Check(AClass.Field2 = [s3eTwo],'Field2 is invalid');
  Check(AClass.Field3 = [s3eThree],'Field3 is invalid');
  AClass.Field1 := [s3eOne,s3eFour];
  AClass.Field2 := [s3eTwo,s3eFive];
  AClass.Field3 := [s3eThree,s3eSix];
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3ClassPropClass(Var AClass: TSoap3ClassProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1.Field1 = '1-1','Field1 is invalid');
  Check(AClass.Field1.Field2 = '1-2','Field2 is invalid');
  Check(AClass.Field1.Field3 = '1-3','Field3 is invalid');
  Check(AClass.Field2.Field1 = '2-1','Field1 is invalid');
  Check(AClass.Field2.Field2 = '2-2','Field2 is invalid');
  Check(AClass.Field2.Field3 = '2-3','Field3 is invalid');
  Check(AClass.Field3.Field1 = '3-1','Field1 is invalid');
  Check(AClass.Field3.Field2 = '3-2','Field2 is invalid');
  Check(AClass.Field3.Field3 = '3-3','Field3 is invalid');
  AClass.Field1.Field1 := '1-1-RET';
  AClass.Field1.Field2 := '1-2-RET';
  AClass.Field1.Field3 := '1-3-RET';
  AClass.Field2.Field1 := '2-1-RET';
  AClass.Field2.Field2 := '2-2-RET';
  AClass.Field2.Field3 := '2-3-RET';
  AClass.Field3.Field1 := '3-1-RET';
  AClass.Field3.Field2 := '3-2-RET';
  AClass.Field3.Field3 := '3-3-RET';
end;

procedure TIdSoapInterfaceTestsInterface.ProcSimple3DynArrPropClass(Var AClass: TSoap3DynArrProperties);
begin
  Check(AClass <> nil,'AClass should not be nil');
  Check(AClass.Field1[0] = '1-0','Field1 is invalid');
  Check(AClass.Field1[1] = '1-1','Field2 is invalid');
  Check(AClass.Field1[2] = '1-2','Field3 is invalid');
  Check(AClass.Field2[0] = '2-0','Field1 is invalid');
  Check(AClass.Field2[1] = '2-1','Field2 is invalid');
  Check(AClass.Field2[2] = '2-2','Field3 is invalid');
  Check(AClass.Field3[0] = '3-0','Field1 is invalid');
  Check(AClass.Field3[1] = '3-1','Field2 is invalid');
  Check(AClass.Field3[2] = '3-2','Field3 is invalid');
  AClass.Field1[0] := '1-0-RET';
  AClass.Field1[1] := '1-1-RET';
  AClass.Field1[2] := '1-2-RET';
  AClass.Field2[0] := '2-0-RET';
  AClass.Field2[1] := '2-1-RET';
  AClass.Field2[2] := '2-2-RET';
  AClass.Field3[0] := '3-0-RET';
  AClass.Field3[1] := '3-1-RET';
  AClass.Field3[2] := '3-2-RET';
end;

function  TIdSoapInterfaceTestsInterface.FuncSpBoolean(ABool : TIdSoapBoolean): TIdSoapBoolean;
begin
  if assigned(ABool) then
    begin
    result := TIdSoapBoolean.create;
    result.Value := ABool.Value;
    end
  else
    begin
    result := nil;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSpBoolean(var VBool : TIdSoapBoolean);
begin
  if VBool.Value then
    begin
    FreeAndNil(VBool);
    end
  else
    begin
    VBool.Value := true;
    end;
end;

function  TIdSoapInterfaceTestsInterface.FuncSpInteger(AInt : TIdSoapInteger): TIdSoapInteger;
begin
  if assigned(AInt) then
    begin
    result := TIdSoapInteger.create;
    result.Value := AInt.Value;
    end
  else
    begin
    result := nil;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSpInteger(var VInt : TIdSoapInteger);
begin
  if VInt.Value mod 2 = 1 then
    begin
    VInt.Value := VInt.Value - 1;
    end
  else
    begin
    FreeAndNil(VInt);
    end;
end;

function  TIdSoapInterfaceTestsInterface.FuncSpDouble(ADouble : TIdSoapDouble): TIdSoapDouble;
begin
  if assigned(ADouble) then
    begin
    result := TIdSoapDouble.create;
    result.Value := ADouble.Value;
    end
  else
    begin
    result := nil;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSpDouble(var VDouble : TIdSoapDouble);
begin
  if VDouble.Value > 1 then
    begin
    VDouble.Value := VDouble.Value * VDouble.Value;
    end
  else
    begin
    FreeAndNil(VDouble);
    end;
end;

function  TIdSoapInterfaceTestsInterface.FuncSpString(AStr : TIdSoapString): TIdSoapString;
begin
  if assigned(AStr) then
    begin
    result := TIdSoapString.create;
    result.Value := AStr.Value;
    end
  else
    begin
    result := nil;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcSpString(var VStr : TIdSoapString);
begin
  if length(VStr.Value) > 3 then
    begin
    VStr.Value := VStr.Value + '___';
    end
  else
    begin
    FreeAndNil(VStr);
    end;
end;

function  TIdSoapInterfaceTestsInterface.FuncQName(AQname : TIdSoapQName): TIdSoapQName;
begin
  if assigned(AQname) then
    begin
    result := TIdSoapQname.create;
    result.Namespace := AQname.Namespace;
    result.Value := AQname.Value;
    end
  else
    begin
    result := nil;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcQName(var VQName : TIdSoapQName);
begin
  if length(VQname.Value) > 3 then
    begin
    VQname.Namespace := 'namespace';
    VQname.Value := 'name';
    end
  else
    begin
    FreeAndNil(VQname);
    end;
end;

function  TIdSoapInterfaceTestsInterface.FuncRawXML(AXml : TIdSoapRawXML): TIdSoapRawXML;
begin
  if assigned(AXml) then
    begin
    result := TIdSoapRawXML.create;
    result.Init(GServer.XMLProvider);
    result.XML.GrabChildren(AXml.XML, true);
    end
  else
    begin
    result := nil;
    end;
end;

procedure TIdSoapInterfaceTestsInterface.ProcRawXML(var VXml : TIdSoapRawXML);
begin
  if VXml.XML.ChildCount > 0 then
    begin
    VXml.XML.AppendChild('testadd').setAttribute('testattr', 'testvalue');
    end
  else
    begin
    FreeAndNil(VXML);
    end;
end;

initialization
  IdSoapRegisterInterfaceClass('IIdSoapInterfaceTestsInterface', TypeInfo(TIdSoapInterfaceTestsInterface), TIdSoapInterfaceTestsInterface);
  if kdeVersionMark = '' then
    exit; {never remove this check - see the National Development Manager }
end.
