unit uRESTDWMemoryDataset;

{$I ..\..\Includes\uRESTDW.inc}

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
  {$IFNDEF RESTDWLAZARUS} SqlTimSt, {$ENDIF}
  SysUtils, Classes, DB, FmtBCD, Variants, uRESTDWExprParser, uRESTDWAbout,
  uRESTDWConsts, uRESTDWPrototypes, uRESTDWTools;

const
  ftBlobTypes = [dwftBlob, dwftMemo, dwftBytes, dwftVarBytes, dwftFmtMemo,
                 dwftOraBlob, dwftOraClob, dwftWideMemo];

type
  ERESTDWDataSetError = class (Exception);

  TRESTDWRecInfo = record
    Bookmark: Longint;
    BookmarkFlag: TBookmarkFlag;
  end;
  PRESTDWRecInfo = ^TRESTDWRecInfo;

  {$IF Defined(RESTDWLAZARUS) or (Defined(DELPHIXEUP) and not Defined(NEXTGEN))}
    TRESTDWBuffer = TRecordBuffer;
  {$ELSEIF Defined(NEXTGEN)}
    TRESTDWBuffer = TRecBuf;
  {$ELSEIF not Defined(DELPHIXEUP)}
    TRESTDWBuffer = PChar;
  {$IFEND}
  PRESTDWBuffer = ^TRESTDWBuffer;

  TRESTDWMemTable = class;
  TRESTDWBlobStream = class;

  TRESTDWBlobField = record
    Buffer: PByte;  // pointer to memory allocated for Blob data
    Size: UInt64;   // size of Blob data
  end;
  PRESTDWBlobField = ^TRESTDWBlobField;

  { TRESTDWRecord }

  TRESTDWRecordStatus = (rsOriginal, rsUpdated, rsInserted, rsDeleted);

  PRESTDWRecord = ^TRESTDWRecord;
  TRESTDWRecord = class(TPersistent)
  private
    FDataset : TRESTDWMemTable;
    FBuffer : TRESTDWBuffer;
    FAccept : Byte;
    FID     : Integer;
    FStatus : TRESTDWRecordStatus;
    procedure setBuffer(const Value: TRESTDWBuffer);
  protected
    procedure clearRecInfo;
    procedure clearBlobsFields;
  public
    constructor Create(AOwner : TRESTDWMemTable);
    destructor Destroy; override;

    function CopyBuffer : TRESTDWBuffer; overload;
    procedure CopyBuffer(var Buffer : TRESTDWBuffer); overload;

    property Buffer : TRESTDWBuffer read FBuffer write setBuffer;
  published
    property Accept : Byte read FAccept write FAccept;
    property Status : TRESTDWRecordStatus read FStatus write FStatus;
    property ID : Integer read FID write FID;
  end;


  TRESTDWBlobStream = class(TStream)
  private
    FDataset : TRESTDWMemTable;
    FField : TBlobField;
    FMode: TBlobStreamMode;
    FBlobField : PRESTDWBlobField;
    FModified : boolean;
    FPosition : UInt64;
  protected
    procedure AllocBlobField(NewSize: UInt64);
    procedure FreeBlobField;
    procedure SetDataBlob;
  public
    constructor Create(AOwner : TRESTDWMemTable; DataField: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;

    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: int64; Origin: TSeekOrigin): int64; override;
  end;

  IRESTDWMemTable = Interface
    {d5ba50cb-c81b-4648-a55c-6eb2f5d2a69b}
    function GetDataset: TDataset;
    function GetRecordObj(idx : integer) : TRESTDWRecord;

    function GetFieldSize(idx : integer) : integer; overload;
    function GetFieldSize(name : string) : integer; overload;
    function GetFieldType(name : string) : TFieldType;

    function GetRecSize : integer;
    function GetRecordSize : word;
    procedure AddNewRecord(rec : TRESTDWRecord);
    procedure AddBlobList(blob : PRESTDWBlobField);
  end;

  TRESTDWStorageBase = class(TRESTDWComponent)
  private
    {$IFDEF RESTDWLAZARUS}
      FDatabaseCharSet: TDatabaseCharSet;
    {$ENDIF}
    FEncodeStrs: Boolean;
  public
    procedure SaveDatasetToStream(ADataset: TDataset; var AStream: TStream); virtual;
    procedure LoadDatasetFromStream(ADataset: TDataset; AStream: TStream); virtual;

    procedure SaveDWMemToStream(IDataset: IRESTDWMemTable; var AStream: TStream); virtual;
    procedure LoadDWMemFromStream(IDataset: IRESTDWMemTable; AStream: TStream); virtual;
  public
    constructor Create(AOwner: TComponent); override;

    procedure SaveToStream(ADataset: TDataset; var AStream: TStream);
    procedure LoadFromStream(ADataset: TDataset; AStream: TStream);

    procedure SaveToFile(ADataset: TDataset; AFileName: String);
    procedure LoadFromFile(ADataset: TDataset; AFileName: String);
  public
    {$IFDEF RESTDWLAZARUS}
      property DatabaseCharSet: TDatabaseCharSet read FDatabaseCharSet  write FDatabaseCharSet;
    {$ENDIF}
    property EncodeStrs: Boolean read FEncodeStrs write FEncodeStrs;
  end;

  TRESTDWCompareRecords = function(Item1, Item2: TRESTDWRecord): Integer of object;


  PRecordList = ^TRecordList;

  { TRecordList }

  TRecordList = Class(TList)
  private
    function GetRec(Index: Integer): TRESTDWRecord; overload;
    procedure PutRec(Index: Integer; Item: TRESTDWRecord); overload;
    procedure ClearAll;
  public
    destructor Destroy; override;
    procedure Delete(Index: Integer); overload;
    function Add(Item: TRESTDWRecord): Integer; overload;

    property Items[Index: Integer]: TRESTDWRecord read GetRec write PutRec; default;
  end;

  { TRESTDWMemTable }

  TRESTDWMemTable = class(TDataSet, IRESTDWMemTable)
  private
    FAbout : TRESTDWAboutInfo;
    FRecords : TRecordList;

    // status
    FIsTableOpen: Boolean;
    FBlockEvents : Boolean;

    // record data
    FRecordSize, // the size of the actual data
    FRecordBufferSize : integer; // data + housekeeping (TRecInfo)

    FCurrentRecord, // current record (0 to FRecordCount - 1)
    FBofCrack, // before the first record (crack)
    FEofCrack: Longint; // after the last record (crack)
    FRecordCount : Longint;
    FFieldOffsets : array of integer;
    FFieldSize : array of integer;
    FBlobs: TList;
    FFilterBuffer: TRESTDWBuffer;
    FControlsDisabled : boolean; // filtro
    FFilterParser : TExprParser;
    FIndexFieldNames : string;
    FFilterRecordCount : LongInt;
    FStorageDataType : TRESTDWStorageBase;
    FCaseInsensitiveSort: Boolean;
    FIndexList : TStringList;
    FLastID : integer;

    FStatusRecord : TRESTDWRecordStatus;
    FStatusRecordChanged : Boolean;

    procedure setIndexFieldNames(const Value: string);
  protected
    // create, close, and so on
    procedure InternalOpen; override;
    procedure InternalClose; override;
    function IsCursorOpen: Boolean; override;
    procedure CreateFields; override;
    procedure OpenCursor(InfoQuery: Boolean); override;

    // custom functions
    procedure InternalInitFieldDefs; override;
    function InternalRecordCount: Longint; virtual;
    procedure InternalPreOpen; virtual;
    procedure InternalAfterOpen; virtual;

    // memory management
    function AllocRecordBuffer: TRESTDWBuffer; override;
    procedure InternalInitRecord(Buffer: TRESTDWBuffer); override;
    procedure FreeRecordBuffer(var ABuffer: TRESTDWBuffer); override;
    function GetRecordSize: Word; override;
    function GetActiveBuffer(var Buffer: TRESTDWBuffer): Boolean;
    procedure ClearCalcFields(Buffer: TRecordBuffer); override;

    // movement and optional navigation (used by grids)
    function GetRecord(Buffer: TRESTDWBuffer; GetMode: TGetMode;
      DoCheck: Boolean): TGetResult; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    function GetRecNo: integer; override;
    function GetRecordCount: Integer; override;
    procedure SetRecNo(Value: Integer); override;

    // filter
    function FilterRecord(Buffer : TRESTDWBuffer): Boolean;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetFilterText(const Value: string); override;

    // events
    {$IFDEF RESTDWLAZARUS}
      procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
    {$ELSE}
      {$IFNDEF DELPHIXEUP}
        procedure DataEvent(Event: TDataEvent; Info: Longint); override;
      {$ELSE}
        procedure DataEvent(Event: TDataEvent; Info: NativeInt); override;
      {$ENDIF}
    {$ENDIF}

    // parser
    function ParserGetVariableValue(Sender: TObject; const VarName: string; var Value: Variant): Boolean; virtual;

    // bookmarks
    function BookmarkValid(ABookmark: TBookmark): Boolean; override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure InternalSetToRecord(Buffer: TRESTDWBuffer); override;

    procedure SetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer); override;
    procedure GetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer); override;
    {$IFDEF DELPHIXEUP}
      procedure GetBookmarkData(Buffer: TRESTDWBuffer; Data: TBookmark); override;
    {$ENDIF}
    procedure SetBookmarkFlag(Buffer: TRESTDWBuffer; Value: TBookmarkFlag); override;
    function GetBookmarkFlag(Buffer: TRESTDWBuffer): TBookmarkFlag; override;

    // editing (dummy vesions)
    procedure InternalDelete; override;

    {$IFDEF DELPHIXEUP}
      procedure InternalAddRecord(Buffer: TRecBuf; Append: Boolean); override;
      procedure InternalAddRecord(Buffer: TRESTDWBuffer; Append: Boolean); override;
    {$ENDIF}
    procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;

    procedure InternalPost; override;
    procedure DoAfterPost; override;

    // fields
    {$IFDEF DELPHIXEUP}
      procedure SetFieldData(Field: TField; Buffer: TValueBuffer); overload; override;
    {$ENDIF}
    procedure SetFieldData(Field: TField; Buffer: Pointer); overload; override;

    // other
    procedure InternalHandleException; override;
    procedure UpdateRecordsAccept(acc : Byte);
    function GetFilterRecordCount : integer;
    procedure RecalcFilters;

    // sort
    procedure Sort;
    procedure QuickSort(L, R: Integer; Compare: TRESTDWCompareRecords);
    function CompareRecords(Item1, Item2: TRESTDWRecord): Integer; virtual;
    procedure CreateIndexList(const FieldNames: string);
    procedure FreeIndexList;
    function FindFieldValue(Item: TRESTDWRecord; Field: TField): Variant;

    // IRESTDWMenTable - interface
    function GetDataset: TDataset;
    function GetRecordObj(idx : integer) : TRESTDWRecord;
    procedure AddNewRecord(rec : TRESTDWRecord);
    procedure AddBlobList(blob : PRESTDWBlobField);
    function GetFieldSize(idx : integer) : integer; overload;
    function GetFieldSize(fdname : string) : integer; overload;
    function GetFieldType(fdname : string) : TFieldType;
  protected
    function GetRecSize : integer;
    function GetFieldOffsets(idx : integer) : integer;
    function GetActiveRecord : TRESTDWBuffer;

    function calcFieldSize(ft : TFieldType; fs : integer) : integer;
    procedure clearRecords;
    procedure clearBlobs;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    // locate
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; override;

    {$IFDEF DELPHIXEUP}
      function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    {$ENDIF}
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;

    // status - Delta
    procedure SetRecordStatus(rec_status : TRESTDWRecordStatus);
    function GetRecordStatus : TRESTDWRecordStatus;

    // blobs
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;

    // Streams
    procedure LoadFromStream(AStream : TStream); virtual;
    procedure LoadFromFile(AFileName : string); virtual;
    procedure SaveToStream(AStream : TStream); virtual;
    procedure SaveToFile(AFileName : string); virtual;

    procedure EmptyTable; virtual;
    procedure RefreshStates; virtual;

    procedure SortOnFields(const FieldNames: string = ''; CaseInsensitive: Boolean = True);

    property StorageDataType: TRESTDWStorageBase read FStorageDataType write FStorageDataType;
  published
    // redeclared data set properties
    property Active;
    property AutoCalcFields;
    property Filter;
    property Filtered;
    property FilterOptions;
    property FieldDefs;

    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;

    property AboutInfo : TRESTDWAboutInfo read FAbout write FAbout stored False;
    property IndexFieldNames : string read FIndexFieldNames write setIndexFieldNames;
  end;

