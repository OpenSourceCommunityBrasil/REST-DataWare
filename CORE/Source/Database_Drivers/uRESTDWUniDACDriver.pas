unit uRESTDWUniDACDriver;

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
  {$IFDEF RESTDWLAZARUS}
    LResources,
  {$ENDIF}
  Classes, SysUtils, DB,
  MemDS, DBAccess, Uni, VirtualTable,
  uRESTDWMemtable, uRESTDWDriverBase, uRESTDWBasicTypes, uRESTDWProtoTypes;

const
  rdwUniDACProtocols : array[0..27] of string = (('access'),('advantage'),
                      ('ase'),('db2'),('dbf'),('interbase'),('mysql'),
                      ('mongodb'),('nexusdb'),('obdc'),('oracle'),
                      ('postgresql'),('redshift'),('sql server'),('sqlite'),
                      ('bigcommerce'),('bigquery'),('dynamics 365'),
                      ('freshbooks'),('hubspot'),('magento'),('mailchimp'),
                      ('netsuite'),('quickbooks'),('salesforce mc'),
                      ('salesforce'),('sugar crm'),('zoho crm'));

  rdwUniDACDbType : array[0..27] of TRESTDWDatabaseType = ((dbtAccess),
                    (dbtUndefined),(dbtUndefined),(dbtUndefined),(dbtDbase),
                    (dbtInterbase),(dbtMySQL),(dbtUndefined),(dbtUndefined),
                    (dbtODBC),(dbtOracle),(dbtPostgreSQL),(dbtUndefined),
                    (dbtMsSQL),(dbtSQLLite),(dbtUndefined),(dbtUndefined),
                    (dbtUndefined),(dbtUndefined),(dbtUndefined),(dbtUndefined),
                    (dbtUndefined),(dbtUndefined),(dbtUndefined),(dbtUndefined),
                    (dbtUndefined),(dbtUndefined),(dbtUndefined));

type
  TRESTDWUniDACTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream : TStream); override;
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure FetchAll; override;
  end;

  { TRESTDWUniDACStoreProc }

  TRESTDWUniDACStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWUniDACQuery }

  TRESTDWUniDACQuery = class(TRESTDWDrvQuery)
  protected
    procedure createSequencedField(seqname,field : string); override;
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

  { TRESTDWUniDACDriver }

  TRESTDWUniDACDriver = class(TRESTDWDriverBase)
  private
    FTransaction : TUniTransaction;
  protected
    procedure setConnection(AValue: TComponent); override;
    function getConectionType : TRESTDWDatabaseType; override;
    Function compConnIsValid(comp : TComponent) : boolean; override;
  public
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
  RegisterComponents('REST Dataware - Drivers', [TRESTDWUniDACDriver]);
end;

{ TRESTDWUniDACStoreProc }

procedure TRESTDWUniDACStoreProc.ExecProc;
var
  qry : TUniStoredProc;
begin
  inherited ExecProc;
  qry := TUniStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWUniDACStoreProc.Prepare;
var
  qry : TUniStoredProc;
begin
  inherited Prepare;
  qry := TUniStoredProc(Self.Owner);
  qry.Prepare;
end;

 { TRESTDWUniDACDriver }

function TRESTDWUniDACDriver.getConectionType : TRESTDWDatabaseType;
var
  prot : string;
  i : integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  prot := LowerCase(TUniConnection(Connection).ProviderName);

  i := 0;
  while i < Length(rdwUniDACProtocols) do begin
    if Pos(rdwUniDACProtocols[i],prot) > 0 then begin
      Result := rdwUniDACDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

function TRESTDWUniDACDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TUniQuery;
begin
  qry := TUniQuery.Create(Self);
  qry.Connection := TUniConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWUniDACQuery.Create(qry);
end;

function TRESTDWUniDACDriver.getTable : TRESTDWDrvTable;
var
  qry : TUniTable;
begin
  qry := TUniTable.Create(Self);
  qry.Connection  := TUniConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWUniDACTable.Create(qry);
end;

function TRESTDWUniDACDriver.getStoreProc : TRESTDWDrvStoreProc;
var
  qry : TUniStoredProc;
begin
  qry := TUniStoredProc.Create(Self);
  qry.Connection := TUniConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWUniDACStoreProc.Create(qry);
end;

procedure TRESTDWUniDACDriver.Connect;
begin
  if Assigned(Connection) then
    TUniConnection(Connection).Open;
  inherited Connect;
end;

destructor TRESTDWUniDACDriver.Destroy;
begin
  FreeAndNil(FTransaction);
  inherited;
end;

procedure TRESTDWUniDACDriver.Disconect;
begin
  if Assigned(Connection) then
    TUniConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWUniDACDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TUniConnection(Connection).Connected;
end;

