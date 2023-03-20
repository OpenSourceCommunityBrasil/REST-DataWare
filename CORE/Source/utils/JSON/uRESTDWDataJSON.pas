unit uRESTDWDataJSON;

{$I ..\..\Includes\uRESTDW.inc}

Interface

Uses
 {$IF Defined(RESTDWLAZARUS) AND not Defined(RESTDWLAMW)}
   LCL,
 {$ELSEIF Defined(RESTDWWINDOWS)}
   Windows,
 {$IFEND}
  SysUtils, uRESTDWDataUtils, Classes, TypInfo, Variants, uRESTDWConsts;

Type
 TRESTDWJSONObjectType  = (jtObject, jtArray, jtValue, jtUnknow);
 TRESTDWJSONElementType = (etString, etNumeric, etInteger, etBoolean, etDateTime, etBlob, etUnknow);

Type
 TRESTDWJSONBaseClass = Class(TObject)
 Private
  vElementType : TRESTDWJSONElementType;
  vValue       : Variant;
  vSpecialChars,
  vIsNull      : Boolean;
  Procedure   SetValue    (aValue : Variant);
 Public
  Constructor Create(aElementType : TRESTDWJSONElementType);
  Destructor  Destroy;Override;
  Procedure   Clear;
  Function    ToJSON              : String;Virtual;
  Property    ElementType         : TRESTDWJSONElementType Read VElementType  Write VElementType;
  Property    Value               : Variant                Read vValue        Write SetValue;
  Property    IsNull              : Boolean                Read vIsNull       Write vIsNull;
  Property    SpecialChars        : Boolean                Read vSpecialChars Write vSpecialChars;
End;

Type
 PRESTDWJSONBaseObjectClass = ^TRESTDWJSONBaseObjectClass;
 TRESTDWJSONBaseObjectClass = Class(TRESTDWJSONBaseClass)
 Private
  vElementName  : String;
  VObjectType   : TRESTDWJSONObjectType;
 Private
  Property ElementType  : TRESTDWJSONElementType Read VElementType  Write VElementType;
 Public
  Function ToJSON       : String; Override;
  Property ElementName  : String                 Read vElementName  Write vElementName;
End;

Type
 PRESTDWJSONString = ^TRESTDWJSONString;
 TRESTDWJSONString = Class(TRESTDWJSONBaseObjectClass)
 Private
 Public
  Constructor Create;
  Property ElementName  : String  Read vElementName  Write vElementName;
  Function ToJSON       : String; Override;
End;

Type
 PRESTDWJSONNumeric = ^TRESTDWJSONNumeric;
 TRESTDWJSONNumeric = Class(TRESTDWJSONBaseObjectClass)
 Private
 Public
  Constructor Create;
  Property ElementName  : String  Read vElementName Write vElementName;
  Function ToJSON       : String; Override;
End;

Type
 PRESTDWJSONInteger = ^TRESTDWJSONInteger;
 TRESTDWJSONInteger = Class(TRESTDWJSONBaseObjectClass)
 Private
 Public
  Constructor Create;
  Property ElementName  : String  Read vElementName Write vElementName;
  Function ToJSON       : String; Override;
End;

Type
 PRESTDWJSONBoolean = ^TRESTDWJSONBoolean;
 TRESTDWJSONBoolean = Class(TRESTDWJSONBaseObjectClass)
 Private
 Public
  Constructor Create;
  Property ElementName  : String  Read vElementName Write vElementName;
  Function ToJSON       : String; Override;
End;

Type
 TRESTDWDateTimeFormat = (dtfFloatValue, dtfString, dtfISO8601, dtfMask);
 PRESTDWJSONDateTime   = ^TRESTDWJSONDateTime;
 TRESTDWJSONDateTime   = Class(TRESTDWJSONBaseObjectClass)
 Private
  vMaskDateTime           : String;
  vDateTimeFormat         : TRESTDWDateTimeFormat;
 Public
  Constructor Create;
  Property ElementName    : String                Read vElementName    Write vElementName;
  Property DateTimeFormat : TRESTDWDateTimeFormat Read vDateTimeFormat Write vDateTimeFormat Default dtfString;
  Property FormatMask     : String                Read vMaskDateTime   Write vMaskDateTime;
  Function ToJSON         : String; Override;
End;

Type
 PRESTDWJSONBlob = ^TRESTDWJSONBlob;
 TRESTDWJSONBlob = Class(TRESTDWJSONBaseObjectClass)
 Private
 Public
  Constructor Create;
  Property ElementName  : String  Read vElementName Write vElementName;
  Function ToJSON       : String; Override;
  Function SaveToFile  (Filename    : String)  : Boolean;
  Function SaveToStream(Var aStream : TStream) : Boolean;
End;

