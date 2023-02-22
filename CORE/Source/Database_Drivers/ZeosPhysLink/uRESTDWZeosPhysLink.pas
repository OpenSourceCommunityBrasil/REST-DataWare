unit uRESTDWZeosPhysLink;

interface

uses
  Classes, SysUtils, ZConnection, ZDbcIntfs, uRESTDWAbout, uRESTDWBasicDB,
  uRESTDWZDbc;

type
  TRESTDWZeosPhysLink = class(TRESTDWComponent)
  private
    FZConnection : TZConnection;
    FDatabase : TRESTDWDatabasebaseBase;
    FProvider : TZServerProvider;
    FOldZeosBeforeConnect : TNotifyEvent;
    procedure setZConnection(const Value: TZConnection);
  protected
    procedure OnRESTDWZeosBeforeConnect(Sender : TObject);
  published
    property ZConnection : TZConnection read FZConnection write setZConnection;
    property Provider : TZServerProvider read FProvider write FProvider;
    property Database : TRESTDWDatabasebaseBase read FDatabase write FDatabase;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - PhysLink', [TRESTDWZeosPhysLink]);
end;

{ TRESTDWZeosPhysLink }

procedure TRESTDWZeosPhysLink.OnRESTDWZeosBeforeConnect(Sender: TObject);
begin
  if Assigned(FOldZeosBeforeConnect) then
    FOldZeosBeforeConnect(FZConnection);
  TZRESTDWDriver(FZConnection.DbcDriver).Database := FDatabase;
end;

procedure TRESTDWZeosPhysLink.setZConnection(const Value: TZConnection);
begin
  FZConnection := Value;
  FOldZeosBeforeConnect := nil;
  if (FZConnection <> nil) and (ZConnection.Protocol = 'restdw') then begin
    FOldZeosBeforeConnect := FZConnection.BeforeConnect;
    FZConnection.BeforeConnect := {$IFDEF FPC}@{$ENDIF}OnRESTDWZeosBeforeConnect;
  end;
end;

end.
