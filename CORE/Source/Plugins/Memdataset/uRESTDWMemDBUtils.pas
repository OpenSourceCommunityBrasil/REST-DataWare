unit uRESTDWMemDBUtils;

{$I ..\..\Includes\uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

uses
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
 TFieldListArray = Array of TField;

type
  IRESTDWDataControl = interface
    ['{8B6910C8-D5FD-40BA-A427-FC54FE7B85E5}']
    function GetDataLink: TDataLink;
  end;
  TRESTDWDataLink = class(TDataLink)
  protected
    procedure FocusControl(Field: TFieldRef); overload; override;
    procedure FocusControl(const Field: TField); reintroduce; overload; virtual;
  end;
  TCommit = (ctNone, ctStep, ctAll);
  TRESTDWDBProgressEvent = procedure(UserData: Integer; var Cancel: Boolean; Line: Integer) of object;
  EJvScriptError = class(Exception)
  private
    FErrPos: Integer;
  public
    // The dummy parameter is only there for BCB compatibility so that
    // when the hpp file gets generated, this constructor generates
    // a C++ constructor that doesn't already exist
    constructor Create(const AMessage: string; AErrPos: Integer; DummyForBCB: Integer = 0); overload;
    property ErrPos: Integer read FErrPos;
  end;
  TRESTDWLocateObject = class(TObject)
  private
    FDataSet: TDataSet;
    FLookupField: TField;
    FLookupValue: string;
    FLookupExact: Boolean;
    FCaseSensitive: Boolean;
    FBookmark: TBookmark;
    FIndexSwitch: Boolean;
    procedure SetDataSet(Value: TDataSet);
  protected
    function MatchesLookup(Field: TField): Boolean;
    procedure CheckFieldType(Field: TField); virtual;
    procedure ActiveChanged; virtual;
    function LocateKey: Boolean; virtual;
    function LocateFull: Boolean; virtual;
    function UseKey: Boolean; virtual;
    function FilterApplicable: Boolean; virtual;
    property LookupField: TField read FLookupField;
    property LookupValue: string read FLookupValue;
    property LookupExact: Boolean read FLookupExact;
    property CaseSensitive: Boolean read FCaseSensitive;
    property Bookmark: TBookmark read FBookmark write FBookmark;
  public
//    function Locate(const KeyField, KeyValue: string; Exact,
//      CaseSensitive: Boolean; DisableControls: Boolean = True;
//      RightTrimmedLookup: Boolean = False): Boolean;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property IndexSwitch: Boolean read FIndexSwitch write FIndexSwitch;
  end;
  TCreateLocateObject = function: TRESTDWLocateObject;
var
  CreateLocateObject: TCreateLocateObject = nil;
function CreateLocate(DataSet: TDataSet): TRESTDWLocateObject;
{ Utility routines }
function IsDataSetEmpty(DataSet: TDataSet): Boolean;
procedure RefreshQuery(Query: TDataSet);
function DataSetSortedSearch(DataSet: TDataSet;
  const Value, FieldName: string; CaseInsensitive: Boolean): Boolean;
function DataSetSectionName(DataSet: TDataSet): string;
function DataSetLocateThrough(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;

procedure AssignRecord(Source, Dest: TDataSet; ByName: Boolean);
procedure CheckRequiredField(Field: TField);
procedure CheckRequiredFields(const Fields: array of TField);
procedure GotoBookmarkEx(DataSet: TDataSet; const Bookmark: TBookmark; Mode: TResyncMode = [rmExact, rmCenter]; ForceScrollEvents: Boolean = False);
{ SQL expressions }
function DateToSQL(Value: TDateTime): string;
function FormatSQLDateRange(Date1, Date2: TDateTime;
  const FieldName: string): string;
function FormatSQLDateRangeEx(Date1, Date2: TDateTime;
  const FieldName: string): string;
function FormatSQLNumericRange(const FieldName: string;
  LowValue, HighValue, LowEmpty, HighEmpty: Double; Inclusive: Boolean): string;
function StrMaskSQL(const Value: string): string;
const
  TrueExpr = '0=0';
  {$NODEFINE TrueExpr}
const
  { Server Date formats}
  sdfStandard16 = '''"''mm''/''dd''/''yyyy''"'''; {"mm/dd/yyyy"}
  sdfStandard32 = '''''''dd/mm/yyyy'''''''; {'dd/mm/yyyy'}
  sdfOracle = '"TO_DATE(''"dd/mm/yyyy"'', ''DD/MM/YYYY'')"';
  sdfInterbase = '"CAST(''"mm"/"dd"/"yyyy"'' AS DATE)"';
  sdfMSSQL = '"CONVERT(datetime, ''"mm"/"dd"/"yyyy"'', 103)"';
const
  ServerDateFmt: string = sdfStandard16;
{.$NODEFINE ftNonTextTypes}
(*$HPPEMIT 'namespace JvDBUtils'*)
(*$HPPEMIT '{'*)
(*$HPPEMIT '#define ftNonTextTypes (System::Set<TFieldType, ftUnknown, ftCursor> () \'*)
(*$HPPEMIT '        << ftBytes << ftVarBytes << ftBlob << ftMemo << ftGraphic \'*)
(*$HPPEMIT '        << ftFmtMemo << ftParadoxOle << ftDBaseOle << ftTypedBinary << ftCursor )'*)
(*$HPPEMIT '}'*)
type
  Largeint = Longint;
  {$NODEFINE Largeint}
function NameDelimiter(C: Char): Boolean;
function IsLiteral(C: Char): Boolean;
procedure _DBError(const Msg: string);
{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: 'JVCL\run'
  );
{$ENDIF UNITVERSIONING}
implementation
uses
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
procedure TRESTDWDataLink.FocusControl(Field: TFieldRef);
begin
  FocusControl(Field^);
end;
procedure TRESTDWDataLink.FocusControl(const Field: TField);
begin
end;
{ Utility routines }
function NameDelimiter(C: Char): Boolean;
begin
  Result := RESTDWCharInSet(C, [' ', ',', ';', ')', '.', Cr, Lf]);
end;
function IsLiteral(C: Char): Boolean;
begin
  Result := RESTDWCharInSet(C, ['''', '"']);
end;
procedure _DBError(const Msg: string);
begin
  DatabaseError(Msg);
end;
constructor EJvScriptError.Create(const AMessage: string; AErrPos: Integer; DummyForBCB: Integer);
begin
  inherited Create(AMessage);
  FErrPos := AErrPos;
end;
// (rom) better use Windows dialogs which are localized
function SetToBookmark(ADataSet: TDataSet; ABookmark: TBookmark): Boolean;
begin
  Result := False;
  if ADataSet.Active and (ABookmark <> nil) and not (ADataSet.Bof and ADataSet.Eof) and
    ADataSet.BookmarkValid(ABookmark) then
  try
    ADataSet.GotoBookmark(ABookmark);
    Result := True;
  except
  end;
end;
{ Refresh Query procedure }
procedure RefreshQuery(Query: TDataSet);
var
  BookMk: TBookmark;
begin
  Query.DisableControls;
  try
    if Query.Active then
      BookMk := Query.GetBookmark
    else
      BookMk := nil;
    try
      Query.Close;
      Query.Open;
      SetToBookmark(Query, BookMk);
    finally
      if BookMk <> nil then
        Query.FreeBookmark(BookMk);
    end;
  finally
    Query.EnableControls;
  end;
end;
procedure TRESTDWLocateObject.SetDataSet(Value: TDataSet);
begin
  ActiveChanged;
  FDataSet := Value;
end;
function TRESTDWLocateObject.LocateFull: Boolean;
begin
  Result := False;
  DataSet.First;
  while not DataSet.Eof do
  begin
    if MatchesLookup(FLookupField) then
    begin
      Result := True;
      Break;
    end;
    DataSet.Next;
  end;
end;
function TRESTDWLocateObject.LocateKey: Boolean;
begin
  Result := False;
end;
function TRESTDWLocateObject.FilterApplicable: Boolean;
begin
  Result := FLookupField.FieldKind in [fkData, fkInternalCalc];
end;
procedure TRESTDWLocateObject.CheckFieldType(Field: TField);
begin
end;
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
function TRESTDWLocateObject.UseKey: Boolean;
begin
  Result := False;
end;
procedure TRESTDWLocateObject.ActiveChanged;
begin
end;
function TRESTDWLocateObject.MatchesLookup(Field: TField): Boolean;
var
  Temp: string;
begin
  Temp := Field.AsString;
  if not LookupExact then
    SetLength(Temp, Min(Length(FLookupValue), Length(Temp)));
  if CaseSensitive then
    Result := AnsiSameStr(Temp, LookupValue)
  else
    Result := AnsiSameText(Temp, LookupValue);
end;
function CreateLocate(DataSet: TDataSet): TRESTDWLocateObject;
begin
  if Assigned(CreateLocateObject) then
   Begin
    {$IFDEF FPC}
     Result := CreateLocateObject();
    {$ELSE}
     Result := CreateLocateObject;
    {$ENDIF}
   End
  else
    Result := TRESTDWLocateObject.Create;
  if (Result <> nil) and (DataSet <> nil) then
    Result.DataSet := DataSet;
end;
{ DataSet locate routines }
function DataSetLocateThrough(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  FieldCount : Integer;
  Fields     : TFieldListArray;
  Bookmark: TBookmarkType;
  function CompareField(Field: TField; const Value: Variant): Boolean;
  var
   S, A : string;
  begin
    if Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString{$ENDIF UNICODE}] then
    begin
      if Value = Null then
        Result := Field.IsNull
      else
      begin
        S := Field.AsString;
        A := Copy(Value, InitStrPos, Field.Size);
        if loPartialKey in Options then
          Delete(S, Length(Value) + 1, MaxInt);
        if loCaseInsensitive in Options then
          Result := Uppercase(S) = Uppercase(A)
        else
          Result := S = A;
      end;
    end
    else
      Result := (Field.Value = Value);
  end;
  function CompareRecord: Boolean;
  var
    I: Integer;
  begin
    // Works with the KeyValues variant like TCustomClientDataSet.LocateRecord
    if (FieldCount = 1) and not VarIsArray(KeyValues) then
      Result := CompareField(TField(Fields[0]), KeyValues)
    else
    begin
      Result := True;
      for I := 0 to FieldCount - 1 do
        Result := Result and CompareField(TField(Fields[I]), KeyValues[I]);
    end;
  end;
 procedure GetFieldList(List: TFieldListArray; const FieldNames: string);
 var
  I, Len,
  Pos     : Integer;
  Field   : TField;
 begin
  Len := FieldNames.Length;
  Pos := 1;
  I := 0;
  while Pos <= Len do
   begin
    Field := DataSet.FieldByName(ExtractFieldName(FieldNames, Pos));
    SetLength(Fields, I+1);
    Fields[I] := Field;
    Inc(I);
   end;
 End;
begin
  Result := False;
  SetLength(Fields, 0);
  DataSet.CheckBrowseMode;
  if DataSet.IsEmpty then
    Exit;
//  Fields := TList.Create;
  try
    GetFieldList(Fields, KeyFields);
    FieldCount := Length(Fields);
    Result := CompareRecord;
    if Result then
      Exit;
    DataSet.DisableControls;
    try
      Bookmark := TBookmarkType(DataSet.Bookmark);
      try
        DataSet.First;
        while not DataSet.Eof do
        begin
          Result := CompareRecord;
          if Result then
            Break;
          DataSet.Next;
        end;
      finally
        if not Result and DataSet.BookmarkValid(TBookmark(Bookmark)) then
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
      end;
    finally
      DataSet.EnableControls;
    end;
  finally
   SetLength(Fields, 0);
//   Fields.Free;
  end;
end;
{ DataSetSortedSearch. Navigate on sorted DataSet routine. }
function DataSetSortedSearch(DataSet: TDataSet; const Value,
  FieldName: string; CaseInsensitive: Boolean): Boolean;
var
  L, H, I: Longint;
  CurrentPos: Longint;
  CurrentValue: string;
  BookMk: TBookmark;
  Field: TField;
  function UpStr(const Value: string): string;
  begin
    if CaseInsensitive then
      Result := AnsiUpperCase(Value)
    else
      Result := Value;
  end;
  function GetCurrentStr: string;
  begin
    Result := Field.AsString;
    if Length(Result) > Length(Value) then
      SetLength(Result, Length(Value));
    Result := UpStr(Result);
  end;
begin
  Result := False;
  if DataSet = nil then
    Exit;
  Field := DataSet.FindField(FieldName);
  if Field = nil then
    Exit;
  if Field.DataType in [ftString{$IFDEF UNICODE}, ftWideString{$ENDIF UNICODE}] then
  begin
    DataSet.DisableControls;
    BookMk := DataSet.GetBookmark;
    try
      L := 0;
      DataSet.First;
      CurrentPos := 0;
      H := DataSet.RecordCount - 1;
      if Value <> '' then
      begin
        while L <= H do
        begin
          I := (L + H) shr 1;
          if I <> CurrentPos then
            DataSet.MoveBy(I - CurrentPos);
          CurrentPos := I;
          CurrentValue := GetCurrentStr;
          if UpStr(Value) > CurrentValue then
            L := I + 1
          else
          begin
            H := I - 1;
            if UpStr(Value) = CurrentValue then
              Result := True;
          end;
        end;
        if Result then
        begin
          if L <> CurrentPos then
            DataSet.MoveBy(L - CurrentPos);
          while (L < DataSet.RecordCount) and
            (UpStr(Value) <> GetCurrentStr) do
          begin
            Inc(L);
            DataSet.MoveBy(1);
          end;
        end;
      end
      else
        Result := True;
      if not Result then
        SetToBookmark(DataSet, BookMk);
    finally
      DataSet.FreeBookmark(BookMk);
      DataSet.EnableControls;
    end;
  end
  else
    DatabaseErrorFmt('Field %s TypeMismatch', [Field.DisplayName]);
end;
{ Save and restore DataSet Fields layout }
function DataSetSectionName(DataSet: TDataSet): string;
begin
 Result := DataSet.Name;
end;
function CheckSection(DataSet: TDataSet; const Section: string): string;
begin
  Result := Section;
  if Result = '' then
    Result := DataSetSectionName(DataSet);
end;
function IsDataSetEmpty(DataSet: TDataSet): Boolean;
begin
  Result := (not DataSet.Active) or (DataSet.Eof and DataSet.Bof);
end;
{ SQL expressions }
function DateToSQL(Value: TDateTime): string;
begin
  Result := IntToStr(Trunc(Value));
end;
function FormatSQLDateRange(Date1, Date2: TDateTime;
  const FieldName: string): string;
begin
  Result := TrueExpr;
  if (Date1 = Date2) and (Date1 <> NullDate) then
  begin
    Result := Format('%s = %s', [FieldName, FormatDateTime(ServerDateFmt,
        Date1)]);
  end
  else
  if (Date1 <> NullDate) or (Date2 <> NullDate) then
  begin
    if Date1 = NullDate then
      Result := Format('%s < %s', [FieldName,
        FormatDateTime(ServerDateFmt, IncDay(Date2, 1))])
    else
    if Date2 = NullDate then
      Result := Format('%s > %s', [FieldName,
        FormatDateTime(ServerDateFmt, IncDay(Date1, -1))])
    else
      Result := Format('(%s < %s) AND (%s > %s)',
        [FieldName, FormatDateTime(ServerDateFmt, IncDay(Date2, 1)),
        FieldName, FormatDateTime(ServerDateFmt, IncDay(Date1, -1))]);
  end;
end;
function FormatSQLDateRangeEx(Date1, Date2: TDateTime;
  const FieldName: string): string;
begin
  Result := TrueExpr;
  if (Date1 <> NullDate) or (Date2 <> NullDate) then
  begin
    if Date1 = NullDate then
      Result := Format('%s < %s', [FieldName,
        FormatDateTime(ServerDateFmt, IncDay(Date2, 1))])
    else
    if Date2 = NullDate then
      Result := Format('%s >= %s', [FieldName,
        FormatDateTime(ServerDateFmt, Date1)])
    else
      Result := Format('(%s < %s) AND (%s >= %s)',
        [FieldName, FormatDateTime(ServerDateFmt, IncDay(Date2, 1)),
        FieldName, FormatDateTime(ServerDateFmt, Date1)]);
  end;
end;
function FormatSQLNumericRange(const FieldName: string;
  LowValue, HighValue, LowEmpty, HighEmpty: Double; Inclusive: Boolean): string;
const
  Operators: array[Boolean, 1..2] of string = (('>', '<'), ('>=', '<='));
begin
  Result := TrueExpr;
  if (LowValue = HighValue) and (LowValue <> LowEmpty) then
    Result := Format('%s = %g', [FieldName, LowValue])
  else
  if (LowValue <> LowEmpty) or (HighValue <> HighEmpty) then
  begin
    if LowValue = LowEmpty then
      Result := Format('%s %s %g', [FieldName, Operators[Inclusive, 2], HighValue])
    else
    if HighValue = HighEmpty then
      Result := Format('%s %s %g', [FieldName, Operators[Inclusive, 1], LowValue])
    else
      Result := Format('(%s %s %g) AND (%s %s %g)',
        [FieldName, Operators[Inclusive, 2], HighValue,
        FieldName, Operators[Inclusive, 1], LowValue]);
  end;
end;
function StrMaskSQL(const Value: string): string;
begin
  if (Pos('*', Value) = 0) and (Pos('?', Value) = 0) and (Value <> '') then
    Result := '*' + Value + '*'
  else
    Result := Value;
end;
procedure CheckRequiredField(Field: TField);
begin
  if not Field.ReadOnly and not Field.Calculated and Field.IsNull then
  begin
    Field.FocusControl;
    DatabaseErrorFmt('Field %s Required', [Field.DisplayName]);
  end;
end;
procedure CheckRequiredFields(const Fields: array of TField);
var
  I: Integer;
begin
  for I := Low(Fields) to High(Fields) do
    CheckRequiredField(Fields[I]);
end;
type
  TDataSetAccess = class(TDataSet);
procedure GotoBookmarkEx(DataSet: TDataSet; const Bookmark: TBookmark; Mode: TResyncMode; ForceScrollEvents: Boolean);
var
  DS: TDataSetAccess;
begin
	if (DataSet <> nil) and (Bookmark <> nil) then
	begin
    DS := TDataSetAccess(DataSet);
		DS.CheckBrowseMode;
		if ForceScrollEvents or (rmCenter in Mode) then DS.DoBeforeScroll;
		DS.InternalGotoBookmark({$IFNDEF RTL240_UP}Pointer{$ENDIF}(Bookmark));
		DS.Resync(Mode);
		if ForceScrollEvents or (rmCenter in Mode) then DS.DoAfterScroll;
	end;
end;
procedure AssignRecord(Source, Dest: TDataSet; ByName: Boolean);
var
  I: Integer;
  F, FSrc: TField;
begin
  if not (Dest.State in dsEditModes) then
    _DBError('Not Editing');
  if ByName then
  begin
    for I := 0 to Source.FieldCount - 1 do
    begin
      F := Dest.FindField(Source.Fields[I].FieldName);
      FSrc := Source.Fields[i];
      if (F <> nil) and (F.DataType <> ftAutoInc) then
      begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
             ftString: F.AsString := FSrc.AsString;
             ftInteger: F.AsInteger := FSrc.AsInteger;
             ftBoolean: F.AsBoolean := FSrc.AsBoolean;
             ftFloat: F.AsFloat := FSrc.AsFloat;
             ftCurrency: F.AsCurrency := FSrc.AsCurrency;
             ftDate: F.AsDateTime := FSrc.AsDateTime;
             ftDateTime: F.AsDateTime := FSrc.AsDateTime;
          else
             F.Value := FSrc.Value;
          end;
      end;
    end;
  end
  else
  begin
    for I := 0 to Min(Source.FieldDefs.Count - 1, Dest.FieldDefs.Count - 1) do
    begin
      F := Dest.FindField(Dest.FieldDefs[I].Name);
      FSrc := Source.FindField(Source.FieldDefs[I].Name);
      if (F <> nil) and (FSrc <> nil) and (F.DataType <> ftAutoInc) then
      begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
             ftString: F.AsString := FSrc.AsString;
             ftInteger: F.AsInteger := FSrc.AsInteger;
             ftBoolean: F.AsBoolean := FSrc.AsBoolean;
             ftFloat: F.AsFloat := FSrc.AsFloat;
             ftCurrency: F.AsCurrency := FSrc.AsCurrency;
             ftDate: F.AsDateTime := FSrc.AsDateTime;
             ftDateTime: F.AsDateTime := FSrc.AsDateTime;
          else
             F.Value := FSrc.Value;
          end;
      end;
    end;
  end;
end;
end.
