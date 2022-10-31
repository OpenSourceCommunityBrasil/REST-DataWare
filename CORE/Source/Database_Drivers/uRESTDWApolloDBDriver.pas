unit uRESTDWApolloDBDriver;

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
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes,
  apWin, ApConn, apoQSet, apCommon;

type
  TRESTDWApolloDBTable = class(TRESTDWDrvTable)
  public
    procedure SaveToStream(stream : TStream); override;
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
  end;
  { TRESTDWApolloDBQuery }

  TRESTDWApolloDBQuery = class(TRESTDWDrvQuery)
  public
    procedure LoadFromStreamParam(IParam : integer; stream : TStream; blobtype : TBlobType); override;
    procedure SaveToStream(stream : TStream); override;
    procedure ExecSQL; override;
    procedure Prepare; override;

    function RowsAffected : Int64; override;
  end;

  { TRESTDWApolloDBDriver }

  TRESTDWApolloDBDriver = class(TRESTDWDriverBase)
  private
    FDatabaseName : string;
    FPassword : string;
    FTableType : TApolloTableType;
  protected
    Function compConnIsValid(comp : TComponent) : boolean; override;
  public
    function getQuery : TRESTDWDrvQuery; override;
    function getTable : TRESTDWDrvTable; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  published
    property DatabaseName : String            read FDatabaseName  Write FDatabaseName;
    property Password     : String            read FPassword      Write FPassword;
    property TableType    : TApolloTableType  read FTableType     Write FTableType;
  end;


procedure Register;

implementation

{$IFNDEF FPC}
 {$if CompilerVersion < 23}
  {$R .\RESTDWApolloDBDriver.dcr}
 {$IFEND}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWApolloDBDriver]);
end;

 { TRESTDWApolloDBDriver }

function TRESTDWApolloDBDriver.getQuery : TRESTDWDrvQuery;
var
  qry : TMyQuery;
begin
  qry := TMyQuery.Create(Self);
//  qry.Connection := TApolloConnection(Connection);
  qry.DatabaseName := FDatabaseName;
  qry.TableType    := FTableType;
  qry.Password     := FPassword;

  Result := TRESTDWApolloDBQuery.Create(qry);
end;

function TRESTDWApolloDBDriver.getTable : TRESTDWDrvTable;
var
  qry : TApolloTable;
begin
  qry := TApolloTable.Create(Self);
//  qry.Connection := TApolloConnection(Connection);
  qry.DatabaseName := FDatabaseName;
  qry.TableType    := FTableType;
  qry.Password     := FPassword;

  Result := TRESTDWApolloDBTable.Create(qry);
end;

function TRESTDWApolloDBDriver.compConnIsValid(comp: TComponent): boolean;
begin
  Result := comp.InheritsFrom(TApolloConnection);
end;

procedure TRESTDWApolloDBDriver.Connect;
begin
  if Assigned(Connection) then
    TApolloConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWApolloDBDriver.Disconect;
begin
  if Assigned(Connection) then
    TMyConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWApolloDBDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TApolloConnection(Connection).Connected;
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
  inherited ExecSQL;
  qry := TApolloQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWApolloDBQuery.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
begin
  inherited;

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
  Result := -1; //qry.RowsAffected;
end;

procedure TRESTDWApolloDBQuery.SaveToStream(stream: TStream);
begin
  inherited;

end;

{ TRESTDWApolloDBTable }

procedure TRESTDWApolloDBTable.LoadFromStreamParam(IParam: integer;
  stream: TStream; blobtype: TBlobType);
begin
  inherited;

end;

procedure TRESTDWApolloDBTable.SaveToStream(stream: TStream);
begin
  inherited;

end;

end.

