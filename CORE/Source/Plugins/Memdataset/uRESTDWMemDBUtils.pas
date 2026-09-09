Unit uRESTDWMemDBUtils;

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

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

Uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  Variants, Classes, SysUtils, DB, DateUtils,
  uRESTDWTools;

Type
 TBookmarkType = {$IFDEF FPC}TBookmark
                 {$ELSE}
                 {$IFDEF RTL200_UP}TBookmark{$ELSE}TBookmarkStr{$ENDIF RTL200_UP}
                 {$ENDIF};


Type
 TFieldListArray = Array Of TField;

Type
  IRESTDWDataControl = Interface
    ['{8B6910C8-D5FD-40BA-A427-FC54FE7B85E5}']
    Function GetDataLink: TDataLink;
  End;
  TRESTDWDataLink = Class(TDataLink)
  Protected
    Procedure FocusControl(Field: TFieldRef); overload; override;
    Procedure FocusControl(Const Field: TField); reintroduce; overload; virtual;
  End;
  TCommit = (ctNone, ctStep, ctAll);
  TRESTDWDBProgressEvent = Procedure(UserData: Integer; Var Cancel: Boolean; Line: Integer) Of object;
  EJvScriptError = Class(Exception)
  Private
    FErrPos: Integer;
  Public
    // The dummy parameter is only there for BCB compatibility so that
    // when the hpp file gets generated, this constructor generates
    // a C++ constructor that doesn't already exist
    Constructor Create(Const AMessage: string; AErrPos: Integer; DummyForBCB: Integer = 0); overload;
    property ErrPos: Integer read FErrPos;
  End;
  TRESTDWLocateObject = Class(TObject)
  Private
    FDataSet: TDataSet;
    FLookupField: TField;
    FLookupValue: string;
    FLookupExact: Boolean;
    FCaseSensitive: Boolean;
    FBookmark: TBookmark;
    FIndexSwitch: Boolean;
    Procedure SetDataSet(Value: TDataSet);
  Protected
    Function MatchesLookup(Field: TField): Boolean;
    Procedure CheckFieldType(Field: TField); virtual;
    Procedure ActiveChanged; virtual;
    Function LocateKey: Boolean; virtual;
    Function LocateFull: Boolean; virtual;
    Function UseKey: Boolean; virtual;
    Function FilterApplicable: Boolean; virtual;
    property LookupField: TField read FLookupField;
    property LookupValue: string read FLookupValue;
    property LookupExact: Boolean read FLookupExact;
    property CaseSensitive: Boolean read FCaseSensitive;
    property Bookmark: TBookmark read FBookmark write FBookmark;
  Public
//    function Locate(const KeyField, KeyValue: string; Exact,
//      CaseSensitive: Boolean; DisableControls: Boolean = True;
//      RightTrimmedLookup: Boolean = False): Boolean;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property IndexSwitch: Boolean read FIndexSwitch write FIndexSwitch;
  End;
  TCreateLocateObject = Function: TRESTDWLocateObject;
Var
  CreateLocateObject: TCreateLocateObject = nil;
Function CreateLocate(DataSet: TDataSet): TRESTDWLocateObject;
{ Utility routines }
Function IsDataSetEmpty(DataSet: TDataSet): Boolean;
Procedure RefreshQuery(Query: TDataSet);
Function DataSetSortedSearch(DataSet: TDataSet;
  Const Value, FieldName: string; CaseInsensitive: Boolean): Boolean;
Function DataSetSectionName(DataSet: TDataSet): string;
Function DataSetLocateThrough(DataSet: TDataSet; Const KeyFields: string;
  Const KeyValues: Variant; Options: TLocateOptions): Boolean;

Procedure AssignRecord(Source, Dest: TDataSet; ByName: Boolean);
Procedure CheckRequiredField(Field: TField);
Procedure CheckRequiredFields(Const Fields: array Of TField);
Procedure GotoBookmarkEx(DataSet: TDataSet; Const Bookmark: TBookmark; Mode: TResyncMode = [rmExact, rmCenter]; ForceScrollEvents: Boolean = False);
{ SQL expressions }
Function DateToSQL(Value: TDateTime): string;
Function FormatSQLDateRange(Date1, Date2: TDateTime;
  Const FieldName: string): string;
