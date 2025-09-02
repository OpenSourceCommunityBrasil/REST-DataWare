unit uRESTDWJSONInterface;

{$I ..\..\Includes\uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
  de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
  Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
  de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
  Fl�vio Motta               - Member Tester and DEMO Developer.
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Criptografia and Devel.
  Eloy                       - Devel.
  Roniery                    - Devel.
}

interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}
Uses
  SysUtils, Classes, Variants,
  {$IFDEF RESTDWFMX} system.json, {$ELSE} uRESTDWJSON, {$ENDIF}
  uRESTDWConsts;

Type
  TElementType = (etObject, etArray, etString, etNumeric, etBoolean);

  TJSONBaseClass = class
  end;

  TJSONBaseObjectClass = class
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
  Private
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
    Destructor  Destroy; Override;
  End;

  TRESTDWJSONInterfaceObject = Class(TJSONBaseObjectClass)
  Private
    Function GetPair(Index: Integer): TRESTDWJSONPair; Overload;
    Function GetPairN(Index: String): TRESTDWJSONPair; Overload;
    Procedure PutPair(Index: Integer; Item: TRESTDWJSONPair); Overload;
    Procedure PutPairN(Index: String; Item: TRESTDWJSONPair); Overload;
  Public
    Constructor Create(JSONValue: String); Overload;
    Destructor  Destroy; Override;
    Function PairCount: Integer;
    Function ToJSON: String;
    Function ClassType: TClass;
    Function OpenArray(key: String): TRESTDWJSONInterfaceArray; Overload;
    Function OpenArray(Index: Integer): TRESTDWJSONInterfaceArray; Overload;
    Property Pairs[Index: Integer]: TRESTDWJSONPair Read GetPair Write PutPair;
    Property PairByName[Index: String]: TRESTDWJSONPair Read GetPairN
      Write PutPairN;
  End;

implementation

Function removestr(Astr: string; Asubstr: string): string;
Begin
  result := stringreplace(Astr, Asubstr, '', [rfReplaceAll, rfIgnoreCase]);
End;

{$IFDEF RESTDWFMX}

Function GetElementJSON(bArray: TJSONObject; Value: String): String;
Var
  I: Integer;
  aJSONObject: TJSONObject;
Begin
  result := '';
  For I := 0 To bArray.Count - 1 do
  Begin
    aJSONObject := TJSONObject.ParseJSONValue(bArray.Get(I).ToJSON)
      as TJSONObject;
    If Uppercase(Value) = Uppercase
      (removestr(aJSONObject.Pairs[0].JsonString.Value, '"')) Then
    Begin
      result := aJSONObject.Pairs[0].JSONValue.ToJSON;
      Break;
    End;
    FreeAndNil(aJSONObject);
  End;
End;
{$ENDIF}

Function TRESTDWJSONInterfaceObject.OpenArray(key: String) : TRESTDWJSONInterfaceArray;
Var
 {$IFDEF RESTDWFMX}
  vEIndex: Integer;
  aJSONObject: TJSONObject;
 {$ENDIF}
 cJSON      : String;
 aJSONArray : TJSONArray;
Begin
  result := TRESTDWJSONInterfaceArray.Create;
  {$IFDEF RESTDWFMX}
  If TJSONObject(JSONObject).ClassName = 'TJSONObject' Then
   Begin
    aJSONObject := TJSONObject.ParseJSONValue(TJSONObject(JSONObject).ToJSON) as TJSONObject;
    aJSONArray := TJSONObject.ParseJSONValue(TJSONObject(aJSONObject).Get(key).JSONValue.ToJSON) as TJSONArray;
    result.vJSONObject := TJSONBaseClass(aJSONArray);
    FreeAndNil(aJSONObject);
   End
  Else
   Begin
    aJSONArray := TJSONObject.ParseJSONValue(GetElementJSON(TJSONObject(JSONObject), key)) as TJSONArray;
    result.vJSONObject := TJSONBaseClass(aJSONArray);
    // (Key).ToJSON) as TJSONArray);
   End;
  {$ELSE}
   If Assigned(result.vJSONObject) Then
    FreeAndNil(result.vJSONObject);
   cJSON              := TJSONObject(vJSONObject).getString(key);
   result.vJSONObject := TJSONBaseClass(TJSONArray.create(cJSON));
  {$ENDIF}
