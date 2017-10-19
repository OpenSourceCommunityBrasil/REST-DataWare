{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16468: IdSoapTests.dpr 
{
{   Rev 1.2    19/6/2003 21:36:36  GGrieve
{ Version #1
}
{
{   Rev 1.1    18/3/2003 11:16:22  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:38:00  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  18-Mar 2003   Grahame Grieve                  Kylix compile fixes (Dunit update to 7.x)
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
  11-Feb 2002   Andrew Cumming                  Added IdSoapInterfaceTests
}

program IdSoapTests;

{$I IdSoapDefines.inc}

uses
  TestFramework {$IFDEF LINUX},
  QForms,
  QGUITestRunner {$ELSE},
  windows,
  Forms,
  GUITestRunner {$ENDIF},
  IdSoapDebugTests in 'IdSoapDebugTests.pas',
  IDSoapTypeRegistryTests in 'IDSoapTypeRegistryTests.pas',
  IdSoapUtilitiesTest in 'IdSoapUtilitiesTest.pas',
  IdSoapITITests in 'IdSoapITITests.pas',
  IdSoapITIBinXMLTests in 'IdSoapITIBinXMLTests.pas',
  IdSoapITIProviderTests in 'IdSoapITIProviderTests.pas',
  IdSoapITIRttiTests in 'IdSoapITIRttiTests.pas',
  IdSoapIntfRegistryTests in 'IdSoapIntfRegistryTests.pas',
  IdSoapITIParserTests in 'IdSoapITIParserTests.pas',
  TestIntfImpl in 'TestIntfImpl.pas',
  IdSoapRpcXmlTests in 'IdSoapRpcXmlTests.pas',
  IdSoapInterfaceTests,
  IdSoapEndToEnd_1_Tests in 'IdSoapEndToEnd_1_Tests.pas',
  IdSoapTestsRegistration in 'IdSoapTestsRegistration.pas';

{$R *.res}

begin
  { This is because when not running under a debugger, Delphi (6) runs the
    executable with a default directory different to the executable
    Stupid but true. So if it's a problem, just put the right directory
    as the first parameter }

  {$IFDEF MSWINDOWS}
  if ParamStr(1) <> '' then
    SetCurrentDirectory(pchar(ParamStr(1)));
  {$ENDIF}
  IdSoapRegisterTests(nil);
  Application.Initialize;
  {$IFDEF LINUX}
  QGUITestRunner.RunRegisteredTests;
  {$ELSE}
  GuiTestRunner.RunRegisteredTests;
  {$ENDIF}
end.
