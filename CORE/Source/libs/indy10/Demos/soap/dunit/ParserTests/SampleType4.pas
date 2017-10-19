{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16532: SampleType4.pas 
{
{   Rev 1.0    25/2/2003 13:43:38  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
}

{

Testing The parser reading documentation

}

unit SampleType4;

interface

uses
  IdSoapIntfRegistry,
  IdSoapTypeRegistry;


type
  TTestClass = class(TIdBaseSoapableClass)
  Private
    FPropInt: Integer;
    FPropString: String;
    FPropClass: TTestClass;
  Published
    property PropInt: Integer Read FPropInt Write FPropInt;
    property PropString: String Read FPropString Write FPropString;
    property PropClass: TTestClass Read FPropClass Write FPropClass;
    function Result: Integer;
  end;

  TMyInteger = type Integer;
  TEnumeration = (teOne, teTwo, teThree, teFour);
  TMyArray = array of Integer;

{$M+}
  IIdTestInterface = interface(IIdSoapInterface)
    ['{F136E09D-85CC-45FC-A525-5322D323E54F}']
      {!Namespace: http://www.kestral.com.au/test/namespace-namespace;
        soapACTION: http://sdfsdf/sdfsd.sdf/sdf;
        Type: TTestClass=TestClass in http://www.kestral.com.au/test/namespace/schema;
        Type: TTestClass1=TestClass3
        Type: TTestClass2=in http://www.kestral.com.au/test/namespace/schema;
        Type:
      }
      {&This is a test comment for interface IIdTestInterface.
  This comment is to test the indent

   correction built into the parser}
    procedure Sample1(ANum: integer); StdCall; {!Response: Meth1;Request: Meth2} {&A test comment about Sample1}
    function Sample2(ANum: integer): Integer; StdCall;
    function Sample3: Integer; StdCall;
    procedure Sample4; StdCall;
    function Sample5(ANum01: Int64;
      ANum02: cardinal; {&A Test Comment about ANum02}
      ANum03: word;
      ANum04: byte;
      ANum05: double;
      ACls06: TTestClass;
      AStr07: string;
      AStr08: widestring;
      AStr09: shortstring;
      var ANum10: integer;
      ANum11: longint;
      const ANum12: cardinal;
      out ANum13: cardinal;
      AStr14: char;
      AOrd15: TEnumeration;
      AOrd16: boolean;
      ANum17: TMyInteger): Integer; StdCall; {! Request : Meth3  ;Response:Meth4; SoapAction : http://sdfsdf/sdfsd.sdf/sdf2; }
    procedure Sample6(ANum: TMyArray; out VNum2: TMyArray); StdCall;
    function Sample7(ANum: integer): TTestClass; StdCall;
  end;

  IIdTestInterface2 = interface(IIdTestInterface)
    ['{BE259196-D0CC-41B9-8A4F-6FDAD9011E4D}']
    procedure Sample1B(AStr: string); Stdcall;
  end;

implementation

{ TTestClass }

function TTestClass.Result: Integer;
var
  i: Integer;
begin
  Result := FPropInt;
  for i := 0 to length(FPropString) do
    Result := Result + Ord(FPropString[i]);
  if Assigned(FPropClass) then
    Result := Result + FPropClass.Result;
end;

initialization
  IdSoapRegisterType('TMyInteger', TypeInfo(TMyInteger));
  IdSoapRegisterType('TEnumeration', TypeInfo(TEnumeration), 'TestIntfDefn');
  IdSoapRegisterType('TTestClass', TypeInfo(TTestClass));
  IdSoapRegisterType('TMyArray', TypeInfo(TMyArray), 'TestIntfDefn', TypeInfo(Integer));
end.
