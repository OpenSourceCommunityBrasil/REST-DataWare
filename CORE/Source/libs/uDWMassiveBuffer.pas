unit uDWMassiveBuffer;

{$I uRESTDW.inc}

interface

uses SysUtils,       Classes,      Variants,
     DB,             uRESTDWBase,  uDWConsts,
     uDWJSONTools,   uDWJSONInterface, uDWConstsData,
     uDWJSONObject,  uDWAbout,     uDWConstsCharset;

Const
 cJSONValue = '{"MassiveSQLMode":"%s", "SQL":"%s", "Params":"%s", "Bookmark":"%s", ' +
               '"BinaryRequest":"%s", "FetchRowSQL":"%s", "LockSQL":"%s", "UnlockSQL":"%s"}';

Type
 TMassiveType = (mtMassiveCache, mtMassiveObject);

Type
 TMassiveValue = Class(TObject)
 Private
  vIsNull,
  vModified,
  vBinary     : Boolean;
  vJSONValue  : TJSONValue;
  {$IFDEF FPC}
   vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  vValueName   : String;
  vObjectValue : TObjectValue;
  vEncoding    : TEncodeSelect;
  vOldValue    : Variant;
  Function    GetValue       : Variant;
  Procedure   SetValue(Value : Variant);
  Procedure   SetEncoding   (bValue : TEncodeSelect);
  Procedure   SetModified(Value : Boolean);
  Function    GetNullValue(Value : TObjectValue) : Variant;
  Procedure   SetObjectValue(Value : TObjectValue);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Function    IsNull : Boolean;
  Function    AsString : String;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Const Stream : TMemoryStream);
  Property    ValueName   : String       Read vValueName   Write vValueName;
  Property    ObjectValue : TObjectValue Read vObjectValue write SetObjectValue;
  Property    OldValue    : Variant      Read vOldValue    Write vOldValue;
  Property    Value       : Variant      Read GetValue     Write SetValue;
  Property    Binary      : Boolean      Read vBinary      Write vBinary;
  Property    Modified    : Boolean      Read vModified;
  {$IFDEF FPC}
  Property DatabaseCharSet : TDatabaseCharSet Read vDatabaseCharSet Write vDatabaseCharSet;
  {$ENDIF}
  Property Encoding          : TEncodeSelect  Read vEncoding        Write SetEncoding;
End;

Type
 PMassiveValue  = ^TMassiveValue;
 TMassiveValues = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveValue;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveValue); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveValue) : Integer;          Overload;
  Property   Items[Index  : Integer]       : TMassiveValue Read GetRec Write PutRec; Default;
End;

Type
 TMassiveField = Class(TObject)
 Private
  vMassiveFields : TList;
  vOldValue      : Variant;
  vIsNull,
  vReadOnly,
  vAutoGenerateValue,
  vRequired,
  vKeyField   : Boolean;
  vFieldName  : String;
  vFieldType  : TObjectValue;
  vFieldIndex,
  vSize,
  vPrecision  : Integer;
  Function    GetValue       : Variant;
  Function    GetOldValue    : Variant;
  Procedure   SetValue(Value : Variant);
  Function    GetModified    : Boolean;
 Protected
 Public
  Constructor Create(MassiveFields : TList; FieldIndex : Integer);
  Destructor  Destroy;Override;
  Function    IsNull : Boolean;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (var Stream : TMemoryStream);
  Property    Required          : Boolean      Read vRequired          Write vRequired;
  Property    AutoGenerateValue : Boolean      Read vAutoGenerateValue Write vAutoGenerateValue;
  Property    KeyField          : Boolean      Read vKeyField          Write vKeyField;
  Property    ReadOnly          : Boolean      Read vReadOnly          Write vReadOnly;
  Property    FieldType         : TObjectValue Read vFieldType         Write vFieldType;
  Property    FieldName         : String       Read vFieldName         Write vFieldName;
  Property    Size              : Integer      Read vSize              Write vSize;
  Property    Precision         : Integer      Read vPrecision         Write vPrecision;
  Property    OldValue          : Variant      Read GetOldValue        Write vOldValue;
  Property    Value             : Variant      Read GetValue           Write SetValue;
  Property    Modified          : Boolean      Read GetModified;
End;

Type
 PMassiveField  = ^TMassiveField;
 TMassiveFields = Class(TList)
 Private
  vMassiveDataset : TMassiveDataset;
  Function   GetRec(Index : Integer)       : TMassiveField;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveField); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Constructor Create(MassiveDataset : TMassiveDataset);
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Procedure  Delete(FieldName : String);                       Overload;
  Function   Add   (Item  : TMassiveField) : Integer;          Overload;
  Function   FieldByName(FieldName : String) : TMassiveField;
  Property   Items[Index  : Integer]       : TMassiveField Read GetRec Write PutRec; Default;
End;

Type
 TMassiveLine = Class(TObject)
 Private
  vMassiveValues  : TMassiveValues;
  vPrimaryValues  : TMassiveValues;
  vMassiveMode    : TMassiveMode;
  vDataExec,
  vChanges        : TStringList;
  vMassiveType    : TMassiveType;
  vDWParams       : TDWParams;
  Function   GetRec  (Index : Integer)       : TMassiveValue;
  Procedure  PutRec  (Index : Integer; Item  : TMassiveValue);
  Function   GetRecPK(Index : Integer)       : TMassiveValue;
  Procedure  PutRecPK(Index : Integer; Item  : TMassiveValue);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   ClearAll;
  Property    MassiveMode                     : TMassiveMode   Read vMassiveMode Write vMassiveMode;
  Property    UpdateFieldChanges              : TStringList    Read vChanges     Write vChanges;
  Property    MassiveType                     : TMassiveType   Read vMassiveType Write vMassiveType;
  Property    Params                          : TDWParams      Read vDWParams    Write vDWParams;
  Property    DataExec                        : TStringList    Read vDataExec    Write vDataExec;
  Property    Values       [Index  : Integer] : TMassiveValue  Read GetRec       Write PutRec;
  Property    PrimaryValues[Index  : Integer] : TMassiveValue  Read GetRecPK     Write PutRecPK;
End;

Type
 PMassiveLine   = ^TMassiveLine;
 TMassiveBuffer = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveLine;    Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveLine);   Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                         Overload;
  Function   Add   (Item  : TMassiveLine)  : Integer;         Overload;
  Property   Items[Index  : Integer]       : TMassiveLine Read GetRec Write PutRec; Default;
End;

//Massive reply queue
Type
 PMassiveReplyValue = ^TMassiveReplyValue;
 TMassiveReplyValue = Class(TObject)
 Private
  vOldNewValue,
  vOldValue     : Variant;
  vValueName    : String;
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Property    NewValue  : Variant Read vOldNewValue Write vOldNewValue;
  Property    OldValue  : Variant Read vOldValue    Write vOldValue;
  Property    ValueName : String  Read vValueName   Write vValueName;
End;

Type
 PMassiveReplyCache = ^TMassiveReplyCache;
 TMassiveReplyCache = Class(TList)
 Private
  vBuffername : String;
  Function   GetRec (Index  : Integer) : TMassiveReplyValue; Overload;
  Procedure  PutRec (Index  : Integer;
                     Item   : TMassiveReplyValue);           Overload;
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   Delete(Index  : Integer); Overload;
  Procedure   ClearAll;
  Function    ItemByValue(ValueName : String; OldValue : Variant) : TMassiveReplyValue;
  Function    Add   (Item   : TMassiveReplyValue) : Integer; Overload;
  Property    Buffername    : String                         Read vBuffername  Write vBuffername;
  Property    Values[Index  : Integer] : TMassiveReplyValue  Read GetRec       Write PutRec;
End;

Type
 PMassiveReply = ^TMassiveReply;
 TMassiveReply = Class(TList)
 Private
  Function   GetRec(Index : Integer) : TMassiveReplyCache; Overload;
  Procedure  PutRec(Index : Integer;
                    Item  : TMassiveReplyCache);           Overload;
  Procedure  ClearAll;
  Function  GetRecName(Index : String)  : TMassiveReplyCache; Overload;
  Procedure PutRecName(Index : String;
                       Item  : TMassiveReplyCache); Overload;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                      Overload;
  Function   Add   (Item  : TMassiveReplyCache) : Integer; Overload;
  Procedure  AddBufferValue(Buffername,
                            ValueName           : String;
                            OldValue,
                            NewValue            : Variant);
  Procedure  UpdateBufferValue(Buffername,
                               ValueName        : String;
                               OldValue,
                               NewValue         : Variant);
  Function   GetReplyValue (Buffername,
                            ValueName           : String;
                            MyValue             : Variant) : TMassiveReplyValue;
  Property   Items      [Index  : Integer]      : TMassiveReplyCache Read GetRec Write PutRec;
  Property   ItemsString[Index  : String]       : TMassiveReplyCache Read GetRecName Write PutRecName;
End;

Type
 TMassiveDatasetBuffer = Class(TMassiveDataset)
 Protected
  vLastOpen        : Integer;
  vDataset         : TRESTDWClientSQLBase;
  vRecNo           : Integer;
  vMassiveBuffer   : TMassiveBuffer;
  vMassiveLine     : TMassiveLine;
  vMassiveFields   : TMassiveFields;
  vMassiveMode     : TMassiveMode;
  vCreateBuffer,
  vOnLoad          : Boolean;
  vMyCompTag,
  vMasterCompTag,
  vMasterCompFields,
  vSequenceName,
  vSequenceField,
  vTableName       : String;
  {$IFDEF FPC}
  vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  vEncoding        : TEncodeSelect;
  vReflectChanges  : Boolean;
  vMassiveReply    : TMassiveReply;
  vMassiveType     : TMassiveType;
  vDataexec        : TStringList;
  vDWParams        : TDWParams;
 Private
  vMasterFields,
  vDetailFields    : TStringList;
  Procedure ReadStatus;
  Procedure NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                          MassiveModeData     : TMassiveMode;
                          ExecTag             : Boolean = False);
  Procedure SetEncoding          (bValue      : TEncodeSelect);
  Procedure BuildCompFields(MasterCompFields  : String);
  Procedure MassiveCheck(Dataset : TRESTDWClientSQLBase);
 Public
  Constructor Create(Dataset : TRESTDWClientSQLBase);
  Destructor  Destroy;Override;
  Function  RecNo       : Integer;
  Function  RecordCount : Integer;
  Procedure First;
  Procedure Prior;
  Procedure Next;
  Procedure Last;
  Property  TempBuffer  : TMassiveLine     Read vMassiveLine;
  Function  PrimaryKeys : TStringList;
  Function  AtualRec    : TMassiveLine;
  Procedure NewBuffer   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeData      : TMassiveMode;
                         ExecTag              : Boolean = False); Overload;
  Procedure NewBuffer   (Var MassiveLineBuff  : TMassiveLine;
                         MassiveModeData      : TMassiveMode;
                         ExecTag              : Boolean = False); Overload;
  Procedure NewBuffer   (MassiveModeData      : TMassiveMode;
                         ExecTag              : Boolean = False); Overload;
  Procedure BuildDataset(Dataset              : TRESTDWClientSQLBase;
                         UpdateTableName      : String);                 //Constroi o Dataset Massivo
  Procedure BuildLine   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeBuff      : TMassiveMode;
                         Var MassiveLineBuff  : TMassiveLine;
                         UpdateTag            : Boolean = False;
                         ExecTag              : Boolean = False);
  Procedure BuildBuffer (Dataset              : TRESTDWClientSQLBase;    //Cria um Valor Massivo Baseado nos Dados de Um Dataset
                         MassiveMode          : TMassiveMode;
                         UpdateTag            : Boolean = False;
                         ExecTag              : Boolean = False);
  Procedure SaveBuffer  (Dataset              : TRESTDWClientSQLBase;
                         ExecTag              : Boolean = False);   //Salva Um Buffer Massivo na Lista de Massivos
  Procedure ClearBuffer;                                                //Limpa o Buffer Massivo Atual
  Procedure ClearDataset;                                               //Limpa Todo o Dataset Massivo
  Procedure ClearLine;                                                  //Limpa o Buffer Temporario
  Function  ToJSON          : String;                                   //Gera o JSON do Dataset Massivo
  Procedure FromJSON (Value : String);                                  //Carrega o Dataset Massivo a partir de um JSON
  Function  MasterFieldFromDetail(Field      : String) : String;
  Property  MassiveMode     : TMassiveMode     Read vMassiveMode     Write vMassiveMode;   //Modo Massivo do Buffer Atual
  Property  MassiveType     : TMassiveType     Read vMassiveType     Write vMassiveType;
  Property  Fields          : TMassiveFields   Read vMassiveFields   Write vMassiveFields;
  Property  Dataexec        : TStringList      Read vDataexec        Write vDataexec;
  Property  Params          : TDWParams        Read vDWParams        Write vDWParams;
  Property  TableName       : String           Read vTableName;
  Property  OnLoad          : Boolean          Read vOnLoad;
  {$IFDEF FPC}
  Property DatabaseCharSet  : TDatabaseCharSet Read vDatabaseCharSet Write vDatabaseCharSet;
  {$ENDIF}
  Property Encoding         : TEncodeSelect    Read vEncoding        Write SetEncoding;
  Property SequenceName     : String           Read vSequenceName    Write vSequenceName;
  Property SequenceField    : String           Read vSequenceField   Write vSequenceField;
  Property ReflectChanges   : Boolean          Read vReflectChanges  Write vReflectChanges;
  Property LastOpen         : Integer          Read vLastOpen        Write vLastOpen;
  Property MassiveReply     : TMassiveReply    Read vMassiveReply    Write vMassiveReply;
  Property MyCompTag        : String           Read vMyCompTag;
  Property MasterCompTag    : String           Read vMasterCompTag;
  Property MasterCompFields : String           Read vMasterCompFields;
 End;

Type
 TDWMassiveCacheValue = String;

Type
 PMassiveCacheValue  = ^TDWMassiveCacheValue;
 TDWMassiveCacheList = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TDWMassiveCacheValue;     Overload;
  Procedure  PutRec(Index : Integer; Item  : TDWMassiveCacheValue);    Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                  Overload;
  Function   Add   (Item  : TDWMassiveCacheValue) : Integer;           Overload;
  Property   Items[Index  : Integer]            : TDWMassiveCacheValue Read GetRec Write PutRec; Default;
End;

Type
 TMassiveCacheDataset  = TDataset;
 PMassiveCacheDataset  = ^TMassiveCacheDataset;
 TDWMassiveCacheDatasetList = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveCacheDataset;       Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveCacheDataset);      Overload;
  Procedure  ClearAll;
  Function   DatasetExists(Value : TMassiveCacheDataset) : Integer;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                    Overload;
  Function   Add   (Item  : TMassiveCacheDataset) : Integer;             Overload;
  Function   GetDataset(Dataset : String)         : TMassiveCacheDataset;
  Property   Items      [Index  : Integer]  : TMassiveCacheDataset Read GetRec       Write PutRec; Default;
End;

