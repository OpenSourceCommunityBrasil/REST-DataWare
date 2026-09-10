unit uRESTDWStorageBin;

{$I uRESTDW.inc}

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

Uses
 Classes, SysUtils, DB, FmtBcd, uRESTDWBasicDbTypes, uRESTDWProtoTypes,
 uRESTDWMemoryDataset, uRESTDWTools;

Type
 TRESTDWStorageBin = Class(TRESTDWStorageBase)
 Private
  Function ReadByte(AStream : TStream) : Byte;
  Function ReadWord(AStream : TStream) : Word;
  Function ReadDWord(AStream : TStream) : LongWord;
  Function ReadAnsiString(AStream : TStream) : AnsiString;
  Function IsStringField(AFieldType : TFieldType) : Boolean;
  Function IsBlobField(AFieldType : TFieldType) : Boolean;
  Function IsVariableField(AFieldType : TFieldType) : Boolean;
  Function GetFixedWireSize(AWireType : Byte;
                            AField    : TField) : LongWord;
  Procedure SaveRecordToStream(ADataset : TDataset;
                               AWriter  : TRESTDWBinaryPacketWriter);
  Procedure LoadRecordFromStream(ADataset       : TDataset;
                                 AStream        : TStream;
                                 AWireFieldTypes: Array Of Byte;
                                 ANullBitmapSize: Integer);
 Public
  Procedure SaveDWMemToStream(IDataset    : TDataset;
                              Var AStream : TStream); Override;
  Procedure LoadDWMemFromStream(IDataset : TDataset;
                                AStream  : TStream); Override;
  Procedure SaveDatasetToStream(ADataset    : TDataset;
                                Var AStream : TStream); Override;
  Procedure LoadDatasetFromStream(ADataset : TDataset;
                                  AStream  : TStream); Override;
 End;

Implementation

Function TRESTDWStorageBin.ReadByte(AStream : TStream) : Byte;
Begin
 AStream.ReadBuffer(Result, SizeOf(Result));
End;

Function TRESTDWStorageBin.ReadWord(AStream : TStream) : Word;
Begin
 AStream.ReadBuffer(Result, SizeOf(Result));
End;

Function TRESTDWStorageBin.ReadDWord(AStream : TStream) : LongWord;
Begin
 AStream.ReadBuffer(Result, SizeOf(Result));
End;

Function TRESTDWStorageBin.ReadAnsiString(AStream : TStream) : AnsiString;
Var
 L : LongWord;
Begin
 L := ReadDWord(AStream);
 If Int64(L) > AStream.Size - AStream.Position Then
  Raise Exception.Create('Invalid binary packet string length ' + IntToStr(L));
 SetLength(Result, L);
 If L > 0 Then
  AStream.ReadBuffer(Result[1], L);
End;

Function TRESTDWStorageBin.IsStringField(AFieldType : TFieldType) : Boolean;
Begin
 Result := AFieldType In [ftString, ftFixedChar, ftWideString
                          {$IFDEF DELPHIXEUP}, ftFixedWideChar{$ENDIF}];
End;

Function TRESTDWStorageBin.IsBlobField(AFieldType : TFieldType) : Boolean;
Begin
 Result := AFieldType In [ftBlob, ftMemo, ftGraphic
                          {$IFDEF DELPHIXEUP}, ftWideMemo{$ENDIF}];
End;

Function TRESTDWStorageBin.IsVariableField(AFieldType : TFieldType) : Boolean;
Begin
 Result := IsStringField(AFieldType) Or
           IsBlobField(AFieldType) Or
           (AFieldType In [ftBytes, ftVarBytes]);
End;

Function TRESTDWStorageBin.GetFixedWireSize(AWireType : Byte;
                                            AField    : TField) : LongWord;
Begin
 Case AWireType Of
  dwftSmallint : Result := SizeOf(SmallInt);
  dwftInteger  : Result := SizeOf(Integer);
  dwftWord     : Result := SizeOf(Word);
  dwftBoolean  : Result := SizeOf(WordBool);
  dwftFloat    : Result := SizeOf(Double);
  dwftCurrency,
  dwftBCD      : Result := SizeOf(Currency);
  dwftDate,
  dwftTime     : Result := SizeOf(Integer);
  dwftDateTime,
  dwftTimeStamp,
  dwftOraTimeStamp,
  dwftTimeStampOffset : Result := SizeOf(TDateTime);
  dwftLargeint,
  dwftAutoInc  : Result := SizeOf(Int64);
  dwftExtended : Result := SizeOf(Double);
  dwftFMTBcd   : Result := SizeOf(TBcd);
  dwftGuid     : Result := SizeOf(TGUID);
  Else
   Result := AField.DataSize;
 End;
