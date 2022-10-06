unit uidefunctions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  uconsts;

type
  TIDEObject = class
  private
    FIcon: TIcon;
    FName: string;
    FInstallPath: string;
    FRegKey: string;
    FVersion: string;
  public
    procedure AddLibraryPathToDelphi(const APath: string);
    constructor Create;
    destructor Destroy; override;

    property Version: string read FVersion write FVersion;
    property InstallPath: string read FInstallPath write FInstallPath;
    property Name: string read FName write FName;
    property Icon: TIcon read FIcon write FIcon;
    property RegKey: string read FRegKey;
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

procedure TIDEObject.AddLibraryPathToDelphi(const APath: string);
begin

end;

end.
