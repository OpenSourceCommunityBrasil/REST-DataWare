{$DEFINE FireDAC_MONITOR}
unit Firedac.Phys.RDWBase;

interface

uses
  System.SyncObjs, Data.DBXCommon, Data.DB, //
  FireDAC.Phys, System.Classes, FireDAC.DatS, FireDAC.Stan.Intf, FireDAC.Stan.Error,
  FireDAC.Stan.Util, FireDAC.Stan.Param, Firedac.Stan.Option, Data.DBCommonTypes,
  uRESTDWIdBase, uRESTDWParams, uRESTDWBasicTypes, uRESTDWBasicDB,
  FireDAC.Phys.Intf //

    ;

type

  ERDWNativeException      = class;
  TFDPhysRDWBaseDriverLink = class;
  TFDPhysRDWLib            = class;
  TFDPhysRDWDriverBase     = class;
  TFDPhysRDWConnectionBase = class;
  TFDPhysRDWTransaction    = class;
  TFDPhysRDWCommand        = class;
  TRDWReader               = class;

  ERDWNativeException = class(EFDDBEngineException)
  public
    constructor Create(ADBXError: TDBXError; const ADriverName: String = ''); overload;
  end;

  // componente para incluir a uses na unit do FDConnection
  TFDPhysRDWBaseDriverLink = class(TFDPhysDriverLink)
  end;

  // Simula a Dll cliente
  TFDPhysRDWLib = class(TObject)
  private
    [weak]
    FOwningObj        : TObject;
    FLock             : TCriticalSection;
    FCurrentConnection: TFDPhysRDWConnectionBase;
    // class function GetRegistryFile(const Setting, Default: string): string;
    procedure DoError(ADBXError: TDBXError);
  public
    constructor Create(AOwningObj: TObject = nil);
    destructor Destroy; override;
    property OwningObj: TObject read FOwningObj;
  end;

  TFDPhysRDWDriverBase = class(TFDPhysDriver)
  private
    // FCfgFile: String;
    FLib: TFDPhysRDWLib;
  protected
    // carrega a dll de cliente(não tem)
    procedure InternalLoad; override;
    // libera a dll de cliente(não tem)
    procedure InternalUnload; override;
    // Ponteiro para a dll de cliente
    function GetCliObj: Pointer; override;
  public
    constructor Create(AManager: TFDPhysManager; const ADriverDef: IFDStanDefinition); override;
    destructor Destroy; override;
    // property CfgFile: String read FCfgFile;
    property Lib: TFDPhysRDWLib read FLib;
  end;

  TFDPhysRDWConnectionBase = class(TFDPhysConnection)
  private
    FRDWDatabase   : TRESTDWIdDatabase;
    FRdbmsKind     : TFDRDBMSKind;
    FCurrentCommand: TFDPhysRDWCommand;
{$IFDEF FireDAC_MONITOR}
    function DoTrace(TraceInfo: TDBXTraceInfo): CBRType;
{$ENDIF}
    // Cria os objetos e interfaces de conexão
    procedure GetConnInterfaces;
    // Seta os parametros da conexão
    procedure SetConnParams;
    // Dispara erros durante a conexão
    Procedure DoEventConnecton(Sucess: Boolean; Const Error: String);
    // Retorna o PhyscDriver
    function GetPhysDriver: TFDPhysRDWDriverBase;
  protected
    // Conecta ao server
    procedure InternalConnect; override;
    // Desconecta
    procedure InternalDisconnect; override;
    // Cria o  TFDPhysCommand a ser executado
    function InternalCreateCommand: TFDPhysCommand; override;
    // Cria a transsação
    function InternalCreateTransaction: TFDPhysTransaction; override;
{$IFDEF FireDAC_MONITOR}
    procedure InternalTracingChanged; override;
{$ENDIF}
    // Executa um comando diretamente(sem retorno)
    procedure InternalExecuteDirect(const ASQL: String; ATransaction: TFDPhysTransaction); override;
    // Monitor Items
    procedure GetItem(AIndex: Integer; out AName: String; out AValue: Variant;
      out AKind: TFDMoniAdapterItemKind); override;
    function GetItemCount: Integer; override;
    // Retorna o RDWDatabase
    function GetCliObj: Pointer; override;
    // Retorna o handle da Dll Cliente(Nesse caso o RDWDatabase)
    function InternalGetCliHandle: Pointer; override;
    // Obtém o tipo do RDBMS dos metadados
    function GetRDBMSKindFromAlias: TFDRDBMSKind;
    // Retorna as palavras reservadas de cada RDBMS
    function GetKeywords: String;
  public
    constructor Create(ADriverObj: TFDPhysDriver; AConnHost: TFDPhysConnectionHost); override;
    destructor Destroy; override;
    // Retorna o RDWDatabase
    property Database: TRESTDWIdDatabase read FRDWDatabase;
    // Property DriverName: String read FDriverName;
    property PhysDriver: TFDPhysRDWDriverBase read GetPhysDriver;
  end;

  // Controle de Transações(Falta implementar)
  TFDPhysRDWTransaction = class(TFDPhysTransaction)
  private
    FTransactions: TFDStringList;
    function GetIsolationLevel: TFDTxIsolation;
    function GetPhysConn: TFDPhysRDWConnectionBase;
  protected
    procedure InternalStartTransaction(AID: LongWord); override;
    procedure InternalCommit(AID: LongWord); override;
    procedure InternalRollback(AID: LongWord); override;
  public
    constructor Create(AConnection: TFDPhysConnection); override;
    destructor Destroy; override;
    property PhysConn: TFDPhysRDWConnectionBase read GetPhysConn;
  end;

  TRDWCommand = class
  private
    // Tipo de comando(select/update/delete, etc)
    FCommandKind: TFDPhysCommandKind;
    // FParameters  : TParams;
    FRowsAffected: Int64;
    // FCmdResult    : uRestDwParams.TJSONValue;
    FDsResult     : TRESTDWClientSQL;
    FLastReader   : TRDWReader;
    FRDWConnection: TRESTDWIdDatabase;
    FMessageError : string;
    { TODO -oDelcio -cRDW : Ver onde altera FPrepared }
    FPrepared: Boolean;
    { TODO -oDelcio -cRDW : Ver onde altera FText }
    FText: string;
    { TODO -oDelcio -cRDW : Ver onde altera FOpen }
    FOpen: Boolean;
    // controle de execução de comandos
    procedure CommandExecuting;
    procedure CommandExecuted;
    // parametros de dados
    function GetParameters: TParams;
    // procedure SetParameters;
    // procedure CreateParameters;
    // tamanho do pacorte de dados
    procedure SetRowSetSize(const Value: Int64);
    // Texto da Instrução SQL
    procedure SetText(const Value: string);
  protected
    procedure Open; virtual;
    /// <summary>
    /// Close the command and any associated resources.  Normally called
    /// by the destructor.
    /// </summary>
    procedure Close; virtual;
    // Desassocia o leitor
    procedure CloseReader; virtual;
  public
    constructor Create(aKind: TFDPhysCommandKind); virtual;
    destructor Destroy; override;
    /// <summary>
    /// This method should be called before calling any of the <c>Execute*</c>
    /// methods.
    /// If no parameters have been setup, the driver supports parameter metadata,
    /// and the dynamic sql statement contains parameters, prepare will setup
    /// the command's parameters.
    /// </summary>
    procedure Prepare; virtual;
    // executa o comando(requisição ao servidor)
    function ExecuteQuery: TRDWReader; virtual;
    /// <summary>
    /// For commands that return more then one reader.
    /// </summary>
    /// <returns>The next instance of <c>TRDWReader</c>.  If there are no more <c>TRDWReader</c> instances, nil is returned.</returns>
    function GetNextReader: TRDWReader; virtual;
    property RowsAffected: Int64 read FRowsAffected;
    property Parameters: TParams read GetParameters;
    property RowSetSize: Int64 write SetRowSetSize;
    /// <summary>
    /// command to execute. <c>Text</c> can be set to
    /// sql statements such as select, insert, update, and delete.
    /// </summary>
    property Text: string read FText write SetText;
  end;

  // Read result
  TRDWReader = class
  private
    { TODO -oDelcio -cRDW : Ver onde altera FClosed }
    FClosed : Boolean;
    FCommand: TRDWCommand;
    FFirst  : Boolean;
    function GetColumnCount: Integer;
    procedure CommandCloseReader;
    procedure CloseReader;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    /// <returns>Number of columns that can be accessed from the <c>Value</c> array property.</returns>
    property ColumnCount: Integer read GetColumnCount;
    /// <summary>
    /// Must call <c>Next</c> at least once for this property to
    /// return a meaningful result.
    /// <returns>true if there are no more rows</returns>
    /// </summary>
    property Closed: Boolean read FClosed;
    /// <summary>
    /// This method must be called to navigate to the first and successive
    /// rows.
    /// <returns>false then there are no more rows</returns>
    /// </summary>
    function Next: Boolean; virtual;
  end;

  TFDPhysRDWCommand = class(TFDPhysCommand)
  private
    FRDWCommand    : TRDWCommand;
    FRDWReader     : TRDWReader;
    FReadersList   : TFDObjList;
    FColumnIndex   : Word;
    FParamChildPos : array of Word;
    FMetaForPackage: Boolean;
    FConnection    : TFDPhysRDWConnectionBase;
    // Obtem os dados de um registro
    procedure FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
    // Obtém os valores do parametros
    procedure GetParamValues(AParams: TFDParams; AGetDataSets: Boolean);
    // Seta os valores dos parametros
    procedure SetParamValues(AParams: TFDParams; AValueIndex: Integer);
    procedure CreateParams;
    // Obtem os metadados
    procedure OpenMetaInfo;
    // Obtem um registro dos metadados
    function FetchMetaRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow; ARowIndex: Integer)
      : Boolean;
    function GetPhysConn: TFDPhysRDWConnectionBase;
    // Adiciona um cursor(Reader) na lista
    procedure AddCursor(AReader: TRDWReader);
    // Remove um cursor da lista
    procedure DeleteCursor(AReader: TRDWReader);
  protected
    // encerra o comando e libera o Reader
    procedure InternalClose; override;
    // Executa um comando x vezes(Quando usado ParamByname('xxx').Values[i])
    // possivelmente usado em TfdQuery.ExecSQL e TfdConnection.ExecSql
    procedure InternalExecute(ATimes, AOffset: Integer; var ACount: TFDCounter); override;
    // Obtem os registros de um pacote de registros
    function InternalFetchRowSet(ATable: TFDDatSTable; AParentRow: TFDDatSRow;
      ARowsetSize: LongWord): LongWord; override;
    // Abre, Executa e seta o cursor de um comando
    function InternalOpen{$IF CompilerVersion > 31}(var ACount: TFDCounter){$IFEND}: Boolean; override;
    // Obtem proximo pacote de registros
    function InternalNextRecordSet: Boolean; override;
    // Prepara a execução  do comando
    procedure InternalPrepare; override;
    // Relação inicial entre a coluna do Dataset do firedac e a coluna do retorno da execução do comando(TRDWCommand.FDsResult)
    function InternalColInfoStart(var ATabInfo: TFDPhysDataTableInfo): Boolean; override;
    // Obtem as propriedades da coluna
    function InternalColInfoGet(var AColInfo: TFDPhysDataColumnInfo): Boolean; override;
    // Libera o comando preparado com InternalPrepare
    procedure InternalUnprepare; override;
    // Retorna o Comando RDW
    function GetCliObj: Pointer; override;
  public
    constructor Create(AConnectionObj: TFDPhysConnection);
    destructor Destroy; override;
    // retorna o Physc Connection do FireDac
    property PhysConn: TFDPhysRDWConnectionBase read GetPhysConn;
  end;

