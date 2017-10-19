{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16379: TestIntfLogic.pas 
{
{   Rev 1.0    25/2/2003 13:26:58  GGrieve
}
{
IndySOAP: DUnit Tests
}
{
Version History:
   7-Mar 2002   Grahame Grieve                  Total Rewrite of Tests
}

{
this is isolated here so the client can call the tests,
then pass the same info to the server, and compare results

}

unit TestIntfLogic;

interface

uses TestIntfDefn;

procedure ImplSample1(ANum : integer);
function ImplSample2(ANum : integer):Integer;
function ImplSample3:Integer;
procedure ImplSample4;
function ImplSample5(ANum01 : Int64;
                 ANum02 : cardinal;
                 ANum03 : word;
                 ANum04 : byte;
                 ANum05 : double;
                 ACls06 : TTestClass;
                 AStr07 : string;
                 AStr08 : widestring;
                 AStr09 : shortstring;
            var  ANum10 : integer;
                 ANum11 : longint;
           const ANum12 : cardinal;
             out ANum13 : cardinal;
                 AStr14 : char;
                 AOrd15 : TEnumeration;
                 AOrd16 : boolean;
                 ANum17 : TMyInteger):Integer;
procedure ImplSample6(ANum : array of integer; out VNum2 : TMyArray);
function ImplSample7(ANum : integer):TTestClass;
procedure ImplSample1B(AStr : string);

implementation

uses
  IdSoapExceptions,
  SysUtils;

var
  GRandSeed : integer;

 //ok, it's global. but here, if we are careful (and we are) then it will be OK

procedure ImplSample1(ANum : integer);
begin
  if ANum <> 42 then // 42 is the answer!
    raise EIdSoapBadParameterValue.create('Test value was not right');
end;

function ImplSample2(ANum : integer):Integer;
begin
 result := ANum*GRandSeed;
end;


function ImplSample3:Integer;
begin
  result := GRandSeed;
end;

procedure ImplSample4;
begin
  raise EIdUnderDevelopment.create('Testing number is '+inttostr(GRandSeed));
end;

function ImplSample5(ANum01 : Int64;
                 ANum02 : cardinal;
                 ANum03 : word;
                 ANum04 : byte;
                 ANum05 : double;
                 ACls06 : TTestClass;
                 AStr07 : string;
                 AStr08 : widestring;
                 AStr09 : shortstring;
            var  ANum10 : integer;
                 ANum11 : longint;
           const ANum12 : cardinal;
             out ANum13 : cardinal;
                 AStr14 : char;
                 AOrd15 : TEnumeration;
                 AOrd16 : boolean;
                 ANum17 : TMyInteger):Integer;
var i : integer;
begin
  result := ANum01 + ANum02 + ANum03 + ANum04 + trunc(ANum05)+ANum10+ANum11+ANum12;
  ANum13 := result;
  if assigned(ACls06) then
    result := result + ACls06.Result;
  for i := 1 to length(AStr08) do
    result := result + ord(AStr08[i]);
  for i := 1 to length(AStr09) do
    result := result + ord(AStr09[i]);
  result := result + ord(AStr14)+ord(AOrd15);
  if AOrd16 then
    result := result * 2;
  result := result + ANum17;
end;

procedure ImplSample6(ANum : array of integer; out VNum2 : TMyArray);
var i, j, k : integer;
begin
  j := 0;
  for i := low(ANum) to High(ANum) do
    j := j + ANum[i];
  k := j mod 10;
  SetLength(VNum2, k);
  for i := 0 to k - 1 do
    VNum2[i] := (ANum[i] mod k) * i;
end;

function ImplSample7(ANum : integer):TTestClass;
begin
  result := TTestClass.create;
  result.PropInt := ANum;
  result.PropString := inttostr(ANum-1);
  Result.PropClass := TTestClass.create;
  result.PropClass.PropInt := ANum-2;
  result.PropClass.PropString := inttostr(ANum-3);
end;

procedure ImplSample1B(AStr : string);
begin
  if AStr = 'xxxyyz!' then
    raise EIdSoapBadParameterValue.create('Test value was not right');
end;


initialization
  randomize;
  GRandSeed := random(500);
end.
