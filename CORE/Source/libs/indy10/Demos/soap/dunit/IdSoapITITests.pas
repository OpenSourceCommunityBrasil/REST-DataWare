{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16414: IdSoapITITests.pas 
{
{   Rev 1.1    19/6/2003 21:36:20  GGrieve
{ Version #1
}
{
{   Rev 1.0    25/2/2003 13:28:28  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  Header Changes
  05-Sep 2002   Grahame Grieve                  remove IdGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Add Tests for renaming names and types
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  24-Jul 2002   Grahame Grieve                  Change to SoapAction policy
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  21-Apr 2002   Andrew Cumming                  Removing dependence on ole2 for D5
  11-Apr 2002   Grahame Grieve                  Update tests for changes to assertion policy
  04-Apr 2002   Grahame Grieve                  Namespace and SoapAction tests
  03-Apr 2002   Grahame Grieve                  Add Resquest/Response name tests
  22-Mar 2002   Grahame Grieve                  Test Documentation Property
  14-Mar 2002   Andrew Cumming                  Added code for Application.ProcessMessages equiv to TearDown
  14-Mar 2002   Grahame Grieve                  Namespace related tests
   8-Mar 2002   Andrew Cumming                  Made D4/D5 compatible
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
}

unit IdSoapITITests;

{$I IdSoapDefines.inc}

interface

uses
  TestFramework,
  IdSoapITI;

type
  TITITestCase = class(TTestCase)
  Private
    FITI: TIdSoapITI;
  Protected
    procedure Setup; Override;
    procedure TearDown; Override;
  end;

  TITIParameterTestCases = class(TITITestCase)
  Private
    FParam: TIdSoapITIParameter;
  Protected
    procedure Setup; Override;
    procedure TearDown; Override;
  Published
    procedure TestProperty1;
    procedure TestProperty2;
    procedure TestProperty3;
    procedure TestValidation1;
    procedure TestValidation2;
    procedure TestValidation3;
    procedure TestValidation4;
    procedure TestValidation5;
    procedure TestDocumentation;
  end;

  TITIMethodTestCases = class(TITITestCase)
  Private
    FMethod: TIdSoapITIMethod;
    FIntf : TIdSoapITIInterface;
  Protected
    procedure Setup; Override;
    procedure TearDown; Override;
  Published
    procedure TestProperty1;
    procedure TestProperty2;
    procedure TestProperty3;
    procedure TestProperty4;
    procedure TestSoapAction1;
    procedure TestSoapAction2;
    procedure TestValidation1;
    procedure TestValidation2;
    procedure TestValidation3;
    procedure TestValidation4;
    procedure TestValidation5;
    procedure TestValidation6;
    procedure TestValidation7;
    procedure TestSoapOpType;
    procedure TestNameReplacement1;
    procedure TestNameReplacement2;
    procedure TestNameReplacement3;
    procedure TestNameReplacement4;
    procedure TestNameReplacement5;
    procedure TestNameReplacement6;
    procedure TestTypeReplacement1;
    procedure TestTypeReplacement2;
    procedure TestTypeReplacement3;
    procedure TestTypeReplacement4;
    procedure TestTypeReplacement5;
    procedure TestTypeReplacement6;
    procedure TestTypeReplacement7;
    procedure TestTypeReplacement8;
    procedure TestTypeReplacement9;
    procedure TestTypeReplacementA;
    procedure TestTypeReplacementB;
    procedure TestTypeReplacementC;
  end;

  TITIInterfaceTestCases = class(TITITestCase)
  Private
    FIntf: TIdSoapITIInterface;
  Protected
    procedure Setup; Override;
    procedure TearDown; Override;
  Published
    procedure TestProperty1;
    procedure TestProperty2;
    procedure TestProperty3;
    procedure TestPropertyUnitName;
    procedure TestNamespace1;
    procedure TestNamespace2;
    procedure TestValidation1;
    procedure TestValidation2;
    procedure TestValidation3;
    procedure TestValidation4;
    procedure TestValidation5;
    procedure TestValidation6;
    procedure TestMethodSearch;
  end;

  TITITestCases = class(TITITestCase)
  Protected
    procedure Setup; Override;
  Published
    procedure TestValidation1;
    procedure TestValidation2;
    procedure TestValidation3;
    procedure TestValidation4;
  end;

implementation

uses
  IdSoapTestingUtils,
{$IFDEF DELPHI4OR5}
  ComObj,
{$ENDIF}
  IdSoapExceptions,
  IdSoapUtilities,
  SysUtils,
  TypInfo;

{ TITITestCase }

procedure TITITestCase.Setup;
begin
  FITI := TIdSoapITI.Create;
end;

procedure TITITestCase.TearDown;
begin
  FreeAndNil(FITI);
  IdSoapProcessMessages;
end;

{ TITIParameterTestCases }

procedure TITIParameterTestCases.Setup;
begin
  inherited;
  FParam := TIdSoapITIParameter.Create(FITI, nil);
end;

procedure TITIParameterTestCases.TearDown;
begin
  FreeAndNil(FParam);
  inherited;
end;

procedure TITIParameterTestCases.TestDocumentation;
begin
  FParam.Documentation := 'Test';
  check(FParam.Documentation = 'Test', 'Property Documentation Feedback test failed');
end;

procedure TITIParameterTestCases.TestProperty1;
begin
  FParam.Name := 'Test';
  check(FParam.Name = 'Test', 'Property Name Feedback test failed');
end;

procedure TITIParameterTestCases.TestProperty2;
begin
  FParam.NameOfType := 'Test2';
  check(FParam.NameOfType = 'Test2', 'Property NameOfType Feedback test failed');
end;

procedure TITIParameterTestCases.TestProperty3;
begin
  FParam.ParamFlag := pfReference;
  check(FParam.ParamFlag = pfReference, 'Property ParamFlag Feedback test failed');
end;

procedure TITIParameterTestCases.TestValidation1;
begin
  ExpectedException := EAssertionFailed;
  FParam.Name := '';
  FParam.ParamFlag := pfConst;
  FParam.NameOfType := 'Integer';
  FParam.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIParameterTestCases.TestValidation2;
begin
  ExpectedException := EAssertionFailed;
  FParam.Name := 'xxx';
  FParam.ParamFlag := pfConst;
  FParam.NameOfType := '';
  FParam.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIParameterTestCases.TestValidation3;
begin
  ExpectedException := EAssertionFailed;
  FParam.Name := 'xxx';
  FParam.ParamFlag := pfAddress;
  FParam.NameOfType := 'Integer';
  FParam.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIParameterTestCases.TestValidation4;
begin
  ExpectedException := EIdSoapUnknownType;
  FParam.Name := 'xxx';
  FParam.ParamFlag := pfConst;
  FParam.NameOfType := 'xxx';
  FParam.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIParameterTestCases.TestValidation5;
begin
  FParam.Name := 'xxx';
  FParam.ParamFlag := pfConst;
  FParam.NameOfType := 'Integer';
  FParam.Validate('test');
  Check(True, 'Validate should''ve passed');
end;

{ TITIMethodTestCases }

procedure TITIMethodTestCases.Setup;
begin
  inherited;
  FIntf := TIdSoapITIInterface.Create(FITI);
  FMethod := TIdSoapITIMethod.Create(FITI, FIntf);
  FMethod.Name := 'test1';
  FIntf.AddMethod(FMethod);
end;

procedure TITIMethodTestCases.TearDown;
begin
  FreeAndNil(FIntf);
  inherited;
end;

procedure TITIMethodTestCases.TestProperty1;
begin
  FMethod.Name := 'Test';
  check(FMethod.Name = 'Test', 'Property Name Feedback test failed');
end;

procedure TITIMethodTestCases.TestProperty2;
begin
  FMethod.CallingConvention := idccCdecl;
  check(FMethod.CallingConvention = idccCdecl, 'Property CallingConvention Feedback test failed');
end;

procedure TITIMethodTestCases.TestProperty3;
begin
  FMethod.MethodKind := mkSafeProcedure;
  check(FMethod.MethodKind = mkSafeProcedure, 'Property MethodKind Feedback test failed');
end;

procedure TITIMethodTestCases.TestProperty4;
begin
  FMethod.ResultType := 'Test';
  check(FMethod.ResultType = 'Test', 'Property ResultType Feedback test failed');
end;

procedure TITIMethodTestCases.TestSoapAction1;
begin
  FMethod.SoapAction := '';
  check(FMethod.SoapAction = '', 'SoapAction is wrong');
end;

procedure TITIMethodTestCases.TestSoapAction2;
begin
  FMethod.SoapAction := 'asasas';
  check(FMethod.SoapAction = 'asasas', 'SoapAction is wrong');
end;

procedure TITIMethodTestCases.TestValidation1;
begin
  ExpectedException := EAssertionFailed;
  FMethod.Name := '';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkProcedure;
  FMethod.ResultType := '';
  FMethod.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIMethodTestCases.TestValidation2;
begin
  ExpectedException := EAssertionFailed;
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccRegister;
  FMethod.MethodKind := mkProcedure;
  FMethod.ResultType := '';
  FMethod.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIMethodTestCases.TestValidation3;
begin
  ExpectedException := EAssertionFailed;
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkDestructor;
  FMethod.ResultType := '';
  FMethod.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIMethodTestCases.TestValidation4;
begin
  ExpectedException := EAssertionFailed;
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkFunction;
  FMethod.ResultType := '';
  FMethod.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIMethodTestCases.TestValidation5;
begin
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkProcedure;
  FMethod.ResultType := '';
  FMethod.Validate('test');
  Check(True, 'test should''ve passed');
end;

procedure TITIMethodTestCases.TestValidation6;
begin
  ExpectedException := EIdSoapUnknownType;
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkFunction;
  FMethod.ResultType := 'xxx';
  FMethod.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIMethodTestCases.TestValidation7;
begin
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkFunction;
  FMethod.ResultType := 'Double';
  FMethod.Validate('test');
  Check(True, 'test should''ve passed');
end;

procedure TITIMethodTestCases.TestNameReplacement1; // empty list
var
  LName : String;
begin
  LName := FIntf.ReplaceName('Test');
  Check(LName = 'Test');
  LName := FMethod.ReplaceName('Test');
  Check(LName = 'Test');
end;

procedure TITIMethodTestCases.TestNameReplacement2; // single parameter
var
  LName : String;
begin
  FIntf.DefineNameReplacement('', 'Test', 'soap1');
  FMethod.DefineNameReplacement('', 'Test', 'soap');
  LName := FIntf.ReplaceName('Test');
  Check(LName = 'soap1');
  LName := FMethod.ReplaceName('Test');
  Check(LName = 'soap');
  LName := FMethod.ReplaceName('Test1');
  Check(LName = 'Test1');
  LName := FMethod.ReverseReplaceName('', 'Test1');
  Check(LName = 'Test1');
  LName := FMethod.ReverseReplaceName('', 'soap');
  Check(LName = 'Test');
end;

procedure TITIMethodTestCases.TestNameReplacement3; // duplicate parameter
begin
  FMethod.DefineNameReplacement('', 'Test', 'soap');
  FIntf.DefineNameReplacement('', 'Test', 'soap1');
  ExpectedException := EIdSoapRequirementFail;
  FMethod.DefineNameReplacement('', 'Test', 'soap2');
end;

procedure TITIMethodTestCases.TestNameReplacement4; // single field
var
  LName : String;
begin
  FIntf.DefineNameReplacement('TTest', 'Test', 'soap1');
  LName := FMethod.ReplaceName('Test1');
  Check(LName = 'Test1');
  LName := FMethod.ReplacePropertyName('TTest', 'Test');
  Check(LName = 'soap1');
  LName := FMethod.ReplacePropertyName('TTest', 'Test2');
  Check(LName = 'Test2');
  LName := FMethod.ReverseReplaceName('TTest', 'soap1');
  Check(LName = 'Test');
  LName := FMethod.ReverseReplaceName('TTest', 'Test2');
  Check(LName = 'Test2');
end;

procedure TITIMethodTestCases.TestNameReplacement5; // duplicate field
begin
  FMethod.DefineNameReplacement('TTest', 'Test', 'soap');
  FIntf.DefineNameReplacement('TTest', 'Test', 'soap1');
  FMethod.DefineNameReplacement('', 'Test', 'soap2');
  ExpectedException := EIdSoapRequirementFail;
  FMethod.DefineNameReplacement('TTest', 'Test', 'soap2');
end;

procedure TITIMethodTestCases.TestNameReplacement6; // field & parameter with common base name
var
  LName : String;
begin

  FMethod.DefineNameReplacement('', 'Test', 'soap');
  FIntf.DefineNameReplacement('TTest', 'Test', 'soap1');
  FMethod.DefineNameReplacement('TTest', 'Test', 'soap2');
  LName := FIntf.ReplacePropertyName('TTest', 'Test');
  Check(LName = 'soap1');
  LName := FMethod.ReplacePropertyName('TTest', 'Test');
  Check(LName = 'soap2');
  LName := FMethod.ReplaceName('Test');
  Check(LName = 'soap');
  LName := FMethod.ReplaceName('Test1');
  Check(LName = 'Test1');
end;

procedure TITIMethodTestCases.TestTypeReplacement1; // empty list
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := '';
  FMethod.ReplaceTypeName('TTest', 'urn:test', LName, LNameSpace);
  Check(LName = 'TTest');
  Check(LNameSpace = 'urn:test');
  Check(FMethod.ReverseReplaceType('TTest', 'urn:test', 'urn:test') = 'TTest');
end;

procedure TITIMethodTestCases.TestTypeReplacement2; // empty list with interface namespace defined
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := 'urn:test1';
  FMethod.ReplaceTypeName('TTest', 'urn:test', LName, LNameSpace);
  Check(LName = 'TTest');
  Check(LNameSpace = 'urn:test1');
end;

procedure TITIMethodTestCases.TestTypeReplacement3; // single type with namespace
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := '';
  FIntf.DefineTypeReplacement('TTest', 'soapTest', 'urn:soap.org');
  FMethod.ReplaceTypeName('TTest', 'urn:test', LName, LNameSpace);
  Check(LName = 'soapTest');
  Check(LNameSpace = 'urn:soap.org');
  Check(FMethod.ReverseReplaceType('soapTest', 'urn:soap.org', 'urn:test') = 'TTest');
  Check(FMethod.ReverseReplaceType('soapTest', 'urn:test', 'urn:test') = 'soapTest');
  Check(FMethod.ReverseReplaceType('soapTest1', 'urn:test', 'urn:test') = 'soapTest1');
end;

procedure TITIMethodTestCases.TestTypeReplacement4; // single type no namespace
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := '';
  FIntf.DefineTypeReplacement('TTest', 'soapTest', '');
  FMethod.ReplaceTypeName('TTest', 'urn:test', LName, LNameSpace);
  Check(LName = 'soapTest');
  Check(LNameSpace = 'urn:test');
end;

procedure TITIMethodTestCases.TestTypeReplacement5; // single type namespace only
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := '';
  FIntf.DefineTypeReplacement('TTest', '', 'urn:soap.org');
  FMethod.ReplaceTypeName('TTest', 'urn:test', LName, LNameSpace);
  Check(LName = 'TTest');
  Check(LNameSpace = 'urn:soap.org');
end;

procedure TITIMethodTestCases.TestTypeReplacement6; // single type with namespace  with interface namespace defined
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := 'urn:ns';
  FIntf.DefineTypeReplacement('TTest', 'soapTest', 'urn:soap.org');
  FMethod.ReplaceTypeName('TTest', '', LName, LNameSpace);
  Check(LName = 'soapTest');
  Check(LNameSpace = 'urn:soap.org');
end;

procedure TITIMethodTestCases.TestTypeReplacement7; // single type no namespace  with interface namespace defined
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := 'urn:ns';
  FIntf.DefineTypeReplacement('TTest', 'soapTest', '');
  FMethod.ReplaceTypeName('TTest', 'urn:test', LName, LNameSpace);
  Check(LName = 'soapTest');
  Check(LNameSpace = 'urn:ns');
end;

procedure TITIMethodTestCases.TestTypeReplacement8; // single type namespace only   with interface namespace defined
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := 'urn:ns';
  FIntf.DefineTypeReplacement('TTest', '', 'urn:soap.org');
  FMethod.ReplaceTypeName('TTest', '', LName, LNameSpace);
  Check(LName = 'TTest');
  Check(LNameSpace = 'urn:soap.org');
end;

procedure TITIMethodTestCases.TestTypeReplacement9; // duplicate type
begin
  FIntf.DefineTypeReplacement('TTest', '', 'urn:soap.org');
  ExpectedException := EIdSoapRequirementFail;
  FIntf.DefineTypeReplacement('TTest', 'test', 'urn:ns');
end;

procedure TITIMethodTestCases.TestTypeReplacementA;
begin
  ExpectedException := EIdSoapRequirementFail;
  FIntf.DefineTypeReplacement('', 'test', 'urn:ns');
end;

procedure TITIMethodTestCases.TestTypeReplacementB;
begin
  ExpectedException := EIdSoapRequirementFail;
  FIntf.DefineTypeReplacement('TTest', '', '');
end;

procedure TITIMethodTestCases.TestTypeReplacementC;
var
  LName, LNamespace : string;
begin
  FIntf.Namespace := '';
  FIntf.DefineTypeReplacement('TTest3', 'soapTest3', 'urn:soap3.org');
  FIntf.DefineTypeReplacement('TTest2', 'soapTest2', 'urn:soap2.org');
  FIntf.DefineTypeReplacement('TTest4', 'soapTest4', 'urn:soap4.org');
  FIntf.DefineTypeReplacement('TTest1', 'soapTest1', 'urn:soap1.org');
  FMethod.ReplaceTypeName('TTest1', 'urn:test', LName, LNameSpace);
  Check(LName = 'soapTest1');
  Check(LNameSpace = 'urn:soap1.org');
  FMethod.ReplaceTypeName('TTest2', 'urn:test', LName, LNameSpace);
  Check(LName = 'soapTest2');
  Check(LNameSpace = 'urn:soap2.org');
  FMethod.ReplaceTypeName('TTest3', 'urn:test', LName, LNameSpace);
  Check(LName = 'soapTest3');
  Check(LNameSpace = 'urn:soap3.org');
  FMethod.ReplaceTypeName('TTest4', 'urn:test', LName, LNameSpace);
  Check(LName = 'soapTest4');
  Check(LNameSpace = 'urn:soap4.org');
end;

procedure TITIMethodTestCases.TestSoapOpType;
begin
  Check(FMethod.EncodingMode = semRPC);
  FMethod.EncodingMode := semDocument;
  Check(FMethod.EncodingMode = semDocument);
  FMethod.EncodingMode := semRPC;
  Check(FMethod.EncodingMode = semRPC);
end;

{ TITIInterfaceTestCases }

procedure TITIInterfaceTestCases.Setup;
var
  FMethod: TIdSoapITIMethod;
begin
  inherited;
  FMethod := TIdSoapITIMethod.Create(FITI, nil);
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkFunction;
  FMethod.ResultType := 'Double';
  FIntf := TIdSoapITIInterface.Create(FITI);
  FIntf.AddMethod(FMethod);
end;

procedure TITIInterfaceTestCases.TearDown;
begin
  FIntf.Free;
  inherited;
end;

procedure TITIInterfaceTestCases.TestProperty1;
begin
  FIntf.Name := 'test';
  Check(FIntf.Name = 'test', 'Property Name Feedback test failed');
end;

procedure TITIInterfaceTestCases.TestProperty2;
begin
  FIntf.Ancestor := 'test';
  Check(FIntf.Ancestor = 'test', 'Property Name Feedback test failed');
end;

procedure TITIInterfaceTestCases.TestProperty3;
begin
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  Check(GUIDToString({$IFDEF DELPHI5} System.TGUID( {$ENDIF} FIntf.GUID {$IFDEF DELPHI5}) {$ENDIF}) = '{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}', 'Property Name Feedback test failed');
end;

procedure TITIInterfaceTestCases.TestPropertyUnitName;
begin
  FIntf.UnitName := 'testunit';
  Check(FIntf.UnitName = 'testunit', 'Unitname Feedbback test failed');
end;

procedure TITIInterfaceTestCases.TestNamespace1;
begin
  FIntf.UnitName := 'testunit';
  FIntf.Name := 'testname';
  FIntf.Namespace := '';
  check(FIntf.Namespace = '', 'Namespace is wrong');
end;

procedure TITIInterfaceTestCases.TestNamespace2;
begin
  FIntf.UnitName := 'testunit';
  FIntf.Name := 'testname';
  FIntf.Namespace := 'testns';
  check(FIntf.Namespace = 'testns', 'Namespace is wrong');
end;

procedure TITIInterfaceTestCases.TestValidation1;
begin
  ExpectedException := EAssertionFailed;
  FIntf.Name := '';
  FIntf.UnitName := 'testunit';
  FIntf.Ancestor := 'IIdSoapInterface';
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  FIntf.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIInterfaceTestCases.TestValidation2;
begin
  ExpectedException := EAssertionFailed;
  FIntf.Name := 'xxx';
  FIntf.UnitName := 'testunit';
  FIntf.Ancestor := 'sdfsdf';
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  FIntf.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIInterfaceTestCases.TestValidation3;
begin
  ExpectedException := EAssertionFailed;
  FIntf.Name := 'xxx';
  FIntf.UnitName := 'testunit';
  FIntf.Ancestor := '';
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  FIntf.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIInterfaceTestCases.TestValidation4;
var
  FMethod: TIdSoapITIMethod;
begin
  ExpectedException := EAssertionFailed;
  FIntf.Name := 'xxx';
  FIntf.UnitName := 'testunit';
  FIntf.Ancestor := 'IIdSoapInterface';
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  FMethod := TIdSoapITIMethod.Create(FITI, FIntf);
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkFunction;
  FMethod.ResultType := 'Double';
  try
    FIntf.AddMethod(FMethod);
  except
    FMethod.Free;
    raise;
    end;
  Check(False, 'test should''ve raised an exception');
end;

procedure TITIInterfaceTestCases.TestValidation5;
begin
  FIntf.Name := 'xxx';
  FIntf.UnitName := 'testunit';
  FIntf.Ancestor := 'IIdSoapInterface';
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  FIntf.Validate('test');
  Check(True, 'test should''ve passed');
end;

procedure TITIInterfaceTestCases.TestValidation6;
begin
  ExpectedException := EAssertionFailed;
  FIntf.Name := 'xxx';
  FIntf.UnitName := '';
  FIntf.Ancestor := 'IIdSoapInterface';
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  FIntf.Validate('test');
  Check(False, 'test should''ve raised an exception');
end;


procedure TITIInterfaceTestCases.TestMethodSearch;
var
  LMeth : TIdSoapITIMethod;
begin
  FIntf.Name := 'xxx';
  FIntf.UnitName := 'ssdf';
  FIntf.Ancestor := 'IIdSoapInterface';
  FIntf.GUID := StringToGUID('{53CA2DF3-60BF-4F4F-87B1-2CF01B4BE8DE}');
  LMeth := TIdSoapITIMethod.create(FITI, FIntf);
  LMeth.Name := 'TestMeth';
  LMeth.CallingConvention := idccStdCall;
  LMeth.MethodKind := mkProcedure;
  FIntf.AddMethod(LMeth);
  LMeth := TIdSoapITIMethod.create(FITI, FIntf);
  LMeth.Name := 'TestMeth1';
  LMeth.CallingConvention := idccStdCall;
  LMeth.MethodKind := mkProcedure;
  FIntf.AddMethod(LMeth);
  LMeth := TIdSoapITIMethod.create(FITI, FIntf);
  LMeth.Name := 'TestMeth2';
  LMeth.CallingConvention := idccStdCall;
  LMeth.MethodKind := mkProcedure;
  LMeth.RequestMessageName := 'lMReq';
  LMeth.ResponseMessageName := 'lMResp';
  FIntf.AddMethod(LMeth);
  FIntf.Validate('test');
  check(assigned(FIntf.FindMethodByName('TestMeth', ntPascal)));
  check(assigned(FIntf.FindMethodByName('TestMeth1', ntPascal)));
  check(assigned(FIntf.FindMethodByName('TestMeth2', ntPascal)));
  check(assigned(FIntf.FindMethodByName('TestMeth', ntMessageRequest)));
  check(assigned(FIntf.FindMethodByName('TestMeth1', ntMessageRequest)));
  check(assigned(FIntf.FindMethodByName('lMReq', ntMessageRequest)));
  check(assigned(FIntf.FindMethodByName('TestMethResponse', ntMessageResponse)));
  check(assigned(FIntf.FindMethodByName('TestMeth1Response', ntMessageResponse)));
  check(assigned(FIntf.FindMethodByName('lMResp', ntMessageResponse)));

  check(assigned(FIntf.FindMethodByName('Testmeth', ntPascal)));
  check(assigned(FIntf.FindMethodByName('TestMeth1', ntMessageRequest)));
  check(assigned(FIntf.FindMethodByName('LMResp', ntMessageResponse)));

  check(not assigned(FIntf.FindMethodByName('TestMeth2', ntMessageRequest)));
end;


{ TITITestCases }

procedure TITITestCases.Setup;
var
  FMethod: TIdSoapITIMethod;
  FIntf: TIdSoapITIInterface;
begin
  inherited;
  FIntf := TIdSoapITIInterface.Create(FITI);
  FIntf.Name := 'I1';
  FIntf.UnitName := 'testunit';
  FIntf.GUID := StringToGUID('{A1D3E03F-FAA9-4A9E-9CBA-B6F2DFCF57F4}');
  FIntf.Ancestor := 'IIdSoapInterface';
  FITI.AddInterface(FIntf);
  FMethod := TIdSoapITIMethod.Create(FITI, FIntf);
  FMethod.Name := 'xxx';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkFunction;
  FMethod.ResultType := 'Double';
  FIntf.AddMethod(FMethod);
  FMethod := TIdSoapITIMethod.Create(FITI, FIntf);
  FMethod.Name := 'xxxy';
  FMethod.CallingConvention := idccStdCall;
  FMethod.MethodKind := mkFunction;
  FMethod.ResultType := 'Double';
  FIntf := TIdSoapITIInterface.Create(FITI);
  FIntf.AddMethod(FMethod);
  FIntf.Name := 'I2';
  FIntf.UnitName := 'testunit';
  FIntf.GUID := StringToGUID('{541F9EC1-5DE9-4C4D-87BC-F86B646BB518}');
  FIntf.Ancestor := 'I1';
  FITI.AddInterface(FIntf);
end;

procedure TITITestCases.TestValidation1;
begin
  FITI.Validate('test');
  check(True, 'ITI failed to validate');
end;

procedure TITITestCases.TestValidation2;
var
  FIntf: TIdSoapITIInterface;
begin
  ExpectedException := EAssertionFailed;
  FIntf := TIdSoapITIInterface.Create(FITI);
  FIntf.Name := 'I1';
  FIntf.GUID := StringToGUID('{A1D3E03F-FAA9-4A9E-9CBA-B6F2DFCF57F4}');
  FIntf.Ancestor := 'IIdSoapInterface';
  try
    FITI.AddInterface(FIntf);
  except
    FIntf.Free;
    raise;
    end;
  check(False, 'This test shoudl''ve failed');
end;

procedure TITITestCases.TestValidation3;
begin
  Check(assigned(FITI.FindInterfaceByName('I1')), 'Couldn''t find interface');
  Check(not assigned(FITI.FindInterfaceByName('Ix1')), 'found interface wrongly');
end;

procedure TITITestCases.TestValidation4;
begin
  Check(assigned(FITI.FindInterfaceByGUID(StringToGUID('{541F9EC1-5DE9-4C4D-87BC-F86B646BB518}'))), 'Couldn''t find interface');
  Check(not assigned(FITI.FindInterfaceByGUID(StringToGUID('{541F9EC1-5DE9-4C4D-87BC-F86B646BB5D8}'))), 'found interface wrongly');
end;

end.