End;

Procedure TRESTDWStorageBin.SaveRecordToStream(ADataset : TDataset;
                                               AWriter  : TRESTDWBinaryPacketWriter);
Var
 I         : Integer;
 J         : Integer;
 L         : LongWord;
 AField    : TField;
 ABytes    : TRESTDWMemBytes;
 AString   : AnsiString;
 ADateTime : TDateTime;
 ADouble   : Double;
 ACurrency  : Currency;
 ABcd       : TBcd;
 ATimeStamp : TTimeStamp;
 AWireValue : Integer;
Begin
 AWriter.BeginRecord;
 For I := 0 To ADataset.FieldCount - 1 Do
  Begin
   AField := ADataset.Fields[I];
   If AField.IsNull Then
    Begin
     AWriter.StoreNull(I);
     Continue;
    End;
   If IsStringField(AField.DataType) Then
    Begin
     AString := AnsiString(AField.AsString);
     If Length(AString) > 0 Then
      AWriter.StoreField(I, @AString[1], Length(AString))
     Else
      AWriter.StoreField(I, Nil, 0);
     Continue;
    End;
   If FieldTypeToDWFieldType(AField.DataType) = dwftDate Then
    Begin
     AWireValue := Trunc(AField.AsDateTime) + 693594;
     AWriter.StoreField(I, @AWireValue, SizeOf(AWireValue));
     Continue;
    End;
   If FieldTypeToDWFieldType(AField.DataType) = dwftTime Then
    Begin
     ATimeStamp := DateTimeToTimeStamp(AField.AsDateTime);
     AWireValue := ATimeStamp.Time;
     AWriter.StoreField(I, @AWireValue, SizeOf(AWireValue));
     Continue;
    End;
   If FieldTypeToDWFieldType(AField.DataType) = dwftBCD Then
    Begin
     ACurrency := AField.AsCurrency;
     AWriter.StoreField(I, @ACurrency, SizeOf(ACurrency));
     Continue;
    End;
   If FieldTypeToDWFieldType(AField.DataType) = dwftFMTBcd Then
    Begin
     ABcd := AField.AsBCD;
     AWriter.StoreField(I, @ABcd, SizeOf(ABcd));
     Continue;
    End;
   If FieldTypeToDWFieldType(AField.DataType) = dwftExtended Then
    Begin
{$IFDEF FPC}
     ADouble := AField.AsFloat;
{$ELSE}
 {$IFDEF DELPHI2010UP}
     If AField.DataType = ftExtended Then
      ADouble := AField.AsExtended
     Else
 {$ENDIF}
     ADouble := AField.AsFloat;
{$ENDIF}
     AWriter.StoreField(I, @ADouble, SizeOf(ADouble));
     Continue;
    End;
   If FieldTypeToDWFieldType(AField.DataType) In [dwftDateTime,
                                                   dwftTimeStamp,
                                                   dwftOraTimeStamp,
                                                   dwftTimeStampOffset] Then
    Begin
     ADateTime := AField.AsDateTime;
     AWriter.StoreField(I, @ADateTime, SizeOf(ADateTime));
     Continue;
    End;
   L := Length(AField.AsBytes);
   SetLength(ABytes, L);
   For J := 0 To Integer(L) - 1 Do
    ABytes[J] := AField.AsBytes[J];
   If L > 0 Then
    AWriter.StoreField(I, @ABytes[0], L)
   Else
    AWriter.StoreField(I, Nil, 0);
  End;
 AWriter.EndRecord;
End;

Procedure TRESTDWStorageBin.SaveDatasetToStream(ADataset    : TDataset;
                                                Var AStream : TStream);
Var
 I         : Integer;
 AField    : TField;
 AWriter   : TRESTDWBinaryPacketWriter;
 ABookmark : TBookmark;
 AHasBookmark : Boolean;
Begin
 If Not ADataset.Active Then
  ADataset.Open
 Else
  ADataset.CheckBrowseMode;
 AStream.Size := 0;
 AStream.Position := 0;
 AWriter := TRESTDWBinaryPacketWriter.Create(AStream);
 Try
{$IFDEF RESTDWLAZARUS}
  AWriter.DatabaseCharSet := DatabaseCharSet;
{$ENDIF}
  AWriter.ClearFieldDefs;
  For I := 0 To ADataset.FieldCount - 1 Do
   Begin
    AField := ADataset.Fields[I];
    AWriter.AddFieldDef(AField.FieldName,
                        AField.DisplayName,
                        AField.Size,
                        AField.DataType,
                        AField.ReadOnly);
   End;
  AWriter.StoreFieldDefs(1);
  AHasBookmark := False;
  If Not ADataset.IsUniDirectional Then
   Begin
    ABookmark := ADataset.GetBookmark;
    AHasBookmark := True;
   End;
  ADataset.DisableControls;
  Try
   If Not ADataset.IsUniDirectional Then
    ADataset.First;
   While Not ADataset.Eof Do
    Begin
     SaveRecordToStream(ADataset, AWriter);
     ADataset.Next;
    End;
  Finally
   If AHasBookmark Then
    Begin
     If ADataset.BookmarkValid(ABookmark) Then
      ADataset.GotoBookmark(ABookmark);
     ADataset.FreeBookmark(ABookmark);
    End;
   ADataset.EnableControls;
  End;
 Finally
  AWriter.Free;
 End;
 AStream.Position := 0;