const
  S_FD_RDWId                       = 'RDW';
  S_FD_ConnParam_RDW_PoolerName    = 'PoolerName';
  S_FD_ConnParam_RDW_PoolerPort    = 'PoolerPort';
  S_FD_ConnParam_RDW_PoolerService = 'PoolerService';
  S_FD_ConnParam_RDW_Timeout       = 'Timeout';
  er_FD_RDWGeneral                 = 1000;
  er_FD_RDWParMBNotEmpty           = 1001;

implementation

uses
  System.Variants, System.Win.Registry, Winapi.Windows,
  System.SysUtils, SqlConst, Data.FmtBcd,
  Data.SqlTimSt, FireDAC.Stan.SQLTimeInt, Data.DBXMetaDataNames,
  FireDAC.Stan.Consts, uRESTDWJSONObject, uRESTDWPoolermethod,
  uRESTDWDataUtils, Firedac.Phys.RDWDef, System.StrUtils;

{ TFDPhysRDWLib }

constructor TFDPhysRDWLib.Create(AOwningObj: TObject);
begin
  inherited Create;
  FOwningObj := AOwningObj;
  FLock      := TCriticalSection.Create;
end;

destructor TFDPhysRDWLib.Destroy;
begin
  FDFreeAndNil(FLock);
  inherited Destroy;