Type
 TDWMassiveCache = Class(TComponent)
 Private
  MassiveCacheList        : TDWMassiveCacheList;
  MassiveCacheDatasetList : TDWMassiveCacheDatasetList;
  vReflectChanges         : Boolean;
  vMassiveType            : TMassiveType;
 Public
  Function    MassiveCount      : Integer;
  Function    ToJSON            : String;
  Procedure   Add(Value         : String;
                  Const Dataset : TDataset);
  Procedure   ProcessChanges(Value : String);
  Procedure   Clear;
  Constructor Create(AOwner     : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property    MassiveType       : TMassiveType Read vMassiveType    Write vMassiveType;
  Property    ReflectChanges    : Boolean      Read vReflectChanges Write vReflectChanges;
End;

Type
 TDWMassiveCacheSQLValue = Class(TCollectionItem)
 Private
  vMassiveSQLMode : TMassiveSQLMode;
  vFetchRowSQL,
  vLockSQL,
  vUnlockSQL,
  vSQL            : TStringList;
  vBookmark       : String;
  vParams         : TParams;
  vParamCount     : Integer;
  vBinaryRequest  : Boolean;
  FMemDS          : TMemoryStream;
  Procedure CreateParams;
  Procedure SetSQL       (Value   : TStringList);
  Procedure OnChangingSQL(Sender  : TObject);
  Procedure SetMemDS (Const Value : TMemoryStream);
 Public
  Constructor Create (aCollection : TCollection);Override;
  Destructor  Destroy;Override;
  Function    ParamByName  (Value : String) : TParam;    //Retorna o Parametro de Acordo com seu nome
  Property  ParamCount            : Integer           Read vParamCount;
  Property  MemDS                 : TMemoryStream     Read FMemDS          Write SetMemDS;
 Published
  Property MassiveSQLMode         : TMassiveSQLMode   Read vMassiveSQLMode Write vMassiveSQLMode;
  Property SQL                    : TStringList       Read vSQL            Write SetSQL;                  //SQL a ser Executado
  Property FetchRowSQL            : TStringList       Read vFetchRowSQL    Write vFetchRowSQL;            //SQL a ser Executado
  Property LockSQL                : TStringList       Read vLockSQL        Write vLockSQL;                //SQL a ser Executado
  Property UnlockSQL              : TStringList       Read vUnlockSQL      Write vUnlockSQL;              //SQL a ser Executado
  Property Bookmark               : String            Read vBookmark       Write vBookmark;
  Property BinaryRequest          : Boolean           Read vBinaryRequest  Write vBinaryRequest;
  Property Params                 : TParams           Read vParams         Write vParams;
End;

Type
 PMassiveCacheSQLValue  = ^TDWMassiveCacheSQLValue;
 TDWMassiveCacheSQLList = Class(TDWOwnedCollection)
 Private
  fOwner                  : TPersistent;
  vEncoding               : TEncodeSelect;
  Function   GetOwner     : TPersistent; override;
  Function   GetRec(Index : Integer)       : TDWMassiveCacheSQLValue;     Overload;
  Procedure  PutRec(Index : Integer; Item  : TDWMassiveCacheSQLValue);    Overload;
  Procedure  ClearAll;
 Protected
 Public
  Constructor Create     (AOwner      : TPersistent;
                          aItemClass  : TCollectionItemClass);
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                                     Overload;
  Function   ToJSON       : String;
  Function   Add                     : TCollectionItem;
  Property   Encoding     : TEncodeSelect                      Read vEncoding Write vEncoding;
  Property   Items[Index  : Integer] : TDWMassiveCacheSQLValue Read GetRec    Write PutRec; Default;
End;

Type
 TDWMassiveSQLCache = Class(TDWComponent)
 Private
  vEncoding            : TEncodeSelect;
  vMassiveCacheSQLList : TDWMassiveCacheSQLList;
  Procedure   SetEncoding(Value : TEncodeSelect);
 Public
  Function    MassiveCount   : Integer;
  Function    ToJSON         : String;
  Function    ParamsToBin(Params              : TParams) : String;
  Procedure   Clear;
  Procedure   Store     (MassiveCacheSQLValue : TDWMassiveCacheSQLValue);Overload;
  Procedure   Store     (SQL                  : String; Dataset              : TDataset);               Overload;
  procedure   Store     (MemDS                : TMemoryStream); OverLoad;
  Constructor Create    (AOwner               : TComponent);             Override;//Cria o Componente
  Destructor  Destroy;Override;                                                   //Destroy a Classe
 Published
  Property Encoding   : TEncodeSelect          Read vEncoding            Write SetEncoding;
  Property CachedList : TDWMassiveCacheSQLList Read vMassiveCacheSQLList Write vMassiveCacheSQLList;
End;

Type
 TMassiveProcess     = Procedure(Var MassiveDataset : TMassiveDatasetBuffer;
                                 Var Ignore         : Boolean) Of Object;
 TMassiveEvent       = Procedure(Var MassiveDataset : TMassiveDatasetBuffer) Of Object;
 TMassiveLineProcess = Procedure(Var MassiveDataset : TMassiveDatasetBuffer;
                                 Dataset            : TDataset) Of Object;

implementation


Uses uRESTDWPoolerDB, uDWPoolerMethod, PropertyPersist;


Function removestr(Astr: string; Asubstr: string):string;
Begin
 result:= stringreplace(Astr,Asubstr,'',[rfReplaceAll, rfIgnoreCase]);
End;

{ TMassiveField }

Function    TMassiveField.IsNull : Boolean;
Begin
 Result := (vIsNull) and varIsNull(Value);
End;

Constructor TMassiveField.Create(MassiveFields : TList; FieldIndex : Integer);
Begin
 vRequired          := False;
 vAutoGenerateValue := False;
 vReadOnly          := False;
 vIsNull            := True;
 vKeyField          := vRequired;
 vFieldType         := ovUnknown;
 vFieldName         := '';
 vOldValue          := Null;
 vMassiveFields     := MassiveFields;
 vFieldIndex        := FieldIndex;
End;

Destructor TMassiveField.Destroy;
Begin
 Inherited;
End;

Procedure TMassiveField.LoadFromStream(Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].LoadFromStream(Stream);
  End;
End;

Procedure TMassiveField.SaveToStream(var Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].SaveToStream(Stream);
  End;
End;

Procedure TMassiveField.SetValue(Value: Variant);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].ValueName      := vFieldName;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].ObjectValue    := vFieldType;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].vJSONValue.ObjectValue := vFieldType;
   If Not TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].isnull Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].OldValue      := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value
   Else
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].OldValue      := Null;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value          := Value;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].SetModified(True);
   vIsNull := VarIsNull(Value);
  End;
End;

Function TMassiveField.GetModified : Boolean;
Var
 vRecNo : Integer;
Begin
 Result := False;
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Modified;
  End;
End;

Function TMassiveField.GetOldValue    : Variant;
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].vJSONValue.ObjectValue := vFieldType;
   If Not TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].isNull Then
    Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].OldValue
   Else
    Result := Null;
  End;
End;

Function TMassiveField.GetValue : Variant;
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].vJSONValue.ObjectValue := vFieldType;
   If Not TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].isNull Then
    Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value
   Else
    Result := Null;
  End;
End;

{ TMassiveFields }

Function TMassiveFields.Add(Item: TMassiveField): Integer;
Var
 vItem : ^TMassiveField;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveFields.Delete(FieldName : String);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count -1 Do
  Begin
   If Uppercase(Self.Items[I].vFieldName) =
      Uppercase(FieldName) Then
    Begin
     Self.Delete(I);
     Break;
    End;
  End;
End;

Procedure TMassiveFields.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveField(TList(Self).Items[Index]^)) Then
      Begin
       {$IFDEF FPC}
       FreeAndNil(TList(Self).Items[Index]^);
       {$ELSE}
        {$IF CompilerVersion > 33}
         FreeAndNil(TMassiveField(TList(Self).Items[Index]^));
         {$ELSE}
         FreeAndNil(TList(Self).Items[Index]^);
        {$IFEND}
       {$ENDIF}
      End;
     {$IFDEF FPC}
      Dispose(PMassiveField(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TMassiveFields.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TMassiveFields.Create(MassiveDataset: TMassiveDataset);
Begin
 Inherited Create;
 vMassiveDataset := MassiveDataset;
End;

Destructor TMassiveFields.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveFields.FieldByName(FieldName : String): TMassiveField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   If LowerCase(TMassiveField(TList(Self).Items[I]^).vFieldName) =
      LowerCase(FieldName) Then
    Begin
     Result := TMassiveField(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Function TMassiveFields.GetRec(Index : Integer) : TMassiveField;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveField(TList(Self).Items[Index]^);
End;

Procedure TMassiveFields.PutRec(Index : Integer; Item : TMassiveField);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveField(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveValue }

Constructor TMassiveValue.Create;
Begin
 vBinary    := False;
 vIsNull    := True;
 vModified  := False;
 vOldValue  := Null;
 vJSONValue := TJSONValue.Create;
End;

Function   TMassiveValue.AsString : String;
Begin
 Result := vJSONValue.AsString;
End;

Function   TMassiveValue.IsNull : Boolean;
Begin
 Result := vIsNull;
End;

Destructor TMassiveValue.Destroy;
Begin
 If Assigned(vJSONValue) Then
  FreeAndNil(vJSONValue);
 Inherited;
End;

Procedure TMassiveValue.SetObjectValue(Value : TObjectValue);
Begin
 vObjectValue           := Value;
 vJSONValue.ObjectValue := vObjectValue;
End;

Function TMassiveValue.GetNullValue(Value : TObjectValue) : Variant;
Begin
 Case Value Of
  ovVariant,
  ovUnknown         : Result := Null;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo         : Result := '';
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Result := 0;
  ovSingle,
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Result := 0;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Result := 0;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Result := Null;
 End;
End;

Function TMassiveValue.GetValue: Variant;
Begin
 Result := vJSONValue.Value;
 If VarIsNull(Result) Then
  Result := GetNullValue(vJSONValue.ObjectValue);
End;

Procedure TMassiveValue.LoadFromStream(Stream: TMemoryStream);
Begin
 vBinary := True;
 vJSONValue.Encoding := vEncoding;
 If vJSONValue <> Nil Then
  Begin
   vJSONValue.Binary  := vBinary;
   {$IFDEF FPC}
   vJSONValue.DatabaseCharSet := csUndefined;
   {$ENDIF}
   vJSONValue.LoadFromStream(Stream);
  End;
 vIsNull := vJSONValue.IsNull;
End;

Procedure TMassiveValue.SaveToStream(Const Stream: TMemoryStream);
Begin
 vJSONValue.ObjectValue := ovBlob;
 vJSONValue.Encoded     := True;
 vJSONValue.SaveToStream(Stream, True);
End;

Procedure TMassiveValue.SetModified(Value : Boolean);
Begin
 vModified := Value;
End;

Procedure TMassiveValue.SetEncoding(bValue: TEncodeSelect);
Begin
 vEncoding := bValue;
End;

Procedure TMassiveValue.SetValue(Value: Variant);
Begin
 vJSONValue.Encoding := vEncoding;
 vIsNull             := varIsNull(Value);
 If vJSONValue <> Nil Then
  Begin
   vJSONValue.Binary  := vBinary;
   {$IFDEF FPC}
   vJSONValue.DatabaseCharSet := csUndefined;
   {$ENDIF}
   If vJSONValue.Binary Then
    Begin
     vJSONValue.ObjectValue := ovBlob;
     vJSONValue.SetValue(Value, False);
     vJSONValue.Encoded := True;
    End
   Else
    vJSONValue.SetValue(Value);
  End;
 vIsNull := vJSONValue.IsNull;
End;

{ TMassiveValues }

Function TMassiveValues.Add(Item: TMassiveValue): Integer;
Var
 vItem : ^TMassiveValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveValues.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Procedure TMassiveValues.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveValue(TList(Self).Items[Index]^)) Then
      Begin
       Try
        If Assigned(TMassiveValue(TList(Self).Items[Index]^)) Then
         FreeAndNil(TMassiveValue(TList(Self).Items[Index]^));
        {$IFDEF FPC}
         Dispose(PMassiveValue(TList(Self).Items[Index]));
        {$ELSE}
         Dispose(TList(Self).Items[Index]);
        {$ENDIF}
       Except
       End;
      End;
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveValues.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveValues.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(Self).Items[Index]^);
End;

Procedure TMassiveValues.PutRec(Index: Integer; Item: TMassiveValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveValue(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveLine }

Constructor TMassiveLine.Create;
Begin
 vMassiveValues  := TMassiveValues.Create;
 vMassiveMode    := mmBrowse;
 vChanges        := TStringList.Create;
 vDataExec       := TStringList.Create;
 vMassiveType    := mtMassiveCache;
 vDWParams       := TDWParams.Create;
End;

Destructor TMassiveLine.Destroy;
Begin
 If Assigned(vMassiveValues) Then
  FreeAndNil(vMassiveValues);
 If Assigned(vChanges) Then
  FreeAndNil(vChanges);
 If Assigned(vPrimaryValues) Then
  FreeAndNil(vPrimaryValues);
 If Assigned(vDataExec) Then
  FreeAndNil(vDataExec);
 If Assigned(vDWParams) Then
  FreeAndNil(vDWParams);
 Inherited;
End;

Function TMassiveLine.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(vMassiveValues).Items[Index]^);
End;

Function TMassiveLine.GetRecPK(Index : Integer) : TMassiveValue;
Begin
 Result := Nil;
 If vPrimaryValues <> Nil Then
  If (Index < vPrimaryValues.Count) And (Index > -1) Then
   Result := TMassiveValue(TList(vPrimaryValues).Items[Index]^);
End;

Procedure TMassiveLine.ClearAll;
Begin
 vMassiveValues.ClearAll;
 If Assigned(vPrimaryValues) Then
  vPrimaryValues.ClearAll;
 If Assigned(vChanges)       Then
  If vChanges.Count > 0      Then
   vChanges.Clear;
End;

Procedure TMassiveLine.PutRec(Index: Integer;   Item : TMassiveValue);
Begin
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  Begin
   TMassiveValue(TList(vMassiveValues).Items[Index]^) := Item;
   TMassiveValue(TList(vMassiveValues).Items[Index]^).SetModified(True);
  End;
End;

Procedure TMassiveLine.PutRecPK(Index: Integer; Item : TMassiveValue);
Begin
 If (Index < vPrimaryValues.Count) And (Index > -1) Then
  TMassiveValue(TList(vPrimaryValues).Items[Index]^) := Item;
End;

{ TMassiveBuffer }

Function TMassiveBuffer.Add(Item : TMassiveLine): Integer;
Var
 vItem : ^TMassiveLine;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveBuffer.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Procedure TMassiveBuffer.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   {$IFDEF FPC}
   If (Index < Self.Count -1) Then
   {$ENDIF}
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     Try
      If Assigned(TMassiveLine(TList(Self).Items[Index]^)) Then
       FreeAndNil(TMassiveLine(TList(Self).Items[Index]^));
      {$IFDEF FPC}
       Dispose(PMassiveLine(TList(Self).Items[Index]));
      {$ELSE}
       Dispose(TList(Self).Items[Index]);
      {$ENDIF}
     Except
     End;
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveBuffer.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveBuffer.GetRec(Index: Integer): TMassiveLine;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveLine(TList(Self).Items[Index]^);
End;

Procedure TMassiveBuffer.PutRec(Index: Integer; Item: TMassiveLine);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveLine(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveDatasetBuffer }

Procedure TMassiveDatasetBuffer.NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                                              MassiveModeData     : TMassiveMode;
                                              ExecTag             : Boolean = False);
