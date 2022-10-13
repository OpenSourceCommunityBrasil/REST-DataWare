unit uRESTDWMemtable;

interface

uses
  uRESTDWCustom,
  Db, DBClient, Classes, DBConsts, Math, uRESTDWFieldsClass, uRESTDWDetailLink, SysUtils;

Type
 TWhileNotEofFeature  = (wnefIgnoreEvents, wnefBeginFirst, wnefBookmarkRecord);
 TWhileNotEofFeatures = Set of TWhileNotEofFeature;
 TFtDataSetEvent      = (fdseBeforeCancel,  fdseAfterCancel,
                         fdseBeforeClose,   fdseAfterClose,
                         fdseBeforeDelete,  fdseAfterDelete,
                         fdseBeforeEdit,    fdseAfterEdit,
                         fdseBeforeInsert,  fdseAfterInsert,
                         fdseBeforeOpen,    fdseAfterOpen,
                         fdseBeforePost,    fdseAfterPost,
                         fdseBeforeRefresh, fdseAfterRefresh,
                         fdseBeforeScroll,  fdseAfterScroll,
                         fdseOnCalcFields,  fdseOnNewRecord,
                         fdseFilterRecord,  fdseStateChange,
                         fdseDataChange);
 TBaseFeatures        = Class(TCustomdwMemtable)
  private
   FIgnoreBookmark : Boolean;
    DataSetStates: Array [0 .. 1] of TDataSetState;
    FOnStateChange: TNotifyEvent;
    FOnDataChange: TDataChangeEvent;
    procedure CheckStructure(UseAutoIncAsInteger: Boolean);
    function GetFields: TFtFields;
    procedure UpdateLastState;

  protected
    FDataSetEvents: Integer;
    function GetFieldCount: Integer; virtual;
    {$IFDEF FPC}
      Procedure DataEvent(Event : TDataEvent;
                          Info  : NativeInt); Override;
    {$ELSE}
     {$IF CompilerVersion <= 22}
      Procedure DataEvent(Event : TDataEvent;
                          Info  : Integer);   Override;
     {$ELSE}
      Procedure DataEvent(Event : TDataEvent;
                          Info  : NativeInt); Override;
     {$IFEND}
    {$ENDIF}
    procedure DoStateChange; virtual;
    procedure DoDataChange(AField: TField); virtual;

    procedure DoAfterCancel; override;
    procedure DoAfterClose; override;
    procedure DoAfterDelete; override;
    procedure DoAfterEdit; override;
    procedure DoAfterInsert; override;
    procedure DoAfterPost; override;
    procedure DoAfterRefresh; override;
    procedure DoAfterScroll; override;
    procedure DoBeforeCancel; override;
    procedure DoBeforeClose; override;
    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforeInsert; override;
    procedure DoBeforeOpen; override;
    procedure DoAfterOpen; override;
    procedure DoBeforePost; override;
    procedure DoBeforeRefresh; override;
    procedure DoBeforeScroll; override;
    procedure DoOnCalcFields; override;
    procedure DoOnNewRecord; override;
//    procedure DoFilterRecord; override;

    procedure BridgeDataSetEvent(ADataSetEvent: TFtDataSetEvent; AField: TField = nil); virtual;

  public
    procedure AfterConstruction; override;
    procedure PostIfModified;
    procedure CopyStructure(ASource: TDataset; AUseAutoIncAsInteger: Boolean = False);
    function GetLastState: TDataSetState;
    property LastState: TDataSetState read GetLastState;
    property FieldCount: Integer read GetFieldCount;

