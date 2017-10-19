{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  22978: ChatContextData.pas 
{
{   Rev 1.0    09/10/2003 3:16:28 PM  Jeremy Darling
{ Project uploaded for the first time
}
unit ChatContextData;

interface

uses
  Classes,
  SyncObjs,
  SysUtils,
  IdContext;

type
  TChatContextData = class;

  TMsgAvail    = procedure(Sender : TChatContextData) of object;
  TUserNameSet = procedure(Sender : TChatContextData; var UserName : String) of object;

  TChatContextData=class(TObject)
  private
    FLock : TCriticalSection;
    FCurMsg: TStringList;
    FOnMsgAvail: TMsgAvail;
    FContext: TIdContext;
    FUserName: String;
    FOnUserNameSet: TUserNameSet;
    function GetCurMsg: String;
    procedure CheckForMsg;
    procedure SetOnMsgAvail(const Value: TMsgAvail);
    function GetContext: TIdContext;
    procedure SetUserName(const Value: String);
    procedure SetOnUserNameSet(const Value: TUserNameSet);
  public
    property CurMsg : String read GetCurMsg;
    function Pop : String;
    constructor Create;
    destructor Destroy; override;
    procedure CheckMsg(AContext: TIdContext);
    property OnMsgAvail : TMsgAvail read FOnMsgAvail write SetOnMsgAvail;
    property Context: TIdContext read GetContext;
    property UserName : String read FUserName write SetUserName;
    property OnUserNameSet : TUserNameSet read FOnUserNameSet write SetOnUserNameSet;
  end;

implementation

{ TChatContextData }

procedure TChatContextData.CheckForMsg;
var
  UN : String;
  msg: String;
begin
  if FCurMsg.Count > 1 then
    begin
      if UserName = '' then
        begin
          UN := Pop;
          if Assigned(FOnUserNameSet) then
            FOnUserNameSet(Self, UN);
          UserName := UN;
          msg := 'Welcome ' + UN + #13#10;
          Context.Connection.IOHandler.WriteBuffer(msg[1], length(msg));
        end
      else
        if Assigned(FOnMsgAvail) then
          FOnMsgAvail(Self);
    end;
end;

procedure TChatContextData.CheckMsg(AContext: TIdContext);
var
  S, Swp : String;
  I : Integer;
begin
  FLock.Enter;
  try
    FContext := AContext;
    AContext.Connection.IOHandler.CheckForDisconnect(True, True);
    I := AContext.Connection.IOHandler.Buffer.Size;
    If I >= 1 then
      begin
        Swp := Copy(FCurMsg.Text, 1, Length(FCurMsg.Text) -2);
        SetLength(S, I);
        AContext.Connection.IOHandler.ReadBuffer(S[1], I);
        S := StringReplace(S, #13#10, #10#13, [rfReplaceAll]);
        if (S = #10#13) then
          FCurMsg.Add('')
        else
          FCurMsg.Text := Swp + S;
        CheckForMsg;
      end;
  finally
    FLock.Leave;
  end;
end;

constructor TChatContextData.Create;
begin
  inherited;
  FCurMsg := TStringList.Create;
  FLock   := TCriticalSection.Create;
end;

destructor TChatContextData.Destroy;
begin
  FCurMsg.Free;
  FLock.Free;
  inherited;
end;

function TChatContextData.GetContext: TIdContext;
begin
  Result := FContext;
end;

function TChatContextData.GetCurMsg: String;
begin
  FLock.Enter;
  try
    if FCurMsg.Count > 0 then
      begin
        Result := FCurMsg[0];
      end
    else
      Result := '';
  finally
    FLock.Leave;
  end;
end;

function TChatContextData.Pop: String;
begin
  FLock.Enter;
  try
    Result := GetCurMsg;
    if UserName <> '' then
      Result := UserName + ': ' + Result;
    if FCurMsg.Count > 0 then
      FCurMsg.Delete(0);
  finally
    FLock.Leave;
  end;
end;

procedure TChatContextData.SetOnMsgAvail(const Value: TMsgAvail);
begin
  FOnMsgAvail := Value;
end;

procedure TChatContextData.SetOnUserNameSet(const Value: TUserNameSet);
begin
  FOnUserNameSet := Value;
end;

procedure TChatContextData.SetUserName(const Value: String);
begin
  FUserName := Value;
end;

end.
