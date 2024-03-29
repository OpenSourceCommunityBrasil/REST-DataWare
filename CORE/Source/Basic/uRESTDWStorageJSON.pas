unit uRESTDWStorageJSON;

interface

uses
  Classes, SysUtils, DB, uRESTDWConsts, uRESTDWMemoryDataset,
  uRESTDWJson, uRESTDWProtoTypes;

type
  TRESTDWStorageJSON = class(TRESTDWStorageBase)
  private
    FFieldTypes : array of integer;
  protected
    function SaveRecordToStream(Dataset : TDataset) : ansistring;
    procedure LoadRecordFromStream(Dataset : TDataset; json : TJSONArray);
  public
    procedure SaveDatasetToStream(dataset : TDataset; var stream : TStream); override;
    procedure LoadDatasetFromStream(dataset : TDataset; stream : TStream); overload; override;
  end;

implementation

uses
  uRESTDWBasicTypes, uRESTDWTools;

{ TRESTDWStorageBinRDW }

procedure TRESTDWStorageJSON.LoadDatasetFromStream(dataset: TDataset; stream: TStream);
var
  fc : integer;
  fk : TFieldKind;
  rc : LongInt;
  i : LongInt;
  j : integer;
  s : ansistring;
  ft : Byte;
  b : boolean;

  vFieldDef : TFieldDef;
  json : TJSONObject;
  jArr1, jArr2 : TJSONArray;
  arrLen : LongInt;
  sAux : ansistring;
begin
  stream.Position := 0;

  SetLength(sAux,stream.Size);
  stream.Read(sAux[InitStrPos],stream.Size);

  stream.Size := 0; // limpando a memoria

  json := TJSONObject.create(sAux);

  dataset.Close;
  dataset.FieldDefs.Clear;

  jArr1 := TJSONArray(json.get('fields'));

  arrLen := jArr1.length - 1;
  SetLength(FFieldTypes,arrLen+1);

  for i := 0 to arrLen do begin
    jArr2 := TJSONArray(jArr1.get(0));
    j := jArr2.getInt(0);
    fk := TFieldKind(j);

    vFieldDef := dataset.FieldDefs.AddFieldDef;

    s := jArr2.getString(1);
    vFieldDef.Name := s;

    ft := jArr2.getInt(2);
    vFieldDef.DataType := DWFieldTypeToFieldType(ft);
    FFieldTypes[i] := ft;

    j := jArr2.getInt(3);
    vFieldDef.Size := j;

    j := jArr2.getInt(4);
    if (ft in [dwftFloat, dwftCurrency,dwftBCD,dwftExtended,dwftSingle,dwftFMTBcd]) then
      vFieldDef.Precision := j;

    b := jArr2.getBoolean(5);
    vFieldDef.Required := b;

    if fk = fkInternalCalc Then
      vFieldDef.InternalCalcField := True;

    jArr1.delete(0);
  end;

  jArr1 := TJSONArray(json.get('lines'));

  dataset.Open;
  dataset.DisableControls;
  arrLen := jArr1.length - 1;

  for i := 0 to arrLen do begin
    jArr2 := TJSONArray(jArr1.get(0));

    dataset.Append;
    LoadRecordFromStream(Dataset,jArr2);
    dataset.Post;

    jArr1.delete(0);
  end;
  dataset.First;
  dataset.EnableControls;

  FreeAndNil(json);
end;

procedure TRESTDWStorageJSON.LoadRecordFromStream(Dataset : TDataset; json : TJSONArray);
var
  i : integer;
  L : longInt;
  J : integer;
  R : Real;
  E : Extended;
  S : ansistring;
  Cr : Currency;
  P : TStringStream;
  Bool : boolean;
  vField : TField;