End;

Function TRESTDWJSONInterfaceObject.OpenArray(Index: Integer)
  : TRESTDWJSONInterfaceArray;
{$IFDEF RESTDWFMX}
Var
  vEIndex: Integer;
  aJSONObject: TJSONObject;
  aJSONArray: TJSONArray;
  {$ENDIF}
Begin
  result := TRESTDWJSONInterfaceArray.Create;
  If Assigned(vJSONObject) Then
   FreeAndNil(vJSONObject);
  {$IFDEF RESTDWFMX}
  If TJSONObject(JSONObject).ClassName = 'TJSONObject' Then
  Begin
    aJSONObject := TJSONObject.ParseJSONValue(TJSONObject(JSONObject).ToJSON)
      as TJSONObject;
    aJSONArray := TJSONObject.ParseJSONValue(TJSONObject(aJSONObject)
      .Pairs[Index].JSONValue.ToJSON) as TJSONArray;
    result.vJSONObject := TJSONBaseClass(aJSONArray);
    FreeAndNil(aJSONObject);
  End
  Else
  Begin
    aJSONArray := TJSONObject.ParseJSONValue(TJSONObject(aJSONObject)
      .Pairs[Index].JSONValue.ToJSON) as TJSONArray;
    result.vJSONObject := TJSONBaseClass(aJSONArray);
    // (Key).ToJSON) as TJSONArray);
  End;
  {$ELSE}
  If TJSONObject(JSONObject).ClassName = 'TJSONObject' Then
    result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject)
      .opt(TJSONObject(vJSONObject).names.Get(Index).toString))
  Else If TJSONObject(JSONObject).ClassName = 'TJSONArray' Then
    result.vJSONObject := TJSONBaseClass(TJSONArray(vJSONObject).Get(Index));
  {$ENDIF}
End;

Constructor TRESTDWJSONInterfaceArray.Create;
Begin
 Inherited Create;
 vJSONObject := Nil;
End;

Destructor TRESTDWJSONInterfaceArray.Destroy;
Begin
  If Assigned(vJSONObject) Then
   FreeAndNil(vJSONObject);
  inherited;
End;

Function TRESTDWJSONInterfaceArray.ElementCount: Integer;
Begin
  result := 0;
  If vJSONObject = Nil then
    Exit;
  {$IFDEF RESTDWFMX}
  result := TJSONArray(vJSONObject).Size;
  {$ELSE}
  If TJSONObject(vJSONObject).ClassName = 'TJSONObject' Then
   Begin
    If TJSONObject(vJSONObject).names <> Nil Then
     result := TJSONObject(vJSONObject).names.length;
   End
  Else If TJSONObject(vJSONObject).ClassName = 'TJSONArray' Then
   result := TJSONArray(vJSONObject).length;
  {$ENDIF}
End;

Function TRESTDWJSONInterfaceArray.GetObject(Index: Integer)
  : TRESTDWJSONInterfaceBase;
Var
 {$IFDEF RESTDWFMX}
  aJSONObject : TJSONArray;
  aJSONValue  : TJSONValue;
 {$ELSE}
 cNames : TJSONArray;
 {$ENDIF}
 vJsonString,
 vClassName  : String;
