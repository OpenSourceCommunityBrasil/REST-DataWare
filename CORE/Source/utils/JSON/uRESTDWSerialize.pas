Unit uRESTDWSerialize;

{$I ..\..\Includes\uRESTDW.inc}

Interface

Uses Classes, Messages, SysUtils, Variants, TypInfo, uRESTDWDataJSON;

//Const
// varObject = $0049;

Type
 PObject = ^TObject;

{$TYPEINFO ON}
Type
 TBaseClass = Class(TComponent)
 Public
 End;
 Type
  TArrayOf     = Array of TBaseClass;
 Type
  TRESTDWJSONSerializer = Class(TBaseClass)
  Private
   Class Function  ReadProperty(Instance    : TPersistent;
                                PropInfo    : PPropInfo) : TBaseClass;
   Class Function  ReadClass   (Instance    : TPersistent) : TBaseClass;
   Class Procedure JsonToArray(aObject       : TRESTDWJSONBaseObjectClass;
                               Var aArrayOf  : TArrayOf;
                               aElementClass : TClass);
   Class Procedure GetDynArrayElTypeInfo(TypeInfo    : PTypeInfo;
                                         Var EltInfo : {$IFDEF RESTDWLAZARUS}PPTypeInfo{$ELSE}PTypeInfo{$ENDIF};
                                         Var Dims    : Integer);
  Public
   Class Function JSONtoObject(Json        : String;
                               aClass      : TClass)     : TObject;
   Class Function ObjectToJSON(aClass      : TBaseClass) : String;
 End;


Implementation

Uses uRESTDWTools;

Function VarToObj(Const Value  : Variant;
                  AClass       : TClass;
                  Out AObject) : Boolean;
Var
 Obj   : TObject Absolute AObject;
 P     : PVarData;
 VType : TVarType;
Begin
 P := FindVarData(Value);
 VType  := P^.VType;
 Obj    := Nil;
 Result := True;
 Try
  If (VType = vtClass) And (TObject(P^.VPointer) Is AClass) Then
   Begin
    Obj := TObject(P^.VPointer) as AClass;
    Result := Assigned(Obj) or not Assigned(P^.VPointer);
   End
  Else If (VType <> varNull) And (VType <> varEmpty) Then
   Result := False;
 Except
  Result := False;
 End;
End;

Function ObjToVar(Const Value : TObject) : Variant;
Begin
 VarClear(Result);
 TObject(TVarData(Result).VPointer) := Value;
 TVarData(Result).VType := vtClass; //varObject;
End;

Function GetPropValue(Instance      : tobject;
                      Prop          : String;
                      Preferstrings : Boolean = False): Variant;
Var
 aPropInfo : PPropInfo;
 Dynarray : Pointer;
Begin
 Result := Null;
 If Instance <> Nil Then
  Begin
   aPropInfo := GetPropInfo(Instance, Prop);
   If Assigned(aPropInfo) Then
    Begin
     Case aPropInfo^.Proptype^{$IFNDEF RESTDWLAZARUS}^{$ENDIF}.Kind Of
      tkinteger,
      tkInt64,
      tkFloat,
      tkChar,
      tkWChar       : Result := GetordProp(instance, aPropInfo);
      tkLString,
      tkWString,
      tkString      : Result := GetStrProp(instance, aPropInfo);
      tkclass       : ;
      tkSet         : ;
      tkRecord      : ;
      tkDynArray    : ;
      tkArray       : ;
      tkEnumeration :
       Begin
        If Preferstrings Then
         Result := GetEnumProp(instance, aPropInfo)
        Else
         Begin
          With GettypeData(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF})^ Do
           Begin
            If Basetype{$IFNDEF RESTDWLAZARUS}^{$ENDIF} = typeinfo(Boolean) Then
             Result := Boolean(GetordProp(instance, aPropInfo))
            Else
             Result := GetordProp(instance, aPropInfo);
           End;
         End;
       End;
     End;
    End;
  End;