end;

procedure TFDPhysRDWLib.DoError(ADBXError: TDBXError);
var
  oObj: TObject;
  sDrv: String;
  oExc: ERDWNativeException;
begin
  sDrv := 'RDW';
  if FCurrentConnection <> nil then
    begin
      oObj := FCurrentConnection;
      // sDrv := FCurrentConnection.FDriverName;
    end
  else
    begin
      oObj := nil;
      // sDrv := 'RDW';
    end;
  oExc := ERDWNativeException.Create(ADBXError, sDrv);
  FDFree(ADBXError);
  FDException(oObj, oExc {$IFDEF FireDAC_Monitor}, False {$ENDIF});
end;

{ TFDPhysRDWDriverBase }

constructor TFDPhysRDWDriverBase.Create(AManager: TFDPhysManager;
  const ADriverDef: IFDStanDefinition);
begin
  inherited Create(AManager, ADriverDef);
  FLib := TFDPhysRDWLib.Create;
end;

destructor TFDPhysRDWDriverBase.Destroy;
begin
  inherited Destroy;
  FDFreeAndNil(FLib);
end;

procedure TFDPhysRDWDriverBase.InternalLoad;
begin
  // nothing
end;

procedure TFDPhysRDWDriverBase.InternalUnload;
begin
  // nothing
end;

function TFDPhysRDWDriverBase.GetCliObj: Pointer;
begin
  Result := FLib;
end;

constructor ERDWNativeException.Create(ADBXError: TDBXError; const ADriverName: String);
var
  eKind: TFDCommandExceptionKind;
  s    : string;
begin
  // if ADBXError.ErrorCode = TDBXErrorCodes.Warning, then set FInfo and do not raise
  if ADriverName = '' then
    s := '<unknown>'
  else
    s := ADriverName;
  inherited Create(er_FD_RDWGeneral, FDExceptionLayers([S_FD_LPhys, S_FD_RDWId, s]) + ' ' +
    ADBXError.Message);
  case ADBXError.ErrorCode of
    TDBXErrorCodes.InvalidUserOrPassword: eKind := ekUserPwdInvalid;
    TDBXErrorCodes.ConnectionFailed: eKind      := ekServerGone;
    TDBXErrorCodes.OptimisticLockFailed: eKind  := ekRecordLocked;
    TDBXErrorCodes.NoTable: eKind               := ekObjNotExists;
    TDBXErrorCodes.Eof: eKind                   := ekNoDataFound;
    TDBXErrorCodes.NoData: eKind                := ekNoDataFound;
  else eKind                                    := ekOther;
  end;
  if Pos('user credentials', ADBXError.Message) > 0 then
    eKind := ekUserPwdInvalid;
  AppendError(1, ADBXError.ErrorCode, ADBXError.Message, '', eKind, -1, -1);
end;

{ TFDPhysRDWConnectionBase }

constructor TFDPhysRDWConnectionBase.Create(ADriverObj: TFDPhysDriver;
  AConnHost: TFDPhysConnectionHost);
begin
  inherited Create(ADriverObj, AConnHost);

end;

destructor TFDPhysRDWConnectionBase.Destroy;
begin
  inherited Destroy;
end;

function TFDPhysRDWConnectionBase.GetPhysDriver: TFDPhysRDWDriverBase;
begin
  Result := TFDPhysRDWDriverBase(DriverObj);
end;

function TFDPhysRDWConnectionBase.GetRDBMSKindFromAlias: TFDRDBMSKind;
var
  oManMeta: IFDPhysManagerMetadata;
begin
  Result := FRdbmsKind;
  if Result = TFDRDBMSKinds.Unknown then
    begin
      {TODO -oDelcio -cRDW : Obter o tipo do banco de dados do servidor para que o firedac gere comandos específicos de cada RDBMS corretamente}
      //Hoje temos que setar em Params.RDBMS
      FDPhysManager.CreateMetadata(oManMeta);
      Result := oManMeta.GetRDBMSKind(GetConnectionDef.AsString[S_FD_ConnParam_Common_RDBMS]);
    end;
end;

function TFDPhysRDWConnectionBase.GetKeywords: String;
begin
  Result := '';
end;

function TFDPhysRDWConnectionBase.InternalCreateCommand: TFDPhysCommand;
begin
  Result := TFDPhysRDWCommand.Create(Self);
end;

function TFDPhysRDWConnectionBase.InternalCreateTransaction: TFDPhysTransaction;
begin
  Result := TFDPhysRDWTransaction.Create(Self);
end;

{$IFDEF FireDAC_MONITOR}

