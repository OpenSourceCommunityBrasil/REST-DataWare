Unit uRESTDWFCMValue;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMCompat;

Type
  TRESTDWFCMValueKind = (
    fvkNull,
    fvkString,
    fvkNumber,
    fvkBoolean,
    fvkObject,
    fvkArray
  );

  TRESTDWFCMValue = Class(TPersistent)
  Private
    FName         : String;
    FKind         : TRESTDWFCMValueKind;
    FStringValue  : String;
    FNumberValue  : String;
    FBooleanValue : Boolean;
    FItems        : TList;

    Procedure ClearItems;
    Function GetCount : Integer;
    Function GetItem(AIndex : Integer) : TRESTDWFCMValue;
  Public
    Constructor Create(AKind : TRESTDWFCMValueKind); Reintroduce; Overload;
    Constructor Create; Overload;
    Destructor Destroy; Override;

    Procedure Assign(Source : TPersistent); Override;
    Procedure Clear;

    Function AddNull(Const AName : String) : TRESTDWFCMValue;
    Function AddString(Const AName,
                             AValue : String) : TRESTDWFCMValue;
    Function AddNumber(Const AName,
                             AValue : String) : TRESTDWFCMValue;
    Function AddInteger(Const AName : String;
                        AValue      : Int64) : TRESTDWFCMValue;
    Function AddBoolean(Const AName : String;
                        AValue      : Boolean) : TRESTDWFCMValue;
    Function AddObject(Const AName : String) : TRESTDWFCMValue;
    Function AddArray(Const AName : String) : TRESTDWFCMValue; Overload;

    Function AddArrayNull : TRESTDWFCMValue;
    Function AddArrayString(Const AValue : String) : TRESTDWFCMValue;
    Function AddArrayNumber(Const AValue : String) : TRESTDWFCMValue;
    Function AddArrayInteger(AValue : Int64) : TRESTDWFCMValue;
    Function AddArrayBoolean(AValue : Boolean) : TRESTDWFCMValue;
    Function AddArrayObject : TRESTDWFCMValue;
    Function AddArray : TRESTDWFCMValue; Overload;

    Property Count : Integer Read GetCount;
    Property Items[AIndex : Integer] : TRESTDWFCMValue Read GetItem; Default;
    Property Name : String Read FName Write FName;
    Property Kind : TRESTDWFCMValueKind Read FKind Write FKind;
    Property StringValue : String Read FStringValue Write FStringValue;
    Property NumberValue : String Read FNumberValue Write FNumberValue;
    Property BooleanValue : Boolean Read FBooleanValue Write FBooleanValue;
  End;

Implementation

Constructor TRESTDWFCMValue.Create;
Begin
  Inherited Create;
  FItems := TList.Create;
  FKind := fvkObject;
End;

Constructor TRESTDWFCMValue.Create(AKind : TRESTDWFCMValueKind);
Begin
  Inherited Create;
  FItems := TList.Create;
  FKind := AKind;
End;

Destructor TRESTDWFCMValue.Destroy;
Begin
  ClearItems;
  FItems.Free;
  Inherited Destroy;
End;

Procedure TRESTDWFCMValue.ClearItems;
Var
  I : Integer;
Begin
  For I := FItems.Count - 1 DownTo 0 Do
    TObject(FItems[I]).Free;

  FItems.Clear;
End;

Procedure TRESTDWFCMValue.Clear;
Begin
  ClearItems;
  FName := '';
  FStringValue := '';
  FNumberValue := '';
  FBooleanValue := False;
  FKind := fvkObject;
End;

Function TRESTDWFCMValue.GetCount : Integer;
Begin
  Result := FItems.Count;
End;

Function TRESTDWFCMValue.GetItem(AIndex : Integer) : TRESTDWFCMValue;
Begin
  Result := TRESTDWFCMValue(FItems[AIndex]);
End;

Procedure TRESTDWFCMValue.Assign(Source : TPersistent);
Var
  LSource : TRESTDWFCMValue;
  LItem   : TRESTDWFCMValue;
  LNew    : TRESTDWFCMValue;
  I       : Integer;
