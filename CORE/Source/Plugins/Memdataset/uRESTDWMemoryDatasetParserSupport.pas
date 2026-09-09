Unit uRESTDWMemoryDatasetParserSupport;

// parse support

{$I uRESTDW.inc}
{$DEFINE RESTDW_SUPPORT_INT64}

Interface

Uses
  Classes;

Type

  {TRESTDWMemOCollection interfaces between OWL TCollection and VCL TList}

  TRESTDWMemOCollection = Class(TList)
  Public
    Procedure AtFree(Index: Integer);
    Procedure FreeAll;
    Procedure DoFree(Item: Pointer);
    Procedure FreeItem(Item: Pointer); virtual;
    Destructor Destroy; override;
  End;

  TRESTDWMemNoOwnerCollection = Class(TRESTDWMemOCollection)
  Public
    Procedure FreeItem(Item: Pointer); override;
  End;

  { TRESTDWMemSortedCollection object }

  TRESTDWMemSortedCollection = Class(TRESTDWMemOCollection)
  Public
    Function Compare(Key1, Key2: Pointer): Integer; virtual; abstract;
    Function IndexOf(Item: Pointer): Integer; virtual;
    Procedure Add(Item: Pointer); virtual;
    Procedure AddReplace(Item: Pointer); virtual;
    Procedure AddList(Source: TList; FromIndex, ToIndex: Integer);
    {if duplicate then replace the duplicate else add}
    Function KeyOf(Item: Pointer): Pointer; virtual;
    Function Search(Key: Pointer; Var Index: Integer): Boolean; virtual;
  End;

  { TRESTDWMemStrCollection object }

  TRESTDWMemStrCollection = Class(TRESTDWMemSortedCollection)
  Public
    Function Compare(Key1, Key2: Pointer): Integer; override;
    Procedure FreeItem(Item: Pointer); override;
  End;

Function GetStrFromInt(Val: Integer; Const Dst: PChar): Integer;
Procedure GetStrFromInt_Width(Val: Integer; Const Width: Integer; Const Dst: PChar; Const PadChar: Char);
{$IFDEF RESTDW_SUPPORT_INT64}
Function  GetStrFromInt64(Val: Int64; Const Dst: PChar): Integer;
Procedure GetStrFromInt64_Width(Val: Int64; Const Width: Integer; Const Dst: PChar; Const PadChar: Char);
{$ENDIF}

Implementation

Uses SysUtils;

Destructor TRESTDWMemOCollection.Destroy;
Begin
 FreeAll;
 Inherited Destroy;
End;

Procedure TRESTDWMemOCollection.AtFree(Index: Integer);
Var
 Item: Pointer;
Begin
 Item := Items[Index];
 Delete(Index);
 FreeItem(Item);
End;


Procedure TRESTDWMemOCollection.FreeAll;
Var
 I: Integer;
Begin
 Try
 For I := 0 To Count - 1 Do
  FreeItem(Items[I]);
 Finally
 Count := 0;
End;
End;

Procedure TRESTDWMemOCollection.DoFree(Item: Pointer);
Begin
 AtFree(IndexOf(Item));
End;

Procedure TRESTDWMemOCollection.FreeItem(Item: Pointer);
Begin
 If (Item <> nil) Then
 With TObject(Item) as TObject Do
  Free;
End;

{----------------------------------------------------------------virtual;
 Implementing TRESTDWMemNoOwnerCollection
 -----------------------------------------------------------------}

Procedure TRESTDWMemNoOwnerCollection.FreeItem(Item: Pointer);
Begin
End;

{ TRESTDWMemSortedCollection }

Function TRESTDWMemSortedCollection.IndexOf(Item: Pointer): Integer;
Var
 I: Integer;
Begin
 IndexOf := -1;
 If Search(KeyOf(Item), I) Then
  Begin
   While (I < Count) and (Item <> Items[I]) Do
   Inc(I);
   If I < Count Then
    IndexOf := I;
  End;
End;

Procedure TRESTDWMemSortedCollection.AddReplace(Item: Pointer);
Var
 Index: Integer;
Begin
 If Search(KeyOf(Item), Index) Then
 Delete(Index);
 Add(Item);
End;

Procedure TRESTDWMemSortedCollection.Add(Item: Pointer);
Var
 I: Integer;
Begin
 Search(KeyOf(Item), I);
 Insert(I, Item);
End;