//    property Fields: TFtFields read GetFields;

    procedure WhileNotEof(AMethod: TThreadMethod; AWhileNotEofFeatures: TWhileNotEofFeatures = [wnefBeginFirst, wnefBookmarkRecord]);

    property OnDataChange: TDataChangeEvent read FOnDataChange write FOnDataChange;
    property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;

    procedure EnableDataSetEvents;
    procedure DisableDataSetEvents;
    function IgnoreEvents: Boolean;
    property IgnoreBookmark : Boolean Read FIgnoreBookmark Write FIgnoreBookmark Default False;
  published

  end;

  TRecordStatus = (rsNone, rsPrepareDelete, rsInserted, rsModified, rsDeleted, rsPrepareDeleteModified, rsPrepareDeleteInserted,
    rsModifiedAgain);
  TApplyRecordEvent = procedure(ADataset: TDataset; AUpdateStatus: TUpdateStatus; const AOldValues: TParams; var ANewValues: TParams)
    of object;

  TChangedRecord = class(TSmallintField)
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TRESTDWMemtableControlUpdates = class(TBaseFeatures)

  private
    FChangesDataSet: TBaseFeatures;
    FTransactionDataSet: TBaseFeatures;

    FBookMarkId: Integer;
    FControlUpdates: Boolean;
    FChangeOrder: Integer;
    FOnApplyRecord: TApplyRecordEvent;
    FInTransaction: Boolean;
    FAutoApplyUpdates: Boolean;
    function NextChangeOrder: Integer;
    function NextId: Integer;

    procedure AddChangeRecord(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus);
    procedure ModifyChangeRecord(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus);
    procedure ApplyChangeData(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus);

    procedure GotoBookmarkRecord(ADataSet: TBaseFeatures);
    procedure CreateModificationsDataSet(var ADataSet: TBaseFeatures);
    function LocateRecord(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus = rsNone): Boolean;
    procedure AddBookmarkField;
    procedure CreateApplyParamByField(AParams: TParams; AField: TField);
    procedure SetStatus(ADataSet: TBaseFeatures; const AValue: TRecordStatus);
    function GetStatus(ADataSet: TBaseFeatures): TRecordStatus;
    function GetChangesDataSet: TBaseFeatures;
    function GetTransactionDataSet: TBaseFeatures;
    function CatalogTransaction: Boolean;

    function CatalogUpdates: Boolean;
    procedure RevertChanges(ADataSet: TBaseFeatures);

    procedure MyDoBeforeDelete(ADataSet: TBaseFeatures);
    procedure MyDoAfterDelete(ADataSet: TBaseFeatures);
    procedure MyDoBeforeEdit(ADataSet: TBaseFeatures);
    procedure MyDoAfterPost(ADataSet: TBaseFeatures);
    procedure MyDoAfterClose(ADataSet: TBaseFeatures);
    procedure MyDoAfterCancel(ADataSet: TBaseFeatures);

  protected
    procedure ApplyAutogenerateFieldValues(ANewValues: TParams); virtual;
    function GetInTransaction: Boolean; virtual;
    procedure SetAutoApplyUpdates(const Value: Boolean); virtual;
    procedure ApplyRecord; virtual;
    procedure DoApplyRecord(AUpdateStatus: TUpdateStatus; const AOldValues: TParams; var ANewValues: TParams); virtual;

    procedure DoBeforeDelete; override;
    procedure DoAfterDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoAfterPost; override;
    procedure DoAfterClose; override;
    procedure DoAfterCancel; override;

    procedure DoOnNewRecord; override;
    procedure DoBeforeOpen; override;

  public
    property ChangesDataSet: TBaseFeatures read GetChangesDataSet;
    property TransactionDataSet: TBaseFeatures read GetTransactionDataSet;
    procedure ApplyUpdates; virtual;
    procedure BeforeApplyUpdates; virtual;
    procedure AfterApplyUpdates; virtual;
    procedure CancelUpdates; virtual;
    procedure ClearUpdates; virtual;
    procedure DoApplyUpdatesError(E: Exception; var ARaiseException: Boolean); virtual;

    property InTransaction: Boolean read GetInTransaction;

    procedure StartTransaction; reintroduce; virtual;
    procedure CommitTransaction; virtual;
    procedure RollbackTransaction; virtual;
    constructor Create(AOwner: TComponent); override;
  published
    procedure SetControlUpdates(const Value: Boolean);
    property ControlUpdates: Boolean read FControlUpdates write SetControlUpdates;
    property AutoApplyUpdates: Boolean read FAutoApplyUpdates write SetAutoApplyUpdates;
    property OnApplyRecord: TApplyRecordEvent read FOnApplyRecord write FOnApplyRecord;
  end;

  TIgnoreEvents = class(TRESTDWMemtableControlUpdates)

  protected
    procedure BridgeDataSetEvent(ADataSetEvent: TFtDataSetEvent; AField: TField = nil); override;

//    procedure StateChange; reintroduce; virtual;
//    procedure DataChange(AField: TField); reintroduce; virtual;
    procedure DoAfterCancel; reintroduce; virtual;
    procedure DoAfterClose; reintroduce; virtual;
    procedure DoAfterDelete; reintroduce; virtual;
    procedure DoAfterEdit; reintroduce; virtual;
    procedure DoAfterInsert; reintroduce; virtual;
    procedure DoAfterPost; reintroduce; virtual;
    procedure DoAfterRefresh; reintroduce; virtual;
    procedure DoAfterScroll; reintroduce; virtual;
    procedure DoBeforeCancel; reintroduce; virtual;
    procedure DoBeforeClose; reintroduce; virtual;
    procedure DoBeforeDelete; reintroduce; virtual;
    procedure DoBeforeEdit; reintroduce; virtual;
    procedure DoBeforeInsert; reintroduce; virtual;
    procedure DoBeforeOpen; reintroduce; virtual;
    procedure DoAfterOpen; reintroduce; virtual;
    procedure DoBeforePost; reintroduce; virtual;
    procedure DoBeforeRefresh; reintroduce; virtual;
    procedure DoBeforeScroll; reintroduce; virtual;
    procedure DoOnCalcFields; reintroduce; virtual;
    procedure DoOnNewRecord; reintroduce; virtual;
    procedure DoFilterRecord; reintroduce; virtual;
  end;

type
  TRESTDWMemtable = class(TIgnoreEvents)
  Public
   Procedure LoadFromStream(Stream : TStream);
  published
    property Active;
    property Filter;
    property Filtered;
    property FilterOptions;
    property Fields;
    property FieldDefs;
    property IndexDefs;
    property IndexFieldNames;
    property IndexName;
    property MasterFields;
    property MasterSource;
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
    property BeforeRefresh;
    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    property OnDataChange;
    property OnStateChange;
  end;

const
  ftBlobTypes = [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftOraBlob, ftOraClob
{$IFDEF COMPILER10_UP}, ftWideMemo{$ENDIF COMPILER10_UP}];
  ftSupported = [ftString, ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftDate, ftTime, ftDateTime, ftAutoInc,
    ftBCD, ftFMTBCD, ftTimestamp,
{$IFDEF COMPILER10_UP}
  ftOraTimestamp, ftFixedWideChar,
{$ENDIF COMPILER10_UP}
{$IFDEF COMPILER12_UP}
  ftLongWord, ftShortint, ftByte, ftExtended,
{$ENDIF COMPILER12_UP}
  ftBytes, ftVarBytes, ftADT, ftFixedChar, ftWideString, ftLargeint, ftVariant, ftGuid] + ftBlobTypes;

  RECORD_STATUS_FIELD_NAME = 'E18AC7EE727F4558A8C9EB1EB2218BA6';
  UPDATE_ORDER_FIELD_NAME = 'D7F727799DCA40B6BF9FF11D302B0680';
  BOOKMARK_FIELD_NAME = 'D0300807B31C41E6ADF86D8316E1CB8E';

