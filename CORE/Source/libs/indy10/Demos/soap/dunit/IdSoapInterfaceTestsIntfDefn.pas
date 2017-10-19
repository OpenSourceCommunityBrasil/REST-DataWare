{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16398: IdSoapInterfaceTestsIntfDefn.pas 
{
{   Rev 1.3    23/6/2003 15:15:24  GGrieve
{ fix for V#1
}
{
{   Rev 1.2    19/6/2003 21:36:04  GGrieve
{ Version #1
}
{
{   Rev 1.1    18/3/2003 11:15:50  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:27:46  GGrieve
}
{
Version History:
  23-Jun 2003   Grahame Grieve                  Fix declaration of HexArray
  19 Jun 2003   Grahame Grieve                  Better Test Children
  18-Mar 2003   Grahame Grieve                  QName, RawXML, Schema extensibility, Kylix compile fixes
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Andrew Cumming                  Many more tests for class properties
  24-Jul 2002   Grahame Grieve                  Change to namespace policy
  29-May 2002   Grahame Grieve                  Fix registration of TTestDynByteArr
  29-May 2002   Grahame Grieve                  Added Binary Array tests + move type registration
   4-May 2002   Andrew Cumming                  Added small test to assist in property array bug search
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  09-Apr 2002   Andrew Cumming                  Added tests for nil classes and empty arrays
  09-Apr 2002   Andrew Cumming                  Class properties in a test were not published
  08-Apr 2002   Grahame Grieve                  Binary Properties and Objects by reference tests
  06-Apr 2002   Andrew Cumming                  Added date/time tests
  05-Apr 2002   Andrew Cumming                  Added more tests for arrays of classes
  27-Mar 2002   Grahame Grieve                  Add Tests for Arrays of objects
  14-Mar 2002   Grahame Grieve                  Change Widestring tests (still failing though)
  12-Mar 2002   Grahame Grieve                  Added Binary Tests
   8-Mar 2002   Andrew Cumming                  Added code for Boolean tests
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
   3-Mar 2002   Andrew Cumming                  Added code fo SETs testing
   3-Mar 2002   Andrew Cumming                  Changed declarations slightly to accomodate dyn array properties in D4/D5
   1-Mar 2002   Andrew Cumming                  Added polymorphic class tests
  28-Feb 2002   Andrew Cumming                  Made D4 compatible
  28-Feb 2002   Andrew Cumming                  First version of classes completed
  24-Feb 2002   Andrew Cumming                  Added dynamic array result tests
  24-Feb 2002   Andrew Cumming                  More dynamic array tests
  22-Feb 2002   Andrew Cumming                  More dynamic array tests + ASCII string escape test
  12-Feb 2002   Merged with IndySOAP masters
}

unit IdSoapInterfaceTestsIntfDefn;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapDateTime,
  IdSoapDebug,
  IdSoapRawXml,
  IdSoapTypeRegistry,
  TypInfo;

procedure DefineString(AStringType: TTypeKind);
procedure DefineValues(AForceCardinal: Boolean; AOrdType: TOrdType; ATestValues1: Boolean);
procedure DefineInt64(ATestValues1: Boolean);
procedure DefineReal(AFloatType: TFloatType; ATestValues1: Boolean);

var
  g1, g2, g3, g4, g5: Int64;
  gR1, gR2, gR3, gR4, gR5: Extended;
  gS1, gS2, gS3, gS4, gS5: String;
  gWS1, gWS2, gWS3, gWS4, gWS5: String;

type
  TTestDynCurrency1Arr = array of Currency;                        // for testing dynamic currency arrays
  TTestDynIntegerArr   = array of Integer;                         // for testing dynamic integer arrays
  TTestDynInteger2Arr  = array of array of Integer;                // for testing dynamic integer arrays depth 2
  TTestDynString3Arr   = array of array of array of string;        // for testing dynamic string arrays
  TTestDynByteArr      = array of Byte;                         // for testing dynamic byte arrays
  TTestDynByte4Arr     = array of array of array of array of byte; // for testing dynamic byte arrays
  TTestDynStreamArray  = array of TStream;                         // for testing dynmaic TStream Arrays
  TTestDynHexStreamArray  = array of THexStream;                         // for testing dynmaic TStream Arrays

  TString50 = String[50];

  TSoapVirtualClassTestBase = class ( TIdBaseSoapableClass )
    private
      FByte: Byte;
    published
      property AByte: Byte read FByte write FByte;
    end;

  TSoapVirtualClassTestChild = class ( TSoapVirtualClassTestBase )
    private
      FInt: Integer;
    published
      property AInt: Integer read FInt write FInt;
    end;

  TSoapSimpleTestClass = Class ( TIdBaseSoapableClass )
    private
      FFieldString: String;
    public
    published
      property FieldString: String read FFieldString write FFieldString;
    end;

  TSoapNilPropClass = class ( TIdBaseSoapableClass )
    private
      FAClass: TSoapSimpleTestClass;
    published
      property AClass: TSoapSimpleTestClass read FAClass write FAClass;
    end;

  TSoap3StringProperties = class (TIdBaseSoapableClass)
  private
    FField1: String;
    FField2: String;
    FField3: String;
  published
    property Field1: String read FField1 write FField1;
    property Field2: String read FField2 write FField2;
    property Field3: String read FField3 write FField3;
  end;

  TSoap3ShortStringProperties = class(TIdBaseSoapableClass)
  private
    FField1: ShortString;
    FField2: ShortString;
    FField3: ShortString;
  published
    property Field1: ShortString read FField1 write FField1;
    property Field2: ShortString read FField2 write FField2;
    property Field3: ShortString read FField3 write FField3;
  end;

  TSoap3ByteProperties = class(TIdBaseSoapableClass)
  private
    FField1: Byte;
    FField2: Byte;
    FField3: Byte;
  published
    property Field1: Byte read FField1 write FField1;
    property Field2: Byte read FField2 write FField2;
    property Field3: Byte read FField3 write FField3;
  end;

  TSoap3ShortIntProperties = class(TIdBaseSoapableClass)
  private
    FField1: ShortInt;
    FField2: ShortInt;
    FField3: ShortInt;
  published
    property Field1: ShortInt read FField1 write FField1;
    property Field2: ShortInt read FField2 write FField2;
    property Field3: ShortInt read FField3 write FField3;
  end;

  TSoap3SmallIntProperties = class(TIdBaseSoapableClass)
  private
    FField1: SmallInt;
    FField2: SmallInt;
    FField3: SmallInt;
  published
    property Field1: SmallInt read FField1 write FField1;
    property Field2: SmallInt read FField2 write FField2;
    property Field3: SmallInt read FField3 write FField3;
  end;

  TSoap3WordProperties = class(TIdBaseSoapableClass)
  private
    FField1: Word;
    FField2: Word;
    FField3: Word;
  published
    property Field1: Word read FField1 write FField1;
    property Field2: Word read FField2 write FField2;
    property Field3: Word read FField3 write FField3;
  end;

  TSoap3IntegerProperties = class(TIdBaseSoapableClass)
  private
    FField1: Integer;
    FField2: Integer;
    FField3: Integer;
  published
    property Field1: Integer read FField1 write FField1;
    property Field2: Integer read FField2 write FField2;
    property Field3: Integer read FField3 write FField3;
  end;

{$IFNDEF DELPHI4}
  TSoap3CardinalProperties = class(TIdBaseSoapableClass)
  private
    FField1: Cardinal;
    FField2: Cardinal;
    FField3: Cardinal;
  published
    property Field1: Cardinal read FField1 write FField1;
    property Field2: Cardinal read FField2 write FField2;
    property Field3: Cardinal read FField3 write FField3;
  end;
{$ENDIF}

  TSoap3Int64Properties = class(TIdBaseSoapableClass)
  private
    FField1: Int64;
    FField2: Int64;
    FField3: Int64;
  published
    property Field1: Int64 read FField1 write FField1;
    property Field2: Int64 read FField2 write FField2;
    property Field3: Int64 read FField3 write FField3;
  end;

  TSoap3SingleProperties = class(TIdBaseSoapableClass)
  private
    FField1: Single;
    FField2: Single;
    FField3: Single;
  published
    property Field1: Single read FField1 write FField1;
    property Field2: Single read FField2 write FField2;
    property Field3: Single read FField3 write FField3;
  end;

  TSoap3DoubleProperties = class(TIdBaseSoapableClass)
  private
    FField1: Double;
    FField2: Double;
    FField3: Double;
  published
    property Field1: Double read FField1 write FField1;
    property Field2: Double read FField2 write FField2;
    property Field3: Double read FField3 write FField3;
  end;

  TSoap3ExtendedProperties = class(TIdBaseSoapableClass)
  private
    FField1: Extended;
    FField2: Extended;
    FField3: Extended;
  published
    property Field1: Extended read FField1 write FField1;
    property Field2: Extended read FField2 write FField2;
    property Field3: Extended read FField3 write FField3;
  end;

  TSoap3CompProperties = class(TIdBaseSoapableClass)
  private
    FField1: Comp;
    FField2: Comp;
    FField3: Comp;
  published
    property Field1: Comp read FField1 write FField1;
    property Field2: Comp read FField2 write FField2;
    property Field3: Comp read FField3 write FField3;
  end;

  TSoap3CurrProperties = class(TIdBaseSoapableClass)
  private
    FField1: Currency;
    FField2: Currency;
    FField3: Currency;
  published
    property Field1: Currency read FField1 write FField1;
    property Field2: Currency read FField2 write FField2;
    property Field3: Currency read FField3 write FField3;
  end;

  TSoap3WideStringProperties = class(TIdBaseSoapableClass)
  private
    FField1: WideString;
    FField2: WideString;
    FField3: WideString;
  published
    property Field1: WideString read FField1 write FField1;
    property Field2: WideString read FField2 write FField2;
    property Field3: WideString read FField3 write FField3;
  end;

  TSoap3CharProperties = class(TIdBaseSoapableClass)
  private
    FField1: Char;
    FField2: Char;
    FField3: Char;
  published
    property Field1: Char read FField1 write FField1;
    property Field2: Char read FField2 write FField2;
    property Field3: Char read FField3 write FField3;
  end;

  TSoap3WideCharProperties = class(TIdBaseSoapableClass)
  private
    FField1: WideChar;
    FField2: WideChar;
    FField3: WideChar;
  published
    property Field1: WideChar read FField1 write FField1;
    property Field2: WideChar read FField2 write FField2;
    property Field3: WideChar read FField3 write FField3;
  end;

  TSoap3Enum = (s3eOne,s3eTwo,s3eThree,s3eFour,s3eFive,s3eSix);

  TSoap3EnumProperties = class(TIdBaseSoapableClass)
  private
    FField1: TSoap3Enum;
    FField2: TSoap3Enum;
    FField3: TSoap3Enum;
  published
    property Field1: TSoap3Enum read FField1 write FField1;
    property Field2: TSoap3Enum read FField2 write FField2;
    property Field3: TSoap3Enum read FField3 write FField3;
  end;

  TSoap3Set = set of TSoap3Enum;

  TSoap3SetProperties = class(TIdBaseSoapableClass)
  private
    FField1: TSoap3Set;
    FField2: TSoap3Set;
    FField3: TSoap3Set;
  published
    property Field1: TSoap3Set read FField1 write FField1;
    property Field2: TSoap3Set read FField2 write FField2;
    property Field3: TSoap3Set read FField3 write FField3;
  end;

  TSoap3ClassProperties = class(TIdBaseSoapableClass)
  private
    FField1: TSoap3StringProperties;
    FField2: TSoap3StringProperties;
    FField3: TSoap3StringProperties;
  published
    property Field1: TSoap3StringProperties read FField1 write FField1;
    property Field2: TSoap3StringProperties read FField2 write FField2;
    property Field3: TSoap3StringProperties read FField3 write FField3;
  end;

  TSoap3DynArr = array of String;

  TSoap3DynArrProperties = class(TIdBaseSoapableClass)
  private
    FField1: TSoap3DynArr;
    FField2: TSoap3DynArr;
    FField3: TSoap3DynArr;
  public
{$IFDEF DELPHI4OR5}   // alternate D4/D5 method for dynamic array properties
    property Field1: TSoap3DynArr read FField1 write FField1;
    property Field2: TSoap3DynArr read FField2 write FField2;
    property Field3: TSoap3DynArr read FField3 write FField3;
{$ENDIF}
  published
{$IFNDEF DELPHI4OR5}
    property Field1: TSoap3DynArr read FField1 write FField1;
    property Field2: TSoap3DynArr read FField2 write FField2;
    property Field3: TSoap3DynArr read FField3 write FField3;
{$ENDIF}
  end;

  TTestDynObj1Arr      = array of TSoapSimpleTestClass;                    // for testing dynamic object arrays
  TTestDynObj2Arr      = array of array of TSoapSimpleTestClass;           // for testing dynamic object arrays
  TTestDynObj3Arr      = array of array of array of TSoapSimpleTestClass;  // for testing dynamic object arrays

  TSmallEnum = (seOne,seTwo,seThree,seFour,seFive,seSix,seSeven,seEight,seNine,seTen);
  TSmallSet = set of TSmallEnum;

  TSoapTestClass = Class ( TIdBaseSoapableClass )
    private
      FFieldInteger: Integer;
      FStaticInteger: Integer;
      FVirtualInteger: Integer;
      FFieldAnsiString: String;
      FStaticAnsiString: String;
      FVirtualAnsiString: String;
      FFieldShortString: TString50;
      FStaticShortString: TString50;
      FVirtualShortString: TString50;
      FFieldInt64: Int64;
      FStaticInt64: Int64;
      FVirtualInt64: Int64;
      FFieldWideString: WideString;
      FStaticWideString: WideString;
      FVirtualWideString: WideString;
      FFieldChar: Char;
      FStaticChar: Char;
      FVirtualChar: Char;
      FFieldWideChar: WideChar;
      FStaticWideChar: WideChar;
      FVirtualWideChar: WideChar;
      FFieldSingle: Single;
      FStaticSingle: Single;
      FVirtualSingle: Single;
      FFieldDouble: Double;
      FStaticDouble: Double;
      FVirtualDouble: Double;
      FFieldExtended: Extended;
      FStaticExtended: Extended;
      FVirtualExtended: Extended;
      FFieldComp: Comp;
      FStaticComp: Comp;
      FVirtualComp: Comp;
      FFieldCurrency: Currency;
      FStaticCurrency: Currency;
      FVirtualCurrency: Currency;
      FFieldClass: TSoapSimpleTestClass;
      FStaticClass: TSoapSimpleTestClass;
      FVirtualClass: TSoapSimpleTestClass;
      FStaticArray: TTestDynCurrency1Arr;
      FVirtualArray: TTestDynCurrency1Arr;
      FFieldEnum: TSmallEnum;
      FStaticEnum: TSmallEnum;
      FVirtualEnum: TSmallEnum;
      FFieldSet: TSmallSet;
      FStaticSet: TSmallSet;
      FVirtualSet: TSmallSet;
      function  GetStaticInteger: Integer;
      function  GetVirtualInteger: Integer; virtual;
      function  GetStaticAnsiString: String;
      function  GetVirtualAnsiString: string; virtual;
      procedure SetStaticInteger(const Value: Integer);
      procedure SetVirtualInteger(const Value: Integer); virtual;
      procedure SetStaticAnsiString(const Value: String);
      procedure SetVirtualAnsiString(const Value: string); virtual;
      function  GetStaticShortString: TString50;
      function  GetVirtualShortString: TString50; virtual;
      procedure SetStaticShortString(const Value: TString50);
      procedure SetVirtualShortString(const Value: TString50); virtual;
      function  GetStaticInt64: Int64;
      function  GetVirtualInt64: Int64; virtual;
      procedure SetStaticInt64(const Value: Int64);
      procedure SetVirtualInt64(const Value: Int64); virtual;
      function  GetStaticWideString: WideString;
      function  GetVirtualWideString: WideString; virtual;
      procedure SetStaticWideString(const Value: WideString);
      procedure SetVirtualWideString(const Value: WideString); virtual;
      function  GetStaticChar: Char;
      function  GetVirtualChar: Char; virtual;
      procedure SetStaticChar(const Value: Char);
      procedure SetVirtualChar(const Value: Char); virtual;
      function  GetStaticWideChar: WideChar;
      function  GetVirtualWideChar: WideChar; virtual;
      procedure SetStaticWideChar(const Value: WideChar);
      procedure SetVirtualWideChar(const Value: WideChar); virtual;
      function  GetStaticComp: Comp;
      function  GetStaticCurrency: Currency;
      function  GetStaticDouble: Double;
      function  GetStaticExtended: Extended;
      function  GetStaticSingle: Single;
      function  GetVirtualComp: Comp; virtual;
      function  GetVirtualCurrency: Currency; virtual;
      function  GetVirtualDouble: Double; virtual;
      function  GetVirtualExtended: Extended; virtual;
      function  GetVirtualSingle: Single; virtual;
      procedure SetStaticComp(const Value: Comp);
      procedure SetStaticCurrency(const Value: Currency);
      procedure SetStaticDouble(const Value: Double);
      procedure SetStaticExtended(const Value: Extended);
      procedure SetStaticSingle(const Value: Single);
      procedure SetVirtualComp(const Value: Comp); virtual;
      procedure SetVirtualCurrency(const Value: Currency); virtual;
      procedure SetVirtualDouble(const Value: Double); virtual;
      procedure SetVirtualExtended(const Value: Extended); virtual;
      procedure SetVirtualSingle(const Value: Single); virtual;
      function  GetStaticClass: TSoapSimpleTestClass;
      function  GetVirtualClass: TSoapSimpleTestClass;
      procedure SetStaticClass(const Value: TSoapSimpleTestClass);
      procedure SetVirtualClass(const Value: TSoapSimpleTestClass);
      function GetStaticEnum: TSmallEnum;
      function GetVirtualEnum: TSmallEnum; virtual;
      procedure SetStaticEnum(const Value: TSmallEnum);
      procedure SetVirtualEnum(const Value: TSmallEnum); virtual;
      function GetStaticSet: TSmallSet;
      function GetVirtualSet: TSmallSet; virtual;
      procedure SetStaticSet(const Value: TSmallSet);
      procedure SetVirtualSet(const Value: TSmallSet); virtual;
    public
      FFieldArray: TTestDynCurrency1Arr;  // needed in public as the registration is in another unit
      Constructor Create; Override;
      Destructor Destroy; Override;
// the next 4 methods need public access as there registered in another unit
      function  GetStaticArray: TTestDynCurrency1Arr;
      function  GetVirtualArray: TTestDynCurrency1Arr; virtual;
      procedure SetStaticArray(const Value: TTestDynCurrency1Arr);
      procedure SetVirtualArray(const Value: TTestDynCurrency1Arr); virtual;
{$IFDEF DELPHI4OR5}   // alternate D4/D5 method for dynamic array properties
      property VirtualArray: TTestDynCurrency1Arr read GetVirtualArray write SetVirtualArray;
      property StaticArray: TTestDynCurrency1Arr read GetStaticArray write SetStaticArray;
      property FieldArray: TTestDynCurrency1Arr read FFieldArray write FFieldArray;
{$ENDIF}
    published
      property VirtualInteger: Integer read GetVirtualInteger write SetVirtualInteger;
      property StaticInteger: Integer read GetStaticInteger write SetStaticInteger;
      property FieldInteger: Integer read FFieldInteger write FFieldInteger;
      property VirtualAnsiString: string read GetVirtualAnsiString write SetVirtualAnsiString;
      property StaticAnsiString: String read GetStaticAnsiString write SetStaticAnsiString;
      property FieldAnsiString: String read FFieldAnsiString write FFieldAnsiString;
      property VirtualShortString: TString50 read GetVirtualShortString write SetVirtualShortString;
      property StaticShortString: TString50 read GetStaticShortString write SetStaticShortString;
      property FieldShortString: TString50 read FFieldShortString write FFieldShortString;
      property VirtualInt64: Int64 read GetVirtualInt64 write SetVirtualInt64;
      property StaticInt64: Int64 read GetStaticInt64 write SetStaticInt64;
      property FieldInt64: Int64 read FFieldInt64 write FFieldInt64;
      property VirtualWideString: WideString read GetVirtualWideString write SetVirtualWideString;
      property StaticWideString: WideString read GetStaticWideString write SetStaticWideString;
      property FieldWideString: WideString read FFieldWideString write FFieldWideString;
      property VirtualChar: Char read GetVirtualChar write SetVirtualChar;
      property StaticChar: Char read GetStaticChar write SetStaticChar;
      property FieldChar: Char read FFieldChar write FFieldChar;
      property VirtualWideChar: WideChar read GetVirtualWideChar write SetVirtualWideChar;
      property StaticWideChar: WideChar read GetStaticWideChar write SetStaticWideChar;
      property FieldWideChar: WideChar read FFieldWideChar write FFieldWideChar;
      property VirtualSingle: Single read GetVirtualSingle write SetVirtualSingle;
      property StaticSingle: Single read GetStaticSingle write SetStaticSingle;
      property FieldSingle: Single read FFieldSingle write FFieldSingle;
      property VirtualDouble: Double read GetVirtualDouble write SetVirtualDouble;
      property StaticDouble: Double read GetStaticDouble write SetStaticDouble;
      property FieldDouble: Double read FFieldDouble write FFieldDouble;
      property VirtualExtended: Extended read GetVirtualExtended write SetVirtualExtended;
      property StaticExtended: Extended read GetStaticExtended write SetStaticExtended;
      property FieldExtended: Extended read FFieldExtended write FFieldExtended;
      property VirtualComp: Comp read GetVirtualComp write SetVirtualComp;
      property StaticComp: Comp read GetStaticComp write SetStaticComp;
      property FieldComp: Comp read FFieldComp write FFieldComp;
      property VirtualCurrency: Currency read GetVirtualCurrency write SetVirtualCurrency;
      property StaticCurrency: Currency read GetStaticCurrency write SetStaticCurrency;
      property FieldCurrency: Currency read FFieldCurrency write FFieldCurrency;
      property VirtualClass: TSoapSimpleTestClass read GetVirtualClass write SetVirtualClass;
      property StaticClass: TSoapSimpleTestClass read GetStaticClass write SetStaticClass;
      property FieldClass: TSoapSimpleTestClass read FFieldClass write FFieldClass;
{$IFNDEF DELPHI4OR5}
      property VirtualArray: TTestDynCurrency1Arr read GetVirtualArray write SetVirtualArray;
      property StaticArray: TTestDynCurrency1Arr read GetStaticArray write SetStaticArray;
      property FieldArray: TTestDynCurrency1Arr read FFieldArray write FFieldArray;
{$ENDIF}
      property VirtualEnum: TSmallEnum read GetVirtualEnum write SetVirtualEnum;
      property StaticEnum: TSmallEnum read GetStaticEnum write SetStaticEnum;
      property FieldEnum: TSmallEnum read FFieldEnum write FFieldEnum;
      property VirtualSet: TSmallSet read GetVirtualSet write SetVirtualSet;
      property StaticSet: TSmallSet read GetStaticSet write SetStaticSet;
      property FieldSet: TSmallSet read FFieldSet write FFieldSet;
    end;

  TSoapFieldArrClass = class(TIdBaseSoapableClass)
  private
    FFieldArray: TTestDynCurrency1Arr;
  public
{$IFDEF DELPHI4OR5}   // alternate D4/D5 method for dynamic array properties
    property FieldArray: TTestDynCurrency1Arr read FFieldArray write FFieldArray;
{$ENDIF}
  published
{$IFNDEF DELPHI4OR5}
    property FieldArray: TTestDynCurrency1Arr read FFieldArray write FFieldArray;
{$ENDIF}
  end;

  // this is just a largeee enumeration to check agains the 256 boundary
  TLargeEnum = (le0, le1, le2, le3, le4, le5, le6, le7, le8, le9,
    le10, le11, le12, le13, le14, le15, le16, le17, le18, le19,
    le20, le21, le22, le23, le24, le25, le26, le27, le28, le29,
    le30, le31, le32, le33, le34, le35, le36, le37, le38, le39,
    le40, le41, le42, le43, le44, le45, le46, le47, le48, le49,
    le50, le51, le52, le53, le54, le55, le56, le57, le58, le59,
    le60, le61, le62, le63, le64, le65, le66, le67, le68, le69,
    le70, le71, le72, le73, le74, le75, le76, le77, le78, le79,
    le80, le81, le82, le83, le84, le85, le86, le87, le88, le89,
    le90, le91, le92, le93, le94, le95, le96, le97, le98, le99,
    le100, le101, le102, le103, le104, le105, le106, le107, le108, le109,
    le110, le111, le112, le113, le114, le115, le116, le117, le118, le119,
    le120, le121, le122, le123, le124, le125, le126, le127, le128, le129,
    le130, le131, le132, le133, le134, le135, le136, le137, le138, le139,
    le140, le141, le142, le143, le144, le145, le146, le147, le148, le149,
    le150, le151, le152, le153, le154, le155, le156, le157, le158, le159,
    le160, le161, le162, le163, le164, le165, le166, le167, le168, le169,
    le170, le171, le172, le173, le174, le175, le176, le177, le178, le179,
    le180, le181, le182, le183, le184, le185, le186, le187, le188, le189,
    le190, le191, le192, le193, le194, le195, le196, le197, le198, le199,
    le200, le201, le202, le203, le204, le205, le206, le207, le208, le209,
    le210, le211, le212, le213, le214, le215, le216, le217, le218, le219,
    le220, le221, le222, le223, le224, le225, le226, le227, le228, le229,
    le230, le231, le232, le233, le234, le235, le236, le237, le238, le239,
    le240, le241, le242, le243, le244, le245, le246, le247, le248, le249,
    le250, le251, le252, le253, le254, le255, le256, le257, le258, le259,
    le260, le261, le262, le263, le264, le265, le266, le267, le268, le269,
    le270, le271, le272, le273, le274, le275, le276, le277, le278, le279,
    le280, le281, le282, le283, le284, le285, le286, le287, le288, le289,
    le290, le291, le292, le293, le294, le295, le296, le297, le298, le299);

  TBinaryTestClass = class (TIdBaseSoapableClass)
  private
    FStream : TStream;
    FSize : integer;
    FCheckDigit : Byte;
  published
    property Stream : TStream read FStream write FStream;
    property Size : integer read FSize write FSize;
    property CheckDigit : byte read FCheckDigit write FCheckDigit;
  end;

  THexBinaryTestClass = class (TIdBaseSoapableClass)
  private
    FStream : THexStream;
    FSize : integer;
    FCheckDigit : Byte;
  published
    property HexStream : THexStream read FStream write FStream;
    property Size : integer read FSize write FSize;
    property CheckDigit : byte read FCheckDigit write FCheckDigit;
  end;

  TReferenceTestingObject = class (TIdBaseSoapableClass)
  private
    FChild: TReferenceTestingObject;
    FProp : string;
  public
    Constructor create;    override;
  published
    property Child : TReferenceTestingObject read FChild write FChild;
    property Prop : string read FProp write FProp;
  end;

Type
  IIdSoapInterfaceTestsInterface = interface(IIDSoapInterface)
    ['{5E3EB4B6-1DB9-42C9-A048-4D9B318BD9A0}']
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
    // BYTE TESTS
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
    // CHAR TESTS
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
    // BOOLEAN TESTS
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
    procedure ProcReferenceTesting1(ASame : boolean; AObj1, AObj2 : TReferenceTestingObject);  stdcall;
    procedure ProcReferenceTesting2(out VObj1, VObj2 : TReferenceTestingObject); stdcall;
    procedure ProcNilClass(AClass: TSoapSimpleTestClass); stdcall;
    procedure ProcConstNilClass(const AClass: TSoapSimpleTestClass); stdcall;
    procedure ProcOutNilClass(Out AClass: TSoapSimpleTestClass); stdcall;
    procedure ProcVarNilClass(Var AClass: TSoapSimpleTestClass); stdcall;
    function  FuncRetNilClass: TSoapSimpleTestClass; stdcall;
    function  FuncRetNilPropClass: TSoapNilPropClass; stdcall;

    // CLASS property/order tests
    procedure ProcSimple3StringPropClass(Var AClass: TSoap3StringProperties); stdcall;
    procedure ProcSimple3ShortStringPropClass(Var AClass: TSoap3ShortStringProperties); stdcall;
    procedure ProcSimple3BytePropClass(Var AClass: TSoap3ByteProperties); stdcall;
    procedure ProcSimple3ShortIntPropClass(Var AClass: TSoap3ShortIntProperties); stdcall;
    procedure ProcSimple3SmallIntPropClass(Var AClass: TSoap3SmallIntProperties); stdcall;
    procedure ProcSimple3WordPropClass(Var AClass: TSoap3WordProperties); stdcall;
    procedure ProcSimple3IntegerPropClass(Var AClass: TSoap3IntegerProperties); stdcall;
{$IFNDEF DELPHI4}
    procedure ProcSimple3CardinalPropClass(Var AClass: TSoap3CardinalProperties); stdcall;
{$ENDIF}
    procedure ProcSimple3SinglePropClass(Var AClass: TSoap3SingleProperties); stdcall;
    procedure ProcSimple3DoublePropClass(Var AClass: TSoap3DoubleProperties); stdcall;
    procedure ProcSimple3ExtendedPropClass(Var AClass: TSoap3ExtendedProperties); stdcall;
    procedure ProcSimple3CompPropClass(Var AClass: TSoap3CompProperties); stdcall;
    procedure ProcSimple3CurrPropClass(Var AClass: TSoap3CurrProperties); stdcall;
    procedure ProcSimple3WideStringPropClass(Var AClass: TSoap3WideStringProperties); stdcall;
    procedure ProcSimple3Int64PropClass(Var AClass: TSoap3Int64Properties); stdcall;
    procedure ProcSimple3CharPropClass(Var AClass: TSoap3CharProperties); stdcall;
    procedure ProcSimple3WideCHarPropClass(Var AClass: TSoap3WideCharProperties); stdcall;
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

resourcestring
  KdeVersionMark = {!!uv}'!-!DevTestsIntfDefn.pas,0.00-005,22 Jan 02 17:19,13316';

implementation

Uses
  IdSoapRTTIHelpers,
  IdSoapUtilities,
  SysUtils;

procedure DefineString(AStringType: TTypeKind);
var
  w : Widechar;
begin
  case AStringType of
    tkString:        // ShortString
        begin
        gS1 := 'This is a string gS1';
        gS2 := 'This is a string gS2. Just another one';
        gS3 := 'This is a string gS3. more strings to test';
        gS4 := 'This is a string gS4. yes, even more';
        gS5 := 'This is a string gS5. Finally, the last one';
        end;
    tkLString:       // AnsiString
        begin
        gS1 := 'This is atring gS1';
        gS2 := 'This is atring gS2. Just another one';
        gS3 := 'This is atring gS3. more strings to test';
        gS4 := 'This is atring gS4. yes, even more';
        gS5 := 'This is atring gS5. Finally, the last one';
        end;
    tkWString:       // WideString
        begin
        w := chr(23423);
        gWS1 := 'This is a wide string gS1 '+w;
        gWS2 := 'This is a wide string gS2. '+w+' Just another one';
        gWS3 := 'This is a wide string gS3. '+w+' more strings to test';
        gWS4 := 'This is a wide string gS4. '+w+' yes, even more';
        gWS5 := 'This is a wide string gS5. '+w+' Finally, the last one';
        end;
    end;
end;

procedure DefineReal(AFloatType: TFloatType; ATestValues1: Boolean);
begin
  case AFloatType of
    ftSingle:
      if ATestValues1 then
        begin
        gR1 := 123.456;
        gR2 := 675.7864;
        gR3 := 8978.456456;
        gR4 := 4546.46545;
        gR5 := 4564.65645;
        end
      else
          begin
          gR1 := -123.456;
          gR2 := -675.7864;
          gR3 := -8978.456456;
          gR4 := -4546.46545;
          gR5 := -4564.65645;
          end;
      ftDouble:
      if ATestValues1 then
        begin
        gR1 := 123.456;
        gR2 := 675.7864;
        gR3 := 897489546.456456;
        gR4 := 456546.46545;
        gR5 := 45464.65645;
        end
      else
          begin
          gR1 := -123.456;
          gR2 := -675.7864;
          gR3 := -897489546.456456;
          gR4 := -456546.46545;
          gR5 := -45464.65645;
          end;
      ftExtended:
      if ATestValues1 then
        begin
        gR1 := 123.456;
        gR2 := 675.7864;
        gR3 := 897489546.456456;
        gR4 := 456546.46545;
        gR5 := 45464.65645;
        end
      else
          begin
          gR1 := -123.456;
          gR2 := -675.7864;
          gR3 := -897489546.456456;
          gR4 := -456546.46545;
          gR5 := -45464.65645;
          end;
      ftComp:
      if ATestValues1 then
        begin
        gR1 := 123456;
        gR2 := 6757864;
        gR3 := 8974895;
        gR4 := 456546;
        gR5 := 45464;
        end
      else
          begin
          gR1 := -123456;
          gR2 := -6757864;
          gR3 := -8974895;
          gR4 := -456546;
          gR5 := -45464;
          end;
      ftCurr:
      if ATestValues1 then
        begin
        gR1 := 123.456;
        gR2 := 675.7864;
        gR3 := 897489546.456456;
        gR4 := 456546.46545;
        gR5 := 45464.65645;
        end
      else
          begin
          gR1 := -123.456;
          gR2 := -675.7864;
          gR3 := -897489546.456456;
          gR4 := -456546.46545;
          gR5 := -45464.65645;
          end;
    end;
end;

procedure DefineInt64(ATestValues1: Boolean);
begin
  if ATestValues1 then
    begin
    g1 := $73284552;
    g2 := $26563762;
    g3 := $0897ac77;
    g4 := $68430dcf;
    g5 := $59837228;
    end
  else
    begin
    g1 := -$73284552;
    g2 := -$26563762;
    g3 := -$0897ac77;
    g4 := -$68430dcf;
    g5 := -$59837228;
    end;
end;

procedure DefineValues(AForceCardinal: Boolean; AOrdType: TOrdType; ATestValues1: Boolean);
begin
{$IFDEF DELPHI4}
  if AForceCardinal then    // D4 doesnt have a otULong so we have to force it for testing
    begin
    if ATestValues1 then
      begin
      g1 := $92021234;
      g2 := $d4005678;
      g3 := $b6119012;
      g4 := $a8323456;
      g5 := $90567890;
      end
    else
      begin
      g1 := $92021234;
      g2 := $d4005678;
      g3 := $b6119012;
      g4 := $a8323456;
      g5 := $90567890;
      end;
    exit;
    end;

{$ENDIF}
  case AOrdType of
    otUByte:
        begin
        if ATestValues1 then
          begin
          g1 := 12;
          g2 := 34;
          g3 := 56;
          g4 := 78;
          g5 := 90;
          end
        else
          begin
          g1 := 12;
          g2 := 34;
          g3 := 56;
          g4 := 78;
          g5 := 90;
          end;
        end;
    otSByte:
        begin
        if ATestValues1 then
          begin
          g1 := 12;
          g2 := 34;
          g3 := 56;
          g4 := 78;
          g5 := 90;
          end
        else
          begin
          g1 := -12;
          g2 := -34;
          g3 := -56;
          g4 := -78;
          g5 := -90;
          end;
        end;
    otUWord:
        begin
        if ATestValues1 then
          begin
          g1 := $9202;
          g2 := $d400;
          g3 := $b611;
          g4 := $a832;
          g5 := $9056;
          end
        else
          begin
          g1 := $9202;
          g2 := $d400;
          g3 := $b611;
          g4 := $a832;
          g5 := $9056;
          end;
        end;
    otSWord:
        begin
        if ATestValues1 then
          begin
          g1 := $5202;
          g2 := $4400;
          g3 := $6611;
          g4 := $1832;
          g5 := $2056;
          end
        else
          begin
          g1 := -$5202;
          g2 := -$4400;
          g3 := -$6611;
          g4 := -$1832;
          g5 := -$2056;
          end;
        end;
{$IFNDEF DELPHI4}
    otULong:
        begin
        if ATestValues1 then
          begin
          g1 := $92021234;
          g2 := $d4005678;
          g3 := $b6119012;
          g4 := $a8323456;
          g5 := $90567890;
          end
        else
          begin
          g1 := $92021234;
          g2 := $d4005678;
          g3 := $b6119012;
          g4 := $a8323456;
          g5 := $90567890;
          end;
        end;
{$ENDIF}
    otSLong:
        begin
        if ATestValues1 then
          begin
          g1 := $52025432;
          g2 := $44001658;
          g3 := $66113855;
          g4 := $18327453;
          g5 := $20568584;
          end
        else
          begin
          g1 := -$52025432;
          g2 := -$44001658;
          g3 := -$66113855;
          g4 := -$18327453;
          g5 := -$20568584;
          end;
        end;
    end;
end;

{ TReferenceTestingObject }

Constructor TReferenceTestingObject.create;
begin
  inherited;
  FProp := 'Value';
end;

{ TSoapTestClass }

constructor TSoapTestClass.Create;
begin
  Inherited;
  FFieldInteger := 1;
end;

destructor TSoapTestClass.Destroy;
begin
  FreeAndNil(FFieldClass);
  FreeAndNil(FStaticClass);
  FreeAndNil(FVirtualClass);
  inherited;
end;

function TSoapTestClass.GetStaticInteger: Integer;
begin
  result := FStaticInteger;
end;

function TSoapTestClass.GetVirtualInteger: Integer;
begin
  Result := FVirtualInteger;
end;

function TSoapTestClass.GetStaticAnsiString: String;
begin
  result := FStaticAnsiString;
end;

function TSoapTestClass.GetVirtualAnsiString: string;
begin
  Result := FVirtualAnsiString;
end;

procedure TSoapTestClass.SetStaticInteger(const Value: Integer);
begin
  FStaticInteger := Value;
end;

procedure TSoapTestClass.SetVirtualInteger(const Value: Integer);
begin
  FVirtualInteger := Value;
end;

procedure TSoapTestClass.SetStaticAnsiString(const Value: String);
begin
  FStaticAnsiString := Value;
end;

procedure TSoapTestClass.SetVirtualAnsiString(const Value: string);
begin
  FVirtualAnsiString := Value;
end;

function TSoapTestClass.GetStaticShortString: TString50;
begin
  Result := FStaticShortString;
end;

function TSoapTestClass.GetVirtualShortString: TString50;
begin
  result := FVirtualShortString;
end;

procedure TSoapTestClass.SetStaticShortString(const Value: TString50);
begin
  FStaticShortString := Value;
end;

procedure TSoapTestClass.SetVirtualShortString(const Value: TString50);
begin
  FVirtualShortString := Value;
end;

function TSoapTestClass.GetStaticInt64: Int64;
begin
  result := FStaticInt64;
end;

function TSoapTestClass.GetVirtualInt64: Int64;
begin
  result := FVirtualInt64;
end;

procedure TSoapTestClass.SetStaticInt64(const Value: Int64);
begin
  FStaticInt64 := Value;
end;

procedure TSoapTestClass.SetVirtualInt64(const Value: Int64);
begin
  FVirtualInt64 := Value;
end;

function TSoapTestClass.GetStaticWideString: WideString;
begin
  result := FStaticWideString;
end;

function TSoapTestClass.GetVirtualWideString: WideString;
begin
  result := FVirtualWideString;
end;

procedure TSoapTestClass.SetStaticWideString(const Value: WideString);
begin
  FStaticWideString := Value;
end;

procedure TSoapTestClass.SetVirtualWideString(const Value: WideString);
begin
  FVirtualWideString := Value;
end;

function TSoapTestClass.GetStaticChar: Char;
begin
  Result := FStaticCHar;
end;

function TSoapTestClass.GetVirtualChar: Char;
begin
  result := FVirtualChar;
end;

procedure TSoapTestClass.SetStaticChar(const Value: Char);
begin
  FStaticChar := Value;
end;

procedure TSoapTestClass.SetVirtualChar(const Value: Char);
begin
  FVirtualChar := Value;
end;

function TSoapTestClass.GetStaticWideChar: WideChar;
begin
  result := FStaticWideChar;
end;

function TSoapTestClass.GetVirtualWideChar: WideChar;
begin
  result := FVirtualWideChar;
end;

procedure TSoapTestClass.SetStaticWideChar(const Value: WideChar);
begin
  FStaticWideChar := Value;
end;

procedure TSoapTestClass.SetVirtualWideChar(const Value: WideChar);
begin
  FVirtualWideChar := Value;
end;

function TSoapTestClass.GetStaticComp: Comp;
begin
  Result := FStaticComp;
end;

function TSoapTestClass.GetStaticCurrency: Currency;
begin
  Result := FStaticCurrency;
end;

function TSoapTestClass.GetStaticDouble: Double;
begin
  Result := FStaticDouble;
end;

function TSoapTestClass.GetStaticExtended: Extended;
begin
  Result := FStaticExtended;
end;

function TSoapTestClass.GetStaticSingle: Single;
begin
  Result := FStaticSingle;
end;

function TSoapTestClass.GetVirtualComp: Comp;
begin
  Result := FVirtualComp;
end;

function TSoapTestClass.GetVirtualCurrency: Currency;
begin
  result := FVirtualCurrency;
end;

function TSoapTestClass.GetVirtualDouble: Double;
begin
  Result := FVirtualDouble;
end;

function TSoapTestClass.GetVirtualExtended: Extended;
begin
  Result := FVirtualExtended;
end;

function TSoapTestClass.GetVirtualSingle: Single;
begin
  Result := FVirtualSingle;
end;

procedure TSoapTestClass.SetStaticComp(const Value: Comp);
begin
  FStaticComp := Value;
end;

procedure TSoapTestClass.SetStaticCurrency(const Value: Currency);
begin
  FStaticCurrency := Value;
end;

procedure TSoapTestClass.SetStaticDouble(const Value: Double);
begin
  FStaticDouble := Value;
end;

procedure TSoapTestClass.SetStaticExtended(const Value: Extended);
begin
  FStaticExtended := Value;
end;

procedure TSoapTestClass.SetStaticSingle(const Value: Single);
begin
  FStaticSingle := Value;
end;

procedure TSoapTestClass.SetVirtualComp(const Value: Comp);
begin
  FVirtualComp := Value;
end;

procedure TSoapTestClass.SetVirtualCurrency(const Value: Currency);
begin
  FVirtualCurrency := Value;
end;

procedure TSoapTestClass.SetVirtualDouble(const Value: Double);
begin
  FVirtualDouble := Value;
end;

procedure TSoapTestClass.SetVirtualExtended(const Value: Extended);
begin
  FVirtualExtended := Value;
end;

procedure TSoapTestClass.SetVirtualSingle(const Value: Single);
begin
  FVirtualSingle := Value;
end;

function TSoapTestClass.GetStaticClass: TSoapSimpleTestClass;
begin
  result := FStaticClass;
end;

function TSoapTestClass.GetVirtualClass: TSoapSimpleTestClass;
begin
  result := FVirtualClass;
end;

procedure TSoapTestClass.SetStaticClass(const Value: TSoapSimpleTestClass);
begin
  FStaticClass := Value;
end;

procedure TSoapTestClass.SetVirtualClass(const Value: TSoapSimpleTestClass);
begin
  FVirtualClass := Value;
end;

function TSoapTestClass.GetStaticArray: TTestDynCurrency1Arr;
begin
  Result := FStaticArray;
end;

function TSoapTestClass.GetVirtualArray: TTestDynCurrency1Arr;
begin
  Result := FVirtualArray;
end;

procedure TSoapTestClass.SetStaticArray(const Value: TTestDynCurrency1Arr);
begin
  FStaticArray := Value;
end;

procedure TSoapTestClass.SetVirtualArray(const Value: TTestDynCurrency1Arr);
begin
  FVirtualArray := Value;
end;

function TSoapTestClass.GetStaticEnum: TSmallEnum;
begin
  Result := FStaticEnum;
end;

function TSoapTestClass.GetVirtualEnum: TSmallEnum;
begin
  Result := FVirtualEnum;
end;

procedure TSoapTestClass.SetStaticEnum(const Value: TSmallEnum);
begin
  FStaticEnum := Value;
end;

procedure TSoapTestClass.SetVirtualEnum(const Value: TSmallEnum);
begin
  FVirtualEnum := Value;
end;

function TSoapTestClass.GetStaticSet: TSmallSet;
begin
  result := FStaticSet;
end;

function TSoapTestClass.GetVirtualSet: TSmallSet;
begin
  result := FVirtualSet;
end;

procedure TSoapTestClass.SetStaticSet(const Value: TSmallSet);
begin
  FStaticSet := Value;
end;

procedure TSoapTestClass.SetVirtualSet(const Value: TSmallSet);
begin
  FVirtualSet := Value;
end;

initialization
  IdSoapRegisterType(TypeInfo(TSoap3Enum));
  IdSoapRegisterType(TypeInfo(TSoap3Set));
  IdSoapRegisterType(TypeInfo(TSoap3DynArr), '', TypeInfo(String));
  IdSoapRegisterType(TypeInfo(TSoap3DynArrProperties));
{$IFDEF DELPHI4OR5}   // alternate D4/D5 method for dynamic array properties
  IdSoapRegisterProperty('TSoap3DynArrProperties', 'Field1',
                         IdSoapFieldProp(@TSoap3DynArrProperties(nil).FField1),
                         IdSoapFieldProp(@TSoap3DynArrProperties(nil).FField1),
                         TypeInfo(TSoap3DynArr));
  IdSoapRegisterProperty('TSoap3DynArrProperties', 'Field2',
                         IdSoapFieldProp(@TSoap3DynArrProperties(nil).FField2),
                         IdSoapFieldProp(@TSoap3DynArrProperties(nil).FField2),
                         TypeInfo(TSoap3DynArr));
  IdSoapRegisterProperty('TSoap3DynArrProperties', 'Field3',
                         IdSoapFieldProp(@TSoap3DynArrProperties(nil).FField3),
                         IdSoapFieldProp(@TSoap3DynArrProperties(nil).FField3),
                         TypeInfo(TSoap3DynArr));
{$ENDIF}

  IdSoapRegisterType(TypeInfo(TSoap3StringProperties));
  IdSoapRegisterType(TypeInfo(TSoap3ShortStringProperties));
  IdSoapRegisterType(TypeInfo(TSoap3ByteProperties));
  IdSoapRegisterType(TypeInfo(TSoap3ShortIntProperties));
  IdSoapRegisterType(TypeInfo(TSoap3SmallIntProperties));
  IdSoapRegisterType(TypeInfo(TSoap3WordProperties));
  IdSoapRegisterType(TypeInfo(TSoap3IntegerProperties));
{$IFNDEF DELPHI4}
  IdSoapRegisterType(TypeInfo(TSoap3CardinalProperties));
{$ENDIF}
  IdSoapRegisterType(TypeInfo(TSoap3Int64Properties));
  IdSoapRegisterType(TypeInfo(TSoap3SingleProperties));
  IdSoapRegisterType(TypeInfo(TSoap3DoubleProperties));
  IdSoapRegisterType(TypeInfo(TSoap3ExtendedProperties));
  IdSoapRegisterType(TypeInfo(TSoap3CompProperties));
  IdSoapRegisterType(TypeInfo(TSoap3CurrProperties));
  IdSoapRegisterType(TypeInfo(TSoap3WideStringProperties));
  IdSoapRegisterType(TypeInfo(TSoap3CharProperties));
  IdSoapRegisterType(TypeInfo(TSoap3WideCharProperties));
  IdSoapRegisterType(TypeInfo(TSoap3EnumProperties));
  IdSoapRegisterType(TypeInfo(TSoap3SetProperties));
  IdSoapRegisterType(TypeInfo(TSoap3ClassProperties));

  IdSoapRegisterType(TypeInfo(TBinaryTestClass));
  IdSoapRegisterType(TypeInfo(THexBinaryTestClass));
  IdSoapRegisterType(TypeInfo(TReferenceTestingObject));
  IdSoapRegisterType(TypeInfo(TSoapNilPropClass));

  IdSoapRegisterType(TypeInfo(TSoapSimpleTestClass));
  IdSoapRegisterClass(TypeInfo(TSoapVirtualClassTestBase), [TypeInfo(TSoapVirtualClassTestChild)], true);
  IdSoapRegisterType(TypeInfo(TSoapTestClass));
  IdSoapRegisterType(TypeInfo(TSoapFieldArrClass));

  IdSoapRegisterType(TypeInfo(TLargeEnum));
  IdSoapRegisterType(TypeInfo(TSmallEnum));
  IdSoapRegisterType(TypeInfo(TSmallSet));
  IdSoapRegisterType(TypeInfo(TString50));

  IdSoapRegisterType(TypeInfo(TTestDynObj1Arr), '', TypeInfo(TSoapSimpleTestClass));
  IdSoapRegisterType(TypeInfo(TTestDynObj2Arr), '', TypeInfo(TSoapSimpleTestClass));
  IdSoapRegisterType(TypeInfo(TTestDynObj3Arr), '', TypeInfo(TSoapSimpleTestClass));
  IdSoapRegisterType(TypeInfo(TTestDynCurrency1Arr), '', TypeInfo(Currency));
  IdSoapRegisterType(TypeInfo(TTestDynIntegerArr), '', TypeInfo(Integer));
  IdSoapRegisterType(TypeInfo(TTestDynInteger2Arr), '', TypeInfo(Integer));
  IdSoapRegisterType(TypeInfo(TTestDynString3Arr), '', TypeInfo(String));
  IdSoapRegisterType(TypeInfo(TTestDynByte4Arr), '', TypeInfo(Byte));
  IdSoapRegisterType(TypeInfo(TTestDynByteArr), '', TypeInfo(Byte));
  IdSoapRegisterType(TypeInfo(TTestDynStreamArray), '', TypeInfo(TStream));
  IdSoapRegisterType(TypeInfo(TTestDynHexStreamArray), '', TypeInfo(THexStream));

  IdSoapRegisterType(TypeInfo(TTypeKind));
  IdSoapRegisterType(TypeInfo(TOrdType));
  IdSoapRegisterType(TypeInfo(TFloatType));

{$IFDEF DELPHI4OR5}   // alternate D4/D5 method for dynamic array properties
  IdSoapRegisterProperty('TSoapTestClass', 'VirtualArray',
                         IdSoapVirtualProp(TSoapTestClass,@TSoapTestClass.GetVirtualArray),
                         IdSoapVirtualProp(TSoapTestClass,@TSoapTestClass.SetVirtualArray),
                         TypeInfo(TTestDynCurrency1Arr));
  IdSoapRegisterProperty('TSoapTestClass', 'StaticArray',
                         IdSoapStaticProp(@TSoapTestClass.GetStaticArray),
                         IdSoapStaticProp(@TSoapTestClass.SetStaticArray),
                         TypeInfo(TTestDynCurrency1Arr));

  IdSoapRegisterProperty('TSoapTestClass', 'FieldArray',
                         IdSoapFieldProp(@TSoapTestClass(nil).FFieldArray),
                         IdSoapFieldProp(@TSoapTestClass(nil).FFieldArray),
                         TypeInfo(TTestDynCurrency1Arr));

  IdSoapRegisterProperty('TSoapFieldArrClass', 'FieldArray',
                         IdSoapFieldProp(@TSoapFieldArrClass(nil).FFieldArray),
                         IdSoapFieldProp(@TSoapFieldArrClass(nil).FFieldArray),
                         TypeInfo(TTestDynCurrency1Arr));
{$ENDIF}
end.