procedure TFDPhysRDWConnectionBase.DoEventConnecton(Sucess: Boolean; const Error: String);
var
  oObj: TObject;
  oExc: EFDDBEngineException;
begin
  if not Sucess then
    begin
      { TODO -oDelcio -cRDW : DoError: Pegar FCurrentCommand }
      // if FCurrentCommand <> nil then
      // oObj := FCurrentCommand
      // else
      oObj := Self;
      oExc := EFDDBEngineException.Create(0, Error);
      // FDFree(ADBXError);
      FDException(oObj, oExc {$IFDEF FireDAC_MONITOR}, GetTracing {$ENDIF});
    end;
end;

function TFDPhysRDWConnectionBase.DoTrace(TraceInfo: TDBXTraceInfo): CBRType;
var
  oObj: TObject;
begin
  { TODO -oDelcio -cRDW : DoTrace: Pegar FCurrentCommand }
  // if FCurrentCommand <> nil then
  // oObj := FCurrentCommand
  // else
  // oObj := Self;
  //
  // if FCurrentCommand <> nil then
  // oObj := FCurrentCommand
  // else
  // oObj := Self;
  GetMonitor.Notify(ekVendor, esProgress, oObj, TraceInfo.Message, []);
  Result := cbrUSEDEF;
end;

procedure TFDPhysRDWConnectionBase.InternalTracingChanged;
begin
  { TODO -oDelcio -cRDW : InternalTracingChanged: Implementar Tracing }
  // if FDbxConnection <> nil then
  // if FTracing then
  // FDbxConnection.OnTrace := DoTrace
  // else
  // FDbxConnection.OnTrace := nil;
end;
{$ENDIF}

procedure TFDPhysRDWConnectionBase.GetConnInterfaces;
var
  oConnMeta: IFDPhysConnectionMetadata;
  s        : String;
  i        : Integer;
begin
  CreateMetadata(oConnMeta);
  PhysDriver.Lib.FLock.Enter;
  PhysDriver.Lib.FCurrentConnection := Self;
  try
    if FRDWDatabase = nil then
      begin
        FRDWDatabase              := TRESTDWIdDatabase.Create(nil);
        FRDWDatabase.OnConnection := DoEventConnecton;
{$IFDEF FireDAC_MONITOR}
        if GetTracing then
          begin
            { TODO -oDelcio -cRDW: Implementar Monitor Tracing }
          end;
        InternalTracingChanged;
{$ENDIF}
      end;
  finally
    PhysDriver.Lib.FCurrentConnection := nil;
    PhysDriver.Lib.FLock.Leave;
  end;
end;

procedure TFDPhysRDWConnectionBase.SetConnParams;
begin
  FRDWDatabase.PoolerPort     := ConnectionDef.AsInteger[S_FD_ConnParam_RDW_PoolerPort];
  FRDWDatabase.PoolerName     := ConnectionDef.AsString[S_FD_ConnParam_RDW_PoolerName];
  FRDWDatabase.PoolerService  := ConnectionDef.AsString[S_FD_ConnParam_RDW_PoolerService];
  FRDWDatabase.ConnectTimeOut := ConnectionDef.AsInteger[S_FD_ConnParam_RDW_Timeout];
  FRDWDatabase.RequestTimeOut := ConnectionDef.AsInteger[S_FD_ConnParam_RDW_Timeout];

  FRDWDatabase.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
  with FRDWDatabase.AuthenticationOptions.OptionParams as TRESTDWAuthOptionBasic do
    begin
      Username := ConnectionDef.AsString['User_Name'];
      Password := ConnectionDef.AsString['Password'];
    end;
end;

procedure TFDPhysRDWConnectionBase.InternalConnect;
begin
  GetConnInterfaces;
  SetConnParams;
  if not FRDWDatabase.Connected then
    FRDWDatabase.Open;
  FRdbmsKind := GetRDBMSKindFromAlias;
end;

procedure TFDPhysRDWConnectionBase.InternalDisconnect;
begin
  FDFreeAndNil(FRDWDatabase);
  FRdbmsKind := TFDRDBMSKinds.Unknown;
end;

procedure TFDPhysRDWConnectionBase.InternalExecuteDirect(const ASQL: String;
  ATransaction: TFDPhysTransaction);
var
  _Sql         : TStringList;
  _Params      : TParams;
  _Error       : Boolean;
  _MessageError: String;
  _Result      : uRESTDWParams.TJSONValue;
  _RowsAffected: Integer;
  _PoolerMethod: TRESTDWPoolerMethodClient;
  _Execute:Boolean;
begin
  _Params       := nil;
  _Error        := False;
  _MessageError := '';
  _Result       := nil;
  _RowsAffected := 0;

  _Sql    := TStringList.Create;
  _Params := TParams.Create(nil);
  try
    _Sql.Text := ASQL;
    _Execute:= not  ContainsText(ASQL,'select');

    FRDWDatabase.ExecuteCommand(_PoolerMethod, _Sql, _Params, _Error, _MessageError, _Result,
      _RowsAffected, _Execute);

  finally
    FreeAndNil(_Sql);
    _Params.Free;
  end;
  if _Error then
    raise Exception.Create(_MessageError);
end;

function TFDPhysRDWConnectionBase.GetCliObj: Pointer;
begin
  Result := FRDWDatabase;
end;

function TFDPhysRDWConnectionBase.InternalGetCliHandle: Pointer;
begin
  if FRDWDatabase <> nil then
    Result := @FRDWDatabase
  else
    Result := nil;
end;

function TFDPhysRDWConnectionBase.GetItemCount: Integer;
begin
  Result := inherited GetItemCount;

  if (FRDWDatabase <> nil) then
    Inc(Result, 2)
  else
    Inc(Result);
end;

procedure TFDPhysRDWConnectionBase.GetItem(AIndex: Integer; out AName: String; out AValue: Variant;
  out AKind: TFDMoniAdapterItemKind);