implementation

uses
  Variants;

const
  INTERNAL_FIRST = 0;

procedure SetFieldValue(Field: TField; Value: variant);
var
  vReadOnly: Boolean;
  vLastState: TDataSetState;
begin
  vReadOnly := False;
  if Value = Unassigned then Exit;

  if Field.Value <> Value then begin
    vLastState := Field.Dataset.State;
    if not(vLastState in [dsEdit, dsInsert]) then
      Field.Dataset.Edit;
    try
      vReadOnly := Field.ReadOnly;
      Field.ReadOnly := False;
      if (VarToStr(Value) = '') and (Field.DataType in [ftDate, ftDateTime, ftTime]) then begin
        Field.AsDateTime := 0;
      end else if (VarToStr(Value) = '') and (Field is TNumericField) then begin
        Field.AsInteger := 0;
      end else begin
        Field.Value := Value;
      end;
      if not(vLastState in [dsEdit, dsInsert]) then
        Field.Dataset.Post;
    finally
      Field.ReadOnly := vReadOnly;
    end;
  end;
end;

procedure AssignRecord(Source, Dest: TDataset; ByName: Boolean);
var
  I: Integer;
  F, FSrc: TField;
begin
  if not(Dest.State in dsEditModes) then
    DatabaseError(SNotEditing);
  if ByName then begin
    for I := 0 to Source.FieldCount - 1 do begin
      F := Dest.FindField(Source.Fields[I].FieldName);
      FSrc := Source.Fields[I];
      if (F <> nil) and (F.DataType <> ftAutoInc) then begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
            ftString:
              F.AsString := FSrc.AsString;
            ftInteger:
              F.AsInteger := FSrc.AsInteger;
            ftBoolean:
              F.AsBoolean := FSrc.AsBoolean;
            ftFloat:
              F.AsFloat := FSrc.AsFloat;
            ftCurrency:
              F.AsCurrency := FSrc.AsCurrency;
            ftDate:
              F.AsDateTime := FSrc.AsDateTime;
            ftDateTime:
              F.AsDateTime := FSrc.AsDateTime;
          else
            F.Value := FSrc.Value;
          end;
      end;
    end;
  end else begin
    for I := 0 to Min(Source.FieldDefs.Count - 1, Dest.FieldDefs.Count - 1) do begin
      F := Dest.FindField(Dest.FieldDefs[I].Name);
      FSrc := Source.FindField(Source.FieldDefs[I].Name);
      if (F <> nil) and (FSrc <> nil) and (F.DataType <> ftAutoInc) then begin
        if FSrc.IsNull then
          F.Value := FSrc.Value
        else
          case F.DataType of
            ftString:
              F.AsString := FSrc.AsString;
            ftInteger:
              F.AsInteger := FSrc.AsInteger;
            ftBoolean:
              F.AsBoolean := FSrc.AsBoolean;
            ftFloat:
              F.AsFloat := FSrc.AsFloat;
            ftCurrency:
              F.AsCurrency := FSrc.AsCurrency;
            ftDate:
              F.AsDateTime := FSrc.AsDateTime;
            ftDateTime:
              F.AsDateTime := FSrc.AsDateTime;
          else
            F.Value := FSrc.Value;
          end;
      end;
    end;
  end;
end;

procedure TIgnoreEvents.BridgeDataSetEvent(ADataSetEvent: TFtDataSetEvent; AField: TField = nil);
begin
  inherited;
  case ADataSetEvent of
    fdseBeforeCancel: DoBeforeCancel;
    fdseAfterCancel: DoAfterCancel;
    fdseBeforeClose: DoBeforeClose;
    fdseAfterClose: DoAfterClose;
    fdseBeforeDelete: DoBeforeDelete;
    fdseAfterDelete: DoAfterDelete;
    fdseBeforeEdit: DoBeforeEdit;
    fdseAfterEdit: DoAfterEdit;
    fdseBeforeInsert: DoBeforeInsert;
    fdseAfterInsert: DoAfterInsert;
    fdseBeforeOpen: DoBeforeOpen;
    fdseAfterOpen: DoAfterOpen;
    fdseBeforePost: DoBeforePost;
    fdseAfterPost: DoAfterPost;
    fdseBeforeRefresh: DoBeforeRefresh;
    fdseAfterRefresh: DoAfterRefresh;
    fdseBeforeScroll: DoBeforeScroll;
    fdseAfterScroll: DoAfterScroll;
    fdseOnCalcFields: DoOnCalcFields;
    fdseOnNewRecord: DoOnNewRecord;
    fdseFilterRecord: DoFilterRecord;
//    fdseDataChange: DoDataChange(AField);
//    fdseStateChange: DoStateChange;
  end;
end;

procedure TIgnoreEvents.DoAfterCancel;
begin
end;
procedure TIgnoreEvents.DoAfterClose;
begin
end;
procedure TIgnoreEvents.DoAfterDelete;
begin
end;
procedure TIgnoreEvents.DoAfterEdit;
begin
end;
procedure TIgnoreEvents.DoAfterInsert;
begin
end;
procedure TIgnoreEvents.DoAfterOpen;
begin
end;
procedure TIgnoreEvents.DoAfterPost;
begin
end;
procedure TIgnoreEvents.DoAfterRefresh;
begin
end;
procedure TIgnoreEvents.DoAfterScroll;
begin
end;
procedure TIgnoreEvents.DoBeforeCancel;
begin
end;
procedure TIgnoreEvents.DoBeforeClose;
begin
end;
procedure TIgnoreEvents.DoBeforeDelete;
begin
end;
procedure TIgnoreEvents.DoBeforeEdit;
begin
end;
procedure TIgnoreEvents.DoBeforeInsert;
begin
end;
procedure TIgnoreEvents.DoBeforeOpen;
begin
end;
procedure TIgnoreEvents.DoBeforePost;
begin
end;
procedure TIgnoreEvents.DoBeforeRefresh;
begin
end;
procedure TIgnoreEvents.DoBeforeScroll;
begin
end;
procedure TIgnoreEvents.DoFilterRecord;
begin
end;
procedure TIgnoreEvents.DoOnCalcFields;
begin
end;
procedure TIgnoreEvents.DoOnNewRecord;
begin
end;

