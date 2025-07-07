unit uRESTDWStorageBin;

{$I ..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilberto Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambem tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alberto Brito              - Admin - Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

{$IFDEF FPC}
 {$MODE OBJFPC}{$H+}
{$ENDIF}

uses
  {$IFNDEF RESTDWLAZARUS}{$IFNDEF RESTDWFPC}SqlTimSt, {$ENDIF}{$ENDIF}
  Classes, SysUtils, uRESTDWMemoryDataset, FmtBcd, DB, Variants, uRESTDWConsts,
  uRESTDWTools{$IFDEF FPC}, uRESTDWBasicTypes{$ENDIF};

 Type
  TRESTDWStorageBin = Class(TRESTDWStorageBase)
 Private
  FFieldKind      : Array of TFieldKind;
  FFieldNames     : Array of String;
  FFieldSize,
  FFieldPrecision : Array of Integer;
  FFieldTypes,
  FFieldAttrs     : Array of Byte;
  FFieldExists    : Array of Boolean;
  Procedure SaveRecordToStream       (ADataset    : TDataset;
                                      Var AStream : TStream);
  Procedure LoadRecordFromStream     (ADataset    : TDataset;
                                      AStream     : TStream);
  Function  SaveRecordDWMemToStream  (Dataset     : IRESTDWMemTable;
                                      stream      : TStream) : Longint;
  Procedure LoadRecordDWMemFromStream(Dataset     : IRESTDWMemTable;
                                      Stream      : TStream);
 Public
  Procedure SaveDWMemToStream        (IDataset    : IRESTDWMemTable;
                                      Var AStream : TStream); Override;
  Procedure LoadDWMemFromStream      (IDataset    : IRESTDWMemTable;
                                      AStream     : TStream); Override;
  Procedure SaveDatasetToStream      (ADataset    : TDataset;
                                      Var AStream : TStream); Override;
  Procedure LoadDatasetFromStream    (ADataset    : TDataset;
                                      AStream     : TStream); Override;
 End;

 {$IFDEF FPC}
  Function DateTimeToSQLTimeStamp(Const DateTime : TDateTime)      : TSQLTimeStamp;
  Function SQLTimeStampToDateTime(Const DateTime  : TSQLTimeStamp) : TDateTime;
 {$ENDIF}

Implementation

Uses
 uRESTDWProtoTypes,
 uRESTDWBufferBase;

{ TRESTDWStorageBin }


{$IFDEF FPC}
Function DateTimeToSQLTimeStamp(Const DateTime : TDateTime) : TSQLTimeStamp;
Var
 aFractions : Word;
Begin
 DecodeDate(DateTime, Result.Year, Result.Month,  Result.Day);
 DecodeTime(DateTime, Result.Hour, Result.Minute, Result.Second, aFractions);
 Result.Fractions := aFractions;
End;

Function SQLTimeStampToDateTime(Const DateTime  : TSQLTimeStamp) : TDateTime;
 Function IsSQLTimeStampBlank  (Const TimeStamp : TSQLTimeStamp) : Boolean;
 Begin
  Result := (TimeStamp.Year      = 0) And
            (TimeStamp.Month     = 0) And
            (TimeStamp.Day       = 0) And
            (TimeStamp.Hour      = 0) And
            (TimeStamp.Minute    = 0) And
            (TimeStamp.Second    = 0) And
            (TimeStamp.Fractions = 0);
 End;
Begin
 If IsSQLTimeStampBlank(DateTime) Then
  Result := 0
 Else
  Begin
   Result := EncodeDate(DateTime.Year, DateTime.Month, DateTime.Day);
   If Result >= 0 Then
    Result := Result + EncodeTime(DateTime.Hour, DateTime.Minute, DateTime.Second, DateTime.Fractions)
   Else
    Result := Result - EncodeTime(DateTime.Hour, DateTime.Minute, DateTime.Second, DateTime.Fractions);
  End;
End;
{$ENDIF}

Procedure TRESTDWStorageBin.LoadDatasetFromStream(ADataset : TDataset;
                                                  AStream  : TStream);
Var
 vFieldKind : TFieldKind;
 r, i,
 vRecordCount : DWInteger;
 vInt,
 vFieldsCount : DWInt64;
 vString      : DWString;
 vFieldType   : Byte;
 vBoolean     : Boolean;
 vByte        : Byte;
 vFieldDef    : TFieldDef;
 vFieldAttrs  : Array of Byte;
 vField       : TField;
Begin
 AStream.Position := 0;
 // field count
 AStream.Read(vFieldsCount,SizeOf(Integer));
 SetLength(FFieldKind,      vFieldsCount);
 SetLength(FFieldTypes,     vFieldsCount);
 SetLength(vFieldAttrs,     vFieldsCount);
 SetLength(FFieldNames,     vFieldsCount);
 SetLength(FFieldSize,      vFieldsCount);
 SetLength(FFieldPrecision, vFieldsCount);
 // encodestr
 AStream.Read(vBoolean, Sizeof(vBoolean));
 EncodeStrs := vBoolean;
 ADataset.Close;
 ADataset.FieldDefs.Clear;
 For I := 0 To vFieldsCount-1 Do
  Begin
   // field kind
   AStream.Read(vByte, SizeOf(vByte));
   FFieldKind[I] := TFieldKind(vByte);
   vFieldDef := ADataset.FieldDefs.AddFieldDef;
   // fieldname
   AStream.Read(vByte, SizeOf(vByte));
   SetLength(vString, vByte);
   AStream.Read(vString[InitStrPos], vByte);
   vFieldDef.Name := vString;
   FFieldNames[I] := vString;
   // field type
   AStream.Read(vFieldType, SizeOf(vFieldType));
   vFieldDef.DataType := DWFieldTypeToFieldType(vFieldType);
   FFieldTypes[I] := vFieldType;
   // field size
   AStream.Read(vInt, SizeOf(vInt));
   vFieldDef.Size := vInt;
   FFieldSize[I]  := vInt;
   // field precision
   AStream.Read(vInt, SizeOf(vInt));
   FFieldPrecision[I] := vInt;
   If (FFieldTypes[I]  In [dwftFloat, dwftCurrency, dwftExtended]) Then
    vFieldDef.Precision := FFieldPrecision[I]
   Else If (vFieldType In [dwftBCD, dwftFMTBcd]) Then
    Begin
     {$IFDEF FPC}
     vFieldDef.Size := 0;
     vFieldDef.Precision := FFieldPrecision[I];
     {$ELSE}
     vFieldDef.Size := 0;
     vFieldDef.Precision := 0;
     {$ENDIF}
    End;
   // field required + provider flag
   AStream.Read(vByte, SizeOf(Byte));
   vFieldAttrs[I] := vByte;
   vFieldDef.Required := vFieldAttrs[I] and 1 > 0;
  End;
  // provider flags deve ser recolocado depois dos fields criados
 For I := 0 To vFieldsCount-1 Do
  Begin
   vField := ADataset.FindField(FFieldNames[I]);
   If vField <> Nil Then
    Begin
     vField.ProviderFlags := [];
     If vFieldAttrs[I] And 2 > 0  Then
      vField.ProviderFlags   := vField.ProviderFlags + [pfInUpdate];
     If vFieldAttrs[I] And 4 > 0  Then
      vField.ProviderFlags   := vField.ProviderFlags + [pfInWhere];
     If vFieldAttrs[I] And 8 > 0  Then
      vField.ProviderFlags   := vField.ProviderFlags + [pfInKey];
     If vFieldAttrs[I] And 16 > 0 Then
      vField.ProviderFlags   := vField.ProviderFlags + [pfHidden];
     {$IFDEF RESTDWLAZARUS}
      If vFieldAttrs[I] And 32 > 0 Then
       vField.ProviderFlags  := vField.ProviderFlags + [pfRefreshOnInsert];
      If vFieldAttrs[I] And 64 > 0 Then
       vField.ProviderFlags  := vField.ProviderFlags + [pfRefreshOnUpdate];
     {$ENDIF}
    End;
  End;
 AStream.Read(vRecordCount, SizeOf(vRecordCount));
 ADataset.Open;
 ADataset.DisableControls;
 Try
  r := 0;
  While r <= vRecordCount Do //Anderson
   Begin
    ADataset.Append;
    LoadRecordFromStream(ADataset, AStream);
    ADataset.Post;
    Inc(r);
   End;
 Finally
  ADataset.EnableControls;
 End;
End;

Procedure TRESTDWStorageBin.LoadDWMemFromStream(IDataset : IRESTDWMemTable;
                                                AStream  : TStream);
 Procedure CreateFieldDefs(DataSet : TDataSet;
                           Index   : Integer);
 Var
  vFDef : TFieldDef;
  Function FindDef(aName : String) : Boolean;
  Var
   I : Integer;
  Begin
   Result := False;
   For I := 0 To DataSet.FieldDefs.Count -1 Do
    Begin
     Result := Lowercase(DataSet.FieldDefs[I].Name) = Lowercase(aName);
     If Result Then
      Break;
    End;
  End;
 Begin
  If Trim(FFieldNames[Index]) <> '' Then
   Begin
    If (Not (Assigned(DataSet.FindField(FFieldNames[Index]))) And
       Not(FindDef(FFieldNames[Index]))) Then
     Begin
      VFDef          := DataSet.FieldDefs.AddFieldDef;
      VFDef.Name     := FFieldNames[Index];
      VFDef.DataType := DWFieldTypeToFieldType(FFieldTypes[Index]);
      VFDef.Size     := FFieldSize[Index];
      VFDef.Required := FFieldAttrs[Index] and 1 > 0;
      Case FFieldTypes[Index] of
        dwftFloat,
        dwftCurrency,
        dwftSingle    : VFDef.Precision := FFieldPrecision[Index];
        dwftBCD,
        dwftFMTBcd    : Begin
                        {$IFNDEF FPC}
                         VFDef.Size := 0;
                         VFDef.Precision := 0;
                        {$ELSE}
                         VFDef.Precision := FFieldPrecision[Index];
                        {$ENDIF}
                        End;
{
        dwftWideString : Begin
                          If VFDef.Size > 7100 Then
                           Begin
                            VFDef.Size := 7100;
                            FFieldSize[Index] := VFDef.Size;
                           End;
                         End;
}
      End;
     End;
   End;
 End;
Var
 ADataSet            : TRESTDWMemTable;
 I,
 vFieldsCount        : DWInteger;
 vFieldSize,
 vFieldPrecision     : DWInt16;
 vFieldName          : DWString;
 vBoolean,
 vNoFields           : Boolean;
 vByte,
 vFieldKind,
 vFieldType,
 vFieldProviderFlags : Byte;
 vFieldDef           : TFieldDef;
 vField              : TField;
Begin
 ADataSet := TRESTDWMemTable(IDataset.GetDataset);
 // field count
 AStream.Position := 0;
 AStream.Read(vFieldsCount, SizeOf(vFieldsCount));
 SetLength(FFieldKind,      vFieldsCount);
 SetLength(FFieldTypes,     vFieldsCount);
 SetLength(FFieldAttrs,     vFieldsCount);
 SetLength(FFieldNames,     vFieldsCount);
 SetLength(FFieldSize,      vFieldsCount);
 SetLength(FFieldPrecision, vFieldsCount);
 SetLength(FFieldExists,    vFieldsCount);
 // encodestrs
 AStream.Read(vBoolean, Sizeof(vBoolean));
 EncodeStrs := vBoolean;
 vNoFields :=  (ADataSet.Fields.Count = 0);
 ADataSet.Close;
 If vNoFields Then
 begin
  ADataSet.FieldDefs.Clear;
 end;
 For I := 0 To vFieldsCount-1 Do
  Begin
   // field kind
   AStream.Read(vFieldKind, SizeOf(vFieldKind));
   FFieldKind[I] := TFieldKind(vFieldKind);
   // field name
   AStream.Read(vByte, SizeOf(vByte));
   SetLength(vFieldName, vByte);
   AStream.Read(vFieldName[InitStrPos], vByte);
   FFieldNames[I] := vFieldName;
   // field type
   AStream.Read(vFieldType, SizeOf(vFieldType));
   FFieldTypes[I] := vFieldType;
   // field size
   AStream.Read(vFieldSize, SizeOf(vFieldSize));
   FFieldSize[I] := vFieldSize;
   // field precision
   AStream.Read(vFieldPrecision, SizeOf(vFieldPrecision));
   {$IFDEF FPC}
    If vFieldType in [dwftSingle, dwftFloat, dwftFMTBcd, dwftBCD] Then
     If vFieldType in [dwftFloat, dwftFMTBcd, dwftBCD] Then
      Begin
       If (vFieldPrecision    < 12) Or
          (FFieldPrecision[I] =  0) Then
        FFieldPrecision[I] := 12;
      End
     Else
      Begin
       If (vFieldPrecision    < 8) Or
          (FFieldPrecision[I] = 0) Then
        FFieldPrecision[I] := 8;
      End;
   {$ELSE}
    FFieldPrecision[I] := vFieldPrecision;
    If vFieldType in [dwftSingle] Then
     If vFieldPrecision < 12 Then
      FFieldPrecision[I] := 12;
   {$ENDIF}
   // required + provider flags
   AStream.Read(vFieldProviderFlags, SizeOf(Byte));
   FFieldAttrs[I]     := vFieldProviderFlags;
   // field is persistent or no fields persistet
   FFieldExists[I]    := (ADataSet.FindField(FFieldNames[I]) <> nil); // or (vNoFields);
    // create fieldsDefs like fields persistent
   If ((vNoFields) Or (Not FFieldExists[I])) Then
    CreateFieldDefs(ADataSet, I);
  End;
 ADataSet.Open;
 // provider flags deve ser recolocado depois dos fields criados  se nao existiam
 If (vNoFields) Then
  Begin
   For I := 0 to vFieldsCount-1 do
    Begin
     vField := ADataSet.FindField(FFieldNames[I]);
     If vField <> Nil Then
      Begin
       vField.ProviderFlags := [];
       If FFieldAttrs[I]  And 2 > 0  Then
        vField.ProviderFlags := vField.ProviderFlags + [pfInUpdate];
       If FFieldAttrs[I]  And 4 > 0  Then
        vField.ProviderFlags := vField.ProviderFlags + [pfInWhere];
       If FFieldAttrs[I]  And 8 > 0  Then
        vField.ProviderFlags := vField.ProviderFlags + [pfInKey];
       If FFieldAttrs[I]  And 16 > 0 Then
        vField.ProviderFlags := vField.ProviderFlags + [pfHidden];
       {$IFDEF RESTDWLAZARUS}
        If FFieldAttrs[I] And 32 > 0 Then
         vField.ProviderFlags := vField.ProviderFlags + [pfRefreshOnInsert];
        If FFieldAttrs[I] And 64 > 0 Then
         vField.ProviderFlags := vField.ProviderFlags + [pfRefreshOnUpdate];
       {$ENDIF}
      End;
    End;
  End;
 ADataSet.DisableControls;
 Try
  LoadRecordDWMemFromStream(IDataset, AStream);
 Finally
  ADataSet.EnableControls;
  AStream := Nil;
  AStream.Free;
 End;
End;

Procedure TRESTDWStorageBin.LoadRecordDWMemFromStream(Dataset : IRESTDWMemTable;
                                                      stream  : TStream);
Var
 I, B,
 vFieldCount   : DWInteger;
 vRecCount     : DWInt64;
 vVarBytes     : TRESTDWBytes;
 aField        : TField;
 aIndex        : Integer;
 vDataset      : TRESTDWMemTable;
 vActualRecord : TRESTDWMTMemoryRecord;
 vDataType     : TFieldType;
 vDWFieldType  : Byte;
 pData         : {$IFDEF FPC} PAnsiChar {$ELSE} PByte {$ENDIF};
 pActualRecord : PRESTDWMTMemBuffer;
 V6            : DWFloat;
 S             : DWString;
 vString       : DWString;
 vWideString   : DWWideString;
// vDWWideString : DWWideString;
 vInt          : DWInteger;
 vLength       : DWWord;
 vBoolean      : Boolean;
 vInt64        : DWInt64;
 vSingle       : DWSingle;
 vDouble       : DWDouble;
 vWord         : DWWord;
 vCurrency     : DWCurrency;
 vTimeStamp    : {$IFDEF FPC} TTimeStamp {$ELSE} TSQLTimeStamp {$ENDIF};
 {$IFDEF FPC}
 vTimeStampLaz   : TDateTime;
 {$ELSE}
 vTimeStampDelphi : TDateTime;
 {$ENDIF}
 vBCD          : DWBcd;
 vBytes        : TRESTDWBytes;
 vTimeZone     : DWDouble;
 vDateTimeRec  : TDateTimeRec;
 vByte         : Byte;
 {$IFNDEF FPC}
  {$IF CompilerVersion >= 21}
   vTimeStampOffset: TSQLTimeStampOffset;
  {$IFEND}
 {$ENDIF}
 Procedure tratarNulos;
 Begin
  If aField = nil Then
   Exit;
  If (vDWFieldType In [dwftFixedWideChar,
                       dwftWideString,
                       dwftFixedChar,
                       dwftString,
                       dwftOraClob,
                       dwftWideMemo,
                       dwftFmtMemo,
                       dwftMemo]) Then
   Begin
    vLength := Dataset.GetCalcFieldLen(aField.DataType, aField.Size);
    {$IFDEF FPC}
     FillChar(PData^, vLength -1, #0);
    {$ELSE}
     FillChar(pData^, vLength -1, 0);
    {$ENDIF}
   End
  Else If (vDWFieldType In [dwftLongWord,
                            dwftByte,
                            dwftShortint,
                            dwftSmallint,
                            dwftWord,
                            dwftInteger,
                            dwftSingle,
                            dwftExtended,
                            dwftFloat,
                            dwftOraTimeStamp,
                            dwftBCD,
                            dwftFMTBcd,
                            dwftCurrency,
                            dwftDate,
                            dwftTime,
                            dwftDateTime,
                            dwftTimeStampOffset,
                            dwftAutoInc,
                            dwftLargeint,
                            dwftTimeStamp]) Then
   Begin
    If Not (vDWFieldType In [dwftByte,
                             dwftShortint]) Then
     Begin
      vLength := Dataset.GetCalcFieldLen(aField.DataType, aField.Size);
      {$IFDEF FPC}
       FillChar(PData^, vLength, #0);
       Move(vBoolean, pData^, SizeOf(Boolean));
      {$ELSE}
       {$IF CompilerVersion <= 22}
        FillChar(PData^, vLength, #0);
       {$IFEND}
       Move(vBoolean, pData^, SizeOf(Boolean));
      {$ENDIF}
     End
    Else If vBoolean Then
     FillChar(pData^, 1, 'S');
   End
  Else If (vDWFieldType In [dwftBoolean]) Then
   FillChar(pData^, 2, 0);
 End;
Begin
 pActualRecord := Nil;
 vDataset      := TRESTDWMemTable(Dataset.GetDataset);
 stream.Read(vRecCount, SizeOf(vRecCount));
 vRecCount     := vRecCount - 1;
 vFieldCount   := Length(FFieldNames);
 vFieldCount   := vFieldCount - 1;
 For i := 0 To vRecCount Do
  Begin
   pActualRecord := PRESTDWMTMemBuffer(Dataset.AllocRecordBuffer);
   {$IFDEF RESTDWANDROID}
    Dataset.InternalAddRecord(nativeint(pActualRecord), True);
   {$ELSE}
    Dataset.InternalAddRecord(pActualRecord, True);
   {$ENDIF}
   vActualRecord := Dataset.GetMemoryRecord(i);
   For b := 0 To vFieldCount Do
    Begin
     vBoolean      := False;
     stream.Read(vBoolean, SizeOf(boolean));
     SetLength(vVarBytes, 0);
     aField := vDataset.FindField(FFieldNames[b]);
     If aField <> Nil Then
      Begin
       aIndex := aField.FieldNo - 1;
       If (aIndex < 0) Then
        Continue;
       vDataType := aField.DataType;
      End
     Else
      vDataType := DWFieldTypeToFieldType(FFieldTypes[b]);
     vDWFieldType := FFieldTypes[b];
     pData := nil;
     If (pActualRecord <> Nil) Then
      Begin
       If aField <> Nil Then
        Begin
         If Dataset.DataTypeSuported(vDataType) Then
          Begin
           If Dataset.DataTypeIsBlobTypes(vDataType) Then
            pData := Pointer(Dataset.GetBlob(-1, aField.Offset))
           Else
            pData := Pointer(pActualRecord + Dataset.GetOffSets(aField));
          End;
        End;
       tratarNulos;
       If Not vBoolean Then
        Continue;
       If (pData <> Nil) Or (aField = Nil) Then
        Begin
         // N Bytes - WideString
          case vDWFieldType Of
          dwftWideString,
          dwftFixedWideChar    :Begin
                                  stream.Read(vInt64, SizeOf(vInt64));
                                  vWideString := '';
                                  If vInt64 > 0 Then
                                   Begin
                                    SetLength(vWideString, vInt64);
                                    {$IFDEF FPC}
                                     stream.Read(Pointer(vString)^, vInt64);
                                     If EncodeStrs Then
                                      vString := DecodeStrings(vString,  Dataset.GetDatabaseCharSet);
                                     vString := GetStringEncode(vString, Dataset.GetDatabaseCharSet);
                                     vInt64 := (Length(vString) + 1) * SizeOf(WideChar);
                                     If aField <> Nil Then
                                      Move(Pointer(WideString(vString))^, PData^, vInt64);
                                    {$ELSE}
                                     stream.Read(vWideString[InitStrPos], vInt64);
                                     If EncodeStrs Then
                                      vString := DecodeStrings(vWideString)
                                     Else
                                      vString := Trim(vWideString);
//                                     vInt64 := (Length(vString) + 1);// * SizeOf(WideChar);
                                     If aField <> Nil Then
                                      Move(vString[InitStrPos], pData^, Length(vString));
                                    {$ENDIF}
                                   End;
                                 End;
           // N Bytes - Strings
           dwftFixedChar,
           dwftString            :Begin
                                    stream.Read(vInt64, SizeOf(vInt64));
                                    vString := '';
                                    If vInt64 > 0 Then
                                     Begin
                                      SetLength(vString, vInt64);
                                      {$IFDEF FPC}
                                       stream.Read(Pointer(vString)^, vInt64);
                                       If EncodeStrs Then
                                        vString := DecodeStrings(vString,  Dataset.GetDatabaseCharSet);
                                       vString := GetStringEncode(vString, Dataset.GetDatabaseCharSet);
                                       If aField <> Nil Then
                                        Move(Pointer(vString)^, pData^, Length(vString));
                                      {$ELSE}
                                       stream.Read(vString[InitStrPos], vInt64);
                                       If EncodeStrs Then
                                        vString := DecodeStrings(vString);
                                       If aField <> Nil Then
                                        Move(vString[InitStrPos], pData^, Length(vString));
                                      {$ENDIF}
                                     End;
                                  End;
           // 1 - Byte - Inteiro
           dwftByte,
           dwftShortint           :Begin
                                     stream.Read(vByte, SizeOf(vByte));
                                     If aField <> Nil Then
                                      Move(vByte, PData^, Sizeof(vByte));
                                   End;
                                   // 1 - Byte - Boolean
          dwftBoolean             :Begin
                                     setlength(vVarBytes, 0);
                                     setlength(vVarBytes, 2);
                                     Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                     stream.Read(vBoolean,        SizeOf(vBoolean));
                                     Move(vBoolean, vVarBytes[1], Sizeof(Boolean));
                                     If aField <> Nil Then
                                      Move(vVarBytes[0], PData^, Sizeof(vBoolean) + Sizeof(vBoolean));
                                   End;
           // 2 - Bytes
           dwftSmallint,
           dwftWord               :Begin
                                     stream.Read(vWord, SizeOf(vWord));
                                     If aField <> Nil Then
                                      Begin
                                       SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vWord));
                                       //Move Null para Bytes
                                       Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                       //Move Bytes do Dado para Bytes
                                       Move(vWord, vVarBytes[1], Sizeof(vWord));
                                       //Move Bytes para Buffer
                                       Move(vVarBytes[0], PData^, Sizeof(Boolean) + Sizeof(vWord));
                                      End;
                                   End;
           // 4 - Bytes - Inteiros
           dwftInteger            :Begin
                                     stream.Read(vInt, SizeOf(vInt));
                                     If aField <> Nil Then
                                      Begin
                                       SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vInt));
                                       //Move Null para Bytes
                                       Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                       //Move Bytes do Dado para Bytes
                                       Move(vInt, vVarBytes[1], Sizeof(vInt));
                                       //Move Bytes para Buffer
                                       Move(vVarBytes[0], PData^, Sizeof(Boolean) + Sizeof(vInt));
                                      End;
                                   End;
           // 4 - Bytes - Flutuantes
           dwftSingle             :Begin          // Gledston
                                     vLength := SizeOf(vDouble);
                                     stream.Read(vDouble, vLength);
                                     If aField <> Nil Then
                                      Begin
                                       //Move(vSingle,PData^,Sizeof(vSingle));
                                       SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vDouble));
                                       //Move Null para Bytes
                                       Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                       //Move Bytes do Dado para Bytes
                                       Move(vDouble, vVarBytes[1], Sizeof(vDouble));
                                       //Move Bytes para Buffer
                                       Move(vVarBytes[0], PData^, Length(vVarBytes));
                                      End;
                                   End;
           // 8 - Bytes - Inteiros
           dwftLargeint,
           dwftAutoInc,
           dwftLongWord           :Begin
                                     stream.Read(vInt64, SizeOf(vInt64));
                                     If aField <> Nil Then
                                      Begin
                                       SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vInt64));
                                       //Move Null para Bytes
                                       Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                       //Move Bytes do Dado para Bytes
                                       Move(vInt64, vVarBytes[1], Sizeof(vInt64));
                                       //Move Bytes para Buffer
                                       Move(vVarBytes[0], PData^, Length(vVarBytes));
                                      End;
                                   End;
           // 8 - Bytes - Flutuantes
           dwftFloat              :Begin
                                     stream.Read(vDouble, SizeOf(vDouble));
                                     If aField <> Nil Then
                                      Begin
                                       SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vDouble));
                                       //Move Null para Bytes
                                       Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                       //Move Bytes do Dado para Bytes
                                       Move(vDouble, vVarBytes[1], Sizeof(vDouble));
                                       //Move Bytes para Buffer
                                       Move(vVarBytes[0], PData^, Length(vVarBytes));
                                      End;
                                   End;
           //dwftExtended           :Begin
           //                          stream.Read(vDouble, SizeOf(Extended));
           //                          If aField <> Nil Then
           //                           Begin
           //                            SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(Extended));
           //                            //Move Null para Bytes
           //                            Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
           //                            //Move Bytes do Dado para Bytes
           //                            Move(vDouble, vVarBytes[1], Sizeof(Extended));
           //                            //Move Bytes para Buffer
           //                            {$IFDEF FPC}
           //                              PRESTDWBytes(pData)^ := vVarBytes;
           //                            {$ELSE}
           //                              Move(vVarBytes[0], PData^, Sizeof(Boolean) + Sizeof(vDouble));
           //                            {$ENDIF}
           //                           End;
           //                        End;
           // 8 - Bytes - Date, Time, DateTime, TimeStamp
           dwftDate,
           dwftTime,
           dwftDateTime,
           dwftTimeStamp          : Begin
                                     stream.Read(vDouble, SizeOf(vDouble));
                                     If aField <> Nil Then
                                      Begin
                                       SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vDouble));
                                       //Move Null para Bytes
                                       Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                       //Move Bytes do Dado para Bytes
                                       Case vDataType Of
                                        ftDate      : vDouble := DateTimeToTimeStamp(vDouble).Date;
