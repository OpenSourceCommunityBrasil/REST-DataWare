{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16437: IdSoapRpcXmlTests.pas 
{
{   Rev 1.4    23/6/2003 15:15:36  GGrieve
{ fix for V#1
}
{
{   Rev 1.3    20/6/2003 00:01:34  GGrieve
{ compile fixes
}
{
{   Rev 1.2    19/6/2003 21:36:30  GGrieve
{ Version #1
}
{
{   Rev 1.1    18/3/2003 11:16:12  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:29:22  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  23-Jun 2003   Grahame Grieve                  Fix for various charset issues
  19 Jun 2003   Grahame Grieve                  Custom XML testing, no MsXML testing when not used, Linux testing fixes, header changes
  18-Mar 2003   Grahame Grieve                  QName, RawXML, Schema extensibility
  04-Oct 2002   Grahame Grieve                  MimeType changes, Attachment tests
  17-Sep 2002   Grahame Grieve                  HexBinary, Soapbuilders2 tests
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit testing
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Add Tests for renaming names and types, fix consequent changes to Array handling
  16-Aug 2002   Grahame Grieve                  Add mixed namespace test
  13 Aug 2002   Grahame Grieve                  Add SoapBuilders tests
  06-Aug 2002   Grahame Grieve                  Add tests for manual msg interface
  24-Jul 2002   Grahame Grieve                  Test new namespace policy, Google Tests
  22-Jul 2002   Grahame Grieve                  Soap V1.1 conformance testing
  11-Apr 2002   Grahame Grieve                  Update tests for changes to assertion policy
  08-Apr 2002   Grahame Grieve                  Objects by reference testing
  08-Apr 2002   Andrew Cumming                  Fixed date compare rouding error and added new test to check for this
  06-Apr 2002   Andrew Cumming                  Name change for NanoSeconds
  05-Apr 2002   Grahame Grieve                  Date Time Tests fixed to check the right thing
  03-Apr 2002   Grahame Grieve                  Date Time Tests changed to class based TIdSoapDateTime
  03-Apr 2002   Grahame Grieve                  update for changes to packet interface relating to request/response
  02-Apr 2002   Grahame Grieve                  Date Time Tests added
  27-Mar 2002   Grahame Grieve                  remove ViewStream
  26-Mar 2002   Grahame Grieve                  Standard array handling, changes to packet layer
  22-Mar 2002   Grahame Grieve                  Test pretty XML
  22-Mar 2002   Grahame Grieve                  Fix for changes to Node handling
  15-Mar 2002   Grahame Grieve                  Fix issues with namespaces in tests
  14-Mar 2002   Grahame Grieve                  Added tests relating to Encoding Option seoCheckStrings
  14-Mar 2002   Andrew Cumming                  Added code for Application.ProcessMessages equiv to TearDown
  14-Mar 2002   Grahame Grieve                  Whitespace tests
  12-Mar 2002   Grahame Grieve                  Added Binary Tests
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
   3-Mar 2002   Grahame Grieve                  Updates for Namespace support
   7-Feb 2002   Andrew Cumming                  D4 compatibility
   7-Feb 2002   Grahame Grieve                  Testing for XML and Bin Variants, stub for standards compliance
   First Written by Grahame Grieve, Jan 2002
}

unit IdSoapRpcXmlTests;

{$I IdSoapDefines.inc}
interface

uses
  Classes,
  IdSoapUtilities,
  TestExtensions,
  TestFramework,
  IdSoapRpcPacket,
  IdSoapXML;

type
  TIdSoapXMLTests = class(TTestCase)
  private
    FDom : TIdSoapXmlDom;
    procedure LoadFile(AFile : String);
  protected
    procedure TearDown; override;
    procedure CreateDOM; virtual; abstract;
  published
    procedure TestEuroISO8859;
    procedure TestEuroUTF8;
  end;

  TIdSoapXMLOpenXMLTests = class(TIdSoapXMLTests)
  protected
    procedure CreateDOM; override;
  end;

{$IFDEF USE_MSXML}
  TIdSoapXMLMsXMLTests = class(TIdSoapXMLTests)
  protected
    procedure CreateDOM; override;
  end;
{$ENDIF}

  TIdSoapXMLCustomTests = class(TIdSoapXMLTests)
  protected
    procedure CreateDOM; override;
  end;

  TIdSoapPacketBaseTests = class(TTestCase)
  Private
    FStream: TStringStream;
    FFault: TIdSoapFaultWriter;
    FWriter: TIdSoapWriter;
    FReader: TIdSoapReader;
  Protected
    procedure Setup; Override;
    procedure TearDown; Override;
    function CreateReader : TIdSoapReader; Virtual; abstract;
    function CreateWriter : TIdSoapWriter; Virtual; abstract;
    function CreateFault : TIdSoapFaultWriter; Virtual; abstract;
  Published
    // point tests that ensure that single classes are working as expected
    procedure Test_Writer_NoName;

    // test that check that end to end behaviour is ok
    procedure Test_IdSoap_Message;
    procedure Test_IdSoap_Param;
    procedure Test_IdSoap_EncOpt_TypesIn1;
    procedure Test_IdSoap_EncOpt_TypesIn2;
    procedure Test_IdSoap_EncOpt_TypesOut1;
    procedure Test_IdSoap_Param_Case_Name;
    procedure Test_IdSoap_Param_AllTypes;
    procedure Test_IdSoap_Param_AllTypes_ByNode;
    procedure Test_IdSoap_Param_DateTimeTypes;
    procedure Test_IdSoap_Param_Binary;
    procedure Test_IdSoap_Param_Binary_Empty;
    procedure Test_IdSoap_Param_Binary_Hex;
    procedure Test_IdSoap_Param_Binary_Hex_Empty;
    procedure Test_IdSoap_Attachment;
    procedure Test_IdSoap_AttachmentEmpty;
    procedure Test_IdSoap_2Attachments;
    procedure Test_IdSoap_Param_Read_NonExist;
    procedure Test_IdSoap_Param_Unicode;
    procedure Test_IdSoap_Param_Char1;
    procedure Test_IdSoap_Param_Char2;
    procedure Test_IdSoap_Param_Char3;
    procedure Test_IdSoap_Param_Char4;
    procedure Test_IdSoap_Param_Char5;
    procedure Test_IdSoap_Param_Char6;
    procedure Test_IdSoap_Param_Str1;
    procedure Test_IdSoap_Param_Str2;
    procedure Test_IdSoap_Param_Str3;
    procedure Test_IdSoap_Param_Str4;
    procedure Test_IdSoap_Param_Str5;
    procedure Test_IdSoap_Param_Str6;
    procedure Test_IdSoap_Param_Str7;
    procedure Test_IdSoap_Param_Str8;
    procedure Test_IdSoap_Param_StrBad1;
    procedure Test_IdSoap_Param_StrBad2;
    procedure Test_IdSoap_Param_StrBad3;
    procedure Test_IdSoap_Param_StrBad4;
    procedure Test_IdSoap_Param_StrBad5;
    procedure Test_IdSoap_Param_StrBad6;
    procedure Test_IdSoap_Node_Struct;
    procedure Test_IdSoap_Node_Struct_ByRef;
    procedure Test_IdSoap_Node_Struct_NoType;
    procedure Test_IdSoap_Node_Array;
    procedure Test_IdSoap_Node_Element_Simple;
    procedure Test_IdSoap_Node_Element_Complex;
    procedure Test_IdSoap_Node_Element_Complex_Sparse;
    procedure Test_IdSoap_Node_Element_Complex_2Dim;
    procedure Test_IdSoap_Node_No_Exist;
    procedure Test_IdSoap_Node_Case_Name;
    procedure Test_IdSoap_Node_No_Class;
    procedure Test_IdSoap_Node_Wrong_Class;
    procedure Test_IdSoap_Node_Level2;
    procedure Test_IdSoap_Exception1;
    procedure Test_IdSoap_Exception1_Message_Check;
    procedure Test_IdSoap_Exception2;
    procedure Test_IdSoap_Exception3;
    procedure Test_IdSoap_Exception4;
    procedure Test_IdSoap_Exception5;
    procedure RepeatTests;
  end;

  TIdSoapPacketXMLTests = class(TIdSoapPacketBaseTests)
  published
    procedure Test_IdSoap_Param_DefaultsOn;
    procedure Test_IdSoap_Param_DefaultsOff;
  end;

  TIdSoapPacketXML8Tests = class(TIdSoapPacketXMLTests)
  protected
    function CreateReader : TIdSoapReader; override;
    function CreateWriter : TIdSoapWriter; override;
    function CreateFault : TIdSoapFaultWriter; Override;
    procedure SetReaderOptions(AReader : TIdSoapReader); virtual; abstract;
    procedure SetWriterOptions(AWriter : TIdSoapWriter); virtual; abstract;
  end;

  TIdSoapPacketXML8DefaultTests = class(TIdSoapPacketXML8Tests)
  protected
    procedure SetReaderOptions(AReader : TIdSoapReader); override;
    procedure SetWriterOptions(AWriter : TIdSoapWriter); override;
  end;

  TIdSoapPacketXML8DocumentTests = class(TIdSoapPacketXML8Tests)
  protected
    procedure SetReaderOptions(AReader : TIdSoapReader); override;
    procedure SetWriterOptions(AWriter : TIdSoapWriter); override;
  end;

  TIdSoapPacketXML16Tests = class(TIdSoapPacketXMLTests)
  protected
    function CreateReader : TIdSoapReader; override;
    function CreateWriter : TIdSoapWriter; override;
    function CreateFault : TIdSoapFaultWriter; Override;
  end;

  TIdSoapPacketBinTests = class(TIdSoapPacketBaseTests)
  protected
    function CreateReader : TIdSoapReader; override;
    function CreateWriter : TIdSoapWriter; override;
    function CreateFault : TIdSoapFaultWriter; Override;
  end;

{$IFDEF USE_MSXML}
  TIdSoapPacketMsXml8Tests = class(TIdSoapPacketBaseTests)
  protected
    function CreateReader : TIdSoapReader; override;
    function CreateWriter : TIdSoapWriter; override;
    function CreateFault : TIdSoapFaultWriter; Override;
  end;

  TIdSoapPacketMsXml16Tests = class(TIdSoapPacketBaseTests)
  protected
    function CreateReader : TIdSoapReader; override;
    function CreateWriter : TIdSoapWriter; override;
    function CreateFault : TIdSoapFaultWriter; Override;
  end;
{$ENDIF}

  TIdSoapPacketCustom8Tests = class(TIdSoapPacketBaseTests)
  protected
    function CreateReader : TIdSoapReader; override;
    function CreateWriter : TIdSoapWriter; override;
    function CreateFault : TIdSoapFaultWriter; Override;
  end;

  TReaderTestCase = class (TTestCase)
  private
    FReader: TIdSoapReader;
    Procedure ReadFile(AFileName: string);
  protected
    procedure Setup; Override;
    procedure TearDown; Override;
  end;

  TIdSoapCompatibilityGeneral = class(TReaderTestCase)
  Published
    procedure Test_Soap_Fault;
    procedure Test_Soap_Fault1;
    procedure Test_Soap_Fault2;
  end;

  TIdSoapCompatibilityStandard = class(TReaderTestCase)
  Published
    // Each of these tests checks that the samples in the soap standard itself
    // can be understood appropriately. some typos have been corrected
    procedure Test_Standard_Example_1;
    Procedure Test_Standard_Example_2;

    procedure Test_Standard_Packet_Array;
  end;

  TIdSoapCompatibilityBorland = class(TReaderTestCase)
  Private
    procedure CheckBorlandPacket(AUseRefs : boolean);
  Published
    // tests that check that the SOAP reading is compliant with Borland
    procedure Test_Standard_Packet_Borland1;
    procedure Test_Standard_Packet_BorlandPretty;
    procedure Test_Standard_Packet_Borland_Exception;
    procedure Test_Standard_Packet_Borland_Exception_Class;
    procedure Test_Borland_Std;
    procedure Test_Borland_Pretty;
    procedure Test_Borland_Pretty_NoNull;
    procedure Test_Borland_Pretty_InLine;
    procedure Test_Borland_Pretty_InLine_NoNull;
    procedure Test_Soap_Headers;
    procedure Test_Soap_Headers_MustUnderstand1;
    procedure Test_Soap_Headers_MustUnderstand2;
  end;

  TIdSoapCompatibilityGoogle = class(TReaderTestCase)
  Published
    procedure Test_Read_GoogleGetCachedPage;
    procedure Test_Read_GoogleGetCachedPageResponse;
    procedure Test_Read_GoogleSearch;
    procedure Test_Read_GoogleSearchResponse;
    procedure Test_Read_GoogleSpellingSuggestion;
    procedure Test_Read_GoogleSpellingSuggestionResponse;
  end;

  TIdSoapCompatibilitySoapBuilders = class(TReaderTestCase)
  Published
    procedure Test_SoapBuilder_echoVoid;
    procedure Test_SoapBuilder_echoVoidResponse;

    procedure Test_SoapBuilder_echostring;
    procedure Test_SoapBuilder_echostringResponse;
    procedure Test_SoapBuilder_echostringArray;
    procedure Test_SoapBuilder_echostringArrayResponse;

    procedure Test_SoapBuilder_echoInteger;
    procedure Test_SoapBuilder_echoIntegerResponse;
    procedure Test_SoapBuilder_echoIntegerArray;
    procedure Test_SoapBuilder_echoIntegerArrayResponse;

    procedure Test_SoapBuilder_echoFloat;
    procedure Test_SoapBuilder_echoFloatResponse;
    procedure Test_SoapBuilder_echoFloatArray;
    procedure Test_SoapBuilder_echoFloatArrayResponse;

    procedure Test_SoapBuilder_echoStruct;
    procedure Test_SoapBuilder_echoStructResponse;
    procedure Test_SoapBuilder_echoStructResponseKafka;
    procedure Test_SoapBuilder_echoStructArray;
    procedure Test_SoapBuilder_echoStructArrayResponse;

    procedure Test_SB2_Glue_Struct;
    procedure Test_SB2_EasySoap_2DArray;
    procedure Test_SB2_Glue_2DArray;
  end;

  TIdSoapCompatibilityDocLit = class(TReaderTestCase)
  Published
    procedure Test_Read_LookyBookResponse;
  end;

  TIdSoapCompatibilityMisc = class(TReaderTestCase)
  Published
    procedure Test_Read_MapPointBase64;
  end;


type
{$IFDEF USE_MSXML}
  TIdSoapDecoderSetupMSXML = class (TTestSetup)
  protected
    procedure Setup; override;
  end;
{$ENDIF}

  TIdSoapDecoderSetupOpenXML = class (TTestSetup)
  protected
    procedure Setup; override;
  end;

  TIdSoapDecoderSetupCustom = class (TTestSetup)
  protected
    procedure Setup; override;
  end;


  TIdSoapDIMETests = class (TTestCase)
  Published
    procedure TestDime;
    procedure TestEmptyDime1;
    procedure TestEmptyDime2;
    procedure TestChunkedDime;
    procedure TestDIMEExample;
  end;

implementation

uses
  IdException,
  IdGlobal,
  IdSoapComponent,
  IdSoapConsts,
  IdSoapDateTime,
  IdSoapDime,
  IdSoapExceptions,
  IdSoapITI,
  IdSoapRpcXml,
  IdSoapRpcBin,
  IdSoapTestingUtils,
  IdSoapTypeRegistry,
  SysUtils,
  TypInfo;

var
  GXmlProvider : TIdSoapXmlProvider;

// linux and windows handle chars with value 128 - 255
// quite differently. Rather than trying to make IndySoap
// behave identically on different platforms, we say that
// the tests expect different outcomes

function GetTargetStr(AStr : String):String;
begin
  {$IFDEF MSWINDOWS}
  result := AStr;
  {$ELSE}
  result := IdSoapAnsiToUTF8(AStr); 
  {$ENDIF}
end;

type
  TEncodingTestClass = class (TIdBaseSoapableClass)
  private
    FNum : integer;
  published
    property Num : integer read FNum write FNum;
  end;

{ TITIParserTestCases }

procedure TIdSoapPacketBaseTests.Setup;
begin
  FStream := TStringStream.Create('');
  FWriter := CreateWriter;
  FWriter.EncodingOptions := [seoUseCrLf, seoRequireTypes, seoCheckStrings];
  FReader := CreateReader;
  FReader.EncodingOptions := [seoUseCrLf, seoRequireTypes, seoCheckStrings];
  FFault := CreateFault;
end;

procedure TIdSoapPacketBaseTests.TearDown;
begin
  FreeAndNil(FStream);
  FreeAndNil(FWriter);
  FreeAndNil(FReader);
  FreeAndNil(FFault);
  IdSoapProcessMessages;
end;

procedure TIdSoapPacketBaseTests.Test_Writer_NoName;
var
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  FWriter.Encode(FStream, LMimeType, nil, nil);
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Message;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.CheckPacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.MessageNameSpace = 'urn:test');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Case_Name;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'testparam'] = 'Value', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Read_NonExist;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  FReader.EncodingOptions := FReader.EncodingOptions + [seoUseDefaults];
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'testparam1'] = '', 'Reading Parameter Failed');
  FReader.EncodingOptions := FReader.EncodingOptions - [seoUseDefaults];
  ExpectedException := EIdSoapRequirementFail;
  Check(FReader.ParamDouble[NIL, 'testparam1'] = 0, 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Binary;
var
  LStream : TMemoryStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LStream := TIdMemoryStream.create;
  try
    FillTestingStream(LStream, 2000);
    FWriter.SetMessageName('TestProc', 'urn:test');
    FWriter.DefineParamBinaryBase64(nil, 'ABinary', LStream);
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    LStream.Position := 0;
    LStream2 := FReader.ParamBinaryBase64[nil, 'ABinary'];
    try
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Binary_Empty;
var
  LStream : TMemoryStream;
  LStream2 : TStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LStream := TIdMemoryStream.create;
  try
    FillTestingStream(LStream, 0);
    FWriter.SetMessageName('TestProc', 'urn:test');
    FWriter.DefineParamBinaryBase64(nil, 'ABinary', LStream);
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    LStream.Position := 0;
    LStream2 := FReader.ParamBinaryBase64[nil, 'ABinary'];
    try
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Binary_Hex;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LStream := THexStream.create;
  try
    FillTestingStream(LStream, 2000);
    FWriter.SetMessageName('TestProc', 'urn:test');
    FWriter.DefineParamBinaryHex(nil, 'ABinary', LStream);
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    LStream.Position := 0;
    LStream2 := FReader.ParamBinaryHex[nil, 'ABinary'];
    try
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Binary_Hex_Empty;
var
  LStream : THexStream;
  LStream2 : THexStream;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LStream := THexStream.create;
  try
    FillTestingStream(LStream, 0);
    FWriter.SetMessageName('TestProc', 'urn:test');
    FWriter.DefineParamBinaryHex(nil, 'ABinary', LStream);
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    LStream.Position := 0;
    LStream2 := FReader.ParamBinaryHex[nil, 'ABinary'];
    try
      LOK := TestStreamsIdentical(LStream, LStream2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStream2);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_AllTypes;
var
  LSingle: Single;
  LDouble: Double;
  LComp: Comp;
  LExtended: Extended;
  LCurr: Currency;
  LMimeType : string;
begin
  LSingle := 1.223;
  LDouble := 1000.223423423;
  LComp := 23443423434234;
  LExtended := 100042356.22;
  LCurr := 234252323445.2342;
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AString', 'xx');
  FWriter.DefineParamShortString(NIL, 'AShortString', 'xy');
  FWriter.DefineParamByte(NIL, 'AByte', 45);
  FWriter.DefineParamShortInt(NIL, 'AShortInt', - 35);
  FWriter.DefineParamChar(NIL, 'AChar', 'C');
  FWriter.DefineParamBoolean(NIL, 'ABoolean', False);
  FWriter.DefineParamWord(NIL, 'AWord', 23423);
  FWriter.DefineParamSmallInt(NIL, 'ASmallInt', - 23423);
  FWriter.DefineParamCardinal(NIL, 'ACardinal', 4294967292);
  FWriter.DefineParamInteger(NIL, 'AInteger', 123123);
  FWriter.DefineParamInt64(NIL, 'AInt64', 23443423434234);
  FWriter.DefineParamSingle(NIL, 'ASingle', LSingle);
  FWriter.DefineParamDouble(NIL, 'ADouble', LDouble);
  FWriter.DefineParamComp(NIL, 'AComp', LComp);
  FWriter.DefineParamExtended(NIL, 'AExtended', LExtended);
  FWriter.DefineParamCurrency(NIL, 'ACurrency', LCurr);
  FWriter.DefineParamEnumeration(NIL, 'AEnumeration', Typeinfo(TTypeKind), 'test', 'testns', nil, Ord(tkClass));
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'AString'] = 'xx', 'String Parameter Failed Checking');
  Check(FReader.ParamShortString[NIL, 'AShortString'] = 'xy', 'ShortString Parameter Failed Checking');
  Check(FReader.ParamByte[NIL, 'AByte'] = 45, 'Byte Parameter Failed Checking');
  Check(FReader.ParamShortInt[NIL, 'AShortInt'] = -35, 'Int Parameter Failed Checking');
  Check(FReader.ParamChar[NIL, 'AChar'] = 'C', 'Char Parameter Failed Checking');
  Check(FReader.ParamBoolean[NIL, 'ABoolean'] = False, 'Boolean Parameter Failed Checking');
  Check(FReader.ParamWord[NIL, 'AWord'] = 23423, 'Word Parameter Failed Checking');
  Check(FReader.ParamSmallInt[NIL, 'ASmallInt'] = -23423, 'SmallInt Parameter Failed Checking');
  Check(FReader.ParamCardinal[NIL, 'ACardinal'] = 4294967292, 'Cardinal Parameter Failed Checking');
  Check(FReader.ParamInteger[NIL, 'AInteger'] = 123123, 'Integer Parameter Failed Checking');
  Check(FReader.ParamInt64[NIL, 'AInt64'] = 23443423434234, 'Int64 Parameter Failed Checking');
  Check(FloatEquals(FReader.ParamSingle[NIL, 'ASingle'], LSingle), 'Single Parameter Failed Checking');
  Check(FloatEquals(FReader.ParamDouble[NIL, 'ADouble'], LDouble), 'Double Parameter Failed Checking');
  Check(FReader.ParamComp[NIL, 'AComp'] = LComp, 'Comp Parameter Failed Checking');
  // There's a little uncertainty in the last few decimal places
  Check(FloatEquals(FReader.ParamExtended[NIL, 'AExtended'], LExtended), 'Extended Parameter Failed Checking');
  Check(FReader.ParamCurrency[NIL, 'ACurrency'] = LCurr, 'Currency Parameter Failed Checking');
  Check(FReader.ParamEnumeration[NIL, 'AEnumeration', Typeinfo(TTypeKind), 'test', 'testns', nil] = Ord(tkClass), 'Enumerated Parameter Failed Checking');
  if FReader.EncodingMode = semRPC then
    begin
    ExpectedException := EIdSoapRequirementFail;
    Check(FReader.ParamEnumeration[NIL, 'AEnumeration', Typeinfo(TTypeKind), 'Test', 'testNS', nil] = Ord(tkClass), 'Enumerated Parameter Failed Checking');
    end;
end;

procedure TIdSoapPacketXMLTests.Test_IdSoap_Param_DefaultsOff;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;

  try
    Check(FReader.ParamString[NIL, 'AString'] = '');
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamShortString[NIL, 'AShortString'] = '');
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamByte[NIL, 'AByte'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamShortInt[NIL, 'AShortInt'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamBoolean[NIL, 'ABoolean'] = false);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamWord[NIL, 'AWord'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamSmallInt[NIL, 'ASmallInt'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamCardinal[NIL, 'ACardinal'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamInteger[NIL, 'AInteger'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamInt64[NIL, 'AInt64'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamSingle[NIL, 'ASingle'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamDouble[NIL, 'ADouble'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamComp[NIL, 'AComp'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamExtended[NIL, 'AExtended'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamCurrency[NIL, 'ACurrency'] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamEnumeration[NIL, 'AEnumeration', Typeinfo(TTypeKind), 'test', 'testns', nil] = 0);
    check(false);
  except
    check(true);
  end;
  try
    Check(FReader.ParamChar[NIL, 'AChar'] = ' ');
    check(false);
  except
    check(true);
  end;
end;

procedure TIdSoapPacketXMLTests.Test_IdSoap_Param_DefaultsOn;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  FReader.EncodingOptions := FReader.EncodingOptions + [seoUseDefaults];
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'AString'] = '', 'String Parameter Failed Checking');
  Check(FReader.ParamShortString[NIL, 'AShortString'] = '', 'ShortString Parameter Failed Checking');
  Check(FReader.ParamByte[NIL, 'AByte'] = 0, 'Byte Parameter Failed Checking');
  Check(FReader.ParamShortInt[NIL, 'AShortInt'] = 0, 'Int Parameter Failed Checking');
  Check(FReader.ParamBoolean[NIL, 'ABoolean'] = False, 'Boolean Parameter Failed Checking');
  Check(FReader.ParamWord[NIL, 'AWord'] = 0, 'Word Parameter Failed Checking');
  Check(FReader.ParamSmallInt[NIL, 'ASmallInt'] = 0, 'SmallInt Parameter Failed Checking');
  Check(FReader.ParamCardinal[NIL, 'ACardinal'] = 0, 'Cardinal Parameter Failed Checking');
  Check(FReader.ParamInteger[NIL, 'AInteger'] = 0, 'Integer Parameter Failed Checking');
  Check(FReader.ParamInt64[NIL, 'AInt64'] = 0, 'Int64 Parameter Failed Checking');
  Check(FReader.ParamSingle[NIL, 'ASingle'] = 0, 'Single Parameter Failed Checking');
  Check(FReader.ParamDouble[NIL, 'ADouble'] = 0, 'Double Parameter Failed Checking');
  Check(FReader.ParamComp[NIL, 'AComp'] = 0, 'Comp Parameter Failed Checking');
  Check(FReader.ParamExtended[NIL, 'AExtended'] = 0, 'Extended Parameter Failed Checking');
  Check(FReader.ParamCurrency[NIL, 'ACurrency'] = 0, 'Currency Parameter Failed Checking');
  Check(FReader.ParamEnumeration[NIL, 'AEnumeration', Typeinfo(TTypeKind), 'test', 'testns', nil] = Ord(tkUnknown), 'Enumerated Parameter Failed Checking');
  // can't have a default value for char
  ExpectedException := EIdSoapRequirementFail;
  Check(FReader.ParamChar[NIL, 'AChar'] = 'C', 'Char Parameter Failed Checking');
end;


procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_AllTypes_ByNode;
var
  LSingle: Single;
  LDouble: Double;
  LComp: Comp;
  LExtended: Extended;
  LCurr: Currency;
  LMimeType : string;
begin
  LSingle := 1.223;
  LDouble := 1000.223423423;
  LComp := 23443423434234;
  LExtended := 100042356.22;
  LCurr := 234252323445.2342;
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.BaseNode.ParamString['AString'] := 'xx';
  FWriter.BaseNode.ParamShortString['AShortString'] := 'xy';
  FWriter.BaseNode.ParamByte['AByte'] :=  45;
  FWriter.BaseNode.ParamShortInt['AShortInt'] := -35;
  FWriter.BaseNode.ParamChar['AChar'] := 'C';
  FWriter.BaseNode.ParamBoolean['ABoolean'] :=  False;
  FWriter.BaseNode.ParamWord['AWord'] :=  23423;
  FWriter.BaseNode.ParamSmallInt['ASmallInt'] := -23423;
  FWriter.BaseNode.ParamCardinal['ACardinal'] :=  4294967292;
  FWriter.BaseNode.ParamInteger['AInteger'] :=  123123;
  FWriter.BaseNode.ParamInt64['AInt64'] :=  23443423434234;
  FWriter.BaseNode.ParamSingle['ASingle'] :=  LSingle;
  FWriter.BaseNode.ParamDouble['ADouble'] :=  LDouble;
  FWriter.BaseNode.ParamComp['AComp'] :=  LComp;
  FWriter.BaseNode.ParamExtended['AExtended'] :=  LExtended;
  FWriter.BaseNode.ParamCurrency['ACurrency'] :=  LCurr;
  FWriter.BaseNode.ParamEnumeration['AEnumeration', Typeinfo(TTypeKind), 't', 't', nil] := Ord(tkClass);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.BaseNode.ParamString['AString'] = 'xx', 'String Parameter Failed Checking');
  Check(FReader.BaseNode.ParamShortString['AShortString'] = 'xy', 'ShortString Parameter Failed Checking');
  Check(FReader.BaseNode.ParamByte['AByte'] = 45, 'Byte Parameter Failed Checking');
  Check(FReader.BaseNode.ParamShortInt['AShortInt'] = -35, 'Int Parameter Failed Checking');
  Check(FReader.BaseNode.ParamChar['AChar'] = 'C', 'Char Parameter Failed Checking');
  Check(FReader.BaseNode.ParamBoolean['ABoolean'] = False, 'Boolean Parameter Failed Checking');
  Check(FReader.BaseNode.ParamWord['AWord'] = 23423, 'Word Parameter Failed Checking');
  Check(FReader.BaseNode.ParamSmallInt['ASmallInt'] = -23423, 'SmallInt Parameter Failed Checking');
  Check(FReader.BaseNode.ParamCardinal['ACardinal'] = 4294967292, 'Cardinal Parameter Failed Checking');
  Check(FReader.BaseNode.ParamInteger['AInteger'] = 123123, 'Integer Parameter Failed Checking');
  Check(FReader.BaseNode.ParamInt64['AInt64'] = 23443423434234, 'Int64 Parameter Failed Checking');
  Check(FloatEquals(FReader.BaseNode.ParamSingle['ASingle'], LSingle), 'Single Parameter Failed Checking');
  Check(FloatEquals(FReader.BaseNode.ParamDouble['ADouble'], LDouble), 'Double Parameter Failed Checking');
  Check(FReader.BaseNode.ParamComp['AComp'] = LComp, 'Comp Parameter Failed Checking');
  // There's a little uncertainty in the last few decimal places
  Check(FloatEquals(FReader.BaseNode.ParamExtended['AExtended'], LExtended), 'Extended Parameter Failed Checking');
  Check(FReader.BaseNode.ParamCurrency['ACurrency'] = LCurr, 'Currency Parameter Failed Checking');
  Check(FReader.BaseNode.ParamEnumeration['AEnumeration', Typeinfo(TTypeKind), 't', 't', nil] = Ord(tkClass), 'Enumerated Parameter Failed Checking');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_DateTimeTypes;
var
  LDate1 : TDateTime;
  LDate2 : TDateTime;
  LDate3 : TDateTime;
  LDate4 : TDateTime;
  LDate5 : TDateTime;
  LIdDate : TIdSoapDateTime;
  LIdDate1 : TIdSoapDateTime;
  LIdDate2 : TIdSoapTime;
  LIdDate3 : TIdSoapDate;
  LIdDate5:  TIdSoapDateTime;
  LMimeType : string;
  LNil : boolean;
  LVal : string;
  LTypeNS : string;
  LType : string;
begin
  LDate1 := now;
  LDate2 := EncodeTime(12, 53, 44, 0);
  LDate3 := EncodeDate(1999, 06, 04);
  LDate4 := 0;
  LDate5 := 37354.476797;  // checks for a rounding error in floating point for millisecs
  LIdDate1 := DateTimeToIdSoapDateTime(LDate1);
  LIdDate2 := DateTimeToIdSoapTime(LDate2);
  LIdDate3 := DateTimeToIdSoapDate(LDate3);
  LIdDate5 := DateTimeToIdSoapDate(LDate5);
  try
    FWriter.SetMessageName('TestProc', 'urn:test');
    FWriter.DefineParamString(NIL, 'AString', 'xx');
    FWriter.DefineParamDateTime(NIL, 'ADate1', LDate1);
    FWriter.DefineParamDateTime(NIL, 'ADate2', LDate2);
    FWriter.DefineParamDateTime(NIL, 'ADate3', LDate3);
    FWriter.DefineParamDateTime(NIL, 'ADate4', LDate4);
    FWriter.DefineParamDateTime(NIL, 'ADate5', LDate5);
    FWriter.DefineGeneralParam(nil, false, 'AIdDate1', LIdDate1.WriteToXML, ID_SOAP_NS_SCHEMA_2001, ID_SOAP_XSI_TYPE_DATETIME);
    FWriter.DefineGeneralParam(nil, false, 'AIdDate2', LIdDate2.WriteToXML, ID_SOAP_NS_SCHEMA_2001, ID_SOAP_XSI_TYPE_TIME);
    FWriter.DefineGeneralParam(nil, false, 'AIdDate3', LIdDate3.WriteToXML, ID_SOAP_NS_SCHEMA_2001, ID_SOAP_XSI_TYPE_DATE);
    if FReader.EncodingMode = semRPC then
      begin
      // just can't run this test in doc|lit - works differently
      FWriter.DefineGeneralParam(nil, true, 'AIdDate4', LIdDate1.WriteToXML, ID_SOAP_NS_SCHEMA_2001, ID_SOAP_XSI_TYPE_DATETIME);
      end;

    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    FReader.EncodingOptions := FReader.EncodingOptions + [seoUseDefaults];
    Check(FReader.ParamString[NIL, 'AString'] = 'xx', 'String Parameter Failed Checking');
    Check(IdSoapSameDateTime(FReader.ParamDateTime[NIL, 'ADate1'],LDate1), 'Date1 Parameter Failed Checking ('+FormatDateTime('yyyymmddhhnnsszzz', LDate1)+' / '+FormatDateTime('yyyymmddhhnnsszzz', FReader.ParamDateTime[NIL, 'ADate1'])+')');
    Check(FReader.ParamDateTime[NIL, 'ADate2'] = LDate2, 'Date2 Parameter Failed Checking');
    Check(FReader.ParamDateTime[NIL, 'ADate3'] = LDate3, 'Date3 Parameter Failed Checking');
    Check(FReader.ParamDateTime[NIL, 'ADate4'] = LDate4, 'Date4 Parameter Failed Checking');
    Check(IdSoapSameDateTime(FReader.ParamDateTime[NIL, 'ADate5'],LDate5), 'Date5 Parameter Failed Checking (Probable Rounding error)');

    LIdDate := TIdSoapDateTime.create;
    try
      Check(FReader.GetGeneralParam(nil, 'AIdDate1', LNil, LVal, LTypeNS, LType));
      check(not LNil);
      LIdDate.SetAsXML(LVal, LTypeNS, LType);
      Check(LIdDate.Year = LIdDate1.Year, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.Month = LIdDate1.Month, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.Day = LIdDate1.Day, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.Hour = LIdDate1.Hour, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.Minute = LIdDate1.Minute, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.Second = LIdDate1.Second, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.Nanosecond = LIdDate1.Nanosecond, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.Timezone = LIdDate1.Timezone, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.tzHours = LIdDate1.tzHours, 'IdDate1 Parameter Failed Checking');
      Check(LIdDate.tzMinutes = LIdDate1.tzMinutes, 'IdDate1 Parameter Failed Checking');
      LIdDate.SetAsXML(LVal, '', ''); // type may not be passed
    finally
      FreeAndNil(LIdDate);
    end;

    LIdDate := TIdSoapTime.create;
    try
      Check(FReader.GetGeneralParam(nil, 'AIdDate2', LNil, LVal, LTypeNS, LType));
      check(not LNil);
      LIdDate.SetAsXML(LVal, LTypeNS, LType);
      Check(LIdDate.Hour = LIdDate2.Hour, 'IdDate2 Parameter Failed Checking');
      Check(LIdDate.Minute = LIdDate2.Minute, 'IdDate2 Parameter Failed Checking');
      Check(LIdDate.Second = LIdDate2.Second, 'IdDate2 Parameter Failed Checking');
      Check(LIdDate.Nanosecond = LIdDate2.Nanosecond, 'IdDate2 Parameter Failed Checking');
      Check(LIdDate.Timezone = LIdDate2.Timezone, 'IdDate2 Parameter Failed Checking');
      Check(LIdDate.tzHours = LIdDate2.tzHours, 'IdDate2 Parameter Failed Checking');
      Check(LIdDate.tzMinutes = LIdDate2.tzMinutes, 'IdDate2 Parameter Failed Checking');
    finally
      FreeAndNil(LIdDate);
    end;

    LIdDate := TIdSoapDate.create;
    try
      Check(FReader.GetGeneralParam(nil, 'AIdDate3', LNil, LVal, LTypeNS, LType));
      check(not LNil);
      LIdDate.SetAsXML(LVal, LTypeNS, LType);
      Check(LIdDate.Year = LIdDate3.Year, 'IdDate3 Parameter Failed Checking');
      Check(LIdDate.Month = LIdDate3.Month, 'IdDate3 Parameter Failed Checking');
      Check(LIdDate.Day = LIdDate3.Day, 'IdDate3 Parameter Failed Checking');
      Check(LIdDate.Timezone = LIdDate3.Timezone, 'IdDate3 Parameter Failed Checking');
      Check(LIdDate.tzHours = LIdDate3.tzHours, 'IdDate3 Parameter Failed Checking');
      Check(LIdDate.tzMinutes = LIdDate3.tzMinutes, 'IdDate3 Parameter Failed Checking');
    finally
      FreeAndNil(LIdDate);
    end;
  finally
    FreeAndNil(LIdDate1);
    FreeAndNil(LIdDate2);
    FreeAndNil(LIdDate3);
    FreeAndNil(LIdDate5);
  end;
  if FReader.EncodingMode = semRPC then
    begin
    Check(FReader.GetGeneralParam(nil, 'AIdDate4', LNil, LVal, LTypeNS, LType));
    check(LNil);
    end
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Unicode;
var
  Val : word;
  LWide: WideString;
  LWideC: WideChar;
  LMimeType : string;
begin
  Val := 23423;
  move(Val, LWideC, sizeof(word));
  LWide := 'werwer';
  LWide := LWide + LWideC;
  check(LWide[7] = LWideC);

  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AString', GetTargetStr('x' + chr(167)));
  FWriter.DefineParamWideString(NIL, 'AWideString', LWide);
  FWriter.DefineParamWideChar(NIL, 'AWideChar', LWideC);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'AString'] = GetTargetStr('x' + chr(167)), 'String Parameter Failed Checking');
  if FReader.XmlProvider <> xpCustom then
    begin
    // Custom doesn't support widechar
    Check(FReader.ParamWideChar[NIL, 'AWideChar'] = LWideC, 'WideChar Parameter Failed Checking');
    Check(FReader.ParamWideString[NIL, 'AWideString'] = LWide, 'WideString Parameter Failed Checking');
    end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Char1;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamChar(NIL, 'AChar', #32);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamChar[NIL, 'AChar'] = #32, 'Char #32 failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Char2;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamChar(NIL, 'AChar', #126);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamChar[NIL, 'AChar'] = #126, 'Char #126 failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Char3;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamChar(NIL, 'AChar', #13);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamChar[NIL, 'AChar'] = #13, 'Char #13 failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Char4;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamChar(NIL, 'AChar', #10);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamChar[NIL, 'AChar'] = #13, 'Char #10 failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Char5;
var
  LMimeType : string;
begin
  FReader.EncodingOptions := [];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamChar(NIL, 'AChar', #13);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamChar[NIL, 'AChar'] = #10, 'Char #13 failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Char6;
var
  LMimeType : string;
begin
  FReader.EncodingOptions := [];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamChar(NIL, 'AChar', #10);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamChar[NIL, 'AChar'] = #10, 'Char #10 failed');
end;


procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str1;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', 'asd'+#13#10+'asd');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = 'asd'+#13#10+'asd', 'Windows EOLN failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str2;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', 'asd'+#10+'asd');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = 'asd'+#13#10+'asd', 'Linux EOLN failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str3;
var
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', #13#10);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = #13#10, 'Single Win EOLN failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str4;
var
  LMimeType : string;
begin
  FReader.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', 'asd'+#13#10+'asd');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = 'asd'+#10+'asd', 'Windows EOLN failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str5;
var
  LMimeType : string;
begin
  FReader.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', 'asd'+#10+'asd');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = 'asd'+#10+'asd', 'Linux EOLN failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str6;
var
  LMimeType : string;
begin
  FReader.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', #13#10);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = #10, 'Single Win EOLN failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str7;
var
  LMimeType : string;
begin
  FReader.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', 'test <test>');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = 'test <test>', 'chars <> failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_Str8;
var
  LMimeType : string;
begin
  FReader.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', GetTargetStr('Test'+Chr(0169)));
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.ParamString[NIL, 'AStr'] = GetTargetStr('Test'+Chr(0169)), 'Copyright failed');
end;


procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_StrBad1;
begin
  FWriter.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  ExpectedException := EIdSoapRequirementFail;
  FWriter.DefineParamString(NIL, 'AStr', #1);
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_StrBad2;
begin
  FWriter.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  ExpectedException := EIdSoapRequirementFail;
  FWriter.DefineParamChar(NIL, 'AStr', #12);
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_StrBad3;
begin
  FWriter.EncodingOptions := [seoCheckStrings];
  FWriter.SetMessageName('TestProc', 'urn:test');
  ExpectedException := EIdSoapRequirementFail;
  FWriter.DefineParamShortString(NIL, 'AStr', #18);
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_StrBad4;
begin
  FWriter.EncodingOptions := [];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'AStr', #1);
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_StrBad5;
begin
  FWriter.EncodingOptions := [];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamChar(NIL, 'AStr', #12);
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Param_StrBad6;
begin
  FWriter.EncodingOptions := [];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamShortString(NIL, 'AStr', #18);
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Struct;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test', self);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  FWriter.DefineParamString(NIL, 'TestParam1', 'Value3');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
  LNode := FReader.GetStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  Check(LNode.IsArray = false, 'Node IsArrayRoot is wrong');
  if FReader.EncodingMode = semDocument then
    begin
    Check(LNode.TypeName = '', 'Node class is wrong');
    end
  else
    begin
    Check(LNode.TypeName = 'TEncodingTestClass', 'Node class is wrong');
    end;
  Check(LNode.Reference = nil, 'Node reference should be nil');
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value1', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
  if FReader.EncodingMode = semRPC then
    begin
    ExpectedException := EIdSoapRequirementFail;
    FReader.GetStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test1');
    end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Struct_ByRef;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  FWriter.EncodingOptions := [seoUseCrLf, seoCheckStrings, seoReferences];
  FReader.EncodingOptions := [seoUseCrLf, seoCheckStrings, seoReferences];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test', self);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  FWriter.DefineParamString(NIL, 'TestParam1', 'Value3');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
  LNode := FReader.GetStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  Check(LNode.IsArray = false, 'Node IsArrayRoot is wrong');
  Check(LNode.Reference <> nil, 'Node reference should not be nil');
  LNode := LNode.Reference;
  Check(LNode.TestValid, 'Node not found');
  Check(LNode.IsArray = false, 'Node IsArrayRoot is wrong');
  Check(LNode.Reference = nil, 'Node reference should be nil');
  if FReader.EncodingMode = semRPC then
    begin
    Check(LNode.TypeName = 'TEncodingTestClass', 'Node class is wrong');
    Check(LNode.TypeNamespace = 'urn:test', 'Node class is wrong');
    end
  else
    begin
    Check(LNode.TypeName = '', 'Node class is wrong');
    Check(LNode.TypeNamespace = '', 'Node class is wrong');
    end;
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value1', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Struct_NoType;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  FWriter.EncodingOptions := DEFAULT_RPC_OPTIONS + [seoSuppressTypes] - [seoReferences];
  FReader.EncodingOptions := DEFAULT_RPC_OPTIONS - [seoRequireTypes];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test', self);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  FWriter.DefineParamString(NIL, 'TestParam1', 'Value3');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
  LNode := FReader.GetStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  Check(LNode.IsArray = false, 'Node IsArrayRoot is wrong');
  Check(LNode.TypeName = '', 'Node class is wrong');
  Check(LNode.Reference = nil, 'Node reference should be nil');
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value1', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
  FReader.GetStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test1');
  FReader.GetStruct(NIL, 'ANode', 'TEncodingTestClassNo', 'urn:test');
  ExpectedException := EIdSoapRequirementFail;
  FReader.GetStruct(NIL, 'ANode1', 'TEncodingTestClass', 'urn:test1');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Array;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  FWriter.AddArray(NIL, 'ANode', 'string', 'http://www.w3.org/2001/XMLSchema', false);
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  LNode := FReader.GetArray(NIL, 'ANode', true);
  if FReader.EncodingMode = semRPC then
    begin
    Check(LNode.TestValid, 'Node not found');
    Check(LNode.IsArray = true, 'Node IsArrayRoot is wrong');
    Check(LNode.TypeName = 'string', 'Node class is wrong');
    Check(LNode.TypeNamespace = 'http://www.w3.org/2001/XMLSchema', 'Node class is wrong');
    end
  else
    begin
    Check(LNode = nil);
    end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Element_Simple;
var
  LArray : TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LArray := FWriter.AddArray(NIL, 'ANode', 'string', 'http://www.w3.org/2001/XMLSchema', false);
  FWriter.DefineParamString(LArray, '0', 'Value1');
  FWriter.DefineParamString(LArray, '1', 'Value2');
  FWriter.DefineParamString(NIL, 'TestParam1', 'Value3');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
  LArray := FReader.GetArray(NIL, 'ANode');
  Check(LArray.TestValid, 'Node not found');
  Check(LArray.IsArray = true, 'Node IsArrayRoot is wrong');
  if FReader.EncodingMode = semRPC then
    begin
    Check(LArray.TypeName = 'string', 'Node class is wrong');
    end
  else
    begin
    Check(LArray.TypeName = '', 'Node class is wrong');
    end;
  Check(LArray.Params.count = 2, 'Node count is wrong');
  Check(FReader.ParamString[LArray, '0'] = 'Value1', 'Reading Parameter Failed');
  Check(FReader.ParamString[LArray, '1'] = 'Value2', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Element_Complex;
var
  LArray : TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LArray := FWriter.AddArray(NIL, 'ANode', 'string', 'http://www.w3.org/2001/XMLSchema', false);
  FWriter.DefineParamString(LArray, '0', 'Value1');
  FWriter.DefineParamString(LArray, '1', 'Value2');
  FWriter.DefineParamString(NIL, 'TestParam1', 'Value3');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
  LArray := FReader.GetArray(NIL, 'ANode');
  Check(LArray.TestValid, 'Node not found');
  Check(LArray.IsArray = true, 'Node IsArrayRoot is wrong');
  if FReader.EncodingMode = semDocument then
    begin
    Check(LArray.TypeName = '', 'Node class is wrong');
    Check(LArray.TypeNamespace = '');
    end
  else
    begin
    Check(LArray.TypeName = 'string', 'Node class is wrong');
    Check(LArray.TypeNamespace = 'http://www.w3.org/2001/XMLSchema');
    end;
  Check(LArray.Params.count = 2, 'Node count is wrong');
  Check(FReader.ParamString[LArray, '0'] = 'Value1', 'Reading Parameter Failed');
  Check(FReader.ParamString[LArray, '1'] = 'Value2', 'Reading Parameter Failed');
  Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Element_Complex_Sparse;
var
  LArray : TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LArray := FWriter.AddArray(NIL, 'ANode', 'string', 'http://www.w3.org/2001/XMLSchema', false);
  FWriter.DefineParamString(LArray, '0', 'Value1');
  FWriter.DefineParamString(LArray, '2', 'Value2');
  FWriter.DefineParamString(NIL, 'TestParam1', 'Value3');
  if FWriter.EncodingMode = semDocument then
    begin
    ExpectedException := EIdSoapRequirementFail;
    FWriter.Encode(FStream, LMimeType, nil, nil);
    end
  else
    begin
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
    Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
    Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
    LArray := FReader.GetArray(NIL, 'ANode');
    Check(LArray.TestValid, 'Node not found');
    Check(LArray.IsArray = true, 'Node IsArrayRoot is wrong');
    Check(LArray.TypeName = 'string', 'Node class is wrong');
    Check(LArray.Params.count = 2, 'Node count is wrong');
    Check(FReader.ParamString[LArray, '0'] = 'Value1', 'Reading Parameter Failed');
    Check(FReader.ParamString[LArray, '2'] = 'Value2', 'Reading Parameter Failed');
    Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
    end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Element_Complex_2Dim;
var
  LArray : TIdSoapNode;
  LArray2 : TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LArray := FWriter.AddArray(NIL, 'ANode', 'string', 'http://www.w3.org/2001/XMLSchema', false);
  LArray2 := FWriter.AddArray(LArray, '0', 'string', 'http://www.w3.org/2001/XMLSchema', false);
  FWriter.DefineParamString(LArray2, '0', 'Value1');
  FWriter.DefineParamString(LArray2, '2', 'Value2');
  LArray2 := FWriter.AddArray(LArray, '1', 'string', 'http://www.w3.org/2001/XMLSchema', false);
  FWriter.DefineParamString(LArray2, '1', 'Value4');
  FWriter.DefineParamString(LArray2, '3', 'Value5');
  FWriter.DefineParamString(LArray2, '103', 'Value6');
  FWriter.DefineParamString(NIL, 'TestParam1', 'Value3');
  if FWriter.EncodingMode = semDocument then
    begin
    ExpectedException := EIdSoapRequirementFail;
    FWriter.Encode(FStream, LMimeType, nil, nil);
    end
  else
    begin
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
    Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
    Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
    LArray := FReader.GetArray(NIL, 'ANode');
    LArray2 := FReader.GetArray(LArray, '0');
    Check(LArray2.TestValid, 'Node not found');
    Check(LArray2.IsArray = true, 'Node IsArrayRoot is wrong');
    Check(LArray2.TypeName = 'string', 'Node class is wrong');
    Check(LArray2.Params.count = 2, 'Node count is wrong');
    Check(FReader.ParamString[LArray2, '0'] = 'Value1', 'Reading Parameter Failed');
    Check(FReader.ParamString[LArray2, '2'] = 'Value2', 'Reading Parameter Failed');
    LArray2 := FReader.GetArray(LArray, '1');
    Check(LArray2.TestValid, 'Node not found');
    Check(LArray2.IsArray = true, 'Node IsArrayRoot is wrong');
    Check(LArray2.TypeName = 'string', 'Node class is wrong');
    Check(LArray2.Params.count = 3, 'Node count is wrong');
    Check(FReader.ParamString[LArray2, '1'] = 'Value4', 'Reading Parameter Failed');
    Check(FReader.ParamString[LArray2, '3'] = 'Value5', 'Reading Parameter Failed');
    Check(FReader.ParamString[LArray2, '103'] = 'Value6', 'Reading Parameter Failed');
    Check(FReader.ParamString[NIL, 'TestParam1'] = 'Value3', 'Reading Parameter Failed');
    end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_No_Exist;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  ExpectedException := EIdSoapRequirementFail;
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test', self);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  LNode := FReader.GetStruct(NIL, 'AOtherNode', 'TEncodingTestClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value1', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_No_Class;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  ExpectedException := EAssertionFailed;
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', '', 'urn:test', self);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  LNode := FReader.GetStruct(NIL, 'ANode', '', '');
  Check(LNode.TestValid, 'Node not found');
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value1', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Wrong_Class;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test', self);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  if FReader.EncodingMode = semRPC then
    begin
    ExpectedException := EIdSoapRequirementFail;
    end;
  LNode := FReader.GetStruct(NIL, 'ANode', 'TOtherClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value1', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Case_Name;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test', nil);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  LNode := FReader.GetStruct(NIL, 'anode', 'TEncodingTestClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value1', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Node_Level2;
var
  LNode: TIdSoapNode;
  LMimeType : string;
begin
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  LNode := FWriter.AddStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test', nil);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value1');
  LNode := FWriter.AddStruct(LNode, 'ANode', 'TEncodingTestClass', 'urn:test', nil);
  FWriter.DefineParamString(LNode, 'TestParam', 'Value2');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
  LNode := FReader.GetStruct(NIL, 'ANode', 'TEncodingTestClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  LNode := FReader.GetStruct(LNode, 'ANode', 'TEncodingTestClass', 'urn:test');
  Check(LNode.TestValid, 'Node not found');
  Check(FReader.ParamString[LNode, 'TestParam'] = 'Value2', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Exception1;
var
  LExcept: Exception;
  LMimeType : string;
begin
  ExpectedException := Exception;
  LExcept := Exception.Create('Testing');
  try
    FFault.DefineException(LExcept);
    FFault.Encode(FStream, LMimeType, nil, nil);
  finally
    // it's unusual to free exceptions like this. But this one has never
    // been raised. A different exception of the same class is raised below
    FreeAndNil(LExcept);
    end;
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  check(False, 'Exception should''ve been raised');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Exception1_Message_Check;
var
  LExcept: Exception;
  LMimeType : string;
begin
  LExcept := Exception.Create('Testing');
  try
    FFault.DefineException(LExcept);
    FFault.Encode(FStream, LMimeType, nil, nil);
  finally
    // it's unusual to free exceptions like this. But this one has never
    // been raised. A different exception of the same class is raised below
    FreeAndNil(LExcept);
    end;
  FStream.Position := 0;
  try
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    check(False, 'Exception should''ve been raised');
  except
    on e:
    Exception do
      begin
      Check(e.message = 'soap:Server: Testing', 'Exception message is wrong');
      end
    end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Exception2;
var
  LExcept: Exception;
  LMimeType : string;
begin
  LExcept := EIdSoapRequirementFail.Create('Testing');
  try
    FFault.DefineException(LExcept);
    FFault.Encode(FStream, LMimeType, nil, nil);
  finally
    // it's unusual to free exceptions like this. But this one has never
    // been raised. A different exception of the same class is raised below
    FreeAndNil(LExcept);
    end;
  FStream.Position := 0;
  ExpectedException := EIdSoapRequirementFail;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  check(False, 'Exception should''ve been raised');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Exception3;
var
  LExcept: Exception;
  LMimeType : string;
begin
  ExpectedException := EConvertError;
  LExcept := EConvertError.Create('Testing');
  try
    FFault.DefineException(LExcept);
    FFault.Encode(FStream, LMimeType, nil, nil);
  finally
    // it's unusual to free exceptions like this. But this one has never
    // been raised. A different exception of the same class is raised below
    FreeAndNil(LExcept);
    end;
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  check(False, 'Exception should''ve been raised');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Exception4;
var
  LExcept: Exception;
  LMimeType : string;
begin
  ExpectedException := EIdReadTimeout;
  LExcept := EIdReadTimeout.Create('Testing');
  try
    FFault.DefineException(LExcept);
    FFault.Encode(FStream, LMimeType, nil, nil);
  finally
    // it's unusual to free exceptions like this. But this one has never
    // been raised. A different exception of the same class is raised below
    FreeAndNil(LExcept);
    end;
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  check(False, 'Exception should''ve been raised');
end;

type
  ETestingExceptionClass = class(EIdBaseSoapableException);

procedure TIdSoapPacketBaseTests.Test_IdSoap_Exception5;
var
  LExcept: Exception;
  LMimeType : string;
begin
  ExpectedException := ETestingExceptionClass;
  LExcept := ETestingExceptionClass.Create('Testing');
  try
    FFault.DefineException(LExcept);
    FFault.Encode(FStream, LMimeType, nil, nil);
  finally
    // it's unusual to free exceptions like this. But this one has never
    // been raised. A different exception of the same class is raised below
    FreeAndNil(LExcept);
    end;
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  check(False, 'Exception should''ve been raised');
end;

{ TITIRpcXML8SelfCases }

function TIdSoapPacketXML8Tests.CreateFault: TIdSoapFaultWriter;
begin
  result := TIdSoapFaultWriterXML.create(IdSoapV1_1, xpOpenXML);
  (result as TIdSoapFaultWriterXML).UseUTF16 := false;
end;

function TIdSoapPacketXML8Tests.CreateReader: TIdSoapReader;
begin
  result := TIdSoapReaderXML.create(IdSoapV1_1, xpOpenXML);
  SetReaderOptions(Result);
end;

function TIdSoapPacketXML8Tests.CreateWriter: TIdSoapWriter;
begin
{$IFDEF USE_MSXML}
  result := TIdSoapWriterXML.create(IdSoapV1_1, xpMSXML);
{$ELSE}
  result := TIdSoapWriterXML.create(IdSoapV1_1, xpOpenXML);
{$ENDIF}
  (result as TIdSoapWriterXML).UseUTF16 := false;
  SetWriterOptions(result);
end;

{ TITIRpcXMLSelfCases }

function TIdSoapPacketXML16Tests.CreateFault: TIdSoapFaultWriter;
begin
  result := TIdSoapFaultWriterXML.create(IdSoapV1_1, xpOpenXML);
  (result as TIdSoapFaultWriterXML).UseUTF16 := true;
end;

function TIdSoapPacketXML16Tests.CreateReader: TIdSoapReader;
begin
  result := TIdSoapReaderXML.create(IdSoapV1_1, xpOpenXML);
end;

function TIdSoapPacketXML16Tests.CreateWriter: TIdSoapWriter;
begin
  result := TIdSoapWriterXML.create(IdSoapV1_1, xpOpenXML);
  (result as TIdSoapWriterXML).UseUTF16 := true;
end;

{ TITIRpcBinSelfCases }

function TIdSoapPacketBinTests.CreateFault: TIdSoapFaultWriter;
begin
  result := TIdSoapFaultWriterBin.create(IdSoapV1_1, xpOpenXML);
end;

function TIdSoapPacketBinTests.CreateReader: TIdSoapReader;
begin
  result := TIdSoapReaderBin.create(IdSoapV1_1, xpOpenXML);
end;

function TIdSoapPacketBinTests.CreateWriter: TIdSoapWriter;
begin
  result := TIdSoapWriterBin.create(IdSoapV1_1, xpOpenXML);
end;

procedure TIdSoapPacketBaseTests.RepeatTests;
var i : integer;
begin
  TearDown;
  for i := 0 to 40 do
    begin
    Setup;
    Test_IdSoap_Node_Level2;
    TearDown;
    end;
end;

{ TITIRpcXMLStdCases }

procedure TIdSoapCompatibilityBorland.Test_Standard_Packet_Borland1;
begin
  ReadFile('SoapSamples'+PathDelim+'Soap1.xml');
  Check(FReader.MessageName = 'CreateSessionResponse');
  Check(FReader.MessageNameSpace = 'urn:RPC_Sessions-ISessionServices');
  Check(FReader.ParamCardinal[nil, ID_SOAP_NAME_RESULT] = 35981685, 'Failed to read Borland Response Soap Packet');
end;

procedure TIdSoapCompatibilityBorland.Test_Standard_Packet_Borland_Exception;
begin
  ExpectedException := EIdSoapFault;
  ReadFile('SoapSamples'+PathDelim+'TestException_Response_Exception.xml');
end;

procedure TIdSoapCompatibilityBorland.Test_Standard_Packet_Borland_Exception_Class;
begin
  ExpectedException := EAssertionFailed;
  ReadFile('SoapSamples'+PathDelim+'TestException_Response_KnownException.xml');
end;

procedure TIdSoapCompatibilityBorland.Test_Standard_Packet_BorlandPretty;
begin
  ReadFile('SoapSamples'+PathDelim+'SoapPretty.xml');
  Check(FReader.MessageName = 'CreateSessionResponse');
  Check(FReader.MessageNameSpace = 'urn:RPC_Sessions-ISessionServices');
  Check(FReader.ParamCardinal[nil, ID_SOAP_NAME_RESULT] = 35981685, 'Failed to read Borland Response Soap Packet');
end;

procedure TIdSoapCompatibilityBorland.CheckBorlandPacket(AUseRefs : boolean);
var
  LArray : TIdSoapNode;
  LObject : TIdSoapNode;
begin
  Check(FReader.MessageName = 'TestParam');
  Check(FReader.MessageNameSpace = 'urn:Defn-ITestInterface');
  Check(FReader.ParamInteger[nil, 'Aint'] = 2);
  Check(FReader.ParamString[nil, 'AString'] = 'AString<something>');
  LArray := FReader.GetArray(nil, 'AArray');
  Check(LArray.TestValid(TIdSoapNode));
  Check(LArray.Params.count = 5);
  Check(FReader.ParamString[LArray, '0'] = 'ArrayString 0');
  Check(FReader.ParamString[LArray, '1'] = 'ArrayString 1');
  Check(FReader.ParamString[LArray, '2'] = 'ArrayString 2');
  Check(FReader.ParamString[LArray, '3'] = 'ArrayString 3');
  Check(FReader.ParamString[LArray, '4'] = 'ArrayString 4');
  LObject := FReader.GetStruct(nil, 'AObject', 'TTestObject', 'urn:Defn');
  if AUseRefs then
    begin
    check(LObject.TestValid(TIdSoapNode));
    check(LObject.Reference.TestValid(TIdSoapNode));
    LObject := LObject.Reference;
    end;
  check(LObject.TestValid(TIdSoapNode));
  Check(FReader.ParamInteger[LObject, 'Testint'] = 3);
  Check(FReader.ParamString[LObject, 'TestString'] = 'ClassString 1 something');
  LArray := FReader.GetArray(LObject, 'TestArray');
  Check(LArray.TestValid(TIdSoapNode));
  Check(LArray.Params.count = 3);
  Check(FReader.ParamString[LArray, '0'] = 'ClassArrayString 0');
  Check(FReader.ParamString[LArray, '1'] = 'ClassArrayString 1');
  Check(FReader.ParamString[LArray, '2'] = 'ClassArrayString 2');
  LObject := FReader.GetStruct(LObject, 'TestObject', 'TTestObject', 'urn:Defn');
  if AUseRefs then
    begin
    check(LObject.TestValid(TIdSoapNode));
    check(LObject.Reference.TestValid(TIdSoapNode));
    LObject := LObject.Reference;
    end;
  check(LObject.TestValid(TIdSoapNode));
  Check(FReader.ParamInteger[LObject, 'Testint'] = 5);
  Check(FReader.ParamString[LObject, 'TestString'] = 'ClassString  2 something');
  LArray := FReader.GetArray(LObject, 'TestArray');
  Check(LArray.TestValid(TIdSoapNode));
  Check(LArray.Params.count = 30);
  Check(FReader.ParamString[LArray, '0'] = 'Class2ArrayString 0');
  Check(FReader.ParamString[LArray, '1'] = 'Class2ArrayString 1');
  Check(FReader.ParamString[LArray, '2'] = 'Class2ArrayString 2');
  Check(FReader.ParamString[LArray, '3'] = 'Class2ArrayString 3');
  Check(FReader.ParamString[LArray, '4'] = 'Class2ArrayString 4');
  Check(FReader.ParamString[LArray, '5'] = 'Class2ArrayString 5');
  Check(FReader.ParamString[LArray, '6'] = 'Class2ArrayString 6');
  Check(FReader.ParamString[LArray, '7'] = 'Class2ArrayString 7');
  Check(FReader.ParamString[LArray, '8'] = 'Class2ArrayString 8');
  Check(FReader.ParamString[LArray, '9'] = 'Class2ArrayString 9');
  Check(FReader.ParamString[LArray, '10'] = 'Class2ArrayString 10');
  Check(FReader.ParamString[LArray, '11'] = 'Class2ArrayString 11');
  Check(FReader.ParamString[LArray, '12'] = 'Class2ArrayString 12');
  Check(FReader.ParamString[LArray, '13'] = 'Class2ArrayString 13');
  Check(FReader.ParamString[LArray, '14'] = 'Class2ArrayString 14');
  Check(FReader.ParamString[LArray, '15'] = 'Class2ArrayString 15');
  Check(FReader.ParamString[LArray, '16'] = 'Class2ArrayString 16');
  Check(FReader.ParamString[LArray, '17'] = 'Class2ArrayString 17');
  Check(FReader.ParamString[LArray, '18'] = 'Class2ArrayString 18');
  Check(FReader.ParamString[LArray, '19'] = 'Class2ArrayString 19');
  Check(FReader.ParamString[LArray, '20'] = 'Class2ArrayString 20');
  Check(FReader.ParamString[LArray, '21'] = 'Class2ArrayString 21');
  Check(FReader.ParamString[LArray, '22'] = 'Class2ArrayString 22');
  Check(FReader.ParamString[LArray, '23'] = 'Class2ArrayString 23');
  Check(FReader.ParamString[LArray, '24'] = 'Class2ArrayString 24');
  Check(FReader.ParamString[LArray, '25'] = 'Class2ArrayString 25');
  Check(FReader.ParamString[LArray, '26'] = 'Class2ArrayString 26');
  Check(FReader.ParamString[LArray, '27'] = 'Class2ArrayString 27');
  Check(FReader.ParamString[LArray, '28'] = 'Class2ArrayString 28');
  Check(FReader.ParamString[LArray, '29'] = 'Class2ArrayString 29');
  check(LObject.Children.IndexOf('TestObject') = -1);
end;

procedure TIdSoapCompatibilityBorland.Test_Borland_Std;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland.xml');
  CheckBorlandPacket(true);
end;

procedure TIdSoapCompatibilityBorland.Test_Borland_Pretty;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland_Pretty.xml');
  CheckBorlandPacket(true);
  Check(Freader.Headers.count = 0);
end;

procedure TIdSoapCompatibilityBorland.Test_Borland_Pretty_InLine;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland_InLine.xml');
  CheckBorlandPacket(false);
end;

procedure TIdSoapCompatibilityBorland.Test_Borland_Pretty_InLine_NoNull;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland_InLine_NoNull.xml');
  CheckBorlandPacket(false);
end;

procedure TIdSoapCompatibilityBorland.Test_Borland_Pretty_NoNull;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland_Pretty_NoNull.xml');
  CheckBorlandPacket(true);
end;

procedure TIdSoapCompatibilityBorland.Test_Soap_Headers;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland_Headers.xml');
  CheckBorlandPacket(true);
  Check(FReader.Headers.count = 1);
end;

procedure TIdSoapCompatibilityBorland.Test_Soap_Headers_MustUnderstand1;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland_Headers_Req.xml');
  CheckBorlandPacket(true);
  Check(FReader.Headers.count = 1);
end;

procedure TIdSoapCompatibilityBorland.Test_Soap_Headers_MustUnderstand2;
begin
  if IdTypeRegistry.IndexOf('TEncodingTestClass') = -1 then
    begin
    // the fact that we actually register the wrong class is OK, since we
    // are only worried about namespace registration
    IdSoapRegisterType(TypeInfo(TEncodingTestClass));
    end;
  FReader.EncodingOptions := DEFAULT_RPC_OPTIONS + [seoCheckMustUnderstand];
  ReadFile('SoapSamples'+PathDelim+'Soap_Borland_Headers_Req.xml');
  ExpectedException := EIdSoapRequirementFail;
  FReader.CheckMustUnderstand;
end;

{ TIdSoapCompatibilityStandard }

procedure TIdSoapCompatibilityStandard.Test_Standard_Example_1;
begin
  FReader.EncodingOptions := DEFAULT_RPC_OPTIONS - [seoRequireTypes];
  ReadFile('SoapSamples'+PathDelim+'Soap_Std_Example_1.xml');
  Check(FReader.MessageNameSpace = 'Some-URI');
  Check(FReader.MessageName = 'GetLastTradePrice');
  Check(FReader.ParamString[nil, 'symbol'] = 'DIS');
end;

procedure TIdSoapCompatibilityStandard.Test_Standard_Example_2;
begin
  FReader.EncodingOptions := DEFAULT_RPC_OPTIONS - [seoRequireTypes];
  ReadFile('SoapSamples'+PathDelim+'Soap_Std_Example_2.xml');
  Check(FReader.MessageNameSpace = 'Some-URI');
  Check(FReader.MessageName = 'GetLastTradePriceResponse');
  Check(FReader.ParamCurrency[nil, 'price'] = 34.5);
end;

procedure TIdSoapCompatibilityStandard.Test_Standard_Packet_Array;
var
  LArray : TIdSoapNode;
  LArray2 : TIdSoapNode;
  LArray3 : TIdSoapNode;
  LOrder : TIdSoapNode;
begin
  ReadFile('SoapSamples'+PathDelim+'Soap_Std_Array_Samples.xml');
  Check(FReader.MessageName = 'CreateSessionResponse');
  Check(FReader.MessageNameSpace = 'urn:RPC_Sessions-ISessionServices');

  Check(FReader.ParamCardinal[nil, ID_SOAP_NAME_RESULT] = 35981685, 'Failed to read Borland Response Soap Packet');

{
- <Array1 xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:int[2]">
  <number>3</number>
  <number>4</number>
  </Array1>
}
  LArray := FReader.GetArray(nil, 'Array1');
  check(LArray.IsArray);
  Check(LArray.Params.Count = 2);
  Check(LArray.TypeName = 'int');
  Check(FReader.ParamInteger[LArray, '0'] = 3);
  Check(FReader.ParamInteger[LArray, '1'] = 4);


{
- <Array2 xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="ns2:Order[2]">
- <Order>
  <Product xsi:type="string">Apple</Product>
  <Price xsi:type="float">1.56</Price>
  </Order>
- <Order>
  <Product xsi:type="string">Peach</Product>
  <Price xsi:type="float">1.48</Price>
  </Order>
  </Array2>
}
  LArray := FReader.GetArray(nil, 'Array2');
  check(LArray.IsArray);
  Check(LArray.Children.Count = 2);
  Check(LArray.TypeName = 'Order');
  LOrder := FReader.GetStruct(LArray, '0', 'Order', 'urn:test');
  check(not LOrder.IsArray);
  Check(LOrder.Params.Count = 2);
  Check(LOrder.TypeName = 'Order');
  Check(FReader.ParamString[LOrder, 'Product'] = 'Apple');
  Check(FReader.ParamSingle[LOrder, 'Price'] - 1.56 < 0.001);
  LOrder := FReader.GetStruct(LArray, '1', 'Order', 'urn:test');
  check(not LOrder.IsArray);
  Check(LOrder.Params.Count = 2);
  Check(LOrder.TypeName = 'Order');
  Check(FReader.ParamString[LOrder, 'Product'] = 'Peach');
  Check(FReader.ParamSingle[LOrder, 'Price'] - 1.48 < 0.001);

{
- <Array3 xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[][2]">
  <item href="#array-1" />
  <item href="#array-2" />
  </Array3>
- <Array4 id="array-1" xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[3]">
  <item>r1c1</item>
  <item>r1c2</item>
  <item>r1c3</item>
  </Array4>
- <Array5 id="array-2" xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[2]">
  <item>r2c1</item>
  <item>r2c2</item>
  </Array5>
}
  LArray := FReader.GetArray(nil, 'Array3');
  check(LArray.IsArray);
  Check(LArray.Children.Count = 2);
  Check(AnsiSameText(LArray.TypeName, 'String'));
  LArray2 := FReader.GetArray(LArray, '0');
  check(LArray2.IsArray);
  check(not Assigned(LArray2.Reference)); // already dereferenced
  check(LArray2.IsArray);
  Check(LArray2.Params.Count = 3);
  Check(AnsiSameText(LArray2.TypeName, 'String'));
  Check(FReader.ParamString[LArray2, '0'] = 'r1c1');
  Check(FReader.ParamString[LArray2, '1'] = 'r1c2');
  Check(FReader.ParamString[LArray2, '2'] = 'r1c3');
  LArray2 := FReader.GetArray(LArray, '1');
  check(LArray2.IsArray);
  check(not Assigned(LArray2.Reference));
  check(LArray2.IsArray);
  Check(LArray2.Params.Count = 2);
  Check(AnsiSameText(LArray2.TypeName, 'String'));
  Check(FReader.ParamString[LArray2, '0'] = 'r2c1');
  Check(FReader.ParamString[LArray2, '1'] = 'r2c2');

{
- <Array6 xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[2,3]">
  <item>r1c1</item>
  <item>r1c2</item>
  <item>r1c3</item>
  <item>r2c1</item>
  <item>r2c2</item>
  <item>r2c3</item>
  </Array6>
}
  LArray := FReader.GetArray(nil, 'Array6');
  check(LArray.IsArray);
  Check(LArray.Children.Count = 2);
  Check(AnsiSameText(LArray.TypeName, 'String'));
  LArray2 := FReader.GetArray(LArray, '0');
  check(LArray2.IsArray);
  Check(LArray2.Params.Count = 3);
  Check(AnsiSameText(LArray2.TypeName, 'String'));
  Check(FReader.ParamString[LArray2, '0'] = 'r1c1');
  Check(FReader.ParamString[LArray2, '1'] = 'r1c2');
  Check(FReader.ParamString[LArray2, '2'] = 'r1c3');
  LArray2 := FReader.GetArray(LArray, '1');
  check(LArray2.IsArray);
  Check(LArray2.Params.Count = 3);
  Check(AnsiSameText(LArray2.TypeName, 'String'));
  Check(FReader.ParamString[LArray2, '0'] = 'r2c1');
  Check(FReader.ParamString[LArray2, '1'] = 'r2c2');
  Check(FReader.ParamString[LArray2, '2'] = 'r2c3');

{
- <Array7 xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[6]" SOAP-ENC:offset="[3]">
  <item>The fourth element</item>
  <item>The fifth element</item>
  <item>The sixth element</item>
  </Array7>
}
  LArray := FReader.GetArray(nil, 'Array7');
  check(LArray.IsArray);
  Check(LArray.Params.Count = 3);
  Check(AnsiSameText(LArray.TypeName, 'string'));
  Check(FReader.ParamString[LArray, '3'] = 'The fourth element');
  Check(FReader.ParamString[LArray, '4'] = 'The fifth element');
  Check(FReader.ParamString[LArray, '5'] = 'The sixth element');

{
- <Array8 xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[,][4]">
  <item href="#array-3" SOAP-ENC:position="[2]" />
  </Array8>
- <Array9 id="array-3" xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[10,10]">
  <item SOAP-ENC:position="[2,2]">Third row, third col</item>
  <item SOAP-ENC:position="[7,2]">Eighth row, third col</item>
  </Array9>
}
  LArray := FReader.GetArray(nil, 'Array8');
  check(LArray.IsArray);
  Check(LArray.Children.Count = 1);
  Check(AnsiSameText(LArray.TypeName, 'String'));
  LArray2 := FReader.GetArray(LArray, '2');
  check(LArray2.IsArray);
  check(not Assigned(LArray2.Reference));
  check(LArray2.IsArray);
  Check(LArray2.Children.Count = 2);
  Check(AnsiSameText(LArray2.TypeName, 'String'));
  LArray3 := FReader.GetArray(LArray2, '2');
  check(LArray3.IsArray);
  Check(LArray3.Params.Count = 1);
  Check(AnsiSameText(LArray3.TypeName, 'String'));
  Check(FReader.ParamString[LArray3, '2'] = 'Third row, third col');
  LArray3 := FReader.GetArray(LArray2, '7');
  check(LArray3.IsArray);
  Check(LArray3.Params.Count = 1);
  Check(AnsiSameText(LArray3.TypeName, 'String'));
  Check(FReader.ParamString[LArray3, '2'] = 'Eighth row, third col');

{
- <Array10 xsi:type="SOAP-ENC:array" SOAP-ENC:arrayType="xsd:string[,][4]">
- <Array11 xsi:type="SOAP-ENC:array" SOAP-ENC:position="[2]" SOAP-ENC:arrayType="xsd:string[10,10]">
  <item SOAP-ENC:position="[2,2]">Third row, third col</item>
  <item SOAP-ENC:position="[7,2]">Eighth row, third col</item>
  </Array11>
  </Array10>
}
  LArray := FReader.GetArray(nil, 'Array10');
  check(LArray.IsArray);
  Check(LArray.Children.Count = 1);
  Check(AnsiSameText(LArray.TypeName, 'String'));
  LArray2 := FReader.GetArray(LArray, '2');
  check(LArray2.IsArray);
  Check(LArray2.Children.Count = 2);                          
  Check(AnsiSameText(LArray2.TypeName, 'String'));
  LArray3 := FReader.GetArray(LArray2, '2');
  check(LArray3.IsArray);
  Check(LArray3.Params.Count = 1);
  Check(AnsiSameText(LArray3.TypeName, 'String'));
  Check(FReader.ParamString[LArray3, '2'] = 'Third row, third col');
  LArray3 := FReader.GetArray(LArray2, '7');
  check(LArray3.IsArray);
  Check(LArray3.Params.Count = 1);
  Check(AnsiSameText(LArray3.TypeName, 'String'));
  Check(FReader.ParamString[LArray3, '2'] = 'Eighth row, third col');
end;

{ TIdSoapCompatibilityGeneral }

procedure TIdSoapCompatibilityGeneral.Test_Soap_Fault;
begin
  try
    ReadFile('SoapSamples'+PathDelim+'SampleFault.xml');
    check(false);
  except
    on e:exception do
      begin
      check(e is EIdSoapFault);
      check(e.message = 'Server: Unknown SOAPAction ITest');
      end;
  end;
end;

procedure TIdSoapCompatibilityGeneral.Test_Soap_Fault1;
begin
  try
    ReadFile('SoapSamples'+PathDelim+'SoapFault1.xml');
    check(false);
  except
    on e:EIdSoapFault do
      begin
      check(e.FaultActor = '');
      check(e.FaultCode = 'ns1:Server.userException');
      check(e.FaultString = 'java.lang.Exception: BLJAJAJA JAKAS HUJNJA');
      check(e.Details <> '');
      end;
  end;
end;

procedure TIdSoapCompatibilityGeneral.Test_Soap_Fault2;
begin
  try
    ReadFile('SoapSamples'+PathDelim+'SoapFault2.xml');
    check(false);
  except
    on e:EIdSoapFault do
      begin
      check(e.FaultActor = '/LRInterimWeb/servlet/rpcrouter');
      check(e.FaultCode = 'SOAP-ENV:Server');
      check(e.FaultString = 'exception.AttributeMissing');
      check(e.Details <> '');
      end;
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_EncOpt_TypesIn1;
var
  LMimeType : string;
begin
  FWriter.EncodingOptions := DEFAULT_RPC_OPTIONS;
  FReader.EncodingOptions := DEFAULT_RPC_OPTIONS;
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_EncOpt_TypesIn2;
var
  LMimeType : string;
begin
  FWriter.EncodingOptions := DEFAULT_RPC_OPTIONS;
  FReader.EncodingOptions := DEFAULT_RPC_OPTIONS - [seoRequireTypes];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_EncOpt_TypesOut1;
var
  LMimeType : string;
begin
  FWriter.EncodingOptions := DEFAULT_RPC_OPTIONS + [seoSuppressTypes];
  FReader.EncodingOptions := DEFAULT_RPC_OPTIONS - [seoRequireTypes];
  FWriter.SetMessageName('TestProc', 'urn:test');
  FWriter.DefineParamString(NIL, 'TestParam', 'Value');
  FWriter.Encode(FStream, LMimeType, nil, nil);
  FStream.Position := 0;
  FReader.ReadMessage(FStream, LMimeType, nil, nil);
  FReader.checkpacketOK;
  FReader.ProcessHeaders;
  FReader.DecodeMessage;
  Check(FReader.MessageName = 'TestProc', 'Soap method Name failed');
  Check(FReader.ParamString[NIL, 'TestParam'] = 'Value', 'Reading Parameter Failed');
end;

{ TIdSoapCompatibilityGoogle }

procedure TIdSoapCompatibilityGoogle.Test_Read_GoogleGetCachedPage;
begin
  ReadFile('SoapSamples'+PathDelim+'GoogleGetCachedPage.xml');
  Check(FReader.ParamString[nil, 'key'] = '00000000000000000000000000000000');
  Check(FReader.ParamString[nil, 'url'] = 'http://www.google.com/');
end;

procedure TIdSoapCompatibilityGoogle.Test_Read_GoogleGetCachedPageResponse;
begin
  ReadFile('SoapSamples'+PathDelim+'GoogleGetCachedPageResponse.xml');
end;

procedure TIdSoapCompatibilityGoogle.Test_Read_GoogleSearch;
begin
  ReadFile('SoapSamples'+PathDelim+'GoogleSearch.xml');
  Check(FReader.Paramstring[nil, 'key'] = '00000000000000000000000000000000');
  Check(FReader.Paramstring[nil, 'q'] = 'shrdlu winograd maclisp teletype');
  Check(FReader.ParamInteger[nil, 'start'] = 0);
  Check(FReader.ParamInteger[nil, 'maxResults'] = 10);
  Check(FReader.ParamBoolean[nil, 'filter'] = true);
  Check(FReader.Paramstring[nil, 'restrict'] = '');
  Check(FReader.ParamBoolean[nil, 'safeSearch'] = false);
  Check(FReader.Paramstring[nil, 'lr'] = '');
  Check(FReader.Paramstring[nil, 'ie'] = 'latin1');
  Check(FReader.Paramstring[nil, 'oe'] = 'latin1');
end;

procedure TIdSoapCompatibilityGoogle.Test_Read_GoogleSearchResponse;
begin
  ReadFile('SoapSamples'+PathDelim+'GoogleSearchResponse.xml');
end;

procedure TIdSoapCompatibilityGoogle.Test_Read_GoogleSpellingSuggestion;
begin
  ReadFile('SoapSamples'+PathDelim+'GoogleSpellingSuggestion.xml')
end;

procedure TIdSoapCompatibilityGoogle.Test_Read_GoogleSpellingSuggestionResponse;
begin
  ReadFile('SoapSamples'+PathDelim+'GoogleSpellingSuggestionResponse.xml')

end;

{ TReaderTestCase }

procedure TReaderTestCase.Setup;
begin
  FReader := TIdSoapReaderXML.create(IdSoapV1_1, GXmlProvider);
end;

procedure TReaderTestCase.TearDown;
begin
  FreeAndNil(FReader);
end;

procedure TReaderTestCase.ReadFile(AFileName: string);
Var
  LStream : TFileStream;
begin
  assert(FileExists(AFileName), 'File "'+AFileName+'" not found');
  LStream := TFileStream.create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    FReader.ReadMessage(LStream, '', nil, nil);
    FReader.CheckPacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
  finally
    FreeAndNil(LStream);
  end;
end;

{ TIdSoapCompatibilitySoapBuilders }

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echostring;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoString.xml');
  Check(FReader.BaseNode.ParamString['inputString'] = 'hello');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echostringResponse;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStringResponse.xml');
  Check(FReader.BaseNode.ParamString['return'] = 'hello');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echostringArray;
var
  LArrayNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStringArray.xml');
  LArrayNode := FReader.GetArray(nil, 'inputStringArray', false);
  Check(LArrayNode.ParamString['0'] = 'hello');
  Check(LArrayNode.ParamString['1'] = 'goodbye');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echostringArrayResponse;
var
  LArrayNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStringArrayResponse.xml');
  LArrayNode := FReader.GetArray(nil, 'return', false);
  Check(LArrayNode.ParamString['0'] = 'hello');
  Check(LArrayNode.ParamString['1'] = 'goodbye');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoFloat;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoFloat.xml');
  Check(FReader.BaseNode.ParamSingle['inputFloat'] = 5.5);
  Check(FReader.BaseNode.ParamDouble['inputFloat'] = 5.5);
  Check(FReader.BaseNode.ParamExtended['inputFloat'] = 5.5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoFloatResponse;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoFloatResponse.xml');
  Check(FReader.BaseNode.ParamSingle['return'] = 5.5);
  Check(FReader.BaseNode.ParamDouble['return'] = 5.5);
  Check(FReader.BaseNode.ParamExtended['return'] = 5.5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoFloatArray;
var
  LArrayNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoFloatArray.xml');
  LArrayNode := FReader.GetArray(nil, 'inputFloatArray', false);
  Check(FloatEquals(LArrayNode.ParamDouble['0'], 5.2), 'Value "'+FloatToStrF(LArrayNode.ParamDouble['0'], ffGeneral, 8, 16)+'" instead of "5.2"');
  Check(FloatEquals(LArrayNode.ParamDouble['1'], 6.2), 'Value "'+FloatToStrF(LArrayNode.ParamDouble['0'], ffGeneral, 8, 16)+'" instead of "5.2"');
  Check(FloatEquals(LArrayNode.ParamDouble['2'], -1.3), 'Value "'+FloatToStrF(LArrayNode.ParamDouble['0'], ffGeneral, 8, 16)+'" instead of "5.2"');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoFloatArrayResponse;
var
  LArrayNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoFloatArrayResponse.xml');
  LArrayNode := FReader.GetArray(nil, 'return', false);
  Check(FloatEquals(LArrayNode.ParamDouble['0'], 5.2), 'Value "'+FloatToStrF(LArrayNode.ParamDouble['0'], ffGeneral, 8, 16)+'" instead of "5.2"');
  Check(FloatEquals(LArrayNode.ParamDouble['1'], 6.2), 'Value "'+FloatToStrF(LArrayNode.ParamDouble['0'], ffGeneral, 8, 16)+'" instead of "5.2"');
  Check(FloatEquals(LArrayNode.ParamDouble['2'], -1.3), 'Value "'+FloatToStrF(LArrayNode.ParamDouble['0'], ffGeneral, 8, 16)+'" instead of "5.2"');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoInteger;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoInteger.xml');
  Check(FReader.BaseNode.ParamInteger['inputInteger'] = 5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoIntegerResponse;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoIntegerResponse.xml');
  Check(FReader.BaseNode.ParamInteger['return'] = 5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoIntegerArray;
var
  LArrayNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoIntegerArray.xml');
  LArrayNode := FReader.GetArray(nil, 'inputIntegerArray', false);
  Check(LArrayNode.ParamInteger['0'] = -1);
  Check(LArrayNode.ParamInteger['1'] = 0);
  Check(LArrayNode.ParamInteger['2'] = 1);
  Check(LArrayNode.ParamInteger['3'] = 2);
  Check(LArrayNode.ParamInteger['4'] = 3);
  Check(LArrayNode.ParamInteger['5'] = 4);
  Check(LArrayNode.ParamInteger['6'] = 5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoIntegerArrayResponse;
var
  LArrayNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoIntegerArrayResponse.xml');
  LArrayNode := FReader.GetArray(nil, 'return', false);
  Check(LArrayNode.ParamInteger['0'] = -1);
  Check(LArrayNode.ParamInteger['1'] = 0);
  Check(LArrayNode.ParamInteger['2'] = 1);
  Check(LArrayNode.ParamInteger['3'] = 2);
  Check(LArrayNode.ParamInteger['4'] = 3);
  Check(LArrayNode.ParamInteger['5'] = 4);
  Check(LArrayNode.ParamInteger['6'] = 5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoVoid;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoVoid.xml');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoVoidResponse;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoVoidResponse.xml');
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoStruct;
var
  LStructNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStruct.xml');
  LStructNode := FReader.GetStruct(nil, 'inputStruct', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 6.2));
  Check(LStructNode.ParamString['varString'] = 'test string');
  Check(LStructNode.ParamInteger['varInt'] = 5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoStructResponse;
var
  LStructNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStructResponse.xml');
  LStructNode := FReader.GetStruct(nil, 'return', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 6.2));
  Check(LStructNode.ParamString['varString'] = 'test string');
  Check(LStructNode.ParamInteger['varInt'] = 5);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoStructResponseKafka;
var
  LStructNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStructResponseKafka.xml');
  LStructNode := FReader.GetStruct(nil, 'param', 'SOAPStruct', 'http://soapinterop.org/', false);
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 3.5));
  Check(LStructNode.ParamString['varString'] = 'test s 1');
  Check(LStructNode.ParamInteger['varInt'] = 23452);
  ExpectedException := EIdSoapRequirementFail;
  FReader.GetStruct(nil, 'param', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoStructArray;
var
  LArrayNode : TIdSoapNode;
  LStructNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStructArray.xml');
  LArraynode := FReader.GetArray(nil, 'inputStructArray', false);
  LStructNode := FReader.GetStruct(LArrayNode, '0', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 6.2));
  Check(LStructNode.ParamString['varString'] = 'test string');
  Check(LStructNode.ParamInteger['varInt'] = 5);
  LStructNode := FReader.GetStruct(LArrayNode, '1', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 12.4));
  Check(LStructNode.ParamString['varString'] = 'another test');
  Check(LStructNode.ParamInteger['varInt'] = 10);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SoapBuilder_echoStructArrayResponse;
var
  LArrayNode : TIdSoapNode;
  LStructNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echoStructArrayResponse.xml');
  LArraynode := FReader.GetArray(nil, 'return', false);
  LStructNode := FReader.GetStruct(LArrayNode, '0', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 6.2));
  Check(LStructNode.ParamString['varString'] = 'test string');
  Check(LStructNode.ParamInteger['varInt'] = 5);
  LStructNode := FReader.GetStruct(LArrayNode, '1', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 12.4));
  Check(LStructNode.ParamString['varString'] = 'another test');
  Check(LStructNode.ParamInteger['varInt'] = 10);
end;


procedure TIdSoapCompatibilitySoapBuilders.Test_SB2_Glue_Struct;
var
  LStructNode : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'Glue_Struct.xml');
  LStructNode := FReader.GetStruct(nil, 'result', 'SOAPStruct', 'http://soapinterop.org/xsd', false);
  LStructNode := LStructNode.Reference;
  Check(LStructNode.ParamString['varString'] = 'test s 1');
  Check(FloatEquals(LStructNode.ParamDouble['varFloat'], 3.5));
  Check(LStructNode.ParamInteger['varInt'] = 23452);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SB2_Glue_2DArray;
var
  LArr1 : TIdSoapNode;
  LArr2 : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echo2DArray2.xml');
  LArr1 := FReader.GetArray(nil, 'Result', false);
  Check(LArr1.Children.count = 3);
  Check(LArr1.Params.count = 0);
  LArr2 := FReader.GetArray(LArr1, '0', false);
  Check(LArr2.Children.count = 0);
  Check(LArr2.Params.count = 4);
  LArr2 := FReader.GetArray(LArr1, '1', false);
  Check(LArr2.Children.count = 0);
  Check(LArr2.Params.count = 4);
  LArr2 := FReader.GetArray(LArr1, '2', false);
  Check(LArr2.Children.count = 0);
  Check(LArr2.Params.count = 4);
end;

procedure TIdSoapCompatibilitySoapBuilders.Test_SB2_EasySoap_2DArray;
var
  LArr1 : TIdSoapNode;
  LArr2 : TIdSoapNode;
begin
  ReadFile('SoapBuilders'+PathDelim+'echo2DArray1.xml');
  LArr1 := FReader.GetArray(nil, 'return', false);
  Check(LArr1.Children.count = 3);
  Check(LArr1.Params.count = 0);
  LArr2 := FReader.GetArray(LArr1, '0', false);
  Check(LArr2.Children.count = 0);
  Check(LArr2.Params.count = 4);
  LArr2 := FReader.GetArray(LArr1, '1', false);
  Check(LArr2.Children.count = 0);
  Check(LArr2.Params.count = 4);
  LArr2 := FReader.GetArray(LArr1, '2', false);
  Check(LArr2.Children.count = 0);
  Check(LArr2.Params.count = 4);
end;


{ TIdSoapCompatibilityDocLit }

procedure TIdSoapCompatibilityDocLit.Test_Read_LookyBookResponse;
var
  LStructNode : TIdSoapNode;
  LArrayNode : TIdSoapNode;
begin
  FReader.EncodingMode := semDocument;
  ReadFile('SoapSamples'+PathDelim+'LookyBookResponse.xml');
  LStructNode := FReader.GetStruct(nil, 'GetInfoResult', '', '', false);
  Check(LStructNode.ParamString['isbn'] = '0060652942');
  Check(LStructNode.ParamString['title'] = 'The Abolition of Man');
  Check(LStructNode.ParamString['author'] = 'C. S. Lewis');
  Check(LStructNode.ParamString['pubdate'] = 'March 2001');
  Check(LStructNode.ParamString['publisher'] = 'Harper San Francisco');
  Check(LStructNode.ParamString['imgUrl'] = 'http://images.barnesandnoble.com/images/5400000/5400321.gif');
  Check(LStructNode.ParamString['timestamp'] = '22.08.2002 05:38:30');
  LArraynode := FReader.GetArray(LStructNode, 'vendorprice', false);
  LStructNode := FReader.GetStruct(LArraynode, '0', '', '', false);
  Check(LStructNode.ParamString['name'] = 'Barnes & Noble');
  Check(LStructNode.ParamString['siteUrl'] = 'http://service.bfast.com/bfast/click?bfmid=2181&sourceid=35831040&bfpid=0060652942');
  Check(LStructNode.ParamString['pricePrefix'] = '$');
  Check(LStructNode.ParamString['price'] = '8.00');
  LStructNode := FReader.GetStruct(LArraynode, '2', '', '', false);
  Check(LStructNode.ParamString['name'] = 'Bookshop.co.uk');
  Check(LStructNode.ParamString['siteUrl'] = 'http://www.bookshop.co.uk/ser/serdsp.asp?isbn=0060652942');

  // note that this sequence shows that the file has been worked over once too often, as it's double UTF-8 encoded
  // it's not clear how this came about
  Check(LStructNode.ParamString['pricePrefix'] = GetTargetStr(chr($A3)));
  Check(LStructNode.ParamString['price'] = '[unavailable]');
end;

{ TIdSoapPacketXML8DefaultTests }

procedure TIdSoapPacketXML8DefaultTests.SetReaderOptions(AReader: TIdSoapReader);
begin
  AReader.EncodingMode := semRPC;
end;

procedure TIdSoapPacketXML8DefaultTests.SetWriterOptions(AWriter: TIdSoapWriter);
begin
  AWriter.EncodingMode := semRPC;
end;

{ TIdSoapPacketXML8DocumentTests }

procedure TIdSoapPacketXML8DocumentTests.SetReaderOptions(AReader: TIdSoapReader);
begin
  AReader.EncodingMode := semDocument;
end;

procedure TIdSoapPacketXML8DocumentTests.SetWriterOptions(AWriter: TIdSoapWriter);
begin
  AWriter.EncodingMode := semDocument;
end;

{ TIdSoapDIMETests }

procedure TIdSoapDIMETests.TestDime;
var
  LMem1 : TIdMemoryStream;
  LMem2 : TIdMemoryStream;
  LMem3 : TIdMemoryStream;
  LDime : TIdSoapDimeMessage;
  LRec  : TIdSoapDimeRecord;
  LMsg : string;
begin
  LMem1 := TIdMemoryStream.create;
  LMem2 := TIdMemoryStream.create;
  LMem3 := TIdMemoryStream.create;
  try
    FillTestingStream(LMem1, 10000);
    FillTestingStream(LMem2, 200);

    LDime := TIdSoapDimeMessage.create;
    try
      LRec := LDime.Add('1');
      LRec.TypeType := dtMime;
      LRec.TypeInfo := 'text/plain';
      LRec.Content.CopyFrom(LMem1, 0);
      LRec := LDime.Add('part 2');
      LRec.TypeType := dtURI;
      LRec.TypeInfo := 'http://tempuri.org/test';
      LRec.Content.CopyFrom(LMem2, 0);
      LDime.WriteToStream(LMem3);
    finally
      FreeAndNil(LDime);
    end;
    LMem1.Position := 0;
    LMem2.Position := 0;
    LMem3.Position := 0;
    LDime := TIdSoapDimeMessage.create;
    try
      LDime.ReadFromStream(LMem3);
      check(LDime.RecordCount = 2);
      LRec := LDime.Item[0];
      Check(LRec.TestValid);
      Check(LRec.TypeType = dtMime);
      Check(LRec.TypeInfo = 'text/plain');
      Check(LRec.Id = '1');
      if not TestStreamsIdentical(LMem1, LRec.Content, LMsg) then
        begin
        Check(false, LMsg);
        end;
      LRec := LDime.Item[1];
      Check(LRec.TestValid);
      Check(LRec.TypeType = dtURI);
      Check(LRec.TypeInfo = 'http://tempuri.org/test');
      Check(LRec.Id = 'part 2');
      if not TestStreamsIdentical(LMem2, LRec.Content, LMsg) then
        begin
        Check(false, LMsg);
        end;
      Check(LDime.ItemByName['part 2'] = LRec);
      Check(LDime.ItemByName['1'] <> nil);
      Check(LDime.ItemByName['p1'] = nil);
    finally
      FreeAndNil(LDime);
    end;
  finally
    FreeAndNil(LMem1);
    FreeAndNil(LMem2);
    FreeAndNil(LMem3);
  end;
end;

procedure TIdSoapDIMETests.TestEmptyDime1;
var
  LMem3 : TIdMemoryStream;
  LDime : TIdSoapDimeMessage;
begin
  LMem3 := TIdMemoryStream.create;
  try
    LDime := TIdSoapDimeMessage.create;
    try
      LDime.WriteToStream(LMem3);
    finally
      FreeAndNil(LDime);
    end;
    LMem3.Position := 0;
    LDime := TIdSoapDimeMessage.create;
    try
      LDime.ReadFromStream(LMem3);
      check(LDime.RecordCount = 0);
    finally
      FreeAndNil(LDime);
    end;
  finally
    FreeAndNil(LMem3);
  end;
end;

procedure TIdSoapDIMETests.TestEmptyDime2;
var
  LMem1 : TIdMemoryStream;
  LMem2 : TIdMemoryStream;
  LMem3 : TIdMemoryStream;
  LDime : TIdSoapDimeMessage;
  LRec  : TIdSoapDimeRecord;
  LMsg : string;
begin
  LMem1 := TIdMemoryStream.create;
  LMem2 := TIdMemoryStream.create;
  LMem3 := TIdMemoryStream.create;
  try
    LDime := TIdSoapDimeMessage.create;
    try
      LRec := LDime.Add('1');
      LRec.TypeType := dtMime;
      LRec.TypeInfo := '';
      LRec.Content.CopyFrom(LMem1, 0);
      LRec := LDime.Add('part 2');
      LRec.TypeType := dtURI;
      LRec.TypeInfo := 'http://tempuri.org/test';
      LRec.Content.CopyFrom(LMem2, 0);
      LDime.WriteToStream(LMem3);
    finally
      FreeAndNil(LDime);
    end;
    LMem1.Position := 0;
    LMem2.Position := 0;
    LMem3.Position := 0;
    LDime := TIdSoapDimeMessage.create;
    try
      LDime.ReadFromStream(LMem3);
      check(LDime.RecordCount = 2);
      LRec := LDime.Item[0];
      Check(LRec.TestValid);
      Check(LRec.TypeType = dtMime);
      Check(LRec.TypeInfo = '');
      Check(LRec.Id = '1');
      if not TestStreamsIdentical(LMem1, LRec.Content, LMsg) then
        begin
        Check(false, LMsg);
        end;
      LRec := LDime.Item[1];
      Check(LRec.TestValid);
      Check(LRec.TypeType = dtURI);
      Check(LRec.TypeInfo = 'http://tempuri.org/test');
      Check(LRec.Id = 'part 2');
      if not TestStreamsIdentical(LMem2, LRec.Content, LMsg) then
        begin
        Check(false, LMsg);
        end;
      Check(LDime.ItemByName['part 2'] = LRec);
      Check(LDime.ItemByName['1'] <> nil);
      Check(LDime.ItemByName['p1'] = nil);
    finally
      FreeAndNil(LDime);
    end;
  finally
    FreeAndNil(LMem1);
    FreeAndNil(LMem2);
    FreeAndNil(LMem3);
  end;
end;

procedure TIdSoapDIMETests.TestChunkedDime;
var
  LMem1 : TIdMemoryStream;
  LMem2 : TIdMemoryStream;
  LMem3 : TIdMemoryStream;
  LDime : TIdSoapDimeMessage;
  LRec  : TIdSoapDimeRecord;
  LMsg : string;
begin
  LMem1 := TIdMemoryStream.create;
  LMem2 := TIdMemoryStream.create;
  LMem3 := TIdMemoryStream.create;
  try
    FillTestingStream(LMem1, 10000);
    FillTestingStream(LMem1, 200);

    LDime := TIdSoapDimeMessage.create;
    try
      LRec := LDime.Add('1');
      LRec.TypeType := dtMime;
      LRec.TypeInfo := 'text/plain';
      LRec.Content.CopyFrom(LMem1, 0);
      LRec.ChunkSize := 512;
      LRec := LDime.Add('part 2');
      LRec.TypeType := dtURI;
      LRec.TypeInfo := 'http://tempuri.org/test';
      LRec.Content.CopyFrom(LMem2, 0);
      LRec.ChunkSize := 64;
      LDime.WriteToStream(LMem3);
    finally
      FreeAndNil(LDime);
    end;
    LMem1.Position := 0;
    LMem2.Position := 0;
    LMem3.Position := 0;
    LDime := TIdSoapDimeMessage.create;
    try
      LDime.ReadFromStream(LMem3);
      check(LDime.RecordCount = 2);
      LRec := LDime.Item[0];
      Check(LRec.TestValid);
      Check(LRec.TypeType = dtMime);
      Check(LRec.TypeInfo = 'text/plain');
      Check(LRec.Id = '1');
      if not TestStreamsIdentical(LMem1, LRec.Content, LMsg) then
        begin
        Check(false, LMsg);
        end;
      LRec := LDime.Item[1];
      Check(LRec.TestValid);
      Check(LRec.TypeType = dtURI);
      Check(LRec.TypeInfo = 'http://tempuri.org/test');
      Check(LRec.Id = 'part 2');
      if not TestStreamsIdentical(LMem2, LRec.Content, LMsg) then
        begin
        Check(false, LMsg);
        end;
      Check(LDime.ItemByName['part 2'] = LRec);
      Check(LDime.ItemByName['1'] <> nil);
      Check(LDime.ItemByName['p1'] = nil);
    finally
      FreeAndNil(LDime);
    end;
  finally
    FreeAndNil(LMem1);
    FreeAndNil(LMem2);
    FreeAndNil(LMem3);
  end;
end;

procedure TIdSoapDIMETests.TestDIMEExample;
var
  LDime : TIdSoapDimeMessage;
  LRec : TIdSoapDimeRecord;
  LFile : TFileStream;
begin
  // example DIME packet kindly provided by Bub Cummings from Whitemesa.com
  LDime := TIdSoapDimeMessage.create;
  try
    LFile := TFileStream.create('Dime/Test.dime', fmOpenRead or fmShareDenyWrite);
    try
      LDime.ReadFromStream(LFile);
    finally
      FreeAndNil(LFile);
    end;
    Check(LDime.RecordCount = 1);
    LRec := LDime.Item[0];
    Check(LRec.Id = '');
    Check(LRec.TypeType = dtMime);
    Check(LRec.TypeInfo = 'text/html');
    Check(LRec.Content.Size = 6078);
  finally
    FreeAndNil(LDime);
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_Attachment;
var
  LStream : TMemoryStream;
  LAtt : TIdSoapAttachment;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LStream := TIdMemoryStream.create;
  try
    FillTestingStream(LStream, 2000);
    FWriter.SetMessageName('TestProc', 'urn:test');
    LAtt := FWriter.Attachments.Add('Test');
    LAtt.MimeType := 'application/octet-stream';
    LAtt.Content.CopyFrom(LStream, 0);
    LAtt.Content.Position := 0;
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    Check(FReader.Attachments.count = 1);
    LAtt := FReader.Attachments.Attachment['Test'];
    Check(LAtt.Id = 'Test');
    Check(LAtt.MimeType = 'application/octet-stream');
    LStream.Position := 0;
    LOK := TestStreamsIdentical(LStream, LAtt.Content, LMsg);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_2Attachments;
var
  LStream1 : TMemoryStream;
  LStream2 : TMemoryStream;
  LAtt : TIdSoapAttachment;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LStream1 := TIdMemoryStream.create;
  LStream2 := TIdMemoryStream.create;
  try
    FillTestingStream(LStream1, 2000);
    FillTestingStream(LStream2, 40000);
    FWriter.SetMessageName('TestProc', 'urn:test');
    LAtt := FWriter.Attachments.Add('Test1');
    LAtt.MimeType := 'application/octet-stream';
    LAtt.Content.CopyFrom(LStream1, 0);
    LAtt := FWriter.Attachments.Add('', false);
    LAtt.URIType := 'asdasd';
    LAtt.Content.CopyFrom(LStream2, 0);
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    Check(FReader.Attachments.count = 2);
    LAtt := FReader.Attachments.Attachment['Test1'];
    Check(LAtt.Id = 'Test1');
    Check(LAtt.MimeType = 'application/octet-stream');
    LStream1.Position := 0;
    LOK := TestStreamsIdentical(LStream1, LAtt.Content, LMsg);
    Check(LOK, LMsg);
    LAtt := FReader.Attachments.AttachmentByIndex[1];
    Check(LAtt.Id = '');
    Check(LAtt.URIType = 'asdasd');
    LStream2.Position := 0;
    LOK := TestStreamsIdentical(LStream2, LAtt.Content, LMsg);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LStream1);
    FreeAndNil(LStream2);
  end;
end;

procedure TIdSoapPacketBaseTests.Test_IdSoap_AttachmentEmpty;
var
  LStream : TMemoryStream;
  LAtt : TIdSoapAttachment;
  LMsg : string;
  LOK : boolean;
  LMimeType : string;
begin
  LStream := TIdMemoryStream.create;
  try
    FWriter.SetMessageName('TestProc', 'urn:test');
    LAtt := FWriter.Attachments.Add('Test');
    LAtt.MimeType := 'application/octet-stream';
    LAtt.Content.CopyFrom(LStream, 0);
    FWriter.Encode(FStream, LMimeType, nil, nil);
    FStream.Position := 0;
    FReader.ReadMessage(FStream, LMimeType, nil, nil);
    FReader.checkpacketOK;
    FReader.ProcessHeaders;
    FReader.DecodeMessage;
    Check(FReader.Attachments.count = 1);
    LAtt := FReader.Attachments.Attachment['Test'];
    Check(LAtt.Id = 'Test');
    Check(LAtt.MimeType = 'application/octet-stream');
    LStream.Position := 0;
    LOK := TestStreamsIdentical(LStream, LAtt.Content, LMsg);
    Check(LOK, LMsg);
  finally
    FreeAndNil(LStream);
  end;
end;

{$IFDEF USE_MSXML}
{ TIdSoapPacketMsXml8Tests }

function TIdSoapPacketMsXml8Tests.CreateFault: TIdSoapFaultWriter;
begin
  result := TIdSoapFaultWriterXML.create(IdSoapV1_1, xpMsXml);
  (result as TIdSoapFaultWriterXML).UseUTF16 := false;
end;

function TIdSoapPacketMsXml8Tests.CreateReader: TIdSoapReader;
begin
  result := TIdSoapReaderXML.create(IdSoapV1_1, xpMsXml);
end;

function TIdSoapPacketMsXml8Tests.CreateWriter: TIdSoapWriter;
begin
  result := TIdSoapWriterXML.create(IdSoapV1_1, xpCustom);
  (result as TIdSoapWriterXML).UseUTF16 := false;
end;

{ TIdSoapPacketMsXml16BinTests }

function TIdSoapPacketMsXml16Tests.CreateFault: TIdSoapFaultWriter;
begin
  result := TIdSoapFaultWriterXML.create(IdSoapV1_1, xpMsXml);
  (result as TIdSoapFaultWriterXML).UseUTF16 := true;
end;

function TIdSoapPacketMsXml16Tests.CreateReader: TIdSoapReader;
begin
  result := TIdSoapReaderXML.create(IdSoapV1_1, xpMsXml);
end;

function TIdSoapPacketMsXml16Tests.CreateWriter: TIdSoapWriter;
begin
  result := TIdSoapWriterXML.create(IdSoapV1_1, xpMsXml);
  (result as TIdSoapWriterXML).UseUTF16 := true;
end;
{$ENDIF}

{ TIdSoapDecoderSetupOpenXML }

procedure TIdSoapDecoderSetupOpenXML.Setup;
begin
  GXmlProvider := xpOpenXML;
end;

{$IFDEF USE_MSXML}
{ TIdSoapDecoderSetupMSXML }

procedure TIdSoapDecoderSetupMSXML.Setup;
begin
  GXmlProvider := xpMsXml;
end;
{$ENDIF}

{ TIdSoapPacketCustom8Tests }

function TIdSoapPacketCustom8Tests.CreateFault: TIdSoapFaultWriter;
begin
  result := TIdSoapFaultWriterXML.create(IdSoapV1_1, xpCustom);
  (result as TIdSoapFaultWriterXML).UseUTF16 := false;
end;

function TIdSoapPacketCustom8Tests.CreateReader: TIdSoapReader;
begin
  result := TIdSoapReaderXML.create(IdSoapV1_1, xpCustom);
end;

function TIdSoapPacketCustom8Tests.CreateWriter: TIdSoapWriter;
begin
{$IFDEF USE_MSXML}
  result := TIdSoapWriterXML.create(IdSoapV1_1, xpMsXml);
{$ELSE}
  result := TIdSoapWriterXML.create(IdSoapV1_1, xpOpenXml);
{$ENDIF}
  (result as TIdSoapWriterXML).UseUTF16 := false;
end;

{ TIdSoapCompatibilityMisc }

procedure TIdSoapCompatibilityMisc.Test_Read_MapPointBase64;
var
  LNode : TIdSoapNode;
  LStr1 : TStream;
  LStr2 : TStream;
  LOk : boolean;
  LMsg : String;
begin
  FReader.EncodingOptions := [];
  ReadFile('SoapSamples'+PathDelim+'mappoint.xml');
  LNode := FReader.GetNodeNoClassnameCheck(nil, 'GetMapResult');
  LNode := FReader.GetNodeNoClassnameCheck(LNode, 'MapImage');
  LNode := FReader.GetNodeNoClassnameCheck(LNode, 'MimeData');
  LStr1 := FReader.ParamBinaryBase64[LNode, 'Bits'];
  try
    LStr2 := TFileStream.create('SoapSamples'+PathDelim+'mappoint.gif', fmOpenRead or fmShareDenyWrite);
    try
      LOK := TestStreamsIdentical(LStr1, LStr2, LMsg);
      Check(LOK, LMsg);
    finally
      FreeAndNil(LStr2);
    end;
  finally
    FreeAndNil(LStr1);
  end;
end;

{ TIdSoapDecoderSetupCustom }

procedure TIdSoapDecoderSetupCustom.Setup;
begin
  GXmlProvider := xpCustom;
end;

{ TIdSoapXMLTests }

procedure TIdSoapXMLTests.LoadFile(AFile: String);
var
  LFile : TFileStream;
begin
  CreateDOM;
  LFile := TFileStream.create(AFile, fmOpenRead or fmShareDenyWrite);
  try
    FDom.Read(LFile);
  finally
    FreeAndNil(LFile);
  end;
end;

procedure TIdSoapXMLTests.TearDown;
begin
  FreeAndNil(FDom);
end;

procedure TIdSoapXMLTests.TestEuroISO8859;
begin
  LoadFile('XMLSamples'+PathDelim+'euro_iso8859.xml');
  check(FDom.Root.FindElementAnyNS('TDPDECurrency').FindElementAnyNS('symbol').TextContentA = GetTargetStr(char(163)));
end;

procedure TIdSoapXMLTests.TestEuroUTF8;
begin
  LoadFile('XMLSamples'+PathDelim+'euro_utf8.xml');
  check(FDom.Root.FindElementAnyNS('TDPDECurrency').FindElementAnyNS('symbol').TextContentA = GetTargetStr(char(163)));
end;

{ TIdSoapXMLOpenXMLTests }

procedure TIdSoapXMLOpenXMLTests.CreateDOM;
begin
  FDom := IdSoapDomFactory(xpOpenXML);
end;

{$IFDEF USE_MSXML}
{ TIdSoapXMLMsXMLTests }

procedure TIdSoapXMLMsXMLTests.CreateDOM;
begin
  FDom := IdSoapDomFactory(xpMsXML);
end;
{$ENDIF}

{ TIdSoapXMLCustomTests }

procedure TIdSoapXMLCustomTests.CreateDOM;
begin
  FDom := IdSoapDomFactory(xpCustom);
end;

initialization
  IdRegisterException(ETestingExceptionClass);
  IdSoapRegisterType(TypeInfo(TEncodingTestClass));
  IdSoapRegisterType(TypeInfo(TEncodingTestClass), 'Order');
end.


