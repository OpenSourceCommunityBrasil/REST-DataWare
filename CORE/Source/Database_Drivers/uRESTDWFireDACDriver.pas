unit uRESTDWFireDACDriver;

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
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.StorageBin,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.Param, FireDAC.DatS, DB, uRESTDWBasicDB, uRESTDWProtoTypes,
  FireDAC.Phys.RESTDW;

const
  rdwFireDACDrivers : array[0..17] of string = (('ads'),('asa'),('db2'),('ds'),
                      ('fb'),('ib'),('iblite'),('infx'),('mongo'),('msacc'),
                      ('mssql'),('mysql'),('odbc'),('ora'),('pg'),('sqlite'),
                      ('tdata'),('tdbx'));

  rdwFireDACDbType : array[0..17] of TRESTDWDatabaseType = ((dbtUndefined),(dbtUndefined),
                     (dbtDbase),(dbtUndefined),(dbtFirebird),(dbtInterbase),(dbtInterbase),
                     (dbtUndefined),(dbtUndefined),(dbtUndefined),(dbtMsSQL),(dbtMySQL),
                     (dbtODBC),(dbtOracle),(dbtPostgreSQL),(dbtSQLLite),(dbtUndefined),
                     (dbtUndefined));

type
  { TRESTDWFireDACStoreProc }

  TRESTDWFireDACStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWFireDACTable }
  TRESTDWFireDACTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream : TStream); override;
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure FetchAll; override;
  end;

  { TRESTDWFireDACQuery }

  TRESTDWFireDACQuery = class(TRESTDWDrvQuery)
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

  { TRESTDWFireDACDriver }

  TRESTDWFireDACDriver = class(TRESTDWDriverBase)
  private
    FConnTeste : TComponent;
    function isAutoCommit : boolean;
  protected
    function getConectionType : TRESTDWDatabaseType; override;
    Function compConnIsValid(comp : TComponent) : boolean; override;
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
    class procedure CreateConnection(const AConnectionDefs  : TConnectionDefs;
                                     var AConnection        : TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWFireDACDriver]);
  RegisterComponents('REST Dataware - PhysLink', [TRESTDWFireDACPhysLink]);
end;

{ TRESTDWFireDACStoreProc }

procedure TRESTDWFireDACStoreProc.ExecProc;
var
  qry : TFDStoredProc;
begin
  inherited ExecProc;
  qry := TFDStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWFireDACStoreProc.Prepare;
var
  qry : TFDStoredProc;
begin
  inherited Prepare;
  qry := TFDStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWFireDACDriver }

function TRESTDWFireDACDriver.isAutoCommit: boolean;
begin
  Result := False;
  {$IFDEF DELPHI10_0UP}
    if Assigned(Connection) then
      Result := TFDConnection(Connection).UpdateOptions.AutoCommitUpdates;
  {$ENDIF}
end;

function TRESTDWFireDACDriver.getConectionType: TRESTDWDatabaseType;
var
  conn : string;
  i: integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  conn := LowerCase(TFDConnection(Connection).DriverName);

  i := 0;
  while i < Length(rdwFireDACDrivers) do begin
    if Pos(rdwFireDACDrivers[i],conn) > 0 then begin
      Result := rdwFireDACDbType[i];
      Break;
    end;
    i := i + 1;
  end;

  // Eloy
  case Result of
    dbtODBC:
      begin
        i := StrToIntDef(TFDConnection(Connection).Params.Values['RDBMSKind'],
          TFDConnection(Connection).RDBMSKind);
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

function TRESTDWFireDACDriver.getQuery: TRESTDWDrvQuery;
var
  qry : TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  qry.Connection := TFDConnection(Connection);
  qry.FormatOptions.StrsTrim       := StrsTrim;
  qry.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  qry.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  qry.ResourceOptions.ParamCreate  := True;
  qry.ResourceOptions.StoreItems   := [siMeta,siData,siDelta];
  qry.FetchOptions.Mode            := fmAll;

  Result := TRESTDWFireDACQuery.Create(qry);
end;

function TRESTDWFireDACDriver.getQuery(AUnidir : boolean) : TRESTDWDrvQuery;
var
  qry : TFDQuery;
begin

  Result := inherited getQuery(AUnidir);
  qry := TFDQuery(Result.Owner);
  qry.FetchOptions.Unidirectional := AUnidir;
end;

function TRESTDWFireDACDriver.getTable : TRESTDWDrvTable;
var
  qry : TFDTable;
begin
  qry := TFDTable.Create(Self);
  qry.FetchOptions.RowsetSize := -1;
  qry.Connection := TFDConnection(Connection);
  qry.CachedUpdates := False;

  Result := TRESTDWFireDACTable.Create(qry);
