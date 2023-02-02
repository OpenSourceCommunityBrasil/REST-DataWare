unit uRESTDWStorageBin;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

interface

uses
  Classes, SysUtils, uRESTDWMemoryDataset, DB, Variants, uRESTDWConsts;

 Type
  TRESTDWStorageBinRDW = Class(TRESTDWStorageBase)
  Private
   FFieldTypes : Array of integer;
   FFieldNames : Array of String;
  Protected
   Procedure SaveRecordToStream       (Dataset    : TDataset;
                                       stream     : TStream);
   Procedure LoadRecordFromStream     (Dataset    : TDataset;
                                       stream     : TStream);
   Function  SaveRecordDWMemToStream  (Dataset    : IRESTDWMemTable;
                                       stream     : TStream) : Longint;
   Procedure LoadRecordDWMemFromStream(Dataset    : IRESTDWMemTable;
                                       stream     : TStream);
   Procedure SaveDWMemToStream        (dataset    : IRESTDWMemTable;
                                       Var stream : TStream); Override;
   Procedure LoadDWMemFromStream      (dataset    : IRESTDWMemTable;
                                       stream     : TStream); Override;
   Procedure SaveDatasetToStream      (dataset    : TDataset;
                                       Var stream : TStream); Override;
   Procedure LoadDatasetFromStream    (dataset    : TDataset;
                                       stream     : TStream); Override;
  End;

Implementation

uses
  uRESTDWProtoTypes, uRESTDWBufferBase, uRESTDWTools, FmtBCD {$IFNDEF FPC}, SqlTimSt{$ENDIF};

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
  y : byte;
  vFieldDef : TFieldDef;
  fldAttrs  : array of byte;
begin
  stream.Position := 0;
  stream.Read(fc,SizeOf(Integer));

  SetLength(FFieldTypes, fc);
  SetLength(fldAttrs,    fc);
  SetLength(FFieldNames, fc);
  Stream.Read(b, Sizeof(Byte));
  EncodeStrs := b;

  dataset.Close;
  dataset.FieldDefs.Clear;
  For i := 0 to fc-1 Do
   Begin
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
    FFieldNames[I] := s;
    stream.Read(j,SizeOf(Integer));
    vFieldDef.Size := j;

    stream.Read(j,SizeOf(Integer));
    if (ft in [dwftFloat, dwftCurrency,dwftExtended,dwftSingle]) then begin
      vFieldDef.Precision := j;
    end
    else if (ft in [dwftBCD, dwftFMTBcd]) then begin
      vFieldDef.Size := 0;
      vFieldDef.Precision := 0;
    end;

    stream.Read(y,SizeOf(Byte));
    fldAttrs[i] := y;

    vFieldDef.Required := y and 1 > 0;

    if fk = fkInternalCalc Then
      vFieldDef.InternalCalcField := True;
   End;
  stream.Read(rc,SizeOf(LongInt));
  dataset.Open;
  For i := 0 to fc-1 Do
   Begin
    If dataset.FindField(FFieldNames[I]) <> Nil Then
     Begin
      If fldAttrs[i] And 2 > 0  Then
       dataset.Fields[i].ProviderFlags := dataset.Fields[i].ProviderFlags + [pfInUpdate];
      If fldAttrs[i] and 4 > 0  Then
       dataset.Fields[i].ProviderFlags := dataset.Fields[i].ProviderFlags + [pfInWhere];
      If fldAttrs[i] And 8 > 0  Then
       dataset.Fields[i].ProviderFlags := dataset.Fields[i].ProviderFlags + [pfInKey];
      If fldAttrs[i] And 16 > 0 Then
        dataset.Fields[i].ProviderFlags := dataset.Fields[i].ProviderFlags + [pfHidden];
      {$IFDEF FPC}
       If fldAttrs[i] And 32 > 0 Then
        dataset.Fields[i].ProviderFlags := dataset.Fields[i].ProviderFlags + [pfRefreshOnInsert];
       If fldAttrs[i] And 64 > 0 Then
        dataset.Fields[i].ProviderFlags := dataset.Fields[i].ProviderFlags + [pfRefreshOnUpdate];
      {$ENDIF}
     End;
   End;
  dataset.DisableControls;
  For i := 1 to rc Do
   Begin
    dataset.Append;
    LoadRecordFromStream(Dataset,stream);
    dataset.Post;
   End;
  dataset.First;
  dataset.EnableControls;
end;

procedure TRESTDWStorageBinRDW.LoadDWMemFromStream(dataset: IRESTDWMemTable;
  stream: TStream);
var
  fc : integer;
  fk : TFieldKind;
  rc : LongInt;
  i : LongInt;
  j : integer;
  s : DWString;
  ft : Byte;
  b : boolean;
  y : byte;
  vFieldDef : TFieldDef;
  ds : TRESTDWMemTable;
  fldAttrs : array of byte;
