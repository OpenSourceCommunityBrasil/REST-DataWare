Unit uRESTDWMemoryDatasetParserCore;

{--------------------------------------------------------------
| TRESTDWMemCustomExpressionParser
|
| - contains core expression parser
|
| This code is based on code from:
|
| Original author: Egbert van Nes
| With contributions of: John Bultena and Ralf Junker
| Homepage: http://www.slm.wau.nl/wkao/parseexpr.html
|
| see also: http://www.datalog.ro/delphi/parser.html
|   (Renate Schaaf (schaaf at math.usu.edu), 1993
|    Alin Flaider (aflaidar at datalog.ro), 1996
|    Version 9-10: Stefan Hoffmeister, 1996-1997)
|
|---------------------------------------------------------------}

Interface

{$I uRESTDW.inc}
{$DEFINE RESTDW_SUPPORT_INT64}

Uses
  SysUtils,
  Classes,
  Db,
  uRESTDWMemoryDatasetParserSupport,
  uRESTDWMemoryDatasetParserDefs;

{$define ENG_NUMBERS}

// ENG_NUMBERS will force the use of English style numbers 8.1 instead of 8,1
//   (if the comma is your decimal separator)
// The advantage is that arguments can be separated with a comma which is
// fairly common, otherwise there is ambiguity: what does 'var1,8,4,4,5' mean?
// If you don't define ENG_NUMBERS and DecimalSeparator is a comma then
// the argument separator will be a semicolon ';'

Type

  TRESTDWMemCustomExpressionParser = Class(TObject)
  Private
    FHexChar: Char;
    FArgSeparator: Char;
    FDecimalSeparator: Char;
    FOptimize: Boolean;
    FConstantsList: TRESTDWMemOCollection;
    FLastRec: PRESTDWMemExpressionRec;
    FCurrentRec: PRESTDWMemExpressionRec;
    FExpResult: PChar;
    FExpResultPos: PChar;
    FExpResultSize: Integer;

    Procedure ParseString(AnExpression: string; DestCollection: TRESTDWMemExprCollection);
    Function  MakeTree(Expr: TRESTDWMemExprCollection; FirstItem, LastItem: Integer): PRESTDWMemExpressionRec;
    Procedure MakeLinkedList(Var ExprRec: PRESTDWMemExpressionRec; Memory: PPChar;
        MemoryPos: PPChar; MemSize: PInteger);
    Procedure Check(AnExprList: TRESTDWMemExprCollection);
    Procedure CheckArguments(ExprRec: PRESTDWMemExpressionRec);
    Procedure RemoveConstants(Var ExprRec: PRESTDWMemExpressionRec);
    Function ResultCanVary(ExprRec: PRESTDWMemExpressionRec): Boolean;
  Protected
    FWordsList: TRESTDWMemSortedCollection;

    Function MakeRec: PRESTDWMemExpressionRec; virtual;
    Procedure FillExpressList; virtual; abstract;
    Procedure HandleUnknownVariable(VarName: string); virtual; abstract;

    Procedure CompileExpression(AnExpression: string);
    Procedure EvaluateCurrent;
    Procedure DisposeList(ARec: PRESTDWMemExpressionRec);
    Procedure DisposeTree(ExprRec: PRESTDWMemExpressionRec);
    Function CurrentExpression: string; virtual; abstract;
    Function GetResultType: TRESTDWMemExpressionType; virtual;

    property CurrentRec: PRESTDWMemExpressionRec read FCurrentRec write FCurrentRec;
    property LastRec: PRESTDWMemExpressionRec read FLastRec write FLastRec;
    property ExpResult: PChar read FExpResult;
    property ExpResultPos: PChar read FExpResultPos write FExpResultPos;

  Public
    Constructor Create;
    Destructor Destroy; override;

    Function DefineFloatVariable(AVarName: string; AValue: PDouble): TRESTDWMemExprWord;
    Function DefineIntegerVariable(AVarName: string; AValue: PInteger): TRESTDWMemExprWord;
//    procedure DefineSmallIntVariable(AVarName: string; AValue: PSmallInt);
{$IFDEF RESTDW_SUPPORT_INT64}
    Function DefineLargeIntVariable(AVarName: string; AValue: PRESTDWMemLargeInt): TRESTDWMemExprWord;
{$ENDIF}
    Function DefineDateTimeVariable(AVarName: string; AValue: PRESTDWMemDateTimeRec): TRESTDWMemExprWord;
    Function DefineBooleanVariable(AVarName: string; AValue: PBoolean): TRESTDWMemExprWord;
    Function DefineStringVariable(AVarName: string; AValue: PPChar): TRESTDWMemExprWord;
    Function DefineFunction(AFunctName, AShortName, ADescription, ATypeSpec: string;
        AMinFunctionArg: Integer; AResultType: TRESTDWMemExpressionType; AFuncAddress: TRESTDWMemExprFunc): TRESTDWMemExprWord;
    Procedure Evaluate(AnExpression: string);
    Function AddExpression(AnExpression: string): Integer;
    Procedure ClearExpressions; virtual;
//    procedure GetGeneratedVars(AList: TList);
    Procedure GetFunctionNames(AList: TStrings);
    Function GetFunctionDescription(AFunction: string): string;
    property HexChar: Char read FHexChar write FHexChar;
    property ArgSeparator: Char read FArgSeparator write FArgSeparator;
    property Optimize: Boolean read FOptimize write FOptimize;
    property ResultType: TRESTDWMemExpressionType read GetResultType;

    //If optimize is selected, the code tries to remove constant expressions
    //Examples: 4*4*x is evaluated as 16*x and exp(1)-4*x is replaced by 2.17 -4*x
  End;


//--Expression functions-----------------------------------------------------
//I: Integer; L: Large Integer (Int64); F: Double; S: String; B: Boolean

Procedure FuncFloatToStr(Param: PRESTDWMemExpressionRec);
Procedure FuncIntToStr_Gen(Param: PRESTDWMemExpressionRec; Val: {$IFDEF RESTDW_SUPPORT_INT64}Int64{$else}Integer{$ENDIF});
Procedure FuncIntToStr(Param: PRESTDWMemExpressionRec);
{$IFDEF RESTDW_SUPPORT_INT64}
Procedure FuncInt64ToStr(Param: PRESTDWMemExpressionRec);
{$ENDIF}
Procedure FuncDateToStr(Param: PRESTDWMemExpressionRec);
Procedure FuncSubString(Param: PRESTDWMemExpressionRec);
Procedure FuncUppercase(Param: PRESTDWMemExpressionRec);
Procedure FuncLowercase(Param: PRESTDWMemExpressionRec);
Procedure FuncNegative_F_F(Param: PRESTDWMemExpressionRec);
Procedure FuncNegative_I_I(Param: PRESTDWMemExpressionRec);
{$IFDEF RESTDW_SUPPORT_INT64}
Procedure FuncNegative_L_L(Param: PRESTDWMemExpressionRec);
{$ENDIF}
Procedure FuncAdd_F_FF(Param: PRESTDWMemExpressionRec);
Procedure FuncAdd_F_FI(Param: PRESTDWMemExpressionRec);
Procedure FuncAdd_F_II(Param: PRESTDWMemExpressionRec);
Procedure FuncAdd_F_IF(Param: PRESTDWMemExpressionRec);
{$IFDEF RESTDW_SUPPORT_INT64}
Procedure FuncAdd_F_FL(Param: PRESTDWMemExpressionRec);
Procedure FuncAdd_F_IL(Param: PRESTDWMemExpressionRec);
Procedure FuncAdd_F_LL(Param: PRESTDWMemExpressionRec);
Procedure FuncAdd_F_LF(Param: PRESTDWMemExpressionRec);
Procedure FuncAdd_F_LI(Param: PRESTDWMemExpressionRec);
{$ENDIF}
Procedure FuncSub_F_FF(Param: PRESTDWMemExpressionRec);
Procedure FuncSub_F_FI(Param: PRESTDWMemExpressionRec);
Procedure FuncSub_F_II(Param: PRESTDWMemExpressionRec);
Procedure FuncSub_F_IF(Param: PRESTDWMemExpressionRec);
{$IFDEF RESTDW_SUPPORT_INT64}
Procedure FuncSub_F_FL(Param: PRESTDWMemExpressionRec);
Procedure FuncSub_F_IL(Param: PRESTDWMemExpressionRec);
Procedure FuncSub_F_LL(Param: PRESTDWMemExpressionRec);
Procedure FuncSub_F_LF(Param: PRESTDWMemExpressionRec);
Procedure FuncSub_F_LI(Param: PRESTDWMemExpressionRec);
{$ENDIF}
Procedure FuncMul_F_FF(Param: PRESTDWMemExpressionRec);
Procedure FuncMul_F_FI(Param: PRESTDWMemExpressionRec);
Procedure FuncMul_F_II(Param: PRESTDWMemExpressionRec);
Procedure FuncMul_F_IF(Param: PRESTDWMemExpressionRec);
{$IFDEF RESTDW_SUPPORT_INT64}
Procedure FuncMul_F_FL(Param: PRESTDWMemExpressionRec);
Procedure FuncMul_F_IL(Param: PRESTDWMemExpressionRec);
Procedure FuncMul_F_LL(Param: PRESTDWMemExpressionRec);
Procedure FuncMul_F_LF(Param: PRESTDWMemExpressionRec);
Procedure FuncMul_F_LI(Param: PRESTDWMemExpressionRec);
{$ENDIF}
Procedure FuncDiv_F_FF(Param: PRESTDWMemExpressionRec);
Procedure FuncDiv_F_FI(Param: PRESTDWMemExpressionRec);
Procedure FuncDiv_F_II(Param: PRESTDWMemExpressionRec);
Procedure FuncDiv_F_IF(Param: PRESTDWMemExpressionRec);
{$IFDEF RESTDW_SUPPORT_INT64}
Procedure FuncDiv_F_FL(Param: PRESTDWMemExpressionRec);
Procedure FuncDiv_F_IL(Param: PRESTDWMemExpressionRec);
Procedure FuncDiv_F_LL(Param: PRESTDWMemExpressionRec);
Procedure FuncDiv_F_LF(Param: PRESTDWMemExpressionRec);
Procedure FuncDiv_F_LI(Param: PRESTDWMemExpressionRec);
{$ENDIF}
Procedure FuncStrI_EQ(Param: PRESTDWMemExpressionRec);
Procedure FuncStrI_NEQ(Param: PRESTDWMemExpressionRec);
Procedure FuncStrI_LT(Param: PRESTDWMemExpressionRec);
Procedure FuncStrI_GT(Param: PRESTDWMemExpressionRec);
Procedure FuncStrI_LTE(Param: PRESTDWMemExpressionRec);
Procedure FuncStrI_GTE(Param: PRESTDWMemExpressionRec);
Procedure FuncStrIP_EQ(Param: PRESTDWMemExpressionRec);
Procedure FuncStrP_EQ(Param: PRESTDWMemExpressionRec);
Procedure FuncStr_EQ(Param: PRESTDWMemExpressionRec);
Procedure FuncStr_NEQ(Param: PRESTDWMemExpressionRec);
Procedure FuncStr_LT(Param: PRESTDWMemExpressionRec);
Procedure FuncStr_GT(Param: PRESTDWMemExpressionRec);
Procedure FuncStr_LTE(Param: PRESTDWMemExpressionRec);
Procedure FuncStr_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_FF_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_FF_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_FF_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_FF_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_FF_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_FF_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_FI_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_FI_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_FI_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_FI_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_FI_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_FI_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_II_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_II_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_II_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_II_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_II_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_II_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_IF_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_IF_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_IF_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_IF_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_IF_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_IF_GTE(Param: PRESTDWMemExpressionRec);
{$IFDEF RESTDW_SUPPORT_INT64}
Procedure Func_LL_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_LL_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_LL_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_LL_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_LL_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_LL_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_LF_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_LF_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_LF_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_LF_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_LF_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_LF_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_FL_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_FL_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_FL_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_FL_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_FL_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_FL_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_LI_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_LI_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_LI_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_LI_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_LI_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_LI_GTE(Param: PRESTDWMemExpressionRec);
Procedure Func_IL_EQ(Param: PRESTDWMemExpressionRec);
Procedure Func_IL_NEQ(Param: PRESTDWMemExpressionRec);
Procedure Func_IL_LT(Param: PRESTDWMemExpressionRec);
Procedure Func_IL_GT(Param: PRESTDWMemExpressionRec);
Procedure Func_IL_LTE(Param: PRESTDWMemExpressionRec);
Procedure Func_IL_GTE(Param: PRESTDWMemExpressionRec);
{$ENDIF}
Procedure Func_AND(Param: PRESTDWMemExpressionRec);
Procedure Func_OR(Param: PRESTDWMemExpressionRec);
Procedure Func_NOT(Param: PRESTDWMemExpressionRec);