begin
  if AIndex < inherited GetItemCount then
    inherited GetItem(AIndex, AName, AValue, AKind)
  else
    case AIndex - inherited GetItemCount of
      0:
        begin
          AName  := 'RDW product name';
          AKind  := ikClientInfo;
          AValue := 'REST Dataware Core';
        end;
      1:
        begin
          AName  := 'RDW product version';
          AKind  := ikClientInfo;
          AValue := FRDWDatabase.VersionInfo;
        end;
    end;
end;

{ TFDPhysRDWTransaction }

constructor TFDPhysRDWTransaction.Create(AConnection: TFDPhysConnection);
begin
  inherited Create(AConnection);
  FTransactions := TFDStringList.Create;
end;

destructor TFDPhysRDWTransaction.Destroy;
begin
  FDFreeAndNil(FTransactions);
  inherited Destroy;
end;

function TFDPhysRDWTransaction.GetPhysConn: TFDPhysRDWConnectionBase;
begin
  Result := TFDPhysRDWConnectionBase(ConnectionObj);
end;

function TFDPhysRDWTransaction.GetIsolationLevel: TFDTxIsolation;
begin
  Result := GetOptions.Isolation;
end;

procedure TFDPhysRDWTransaction.InternalStartTransaction(AID: LongWord);
begin
  { TODO -oDelcio -cRDW : Implementar InternalStartTransaction }
  // FTransactions.AddObject(IntToStr(AID),
  // PhysConn.FDbxConnection.BeginTransaction(GetIsolationLevel));
end;

procedure TFDPhysRDWTransaction.InternalCommit(AID: LongWord);
var
  // oTX: TRDWTrasaction;
  i: Integer;
begin
  { TODO -oDelcio -cRDW : Implementar InternalCommit }

  if FTransactions.Find(IntToStr(AID), i) then
    begin
      // oTX := TRDWTrasaction(FTransactions.Objects[i]);
      FTransactions.Delete(i);
      // PhysConn.FDbxConnection.CommitFreeAndNil(oTX);
    end;
end;

procedure TFDPhysRDWTransaction.InternalRollback(AID: LongWord);
var
  // oTX: TRDWTrasaction;
  i: Integer;
begin
  { TODO -oDelcio -cRDW : Implementar InternalRollback }

  if FTransactions.Find(IntToStr(AID), i) then
    begin
      // oTX := TRDWTrasaction(FTransactions.Objects[i]);
      FTransactions.Delete(i);
      // PhysConn.FDbxConnection.RollbackFreeAndNil(oTX);
    end;
end;

{ TFDPhysRDWCommand }

constructor TFDPhysRDWCommand.Create(AConnectionObj: TFDPhysConnection);
begin
  inherited Create(AConnectionObj);
  FReadersList := TFDObjList.Create;
end;

procedure TFDPhysRDWCommand.CreateParams;
var
  oParams: TFDParams;
  I      : Integer;
begin
  oParams := GetParams;

  if (oParams.Count = 0) or (FRDWCommand.FDsResult = nil) then
    Exit;

  for I := 0 to oParams.Count - 1 do
    with FRDWCommand.Parameters.AddParameter do
      begin
        Name      := oParams[I].Name;
        DataType  := oParams[I].DataType;
        ParamType := oParams[I].ParamType;
      end;
end;

destructor TFDPhysRDWCommand.Destroy;
begin
  inherited Destroy;
  FDFreeAndNil(FReadersList);
end;

function TFDPhysRDWCommand.GetCliObj: Pointer;
begin
  Result := FRDWCommand;
end;

function TFDPhysRDWCommand.GetPhysConn: TFDPhysRDWConnectionBase;
begin
  Result := TFDPhysRDWConnectionBase(FConnectionObj);
end;

procedure TFDPhysRDWCommand.SetParamValues(AParams: TFDParams; AValueIndex: Integer);
var
  I     : Integer;
  _Param: TParam;
begin
  for I := 0 to AParams.Count - 1 do
    begin
      _Param := FRDWCommand.Parameters.FindParam(AParams[I].Name);
      if _Param <> nil then
        _Param.Value := AParams[I].Values[AValueIndex];
    end;
end;

procedure TFDPhysRDWCommand.GetParamValues(AParams: TFDParams; AGetDataSets: Boolean);
var
  I     : Integer;
  _Param: TParam;
begin
  for I := 0 to AParams.Count - 1 do
    begin
      _Param := FRDWCommand.Parameters.FindParam(AParams[I].Name);
      { TODO -oDelcio  -cRDW : Implementar AParams[I].Values[xxx] }
      if _Param <> nil then
        AParams[I].Value := _Param.Value
      else
        AParams[I].Value := null;
    end;
end;

procedure TFDPhysRDWCommand.InternalPrepare;
var
  rName    : TFDPhysParsedName;
  oConnMeta: IFDPhysConnectionMetadata;
begin

  if GetMetaInfoKind = TFDPhysMetaInfoKind.mkNone then
    begin
      if GetCommandKind in [skStoredProc, skStoredProcWithCrs, skStoredProcNoCrs] then
        begin
          GetConnection.CreateMetadata(oConnMeta);

          oConnMeta.DecodeObjName(Trim(GetCommandText()), rName, Self, []);
          FDbCommandText := '';
          if fiMeta in GetOptions.FetchOptions.Items then
            GenerateStoredProcParams(rName);

          FDbCommandText := rName.FObject;
        end
      else
        begin
          // adjust SQL command
          GenerateLimitSelect();
          if GetCommandKind = skUnknown then
            SetCommandKind(skSelect);
        end;
      GenerateParamMarkers();
      { TODO -oDelcio -cRDW : Implementar InternalPrepare }
      FRDWCommand                := TRDWCommand.Create(GetCommandKind);
      FRDWCommand.FRDWConnection := PhysConn.FRDWDatabase;
      FRDWCommand.Text           := FDbCommandText;
      // FRDWCommand.Parameters.SetCount(GetParams.Count);
      PhysConn.FCurrentCommand := Self;
      try
        FRDWCommand.Prepare;
        if GetParams.Count > 0 then
          CreateParams;

      finally
        PhysConn.FCurrentCommand := nil;
      end;
    end
  else
    SetCommandKind(skSelect);
  SetLength(FParamChildPos, GetParams.Count);