//                                        ftTimeStamp : vDouble := TimeStampToMSecs(DateTimeToTimeStamp(vDouble));
                                       End;
                                       Move(vDouble, vVarBytes[1], Sizeof(vDouble));
                                       //Move Bytes para Buffer
                                       Move(vVarBytes[0], PData^, Length(vVarBytes));
                                      End;
                                   End;
           // TimeStampOffSet To Double - 8 Bytes
           // + TimeZone                - 2 Bytes
           dwftTimeStampOffset    :Begin
                                     {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
                                      stream.Read(vDouble, SizeOf(vDouble));
                                      vTimeStampOffSet := DateTimeToSQLTimeStampOffset(vDouble);
                                      stream.Read(vByte,   SizeOf(vByte));
                                      vTimeStampOffSet.TimeZoneHour := vByte - 12;
                                      stream.Read(vByte,   SizeOf(vByte));
                                      vTimeStampOffSet.TimeZoneMinute := vByte;
                                      If aField <> Nil Then
                                       Move(vTimeStampOffSet, PData^, Sizeof(vTimeStampOffSet));
                                     {$ELSE}
                                      // field foi transformado em tdatetime
                                      stream.Read(vDouble, SizeOf(vDouble));
                                      stream.Read(vByte,   SizeOf(vByte));
                                      vTimeZone := (vByte - 12) / 24;
                                      stream.Read(vByte, SizeOf(vByte));
                                      If vTimeZone > 0 Then
                                       vTimeZone := vTimeZone + (vByte / 60 / 24)
                                      Else
                                       vTimeZone := vTimeZone - (vByte / 60 / 24);
                                      vDouble := vDouble - vTimeZone;
                                      If aField <> Nil Then
                                       Begin
                                        {$IFDEF FPC}
                                         vDateTimeRec := DateTimeToDateTimeRec(vDataType, TDateTime(vDouble));
                                         Move(vDateTimeRec, PData^, SizeOf(vDateTimeRec));
                                        {$ELSE}
                                         Case vDataType Of
                                          ftDate : vDateTimeRec.Date := DateTimeToTimeStamp(vDouble).Date;
                                          ftTime : vDateTimeRec.Time := DateTimeToTimeStamp(vDouble).Time;
                                          Else vDateTimeRec.DateTime := TimeStampToMSecs(DateTimeToTimeStamp(vDouble));
                                         End;
                                         Move(vDateTimeRec, pData^, SizeOf(vDateTimeRec));
                                        {$ENDIF}
                                       End;
                                     {$IFEND}
                                   End;
           // 8 - Bytes - Currency
           dwftCurrency           :Begin
                                     stream.Read(vCurrency, SizeOf(vCurrency));
                                     If aField <> Nil Then
                                      Begin
                                       SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vCurrency));
                                       //Move Null para Bytes
                                       Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                       vString := CurrToStr(vCurrency);               //Gledston acresentei estas linhas
                                       V6      := StrtoFloat(vString);
                                       //Move Bytes do Dado para Bytes
                                       Move(V6, vVarBytes[1], Sizeof(V6));
                                       //Move Bytes para Buffer
                                       Move(vVarBytes[0], PData^, Length(vVarBytes));
                                      End;
                                   End;
           // 8 - Bytes - Currency
          dwftBCD                 :Begin
                                     stream.Read(vCurrency, SizeOf(vCurrency));
                                     If aField <> Nil Then
                                      Begin
                                       {$IFDEF FPC}
                                        SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vCurrency));
                                        //Move Null para Bytes
                                        Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                        //Move Bytes do Dado para Bytes
                                        Move(vCurrency, vVarBytes[1], Sizeof(vCurrency));
                                        //Move Bytes para Buffer
                                        Move(vVarBytes[0], PData^, Length(vVarBytes));
                                       {$ELSE}
                                        {$IF CompilerVersion <= 21}
                                         CurrToBCD(vCurrency, vBCD);
                                        {$ELSE}
                                         vBCD := CurrencyToBcd(vCurrency);
                                        {$IFEND}
                                        SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vBCD));
                                        //Move Null para Bytes
                                        Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                        //Move Bytes do Dado para Bytes
                                        Move(vBCD, vVarBytes[1], Sizeof(vBCD));
                                        //Move Bytes para Buffer
                                        Move(vVarBytes[0], PData^, Sizeof(Boolean) + Sizeof(vBCD));
                                       {$ENDIF}
                                      End;
                                   End;
          // 8 - Bytes - Currency
          dwftFMTBcd              :Begin
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
                                     SetLength(vVarBytes, Sizeof(Boolean) + Sizeof(vBCD));
                                     //Move Null para Bytes
                                     Move(vBoolean, vVarBytes[0], Sizeof(Boolean));
                                     //Move Bytes do Dado para Bytes
                                     Move(vBCD, vVarBytes[1], Sizeof(vBCD));
                                     //Move Bytes para Buffer
                                     Move(vVarBytes[0], PData^, Sizeof(Boolean) + Sizeof(vBCD));
                                   End;
           //N Bytes - String Blobs
          dwftWideMemo,
          dwftFmtMemo,
          dwftOraClob,
          dwftMemo                :Begin
                                     stream.Read(vInt64, SizeOf(vInt64));
                                     vString := '';
                                     If vInt64 > 0 Then
                                      Begin
                                       SetLength(vString, vInt64);
                                       {$IFDEF FPC}
                                        stream.Read(Pointer(vString)^, vInt64);
                                        If EncodeStrs Then
                                         vString := DecodeStrings(vString, csUndefined);
                                        vString := GetStringEncode(vString, csUndefined);
                                       {$ELSE}
                                        stream.Read(vString[InitStrPos], vInt64);
                                        If EncodeStrs Then
                                         vString := DecodeStrings(vString);
                                       {$ENDIF}
                                       vInt64 := Length(vString) + 1;
                                       Try
                                        SetLength(vBytes, vInt64);
                                        Move(vString[InitStrPos], vBytes[0], vInt64);
                                        If aField <> Nil Then
                                         PRESTDWBytes(pData)^ := vBytes;
                                       Finally
                                        SetLength(vBytes, 0);
                                       End;
                                      End;
                                   End;
           // N Bytes - Others Blobs
          dwftStream,
          dwftOraBlob,
          dwftBlob,
          dwftBytes               :Begin
                                     SetLength(vBytes, 0);
                                     stream.Read(vInt64, SizeOf(DWInt64));
                                     If vInt64 > 0 Then
                                      Begin
                                       // Actual TODO XyberX
                                       SetLength(vBytes, vInt64);
                                       stream.Read(vBytes[0], vInt64);
                                      End;
                                     Try
                                      If Length(vBytes) > 0 Then
                                       Begin
                                        If aField <> Nil Then
                                         PRESTDWBytes(pData)^ := vBytes;
                                       End;
                                     Finally
                                      SetLength(vBytes, 0);
                                     End;
                                   End;
          // N Bytes - Others
          Else
            Begin
             stream.Read(vInt64, SizeOf(vInt64));
             vString := '';
             If vInt64 > 0 Then
              Begin
               SetLength(vString, vInt64);
               {$IFDEF FPC}
                stream.Read(Pointer(vString)^, vInt64);
                If EncodeStrs Then
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
          End;
        End;
      End;
     SetLength(vVarBytes, 0);
    End;
   Try
    Dataset.SetMemoryRecordData(pActualRecord, i);
   Finally
    Dispose(pActualRecord);//FreeMem(PRESTDWMTMemBuffer(@PActualRecord));
   End;
  End;
