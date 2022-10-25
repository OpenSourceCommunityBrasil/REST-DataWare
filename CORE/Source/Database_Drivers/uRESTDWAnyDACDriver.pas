unit uRESTDWAnyDACDriver;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

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
  {$IFDEF FPC}
    LResources,
  {$ENDIF}
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes, uADCompClient,
  uADCompDataSet, DB;

const
  {$IFDEF FPC}
    rdwAnyDACDrivers : array of string = ('ads','asa','db2','ds','fb','ib',
                        'iblite','infx','mongo','msacc','mssql','mysql','odbc',
                        'ora','pg','sqlite','tdata','tdbx');

    rdwAnyDACDbType : array of TRESTDWDatabaseType = (dbtUndefined,dbtUndefined,
                       dbtDbase,dbtUndefined,dbtFirebird,dbtInterbase,dbtInterbase,
                       dbtUndefined,dbtUndefined,dbtUndefined,dbtMsSQL,dbtMySQL,
                       dbtODBC,dbtOracle,dbtPostgreSQL,dbtSQLLite,dbtUndefined,
                       dbtUndefined);
  {$ELSE}
    rdwAnyDACDrivers : array of string = ['ads','asa','db2','ds','fb','ib',
                        'iblite','infx','mongo','msacc','mssql','mysql','odbc',
                        'ora','pg','sqlite','tdata','tdbx'];

    rdwAnyDACDbType : array of TRESTDWDatabaseType = [dbtUndefined,dbtUndefined,
                       dbtDbase,dbtUndefined,dbtFirebird,dbtInterbase,dbtInterbase,
                       dbtUndefined,dbtUndefined,dbtUndefined,dbtMsSQL,dbtMySQL,
                       dbtODBC,dbtOracle,dbtPostgreSQL,dbtSQLLite,dbtUndefined,
                       dbtUndefined];
  {$ENDIF}

  crdwConnectionNotFireDAC = 'Componente não é um AnyDACConnection';

type
  { TRESTDWAnyDACDataset }

  TRESTDWAnyDACDataset = class(TRESTDWDataset)
  public
    procedure SaveToStream(stream : TStream); override;
  end;

  { TRESTDWAnyDACStoreProc }

  TRESTDWAnyDACStoreProc = class(TRESTDWStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWAnyDACQuery }

  TRESTDWAnyDACQuery = class(TRESTDWQuery)
  protected
    procedure createSequencedField(seqname, field : string); override;
  public
    procedure ExecSQL; override;
    procedure Prepare; override;

    function RowsAffected : Int64; override;
  end;

  { TRESTDWAnyDACDriver }

  TRESTDWAnyDACDriver = class(TRESTDWDriverBase)
  private
    function aGetConnection: TADConnection;
    procedure aSetConnection(const Value: TADConnection);
  protected
    procedure setConnection(AValue: TComponent); override;

    function getConectionType : TRESTDWDatabaseType; override;
  public
    function getQuery : TRESTDWQuery; override;
    function getTable : TRESTDWTable; override;
    function getStoreProc : TRESTDWStoreProc; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;
    function connInTransaction : boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  published
    Property Connection : TADConnection Read aGetConnection Write aSetConnection;
  end;

procedure Register;

implementation

{$IFNDEF FPC}
 {$if CompilerVersion < 23}
  {$R .\RESTDWAnyDACDriver.dcr}
 {$IFEND}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWAnyDACDriver]);
end;

{ TRESTDWAnyDACStoreProc }

procedure TRESTDWAnyDACStoreProc.ExecProc;
var
  qry : TADStoredProc;
begin
  inherited ExecProc;
  qry := TADStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWAnyDACStoreProc.Prepare;
var
  qry : TADStoredProc;
begin
  inherited Prepare;
  qry := TADStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWAnyDACDataset }

procedure TRESTDWAnyDACDataset.SaveToStream(stream : TStream);
var
  qry : TADDataset;
begin
  inherited SaveToStream(stream);
  qry := TADDataset(Self.Owner);
  qry.SaveToStream(stream);

  stream.Position := 0;
end;

 { TRESTDWAnyDACDriver }

procedure TRESTDWAnyDACDriver.setConnection(AValue : TComponent);
begin
  if (Assigned(AValue)) and (not AValue.InheritsFrom(TADConnection)) then
    raise Exception.Create(crdwConnectionNotFireDAC);
  inherited setConnection(AValue);
end;