Var
 I            : Integer;
 MassiveValue : TMassiveValue;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 If ExecTag Then
  MassiveLineBuff.MassiveType := mtMassiveObject;
 If ExecTag Then
  Begin
   MassiveLineBuff.vDataExec.Text := vDataexec.Text;
   MassiveLineBuff.Params.Clear;
   MassiveLineBuff.Params.CopyFrom(vDWParams);
  End
 Else
  Begin
   For I := 0 To vMassiveFields.Count Do
    Begin
     MassiveValue          := TMassiveValue.Create;
     MassiveValue.Encoding := vEncoding;
     If (vMassiveFields.Count > I) And (I > 0) Then
      Begin
       MassiveValue.ValueName              := vMassiveFields.Items[I -1].FieldName;
       MassiveValue.ObjectValue            := vMassiveFields.Items[I -1].vFieldType;
       MassiveValue.vJSONValue.ObjectValue := MassiveValue.ObjectValue;
      End;
     {$IFDEF FPC}
     MassiveValue.DatabaseCharSet := DatabaseCharSet;
     {$ENDIF}
     If I = 0 Then
      MassiveValue.Value := MassiveModeToString(MassiveModeData);
     MassiveLineBuff.vMassiveValues.Add(MassiveValue);
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.BuildLine(Dataset             : TRESTDWClientSQLBase;
                                          MassiveModeBuff     : TMassiveMode;
                                          Var MassiveLineBuff : TMassiveLine;
                                          UpdateTag           : Boolean = False;
                                          ExecTag             : Boolean = False);
 Procedure CopyValue(MassiveModeBuff : TMassiveMode);
 Var
  I, A          : Integer;
  vFieldList    : TStringList;
  Field         : TField;
  vStringStream : TMemoryStream;
  vUpdateCase   : Boolean;
  MassiveValue  : TMassiveValue;
  vBookmark,
  vTagkey       : String;
  Function MasssiveFieldsCount : Integer;
  Var
   I : Integer;
  Begin
   Result := 0;
   vFieldList.Clear;
   For I := 0 To vMassiveFields.Count -1 Do
    Begin
     Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
     If Field <> Nil Then
      Begin
       If Field.FieldKind = fkData Then
        Begin
         vFieldList.Add(vMassiveFields.Items[I].vFieldName);
         Result := Result + 1;
        End;
      End;
    End;
  End;
 Begin
  vStringStream := Nil;
  vUpdateCase   := False;
  vFieldList    := TStringList.Create;
  //KeyValues to Update
  If MassiveModeBuff = mmUpdate Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues = Nil;
  If MassiveLineBuff.vPrimaryValues <> Nil Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues.Count = 0;
  A   := MasssiveFieldsCount;
  Try
  If MassiveLineBuff.vMassiveValues.Count > 1 Then
   Begin
    MassiveLineBuff.vChanges.Clear;
    For I := 0 To vFieldList.Count -1 Do
     Begin
      Field := Dataset.FindField(vFieldList[I]);
      If Field <> Nil Then
       Begin
        If (Field.ProviderFlags = []) Then //Or (Field.ReadOnly) Then
         Continue;
        MassiveLineBuff.vMassiveValues.Items[I + 1].vJSONValue.ObjectValue := FieldTypeToObjectValue(Field.DataType);
        If MassiveModeBuff = mmDelete Then
         If Not(pfInKey in Field.ProviderFlags) Then
          Continue;
        //KeyValues to Update
        If (MassiveModeBuff = mmUpdate)      And
           (vUpdateCase)                     Then
         If (pfInKey in Field.ProviderFlags) Then
          Begin
           If MassiveLineBuff.vPrimaryValues = Nil Then
            MassiveLineBuff.vPrimaryValues := TMassiveValues.Create;
           If vUpdateCase Then
            Begin
             MassiveValue  := TMassiveValue.Create;
             MassiveValue.ObjectValue := FieldTypeToObjectValue(Field.DataType);
             MassiveValue.Encoding := Encoding;
             If Field.DataType in [ftBytes, ftVarBytes,
                                   ftBlob, ftGraphic,
                                   ftOraBlob, ftOraClob] Then
              Begin
               vStringStream := TMemoryStream.Create;
               Try
                If Not Field.IsNull Then
                 Begin
                  TBlobField(Field).SaveToStream(vStringStream);
                  vStringStream.Position := 0;
                  MassiveValue.LoadFromStream(vStringStream);
                  MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                 End
                Else
                 MassiveValue.Value := Null;
               Finally
                If Assigned(vStringStream) Then
                 FreeAndNil(vStringStream);
               End;
              End
             Else if Field.DataType in [ftDate, ftTime,ftDateTime, ftTimeStamp] then     // ajuste massive
              MassiveValue.Value := Field.AsDateTime
             Else if Trim(Field.AsString) <> '' Then
              MassiveValue.Value := Field.AsString;
             MassiveValue.ValueName   := Field.FieldName;
             MassiveLineBuff.vPrimaryValues.Add(MassiveValue);
            End;
          End;
        Case Field.DataType Of
         {$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
         ftFixedChar, ftFixedWideChar,
         {$IFEND}{$ENDIF}
         ftString,    ftWideString,
         ftMemo {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         , ftWideMemo
         {$IFEND}
         {$ELSE}
         , ftWideMemo
         {$ENDIF}                  : Begin
                                      If Not UpdateTag Then
                                       Begin
                                        If Field.IsNull Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                                        Else If Field.Size > 0 Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Copy(Field.AsString, 1, Field.Size)
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                       End
                                      Else
                                       Begin
                                        If (MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)   Then
                                         Begin
                                          MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.Value;
                                          MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                         End;
                                       End;
                                     End;
         ftInteger, ftSmallInt,
         ftWord,    ftLargeint
         {$IFNDEF FPC}{$if CompilerVersion > 21}, ftLongWord{$IFEND}{$ENDIF}
                                   : Begin
                                      If Not UpdateTag Then
                                       Begin
                                        If Field.IsNull Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                                        Else If Trim(Field.AsString) <> '' Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString)
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                       End
                                      Else
                                       Begin
                                        If Field.IsNull Then
                                         Begin
                                          MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                                          MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName)); // ELOY - Add to BufferChanges
                                         End
                                        Else
                                         Begin
                                          If ((MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)    Or
                                              (MassiveLineBuff.vMassiveValues.Items[I + 1].isnull <> Field.IsNull)) Then
                                           Begin
                                            MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString);
                                            MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                           End;
                                         End;
                                       End;
                                     End;
         ftFloat,
         ftCurrency, ftBCD{$IFNDEF FPC}
                          {$IF CompilerVersion > 21}
                           , ftSingle, ftFMTBcd
                          {$IFEND}
                          {$ENDIF} : Begin
                                      If Not UpdateTag Then
                                       Begin
                                        If Field.IsNull Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                                        Else If Trim(Field.AsString) <> '' Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := BuildStringFloat(Field.AsString)
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                       End
                                      Else
                                       Begin
                                        If Field.IsNull Then
                                         Begin
                                          MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                                          MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName)); // ELOY - Add to BufferChanges
                                         End
                                        Else
                                         Begin
                                          If ((MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)    Or
                                              (MassiveLineBuff.vMassiveValues.Items[I + 1].isnull <> Field.IsNull)) Then
                                           Begin
                                            If Trim(Field.AsString) <> '' Then
                                             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := BuildStringFloat(Field.AsString)
                                            Else
                                             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                                            MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                           End;
                                         End;
                                       End;
                                     End;
         ftDate, ftTime,
         ftDateTime, ftTimeStamp   : Begin
                                      If Not UpdateTag Then
                                       Begin
                                        If Field.IsNull Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null
                                        Else If Trim(Field.AsString) <> '' Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsDateTime
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                       End
                                      Else
                                       Begin
                                        If Field.IsNull Then
                                         Begin
                                          If Not MassiveLineBuff.vMassiveValues.Items[I + 1].IsNull  then
                                           Begin
                                            MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                                            MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName)); // ELOY - Add to BufferChanges
                                           End
                                          Else
                                           MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                                         End
                                        Else
                                         Begin
                                          If  ((MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value)   Or
                                              (MassiveLineBuff.vMassiveValues.Items[I + 1].isnull <> Field.IsNull)) Then
                                           Begin
                                            If Trim(Field.AsString) <> '' Then
                                             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsDateTime
                                            Else
                                             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                                            MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                           End;
                                         End;
                                       End;
                                     End;
         ftBytes, ftVarBytes,
         ftBlob, ftGraphic,
         ftOraBlob, ftOraClob      : Begin
                                      vStringStream := TMemoryStream.Create;
                                      Try
                                       If Not Field.IsNull Then
                                        Begin
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Binary := True;
                                         TBlobField(Field).SaveToStream(vStringStream);
                                         vStringStream.Position := 0;
                                         If Not UpdateTag Then
                                          MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Encodeb64Stream(vStringStream) //StreamToHex(vStringStream)
                                         Else
                                          Begin
                                           If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Encodeb64Stream(vStringStream) Then //StreamToHex(vStringStream) Then
                                            Begin
                                             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Encodeb64Stream(vStringStream); //StreamToHex(vStringStream);
                                             MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                            End;
                                          End;
                                        End
                                       Else
                                        Begin
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Null;
                                         MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                        End;
                                      Finally
                                       If Assigned(vStringStream) Then
                                        FreeAndNil(vStringStream);
                                      End;
                                     End;
         Else
          Begin
           If Not UpdateTag Then
            MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.Value
           Else
            Begin
             If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.Value Then
              Begin
               MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.Value;
               MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
              End;
            End;
          End;
        End;
       End;
     End;
   End;
  Finally
   If MassiveLineBuff.vMassiveValues.Count > 1 Then
   If vReflectChanges Then
    Begin
     If Dataset is TRESTDWClientSQL Then
      Begin
       If TRESTDWClientSQL(Dataset).RecNo > 0 Then
        Begin
         Try
          vBookmark := BookmarkToHex(TByteArr(TRESTDWClientSQL(Dataset).Bookmark));
         Except
         End;
         vTagkey := IntToStr(vLastOpen) + '|' + EncodeStrings(vBookmark{$IFDEF FPC}, csUndefined{$ENDIF});
         MassiveLineBuff.vMassiveValues.Items[MassiveLineBuff.vMassiveValues.Count -1].Value := EncodeStrings(vTagKey{$IFDEF FPC}, csUndefined{$ENDIF});
        End;
      End
     Else If Dataset is TRESTDWTable Then
      Begin
       If TRESTDWTable(Dataset).RecNo > 0 Then
        Begin
         Try
          vBookmark := BookmarkToHex(TByteArr(TRESTDWTable(Dataset).Bookmark));
         Except
         End;
         vTagkey := IntToStr(vLastOpen) + '|' + EncodeStrings(vBookmark{$IFDEF FPC}, csUndefined{$ENDIF});
         MassiveLineBuff.vMassiveValues.Items[MassiveLineBuff.vMassiveValues.Count -1].Value := EncodeStrings(vTagKey{$IFDEF FPC}, csUndefined{$ENDIF});
        End;
      End;
    End;
   vFieldList.Free;
  End;
 End;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeBuff;
 Case MassiveModeBuff Of
  mmInsert : CopyValue(MassiveModeBuff);
  mmUpdate : CopyValue(MassiveModeBuff);
  mmDelete : Begin
              NewBuffer(MassiveModeBuff, ExecTag);
              CopyValue(MassiveModeBuff);
             End;
  mmExec   : NewBuffer(MassiveModeBuff, ExecTag);
 End;
End;

Function TMassiveDatasetBuffer.AtualRec : TMassiveLine;
Begin
 Result := Nil;
 If RecordCount > 0 Then
  Result := vMassiveBuffer.Items[vRecNo -1];
End;

Procedure TMassiveDatasetBuffer.MassiveCheck(Dataset : TRESTDWClientSQLBase);
Var
 I : Integer;
 MassiveField : TMassiveField;
