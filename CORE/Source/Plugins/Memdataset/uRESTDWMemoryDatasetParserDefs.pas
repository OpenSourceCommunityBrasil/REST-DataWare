Unit uRESTDWMemoryDatasetParserDefs;

Interface

{$I uRESTDW.inc}
{$DEFINE RESTDW_SUPPORT_INT64}

Uses
  SysUtils,
  Classes,
  Db,
  uRESTDWMemoryDatasetParserSupport;

Const
  MaxArg = 6;
  ArgAllocSize = 32;

Type
  TRESTDWMemExpressionType = (etInteger, etString, etBoolean, etLargeInt, etFloat, etDateTime,
    etLeftBracket, etRightBracket, etComma, etUnknown);

  ERESTDWMemParserException = Class(Exception);
  PRESTDWMemExpressionRec = ^TRESTDWMemExpressionRec;
  PRESTDWMemDynamicType = ^TRESTDWMemDynamicType;
  PRESTDWMemDateTimeRec = ^TDateTimeRec;
{$IFDEF RESTDW_SUPPORT_INT64}
  PRESTDWMemLargeInt = ^Int64;
{$ENDIF}

  TRESTDWMemExprWord = Class;

  TRESTDWMemExprFunc = Procedure(Expr: PRESTDWMemExpressionRec);

