{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22956: ClientThread.pas 
{
{   Rev 1.0    09/10/2003 3:10:54 PM  Jeremy Darling
{ Project Checked into TC for the first time
}
unit ClientThread;

interface

uses
  IdTCPClient,
  ComCtrls,
  Classes,
  SysUtils,
  SyncObjs,
  Windows;

type
  TClientThread=class(TThread)
  private
    FClient: TIdTCPClient;
    FState: Integer;
    FStatusText: String;
    FListItem: TListItem;
    FLastTick: Cardinal;
    FuiLock: TCriticalSection;
    FSleepTime: Integer;
    procedure SetState(const Value: Integer);
    procedure SetStatusText(const Value: String);
    procedure SetListItem(const Value: TListItem);
    procedure SetuiLock(const Value: TCriticalSection);
    procedure SetSleepTime(const Value: Integer);
  public
    procedure AssignClient(AClient: TIdTCPClient);
    procedure Execute; override;
    destructor Destroy; override;
    property SleepTime : Integer read FSleepTime write SetSleepTime;
    property Client : TIdTCPClient read FClient;
    property State : Integer read FState write SetState;
    property StatusText : String read FStatusText write SetStatusText;
    property ListItem : TListItem read FListItem write SetListItem;
    property uiLock   : TCriticalSection read FuiLock write SetuiLock;
  end;

implementation

{ TClientThread }

procedure TClientThread.AssignClient(AClient: TIdTCPClient);
begin
  if not Assigned(FClient) then
    FClient := TIdTCPClient.Create(nil);
  with FClient do
    begin
      Port           := AClient.Port;
      Host           := AClient.Host;
      IOHandler      := AClient.IOHandler;
      OnConnected    := AClient.OnConnected;
      OnDisconnected := AClient.OnDisconnected;
      OnStatus       := AClient.OnStatus;
      OnWork         := AClient.OnWork;
      OnWorkBegin    := AClient.OnWorkBegin;
      OnWorkEnd      := AClient.OnWorkEnd;
    end;
end;

destructor TClientThread.Destroy;
begin
  uiLock.Enter;
  try
    ListItem.Free;
  finally
    uiLock.Leave;
    FClient.Free;
    inherited;
  end;
end;

procedure TClientThread.Execute;
begin
  while not Terminated do
    begin
      if (not FClient.Connected) and
         (State = -2) then
        begin
          State := -1;
          FClient.Connect;
          FLastTick := GetTickCount;
        end
      else
        begin
          if State <> -1 then
            begin
              if GetTickCount - FLastTick > 1000 then
                begin
                  State := State + 1;
                  FLastTick := GetTickCount;
                  if State > SleepTime then
                    begin
                      State := -3;
                      FClient.Disconnect;
                    end;
                end
              else
                Sleep(500);
            end;
        end;
    end
end;

procedure TClientThread.SetListItem(const Value: TListItem);
begin
  FListItem := Value;
end;

procedure TClientThread.SetSleepTime(const Value: Integer);
begin
  FSleepTime := Value;
end;

procedure TClientThread.SetState(const Value: Integer);
begin
  FState := Value;
  case Value of
    -3 : StatusText := 'Disconnecting';
    -2 : StatusText := 'Creating';
    -1 : StatusText := 'Connecting';
  else
    StatusText := 'Sleeping [' + IntToStr(Value) + '/' + IntToStr(SleepTime) + '] while connected';
  end;
end;

procedure TClientThread.SetStatusText(const Value: String);
begin
  uiLock.Enter;
  try
    FStatusText := Value;
    ListItem.SubItems[0] := value;
  finally
    uiLock.Leave;
  end;
end;

procedure TClientThread.SetuiLock(const Value: TCriticalSection);
begin
  FuiLock := Value;
end;

end.
