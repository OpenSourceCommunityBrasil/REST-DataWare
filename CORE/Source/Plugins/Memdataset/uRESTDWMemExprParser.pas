Unit uRESTDWMemExprParser;

{$I uRESTDW.inc}

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
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

Uses
  SysUtils, Classes;

Type
  TObjectList = Class(TList);
  TOnGetVariableValue = Function(Sender: TObject; Const VarName: string;
    Var Value: Variant): Boolean Of object;

  TOnExecuteFunction = Function(Sender: TObject; Const FuncName: string;
    Const Args: Variant; Var ResVal: Variant): Boolean Of object;

  TExprParser = Class
  Private
    FValue: Variant;
    FParser: TObject; // TParser
    FScan: TObject; // TScan
    FExpression: string;
    FOnGetVariable: TOnGetVariableValue;
    FOnExecuteFunction: TOnExecuteFunction;
    FEnableWildcardMatching: Boolean;
    FErrorMessage: string;
    FCaseInsensitive: Boolean;
    Procedure SetExpression(Const Value: string);
    Function DoGetVariable(Const VarName: string; Var Value: Variant): Boolean;
    Function DoExecuteFunction(Const FuncName: string; Const Args: Variant; Var ResVal: Variant): Boolean;
    Procedure SetCaseInsensitive(Const Value: Boolean);
    Function ConvertDoubleOperators(Value : String) : String;
  Public
    Constructor Create();
    Destructor Destroy; override;
    Function Eval: Boolean; overload;
    Function Eval(Const AExpression: string): Boolean; overload;
    property ErrorMessage: string read FErrorMessage;
  {published} // ahuser: not a TPersistent derived class
    property Expression: string read FExpression write SetExpression;
    property OnGetVariable: TOnGetVariableValue read FOnGetVariable write FOnGetVariable;
    property OnExecuteFunction: TOnExecuteFunction read FOnExecuteFunction write FOnExecuteFunction;
    property Value: Variant read FValue;
    property EnableWildcardMatching: Boolean read FEnableWildcardMatching write FEnableWildcardMatching;
    property CaseInsensitive: Boolean read FCaseInsensitive write SetCaseInsensitive;
  End;

  EExprParserError = Class(Exception);

{$IFDEF TESTING_PARSER}
Var
  DebugText: string;
{$ENDIF TESTING_PARSER}
Implementation

Uses
  Variants{$IFNDEF FPC}, Masks{$ENDIF};
{$IFDEF COMPILER12_UP}
  // Our charsets do not contain any char > 127 what makes it safe because the
  // compiler generates correct code.
  {$WARN WIDECHAR_REDUCED OFF}
{$ENDIF COMPILER12_UP}

Const
  cNumbers = ['0'..'9'];
  cLetters = ['a'..'z', 'A'..'Z', '_'];
  cLettersAndNumbers = cLetters + cNumbers;
  cOperators = [
    '+',
    '-',
    '/',
    '*',
    '=',
    '<',
    '@', // <=
    '>',
    '#', // <>
    '&',
    '|',
    '!',
    '~'];