//-----

  TRESTDWMemDynamicType = Class(TObject)
  Private
    FMemory: PPChar;
    FMemoryPos: PPChar;
    FSize: PInteger;
  Public
    Constructor Create(DestMem, DestPos: PPChar; ASize: PInteger);

    Procedure AssureSpace(ASize: Integer);
    Procedure Resize(NewSize: Integer; Exact: Boolean);
    Procedure Rewind;
    Procedure Append(Source: PChar; Length: Integer);
    Procedure AppendInteger(Source: Integer);

    property Memory: PPChar read FMemory;
    property MemoryPos: PPChar read FMemoryPos;
    property Size: PInteger read FSize;
  End;

  TRESTDWMemExpressionRec = Record
    //used both as linked tree and linked list for maximum evaluation efficiency
    Oper: TRESTDWMemExprFunc;
    Next: PRESTDWMemExpressionRec;
    Res: TRESTDWMemDynamicType;
    ExprWord: TRESTDWMemExprWord;
    AuxData: pointer;
    ResetDest: boolean;
    WantsFunction: boolean;
    Args: array[0..MaxArg-1] Of PChar;
    ArgsPos: array[0..MaxArg-1] Of PChar;
    ArgsSize: array[0..MaxArg-1] Of Integer;
    ArgsType: array[0..MaxArg-1] Of TRESTDWMemExpressionType;
    ArgList: array[0..MaxArg-1] Of PRESTDWMemExpressionRec;
  End;

  TRESTDWMemExprCollection = Class(TRESTDWMemNoOwnerCollection)
  Public
    Procedure Check;
    Procedure EraseExtraBrackets;
  End;

  TRESTDWMemExprWordRec = Record
    Name: PChar;
    ShortName: PChar;
    IsOperator: Boolean;
    IsVariable: Boolean;
    IsFunction: Boolean;
    NeedsCopy: Boolean;
    FixedLen: Boolean;
    CanVary: Boolean;
    ResultType: TRESTDWMemExpressionType;
    MinArg: Integer;
    MaxArg: Integer;
    TypeSpec: PChar;
    Description: PChar;
    ExprFunc: TRESTDWMemExprFunc;
  End;

  TRESTDWMemExprWord = Class(TObject)
  Private
    FName: string;
    FExprFunc: TRESTDWMemExprFunc;
  Protected
    FRefCount: Cardinal;

    Function GetIsOperator: Boolean; virtual;
    Function GetIsVariable: Boolean;
    Function GetNeedsCopy: Boolean;
    Function GetFixedLen: Integer; virtual;
    Function GetCanVary: Boolean; virtual;
    Function GetResultType: TRESTDWMemExpressionType; virtual;
    Function GetMinFunctionArg: Integer; virtual;
    Function GetMaxFunctionArg: Integer; virtual;
    Function GetDescription: string; virtual;
    Function GetTypeSpec: string; virtual;
    Function GetShortName: string; virtual;
    Procedure SetFixedLen(NewLen: integer); virtual;
  Public
    Constructor Create(AName: string; AExprFunc: TRESTDWMemExprFunc);

    Function LenAsPointer: PInteger; virtual;
    Function AsPointer: PChar; virtual;
    Function IsFunction: Boolean; virtual;

    property ExprFunc: TRESTDWMemExprFunc read FExprFunc;
    property IsOperator: Boolean read GetIsOperator;
    property CanVary: Boolean read GetCanVary;
    property IsVariable: Boolean read GetIsVariable;
    property NeedsCopy: Boolean read GetNeedsCopy;
    property FixedLen: Integer read GetFixedLen write SetFixedLen;
    property ResultType: TRESTDWMemExpressionType read GetResultType;
    property MinFunctionArg: Integer read GetMinFunctionArg;
    property MaxFunctionArg: Integer read GetMaxFunctionArg;
    property Name: string read FName;
    property ShortName: string read GetShortName;
    property Description: string read GetDescription;
    property TypeSpec: string read GetTypeSpec;
  End;

  TRESTDWMemExpressShortList = Class(TRESTDWMemSortedCollection)
  Public
    Function KeyOf(Item: Pointer): Pointer; override;
    Function Compare(Key1, Key2: Pointer): Integer; override;
    Procedure FreeItem(Item: Pointer); override;
  End;

  TRESTDWMemExpressList = Class(TRESTDWMemSortedCollection)
  Private
    FShortList: TRESTDWMemExpressShortList;
  Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure Add(Item: Pointer); override;
    Function  KeyOf(Item: Pointer): Pointer; override;
    Function  Compare(Key1, Key2: Pointer): Integer; override;
    Function  Search(Key: Pointer; Var Index: Integer): Boolean; override;
    Procedure FreeItem(Item: Pointer); override;
  End;

  TRESTDWMemConstant = Class(TRESTDWMemExprWord)
  Private
    FResultType: TRESTDWMemExpressionType;
  Protected
    Function GetResultType: TRESTDWMemExpressionType; override;
  Public
    Constructor Create(AName: string; AVarType: TRESTDWMemExpressionType; AExprFunc: TRESTDWMemExprFunc);
  End;

  TRESTDWMemFloatConstant = Class(TRESTDWMemConstant)
  Private
    FValue: Double;
  Public
    // not overloaded to support older Delphi versions
    Constructor Create(AName: string; AValue: string);
    Constructor CreateAsDouble(AName: string; AValue: Double);

    Function AsPointer: PChar; override;

    property Value: Double read FValue write FValue;
  End;

  TRESTDWMemUserConstant = Class(TRESTDWMemFloatConstant)
  Private
    FDescription: string;
  Protected
    Function GetDescription: string; override;
  Public
    Constructor CreateAsDouble(AName, Descr: string; AValue: Double);
  End;

  TRESTDWMemStringConstant = Class(TRESTDWMemConstant)
  Private
    FValue: string;
  Public
    // Allow undelimited, delimited by single quotes, delimited by double quotes
    // If delimited, allow escaping inside string with double delimiters
    Constructor Create(AValue: string);

    Function AsPointer: PChar; override;
  End;

  TRESTDWMemIntegerConstant = Class(TRESTDWMemConstant)
  Private
    FValue: Integer;
  Public
    Constructor Create(AValue: Integer);

    Function AsPointer: PChar; override;
  End;

{$IFDEF RESTDW_SUPPORT_INT64}
  TRESTDWMemLargeIntConstant = Class(TRESTDWMemConstant)
  Private
    FValue: Int64;
  Public
    Constructor Create(AValue: Int64);

    Function AsPointer: PChar; override;
  End;
{$ENDIF}

  TRESTDWMemBooleanConstant = Class(TRESTDWMemConstant)
  Private
    FValue: Boolean;
  Public
    // not overloaded to support older Delphi versions
    Constructor Create(AName: string; AValue: Boolean);

    Function AsPointer: PChar; override;

    property Value: Boolean read FValue write FValue;
  End;

  TRESTDWMemVariable = Class(TRESTDWMemExprWord)
  Private
    FResultType: TRESTDWMemExpressionType;
  Protected
    Function GetCanVary: Boolean; override;
    Function GetResultType: TRESTDWMemExpressionType; override;
  Public
    Constructor Create(AName: string; AVarType: TRESTDWMemExpressionType; AExprFunc: TRESTDWMemExprFunc);
  End;

  TRESTDWMemFloatVariable = Class(TRESTDWMemVariable)
  Private
    FValue: PDouble;
  Public
    Constructor Create(AName: string; AValue: PDouble);

    Function AsPointer: PChar; override;
  End;

  TRESTDWMemStringVariable = Class(TRESTDWMemVariable)
  Private
    FValue: PPChar;
    FFixedLen: Integer;
  Protected
    Function GetFixedLen: Integer; override;
    Procedure SetFixedLen(NewLen: integer); override;
  Public
    Constructor Create(AName: string; AValue: PPChar);

    Function LenAsPointer: PInteger; override;
    Function AsPointer: PChar; override;

    property FixedLen: Integer read FFixedLen;
  End;

  TRESTDWMemDateTimeVariable = Class(TRESTDWMemVariable)
  Private
    FValue: PRESTDWMemDateTimeRec;
  Public
    Constructor Create(AName: string; AValue: PRESTDWMemDateTimeRec);

    Function AsPointer: PChar; override;
  End;

  TRESTDWMemIntegerVariable = Class(TRESTDWMemVariable)
  Private
    FValue: PInteger;
  Public
    Constructor Create(AName: string; AValue: PInteger);

    Function AsPointer: PChar; override;
  End;