end;

function TRESTDWFireDACDriver.getStoreProc : TRESTDWDrvStoreProc;
var
  qry : TFDStoredProc;
begin
  qry := TFDStoredProc.Create(Self);
  qry.Connection := TFDConnection(Connection);
  qry.FormatOptions.StrsTrim       := StrsTrim;
  qry.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  qry.FormatOptions.StrsTrim2Len   := StrsTrim2Len;

  Result := TRESTDWFireDACStoreProc.Create(qry);
end;

procedure TRESTDWFireDACDriver.Connect;
begin
  if Assigned(Connection) then
    TFDConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWFireDACDriver.Disconect;
begin
  if Assigned(Connection) then
    TFDConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWFireDACDriver.isConnected: boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TFDConnection(Connection).Connected;
end;

function TRESTDWFireDACDriver.connInTransaction: boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TFDConnection(Connection).InTransaction;
end;

procedure TRESTDWFireDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) and (not isAutoCommit) then
    TFDConnection(Connection).StartTransaction;
end;

procedure TRESTDWFireDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) and (not isAutoCommit) then
    TFDConnection(Connection).Rollback;
end;

function TRESTDWFireDACDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TFDConnection);
end;

procedure TRESTDWFireDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) and (not isAutoCommit) then
    TFDConnection(Connection).Commit;
end;

class procedure TRESTDWFireDACDriver.CreateConnection(
   const AConnectionDefs : TConnectionDefs; var AConnection : TComponent);

  procedure ServerParamValue(ParamName, Value : String);
  var
    I, vIndex : Integer;
  begin
   vIndex := -1;
   for I := 0 To TFDConnection(AConnection).Params.Count-1 do begin
     if SameText(TFDConnection(AConnection).Params.Names[I],ParamName) then begin
       vIndex := I;
       Break;
     end;
   end;
   if vIndex = -1 Then
     TFDConnection(AConnection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Value]))
   else
     TFDConnection(AConnection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Value]);
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
        ServerParamValue('DriverID',  'FB');
        ServerParamValue('Server',    AConnectionDefs.HostName);
        ServerParamValue('Port',      IntToStr(AConnectionDefs.dbPort));
        ServerParamValue('Database',  AConnectionDefs.DatabaseName);
        ServerParamValue('User_Name', AConnectionDefs.Username);
        ServerParamValue('Password',  AConnectionDefs.Password);
        ServerParamValue('CharacterSet',  AConnectionDefs.Charset);
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

{ TRESTDWFireDACQuery }

procedure TRESTDWFireDACQuery.createSequencedField(seqname, field : string);
var
  qry : TFDQuery;
  fd : TField;
begin
  qry := TFDQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWFireDACQuery.ExecSQL;
var
  qry : TFDQuery;
begin
  inherited ExecSQL;
  qry := TFDQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWFireDACQuery.FetchAll;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  qry.FetchAll;
end;

function TRESTDWFireDACQuery.getParamDataType(IParam: integer): TFieldType;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWFireDACQuery.getParamName(IParam: integer): string;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWFireDACQuery.getParamSize(IParam: integer): integer;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWFireDACQuery.getParamValue(IParam: integer): variant;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWFireDACQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

function TRESTDWFireDACQuery.ParamCount: Integer;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  Result := qry.ParamCount;
end;

procedure TRESTDWFireDACQuery.Prepare;
var
  qry : TFDQuery;
begin
  inherited Prepare;
  qry := TFDQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWFireDACQuery.RowsAffected: Int64;
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

procedure TRESTDWFireDACQuery.SaveToStream(stream: TStream);
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  qry.SaveToStream(stream, sfBinary);

  stream.Position := 0;
end;

procedure TRESTDWFireDACQuery.setParamDataType(IParam: integer;
                                               AValue: TFieldType);
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWFireDACQuery.setParamValue(IParam: integer;
                                            AValue: variant);
var
  qry : TFDQuery;
begin
  qry := TFDQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

{ TRESTDWFireDACTable }

procedure TRESTDWFireDACTable.FetchAll;
var
  qry : TFDTable;
begin
  qry := TFDTable(Self.Owner);
  qry.FetchAll;
end;

procedure TRESTDWFireDACTable.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TFDTable;
begin
  qry := TFDTable(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

procedure TRESTDWFireDACTable.SaveToStream(stream: TStream);
var
  qry : TFDTable;
begin
  qry := TFDTable(Self.Owner);
  qry.SaveToStream(stream, sfBinary);

  stream.Position := 0;
end;

end.