Type
  TToken = (tkNA, tkEOF, tkError,
    tkLParen, tkRParen, tkComa,
    tkOperator, tkIdentifier,
    tkNumber, tkInteger, tkString);

  TLex = Class
  Private
    FToken: TToken;
    FChr: Char;
    FStr: string;
    FPos: Integer;
  Public
    Constructor Create(AToken: TToken; APos: Integer); overload;
    Constructor Create(AToken: TToken; Const AStr: string; APos: Integer); overload;
    Constructor Create(AToken: TToken; AChr: Char; APos: Integer); overload;
    Function Debug(): string;
    property Token: TToken read FToken;
    property Chr: Char read FChr;
    property Str: string read FStr;
    property Pos: Integer read FPos;
  End;

  TScan = Class(TObjectList)
  Private
    FErrorMessage: string;
    Function GetItem(Index: Integer): TLex;
  Public
    Constructor Create();
    property Items[Index: Integer]: TLex read GetItem; default;
    Function Parse(Const Str: string): Boolean;
    {$IFDEF TESTING_PARSER}
    Procedure DebugPrint();
    {$ENDIF TESTING_PARSER}
    property ErrorMessage: string read FErrorMessage;
  End;

  TParser = Class;
  TNode = Class
  Private
    FParser: TParser;
  Public
    Constructor Create(Parser: TParser); virtual;
    // Delphi 5 compiler shows hints about a not exported or used symbol
    // TNode.Eval. This is a compiler bug that is caused by the "abstract" keyword.
    Function Eval(): Variant; virtual; abstract;
  End;

  EParserError = Class(EExprParserError)
  Public
    Constructor Create(Const Msg: string; Lex: TLex); overload;
  End;

  TNodeCValue = Class(TNode)
  Private
    FCValue: TLex;
  Public
    Constructor Create(AParser: TParser; ACValue: TLex); reintroduce;
    Function Eval(): Variant; override;
  End;

  TNodeVariable = Class(TNode)
  Private
    FLex: TLex;
  Public
    Constructor Create(AParser: TParser; ALex: TLex); reintroduce;
    Function Eval(): Variant; override;
  End;

  TNodeUnary = Class(TNode)
  Private
    FOperator: TLex;
    FRightNode: TNode;
  Public
    Constructor Create(AParser: TParser; AOperator: TLex; ARightNode: TNode); reintroduce;
    Destructor Destroy; override;
    Function Eval(): Variant; override;
  End;

  TNodeBin = Class(TNode)
  Private
    FOperator: TLex;
    FLeftNode, FRightNode: TNode;
  Public
    Constructor Create(AParser: TParser; AOperator: TLex; ALeftNode, ARightNode: TNode); reintroduce;
    Destructor Destroy; override;
    Function Eval(): Variant; override;
  End;

  TNodeFunction = Class(TNode)
  Private
    FFunc: TLex;
    FArgs: TObjectList;
  Public
    Constructor Create(AParser: TParser; AFunc: TLex); reintroduce;
    Destructor Destroy; override;
    Procedure AddArg(Node: TNode);
    Function Eval(): Variant; override;
  End;

  TParser = Class
  Private
    FParent: TExprParser;
    FScan: TScan;
    FScanIdx: Integer;
    FRoot: TNode;
    FErrorMessage: string;
    FValue: Variant;
  Public
    Destructor Destroy; override;
    Function Parse(): Boolean;
    Function Execute(): Boolean;
    Function Expr(): TNode;
    Function Term(): TNode;
    Function Factor(): TNode;
    Function LexC(): TLex;
    Function LexLook(LookAhead: Integer = 1): TLex;
    Procedure LexAccept();
    property Parent: TExprParser read FParent write FParent;
    property Value: Variant read FValue;
    property ErrorMessage: string read FErrorMessage;
    property Scan: TScan read FScan write FScan;
  End;
Var
  ELexEOF: TLex; // ahuser: what the...
{$IFDEF TESTING_PARSER}
Procedure DebugMessage(Const msg: string);
Begin
  DebugText := DebugText + msg + sLineBreak;
End;
{$ENDIF TESTING_PARSER}
{ TLex }
Constructor TLex.Create(AToken: TToken; APos: Integer);
Begin
  FToken := AToken;
  FPos := APos;
End;
Constructor TLex.Create(AToken: TToken; Const AStr: string; APos: Integer);
Begin
  Inherited Create;
  FToken := AToken;
  FStr := AStr;
  FPos := APos;
End;
Constructor TLex.Create(AToken: TToken; AChr: Char; APos: Integer);
Begin
  FToken := AToken;
  FChr := Char(AChr);
  FPos := APos;
End;
Function TLex.debug: string;
Const
  TokenStr: array[TToken] Of string =
    ('N/A', 'End of expression', 'Error',
    '(', ')', ',',
    'Operator', 'Identifier',
    'Number', 'Integer', 'String');
Begin
  Result := TokenStr[Token];
  Case Token Of
    tkOperator:
      Result := Result + ': ' + Chr;
    tkIdentifier, tkNumber, tkInteger, tkString:
      Result := Result + ': ' + Str;
  End;
  Result := Result + ' at pos: ' + IntToStr(Pos);
End;
{ TScan }
Constructor TScan.Create;
Begin
  Inherited Create;
  FErrorMessage := '';
End;
Function TScan.GetItem(Index: Integer): TLex;
Begin
  Result := TLex(Inherited Items[Index]);
End;
Function TScan.Parse(Const Str: string): Boolean;
Var
  Idx, StartIdx, Len: Integer;
  C: Char;
  S: string;
  CToken: TToken;
