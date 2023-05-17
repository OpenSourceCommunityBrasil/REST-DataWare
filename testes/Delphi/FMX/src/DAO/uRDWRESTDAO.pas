unit uRDWRESTDAO;

interface

uses
  System.Classes, uConsts, System.SysUtils,
  uRESTDWDataUtils, uRESTDWResponseTranslator, uRESTDWIdBase, uRESTDWConsts;

type
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
    function TesteEndpoint(aEndpoint: string; aMethod: TTestRequestMethod;
      out erro: string): boolean;
    function TesteConcorrente(aEndpoint: string; aMethod: TTestRequestMethod;
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
  aMethod: TTestRequestMethod; cRepeat, cRequests: integer): boolean;
var
  I: integer;
  teste: boolean;
begin
  FURL := FServer + '/' + aEndpoint;
  for I := 0 to pred(cRepeat) do
    TThread.Queue(nil,
      procedure
      begin
        FStream := TStringStream.Create;
        try
          try
            case aMethod of
              rtmGET:
                teste := FRESTClient.Get(FURL, FDefaultHeader, FStream) = 200;
              rtmPOST:
                teste := FRESTClient.Post(FURL, FDefaultHeader, FStream) = 201;
              rtmPUT:
                teste := FRESTClient.Put(FURL, FDefaultHeader, FStream,
                  false) = 201;
              rtmPATCH:
                teste := FRESTClient.Patch(FURL, FDefaultHeader, FStream,
                  false) = 201;
              rtmDELETE:
                teste := FRESTClient.Delete(FURL, FDefaultHeader,
                  FStream) = 200;
            end;
          finally
            FStream.Free;
          end;
        except
          teste := false;
        end;
      end);
  Result := teste;
end;

function TRDWRESTDAO.TesteEndpoint(aEndpoint: string;
aMethod: TTestRequestMethod; out erro: string): boolean;
var
  currentmethod: string;
begin
  FURL := FServer + '/' + aEndpoint;
  FStream := TStringStream.Create;
  try
    case aMethod of
      rtmGET:
        begin
          currentmethod := 'GET';
          Result := FRESTClient.Get(FURL, FDefaultHeader, FStream) = 200;
        end;

      rtmPOST:
        begin
          currentmethod := 'POST';
          Result := FRESTClient.Post(FURL, FDefaultHeader, FStream) = 201;
        end;
      rtmPUT:
        begin
          currentmethod := 'PUT';
          Result := FRESTClient.Put(FURL, FDefaultHeader, FStream, false) = 201;
        end;
      rtmPATCH:
        begin
          currentmethod := 'PATCH';
          Result := FRESTClient.Patch(FURL, FDefaultHeader, FStream,
            false) = 201;
        end;
      rtmDELETE:
        begin
          currentmethod := 'DELETE';
          Result := FRESTClient.Delete(FURL, FDefaultHeader, FStream) = 200;
        end;
    end;
    FStream.Free;
  except
    Result := false;
    erro := Format('Método %s falhou', [currentmethod]);
  end;
end;

end.