Begin
 vMasterCompTag    := '';
 vMyCompTag        := Dataset.Componenttag;
 If Dataset is TRESTDWClientSQL Then
  Begin
   If TRESTDWClientSQL(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWClientSQL(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWClientSQL(Dataset).RelationFields.Text;
  End
 Else If Dataset is TRESTDWTable Then
  Begin
   If TRESTDWTable(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWTable(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWTable(Dataset).RelationFields.Text;
  End;
 vSequenceName     := Dataset.SequenceName;
 vSequenceField    := Dataset.SequenceField;
 For I := 0 To Dataset.Fields.Count -1 Do
  Begin
   If ((Dataset.Fields[I].FieldKind = fkData)             And
       ((pfInUpdate in Dataset.Fields[I].ProviderFlags)   Or
        (pfInWhere  in Dataset.Fields[I].ProviderFlags)   Or
        (pfInKey    in Dataset.Fields[I].ProviderFlags))) Or
      (vReflectChanges And ((Dataset.Fields[I].ReadOnly)  Or
       (Not(Dataset.Fields[I].ProviderFlags = []))))      Then
    Begin
     MassiveField                    := vMassiveFields.FieldByName(Dataset.Fields[I].FieldName);
     If MassiveField = Nil Then
      Begin
       MassiveField                   := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
       vMassiveFields.Add(MassiveField);
      End;
     MassiveField.vReadOnly          := Dataset.Fields[I].ReadOnly;
     MassiveField.vRequired          := Dataset.Fields[I].Required;
     MassiveField.vKeyField          := pfInKey in Dataset.Fields[I].ProviderFlags;
     MassiveField.vFieldName         := Dataset.Fields[I].FieldName;
     MassiveField.vFieldType         := FieldTypeToObjectValue(Dataset.Fields[I].DataType);
     MassiveField.vSize              := Dataset.Fields[I].DataSize;
     {$IFNDEF FPC}{$IF CompilerVersion > 21}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].AutoGenerateValue = arAutoInc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     If Not (MassiveField.vAutoGenerateValue) Then
      MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                          (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ELSE}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$IFEND}
     {$ELSE}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ENDIF}
    End
   Else
    Begin
     If (Not(vReflectChanges) And
        ((Dataset.Fields[I].ReadOnly) Or (Dataset.Fields[I].ProviderFlags = []))) Or
        (vReflectChanges And (Dataset.Fields[I].ProviderFlags = [])) Then
      Begin
       If vMassiveFields.FieldByName(Dataset.Fields[I].FieldName) <> Nil Then
        Begin
         If Dataset is TRESTDWClientSQL Then
          TRESTDWClientSQL(Dataset).RebuildMassiveDataset
         Else If Dataset is TRESTDWTable Then
          TRESTDWTable(Dataset).RebuildMassiveDataset;
         Exit;
         //vMassiveFields.Delete(Dataset.Fields[I].FieldName);
        End;
      End;
    End;
  End;
 If vReflectChanges Then
  Begin
   If vMassiveFields.Count > 0 Then
    Begin
     vMassiveLine.vMassiveMode       := mmBrowse;
     MassiveField                    := vMassiveFields.FieldByName(DWFieldBookmark);
     If MassiveField = Nil Then
      Begin
       MassiveField                  := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
       vMassiveFields.Add(MassiveField);
      End;
     MassiveField.vRequired          := False;
     MassiveField.vKeyField          := False;
     MassiveField.vFieldName         := DWFieldBookmark;
     MassiveField.vFieldType         := ovString;
     MassiveField.vSize              := 60;
     MassiveField.vAutoGenerateValue := True;
    End;
  End;
 If Dataset      Is TRESTDWClientSQL Then
  vTableName    := TRESTDWClientSQL(Dataset).UpdateTableName
 Else If Dataset Is TRESTDWTable Then
  vTableName    := TRESTDWTable(Dataset).TableName;
 vSequenceName  := Dataset.SequenceName;
End;

Procedure TMassiveDatasetBuffer.BuildBuffer(Dataset     : TRESTDWClientSQLBase;
                                            MassiveMode : TMassiveMode;
                                            UpdateTag   : Boolean = False;
                                            ExecTag     : Boolean = False);
Begin
 MassiveCheck(Dataset);
 Case MassiveMode Of
  mmInactive : Begin
                vMassiveBuffer.ClearAll;
                vMassiveLine.ClearAll;
                vMassiveFields.ClearAll;
               End;
  mmBrowse   : vMassiveLine.ClearAll;
  mmExec     : Begin
                vMassiveLine.ClearAll;
                BuildLine(Dataset, MassiveMode, vMassiveLine, UpdateTag, ExecTag);
               End;
  Else
   BuildLine(Dataset, MassiveMode, vMassiveLine, UpdateTag, ExecTag);
 End;
End;

Function TMassiveDatasetBuffer.MasterFieldFromDetail(Field : String) : String;
Var
 I : Integer;
Begin
 Result := '';
 I := vDetailFields.IndexOf(Field);
 If I > -1 Then
  Result := vMasterFields[I];
End;

Procedure TMassiveDatasetBuffer.BuildCompFields(MasterCompFields : String);
Var
 I        : Integer;
 vTempValue,
 vFieldA,
 vFieldD  : String;
 vFields  : TStringList;
Begin
 vFields  := TStringList.Create;
 Try
  vFields.Text := MasterCompFields;
  For I := 0 To vFields.Count -1 Do
   Begin
    vTempValue := vFields[I];
    vFieldA    := Copy(vTempValue, InitStrPos, (Pos('=', vTempValue) -1) - FinalStrPos);
    vFieldD    := Copy(vTempValue, (Pos('=', vTempValue) - FinalStrPos) + 1, Length(vTempValue));
    vMasterFields.Add(vFieldA);
    vDetailFields.Add(vFieldD);
   End;
 Finally
  FreeAndNil(vFields);
 End;
End;

Procedure TMassiveDatasetBuffer.BuildDataset(Dataset         : TRESTDWClientSQLBase;
                                             UpdateTableName : String);
Var
 I : Integer;
 MassiveField : TMassiveField;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 vMasterCompTag    := '';
 vMyCompTag        := Dataset.Componenttag;
 If Dataset Is TRESTDWClientSQL Then
  Begin
   If TRESTDWClientSQL(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWClientSQL(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWClientSQL(Dataset).RelationFields.Text;
  End
 Else If Dataset Is TRESTDWTable Then
  Begin
   If TRESTDWTable(Dataset).MasterDataSet <> Nil Then
    vMasterCompTag   := TRESTDWTable(Dataset).MasterDataSet.Componenttag;
   vMasterCompFields := TRESTDWTable(Dataset).RelationFields.Text;
  End;
 vSequenceName     := Dataset.SequenceName;
 vSequenceField    := Dataset.SequenceField;
 For I := 0 To Dataset.Fields.Count -1 Do
  Begin
   If ((Dataset.Fields[I].FieldKind = fkData)             And
       ((pfInUpdate in Dataset.Fields[I].ProviderFlags)   Or
        (pfInWhere  in Dataset.Fields[I].ProviderFlags)   Or
        (pfInKey    in Dataset.Fields[I].ProviderFlags))) Or
      (vReflectChanges And ((Dataset.Fields[I].ReadOnly)  Or
       (Not(Dataset.Fields[I].ProviderFlags = []))))      Then
    Begin
     MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
     MassiveField.vReadOnly          := Dataset.Fields[I].ReadOnly;
     MassiveField.vRequired          := Dataset.Fields[I].Required;
     MassiveField.vKeyField          := pfInKey in Dataset.Fields[I].ProviderFlags;
     MassiveField.vFieldName         := Dataset.Fields[I].FieldName;
     MassiveField.vFieldType         := FieldTypeToObjectValue(Dataset.Fields[I].DataType);
     MassiveField.vSize              := Dataset.Fields[I].DataSize;
     {$IFNDEF FPC}{$IF CompilerVersion > 21}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].AutoGenerateValue = arAutoInc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     If Not (MassiveField.vAutoGenerateValue) Then
      MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                          (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ELSE}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$IFEND}
     {$ELSE}
     MassiveField.vAutoGenerateValue := ((Dataset.Fields[I].FieldKind = fkInternalCalc) Or
                                         (Lowercase(Dataset.Fields[I].FieldName) = Lowercase(vSequenceField)));
     {$ENDIF}
     vMassiveFields.Add(MassiveField);
    End
   Else
    Begin
     If (Not(vReflectChanges) And (Dataset.Fields[I].ReadOnly)) Or
        (vReflectChanges And (Dataset.Fields[I].ProviderFlags = [])) Then
      Begin
       If vMassiveFields.FieldByName(Dataset.Fields[I].FieldName) <> Nil Then
        vMassiveFields.Delete(Dataset.Fields[I].FieldName);
      End;
    End;
  End;
 If vReflectChanges Then
  Begin
   If vMassiveFields.Count > 0 Then
    Begin
     vMassiveLine.vMassiveMode       := mmBrowse;
     MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
     MassiveField.vRequired          := False;
     MassiveField.vKeyField          := False;
     MassiveField.vFieldName         := DWFieldBookmark;
     MassiveField.vFieldType         := ovString;
     MassiveField.vSize              := 60;
     MassiveField.vAutoGenerateValue := True;
     vMassiveFields.Add(MassiveField);
    End;
  End;
 vTableName    := UpdateTableName;
 vSequenceName := Dataset.SequenceName;
End;

Procedure TMassiveDatasetBuffer.ClearBuffer;
Begin
 vMassiveBuffer.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearLine;
Begin
 vMassiveLine.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearDataset;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
End;

Constructor TMassiveDatasetBuffer.Create(Dataset : TRESTDWClientSQLBase);
Begin
 vDataset        := Dataset;
 vRecNo          := -1;
 vMassiveBuffer  := TMassiveBuffer.Create;
 vMassiveLine    := TMassiveLine.Create;
 vMassiveFields  := TMassiveFields.Create(Self);
 vMassiveReply   := TMassiveReply.Create;
 vDataexec       := TStringList.Create;
 vDWParams       := TDWParams.Create;
 vMassiveMode    := mmInactive;
 vMassiveType    := mtMassiveCache;
 vTableName      := '';
 vSequenceName   := '';
 vSequenceField  := '';
 vReflectChanges := True;
 vMasterFields   := TStringList.Create;
 vDetailFields   := TStringList.Create;
 vOnLoad         := False;
 vCreateBuffer   := True;
End;

Destructor TMassiveDatasetBuffer.Destroy;
Begin
 FreeAndNil(vMassiveBuffer);
 FreeAndNil(vMassiveLine);
 FreeAndNil(vMassiveFields);
 FreeAndNil(vMassiveReply);
 FreeAndNil(vMasterFields);
 FreeAndNil(vDetailFields);
 FreeAndNil(vDataexec);
 FreeAndNil(vDWParams);
 Inherited;
End;

Procedure TMassiveDatasetBuffer.First;
Begin
 If RecordCount > 0 Then
  Begin
   vRecNo := 1;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.Last;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo <> RecordCount Then
    vRecNo := RecordCount;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Var MassiveLineBuff : TMassiveLine;
                                          MassiveModeData     : TMassiveMode;
                                          ExecTag             : Boolean = False);
Begin
 MassiveLineBuff.ClearAll;
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 NewLineBuffer(MassiveLineBuff, MassiveModeData, ExecTag); //Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Dataset         : TRESTDWClientSQLBase;
                                          MassiveModeData : TMassiveMode;
                                          ExecTag         : Boolean = False);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 MassiveCheck(Dataset);
 NewLineBuffer(vMassiveLine, MassiveModeData, ExecTag); //Sempre se assume mmInsert como padrão
 //BuildLine(Dataset, MassiveModeData, vMassiveLine);//Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.NewBuffer(MassiveModeData     : TMassiveMode;
                                          ExecTag             : Boolean = False);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 NewLineBuffer(vMassiveLine, MassiveModeData, ExecTag); //Sempre se assume mmInsert como padrão
End;

Procedure TMassiveDatasetBuffer.Next;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo < RecordCount Then
    Inc(vRecNo);
   ReadStatus;
  End;
End;

Function TMassiveDatasetBuffer.PrimaryKeys : TStringList;
Var
 I : Integer;
Begin
 Result := TStringList.Create;
 If vMassiveFields <> Nil Then
  Begin
   For I := 0 To vMassiveFields.Count -1 Do
    Begin
     If vMassiveFields.Items[I].vKeyField Then
      Result.Add(vMassiveFields.Items[I].vFieldName);
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.Prior;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo > 1 Then
    Dec(vRecNo);
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.ReadStatus;
Begin
 If (RecordCount > 0) Then
  Begin
   vCreateBuffer := False;
   If vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Count > 0 Then
    vMassiveMode  := StringToMassiveMode(vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[0].Value)
   Else
    vMassiveMode  := vMassiveBuffer.Items[vRecNo -1].vMassiveMode;
   vDataexec.Text := vMassiveBuffer.Items[vRecNo -1].vDataExec.Text;
   vDWParams.CopyFrom(vMassiveBuffer.Items[vRecNo -1].vDWParams);
  End
 Else
  vMassiveMode := mmInactive;
End;

Function TMassiveDatasetBuffer.RecNo : Integer;
Begin
 Result := vRecNo;
End;

Function TMassiveDatasetBuffer.RecordCount : Integer;
Begin
 Result := 0;
 If vMassiveBuffer <> Nil Then
  Result := vMassiveBuffer.Count;
End;

Procedure TMassiveDatasetBuffer.SaveBuffer(Dataset : TRESTDWClientSQLBase;
                                           ExecTag : Boolean = False);
Var
 I, A          : Integer;
 Field         : TField;
 vStringStream : TMemoryStream;
 MassiveLine   : TMassiveLine;
 MassiveValue  : TMassiveValue;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
Begin
 vStringStream           := Nil;
 MassiveLine             := TMassiveLine.Create;
 MassiveLine.MassiveMode := vMassiveLine.MassiveMode;
 MassiveLine.MassiveType := vMassiveLine.MassiveType;
 NewBuffer(MassiveLine, vMassiveLine.vMassiveMode, ExecTag);
 Try
  If ExecTag Then
   Begin
    MassiveLine.vDataExec.Text := vMassiveLine.DataExec.Text;
    MassiveLine.Params.Clear;
    MassiveLine.Params.CopyFrom(vMassiveLine.Params);
   End
  Else
   Begin
    If vMassiveLine.vMassiveValues.Count > 1 Then
    If vMassiveLine.vMassiveMode = mmUpdate Then
     Begin
      For I := 0 To vMassiveLine.vChanges.Count -1 Do
       Begin
        Field := Dataset.FindField(vMassiveLine.vChanges[I]);
        If Field <> Nil Then
         Begin
          MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ValueName              := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ValueName;
          MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ObjectValue            := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].ObjectValue;
          MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].vJSONValue.ObjectValue := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].vJSONValue.ObjectValue;
          If Field.DataType  In [ftBytes, ftVarBytes,
                                 ftBlob, ftGraphic,
                                 ftOraBlob, ftOraClob] Then
           Begin
            Try
             vStringStream := TMemoryStream.Create;
             vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].SaveToStream(vStringStream);
             vStringStream.Position := 0;
             If vStringStream.Size > 0 Then
              MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].LoadFromStream(vStringStream);
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Begin
            If vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].isnull Then
             MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value := Null
            Else
             MassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value := vMassiveLine.vMassiveValues.Items[GetFieldIndex(vMassiveLine.vChanges[I]) +1].Value;
           End;
         End;
       End;
      If vReflectChanges Then
       Begin
        If vMassiveLine.vChanges.IndexOf(DWFieldBookmark) = -1 Then
         vMassiveLine.vChanges.Add(DWFieldBookmark);
        MassiveLine.vMassiveValues.Items[GetFieldIndex(DWFieldBookmark) +1].Value := vMassiveLine.vMassiveValues.Items[GetFieldIndex(DWFieldBookmark) +1].Value;
       End;
     End
    Else
     Begin
      For I := 0 To vMassiveFields.Count -1 Do
       Begin
        If I = 0 Then
         MassiveLine.vMassiveValues.Items[I].Value := vMassiveLine.vMassiveValues.Items[I].Value;
        Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
        If Field <> Nil Then
         Begin
          If vMassiveLine.vMassiveMode = mmDelete Then
           If Not(pfInKey in Field.ProviderFlags) Then
            Continue;
          MassiveLine.vMassiveValues.Items[I +1].vJSONValue.ObjectValue := vMassiveLine.vMassiveValues.Items[I +1].vJSONValue.ObjectValue;
          If Field.DataType  In [ftBytes, ftVarBytes,
                                 ftBlob, ftGraphic,
                                 ftOraBlob, ftOraClob] Then
           Begin
            vStringStream := TMemoryStream.Create;
            Try
             vMassiveLine.vMassiveValues.Items[I +1].SaveToStream(vStringStream);
             vStringStream.Position := 0;
             If vStringStream.Size > 0 Then
              MassiveLine.vMassiveValues.Items[I +1].LoadFromStream(vStringStream);
            Finally
             If Assigned(vStringStream) Then
              FreeAndNil(vStringStream);
            End;
           End
          Else
           Begin
            If Not vMassiveLine.vMassiveValues.Items[I +1].isNull Then
             MassiveLine.vMassiveValues.Items[I +1].Value := vMassiveLine.vMassiveValues.Items[I +1].Value;
           End;
         End
        Else
         Begin
          If vReflectChanges Then
           Begin
            If (vMassiveLine.vMassiveValues.Items[I +1].Value <> '')               And
               (Lowercase(vMassiveFields.Items[I].vFieldName) = Lowercase(DWFieldBookmark)) Then
             MassiveLine.vMassiveValues.Items[I +1].Value := vMassiveLine.vMassiveValues.Items[I +1].Value;
           End;
         End;
       End;
     End;
   End;
 Finally
  //Update Changes
  If ExecTag Then
   Begin
    vMassiveBuffer.Add(MassiveLine);
    vMassiveLine.ClearAll;
   End
  Else
   Begin
    If vMassiveLine.vMassiveValues.Count > 1 Then
     Begin
      For A := 0 To vMassiveLine.vChanges.Count -1 do
       MassiveLine.vChanges.Add(vMassiveLine.vChanges[A]);
      //KeyValues to Update
      If vMassiveLine.vPrimaryValues <> Nil Then
       Begin
        If vMassiveLine.vPrimaryValues.Count > 0 Then
         Begin
          If MassiveLine.vPrimaryValues = Nil Then
           MassiveLine.vPrimaryValues := TMassiveValues.Create;
          For A := 0 To vMassiveLine.vPrimaryValues.Count -1 do
           Begin
            MassiveValue  := TMassiveValue.Create;
            MassiveValue.ObjectValue := vMassiveLine.vPrimaryValues.Items[A].ObjectValue;
            MassiveValue.ValueName   := vMassiveLine.vPrimaryValues.Items[A].ValueName;
            MassiveValue.Value       := vMassiveLine.vPrimaryValues.Items[A].Value;
            MassiveLine.vPrimaryValues.Add(MassiveValue);
           End;
         End;
       End;
      vMassiveBuffer.Add(MassiveLine);
      vMassiveLine.ClearAll;
     End;
   End;
 End;
