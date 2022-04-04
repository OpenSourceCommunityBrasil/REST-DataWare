unit uRESTDWHeaderList;

{$I ..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
 Classes, uRESTDWBasicTypes;


 Type
  TRESTDWHeaderList = class(TStringList)
 Protected
  FNameValueSeparator : String;
  FUnfoldLines,
  FFoldLines          : Boolean;
  FFoldLinesLength    : Integer;
  FQuoteType: TRESTDWHeaderQuotingType;
  Procedure AssignTo         (Dest        : TPersistent);Override;
  Procedure DeleteFoldedLines(Index       : Integer);
  Function  FoldLine         (AString     : String): TStrings; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use FoldLineToList()'{$ENDIF};{$ENDIF}
  Procedure FoldLineToList   (AString     : String;
                              ALines      : TStrings);
  Procedure FoldAndInsert    (AString     : String;
                              Index       : Integer);
  Function  GetName          (Index       : Integer) : String;
  Function  GetValue         (Const AName : String)  : String;
  Function  GetParam         (Const AName,
                              AParam      : String)  : String;
  Function  GetAllParams     (Const AName : String)  : String;
  Procedure SetValue         (Const AName,
                              AValue      : String);
  Procedure SetParam         (Const AName,
                              AParam,
                              AValue      : String);
  Procedure SetAllParams     (Const AName,
                              AValue      : String);
  Function  GetValueFromLine (Var VLine   : Integer) : String;
  procedure SkipValueAtLine  (Var VLine   : Integer);
 Public
  Procedure AddStrings       (Strings     : TStrings); Override;
  Procedure AddStdValues     (ASrc        : TStrings);
  Procedure AddValue         (Const AName,
                              AValue       : String);
  Procedure ConvertToStdValues(ADest       : TStrings);
  Constructor Create          (AQuoteType  : TRESTDWHeaderQuotingType);
  Procedure   Extract         (Const AName : String;
                               ADest       : TStrings);
  Function    IndexOfName     (const AName : String) : Integer; Reintroduce;
  Property    Names [Index : Integer]           : String Read GetName;
  Property    Values[Const Name : String]       : String Read GetValue            Write SetValue;
  Property    Params[Const Name, Param: String] : String Read GetParam            Write SetParam;
  Property    AllParams[Const Name : String]    : String Read GetAllParams        Write SetAllParams;
  Property    NameValueSeparator   : String              Read FNameValueSeparator Write FNameValueSeparator;
  Property    UnfoldLines          : Boolean             Read FUnfoldLines        Write FUnfoldLines;
  Property    FoldLines            : Boolean             Read FFoldLines          Write FFoldLines;
  Property    FoldLength           : Integer             Read FFoldLinesLength    Write FFoldLinesLength;
 End;

Implementation

Uses
  uRESTDWException,
  SysUtils,
  uRESTDWTools;

Procedure TRESTDWHeaderList.AddStdValues(ASrc: TStrings);
Var
 I : integer;
Begin
 BeginUpdate;
 Try
  For I := 0 To ASrc.Count - 1 Do
   AddValue(ASrc.Names[i], restdwValueFromIndex(ASrc, i));
  Finally
   EndUpdate;
  End;
End;

procedure TRESTDWHeaderList.AddValue(const AName, AValue: string);
var
  I: Integer;
begin
  if (AName <> '') and (AValue <> '') then begin  {Do not Localize}
    I := Add('');    {Do not Localize}
    if FFoldLines then begin
      FoldAndInsert(AName + FNameValueSeparator + AValue, I);
    end else begin
      Put(I, AName + FNameValueSeparator + AValue);
    end;
  end;
end;

procedure TRESTDWHeaderList.AddStrings(Strings: TStrings);
begin
  if Strings is TRESTDWHeaderList then begin
    inherited AddStrings(Strings);
  end else begin
    AddStdValues(Strings);
  end;
end;

procedure TRESTDWHeaderList.AssignTo(Dest: TPersistent);
begin
  if (Dest is TStrings) and not (Dest is TRESTDWHeaderList) then begin
    ConvertToStdValues(TStrings(Dest));
  end else begin
    inherited AssignTo(Dest);
  end;
end;

procedure TRESTDWHeaderList.ConvertToStdValues(ADest: TStrings);
var
  idx: Integer;
  LName, LValue: string;
begin
  ADest.BeginUpdate;
  try
    idx := 0;
    while idx < Count do
    begin
      LName := GetName(idx);
      LValue := GetValueFromLine(idx);
                                                                        
      ADest.Add(LName + '=' + LValue); {do not localize}
    end;
  finally
    ADest.EndUpdate;
  end;
end;

constructor TRESTDWHeaderList.Create(AQuoteType: TRESTDWHeaderQuotingType);
begin
  inherited Create;
  FNameValueSeparator := ': ';    {Do not Localize}
  FUnfoldLines := True;
  FFoldLines := True;
  { 78 was specified by a message draft available at
    http://www.imc.org/draft-ietf-drums-msg-fmt }
  // HTTP does not technically have a limitation on line lengths
  FFoldLinesLength := iif(AQuoteType = QuoteHTTP, MaxInt, 78);
  FQuoteType := AQuoteType;
end;

procedure TRESTDWHeaderList.DeleteFoldedLines(Index: Integer);
begin
  Inc(Index);  {skip the current line}
  if Index < Count then begin
    while (Index < Count) and CharIsInSet(Get(Index), 1, LWS) do begin {Do not Localize}
      Delete(Index);
    end;
  end;
end;

procedure TRESTDWHeaderList.Extract(const AName: string; ADest: TStrings);
var
  idx : Integer;
begin
  if Assigned(ADest) then begin
    ADest.BeginUpdate;
    try
      idx := 0;
      while idx < Count do
      begin
        if TextIsSame(AName, GetName(idx)) then begin
          ADest.Add(GetValueFromLine(idx));
        end else begin
          SkipValueAtLine(idx);
        end;
      end;
    finally
      ADest.EndUpdate;
    end;
  end;
end;

procedure TRESTDWHeaderList.FoldAndInsert(AString : String; Index: Integer);
var
  LStrs : TStrings;
  idx : Integer;
begin
  LStrs := TStringList.Create;
  try
    FoldLineToList(AString, LStrs);
    idx := LStrs.Count - 1;
    Put(Index, LStrs[idx]);
    {We decrement by one because we put the last string into the HeaderList}
    Dec(idx);
    while idx > -1 do
    begin
      Insert(Index, LStrs[idx]);
      Dec(idx);
    end;
  finally
    FreeAndNil(LStrs);
  end;  //finally
end;

Function TRESTDWHeaderList.FoldLine(AString : String) : TStrings;
Begin
 Result := TStringList.Create;
 Try
  FoldLineToList(AString, Result);
 Except
  FreeAndNil(Result);
  Raise;
 End;
End;

Procedure TRESTDWHeaderList.FoldLineToList(AString : string; ALines: TStrings);
Var
 s : String;
Begin
 s := WrapText(AString, EOL+' ', LWS+',', FFoldLinesLength);    {Do not Localize}
  if s <> '' then begin
    ALines.BeginUpdate;
    try
      repeat
        ALines.Add(TrimRight(Fetch(s, EOL)));
      until s = '';  {Do not Localize};
    finally
      ALines.EndUpdate;
    end;
  end;
end;

Function TRESTDWHeaderList.GetName(Index: Integer) : String;
Var
 I : Integer;
Begin
 Result := Get(Index);
 I := InternalAnsiPos(TrimRight(FNameValueSeparator), Result);
 If I <> 0 Then
  SetLength(Result, I - 1)
 Else
  SetLength(Result, 0);
End;

Function TRESTDWHeaderList.GetValue(Const AName : String) : String;
Var
 idx : Integer;
Begin
 idx    := IndexOfName(AName);
 Result := GetValueFromLine(idx);
End;

Function TRESTDWHeaderList.GetValueFromLine(Var VLine : Integer) : String;
Var
 LLine,
 LSep   : string;
 P      : Integer;
Begin
 If (VLine >= 0)    And
    (VLine < Count) Then
  Begin
   LLine  := Get(VLine);
   Inc(VLine);
   LSep   := TrimRight(FNameValueSeparator);
   P      := InternalAnsiPos(LSep, LLine);
   Result := TrimLeft(Copy(LLine, P + Length(LSep), MaxInt));
   If FUnfoldLines Then
    Begin
     While VLine < Count Do
      Begin
       LLine := Get(VLine);
       If Not CharIsInSet(LLine, 1, LWS) Then
        Break;
       Result := Trim(Result) + ' ' + Trim(LLine); {Do not Localize}
       Inc(VLine);
      End;
    End;
   Result := Trim(Result);
  End
 Else
  Result := '';
End;

Procedure TRESTDWHeaderList.SkipValueAtLine(var VLine: Integer);
Begin
 If (VLine >= 0)    And
    (VLine < Count) Then
  Begin
   Inc(VLine);
   If FUnfoldLines Then
    Begin
     While VLine < Count Do
      Begin
       If Not CharIsInSet(Get(VLine), 1, LWS) Then
        Break;
       Inc(VLine);
      End;
    End;
  End;
End;

Function TRESTDWHeaderList.GetParam(Const AName, AParam : String) : String;
Var
 s          : String;
 LQuoteType : TRESTDWHeaderQuotingType;
Begin
 s := Values[AName];
 If s <> '' Then
  Begin
   LQuoteType := FQuoteType;
   Case LQuoteType Of
      QuoteRFC822 : Begin
                     If PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) <> -1 Then
                      LQuoteType := QuoteMIME;
                    End;
      QuoteMIME: begin
        if PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) = -1 then begin {Do not Localize}
          LQuoteType := QuoteRFC822;
        end;
      end;
    end;
    Result := ExtractHeaderSubItem(s, AParam, LQuoteType);
  end else begin
    Result := '';
  end;
