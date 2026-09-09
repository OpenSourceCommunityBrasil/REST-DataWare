unit uRESTDWJSONInterface;

{$I uRESTDW.inc}

interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

{$IFDEF FPC}
 {$DEFINE RESTDWLEGACYJSON}
{$ENDIF}
{$IFNDEF FPC}
 {$IFNDEF DELPHIXE7UP}
  {$DEFINE RESTDWLEGACYJSON}
 {$ENDIF}
{$ENDIF}

Uses
  SysUtils, Classes, Variants,
  {$IFDEF RESTDWLEGACYJSON}
  uRESTDWJSON,
  {$ELSE}
  System.JSON,
  {$ENDIF}
  uRESTDWConsts;

Type
  TElementType = (etObject, etArray, etString, etNumeric, etBoolean);

  TJSONBaseClass = Class
  End;

  TJSONBaseObjectClass = Class
  Private
    vJSONObject: TJSONBaseClass;
    Function GetObject: TJSONObject;
    Procedure SetObject(Value: TJSONObject);
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Property JSONObject: TJSONObject Read GetObject Write SetObject;
  End;

  TJSONBaseArrayClass = Class
  Private
    vJSONObject: TJSONBaseClass;
    Function GetObject: TJSONArray;
    Procedure SetObject(Value: TJSONArray);
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Property JSONObject: TJSONArray Read GetObject Write SetObject;
  End;

  TRESTDWJSONPair = Packed Record
    isnull: Boolean;
    ClassName, Name, Value: String;
  End;

  TRESTDWJSONInterfaceBase = Class(TJSONBaseObjectClass)
  Public
    Constructor Create(ParentJSON: TJSONBaseClass);
    Destructor Destroy; Override;
    Function PairCount: Integer;
  End;

  TRESTDWJSONValueInterface = Class(TRESTDWJSONInterfaceBase)
  Private
    Function GetPair(Index: Integer): TRESTDWJSONPair;
    Procedure PutPair(Index: Integer; Value: TRESTDWJSONPair);
  Public
    Property Pair[Index: Integer]: TRESTDWJSONPair Read GetPair Write PutPair;
  End;

  TRESTDWJSONInterfaceArray = Class(TJSONBaseArrayClass)
  Public
    Function ElementCount: Integer;
    Function GetObject(Index: Integer): TRESTDWJSONInterfaceBase;
    Function ToJSON: String;
    Constructor Create;
    Destructor Destroy; Override;
  End;

  TRESTDWJSONInterfaceObject = Class(TJSONBaseObjectClass)
  Private
    Function GetPair(Index: Integer): TRESTDWJSONPair; Overload;
    Function GetPairN(Index: String): TRESTDWJSONPair; Overload;
    Procedure PutPair(Index: Integer; Item: TRESTDWJSONPair); Overload;
    Procedure PutPairN(Index: String; Item: TRESTDWJSONPair); Overload;
  Public
    Constructor Create(JSONValue: String); Overload;
    Destructor Destroy; Override;
    Function PairCount: Integer;
    Function ToJSON: String;
    Function ClassType: TClass;
    Function OpenArray(Key: String): TRESTDWJSONInterfaceArray; Overload;
    Function OpenArray(Index: Integer): TRESTDWJSONInterfaceArray; Overload;
    Property Pairs[Index: Integer]: TRESTDWJSONPair Read GetPair Write PutPair;
    Property PairByName[Index: String]: TRESTDWJSONPair Read GetPairN Write PutPairN;
  End;

implementation

Function EmptyPair: TRESTDWJSONPair;
Begin
  Result.isnull := True;
  Result.ClassName := '';
  Result.Name := '';
  Result.Value := '';
End;

Function FirstJSONChar(Const Value: String): Char;
Var
  I: Integer;
Begin
  Result := #0;
  For I := 1 To Length(Value) Do
   Begin
    If Value[I] > ' ' Then
     Begin
      Result := Value[I];
      Exit;
     End;
   End;
End;

{$IFDEF RESTDWLEGACYJSON}

Function LegacyValueToJSON(Value: TZAbstractObject): String;
Begin
  Result := '';
  If Value = Nil Then
    Exit;
  Result := Value.toString;
