unit uRESTDWStorageBinRDW;

interface

uses
  Classes, SysUtils, uRESTDWStorageBase, DB, uRESTDWConsts;

type
  TRESTDWStorageBinRDW = class(TRESTDWStorageBase)
  private
    FFieldTypes : array of integer;
  protected
    procedure SaveRecordToStream(Dataset : TDataset; stream  : TStream);
    procedure LoadRecordFromStream(Dataset : TDataset; stream  : TStream);
  public
    procedure SaveDatasetToStream(dataset : TDataset; var stream : TStream); override;
    procedure LoadDatasetFromStream(dataset : TDataset; stream : TStream); overload; override;
  end;

implementation

uses
  uRESTDWProtoTypes, uRESTDWTools;

{ TRESTDWStorageBinRDW }

procedure TRESTDWStorageBinRDW.LoadDatasetFromStream(dataset: TDataset; stream: TStream);
var
  fc : integer;
  fk : TFieldKind;
  rc : LongInt;
  i : LongInt;
  j : integer;
  s : DWString;
  ft : Byte;
  b : boolean;
  vFieldDef : TFieldDef;
begin
  stream.Position := 0;
  stream.Read(fc,SizeOf(Integer));

  SetLength(FFieldTypes,fc);

  Stream.Read(b, Sizeof(Byte));
  EncodeStrs := b;

  dataset.Close;
  dataset.FieldDefs.Clear;

  for i := 0 to fc-1 do begin
    stream.Read(j,SizeOf(Integer));
    fk := TFieldKind(j);
    vFieldDef := dataset.FieldDefs.AddFieldDef;

    stream.Read(j,SizeOf(Integer));
    SetLength(s,j);
    stream.Read(s[InitStrPos],j);

    vFieldDef.Name := s;

    stream.Read(ft,SizeOf(Byte));
    vFieldDef.DataType := DWFieldTypeToFieldType(ft);
    FFieldTypes[i] := ft;

    stream.Read(j,SizeOf(Integer));
    vFieldDef.Size := j;

    stream.Read(j,SizeOf(Integer));
    if (ft in [dwftFloat, dwftCurrency,dwftBCD,dwftExtended,dwftSingle,dwftFMTBcd]) then
      vFieldDef.Precision := j;

    stream.Read(b,SizeOf(Byte));

    vFieldDef.Required := b;
    if fk = fkInternalCalc Then
      vFieldDef.InternalCalcField := True;
  end;

  stream.Read(rc,SizeOf(LongInt));

  dataset.Open;

  dataset.DisableControls;
  for i := 1 to rc do begin
    dataset.Append;
    LoadRecordFromStream(Dataset,stream);
    dataset.Post;
  end;
  dataset.First;
  dataset.EnableControls;
end;

procedure TRESTDWStorageBinRDW.LoadRecordFromStream(Dataset: TDataset; stream: TStream);
var
  i : integer;
  L : longInt;
  J : integer;
  R : Real;
  E : Extended;
  S : DWString;
  Cr : Currency;
  P : TMemoryStream;
  Bool : boolean;
  vField : TField;