end;

procedure TFDPhysRDWCommand.InternalUnprepare;
begin
  if FRDWCommand = nil then
    Exit;
  InternalClose;
  FDFreeAndNil(FRDWCommand);
  SetLength(FParamChildPos, 0);
end;

function TFDPhysRDWCommand.InternalColInfoStart(var ATabInfo: TFDPhysDataTableInfo): Boolean;
begin
  Result := OpenBlocked;
  if Result then
    if ATabInfo.FSourceID = -1 then
      begin
        ATabInfo.FSourceName := GetCommandText;
        ATabInfo.FSourceID   := 1;
        FColumnIndex         := 1;
      end
    else
      begin
        { TODO -oDelcio -cRDW : Implementar TFDPhysRDWCommand.InternalColInfoStart OpenBlocked = False }
        raise Exception.Create('TFDPhysRDWCommand.InternalColInfoStart');

        // ATabInfo.FSourceName := FDBXReader.ValueType[ATabInfo.FSourceID - 1].Name;
        ATabInfo.FSourceID := ATabInfo.FSourceID;
      end;
end;

function TFDPhysRDWCommand.InternalColInfoGet(var AColInfo: TFDPhysDataColumnInfo): Boolean;
var
  iCount: Integer;
begin
  if AColInfo.FParentTableSourceID <> -1 then
    begin
      { TODO -oDelcio -cRDW : Implementar InternalColInfoGet com  AColInfo.FParentTableSourceID }
      Result := False;
      Exit;
    end
  else
    begin
      iCount := FRDWReader.ColumnCount;
      if FColumnIndex > iCount then
        begin
          Result := False;
          Exit;
        end;
    end;

  with FRDWCommand.FDsResult.GetFieldColumn(FRDWCommand.FDsResult.Fields[FColumnIndex - 1]) do
    begin
      AColInfo.FSourceID   := FColumnIndex;
      AColInfo.FSourceName := SourceName;
      // AColInfo.FOriginColName
      AColInfo.FSourceType := DataType;
      AColInfo.FType       := DataType;
      // AColInfo.FOriginTabName:= OriginTabName;
      AColInfo.FAttrs := Attributes;

      AColInfo.FLen := StorageSize;

      AColInfo.FPrec  := Precision;
      AColInfo.FScale := Scale;

      AColInfo.FForceAddOpts := Options;
    end;

  Inc(FColumnIndex);
  Result := True;
end;

procedure TFDPhysRDWCommand.AddCursor(AReader: TRDWReader);
begin
  if AReader = nil then
    Exit;
  if FReadersList.IndexOf(AReader) = -1 then
    if AReader.ColumnCount > 0 then
      begin
        FReadersList.Add(AReader);
        if FRDWReader = nil then
          FRDWReader := TRDWReader(FReadersList[0]);
      end
    else
      FDFree(AReader);
end;

procedure TFDPhysRDWCommand.DeleteCursor(AReader: TRDWReader);
begin
  if AReader = nil then
    Exit;
  FReadersList.Remove(AReader);
  if FRDWReader = AReader then
    FRDWReader := nil;
  FDFree(AReader);
end;

function TFDPhysRDWCommand.InternalOpen{$IF CompilerVersion > 31}(var ACount: TFDCounter){$IFEND}: Boolean;
var
  i: Word;
begin
  { TODO -oDelcio -cRDW : Implementar InternalOpen }
  {$IF CompilerVersion > 31}
  ACount := 0;
  {$IFEND}
  if FRDWReader = nil then
    begin
      if GetMetaInfoKind = TFDPhysMetaInfoKind.mkNone then
        begin
          SetParamValues(GetParams, 0);
          // if PhysConn.FDbxConnection.DatabaseMetaData.SupportsRowSetSize then
          FRDWCommand.RowSetSize   := GetOptions.FetchOptions.ActualRowsetSize;
          PhysConn.FCurrentCommand := Self;
          try
            AddCursor(FRDWCommand.ExecuteQuery);
          finally
           {$IF CompilerVersion > 31}
            ACount                   := FRDWCommand.RowsAffected;
           {$IFEND}
            PhysConn.FCurrentCommand := nil;
          end;
          if GetState = csAborting then
            InternalClose
          else
            GetParamValues(GetParams, True);
        end
      else
        OpenMetaInfo;
      if FRDWReader <> nil then
        if FRDWReader.Closed then
          InternalClose
        else
          begin
            // não precisamos
            // check buffer space
            // used for AnsiStr -> WideStr conversion, otherwise
            // buffer will have enough size
          end;
    end;
  Result := (FRDWReader <> nil);
end;

procedure TFDPhysRDWCommand.InternalClose;
var
  i: Integer;
begin

  GetParamValues(GetParams, False);

  if not GetNextRecordSet and (FReadersList.Count > 0) then
    try

      for i := 0 to FReadersList.Count - 1 do
        FDFree(TRDWReader(FReadersList[i]));

      FRDWCommand.FLastReader:= nil;

    finally
      FReadersList.Clear;
      FRDWReader := nil;
    end;

end;

function TFDPhysRDWCommand.InternalNextRecordSet: Boolean;
begin
  { TODO -oDelcio -cRDW : Implementar InternalNextRecordSet }
  DeleteCursor(FRDWReader);
  if FReadersList.Count > 0 then
    FRDWReader := TRDWReader(FReadersList[0])
  else
    AddCursor(FRDWCommand.GetNextReader);
  Result := FRDWReader <> nil;
end;

procedure TFDPhysRDWCommand.InternalExecute(ATimes, AOffset: Integer; var ACount: TFDCounter);
var
  i        : Integer;
  iAffected: Int64;