Type
 TRESTDWJSONBase = Class(TObject)
 Private
  vSpecialChars                      : Boolean;
  vList                              : TList;
  vJSONObjectType                    : TRESTDWJSONObjectType;
  vElementName                       : String;
  Procedure ClearList;
  Function  GetRec      (Index       : Integer)               : TRESTDWJSONBaseObjectClass; Overload;
  Procedure PutRec      (Index       : Integer;
                         Item        : TRESTDWJSONBaseObjectClass);                         Overload;
  Function  GetRecName  (Index       : String)                : TRESTDWJSONBaseObjectClass; Overload;
  Procedure PutRecName  (Index       : String;
                         Item        : TRESTDWJSONBaseObjectClass);                         Overload;
  Function  BuildJson   (aObjectType : TRESTDWJSONObjectType) : String;
  Function  GetRecNameIndex(Index    : String) : Integer;
  Procedure ReadJSON(JSON : String);
 Public
  Constructor Create(aObjectType                   : TRESTDWJSONObjectType);Overload;
  Constructor Create(JSON                          : String);Overload;
  Destructor  Destroy; Override;
  Function    AddFloat (Key             : String;
                        Value           : Real)            : Integer;
  Function    AddDateTime(Key             : String;
                          Value           : TDateTime;
                          aDateTimeFormat : TRESTDWDateTimeFormat = dtfString;
                          aFormatMask     : String = '')     : Integer;
  Function    AddNull  (Key             : String;
                        ElementType     : TRESTDWJSONElementType = etString) : Integer;
  Function    Add      (Key,
                        Value           : String)  : Integer;Overload;
  Function    Add      (Key             : String;
                        Value           : Integer)         : Integer;Overload;
  Function    Add      (Key             : String;
                        Value           : Real)            : Integer;Overload;
  Function    Add(Key             : String;
                  Value           : Boolean)         : Integer;Overload;
  Function    Add(Key             : String;
                  Value           : TDateTime;
                  aDateTimeFormat : TRESTDWDateTimeFormat = dtfString;
                  aFormatMask     : String = '')     : Integer;Overload;
  Function    Add(Key             : String;
                  Const Value     : TStream)   : Integer;Overload;
  Function    Add(Key             : String;
                  Value           : TRESTDWJSONBase) : Integer;Overload;
  Function    Add(Value           : String)          : Integer;Overload;
  Function    Add(Value           : Integer)         : Integer;Overload;
  Function    Add(Value           : Real)            : Integer;Overload;
  Function    Add(Value           : Boolean)         : Integer;Overload;
  Function    Add(Value           : TDateTime;
                  aDateTimeFormat : TRESTDWDateTimeFormat = dtfString;
                  aFormatMask     : String = '')     : Integer;Overload;
  Function    Add(Const Value     : TStream)         : Integer;Overload;
  Function    Add(Value           : TRESTDWJSONBase) : Integer;Overload;
  Procedure   Delete(Index        : Integer);Overload;
  Procedure   Delete(aElement     : String); Overload;
  Procedure   Clear;
  Function    Count               : Integer;
  Function    ToJSON              : String;Virtual;
  Function    SaveToFile   (Filename : String)     : Boolean;
  Property    Elements     [Index : Integer]       : TRESTDWJSONBaseObjectClass Read GetRec        Write PutRec; Default;
  Property    ElementByName[Index : String ]       : TRESTDWJSONBaseObjectClass Read GetRecName    Write PutRecName;
  Property    ElementName         : String                                      Read vElementName  Write vElementName;
  Property    ObjectType          : TRESTDWJSONObjectType                       Read vJSONObjectType;
  Property    SpecialChars        : Boolean                                     Read vSpecialChars Write vSpecialChars;
End;

Type
 TRESTDWJSONObject = Class(TRESTDWJSONBase)
 Private
  Property    ObjectType;
 Public
  Function    ToJSON      : String; Override;
  Constructor Create;Overload;
  Constructor Create(JSON : String);Overload;
End;

Type
 TRESTDWJSONArray = Class(TRESTDWJSONBase)
 Private
  Property    ObjectType;
 Public
  Function    ToJSON      : String; Override;
  Constructor Create;Overload;
  Constructor Create(JSON : String);Overload;
End;

Type
 TRESTDWJSONValue = Class(TRESTDWJSONBase)
 Private
  Property    ObjectType;
 Public
  Function    ToJSON              : String;Override;
  Constructor Create;
End;

Function GetItemJSONClass   (Item  : TRESTDWJSONBaseObjectClass) : TRESTDWJSONElementType;
Function ISO8601FromDateTime(Value : TDateTime) : String;
Function DateTimeFromISO8601(Value : String)    : TDateTime;
Function escape_chars       (s     : String)    : String;
Function unescape_chars     (s     : String)    : String;

Implementation

Uses
  uRESTDWTools, uRESTDWJSON, uRESTDWJSONInterface
 {$IFDEF RESTDWFMX}, system.json{$ENDIF};

