unit uRESTDWBasicDbTypes;

{$I ..\..\Source\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFNDEF RESTDWLAZARUS}
 {$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
 {$ENDIF}
{$ENDIF}

Interface

Uses
  {$IFNDEF FPC}
   {$IF CompilerVersion < 21}
    DbTables,
   {$IFEND}
  {$ENDIF}
 SysUtils,  Classes, Db, FMTBcd,
 uRESTDWAbout, uRESTDWProtoTypes, uRESTDWConsts, uRESTDWTools;

 Type
  TRESTDWMemTableAE     = Class
 End;
  TFieldAttrs           = Array of Byte;
  TMemBlobData          = TRESTDWBytes;
  TMemBlobArray         = Array Of TMemBlobData;
  PMemBlobArray         = ^TMemBlobArray;

 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
    PRESTDWMTMemBuffer    = PByte;
    TRESTDWMTBookmark     = TBookmark;
    TRESTDWMTValueBuffer  = TValueBuffer;
    TRESTDWMTRecordBuffer = TRecordBuffer;
  {$ELSE}
   {$IFDEF UNICODE}
    PRESTDWMTMemBuffer    = PByte;
   {$ELSE}
     PRESTDWMTMemBuffer   = PAnsiChar;
   {$ENDIF UNICODE}
   TRESTDWMTBookmark      = Pointer;
   TRESTDWMTValueBuffer   = Pointer;
   TRESTDWMTRecordBuffer  = Pointer;
  {$IFEND}
 {$ELSE}
  TValueBuffer            = Array of Byte;
  PRESTDWMTMemBuffer      = PByte;
  TRESTDWMTBookmark       = Pointer;
  TRESTDWMTValueBuffer    = Pointer;
  TRESTDWMTRecordBuffer   = TRecordBuffer;
 {$ENDIF}
 PMemBlobData          = ^TRESTDWBytes;
 Type
  PRESTDWMTMemoryRecord = ^TRESTDWMTMemoryRecord;
  TRESTDWMTMemoryRecord = Class(TPersistent)
 Private
  FMemoryData : TRESTDWMemTableAE;
  FIndex,
  FID         : Integer;
  FData       : Pointer;
  FIsNull     : Boolean;
  Function  GetIndex : Integer;
  Procedure SetMemoryData(Value        : TRESTDWMemTableAE;
                          UpdateParent : Boolean);
 Protected
  Procedure SetIndex     (Value        : Integer);         Virtual;
 Public
  FBlobs      : TMemBlobArray;
  Constructor Create     (MemoryData   : TRESTDWMemTableAE); Virtual;
  Constructor CreateEx   (MemoryData   : TRESTDWMemTableAE;
                          UpdateParent : Boolean);         Virtual;
  Destructor  Destroy;Override;
  Property    MemoryData : TRESTDWMemTableAE Read FMemoryData;
  Property    ID         : Integer         Read FID         Write FID;
  Property    Index      : Integer         Read GetIndex    Write SetIndex;
  Property    Data       : Pointer         Read FData       Write FData;
  Property    Blobs      : TMemBlobArray   Read FBlobs      Write FBlobs;
  Property    IsNull     : Boolean         Read FIsNull     Write FIsNull;
 End;
 Type
  IRESTDWMemTable = Interface
   Function GetRecordCount               : Integer;
   Function GetMemoryRecord  (Index      : Integer)      : TRESTDWMTMemoryRecord;
   Function GetOffSets       (aField     : TField)       : Word;Overload;
   Function GetOffSets       (Index      : Integer)      : Word;Overload;
   Function GetOffSetsBlobs              : Word;
   Function DataTypeSuported(datatype    : TFieldType)   : Boolean; // new
   Function DataTypeIsBlobTypes(datatype : TFieldType)   : Boolean; // new
   Function GetBlobRec         (Field    : TField;
                                Rec      : TRESTDWMTMemoryRecord) : TMemBlobData;
   Function CreateBlobStream   (Field    : TField;
                                Mode     : TBlobStreamMode)       : TStream;
   Function GetCalcFieldLen    (FieldType: TFieldType;
                                Size     : Word)                  : Word;
   Procedure InternalAddRecord (Buffer   : {$IFDEF FPC}Pointer{$ELSE}
                                           {$IFDEF RESTDWANDROID}TRecBuf{$ELSE}
                                           {$IF CompilerVersion >22}Pointer{$ELSE}TRecordBuffer{$IFEND}{$ENDIF}{$ENDIF};
                                aAppend  : Boolean);
   Procedure InitRecord        (Buffer   : {$IFDEF NEXTGEN}TRecBuf{$ELSE}TRecordBuffer{$ENDIF});
   Function  AllocRecordBuffer           : TRecordBuffer;
   Procedure SetMemoryRecordData(Buffer  : PRESTDWMTMemBuffer;
                                 Pos     : Integer);
   Procedure AfterLoad;
   Function  GetDataset                  : TDataset;
   Function  GetBlob           (RecNo, Index    : Integer) : PMemBlobData;
   Procedure Loaded;
   {$IFDEF FPC}
   Function  GetDatabaseCharSet          : TDatabaseCharSet;
   {$ENDIF}
 End;
 Type
  TConnectionDefs = Class(TPersistent)
  Private
   votherDetails,
   vCharset,
   vDatabaseName,
   vHostName,
   vUsername,
   vPassword,
   vProtocol,
   vDriverID,
   vDataSource       : String;
   vdbPort         : Integer;
   vDWDatabaseType : TRESTDWDatabaseType;
  Private
   Function GetDatabaseType(Value : String)          : TRESTDWDatabaseType;Overload;
   Function GetDatabaseType(Value : TRESTDWDatabaseType) : String;         Overload;
  Public
   Constructor Create; //Cria o Componente
   Destructor  Destroy;Override;//Destroy a Classe
   Procedure   Assign(Source : TPersistent); Override;
   Function    ToJSON : String;
   Procedure   LoadFromJSON(Value : String);
  Published
   Property DriverType   : TRESTDWDatabaseType Read vDWDatabaseType Write vDWDatabaseType;
   Property Charset      : String          Read vCharset        Write vCharset;
   Property DriverID     : String          Read vDriverID       Write vDriverID;
   Property DatabaseName : String          Read vDatabaseName   Write vDatabaseName;
   Property HostName     : String          Read vHostName       Write vHostName;
   Property Username     : String          Read vUsername       Write vUsername;
   Property Password     : String          Read vPassword       Write vPassword;
   Property Protocol     : String          Read vProtocol       Write vProtocol;
   Property DBPort       : Integer         Read vdbPort         Write vdbPort;
   Property DataSource   : String          Read vDataSource     Write vDataSource;
   Property OtherDetails : String          Read votherDetails   Write votherDetails;
  End;
 Type
  TRESTDWStorageBase = class(TRESTDWComponent)
  Private
   {$IFDEF FPC}
    FDatabaseCharSet: TDatabaseCharSet;
   {$ENDIF}
   FEncodeStrs: Boolean;
  Protected
   Procedure SaveDatasetToStream  (Dataset    : TDataset;
                                   Var stream : TStream); Virtual;
   Procedure LoadDatasetFromStream(Dataset    : TDataset;
                                   stream     : TStream); Virtual;
   Procedure SaveDWMemToStream    (Dataset    : TDataset;
                                   Var stream : TStream); Virtual;
   Procedure LoadDWMemFromStream  (Dataset    : TDataset;
                                   stream     : TStream); Virtual;
  Public
   Constructor Create        (AOwner     : TComponent); Override;
   Procedure   SaveToStream  (Dataset    : TDataset;
                              Var Stream : TStream);
   Procedure   LoadFromStream(Dataset    : TDataset;
                              Stream     : TStream);
   Procedure   SaveToFile    (Dataset    : TDataset;
                              FileName   : String);
   Procedure   LoadFromFile  (Dataset    : TDataset;
                              FileName   : String);
  Public
   Property  EncodeStrs      : Boolean          Read FEncodeStrs      Write FEncodeStrs;
  Published
   {$IFDEF FPC}
    Property DatabaseCharSet : TDatabaseCharSet Read FDatabaseCharSet Write FDatabaseCharSet;
   {$ENDIF}
  End;



implementation

Uses uRESTDWMemoryDataset, uRESTDWDataJSON, uRESTDWJSONInterface;

constructor TRESTDWStorageBase.Create(AOwner: TComponent);
Begin
  inherited Create(AOwner);
  FEncodeStrs := True;
End;

Procedure TRESTDWStorageBase.LoadDatasetFromStream(Dataset: TDataset; stream: TStream);
Begin

End;

Procedure TRESTDWStorageBase.LoadDWMemFromStream(Dataset : TDataset;
                                                 stream  : TStream);
Begin

End;

Procedure TRESTDWStorageBase.LoadFromFile(Dataset: TDataset; FileName: String);
Var
 vFileStream : TFileStream;
Begin
 If not FileExists(FileName) then
  Exit;
 vFileStream := TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
 Try
  LoadFromStream(Dataset,TStream(vFileStream));
 Finally
  vFileStream := Nil;
  vFileStream.Free;
 End;
End;

Procedure TRESTDWStorageBase.LoadFromStream(Dataset: TDataset; stream: TStream);
Begin
 LoadDWMemFromStream(TRESTDWMemtable(Dataset), stream);
End;

Procedure TRESTDWStorageBase.SaveDatasetToStream(Dataset: TDataset; Var stream: TStream);
Begin

End;

Procedure TRESTDWStorageBase.SaveDWMemToStream(Dataset    : TDataset;
                                               Var Stream : TStream);
Begin

End;

Procedure TRESTDWStorageBase.SaveToFile(Dataset: TDataset; FileName: String);
Var
 vFileStream : TFileStream;
Begin
 Try
  vFileStream := TFileStream.Create(FileName,fmCreate);
  Try
   SaveToStream(Dataset,TStream(vFileStream));
  Except
  End;
 Finally
  vFileStream.Free;
 End;
End;

Procedure TRESTDWStorageBase.SaveToStream(Dataset: TDataset; Var stream: TStream);
Begin
 SaveDatasetToStream(Dataset, stream);
End;

Constructor TConnectionDefs.Create;
Begin
 Inherited;
 vdbPort          := -1;
 vDWDatabaseType  := dbtUndefined;
End;

Destructor  TConnectionDefs.Destroy;
Begin
 Inherited;
End;

Function TConnectionDefs.GetDatabaseType(Value : String)          : TRESTDWDatabaseType;
Begin
 Result := dbtUndefined;
 If LowerCase(Value) = LowerCase('dbtUndefined')       Then
  Result := dbtUndefined
 Else If LowerCase(Value) = LowerCase('dbtAccess')     Then
  Result := dbtAccess
 Else If LowerCase(Value) = LowerCase('dbtDbase')      Then
  Result := dbtDbase
 Else If LowerCase(Value) = LowerCase('dbtFirebird')   Then
  Result := dbtFirebird
 Else If LowerCase(Value) = LowerCase('dbtInterbase')  Then
  Result := dbtInterbase
 Else If LowerCase(Value) = LowerCase('dbtMySQL')      Then
  Result := dbtMySQL
 Else If LowerCase(Value) = LowerCase('dbtMsSQL')      Then
  Result := dbtMsSQL
 Else If LowerCase(Value) = LowerCase('dbtOracle')     Then
  Result := dbtOracle
 Else If LowerCase(Value) = LowerCase('dbtODBC')       Then
  Result := dbtODBC
 Else If LowerCase(Value) = LowerCase('dbtParadox')    Then
  Result := dbtParadox
 Else If LowerCase(Value) = LowerCase('dbtPostgreSQL') Then
  Result := dbtPostgreSQL
 Else If LowerCase(Value) = LowerCase('dbtSQLLite')    Then
  Result := dbtSQLLite
 Else If LowerCase(Value) = LowerCase('dbtAdo')    Then
  Result := dbtAdo;
End;

Function TConnectionDefs.GetDatabaseType(Value : TRESTDWDatabaseType) : String;
Begin
 Case Value Of
  dbtUndefined  : Result := LowerCase('dbtUndefined');
  dbtAccess     : Result := LowerCase('dbtAccess');
  dbtDbase      : Result := LowerCase('dbtDbase');
  dbtFirebird   : Result := LowerCase('dbtFirebird');
  dbtInterbase  : Result := LowerCase('dbtInterbase');
  dbtMySQL      : Result := LowerCase('dbtMySQL');
  dbtSQLLite    : Result := LowerCase('dbtSQLLite');
  dbtOracle     : Result := LowerCase('dbtOracle');
  dbtMsSQL      : Result := LowerCase('dbtMsSQL');
  dbtParadox    : Result := LowerCase('dbtParadox');
  dbtPostgreSQL : Result := LowerCase('dbtPostgreSQL');
  dbtODBC       : Result := LowerCase('dbtODBC');
  dbtAdo        : Result := LowerCase('dbtAdo');
 End;
End;

Procedure   TConnectionDefs.Assign(Source : TPersistent);
Var
 Src : TConnectionDefs;
Begin
 If Source is TConnectionDefs Then
  Begin
   Src           := TConnectionDefs(Source);
   votherDetails := Src.votherDetails;
   vDatabaseName := Src.vDatabaseName;
   vHostName     := Src.vHostName;
   vUsername     := Src.vUsername;
   vPassword     := Src.vPassword;
   vdbPort       := Src.vdbPort;
   vDriverID     := Src.vDriverID;
   vDataSource   := Src.vDataSource;
  End
 Else
  Inherited;
End;

Function    TConnectionDefs.ToJSON : String;
Begin
 Result := Format('{"databasename":"%s","hostname":"%s",'+
                  '"username":"%s","password":"%s","dbPort":%d,'+
                  '"otherDetails":"%s","charset":"%s","databasetype":"%s","protocol":"%s",'+
                  '"driverID":"%s","datasource":"%s"}',
                  [EncodeStrings(vDatabaseName{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vHostName    {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vUsername    {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vPassword    {$IFDEF FPC}, csUndefined{$ENDIF}),
                   vdbPort,
                   EncodeStrings(votherDetails{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vCharset     {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(GetDatabaseType(vDWDatabaseType){$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vProtocol  {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vDriverID  {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vDataSource{$IFDEF FPC}, csUndefined{$ENDIF})]);
End;

Procedure TConnectionDefs.LoadFromJSON(Value : String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
Begin
 bJsonValue := TRESTDWJSONInterfaceObject.Create(Value);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vDatabaseName   := DecodeStrings(bJsonValue.Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vHostName       := DecodeStrings(bJsonValue.Pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vUsername       := DecodeStrings(bJsonValue.Pairs[2].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vPassword       := DecodeStrings(bJsonValue.Pairs[3].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    If bJsonValue.Pairs[4].Value <> '' Then
     vdbPort        := StrToInt(bJsonValue.Pairs[4].Value)
    Else
     vdbPort        := -1;
    votherDetails   := DecodeStrings(bJsonValue.Pairs[5].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vCharset        := DecodeStrings(bJsonValue.Pairs[6].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDWDatabaseType := GetDatabaseType(DecodeStrings(bJsonValue.Pairs[7].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vProtocol       := DecodeStrings(bJsonValue.Pairs[8].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDriverID       := DecodeStrings(bJsonValue.Pairs[9].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDataSource     := DecodeStrings(bJsonValue.Pairs[10].Value{$IFDEF FPC}, csUndefined{$ENDIF});
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

// === { TRESTDWMTMemoryRecord } ====================================================
Constructor TRESTDWMTMemoryRecord.Create(MemoryData: TRESTDWMemTableAE);
Begin
 FIsNull := True;
 FIndex := -1;
 CreateEx(MemoryData, True);
End;

Constructor TRESTDWMTMemoryRecord.CreateEx(MemoryData: TRESTDWMemTableAE; UpdateParent: Boolean);
Begin
 Inherited Create;
 SetMemoryData(MemoryData, UpdateParent);
End;

Destructor TRESTDWMTMemoryRecord.Destroy;
Begin
 SetMemoryData(Nil, False);
// Finalize(FBlobs);
// SetLength(FBlobs, 0);
 Inherited Destroy;
End;

Function TRESTDWMTMemoryRecord.GetIndex: Integer;
Begin
// If FMemoryData <> Nil then
//  Result := FMemoryData.FRecords.IndexOf(Self)
// Else
 Result := FIndex;
End;

Procedure TRESTDWMTMemoryRecord.SetMemoryData(Value: TRESTDWMemTableAE; UpdateParent: Boolean);
var
 I, DataSize: Integer;
Begin
 If FMemoryData <> Value then
  Begin
   If FMemoryData <> nil then
    Begin
     If TRESTDWMemTable(FMemoryData).BlobFieldCount > 0 Then
      Begin
//       {$IFDEF FPC}
        SetLength(FBlobs, 0); //Finalize(FBlobs, FMemoryData.BlobFieldCount);
//       {$ELSE}
//        Finalize(FBlobs);
//       {$ENDIF}
      End;
     TRESTDWMemTable(FMemoryData).FRecords.Remove(Self);
     {$IFDEF FPC}
      ReallocMem(FData, 0);
     {$ELSE}
      FreeMem(FData, SizeOf(FData));
//      ReallocMem(FData, 0);
     {$ENDIF}
     FMemoryData := Nil;
    End;
   If Value <> Nil then
    Begin
     If UpdateParent then
      Begin
       TRESTDWMemTable(Value).FRecords.Add(Self);
       Inc(TRESTDWMemTable(Value).FLastID);
       FID := TRESTDWMemTable(Value).FLastID;
      End;
     FMemoryData := Value;
     If TRESTDWMemTable(Value).BlobFieldCount > 0 then
      Begin
       SetLength(FBlobs, 0);
       SetLength(FBlobs, TRESTDWMemTable(Value).BlobFieldCount);
      End;
     DataSize := 0;
     For I := 0 to TRESTDWMemTable(Value).Fields.Count - 1 do
      CalcDataSize(TRESTDWMemTable(Value).Fields[I], DataSize);
     ReallocMem(FData, DataSize);
    End;
  End;
End;

Procedure TRESTDWMTMemoryRecord.SetIndex(Value: Integer);
var
  CurIndex: Integer;
Begin
 CurIndex := GetIndex;
 If (CurIndex >= 0) and (CurIndex <> Value) then
  TRESTDWMemTable(FMemoryData).FRecords.Move(CurIndex, Value);
 FIndex := Value;
End;

end.