End;

Procedure TRESTDWStorageBin.LoadRecordFromStream(ADataset : TDataset;
                                                 AStream  : TStream);
Var
 vField         : TField;
 vString        : DWString;
 vInt64         : DWInt64;
 I,
 vInt           : DWInteger;
 vDouble,
 vTimeZone      : DWDouble;
 vSingle        : DWSingle;
 vSmallint      : DWSmallint;
 vCurrency      : DWCurrency;
 vMemoryAStream : TMemoryStream;
 vBoolean       : Boolean;
 vByte          : Byte;
 {$IFDEF DELPHIXEUP}
  vTimeStampOffset : TSQLTimeStampOffset;
 {$ENDIF}
Begin
 For I := 0 To Length(FFieldTypes) -1 Do
  Begin
   vField := ADataset.Fields[i];
   vField.Clear;
   AStream.Read(vBoolean, Sizeof(Byte));
   If Not vBoolean Then // is null
    Continue;
    // N - Bytes
   If (FFieldTypes[i] In [dwftFixedChar,
                          dwftWideString,
                          dwftString,
                          dwftFixedWideChar]) Then
    Begin
     AStream.Read(vInt64, Sizeof(vInt64));
     vString := '';
     If vInt64 > 0 Then
      Begin
       SetLength(vString, vInt64);
       {$IFDEF FPC}
        AStream.Read(Pointer(vString)^, vInt64);
        If EncodeStrs Then
         vString := DecodeStrings  (vString, csUndefined);
        vString  := GetStringEncode(vString, csUndefined);
       {$ELSE}
        AStream.Read(vString[InitStrPos], vInt64);
        If EncodeStrs Then
         vString := DecodeStrings(vString);
       {$ENDIF}
      End;
     vField.AsString := vString;
    End
    // 1 - Byte - Inteiro
   Else If (FFieldTypes[i] In [dwftByte,
                               dwftShortint]) Then
    Begin
     AStream.Read(vByte, Sizeof(vByte));
     vField.AsInteger := vByte;
    End
    // 1 - Byte - Boolean
   Else If (FFieldTypes[i] In [dwftBoolean]) Then
    Begin
     AStream.Read(vBoolean, Sizeof(vBoolean));
     vField.AsBoolean := vBoolean;
    End
    // 2 - Bytes
   Else If (FFieldTypes[i] In [dwftSmallint,
                               dwftWord])    Then
    Begin
     AStream.Read(vSmallint, Sizeof(vSmallint));
     vField.AsInteger := vSmallint;
    End
    // 4 - Bytes - Inteiros
   Else If (FFieldTypes[i] In [dwftInteger]) Then
    Begin
     AStream.Read(vInt, Sizeof(vInt));
     vField.AsInteger := vInt;
    End
    // 4 - Bytes - Flutuantes
   Else If (FFieldTypes[i] In [dwftSingle]) Then
    Begin
     AStream.Read(vSingle, Sizeof(vSingle));
     {$IFDEF DELPHIXEUP}
      vField.AsSingle := vSingle;
     {$ELSE}
      vField.AsFloat := vSingle;
     {$ENDIF}
    End
    // 8 - Bytes - Inteiros
   Else If (FFieldTypes[i] In [dwftLargeint,
                               dwftAutoInc,
                               dwftLongWord]) Then
    Begin
     AStream.Read(vInt64, Sizeof(vInt64));
     {$IFDEF DELPHIXEUP}
      vField.AsLargeInt := vInt64;
     {$ELSE}
      vField.AsInteger := vInt64;
     {$ENDIF}
    End
    // 8 - Bytes - Flutuantes
   Else If (FFieldTypes[i] In [dwftFloat,
                               dwftExtended]) Then
    Begin
     AStream.Read(vDouble, Sizeof(vDouble));
     vField.AsFloat := vDouble;
    End
    // 8 - Bytes - Date, Time, DateTime
   Else If (FFieldTypes[i] In [dwftDate,
                               dwftTime,
                               dwftDateTime]) Then
    Begin
     AStream.Read(vDouble, Sizeof(vDouble));
     vField.AsDateTime := vDouble;
    End
    // TimeStamp To Double - 8 Bytes
   Else If (FFieldTypes[i] In [dwftTimeStamp]) Then
    Begin
     AStream.Read(vDouble, Sizeof(vDouble));
     vField.AsDateTime := vDouble;
    End
   // TimeStampOffSet To Double - 8 Bytes
   // + TimeZone                - 2 Bytes
   Else If (FFieldTypes[i] In [dwftTimeStampOffset]) Then
    Begin
     {$IFDEF DELPHIXEUP}
      AStream.Read(vDouble, Sizeof(vDouble));
      vTimeStampOffset                := DateTimeToSQLTimeStampOffset(vDouble);
      AStream.Read(vByte, Sizeof(vByte));
      vTimeStampOffset.TimeZoneHour   := vByte - 12;
      AStream.Read(vByte, Sizeof(vByte));
      vTimeStampOffset.TimeZoneMinute := vByte;
      vField.AsSQLTimeStampOffset     := vTimeStampOffset;
     {$ELSE}
      // field foi transformado em datetime
      AStream.Read(vDouble, Sizeof(vDouble));
      AStream.Read(vByte,   SizeOf(vByte));
      vTimeZone  := (vByte - 12) / 24;
      AStream.Read(vByte,   SizeOf(vByte));
      If vTimeZone > 0 Then
       vTimeZone := vTimeZone + (vByte / 60 / 24)
      Else
       vTimeZone := vTimeZone - (vByte / 60 / 24);
      vDouble    := vDouble - vTimeZone;
      vField.AsDateTime := vDouble;
     {$ENDIF}
    End
    // 8 - Bytes - Currency
   Else If (FFieldTypes[i] In [dwftCurrency,
                               dwftBCD,
                               dwftFMTBcd]) Then
    Begin
     AStream.Read(vCurrency, Sizeof(vCurrency));
     vField.AsCurrency := vCurrency;
    End
    // N Bytes - Blobs
   Else If (FFieldTypes[i] In [dwftStream,
                               dwftBlob,
                               dwftOraBlob,
                               dwftBytes,
                               dwftMemo,
                               dwftWideMemo,
                               dwftOraClob,
                               dwftFmtMemo]) Then
    Begin
     AStream.Read(vInt64, Sizeof(vInt64));
     If vInt64 > 0 Then
      Begin
       vMemoryAStream := TMemoryStream.Create;
       Try
        vMemoryAStream.CopyFrom(AStream, vInt64);
        vMemoryAStream.Position := 0;
        TBlobField(vField).LoadFromStream(vMemoryAStream);
       Finally
        FreeAndNil(vMemoryAStream);
       End;
      End;
    End
   // N Bytes - Others
   Else
    Begin
     AStream.Read(vInt64, Sizeof(vInt64));
     vString := '';
     If vInt64 > 0 Then
      Begin
       SetLength(vString, vInt64);
       {$IFDEF FPC}
        AStream.Read(Pointer(vString)^, vInt64);
        If EncodeStrs Then
         vString := DecodeStrings(vString, csUndefined);
        vString := GetStringEncode(vString, csUndefined);
       {$ELSE}
        AStream.Read(vString[InitStrPos], vInt64);
        If EncodeStrs Then
         vString := DecodeStrings(vString);
       {$ENDIF}
      End;
     vField.AsString := vString;
    End;
  End;