End;

Procedure TMassiveDatasetBuffer.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonValueB,
 bJsonValueC,
 bJsonValueD : TDWJSONBase;
 bJsonOBJC,
 bJsonValue  : TDWJSONObject;
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC,
 bJsonArrayD,
 bJsonArrayE  : TDWJSONArray;
 MassiveValue : TMassiveValue;
 A, C,
 D, E, I, X   : Integer;
 MassiveField : TMassiveField;
 MassiveLine  : TMassiveLine;
 vTempValue   : String;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 bJsonValue  := TDWJSONObject.Create(Value);
 bJsonArray  := Nil;
 bJsonArrayB := Nil;
 vOnLoad     := True;
 If bJsonValue.PairCount > 0 Then
  Begin
   Try
    vTableName        := bJsonValue.pairs[4].Value;
    vReflectChanges   := False;
    vMasterCompFields := '';
    vMasterCompTag    := '';
    If bJsonValue.PairCount > 5 Then
     Begin
      vReflectChanges   := StringToBoolean(bJsonValue.pairs[6].Value);
      vSequenceName     := bJsonValue.pairs[7].Value;
      vSequenceField    := bJsonValue.pairs[8].Value;
      vmycomptag        := bJsonValue.pairs[9].Value;
      vMasterCompTag    := bJsonValue.pairs[10].Value;
      If Not (bJsonValue.pairs[11].IsNull) Then
       Begin
        vMasterCompFields := DecodeStrings(bJsonValue.pairs[11].Value{$IFDEF FPC}, csUndefined{$ENDIF});
        BuildCompFields(vMasterCompFields);
       End;
     End;
    bJsonArray  := bJsonValue.openArray(bJsonValue.pairs[5].Name);
    If bJsonArray.ElementCount > 0 Then
    For A := 0 To 1 Do
     Begin
      bJsonOBJ     := bJsonArray.GetObject(A);
      If A = 0 Then //Fields
       Begin
        Try
         bJsonArrayB := TDWJSONObject(bJsonOBJ).openArray('fields');
         For I := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJb :=  bJsonArrayB.GetObject(I);
           Try
            MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
            MassiveField.vRequired          := TDWJSONObject(bJsonOBJb).Pairs[3].Value      = 'S';
            MassiveField.vKeyField          := TDWJSONObject(bJsonOBJb).Pairs[2].Value      = 'S';
            MassiveField.vFieldName         := TDWJSONObject(bJsonOBJb).Pairs[0].Value;
            MassiveField.vFieldType         := GetValueType(TDWJSONObject(bJsonOBJb).Pairs[1].Value);
            MassiveField.vSize              := StrToInt(TDWJSONObject(bJsonOBJb).Pairs[4].Value);
            MassiveField.vAutoGenerateValue := TDWJSONObject(bJsonOBJb).Pairs[7].Value = 'S';
            MassiveField.vReadOnly          := TDWJSONObject(bJsonOBJb).Pairs[6].Value = 'S';
            vMassiveFields.Add(MassiveField);
           Finally
            FreeAndNil(bJsonOBJb);
           End;
          End;
        Finally
         FreeAndNil(bJsonArrayB);
        End;
       End
      Else //Data
       Begin
        bJsonArrayB := TDWJSONObject(bJsonOBJ).OpenArray('lines');
        For E := 0 to bJsonArrayB.ElementCount -1  Do
         Begin
          bJsonValueC := bJsonArrayB.GetObject(E);
          bJsonArrayC := TDWJSONArray(bJsonValueC);
          Try
           bJsonValueD  := bJsonArrayC.GetObject(0);
           bJsonArrayD  := TDWJSONArray(bJsonValueD);
           bJsonOBJC    := TDWJSONObject(bJsonArrayD.GetObject(0));
           vMassiveMode := StringToMassiveMode(bJsonOBJC.Pairs[0].Value);
           If vMassiveMode = mmExec Then
            Begin
             FreeAndNil(bJsonOBJC);
             bJsonOBJC    := TDWJSONObject(bJsonArrayD.GetObject(1));
             vDataexec.Text := DecodeStrings(bJsonOBJC.Pairs[0].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
             FreeAndNil(bJsonOBJC);
             bJsonOBJC    := TDWJSONObject(bJsonArrayD.GetObject(2));
             vDWParams.FromJSON(DecodeStrings(bJsonOBJC.Pairs[0].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
            End;
           FreeAndNil(bJsonOBJC);
           MassiveLine  := TMassiveLine.Create;
           NewLineBuffer(MassiveLine, vMassiveMode, vMassiveMode = mmExec); //Sempre se assume MassiveMode vindo na String
           vDWParams.Clear;
           If vMassiveMode = mmUpdate Then
            Begin
             If bJsonArrayD.ElementCount > 1 Then
              Begin
               bJsonArrayE  := TDWJSONArray(bJsonArrayC.GetObject(2));
               If bJsonArrayE.JSONObject <> Nil Then
                Begin
                 For D := 0 To bJsonArrayE.ElementCount -1 Do //Valores
                  Begin
                   bJsonValueB  := bJsonArrayE.GetObject(D);
                   MassiveLine.vChanges.Add(TDWJSONObject(bJsonValueB).Pairs[0].Value);
                   FreeAndNil(bJsonValueB);
                  End;
                End;
               bJsonArrayE.Free;
               bJsonArrayE  := TDWJSONArray(bJsonArrayC.GetObject(1));
               If bJsonArrayE.JSONObject <> Nil Then
                Begin
                 For D := 0 To bJsonArrayE.ElementCount -1 Do //Valores
                  Begin
                   MassiveValue        := TMassiveValue.Create;
                   bJsonValueB         := bJsonArrayE.GetObject(D);
                   vTempValue          := TDWJSONObject(bJsonValueB).Pairs[0].Value;
                   MassiveValue.ObjectValue := GetValueType(Copy(vTempValue, InitStrPos, (Pos('|', vTempValue) - FinalStrPos) -1));
                   DeleteStr(vTempValue, InitStrPos, (Pos('|', vTempValue) - FinalStrPos));
                   If (vTempValue = cNullvalue) or
                      (vTempValue = '') Then
                    vTempValue := '';
                   If MassiveValue.ObjectValue in [ovString, ovWideString, ovMemo,
                                                   ovWideMemo, ovFixedChar, ovFixedWideChar] Then
                    MassiveValue.Value := vTempValue
                   Else If MassiveValue.vJSONValue.ObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
                    Begin
                     If Not TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveValue.Value := UnixToDateTime(StrToInt64(vTempValue));
                    End
                   Else
                    MassiveValue.Value := vTempValue;
                   MassiveValue.SetModified(Not (vOnLoad));
                   If Not Assigned(MassiveLine.vPrimaryValues) Then
                    MassiveLine.vPrimaryValues := TMassiveValues.Create;
                   MassiveLine.vPrimaryValues.Add(MassiveValue);
                   FreeAndNil(bJsonValueB);
                  End;
                End;
               bJsonArrayE.Free;
               If MassiveLine.vChanges.count > 0 Then
               For C := 1 To bJsonArrayD.ElementCount -1 Do //Valores
                Begin
                 bJsonValueB := bJsonArrayD.GetObject(C);
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].vJSONValue.ObjectValue := vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType;
                 If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovString, ovMemo, ovWideString, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
                  Begin
                   If (Not (TDWJSONObject(bJsonValueB).Pairs[0].isnull))        And
                      (TDWJSONObject(bJsonValueB).Pairs[0].Value <> cNullValue) Then
                    Begin
                     vTempValue := DecodeStrings(TDWJSONObject(bJsonValueB).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF});
                     MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := vTempValue;
                     {$IFNDEF FPC}
                      {$IF (CompilerVersion < 19)}
                       If vEncoding = esASCII Then
                        Begin
                         vTempValue := UTF8Decode(vTempValue);
                         MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := vTempValue;
                        End;
                      {$IFEND}
                     {$ENDIF}
                    End
                   Else
                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].SetValue(Null);
//                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := TDWJSONObject(bJsonValueB).Pairs[0].Value;
                  End
                 Else
                  Begin
                   If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovBytes, ovVarBytes, ovStream, ovBlob,
                                                                                                    ovGraphic, ovOraBlob, ovOraClob] Then
                    Begin
                     MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Binary := True;
                     If TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].SetValue(Null)
                     Else
                      MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value  := TDWJSONObject(bJsonValueB).Pairs[0].Value;
                    End
                   Else If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
                    Begin
                     If Not TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := UnixToDateTime(StrToInt64(TDWJSONObject(bJsonValueB).Pairs[0].Value));
                    End
                   Else If Not TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := TDWJSONObject(bJsonValueB).Pairs[0].Value
                   Else
                    MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := Null;
                  End;
                 MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].SetModified(Not (vOnLoad));
                 bJsonValueB.Free;
                End;
              End;
            End
           Else If vMassiveMode <> mmExec Then
            Begin
             For C := 1 To bJsonArrayD.ElementCount -1 Do //Valores
              Begin
               bJsonValueB := bJsonArrayD.GetObject(C);
               If (vMassiveFields.Items[C-1] <> Nil) Then
                Begin
                 MassiveLine.Values[C].vJSONValue.ObjectValue := vMassiveFields.Items[C-1].vFieldType;
                 If TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                  MassiveLine.Values[C].Value := Null
                 Else
                  Begin
                   If vMassiveFields.Items[C-1].vFieldType in [ovString, ovWideString, ovMemo, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
                    Begin
                     If lowercase(TDWJSONObject(bJsonValueB).Pairs[0].Value) <> cNullvalue then
                      MassiveLine.Values[C].Value := DecodeStrings(TDWJSONObject(bJsonValueB).Pairs[0].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                     Else
                      MassiveLine.Values[C].Value := TDWJSONObject(bJsonValueB).Pairs[0].Value;
                    End
                   Else
                    Begin
                     If vMassiveFields.Items[C-1].vFieldType in [ovBytes, ovVarBytes, ovStream, ovBlob,
                                                                 ovGraphic, ovOraBlob, ovOraClob] Then
                      Begin
                       MassiveLine.Values[C].Binary := True;
                       If TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                        MassiveLine.Values[C].SetValue(Null)
                       Else
                        MassiveLine.Values[C].Value  := TDWJSONObject(bJsonValueB).Pairs[0].Value;
                      End
                     Else If vMassiveFields.Items[C-1].vFieldType in [ovDate, ovTime, ovDateTime, ovTimeStamp] then     // ajuste massive
                      Begin
                       If Not TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                        MassiveLine.Values[C].Value := UnixToDateTime(StrToInt64(TDWJSONObject(bJsonValueB).Pairs[0].Value));
                      End
                     Else If Not TDWJSONObject(bJsonValueB).Pairs[0].isnull Then
                      MassiveLine.Values[C].Value := TDWJSONObject(bJsonValueB).Pairs[0].Value
                     Else
                      MassiveLine.Values[C].Value := Null;
                    End;
                  End;
                End;
               MassiveLine.Values[C].SetModified(Not (vOnLoad));
               FreeAndNil(bJsonValueB);
              End;
            End;
          Finally
           FreeAndNil(bJsonValueD);
           FreeAndNil(bJsonValueC);
           vMassiveBuffer.Add(MassiveLine);
          End;
         End;
       End;
      FreeAndNil(bJsonOBJ);
     End;
   Finally
    vOnLoad := False;
    If Assigned(bJsonArrayB) Then
     FreeAndNil(bJsonArrayB);
    If Assigned(bJsonArray)  Then
     FreeAndNil(bJsonArray);
    FreeAndNil(bJsonValue);
   End;
  End;
End;

Function TMassiveDatasetBuffer.ToJSON : String;
Var
 A              : Integer;
 vLines,
 vTagFields,
 vTagLinkFields : String;
 Function GenerateHeader: String;
 Var
  I              : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc       : string;
 Begin
  For I := 0 To vMassiveFields.Count - 1 Do
   Begin
    If vDataset <> Nil Then
     Begin
      If (vDataset.FindField(vMassiveFields.Items[I].vFieldName) <> Nil) Then
       Begin
        If Not(Self.vReflectChanges) And
           (vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).ReadOnly) And
           ((Not vMassiveFields.Items[I].vKeyField) And (Not vMassiveFields.Items[I].vAutoGenerateValue)) Then
         Continue;
        {$IFNDEF FPC}{$IF CompilerVersion > 21}
        vMassiveFields.Items[I].vReadOnly          := vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).ReadOnly;
        vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).AutoGenerateValue = arAutoInc) Or
                                                       (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        If Not (vMassiveFields.Items[I].vAutoGenerateValue) Then
         vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc) Or
                                                        (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        {$ELSE}
        vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc) Or
                                                        (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        {$IFEND}
        {$ELSE}
        vMassiveFields.Items[I].vAutoGenerateValue := ((vDataset.FieldByName(vMassiveFields.Items[I].vFieldName).FieldKind = fkInternalCalc) Or
                                                       (lowercase(vMassiveFields.Items[I].vFieldName) = lowercase(vSequenceField)));
        {$ENDIF}
       End;
     End;
    vPrimary  := 'N';
    vAutoinc  := 'N';
    vReadOnly := 'N';
    If vMassiveFields.Items[I].vKeyField Then
     vPrimary := 'S';
    vRequired := 'N';
    If vMassiveFields.Items[I].vRequired Then
     vRequired := 'S';
    If vMassiveFields.Items[I].vReadOnly Then
     vReadOnly := 'S';
    If (vMassiveFields.Items[I].vAutoGenerateValue) Or
       (vMassiveFields.Items[I].FieldType = ovAutoInc) Then
     vAutoinc := 'S';
    If vMassiveFields.Items[I].FieldType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ovExtended,
                                             {$IFEND}{$ENDIF}ovFloat, ovCurrency, ovFMTBcd, ovSingle, ovBCD] Then
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size,
                                                  vMassiveFields.Items[I].Precision, vReadOnly, vAutoinc])
    Else
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size, 0, vReadOnly, vAutoinc]);
    If I = 0 Then
     Result := vGenerateLine
    Else
     Result := Result + ', ' + vGenerateLine;
   End;
 End;
 Function GenerateLine(MassiveLineBuff : TMassiveLine) : String;
 Var
  A, I          : Integer;
  vTempLine,
  vTempComp,
  vTempKeys,
  vTempValue    : String;
  vMassiveMode  : TMassiveMode;
  vNoChange     : Boolean;
 Begin
  vMassiveMode := mmInactive;
  If MassiveLineBuff.MassiveMode = mmExec Then
   Begin
    vMassiveMode := MassiveLineBuff.MassiveMode;
    vTempLine    := Format('["%s", "%s", "%s"]', [MassiveModeToString(vMassiveMode),
                                                  EncodeStrings(MassiveLineBuff.DataExec.Text{$IFDEF FPC}, csUndefined{$ENDIF}),
                                                  EncodeStrings(MassiveLineBuff.Params.ToJSON{$IFDEF FPC}, csUndefined{$ENDIF})]);
   End
  Else
   Begin
    For I := 0 To MassiveLineBuff.vMassiveValues.Count - 1 Do
     Begin
      If I = 0 Then
       vMassiveMode  := StringToMassiveMode(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value)
      Else
       Begin
        If vMassiveMode = mmUpdate Then
         Begin
          If MassiveLineBuff.vChanges.Count = 0 Then
           Continue;
          vNoChange := True;
          For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
           Begin
            If vDataset <> Nil Then
             Begin
              If vMassiveFields.Count <= (I-1) Then
               Continue;
              If (vDataset.FindField(vMassiveFields.Items[I-1].vFieldName) <> Nil) Then
               Begin
                If vDataset.FieldByName(vMassiveFields.Items[I-1].vFieldName).ReadOnly Then
                 Continue;
               End
              Else
               vNoChange := Not vReflectChanges;
             End;
            If Not((vDataset.FindField(vMassiveFields.Items[I-1].vFieldName) = Nil)) Then
             vNoChange := Lowercase(vMassiveFields.Items[I-1].vFieldName) <>
                          Lowercase(MassiveLineBuff.vChanges[A]);
            If Not (vNoChange) Then
             Break;
           End;
          If vNoChange Then
           Continue;
         End;
        If vDataset <> Nil Then
         Begin
          If vMassiveFields.Count <= (I-1) then
           Continue;
         End;
       End;
      If MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.IsNull Then
       vTempValue := Format('%s', [cNullvalue])
      Else
       Begin
        If vTempLine = '' Then
         vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.AsString])    //asstring
        Else
         Begin
          If vMassiveFields.Items[I-1].vFieldType in [ovString, ovWideString, ovMemo, ovWideMemo, ovFixedChar, ovFixedWideChar] Then
           Begin
            vTempValue    := Format('"%s"', [EncodeStrings(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value{$IFDEF FPC}, csUndefined{$ENDIF})])
           End
          Else
           vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.AsString])
         End;
       End;
      If I = 0 Then
       vTempLine := vTempValue
      Else
       vTempLine := vTempLine + ', ' + vTempValue;
     End;
    vTempLine := '[' + vTempLine + ']';
    If MassiveLineBuff.vChanges.Count > 0 Then
     Begin
      For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
       Begin
        vTempValue := Format('"%s"', [MassiveLineBuff.vChanges[A]]);    //asstring
        If A = 0 Then
         vTempKeys := vTempValue
        Else
         vTempKeys := vTempKeys + ', ' + vTempValue;
       End;
      vTempKeys := '[' + vTempKeys + ']';
     End;
    If MassiveLineBuff.vPrimaryValues <> Nil Then
     Begin
      For I := 0 To MassiveLineBuff.vPrimaryValues.Count - 1 Do
       Begin
        If MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.IsNull Then
         vTempValue := Format('"%s|%s"', [GetValueType(MassiveLineBuff.vPrimaryValues.Items[I].ObjectValue),
                                          cNullvalue])
        Else
         vTempValue    := Format('"%s|%s"', [GetValueType(MassiveLineBuff.vPrimaryValues.Items[I].ObjectValue),
                                             MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.AsString]);    //asstring
        If I = 0 Then
         vTempComp := vTempValue
        Else
         vTempComp := vTempComp + ', ' + vTempValue;
       End;
      If MassiveLineBuff.vPrimaryValues.Count > 0 Then
       vTempComp := '[' + vTempComp + ']';
     End;
   End;
  If (vTempComp <> '') And (vTempKeys <> '') Then
   Result := Format('%s,%s,%s', [vTempLine, vTempComp, vTempKeys])
  Else
   Result := vTempLine;
 End;
