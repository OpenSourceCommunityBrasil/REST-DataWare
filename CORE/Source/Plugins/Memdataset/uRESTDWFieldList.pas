unit uRESTDWFieldList;

interface

uses
  Classes, Db, SysUtils, uRESTDWCustom_Inherited;

type

  TFtFieldList = class
  private
    FCount: integer;
    FPrimaryCount: integer;

  public
    FieldCount: integer;

    FieldNo: array of integer;
//    FieldOfs: array of integer;
    Options: array of TkbmifoOptions;
    LocateOptions: TLocateOptions;
    Fields: array of TField;

    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const ADataSet: TCustomFreeTable; const AField: TField; const AValue: TkbmifoOptions): integer;
    procedure Clear; virtual;
    function IndexOf(Item: TField): integer;
    procedure AssignTo(AFieldList: TFtFieldList);
    procedure MergeOptionsTo(AFieldList: TFtFieldList); // Must be identical fieldlists.
    procedure DefineAdditionalOrderFields(ADataSet: TCustomFreeTable; AFieldList: TFtFieldList);
    procedure ClearOptions;
    function GetAsString: string;

    procedure SetOptions(ADataSet: TCustomFreeTable; AOptions: TkbmifoOption; AFieldNames: string);
    function FindField(const AFieldName: string): TField;
    function StartsWith(AList: TFtFieldList; const ASameCase: boolean; const AOnlyPrimary: boolean): boolean;
    function IsEqualTo(AList: TFtFieldList; const ASameCase: boolean; const AOnlyPrimary: boolean): boolean;
    procedure Build(ADataSet: TCustomFreeTable; const AFieldNames: string; const AAggregateFieldNaming: boolean = false);

    property Count: integer read FCount;
    property PrimaryCount: integer read FPrimaryCount;
  end;


implementation


constructor TFtFieldList.Create;
begin
  FCount := 0;
end;

destructor TFtFieldList.Destroy;
begin
  inherited;
end;

// Build field list from list of fieldnames.
// fld1;fld2;fld3...
// Each field can contain options:
// fldname:options
// Options can be either C for Caseinsensitive or D for descending or a combination.
procedure TFtFieldList.Build(ADataSet: TCustomFreeTable; const AFieldNames: string;
  const AAggregateFieldNaming: boolean = false);
const
  lIndexErr = 'Can''t index on field %s';
var
  p, p1: integer;
  fld: TField;
  s, sname, sopt: string;
  opt: TkbmifoOptions;
begin
  Clear;
  p := 1;
  while p <= length(AFieldNames) do begin
    // Extract fieldname and options from list of fields.
    s := ExtractFieldName(AFieldNames, p);
    p1 := Pos(':', s);
    opt := [];
    if p1 <= 0 then
      sname := s
    else begin
      sname := copy(s, 1, p1 - 1);
      sopt := UpperCase(copy(s, p1 + 1, length(s)));
      opt := [];//ADataSet.GetAggregateFieldOption(sopt);
      if opt = [] then
        opt := ADataSet.GetExtractFieldOption(sopt);
      if opt = [] then begin
        if Pos('C', sopt) > 0 then
          Include(opt, mtifoCaseInsensitive);
        if Pos('D', sopt) > 0 then
          Include(opt, mtifoDescending);
        if Pos('N', sopt) > 0 then
          Include(opt, mtifoIgnoreNull);
        if Pos('P', sopt) > 0 then
          Include(opt, mtifoPartial);
        if Pos('L', sopt) > 0 then
          Include(opt, mtifoIgnoreLocale);
        if Pos('S', sopt) > 0 then
          Include(opt, mtifoIgnoreNonSpace);
        if Pos('K', sopt) > 0 then
          Include(opt, mtifoIgnoreKanatype);
        if Pos('I', sopt) > 0 then
          Include(opt, mtifoIgnoreSymbols);
        if Pos('W', sopt) > 0 then
          Include(opt, mtifoIgnoreWidth);
      end else if AAggregateFieldNaming then
        sname := '';//ADataSet.GetAggregateFieldName(sname, opt);
    end;
    fld := ADataSet.FieldByName(sname);
    if (fld.FieldKind in [fkData, fkInternalCalc, fkCalculated, fkLookup]) and
      (fld.DataType in (ftSupported - ftBlobTypes{kbmSupportedFieldTypes - kbmBinaryTypes})) then
      Add(ADataSet, fld, opt)
    else
      DatabaseErrorFmt(lIndexErr, [fld.DisplayName]);
    if fld.FieldKind = fkCalculated then
      ADataSet.RecalcOnIndex := True;
  end;

  FPrimaryCount := Count;
end;

// Compare two field lists.
// Returns true if they are exactly equal, otherwise false.
function TFtFieldList.IsEqualTo(AList: TFtFieldList; const ASameCase: boolean; const AOnlyPrimary: boolean): boolean;
var
  I, J: Integer;
