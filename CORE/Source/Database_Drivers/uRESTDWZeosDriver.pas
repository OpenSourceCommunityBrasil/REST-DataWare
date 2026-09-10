unit uRESTDWZeosDriver;

{$I uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilberto Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

{$IFDEF FPC}
  {$MODE DELPHI}
  {$H+}
{$ENDIF}

interface

uses
  {$IFDEF RESTDWLAZARUS}
    LResources,
  {$ENDIF}
  ZMemTable,
  Classes, SysUtils, DB, Variants, FmtBCD,
  ZConnection, ZDataset, ZSequence, ZDbcIntfs, ZAbstractRODataset,
  ZAbstractDataset, ZStoredProcedure, ZEncoding, ZDatasetUtils,
  {$IFDEF ZEOS80UP}
    ZDatasetParam,
  {$ENDIF}
  uRESTDWDriverBase, uRESTDWBasicDbTypes, uRESTDWProtoTypes, uRESTDWZeosPhysLink,
  uRESTDWMemoryDataset;

const
  rdwZeosProtocols: array[0..16] of string = ('ado','asa','asa_capi',
                    'firebird','interbase','mssql','mysql','odbc_a',
                    'odbc_w','oledb','oracle','pooled','postgresql',
                    'sqlite','sybase','webserviceproxy','mariadb'
  );

  rdwZeosDbType: array[0..16] of TRESTDWDatabaseType = (dbtAdo,dbtUndefined, dbtUndefined, dbtFirebird, dbtInterbase, dbtMsSQL, dbtMySQL,
                 dbtODBC,dbtODBC,dbtUndefined,dbtOracle,dbtUndefined,dbtPostgreSQL,
                 dbtSQLLite,dbtUndefined,dbtUndefined,dbtMySQL
  );

type
  { TRESTDWZeosStoreProc }
  TRESTDWZeosStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWZeosTable }
  TRESTDWZeosTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream: TStream); override;
    procedure SaveToStreamCompatibleMode(stream: TStream); override;
    procedure LoadFromStreamParam(IParam: integer; stream: TStream; blobtype: TBlobType); override;
    procedure FetchAll; override;
  end;

  { TRESTDWZeosQuery }
  TRESTDWZeosQuery = class(TRESTDWDrvQuery)
  private
    FSequence: TZSequence;
  protected
    procedure createSequencedField(seqname, field: string); override;
  public
    procedure SaveToStream(stream: TStream); override;
    procedure SaveToStreamCompatibleMode(stream: TStream); override;
    procedure ExecSQL; override;
    procedure Prepare; override;
    procedure FetchAll; override;
    destructor Destroy; override;
    function RowsAffected: Int64; override;
    function ParamCount: Integer; override;
    function getParamDataType(IParam: integer): TFieldType; override;
    function getParamName(IParam: integer): string; override;
    function getParamSize(IParam: integer): integer; override;
    function getParamValue(IParam: integer): variant; override;
    procedure setParamDataType(IParam: integer; AValue: TFieldType); override;
    procedure setParamValue(IParam: integer; AValue: variant); override;
    procedure LoadFromStreamParam(IParam: integer; stream: TStream; blobtype: TBlobType); override;
  end;

  { TRESTDWZeosDriver }
  TRESTDWZeosDriver = class(TRESTDWDriverBase)
  protected
    procedure setConnection(AValue: TComponent); override;
    function getConnectionType: TRESTDWDatabaseType; override;
    function compConnIsValid(comp: TComponent): boolean; override;
    procedure zAfterPost(DataSet: TDataSet);
    procedure zAfterOpen(DataSet: TDataSet);
    procedure zOnNewRecord(DataSet: TDataSet);
  public
    destructor Destroy; override;
    function getQuery: TRESTDWDrvQuery; override;
    function getQuery(AUnidir: boolean): TRESTDWDrvQuery; override;
    function getTable: TRESTDWDrvTable; override;
    function getStoreProc: TRESTDWDrvStoreProc; override;
    procedure Connect; override;
    procedure Disconect; override;
    function isConnected: boolean; override;
    function connInTransaction: boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;
    class procedure CreateConnection(const AConnectionDefs: TConnectionDefs; var AConnection: TComponent); override;
  end;