End;

Function LegacyValueIsNull(Value: TZAbstractObject): Boolean;
Begin
  Result := (Value = Nil) Or (Value = CNULL) Or (Value is NULL);
End;

Function LegacyCloneValue(Value: TZAbstractObject): TJSONBaseClass;
Var
  S: String;
  C: Char;
Begin
  Result := Nil;
  If LegacyValueIsNull(Value) Then
    Exit;
  S := Value.toString;
  C := FirstJSONChar(S);
  If C = '{' Then
    Result := TJSONBaseClass(TJSONObject.Create(S))
  Else If C = '[' Then
    Result := TJSONBaseClass(TJSONArray.Create(S))
  Else If Value is _String Then
    Result := TJSONBaseClass(_String(Value).Clone)
  Else
    Result := TJSONBaseClass(Value.Clone);
End;

Function LegacyObjectNameAt(AObject: TJSONObject; Index: Integer): String;
Var
  Names: TJSONArray;
Begin
  Result := '';
  If (AObject = Nil) Or (Index < 0) Then
    Exit;
  Names := AObject.names;
  Try
    If (Names <> Nil) And (Index < Names.length) Then
      Result := Names.Get(Index).toString;
  Finally
    Names.Free;
  End;
End;

Function LegacyPairFromValue(Const AName: String;
  Value: TZAbstractObject): TRESTDWJSONPair;
Begin
  Result := EmptyPair;
  Result.Name := AName;
  If LegacyValueIsNull(Value) Then
   Begin
    Result.ClassName := 'TJSONValue';
    Exit;
   End;
  Result.ClassName := Value.ClassName;
  Result.Value := LegacyValueToJSON(Value);
  Result.isnull := False;
End;

{$ELSE}

Function NativeValueIsNull(Value: TJSONValue): Boolean;
Begin
  Result := (Value = Nil) Or (Value is TJSONNull);
End;

Function NativeValueText(Value: TJSONValue): String;
Begin
  Result := '';
  If Value = Nil Then
    Exit;
  If (Value is TJSONObject) Or (Value is TJSONArray) Then
    Result := Value.ToJSON
  Else If Value is TJSONNull Then
    Result := ''
  Else
    Result := Value.Value;
End;

Function NativeCloneValue(Value: TJSONValue): TJSONBaseClass;
Var
  Parsed: TJSONValue;
Begin
  Result := Nil;
  If NativeValueIsNull(Value) Then
    Exit;
  Parsed := TJSONObject.ParseJSONValue(Value.ToJSON);
  If Parsed <> Nil Then
    Result := TJSONBaseClass(Parsed);
End;

Function NativePairFromValue(Const AName: String;
  Value: TJSONValue): TRESTDWJSONPair;
Begin
  Result := EmptyPair;
  Result.Name := AName;
  If NativeValueIsNull(Value) Then
   Begin
    Result.ClassName := 'TJSONValue';
    Exit;
   End;
  Result.ClassName := Value.ClassName;
  Result.Value := NativeValueText(Value);
  Result.isnull := False;
End;

{$ENDIF}

Constructor TJSONBaseObjectClass.Create;
Begin
  Inherited Create;
  vJSONObject := Nil;
End;

Destructor TJSONBaseObjectClass.Destroy;
Begin
  If vJSONObject <> Nil Then
    FreeAndNil(vJSONObject);
  Inherited;
End;

Function TJSONBaseObjectClass.GetObject: TJSONObject;
Begin
  Result := TJSONObject(vJSONObject);
End;

Procedure TJSONBaseObjectClass.SetObject(Value: TJSONObject);
Begin
  If Pointer(vJSONObject) = Pointer(Value) Then
    Exit;
  If vJSONObject <> Nil Then
    FreeAndNil(vJSONObject);
  vJSONObject := TJSONBaseClass(Value);
End;

Constructor TJSONBaseArrayClass.Create;
Begin
  Inherited Create;
  vJSONObject := Nil;
End;

Destructor TJSONBaseArrayClass.Destroy;
Begin
  If vJSONObject <> Nil Then
    FreeAndNil(vJSONObject);
  Inherited;
End;

