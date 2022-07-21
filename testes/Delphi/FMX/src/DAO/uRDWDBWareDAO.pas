unit uRDWDBWareDAO;

interface

uses
  System.SysUtils,
  uRESTDWPoolerDB, ServerUtils;

type
  TRDWDBWareDAO = class
  private
    FRDWDB: TRESTDWDataBase;
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
  FRDWDB := TRESTDWDataBase.Create(nil);
  FRDWDB.AuthenticationOptions := TRDWClientAuthOptionParams(rdwAONone);
  FRDWDB.PoolerURL := aServer;
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
  TRDWAuthOptionBasic(FRDWDB.AuthenticationOptions.OptionParams)
    .Username := user;
  TRDWAuthOptionBasic(FRDWDB.AuthenticationOptions.OptionParams).password
    := password;
end;

end.