procedure Register;

implementation

Procedure SaveZeosDatasetToDWMEM(ADataset: TDataSet; AStream: TStream);
Var
  I            : Integer;
  L            : Integer;
  Field        : TField;
  Writer       : TRESTDWBinaryPacketWriter;
  Bookmark     : TBookmark;
  HasBookmark  : Boolean;
  S            : AnsiString;
  Bytes        : TRESTDWMemBytes;
{$IFDEF DELPHI2009UP}
  FieldBytes   : TBytes;
{$ENDIF}
  BlobStream   : TStream;
  VBool        : WordBool;
  VSmall       : SmallInt;
  VWord        : Word;
  VInt         : Integer;
  VInt64       : Int64;
  VDouble      : Double;
  VCurrency    : Currency;
  VBcd         : TBcd;
  VDateTime    : TDateTime;
  VGuid        : TGUID;
  Buffer       : Pointer;
Begin
  If Not Assigned(ADataset) Or Not Assigned(AStream) Then
   Exit;
  If Not ADataset.Active Then
   ADataset.Open
  Else
   ADataset.CheckBrowseMode;
  AStream.Size := 0;
  AStream.Position := 0;
  Writer := TRESTDWBinaryPacketWriter.Create(AStream);
  Try
   Writer.ClearFieldDefs;
   For I := 0 To ADataset.FieldCount - 1 Do
    Begin
     Field := ADataset.Fields[I];
     Writer.AddFieldDef(Field.FieldName,
                        Field.DisplayName,
                        Field.Size,
                        Field.DataType,
                        Field.ReadOnly);
    End;
   Writer.StoreFieldDefs(1);
   HasBookmark := False;
   If Not ADataset.IsUniDirectional Then
    Begin
     Bookmark := ADataset.GetBookmark;
     HasBookmark := True;
     ADataset.First;
    End;
   ADataset.DisableControls;
   Try
    While Not ADataset.Eof Do
     Begin
      Writer.BeginRecord;
      For I := 0 To ADataset.FieldCount - 1 Do
       Begin
        Field := ADataset.Fields[I];
        If Field.IsNull Then
         Begin
          Writer.StoreNull(I);
          Continue;
         End;
        Case Field.DataType Of
         ftString,
         ftFixedChar,
         ftWideString
{$IFDEF DELPHI2010UP}
         ,ftFixedWideChar
{$ENDIF}
          :
           Begin
            S := AnsiString(Field.AsString);
            If Length(S) > 0 Then
             Buffer := @S[1]
            Else
             Buffer := Nil;
            Writer.StoreField(I, Buffer, Length(S));
           End;
         ftSmallint:
          Begin
           VSmall := SmallInt(Field.AsInteger);
           Writer.StoreField(I, @VSmall, SizeOf(VSmall));
          End;
         ftInteger:
          Begin
           VInt := Field.AsInteger;
           Writer.StoreField(I, @VInt, SizeOf(VInt));
          End;
         ftWord:
          Begin
           VWord := Word(Field.AsInteger);
           Writer.StoreField(I, @VWord, SizeOf(VWord));
          End;
         ftBoolean:
          Begin
           VBool := Field.AsBoolean;
           Writer.StoreField(I, @VBool, SizeOf(VBool));
          End;
         ftFloat:
          Begin
           VDouble := Field.AsFloat;
           Writer.StoreField(I, @VDouble, SizeOf(VDouble));
          End;
         ftCurrency,
         ftBCD:
          Begin
           VCurrency := Field.AsCurrency;
           Writer.StoreField(I, @VCurrency, SizeOf(VCurrency));
          End;
         ftDate:
          Begin
           VDateTime := Field.AsDateTime;
           VInt := DateTimeToTimeStamp(VDateTime).Date;
           Writer.StoreField(I, @VInt, SizeOf(VInt));
          End;
         ftTime:
          Begin
           VDateTime := Field.AsDateTime;
           VInt := DateTimeToTimeStamp(VDateTime).Time;
           Writer.StoreField(I, @VInt, SizeOf(VInt));
          End;
         ftDateTime,
         ftTimeStamp
{$IFDEF DELPHI2010UP}
         ,ftOraTimeStamp,
         ftTimeStampOffset
{$ENDIF}
          :
           Begin
            VDateTime := Field.AsDateTime;
            Writer.StoreField(I, @VDateTime, SizeOf(VDateTime));
           End;
         ftLargeint,
         ftAutoInc:
          Begin
           VInt64 := Field.AsLargeInt;
           Writer.StoreField(I, @VInt64, SizeOf(VInt64));
          End;
         ftFMTBcd:
          Begin
           FillChar(VBcd, SizeOf(VBcd), 0);
           VBcd := StrToBcd(Field.AsString);
           Writer.StoreField(I, @VBcd, SizeOf(VBcd));
          End;
         ftGuid:
          Begin
           FillChar(VGuid, SizeOf(VGuid), 0);
           If Field.AsString <> '' Then
            VGuid := StringToGUID(Field.AsString);
           Writer.StoreField(I, @VGuid, SizeOf(VGuid));
          End;
         ftBlob,
         ftMemo,
         ftGraphic
{$IFDEF DELPHI2010UP}
         ,ftWideMemo
{$ENDIF}
          :
           Begin
            BlobStream := ADataset.CreateBlobStream(Field, bmRead);
            Try
             L := BlobStream.Size;
             SetLength(Bytes, L);
             BlobStream.Position := 0;
             If L > 0 Then
              Begin
               BlobStream.ReadBuffer(Bytes[0], L);
               Buffer := @Bytes[0];
              End
             Else
              Buffer := Nil;
             Writer.StoreField(I, Buffer, L);
            Finally
             BlobStream.Free;
            End;
           End;
         ftBytes,
         ftVarBytes:
          Begin
{$IFDEF DELPHI2009UP}
           FieldBytes := Field.AsBytes;
           L := Length(FieldBytes);
           SetLength(Bytes, L);
           If L > 0 Then
            Move(FieldBytes[0], Bytes[0], L);
{$ELSE}
           Bytes := Field.AsBytes;
           L := Length(Bytes);
{$ENDIF}
           If L > 0 Then
            Buffer := @Bytes[0]
           Else
            Buffer := Nil;
           Writer.StoreField(I, Buffer, L);
          End;
        Else
         DatabaseError('Zeos field type is not representable by the RESTDW DataSet binary contract: ' +
                       IntToStr(Ord(Field.DataType)));
        End;
        End;
      Writer.EndRecord;
      ADataset.Next;
     End;
   Finally
    If HasBookmark Then
     Begin
      If ADataset.BookmarkValid(Bookmark) Then
       ADataset.GotoBookmark(Bookmark);
      ADataset.FreeBookmark(Bookmark);
     End;
    ADataset.EnableControls;
   End;
  Finally
   Writer.Free;
  End;
  AStream.Position := 0;