Var
  DbfWordsSensGeneralList, DbfWordsInsensGeneralList: TRESTDWMemExpressList; //case sensitive and case insensitive
  DbfWordsSensPartialList, DbfWordsInsensPartialList: TRESTDWMemExpressList; //for partial matches
  DbfWordsSensNoPartialList, DbfWordsInsensNoPartialList: TRESTDWMemExpressList; //no partial match allowed
  DbfWordsGeneralList: TRESTDWMemExpressList;

Implementation

Procedure LinkVariable(ExprRec: PRESTDWMemExpressionRec);
Begin
 With ExprRec^ Do
  Begin
   If ExprWord.IsVariable Then
    Begin
     // copy pointer to variable
     Args[0] := ExprWord.AsPointer;
     // store length as second parameter
     Args[1] := PChar(ExprWord.LenAsPointer);
    End;
  End;
End;

Procedure LinkVariables(ExprRec: PRESTDWMemExpressionRec);
Var
 I: integer;
Begin
 With ExprRec^ Do
  Begin
   I := 0;
   While (I < MaxArg) and (ArgList[I] <> nil) Do
    Begin
     LinkVariables(ArgList[I]);
     Inc(I);
    End;
  End;
 LinkVariable(ExprRec);
End;

{ TRESTDWMemCustomExpressionParser }

Constructor TRESTDWMemCustomExpressionParser.Create;
Begin
 Inherited;

 FHexChar := '$';
{$IFDEF ENG_NUMBERS}
 FDecimalSeparator := '.';
 FArgSeparator := ',';
{$ELSE}
 FDecimalSeparator := DecimalSeparator;
 If DecimalSeparator = ',' Then
 FArgSeparator := ';'
 Else
 FArgSeparator := ',';
{$ENDIF}
 FConstantsList := TRESTDWMemOCollection.Create;
 FWordsList := TRESTDWMemExpressList.Create;
 GetMem(FExpResult, ArgAllocSize);
 FExpResultPos := FExpResult;
 FExpResultSize := ArgAllocSize;
 FOptimize := true;
 FillExpressList;
End;

Destructor TRESTDWMemCustomExpressionParser.Destroy;
Begin
 ClearExpressions;
 FreeMem(FExpResult);
 FConstantsList.Free;
 FWordsList.Free;

 Inherited;
End;

Procedure TRESTDWMemCustomExpressionParser.CompileExpression(AnExpression: string);
Var
 ExpColl: TRESTDWMemExprCollection;
 ExprTree: PRESTDWMemExpressionRec;
Begin
 If Length(AnExpression) > 0 Then
  Begin
   ExprTree := nil;
   ExpColl := TRESTDWMemExprCollection.Create;
   Try
   FConstantsList.FreeAll;
    //    FCurrentExpression := anExpression;
   ParseString(AnExpression, ExpColl);
   Check(ExpColl);
   ExprTree := MakeTree(ExpColl, 0, ExpColl.Count - 1);
   FCurrentRec := nil;
   CheckArguments(ExprTree);
   LinkVariables(ExprTree);
   If Optimize Then
   RemoveConstants(ExprTree);
    // all constant expressions are evaluated and replaced by variables
   FCurrentRec := nil;
   FExpResultPos := FExpResult;
   MakeLinkedList(ExprTree, @FExpResult, @FExpResultPos, @FExpResultSize);
   Except
   on E: Exception Do
   Begin
    DisposeTree(ExprTree);
    ExpColl.Free;
    raise;
   End;
  End;
 ExpColl.Free;
End;
End;

Procedure TRESTDWMemCustomExpressionParser.CheckArguments(ExprRec: PRESTDWMemExpressionRec);
Var
 TempExprWord: TRESTDWMemExprWord;
 I, error, firstFuncIndex, funcIndex: Integer;
 foundAltFunc: Boolean;

 Procedure FindAlternate;
 Begin
  // see if we can find another function
  If funcIndex < 0 Then
   Begin
    firstFuncIndex := FWordsList.IndexOf(ExprRec^.ExprWord);
    funcIndex := firstFuncIndex;
   End;
  // check if not last function
  If (0 <= funcIndex) and (funcIndex < FWordsList.Count - 1) Then
   Begin
    inc(funcIndex);
    TempExprWord := TRESTDWMemExprWord(FWordsList.Items[funcIndex]);
    If FWordsList.Compare(FWordsList.KeyOf(ExprRec^.ExprWord), FWordsList.KeyOf(TempExprWord)) = 0 Then
     Begin
      ExprRec^.ExprWord := TempExprWord;
      ExprRec^.Oper := ExprRec^.ExprWord.ExprFunc;
      foundAltFunc := true;
     End;
   End;
 End;

 Procedure InternalCheckArguments;
 Begin
  I := 0;
  error := 0;
  foundAltFunc := false;
  With ExprRec^ Do
   Begin
    If WantsFunction <> (ExprWord.IsFunction and not ExprWord.IsOperator) Then
     Begin
      error := 4;
      Exit;
     End;
 
    While (I < ExprWord.MaxFunctionArg) and (ArgList[I] <> nil) and (error = 0) Do
     Begin
      // test subarguments first
      CheckArguments(ArgList[I]);
  
      // test if correct type
      If (ArgList[I]^.ExprWord.ResultType <> ExprCharToExprType(ExprWord.TypeSpec[I+1])) Then
      error := 2;
  
      // goto next argument
      Inc(I);
     End;
 
    // test if enough parameters passed; I = num args user passed
    If (error = 0) and (I < ExprWord.MinFunctionArg) Then
    error := 1;
 
    // test if too many parameters passed
    If (error = 0) and (I > ExprWord.MaxFunctionArg) Then
    error := 3;
   End;
 End;

Begin
 funcIndex := -1;
 Repeat
 InternalCheckArguments;

  // error occurred?
 If error <> 0 Then
  FindAlternate;
 Until (error = 0) or not foundAltFunc;

 // maybe it's an undefined variable
 If (error <> 0) and not ExprRec^.WantsFunction and (firstFuncIndex >= 0) Then
  Begin
   HandleUnknownVariable(ExprRec^.ExprWord.Name);
   { must not add variable as first function in this set of duplicates,
   otherwise following searches will not find it }
   FWordsList.Exchange(firstFuncIndex, firstFuncIndex+1);
   ExprRec^.ExprWord := TRESTDWMemExprWord(FWordsList.Items[firstFuncIndex+1]);
   ExprRec^.Oper := ExprRec^.ExprWord.ExprFunc;
   InternalCheckArguments;
  End;

 // fatal error?
 Case error Of
 1: raise ERESTDWMemParserException.Create('Function or operand has too few arguments');
 2: raise ERESTDWMemParserException.Create('Argument type mismatch');
 3: raise ERESTDWMemParserException.Create('Function or operand has too many arguments');
 4: raise ERESTDWMemParserException.Create('No function with this name, remove brackets for variable');
End;
End;

Function TRESTDWMemCustomExpressionParser.ResultCanVary(ExprRec: PRESTDWMemExpressionRec):
 Boolean;
Var
 I: Integer;
Begin
 With ExprRec^ Do
  Begin
   Result := ExprWord.CanVary;
   If not Result Then
   For I := 0 To ExprWord.MaxFunctionArg - 1 Do
   If (ArgList[I] <> nil) and ResultCanVary(ArgList[I]) Then
    Begin
     Result := true;
     Exit;
    End
  End;
End;

Procedure TRESTDWMemCustomExpressionParser.RemoveConstants(Var ExprRec: PRESTDWMemExpressionRec);
Var
 I: Integer;
