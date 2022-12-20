unit FireDAC.Phys.RDW;

interface

uses
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.DatS,
  FireDAC.Phys,
  FireDAC.Phys.RDWBase;

type
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32 or pidiOSSimulator or
    pidiOSDevice32 or pidiOSDevice64 or pidAndroid)] 
  TFDPhysRDWDriverLink = class(TFDPhysRDWBaseDriverLink)

  end;

procedure register;

implementation

uses
  System.Variants, System.SysUtils, System.Generics.Collections, Data.DB,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.Stan.Option, FireDAC.Stan.Util,
  FireDAC.Stan.Consts, FireDAC.Stan.ResStrs, FireDAC.Phys.Intf,
  FireDAC.Phys.SQLGenerator, FireDAC.Phys.RDWDef;

type
  TFDPhysRDWDriver = class;

  TFDPhysRDWDriver = class(TFDPhysRDWDriverBase)
  protected
    function InternalCreateConnection(AConnHost: TFDPhysConnectionHost): TFDPhysConnection; override;
    class function GetBaseDriverID: String; override;
    class function GetBaseDriverDesc: String; override;
    class function GetRDBMSKind: TFDRDBMSKind; override;
    class function GetConnectionDefParamsClass: TFDConnectionDefParamsClass; override;
    function GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable; override;
  end;

procedure register;
begin
  RegisterComponents('REST Dataware - Physicals', [TFDPhysRDWDriverLink]);
end;

{-------------------------------------------------------------------------------}
{ TFDPhysRDWDriver                                                           }
{-------------------------------------------------------------------------------}

function TFDPhysRDWDriver.InternalCreateConnection(
  AConnHost: TFDPhysConnectionHost): TFDPhysConnection;
begin
  Result := TFDPhysRDWConnectionBase.Create(Self, AConnHost);
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetBaseDriverID: String;
begin
  Result := S_FD_RDWId;
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetBaseDriverDesc: String;
begin
  Result := 'Rest Dataware Data Source';
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetRDBMSKind: TFDRDBMSKind;
begin
  Result := TFDRDBMSKinds.Other;
end;

{-------------------------------------------------------------------------------}
class function TFDPhysRDWDriver.GetConnectionDefParamsClass: TFDConnectionDefParamsClass;
begin
  Result := TFDPhysRDWConnectionDefParams;
end;

{-------------------------------------------------------------------------------}
function TFDPhysRDWDriver.GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable;
begin
  Result := inherited GetConnParams(AKeys, AParams);
end;

{-------------------------------------------------------------------------------}
initialization
 {$if CompilerVersion > 31}
  FDRegisterDriverClass(TFDPhysRDWDriver);
 {$ELSE}
  FDPhysManager.RegisterDriverClass(TFDPhysRDWDriver);
 {$IFEND}

finalization
 {$if CompilerVersion > 31}
  FDUnregisterDriverClass(TFDPhysRDWDriver);
 {$IFEND}

end.
