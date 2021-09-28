unit udaemonservice;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DaemonApp;

type

  { TDaemonMapper1 }

  TDaemonMapper1 = class(TDaemonMapper)
    procedure DaemonMapper1Run(Sender: TObject);
  private

  public

  end;

var
  DaemonMapper1: TDaemonMapper1;

implementation

procedure RegisterMapper;
begin
  RegisterDaemonMapper(TDaemonMapper1)
end;

{$R *.lfm}

{ TDaemonMapper1 }

procedure TDaemonMapper1.DaemonMapper1Run(Sender: TObject);
begin
 //
end;


initialization
  RegisterMapper;
end.