Begin
  Len := Length(Str);
  Idx := 1;
  S := '';
  CToken := tkNA;
  While Idx <= Len Do
  Begin
    C := Str[Idx];
    StartIdx := Idx;
    Inc(Idx);
    CToken := tkNA;
    Case C Of
      '(': CToken := tkLParen;
      ')': CToken := tkRParen;
      ',': CToken := tkComa;
      ' ', #09: ;
    Else
      If C in cOperators Then
        CToken := tkOperator
      Else
        If (C = '"') or (C = '''') Then
        Begin
          CToken := tkString;
          While (Idx <= Len) and (Str[Idx] <> C) Do
          Begin
            S := S + Str[Idx]; // ahuser: performance suicide
            Inc(Idx);
          End;
          If (Idx <= Len) and (Str[Idx] = C) Then
            Inc(Idx)
          Else
          Begin
            CToken := tkError;
            FErrorMessage := 'No end of string found';
          End
        End
        Else
        If C in cNumbers Then
        Begin
          CToken := tkInteger;
          S := S + C;
          While (Idx <= Len) and (Str[Idx] in cNumbers) Do
          Begin
            S := S + Str[Idx]; // ahuser: performance suicide
            Inc(Idx);
          End;
          If ((Idx <= Len) and (Str[Idx] = '.')) Then
          Begin
            CToken := tkNumber;
            Inc(Idx);
            S := S + '.';
            While (Idx <= Len) and (Str[Idx] in cNumbers) Do
            Begin
              S := S + Str[Idx]; // ahuser: performance suicide
              Inc(Idx);
            End;
          End;
        End
        Else
        If C = '.' Then         // .55
        Begin
          CToken := tkNumber;
          S := S + C;
          While (Idx <= Len) and (Str[Idx] in cNumbers) Do
          Begin
            S := S + Str[Idx]; // ahuser: performance suicide
            Inc(Idx);
          End;
        End
        Else
        If C in cLetters Then
        Begin
          CToken := tkIdentifier;
          S := S + C;
          While (Idx <= Len) and (Str[Idx] in cLettersAndNumbers) Do
          Begin
            S := S + Str[Idx]; // ahuser: performance suicide
            Inc(Idx);
          End;
        End
        Else
        Begin
          CToken := tkError;
          FErrorMessage := Format('Bad character ''%s''', [string(C)]);
        End;
    End;
    Case CToken Of
      tkError: break;
      tkNA: ;                           // continue
      tkOperator: Add(TLex.Create(tkOperator, C, StartIdx));
      tkIdentifier,
        tkNumber,
        tkInteger,
        tkString:
        Begin
          If CompareText(S, 'and') = 0 Then
            Add(TLex.Create(tkOperator, '&', StartIdx))
          Else
            If CompareText(S, 'or') = 0 Then
              Add(TLex.Create(tkOperator, '|', StartIdx))
            Else
            Begin
              If CompareText(S, 'like')=0 Then
                Add(TLex.Create(tkOperator, '~', StartIdx))
              Else
                Add(TLex.Create(CToken, S, StartIdx));
            End;
          S := '';
        End
      Else
        Add(TLex.Create(CToken, StartIdx));
    End;
  End;
  Result := CToken <> tkError;
  ELexEOF := TLex.Create(tkEOF, Idx);
  Add(ELexEOF);
End;
{$IFDEF TESTING_PARSER}
Procedure TScan.DebugPrint;
Var
  I: Integer;
Begin
  For I := 0 To Count - 1 Do
    DebugMessage(Items[I].Debug);
End;
{$ENDIF TESTING_PARSER}
{ TParser }
Destructor TParser.Destroy;
Begin
  FRoot.Free;
  Inherited Destroy;
End;
Function TParser.Parse: Boolean;
Begin
  FreeAndNil(FRoot);
  Try
    FRoot := Expr();
    If FScanIdx < FScan.Count - 1 Then
    Begin
      FreeAndNil(FRoot);
      raise EParserError.Create('Unexpected ', LexC());
    End;
  Except
    on E: Exception Do
      FErrorMessage := E.Message;
  End;
  Result := FRoot <> nil;
End;
Function TParser.Execute: Boolean;
Begin
  Result := False;
  If FRoot <> nil Then
  Begin
    Try
      FValue := FRoot.Eval();
      Result := True;
    Except
      on E: Exception Do
      Begin
        FErrorMessage := E.Message;
//        raise;
      End;
    End;
  End;
End;
Procedure TParser.LexAccept;
Begin
  Inc(FScanIdx);