end;

Function SetValue(Instance      : tobject;
                  Prop          : String;
                  Value         : Variant) : Boolean;
var
 infoPropriedades : PPropInfo;
 Dynarray         : Pointer;
Begin
 Result := False;
 If Instance <> Nil Then
  Begin
   infoPropriedades := GetPropInfo(Instance, Prop);
   If Assigned(infoPropriedades) Then
    Begin
     Case infoPropriedades^.Proptype^{$IFNDEF RESTDWLAZARUS}^{$ENDIF}.Kind Of
      tkinteger,
      tkChar,
      tkWChar,
      tkclass       :
       Begin
        Try
         SetordProp(instance, infoPropriedades, Integer(Value));
         Result := True;
        Except
        End;
       End;
      tkLString, tkWString, tkEnumeration :
       Begin
        Try
         SetPropValue(instance, Prop, Value);
         Result := True;
        Except
        End;
       End;
     End;
    End;
  End;
End;

Class Function TRESTDWJSONSerializer.ReadClass(Instance : TPersistent) : TBaseClass;
Var
 I,
 PropCount : Integer;
 PropList  : PPropList;
 PropInfo  : PPropInfo;
Begin
 PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
 If PropCount > 0 Then
  Begin
   GetMem(PropList, PropCount * SizeOf(Pointer));
   Try
    GetPropInfos(Instance.ClassInfo, PropList);
    For i := 0 to PropCount - 1 Do
     Begin
      PropInfo := PropList^[I];
      If Not(PropInfo = Nil) Then
       ReadProperty(Instance, PropInfo);
     End;
   Finally
    FreeMem(PropList, PropCount * SizeOf(Pointer));
   End;
  End;
End;

Class Procedure TRESTDWJSONSerializer.JsonToArray(aObject       : TRESTDWJSONBaseObjectClass;
                                                  Var aArrayOf  : TArrayOf;
                                                  aElementClass : TClass);
Var
 aCount,
 bCount,
 aSize,
 OrdValue,
 Dimensions,
 A, X, I      : Integer;
 aBaseData,
 aTypeData    : PTypeData;
 fPropList    : PPropList;
 aBaseType,
 bTypeData    : PTypeInfo;
 aElementTypeInfo : {$IFDEF RESTDWLAZARUS}PPTypeInfo{$ELSE}PTypeInfo{$ENDIF};
 aPropertyInfo,
 aPropInfo    : PPropInfo;
 aEnumName,
 bElementName : String;
 vStreamb,
 vStream      : TStream;
 vValue,
 aValue       : Variant;
 aElement     : TRESTDWJSONBaseObjectClass;
 vDateTime    : TDateTime;
 bClass       : TClass;
