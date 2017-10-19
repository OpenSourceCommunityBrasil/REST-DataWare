{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16445: IdSoapTestsRegistration.pas 
{
{   Rev 1.4    20/6/2003 00:01:40  GGrieve
{ compile fixes
}
{
{   Rev 1.3    19/6/2003 21:36:40  GGrieve
{ Version #1
}
{
{   Rev 1.2    21/3/2003 11:43:40  GGrieve
}
{
{   Rev 1.1    18/3/2003 11:16:24  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:29:44  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  Custom XML provider, MSXML not tested when not supported
  21-Mar 2003   Grahame Grieve                  Add TIdSoapHashTable tests
  18-Mar 2003   Grahame Grieve                  Kylix compile fixes
  09-Oct 2002   Andrew Cumming                  Added tests for inherited interfaces
  04-Oct 2002   Grahame Grieve                  Add Dime, 2Way tests
  26-Sep 2002   Grahame Grieve                  Sessional Testing
  17-Sep 2002   Grahame Grieve                  SoapBuilders2 Tests
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Aug 2002   Grahame Grieve                  D4 Compiler fixes
  26-Aug 2002   Grahame Grieve                  Fix for various SoapBuilder problems
  23-Aug 2002   Grahame Grieve                  Doc|Lit testing
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Add Tests for renaming names and types
  17-Aug 2002   Grahame Grieve                  clean out soapbuilders tests
  15 Aug 2002   Grahame Grieve                  More SoapBuilders tests
  13 Aug 2002   Grahame Grieve                  Add SoapBuilders tests
  06-Aug 2002   Grahame Grieve                  Add One/Way + EMail tests
  24-Jul 2002   Grahame Grieve                  Reorganise WSDL tests, add Google tests
  29-May 2002   Grahame Grieve                  Added WSDL tests
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  05-Apr 2002   Grahame Grieve                  RTTI tests added
  02-Apr 2002   Grahame Grieve                  Date Time Tests added
  29-Mar 2002   Grahame Grieve                  Add TIdBaseSoapableClass tests
  26-Mar 2002   Grahame Grieve                  Clean up RTTI tests IFDEFs and add Standard tests
  15-Mar 2002   Grahame Grieve                  Add Comms Tests
  12-Mar 2002   Grahame Grieve                  Added Indy Tests
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
}

{
Test Structure
   Encoding/Decoding
   Communications
   Functional Tests

}

unit IdSoapTestsRegistration;

{$I IdSoapDefines.inc}

interface

uses
  TestExtensions,
  TestFramework;

// you can use this procedure to register the Indy Soap
// tests in other DUnit test suites. All you need to do
// is ensure that the /soap/dunit directory (whereever
// you have it) is the current directory when this routine
// is executed, and when the test structure returned executes

// these tests use global type registries, so you may need to
// be a little careful of interactions between these tests
// and your tests

procedure IdSoapRegisterTests(AParent : TTestSuite);

implementation

uses
  IdSoapBuildersTests,
  IdSoapBuildersTests2,
  IdSoapCommsTests,
  IdSoapDateTimeTests,
  IdSoapDebugTests,
  IdSoapEndToEnd_1_Tests,
  IdSoapIndyTests,
  IdSoapInterfaceTests,
  IdSoapMessagingTests,
  IdSoapInterfaceTestsServer,
  IdSoapRenamingTests,
  IdSoapIntfRegistryTests,
  IdSoapITIBinXMLTests,
  IdSoapITIParserTests,
  IdSoapITIProviderTests,
  IdSoapITIRttiTests,
  IdSoapITITests,
  IdSoapRpcXmlTests,
  IdSoapRTTITests,
  {$IFNDEF LINUX}
  {$IFDEF VCL5ORABOVE}
  IdSoapTestSettings,
  {$ENDIF}
  {$ENDIF}
  IDSoapTypeRegistryTests,
  IdSoapUtilities,
  IdSoapUtilitiesTest,
  IdSoapWsdlTests,
  IdSoapLowLevelInterfaceTests,
  IniFiles,
  SysUtils;

function BuildGroup(AName:String; AClasses : array of TTestCaseClass):TTestSuite;
var
  i : integer;
begin
  result := TTestSuite.create(AName);
  for i := Low(AClasses) to High(AClasses) do
    result.AddTests(AClasses[i]);
end;

function InfrastuctureTests:TTestSuite;
begin
  result := TTestSuite.create('Infrastructure');
  result.AddSuite(BuildGroup('Debugging', [TDebugTestCases]));
  result.AddSuite(BuildGroup('TIdStringList', [TTestIdStringList]));
  result.AddSuite(BuildGroup('TIdCriticalSection', [TTestIdCriticalSection]));
  result.AddSuite(BuildGroup('TIdHashTable', [TTestHashTable]));
  result.AddSuite(BuildGroup('Utilities', [TTestProcedures]));
  result.AddSuite(BuildGroup('Base64 Tests', [TIndyBase64Tests]));
end;

function SoapTypeTests:TTestSuite;
begin
  result := TTestSuite.create('Soap Types');
  result.AddSuite(BuildGroup('TIdBaseSoapableClass Tests', [TIdBaseSoapableClassTestCases]));
  result.AddSuite(BuildGroup('TIdSoapDateTime Tests', [TIdSoapDateTimeTests]));
end;

function TypeRegistrationTests:TTestSuite;
begin
  result := TTestSuite.create('Type Registration');
  result.AddSuite(BuildGroup('Type Registry', [TTypeRegistryTestCases]));
  result.AddSuite(BuildGroup('Exception Registry', [TExceptionRegistryTestCases]));
  result.AddSuite(BuildGroup('Interface Registry', [TIntfNameRegistryTestCases]));
  result.AddSuite(BuildGroup('Server Interface Registry', [TIntfRegistryTestCases]));
  result.AddSuite(BuildGroup('RTTI Helper', [TIdSoapRTTITests]));
end;

function ITITests:TTestSuite;
var
  LTemp : TTestSuite;
begin
  result := TTestSuite.create('ITI + Management');
  LTemp := TTestSuite.create('Base ITI Tests');
  result.AddSuite(LTemp);
  LTemp.AddSuite(BuildGroup('Parameter', [TITIParameterTestCases]));
  LTemp.AddSuite(BuildGroup('Method', [TITIMethodTestCases]));
  LTemp.AddSuite(BuildGroup('interface', [TITIInterfaceTestCases]));
  LTemp.AddSuite(BuildGroup('ITI', [TITITestCases]));

  result.AddSuite(BuildGroup('ITI Streaming', [TITIStreamCase]));
  result.AddSuite(BuildGroup('ITI Parsing', [TITIParserTestCases]));
  {$IFDEF VER140ENTERPRISE}
  result.AddSuite(BuildGroup('ITI from RTTI', [TRTTIToITITestCases]));
  {$ENDIF}
  result.AddSuite(BuildGroup('ITI Provider', [TITIProviderCase]));
end;


function EncodingTests:TTestSuite;
var
  LTemp : TTestSuite;
  LSetup : TTestSetup;
begin
  result := TTestSuite.create('Encoding / Decoding');

  LTemp := TTestSuite.create('XML tests');
  result.AddSuite(LTemp);
  LTemp.AddSuite(BuildGroup('OpenXML', [TIdSoapXMLOpenXMLTests]));
  {$IFDEF USE_MSXML}
  LTemp.AddSuite(BuildGroup('MsXML', [TIdSoapXMLMsXMLTests]));
  {$ENDIF}
  LTemp.AddSuite(BuildGroup('Custom', [TIdSoapXMLCustomTests]));

  LTemp := TTestSuite.create('Self Tests - OpenXML');
  result.AddSuite(LTemp);
  LTemp.AddSuite(BuildGroup('Dime', [TIdSoapDIMETests]));
  LTemp.AddSuite(BuildGroup('xml8', [TIdSoapPacketXML8DefaultTests]));
  LTemp.AddSuite(BuildGroup('xml8-Doc|Lit', [TIdSoapPacketXML8DocumentTests]));
  LTemp.AddSuite(BuildGroup('xml16', [TIdSoapPacketXML16Tests]));
  {$IFDEF USE_MSXML}
  LTemp.AddSuite(BuildGroup('MsXml', [TIdSoapPacketMsXml8Tests]));
  LTemp.AddSuite(BuildGroup('MsXml16', [TIdSoapPacketMsXml16Tests]));
  {$ENDIF}
  LTemp.AddSuite(BuildGroup('Custom8', [TIdSoapPacketCustom8Tests]));
  LTemp.AddSuite(BuildGroup('bin', [TIdSoapPacketBinTests]));

  LTemp := TTestSuite.create('Compatibility Tests - OpenXML');
  LSetup := TIdSoapDecoderSetupOpenXML.create(LTemp);
  result.AddTest(LSetup);
  LTemp.AddSuite(BuildGroup('General', [TIdSoapCompatibilityGeneral]));
  LTemp.AddSuite(BuildGroup('Standard', [TIdSoapCompatibilityStandard]));
  LTemp.AddSuite(BuildGroup('SoapBuilders', [TIdSoapCompatibilitySoapBuilders]));
  LTemp.AddSuite(BuildGroup('Borland', [TIdSoapCompatibilityBorland]));
  LTemp.AddSuite(BuildGroup('Google', [TIdSoapCompatibilityGoogle]));
  LTemp.AddSuite(BuildGroup('Doc|Lit', [TIdSoapCompatibilityDocLit]));
  LTemp.AddSuite(BuildGroup('Misc', [TIdSoapCompatibilityMisc]));

{$IFDEF USE_MSXML}
  LTemp := TTestSuite.create('Compatibility Tests - MSXML');
  LSetup := TIdSoapDecoderSetupMSXML.create(LTemp);
  result.AddTest(LSetup);
  LTemp.AddSuite(BuildGroup('General', [TIdSoapCompatibilityGeneral]));
  LTemp.AddSuite(BuildGroup('Standard', [TIdSoapCompatibilityStandard]));
  LTemp.AddSuite(BuildGroup('SoapBuilders', [TIdSoapCompatibilitySoapBuilders]));
  LTemp.AddSuite(BuildGroup('Borland', [TIdSoapCompatibilityBorland]));
  LTemp.AddSuite(BuildGroup('Google', [TIdSoapCompatibilityGoogle]));
  LTemp.AddSuite(BuildGroup('Doc|Lit', [TIdSoapCompatibilityDocLit]));
  LTemp.AddSuite(BuildGroup('Misc', [TIdSoapCompatibilityMisc]));
{$ENDIF}

  LTemp := TTestSuite.create('Compatibility Tests - Custom');
  LSetup := TIdSoapDecoderSetupCustom.create(LTemp);
  result.AddTest(LSetup);
  LTemp.AddSuite(BuildGroup('General', [TIdSoapCompatibilityGeneral]));
  LTemp.AddSuite(BuildGroup('Standard', [TIdSoapCompatibilityStandard]));
  LTemp.AddSuite(BuildGroup('SoapBuilders', [TIdSoapCompatibilitySoapBuilders]));
  LTemp.AddSuite(BuildGroup('Borland', [TIdSoapCompatibilityBorland]));
  LTemp.AddSuite(BuildGroup('Google', [TIdSoapCompatibilityGoogle]));
  LTemp.AddSuite(BuildGroup('Doc|Lit', [TIdSoapCompatibilityDocLit]));
  LTemp.AddSuite(BuildGroup('Misc', [TIdSoapCompatibilityMisc]));
end;

function CommsTests:TTestSuite;
begin
  result := TTestSuite.create('Communications');  result.AddSuite(BuildGroup('general', [TIdSoapCommsTests]));
  result.AddSuite(BuildGroup('http', [TIdSoapHTTPTests]));
  result.AddSuite(BuildGroup('tcpip', [TIdSoapTCPIPTests]));
  result.AddSuite(BuildGroup('Email', [TEmailMsgTestCases]));
  result.AddSuite(BuildGroup('TwoWay TCP/IP', [TIdSoapTwoWayTCPIPTests]));
  {$IFDEF MSWINDOWS}
  result.AddSuite(BuildGroup('WinInet', [TIdSoapWinInetTests]));
  {$ENDIF}
end;

function WSDLTests:TTestSuite;
begin
  result := TTestSuite.create('WSDL functionality');
  result.AddSuite(BuildGroup('WSDL', [TIdSoapWSDLTests]));
end;

function FunctionalTests:TTestSuite;
var
  LTemp : TTestSuite;
  LTemp2 : TTestSuite;
  LInterfaceTestsServerSetup : TIdSoapInterfaceTestsServerSetup;
  FIniFile : TIniFile;
begin
  result := TTestSuite.create('Functional Testing');

  LTemp := TTestSuite.create('Request/Response Tests');
  LTemp.AddSuite(BuildGroup('xml8', [TIdSoapInterfaceXML8Tests]));
{$IFDEF USE_MSXML}
  LTemp.AddSuite(BuildGroup('msxml', [TIdSoapInterfaceMsXMLTests]));
{$ENDIF}
  LTemp.AddSuite(BuildGroup('doc|lit', [TIdSoapInterfaceDocLitTests]));
  LTemp.AddSuite(BuildGroup('xml16', [TIdSoapInterfaceXML16Tests]));
  LTemp.AddSuite(BuildGroup('bin', [TIdSoapInterfaceBinTests]));
  LTemp.AddSuite(BuildGroup('misc', [TIdSoapMiscTests]));
  LTemp.AddSuite(BuildGroup('headers - xml', [TIdSoapHeaderTestsXML]));
  LTemp.AddSuite(BuildGroup('headers - bin', [TIdSoapHeaderTestsBIN]));
  LTemp.AddSuite(BuildGroup('sessions - cookies', [TIdSoapSessionTestsCookieIndy]));
// to be reenabled once cookie support in winnet is complete
//  LTemp.AddSuite(BuildGroup('sessions - cookies (ie)', [TIdSoapSessionTestsCookieWinInet]));
  LTemp.AddSuite(BuildGroup('sessions - soap', [TIdSoapSessionTestsSoapXML]));
  LTemp.AddSuite(BuildGroup('sessions - bin', [TIdSoapSessionTestsSoapBin]));

  LInterfaceTestsServerSetup := TIdSoapInterfaceTestsServerSetup.create(LTemp, 'Setup');
  result.AddTest(LInterfaceTestsServerSetup);

  LTemp := TTestSuite.create('One Way Tests');
  LTemp.AddSuite(BuildGroup('xml8', [TIdSoapMsgXML8Tests]));
  LTemp.AddSuite(BuildGroup('xml16', [TIdSoapMsgXML16Tests]));
  LTemp.AddSuite(BuildGroup('bin', [TIdSoapMsgBinTests]));
  result.AddSuite(LTemp);

  LTemp := TTestSuite.create('Original Tests');
  result.AddSuite(LTemp);

  LTemp2 := TTestSuite.create('HTTP');
  LTemp.AddSuite(LTemp2);
  LTemp2.AddSuite(BuildGroup('xml8', [TITIEndToEndHTTPXMl8Cases]));
  LTemp2.AddSuite(BuildGroup('xml16', [TITIEndToEndHTTPXML16Cases]));
  LTemp2.AddSuite(BuildGroup('bin', [TITIEndToEndHTTPBinCases]));

  LTemp2 := TTestSuite.create('TCP/IP');
  LTemp.AddSuite(LTemp2);
  LTemp2.AddSuite(BuildGroup('xml8', [TITIEndToEndTCPIPXMl8Cases]));
  LTemp2.AddSuite(BuildGroup('xml16', [TITIEndToEndTCPIPXML16Cases]));
  LTemp2.AddSuite(BuildGroup('bin', [TITIEndToEndTCPIPBinCases]));

  FIniFile := TIniFile.create('IdSoapTestSettings.ini');
  try
    if FIniFile.ReadBool('SoapBuilders', 'Use', true) then
     begin
     LTemp := TTestSuite.create('SoapBuilders (Live Internet)');
     result.AddSuite(LTemp);
     LTemp.AddTest(TIdSoapBuildersEasySoap.create(TIdSoapBuildersTests.Suite, 'EasySoap'));
     LTemp.AddTest(TIdSoapBuildersDolphin.create(TIdSoapShortBuildersTests.Suite, 'Dolphin'));
     LTemp.AddTest(TIdSoapBuildersIona.create(TIdSoapShortBuildersTests.Suite, 'Iona'));
     LTemp.AddTest(TIdSoapBuildersKafka.create(TIdSoapShortBuildersTests.Suite, 'Kafka'));
     LTemp.AddTest(TIdSoapBuildersMSSoap.create(TIdSoapBuildersTests.Suite, 'MSSoap'));
     LTemp.AddTest(TIdSoapBuildersMSNet.create(TIdSoapBuildersTests.Suite, 'MS.Net'));
     LTemp.AddTest(TIdSoapBuildersSoap4R.create(TIdSoapBuildersTests.Suite, 'Soap4R'));
     LTemp.AddTest(TIdSoapBuildersSoapLite.create(TIdSoapBuildersTests.Suite, 'SoapLite'));

     LTemp := TTestSuite.create('SoapBuilders 2');
     result.AddSuite(LTemp);

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'Apache Axis', 'http://nagoya.apache.org:5049/axis/services/echo', true, 'http://nagoya.apache.org:5049/axis/services/echo'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests]),
            'Apache SOAP 2.2', 'http://nagoya.apache.org:5049/soap/servlet/rpcrouter', true));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTestsShort]),
            'ASP.NET Web Services', 'http://www.mssoapinterop.org/asmx/simple.asmx', true, 'http://www.mssoapinterop.org/asmx/simpleB.asmx'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests]),
            'CapeConnect', 'http://interop.capeclear.com/ccx/soapbuilders-round2', true));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'Delphi SOAP', 'http://soap-server.borland.com/WebServices/Interop/cgi-bin/InteropService.exe/soap/InteropTestPortType', true, 'http://soap-server.borland.com/WebServices/Interop/cgi-bin/InteropGroupB.exe/soap/InteropTestPortTypeB'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'EasySoap++', 'http://easysoap.sourceforge.net/cgi-bin/interopserver', true, 'http://easysoap.sourceforge.net/cgi-bin/interopserver'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests]),
            'eSOAP', 'http://www.quakersoft.net/cgi-bin/interop2_server.cgi', true));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'gSOAP', 'http://websrv.cs.fsu.edu/~engelen/interop2.cgi', true, 'http://websrv.cs.fsu.edu/~engelen/interop2B.cgi'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'GLUE', 'http://www.themindelectric.net:8005/glue/round2', true, 'http://www.themindelectric.net:8005/glue/round2B'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'HP SOAP', 'http://soap.bluestone.com/hpws/soap/EchoService', true, 'http://soap.bluestone.com/hpws/soap/EchoService'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'IONA XMLBus', 'http://interop.xmlbus.com:7002/xmlbus/container/InteropTest/BaseService/BasePort', true, 'http://interop.xmlbus.com:7002/xmlbus/container/InteropTest/GroupBService/GroupBPort'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTestsNoHex]),
            'kSOAP', 'http://kissen.cs.uni-dortmund.de:8080/ksoapinterop', true));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTestsNoHex, TIdSoapSoapBuilders2GroupBTests]),
            'MS .NET Remoting', 'http://www.mssoapinterop.org/remoting/ServiceA.soap', false, 'http://www.mssoapinterop.org/remoting/ServiceB.soap'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'MS SOAP ToolKit 3.0', 'http://mssoapinterop.org/stkV3/Interop.wsdl', false, 'http://mssoapinterop.org/stkV3/InteropB.wsdl'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTestsNoHex, TIdSoapSoapBuilders2GroupBTests]),
            'MS SOAP ToolKit 3.0 (Typed)', 'http://mssoapinterop.org/stkV3/InteropTyped.wsdl', true, 'http://mssoapinterop.org/stkV3/InteropBtyped.wsdl'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'NuSOAP', 'http://dietrich.ganx4.com/nusoap/testbed/round2_base_server.php', true, 'http://dietrich.ganx4.com/nusoap/testbed/round2_groupb_server.php'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests]),
            'NuWave', 'http://interop.nuwave-tech.com:7070/interop/base.wsdl', true));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'OpenLink Virtuoso', 'http://demo.openlinksw.com:8890/Interop', false, 'http://demo.openlinksw.com:8890/Interop'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTestsNoHex]),
            'Oracle', 'http://ws-interop.oracle.com/soapbuilder/r2/InteropTest', true));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'PEAR SOAP', 'http://www.caraveo.com/soap_interop/server_round2.php', true, 'http://www.caraveo.com/soap_interop/server_round2.php'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTestsShort]),
            'SIM', 'http://soapinterop.simdb.com/round2', true, 'http://soapinterop.simdb.com/round2B'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'SOAP4R', 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/', true, 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'SOAP:Lite', 'http://services.soaplite.com/interop.cgi', true, 'http://services.soaplite.com/interop.cgi'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'Spray 2001', 'http://www.dolphinharbor.org/services/interop2001', true, 'http://www.dolphinharbor.org/services/interopB2001', ));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'Sun Microsystems', 'http://soapinterop.java.sun.com:80/round2/base', true, 'http://soapinterop.java.sun.com:80/round2/groupb'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests]),
            'VW OpentalkSoap 1.0', 'http://www.cincomsmalltalk.com/soap/interop', true));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'WASP Advanced 4.0', 'http://soap.systinet.net:6060/InteropService/', true, 'http://soap.systinet.net:6060/InteropBService/'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'WASP for C++ 4.0', 'http://soap.systinet.net:6070/InteropService/', true, 'http://soap.systinet.net:6070/InteropBService/'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'webMethods Integration Server', 'http://ewsdemo.webMethods.com:80/soap/rpc', false, 'http://ewsdemo.webMethods.com:80/soap/rpc'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTests, TIdSoapSoapBuilders2GroupBTests]),
            'White Mesa SOAP Server', 'http://www.whitemesa.net/interop/std', false, 'http://www.whitemesa.net/interop/std/groupB'));

     LTemp.AddTest(TIdSoapBuilders2Setup.create(BuildGroup('Tests', [TIdSoapSoapBuilders2BaseTestsNoHex, TIdSoapSoapBuilders2GroupBTestsShort]),
            'Wingfoot SOAP Server', 'http://www.wingfoot.com/servlet/wserver', true, 'http://www.wingfoot.com/servlet/wserver'));
     end;
  finally
    FreeAndNil(FIniFile);
  end;