implementation

uses
  {$IFDEF RESTDWLAZARUS}
    bufstream,
  {$ENDIF}
  uRESTDWStorageBin;

{ TRecordList }

function TRecordList.GetRec(Index : Integer) : TRESTDWRecord;
begin
  Result := nil;
  if (Index < Self.Count) and (Index > -1) then
    Result := TRESTDWRecord(TList(Self).Items[Index]^);
end;

procedure TRecordList.PutRec(Index : Integer; Item : TRESTDWRecord);
begin
  if (Index < Self.Count) and (Index > -1) then
    TRESTDWRecord(TList(Self).Items[Index]^) := Item;
end;

procedure TRecordList.ClearAll;
Var
  i : integer;
Begin
  i := Count - 1;
  while i > -1 Do Begin
    Delete(I);
    Dec(I);
  end;
  inherited Clear;
end;

destructor TRecordList.Destroy;
begin
  ClearAll;
  inherited Destroy;
end;

procedure TRecordList.Delete(Index : Integer);
begin
  if (Index > -1) And (Count > Index) then Begin
    try
      if Assigned(TList(Self).Items[Index]) then begin
        if Assigned(TRESTDWRecord(TList(Self).Items[Index]^)) then begin
          {$IF Defined(RESTDWLAZARUS) OR not Defined(DELPHI10_4UP)}
          FreeAndNil(TList(Self).Items[Index]^);
          {$ELSE}
          FreeAndNil(TRESTDWRecord(TList(Self).Items[Index]^));
          {$IFEND}
        end;
      end;
      {$IFDEF RESTDWLAZARUS}
        Dispose(PRESTDWRecord(TList(Self).Items[Index]));
      {$ELSE}
        Dispose(TList(Self).Items[Index]);
      {$ENDIF}
    except

    end;
    TList(Self).Delete(Index);
  end;
end;

function TRecordList.Add(Item : TRESTDWRecord) : Integer;
var
  vItem: PRESTDWRecord;
Begin
  New(vItem);
  vItem^ := Item;
  Result := inherited Add(vItem);
end;

procedure TRESTDWMemTable.InternalOpen;
begin
  InternalPreOpen; // custom method for subclasses

  FieldDefs.Updated := False;
  FieldDefs.Update;
  {$IFNDEF RESTDWLAZARUS}
  FieldDefList.Update;
  {$ENDIF}

  // if there are no persistent field objects,
  // create the fields dynamically
  {$IFNDEF HAS_AUTOMATIC_DB_FIELDS}
    if DefaultFields then
  {$ENDIF !HAS_AUTOMATIC_DB_FIELDS}
    CreateFields;

  // connect the TField objects with the actual fields
  BindFields(True);

  InternalAfterOpen; // custom method for subclasses

  // sets cracks and record position and size
  FBofCrack := -1;
  FEofCrack := InternalRecordCount;
  FCurrentRecord := FBofCrack;
  FRecordSize := FRecordSize + CalcFieldsSize;
  FRecordBufferSize := FRecordSize + SizeOf(Pointer);
  BookmarkSize := SizeOf(Integer);

  // everything OK: table is now open
  InternalFirst;
end;

procedure TRESTDWMemTable.InternalClose;
var
  vBlock : Boolean;
begin
  if not FIsTableOpen then
    Exit;

  ClearBuffers;
  vBlock := FBlockEvents;
  FBlockEvents := False;

  EmptyTable;

  // disconnet field objects
//  BindFields(False);
  // destroy field object (if not persistent)
  {$IFNDEF HAS_AUTOMATIC_DB_FIELDS}
    if DefaultFields then
  {$ENDIF !HAS_AUTOMATIC_DB_FIELDS}
    DestroyFields;

  // close the file
  FBlockEvents := vBlock; 
  FIsTableOpen := False;
end;

function TRESTDWMemTable.IsCursorOpen: Boolean;
begin
  Result := FIsTableOpen;
end;

procedure TRESTDWMemTable.LoadFromFile(AFileName: string);
var
  fStr : TFileStream;
begin
  if not FileExists(AFileName) then
    Exit;

  try
    fStr := TFileStream.Create(AFileName,fmOpenRead or fmShareDenyWrite);
    try
      fStr.Position := 0;
      LoadFromStream(TStream(fStr));
    finally
      fStr.Free;
    end;
  except
    on e : Exception do begin
      raise Exception.Create(e.Message);
    end;
  end;
end;

procedure TRESTDWMemTable.LoadFromStream(AStream: TStream);
var
  vStor : TRESTDWStorageBase;
  vFiltered : Boolean;
begin
  Close;
  vFiltered := Filtered;
  Filtered := False;

  FBlockEvents := True;

  if Assigned(FStorageDataType) then
    vStor := FStorageDataType
  else
    vStor := TRESTDWStorageBin.Create(nil);

  try
    vStor.LoadFromStream(Self,AStream);
  finally
    if not Assigned(FStorageDataType) then
      vStor.Free;
  end;

  if FIndexFieldNames <> '' then
    SortOnFields(FIndexFieldNames,FCaseInsensitiveSort);

  Filtered := vFiltered;
  RefreshStates;
end;

function TRESTDWMemTable.Locate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  vFieldCount : Integer;
  vFields : TList;
  vField : TField; // else BAD mem leak on 'Field.asString'
  SaveState: TDataSetState;
  I: Integer;
  vRec : TRESTDWRecord;
  vBuffer : PRESTDWBuffer;
  vBook : Integer;
  vBookmark : TBookMark;

  function CompareField(Field: TField; Value: Variant): Boolean; { BG }
  var
    S: string;
    vDWFieldType : Byte;
  begin
    vDWFieldType := FieldTypeToDWFieldType(Field.DataType);
    if vDWFieldType in [dwftString, dwftFixedChar, dwftWideString, dwftFixedWideChar] then begin
      if Value = Null then begin
        Result := Field.IsNull;
      end
      else begin
        S := Field.AsString;
        Result := AnsiSameStr(S, Value);
      end;
    end
    else begin
      Result := (Field.Value = Value);
    end;
  end;

  function CompareRecord: Boolean;
  var
    ii : Integer;
  begin
    if vFieldCount = 1 then begin
      vField := TField(Fields[0]);
      Result := CompareField(vField, KeyValues);
    end
    else begin
      Result := True;
      for ii := 0 to vFieldCount - 1 do begin
        vField := TField(vFields[ii]);
        Result := Result and CompareField(vField, KeyValues[ii]);
        if not Result then
          Break;
      end;
    end;
  end;
begin
  DoBeforeScroll;

  Result := False;
  CheckBrowseMode;
  if IsEmpty then begin
    Resync([]);
    Exit;
  end;
  vFields := TList.Create;
  try
    GetFieldList(vFields, KeyFields);
    vFieldCount := vFields.Count;
    Result := CompareRecord;
    if Result then begin
      Resync([]);
      Exit;
    end
    else begin
      SaveState := SetTempState(dsCalcFields);
      try
        try
          vBuffer := PRESTDWBuffer(TempBuffer);
          for i := FCurrentRecord to FRecords.Count - 1 Do Begin
            vRec := GetRecordObj(i);
            vRec.CopyBuffer(vBuffer^);
            CalculateFields(vBuffer^);
            Result := CompareRecord;
            if Result Then
              Break;
          end;

          if not Result then begin
            for i := 0 to FCurrentRecord - 1 Do Begin
              vRec := GetRecordObj(i);
              vRec.CopyBuffer(vBuffer^);
              CalculateFields(vBuffer^);
              Result := CompareRecord;
              if Result Then
                Break;
            end;
          end;
        finally
          if Result then begin
            {$IFDEF DELPHIXEUP}
               SetLength(vBookmark,BookmarkSize);
               Move(i,Pointer(@vBookmark[0])^,SizeOf(vBook));
            {$ELSE}
               SetLength(vBookmark,BookmarkSize);
               Move(i,Pointer(@vBookmark[0])^,SizeOf(vBook));
            {$ENDIF}
          end;
        end;
      finally
        RestoreState(SaveState);
        if Result and Self.BookmarkValid(vBookmark) then begin
          Self.Bookmark := vBookmark;
          Resync([]);
        end;
        SetLength(vBookmark,0);
      end;
    end;
  finally
    FreeAndNil(vFields);
  end;

  if Result then begin
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
  end;
