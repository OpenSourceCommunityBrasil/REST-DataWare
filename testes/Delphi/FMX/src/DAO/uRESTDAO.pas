unit uRESTDAO;

interface

uses
  System.JSON,
  REST.Client, REST.Types, REST.Authenticator.Basic

    ;

type
  TRESTDAO = Class
  private
    FRESTAPI: TRESTRequest;
    FClientAPI: TRESTClient;
    FBasicAuth: THTTPBasicAuthenticator;
    FServer: String;
  public
    constructor Create(aServer, aPort: string);
    destructor Destroy; override;
    procedure SetBasicAuth(user, password: string);
    function TesteEndpointGET(aEndpoint: string): boolean;
    function TesteEndpointPOST(aEndpoint: string): boolean;
    function TesteEndpointPUT(aEndpoint: string): boolean;
    function TesteEndpointPATCH(aEndpoint: string): boolean;
    function TesteEndpointDELETE(aEndpoint: string): boolean;
    function TesteAssyncEndpoint(aEndpoint: string; aMethod: TRESTRequestMethod;
      aCount: integer): boolean;
  End;

implementation

uses
  System.Classes;

{ TRESTDAO }

constructor TRESTDAO.Create(aServer, aPort: string);
begin
  FClientAPI := TRESTClient.Create(nil);
  FRESTAPI := TRESTRequest.Create(nil);
  try
    FServer := aServer + ':' + aPort;

    FClientAPI.BaseURL := FServer;
    FRESTAPI.Client := FClientAPI;

    FClientAPI.UserAgent := 'RDWTestFMX Tool v1.0';
  except
  end;
end;

destructor TRESTDAO.Destroy;
begin
  FRESTAPI.Response := nil;

  if FBasicAuth <> nil then
    FBasicAuth.Free;
  FClientAPI.Free;
  FRESTAPI.Free;

  inherited;
end;

procedure TRESTDAO.SetBasicAuth(user, password: string);
begin
  if FBasicAuth = nil then
    FBasicAuth := THTTPBasicAuthenticator.Create(nil);
  FBasicAuth.Username := user;
  FBasicAuth.password := password;
  FClientAPI.Authenticator := FBasicAuth;
end;

function TRESTDAO.TesteAssyncEndpoint(aEndpoint: string;
  aMethod: TRESTRequestMethod; aCount: integer): boolean;
var
  Response: boolean;
  fail, I: integer;
  threads: Array of TThread;
begin
  fail := 0;
  SetLength(threads, aCount);
  for I := 0 to aCount do
    TThread(threads[I]).CreateAnonymousThread(
      procedure
      begin
        Response := false;
        FRESTAPI.Response := nil;
        FRESTAPI.Resource := aEndpoint;
        FRESTAPI.Method := aMethod;
        try
          FRESTAPI.Execute;
          case aMethod of
            rmGET, rmDELETE:
              begin
                if FRESTAPI.Response.StatusCode <> 200 then
                  inc(fail);
              end;
            rmPOST, rmPUT, rmPATCH:
              begin
                if FRESTAPI.Response.StatusCode <> 201 then
                  inc(fail);
              end;
          end;
        except
          Response := false;
        end;
      end).Start;

  Result := fail = 0;
end;

function TRESTDAO.TesteEndpointDELETE(aEndpoint: string): boolean;
begin
  Result := false;
  FRESTAPI.Response := nil;
  FRESTAPI.Resource := aEndpoint;
  FRESTAPI.Method := rmDELETE;
  try
    FRESTAPI.Execute;
    Result := FRESTAPI.Response.StatusCode = 200;
  except
    Result := false;
  end;
end;

function TRESTDAO.TesteEndpointGET(aEndpoint: string): boolean;
begin
  Result := false;
  FRESTAPI.Response := nil;
  FRESTAPI.Resource := aEndpoint;
  FRESTAPI.Method := rmGET;
  try
    FRESTAPI.Execute;
    Result := FRESTAPI.Response.StatusCode = 200;
  except
    Result := false;
  end;
end;

function TRESTDAO.TesteEndpointPATCH(aEndpoint: string): boolean;
begin
  Result := false;
  FRESTAPI.Response := nil;
  FRESTAPI.Resource := aEndpoint;
  FRESTAPI.Method := rmPATCH;
  try
    FRESTAPI.Execute;
    Result := FRESTAPI.Response.StatusCode = 201;
  except
    Result := false;
  end;
end;

function TRESTDAO.TesteEndpointPOST(aEndpoint: string): boolean;
begin
  Result := false;
  FRESTAPI.Response := nil;
  FRESTAPI.Resource := aEndpoint;
  FRESTAPI.Method := rmPOST;
  try
    FRESTAPI.Execute;
    Result := FRESTAPI.Response.StatusCode = 201;
  except
    Result := false;
  end;
end;

function TRESTDAO.TesteEndpointPUT(aEndpoint: string): boolean;
begin
  Result := false;
  FRESTAPI.Response := nil;
  FRESTAPI.Resource := aEndpoint;
  FRESTAPI.Method := rmPUT;
  try
    FRESTAPI.Execute;
    Result := FRESTAPI.Response.StatusCode = 201;
  except
    Result := false;
  end;
end;

end.