Function TJSONBaseArrayClass.GetObject: TJSONArray;
Begin
  Result := TJSONArray(vJSONObject);
End;

Procedure TJSONBaseArrayClass.SetObject(Value: TJSONArray);
Begin
  If Pointer(vJSONObject) = Pointer(Value) Then
    Exit;
  If vJSONObject <> Nil Then
    FreeAndNil(vJSONObject);
  vJSONObject := TJSONBaseClass(Value);
End;

Constructor TRESTDWJSONInterfaceBase.Create(ParentJSON: TJSONBaseClass);
Begin
  Inherited Create;
  vJSONObject := ParentJSON;
End;

Destructor TRESTDWJSONInterfaceBase.Destroy;
Begin
  Inherited;
End;

Function TRESTDWJSONInterfaceBase.PairCount: Integer;
{$IFDEF RESTDWLEGACYJSON}
Var
  Names: TJSONArray;
{$ENDIF}
Begin
  Result := 0;
  If vJSONObject = Nil Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If TObject(vJSONObject) is TJSONObject Then
   Begin
    Names := TJSONObject(vJSONObject).names;
    Try
      If Names <> Nil Then
        Result := Names.length;
    Finally
      Names.Free;
    End;
   End
  Else If TObject(vJSONObject) is TJSONArray Then
    Result := TJSONArray(vJSONObject).length
  Else
    Result := 1;
{$ELSE}
  If TObject(vJSONObject) is TJSONObject Then
    Result := TJSONObject(vJSONObject).Count
  Else If TObject(vJSONObject) is TJSONArray Then
    Result := TJSONArray(vJSONObject).Size
  Else
    Result := 1;
{$ENDIF}
End;

Constructor TRESTDWJSONInterfaceArray.Create;
Begin
  Inherited Create;
End;

Destructor TRESTDWJSONInterfaceArray.Destroy;
Begin
  Inherited;
End;

Function TRESTDWJSONInterfaceArray.ElementCount: Integer;
Begin
  Result := 0;
  If vJSONObject = Nil Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If TObject(vJSONObject) is TJSONArray Then
    Result := TJSONArray(vJSONObject).length
  Else If TObject(vJSONObject) is TJSONObject Then
    Result := TJSONObject(vJSONObject).length;
{$ELSE}
  If TObject(vJSONObject) is TJSONArray Then
    Result := TJSONArray(vJSONObject).Size
  Else If TObject(vJSONObject) is TJSONObject Then
    Result := TJSONObject(vJSONObject).Count;
{$ENDIF}
End;

Function TRESTDWJSONInterfaceArray.GetObject(Index: Integer): TRESTDWJSONInterfaceBase;
{$IFDEF RESTDWLEGACYJSON}
Var
  Value: TZAbstractObject;
  Name: String;
{$ELSE}
Var
  Value: TJSONValue;
{$ENDIF}
Begin
  Result := TRESTDWJSONInterfaceBase.Create(Nil);
  If (vJSONObject = Nil) Or (Index < 0) Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If TObject(vJSONObject) is TJSONArray Then
   Begin
    If Index >= TJSONArray(vJSONObject).length Then
      Exit;
    Value := TJSONArray(vJSONObject).opt(Index);
    Result.vJSONObject := LegacyCloneValue(Value);
   End
  Else If TObject(vJSONObject) is TJSONObject Then
   Begin
    If Index >= TJSONObject(vJSONObject).length Then
      Exit;
    Name := LegacyObjectNameAt(TJSONObject(vJSONObject), Index);
    If Name = '' Then
      Exit;
    Value := TJSONObject(vJSONObject).opt(Name);
    Result.vJSONObject := LegacyCloneValue(Value);
   End;
{$ELSE}
  If TObject(vJSONObject) is TJSONArray Then
   Begin
    If Index >= TJSONArray(vJSONObject).Size Then
      Exit;
    Value := TJSONArray(vJSONObject).Get(Index);
    Result.vJSONObject := NativeCloneValue(Value);
   End
  Else If TObject(vJSONObject) is TJSONObject Then
   Begin
    If Index >= TJSONObject(vJSONObject).Count Then
      Exit;
    Value := TJSONObject(vJSONObject).Pairs[Index].JSONValue;
    Result.vJSONObject := NativeCloneValue(Value);
   End;
{$ENDIF}
End;