Function FormatSQLDateRangeEx(Date1, Date2: TDateTime;
  Const FieldName: string): string;
Function FormatSQLNumericRange(Const FieldName: string;
  LowValue, HighValue, LowEmpty, HighEmpty: Double; Inclusive: Boolean): string;
Function StrMaskSQL(Const Value: string): string;
Const
  TrueExpr = '0=0';
  {$NODEFINE TrueExpr}
Const
  { Server Date formats}
  sdfStandard16 = '''"''mm''/''dd''/''yyyy''"'''; {"mm/dd/yyyy"}
  sdfStandard32 = '''''''dd/mm/yyyy'''''''; {'dd/mm/yyyy'}
  sdfOracle = '"TO_DATE(''"dd/mm/yyyy"'', ''DD/MM/YYYY'')"';
  sdfInterbase = '"CAST(''"mm"/"dd"/"yyyy"'' AS DATE)"';
  sdfMSSQL = '"CONVERT(datetime, ''"mm"/"dd"/"yyyy"'', 103)"';
Const
  ServerDateFmt: string = sdfStandard16;
{.$NODEFINE ftNonTextTypes}
(*$HPPEMIT 'namespace JvDBUtils'*)
(*$HPPEMIT '{'*)
(*$HPPEMIT '#define ftNonTextTypes (System::Set<TFieldType, ftUnknown, ftCursor> () \'*)
(*$HPPEMIT '        << ftBytes << ftVarBytes << ftBlob << ftMemo << ftGraphic \'*)
(*$HPPEMIT '        << ftFmtMemo << ftParadoxOle << ftDBaseOle << ftTypedBinary << ftCursor )'*)
(*$HPPEMIT '}'*)
Type
  Largeint = Longint;
  {$NODEFINE Largeint}
Function NameDelimiter(C: Char): Boolean;
Function IsLiteral(C: Char): Boolean;
Procedure _DBError(Const Msg: string);
{$IFDEF UNITVERSIONING}
Const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JVCL\run'
  );
{$ENDIF UNITVERSIONING}
Implementation
Uses
  Math,
  {$IFDEF HAS_UNIT_SYSTEM_UITYPES}
  System.UITypes,
  {$ENDIF}
  {$IFDEF RTL240_UP}
  System.Generics.Collections,
  {$ENDIF RTL240_UP}
  {$IFDEF RESTDWVCL}uRESTDWMemVCLUtils, {$ENDIF}
  uRESTDWMemTypes, uRESTDWMemConsts, uRESTDWMemResources,
  uRESTDWConsts;

{ TRESTDWDataLink }
Procedure TRESTDWDataLink.FocusControl(Field: TFieldRef);
Begin
  FocusControl(Field^);
End;
Procedure TRESTDWDataLink.FocusControl(Const Field: TField);
Begin
End;
{ Utility routines }
Function NameDelimiter(C: Char): Boolean;
Begin
  Result := RESTDWCharInSet(C, [' ', ',', ';', ')', '.', Cr, Lf]);
End;
Function IsLiteral(C: Char): Boolean;
Begin
  Result := RESTDWCharInSet(C, ['''', '"']);
End;
Procedure _DBError(Const Msg: string);
Begin
  DatabaseError(Msg);
End;
Constructor EJvScriptError.Create(Const AMessage: string; AErrPos: Integer; DummyForBCB: Integer);
Begin
  Inherited Create(AMessage);
  FErrPos := AErrPos;
End;
// (rom) better use Windows dialogs which are localized
Function SetToBookmark(ADataSet: TDataSet; ABookmark: TBookmark): Boolean;
Begin
  Result := False;
  If ADataSet.Active and (ABookmark <> nil) and not (ADataSet.Bof and ADataSet.Eof) and
    ADataSet.BookmarkValid(ABookmark) Then
  Try
    ADataSet.GotoBookmark(ABookmark);
    Result := True;
  Except
  End;
End;
{ Refresh Query procedure }
Procedure RefreshQuery(Query: TDataSet);
Var
  BookMk: TBookmark;
Begin
  Query.DisableControls;
  Try
    If Query.Active Then
      BookMk := Query.GetBookmark
    Else
      BookMk := nil;
    Try
      Query.Close;
      Query.Open;
      SetToBookmark(Query, BookMk);
    Finally
      If BookMk <> nil Then
        Query.FreeBookmark(BookMk);
    End;
  Finally
    Query.EnableControls;
  End;
End;
Procedure TRESTDWLocateObject.SetDataSet(Value: TDataSet);
Begin
  ActiveChanged;
  FDataSet := Value;
End;
Function TRESTDWLocateObject.LocateFull: Boolean;
Begin
  Result := False;
  DataSet.First;
  While not DataSet.Eof Do
  Begin
    If MatchesLookup(FLookupField) Then
    Begin
      Result := True;
      Break;
    End;
    DataSet.Next;
  End;
End;
Function TRESTDWLocateObject.LocateKey: Boolean;
Begin
  Result := False;
End;
Function TRESTDWLocateObject.FilterApplicable: Boolean;
Begin
  Result := FLookupField.FieldKind in [fkData, fkInternalCalc];
End;
Procedure TRESTDWLocateObject.CheckFieldType(Field: TField);
Begin
End;
//function TRESTDWLocateObject.Locate(const KeyField, KeyValue: string;
//  Exact, CaseSensitive: Boolean; DisableControls: Boolean; RightTrimmedLookup: Boolean): Boolean;
//var
//  LookupKey: TField;
//
//  function IsStringType(FieldType: TFieldType): Boolean;
//  const
//    cStringTypes = [ftString, ftWideString];
//  begin
//    Result := FieldType in cStringTypes;
//  end;
//
//begin
//  if DataSet = nil then
//  begin
//    Result := False;
//    Exit;
//  end;
//  DataSet.CheckBrowseMode;
//  LookupKey := DataSet.FieldByName(KeyField);
//  DataSet.CursorPosChanged;
//  FLookupField := LookupKey;
//  if RightTrimmedLookup then
//    FLookupValue := TrimRight(KeyValue)
//  else
//    FLookupValue := KeyValue;
//  FLookupExact := Exact;
//  FCaseSensitive := CaseSensitive;
//  if not IsStringType(FLookupField.DataType) then
//  begin
//    FCaseSensitive := True;
//    try
//      CheckFieldType(FLookupField);
//    except
//      Result := False;
//      Exit;
//    end;
//  end
//  else
//    FCaseSensitive := CaseSensitive;
//  if DisableControls then
//    DataSet.DisableControls;
//  try
//    FBookmark := DataSet.GetBookmark;
//    try
//      Result := MatchesLookup(FLookupField);
//      if not Result then
//      begin
//        if UseKey then
//          Result := LocateKey
//        else
//        begin
//          if FilterApplicable then
//            Result := LocateFilter
//          else
//            Result := LocateFull;
//        end;
//        if not Result then
//          SetToBookmark(DataSet, FBookmark);
//      end;
//    finally
//      FLookupValue := '';
//      FLookupField := nil;
//      DataSet.FreeBookmark(FBookmark);
//      FBookmark := nil;
//    end;
//  finally
//    if DisableControls then
//      DataSet.EnableControls;
//  end;
//end;
Function TRESTDWLocateObject.UseKey: Boolean;
Begin
  Result := False;
End;
Procedure TRESTDWLocateObject.ActiveChanged;
Begin
End;
Function TRESTDWLocateObject.MatchesLookup(Field: TField): Boolean;
Var
  Temp: string;
Begin
  Temp := Field.AsString;
  If not LookupExact Then
    SetLength(Temp, Min(Length(FLookupValue), Length(Temp)));
  If CaseSensitive Then
    Result := AnsiSameStr(Temp, LookupValue)
  Else
    Result := AnsiSameText(Temp, LookupValue);
End;
Function CreateLocate(DataSet: TDataSet): TRESTDWLocateObject;
Begin
  If Assigned(CreateLocateObject) Then
   Begin
    {$IFDEF FPC}
     Result := CreateLocateObject();
    {$ELSE}
     Result := CreateLocateObject;
    {$ENDIF}
   End
  Else
    Result := TRESTDWLocateObject.Create;
  If (Result <> nil) and (DataSet <> nil) Then
    Result.DataSet := DataSet;
End;
{ DataSet locate routines }
Function DataSetLocateThrough(DataSet: TDataSet; Const KeyFields: string;
  Const KeyValues: Variant; Options: TLocateOptions): Boolean;
Var
  FieldCount : Integer;
  Fields     : TFieldListArray;
  Bookmark: TBookmarkType;
  Function CompareField(Field: TField; Const Value: Variant): Boolean;
  Var
   S, A : string;
  Begin
    If Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString{$ENDIF UNICODE}] Then
    Begin
      If Value = Null Then
        Result := Field.IsNull
      Else
      Begin
        S := Field.AsString;
        A := Copy(Value, InitStrPos, Field.Size);
        If loPartialKey in Options Then
          Delete(S, Length(Value) + 1, MaxInt);
        If loCaseInsensitive in Options Then
          Result := Uppercase(S) = Uppercase(A)
        Else
          Result := S = A;
      End;
    End
    Else
      Result := (Field.Value = Value);
  End;
  Function CompareRecord: Boolean;
  Var
    I: Integer;
  Begin
    // Works with the KeyValues variant like TCustomClientDataSet.LocateRecord
    If (FieldCount = 1) and not VarIsArray(KeyValues) Then
      Result := CompareField(TField(Fields[0]), KeyValues)
    Else
    Begin
      Result := True;
      For I := 0 To FieldCount - 1 Do
        Result := Result and CompareField(TField(Fields[I]), KeyValues[I]);
    End;
  End;
 Procedure GetFieldList(List: TFieldListArray; Const FieldNames: string);
 Var
  I, Len,
  Pos     : Integer;
  Field   : TField;
 Begin
  Len := FieldNames.Length;
  Pos := 1;
  I := 0;
  While Pos <= Len Do
   Begin
    Field := DataSet.FieldByName(ExtractFieldName(FieldNames, Pos));
    SetLength(Fields, I+1);
    Fields[I] := Field;
    Inc(I);
   End;
 End;
Begin
  Result := False;
  SetLength(Fields, 0);
  DataSet.CheckBrowseMode;
  If DataSet.IsEmpty Then
    Exit;
//  Fields := TList.Create;
  Try
    GetFieldList(Fields, KeyFields);
    FieldCount := Length(Fields);
    Result := CompareRecord;
    If Result Then
      Exit;
    DataSet.DisableControls;
    Try
      Bookmark := TBookmarkType(DataSet.Bookmark);
      Try
        DataSet.First;
        While not DataSet.Eof Do
        Begin
          Result := CompareRecord;
          If Result Then
            Break;
          DataSet.Next;
        End;
      Finally
        If not Result and DataSet.BookmarkValid(TBookmark(Bookmark)) Then
         Begin
          {$IFNDEF FPC}
            {$IF CompilerVersion > 21}
             DataSet.Bookmark := TBookmark(Bookmark);
            {$ELSE}
             DataSet.Bookmark := TBookmarkSTR(Bookmark);
            {$IFEND}
          {$ELSE}
           DataSet.Bookmark := TBookmark(Bookmark);
          {$ENDIF}
         End;
      End;
    Finally
      DataSet.EnableControls;
    End;
  Finally
   SetLength(Fields, 0);
//   Fields.Free;
  End;
End;
{ DataSetSortedSearch. Navigate on sorted DataSet routine. }
Function DataSetSortedSearch(DataSet: TDataSet; Const Value,
  FieldName: string; CaseInsensitive: Boolean): Boolean;
Var
  L, H, I: Longint;
  CurrentPos: Longint;
  CurrentValue: string;
  BookMk: TBookmark;
  Field: TField;
  Function UpStr(Const Value: string): string;
  Begin
    If CaseInsensitive Then
      Result := AnsiUpperCase(Value)
    Else
      Result := Value;
  End;
  Function GetCurrentStr: string;
  Begin
    Result := Field.AsString;
    If Length(Result) > Length(Value) Then
      SetLength(Result, Length(Value));
    Result := UpStr(Result);
  End;
Begin
  Result := False;
  If DataSet = nil Then
    Exit;
  Field := DataSet.FindField(FieldName);
  If Field = nil Then
    Exit;
  If Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString{$ENDIF UNICODE}] Then
  Begin
    DataSet.DisableControls;
    BookMk := DataSet.GetBookmark;
    Try
      L := 0;
      DataSet.First;
      CurrentPos := 0;
      H := DataSet.RecordCount - 1;
      If Value <> '' Then
      Begin
        While L <= H Do
        Begin
          I := (L + H) shr 1;
          If I <> CurrentPos Then
            DataSet.MoveBy(I - CurrentPos);
          CurrentPos := I;
          CurrentValue := GetCurrentStr;
          If UpStr(Value) > CurrentValue Then
            L := I + 1
          Else
          Begin
            H := I - 1;
            If UpStr(Value) = CurrentValue Then
              Result := True;
          End;
        End;
        If Result Then
        Begin
          If L <> CurrentPos Then
            DataSet.MoveBy(L - CurrentPos);
          While (L < DataSet.RecordCount) and
            (UpStr(Value) <> GetCurrentStr) Do
          Begin
            Inc(L);
            DataSet.MoveBy(1);
          End;
        End;
      End
      Else
        Result := True;
      If not Result Then
        SetToBookmark(DataSet, BookMk);
    Finally
      DataSet.FreeBookmark(BookMk);
      DataSet.EnableControls;
    End;
  End
  Else
    DatabaseErrorFmt('Field %s TypeMismatch', [Field.DisplayName]);
End;
{ Save and restore DataSet Fields layout }
Function DataSetSectionName(DataSet: TDataSet): string;
Begin
 Result := DataSet.Name;
End;
Function CheckSection(DataSet: TDataSet; Const Section: string): string;
Begin
  Result := Section;
  If Result = '' Then
    Result := DataSetSectionName(DataSet);
End;
Function IsDataSetEmpty(DataSet: TDataSet): Boolean;
Begin
  Result := (not DataSet.Active) or (DataSet.Eof and DataSet.Bof);
End;
{ SQL expressions }
Function DateToSQL(Value: TDateTime): string;
Begin
  Result := IntToStr(Trunc(Value));
End;
Function FormatSQLDateRange(Date1, Date2: TDateTime;
  Const FieldName: string): string;
Begin
  Result := TrueExpr;
  If (Date1 = Date2) and (Date1 <> NullDate) Then
  Begin
    Result := Format('%s = %s', [FieldName, FormatDateTime(ServerDateFmt,
        Date1)]);
  End
  Else
  If (Date1 <> NullDate) or (Date2 <> NullDate) Then
  Begin
    If Date1 = NullDate Then
      Result := Format('%s < %s', [FieldName,
        FormatDateTime(ServerDateFmt, IncDay(Date2, 1))])
    Else
    If Date2 = NullDate Then
      Result := Format('%s > %s', [FieldName,
        FormatDateTime(ServerDateFmt, IncDay(Date1, -1))])
    Else
      Result := Format('(%s < %s) AND (%s > %s)',
        [FieldName, FormatDateTime(ServerDateFmt, IncDay(Date2, 1)),
        FieldName, FormatDateTime(ServerDateFmt, IncDay(Date1, -1))]);
  End;
End;
Function FormatSQLDateRangeEx(Date1, Date2: TDateTime;
  Const FieldName: string): string;
Begin
  Result := TrueExpr;
  If (Date1 <> NullDate) or (Date2 <> NullDate) Then
  Begin
    If Date1 = NullDate Then
      Result := Format('%s < %s', [FieldName,
        FormatDateTime(ServerDateFmt, IncDay(Date2, 1))])
    Else
    If Date2 = NullDate Then
      Result := Format('%s >= %s', [FieldName,
        FormatDateTime(ServerDateFmt, Date1)])
    Else
      Result := Format('(%s < %s) AND (%s >= %s)',
        [FieldName, FormatDateTime(ServerDateFmt, IncDay(Date2, 1)),
        FieldName, FormatDateTime(ServerDateFmt, Date1)]);
  End;
End;
Function FormatSQLNumericRange(Const FieldName: string;
  LowValue, HighValue, LowEmpty, HighEmpty: Double; Inclusive: Boolean): string;
Const
  Operators: array[Boolean, 1..2] Of string = (('>', '<'), ('>=', '<='));
Begin
  Result := TrueExpr;
  If (LowValue = HighValue) and (LowValue <> LowEmpty) Then
    Result := Format('%s = %g', [FieldName, LowValue])
  Else
  If (LowValue <> LowEmpty) or (HighValue <> HighEmpty) Then
  Begin
    If LowValue = LowEmpty Then
      Result := Format('%s %s %g', [FieldName, Operators[Inclusive, 2], HighValue])
    Else
    If HighValue = HighEmpty Then
      Result := Format('%s %s %g', [FieldName, Operators[Inclusive, 1], LowValue])
    Else
      Result := Format('(%s %s %g) AND (%s %s %g)',
        [FieldName, Operators[Inclusive, 2], HighValue,
        FieldName, Operators[Inclusive, 1], LowValue]);
  End;
End;
Function StrMaskSQL(Const Value: string): string;
Begin
  If (Pos('*', Value) = 0) and (Pos('?', Value) = 0) and (Value <> '') Then
    Result := '*' + Value + '*'
  Else
    Result := Value;
End;
Procedure CheckRequiredField(Field: TField);
Begin
  If not Field.ReadOnly and not Field.Calculated and Field.IsNull Then
  Begin
    Field.FocusControl;
    DatabaseErrorFmt('Field %s Required', [Field.DisplayName]);
  End;
End;
Procedure CheckRequiredFields(Const Fields: array Of TField);
Var
  I: Integer;
Begin
  For I := Low(Fields) To High(Fields) Do
    CheckRequiredField(Fields[I]);
End;
Type
  TDataSetAccess = Class(TDataSet);
Procedure GotoBookmarkEx(DataSet: TDataSet; Const Bookmark: TBookmark; Mode: TResyncMode; ForceScrollEvents: Boolean);
Var
  DS: TDataSetAccess;
Begin
	If (DataSet <> nil) and (Bookmark <> nil) Then
	Begin
    DS := TDataSetAccess(DataSet);
		DS.CheckBrowseMode;
		If ForceScrollEvents or (rmCenter in Mode) Then DS.DoBeforeScroll;
		DS.InternalGotoBookmark({$IFNDEF RTL240_UP}Pointer{$ENDIF}(Bookmark));
		DS.Resync(Mode);
		If ForceScrollEvents or (rmCenter in Mode) Then DS.DoAfterScroll;
	End;
End;
Procedure AssignRecord(Source, Dest: TDataSet; ByName: Boolean);
Var
  I: Integer;
  F, FSrc: TField;
Begin
  If not (Dest.State in dsEditModes) Then
    _DBError('Not Editing');
  If ByName Then
  Begin
    For I := 0 To Source.FieldCount - 1 Do
    Begin
      F := Dest.FindField(Source.Fields[I].FieldName);
      FSrc := Source.Fields[i];
      If (F <> nil) and (F.DataType <> ftAutoInc) Then
      Begin
        If FSrc.IsNull Then
          F.Value := FSrc.Value
        Else
          Case F.DataType Of
             ftString: F.AsString := FSrc.AsString;
             ftInteger: F.AsInteger := FSrc.AsInteger;
             ftBoolean: F.AsBoolean := FSrc.AsBoolean;
             ftFloat: F.AsFloat := FSrc.AsFloat;
             ftCurrency: F.AsCurrency := FSrc.AsCurrency;
             ftDate: F.AsDateTime := FSrc.AsDateTime;
             ftDateTime: F.AsDateTime := FSrc.AsDateTime;
          Else
             F.Value := FSrc.Value;
          End;
      End;
    End;
  End
  Else
  Begin
    For I := 0 To Min(Source.FieldDefs.Count - 1, Dest.FieldDefs.Count - 1) Do
    Begin
      F := Dest.FindField(Dest.FieldDefs[I].Name);
      FSrc := Source.FindField(Source.FieldDefs[I].Name);
      If (F <> nil) and (FSrc <> nil) and (F.DataType <> ftAutoInc) Then
      Begin
        If FSrc.IsNull Then
          F.Value := FSrc.Value
        Else
          Case F.DataType Of
             ftString: F.AsString := FSrc.AsString;
             ftInteger: F.AsInteger := FSrc.AsInteger;
             ftBoolean: F.AsBoolean := FSrc.AsBoolean;
             ftFloat: F.AsFloat := FSrc.AsFloat;
             ftCurrency: F.AsCurrency := FSrc.AsCurrency;
             ftDate: F.AsDateTime := FSrc.AsDateTime;
             ftDateTime: F.AsDateTime := FSrc.AsDateTime;
          Else
             F.Value := FSrc.Value;
          End;
      End;
    End;
  End;
End;
End.