Begin
 vTagFields  := '{"fields":[' + GenerateHeader + ']}';
 For A := 0 To vMassiveBuffer.Count -1 Do
  Begin
   If A = 0 Then
    vLines := Format('[%s]', [GenerateLine(vMassiveBuffer.Items[A])])
   Else
    vLines := vLines + Format(', [%s]', [GenerateLine(vMassiveBuffer.Items[A])]);
  End;
 vTagFields := vTagFields + Format(', {"lines":[%s]}', [vLines]);
 vTagLinkFields := '';
 If Trim(vMasterCompFields) <> '' Then
  vTagLinkFields := EncodeStrings(vMasterCompFields{$IFDEF FPC}, csUndefined{$ENDIF});
 Result := Format(TMassiveFormatJSON, ['ObjectType',   GetObjectName(toMassive),
                                       'Direction',    GetDirectionName(odINOUT),
                                       'Encoded',      'true',
                                       'ValueType',    GetValueType(ovObject),
                                       'TableName',    vTableName,
                                       'MassiveValue', vTagFields,
                                       BooleanToString(vReflectChanges),
                                       vSequenceName,
                                       vSequenceField,
                                       vMyCompTag,
                                       vMasterCompTag,
                                       vTagLinkFields]);
End;

Procedure TMassiveDatasetBuffer.SetEncoding(bValue: TEncodeSelect);
Begin
 vEncoding := bValue;
End;

{ TDWMassiveCacheList }

function TDWMassiveCacheList.Add(Item: TDWMassiveCacheValue): Integer;
Var
 vItem : ^TDWMassiveCacheValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

procedure TDWMassiveCacheList.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

procedure TDWMassiveCacheList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If TDWMassiveCacheValue(TList(Self).Items[Index]^) <> '' Then
      TDWMassiveCacheValue(TList(Self).Items[Index]^) := '';
     {$IFDEF FPC}
      Dispose(PMassiveCacheValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
end;

destructor TDWMassiveCacheList.Destroy;
begin
 ClearAll;
 Inherited;
end;

function TDWMassiveCacheList.GetRec(Index: Integer): TDWMassiveCacheValue;
begin
 Result := '';
 If (Index < Self.Count) And (Index > -1) Then
  Result := TDWMassiveCacheValue(TList(Self).Items[Index]^);
end;

procedure TDWMassiveCacheList.PutRec(Index: Integer; Item: TDWMassiveCacheValue);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TDWMassiveCacheValue(TList(Self).Items[Index]^) := Item;
end;

{ TDWMassiveCache }

Constructor TDWMassiveCache.Create(AOwner: TComponent);
Begin
  inherited;
 vReflectChanges         := False;
 MassiveCacheList        := TDWMassiveCacheList.Create;
 vMassiveType            := mtMassiveCache;
 MassiveCacheDatasetList := TDWMassiveCacheDatasetList.Create;
End;

Function TDWMassiveCache.MassiveCount : Integer;
Begin
 Result := MassiveCacheList.Count;
End;

Procedure TDWMassiveCache.ProcessChanges(Value : String);
Var
 X, I             : Integer;
 bJsonValueX,
 bJsonValue       : TDWJSONObject;
 bJsonArrayX,
 bJsonArray       : TDWJSONArray;
 bJsonValueY,
 bJsonValueB      : TDWJSONBase;
 vValue,
 vComponentTag,
 vJSONItems,
 vLastTimeB,
 vBookmark        : String;
 Dataset          : TDataset;
 vActualRecB      : Integer;
 vBookmarkD       : String;
 vOldReadOnly     : Boolean;
 vStringStream    : TMemoryStream;
 Function DecodeREC(BookmarkSTR  : String;
                    Var LastTime : String) : Integer;
 Begin
  Result := -1;
  If Pos('|', BookmarkSTR) > 0 Then
   Begin
    Result := StrToInt(Copy(BookmarkSTR, InitStrPos, (Pos('|', BookmarkSTR) - FinalStrPos) -1));
    DeleteStr(BookmarkSTR, InitStrPos, (Pos('|', BookmarkSTR) - FinalStrPos));
    LastTime := DecodeStrings(BookmarkSTR{$IFDEF FPC}, csUndefined{$ENDIF});
   End;
 End;
Begin
 vStringStream  := Nil;
 bJsonValue     := TDWJSONObject.Create(StringReplace(Value, #$FEFF, '', [rfReplaceAll]));
 bJsonArray     := TDWJSONArray(bJsonValue);
 Dataset        := Nil;
 Try
  For I := 0 To bJsonArray.ElementCount -1 Do //For I := 0 To MassiveCacheDatasetList.Count -1 Do
   Begin
    bJsonValueB := bJsonArray.GetObject(I);
    Try
     vBookmark     := DecodeStrings(TDWJSONObject(bJsonValueB).Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF});
     vComponentTag := TDWJSONObject(bJsonValueB).Pairs[2].Value;
     vJSONItems    := TDWJSONObject(bJsonValueB).Pairs[1].Value;
     Dataset       := MassiveCacheDatasetList.GetDataset(vComponentTag);
     vActualRecB   := DecodeREC(vBookmark, vLastTimeB);
     If Dataset <> Nil Then
      Begin
       If (vActualRecB > -1) Then
        Begin
         If Dataset Is TRESTDWClientSQL Then
          Begin
           TRESTDWClientSQL(Dataset).SetInBlockEvents(True);
           If Not TRESTDWClientSQL(Dataset).BookmarkValid(TBookmark(HexToBookmark(vLastTimeB))) Then
            Continue;
           TRESTDWClientSQL(Dataset).GotoBookmark(TBookmark(HexToBookmark(vLastTimeB)));
           TRESTDWClientSQL(Dataset).Edit;
          End
         Else If Dataset Is TRESTDWTable Then
          Begin
           TRESTDWTable(Dataset).SetInBlockEvents(True);
           If Not TRESTDWTable(Dataset).BookmarkValid(TBookmark(HexToBookmark(vLastTimeB))) Then
            Continue;
           TRESTDWTable(Dataset).GotoBookmark(TBookmark(HexToBookmark(vLastTimeB)));
           TRESTDWTable(Dataset).Edit;
          End;
         Try
          bJsonValueX     := TDWJSONObject.Create(vJSONItems);
          bJsonArrayX     := TDWJSONArray(bJsonValueX);
          For X := 0 To bJsonArrayX.ElementCount -1 Do //For I := 0 To MassiveCacheDatasetList.Count -1 Do
           Begin
            bJsonValueY := bJsonArrayX.GetObject(X);
            Try
             If Dataset Is TRESTDWClientSQL Then
              Begin
               If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name) <> Nil Then
                Begin
                 vValue := TDWJSONObject(bJsonValueY).Pairs[0].Value;
                 vOldReadOnly := TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly;
                 TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly := False;
                 If (TRESTDWClientSQL(Dataset).State in [dsBrowse]) Then
                  TRESTDWClientSQL(Dataset).Edit;
                 If (vValue = cNullvalue) Or
                    (TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                  Begin
                   If Not (TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                    TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                   Continue;
                  End;
                 If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                          ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                          ftString,    ftWideString,
                                                                          ftMemo {$IFNDEF FPC}
                                                                                  {$IF CompilerVersion > 21}
                                                                                          , ftWideMemo
                                                                                   {$IFEND}
                                                                                   {$ELSE}
                                                                                   , ftWideMemo
                                                                                  {$ENDIF}]    Then
                  Begin
                   If (vValue <> Null) And (Trim(vValue) <> cNullvalue) and (Trim(vValue) <> '') Then
                    Begin
                     vValue := DecodeStrings(vValue{$IFDEF FPC}, csUndefined{$ENDIF});
                     {$IFNDEF FPC}{$IF CompilerVersion < 18}
                     vValue := utf8Decode(vValue);
                     {$IFEND}{$ENDIF}
                     If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Size > 0 Then
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsString := Copy(vValue, 1, TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Size)
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsString := vValue;
                    End
                   Else
                    TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                  End
                 Else
                  Begin
                   If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftAutoinc, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Begin
                     If (Trim(vValue) <> '') And (Trim(vValue) <> cNullvalue) Then
                      Begin
                       If vValue <> Null Then
                        Begin
                         vValue := DecodeStrings(vValue{$IFDEF FPC}, csUndefined{$ENDIF});
                         If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                          Begin
                           {$IFNDEF FPC}
                            {$IF CompilerVersion > 21}TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsLargeInt := StrToInt64(vValue);
                            {$ELSE}TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsInteger                     := StrToInt64(vValue);
                            {$IFEND}
                           {$ELSE}
                            TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsLargeInt := StrToInt64(vValue);
                           {$ENDIF}
                          End
                         Else
                          TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsInteger  := StrToInt(vValue);
                        End;
                      End
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
                    Begin
                     If (vValue <> Null) And
                        (Trim(vValue) <> cNullvalue) and
                        (Trim(vValue) <> '') Then
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsFloat  := StrToFloat(BuildFloatString(vValue))
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                    Begin
                     If (vValue       <> Null)   And
                        (Trim(vValue) <> cNullvalue) And
                        (Trim(vValue) <> '')     And
                        (Trim(vValue) <> '0')    Then
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(vValue))
                     Else
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                    End  //Tratar Blobs de Parametros...
                   Else If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                                  ftGraphic, ftOraBlob, ftOraClob] Then
                    Begin
                     vStringStream := TMemoryStream.Create;
                     Try
                      If (vValue <> cNullvalue) And
                         (vValue <> '') Then
                       Begin
                        vStringStream := Decodeb64Stream(vValue);
  //                      HexToStream(vValue, vStringStream);
                        vStringStream.Position := 0;
                        TBlobfield(TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name)).LoadFromStream(vStringStream); //, ftBlob);
                       End
                      Else
                       TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                     Finally
                      FreeAndNil(vStringStream);
                     End;
                    End
                   Else If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                    Begin
                     If TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType = ftBoolean Then
                      TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Value := StringToBoolean(vValue)
                     Else
                      Begin
                       If vValue <> '' Then
                        TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsString := DecodeStrings(vValue{$IFDEF FPC}, csUndefined{$ENDIF})
                       Else
                        TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                      End;
                    End
                   Else If (vValue <> Null) And
                           (Trim(vValue) <> cNullvalue) Then
                    TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Value := vValue
                   Else
                    TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                  End;
                 If vOldReadOnly Then
                  TRESTDWClientSQL(Dataset).Post;
                 TRESTDWClientSQL(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly := vOldReadOnly;
                End;
              End
             Else If Dataset Is TRESTDWTable Then
              Begin
               If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name) <> Nil Then
                Begin
                 vValue := TDWJSONObject(bJsonValueY).Pairs[0].Value;
                 vOldReadOnly := TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly;
                 TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly := False;
                 If (TRESTDWTable(Dataset).State in [dsBrowse]) Then
                  TRESTDWTable(Dataset).Edit;
                 If (vValue = cNullvalue) Or
                    (TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                  Begin
                   If Not (TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly) Then
                    TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                   Continue;
                  End;
                 If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                          ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                          ftString,    ftWideString,
                                                                          ftMemo {$IFNDEF FPC}
                                                                                  {$IF CompilerVersion > 21}
                                                                                          , ftWideMemo
                                                                                   {$IFEND}
                                                                                   {$ELSE}
                                                                                   , ftWideMemo
                                                                                  {$ENDIF}]    Then
                  Begin
                   If (vValue <> Null) And (Trim(vValue) <> cNullvalue) and (Trim(vValue) <> '') Then
                    Begin
                     vValue := DecodeStrings(vValue{$IFDEF FPC}, csUndefined{$ENDIF});
                     {$IFNDEF FPC}{$IF CompilerVersion < 18}
                     vValue := utf8Decode(vValue);
                     {$IFEND}{$ENDIF}
                     If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Size > 0 Then
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsString := Copy(vValue, 1, TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Size)
                     Else
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsString := vValue;
                    End
                   Else
                    TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                  End
                 Else
                  Begin
                   If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftInteger, ftSmallInt, ftAutoinc, ftWord, {$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF} ftLargeint] Then
                    Begin
                     If (Trim(vValue) <> '') And (Trim(vValue) <> cNullvalue) Then
                      Begin
                       If vValue <> Null Then
                        Begin
                         vValue := DecodeStrings(vValue{$IFDEF FPC}, csUndefined{$ENDIF});
                         If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongWord, {$IFEND}{$ENDIF}ftLargeint] Then
                          Begin
                           {$IFNDEF FPC}
                            {$IF CompilerVersion > 21}TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsLargeInt := StrToInt64(vValue);
                            {$ELSE}TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsInteger                     := StrToInt64(vValue);
                            {$IFEND}
                           {$ELSE}
                            TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsLargeInt := StrToInt64(vValue);
                           {$ENDIF}
                          End
                         Else
                          TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsInteger  := StrToInt(vValue);
                        End;
                      End
                     Else
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}] Then
                    Begin
                     If (vValue <> Null) And
                        (Trim(vValue) <> cNullvalue) and
                        (Trim(vValue) <> '') Then
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsFloat  := StrToFloat(BuildFloatString(vValue))
                     Else
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                    End
                   Else If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                    Begin
                     If (vValue       <> Null)   And
                        (Trim(vValue) <> cNullvalue) And
                        (Trim(vValue) <> '')     And
                        (Trim(vValue) <> '0')    Then
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsDateTime  := UnixToDateTime(StrToInt64(vValue))
                     Else
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                    End  //Tratar Blobs de Parametros...
                   Else If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                                  ftGraphic, ftOraBlob, ftOraClob] Then
                    Begin
                     vStringStream := TMemoryStream.Create;
                     Try
                      If (vValue <> cNullvalue) And
                         (vValue <> '') Then
                       Begin
                        vStringStream := Decodeb64Stream(vValue);
  //                      HexToStream(vValue, vStringStream);
                        vStringStream.Position := 0;
                        TBlobfield(TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name)).LoadFromStream(vStringStream); //, ftBlob);
                       End
                      Else
                       TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                     Finally
                      FreeAndNil(vStringStream);
                     End;
                    End
                   Else If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType in [ftBoolean, ftInterface, ftIDispatch, ftGuid] Then
                    Begin
                     If TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).DataType = ftBoolean Then
                      TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Value := StringToBoolean(vValue)
                     Else
                      Begin
                       If vValue <> '' Then
                        TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).AsString := DecodeStrings(vValue{$IFDEF FPC}, csUndefined{$ENDIF})
                       Else
                        TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                      End;
                    End
                   Else If (vValue <> Null) And
                           (Trim(vValue) <> cNullvalue) Then
                    TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Value := vValue
                   Else
                    TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).Clear;
                  End;
                 If vOldReadOnly Then
                  TRESTDWTable(Dataset).Post;
                 TRESTDWTable(Dataset).FindField(TDWJSONObject(bJsonValueY).Pairs[0].Name).ReadOnly := vOldReadOnly;
                End;
              End;
            Finally
             FreeAndNil(bJsonValueY);
            End;
           End;
         Finally
          If Dataset Is TRESTDWClientSQL Then
           Begin
            If TRESTDWClientSQL(Dataset).State in [dsEdit, dsInsert] Then
             TRESTDWClientSQL(Dataset).Post;
            TRESTDWClientSQL(Dataset).GotoBookmark(TBookmark(vBookmarkD));
            TRESTDWClientSQL(Dataset).SetInBlockEvents(False);
           End
          Else If Dataset Is TRESTDWTable Then
           Begin
            If TRESTDWTable(Dataset).State in [dsEdit, dsInsert] Then
             TRESTDWTable(Dataset).Post;
            TRESTDWTable(Dataset).GotoBookmark(TBookmark(vBookmarkD));
            TRESTDWTable(Dataset).SetInBlockEvents(False);
           End;
          FreeAndNil(bJsonValueX);
         End;
        End;
      End;
    Finally
     FreeAndNil(bJsonValueB);
    End;
   End;
 Finally
  MassiveCacheDatasetList.ClearAll;
  FreeAndNil(bJsonArray);
 End;
