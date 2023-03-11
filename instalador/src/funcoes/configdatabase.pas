unit configdatabase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, SQLite3Conn;

type
  TIDEKind = (ikDelphi, ikLazarus);
  TResourceType = (rtSocket, rtDBWare, rtResources);

  { TRESTDWInstallerConfigDataBase }

  TRESTDWInstallerConfigDataBase = class
  public
    constructor Create;
    destructor Destroy; override;
    function getResourceList(aIDE: TIDEKind; aVersion: string;
      aResType: TResourceType): string;
  private
    FQuery: TSQLQuery;
    FConnection: TSQLite3Connection;
    procedure CreateDatabase;

  end;

implementation

{ TRESTDWInstallerConfigDataBase }

constructor TRESTDWInstallerConfigDataBase.Create;
begin
  FConnection := TSQLite3Connection.Create(nil);
  FConnection.DatabaseName := ExtractFileDir(ParamStr(0)) + '\installer.bin';
  FConnection.CreateDB;

  FQuery := TSQLQuery.Create(nil);
  FQuery.SQLConnection := FConnection;
  CreateDatabase;
end;

destructor TRESTDWInstallerConfigDataBase.Destroy;
begin
  FQuery.Free;
  FConnection.Free;
  inherited Destroy;
end;

function TRESTDWInstallerConfigDataBase.getResourceList(aIDE: TIDEKind;
  aVersion: string; aResType: TResourceType): string;
begin

end;

procedure TRESTDWInstallerConfigDataBase.CreateDatabase;
begin
  FQuery.SQL.Text := 'PRAGMA table_info()';
  FQuery.Open;
  if FQuery.IsEmpty then
    with FQuery.SQL do
    begin

    end;
  FQuery.Close;
end;

end.