{TBaseFeatures}

procedure TBaseFeatures.DoAfterCancel;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterCancel);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterClose;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterClose);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterDelete;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterDelete);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterInsert;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterInsert);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterOpen;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterOpen);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterEdit;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterEdit);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterPost;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterPost);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterRefresh;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterRefresh);
    inherited;
  end;
end;

procedure TBaseFeatures.DoAfterScroll;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseAfterScroll);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeCancel;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeCancel);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeClose;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeClose);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeDelete;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeDelete);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeEdit;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeEdit);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeInsert;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeInsert);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeOpen;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeOpen);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforePost;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforePost);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeRefresh;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeRefresh);
    inherited;
  end;
end;

procedure TBaseFeatures.DoBeforeScroll;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseBeforeScroll);
    inherited;
  end;
end;

procedure TBaseFeatures.DoOnCalcFields;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseOnCalcFields);
    inherited;
  end;
end;

procedure TBaseFeatures.DoOnNewRecord;
begin
  if not IgnoreEvents then begin
    BridgeDataSetEvent(fdseOnNewRecord);
    inherited;
  end;
end;

procedure TBaseFeatures.DoDataChange(AField: TField);
begin
  if not IgnoreEvents then begin
    if Assigned(FOnDataChange) then
      FOnDataChange(Self, AField);
//    BridgeDataSetEvent(fdseDataChange, AField);
  end;
end;

procedure TBaseFeatures.DoStateChange;
begin
  {UpdateLastState; foiremovido daqui para o DataEvent. Verificar se vai funcioanr bem 04/05/21}
  if not IgnoreEvents then begin
    if Assigned(FOnStateChange) then
      FOnStateChange(Self);
//    BridgeDataSetEvent(fdseStateChange);
  end;
end;

procedure TBaseFeatures.EnableDataSetEvents;
begin
  if FDataSetEvents > 0 then
    Dec(FDataSetEvents);
  if FDataSetEvents = 0 then
    DataEvent(deUpdateState, 0);
end;

procedure TBaseFeatures.UpdateLastState;
begin
  DataSetStates[0] := DataSetStates[1];
  DataSetStates[1] := State;
end;

procedure TBaseFeatures.WhileNotEof(AMethod: TThreadMethod; AWhileNotEofFeatures: TWhileNotEofFeatures);
var
  vBookMark: TBookmark;
begin
  if IsEmpty then
    Exit;
  try
    DisableControls;
    if wnefBookmarkRecord in AWhileNotEofFeatures then
      vBookMark := GetBookmark;

    if wnefIgnoreEvents in AWhileNotEofFeatures then begin
      DisableDataSetEvents;
    end;

    if wnefBeginFirst in AWhileNotEofFeatures then
      First;

    while not Eof do begin
      AMethod;
      Next;
    end;
  finally
    if wnefIgnoreEvents in AWhileNotEofFeatures then
      EnableDataSetEvents;
    if wnefBookmarkRecord in AWhileNotEofFeatures then
      if BookmarkValid(vBookMark) then
        GotoBookmark(vBookMark);
    EnableControls;
  end;
end;

procedure TBaseFeatures.AfterConstruction;
var
  I: Integer;
begin
  inherited;
  {$IFDEF  KBM_FT}
  AutoReposition := True;
  {$ENDIF}
  DataSetStates[0] := dsInactive;
  DataSetStates[1] := dsInactive;
end;

procedure TBaseFeatures.BridgeDataSetEvent(ADataSetEvent: TFtDataSetEvent; AField: TField = nil);
begin
end;

procedure TBaseFeatures.CheckStructure(UseAutoIncAsInteger: Boolean);

  procedure CheckDataTypes(FieldDefs: TFieldDefs);
  var
    J: Integer;
  begin
    for J := FieldDefs.Count - 1 downto 0 do begin
      if (FieldDefs.Items[J].DataType = ftAutoInc) and UseAutoIncAsInteger then
        FieldDefs.Items[J].DataType := ftInteger;
      if not(FieldDefs.Items[J].DataType in ftSupported) then
        FieldDefs.Items[J].Free;
    end;
  end;

var
  I: Integer;
begin
  CheckDataTypes(FieldDefs);
  for I := 0 to FieldDefs.Count - 1 do
    if (csDesigning in ComponentState) and (Owner <> nil) then
      FieldDefs.Items[I].CreateField(Owner)
    else
      FieldDefs.Items[I].CreateField(Self);
end;

procedure TBaseFeatures.CopyStructure(ASource: TDataset; AUseAutoIncAsInteger: Boolean);
var
  I: Integer;
begin
  if ASource = nil then
    Exit;
  CheckInactive;
  for I := FieldCount - 1 downto 0 do
    Fields[I].Free;

  // Source.FieldDefs.Update;
  FieldDefs := ASource.FieldDefs;
  CheckStructure(AUseAutoIncAsInteger);
end;

function TBaseFeatures.GetFieldCount: Integer;
begin
  Result := TFtFields(Fields).Count;
