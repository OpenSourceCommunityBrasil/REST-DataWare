unit uRESTDWInterbaseDriver;

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
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes, uRESTDWMemtable,
  DB,
  {$IFNDEF DELPHIXEUP}
    IBDatabase, IBQuery, IBCustomDataSet, IBTable, IBStoredProc
  {$ELSE}
    IBX.IBDatabase, IBX.IBQuery, IBX.IBCustomDataSet, IBX.IBTable,
    IBX.IBStoredProc, IBX.IBInputOutput
  {$IFEND};


type
  TRESTDWInterbaseStoreProc = class(TRESTDWDrvStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  TRESTDWInterbaseTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream : TStream); override;
    procedure FetchAll; override;
  end;

  { TRESTDWInterbaseQuery }

  TRESTDWInterbaseQuery = class(TRESTDWDrvQuery)
  protected
    procedure createSequencedField(seqname,field : string); override;
  public
    procedure SaveToStream(stream : TStream); override;
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
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
  end;

  { TRESTDWInterbaseDriver }

  TRESTDWInterbaseDriver = class(TRESTDWDriverBase)
  private
    FTransaction : TIBTransaction;
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

    class procedure CreateConnection(const AConnectionDefs  : TConnectionDefs;
                                     var AConnection        : TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWInterbaseDriver]);
end;

{ TRESTDWInterbaseQuery }

procedure TRESTDWInterbaseQuery.createSequencedField(seqname, field : string);
var
  qry : TIBQuery;
begin
  if Trim(seqname) = '' then
    Exit;

  qry := TIBQuery(Self.Owner);
  qry.GeneratorField.Generator := seqname;
  qry.GeneratorField.Field := field;
end;

procedure TRESTDWInterbaseQuery.ExecSQL;
var
  qry : TIBQuery;
begin
  inherited ExecSQL;
  qry := TIBQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWInterbaseQuery.FetchAll;
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  qry.FetchAll;
end;

function TRESTDWInterbaseQuery.getParamDataType(IParam: integer): TFieldType;
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWInterbaseQuery.getParamName(IParam: integer): string;
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWInterbaseQuery.getParamSize(IParam: integer): integer;
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWInterbaseQuery.getParamValue(IParam: integer): variant;
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWInterbaseQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

function TRESTDWInterbaseQuery.ParamCount: Integer;
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  Result := qry.ParamCount;
end;

procedure TRESTDWInterbaseQuery.Prepare;
var
  qry : TIBQuery;
begin
  inherited Prepare;
  qry := TIBQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWInterbaseQuery.RowsAffected: Int64;
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

procedure TRESTDWInterbaseQuery.SaveToStream(stream: TStream);
var
  qry : TIBQuery;
  memtable : TRESTDWMemtable;
begin
  qry := TIBQuery(Self.Owner);
  memtable := TRESTDWMemtable.Create(nil);
  try
    memtable.Assign(qry);
    memtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(memtable);
  end;
end;

procedure TRESTDWInterbaseQuery.setParamDataType(IParam: integer;
                                                 AValue: TFieldType);
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWInterbaseQuery.setParamValue(IParam: integer; AValue: variant);
var
  qry : TIBQuery;
begin
  qry := TIBQuery(Self.Owner);
  qry.Params[IParam].Value := AValue;
end;

{ TRESTDWInterbaseDriver }

procedure TRESTDWInterbaseDriver.setConnection(AValue: TComponent);
begin
  if FTransaction <> nil then
    FTransaction.DefaultDatabase := TIBDatabase(AValue);

  TIBDatabase(AValue).DefaultTransaction := FTransaction;
  inherited setConnection(AValue);
end;

function TRESTDWInterbaseDriver.getConectionType: TRESTDWDatabaseType;
begin
  Result := dbtInterbase;
end;

function TRESTDWInterbaseDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TIBQuery;
begin
  qry := TIBQuery.Create(Self);
  qry.Database := TIBDatabase(Connection);
  qry.Transaction := FTransaction;

  Result := TRESTDWInterbaseQuery.Create(qry);
end;

function TRESTDWInterbaseDriver.getStoreProc: TRESTDWDrvStoreProc;
var
  qry : TIBStoredProc;
