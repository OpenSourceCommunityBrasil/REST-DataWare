unit uRESTDWMyDACDriver;

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
  MyClasses, MyAccess, MyScript, DADump, MyDump, VirtualTable, MemDS, DBAccess,
  uRESTDWDriverBase, uRESTDWBasicTypes, uRESTDWMemtable;

type
  TRESTDWMyDACTable = class(TRESTDWDrvTable)
  public
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure SaveToStream(stream : TStream); override;
    procedure FetchAll; override;
  end;

  { TRESTDWMyDACStoreProc }

  TRESTDWMyDACStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWMyDACQuery }

  TRESTDWMyDACQuery = class(TRESTDWDrvQuery)
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

  { TRESTDWMyDACDriver }

  TRESTDWMyDACDriver = class(TRESTDWDriverBase)
  private
    FTransaction : TMyTransaction;
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
  RegisterComponents('REST Dataware - Drivers', [TRESTDWMyDACDriver]);
end;

{ TRESTDWMyDACStoreProc }

procedure TRESTDWMyDACStoreProc.ExecProc;
var
  qry : TMyStoredProc;
begin
  inherited ExecProc;
  qry := TMyStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWMyDACStoreProc.Prepare;
var
  qry : TMyStoredProc;
begin
  inherited Prepare;
  qry := TMyStoredProc(Self.Owner);
  qry.Prepare;
end;

 { TRESTDWMyDACDriver }

function TRESTDWMyDACDriver.getConectionType : TRESTDWDatabaseType;
begin
  // somente MySQL
  Result := dbtMySQL;
end;

function TRESTDWMyDACDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TMyQuery;
begin
  qry := TMyQuery.Create(Self);
  qry.Connection := TMyConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWMyDACQuery.Create(qry);
end;

function TRESTDWMyDACDriver.getTable : TRESTDWDrvTable;
var
  qry : TMyTable;
begin
  qry := TMyTable.Create(Self);
  qry.Connection := TMyConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWMyDACTable.Create(qry);
end;

function TRESTDWMyDACDriver.getStoreProc : TRESTDWDrvStoreProc;
var
  qry : TMyStoredProc;
begin
  qry := TMyStoredProc.Create(Self);
  qry.Connection := TMyConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;
  qry.Transaction               := FTransaction;

  Result := TRESTDWMyDACStoreProc.Create(qry);
end;

procedure TRESTDWMyDACDriver.Connect;
begin
  inherited Connect;
  if Assigned(Connection) then
    TMyConnection(Connection).Open;
end;

destructor TRESTDWMyDACDriver.Destroy;
begin

  inherited;
end;

procedure TRESTDWMyDACDriver.Disconect;
begin
  inherited Disconect;
  if Assigned(Connection) then
    TMyConnection(Connection).Close;
end;

function TRESTDWMyDACDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TMyConnection(Connection).Connected;
end;

procedure TRESTDWMyDACDriver.setConnection(AValue: TComponent);
begin
  if not Assigned(FTransaction) then
    FTransaction := TMyTransaction.Create(Self);
  FTransaction.DefaultConnection := TMyConnection(AValue);
  TMyConnection(AValue).DefaultTransaction := FTransaction;
end;

function TRESTDWMyDACDriver.connInTransaction : boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TMyConnection(Connection).InTransaction;
end;

procedure TRESTDWMyDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) then
    TMyConnection(Connection).StartTransaction;
end;

procedure TRESTDWMyDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    TMyConnection(Connection).Rollback;
end;

function TRESTDWMyDACDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TMyConnection);
end;

procedure TRESTDWMyDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    TMyConnection(Connection).Commit;
end;

constructor TRESTDWMyDACDriver.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TMyTransaction.Create(Self);
  FTransaction.DefaultConnection := TMyConnection(Connection);
end;

class procedure TRESTDWMyDACDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                    var AConnection : TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    if AConnectionDefs.DriverType = dbtMySQL then begin
      with TMyConnection(AConnection) do begin
        Server   := AConnectionDefs.HostName;
        Database := AConnectionDefs.DatabaseName;
        Username := AConnectionDefs.Username;
        Password := AConnectionDefs.Password;
        Port     := AConnectionDefs.DBPort;
      end;
    end;
  end;
end;

{ TRESTDWMyDACQuery }

procedure TRESTDWMyDACQuery.createSequencedField(seqname, field : string);
var
  qry : TMyQuery;
  fd : TField;
begin
  qry := TMyQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWMyDACQuery.ExecSQL;
var
  qry : TMyQuery;
begin
  inherited ExecSQL;
  qry := TMyQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWMyDACQuery.FetchAll;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  qry.FetchingAll;
end;

procedure TRESTDWMyDACQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWMyDACQuery.Prepare;
var
  qry : TMyQuery;
begin
  inherited Prepare;
  qry := TMyQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWMyDACQuery.RowsAffected : Int64;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

function TRESTDWMyDACQuery.ParamCount : Integer;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  Result := qry.ParamCount;
end;

function TRESTDWMyDACQuery.getParamDataType(IParam : integer) : TFieldType;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWMyDACQuery.getParamName(IParam : integer) : string;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWMyDACQuery.getParamSize(IParam : integer) : integer;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWMyDACQuery.getParamValue(IParam : integer) : variant;
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWMyDACQuery.setParamDataType(IParam : integer; AValue : TFieldType);
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWMyDACQuery.setParamValue(IParam : integer; AValue : variant);
var
  qry : TMyQuery;
begin
  qry := TMyQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

procedure TRESTDWMyDACQuery.SaveToStream(stream: TStream);
var
  vDWMemtable : TRESTDWMemtable;
  qry : TMyQuery;
begin
  inherited SaveToStream(stream);
  qry := TMyQuery(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(Nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(vDWMemtable);
  end;
end;

{ TRESTDWMyDACTable }

procedure TRESTDWMyDACTable.FetchAll;
var
  qry : TMyTable;
begin
  qry := TMyTable(Self.Owner);
  qry.FetchingAll;
end;

procedure TRESTDWMyDACTable.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TMyTable;
begin
  qry := TMyTable(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWMyDACTable.SaveToStream(stream: TStream);
var
  vDWMemtable : TRESTDWMemtable;
  qry : TMyTable;
begin
  inherited SaveToStream(stream);
  qry := TMyTable(Self.Owner);
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