End;

Procedure TDWMassiveCache.Add(Value         : String;
                              Const Dataset : TDataset);
Begin
 MassiveCacheList.Add(Value);
 If vReflectChanges Then
  Begin
   If Dataset is TRESTDWClientSQLBase Then
    MassiveCacheDatasetList.Add(Dataset);
  End;
End;

Procedure TDWMassiveCache.Clear;
Begin
 MassiveCacheList.ClearAll;
End;

Function TDWMassiveCache.ToJSON : String;
Var
 I : Integer;
 vMassiveLine : String;
Begin
 Result := '[%s]';
 vMassiveLine := '';
 For I := 0 To MassiveCacheList.Count -1 Do
  Begin
   If Length(vMassiveLine) = 0 Then
    vMassiveLine := MassiveCacheList.Items[I]
   Else
    vMassiveLine := vMassiveLine + ', ' + MassiveCacheList.Items[I];
  End;
 If vMassiveLine <> '' Then
  Result := Format(Result, [vMassiveLine])
 Else
  Result := vMassiveLine;
End;

Destructor TDWMassiveCache.Destroy;
Begin
 FreeAndNil(MassiveCacheList);
 FreeAndNil(MassiveCacheDatasetList);
 Inherited;
End;

Procedure TDWMassiveSQLCache.Store(SQL                  : String;
                                   Dataset              : TDataset);
Var
 I                     : Integer;
 vMassiveCacheSQLValue : TDWMassiveCacheSQLValue;
Begin
 If Not Dataset.IsEmpty Then
  Begin
   vMassiveCacheSQLValue := TDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
   vMassiveCacheSQLValue.SQL.Text := SQL;
   For I := 0 To vMassiveCacheSQLValue.Params.Count -1 Do
    Begin
     If Dataset Is TRESTDWClientSQL Then
      Begin
       If TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name) <> Nil Then
        vMassiveCacheSQLValue.Params[I].AssignField(TRESTDWClientSQL(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name)); // .AssignValues(TRESTDWClientSQL(Dataset).Params);
      End
     Else If Dataset Is TRESTDWTable Then
      Begin
       If TRESTDWTable(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name) <> Nil Then
        vMassiveCacheSQLValue.Params[I].AssignField(TRESTDWTable(Dataset).FindField(vMassiveCacheSQLValue.Params[I].Name));
      End;
    End;
  End;
End;

Procedure TDWMassiveSQLCache.Store(MassiveCacheSQLValue : TDWMassiveCacheSQLValue);
Var
 vMassiveCacheSQLValue : TDWMassiveCacheSQLValue;
Begin
 vMassiveCacheSQLValue := TDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
 vMassiveCacheSQLValue.SQL.Text := MassiveCacheSQLValue.SQL.Text;
 vMassiveCacheSQLValue.Params.AssignValues(MassiveCacheSQLValue.Params);
End;

Destructor TDWMassiveCacheSQLValue.Destroy;
Begin
 FreeAndNil(vSQL);
 FreeAndNil(vFetchRowSQL);
 FreeAndNil(vLockSQL);
 FreeAndNil(vUnlockSQL);
 FreeAndNil(vParams);
 FreeAndNil(FMemDS);
 Inherited;
End;

Function ScanParams(SQL : String) : TStringList;
Var
 vTemp        : String;
 FCurrentPos  : PChar;
 vOldChar     : Char;
 vParamName   : String;
 Function GetParamName : String;
 Begin
  Result := '';
  If FCurrentPos^ = ':' Then
   Begin
    Inc(FCurrentPos);
    If vOldChar in [' ', ',', '=', '-', '+', '<', '>', '(', ')', ':', '|'] Then //Correção postada por José no Forum.