Function TRESTDWJSONInterfaceArray.ToJSON: String;
Begin
  Result := '';
  If vJSONObject = Nil Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  Result := TZAbstractObject(vJSONObject).toString;
{$ELSE}
  Result := TJSONValue(vJSONObject).ToJSON;
{$ENDIF}
End;

Constructor TRESTDWJSONInterfaceObject.Create(JSONValue: String);
{$IFNDEF RESTDWLEGACYJSON}
Var
  Parsed: TJSONValue;
{$ENDIF}
Begin
  Inherited Create;
  If Trim(JSONValue) = '' Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If FirstJSONChar(JSONValue) = '[' Then
    vJSONObject := TJSONBaseClass(TJSONArray.Create(JSONValue))
  Else If FirstJSONChar(JSONValue) = '{' Then
    vJSONObject := TJSONBaseClass(TJSONObject.Create(JSONValue))
  Else
    vJSONObject := TJSONBaseClass(TJSONObject.Create('{}'));
{$ELSE}
  Parsed := TJSONObject.ParseJSONValue(JSONValue);
  If Parsed <> Nil Then
    vJSONObject := TJSONBaseClass(Parsed)
  Else
    vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue('{}'));
{$ENDIF}
End;

Destructor TRESTDWJSONInterfaceObject.Destroy;
Begin
  Inherited;
End;

Function TRESTDWJSONInterfaceObject.PairCount: Integer;
Begin
  Result := 0;
  If vJSONObject = Nil Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If TObject(vJSONObject) is TJSONObject Then
    Result := TJSONObject(vJSONObject).length
  Else If TObject(vJSONObject) is TJSONArray Then
    Result := TJSONArray(vJSONObject).length
  Else
    Result := 1;
{$ELSE}
  If TObject(vJSONObject) is TJSONObject Then
    Result := TJSONObject(vJSONObject).Count
  Else If TObject(vJSONObject) is TJSONArray Then
    Result := TJSONArray(vJSONObject).Size
  Else
    Result := 1;
{$ENDIF}
End;

Function TRESTDWJSONInterfaceObject.GetPair(Index: Integer): TRESTDWJSONPair;
{$IFDEF RESTDWLEGACYJSON}
Var
  Name: String;
  Value: TZAbstractObject;
{$ELSE}
Var
  Value: TJSONValue;
{$ENDIF}
Begin
  Result := EmptyPair;
  If (vJSONObject = Nil) Or (Index < 0) Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If TObject(vJSONObject) is TJSONObject Then
   Begin
    If Index >= TJSONObject(vJSONObject).length Then
      Exit;
    Name := LegacyObjectNameAt(TJSONObject(vJSONObject), Index);
    If Name = '' Then
      Exit;
    Value := TJSONObject(vJSONObject).opt(Name);
    Result := LegacyPairFromValue(Name, Value);
   End
  Else If TObject(vJSONObject) is TJSONArray Then
   Begin
    If Index >= TJSONArray(vJSONObject).length Then
      Exit;
    Value := TJSONArray(vJSONObject).opt(Index);
    Result := LegacyPairFromValue('arrayobj' + IntToStr(Index), Value);
   End
  Else
    Result := LegacyPairFromValue('', TZAbstractObject(vJSONObject));
{$ELSE}
  If TObject(vJSONObject) is TJSONObject Then
   Begin
    If Index >= TJSONObject(vJSONObject).Count Then
      Exit;
    Value := TJSONObject(vJSONObject).Pairs[Index].JSONValue;
    Result := NativePairFromValue(TJSONObject(vJSONObject).Pairs[Index].JsonString.Value, Value);
   End
  Else If TObject(vJSONObject) is TJSONArray Then
   Begin
    If Index >= TJSONArray(vJSONObject).Size Then
      Exit;
    Value := TJSONArray(vJSONObject).Get(Index);
    Result := NativePairFromValue('arrayobj' + IntToStr(Index), Value);
   End
  Else
    Result := NativePairFromValue('', TJSONValue(vJSONObject));
{$ENDIF}
End;

