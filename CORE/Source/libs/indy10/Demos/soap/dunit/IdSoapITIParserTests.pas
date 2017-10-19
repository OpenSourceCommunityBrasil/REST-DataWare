{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16408: IdSoapITIParserTests.pas 
{
{   Rev 1.1    19/6/2003 21:36:16  GGrieve
{ Version #1
}
{
{   Rev 1.0    25/2/2003 13:28:12  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  Support renaming in ITI
  26-Sep 2002   Grahame Grieve                  Sessional Testing
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Add Tests for renaming names and types
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  24-Jul 2002   Grahame Grieve                  Change to SoapAction policy
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  04-Apr 2002   Grahame Grieve                  Namespace and SoapAction tests
  03-Apr 2002   Grahame Grieve                  Fix Kylix issue
  03-Apr 2002   Grahame Grieve                  Request & Response name parsing
  26-Mar 2002   Grahame Grieve                  remove hint
  22-Mar 2002   Grahame Grieve                  Test Documentation Property
  14-Mar 2002   Andrew Cumming                  Added code for Application.ProcessMessages equiv to TearDown
  14-Mar 2002   Grahame Grieve                  Changes to parser
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
  03-Feb 2002   Andrew Cumming                  Added D4 support
}

{
we have already tested the ITI itself but this will test it again.
We will take a known interface definition, and parse it.
And then check it. And then validate it. (Later, we will do our
live testing with the same interface and a real implementation)

We will do this cycle parse/check/validate many times with variants of
the interface definition, trying to break the parser, and the validation
with some of these tests, we are more interested in whether the parser doesn't
hang
}

unit IdSoapITIParserTests;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  TestFramework,
  IdSoapITI,
  IdSoapITIParser;

type
  TITIParserTestCases = class(TTestCase)
  Private
    FITI : TIdSoapITI;
    FParser: TIdSoapITIParser;
    FFile: TFileStream;
    FInclusions: TStringList;
    FExclusions: TStringList;
    procedure OpenFile(AFileName: String);
    procedure BaseSoapDefnCheck(ASessional : boolean);
  Protected
    procedure Setup; Override;
    procedure TearDown; Override;
  Published
    procedure TestRealDefinition;
    procedure TestRealDefinitionValidate;
    procedure TestSplitDefinition;
    procedure TestSplitDefinitionValidate;
    procedure TestExclusion1;
    procedure TestExclusion2;
    procedure TestExclusion3;
    procedure TestInclusion1;
    procedure TestInclusion2;
    procedure TestInclusion3;
    procedure TestEmptyFile;
    procedure TestNoUnit;
    procedure TestNoInterface;
    procedure TestNoImplementation;
    procedure TestFragment;
    procedure TestNoEnd;
    procedure TestNoMiddleEnd;
    procedure TestMissingSemiColon1;
    procedure TestMissingSemiColon2;
    procedure TestMissingSemiColon3;
    procedure TestMissingSemiColon4;
    procedure TestMissingGuid;
    procedure TestUnterminatedGuid;
    procedure TestSpoofAttempt;
    procedure TestSpoofAttempt2;
    procedure TestDoco;
    procedure TestSoapinfo;
    procedure TestTypeRenaming1;
    procedure TestTypeRenaming2;
    procedure TestTypeRenaming3;
    procedure TestTypeRenaming4;
    procedure TestTypeRenaming5;
    procedure TestTypeRenaming6;
    procedure TestTypeRenaming7;
    procedure TestTypeRenaming8;
    procedure TestTypeRenaming9;
  end;

implementation

uses
  IdSoapExceptions,
  IdSoapTestingUtils,
  IdSoapUtilities,
  SysUtils;

{ TITIParserTestCases }

procedure TITIParserTestCases.Setup;
begin
  FInclusions := TStringList.Create;
  FExclusions := TStringList.Create;
  FParser := TIdSoapITIParser.Create;
  FITI := TIdSoapITI.create;
end;

procedure TITIParserTestCases.OpenFile(AFileName: String);
begin
  assert(FileExists(AFileName), 'File "' + AFileName + '" not found from ' + GetCurrentDir);
  FFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
end;

procedure TITIParserTestCases.TearDown;
begin
  FreeAndNil(FFile);
  FreeAndNil(FITI);
  FreeAndNil(FParser);
  FreeAndNil(FInclusions);
  FreeAndNil(FExclusions);
  IdSoapProcessMessages;
end;

procedure TITIParserTestCases.TestRealDefinition;
var
  LMsg : string;
begin
  OpenFile('TestIntfDefn.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Parsing Failed: '+LMsg);
end;

procedure TITIParserTestCases.TestRealDefinitionValidate;
begin
  OpenFile('TestIntfDefn.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FITI.Validate('test');
  Check(True, 'Main testing ITI should validate');
end;

procedure TITIParserTestCases.TestSplitDefinition;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Parsing Failed: '+LMsg);
end;

procedure TITIParserTestCases.TestSplitDefinitionValidate;
begin
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FITI.Validate('test');
  Check(True, 'Split testing ITI should validate');
end;

procedure TITIParserTestCases.TestExclusion1;
var
  LMsg : string;
begin
  FExclusions.Add('IIdTestInterface');
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 8, 'Exclusions Failed: '+LMsg);
  // 8 errors relating to the second interface being confused with the first
end;

procedure TITIParserTestCases.TestExclusion2;
var
  LMsg : string;
begin
  FExclusions.Add('IIdTestInterface2');
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 1, 'Exclusions Failed: '+LMsg);
end;

procedure TITIParserTestCases.TestExclusion3;
var
  LMsg : string;
begin
  FExclusions.Add('IIdTestInterface');
  FExclusions.Add('IIdTestInterface2');
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 1, 'Exclusions Failed: '+LMsg);
end;

procedure TITIParserTestCases.TestInclusion1;
var
  LMsg : string;
begin
  FInclusions.Add('IIdTestInterface2');
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 8, 'Inclusions Failed: '+LMsg);
  // 6 errors relating to the second interface being confused with the first
end;

procedure TITIParserTestCases.TestInclusion2;
var
  LMsg : string;
begin
  FInclusions.Add('IIdTestInterface');
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 1, 'Inclusions Failed: '+LMsg);
end;