begin
  ACount := 0;
  if GetMetaInfoKind = TFDPhysMetaInfoKind.mkNone then
    for i := AOffset to ATimes - 1 do
      begin
        SetParamValues(GetParams, i);
        PhysConn.FCurrentCommand := Self;
        try
          try
            AddCursor(FRDWCommand.ExecuteQuery);
          except
            on E: ERDWNativeException do
              begin
                E.Errors[0].RowIndex := i;
                raise;
              end;
          end;
        finally
          PhysConn.FCurrentCommand := nil;
          DeleteCursor(FRDWReader);
        end;
        if GetState <> csAborting then
begin
            GetParamValues(GetParams, False);
            iAffected := FRDWCommand.RowsAffected;
            if iAffected <= -1 then
              iAffected := 0;
            Inc(ACount, iAffected);
          end
        else
          Break;
      end;

  // var
  // _RowsAffected:Integer;
  // begin
  // { TODO -oDelcio -cRDW : Implementar InternalExecute }
  // _RowsAffected:= ATimes;
  //
  // ACount:= _RowsAffected;
end;

procedure TFDPhysRDWCommand.FetchRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow);
var
  oCol    : TFDDatSColumn;
  oRow    : TFDDatSRow;
  j       : Integer;
  pData   : Pointer;
  iLen    : LongWord;
  oFmtOpts: TFDFormatOptions;
begin
  oRow     := ATable.NewRow(True);
  oFmtOpts := GetOptions.FormatOptions;
  try
    { TODO -oOwner -cGeneral : Implementar Command.FetchRow }
    for j := 0 to ATable.Columns.Count - 1 do
      begin
        oCol := ATable.Columns[j];
        if (oCol.SourceID > 0) and CheckFetchColumn(oCol.SourceDataType, oCol.Attributes) then
          begin
            FRDWCommand.FDsResult.SourceView.Rows[FRDWCommand.FDsResult.RecNo - 1]
              .GetData(oCol.SourceID - 1, rvDefault, pData, 0, iLen, False);

            oRow.SetData(j, pData, iLen);
          end;
      end;

    ATable.Rows.Add(oRow);
  except
    FDFree(oRow);
    raise;
  end;
end;

function TFDPhysRDWCommand.InternalFetchRowSet(ATable: TFDDatSTable; AParentRow: TFDDatSRow;
  ARowsetSize: LongWord): LongWord;
var
  i: LongWord;
begin
  Result := 0;
  { TODO -oDelcio -cRDW : Implementar InternalFetchRowSet }
  if GetMetaInfoKind <> TFDPhysMetaInfoKind.mkNone then
    ARowsetSize := MaxInt;
  for i         := 1 to ARowsetSize do
    begin
      if not FRDWReader.Next then
        Break;
      if GetMetaInfoKind = TFDPhysMetaInfoKind.mkNone then
        begin
          FetchRow(ATable, AParentRow);
          Inc(Result);
        end
      else if FetchMetaRow(ATable, AParentRow, i - 1) then
        Inc(Result);
    end;
end;

// Meta data handling
procedure TFDPhysRDWCommand.OpenMetaInfo;
begin
  { TODO -oDelcio -cRDW : Implementar OpenMetaInfo }
end;

function TFDPhysRDWCommand.FetchMetaRow(ATable: TFDDatSTable; AParentRow: TFDDatSRow;
  ARowIndex: Integer): Boolean;
var
  oRow  : TFDDatSRow;
  iRecNo: Integer;
begin
  iRecNo := ATable.Rows.Count + 1;
  oRow   := ATable.NewRow(True);
  try
    { TODO -oOwner -cGeneral : Implementar Command.FetchMetaRow }

    ATable.Rows.Add(oRow);
    Result := True;
  except
    FDFree(oRow);
    raise;
  end;
end;

{ TRDWCommand }

procedure TRDWCommand.Close;
begin
  { TODO -oOwner -cGeneral : Ver se algo tem q ser liberado em TRDWCommand.Close }
  // if Assigned(FFreeOnCloseList) then
  // FreeOnExecuteObjects;
  CloseReader;
  // FreeAndNil(FParameters);
  if FOpen then
    begin
      // DerivedClose;
      FOpen     := false;
      FPrepared := false;
    end;
end;

procedure TRDWCommand.CloseReader;
var
  _Reader: TRDWReader;
begin
  if FLastReader <> nil then
    begin
      _Reader     := FLastReader;
      FLastReader          := nil;
      _Reader.CommandCloseReader;
      _Reader.FCommand := nil;
    end;
end;

procedure TRDWCommand.CommandExecuted;
begin
  { TODO -oDelcio -cRDW : Implementar FParameterRow(controle de rows no FD Parameter.Values[]) }
  // if (FParameters <> nil) and (FParameters.FParameterRow <> nil) then
  // inc(FParameters.FParameterRow.FGeneration);
end;

procedure TRDWCommand.CommandExecuting;
begin
  { TODO -oOwner -cGeneral : Ver se precisa liberar objetos em TRDWCommand.CommandExecuting }

  // if Assigned(FFreeOnCloseList) then
  // FreeOnExecuteObjects;
  Open;
  CloseReader;
  if (Parameters.Count > 0) then
    begin
      if not FPrepared then
        Prepare;
    end;
end;

constructor TRDWCommand.Create(aKind: TFDPhysCommandKind);
begin
  inherited Create;
  FCommandKind := aKind;
end;

destructor TRDWCommand.Destroy;
begin
  if FDsResult <> nil then
    begin
      FDFree(FDsResult);
      FDsResult := nil;
    end;
  inherited;
end;

function TRDWCommand.ExecuteQuery: TRDWReader;
var
  _Error       : Boolean;
  _MessageError: String;
  // _Result      : uRESTDWParams.TJSONValue;
  // _PoolerMethod: TRESTDWPoolerMethodClient;