function TRESTDWAnyDACDriver.getConectionType : TRESTDWDatabaseType;
var
  conn : string;
  i: integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  conn := LowerCase(TADConnector(Connection).DriverName);

  i := 0;
  while i < Length(rdwAnyDACDrivers) do begin
    if Pos(rdwAnyDACDrivers[i],conn) > 0 then begin
      Result := rdwAnyDACDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

function TRESTDWAnyDACDriver.getQuery : TRESTDWQuery;
var
  qry : TADQuery;
begin
  qry := TADQuery.Create(Self);
  qry.Connection := TADConnection(Connection);

  Result := TRESTDWAnyDACQuery.Create(qry);
end;

function TRESTDWAnyDACDriver.getTable : TRESTDWTable;
var
  qry : TADTable;
begin
  qry := TADTable.Create(Self);
  qry.FetchOptions.RowsetSize := -1;
  qry.Connection := TADConnection(Connection);

  Result := TRESTDWTable.Create(qry);
end;

function TRESTDWAnyDACDriver.getStoreProc : TRESTDWStoreProc;
var
  qry : TADStoredProc;
begin
  qry := TADStoredProc.Create(Self);
  qry.Connection := TADConnection(Connection);
  qry.FormatOptions.StrsTrim       := StrsTrim;
  qry.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  qry.FormatOptions.StrsTrim2Len   := StrsTrim2Len;

  Result := TRESTDWAnyDACStoreProc.Create(qry);
end;

procedure TRESTDWAnyDACDriver.Connect;
begin
  if Assigned(Connection) then
    TADConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWAnyDACDriver.Disconect;
begin
  if Assigned(Connection) then
    TADConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWAnyDACDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TADConnection(Connection).Connected;
end;

function TRESTDWAnyDACDriver.connInTransaction : boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TADConnection(Connection).InTransaction;
end;

procedure TRESTDWAnyDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) then
    Result := TADConnection(Connection).StartTransaction;
end;

procedure TRESTDWAnyDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    Result := TADConnection(Connection).Rollback;
end;

function TRESTDWAnyDACDriver.aGetConnection: TADConnection;
begin
 Result := TADConnection(GetConnection);
end;

procedure TRESTDWAnyDACDriver.aSetConnection(const Value: TADConnection);
begin
 setConnection(Value);
end;

procedure TRESTDWAnyDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    Result := TADConnection(Connection).Commit;
end;

class procedure TRESTDWAnyDACDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                     var AConnection : TComponent);
  procedure ServerParamValue(ParamName, Value : String);
  var
    I, vIndex : Integer;
  begin
   for I := 0 To TADConnection(AConnection).Params.Count-1 do begin
     if SameText(TADConnection(AConnection).Params.Names[I],ParamName) then begin
       vIndex := I;
       Break;
     end;
   end;
   if vIndex = -1 Then
     TADConnection(AConnection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Value]))
   else
     TADConnection(AConnection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Value]);
  end;
begin
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
        ServerParamValue('DriverID',  'FB');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtInterbase  : begin
        ServerParamValue('DriverID',  'IB');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('Protocol',  Uppercase(AConnectionDefs.Protocol));
      end;
      dbtMySQL      : begin
        ServerParamValue('DriverID',  'MySQL');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtSQLLite    : begin
        ServerParamValue('DriverID',  'SQLite');
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtOracle     : begin

      end;
      dbtMsSQL      : begin
        ServerParamValue('DriverID',  'MsSQL');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
      dbtODBC       : begin
        ServerParamValue('DriverID',  'ODBC');
        ServerParamValue('DataSource', AConnectionDefs.DataSource);
      end;
      dbtParadox    : begin

      end;
      dbtPostgreSQL : begin
        ServerParamValue('DriverID',  'PQ');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
      end;
    end;
  end;
end;

{ TRESTDWAnyDACQuery }

procedure TRESTDWAnyDACQuery.createSequencedField(seqname, field : string);
var
  qry : TADQuery;
  fd : TADField;
begin
  qry := TADQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWAnyDACQuery.ExecSQL;
var
  qry : TADQuery;
begin
  inherited ExecSQL;
  qry := TADQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWAnyDACQuery.Prepare;
var
  qry : TADQuery;
begin
  inherited Prepare;
  qry := TADQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWAnyDACQuery.RowsAffected : Int64;
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

{$IFDEF FPC}
initialization
  {$I ../../Packages/Lazarus/Drivers/anydac/restdwanydacdriver.lrs}
{$ENDIF}

end.