begin
  for i := 0 to Length(FFieldTypes)-1 do begin
    vField := Dataset.Fields[i];
    vField.Clear;

    Bool := json.isNull(i);
    if Bool then // is null
      Continue;

    case FFieldTypes[i] of
      dwftFixedChar,
      dwftWideString,
      dwftString : begin
                  S := json.getString(i);
                  if S <> '' then begin
                    {$IFDEF FPC}
                     if EncodeStrs then
                       S := DecodeStrings(S);
                     S := GetStringEncode(S, FDatabaseCharSet);
                    {$ELSE}
                     if EncodeStrs then
                       S := DecodeStrings(S);
                    {$ENDIF}
                  end;
                  vField.AsString := S;
      end;
      dwftByte,
      dwftShortint,
      dwftSmallint,
      dwftWord,
      dwftInteger,
      dwftAutoInc :  Begin
                  J := json.getInt(i);
                  vField.AsInteger := J;
      end;
      dwftSingle   : begin
                  R := json.getDouble(i);
                  vField.AsSingle := R;
      end;
      dwftExtended : begin
                  R := json.getDouble(i);
                  vField.AsExtended := R;
      end;
      dwftFloat    : begin
                  R := json.getDouble(i);
                  vField.AsFloat := R;
      end;
      dwftFMTBcd,
      dwftCurrency,
      dwftBCD     :  begin
                  Cr := json.getDouble(i);
                  vField.AsCurrency := Cr;
      end;
      dwftTimeStampOffset,
      dwftDate,
      dwftTime,
      dwftDateTime,
      dwftTimeStamp : begin
                  R := json.getDouble(i);
                  vField.AsDateTime := R;
      End;
      dwftLongWord,
      dwftLargeint : begin
                  L := json.getInt64(i);
                  {$IF NOT DEFINED(FPC) AND (CompilerVersion < 22)}
                    vField.AsInteger := L;
                  {$ELSE}
                    vField.AsLargeInt := L;
                  {$IFEND}
      end;
      dwftBoolean  : begin
                  Bool := json.getBoolean(i);
                  vField.AsBoolean := Bool
      End;
      dwftMemo,
      dwftWideMemo,
      dwftStream,
      dwftFmtMemo,
	  dwftOraClob,
      dwftBlob,
	  dwftOraBlob,
      dwftBytes : begin
                  S := json.getString(i);
                  if S <> '' then Begin
                    S := DecodeStrings(S);
                    P := TStringStream.Create(S);
                    try
                      P.Position := 0;
                      TBlobField(vField).LoadFromStream(P);
                    finally
                      P.Free;
                    end;
                  end;
      end;
      else begin
                  S := json.getString(i);
                  if S <> '' then begin
                    {$IFDEF FPC}
                     if EncodeStrs then
                       S := DecodeStrings(S);
                     S := GetStringEncode(S, FDatabaseCharSet);
                    {$ELSE}
                     if EncodeStrs then
                       S := DecodeStrings(S);
                    {$ENDIF}
                  end;
                  vField.AsString := S;
      end;
    end;
  end;
end;

procedure TRESTDWStorageJSON.SaveDatasetToStream(dataset: TDataset; var stream: TStream);
var
  i : integer;
  s : ansistring;
  j : integer;
  b : boolean;
  y : byte;

  bm : TBookmark;

  sAux : ansistring;
begin
  stream.Size := 0;

  sAux := '{"fields":[';
  stream.Write(sAux[InitStrPos],Length(sAux));

  i := 0;
  while i < Dataset.FieldCount do begin
    sAux := '';
    if i > 0 then
      sAux := sAux + ',';
    sAux := sAux + '[';
    j := Ord(Dataset.Fields[i].FieldKind);
    sAux := sAux + IntToStr(j);

    s := Dataset.Fields[i].DisplayName;
    sAux := sAux + ',"' + s + '"';

    y := FieldTypeToDWFieldType(Dataset.Fields[i].DataType);
    sAux := sAux + ',' + IntToStr(y);

    j := Dataset.Fields[i].Size;
    sAux := sAux + ',' + IntToStr(j);

    j := 0;
    if Dataset.Fields[i].InheritsFrom(TFloatField) then
      j := TFloatField(Dataset.Fields[i]).Precision;
    sAux := sAux + ',' + IntToStr(j);

    b := Dataset.Fields[i].Required;
    if b then
      sAux := sAux + ',true'
    else
      sAux := sAux + ',false';

    sAux := sAux + ']';
    stream.Write(sAux[InitStrPos],Length(sAux));

    i := i + 1;
  end;
  sAux := '],"lines":[';
  stream.Write(sAux[InitStrPos],Length(sAux));

  bm := dataset.GetBookmark;
  dataset.DisableControls;
  dataset.First;
  i := 0;
  while not Dataset.Eof do begin
    sAux := SaveRecordToStream(dataset);
    sAux := '[' + sAux + ']';
    if i > 0 then
      sAux := ',' + sAux;
    stream.Write(sAux[InitStrPos],Length(sAux));

    dataset.Next;
    i := i + 1;
  end;
  dataset.GotoBookmark(bm);
  dataset.FreeBookmark(bm);
  dataset.EnableControls;

  sAux := ']}';
  stream.Write(sAux[InitStrPos],Length(sAux));
  stream.Position := 0;
