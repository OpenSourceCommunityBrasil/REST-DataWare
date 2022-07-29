unit uRDWBinaryEventsDAO;

interface

uses
  System.SysUtils,
  uRESTDWIdBase, uRESTDWBasicDB, uRESTDWDataUtils, uRESTDWServerEvents;

type
  TRDWBinaryEventsDAO = class
  private
    FRDWClientPooler: TRESTDWIdClientPooler;
    FRDWClientEvents: TRESTDWClientEvents;
  public
    constructor Create(aServer, aPort: string);
    destructor Destroy; override;
    procedure SetBasicAuth(user, password: string);
  end;

implementation

{ TRDWBinaryEventsDAO }

constructor TRDWBinaryEventsDAO.Create(aServer, aPort: string);
begin
  FRDWClientPooler := TRESTDWIdClientPooler.Create(nil);
  FRDWClientPooler.AuthenticationOptions := TRESTDWClientAuthOptionParams
    (rdwAONone);
  FRDWClientPooler.Host := aServer;
  FRDWClientPooler.Port := StrToInt(aPort);
  FRDWClientPooler.BinaryRequest := true;
  FRDWClientPooler.DataCompression := true;
  FRDWClientPooler.UserAgent := 'RDWTestFMX Tool v1.0';

  FRDWClientEvents := TRESTDWClientEvents.Create(nil);
  FRDWClientEvents.RESTClientPooler := FRDWClientPooler;
  FRDWClientEvents.ServerEventName := FRDWClientPooler.FailOverConnections.Items
    [0].GetPoolerList[0];
  FRDWClientEvents.ClearEvents;
  FRDWClientEvents.GetEvents := true;

  // FRDWClientPooler.PoolerName := FRDWDB.PoolerList[0];
end;

destructor TRDWBinaryEventsDAO.Destroy;
begin
  FRDWClientPooler.Free;
  FRDWClientEvents.Free;

  inherited;
end;

procedure TRDWBinaryEventsDAO.SetBasicAuth(user, password: string);
begin
  FRDWClientPooler.AuthenticationOptions.AuthorizationOption := rdwAOBasic;
  TRESTDWAuthOptionBasic(FRDWClientPooler.AuthenticationOptions.OptionParams)
    .Username := user;
  TRESTDWAuthOptionBasic(FRDWClientPooler.AuthenticationOptions.OptionParams)
    .password := password;

end;

end.