Begin
  result := TRESTDWJSONInterfaceBase.Create(Nil);
  vClassName := TJSONObject(vJSONObject).ClassName;
  If (Uppercase(TJSONObject(vJSONObject).ClassName) = Uppercase('TJSONArray')) Then
   Begin
    {$IFDEF RESTDWFMX}
    aJSONValue := TJSONObject.ParseJSONValue(TJSONObject(JSONObject).Get(Index).ToJSON);
    If aJSONValue is TJSONObject Then
     result.vJSONObject := TJSONBaseClass(aJSONValue as TJSONObject)
    Else
     result.vJSONObject := TJSONBaseClass(aJSONValue);
    {$ELSE}
    If TJSONArray(vJSONObject).isnull(Index) Then
     result.vJSONObject := Nil
    Else
     Begin
      If TJSONArray(vJSONObject).optJSONArray(Index) = Nil Then
       Begin
        vJsonString := TJSONArray(vJSONObject).optString(Index);
        If vJsonString <> '' Then
         Begin
          If vJsonString[InitStrPos] = '[' Then
           result.vJSONObject := TJSONBaseClass(TJSONArray.create(vJsonString))
          Else If vJsonString[InitStrPos] = '{' Then
           result.vJSONObject := TJSONBaseClass(TJSONObject.create(vJsonString))
          Else
           result.vJSONObject := TJSONBaseClass(TJSONObject.create(Format('{"%d"="%s"}', [Index, vJsonString])));
         End
        Else
         result.vJSONObject := Nil;
       End
      Else
       result.vJSONObject := TJSONBaseClass(TJSONArray.create(TJSONArray(vJSONObject).optJSONArray(Index).toString));
     End;
    {$ENDIF}
   End
  Else If (Uppercase(TJSONObject(vJSONObject).ClassName)
    = Uppercase('TJSONObject')) Then
   Begin
    {$IFDEF RESTDWFMX}
    result.vJSONObject := TJSONBaseClass
      (TJSONObject.ParseJSONValue(TJSONObject(vJSONObject).Get(Index)
      .JSONValue.ToJSON) as TJSONArray);
    {$ELSE}
     cNames := TJSONObject(vJSONObject).names;
     vJsonString := TJSONObject(vJSONObject).opt(cNames.Get(Index).toString).toString;
     If vJsonString[InitStrPos] = '[' Then
      result.vJSONObject := TJSONBaseClass(TJSONArray.create(vJsonString))
     Else If vJsonString[InitStrPos] = '{' Then
      result.vJSONObject := TJSONBaseClass(TJSONObject.create(vJsonString))
     Else
      result.vJSONObject := Nil;
     If Assigned(cNames) Then
      FreeAndNil(cNames);
    {$ENDIF}
   End
  Else
   result.vJSONObject := TJSONBaseClass(TJSONObject(vJSONObject));
End;

Function TRESTDWJSONInterfaceArray.ToJSON: String;
Begin
  result := TJSONObject(Self).toString;
End;

Constructor TRESTDWJSONInterfaceObject.Create(JSONValue: String);
Begin
  Inherited Create;
  If JSONValue <> '' Then
  Begin
    If Assigned(vJSONObject) Then
     FreeAndNil(vJSONObject);
    {$IFDEF RESTDWFMX}
    If JSONValue[InitStrPos] = '[' then
      vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue(JSONValue) as TJSONArray)
    Else If JSONValue[InitStrPos] = '{' then
      vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue(JSONValue) as TJSONObject)
    Else
      vJSONObject := TJSONBaseClass(TJSONObject.ParseJSONValue('{}') 	  as TJSONObject)
    {$ELSE}
    If JSONValue[InitStrPos] = '[' then
      vJSONObject := TJSONBaseClass(TJSONArray.Create(JSONValue))
    Else If JSONValue[InitStrPos] = '{' then
      vJSONObject := TJSONBaseClass(TJSONObject.Create(JSONValue))
    Else
      vJSONObject := TJSONBaseClass(TJSONObject.Create('{}'))
    {$ENDIF}
  End;
End;

Destructor TRESTDWJSONInterfaceObject.Destroy;
Begin
 If Assigned(vJSONObject) Then
  FreeAndNil(vJSONObject);
 Inherited;
End;

Function TRESTDWJSONInterfaceObject.GetPairN(Index: String): TRESTDWJSONPair;
Var
  I: Integer;
  vElementName, vClassName: String;
  {$IFDEF RESTDWFMX}
  aJSONObject: TJSONObject;
  vValueJSON: String;
  {$ELSE}
  cNames : TJSONArray;
  {$ENDIF}
