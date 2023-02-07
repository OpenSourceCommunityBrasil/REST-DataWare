unit uRESTDWStorageBin;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

interface

uses
  Classes, SysUtils, uRESTDWMemoryDataset, FmtBcd, DB, Variants, uRESTDWConsts;

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
  uRESTDWProtoTypes, uRESTDWBufferBase, uRESTDWTools {$IFNDEF FPC}, SqlTimSt{$ENDIF};

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

  vRecCount : integer;
  vFieldCount : integer;

  aField : TField;
  aIndex : Integer;
  vDataset  : TRESTDWMemTable;
  vActualRecord: TJvMemoryRecord;

  vDataType     : TFieldType;
  vDWFieldType  : Byte;

  pData: {$IFDEF FPC} PAnsiChar {$ELSE} PByte {$ENDIF};
  pActualRecord: PJvMemBuffer;

  vString    : DWString;
  vInt       : Integer;
  vLength    : Word;
  vBoolean   : boolean;
  vInt64     : Int64;
  vSingle    : Single;
  vDouble    : Double;
  vWord      : Word;
  vCurrency  : Currency;
  vTimeStamp : {$IFDEF FPC} TTimeStamp {$ELSE} TSQLTimeStamp {$ENDIF};
  vBCD       : TBcd;
  vBytes     : TRESTDWBytes;
  vTimeZone  : Double;
  vDateTimeRec : TDateTimeRec;
  vByte: Byte;
  {$IFNDEF FPC}
    {$IF CompilerVersion >= 21}
      vTimeStampOffset: TSQLTimeStampOffset;
    {$IFEND}
  {$ENDIF}

  procedure tratarNulos;
  begin
    if (vDWFieldType in [dwftFixedWideChar,dwftWideString,dwftFixedChar, dwftString]) then begin
      if aField <> nil then begin
        vLength := Dataset.GetCalcFieldLen(aField.DataType, aField.Size);
        {$IFDEF FPC}
          FillChar(PData^, vLength, #0);
        {$ELSE}
          FillChar(pData^, vLength, 0);
        {$ENDIF}
      end;
    end
    else if (vDWFieldType in [dwftLongWord,dwftByte,dwftShortint,dwftSmallint,
                              dwftWord,dwftInteger,dwftSingle,dwftExtended,
                              dwftFloat,dwftOraTimeStamp,dwftBCD,dwftFMTBcd,
                              dwftCurrency,dwftDate,dwftTime,dwftDateTime,
                              dwftTimeStampOffset,dwftAutoInc,dwftLargeint,
                              dwftTimeStamp]) then begin
      if vBoolean then
        FillChar(PData^, 1, 'S');
    end;
  end;

Begin
  pActualRecord := nil;

  vDataset := TRESTDWMemTable(Dataset.GetDataset);

  stream.Read(vRecCount, SizeOf(vRecCount));
  vRecCount := vRecCount - 1;

  vFieldCount := Length(FFieldNames);
  vFieldCount := vFieldCount - 1;

  for i := 0 to vRecCount do begin
    pActualRecord := PJvMemBuffer(Dataset.AllocRecordBuffer);

    Dataset.InternalAddRecord(pActualRecord, True);

    vActualRecord := Dataset.GetMemoryRecord(i);

    for b := 0 To vFieldCount do begin
      aField := vDataset.FindField(FFieldNames[b]);

      If aField <> Nil Then Begin
        aIndex := aField.FieldNo - 1;

        If (aIndex < 0) Then
          Continue;

        vDataType := aField.DataType;
      End
      Else begin
        vDataType := DWFieldTypeToFieldType(FFieldTypes[b]);
      end;

      vDWFieldType := FFieldTypes[b];

      stream.Read(vBoolean, SizeOf(Byte));

      if (pActualRecord <> Nil) then begin
        If aField <> Nil Then Begin
          if Dataset.DataTypeSuported(vDataType) then begin
            if Dataset.DataTypeIsBlobTypes(vDataType) then
              pData := Pointer(@PMemBlobArray(pActualRecord + Dataset.GetOffSetsBlobs)^[aField.Offset])
              // Pointer(@PMemBlobArray(vActualRecord.Blobs)^[ds.Fields[B].Offset])
            else
              pData := Pointer(pActualRecord + Dataset.GetOffSets(aIndex));
          end;
        End;

        tratarNulos;
        if vBoolean then
          Continue;

        if (pData <> nil) Or (aField = Nil) then begin
          // N Bytes - WideString
          if (vDWFieldType in [dwftFixedWideChar,dwftWideString]) then begin
            stream.Read(vInt64, SizeOf(vInt64));
            vString := '';
            if vInt64 > 0 then begin
              SetLength(vString, vInt64);
              {$IFDEF FPC}
                stream.Read(Pointer(vString)^, vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString, csUndefined);

                vString := GetStringEncode(vString, csUndefined);

                vInt64 := (Length(vString) + 1) * SizeOf(WideChar);

                If aField <> Nil Then
                  Move(Pointer(WideString(vString))^, PData^, vInt64);
              {$ELSE}
                stream.Read(vString[InitStrPos], vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString);

                vInt64 := (Length(vString) + 1) * SizeOf(WideChar);

                If aField <> Nil Then
                  Move(WideString(vString)[InitStrPos], pData^, vInt64);
              {$ENDIF}
            end;
          end
          // N Bytes - Strings
          else if (vDWFieldType in [dwftFixedChar,dwftString]) then begin
            stream.Read(vInt64, SizeOf(vInt64));
            vString := '';
            If vInt64 > 0 Then begin
              SetLength(vString, vInt64);
              {$IFDEF FPC}
                stream.Read(Pointer(vString)^, vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString, csUndefined);

                vString := GetStringEncode(vString, csUndefined);

                If aField <> Nil Then
                  Move(Pointer(vString)^, pData^, Length(vString));
              {$ELSE}
                stream.Read(vString[InitStrPos], vInt64);

                If EncodeStrs Then
                  vString := DecodeStrings(vString);

                If aField <> Nil Then
                  Move(vString[InitStrPos], pData^, Length(vString));
              {$ENDIF}
            end;
          end
          // 1 - Byte - Inteiro
          else if (vDWFieldType in [dwftByte,dwftShortint]) then
          begin
            stream.Read(vByte, SizeOf(vByte));
            if aField <> Nil Then
              Move(vByte,PData^,Sizeof(vByte));
          end
          // 1 - Byte - Boolean
          else if (vDWFieldType in [dwftBoolean]) then
          begin
            stream.Read(vBoolean, SizeOf(vBoolean));
            if aField <> Nil Then
              Move(vBoolean,PData^,Sizeof(vBoolean));
          end
          // 2 - Bytes
          else if (vDWFieldType in [dwftSmallint,dwftWord]) then begin
            stream.Read(vWord, SizeOf(vWord));
            if aField <> Nil Then
              Move(vWord,PData^,Sizeof(vWord));
          end
          // 4 - Bytes - Inteiros
          else if (vDWFieldType in [dwftInteger]) then
          begin
            stream.Read(vInt, SizeOf(vInt));
            if aField <> Nil Then
              Move(vInt,PData^,Sizeof(vInt));
          end
          // 4 - Bytes - Flutuantes
          else if (vDWFieldType in [dwftSingle]) then
          begin
            stream.Read(vSingle, SizeOf(vSingle));
            if aField <> Nil Then
              Move(vSingle,PData^,Sizeof(vSingle));
          end
          // 8 - Bytes - Inteiros
          else if (vDWFieldType in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
          begin
            stream.Read(vInt64, SizeOf(vInt64));
            if aField <> Nil Then
              Move(vInt64,PData^,Sizeof(vInt64));
          end
          // 8 - Bytes - Flutuantes
          else if (vDWFieldType in [dwftFloat,dwftExtended]) then
          begin
            stream.Read(vDouble, SizeOf(vDouble));
            if aField <> Nil Then
              Move(vDouble,PData^,Sizeof(vDouble));
          end
          // 8 - Bytes - Date, Time, DateTime, TimeStamp
          else if (vDWFieldType in [dwftDate,dwftTime,dwftDateTime]) then
          begin
            stream.Read(vDouble, SizeOf(vDouble));
            if aField <> Nil Then begin
              {$IFDEF FPC}
                vDateTimeRec := DateTimeToDateTimeRec(vDataType, TDateTime(vDouble));
                Move(vDateTimeRec, PData^, SizeOf(vDateTimeRec));
              {$ELSE}
                Case vDataType Of
                  ftDate:
                    vDateTimeRec.Date := DateTimeToTimeStamp(vDouble).Date;
                  ftTime:
                    vDateTimeRec.Time := DateTimeToTimeStamp(vDouble).Time;
                  Else
                    vDateTimeRec.DateTime := TimeStampToMSecs(DateTimeToTimeStamp(vDouble));
                End;
                Move(vDateTimeRec, pData^, SizeOf(vDateTimeRec));
              {$ENDIF}
            end;
          end
          else if (vDWFieldType in [dwftTimeStamp]) then
          begin
            stream.Read(vDouble, SizeOf(vDouble));
            if aField <> Nil Then begin
              {$IFDEF FPC}
                vTimeStamp := DateTimeToTimeStamp(vDouble);
              {$ELSE}
                vTimeStamp := DateTimeToSQLTimeStamp(vDouble);
              {$ENDIF};
              Move(vTimeStamp, pData^, SizeOf(vTimeStamp));
            end;
          end
          // TimeStampOffSet To Double - 8 Bytes
          // + TimeZone                - 2 Bytes
          else if (vDWFieldType in [dwftTimeStampOffset]) then begin
            {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
              stream.Read(vDouble, SizeOf(vDouble));
              vTimeStampOffSet := DateTimeToSQLTimeStampOffset(vDouble);

              stream.Read(vByte, SizeOf(vByte));
              vTimeStampOffSet.TimeZoneHour := vByte - 12;

              stream.Read(vByte, SizeOf(vByte));
              vTimeStampOffSet.TimeZoneMinute := vByte;

              if aField <> Nil Then
                Move(vTimeStampOffSet,PData^,Sizeof(vTimeStampOffSet));
            {$ELSE}
              // field foi transformado em tdatetime
              stream.Read(vDouble, SizeOf(vDouble));

              stream.Read(vByte, SizeOf(vByte));
              vTimeZone := (vByte - 12) / 24;

              stream.Read(vByte, SizeOf(vByte));
              if vTimeZone > 0 then
                vTimeZone := vTimeZone + (vByte / 60 / 24)
              else
                vTimeZone := vTimeZone - (vByte / 60 / 24);

              vDouble := vDouble - vTimeZone;

              if aField <> Nil Then begin
                {$IFDEF FPC}
                  vDateTimeRec := DateTimeToDateTimeRec(vDataType, TDateTime(vDouble));
                  Move(vDateTimeRec, PData^, SizeOf(vDateTimeRec));
                {$ELSE}
                  Case vDataType Of
                    ftDate:
                      vDateTimeRec.Date := DateTimeToTimeStamp(vDouble).Date;
                    ftTime:
                      vDateTimeRec.Time := DateTimeToTimeStamp(vDouble).Time;
                    Else
                      vDateTimeRec.DateTime := TimeStampToMSecs(DateTimeToTimeStamp(vDouble));
                  End;
                  Move(vDateTimeRec, pData^, SizeOf(vDateTimeRec));
                {$ENDIF}
              end;
            {$IFEND}
          end
          // 8 - Bytes - Currency
          else if (vDWFieldType in [dwftCurrency]) then
          begin
            stream.Read(vCurrency, SizeOf(vCurrency));
            if aField <> Nil Then
              Move(vCurrency,PData^,Sizeof(vCurrency));
          end
          // 8 - Bytes - Currency
          else if (vDWFieldType in [dwftBCD]) then
          begin
            stream.Read(vCurrency, SizeOf(vCurrency));

            if aField <> Nil Then begin
              {$IFDEF FPC}
               Move(vCurrency,PData^, Sizeof(vCurrency));
              {$ELSE}
               {$IF CompilerVersion <= 21}
                CurrToBCD(vCurrency, vBCD);
               {$ELSE}
                vBCD := CurrencyToBcd(vCurrency);
               {$IFEND}
                Move(vBCD,PData^,Sizeof(vBCD));
              {$ENDIF}
            end;
          end
          // 8 - Bytes - Currency
          Else if (vDWFieldType in [dwftFMTBcd]) then
          begin
            stream.Read(vCurrency, SizeOf(vCurrency));
            {$IFDEF FPC}
              vBCD := CurrToBcd(vCurrency);
            {$ELSE}
              {$IF CompilerVersion <= 21}
               CurrToBCD(vCurrency, vBCD);
              {$ELSE}
               vBCD := CurrencyToBcd(vCurrency);
              {$IFEND}
            {$ENDIF}
            Move(vBCD,PData^,Sizeof(vBCD));
          end
          // N Bytes - WideString Blobs
          else if (vDWFieldType in [dwftWideMemo,dwftFmtMemo]) then
          begin
            stream.Read(vInt64, SizeOf(vInt64));
            vString := '';
            if vInt64 > 0 then begin
              SetLength(vString, vInt64);
              {$IFDEF FPC}
                stream.Read(Pointer(vString)^, vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString, csUndefined);

                vString := GetStringEncode(vString, csUndefined);
              {$ELSE}
                stream.Read(vString[InitStrPos], vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString);
              {$ENDIF}
              vInt64 := (Length(vString) + 1) * SizeOf(WideChar);
              try
                SetLength(vBytes, vInt64);
                Move(WideString(vString)[InitStrPos], vBytes[0], vInt64);
                If aField <> Nil Then
                  PRESTDWBytes(pData)^ := vBytes;
              finally
                SetLength(vBytes, 0);
              end;
            end;
          end
          // N Bytes - String Blobs
          else if (vDWFieldType in [dwftMemo]) then
          begin
            stream.Read(vInt64, SizeOf(vInt64));
            vString := '';
            if vInt64 > 0 then begin
              SetLength(vString, vInt64);
              {$IFDEF FPC}
                stream.Read(Pointer(vString)^, vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString, csUndefined);

                vString := GetStringEncode(vString, csUndefined);
              {$ELSE}
                stream.Read(vString[InitStrPos], vInt64);

                if EncodeStrs then
                  vString := DecodeStrings(vString);
              {$ENDIF}
              vInt64 := Length(vString) + 1;
              try
                SetLength(vBytes, vInt64);
                Move(vString[InitStrPos], vBytes[0], vInt64);
                If aField <> Nil Then
                  PRESTDWBytes(pData)^ := vBytes;
              finally
                SetLength(vBytes, 0);
              end;
            end;
          end
          // N Bytes - Others Blobs
          else if (vDWFieldType in [dwftStream,dwftBlob,dwftBytes]) then
          begin
            SetLength(vBytes, 0);
            stream.Read(vInt64, SizeOf(DWInt64));

            If vInt64 > 0 Then Begin
              // Actual TODO XyberX
              SetLength(vBytes, vInt64);
              stream.Read(vBytes[0], vInt64);
            End;

            Try
              If Length(vBytes) > 0 Then Begin
                If aField <> Nil Then
                  PRESTDWBytes(pData)^ := vBytes;
              end;
            Finally
              SetLength(vBytes, 0);
            End;
          end
          // N Bytes - Others
          else begin
            stream.Read(vInt64, SizeOf(vInt64));

            vString := '';

            If vInt64 > 0 then begin
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
          end;
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
  vField        : TField;

  i : integer;

  vString       : DWString;
  vInt64        : Int64;
  vInt          : Integer;
  vDouble       : Double;
  vTimeZone     : Double;
  vSingle       : Single;
  vWord         : Word;
  vCurrency     : Currency;
  vMemoryStream : TMemoryStream;
  vBoolean      : Boolean;
  vByte         : Byte;
 {$IFNDEF FPC}
   {$IF CompilerVersion >= 21}
     vTimeStampOffset : TSQLTimeStampOffset;
   {$IFEND}
 {$ENDIF}
begin
  for i := 0 to Length(FFieldTypes)-1 do begin
    vField := Dataset.Fields[i];
    vField.Clear;

    Stream.Read(vBoolean, Sizeof(Byte));
    if vBoolean then // is null
      Continue;

    // N - Bytes
    if (FFieldTypes[i] in [dwftFixedChar,dwftWideString,dwftString,dwftMemo,
                           dwftFixedWideChar,dwftWideMemo,dwftFmtMemo]) then begin
      Stream.Read(vInt64, Sizeof(vInt64));
      vString := '';
      if vInt64 > 0 then begin
        SetLength(vString, vInt64);
        {$IFDEF FPC}
         Stream.Read(Pointer(vString)^, vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString, csUndefined);
         vString := GetStringEncode(vString, csUndefined);
        {$ELSE}
         Stream.Read(vString[InitStrPos], vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString);
        {$ENDIF}
      end;
      vField.AsString := vString;
    end
    // 1 - Byte - Inteiro
    else if (FFieldTypes[i] in [dwftByte,dwftShortint]) then
    begin
      Stream.Read(vByte, Sizeof(vByte));
      vField.AsInteger := vByte;
    end
    // 1 - Byte - Boolean
    else if (FFieldTypes[i] in [dwftByte,dwftShortint]) then
    begin
      Stream.Read(vBoolean, Sizeof(vBoolean));
      vField.AsBoolean := vBoolean;
    end
    // 2 - Bytes
    else if (FFieldTypes[i] in [dwftSmallint,dwftWord]) then begin
      Stream.Read(vWord, Sizeof(vWord));
      vField.AsInteger := vWord;
    end
    // 4 - Bytes - Inteiros
    else if (FFieldTypes[i] in [dwftInteger]) then
    begin
      Stream.Read(vInt, Sizeof(vInt));
      vField.AsInteger := vWord;
    end
    // 4 - Bytes - Flutuantes
    else if (FFieldTypes[i] in [dwftSingle]) then
    begin
      Stream.Read(vSingle, Sizeof(vSingle));
      {$IFDEF FPC}
        vField.AsFloat := vSingle;
      {$ELSE}
        {$IF (CompilerVersion < 22)}
          vField.AsFloat := vSingle;
        {$ELSE}
          vField.AsSingle := vSingle;
        {$IFEND}
      {$ENDIF}
    end
    // 8 - Bytes - Inteiros
    else if (FFieldTypes[i] in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
    begin
      Stream.Read(vInt64, Sizeof(vInt64));
      {$IF NOT DEFINED(FPC) AND (CompilerVersion < 22)}
        vField.AsInteger := vInt64;
      {$ELSE}
        vField.AsLargeInt := vInt64;
      {$IFEND}
    end
    // 8 - Bytes - Flutuantes
    else if (FFieldTypes[i] in [dwftFloat,dwftExtended]) then
    begin
      Stream.Read(vDouble, Sizeof(vDouble));
      vField.AsFloat := vDouble;
    end
    // 8 - Bytes - Date, Time, DateTime
    else if (FFieldTypes[i] in [dwftDate,dwftTime,dwftDateTime]) then
    begin
      Stream.Read(vDouble, Sizeof(vDouble));
      vField.AsDateTime := vDouble;
    end
    // TimeStamp To Double - 8 Bytes
    else if (FFieldTypes[i] in [dwftTimeStamp]) then begin
      Stream.Read(vDouble, Sizeof(vDouble));
      vField.AsDateTime := vDouble;
    end
    // TimeStampOffSet To Double - 8 Bytes
    // + TimeZone                - 2 Bytes
    else if (FFieldTypes[i] in [dwftTimeStampOffset]) then begin
      {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
        stream.Read(vDouble, Sizeof(vDouble));
        vTimeStampOffset := DateTimeToSQLTimeStampOffset(vDouble);

        stream.Read(vByte, Sizeof(vByte));
        vTimeStampOffset.TimeZoneHour := vByte - 12;

        stream.Read(vByte, Sizeof(vByte));
        vTimeStampOffset.TimeZoneMinute := vByte;

        vField.AsSQLTimeStampOffset := vTimeStampOffset;
      {$ELSE}
        // field foi transformado em datetime
        stream.Read(vDouble, Sizeof(vDouble));
        stream.Read(vByte, SizeOf(vByte));
        vTimeZone := (vByte - 12) / 24;

        stream.Read(vByte, SizeOf(vByte));
        if vTimeZone > 0 then
          vTimeZone := vTimeZone + (vByte / 60 / 24)
        else
          vTimeZone := vTimeZone - (vByte / 60 / 24);

        vDouble := vDouble - vTimeZone;
        vField.AsDateTime := vDouble;
      {$IFEND}
    end
    // 8 - Bytes - Currency
    else if (FFieldTypes[i] in [dwftCurrency,dwftBCD,dwftFMTBcd]) then
    begin
      stream.Read(vCurrency, Sizeof(vCurrency));
      vField.AsCurrency := vCurrency;
    end
    // N Bytes - Blobs
    else if (FFieldTypes[i] in [dwftStream,dwftBlob,dwftBytes]) then
    begin
      stream.Read(vInt64, Sizeof(DWInt64));
      if vInt64 > 0 then Begin
        vMemoryStream := TMemoryStream.Create;
        try
          vMemoryStream.CopyFrom(stream, vInt64);
          vMemoryStream.Position := 0;
          TBlobField(vField).LoadFromStream(vMemoryStream);
        finally
          FreeAndNil(vMemoryStream);
        end;
      end;
    end
    // N Bytes - Others
    else begin
      Stream.Read(vInt64, Sizeof(vInt64));
      vString := '';
      if vInt64 > 0 then begin
        SetLength(vString, vInt64);
        {$IFDEF FPC}
         Stream.Read(Pointer(vString)^, vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString, csUndefined);
         vString := GetStringEncode(vString, csUndefined);
        {$ELSE}
         Stream.Read(vString[InitStrPos], vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString);
        {$ENDIF}
      end;
      vField.AsString := vString;
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
 vDataSet      : TRESTDWMemTable;

 I, B,
 aIndex        : Integer;
 vActualRecord : TJvMemoryRecord;
 PActualRecord : PJvMemBuffer;
 PData         : {$IFDEF FPC} PAnsiChar {$ELSE} PByte {$ENDIF};

 vDataType     : TFieldType;
 vDWFieldType  : Byte;
 vFieldCount   : Integer;

 vString       : DWString;
 vInt64        : Int64;
 vCardinal     : Cardinal;
 vInt          : Integer;
 vByte         : Byte;
 vWord         : Word;
 vSingle       : Single;
 vDouble       : Double;
 vCurrency     : Currency;
 vBCD          : TBcd;
 vMemoryStream : TMemoryStream;
 vBoolean      : Boolean;
 vTimeStamp    : {$IFDEF FPC} TTimeStamp {$ELSE} TSQLTimeStamp {$ENDIF};
 {$IFNDEF FPC}
   {$IF CompilerVersion >= 21}
     vTimeStampOffSet : TSQLTimeStampOffset;
   {$IFEND}
 {$ENDIF}
Begin
  vDataSet := TRESTDWMemTable(dataset.GetDataset);

  vFieldCount := vDataSet.Fields.Count - 1;
  Result := dataset.GetRecordCount - 1;

  for I := 0 to Result do begin
    vActualRecord := dataset.GetMemoryRecord(I);
    pActualRecord := PJvMemBuffer(vActualRecord.Data);
    vBoolean      := False;
    for B := 0 To vFieldCount do begin
      aIndex := vDataSet.Fields[B].FieldNo - 1;
      if (aIndex >= 0) And (PActualRecord <> Nil) then begin
        vDataType := vDataSet.FieldDefs[aIndex].DataType;
        vBoolean := vDataSet.Fields[B].IsNull;
        if vBoolean then begin
          Stream.Write(vBoolean, SizeOf(Byte));
          Continue;
        End;
//          if PData <> nil then begin
//            if ds.Fields[B] is TBlobField then
//              aBreak  := PData <> nil
//            else
//              aBreak  := {$IFDEF FPC} PData^ <> #0 {$ELSE} PData^ <> 0 {$ENDIF};
//            Inc(PData);
//          end;

        if Dataset.DataTypeSuported(vDataType) then begin
          if Dataset.DataTypeIsBlobTypes(vDataType) then
           PData    := Pointer(@PMemBlobArray(PActualRecord + Dataset.GetOffSetsBlobs)^[vDataSet.Fields[B].Offset])
           //Pointer(@PMemBlobArray(vActualRecord.Blobs)^[ds.Fields[B].Offset])
          else
           PData    := Pointer(PActualRecord + dataset.GetOffSets(aIndex));
        end;

        vDWFieldType := FieldTypeToDWFieldType(vDataType);

        // N Bytes
        if (vDWFieldType in [dwftFixedChar,dwftWideString,dwftString,
                             dwftFixedWideChar,dwftWideMemo,dwftFmtMemo,
                             dwftMemo]) then begin
          vString := PAnsiChar(PData);
          if EncodeStrs then
            vString := EncodeStrings(vString{$IFDEF FPC}, csUndefined{$ENDIF});
          vInt64 := Length(vString);
          Stream.Write(vInt64, Sizeof(vInt64));
          {$IFNDEF FPC}
            if vInt64 <> 0 then
              Stream.Write(vString[InitStrPos], vInt64);
          {$ELSE}
            if vInt64 <> 0 then
              Stream.Write(vString[1], vInt64);
          {$ENDIF}
        end
        // 1 - Byte
        else if (vDWFieldType in [dwftByte,dwftShortint,dwftBoolean]) then
        begin
          Move(PData^,vByte,Sizeof(vByte));
          Stream.Write(vByte, Sizeof(vByte));
        end
        // 2 - Bytes
        else if (vDWFieldType in [dwftSmallint,dwftWord]) then begin
          Move(PData^,vWord,Sizeof(vWord));
          Stream.Write(vWord, Sizeof(vWord));
        end
        // 4 - Bytes - Inteiros
        else if (vDWFieldType in [dwftInteger]) then
        begin
          Move(PData^,vInt,Sizeof(vInt));
          Stream.Write(vByte, Sizeof(vInt));
        end
        // 4 - Bytes - Flutuantes
        else if (vDWFieldType in [dwftSingle]) then
        begin
          Move(PData^,vSingle,Sizeof(vSingle));
          Stream.Write(vSingle, Sizeof(vSingle));
        end
        // 8 - Bytes - Inteiros
        else if (vDWFieldType in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
        begin
          Move(PData^,vInt64,Sizeof(vInt64));
          Stream.Write(vInt64, Sizeof(vInt64));
        end
        // 8 - Bytes - Flutuantes
        else if (vDWFieldType in [dwftFloat,dwftExtended,dwftDate,dwftTime,dwftDateTime]) then
        begin
          Move(PData^,vDouble,Sizeof(vDouble));
          Stream.Write(vDouble, Sizeof(vDouble));
        end
        // TimeStamp To Double - 8 Bytes
        else if (vDWFieldType in [dwftTimeStamp]) then begin
          Move(PData^,vTimeStamp,Sizeof(vTimeStamp));
          {$IFDEF FPC}
            vDouble := TimeStampToDateTime(vTimeStamp);
          {$ELSE}
            vDouble := SQLTimeStampToDateTime(vTimeStamp);
          {$ENDIF}
          Stream.Write(vDouble, Sizeof(vDouble));
        end
        {$IFNDEF FPC}
          {$IF CompilerVersion >= 21}
            // TimeStampOffSet To Double - 8 Bytes
            // + TimeZone                - 2 Bytes
            else if (vDWFieldType in [dwftTimeStampOffset]) then begin
              Move(PData^,vTimeStampOffSet,Sizeof(vTimeStampOffSet));
              vDouble := SQLTimeStampOffsetToDateTime(vTimeStampOffSet);
              Stream.Write(vDouble, Sizeof(vDouble));

              vByte := vTimeStampOffSet.TimeZoneHour + 12;
              Stream.Write(vByte, Sizeof(vByte));

              vByte := vTimeStampOffSet.TimeZoneMinute;
              Stream.Write(vByte, Sizeof(vByte));
            end
          {$IFEND}
        {$ENDIF}
        // 8 - Bytes - Currency
        else if (vDWFieldType in [dwftCurrency]) then
        begin
          Move(PData^,vCurrency,Sizeof(vCurrency));
          Stream.Write(vCurrency, Sizeof(vCurrency));
        end
        // 8 - Bytes - Currency
        else if (vDWFieldType in [dwftBCD]) then
        begin
          {$IFDEF FPC}
            Move(PData^,vCurrency,Sizeof(vCurrency));
          {$ELSE}
            Move(PData^,vBCD,Sizeof(vBCD));
            {$IF CompilerVersion <= 21}
             BCDToCurr(vBCD, vCurrency);
            {$ELSE}
             vCurrency := BCDToCurrency(vBCD);
            {$IFEND}
          {$ENDIF}
          Stream.Write(vCurrency, Sizeof(vCurrency));
        end
        // 8 - Bytes - Currency
        else if (vDWFieldType in [dwftFMTBcd]) then
        begin
          Move(PData^,vBCD,Sizeof(vBCD));
          {$IFDEF FPC}
            vCurrency := BCDToDouble(vBCD);
          {$ELSE}
            {$IF CompilerVersion <= 21}
             BCDToCurr(vBCD, vCurrency);
            {$ELSE}
             vCurrency := BCDToCurrency(vBCD);
            {$IFEND}
          {$ENDIF}
          Stream.Write(vCurrency, Sizeof(vCurrency));
        end
        // N Bytes - Blobs
        else if (vDWFieldType in [dwftStream,dwftBlob,dwftBytes]) then
        begin
          vMemoryStream := TMemoryStream.Create;
          try
            vString := PAnsiChar(PData);
            vInt64 := Length(vString);
            Stream.Write(vInt64, Sizeof(vInt64));
            vMemoryStream.Position := 0;
            Stream.CopyFrom(vMemoryStream, vInt64);
          finally
            FreeAndNil(vMemoryStream);
          end;
        end
        // N Bytes - Others
        else begin
          vString := PAnsiChar(PData);
          if EncodeStrs then
            vString := EncodeStrings(vString{$IFDEF FPC}, csUndefined{$ENDIF});
          vInt64 := Length(vString);
          Stream.Write(vInt64, Sizeof(vInt64));
          {$IFNDEF FPC}
            If vInt64 <> 0 Then
              Stream.Write(vString[InitStrPos], vInt64);
          {$ELSE}
            If vInt64 <> 0 Then
              Stream.Write(vString[1], vInt64);
          {$ENDIF}
        end;
      end;
    end;
  end;

  Result := Result + 1;
end;

procedure TRESTDWStorageBinRDW.SaveRecordToStream(Dataset: TDataset; stream: TStream);
var
  i: integer;
  vDWFieldType : Byte;

  vBytes: TRESTDWBytes;
  vString       : DWString;
  vInt64        : Int64;
  vInt          : Integer;
  vDouble       : Double;
  vWord         : Word;
  vSingle       : Single;
  vCurrency     : Currency;
  vMemoryStream : TMemoryStream;
  vBoolean      : boolean;
  vByte         : Byte;
  {$IFNDEF FPC}
    {$IF CompilerVersion >= 21}
      vTimeStampOffset : TSQLTimeStampOffset;
    {$IFEND}
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

    vDWFieldType := FieldTypeToDWFieldType(Dataset.Fields[i].DataType);

    // N - Bytes
    if (vDWFieldType in [dwftFixedChar,dwftWideString,dwftString,
                         dwftFixedWideChar, dwftWideMemo,dwftFmtMemo,
                         dwftMemo]) then begin
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
    // 1 - Byte - Inteiros
    else if (vDWFieldType in [dwftByte,dwftShortint]) then
    begin
      vByte := Dataset.Fields[i].AsInteger;
      stream.Write(vByte, Sizeof(vByte));
    end
    // 1 - Byte - Boolean
    else if (vDWFieldType in [dwftBoolean]) then
    begin
      vBoolean := Dataset.Fields[i].AsBoolean;
      stream.Write(vBoolean, Sizeof(vBoolean));
    end
    // 2 - Bytes
    else if (vDWFieldType in [dwftSmallint,dwftWord]) then begin
      vWord := Dataset.Fields[i].AsInteger;
      stream.Write(vWord, Sizeof(vWord));
    end
    // 4 - Bytes - Inteiros
    else if (vDWFieldType in [dwftInteger]) then
    begin
      vInt := Dataset.Fields[i].AsInteger;
      stream.Write(vInt, Sizeof(vInt));
    end
    // 4 - Bytes - Flutuantes
    else if (vDWFieldType in [dwftSingle]) then
    begin
      {$IFNDEF FPC}
        {$IF CompilerVersion >= 21}
          vSingle := Dataset.Fields[i].AsSingle;
        {$ELSE}
          vSingle := Dataset.Fields[i].AsFloat;
        {$IFEND}
      {$ELSE}
        vSingle := Dataset.Fields[i].AsFloat;
      {$ENDIF}
      stream.Write(vSingle, SizeOf(Single));
    end
    // 8 - Bytes - Inteiros
    else if (vDWFieldType in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
    begin
     {$IF CompilerVersion <= 21}
      vInt64 := Dataset.Fields[i].AsInteger;
     {$ELSE}
      vInt64 := Dataset.Fields[i].AsLargeInt;
     {$IFEND}
      Stream.Write(vInt64, Sizeof(vInt64));
    end
    // 8 - Bytes - Flutuantes
    else if (vDWFieldType in [dwftFloat,dwftExtended]) then
    begin
      vDouble := Dataset.Fields[i].AsFloat;
      Stream.Write(vDouble, Sizeof(vDouble));
    end
    // 8 - Bytes - Date, Time, DateTime, TimeStamp
    else if (vDWFieldType in [dwftDate,dwftTime,dwftDateTime,dwftTimeStamp]) then
    begin
      vDouble := Dataset.Fields[i].AsDateTime;
      Stream.Write(vDouble, Sizeof(vDouble));
    end
    {$IFNDEF FPC}
      {$IF CompilerVersion >= 21}
        // TimeStampOffSet To Double - 8 Bytes
        // + TimeZone                - 2 Bytes
        else if (vDWFieldType in [dwftTimeStampOffset]) then begin
          vTimeStampOffSet := Dataset.Fields[i].AsSQLTimeStampOffset;
          vDouble := SQLTimeStampOffsetToDateTime(vTimeStampOffSet);
          Stream.Write(vDouble, Sizeof(vDouble));

          vByte := vTimeStampOffSet.TimeZoneHour + 12;
          Stream.Write(vByte, Sizeof(vByte));

          vByte := vTimeStampOffSet.TimeZoneMinute;
          Stream.Write(vByte, Sizeof(vByte));
        end
      {$IFEND}
    {$ENDIF}
    // 8 - Bytes - Currency
    else if (vDWFieldType in [dwftCurrency,dwftBCD,dwftFMTBcd]) then
    begin
      vCurrency := Dataset.Fields[i].AsCurrency;
      Stream.Write(vCurrency, Sizeof(vCurrency));
    end
    // N Bytes - Blobs
    else if (vDWFieldType in [dwftStream,dwftBlob,dwftBytes]) then
    begin
      vMemoryStream := TMemoryStream.Create;

      try
        TBlobField(Dataset.Fields[i]).SaveToStream(vMemoryStream);

        vInt64 := vMemoryStream.Size;
        stream.Write(vInt64, SizeOf(DWInt64));

        SetLength(vBytes, vInt64);
        Try
          vMemoryStream.Position := 0;
          vMemoryStream.Read(vBytes[0], vInt64);
        except

        end;

        stream.Write(vBytes[0], vInt64);
      Finally
        SetLength(vBytes, 0);
        FreeAndNil(vMemoryStream);
      End;
    end
    // N Bytes - Others
    else begin
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