Begin
 ds := TRESTDWMemTable(dataset.GetDataset);
 stream.Position := 0;
 stream.Read(fc, SizeOf(Integer));
 SetLength(FFieldTypes, fc);
 SetLength(fldAttrs, fc);
 SetLength(FFieldNames, fc);
 Stream.Read(b, Sizeof(Byte));
 EncodeStrs := b;
 ds.ClearBuffer;
 If ds.Active Then
  Begin
   ds.CancelChanges;
   ds.Close;
  End;
 If ds.FieldDefs.Count > 0 Then
  ds.FieldDefs.Clear;
 For i := 0 To fc-1 Do
  Begin
   stream.Read(j,SizeOf(Integer));
   fk := TFieldKind(j);
   vFieldDef := ds.FieldDefs.AddFieldDef;
   stream.Read(j,SizeOf(Integer));
   SetLength(s,j);
   stream.Read(s[InitStrPos],j);
   vFieldDef.Name := s;
   FFieldNames[I] := s;
   stream.Read(ft,SizeOf(Byte));
   vFieldDef.DataType := DWFieldTypeToFieldType(ft);
   FFieldTypes[i] := ft;
   stream.Read(j,SizeOf(Integer));
   vFieldDef.Size := j;
   stream.Read(j,SizeOf(Integer));

   if (ft in [dwftFloat, dwftCurrency,dwftExtended,dwftSingle]) then
    vFieldDef.Precision := j
   Else if (ft in [dwftBCD, dwftFMTBcd]) then begin
      vFieldDef.Size := 0;
      vFieldDef.Precision := 0;
    end;

    stream.Read(y,SizeOf(Byte));

    vFieldDef.Required := y and 1 > 0;

    if fk = fkInternalCalc Then
      vFieldDef.InternalCalcField := True;
  end;

  ds.Open;
  For i := 0 to fc-1 Do
   Begin
    If ds.FindField(FFieldNames[I]) <> Nil Then
     Begin
      If fldAttrs[i] And 2 > 0  Then
       ds.Fields[i].ProviderFlags := ds.Fields[i].ProviderFlags + [pfInUpdate];
      If fldAttrs[i] and 4 > 0  Then
       ds.Fields[i].ProviderFlags := ds.Fields[i].ProviderFlags + [pfInWhere];
      If fldAttrs[i] And 8 > 0  Then
       ds.Fields[i].ProviderFlags := ds.Fields[i].ProviderFlags + [pfInKey];
      If fldAttrs[i] And 16 > 0 Then
        ds.Fields[i].ProviderFlags := ds.Fields[i].ProviderFlags + [pfHidden];
      {$IFDEF FPC}
       If fldAttrs[i] And 32 > 0 Then
        ds.Fields[i].ProviderFlags := ds.Fields[i].ProviderFlags + [pfRefreshOnInsert];
       If fldAttrs[i] And 64 > 0 Then
        ds.Fields[i].ProviderFlags := ds.Fields[i].ProviderFlags + [pfRefreshOnUpdate];
      {$ENDIF}
     End;
   End;
  ds.DisableControls;
  LoadRecordDWMemFromStream(dataset,stream);
  ds.EnableControls;
  ds.AfterLoad;
end;

procedure TRESTDWStorageBinRDW.LoadRecordDWMemFromStream(Dataset: IRESTDWMemTable;
  stream: TStream);
var
  i: DWInteger;
  b: DWInteger;
  rc: DWInteger;
  fc: DWInteger;

  aField: TField;
  aIndex: DWInteger;
  aDataType: TFieldType;
  vMemTable: TRESTDWMemTable;
  vActualRecord: TJvMemoryRecord;

  pData: {$IFDEF FPC} PAnsiChar {$ELSE} PByte {$ENDIF};
  pActualRecord: PJvMemBuffer;

  vInt: DWInteger;
  vLength: Word;
  vBoolean: boolean;
  vInt64: DWInt64;
  vSingle: Single;
  vDouble: Double;
  vFloat: DWFloat;
  vString: DWString;
  vCurrency: Currency;
  vTimeStamp: {$IFDEF FPC} TTimeStamp {$ELSE} TSQLTimeStamp {$ENDIF};
  vBCD: TBcd;
  vBytes: TRESTDWBytes;
  vDateTimeRec: TDateTimeRec;
  vByte: Byte;
  {$IFNDEF FPC}
    {$IF CompilerVersion >= 21}
  vTimeStampOffset: TSQLTimeStampOffset;
    {$IFEND}
  {$ENDIF}
