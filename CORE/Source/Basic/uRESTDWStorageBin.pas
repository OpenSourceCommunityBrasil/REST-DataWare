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

uses
  {$IFNDEF RESTDWLAZARUS}SqlTimSt, {$ENDIF}
  Classes, SysUtils, uRESTDWMemoryDataset, FmtBcd, DB, Variants, uRESTDWConsts,
  uRESTDWTools;

type
  TRESTDWStorageBin = Class(TRESTDWStorageBase)
  private
    FFieldTypes : Array of byte;
    FFieldNames : Array of String;
  public
    procedure SaveRecordToStream(ADataset : TDataset; var AStream : TStream);
    procedure LoadRecordFromStream(ADataset : TDataset; AStream : TStream);
    function  SaveRecordDWMemToStream(IDataset : IRESTDWMemTable; var AStream : TStream) : integer;
    procedure LoadRecordDWMemFromStream(IDataset : IRESTDWMemTable; AStream : TStream);
  public
    procedure SaveDWMemToStream(IDataset : IRESTDWMemTable; var AStream : TStream); override;
    procedure LoadDWMemFromStream(IDataset : IRESTDWMemTable; AStream : TStream); override;
    procedure SaveDatasetToStream(ADataset : TDataset; var AStream : TStream); override;
    procedure LoadDatasetFromStream(ADataset : TDataset; AStream : TStream); override;
  end;

implementation

uses
  uRESTDWProtoTypes, uRESTDWBufferBase;

{ TRESTDWStorageBin }

procedure TRESTDWStorageBin.LoadDatasetFromStream(ADataset: TDataset; AStream: TStream);
var
  vFieldCount : integer;
  vFieldKind : TFieldKind;
  vRecordCount, r : Int64;
  i : Integer;
  vInt : integer;
  vString : utf8string;
  vFieldType : Byte;
  vBoolean : boolean;
  vByte : byte;
  vFieldDef : TFieldDef;
  vFieldAttrs  : array of byte;
  vField : TField;
begin
  AStream.Position := 0;
  // field count
  AStream.Read(vFieldCount,SizeOf(Integer));
  SetLength(FFieldTypes, vFieldCount);

  SetLength(vFieldAttrs, vFieldCount);
  SetLength(FFieldNames, vFieldCount);

  // encodestr
  AStream.Read(vBoolean, Sizeof(vBoolean));
  EncodeStrs := vBoolean;

  ADataset.Close;
  ADataset.FieldDefs.Clear;

  for i := 0 to vFieldCount-1 do begin
    // field kind
    AStream.Read(vByte,SizeOf(vByte));
    vFieldKind := TFieldKind(vByte);

    vFieldDef := ADataset.FieldDefs.AddFieldDef;

    // fieldname
    AStream.Read(vByte,SizeOf(vByte));
    SetLength(vString,vByte);
    AStream.Read(vString[InitStrPos],vByte);
    vFieldDef.Name := vString;

    FFieldNames[i] := vString;

    // field type
    AStream.Read(vFieldType,SizeOf(vFieldType));
    vFieldDef.DataType := DWFieldTypeToFieldType(vFieldType);

    FFieldTypes[i] := vFieldType;

    // field size
    AStream.Read(vInt,SizeOf(Integer));
    vFieldDef.Size := vInt;

    // field precision
    AStream.Read(vInt,SizeOf(Integer));
    if (vFieldType in [dwftFloat,dwftCurrency,dwftExtended,dwftSingle]) then begin
      vFieldDef.Precision := vInt;
    end
    else if (vFieldType in [dwftBCD, dwftFMTBcd]) then begin
      vFieldDef.Size := 0;
      vFieldDef.Precision := 0;
    end;

    // field required + provider flag
    AStream.Read(vByte,SizeOf(Byte));
    vFieldAttrs[i] := vByte;
    vFieldDef.Required := vByte and 1 > 0;
  end;

  // provider flags deve ser recolocado depois dos fields criados
  for i := 0 to vFieldCount-1 do begin
    vField := ADataset.FindField(FFieldNames[i]);
    if vField <> nil then begin
      vField.ProviderFlags := [];
      if vFieldAttrs[i] and 2 > 0 then
        vField.ProviderFlags := vField.ProviderFlags + [pfInUpdate];
      if vFieldAttrs[i] and 4 > 0 then
        vField.ProviderFlags := vField.ProviderFlags + [pfInWhere];
      if vFieldAttrs[i] and 8 > 0 then
        vField.ProviderFlags := vField.ProviderFlags + [pfInKey];
      if vFieldAttrs[i] and 16 > 0 then
        vField.ProviderFlags := vField.ProviderFlags + [pfHidden];
      {$IFDEF RESTDWLAZARUS}
        if vFieldAttrs[i] and 32 > 0 then
          vField.ProviderFlags := vField.ProviderFlags + [pfRefreshOnInsert];
        if vFieldAttrs[i] and 64 > 0 then
          vField.ProviderFlags := vField.ProviderFlags + [pfRefreshOnUpdate];
      {$ENDIF}
    end;
  end;

  AStream.Read(vRecordCount,SizeOf(vRecordCount));
  ADataset.Open;

  ADataset.DisableControls;
  r := 0;
  While r <=  vRecordCount do //Anderson
  begin
    ADataset.Append;
    LoadRecordFromStream(ADataset,AStream);
    ADataset.Post;
    inc(r);
  end;

  ADataset.EnableControls;
end;

procedure TRESTDWStorageBin.LoadDWMemFromStream(IDataset: IRESTDWMemTable; AStream: TStream);
var
  ADataSet : TRESTDWMemTable;
  vFieldsCount : integer;
  vRecordCount, r : int64;
  i : Integer;
  vInt : integer;
  vFieldKind : TFieldKind;
  vString : utf8string;
  vFieldType : Byte;
  vBoolean : boolean;
  vByte : byte;
  vFieldDef : TFieldDef;
  vFieldAttrs : array of byte;
  vField : TField;