end;

function TRESTDWMemTable.Lookup(const KeyFields: string;
  const KeyValues: Variant; const ResultFields: string): Variant;
var
  vFieldCount : Integer;
  vFields : TList;
  vField : TField;
  SaveState: TDataSetState;
  I: Integer;
  vMatched: Boolean;
  vRec : TRESTDWRecord;
  vBuffer : PRESTDWBuffer;

  function CompareField(Field: TField; Value: Variant): Boolean; { BG }
  var
    S: string;
    vDWFieldType : Byte;
  begin
    vDWFieldType := FieldTypeToDWFieldType(Field.DataType);
    if vDWFieldType in [dwftString, dwftFixedChar, dwftWideString, dwftFixedWideChar] then begin
      if Value = Null then begin
        Result := Field.IsNull;
      end
      else begin
        S := Field.AsString;
        Result := AnsiSameStr(S, Value);
      end;
    end
    else begin
      Result := (Field.Value = Value);
    end;
  end;

  function CompareRecord: Boolean;
  var
    ii : Integer;
  begin
    if vFieldCount = 1 then begin
      vField := TField(vFields[0]);
      Result := CompareField(vField, KeyValues);
    end
    else begin
      Result := True;
      for ii := 0 to vFieldCount - 1 do begin
        vField := TField(vFields[ii]);
        Result := Result and CompareField(vField, KeyValues[ii]);
        if not Result then
          Break;
      end;
    end;
  end;

Begin
  Result := null;
  CheckBrowseMode;
  If IsEmpty Then
    Exit;

  vFields := TList.Create;
  try
    GetFieldList(vFields, KeyFields);
    vFieldCount := vFields.Count;
    vMatched := CompareRecord;
    if vMatched then begin
      Result := ToBytes(FieldValues[ResultFields])
    end
    else begin
      SaveState := SetTempState(dsCalcFields);
      try
        try
          vBuffer := PRESTDWBuffer(TempBuffer);
          for i := 0 To FRecords.Count - 1 Do Begin
            vRec := GetRecordObj(i);
            vRec.CopyBuffer(vBuffer^);
            CalculateFields(vBuffer^);
            vMatched := CompareRecord;
            if vMatched Then
              Break;
          end;
        finally
          if vMatched Then
            Result := ToBytes(FieldValues[ResultFields]);
        end;
      finally
        RestoreState(SaveState);
      end;
    end;
  finally
    FreeAndNil(vFields);
  end;
end;

function TRESTDWMemTable.ParserGetVariableValue(Sender: TObject;
  const VarName: string; var Value: Variant): Boolean;
var
  Field: TField;
begin
  Field := FieldByName(Varname);
  if Assigned(Field) then begin
    Value := Field.Value;
    Result := True;
  end
  else begin
    Result := False;
  end;
end;

procedure TRESTDWMemTable.QuickSort(L, R: Integer; Compare: TRESTDWCompareRecords);
var
  I, J: Integer;
  P : TRESTDWRecord;
begin
  repeat
    I := L;
    J := R;
    P := GetRecordObj((L + R) shr 1);
    repeat
      while Compare(GetRecordObj(I), P) < 0 do
        Inc(I);
      while Compare(GetRecordObj(J), P) > 0 do
        Dec(J);
      if I <= J then begin
        if I < J then
          FRecords.Exchange(I, J);
        Inc(I);
        Dec(J);
      end;
    until I > J;

    if L < J then
      QuickSort(L, J, Compare);

    L := I;
  until I >= R;
end;

procedure TRESTDWMemTable.RecalcFilters;
var
  vBuffer : TRESTDWBuffer;
  vRec : TRESTDWRecord;
  vAccept : Boolean;
  i : integer;
begin
  i := 0;
  while i < FRecords.Count do begin
    vRec := GetRecordObj(i);
    vBuffer := vRec.CopyBuffer;
    vAccept := FilterRecord(vBuffer);
    if not vAccept then
      vRec.Accept := 2;
    FreeMem(vBuffer);
    i := i + 1;
  end;
end;

procedure TRESTDWMemTable.RefreshStates;
begin
  try
    SetState(dsInactive);
    FBlockEvents := False;
  finally
    SetState(dsBrowse);
  end;
end;

procedure TRESTDWMemTable.CreateFields;
var
  i : integer;
begin
  for i := 0 to FieldDefs.Count - 1 do begin
    with FieldDefs.Items[I] do begin
      {$IFDEF RESTDWLAZARUS}
        if DataType = ftTimeStamp then begin
          DataType := ftDateTime;
        end;
      {$ENDIF}
    end;
  end;

  if Fields.Count = 0 then
    inherited CreateFields;
end;

procedure TRESTDWMemTable.OpenCursor(InfoQuery : Boolean);
begin
  // initialize the field definitions
  // (another virtual abstract method of TDataSet)
  InternalInitFieldDefs;

  FIsTableOpen := True;
  inherited OpenCursor(InfoQuery);
end;

procedure TRESTDWMemTable.CreateIndexList(const FieldNames: string);
var
  vPos, vPosFinal : Integer;
  vField : TField;
  vFieldName : string;
  vOrder : string;
  bField : boolean;

  procedure addFieldList;
  var
    vDWFieldType : Byte;
  begin
    if vFieldName = '' then
      Exit;

    vOrder := LowerCase(vOrder);
    if vOrder = '' then
      vOrder := 'asc';

    if (not SameText(vOrder,'asc')) and
       (not SameText(vOrder,'desc')) then
      vOrder := 'asc';

    vField := FindField(vFieldName);
    if vField <> nil then begin
      vDWFieldType := FieldTypeToDWFieldType(vField.DataType);
      if vDWFieldType in ftBlobTypes then begin
        raise Exception.Create('Fields blobs not accept on sort');
        Exit;
      end;
      FIndexList.AddObject(vOrder,vField);
    end
    else begin
      raise Exception.Create('Fields '+vFieldName+' not found');
      Exit;
    end;

    vFieldName := '';
    vOrder := '';
    bField := True;
  end;
begin
  if FIndexList = nil then
    FIndexList := TStringList.Create
  else
    FIndexList.Clear;

  {$IFDEF DELPHIXE4UP}
    vPosFinal := High(FieldNames);
  {$ELSE}
    vPosFinal := Length(FieldNames);
  {$ENDIF}

  vFieldName := '';
  vOrder := '';
  bField := True;
  vPos := InitStrPos;
  while vPos <= vPosFinal do begin
    if FieldNames[vPos] in [';',','] then begin
      addFieldList;
    end
    else if FieldNames[vPos] = '|' then begin
      bField := False;
    end
    else begin
      if bField then
        vFieldName := vFieldName + FieldNames[vPos]
      else
        vOrder := vOrder + FieldNames[vPos];
    end;
    vPos := vPos + 1;
  end;
  addFieldList;
end;

procedure TRESTDWMemTable.InternalGotoBookmark(ABookmark: Pointer);
var
  ReqBookmark: Integer;
begin
  ReqBookmark := Integer(ABookmark^);
  if (ReqBookmark >= FBofCrack) and (ReqBookmark <= InternalRecordCount) then
    FCurrentRecord := ReqBookmark
  else
    raise ERESTDWDataSetError.Create ('Bookmark ' + IntToStr (ReqBookmark) + ' not found');
end;

procedure TRESTDWMemTable.InternalSetToRecord (Buffer: TRESTDWBuffer);
var
  ReqBookmark: Integer;
begin
  ReqBookmark := PRESTDWRecInfo(Buffer + FRecordSize)^.Bookmark;
  InternalGotoBookmark(@ReqBookmark);
end;

{$IFDEF DELPHIXEUP}
  procedure TRESTDWMemTable.GetBookmarkData(Buffer: TRESTDWBuffer; Data: TBookmark);
  var
    vBook : integer;
  begin
    vBook := PRESTDWRecInfo(Buffer + FRecordSize)^.Bookmark;
    Move(vBook,Pointer(@Data[0])^,SizeOf(vBook)); // XE
  end;
{$ENDIF}

function TRESTDWMemTable.GetBookmarkFlag(Buffer: TRESTDWBuffer): TBookmarkFlag;
begin
  Result := PRESTDWRecInfo(Buffer + FRecordSize)^.BookmarkFlag;
end;

function TRESTDWMemTable.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  SrcBuffer: TRESTDWBuffer;

  vNull : boolean;
  I : integer;
  J : integer;

  vDWDataType : Byte;
  vByte : Byte;

  vCurrency : Currency;
  vDouble : Double;
  vFmtBCD : tBCD;
  vTimeStamp : TTimeStamp;
  vDateTimeRec : TDateTimeRec;
  vString : AnsiString;
  {$IFNDEF RESTDWLAZARUS}
    vSQLTimeStamp : TSQLTimeStamp;
  {$ENDIF}
  {$IFDEF DELPHIXEUP}
    vTimeStampOffSet : TSQLTimeStampOffSet;
  {$ENDIF}
