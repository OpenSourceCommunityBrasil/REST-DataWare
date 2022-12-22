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
  published
    property DriverID: String read GetDriverID write SetDriverID stored False;
    property DriverName: String read GetDriverName write SetDriverName stored False;
  end;

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

procedure TFDPhysRDWConnectionDefParams.SetDriverID(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_Common_DriverID] := AValue;
end;

procedure TFDPhysRDWConnectionDefParams.SetDriverName(const AValue: String);
begin
  FDef.AsString[DriverName] := AValue;
end;

end.
