unit uRESTDWApolloDBDriver;

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
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes, uRESTDWConsts,
  apWin, ApConn, apoQSet, apCommon, DB, ApoDSet, TypInfo, apGlobal,
  apoEnv, uRESTDWMemTable;

type
  TRESTDWApolloDBTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream : TStream); override;
  end;
  { TRESTDWApolloDBQuery }

  TRESTDWApolloDBQuery = class(TRESTDWDrvQuery)
  public
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
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
  end;

  { TRESTDWApolloDBDriver }

  TRESTDWApolloDBDriver = class(TRESTDWDriverBase)
  private
    FTableType : TApolloTableType;
    FPassword : string;
  protected
    Function compConnIsValid(comp : TComponent) : boolean; override;
  public
    function getQuery : TRESTDWDrvQuery; override;
    function getTable : TRESTDWDrvTable; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;

    Procedure GetTableNames     (Var TableNames        : TStringList;
                                 Var Error             : Boolean;
                                 Var MessageError      : String); override;
    
    Procedure GetFieldNames     (TableName             : String;
                                 Var FieldNames        : TStringList;
                                 Var Error             : Boolean;
                                 Var MessageError      : String); override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  published
    property TableType    : TApolloTableType  read FTableType     Write FTableType;  
    property Password     : String            read FPassword      Write FPassword;
  end;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWApolloDBDriver]);
end;

 { TRESTDWApolloDBDriver }

function TRESTDWApolloDBDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery.Create(Self);
  if Connection is TApolloConnection then begin 
    qry.AccessMethod := amServer;
    qry.DatabaseName := '';
    if Self.ServerMethod <> nil then     
      qry.DataBaseName := Self.ServerMethod.ClientWelcomeMessage;
    qry.ApolloConnection := TApolloConnection(Connection);
    qry.ApolloConnection.DataBaseName := qry.DataBaseName;
  end
  else if Connection is TApolloDatabase then begin  
    qry.AccessMethod := amLocal;
    qry.ApolloConnection := nil;
    qry.DatabaseName := TApolloDatabase(Connection).DataPathAlias;
  end;
  qry.TableType := FTableType;
  qry.Password := FPassword;

  Result := TRESTDWApolloDBQuery.Create(qry);
end;

function TRESTDWApolloDBDriver.getTable : TRESTDWDrvTable;
var
  qry : TApolloTable;
begin
  qry := TApolloTable.Create(Self);
  if Connection is TApolloConnection then begin
    qry.AccessMethod := amServer;
    qry.DatabaseName := '';
    if Self.ServerMethod <> nil then
      qry.DatabaseName := Self.ServerMethod.ClientWelcomeMessage;
    qry.ApolloConnection := TApolloConnection(Connection);
  end
  else if Connection is TApolloDatabase then begin
    qry.AccessMethod := amLocal;
    qry.ApolloConnection := nil;
    qry.DatabaseName := TApolloDatabase(Connection).DataPathAlias;
  end;
  qry.TableType := FTableType;
  qry.Password := FPassword;
  qry.FetchCount := -1; // fetchall

  Result := TRESTDWApolloDBTable.Create(qry);
end;

procedure TRESTDWApolloDBDriver.GetTableNames(var TableNames: TStringList;
  var Error: Boolean; var MessageError: String);
var
  dbs, tbs, tabs : TStringList;
  p : integer;
  s : string;
begin   
  tabs := TStringList.Create;     
  if Connection is TApolloConnection then begin  
    dbs := TApolloConnection(Connection).GetDatabaseNamesList;
    while dbs.Count > 0 do begin
      tbs := TApolloConnection(Connection).GetTableNamesList(dbs.Strings[0]); 
      while tbs.Count > 0 do begin      
        s := AnsiUpperCase(tbs.Strings[0]);
        p := LastDelimiter('.',s);
        if p > 0 then    
          s := Copy(s,1,p-1); 

        tabs.Add(dbs.Strings[0]+'.'+s);
        tbs.Delete(0);      
      end;
      dbs.Delete(0);
    end;
    FreeAndNil(dbs);
    FreeAndNil(tbs);    
  end
  else if Connection is TApolloDatabase then begin
    tbs := TStringList.Create;     
    TApolloDatabase(Connection).EnumTableNames(tbs);
    while tbs.Count > 0 do begin
      s := AnsiUpperCase(tbs.Strings[0]);
      p := LastDelimiter('.',s);
      if p > 0 then    
        s := Copy(s,1,p-1); 
      tabs.Add(s);
      tbs.Delete(0);
    end;
    FreeAndNil(tbs);
  end;

  if Not Assigned(TableNames) then
    TableNames := TStringList.Create;

  while tabs.Count > 0 do begin
    TableNames.Add(tabs.Strings[0]);
    tabs.Delete(0);   
  end;             
  
  FreeAndNil(tabs);
end;

function TRESTDWApolloDBDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TApolloConnection) or
            comp.InheritsFrom(TApolloDatabase);
end;

procedure TRESTDWApolloDBDriver.Connect;
begin
  if Assigned(Connection) and (Connection is TApolloConnection) then
    TApolloConnection(Connection).Connect;
  inherited Connect;