begin
  I := Field.FieldNo - 1;
  Result := GetActiveBuffer(SrcBuffer);

  if not Result then
    Exit;

  if I >= 0 then begin
    Inc(SrcBuffer,FFieldOffsets[I]);
    Move(SrcBuffer^,vNull,SizeOf(Boolean));
    Inc(SrcBuffer,SizeOf(Boolean));

    Result := vNull;
    if Result and Assigned(Buffer) then begin
      J := FFieldSize[I];

      vDWDataType := FieldTypeToDWFieldType(Field.DataType);

      if vDWDataType = dwftFMTBcd then begin
        Move(SrcBuffer^,vCurrency,J);
        vFmtBCD := DoubleToBCD(vCurrency);
        Move(vFmtBCD,Buffer^,J);
      end
      else if vDWDataType = dwftTimeStamp then begin
        Move(SrcBuffer^,vDouble,SizeOf(vDouble));
        {$IFDEF RESTDWLAZARUS}
          vTimeStamp := DateTimeToTimeStamp(vDouble);
          Move(vTimeStamp,Buffer^,SizeOf(vTimeStamp));
        {$ELSE}
          vSQLTimeStamp := DateTimeToSQLTimeStamp(vDouble);
          Move(vSQLTimeStamp,Buffer^,SizeOf(vSQLTimeStamp));
        {$ENDIF}
      end
      else if vDWDataType in [dwftDate, dwftTime, dwftDateTime] then begin
        Move(SrcBuffer^,vDouble,SizeOf(vDouble));
        vTimeStamp := DateTimeToTimeStamp(vDouble);
        case vDWDataType of
          dwftDate: vDateTimeRec.Date := vTimeStamp.Date;
          dwftTime: vDateTimeRec.Time := vTimeStamp.Time;
        else
          vDateTimeRec.DateTime := TimeStampToMSecs(vTimeStamp);
        end;
        Move(vDateTimeRec,Buffer^,SizeOf(vDateTimeRec));
      end
      else if vDWDataType = dwftTimeStampOffset then begin
        {$IFDEF DELPHIXEUP}
          Move(SrcBuffer^,vDouble,SizeOf(vDouble));
          Inc(SrcBuffer,SizeOf(vDouble));

          vTimeStampOffSet := DateTimeToSQLTimeStampOffset(vDouble);

          Move(SrcBuffer^,vByte,SizeOf(vByte));
          Inc(SrcBuffer,SizeOf(vByte));

          vTimeStampOffSet.TimeZoneHour := vByte - 12;

          Move(SrcBuffer^,vByte,SizeOf(vByte));
          Inc(SrcBuffer,SizeOf(vByte));

          vTimeStampOffSet.TimeZoneMinute := vByte;
          Dec(SrcBuffer,J);

          Move(vTimeStampOffSet,Buffer^,SizeOf(vTimeStampOffSet));
        {$ENDIF}
      end
      else if vDWDataType = dwftWideString then begin
        SetLength(vString,J);
        Move(SrcBuffer^,vString[InitStrPos],J);
        Move(vString[InitStrPos],Buffer^,J);
      end
      else begin
        Move(SrcBuffer^,Buffer^,J);
      end;
//      Dec(SrcBuffer,FFieldOffsets[I]+SizeOf(Boolean));
    end;
  end
  // Calculated, Lookup
  else begin
    I := Field.Index;
    Inc(SrcBuffer,FFieldOffsets[I]);
    Move(SrcBuffer^,vNull,SizeOf(Boolean));
    Inc(SrcBuffer);
    Result := vNull;
    if Result and Assigned(Buffer) then begin
      J := FFieldSize[I];
      Move(SrcBuffer^,Buffer^,J);
    end;
//    Dec(SrcBuffer,FFieldOffsets[I]+SizeOf(Boolean));
  end;
end;

function TRESTDWMemTable.GetDataset: TDataset;
begin
  Result := Self;
end;

function TRESTDWMemTable.GetFieldOffsets(idx : integer) : integer;
begin
  Result := FFieldOffsets[idx];
end;

function TRESTDWMemTable.GetFieldSize(fdname: string): integer;
var
  vField : TField;
begin
  vField := FindField(fdname);
  if vField <> nil then
    Result := vField.Index;
end;

{$IFDEF DELPHIXEUP}
function TRESTDWMemTable.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
begin
  Result := GetFieldData(Field,Pointer(Buffer));
end;
{$ENDIF}

procedure TRESTDWMemTable.SetBookmarkFlag (Buffer: TRESTDWBuffer; Value: TBookmarkFlag);
begin
  PRESTDWRecInfo(Buffer + FRecordSize)^.BookmarkFlag := Value;
end;

{$IFDEF DELPHIXEUP}
procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin
  SetFieldData(Field,Pointer(Buffer));
end;
{$ENDIF}

procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: Pointer);
var
  DestBuffer: TRESTDWBuffer;

  vNull : boolean;
  I,J : integer;

  vDWDataType : Byte;
  vByte : Byte;

  vCurrency : Currency;
  vDouble : Double;
  vFmtBCD : tBCD;
  vDateTimeRec : TDateTimeRec;
  vTimeStamp : TTimeStamp;
  {$IFNDEF RESTDWLAZARUS}
    vSQLTimeStamp : TSQLTimeStamp;
  {$ENDIF}
  {$IFDEF DELPHIXEUP}
    vTimeStampOffSet : TSQLTimeStampOffSet;
  {$ENDIF}
begin
  I:= Field.FieldNo - 1;
  if not GetActiveBuffer(DestBuffer) then
    Exit;

  if I >= 0 then begin
    if State in [dsEdit, dsInsert, dsNewValue] then
      Field.Validate(Buffer);

    Inc(DestBuffer,FFieldOffsets[I]);
    vNull := not (Buffer = nil);
    Move(vNull,DestBuffer^,SizeOf(Boolean));
    Inc(DestBuffer,SizeOf(Boolean));
    if Buffer <> nil then begin
      J := FFieldSize[I];

      vDWDataType := FieldTypeToDWFieldType(Field.DataType);
      if vDWDataType in [dwftWideString, dwftFixedWideChar, dwftFixedChar, dwftString] then
        Dec(J);

      if vDWDataType = dwftFMTBcd then begin
        Move(Buffer^,vFmtBCD,SizeOf(tBCD));
        vCurrency := BCDToDouble(vFmtBCD);
        Move(vCurrency,DestBuffer^,J);
      end
      else if vDWDataType = dwftTimeStamp then begin
        {$IFDEF RESTDWLAZARUS}
          Move(Buffer^,vTimeStamp,SizeOf(vTimeStamp));
          vDouble := TimeStampToDateTime(vTimeStamp);
        {$ELSE}
          Move(Buffer^,vSQLTimeStamp,SizeOf(vSQLTimeStamp));
          vDouble := SQLTimeStampToDateTime(vSQLTimeStamp);
        {$ENDIF}
        Move(vDouble,DestBuffer^,J);
      end
      else if vDWDataType in [dwftDate, dwftTime, dwftDateTime] then begin
        Move(Buffer^,vDateTimeRec,SizeOf(vDateTimeRec));
        case vDWDataType of
          dwftDate:
            begin
              vTimeStamp.Time := 0;
              vTimeStamp.Date := vDateTimeRec.Date;
            end;
          dwftTime:
            begin
              vTimeStamp.Time := vDateTimeRec.Time;
              vTimeStamp.Date := DateDelta;
            end;
        else
          try
            {$IFDEF RESTDWLAZARUS}
              vTimeStamp := MSecsToTimeStamp(Comp(vDateTimeRec.DateTime));
            {$ELSE}
              vTimeStamp := MSecsToTimeStamp(vDateTimeRec.DateTime);
            {$ENDIF}
          except
            vTimeStamp.Time := 0;
            vTimeStamp.Date := 0;
          end;
        end;
        vDouble := TimeStampToDateTime(vTimeStamp);
        Move(vDouble,DestBuffer^,SizeOf(vDouble));
      end
      else if vDWDataType = dwftTimeStampOffset then begin
        {$IFDEF DELPHIXEUP}
          Move(Buffer^,vTimeStampOffSet,SizeOf(vTimeStamp));
          vDouble := SQLTimeStampOffsetToDateTime(vTimeStampOffSet);
          Move(vDouble,DestBuffer^,SizeOf(vDouble));
          Inc(DestBuffer,SizeOf(vDouble));

          vByte := vTimeStampOffSet.TimeZoneHour + 12;
          Move(vByte,DestBuffer^,SizeOf(vByte));
          Inc(DestBuffer,SizeOf(vByte));

          vByte := vTimeStampOffSet.TimeZoneMinute;
          Move(vByte,DestBuffer^,SizeOf(vByte));
          Inc(DestBuffer,SizeOf(vByte));
          Dec(DestBuffer,J);
        {$ENDIF}
      end
      else begin
        Move(Buffer^,DestBuffer^,J);
      end;
//      Dec(DestBuffer,FFieldOffsets[I]+SizeOf(Boolean));
    end;
  end
  else begin
    I := Field.Index;
    Inc(DestBuffer,FFieldOffsets[I]);
    vNull := not (Buffer = nil);
    Move(vNull,DestBuffer^,SizeOf(Boolean));
    Inc(DestBuffer);
    if Buffer <> nil then begin
      J := FFieldSize[I];
      Move(Buffer^,DestBuffer^,J);
    end;
//    Dec(DestBuffer,FFieldOffsets[I]+SizeOf(Boolean));
  end;

  if not (State in [dsCalcFields, dsFilter, dsNewValue]) then begin
    {$IF Defined(RESTDWLAZARUS)}
      DataEvent(deFieldChange, Ptrint(Field));
    {$ELSEIF not Defined(DELPHIXEUP)}
        DataEvent(deFieldChange, Longint(Field));
    {$ELSE}
        DataEvent(deFieldChange, NativeInt(Field));
    {$IFEND}
  end;
end;

procedure TRESTDWMemTable.SetFiltered(Value: Boolean);
begin
  UpdateRecordsAccept(1);
  if Active then begin
    CheckBrowseMode;

    if Value then
      RecalcFilters;

    if Value <> Filtered then
      inherited SetFiltered(Value);

    First;
    if (not FBlockEvents) then
      RefreshStates
  end
  else begin
    inherited SetFiltered(Value);
  end;
end;

