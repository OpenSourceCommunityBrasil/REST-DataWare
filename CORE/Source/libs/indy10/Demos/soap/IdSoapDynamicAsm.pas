{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15720: IdSoapDynamicAsm.pas 
{
{   Rev 1.1    20/6/2003 00:03:08  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:33:06  GGrieve
}
{
IndySOAP: Dynamic Machine code generation
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Range check fix
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  14-Apr 2002   Andrew Cumming                  Added code for Kylix PIC
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
   7-Mar 2002   Grahame Grieve                  Add IdGlobal again
   7-Mar 2002   Grahame Grieve                  Review assertions
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapDynamicAsm;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapDebug;

type
  TIdSoapDynamicAsm = class(TIdBaseObject)
  Private
    FStream: TMemoryStream;
    function GetCurrentAdr: Pointer;
  Public
    constructor Create;
    destructor Destroy; Override;
    procedure Clear;
    procedure PutMem(var AData; ALen: Integer);
    procedure PutByte(AByte: Byte);
    procedure PutWord(AWord: Word);
    procedure PutInteger(AInteger: Integer);
    procedure PutCardinal(ACardinal: Cardinal);
    procedure PutPointer(APointer: Pointer);
    procedure AsmFarCall(Adr: Pointer);
    function  AsmPushInt(AInteger: Integer): Integer;
    procedure AsmPushCardinal(ACardinal: Cardinal);
    procedure AsmPushInt64(AInt64: Int64);
    procedure AsmPushSingle(ASingle: Single);  // Extended is 10 bytes so is passed on the stack not by register
    procedure AsmPushDouble(ADouble: Double);
    procedure AsmPushComp(AComp: Comp);
    procedure AsmPushCurrency(ACurrency: Currency);
    procedure AsmPushExtended(AExtended: Extended);
    procedure AsmAddSp(ANum: Integer);
    procedure AsmPushEbp;
    procedure AsmMovEbpEsp;
    procedure AsmMovEspEbp;
    procedure AsmPopEbp;
    procedure PatchInt(AOffset,AValue: Integer);
    procedure AsmPushPtr(APtr: Pointer);
    procedure AsmRet(ABytesToPop: Word);
    function Execute(AOffset: Integer): Int64;
    property CurrentAdr: Pointer Read GetCurrentAdr;
  end;

implementation

uses
  IdSoapUtilities,
  SysUtils;

constructor TIdSoapDynamicAsm.Create;
begin
  inherited;
  FStream := TMemoryStream.Create;
end;

destructor TIdSoapDynamicAsm.Destroy;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.Destroy';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FStream);
  inherited;
end;

procedure TIdSoapDynamicAsm.Clear;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.Clear';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  FStream.Clear;
end;

function TIdSoapDynamicAsm.GetCurrentAdr: Pointer;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.GetCurrentAdr:';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  Result := NIL;
end;

procedure TIdSoapDynamicAsm.PutMem(var AData; ALen: Integer);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.PutMem';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  FStream.Write(AData, ALen);
end;

procedure TIdSoapDynamicAsm.PutByte(AByte: Byte);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.PutByte';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutMem(AByte, Sizeof(AByte));
end;

procedure TIdSoapDynamicAsm.PutWord(AWord: Word);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.PutWord';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutMem(AWord, Sizeof(AWord));
end;

procedure TIdSoapDynamicAsm.PutInteger(AInteger: Integer);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.PutInteger';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutMem(AInteger, Sizeof(AInteger));
end;

procedure TIdSoapDynamicAsm.PutCardinal(ACardinal: Cardinal);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.PutCardinal';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutMem(ACardinal, Sizeof(ACardinal));
end;

procedure TIdSoapDynamicAsm.PutPointer(APointer: Pointer);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.PutPointer';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutMem(APointer, Sizeof(APointer));
end;

// the second param is for Kylix2 exception handling code generation
procedure TIdSoapDynamicAsm.AsmFarCall(Adr: Pointer);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmFarCall';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutWord($15ff);   // reversed for word  (FAR CALL)
  PutMem(Adr, Sizeof(Adr));
end;

procedure TIdSoapDynamicAsm.AsmAddSp(ANum: Integer);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmAddSp';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  Assert((ANum >= 0) and (ANum <= 127), ASSERT_LOCATION+': Value is untested');
  PutWord($c483);  // reversed for word
  PutByte(ANum);
end;

function TIdSoapDynamicAsm.AsmPushInt(AInteger: Integer): Integer;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushInt';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  result := FStream.Position;
  if (AInteger >= -128) and (AInteger <= 127) then
    begin
    PutByte($6A);
    PutByte(AInteger);
    end
  else
    begin
    PutByte($68);
    PutInteger(AInteger);
    end;
end;

procedure TIdSoapDynamicAsm.AsmPushCardinal(ACardinal: Cardinal);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushCardinal';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  if (ACardinal >= $ffffff80) and (ACardinal <= 127) then
    begin
    PutByte($6A);
    PutByte(ACardinal);
    end
  else
    begin
    PutByte($68);
    PutCardinal(ACardinal);
    end;
end;

procedure TIdSoapDynamicAsm.AsmPushInt64(AInt64: Int64);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushInt64';
type
  TMap = record
    case Byte of
      0: (AInt64: Int64);
      1: (ACard1: Cardinal;
        ACard2: Cardinal;
    );
  end;
var
  LMap: TMap Absolute AInt64;
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  AsmPushCardinal(LMap.ACard2);  // push LSC
  AsmPushCardinal(LMap.ACard1);  // push MSC
end;

procedure TIdSoapDynamicAsm.AsmPushSingle(ASingle: Single);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushSingle';
var
  LCardinal: Cardinal Absolute ASingle;  // there the same size and cardinal is easier to work with
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  AsmPushCardinal(LCardinal);
end;

procedure TIdSoapDynamicAsm.AsmPushDouble(ADouble: Double);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushDouble';
var
  LInt64: Int64 Absolute ADouble;  // there the same size and Int64 is easier to work with
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  AsmPushInt64(LInt64);
end;

procedure TIdSoapDynamicAsm.AsmPushComp(AComp: Comp);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushComp';
var
  LInt64: Int64 Absolute AComp;  // there the same size and Int64 is easier to work with
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  AsmPushInt64(LInt64);
end;

procedure TIdSoapDynamicAsm.AsmPushCurrency(ACurrency: Currency);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushCurrency';
var
  LInt64: Int64 Absolute ACurrency;  // there the same size and Int64 is easier to work with
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  AsmPushInt64(LInt64);
end;

procedure TIdSoapDynamicAsm.AsmPushExtended(AExtended: Extended);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushExtended';
var
  LData: array[1..3] of Cardinal Absolute AExtended;
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  AsmPushCardinal(LData[3]);
  AsmPushCardinal(LData[2]);
  AsmPushCardinal(LData[1]);
end;

procedure TIdSoapDynamicAsm.AsmPushEbp;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushCardinal';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutByte($55);
end;

procedure TIdSoapDynamicAsm.AsmMovEbpEsp;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmMovEbpEsp';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutWord($ec8b);
end;

procedure TIdSoapDynamicAsm.AsmMovEspEbp;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmMovEspEbp';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutWord($e58b);
end;

procedure TIdSoapDynamicAsm.AsmPopEbp;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPopEbp';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  PutByte($5d);
end;

procedure TIdSoapDynamicAsm.PatchInt(AOffset,AValue: Integer);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.PatchInt';
var
  LStreamPos: Integer;
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  Assert(AOffset+sizeof(Integer)<=FStream.Size, ASSERT_LOCATION+': Invalid patch location');
  LStreamPos := FStream.Position;
  try
    FStream.Position := AOffset;
    FStream.Write(AValue,sizeof(Integer));
  finally
    FStream.Position := LStreamPos;
    end;
end;

procedure TIdSoapDynamicAsm.AsmPushPtr(APtr: Pointer);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmPushPtr';
var
  LCardinal: Cardinal Absolute APtr;
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  if (LCardinal >= $ffffff80) and (LCardinal <= 127) then
    begin
    PutByte($6A);
    PutByte(LCardinal);
    end
  else
    begin
    PutByte($68);
    PutCardinal(LCardinal);
    end;
end;


procedure TIdSoapDynamicAsm.AsmRet(ABytesToPop: Word);
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.AsmRet';
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  if ABytesToPop = 0 then
    begin
    PutByte($c3);
    end
  else
    begin
    PutByte($c2);
    PutWord(ABytesToPop);
    end;
end;

function TIdSoapDynamicAsm.Execute(AOffset: Integer): Int64;
Const ASSERT_LOCATION = 'IdSoapDynamicAsm.TIdSoapDynamicAsm.Execute';
var
  LPtr: Pointer;
begin
  Assert(Self.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': self is not valid');
  LPtr := PChar(FStream.Memory) + AOffset;
  asm
    mov  edx,LPtr
    call edx
    mov dword ptr[Result],eax    // most results will only use EAX
    mov dword ptr[Result+4],edx  // but some use EAX and EDX
    end;
end;


end.