begin
  ADataSet := TRESTDWMemTable(IDataset.GetDataset);

  // field count
  AStream.Position := 0;
  AStream.Read(vFieldsCount, SizeOf(vFieldsCount));

  SetLength(FFieldTypes, vFieldsCount);
  SetLength(vFieldAttrs, vFieldsCount);
  SetLength(FFieldNames, vFieldsCount);

  // encodestrs
  AStream.Read(vBoolean, Sizeof(vBoolean));
  EncodeStrs := vBoolean;

  ADataSet.Close;
  ADataSet.FieldDefs.Clear;

  for i := 0 to vFieldsCount-1 do begin
    // field kind
    AStream.Read(vByte,SizeOf(vByte));
    vFieldKind := TFieldKind(vByte);

    vFieldDef := ADataSet.FieldDefs.AddFieldDef;

    // field name
    AStream.Read(vByte,SizeOf(vByte));
    SetLength(vString,vByte);
    AStream.Read(vString[InitStrPos],vByte);
    vFieldDef.Name := vString;

    FFieldNames[I] := vString;

    // datatype
    AStream.Read(vFieldType,SizeOf(Byte));
    vFieldDef.DataType := DWFieldTypeToFieldType(vFieldType);

    FFieldTypes[i] := vFieldType;

    // field size
    AStream.Read(vInt,SizeOf(Integer));
    vFieldDef.Size := vInt;

    // field precision
    AStream.Read(vInt,SizeOf(Integer));
    if (vFieldType in [dwftFloat, dwftCurrency,dwftExtended,dwftSingle]) then begin
      vFieldDef.Precision := vInt
    end
    else if (vFieldType in [dwftBCD, dwftFMTBcd]) then begin
      vFieldDef.Size := 0;
      vFieldDef.Precision := 0;
    end;

    // required + provider flags
    AStream.Read(vByte,SizeOf(Byte));
    vFieldAttrs[i] := vByte;
    vFieldDef.Required := vByte and 1 > 0;
  end;

  ADataSet.Open;

  // provider flags deve ser recolocado depois dos fields criados
  for i := 0 to vFieldsCount-1 do begin
    vField := ADataSet.FindField(FFieldNames[i]);
    if vField <> nil then begin
      vField.ProviderFlags := [];
      if vFieldAttrs[i] and 2 > 0  Then
        vField.ProviderFlags := vField.ProviderFlags + [pfInUpdate];
      if vFieldAttrs[i] and 4 > 0  Then
        vField.ProviderFlags := vField.ProviderFlags + [pfInWhere];
      if vFieldAttrs[i] and 8 > 0  Then
        vField.ProviderFlags := vField.ProviderFlags + [pfInKey];
      if vFieldAttrs[i] and 16 > 0 Then
        vField.ProviderFlags := vField.ProviderFlags + [pfHidden];
      {$IFDEF RESTDWLAZARUS}
        if vFieldAttrs[i] and 32 > 0 Then
          vField.ProviderFlags := vField.ProviderFlags + [pfRefreshOnInsert];
        if vFieldAttrs[i] and 64 > 0 Then
          vField.ProviderFlags := vField.ProviderFlags + [pfRefreshOnUpdate];
      {$ENDIF}
    end;
  end;

  ADataSet.DisableControls;
  LoadRecordDWMemFromStream(IDataset,AStream);
  ADataSet.EnableControls;
end;

procedure TRESTDWStorageBin.LoadRecordDWMemFromStream(IDataset: IRESTDWMemTable; AStream: TStream);
var
  ADataset  : TRESTDWMemTable;
  i : Integer;
  j : integer;
  vRecCount, r : int64;
  vFieldCount : integer;
  vFieldSize : integer;
  vRec : TRESTDWRecord;
  vBuf : TRESTDWBuffer;
  vDWFieldType : Byte;
  vInt64 : int64;
  vString : utf8string;
  vBoolean : boolean;
  vByte : Byte;
  vSmallInt : smallint;
  vInt : integer;
  vSingle : Single;
  vDouble : Double;
  vCurrency : Currency;
  vBlobField : PRESTDWBlobField;
  vDecBuf : int64;
  sStr : TStringStream;

  procedure clearBuffer;
  var
    f,z,n : integer;
  begin
    n := IDataSet.GetRecordSize;
    FillChar(vBuf^, n, 0);
  end;

begin
  ADataset := TRESTDWMemTable(IDataset.GetDataset);

  // record count
  AStream.Read(vRecCount, SizeOf(vRecCount));
  vRecCount := vRecCount - 1;

  vFieldCount := Length(FFieldNames);
  vFieldCount := vFieldCount - 1;

  r := 0;
  while r <= vRecCount do begin        //Anderson
    GetMem(vBuf, IDataset.GetRecordSize);
    clearBuffer;
    vDecBuf := 0;
    for j := 0 To vFieldCount do begin
      vDWFieldType := FFieldTypes[j];
      AStream.Read(vBoolean, SizeOf(vBoolean));
      vFieldSize := IDataSet.GetFieldSize(j);
      if not vBoolean then begin
        // not null
        vBoolean := not vBoolean;
        Move(vBoolean,vBuf^,SizeOf(vBoolean));
        Inc(vBuf);
        // N Bytes - Strings
        if (vDWFieldType in [dwftFixedWideChar,dwftWideString]) then begin
          AStream.Read(vInt64, SizeOf(vInt64));
          vString := '';
          if vInt64 > 0 then begin
            SetLength(vString, vInt64);
            {$IFDEF RESTDWLAZARUS}
              AStream.Read(Pointer(vString)^, vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString, csUndefined);
              vString := GetStringEncode(vString, csUndefined);
            {$ELSE}
              AStream.Read(vString[InitStrPos], vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString);
            {$ENDIF}
            vInt64 := (Length(vString) + 1) * SizeOf(WideChar);
            Move(WideString(vString)[InitStrPos], vBuf^, vInt64);
          end;
        end
        // N Bytes - Strings
        else if (vDWFieldType in [dwftFixedChar,dwftString]) then begin
          AStream.Read(vInt64, SizeOf(vInt64));
          vString := '';
          if vInt64 > 0 then begin
            SetLength(vString, vInt64);
            {$IFDEF RESTDWLAZARUS}
              AStream.Read(Pointer(vString)^, vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString, csUndefined);
              vString := GetStringEncode(vString, csUndefined);
            {$ELSE}
              AStream.Read(vString[InitStrPos], vInt64);
