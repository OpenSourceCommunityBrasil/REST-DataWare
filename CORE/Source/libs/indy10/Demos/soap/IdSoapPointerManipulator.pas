{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15754: IdSoapPointerManipulator.pas 
{
{   Rev 1.0    11/2/2003 20:35:24  GGrieve
}
// General pointer manipulation routines to assist in processing RTTI info

{
Version History:
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
   7-Mar 2002   Grahame Grieve                  Review assertions
  28-Feb 2002   Andrew Cumming                  Added a result to IdSoapPtrInc
  15-Feb 2002   Andrew Cumming                  First release
}

Unit IdSoapPointerManipulator;

{$I IdSoapDefines.inc}

interface

Uses
  IdSoapDebug;

Type
  TIdSoapPointerManipulator = Class ( TIdBaseObject )
    private
      FPtr : Pointer;
      function GetAsByte: Byte;
      function GetAsChar: Char;
      function GetAsInteger: Integer;
      function GetAsString: String;
      function GetAsWord: Word;
      procedure SetAsByte(const Value: Byte);
      procedure SetAsChar(const Value: Char);
      procedure SetAsInteger(const Value: Integer);
      procedure SetAsString(const Value: String);
      procedure SetAsWord(const Value: Word);
    function GetAsPointer: pointer;
    procedure SetAsPointer(const Value: pointer);
    public
      Property Ptr: Pointer read FPtr write FPtr;
      Property AsChar: Char read GetAsChar write SetAsChar;
      Property AsByte: Byte read GetAsByte write SetAsByte;
      Property AsWord: Word read GetAsWord write SetAsWord;
      Property AsInteger: Integer read GetAsInteger write SetAsInteger;
      Property AsLongint: Integer read GetAsInteger write SetAsInteger;
      Property AsString: String read GetAsString write SetAsString;
      Property AsPointer: pointer read GetAsPointer write SetAsPointer;
    end;

function IdSoapPtrInc(Var APointer; AValue: Integer = 1): Pointer;

implementation

// increments APointer by AValue bytes and returns the resulting new pointer
function IdSoapPtrInc(var APointer; AValue: Integer): Pointer; assembler;
asm
  add [eax],edx      // nice and fast
  mov eax,[eax]
end;

{ TIdSoapPointerManipulator }

function TIdSoapPointerManipulator.GetAsByte: Byte;
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.GetAsByte';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Result := Byte(FPtr^);
  inc(PChar(FPtr),Sizeof(Byte));
end;

function TIdSoapPointerManipulator.GetAsChar: Char;
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.GetAsChar';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Result := Char(FPtr^);
  inc(PChar(FPtr),Sizeof(Char));
end;

function TIdSoapPointerManipulator.GetAsInteger: Integer;
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.GetAsInteger';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Result := Integer(FPtr^);
  inc(PChar(FPtr),Sizeof(Integer));
end;

function TIdSoapPointerManipulator.GetAsPointer: pointer;
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.GetAsPointer';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Result := Pointer(FPtr^);
  inc(PChar(FPtr),Sizeof(pointer));
end;

function TIdSoapPointerManipulator.GetAsString: String;
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.GetAsString';
Var
  Len : Byte;
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Len := GetAsByte;
  SetLength(Result,Len);
  move(FPtr^,Result[1],Len);
  inc(PChar(FPtr),Len);
end;

function TIdSoapPointerManipulator.GetAsWord: Word;
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.GetAsWord';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Result := Word(FPtr^);
  inc(PChar(FPtr),Sizeof(Word));
end;

procedure TIdSoapPointerManipulator.SetAsByte(const Value: Byte);
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.SetAsByte';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Byte(FPtr^) := Value;
  inc(PChar(FPtr));
end;

procedure TIdSoapPointerManipulator.SetAsChar(const Value: Char);
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.SetAsChar';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Char(FPtr^) := Value;
  inc(PChar(FPtr));
end;

procedure TIdSoapPointerManipulator.SetAsInteger(const Value: Integer);
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.SetAsInteger';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Integer(FPtr^) := Value;
  inc(PChar(FPtr),Sizeof(Integer));
end;

procedure TIdSoapPointerManipulator.SetAsPointer(const Value: pointer);
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.SetAsPointer';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Pointer(FPtr^) := Value;
  inc(PChar(FPtr),Sizeof(pointer));
end;

procedure TIdSoapPointerManipulator.SetAsString(const Value: String);
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.SetAsString';
Var
  Len : Byte;
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Len := Length(Value);
  SetAsByte(Len);
  if Len > 0 then
    begin
    move(Value[1],FPtr^,Len);
    inc(PChar(FPtr),Len);
    end;
end;

procedure TIdSoapPointerManipulator.SetAsWord(const Value: Word);
const ASSERT_LOCATION = 'IdSoapPointerManipulator.TIdSoapPointerManipulator.SetAsWord';
begin
  Assert(self.TestValid(TIdSoapPointerManipulator), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(FPtr), ASSERT_LOCATION+': FPtr is nil');
  Word(FPtr^) := Value;
  inc(PChar(FPtr),Sizeof(Word));
end;

end.
