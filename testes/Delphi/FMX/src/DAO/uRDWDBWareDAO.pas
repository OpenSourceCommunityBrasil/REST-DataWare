unit uRDWDBWareDAO;

interface

uses
  System.SysUtils,
  uRESTDWIdBase, uRESTDWBasicDB, uRESTDWDataUtils, uRESTDWConsts;

type
  TRDWDBWareDAO = class
  private
    FRDWDB: TRESTDWIdDatabase;
    FRDWSQL: TRESTDWClientSQL;
  public
    constructor Create(aServer, aPort: string);
    destructor Destroy; override;
    procedure SetBasicAuth(user, password: string);
  end;

implementation

{ TRDWDBWareDAO }

constructor TRDWDBWareDAO.Create(aServer, aPort: string);
begin
  FRDWDB := TRESTDWIdDatabase.Create(nil);
  FRDWDB.AuthenticationOptions := TRESTDWClientAuthOptionParams(rdwAONone);
  // FRDWDB.PoolerURL := aServer;
  FRDWDB.PoolerPort := StrToInt(aPort);
  FRDWDB.PoolerName := FRDWDB.PoolerList[0];
  FRDWDB.Active := true;

  FRDWSQL := TRESTDWClientSQL.Create(nil);
  FRDWSQL.DataBase := FRDWDB;

end;

destructor TRDWDBWareDAO.Destroy;
begin
  FRDWDB.Free;
  FRDWSQL.Free;

  inherited;
end;

procedure TRDWDBWareDAO.SetBasicAuth(user, password: string);
begin
  FRDWDB.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
  TRESTDWAuthOptionBasic(FRDWDB.AuthenticationOptions.OptionParams)
    .Username := user;
  TRESTDWAuthOptionBasic(FRDWDB.AuthenticationOptions.OptionParams).password
    := password;
end;

end.