end;

procedure TRESTDWApolloDBDriver.Disconect;
begin
  if Assigned(Connection) and (Connection is TApolloConnection) then
    TApolloConnection(Connection).Disconnect;
  inherited Disconect;
end;

procedure TRESTDWApolloDBDriver.GetFieldNames(TableName: String;
  var FieldNames: TStringList; var Error: Boolean; var MessageError: String);
var
  qry : TApolloTable;
  i : integer;
  vSchema, vTable : string;
  vStateResource : boolean;
begin
  if not Assigned(FieldNames) then
    FieldNames := TStringList.Create;
   
  vSchema := '';
  vTable := TableName;
  if Pos('.', vTable) > 0 then begin
    vSchema := Copy(vTable, InitStrPos, Pos('.', vTable)-1);
    Delete(vTable, InitStrPos, Pos('.', vTable));
  end;
  vTable := vTable + '.DBF';
  
  qry := TApolloTable.Create(Self);
  qry.Close;
  try
    if Connection is TApolloConnection then begin  
      if not SameText(vSchema,TApolloConnection(Connection).DataBaseName) then
        Disconect;
        
      TApolloConnection(Connection).DataBaseName := '';

      vStateResource := isConnected;
      if not vStateResource Then
        Connect;       

      TApolloConnection(Connection).GetDataBaseNames;
      TApolloConnection(Connection).DataBaseName := vSchema;
      
      i := TApolloConnection(Connection).ap_GetTableType(vSchema,vTable);
      
      qry.AccessMethod := amServer;
      qry.ApolloConnection := TApolloConnection(Connection);
      qry.DatabaseName := TApolloConnection(Connection).DataBaseName;      
      qry.TableType := TApolloTableType(i);
    end
    else if Connection is TApolloDatabase then begin  
      qry.AccessMethod := amLocal;
      qry.ApolloConnection := nil;
      qry.DatabaseName := TApolloDatabase(Connection).DataPathAlias;     
      qry.TableType := FTableType;
    end;
    qry.Password := FPassword;
    qry.TableName := vTable;

    try
      qry.Open;
    except
      i := 0;      
      while i < 5 do begin
        try
          qry.TableType := TApolloTableType(i);
          qry.Open;
          Break;
        except

        end;
        i := i + 1;
      end;    
    end;

    i := 0;
    while i < qry.Fields.Count do begin
      FieldNames.Add(AnsiUpperCase(qry.Fields[i].DisplayName));
      i := i + 1;  
    end;
  finally
    qry.Free;
  end;

  if not vStateResource then
    Disconect;  
end;

function TRESTDWApolloDBDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then begin
    if (Connection is TApolloConnection) then
      Result := TApolloConnection(Connection).Connected
    else if (Connection is TApolloDatabase) then
      Result := TApolloDatabase(Connection).DataPathAlias <> '';       
  end;
end;

class procedure TRESTDWApolloDBDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                     var AConnection : TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
 
end;

{ TRESTDWApolloDBQuery }

procedure TRESTDWApolloDBQuery.ExecSQL;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWApolloDBQuery.FetchAll;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  qry.FetchAll;
end;

function TRESTDWApolloDBQuery.getParamDataType(IParam: integer): TFieldType;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.Params[IParam].DataType;
end;

function TRESTDWApolloDBQuery.getParamName(IParam: integer): string;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.Params[IParam].Name;
end;

function TRESTDWApolloDBQuery.getParamSize(IParam: integer): integer;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.Params[IParam].Size;
end;

function TRESTDWApolloDBQuery.getParamValue(IParam: integer): variant;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.Params[IParam].Value;
end;

procedure TRESTDWApolloDBQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  qry.Params[IParam].LoadFromStream(stream,blobtype);
end;

function TRESTDWApolloDBQuery.ParamCount: Integer;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.ParamCount;
end;

procedure TRESTDWApolloDBQuery.Prepare;
var
  qry : TApolloQuery;
begin
  inherited Prepare;
  qry := TApolloQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWApolloDBQuery.RowsAffected : Int64;
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.RecordCount;
end;

procedure TRESTDWApolloDBQuery.SaveToStream(stream: TStream);
var
  qry : TApolloQuery;
  vDWMemtable : TRESTDWMemtable;
begin
  qry := TApolloQuery(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
  finally
    vDWMemtable.Free;
  end;
end;

procedure TRESTDWApolloDBQuery.setParamDataType(IParam: integer;
                                                AValue: TFieldType);
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.Params[IParam].DataType := AValue;
end;

procedure TRESTDWApolloDBQuery.setParamValue(IParam: integer;
                                             AValue: variant);
var
  qry : TApolloQuery;
begin
  qry := TApolloQuery(Self.Owner);
  Result := qry.Params[IParam].Value := AValue;
end;

{ TRESTDWApolloDBTable }

procedure TRESTDWApolloDBTable.SaveToStream(stream: TStream);
var
  qry : TApolloTable;
  vDWMemtable : TRESTDWMemtable;
begin
  qry := TApolloTable(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
  finally
    vDWMemtable.Free;
  end;
end;

end.

