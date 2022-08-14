unit uidefunctions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TIDEObject }

  TIDEObject = class
  private
    FIcon: TIcon;
    FName: string;
    FInstallPath: string;
    FRegKey: string;
    FVersion: string;
  public
    property Version: string read FVersion write FVersion;
    property InstallPath: string read FInstallPath write FInstallPath;
    property Name: string read FName write FName;
    property Icon: TIcon read FIcon write FIcon;
    property RegKey: string read FRegKey;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TIDEObject }

constructor TIDEObject.Create;
begin
  Icon := nil;
end;

destructor TIDEObject.Destroy;
begin
  Icon.Free;
  inherited Destroy;
end;

end.