Begin
  If Source Is TRESTDWFCMValue Then
  Begin
    LSource := TRESTDWFCMValue(Source);

    ClearItems;

    FName := LSource.Name;
    FKind := LSource.Kind;
    FStringValue := LSource.StringValue;
    FNumberValue := LSource.NumberValue;
    FBooleanValue := LSource.BooleanValue;

    For I := 0 To LSource.Count - 1 Do
    Begin
      LItem := LSource[I];
      LNew := TRESTDWFCMValue.Create(LItem.Kind);
      LNew.Assign(LItem);
      FItems.Add(LNew);
    End;
  End
  Else
    Inherited Assign(Source);
End;

Function TRESTDWFCMValue.AddNull(Const AName : String) : TRESTDWFCMValue;
Begin
  Result := TRESTDWFCMValue.Create(fvkNull);
  Result.Name := AName;
  FItems.Add(Result);
End;

Function TRESTDWFCMValue.AddString(Const AName,
                                         AValue : String) : TRESTDWFCMValue;
Begin
  Result := TRESTDWFCMValue.Create(fvkString);
  Result.Name := AName;
  Result.StringValue := AValue;
  FItems.Add(Result);
End;

Function TRESTDWFCMValue.AddNumber(Const AName,
                                         AValue : String) : TRESTDWFCMValue;
Begin
  Result := TRESTDWFCMValue.Create(fvkNumber);
  Result.Name := AName;
  Result.NumberValue := AValue;
  FItems.Add(Result);
End;

Function TRESTDWFCMValue.AddInteger(Const AName : String;
                                    AValue      : Int64) : TRESTDWFCMValue;
Begin
  If AValue < 0 Then
    Result :=
      AddNumber(
        AName,
        '-' + RESTDWFCMUIntToStr(TRESTDWFCMUInt64(-(AValue + 1)) + 1)
      )
  Else
    Result :=
      AddNumber(
        AName,
        RESTDWFCMUIntToStr(TRESTDWFCMUInt64(AValue))
      );
End;

Function TRESTDWFCMValue.AddBoolean(Const AName : String;
                                    AValue      : Boolean) : TRESTDWFCMValue;
Begin
  Result := TRESTDWFCMValue.Create(fvkBoolean);
  Result.Name := AName;
  Result.BooleanValue := AValue;
  FItems.Add(Result);
End;

Function TRESTDWFCMValue.AddObject(Const AName : String) : TRESTDWFCMValue;
Begin
  Result := TRESTDWFCMValue.Create(fvkObject);
  Result.Name := AName;
  FItems.Add(Result);
End;

Function TRESTDWFCMValue.AddArray(Const AName : String) : TRESTDWFCMValue;
Begin
  Result := TRESTDWFCMValue.Create(fvkArray);
  Result.Name := AName;
  FItems.Add(Result);
End;

Function TRESTDWFCMValue.AddArrayNull : TRESTDWFCMValue;
Begin
  Result := AddNull('');
End;

Function TRESTDWFCMValue.AddArrayString(Const AValue : String) : TRESTDWFCMValue;
Begin
  Result := AddString('', AValue);
End;

Function TRESTDWFCMValue.AddArrayNumber(Const AValue : String) : TRESTDWFCMValue;
Begin
  Result := AddNumber('', AValue);
End;

Function TRESTDWFCMValue.AddArrayInteger(AValue : Int64) : TRESTDWFCMValue;
Begin
  Result := AddInteger('', AValue);
End;

Function TRESTDWFCMValue.AddArrayBoolean(AValue : Boolean) : TRESTDWFCMValue;
Begin
  Result := AddBoolean('', AValue);
End;

Function TRESTDWFCMValue.AddArrayObject : TRESTDWFCMValue;
Begin
  Result := AddObject('');
End;

Function TRESTDWFCMValue.AddArray : TRESTDWFCMValue;
Begin
  Result := AddArray('');
End;

End.