End;
Function TParser.LexC: TLex;
Begin
  Result := LexLook(0);
End;
Function TParser.LexLook(LookAhead: Integer): TLex;
Begin
  If (FScanIdx + LookAhead) < FScan.Count Then
    Result := FScan[FScanIdx + LookAhead]
  Else
    Result := ELexEOF;
End;
Function TParser.Expr: TNode;
Var
  CNode, RightNode: TNode;
  Lex: TLex;
Begin
  CNode := nil;
  Try
    CNode := Term();
    Lex := LexC();
    If Lex.Token = tkOperator Then
    Begin
      If Lex.Chr in ['+', '-'] Then
      Begin
        LexAccept();
        RightNode := Expr();
        If RightNode = nil Then
          raise EParserError.Create('Expression expected after', Lex);
        CNode := TNodeBin.Create(Self, Lex, CNode, RightNode);
      End;
    End;
  Except
    on E: Exception Do
    Begin
      FreeAndNil(CNode);
      If E is EParserError Then
        raise
      Else
        raise EParserError.Create(E.Message);
    End;
  End;
  Result := CNode;
End;
Function TParser.Term: TNode;
Var
  CNode, RightNode: TNode;
  Lex: TLex;
Begin
  CNode := nil;
  Try
    CNode := Factor();
    Lex := LexC();
    If Lex.Token = tkOperator Then
    Begin
      If Lex.chr in ['*', '/', '=', '&', '|', '<', '>', '~',
                     {$IFNDEF FPC}{$IFDEF DELPHI2010UP}'�',{$ENDIF}{$ENDIF}'@', '#'] Then
      Begin
        LexAccept();
        RightNode := Expr();
        If RightNode = nil Then
          raise EParserError.Create('Expression expected after', Lex);
        CNode := TNodeBin.Create(Self, Lex, CNode, RightNode);
      End;
    End;
  Except
    on E: Exception Do
    Begin
      FreeAndNil(CNode);
      If E is EParserError Then
        raise
      Else
        raise EParserError.Create(E.Message);
    End;
  End;
  Result := CNode;
End;
Function TParser.Factor: TNode;
Var
  CNode: TNode;
  fNode: TNodeFunction;
  Lex: TLex;
Begin
  CNode := nil;
  Try
    Lex := LexC();
    Case Lex.token Of
      tkLParen:
        Begin
          LexAccept();
          CNode := Expr();
          If (LexC().Token = tkRParen) Then
            LexAccept()
          Else
            raise EParserError.Create('Expected closing parenthesis instead of', LexC());
        End;
      tkOperator:                       // unary minus
        Begin
          If Lex.Chr in ['+', '-', '!'] Then
          Begin
            LexAccept();
            CNode := TNodeUnary.Create(Self, Lex, Factor());
          End
          Else
            raise EParserError.Create('Unexpected ', Lex);
        End;
      tkNumber, tkInteger, tkString:
        Begin
          CNode := TNodeCValue.Create(Self, Lex);
          LexAccept();
        End;
      tkIdentifier:
        Begin
          If LexLook().Token = tkLParen Then
          Begin
            // function call
            LexAccept();
            fNode := TNodeFunction.Create(Self, Lex);
            LexAccept();
            CNode := fNode;
            If (LexC().token <> tkRParen) Then
            Begin
              fNode.AddArg(Expr());
              While LexC().Token = tkComa Do
              Begin
                LexAccept();
                fNode.AddArg(Expr());
              End;
            End;
            If (LexC().token = tkRParen) Then
              LexAccept()
            Else
              raise EParserError.Create('Expected closing parenthesis instead of', LexC());
          End
          Else
          Begin
            CNode := TNodeVariable.Create(Self, Lex);
            LexAccept();
          End;
        End;
      Else
        raise EParserError.Create('Unexpected ', Lex);
    End;
  Except
    on E: Exception Do
    Begin
      FreeAndNil(CNode);
      If E is EParserError Then
        raise
      Else
        raise EParserError.Create(E.Message);
    End;
  End;
  Result := CNode;
End;
{ TNode }
Constructor TNode.Create(Parser: TParser);
Begin
  Inherited Create;
  FParser := Parser;
End;
{ TNodeBin }
Constructor TNodeBin.Create(AParser: TParser; AOperator: TLex; ALeftNode, ARightNode: TNode);
Begin
  Inherited Create(AParser);
  FOperator := AOperator;
  FLeftNode := ALeftNode;
  FRightNode := ARightNode;