procedure TRESTDWMemTable.SetFilterText(const Value: string);

  procedure UpdateFilter;
  begin
    FreeAndNil(FFilterParser);
    if Filter <> '' then begin
      FFilterParser := TExprParser.Create;
      FFilterParser.OnGetVariable := {$IFDEF RESTDWLAZARUS}@{$ENDIF}ParserGetVariableValue;
      if foCaseInsensitive in FilterOptions then
        FFilterParser.Expression := AnsiUpperCase(Filter)
      else
        FFilterParser.Expression := Filter;
    end;
  end;

begin
  UpdateRecordsAccept(1);
  if Active then begin
    CheckBrowseMode;
    inherited SetFilterText(Value);
    UpdateFilter;
    if Filtered then begin
      RecalcFilters;
      First;
    end;
  end
  else
  begin
    inherited SetFilterText(Value);
    UpdateFilter;
  end;
end;

procedure TRESTDWMemTable.setIndexFieldNames(const Value: string);
begin
  if Value = FIndexFieldNames then
    Exit;

  FIndexFieldNames := Value;
  SortOnFields(FIndexFieldNames,FCaseInsensitiveSort);
end;

procedure TRESTDWMemTable.InternalFirst;
begin
  FCurrentRecord := FBofCrack;
end;

procedure TRESTDWMemTable.InternalLast;
begin
  FEofCrack := InternalRecordCount;
  FCurrentRecord := FEofCrack;
end;

function TRESTDWMemTable.GetActiveBuffer(var Buffer: TRESTDWBuffer): Boolean;
begin
  case State of
    dsEdit       : Buffer := TRESTDWBuffer(ActiveBuffer);
    dsInsert     : Buffer := TRESTDWBuffer(ActiveBuffer);
    dsFilter     : Buffer := TRESTDWBuffer(FFilterBuffer);
    dsCalcFields : Buffer := TRESTDWBuffer(CalcBuffer);
    else
      if not IsEmpty then
        Buffer := TRESTDWBuffer(ActiveBuffer)
      else
        Buffer := nil;
  end;
  Result := Buffer <> nil;
end;

procedure TRESTDWMemTable.ClearCalcFields(Buffer : TRecordBuffer);
begin
//  FillChar(Buffer[RecordSize], CalcFieldsSize, 0);
end;

function TRESTDWMemTable.GetActiveRecord: TRESTDWBuffer;
begin
  Result := TRESTDWBuffer(FRecords.Items[FCurrentRecord]);
end;

procedure TRESTDWMemTable.GetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer);
{$IF Defined(RESTDWLAZARUS) or not Defined(DELPHIXEUP)}
  var
    vBook : integer;
{$IFEND}
begin
  {$IFDEF DELPHIXEUP}
    GetBookmarkData(Buffer,TBookmark(Data));
  {$ELSE}
    vBook := PRESTDWRecInfo(Buffer + FRecordSize)^.Bookmark;
    Move(vBook,Data^,SizeOf(vBook)); // FPC/D7
  {$ENDIF}
end;

procedure TRESTDWMemTable.SaveToFile(AFileName: string);
var
  fStr : TFileStream;
begin
  try
    fStr := TFileStream.Create(AFileName,fmCreate or fmOpenWrite);
    try
      fStr.Position := 0;
      SaveToStream(TStream(fStr));
    finally
      fStr.Free;
    end;
  except
    on e : Exception do begin
      raise Exception.Create(e.Message);
    end;
  end;
end;

procedure TRESTDWMemTable.EmptyTable;
var
  vState : TDataSetState;
begin
  vState := Self.State;
  SetState(dsInactive);

  clearBlobs;
  clearRecords;

  SetState(vState);
  DataEvent(deDataSetChange, 0);

  SetLength(FFieldOffsets,0);
  SetLength(FFieldSize,0);
  FRecordCount := 0;
  FFilterRecordCount := -1;
  FCurrentRecord := -1;
//  FRecordBufferSize := 0;
  FRecordSize := 0;
  FFilterBuffer := nil;
end;

procedure TRESTDWMemTable.SaveToStream(AStream: TStream);
var
  vStor : TRESTDWStorageBase;
begin
  if Assigned(FStorageDataType) then
    vStor := FStorageDataType
  else
    vStor := TRESTDWStorageBin.Create(nil);

  try
    vStor.SaveToStream(Self,AStream);
  finally
    if not Assigned(FStorageDataType) then
      vStor.Free;
  end;
end;

procedure TRESTDWMemTable.SetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer);
begin
  {$IFDEF DELPHIXEUP}
    SetBookmarkData(Buffer,TBookmark(Data));
  {$ELSE}
    PRESTDWRecInfo(Buffer + FRecordSize)^.Bookmark := Integer(Data^);
  {$ENDIF}
end;

function TRESTDWMemTable.GetRecordCount: Integer;
begin
  Result := 0;
  if State <> dsInactive then
    Result := GetFilterRecordCount;
end;

function TRESTDWMemTable.GetRecordObj(idx: integer): TRESTDWRecord;
begin
  Result := nil;
  if (idx >= 0) and (idx < FRecords.Count) then
    Result := TRESTDWRecord(FRecords.Items[idx]);
end;

function TRESTDWMemTable.GetFieldSize(idx: integer): integer;
begin
  Result := 0;
  if (idx >= 0) and (idx < Length(FFieldSize)) then
    Result := FFieldSize[idx];
end;

function TRESTDWMemTable.GetFilterRecordCount: integer;
var
  i : integer;
  vRec : TRESTDWRecord;
begin
  if FFilterRecordCount = -1 then begin
    i := 0;
    FFilterRecordCount := 0;
    while i < FRecords.Count do begin
      vRec := TRESTDWRecord(FRecords.Items[i]);
      if vRec.Accept <> 2 then
        FFilterRecordCount := FFilterRecordCount + 1;
      i := i + 1;
    end;
  end;
  Result := FFilterRecordCount;
end;

function TRESTDWMemTable.GetRecNo : integer;
begin
  UpdateCursorPos;
  if FCurrentRecord < 0 then
    Result := 1
  else
    Result := FCurrentRecord + 1;
end;

procedure TRESTDWMemTable.SetRecNo(Value: Integer);
begin
  CheckBrowseMode;
  if (Value >= 1) and (Value <= InternalRecordCount) then
  begin
    FCurrentRecord := Value - 1;
    Resync([]);
  end;
end;

procedure TRESTDWMemTable.SetRecordStatus(rec_status: TRESTDWRecordStatus);
var
  vRec : TRESTDWRecord;
begin
  if not (State in [dsInsert]) then begin
    vRec := GetRecordObj(FCurrentRecord);
    vRec.Status := rec_status;
  end
  else begin
    FStatusRecord := rec_status;
    FStatusRecordChanged := True;
  end;
end;

procedure TRESTDWMemTable.Sort;
var
  vPos: TBookmark;
begin
  if Active and (FRecords <> nil) and (FRecords.Count > 0) then begin
    vPos := Bookmark;
    try
      {$IFDEF RESTDWLAZARUS}
      QuickSort(0, FRecords.Count - 1, @CompareRecords);
      {$ELSE}
      QuickSort(0, FRecords.Count - 1, CompareRecords);
      {$ENDIF}
      SetBufListSize(0);
      try
        SetBufListSize(BufferCount+1);
      except
        SetState(dsInactive);
        CloseCursor;
        raise;
      end;
    finally
      Bookmark := vPos;
    end;
    Resync([]);
  end;
end;

procedure TRESTDWMemTable.SortOnFields(const FieldNames: string;
  CaseInsensitive : Boolean);
begin
  if (not Active) or (State = dsInactive) then
    Exit;

  CheckBrowseMode;
  if FieldNames <> '' then
    CreateIndexList(FieldNames)
  else if FIndexFieldNames <> '' then
    CreateIndexList(FIndexFieldNames)
  else
    Exit;

  FCaseInsensitiveSort := CaseInsensitive;

  try
    Sort;
  except
    on e : Exception do begin
      FreeIndexList;
      raise Exception.Create(e.Message);
    end;
  end;
end;

procedure TRESTDWMemTable.UpdateRecordsAccept(acc: Byte);
var
  i : integer;
  vRec : TRESTDWRecord;
begin
  FFilterRecordCount := -1;
  i := 0;
  while i < FRecords.Count do begin
    vRec := TRESTDWRecord(FRecords.Items[i]);
    vRec.Accept := acc;
    i := i + 1;
  end;
end;