End;

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWZeosDriver]);
  RegisterComponents('REST Dataware - PhysLink', [TRESTDWZeosPhysLink]);
end;

{ TRESTDWZeosStoreProc }

procedure TRESTDWZeosStoreProc.ExecProc;
begin
  if Assigned(Owner) and (Owner is TZStoredProc) then
    TZStoredProc(Owner).ExecProc;
end;

procedure TRESTDWZeosStoreProc.Prepare;
begin
  if Assigned(Owner) and (Owner is TZStoredProc) then
    TZStoredProc(Owner).Prepare;
end;

{ TRESTDWZeosDriver }

procedure TRESTDWZeosDriver.setConnection(AValue: TComponent);
begin
  inherited setConnection(AValue);
end;

function TRESTDWZeosDriver.getConnectionType: TRESTDWDatabaseType;
var 
   LProtocol : string;
   I         : integer;
begin
  Result := inherited getConnectionType;
  if not Assigned(Connection) then
    Exit;

  if Result = dbtUndefined then
  begin
    LProtocol := LowerCase(TZConnection(Connection).Protocol);
    
    for  I := Low(rdwZeosProtocols) to High(rdwZeosProtocols) do
      if Pos(rdwZeosProtocols[I], LProtocol) > 0 then
      begin
        Result := rdwZeosDbType[I];
        Break;
      end;
  end;