End;
Destructor TNodeBin.Destroy;
Begin
  FLeftNode.Free;
  FRightNode.Free;
  Inherited Destroy;
End;
Function TNodeBin.Eval: Variant;
Var
  LeftValue, RightValue: Variant;
  Function FixupBoolean(Var AVal1: Variant; Var AVal2: Variant): Boolean;
  Begin
    Result := (TVarData(AVal1).VType = varBoolean) or (TVarData(AVal2).VType = varBoolean);
    If Result Then
    Begin
      If UpperCase(AVal1) = 'TRUE' Then
        AVal1 := 1
      Else
        AVal1 := 0;
      If UpperCase(AVal2) = 'TRUE' Then
        AVal2 := 1
      Else
        AVal2 := 0;
    End;
  End;
  Function FixupDateTime(Var AVal1: Variant; Var AVal2: Variant): Boolean;
  Begin
    Result := TVarData(AVal1).VType = varDate;
    If Result Then
    Begin
      If TVarData(AVal2).VType = varString Then
        AVal2 := StrToDateTime(AVal2); //convert;
    End;
  End;
  Function FixupString(Var aVal: Variant): Boolean;
  Begin
    Result:=((TVarData(aVal).VType = varString) {$IFDEF UNICODE}or (TVarData(aVal).VType = varUString){$ENDIF UNICODE}) and FParser.Parent.FCaseInsensitive;
    If Result Then
      aVal := AnsiUpperCase(aVal);
  End;
  //returns 'True' if a conversion was necessary.
  Function FixupValues(Var AVal1: Variant; Var AVal2: Variant): Boolean;
  Var
    bChanged: Boolean;
  Begin
    Result := FixupDateTime(AVal1, AVal2);
    If not Result Then
      Result := FixupDateTime(AVal2, AVal1);
    If not Result Then
      Result := FixupBoolean(AVal1, AVal2);
    If not Result Then //ensure that the 'String' case is the last one
    Begin
      Result := FixupString(AVal1);
      bChanged := FixupString(AVal2);
      Result := Result or bChanged; //ensure that both Fixups are executed regardless of optimisations
    End;
  End;
  Function EvalLike: Boolean;
  Var
    Wildcard1, Wildcard2: Boolean;
    LeftStr, RightStr: string;
  Begin
    If (LeftValue = Null) or (RightValue = Null) Then
      Result := (LeftValue = Null) and (RightValue = Null)
    Else
    Begin
      // Possiblilities:
      // Left hand contains wildcards -> Match right hand against left hand.
      // Right hand contains wildcards -> Match left hand against right hand.
      // Both hands contain wildcards -> Match for string equality as if no wildcards are supported.
      LeftStr := LeftValue;
      RightStr := RightValue;
      Wildcard1 := (Pos('*', LeftStr) > 0) or (Pos('?', LeftStr) > 0);
      Wildcard2 := (Pos('*', RightStr) > 0) or (Pos('?', RightStr) > 0);
      {$IFNDEF FPC}
      If Wildcard1 and not Wildcard2 Then
        Result := MatchesMask(RightStr, LeftStr)
      Else
      If Wildcard2 Then
        Result := MatchesMask(LeftStr, RightStr)
      Else
      {$ENDIF}
        Result := LeftValue = RightValue;
    End;
  End;
  Function EvalEquality: Boolean;
  Begin
    // Special case, at least one of both is null:
    If (LeftValue = Null) or (RightValue = Null) Then
      Result := (LeftValue = Null) and (RightValue = Null)
    Else
    Begin
      If FParser.Parent.FEnableWildcardMatching and (TVarData(LeftValue).VType<>varDate) Then
      Begin
        Result := EvalLike;
      End
      Else
        Result := LeftValue = RightValue;
    End;
  End;
  Function EvalLT: Boolean;
  Begin
    // Special case, at least one of both is Null:
    If (LeftValue = Null) or (RightValue = Null) Then
      // Null is considered to be smaller than any value.
      Result := LeftValue = Null
    Else
      Result := LeftValue < RightValue;
  End;
  Function EvalGT: Boolean;
  Begin
    // Special case, at least one of both is Null:
    If (LeftValue = Null) or (RightValue = Null) Then
      // Null is considered to be smaller than any value.
      Result := RightValue = Null
    Else
      Result := LeftValue > RightValue;
  End;
  Function EvalLTE: Boolean;
  Begin
    // Special case, at least one of both is Null:
    If (LeftValue = Null) or (RightValue = Null) Then
      // Null is considered to be smaller than any value.
      Result := LeftValue = Null
    Else
      Result := LeftValue <= RightValue;
  End;
  Function EvalGTE: Boolean;
  Begin
    // Special case, at least one of both is Null:
    If (LeftValue = Null) or (RightValue = Null) Then
      // Null is considered to be smaller than any value.
      Result := RightValue = Null
    Else
      Result := LeftValue >= RightValue;
  End;