Function TRESTDWJSONInterfaceObject.GetPairN(Index: String): TRESTDWJSONPair;
{$IFDEF RESTDWLEGACYJSON}
Var
  I: Integer;
  Name: String;
  Value: TZAbstractObject;
{$ELSE}
Var
  I: Integer;
{$ENDIF}
Begin
  Result := EmptyPair;
  If (vJSONObject = Nil) Or (Trim(Index) = '') Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If TObject(vJSONObject) is TJSONObject Then
   Begin
    For I := 0 To TJSONObject(vJSONObject).length - 1 Do
     Begin
      Name := LegacyObjectNameAt(TJSONObject(vJSONObject), I);
      If SameText(Name, Index) Then
       Begin
        Value := TJSONObject(vJSONObject).opt(Name);
        Result := LegacyPairFromValue(Name, Value);
        Exit;
       End;
     End;
   End
  Else If TObject(vJSONObject) is TJSONArray Then
   Begin
    For I := 0 To TJSONArray(vJSONObject).length - 1 Do
     Begin
      Value := TJSONArray(vJSONObject).opt(I);
      If Value is TJSONObject Then
       Begin
        Name := LegacyObjectNameAt(TJSONObject(Value), 0);
        If SameText(Name, Index) Then
         Begin
          Result := LegacyPairFromValue(Name, TJSONObject(Value).opt(Name));
          Exit;
         End;
       End;
     End;
   End;
{$ELSE}
  If TObject(vJSONObject) is TJSONObject Then
   Begin
    For I := 0 To TJSONObject(vJSONObject).Count - 1 Do
     Begin
      If SameText(TJSONObject(vJSONObject).Pairs[I].JsonString.Value, Index) Then
       Begin
        Result := NativePairFromValue(
          TJSONObject(vJSONObject).Pairs[I].JsonString.Value,
          TJSONObject(vJSONObject).Pairs[I].JSONValue);
        Exit;
       End;
     End;
   End
  Else If TObject(vJSONObject) is TJSONArray Then
   Begin
    For I := 0 To TJSONArray(vJSONObject).Size - 1 Do
     Begin
      If TJSONArray(vJSONObject).Get(I) is TJSONObject Then
       Begin
        If TJSONObject(TJSONArray(vJSONObject).Get(I)).Count > 0 Then
         Begin
          If SameText(TJSONObject(TJSONArray(vJSONObject).Get(I)).Pairs[0].JsonString.Value, Index) Then
           Begin
            Result := NativePairFromValue(
              TJSONObject(TJSONArray(vJSONObject).Get(I)).Pairs[0].JsonString.Value,
              TJSONObject(TJSONArray(vJSONObject).Get(I)).Pairs[0].JSONValue);
            Exit;
           End;
         End;
       End;
     End;
   End;
{$ENDIF}
End;

Procedure TRESTDWJSONInterfaceObject.PutPair(Index: Integer; Item: TRESTDWJSONPair);
Var
  Current: TRESTDWJSONPair;
Begin
  Current := GetPair(Index);
  If Current.Name <> '' Then
    PutPairN(Current.Name, Item);
End;

Procedure TRESTDWJSONInterfaceObject.PutPairN(Index: String; Item: TRESTDWJSONPair);
{$IFDEF RESTDWLEGACYJSON}
Var
  OldValue: TZAbstractObject;
{$ELSE}
Var
  OldPair: TJSONPair;
  NewValue: TJSONValue;
{$ENDIF}
Begin
  If (vJSONObject = Nil) Or (Trim(Index) = '') Then
    Exit;
  If Not (TObject(vJSONObject) is TJSONObject) Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  OldValue := TJSONObject(vJSONObject).remove(Index);
  If (OldValue <> Nil) And (OldValue <> CNULL) Then
    OldValue.Free;
  If Item.isnull Then
    TJSONObject(vJSONObject).put(Index, CNULL)
  Else
    TJSONObject(vJSONObject).put(Index, Item.Value);
{$ELSE}
  OldPair := TJSONObject(vJSONObject).RemovePair(Index);
  OldPair.Free;
  If Item.isnull Then
    NewValue := TJSONNull.Create
  Else
    NewValue := TJSONString.Create(Item.Value);
  TJSONObject(vJSONObject).AddPair(Index, NewValue);
{$ENDIF}
End;