{$IFDEF RESTDW_SUPPORT_INT64}

  TRESTDWMemLargeIntVariable = Class(TRESTDWMemVariable)
  Private
    FValue: PRESTDWMemLargeInt;
  Public
    Constructor Create(AName: string; AValue: PRESTDWMemLargeInt);

    Function AsPointer: PChar; override;
  End;

{$ENDIF}

  TRESTDWMemBooleanVariable = Class(TRESTDWMemVariable)
  Private
    FValue: PBoolean;
  Public
    Constructor Create(AName: string; AValue: PBoolean);

    Function AsPointer: PChar; override;
  End;

  TRESTDWMemLeftBracket = Class(TRESTDWMemExprWord)
    Function GetResultType: TRESTDWMemExpressionType; override;
  End;

  TRESTDWMemRightBracket = Class(TRESTDWMemExprWord)
  Protected
    Function GetResultType: TRESTDWMemExpressionType; override;
  End;

  TRESTDWMemComma = Class(TRESTDWMemExprWord)
  Protected
    Function GetResultType: TRESTDWMemExpressionType; override;
  End;

  TRESTDWMemFunction = Class(TRESTDWMemExprWord)
  Private
    FIsOperator: Boolean;
    FOperPrec: Integer;
    FMinFunctionArg: Integer;
    FMaxFunctionArg: Integer;
    FDescription: string;
    FTypeSpec: string;
    FShortName: string;
    FResultType: TRESTDWMemExpressionType;
  Protected
    Function GetDescription: string; override;
    Function GetIsOperator: Boolean; override;
    Function GetMinFunctionArg: Integer; override;
    Function GetMaxFunctionArg: Integer; override;
    Function GetResultType: TRESTDWMemExpressionType; override;
    Function GetTypeSpec: string; override;
    Function GetShortName: string; override;

    Procedure InternalCreate(AName, ATypeSpec: string; AMinFuncArg: Integer; AResultType: TRESTDWMemExpressionType;
      AExprFunc: TRESTDWMemExprFunc; AIsOperator: Boolean; AOperPrec: Integer);
  Public
    Constructor Create(AName, AShortName, ATypeSpec: string; AMinFuncArg: Integer; AResultType: TRESTDWMemExpressionType; AExprFunc: TRESTDWMemExprFunc; Descr: string);
    // Create operator: name, param types used, result type, func addr, operator precedence
    Constructor CreateOper(AName, ATypeSpec: string; AResultType: TRESTDWMemExpressionType; AExprFunc: TRESTDWMemExprFunc; AOperPrec: Integer);

    Function IsFunction: Boolean; override;

    property OperPrec: Integer read FOperPrec;
    property TypeSpec: string read FTypeSpec;
  End;

  TRESTDWMemVaryingFunction = Class(TRESTDWMemFunction)
    // Functions that can vary e.g. random generators
    // should be TRESTDWMemVaryingFunction to ensure that they are
    // always evaluated
  Protected
    Function GetCanVary: Boolean; override;
  End;

Const
  ListChar = ','; {the delimiter used with the 'in' operator: e.g.,
  ('a' in 'a,b') =True
  ('c' in 'a,b') =False}

Function ExprCharToExprType(ExprChar: Char): TRESTDWMemExpressionType;

Implementation