Begin
 fPropList    := Nil;
 Setlength(aArrayOf, Length(aArrayOf) +1);
 X           := Length(aArrayOf) -1;
 aArrayOf[X] := TBaseclass(aElementClass.Create);
 aCount := GetPropList(aElementClass.ClassInfo, tkAny, fPropList);
 aSize  := aCount * SizeOf(Pointer);
 Try
  GetMem(fPropList, aSize);
  aCount := GetPropList(aElementClass.ClassInfo, tkAny, fPropList);
  bCount := TRESTDWJSONObject(aObject).Count;
  For A := 0 To bCount -1 Do
   Begin
    aElement     := TRESTDWJSONObject(aObject).Elements[A];
    bElementName := aElement.ElementName;
    For I := 0 To aCount -1 Do
     Begin
      aPropInfo  := fPropList^[I];
      If Assigned(aPropInfo) Then
       Begin
        If (Lowercase(bElementName) = Lowercase(aPropInfo^.Name)) Then
         Begin
          Case aPropInfo^.Proptype^{$IFNDEF RESTDWLAZARUS}^{$ENDIF}.Kind Of
           tkInteger,
           tkInt64,
           tkFloat,
           tkChar,
           tkWChar       : Begin //Classes baseadas em Bytes
                            If aElement.ElementType in [etString, etDateTime] Then
                             Begin
                              Try
                               vDateTime := StrToDateTime(aElement.Value);
                               SetFloatProp(aArrayOf[X], aPropInfo, Real(vDateTime));
                              Except
                              End;
                             End
                            Else If aElement.ElementType in [etNumeric] Then
                             SetFloatProp(aArrayOf[X], aPropInfo, Real(aElement.Value))
                            Else
                             SetordProp(aArrayOf[X], aPropInfo, Integer(aElement.Value));
                           End;
           tkLString,
           tkWString,
           {$IFDEF RESTDWLAZARUS}
             tkUString, tkAString,
           {$ELSE}
           {$IF Defined(DELPHIXEUP)}tkUString,{$ELSE}tkAString,{$IFEND}
           {$ENDIF}
           tkString      : Begin  //Classes baseadas em Strings
                            SetStrProp(aArrayOf[X], aPropInfo, String(aElement.Value));
                           End;
           tkClass       : Begin
                            aTypeData  := GetTypeData(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF});
                            If Assigned(aTypeData) Then
                             Begin
                              aValue := aElement.Value;
                              If aTypeData^.ClassType.InheritsFrom(TStream) Then //Classes baseadas em Stream
                               Begin
                                vStream    := TStream(aTypeData^.ClassType.Create);
                                vStreamb   := DecodeStream(aValue);
                                If Assigned(vStreamb) Then
                                 vStream.CopyFrom(vStreamb, vStreamb.Size);
//                                vStream.Position := 0;
                                FreeAndNil(vStreamb);
                                SetObjectProp(aArrayOf[X], aPropInfo, vStream);
                               End;
                             End;
                           End;
           tkSet         : Begin
                            bTypeData := GetTypeData(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF})^.CompType{$IFNDEF RESTDWLAZARUS}^{$ENDIF};
                            aBaseData := GetTypeData(bTypeData);
                            OrdValue  := GetOrdProp(aArrayOf[X], aPropertyInfo);
                            For X := aBaseData^.MinValue To aBaseData^.MaxValue do
                             Begin
                              aEnumName := GetEnumName(aBaseType, X);
                              If aEnumName = '' Then
                               Break;
                             End;
                           End;
           tkRecord      : ;
           tkVariant     : Begin
                            vValue := aElement.Value;
                            SetVariantProp(aArrayOf[X], aPropInfo, vValue);
                           End;
           tkDynArray    : Begin
                            If Pointer(GetOrdProp(aObject, aPropInfo)) = Nil Then
                             Begin
                              GetDynArrayElTypeInfo(aPropInfo^.PropType{$IFNDEF RESTDWLAZARUS}^{$ENDIF}, aElementTypeInfo, Dimensions);
                              bClass := GetTypeData(aElementTypeInfo{$IFDEF RESTDWLAZARUS}^{$ENDIF})^.Classtype; //aArrayOf[Length(aArrayOf) -1].ClassType;
                              JsonToArray(aElement, aArrayOf, bClass);
                              {$IFDEF RESTDWLAZARUS}
                              SetVariantProp(aArrayOf[X], aPropInfo, aArrayOf);
                              {$ELSE}
                              SetOrdProp(aArrayOf[X], aPropInfo, Integer(aArrayOf));
                              {$ENDIF}
                             End;
                           End;
           tkArray       : ;
           {$IFDEF RESTDWLAZARUS}
           tkBool        : Begin
                            vValue := aElement.Value;
                            SetOrdProp(aArrayOf[X], aPropInfo, Integer(vValue));
                           End;
           {$ENDIF}
           tkEnumeration :
            Begin
             With GettypeData(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF})^ Do
              Begin
               vValue := aElement.Value;
               If Basetype{$IFNDEF RESTDWLAZARUS}^{$ENDIF} = typeinfo(Boolean) Then
                SetOrdProp(aArrayOf[X], aPropInfo, Integer(vValue))
               Else
                SetOrdProp(aArrayOf[X], aPropInfo, aElement.Value);
              End;
            End;
          End;
          Break;
         End;
       End;
     End;
   End;
 Finally
  FreeMem(fPropList);
 End;