//    if vOldChar in [' ', '=', '-', '+', '<', '>', '(', ')', ':', '|'] then
     Begin
      While Not (FCurrentPos^ = #0) Do
       Begin
        if FCurrentPos^ in ['0'..'9', 'A'..'Z','a'..'z', '_'] then

         Result := Result + FCurrentPos^
        Else
         Break;
        Inc(FCurrentPos);
       End;
     End;
   End
  Else
   Inc(FCurrentPos);
  vOldChar := FCurrentPos^;
 End;
Begin
 Result := TStringList.Create;
 vTemp  := SQL;
 FCurrentPos := PChar(vTemp);
 While Not (FCurrentPos^ = #0) do
  Begin
   If Not (FCurrentPos^ in [#0..' ', ',',
                           '''', '"',
                           '0'..'9', 'A'..'Z',
                           'a'..'z', '_',
                           '$', #127..#255]) Then


    Begin
     vParamName := GetParamName;
     If Trim(vParamName) <> '' Then
      Begin
       Result.Add(vParamName);
       Inc(FCurrentPos);
      End;
    End
   Else
    Begin
     vOldChar := FCurrentPos^;
     Inc(FCurrentPos);
    End;
  End;
End;

Function ReturnParams(SQL : String) : TStringList;
Begin
 Result := ScanParams(SQL);
End;

Function ReturnParamsAtual(ParamsList : TParams) : TStringList;
Var
 I : Integer;
Begin
 Result := Nil;
 If ParamsList.Count > 0 Then
  Begin
   Result := TStringList.Create;
   For I := 0 To ParamsList.Count -1 Do
    Result.Add(ParamsList[I].Name);
  End;
End;

Procedure TDWMassiveCacheSQLValue.CreateParams;
Var
 I         : Integer;
 ParamsListAtual,
 ParamList : TStringList;
 Procedure CreateParam(Value : String);
  Function ParamSeek (Name : String) : Boolean;
  Var
   I : Integer;
  Begin
   Result := False;
   For I := 0 To vParams.Count -1 Do
    Begin
     Result := LowerCase(vParams.items[i].Name) = LowerCase(Name);
     If Result Then
      Break;
    End;
  End;
 Begin
  If Not(ParamSeek(Value)) Then
   vParams.CreateParam(ftString, Value, ptInput);
 End;
 Function CompareParams(A, B : TStringList) : Boolean;
 Var
  I, X : Integer;
 Begin
  Result := (A <> Nil) And (B <> Nil);
  If Result Then
   Begin
    For I := 0 To A.Count -1 Do
     Begin
      For X := 0 To B.Count -1 Do
       Begin
        Result := lowercase(A[I]) = lowercase(B[X]);
        If Result Then
         Break;
       End;
      If Not Result Then
       Break;
     End;
   End;
  If Result Then
   Result := B.Count > 0;
 End;
Begin
 ParamList       := ReturnParams(vSQL.Text);
 ParamsListAtual := ReturnParamsAtual(vParams);
 vParamCount     := 0;
 If Not CompareParams(ParamsListAtual, ParamList) Then
  vParams.Clear;
 If ParamList <> Nil Then
 For I := 0 to ParamList.Count -1 Do
  CreateParam(ParamList[I]);
 If ParamList.Count > 0 Then
  vParamCount := vParams.Count;
 ParamList.Free;
 If Assigned(ParamsListAtual) then
  FreeAndNil(ParamsListAtual);
End;

Procedure TDWMassiveCacheSQLValue.SetSQL(Value: TStringList);
Var
 I : Integer;
Begin
 vSQL.Clear;
 For I := 0 To Value.Count -1 do
  vSQL.Add(Value[I]);
End;

Procedure TDWMassiveCacheSQLValue.OnChangingSQL(Sender: TObject);
Begin
 CreateParams;
End;

Function    TDWMassiveCacheSQLValue.ParamByName  (Value : String) : TParam;
Var
 I : Integer;
 vParamName,
 vTempParam : String;
 Function CompareValue(Value1, Value2 : String) : Boolean;
 Begin
   Result := Value1 = Value2;
 End;
Begin
 Result := Nil;
 For I := 0 to vParams.Count -1 do
  Begin
   vParamName := UpperCase(vParams[I].Name);
   vTempParam := UpperCase(Trim(Value));
   if CompareValue(vTempParam, vParamName) then
    Begin
     Result := vParams[I];
     Break;
    End;
  End;
End;

Constructor TDWMassiveCacheSQLValue.Create (aCollection : TCollection);
Begin
 Inherited;
 vSQL            := TStringList.Create;
 vFetchRowSQL    := TStringList.Create;
 vLockSQL        := TStringList.Create;
 vUnlockSQL      := TStringList.Create;
 vParams         := TParams.Create(Self);
 FMemDS          := TMemoryStream.Create;
 vParamCount     := 0;
 vBinaryRequest  := False;
 vMassiveSQLMode := msqlExecute;
 {$IFDEF FPC}
  vSQL.OnChange := @OnChangingSQL;
 {$ELSE}
  vSQL.OnChange := OnChangingSQL;
 {$ENDIF}
End;

Procedure TDWMassiveSQLCache.SetEncoding(Value : TEncodeSelect);
Begin
 vEncoding := Value;
 vMassiveCacheSQLList.vEncoding := vEncoding;
End;

procedure TDWMassiveSQLCache.Clear;
begin
 vMassiveCacheSQLList.Clear;
end;

constructor TDWMassiveSQLCache.Create(AOwner: TComponent);
begin
  inherited;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
 {$ENDIF}
 vMassiveCacheSQLList           := TDWMassiveCacheSQLList.Create(Self, TDWMassiveCacheSQLValue);
 vMassiveCacheSQLList.vEncoding := vEncoding;
end;

destructor TDWMassiveSQLCache.Destroy;
begin

 FreeAndNil(vMassiveCacheSQLList);
  inherited;
end;

function TDWMassiveSQLCache.MassiveCount: Integer;
begin
 Result := vMassiveCacheSQLList.Count;
end;

Function TDWMassiveSQLCache.ParamsToBin(Params : TParams) : String;
Var
 I             : Integer;
 vTempLine,
 vLineParams   : String;
 vStringStream : TStringStream;
Begin
 Result      := '[%s]';
 vLineParams := '';
 For I := 0 To Params.Count -1 Do
  Begin
   vStringStream := TStringStream.Create('');
   Try
    TPropertyPersist(Params[I]).SaveToStream(vStringStream);
    vTempLine := EncodeStrings(vStringStream.DataString{$IFDEF FPC}, csUndefined{$ENDIF});
   Finally
    vStringStream.Free;
   End;
   If I = 0 Then
    vLineParams := Format('"%s"', [vTempLine])
   Else
    vLineParams := vLineParams + Format(', "%s"', [vTempLine]);
  End;
 Result := Format(Result, [vLineParams]);
End;

Function TDWMassiveSQLCache.ToJSON      : String;
Var
 vStringStream : TStringStream;
 vJSONValue,
 vTempJSON,
 vParamsString : String;
 A, I          : Integer;
 vDWParams     : TDWParams;
Begin
 vJSONValue := '';
 Result     := '';
 vDWParams  := Nil;
 For A := 0 To vMassiveCacheSQLList.Count -1 Do
  Begin
   vParamsString := '';
   If Not vMassiveCacheSQLList[A].BinaryRequest Then
    Begin
     vDWParams     := GetDWParams(vMassiveCacheSQLList[A].vParams, vEncoding);
     If Assigned(vDWParams) Then
      vParamsString := EncodeStrings(vDWParams.ToJSON{$IFDEF FPC}, csUndefined{$ENDIF});
    End
   Else
    vParamsString := Encodeb64Stream(vMassiveCacheSQLList[A].MemDS);
   vTempJSON  := Format(cJSONValue, [MassiveSQLMode(vMassiveCacheSQLList[A].vMassiveSQLMode),
                                     EncodeStrings(vMassiveCacheSQLList[A].vSQL.Text{$IFDEF FPC},         csUndefined{$ENDIF}),
                                     vParamsString,
                                     EncodeStrings(vMassiveCacheSQLList[A].vBookmark{$IFDEF FPC},         csUndefined{$ENDIF}),
                                     BooleanToString(vMassiveCacheSQLList[A].vBinaryRequest),
                                     EncodeStrings(vMassiveCacheSQLList[A].vFetchRowSQL.Text{$IFDEF FPC}, csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].vLockSQL.Text{$IFDEF FPC},     csUndefined{$ENDIF}),
                                     EncodeStrings(vMassiveCacheSQLList[A].vUnlockSQL.Text{$IFDEF FPC},   csUndefined{$ENDIF})]);
   If vJSONValue = '' Then
    vJSONValue := vTempJSON
   Else
    vJSONValue := vJSONValue + ', ' + vTempJSON;
   If Assigned(vDWParams) Then
    FreeAndNil(vDWParams);
  End;
 If vJSONValue <> '' Then
  Result       := Format('[%s]', [vJSONValue]);
End;

Function TDWMassiveCacheSQLList.Add : TCollectionItem;
Begin
 Result := TDWMassiveCacheSQLValue(Inherited Add);
End;

procedure TDWMassiveCacheSQLList.ClearAll;
Var
 I      : Integer;
Begin
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
 End;
End;

Function TDWMassiveCacheSQLList.ToJSON      : String;
Var
 vStringStream : TStringStream;
 vJSONValue,
 vTempJSON,
 vParamsString : String;
 A, I          : Integer;
 vDWParams     : TDWParams;
Begin
 vJSONValue := '';
 Result     := '';
 vDWParams  := Nil;
 For A := 0 To Count -1 Do
  Begin
   vParamsString := '';
   If Not Items[A].BinaryRequest Then
    Begin
     vDWParams     := GetDWParams(Items[A].vParams, vEncoding);
     If Assigned(vDWParams) Then
      vParamsString := EncodeStrings(vDWParams.ToJSON{$IFDEF FPC}, csUndefined{$ENDIF});
    End
   Else
    vParamsString := Encodeb64Stream(Items[A].MemDS);
   vTempJSON  := Format(cJSONValue, [MassiveSQLMode(Items[A].vMassiveSQLMode),
                                     EncodeStrings(Items[A].vSQL.Text{$IFDEF FPC},         csUndefined{$ENDIF}),
                                     vParamsString,
                                     EncodeStrings(Items[A].vBookmark{$IFDEF FPC},         csUndefined{$ENDIF}),
                                     BooleanToString(Items[A].vBinaryRequest),
                                     EncodeStrings(Items[A].vFetchRowSQL.Text{$IFDEF FPC}, csUndefined{$ENDIF}),
                                     EncodeStrings(Items[A].vLockSQL.Text{$IFDEF FPC},     csUndefined{$ENDIF}),
                                     EncodeStrings(Items[A].vUnlockSQL.Text{$IFDEF FPC},   csUndefined{$ENDIF})]);
   If vJSONValue = '' Then
    vJSONValue := vTempJSON
   Else
    vJSONValue := vJSONValue + ', ' + vTempJSON;
  End;
 If vJSONValue <> '' Then
  Result       := Format('[%s]', [vJSONValue]);
End;

procedure TDWMassiveCacheSQLList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

Constructor TDWMassiveCacheSQLList.Create(AOwner      : TPersistent;
                                          aItemClass  : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWMassiveCacheSQLValue);
 fOwner  := AOwner;
End;

Destructor TDWMassiveCacheSQLList.Destroy;
begin
 ClearAll;
 inherited;
end;

Function TDWMassiveCacheSQLList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWMassiveCacheSQLList.GetRec(Index: Integer): TDWMassiveCacheSQLValue;
begin
 Result := TDWMassiveCacheSQLValue(Inherited GetItem(Index));
end;

Procedure TDWMassiveCacheSQLList.PutRec(Index: Integer;
  Item: TDWMassiveCacheSQLValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
End;

Constructor TMassiveReplyValue.Create;
Begin
 vOldNewValue := Null;
 vOldValue    := Null;
 vValueName   := '';
End;

Destructor TMassiveReplyValue.Destroy;
Begin
 vOldNewValue := Null;
 vOldValue    := Null;
 vValueName   := '';
 Inherited;
End;

Function TMassiveReplyCache.Add(Item : TMassiveReplyValue) : Integer;
Var
 vItem : ^TMassiveReplyValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveReplyCache.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Constructor TMassiveReplyCache.Create;
Begin
 Inherited Create;
 vBuffername := '';
End;

Procedure TMassiveReplyCache.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveReplyValue(TList(Self).Items[Index]^)) Then
      Begin
       {$IFDEF FPC}
       FreeAndNil(TList(Self).Items[Index]^);
       {$ELSE}
        {$IF CompilerVersion > 33}
         FreeAndNil(TMassiveReplyValue(TList(Self).Items[Index]^));
         {$ELSE}
         FreeAndNil(TList(Self).Items[Index]^);
        {$IFEND}
       {$ENDIF}
      End;
     {$IFDEF FPC}
      Dispose(PMassiveReplyValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveReplyCache.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveReplyCache.GetRec(Index : Integer) : TMassiveReplyValue;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveReplyValue(TList(Self).Items[Index]^);
end;

Function TMassiveReplyCache.ItemByValue(ValueName : String; OldValue : Variant) : TMassiveReplyValue;
Var
 I : Integer;
Begin
 Result := Nil;
 If Assigned(Self) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(ValueName) = Uppercase(Values[I].ValueName)) And
        (Values[I].OldValue   = OldValue)                       Then
      Begin
       Result := Values[I];
       Break;
      End;
    End;
  End;
End;

Procedure TMassiveReplyCache.PutRec(Index: Integer; Item: TMassiveReplyValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveReplyValue(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveReply }

Procedure TMassiveReply.PutRecName(Index : String;
                                   Item  : TMassiveReplyCache);
Var
 I : Integer;
Begin
 If Assigned(Self) Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TMassiveReplyCache(TList(Self).Items[i]^).Buffername)) Then
      Begin
       TMassiveReplyCache(TList(Self).Items[i]^) := Item;
       Break;
      End;
    End;
  End;
End;

Procedure TMassiveReply.UpdateBufferValue(Buffername, ValueName : String; OldValue, NewValue : Variant);
Var
 MassiveReplyCache : TMassiveReplyCache;
 MassiveReplyValue : TMassiveReplyValue;
Begin
 MassiveReplyCache := ItemsString[Buffername];
 If MassiveReplyCache <> Nil Then
  Begin
   MassiveReplyValue := MassiveReplyCache.ItemByValue(ValueName, OldValue);
   If MassiveReplyValue <> Nil Then
    MassiveReplyValue.NewValue  := NewValue;
  End;
End;

Function TMassiveReply.GetRecName(Index : String) : TMassiveReplyCache;
Var
 I : Integer;
Begin
 Result := Nil;
 If Assigned(Self) Then
  Begin
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TMassiveReplyCache(TList(Self).Items[i]^).Buffername)) Then
      Begin
       Result := TMassiveReplyCache(TList(Self).Items[i]^);
       Break;
      End;
    End;
  End;
End;

Function TMassiveReply.Add(Item: TMassiveReplyCache): Integer;
Var
 vItem : ^TMassiveReplyCache;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveReply.AddBufferValue(Buffername, ValueName : String; OldValue, NewValue : Variant);
Var
 MassiveReplyCache : TMassiveReplyCache;
 MassiveReplyValue : TMassiveReplyValue;
Begin
 MassiveReplyCache := ItemsString[Buffername];
 If MassiveReplyCache = Nil Then
  Begin
   MassiveReplyCache            := TMassiveReplyCache.Create;
   MassiveReplyValue            := TMassiveReplyValue.Create;
   MassiveReplyCache.Buffername := Buffername;
   MassiveReplyValue.ValueName  := ValueName;
   MassiveReplyValue.OldValue   := OldValue;
   If VarIsNull(NewValue) Then
    MassiveReplyValue.NewValue  := OldValue
   Else
    MassiveReplyValue.NewValue  := NewValue;
   MassiveReplyCache.Add(MassiveReplyValue);
   Add(MassiveReplyCache);
  End
 Else
  Begin
   MassiveReplyValue := MassiveReplyCache.ItemByValue(ValueName, OldValue);
   If MassiveReplyValue = Nil Then
    Begin
     MassiveReplyValue := TMassiveReplyValue.Create;
     MassiveReplyValue.ValueName := ValueName;
     MassiveReplyValue.OldValue  := OldValue;
     MassiveReplyValue.NewValue  := NewValue;
     MassiveReplyCache.Add(MassiveReplyValue);
    End;
  End;
End;

procedure TMassiveReply.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Procedure TMassiveReply.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveReplyCache(TList(Self).Items[Index]^)) Then
      Begin
       {$IFDEF FPC}
       FreeAndNil(TList(Self).Items[Index]^);
       {$ELSE}
        {$IF CompilerVersion > 33}
         FreeAndNil(TMassiveReplyCache(TList(Self).Items[Index]^));
        {$ELSE}
         FreeAndNil(TList(Self).Items[Index]^);
        {$IFEND}
       {$ENDIF}
      End;
     {$IFDEF FPC}
      Dispose(PMassiveReplyCache(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveReply.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveReply.GetRec(Index : Integer) : TMassiveReplyCache;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveReplyCache(TList(Self).Items[Index]^);
End;

Function TMassiveReply.GetReplyValue(Buffername,
                                     ValueName  : String;
                                     MyValue    : Variant) : TMassiveReplyValue;
Var
 I, X : Integer;
Begin
 Result := Nil;
 For I := 0 To Count -1 Do
  Begin
   If Lowercase(Items[I].Buffername) = Lowercase(Buffername) Then
    Begin
     For X := 0 To Items[I].Count -1 Do
      Begin
       If (Lowercase(Items[I].Values[X].ValueName) =
           Lowercase(ValueName)) And
          (Items[I].Values[X].OldValue = MyValue) Then
        Begin
         Result := Items[I].Values[X];
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TMassiveReply.PutRec      (Index       : Integer;
                                     Item        : TMassiveReplyCache);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveReplyCache(TList(Self).Items[Index]^) := Item;
End;

{ TDWMassiveCacheDatasetList }

Function TDWMassiveCacheDatasetList.Add(Item : TMassiveCacheDataset) : Integer;
Var
 vItem : ^TMassiveCacheDataset;
 vItemsIndex : Integer;
Begin
 vItemsIndex := DatasetExists(Item);
 If vItemsIndex = -1 Then
  Begin
   New(vItem);
   vItem^ := Item;
   Result := TList(Self).Add(vItem);
  End
 Else
  Result := vItemsIndex;
End;

procedure TDWMassiveCacheDatasetList.ClearAll;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 Do
  Self.Delete(I);
 Self.Clear;
End;

Function TDWMassiveCacheDatasetList.DatasetExists(Value : TMassiveCacheDataset) : Integer;
Var
 I : Integer;
Begin
 Result := -1;
 For I := 0 To Count -1 Do
  Begin
   If Items[I] = Value Then
    Begin
     Result := I;
     Break;
    End;
  End;
End;

Procedure TDWMassiveCacheDatasetList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     {$IFDEF FPC}
      Dispose(PMassiveCacheDataset(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
end;

Destructor TDWMassiveCacheDatasetList.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TDWMassiveCacheDatasetList.GetDataset(Dataset : String) : TMassiveCacheDataset;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Count -1 Do
  Begin
   If TMassiveCacheDataset(TList(Self).Items[I]^) Is TRESTDWClientSQLBase Then
    Begin
     If Lowercase(TRESTDWClientSQLBase(TMassiveCacheDataset(TList(Self).Items[I]^)).Componenttag) =
        Lowercase(Dataset) Then
      Begin
       Result := TMassiveCacheDataset(TList(Self).Items[I]^);
       Break;
      End;
    End;
  End;
End;

Function TDWMassiveCacheDatasetList.GetRec(Index : Integer): TMassiveCacheDataset;
begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveCacheDataset(TList(Self).Items[Index]^);
end;

procedure TDWMassiveCacheDatasetList.PutRec(Index : Integer;
                                            Item  : TMassiveCacheDataset);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveCacheDataset(TList(Self).Items[Index]^) := Item;
end;

Procedure TDWMassiveCacheSQLValue.SetMemDS(const Value: TMemoryStream);
Begin
 FMemDS := Value;
End;

Procedure TDWMassiveSQLCache.Store(MemDS: TMemoryStream);
Var
 vMassiveCacheSQLValue : TDWMassiveCacheSQLValue;
Begin
 vMassiveCacheSQLValue                := TDWMassiveCacheSQLValue(vMassiveCacheSQLList.Add);
 vMassiveCacheSQLValue.BinaryRequest  := True;
 vMassiveCacheSQLValue.MemDS.LoadFromStream(MemDS);
End;

End.