//              vString:= utf8decode(rawbytestring(vString));
              if EncodeStrs then
                vString := DecodeStrings(vString);
            {$ENDIF}
            Move(vString[InitStrPos], vBuf^, vInt64);
          end;
        end
        // 1 - Byte - Inteiro
        else if (vDWFieldType in [dwftByte,dwftShortint]) then
        begin
          AStream.Read(vByte, SizeOf(vByte));
          Move(vByte,vBuf^,Sizeof(vByte));
        end
        // 1 - Byte - Boolean
        else if (vDWFieldType in [dwftBoolean]) then
        begin
          AStream.Read(vBoolean, SizeOf(vBoolean));
          Move(vBoolean,vBuf^,Sizeof(vBoolean));
        end
        // 2 - Bytes
        else if (vDWFieldType in [dwftSmallint,dwftWord]) then begin
          AStream.Read(vSmallInt, SizeOf(vSmallInt));
          Move(vSmallInt,vBuf^,Sizeof(vSmallInt));
        end
        // 4 - Bytes - Inteiros
        else if (vDWFieldType in [dwftInteger]) then
        begin
          AStream.Read(vInt, SizeOf(vInt));
          Move(vInt,vBuf^,Sizeof(vInt));
        end
        // 4 - Bytes - Flutuantes
        else if (vDWFieldType in [dwftSingle]) then
        begin
          AStream.Read(vSingle, SizeOf(vSingle));
          Move(vSingle,vBuf^,Sizeof(vSingle));
        end
        // 8 - Bytes - Inteiros
        else if (vDWFieldType in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
        begin
          AStream.Read(vInt64, SizeOf(vInt64));
          Move(vInt64,vBuf^,Sizeof(vInt64));
        end
        // 8 - Bytes - Flutuantes
        else if (vDWFieldType in [dwftFloat,dwftExtended]) then
        begin
          AStream.Read(vDouble, SizeOf(vDouble));
          Move(vDouble,vBuf^,Sizeof(vDouble));
        end
        // 8 - Bytes - Date, Time, DateTime, TimeStamp
        else if (vDWFieldType in [dwftDate,dwftTime,dwftDateTime,dwftTimeStamp]) then
        begin
          AStream.Read(vDouble, SizeOf(vDouble));
          Move(vDouble,vBuf^,Sizeof(vDouble));
        end
        // TimeStampOffSet To Double - 8 Bytes
        // + TimeZone                - 2 Bytes
        else if (vDWFieldType in [dwftTimeStampOffset]) then begin
          AStream.Read(vDouble, SizeOf(vDouble));
          Move(vDouble,vBuf^,Sizeof(vDouble));
          Inc(vBuf,Sizeof(vDouble));
          AStream.Read(vByte, SizeOf(vByte));
          Move(vByte, vBuf^,Sizeof(vByte));
          Inc(vBuf,Sizeof(vByte));
          AStream.Read(vByte, SizeOf(vByte));
          Move(vByte, vBuf^,Sizeof(vByte));
          Inc(vBuf,Sizeof(vByte));
          Dec(vBuf,vFieldSize);
        end
        // 8 - Bytes - Currency/BCD
        else if (vDWFieldType in [dwftCurrency,dwftBCD,dwftFMTBcd]) then
        begin
          AStream.Read(vCurrency, SizeOf(vCurrency));
          Move(vCurrency,vBuf^,Sizeof(vCurrency));
        end
        // N Bytes - WideString Blobs
        else if (vDWFieldType in [dwftWideMemo,dwftFmtMemo]) then
        begin
          AStream.Read(vInt64, SizeOf(vInt64));
          vString := '';
          if vInt64 > 0 then begin
            SetLength(vString, vInt64);
            {$IFDEF RESTDWLAZARUS}
              AStream.Read(Pointer(vString)^, vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString, csUndefined);
              vString := GetStringEncode(vString, csUndefined);
            {$ELSE}
              AStream.Read(vString[InitStrPos], vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString);
            {$ENDIF}
            vInt64 := Length(widestring(Vstring)) * SizeOf(WideChar);
            //vInt64 := vInt64 + 1;
            vBlobField :=  New(PRESTDWBlobField);
            FillChar(vBlobField^, SizeOf(TRESTDWBlobField), 0);
            vBlobField^.Size := vInt64;
            ReallocMem(vBlobField^.Buffer, vInt64);
            Move(widestring(Vstring)[InitStrPos], vBlobField^.Buffer^, vInt64);

            Move(vBlobField,vBuf^,SizeOf(Pointer));
            IDataset.AddBlobList(vBlobField);
          end;
        end
        // N Bytes - String Blobs
        else if (vDWFieldType in [dwftMemo]) then
        begin
          AStream.Read(vInt64, SizeOf(vInt64));
          vString := '';
          if vInt64 > 0 then begin
            SetLength(vString, vInt64);
            {$IFDEF RESTDWLAZARUS}
              AStream.Read(Pointer(vString)^, vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString, csUndefined);
              vString := GetStringEncode(vString, csUndefined);
            {$ELSE}
              AStream.Read(vString[InitStrPos], vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString);
            {$ENDIF}
            vInt64 := Length(vString);
            vBlobField := New(PRESTDWBlobField);
            FillChar(vBlobField^, SizeOf(TRESTDWBlobField), 0);
            vBlobField^.Size := vInt64;
            ReAllocMem(vBlobField^.Buffer, vInt64);
            Move(vString[InitStrPos], vBlobField^.Buffer^, vInt64);

            Move(vBlobField,vBuf^,SizeOf(Pointer));
            IDataset.AddBlobList(vBlobField);
          end;
        end
        // N Bytes - Others Blobs
        else if (vDWFieldType in [dwftStream,dwftBlob,dwftBytes]) then
        begin
          AStream.Read(vInt64, SizeOf(vInt64));
          If vInt64 > 0 Then Begin
            vBlobField := New(PRESTDWBlobField);
            FillChar(vBlobField^, SizeOf(TRESTDWBlobField), 0);
            vBlobField^.Size := vInt64;
            ReAllocMem(vBlobField^.Buffer, vInt64);
            AStream.Read(vBlobField^.Buffer^, vInt64);
            Move(vBlobField,vBuf^,SizeOf(Pointer)); //TRESTDWBlobField
            IDataset.AddBlobList(vBlobField);
          end;
        end
        // N Bytes - Others
        else begin
          AStream.Read(vInt64, SizeOf(vInt64));
          vString := '';
          if vInt64 > 0 then begin
            SetLength(vString, vInt64);
            {$IFDEF RESTDWLAZARUS}
              AStream.Read(Pointer(vString)^, vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString, csUndefined);
              vString := GetStringEncode(vString, csUndefined);
            {$ELSE}
              AStream.Read(vString[InitStrPos], vInt64);
              if EncodeStrs then
                vString := DecodeStrings(vString);
            {$ENDIF}
            Move(vString[InitStrPos], vBuf^, vInt64);
          end;
        end;
      end
      else begin
        // null
        vBoolean := not vBoolean;
        Move(vBoolean,vBuf^,SizeOf(vBoolean));
        Inc(vBuf);
        FillChar(vBuf^, vFieldSize, 0);
      end;
      Inc(vBuf,vFieldSize);
      vDecBuf := vDecBuf + vFieldSize + 1;
    end;
    Dec(vBuf,vDecBuf);
    vRec := TRESTDWRecord.Create(ADataset);
    vRec.Buffer := vBuf;
    Freemem(vBuf);
    IDataset.AddNewRecord(vRec);
    inc(r);
  end;
end;

procedure TRESTDWStorageBin.LoadRecordFromStream(ADataset: TDataset; AStream: TStream);
var
  vField        : TField;
  i : integer;
  vString       : utf8string;
  vInt64        : Int64;
  vInt          : Integer;
  vDouble       : Double;
  vTimeZone     : Double;
  vSingle       : Single;
  vSmallint     : Smallint;
  vCurrency     : Currency;
  vMemoryAStream : TMemoryStream;
  vBoolean      : Boolean;
  vByte         : Byte;
  {$IFDEF DELPHIXEUP}
  vTimeStampOffset : TSQLTimeStampOffset;
  {$ENDIF}
begin
  for i := 0 to Length(FFieldTypes)-1 do begin
    vField := ADataset.Fields[i];
    vField.Clear;
    AStream.Read(vBoolean, Sizeof(Byte));
    if vBoolean then // is null
      Continue;
    // N - Bytes
    if (FFieldTypes[i] in [dwftFixedChar,dwftWideString,dwftString,dwftMemo,
                           dwftFixedWideChar,dwftWideMemo,dwftFmtMemo]) then begin
      AStream.Read(vInt64, Sizeof(vInt64));
      vString := '';
      if vInt64 > 0 then begin
        SetLength(vString, vInt64);
        {$IFDEF RESTDWLAZARUS}
         AStream.Read(Pointer(vString)^, vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString, csUndefined);
         vString := GetStringEncode(vString, csUndefined);
        {$ELSE}
         AStream.Read(vString[InitStrPos], vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString);
        {$ENDIF}
      end;
      vField.AsString := vString;
    end
    // 1 - Byte - Inteiro
    else if (FFieldTypes[i] in [dwftByte,dwftShortint]) then
    begin
      AStream.Read(vByte, Sizeof(vByte));
      vField.AsInteger := vByte;
    end
    // 1 - Byte - Boolean
    else if (FFieldTypes[i] in [dwftByte,dwftShortint]) then
    begin
      AStream.Read(vBoolean, Sizeof(vBoolean));
      vField.AsBoolean := vBoolean;
    end
    // 2 - Bytes
    else if (FFieldTypes[i] in [dwftSmallint,dwftWord]) then begin
      AStream.Read(vSmallint, Sizeof(vSmallint));
      vField.AsInteger := vSmallint;
    end
    // 4 - Bytes - Inteiros
    else if (FFieldTypes[i] in [dwftInteger]) then
    begin
      AStream.Read(vInt, Sizeof(vInt));
      vField.AsInteger := vInt;
    end
    // 4 - Bytes - Flutuantes
    else if (FFieldTypes[i] in [dwftSingle]) then
    begin
      AStream.Read(vSingle, Sizeof(vSingle));
      {$IFDEF DELPHIXEUP}
      vField.AsSingle := vSingle;
      {$ELSE}
      vField.AsFloat := vSingle;
      {$ENDIF}
    end
    // 8 - Bytes - Inteiros
    else if (FFieldTypes[i] in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
    begin
      AStream.Read(vInt64, Sizeof(vInt64));
      {$IFDEF DELPHIXEUP}
      vField.AsLargeInt := vInt64;
      {$ELSE}
      vField.AsInteger := vInt64;
      {$ENDIF}
    end
    // 8 - Bytes - Flutuantes
    else if (FFieldTypes[i] in [dwftFloat,dwftExtended]) then
    begin
      AStream.Read(vDouble, Sizeof(vDouble));
      vField.AsFloat := vDouble;
    end
    // 8 - Bytes - Date, Time, DateTime
    else if (FFieldTypes[i] in [dwftDate,dwftTime,dwftDateTime]) then
    begin
      AStream.Read(vDouble, Sizeof(vDouble));
      vField.AsDateTime := vDouble;
    end
    // TimeStamp To Double - 8 Bytes
    else if (FFieldTypes[i] in [dwftTimeStamp]) then begin
      AStream.Read(vDouble, Sizeof(vDouble));
      vField.AsDateTime := vDouble;
    end
    // TimeStampOffSet To Double - 8 Bytes
    // + TimeZone                - 2 Bytes
    else if (FFieldTypes[i] in [dwftTimeStampOffset]) then begin
      {$IFDEF DELPHIXEUP}
        AStream.Read(vDouble, Sizeof(vDouble));
        vTimeStampOffset := DateTimeToSQLTimeStampOffset(vDouble);
        AStream.Read(vByte, Sizeof(vByte));
        vTimeStampOffset.TimeZoneHour := vByte - 12;
        AStream.Read(vByte, Sizeof(vByte));
        vTimeStampOffset.TimeZoneMinute := vByte;
        vField.AsSQLTimeStampOffset := vTimeStampOffset;
      {$ELSE}
        // field foi transformado em datetime
        AStream.Read(vDouble, Sizeof(vDouble));
        AStream.Read(vByte, SizeOf(vByte));
        vTimeZone := (vByte - 12) / 24;
        AStream.Read(vByte, SizeOf(vByte));
        if vTimeZone > 0 then
          vTimeZone := vTimeZone + (vByte / 60 / 24)
        else
          vTimeZone := vTimeZone - (vByte / 60 / 24);
        vDouble := vDouble - vTimeZone;
        vField.AsDateTime := vDouble;
      {$ENDIF}
    end
    // 8 - Bytes - Currency
    else if (FFieldTypes[i] in [dwftCurrency,dwftBCD,dwftFMTBcd]) then
    begin
      AStream.Read(vCurrency, Sizeof(vCurrency));
      vField.AsCurrency := vCurrency;
    end
    // N Bytes - Blobs
    else if (FFieldTypes[i] in [dwftStream,dwftBlob,dwftBytes]) then
    begin
      AStream.Read(vInt64, Sizeof(DWInt64));
      if vInt64 > 0 then Begin
        vMemoryAStream := TMemoryStream.Create;
        try
          vMemoryAStream.CopyFrom(AStream, vInt64);
          vMemoryAStream.Position := 0;
          TBlobField(vField).LoadFromStream(vMemoryAStream);
        finally
          FreeAndNil(vMemoryAStream);
        end;
      end;
    end
    // N Bytes - Others
    else begin
      AStream.Read(vInt64, Sizeof(vInt64));
      vString := '';
      if vInt64 > 0 then begin
        SetLength(vString, vInt64);
        {$IFDEF RESTDWLAZARUS}
         AStream.Read(Pointer(vString)^, vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString, csUndefined);
         vString := GetStringEncode(vString, csUndefined);
        {$ELSE}
         AStream.Read(vString[InitStrPos], vInt64);
         if EncodeStrs then
           vString := DecodeStrings(vString);
        {$ENDIF}
      end;
      vField.AsString := vString;
    end;
  end;
end;

procedure TRESTDWStorageBin.SaveDatasetToStream(ADataset: TDataset; var AStream: TStream);
var
  i : integer;
  vRecordCount : int64;
  vString : utf8string;
  vInt : integer;
  vBoolean : boolean;
  vByte : byte;
  vBookMark : TBookmark;
begin
  //  AStream.Size := 0; // TBufferedFileStream nao funciona no lazarus
  AStream.Seek(0,soBeginning);
  if not ADataset.Active then
    ADataset.Open
  else
    ADataset.CheckBrowseMode;

  ADataset.UpdateCursorPos;

  // fields cound
  i := ADataset.FieldCount;
  AStream.Write(i,SizeOf(integer));

  // encodestr
  vBoolean := EncodeStrs;
  AStream.Write(vBoolean,SizeOf(vBoolean));

  i := 0;
  while i < ADataset.FieldCount do begin
    // field kind
    vByte := Ord(ADataset.Fields[i].FieldKind);
    AStream.Write(vByte,SizeOf(vByte));

    // field name
    vString := ADataset.Fields[i].DisplayName;
    vByte := Length(vString);
    AStream.Write(vByte,SizeOf(vByte));
    AStream.Write(vString[InitStrPos],vByte);

    // datatype
    vByte := FieldTypeToDWFieldType(ADataset.Fields[i].DataType);
    AStream.Write(vByte,SizeOf(Byte));

    // field size
    vInt := ADataset.Fields[i].Size;
    AStream.Write(vInt,SizeOf(Integer));

    // field precision
    vInt := 0;
    if ADataset.Fields[i].InheritsFrom(TFloatField) then
      vInt := TFloatField(ADataset.Fields[i]).Precision;
    AStream.Write(vInt,SizeOf(Integer));

    // requeired + provider flags
    vByte := 0;
    if ADataset.Fields[i].Required then
      vByte := vByte + 1;
    if pfInUpdate in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 2;
    if pfInWhere in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 4;
    if pfInKey in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 8;
    if pfHidden in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 16;
    {$IFDEF RESTDWLAZARUS}
      if pfRefreshOnInsert in ADataset.Fields[i].ProviderFlags then
        vByte := vByte + 32;
      if pfRefreshOnUpdate in ADataset.Fields[i].ProviderFlags then
        vByte := vByte + 64;
    {$ENDIF}
    AStream.Write(vByte,SizeOf(Byte));
    i := i + 1;
  end;
  i := AStream.Position;

  // marcando position do recordcount = 0
  vRecordCount := 0;
  AStream.WriteBuffer(vRecordCount,SizeOf(vRecordCount));

  if not ADataset.IsUniDirectional then
    vBookMark := ADataset.GetBookmark;

  ADataset.DisableControls;

  if not ADataset.IsUniDirectional then
    ADataset.First;

  vRecordCount := 0;
  while not ADataset.Eof do begin
    try
      SaveRecordToStream(ADataset,AStream);
    except

    end;
    ADataset.Next;
    vRecordCount := vRecordCount + 1;
  end;

  if not ADataset.IsUniDirectional then begin
    ADataset.GotoBookmark(vBookMark);
    ADataset.FreeBookmark(vBookMark);
  end;

  ADataset.EnableControls;

  // marcando novo valor de recordcount
  AStream.Position := i;
  AStream.WriteBuffer(vRecordCount,SizeOf(vRecordCount));
  AStream.Position := 0;
end;

procedure TRESTDWStorageBin.SaveDWMemToStream(IDataset: IRESTDWMemTable; var AStream: TStream);
var
  i : integer;
  ADataset : TRESTDWMemTable;
  vRecordCount : int64;
  vString : utf8string;
  vInt : integer;
  vBoolean : boolean;
  vByte : byte;
  vBookMark : TBookmark;
begin
  ADataSet := TRESTDWMemTable(IDataset.GetDataset);
  AStream.Size := 0;
  if not ADataset.Active then
    ADataset.Open
  else
    ADataset.CheckBrowseMode;
  ADataset.UpdateCursorPos;

  // field count
  i := ADataset.FieldCount;
  AStream.Write(i,SizeOf(integer));

  // encode str
  vBoolean := EncodeStrs;
  AStream.Write(vBoolean,SizeOf(Byte));

  i := 0;
  while i < ADataset.FieldCount do begin
    // fieldkind
    vByte := Ord(ADataset.Fields[i].FieldKind);
    AStream.Write(vByte,SizeOf(vByte));

    // fieldname
    vString := ADataset.Fields[i].DisplayName;
    vByte := Length(vString);
    AStream.Write(vByte,SizeOf(vByte));
    AStream.Write(vString[InitStrPos],vByte);

    // datatype
    vByte := FieldTypeToDWFieldType(ADataset.Fields[i].DataType);
    AStream.Write(vByte,SizeOf(Byte));

    // fieldsize
    vInt := ADataset.Fields[i].Size;
    AStream.Write(vInt,SizeOf(Integer));

    // field precision
    vInt := 0;
    if ADataset.Fields[i].InheritsFrom(TFloatField) then
      vInt := TFloatField(ADataset.Fields[i]).Precision;
    AStream.Write(vInt,SizeOf(Integer));

    // required + provider flags
    vByte := 0;
    if ADataset.Fields[i].Required then
      vByte := vByte + 1;
    if pfInUpdate in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 2;
    if pfInWhere in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 4;
    if pfInKey in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 8;
    if pfHidden in ADataset.Fields[i].ProviderFlags then
      vByte := vByte + 16;
    {$IFDEF RESTDWLAZARUS}
      if pfRefreshOnInsert in ADataset.Fields[i].ProviderFlags then
        vByte := vByte + 32;
      if pfRefreshOnUpdate in ADataset.Fields[i].ProviderFlags then
        vByte := vByte + 64;
    {$ENDIF}
    AStream.Write(vByte,SizeOf(Byte));

    i := i + 1;
  end;
  i := AStream.Position;

  // marcando position recordcount = 0
  vRecordCount := 0;
  AStream.WriteBuffer(vRecordCount,SizeOf(vRecordCount));

  vRecordCount := SaveRecordDWMemToStream(IDataSet,AStream);

  // salvando novo valor de recordcount
  AStream.Position := i;
  AStream.WriteBuffer(vRecordCount,SizeOf(vRecordCount));
  AStream.Position := 0;
end;

function TRESTDWStorageBin.SaveRecordDWMemToStream(IDataset: IRESTDWMemTable; var AStream: TStream) : Integer;
var
  ADataSet : TRESTDWMemTable;
  i : Longint;
  j : integer;
  vFieldSize : integer;
  vDWFieldType : Byte;
  vFieldCount : integer;
  vRec : TRESTDWRecord;
  vBuf : TRESTDWBuffer;
  vBoolean : boolean;
  vString : utf8string;
  vInt : integer;
  vInt64 : int64;
  vByte : Byte;
  vSmallint : Smallint;
  vSingle : Single;
  vDouble : double;
  vCurrency : Currency;
  vBlob : PRESTDWBlobField;
  vDecBuf : int64;
Begin
  ADataSet := TRESTDWMemTable(IDataset.GetDataset);
  vFieldCount := ADataSet.Fields.Count - 1;
  Result := ADataset.RecordCount - 1;
  for i := 0 to Result do begin
    vRec := IDataset.GetRecordObj(i);
    GetMem(vBuf,IDataSet.GetRecordSize);
    Move(vRec.Buffer^,vBuf^,IDataSet.GetRecordSize);
    vDecBuf := 0;
    for j := 0 To vFieldCount do begin
      Move(vBuf^,vBoolean,SizeOf(vBoolean));
      Inc(vBuf);
      vBoolean := not vBoolean;
      AStream.Write(vBoolean,SizeOf(Boolean));
      vFieldSize := IDataset.GetFieldSize(j);
      if not vBoolean then begin
        // N Bytes
        vDWFieldType := FieldTypeToDWFieldType(ADataset.Fields[j].DataType);
        if (vDWFieldType in [dwftFixedChar,dwftWideString,dwftString,
                             dwftFixedWideChar]) then begin
          SetLength(vString,vFieldSize);
          Move(vBuf^,vString[InitStrPos],vFieldSize);
          if EncodeStrs then
            vString := EncodeStrings(vString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
          vInt64 := Length(vString);
          AStream.Write(vInt64, Sizeof(vInt64));
          if vInt64 <> 0 then
            AStream.Write(vString[InitStrPos], vInt64);
        end
        // 1 - Byte
        else if (vDWFieldType in [dwftByte,dwftShortint,dwftBoolean]) then
        begin
          Move(vBuf^,vByte,Sizeof(vByte));
          AStream.Write(vByte, SizeOf(vByte));
        end
        // 2 - Bytes
        else if (vDWFieldType in [dwftSmallint,dwftWord]) then begin
          Move(vBuf^,vSmallint,Sizeof(vSmallint));
          AStream.Write(vSmallint, SizeOf(vSmallint));
        end
        // 4 - Bytes - Inteiros
        else if (vDWFieldType in [dwftInteger]) then
        begin
          Move(vBuf^,vInt,Sizeof(vInt));
          AStream.Write(vInt, Sizeof(vInt));
        end
        // 4 - Bytes - Flutuantes
        else if (vDWFieldType in [dwftSingle]) then
        begin
          Move(vBuf^,vSingle,Sizeof(vSingle));
          AStream.Write(vSingle, Sizeof(vSingle));
        end
        // 8 - Bytes - Inteiros
        else if (vDWFieldType in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
        begin
          Move(vBuf^,vInt64,Sizeof(vInt64));
          AStream.Write(vInt64, Sizeof(vInt64));
        end
        // 8 - Bytes - Flutuantes
        else if (vDWFieldType in [dwftFloat,dwftExtended,dwftDate,dwftTime,dwftDateTime]) then
        begin
          Move(vBuf^,vDouble,Sizeof(vDouble));
          AStream.Write(vDouble, Sizeof(vDouble));
        end
        // TimeStamp To Double - 8 Bytes
        else if (vDWFieldType in [dwftTimeStamp]) then begin
          Move(vBuf^,vDouble,Sizeof(vDouble));
          AStream.Write(vDouble, Sizeof(vDouble));
        end
        {$IFDEF DELPHIXEUP}
            // TimeStampOffSet To Double - 8 Bytes
            // + TimeZone                - 2 Bytes
            else if (vDWFieldType in [dwftTimeStampOffset]) then begin
              Move(vBuf^,vDouble,Sizeof(vDouble));
              AStream.Write(vDouble, Sizeof(vDouble));
              Inc(vBuf,Sizeof(vDouble));
              Move(vBuf^,vByte,Sizeof(vByte));
              AStream.Write(vByte, Sizeof(vByte));
              Inc(vBuf,Sizeof(vByte));
              Move(vBuf^,vByte,Sizeof(vByte));
              AStream.Write(vByte, Sizeof(vByte));
              Inc(vBuf,Sizeof(vByte));
              Dec(vBuf,vFieldSize);
            end
        {$ENDIF}
        // 8 - Bytes - Currency/BCD
        else if (vDWFieldType in [dwftCurrency,dwftBCD,dwftFMTBcd]) then
        begin
          Move(vBuf^,vCurrency,Sizeof(vCurrency));
          AStream.Write(vCurrency, Sizeof(vCurrency));
        end
        // N Bytes - Blobs
        else if (vDWFieldType in [dwftStream,dwftBlob,dwftBytes,dwftWideMemo,
                                  dwftFmtMemo,dwftMemo]) then
        begin
          Move(vBuf^,vBlob,Sizeof(Pointer));
          vInt64 := vBlob^.Size;
          AStream.Write(vInt64, Sizeof(vInt64));
          AStream.Write(vBlob^.Buffer^, vBlob^.Size);
        end
        // N Bytes - Others
        else begin
          SetLength(vString,vFieldSize);
          Move(vBuf^,vString[InitStrPos],vFieldSize);
          if EncodeStrs then
            vString := EncodeStrings(vString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
          vInt64 := Length(vString);
          AStream.Write(vInt64, Sizeof(vInt64));
          if vInt64 <> 0 then
            AStream.Write(vString[InitStrPos], vInt64);
        end;
      end;
      Inc(vBuf,vFieldSize);
      vDecBuf := vDecBuf + vFieldSize + 1;
    end;
    Dec(vBuf,vDecBuf);
    FreeMem(vBuf);
  end;
  Result := Result + 1;
end;

procedure TRESTDWStorageBin.SaveRecordToStream(ADataset: TDataset; var AStream: TStream);
var
  i: integer;
  vDWFieldType : Byte;
  vBytes: TRESTDWBytes;
  vString       : RAWbytestring;
  vWideString   : Utf8string;
  vInt64        : Int64;
  vInt          : Integer;
  vDouble       : Double;
  vWord         : Word;
  vSingle       : Single;
  vCurrency     : Currency;
  vMemoryStream : TMemoryStream;
  vBoolean      : boolean;
  vByte         : Byte;
  {$IFDEF DELPHIXEUP}
  vTimeStampOffset : TSQLTimeStampOffset;
  {$ENDIF}
Begin
  vMemoryStream := nil;
  for i := 0 to ADataset.FieldCount - 1 do begin
    vBoolean := ADataset.Fields[i].IsNull;
    AStream.Write(vBoolean, SizeOf(vBoolean));

    if vBoolean then
      Continue;

    vDWFieldType := FieldTypeToDWFieldType(ADataset.Fields[i].DataType);
    // N - Bytes
    if (vDWFieldType in [dwftFixedChar,dwftWideString,
                         dwftFixedWideChar, dwftWideMemo,dwftFmtMemo
                         ]) then begin
      vWideString := ADataset.Fields[i].AsString;
      if EncodeStrs then
        vWideString := EncodeStrings(vWideString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      vInt64 := Length(vWideString);
      AStream.Write(vInt64, SizeOf(vInt64));
      if vInt64 <> 0 then
        AStream.Write(vWideString[InitStrPos], vInt64);
    end
     // N - Bytes
   else if (vDWFieldType in [dwftString, dwftMemo]) then
   begin
      vString := ADataset.Fields[i].AsString;
      if EncodeStrs then
        vString := EncodeStrings(vString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      vInt64 := Length(vString);
      AStream.Write(vInt64, SizeOf(vInt64));
      if vInt64 <> 0 then
        AStream.Write(vString[InitStrPos], vInt64);
    end
    // 1 - Byte - Inteiros
    else if (vDWFieldType in [dwftByte,dwftShortint]) then
    begin
      vByte := ADataset.Fields[i].AsInteger;
      AStream.Write(vByte, Sizeof(vByte));
    end
    // 1 - Byte - Boolean
    else if (vDWFieldType in [dwftBoolean]) then
    begin
      vBoolean := ADataset.Fields[i].AsBoolean;
      AStream.Write(vBoolean, Sizeof(vBoolean));
    end
    // 2 - Bytes
    else if (vDWFieldType in [dwftSmallint,dwftWord]) then begin
      vWord := ADataset.Fields[i].AsInteger;
      AStream.Write(vWord, Sizeof(vWord));
    end
    // 4 - Bytes - Inteiros
    else if (vDWFieldType in [dwftInteger]) then
    begin
      vInt := ADataset.Fields[i].AsInteger;
      AStream.Write(vInt, Sizeof(vInt));
    end
    // 4 - Bytes - Flutuantes
    else if (vDWFieldType in [dwftSingle]) then
    begin
      {$IFDEF DELPHIXEUP}
        vSingle := ADataset.Fields[i].AsSingle;
      {$ELSE}
        vSingle := ADataset.Fields[i].AsFloat;
      {$ENDIF}
      AStream.Write(vSingle, SizeOf(Single));
    end
    // 8 - Bytes - Inteiros
    else if (vDWFieldType in [dwftLargeint,dwftAutoInc,dwftLongWord]) then
    begin
      {$IFDEF DELPHIXEUP}
      vInt64 := ADataset.Fields[i].AsLargeInt;
      {$ELSE}
      vInt64 := ADataset.Fields[i].AsInteger;
      {$ENDIF}
      AStream.Write(vInt64, Sizeof(vInt64));
    end
    // 8 - Bytes - Flutuantes
    else if (vDWFieldType in [dwftFloat,dwftExtended]) then
    begin
      vDouble := ADataset.Fields[i].AsFloat;
      AStream.Write(vDouble, Sizeof(vDouble));
    end
    // 8 - Bytes - Date, Time, DateTime, TimeStamp
    else if (vDWFieldType in [dwftDate,dwftTime,dwftDateTime,dwftTimeStamp]) then
    begin
      vDouble := ADataset.Fields[i].AsDateTime;
      AStream.Write(vDouble, Sizeof(vDouble));
    end
    {$IFDEF DELPHIXEUP}
        // TimeStampOffSet To Double - 8 Bytes
        // + TimeZone                - 2 Bytes
        else if (vDWFieldType in [dwftTimeStampOffset]) then begin
          vTimeStampOffSet := ADataset.Fields[i].AsSQLTimeStampOffset;
          vDouble := SQLTimeStampOffsetToDateTime(vTimeStampOffSet);
          AStream.Write(vDouble, Sizeof(vDouble));
          vByte := vTimeStampOffSet.TimeZoneHour + 12;
          AStream.Write(vByte, Sizeof(vByte));
          vByte := vTimeStampOffSet.TimeZoneMinute;
          AStream.Write(vByte, Sizeof(vByte));
        end
    {$ENDIF}
    // 8 - Bytes - Currency
    else if (vDWFieldType in [dwftCurrency,dwftBCD,dwftFMTBcd]) then
    begin
      vCurrency := ADataset.Fields[i].AsCurrency;
      AStream.Write(vCurrency, Sizeof(vCurrency));
    end
    // N Bytes - Blobs
    else if (vDWFieldType in [dwftStream,dwftBlob,dwftBytes]) then
    begin
      vMemoryStream := TMemoryStream.Create;
      try
        TBlobField(ADataset.Fields[i]).SaveToStream(vMemoryStream);
        vInt64 := vMemoryStream.Size;
        AStream.Write(vInt64, SizeOf(DWInt64));
        SetLength(vBytes, vInt64);
        Try
          vMemoryStream.Position := 0;
          vMemoryStream.Read(vBytes[0], vInt64);
        except
        end;
        AStream.Write(vBytes[0], vInt64);
      Finally
        SetLength(vBytes, 0);
        FreeAndNil(vMemoryStream);
      End;
    end
    // N Bytes - Others
    else begin
      vString := ADataset.Fields[i].AsString;
      if EncodeStrs then
        vString := EncodeStrings(vString{$IFDEF RESTDWLAZARUS}, csUndefined{$ENDIF});
      vInt64 := Length(vString);
      AStream.Write(vInt64, SizeOf(vInt64));
      if vInt64 <> 0 then
        AStream.Write(vString[InitStrPos], vInt64);
    end;
  end;
end;

end.