function TRESTDWMemTable.GetRecord(Buffer: TRESTDWBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  vAccepted : boolean;
  vRec : TRESTDWRecord;
  vBuf : TRESTDWBuffer;
begin
  Result := grOK; // default
  vAccepted := True;
  repeat
    case GetMode of
      gmNext: // move on
        if FCurrentRecord < InternalRecordCount - 1 then
          Inc (FCurrentRecord)
        else
          Result := grEOF; // end of file
      gmPrior: // move back
        if FCurrentRecord > 0 then
          Dec (FCurrentRecord)
        else
          Result := grBOF; // begin of file
      gmCurrent: // check if empty
        if (FCurrentRecord >= InternalRecordCount) or
           (FCurrentRecord < 0) then
          Result := grError;
    end;
    if Result = grOK then begin
      vRec := GetRecordObj(FCurrentRecord);
      vBuf := vRec.CopyBuffer;
      Move(vBuf[0],Buffer[0],FRecordBufferSize);
      Freemem(vBuf);
      vAccepted := vRec.Accept = 1;

      // cuidando com isso... rsrsrsrsr
      // esse set bookmark faz com que a grid nao fique louca
      // louca no sentido de ela nao ter fim e nem inicio
      // fica "girando" do primeiro volta pro ultimo
      with PRESTDWRecInfo(Buffer + FRecordSize)^ do begin
        BookmarkFlag := bfCurrent;
        Bookmark := FCurrentRecord;
      end;
      if vAccepted then
        CalculateFields(Buffer);
    end;
    if (GetMode = gmCurrent) and not vAccepted then begin
      Result:=grError;
    end;    
  until (Result <> grOK) or vAccepted;

  // load the data
  if (Result = grError) and DoCheck then
    raise ERESTDWDataSetError.Create ('GetRecord: Invalid record');
end;

procedure TRESTDWMemTable.InternalInitFieldDefs;
var
  i, k : integer;
  vField : TField;
  vFieldDef : TFieldDef;
  vBlock : boolean;
  vDefName : string;

  function buscaFieldDef(fdname : string) : TFieldDef;
  var
    f : integer;
  begin
    Result := nil;
    f := 0;
    while f < FieldDefs.Count do begin
      if SameText(FieldDefs[f].Name,fdname) then begin
        Result := FieldDefs[f];
        Break;
      end;

      f := f + 1;
    end;
  end;

begin
  FRecordSize := 0;

  // aki eh necessario isso devido atualizacao dos campos
  // em uma grid qdo usa loadfrom dataset
  vBlock := FBlockEvents;
  FBlockEvents := False;

  if Fields.Count > 0 then begin
    // fields defs é obrigatorio para fields fkData
    for i := 0 to Fields.Count-1 do begin
      if Fields[i].FieldKind = fkData then begin
        vFieldDef := buscaFieldDef(Fields[i].FieldName);
        vDefName := Fields[i].FieldName;

        {$IFNDEF RESTDWLAZARUS}
          if vFieldDef = nil then begin
            vFieldDef := buscaFieldDef(Fields[i].FullName);
            vDefName := Fields[i].FullName;
          end;
        {$ENDIF}

        if vFieldDef = nil then begin
          vFieldDef := buscaFieldDef(Fields[i].DisplayName);
          vDefName := Fields[i].DisplayName;
        end;

        if vFieldDef = nil then begin
          vFieldDef := FieldDefs.AddFieldDef;
          vFieldDef.Name := vDefName;
          vFieldDef.DataType := Fields[i].DataType;
          vFieldDef.Size := Fields[i].Size;
          vFieldDef.Attributes := [faFixed];
        end;
      end;
    end;
    {$IFNDEF RESTDWLAZARUS}
      FieldOptions.AutoCreateMode := acCombineAlways;
      CreateFields;
      for i := 0 to FieldDefs.Count-1 do begin
        vField := Fields.FindField(FieldDefs[i].Name);
        if vField <> nil then
          vField.Index := i;
      end;
      k := FieldDefs.Count;
      for i := 0 to Fields.Count-1 do begin
        vFieldDef := buscaFieldDef(Fields[i].FieldName);
        if vFieldDef = nil then
          vFieldDef := buscaFieldDef(Fields[i].FullName);
        if vFieldDef = nil then
          vFieldDef := buscaFieldDef(Fields[i].DisplayName);

        if vFieldDef = nil then begin
          Fields[i].Index := k;
          k := k + 1;
        end;
      end;
      FieldOptions.AutoCreateMode := acExclusive;
    {$ELSE}
      for i := 0 to FieldDefs.Count-1 do begin
        vField := Fields.FindField(FieldDefs[i].Name);
        if vField = nil then
          FieldDefs[i].CreateField(Self);
      end;
      for i := 0 to FieldDefs.Count-1 do begin
        vField := Fields.FindField(FieldDefs[i].Name);
        if vField <> nil then
          vField.Index := i;
      end;
      k := FieldDefs.Count;
      for i := 0 to Fields.Count-1 do begin
        vFieldDef := buscaFieldDef(Fields[i].FieldName);
        if vFieldDef = nil then
          vFieldDef := buscaFieldDef(Fields[i].DisplayName);

        if vFieldDef = nil then begin
          Fields[i].Index := k;
          k := k + 1;
        end;
      end;
    {$ENDIF}

    SetLength(FFieldOffsets,Fields.Count);
    SetLength(FFieldSize,Fields.Count);
    for i := 0 to Fields.Count-1 do begin
      FFieldOffsets[i] := FRecordSize;
      FRecordSize := FRecordSize + SizeOf(Boolean); // null
      FFieldSize[i] := calcFieldSize(Fields[i].DataType,Fields[i].Size);
      FRecordSize := FRecordSize + FFieldSize[i];
    end;
  end
  else begin
    SetLength(FFieldOffsets,FieldDefs.Count);
    SetLength(FFieldSize,FieldDefs.Count);
    for i := 0 to FieldDefs.Count-1 do begin
      FFieldOffsets[i] := FRecordSize;
      FRecordSize := FRecordSize + SizeOf(Boolean); // null
      FFieldSize[i] := calcFieldSize(FieldDefs[i].DataType,FieldDefs[i].Size);
      FRecordSize := FRecordSize + FFieldSize[i];
    end;
  end;

  FBlockEvents := vBlock;

  {$IFNDEF RESTDWLAZARUS}
    inherited;
  {$ENDIF}
end;

procedure TRESTDWMemTable.InternalInitRecord(Buffer: TRESTDWBuffer);
begin
  FillChar(Buffer^, FRecordSize, 0);
end;

function TRESTDWMemTable.calcFieldSize(ft: TFieldType; fs: integer): integer;
var
  vDWFieldType : Byte;
begin
//    ficaram fora
//    ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
//    ftADT, ftArray, ftReference, ftDataSet,ftVariant, ftInterface,
//    ftIDispatch

  vDWFieldType := FieldTypeToDWFieldType(ft);
  Result := 0;
  case vDWFieldType of
    dwftString,
    dwftFixedChar : Inc(Result, fs + 1);

    dwftFixedWideChar,
    dwftWideString  : Inc(Result, (fs  + 1) * SizeOf(WideChar));

    dwftGuid        : Inc(Result,37); // string 36 + 1;

    dwftBoolean,
    dwftSmallInt,
    dwftWord      : Inc(Result, 2);

    dwftSingle    : Inc(Result,SizeOf(Single));
    dwftInteger   : Inc(Result,SizeOf(Integer));

    dwftDate,
    dwftTime,
    dwftDateTime,
    dwftTimeStamp : Inc(Result, SizeOf(Double));

    dwftTimeStampOffset : begin
      Inc(Result,SizeOf(Double));
      Inc(Result,SizeOf(Byte));
      Inc(Result,SizeOf(Byte));
    end;

    dwftFloat,
    dwftExtended,
    dwftLargeint,
    dwftBCD,
    dwftFMTBcd,
    dwftAutoInc,
    dwftCurrency  : Inc(Result, 8);

    dwftWideMemo,
    dwftBlob,
    dwftMemo,
    dwftBytes,
    dwftVarBytes,
    dwftFmtMemo,
    dwftOraBlob,
    dwftOraClob  : Inc(Result,SizeOf(Pointer));
  else
    raise ERESTDWDataSetError.Create (
      'InitFieldsDefs: Unsupported field type');
  end;
end;

procedure TRESTDWMemTable.clearBlobs;
var
  i : integer;
  vBlob : PRESTDWBlobField;
begin
  if FBlobs = nil then
    Exit;
  // eh mais rapido correr a lista ao contrario
  // pq nao tem que fazer deslocamento
  i := FBlobs.Count - 1;
  while i >= 0 do begin
    vBlob := PRESTDWBlobField(FBlobs.Items[i]);
    FreeMem(vBlob^.Buffer,vBlob^.Size);
    vBlob^.Buffer := nil;
    vBlob^.Size := 0;
    Dispose(vBlob);
    i := i - 1;
  end;
  FBlobs.Clear;
end;

procedure TRESTDWMemTable.clearRecords;
begin
  if FRecords = nil then
    Exit;

  FRecords.ClearAll;
end;

function TRESTDWMemTable.CompareRecords(Item1, Item2: TRESTDWRecord): Integer;
var
  Data1, Data2: Variant;
  sData1, sData2: string;
  vField : TField;
  i : Integer;
  vDescendingSort : boolean;
begin
  Result := 0;
  if FIndexList <> nil then begin
    for i := 0 to FIndexList.Count - 1 do begin
      vDescendingSort := SameText(FIndexList.Strings[I],'desc');
      vField := TField(FIndexList.Objects[I]);
      Data1 := FindFieldValue(Item1, vField);
      Data2 := FindFieldValue(Item2, vField);

      if (Data1 = null) and (Data2 <> null) then begin
        Result := -1
      end
      else if (Data1 <> null) and (Data2 = null) then begin
        Result := 1
      end
      else begin
        if VarIsStr(Data1) then begin
          sData1 := VarToStr(Data1);
          sData2 := VarToStr(Data2);
          if sData1 < sData2 then
            Result := -1
          else if sData1 > sData2 then
            Result := 1;
        end
        else begin
          if (VarCompareValue(Data1,Data2) = vrLessThan) then
            Result := -1
          else if (VarCompareValue(Data1,Data2) = vrGreaterThan) then
            Result := 1;
        end;
      end;

      if vDescendingSort then
        Result := -Result;

      if Result <> 0 then
        Exit;
    end;
  end;
end;

constructor TRESTDWMemTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStatusRecord := rsInserted;
  FStatusRecordChanged := False;
  FRecordCount := 0;
  FFilterRecordCount := -1;
  FRecords := TRecordList.Create;
  FBlobs := TList.Create;
  FIndexList := nil;
  FFilterBuffer := nil;
  FFilterParser := nil;
  FStorageDataType := nil;
end;

function TRESTDWMemTable.CreateBlobStream(Field: TField;
  Mode: TBlobStreamMode): TStream;
begin
  Result := TRESTDWBlobStream.Create(Self,Field as TBlobField,Mode);
end;

{$IF Defined(RESTDWLAZARUS)}
procedure TRESTDWMemTable.DataEvent(Event: TDataEvent; Info: Ptrint);
{$ELSEIF not Defined(DELPHIXEUP)}
procedure TRESTDWMemTable.DataEvent(Event: TDataEvent; Info: Longint);
{$ELSE}
procedure TRESTDWMemTable.DataEvent(Event: TDataEvent; Info: NativeInt);
{$IFEND}
var
  vControl : boolean;
begin
  if FBlockEvents then
    Exit;

  // ideia implementada com intuito de nao filtrar nada
  // enquanto nao estiver inserindo com DisableControls
  // e assim q dat EnableControls ativar o Filtro
  if ControlsDisabled then begin
    FControlsDisabled := True;
  end
  else begin
    vControl := FControlsDisabled;
    FControlsDisabled := False;
    if (vControl) then begin
      if (Filtered) then begin
        RecalcFilters;
        First;
     end;
      SortOnFields(FIndexFieldNames,FCaseInsensitiveSort);
      {$IFNDEF RESTDWLAZARUS}
        RefreshStates;
      {$ENDIF}
    end;
  end;

  if Event in [deDataSetChange,deCheckBrowseMode] then
    FFilterRecordCount := -1;

  inherited DataEvent(Event,Info);
end;

destructor TRESTDWMemTable.Destroy;
begin
  if Self.Active then
    Self.Close;

  if FFilterParser <> nil then
    FreeAndNil(FFilterParser);

  FreeIndexList;
  SetState(dsInactive);

  EmptyTable;
  FreeAndNil(FRecords);
  FreeAndNil(FBlobs);

  inherited Destroy;
end;

procedure TRESTDWMemTable.DoAfterPost;
begin
  inherited DoAfterPost;
  if not ControlsDisabled then
    SortOnFields(FIndexFieldNames,FCaseInsensitiveSort);
end;

function TRESTDWMemTable.FilterRecord(Buffer: TRESTDWBuffer): Boolean;
var
  SaveState: TDatasetState;
begin
  Result := True;
  if Assigned(OnFilterRecord) or (FFilterParser <> nil) then begin
    if (FCurrentRecord >= 0) and (FCurrentRecord < FRecordCount) then begin
      SaveState:=SetTempState(dsFilter);
      try
        FFilterBuffer := Buffer;
        if Assigned(OnFilterRecord) then
          OnFilterRecord(Self,Result);

        if (Result) and (Length(Filter) > 0) then begin
          if (FFilterParser <> nil) and FFilterParser.Eval() then begin
            FFilterParser.EnableWildcardMatching := not (foNoPartialCompare in FilterOptions);
            FFilterParser.CaseInsensitive := foCaseInsensitive in FilterOptions;
            Result := FFilterParser.Value;
          end;
        end;
      finally
        RestoreState(SaveState);
      end;
    end;
  end;
end;

function TRESTDWMemTable.FindFieldValue(Item: TRESTDWRecord; Field: TField): Variant;
var
  vBuffer : TRESTDWBuffer;
  vNull : Boolean;
  vDWFieldType : Byte;
  vValue : PByte;
  i,j : integer;

  vDouble : Double;
  vString : AnsiString;
  vWideString : WideString;
  vByte1, vByte2 : Byte;
  vDateTime : TDatetime;
begin
  if Field.FieldKind = fkData then
    i := Field.FieldNo - 1
  else
    i := Field.Index;

  vBuffer := Item.CopyBuffer;
  Inc(vBuffer,FFieldOffsets[i]);
  Move(vBuffer^,vNull,Sizeof(Boolean));
  Inc(vBuffer,Sizeof(Boolean));

  if vNull then begin // null invertido
    j := FFieldSize[i];
    vDWFieldType := FieldTypeToDWFieldType(Field.DataType);
    if vDWFieldType = dwftTimeStampOffset then begin
      Move(vBuffer^,vDouble,Sizeof(vDouble));
      Inc(vBuffer,SizeOf(Double));

      vDateTime := vDouble;

      Move(vBuffer^,vByte1,Sizeof(vByte1));
      Inc(vBuffer,SizeOf(vByte1));

      Move(vBuffer^,vByte2,Sizeof(vByte2));

      Dec(vBuffer,SizeOf(Double));
      Dec(vBuffer,SizeOf(Byte));

      // data hora -> GMT
      if vByte1 < 12 then begin
        // soma
        vDateTime := vDateTime - ((vByte1 - 12) / 24);
        vDateTime := vDateTime + (vByte2 / 24 / 60);
      end
      else begin
        // sub
        vDateTime := vDateTime - ((vByte1 - 12) / 24);
        vDateTime := vDateTime - (vByte2 / 24 / 60);
      end;

      Result := vDateTime;
    end
    else if vDWFieldType in [dwftString,dwftFixedChar,dwftGuid] then begin
      SetLength(vString,J);
      Move(vBuffer^,vString[InitStrPos],J);
      Result := vString;
    end
    else if vDWFieldType in [dwftWideString,dwftFixedWideChar] then begin
      SetLength(vWideString,J);
      Move(vBuffer^,vWideString[InitStrPos],J);
      Result := vWideString;
    end
    else begin
      GetMem(vValue,j);
      FillChar(vValue^, j,0);
      Move(vBuffer^,vValue^,j);

      case vDWFieldType of
        dwftBoolean        : Result := PBoolean(vValue)^;
        dwftSmallInt       : Result := PSmallInt(vValue)^;
        dwftWord           : Result := PWord(vValue)^;

        dwftSingle         : Result := PSingle(vValue)^;
        dwftInteger        : Result := PInteger(vValue)^;

        dwftDate,
        dwftTime,
        dwftDateTime,
        dwftTimeStamp      : Result := TDateTime(PDouble(vValue)^);

        dwftFloat          : Result := PDouble(vValue)^;
        dwftExtended       : Result := PExtended(vValue)^;
        dwftLargeint       : Result := PInt64(vValue)^;
        dwftBCD            : Result := PCurrency(vValue)^;
        dwftFMTBcd         : Result := PCurrency(vValue)^;
        dwftAutoInc        : Result := PInt64(vValue)^;
        dwftCurrency       : Result := PCurrency(vValue)^;
      end;
      FreeMem(vValue);
    end;
  end
  else begin
    Result := null;
  end;

  Dec(vBuffer,FFieldOffsets[i]+SizeOf(Boolean));
  FreeMem(vBuffer);
end;

procedure TRESTDWMemTable.FreeIndexList;
begin
  if Assigned(FIndexList) then
    FreeAndNil(FIndexList);
end;

procedure TRESTDWMemTable.FreeRecordBuffer(var ABuffer: TRESTDWBuffer);
begin
  Freemem(ABuffer);
end;

function TRESTDWMemTable.GetRecordSize: Word;
begin
  Result := FRecordBufferSize;
end;

function TRESTDWMemTable.GetRecordStatus: TRESTDWRecordStatus;
var
  vRec : TRESTDWRecord;
begin
  vRec := GetRecordObj(FCurrentRecord);
  Result := vRec.Status;
end;

function TRESTDWMemTable.GetRecSize: integer;
begin
  Result := FRecordSize;
end;

procedure TRESTDWMemTable.AddBlobList(blob: PRESTDWBlobField);
begin
  FBlobs.Add(blob);
end;

procedure TRESTDWMemTable.AddNewRecord(rec: TRESTDWRecord);
begin
  FRecords.Add(rec);
  Inc(FRecordCount);
end;

function TRESTDWMemTable.AllocRecordBuffer: TRESTDWBuffer;
begin
  Result := AllocMem(FRecordBufferSize);
  //GetMem(Result, FRecordBufferSize);
  //FRecs.Add(@Result);
end;

function TRESTDWMemTable.BookmarkValid(ABookmark: TBookmark): Boolean;
var
  ReqBookmark: Integer;
begin
  Move(Pointer(ABookmark)^,ReqBookmark,BookmarkSize);
  Result := (ABookmark <> nil) and Active and (ReqBookmark >= FBofCrack) and
            (ReqBookmark < InternalRecordCount);
end;

procedure TRESTDWMemTable.InternalDelete;
var
  vRec : TRESTDWRecord;
  vBuffer : TRESTDWBuffer;
  Accept : boolean;
begin
  // Eloy - correção até revisão da equipe MemTable
  //vRec := GetRecordObj(FCurrentRecord);
  FRecords.Delete(FCurrentRecord);
  //vRec.Free;

  if FCurrentRecord >= FRecords.Count then
    Dec(FCurrentRecord);

  Accept := True;
  repeat
    if Filtered then begin
      vRec := GetRecordObj(FCurrentRecord);
      if vRec <> nil then begin
        vBuffer := vRec.CopyBuffer;
        Accept := FilterRecord(vBuffer);
        FreeMem(vBuffer);
      end;
    end;
    if not Accept then
      Dec(FCurrentRecord);
  until Accept or (FCurrentRecord < 0);

  FRecordCount := FRecordCount - 1;
  if FRecordCount < 0 then
    FRecordCount := 0;
end;

procedure TRESTDWMemTable.InternalHandleException;
begin
  // special purpose exception handling
  // do nothing
end;

procedure TRESTDWMemTable.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
var
  vRecPos: Integer;
  vRec: TRESTDWRecord;
begin
  if AAppend then begin
    vRec := TRESTDWRecord.Create(Self);
    FRecords.Add(vRec);
    FCurrentRecord := FRecords.Count - 1;
  end
  else begin
    if FCurrentRecord = -1 then
      vRecPos := 0
    else
      vRecPos := FCurrentRecord;
    vRec := TRESTDWRecord.Create(Self);
    FRecords.Insert(vRecPos,vRec);
    FCurrentRecord := vRecPos;
  end;
  Move(Buffer^,vRec.FBuffer^,FRecordBufferSize);
  FRecordCount := FRecordCount + 1;
end;

{$IFDEF DELPHIXEUP}
procedure TRESTDWMemTable.InternalAddRecord(Buffer: TRecBuf; Append: Boolean);
begin
  InternalAddRecord(Pointer(Buffer),Append);
end;

procedure TRESTDWMemTable.InternalAddRecord(Buffer: TRESTDWBuffer;
  Append: Boolean);
begin
  InternalAddRecord(Pointer(Buffer),Append);
end;
{$ENDIF}

procedure TRESTDWMemTable.InternalPost;
var
  vRec : TRESTDWRecord;
begin
  CheckActive;
  if not (State in [dsEdit, dsInsert]) then
    Exit;

  inherited InternalPost;

  if State = dsEdit then begin
    vRec := GetRecordObj(FCurrentRecord);
    Move(TRESTDWBuffer(ActiveBuffer)^, vRec.FBuffer^, FRecordBufferSize);

    if FStatusRecordChanged then
      vRec.Status := FStatusRecord;

    FStatusRecord := rsInserted;
    FStatusRecordChanged := False;

    if Filtered then begin
      UpdateRecordsAccept(1);
      RecalcFilters;
    end;
  end
  else begin
    // always append
    InternalAddRecord(ActiveBuffer, FCurrentRecord >= FRecords.Count);
  end;
end;


procedure TRESTDWMemTable.InternalAfterOpen;
begin
  // nothing to do: subclasses can hook in here
end;

procedure TRESTDWMemTable.InternalPreOpen;
begin
  // nothing to do: subclasses can hook in here
end;

function TRESTDWMemTable.InternalRecordCount: Longint;
begin
  Result := FRecordCount;
end;

{ TRESTDWRecord }
procedure TRESTDWRecord.clearBlobsFields;
var
  i : integer;
  vFieldOffSet : integer;
  vBlobField : PRESTDWBlobField;
  vBuf : TRESTDWBuffer;
  vBoolean : boolean;
  vDWFieldType : Byte;
begin
  if FDataset.State = dsInactive then
    Exit;

  i := 0;
  while i < FDataset.Fields.Count do begin
    vDWFieldType := FieldTypeToDWFieldType(FDataset.Fields[i].DataType);
    if vDWFieldType in ftBlobTypes then begin
      vBuf := CopyBuffer;
      vFieldOffSet := FDataset.GetFieldOffsets(i);
      Inc(vBuf,vFieldOffSet);
      Move(vBuf^,vBoolean,SizeOf(vBoolean));
      Inc(vBuf,SizeOf(Boolean));

      if vBoolean then begin
        Move(vBuf^,vBlobField,SizeOf(Pointer));
        try
          if (vBlobField <> nil) and (vBlobField^.Buffer <> nil) then begin
            FDataSet.FBlobs.Remove(vBlobField);
            FreeMem(vBlobField^.Buffer, vBlobField^.Size);
            vBlobField^.Buffer := nil;
            vBlobField^.Size := 0;
            FreeMem(vBlobField);
          end;
        except
          // ja foi destruido no clearBlobs do Dataset
        end;
      end;
      Dec(vBuf,vFieldOffSet+SizeOf(Boolean));
      Freemem(vBuf);
    end;
    i := i + 1;
  end;
end;

procedure TRESTDWRecord.clearRecInfo;
var
  vRecSize : integer;
  vRecInfo : PRESTDWRecInfo;
  vBuf : TRESTDWBuffer;
begin
  vRecSize := FDataset.GetRecordSize;
  vBuf := TRESTDWBuffer(FBuffer);
  Inc(vBuf,vRecSize);
  Move(vBuf^,vRecInfo,SizeOf(Pointer));

  try
    if vRecInfo <> nil then
      FreeMem(vRecInfo);
  except
    // ja ta limpo
  end;
  Dec(vBuf,vRecSize);
end;

function TRESTDWRecord.CopyBuffer: TRESTDWBuffer;
begin
  GetMem(Result, FDataset.FRecordBufferSize);
  FillChar(Result^,FDataset.FRecordBufferSize,0);
  Move(FBuffer^,Result^,FDataset.FRecordBufferSize);
end;

procedure TRESTDWRecord.CopyBuffer(var Buffer: TRESTDWBuffer);
begin
  Move(FBuffer^,Buffer^,FDataset.FRecordBufferSize);
end;

constructor TRESTDWRecord.Create(AOwner : TRESTDWMemTable);
begin
  inherited Create;
  FDataset := AOwner;
  FAccept := 1;
  FStatus := rsInserted;
  FID := FDataset.FLastID;

  FDataset.FLastID := FDataset.FLastID + 1;
  GetMem(FBuffer, FDataset.FRecordBufferSize);
  FillChar(FBuffer^,FDataset.FRecordBufferSize,0);
end;

destructor TRESTDWRecord.Destroy;
begin
//  clearRecInfo;
  clearBlobsFields;
  FreeMem(FBuffer);
  FDataset := nil;
  FBuffer := nil;
  inherited Destroy;
end;

procedure TRESTDWRecord.setBuffer(const Value: TRESTDWBuffer);
begin
  clearBlobsFields;
  Move(Value^,FBuffer^,FDataset.GetRecordSize);
end;

{ TRESTDWBlobStream }

procedure TRESTDWBlobStream.AllocBlobField(NewSize: UInt64);
begin
  if FBlobField = nil then begin
    FBlobField := New(PRESTDWBlobField);
    FillChar(FBlobField^, SizeOf(TRESTDWBlobField), 0);
  end;

  FDataSet.FBlobs.Remove(FBlobField);
  ReAllocMem(FBlobField^.Buffer, NewSize);
  FDataSet.FBlobs.Add(FBlobField);
  FModified := True;
end;

constructor TRESTDWBlobStream.Create(AOwner: TRESTDWMemTable;
  DataField: TBlobField; Mode: TBlobStreamMode);
begin
  FDataset := AOwner;
  FField := DataField;
  FMode := Mode;

  if not FField.GetData(@FBlobField) then
    FBlobField := nil;

  // release existing Blob
  if (Mode = bmWrite) and (FBlobField <> nil) then
    FreeBlobField;
end;

destructor TRESTDWBlobStream.Destroy;
begin
  SetDataBlob;
  FDataset := nil;
  FField := nil;
  inherited Destroy;
end;

procedure TRESTDWBlobStream.FreeBlobField;
begin
  FDataSet.FBlobs.Remove(FBlobField);
  FreeMem(FBlobField^.Buffer, FBlobField^.Size);
  FBlobField^.Buffer := nil;
  FBlobField^.Size := 0;
  FBlobField := nil;
  FModified := True;
end;

function TRESTDWBlobStream.Read(var Buffer; Count: Longint): Longint;
var
  P : Pointer;
begin
  if FBlobField <> nil then begin
    if FPosition + Count > FBlobField^.Size then
      Count := FBlobField^.Size - FPosition;
    {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXEUP)}
      P := FBlobField^.Buffer;
      Inc(PByte(P),FPosition);
    {$ELSE}
      P := FBlobField^.Buffer + FPosition;
    {$IFEND}
    Move(P^, Buffer, Count);
    {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXEUP)}
      Dec(PByte(P),FPosition);
    {$ELSE}
      P := FBlobField^.Buffer - FPosition;
    {$IFEND}
    Inc(FPosition, Count);
  end
  else begin
    Count := 0;
  end;
  Result := Count;