Procedure TRESTDWMemSortedCollection.AddList(Source: TList; FromIndex, ToIndex: Integer);
Var
 I: Integer;
Begin
 For I := FromIndex To ToIndex Do
 Add(Source.Items[I]);
End;

Function TRESTDWMemSortedCollection.KeyOf(Item: Pointer): Pointer;
Begin
 Result := Item;
End;

Function TRESTDWMemSortedCollection.Search(Key: Pointer; Var Index: Integer): Boolean;
Var
 L, H, I, C: Integer;
Begin
 Result := false;
 L := 0;
 H := Count - 1;
 While L <= H Do
  Begin
   I := (L + H) div 2;
   C := Compare(KeyOf(Items[I]), Key);
   If C < 0 Then
   L := I + 1
   Else Begin
   H := I - 1;
   Result := C = 0;
  End;
End;
 Index := L;
End;

{ TRESTDWMemStrCollection }

Function TRESTDWMemStrCollection.Compare(Key1, Key2: Pointer): Integer;
Begin
 Compare := StrComp(PChar(Key1), PChar(Key2));
End;

Procedure TRESTDWMemStrCollection.FreeItem(Item: Pointer);
Begin
 StrDispose(PChar(Item));
End;

// it seems there is no pascal function to convert an integer into a PChar???


Function GetStrFromInt(Val: Integer; Const Dst: PChar): Integer;
Var
 Temp: array[0..10] Of Char;
 I, J: Integer;
Begin
 Val := Abs(Val);
 // we'll have to store characters backwards first
 I := 0;
 J := 0;
 Repeat
 Temp[I] := Chr((Val mod 10) + Ord('0'));
 Val := Val div 10;
 Inc(I);
 Until Val = 0;

 // remember number of digits
 Result := I;
 // copy value, remember: stored backwards
 Repeat
 Dst[J] := Temp[I-1];
 Inc(J);
 Dec(I);
 Until I = 0;
 // done!
End;

// it seems there is no pascal function to convert an integer into a PChar???

Procedure GetStrFromInt_Width(Val: Integer; Const Width: Integer; Const Dst: PChar; Const PadChar: Char);
Var
 Temp: array[0..10] Of Char;
 I, J: Integer;
 NegSign: boolean;
Begin
 NegSign := Val < 0;
 If NegSign Then
 Val := -Val;

 I := 0;
 Repeat
 Temp[I] := Chr((Val mod 10) + Ord('0'));
 Val := Val div 10;
 Inc(I);
 Until Val = 0;

 J := 0;
 While J < Width - I - Ord(NegSign) Do
  Begin
   Dst[J] := PadChar;
   Inc(J);
  End;

 If NegSign Then
  Begin
   Dst[J] := '-';
   Inc(J);
  End;

 Repeat
 Dst[J] := Temp[I - 1];
 Inc(J);
 Dec(I);
 Until I = 0;
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure GetStrFromInt64_Width(Val: Int64; Const Width: Integer; Const Dst: PChar; Const PadChar: Char);
Var
 Temp: array[0..19] Of Char;
 I, J: Integer;
 NegSign: boolean;
Begin
 NegSign := Val < 0;
 If NegSign Then
 Val := -Val;

 I := 0;
 Repeat
 Temp[I] := Chr((Val mod 10) + Ord('0'));
 Val := Val div 10;
 Inc(I);
 Until Val = 0;

 J := 0;
 While J < Width - I - Ord(NegSign) Do
  Begin
   Dst[J] := PadChar;
   Inc(J);
  End;

 If NegSign Then
  Begin
   Dst[J] := '-';
   Inc(J);
  End;

 Repeat
 Dst[J] := Temp[I - 1];
 Inc(J);
 Dec(I);
 Until I = 0;
End;

Function GetStrFromInt64(Val: Int64; Const Dst: PChar): Integer;
Var
 Temp: array[0..19] Of Char;
 I, J: Integer;
Begin
 Val := Abs(Val);
 // we'll have to store characters backwards first
 I := 0;
 J := 0;
 Repeat
 Temp[I] := Chr((Val mod 10) + Ord('0'));
 Val := Val div 10;
 Inc(I);
 Until Val = 0;

 // remember number of digits
 Result := I;
 // copy value, remember: stored backwards
 Repeat
 Dst[J] := Temp[I-1];
 inc(J);
 dec(I);
 Until I = 0;
 // done!
End;

{$ENDIF}

End.