procedure TITIParserTestCases.TestInclusion3;
var
  LMsg : string;
begin
  FInclusions.Add('IIdTestInterface');
  FINclusions.Add('IIdTestInterface2');
  OpenFile('ParserTests/Sample1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  FreeAndNil(FFile);
  OpenFile('ParserTests/Sample1a.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Inclusions Failed: '+LMsg);
end;

procedure TITIParserTestCases.TestEmptyFile;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample2.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, 'Empty file was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestNoUnit;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample3.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Missing Unit Declaration was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestNoInterface;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample4.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, 'Missing Unit Interface was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestNoImplementation;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample5.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Missing Unit Implementation was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestFragment;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample6.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Fragment was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestNoEnd;
var
  LMsg : string;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample7.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'missing end was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestNoMiddleEnd;
var
  LMsg : string;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample8.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, 'missing end was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestMissingSemiColon1;
var
  LMsg : string;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample9.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, 'missing colon was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestMissingSemiColon2;
var
  LMsg : string;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample10.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, 'missing colon was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestMissingSemiColon3;
var
  LMsg : string;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample11.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, 'missing colon was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestMissingSemiColon4;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample12.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(false, 'missing colon should''ve raised exception');
end;

procedure TITIParserTestCases.TestMissingGuid;
var
  LMsg : string;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample13.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, 'missing GUID was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestUnterminatedGuid;
var
  LMsg : string;
begin
  ExpectedException := EIdSoapBadDefinition;
  OpenFile('ParserTests/Sample14.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) <> 0, ' Unterminated GUID was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestSpoofAttempt;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample15.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, ' Spoof Attempt was a problem: '+LMsg);
end;

procedure TITIParserTestCases.TestSpoofAttempt2;
var
  LMsg : string;
begin
  OpenFile('ParserTests/Sample16.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, ' Spoof Attempt was a problem: '+LMsg);
end;

{$IFDEF MSWINDOWS}
const
  EOLN = #13#10;
{$ELSE}
const
  EOLN = #10;
{$ENDIF}

procedure TITIParserTestCases.TestDoco;
var
  LMsg : string;
  LIntf : TIdSoapITIInterface;
  LMeth : TIdSoapITIMethod;
  LParam : TIdSoapITIParameter;
begin
  OpenFile('ParserTests/SampleDoco.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Parsing Failed: '+LMsg);
  LIntf := FITI.FindInterfaceByName('IIdTestInterface');
  Check(LIntf.Documentation = 'This is a test comment for interface IIdTestInterface.'+EOLN+'This comment is to test the indent'+EOLN+EOLN+' correction built into the parser'+EOLN, 'Interface Documentation parsing failed');
  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample1')] as TIdSoapITIMethod;
  Check(LMeth.Documentation = 'A test comment about Sample1', 'Method Documentation parsing failed');
  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample5')] as TIdSoapITIMethod;
  LParam := LMeth.Parameters.ParamByName['ANum02'];
  Check(LParam.Documentation = 'A Test Comment about ANum02', 'Parameter Documentation parsing failed');
end;

procedure TITIParserTestCases.BaseSoapDefnCheck(ASessional : boolean);
var
  LMsg : string;
  LIntf : TIdSoapITIInterface;
  LMeth : TIdSoapITIMethod;
  LParam : TIdSoapITIParameter;
begin
  Check(CheckTestingITI(FITI, LMsg) = 0, 'Parsing Failed: '+LMsg);

  LIntf := FITI.FindInterfaceByName('IIdTestInterface');
  Check(LIntf.Documentation = 'This is a test comment for interface IIdTestInterface.'+EOLN+'This comment is to test the indent'+EOLN+EOLN+' correction built into the parser'+EOLN, 'Interface Documentation parsing failed');
  Check(LIntf.Namespace = 'http://www.kestral.com.au/test/namespace-namespace', 'Namespace parsing failed');

  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample1')] as TIdSoapITIMethod;
  Check(LMeth.Documentation = 'A test comment about Sample1', 'Method Documentation parsing failed');
  Check(LMeth.RequestMessageName = 'Meth2', 'SOAP Info parsing failed');
  Check(LMeth.ResponseMessageName = 'Meth1', 'SOAP Info parsing failed');
  Check(LMeth.SoapAction = 'http://sdfsdf/sdfsd.sdf/sdf', 'SoapAction parsing failed');

  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample4')] as TIdSoapITIMethod;
  Check(LMeth.Documentation = '', 'Method Documentation parsing failed');
  Check(LMeth.RequestMessageName = 'Sample4', 'SOAP Info parsing failed');
  Check(LMeth.ResponseMessageName = 'Sample4Response', 'SOAP Info parsing failed');
  Check(LMeth.SoapAction = 'http://sdfsdf/sdfsd.sdf/sdf', 'SoapAction parsing failed');
  if ASessional then
    begin
    Check(LMeth.SessionRequired, 'Sessional failed to parse');
    end;

  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample5')] as TIdSoapITIMethod;
  LParam := LMeth.Parameters.ParamByName['ANum02'];
  Check(LParam.Documentation = 'A Test Comment about ANum02', 'Parameter Documentation parsing failed');
  Check(LMeth.RequestMessageName = 'Meth3', 'SOAP Info parsing failed');
  Check(LMeth.ResponseMessageName = 'Meth4', 'SOAP Info parsing failed');
  Check(LMeth.SoapAction = 'http://sdfsdf/sdfsd.sdf/sdf2', 'SoapAction parsing failed');
  if ASessional then
    begin
    Check(not LMeth.SessionRequired, 'Sessional failed to parse');
    end;
end;

procedure TITIParserTestCases.TestSoapinfo;
begin
  OpenFile('ParserTests/SampleDefn.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  BaseSoapDefnCheck(true);
end;

procedure TITIParserTestCases.TestTypeRenaming1;
var
  LIntf : TIdSoapITIInterface;
  i : integer;
begin
  OpenFile('ParserTests/SampleType1.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  BaseSoapDefnCheck(false);

  LIntf := FITI.FindInterfaceByName('IIdTestInterface');
  Check(LIntf.Types.count = 3);
  Check(LIntf.Types.IndexOf('TTestClass') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Name = 'TestClass');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');
  Check(LIntf.Types.IndexOf('TTestClass1') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Name = 'TestClass3');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Namespace = '');
  Check(LIntf.Types.IndexOf('TTestClass2') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Name = 'TTestClass2');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');

  for i := 0 to LIntf.Methods.count - 1 do
    begin
    Check((LIntf.Methods.objects[i] as TIdSoapITIMethod).EncodingMode = semRPC);
    end;
end;

procedure TITIParserTestCases.TestTypeRenaming2;
var
  LIntf : TIdSoapITIInterface;
  LMeth : TIdSoapITIMethod;
  i : integer;
begin
  OpenFile('ParserTests/SampleType2.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  BaseSoapDefnCheck(false);

  LIntf := FITI.FindInterfaceByName('IIdTestInterface');
  Check(LIntf.Types.count = 3);
  Check(LIntf.Types.IndexOf('TTestClass') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Name = 'TestClass');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');
  Check(LIntf.Types.IndexOf('TTestClass1') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Name = 'TestClass3');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Namespace = '');
  Check(LIntf.Types.IndexOf('TTestClass2') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Name = 'TTestClass2');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');
  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample1')] as TIdSoapITIMethod;
  Check(LMeth.Types.count = 0);
  for i := 0 to LIntf.Methods.count - 1 do
    begin
    if i = 0 then
      begin
      Check((LIntf.Methods.objects[i] as TIdSoapITIMethod).EncodingMode = semRPC);
      end
    else
      begin
      Check((LIntf.Methods.objects[i] as TIdSoapITIMethod).EncodingMode = semDocument);
      end;
    end;
end;

procedure TITIParserTestCases.TestTypeRenaming3;
var
  LIntf : TIdSoapITIInterface;
  LMeth : TIdSoapITIMethod;
  LParam : TIdSoapITIParameter;
begin
  OpenFile('ParserTests/SampleType3.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  BaseSoapDefnCheck(false);

  LIntf := FITI.FindInterfaceByName('IIdTestInterface');
  Check(LIntf.Types.count = 3);
  Check(LIntf.Types.IndexOf('TTestClass') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Name = 'TestClass');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');
  Check(LIntf.Types.IndexOf('TTestClass1') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Name = 'TestClass3');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Namespace = '');
  Check(LIntf.Types.IndexOf('TTestClass2') <> -1);
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Name = 'TTestClass2');
  Check((LIntf.Types.Objects[LIntf.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');

  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample1')] as TIdSoapITIMethod;
  Check(LMeth.Types.count = 1);
  Check(LMeth.Types.IndexOf('TTestClass1') <> -1);
  Check((LMeth.Types.Objects[LMeth.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Name = 'TestClass4');
  Check((LMeth.Types.Objects[LMeth.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Namespace = '');

  LMeth := LIntf.Methods.objects[LIntf.Methods.indexof('Sample5')] as TIdSoapITIMethod;
  Check(LMeth.Types.count = 0);
  LParam := LMeth.Parameters.ParamByName['ANum03'];
  Check(LParam.Types.count = 1);
  Check(LParam.Types.IndexOf('TTestClass1') <> -1);
  Check((LParam.Types.Objects[LParam.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Name = 'TestClass5');
  Check((LParam.Types.Objects[LParam.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Namespace = '');
  LParam := LMeth.Parameters.ParamByName['ANum04'];
  Check(LParam.Types.count = 1);
  Check(LParam.Types.IndexOf('TTestClass1') <> -1);
  Check((LParam.Types.Objects[LParam.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Name = 'TestClass6');
  Check((LParam.Types.Objects[LParam.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Namespace = '');
end;

procedure TITIParserTestCases.TestTypeRenaming4;
begin
  OpenFile('ParserTests/SampleType4.pas');
  ExpectedException := EIdSoapRequirementFail;
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
end;

procedure TITIParserTestCases.TestTypeRenaming5;
begin
  OpenFile('ParserTests/SampleType5.pas');
  ExpectedException := EIdSoapRequirementFail;
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
end;

procedure TITIParserTestCases.TestTypeRenaming6;
begin
  OpenFile('ParserTests/SampleType6.pas');
  ExpectedException := EIdSoapRequirementFail;
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
end;

procedure TITIParserTestCases.TestTypeRenaming7;
begin
  OpenFile('ParserTests/SampleType7.pas');
  ExpectedException := EIdSoapRequirementFail;
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
end;

procedure TITIParserTestCases.TestTypeRenaming8;
begin
  OpenFile('ParserTests/SampleType7.pas');
  ExpectedException := EIdSoapRequirementFail;
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
end;

procedure TITIParserTestCases.TestTypeRenaming9;
begin
  OpenFile('ParserTests/SampleType9.pas');
  FParser.Parse(FITI, FFile, 'TestIntfDefn', FInclusions, FExclusions);
  BaseSoapDefnCheck(false);

  Check(FITI.Types.count = 3);
  Check(FITI.Types.IndexOf('TTestClass') <> -1);
  Check((FITI.Types.Objects[FITI.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Name = 'TestClass');
  Check((FITI.Types.Objects[FITI.Types.IndexOf('TTestClass')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');
  Check(FITI.Types.IndexOf('TTestClass1') <> -1);
  Check((FITI.Types.Objects[FITI.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Name = 'TestClass3');
  Check((FITI.Types.Objects[FITI.Types.IndexOf('TTestClass1')] as TIdSoapITINameObject).Namespace = '');
  Check(FITI.Types.IndexOf('TTestClass2') <> -1);
  Check((FITI.Types.Objects[FITI.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Name = 'TTestClass2');
  Check((FITI.Types.Objects[FITI.Types.IndexOf('TTestClass2')] as TIdSoapITINameObject).Namespace = 'http://www.kestral.com.au/test/namespace/schema');

end;

end.
