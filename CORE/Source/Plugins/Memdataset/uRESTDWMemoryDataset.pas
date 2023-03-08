unit uRESTDWMemoryDataset;

{$I ..\..\..\Source\Includes\uRESTDWPlataform.inc}
{$I ..\..\..\Source\Includes\uRESTDW.inc}

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
  {$IFNDEF FPC} SqlTimSt, {$ENDIF}
  SysUtils, Classes, Db, FmtBCD, Variants, uRESTDWExprParser, uRESTDWAbout,
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

  {$IFDEF FPC}
    TRESTDWBuffer = TRecordBuffer;
  {$ELSE}
    {$IF CompilerVersion < 21}
      TRESTDWBuffer = PChar;
    {$ELSE}
      {$IFDEF NEXTGEN}
        TRESTDWBuffer = TRecBuf;
      {$ELSE}
        TRESTDWBuffer = TRecordBuffer;
      {$ENDIF}
    {$IFEND}
  {$ENDIF}

  TRESTDWMemTable = class;
  TRESTDWBlobStream = class;

  TRESTDWBlobField = record
    Buffer: PByte;  // pointer to memory allocated for Blob data
    Size: UInt64;   // size of Blob data
  end;
  PRESTDWBlobField = ^TRESTDWBlobField;

  { TRESTDWRecord }

  TRESTDWRecordStatus = (rsOriginal, rsUpdated, rsInserted, rsDeleted);

  TRESTDWRecord = class(TObject)
  private
    FDataset : TRESTDWMemTable;
    FBuffer : Pointer;
    FAccept : Byte;
    FStatus : TRESTDWRecordStatus;
    procedure setBuffer(const Value: Pointer);
  protected
    procedure clearRecInfo;
    procedure clearBlobsFields;
  public
    constructor Create(AOwner : TRESTDWMemTable);
    destructor Destroy; override;

    function CopyBuffer : Pointer; overload;
    procedure CopyBuffer(var Buffer : Pointer); overload;

    property Buffer : Pointer read FBuffer write setBuffer;
  published
    property Accept : Byte read FAccept write FAccept;
    property Status : TRESTDWRecordStatus read FStatus write FStatus;
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
    {$IFDEF FPC}
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
    {$IFDEF FPC}
      property DatabaseCharSet: TDatabaseCharSet read FDatabaseCharSet  write FDatabaseCharSet;
    {$ENDIF}
    property EncodeStrs: Boolean read FEncodeStrs write FEncodeStrs;
  end;

  TRESTDWCompareRecords = function(Item1, Item2: TRESTDWRecord): Integer of object;

  { TRESTDWMemTable }

  TRESTDWMemTable = class(TDataSet, IRESTDWMemTable)
  private
    FRecords : TList;

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
    FCurrentRecordObj : TRESTDWRecord;
    FFilterRecordCount : LongInt;
    FStorageDataType : TRESTDWStorageBase;
    FCaseInsensitiveSort: Boolean;
    FIndexList : TStringList;

    FStatusRecord : TRESTDWRecordStatus;
    FStatusRecordChanged : Boolean;

    procedure setIndexFieldNames(const Value: string);
  protected
    // create, close, and so on
    procedure InternalOpen; override;
    procedure InternalClose; override;
    function IsCursorOpen: Boolean; override;
    procedure CreateFields; override;

    // custom functions
    procedure InternalInitFieldDefs; override;
    function InternalRecordCount: Longint; virtual;
    procedure InternalPreOpen; virtual;
    procedure InternalAfterOpen; virtual;
    procedure InternalLoadCurrentRecord(Buffer: TRESTDWBuffer); virtual;

    // memory management
    function AllocRecordBuffer: TRESTDWBuffer; override;
    procedure InternalInitRecord(Buffer: TRESTDWBuffer); override;
    procedure FreeRecordBuffer(var Buffer: TRESTDWBuffer); override;
    function GetRecordSize: Word; override;
    function GetActiveBuffer(out Buffer: TRESTDWBuffer): Boolean;

    // movement and optional navigation (used by grids)
    function GetRecord(Buffer: TRESTDWBuffer; GetMode: TGetMode;
      DoCheck: Boolean): TGetResult; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    function GetRecNo: Longint; override;
    function GetRecordCount: integer; override;
    procedure SetRecNo(Value: Integer); override;

    // filter
    function FilterRecord(Buffer : TRESTDWBuffer): Boolean;
    procedure SetFiltered(Value: Boolean); override;

    {$IFDEF FPC}
      procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
    {$ELSE}
      {$IF CompilerVersion < 21}
        procedure DataEvent(Event: TDataEvent; Info: Longint); override;
      {$ELSE}
        procedure DataEvent(Event: TDataEvent; Info: NativeInt); override;
      {$IFEND}
    {$ENDIF}

    procedure SetFilterText(const Value: string); override;

    // parser
    function ParserGetVariableValue(Sender: TObject; const VarName: string; var Value: Variant): Boolean; virtual;

    // bookmarks
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure InternalSetToRecord(Buffer: TRESTDWBuffer); override;
    procedure SetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer); override;
    procedure GetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer); override;
    {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
      procedure GetBookmarkData(Buffer: TRESTDWBuffer; Data: TBookmark); override;
    {$IFEND}
    procedure SetBookmarkFlag(Buffer: TRESTDWBuffer; Value: TBookmarkFlag); override;
    function GetBookmarkFlag(Buffer: TRESTDWBuffer): TBookmarkFlag; override;

    // editing (dummy vesions)
    procedure InternalDelete; override;

    {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
      procedure InternalAddRecord(Buffer: TRecBuf; Append: Boolean); override;
      procedure InternalAddRecord(Buffer: TRESTDWBuffer; Append: Boolean); override;
    {$IFEND}
    procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;

    procedure InternalPost; override;
    procedure DoAfterPost; override;

    // fields
    {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
      procedure SetFieldData(Field: TField; Buffer: TValueBuffer); overload; override;
    {$IFEND}
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
    function GetFieldSize(idx : integer) : integer; overload;
    procedure AddNewRecord(rec : TRESTDWRecord);
    procedure AddBlobList(blob : PRESTDWBlobField);
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

    {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
      function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    {$IFEND}
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

    property IndexFieldNames : string read FIndexFieldNames write setIndexFieldNames;
  end;

implementation

uses
  uRESTDWStorageBin;

procedure TRESTDWMemTable.InternalOpen;
begin
  if FIsTableOpen then
    Exit;

  InternalPreOpen; // custom method for subclasses

  // initialize the field definitions
  // (another virtual abstract method of TDataSet)
  InternalInitFieldDefs;

  // if there are no persistent field objects,
  // create the fields dynamically
  if DefaultFields then
    CreateFields;

  // connect the TField objects with the actual fields
  BindFields (True);

  InternalAfterOpen; // custom method for subclasses

  // sets cracks and record position and size
  FBofCrack := -1;
  FEofCrack := InternalRecordCount;
  FCurrentRecord := FBofCrack;
  FRecordBufferSize := FRecordSize + SizeOf(Pointer);
  BookmarkSize := SizeOf(Integer);

  // everything OK: table is now open
  FIsTableOpen := True;
end;

procedure TRESTDWMemTable.InternalClose;
var
  vBlock : Boolean;
begin
  vBlock := FBlockEvents;
  
  EmptyTable;

  // disconnet field objects
  BindFields(False);
  // destroy field object (if not persistent)
  if DefaultFields then
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
      {$IFDEF FPC}
        if DataType = ftTimeStamp then begin
          DataType := ftDateTime;
        end;
      {$ENDIF}
    end;
  end;

  inherited CreateFields;
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

  {$IF (NOT DEFINED(FPC)) AND (CompilerVersion > 24)}
    vPosFinal := High(FieldNames);
  {$ELSE}
    vPosFinal := Length(FieldNames);
  {$IFEND}

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

procedure TRESTDWMemTable.InternalGotoBookmark (ABookmark: Pointer);
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

{$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
  procedure TRESTDWMemTable.GetBookmarkData(Buffer: TRESTDWBuffer; Data: TBookmark);
  var
    vBook : integer;
  begin
    vBook := PRESTDWRecInfo(Buffer + FRecordSize)^.Bookmark;
    Move(vBook,Pointer(@Data[0])^,SizeOf(vBook)); // XE
  end;
{$IFEND}

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

  vCurrency : Currency;
  vDouble : Double;
  vByte : Byte;
  vFmtBCD : tBCD;
  vTimeStamp : TTimeStamp;
  vDateTimeRec : TDateTimeRec;
  vString : AnsiString;
  {$IFNDEF FPC}
    vSQLTimeStamp : TSQLTimeStamp;
  {$ENDIF}
  {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
    vTimeStampOffSet : TSQLTimeStampOffSet;
  {$IFEND}
begin
  I := Field.FieldNo - 1;
  Result := GetActiveBuffer(SrcBuffer);
  if not Result then
    Exit;

  if I >= 0 then begin
    Inc(SrcBuffer,FFieldOffsets[I]);
    Move(SrcBuffer^,vNull,SizeOf(Boolean));
    Inc(SrcBuffer);

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
        {$IFDEF FPC}
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
        {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
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
        {$IFEND}
      end
      else if vDWDataType = dwftWideString then begin
        SetLength(vString,J);
        Move(SrcBuffer^,vString[InitStrPos],J);
        Move(vString[InitStrPos],Buffer^,J);
      end
      else begin
        Move(SrcBuffer^,Buffer^,J);
      end;
      Dec(SrcBuffer,FFieldOffsets[I]+1);								
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

{$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
  function TRESTDWMemTable.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
  begin
    Result := GetFieldData(Field,Pointer(Buffer));
  end;
{$IFEND}

procedure TRESTDWMemTable.SetBookmarkFlag (Buffer: TRESTDWBuffer; Value: TBookmarkFlag);
begin
  PRESTDWRecInfo(Buffer + FRecordSize)^.BookmarkFlag := Value;
end;

{$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
  procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: TValueBuffer);
  begin
    SetFieldData(Field,Pointer(Buffer));
  end;
{$IFEND}

procedure TRESTDWMemTable.SetFieldData(Field: TField; Buffer: Pointer);
var
  DestBuffer: TRESTDWBuffer;
  vNull : boolean;
  I,J: integer;

  vDWDataType : Byte;

  vCurrency : Currency;
  vDouble : Double;
  vByte : Byte;
  vFmtBCD : tBCD;
  vDateTimeRec : TDateTimeRec;
  vTimeStamp : TTimeStamp;
  {$IFNDEF FPC}
    vSQLTimeStamp : TSQLTimeStamp;
  {$ENDIF}

  {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
    vTimeStampOffSet : TSQLTimeStampOffSet;
  {$IFEND}
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
    Inc(DestBuffer);
    if Buffer <> nil then begin
      J := FFieldSize[I];

      vDWDataType := FieldTypeToDWFieldType(Field.DataType);

      if vDWDataType = dwftFMTBcd then begin
        Move(Buffer^,vFmtBCD,SizeOf(tBCD));
        vCurrency := BCDToDouble(vFmtBCD);
        Move(vCurrency,DestBuffer^,J);
      end
      else if vDWDataType = dwftTimeStamp then begin
        {$IFDEF FPC}
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
            {$IFDEF FPC}
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
        {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
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
        {$IFEND}
      end
      else begin
        Move(Buffer^,DestBuffer^,J);
      end;
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
  end;

  {$IFDEF FPC}
    DataEvent(deFieldChange, Ptrint(Field));
  {$ELSE}
    {$IF CompilerVersion < 21}
      DataEvent(deFieldChange, Longint(Field));
    {$ELSE}
      DataEvent(deFieldChange, NativeInt(Field));
    {$IFEND}
  {$ENDIF}
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
      FFilterParser.OnGetVariable := {$IFDEF FPC}@{$ENDIF}ParserGetVariableValue;
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

procedure TRESTDWMemTable.InternalLoadCurrentRecord(Buffer: TRESTDWBuffer);
begin
  FCurrentRecordObj := TRESTDWRecord(FRecords.Items[FCurrentRecord]);
  FCurrentRecordObj.CopyBuffer(Pointer(Buffer));
  with PRESTDWRecInfo(Buffer + FRecordSize)^ do begin
    BookmarkFlag := bfCurrent;
    Bookmark := FCurrentRecord;
  end;
end;

function TRESTDWMemTable.GetActiveBuffer(out Buffer: TRESTDWBuffer): Boolean;
begin
  Buffer := nil;
  case State of
    dsEdit       : Buffer := TRESTDWBuffer(ActiveBuffer);
    dsInsert     : Buffer := TRESTDWBuffer(ActiveBuffer);
    dsFilter     : Buffer := TRESTDWBuffer(FFilterBuffer);
    dsCalcFields : Buffer := TRESTDWBuffer(CalcBuffer);
    else if not IsEmpty then
      Buffer := TRESTDWBuffer(ActiveBuffer);
  end;
  Result := Buffer <> nil;
end;

function TRESTDWMemTable.GetActiveRecord: TRESTDWBuffer;
begin
  Result := TRESTDWBuffer(FRecords.Items[FCurrentRecord]);
end;

procedure TRESTDWMemTable.GetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer);
{$IF (DEFINED(FPC)) or (CompilerVersion < 21)}
  var
    vBook : integer;
{$IFEND}
begin
  {$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
    GetBookmarkData(Buffer,TBookmark(Data));
  {$ELSE}
    vBook := PRESTDWRecInfo(Buffer + FRecordSize)^.Bookmark;
    Move(vBook,Data^,SizeOf(vBook)); // FPC/D7
  {$IFEND}
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

  SetLength(FFieldOffsets,0);
  SetLength(FFieldSize,0);
  FRecordCount := 0;
  FFilterRecordCount := -1;
  FCurrentRecord := -1;
  FRecordBufferSize := 0;
  FRecordSize := 0;

  SetState(vState);
  DataEvent(deDataSetChange, 0);
end;

procedure TRESTDWMemTable.SaveToStream(AStream: TStream);
var
  stor : TRESTDWStorageBin;
begin
  stor := TRESTDWStorageBin.Create(nil);
  try
    stor.SaveToStream(Self,AStream);
  finally
    stor.Free;
  end;
end;

procedure TRESTDWMemTable.SetBookmarkData(Buffer: TRESTDWBuffer; Data: Pointer);
begin
  PRESTDWRecInfo(Buffer + FRecordSize)^.Bookmark := Integer(Data^);
end;

function TRESTDWMemTable.GetRecordCount: integer;
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

function TRESTDWMemTable.GetRecNo: Longint;
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
      {$IFDEF FPC}
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
  if not Active then
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
      InternalLoadCurrentRecord(Buffer);
      vAccepted := FCurrentRecordObj.Accept = 1;
      if vAccepted then
        GetCalcFields(Buffer);
	  end;

    if (GetMode = gmCurrent) and not vAccepted then
      Result:=grError;
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
    {$IFNDEF FPC}
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
        if vField <> nil then
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

  {$IFNDEF FPC}
    inherited;
  {$ENDIF}
end;

procedure TRESTDWMemTable.InternalInitRecord(Buffer: TRESTDWBuffer);
begin
  CheckActive;
  FillChar(Buffer^, FRecordBufferSize, 0);
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
var
  i : integer;
begin
  // eh mais rapido correr a lista ao contrario
  // pq nao tem que fazer deslocamento
  i := FRecords.Count - 1;
  while i >= 0 do begin
    TObject(FRecords.Items[i]).Free;
    FRecords.Delete(i);
    i := i - 1;
  end;
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
          sData1 := AnsiString(Data1);
          sData2 := AnsiString(Data2);
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

{
      if (Data1 = null) and (Data2 <> null) then
        Result := -1
      else if (Data1 <> null) and (Data2 = null) then
        Result := 1
      else if (Data1 < Data2) then
        Result := -1
      else if (Data1 > Data2) then
        Result := 1;
}
      if vDescendingSort then
        Result := -Result;

      if Result <> 0 then
        Exit;
    end;
  end;
end;

constructor TRESTDWMemTable.Create(AOwner: TComponent);
begin
  inherited;
  FStatusRecord := rsInserted;
  FRecordCount := 0;
  FFilterRecordCount := -1;
  FRecords := TList.Create;
  FBlobs := TList.Create;
end;

function TRESTDWMemTable.CreateBlobStream(Field: TField;
  Mode: TBlobStreamMode): TStream;
begin
  Result := TRESTDWBlobStream.Create(Self,Field as TBlobField,Mode);
end;

{$IFDEF FPC}
  procedure TRESTDWMemTable.DataEvent(Event: TDataEvent; Info: Ptrint);
{$ELSE}
  {$IF CompilerVersion < 21}
    procedure TRESTDWMemTable.DataEvent(Event: TDataEvent; Info: Longint);
  {$ELSE}
    procedure TRESTDWMemTable.DataEvent(Event: TDataEvent; Info: NativeInt);
  {$IFEND}
{$ENDIF}
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
      RefreshStates;
    end;
  end;

  if Event in [deDataSetChange,deCheckBrowseMode] then
    FFilterRecordCount := -1;

  inherited DataEvent(Event,Info);
end;

destructor TRESTDWMemTable.Destroy;
begin
  Close;

  if FFilterParser <> nil then
    FreeAndNil(FFilterParser);

  FreeIndexList;
  FRecords.Free;
  FBlobs.Free;
  inherited;
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
  Move(vBuffer^,vNull,Sizeof(vNull));
  Inc(vBuffer,Sizeof(vNull));

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

procedure TRESTDWMemTable.FreeRecordBuffer (var Buffer: TRESTDWBuffer);
begin
  FreeMem(Buffer);
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
  GetMem(Result, FRecordBufferSize);
end;

procedure TRESTDWMemTable.InternalDelete;
var
  vRec : TRESTDWRecord;
  vBuffer : TRESTDWBuffer;
  Accept : boolean;
begin
  vRec := GetRecordObj(FCurrentRecord);
  FRecords.Delete(FCurrentRecord);
  vRec.Free;

  if FCurrentRecord >= FRecords.Count then
    Dec(FCurrentRecord);
  Accept := True;
  repeat
    if Filtered then begin
      vRec := GetRecordObj(FCurrentRecord);
      vBuffer := vRec.CopyBuffer;
      Accept := FilterRecord(vBuffer);
      FreeMem(vBuffer);
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
  vRec : TRESTDWRecord;
begin
  InternalLast;
  vRec := TRESTDWRecord.Create(Self);
  Move(Buffer^,vRec.FBuffer^,FRecordBufferSize);

  // set status
  if FStatusRecordChanged then
    vRec.Status := FStatusRecord;

  FStatusRecord := rsInserted;
  FStatusRecordChanged := False;

  FRecords.Add(vRec);
  Inc(FRecordCount);
end;

{$IF (NOT DEFINED(FPC)) AND (CompilerVersion >= 21)}
  procedure TRESTDWMemTable.InternalAddRecord(Buffer: TRecBuf; Append: Boolean);
  begin
    InternalAddRecord(Pointer(Buffer),Append);
  end;

  procedure TRESTDWMemTable.InternalAddRecord(Buffer: TRESTDWBuffer;
    Append: Boolean);
  begin
    InternalAddRecord(Pointer(Buffer),Append);
  end;
{$IFEND}

procedure TRESTDWMemTable.InternalPost;
var
  vRec : TRESTDWRecord;
begin
  inherited InternalPost;

  CheckActive;
  if State = dsEdit then begin
    vRec := GetRecordObj(FCurrentRecord);
    Move(TRESTDWBuffer(ActiveBuffer)^,vRec.FBuffer^,FRecordBufferSize);

    if FStatusRecordChanged then
      vRec.Status := FStatusRecord;

    FStatusRecord := rsInserted;
    FStatusRecordChanged := False;
  end
  else begin
    // always append
    InternalAddRecord(TRESTDWBuffer(ActiveBuffer),True);
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
  i, p : integer;
  vBlobField : PRESTDWBlobField;
  vField : TField;
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
      vBuf := TRESTDWBuffer(FBuffer);
      p := FDataset.GetFieldOffsets(i);
      Inc(vBuf,p);
      Move(vBuf^,vBoolean,SizeOf(vBoolean));
      Inc(vBuf);

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
      Dec(vBuf,p+SizeOf(Boolean));
    end;
    i := i + 1;
  end;
end;

procedure TRESTDWRecord.clearRecInfo;
var
  p : integer;
  vRecInfo : PRESTDWRecInfo;
  vBuf : TRESTDWBuffer;
begin
  p := FDataset.GetRecordSize;
  vBuf := TRESTDWBuffer(FBuffer);
  Inc(vBuf,p);
  Move(vBuf^,vRecInfo,SizeOf(Pointer));

  try
    if vRecInfo <> nil then
      Dispose(vRecInfo);
  except
    // ja ta limpo
  end;
  Dec(vBuf,p);
end;

function TRESTDWRecord.CopyBuffer: Pointer;
begin
  GetMem(Result,FDataset.FRecordBufferSize);
  FillChar(Result^,FDataset.FRecordBufferSize,0);
  Move(FBuffer^,Result^,FDataset.FRecordBufferSize);
end;

procedure TRESTDWRecord.CopyBuffer(var Buffer: Pointer);
begin
  Move(FBuffer^,Buffer^,FDataset.FRecordBufferSize);
end;

constructor TRESTDWRecord.Create(AOwner : TRESTDWMemTable);
begin
  inherited Create;
  FDataset := AOwner;
  FAccept := 1;
  FStatus := rsInserted;

  GetMem(FBuffer,FDataset.FRecordBufferSize);
  FillChar(FBuffer^,FDataset.FRecordBufferSize,0);
end;

destructor TRESTDWRecord.Destroy;
begin
//  clearRecInfo;
  clearBlobsFields;
  FreeMem(FBuffer);
  FBuffer := nil;
  inherited;
end;

procedure TRESTDWRecord.setBuffer(const Value: Pointer);
begin
//  clearRecInfo;
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
  inherited;
end;

procedure TRESTDWBlobStream.FreeBlobField;
begin
  FDataSet.FBlobs.Remove(FBlobField);
  FreeMem(FBlobField^.Buffer, FBlobField^.Size);
  FBlobField^.Buffer := nil;
  FBlobField^.Size := 0;
  FModified := True;
end;

function TRESTDWBlobStream.Read(var Buffer; Count: Longint): Longint;
var
  P : Pointer;
begin
  if FBlobField <> nil then begin
    if FPosition + Count > FBlobField^.Size then
      Count := FBlobField^.Size - FPosition;
    {$IF (NOT DEFINED(FPC)) and (CompilerVersion < 21)}
      P := FBlobField.Buffer;
      Inc(PByte(P),FPosition);
    {$ELSE}
      P := FBlobField^.Buffer + FPosition;
    {$IFEND}
    Move(P^, Buffer, Count);
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
  {$IF (NOT DEFINED(FPC)) and (CompilerVersion < 21)}
    P := FBlobField^.Buffer;
    Inc(PByte(P),FPosition);
  {$ELSE}
    P := FBlobField^.Buffer + FPosition;
  {$IFEND}
  Move(Buffer, P^, Count);
  Inc(FBlobField^.Size, Count);
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
  vFileStream : TFileStream;
begin
  try
    vFileStream := TFileStream.Create(AFileName,fmCreate);
    try
      SaveToStream(ADataset,TStream(vFileStream));
    except

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