end;

function TRESTDWZeosDriver.getQuery(AUnidir: boolean): TRESTDWDrvQuery;
var
  qry: TZReadOnlyQuery;
begin
  if AUnidir then 
  begin
    qry := TZReadOnlyQuery.Create(Self);
    qry.IsUniDirectional := True;
    qry.Connection := TZConnection(Connection);
    Result := TRESTDWZeosQuery.Create(qry);
  end
  else 
  begin
    Result := inherited getQuery(AUnidir);
  end;
end;

destructor TRESTDWZeosDriver.Destroy;
begin
  inherited Destroy;
end;

procedure TRESTDWZeosDriver.zAfterPost(DataSet: TDataSet);
begin
  if DataSet is TZQuery then
    TZQuery(DataSet).RefreshCurrentRow(True);
end;

procedure TRESTDWZeosDriver.zAfterOpen(DataSet: TDataSet);
var 
   I : integer;
begin
  for I := 0 to DataSet.FieldCount - 1 do
  {$IFDEF FPC}
      if DataSet.Fields[I].DataType in [ftInteger, ftLargeint, ftAutoInc] then
    {$ELSE}
      if (DataSet.Fields[I].DataType in [ftInteger, ftLargeint, ftAutoInc]) and
         (DataSet.Fields[I].AutoGenerateValue = arAutoInc) then
    {$ENDIF}
    begin
      DataSet.Fields[I].Required := False;
      DataSet.Fields[I].ReadOnly := False;
      DataSet.Fields[I].ProviderFlags := [pfInUpdate, pfInWhere, pfInKey];
    end;
end;

procedure TRESTDWZeosDriver.zOnNewRecord(DataSet: TDataSet);
var 
   I : integer;
begin
  for I := 0 to DataSet.FieldCount - 1 do
  {$IFDEF FPC}
      if DataSet.Fields[I].DataType = ftAutoInc then
  {$ELSE}
      if (DataSet.Fields[I].DataType in [ftInteger, ftLargeint, ftAutoInc]) and
         (DataSet.Fields[I].AutoGenerateValue = arAutoInc) then
  {$ENDIF}
        DataSet.Fields[I].Clear;
end;

function TRESTDWZeosDriver.getQuery: TRESTDWDrvQuery;
var 
   qry : TZQuery;
begin
  qry := TZQuery.Create(Self);
  qry.Connection := TZConnection(Connection);
  qry.AfterPost := zAfterPost;
  qry.AfterOpen := zAfterOpen;
  
  Result := TRESTDWZeosQuery.Create(qry);
end;

function TRESTDWZeosDriver.getTable: TRESTDWDrvTable;
var 
   qry : TZTable;
begin
  qry := TZTable.Create(Self);
  qry.Connection := TZConnection(Connection);
  Result := TRESTDWZeosTable.Create(qry);
end;

function TRESTDWZeosDriver.getStoreProc: TRESTDWDrvStoreProc;
var 
   qry : TZStoredProc;
begin
  qry := TZStoredProc.Create(Self);
  qry.Connection := TZConnection(Connection);
  Result := TRESTDWZeosStoreProc.Create(qry);
end;

procedure TRESTDWZeosDriver.Connect;
begin
  if Assigned(Connection) and (not TZConnection(Connection).Connected) then
    TZConnection(Connection).Connected := True;
  inherited Connect;
end;

procedure TRESTDWZeosDriver.Disconect;
var
  I       : Integer;
  DataSet : TZAbstractRODataset;
begin
  for I := ComponentCount - 1 downto 0 do
  begin
    if Components[I] is TZAbstractRODataset then
    begin
      DataSet := TZAbstractRODataset(Components[I]);
      if DataSet.Active then
        DataSet.Close;
    end;
  end;
  if Assigned(Connection) and (TZConnection(Connection).Connected) then
    TZConnection(Connection).Connected := False;
  inherited Disconect;
