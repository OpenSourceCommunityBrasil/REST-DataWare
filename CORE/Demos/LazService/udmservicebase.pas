unit uDmServiceBase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRESTDWSynBase;

type
  TrdwDaemonDM = class(TDatamodule)
    RESTDWServiceSynPooler1: TRESTDWServiceSynPooler;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
   Procedure StartServer;
   Procedure StopServer;
  end;

var
  rdwDaemonDM: TrdwDaemonDM;

implementation

uses uDmService;

{$R *.lfm}

{ TrdwDaemonDM }

procedure TrdwDaemonDM.DataModuleCreate(Sender: TObject);
begin
   RESTDWServiceSynPooler1.ServerMethodClass := TServerMethodDM;
end;

procedure TrdwDaemonDM.StartServer;
begin
 RESTDWServiceSynPooler1.Active := True;
end;

procedure TrdwDaemonDM.StopServer;
begin
 RESTDWServiceSynPooler1.Active := False;
end;

end.