begin
  qry := TIBStoredProc.Create(Self);
  qry.Database := TIBDatabase(Connection);
  qry.Transaction := FTransaction;

  Result := TRESTDWInterbaseStoreProc.Create(qry);
end;

function TRESTDWInterbaseDriver.getTable: TRESTDWDrvTable;
var
  qry : TIBTable;
begin
  qry := TIBTable.Create(Self);
  qry.Database := TIBDatabase(Connection);
  qry.Transaction := FTransaction;

  Result := TRESTDWInterbaseTable.Create(qry);
end;

procedure TRESTDWInterbaseDriver.Connect;
begin
  if Assigned(Connection) then
    TIBDatabase(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWInterbaseDriver.Disconect;
begin
  if Assigned(Connection) then
    TIBDatabase(Connection).Close;
  inherited Disconect;
end;

 constructor TRESTDWInterbaseDriver.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TIBTransaction.Create(Self);
  FTransaction.DefaultDatabase := TIBDatabase(Connection);
end;

destructor TRESTDWInterbaseDriver.Destroy;
begin
  FTransaction.Free;
  inherited Destroy;
end;

function TRESTDWInterbaseDriver.isConnected: boolean;
begin
  Result := inherited isConnected;
  if Assigned(Connection) then
    Result := TIBDatabase(Connection).Connected;
end;

function TRESTDWInterbaseDriver.connInTransaction: boolean;
begin
  Result := FTransaction.Active;
end;

procedure TRESTDWInterbaseDriver.connStartTransaction;
begin
  FTransaction.StartTransaction;
end;

procedure TRESTDWInterbaseDriver.connRollback;
begin
  FTransaction.Rollback;
end;

function TRESTDWInterbaseDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TIBDatabase);
end;

procedure TRESTDWInterbaseDriver.connCommit;
begin
  FTransaction.Commit;
end;

class procedure TRESTDWInterbaseDriver.CreateConnection(const AConnectionDefs: TConnectionDefs;
                                                        var AConnection: TComponent);
var
  sDatabase : string;

  procedure ServerParamValue(ParamName, Value : String);
  var
    I, vIndex : Integer;
  begin
   vIndex := -1;
   for I := 0 To TIBDatabase(AConnection).Params.Count-1 do begin
     if SameText(TIBDatabase(AConnection).Params.Names[I],ParamName) then begin
       vIndex := I;
       Break;
     end;
   end;
   if vIndex = -1 Then
     TIBDatabase(AConnection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Value]))
   else
     TIBDatabase(AConnection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Value]);
  end;

begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) and Assigned(AConnection) then begin
    sDatabase := '';
    if (AConnectionDefs.HostName <> 'localhost') or
       (AConnectionDefs.DBPort <> 3050) then
      sDatabase := sDatabase + AConnectionDefs.HostName;
    if AConnectionDefs.DBPort <> 3050 then
      sDatabase := sDatabase + '/' + IntToStr(AConnectionDefs.DBPort);

    if sDatabase <> '' then
      sDatabase := sDatabase + ':';
    sDatabase := sDatabase + AConnectionDefs.DatabaseName;

    with AConnection as TIBDatabase do begin
      DatabaseName := sDatabase;
      ServerParamValue('User_Name', AConnectionDefs.Username);
      ServerParamValue('Password',  AConnectionDefs.Password);
    end;
  end;
end;

{ TRESTDWInterbaseStoreProc }

procedure TRESTDWInterbaseStoreProc.ExecProc;
var
  qry : TIBStoredProc;
begin
  inherited ExecProc;
  qry := TIBStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWInterbaseStoreProc.Prepare;
var
  qry : TIBStoredProc;
begin
  inherited Prepare;
  qry := TIBStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWInterbaseTable }

procedure TRESTDWInterbaseTable.FetchAll;
var
  qry : TIBTable;
begin
  qry := TIBTable(Self.Owner);
  qry.FetchAll;
end;

procedure TRESTDWInterbaseTable.SaveToStream(stream: TStream);
var
  qry : TIBTable;
  memtable : TRESTDWMemtable;
begin
  qry := TIBTable(Self.Owner);
  memtable := TRESTDWMemtable.Create(nil);
  try
    memtable.Assign(qry);
    memtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(memtable);
  end;
end;

end.