end;

function LowLevelInterfaceTests:TTestSuite;
begin
  result := TTestSuite.create('Lowlevel Interface Tests');
  result.AddSuite(BuildGroup('Inheritance Tests', [TIdSoapInterfaceInheritanceTests]));
end;

procedure IdSoapRegisterTests(AParent : TTestSuite);
  procedure AddGroup(ATest : TTestSuite);
  begin
    if AParent = nil then
      begin
      RegisterTest(ATest);
      end
    else
      begin
      AParent.AddSuite(ATest);
      end;
  end;
begin
  {$IFNDEF LINUX}
  {$IFDEF VCL5ORABOVE}
  if CheckTestOptions then
  {$ENDIF}
  {$ENDIF}
    begin
    AddGroup(InfrastuctureTests);
    AddGroup(TypeRegistrationTests);
    AddGroup(SoapTypeTests);
    AddGroup(ITITests);
    AddGroup(EncodingTests);
    AddGroup(CommsTests);
    AddGroup(WSDLTests);
    AddGroup(FunctionalTests);
    AddGroup(LowLevelInterfaceTests);
    end
  {$IFNDEF LINUX}
  {$IFDEF VCL5ORABOVE}
  else
    begin
    halt;
    end;
  {$ENDIF}
  {$ENDIF}
end;

end.