End;

Procedure TRESTDWStorageBin.SaveDatasetToStream(ADataset    : TDataset;
                                                Var AStream : TStream);
Var
 i            : DWInteger;
 vRecordCount : DWInt64;
 vString      : DWString;
 vInt         : DWInt16;
 vBoolean     : Boolean;
 vByte        : Byte;
 vBookMark    : TBookmark;
Begin
 //  AStream.Size := 0; // TBufferedFileStream nao funciona no lazarus
 AStream.Seek(0,soBeginning);
 If Not ADataset.Active Then
  ADataset.Open
 Else
  ADataset.CheckBrowseMode;
 ADataset.UpdateCursorPos;
 // fields cound
 I        := ADataset.FieldCount;
 AStream.Write(i, SizeOf(I));
 // encodestr
 vBoolean := EncodeStrs;
 AStream.Write(vBoolean, SizeOf(vBoolean));
 I := 0;
 While i < ADataset.FieldCount Do
  Begin
   // field kind
   vByte   := Ord(ADataset.Fields[i].FieldKind);
   AStream.Write(vByte, SizeOf(vByte));
   // field name
   vString := ADataset.Fields[i].DisplayName;
   vByte   := Length(vString);
   AStream.Write(vByte, SizeOf(vByte));
   AStream.Write(vString[InitStrPos], vByte);
   // datatype
   vByte   := FieldTypeToDWFieldType(ADataset.Fields[i].DataType);
   Case vByte Of
    dwftFixedWideChar,
    dwftWideString : vByte := FieldTypeToDWFieldType(ftString);
    dwftSingle     : vByte := FieldTypeToDWFieldType(ftFloat);
   End;
   AStream.Write(vByte, SizeOf(vByte));
   // field size
   vInt    := ADataset.Fields[i].Size;
   AStream.Write(vInt, SizeOf(vInt));
   // field precision
   vInt := 0;
   If ADataset.Fields[i].InheritsFrom(TFloatField) Then
    vInt := TFloatField(ADataset.Fields[i]).Precision;
   AStream.Write(vInt, SizeOf(vInt));
   // requeired + provider flags
   vByte := 0;
   If ADataset.Fields[i].Required Then
    vByte := vByte + 1;
   If pfInUpdate In ADataset.Fields[i].ProviderFlags Then
    vByte := vByte + 2;
   If pfInWhere  In ADataset.Fields[i].ProviderFlags Then
    vByte := vByte + 4;
   If pfInKey    In ADataset.Fields[i].ProviderFlags Then
    vByte := vByte + 8;
   If pfHidden   In ADataset.Fields[i].ProviderFlags Then
    vByte := vByte + 16;
   {$IFDEF RESTDWLAZARUS}
    If pfRefreshOnInsert In ADataset.Fields[i].ProviderFlags Then
     vByte := vByte + 32;
    If pfRefreshOnUpdate in ADataset.Fields[i].ProviderFlags Then
     vByte := vByte + 64;
   {$ENDIF}
   AStream.Write(vByte, SizeOf(vByte));
   I := I + 1;
  End;
 I := AStream.Position;
 // marcando position do recordcount = 0
 vRecordCount := 0;
 AStream.WriteBuffer(vRecordCount, SizeOf(vRecordCount));
 If Not ADataset.IsUniDirectional Then
  vBookMark := ADataset.GetBookmark;
 ADataset.DisableControls;
 If Not ADataset.IsUniDirectional Then
  ADataset.First;
 vRecordCount := 0;
 While Not ADataset.Eof Do
  Begin
   Try
    SaveRecordToStream(ADataset,AStream);
   Except
   End;
   ADataset.Next;
   vRecordCount := vRecordCount + 1;
  End;
 If Not ADataset.IsUniDirectional Then
  Begin
   ADataset.GotoBookmark(vBookMark);
   ADataset.FreeBookmark(vBookMark);
  End;
 ADataset.EnableControls;
 // marcando novo valor de recordcount
 AStream.Position := i;
 AStream.WriteBuffer(vRecordCount,SizeOf(vRecordCount));
 AStream.Position := 0;