Var
  LeftStr, RightStr: string;
Begin
  // Determine values to have them handy.
  LeftValue := FLeftNode.Eval;
  RightValue := FRightNode.Eval;
  FixupValues(LeftValue, RightValue);
  Case FOperator.Chr Of
    '+':
      Begin
        // force string concatenation
        If (TVarData(LeftValue).VType = varString) or
          (TVarData(LeftValue).VType = varOleStr) Then
        Begin
          LeftStr := LeftValue;
          RightStr := RightValue;
          LeftStr := LeftStr + RightStr;
          Result := LeftStr;
        End
        Else
          Result := LeftValue + RightValue;
      End;
    '-': Result := LeftValue - RightValue;
    '*': Result := FLeftNode.Eval * FRightNode.Eval;
    '/': Result := FLeftNode.Eval / FRightNode.Eval;
    '=': Result := EvalEquality();
    '<': Result := EvalLT();
    '>': Result := EvalGT();
    '&': Result := FLeftNode.Eval and FRightNode.Eval;
    '|': Result := FLeftNode.Eval or FRightNode.Eval;
    '~': Result := EvalLike;
    {$IFNDEF FPC}
     {$IFDEF DELPHI2010UP}
      '�': Result := EvalGTE();
     {$ENDIF}
    {$ENDIF}
    '@': Result := EvalLTE();
    '#': Result := not EvalEquality();
  Else
    Result := Null;
  End;
End;
{ TNodeUnary }
Constructor TNodeUnary.Create(AParser: TParser; AOperator: TLex; ARightNode: TNode);
Begin
  Inherited Create(AParser);
  FOperator := AOperator;
  FRightNode := ARightNode;
End;
Destructor TNodeUnary.Destroy;
Begin
  FRightNode.Free;
  Inherited Destroy;
End;
Function TNodeUnary.Eval: Variant;
Begin
  Result := FRightNode.Eval();
  If FOperator.Chr = '-' Then
    Result := -Result;
  If FOperator.Chr = '!' Then
    Result := not Result;
End;
{ TNodeCValue }
Constructor TNodeCValue.Create(AParser: TParser; ACValue: TLex);
Begin
  Inherited Create(AParser);
  FCValue := ACValue;
End;
Function TNodeCValue.Eval: Variant;
Begin
  Case FCValue.Token Of
    tkNumber:
      Result := StrToFloat(FCValue.Str);
    tkInteger:
      Result := StrToInt(FCValue.Str);
    tkString:
      Result := FCValue.Str;
  Else
    Result := Null;
  End;
End;
{ TNodeFunction }
Constructor TNodeFunction.Create(AParser: TParser; AFunc: TLex);
Begin
  Inherited Create(AParser);
  FArgs := TObjectList.Create;
  FFunc := AFunc;
End;
Destructor TNodeFunction.Destroy;
Begin
  FArgs.Free;
  Inherited Destroy;
End;
Procedure TNodeFunction.AddArg(Node: TNode);
Begin
  FArgs.Add(Node);
End;
Function TNodeFunction.Eval: Variant;
Var
  Value: Variant;
  VArgs: Variant;
  I: Integer;
Begin
  VArgs := VarArrayCreate([0, FArgs.Count - 1], varVariant);
  For I := 0 To FArgs.Count - 1 Do
    VArgs[I] := TNode(FArgs[I]).Eval();
  Value := Null;
  If FParser.Parent.DoExecuteFunction(FFunc.Str, VArgs, Value) Then
    Result := Value
  Else
    raise EParserError.CreateFmt('Function %s could not be executed.', [FFunc.Str]);
End;
{ TNodeVariable }
Constructor TNodeVariable.Create(AParser: TParser; ALex: TLex);
Begin
  Inherited Create(AParser);
  FLex := ALex;