Function TrashRemove(Value : String) : String;
Begin
 Result := StringReplace(Value,  #13, '', [rfReplaceAll]);
 Result := StringReplace(Result, #10, '', [rfReplaceAll]);
 Result := StringReplace(Result, #9,  '', [rfReplaceAll]);
End;

Function DateTimeFromISO8601(Value : String)    : TDateTime;
 Function ExtractNum(Value  : String;
                     a, len : Integer) : Integer;
 Begin
  Result := StrToIntDef(Copy(Value, a, len), 0);
 End;
 Function ISO8601StrToTime(Const S : String) : TDateTime;
 Begin
  If (Length(s) >= 8) And
         (s[3] = ':') Then
   Result := EncodeTime(ExtractNum(s, 1, 2),
                        ExtractNum(s, 4, 2),
                        ExtractNum(s, 7, 2), 0)
  Else
   Result := 0.0;
 End;
Var
 year,
 month,
 day   : Integer;
Begin
 If (Length(Value) >= 10)  And
         (Value[5]  = '-') And
         (Value[8]  = '-') Then
  Begin
   year      := ExtractNum(Value, 1, 4);
   month     := ExtractNum(Value, 6, 2);
   day       := ExtractNum(Value, 9, 2);
   If (year   = 0) And
      (month  = 0) And
      (day    = 0) Then
    Result   := 0.0
   Else
    Result   := EncodeDate(year, month, day);
   If (Length(Value) > 10)  And
         (Value[11]  = 'T') Then
    Result   := Result + ISO8601StrToTime(Copy(Value, 12, Length(Value)));
  End
 Else
  Result     := ISO8601StrToTime(Value);
End;

Function ISO8601FromDateTime(Value : TDateTime) : String;
Begin
 Result := FormatDateTime('yyyy-mm-dd"T"hh":"nn":"ss', Value);
End;

Function unescape_chars(s : String) : String;
 Function HexValue(C: Char): Byte;
 Begin
  Case C of
   '0'..'9':  Result := Byte(C) - Byte('0');
   'a'..'f':  Result := (Byte(C) - Byte('a')) + 10;
   'A'..'F':  Result := (Byte(C) - Byte('A')) + 10;
   Else raise Exception.Create('Illegal hexadecimal characters "' + C + '"');
  End;
 End;
Var
 C    : Char;
 I,
 ubuf : Integer;
Begin
 Result := '';
 I := InitStrPos;
 While I <= (Length(S) - FinalStrPos) Do
  Begin
   C := S[I];
   Inc(I);
   If C = '\' then
    Begin
     C := S[I];
     Inc(I);
     Case C of
      'b': Result := Result + #8;
      't': Result := Result + #9;
      'n': Result := Result + #10;
      'f': Result := Result + #12;
      'r': Result := Result + #13;
      'u': Begin
            If Not TryStrToInt('$' + Copy(S, I, 4), ubuf) Then
             Raise Exception.Create(format('Invalid unicode \u%s',[Copy(S, I, 4)]));
            Result := result + WideChar(ubuf);
            Inc(I, 4);
           End;
       Else Result := Result + C;
     End;
    End
   Else Result := Result + C;
  End;
End;

Function escape_chars(s : String) : String;
Var
 b, c   : Char;
 i, len : Integer;
 sb, t  : String;
 Const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')', ' '];
 Function toHexString(c : char) : String;
 Begin
  Result := IntToHex(ord(c), 2);
 End;
Begin
 c      := #0;
 {$IFDEF RESTDWLAZARUS}
 b      := #0;
 i      := 0;
 {$ENDIF}
 len    := length(s);
 Result := '';
  //SetLength (s, len+4);
 t      := '';
 sb     := '';
 For  i := InitStrPos to len - FinalStrPos Do
  Begin
   b := c;
   c := s[i];
   Case (c) Of
    '\', '"' : Begin
                sb := sb + '\';
                sb := sb + c;
               End;
    '/' :      Begin
                If (b = '<') Then
                 sb := sb + '\';
                sb := sb + c;
               End;
    #8  :      Begin
                sb := sb + '\b';
               End;
    #9  :      Begin
                sb := sb + '\t';
               End;
    #10 :      Begin
                sb := sb + '\n';
               End;
    #12 :      Begin
                sb := sb + '\f';
               End;
    #13 :      Begin
                sb := sb + '\r';
               End;
    Else       Begin
                If (Not (c in NoConversion)) Then
                 Begin
                    t := '000' + toHexString(c);
                    sb := sb + '\u' + copy (t, Length(t) -3,4);
                 End
                Else
                 sb := sb + c;
               End;
   End;
  End;
 Result := sb;
End;

Function GetItemJSONClass(Item : TRESTDWJSONBaseObjectClass) : TRESTDWJSONElementType;
Begin
 Result := etUnknow;
 If Item is TRESTDWJSONString Then
  Result := etString
 Else If Item is TRESTDWJSONNumeric Then
  Result := etNumeric
 Else If Item is TRESTDWJSONInteger Then
  Result := etInteger
 Else If Item is TRESTDWJSONBoolean Then
  Result := etBoolean
 Else If Item is TRESTDWJSONDateTime Then
  Result := etDateTime
 Else If Item is TRESTDWJSONBlob Then
  Result := etBlob;
End;

Function TRESTDWJSONBase.Add(Key   : String;
                             Value : Integer) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONInteger;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONInteger.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := Key;
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Key,
                             Value        : String) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONString;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONString.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := Key;
 BaseObjectClass^.Value        := Value;
 BaseObjectClass^.SpecialChars := SpecialChars;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.AddFloat(Key        : String;
                                  Value      : Real) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONNumeric;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONNumeric.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := Key;
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Key             : String;
                             Value           : Real)          : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONNumeric;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONNumeric.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := Key;
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Key   : String;
                             Value : Boolean)       : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONBoolean;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONBoolean.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := Key;
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.AddDateTime(Key             : String;
                                     Value           : TDateTime;
                                     aDateTimeFormat : TRESTDWDateTimeFormat = dtfString;
                                     aFormatMask     : String = '')     : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONDateTime;
Begin
 New(BaseObjectClass);
 BaseObjectClass^                := TRESTDWJSONDateTime.Create;
 BaseObjectClass^.SpecialChars   := vSpecialChars;
 BaseObjectClass^.ElementName    := Key;
 BaseObjectClass^.Value          := Value;
 BaseObjectClass^.DateTimeFormat := aDateTimeFormat;
 BaseObjectClass^.FormatMask     := aFormatMask;
 Result                          := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Key             : String;
                             Value           : TDateTime;
                             aDateTimeFormat : TRESTDWDateTimeFormat = dtfString;
                             aFormatMask     : String = '') : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONDateTime;
Begin
 New(BaseObjectClass);
 BaseObjectClass^                := TRESTDWJSONDateTime.Create;
 BaseObjectClass^.SpecialChars   := vSpecialChars;
 BaseObjectClass^.ElementName    := Key;
 BaseObjectClass^.Value          := Value;
 BaseObjectClass^.DateTimeFormat := aDateTimeFormat;
 BaseObjectClass^.FormatMask     := aFormatMask;
 Result                          := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Key         : String;
                             Const Value : TStream) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONBlob;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONBlob.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := Key;
 BaseObjectClass^.Value        := EncodeStream(Value);
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Value : Integer) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONInteger;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONInteger.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := '';
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Value : String)  : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONString;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONString.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := '';
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Key   : String;
                             Value : TRESTDWJSONBase) : Integer;
Var
 BaseObjectClass  : ^TRESTDWJSONBase;
Begin
 New(BaseObjectClass);
 BaseObjectClass^ := Value;
 {$IFDEF RESTDWLAZARUS}
  If BaseObjectClass^.ObjectType = jtArray Then
   ElementName   := Key
  Else
   BaseObjectClass^.ElementName  := Key;
 {$ELSE}
  If BaseObjectClass^.ObjectType = jtArray Then
   ElementName   := Key
  Else
   BaseObjectClass^.ElementName  := Key;
 {$ENDIF}
 BaseObjectClass^.SpecialChars := vSpecialChars;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Value : TRESTDWJSONBase) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONBase;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := Value;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 ElementName                   := '';
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.AddNull(Key         : String;
                                 ElementType : TRESTDWJSONElementType = etString): Integer;
Var
 JSONString   : ^TRESTDWJSONString;
 JSONInteger  : ^TRESTDWJSONInteger;
 JSONBoolean  : ^TRESTDWJSONBoolean;
 JSONNumeric  : ^TRESTDWJSONNumeric;
 JSONDateTime : ^TRESTDWJSONDateTime;
 JSONBlob     : ^TRESTDWJSONBlob;