End;

Procedure TRESTDWStorageBin.SaveDWMemToStream(IDataset    : IRESTDWMemTable;
                                              Var AStream : TStream);
Var
 ADataset     : TRESTDWMemTable;
 I            : DWInteger;
 vRecordCount : DWInt64;
 vString      : DWString;
 vInt         : DWInt16;
 vBoolean     : Boolean;
 vByte        : Byte;
 vBookMark    : TBookmark;
Begin
 ADataSet := TRESTDWMemTable(IDataset.GetDataset);
 AStream.Size := 0;
 If not ADataset.Active Then
  ADataset.Open
 Else
  ADataset.CheckBrowseMode;
 ADataset.UpdateCursorPos;
 // field count
 i := ADataset.FieldCount;
 AStream.Write(i, SizeOf(I));
 // encode str
 vBoolean := EncodeStrs;
 AStream.Write(vBoolean, SizeOf(vBoolean));
 I := 0;
 While I < ADataset.FieldCount Do
  Begin
   // fieldkind
   vByte   := Ord(ADataset.Fields[i].FieldKind);
   AStream.Write(vByte, SizeOf(vByte));
   // fieldname
   vString := ADataset.Fields[i].DisplayName;
   vByte   := Length(vString);
   AStream.Write(vByte, SizeOf(vByte));
   AStream.Write(vString[InitStrPos], vByte);
   // datatype
   vByte := FieldTypeToDWFieldType(ADataset.Fields[i].DataType);
   Case vByte Of
    dwftFixedWideChar,
    dwftWideString : vByte := FieldTypeToDWFieldType(ftString);
    dwftSingle     : vByte := FieldTypeToDWFieldType(ftFloat);
   End;
 AStream.Write(vByte, SizeOf(vByte));
   // fieldsize
   vInt := ADataset.Fields[i].Size;
   AStream.Write(vInt, SizeOf(vInt));
   // field precision
   vInt := 0;
   If ADataset.Fields[i].InheritsFrom(TFloatField) Then
    vInt := TFloatField(ADataset.Fields[i]).Precision;
   AStream.Write(vInt, SizeOf(vInt));
   // required + provider flags
   vByte := 0;
   If ADataset.Fields[i].Required Then
    vByte := vByte + 1;
   If pfInUpdate In ADataset.Fields[i].ProviderFlags         Then
    vByte := vByte + 2;
   If pfInWhere in ADataset.Fields[i].ProviderFlags          Then
    vByte := vByte + 4;
   If pfInKey In ADataset.Fields[i].ProviderFlags            Then
    vByte := vByte + 8;
   If pfHidden In ADataset.Fields[i].ProviderFlags           Then
    vByte := vByte + 16;
   {$IFDEF RESTDWLAZARUS}
    If pfRefreshOnInsert In ADataset.Fields[i].ProviderFlags Then
     vByte := vByte + 32;
    If pfRefreshOnUpdate In ADataset.Fields[i].ProviderFlags Then
     vByte := vByte + 64;
   {$ENDIF}
   AStream.Write(vByte, SizeOf(vByte));
   i := i + 1;
  End;
 I := AStream.Position;
 // marcando position recordcount = 0
 vRecordCount := 0;
 AStream.WriteBuffer(vRecordCount, SizeOf(vRecordCount));
 vRecordCount := SaveRecordDWMemToStream(IDataSet,AStream);
 // salvando novo valor de recordcount
 AStream.Position := i;
 AStream.WriteBuffer(vRecordCount, SizeOf(vRecordCount));
 AStream.Position := 0;
