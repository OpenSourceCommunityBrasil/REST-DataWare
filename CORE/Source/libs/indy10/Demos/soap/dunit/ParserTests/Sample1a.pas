{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16488: Sample1a.pas 
{
{   Rev 1.0    25/2/2003 13:41:48  GGrieve
}
{!!}
{0.00-001  17 Jan 02 21:36    User : Grahame Grieve          sync with TestIntfDefn.pas}
{

This is a sample definition used to test the parser and the SOAP system

Various derivatives of this source are found in the parser subdirectory

DON'T CHANGE THIS!. If you change it, you have to change at least some
of the parser tests, and the structure test in IdSoapTestingUtils

If you want to add more tests, add them to TestIntfDefn2.pas

}

unit Sample1a;

interface

uses
  IdSoapTypeRegistry;


type
  TTestClass = class (TIdBaseSoapableClass)
  private
    FPropInt : integer;
    FPropString : string;
    FPropClass : TTestClass;
  published
    property PropInt : integer read FPropInt write FPropInt;
    property PropString : string read FPropString write FPropString;
    property PropClass : TTestClass read FPropClass write FPropClass;
  end;

  TMyInteger = type integer;
  TEnumeration = (teOne, teTwo, teThree, teFour);

  IIdTestInterface2 = interface (IIdTestInterface)['{BE259196-D0CC-41B9-8A4F-6FDAD9011E4D}']
    procedure Sample1B(AStr : string);  stdcall;
  end;

ResourceString KdeVersionMark = {!!uv}'!-!Sample1a.pas,0.00-001,17 Jan 02 21:36,13288';
implementation

initialization
  IdSoapRegisterType('TMyInteger', TypeInfo(TMyInteger));
  IdSoapRegisterType('TEnumeration', TypeInfo(TEnumeration));
  IdSoapRegisterType('TTestClass', TypeInfo(TTestClass));
if kdeVersionMark = '' then 
   exit; {never remove this check - see the National Development Manager } 
end.