end;

function TBaseFeatures.GetFields: TFtFields;
begin
  Result := TFtFields(Fields);
end;

//function TBaseFeatures.GetFieldsClass: TFieldsClass;
//begin
//  Result := TFtFields;
//end;

function TBaseFeatures.GetLastState: TDataSetState;
begin
  Result := DataSetStates[0];
end;

function TBaseFeatures.IgnoreEvents: Boolean;
begin
  Result := FDataSetEvents > 0;
end;

procedure TBaseFeatures.PostIfModified;
begin
  if Modified then
    Post
  else
    Cancel;
end;

{$IFDEF FPC}
{$ELSE}
 {$IF CompilerVersion <= 22}
  Procedure TBaseFeatures.DataEvent(Event : TDataEvent;
                                    Info  : Integer);
 {$ELSE}
  Procedure TBaseFeatures.DataEvent(Event : TDataEvent;
                                    Info  : NativeInt);
 {$IFEND}
{$ENDIF}
var
  IsActive: Boolean;
  NotifyDataSources: Boolean;

  procedure UpdateCalcFields;
  begin
    if State <> dsSetKey then
    begin
      if InternalCalcFields and (TField(Info).FieldKind = fkData) then
        RefreshInternalCalcFields(ActiveBuffer)
      else if (CalcFieldsSize <> 0) and AutoCalcFields and
        (TField(Info).FieldKind = fkData) then
        CalculateFields(ActiveBuffer);
      {TField(Info).Change;}
    end;
  end;

begin
  if IgnoreEvents then begin
    case Event of
      deFieldChange: begin
        if TField(Info).FieldKind in [fkData, fkInternalCalc] then
          SetModified(True);
        UpdateCalcFields;
      end;
    end;
  end else begin
    inherited;
    case Event of
      deUpdateState:
        DoStateChange;
      deFieldChange: begin
        DoDataChange(TField(Info));
      end;
    end;
  end;
  if Event = deUpdateState then UpdateLastState;
end;

procedure TBaseFeatures.DisableDataSetEvents;
begin
  Inc(FDataSetEvents);
end;

procedure TRESTDWMemtableControlUpdates.CancelUpdates;
begin
  RevertChanges(ChangesDataSet);
end;

function TRESTDWMemtableControlUpdates.CatalogUpdates: Boolean;
begin
  Result := (not IgnoreEvents) and (ControlUpdates);
end;

function TRESTDWMemtableControlUpdates.CatalogTransaction: Boolean;
begin
  Result := (not IgnoreEvents) and (InTransaction);
end;

procedure TRESTDWMemtableControlUpdates.ClearUpdates;
begin
  if not ControlUpdates then
    Exit;
  ChangesDataSet.CleanData;
end;

procedure TRESTDWMemtableControlUpdates.CommitTransaction;
begin
  FInTransaction := False;
  TransactionDataSet.CleanData;
end;

Constructor TRESTDWMemtableControlUpdates.Create(AOwner: TComponent);
Begin
 Inherited;
 IgnoreBookmark := True;
end;

procedure TRESTDWMemtableControlUpdates.CreateApplyParamByField(AParams: TParams; AField: TField);
var
  vFieldValue: variant;
begin
  vFieldValue := Null;
  case AField.DataType of
    ftString, ftWideString:
      vFieldValue := AField.Value;
    ftBlob: begin
      if not AField.IsNull then
        vFieldValue := AField.Value;
    end
  else
    vFieldValue := AField.Value;
  end;

  if AField.AutoGenerateValue = arNone then begin
    with TParam.Create(AParams, ptInput) do begin
      DataType := AField.DataType;
      if AField.DataType = ftBlob then begin
        if vFieldValue <> NULL then begin
          AsBlob := vFieldValue;
        end;
      end else begin
        Value := vFieldValue;
      end;
      Name := AField.FieldName;
    end;
  end else begin
    with TParam.Create(AParams, ptOutput) do begin
      DataType := AField.DataType;
      Name := AField.FieldName;
    end;
  end;

end;

procedure TRESTDWMemtableControlUpdates.CreateModificationsDataSet(var ADataSet: TBaseFeatures);
var
  I: Integer;
begin
  FreeAndNil(ADataSet);
  ADataSet := TBaseFeatures.Create(Self);

  ADataSet.CopyStructure(Self);

  with TChangedRecord.Create(ADataSet) do begin
    FieldName := RECORD_STATUS_FIELD_NAME;
    Dataset := ADataSet;
    DisplayLabel := 'Record status';
  end;

  with TIntegerField.Create(ADataSet) do begin
    FieldName := UPDATE_ORDER_FIELD_NAME;
    Dataset := ADataSet;
    DisplayLabel := 'Update order';
  end;

  If Not IgnoreBookmark Then
  if ADataSet.FindField(BOOKMARK_FIELD_NAME) = nil then begin
    with TIntegerField.Create(ADataSet) do begin
      FieldName := BOOKMARK_FIELD_NAME;
      Dataset := ADataSet;
    end;
  end;
  If Not IgnoreBookmark Then
   Begin
    ADataSet.FindField(BOOKMARK_FIELD_NAME).DisplayLabel := 'Bookmark';
//    ADataSet.Fields.InternalAddedFields := 3;
   End;
//  Else
//   ADataSet.Fields.InternalAddedFields := 2;
  for I := 0 to ADataSet.Fields.Count - 1 do begin
    ADataSet.Fields[I].ReadOnly := False;
    ADataSet.Fields[I].Required := False;
  end;

  ADataSet.Open;
end;

procedure TRESTDWMemtableControlUpdates.DoBeforeOpen;
begin
  inherited;
  FBookMarkId := 0;
  If Not IgnoreBookmark Then
   AddBookmarkField;
