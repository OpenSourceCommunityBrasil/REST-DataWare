{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16439: IdSoapRTTITests.pas 
{
{   Rev 1.0    25/2/2003 13:29:28  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  05-Apr 2002   Grahame Grieve                  First written because of a bug in the RTTI TIdSoapPropertyManager
}

unit IdSoapRTTITests;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  TestFramework;

type
  TIdSoapRTTITests = class (TTestCase)
  published
    procedure TestSimpleCase;
    procedure TestSimpleDescendent;
    procedure TestNotSoSimpleDescendent;
    procedure TestSimpleCaseByClass;
    procedure TestSimpleCaseByObject;
  end;

implementation

uses
  IdSoapRTTIHelpers,
  IdSoapTypeRegistry,
  IdSoapUtilities,
  SysUtils;

type
  TSimpleCase = class (TIdBaseSoapableClass)
  private
    FAString: String;
  published
    property AString : String read FAString write FAString;
  end;

  TSimpleDescendent = class (TSimpleCase);

  TNotSoSimpleDescendent = class (TSimpleCase)
  private
    FAString2: String;
  published
    property AString2 : String read FAString2 write FAString2;
  end;


{ TIdSoapRTTITests }

procedure TIdSoapRTTITests.TestSimpleCase;
var
  LPropMan : TIdSoapPropertyManager;
begin
  LPropMan := TIdSoapPropertyManager.create(TypeInfo(TSimpleCase));
  try
    Check(LPropMan.TestValid(TIdSoapPropertyManager));
    Check(LPropMan.Count = 1);
    Check(LPropMan.Properties[1].Name = 'AString');
    Check(LPropMan.Properties[1].PropType^^.Name = 'String');
  finally
    FreeAndNil(LPropMan);
  end;
end;

procedure TIdSoapRTTITests.TestSimpleDescendent;
var
  LPropMan : TIdSoapPropertyManager;
begin
  LPropMan := TIdSoapPropertyManager.create(TypeInfo(TSimpleDescendent));
  try
    Check(LPropMan.TestValid(TIdSoapPropertyManager));
    Check(LPropMan.Count = 1);
    Check(LPropMan.Properties[1].Name = 'AString');
    Check(LPropMan.Properties[1].PropType^^.Name = 'String');
  finally
    FreeAndNil(LPropMan);
  end;
end;

procedure TIdSoapRTTITests.TestNotSoSimpleDescendent;
var
  LPropMan : TIdSoapPropertyManager;
begin
  LPropMan := TIdSoapPropertyManager.create(TypeInfo(TNotSoSimpleDescendent));
  try
    Check(LPropMan.TestValid(TIdSoapPropertyManager));
    Check(LPropMan.Count = 2);
    Check(LPropMan.Properties[1].Name = 'AString');
    Check(LPropMan.Properties[1].PropType^^.Name = 'String');
    Check(LPropMan.Properties[2].Name = 'AString2');
    Check(LPropMan.Properties[2].PropType^^.Name = 'String');
  finally
    FreeAndNil(LPropMan);
  end;
end;


procedure TIdSoapRTTITests.TestSimpleCaseByClass;
var
  LPropMan : TIdSoapPropertyManager;
begin
  LPropMan := TIdSoapPropertyManager.create(TSimpleCase.ClassInfo);
  try
    Check(LPropMan.TestValid(TIdSoapPropertyManager));
    Check(LPropMan.Count = 1);
    Check(LPropMan.Properties[1].Name = 'AString');
    Check(LPropMan.Properties[1].PropType^^.Name = 'String');
  finally
    FreeAndNil(LPropMan);
  end;
end;

procedure TIdSoapRTTITests.TestSimpleCaseByObject;
var
  LPropMan : TIdSoapPropertyManager;
  LCase : TSimpleCase;
begin
  LCase := TSimpleCase.create;
  try
    LPropMan := TIdSoapPropertyManager.create(LCase.ClassInfo);
    try
      Check(LPropMan.TestValid(TIdSoapPropertyManager));
      Check(LPropMan.Count = 1);
      Check(LPropMan.Properties[1].Name = 'AString');
      Check(LPropMan.Properties[1].PropType^^.Name = 'String');
      Check(LPropMan.AsAnsiString[LCase, 1] = '');
      LPropMan.AsAnsiString[LCase, 1] := 'test';
      Check(LPropMan.AsAnsiString[LCase, 1] = 'test');
      Check(LCase.AString = 'test');
    finally
      FreeAndNil(LPropMan);
    end;
  finally
    FreeAndNil(LCase);
  end;
end;

end.