Function TRESTDWJSONInterfaceObject.OpenArray(Key: String): TRESTDWJSONInterfaceArray;
{$IFDEF RESTDWLEGACYJSON}
Var
  Value: TZAbstractObject;
{$ELSE}
Var
  Value: TJSONValue;
{$ENDIF}
Begin
  Result := TRESTDWJSONInterfaceArray.Create;
  If (vJSONObject = Nil) Or (Trim(Key) = '') Then
    Exit;
  If Not (TObject(vJSONObject) is TJSONObject) Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  Value := TJSONObject(vJSONObject).opt(Key);
  If Value is TJSONArray Then
    Result.vJSONObject := LegacyCloneValue(Value);
{$ELSE}
  Value := TJSONObject(vJSONObject).GetValue(Key);
  If Value is TJSONArray Then
    Result.vJSONObject := NativeCloneValue(Value);
{$ENDIF}
End;

Function TRESTDWJSONInterfaceObject.OpenArray(Index: Integer): TRESTDWJSONInterfaceArray;
{$IFDEF RESTDWLEGACYJSON}
Var
  Name: String;
  Value: TZAbstractObject;
{$ELSE}
Var
  Value: TJSONValue;
{$ENDIF}
Begin
  Result := TRESTDWJSONInterfaceArray.Create;
  If (vJSONObject = Nil) Or (Index < 0) Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  If TObject(vJSONObject) is TJSONObject Then
   Begin
    If Index >= TJSONObject(vJSONObject).length Then
      Exit;
    Name := LegacyObjectNameAt(TJSONObject(vJSONObject), Index);
    If Name = '' Then
      Exit;
    Value := TJSONObject(vJSONObject).opt(Name);
   End
  Else If TObject(vJSONObject) is TJSONArray Then
   Begin
    If Index >= TJSONArray(vJSONObject).length Then
      Exit;
    Value := TJSONArray(vJSONObject).opt(Index);
   End
  Else
    Exit;
  If Value is TJSONArray Then
    Result.vJSONObject := LegacyCloneValue(Value);
{$ELSE}
  If TObject(vJSONObject) is TJSONObject Then
   Begin
    If Index >= TJSONObject(vJSONObject).Count Then
      Exit;
    Value := TJSONObject(vJSONObject).Pairs[Index].JSONValue;
   End
  Else If TObject(vJSONObject) is TJSONArray Then
   Begin
    If Index >= TJSONArray(vJSONObject).Size Then
      Exit;
    Value := TJSONArray(vJSONObject).Get(Index);
   End
  Else
    Exit;
  If Value is TJSONArray Then
    Result.vJSONObject := NativeCloneValue(Value);
{$ENDIF}
End;

Function TRESTDWJSONInterfaceObject.ClassType: TClass;
Begin
  Result := TRESTDWJSONInterfaceBase;
  If vJSONObject = Nil Then
    Exit;
  If TObject(vJSONObject) is TJSONObject Then
    Result := TRESTDWJSONInterfaceObject
  Else If TObject(vJSONObject) is TJSONArray Then
    Result := TRESTDWJSONInterfaceArray
  Else
    Result := TObject(vJSONObject).ClassType;
End;

Function TRESTDWJSONInterfaceObject.ToJSON: String;
Begin
  Result := '';
  If vJSONObject = Nil Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  Result := TZAbstractObject(vJSONObject).toString;
{$ELSE}
  Result := TJSONValue(vJSONObject).ToJSON;
{$ENDIF}
End;

Function TRESTDWJSONValueInterface.GetPair(Index: Integer): TRESTDWJSONPair;
Begin
  Result := EmptyPair;
  If vJSONObject = Nil Then
    Exit;
{$IFDEF RESTDWLEGACYJSON}
  Result := LegacyPairFromValue('', TZAbstractObject(vJSONObject));
{$ELSE}
  Result := NativePairFromValue('', TJSONValue(vJSONObject));
{$ENDIF}
End;

Procedure TRESTDWJSONValueInterface.PutPair(Index: Integer; Value: TRESTDWJSONPair);
Begin
End;

end.