Begin
  pActualRecord := nil;

  vMemTable := TRESTDWMemTable(Dataset.GetDataset);

  stream.Read(rc, SizeOf(rc));

  rc := rc - 1;

  fc := Length(FFieldNames);

  fc := fc - 1;

  for i := 0 to rc do
  begin
    pActualRecord := PJvMemBuffer(Dataset.AllocRecordBuffer);

    Dataset.InternalAddRecord(pActualRecord, True);

    vActualRecord := Dataset.GetMemoryRecord(i);

    for b := 0 To fc do
    begin
      aField := vMemTable.FindField(FFieldNames[b]);

      If aField <> Nil Then
      Begin
        aIndex := aField.FieldNo - 1;

        If (aIndex < 0) Then
          Continue;
      End
      Else
        aDataType := TFieldType(FFieldTypes[b]);

      stream.Read(vBoolean, SizeOf(Byte));

      if (pActualRecord <> Nil) then
      begin
        If aField <> Nil Then
        Begin
          aDataType := aField.DataType;

          if Dataset.DataTypeSuported(aDataType) then
          begin
            if Dataset.DataTypeIsBlobTypes(aDataType) then
              pData := Pointer(@PMemBlobArray(pActualRecord + Dataset.GetOffSetsBlobs)
                ^[aField.Offset])
              // Pointer(@PMemBlobArray(vActualRecord.Blobs)^[ds.Fields[B].Offset])
            else
              pData := Pointer(pActualRecord + Dataset.GetOffSets(aIndex));
          end;
        End;
        if (pData <> nil) Or (aField = Nil) Then
        begin
          // WIDE STRING
          if (aDataType in FieldGroupWideChar) then
          begin
            If aField <> Nil Then
            Begin
              vLength := Dataset.GetCalcFieldLen(aField.DataType, aField.Size);
              {$IFDEF FPC}
              FillChar(PData^, vLength, #0);
              {$ELSE}
              FillChar(pData^, vLength, 0);
              {$ENDIF}
            End;
            If Not vBoolean Then
            Begin
              stream.Read(vInt64, SizeOf(vInt64));

              vString := '';

              If vInt64 > 0 Then
              Begin
                SetLength(vString, vInt64);
                {$IFDEF FPC}
                stream.Read(Pointer(vString)^, vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString, csUndefined);

                vString := GetStringEncode(vString, csUndefined);

                vInt64 := (Length(vString) + 1) * SizeOf(DWChar);

                If aField <> Nil Then
                  Move(Pointer(WideString(vString))^, PData^, vInt64);
                {$ELSE}
                stream.Read(vString[InitStrPos], vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString);

                vInt64 := (Length(vString) + 1) * SizeOf(DWChar);

                If aField <> Nil Then
                  Move(WideString(vString)[InitStrPos], pData^, vInt64);
                {$ENDIF}
              End;
            End;
          End
          // STRING
          else if (aDataType in FieldGroupChar) then
          Begin
            If aField <> Nil Then
            Begin
              vLength := Dataset.GetCalcFieldLen(aField.DataType, aField.Size);
              {$IFDEF FPC}
              FillChar(PData^, vLength, #0);
              {$ELSE}
              FillChar(pData^, vLength, 0);
              {$ENDIF}
            End;
            If Not vBoolean Then
            Begin
              stream.Read(vInt64, SizeOf(vInt64));

              vString := '';

              If vInt64 > 0 Then
              Begin
                SetLength(vString, vInt64);
                {$IFDEF FPC}
                stream.Read(Pointer(vString)^, vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString, csUndefined);

                vString := GetStringEncode(vString, csUndefined);

                If aField <> Nil Then
                  Move(Pointer(vString)^, PData^, Length(vString));
                {$ELSE}
                stream.Read(vString[InitStrPos], vInt64);

                If EncodeStrs Then
                  vString := DecodeStrings(vString);

                If aField <> Nil Then
                  Move(vString[InitStrPos], pData^, Length(vString));
                {$ENDIF}
              End;
            End;
          End
          // CARDINAL
          else if (aDataType in FieldGroupCardinal) then
          Begin
            If Not vBoolean Then
            Begin
              If aField <> Nil Then
                stream.Read(pData^, SizeOf(Cardinal))
              Else
                stream.Read(vInt, SizeOf(Cardinal));
            End
            Else
              FillChar(PData^, 1, 'S');
          End
          // INTEGER
          else if (aDataType in FieldGroupInt) then
          Begin
            If Not vBoolean Then
            Begin
              If aField <> Nil Then
                stream.Read(pData^, SizeOf(DWInteger))
              Else
                stream.Read(vInt, SizeOf(DWInteger));
            End
            Else
              FillChar(PData^, 1, 'S');
          End
          // SINGLE
          else if (aDataType in FieldGroupSingle) then
          Begin
            If Not vBoolean Then
            Begin
              If aField <> Nil Then
                stream.Read(pData^, SizeOf(Single))
              Else
                stream.Read(vSingle, SizeOf(Single));
            End
            Else
              FillChar(PData^, 1, 'S');
          End
          // EXTENDED
          else if (aDataType in FieldGroupExtended) then
          Begin
            If Not vBoolean Then
            Begin
              If aField <> Nil Then
                stream.Read(pData^, SizeOf(Double))
              Else
                stream.Read(vDouble, SizeOf(Double));
            End
            Else
              FillChar(PData^, 1, 'S');
          End
          // FLOAT
          else if (aDataType in FieldGroupFloat) then
          Begin
            If Not vBoolean Then
            Begin
              If aField <> Nil Then
                stream.Read(pData^, SizeOf(DWFloat))
              Else
                stream.Read(vFloat, SizeOf(DWFloat));
            End
            Else
              FillChar(pData^, 1, 'S');
          End
          // BCD
          else if (aDataType in FieldGroupBCD) then
          Begin
            If Not vBoolean Then
            Begin
              stream.Read(vBCD, SizeOf(TBcd));

              If aField <> Nil Then
              Begin
                Move(vBCD, pData^, SizeOf(vBCD));
              End
              Else
                stream.Read(vBCD, SizeOf(TBcd));
            End
            Else
              FillChar(PData^, 1, 'S');
          End
          // CURRENCY
          else if (aDataType in FieldGroupCurrency) then
          Begin
            If Not vBoolean Then
            Begin
              If aField <> Nil Then
                stream.Read(pData^, SizeOf(Currency))
              Else
                stream.Read(vCurrency, SizeOf(Currency));
            End
            Else
              FillChar(PData^, 1, 'S');
          End
          // DATE TIME
          else if (aDataType in FieldGroupDateTime) then
          Begin
            If aField <> Nil Then
            Begin
              If Not vBoolean Then
              Begin
                stream.Read(vFloat, SizeOf(DWFloat));

                {$IFDEF FPC}
                vDateTimeRec := DateTimeToDateTimeRec(aDataType, TDateTime(vFloat));

                Move(vDateTimeRec, PData^, SizeOf(vDateTimeRec));
                {$ELSE}
                Case aDataType Of
                  ftDate:
                    vDateTimeRec.Date := DateTimeToTimeStamp(vFloat).Date;
                  ftTime:
                    vDateTimeRec.Time := DateTimeToTimeStamp(vFloat).Time;
                Else
                  vDateTimeRec.DateTime := TimeStampToMSecs(DateTimeToTimeStamp(vFloat));
                End;
                Move(vDateTimeRec, pData^, SizeOf(vDateTimeRec));
                {$ENDIF}
              End
              Else
                FillChar(PData^, 1, 'S');
            End
            Else
            Begin
              If Not vBoolean Then
                stream.Read(vFloat, SizeOf(DWFloat));
            End;
          End
          // TIMESTAMP OFFSET
          else if (aDataType in FieldGroupTimeStampOffSet) then
          begin
            If Not vBoolean Then
            Begin
              stream.Read(vFloat, SizeOf(DWFloat));

              vTimeStampOffset := DateTimeToSQLTimeStampOffset(vFloat);

              stream.Read(vByte, SizeOf(Byte));

              vTimeStampOffset.TimeZoneHour := vByte - 12;

              stream.Read(vByte, SizeOf(Byte));

              vTimeStampOffset.TimeZoneMinute := vByte;

              Move(vTimeStampOffset, pData^, SizeOf(vTimeStampOffset));
            End
            Else
              FillChar(PData^, 1, 'S');
          end
          // TIMESTAMP
          else if (aDataType in FieldGroupTimeStamp) then
          Begin
            If aField <> Nil Then
            Begin
              If Not vBoolean Then
              Begin
                stream.Read(vFloat, SizeOf(DWFloat));

                vTimeStamp := {$IFDEF FPC} DateTimeToTimeStamp(vFloat) {$ELSE} DateTimeToSQLTimeStamp(vFloat) {$ENDIF};

                Move(vTimeStamp, pData^, SizeOf(vTimeStamp));
              End
              Else
                FillChar(PData^, 1, 'S');
            End
            Else
            Begin
              If Not vBoolean Then
                stream.Read(vFloat, SizeOf(DWFloat));
            End;
          End
          // INT64
          else if (aDataType in FieldGroupInt64) then
          Begin
            If aField <> Nil Then
            Begin
              If Not vBoolean Then
                stream.Read(pData^, SizeOf(DWInt64))
              Else
                FillChar(PData^, 1, 'S');
            End
            Else
            Begin
              If Not vBoolean Then
                stream.Read(pData^, SizeOf(DWInt64));
            End;
          End
          // BOOLEAN
          else if (aDataType in FieldGroupBoolean) then
          Begin
            If aField <> Nil Then
            Begin
              If Not vBoolean Then
                stream.Read(pData^, SizeOf(Byte));
            End
            Else If Not vBoolean Then
              stream.Read(vByte, SizeOf(Byte));
          End
          // STREAM
          else if (aDataType in FieldGroupStream) then
          Begin
            SetLength(vBytes, 0);

            If Not vBoolean Then
            Begin
              stream.Read(vInt64, SizeOf(DWInt64));

              If vInt64 > 0 Then
              Begin
                // Actual TODO XyberX
                SetLength(vBytes, vInt64);

                stream.Read(vBytes[0], vInt64);
              End;
            End;
            Try
              If Length(vBytes) > 0 Then
                If aField <> Nil Then
                  PRESTDWBytes(pData)^ := vBytes;
            Finally
              SetLength(vBytes, 0);
            End;
          End
          // OTHERS
          Else
          Begin
            stream.Read(vInt64, SizeOf(vInt64));

            vString := '';

            If vInt64 > 0 then
            begin
              SetLength(vString, vInt64);

              {$IFDEF FPC}
              stream.Read(Pointer(vString)^, vInt64);

              if EncodeStrs then
                vString := DecodeStrings(vString, csUndefined);

              vString := GetStringEncode(vString, csUndefined);

              If aField <> Nil Then
                Move(Pointer(vString)^, PData^, Length(vString));
              {$ELSE}
              stream.Read(vString[InitStrPos], vInt64);

              if EncodeStrs then
                vString := DecodeStrings(vString);

              If aField <> Nil Then
                Move(vString[InitStrPos], pData^, Length(vString));
              {$ENDIF}
            end;
            If aField <> Nil Then
              Move(vString[1], pData^, vInt64)
          End;
        end;
      end;
    end;
    Try
      Dataset.SetMemoryRecordData(pActualRecord, i);
    Finally
      {$IFNDEF FPC}
      Dispose(pActualRecord);
      {$ELSE}
      Dispose(PJvMemBuffer(@PActualRecord));
      {$ENDIF}
    End;
  end;
end;

procedure TRESTDWStorageBinRDW.LoadRecordFromStream(Dataset: TDataset; stream: TStream);
var
  i : integer;
  L : DWInt64;
  J : DWInteger;
  R : DWFloat;
  E : Extended;
  S : DWString;
  Cr : Currency;
  P : TMemoryStream;
  Bool : boolean;
  vField  : TField;
  Y      : Byte;
 {$IFNDEF FPC}
   {$IF CompilerVersion >= 21}
     TsOff      : TSQLTimeStampOffset;
   {$IFEND}
 {$ENDIF}
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
                      Stream.Read(J, Sizeof(DWInteger));
                      vField.AsInteger := J;
                     End;
      dwftSingle   : begin
                      Stream.Read(R, Sizeof(DWFloat));
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
                      Stream.Read(R, Sizeof(DWFloat));
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
        Stream.Read(R, Sizeof(DWFloat));
        vField.AsFloat := R;
      end;
      dwftFMTBcd :  begin
        Stream.Read(Cr, Sizeof(Currency));
        {$IFDEF FPC}
          vField.AsBCD := CurrToBCD(Cr);
        {$ELSE}
          vField.AsBCD := DoubleToBcd(Cr);
        {$ENDIF}
      end;
      dwftCurrency,
      dwftBCD : begin
        Stream.Read(Cr, Sizeof(Currency));
        vField.AsCurrency := Cr;
      end;
      dwftTimeStampOffset : begin
        Stream.Read(R, Sizeof(DWFloat));
        TsOff := DateTimeToSQLTimeStampOffset(R);
        Stream.Read(Y, Sizeof(Byte));
        TsOff.TimeZoneHour := Y - 12;
        Stream.Read(Y, Sizeof(Byte));
        TsOff.TimeZoneMinute := Y;
      end;
      dwftDate,
      dwftTime,
      dwftDateTime,
      dwftTimeStamp : begin
                  Stream.Read(R, Sizeof(DWFloat));
                  vField.AsDateTime := R;
      End;
      dwftLongWord,
      dwftLargeint : begin
                  Stream.Read(L, Sizeof(DWInt64));
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
                  Stream.Read(L, Sizeof(DWInt64));
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

    y := 0;
    if Dataset.Fields[i].Required then
      y := y + 1;

    if pfInUpdate in Dataset.Fields[i].ProviderFlags then
      y := y + 2;
    if pfInWhere in Dataset.Fields[i].ProviderFlags then
      y := y + 4;
    if pfInKey in Dataset.Fields[i].ProviderFlags then
      y := y + 8;
    if pfHidden in Dataset.Fields[i].ProviderFlags then
      y := y + 16;
    {$IFDEF FPC}
      if pfRefreshOnInsert in Dataset.Fields[i].ProviderFlags then
        y := y + 32;
      if pfRefreshOnUpdate in Dataset.Fields[i].ProviderFlags then
        y := y + 64;
    {$ENDIF}
    stream.Write(y,SizeOf(Byte));

    i := i + 1;
  end;

  i := stream.Position;
  rc := 0;
  stream.WriteBuffer(rc,SizeOf(Longint));

  bm := dataset.GetBookmark;
  dataset.DisableControls;
  dataset.Last;
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

procedure TRESTDWStorageBinRDW.SaveDWMemToStream(dataset: IRESTDWMemTable;
  var stream: TStream);
var
  i : integer;
  rc : Longint;
  s : DWString;
  j : integer;
  b : boolean;
  y : byte;

  ds : TRESTDWMemTable;

  bm : TBookmark;
begin
  stream.Size := 0;

  ds := TRESTDWMemTable(dataset.GetDataset);

  if not ds.Active then
    ds.Open
  else
    ds.CheckBrowseMode;
  ds.UpdateCursorPos;

  i := ds.FieldCount;
  stream.Write(i,SizeOf(integer));

  b := EncodeStrs;
  stream.Write(b,SizeOf(Byte));

  i := 0;
  while i < ds.FieldCount do begin
    j := Ord(ds.Fields[i].FieldKind);
    stream.Write(j,SizeOf(Integer));

    s := ds.Fields[i].DisplayName;
    j := Length(s);
    stream.Write(j,SizeOf(Integer));
    stream.Write(s[InitStrPos],j);

    y := FieldTypeToDWFieldType(ds.Fields[i].DataType);
    stream.Write(y,SizeOf(Byte));

    j := ds.Fields[i].Size;
    stream.Write(j,SizeOf(Integer));

    j := 0;
    if ds.Fields[i].InheritsFrom(TFloatField) then
      j := TFloatField(ds.Fields[i]).Precision;

    stream.Write(j,SizeOf(Integer));

    y := 0;
    if ds.Fields[i].Required then
      y := y + 1;

    if pfInUpdate in ds.Fields[i].ProviderFlags then
      y := y + 2;
    if pfInWhere in ds.Fields[i].ProviderFlags then
      y := y + 4;
    if pfInKey in ds.Fields[i].ProviderFlags then
      y := y + 8;
    if pfHidden in ds.Fields[i].ProviderFlags then
      y := y + 16;
    {$IFDEF FPC}
      if pfRefreshOnInsert in ds.Fields[i].ProviderFlags then
        y := y + 32;
      if pfRefreshOnUpdate in ds.Fields[i].ProviderFlags then
        y := y + 64;
    {$ENDIF}
    stream.Write(y,SizeOf(Byte));

    i := i + 1;
  end;

  i := stream.Position;
  rc := 0;
  stream.WriteBuffer(rc,SizeOf(Longint));

  rc := SaveRecordDWMemToStream(dataset,stream);

  stream.Position := i;
  stream.WriteBuffer(rc,SizeOf(Longint));
  stream.Position := 0;
end;

function TRESTDWStorageBinRDW.SaveRecordDWMemToStream(Dataset: IRESTDWMemTable;
  stream: TStream) : Longint;
var
 I, B,
 aIndex        : Integer;
 vActualRecord : TJvMemoryRecord;
 PActualRecord : PJvMemBuffer;
 aDataType     : TFieldType;
 PData         : {$IFDEF FPC} PAnsiChar {$ELSE} PByte {$ENDIF};
 aBreak        : Boolean;

 ds            : TRESTDWMemTable;
 L             : Longint;
 J             : Integer;
 R             : DWFloat;
 E             : Extended;
 Si            : Smallint;
 Cr            : Currency;
 Bool          : Boolean;
 S             : DWString;
 P             : TMemoryStream;
 fc            : integer;
 Dt            : TDateTime;
 Ts            : {$IFDEF FPC} TTimeStamp {$ELSE} TSQLTimeStamp {$ENDIF};
 Y             : Byte;
 {$IFNDEF FPC}
   {$IF CompilerVersion >= 21}
     TsOff      : TSQLTimeStampOffset;
   {$IFEND}
 {$ENDIF}
 bcd           : TBcd;
Begin
  ds := TRESTDWMemTable(dataset.GetDataset);

  fc := ds.Fields.Count - 1;
  Result := dataset.GetRecordCount - 1; // isso pesa muito

  for I := 0 to Result do begin
    vActualRecord := dataset.GetMemoryRecord(I);
    pActualRecord := PJvMemBuffer(vActualRecord.Data);
    aBreak        := False;
    for B := 0 To fc do begin
      aIndex := ds.Fields[B].FieldNo - 1;
      if (aIndex >= 0) And (PActualRecord <> Nil) then begin
        aDataType := ds.FieldDefs[aIndex].DataType;
        aBreak := ds.Fields[B].IsNull;
        if aBreak then
         Begin
          Stream.Write(aBreak, SizeOf(Byte));
          Continue;
         End;
//          if PData <> nil then begin
//            if ds.Fields[B] is TBlobField then
//              aBreak  := PData <> nil
//            else
//              aBreak  := {$IFDEF FPC} PData^ <> #0 {$ELSE} PData^ <> 0 {$ENDIF};
//            Inc(PData);
//          end;

        if dataset.DataTypeSuported(aDataType) then begin
          if dataset.DataTypeIsBlobTypes(aDataType) then
           PData    := Pointer(@PMemBlobArray(PActualRecord + dataset.GetOffSetsBlobs)^[ds.Fields[B].Offset]) //Pointer(@PMemBlobArray(vActualRecord.Blobs)^[ds.Fields[B].Offset])
          else
            PData    := Pointer(PActualRecord + dataset.GetOffSets(aIndex));
        end;
        case aDataType of
          ftFixedChar,
          ftWideString,
          ftString : begin
                      S := PAnsiChar(PData);
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
                      Move(PData^,J,Sizeof(PData));
                      Stream.Write(J, Sizeof(Integer));
          end;
          {$ENDIF}
          ftSmallint : begin
                      Move(PData^,Si,Sizeof(PData));
                      J := Si;
                      Stream.Write(J, Sizeof(Integer));
          end;
          ftWord,
          ftInteger,
          ftAutoInc :  Begin
                      Move(PData^,J,Sizeof(PData));
                      Stream.Write(J, Sizeof(Integer));
          end;
          {$IFNDEF FPC}
            {$IF CompilerVersion >= 21}
              ftSingle   : Begin
                            Move(PData^, R, Sizeof(PData));
                            Stream.Write(R, Sizeof(DWFloat));
                           End;
              ftExtended : begin
                          Move(PData^,E,Sizeof(PData));
                          Stream.Write(E, Sizeof(Extended));
              end;
            {$IFEND}
          {$ENDIF}
          ftFMTBcd : begin
                      Move(PData^,bcd,Sizeof(bcd));
                      BCDToCurr(bcd,Cr);
                      Stream.Write(Cr, Sizeof(Currency));
          end;
          ftFloat  : Begin
                      Move(PData^, R, Sizeof(DWFloat));
                      Stream.Write(R, Sizeof(DWFloat));
                     End;
          ftCurrency,
          ftBCD     :  begin
                        Move(PData^,Cr,Sizeof(PData));
                        Stream.Write(Cr, Sizeof(Currency));
                       end;
          {$IFNDEF FPC}
            {$IF CompilerVersion >= 21}
              ftTimeStampOffset : begin
                Move(PData^,TsOff,Sizeof(TsOff));
                Dt := SQLTimeStampOffsetToDateTime(TsOff);
                Stream.Write(Dt, Sizeof(DWFloat));
                Y := TsOff.TimeZoneHour + 12;
                Stream.Write(Y, Sizeof(Byte));
                Y := TsOff.TimeZoneMinute;
                Stream.Write(Y, Sizeof(Byte));
              end;
            {$IFEND}
          {$ENDIF}
          ftDate,
          ftTime,
          ftDateTime : begin
                      Move(PData^, Dt, Sizeof(Dt));
                      R := Dt;
                      Stream.Write(R, Sizeof(DWFloat));
          end;
          ftTimeStamp : begin
                      Move(PData^,Ts,Sizeof(Ts));
                      Dt := {$IFDEF FPC} TimeStampToDateTime(Ts) {$ELSE} SQLTimeStampToDateTime(Ts) {$ENDIF};
                      Stream.Write(R, Sizeof(DWFloat));
          End;
          {$IFNDEF FPC}
            {$IF CompilerVersion >= 21}
              ftLongWord,
            {$IFEND}
          {$ENDIF}
          ftLargeint : begin
                      Move(PData^,L,Sizeof(PData));
                      Stream.Write(L, Sizeof(Longint));
          end;
          ftBoolean  : begin
                      Move(PData^,Bool,Sizeof(PData));
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
                        S := PAnsiChar(PData);
                        L := Length(S);
                        Stream.Write(L, Sizeof(Longint));
                        P.Position := 0;
                        Stream.CopyFrom(P, L);
                      finally
                        FreeAndNil(P);
                      end;
          end;
          else begin
                      S := PAnsiChar(PData);
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
  end;

  Result := Result + 1;
end;

procedure TRESTDWStorageBinRDW.SaveRecordToStream(Dataset: TDataset; stream: TStream);
var
  i: integer;
  vBytes: TRESTDWBytes;
  vString: DWString;
  vInt64: DWInt64;
  vInt: DWInteger;
  vFloat: DWFloat;
  vDouble: Double;
  vCardinal: Cardinal;
  vSingle: Single;
  vCurrency: Currency;
  vMemoryStream: TMemoryStream;
  vBoolean: boolean;
  vByte: Byte;
  {$IFNDEF FPC}
    {$IF CompilerVersion >= 21}
  vTimeStampOffset: TSQLTimeStampOffset;
    {$IFEND}
  vBCD: TBcd;
  {$ENDIF}
Begin
  vMemoryStream := nil;

  for i := 0 to Dataset.FieldCount - 1 do
  begin
    if fkCalculated = Dataset.Fields[i].FieldKind then
      vBoolean := True
    else
    Begin
      if Dataset.Fields[i].DataType in ftBlobTypes then
      Begin
        vMemoryStream := TMemoryStream.Create;
        Try
          TBlobField(Dataset.Fields[i]).SaveToStream(vMemoryStream);

          vBoolean := (vMemoryStream.Size = 0);
        Finally
          FreeAndNil(vMemoryStream);
        End;
      End
      Else
        vBoolean := Dataset.Fields[i].IsNull;
    End;

    stream.Write(vBoolean, SizeOf(Byte));
    if vBoolean then
      Continue;

    //STRING OR WIDE STRING
    if ((Dataset.Fields[i].DataType in FieldGroupChar) or
      (Dataset.Fields[i].DataType in FieldGroupWideChar)) then
    begin
      vString := Dataset.Fields[i].AsString;

      if EncodeStrs then
        vString := EncodeStrings(vString{$IFDEF FPC}, csUndefined{$ENDIF});

      vInt64 := Length(vString);

      stream.Write(vInt64, SizeOf(vInt64));

      {$IFNDEF FPC}
      if vInt64 <> 0 then
        stream.Write(vString[InitStrPos], vInt64);
      {$ELSE}
      if vInt64 <> 0 then
        stream.Write(vString[1], vInt64);
      {$ENDIF}
    end
    // CARDINAL
    else if (Dataset.Fields[i].DataType in FieldGroupCardinal) then
    begin
      vCardinal := Dataset.Fields[i].AsLongWord;

      stream.Write(vCardinal, SizeOf(Cardinal));
    end
    // INTEGER
    else if (Dataset.Fields[i].DataType in FieldGroupInt) then
    begin
      vInt := Dataset.Fields[i].AsInteger;

      stream.Write(vInt, SizeOf(DWInteger));
    end
    // STREAM
    else if (Dataset.Fields[i].DataType in FieldGroupStream) then
    Begin
      vMemoryStream := TMemoryStream.Create;

      Try
        TBlobField(Dataset.Fields[i]).SaveToStream(vMemoryStream);

        vInt64 := vMemoryStream.Size;

        stream.Write(vInt64, SizeOf(DWInt64));

        SetLength(vBytes, vInt64);

        Try
          vMemoryStream.Position := 0;

          vMemoryStream.Read(vBytes[0], vInt64);
        Except
          //
        End;

        stream.Write(vBytes[0], vInt64);
      Finally
        SetLength(vBytes, 0);

        FreeAndNil(vMemoryStream);
      End;
    end
    // SINGLE
    else if (Dataset.Fields[i].DataType in FieldGroupSingle) then
    begin
      vSingle := Dataset.Fields[i].AsSingle;

      stream.Write(vSingle, SizeOf(Single));
    end
    // EXTENDED
    else if (Dataset.Fields[i].DataType in FieldGroupExtended) then
    begin
      vDouble := Dataset.Fields[i].AsFloat;

      stream.Write(vDouble, SizeOf(Double));
    end
    // CURRENCY
    else if ((Dataset.Fields[i].DataType in FieldGroupCurrency) {$IFDEF FPC} or (Dataset.Fields[i].DataType in FieldGroupBCD) {$ENDIF}) then
    begin
      vCurrency := Dataset.Fields[i].AsCurrency;

      stream.Write(vCurrency, SizeOf(Currency));
    end
    {$IFNDEF FPC}
    // BCD
    else if (Dataset.Fields[i].DataType in FieldGroupBCD) then
    begin
      vBCD := Dataset.Fields[i].AsBCD;

      stream.Write(vBCD, SizeOf(TBcd));
    end
    {$ENDIF}
    // FLOAT
    else if (Dataset.Fields[i].DataType in FieldGroupFloat) then
    Begin
      vFloat := Dataset.Fields[i].AsFloat;

      stream.Write(vFloat, SizeOf(DWFloat));
    End
    // TIMESTAMP OFFSET
    else if (Dataset.Fields[i].DataType in FieldGroupTimeStampOffSet) then
    begin
      vTimeStampOffset := Dataset.Fields[i].AsSQLTimeStampOffset;

      vFloat := SQLTimeStampOffsetToDateTime(vTimeStampOffset);

      stream.Write(vFloat, SizeOf(DWFloat));

      vByte := vTimeStampOffset.TimeZoneHour + 12;

      stream.Write(vByte, SizeOf(Byte));

      vByte := vTimeStampOffset.TimeZoneMinute;

      stream.Write(vByte, SizeOf(Byte));
    end
    // DATETIME OR TIMESTAMP
    else if ((Dataset.Fields[i].DataType in FieldGroupDateTime) or
      (Dataset.Fields[i].DataType in FieldGroupTimeStamp)) then
    Begin
      vFloat := Dataset.Fields[i].AsDateTime;

      stream.Write(vFloat, SizeOf(DWFloat));
    End
    // INT64
    else if (Dataset.Fields[i].DataType in FieldGroupInt64) then
    begin
    {$IF NOT DEFINED(FPC) AND (CompilerVersion < 22)}
      vInt64 := Dataset.Fields[i].AsInteger;
    {$ELSE}
      vInt64 := Dataset.Fields[i].AsLargeInt;
    {$IFEND}

      stream.Write(vInt64, SizeOf(DWInt64));
    end
    // BOOLEAN
    else if (Dataset.Fields[i].DataType in FieldGroupBoolean) then
    begin
      vBoolean := Dataset.Fields[i].AsBoolean;

      stream.Write(vBoolean, SizeOf(Byte));
    End
    // OTHERS...
    else
    begin
      vString := Dataset.Fields[i].AsString;

      if EncodeStrs then
        vString := EncodeStrings(vString{$IFDEF FPC}, csUndefined{$ENDIF});

      vInt64 := Length(vString);

      stream.Write(vInt64, SizeOf(vInt64));

      {$IFNDEF FPC}
      If vInt64 <> 0 Then
        stream.Write(vString[InitStrPos], vInt64);
      {$ELSE}
      If vInt64 <> 0 Then
        stream.Write(vString[1], vInt64);
      {$ENDIF}
    end;
  end;
end;

end.