Begin
 If not ResultCanVary(ExprRec) Then
  Begin
   If not ExprRec^.ExprWord.IsVariable Then
    Begin
     // reset current record so that make list generates new
     FCurrentRec := nil;
     FExpResultPos := FExpResult;
     MakeLinkedList(ExprRec, @FExpResult, @FExpResultPos, @FExpResultSize);
  
     Try
      // compute result
     EvaluateCurrent;
  
      // make new record to store constant in
     ExprRec := MakeRec;
  
      // check result type
     With ExprRec^ Do
      Begin
       Case ResultType Of
       etBoolean: ExprWord := TRESTDWMemBooleanConstant.Create(EmptyStr, PBoolean(FExpResult)^);
       etFloat:   ExprWord := TRESTDWMemFloatConstant.CreateAsDouble(EmptyStr, PDouble(FExpResult)^);
       etInteger: ExprWord := TRESTDWMemIntegerConstant.Create(PInteger(FExpResult)^);
   {$IFDEF RESTDW_SUPPORT_INT64}
       etLargeInt:ExprWord := TRESTDWMemLargeIntConstant.Create(PInt64(FExpResult)^);
   {$ENDIF}
       etString:  ExprWord := TRESTDWMemStringConstant.Create(FExpResult);
       Else raise ERESTDWMemParserException.CreateFmt('No support for resulttype %d. Please fix the TDBF code.',[Ord(ResultType)]);
      End;
  
       // fill in structure
     Oper := ExprWord.ExprFunc;
     Args[0] := ExprWord.AsPointer;
     FConstantsList.Add(ExprWord);
    End;
   Finally
   DisposeList(FCurrentRec);
   FCurrentRec := nil;
  End;
End;
 End Else
 With ExprRec^ Do
  Begin
   For I := 0 To ExprWord.MaxFunctionArg - 1 Do
   If ArgList[I] <> nil Then
    RemoveConstants(ArgList[I]);
  End;
End;

Procedure TRESTDWMemCustomExpressionParser.DisposeTree(ExprRec: PRESTDWMemExpressionRec);
Var
 I: Integer;
Begin
 If ExprRec <> nil Then
  Begin
   With ExprRec^ Do
    Begin
     If ExprWord <> nil Then
     For I := 0 To ExprWord.MaxFunctionArg - 1 Do
     DisposeTree(ArgList[I]);
     If Res <> nil Then
     Res.Free;
    End;
   Dispose(ExprRec);
  End;
End;

Procedure TRESTDWMemCustomExpressionParser.DisposeList(ARec: PRESTDWMemExpressionRec);
Var
 TheNext: PRESTDWMemExpressionRec;
 I: Integer;
Begin
 If ARec <> nil Then
 Repeat
  TheNext := ARec^.Next;
  If ARec^.Res <> nil Then
  ARec^.Res.Free;
  I := 0;
  While ARec^.ArgList[I] <> nil Do
   Begin
    FreeMem(ARec^.Args[I]);
    Inc(I);
   End;
  Dispose(ARec);
  ARec := TheNext;
 Until ARec = nil;
End;

Procedure TRESTDWMemCustomExpressionParser.MakeLinkedList(Var ExprRec: PRESTDWMemExpressionRec;
 Memory: PPChar; MemoryPos: PPChar; MemSize: PInteger);
Var
 I: Integer;
Begin
 // test function type
 If @ExprRec^.ExprWord.ExprFunc = nil Then
  Begin
   // special 'no function' function
   // indicates no function is present -> we can concatenate all instances
   // we don't create new arguments...these 'fall' through
   // use destination as we got it
   I := 0;
   While ExprRec^.ArgList[I] <> nil Do
    Begin
     // convert arguments to list
     MakeLinkedList(ExprRec^.ArgList[I], Memory, MemoryPos, MemSize);
     // goto next argument
     Inc(I);
    End;
   // don't need this record anymore
   Dispose(ExprRec);
   ExprRec := nil;
  End Else Begin
  // inc memory pointer so we know if we are first
 ExprRec^.ResetDest := MemoryPos^ = Memory^;
 Inc(MemoryPos^);
  // convert arguments to list
 I := 0;
 While ExprRec^.ArgList[I] <> nil Do
  Begin
    // save variable type for easy access
   ExprRec^.ArgsType[I] := ExprRec^.ArgList[I]^.ExprWord.ResultType;
    // check if we need to copy argument: variables in general do not
    // need copying, except for fixed len strings which are not
    // null-terminated
 //      if ExprRec^.ArgList[I].ExprWord.NeedsCopy then
 //      begin
     // get memory for argument
   GetMem(ExprRec^.Args[I], ArgAllocSize);
   ExprRec^.ArgsPos[I] := ExprRec^.Args[I];
   ExprRec^.ArgsSize[I] := ArgAllocSize;
   MakeLinkedList(ExprRec^.ArgList[I], @ExprRec^.Args[I], @ExprRec^.ArgsPos[I],
    @ExprRec^.ArgsSize[I]);
 //      end else begin
     // copy reference
 //        ExprRec^.Args[I] := ExprRec^.ArgList[I].Args[0];
 //        ExprRec^.ArgsPos[I] := ExprRec^.Args[I];
 //        ExprRec^.ArgsSize[I] := 0;
 //        FreeMem(ExprRec^.ArgList[I]);
 //        ExprRec^.ArgList[I] := nil;
 //      end;
 
    // goto next argument
   Inc(I);
  End;

  // link result to target argument
 ExprRec^.Res := TRESTDWMemDynamicType.Create(Memory, MemoryPos, MemSize);

  // link to next operation
 If FCurrentRec = nil Then
  Begin
   FCurrentRec := ExprRec;
   FLastRec := ExprRec;
  End Else Begin
  FLastRec^.Next := ExprRec;
  FLastRec := ExprRec;
End;
 End;
End;

Function TRESTDWMemCustomExpressionParser.MakeTree(Expr: TRESTDWMemExprCollection;
 FirstItem, LastItem: Integer): PRESTDWMemExpressionRec;

{
- This is the most complex routine, it breaks down the expression and makes
 a linked tree which is used for fast function evaluations
- it is implemented recursively
}

Var
 I, IArg, IStart, IEnd, lPrec, brCount: Integer;
 ExprWord: TRESTDWMemExprWord;
Begin
 // remove redundant brackets
 brCount := 0;
 While (FirstItem+brCount < LastItem) and (TRESTDWMemExprWord(
  Expr.Items[FirstItem+brCount]).ResultType = etLeftBracket) Do
 Inc(brCount);
 I := LastItem;
 While (I > FirstItem) and (TRESTDWMemExprWord(
  Expr.Items[I]).ResultType = etRightBracket) Do
 Dec(I);
 // test max of start and ending brackets
 If brCount > (LastItem-I) Then
 brCount := LastItem-I;
 // count number of bracket pairs completely open from start to end
 // IArg is min.brCount
 I := FirstItem + brCount;
 IArg := brCount;
 While (I <= LastItem - brCount) and (brCount > 0) Do
  Begin
   Case TRESTDWMemExprWord(Expr.Items[I]).ResultType Of
   etLeftBracket: Inc(brCount);
   etRightBracket:
   Begin
    Dec(brCount);
    If brCount < IArg Then
    IArg := brCount;
   End;
  End;
 Inc(I);
End;
 // useful pair bracket count, is in minimum, is IArg
 brCount := IArg;
 // check if subexpression closed within (bracket level will be zero)
 If brCount > 0 Then
  Begin
   Inc(FirstItem, brCount);
   Dec(LastItem, brCount);
  End;

 // check for empty range
 If LastItem < FirstItem Then
  Begin
   Result := nil;
   Exit;
  End;

 // get new record
 Result := MakeRec;

 // simple constant, variable or function?
 If LastItem = FirstItem Then
  Begin
   Result^.ExprWord := TRESTDWMemExprWord(Expr.Items[FirstItem]);
   Result^.Oper := Result^.ExprWord.ExprFunc;
   Exit;
  End;

 // no...more complex, find operator with lowest precedence
 brCount := 0;
 IArg := 0;
 IEnd := FirstItem-1;
 lPrec := -1;
 For I := FirstItem To LastItem Do
  Begin
   ExprWord := TRESTDWMemExprWord(Expr.Items[I]);
   If (brCount = 0) and ExprWord.IsOperator and (TRESTDWMemFunction(ExprWord).OperPrec > lPrec) Then
    Begin
     IEnd := I;
     lPrec := TRESTDWMemFunction(ExprWord).OperPrec;
    End;
   Case ExprWord.ResultType Of
   etLeftBracket: Inc(brCount);
   etRightBracket: Dec(brCount);
  End;
 End;

 // operator found ?
 If IEnd >= FirstItem Then
  Begin
   // save operator
   Result^.ExprWord := TRESTDWMemExprWord(Expr.Items[IEnd]);
   Result^.Oper := Result^.ExprWord.ExprFunc;
   // recurse into left part if present
   If IEnd > FirstItem Then
    Begin
     Result^.ArgList[IArg] := MakeTree(Expr, FirstItem, IEnd-1);
     Inc(IArg);
    End;
   // recurse into right part if present
   If IEnd < LastItem Then
   Result^.ArgList[IArg] := MakeTree(Expr, IEnd+1, LastItem);
  End Else
 If TRESTDWMemExprWord(Expr.Items[FirstItem]).IsFunction Then
  Begin
   // save function
   Result^.ExprWord := TRESTDWMemExprWord(Expr.Items[FirstItem]);
   Result^.Oper := Result^.ExprWord.ExprFunc;
   Result^.WantsFunction := true;
   // parse function arguments
   IEnd := FirstItem + 1;
   IStart := IEnd;
   brCount := 0;
   If TRESTDWMemExprWord(Expr.Items[IEnd]).ResultType = etLeftBracket Then
    Begin
     // opening bracket found, first argument expression starts at next index
     Inc(brCount);
     Inc(IStart);
     While (IEnd < LastItem) and (brCount <> 0) Do
      Begin
       Inc(IEnd);
       Case TRESTDWMemExprWord(Expr.Items[IEnd]).ResultType Of
       etLeftBracket: Inc(brCount);
       etComma:
       If brCount = 1 Then
        Begin
           // argument separation found, build tree of argument expression
         Result^.ArgList[IArg] := MakeTree(Expr, IStart, IEnd-1);
         Inc(IArg);
         IStart := IEnd + 1;
        End;
       etRightBracket: Dec(brCount);
      End;
    End;
 
    // parse last argument
   Result^.ArgList[IArg] := MakeTree(Expr, IStart, IEnd-1);
  End;
 End Else
 raise ERESTDWMemParserException.Create('Operator/function missing');
End;