Begin
  result.isnull := False;
  result.Value  :=  'null';
  If vJSONObject = Nil Then
  Begin
    result.isnull := True;
    Exit;
  End;
  vClassName := TJSONObject(vJSONObject).ClassName;
  {$IFDEF RESTDWFMX}
  If (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceObject')) Or
    (Uppercase(vClassName) = Uppercase('TJSONObject')) Or
    (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceBase')) Then
  Begin
    If vClassName <> '_String' Then
    Begin
      For I := 0 To TJSONObject(vJSONObject).Count - 1 Do
      Begin
        result.Name := removestr(TJSONObject(vJSONObject)
          .Pairs[I].JsonString.Value, '"');
        If LowerCase(result.Name) <> LowerCase(Index) Then
        Begin
          result.Name := '';
          Continue;
        End;
        If TJSONObject(vJSONObject).Pairs[I].JSONValue is TJSONObject Then
        Begin
          result.ClassName := 'TJSONObject';
          vValueJSON := TJSONObject(vJSONObject).Pairs[I].JSONValue.toString;
          If (vValueJSON = '') Or (Trim(vValueJSON) = '""') then
            result.Value := TJSONObject(vJSONObject).Pairs[I].JSONValue.Value
          Else
            result.Value := vValueJSON;
        End
        Else
        Begin
          result.ClassName := TJSONObject(vJSONObject).Pairs[I]
            .JSONValue.ClassName;
          vValueJSON := TJSONObject(vJSONObject).Pairs[I].JSONValue.Value;
          If (vValueJSON = '') Or (Trim(vValueJSON) = '""') then
            result.Value := TJSONObject(vJSONObject).Pairs[I].JSONValue.toString
          Else
            result.Value := vValueJSON;
        End;
        Break;
      End;
    End;
  End
  Else If Uppercase(vClassName) = Uppercase('TJSONArray') Then
  Begin
    For I := 0 To TJSONObject(vJSONObject).Count - 1 Do
    Begin
      aJSONObject := TJSONObject.ParseJSONValue(TJSONObject(vJSONObject).Get(I)
        .ToJSON) as TJSONObject;
      result.Name := removestr(aJSONObject.Value, '"');
      If LowerCase(result.Name) <> LowerCase(Index) Then
      Begin
        FreeAndNil(aJSONObject);
        result.Name := '';
        Continue;
      End;
      If (aJSONObject.toString = '') Or (Trim(aJSONObject.toString) = '""') then
        result.Value := ''
      Else
        result.Value := aJSONObject.toString;
      result.ClassName := 'TJSONArray';
      FreeAndNil(aJSONObject);
      Break;
    End;
  End;
  {$ELSE}
  If (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceObject')) Or
    (Uppercase(vClassName) = Uppercase('TJSONObject')) Or
    (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceBase')) Then
  Begin
    If vClassName <> '_String' Then
    Begin
     cNames := TJSONObject(vJSONObject).names;
      For I := 0 To cNames.length - 1 Do
       Begin
        If LowerCase(cNames.Get(I).toString) <>
          LowerCase(Index) Then
          Continue;
        result.Name := cNames.Get(I).toString;
        result.Value := TJSONObject(vJSONObject).Get(result.Name).toString;
        result.ClassName := TJSONObject(vJSONObject).Get(result.Name).ClassName;
        Break;
       End;
     If Assigned(cNames) Then
      FreeAndNil(cNames);
    End;
  End
  Else If Uppercase(vClassName) = Uppercase('TJSONArray') Then
  Begin
    For I := 0 To TJSONArray(vJSONObject).length - 1 Do
    Begin
      If LowerCase(TJSONArray(vJSONObject).Get(I).ClassName) <>
        LowerCase('_String') Then
      Begin
        vClassName := TJSONArray(vJSONObject).optJSONObject(I).ClassName;
        result.ClassName := 'TJSONArray';
        cNames := TJSONArray(vJSONObject).optJSONObject(I).names;
        If ((cNames.length > 0)
           And (Uppercase(vClassName) = Uppercase('TJSONArray'))) Then
         Begin
          If (TJSONObject(TJSONArray(vJSONObject).optJSONObject(I))
            .names.length > I) Then
          Begin
            If LowerCase(TJSONObject(TJSONArray(vJSONObject).optJSONObject(I))
              .names.Get(0).toString) <> LowerCase(Index) Then
            Begin
              result.ClassName := '';
              Continue;
            End;
            result.Name := TJSONObject(TJSONArray(vJSONObject).optJSONObject(I))
              .names.Get(0).toString;
            result.Value := TJSONObject(TJSONArray(vJSONObject).optJSONObject(I)
              ).Get(result.Name).toString;
            Break;
          End;
         End
        Else
         Begin
          result.Name := TJSONArray(vJSONObject).Get(I).toString;
          If LowerCase(result.Name) <> LowerCase(Index) Then
          Begin
            result.Name := '';
            Continue;
          End;
          If (Trim(result.Name) = '') Or
            ((Pos('{', result.Name) > 0) Or (Pos('[', result.Name) > 0)) Then
            result.Name := 'arrayobj' + IntToStr(I);
          result.Value := TJSONArray(vJSONObject).opt(I).toString;
          Break;
         End;
        if Assigned(cNames) then
         FreeAndNil(cNames)
      End;
    End;
  End;
  {$ENDIF}
  If Trim(result.ClassName) = '' Then
    result.ClassName := vClassName;
  // Corre��o para null value
  result.isnull := (result.Value = 'null'); // or (Result.Value = '');
  If result.isnull Then
    result.Value := '';
End;

Function TRESTDWJSONInterfaceObject.GetPair(Index: Integer): TRESTDWJSONPair;
Var
  vElementName, vClassName: String;
  {$IFDEF RESTDWFMX}
  aJSONObject: TJSONObject;
  vValueJSON: String;
  {$ELSE}
   cNames : TJSONArray;
  {$ENDIF}
Begin
  result.isnull := False;
  result.Value  :=  'null';
  If vJSONObject = Nil Then
  Begin
    result.isnull := True;
    Exit;
  End;
  vClassName := TJSONObject(vJSONObject).ClassName;
  {$IFDEF RESTDWFMX}
  If (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceObject')) Or
    (Uppercase(vClassName) = Uppercase('TJSONObject')) Or
    (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceBase')) Then
  Begin
    If vClassName <> '_String' Then
    Begin
      If (TJSONObject(vJSONObject).Count > index) Then
      Begin
        result.Name := removestr(TJSONObject(vJSONObject).Pairs[index]
          .JsonString.Value, '"');
        If TJSONObject(vJSONObject).Pairs[index].JSONValue is TJSONObject Then
        Begin
          result.ClassName := 'TJSONObject';
          vValueJSON := TJSONObject(vJSONObject).Pairs[index]
            .JSONValue.toString;
          // removestr(TJSONObject(vJSONObject).Pairs[index].JsonValue.tostring, '"');
          If (vValueJSON = '') Or (Trim(vValueJSON) = '""') then
            result.Value := TJSONObject(vJSONObject).Pairs[index]
              .JSONValue.Value
          else
            result.Value := vValueJSON;
        End
        Else
        Begin
          result.ClassName := TJSONObject(vJSONObject).Pairs[index]
            .JSONValue.ClassName;
          vValueJSON := TJSONObject(vJSONObject).Pairs[index].JSONValue.Value;
          If (vValueJSON = '') Or (Trim(vValueJSON) = '""') then
            result.Value := TJSONObject(vJSONObject).Pairs[index]
              .JSONValue.toString
          else
            result.Value := vValueJSON;
        End;
      End;
    End
    Else
    Begin
      result.Value := TJSONObject(vJSONObject).Pairs[index].JSONValue.Value;
      // removestr(TJSONObject(vJSONObject).Pairs[index].JsonValue.tostring, '"');
      result.ClassName := TJSONObject(vJSONObject).Pairs[index]
        .JSONValue.ClassName;
    End;
  End
  Else If Uppercase(vClassName) = Uppercase('TJSONArray') Then
  Begin
    aJSONObject := TJSONObject.ParseJSONValue(TJSONObject(vJSONObject)
      .Get(index).ToJSON) as TJSONObject;
    result.Name := removestr(aJSONObject.Value, '"');
    If (aJSONObject.toString = '') Or (Trim(aJSONObject.toString) = '""') then
      result.Value := ''
    Else
      result.Value := aJSONObject.toString;
    result.ClassName := 'TJSONArray';
    FreeAndNil(aJSONObject);
  End
  Else
  Begin
    result.Name := '';
    result.Value := TJSONValue(vJSONObject).Value;
    If (result.Value = '') Or (Trim(result.Value) = '""') then
      result.Value := TJSONObject(vJSONObject).ToJSON;
    result.ClassName := 'TJSONValue';
  End;
  {$ELSE}
  If (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceObject')) Or
    (Uppercase(vClassName) = Uppercase('TJSONObject')) Or
    (Uppercase(vClassName) = Uppercase('TRESTDWJSONInterfaceBase')) Then
  Begin
   If vClassName <> '_String' Then
    Begin
     cNames := TJSONObject(vJSONObject).names;
     If cNames.length > 0 Then
      Begin
       If (cNames.length > index) Then
        Begin
          result.Name := cNames.Get(index).toString;
          Try
           IF (TJSONObject(vJSONObject).Get(result.Name) <> Nil)   And
              (TJSONObject(vJSONObject).Get(result.Name) <> CNULL) Then
            result.Value := TJSONObject(vJSONObject).Get(result.Name).toString;
          Except
           result.Value := '';
          End;
         result.ClassName := cNames.Get(index).ClassName;
        End;
      End
     Else
      Begin
       result.Value := TJSONObject(vJSONObject).toString;
       result.ClassName := TJSONObject(vJSONObject).ClassName;
      End;
     If cNames <> Nil Then
      FreeAndNil(cNames);
    End
    Else
    Begin
      result.Value := TJSONObject(vJSONObject).toString;
      result.ClassName := TJSONObject(vJSONObject).ClassName;
    End;
  End
  Else If Uppercase(vClassName) = Uppercase('TJSONArray') Then
  Begin
    If LowerCase(TJSONArray(vJSONObject).Get(index).ClassName) = LowerCase('_String') Then
     Begin
      result.ClassName := '_String';
      result.Name := 'arrayobj' + IntToStr(Index);
      result.Value := TJSONArray(vJSONObject).Get(index).toString;
     End
    Else If LowerCase(TJSONArray(vJSONObject).Get(index).ClassName) = LowerCase('_Integer') Then
     Begin
      result.ClassName := '_Integer';
      result.Name := 'arrayobj' + IntToStr(Index);
      result.Value := TJSONArray(vJSONObject).Get(index).toString;
     End
    Else If LowerCase(TJSONArray(vJSONObject).Get(index).ClassName) = LowerCase('_Double') Then
     Begin
      result.ClassName := '_Double';
      result.Name := 'arrayobj' + IntToStr(Index);
      result.Value := TJSONArray(vJSONObject).Get(index).toString;
     End
    Else
    Begin
     vClassName := TJSONArray(vJSONObject).optJSONObject(index).ClassName;
     result.ClassName := 'TJSONArray';
     cNames := TJSONObject(TJSONArray(vJSONObject).optJSONObject(index)).names;
     If (cNames.length > 0) And (Uppercase(vClassName) = Uppercase('TJSONArray')) Then
      Begin
       If (cNames.length > index) Then
        Begin
         result.Name := cNames.Get(index).toString;
         result.Value := TJSONObject(TJSONArray(vJSONObject).optJSONObject(index)).Get(result.Name).toString;
        End;
      End
     Else
      Begin
       result.Name := TJSONArray(vJSONObject).Get(index).toString;
       If (Trim(result.Name) = '') Or
          ((Pos('{', result.Name) > 0) Or (Pos('[', result.Name) > 0)) Then
        result.Name := 'arrayobj' + IntToStr(Index);
       result.Value := TJSONArray(vJSONObject).opt(Index).toString;
      End;
     If Assigned(cNames) Then
      FreeAndNil(cNames);
    End;
  End
  Else
  Begin
    result.Value := TJSONObject(vJSONObject).toString;
    result.ClassName := TJSONObject(vJSONObject).ClassName;
  End;
  {$ENDIF}
  If Trim(result.ClassName) = '' Then
    result.ClassName := vClassName;
  // Corre��o para null value
  result.isnull := (result.Value = 'null') or (Result.Value = '');
  If result.isnull Then
    result.Value := '';
End;

Function TRESTDWJSONInterfaceObject.PairCount: Integer;
{$IFNDEF RESTDWFMX}
Var
 cNames : TJSONArray;
{$ENDIF}
Begin
  result := 0;
  If vJSONObject = Nil Then
    Exit;
  {$IFDEF RESTDWFMX}
  If vJSONObject <> Nil Then
    result := TJSONObject(vJSONObject).Count;
  {$ELSE}
  If TJSONObject(vJSONObject).ClassName = 'TJSONObject' Then
   Begin
    cNames := TJSONObject(vJSONObject).names;
    If cNames <> Nil Then
     Begin
      result := cNames.length;
      FreeAndNil(cNames);
     End;
   End
  Else
    result := TJSONArray(vJSONObject).length;
  {$ENDIF}
End;

Procedure TRESTDWJSONInterfaceObject.PutPairN(Index: String;
  Item: TRESTDWJSONPair);
Begin

End;

Procedure TRESTDWJSONInterfaceObject.PutPair(Index: Integer;
  Item: TRESTDWJSONPair);
Begin

End;

Function TRESTDWJSONInterfaceObject.ClassType: TClass;
Begin
  If TJSONObject(vJSONObject).ClassType = TJSONObject Then
    result := TRESTDWJSONInterfaceObject
  Else If TJSONObject(vJSONObject).ClassType = TJSONArray Then
    result := TRESTDWJSONInterfaceArray
  Else If TJSONObject(vJSONObject).ClassType = TRESTDWJSONInterfaceBase Then
    result := TRESTDWJSONInterfaceBase
  Else
    result := TJSONObject(vJSONObject).ClassType;
End;

Function TRESTDWJSONInterfaceObject.ToJSON: String;
Begin
  result := TJSONObject(vJSONObject).toString;
End;

{ TRESTDWJSONValueInterface }

Function TRESTDWJSONValueInterface.GetPair(Index: Integer): TRESTDWJSONPair;
Begin
  result.Name := TJSONObject(Self).toString;
  result.Value := TJSONObject(Self).toString;
  result.ClassName := TJSONObject(Self).ClassName;
End;

procedure TRESTDWJSONValueInterface.PutPair(Index: Integer; Value: TRESTDWJSONPair);
begin

end;

constructor TJSONBaseArrayClass.Create;
begin
  If Assigned(vJSONObject) Then
   FreeAndNil(vJSONObject);
  inherited;
end;

destructor TJSONBaseArrayClass.Destroy;
begin
  If Assigned(vJSONObject) Then
   FreeAndNil(vJSONObject);
  inherited;
end;

Function TJSONBaseArrayClass.GetObject: TJSONArray;
Begin
  result := TJSONArray(vJSONObject);
End;

procedure TJSONBaseArrayClass.SetObject(Value: TJSONArray);
begin
 If Assigned(Value) then
  vJSONObject := TJSONBaseClass(Value);
end;

{ TJSONBaseObjectClass }

constructor TJSONBaseObjectClass.Create;
begin
 Inherited Create;
 vJSONObject := Nil;
end;

destructor TJSONBaseObjectClass.Destroy;
begin
  If Assigned(vJSONObject) Then
   FreeAndNil(vJSONObject);
 Inherited;
end;

Function TJSONBaseObjectClass.GetObject: TJSONObject;
Begin
  result := TJSONObject(vJSONObject);
End;

Procedure TJSONBaseObjectClass.SetObject(Value: TJSONObject);
Begin
  vJSONObject := TJSONBaseClass(Value);
End;

{ TRESTDWJSONInterfaceBase }

constructor TRESTDWJSONInterfaceBase.Create(ParentJSON: TJSONBaseClass);
begin
  Inherited Create;
  vJSONObject := ParentJSON;
end;

Destructor TRESTDWJSONInterfaceBase.Destroy;
Begin
  If Assigned(vJSONObject) Then
   FreeAndNil(vJSONObject);
  inherited;
End;

function TRESTDWJSONInterfaceBase.PairCount: Integer;
{$IFNDEF RESTDWFMX}
Var
 cNames : TJSONArray;
{$ENDIF}
begin
  {$IFDEF RESTDWFMX}
  result := TJSONObject(vJSONObject).Count;
  {$ELSE}
   cNames := TJSONObject(vJSONObject).names;
   result := cNames.length;
   FreeAndNil(cNames);
  {$ENDIF}
end;

end.
