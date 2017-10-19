{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16396: IdSoapInterfaceTests.pas 
{
{   Rev 1.2    19/6/2003 21:35:56  GGrieve
{ Version #1
}
{
{   Rev 1.1    18/3/2003 11:15:46  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:27:40  GGrieve
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  Better test children
  18-Mar 2003   Grahame Grieve                  QName, RawXML, Schema extensibility, Kylix compile fixes
  05-Sep 2002   Grahame Grieve                  Various fixes for Doc|Lit mode
  28-Aug 2002   Andrew Cumming                  Many more tests for class properties
  23-Aug 2002   Grahame Grieve                  Doc|Lit testing
  06-Aug 2002   Grahame Grieve                  Fix warning
  22-Jul 2002   Grahame Grieve                  Soap V1.1 conformance testing
  17-Jul 2002   Andrew Cumming                  Fixed interface disposing issue in TestInterfaceLifetimes
  29-May 2002   Grahame Grieve                  Fix Binary Array Test - reset Stream positions
  29-May 2002   Grahame Grieve                  Added Binary Array tests + move type registration
   7-May 2002   Andrew Cumming                  Added resource additions
   4-May 2002   Andrew Cumming                  Added small test to assist in property array bug search
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing compiler warnings
  12-Apr 2002   Andrew Cumming                  More tests for multiple interfaces
  10-Apr 2002   Andrew Cumming                  Added another test for lifetime checking
  09-Apr 2002   Andrew Cumming                  Added tests for nil classes and empty arrays
  08-Apr 2002   Grahame Grieve                  Binary Properties and Objects by reference tests
  06-Apr 2002   Andrew Cumming                  Fix D6 compiler errors
  06-Apr 2002   Andrew Cumming                  Added date/time tests
  05-Apr 2002   Andrew Cumming                  Added more tests for arrays of classes
  02-Apr 2002   Grahame Grieve                  whoopsy. Set the encoding type right, and surprise - lot's of failures
  29-Mar 2002   Grahame Grieve                  Add tests relating to object lifetime management (will force fix of server leaks)
  27-Mar 2002   Andrew Cumming                  Name change, a type wasnt registered, IDSOAP changes to ID_SOAP for polymorphic's
  27-Mar 2002   Grahame Grieve                  Add Tests for Arrays of objects
  26-Mar 2002   Grahame Grieve                  Change to direct client, and fix type registrations
  19-Mar 2002   Andrew Cumming                  Added extra namespace info for D4/D5 support
  14-Mar 2002   Andrew Cumming                  Added code for Application.ProcessMessages equiv to TearDown
  14-Mar 2002   Grahame Grieve                  Change Widestring tests (still failing though)
  12-Mar 2002   Grahame Grieve                  Added Binary Tests
   8-Mar 2002   Andrew Cumming                  Added code for Boolean tests
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
   3-Mar 2002   Andrew Cumming                  Added some tests for SETs
   3-Mar 2002   Andrew Cumming                  Changed declarations slightly to accomodate dyn array properties in D4/D5
   1-Mar 2002   Andrew Cumming                  Added polymorphic class tests
  28-Feb 2002   Andrew Cumming                  Made D4 compatible
  28-Feb 2002   Andrew Cumming                  First tests for classes
  24-Feb 2002   Andrew Cumming                  Added tests for dynamic array results
  24-Feb 2002   Andrew Cumming                  More dynamic array tests
  22-Feb 2002   Andrew Cumming                  Registration of arrays for D4/D5
  22-Feb 2002   Andrew Cumming                  More dynamic array tests + ASCII string escape test
  15-Feb 2002   Andrew Cumming                  Fixed for re-arrangement of code in helper unit
  14-Feb-2002   Added more details to dynamic array tests to help diferentiate the different array elements
  13-Feb 2002   Fixed up names for Dynamic array tests. Added new dynamic array test
  12-Feb 2002   Merged with IndySOAP masters
}

Unit IdSoapInterfaceTests;

{$I IdSoapDefines.inc}

Interface

uses
  Classes,
  IdSoapInterfaceTestsIntfDefn,
  IdSoapITI,
  IdSoapMultipleIntfDefn,
  IdSoapITIProvider,
  IdSoapTypeRegistry,
  IdSoapXML,
  TestFramework,
  TypInfo;

type
  TIdSoapInterfaceBaseTests = class(TTestCase)
  Private
    FIntf: IIdSoapInterfaceTestsInterface;
    FIntf2 : IIdSoapInterfaceTestsInterface;
    FBool1, FBool2: Boolean;
    FByte1, FByte2: Byte;
    FChar1, FChar2: Char;
    FShortInt1, FShortInt2: Shortint;
    FWord1, FWord2: Word;
    FSmallint1, FSmallint2: Smallint;
    FCardinal1, FCardinal2: Cardinal;
    FInteger1, FInteger2: Integer;
    FInt641, FInt642: Int64;
    FSingle1, FSingle2: Single;
    FDouble1, FDouble2: Double;
    FComp1, FComp2: Comp;
    FExtended1, FExtended2: Extended;
    FCurrency1, FCurrency2: Currency;
    FShortString1, FShortString2: Shortstring;
    FString1, FString2: String;
    FWideString1, FWideString2: WideString;
    FEnum1, FEnum2: TLargeEnum;
    FBoolean1,FBoolean2: Boolean;
    procedure DefineString(AStringType: TTypeKind);
    procedure DefineReal(AFloatType: TFloatType; ATestValues1: Boolean);
    procedure DefineInt64(ATestValues1: Boolean);
    procedure DefineValues(AForceCardinal: Boolean; AOrdType: TOrdType; ATestValues1: Boolean);
    function CreateSendStream(AFillCount : integer):TStream;
    function CreateSendHexStream(AFillCount : integer):THexStream;
  Protected
    procedure SetUp; Override;
    procedure TearDown; Override;
    procedure FixITI(AITI : TIdSoapITI); virtual; abstract;
    function GetClientEncodingType : TIdSoapEncodingType; virtual; abstract;
    function GetXMLProvider : TIdSoapXMLProvider; virtual;
  Published
    // initial tests to check error reporting. If these fail, then you cannot rely on the remaining tests
    procedure ProcedureCall;
    procedure TestServerErrorReporting;
    // Tests to confirm transport of data
    procedure TestFullAsciiSet;
    // BOOLEAN tests
    procedure FuncRetBoolToggle;
    procedure FuncBoolRetBool;
    procedure FuncVarBoolRetBool;
    procedure FuncBoolBoolRetBool;
    procedure FuncVarBoolBoolRetBool;
    procedure FuncBoolVarBoolRetBool;
    procedure FuncVarBoolVarBoolRetBool;
    procedure FuncConstBoolBoolRetBool;
    procedure FuncBoolConstBoolRetBool;
    procedure FuncConstBoolConstBoolRetBool;
    procedure FuncOutBoolBoolRetBool;
    procedure FuncBoolOutBoolRetBool;
    procedure FuncOutBoolOutBoolRetBool;
    // BYTE tests
    procedure FuncRetByteToggle;
    procedure FuncByteRetByte;
    procedure FuncVarByteRetByte;
    procedure FuncByteByteRetByte;
    procedure FuncVarByteByteRetByte;
    procedure FuncByteVarByteRetByte;
    procedure FuncVarByteVarByteRetByte;
    procedure FuncConstByteByteRetByte;
    procedure FuncByteConstByteRetByte;
    procedure FuncConstByteConstByteRetByte;
    procedure FuncOutByteByteRetByte;
    procedure FuncByteOutByteRetByte;
    procedure FuncOutByteOutByteRetByte;
    // CHAR tests
    procedure FuncRetCharToggle;
    procedure FuncCharRetChar;
    procedure FuncVarCharRetChar;
    procedure FuncCharCharRetChar;
    procedure FuncVarCharCharRetChar;
    procedure FuncCharVarCharRetChar;
    procedure FuncVarCharVarCharRetChar;
    procedure FuncConstCharCharRetChar;
    procedure FuncCharConstCharRetChar;
    procedure FuncConstCharConstCharRetChar;
    procedure FuncOutCharCharRetChar;
    procedure FuncCharOutCharRetChar;
    procedure FuncOutCharOutCharRetChar;
    // SHORTINT tests
    procedure FuncRetShortIntToggle;
    procedure FuncShortIntRetShortInt;
    procedure FuncVarShortIntRetShortInt;
    procedure FuncShortIntShortIntRetShortInt;
    procedure FuncVarShortIntShortIntRetShortInt;
    procedure FuncShortIntVarShortIntRetShortInt;
    procedure FuncVarShortIntVarShortIntRetShortInt;
    procedure FuncConstShortIntShortIntRetShortInt;
    procedure FuncShortIntConstShortIntRetShortInt;
    procedure FuncConstShortIntConstShortIntRetShortInt;
    procedure FuncOutShortIntShortIntRetShortInt;
    procedure FuncShortIntOutShortIntRetShortInt;
    procedure FuncOutShortIntOutShortIntRetShortInt;
    // WORD tests
    procedure FuncRetWordToggle;
    procedure FuncWordRetWord;
    procedure FuncVarWordRetWord;
    procedure FuncWordWordRetWord;
    procedure FuncVarWordWordRetWord;
    procedure FuncWordVarWordRetWord;
    procedure FuncVarWordVarWordRetWord;
    procedure FuncConstWordWordRetWord;
    procedure FuncWordConstWordRetWord;
    procedure FuncConstWordConstWordRetWord;
    procedure FuncOutWordWordRetWord;
    procedure FuncWordOutWordRetWord;
    procedure FuncOutWordOutWordRetWord;
    // SMALLINT TESTS
    procedure FuncRetSmallintToggle;
    procedure FuncSmallintRetSmallint;
    procedure FuncVarSmallintRetSmallint;
    procedure FuncSmallintSmallintRetSmallint;
    procedure FuncVarSmallintSmallintRetSmallint;
    procedure FuncSmallintVarSmallintRetSmallint;
    procedure FuncVarSmallintVarSmallintRetSmallint;
    procedure FuncConstSmallintSmallintRetSmallint;
    procedure FuncSmallintConstSmallintRetSmallint;
    procedure FuncConstSmallintConstSmallintRetSmallint;
    procedure FuncOutSmallintSmallintRetSmallint;
    procedure FuncSmallintOutSmallintRetSmallint;
    procedure FuncOutSmallintOutSmallintRetSmallint;
    // CARDINAL TESTS
    procedure FuncRetCardinalToggle;
    procedure FuncCardinalRetCardinal;
    procedure FuncVarCardinalRetCardinal;
    procedure FuncCardinalCardinalRetCardinal;
    procedure FuncVarCardinalCardinalRetCardinal;
    procedure FuncCardinalVarCardinalRetCardinal;
    procedure FuncVarCardinalVarCardinalRetCardinal;
    procedure FuncConstCardinalCardinalRetCardinal;
    procedure FuncCardinalConstCardinalRetCardinal;
    procedure FuncConstCardinalConstCardinalRetCardinal;
    procedure FuncOutCardinalCardinalRetCardinal;
    procedure FuncCardinalOutCardinalRetCardinal;
    procedure FuncOutCardinalOutCardinalRetCardinal;
    // INTEGER TESTS
    procedure FuncRetIntegerToggle;
    procedure FuncIntegerRetInteger;
    procedure FuncVarIntegerRetInteger;
    procedure FuncIntegerIntegerRetInteger;
    procedure FuncVarIntegerIntegerRetInteger;
    procedure FuncIntegerVarIntegerRetInteger;
    procedure FuncVarIntegerVarIntegerRetInteger;
    procedure FuncConstIntegerIntegerRetInteger;
    procedure FuncIntegerConstIntegerRetInteger;
    procedure FuncConstIntegerConstIntegerRetInteger;
    procedure FuncOutIntegerIntegerRetInteger;
    procedure FuncIntegerOutIntegerRetInteger;
    procedure FuncOutIntegerOutIntegerRetInteger;
    // INT64 TESTS
    procedure FuncRetInt64Toggle;
    procedure FuncInt64RetInt64;
    procedure FuncVarInt64RetInt64;
    procedure FuncInt64Int64RetInt64;
    procedure FuncVarInt64Int64RetInt64;
    procedure FuncInt64VarInt64RetInt64;
    procedure FuncVarInt64VarInt64RetInt64;
    procedure FuncConstInt64Int64RetInt64;
    procedure FuncInt64ConstInt64RetInt64;
    procedure FuncConstInt64ConstInt64RetInt64;
    procedure FuncOutInt64Int64RetInt64;
    procedure FuncInt64OutInt64RetInt64;
    procedure FuncOutInt64OutInt64RetInt64;
    // SINGLE TESTS
    procedure FuncRetSingleToggle;
    procedure FuncSingleRetSingle;
    procedure FuncVarSingleRetSingle;
    procedure FuncSingleSingleRetSingle;
    procedure FuncVarSingleSingleRetSingle;
    procedure FuncSingleVarSingleRetSingle;
    procedure FuncVarSingleVarSingleRetSingle;
    procedure FuncConstSingleSingleRetSingle;
    procedure FuncSingleConstSingleRetSingle;
    procedure FuncConstSingleConstSingleRetSingle;
    procedure FuncOutSingleSingleRetSingle;
    procedure FuncSingleOutSingleRetSingle;
    procedure FuncOutSingleOutSingleRetSingle;
    // DOUBLE TESTS
    procedure FuncRetDoubleToggle;
    procedure FuncDoubleRetDouble;
    procedure FuncVarDoubleRetDouble;
    procedure FuncDoubleDoubleRetDouble;
    procedure FuncVarDoubleDoubleRetDouble;
    procedure FuncDoubleVarDoubleRetDouble;
    procedure FuncVarDoubleVarDoubleRetDouble;
    procedure FuncConstDoubleDoubleRetDouble;
    procedure FuncDoubleConstDoubleRetDouble;
    procedure FuncConstDoubleConstDoubleRetDouble;
    procedure FuncOutDoubleDoubleRetDouble;
    procedure FuncDoubleOutDoubleRetDouble;
    procedure FuncOutDoubleOutDoubleRetDouble;
    // COMP TESTS
    procedure FuncRetCompToggle;
    procedure FuncCompRetComp;
    procedure FuncVarCompRetComp;
    procedure FuncCompCompRetComp;
    procedure FuncVarCompCompRetComp;
    procedure FuncCompVarCompRetComp;
    procedure FuncVarCompVarCompRetComp;
    procedure FuncConstCompCompRetComp;
    procedure FuncCompConstCompRetComp;
    procedure FuncConstCompConstCompRetComp;
    procedure FuncOutCompCompRetComp;
    procedure FuncCompOutCompRetComp;
    procedure FuncOutCompOutCompRetComp;
    // EXTENDED TESTS
    procedure FuncRetExtendedToggle;
    procedure FuncExtendedRetExtended;
    procedure FuncVarExtendedRetExtended;
    procedure FuncExtendedExtendedRetExtended;
    procedure FuncVarExtendedExtendedRetExtended;
    procedure FuncExtendedVarExtendedRetExtended;
    procedure FuncVarExtendedVarExtendedRetExtended;
    procedure FuncConstExtendedExtendedRetExtended;
    procedure FuncExtendedConstExtendedRetExtended;
    procedure FuncConstExtendedConstExtendedRetExtended;
    procedure FuncOutExtendedExtendedRetExtended;
    procedure FuncExtendedOutExtendedRetExtended;
    procedure FuncOutExtendedOutExtendedRetExtended;
    // CURRENCY TESTS
    procedure FuncRetCurrencyToggle;
    procedure FuncCurrencyRetCurrency;
    procedure FuncVarCurrencyRetCurrency;
    procedure FuncCurrencyCurrencyRetCurrency;
    procedure FuncVarCurrencyCurrencyRetCurrency;
    procedure FuncCurrencyVarCurrencyRetCurrency;
    procedure FuncVarCurrencyVarCurrencyRetCurrency;
    procedure FuncConstCurrencyCurrencyRetCurrency;
    procedure FuncCurrencyConstCurrencyRetCurrency;
    procedure FuncConstCurrencyConstCurrencyRetCurrency;
    procedure FuncOutCurrencyCurrencyRetCurrency;
    procedure FuncCurrencyOutCurrencyRetCurrency;
    procedure FuncOutCurrencyOutCurrencyRetCurrency;
    // SHORTSTRING TESTS
    procedure FuncRetShortStringToggle;
    procedure FuncShortStringRetShortString;
    procedure FuncVarShortStringRetShortString;
    procedure FuncShortStringShortStringRetShortString;
    procedure FuncVarShortStringShortStringRetShortString;
    procedure FuncShortStringVarShortStringRetShortString;
    procedure FuncVarShortStringVarShortStringRetShortString;
    procedure FuncConstShortStringShortStringRetShortString;
    procedure FuncShortStringConstShortStringRetShortString;
    procedure FuncConstShortStringConstShortStringRetShortString;
    procedure FuncOutShortStringShortStringRetShortString;
    procedure FuncShortStringOutShortStringRetShortString;
    procedure FuncOutShortStringOutShortStringRetShortString;
    // LONGSTRING TESTS
    procedure FuncRetStringToggle;
    procedure FuncStringRetString;
    procedure FuncVarStringRetString;
    procedure FuncStringStringRetString;
    procedure FuncVarStringStringRetString;
    procedure FuncStringVarStringRetString;
    procedure FuncVarStringVarStringRetString;
    procedure FuncConstStringStringRetString;
    procedure FuncStringConstStringRetString;
    procedure FuncConstStringConstStringRetString;
    procedure FuncOutStringStringRetString;
    procedure FuncStringOutStringRetString;
    procedure FuncOutStringOutStringRetString;
    // WIDESTRING TESTS
    procedure FuncRetWideStringToggle;
    procedure FuncWideStringRetWideString;
    procedure FuncVarWideStringRetWideString;
    procedure FuncWideStringWideStringRetWideString;
    procedure FuncVarWideStringWideStringRetWideString;
    procedure FuncWideStringVarWideStringRetWideString;
    procedure FuncVarWideStringVarWideStringRetWideString;
    procedure FuncConstWideStringWideStringRetWideString;
    procedure FuncWideStringConstWideStringRetWideString;
    procedure FuncConstWideStringConstWideStringRetWideString;
    procedure FuncOutWideStringWideStringRetWideString;
    procedure FuncWideStringOutWideStringRetWideString;
    procedure FuncOutWideStringOutWideStringRetWideString;
    // ENUMERATION TESTS
    procedure FuncRetEnumToggle;
    procedure FuncEnumRetEnum;
    procedure FuncVarEnumRetEnum;
    procedure FuncEnumEnumRetEnum;
    procedure FuncVarEnumEnumRetEnum;
    procedure FuncEnumVarEnumRetEnum;
    procedure FuncVarEnumVarEnumRetEnum;
    procedure FuncConstEnumEnumRetEnum;
    procedure FuncEnumConstEnumRetEnum;
    procedure FuncConstEnumConstEnumRetEnum;
    procedure FuncOutEnumEnumRetEnum;
    procedure FuncEnumOutEnumRetEnum;
    procedure FuncOutEnumOutEnumRetEnum;
    // BOOLEAN tests
    procedure FuncBooleanRetBoolean;
    procedure FuncVarBooleanRetBoolean;
    procedure FuncBooleanBooleanRetBoolean;
    procedure FuncVarBooleanBooleanRetBoolean;
    procedure FuncBooleanVarBooleanRetBoolean;
    procedure FuncVarBooleanVarBooleanRetBoolean;
    procedure FuncConstBooleanBooleanRetBoolean;
    procedure FuncBooleanConstBooleanRetBoolean;
    procedure FuncConstBooleanConstBooleanRetBoolean;
    procedure FuncOutBooleanBooleanRetBoolean;
    procedure FuncBooleanOutBooleanRetBoolean;
    procedure FuncOutBooleanOutBooleanRetBoolean;
    // SETS tests
    procedure FuncRetSet;
    procedure ProcSet;
    procedure ProcConstSet;
    procedure ProcOutSet;
    procedure ProcVarSet;
    // DYNAMIC ARRAYS tests
    procedure DynArrTraversalRoutines;   // this is NOT a SOAP proc
    procedure ProcDynCurrency1Arr;
    procedure ProcDynInteger2Arr;
    procedure ProcDynString3Arr;
    procedure ProcDynByte4Arr;
    procedure ProcDynVarByte4Arr;
    procedure ProcDynVarCurrency1Arr;
    procedure ProcDynOutInteger2Arr;
    procedure FuncRetDynInteger2Arr;
    procedure FuncRetDynCurrency1Arr;
    procedure ProcDynObject1Arr;
    procedure ProcDynObject2Arr;
    procedure ProcDynObject3Arr;
    procedure ProcOutDynObject1Arr;
    procedure ProcOutDynObject2Arr;
    procedure FuncRetDynObject1Arr;
    procedure FuncRetDynObject2Arr;
    procedure ProcDynObject1ArrGarbageCollected;
    procedure ProcOutDynObject1ArrGarbageCollected;
    procedure FuncRetDynObject1ArrGarbageCollected;
    procedure ProcOutDynObject1ArrServerKeepAlive;
    procedure FuncRetDynObject1ArrServerKeepAlive;
    procedure ProcDynArrNil;
    procedure ProcConstDynArrNil;
    procedure ProcOutDynArrNil;
    procedure ProcVarDynArrNil;
    procedure FuncRetDynArrNil;

    // CLASS tests
    procedure ProcClass;
    procedure ProcFieldArrClass;
    procedure FuncRetClass;
    procedure ProcClass_InLine;
    procedure FuncRetClass_InLine;
    procedure ProcClassGarbageCollected;
    procedure FuncRetClassGarbageCollected;
    procedure ProcClassServerKeepAlive;
    procedure FuncRetClassServerKeepAlive;
    procedure FuncRetVirtualClass;
    procedure ProcVarVirtualClass;
    procedure ProcVirtualClass;
    procedure ProcClassReference1;
    procedure ProcClassReference2;
    procedure ProcClassReference3;
    procedure FuncClassReference4;
    procedure FuncClassReference5;

    procedure ProcNilClass;
    procedure ProcConstNilClass;
    procedure ProcOutNilClass;
    procedure ProcVarNilClass;
    procedure FuncRetNilClass;
    procedure FuncRetNilPropClass;

    // CLASS property/ordering tests

    procedure ProcSimple3StringPropClass;
    procedure ProcSimple3ShortStringPropClass;
    procedure ProcSimple3BytePropClass;
    procedure ProcSimple3ShortIntPropClass;
    procedure ProcSimple3SmallIntPropClass;
    procedure ProcSimple3WordPropClass;
    procedure ProcSimple3IntegerPropClass;
{$IFNDEF DELPHI4}
    procedure ProcSimple3CardinalPropClass;
{$ENDIF}
    procedure ProcSimple3Int64PropClass;
    procedure ProcSimple3SinglePropClass;
    procedure ProcSimple3DoublePropClass;
    procedure ProcSimple3ExtendedPropClass;
    procedure ProcSimple3CompPropClass;
    procedure ProcSimple3CurrPropClass;
    procedure ProcSimple3WideStringPropClass;
    procedure ProcSimple3CharPropClass;
    procedure ProcSimple3WideCharPropClass;
    procedure ProcSimple3EnumPropClass;
    procedure ProcSimple3SetPropClass;
    procedure ProcSimple3ClassPropClass;
    procedure ProcSimple3DynArrPropClass;

    // BINARY Tests
    procedure ProcTestBinary;
    procedure ProcTestBinaryEmpty;
    procedure ProcTestBinaryNil;
    procedure FuncTestBinary;
    procedure FuncTestBinaryEmpty;
    procedure FuncTestBinaryNil;
    procedure ProcTestOutBinary;
    procedure ProcTestOutBinaryEmpty;
    procedure ProcTestOutBinaryNil;
    procedure ProcTestVarBinary;
    procedure ProcTestVarBinaryEmpty;
    procedure ProcTestVarBinaryNil;
    procedure ProcTestOutBinaryHuge;
    procedure ProcTestBinaryProperty;
    procedure ProcTestVarBinaryProperty;
    procedure ProcTestOutBinaryProperty;
    procedure FuncTestRetBinaryProperty;
    procedure ProcTestBinaryArray;
    procedure ProcTestOutBinaryArray;
    procedure ProcTestVarBinaryArray;
    procedure ProcTestHexBinary;
    procedure ProcTestHexBinaryEmpty;
    procedure ProcTestHexBinaryNil;
    procedure FuncTestHexBinary;
    procedure FuncTestHexBinaryEmpty;
    procedure FuncTestHexBinaryNil;
    procedure ProcTestOutHexBinary;
    procedure ProcTestOutHexBinaryEmpty;
    procedure ProcTestOutHexBinaryNil;
    procedure ProcTestVarHexBinary;
    procedure ProcTestVarHexBinaryEmpty;
    procedure ProcTestVarHexBinaryNil;
    procedure ProcTestOutHexBinaryHuge;
    procedure ProcTestHexBinaryProperty;
    procedure ProcTestVarHexBinaryProperty;
    procedure ProcTestOutHexBinaryProperty;
    procedure FuncTestRetHexBinaryProperty;
    procedure ProcTestHexBinaryArray;
    procedure ProcTestOutHexBinaryArray;
    procedure ProcTestVarHexBinaryArray;

    // DATE tests
    procedure ProcParamDateTime;
    procedure FuncParamDateTimeRetDateTime;
    procedure ProcParamOutDateTime;
    procedure ProcParamVarDateTime;
    procedure ProcParamDate;
    procedure FuncParamDateRetDate;
    procedure ProcParamOutDate;
    procedure ProcParamVarDate;
    procedure ProcParamTime;
    procedure FuncParamTimeRetTime;
    procedure ProcParamOutTime;
    procedure ProcParamVarTime;

    // Interface lifetime testing
    procedure TestInterfaceLifetimes;
    // Multiple simultaneous interface testing
    procedure NoInterfaceUsage;
    procedure TestMultipleInterfaces;
    procedure TestInterfacesReleaseOrder;

    // Tests for special classes
    procedure TestSpecialBoolean;
    procedure TestSpecialInteger;
    procedure TestSpecialDouble;
    procedure TestSpecialString;
    procedure TestQName;
    procedure TestRawXml;
  end;

  TIdSoapInterfaceRPCTests = class(TIdSoapInterfaceBaseTests)
  Protected
    procedure FixITI(AITI : TIdSoapITI); override;
  end;

  TIdSoapInterfaceBinTests = class(TIdSoapInterfaceRPCTests)
  Protected
    function GetClientEncodingType : TIdSoapEncodingType; override;
  end;

  TIdSoapInterfaceXML8Tests = class(TIdSoapInterfaceRPCTests)
  Protected
    function GetClientEncodingType : TIdSoapEncodingType; override;
  end;

  {$IFDEF USE_MSXML}
  TIdSoapInterfaceMsXMLTests= class(TIdSoapInterfaceXML8Tests)
  Protected
    function GetXMLProvider : TIdSoapXMLProvider; override;
  end;
  {$ENDIF}

  TIdSoapInterfaceXML16Tests = class(TIdSoapInterfaceRPCTests)
  Protected
    function GetClientEncodingType : TIdSoapEncodingType; override;
  end;

  TIdSoapInterfaceDocLitTests = class(TIdSoapInterfaceBaseTests)
  Protected
    function GetClientEncodingType : TIdSoapEncodingType; override;
    procedure FixITI(AITI : TIdSoapITI); override;
  end;


Implementation

{$R IdSoapInterfaceTests.res}

uses
  IdSoapClient,
  IdSoapClientHTTP,
  IdSoapClientDirect,
  IdSoapDateTime,
  IdSoapDebug,
  IdSoapExceptions,
  IdSoapInterfaceTestsServer,
  IdSoapRawXML,
  IdSoapRpcPacket,
  IdSoapRTTIHelpers,
  IdSoapServer,
  IdSoapTestingUtils,
  IdSoapUtilities,
  SysUtils;

function IsIn(ATest, AVal1, AVal2: Int64): Boolean;
begin
  Result := True;
  if ATest = AVal1 then
    exit;
  if ATest = AVal2 then
    exit;
  Result := False;
end;

function IsStringIn(ATest, AString1, AString2: String): Boolean;
begin
  Result := True;
  if ATest = AString1 then
    exit;
  if ATest = AString2 then
    exit;
  Result := False;
end;

function IsStringInW(ATest, AString1, AString2: WideString): Boolean;
begin
  Result := True;
  if ATest = AString1 then
    exit;
  if ATest = AString2 then
    exit;
  Result := False;
end;

function IsEnumIn(ATest, AEnum1, AEnum2: TLargeEnum): Boolean;
begin
  Result := True;
  if ATest = AEnum1 then
    exit;
  if ATest = AEnum2 then
    exit;
  Result := False;
end;

function SameReal(AReal1, AReal2: Extended): Boolean;
begin
  Result := Abs(AReal1 - AReal2) < 0.001;
end;

function RealIsIn(ATest, AVal1, AVal2: Extended): Boolean;
begin
  Result := True;
  if abs(ATest - AVal1) < 0.001 then
    exit;
  if abs(ATest - AVal2) < 0.001 then
    exit;
  Result := False;
end;

{ TTest }

// All tests follow the following regime on EVERY type
// First determine if the result is coming back ok. This is done by toggling to try to ensure we dont get a stuck value
// next, check for a param by value
// then a param by ref (var type)
// then try dual params with combinations of const, var, and out to ensure the parameter ordering is correct
//      and to ensure that one parameter type is not interfering with another.

procedure TIdSoapInterfaceBaseTests.DefineValues(AForceCardinal: Boolean; AOrdType: TOrdType; ATestValues1: Boolean);
begin
  IdSoapInterfaceTestsIntfDefn.DefineValues(AForceCardinal,AOrdType, ATestValues1);
  FIntf.DefineValues(AForceCardinal,AOrdType, ATestValues1);
end;

procedure TIdSoapInterfaceBaseTests.DefineString(AStringType: TTypeKind);
begin
  IdSoapInterfaceTestsIntfDefn.DefineString(AStringType);
  FIntf.DefineString(AStringType);
end;

procedure TIdSoapInterfaceBaseTests.DefineReal(AFloatType: TFloatType; ATestValues1: Boolean);
begin
  IdSoapInterfaceTestsIntfDefn.DefineReal(AFloatType, ATestValues1);
  FIntf.DefineReal(AFloatType, ATestValues1);
end;

procedure TIdSoapInterfaceBaseTests.DefineInt64(ATestValues1: Boolean);
begin
  IdSoapInterfaceTestsIntfDefn.DefineInt64(ATestValues1);
  FIntf.DefineInt64(ATestValues1);
end;

procedure TIdSoapInterfaceBaseTests.FuncBoolBoolRetBool;
begin
  Check(FIntf.FuncBoolBoolRetBool(True, False), 'Failed Result');
end;

procedure TIdSoapInterfaceBaseTests.FuncBoolConstBoolRetBool;
begin
  Check(FIntf.FuncBoolConstBoolRetBool(True, False), 'Failed Result');
end;

procedure TIdSoapInterfaceBaseTests.FuncBoolOutBoolRetBool;
begin
  FBool2 := False;
  Check(FIntf.FuncBoolOutBoolRetBool(True, FBool2), 'Failed Result');
  Check(FBool2, 'Failed Bool2');
end;

procedure TIdSoapInterfaceBaseTests.FuncBoolVarBoolRetBool;
begin
  FBool1 := False;
  Check(FIntf.FuncBoolVarBoolRetBool(True, FBool1), 'Failed Result');
  Check(FBool1, 'Failed Bool1');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstBoolBoolRetBool;
begin
  Check(FIntf.FuncConstBoolBoolRetBool(True, False), 'Failed Result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstBoolConstBoolRetBool;
begin
  Check(FIntf.FuncConstBoolConstBoolRetBool(True, False), 'Failed Result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutBoolBoolRetBool;
begin
  FBool1 := True;
  Check(FIntf.FuncOutBoolBoolRetBool(FBool1, False), 'Failed Result');
  Check(FBool1, 'Failed Bool1');   // Bool1 is out so should be received false
end;

procedure TIdSoapInterfaceBaseTests.FuncOutBoolOutBoolRetBool;
begin
  FBool1 := True;
  FBool2 := False;
  Check(FIntf.FuncOutBoolOutBoolRetBool(FBool1, FBool2), 'Failed Result');
  Check(FBool1, 'Failed Bool1');   // Bool1 is out so should be received false
  Check(FBool2, 'Failed Bool2');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarBoolBoolRetBool;
begin
  FBool1 := True;
  Check(FIntf.FuncVarBoolBoolRetBool(FBool1, False), 'Failed Result');
  Check(not FBool1, 'Failed Bool1');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarBoolVarBoolRetBool;
begin
  FBool1 := True;
  FBool2 := False;
  Check(FIntf.FuncVarBoolVarBoolRetBool(FBool1, FBool2), 'Failed Result');
  Check(not FBool1, 'Failed Bool1');
  Check(FBool2, 'Failed Bool1');
end;

procedure TIdSoapInterfaceBaseTests.SetUp;
begin
  inherited;
  if not GTestClient.Active then
    begin
    GTestClient.EncodingType := GetClientEncodingType;
    GTestClient.EncodingOptions := DEFAULT_RPC_OPTIONS;
    end;
  GTestClient.XMLProvider := GetXMLProvider;
  GTestClient.Active := true;
  GTestClient.GarbageCollectObjects := false;
  FixITI(GTestClient.ITI);
  FIntf := IdSoapD4Interface(GTestClient) as IIdSoapInterfaceTestsInterface;
  if not GTestClient2.Active then
    begin
    GTestClient2.EncodingType := GetClientEncodingType;
    GTestClient2.EncodingOptions := DEFAULT_RPC_OPTIONS - [seoReferences];
    end;
  GTestClient2.Active := true;
  FixITI(GTestClient2.ITI);
  FixITI(GServer.ITI);
  GServer.XMLProvider := GetXMLProvider;
  FIntf2 := IdSoapD4Interface(GTestClient2) as IIdSoapInterfaceTestsInterface;

  GTestServerKeepAlive := false;
  GServerObject := nil;
  IdSoapProcessMessages;
end;

procedure TIdSoapInterfaceBaseTests.TearDown;
begin
  inherited;
  FIntf := NIL;
  FIntf2 := NIL;
  IdSoapProcessMessages;
end;

procedure TIdSoapInterfaceBaseTests.TestFullAsciiSet;
Var
  LString: String;
  LInt: Integer;
begin
  SetLength(LString, 256 - 32);
  for LInt := 32 to 255 do
    LString[(LInt-32)+1] := chr(LInt);
  FIntf.TestFullAsciiSet(LString);
end;


procedure TIdSoapInterfaceBaseTests.FuncBoolRetBool;
begin
  Check(FIntf.FuncBoolRetBool(False), 'False in true out failed');
  Check(not FIntf.FuncBoolRetBool(True), 'True in false out failed');
end;

procedure TIdSoapInterfaceBaseTests.FuncRetBoolToggle;
var
  LBool: Boolean;
begin
  LBool := FIntf.FuncRetBoolToggle;
  Check(LBool <> FIntf.FuncRetBoolToggle, 'Boolean result failed');
  LBool := FIntf.FuncRetBoolToggle;
  Check(LBool <> FIntf.FuncRetBoolToggle, 'Boolean result failed');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarBoolRetBool;
var
  LBool: Boolean;
  LTog: Boolean;
begin
  LTog := FIntf.FuncRetBoolToggle;
  LBool := False;
  Check(FIntf.FuncVarBoolRetBool(LBool) = LTog, 'Result <> toggle value');
  Check(LBool = True, 'Var bool did not return TRUE');
  LTog := FIntf.FuncRetBoolToggle;
  LBool := True;
  Check(FIntf.FuncVarBoolRetBool(LBool) = LTog, 'Result <> toggle value');
  Check(LBool = False, 'Var bool did not return FALSE');
end;

procedure TIdSoapInterfaceBaseTests.ProcedureCall;
begin
  FIntf.ProcCall;
  Check(True, 'This will never fail (ho ho)');
end;

procedure TIdSoapInterfaceBaseTests.TestServerErrorReporting;
begin
  FBool1 := False;
  try
    FIntf.TestServerFailureReporter;
  except
    FBool1 := True;   // the test passed
    end;
  Check(FBool1, 'Failed server error reporting procedure');
end;

// BYTE tests

procedure TIdSoapInterfaceBaseTests.FuncRetByteToggle;
begin
  FByte1 := FIntf.FuncRetByteToggle;
  Check(FByte1 in [$55, $AA], 'Invalue byte return value');
  FByte2 := FIntf.FuncRetByteToggle;
  Check(FByte2 in [$55, $AA], 'Invalue byte return value');
  Check(FByte1 <> FByte2, 'Byte result stuck');
end;

procedure TIdSoapInterfaceBaseTests.FuncByteRetByte;
begin
  Check(FIntf.FuncByteRetByte(12) = 22, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarByteRetByte;
begin
  FByte1 := 12;
  Check(FIntf.FuncVarByteRetByte(FByte1) = 22, 'Result invalid');
  Check(FByte1 = 21, 'Byte1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncByteByteRetByte;
begin
  Check(FIntf.FuncByteByteRetByte(12, 34) = 90, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarByteByteRetByte;
begin
  FByte1 := 12;
  Check(FIntf.FuncVarByteByteRetByte(FByte1, 34) = 90, 'Result invalid');
  Check(FByte1 = 56, 'Byte1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncByteVarByteRetByte;
begin
  FByte2 := 34;
  Check(FIntf.FuncByteVarByteRetByte(12, FByte2) = 90, 'Result invalid');
  Check(FByte2 = 78, 'Byte1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarByteVarByteRetByte;
begin
  FByte1 := 12;
  FByte2 := 34;
  Check(FIntf.FuncVarByteVarByteRetByte(FByte1, FByte2) = 90, 'Result invalid');
  Check(FByte1 = 56, 'Byte1 invalid');
  Check(FByte2 = 78, 'Byte2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstByteByteRetByte;
begin
  Check(FIntf.FuncConstByteByteRetByte(12, 34) = 90, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncByteConstByteRetByte;
begin
  Check(FIntf.FuncByteConstByteRetByte(12, 34) = 90, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstByteConstByteRetByte;
begin
  Check(FIntf.FuncConstByteConstByteRetByte(12, 34) = 90, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutByteByteRetByte;
begin
  FByte1 := 12;
  Check(FIntf.FuncOutByteByteRetByte(FByte1, 34) = 90, 'Result invalid');
  Check(FByte1 = 56, 'Byte1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncByteOutByteRetByte;
begin
  FByte2 := 34;
  Check(FIntf.FuncByteOutByteRetByte(12, FByte2) = 90, 'Result invalid');
  Check(FByte2 = 78, 'Byte2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutByteOutByteRetByte;
begin
  FByte1 := 12;
  FByte2 := 34;
  Check(FIntf.FuncOutByteOutByteRetByte(FByte1, FByte2) = 90, 'Result invalid');
  Check(FByte1 = 56, 'Byte1 invalid');
  Check(FByte2 = 78, 'Byte2 invalid');
end;

// CHAR tests

procedure TIdSoapInterfaceBaseTests.FuncRetCharToggle;
begin
  FChar1 := FIntf.FuncRetCharToggle;
  FChar2 := FIntf.FuncRetCharToggle;
  Check(FChar1 in [#$55, #$AA], 'Result invalid');
  Check(FChar2 in [#$55, #$AA], 'Result invalid');
  Check(FChar1 <> FChar2, 'Result stuck');
end;

procedure TIdSoapInterfaceBaseTests.FuncCharRetChar;
begin
  Check(FIntf.FuncCharRetChar(#42) = #90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCharRetChar;
begin
  FChar1 := #42;
  Check(FIntf.FuncVarCharRetChar(FChar1) = #90, 'invalid result');
  Check(FChar1 = #56, 'Char1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCharCharRetChar;
begin
  Check(FIntf.FuncCharCharRetChar(#42, #34) = #90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCharCharRetChar;
begin
  FChar1 := #42;
  Check(FIntf.FuncVarCharCharRetChar(FChar1, #34) = #90, 'invalid result');
  Check(FChar1 = #56, 'Char1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCharVarCharRetChar;
begin
  FChar2 := #34;
  Check(FIntf.FuncCharVarCharRetChar(#42, FChar2) = #90, 'invalid result');
  Check(FChar2 = #78, 'Char2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCharVarCharRetChar;
begin
  FChar1 := #42;
  FChar2 := #34;
  Check(FIntf.FuncVarCharVarCharRetChar(FChar1, FChar2) = #90, 'invalid result');
  Check(FChar1 = #56, 'Char1 invalid');
  Check(FChar2 = #78, 'Char2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCharCharRetChar;
begin
  FChar1 := #42;
  FChar2 := #34;
  Check(FIntf.FuncConstCharCharRetChar(FChar1, FChar2) = #90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncCharConstCharRetChar;
begin
  FChar1 := #42;
  FChar2 := #34;
  Check(FIntf.FuncCharConstCharRetChar(FChar1, FChar2) = #90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCharConstCharRetChar;
begin
  FChar1 := #42;
  FChar2 := #34;
  Check(FIntf.FuncConstCharConstCharRetChar(FChar1, FChar2) = #90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCharCharRetChar;
begin
  FChar1 := #42;
  FChar2 := #34;
  Check(FIntf.FuncOutCharCharRetChar(FChar1, FChar2) = #90, 'invalid result');
  Check(FChar1 = #56, 'Char1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCharOutCharRetChar;
begin
  FChar1 := #42;
  FChar2 := #34;
  Check(FIntf.FuncCharOutCharRetChar(FChar1, FChar2) = #90, 'invalid result');
  Check(FChar2 = #78, 'Char2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCharOutCharRetChar;
begin
  FChar1 := #42;
  FChar2 := #34;
  Check(FIntf.FuncOutCharOutCharRetChar(FChar1, FChar2) = #90, 'invalid result');
  Check(FChar1 = #56, 'Char1 invalid');
  Check(FChar2 = #78, 'Char2 invalid');
end;

// for signed integers, we need to check both positive and negative numbers to check for any
// signed unsigned mismatches in the engine

// SHORTINT tests

procedure TIdSoapInterfaceBaseTests.FuncRetShortIntToggle;
begin
  DefineValues(False,otSByte, True);
  FShortInt1 := FIntf.FuncRetShortIntToggle;
  FShortInt2 := FIntf.FuncRetShortIntToggle;
  Check(FShortInt1 in [Shortint(g1), Shortint(g2)], 'result invalid');
  Check(FShortInt2 in [Shortint(g1), Shortint(g2)], 'result invalid');
  Check(FShortInt1 <> FShortint2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  Check(FIntf.FuncShortIntRetShortInt(g1) = g5, 'Result invalid');
  DefineValues(False,otSByte, False);
  Check(FIntf.FuncShortIntRetShortInt(g1) = g5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  FShortInt1 := g1;
  Check(FIntf.FuncVarShortIntRetShortInt(FShortint1) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
  DefineValues(False,otSByte, False);
  FShortInt1 := g1;
  Check(FIntf.FuncVarShortIntRetShortInt(FShortint1) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortIntShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  Check(FIntf.FuncShortIntShortIntRetShortInt(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSByte, False);
  Check(FIntf.FuncShortIntShortIntRetShortInt(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarShortIntShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  FShortInt1 := g1;
  Check(FIntf.FuncVarShortIntShortIntRetShortInt(FShortint1, g2) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
  DefineValues(False,otSByte, False);
  FShortInt1 := g1;
  Check(FIntf.FuncVarShortIntShortIntRetShortInt(FShortint1, g2) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortIntVarShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  FShortInt2 := g2;
  Check(FIntf.FuncShortIntVarShortIntRetShortInt(g1, FShortint2) = g5, 'invalid result');
  Check(FShortint2 = g4, 'Shortint1 invalid');
  DefineValues(False,otSByte, False);
  FShortInt2 := g2;
  Check(FIntf.FuncShortIntVarShortIntRetShortInt(g1, FShortint2) = g5, 'invalid result');
  Check(FShortint2 = g4, 'Shortint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarShortIntVarShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  FShortInt1 := g1;
  FShortInt2 := g2;
  Check(FIntf.FuncVarShortIntVarShortIntRetShortInt(FShortint1, FShortint2) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
  Check(FShortint2 = g4, 'Shortint1 invalid');
  DefineValues(False,otSByte, False);
  FShortInt1 := g1;
  FShortInt2 := g2;
  Check(FIntf.FuncVarShortIntVarShortIntRetShortInt(FShortint1, FShortint2) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
  Check(FShortint2 = g4, 'Shortint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstShortIntShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  Check(FIntf.FuncConstShortIntShortIntRetShortInt(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSByte, False);
  Check(FIntf.FuncConstShortIntShortIntRetShortInt(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortIntConstShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  Check(FIntf.FuncShortIntConstShortIntRetShortInt(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSByte, False);
  Check(FIntf.FuncShortIntConstShortIntRetShortInt(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstShortIntConstShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  Check(FIntf.FuncConstShortIntConstShortIntRetShortInt(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSByte, False);
  Check(FIntf.FuncConstShortIntConstShortIntRetShortInt(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutShortIntShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  FShortInt1 := g1;
  Check(FIntf.FuncOutShortIntShortIntRetShortInt(FShortint1, g2) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
  DefineValues(False,otSByte, False);
  FShortInt1 := g1;
  Check(FIntf.FuncOutShortIntShortIntRetShortInt(FShortint1, g2) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortIntOutShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  FShortInt2 := g2;
  Check(FIntf.FuncShortIntOutShortIntRetShortInt(g1, FShortint2) = g5, 'invalid result');
  Check(FShortint2 = g4, 'Shortint1 invalid');
  DefineValues(False,otSByte, False);
  FShortInt2 := g2;
  Check(FIntf.FuncShortIntOutShortIntRetShortInt(g1, FShortint2) = g5, 'invalid result');
  Check(FShortint2 = g4, 'Shortint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutShortIntOutShortIntRetShortInt;
begin
  DefineValues(False,otSByte, True);
  FShortInt1 := g1;
  FShortInt2 := g2;
  Check(FIntf.FuncOutShortIntOutShortIntRetShortInt(FShortint1, FShortint2) = g5, 'invalid result');
  Check(FShortint1 = g3, 'Shortint1 invalid');
  Check(FShortint2 = g4, 'Shortint1 invalid');
end;

// WORD tests
procedure TIdSoapInterfaceBaseTests.FuncRetWordToggle;
begin
  DefineValues(False,otUWord, True);
  FWord1 := FIntf.FuncRetWordToggle;
  FWord2 := FIntf.FuncRetWordToggle;
  Check(IsIn(FWord1, g1, g2), 'result invalid');
  Check(IsIn(FWord2, g1, g2), 'result invalid');
  Check(FWord1 <> FWord2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWordRetWord;
begin
  DefineValues(False,otUWord, True);
  Check(FIntf.FuncWordRetWord(g1) = g5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarWordRetWord;
begin
  DefineValues(False,otUWord, True);
  FWord1 := g1;
  Check(FIntf.FuncVarWordRetWord(FWord1) = g5, 'invalid result');
  Check(FWord1 = g3, 'Word1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWordWordRetWord;
begin
  DefineValues(False,otUWord, True);
  Check(FIntf.FuncWordWordRetWord(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarWordWordRetWord;
begin
  DefineValues(False,otUWord, True);
  FWord1 := g1;
  Check(FIntf.FuncVarWordWordRetWord(FWord1, g2) = g5, 'invalid result');
  Check(FWord1 = g3, 'Word1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWordVarWordRetWord;
begin
  DefineValues(False,otUWord, True);
  FWord2 := g2;
  Check(FIntf.FuncWordVarWordRetWord(g1, FWord2) = g5, 'invalid result');
  Check(FWord2 = g4, 'Word2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarWordVarWordRetWord;
begin
  DefineValues(False,otUWord, True);
  FWord1 := g1;
  FWord2 := g2;
  Check(FIntf.FuncVarWordVarWordRetWord(FWord1, FWord2) = g5, 'invalid result');
  Check(FWord1 = g3, 'Word1 invalid');
  Check(FWord2 = g4, 'Word2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstWordWordRetWord;
begin
  DefineValues(False,otUWord, True);
  Check(FIntf.FuncConstWordWordRetWord(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncWordConstWordRetWord;
begin
  DefineValues(False,otUWord, True);
  Check(FIntf.FuncWordConstWordRetWord(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstWordConstWordRetWord;
begin
  DefineValues(False,otUWord, True);
  Check(FIntf.FuncConstWordConstWordRetWord(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutWordWordRetWord;
begin
  DefineValues(False,otUWord, True);
  FWord1 := g1;
  FWord2 := g2;
  Check(FIntf.FuncOutWordWordRetWord(FWord1, FWord2) = g5, 'invalid result');
  Check(FWord1 = g3, 'Word1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWordOutWordRetWord;
begin
  DefineValues(False,otUWord, True);
  FWord1 := g1;
  FWord2 := g2;
  Check(FIntf.FuncWordOutWordRetWord(FWord1, FWord2) = g5, 'invalid result');
  Check(FWord2 = g4, 'Word2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutWordOutWordRetWord;
begin
  DefineValues(False,otUWord, True);
  FWord1 := g1;
  FWord2 := g2;
  Check(FIntf.FuncOutWordOutWordRetWord(FWord1, FWord2) = g5, 'invalid result');
  Check(FWord1 = g3, 'Word1 invalid');
  Check(FWord2 = g4, 'Word2 invalid');
end;

// SMALLINT TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetSmallintToggle;
begin
  DefineValues(False,otSWord, True);
  FSmallint1 := FIntf.FuncRetSmallintToggle;
  FSmallint2 := FIntf.FuncRetSmallintToggle;
  Check(IsIn(FSmallint1, g1, g2), 'result invalid');
  Check(IsIn(FSmallint2, g1, g2), 'result invalid');
  Check(FSmallint1 <> FSmallint2, 'result invalid');
  DefineValues(False,otSWord, False);
  FSmallint1 := FIntf.FuncRetSmallintToggle;
  FSmallint2 := FIntf.FuncRetSmallintToggle;
  Check(IsIn(FSmallint1, g1, g2), 'result invalid');
  Check(IsIn(FSmallint2, g1, g2), 'result invalid');
  Check(FSmallint1 <> FSmallint2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncSmallIntRetSmallInt(g1) = g5, 'Result invalid');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncSmallIntRetSmallInt(g1) = g5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  FSmallint1 := g1;
  Check(FIntf.FuncVarSmallintRetSmallint(FSmallint1) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
  DefineValues(False,otSWord, False);
  FSmallint1 := g1;
  Check(FIntf.FuncVarSmallintRetSmallint(FSmallint1) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSmallintSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncSmallintSmallintRetSmallint(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncSmallintSmallintRetSmallint(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarSmallintSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  FSmallint1 := g1;
  Check(FIntf.FuncVarSmallintSmallintRetSmallint(FSmallint1, g2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
  DefineValues(False,otSWord, False);
  FSmallint1 := g1;
  Check(FIntf.FuncVarSmallintSmallintRetSmallint(FSmallint1, g2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSmallintVarSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  FSmallint2 := g2;
  Check(FIntf.FuncSmallintVarSmallintRetSmallint(g1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
  DefineValues(False,otSWord, False);
  FSmallint2 := g2;
  Check(FIntf.FuncSmallintVarSmallintRetSmallint(g1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarSmallintVarSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncVarSmallintVarSmallintRetSmallint(FSmallint1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
  DefineValues(False,otSWord, False);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncVarSmallintVarSmallintRetSmallint(FSmallint1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstSmallintSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncConstSmallintSmallintRetSmallint(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncConstSmallintSmallintRetSmallint(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncSmallintConstSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncSmallintConstSmallintRetSmallint(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncSmallintConstSmallintRetSmallint(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstSmallintConstSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncConstSmallintConstSmallintRetSmallint(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncConstSmallintConstSmallintRetSmallint(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutSmallintSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncOutSmallintSmallintRetSmallint(FSmallint1, g2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
  DefineValues(False,otSWord, False);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncOutSmallintSmallintRetSmallint(FSmallint1, g2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSmallintOutSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncSmallintOutSmallintRetSmallint(g1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
  DefineValues(False,otSWord, False);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncSmallintOutSmallintRetSmallint(g1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutSmallintOutSmallintRetSmallint;
begin
  DefineValues(False,otSWord, True);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncOutSmallintOutSmallintRetSmallint(FSmallint1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
  DefineValues(False,otSWord, False);
  FSmallint1 := g1;
  FSmallint2 := g2;
  Check(FIntf.FuncOutSmallintOutSmallintRetSmallint(FSmallint1, FSmallint2) = g5, 'invalid result');
  Check(FSmallint1 = g3, 'Smallint1 invalid');
  Check(FSmallint2 = g4, 'Smallint2 invalid');
end;

// CARDINAL TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetCardinalToggle;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal1 := FIntf.FuncRetCardinalToggle;
  FCardinal2 := FIntf.FuncRetCardinalToggle;
  Check(IsIn(FCardinal1, g1, g2), 'result invalid');
  Check(IsIn(FCardinal2, g1, g2), 'result invalid');
  Check(FCardinal1 <> FCardinal2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  Check(FIntf.FuncCardinalRetCardinal(g1) = g5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal1 := g1;
  Check(FIntf.FuncVarCardinalRetCardinal(FCardinal1) = g5, 'invalid result');
  Check(FCardinal1 = g3, 'Cardinal1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCardinalCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  Check(FIntf.FuncCardinalCardinalRetCardinal(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCardinalCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal1 := g1;
  Check(FIntf.FuncVarCardinalCardinalRetCardinal(FCardinal1, g2) = g5, 'invalid result');
  Check(FCardinal1 = g3, 'Cardinal1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCardinalVarCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal2 := g2;
  Check(FIntf.FuncCardinalVarCardinalRetCardinal(g1, FCardinal2) = g5, 'invalid result');
  Check(FCardinal2 = g4, 'Cardinal2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCardinalVarCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal1 := g1;
  FCardinal2 := g2;
  Check(FIntf.FuncVarCardinalVarCardinalRetCardinal(FCardinal1, FCardinal2) = g5, 'invalid result');
  Check(FCardinal1 = g3, 'Cardinal1 invalid');
  Check(FCardinal2 = g4, 'Cardinal2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCardinalCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  Check(FIntf.FuncConstCardinalCardinalRetCardinal(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncCardinalConstCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  Check(FIntf.FuncCardinalConstCardinalRetCardinal(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCardinalConstCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  Check(FIntf.FuncConstCardinalConstCardinalRetCardinal(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCardinalCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal1 := g1;
  FCardinal2 := g2;
  Check(FIntf.FuncOutCardinalCardinalRetCardinal(FCardinal1, FCardinal2) = g5, 'invalid result');
  Check(FCardinal1 = g3, 'Cardinal1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCardinalOutCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal1 := g1;
  FCardinal2 := g2;
  Check(FIntf.FuncCardinalOutCardinalRetCardinal(FCardinal1, FCardinal2) = g5, 'invalid result');
  Check(FCardinal2 = g4, 'Cardinal2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCardinalOutCardinalRetCardinal;
begin
{$IFDEF DELPHI4}
  DefineValues(True,otSLong, True);
{$ELSE}
  DefineValues(False,otULong, True);
{$ENDIF}
  FCardinal1 := g1;
  FCardinal2 := g2;
  Check(FIntf.FuncOutCardinalOutCardinalRetCardinal(FCardinal1, FCardinal2) = g5, 'invalid result');
  Check(FCardinal1 = g3, 'Cardinal1 invalid');
  Check(FCardinal2 = g4, 'Cardinal2 invalid');
end;

// INTEGER TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetIntegerToggle;
begin
  DefineValues(False,otSLong, True);
  FInteger1 := FIntf.FuncRetIntegerToggle;
  FInteger2 := FIntf.FuncRetIntegerToggle;
  Check(IsIn(FInteger1, g1, g2), 'result invalid');
  Check(IsIn(FInteger2, g1, g2), 'result invalid');
  Check(FInteger1 <> FInteger2, 'result invalid');
  DefineValues(False,otSWord, False);
  FInteger1 := FIntf.FuncRetIntegerToggle;
  FInteger2 := FIntf.FuncRetIntegerToggle;
  Check(IsIn(FInteger1, g1, g2), 'result invalid');
  Check(IsIn(FInteger2, g1, g2), 'result invalid');
  Check(FInteger1 <> FInteger2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncIntegerRetInteger(g1) = g5, 'Result invalid');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncIntegerRetInteger(g1) = g5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  FInteger1 := g1;
  Check(FIntf.FuncVarIntegerRetInteger(FInteger1) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
  DefineValues(False,otSWord, False);
  FInteger1 := g1;
  Check(FIntf.FuncVarIntegerRetInteger(FInteger1) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncIntegerIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncIntegerIntegerRetInteger(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncIntegerIntegerRetInteger(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarIntegerIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  FInteger1 := g1;
  Check(FIntf.FuncVarIntegerIntegerRetInteger(FInteger1, g2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
  DefineValues(False,otSWord, False);
  FInteger1 := g1;
  Check(FIntf.FuncVarIntegerIntegerRetInteger(FInteger1, g2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncIntegerVarIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  FInteger2 := g2;
  Check(FIntf.FuncIntegerVarIntegerRetInteger(g1, FInteger2) = g5, 'invalid result');
  Check(FInteger2 = g4, 'Integer2 invalid');
  DefineValues(False,otSWord, False);
  FInteger2 := g2;
  Check(FIntf.FuncIntegerVarIntegerRetInteger(g1, FInteger2) = g5, 'invalid result');
  Check(FInteger2 = g4, 'Integer2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarIntegerVarIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncVarIntegerVarIntegerRetInteger(FInteger1, FInteger2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
  Check(FInteger2 = g4, 'Integer2 invalid');
  DefineValues(False,otSWord, False);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncVarIntegerVarIntegerRetInteger(FInteger1, FInteger2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
  Check(FInteger2 = g4, 'Integer2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstIntegerIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncConstIntegerIntegerRetInteger(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncConstIntegerIntegerRetInteger(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncIntegerConstIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncIntegerConstIntegerRetInteger(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncIntegerConstIntegerRetInteger(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstIntegerConstIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  Check(FIntf.FuncConstIntegerConstIntegerRetInteger(g1, g2) = g5, 'invalid result');
  DefineValues(False,otSWord, False);
  Check(FIntf.FuncConstIntegerConstIntegerRetInteger(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutIntegerIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncOutIntegerIntegerRetInteger(FInteger1, g2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
  DefineValues(False,otSWord, False);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncOutIntegerIntegerRetInteger(FInteger1, g2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncIntegerOutIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncIntegerOutIntegerRetInteger(g1, FInteger2) = g5, 'invalid result');
  Check(FInteger2 = g4, 'Integer2 invalid');
  DefineValues(False,otSWord, False);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncIntegerOutIntegerRetInteger(g1, FInteger2) = g5, 'invalid result');
  Check(FInteger2 = g4, 'Integer2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutIntegerOutIntegerRetInteger;
begin
  DefineValues(False,otSWord, True);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncOutIntegerOutIntegerRetInteger(FInteger1, FInteger2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
  Check(FInteger2 = g4, 'Integer2 invalid');
  DefineValues(False,otSWord, False);
  FInteger1 := g1;
  FInteger2 := g2;
  Check(FIntf.FuncOutIntegerOutIntegerRetInteger(FInteger1, FInteger2) = g5, 'invalid result');
  Check(FInteger1 = g3, 'Integer1 invalid');
  Check(FInteger2 = g4, 'Integer2 invalid');
end;

// INT64 TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetInt64Toggle;
begin
  DefineInt64(True);
  FInt641 := FIntf.FuncRetInt64Toggle;
  FInt642 := FIntf.FuncRetInt64Toggle;
  Check(IsIn(FInt641, g1, g2), 'result invalid');
  Check(IsIn(FInt642, g1, g2), 'result invalid');
  Check(FInt641 <> FInt642, 'result invalid');
  DefineInt64(False);
  FInt641 := FIntf.FuncRetInt64Toggle;
  FInt642 := FIntf.FuncRetInt64Toggle;
  Check(IsIn(FInt641, g1, g2), 'result invalid');
  Check(IsIn(FInt642, g1, g2), 'result invalid');
  Check(FInt641 <> FInt642, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncInt64RetInt64;
begin
  DefineInt64(True);
  Check(FIntf.FuncInt64RetInt64(g1) = g5, 'Result invalid');
  DefineInt64(False);
  Check(FIntf.FuncInt64RetInt64(g1) = g5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarInt64RetInt64;
begin
  DefineInt64(True);
  FInt641 := g1;
  Check(FIntf.FuncVarInt64RetInt64(FInt641) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
  DefineInt64(False);
  FInt641 := g1;
  Check(FIntf.FuncVarInt64RetInt64(FInt641) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncInt64Int64RetInt64;
begin
  DefineInt64(True);
  Check(FIntf.FuncInt64Int64RetInt64(g1, g2) = g5, 'invalid result');
  DefineInt64(False);
  Check(FIntf.FuncInt64Int64RetInt64(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarInt64Int64RetInt64;
begin
  DefineInt64(True);
  FInt641 := g1;
  Check(FIntf.FuncVarInt64Int64RetInt64(FInt641, g2) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
  DefineInt64(False);
  FInt641 := g1;
  Check(FIntf.FuncVarInt64Int64RetInt64(FInt641, g2) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncInt64VarInt64RetInt64;
begin
  DefineInt64(True);
  FInt642 := g2;
  Check(FIntf.FuncInt64VarInt64RetInt64(g1, FInt642) = g5, 'invalid result');
  Check(FInt642 = g4, 'Int642 invalid');
  DefineInt64(False);
  FInt642 := g2;
  Check(FIntf.FuncInt64VarInt64RetInt64(g1, FInt642) = g5, 'invalid result');
  Check(FInt642 = g4, 'Int642 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarInt64VarInt64RetInt64;
begin
  DefineInt64(True);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncVarInt64VarInt64RetInt64(FInt641, FInt642) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
  Check(FInt642 = g4, 'Int642 invalid');
  DefineInt64(False);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncVarInt64VarInt64RetInt64(FInt641, FInt642) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
  Check(FInt642 = g4, 'Int642 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstInt64Int64RetInt64;
begin
  DefineInt64(True);
  Check(FIntf.FuncConstInt64Int64RetInt64(g1, g2) = g5, 'invalid result');
  DefineInt64(False);
  Check(FIntf.FuncConstInt64Int64RetInt64(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncInt64ConstInt64RetInt64;
begin
  DefineInt64(True);
  Check(FIntf.FuncInt64ConstInt64RetInt64(g1, g2) = g5, 'invalid result');
  DefineInt64(False);
  Check(FIntf.FuncInt64ConstInt64RetInt64(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstInt64ConstInt64RetInt64;
begin
  DefineInt64(True);
  Check(FIntf.FuncConstInt64ConstInt64RetInt64(g1, g2) = g5, 'invalid result');
  DefineInt64(False);
  Check(FIntf.FuncConstInt64ConstInt64RetInt64(g1, g2) = g5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutInt64Int64RetInt64;
begin
  DefineInt64(True);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncOutInt64Int64RetInt64(FInt641, g2) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
  DefineInt64(False);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncOutInt64Int64RetInt64(FInt641, g2) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncInt64OutInt64RetInt64;
begin
  DefineInt64(True);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncInt64OutInt64RetInt64(g1, FInt642) = g5, 'invalid result');
  Check(FInt642 = g4, 'Int642 invalid');
  DefineInt64(False);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncInt64OutInt64RetInt64(g1, FInt642) = g5, 'invalid result');
  Check(FInt642 = g4, 'Int642 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutInt64OutInt64RetInt64;
begin
  DefineInt64(True);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncOutInt64OutInt64RetInt64(FInt641, FInt642) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
  Check(FInt642 = g4, 'Int642 invalid');
  DefineInt64(False);
  FInt641 := g1;
  FInt642 := g2;
  Check(FIntf.FuncOutInt64OutInt64RetInt64(FInt641, FInt642) = g5, 'invalid result');
  Check(FInt641 = g3, 'Int641 invalid');
  Check(FInt642 = g4, 'Int642 invalid');
end;

// SINGLE TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetSingleToggle;
begin
  DefineReal(ftSingle, True);
  FSingle1 := FIntf.FuncRetSingleToggle;
  FSingle2 := FIntf.FuncRetSingleToggle;
  Check(RealIsIn(FSingle1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FSingle2, gR1, gR2), 'result invalid');
  Check(FSingle1 <> FSingle2, 'result invalid');
  DefineReal(ftSingle, False);
  FSingle1 := FIntf.FuncRetSingleToggle;
  FSingle2 := FIntf.FuncRetSingleToggle;
  Check(RealIsIn(FSingle1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FSingle2, gR1, gR2), 'result invalid');
  Check(FSingle1 <> FSingle2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  Check(SameReal(FIntf.FuncSingleRetSingle(gR1), gR5), 'Result invalid');
  DefineReal(ftSingle, False);
  Check(SameReal(FIntf.FuncSingleRetSingle(gR1), gR5), 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  FSingle1 := gR1;
  Check(SameReal(FIntf.FuncVarSingleRetSingle(FSingle1), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
  DefineReal(ftSingle, False);
  FSingle1 := gR1;
  Check(SameReal(FIntf.FuncVarSingleRetSingle(FSingle1), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSingleSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  Check(SameReal(FIntf.FuncSingleSingleRetSingle(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftSingle, False);
  Check(SameReal(FIntf.FuncSingleSingleRetSingle(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarSingleSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  FSingle1 := gR1;
  Check(SameReal(FIntf.FuncVarSingleSingleRetSingle(FSingle1, gR2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
  DefineReal(ftSingle, False);
  FSingle1 := gR1;
  Check(SameReal(FIntf.FuncVarSingleSingleRetSingle(FSingle1, gR2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSingleVarSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncSingleVarSingleRetSingle(gR1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
  DefineReal(ftSingle, False);
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncSingleVarSingleRetSingle(gR1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarSingleVarSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncVarSingleVarSingleRetSingle(FSingle1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
  DefineReal(ftSingle, False);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncVarSingleVarSingleRetSingle(FSingle1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstSingleSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  Check(SameReal(FIntf.FuncConstSingleSingleRetSingle(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftSingle, False);
  Check(SameReal(FIntf.FuncConstSingleSingleRetSingle(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncSingleConstSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  Check(SameReal(FIntf.FuncSingleConstSingleRetSingle(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftSingle, False);
  Check(SameReal(FIntf.FuncSingleConstSingleRetSingle(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstSingleConstSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  Check(SameReal(FIntf.FuncConstSingleConstSingleRetSingle(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftSingle, False);
  Check(SameReal(FIntf.FuncConstSingleConstSingleRetSingle(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutSingleSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncOutSingleSingleRetSingle(FSingle1, gR2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
  DefineReal(ftSingle, False);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncOutSingleSingleRetSingle(FSingle1, gR2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncSingleOutSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncSingleOutSingleRetSingle(gR1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
  DefineReal(ftSingle, False);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncSingleOutSingleRetSingle(gR1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutSingleOutSingleRetSingle;
begin
  DefineReal(ftSingle, True);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncOutSingleOutSingleRetSingle(FSingle1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
  DefineReal(ftSingle, False);
  FSingle1 := gR1;
  FSingle2 := gR2;
  Check(SameReal(FIntf.FuncOutSingleOutSingleRetSingle(FSingle1, FSingle2), gR5), 'invalid result');
  Check(SameReal(FSingle1, gR3), 'Single1 invalid');
  Check(SameReal(FSingle2, gR4), 'Single2 invalid');
end;

// DOUBLE TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetDoubleToggle;
begin
  DefineReal(ftDouble, True);
  FDouble1 := FIntf.FuncRetDoubleToggle;
  FDouble2 := FIntf.FuncRetDoubleToggle;
  Check(RealIsIn(FDouble1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FDouble2, gR1, gR2), 'result invalid');
  Check(FDouble1 <> FDouble2, 'result invalid');
  DefineReal(ftDouble, False);
  FDouble1 := FIntf.FuncRetDoubleToggle;
  FDouble2 := FIntf.FuncRetDoubleToggle;
  Check(RealIsIn(FDouble1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FDouble2, gR1, gR2), 'result invalid');
  Check(FDouble1 <> FDouble2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  Check(SameReal(FIntf.FuncDoubleRetDouble(gR1), gR5), 'Result invalid');
  DefineReal(ftDouble, False);
  Check(SameReal(FIntf.FuncDoubleRetDouble(gR1), gR5), 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  FDouble1 := gR1;
  Check(SameReal(FIntf.FuncVarDoubleRetDouble(FDouble1), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
  DefineReal(ftDouble, False);
  FDouble1 := gR1;
  Check(SameReal(FIntf.FuncVarDoubleRetDouble(FDouble1), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncDoubleDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  Check(SameReal(FIntf.FuncDoubleDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftDouble, False);
  Check(SameReal(FIntf.FuncDoubleDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarDoubleDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  FDouble1 := gR1;
  Check(SameReal(FIntf.FuncVarDoubleDoubleRetDouble(FDouble1, gR2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
  DefineReal(ftDouble, False);
  FDouble1 := gR1;
  Check(SameReal(FIntf.FuncVarDoubleDoubleRetDouble(FDouble1, gR2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncDoubleVarDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncDoubleVarDoubleRetDouble(gR1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
  DefineReal(ftDouble, False);
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncDoubleVarDoubleRetDouble(gR1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarDoubleVarDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncVarDoubleVarDoubleRetDouble(FDouble1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
  DefineReal(ftDouble, False);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncVarDoubleVarDoubleRetDouble(FDouble1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstDoubleDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  Check(SameReal(FIntf.FuncConstDoubleDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftDouble, False);
  Check(SameReal(FIntf.FuncConstDoubleDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncDoubleConstDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  Check(SameReal(FIntf.FuncDoubleConstDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftDouble, False);
  Check(SameReal(FIntf.FuncDoubleConstDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstDoubleConstDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  Check(SameReal(FIntf.FuncConstDoubleConstDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftDouble, False);
  Check(SameReal(FIntf.FuncConstDoubleConstDoubleRetDouble(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutDoubleDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncOutDoubleDoubleRetDouble(FDouble1, gR2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
  DefineReal(ftDouble, False);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncOutDoubleDoubleRetDouble(FDouble1, gR2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncDoubleOutDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncDoubleOutDoubleRetDouble(gR1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
  DefineReal(ftDouble, False);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncDoubleOutDoubleRetDouble(gR1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutDoubleOutDoubleRetDouble;
begin
  DefineReal(ftDouble, True);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncOutDoubleOutDoubleRetDouble(FDouble1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
  DefineReal(ftDouble, False);
  FDouble1 := gR1;
  FDouble2 := gR2;
  Check(SameReal(FIntf.FuncOutDoubleOutDoubleRetDouble(FDouble1, FDouble2), gR5), 'invalid result');
  Check(SameReal(FDouble1, gR3), 'Double1 invalid');
  Check(SameReal(FDouble2, gR4), 'Double2 invalid');
end;

// COMP TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetCompToggle;
begin
  DefineReal(ftComp, True);
  FComp1 := FIntf.FuncRetCompToggle;
  FComp2 := FIntf.FuncRetCompToggle;
  Check(RealIsIn(FComp1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FComp2, gR1, gR2), 'result invalid');
  Check(FComp1 <> FComp2, 'result invalid');
  DefineReal(ftComp, False);
  FComp1 := FIntf.FuncRetCompToggle;
  FComp2 := FIntf.FuncRetCompToggle;
  Check(RealIsIn(FComp1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FComp2, gR1, gR2), 'result invalid');
  Check(FComp1 <> FComp2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCompRetComp;
begin
  DefineReal(ftComp, True);
  Check(SameReal(FIntf.FuncCompRetComp(gR1), gR5), 'Result invalid');
  DefineReal(ftComp, False);
  Check(SameReal(FIntf.FuncCompRetComp(gR1), gR5), 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCompRetComp;
begin
  DefineReal(ftComp, True);
  FComp1 := gR1;
  Check(SameReal(FIntf.FuncVarCompRetComp(FComp1), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
  DefineReal(ftComp, False);
  FComp1 := gR1;
  Check(SameReal(FIntf.FuncVarCompRetComp(FComp1), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCompCompRetComp;
begin
  DefineReal(ftComp, True);
  Check(SameReal(FIntf.FuncCompCompRetComp(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftComp, False);
  Check(SameReal(FIntf.FuncCompCompRetComp(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCompCompRetComp;
begin
  DefineReal(ftComp, True);
  FComp1 := gR1;
  Check(SameReal(FIntf.FuncVarCompCompRetComp(FComp1, gR2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
  DefineReal(ftComp, False);
  FComp1 := gR1;
  Check(SameReal(FIntf.FuncVarCompCompRetComp(FComp1, gR2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCompVarCompRetComp;
begin
  DefineReal(ftComp, True);
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncCompVarCompRetComp(gR1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
  DefineReal(ftComp, False);
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncCompVarCompRetComp(gR1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCompVarCompRetComp;
begin
  DefineReal(ftComp, True);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncVarCompVarCompRetComp(FComp1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
  DefineReal(ftComp, False);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncVarCompVarCompRetComp(FComp1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCompCompRetComp;
begin
  DefineReal(ftComp, True);
  Check(SameReal(FIntf.FuncConstCompCompRetComp(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftComp, False);
  Check(SameReal(FIntf.FuncConstCompCompRetComp(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncCompConstCompRetComp;
begin
  DefineReal(ftComp, True);
  Check(SameReal(FIntf.FuncCompConstCompRetComp(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftComp, False);
  Check(SameReal(FIntf.FuncCompConstCompRetComp(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCompConstCompRetComp;
begin
  DefineReal(ftComp, True);
  Check(SameReal(FIntf.FuncConstCompConstCompRetComp(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftComp, False);
  Check(SameReal(FIntf.FuncConstCompConstCompRetComp(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCompCompRetComp;
begin
  DefineReal(ftComp, True);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncOutCompCompRetComp(FComp1, gR2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
  DefineReal(ftComp, False);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncOutCompCompRetComp(FComp1, gR2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCompOutCompRetComp;
begin
  DefineReal(ftComp, True);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncCompOutCompRetComp(gR1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
  DefineReal(ftComp, False);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncCompOutCompRetComp(gR1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCompOutCompRetComp;
begin
  DefineReal(ftComp, True);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncOutCompOutCompRetComp(FComp1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
  DefineReal(ftComp, False);
  FComp1 := gR1;
  FComp2 := gR2;
  Check(SameReal(FIntf.FuncOutCompOutCompRetComp(FComp1, FComp2), gR5), 'invalid result');
  Check(SameReal(FComp1, gR3), 'Comp1 invalid');
  Check(SameReal(FComp2, gR4), 'Comp2 invalid');
end;

// EXTENDED TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetExtendedToggle;
begin
  DefineReal(ftExtended, True);
  FExtended1 := FIntf.FuncRetExtendedToggle;
  FExtended2 := FIntf.FuncRetExtendedToggle;
  Check(RealIsIn(FExtended1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FExtended2, gR1, gR2), 'result invalid');
  Check(FExtended1 <> FExtended2, 'result invalid');
  DefineReal(ftExtended, False);
  FExtended1 := FIntf.FuncRetExtendedToggle;
  FExtended2 := FIntf.FuncRetExtendedToggle;
  Check(RealIsIn(FExtended1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FExtended2, gR1, gR2), 'result invalid');
  Check(FExtended1 <> FExtended2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  Check(SameReal(FIntf.FuncExtendedRetExtended(gR1), gR5), 'Result invalid');
  DefineReal(ftExtended, False);
  Check(SameReal(FIntf.FuncExtendedRetExtended(gR1), gR5), 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  FExtended1 := gR1;
  Check(SameReal(FIntf.FuncVarExtendedRetExtended(FExtended1), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
  DefineReal(ftExtended, False);
  FExtended1 := gR1;
  Check(SameReal(FIntf.FuncVarExtendedRetExtended(FExtended1), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncExtendedExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  Check(SameReal(FIntf.FuncExtendedExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftExtended, False);
  Check(SameReal(FIntf.FuncExtendedExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarExtendedExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  FExtended1 := gR1;
  Check(SameReal(FIntf.FuncVarExtendedExtendedRetExtended(FExtended1, gR2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
  DefineReal(ftExtended, False);
  FExtended1 := gR1;
  Check(SameReal(FIntf.FuncVarExtendedExtendedRetExtended(FExtended1, gR2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncExtendedVarExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncExtendedVarExtendedRetExtended(gR1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
  DefineReal(ftExtended, False);
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncExtendedVarExtendedRetExtended(gR1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarExtendedVarExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncVarExtendedVarExtendedRetExtended(FExtended1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
  DefineReal(ftExtended, False);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncVarExtendedVarExtendedRetExtended(FExtended1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstExtendedExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  Check(SameReal(FIntf.FuncConstExtendedExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftExtended, False);
  Check(SameReal(FIntf.FuncConstExtendedExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncExtendedConstExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  Check(SameReal(FIntf.FuncExtendedConstExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftExtended, False);
  Check(SameReal(FIntf.FuncExtendedConstExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstExtendedConstExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  Check(SameReal(FIntf.FuncConstExtendedConstExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftExtended, False);
  Check(SameReal(FIntf.FuncConstExtendedConstExtendedRetExtended(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutExtendedExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncOutExtendedExtendedRetExtended(FExtended1, gR2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
  DefineReal(ftExtended, False);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncOutExtendedExtendedRetExtended(FExtended1, gR2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncExtendedOutExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncExtendedOutExtendedRetExtended(gR1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
  DefineReal(ftExtended, False);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncExtendedOutExtendedRetExtended(gR1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutExtendedOutExtendedRetExtended;
begin
  DefineReal(ftExtended, True);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncOutExtendedOutExtendedRetExtended(FExtended1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
  DefineReal(ftExtended, False);
  FExtended1 := gR1;
  FExtended2 := gR2;
  Check(SameReal(FIntf.FuncOutExtendedOutExtendedRetExtended(FExtended1, FExtended2), gR5), 'invalid result');
  Check(SameReal(FExtended1, gR3), 'Extended1 invalid');
  Check(SameReal(FExtended2, gR4), 'Extended2 invalid');
end;

// CURRENCY TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetCurrencyToggle;
begin
  DefineReal(ftCurr, True);
  FCurrency1 := FIntf.FuncRetCurrencyToggle;
  FCurrency2 := FIntf.FuncRetCurrencyToggle;
  Check(RealIsIn(FCurrency1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FCurrency2, gR1, gR2), 'result invalid');
  Check(FCurrency1 <> FCurrency2, 'result invalid');
  DefineReal(ftCurr, False);
  FCurrency1 := FIntf.FuncRetCurrencyToggle;
  FCurrency2 := FIntf.FuncRetCurrencyToggle;
  Check(RealIsIn(FCurrency1, gR1, gR2), 'result invalid');
  Check(RealIsIn(FCurrency2, gR1, gR2), 'result invalid');
  Check(FCurrency1 <> FCurrency2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  Check(SameReal(FIntf.FuncCurrencyRetCurrency(gR1), gR5), 'Result invalid');
  DefineReal(ftCurr, False);
  Check(SameReal(FIntf.FuncCurrencyRetCurrency(gR1), gR5), 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  FCurrency1 := gR1;
  Check(SameReal(FIntf.FuncVarCurrencyRetCurrency(FCurrency1), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
  DefineReal(ftCurr, False);
  FCurrency1 := gR1;
  Check(SameReal(FIntf.FuncVarCurrencyRetCurrency(FCurrency1), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCurrencyCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  Check(SameReal(FIntf.FuncCurrencyCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftCurr, False);
  Check(SameReal(FIntf.FuncCurrencyCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCurrencyCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  FCurrency1 := gR1;
  Check(SameReal(FIntf.FuncVarCurrencyCurrencyRetCurrency(FCurrency1, gR2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
  DefineReal(ftCurr, False);
  FCurrency1 := gR1;
  Check(SameReal(FIntf.FuncVarCurrencyCurrencyRetCurrency(FCurrency1, gR2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCurrencyVarCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncCurrencyVarCurrencyRetCurrency(gR1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
  DefineReal(ftCurr, False);
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncCurrencyVarCurrencyRetCurrency(gR1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarCurrencyVarCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncVarCurrencyVarCurrencyRetCurrency(FCurrency1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
  DefineReal(ftCurr, False);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncVarCurrencyVarCurrencyRetCurrency(FCurrency1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCurrencyCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  Check(SameReal(FIntf.FuncConstCurrencyCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftCurr, False);
  Check(SameReal(FIntf.FuncConstCurrencyCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncCurrencyConstCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  Check(SameReal(FIntf.FuncCurrencyConstCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftCurr, False);
  Check(SameReal(FIntf.FuncCurrencyConstCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstCurrencyConstCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  Check(SameReal(FIntf.FuncConstCurrencyConstCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
  DefineReal(ftCurr, False);
  Check(SameReal(FIntf.FuncConstCurrencyConstCurrencyRetCurrency(gR1, gR2), gR5), 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCurrencyCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncOutCurrencyCurrencyRetCurrency(FCurrency1, gR2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
  DefineReal(ftCurr, False);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncOutCurrencyCurrencyRetCurrency(FCurrency1, gR2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncCurrencyOutCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncCurrencyOutCurrencyRetCurrency(gR1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
  DefineReal(ftCurr, False);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncCurrencyOutCurrencyRetCurrency(gR1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutCurrencyOutCurrencyRetCurrency;
begin
  DefineReal(ftCurr, True);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncOutCurrencyOutCurrencyRetCurrency(FCurrency1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
  DefineReal(ftCurr, False);
  FCurrency1 := gR1;
  FCurrency2 := gR2;
  Check(SameReal(FIntf.FuncOutCurrencyOutCurrencyRetCurrency(FCurrency1, FCurrency2), gR5), 'invalid result');
  Check(SameReal(FCurrency1, gR3), 'Currency1 invalid');
  Check(SameReal(FCurrency2, gR4), 'Currency2 invalid');
end;

// SHORTSTRING TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetShortStringToggle;
begin
  DefineString(tkString);
  FShortString1 := FIntf.FuncRetShortStringToggle;
  FShortString2 := FIntf.FuncRetShortStringToggle;
  Check(IsStringIn(FShortString1, gS1, gS2), 'result invalid');
  Check(IsStringIn(FShortString2, gS1, gS2), 'result invalid');
  Check(FShortString1 <> FShortString2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortStringRetShortString;
begin
  DefineString(tkString);
  Check(FIntf.FuncShortStringRetShortString(gS1) = gS5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarShortStringRetShortString;
begin
  DefineString(tkString);
  FShortString1 := gS1;
  Check(FIntf.FuncVarShortStringRetShortString(FShortString1) = gS5, 'invalid result');
  Check(FShortString1 = gS3, 'ShortString1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortStringShortStringRetShortString;
begin
  DefineString(tkString);
  Check(FIntf.FuncShortStringShortStringRetShortString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarShortStringShortStringRetShortString;
begin
  DefineString(tkString);
  FShortString1 := gS1;
  Check(FIntf.FuncVarShortStringShortStringRetShortString(FShortString1, gS2) = gS5, 'invalid result');
  Check(FShortString1 = gS3, 'ShortString1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortStringVarShortStringRetShortString;
begin
  DefineString(tkString);
  FShortString2 := gS2;
  Check(FIntf.FuncShortStringVarShortStringRetShortString(gS1, FShortString2) = gS5, 'invalid result');
  Check(FShortString2 = gS4, 'ShortString2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarShortStringVarShortStringRetShortString;
begin
  DefineString(tkString);
  FShortString1 := gS1;
  FShortString2 := gS2;
  Check(FIntf.FuncVarShortStringVarShortStringRetShortString(FShortString1, FShortString2) = gS5, 'invalid result');
  Check(FShortString1 = gS3, 'ShortString1 invalid');
  Check(FShortString2 = gS4, 'ShortString2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstShortStringShortStringRetShortString;
begin
  DefineString(tkString);
  Check(FIntf.FuncConstShortStringShortStringRetShortString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortStringConstShortStringRetShortString;
begin
  DefineString(tkString);
  Check(FIntf.FuncShortStringConstShortStringRetShortString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstShortStringConstShortStringRetShortString;
begin
  DefineString(tkString);
  Check(FIntf.FuncConstShortStringConstShortStringRetShortString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutShortStringShortStringRetShortString;
begin
  DefineString(tkString);
  FShortString1 := gS1;
  FShortString2 := gS2;
  Check(FIntf.FuncOutShortStringShortStringRetShortString(FShortString1, gS2) = gS5, 'invalid result');
  Check(FShortString1 = gS3, 'ShortString1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncShortStringOutShortStringRetShortString;
begin
  DefineString(tkString);
  FShortString1 := gS1;
  FShortString2 := gS2;
  Check(FIntf.FuncShortStringOutShortStringRetShortString(gS1, FShortString2) = gS5, 'invalid result');
  Check(FShortString2 = gS4, 'ShortString2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutShortStringOutShortStringRetShortString;
begin
  DefineString(tkString);
  FShortString1 := gS1;
  FShortString2 := gS2;
  Check(FIntf.FuncOutShortStringOutShortStringRetShortString(FShortString1, FShortString2) = gS5, 'invalid result');
  Check(FShortString1 = gS3, 'ShortString1 invalid');
  Check(FShortString2 = gS4, 'ShortString2 invalid');
end;

// LONGSTRING TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetStringToggle;
begin
  DefineString(tkString);
  FString1 := FIntf.FuncRetStringToggle;
  FString2 := FIntf.FuncRetStringToggle;
  Check(IsStringIn(FString1, gS1, gS2), 'result invalid');
  Check(IsStringIn(FString2, gS1, gS2), 'result invalid');
  Check(FString1 <> FString2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncStringRetString;
begin
  DefineString(tkString);
  Check(FIntf.FuncStringRetString(gS1) = gS5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarStringRetString;
begin
  DefineString(tkString);
  FString1 := gS1;
  Check(FIntf.FuncVarStringRetString(FString1) = gS5, 'invalid result');
  Check(FString1 = gS3, 'String1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncStringStringRetString;
begin
  DefineString(tkString);
  Check(FIntf.FuncStringStringRetString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarStringStringRetString;
begin
  DefineString(tkString);
  FString1 := gS1;
  Check(FIntf.FuncVarStringStringRetString(FString1, gS2) = gS5, 'invalid result');
  Check(FString1 = gS3, 'String1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncStringVarStringRetString;
begin
  DefineString(tkString);
  FString2 := gS2;
  Check(FIntf.FuncStringVarStringRetString(gS1, FString2) = gS5, 'invalid result');
  Check(FString2 = gS4, 'String2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarStringVarStringRetString;
begin
  DefineString(tkString);
  FString1 := gS1;
  FString2 := gS2;
  Check(FIntf.FuncVarStringVarStringRetString(FString1, FString2) = gS5, 'invalid result');
  Check(FString1 = gS3, 'String1 invalid');
  Check(FString2 = gS4, 'String2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstStringStringRetString;
begin
  DefineString(tkString);
  Check(FIntf.FuncConstStringStringRetString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncStringConstStringRetString;
begin
  DefineString(tkString);
  Check(FIntf.FuncStringConstStringRetString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstStringConstStringRetString;
begin
  DefineString(tkString);
  Check(FIntf.FuncConstStringConstStringRetString(gS1, gS2) = gS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutStringStringRetString;
begin
  DefineString(tkString);
  FString1 := gS1;
  FString2 := gS2;
  Check(FIntf.FuncOutStringStringRetString(FString1, gS2) = gS5, 'invalid result');
  Check(FString1 = gS3, 'String1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncStringOutStringRetString;
begin
  DefineString(tkString);
  FString1 := gS1;
  FString2 := gS2;
  Check(FIntf.FuncStringOutStringRetString(gS1, FString2) = gS5, 'invalid result');
  Check(FString2 = gS4, 'String2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutStringOutStringRetString;
begin
  DefineString(tkString);
  FString1 := gS1;
  FString2 := gS2;
  Check(FIntf.FuncOutStringOutStringRetString(FString1, FString2) = gS5, 'invalid result');
  Check(FString1 = gS3, 'String1 invalid');
  Check(FString2 = gS4, 'String2 invalid');
end;

// WIDESTRING TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetWideStringToggle;
begin
  DefineString(tkWString);
  FWideString1 := FIntf.FuncRetWideStringToggle;
  FWideString2 := FIntf.FuncRetWideStringToggle;
  Check(IsStringInW(FWideString1, gWS1, gWS2), 'result invalid');
  Check(IsStringInW(FWideString2, gWS1, gWS2), 'result invalid');
  Check(FWideString1 <> FWideString2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWideStringRetWideString;
begin
  DefineString(tkWString);
  Check(FIntf.FuncWideStringRetWideString(gWS1) = gWS5, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarWideStringRetWideString;
begin
  DefineString(tkWString);
  FWideString1 := gWS1;
  Check(FIntf.FuncVarWideStringRetWideString(FWideString1) = gWS5, 'invalid result');
  Check(FWideString1 = gWS3, 'WideString1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWideStringWideStringRetWideString;
begin
  DefineString(tkWString);
  Check(FIntf.FuncWideStringWideStringRetWideString(gWS1, gWS2) = gWS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarWideStringWideStringRetWideString;
begin
  DefineString(tkWString);
  FWideString1 := gWS1;
  Check(FIntf.FuncVarWideStringWideStringRetWideString(FWideString1, gWS2) = gWS5, 'invalid result');
  Check(FWideString1 = gWS3, 'WideString1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWideStringVarWideStringRetWideString;
begin
  DefineString(tkWString);
  FWideString2 := gWS2;
  Check(FIntf.FuncWideStringVarWideStringRetWideString(gWS1, FWideString2) = gWS5, 'invalid result');
  Check(FWideString2 = gWS4, 'WideString2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarWideStringVarWideStringRetWideString;
begin
  DefineString(tkWString);
  FWideString1 := gWS1;
  FWideString2 := gWS2;
  Check(FIntf.FuncVarWideStringVarWideStringRetWideString(FWideString1, FWideString2) = gWS5, 'invalid result');
  Check(FWideString1 = gWS3, 'WideString1 invalid');
  Check(FWideString2 = gWS4, 'WideString2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstWideStringWideStringRetWideString;
begin
  DefineString(tkWString);
  Check(FIntf.FuncConstWideStringWideStringRetWideString(gWS1, gWS2) = gWS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncWideStringConstWideStringRetWideString;
begin
  DefineString(tkWString);
  Check(FIntf.FuncWideStringConstWideStringRetWideString(gWS1, gWS2) = gWS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstWideStringConstWideStringRetWideString;
begin
  DefineString(tkWString);
  Check(FIntf.FuncConstWideStringConstWideStringRetWideString(gWS1, gWS2) = gWS5, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutWideStringWideStringRetWideString;
begin
  DefineString(tkWString);
  FWideString1 := gWS1;
  FWideString2 := gWS2;
  Check(FIntf.FuncOutWideStringWideStringRetWideString(FWideString1, gWS2) = gWS5, 'invalid result');
  Check(FWideString1 = gWS3, 'WideString1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncWideStringOutWideStringRetWideString;
begin
  DefineString(tkWString);
  FWideString1 := gWS1;
  FWideString2 := gWS2;
  Check(FIntf.FuncWideStringOutWideStringRetWideString(gWS1, FWideString2) = gWS5, 'invalid result');
  Check(FWideString2 = gWS4, 'WideString2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutWideStringOutWideStringRetWideString;
begin
  DefineString(tkWString);
  FWideString1 := gWS1;
  FWideString2 := gWS2;
  Check(FIntf.FuncOutWideStringOutWideStringRetWideString(FWideString1, FWideString2) = gWS5, 'invalid result');
  Check(FWideString1 = gWS3, 'WideString1 invalid');
  Check(FWideString2 = gWS4, 'WideString2 invalid');
end;

// ENUMERATION TESTS

procedure TIdSoapInterfaceBaseTests.FuncRetEnumToggle;
begin
  FEnum1 := FIntf.FuncRetEnumToggle;
  FEnum2 := FIntf.FuncRetEnumToggle;
  Check(IsEnumIn(FEnum1, le12, le34), 'result invalid');
  Check(IsEnumIn(FEnum2, le12, le34), 'result invalid');
  Check(FEnum1 <> FEnum2, 'result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncEnumRetEnum;
begin
  Check(FIntf.FuncEnumRetEnum(le258) = le283, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarEnumRetEnum;
begin
  FEnum1 := le12;
  Check(FIntf.FuncVarEnumRetEnum(FEnum1) = le90, 'invalid result');
  Check(FEnum1 = le56, 'Enum1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncEnumEnumRetEnum;
begin
  Check(FIntf.FuncEnumEnumRetEnum(le12, le34) = le90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarEnumEnumRetEnum;
begin
  FEnum1 := le12;
  Check(FIntf.FuncVarEnumEnumRetEnum(FEnum1, le34) = le90, 'invalid result');
  Check(FEnum1 = le56, 'Enum1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncEnumVarEnumRetEnum;
begin
  FEnum2 := le34;
  Check(FIntf.FuncEnumVarEnumRetEnum(le12, FEnum2) = le90, 'invalid result');
  Check(FEnum2 = le78, 'Enum2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarEnumVarEnumRetEnum;
begin
  FEnum1 := le12;
  FEnum2 := le34;
  Check(FIntf.FuncVarEnumVarEnumRetEnum(FEnum1, FEnum2) = le90, 'invalid result');
  Check(FEnum1 = le56, 'Enum1 invalid');
  Check(FEnum2 = le78, 'Enum2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstEnumEnumRetEnum;
begin
  Check(FIntf.FuncConstEnumEnumRetEnum(le12, le34) = le90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncEnumConstEnumRetEnum;
begin
  Check(FIntf.FuncEnumConstEnumRetEnum(le12, le34) = le90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstEnumConstEnumRetEnum;
begin
  Check(FIntf.FuncConstEnumConstEnumRetEnum(le12, le34) = le90, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutEnumEnumRetEnum;
begin
  FEnum1 := le12;
  Check(FIntf.FuncOutEnumEnumRetEnum(FEnum1, le34) = le90, 'invalid result');
  Check(FEnum1 = le56, 'Enum1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncEnumOutEnumRetEnum;
begin
  FEnum2 := le34;
  Check(FIntf.FuncEnumOutEnumRetEnum(le12, FEnum2) = le90, 'invalid result');
  Check(FEnum2 = le78, 'Enum2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutEnumOutEnumRetEnum;
begin
  FEnum1 := le12;
  FEnum2 := le34;
  Check(FIntf.FuncOutEnumOutEnumRetEnum(FEnum1, FEnum2) = le90, 'invalid result');
  Check(FEnum1 = le56, 'Enum1 invalid');
  Check(FEnum2 = le78, 'Enum2 invalid');
end;

// BOOLEAN TESTS

procedure TIdSoapInterfaceBaseTests.FuncBooleanRetBoolean;
begin
  Check(FIntf.FuncBooleanRetBoolean(true) = false, 'Result invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarBooleanRetBoolean;
begin
  FBoolean1 := false;
  Check(FIntf.FuncVarBooleanRetBoolean(FBoolean1) = false, 'invalid result');
  Check(FBoolean1 = true, 'Boolean1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncBooleanBooleanRetBoolean;
begin
  Check(FIntf.FuncBooleanBooleanRetBoolean(false, true) = true, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarBooleanBooleanRetBoolean;
begin
  FBoolean1 := true;
  Check(FIntf.FuncVarBooleanBooleanRetBoolean(FBoolean1, false) = false, 'invalid result');
  Check(FBoolean1 = false, 'Boolean1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncBooleanVarBooleanRetBoolean;
begin
  FBoolean2 := false;
  Check(FIntf.FuncBooleanVarBooleanRetBoolean(true, FBoolean2) = true, 'invalid result');
  Check(FBoolean2 = true, 'Boolean2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncVarBooleanVarBooleanRetBoolean;
begin
  FBoolean1 := true;
  FBoolean2 := false;
  Check(FIntf.FuncVarBooleanVarBooleanRetBoolean(FBoolean1, FBoolean2) = false, 'invalid result');
  Check(FBoolean1 = false, 'Boolean1 invalid');
  Check(FBoolean2 = true, 'Boolean2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstBooleanBooleanRetBoolean;
begin
  Check(FIntf.FuncConstBooleanBooleanRetBoolean(false, true) = true, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncBooleanConstBooleanRetBoolean;
begin
  Check(FIntf.FuncBooleanConstBooleanRetBoolean(true, false) = true, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncConstBooleanConstBooleanRetBoolean;
begin
  Check(FIntf.FuncConstBooleanConstBooleanRetBoolean(true, true) = true, 'invalid result');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutBooleanBooleanRetBoolean;
begin
  FBoolean1 := false;
  Check(FIntf.FuncOutBooleanBooleanRetBoolean(FBoolean1, false) = false, 'invalid result');
  Check(FBoolean1 = true, 'Boolean1 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncBooleanOutBooleanRetBoolean;
begin
  FBoolean2 := true;
  Check(FIntf.FuncBooleanOutBooleanRetBoolean(true, FBoolean2) = true, 'invalid result');
  Check(FBoolean2 = false, 'Boolean2 invalid');
end;

procedure TIdSoapInterfaceBaseTests.FuncOutBooleanOutBooleanRetBoolean;
begin
  FBoolean1 := false;
  FBoolean2 := true;
  Check(FIntf.FuncOutBooleanOutBooleanRetBoolean(FBoolean1, FBoolean2) = false, 'invalid result');
  Check(FBoolean1 = true, 'Boolean1 invalid');
  Check(FBoolean2 = false, 'Boolean2 invalid');
end;

// SETS tests

procedure TIdSoapInterfaceBaseTests.FuncRetSet;
begin
  Check(FIntf.FuncRetSet = [seOne,seThree,seFive,seTen],'Incorrect SET');
end;

procedure TIdSoapInterfaceBaseTests.ProcSet;
begin
  FIntf.ProcSet([seOne,seThree,seFive,seTen]);
end;

procedure TIdSoapInterfaceBaseTests.ProcConstSet;
begin
  FIntf.ProcSet([seOne,seThree,seFive,seTen]);
end;

procedure TIdSoapInterfaceBaseTests.ProcOutSet;
Var
  LSet: TSmallSet;
begin
  LSet := [];
  FIntf.ProcOutSet(LSet);
  Check(LSet = [seOne,seThree,seFive,seNine,seTen],'Invalid set value');
end;

procedure TIdSoapInterfaceBaseTests.ProcVarSet;
Var
  LSet: TSmallSet;
begin
  LSet := [seOne,seThree,seFive,seTen];
  FIntf.ProcOutSet(LSet);
  Check(LSet = [seOne,seThree,seFive,seNine,seTen],'Invalid set value');
end;

// DYNAMIC ARRAY tests

procedure TIdSoapInterfaceBaseTests.DynArrTraversalRoutines;
type
  TTestDynArr = array of array of array of array of Word;   // for testing dynamic arrays
var
  x: TTestDynArr;
  LSubscripts: TIdSoapDynArrSubscriptEntryArray;
begin
  SetLength(x, 9);
  SetLength(x[3], 3);
  Setlength(x[3][0], 5);
  SetLength(x[3][1], 2);
  SetLength(x[3][2], 7);
  SetLength(x[3][1][1], 5);
  x[3][1][1][0] := 3110;
  x[3][1][1][1] := 3111;
  x[3][1][1][2] := 3112;
  x[3][1][1][3] := 3113;
  x[3][1][1][4] := 3114;
  SetLength(x[3][2][5], 1);
  x[3][2][5][0] := 3250;

  setlength(x[7], 8);
  setlength(x[7][3], 5);
  setlength(x[7][3][3], 3);
  x[7][3][3][0] := 7330;
  x[7][3][3][1] := 7331;
  x[7][3][3][2] := 7332;
  setlength(x[7][3][1], 4);
  x[7][3][1][0] := 7310;
  x[7][3][1][1] := 7311;
  x[7][3][1][2] := 7312;
  x[7][3][1][3] := 7313;

  IdSoapDynArrSetupSubscriptCounter(LSubscripts, x, TypeInfo(TTestDynArr));

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 3110, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 3111, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 3112, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 3113, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 3114, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 3250, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 7310, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 7311, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 7312, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 7313, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 7330, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 7331, 'Faile array traversal at 3110');

  Check(IdSoapDynArrNextEntry(x, LSubscripts), 'Unexpected end in dynamic array traversal');
  Check(Word(IdSoapDynArrData(LSubscripts, x)^) = 7332, 'Faile array traversal at 3110');

  Check(not IdSoapDynArrNextEntry(x, LSubscripts), 'Should have reached the end of the array');
end;

procedure TIdSoapInterfaceBaseTests.ProcDynCurrency1Arr;
var
  LArray: TTestDynCurrency1Arr;
begin
  SetLength(LArray,4);
  LArray[0] := 123.456;
  LArray[1] := 234.567;
  LArray[2] := 345.678;
  LArray[3] := 456.789;
  FIntf.ProcDynCurrency1Arr(LArray);
end;

procedure TIdSoapInterfaceBaseTests.ProcDynInteger2Arr;
Var
  LArray : TTestDynInteger2Arr;
begin
  SetLength(LArray,5);
  SetLength(LArray[0],3);
  SetLength(LArray[2],5);
  LArray[0][0] := 100;
  LArray[0][1] := 101;
  LArray[0][2] := 102;
  LArray[2][0] := 120;
  LArray[2][1] := 121;
  LArray[2][2] := 122;
  LArray[2][3] := 123;
  LArray[2][4] := 124;
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcDynInteger2Arr(LArray);
end;

procedure TIdSoapInterfaceBaseTests.ProcDynString3Arr;
Var
  LArray : TTestDynString3Arr;
begin
  SetLength(LArray,4);
  SetLength(Larray[2],7);
  SetLength(LArray[2,4],10);
  LArray[2,4,5] := 'Hello World';
  LArray[2,4,7] := 'I''m the seven''th';
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcDynString3Arr(LArray);
end;

procedure TIdSoapInterfaceBaseTests.ProcDynByte4Arr;
Var
  LArray : TTestDynByte4Arr;
begin
  SetLength(LArray,12);
  SetLength(LArray[3],4);
  SetLength(LArray[3,3],14);
  SetLength(LArray[3,3,9],25);
  LArray[3,3,9,12] := 123;
  SetLength(LArray[7],9);
  SetLength(LArray[7,0],1);
  SetLength(LArray[7,0,0],18);
  LArray[7,0,0,10] := 234;
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcDynByte4Arr(LArray);
end;

procedure TIdSoapInterfaceBaseTests.ProcDynVarByte4Arr;
Var
  LArray : TTestDynByte4Arr;
begin
  SetLength(LArray,12);
  SetLength(LArray[3],4);
  SetLength(LArray[3,3],14);
  SetLength(LArray[3,3,9],25);
  LArray[3,3,9,12] := 123;
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcDynVarByte4Arr(LArray);
  Check(Length(LArray)=8,'Subscript 1 length incorrect');
  Check(Length(LArray[7])=1,'Subscript 2 length incorrect');
  Check(Length(LArray[7,0])=1,'Subscript 3 length incorrect');
  Check(Length(LArray[7,0,0])=18,'Subscript 4 length incorrect');
  Check(LArray[7,0,0,10]=214,'Var result from server incorrect');
end;

// this checks that the returned array has been correctly re-sized
procedure TIdSoapInterfaceBaseTests.ProcDynVarCurrency1Arr;
Var
  LArray: TTestDynCurrency1Arr;
begin
  SetLength(LArray,5);
  LArray[0] := 987.654;
  LArray[1] := 876.543;
  LArray[2] := 765.432;
  FIntf.ProcDynVarCurrency1Arr(LArray);
  Check(LArray[0]=987.654,'[0] incorrect');
  Check(LArray[1]=876.543,'[1] incorrect');
  Check(LArray[2]=123.456,'[2] incorrect');
  Check(LArray[3]=234.567,'[3] incorrect');
  Check(LArray[4]=345.678,'[4] incorrect');
  Check(LArray[5]=0.0    ,'[5] incorrect');
  Check(LArray[6]=456.789,'[6] incorrect');
end;

// check an OUT param type
procedure TIdSoapInterfaceBaseTests.ProcDynOutInteger2Arr;
Var
  LArray: TTestDynInteger2Arr;
begin
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcDynOutInteger2Arr(LArray);
  Check(Length(LArray)=2,'base array length incorrect');
  Check(Length(LArray[1])=3,'[1] length incorrect');
  Check(LArray[1,1] = 43210,'Value incorrect');
end;

// check dynamic array results
procedure TIdSoapInterfaceBaseTests.FuncRetDynInteger2Arr;
Var
  LArray: TTestDynInteger2Arr;
begin
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
   LArray := FIntf.FuncRetDynInteger2Arr;
  Check(Length(LArray)=4,'base array length incorrect');
  Check(Length(LArray[3])=10,'[3] length incorrect');
  Check(LArray[3,5] = 1122,'value incorrect');
end;

procedure TIdSoapInterfaceBaseTests.FuncRetDynCurrency1Arr;
Var
  LArray: TTestDynCurrency1Arr;
begin
  LArray := FIntf.FuncRetDynCurrency1Arr;
  Check(Length(LArray)=5,'base array length incorrect');
  Check(LArray[3] = 1122,'value incorrect');
end;

procedure TIdSoapInterfaceBaseTests.ProcDynObject1Arr;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  SetLength(LArray, 3);
  for i := Low(LArray) to High(LArray) do
    begin
    LArray[i] := TSoapSimpleTestClass.create;
    LArray[i].FieldString := 'Value '+inttostr(i);
    end;
  FIntf.ProcDynObject1Arr(LArray);
  Check(not GServerObject.TestValid);
  for i := Low(LArray) to High(LArray) do
    begin
    FreeAndNil(LArray[i]);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcDynObject2Arr;
var
  LArray : TTestDynObj2Arr;
  i,j: Integer;
begin
  SetLength(LArray, 4);
  SetLength(LArray[2],2);
  SetLength(LArray[3],3);
  LArray[2][0] := TSoapSimpleTestClass.create;
  LArray[2][0].FieldString := 'Value 2,0';
  LArray[2][1] := TSoapSimpleTestClass.create;
  LArray[2][1].FieldString := 'Value 2,1';
  LArray[3][0] := TSoapSimpleTestClass.create;
  LArray[3][0].FieldString := 'Value 3,0';
  LArray[3][1] := TSoapSimpleTestClass.create;
  LArray[3][1].FieldString := 'Value 3,1';
  LArray[3][2] := TSoapSimpleTestClass.create;
  LArray[3][2].FieldString := 'Value 3,2';
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  try
    FIntf.ProcDynObject2Arr(LArray);
    Check(not GServerObject.TestValid);
  finally
    for i := low(larray) to high(larray) do
      begin
      for j:=0 to length(larray[i])-1 do
        begin
        freeandnil(larray[i][j]);
        end;
      end;
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcDynObject3Arr;
var
  LArray : TTestDynObj3Arr;
  i,j,k: Integer;
  procedure Define(l1,l2,l3: Integer);
  begin
    LArray[l1,l2,l3] := TSoapSimpleTestClass.create;
    LArray[l1][l2][l3].FieldString := 'Value '+Inttostr(l1)+','+inttostr(l2)+','+inttostr(l3);
  end;
begin
  SetLength(LArray, 3);

  SetLength(LArray[0],2);
  SetLength(LArray[2],1);

  SetLength(LArray[0][0],2);
  SetLength(LArray[0][1],2);
  SetLength(LArray[2][0],3);

  Define(0,0,0);
  Define(0,0,1);
  Define(0,1,0);
  Define(0,1,1);
  Define(2,0,0);
  Define(2,0,1);
  Define(2,0,2);
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  try
    FIntf.ProcDynObject3Arr(LArray);
    Check(not GServerObject.TestValid);
  finally
    for i := Low(LArray) to High(LArray) do
      begin
      for j:=0 to length(LArray[i])-1 do
        begin
        for k:=0 to length(LArray[i][j])-1 do
          begin
          FreeAndNil(LArray[i][j][k]);
          end;
        end;
      end;
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcOutDynObject1Arr;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  FIntf.ProcOutDynObject1Arr(LArray);
  check(Length(LArray) = 3, 'Length should be 3');
  for i := Low(LArray) to High(LArray) do
    check(LArray[i].FieldString = 'Return Value '+inttostr(i), 'value '+inttostr(i)+' is wrong');
  for i := Low(LArray) to High(LArray) do
    begin
    FreeAndNil(LArray[i]);
    end;
  Check(not GServerObject.TestValid,'Failed class life test');
end;

procedure TIdSoapInterfaceBaseTests.ProcOutDynObject2Arr;
var
  LArray : TTestDynObj2Arr;
  i,j : integer;
begin
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcOutDynObject2Arr(LArray);
  check(Length(LArray) = 4, 'Length should be 4');
  for i := Low(LArray) to High(LArray) do
    for j:= 0 to length(LArray[i])-1 do
      check(LArray[i][j].FieldString = 'Return Value '+inttostr(i)+','+inttostr(j), 'value '+inttostr(i)+','+inttostr(j)+' is wrong');
  for i := Low(LArray) to High(LArray) do
    for j:= 0 to length(LArray[i])-1 do
      begin
      FreeAndNil(LArray[i][j]);
      end;
  Check(not GServerObject.TestValid,'Failed class life test');
end;

procedure TIdSoapInterfaceBaseTests.FuncRetDynObject1Arr;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  LArray := FIntf.FuncRetDynObject1Arr;
  check(Length(LArray) = 3, 'Length should be 3');
  for i := Low(LArray) to High(LArray) do
    check(LArray[i].FieldString = 'Return Value '+inttostr(i), 'value '+inttostr(i)+' is wrong');
  for i := Low(LArray) to High(LArray) do
    begin
    FreeAndNil(LArray[i]);
    end;
  Check(not GServerObject.TestValid,'Failed class life test');
end;

procedure TIdSoapInterfaceBaseTests.FuncRetDynObject2Arr;
var
  LArray : TTestDynObj2Arr;
  i,j : integer;
begin
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  LArray := FIntf.FuncRetDynObject2Arr;
  check(Length(LArray) = 5, 'Length should be 5');  // NOTE: The last entry from the server had no data and hence
                                                    //       should have been removed
  for i := Low(LArray) to High(LArray) do
    for j:= 0 to length(LArray[i])-1 do
      check(LArray[i][j].FieldString = 'Return Value '+inttostr(i)+','+inttostr(j), 'value '+inttostr(i)+','+inttostr(j)+' is wrong');
  for i := Low(LArray) to High(LArray) do
    for j:= 0 to length(LArray[i])-1 do
      begin
      FreeAndNil(LArray[i][j]);
      end;
  Check(not GServerObject.TestValid,'Failed class life test');
end;

procedure TIdSoapInterfaceBaseTests.ProcDynObject1ArrGarbageCollected;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  GTestClient.GarbageCollectObjects := true;
  SetLength(LArray, 3);
  for i := Low(LArray) to High(LArray) do
    begin
    LArray[i] := TSoapSimpleTestClass.create;
    LArray[i].FieldString := 'Value '+inttostr(i);
    end;
  FIntf.ProcDynObject1Arr(LArray);
  for i := Low(LArray) to High(LArray) do
    begin
    Check(LArray[i].TestValid);
    end;
  FIntf.ProcCall;
  for i := Low(LArray) to High(LArray) do
    begin
    Check(not LArray[i].TestValid,'Failed class life test');
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcOutDynObject1ArrGarbageCollected;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  GTestClient.GarbageCollectObjects := true;
  FIntf.ProcOutDynObject1Arr(LArray);
  check(Length(LArray) = 3, 'Length should be 3');
  for i := Low(LArray) to High(LArray) do
    begin
    Check(LArray[i].TestValid);
    check(LArray[i].FieldString = 'Return Value '+inttostr(i), 'value '+inttostr(i)+' is wrong');
    end;
  FIntf.ProcCall;
  for i := Low(LArray) to High(LArray) do
    begin
    Check(not LArray[i].TestValid,'Failed class life test');
    end;
end;

procedure TIdSoapInterfaceBaseTests.FuncRetDynObject1ArrGarbageCollected;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  GTestClient.GarbageCollectObjects := true;
  LArray := FIntf.FuncRetDynObject1Arr;
  check(Length(LArray) = 3, 'Length should be 3');
  for i := Low(LArray) to High(LArray) do
    begin
    Check(LArray[i].TestValid);
    check(LArray[i].FieldString = 'Return Value '+inttostr(i), 'value '+inttostr(i)+' is wrong');
    end;
  FIntf.ProcCall;
  for i := Low(LArray) to High(LArray) do
    begin
    Check(not LArray[i].TestValid,'Failed class life test');
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcOutDynObject1ArrServerKeepAlive;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  GTestServerKeepAlive := true;
  FIntf.ProcOutDynObject1Arr(LArray);
  check(Length(LArray) = 3, 'Length should be 3');
  for i := Low(LArray) to High(LArray) do
    check(LArray[i].FieldString = 'Return Value '+inttostr(i), 'value '+inttostr(i)+' is wrong');
  for i := Low(LArray) to High(LArray) do
    begin
    FreeAndNil(LArray[i]);
    end;
  Check(GServerObject.TestValid,'Failed class life test');
  FreeAndNil(GServerObject);
end;

procedure TIdSoapInterfaceBaseTests.FuncRetDynObject1ArrServerKeepAlive;
var
  LArray : TTestDynObj1Arr;
  i : integer;
begin
  GTestServerKeepAlive := true;
  LArray := FIntf.FuncRetDynObject1Arr;
  check(Length(LArray) = 3, 'Length should be 3');
  for i := Low(LArray) to High(LArray) do
    check(LArray[i].FieldString = 'Return Value '+inttostr(i), 'value '+inttostr(i)+' is wrong');
  for i := Low(LArray) to High(LArray) do
    begin
    FreeAndNil(LArray[i]);
    end;
  Check(GServerObject.TestValid,'Failed class life test');
  FreeAndNil(GServerObject);
end;

procedure TIdSoapInterfaceBaseTests.ProcDynArrNil;
var
  ADynArr: TTestDynCurrency1Arr;
begin
  SetLength(ADynArr,0);
  FIntf.ProcDynArrNil(ADynArr);
end;

procedure TIdSoapInterfaceBaseTests.ProcConstDynArrNil;
var
  ADynArr: TTestDynCurrency1Arr;
begin
  SetLength(ADynArr,0);
  FIntf.ProcConstDynArrNil(ADynArr);
end;

procedure TIdSoapInterfaceBaseTests.ProcOutDynArrNil;
var
  ADynArr: TTestDynCurrency1Arr;
begin
  FIntf.ProcOutDynArrNil(ADynArr);
  check(Length(ADynArr)=0,'Array should have 0 length');
end;

procedure TIdSoapInterfaceBaseTests.ProcVarDynArrNil;
var
  ADynArr: TTestDynCurrency1Arr;
begin
  FIntf.ProcVarDynArrNil(ADynArr);
  check(Length(ADynArr)=0,'Array should have 0 length');
end;

procedure TIdSoapInterfaceBaseTests.FuncRetDynArrNil;
var
  ADynArr: TTestDynCurrency1Arr;
begin
  ADynArr := FIntf.FuncRetDynArrNil;
  check(Length(ADynArr)=0,'Array should have 0 length');
end;

// CLASS tests

procedure TIdSoapInterfaceBaseTests.ProcFieldArrClass;
var
  LClass: TSoapFieldArrClass;
  LArray: TTestDynCurrency1Arr;
begin
  LClass := TSoapFieldArrClass.Create;
  try
    SetLength(LArray,3);
    LArray[0] := 123.456;
    LArray[1] := 234.567;
    LArray[2] := 345.678;
    LClass.FieldArray := Copy(LArray);
    Check(Length(LClass.FieldArray) = 3, 'Failed field array in class - length of way');

    FIntf.ProcClassFieldArr(LClass);

    Check(Length(LClass.FieldArray) = 3, 'Failed field array in class - length of way');
    Check(LClass.FieldArray[0] = 654.321,'Failed field array in class');
    Check(LClass.FieldArray[1] = 765.432,'Failed field array in class');
    Check(LClass.FieldArray[2] = 876.543,'Failed field array in class');
  finally
    FreeAndNil(LClass);
    end;
end;

// test all property types in all 3 possible property permutations
// namely FIELD, STATIC METHOD and VIRTUAL METHOD
procedure TIdSoapInterfaceBaseTests.ProcClass;
var
  LClass: TSoapTestClass;
  LSimpleClass: TSoapSimpleTestClass;
  LArray: TTestDynCurrency1Arr;
begin
  LSimpleClass := TSoapSimpleTestClass.Create;
  LSimpleClass.FieldString := 'SimpleClass FieldString';
  LClass := TSoapTestClass.Create;
  try

    LClass.FieldInteger := 123;
    LClass.StaticInteger := 234;
    LClass.VirtualInteger := 345;
    LClass.FieldAnsiString := 'Field AnsiString';
    LClass.StaticAnsiString := 'Static AnsiString';
    LClass.VirtualAnsiString := 'Virtual AnsiString';
    LClass.FieldShortString := 'Field ShortString';
    LClass.StaticShortString := 'Static ShortString';
    LClass.VirtualShortString := 'Virtual ShortString';
    LClass.FieldWideString := 'Field WideString';
    LClass.StaticWideSTring := 'Static WideString';
    LClass.VirtualWideString := 'Virtual WideString';
    LClass.FieldInt64 := 1234567;
    LClass.StaticInt64 := 2345678;
    LClass.VirtualInt64 := 3456789;
    LClass.FieldChar := 'F';
    LClass.StaticChar := 'S';
    LClass.VirtualChar := 'V';
    LClass.FieldWideChar := 'f';
    LClass.StaticWideChar := 's';
    LClass.VirtualWideChar := 'v';
    LClass.FieldSingle := 123.456;
    LClass.StaticSingle := 234.567;
    LClass.VirtualSingle := 345.678;
    LClass.FieldDouble := 1123.456;
    LClass.StaticDouble := 1234.567;
    LClass.VirtualDouble := 1345.678;
    LClass.FieldExtended := 2123.456;
    LClass.StaticExtended := 2234.567;
    LClass.VirtualExtended := 2345.678;
    LClass.FieldComp := 3123.456;
    LClass.StaticComp := 3234.567;
    LClass.VirtualComp := 3345.678;
    LClass.FieldCurrency := 4123.456;
    LClass.StaticCurrency := 4234.567;
    LClass.VirtualCurrency := 4345.678;
    LClass.FieldClass := LSimpleClass;

    SetLength(LArray,3);

    LArray[0] := 1;
    LArray[1] := 2;
    LArray[2] := 3;
    LClass.FieldArray := copy(LArray);

    LArray[0] := 2;
    LArray[1] := 3;
    LArray[2] := 4;
    LClass.StaticArray := copy(LArray);

    LArray[0] := 3;
    LArray[1] := 4;
    LArray[2] := 5;
    LClass.VirtualArray := copy(LArray);

    LClass.FieldEnum := seOne;
    LClass.StaticEnum := seTwo;
    LClass.VirtualEnum := seThree;
    LClass.FieldSet := [seOne,seTwo,seThree];
    LClass.StaticSet := [seTwo,seThree,seFour];
    LClass.VirtualSet := [seThree,seFour,seFive];

    FIntf.ProcClass(LClass);
    Check(LClass.FieldSet = [seOne,seTwo,seThree,seSeven],'Invalid SET');
    Check(LClass.StaticSet = [seTwo,seThree,seFour,seEight],'Invalid SET');
    Check(LClass.VirtualSet = [seThree,seFour,seFive,seNine],'Invalid SET');
  finally
    FreeAndNil(LClass);
    end;
  check(Not LSimpleClass.TestValid);
end;

procedure TIdSoapInterfaceBaseTests.ProcClass_InLine;
var
  LClass: TSoapTestClass;
  LSimpleClass: TSoapSimpleTestClass;
  LArray: TTestDynCurrency1Arr;
begin
  LSimpleClass := TSoapSimpleTestClass.Create;
  LSimpleClass.FieldString := 'SimpleClass FieldString';
  LClass := TSoapTestClass.Create;
  try

    LClass.FieldInteger := 123;
    LClass.StaticInteger := 234;
    LClass.VirtualInteger := 345;
    LClass.FieldAnsiString := 'Field AnsiString';
    LClass.StaticAnsiString := 'Static AnsiString';
    LClass.VirtualAnsiString := 'Virtual AnsiString';
    LClass.FieldShortString := 'Field ShortString';
    LClass.StaticShortString := 'Static ShortString';
    LClass.VirtualShortString := 'Virtual ShortString';
    LClass.FieldWideString := 'Field WideString';
    LClass.StaticWideSTring := 'Static WideString';
    LClass.VirtualWideString := 'Virtual WideString';
    LClass.FieldInt64 := 1234567;
    LClass.StaticInt64 := 2345678;
    LClass.VirtualInt64 := 3456789;
    LClass.FieldChar := 'F';
    LClass.StaticChar := 'S';
    LClass.VirtualChar := 'V';
    LClass.FieldWideChar := 'f';
    LClass.StaticWideChar := 's';
    LClass.VirtualWideChar := 'v';
    LClass.FieldSingle := 123.456;
    LClass.StaticSingle := 234.567;
    LClass.VirtualSingle := 345.678;
    LClass.FieldDouble := 1123.456;
    LClass.StaticDouble := 1234.567;
    LClass.VirtualDouble := 1345.678;
    LClass.FieldExtended := 2123.456;
    LClass.StaticExtended := 2234.567;
    LClass.VirtualExtended := 2345.678;
    LClass.FieldComp := 3123.456;
    LClass.StaticComp := 3234.567;
    LClass.VirtualComp := 3345.678;
    LClass.FieldCurrency := 4123.456;
    LClass.StaticCurrency := 4234.567;
    LClass.VirtualCurrency := 4345.678;
    LClass.FieldClass := LSimpleClass;

    SetLength(LArray,3);

    LArray[0] := 1;
    LArray[1] := 2;
    LArray[2] := 3;
    LClass.FieldArray := copy(LArray);

    LArray[0] := 2;
    LArray[1] := 3;
    LArray[2] := 4;
    LClass.StaticArray := copy(LArray);

    LArray[0] := 3;
    LArray[1] := 4;
    LArray[2] := 5;
    LClass.VirtualArray := copy(LArray);

    LClass.FieldEnum := seOne;
    LClass.StaticEnum := seTwo;
    LClass.VirtualEnum := seThree;
    LClass.FieldSet := [seOne,seTwo,seThree];
    LClass.StaticSet := [seTwo,seThree,seFour];
    LClass.VirtualSet := [seThree,seFour,seFive];

    FIntf2.ProcClass(LClass);
    Check(LClass.FieldSet = [seOne,seTwo,seThree,seSeven],'Invalid SET');
    Check(LClass.StaticSet = [seTwo,seThree,seFour,seEight],'Invalid SET');
    Check(LClass.VirtualSet = [seThree,seFour,seFive,seNine],'Invalid SET');
  finally
    FreeAndNil(LClass);
    end;
  check(Not LSimpleClass.TestValid);
end;

// test we can get a class as a result
procedure TIdSoapInterfaceBaseTests.FuncRetClass;
Var
  LClass: TSoapSimpleTestClass;
begin
  Check(GServerObject = nil);
  LClass := FIntf.FuncRetClass;
  try
    Check(not GServerObject.TestValid);
    check(LClass.TestValid);
  finally
    LClass.Free;
    end;
end;

procedure TIdSoapInterfaceBaseTests.FuncRetClass_InLine;
Var
  LClass: TSoapSimpleTestClass;
begin
  Check(GServerObject = nil);
  LClass := FIntf2.FuncRetClass;
  try
    Check(not GServerObject.TestValid);
    check(LClass.TestValid);
  finally
    LClass.Free;
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcClassGarbageCollected;
var
  LClass: TSoapTestClass;
  LSimpleClass: TSoapSimpleTestClass;
  LArray: TTestDynCurrency1Arr;
  LSNum1, LSNum2:integer;
begin
  GTestClient.GarbageCollectObjects := true;
  LSimpleClass := TSoapSimpleTestClass.Create;
  LSimpleClass.FieldString := 'SimpleClass FieldString';
  LSNum2 := LSimpleClass.SerialNumber;
  LClass := TSoapTestClass.Create;
  LSNum1 := LClass.SerialNumber;
  LClass.FieldClass := LSimpleClass;
  LClass.FieldInteger := 123;
  LClass.StaticInteger := 234;
  LClass.VirtualInteger := 345;
  LClass.FieldAnsiString := 'Field AnsiString';
  LClass.StaticAnsiString := 'Static AnsiString';
  LClass.VirtualAnsiString := 'Virtual AnsiString';
  LClass.FieldShortString := 'Field ShortString';
  LClass.StaticShortString := 'Static ShortString';
  LClass.VirtualShortString := 'Virtual ShortString';
  LClass.FieldWideString := 'Field WideString';
  LClass.StaticWideSTring := 'Static WideString';
  LClass.VirtualWideString := 'Virtual WideString';
  LClass.FieldInt64 := 1234567;
  LClass.StaticInt64 := 2345678;
  LClass.VirtualInt64 := 3456789;
  LClass.FieldChar := 'F';
  LClass.StaticChar := 'S';
  LClass.VirtualChar := 'V';
  LClass.FieldWideChar := 'f';
  LClass.StaticWideChar := 's';
  LClass.VirtualWideChar := 'v';
  LClass.FieldSingle := 123.456;
  LClass.StaticSingle := 234.567;
  LClass.VirtualSingle := 345.678;
  LClass.FieldDouble := 1123.456;
  LClass.StaticDouble := 1234.567;
  LClass.VirtualDouble := 1345.678;
  LClass.FieldExtended := 2123.456;
  LClass.StaticExtended := 2234.567;
  LClass.VirtualExtended := 2345.678;
  LClass.FieldComp := 3123.456;
  LClass.StaticComp := 3234.567;
  LClass.VirtualComp := 3345.678;
  LClass.FieldCurrency := 4123.456;
  LClass.StaticCurrency := 4234.567;
  LClass.VirtualCurrency := 4345.678;
  SetLength(LArray,3);

  LArray[0] := 1;
  LArray[1] := 2;
  LArray[2] := 3;
  LClass.FieldArray := copy(LArray);

  LArray[0] := 2;
  LArray[1] := 3;
  LArray[2] := 4;
  LClass.StaticArray := copy(LArray);

  LArray[0] := 3;
  LArray[1] := 4;
  LArray[2] := 5;
  LClass.VirtualArray := copy(LArray);

  LClass.FieldEnum := seOne;
  LClass.StaticEnum := seTwo;
  LClass.VirtualEnum := seThree;
  LClass.FieldSet := [seOne,seTwo,seThree];
  LClass.StaticSet := [seTwo,seThree,seFour];
  LClass.VirtualSet := [seThree,seFour,seFive];

  Check(not GTestClient.GarbageContext.OwnsObject(LClass));
  Check(not GTestClient.GarbageContext.OwnsObject(LSimpleClass));
  FIntf.ProcClass(LClass);
  Check(LClass.TestValid(TSoapTestClass) and (LClass.SerialNumber <> LSNum1), 'LClass is not valid');
  LSNum1 := LClass.SerialNumber;
  Check(GTestClient.GarbageContext.OwnsObject(LClass), 'garbage context does not own object1');
  Check(LClass.FieldSet = [seOne,seTwo,seThree,seSeven],'Invalid SET');
  Check(LClass.StaticSet = [seTwo,seThree,seFour,seEight],'Invalid SET');
  Check(LClass.VirtualSet = [seThree,seFour,seFive,seNine],'Invalid SET');
  FIntf.ProcCall;
  Check(not (LClass.TestValid(TSoapTestClass) and (LClass.SerialNumber = LSNum1)), 'Class is still valid');
  Check(not (LSimpleClass.TestValid(TSoapSimpleTestClass) and (LSimpleClass.SerialNumber = LSNum2)), 'simple Class is still valid');
end;

// test we can get a class as a result
procedure TIdSoapInterfaceBaseTests.FuncRetClassGarbageCollected;
Var
  LClass: TSoapSimpleTestClass;
begin
  GTestClient.GarbageCollectObjects := true;
  LClass := FIntf.FuncRetClass;
  check(LClass.TestValid);
  Check(GTestClient.GarbageContext.OwnsObject(LClass));
  FIntf.ProcCall;
  Check(not LClass.TestValid);
end;

procedure TIdSoapInterfaceBaseTests.ProcClassServerKeepAlive;
var
  LClass: TSoapTestClass;
  LSimpleClass: TSoapSimpleTestClass;
  LArray: TTestDynCurrency1Arr;
begin
  GTestServerKeepAlive := true;
  LSimpleClass := TSoapSimpleTestClass.Create;
  LSimpleClass.FieldString := 'SimpleClass FieldString';
  LClass := TSoapTestClass.Create;
  try

    LClass.FieldInteger := 123;
    LClass.StaticInteger := 234;
    LClass.VirtualInteger := 345;
    LClass.FieldAnsiString := 'Field AnsiString';
    LClass.StaticAnsiString := 'Static AnsiString';
    LClass.VirtualAnsiString := 'Virtual AnsiString';
    LClass.FieldShortString := 'Field ShortString';
    LClass.StaticShortString := 'Static ShortString';
    LClass.VirtualShortString := 'Virtual ShortString';
    LClass.FieldWideString := 'Field WideString';
    LClass.StaticWideSTring := 'Static WideString';
    LClass.VirtualWideString := 'Virtual WideString';
    LClass.FieldInt64 := 1234567;
    LClass.StaticInt64 := 2345678;
    LClass.VirtualInt64 := 3456789;
    LClass.FieldChar := 'F';
    LClass.StaticChar := 'S';
    LClass.VirtualChar := 'V';
    LClass.FieldWideChar := 'f';
    LClass.StaticWideChar := 's';
    LClass.VirtualWideChar := 'v';
    LClass.FieldSingle := 123.456;
    LClass.StaticSingle := 234.567;
    LClass.VirtualSingle := 345.678;
    LClass.FieldDouble := 1123.456;
    LClass.StaticDouble := 1234.567;
    LClass.VirtualDouble := 1345.678;
    LClass.FieldExtended := 2123.456;
    LClass.StaticExtended := 2234.567;
    LClass.VirtualExtended := 2345.678;
    LClass.FieldComp := 3123.456;
    LClass.StaticComp := 3234.567;
    LClass.VirtualComp := 3345.678;
    LClass.FieldCurrency := 4123.456;
    LClass.StaticCurrency := 4234.567;
    LClass.VirtualCurrency := 4345.678;
    LClass.FieldClass := LSimpleClass;

    SetLength(LArray,3);

    LArray[0] := 1;
    LArray[1] := 2;
    LArray[2] := 3;
    LClass.FieldArray := copy(LArray);

    LArray[0] := 2;
    LArray[1] := 3;
    LArray[2] := 4;
    LClass.StaticArray := copy(LArray);

    LArray[0] := 3;
    LArray[1] := 4;
    LArray[2] := 5;
    LClass.VirtualArray := copy(LArray);

    LClass.FieldEnum := seOne;
    LClass.StaticEnum := seTwo;
    LClass.VirtualEnum := seThree;
    LClass.FieldSet := [seOne,seTwo,seThree];
    LClass.StaticSet := [seTwo,seThree,seFour];
    LClass.VirtualSet := [seThree,seFour,seFive];

    Check(GServerObject = nil);
    FIntf.ProcClass(LClass);
    Check(GServerObject.TestValid);
    FreeAndNil(GServerObject);
    Check(LClass.FieldSet = [seOne,seTwo,seThree,seSeven],'Invalid SET');
    Check(LClass.StaticSet = [seTwo,seThree,seFour,seEight],'Invalid SET');
    Check(LClass.VirtualSet = [seThree,seFour,seFive,seNine],'Invalid SET');
  finally
    FreeAndNil(LClass);
    end;
  check(Not LSimpleClass.TestValid);
end;

procedure TIdSoapInterfaceBaseTests.FuncRetClassServerKeepAlive;
Var
  LClass: TSoapSimpleTestClass;
begin
  GTestServerKeepAlive := true;
  Check(GServerObject = nil);
  LClass := FIntf.FuncRetClass;
  try
    Check(GServerObject.TestValid);
    FreeAndNil(GServerObject);
    check(LClass.TestValid);
  finally
    LClass.Free;
    end;
end;


// test virtual classes come across ok
procedure TIdSoapInterfaceBaseTests.FuncRetVirtualClass;
var
  LClass: TSoapVirtualClassTestBase;
begin
  LClass := FIntf.FuncRetVirtualClass(false);
  try
    check(LClass is TSoapVirtualClassTestBase);
    check(Not (LClass is TSoapVirtualClassTestChild));
    check(LClass.AByte = 4);
  finally
    FreeAndNil(LClass);
  end;

  LClass := FIntf.FuncRetVirtualClass(true);
  try
    check(LClass is TSoapVirtualClassTestChild);
    check(LClass.AByte = 4);
    check((LClass as TSoapVirtualClassTestChild).AInt = 3);
  finally
    FreeAndNil(LClass);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcVarVirtualClass;
Var
  LClass: TSoapVirtualClassTestBase;
begin
  LClass := TSoapVirtualClassTestBase.create;
  try
    LClass.AByte := 7;
    FIntf.ProcVarVirtualClass(LClass);
    check(LClass.AByte = 13);
    check(LClass is TSoapVirtualClassTestChild);
    check((LClass as TSoapVirtualClassTestChild).AInt = -5);
  finally
    FreeAndNil(LClass);
  end;

  LClass := TSoapVirtualClassTestChild.create;
  try
    LClass.AByte := 7;
    (LClass as TSoapVirtualClassTestChild).AInt := 345;
    FIntf.ProcVarVirtualClass(LClass);
    check(LClass.AByte = 9);
    check(not (LClass is TSoapVirtualClassTestChild));
  finally
    FreeAndNil(LClass);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcVirtualClass;
Var
  LClass: TSoapVirtualClassTestBase;
begin
  LClass := TSoapVirtualClassTestChild.Create;
  try
    LClass.AByte := 4;
    FIntf.ProcVirtualClass(LClass);
  finally
    FreeAndNil(LClass);
  end;
  LClass := TSoapVirtualClassTestBase.Create;
  try
    LClass.AByte := 3;
    FIntf.ProcVirtualClass(LClass);
  finally
    FreeAndNil(LClass);
  end;
end;

{ TIdSoapInterfaceBinTests }

function TIdSoapInterfaceBinTests.GetClientEncodingType: TIdSoapEncodingType;
begin
  result := etIdBinary;
end;

{ TIdSoapInterfaceXML8Tests }

function TIdSoapInterfaceXML8Tests.GetClientEncodingType: TIdSoapEncodingType;
begin
  result := etIdXmlUtf8;
end;

{ TIdSoapInterfaceXML16Tests }

function TIdSoapInterfaceXML16Tests.GetClientEncodingType: TIdSoapEncodingType;
begin
  result := etIdXmlUtf16;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestBinary;
var
  LStream : TStream;
  LCheckDigit : byte;
begin
  LStream := CreateSendStream(2000);
  try
    LCheckDigit := GetStreamCheckDigit(LStream);
    LStream.Position := 0;
    FIntf.ProcParamStream(LStream, LCheckDigit);
    Check((LStream as TIDMemoryStream).TestValid(TIdMemoryStream))
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestHexBinary;
var
  LStream : THexStream;
  LCheckDigit : byte;
begin
  LStream := CreateSendHexStream(2000);
  try
    LCheckDigit := GetStreamCheckDigit(LStream);
    LStream.Position := 0;
    FIntf.ProcParamHexStream(LStream, LCheckDigit);
    Check((LStream as THexStream).TestValid(THexStream))
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestBinaryEmpty;
var
  LStream : TStream;
  LCheckDigit : byte;
begin
  LStream := CreateSendStream(0);
  try
    LCheckDigit := GetStreamCheckDigit(LStream);
    LStream.Position := 0;
    FIntf.ProcParamStream(LStream, LCheckDigit);
    Check((LStream as TIDMemoryStream).TestValid(TIdMemoryStream))
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestHexBinaryEmpty;
var
  LStream : THexStream;
  LCheckDigit : byte;
begin
  LStream := CreateSendHexStream(0);
  try
    LCheckDigit := GetStreamCheckDigit(LStream);
    LStream.Position := 0;
    FIntf.ProcParamHexStream(LStream, LCheckDigit);
    Check((LStream as THexStream).TestValid(THexStream))
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestBinaryNil;
begin
  FIntf.ProcParamStream(nil, 0);
end;

procedure TIdSoapInterfaceBaseTests.ProcTestHexBinaryNil;
begin
  FIntf.ProcParamHexStream(nil, 0);
end;

procedure TIdSoapInterfaceBaseTests.FuncTestBinary;
var
  LStream : TStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendStream(2000);
  try
    LStream.Position := 0;
    LStream2 := FIntf.FuncParamStreamRetStream(LStream);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.FuncTestHexBinary;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendHexStream(2000);
  try
    LStream.Position := 0;
    LStream2 := FIntf.FuncParamHexStreamRetHexStream(LStream);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.FuncTestBinaryEmpty;
var
  LStream : TStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendStream(0);
  try
    LStream.Position := 0;
    LStream2 := FIntf.FuncParamStreamRetStream(LStream);
    Assert(Assigned(LStream2),'LStream2 should NOT be nil');
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.FuncTestHexBinaryEmpty;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendHexStream(0);
  try
    LStream.Position := 0;
    LStream2 := FIntf.FuncParamHexStreamRetHexStream(LStream);
    Assert(Assigned(LStream2),'LStream2 should NOT be nil');
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.FuncTestBinaryNil;
begin
  Check(Not assigned(FIntf.FuncParamStreamRetStream(nil)), 'Result should be nil');
end;

procedure TIdSoapInterfaceBaseTests.FuncTestHexBinaryNil;
begin
  Check(Not assigned(FIntf.FuncParamHexStreamRetHexStream(nil)), 'Result should be nil');
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutBinary;
var
  LStream : TStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendStream(2000);
  try
    LStream.Position := 0;
    FIntf.ProcParamOutStream(LStream, LStream2);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutHexBinary;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendHexStream(2000);
  try
    LStream.Position := 0;
    FIntf.ProcParamOutHexStream(LStream, LStream2);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutBinaryEmpty;
var
  LStream : TStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendStream(0);
  try
    LStream.Position := 0;
    FIntf.ProcParamOutStream(LStream, LStream2);
    Assert(Assigned(LStream2),'LStream2 is nil');
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutHexBinaryEmpty;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendHexStream(0);
  try
    LStream.Position := 0;
    FIntf.ProcParamOutHexStream(LStream, LStream2);
    Assert(Assigned(LStream2),'LStream2 is nil');
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutBinaryNil;
Var
  LStream : TStream;
begin
  FIntf.ProcParamOutStream(Nil, LStream);
  Check(not assigned(LStream), 'Stream should be nil');
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutHexBinaryNil;
Var
  LStream : THexStream;
begin
  FIntf.ProcParamOutHexStream(Nil, LStream);
  Check(not assigned(LStream), 'Stream should be nil');
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarBinary;
var
  LStream : TStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendStream(2000);
  try
    LStream.Position := 0;
    LStream2 := nil;
    FIntf.ProcParamVarStream(LStream, LStream2);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarHexBinary;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendHexStream(2000);
  try
    LStream.Position := 0;
    LStream2 := nil;
    FIntf.ProcParamVarHexStream(LStream, LStream2);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarBinaryEmpty;
var
  LStream : TStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendStream(0);
  try
    LStream.Position := 0;
    LStream2 := nil;
    FIntf.ProcParamVarStream(LStream, LStream2);
    Assert(Assigned(LStream2),'LStream2 is nil');
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarHexBinaryEmpty;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendHexStream(0);
  try
    LStream.Position := 0;
    LStream2 := nil;
    FIntf.ProcParamVarHexStream(LStream, LStream2);
    Assert(Assigned(LStream2),'LStream2 is nil');
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarBinaryNil;
Var
  LStream : TStream;
begin
  LStream := nil;
  FIntf.ProcParamVarStream(Nil, LStream);
  Check(not assigned(LStream), 'Stream should be nil');
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarHexBinaryNil;
Var
  LStream : THexStream;
begin
  LStream := nil;
  FIntf.ProcParamVarHexStream(Nil, LStream);
  Check(not assigned(LStream), 'Stream should be nil');
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutBinaryHuge;
var
  LStream : TStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendStream(512 * 1024); // 1 MB
  try
    LStream.Position := 0;
    FIntf.ProcParamOutStream(LStream, LStream2);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutHexBinaryHuge;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
begin
  LStream := CreateSendHexStream(512 * 1024); // 1 MB
  try
    LStream.Position := 0;
    FIntf.ProcParamOutHexStream(LStream, LStream2);
    try
      LStream.Position := 0;
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

function TIdSoapInterfaceBaseTests.CreateSendStream(AFillCount : integer): TStream;
begin
  result := TIdMemoryStream.create;
  FillTestingStream(Result, AFillCount);
  result.Position := 0;
end;

function TIdSoapInterfaceBaseTests.CreateSendHexStream(AFillCount : integer): THexStream;
begin
  result := THexStream.create;
  FillTestingStream(Result, AFillCount);
  result.Position := 0;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestBinaryProperty;
var
  LBin : TBinaryTestClass;
begin
  LBin := TBinaryTestClass.create;
  try
    LBin.Stream := CreateSendStream(400);
    LBin.Size := LBin.Stream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.Stream);
    LBin.Stream.Position := 0;
    FIntf.ProcParamPropStream(LBin);
  finally
    FreeAndNil(LBin);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestHexBinaryProperty;
var
  LBin : THexBinaryTestClass;
begin
  LBin := THexBinaryTestClass.create;
  try
    LBin.HexStream := CreateSendHexStream(400);
    LBin.Size := LBin.HexStream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.HexStream);
    LBin.HexStream.Position := 0;
    FIntf.ProcParamPropHexStream(LBin);
  finally
    FreeAndNil(LBin);
  end;
end;

procedure TIdSoapInterfaceBaseTests.FuncTestRetBinaryProperty;
var
  LBin, LBin2 : TBinaryTestClass;
  LMsg : string;
  LOK : boolean;
begin
  LBin := TBinaryTestClass.create;
  try
    LBin.Stream := CreateSendStream(400);
    LBin.Size := LBin.Stream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.Stream);
    LBin.Stream.Position := 0;
    LBin2 := FIntf.FuncParamPropStreamRetStream(LBin);
    LBin2.Stream.Position := 0;
    LBin.Stream.Position := 0;
    LOK := TestStreamsIdentical(LBin.Stream, LBin2.Stream, LMsg);
    LBin2.Stream.Position := 0;
    check(GetStreamCheckDigit(LBin2.Stream) = LBin2.CheckDigit);
    check(LBin2.Stream.Size = LBin2.Size);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LBin);
    FreeAndNil(LBin2);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarHexBinaryProperty;
var
  LBin, LBin2 : THexBinaryTestClass;
  LMsg : string;
  LOK : boolean;
begin
  LBin := THexBinaryTestClass.create;
  try
    LBin.HexStream := CreateSendHexStream(400);
    LBin.Size := LBin.HexStream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.HexStream);
    LBin.HexStream.Position := 0;
    LBin2 := FIntf.FuncParamPropHexStreamRetHexStream(LBin);
    LBin2.HexStream.Position := 0;
    LBin.HexStream.Position := 0;
    LOK := TestStreamsIdentical(LBin.HexStream, LBin2.HexStream, LMsg);
    LBin2.HexStream.Position := 0;
    check(GetStreamCheckDigit(LBin2.HexStream) = LBin2.CheckDigit);
    check(LBin2.HexStream.Size = LBin2.Size);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LBin);
    FreeAndNil(LBin2);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutBinaryProperty;
var
  LBin, LBin2 : TBinaryTestClass;
  LMsg : string;
  LOK : boolean;
begin
  LBin := TBinaryTestClass.create;
  try
    LBin.Stream := CreateSendStream(400);
    LBin.Size := LBin.Stream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.Stream);
    LBin.Stream.Position := 0;
    FIntf.ProcParamPropOutStream(LBin, LBin2);
    LBin.Stream.Position := 0;
    LBin2.Stream.Position := 0;
    LOK := TestStreamsIdentical(LBin.Stream, LBin2.Stream, LMsg);
    LBin2.Stream.Position := 0;
    check(GetStreamCheckDigit(LBin2.Stream) = LBin2.CheckDigit);
    check(LBin2.Stream.Size = LBin2.Size);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LBin);
    FreeAndNil(LBin2);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutHexBinaryProperty;
var
  LBin, LBin2 : THexBinaryTestClass;
  LMsg : string;
  LOK : boolean;
begin
  LBin := THexBinaryTestClass.create;
  try
    LBin.HexStream := CreateSendHexStream(400);
    LBin.Size := LBin.HexStream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.HexStream);
    LBin.HexStream.Position := 0;
    FIntf.ProcParamPropOutHexStream(LBin, LBin2);
    LBin.HexStream.Position := 0;
    LBin2.HexStream.Position := 0;
    LOK := TestStreamsIdentical(LBin.HexStream, LBin2.HexStream, LMsg);
    LBin2.HexStream.Position := 0;
    check(GetStreamCheckDigit(LBin2.HexStream) = LBin2.CheckDigit);
    check(LBin2.HexStream.Size = LBin2.Size);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LBin);
    FreeAndNil(LBin2);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarBinaryProperty;
var
  LBin, LBin2 : TBinaryTestClass;
  LMsg : string;
  LOK : boolean;
begin
  LBin := TBinaryTestClass.create;
  try
    LBin.Stream := CreateSendStream(400);
    LBin.Size := LBin.Stream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.Stream);
    LBin.Stream.Position := 0;
    LBin2 := nil;
    FIntf.ProcParamPropOutStream(LBin, LBin2);
    LBin.Stream.Position := 0;
    LBin2.Stream.Position := 0;
    LOK := TestStreamsIdentical(LBin.Stream, LBin2.Stream, LMsg);
    LBin2.Stream.Position := 0;
    LBin.Stream.Position := 0;
    check(GetStreamCheckDigit(LBin2.Stream) = LBin2.CheckDigit);
    check(LBin2.Stream.Size = LBin2.Size);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LBin);
    FreeAndNil(LBin2);
  end;
end;

procedure TIdSoapInterfaceBaseTests.FuncTestRetHexBinaryProperty;
var
  LBin, LBin2 : THexBinaryTestClass;
  LMsg : string;
  LOK : boolean;
begin
  LBin := THexBinaryTestClass.create;
  try
    LBin.HexStream := CreateSendHexStream(400);
    LBin.Size := LBin.HexStream.Size;
    LBin.CheckDigit := GetStreamCheckDigit(LBin.HexStream);
    LBin.HexStream.Position := 0;
    LBin2 := nil;
    FIntf.ProcParamPropOutHexStream(LBin, LBin2);
    LBin.HexStream.Position := 0;
    LBin2.HexStream.Position := 0;
    LOK := TestStreamsIdentical(LBin.HexStream, LBin2.HexStream, LMsg);
    LBin2.HexStream.Position := 0;
    LBin.HexStream.Position := 0;
    check(GetStreamCheckDigit(LBin2.HexStream) = LBin2.CheckDigit);
    check(LBin2.HexStream.Size = LBin2.Size);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LBin);
    FreeAndNil(LBin2);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestBinaryArray;
var
  LLen: integer;
  LCheckDigits: TTestDynByteArr;
  LArray: TTestDynStreamArray;
begin
  LLen := 4;
  SetLength(LCheckDigits, LLen);
  SetLength(LArray, LLen);
  LArray[0] := nil;
  LCheckDigits[0] := 0;
  LArray[1] := CreateSendStream(0);
  LCheckDigits[1] := GetStreamCheckDigit(LArray[1]);
  LArray[1].Position := 0;
  LArray[2] := CreateSendStream(100);
  LCheckDigits[2] := GetStreamCheckDigit(LArray[2]);
  LArray[2].Position := 0;
  LArray[3] := CreateSendStream(10000);
  LCheckDigits[3] := GetStreamCheckDigit(LArray[3]);
  LArray[3].Position := 0;
  try
    if GInDocumentMode then
      begin
      ExpectedException := EIdSoapRequirementFail;
      end;
    FIntf.ProcParamStreamArray(LLen, LCheckDigits, LArray);
  finally
    FreeAndNil(LArray[0]);
    FreeAndNil(LArray[1]);
    FreeAndNil(LArray[2]);
    FreeAndNil(LArray[3]);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestHexBinaryArray;
var
  LLen: integer;
  LCheckDigits: TTestDynByteArr;
  LArray: TTestDynHexStreamArray;
begin
  LLen := 4;
  SetLength(LCheckDigits, LLen);
  SetLength(LArray, LLen);
  LArray[0] := nil;
  LCheckDigits[0] := 0;
  LArray[1] := CreateSendHexStream(0);
  LCheckDigits[1] := GetStreamCheckDigit(LArray[1]);
  LArray[1].Position := 0;
  LArray[2] := CreateSendHexStream(100);
  LCheckDigits[2] := GetStreamCheckDigit(LArray[2]);
  LArray[2].Position := 0;
  LArray[3] := CreateSendHexStream(10000);
  LCheckDigits[3] := GetStreamCheckDigit(LArray[3]);
  LArray[3].Position := 0;
  try
    if GInDocumentMode then
      begin
      ExpectedException := EIdSoapRequirementFail;
      end;
    FIntf.ProcParamHexStreamArray(LLen, LCheckDigits, LArray);
  finally
    FreeAndNil(LArray[0]);
    FreeAndNil(LArray[1]);
    FreeAndNil(LArray[2]);
    FreeAndNil(LArray[3]);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutBinaryArray;
var
  LLen: integer;
  LCheckDigits: TTestDynByteArr;
  LArray: TTestDynStreamArray;
  i : integer;
begin
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcParamOutStreamArray(LLen, LCheckDigits, LArray);
  try
    if Length(LCheckDigits) <> LLen then
      raise exception.create('CheckDigit Array Length wrong ('+IntToStr(Length(LCheckDigits))+'/'+IntToStr(LLen)+')');
    if Length(LArray) <> LLen then
      raise exception.create('Stream Array Length wrong ('+IntToStr(Length(LArray))+'/'+IntToStr(LLen)+')');
    for i := Low(LCheckDigits) to High(LCheckDigits) do
      begin
      if LCheckDigits[i] = 0 then
        begin
        if assigned(LArray[i]) then
          raise exception.create('Stream should be nil');
        end
      else
        begin
        Assert(Assigned(LArray[i]),'Stream should NOT be nil');
        case i of
         1:check(LArray[i].Size = 0);
         2:check(LArray[i].Size = 200);
         3:check(LArray[i].Size = 20000);
        end;
        if not GetStreamCheckDigit(LArray[i]) = LCheckDigits[i] then
          raise exception.create('Stream Check Digit failed');
        end;
     end;
  finally
    FreeAndNil(LArray[0]);
    FreeAndNil(LArray[1]);
    FreeAndNil(LArray[2]);
    FreeAndNil(LArray[3]);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestOutHexBinaryArray;
var
  LLen: integer;
  LCheckDigits: TTestDynByteArr;
  LArray: TTestDynHexStreamArray;
  i : integer;
begin
  if GInDocumentMode then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  FIntf.ProcParamOutHexStreamArray(LLen, LCheckDigits, LArray);
  try
    if Length(LCheckDigits) <> LLen then
      raise exception.create('CheckDigit Array Length wrong ('+IntToStr(Length(LCheckDigits))+'/'+IntToStr(LLen)+')');
    if Length(LArray) <> LLen then
      raise exception.create('HexStream Array Length wrong ('+IntToStr(Length(LArray))+'/'+IntToStr(LLen)+')');
    for i := Low(LCheckDigits) to High(LCheckDigits) do
      begin
      if LCheckDigits[i] = 0 then
        begin
        if assigned(LArray[i]) then
          raise exception.create('HexStream should be nil');
        end
      else
        begin
        Assert(Assigned(LArray[i]),'HexStream should NOT be nil');
        case i of
         1:check(LArray[i].Size = 0);
         2:check(LArray[i].Size = 200);
         3:check(LArray[i].Size = 20000);
        end;
        if not GetStreamCheckDigit(LArray[i]) = LCheckDigits[i] then
          raise exception.create('HexStream Check Digit failed');
        end;
     end;
  finally
    FreeAndNil(LArray[0]);
    FreeAndNil(LArray[1]);
    FreeAndNil(LArray[2]);
    FreeAndNil(LArray[3]);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarBinaryArray;
var
  LLen: integer;
  LCheckDigits: TTestDynByteArr;
  LArray: TTestDynStreamArray;
  i : integer;
begin
  LLen := 4;
  SetLength(LCheckDigits, LLen);
  SetLength(LArray, LLen);
  LArray[0] := nil;
  LCheckDigits[0] := 0;
  LArray[1] := CreateSendStream(0);
  LCheckDigits[1] := GetStreamCheckDigit(LArray[1]);
  LArray[1].Position := 0;
  LArray[2] := CreateSendStream(100);
  LCheckDigits[2] := GetStreamCheckDigit(LArray[2]);
  LArray[2].Position := 0;
  LArray[3] := CreateSendStream(10000);
  LCheckDigits[3] := GetStreamCheckDigit(LArray[3]);
  LArray[3].Position := 0;
  try
    if GInDocumentMode then
      begin
      ExpectedException := EIdSoapRequirementFail;
      end;
    FIntf.ProcParamVarStreamArray(LLen, LCheckDigits, LArray);
    if Length(LCheckDigits) <> LLen then
      raise exception.create('CheckDigit Array Length wrong ('+IntToStr(Length(LCheckDigits))+'/'+IntToStr(LLen)+')');
    if Length(LArray) <> LLen then
      raise exception.create('Stream Array Length wrong ('+IntToStr(Length(LArray))+'/'+IntToStr(LLen)+')');
    for i := Low(LCheckDigits) to High(LCheckDigits) do
      begin
      if LCheckDigits[i] = 0 then
        begin
        if assigned(LArray[i]) then
          raise exception.create('Stream should be nil');
        end
      else
        begin
        case i of
         1:check(LArray[i].Size = 0, 'length of stream 1 is '+inttostr(LArray[i].Size)+', should be 0');
         2:check(LArray[i].Size = 200, 'length of stream 2 is '+inttostr(LArray[i].Size)+', should be 200');
         3:check(LArray[i].Size = 20000, 'length of stream 3 is '+inttostr(LArray[i].Size)+', should be 20000');
        end;
        if not GetStreamCheckDigit(LArray[i]) = LCheckDigits[i] then
          raise exception.create('Stream Check Digit failed');
        end;
     end;
  finally
    FreeAndNil(LArray[0]);
    FreeAndNil(LArray[1]);
    FreeAndNil(LArray[2]);
    FreeAndNil(LArray[3]);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcTestVarHexBinaryArray;
var
  LLen: integer;
  LCheckDigits: TTestDynByteArr;
  LArray: TTestDynHexStreamArray;
  i : integer;
begin
  LLen := 4;
  SetLength(LCheckDigits, LLen);
  SetLength(LArray, LLen);
  LArray[0] := nil;
  LCheckDigits[0] := 0;
  LArray[1] := CreateSendHexStream(0);
  LCheckDigits[1] := GetStreamCheckDigit(LArray[1]);
  LArray[1].Position := 0;
  LArray[2] := CreateSendHexStream(100);
  LCheckDigits[2] := GetStreamCheckDigit(LArray[2]);
  LArray[2].Position := 0;
  LArray[3] := CreateSendHexStream(10000);
  LCheckDigits[3] := GetStreamCheckDigit(LArray[3]);
  LArray[3].Position := 0;
  try
    if GInDocumentMode then
      begin
      ExpectedException := EIdSoapRequirementFail;
      end;
    FIntf.ProcParamVarHexStreamArray(LLen, LCheckDigits, LArray);
    if Length(LCheckDigits) <> LLen then
      raise exception.create('CheckDigit Array Length wrong ('+IntToStr(Length(LCheckDigits))+'/'+IntToStr(LLen)+')');
    if Length(LArray) <> LLen then
      raise exception.create('HexStream Array Length wrong ('+IntToStr(Length(LArray))+'/'+IntToStr(LLen)+')');
    for i := Low(LCheckDigits) to High(LCheckDigits) do
      begin
      if LCheckDigits[i] = 0 then
        begin
        if assigned(LArray[i]) then
          raise exception.create('HexStream should be nil');
        end
      else
        begin
        case i of
         1:check(LArray[i].Size = 0, 'length of HexStream 1 is '+inttostr(LArray[i].Size)+', should be 0');
         2:check(LArray[i].Size = 200, 'length of HexStream 2 is '+inttostr(LArray[i].Size)+', should be 200');
         3:check(LArray[i].Size = 20000, 'length of HexStream 3 is '+inttostr(LArray[i].Size)+', should be 20000');
        end;
        if not GetStreamCheckDigit(LArray[i]) = LCheckDigits[i] then
          raise exception.create('HexStream Check Digit failed');
        end;
     end;
  finally
    FreeAndNil(LArray[0]);
    FreeAndNil(LArray[1]);
    FreeAndNil(LArray[2]);
    FreeAndNil(LArray[3]);
  end;
end;


// DATE tests

procedure TIdSoapInterfaceBaseTests.ProcParamDateTime;
var
  LDT: TIdSoapDateTime;
begin
  LDT := TIdSOapDateTime.Create;
  LDT.Year := 1234;
  LDT.Month := 5;
  LDT.Day := 30;
  LDT.Hour := 12;
  LDT.Minute := 18;
  LDT.Second := 29;
  LDT.Nanosecond := 987654321;
  Try
    FIntf.ProcParamDateTime(LDT);
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.FuncParamDateTimeRetDateTime;
var
  LDT,LRet: TIdSoapDateTime;
begin
  LDT := TIdSOapDateTime.Create;
  LDT.Year := 1234;
  LDT.Month := 5;
  LDT.Day := 30;
  LDT.Hour := 12;
  LDT.Minute := 18;
  LDT.Second := 29;
  LDT.Nanosecond := 987654321;
  LRet := nil;
  Try
    LRet := FIntf.FuncParamDateTimeRetDateTime(LDT);
    Check(LRet.Year = 4321,'Year failed');
    Check(LRet.Month = 7,'Month failed');
    Check(LRet.Day = 20,'Day failed');
    Check(LRet.Hour = 9,'Hour failed');
    Check(LRet.Minute = 28,'Minute failed');
    Check(LRet.Second = 39,'Second failed');
    Check(LRet.Nanosecond = 987654322,'Nanoseconds failed');
  finally
    FreeAndNil(LRet);
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamOutDateTime;
var
  LDT: TIdSoapDateTime;
begin
  LDT := nil;
  Try
    FIntf.ProcParamOutDateTime(LDT);
    Check(LDT.Year = 4321,'Year failed');
    Check(LDT.Month = 7,'Month failed');
    Check(LDT.Day = 20,'Day failed');
    Check(LDT.Hour = 9,'Hour failed');
    Check(LDT.Minute = 28,'Minute failed');
    Check(LDT.Second = 39,'Second failed');
    Check(LDT.Nanosecond = 987654322,'Nanoseconds failed');
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamVarDateTime;
var
  LDT: TIdSoapDateTime;
begin
  LDT := TIdSOapDateTime.Create;
  Try
    LDT.Year := 1234;
    LDT.Month := 5;
    LDT.Day := 30;
    LDT.Hour := 12;
    LDT.Minute := 18;
    LDT.Second := 29;
    LDT.Nanosecond := 987654321;
    FIntf.ProcParamVarDateTime(LDT);
    Check(LDT.Year = 4321,'Year failed');
    Check(LDT.Month = 7,'Month failed');
    Check(LDT.Day = 20,'Day failed');
    Check(LDT.Hour = 9,'Hour failed');
    Check(LDT.Minute = 28,'Minute failed');
    Check(LDT.Second = 39,'Second failed');
    Check(LDT.Nanosecond = 987654322,'Nanoseconds failed');
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamDate;
var
  LDT: TIdSoapDate;
begin
  LDT := TIdSOapDate.Create;
  LDT.Year := 1234;
  LDT.Month := 5;
  LDT.Day := 30;
  Try
    FIntf.ProcParamDate(LDT);
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.FuncParamDateRetDate;
var
  LDT,LRet: TIdSoapDate;
begin
  LDT := TIdSOapDate.Create;
  LDT.Year := 1234;
  LDT.Month := 5;
  LDT.Day := 30;
  LRet := nil;
  Try
    LRet := FIntf.FuncParamDateRetDate(LDT);
    Check(LRet.Year = 4321,'Year failed');
    Check(LRet.Month = 7,'Month failed');
    Check(LRet.Day = 20,'Day failed');
  finally
    FreeAndNil(LRet);
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamOutDate;
var
  LDT: TIdSoapDate;
begin
  LDT := nil;
  Try
    FIntf.ProcParamOutDate(LDT);
    Check(LDT.Year = 4321,'Year failed');
    Check(LDT.Month = 7,'Month failed');
    Check(LDT.Day = 20,'Day failed');
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamVarDate;
var
  LDT: TIdSoapDate;
begin
  LDT := TIdSOapDate.Create;
  Try
    LDT.Year := 1234;
    LDT.Month := 5;
    LDT.Day := 30;
    FIntf.ProcParamVarDate(LDT);
    Check(LDT.Year = 4321,'Year failed');
    Check(LDT.Month = 7,'Month failed');
    Check(LDT.Day = 20,'Day failed');
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamTime;
var
  LDT: TIdSoapTime;
begin
  LDT := TIdSoapTime.Create;
  LDT.Hour := 12;
  LDT.Minute := 18;
  LDT.Second := 29;
  LDT.Nanosecond := 987654321;
  Try
    FIntf.ProcParamTime(LDT);
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.FuncParamTimeRetTime;
var
  LDT,LRet: TIdSoapTime;
begin
  LDT := TIdSOapTime.Create;
  LDT.Hour := 12;
  LDT.Minute := 18;
  LDT.Second := 29;
  LDT.Nanosecond := 987654321;
  LRet := nil;
  Try
    LRet := FIntf.FuncParamTimeRetTime(LDT);
    Check(LRet.Hour = 9,'Hour failed');
    Check(LRet.Minute = 28,'Minute failed');
    Check(LRet.Second = 39,'Second failed');
    Check(LRet.Nanosecond = 987654322,'Nanoseconds failed');
  finally
    FreeAndNil(LRet);
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamOutTime;
var
  LDT: TIdSoapTime;
begin
  LDT := nil;
  Try
    FIntf.ProcParamOutTime(LDT);
    Check(LDT.Hour = 9,'Hour failed');
    Check(LDT.Minute = 28,'Minute failed');
    Check(LDT.Second = 39,'Second failed');
    Check(LDT.Nanosecond = 987654322,'Nanoseconds failed');
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcParamVarTime;
var
  LDT: TIdSoapTime;
begin
  LDT := TIdSOapTime.Create;
  Try
    LDT.Hour := 12;
    LDT.Minute := 18;
    LDT.Second := 29;
    LDT.Nanosecond := 987654321;
    FIntf.ProcParamVarTime(LDT);
    Check(LDT.Hour = 9,'Hour failed');
    Check(LDT.Minute = 28,'Minute failed');
    Check(LDT.Second = 39,'Second failed');
    Check(LDT.Nanosecond = 987654322,'Nanoseconds failed');
  finally
    FreeAndNil(LDT);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcClassReference1;
var
  LObj1 : TReferenceTestingObject;
begin
  LObj1 := TReferenceTestingObject.create;
  try
    FIntf.ProcReferenceTesting1(true, LObj1, LObj1);
  finally
    FreeAndNil(LObj1);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcClassReference2;
var
  LObj1 : TReferenceTestingObject;
  LObj2 : TReferenceTestingObject;
begin
  LObj1 := TReferenceTestingObject.create;
  try
    LObj2 := TReferenceTestingObject.create;
    try
      FIntf.ProcReferenceTesting1(false, LObj1, LObj2);
    finally
      FreeAndNil(LObj2);
    end;
  finally
    FreeAndNil(LObj1);
  end;
end;

procedure TIdSoapInterfaceBaseTests.ProcClassReference3;
var
  LObj1 : TReferenceTestingObject;
begin
  LObj1 := TReferenceTestingObject.create;
  try
    FIntf2.ProcReferenceTesting1(false, LObj1, LObj1);
  finally
    FreeAndNil(LObj1);
  end;
end;

procedure TIdSoapInterfaceBaseTests.FuncClassReference4;
var
  LObj1, LObj2 : TReferenceTestingObject;
begin
  Fintf.ProcReferenceTesting2(LObj1, LObj2);
  Check(LObj1.Child = LObj2);
  FreeAndNil(LObj1);
end;

procedure TIdSoapInterfaceBaseTests.FuncClassReference5;
var
  LObj1, LObj2 : TReferenceTestingObject;
begin
  Fintf2.ProcReferenceTesting2(LObj1, LObj2);
  Check(LObj1.Child <> LObj2);
  FreeAndNil(LObj1);
  FreeAndNil(LObj2);
end;

procedure TIdSoapInterfaceBaseTests.ProcNilClass;
begin
  FIntf.ProcNilClass(nil);
end;

procedure TIdSoapInterfaceBaseTests.ProcConstNilClass;
begin
  FIntf.ProcNilClass(nil);
end;

procedure TIdSoapInterfaceBaseTests.ProcOutNilClass;
var
  AClass: TSoapSimpleTestClass;
begin
  FIntf.ProcOutNilClass(AClass);
  Check(AClass = nil,'AClass should be nil');
end;

procedure TIdSoapInterfaceBaseTests.ProcVarNilClass;
var
  AClass: TSoapSimpleTestClass;
begin
  AClass := nil;
  FIntf.ProcOutNilClass(AClass);
  Check(AClass = nil,'AClass should be nil');
end;

procedure TIdSoapInterfaceBaseTests.FuncRetNilClass;
begin
  check(not Assigned(FIntf.FuncRetNilClass),'Result should be a nil class');
end;

procedure TIdSoapInterfaceBaseTests.FuncRetNilPropClass;
var
  AClass: TSoapNilPropClass;
begin
  AClass := FIntf.FuncRetNilPropClass;
  check(not Assigned(AClass.AClass),'Class property should be nil');
  FreeAndNil(AClass);
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3StringPropClass;
var
  AClass: TSoap3StringProperties;
begin
  AClass := TSoap3StringProperties.Create;
  try
    AClass.Field1 := 'Field1';
    AClass.Field2 := 'Field2';
    AClass.Field3 := 'Field3';
    FIntf.ProcSimple3StringPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 'Field1|RET1','Field1 is invalid');
    Check(AClass.Field2 = 'Field2|RET2','Field2 is invalid');
    Check(AClass.Field3 = 'Field3|RET3','Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3ShortStringPropClass;
var
  AClass: TSoap3ShortStringProperties;
begin
  AClass := TSoap3ShortStringProperties.Create;
  try
    AClass.Field1 := 'SS1';
    AClass.Field2 := 'SS2';
    AClass.Field3 := 'SS3';
    FIntf.ProcSimple3ShortStringPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 'SS1|1','Field1 is invalid');
    Check(AClass.Field2 = 'SS2|2','Field2 is invalid');
    Check(AClass.Field3 = 'SS3|3','Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3BytePropClass;
var
  AClass: TSoap3ByteProperties;
begin
  AClass := TSoap3ByteProperties.Create;
  try
    AClass.Field1 := 1;
    AClass.Field2 := 2;
    AClass.Field3 := 3;
    FIntf.ProcSimple3BytePropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = $11,'Field1 is invalid');
    Check(AClass.Field2 = $22,'Field2 is invalid');
    Check(AClass.Field3 = $33,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3ShortIntPropClass;
var
  AClass: TSoap3ShortIntProperties;
begin
  AClass := TSoap3ShortIntProperties.Create;
  try
    AClass.Field1 := 12;
    AClass.Field2 := 13;
    AClass.Field3 := 14;
    FIntf.ProcSimple3ShortIntPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = -21,'Field1 is invalid');
    Check(AClass.Field2 = -32,'Field2 is invalid');
    Check(AClass.Field3 = -43,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3SmallIntPropClass;
var
  AClass: TSoap3SmallIntProperties;
begin
  AClass := TSoap3SmallIntProperties.Create;
  try
    AClass.Field1 := -1;
    AClass.Field2 := -2;
    AClass.Field3 := -3;
    FIntf.ProcSimple3SmallIntPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = -11,'Field1 is invalid');
    Check(AClass.Field2 = -22,'Field2 is invalid');
    Check(AClass.Field3 = -33,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3WordPropClass;
var
  AClass: TSoap3WordProperties;
begin
  AClass := TSoap3WordProperties.Create;
  try
    AClass.Field1 := 123;
    AClass.Field2 := 456;
    AClass.Field3 := 789;
    FIntf.ProcSimple3WordPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 111,'Field1 is invalid');
    Check(AClass.Field2 = 222,'Field2 is invalid');
    Check(AClass.Field3 = 333,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3IntegerPropClass;
var
  AClass: TSoap3IntegerProperties;
begin
  AClass := TSoap3IntegerProperties.Create;
  try
    AClass.Field1 := 1111;
    AClass.Field2 := 2222;
    AClass.Field3 := 3333;
    FIntf.ProcSimple3IntegerPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 11111,'Field1 is invalid');
    Check(AClass.Field2 = 22222,'Field2 is invalid');
    Check(AClass.Field3 = 33333,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

{$IFNDEF DELPHI4}
procedure TIdSoapInterfaceBaseTests.ProcSimple3CardinalPropClass;
var
  AClass: TSoap3CardinalProperties;
begin
  AClass := TSoap3CardinalProperties.Create;
  try
    AClass.Field1 := 5555;
    AClass.Field2 := 6666;
    AClass.Field3 := 7777;
    FIntf.ProcSimple3CardinalPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 55555,'Field1 is invalid');
    Check(AClass.Field2 = 66666,'Field2 is invalid');
    Check(AClass.Field3 = 77777,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;
{$ENDIF}

procedure TIdSoapInterfaceBaseTests.ProcSimple3Int64PropClass;
var
  AClass: TSoap3Int64Properties;
begin
  AClass := TSoap3Int64Properties.Create;
  try
    AClass.Field1 := 1000000001;
    AClass.Field2 := 1000000002;
    AClass.Field3 := 1000000003;
    FIntf.ProcSimple3Int64PropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 10000000011,'Field1 is invalid');
    Check(AClass.Field2 = 10000000022,'Field2 is invalid');
    Check(AClass.Field3 = 10000000033,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3SinglePropClass;
var
  AClass: TSoap3SingleProperties;
begin
  AClass := TSoap3SingleProperties.Create;
  try
    AClass.Field1 := 123.0;
    AClass.Field2 := 456.0;
    AClass.Field3 := 789.0;
    FIntf.ProcSimple3SinglePropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 111.0,'Field1 is invalid');
    Check(AClass.Field2 = 222.0,'Field2 is invalid');
    Check(AClass.Field3 = 333.0,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3DoublePropClass;
var
  AClass: TSoap3DoubleProperties;
begin
  AClass := TSoap3DoubleProperties.Create;
  try
    AClass.Field1 := 111.1;
    AClass.Field2 := 222.2;
    AClass.Field3 := 333.3;
    FIntf.ProcSimple3DoublePropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(SameReal(AClass.Field1,111.11),'Field1 is invalid');
    Check(SameReal(AClass.Field2,222.22),'Field2 is invalid');
    Check(SameReal(AClass.Field3,333.33),'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3ExtendedPropClass;
var
  AClass: TSoap3ExtendedProperties;
begin
  AClass := TSoap3ExtendedProperties.Create;
  try
    AClass.Field1 := 123.111;
    AClass.Field2 := 456.222;
    AClass.Field3 := 789.333;
    FIntf.ProcSimple3ExtendedPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(SameReal(AClass.Field1,111.111),'Field1 is invalid');
    Check(SameReal(AClass.Field2,222.222),'Field2 is invalid');
    Check(SameReal(AClass.Field3,333.333),'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3CompPropClass;
var
  AClass: TSoap3CompProperties;
begin
  AClass := TSoap3CompProperties.Create;
  try
    AClass.Field1 := 1;
    AClass.Field2 := 2;
    AClass.Field3 := 3;
    FIntf.ProcSimple3CompPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 11,'Field1 is invalid');
    Check(AClass.Field2 = 22,'Field2 is invalid');
    Check(AClass.Field3 = 33,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3CurrPropClass;
var
  AClass: TSoap3CurrProperties;
begin
  AClass := TSoap3CurrProperties.Create;
  try
    AClass.Field1 := 123456.78;
    AClass.Field2 := 234567.89;
    AClass.Field3 := 345678.90;
    FIntf.ProcSimple3CurrPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = -111.11,'Field1 is invalid');
    Check(AClass.Field2 = -222.22,'Field2 is invalid');
    Check(AClass.Field3 = -333.33,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3WideStringPropClass;
var
  AClass: TSoap3WideStringProperties;
begin
  AClass := TSoap3WideStringProperties.Create;
  try
    AClass.Field1 := 'WS1';
    AClass.Field2 := 'WS2';
    AClass.Field3 := 'WS3';
    FIntf.ProcSimple3WideStringPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 'WS1|1','Field1 is invalid');
    Check(AClass.Field2 = 'WS2|2','Field2 is invalid');
    Check(AClass.Field3 = 'WS3|3','Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3CharPropClass;
var
  AClass: TSoap3CharProperties;
begin
  AClass := TSoap3CharProperties.Create;
  try
    AClass.Field1 := 'A';
    AClass.Field2 := 'B';
    AClass.Field3 := 'C';
    FIntf.ProcSimple3CharPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 'a','Field1 is invalid');
    Check(AClass.Field2 = 'b','Field2 is invalid');
    Check(AClass.Field3 = 'c','Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3WideCharPropClass;
var
  AClass: TSoap3WideCharProperties;
begin
  AClass := TSoap3WideCHarProperties.Create;
  try
    AClass.Field1 := '1';
    AClass.Field2 := '2';
    AClass.Field3 := '3';
    FIntf.ProcSimple3WideCharPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = 'A','Field1 is invalid');
    Check(AClass.Field2 = 'B','Field2 is invalid');
    Check(AClass.Field3 = 'C','Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3EnumPropClass;
var
  AClass: TSoap3EnumProperties;
begin
  AClass := TSoap3EnumProperties.Create;
  try
    AClass.Field1 := s3eOne;
    AClass.Field2 := s3eTwo;
    AClass.Field3 := s3eThree;
    FIntf.ProcSimple3EnumPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = s3eFour,'Field1 is invalid');
    Check(AClass.Field2 = s3eFive,'Field2 is invalid');
    Check(AClass.Field3 = s3eSix,'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3SetPropClass;
var
  AClass: TSoap3SetProperties;
begin
  AClass := TSoap3SetProperties.Create;
  try
    AClass.Field1 := [s3eOne];
    AClass.Field2 := [s3eTwo];
    AClass.Field3 := [s3eThree];
    FIntf.ProcSimple3SetPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1 = [s3eOne,s3eFour],'Field1 is invalid');
    Check(AClass.Field2 = [s3eTwo,s3eFive],'Field2 is invalid');
    Check(AClass.Field3 = [s3eThree,s3eSix],'Field3 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3ClassPropClass;
var
  AClass: TSoap3ClassProperties;
begin
  AClass := TSoap3ClassProperties.Create;
  try
    AClass.Field1 := TSoap3StringProperties.Create;
    AClass.Field2 := TSoap3StringProperties.Create;
    AClass.Field3 := TSoap3StringProperties.Create;
    AClass.Field1.Field1 := '1-1';
    AClass.Field1.Field2 := '1-2';
    AClass.Field1.Field3 := '1-3';
    AClass.Field2.Field1 := '2-1';
    AClass.Field2.Field2 := '2-2';
    AClass.Field2.Field3 := '2-3';
    AClass.Field3.Field1 := '3-1';
    AClass.Field3.Field2 := '3-2';
    AClass.Field3.Field3 := '3-3';
    FIntf.ProcSimple3ClassPropClass(AClass);
    Check(AClass <> nil,'AClass should not be nil');
    Check(AClass.Field1.Field1 = '1-1-RET','Field1-1 is invalid');
    Check(AClass.Field1.Field2 = '1-2-RET','Field1-2 is invalid');
    Check(AClass.Field1.Field3 = '1-3-RET','Field1-3 is invalid');
    Check(AClass.Field2.Field1 = '2-1-RET','Field2-1 is invalid');
    Check(AClass.Field2.Field2 = '2-2-RET','Field2-2 is invalid');
    Check(AClass.Field2.Field3 = '2-3-RET','Field2-3 is invalid');
    Check(AClass.Field3.Field1 = '3-1-RET','Field3-1 is invalid');
    Check(AClass.Field3.Field2 = '3-2-RET','Field3-2 is invalid');
    Check(AClass.Field3.Field3 = '3-3-RET','Field3-3 is invalid');
  finally
    AClass.Field1.Free;  // cant use FreeAndNil on a property
    AClass.Field1 := nil;
    AClass.Field2.Free;
    AClass.Field2 := nil;
    AClass.Field3.Free;
    AClass.Field3 := nil;
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.ProcSimple3DynArrPropClass;
var
  AClass: TSoap3DynArrProperties;
  ADyn: TSoap3DynArr;
begin
  AClass := TSoap3DynArrProperties.Create;
  SetLength(ADyn,3);
  try
    ADyn[0] := '1-0';
    ADyn[1] := '1-1';
    ADyn[2] := '1-2';
    AClass.Field1 := copy(ADyn);

    ADyn[0] := '2-0';
    ADyn[1] := '2-1';
    ADyn[2] := '2-2';
    AClass.Field2 := copy(ADyn);

    ADyn[0] := '3-0';
    ADyn[1] := '3-1';
    ADyn[2] := '3-2';
    AClass.Field3 := copy(ADyn);

    FIntf.ProcSimple3DynArrPropClass(AClass);

    Check(AClass <> nil,'AClass should not be nil');

    Check(AClass.Field1[0] = '1-0-RET','Field1-0 is invalid');
    Check(AClass.Field1[1] = '1-1-RET','Field1-1 is invalid');
    Check(AClass.Field1[2] = '1-2-RET','Field1-2 is invalid');

    Check(AClass.Field2[0] = '2-0-RET','Field2-0 is invalid');
    Check(AClass.Field2[1] = '2-1-RET','Field2-1 is invalid');
    Check(AClass.Field2[2] = '2-2-RET','Field2-2 is invalid');

    Check(AClass.Field3[0] = '3-0-RET','Field3-0 is invalid');
    Check(AClass.Field3[1] = '3-1-RET','Field3-1 is invalid');
    Check(AClass.Field3[2] = '3-2-RET','Field3-2 is invalid');
  finally
    FreeAndNil(AClass);
    end;
end;

procedure TIdSoapInterfaceBaseTests.TestInterfaceLifetimes;
Var
  LTestClient: TIdSoapBaseClient;
  LIntf: IIdSoapInterfaceTestsInterface;
  LServer: TIdSoapServer;
{$IFDEF DELPHI4}
  LTempInterface: IUnknown;
{$ENDIF}
begin
  LServer := TIdSoapServer.Create(NIL);
  LServer.ITISource := islResource;
  LServer.ITIResourceName := 'IdSoapInterfaceTests';
  LServer.Active := true;
  LTestClient := TIdSoapClientHTTP.create(nil);
  LTestClient.ITISource := islResource;
  LTestClient.ITIResourceName := 'IdSoapInterfaceTests';
  LTestClient.Active := True;
{$IFDEF DELPHI4}
  LTempInterface := IdSoapD4Interface(LTestClient);
  LIntf := LTempInterface as IIdSoapInterfaceTestsInterface;
  LTempInterface := nil;
{$ELSE}
  LIntf := LTestClient as IIdSoapInterfaceTestsInterface;
{$ENDIF}
  LServer.Active := false;
  FreeAndNil(LTestClient);
  FreeAndNil(LServer);
end;

// Multiple simultaneous interface testing

procedure TIdSoapInterfaceBaseTests.NoInterfaceUsage;
var
  LIntf: IIdSoapInterfaceTestsInterface;
begin
  LIntf := IdSoapD4Interface(GTestClient) as IIdSoapInterfaceTestsInterface;
  LIntf := nil;
end;

procedure TIdSoapInterfaceBaseTests.TestMultipleInterfaces;
var
  LIntf1: IIdSoapInterfaceTestsInterface;
  LIntf2: IIdSoapMultiple;
begin
  LIntf1 := IdSoapD4Interface(GTestClient) as IIdSoapInterfaceTestsInterface;
  LIntf2 := IdSoapD4Interface(GTestClient) as IIdSoapMultiple;
  LIntf1.ProcCall;
  Check(LIntf2.Called(5634) = 'Just a string');
  LIntf1 := nil;
  LIntf2 := nil;
end;

procedure TIdSoapInterfaceBaseTests.TestInterfacesReleaseOrder;
var
  LIntf1: IIdSoapInterfaceTestsInterface;
  LIntf2: IIdSoapMultiple;
begin
  LIntf1 := IdSoapD4Interface(GTestClient) as IIdSoapInterfaceTestsInterface;
  LIntf2 := IdSoapD4Interface(GTestClient) as IIdSoapMultiple;
  LIntf1.ProcCall;
  Check(LIntf2.Called(5634) = 'Just a string');
  LIntf1 := nil;
  LIntf2 := nil;
  LIntf1 := IdSoapD4Interface(GTestClient) as IIdSoapInterfaceTestsInterface;
  LIntf2 := IdSoapD4Interface(GTestClient) as IIdSoapMultiple;
  LIntf1.ProcCall;
  Check(LIntf2.Called(5634) = 'Just a string');
  LIntf2 := nil;
  LIntf1 := nil;
end;

{ TIdSoapInterfaceRPCTests }

procedure TIdSoapInterfaceRPCTests.FixITI(AITI: TIdSoapITI);
var
  i, j : integer;
  LIntf : TIdSoapITIInterface;
  LMeth : TIdSoapITIMethod;
begin
  GInDocumentMode := false;
  for i := 0 to AITI.Interfaces.count -1 do
    begin
    LIntf := AITI.Interfaces.objects[i] as TIdSoapITIInterface;
    for j := 0 to LIntf.Methods.count -1 do
      begin
      LMeth := LIntf.Methods.objects[j] as TIdSoapITIMethod;
      LMeth.EncodingMode := semRPC;
      end;
    end;
end;

{ TIdSoapInterfaceDocLitTests }

procedure TIdSoapInterfaceDocLitTests.FixITI(AITI: TIdSoapITI);
var
  i, j : integer;
  LIntf : TIdSoapITIInterface;
  LMeth : TIdSoapITIMethod;
begin
  GInDocumentMode := true;
  for i := 0 to AITI.Interfaces.count -1 do
    begin
    LIntf := AITI.Interfaces.objects[i] as TIdSoapITIInterface;
    for j := 0 to LIntf.Methods.count -1 do
      begin
      LMeth := LIntf.Methods.objects[j] as TIdSoapITIMethod;
      LMeth.EncodingMode := semDocument;
      end;
    end;
end;

function TIdSoapInterfaceDocLitTests.GetClientEncodingType: TIdSoapEncodingType;
begin
  result := etIdXmlUtf8;
end;

function TIdSoapInterfaceBaseTests.GetXMLProvider: TIdSoapXMLProvider;
begin
  result := xpOpenXML;
end;

{ TIdSoapInterfaceMsXMLTests }
{$IFDEF USE_MSXML}

function TIdSoapInterfaceMsXMLTests.GetXMLProvider: TIdSoapXMLProvider;
begin
  result := xpMsXml;
end;

{$ENDIF}


procedure TIdSoapInterfaceBaseTests.TestSpecialBoolean;
var
  LBool1, LBool2 : TIdSoapBoolean;
begin
  check(FIntf.FuncSpBoolean(nil) = nil);
  LBool1 := TIdSoapBoolean.create;
  try
    LBool1.Value := true;
    LBool2 := FIntf.FuncSpBoolean(LBool1);
    check(Assigned(LBool2));
    check(LBool2.Value = LBool1.Value);
    FreeAndNil(LBool2);
    LBool1.Value := false;
    FIntf.ProcSpBoolean(LBool1);
    check(Assigned(LBool1));
    check(LBool1.Value = true);
    LBool1.Value := true;
    FIntf.ProcSpBoolean(LBool1);
    check(not Assigned(LBool1));
  finally
    FreeAndNil(LBool1);
  end;
end;

procedure TIdSoapInterfaceBaseTests.TestSpecialDouble;
var
  LDbl1, LDbl2 : TIdSoapDouble;
begin
  check(FIntf.FuncSpDouble(nil) = nil);
  LDbl1 := TIdSoapDouble.create;
  try
    LDbl1.Value := 2.1;
    LDbl2 := FIntf.FuncSpDouble(LDbl1);
    check(Assigned(LDbl2));
    check(LDbl2.Value = LDbl1.Value);
    FreeAndNil(LDbl2);
    LDbl1.Value := 2.4;
    FIntf.ProcSpDouble(LDbl1);
    check(Assigned(LDbl1));
    check(FloatEquals(LDbl1.Value, 2.4 * 2.4));
    LDbl1.Value := 0.5;
    FIntf.ProcSpDouble(LDbl1);
    check(not Assigned(LDbl1));
  finally
    FreeAndNil(LDbl1);
  end;
end;

procedure TIdSoapInterfaceBaseTests.TestSpecialInteger;
var
  LInt1, LInt2 : TIdSoapInteger;
begin
  check(FIntf.FuncSpInteger(nil) = nil);
  LInt1 := TIdSoapInteger.create;
  try
    LInt1.Value := 4;
    LInt2 := FIntf.FuncSpInteger(LInt1);
    check(Assigned(LInt2));
    check(LInt2.Value = LInt1.Value);
    FreeAndNil(Lint2);
    LInt1.Value := 5;
    FIntf.ProcSpInteger(LInt1);
    check(Assigned(LInt1));
    check(LInt1.Value = 4);
    LInt1.Value := 2;
    FIntf.ProcSpInteger(LInt1);
    check(not Assigned(LInt1));
  finally
    FreeAndNil(LInt1);
  end;
end;

procedure TIdSoapInterfaceBaseTests.TestSpecialString;
var
  LStr1, LStr2 : TIdSoapString;
begin
  check(FIntf.FuncSpString(nil) = nil);
  LStr1 := TIdSoapString.create;
  try
    LStr1.Value := 'werwer';
    LStr2 := FIntf.FuncSpString(LStr1);
    check(Assigned(LStr2));
    check(LStr2.Value = LStr1.Value);
    FreeAndNil(LStr2);
    LStr1.Value := 'werwer';
    FIntf.ProcSpString(LStr1);
    check(Assigned(LStr1));
    check(LStr1.Value = 'werwer___');
    LStr1.Value := 'we';
    FIntf.ProcSpString(LStr1);
    check(not Assigned(LStr1));
  finally
    FreeAndNil(LStr1);
  end;
end;

procedure TIdSoapInterfaceBaseTests.TestQName;
var
  LQName1, LQName2 : TIdSoapQName;
begin
  check(FIntf.FuncQName(nil) = nil);
  LQName1 := TIdSoapQName.create;
  try
    LQName1.Namespace := 'namespace1';
    LQName1.Value := 'name1';
    LQName2 := FIntf.FuncQName(LQName1);
    check(Assigned(LQName2));
    check(LQName2.Value = LQName1.Value);
    check(LQName2.Namespace = LQName1.Namespace);
    FreeAndNil(LQName2);
    LQName1.Namespace := 'namespace1';
    LQName1.Value := 'name1';
    FIntf.ProcQName(LQName1);
    check(Assigned(LQName1));
    check(LQName1.Namespace = 'namespace');
    check(LQName1.Value = 'name');
    LQName1.Namespace := 'namespace1';
    LQName1.Value := 'na';
    FIntf.ProcQName(LQName1);
    check(not Assigned(LQName1));
  finally
    FreeAndNil(LQName1);
  end;
end;


procedure TIdSoapInterfaceBaseTests.TestRawXml;
var
  LRaw1, LRaw2 : TIdSoapRawXML;
begin
  check(FIntf.FuncRawXML(nil) = nil);
  LRaw1 := TIdSoapRawXML.create;
  try
    LRaw1.Init(GServer.XMLProvider);
    LRaw1.TypeNamespace := 'test';
    LRaw1.TypeName := 'test';
    LRaw1.XML.AppendChild('test1');
    LRaw1.XML.AppendChild('test2');
    LRaw1.XML.setAttribute('tattr', 'tvalue');
    LRaw2 := FIntf.FuncRawXML(LRaw1);
    check(Assigned(LRaw2));
    check(LRaw2.XML.ChildCount = 2);
    check(LRaw2.XML.FirstChild.Name = 'test1');
    check(LRaw2.XML.FirstChild.NextSibling.Name = 'test2');
    check(LRaw2.XML.getAttribute('', 'tattr') = 'tvalue');
    FreeAndNil(LRaw2);
    FIntf.ProcRawXML(LRaw1);
    check(Assigned(LRaw1));
    check(LRaw1.XML.ChildCount = 3);
    check(LRaw1.XML.FirstChild.Name = 'test1');
    check(LRaw1.XML.FirstChild.NextSibling.Name = 'test2');
    check(LRaw1.XML.FirstChild.NextSibling.NextSibling.Name = 'testadd');
    check(LRaw1.XML.getAttribute('', 'tattr') = 'tvalue');
    check(LRaw1.XML.FirstChild.NextSibling.NextSibling.getAttribute('', 'testattr') = 'testvalue');
    LRaw1.XML.removeChild(LRaw1.XML.FirstChild.NextSibling.NextSibling);
    LRaw1.XML.removeChild(LRaw1.XML.FirstChild.NextSibling);
    LRaw1.XML.removeChild(LRaw1.XML.FirstChild);
    FIntf.ProcRawXML(LRaw1);
    check(not Assigned(LRaw1)); 
  finally
    FreeAndNil(LRaw1);
  end;
end;

end.