End;

Class Procedure TRESTDWJSONSerializer.GetDynArrayElTypeInfo(typeInfo : PTypeInfo; var
                                                            EltInfo  : {$IFDEF RESTDWLAZARUS}PPTypeInfo{$ELSE}PTypeInfo{$ENDIF};
                                                            Var Dims : Integer);
Var
 S           : String;
 P           : Pointer;
 ppInfo      : PPTypeInfo;
 Info        : {$IFDEF RESTDWLAZARUS}PPTypeInfo{$ELSE}PTypeInfo{$ENDIF};
 CleanupInfo : Boolean;
 Function ReadByte(Var P : Pointer) : Byte;
 Begin
  Result := Byte(P^);
  P := Pointer(NativeInt(P) + 1);
 End;
 Function ReadString(Var P : Pointer) : String;
 Var
  B: Byte;
  {$IF Defined(UNICODE) or Defined(NEXTGEN)}
  AStr: TBytes;
  {$ELSE}
  AStr: AnsiString;
  {$IFEND}
 Begin
  B := Byte(P^);
  {$IFDEF UNICODE}
  SetLength(AStr, B);
  P := Pointer(NativeInt(P)+1);
    {$IFDEF NEXTGEN}
    Move(P^, AStr[0], Integer(B));
    Result := Tencoding.UTF8.GetString(AStr);
    {$ELSE !NEXTGEN}
    Move(P^, AStr[1], Integer(B));
    Result := UTF8ToString(AStr);
    {$ENDIF NEXTGEN}
  {$ELSE}
  SetLength(Result, B);
  P := Pointer( NativeInt(P) + 1);
  Move(P^, Result[1], Integer(B));
  {$ENDIF}
  P := Pointer( NativeInt(P) + B );
 End;

 Function ReadLong(Var P : Pointer) : Integer;
 Begin
  Result := Integer(P^);
  P := Pointer( NativeInt(P) + 4);
 End;

 Function ReadPointer(var P: Pointer): Pointer;
 Begin
  Result := Pointer(P^);
  P := Pointer(NativeInt(P) + SizeOf(Pointer));
 End;
Begin
 CleanupInfo := False;
 Dims        := 0;
 P      := Pointer(typeInfo);
 ReadByte(P);
 S      := ReadString(P);
 ReadLong(P);
 ppInfo := ReadPointer(P);
 If (ppInfo <> Nil) Then
  Begin
   CleanupInfo := True;
   Info := ppInfo{$IFNDEF RESTDWLAZARUS}^{$ENDIF};
   If Info{$IFDEF RESTDWLAZARUS}^{$ENDIF}^.Kind = tkDynArray then
    GetDynArrayElTypeInfo(Info{$IFDEF RESTDWLAZARUS}^{$ENDIF}, EltInfo, Dims);
  End;
 ReadLong(P);
 ppInfo := ReadPointer(P);
 If ppInfo <> Nil Then
  Begin
   EltInfo := ppInfo{$IFNDEF RESTDWLAZARUS}^{$ENDIF};
   If Not CleanupInfo Then
    Begin
     Info := EltInfo;
     If Info{$IFDEF RESTDWLAZARUS}^^{$ENDIF}.Kind = tkDynArray Then
      GetDynArrayElTypeInfo(Info{$IFDEF RESTDWLAZARUS}^{$ENDIF}, EltInfo, Dims);
    End;
  End;
 Inc(Dims);
End;

Class Function TRESTDWJSONSerializer.JSONtoObject(Json        : String;
                                                  aClass      : TClass) : TObject;