procedure TRESTDWUniDACDriver.setConnection(AValue: TComponent);
begin
  inherited;
  if not Assigned(FTransaction) then
    FTransaction := TUniTransaction.Create(Self);
  FTransaction.DefaultConnection := TUniConnection(AValue);
  TUniConnection(AValue).DefaultTransaction := FTransaction;
end;

function TRESTDWUniDACDriver.connInTransaction : boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TUniConnection(Connection).InTransaction;
end;

procedure TRESTDWUniDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) then
    TUniConnection(Connection).StartTransaction;
end;

procedure TRESTDWUniDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    TUniConnection(Connection).Rollback;
end;

function TRESTDWUniDACDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TUniConnection);
end;

procedure TRESTDWUniDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    TUniConnection(Connection).Commit;
end;

constructor TRESTDWUniDACDriver.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TUniTransaction.Create(Self);
  FTransaction.DefaultConnection := TUniConnection(Connection);
end;

class procedure TRESTDWUniDACDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                     var AConnection : TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    case AConnectionDefs.DriverType Of
      dbtUndefined  : TUniConnection(AConnection).ProviderName := '';
      dbtAccess     : TUniConnection(AConnection).ProviderName := 'access';
      dbtDbase      : TUniConnection(AConnection).ProviderName := 'dbf';
      dbtParadox    : TUniConnection(AConnection).ProviderName := '';
      dbtFirebird   : TUniConnection(AConnection).ProviderName := 'interbase';
      dbtInterbase  : TUniConnection(AConnection).ProviderName := 'interbase';
      dbtMySQL      : TUniConnection(AConnection).ProviderName := 'mysql';
      dbtSQLLite    : TUniConnection(AConnection).ProviderName := 'sqlite';
      dbtOracle     : TUniConnection(AConnection).ProviderName := 'oracle';
      dbtMsSQL      : TUniConnection(AConnection).ProviderName := 'sql server';
      dbtODBC       : TUniConnection(AConnection).ProviderName := 'odbc';
      dbtPostgreSQL : TUniConnection(AConnection).ProviderName := 'postgresql';
      dbtAdo        : TUniConnection(AConnection).ProviderName := '';
    end;
  end;

  with TUniConnection(AConnection) do begin
    Server   := AConnectionDefs.HostName;
    Database := AConnectionDefs.DatabaseName;
    Username := AConnectionDefs.Username;
    Password := AConnectionDefs.Password;
    Port     := AConnectionDefs.DBPort;
  end;
end;

{ TRESTDWUniDACQuery }

procedure TRESTDWUniDACQuery.createSequencedField(seqname, field : string);
var
  qry : TUniQuery;
  fd : TField;
begin
  qry := TUniQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWUniDACQuery.ExecSQL;
var
  qry : TUniQuery;
begin
  inherited ExecSQL;
  qry := TUniQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWUniDACQuery.FetchAll;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  qry.FetchingAll;
end;

procedure TRESTDWUniDACQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWUniDACQuery.Prepare;
var
  qry : TUniQuery;
begin
  inherited Prepare;
  qry := TUniQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWUniDACQuery.RowsAffected : Int64;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

function TRESTDWUniDACQuery.ParamCount : Integer;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  Result := qry.ParamCount;
end;

function TRESTDWUniDACQuery.getParamDataType(IParam : integer) : TFieldType;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWUniDACQuery.getParamName(IParam : integer) : string;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWUniDACQuery.getParamSize(IParam : integer) : integer;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWUniDACQuery.getParamValue(IParam : integer) : variant;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWUniDACQuery.setParamDataType(IParam : integer; AValue : TFieldType);
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWUniDACQuery.setParamValue(IParam : integer; AValue : variant);
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

procedure TRESTDWUniDACQuery.SaveToStream(stream: TStream);
var
  vTable : TVirtualTable;
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  vTable  := TVirtualTable.Create(Nil);
  try
    vTable.Assign(qry);
    vTable.SaveToStream(stream);
    stream.Position := 0;
  finally
    vTable.Free;
  end;
end;

{ TRESTDWUniDACTable }

procedure TRESTDWUniDACTable.FetchAll;
var
  qry : TUniTable;
begin
  qry := TUniTable(Self.Owner);
  qry.FetchingAll;
end;

procedure TRESTDWUniDACTable.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TUniTable;
begin
  qry := TUniTable(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWUniDACTable.SaveToStream(stream: TStream);
var
  qry : TUniTable;
  vTable : TVirtualTable;
begin
  qry := TUniTable(Self.Owner);
  vTable  := TVirtualTable.Create(Nil);
  try
    vTable.Assign(qry);
    vTable.SaveToStream(stream);
    stream.Position := 0;
  finally
    vTable.Free;
  end;
end;

{$IFDEF RESTDWLAZARUS}
initialization
{$I ..\RESTDWLazarusDrivers.lrs}
{$ENDIF}

end.

