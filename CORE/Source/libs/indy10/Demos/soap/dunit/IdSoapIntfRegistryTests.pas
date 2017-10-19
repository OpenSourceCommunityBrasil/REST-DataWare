{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16404: IdSoapIntfRegistryTests.pas 
{
{   Rev 1.1    18/3/2003 11:16:00  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:28:04  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  18-Mar 2003   Grahame Grieve                  QName, RawXML, Schema extensibility, Kylix compile fixes
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
}

unit IdSoapIntfRegistryTests;

interface

uses
  TestFramework,
  IdSoapIntfRegistry;

type
  TIntfRegistryTestCases = class(TTestCase)
  Published
    procedure TestNotRegistered;
    procedure CheckRegisteredType;
    procedure TestBadRegistration1;
    procedure TestBadRegistration2;
    procedure TestBadRegistration3;
    procedure TestBadRegistration4;
    procedure TestFactory;
  end;

  TIntfNameRegistryTestCases = class(TTestCase)
  Published
    procedure TestNameNotRegistered;
    procedure TestNameRegistration;
    procedure TestNameRegistrationEmpty;
    procedure TestNameRegistrationDuplicate;
  end;

implementation

uses
  IdGlobal,
  IdSoapExceptions,
  IdSoapITIRttitests,
  IdSoapTypeRegistry,
  SysUtils;

{ TIntfRegistryTestCases }

type
  TTestIntfClass = class(TIdSoapBaseImplementation);


procedure TIntfRegistryTestCases.TestNotRegistered;
begin
  ExpectedException := EIdSoapRequirementFail;
  check(Assigned(IdSoapInterfaceImplementationFactory('IMyTestInterface')), 'this should raise an exception');
end;


procedure TIntfRegistryTestCases.CheckRegisteredType;
var
  LObj : TObject;
begin
  IdSoapRegisterInterfaceClass('IMyTestInterface', TypeInfo(TTestIntfClass), TTestIntfClass);
  LObj := IdSoapInterfaceImplementationFactory('IMyTestInterface');
  try
    check(LObj is TTestIntfClass, 'Implementation factory returned the wrong class');
  finally
    FreeAndNil(LObj);
  end;
end;

procedure TIntfRegistryTestCases.TestBadRegistration1;
begin
  ExpectedException := EAssertionFailed;
  IdSoapRegisterInterfaceClass('IMyTestInterface', TypeInfo(TTestIntfClass), TTestIntfClass);
end;

procedure TIntfRegistryTestCases.TestBadRegistration2;
begin
  ExpectedException := EAssertionFailed;
  IdSoapRegisterInterfaceClass('', TypeInfo(TTestIntfClass), TTestIntfClass);
end;

procedure TIntfRegistryTestCases.TestBadRegistration3;
begin
  ExpectedException := EAssertionFailed;
  IdSoapRegisterInterfaceClass('zxxc', NIL, TTestIntfClass);
end;

procedure TIntfRegistryTestCases.TestBadRegistration4;
begin
  ExpectedException := EAssertionFailed;
  IdSoapRegisterInterfaceClass('xx', TypeInfo(TTestIntfClass), NIL);
end;

function factory(AInterfaceName: String): TInterfacedObject;
begin
  if AInterfaceName = 'IMyTestInterface2' then
    Result := TTestIntfClass.Create
  else
    raise Exception.Create('Wrong name');
end;

procedure TIntfRegistryTestCases.TestFactory;
var
  LObj : TObject;
begin
  IdSoapRegisterInterfaceFactory('IMyTestInterface2', TypeInfo(TTestIntfClass), @factory);
  LObj := IdSoapInterfaceImplementationFactory('IMyTestInterface2');
  try
    check(LObj is TTestIntfClass, 'Implementation factory returned the wrong class');
  finally
    FreeAndNil(LObj);
  end;
end;

type
  IRegTestInterface1 = interface (IIdSoapInterface) ['{9308F377-3AB5-4087-9315-0D2E10C0F5A1}']
    procedure Test;
    procedure TestParams(AParam : integer);
    function  TestFunc(AParam : integer):integer;
  end;


procedure TIntfNameRegistryTestCases.TestNameNotRegistered;
begin
  check(GInterfaceNames.indexof('IRegTestInterface1') = -1, 'Interface not registered but already exists');
end;


procedure TIntfNameRegistryTestCases.TestNameRegistration;
begin
  IdSoapRegisterInterface(TypeInfo(IRegTestInterface1));
  check(GInterfaceNames.indexof('IRegTestInterface1') <> -1, 'Interface not registered but already exists');
end;

procedure TIntfNameRegistryTestCases.TestNameRegistrationDuplicate;
begin
  if GInterfaceNames.indexof('IRegTestInterface1') = -1 then
    begin
    IdSoapRegisterInterface(TypeInfo(IRegTestInterface1));
    end;
  ExpectedException := EAssertionFailed;
  IdSoapRegisterInterface(TypeInfo(IRegTestInterface1));
end;

procedure TIntfNameRegistryTestCases.TestNameRegistrationEmpty;
begin
  ExpectedException := EAssertionFailed;
  IdSoapRegisterInterface(nil);
end;

end.