begin
  for i := 0 to Length(FFieldTypes)-1 do begin
    vField := Dataset.Fields[i];
    vField.Clear;

    Stream.Read(Bool, Sizeof(Byte));
    if Bool then // is null
      Continue;

    case FFieldTypes[i] of
      dwftFixedChar,
      dwftWideString,
      dwftString : begin
                  Stream.Read(L, Sizeof(L));
                  S := '';
                  if L > 0 then begin
                    SetLength(S, L);
                    {$IFDEF FPC}
                     Stream.Read(Pointer(S)^, L);
                     if EncodeStrs then
                       S := DecodeStrings(S, csUndefined);
                     S := GetStringEncode(S, csUndefined);
                    {$ELSE}
                     Stream.Read(S[InitStrPos], L);
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
                      Stream.Read(J, Sizeof(Integer));
                      vField.AsInteger := J;
                     End;
      dwftSingle   : begin
                      Stream.Read(R, Sizeof(Real));
                      {$IFDEF FPC}
                       vField.AsFloat := R;
                      {$ELSE}
                       {$IF (CompilerVersion < 22)}
                        vField.AsFloat := R;
                       {$ELSE}
                        vField.AsSingle  := R;
                       {$IFEND}
                      {$ENDIF}
                     end;
      dwftExtended : begin
                      Stream.Read(R, Sizeof(Real));
                      {$IFDEF FPC}
                       vField.AsFloat := R;
                      {$ELSE}
                       {$IF (CompilerVersion < 22)}
                        vField.AsFloat := R;
                       {$ELSE}
                        vField.AsExtended := R;
                       {$IFEND}
                      {$ENDIF}
                     end;
      dwftFloat    : begin
                  Stream.Read(R, Sizeof(Real));
                  vField.AsFloat := R;
      end;
      dwftFMTBcd,
      dwftCurrency,
      dwftBCD     :  begin
                  Stream.Read(Cr, Sizeof(Currency));
                  vField.AsCurrency := Cr;
      end;
      dwftTimeStampOffset,
      dwftDate,
      dwftTime,
      dwftDateTime,
      dwftTimeStamp : begin
                  Stream.Read(R, Sizeof(Real));
                  vField.AsDateTime := R;
      End;
      dwftLongWord,
      dwftLargeint : begin
                  Stream.Read(L, Sizeof(LongInt));
                  {$IF NOT DEFINED(FPC) AND (CompilerVersion < 22)}
                    vField.AsInteger := L;
                  {$ELSE}
                    vField.AsLargeInt := L;
                  {$IFEND}
      end;
      dwftBoolean  : begin
                  Stream.Read(Bool, Sizeof(Byte));
                  vField.AsBoolean := Bool
      End;
      dwftMemo,
      dwftWideMemo,
      dwftStream,
      dwftFmtMemo,
      dwftBlob,
      dwftBytes : begin
                  Stream.Read(L, Sizeof(LongInt));
                  if L > 0 then Begin
                    P := TMemoryStream.Create;
                    try
                      P.CopyFrom(Stream, L);
                      P.Position := 0;
                      TBlobField(vField).LoadFromStream(P);
                    finally
                     P.Free;
                    end;
                  end;
      end;
      else begin
                  Stream.Read(L, Sizeof(L));
                  S := '';
                  if L > 0 then begin
                    SetLength(S, L);
                    {$IFDEF FPC}
                     Stream.Read(Pointer(S)^, L);
                     if EncodeStrs then
                       S := DecodeStrings(S, csUndefined);
                     S := GetStringEncode(S, csUndefined);
                    {$ELSE}
                     Stream.Read(S[InitStrPos], L);
                     if EncodeStrs then
                       S := DecodeStrings(S);
                    {$ENDIF}
                  end;
                  vField.AsString := S;
      end;
    end;
  end;
end;

procedure TRESTDWStorageBinRDW.SaveDatasetToStream(dataset: TDataset; var stream: TStream);
var
  i : integer;
  rc : Longint;
  s : DWString;
  j : integer;
  b : boolean;
  y : byte;

  bm : TBookmark;
begin
  stream.Size := 0;

  if not Dataset.Active then
    Dataset.Open
  else
    Dataset.CheckBrowseMode;
  Dataset.UpdateCursorPos;

  i := Dataset.FieldCount;
  stream.Write(i,SizeOf(integer));

  b := EncodeStrs;
  stream.Write(b,SizeOf(Byte));

  i := 0;
  while i < Dataset.FieldCount do begin
    j := Ord(Dataset.Fields[i].FieldKind);
    stream.Write(j,SizeOf(Integer));

    s := Dataset.Fields[i].DisplayName;
    j := Length(s);
    stream.Write(j,SizeOf(Integer));
    stream.Write(s[InitStrPos],j);

    y := FieldTypeToDWFieldType(Dataset.Fields[i].DataType);
    stream.Write(y,SizeOf(Byte));

    j := Dataset.Fields[i].Size;
    stream.Write(j,SizeOf(Integer));

    j := 0;
    if Dataset.Fields[i].InheritsFrom(TFloatField) then
      j := TFloatField(Dataset.Fields[i]).Precision;

    stream.Write(j,SizeOf(Integer));

    b := Dataset.Fields[i].Required;
    stream.Write(b,SizeOf(Byte));

    i := i + 1;
  end;

  i := stream.Position;
  rc := 0;
  stream.WriteBuffer(rc,SizeOf(Longint));

  bm := dataset.GetBookmark;
  dataset.DisableControls;
  dataset.First;
  rc := 0;
  while not Dataset.Eof do begin
    SaveRecordToStream(dataset,stream);
    dataset.Next;
    rc := rc + 1;
  end;
  dataset.GotoBookmark(bm);
  dataset.FreeBookmark(bm);
  dataset.EnableControls;

  stream.Position := i;
  stream.WriteBuffer(rc,SizeOf(Longint));
  stream.Position := 0;
