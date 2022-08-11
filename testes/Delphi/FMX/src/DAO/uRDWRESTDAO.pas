unit uRDWRESTDAO;

interface

uses
  System.Classes,
  uRESTDWDataUtils, uRESTDWResponseTranslator, uRESTDWIdBase;

type
  TRequestMethod = (rmGET, rmPOST, rmPUT, rmPATCH, rmDELETE);

  TRDWRESTDAO = Class
  private
    FRESTClient: TRESTDWIdClientREST;
    FServer: String;
    FStream: TStringStream;
    FDefaultHeader: TStringList;
    FURL: string;
  public
    constructor Create(aServer, aPort: string; binary: boolean);
    destructor Destroy; override;
    procedure SetBasicAuth(user, password: string);
    function TesteEndpoint(aEndpoint: string; aMethod: TRequestMethod): boolean;
    function TesteConcorrente(aEndpoint: string; aMethod: TRequestMethod;
      cRepeat, cRequests: integer): boolean;
  End;

implementation

{ TRESTDAO }

constructor TRDWRESTDAO.Create(aServer, aPort: string; binary: boolean);
begin
  FServer := aServer + ':' + aPort;
  FRESTClient := TRESTDWIdClientREST.Create(nil);
  FRESTClient.UserAgent := 'RDWTestFMX Tool v1.0';
  FRESTClient.AuthenticationOptions.AuthorizationOption := rdwAONone;

  if binary then
  begin
    FDefaultHeader := TStringList.Create;
    FDefaultHeader.AddPair('BinaryRequest', 'true');
    FDefaultHeader.AddPair('DataCompression', 'true');
  end
  else
    FDefaultHeader := nil;
end;

destructor TRDWRESTDAO.Destroy;
begin
  FRESTClient.Free;

  inherited;
end;

procedure TRDWRESTDAO.SetBasicAuth(user, password: string);
begin
  FRESTClient.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
  TRESTDWAuthOptionBasic(FRESTClient.AuthenticationOptions.OptionParams)
    .Username := user;
  TRESTDWAuthOptionBasic(FRESTClient.AuthenticationOptions.OptionParams)
    .password := password;
end;

function TRDWRESTDAO.TesteConcorrente(aEndpoint: string;
  aMethod: TRequestMethod; cRepeat, cRequests: integer): boolean;
var
  I: integer;
  teste: boolean;
begin
  FURL := FServer + '/' + aEndpoint;
  for I := 0 to pred(cRepeat) do
    TThread.CreateAnonymousThread(
      procedure
      begin
        FStream := TStringStream.Create;
        try
          try
            case aMethod of
              rmGET:
                teste := FRESTClient.Get(FURL, FDefaultHeader, FStream) = 200;
              rmPOST:
                teste := FRESTClient.Post(FURL, FDefaultHeader, FStream) = 201;
              rmPUT:
                teste := FRESTClient.Put(FURL, FDefaultHeader, FStream,
                  false) = 201;
              rmPATCH:
                teste := FRESTClient.Patch(FURL, FDefaultHeader, FStream,
                  false) = 201;
              rmDELETE:
                teste := FRESTClient.Delete(FURL, FDefaultHeader,
                  FStream) = 200;
            end;
          finally
            FStream.Free;
          end;
        except
          teste := false;
        end;
      end).Start;
  Result := teste;
end;

function TRDWRESTDAO.TesteEndpoint(aEndpoint: string;
aMethod: TRequestMethod): boolean;
begin
  FURL := FServer + '/' + aEndpoint;
  FStream := TStringStream.Create;
  try
    case aMethod of
      rmGET:
        Result := FRESTClient.Get(FURL, FDefaultHeader, FStream) = 200;
      rmPOST:
        Result := FRESTClient.Post(FURL, FDefaultHeader, FStream) = 201;
      rmPUT:
        Result := FRESTClient.Put(FURL, FDefaultHeader, FStream, false) = 201;
      rmPATCH:
        Result := FRESTClient.Patch(FURL, FDefaultHeader, FStream, false) = 201;
      rmDELETE:
        Result := FRESTClient.Delete(FURL, FDefaultHeader, FStream) = 200;
    end;
    FStream.Free;
  except
    Result := false;
  end;
end;

end.