end;

function TRESTDWZeosDriver.isConnected: boolean;
begin
  Result := inherited isConnected;
  if Assigned(Connection) then
    Result := TZConnection(Connection).Connected;
end;

function TRESTDWZeosDriver.connInTransaction: boolean;
begin
  Result := inherited connInTransaction;
  if Assigned(Connection) and (not TZConnection(Connection).AutoCommit) then
    Result := TZConnection(Connection).InTransaction;
end;

procedure TRESTDWZeosDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) and (not TZConnection(Connection).AutoCommit) then
    TZConnection(Connection).StartTransaction;
end;

procedure TRESTDWZeosDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) and (not TZConnection(Connection).AutoCommit) then
    TZConnection(Connection).Rollback;
end;

function TRESTDWZeosDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TZConnection);
end;

procedure TRESTDWZeosDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) and (not TZConnection(Connection).AutoCommit) then
    TZConnection(Connection).Commit;
end;

class procedure TRESTDWZeosDriver.CreateConnection(
  const AConnectionDefs: TConnectionDefs; var AConnection: TComponent);
var 
  LConn : TZConnection;
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  
  if not (Assigned(AConnectionDefs) and Assigned(AConnection)) then
    Exit;

  LConn := TZConnection(AConnection);

  case AConnectionDefs.DriverType of
    dbtUndefined, dbtAccess, dbtDbase, dbtParadox: LConn.Protocol := '';
    dbtFirebird:   LConn.Protocol := 'firebird';
    dbtInterbase:  LConn.Protocol := 'interbase';
    dbtMySQL:      LConn.Protocol := 'mysql';
    dbtSQLLite:    LConn.Protocol := 'sqlite';
    dbtOracle:     LConn.Protocol := 'oracle';
    dbtMsSQL:      LConn.Protocol := 'mssql';
    dbtODBC:       LConn.Protocol := 'odbc_a';
    dbtPostgreSQL: LConn.Protocol := 'postgresql';
    dbtAdo:        LConn.Protocol := 'ado';
  end;

  LConn.HostName := AConnectionDefs.HostName;
  LConn.Database := AConnectionDefs.DatabaseName;
  LConn.User     := AConnectionDefs.Username;
  LConn.Password := AConnectionDefs.Password;
  LConn.Port     := AConnectionDefs.DBPort;

  // AJUSTES ZEOS 8 + FIREBIRD 3.0+ (IDENTITY E DEFAULTS)
  LConn.Properties.Add('AutoParamRefreshes=True');
  LConn.Properties.Add('GetIdentityAfterInsert=True');
  LConn.Properties.Add('SupportIdentityColumns=True');
  LConn.Properties.Add('AutoRefresh=True');
  LConn.Properties.Add('RefreshAfterPost=True');
   
end;

{ TRESTDWZeosQuery }

procedure TRESTDWZeosQuery.createSequencedField(seqname, field: string);
var 
   LQuery : TZQuery;
   LSequence : TZSequence;
   varField : TField;
begin
  if Assigned(Self.Owner) and (Self.Owner is TZQuery) then
  begin
    LQuery := TZQuery(Self.Owner);
    varField := LQuery.FindField(field);
    
    if Assigned(varField) then 
    begin
      varField.Required          := False;      
      {$IFDEF FPC}
      // Lazarus não possui AutoGenerateValue
      if varField.DataType in [ftInteger, ftLargeint] then
        varField.ReadOnly := False;
      {$ELSE}
      varField.AutoGenerateValue := arAutoInc;
      {$ENDIF}

      if LQuery.Sequence = nil then
      begin
        LSequence := TZSequence.Create(LQuery);
        LSequence.Connection   := LQuery.Connection;
        LSequence.SequenceName := ''; 
        LQuery.Sequence      := LSequence;
        LQuery.SequenceField := field;
      end;
    end;
  end;
end;

procedure TRESTDWZeosQuery.ExecSQL;
var
  qry    : TZAbstractRODataset;
  I      : Integer;
  LParam : TZParam;
  LField : TField;