Function ExprCharToExprType(ExprChar: Char): TRESTDWMemExpressionType;
Begin
 Case ExprChar Of
 'B': Result := etBoolean;
 'I': Result := etInteger;
 'L': Result := etLargeInt;
 'F': Result := etFloat;
 'D': Result := etDateTime;
 'S': Result := etString;
 Else
 Result := etUnknown;
End;
End;

Procedure _FloatVariable(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^;
End;

Procedure _BooleanVariable(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PBoolean(Res.MemoryPos^)^ := PBoolean(Args[0])^;
End;

Procedure _StringConstant(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.Append(Args[0], StrLen(Args[0]));
End;

Procedure _StringVariable(Param: PRESTDWMemExpressionRec);
Var
 length: integer;
Begin
 With Param^ Do
  Begin
   length := PInteger(Args[1])^;
   If length = -1 Then
   length := StrLen(PPChar(Args[0])^);
   Res.Append(PPChar(Args[0])^, length);
  End;
End;

Procedure _DateTimeVariable(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PRESTDWMemDateTimeRec(Res.MemoryPos^)^ := PRESTDWMemDateTimeRec(Args[0])^;
End;

Procedure _IntegerVariable(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^;
End;

{
Procedure _SmallIntVariable(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ do
 PSmallInt(Res.MemoryPos^)^ := PSmallInt(Args[0])^;
End;
}

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure _LargeIntVariable(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PRESTDWMemLargeInt(Res.MemoryPos^)^ := PRESTDWMemLargeInt(Args[0])^;
End;

{$ENDIF}

{ TExpressionWord }

Constructor TRESTDWMemExprWord.Create(AName: string; AExprFunc: TRESTDWMemExprFunc);
Begin
 FName := AName;
 FExprFunc := AExprFunc;
End;

Function TRESTDWMemExprWord.GetCanVary: Boolean;
Begin
 Result := False;
End;

Function TRESTDWMemExprWord.GetDescription: string;
Begin
 Result := EmptyStr;
End;

Function TRESTDWMemExprWord.GetShortName: string;
Begin
 Result := EmptyStr;
End;

Function TRESTDWMemExprWord.GetIsOperator: Boolean;
Begin
 Result := False;
End;

Function TRESTDWMemExprWord.GetIsVariable: Boolean;
Begin
{$IFDEF FPC}
 Result := (Pointer(FExprFunc) = Pointer(@_StringVariable)) Or
           (Pointer(FExprFunc) = Pointer(@_StringConstant)) Or
           (Pointer(FExprFunc) = Pointer(@_FloatVariable)) Or
           (Pointer(FExprFunc) = Pointer(@_IntegerVariable)) Or
{$IFDEF RESTDW_SUPPORT_INT64}
           (Pointer(FExprFunc) = Pointer(@_LargeIntVariable)) Or
{$ENDIF}
           (Pointer(FExprFunc) = Pointer(@_DateTimeVariable)) Or
           (Pointer(FExprFunc) = Pointer(@_BooleanVariable));
{$ELSE}
 Result := (@FExprFunc = @_StringVariable) Or
           (@FExprFunc = @_StringConstant) Or
           (@FExprFunc = @_FloatVariable) Or
           (@FExprFunc = @_IntegerVariable) Or
{$IFDEF RESTDW_SUPPORT_INT64}
           (@FExprFunc = @_LargeIntVariable) Or
{$ENDIF}
           (@FExprFunc = @_DateTimeVariable) Or
           (@FExprFunc = @_BooleanVariable);
{$ENDIF}
End;

Function TRESTDWMemExprWord.GetNeedsCopy: Boolean;
Begin
{$IFDEF FPC}
 Result := (Pointer(FExprFunc) <> Pointer(@_StringConstant)) And
           (Pointer(FExprFunc) <> Pointer(@_FloatVariable)) And
           (Pointer(FExprFunc) <> Pointer(@_IntegerVariable)) And
{$IFDEF RESTDW_SUPPORT_INT64}
           (Pointer(FExprFunc) <> Pointer(@_LargeIntVariable)) And
{$ENDIF}
           (Pointer(FExprFunc) <> Pointer(@_DateTimeVariable)) And
           (Pointer(FExprFunc) <> Pointer(@_BooleanVariable));
{$ELSE}
 Result := (@FExprFunc <> @_StringConstant) And
           (@FExprFunc <> @_FloatVariable) And
           (@FExprFunc <> @_IntegerVariable) And
{$IFDEF RESTDW_SUPPORT_INT64}
           (@FExprFunc <> @_LargeIntVariable) And
{$ENDIF}
           (@FExprFunc <> @_DateTimeVariable) And
           (@FExprFunc <> @_BooleanVariable);
{$ENDIF}
End;

Function TRESTDWMemExprWord.GetFixedLen: Integer;
Begin
 // -1 means variable, non-fixed length
 Result := -1;
End;

Function TRESTDWMemExprWord.GetMinFunctionArg: Integer;
Begin
 Result := 0;
End;

Function TRESTDWMemExprWord.GetMaxFunctionArg: Integer;
Begin
 Result := 0;
End;

Function TRESTDWMemExprWord.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := etUnknown;
End;

Function TRESTDWMemExprWord.GetTypeSpec: string;
Begin
 Result := EmptyStr;
End;

Function TRESTDWMemExprWord.AsPointer: PChar;
Begin
 Result := nil;
End;

Function TRESTDWMemExprWord.LenAsPointer: PInteger;
Begin
 Result := nil;
End;

Function TRESTDWMemExprWord.IsFunction: Boolean;
Begin
 Result := False;
End;

Procedure TRESTDWMemExprWord.SetFixedLen(NewLen: integer);
Begin
End;

{ TRESTDWMemConstant }

Constructor TRESTDWMemConstant.Create(AName: string; AVarType: TRESTDWMemExpressionType; AExprFunc: TRESTDWMemExprFunc);
Begin
 Inherited Create(AName, AExprFunc);

 FResultType := AVarType;
End;

Function TRESTDWMemConstant.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := FResultType;
End;

{ TRESTDWMemFloatConstant }

Constructor TRESTDWMemFloatConstant.Create(AName, AValue: string);
Begin
 Inherited Create(AName, etFloat, {$IFDEF FPC}@{$ENDIF}_FloatVariable);

 If Length(AValue) > 0 Then
 FValue := StrToFloat(AValue)
 Else
 FValue := 0.0;
End;

Constructor TRESTDWMemFloatConstant.CreateAsDouble(AName: string; AValue: Double);
Begin
 Inherited Create(AName, etFloat, {$IFDEF FPC}@{$ENDIF}_FloatVariable);

 FValue := AValue;
End;

Function TRESTDWMemFloatConstant.AsPointer: PChar;
Begin
 Result := PChar(@FValue);
End;

{ TRESTDWMemUserConstant }

Constructor TRESTDWMemUserConstant.CreateAsDouble(AName, Descr: string; AValue: Double);
Begin
 FDescription := Descr;

 Inherited CreateAsDouble(AName, AValue);
End;

Function TRESTDWMemUserConstant.GetDescription: string;
Begin
 Result := FDescription;
End;

{ TRESTDWMemStringConstant }

Constructor TRESTDWMemStringConstant.Create(AValue: string);
Var
 firstChar, lastChar: Char;
Begin
 Inherited Create(AValue, etString, {$IFDEF FPC}@{$ENDIF}_StringConstant);

 firstChar := AValue[1];
 lastChar := AValue[Length(AValue)];
 If (firstChar = lastChar) and ((firstChar = '''') or (firstChar = '"')) Then
  Begin
   FValue := Copy(AValue, 2, Length(AValue) - 2);
   FValue := StringReplace(FValue, firstChar+FirstChar, firstChar, [rfReplaceAll,rfIgnoreCase])
  End
 Else
 FValue := AValue;
End;

Function TRESTDWMemStringConstant.AsPointer: PChar;
Begin
 Result := PChar(FValue);
End;

{ TRESTDWMemBooleanConstant }

Constructor TRESTDWMemBooleanConstant.Create(AName: string; AValue: Boolean);
Begin
 Inherited Create(AName, etBoolean, {$IFDEF FPC}@{$ENDIF}_BooleanVariable);

 FValue := AValue;
End;

Function TRESTDWMemBooleanConstant.AsPointer: PChar;
Begin
 Result := PChar(@FValue);
End;

{ TRESTDWMemIntegerConstant }

Constructor TRESTDWMemIntegerConstant.Create(AValue: Integer);
Begin
 Inherited Create(IntToStr(AValue), etInteger, {$IFDEF FPC}@{$ENDIF}_IntegerVariable);

 FValue := AValue;
End;

Function TRESTDWMemIntegerConstant.AsPointer: PChar;
Begin
 Result := PChar(@FValue);
End;

{$IFDEF RESTDW_SUPPORT_INT64}
{ TRESTDWMemLargeIntConstant }

Constructor TRESTDWMemLargeIntConstant.Create(AValue: Int64);
Begin
 Inherited Create(IntToStr(AValue), etLargeInt, {$IFDEF FPC}@{$ENDIF}_LargeIntVariable);

 FValue := AValue;
End;

Function TRESTDWMemLargeIntConstant.AsPointer: PChar;
Begin
 Result := PChar(@FValue);
End;
{$ENDIF}

{ TRESTDWMemVariable }

Constructor TRESTDWMemVariable.Create(AName: string; AVarType: TRESTDWMemExpressionType; AExprFunc: TRESTDWMemExprFunc);
Begin
 Inherited Create(AName, AExprFunc);

 FResultType := AVarType;
End;

Function TRESTDWMemVariable.GetCanVary: Boolean;
Begin
 Result := True;
End;

Function TRESTDWMemVariable.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := FResultType;
End;

{ TRESTDWMemFloatVariable }

Constructor TRESTDWMemFloatVariable.Create(AName: string; AValue: PDouble);
Begin
 Inherited Create(AName, etFloat, {$IFDEF FPC}@{$ENDIF}_FloatVariable);
 FValue := AValue;
End;

Function TRESTDWMemFloatVariable.AsPointer: PChar;
Begin
 Result := PChar(FValue);
End;

{ TRESTDWMemStringVariable }

Constructor TRESTDWMemStringVariable.Create(AName: string; AValue: PPChar);
Begin
 // variable or fixed length?
 Inherited Create(AName, etString, {$IFDEF FPC}@{$ENDIF}_StringVariable);

 // store pointer to string
 FValue := AValue;
 FFixedLen := -1;
End;

Function TRESTDWMemStringVariable.AsPointer: PChar;
Begin
 Result := PChar(FValue);
End;

Function TRESTDWMemStringVariable.GetFixedLen: Integer;
Begin
 Result := FFixedLen;
End;

Function TRESTDWMemStringVariable.LenAsPointer: PInteger;
Begin
 Result := @FFixedLen;
End;

Procedure TRESTDWMemStringVariable.SetFixedLen(NewLen: integer);
Begin
 FFixedLen := NewLen;
End;

{ TRESTDWMemDateTimeVariable }

Constructor TRESTDWMemDateTimeVariable.Create(AName: string; AValue: PRESTDWMemDateTimeRec);
Begin
 Inherited Create(AName, etDateTime, {$IFDEF FPC}@{$ENDIF}_DateTimeVariable);
 FValue := AValue;
End;

Function TRESTDWMemDateTimeVariable.AsPointer: PChar;
Begin
 Result := PChar(FValue);
End;

{ TRESTDWMemIntegerVariable }

Constructor TRESTDWMemIntegerVariable.Create(AName: string; AValue: PInteger);
Begin
 Inherited Create(AName, etInteger, {$IFDEF FPC}@{$ENDIF}_IntegerVariable);
 FValue := AValue;
End;

Function TRESTDWMemIntegerVariable.AsPointer: PChar;
Begin
 Result := PChar(FValue);
End;

{$IFDEF RESTDW_SUPPORT_INT64}

{ TRESTDWMemLargeIntVariable }

Constructor TRESTDWMemLargeIntVariable.Create(AName: string; AValue: PRESTDWMemLargeInt);
Begin
 Inherited Create(AName, etLargeInt, {$IFDEF FPC}@{$ENDIF}_LargeIntVariable);
 FValue := AValue;
End;

Function TRESTDWMemLargeIntVariable.AsPointer: PChar;
Begin
 Result := PChar(FValue);
End;

{$ENDIF}

{ TRESTDWMemBooleanVariable }

Constructor TRESTDWMemBooleanVariable.Create(AName: string; AValue: PBoolean);
Begin
 Inherited Create(AName, etBoolean, {$IFDEF FPC}@{$ENDIF}_BooleanVariable);
 FValue := AValue;
End;

Function TRESTDWMemBooleanVariable.AsPointer: PChar;
Begin
 Result := PChar(FValue);
End;

{ TRESTDWMemLeftBracket }

Function TRESTDWMemLeftBracket.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := etLeftBracket;
End;

{ TRESTDWMemRightBracket }

Function TRESTDWMemRightBracket.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := etRightBracket;
End;

{ TRESTDWMemComma }

Function TRESTDWMemComma.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := etComma;
End;

{ TRESTDWMemExpressList }

Constructor TRESTDWMemExpressList.Create;
Begin
 Inherited;

 FShortList := TRESTDWMemExpressShortList.Create;
End;

Destructor TRESTDWMemExpressList.Destroy;
Begin
 Inherited;
 FShortList.Free;
End;

Procedure TRESTDWMemExpressList.Add(Item: Pointer);
Var
 I: Integer;
Begin
 Inherited;

 { remember we reference the object }
 Inc(TRESTDWMemExprWord(Item).FRefCount);

 { also add ShortName as reference }
 If Length(TRESTDWMemExprWord(Item).ShortName) > 0 Then
  Begin
   FShortList.Search(FShortList.KeyOf(Item), I);
   FShortList.Insert(I, Item);
  End;
End;

Function TRESTDWMemExpressList.Compare(Key1, Key2: Pointer): Integer;
Begin
 Result := StrIComp(PChar(Key1), PChar(Key2));
End;

Function TRESTDWMemExpressList.KeyOf(Item: Pointer): Pointer;
Begin
 Result := PChar(TRESTDWMemExprWord(Item).Name);
End;

Procedure TRESTDWMemExpressList.FreeItem(Item: Pointer);
Begin
 Dec(TRESTDWMemExprWord(Item).FRefCount);
 FShortList.Remove(Item);
 If TRESTDWMemExprWord(Item).FRefCount = 0 Then
 Inherited;
End;

Function TRESTDWMemExpressList.Search(Key: Pointer; Var Index: Integer): Boolean;
Var
 SecIndex: Integer;
Begin
 Result := Inherited Search(Key, Index);
 If not Result Then
  Begin
   Result := FShortList.Search(Key, SecIndex);
   If Result Then
   Index := IndexOf(FShortList.Items[SecIndex]);
  End;
End;

Function TRESTDWMemExpressShortList.Compare(Key1, Key2: Pointer): Integer;
Begin
 Result := StrIComp(PChar(Key1), PChar(Key2));
End;

Function TRESTDWMemExpressShortList.KeyOf(Item: Pointer): Pointer;
Begin
 Result := PChar(TRESTDWMemExprWord(Item).ShortName);
End;

Procedure TRESTDWMemExpressShortList.FreeItem(Item: Pointer);
Begin
End;

{ TRESTDWMemExprCollection }

Procedure TRESTDWMemExprCollection.Check;
Var
 brCount, I: Integer;
Begin
 brCount := 0;
 For I := 0 To Count - 1 Do
  Begin
   Case TRESTDWMemExprWord(Items[I]).ResultType Of
   etLeftBracket: Inc(brCount);
   etRightBracket: Dec(brCount);
  End;
End;
 If brCount <> 0 Then
 raise ERESTDWMemParserException.Create('Unequal brackets');
End;

Procedure TRESTDWMemExprCollection.EraseExtraBrackets;
Var
 I: Integer;
 brCount: Integer;
Begin
 If (TRESTDWMemExprWord(Items[0]).ResultType = etLeftBracket) Then
  Begin
   brCount := 1;
   I := 1;
   While (I < Count) and (brCount > 0) Do
    Begin
     Case TRESTDWMemExprWord(Items[I]).ResultType Of
     etLeftBracket: Inc(brCount);
     etRightBracket: Dec(brCount);
    End;
   Inc(I);
  End;
 If (brCount = 0) and (I = Count) and (TRESTDWMemExprWord(Items[I - 1]).ResultType =
  etRightBracket) Then
 Begin
  For I := 0 To Count - 3 Do
  Items[I] := Items[I + 1];
  Count := Count - 2;
  EraseExtraBrackets; //Check if there are still too many brackets
 End;
End;
End;

{ TRESTDWMemFunction }

Constructor TRESTDWMemFunction.Create(AName, AShortName, ATypeSpec: string; AMinFuncArg: Integer; AResultType: TRESTDWMemExpressionType;
 AExprFunc: TRESTDWMemExprFunc; Descr: string);
Begin
 //to increase compatibility don't use default parameters
 FDescription := Descr;
 FShortName := AShortName;
 InternalCreate(AName, ATypeSpec, AMinFuncArg, AResultType, AExprFunc, false, 0);
End;

Constructor TRESTDWMemFunction.CreateOper(AName, ATypeSpec: string; AResultType: TRESTDWMemExpressionType;
 AExprFunc: TRESTDWMemExprFunc; AOperPrec: Integer);
Begin
 InternalCreate(AName, ATypeSpec, -1, AResultType, AExprFunc, true, AOperPrec);
End;

Procedure TRESTDWMemFunction.InternalCreate(AName, ATypeSpec: string; AMinFuncArg: Integer; AResultType: TRESTDWMemExpressionType;
 AExprFunc: TRESTDWMemExprFunc; AIsOperator: Boolean; AOperPrec: Integer);
Begin
 Inherited Create(AName, AExprFunc);

 FMaxFunctionArg := Length(ATypeSpec);
 FMinFunctionArg := AMinFuncArg;
 If AMinFuncArg = -1 Then
 FMinFunctionArg := FMaxFunctionArg;
 FIsOperator := AIsOperator;
 FOperPrec := AOperPrec;
 FTypeSpec := ATypeSpec;
 FResultType := AResultType;

 // check correctness
 If FMaxFunctionArg > MaxArg Then
 raise ERESTDWMemParserException.Create('Too many arguments');
End;

Function TRESTDWMemFunction.GetDescription: string;
Begin
 Result := FDescription;
End;

Function TRESTDWMemFunction.GetIsOperator: Boolean;
Begin
 Result := FIsOperator;
End;

Function TRESTDWMemFunction.GetMinFunctionArg: Integer;
Begin
 Result := FMinFunctionArg;
End;

Function TRESTDWMemFunction.GetMaxFunctionArg: Integer;
Begin
 Result := FMaxFunctionArg;
End;

Function TRESTDWMemFunction.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := FResultType;
End;

Function TRESTDWMemFunction.GetShortName: string;
Begin
 Result := FShortName;
End;

Function TRESTDWMemFunction.GetTypeSpec: string;
Begin
 Result := FTypeSpec;
End;

Function TRESTDWMemFunction.IsFunction: Boolean;
Begin
 Result := True;
End;

{ TRESTDWMemVaryingFunction }

Function TRESTDWMemVaryingFunction.GetCanVary: Boolean;
Begin
 Result := True;
End;

{ TRESTDWMemDynamicType }

Constructor TRESTDWMemDynamicType.Create(DestMem, DestPos: PPChar; ASize: PInteger);
Begin
 Inherited Create;

 FMemory := DestMem;
 FMemoryPos := DestPos;
 FSize := ASize;
End;

Procedure TRESTDWMemDynamicType.Rewind;
Begin
 FMemoryPos^ := FMemory^;
End;

Procedure TRESTDWMemDynamicType.AssureSpace(ASize: Integer);
Begin
 // need more memory?
 If ((FMemoryPos^) - (FMemory^) + ASize) > (FSize^) Then
 Resize((FMemoryPos^) - (FMemory^) + ASize, False);
End;

Procedure TRESTDWMemDynamicType.Resize(NewSize: Integer; Exact: Boolean);
Var
 tempBuf: PChar;
 bytesCopy, pos: Integer;
Begin
 // if not exact requested make newlength a multiple of ArgAllocSize
 If not Exact Then
 NewSize := NewSize div ArgAllocSize * ArgAllocSize + ArgAllocSize;
 // create new buffer
 GetMem(tempBuf, NewSize);
 // copy memory
 bytesCopy := FSize^;
 If bytesCopy > NewSize Then
 bytesCopy := NewSize;
 Move(FMemory^^, tempBuf^, bytesCopy);
 // save position in string
 pos := FMemoryPos^ - FMemory^;
 // delete old mem
 FreeMem(FMemory^);
 // assign new
 FMemory^ := tempBuf;
 FSize^ := NewSize;
 // assign position
 FMemoryPos^ := FMemory^ + pos;
End;

Procedure TRESTDWMemDynamicType.Append(Source: PChar; Length: Integer);
Begin
 // make room for string plus null-terminator
 AssureSpace(Length+4);
 // copy
 Move(Source^, FMemoryPos^^, Length);
 Inc(FMemoryPos^, Length);
 // null-terminate
 FMemoryPos^^ := #0;
End;

Procedure TRESTDWMemDynamicType.AppendInteger(Source: Integer);
Begin
 // make room for number
 AssureSpace(12);
 Inc(FMemoryPos^, GetStrFromInt(Source, FMemoryPos^));
 FMemoryPos^^ := #0;
End;

End.