end;

function TRESTDWBlobStream.Seek(const Offset: int64; Origin: TSeekOrigin): int64;
begin
  if FBlobField <> nil then begin
    case Origin of
      soBeginning : FPosition := Offset;
      soEnd       : FPosition := FBlobField^.Size + Offset;
      soCurrent   : FPosition := FPosition + Offset;
    end;
  end;
  Result := FPosition;
end;

procedure TRESTDWBlobStream.SetDataBlob;
begin
  if FModified then begin
    // Empty blob = IsNull
    if (FBlobField = nil) or (FBlobField^.Size = 0) then
      FField.SetData(nil)
    else
      FField.SetData(@FBlobField);
  end;
end;

function TRESTDWBlobStream.Write(const Buffer; Count: Longint): Longint;
var
  P : Pointer;
begin
  AllocBlobField(FPosition+Count);
  {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXEUP)}
    P := FBlobField^.Buffer;
    Inc(PByte(P),FPosition);
  {$ELSE}
    P := FBlobField^.Buffer + FPosition;
  {$IFEND}
  Move(Buffer, P^, Count);
  Inc(FBlobField^.Size, Count);
  {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXEUP)}
    Dec(PByte(P),FPosition);
  {$ELSE}
    P := FBlobField^.Buffer - FPosition;
  {$IFEND}
  Inc(FPosition, Count);
  Result := Count;
  SetDataBlob;