begin
  Result := false;

  if AOnlyPrimary then
    J := AList.FPrimaryCount
  else
    J := AList.Count;
  if Count < J then
    exit;

  for I := 0 to J - 1 do
    if (Fields[I] <> AList.Fields[I]) or
      (ASameCase and ((mtifoCaseInsensitive in Options[I]) <> (mtifoCaseInsensitive in AList.Options[I]))) then
      exit;
  Result := true;
end;

// Compare two field lists.
// Returns true if list2 is contained in list1, otherwise false.
function TFtFieldList.StartsWith(AList: TFtFieldList; const ASameCase: boolean; const AOnlyPrimary: boolean): boolean;
var
  I, J: Integer;
begin
  Result := false;

  if AOnlyPrimary then
    J := AList.FPrimaryCount
  else
    J := AList.Count;
  if Count < J then
    exit;

  for I := J downto 0 do
    if (Fields[I] <> AList.Fields[I]) or
      (ASameCase and ((mtifoCaseInsensitive in Options[I]) <> (mtifoCaseInsensitive in AList.Options[I]))) then
      exit;
  Result := true;
end;

// Find field from list.
function TFtFieldList.FindField(const AFieldName: string): TField;
var
  fld: TField;
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do begin
    fld := Fields[I];
    if fld.FieldName = AFieldName then begin
      Result := fld;
      break;
    end;
  end;
end;

// Setup options for specific fields in the fieldlist.
procedure TFtFieldList.SetOptions(ADataSet: TCustomFreeTable; AOptions: TkbmifoOption; AFieldNames: string);
var
  I, J: Integer;
  lst: TFtFieldList;
  b: boolean;
begin
  // Set flags.
  lst := TFtFieldList.Create;
  try
    lst.Build(ADataSet, AFieldNames);
    for I := 0 to Count - 1 do begin
      b := false;
      for J := 0 to lst.Count - 1 do
        if lst.Fields[J] = Fields[I] then begin
          b := true;
          break;
        end;

      if b then
        Include(Options[I], AOptions)
      else
        Exclude(Options[I], AOptions);
    end;
  finally
    lst.Free;
  end;
end;

function TFtFieldList.Add(const ADataSet: TCustomFreeTable; const AField: TField; const AValue: TkbmifoOptions): integer;
begin
  Result := FCount;
  if length(Fields) <= FCount then begin
    SetLength(Fields, FCount + 20);
    SetLength(Options, FCount + 20);
//    SetLength(FieldOfs, FCount + 20);
    SetLength(FieldNo, FCount + 20);
  end;

  Fields[FCount] := AField;
  Options[FCount] := AValue;
//  FieldOfs[FCount] := ADataSet.FCommon.GetFieldDataOffset(AField);
  FieldNo[FCount] := AField.FieldNo;
  inc(FCount);
end;

procedure TFtFieldList.Clear;
begin
  FCount := 0;
  SetLength(Fields, 20);
  SetLength(Options, 20);
//  SetLength(FieldOfs, 20);
  SetLength(FieldNo, 20);
end;

function TFtFieldList.IndexOf(Item: TField): integer;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do begin
    if Fields[I] = Item then begin
      Result := I;
      exit;
    end;
  end;
  Result := -1;
end;

procedure TFtFieldList.AssignTo(AFieldList: TFtFieldList);
var
  I: Integer;
begin
  AFieldList.Clear;
  for I := 0 to Count - 1 do begin
    AFieldList.Fields[I] := Fields[I];
    AFieldList.Options[I] := Options[I];
//    AFieldList.FieldOfs[I] := FieldOfs[I];
    AFieldList.FieldNo[I] := FieldNo[I];
  end;
  AFieldList.FCount := FCount;
  AFieldList.FPrimaryCount := FPrimaryCount;
end;

procedure TFtFieldList.MergeOptionsTo(AFieldList: TFtFieldList);
var
  I: Integer;
  n: Integer;
begin
  n := FCount;
  if n > AFieldList.FCount then
    n := AFieldList.FCount;
  for I := 0 to n - 1 do
    AFieldList.Options[I] := AFieldList.Options[I] + Options[I];
end;

procedure TFtFieldList.DefineAdditionalOrderFields(ADataSet: TCustomFreeTable; AFieldList: TFtFieldList);
var
  I: integer;
  fld: TField;
  ifo: TkbmifoOptions;
begin
  for I := 0 to AFieldList.Count - 1 do begin
    fld := AFieldList.Fields[I];
    if IndexOf(fld) < 0 then begin
      ifo := AFieldList.Options[I];
      Add(ADataSet, fld, ifo);
    end;
  end;

end;

procedure TFtFieldList.ClearOptions;
var
  I: Integer;
  n: Integer;
begin
  n := Count;
  for I := 0 to n - 1 do
    Options[I] := [];
end;

function TFtFieldList.GetAsString: string;
var
  I: Integer;
  s, a: string;
begin
  s := '';
  a := '';
  for I := 0 to FCount - 1 do begin
    s := s + a + Fields[I].FieldName;
    a := ';';
  end;
  Result := s;
end;

end.
