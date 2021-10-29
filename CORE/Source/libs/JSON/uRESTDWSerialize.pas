Unit uRESTDWSerialize;

{$I uRESTDW.inc}

Interface

Uses Classes, Messages, SysUtils, Variants, TypInfo;

{$METHODINFO ON}
Type
 TBaseClass = Class(TComponent)
End;
{$METHODINFO OFF}

 Type
  TRESTDWJSONSerializer = Class(TBaseClass)
 Public
  Class Function JSONtoObject(Json        : String;
                              aClass      : TClass)     : TBaseClass;
  Class Function ObjectToJSON(aClass      : TBaseClass) : String;
 End;


Implementation

Uses uRESTDWDataJSON, uDWJSONTools;

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
     Case aPropInfo^.Proptype^{$IFNDEF FPC}^{$ENDIF}.Kind Of
      tkinteger,
      tkInt64,
      tkFloat,
      tkChar,
      tkWChar       : Result := GetordProp(instance, aPropInfo);
      tkLString,
      tkWString,
      tkString      : Result := GetStrProp(instance, aPropInfo);
      tkclass       : Begin

                      End;
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
          With GettypeData(aPropInfo^.Proptype{$IFNDEF FPC}^{$ENDIF})^ Do
           Begin
            If Basetype{$IFNDEF FPC}^{$ENDIF} = typeinfo(Boolean) Then
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
     Case infoPropriedades^.Proptype^{$IFNDEF FPC}^{$ENDIF}.Kind Of
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

Class Function TRESTDWJSONSerializer.JSONtoObject(Json        : String;
                                                  aClass      : TClass) : TBaseClass;
Var
 JSONObject : TRESTDWJSONObject;
 fPropList  : PPropList;
 aPropInfo  : PPropInfo;
 aTypeData  : PTypeData;
 A, I,
 OrdValue,
 aSize,
 aCount     : Integer;
 aValue,
 aPropValue : Variant;
 vDateTime  : Variant;
 aObject,
 bObj       : TObject;
 vValue     : Boolean;
 vStream    : TStream;
Begin
 fPropList     := Nil;
 JSONObject    := TRESTDWJSONObject.Create(Json);
 aObject       := aClass.Create;
 Try
  If Assigned(JSONObject) Then
   Begin
    aCount := GetPropList(aObject.ClassInfo, tkAny, fPropList);
    aSize  := aCount * SizeOf(Pointer);
    GetMem(fPropList, aSize);
    aCount := GetPropList(aObject.ClassInfo, tkAny, fPropList);
    Try
     For A := 0 To JSONObject.Count -1 Do
      Begin
       For I := 0 To aCount -1 Do
        Begin
         aPropInfo  := fPropList^[I];
         If Lowercase(JSONObject.Elements[A].ElementName) = Lowercase(aPropInfo^.Name) Then
          Begin
           If Assigned(aPropInfo) Then
            Begin
             Case aPropInfo^.Proptype^{$IFNDEF FPC}^{$ENDIF}.Kind Of
              tkinteger,
              tkInt64,
              tkFloat,
              tkChar,
              tkWChar       : Begin //Classes baseadas em Bytes
                               If JSONObject.Elements[A].ElementType in [etString, etDateTime] Then
                                Begin
                                 Try
                                  vDateTime := StrToDateTime(JSONObject.Elements[A].Value);
                                  SetFloatProp(aObject, aPropInfo, Real(vDateTime));
                                 Except
                                 End;
                                End
                               Else If JSONObject.Elements[A].ElementType in [etNumeric] Then
                                SetFloatProp(aObject, aPropInfo, Real(JSONObject.Elements[A].Value))
                               Else
                                SetordProp(aObject, aPropInfo, Integer(JSONObject.Elements[A].Value));
                              End;
              tkLString,
              tkWString,
              {$IFNDEF FPC}
               {$IF CompilerVersion > 22} // Delphi 2010 pra cima
                tkUString,
               {$IFEND}
              {$ELSE}
              tkUString,
              tkAString,
              {$ENDIF}
              tkString      : Begin  //Classes baseadas em Strings
                               SetStrProp(aObject, aPropInfo, String(JSONObject.Elements[A].Value));
                              End;
              tkclass       : Begin
                               aTypeData  := GetTypeData(aPropInfo^.Proptype{$IFNDEF FPC}^{$ENDIF});
                               If Assigned(aTypeData) Then
                                Begin
                                 aValue := JSONObject.Elements[A].Value;
                                 If aTypeData^.ClassType.InheritsFrom(TStream) Then //Classes baseadas em Stream
                                  Begin
                                   vStream    := Decodeb64Stream(aValue);
                                   vStream.Position := 0;
                                   SetObjectProp(aObject, aPropInfo, vStream);
                                  End;
                                End;
                              End;
              tkSet         : ;
              tkRecord      : ;
              tkDynArray    : ;
              tkArray       : ;
              {$IFDEF FPC}
              tkBool        : Begin
                               vValue := JSONObject.Elements[A].Value;
                               SetOrdProp(aObject, aPropInfo, Integer(vValue));
                              End;
              {$ENDIF}                
              tkEnumeration :
               Begin
                With GettypeData(aPropInfo^.Proptype{$IFNDEF FPC}^{$ENDIF})^ Do
                 Begin
                  vValue := JSONObject.Elements[A].Value;
                  If Basetype{$IFNDEF FPC}^{$ENDIF} = typeinfo(Boolean) Then
                   SetOrdProp(aObject, aPropInfo, Integer(vValue))
                  Else
                   SetOrdProp(aObject, aPropInfo, JSONObject.Elements[A].Value);
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
  Result := TBaseClass(aObject);
  If Assigned(JSONObject) Then
   FreeAndNil(JSONObject);
 End;
End;

Class Function TRESTDWJSONSerializer.ObjectToJSON(aClass : TBaseClass) : String;
Begin

End;

End.