begin
  if Assigned(Self.Owner) and (Self.Owner is TZAbstractRODataset) then 
  begin
    qry := TZAbstractRODataset(Self.Owner);

    if qry is TZQuery then
    begin
      for I := 0 to TZQuery(qry).Params.Count - 1 do
      begin
        LParam := TZQuery(qry).Params[I];
        if (LParam.DataType in [ftInteger, ftLargeint, ftAutoInc]) and (LParam.Value = 0) then
        begin
          LField := TZQuery(qry).FindField(LParam.Name);
          {$IFDEF FPC}
           if (LField.DataType in [ftAutoInc, ftInteger, ftLargeint]) and
              (pfInKey in LField.ProviderFlags) then
               LParam.Clear;
          {$ELSE}
           if (LField.AutoGenerateValue = arAutoInc) and
              (pfInKey in LField.ProviderFlags) then
              LParam.Clear;
          {$ENDIF}
          begin
            LParam.Clear; 
          end;
        end;
      end;
    end;

    qry.ExecSQL;
  end;
  
end;

procedure TRESTDWZeosQuery.FetchAll;
begin
  if Assigned(Self.Owner) and (Self.Owner is TZTable) then
    TZTable(Self.Owner).FetchAll;
end;

procedure TRESTDWZeosQuery.LoadFromStreamParam(
  IParam: Integer;
  Stream: TStream;
  BlobType: TBlobType);
var
  qry: TZAbstractRODataset;

{$IFDEF ZEOS80UP}
  cp: Word;
  LParams: TZParams;
{$ENDIF}

begin
  if not Assigned(Self.Owner) then
    Exit;

  qry := TZAbstractRODataset(Self.Owner);

{$IFDEF ZEOS80UP}

  LParams := nil;

  if qry is TZQuery then
    LParams := TZQuery(qry).Params
  else if qry is TZReadOnlyQuery then
    LParams := TZReadOnlyQuery(qry).Params;

  if Assigned(LParams) then
  begin
  {$IFNDEF FPC}
    // Delphi + Zeos 8
    if BlobType in
      [ftWideString{$IFDEF WITH_WIDEMEMO}, ftFixedWideChar, ftWideMemo{$ENDIF}] then
      LParams[IParam].LoadTextFromStream(Stream, zCP_UTF16)
    else if BlobType in
      [ftBlob, ftGraphic, ftTypedBinary, ftOraBlob] then
      LParams[IParam].LoadBinaryFromStream(Stream)
    else if BlobType in
      [ftMemo, ftParadoxOle, ftDBaseOle, ftOraClob] then
    begin
      cp := qry.Connection.RawCharacterTransliterateOptions
               .GetRawTransliterateCodePage(ttParam);
      LParams[IParam].LoadTextFromStream(Stream, cp);
    end;
  {$ELSE}
    // Lazarus + Zeos 8
    LParams[IParam].LoadFromStream(Stream, BlobType);
  {$ENDIF}
  end;
  {$ELSE}
  if qry is TZQuery then
    TZQuery(qry).Params[IParam].LoadFromStream(Stream, BlobType)
  else if qry is TZReadOnlyQuery then
    TZReadOnlyQuery(qry).Params[IParam].LoadFromStream(Stream, BlobType);
  {$ENDIF}

end;

procedure TRESTDWZeosQuery.Prepare;
var 
   qry        : TZAbstractRODataset;
   I          : integer;
   LParam     : TZParam;
   LParamName : string;
begin
  inherited Prepare;
  if Assigned(Self.Owner) and (Self.Owner is TZAbstractRODataset) then 
  begin
    qry := TZAbstractRODataset(Self.Owner);
    
    if qry is TZQuery then
    begin
      for I := 0 to TZQuery(qry).Params.Count - 1 do
      begin
        LParam := TZQuery(qry).Params[I];
        if (LParam.DataType in [ftInteger, ftLargeint, ftAutoInc]) and (LParam.Value = 0) then
        begin
          LParamName := LowerCase(LParam.Name);
          if (LParamName = 'id') or (LParamName.StartsWith('cod')) or (LParamName.EndsWith('id')) then
            LParam.Clear;
        end;
      end;
    end;
    
    qry.Prepare;
  end;