end;

{ TRESTDWStorageBase }

constructor TRESTDWStorageBase.Create(AOwner: TComponent);
begin
  inherited;
  FEncodeStrs := False;
end;

procedure TRESTDWStorageBase.LoadDatasetFromStream(ADataset: TDataset; AStream: TStream);
begin

end;

procedure TRESTDWStorageBase.LoadDWMemFromStream(IDataset: IRESTDWMemTable; AStream: TStream);
begin

end;

procedure TRESTDWStorageBase.LoadFromFile(ADataset: TDataset; AFileName: String);
var
  vFileStream : TFileStream;
begin
  if not FileExists(AFileName) then
    Exit;

  vFileStream := TFileStream.Create(AFileName,fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(ADataset,TStream(vFileStream));
  finally
    vFileStream.Free;
  end;
end;

procedure TRESTDWStorageBase.LoadFromStream(ADataset: TDataset; AStream: TStream);
begin
  if ADataset.InheritsFrom(TRESTDWMemTable) then
    LoadDWMemFromStream(TRESTDWMemTable(ADataset), AStream)
  else
    LoadDatasetFromStream(ADataset, AStream);
end;

procedure TRESTDWStorageBase.SaveDatasetToStream(ADataset: TDataset; var AStream: TStream);
begin

end;

procedure TRESTDWStorageBase.SaveDWMemToStream(IDataset: IRESTDWMemTable; var AStream: TStream);
begin

end;

procedure TRESTDWStorageBase.SaveToFile(ADataset: TDataset; AFileName: String);
var
  vFileStream : TBufferedFileStream;
begin
  try
    vFileStream := TBufferedFileStream.Create(AFileName,fmCreate);
    try
      SaveToStream(ADataset,TStream(vFileStream));
    except
      on e : Exception do begin
        raise
      end;
    end;
  finally
    vFileStream.Free;
  end;
end;

procedure TRESTDWStorageBase.SaveToStream(ADataset: TDataset; var AStream: TStream);
begin
  if ADataset.InheritsFrom(TRESTDWMemTable) then
    SaveDWMemToStream(TRESTDWMemTable(ADataset), AStream)
  else
    SaveDatasetToStream(ADataset, AStream);
end;

function TRESTDWMemTable.GetFieldType(fdname: string): TFieldType;
var
  vField : TField;
begin
  vField := FindField(fdname);
  if vField <> nil then
    Result := vField.DataType;
end;

end.
