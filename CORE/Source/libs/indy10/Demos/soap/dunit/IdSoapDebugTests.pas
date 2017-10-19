{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16389: IdSoapDebugTests.pas 
{
{   Rev 1.1    19/6/2003 21:35:50  GGrieve
{ Version #1
}
{
{   Rev 1.0    25/2/2003 13:27:24  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  19 Jun 2003   Grahame Grieve                  remove class_tracking
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
}

unit IdSoapDebugTests;

{$I IdSoapDefines.inc}

{$IFNDEF OBJECT_TRACKING}
  Currently, you must have OBJECT_TRACKING defined to run the tests
{$ENDIF}

interface

uses
  TestFramework,
  IdSoapDebug;

type
  TIdSoapDebugTestClass = class (TIdBaseObject)
  end;

  TDebugTestCases = class (TTestCase)
  published
    procedure TestDebug1;
    procedure TestDebug2;
    procedure TestDebug3;
    procedure TestDebug4;
    procedure TestDebug5;
    procedure TestDebug6;
  end;

implementation

{ TDebugTestCases }

var GTest : TIdSoapDebugTestClass;

procedure TDebugTestCases.TestDebug1;
begin
  GTest := nil;
  check(GTest = nil, 'GTest is not nil');
  check(not GTest.TestValid, 'GTest is nil and valid');
end;

procedure TDebugTestCases.TestDebug2;
begin
  GTest := TIdSoapDebugTestClass(Random(20000)+2000);
  check(not GTest.TestValid, 'GTest is random and valid');
end;

procedure TDebugTestCases.TestDebug3;
begin
  GTest := TIdSoapDebugTestClass.create;
  check(GTest.TestValid, 'GTest is created but not valid');
end;

procedure TDebugTestCases.TestDebug4;
begin
  GTest.free;
  check(not GTest.TestValid, 'GTest is still valid after freeing');
end;

procedure TDebugTestCases.TestDebug5;
begin
  check(IdGetThreadObjectCount > 0, 'Thread Object Counting is not working');
end;

procedure TDebugTestCases.TestDebug6;
var c,i:integer;
begin
  c := IdGetThreadObjectCount;
  for i := 0 to 100 do
    begin
    GTest := TIdSoapDebugTestClass.create;
    GTest.free;
    end;
  Check(IdGetThreadObjectCount - c = 0, 'Thread Object Counting didn''t hold it''s value');
end;

end.