end;

destructor TRESTDWZeosQuery.Destroy;
begin
  if Assigned(FSequence) then
    FreeAndNil(FSequence);
  inherited Destroy;
end;

function TRESTDWZeosQuery.RowsAffected: Int64;
begin
  Result := 0;
  if Assigned(Self.Owner) and (Self.Owner is TZAbstractRODataset) then
    Result := TZAbstractRODataset(Self.Owner).RowsAffected;
end;

// REFATORAÇÃO: Otimização drástica e unificação no acesso aos parâmetros do Zeos
function TRESTDWZeosQuery.ParamCount: Integer;
var
 qry : TZAbstractRODataset;

begin
 Result:=0;
 If not Assigned(Self.Owner) Then
  Exit;
 qry:=TZAbstractRODataset(Self.Owner);
 If qry is TZQuery Then
  Result:=TZQuery(qry).Params.Count
 Else If qry is TZReadOnlyQuery Then
  Result:=TZReadOnlyQuery(qry).Params.Count;
 If (Result=0) and (Pos(':',SQL.Text)>0) Then
  Begin
   Prepare;
   If qry is TZQuery Then
    Result:=TZQuery(qry).Params.Count
   Else If qry is TZReadOnlyQuery Then
    Result:=TZReadOnlyQuery(qry).Params.Count;
  End;
end;


function TRESTDWZeosQuery.getParamDataType(IParam: integer): TFieldType;
var 
   qry        : TZAbstractRODataset;
begin
  Result := ftUnknown;
  if not Assigned(Self.Owner) then Exit;

  qry := TZAbstractRODataset(Self.Owner);
  if qry is TZQuery then Result := TZQuery(qry).Params[IParam].DataType
  else if qry is TZReadOnlyQuery then Result := TZReadOnlyQuery(qry).Params[IParam].DataType;
end;

function TRESTDWZeosQuery.getParamName(IParam: integer): string;
var 
   qry        : TZAbstractRODataset;
begin
  Result := '';
  if not Assigned(Self.Owner) then Exit;

  qry := TZAbstractRODataset(Self.Owner);
  if qry is TZQuery then Result := TZQuery(qry).Params[IParam].Name
  else if qry is TZReadOnlyQuery then Result := TZReadOnlyQuery(qry).Params[IParam].Name;
end;

function TRESTDWZeosQuery.getParamSize(IParam: integer): integer;
var 
   qry        : TZAbstractRODataset;
begin
  Result := 0;
  if not Assigned(Self.Owner) then Exit;

  qry := TZAbstractRODataset(Self.Owner);
  if qry is TZQuery then Result := TZQuery(qry).Params[IParam].Size
  else if qry is TZReadOnlyQuery then Result := TZReadOnlyQuery(qry).Params[IParam].Size;
end;

function TRESTDWZeosQuery.getParamValue(IParam: integer): variant;
var 
   qry        : TZAbstractRODataset;
begin
  Result := Null;
  if not Assigned(Self.Owner) then Exit;

  qry := TZAbstractRODataset(Self.Owner);
  if qry is TZQuery then Result := TZQuery(qry).Params[IParam].Value
  else if qry is TZReadOnlyQuery then Result := TZReadOnlyQuery(qry).Params[IParam].Value;
end;

procedure TRESTDWZeosQuery.setParamDataType(IParam: integer; AValue: TFieldType);
var 
   qry        : TZAbstractRODataset;
begin
  if not Assigned(Self.Owner) then Exit;

  qry := TZAbstractRODataset(Self.Owner);
  if qry is TZQuery then TZQuery(qry).Params[IParam].DataType := AValue
  else if qry is TZReadOnlyQuery then TZReadOnlyQuery(qry).Params[IParam].DataType := AValue;
end;

procedure TRESTDWZeosQuery.setParamValue(IParam: integer; AValue: variant);
var
  qry : TZAbstractRODataset;
begin
  if not Assigned(Self.Owner) then Exit;
    qry := TZAbstractRODataset(Self.Owner);
  if qry is TZQuery then
    TZQuery(qry).Params[IParam].Value := AValue
  else if qry is TZReadOnlyQuery then
    TZReadOnlyQuery(qry).Params[IParam].Value := AValue;