end;

function TRESTDWStorageJSON.SaveRecordToStream(Dataset : TDataset) : ansistring;
var
  i  : integer;
  s  : ansistring;
  L  : longint;
  J  : integer;
  R  : Extended;
  E  : Extended;
  Cr : Currency;
  P  : TStringStream;
  Bool : Boolean;

  function ftos(fl : Extended) : ansistring;
  var
    ps : integer;
    ss : ansistring;
  begin
    ss := FloatToStr(fl);
    ps := Pos(',',ss);
    if ps > 0 then begin
      Delete(ss,ps,1);
      Insert('.',ss,ps);
    end;
    ftos := ss;
  end;
Begin
  P := nil;
  Result := '';
  for i := 0 to Dataset.FieldCount - 1 do begin
    if fkCalculated = Dataset.Fields[I].FieldKind then
      Bool := True
    else
      Bool := Dataset.Fields[I].IsNull;

    if Result <> '' then
      Result := Result + ',';

    if Bool then begin
      Result := Result + 'null';
      Continue;
    end;

    case Dataset.Fields[I].DataType Of
      ftFixedChar,
      ftWideString,
      ftString : begin
                  S := Dataset.Fields[I].AsString;
                  if EncodeStrs then
                    S := EncodeStrings(S);
                  Result := Result + '"' + S + '"';

      end;
      {$IFDEF COMPILER12_UP}
      ftByte,
      ftShortint : begin
                  J := Dataset.Fields[I].AsInteger;
                  Result := Result + IntToStr(J);
      end;
      {$ENDIF}
      ftSmallint,
      ftWord,
      ftInteger,
      ftAutoInc :  Begin
                  J := Dataset.Fields[I].AsInteger;
                  Result := Result + IntToStr(J);
      end;
      {$IFNDEF FPC}
        {$IF CompilerVersion >= 21}
          ftSingle   : begin
                      R := Dataset.Fields[I].AsSingle;
                      Result := Result + ftos(R);
          end;
          ftExtended : begin
                      E := Dataset.Fields[I].AsExtended;
                      Result := Result + ftos(E);
          end;
        {$IFEND}
      {$ENDIF}
      ftFloat    : begin
                  R := Dataset.Fields[I].AsFloat;
                  Result := Result + ftos(R);
      end;
      ftFMTBcd,
      ftCurrency,
      ftBCD     :  begin
                  Cr := Dataset.Fields[I].AsCurrency;
                  Result := Result + ftos(Cr);
      end;
      {$IFNDEF FPC}
        {$IF CompilerVersion >= 21}
          ftTimeStampOffset,
        {$IFEND}
      {$ENDIF}
      ftDate,
      ftTime,
      ftDateTime,
      ftTimeStamp : begin
                  R := Dataset.Fields[I].AsDateTime;
                  Result := Result + ftos(R);
      End;
      {$IFNDEF FPC}
        {$IF CompilerVersion >= 21}
          ftLongWord,
        {$IFEND}
      {$ENDIF}
      ftLargeint : begin
                  {$IF NOT DEFINED(FPC) AND (CompilerVersion < 22)}
                    L := Dataset.Fields[I].AsInteger;
                  {$ELSE}
                    L := Dataset.Fields[I].AsLargeInt;
                  {$ENDIF}
                  Result := Result + IntToStr(L);
      end;
      ftBoolean  : begin
                  Bool := Dataset.Fields[I].AsBoolean;
                  if Bool then
                    Result := Result + 'true'
                  else
                    Result := Result + 'false';
      End;
      ftMemo,
      {$IFNDEF FPC}
        {$IF CompilerVersion > 21}
          ftWideMemo,
          ftStream,
        {$IFEND}
      {$ELSE}
        ftWideMemo,
      {$ENDIF}
      ftFmtMemo,
	  ftOraBlob,
      ftBlob,	  
      ftBytes : begin
                  P := TStringStream.Create;
                  try
                    TBlobField(Dataset.Fields[I]).SaveToStream(P);
                    S := EncodeStrings(P.DataString);
                    Result := Result + '"' + S + '"';
                  finally
                    FreeAndNil(P);
                  end;
      end;
      else begin
                  S := Dataset.Fields[I].AsString;
                  if EncodeStrs then
                    S := EncodeStrings(S);
                  Result := Result + '"' + S + '"';
      end;
    end;
  end;
end;

end.