end;

procedure TRESTDWMemtableControlUpdates.DoOnNewRecord;
begin
  If Not IgnoreBookmark Then
   FieldByName(BOOKMARK_FIELD_NAME).AsInteger := NextId;
  inherited;
end;

function TRESTDWMemtableControlUpdates.GetChangesDataSet: TBaseFeatures;
begin
  if FChangesDataSet = nil then
    CreateModificationsDataSet(FChangesDataSet);
  Result := FChangesDataSet;
end;

function TRESTDWMemtableControlUpdates.GetInTransaction: Boolean;
begin
  Result := FInTransaction;
end;

function TRESTDWMemtableControlUpdates.GetStatus(ADataSet: TBaseFeatures): TRecordStatus;
begin
  Result := TRecordStatus(ADataSet.FieldByName(RECORD_STATUS_FIELD_NAME).AsInteger);
end;

function TRESTDWMemtableControlUpdates.GetTransactionDataSet: TBaseFeatures;
begin
  if FTransactionDataSet = nil then
    CreateModificationsDataSet(FTransactionDataSet);
  Result := FTransactionDataSet;
end;

procedure TRESTDWMemtableControlUpdates.GotoBookmarkRecord(ADataSet: TBaseFeatures);
begin
 If Not IgnoreBookmark Then
  if FieldByName(BOOKMARK_FIELD_NAME).AsInteger <> ADataSet.FieldByName(BOOKMARK_FIELD_NAME).AsInteger then
    Locate(BOOKMARK_FIELD_NAME, ADataSet.FieldByName(BOOKMARK_FIELD_NAME).AsInteger, []);

  {Este else era com a tentativa de utilizar o bookmark em vez de usar um campo adicional.
   Mas a depois de resolvida a questão não ha mais necesisdade da utulização do GotoBookMark, porém
   o ideal seria não rpecisar utilizar o campo adicional e por isso foi deixado esta parte do código caso
   seja possível utilizar no futuro}
  //GotoBookmark(TBookmark(ADataSet.FieldByName(BOOKMARK_FIELD_NAME).AsInteger));
end;

function TRESTDWMemtableControlUpdates.LocateRecord(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus = rsNone): Boolean;
var
  VFieldValues: Array of variant;
begin
 If Not IgnoreBookmark Then
  Begin
   SetLength(VFieldValues, 2);
   vFieldValues[0] := FieldByName(BOOKMARK_FIELD_NAME).Value;
   vFieldValues[1] := Ord(ARecordStatus);
   Result := ADataSet.Locate(BOOKMARK_FIELD_NAME + ';' + RECORD_STATUS_FIELD_NAME, vFieldValues, []);
  End;
end;

procedure TRESTDWMemtableControlUpdates.ModifyChangeRecord(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus);
begin
  if ADataSet <> nil then begin
    ADataSet.Edit;
    ApplyChangeData(ADataSet, ARecordStatus);
    ADataSet.Post;
  end;
end;

procedure TRESTDWMemtableControlUpdates.MyDoAfterCancel(ADataSet: TBaseFeatures);
begin
  if LastState = dsEdit then
    if GetStatus(ADataSet) = rsModifiedAgain then
      SetStatus(ADataSet, rsModified)
    else
      ADataSet.Delete;
end;

procedure TRESTDWMemtableControlUpdates.MyDoAfterClose(ADataSet: TBaseFeatures);
begin

end;

procedure TRESTDWMemtableControlUpdates.MyDoAfterDelete(ADataSet: TBaseFeatures);
begin
  case GetStatus(ADataSet) of
    rsPrepareDeleteInserted:
      ADataSet.Delete;
    rsPrepareDeleteModified, rsPrepareDelete:
      SetStatus(ADataSet, rsDeleted);
  end;
end;

procedure TRESTDWMemtableControlUpdates.MyDoAfterPost(ADataSet: TBaseFeatures);
var
  vRecordStatus: TRecordStatus;
begin
  vRecordStatus := GetStatus(ADataSet);
  if (LastState = dsInsert) then
    AddChangeRecord(ADataSet, rsInserted)
  else if (LastState = dsEdit) and (vRecordStatus = rsModifiedAgain) then
    SetStatus(ADataSet, rsModified)
  else if LocateRecord(ADataSet, rsInserted) then
    ModifyChangeRecord(ADataSet, rsInserted);
end;

procedure TRESTDWMemtableControlUpdates.MyDoBeforeDelete(ADataSet: TBaseFeatures);
begin
  if LocateRecord(ADataSet, rsInserted) then begin
    SetStatus(ADataSet, rsPrepareDeleteInserted)
  end else if LocateRecord(ADataSet, rsModified) then begin
    SetStatus(ADataSet, rsPrepareDeleteModified)
  end else begin
    AddChangeRecord(ADataSet, rsPrepareDelete);
  end;
end;

procedure TRESTDWMemtableControlUpdates.MyDoBeforeEdit(ADataSet: TBaseFeatures);
begin
  if (not LocateRecord(ADataSet, rsModified)) and (not LocateRecord(ADataSet, rsInserted)) then begin
    AddChangeRecord(ADataSet, rsModified)
  end else if LocateRecord(ADataSet, rsModified) then begin
    SetStatus(ADataSet, rsModifiedAgain);
  end;
end;

function TRESTDWMemtableControlUpdates.NextChangeOrder: Integer;
begin
  FChangeOrder := FChangeOrder + 1;
  Result := FChangeOrder;
end;

function TRESTDWMemtableControlUpdates.NextId: Integer;
begin
  FBookMarkId := FBookMarkId + 1;
  Result := FBookMarkId;