Begin
 Case ElementType Of
  etString   : Begin
                New(JSONString);
                JSONString^             := TRESTDWJSONString.Create;
                JSONString^.ElementName := Key;
                Result                  := vList.Add(JSONString);
               End;
  etNumeric  : Begin
                New(JSONNumeric);
                JSONNumeric^             := TRESTDWJSONNumeric.Create;
                JSONNumeric^.ElementName := Key;
                Result                   := vList.Add(JSONNumeric);
               End;
  etInteger  : Begin
                New(JSONInteger);
                JSONInteger^             := TRESTDWJSONInteger.Create;
                JSONInteger^.ElementName := Key;
                Result                   := vList.Add(JSONInteger);
               End;
  etBoolean  : Begin
                New(JSONBoolean);
                JSONBoolean^             := TRESTDWJSONBoolean.Create;
                JSONBoolean^.ElementName := Key;
                Result                   := vList.Add(JSONBoolean);
               End;
  etDateTime : Begin
                New(JSONDateTime);
                JSONDateTime^             := TRESTDWJSONDateTime.Create;
                JSONDateTime^.ElementName := Key;
                Result                    := vList.Add(JSONDateTime);
               End;
  etBlob     : Begin
                New(JSONBlob);
                JSONBlob^                 := TRESTDWJSONBlob.Create;
                JSONBlob^.ElementName     := Key;
                Result                    := vList.Add(JSONBlob);
               End;
 End;
End;

Function TRESTDWJSONBase.Add(Value : Boolean) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONBoolean;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONBoolean.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := '';
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Value : Real) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONNumeric;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONNumeric.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := '';
 BaseObjectClass^.Value        := Value;
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Const Value : TStream) : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONBlob;
Begin
 New(BaseObjectClass);
 BaseObjectClass^              := TRESTDWJSONBlob.Create;
 BaseObjectClass^.SpecialChars := vSpecialChars;
 BaseObjectClass^.ElementName  := '';
 BaseObjectClass^.Value        := EncodeStream(Value);
 Result                        := vList.Add(BaseObjectClass);
End;

Function TRESTDWJSONBase.Add(Value           : TDateTime;
                             aDateTimeFormat : TRESTDWDateTimeFormat = dtfString;
                             aFormatMask     : String = '') : Integer;
Var
 BaseObjectClass : ^TRESTDWJSONDateTime;
Begin
 New(BaseObjectClass);
 BaseObjectClass^                := TRESTDWJSONDateTime.Create;
 BaseObjectClass^.SpecialChars   := vSpecialChars;
 BaseObjectClass^.ElementName    := '';
 BaseObjectClass^.Value          := Value;
 BaseObjectClass^.DateTimeFormat := aDateTimeFormat;
 BaseObjectClass^.FormatMask     := aFormatMask;
 Result                          := vList.Add(BaseObjectClass);
End;

Procedure TRESTDWJSONBase.Delete(Index : Integer);
Begin
 If (Index < vList.Count) And (Index > -1) Then
  Begin
   Try
    If Assigned(vList.Items[Index])  Then
     Begin
      Case TRESTDWJSONBaseObjectClass(vList.Items[Index]^).ElementType Of
       etString   : Begin
                     {$IFDEF RESTDWLAZARUS}
                      FreeAndNil(vList.Items[Index]^);
                     {$ELSE}
                      FreeAndNil(TRESTDWJSONString(vList.Items[Index]^));
                     {$ENDIF}
                     Dispose(PRESTDWJSONString(vList.Items[Index]));
                    End;
       etNumeric  : Begin
                     {$IFDEF RESTDWLAZARUS}
                      FreeAndNil(vList.Items[Index]^);
                     {$ELSE}
                      FreeAndNil(TRESTDWJSONNumeric(vList.Items[Index]^));
                     {$ENDIF}
                     Dispose(PRESTDWJSONNumeric(vList.Items[Index]));
                    End;
       etInteger  : Begin
                     {$IFDEF RESTDWLAZARUS}
                      FreeAndNil(vList.Items[Index]^);
                     {$ELSE}
                      FreeAndNil(TRESTDWJSONInteger(vList.Items[Index]^));
                     {$ENDIF}
                     Dispose(PRESTDWJSONInteger(vList.Items[Index]));
                    End;
       etBoolean  : Begin
                     {$IFDEF RESTDWLAZARUS}
                      FreeAndNil(vList.Items[Index]^);
                     {$ELSE}
                      FreeAndNil(TRESTDWJSONBoolean(vList.Items[Index]^));
                     {$ENDIF}
                     Dispose(PRESTDWJSONBoolean(vList.Items[Index]));
                    End;
       etDateTime : Begin
                     {$IFDEF RESTDWLAZARUS}
                      FreeAndNil(vList.Items[Index]^);
                     {$ELSE}
                      FreeAndNil(TRESTDWJSONDateTime(vList.Items[Index]^));
                     {$ENDIF}
                     Dispose(PRESTDWJSONDateTime(vList.Items[Index]));
                    End;
       etBlob     : Begin
                     {$IFDEF RESTDWLAZARUS}
                      FreeAndNil(vList.Items[Index]^);
                     {$ELSE}
                      FreeAndNil(TRESTDWJSONBlob(vList.Items[Index]^));
                     {$ENDIF}
                     Dispose(PRESTDWJSONBlob(vList.Items[Index]));
                    End;
       Else
        Begin
         {$IFDEF RESTDWLAZARUS}
          FreeAndNil(vList.Items[Index]^);
         {$ELSE}
          FreeAndNil(TRESTDWJSONBaseObjectClass(vList.Items[Index]^));
         {$ENDIF}
         Dispose(PRESTDWJSONBaseObjectClass(vList.Items[Index]));
        End;
      End;
    End;
   Except
   End;
   vList.Delete(Index);
  End;
End;

Procedure TRESTDWJSONBase.Clear;
Begin
 ClearList;
End;

Procedure TRESTDWJSONBase.ClearList;
Var
 I : Integer;
Begin
 If Assigned(vList) Then
  Begin
   For I := vList.Count - 1 Downto 0 Do
    Delete(I);
   vList.Clear;
  End;
End;

Constructor TRESTDWJSONBase.Create(aObjectType : TRESTDWJSONObjectType);
Begin
 Inherited Create;
 vSpecialChars   := True;
 vList           := TList.Create;
 vJSONObjectType := aObjectType;
 vElementName    := '';
End;

Procedure TRESTDWJSONBase.Delete(aElement : String);
Var
 vTempValue : Integer;
Begin
 vTempValue := GetRecNameIndex(aElement);
 If vTempValue > -1 Then
  Delete(vTempValue)
 Else
  Raise Exception.Create('Invalid Element...'); 
End;