end;

procedure TRESTDWZeosQuery.SaveToStreamCompatibleMode(stream: TStream);
Begin
  If Assigned(Self.Owner) And (Self.Owner Is TDataSet) Then
   SaveZeosDatasetToDWMEM(TDataSet(Self.Owner), stream);
End;

procedure TRESTDWZeosQuery.SaveToStream(stream: TStream);
var 
   qry      : TZQuery;
   memtable : TZMemTable;
begin
  if not (Assigned(Self.Owner) and Assigned(stream)) then Exit;

  qry := TZQuery(Self.Owner);
  memtable := TZMemTable.Create(nil);
  try
    memtable.AssignDataFrom(qry);
    memtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(memtable);
  end;
end;

{ TRESTDWZeosTable }

procedure TRESTDWZeosTable.FetchAll;
begin
  if Assigned(Self.Owner) and (Self.Owner is TZTable) then
    TZTable(Self.Owner).FetchAll;
end;

procedure TRESTDWZeosTable.LoadFromStreamParam(IParam: integer; stream: TStream; blobtype: TBlobType);
var
  qry     : TZAbstractRODataset;
  LParams : TZParams;
  cp      : word;
begin
  if not Assigned(Self.Owner) then Exit;
  
  qry := TZAbstractRODataset(Self.Owner);

  {$IFDEF ZEOS80UP}
    // Deixando a variável estritamente dentro da diretiva
    LParams := nil; 
    
    if qry is TZQuery then 
      LParams := TZQuery(qry).Params
    else if qry is TZReadOnlyQuery then 
      LParams := TZReadOnlyQuery(qry).Params;

    if Assigned(LParams) then 
    begin
      if BlobType in [ftWideString{$IFDEF WITH_WIDEMEMO}, ftFixedWideChar, ftWideMemo{$ENDIF}] then
        LParams[IParam].LoadTextFromStream(Stream, zCP_UTF16)
      else if BlobType in [ftBlob, ftGraphic, ftTypedBinary, ftOraBlob] then
        LParams[IParam].LoadBinaryFromStream(Stream)
      else if BlobType in [ftMemo, ftParadoxOle, ftDBaseOle, ftOraClob] then 
      begin
        cp := qry.Connection.RawCharacterTransliterateOptions.GetRawTransliterateCodePage(ttParam);
        LParams[IParam].LoadTextFromStream(Stream, cp);
      end;
    end;
  {$ELSE}
    if qry is TZQuery then
      TZQuery(qry).Params[IParam].LoadFromStream(stream, blobtype)
    else if qry is TZReadOnlyQuery then
      TZReadOnlyQuery(qry).Params[IParam].LoadFromStream(stream, blobtype);
  {$ENDIF}
end;

procedure TRESTDWZeosTable.SaveToStreamCompatibleMode(stream: TStream);
Begin
  If Assigned(Self.Owner) And (Self.Owner Is TDataSet) Then
   SaveZeosDatasetToDWMEM(TDataSet(Self.Owner), stream);
End;

procedure TRESTDWZeosTable.SaveToStream(stream: TStream);
var
  qry      : TZAbstractRODataset;
  memtable : TZMemTable;
begin
  if not (Assigned(Self.Owner) and Assigned(stream)) then 
    Exit;

  // REFATORAÇÃO: Instanciação com escopo inline seguro
  qry := TZTable.Create(Self.Owner);
  memtable := TZMemTable.Create(nil);
  try
    memtable.Assign(qry);
    memtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    // CORREÇÃO: qry adicionado ao bloco de liberação para eliminar o Memory Leak
    FreeAndNil(qry);
    FreeAndNil(memtable);
  end;
end;

Initialization
 RegisterClass(TRESTDWZeosDriver);
 RegisterRESTDWDriverClass(TRESTDWZeosDriver);

Finalization
 UnregisterRESTDWDriverClass(TRESTDWZeosDriver);
 UnRegisterClass(TRESTDWZeosDriver);

end.