end;

procedure TRESTDWMemtableControlUpdates.RevertChanges(ADataSet: TBaseFeatures);
var
  iRecNo: Integer;
  vBookMark: TBookmark;
begin
  if not ControlUpdates then
    Exit;
  if ADataSet.IsEmpty then
    Exit;
  try
    DisableDataSetEvents;
    DisableControls;
    ADataSet.DisableControls;
    vBookMark := GetBookmark;
    ADataSet.SortOn(RECORD_STATUS_FIELD_NAME);
    ADataSet.First;
    while not ADataSet.Eof do begin
      case GetStatus(ADataSet) of
        rsDeleted: begin
            Insert;
            AssignRecord(ADataSet, Self, True);
            Post;
          end;
        rsModified: begin
            GotoBookmarkRecord(ADataSet);
            Edit;
            AssignRecord(ADataSet, Self, True);
            Post;
          end;
        rsInserted: begin
            GotoBookmarkRecord(ADataSet);
            Delete;
          end;
      end;
      ADataSet.Next;
    end;
    // if FindField(BOOKMARK_FIELD_NAME) <> nil then
    // SortOn(BOOKMARK_FIELD_NAME);
    ADataSet.CleanData;
  finally
    if BookmarkValid(vBookMark) then
      GotoBookmark(vBookMark);
    ADataSet.EnableControls;
    EnableControls;
    EnableDataSetEvents;
  end;
end;

procedure TRESTDWMemtableControlUpdates.RollbackTransaction;
begin
  FInTransaction := False;
  RevertChanges(TransactionDataSet);
  ChangesDataSet.CleanData;
end;

procedure TRESTDWMemtableControlUpdates.SetAutoApplyUpdates(const Value: Boolean);
begin
  FAutoApplyUpdates := Value;
  if Value then begin
    if not ControlUpdates then
      ControlUpdates := True;
  end;
end;

procedure TRESTDWMemtableControlUpdates.SetControlUpdates(const Value: Boolean);
begin
  if FControlUpdates = Value then
    Exit;

  if Value then begin
    FChangeOrder := 0;
  end else begin
    FreeAndNil(FChangesDataSet);
  end;
  FControlUpdates := Value;
end;

procedure TRESTDWMemtableControlUpdates.SetStatus(ADataSet: TBaseFeatures; const AValue: TRecordStatus);
begin
  ADataSet.Edit;
  ADataSet.FieldByName(RECORD_STATUS_FIELD_NAME).AsInteger := Ord(AValue);
  ADataSet.Post;
end;

procedure TRESTDWMemtableControlUpdates.StartTransaction;
begin
  FInTransaction := True;
end;

procedure TRESTDWMemtableControlUpdates.ApplyAutogenerateFieldValues(ANewValues: TParams);
var
  I: Integer;
begin
  if ANewValues.Count = 0 then Exit;
  
  try
    DisableDataSetEvents;
    Edit;
    for I := 0 to ANewValues.Count - 1 do begin
      if ANewValues[I].ParamType = ptOutput then begin
        SetFieldValue(FieldByName(ANewValues[I].Name), ANewValues[I].Value);
      end;
    end;
    PostIfModified;
  finally
    EnableDataSetEvents;
  end;
end;

procedure TRESTDWMemtableControlUpdates.ApplyChangeData(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus);
begin
  if ADataSet <> nil then begin
    AssignRecord(Self, ADataSet, True);
    ADataSet.FieldByName(RECORD_STATUS_FIELD_NAME).AsInteger := Ord(ARecordStatus);
    ADataSet.FieldByName(UPDATE_ORDER_FIELD_NAME).AsInteger := NextChangeOrder;
  end;
end;

procedure TRESTDWMemtableControlUpdates.ApplyUpdates;
var
  vBookMark: TBookmark;
  vRaiseException: Boolean;
begin
  vRaiseException := True;
  if not ControlUpdates then
    Exit;
  if ChangesDataSet.IsEmpty then
    Exit;
  try
    try
      BeforeApplyUpdates;
      DisableDataSetEvents;
      DisableControls;
      ChangesDataSet.DisableControls;
      vBookMark := GetBookmark;
      ChangesDataSet.SortOn(UPDATE_ORDER_FIELD_NAME);
      ChangesDataSet.First;
      while not ChangesDataSet.Eof do begin
        if GetStatus(ChangesDataSet) in [rsInserted, rsModified, rsDeleted] then
          ApplyRecord;
        ChangesDataSet.Next;
      end;
      ChangesDataSet.CleanData;
      AfterApplyUpdates;
    except
      on E: Exception do begin
        DoApplyUpdatesError(E, vRaiseException);
       {TODO -odwMemtable -cToImplement : Implementar um evento OnApplyUpdatesError}
        if vRaiseException then
          raise ;
      end;
    end;
  finally
    if BookmarkValid(vBookMark) then
      GotoBookmark(vBookMark);
    ChangesDataSet.EnableControls;
    EnableControls;
    EnableDataSetEvents;
  end;

end;

procedure TRESTDWMemtableControlUpdates.BeforeApplyUpdates;
begin

end;

procedure TRESTDWMemtableControlUpdates.DoAfterCancel;
begin
  inherited;
  if CatalogUpdates then
    MyDoAfterCancel(ChangesDataSet);
  if CatalogTransaction then
    MyDoAfterCancel(TransactionDataSet);
end;

procedure TRESTDWMemtableControlUpdates.DoAfterClose;
begin
  FreeAndNil(FChangesDataSet);
  FreeAndNil(FTransactionDataSet);
  FInTransaction := False;
  inherited;
end;

