unit FireDAC.Phys.RDWDef;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Phys.Intf;

type
  TFDPhysRDWConnectionDefParams = class(TFDConnectionDefParams)
  private
    function GetDriverID: String;
    procedure SetDriverID(const AValue: String);
    function GetDriverName: String;
    procedure SetDriverName(const AValue: String);
    function GetRDBMS: TFDRDBMSKind;
    procedure SetRDBMS(const AValue: TFDRDBMSKind);
  published
    property DriverID: String read GetDriverID write SetDriverID stored False;
    property DriverName: String read GetDriverName write SetDriverName stored False;
    property RDBMS: TFDRDBMSKind read GetRDBMS write SetRDBMS stored False;
  end;

const
  S_FD_ConnParam_Common_RDBMS = 'RDBMS';

implementation

uses
  FireDAC.Stan.Consts;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetDriverID: String;
begin
  Result := FDef.AsString[S_FD_ConnParam_Common_DriverID];
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetDriverName: String;
begin
  Result := FDef.AsString[DriverName];
end;

function TFDPhysRDWConnectionDefParams.GetRDBMS: TFDRDBMSKind;
var
  oManMeta: IFDPhysManagerMetadata;
begin
  FDPhysManager.CreateMetadata(oManMeta);
  Result := oManMeta.GetRDBMSKind(FDef.AsString[S_FD_ConnParam_Common_RDBMS]);
end;

procedure TFDPhysRDWConnectionDefParams.SetDriverID(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_Common_DriverID] := AValue;
end;

procedure TFDPhysRDWConnectionDefParams.SetDriverName(const AValue: String);
begin
  FDef.AsString[DriverName] := AValue;
end;

procedure TFDPhysRDWConnectionDefParams.SetRDBMS(const AValue: TFDRDBMSKind);
var
  oManMeta: IFDPhysManagerMetadata;
begin
  FDPhysManager.CreateMetadata(oManMeta);
  FDef.AsString[S_FD_ConnParam_Common_RDBMS] := oManMeta.GetRDBMSName(AValue);
end;

end.
