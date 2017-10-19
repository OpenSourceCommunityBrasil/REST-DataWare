{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16376: TestIntfImpl.pas 
{
{   Rev 1.0    25/2/2003 13:26:52  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
}
{


This is a sample definition used to test the parser and the SOAP system

Various derivatives of this source are found in the parser subdirectory

DON'T CHANGE THIS!. If you change it, you have to change at least some
of the parser tests, and the structure test in IdSoapTestingUtils

If you want to add more tests, add them to TestIntfDefn2.pas

}

unit TestIntfImpl;

interface

uses
  TestIntfDefn, IdSoapIntfRegistry;

type
  TIdTestInterfaceImpl = Class (TIdSoapBaseImplementation, IIdTestInterface )
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

  TIdTestInterface2Impl = Class (TIdSoapBaseImplementation, IIdTestInterface, IIdTestInterface2)
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
    procedure Sample1B(AStr : string);  stdcall;
  end;

implementation

uses
  IdSoapUtilities,
  SysUtils,
  TestIntfLogic;

{ TIdTestInterfaceImpl }

procedure TIdTestInterfaceImpl.Sample1(ANum: integer);
begin
  ImplSample1(ANum);
end;

function TIdTestInterfaceImpl.Sample2(ANum: integer): Integer;
begin
  result := ImplSample2(ANum);
end;

function TIdTestInterfaceImpl.Sample3: Integer;
begin
  result := ImplSample3;
end;

procedure TIdTestInterfaceImpl.Sample4;
begin
  ImplSample4;
end;

function TIdTestInterfaceImpl.Sample5(ANum01: Int64; ANum02: cardinal;
  ANum03: word; ANum04: byte; ANum05: double; ACls06: TTestClass;
  AStr07: string; AStr08: widestring; AStr09: shortstring;
  var ANum10: integer; ANum11: Integer; const ANum12: cardinal;
  out ANum13: cardinal; AStr14: char; AOrd15: TEnumeration;
  AOrd16: boolean; ANum17: TMyInteger): Integer;
begin
  result := ImplSample5(ANum01, ANum02, ANum03,ANum04,ANum05,ACls06,AStr07,AStr08,AStr09,ANum10, ANum11,ANum12,ANum13,AStr14,AOrd15,AOrd16,ANum17);
end;

procedure TIdTestInterfaceImpl.Sample6(ANum: TMyArray; out VNum2: TMyArray);
begin
  ImplSample6(ANum, VNum2);
end;

function TIdTestInterfaceImpl.Sample7(ANum: integer): TTestClass;
begin
  result := ImplSample7(ANum);
end;

{ TIdTestInterface2Impl }

procedure TIdTestInterface2Impl.Sample1(ANum: integer);
begin
  ImplSample1(ANum);
end;

procedure TIdTestInterface2Impl.Sample1B(AStr: string);
begin
  ImplSample1B(AStr);
end;

function TIdTestInterface2Impl.Sample2(ANum: integer): Integer;
begin
  result := ImplSample2(ANum);
end;

function TIdTestInterface2Impl.Sample3: Integer;
begin
  result := ImplSample3;
end;

procedure TIdTestInterface2Impl.Sample4;
begin
  ImplSample4;
end;

function TIdTestInterface2Impl.Sample5(ANum01: Int64; ANum02: cardinal;
  ANum03: word; ANum04: byte; ANum05: double; ACls06: TTestClass;
  AStr07: string; AStr08: widestring; AStr09: shortstring;
  var ANum10: integer; ANum11: Integer; const ANum12: cardinal;
  out ANum13: cardinal; AStr14: char; AOrd15: TEnumeration;
  AOrd16: boolean; ANum17: TMyInteger): Integer;
begin
  result := ImplSample5(ANum01, ANum02, ANum03,ANum04,ANum05,ACls06,AStr07,AStr08,AStr09,ANum10, ANum11,ANum12,ANum13,AStr14,AOrd15,AOrd16,ANum17);
end;

procedure TIdTestInterface2Impl.Sample6(ANum: TMyArray; out VNum2: TMyArray);
begin
  ImplSample6(ANum, VNum2);
end;

function TIdTestInterface2Impl.Sample7(ANum: integer): TTestClass;
begin
  result := ImplSample7(ANum);
end;

var
   HoldIntf : TIdTestInterface2Impl;

function Factory_TIdTestInterface2Impl(AInterfaceName: String): TInterfacedObject;
begin
  result := HoldIntf;
end;

initialization
  IdSoapRegisterInterfaceClass('IIdTestInterface', TypeInfo(TIdTestInterfaceImpl), TIdTestInterfaceImpl);
  IdSoapRegisterInterfaceFactory('IIdTestInterface2', TypeInfo(TIdTestInterfaceImpl), Factory_TIdTestInterface2Impl);
  HoldIntf := TIdTestInterface2Impl.create;
finalization
  FreeAndNil(HoldIntf);
end.