Var
 JSONObject   : TRESTDWJSONObject;
 JSONArray    : TRESTDWJSONArray;
 fPropList    : PPropList;
 aPropertyInfo,
 aPropInfo    : PPropInfo;
 aBaseData,
 aTypeData    : PTypeData;
 bTypeData,
 aBaseType    : PTypeInfo;
 aElementTypeInfo : {$IFDEF RESTDWLAZARUS}PPTypeInfo{$ELSE}PTypeInfo{$ENDIF};
 aItemArray   : TBaseClass;
 A, I, X,
 aPropCount,
 OrdValue,
 aSize,
 bCount,
 Dimensions,
 aCount       : Integer;
 aValue,
 aPropValue,
 vValueData,
 vDateTime    : Variant;
 arrObj,
 bObj         : TObject;
 vValue       : Boolean;
 vStreamb,
 vStream      : TStream;
 bElementName,
 aEnumName    : String;
 Data         : Variant;
 DynArray     : Pointer;
 aArrayOf     : TArrayOf;
 bClass       : TClass;
Begin
 fPropList    := Nil;
 JSONArray    := Nil;
 JSONObject   := TRESTDWJSONObject.Create(Json);
 SetLength(aArrayOf, 0);
 If JSONObject.ObjectType = jtArray Then
  JSONArray   := TRESTDWJSONArray(JSONObject);
 Result := TObject(aClass.Create);
 Try
  If Assigned(JSONObject) Then
   Begin
    aCount := GetPropList(TObject(Result).ClassInfo, tkAny, fPropList);
    aSize  := aCount * SizeOf(Pointer);
    GetMem(fPropList, aSize);
    aCount := GetPropList(TObject(Result).ClassInfo, tkAny, fPropList);
    If Assigned(JSONArray) Then
     bCount := JSONArray.Count
    Else
     bCount := JSONObject.Count;
    Try