Procedure TRESTDWMemCustomExpressionParser.ParseString(AnExpression: string; DestCollection: TRESTDWMemExprCollection);
Var
 isConstant: Boolean;
 I, I1, I2, Len, DecSep: Integer;
 W, S: string;
 TempWord: TRESTDWMemExprWord;

 Procedure ReadConstant(AnExpr: string; isHex: Boolean);
 Begin
  isConstant := true;
  While (I2 <= Len) and ((AnExpr[I2] in ['0'..'9']) or
  (isHex and (AnExpr[I2] in ['a'..'f', 'A'..'F']))) Do
  Inc(I2);
  If I2 <= Len Then
   Begin
    If AnExpr[I2] = FDecimalSeparator Then
     Begin
      Inc(I2);
      While (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) Do
      Inc(I2);
     End;
    If (I2 <= Len) and (AnExpr[I2] = 'e') Then
     Begin
      Inc(I2);
      If (I2 <= Len) and (AnExpr[I2] in ['+', '-']) Then
      Inc(I2);
      While (I2 <= Len) and (AnExpr[I2] in ['0'..'9']) Do
      Inc(I2);
     End;
   End;
 End;

 Procedure ReadWord(AnExpr: string);
 Var
 OldI2: Integer;
 constChar: Char;
 Begin
  isConstant := false;
  I1 := I2;
  While (I1 < Len) and (AnExpr[I1] = ' ') Do
  Inc(I1);
  I2 := I1;
  If I1 <= Len Then
   Begin
    If AnExpr[I2] = HexChar Then
     Begin
      Inc(I2);
      OldI2 := I2;
      ReadConstant(AnExpr, true);
      If I2 = OldI2 Then
       Begin
        isConstant := false;
        While (I2 <= Len) and (AnExpr[I2] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) Do
        Inc(I2);
       End;
     End
    Else If AnExpr[I2] = FDecimalSeparator Then
    ReadConstant(AnExpr, false)
    Else
     // String constants can be delimited by ' or "
     // but need not be - see below
     // To use a delimiter inside the string, double it up to escape it
    Case AnExpr[I2] Of
    '''', '"':
    Begin
     isConstant := true;
     constChar := AnExpr[I2];
     Inc(I2);
     While (I2 <= Len) Do
      Begin
          // Regular character?
       If (AnExpr[I2] <> constChar) Then
       Inc(I2)
       Else // we do have a const, now check for escaped consts
       If (I2+1 <= Len) and
       (AnExpr[I2+1]=constChar) Then
       Inc(I2,2) //skip past, deal with duplicates later
       Else //at the trailing delimiter
       Begin
        Inc(I2); //move past delimiter
        Break;
       End;
      End;
    End;
      // However string constants can also appear without delimiters
    'a'..'z', 'A'..'Z', '_':
    Begin
     While (I2 <= Len) and (AnExpr[I2] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) Do
     Inc(I2);
    End;
    '>', '<':
    Begin
     If (I2 <= Len) Then
     Inc(I2);
     If AnExpr[I2] in ['=', '<', '>'] Then
     Inc(I2);
    End;
    '=':
    Begin
     If (I2 <= Len) Then
     Inc(I2);
     If AnExpr[I2] in ['<', '>', '='] Then
     Inc(I2);
    End;
    '&':
    Begin
     If (I2 <= Len) Then
     Inc(I2);
     If AnExpr[I2] in ['&'] Then
     Inc(I2);
    End;
    '|':
    Begin
     If (I2 <= Len) Then
     Inc(I2);
     If AnExpr[I2] in ['|'] Then
     Inc(I2);
    End;
    ':':
    Begin
     If (I2 <= Len) Then
     Inc(I2);
     If AnExpr[I2] = '=' Then
     Inc(I2);
    End;
    '!':
    Begin
     If (I2 <= Len) Then
     Inc(I2);
     If AnExpr[I2] = '=' Then //support for !=
     Inc(I2);
    End;
    '+':
    Begin
     Inc(I2);
     If (AnExpr[I2] = '+') and FWordsList.Search(PChar('++'), I) Then
     Inc(I2);
    End;
    '-':
    Begin
     Inc(I2);
     If (AnExpr[I2] = '-') and FWordsList.Search(PChar('--'), I) Then
     Inc(I2);
    End;
    '^', '/', '\', '*', '(', ')', '%', '~', '$':
    Inc(I2);
    '0'..'9':
    ReadConstant(AnExpr, false);
    Else
     Begin
      Inc(I2);
     End;
   End;
 End;
 End;

Begin
 I2 := 1;
 S := Trim(AnExpression);
 Len := Length(S);
 Repeat
 ReadWord(S);
 W := Trim(Copy(S, I1, I2 - I1));
 If isConstant Then
  Begin
   If W[1] = HexChar Then
    Begin
      // convert hexadecimal to decimal
     W[1] := '$';
     W := IntToStr(StrToInt(W));
    End;
   If (W[1] = '''') or (W[1] = '"') Then
    Begin
      // StringConstant will handle any escaped quotes
     TempWord := TRESTDWMemStringConstant.Create(W);
    End
   Else
    Begin
     DecSep := Pos(FDecimalSeparator, W);
     If (DecSep > 0) Then
      Begin
   {$IFDEF ENG_NUMBERS}
        // we'll have to convert FDecimalSeparator into DecimalSeparator
        // otherwise the OS will not understand what we mean
   {$IFDEF FPC}
       W[DecSep] := DefaultFormatSettings.DecimalSeparator;
   {$ELSE}
    {$IFDEF RTL240_UP}
       W[DecSep] := FormatSettings.DecimalSeparator;
    {$ELSE}
       W[DecSep] := DecimalSeparator;
    {$ENDIF}
   {$ENDIF}
   {$ENDIF}
       TempWord := TRESTDWMemFloatConstant.Create(W, W)
      End Else Begin
     TempWord := TRESTDWMemIntegerConstant.Create(StrToInt(W));
    End;
  End;
  DestCollection.Add(TempWord);
  FConstantsList.Add(TempWord);
