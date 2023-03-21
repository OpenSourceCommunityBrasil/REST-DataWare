unit uRESTDWLazarusDriver;

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
  LResources, SQLDB, Classes, SysUtils, DB,
  uRESTDWDriverBase, uRESTDWProtoTypes, uRESTDWBasicTypes;

const
  rdwLazSQLConnector : array[0..9] of string = (('mssql'),('sybase'),
                      ('postgresql'),('pqconn'),('oracle'),('odbc'),('mysql'),
                      ('sqlite'),('firebird'),('ibconn'));

  rdwLazSQLDbType : array[0..9] of TRESTDWDatabaseType = ((dbtMsSQL),(dbtUndefined),
                    (dbtPostgreSQL),(dbtPostgreSQL),(dbtOracle),(dbtODBC),(dbtMySQL),
                    (dbtSQLLite),(dbtFirebird),(dbtFirebird));

type
  { TRESTDWLazSQLQuery }

  TRESTDWLazSQLQuery = class(TRESTDWDrvQuery)
  private
    FSequence : TSQLSequence;
  protected
    procedure createSequencedField(seqname,field : string); override;
  public
    procedure SaveToStream(stream : TStream); override;
    procedure ExecSQL; override;
    procedure Prepare; override;

    destructor Destroy; override;

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

  { TRESTDWLazSQLDriver }

  TRESTDWLazarusDriver = class(TRESTDWDriverBase)
  private
    FTransaction : TSQLTransaction;
  protected
    procedure setConnection(AValue: TComponent); override;

    function getConectionType : TRESTDWDatabaseType; override;
    Function compConnIsValid(comp : TComponent) : boolean; override;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    function getQuery : TRESTDWDrvQuery; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;

    function connInTransaction : boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;

    class procedure CreateConnection(const AConnectionDefs  : TConnectionDefs;
                                     var AConnection        : TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWLazarusDriver]);
end;

{ TRESTDWLazSQLQuery }

procedure TRESTDWLazSQLQuery.createSequencedField(seqname, field : string);
var
  qry : TSQLQuery;
begin
  if Trim(seqname) = '' then
    Exit;

  qry := TSQLQuery(Self.Owner);
  if FSequence = nil then
    FSequence := TSQLSequence.Create(qry);

  FSequence.SequenceName := seqname;
  FSequence.FieldName := field;

  qry.Sequence := FSequence;
end;

procedure TRESTDWLazSQLQuery.ExecSQL;
var
  qry : TSQLQuery;
begin
  inherited ExecSQL;
  qry := TSQLQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWLazSQLQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWLazSQLQuery.Prepare;
var
  qry : TSQLQuery;
begin
  inherited Prepare;
  qry := TSQLQuery(Self.Owner);
  qry.Prepare;
end;

destructor TRESTDWLazSQLQuery.Destroy;
begin
  if FSequence <> nil then
    FSequence.Free;
  inherited Destroy;
end;

function TRESTDWLazSQLQuery.RowsAffected: Int64;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

function TRESTDWLazSQLQuery.ParamCount : Integer;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  Result := qry.Params.Count;
end;

function TRESTDWLazSQLQuery.getParamDataType(IParam : integer) : TFieldType;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWLazSQLQuery.getParamName(IParam : integer) : string;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWLazSQLQuery.getParamSize(IParam : integer) : integer;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWLazSQLQuery.getParamValue(IParam : integer) : variant;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWLazSQLQuery.setParamDataType(IParam : integer; AValue : TFieldType);
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWLazSQLQuery.setParamValue(IParam : integer; AValue : variant);
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

procedure TRESTDWLazSQLQuery.SaveToStream(stream: TStream);
var
  qry : TSQLQuery;
begin
  inherited SaveToStream(stream);
  qry := TSQLQuery(Self.Owner);
  qry.SaveToStream(stream);

  stream.Position := 0;
end;

{ TRESTDWLazSQLDriver }

procedure TRESTDWLazarusDriver.setConnection(AValue: TComponent);
begin
  if FTransaction <> nil then
    FTransaction.SQLConnection := TSQLConnection(AValue);
  inherited setConnection(AValue);
end;

function TRESTDWLazarusDriver.getConectionType: TRESTDWDatabaseType;
var
  conn : string;
  i: integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  if Connection is TSQLConnector then
    conn := LowerCase(TSQLConnector(Connection).ConnectorType)
  else
    conn := LowerCase(Connection.ClassName);

  i := 0;
  while i < Length(rdwLazSQLConnector) do begin
    if Pos(rdwLazSQLConnector[i],conn) > 0 then begin
      Result := rdwLazSQLDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

function TRESTDWLazarusDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TSQLQuery;
begin
  qry := TSQLQuery.Create(Self);
  qry.SQLConnection := TSQLConnection(Connection);
  qry.Transaction := FTransaction;

  Result := TRESTDWLazSQLQuery.Create(qry);
end;

procedure TRESTDWLazarusDriver.Connect;
begin
  if Assigned(Connection) then
    TSQLConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWLazarusDriver.Disconect;
begin
  if Assigned(Connection) then
    TSQLConnection(Connection).Close;
  inherited Disconect;
end;

 constructor TRESTDWLazarusDriver.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TSQLTransaction.Create(Self);
  FTransaction.SQLConnection := TSQLConnection(Connection);
end;

destructor TRESTDWLazarusDriver.Destroy;
begin
  FTransaction.Free;
  inherited Destroy;
end;

function TRESTDWLazarusDriver.isConnected: boolean;
begin
  Result := inherited isConnected;
  if Assigned(Connection) then
    Result := TSQLConnection(Connection).Connected;
end;

function TRESTDWLazarusDriver.connInTransaction: boolean;
begin
  Result := FTransaction.Active;
end;

procedure TRESTDWLazarusDriver.connStartTransaction;
begin
  FTransaction.StartTransaction;
end;

procedure TRESTDWLazarusDriver.connRollback;
begin
  FTransaction.Rollback;
end;

function TRESTDWLazarusDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TSQLConnection);
end;

procedure TRESTDWLazarusDriver.connCommit;
begin
  FTransaction.Commit;
end;

class procedure TRESTDWLazarusDriver.CreateConnection(const AConnectionDefs: TConnectionDefs;
                                                     var AConnection: TComponent);
  procedure ServerParamValue(ParamName, Value : String);
  var
    I, vIndex : Integer;
  begin
   for I := 0 To TSQLConnection(AConnection).Params.Count-1 do begin
     if SameText(TSQLConnection(AConnection).Params.Names[I],ParamName) then begin
       vIndex := I;
       Break;
     end;
   end;
   if vIndex = -1 Then
     TSQLConnection(AConnection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Value]))
   else
     TSQLConnection(AConnection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Value]);
  end;
Begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    case AConnectionDefs.DriverType Of
      dbtUndefined  : begin

      end;
      dbtAccess     : begin

      end;
      dbtDbase      : begin

      end;
      dbtFirebird   : begin
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtInterbase  : begin
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtMySQL      : begin
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtSQLLite    : begin
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
      end;
      dbtOracle     : begin

      end;
      dbtMsSQL      : begin
        ServerParamValue('DriverID',  AConnectionDefs.DriverID);
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtODBC       : begin
        ServerParamValue('DataSource', AConnectionDefs.DataSource);
      end;
      dbtParadox    : begin

      end;
      dbtPostgreSQL : begin

      end;
    end;
  end;
end;

initialization
{$I ..\RESTDWLazarusDrivers.lrs}

end.