end;

procedure TRESTDWStorageBinRDW.SaveRecordToStream(Dataset: TDataset; stream: TStream);
var
  i  : integer;
  s  : DWString;
  L  : longint;
  J  : integer;
  R  : Real;
  E  : Extended;
  Cr : Currency;
  P  : TMemoryStream;
  Bool : Boolean;
Begin
  P := nil;
  for i := 0 to Dataset.FieldCount - 1 do begin
    if fkCalculated = Dataset.Fields[I].FieldKind then
      Bool := True
    else
      Bool := Dataset.Fields[I].IsNull;

    Stream.Write(Bool, SizeOf(Byte));
    if Bool then
      Continue;

    case Dataset.Fields[I].DataType Of
      ftFixedChar,
      ftWideString,
      ftString : begin
                  S := Dataset.Fields[I].AsString;
                  if EncodeStrs then
                    S := EncodeStrings(S{$IFDEF FPC}, csUndefined{$ENDIF});
                  L := Length(S);
                  Stream.Write(L, Sizeof(L));
                  {$IFNDEF FPC}
                    if L <> 0 then Stream.Write(S[InitStrPos], L);
                  {$ELSE}
                    if L <> 0 then Stream.Write(S[1], L);
                  {$ENDIF}
      end;
      {$IFDEF COMPILER12_UP}
      ftByte,
      ftShortint : begin
                  J := Dataset.Fields[I].AsInteger;
                  Stream.Write(J, Sizeof(Integer));
      end;
      {$ENDIF}
      ftSmallint,
      ftWord,
      ftInteger,
      ftAutoInc :  Begin
                  J := Dataset.Fields[I].AsInteger;
                  Stream.Write(J, Sizeof(Integer));
      end;
      {$IFNDEF FPC}
        {$IF CompilerVersion >= 21}
          ftSingle   : begin
                      R := Dataset.Fields[I].AsSingle;
                      Stream.Write(R, Sizeof(Real));
          end;
          ftExtended : begin
                      E := Dataset.Fields[I].AsExtended;
                      Stream.Write(E, Sizeof(Extended));
          end;
        {$IFEND}
      {$ENDIF}
      ftFloat    : begin
                  R := Dataset.Fields[I].AsFloat;
                  Stream.Write(R, Sizeof(Real));
      end;
      ftFMTBcd,
      ftCurrency,
      ftBCD     :  begin
                  Cr := Dataset.Fields[I].AsCurrency;
                  Stream.Write(Cr, Sizeof(Currency));
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
                  Stream.Write(R, Sizeof(Real));
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
                  {$IFEND}
                  Stream.Write(L, Sizeof(Longint));
      end;
      ftBoolean  : begin
                  Bool := Dataset.Fields[I].AsBoolean;
                  Stream.Write(Bool, Sizeof(Byte));
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
      ftBlob,
      ftBytes : begin
                  P := TMemoryStream.Create;
                  try
                    TBlobField(Dataset.Fields[I]).SaveToStream(P);
                    L := P.Size;
                    Stream.Write(L, Sizeof(Longint));
                    P.Position := 0;
                    Stream.CopyFrom(P, L);
                  finally
                    FreeAndNil(P);
                  end;
      end;
      else begin
                  S := Dataset.Fields[I].AsString;
                  if EncodeStrs then
                    S := EncodeStrings(S{$IFDEF FPC}, csUndefined{$ENDIF});
                  L := Length(S);
                  Stream.Write(L, Sizeof(L));
                  {$IFNDEF FPC}
                    If L <> 0 Then Stream.Write(S[InitStrPos], L);
                  {$ELSE}
                    If L <> 0 Then Stream.Write(S[1], L);
                  {$ENDIF}
      end;
    end;
  end;
end;

end.
