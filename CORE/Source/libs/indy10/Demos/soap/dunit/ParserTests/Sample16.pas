{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16518: Sample16.pas 
{
{   Rev 1.0    25/2/2003 13:43:02  GGrieve
}
{!!}
{0.00-001  17 Jan 02 21:36    User : Grahame Grieve          sync with TestIntfDefn.pas}
{
insert comment in token
}
interface

type
  T1 = record
    case integer of
       1 : (
            f1 : integer;
            f2 : integer;
           );
       2:  (
           ord : tEnum{sdf}eration;
           );
    end;

  IIdTestInterface {huh?} = {bad} interface{hu
   h?} ( IIdSoapInterface ) //test
     ['{F136E09D-85CC-45FC-A525-5322D323E54F}'] {sdfsf}
    procedure Sample1(ANum : integer); StdCall;
    function Sample2(ANum : integer):Integer; StdCall;
    function Sample3:Integer; StdCall;
    procedure Sample4; StdCall;   {asdfs}
    function Sample5(ANum01 : Int64;
                     ANum02 : cardinal;
                     ANum03 : word;
                     ANum04 : byte;
                     ANum05 : double;
                     ACls06 : TTestClass;
                     AStr07 : string;
                     AStr08 : widestring;
                     AStr09{sdf} : {df s} shortstring;
                 var ANum10 : integer;
                     ANum11 : longint;
               const ANum12 : cardinal;
                 out ANum13 : cardinal;
                     AStr14 : char;
                     AOrd15 : TEnumeration;
                     AOrd16 : boolean;
                     ANum17 : TMyInteger{sdf}){sdf}:{sdf}Integer{sdf};{sdf}StdCall{sdf};{sdf}
    procedure Sample6(ANum : TMyArray; out{sadf}VNum2 : TMyArray); StdCall;
    function Sample7(ANum : integer)//
                           :TTestClass; StdCall;
  end;

  T1 = record
    case integer of
       1 : record
            f1 : integer;
            f2 : integer;
           end;
    end;

  IIdTestInterface2 = interface (IIdTestInterface) ['{BE259196-D0CC-41B9-8A4F-6FDAD9011E4D}']
    procedure Sample1B(AStr : string);  stdcall;
  end;