End;

Procedure TRESTDWStorageBin.SaveDWMemToStream(IDataset    : TDataset;
                                              Var AStream : TStream);
Begin
 SaveDatasetToStream(IDataset, AStream);
End;

Procedure TRESTDWStorageBin.LoadRecordFromStream(ADataset        : TDataset;
                                                 AStream         : TStream;
                                                 AWireFieldTypes : Array Of Byte;
                                                 ANullBitmapSize : Integer);
Var
 I           : Integer;
 L           : LongWord;
 AField      : TField;
 ANullBitmap : Array Of Byte;
 ABuffer     : Array Of Byte;
 AString     : AnsiString;
 ADateTime   : TDateTime;
 ADouble     : Double;
 ACurrency   : Currency;
 ABcd        : TBcd;
{$IFDEF FPC}
 ATimeStamp  : TTimeStamp;
 AWireValue  : Integer;
{$ENDIF}
 ABlobStream : TMemoryStream;
Begin
 SetLength(ANullBitmap, ANullBitmapSize);
 If ANullBitmapSize > 0 Then
  AStream.ReadBuffer(ANullBitmap[0], ANullBitmapSize);
 For I := 0 To ADataset.FieldCount - 1 Do
  Begin
   AField := ADataset.Fields[I];
   If (ANullBitmapSize > 0) And
      ((ANullBitmap[I Div 8] And Byte(1 Shl (I Mod 8))) <> 0) Then
    Begin
     AField.Clear;
     Continue;
    End;
   If IsStringField(AField.DataType) Then
    Begin
     AString := ReadAnsiString(AStream);
     AField.AsString := String(AString);
     Continue;
    End;
{$IFDEF FPC}
    If (I < Length(AWireFieldTypes)) And
       (AWireFieldTypes[I] = dwftDate) Then
    Begin
     AStream.ReadBuffer(AWireValue, SizeOf(AWireValue));
     AField.AsDateTime := TDateTime(AWireValue - 693594);
     Continue;
    End;
    If (I < Length(AWireFieldTypes)) And
       (AWireFieldTypes[I] = dwftTime) Then
     Begin
      AStream.ReadBuffer(AWireValue, SizeOf(AWireValue));
      AField.AsDateTime := AWireValue / 86400000.0;
      Continue;
     End;
    If (I < Length(AWireFieldTypes)) And
       (AWireFieldTypes[I] = dwftBCD) Then
    Begin
     AStream.ReadBuffer(ACurrency, SizeOf(ACurrency));
     AField.AsCurrency := ACurrency;
     Continue;
    End;
   If (I < Length(AWireFieldTypes)) And
       (AWireFieldTypes[I] = dwftFMTBcd) Then
    Begin
     AStream.ReadBuffer(ABcd, SizeOf(ABcd));
     AField.AsBCD := ABcd;
     Continue;
    End;
{$ENDIF}

   If (I < Length(AWireFieldTypes)) And
      (AWireFieldTypes[I] = dwftExtended) Then
    Begin
     AStream.ReadBuffer(ADouble, SizeOf(ADouble));
{$IFDEF FPC}
     AField.AsFloat := ADouble;
{$ELSE}
 {$IFDEF DELPHI2010UP}
     If AField.DataType = ftExtended Then
      AField.AsExtended := ADouble
     Else
 {$ENDIF}
     AField.AsFloat := ADouble;
{$ENDIF}
     Continue;
    End;
   If (I < Length(AWireFieldTypes)) And
      (AWireFieldTypes[I] In [dwftDateTime,
                              dwftTimeStamp,
                              dwftOraTimeStamp,
                              dwftTimeStampOffset]) Then
    Begin
     AStream.ReadBuffer(ADateTime, SizeOf(ADateTime));
     AField.AsDateTime := ADateTime;
     Continue;
    End;
   If IsVariableField(AField.DataType) Then
    L := ReadDWord(AStream)
   Else
    L := GetFixedWireSize(AWireFieldTypes[I], AField);
   If Int64(L) > AStream.Size - AStream.Position Then
    Raise Exception.Create('Invalid binary packet field size ' + IntToStr(L));
   SetLength(ABuffer, L);
   If L > 0 Then
    AStream.ReadBuffer(ABuffer[0], L);
   If IsBlobField(AField.DataType) Then
    Begin
     ABlobStream := TMemoryStream.Create;
     Try
      If L > 0 Then
       ABlobStream.WriteBuffer(ABuffer[0], L);
      ABlobStream.Position := 0;
      TBlobField(AField).LoadFromStream(ABlobStream);
     Finally
      ABlobStream.Free;
     End;
    End
   Else If L > 0 Then
    AField.SetData(@ABuffer[0])
   Else
    AField.Clear;
  End;
