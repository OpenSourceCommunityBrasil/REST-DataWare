{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16492: Sample3.pas 
{
{   Rev 1.0    25/2/2003 13:41:58  GGrieve
}
{!!}
{0.00-001  17 Jan 02 21:36    User : Grahame Grieve          sync with TestIntfDefn.pas}
{

no unit declaration
}

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

  IIdTestInterface = interface ( IIdSoapInterface )['{F136E09D-85CC-45FC-A525-5322D323E54F}']
    procedure Sample1(ANum : integer); StdCall;
    function Sample2(ANum : integer):Integer; StdCall;
    function Sample3:Integer; StdCall;
    procedure Sample4; StdCall;
    function Sample5(ANum01 : Int64;
                     ANum02 : cardinal;
                     ANum03 : word;
                     ANum04 : byte;
                     ANum05 : double;
                     ACls06 : TTestClass;
                     AStr07 : string;
                     AStr08 : widestring;
                     AStr09 : shortstring;
                 var ANum10 : integer;
                     ANum11 : longint;
               const ANum12 : cardinal;
                 out ANum13 : cardinal;
                     AStr14 : char;
                     AOrd15 : TEnumeration;
                     AOrd16 : boolean;
                     ANum17 : TMyInteger):Integer; StdCall;
    procedure Sample6(ANum : TMyArray; out VNum2 : TMyArray); StdCall;
    function Sample7(ANum : integer):TTestClass; StdCall;
  end;

  IIdTestInterface2 = interface (IIdTestInterface) ['{BE259196-D0CC-41B9-8A4F-6FDAD9011E4D}']
    procedure Sample1B(AStr : string);  stdcall;
  end;

ResourceString KdeVersionMark = {!!uv}'!-!Sample3.pas,0.00-001,17 Jan 02 21:36,13290';
implementation

initialization
  IdSoapRegisterType('TMyInteger', TypeInfo(TMyInteger));
  IdSoapRegisterType('TEnumeration', TypeInfo(TEnumeration));
  IdSoapRegisterType('TTestClass', TypeInfo(TTestClass));
if kdeVersionMark = '' then 
   exit; {never remove this check - see the National Development Manager } 
end.