End;
Function TNodeVariable.Eval: Variant;
Var
  Value: Variant;
Begin
  Value := Null;
  If FParser.Parent.DoGetVariable(FLex.Str, Value) Then
    Result := Value
  Else
    raise EParserError.Create('Variable ' + FLex.Str + ' could not be fetched.');
End;
{ EParserError }
Constructor EParserError.Create(Const Msg: string; Lex: TLex);
Begin
  Inherited CreateFmt('%s %s', [Msg, Lex.Debug]);
End;
{ TExprParser }

Function TExprParser.ConvertDoubleOperators(Value: String): String;
Var
  i : integer;
  bEscapeDoubleQuote,
  bEscapeQuote : Boolean;
  sOperator : string;
Begin
  Result := '';
  bEscapeDoubleQuote := False;
  bEscapeQuote := False;
  i := 1;
  While i <= Length(Value) Do Begin
    If (Value[i] = '"') and (not bEscapeQuote) Then Begin
      bEscapeDoubleQuote := not bEscapeDoubleQuote;
      Result := Result + Value[i];
    End
    Else If (Value[i] = '''') and (not bEscapeDoubleQuote) Then Begin
      bEscapeQuote := not bEscapeQuote;
      Result := Result + Value[i];
    End
    Else If (Value[i] in cOperators) and (not bEscapeQuote) and (not bEscapeDoubleQuote) Then Begin
      sOperator := sOperator + Value[i];
    End
    Else Begin
      If sOperator <> '' Then Begin
        sOperator := StringReplace(sOperator,'>=','�',[rfReplaceAll]);
        sOperator := StringReplace(sOperator,'<=','@',[rfReplaceAll]);
        sOperator := StringReplace(sOperator,'<>','#',[rfReplaceAll]);
        sOperator := StringReplace(sOperator,'!=','#',[rfReplaceAll]);
        Result := Result + sOperator;
        sOperator := '';
      End;
      Result := Result + Value[i];
    End;

    i := i + 1;
  End;
End;

Constructor TExprParser.Create;
Begin
  Inherited Create;
  FErrorMessage := '';
End;
Destructor TExprParser.Destroy;
Begin
  FParser.Free;
  FScan.Free;
  Inherited Destroy;
End;
Function TExprParser.Eval(): Boolean;
Var
  Parser: TParser;
  {$IFDEF TESTING_PARSER}
  Scan: TScan;
  {$ENDIF TESTING_PARSER}
Begin
  FErrorMessage := '';
  {$IFDEF TESTING_PARSER}
  DebugText := '';
  Scan := TScan(FScan);
  Scan.DebugPrint();
  {$ENDIF TESTING_PARSER}
  Parser := TParser(FParser);
  If Parser.Execute() Then
  Begin
    FValue := Parser.Value;
    Result := True;
  End
  Else
  Begin
    FErrorMessage := Parser.ErrorMessage;
    Result := False;
  End
End;
Function TExprParser.Eval(Const AExpression: string): Boolean;
Begin
  SetExpression(AExpression);
  Result := Eval();
End;
Procedure TExprParser.SetCaseInsensitive(Const Value: Boolean);
Begin
  FCaseInsensitive := Value;
End;
Procedure TExprParser.SetExpression(Const Value: string);
Var
  nValue : string;
Begin
  nValue := ConvertDoubleOperators(Value);
  If nValue <> FExpression Then
  Begin
    FExpression := nValue;
    FParser.Free;
    FScan.Free;
    FParser := TParser.Create;
    TParser(FParser).Parent := Self;
    FScan := TScan.Create;
    If not TScan(FScan).Parse(FExpression) Then
      FErrorMessage := TScan(FScan).ErrorMessage
    Else
    Begin
      TParser(FParser).Scan := TScan(FScan);
      TParser(FParser).Parse();
    End;
  End;
End;
Function TExprParser.DoGetVariable(Const VarName: string; Var Value: Variant): Boolean;
Begin
  Result := False;
  If Assigned(FOnGetVariable) Then
    Result := FOnGetVariable(Self, VarName, Value);
End;
Function TExprParser.DoExecuteFunction(Const FuncName: string; Const Args: Variant; Var ResVal: Variant): Boolean;
Begin
  Result := False;
  If Assigned(FOnExecuteFunction) Then
    Result := FOnExecuteFunction(Self, FuncName, Args, ResVal);
End;
End.