End;

Function TRESTDWStorageBin.SaveRecordDWMemToStream(Dataset : IRESTDWMemTable;
                                                   stream  : TStream) : Longint;
Var
 vDataSet      : TRESTDWMemTable;
 I, B, aIndex  : DWInteger;
 vActualRecord : TRESTDWMTMemoryRecord;
 PActualRecord : PRESTDWMTMemBuffer;
 PData         : {$IFDEF FPC}PAnsiChar{$ELSE}PByte{$ENDIF};
 vDataType     : TFieldType;
 vDWFieldType  : Byte;
 vFieldCount   : DWInteger;
 vString       : DWString;
 vInt64        : DWInt64;
 vCardinal     : DWCardinal;
 vInt          : DWInteger;
 vByte         : Byte;
 vWord         : Word;
 vSingle       : DWSingle;
 vDouble       : DWDouble;
 vCurrency     : DWCurrency;
 vBCD          : DWBCD;
 vMemoryStream : TMemoryStream;
 vBoolean      : Boolean;
 vRESTDWBytes  : TRESTDWBytes;
 vTimeStamp    : {$IFDEF FPC} TTimeStamp {$ELSE} TSQLTimeStamp {$ENDIF};
 {$IFNDEF FPC}
   {$IF CompilerVersion >= 21}
     vTimeStampOffSet : TSQLTimeStampOffset;
   {$IFEND}
 {$ENDIF}