end;

function TRESTDWHeaderList.GetAllParams(const AName: string): string;
var
  s: string;
begin
  s := Values[AName];
  if s <> '' then begin
    Fetch(s, ';'); {do not localize}
    Result := Trim(s);
  end else begin
    Result := '';
  end;
end;

function TRESTDWHeaderList.IndexOfName(const AName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do begin
    if TextIsSame(GetName(i), AName) then begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TRESTDWHeaderList.SetValue(const AName, AValue: string);
var
  I: Integer;
begin
  I := IndexOfName(AName);
  if AValue <> '' then begin  {Do not Localize}
    if I < 0 then begin
      I := Add('');    {Do not Localize}
    end;
    if FFoldLines then begin
      DeleteFoldedLines(I);
      FoldAndInsert(AName + FNameValueSeparator + AValue, I);
    end else begin
      Put(I, AName + FNameValueSeparator + AValue);
    end;
  end
  else if I >= 0 then begin
    if FFoldLines then begin
      DeleteFoldedLines(I);
    end;
    Delete(I);
  end;
end;

procedure TRESTDWHeaderList.SetParam(const AName, AParam, AValue: string);
var
  LQuoteType: TRESTDWHeaderQuotingType;
begin
  LQuoteType := FQuoteType;
  case LQuoteType of
    QuoteRFC822: begin
      if PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) <> -1 then begin {Do not Localize}
        LQuoteType := QuoteMIME;
      end;
    end;
    QuoteMIME: begin
      if PosInStrArray(AName, ['Content-Type', 'Content-Disposition'], False) = -1 then begin {Do not Localize}
        LQuoteType := QuoteRFC822;
      end;
    end;
  end;
  Values[AName] := ReplaceHeaderSubItem(Values[AName], AParam, AValue, LQuoteType);
end;

procedure TRESTDWHeaderList.SetAllParams(const AName, AValue: string);
var
  LValue: string;
begin
  LValue := Values[AName];
  if LValue <> '' then
  begin
    LValue := ExtractHeaderItem(LValue);
    if AValue <> '' then begin
      LValue := LValue + '; ' + AValue; {do not localize}
    end;
    Values[AName] := LValue;
  end;
end;

end.
