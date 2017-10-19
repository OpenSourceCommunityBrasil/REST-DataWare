{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16447: IDSoapTypeRegistryTests.pas 
{
{   Rev 1.1    19/6/2003 21:36:44  GGrieve
{ Version #1
}
{
{   Rev 1.0    25/2/2003 13:29:50  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  remove redundant names
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  11-Apr 2002   Grahame Grieve                  Update tests for changes to assertion policy
  02-Apr 2002   Grahame Grieve                  Add Context checks
  29-Mar 2002   Grahame Grieve                  Add TIdBaseSoapableClass tests
  26-Mar 2002   Grahame Grieve                  Fix type registration parameter order
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
  05-Feb 2002   Andrew Cumming                  Added D4 support
}

{
This tests Type and Exception registries. Class registry is not developed yet,
so can't be tested
}
unit IDSoapTypeRegistryTests;

interface

Uses
  TestFramework;

type
  TTypeRegistryTestCases = class (TTestCase)
  published
    procedure TestCommonTypes1;
    procedure TestCommonTypes2;
    procedure TestCommonTypes3;
    procedure TestCommonTypes4;
    procedure TestCommonTypes5;
    procedure TestCommonTypes6;
    procedure TestCommonTypes7;
    procedure TestCommonTypes8;
  end;

  TExceptionRegistryTestCases = class (TTestCase)
  published
    procedure TestExceptions1;
    procedure TestExceptions2;
    procedure TestExceptions3;
    procedure TestExceptions4;
  end;

  TIdBaseSoapableClassTestCases = class (TTestCase)
  published
    procedure TestOwnsObjects1;
    procedure TestOwnsObjects2;
    procedure TestOwnsObjects3;
    procedure TestContext;
  end;

implementation

uses
  Classes,
  IdSoapExceptions,
  IdSoapTypeRegistry,
  IdSoapUtilities,
  SysUtils;

{ TRegistryTestCases }

procedure TTypeRegistryTestCases.TestCommonTypes1;
begin
  Check(assigned(IdSoapGetTypeInfo('Integer')), 'Integer type not registered with the type library');
  Check(assigned(IdSoapGetTypeInfo('INTEGER')), 'Case sensitivity in the the library');
  Check(AnsiSameText(IdSoapGetTypeInfo('INTEGER').Name, 'Integer'), 'Integer type name wrong in library');
end;

procedure TTypeRegistryTestCases.TestCommonTypes2;
begin
  ExpectedException := EIdSoapUnknownType;
  Check(not assigned(IdSoapGetTypeInfo('INTEGER1')), 'this raises an exception');
end;

procedure TTypeRegistryTestCases.TestCommonTypes3;
begin
  Check(assigned(IdSoapGetTypeInfo('WideString')), 'WideString type not registered with the type library');
end;

procedure TTypeRegistryTestCases.TestCommonTypes4;
begin
  ExpectedException := EAssertionFailed;
  Check((assigned(IdSoapGetTypeInfo(''))), 'this should raise an exception');
end;

type
   TMyType = integer;

procedure TTypeRegistryTestCases.TestCommonTypes5;
begin
  ExpectedException := EIdSoapUnknownType;
  Check(not assigned(IdSoapGetTypeInfo('TMyType')), 'this raises an exception');
end;

procedure TTypeRegistryTestCases.TestCommonTypes6;
begin
  IdSoapRegisterType(TypeInfo(TMyType), 'TMyType');
  Check(AnsiSameText(IdSoapGetTypeInfo('INTEGER').Name, 'Integer'), 'TMyType not properly registered');
end;

type
  EMyException = class (EIdBaseSoapableException);

procedure TTypeRegistryTestCases.TestCommonTypes7;
begin
  ExpectedException := EAssertionFailed;
  IdSoapRegisterType(TypeInfo(Integer));
end;

procedure TTypeRegistryTestCases.TestCommonTypes8;
begin
  ExpectedException := EAssertionFailed;
  IdSoapRegisterType(nil);
end;

procedure TExceptionRegistryTestCases.TestExceptions1;
begin
  Check(IdExceptionFactory('Server', 'EMyException', 'test') = nil, 'Unknown exception class produced exception - should return nil');
end;

procedure TExceptionRegistryTestCases.TestExceptions2;
begin
  IdRegisterException(EMyException);
  Check(IdExceptionFactory('Server', 'EMyException', 'test') is EMyException, 'EMyException exception class didn''t produce EMyException as exception');
end;

procedure TExceptionRegistryTestCases.TestExceptions3;
begin
  Check(IdExceptionFactory('Server', 'EAssertionFailed', 'test') is EAssertionFailed, 'EAssertionFailed exception class didn''t produce EAssertionFailed as exception');
end;

procedure TExceptionRegistryTestCases.TestExceptions4;
begin
  ExpectedException := EAssertionFailed;
  IdRegisterException(EMyException);
end;

type
  TOwnershipTester = class (TIdBaseSoapableClass)
  private
    FChild: TOwnershipTester;
  published
    property Child : TOwnershipTester read FChild write FChild;
  end;

{ TIdBaseSoapableClassTestCases }

procedure TIdBaseSoapableClassTestCases.TestOwnsObjects1;
var
  o1:TOwnershipTester;
  o2:TOwnershipTester;
begin
  o1 := TOwnershipTester.create;
  check(o1.ClassInfo <> nil);
  o2 := TOwnershipTester.create;
  check(o2.ClassInfo <> nil);
  check(o1.testvalid);
  check(o2.testvalid);
  o1.Child := o2;
  check(o1.testvalid);
  check(o2.testvalid);
  o1.free;
  check(not o1.testvalid);
  check(not o2.testvalid);
end;

procedure TIdBaseSoapableClassTestCases.TestOwnsObjects2;
var
  o1:TOwnershipTester;
  o2:TOwnershipTester;
begin
  o1 := TOwnershipTester.create;
  o2 := TOwnershipTester.create;
  check(o1.testvalid);
  check(o2.testvalid);
  o1.Child := o2;
  o1.OwnsObjects := false;
  check(o1.testvalid);
  check(o2.testvalid);
  o1.free;
  check(not o1.testvalid);
  check(o2.testvalid);
  o2.free;
end;

procedure TIdBaseSoapableClassTestCases.TestOwnsObjects3;
var
  o1:TOwnershipTester;
  o2:TOwnershipTester;
begin
  o1 := TOwnershipTester.create;
  o2 := TOwnershipTester.create;
  try
    check(o1.testvalid);
    check(o2.testvalid);
    o1.Child := o2;
    o2.Child := o1;
    ExpectedException := EIdSoapRequirementFail;
    o1.free;
  finally
    o2.Child := nil;
    o1.free;
  end;
end;

procedure TIdBaseSoapableClassTestCases.TestContext;
var
  o1 : TOwnershipTester;
  o2 : TOwnershipTester;
  o3 : TOwnershipTester;
  o4 : TOwnershipTester;
  ctxt : TIdBaseSoapableClassContext;
begin
  ctxt := TIdBaseSoapableClassContext.create;
  try
    o1 := TOwnershipTester.create;
    check(o1.TestValid);
    check(Ctxt.OwnedObjectCount = 0);
    Ctxt.Attach(o1);
    check(o1.TestValid);
    check(Ctxt.OwnedObjectCount = 1);
    Ctxt.Cleanup;
    check(not o1.TestValid);
    check(Ctxt.OwnedObjectCount = 0);
    o1 := TOwnershipTester.create;
    o2 := TOwnershipTester.create;
    o3 := TOwnershipTester.create;
    o4 := TOwnershipTester.create;
    Ctxt.Attach(o1);
    check(Ctxt.OwnedObjectCount = 1);
    Ctxt.Attach(o2);
    check(Ctxt.OwnedObjectCount = 2);
    Ctxt.Attach(o3);
    check(Ctxt.OwnedObjectCount = 3);
    o3.Free;
    Check(not o3.TestValid);
    check(Ctxt.OwnedObjectCount = 2);
    Ctxt.Attach(o4);
    check(Ctxt.OwnedObjectCount = 3);
    o2.free;
    check(Ctxt.OwnedObjectCount = 2);
    ctxt.Cleanup;
    check(Ctxt.OwnedObjectCount = 0);
    o1 := TOwnershipTester.create;
    o2 := TOwnershipTester.create;
    o3 := TOwnershipTester.create;
    o4 := TOwnershipTester.create;
    Ctxt.Attach(o1);
    Ctxt.Attach(o2);
    Ctxt.Attach(o3);
    Ctxt.Attach(o4);
    check(Ctxt.OwnedObjectCount = 4);
    ctxt.cleanup;
    Check(not o1.TestValid);
    Check(not o2.TestValid);
    Check(not o3.TestValid);
    Check(not o4.TestValid);
    o1 := TOwnershipTester.create;
    o2 := TOwnershipTester.create;
    o3 := TOwnershipTester.create;
    o4 := TOwnershipTester.create;
    Ctxt.Attach(o1);
    check(Ctxt.OwnedObjectCount = 1);
    o1.free;
    check(Ctxt.OwnedObjectCount = 0);
    Ctxt.Attach(o2);
    check(Ctxt.OwnedObjectCount = 1);
    Ctxt.Attach(o3);
    check(Ctxt.OwnedObjectCount = 2);
    o2.free;
    check(Ctxt.OwnedObjectCount = 1);
    Ctxt.Attach(o4);
    check(Ctxt.OwnedObjectCount = 2);
    Ctxt.Cleanup;
  finally
    ctxt.free;
  end;
end;


end.