Destructor TRESTDWJSONBase.Destroy;
Begin
 ClearList;
 If Assigned(vList) Then
  FreeAndNil(vList);
 Inherited;
End;

Function TRESTDWJSONBase.GetRec     (Index : Integer) : TRESTDWJSONBaseObjectClass;
Var
 vObjectClass : TRESTDWJSONBaseObjectClass;
Begin
 Result := Nil;
 If (Index < vList.Count) And (Index > -1) Then
  Begin
   If TRESTDWJSONBase(vList.Items[Index]^).InheritsFrom(TRESTDWJSONBase) Then
    Begin
     If vJSONObjectType = jtobject Then
      Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONObject(vList.Items[Index]^))
     Else If vJSONObjectType = jtArray Then
      Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONArray(vList.Items[Index]^))
     Else If vJSONObjectType = jtValue Then
      Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONValue(vList.Items[Index]^));
    End
   Else
    Begin
     Case TRESTDWJSONBaseObjectClass(vList.Items[Index]^).ElementType Of
      etString   : Result := TRESTDWJSONString(vList.Items[Index]^);
      etNumeric  : Result := TRESTDWJSONNumeric(vList.Items[Index]^);
      etInteger  : Result := TRESTDWJSONInteger(vList.Items[Index]^);
      etBoolean  : Result := TRESTDWJSONBoolean(vList.Items[Index]^);
      etDateTime : Result := TRESTDWJSONDateTime(vList.Items[Index]^);
      etBlob     : Result := TRESTDWJSONBlob(vList.Items[Index]^);
      etUnknow   : Begin
                    If vJSONObjectType = jtobject Then
                     Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONObject(vList.Items[Index]^))
                    Else If vJSONObjectType = jtArray Then
                     Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONArray(vList.Items[Index]^))
                    Else If vJSONObjectType = jtValue Then
                     Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONValue(vList.Items[Index]^));
                   End;
     End;
    End;
  End;
End;

Function TRESTDWJSONBase.GetRecName (Index : String) : TRESTDWJSONBaseObjectClass;
Var
 I         : Integer;
Begin
 Result    := Nil;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For I := 0 To vList.Count - 1 Do
    Begin
     If TRESTDWJSONBase(vList.Items[I]^).InheritsFrom(TRESTDWJSONBase) Then
      Begin
       If vJSONObjectType = jtobject Then
        Begin
         If Uppercase(TRESTDWJSONObject(vList.Items[I]^).ElementName) = Uppercase(Index)  Then
          Begin
           Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONObject(vList.Items[I]^));
           Break;
          End;
        End
       Else If vJSONObjectType = jtArray Then
        Begin
         If Uppercase(TRESTDWJSONArray(vList.Items[I]^).ElementName) = Uppercase(Index)  Then
          Begin
           Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONArray(vList.Items[I]^));
           Break;
          End;
        End
       Else If vJSONObjectType = jtValue Then
        Begin
         If Uppercase(TRESTDWJSONValue(vList.Items[I]^).ElementName) = Uppercase(Index)  Then
          Begin
           Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONValue(vList.Items[I]^));
           Break;
          End;
        End;
      End
     Else
      Begin
       If (Uppercase(Index) = Uppercase(TRESTDWJSONBaseObjectClass(vList.Items[i]^).vElementName)) Then
        Begin
         Case TRESTDWJSONBaseObjectClass(vList.Items[I]^).VElementType Of
          etString   : Result := TRESTDWJSONString(vList.Items[I]^);
          etNumeric  : Result := TRESTDWJSONNumeric(vList.Items[I]^);
          etInteger  : Result := TRESTDWJSONInteger(vList.Items[I]^);
          etBoolean  : Result := TRESTDWJSONBoolean(vList.Items[I]^);
          etDateTime : Result := TRESTDWJSONDateTime(vList.Items[I]^);
          etBlob     : Result := TRESTDWJSONBlob(vList.Items[I]^);
          etUnknow   : Begin
                        If vJSONObjectType = jtobject Then
                         Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONObject(vList.Items[I]^))
                        Else If vJSONObjectType = jtArray Then
                         Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONArray(vList.Items[I]^))
                        Else If vJSONObjectType = jtValue Then
                         Result := TRESTDWJSONBaseObjectClass(TRESTDWJSONValue(vList.Items[I]^));
                       End;
         End;
         Break;
        End;
      End;
    End;
  End;
End;


Function TRESTDWJSONBase.GetRecNameIndex (Index : String) : Integer;
Var
 I         : Integer;
Begin
 Result    := -1;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For I := 0 To vList.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TRESTDWJSONBaseObjectClass(vList.Items[i]^).vElementName)) Then
      Begin
       Result := I;
       Break;
      End;
    End;
  End;
End;

Function TRESTDWJSONBase.Count : Integer;
Begin
 Result := -1;
 If Assigned(vList) Then
  Result := TList(vList).Count;
End;

Constructor TRESTDWJSONBase.Create(JSON : String);
Var
 bJsonValue  : TRESTDWJSONBaseClass;
 bJsonArrayB : TRESTDWJSONArray;
begin
 If JSON = '' Then
  Exit;
 {$IFNDEF RESTDWLAZARUS}
  {$IFDEF RESTDWFMX}
   If JSON[InitStrPos] = '[' then
    bJsonValue  := TRESTDWJSONBaseClass(TJSONObject.ParseJSONValue(JSON) as TJsonArray)
   Else If JSON[InitStrPos] = '{' then
    bJsonValue  := TRESTDWJSONBaseClass(TJSONObject.ParseJSONValue(JSON) as TJsonObject)
   Else
    bJsonValue  := TRESTDWJSONBaseClass(TJSONObject.ParseJSONValue('{}') as TJsonObject);
  {$ELSE}
   If JSON[InitStrPos] = '[' then
    bJsonValue  := TRESTDWJSONBaseClass(TRESTDWJSONArray.Create(JSON))
   Else If JSON[InitStrPos] = '{' then
    bJsonValue  := TRESTDWJSONBaseClass(TRESTDWJSONObject.Create(JSON))
   Else
    bJsonValue  := TRESTDWJSONBaseClass(TRESTDWJSONObject.Create('{}'));
  {$ENDIF}
 {$ELSE}
  Try
   If JSON[InitStrPos] = '[' then
    bJsonValue  := TRESTDWJSONBaseClass(TJSONArray.Create(JSON))
   Else If JSON[InitStrPos] = '{' then
    bJsonValue  := TRESTDWJSONBaseClass(TJSONObject.Create(JSON))
   Else
    bJsonValue  := TRESTDWJSONBaseClass(TJSONObject.Create('{}'));
  Except
   bJsonValue  := Nil;
  End;
 {$ENDIF}
 Try
  If (bJsonValue.ClassType = TRESTDWJSONObject) Or
     (bJsonValue.ClassType = TJSONObject)   Then
   Begin
    Create(jtObject);
    ReadJSON(JSON);
   End
  Else
   Begin
    Create(jtArray);
    ReadJSON(JSON);
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Procedure TRESTDWJSONBase.PutRec    (Index : Integer;
                                     Item  : TRESTDWJSONBaseObjectClass);
