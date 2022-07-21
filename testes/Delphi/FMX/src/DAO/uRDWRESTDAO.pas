unit uRDWRESTDAO;

interface

uses
  System.Classes,
  ServerUtils, uDWResponseTranslator;

type
  TRDWRESTDAO = Class
  private
    FRESTClient: TDWClientREST;
    FServer: String;
    FStream: TStringStream;
  public
    constructor Create(aServer, aPort: string);
    destructor Destroy; override;
    procedure SetBasicAuth(user, password: string);
    function TesteEndpointGET(aEndpoint: string): boolean;
    function TesteEndpointPOST(aEndpoint: string): boolean;
    function TesteEndpointPUT(aEndpoint: string): boolean;
    function TesteEndpointPATCH(aEndpoint: string): boolean;
    function TesteEndpointDELETE(aEndpoint: string): boolean;
  End;

implementation

{ TRESTDAO }

constructor TRDWRESTDAO.Create(aServer, aPort: string);
begin
  FServer := aServer + ':' + aPort;
  FRESTClient := TDWClientREST.Create(nil);
  FRESTClient.UserAgent := 'RDWTestFMX Tool v1.0';
  FRESTClient.AuthenticationOptions.AuthorizationOption := rdwAONone;
end;

destructor TRDWRESTDAO.Destroy;
begin
  FRESTClient.Free;

  inherited;
end;

procedure TRDWRESTDAO.SetBasicAuth(user, password: string);
begin
  FRESTClient.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
  TRDWAuthOptionBasic(FRESTClient.AuthenticationOptions.OptionParams)
    .Username := user;
  TRDWAuthOptionBasic(FRESTClient.AuthenticationOptions.OptionParams).password
    := password;
end;

function TRDWRESTDAO.TesteEndpointDELETE(aEndpoint: string): boolean;
var
  URL: String;
begin
  URL := FServer + '\' + aEndpoint;
  FStream := TStringStream.Create;
  try
    Result := FRESTClient.Delete(URL, nil, FStream) = 200;
    FStream.Free;
  except
    Result := false;
  end;
end;

function TRDWRESTDAO.TesteEndpointGET(aEndpoint: string): boolean;
var
  URL: String;
begin
  URL := FServer + '\' + aEndpoint;
  FStream := TStringStream.Create;
  try
    Result := FRESTClient.Get(URL, nil, FStream) = 200;
    FStream.Free;
  except
    Result := false;
  end;
end;

function TRDWRESTDAO.TesteEndpointPATCH(aEndpoint: string): boolean;
var
  URL: String;
begin
  URL := FServer + '\' + aEndpoint;
  FStream := TStringStream.Create;
  try
    Result := FRESTClient.Patch(URL, nil, nil, FStream) = 201;
    FStream.Free;
  except
    Result := false;
  end;
end;

function TRDWRESTDAO.TesteEndpointPOST(aEndpoint: string): boolean;
var
  URL: String;
begin
  URL := FServer + '\' + aEndpoint;
  FStream := TStringStream.Create;
  try
    Result := FRESTClient.Post(URL, nil, nil, FStream) = 201;
    FStream.Free;
  except
    Result := false;
  end;
end;

function TRDWRESTDAO.TesteEndpointPUT(aEndpoint: string): boolean;
var
  URL: String;
begin
  URL := FServer + '\' + aEndpoint;
  FStream := TStringStream.Create;
  try
    Result := FRESTClient.Put(URL, nil, nil, FStream) = 201;
    FStream.Free;
  except
    Result := false;
  end;
end;

end.