procedure TRESTDWMemtableControlUpdates.DoAfterDelete;
begin
  if CatalogUpdates then
    MyDoAfterDelete(ChangesDataSet);
  if CatalogTransaction then
    MyDoAfterDelete(TransactionDataSet);
  inherited;
  if not IgnoreEvents then begin
    if AutoApplyUpdates then
      ApplyUpdates;
  end;
end;

procedure TRESTDWMemtableControlUpdates.DoAfterPost;
begin
  inherited;
  if CatalogUpdates then
    MyDoAfterPost(ChangesDataSet);
  if CatalogTransaction then
    MyDoAfterPost(TransactionDataSet);
  if not IgnoreEvents then begin
    if AutoApplyUpdates then
      ApplyUpdates;
  end;
end;

procedure TRESTDWMemtableControlUpdates.DoApplyRecord(AUpdateStatus: TUpdateStatus; const AOldValues: TParams; var ANewValues: TParams);
begin
  if Assigned(FOnApplyRecord) then begin
    FOnApplyRecord(Self, AUpdateStatus, AOldValues, ANewValues);
  end;
end;

procedure TRESTDWMemtableControlUpdates.DoApplyUpdatesError(E: Exception;
  var ARaiseException: Boolean);
begin
  ARaiseException := True;
end;

procedure TRESTDWMemtableControlUpdates.ApplyRecord;
var
  OldValues: TParams;
  NewValues: TParams;
  I: Integer;
  UpdateStatus: TUpdateStatus;
begin
  case GetStatus(ChangesDataSet) of
    rsDeleted:
      UpdateStatus := usDeleted;
    rsInserted:
      UpdateStatus := usInserted;
    rsModified:
      UpdateStatus := usModified;
    rsNone, rsPrepareDelete, rsPrepareDeleteModified, rsPrepareDeleteInserted:
      Exit;
  end;

  try
    OldValues := TParams.Create(nil);
    NewValues := TParams.Create(nil);

    for I := 0 to ChangesDataSet.Fields.Count - 1 do begin
      if ChangesDataSet.Fields[I].FieldKind <> fkData then
        Continue;

      case UpdateStatus of
        usDeleted:
          CreateApplyParamByField(OldValues, ChangesDataSet.Fields[I]);
        usModified: begin
            GotoBookmarkRecord(ChangesDataSet);
            CreateApplyParamByField(OldValues, ChangesDataSet.Fields[I]);
            if ChangesDataSet.Fields[I].IsBlob then begin
              if ChangesDataSet.Fields[I].AsString <> Fields[I].AsString then
                CreateApplyParamByField(NewValues, Fields[I]);
            end else begin
              if ChangesDataSet.Fields[I].Value <> Fields[I].Value then
                CreateApplyParamByField(NewValues, Fields[I]);
            end;
          end;
        usInserted: begin
            GotoBookmarkRecord(ChangesDataSet);
            CreateApplyParamByField(NewValues, Fields[I]);
          end;
      end;
    end;
    DoApplyRecord(UpdateStatus, OldValues, NewValues);
    if UpdateStatus in [usInserted, usModified] then
      ApplyAutogenerateFieldValues(NewValues);
  finally
    FreeAndNil(OldValues);
    FreeAndNil(NewValues);
  end;
end;

procedure TRESTDWMemtableControlUpdates.DoBeforeDelete;
begin
  inherited;
  if CatalogUpdates then
    MyDoBeforeDelete(ChangesDataSet);
  if CatalogTransaction then
    MyDoBeforeDelete(TransactionDataSet);
end;

procedure TRESTDWMemtableControlUpdates.DoBeforeEdit;
begin
  if CatalogUpdates then
    MyDoBeforeEdit(ChangesDataSet);
  if CatalogTransaction then
    MyDoBeforeEdit(TransactionDataSet);
  inherited;
end;

procedure TRESTDWMemtableControlUpdates.AddChangeRecord(ADataSet: TBaseFeatures; ARecordStatus: TRecordStatus);
begin
  ADataSet.Append;
  ApplyChangeData(ADataSet, ARecordStatus);
  ADataSet.Post;
end;

procedure TRESTDWMemtableControlUpdates.AfterApplyUpdates;
begin

end;

procedure TRESTDWMemtableControlUpdates.AddBookmarkField;
begin
  if csDesigning in ComponentState then
    Exit;
 If Not IgnoreBookmark Then
  if FindField(BOOKMARK_FIELD_NAME) = nil then begin
    with TIntegerField.Create(Self) do begin
      FieldName := BOOKMARK_FIELD_NAME;
      Dataset := Self;
      DisplayLabel := 'Bookmark';
      Visible := False;
    end;
//    Fields.InternalAddedFields := Fields.InternalAddedFields + 1;
  end;
end;

procedure TChangedRecord.GetText(var Text: string; DisplayText: Boolean);
begin
  inherited;
  case TRecordStatus(AsInteger) of
    rsNone:
      Text := 'rsNone';
    rsPrepareDelete:
      Text := 'rsPrepareDelete';
    rsInserted:
      Text := 'rsInserted';
    rsModified:
      Text := 'rsModified';
    rsDeleted:
      Text := 'rsDeleted';
    rsPrepareDeleteModified:
      Text := 'rsrsPrepareDeleteModified';
    rsPrepareDeleteInserted:
      Text := 'rsPrepareDeleteInserted';
    rsModifiedAgain:
      Text := 'rsModifiedAgain';
  end;
end;

{ TRESTDWMemtable }

Procedure TRESTDWMemtable.LoadFromStream(Stream: TStream);
Begin
 DisableControls;
 Try
  Inherited LoadFromStream(Stream);
 Finally
  EnableControls;
 End;
End;

end.
