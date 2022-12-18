unit Firedac.Phys.RDWDef;


interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Phys.Intf;

type
  TFDPhysRDWConnectionDefParams = class(TFDConnectionDefParams)
  private
    function GetDriverID: String;
    procedure SetDriverID(const AValue: String);
    function GetPoolerName: String;
    procedure SetPoolerName(const AValue: String);
    function GetDriverName: String;
    procedure SetDriverName(const AValue: String);
    function GetMetaDefCatalog: String;
    procedure SetMetaDefCatalog(const AValue: String);
    function GetMetaDefSchema: String;
    procedure SetMetaDefSchema(const AValue: String);
    function GetMetaCurCatalog: String;
    procedure SetMetaCurCatalog(const AValue: String);
    function GetMetaCurSchema: String;
    procedure SetMetaCurSchema(const AValue: String);
    function GetRDBMS: TFDRDBMSKind;
    procedure SetRDBMS(const AValue: TFDRDBMSKind);
    function GetPoolerPort: Integer;
    procedure SetPoolerPort(const Value: Integer);
    function GetPoolerService: string;
    procedure SetPoolerService(const Value: string);
  published
    property DriverID: String read GetDriverID write SetDriverID stored False;
    property PoolerName: String read GetPoolerName write SetPoolerName stored False;
    property PoolerService: string read GetPoolerService write SetPoolerService stored False;
    property PoolerPort: Integer read GetPoolerPort write SetPoolerPort stored False default 8082;
    property DriverName: String read GetDriverName write SetDriverName stored False;
    property MetaDefCatalog: String read GetMetaDefCatalog write SetMetaDefCatalog stored False;
    property MetaDefSchema: String read GetMetaDefSchema write SetMetaDefSchema stored False;
    property MetaCurCatalog: String read GetMetaCurCatalog write SetMetaCurCatalog stored False;
    property MetaCurSchema: String read GetMetaCurSchema write SetMetaCurSchema stored False;
    property RDBMS: TFDRDBMSKind read GetRDBMS write SetRDBMS stored False;
  end;

implementation

uses
  FireDAC.Stan.Consts, Firedac.Phys.RDWBase;

// Data.DBXCommon,
// TFDPhysTDBXConnectionDefParams
// Generated for: FireDAC TDBX driver

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetDriverID: String;
begin
  Result := FDef.AsString[S_FD_ConnParam_Common_DriverID];
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetDriverID(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_Common_DriverID] := AValue;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetPoolerName: String;
begin
  Result := FDef.AsString[S_FD_ConnParam_RDW_PoolerName];
end;

function TFDPhysRDWConnectionDefParams.GetPoolerPort: Integer;
begin
  Result:= FDef.AsInteger[S_FD_ConnParam_RDW_PoolerPort];
end;

function TFDPhysRDWConnectionDefParams.GetPoolerService: string;
begin
  Result := FDef.AsString[S_FD_ConnParam_RDW_PoolerService];
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetPoolerName(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_RDW_PoolerName] := AValue;
end;

procedure TFDPhysRDWConnectionDefParams.SetPoolerPort(const Value: Integer);
begin
  FDef.AsInteger[S_FD_ConnParam_RDW_PoolerPort] := Value;
end;

procedure TFDPhysRDWConnectionDefParams.SetPoolerService(const Value: string);
begin
   FDef.AsString[S_FD_ConnParam_RDW_PoolerService] := Value;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetDriverName: String;
begin
  Result := FDef.AsString[DriverName];
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetDriverName(const AValue: String);
begin
  FDef.AsString[DriverName] := AValue;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetMetaDefCatalog: String;
begin
  Result := FDef.AsString[S_FD_ConnParam_Common_MetaDefCatalog];
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetMetaDefCatalog(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_Common_MetaDefCatalog] := AValue;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetMetaDefSchema: String;
begin
  Result := FDef.AsString[S_FD_ConnParam_Common_MetaDefSchema];
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetMetaDefSchema(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_Common_MetaDefSchema] := AValue;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetMetaCurCatalog: String;
begin
  Result := FDef.AsString[S_FD_ConnParam_Common_MetaCurCatalog];
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetMetaCurCatalog(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_Common_MetaCurCatalog] := AValue;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetMetaCurSchema: String;
begin
  Result := FDef.AsString[S_FD_ConnParam_Common_MetaCurSchema];
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetMetaCurSchema(const AValue: String);
begin
  FDef.AsString[S_FD_ConnParam_Common_MetaCurSchema] := AValue;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWConnectionDefParams.GetRDBMS: TFDRDBMSKind;
var
  oManMeta: IFDPhysManagerMetadata;
begin
  FDPhysManager.CreateMetadata(oManMeta);
  Result := oManMeta.GetRDBMSKind(FDef.AsString[S_FD_ConnParam_Common_RDBMS]);
end;

{-------------------------------------------------------------------------------}
procedure TFDPhysRDWConnectionDefParams.SetRDBMS(const AValue: TFDRDBMSKind);
var
  oManMeta: IFDPhysManagerMetadata;
begin
  FDPhysManager.CreateMetadata(oManMeta);
  FDef.AsString[S_FD_ConnParam_Common_RDBMS] := oManMeta.GetRDBMSName(AValue);
end;

end.