End;

Procedure TRESTDWStorageBin.LoadDatasetFromStream(ADataset : TDataset;
                                                  AStream  : TStream);
Const
 RESTDWBinaryIdent : AnsiString = 'BinRESTDWDataSet';
Var
 I                : Integer;
 AAutoIncValue    : Integer;
 AFieldCount      : Word;
 AFieldSize       : Word;
 AWireType        : Word;
 AReadOnly        : Byte;
 ARecordMarker    : Byte;
 ARowState        : Byte;
 AUpdateOrder     : Integer;
 ANullBitmapSize  : Integer;
 AIdent           : AnsiString;
 AName            : AnsiString;
 ADisplayName     : AnsiString;
 AFieldDef        : TFieldDef;
 AField           : TField;
 AWireFieldTypes  : Array Of Byte;
Begin
 AStream.Position := 0;
 SetLength(AIdent, Length(RESTDWBinaryIdent));
 If Length(AIdent) > 0 Then
  AStream.ReadBuffer(AIdent[1], Length(AIdent));
 If AIdent <> RESTDWBinaryIdent Then
  Raise Exception.Create('The data stream format is unrecognized');
 If ReadByte(AStream) <> 20 Then
  Raise Exception.Create('The data stream format is unrecognized');
 AFieldCount := ReadWord(AStream);
 SetLength(AWireFieldTypes, AFieldCount);
 ADataset.Close;
 ADataset.FieldDefs.Clear;
 For I := 0 To AFieldCount - 1 Do
  Begin
   AName := ReadAnsiString(AStream);
   ADisplayName := ReadAnsiString(AStream);
   AFieldSize := ReadWord(AStream);
   AWireType := ReadWord(AStream);
   If AWireType > 255 Then
    Raise Exception.Create('Invalid binary packet field type ' + IntToStr(AWireType));
   AWireFieldTypes[I] := Byte(AWireType);
   AFieldDef := ADataset.FieldDefs.AddFieldDef;
   AFieldDef.Name := String(AName);
   AFieldDef.DisplayName := String(ADisplayName);
   AFieldDef.Size := AFieldSize;
   Case AWireFieldTypes[I] Of
    dwftTimeStamp,
    dwftOraTimeStamp,
    dwftTimeStampOffset : AFieldDef.DataType := ftDateTime;
    Else
     AFieldDef.DataType := DWFieldTypeToFieldType(AWireFieldTypes[I]);
   End;
   AReadOnly := ReadByte(AStream);
   If AReadOnly = 1 Then
    AFieldDef.Attributes := AFieldDef.Attributes + [faReadonly];
  End;
 AStream.ReadBuffer(AAutoIncValue, SizeOf(AAutoIncValue));
 ANullBitmapSize := (AFieldCount + 7) Div 8;
 ADataset.Open;
 For I := 0 To ADataset.FieldCount - 1 Do
  Begin
   AField := ADataset.Fields[I];
   If I < AFieldCount Then
    AField.ReadOnly := False;
  End;
 ADataset.DisableControls;
 Try
  While AStream.Position < AStream.Size Do
   Begin
    ARecordMarker := ReadByte(AStream);
    If ARecordMarker <> $FE Then
     Raise Exception.Create('Invalid binary packet record marker ' + IntToStr(ARecordMarker));
    ARowState := ReadByte(AStream);
    If ARowState <> 0 Then
     AStream.ReadBuffer(AUpdateOrder, SizeOf(AUpdateOrder));
    ADataset.Append;
    Try
     LoadRecordFromStream(ADataset,
                          AStream,
                          AWireFieldTypes,
                          ANullBitmapSize);
     ADataset.Post;
    Except
     ADataset.Cancel;
     Raise;
    End;
   End;
 Finally
  ADataset.EnableControls;
 End;
End;

Procedure TRESTDWStorageBin.LoadDWMemFromStream(IDataset : TDataset;
                                                AStream  : TStream);
Begin
 LoadDatasetFromStream(IDataset, AStream);
End;

End.