Begin
 If (Index < vList.Count) And (Index > -1) Then
  TRESTDWJSONBaseObjectClass(TList(vList).Items[Index]^) := Item;
End;

Procedure TRESTDWJSONBase.PutRecName(Index : String;
                                     Item  : TRESTDWJSONBaseObjectClass);
Var
 I         : Integer;
 vNotFount : Boolean;
Begin
 vNotFount := True;
 If Assigned(Self) And (Lowercase(Index) <> '') Then
  Begin
   For i := 0 To vList.Count - 1 Do
    Begin
     If (Lowercase(Index) = Lowercase(TRESTDWJSONBaseObjectClass(TList(vList).Items[i]^).vElementName)) Then
      Begin
       TRESTDWJSONBaseObjectClass(TList(vList).Items[i]^) := Item;
       vNotFount := False;
       Break;
      End;
    End;
  End;
 If vNotFount Then
  Begin
   Item           := TRESTDWJSONBaseObjectClass.Create(GetItemJSONClass(Item));
   Item.vElementName := Index;
   vList.Add(Item);
  End;
End;

Function TRESTDWJSONBase.BuildJson(aObjectType : TRESTDWJSONObjectType) : String;
Var
 I     : Integer;
 vLine : String;
Begin
 vLine := '';
 Case aObjectType Of
  jtobject : Begin
              Result := '';
              For I := 0 To vList.Count -1 Do
               Begin
                Case GetItemJSONClass(TRESTDWJSONBaseObjectClass(vList.Items[I]^)) of
                 etUnknow   : Begin
                               Case TRESTDWJSONBase(vList.Items[I]^).ObjectType Of
                                jtobject : vLine := TRESTDWJSONObject(vList.Items[I]^).ToJSON;
                                jtArray  : vLine := TRESTDWJSONArray(vList.Items[I]^).ToJSON;
                                jtValue  : vLine := TRESTDWJSONBase(vList.Items[I]^).ToJSON;
                               End;
                              End;
                 etString   : vLine := TRESTDWJSONString  (vList.Items[I]^).ToJSON;
                 etNumeric  : vLine := TRESTDWJSONNumeric (vList.Items[I]^).ToJSON;
                 etInteger  : vLine := TRESTDWJSONInteger (vList.Items[I]^).ToJSON;
                 etBoolean  : vLine := TRESTDWJSONBoolean (vList.Items[I]^).ToJSON;
                 etDateTime : vLine := TRESTDWJSONDateTime(vList.Items[I]^).ToJSON;
                 etBlob     : vLine := TRESTDWJSONBlob    (vList.Items[I]^).ToJSON;
                End;
                If (GetItemJSONClass(TRESTDWJSONBaseObjectClass(vList.Items[I]^)) = etUnknow) And
                   (TRESTDWJSONBase(vList.Items[I]^).ObjectType in [jtobject, jtArray]) Then
                 Begin
                  If (elementname <> '') Then
                   vLine := Format('"%s":%s', [elementname, vLine])
                  Else
                   Begin
                    If TRESTDWJSONBase(vList.Items[I]^).ObjectType = jtobject Then
                     if TRESTDWJSONObject(vList.Items[I]^).ElementName <> '' Then
                     vLine := Format('"%s":%s', [TRESTDWJSONObject(vList.Items[I]^).ElementName, vLine]);
                   End;
                 End;
                If Result = '' Then
                 Result := vLine
                Else
                 Result := Result + ', ' + vLine;
                vLine := '';
               End;
              Result := '{' + Result + '}';
             End;
  jtArray  : Begin
              vLine := '';
              For I := 0 To Count -1 Do
               Begin
                Case TRESTDWJSONBase(vList.Items[I]^).ObjectType Of
                 jtobject : Begin
                             If vLine = '' Then
                              vLine := TRESTDWJSONObject(vList.Items[I]^).ToJSON
                             Else
                              vLine := vLine + ', ' + TRESTDWJSONObject(vList.Items[I]^).ToJSON;
                            End;
                 jtArray  : Begin
                             If vLine = '' Then
                              vLine := TRESTDWJSONArray(vList.Items[I]^).ToJSON
                             Else
                              vLine := vLine + ', ' + TRESTDWJSONArray(vList.Items[I]^).ToJSON;
                            End;
                 jtValue  : Begin
                             If vLine = '' Then
                              vLine := TRESTDWJSONValue(vList.Items[I]^).ToJSON
                             Else
                              vLine := vLine + ', ' + TRESTDWJSONValue(vList.Items[I]^).ToJSON;
                            End;
                End;
               End;
              If elementname <> '' Then
               Result := Format('["%s":%s]', [elementname, vLine])
              Else
               Result := '[' + vLine + ']';
             End;
  jtValue  : Begin
              Result := '';
              For I := 0 To vList.Count -1 Do
               Begin
                Case GetItemJSONClass(TRESTDWJSONBaseObjectClass(vList.Items[I]^)) of
                 etUnknow   : Begin
                               If TRESTDWJSONBase(vList.Items[I]^).ObjectType In [jtobject,
                                                                                      jtArray,
                                                                                      jtValue] Then
                                vLine := TRESTDWJSONBase(vList.Items[I]^).ToJSON;
                              End;
                 etString   : vLine := TRESTDWJSONString  (vList.Items[I]^).ToJSON;
                 etNumeric  : vLine := TRESTDWJSONNumeric (vList.Items[I]^).ToJSON;
                 etInteger  : vLine := TRESTDWJSONInteger (vList.Items[I]^).ToJSON;
                 etBoolean  : vLine := TRESTDWJSONBoolean (vList.Items[I]^).ToJSON;
                 etDateTime : vLine := TRESTDWJSONDateTime(vList.Items[I]^).ToJSON;
                 etBlob     : vLine := TRESTDWJSONBlob    (vList.Items[I]^).ToJSON;
                End;
                If Result = '' Then
                 Result := vLine
                Else
                 Result := Result + ', ' + vLine;
                vLine := '';
               End;
             End;
  jtunknow : Raise Exception.Create('Invalid Unknow Object');
 End;