//     GetMem(Result, bCount * SizeOf(Pointer));
     For A := 0 To bCount -1 Do
      Begin
       For I := 0 To aCount -1 Do
        Begin
         aPropInfo  := fPropList^[I];
         If Assigned(JSONArray) Then
          bElementName := JSONArray.ElementName
         Else
          bElementName := JSONObject.Elements[A].ElementName;
         If (Lowercase(bElementName) = Lowercase(aPropInfo^.Name)) Or
            ((Lowercase(bElementName) = '') And
             (aPropInfo^.Proptype^{$IFNDEF RESTDWLAZARUS}^{$ENDIF}.Kind In [tkArray, tkDynArray, tkClass])) Then
          Begin
           If Assigned(aPropInfo) Then
            Begin
             Case aPropInfo^.Proptype^{$IFNDEF RESTDWLAZARUS}^{$ENDIF}.Kind Of
              tkInteger,
              tkInt64,
              tkFloat,
              tkChar,
              tkWChar       : Begin //Classes baseadas em Bytes
                               If JSONObject.Elements[A].ElementType in [etString, etDateTime] Then
                                Begin
                                 Try
                                  vDateTime := StrToDateTime(JSONObject.Elements[A].Value);
                                  SetFloatProp(TObject(Result), aPropInfo, Real(vDateTime));
                                 Except
                                 End;
                                End
                               Else If JSONObject.Elements[A].ElementType in [etNumeric] Then
                                SetFloatProp(TObject(Result), aPropInfo, Real(JSONObject.Elements[A].Value))
                               Else
                                SetordProp(TObject(Result), aPropInfo, Integer(JSONObject.Elements[A].Value));
                              End;
              tkLString,
              tkWString,
              {$IFDEF RESTDWLAZARUS}
                tkUString, tkAString,
              {$ELSE}
              {$IF Defined(DELPHIXEUP)}tkUString,{$ELSE}tkAString,{$IFEND}
              {$ENDIF}
              tkString      : Begin  //Classes baseadas em Strings
                               SetStrProp(TObject(Result), aPropInfo, String(JSONObject.Elements[A].Value));
                              End;
              tkClass       : Begin
                               aTypeData  := GetTypeData(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF});
                               If Assigned(aTypeData) Then
                                Begin
                                 aValue := JSONObject.Elements[A].Value;
                                 If aTypeData^.ClassType.InheritsFrom(TStream) Then //Classes baseadas em Stream
                                  Begin
                                   vStream    := DecodeStream(aValue); //TStream(aTypeData^.ClassType.Create);
                                   vStream.Position := 0;
                                   SetObjectProp(TObject(Result), aPropInfo, vStream);
                                  End;
                                End;
                              End;
              tkSet         : Begin
                               bTypeData := GetTypeData(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF})^.CompType{$IFNDEF RESTDWLAZARUS}^{$ENDIF};
                               aBaseData := GetTypeData(bTypeData);
                               OrdValue  := GetOrdProp(TObject(Result), aPropertyInfo);
                               For X := aBaseData^.MinValue To aBaseData^.MaxValue do
                                Begin
                                 aEnumName := GetEnumName(aBaseType, X);
                                 If aEnumName = '' Then
                                  Break;
                                End;
                              End;
              tkRecord      : ;
              tkVariant     : Begin
                               vValue := JSONObject.Elements[A].Value;
                               SetVariantProp(TObject(Result), aPropInfo, vValue);
                              End;
              tkDynArray    : Begin
                               GetDynArrayElTypeInfo(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF}, aElementTypeInfo, Dimensions);
                               bClass := GetTypeData(aElementTypeInfo{$IFDEF RESTDWLAZARUS}^{$ENDIF})^.Classtype;
                               If Assigned(JSONArray) Then
                                JsonToArray(JSONArray.Elements[A], aArrayOf, bClass)
                               Else
                                JsonToArray(TRESTDWJSONBaseObjectClass (JSONObject), aArrayOf, aClass);
                               {$IFDEF RESTDWLAZARUS}
                               SetVariantProp(TObject(Result), aPropInfo, aArrayOf);
                               {$ELSE}
                               SetOrdProp(TObject(Result), aPropInfo, Integer(aArrayOf));
                               {$ENDIF}
                              End;
              tkArray       : ;
              {$IFDEF RESTDWLAZARUS}
              tkBool        : Begin
                               vValue := JSONObject.Elements[A].Value;
                               SetOrdProp(TObject(Result), aPropInfo, Integer(vValue));
                              End;
              {$ENDIF}
              tkEnumeration :
               Begin
                With GettypeData(aPropInfo^.Proptype{$IFNDEF RESTDWLAZARUS}^{$ENDIF})^ Do
                 Begin
                  vValue := JSONObject.Elements[A].Value;
                  If Basetype{$IFNDEF RESTDWLAZARUS}^{$ENDIF} = typeinfo(Boolean) Then
                   SetOrdProp(TObject(Result), aPropInfo, Integer(vValue))
                  Else
                   SetOrdProp(TObject(Result), aPropInfo, JSONObject.Elements[A].Value);
                 End;
               End;
             End;
           End;
          End;
        End;
      End;
    Finally
     FreeMem(fPropList);
    End;
   End;
 Finally
  If Assigned(JSONObject) Then
   FreeAndNil(JSONObject);
 End;
End;

Class Function TRESTDWJSONSerializer.ObjectToJSON(aClass : TBaseClass) : String;
Begin

End;

Class Function TRESTDWJSONSerializer.ReadProperty(Instance : TPersistent;
                                                  PropInfo : PPropInfo) : TBaseClass;
Var
 I,
 aSize,
 aCount    : Integer;
 fPropList : PPropList;
Begin
 Result := Nil;
 aCount := GetPropList(Instance.ClassInfo, tkAny, fPropList);
 aSize  := aCount * SizeOf(Pointer);
 GetMem(fPropList, aSize);
 aCount := GetPropList(Instance.ClassInfo, tkAny, fPropList);
 For I := 0 To aCount -1 Do
  Begin

  End;
End;

End.
