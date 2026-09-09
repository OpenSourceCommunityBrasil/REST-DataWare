Unit uRESTDWMemDBFilterExpr;
{$I uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface
Uses
  SysUtils, Classes, Variants, DB{$IFNDEF FPC}, DBCommon {$ENDIF};
Type
  TJvDBFilterExpression = Class(TObject)
  Private
    FDataSet: TDataSet;
    {$IFNDEF FPC}
    FParser: TExprParser;
    FRoot: PExprNode;
    Function EvalOpNode(N: PExprNode): Boolean;
    Function EvalFuncNode(N: PExprNode): Variant;
    Function EvaluateNode(N: PExprNode): Variant;
    {$ENDIF}
  Public
    Constructor Create(ADataSet: TDataSet; Const Filter: string; Const FilterOptions: TFilterOptions);
    Destructor Destroy; override;
    Function Evaluate: Boolean;
  End;
Implementation
Uses
 {$IFNDEF FPC}SqlTimSt, {$ENDIF}DateUtils, uRESTDWMemResources, uRESTDWBasicTypes, uRESTDWTools;

Var
  FieldTypeMapInitialized: Boolean = False;
  FieldTypeMap: TFieldMap;
Type
  TExprParserAccess = Class
  Protected
    FDecimalSeparator: {$IFNDEF FPC}{$IF CompilerVersion > 17.0}WideChar{$ELSE}Char{$IFEND}{$ELSE}Char{$ENDIF}; // Delphi 2006+ use WideChar
    {$IFNDEF FPC}
    FFilter: TFilterExpr;
    {$ENDIF}
  End;
  TFilterExprAccess = Class
  Protected
    FDataSet: TDataSet;
    FFieldMap: TFieldMap;
    FOptions: TFilterOptions;
    {$IFNDEF FPC}
    FParserOptions: TParserOptions;
    FNodes: PExprNode;
    {$ENDIF}
  End;
{------------------------------------------------------------------------------}
Function TrimLeftEx(Const S, Blanks: string): string;
Var
  I, Len: Integer;
Begin
  Len := Length(S);
  I := 1;
  While (I <= Len) and (Pos(S[I], Blanks) > 0) Do
    Inc(I);
  Result := Copy(S, I, MaxInt);
End;
Function TrimRightEx(Const S, Blanks: string): string;
Var
  I: Integer;
Begin
  I := Length(S);
  While (I > 0) and (Pos(S[I], Blanks) > 0) Do
    Dec(I);
  Result := Copy(S, 1, I);
End;
Function TrimEx(Const S, Blanks: string): string;
Var
  L, R, Len: Integer;
Begin
  Len := Length(S);
  L := 1;
  While (L <= Len) and (Pos(S[L], Blanks) > 0) Do
    Inc(L);
  R := Len;
  While (R >= L) and (Pos(S[R], Blanks) > 0) Do
    Dec(R);
  Result := Copy(S, L, R - L + 1);
End;
// Derived from "Like" by Michael Winter
Function IsLike(Const MaskStr, S: string): Boolean;
Var
  StringPtr: PChar;
  PatternPtr: PChar;
  StringRes: PChar;
  PatternRes: PChar;
  Index: Integer;
Begin
  If MaskStr = '' Then
  Begin
    Result := False;
    Exit;
  End;
  Result := MaskStr = '%';
  If Result or (S = '') Then
    Exit;
  Index := 1;
  StringPtr := PChar(S) + Index - 1;
  PatternPtr := PChar(MaskStr);
  StringRes := nil;
  PatternRes := nil;
  Repeat
    Repeat
      Case PatternPtr^ Of
        #0:
          Begin
            Result := StringPtr^ = #0;
            If Result or (StringRes = nil) or (PatternRes = nil) Then
              Exit;
            StringPtr := StringRes;
            PatternPtr := PatternRes;
            Break;
          End;
        '%':
          Begin
            Inc(PatternPtr);
            PatternRes := PatternPtr;
            Break;
          End;
        '_':
          Begin
            If StringPtr^ = #0 Then
              Exit;
            Inc(StringPtr);
            Inc(PatternPtr);
          End;
        Else
          Begin
            If StringPtr^ = #0 Then
              Exit;
            If StringPtr^ <> PatternPtr^ Then
            Begin
              If (StringRes = nil) or (PatternRes = nil) Then
                Exit;
              StringPtr := StringRes;
              PatternPtr := PatternRes;
              Break;
            End
            Else
            Begin
              Inc(StringPtr);
              Inc(PatternPtr);
            End;
          End;
      End;
    Until False;
    Repeat
      Case PatternPtr^ Of
        #0:
          Begin
            Result := True;
            Exit;
          End;
        '%':
          Begin
            Inc(PatternPtr);
            PatternRes := PatternPtr;
          End;
        '_':
          Begin
            If StringPtr^ = #0 Then
              Exit;
            Inc(StringPtr);
            Inc(PatternPtr);
          End;
        Else
          Begin
            Repeat
              If StringPtr^ = #0 Then
                Exit;
              If StringPtr^ = PatternPtr^ Then
                Break;
              Inc(StringPtr);
            Until False;
            Inc(StringPtr);
            StringRes := StringPtr;
            Inc(PatternPtr);
            Break;
          End;
      End;
    Until False;
  Until False;
End;
{------------------------------------------------------------------------------}
{ TJvDBFilterExpression }
Constructor TJvDBFilterExpression.Create(ADataSet: TDataSet; Const Filter: string;
  Const FilterOptions: TFilterOptions);
Var
  FieldType: TFieldType;
  {$IFNDEF FPC}
  Nodes: PExprNode;
  Function NodesContainsLeftRight(Root: PExprNode): Boolean;
  Var
    Node: PExprNode;
  Begin
    Result := True;
    Node := Nodes;
    While Node <> nil Do
    Begin
      If (Node.FLeft = Root) or (Node.FRight = Root) Then
        Exit;
      Node := Node.FNext;
    End;
    Result := False;
  End;
  {$ENDIF}
Begin
  Inherited Create;
  FDataSet := ADataSet;
  If not FieldTypeMapInitialized Then
  Begin
    FieldTypeMapInitialized := True;
    For FieldType := Low(FieldType) To High(FieldType) Do
      FieldTypeMap[FieldType] := Ord(FieldType);
  End;
  {$IFNDEF FPC}
  FParser := TExprParser.Create(ADataSet, Filter, [], [poExtSyntax], '', nil, FieldTypeMap);
  Nodes := TFilterExprAccess(TExprParserAccess(FParser).FFilter).FNodes;
  { Find root node because FNodes is the last added node which must not be the root node.
    The root node is the node which istn't referenced by any other node's Left or Right field. }
  If Nodes <> nil Then
  Begin
    FRoot := Nodes;
    While (FRoot.FNext <> nil) and not ((FRoot.FKind = enOperator) and not NodesContainsLeftRight(FRoot)) Do
      FRoot := FRoot.FNext;
  End;
  {$ENDIF}
End;
Destructor TJvDBFilterExpression.Destroy;
Begin
  {$IFNDEF FPC}
  FParser.Free;
  {$ENDIF}
  Inherited Destroy;
End;

Function TJvDBFilterExpression.Evaluate: Boolean;
Begin
 Result := False;
 {$IFNDEF FPC}
  Result := EvalOpNode(FRoot);
 {$ENDIF}
End;

{$IFNDEF FPC}
Function TJvDBFilterExpression.EvaluateNode(N: PExprNode): Variant;
Begin
  If N = nil Then
    Result := Unassigned
  Else
  Begin
    Case N.FKind Of
      enOperator:
        Result := EvalOpNode(N);
      enConst:
        Result := N.FData;
      enField:
        Result := FDataSet.FieldByName(N.FData).AsVariant;
      enFunc:
        Result := EvalFuncNode(N);
    Else
      raise Exception.CreateRes(@RsInvalidFilterNodeKind);
    End;
  End;
End;
Function TJvDBFilterExpression.EvalOpNode(N: PExprNode): Boolean;
Var
  I: Integer;
  V: Variant;
Begin
  If N = nil Then
    Result := False
  Else
  Begin
    Assert(N.FKind = enOperator);
    Case N.FOperator Of
      coEQ:
        Result := EvaluateNode(N.FLeft) = EvaluateNode(N.FRight);
      coNE:
        Result := EvaluateNode(N.FLeft) <> EvaluateNode(N.FRight);
      coGT:
        Result := EvaluateNode(N.FLeft) > EvaluateNode(N.FRight);
      coLT:
        Result := EvaluateNode(N.FLeft) < EvaluateNode(N.FRight);
      coGE:
        Result := EvaluateNode(N.FLeft) >= EvaluateNode(N.FRight);
      coLE:
        Result := EvaluateNode(N.FLeft) <= EvaluateNode(N.FRight);
      coNOT:
        Result := not EvaluateNode(N.FLeft);
      coAND:
        Result := LongBool(EvaluateNode(N.FLeft)) and LongBool(EvaluateNode(N.FRight));
      coOR:
        Result := LongBool(EvaluateNode(N.FLeft)) or LongBool(EvaluateNode(N.FRight));
      coISBLANK:
        Result := VarIsNull(EvaluateNode(N.FLeft));
      coNOTBLANK:
        Result := not VarIsNull(EvaluateNode(N.FLeft));
      coLIKE:
        Result := IsLike(EvaluateNode(N.FLeft), EvaluateNode(N.FRight));
      coIN:
        Begin
          Result := False;
          V := EvaluateNode(N.FLeft);
          If N.FArgs <> nil Then
          Begin
            For I := 0 To N.FArgs.Count - 1 Do
            Begin
              If V = EvaluateNode(N.FArgs[I]) Then
              Begin
                Result := True;
                Break;
              End;
            End;
          End;
        End;
      coMINUS:
        Result := -EvaluateNode(N.FLeft);
      coADD:
        Result := EvaluateNode(N.FLeft) + EvaluateNode(N.FRight);
      coSUB:
        Result := EvaluateNode(N.FLeft) - EvaluateNode(N.FRight);
      coMUL:
        Result := EvaluateNode(N.FLeft) * EvaluateNode(N.FRight);
      coDIV:
        Result := EvaluateNode(N.FLeft) / EvaluateNode(N.FRight);
    Else
      raise Exception.CreateRes(@RsUnknownFilterOperation);
    End;
  End;
End;

Function TJvDBFilterExpression.EvalFuncNode(N: PExprNode): Variant;
Var
  V: Variant;
Begin
  If N = nil Then
    Result := Unassigned
  Else
  Begin
    If (N.FArgs <> nil) and (N.FArgs.Count > 0) Then
    Begin
      V := EvaluateNode(N.FArgs[0]);
      If CompareText(N.FData, 'UPPER') = 0 Then
        Result := AnsiUpperCase(V)
      Else
      If CompareText(N.FData, 'LOWER') = 0 Then
        Result := AnsiLowerCase(V)
      Else
      If CompareText(N.FData, 'TRIM') = 0 Then
      Begin
        If N.FArgs.Count = 1 Then
          Result := Trim(V)
        Else
          Result := TrimEx(V, EvaluateNode(N.FArgs[1]));
      End
      Else
      If CompareText(N.FData, 'TRIMLEFT') = 0 Then
      Begin
        If N.FArgs.Count = 1 Then
          Result := TrimLeft(V)
        Else
          Result := TrimLeftEx(V, EvaluateNode(N.FArgs[1]));
      End
      Else
      If CompareText(N.FData, 'TRIMRIGHT') = 0 Then
      Begin
        If N.FArgs.Count = 1 Then
          Result := TrimRight(V)
        Else
          Result := TrimRightEx(V, EvaluateNode(N.FArgs[1]));
      End
      Else
      If CompareText(N.FData, 'SUBSTRING') = 0 Then
      Begin
        If N.FArgs.Count = 2 Then
          Result := Copy(V, Integer(EvaluateNode(N.FArgs[1])), MaxInt)
        Else
          Result := Copy(V, Integer(EvaluateNode(N.FArgs[1])), Integer(EvaluateNode(N.FArgs[2])));
      End
      Else
      If CompareText(N.FData, 'YEAR') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := -1 Else
          Result := YearOf(V);
      End
      Else
      If CompareText(N.FData, 'MONTH') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := -1 Else
          Result := MonthOf(V);
      End
      Else
      If CompareText(N.FData, 'DAY') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := -1 Else
          Result := DayOf(V);
      End
      Else
      If CompareText(N.FData, 'HOUR') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := -1 Else
          Result := HourOf(V);
      End
      Else
      If CompareText(N.FData, 'MINUTE') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := -1 Else
          Result := MinuteOf(V);
      End
      Else
      If CompareText(N.FData, 'SECOND') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := -1 Else
          Result := SecondOf(V);
      End
      Else
      If CompareText(N.FData, 'TIME') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := NULL Else
          Result := VarSQLTimeStampCreate(TimeOf(V));
      End
      Else
      If CompareText(N.FData, 'DATE') = 0 Then
      Begin
        If VarIsNullEmpty(V) Then Result := NULL Else
          Result := VarSQLTimeStampCreate(DateOf(V));
      End
      Else
        raise Exception.CreateResFmt(@RsUnknownFilterFunction, [N.FData]);
    End
    Else
      raise Exception.CreateResFmt(@RsMissingFilterFunctionParameters, [N.FData]);
  End;
End;
{$ENDIF}
End.