Begin
 vDataSet    := TRESTDWMemTable(dataset.GetDataset);
 vFieldCount := vDataSet.Fields.Count - 1;
 Result      := dataset.GetRecordCount - 1;
 For I := 0 To Result Do
  Begin
   vActualRecord := Dataset.GetMemoryRecord(I);
   pActualRecord := PRESTDWMTMemBuffer(vActualRecord.Data);
   vBoolean      := False;
   For B := 0 To vFieldCount Do
    Begin
     aIndex := vDataSet.Fields[B].FieldNo - 1;
     If (aIndex >= 0) And (PActualRecord <> Nil) Then
      Begin
       vDataType := vDataSet.FieldDefs[aIndex].DataType;
       {$IFNDEF FPC}
        {$IF compilerversion < 21}
         vBoolean  := vDataSet.Fields[B].Size > 0;
        {$ELSE}
         vBoolean  := vDataSet.Fields[B].IsNull;
        {$IFEND}
       {$ELSE}
        vBoolean  := vDataSet.Fields[B].IsNull;
       {$ENDIF}
       vBoolean := Not vBoolean;
       Stream.Write(vBoolean, SizeOf(boolean));
       If Not vBoolean Then
        Continue;
       If Dataset.DataTypeSuported(vDataType) Then
        Begin
         If Dataset.DataTypeIsBlobTypes(vDataType) Then
          PData    := Pointer(@PMemBlobArray(PActualRecord + Dataset.GetOffSetsBlobs)^[vDataSet.Fields[B].Offset])
         Else
          PData    := Pointer(PActualRecord + dataset.GetOffSets(vDataSet.Fields[B]));
        End;
       vDWFieldType := FieldTypeToDWFieldType(vDataType);
       // N Bytes
       Case vDWFieldType Of
        dwftFixedChar,
        dwftWideString,
        dwftFixedWideChar  : Begin
                              {$IFDEF RESTDWANDROID}
                               vString := MarshaledAString(PData);
                              {$ELSE}
                               SetLength(vRESTDWBytes, vDataSet.Fields[B].Size);
                               Try
                                Move(PRESTDWBytes(@Pdata)^[0], vRESTDWBytes[0], vDataSet.Fields[B].Size);
                                vString := StringReplace(BytesToString(vRESTDWBytes, false), #0, '', [rfReplaceAll]);
                               Finally
                                SetLength(vRESTDWBytes, 0);
                               End;
                              {$ENDIF}
                              If EncodeStrs Then
                               vString := EncodeStrings(vString{$IFDEF FPC}, csUndefined{$ENDIF});
                              vInt64   := Length(vString)* SizeOf(vString[1]);
                              Stream.Write(vInt64, Sizeof(vInt64));
                              {$IFNDEF FPC}
                               If vInt64 <> 0 Then
                                Stream.Write(vString[InitStrPos], vInt64);
                              {$ELSE}
                               If vInt64 <> 0 Then
                                Stream.Write(vString[1], vInt64);
                              {$ENDIF}
                             End;
        dwftString         : Begin
                              {$IFDEF RESTDWANDROID}
                               vString := MarshaledAString(PData);
                              {$ELSE}
                               SetLength(vRESTDWBytes, vDataSet.Fields[B].Size);
                               Try
                                Move(PRESTDWBytes(@Pdata)^[0], vRESTDWBytes[0], vDataSet.Fields[B].Size);
                                vString := StringReplace(BytesToString(vRESTDWBytes, false), #0, '', [rfReplaceAll]);
                               Finally
                                SetLength(vRESTDWBytes, 0);
                               End;
                              {$ENDIF}
                              If EncodeStrs Then
                               vString := EncodeStrings(vString{$IFDEF FPC}, csUndefined{$ENDIF});
                              vInt64   := Length(vString);
                              Stream.Write(vInt64, Sizeof(vInt64));
                              {$IFNDEF FPC}
                               If vInt64 <> 0 Then
                                Stream.Write(vString[InitStrPos], vInt64);
                              {$ELSE}
                               If vInt64 <> 0 Then
                                Stream.Write(vString[1], vInt64);
                              {$ENDIF}
                             End;
        // 1 - Byte
        dwftByte,
        dwftShortint,
        dwftBoolean        : Begin
                              Move(PData^, vByte, Sizeof(vByte));
                              Stream.Write(vByte, Sizeof(vByte));
                             End;
        // 2 - Bytes
        dwftSmallint,
        dwftWord           : Begin
                              Move(PData^, vWord, Sizeof(vWord));
                              Stream.Write(vWord, Sizeof(vWord));
                             End;
        // 4 - Bytes - Inteiros
        dwftInteger        : Begin
                              Move(PData^, vInt, Sizeof(vInt));
                              Stream.Write(vByte, Sizeof(vInt));
                             End;
        // 4 - Bytes - Flutuantes
        dwftSingle         : Begin
                              Move(PData^, vDouble, Sizeof(vDouble));
                              Stream.Write(vDouble, Sizeof(vDouble));
                             End;
        // 8 - Bytes - Inteiros
        dwftLargeint,
        dwftAutoInc,
        dwftLongWord       : Begin
                              Move(PData^, vInt64, Sizeof(vInt64));
                              Stream.Write(vInt64, Sizeof(vInt64));
                             End;
        // 8 - Bytes - Flutuantes
        dwftFloat,
        dwftDate,
        dwftTime           : Begin
                              Move(PData^, vDouble, Sizeof(vDouble));
                              Stream.Write(vDouble, Sizeof(vDouble));
                             End;
       // TimeStamp To Double - 8 Bytes
        dwftDateTime,
        dwftTimeStamp      : Begin
                              SetLength(vRESTDWBytes, Sizeof(vTimeStamp));
                              Try
                               Move(PRESTDWBytes(@Pdata)^[0], vRESTDWBytes[0], Sizeof(vTimeStamp));
                               Stream.Write(vRESTDWBytes, Length(vRESTDWBytes));
                              Finally
                               SetLength(vRESTDWBytes, 0);
                              End;
                             End;
        {$IFNDEF FPC}
         {$IF CompilerVersion >= 21}
         // TimeStampOffSet To Double - 8 Bytes
         // + TimeZone                - 2 Bytes
         dwftTimeStampOffset : Begin
                                Move(PData^, vTimeStampOffSet, Sizeof(vTimeStampOffSet));
                                vDouble := SQLTimeStampOffsetToDateTime(vTimeStampOffSet);
                                Stream.Write(vDouble, Sizeof(vDouble));
                                vByte   := vTimeStampOffSet.TimeZoneHour + 12;
                                Stream.Write(vByte, Sizeof(vByte));
                                vByte := vTimeStampOffSet.TimeZoneMinute;
                                Stream.Write(vByte, Sizeof(vByte));
                               End;
         {$IFEND}
        {$ENDIF}
        // 8 - Bytes - Currency
       dwftCurrency          : Begin
                                Move(PData^, vCurrency, Sizeof(vCurrency));
                                Stream.Write(vCurrency, Sizeof(vCurrency));
                               End;
        // 8 - Bytes - Currency
       dwftBCD               : Begin
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
                               End;
        // 8 - Bytes - Currency
       dwftFMTBcd            : Begin
                                Move(PData^, vBCD, Sizeof(vBCD));
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
                               End;
        // N Bytes - Blobs
//       dwftWideMemo,
//       dwftFmtMemo,
//       dwftMemo,
       dwftStream,
       dwftBlob,
       dwftOraBlob,
       dwftBytes,
       dwftOraClob,
       dwftMemo,
       dwftWideMemo,
       dwftFmtMemo           : Begin
                                vMemoryStream := TMemoryStream.Create;
                                Try
                                 {$IFDEF RESTDWANDROID}
                                  vString := MarshaledAString(PData);
                                 {$ELSE}
                                  vString := Pansichar(PData);
                                 {$ENDIF}
                                 vInt64 := Length(vString);
                                 Stream.Write(vInt64, Sizeof(vInt64));
                                 vMemoryStream.Position := 0;
                                 Stream.CopyFrom(vMemoryStream, vInt64);
                                Finally
                                 FreeAndNil(vMemoryStream);
                                End;
                               End;
        // N Bytes - Others
        Else
         Begin
          {$IFDEF RESTDWANDROID}
           vString := MarshaledAString(PData);
          {$ELSE}
           vString := Pansichar(PData);
          {$ENDIF}
          If EncodeStrs Then
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
         End;
       End;
      End;
    End;
  End;
 Result := Result + 1;
End;

Procedure TRESTDWStorageBin.SaveRecordToStream(ADataset    : TDataset;
                                               Var AStream : TStream);
Var
 I             : DWInteger;
 vDWFieldType,
 vByte         : Byte;
 vBytes        : TRESTDWBytes;
 vString       : DWString;
 vWideString   : DWWideString;
 vInt64        : DWInt64;
 vInt          : DWInteger;
 vDouble       : DWDouble;
 vWord         : DWWord;
 vSingle       : DWSingle;
 vCurrency     : DWCurrency;
 vMemoryStream : TMemoryStream;
 vBoolean      : Boolean;
 vRESTDWBytes  : TRESTDWBytes;
 vTimeStamp    : {$IFDEF FPC} TTimeStamp {$ELSE} TSQLTimeStamp {$ENDIF};
 {$IFDEF DELPHIXEUP}
  vTimeStampOffset : TSQLTimeStampOffset;
 {$ENDIF}
Begin
 vMemoryStream := nil;
 For i := 0 To ADataset.FieldCount - 1 Do
  Begin
   vBoolean := ADataset.Fields[i].IsNull;
   vBoolean := Not vBoolean;
   AStream.Write(vBoolean, SizeOf(boolean));
   If Not vBoolean Then
    Continue;
   vDWFieldType := FieldTypeToDWFieldType(ADataset.Fields[i].DataType);
   // N - Bytes
   Case vDWFieldType Of
    dwftFixedChar,
    dwftWideString,
    dwftFixedWideChar  : Begin
                          vString := ADataset.Fields[i].AsString;
                          If EncodeStrs Then
                           vString := EncodeStrings(vString{$IFDEF FPC}, DatabaseCharSet{$ENDIF});
                          {$IFDEF FPC}
                           If DatabaseCharSet <> csUndefined Then
                            vString := GetStringDecode(vString, DatabaseCharSet);
                          {$ENDIF}
                          vInt64       := Length(vString);//Length(vWideString)* sizeof(vWideString[1]);
                          AStream.Write(vInt64, SizeOf(vInt64));
                          If vInt64 <> 0 Then
                           AStream.Write(vString[InitStrPos], vInt64);
                         End;
     // N - Bytes
    dwftString         : Begin
                          vString  := ADataset.Fields[i].AsString;
                          If EncodeStrs Then
                           vString := EncodeStrings(vString{$IFDEF FPC}, DatabaseCharSet{$ENDIF});
                          {$IFDEF FPC}
                           If DatabaseCharSet <> csUndefined Then
                            vString := GetStringDecode(vString, DatabaseCharSet);
                          {$ENDIF}
                          vInt64   := Length(vString);
                          AStream.Write(vInt64, SizeOf(vInt64));
                          If vInt64 <> 0 Then
                           AStream.Write(vString[InitStrPos], vInt64);
                         End;
   // 1 - Byte - Inteiros
   dwftByte,
   dwftShortint        : Begin
                          vByte := ADataset.Fields[i].AsInteger;
                          AStream.Write(vByte, Sizeof(vByte));
                         End;
   // 1 - Byte - Boolean
   dwftBoolean         : Begin
                          vBoolean := ADataset.Fields[i].AsBoolean;
                          AStream.Write(vBoolean, Sizeof(vBoolean));
                         End;
   // 2 - Bytes
   dwftSmallint,
   dwftWord            : Begin
                          vWord := ADataset.Fields[i].AsInteger;
                          AStream.Write(vWord, Sizeof(vWord));
                         End;
    // 4 - Bytes - Inteiros
   dwftInteger         : Begin
                          vInt := ADataset.Fields[i].AsInteger;
                          AStream.Write(vInt, Sizeof(vInt));
                         End;
    // 4 - Bytes - Flutuantes
   dwftSingle          : Begin
                          vSingle := ADataset.Fields[i].Value;
                          AStream.Write(vSingle, SizeOf(vSingle));
                         End;
   // 8 - Bytes - Inteiros
   dwftLargeint,
   dwftAutoInc,
   dwftLongWord        : Begin
                          {$IFDEF DELPHIXEUP}
                           vInt64 := ADataset.Fields[i].AsLargeInt;
                          {$ELSE}
                           vInt64 := ADataset.Fields[i].AsInteger;
                          {$ENDIF}
                          AStream.Write(vInt64, Sizeof(vInt64));
                         End;
   // 8 - Bytes - Flutuantes
   dwftFloat        : Begin
                          vDouble := ADataset.Fields[i].AsFloat;
                          AStream.Write(vDouble, Sizeof(vDouble));
                         End;
   // 8 - Bytes - Date, Time, DateTime, TimeStamp
   dwftDate,
   dwftTime,
   dwftDateTime,
   dwftTimeStamp   : Begin
                      vDouble := ADataset.Fields[i].AsDateTime;
                      AStream.Write(vDouble, Sizeof(vDouble));
                     End;
    {$IFDEF DELPHIXEUP}
     // TimeStampOffSet To Double - 8 Bytes
     // + TimeZone                - 2 Bytes
     dwftTimeStampOffset : Begin
                            vTimeStampOffSet := ADataset.Fields[i].AsSQLTimeStampOffset;
                            vDouble          := SQLTimeStampOffsetToDateTime(vTimeStampOffSet);
                            AStream.Write(vDouble, Sizeof(vDouble));
                            vByte            := vTimeStampOffSet.TimeZoneHour + 12;
                            AStream.Write(vByte, Sizeof(vByte));
                            vByte            := vTimeStampOffSet.TimeZoneMinute;
                            AStream.Write(vByte, Sizeof(vByte));
                           End;
    {$ENDIF}
    // 8 - Bytes - Currency
   dwftCurrency,
   dwftBCD,
   dwftFMTBcd          : Begin
                          {$IFDEF FPC}
                          If ADataset.Fields[i].Isnull Then
                           vCurrency := 0
                          Else
                           vCurrency := StrToFloat(ADataset.Fields[i].AsString);
                          {$ELSE}
                           vCurrency := ADataset.Fields[i].AsCurrency;
                          {$ENDIF}
                          AStream.Write(vCurrency, Sizeof(vCurrency));
                         End;
    // N Bytes - Blobs
   dwftStream,
   dwftBlob,
   dwftOraBlob,
   dwftBytes,
   dwftOraClob,
   dwftMemo,
   dwftWideMemo,
   dwftFmtMemo         : Begin
                          vMemoryStream := TMemoryStream.Create;
                          Try
                           TBlobField(ADataset.Fields[i]).SaveToStream(vMemoryStream);
                           vInt64 := vMemoryStream.Size;
                           AStream.Write(vInt64, SizeOf(vInt64));
                           SetLength(vBytes, vInt64);
                           Try
                            vMemoryStream.Position := 0;
                            vMemoryStream.Read(vBytes[0], vInt64);
                           Except
                           End;
                           AStream.Write(vBytes[0], vInt64);
                          Finally
                           SetLength(vBytes, 0);
                           FreeAndNil(vMemoryStream);
                          End;
                         End;
    // N Bytes - Others
    Else
     Begin
      vString := ADataset.Fields[i].AsString;
      If EncodeStrs Then
       vString := EncodeStrings(vString{$IFDEF FPC}, csUndefined{$ENDIF});
      vInt64 := Length(vString);
      AStream.Write(vInt64, SizeOf(vInt64));
      If vInt64 <> 0 Then
       AStream.Write(vString[InitStrPos], vInt64);
     End;
   End;
  End;
End;

End.
