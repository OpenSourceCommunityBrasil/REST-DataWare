unit uRESTDWZDbcResultSet;

{$I uRESTDW.inc}

{$IFDEF FPC}
 {$DEFINE GENERIC_INDEX}
{$ENDIF}

{$DEFINE ZEOS80UP}

{$IFNDEF FPC}
  {$I ZDbc.inc}
{$ELSE}
 {$MODE DELPHI}
{$ENDIF}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros Do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  Do pacote.
 Alexandre Abbade           - Admin - Administrador Do desenvolvimento de DEMOS, coordenador Do Grupo.
 Flávio Motta               - Member Tester And DEMO Developer.
 Mobius One                 - Devel, Tester And Admin.
 Gustavo                    - Criptografia And Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

Interface

{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
Uses
  Classes, SysUtils, Types, Contnrs, FmtBCD, ZSysUtils, ZDbcIntfs, ZDbcResultSet,
  ZDbcResultSetMetadata, ZCompatibility, ZDbcCache, ZDbcCachedResultSet,
  ZDbcGenericResolver, Variants, ZDbcMetadata, ZSelectSchema, ZDatasetUtils,
  uRESTDWZDbc, uRESTDWZPlainDriver, DB, uRESTDWConsts, uRESTDWTools,
  ZDataset, ZMemTable;

Type
 TZRESTDWResultSetMetadata = Class(TZAbstractResultSetMetadata)
 Protected
  Procedure ClearColumn(ColumnInfo : TZColumnInfo); Override;
End;

  {** Implements RESTDW ResultSet. }

{$IFDEF ZEOS80UP}
 TZRESTDWResultSet = Class(TZAbstractReadOnlyResultSet, IZResultSet)
  {$ELSE}
 TZRESTDWResultSet = Class(TZAbstractResultSet)
  {$ENDIF}
 Private
  FRESTDWConnection : IZRESTDWConnection;

  FStream : TStream;
  FEncodeStrs : Boolean;
  FFieldCount : Integer;
  FRecordPos : Int64;
  FRecordCount : Int64;
  FFieldTypes : Array Of Byte;
  FVariantTable : Array Of Array Of Variant;

  FFirstRow : Boolean;
 Protected
  Procedure Open; Override;
  Procedure streamToArray;
 Public
  Constructor Create(Const AStatement : IZStatement;
                     Const SQL        : String;
                     Stream           : TStream);

  Procedure ResetCursor; Override;

  Function IsNull(ColumnIndex : Integer) : Boolean; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetPAnsiChar(ColumnIndex : Integer; Out Len : NativeUInt) : PAnsiChar; {$IFDEF ZEOS80UP} Overload {$ELSE} Override {$ENDIF};
  Function GetPWideChar(ColumnIndex : Integer;
                        Out Len     : NativeUInt) : PWideChar; {$IFDEF ZEOS80UP} Overload {$ELSE} Override {$ENDIF};
  {$IFNDEF NO_UTF8STRING}
  Function GetUTF8String(ColumnIndex : Integer) : UTF8String; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  {$ENDIF}
  {$IFNDEF NO_ANSISTRING}
  Function GetAnsiString(ColumnIndex : Integer) : AnsiString; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  {$ENDIF}
  Function GetBoolean(ColumnIndex : Integer) : Boolean; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetInt(ColumnIndex : Integer) : Integer; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetUInt(ColumnIndex : Integer) : Cardinal; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetLong(ColumnIndex : Integer) : Int64; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetULong(ColumnIndex : Integer) : UInt64; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetFloat(ColumnIndex : Integer) : Single; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetDouble(ColumnIndex : Integer) : Double; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  Function GetCurrency(ColumnIndex : Integer) : Currency; {$IFNDEF ZEOS80UP} Override; {$ENDIF}
  {$IFDEF ZEOS80UP}
  Procedure GetBigDecimal(ColumnIndex : Integer; Var Result : TBCD);
  Function GetBytes(ColumnIndex : Integer; Out Len : NativeUInt) : PByte; Overload;
  {$ELSE}
  Function GetBigDecimal(ColumnIndex : Integer) : Extended; Override;
  Function GetBytes(ColumnIndex : Integer) : TBytes; Override;
  {$ENDIF}
  Procedure GetGUID(ColumnIndex : Integer; Var Result : TGUID);
  {$IFDEF ZEOS80UP}
  Procedure GetDate(ColumnIndex : Integer; Var Result : TZDate); Reintroduce; Overload;
  Procedure GetTime(ColumnIndex : Integer; Var Result : TZTime); Reintroduce; Overload;
  Procedure GetTimestamp(ColumnIndex : Integer; Var Result : TZTimeStamp); Reintroduce; Overload;
  Function GetBlob(ColumnIndex : Integer; LobStreamMode : TZLobStreamMode = lsmRead) : IZBlob;
  {$ELSE}
  Function GetDate(ColumnIndex : Integer) : TDateTime; Override;
  Function GetTime(ColumnIndex : Integer) : TDateTime; Override;
  Function GetTimestamp(ColumnIndex : Integer) : TDateTime; Override;
  Function GetBlob(ColumnIndex : Integer) : IZBlob; Override;
  {$ENDIF}


  Function Next : Boolean; {$IFDEF ZEOS80UP} Reintroduce {$ELSE} Override {$ENDIF};
  {$IFDEF WITH_COLUMNS_TO_JSON}
  Procedure ColumnsToJSON(ResultsWriter      : {$IFDEF MORMOT2}TResultsWriter{$ELSE}TJSONWriter{$ENDIF};
                          JSONComposeOptions : TZJSONComposeOptions);
  {$ENDIF WITH_COLUMNS_TO_JSON}
End;

  {** Implements a cached resolver With RESTDW specific functionality. }
{$IFDEF ZEOS80UP}
 TZRESTDWCachedResolver = Class (TZGenerateSQLCachedResolver, IZCachedResolver)
  {$ELSE}
 TZRESTDWCachedResolver = Class (TZGenericCachedResolver, IZCachedResolver)
  {$ENDIF}
 Private
  FPlainDriver : TZRESTDWPlainDriver;
  FAutoColumnIndex : Integer;
 Public
  Constructor Create(Const AStatement : IZStatement; Const AMetadata : IZResultSetMetadata);

  {$IFDEF ZEOS80UP}
  Procedure PostUpdates(Const Sender : IZCachedResultSet; UpdateType : TZRowUpdateType;
      Const OldRowAccessor, NewRowAccessor : TZRowAccessor); Override;
  {$ELSE}
  Procedure PostUpdates(Sender : IZCachedResultSet; UpdateType : TZRowUpdateType;
      OldRowAccessor, NewRowAccessor : TZRowAccessor); Override;
  {$ENDIF}

  Function CheckKeyColumn(ColumnIndex : Integer) : Boolean; Override;

  {$IFDEF ZEOS80UP}
  Procedure UpdateAutoIncrementFields(Const Sender : IZCachedResultSet;
  UpdateType : TZRowUpdateType; Const OldRowAccessor, NewRowAccessor : TZRowAccessor;
        Const Resolver : IZCachedResolver); Override;
  {$ELSE}
  Procedure UpdateAutoIncrementFields(Sender : IZCachedResultSet; UpdateType : TZRowUpdateType;
        OldRowAccessor, NewRowAccessor : TZRowAccessor; Resolver : IZCachedResolver); Override;
  {$ENDIF}
End;

{$IFDEF ZEOS80UP}
  { TZRESTDWCachedResultSet }

 TZRESTDWCachedResultSet = Class(TZCachedResultSet)
 Protected
    Class Function GetRowAccessorClass : TZRowAccessorClass; Override;
End;

  { TZRESTDWRowAccessor }

 TZRESTDWRowAccessor = Class(TZRowAccessor)
 Protected
    Class Function MetadataToAccessorType(AColumnInfo : TZColumnInfo;
  AConSettings : PZConSettings; Var AColumnCodePage : Word) : TZSQLType; Override;
End;
{$ENDIF}

{$ENDIF ZEOS_DISABLE_RESTDW} //if set we have an empty unit
Implementation
{$IFNDEF ZEOS_DISABLE_RESTDW} //if set we have an empty unit

Uses
  ZMessages, ZTokenizer, ZVariant, ZEncoding, ZFastCode,
  ZGenericSqlAnalyser, uRESTDWProtoTypes {$IFNDEF FPC}, SqlTimSt {$ENDIF};

{ TZRESTDWCachedResultSet }

{$IFDEF ZEOS80UP}
Class Function TZRESTDWCachedResultSet.GetRowAccessorClass : TZRowAccessorClass;
Begin
  Result := TZRESTDWRowAccessor;
End;
{$ENDIF}

{ TZRESTDWRowAccessor }
{$IFDEF ZEOS80UP}
  {$IFDEF FPC} {$PUSH} {$WARN 5024 off : Parameter "AConSettings" not used} {$ENDIF}
Class Function TZRESTDWRowAccessor.MetadataToAccessorType(
  AColumnInfo : TZColumnInfo; AConSettings : PZConSettings; Var AColumnCodePage : Word) : TZSQLType;
Begin
  Result := AColumnInfo.ColumnType;
  If Result in [stAsciiStream, stUnicodeStream, stBinaryStream] Then
   Begin
    Result := TZSQLType(Byte(Result)-3); // no streams 4 RESTDW
    AColumnInfo.Precision := 0;
   End;
   If Result = stUnicodeString Then
    Result := stString; // no national chars in RESTDW
End;
  {$IFDEF FPC} {$POP} {$ENDIF}
{$ENDIF}

{ TZRESTDWResultSet }

{$IFDEF WITH_COLUMNS_TO_JSON}
Procedure TZRESTDWResultSet.ColumnsToJSON(ResultsWriter      : {$IFDEF MORMOT2}TResultsWriter{$ELSE}TJSONWriter{$ENDIF};
                                            JSONComposeOptions : TZJSONComposeOptions);
Begin

End;
{$ENDIF WITH_COLUMNS_TO_JSON}

Constructor TZRESTDWResultSet.Create(Const AStatement : IZStatement;
                                       Const SQL        : String;
                                       Stream           : TStream);
Var
  Metadata : TContainedObject;
Begin
  FRESTDWConnection := AStatement.GetConnection As IZRESTDWConnection;
  If FRESTDWConnection = Nil Then
   Raise Exception.Create(cErrorDatabaseNotFound);
  Metadata := TZRESTDWResultSetMetadata.Create(FRESTDWConnection.GetMetadata,SQL,Self);
  Inherited Create(AStatement, SQL, MetaData, AStatement.GetConnection.GetConSettings);
  FFirstRow := True;
  FStream := Stream;
  If FStream = Nil Then
   Raise Exception.Create('Zeos PhysLink dataset stream not assigned');
  If FStream.Size = 0 Then
   Raise Exception.Create('Zeos PhysLink dataset stream is empty');
  FStream.Position := 0;
  FRecordPos := 0;
  ResultSetConcurrency := rcReadOnly;
  Open;
End;

Procedure TZRESTDWResultSet.Open;
Var
  MemTable   : TZMemTable;
  ColumnInfo : TZColumnInfo;
  Field      : TField;
  I          : Integer;
  J          : Integer;
Begin
  LastRowNo := 0;
  ColumnsInfo.Clear;
  MemTable := TZMemTable.Create(Nil);
  Try
   FStream.Position := 0;
   MemTable.LoadFromStream(FStream);
   FFieldCount := MemTable.FieldCount;
   If FFieldCount < 1 Then
    Raise Exception.Create('Zeos PhysLink native stream has no fields');
   FRecordCount := MemTable.RecordCount;
   SetLength(FVariantTable, FRecordCount);
   SetLength(FFieldTypes, FFieldCount);

   For I := 0 To FFieldCount - 1 Do
    Begin
     Field := MemTable.Fields[I];
     ColumnInfo := TZColumnInfo.Create;
     ColumnInfo.ColumnName := Field.FieldName;
     ColumnInfo.ColumnLabel := Field.DisplayName;
     ColumnInfo.TableName := '';
     ColumnInfo.CatalogName := '';
     ColumnInfo.ReadOnly := Field.ReadOnly;
     ColumnInfo.ColumnType := ConvertDatasetToDbcType(Field.DataType);
     FFieldTypes[I] := FieldTypeToDWFieldType(Field.DataType);
     ColumnInfo.Precision := Field.Size;
     ColumnInfo.Scale := 0;
     ColumnInfo.Writable := Not Field.ReadOnly;
     ColumnInfo.DefinitelyWritable := Not Field.ReadOnly;
     ColumnInfo.Signed := True;
     ColumnInfo.Searchable := True;
     If Field.Required Then
      ColumnInfo.Nullable := ntNoNulls
    Else
     ColumnInfo.Nullable := ntNullable;
     If ColumnInfo.ColumnType in [stString, stAsciiStream] Then
      ColumnInfo.ColumnCodePage := zCP_UTF8;
     ColumnsInfo.Add(ColumnInfo);
    End;

    MemTable.First;
    I := 0;
    While Not MemTable.Eof Do
     Begin
      SetLength(FVariantTable[I], FFieldCount);
      For J := 0 To FFieldCount - 1 Do
       Begin
        If MemTable.Fields[J].IsNull Then
         FVariantTable[I, J] := Null
       Else
        FVariantTable[I, J] := MemTable.Fields[J].Value;
       End;
       Inc(I);
       MemTable.Next;
     End;
  Finally
   MemTable.Free;
  End;
   FStream.Size := 0;
   Inherited Open;
{$IFDEF ZEOS80UP}
   FCursorLocation := rctServer;
{$ENDIF}
End;

Procedure TZRESTDWResultSet.ResetCursor;
Begin
  FFirstRow := True;
  RowNo := 0;
  LastRowNo := 0;
  If Not Closed Then
   Inherited ResetCursor;
End;

Procedure TZRESTDWResultSet.streamToArray;
Var
  i                : Int64;
  j                : Integer;
  vString          : DWString;
  vInt64           : Int64;
  vInt             : Integer;
  vByte            : Byte;
  vBoolean         : Boolean;
  vWord            : Word;
  vSingle          : Single;
  vDouble          : Double;
  VTimeZone        : Double;
  vCurrency        : Currency;
  vStringStream    : TStringStream;
  {$IFDEF DELPHIXEUP}
  vTimeStampOffset : TSQLTimeStampOffset;
  {$ENDIF}
Begin
  vBoolean := False;
  vInt64 := 0;
  vByte := 0;
  vWord := 0;
  vInt := 0;
  vSingle := 0;
  vDouble := 0;
  vCurrency := 0;
  SetLength(FVariantTable,FRecordCount);
  i := 0;
  While i <= FRecordCount-1 Do
   Begin
    SetLength(FVariantTable[i],FFieldCount);
    For j := 0 To FFieldCount-1 Do
     Begin
      FStream.Read(vBoolean,SizeOf(vBoolean));
      If Not vBoolean Then
       Begin
        FVariantTable[i,j] := variants.null;
        Continue;
      End;

      // N - Bytes
      If (FFieldTypes[j] In [dwftFixedChar,dwftString]) Then
       Begin
        FStream.Read(vInt64, Sizeof(vInt64));
        vString := '';
        If vInt64 > 0 Then
         Begin
          SetLength(vString, vInt64);
          {$IFDEF FPC}
           FStream.Read(Pointer(vString)^, vInt64);
           If FEncodeStrs Then
             vString := DecodeStrings(vString, csUndefined);
           vString := GetStringEncode(vString, csUTF8);
          {$ELSE}
           FStream.Read(vString[InitStrPos], vInt64);
           If FEncodeStrs Then
             vString := DecodeStrings(vString);
          {$ENDIF}
        End;
        If System.Pos(#0,vString) > 0 Then
          vString := StringReplace(vString, #0, '', [rfReplaceAll]);
        FVariantTable[i,j] := vString;
      End
      // N - Bytes Wide
      Else If (FFieldTypes[j] In [dwftWideString,dwftFixedWideChar]) Then
       Begin
        FStream.Read(vInt64, Sizeof(vInt64));
        vString := '';
        If vInt64 > 0 Then
         Begin
          SetLength(vString, vInt64);
          {$IFDEF FPC}
           FStream.Read(Pointer(vString)^, vInt64);
           If FEncodeStrs Then
             vString := DecodeStrings(vString, csUndefined);
           vString := GetStringEncode(vString, csUTF8);
          {$ELSE}
           FStream.Read(vString[InitStrPos], vInt64);
           If FEncodeStrs Then
             vString := DecodeStrings(vString);
          {$ENDIF}
        End;
        If System.Pos(#0,vString) > 0 Then
          vString := StringReplace(vString, #0, '', [rfReplaceAll]);
        FVariantTable[i,j] := vString;
      End
      // 1 - Byte - Inteiros
      Else If (FFieldTypes[j] In [dwftByte,dwftShortint]) Then
      Begin
        FStream.Read(vByte, Sizeof(vByte));
        FVariantTable[i,j] := vByte;
      End
      // 1 - Byte - Boolean
      Else If (FFieldTypes[j] In [dwftBoolean]) Then
      Begin
        FStream.Read(vBoolean, Sizeof(vBoolean));
        FVariantTable[i,j] := vBoolean;
      End
      // 2 - Bytes
      Else If (FFieldTypes[j] In [dwftSmallint,dwftWord]) Then
       Begin
        FStream.Read(vWord, Sizeof(vWord));
        FVariantTable[i,j] := vWord;
      End
      // 4 - Bytes - Inteiros
      Else If (FFieldTypes[j] In [dwftInteger]) Then
      Begin
        FStream.Read(vInt, Sizeof(vInt));
        FVariantTable[i,j] := vInt;
      End
      // 4 - Bytes - Flutuantes
      Else If (FFieldTypes[j] In [dwftSingle]) Then
      Begin
        FStream.Read(vSingle, Sizeof(vSingle));
        FVariantTable[i,j] := vSingle;
      End
      // 8 - Bytes - Inteiros
      Else If (FFieldTypes[j] In [dwftLargeint,dwftAutoInc,dwftLongWord]) Then
      Begin
        FStream.Read(vInt64, Sizeof(vInt64));
        FVariantTable[i,j] := vInt64;
      End
      // 8 - Bytes - Flutuantes
      Else If (FFieldTypes[j] In [dwftFloat,dwftExtended]) Then
      Begin
        FStream.Read(vDouble, Sizeof(vDouble));
        FVariantTable[i,j] := vDouble;
      End
      // 8 - Bytes - Date, Time, DateTime, TimeStamp
      Else If (FFieldTypes[j] In [dwftDate,dwftTime,dwftDateTime,dwftTimeStamp]) Then
      Begin
        FStream.Read(vDouble, Sizeof(vDouble));
        FVariantTable[i,j] := vDouble;
      End
      // TimeStampOffSet To Double - 8 Bytes
      // + TimeZone                - 2 Bytes
      Else If (FFieldTypes[j] In [dwftTimeStampOffset]) Then
       Begin
        {$IFDEF DELPHIXEUP}
          FStream.Read(vDouble, Sizeof(vDouble));

          vTimeStampOffSet := DateTimeToSQLTimeStampOffset(vDouble);

          FStream.Read(vByte, Sizeof(vByte));
          vTimeStampOffSet.TimeZoneHour := vByte - 12;

          FStream.Read(vByte, Sizeof(vByte));
          vTimeStampOffSet.TimeZoneMinute := vByte;

          FVariantTable[i,j] := VarSQLTimeStampOffsetCreate(vTimeStampOffset);
        {$ELSE}
          // field foi transformado em datetime
          FStream.Read(vDouble, Sizeof(vDouble));
          FStream.Read(vByte, SizeOf(vByte));
          vTimeZone := (vByte - 12) / 24;

          FStream.Read(vByte, SizeOf(vByte));
          If vTimeZone > 0 Then
            vTimeZone := vTimeZone + (vByte / 60 / 24)
          Else
            vTimeZone := vTimeZone - (vByte / 60 / 24);

          vDouble := vDouble - vTimeZone;
          FVariantTable[i,j] := vDouble;
        {$ENDIF}
      End
      // 8 - Bytes - Currency
      Else If (FFieldTypes[j] In [dwftCurrency,dwftBCD,dwftFMTBcd]) Then
      Begin
        FStream.Read(vCurrency, Sizeof(vCurrency));
        FVariantTable[i,j] := vCurrency;
      End
      // N Bytes - Wide Memos
      Else If (FFieldTypes[j] In [dwftMemo,dwftWideMemo,dwftFmtMemo]) Then
       Begin
        FStream.Read(vInt64, Sizeof(vInt64));
        If vInt64 > 0 Then
         Begin
          vStringStream := TStringStream.Create('');
          Try
            vStringStream.CopyFrom(FStream, vInt64);
            vStringStream.Position := 0;
    //        Result := TEncoding.Unicode.GetString(vStringStream.Bytes);
            vString := vStringStream.DataString;
            If System.Pos(#0,vString) > 0 Then
              vString := StringReplace(vString, #0, '', [rfReplaceAll]);
          Finally
            vStringStream.Free;
          End;
          FVariantTable[i,j] := vString;
        End;
      End
      // N Bytes - Memos e Blobs
      Else If (FFieldTypes[j] In [dwftStream,dwftBlob,dwftBytes]) Then
       Begin
        FStream.Read(vInt64, Sizeof(vInt64));
        If vInt64 > 0 Then
         Begin
          vStringStream := TStringStream.Create('');
          Try
            vStringStream.CopyFrom(FStream, vInt64);
            vStringStream.Position := 0;
            {$IFNDEF FPC}
             {$IFDEF DELPHI2010UP}
              FVariantTable[i,j] := vStringStream.Bytes;
             {$ELSE}
              FVariantTable[i,j] := StreamToBytes(vStringStream);
             {$ENDIF}
            {$ELSE}
             FVariantTable[i,j] := vStringStream.Bytes;
            {$ENDIF}
          Finally
            vStringStream.Free;
          End;
        End;
      End
      Else
       Begin
        FStream.Read(vInt64, Sizeof(vInt64));
        vString := '';
        If vInt64 > 0 Then
         Begin
          SetLength(vString, vInt64);
          {$IFDEF FPC}
           FStream.Read(Pointer(vString)^, vInt64);
           If FEncodeStrs Then
             vString := DecodeStrings(vString, csUndefined);
           vString := GetStringEncode(vString, csUTF8);
          {$ELSE}
           FStream.Read(vString[InitStrPos], vInt64);
           If FEncodeStrs Then
             vString := DecodeStrings(vString);
          {$ENDIF}
        End;
        If System.Pos(#0,vString) > 0 Then
          vString := StringReplace(vString, #0, '', [rfReplaceAll]);
        FVariantTable[i,j] := vString;
      End;
    End;
    Inc(i);
  End;
End;

Function TZRESTDWResultSet.IsNull(ColumnIndex : Integer) : Boolean;
Begin
  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);
  If (RowNo < 1) Or
  (RowNo > FRecordCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid row %d. RecordCount=%d',
  [RowNo, FRecordCount]);
  Result := VarIsNull(FVariantTable[RowNo-1,ColumnIndex]);
End;

Function TZRESTDWResultSet.GetPAnsiChar(ColumnIndex : Integer; Out Len : NativeUInt) : PAnsiChar;
Var
  vString : AnsiString;
Begin
  Result := PAnsiChar('');
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vString := FVariantTable[RowNo-1,ColumnIndex];
    Len := Length(vString)+1;
    Result := PAnsiChar(vString);
   End;
End;

Function TZRESTDWResultSet.GetPWideChar(ColumnIndex : Integer;
                                         Out Len     : NativeUInt) : PWideChar;
Var
  P : PAnsiChar;
  S : AnsiString;
  W : WideString;
Begin
  S := '';
  P := GetPAnsiChar(ColumnIndex, Len);
  SetLength(S,Len);
  S := P;
  W := S;
  Result := PWideChar(W);
  Len := Length(Result);
End;

{$IFNDEF NO_UTF8STRING}
Function TZRESTDWResultSet.GetUTF8String(ColumnIndex : Integer) : UTF8String;
Var
  P   : PAnsiChar;
  Len : NativeUint;
Begin
  P := GetPAnsiChar(ColumnIndex, Len);
  {$IFDEF RESTDWLAZARUS}
  Result := '';
  {$ENDIF}
  If P <> Nil
  {$IFDEF MISS_RBS_SETSTRING_OVERLOAD}
  Then ZSetString(P, Len, result)
  {$ELSE}
  Then System.SetString(Result, P, Len)
  {$ENDIF}
  {$IFNDEF WITH_VAR_INIT_WARNING}
  Else
  {$ENDIF}
End;
{$ENDIF}

Function TZRESTDWResultSet.GetBoolean(ColumnIndex : Integer) : Boolean;
Var
  vBoolean : Boolean;
Begin
  Result := False;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vBoolean := FVariantTable[RowNo-1,ColumnIndex];
    Result := vBoolean;
   End;
End;

{$IFDEF ZEOS80UP}
Function TZRESTDWResultSet.GetBytes(ColumnIndex : Integer;
                                    Out Len      : NativeUInt) : PByte;
Var
  vBytes : TBytes;
Begin
  Result := Nil;
  Len := 0;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}

  If (ColumnIndex < 0) Or
     (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
                             [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vBytes := TBytes(FVariantTable[RowNo-1,ColumnIndex]);
    If Length(vBytes) > 0 Then
     Result := @vBytes[0];
    Len := Length(vBytes);
   End;
End;
{$ELSE}
Function TZRESTDWResultSet.GetBytes(ColumnIndex : Integer) : TBytes;
Var
  vBytes : TBytes;
Begin
  LastWasNull := IsNull(ColumnIndex);

    {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
    {$ENDIF}

  If Not LastWasNull Then
   Begin
    vBytes := TBytes(FVariantTable[RowNo-1,ColumnIndex]);
    Result := vBytes;
   End;
End;
{$ENDIF}

Function TZRESTDWResultSet.GetInt(ColumnIndex : Integer) : Integer;
Var
  vInt : Integer;
Begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vInt := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt;
   End;
End;

Function TZRESTDWResultSet.GetLong(ColumnIndex : Integer) : Int64;
Var
  vInt64 : Int64;
Begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vInt64 := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt64;
   End;
End;

Function TZRESTDWResultSet.GetUInt(ColumnIndex : Integer) : Cardinal;
Begin
  Result := GetLong(ColumnIndex);
End;

{$IF Defined(RangeCheckEnabled) AND Defined(WITH_UINT64_C1118_ERROR)}{$R-}{$IFEND}
Function TZRESTDWResultSet.GetULong(ColumnIndex : Integer) : System.UInt64;
Var
  vInt64 : UInt64;
Begin
  Result := 0;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vInt64 := FVariantTable[RowNo-1,ColumnIndex];
    Result := vInt64;
   End;
End;
{$IF Defined(RangeCheckEnabled) AND Defined(WITH_UINT64_C1118_ERROR)}{$R+}{$IFEND}

Function TZRESTDWResultSet.GetFloat(ColumnIndex : Integer) : Single;
Begin
  Result := GetDouble(ColumnIndex);
End;

Procedure TZRESTDWResultSet.GetGUID(ColumnIndex : Integer; Var Result : TGUID);
Var
  vString : String;
Begin
  vString := GetString(ColumnIndex);
  If Not LastWasNull Then
   Result := StringToGUID(vString);
End;

Function TZRESTDWResultSet.GetDouble(ColumnIndex : Integer) : Double;
Var
  vDouble : Double;
Begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vDouble := FVariantTable[RowNo-1,ColumnIndex];
    Result := vDouble;
   End;
End;

{$IFNDEF NO_ANSISTRING}
Function TZRESTDWResultSet.GetAnsiString(ColumnIndex : Integer) : AnsiString;
Var
  P : PAnsiChar;
  L : NativeUInt;
Begin
  P := GetPAnsiChar(ColumnIndex, L);
  Result := '';
  If Not LastWasNull Then
   Begin
    FUniTemp := PRawToUnicode(P, ZFastCode.StrLen(P), zCP_UTF8);
    Result := ZUnicodeToRaw(FUniTemp, ZOSCodePage);
   End
End;
{$ENDIF}

{$IFDEF ZEOS80UP}
Procedure TZRESTDWResultSet.GetBigDecimal(ColumnIndex : Integer; Var Result : TBCD);
Var
  vCurrency : Currency;
Begin
  vCurrency := GetCurrency(ColumnIndex);
    {$IFNDEF FPC}
  If Not LastWasNull Then
   Result := CurrencyToBcd(vCurrency);
    {$ELSE}
  If Not LastWasNull Then
   Result := DoubleToBCD(vCurrency);
    {$ENDIF}
End;
{$ELSE}
Function TZRESTDWResultSet.GetBigDecimal(ColumnIndex : Integer) : Extended;
Var
  vCurrency : Currency;
Begin
  vCurrency := GetCurrency(ColumnIndex);

    {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
    {$ENDIF}

  If Not LastWasNull Then
   Result := vCurrency;
End;
{$ENDIF}

Function TZRESTDWResultSet.GetCurrency(ColumnIndex : Integer) : Currency;
Var
  vCurrency : Currency;
Begin
  Result := -1;
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}
  If (ColumnIndex < 0) Or
  (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
  [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Begin
    vCurrency := FVariantTable[RowNo-1,ColumnIndex];
    Result := vCurrency;
   End;
End;

{$IFDEF ZEOS80UP}
Procedure TZRESTDWResultSet.GetDate(ColumnIndex : Integer; Var Result : TZDate);
Var
  vDouble : Double;
Begin
  vDouble := GetDouble(ColumnIndex);
  If Not LastWasNull Then
   Result := TZAnyValue.CreateWithDouble(vDouble).GetDate;
End;
{$ELSE}
Function TZRESTDWResultSet.GetDate(ColumnIndex : Integer) : TDateTime;
Var
  vDouble : Double;
Begin
  vDouble := GetDouble(ColumnIndex);
  If Not LastWasNull Then
   Result := TDateTime(vDouble);
End;
{$ENDIF}

{$IFDEF ZEOS80UP}
Procedure TZRESTDWResultSet.GetTime(ColumnIndex : Integer; Var Result : TZTime);
Var
  vDouble : Double;
Begin
  vDouble := GetDouble(ColumnIndex);
  If Not LastWasNull Then
   Result := TZAnyValue.CreateWithDouble(vDouble).GetTime;
End;
{$ELSE}
Function TZRESTDWResultSet.GetTime(ColumnIndex : Integer) : TDateTime;
Var
  vDouble : Double;
Begin
  vDouble := GetDouble(ColumnIndex);
  If Not LastWasNull Then
   Result := TDateTime(vDouble);
End;
{$ENDIF}

{$IFDEF ZEOS80UP}
Procedure TZRESTDWResultSet.GetTimestamp(ColumnIndex : Integer; Var Result : TZTimeStamp);
Var
  vDouble : Double;
Begin
  vDouble := GetDouble(ColumnIndex);
  If Not LastWasNull Then
   Result := TZAnyValue.CreateWithDouble(vDouble).GetTimeStamp;
End;
{$ELSE}
Function TZRESTDWResultSet.GetTimestamp(ColumnIndex : Integer) : TDateTime;
Var
  vDouble : Double;
Begin
  vDouble := GetDouble(ColumnIndex);
  If Not LastWasNull Then
   Result := TDateTime(vDouble);
End;
{$ENDIF}

{$IFDEF ZEOS80UP}
Function TZRESTDWResultSet.GetBlob(ColumnIndex : Integer;
                                   LobStreamMode : TZLobStreamMode = lsmRead) : IZBlob;
Begin
  LastWasNull := IsNull(ColumnIndex);

  {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex - 1;
  {$ENDIF}

  If (ColumnIndex < 0) Or
     (ColumnIndex >= FFieldCount) Then
   Raise Exception.CreateFmt('Zeos PhysLink invalid column index %d. FieldCount=%d',
                             [ColumnIndex, FFieldCount]);

  If Not LastWasNull Then
   Result.SetBytes(TBytes(FVariantTable[RowNo-1,ColumnIndex]));
End;
{$ELSE}
Function TZRESTDWResultSet.GetBlob(ColumnIndex : Integer) : IZBlob;
Var
  sStr : TStringStream;
Begin
  LastWasNull := IsNull(ColumnIndex);
    {$IFNDEF GENERIC_INDEX}
  ColumnIndex := ColumnIndex -1;
    {$ENDIF}
  If Not LastWasNull Then
   Begin
    If FFieldTypes[ColumnIndex] in [dwftMemo,dwftWideMemo,dwftFmtMemo] Then
     Begin
      sStr := TStringStream.Create(String(FVariantTable[RowNo-1,ColumnIndex]));
      Try
       sStr.Position := 0;
       Result := TZAbstractCLob.CreateWithStream(sStr,zCP_UTF8,ConSettings);
      Finally
       sStr.Free;
      End;
     End
    Else
     Begin
            {$IFNDEF FPC}
             {$IFDEF DELPHI2010UP}
      sStr := TStringStream.Create(TBytes(FVariantTable[RowNo-1,ColumnIndex]));
             {$ELSE}
      sStr := TStringStream.Create(BytesToString(TRESTDWBytes(FVariantTable[RowNo-1,ColumnIndex])));
             {$ENDIF}
            {$ELSE}
      sStr := TStringStream.Create(TBytes(FVariantTable[RowNo-1,ColumnIndex]));
            {$ENDIF}
      Try
       sStr.Position := 0;
       Result := TZAbstractBlob.CreateWithStream(sStr);
      Finally
       sStr.Free;
      End;
     End;
   End;
End;
{$ENDIF}


Function TZRESTDWResultSet.Next : Boolean;
Begin
  Result := False;
  If Closed Then
   Exit;

  If FRecordCount <= 0 Then
   Exit;

  If FFirstRow Then
   Begin
    FFirstRow := False;
    RowNo := 1;
   End
  Else
   RowNo := RowNo + 1;

  If ((MaxRows > 0) And (RowNo > MaxRows)) Or
     (RowNo > FRecordCount) Then
   Begin
    LastRowNo := RowNo;
    Exit;
   End;

  LastRowNo := RowNo;
  Result := True;
End;

Function TZRESTDWCachedResolver.CheckKeyColumn(ColumnIndex : Integer) : Boolean;
Begin
  Result := (Metadata.GetTableName(ColumnIndex) <> '')
  And (Metadata.GetColumnName(ColumnIndex) <> '')
  And Metadata.IsSearchable(ColumnIndex)
  And Not (Metadata.GetColumnType(ColumnIndex) in [stUnknown, stBinaryStream]);
End;

Constructor TZRESTDWCachedResolver.Create(Const AStatement : IZStatement; Const AMetadata : IZResultSetMetadata);
Var
  I : Integer;
Begin
  Inherited Create(AStatement, AMetadata);
  {$IFDEF ZEOS80UP}
  FPlainDriver := TZRESTDWPlainDriver(AStatement.GetConnection.GetIZPlainDriver.GetInstance);
  {$ELSE}
  FPlainDriver := TZRESTDWPlainDriver(AStatement.GetConnection.GetIZPlainDriver);
  {$ENDIF}

  { Defines an index Of autoincrement field. }
  FAutoColumnIndex := 0;
  For I := FirstDbcIndex To AMetadata.GetColumnCount{$IFDEF GENERIC_INDEX} - 1{$ENDIF} Do
   If AMetadata.IsAutoIncrement(I) And
  (AMetadata.GetColumnType(I) in [stByte, stShort, stSmall, stLongWord,
  stInteger, stUlong, stLong]) Then
   Begin
    FAutoColumnIndex := I;
    Break;
   End;
End;

{$IFDEF ZEOS80UP}
Procedure TZRESTDWCachedResolver.PostUpdates(Const Sender : IZCachedResultSet;
  UpdateType : TZRowUpdateType; Const OldRowAccessor, NewRowAccessor : TZRowAccessor);
Begin
  Inherited PostUpdates(Sender, UpdateType, OldRowAccessor, NewRowAccessor);

  If (UpdateType = utInserted) Then
   UpdateAutoIncrementFields(Sender, UpdateType, OldRowAccessor, NewRowAccessor, Self);
End;
{$ELSE}
Procedure TZRESTDWCachedResolver.PostUpdates(Sender : IZCachedResultSet; UpdateType : TZRowUpdateType;
  OldRowAccessor, NewRowAccessor : TZRowAccessor);
Begin
  Inherited PostUpdates(Sender, UpdateType, OldRowAccessor, NewRowAccessor);

  If (UpdateType = utInserted) Then
   UpdateAutoIncrementFields(Sender, UpdateType, OldRowAccessor, NewRowAccessor, Self);
End;
{$ENDIF}

{$IFDEF ZEOS80UP}
Procedure TZRESTDWCachedResolver.UpdateAutoIncrementFields(
  Const Sender : IZCachedResultSet; UpdateType : TZRowUpdateType; Const
  OldRowAccessor, NewRowAccessor : TZRowAccessor; Const Resolver : IZCachedResolver);
Begin
  Inherited;
End;
{$ELSE}
Procedure TZRESTDWCachedResolver.UpdateAutoIncrementFields(Sender : IZCachedResultSet;
  UpdateType : TZRowUpdateType; OldRowAccessor, NewRowAccessor : TZRowAccessor;
  Resolver : IZCachedResolver);
Begin
  Inherited;
End;
{$ENDIF}

{ TZRESTDWResultSetMetadata }

Procedure TZRESTDWResultSetMetadata.ClearColumn(ColumnInfo : TZColumnInfo);
Begin
  Inherited;
  ColumnInfo.ReadOnly := False;
  ColumnInfo.Writable := True;
  ColumnInfo.DefinitelyWritable := True;
End;

{$ENDIF ZEOS_DISABLE_RESTDW} //if set we have an empty unit

End.