End;

Function TRESTDWJSONBase.ToJSON : String;
Begin
 Result := BuildJson(vJSONObjectType);
End;

Function TRESTDWJSONBaseObjectClass.ToJSON : String;
Begin
 If VElementType = etUnknow Then
  Raise Exception.Create('Invalid ToJSON to Unknow object...')
 Else
  Result := TRESTDWJSONBaseClass(Self).ToJSON;
End;

Procedure TRESTDWJSONBaseClass.Clear;
Begin
 vValue  := varNull;
 vIsNull := True;
End;

Destructor  TRESTDWJSONBaseClass.Destroy;
Begin
 vValue := '';
 Inherited;
End;

Constructor TRESTDWJSONBaseClass.Create(aElementType : TRESTDWJSONElementType);
Begin
 Inherited Create;
 vSpecialChars := True;
 vElementType  := aElementType;
 vIsNull       := True;
 vValue        := varNull;
End;

Procedure TRESTDWJSONBaseClass.SetValue(aValue : Variant);
Begin
 vValue  := aValue;
 vIsNull := VarIsNull(aValue);
End;

Function TRESTDWJSONBaseClass.ToJSON: String;
Begin
 Raise Exception.Create('Invalid ToJSON to Unknow object...');
End;

Constructor TRESTDWJSONString.Create;
Begin
 Inherited Create(etString);
 vSpecialChars := True;
End;

Function TRESTDWJSONString.ToJSON : String;
Begin
 If vElementName = '' Then
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('%s', ['null'])
   Else
    Begin
     If vSpecialChars Then
      Result := Format('"%s"', [escape_chars(vValue)])
     Else
      Result := Format('"%s"', [vValue]);
    End;
  End
 Else
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('"%s":%s', ['null'])
   Else
    Begin
     If vSpecialChars Then
      Result := Format('"%s":"%s"', [vElementName, escape_chars(vValue)])
     Else
      Result := Format('"%s":"%s"', [vElementName, vValue]);
    End;
  End;
End;

Constructor TRESTDWJSONNumeric.Create;
Begin
 Inherited Create(etNumeric);
End;

Function TRESTDWJSONNumeric.ToJSON : String;
Begin
 If vElementName = '' Then
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('%s', ['null'])
   Else
    Result := Format('%s', [StringReplace(FormatFloat('##0.0#########', vValue), ',', '.', [rfReplaceAll])]);
  End
 Else
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('"%s":%s', ['null'])
   Else
    Result := Format('"%s":%s', [vElementName, StringReplace(FormatFloat('##0.0#########', vValue), ',', '.', [rfReplaceAll])]);
  End;
End;

Constructor TRESTDWJSONInteger.Create;
Begin
 Inherited Create(etInteger);
End;

Function TRESTDWJSONInteger.ToJSON : String;
Begin
 If vElementName = '' Then
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('%s', ['null'])
   Else
    Result := Format('%s', [vValue]);
  End
 Else
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('"%s":%s', ['null'])
   Else
    Result := Format('"%s":%s', [vElementName, vValue]);
  End;
End;

Constructor TRESTDWJSONBoolean.Create;
Begin
 Inherited Create(etBoolean);
End;

Function TRESTDWJSONBoolean.ToJSON : String;
Begin
 If vElementName = '' Then
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('%s', ['null'])
   Else
    If Boolean(vValue) Then
     Result := Format('%s', ['true'])
    Else
     Result := Format('%s', ['false']);
  End
 Else
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('"%s":%s', ['null'])
   Else
    Begin
     If Boolean(vValue) Then
      Result := Format('"%s":%s', [vElementName, 'true'])
     Else
      Result := Format('"%s":%s', [vElementName, 'false']);
    End;
  End;
End;

Constructor TRESTDWJSONDateTime.Create;
Begin
 Inherited Create(etDateTime);
End;

Function TRESTDWJSONDateTime.ToJSON : String;
Begin
 If vElementName = '' Then
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('%s', ['null'])
   Else
    Begin
     Case vDateTimeFormat Of
      dtfString     : Result := Format('"%s"', [vValue]);
      dtfFloatValue : Result := Format('%s', [StringReplace(FormatFloat('##0.0#########', vValue), ',', '.', [rfReplaceAll])]);
      dtfISO8601    : Result := Format('"%s"', [ISO8601FromDateTime(vValue)]);
      dtfMask       : Result := Format('"%s"', [FormatDateTime(vMaskDateTime, vValue)]);
     End;
    End;
  End
 Else
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('"%s":%s', ['null'])
   Else
    Begin
     Case vDateTimeFormat Of
      dtfString     : Result := Format('"%s":"%s"', [vElementName, vValue]);
      dtfFloatValue : Result := Format('"%s":%s',   [vElementName, StringReplace(FormatFloat('##0.0#########', vValue), ',', '.', [rfReplaceAll])]);
      dtfISO8601    : Result := Format('"%s":"%s"', [vElementName, ISO8601FromDateTime(vValue)]);
      dtfMask       : Result := Format('"%s":"%s"', [vElementName, FormatDateTime(vMaskDateTime, vValue)]);
     End;
    End;
  End;
End;

Constructor TRESTDWJSONBlob.Create;
Begin
 Inherited Create(etBlob);
End;

Function TRESTDWJSONBlob.SaveToFile  (Filename    : String) : Boolean;
Var
 vStringStream : TMemoryStream;
Begin
 Result        := False;
 vStringStream := DecodeStream(vValue);
 Try
  If Assigned(vStringStream) Then
   Begin
    vStringStream.SaveToFile(Filename);
    Result        := True;
   End;
 Except

 End;
 If Assigned(vStringStream) Then
  FreeAndNil(vStringStream);
End;

