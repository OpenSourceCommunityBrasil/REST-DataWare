unit StringBuilderUnit;

interface

const
  StringBuilderMemoryBlockLength = 1000;

Type
  PStringBuilderMemoryBlock = ^TStringBuilderMemoryBlock;
  TStringBuilderMemoryBlock = Record
    Data  : Array[0..StringBuilderMemoryBlockLength - 1] of Byte;
    Count : Cardinal;
    Next  : PStringBuilderMemoryBlock;
  end;
  { TStringBuilder }
  TStringBuilder = class
  Protected
   FHead,
   FTail : PStringBuilderMemoryBlock;
   FTotalLength: Cardinal;
   Function Min(const a, b: Cardinal): Cardinal;
  Public
   Constructor Create;
   Destructor  Destroy; Override;
   Procedure   Add(Const aString  : String);Overload;
   Procedure   Add(Const aStrings : Array Of String);Overload;
   Function    ToString : String;
   Procedure   Clean;
   Property    Head        : PStringBuilderMemoryBlock Read FHead;
   Property    Tail        : PStringBuilderMemoryBlock Read FTail;
   Property    TotalLength : Cardinal                  Read FTotalLength;
  end;

implementation

function CreateNewBlock: PStringBuilderMemoryBlock;
begin
  New(result);
  result^.Count := 0;
  result^.Next := nil;
end;

{ TStringBuilder }

function TStringBuilder.Min(const a, b: Cardinal): Cardinal;
begin
  if
    a < b
  then
    result := a
  else
    result := b;
end;

constructor TStringBuilder.Create;
begin
  FHead := nil;
  FTail := nil;
  FTotalLength := 0;
end;

procedure TStringBuilder.Add(const aString : string);
Var
 bytesLeftInString,
 bytesToWriteInCurrentBlock,
 bytesLeftInTailBlock : Cardinal;
 positionInString     : PChar;
Begin
 If Head = Nil Then
  Begin
   FHead := CreateNewBlock;
   FTail := Head;
  End;
 bytesLeftInString := Length(aString);
 Inc(FTotalLength, bytesLeftInString);
 positionInString := PChar(aString);
 While bytesLeftInString > 0 Do
  Begin
   bytesLeftInTailBlock       := StringBuilderMemoryBlockLength - Tail^.Count;
   bytesToWriteInCurrentBlock := Min(bytesLeftInString, bytesLeftInTailBlock);
   Move(positionInString^, Tail^.Data[Tail^.Count], bytesToWriteInCurrentBlock);
   Inc(Tail^.Count, bytesToWriteInCurrentBlock);
   Dec(bytesLeftInString, bytesToWriteInCurrentBlock);
   Inc(positionInString,  bytesToWriteInCurrentBlock);
   If bytesLeftInString > 0 Then
    Begin
     Tail^.Next := CreateNewBlock;
     FTail := Tail^.Next;
    End;
  End;
End;

procedure TStringBuilder.Add(const aStrings: array of string);
var
  i: Cardinal;
begin
  for i := 0 to Length(aStrings) - 1 do
    Add(aStrings[i]);
end;

function TStringBuilder.ToString: string;
var
  currentBlock: PStringBuilderMemoryBlock;
  currentCount: Cardinal;
  currentResultPosition: PChar;
begin
 If Head <> Nil Then
  Begin
   SetLength(result, Totallength);
   currentResultPosition := PChar(Result);
   currentBlock := Head;
   While currentBlock <> nil do
    begin
      currentCount := currentBlock^.Count;
      Move(currentBlock^.Data[0], currentResultPosition^, currentCount);
      Inc(currentResultPosition, currentCount);
      currentBlock := currentBlock^.Next;
    end;
    currentResultPosition^ := #0;
  end
  else
    result := '';
end;

procedure TStringBuilder.Clean;
var
  current, next: PStringBuilderMemoryBlock;
begin
  current := Head;
  while
    current <> nil
  do
  begin
    next := current^.Next;
    Dispose(current);
    current := next;
  end;
  FHead := nil;
  FTail := nil;
  FTotalLength := 0;
end;

destructor TStringBuilder.Destroy;
begin
  Clean;
  inherited Destroy;
end;

end.

