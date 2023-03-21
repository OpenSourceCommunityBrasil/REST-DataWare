unit uRESTDWAnyDACDriver;

{$I ..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilberto Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
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
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes, uADCompClient,
  uADCompDataSet, DB, uADStanStorage, uADStanIntf, uADDatSManager, 
  uADDAptIntf, uADDAptManager;

const
    rdwAnyDACDrivers : array[0..17] of string = (('ads'),('asa'),('db2'),('ds'),
                        ('fb'),('ib'),('iblite'),('infx'),('mongo'),('msacc'),
                        ('mssql'),('mysql'),('odbc'),('ora'),('pg'),('sqlite'),
                        ('tdata'),('tdbx'));

    rdwAnyDACDbType : array[0..17] of TRESTDWDatabaseType = ((dbtUndefined),(dbtUndefined),
                       (dbtDbase),(dbtUndefined),(dbtFirebird),(dbtInterbase),(dbtInterbase),
                       (dbtUndefined),(dbtUndefined),(dbtUndefined),(dbtMsSQL),(dbtMySQL),
                       (dbtODBC),(dbtOracle),(dbtPostgreSQL),(dbtSQLLite),(dbtUndefined),
                       (dbtUndefined));

type
  { TRESTDWAnyDACStoreProc }

  TRESTDWAnyDACStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  TRESTDWAnyDACTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream : TStream); override;
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure FetchAll; override;
  end;

  { TRESTDWAnyDACQuery }

  TRESTDWAnyDACQuery = class(TRESTDWDrvQuery)
  protected
    procedure createSequencedField(seqname, field : string); override;
  public
    procedure SaveToStream(stream : TStream); override;
    procedure ExecSQL; override;
    procedure Prepare; override;
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure FetchAll; override;

    function  RowsAffected : Int64; override;
    function  ParamCount : Integer; override;

    function  getParamDataType(IParam : integer) : TFieldType; override;
    function  getParamName(IParam : integer) : string; override;
    function  getParamSize(IParam : integer) : integer; override;
    function  getParamValue(IParam : integer) : variant; override;

    procedure setParamDataType(IParam : integer; AValue : TFieldType); override;
    procedure setParamValue(IParam : integer; AValue : variant); override;
  end;

  { TRESTDWAnyDACDriver }

  TRESTDWAnyDACDriver = class(TRESTDWDriverBase)
  protected
    Function compConnIsValid(comp : TComponent) : boolean; override;
    function getConectionType : TRESTDWDatabaseType; override;
  public
    function getQuery : TRESTDWDrvQuery; override;
    function getQuery(AUnidir : boolean) : TRESTDWDrvQuery; override;
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

 { TRESTDWAnyDACDriver }

function TRESTDWAnyDACDriver.getConectionType : TRESTDWDatabaseType;
var
  conn : string;
  i: integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  conn := LowerCase(TADConnection(Connection).DriverName);

  i := 0;
  while i < Length(rdwAnyDACDrivers) do begin
    if Pos(rdwAnyDACDrivers[i],conn) > 0 then begin
      Result := rdwAnyDACDbType[i];
      Break;
    end;
    i := i + 1;
  end;

  // Eloy
  case Result of
    dbtODBC:
      begin
        i := StrToIntDef(TADConnection(Connection).Params.Values['RDBMSKind'],
          TADConnection(Connection).RDBMSKind);
        case i of
          0: Result := dbtUndefined;
          1: Result := dbtOracle;
          2: Result := dbtMsSQL;
          3: Result := dbtAccess;
          4: Result := dbtMySQL;
          8: Result := dbtInterbase;
          9: Result := dbtFirebird;
         10: Result := dbtSQLLite;
         11: Result := dbtPostgreSQL;
        end;
      end;
  end;
end;

function TRESTDWAnyDACDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TADQuery;
begin
  qry := TADQuery.Create(Self);
  qry.Connection := TADConnection(Connection);
  qry.FormatOptions.StrsTrim       := StrsTrim;
  qry.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  qry.FormatOptions.StrsTrim2Len   := StrsTrim2Len;

  Result := TRESTDWAnyDACQuery.Create(qry);
end;

function TRESTDWAnyDACDriver.getQuery(AUnidir : boolean) : TRESTDWDrvQuery;
var
  qry : TADQuery;
begin
  Result := inherited getQuery(AUnidir);
  qry := TADQuery(Result.Owner);
  qry.FetchOptions.Unidirectional := AUnidir;
end;

function TRESTDWAnyDACDriver.getTable : TRESTDWDrvTable;
var
  qry : TADTable;
begin
  qry := TADTable.Create(Self);
  qry.FetchOptions.RowsetSize := -1;
  qry.Connection := TADConnection(Connection);
  qry.FormatOptions.StrsTrim       := StrsTrim;
  qry.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  qry.FormatOptions.StrsTrim2Len   := StrsTrim2Len;

  Result := TRESTDWAnyDACTable.Create(qry);
end;

function TRESTDWAnyDACDriver.getStoreProc : TRESTDWDrvStoreProc;
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
    TADConnection(Connection).StartTransaction;
end;

procedure TRESTDWAnyDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    TADConnection(Connection).Rollback;
end;

function TRESTDWAnyDACDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TADConnection);
end;

procedure TRESTDWAnyDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    TADConnection(Connection).Commit;
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
  fd : TField;
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

procedure TRESTDWAnyDACQuery.FetchAll;
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  qry.FetchAll;
end;

function TRESTDWAnyDACQuery.getParamDataType(IParam: integer): TFieldType;
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWAnyDACQuery.getParamName(IParam: integer): string;
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWAnyDACQuery.getParamSize(IParam: integer): integer;
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWAnyDACQuery.getParamValue(IParam: integer): variant;
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWAnyDACQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

function TRESTDWAnyDACQuery.ParamCount: Integer;
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  Result := qry.ParamCount;
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

procedure TRESTDWAnyDACQuery.SaveToStream(stream: TStream);
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  qry.SaveToStream(stream, sfBinary);

  stream.Position := 0;
end;

procedure TRESTDWAnyDACQuery.setParamDataType(IParam: integer;
                                              AValue: TFieldType);
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWAnyDACQuery.setParamValue(IParam: integer; AValue: variant);
var
  qry : TADQuery;
begin
  qry := TADQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

{ TRESTDWAnyDACTable }

procedure TRESTDWAnyDACTable.FetchAll;
var
  qry : TADTable;
begin
  qry := TADTable(Self.Owner);
  qry.FetchAll;
end;

procedure TRESTDWAnyDACTable.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TADTable;
  pname : string;
begin
  pname := Self.Params[IParam].Name;
  qry := TADTable(Self.Owner);
  qry.ParamByName(pname).LoadFromStream(stream,blobtype);
end;

procedure TRESTDWAnyDACTable.SaveToStream(stream: TStream);
var
  qry : TADTable;
begin
  qry := TADTable(Self.Owner);
  qry.SaveToStream(stream, sfBinary);

  stream.Position := 0;
end;

end.