Function TRESTDWJSONBlob.SaveToStream(Var aStream : TStream) : Boolean;
Begin
 Result  := False;
 aStream := DecodeStream(vValue);
 Try
  Result := Assigned(aStream);
  If Result Then
   Result := aStream.Size > 0;
 Except

 End;
End;

Function TRESTDWJSONBlob.ToJSON : String;
Begin
 If vElementName = '' Then
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('%s', ['null'])
   Else
    Result := Format('"%s"', [vValue]);
  End
 Else
  Begin
   If (VarIsNull(vValue)) And (IsNull)  Then
    Result := Format('"%s":%s', ['null'])
   Else
    Result := Format('"%s":"%s"', [vElementName, vValue]);
  End;
End;

Constructor TRESTDWJSONObject.Create;
Begin
 Inherited Create(jtobject);
End;

Constructor TRESTDWJSONArray.Create;
Begin
 Inherited Create(jtArray);
End;

Constructor TRESTDWJSONValue.Create;
Begin
 Inherited Create(jtValue);
End;

Procedure TRESTDWJSONBase.ReadJSON(JSON : String);
Var
 I            : Integer;
 vReal        : Real;
 bJsonValue   : TRESTDWJSONInterfaceObject;
 JSONBase     : TRESTDWJSONBase;
 DecimalLocal : String;
begin
  {$IF Defined(RESTDWLAZARUS) or not Defined(DELPHIXEUP)}
  DecimalLocal := DecimalSeparator;
  {$ELSE}
  DecimalLocal := FormatSettings.DecimalSeparator;
  {$IFEND}
 bJsonValue  := TRESTDWJSONInterfaceObject.Create(TrashRemove(JSON));
 Try
  If Assigned(vList) Then
   Clear;
  If bJsonValue.PairCount > 0 Then
   Begin
    For I := 0 To bJsonValue.PairCount -1 Do
     Begin
      If (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TJSONObject'))   Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TDWJSONObject')) Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TJSONArray'))    Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TDWJSONArray'))  Then
       Begin
        JSONBase     := TRESTDWJSONBase.Create(bJsonValue.pairs[I].Value);
//        If bJsonValue.pairs[I].Name <> '' Then
        If Assigned(JSONBase) Then
         If bJsonValue.pairs[I].Name <> '' Then
          Add(bJsonValue.pairs[I].Name, JSONBase)
         Else
          Add(JSONBase);
       End
      Else
       Begin
        If (Lowercase(bJsonValue.pairs[I].classname) = '_string')     Or
           (Lowercase(bJsonValue.pairs[I].classname) = 'tjsonstring') Then
         Begin
          If (bJsonValue.pairs[I].Value <> cNullvalue)    And
             (bJsonValue.pairs[I].Value <> cNullvalueTag) Then
           Add(bJsonValue.pairs[I].Name, bJsonValue.pairs[I].Value)
          Else
           AddNull(bJsonValue.pairs[I].Name);
         End
        Else If (Lowercase(bJsonValue.pairs[I].classname) = '_integer')     Or
                (Lowercase(bJsonValue.pairs[I].classname) = 'tjsoninteger') Then
         Begin
          If (bJsonValue.pairs[I].Value <> cNullvalue)    And
             (bJsonValue.pairs[I].Value <> cNullvalueTag) Then
           Add(bJsonValue.pairs[I].Name, StrToInt(bJsonValue.pairs[I].Value))
          Else
           AddNull(bJsonValue.pairs[I].Name, etInteger);
         End
        Else If (Lowercase(bJsonValue.pairs[I].classname) = '_double')     Or
                (Lowercase(bJsonValue.pairs[I].classname) = 'tjsonnumber') Then
         Begin
          If (bJsonValue.pairs[I].Value <> cNullvalue)    And
             (bJsonValue.pairs[I].Value <> cNullvalueTag) Then
           Begin
            vReal := StrToFloat(StringReplace(bJsonValue.pairs[I].Value, '.', DecimalLocal, [rfReplaceAll]));
            AddFloat(bJsonValue.pairs[I].Name, vReal);
           End
          Else
           AddNull(bJsonValue.pairs[I].Name, etNumeric);
         End
        Else If (Lowercase(bJsonValue.pairs[I].classname) = '_boolean')     Or
                (Lowercase(bJsonValue.pairs[I].classname) = 'tjsonboolean') Then
         Begin
          If (bJsonValue.pairs[I].Value <> cNullvalue)    And
             (bJsonValue.pairs[I].Value <> cNullvalueTag) Then
           Add(bJsonValue.pairs[I].Name, StringToBoolean(bJsonValue.pairs[I].Value))
          Else
           AddNull(bJsonValue.pairs[I].Name, etBoolean);
         End;
       End;
     End;
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Function TRESTDWJSONBase.SaveToFile(Filename : String): Boolean;
Var
 vStringStream : TStringStream;
 vMemStream    : TMemoryStream;
Begin
 Result        := False;
 vStringStream := TStringStream.Create(ToJSON);
 If vStringStream.Size > 0 Then
  Begin
   vMemStream    := TMemoryStream.Create;
   Try
    vStringStream.Position := 0;
    vMemStream.CopyFrom(vStringStream, vStringStream.Size);
    vMemStream.Position := 0;
    vMemStream.SaveToFile(Filename);
    Result        := True;
   Except

   End;
   If Assigned(vMemStream) Then
    FreeAndNil(vMemStream);
  End;
 If Assigned(vStringStream) Then
  FreeAndNil(vStringStream);
End;

Constructor TRESTDWJSONObject.Create(JSON: String);
Var
 vValue : String;
Begin
 vValue := Trim(JSON);
 If vValue <> '' Then
  Begin
   If vValue[InitStrPos] = '[' Then
    Inherited Create(jtArray)
   Else
    Inherited Create(jtobject);
   If JSON <> '' Then
    ReadJSON(JSON);
  End;
End;

Function TRESTDWJSONObject.ToJSON : String;
Begin
 Result := Inherited ToJSON;
End;

Constructor TRESTDWJSONArray.Create(JSON : String);
Begin
 Inherited Create(jtArray);
 If JSON <> '' Then
  ReadJSON(JSON);
End;

Function TRESTDWJSONArray.ToJSON : String;
Begin
 Result := Inherited ToJSON;
End;

Function TRESTDWJSONValue.ToJSON : String;
Begin
 Result := Inherited ToJSON;
End;

End.