begin
  { TODO -oOwner -cGeneral : !!!! Implementar TRDWCommand.ExecuteQuery }
  Result := nil;
  if FText = '' then
    raise Exception.Create(' TRDWCommand.ExecuteQuery: No Statement to Execute');

  CommandExecuting;

  { TODO -oOwner -cGeneral : Ver onde criar e destruir FDsResult }
  // FDsResult := TRESTDWClientSQL.Create(nil);
  try
    // FDsResult.BinaryRequest := True;
    // FDsResult.DataBase      := FRDWConnection;
    // FDsResult.SQL.Text      := FText;

    case FCommandKind of
      // skUnknown: ;
      skSelect, skSelectForLock, skSelectForUnLock:
        begin
    FDsResult.Open;
          FDsResult.First;
        end;
      skDelete, skInsert, skMerge, skUpdate, skCreate, skAlter, skDrop, skExecute, skSet:
        begin
          FDsResult.ExecSQL;
          // FRowsAffected := FDsResult.RowsAffected;
        end;
      { TODO -oDelcio -cRDW : Falta implementar TRDWCommand.ExecuteQuery para alguns tipos de comando }
      // skStoredProc: ;
      // skStoredProcWithCrs: ;
      // skStoredProcNoCrs: ;
      // skStartTransaction: ;
      // skCommit: ;
      // skRollback: ;
      // skSetSchema: ;
      // skOther: ;
      // skNotResolved: ;
    else raise Exception.Create('TRDWCommand: Tipo de comando(' + ord(FCommandKind).ToString +
        ') não suportado pelo driver RDW');
    end;

    FRowsAffected := FDsResult.RowsAffected;

    _Error        := False;
  except
    on e: Exception do
      begin
        _Error        := True;
        FMessageError := e.Message;
        raise;
      end;

  end;

  if not _Error then
    begin
      Result := TRDWReader.Create;
    end;

  if Result <> nil then
    begin
    Result.FCommand := Self;
  FLastReader       := Result;
    end;
  CommandExecuted;
end;

function TRDWCommand.GetNextReader: TRDWReader;
begin
  CloseReader;
  { TODO -oDelcio -cRDW : Ver casos que necessitam de TRDWCommand.GetNextReader - pacotes de dados subsequentes ??? }
  Result := nil; // DerivedGetNextReader;
  if Assigned(Result) then
    Result.FCommand := Self;
end;

function TRDWCommand.GetParameters: TParams;
begin
  Open;
  Result := FDsResult.Params;
end;

procedure TRDWCommand.Open;
begin
  { TODO -oDelcio -cRDW : Implementar TRDWCommand.Open }
  if not FOpen then
    begin
      // if FConnectionClosed then
      // raise TDBXError.Create(TDBXErrorCodes.InvalidOperation, SConnectionClosed);
      // DerivedOpen;
      FOpen := true;
    end;
end;

procedure TRDWCommand.Prepare;
begin
  Open;
  if FPrepared then
    raise Exception.Create('TRDWCommand.Prepare: Already Prepared');

  { TODO -oDelcio -cGeneral : Implementar  TRDWCommand.Prepare }
  if FDsResult = nil then
    begin
      FDsResult               := TRESTDWClientSQL.Create(nil);
      FDsResult.BinaryRequest := True;
      FDsResult.DataBase      := FRDWConnection;
    end;

  FDsResult.SQL.Text := FText;

  FPrepared := true;
end;

procedure TRDWCommand.SetRowSetSize(const Value: Int64);
begin
  FDsResult.Datapacks := Value;

  // if Value > 0 then
  // begin
  // FDsResult.FetchOptions.Mode            := fmOnDemand;
  // FDsResult.FetchOptions.RowsetSize      := Value;
  // FDsResult.FetchOptions.RecordCountMode := cmTotal;
  // end
  // else
  // FDsResult.FetchOptions.Mode := fmAll;
end;

procedure TRDWCommand.SetText(const Value: string);
begin
  if FOpen and FPrepared and (FDsResult <> nil) and (FDsResult.ParamCount > 0) and (FText <> Value)
  then
    Close;
  FPrepared := false;
  FText     := Value;
end;

{ TRDWReader }

procedure TRDWReader.CloseReader;
var
  Ordinal: Integer;
begin
  if not FClosed then
    begin
      { TODO -oDelco -cGeneral : Ver se precisa liberar objetos em FCommand.FCmdResult }
      if (FCommand <> nil) and (FCommand.FDsResult <> nil) then
        FCommand.FDsResult.Close;
      FFirst := True;
    end;
  FClosed := true;
end;

procedure TRDWReader.CommandCloseReader;
begin
  // DerivedClose;
  CloseReader;
end;

constructor TRDWReader.Create;
begin
  Inherited Create;
  FFirst := True;
end;

destructor TRDWReader.Destroy;
begin

  inherited;
end;

function TRDWReader.GetColumnCount: Integer;
begin
  // if (FCommand.FCmdResult <> nil) and (not FCommand.FCmdResult.IsNull) then
  // Result:= FCommand.FCmdResult.FieldListCount
  if (FCommand.FDsResult <> nil) then
    Result := FCommand.FDsResult.FieldCount
  else
    Result := 0;
end;

function TRDWReader.Next: Boolean;
begin
  // if FValueCount < 0 then
  // begin
  // if FValueCount = NewReaderCount then
  // FValueCount := Length(FValues)
  // else
  // begin
  // Result := False;
  // Exit;
  // end;
  // end;

  Result := not FCommand.FDsResult.Eof;

  if Result then
    begin
      if FFirst and (FCommand.FDsResult.RecNo = 1) then
        FFirst := False
      else
      FCommand.FDsResult.Next;

      Result := not FCommand.FDsResult.Eof;
    end
  else
    begin
      // Unidirectional so free up underlying resources.
      //
      if Assigned(FCommand) then
        FCommand.CloseReader;
      Result := False;
    end;
end;

end.
