unit uDWMassiveBuffer;

interface

uses SysUtils,  Classes,       uDWJSONObject,
     DB,        uRESTDWBase,   uDWPoolerMethod,
     uDWConsts, uDWConstsData;

Type
 TMassiveValue = Class
 Private
  vJSONValue  : TJSONValue;
 Protected
 Public
  Constructor Create;
  Destructor  Free;
  Function    GetValue   : String;
  Procedure   SetValue(Value : String);
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Value      : String  Read GetValue Write SetValue;
End;

Type
 PMassiveValue  = ^TMassiveValue;
 TMassiveValues = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveValue;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveValue); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveValue) : Integer;          Overload;
  Property   Items[Index  : Integer]       : TMassiveValue Read GetRec Write PutRec; Default;
End;

Type
 TMassiveField = Class
 Private
  vRequired,
  vKeyField   : Boolean;
  vJSONValue  : ^TMassiveValue;
  vFieldsName : String;
  vFieldType  : TObjectValue;
 Protected
 Public
  Constructor Create;
  Destructor  Free;
  Function    Value      : String;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Required   : Boolean      Read vRequired   Write vRequired;
  Property    KeyField   : Boolean      Read vKeyField   Write vKeyField;
  Property    FieldType  : TObjectValue Read vFieldType  Write vFieldType;
  Property    FieldsName : String       Read vFieldsName Write vFieldsName;
End;

Type
 PMassiveField  = ^TMassiveField;
 TMassiveFields = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveField;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveField); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveField) : Integer;          Overload;
  Property   Items[Index  : Integer]       : TMassiveField Read GetRec Write PutRec; Default;
End;

implementation

{ TMassiveField }

Constructor TMassiveField.Create;
Begin
 vRequired   := False;
 vKeyField   := vRequired;
 vFieldType  := ovUnknown;
 vJSONValue  := Nil;
 vFieldsName := '';
End;

Destructor TMassiveField.Free;
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   FreeAndNil(vJSONValue^);
 vJSONValue := Nil;
End;

Procedure TMassiveField.LoadFromStream(Stream: TMemoryStream);
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   vJSONValue^.LoadFromStream(Stream);
End;

Procedure TMassiveField.SaveToStream(Stream: TMemoryStream);
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   vJSONValue^.SaveToStream(Stream);
End;

Function TMassiveField.Value : String;
Begin
 If Assigned(vJSONValue) Then
  If Assigned(vJSONValue^) Then
   Result := vJSONValue^.Value;
End;

{ TMassiveFields }

Function TMassiveFields.Add(Item: TMassiveField): Integer;
Var
 vItem : ^TMassiveField;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveFields.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveField(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveField(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TMassiveFields.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Destructor TMassiveFields.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveFields.GetRec(Index : Integer) : TMassiveField;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveField(TList(Self).Items[Index]^);
End;

Procedure TMassiveFields.PutRec(Index : Integer; Item : TMassiveField);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveField(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveValue }

Constructor TMassiveValue.Create;
Begin
 vJSONValue := TJSONValue.Create;
End;

Destructor TMassiveValue.Free;
Begin
 FreeAndNil(vJSONValue);
End;

Function TMassiveValue.GetValue: String;
Begin
 Result := vJSONValue.Value;
End;

Procedure TMassiveValue.LoadFromStream(Stream: TMemoryStream);
Begin
 vJSONValue.LoadFromStream(Stream);
End;

Procedure TMassiveValue.SaveToStream(Stream: TMemoryStream);
Begin
 vJSONValue.SaveToStream(Stream);
End;

Procedure TMassiveValue.SetValue(Value: String);
Begin
 vJSONValue.SetValue(Value);
End;

{ TMassiveValues }

Function TMassiveValues.Add(Item: TMassiveValue): Integer;
Var
 vItem : ^TMassiveValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveValues.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Procedure TMassiveValues.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveValue(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveValues.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveValues.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(Self).Items[Index]^);
End;

Procedure TMassiveValues.PutRec(Index: Integer; Item: TMassiveValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveValue(TList(Self).Items[Index]^) := Item;
End;

End.
