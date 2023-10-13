unit uRESTDWIBDACDriver;

{$I ..\Includes\uRESTDW.inc}

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
 Alberto Brito              - Admin - Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

uses
  {$IFDEF RESTDWLAZARUS}
    LResources,
  {$ENDIF}
  Classes, SysUtils, DB,
  DBAccess, IBC,  MemDS,
  uRESTDWDriverBase, uRESTDWBasicTypes,
  uRESTDWMemoryDataset,
  uRESTDWProtoTypes;

type
  TRESTDWIBDACTable = class(TRESTDWDrvTable)
  public
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure SaveToStream(stream : TStream); override;
    procedure FetchAll; override;
  end;

  { TRESTDWIBDACStoreProc }

  TRESTDWIBDACStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWIBDACQuery }

  TRESTDWIBDACQuery = class(TRESTDWDrvQuery)
  protected
    procedure CreateSequencedField(seqname,field : string); override;
  public
    procedure SaveToStream(stream : TStream); override;
    procedure ExecSQL; override;
    procedure Prepare; override;
    procedure FetchAll; override;

    function  RowsAffected : Int64; override;
    function  ParamCount : Integer; override;

    function  getParamDataType(IParam : integer) : TFieldType; override;
    function  getParamName(IParam : integer) : string; override;
    function  getParamSize(IParam : integer) : integer; override;
    function  getParamValue(IParam : integer) : variant; override;

    procedure setParamDataType(IParam : integer; AValue : TFieldType); override;
    procedure setParamValue(IParam : integer; AValue : variant); override;

    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
  end;

  { TRESTDWIBDACDriver }

  TRESTDWIBDACDriver = class(TRESTDWDriverBase)
  private
    FTransaction : TIbcTransaction;
  protected
    procedure setConnection(AValue: TComponent); override;

  public
    function getConectionType : TRESTDWDatabaseType; override;
    Function compConnIsValid(comp : TComponent) : boolean; override;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    function getQuery : TRESTDWDrvQuery; override;
    function getTable : TRESTDWDrvTable; override;
    function getStoreProc : TRESTDWDrvStoreProc; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;
    function connInTransaction : boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWIBDACDriver]);
end;

{ TRESTDWIBDACStoreProc }

procedure TRESTDWIBDACStoreProc.ExecProc;
var
  qry : TIbcStoredProc;
begin
  inherited ExecProc;
  qry := TIbcStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWIBDACStoreProc.Prepare;
var
  qry : TIbcStoredProc;
begin
  inherited Prepare;
  qry := TIbcStoredProc(Self.Owner);
  qry.Prepare;
end;

 { TRESTDWIBDACDriver }

function TRESTDWIBDACDriver.getConectionType : TRESTDWDatabaseType;
begin
  // somente Firebird
  Result := dbtFirebird;
end;

function TRESTDWIBDACDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery.Create(Self);
  qry.Connection := TIbcConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWIBDACQuery.Create(qry);
end;

function TRESTDWIBDACDriver.getTable : TRESTDWDrvTable;
var
  qry : TIbcTable;
begin
  qry := TIbcTable.Create(Self);
  qry.Connection := TIbcConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWIBDACTable.Create(qry);
end;

function TRESTDWIBDACDriver.getStoreProc : TRESTDWDrvStoreProc;
var
  qry : TIbcStoredProc;
begin
  qry := TIbcStoredProc.Create(Self);
  qry.Connection := TIbcConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWIBDACStoreProc.Create(qry);
end;

procedure TRESTDWIBDACDriver.Connect;
begin
  inherited Connect;
  if Assigned(Connection) then
    TIbcConnection(Connection).Open;
end;

destructor TRESTDWIBDACDriver.Destroy;
begin

  inherited;
end;

procedure TRESTDWIBDACDriver.Disconect;
begin
  inherited Disconect;
  if Assigned(Connection) then
    TIbcConnection(Connection).Close;
end;

function TRESTDWIBDACDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TIbcConnection(Connection).Connected;
end;

procedure TRESTDWIBDACDriver.setConnection(AValue: TComponent);
begin
  inherited;
  if not Assigned(FTransaction) then
    FTransaction := TIbcTransaction.Create(Self);
  FTransaction.DefaultConnection := TIbcConnection(AValue);
  TIbcConnection(AValue).DefaultTransaction := FTransaction;
end;

function TRESTDWIBDACDriver.connInTransaction : boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TIbcConnection(Connection).InTransaction;
end;

procedure TRESTDWIBDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) then
    TIbcConnection(Connection).StartTransaction;
end;

procedure TRESTDWIBDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    TIbcConnection(Connection).Rollback;
end;

function TRESTDWIBDACDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TIBCConnection);
end;

procedure TRESTDWIBDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    TIbcConnection(Connection).Commit;
end;

constructor TRESTDWIBDACDriver.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TIbcTransaction.Create(Self);
  FTransaction.DefaultConnection := TIbcConnection(Connection);
end;

class procedure TRESTDWIBDACDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                    var AConnection : TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    if AConnectionDefs.DriverType = dbtFirebird then begin
      with TIbcConnection(AConnection) do begin
        Server   := AConnectionDefs.HostName;
        Database := AConnectionDefs.DatabaseName;
        Username := AConnectionDefs.Username;
        Password := AConnectionDefs.Password;
        Port     := inttostr(AConnectionDefs.DBPort);
        options.UseUnicode := True;
      end;
    end;
  end;
end;

{ TRESTDWIBDACQuery }

procedure TRESTDWIBDACQuery.createSequencedField(seqname, field : string);
var
  qry : TIbcQuery;
  fd : TField;
begin
  qry := TIbcQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWIBDACQuery.ExecSQL;
var
  qry : TIbcQuery;
begin
  inherited ExecSQL;
  qry := TIbcQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWIBDACQuery.FetchAll;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  qry.FetchingAll;
end;

procedure TRESTDWIBDACQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWIBDACQuery.Prepare;
var
  qry : TIbcQuery;
begin
  inherited Prepare;
  qry := TIbcQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWIBDACQuery.RowsAffected : Int64;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

function TRESTDWIBDACQuery.ParamCount : Integer;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  Result := qry.ParamCount;
end;

function TRESTDWIBDACQuery.getParamDataType(IParam : integer) : TFieldType;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWIBDACQuery.getParamName(IParam : integer) : string;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWIBDACQuery.getParamSize(IParam : integer) : integer;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWIBDACQuery.getParamValue(IParam : integer) : variant;
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWIBDACQuery.setParamDataType(IParam : integer; AValue : TFieldType);
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWIBDACQuery.setParamValue(IParam : integer; AValue : variant);
var
  qry : TIbcQuery;
begin
  qry := TIbcQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

procedure TRESTDWIBDACQuery.SaveToStream(stream: TStream);
var
  vDWMemtable : TRESTDWMemtable;
  qry : TIbcQuery;
begin
  inherited SaveToStream(stream);
  qry := TIbcQuery(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(Nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(vDWMemtable);
  end;
end;

{ TRESTDWIBDACTable }

procedure TRESTDWIBDACTable.FetchAll;
var
  qry : TIbcTable;
begin
  qry := TIbcTable(Self.Owner);
  qry.FetchingAll;
end;

procedure TRESTDWIBDACTable.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TIbcTable;
begin
  qry := TIbcTable(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWIBDACTable.SaveToStream(stream: TStream);
var
  vDWMemtable : TRESTDWMemtable;
  qry : TIbcTable;
begin
  inherited SaveToStream(stream);
  qry := TIbcTable(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(Nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(vDWMemtable);
  end;
end;

{$IFDEF RESTDWLAZARUS}
initialization
{$I ..\RESTDWLazarusDrivers.lrs}
{$ENDIF}

end.