End
 Else If Length(W) > 0 Then
  If FWordsList.Search(PChar(W), I) Then
   Begin
    DestCollection.Add(FWordsList.Items[I])
   End Else Begin
    // unknown variable -> fire event
  HandleUnknownVariable(W);
    // try to search again
  If FWordsList.Search(PChar(W), I) Then
   Begin
    DestCollection.Add(FWordsList.Items[I])
   End Else Begin
   raise ERESTDWMemParserException.Create('Unknown variable '''+W+''' found.');
  End;
  End;
 Until I2 > Len;
End;

Procedure TRESTDWMemCustomExpressionParser.Check(AnExprList: TRESTDWMemExprCollection);
Var
 I, J, K, L: Integer;
Begin
 AnExprList.Check;
 With AnExprList Do
  Begin
   I := 0;
   While I < Count Do
    Begin
     {----CHECK ON DOUBLE MINUS OR DOUBLE PLUS----}
     If ((TRESTDWMemExprWord(Items[I]).Name = '-') or
     (TRESTDWMemExprWord(Items[I]).Name = '+'))
     and ((I = 0) or
     (TRESTDWMemExprWord(Items[I - 1]).ResultType = etComma) or
     (TRESTDWMemExprWord(Items[I - 1]).ResultType = etLeftBracket) or
     (TRESTDWMemExprWord(Items[I - 1]).IsOperator and (TRESTDWMemExprWord(Items[I - 1]).MaxFunctionArg
     = 2))) Then
     Begin
      {replace e.g. ----1 with +1}
      If TRESTDWMemExprWord(Items[I]).Name = '-' Then
      K := -1
      Else
      K := 1;
      L := 1;
      While (I + L < Count) and ((TRESTDWMemExprWord(Items[I + L]).Name = '-')
      or (TRESTDWMemExprWord(Items[I + L]).Name = '+')) and ((I + L = 0) or
      (TRESTDWMemExprWord(Items[I + L - 1]).ResultType = etComma) or
      (TRESTDWMemExprWord(Items[I + L - 1]).ResultType = etLeftBracket) or
      (TRESTDWMemExprWord(Items[I + L - 1]).IsOperator and (TRESTDWMemExprWord(Items[I + L -
      1]).MaxFunctionArg = 2))) Do
      Begin
       If TRESTDWMemExprWord(Items[I + L]).Name = '-' Then
       K := -1 * K;
       Inc(L);
      End;
      If L > 0 Then
       Begin
        Dec(L);
        For J := I + 1 To Count - 1 - L Do
        Items[J] := Items[J + L];
        Count := Count - L;
       End;
      If K = -1 Then
       Begin
        If FWordsList.Search(pchar('-@'), J) Then
        Items[I] := FWordsList.Items[J];
       End
      Else If FWordsList.Search(pchar('+@'), J) Then
      Items[I] := FWordsList.Items[J];
     End;
     {----CHECK ON DOUBLE NOT----}
     If (TRESTDWMemExprWord(Items[I]).Name = 'not')
     and ((I = 0) or
     (TRESTDWMemExprWord(Items[I - 1]).ResultType = etLeftBracket) or
     TRESTDWMemExprWord(Items[I - 1]).IsOperator) Then
     Begin
      {replace e.g. not not 1 with 1}
      K := -1;
      L := 1;
      While (I + L < Count) and (TRESTDWMemExprWord(Items[I + L]).Name = 'not') and ((I
      + L = 0) or
      (TRESTDWMemExprWord(Items[I + L - 1]).ResultType = etLeftBracket) or
      TRESTDWMemExprWord(Items[I + L - 1]).IsOperator) Do
      Begin
       K := -K;
       Inc(L);
      End;
      If L > 0 Then
       Begin
        If K = 1 Then
         Begin
          //remove all
          For J := I To Count - 1 - L Do
          Items[J] := Items[J + L];
          Count := Count - L;
         End
        Else
         Begin
          //keep one
          Dec(L);
          For J := I + 1 To Count - 1 - L Do
          Items[J] := Items[J + L];
          Count := Count - L;
         End
       End;
     End;
     {-----MISC CHECKS-----}
     If (TRESTDWMemExprWord(Items[I]).IsVariable) and ((I < Count - 1) and
     (TRESTDWMemExprWord(Items[I + 1]).IsVariable)) Then
     raise ERESTDWMemParserException.Create('Missing operator between '''+TRESTDWMemExprWord(Items[I]).Name+''' and '''+TRESTDWMemExprWord(Items[I]).Name+'''');
     If (TRESTDWMemExprWord(Items[I]).ResultType = etLeftBracket) and (I >= Count - 1) Then
     raise ERESTDWMemParserException.Create('Missing closing bracket');
     If (TRESTDWMemExprWord(Items[I]).ResultType = etRightBracket) and ((I < Count - 1) and
     (TRESTDWMemExprWord(Items[I + 1]).ResultType = etLeftBracket)) Then
     raise ERESTDWMemParserException.Create('Missing operator between )(');
     If (TRESTDWMemExprWord(Items[I]).ResultType = etRightBracket) and ((I < Count - 1) and
     (TRESTDWMemExprWord(Items[I + 1]).IsVariable)) Then
     raise ERESTDWMemParserException.Create('Missing operator between ) and constant/variable');
     If (TRESTDWMemExprWord(Items[I]).ResultType = etLeftBracket) and ((I > 0) and
     (TRESTDWMemExprWord(Items[I - 1]).IsVariable)) Then
     raise ERESTDWMemParserException.Create('Missing operator between constant/variable and (');
  
     {-----CHECK ON INTPOWER------}
     If (TRESTDWMemExprWord(Items[I]).Name = '^') and ((I < Count - 1) and
     (TRESTDWMemExprWord(Items[I + 1]).ClassType = TRESTDWMemIntegerConstant)) Then
     If FWordsList.Search(PChar('^@'), J) Then
     Items[I] := FWordsList.Items[J]; //use the faster intPower if possible
     Inc(I);
    End;
  End;
End;

Procedure TRESTDWMemCustomExpressionParser.EvaluateCurrent;
Var
 TempRec: PRESTDWMemExpressionRec;
Begin
 If FCurrentRec <> nil Then
  Begin
   // get current record
   TempRec := FCurrentRec;
   // execute list
   Repeat
   With TempRec^ Do
    Begin
      // do we need to reset pointer?
     If ResetDest Then
     Res.MemoryPos^ := Res.Memory^;
  
     Oper(TempRec);
  
      // goto next
     TempRec := Next;
    End;
   Until TempRec = nil;
  End;
End;

Function TRESTDWMemCustomExpressionParser.DefineFunction(AFunctName, AShortName, ADescription, ATypeSpec: string;
 AMinFunctionArg: Integer; AResultType: TRESTDWMemExpressionType; AFuncAddress: TRESTDWMemExprFunc): TRESTDWMemExprWord;
Begin
 Result := TRESTDWMemFunction.Create(AFunctName, AShortName, ATypeSpec, AMinFunctionArg, AResultType, AFuncAddress, ADescription);
 FWordsList.Add(Result);
End;

Function TRESTDWMemCustomExpressionParser.DefineIntegerVariable(AVarName: string; AValue: PInteger): TRESTDWMemExprWord;
Begin
 Result := TRESTDWMemIntegerVariable.Create(AVarName, AValue);
 FWordsList.Add(Result);
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Function TRESTDWMemCustomExpressionParser.DefineLargeIntVariable(AVarName: string; AValue: PRESTDWMemLargeInt): TRESTDWMemExprWord;
Begin
 Result := TRESTDWMemLargeIntVariable.Create(AVarName, AValue);
 FWordsList.Add(Result);
End;

{$ENDIF}

Function TRESTDWMemCustomExpressionParser.DefineDateTimeVariable(AVarName: string; AValue: PRESTDWMemDateTimeRec): TRESTDWMemExprWord;
Begin
 Result := TRESTDWMemDateTimeVariable.Create(AVarName, AValue);
 FWordsList.Add(Result);
End;

Function TRESTDWMemCustomExpressionParser.DefineBooleanVariable(AVarName: string; AValue: PBoolean): TRESTDWMemExprWord;
Begin
 Result := TRESTDWMemBooleanVariable.Create(AVarName, AValue);
 FWordsList.Add(Result);
End;

Function TRESTDWMemCustomExpressionParser.DefineFloatVariable(AVarName: string; AValue: PDouble): TRESTDWMemExprWord;
Begin
 Result := TRESTDWMemFloatVariable.Create(AVarName, AValue);
 FWordsList.Add(Result);
End;

Function TRESTDWMemCustomExpressionParser.DefineStringVariable(AVarName: string; AValue: PPChar): TRESTDWMemExprWord;
Begin
 Result := TRESTDWMemStringVariable.Create(AVarName, AValue);
 FWordsList.Add(Result);
End;

{
Procedure TRESTDWMemCustomExpressionParser.GetGeneratedVars(AList: TList);
Var
 I: Integer;
Begin
 AList.Clear;
 With FWordsList do
 For I := 0 to Count - 1 do
  Begin
   If TObject(Items[I]).ClassType = TGeneratedVariable then
   AList.Add(Items[I]);
  End;
End;
}

Function TRESTDWMemCustomExpressionParser.GetResultType: TRESTDWMemExpressionType;
Begin
 Result := etUnknown;
 If FCurrentRec <> nil Then
  Begin
   //LAST operand should be boolean -otherwise If(,,) doesn't work
   While (FLastRec^.Next <> nil) Do
   FLastRec := FLastRec^.Next;
   If FLastRec^.ExprWord <> nil Then
   Result := FLastRec^.ExprWord.ResultType;
  End;
End;

Function TRESTDWMemCustomExpressionParser.MakeRec: PRESTDWMemExpressionRec;
Var
 I: Integer;
Begin
 New(Result);
 Result^.Oper := nil;
 Result^.AuxData := nil;
 Result^.WantsFunction := false;
 For I := 0 To MaxArg - 1 Do
  Begin
   Result^.Args[I] := nil;
   Result^.ArgsPos[I] := nil;
   Result^.ArgsSize[I] := 0;
   Result^.ArgsType[I] := etUnknown;
   Result^.ArgList[I] := nil;
  End;
 Result^.Res := nil;
 Result^.Next := nil;
 Result^.ExprWord := nil;
 Result^.ResetDest := false;
End;

Procedure TRESTDWMemCustomExpressionParser.Evaluate(AnExpression: string);
Begin
 If Length(AnExpression) > 0 Then
  Begin
   AddExpression(AnExpression);
   EvaluateCurrent;
  End;
End;

Function TRESTDWMemCustomExpressionParser.AddExpression(AnExpression: string): Integer;
Begin
 If Length(AnExpression) > 0 Then
  Begin
   Result := 0;
   CompileExpression(AnExpression);
  End Else
 Result := -1;
 //CurrentIndex := Result;
End;

Procedure TRESTDWMemCustomExpressionParser.ClearExpressions;
Begin
 DisposeList(FCurrentRec);
 FCurrentRec := nil;
 FLastRec := nil;
End;

Function TRESTDWMemCustomExpressionParser.GetFunctionDescription(AFunction: string):
 string;
Var
 S: string;
 p, I: Integer;
Begin
 S := AFunction;
 p := Pos('(', S);
 If p > 0 Then
 S := Copy(S, 1, p - 1);
 If FWordsList.Search(pchar(S), I) Then
 Result := TRESTDWMemExprWord(FWordsList.Items[I]).Description
 Else
 Result := EmptyStr;
End;

Procedure TRESTDWMemCustomExpressionParser.GetFunctionNames(AList: TStrings);
Var
 I, J: Integer;
 S: string;
Begin
 With FWordsList Do
 For I := 0 To Count - 1 Do
  With TRESTDWMemExprWord(FWordsList.Items[I]) Do
  If Length(Description) > 0 Then
   Begin
    S := Name;
    If MaxFunctionArg > 0 Then
     Begin
      S := S + '(';
      For J := 0 To MaxFunctionArg - 2 Do
      S := S + ArgSeparator;
      S := S + ')';
     End;
    AList.Add(S);
   End;
End;


//--Expression functions-----------------------------------------------------

Procedure FuncFloatToStr(Param: PRESTDWMemExpressionRec);
Var
 width, numDigits, resWidth: Integer;
 extVal: Extended;
Begin
 With Param^ Do
  Begin
   // get params;
   numDigits := 0;
   If Args[1] <> nil Then
   width := PInteger(Args[1])^
   Else
   width := 18;
   If Args[2] <> nil Then
   numDigits := PInteger(Args[2])^;
   // convert to string
   Res.AssureSpace(width);
   extVal := PDouble(Args[0])^;
   resWidth := FloatToText(Res.MemoryPos^, extVal, {$ifndef FPC_VERSION}fvExtended,{$ENDIF} ffFixed, 18, numDigits);
   // always use dot as decimal separator
   If numDigits > 0 Then
   Res.MemoryPos^[resWidth-numDigits-1] := '.';
   // result width smaller than requested width? -> add space to compensate
   If (Args[1] <> nil) and (resWidth < width) Then
    Begin
     // move string so that it's right-aligned
     Move(Res.MemoryPos^^, (Res.MemoryPos^)[width-resWidth], resWidth);
     // fill gap with spaces
     FillChar(Res.MemoryPos^^, width-resWidth, ' ');
     // resWidth has been padded, update
     resWidth := width;
    End Else If resWidth > width Then Begin
    // result width more than requested width, cut
   resWidth := width;
  End;
  // advance pointer
 Inc(Res.MemoryPos^, resWidth);
  // null-terminate
 Res.MemoryPos^^ := #0;
End;
End;

Procedure FuncIntToStr_Gen(Param: PRESTDWMemExpressionRec; Val: {$IFDEF RESTDW_SUPPORT_INT64}Int64{$else}Integer{$ENDIF});
Var
 width: Integer;
Begin
 With Param^ Do
  Begin
   // width specified?
   If Args[1] <> nil Then
    Begin
     // convert to string
     width := PInteger(Args[1])^;
  {$IFDEF RESTDW_SUPPORT_INT64}
     GetStrFromInt64_Width
  {$else}
     GetStrFromInt_Width
  {$ENDIF}
     (Val, width, Res.MemoryPos^, #32);
     // advance pointer
     Inc(Res.MemoryPos^, width);
     // need to add decimal?
     If Args[2] <> nil Then
      Begin
       // get number of digits
       width := PInteger(Args[2])^;
       // add decimal dot
       Res.MemoryPos^^ := '.';
       Inc(Res.MemoryPos^);
       // add zeroes
       FillChar(Res.MemoryPos^^, width, '0');
       // go to end
       Inc(Res.MemoryPos^, width);
      End;
    End Else Begin
    // convert to string
   width :=
 {$IFDEF RESTDW_SUPPORT_INT64}
   GetStrFromInt64
 {$else}
   GetStrFromInt
 {$ENDIF}
    (Val, Res.MemoryPos^);
    // advance pointer
   Inc(Param^.Res.MemoryPos^, width);
  End;
  // null-terminate
 Res.MemoryPos^^ := #0;
End;
End;

Procedure FuncIntToStr(Param: PRESTDWMemExpressionRec);
Begin
 FuncIntToStr_Gen(Param, PInteger(Param^.Args[0])^);
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure FuncInt64ToStr(Param: PRESTDWMemExpressionRec);
Begin
 FuncIntToStr_Gen(Param, PInt64(Param^.Args[0])^);
End;

{$ENDIF}

Procedure FuncDateToStr(Param: PRESTDWMemExpressionRec);
Var
 TempStr: string;
Begin
 With Param^ Do
  Begin
   // create in temporary string
   DateTimeToString(TempStr, 'yyyymmdd', PRESTDWMemDateTimeRec(Args[0])^.DateTime);
   // copy to buffer
   Res.Append(PChar(TempStr), Length(TempStr));
  End;
End;

Procedure FuncSubString(Param: PRESTDWMemExpressionRec);
Var
 srcLen, index, count: Integer;
Begin
 With Param^ Do
  Begin
   srcLen := StrLen(Args[0]);
   index := PInteger(Args[1])^ - 1;
   If Args[2] <> nil Then
    Begin
     count := PInteger(Args[2])^;
     If index + count > srcLen Then
     count := srcLen - index;
    End Else
   count := srcLen - index;
   Res.Append(Args[0]+index, count)
  End;
End;

Procedure FuncLeft(Param: PRESTDWMemExpressionRec);
Var
 srcLen,  count: Integer;
Begin
 srcLen := StrLen(Param^.Args[0]);
 count := PInteger(Param^.Args[1])^;
 If  count > srcLen Then
 count := srcLen;
 Param^.Res.Append(Param^.Args[0], count)
End;

Procedure FuncUppercase(Param: PRESTDWMemExpressionRec);
Var
 dest: PChar;
Begin
 With Param^ Do
  Begin
   // first copy
   dest := (Res.MemoryPos)^;
   Res.Append(Args[0], StrLen(Args[0]));
   // make uppercase
   AnsiStrUpper(dest);
  End;
End;

Procedure FuncLowercase(Param: PRESTDWMemExpressionRec);
Var
 dest: PChar;
Begin
 With Param^ Do
  Begin
   // first copy
   dest := (Res.MemoryPos)^;
   Res.Append(Args[0], StrLen(Args[0]));
   // make lowercase
   AnsiStrLower(dest);
  End;
End;

Procedure FuncNegative_F_F(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := -PDouble(Args[0])^;
End;

Procedure FuncNegative_I_I(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInteger(Res.MemoryPos^)^ := -PInteger(Args[0])^;
End;

{$IFDEF RESTDW_SUPPORT_INT64}
Procedure FuncNegative_L_L(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := -PInt64(Args[0])^;
End;
{$ENDIF}

Procedure FuncAdd_F_FF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ + PDouble(Args[1])^;
End;

Procedure FuncAdd_F_FI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ + PInteger(Args[1])^;
End;

Procedure FuncAdd_F_II(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ + PInteger(Args[1])^;
End;

Procedure FuncAdd_F_IF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ + PDouble(Args[1])^;
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure FuncAdd_F_FL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ + PInt64(Args[1])^;
End;

Procedure FuncAdd_F_IL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ + PInt64(Args[1])^;
End;

Procedure FuncAdd_F_LL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ + PInt64(Args[1])^;
End;

Procedure FuncAdd_F_LF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ + PDouble(Args[1])^;
End;

Procedure FuncAdd_F_LI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ + PInteger(Args[1])^;
End;

{$ENDIF}

Procedure FuncSub_F_FF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ - PDouble(Args[1])^;
End;

Procedure FuncSub_F_FI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ - PInteger(Args[1])^;
End;

Procedure FuncSub_F_II(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ - PInteger(Args[1])^;
End;

Procedure FuncSub_F_IF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ - PDouble(Args[1])^;
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure FuncSub_F_FL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ - PInt64(Args[1])^;
End;

Procedure FuncSub_F_IL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ - PInt64(Args[1])^;
End;

Procedure FuncSub_F_LL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ - PInt64(Args[1])^;
End;

Procedure FuncSub_F_LF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ - PDouble(Args[1])^;
End;

Procedure FuncSub_F_LI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ - PInteger(Args[1])^;
End;

{$ENDIF}

Procedure FuncMul_F_FF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ * PDouble(Args[1])^;
End;

Procedure FuncMul_F_FI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ * PInteger(Args[1])^;
End;

Procedure FuncMul_F_II(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ * PInteger(Args[1])^;
End;

Procedure FuncMul_F_IF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ * PDouble(Args[1])^;
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure FuncMul_F_FL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ * PInt64(Args[1])^;
End;

Procedure FuncMul_F_IL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ * PInt64(Args[1])^;
End;

Procedure FuncMul_F_LL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ * PInt64(Args[1])^;
End;

Procedure FuncMul_F_LF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ * PDouble(Args[1])^;
End;

Procedure FuncMul_F_LI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ * PInteger(Args[1])^;
End;

{$ENDIF}

Procedure FuncDiv_F_FF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ / PDouble(Args[1])^;
End;

Procedure FuncDiv_F_FI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ / PInteger(Args[1])^;
End;

Procedure FuncDiv_F_II(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInteger(Res.MemoryPos^)^ := PInteger(Args[0])^ div PInteger(Args[1])^;
End;

Procedure FuncDiv_F_IF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInteger(Args[0])^ / PDouble(Args[1])^;
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure FuncDiv_F_FL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PDouble(Args[0])^ / PInt64(Args[1])^;
End;

Procedure FuncDiv_F_IL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInteger(Args[0])^ div PInt64(Args[1])^;
End;

Procedure FuncDiv_F_LL(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ div PInt64(Args[1])^;
End;

Procedure FuncDiv_F_LF(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PDouble(Res.MemoryPos^)^ := PInt64(Args[0])^ / PDouble(Args[1])^;
End;

Procedure FuncDiv_F_LI(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 PInt64(Res.MemoryPos^)^ := PInt64(Args[0])^ div PInteger(Args[1])^;
End;

{$ENDIF}

Procedure FuncStrI_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) = 0);
End;

Procedure FuncStrIP_EQ(Param: PRESTDWMemExpressionRec);
Var
 arg0len, arg1len: integer;
 match: boolean;
 str0, str1: string;
Begin
 With Param^ Do
  Begin
   arg1len := StrLen(Args[1]);
   If Args[1][0] = '*' Then
    Begin
     If Args[1][arg1len-1] = '*' Then
      Begin
       str0 := AnsiStrUpper(Args[0]);
       str1 := AnsiStrUpper(Args[1]+1);
       setlength(str1, arg1len-2);
       match := AnsiPos(str1, str0) <> 0;
      End Else Begin
     arg0len := StrLen(Args[0]);
      // at least length without asterisk
     match := arg0len >= arg1len - 1;
     If match Then
     match := AnsiStrLIComp(Args[0]+(arg0len-arg1len+1), Args[1]+1, arg1len-1) = 0;
    End;
  End Else
 If Args[1][arg1len-1] = '*' Then
  Begin
   arg0len := StrLen(Args[0]);
   match := arg0len >= arg1len - 1;
   If match Then
   match := AnsiStrLIComp(Args[0], Args[1], arg1len-1) = 0;
  End Else Begin
  match := AnsiStrIComp(Args[0], Args[1]) = 0;
End;
 Res.MemoryPos^^ := Char(match);
 End;
End;

Procedure FuncStrI_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) <> 0);
End;

Procedure FuncStrI_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) < 0);
End;

Procedure FuncStrI_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) > 0);
End;

Procedure FuncStrI_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) <= 0);
End;

Procedure FuncStrI_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrIComp(Args[0], Args[1]) >= 0);
End;

Procedure FuncStrP_EQ(Param: PRESTDWMemExpressionRec);
Var
 arg0len, arg1len: integer;
 match: boolean;
Begin
 With Param^ Do
  Begin
   arg1len := StrLen(Args[1]);
   If Args[1][0] = '*' Then
    Begin
     If Args[1][arg1len-1] = '*' Then
      Begin
       Args[1][arg1len-1] := #0;
       match := AnsiStrPos(Args[0], Args[1]+1) <> nil;
       Args[1][arg1len-1] := '*';
      End Else Begin
     arg0len := StrLen(Args[0]);
      // at least length without asterisk
     match := arg0len >= arg1len - 1;
     If match Then
     match := AnsiStrLComp(Args[0]+(arg0len-arg1len+1), Args[1]+1, arg1len-1) = 0;
    End;
  End Else
 If Args[1][arg1len-1] = '*' Then
  Begin
   arg0len := StrLen(Args[0]);
   match := arg0len >= arg1len - 1;
   If match Then
   match := AnsiStrLComp(Args[0], Args[1], arg1len-1) = 0;
  End Else Begin
  match := AnsiStrComp(Args[0], Args[1]) = 0;
End;
 Res.MemoryPos^^ := Char(match);
 End;
End;

Procedure FuncStr_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) = 0);
End;

Procedure FuncStr_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) <> 0);
End;

Procedure FuncStr_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) < 0);
End;

Procedure FuncStr_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) > 0);
End;

Procedure FuncStr_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) <= 0);
End;

Procedure FuncStr_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(AnsiStrComp(Args[0], Args[1]) >= 0);
End;

Procedure Func_FF_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   =  PDouble(Args[1])^);
End;

Procedure Func_FF_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <> PDouble(Args[1])^);
End;

Procedure Func_FF_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <  PDouble(Args[1])^);
End;

Procedure Func_FF_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   >  PDouble(Args[1])^);
End;

Procedure Func_FF_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <= PDouble(Args[1])^);
End;

Procedure Func_FF_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   >= PDouble(Args[1])^);
End;

Procedure Func_FI_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   =  PInteger(Args[1])^);
End;

Procedure Func_FI_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <> PInteger(Args[1])^);
End;

Procedure Func_FI_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <  PInteger(Args[1])^);
End;

Procedure Func_FI_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   >  PInteger(Args[1])^);
End;

Procedure Func_FI_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <= PInteger(Args[1])^);
End;

Procedure Func_FI_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   >= PInteger(Args[1])^);
End;

Procedure Func_II_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  =  PInteger(Args[1])^);
End;

Procedure Func_II_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <> PInteger(Args[1])^);
End;

Procedure Func_II_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <  PInteger(Args[1])^);
End;

Procedure Func_II_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  >  PInteger(Args[1])^);
End;

Procedure Func_II_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <= PInteger(Args[1])^);
End;

Procedure Func_II_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  >= PInteger(Args[1])^);
End;

Procedure Func_IF_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  =  PDouble(Args[1])^);
End;

Procedure Func_IF_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <> PDouble(Args[1])^);
End;

Procedure Func_IF_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <  PDouble(Args[1])^);
End;

Procedure Func_IF_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  >  PDouble(Args[1])^);
End;

Procedure Func_IF_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <= PDouble(Args[1])^);
End;

Procedure Func_IF_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  >= PDouble(Args[1])^);
End;

{$IFDEF RESTDW_SUPPORT_INT64}

Procedure Func_LL_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    =  PInt64(Args[1])^);
End;

Procedure Func_LL_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <> PInt64(Args[1])^);
End;

Procedure Func_LL_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <  PInt64(Args[1])^);
End;

Procedure Func_LL_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    >  PInt64(Args[1])^);
End;

Procedure Func_LL_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <= PInt64(Args[1])^);
End;

Procedure Func_LL_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    >= PInt64(Args[1])^);
End;

Procedure Func_LF_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    =  PDouble(Args[1])^);
End;

Procedure Func_LF_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <> PDouble(Args[1])^);
End;

Procedure Func_LF_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <  PDouble(Args[1])^);
End;

Procedure Func_LF_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    >  PDouble(Args[1])^);
End;

Procedure Func_LF_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <= PDouble(Args[1])^);
End;

Procedure Func_LF_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    >= PDouble(Args[1])^);
End;

Procedure Func_FL_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   =  PInt64(Args[1])^);
End;

Procedure Func_FL_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <> PInt64(Args[1])^);
End;

Procedure Func_FL_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <  PInt64(Args[1])^);
End;

Procedure Func_FL_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   >  PInt64(Args[1])^);
End;

Procedure Func_FL_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   <= PInt64(Args[1])^);
End;

Procedure Func_FL_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PDouble(Args[0])^   >= PInt64(Args[1])^);
End;

Procedure Func_LI_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    =  PInteger(Args[1])^);
End;

Procedure Func_LI_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <> PInteger(Args[1])^);
End;

Procedure Func_LI_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <  PInteger(Args[1])^);
End;

Procedure Func_LI_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    >  PInteger(Args[1])^);
End;

Procedure Func_LI_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    <= PInteger(Args[1])^);
End;

Procedure Func_LI_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInt64(Args[0])^    >= PInteger(Args[1])^);
End;

Procedure Func_IL_EQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  =  PInt64(Args[1])^);
End;

Procedure Func_IL_NEQ(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <> PInt64(Args[1])^);
End;

Procedure Func_IL_LT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <  PInt64(Args[1])^);
End;

Procedure Func_IL_GT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  >  PInt64(Args[1])^);
End;

Procedure Func_IL_LTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  <= PInt64(Args[1])^);
End;

Procedure Func_IL_GTE(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(PInteger(Args[0])^  >= PInt64(Args[1])^);
End;

{$ENDIF}

Procedure Func_AND(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(Boolean(Args[0]^) and Boolean(Args[1]^));
End;

Procedure Func_OR(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(Boolean(Args[0]^) or Boolean(Args[1]^));
End;

Procedure Func_NOT(Param: PRESTDWMemExpressionRec);
Begin
 With Param^ Do
 Res.MemoryPos^^ := Char(not Boolean(Args[0]^));
End;

Initialization

 DbfWordsGeneralList := TRESTDWMemExpressList.Create;
 DbfWordsInsensGeneralList := TRESTDWMemExpressList.Create;
 DbfWordsInsensNoPartialList := TRESTDWMemExpressList.Create;
 DbfWordsInsensPartialList := TRESTDWMemExpressList.Create;
 DbfWordsSensGeneralList := TRESTDWMemExpressList.Create;
 DbfWordsSensNoPartialList := TRESTDWMemExpressList.Create;
 DbfWordsSensPartialList := TRESTDWMemExpressList.Create;

 With DbfWordsGeneralList Do
  Begin
   // basic function functionality
   Add(TRESTDWMemLeftBracket.Create('(', nil));
   Add(TRESTDWMemRightBracket.Create(')', nil));
   Add(TRESTDWMemComma.Create(',', nil));
 
   // operators - name, param types, result type, func addr, precedence
   // note that the parameter types in the second column must match with
   // the function signature in the function address
   Add(TRESTDWMemFunction.CreateOper('-@', 'I', etInteger,  TRESTDWMemExprFunc(@FuncNegative_I_I), 20));
   Add(TRESTDWMemFunction.CreateOper('-@', 'F', etFloat,    TRESTDWMemExprFunc(@FuncNegative_F_F), 20));
 {$IFDEF RESTDW_SUPPORT_INT64}
   Add(TRESTDWMemFunction.CreateOper('-@', 'L', etLargeInt, TRESTDWMemExprFunc(@FuncNegative_L_L), 20));
 {$ENDIF}
   Add(TRESTDWMemFunction.CreateOper('+', 'SS', etString,   nil,          40));
   Add(TRESTDWMemFunction.CreateOper('+', 'FF', etFloat,    TRESTDWMemExprFunc(@FuncAdd_F_FF), 40));
   Add(TRESTDWMemFunction.CreateOper('+', 'FI', etFloat,    TRESTDWMemExprFunc(@FuncAdd_F_FI), 40));
   Add(TRESTDWMemFunction.CreateOper('+', 'IF', etFloat,    TRESTDWMemExprFunc(@FuncAdd_F_IF), 40));
   Add(TRESTDWMemFunction.CreateOper('+', 'II', etInteger,  TRESTDWMemExprFunc(@FuncAdd_F_II), 40));
 {$IFDEF RESTDW_SUPPORT_INT64}
   Add(TRESTDWMemFunction.CreateOper('+', 'FL', etFloat,    TRESTDWMemExprFunc(@FuncAdd_F_FL), 40));
   Add(TRESTDWMemFunction.CreateOper('+', 'IL', etLargeInt, TRESTDWMemExprFunc(@FuncAdd_F_IL), 40));
   Add(TRESTDWMemFunction.CreateOper('+', 'LF', etFloat,    TRESTDWMemExprFunc(@FuncAdd_F_LF), 40));
   Add(TRESTDWMemFunction.CreateOper('+', 'LL', etLargeInt, TRESTDWMemExprFunc(@FuncAdd_F_LL), 40));
   Add(TRESTDWMemFunction.CreateOper('+', 'LI', etLargeInt, TRESTDWMemExprFunc(@FuncAdd_F_LI), 40));
 {$ENDIF}
   Add(TRESTDWMemFunction.CreateOper('-', 'FF', etFloat,    TRESTDWMemExprFunc(@FuncSub_F_FF), 40));
   Add(TRESTDWMemFunction.CreateOper('-', 'FI', etFloat,    TRESTDWMemExprFunc(@FuncSub_F_FI), 40));
   Add(TRESTDWMemFunction.CreateOper('-', 'IF', etFloat,    TRESTDWMemExprFunc(@FuncSub_F_IF), 40));
   Add(TRESTDWMemFunction.CreateOper('-', 'II', etInteger,  TRESTDWMemExprFunc(@FuncSub_F_II), 40));
 {$IFDEF RESTDW_SUPPORT_INT64}
   Add(TRESTDWMemFunction.CreateOper('-', 'FL', etFloat,    TRESTDWMemExprFunc(@FuncSub_F_FL), 40));
   Add(TRESTDWMemFunction.CreateOper('-', 'IL', etLargeInt, TRESTDWMemExprFunc(@FuncSub_F_IL), 40));
   Add(TRESTDWMemFunction.CreateOper('-', 'LF', etFloat,    TRESTDWMemExprFunc(@FuncSub_F_LF), 40));
   Add(TRESTDWMemFunction.CreateOper('-', 'LL', etLargeInt, TRESTDWMemExprFunc(@FuncSub_F_LL), 40));
   Add(TRESTDWMemFunction.CreateOper('-', 'LI', etLargeInt, TRESTDWMemExprFunc(@FuncSub_F_LI), 40));
 {$ENDIF}
   Add(TRESTDWMemFunction.CreateOper('*', 'FF', etFloat,    TRESTDWMemExprFunc(@FuncMul_F_FF), 40));
   Add(TRESTDWMemFunction.CreateOper('*', 'FI', etFloat,    TRESTDWMemExprFunc(@FuncMul_F_FI), 40));
   Add(TRESTDWMemFunction.CreateOper('*', 'IF', etFloat,    TRESTDWMemExprFunc(@FuncMul_F_IF), 40));
   Add(TRESTDWMemFunction.CreateOper('*', 'II', etInteger,  TRESTDWMemExprFunc(@FuncMul_F_II), 40));
 {$IFDEF RESTDW_SUPPORT_INT64}
   Add(TRESTDWMemFunction.CreateOper('*', 'FL', etFloat,    TRESTDWMemExprFunc(@FuncMul_F_FL), 40));
   Add(TRESTDWMemFunction.CreateOper('*', 'IL', etLargeInt, TRESTDWMemExprFunc(@FuncMul_F_IL), 40));
   Add(TRESTDWMemFunction.CreateOper('*', 'LF', etFloat,    TRESTDWMemExprFunc(@FuncMul_F_LF), 40));
   Add(TRESTDWMemFunction.CreateOper('*', 'LL', etLargeInt, TRESTDWMemExprFunc(@FuncMul_F_LL), 40));
   Add(TRESTDWMemFunction.CreateOper('*', 'LI', etLargeInt, TRESTDWMemExprFunc(@FuncMul_F_LI), 40));
 {$ENDIF}
   Add(TRESTDWMemFunction.CreateOper('/', 'FF', etFloat,    TRESTDWMemExprFunc(@FuncDiv_F_FF), 40));
   Add(TRESTDWMemFunction.CreateOper('/', 'FI', etFloat,    TRESTDWMemExprFunc(@FuncDiv_F_FI), 40));
   Add(TRESTDWMemFunction.CreateOper('/', 'IF', etFloat,    TRESTDWMemExprFunc(@FuncDiv_F_IF), 40));
   Add(TRESTDWMemFunction.CreateOper('/', 'II', etInteger,  TRESTDWMemExprFunc(@FuncDiv_F_II), 40));
 {$IFDEF RESTDW_SUPPORT_INT64}
   Add(TRESTDWMemFunction.CreateOper('/', 'FL', etFloat,    TRESTDWMemExprFunc(@FuncDiv_F_FL), 40));
   Add(TRESTDWMemFunction.CreateOper('/', 'IL', etLargeInt, TRESTDWMemExprFunc(@FuncDiv_F_IL), 40));
   Add(TRESTDWMemFunction.CreateOper('/', 'LF', etFloat,    TRESTDWMemExprFunc(@FuncDiv_F_LF), 40));
   Add(TRESTDWMemFunction.CreateOper('/', 'LL', etLargeInt, TRESTDWMemExprFunc(@FuncDiv_F_LL), 40));
   Add(TRESTDWMemFunction.CreateOper('/', 'LI', etLargeInt, TRESTDWMemExprFunc(@FuncDiv_F_LI), 40));
 {$ENDIF}
 
   Add(TRESTDWMemFunction.CreateOper('=', 'FF', etBoolean, TRESTDWMemExprFunc(@Func_FF_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'FF', etBoolean, TRESTDWMemExprFunc(@Func_FF_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'FF', etBoolean, TRESTDWMemExprFunc(@Func_FF_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','FF', etBoolean, TRESTDWMemExprFunc(@Func_FF_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','FF', etBoolean, TRESTDWMemExprFunc(@Func_FF_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','FF', etBoolean, TRESTDWMemExprFunc(@Func_FF_NEQ), 80));
   Add(TRESTDWMemFunction.CreateOper('=', 'FI', etBoolean, TRESTDWMemExprFunc(@Func_FI_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'FI', etBoolean, TRESTDWMemExprFunc(@Func_FI_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'FI', etBoolean, TRESTDWMemExprFunc(@Func_FI_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','FI', etBoolean, TRESTDWMemExprFunc(@Func_FI_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','FI', etBoolean, TRESTDWMemExprFunc(@Func_FI_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','FI', etBoolean, TRESTDWMemExprFunc(@Func_FI_NEQ), 80));
   Add(TRESTDWMemFunction.CreateOper('=', 'II', etBoolean, TRESTDWMemExprFunc(@Func_II_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'II', etBoolean, TRESTDWMemExprFunc(@Func_II_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'II', etBoolean, TRESTDWMemExprFunc(@Func_II_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','II', etBoolean, TRESTDWMemExprFunc(@Func_II_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','II', etBoolean, TRESTDWMemExprFunc(@Func_II_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','II', etBoolean, TRESTDWMemExprFunc(@Func_II_NEQ), 80));
   Add(TRESTDWMemFunction.CreateOper('=', 'IF', etBoolean, TRESTDWMemExprFunc(@Func_IF_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'IF', etBoolean, TRESTDWMemExprFunc(@Func_IF_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'IF', etBoolean, TRESTDWMemExprFunc(@Func_IF_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','IF', etBoolean, TRESTDWMemExprFunc(@Func_IF_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','IF', etBoolean, TRESTDWMemExprFunc(@Func_IF_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','IF', etBoolean, TRESTDWMemExprFunc(@Func_IF_NEQ), 80));
 {$IFDEF RESTDW_SUPPORT_INT64}
   Add(TRESTDWMemFunction.CreateOper('=', 'LL', etBoolean, TRESTDWMemExprFunc(@Func_LL_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'LL', etBoolean, TRESTDWMemExprFunc(@Func_LL_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'LL', etBoolean, TRESTDWMemExprFunc(@Func_LL_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','LL', etBoolean, TRESTDWMemExprFunc(@Func_LL_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','LL', etBoolean, TRESTDWMemExprFunc(@Func_LL_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','LL', etBoolean, TRESTDWMemExprFunc(@Func_LL_NEQ), 80));
   Add(TRESTDWMemFunction.CreateOper('=', 'LF', etBoolean, TRESTDWMemExprFunc(@Func_LF_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'LF', etBoolean, TRESTDWMemExprFunc(@Func_LF_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'LF', etBoolean, TRESTDWMemExprFunc(@Func_LF_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','LF', etBoolean, TRESTDWMemExprFunc(@Func_LF_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','LF', etBoolean, TRESTDWMemExprFunc(@Func_LF_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','LF', etBoolean, TRESTDWMemExprFunc(@Func_LF_NEQ), 80));
   Add(TRESTDWMemFunction.CreateOper('=', 'LI', etBoolean, TRESTDWMemExprFunc(@Func_LI_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'LI', etBoolean, TRESTDWMemExprFunc(@Func_LI_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'LI', etBoolean, TRESTDWMemExprFunc(@Func_LI_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','LI', etBoolean, TRESTDWMemExprFunc(@Func_LI_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','LI', etBoolean, TRESTDWMemExprFunc(@Func_LI_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','LI', etBoolean, TRESTDWMemExprFunc(@Func_LI_NEQ), 80));
   Add(TRESTDWMemFunction.CreateOper('=', 'FL', etBoolean, TRESTDWMemExprFunc(@Func_FL_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'FL', etBoolean, TRESTDWMemExprFunc(@Func_FL_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'FL', etBoolean, TRESTDWMemExprFunc(@Func_FL_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','FL', etBoolean, TRESTDWMemExprFunc(@Func_FL_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','FL', etBoolean, TRESTDWMemExprFunc(@Func_FL_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','FL', etBoolean, TRESTDWMemExprFunc(@Func_FL_NEQ), 80));
   Add(TRESTDWMemFunction.CreateOper('=', 'IL', etBoolean, TRESTDWMemExprFunc(@Func_IL_EQ) , 80));
   Add(TRESTDWMemFunction.CreateOper('<', 'IL', etBoolean, TRESTDWMemExprFunc(@Func_IL_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'IL', etBoolean, TRESTDWMemExprFunc(@Func_IL_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','IL', etBoolean, TRESTDWMemExprFunc(@Func_IL_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','IL', etBoolean, TRESTDWMemExprFunc(@Func_IL_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','IL', etBoolean, TRESTDWMemExprFunc(@Func_IL_NEQ), 80));
 {$ENDIF}
 
   Add(TRESTDWMemFunction.CreateOper('NOT', 'B',  etBoolean, TRESTDWMemExprFunc(@Func_NOT), 85));
   Add(TRESTDWMemFunction.CreateOper('AND', 'BB', etBoolean, TRESTDWMemExprFunc(@Func_AND), 90));
   Add(TRESTDWMemFunction.CreateOper('OR',  'BB', etBoolean, TRESTDWMemExprFunc(@Func_OR), 100));
 
   // Functions - name, description, param types, min params, result type, Func addr
   Add(TRESTDWMemFunction.Create('STR',       '',      'FII', 1, etString, TRESTDWMemExprFunc(@FuncFloatToStr), ''));
   Add(TRESTDWMemFunction.Create('STR',       '',      'III', 1, etString, TRESTDWMemExprFunc(@FuncIntToStr), ''));
 {$IFDEF RESTDW_SUPPORT_INT64}
   Add(TRESTDWMemFunction.Create('STR',       '',      'LII', 1, etString, TRESTDWMemExprFunc(@FuncInt64ToStr), ''));
 {$ENDIF}
   Add(TRESTDWMemFunction.Create('LEFT',      '',  'SI',  2, etString, TRESTDWMemExprFunc(@FuncLeft), ''));
   Add(TRESTDWMemFunction.Create('DTOS',      '',      'D',   1, etString, TRESTDWMemExprFunc(@FuncDateToStr), ''));
   Add(TRESTDWMemFunction.Create('SUBSTR',    'SUBS',  'SII', 3, etString, TRESTDWMemExprFunc(@FuncSubString), ''));
   Add(TRESTDWMemFunction.Create('UPPERCASE', 'UPPER', 'S',   1, etString, TRESTDWMemExprFunc(@FuncUppercase), ''));
   Add(TRESTDWMemFunction.Create('LOWERCASE', 'LOWER', 'S',   1, etString, TRESTDWMemExprFunc(@FuncLowercase), ''));
  End;

 With DbfWordsInsensGeneralList Do
  Begin
   Add(TRESTDWMemFunction.CreateOper('<', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStrI_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStrI_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','SS', etBoolean, TRESTDWMemExprFunc(@FuncStrI_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','SS', etBoolean, TRESTDWMemExprFunc(@FuncStrI_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','SS', etBoolean, TRESTDWMemExprFunc(@FuncStrI_NEQ), 80));
  End;

 With DbfWordsInsensNoPartialList Do
 Add(TRESTDWMemFunction.CreateOper('=', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStrI_EQ) , 80));

 With DbfWordsInsensPartialList Do
 Add(TRESTDWMemFunction.CreateOper('=', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStrIP_EQ), 80));

 With DbfWordsSensGeneralList Do
  Begin
   Add(TRESTDWMemFunction.CreateOper('<', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStr_LT) , 80));
   Add(TRESTDWMemFunction.CreateOper('>', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStr_GT) , 80));
   Add(TRESTDWMemFunction.CreateOper('<=','SS', etBoolean, TRESTDWMemExprFunc(@FuncStr_LTE), 80));
   Add(TRESTDWMemFunction.CreateOper('>=','SS', etBoolean, TRESTDWMemExprFunc(@FuncStr_GTE), 80));
   Add(TRESTDWMemFunction.CreateOper('<>','SS', etBoolean, TRESTDWMemExprFunc(@FuncStr_NEQ), 80));
  End;

 With DbfWordsSensNoPartialList Do
 Add(TRESTDWMemFunction.CreateOper('=', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStr_EQ) , 80));

 With DbfWordsSensPartialList Do
 Add(TRESTDWMemFunction.CreateOper('=', 'SS', etBoolean, TRESTDWMemExprFunc(@FuncStrP_EQ) , 80));

Finalization

 DbfWordsGeneralList.Free;
 DbfWordsInsensGeneralList.Free;
 DbfWordsInsensNoPartialList.Free;
 DbfWordsInsensPartialList.Free;
 DbfWordsSensGeneralList.Free;
 DbfWordsSensNoPartialList.Free;
 DbfWordsSensPartialList.Free;
End.
