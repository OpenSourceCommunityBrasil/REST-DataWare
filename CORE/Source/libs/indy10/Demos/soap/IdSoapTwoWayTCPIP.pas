{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15778: IdSoapTwoWayTCPIP.pas 
{
{   Rev 1.1    18/3/2003 11:04:06  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:36:48  GGrieve
}
{
IndySOAP: This unit defines a bi-directional asynchronous SOAP service over a single TCP/IP connection
}

{
Version History:
  18-Mar 2003   Grahame Grieve                  fix for D4, Kylix
  04-Oct 2002   Grahame Grieve                  First implemented
}

unit IdSoapTwoWayTCPIP;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapClient,
  IdSoapServer,
  IdSoapServerTCPIP,
  IdTCPClient,
  IdTCPConnection,
  IdTCPServer,
  IdThread;

type
  TIdSoapTwoWayTCPIP = class;

  TIdSoapTwoWayTCPIPClientThread = class (TIdThread)
  private
    FClient : TIdTCPClient;
    FOwner : TIdSoapTwoWayTCPIP;
    procedure ReadRequest;
  protected
    procedure Run; override;
  end;

  TIdSoapRequestInformation2WayTCPIP = class (TIdSoapRequestInformationTCPIP)
  private
    FComponent: TIdSoapTwoWayTCPIP;
  public
    property Component : TIdSoapTwoWayTCPIP read FComponent write FComponent;
  end;

  TIdSoapTwoWayTCPIP = Class (TIdSoapBaseMsgSender)
  private
    FAcceptNewConnection: boolean;
    FHost: string;
    FSoapHandler: TIdSoapMsgReceiver;
    FOnDisconnect: TNotifyEvent;
    FOnConnect: TNotifyEvent;
    FSuppressMimeType : boolean;
    FPort: word;
    FConnected: boolean;
    FClient : TIdTCPClient;
    FServer : TIdTCPServer;
    FServerThread : TIdPeerThread;
    FClientThread : TIdSoapTwoWayTCPIPClientThread;
    procedure SetPort(const AValue: word);
    procedure SetHost(const AValue: string);
    Procedure Connect;
    procedure Disconnect;
    procedure StartServer;
    procedure StopServer;
    procedure ClientConnected(ASender : TObject);
    procedure ClientDisconnected(ASender : TObject);
    procedure ServerConnected(AThread: TIdPeerThread);
    procedure ServerDisconnected(AThread: TIdPeerThread);
    procedure ServerExecute(AThread: TIdPeerThread);
    procedure ReadRequest(AThread: TIdPeerThread);
    procedure ClientDisconnect;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream); override;
    function  GetWSDLLocation : string; override;
    procedure SetCookie(AName, AContent : string); override;
    procedure ClearCookie(AName : string);  override;
    procedure Start; override;
    procedure Stop; override;
  public
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
  published
    property AcceptNewConnection : boolean read FAcceptNewConnection write FAcceptNewConnection;
    property Connected : boolean read FConnected;
    property Host : string read FHost write SetHost;
    property OnConnect : TNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect : TNotifyEvent read FOnDisconnect write FOnDisconnect;
    property Port : word read FPort write SetPort;
    property SoapHandler : TIdSoapMsgReceiver read FSoapHandler write FSoapHandler;
    property SuppressMimeType : boolean read FSuppressMimeType write FSuppressMimeType;
  end;


implementation

uses
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapRequestInfo,
  IdSoapResourceStrings,
  IdSoapUtilities,
  SysUtils;

const
  ASSERT_UNIT = 'IdSoapTwoWayTCPIP';

{ TIdSoapTwoWayTCPIPClientThread }

procedure TIdSoapTwoWayTCPIPClientThread.ReadRequest;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIPClientThread.ReadRequest';
var
  LMimeTypeLen : cardinal;
  LPacketLen : cardinal;
  LInMimeType : string;
  LRequest : TIdMemoryStream;
begin

  LMimeTypeLen := FClient.ReadInteger;
  IdRequire(LMimeTypeLen < ID_SOAP_MAX_MIMETYPE_LENGTH, ASSERT_LOCATION+': '+Format(RS_ERR_TCPIP_TOO_LONG, ['Method']));
  LPacketLen := FClient.ReadInteger;
  IdRequire(LPacketLen < ID_SOAP_MAX_PACKET_LENGTH, ASSERT_LOCATION+': '+Format(RS_ERR_TCPIP_TOO_LONG, ['Packet']));
  LInMimeType := FClient.ReadString(LMimeTypeLen);
  LRequest := TIdMemoryStream.create;
  try
    FClient.ReadStream(LRequest, LPacketLen);
    IdRequire(FClient.ReadInteger = ID_SOAP_TCPIP_MAGIC_FOOTER, ASSERT_LOCATION+': Footer not found');
    LRequest.Position := 0;
    if assigned(FOwner.OnReceiveMessage) then
      begin
      FOwner.OnReceiveMessage(FOwner, LRequest);
      end;
    FOwner.FSoapHandler.HandleSoapMessage(LInMimeType, LRequest);
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapTwoWayTCPIPClientThread.Run;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIPClientThread.Run';
var
  LRequestInfo : TIdSoapRequestInformation2WayTCPIP;
begin
  try
    try
      LRequestInfo := TIdSoapRequestInformation2WayTCPIP.create;
      try
        LRequestInfo.ClientCommsSecurity := ccsInsecure;
        LRequestInfo.CommsType := cctTCPIP;
        LRequestInfo.Thread := nil;
        LRequestInfo.Component := FOwner;
        GIdSoapRequestInfo := LRequestInfo;
        try
          while FClient.Connected do
            begin
            if FClient.ReadInteger = ID_SOAP_TCPIP_MAGIC_REQUEST then
              begin
              ReadRequest;
              end
            end;
        finally
          GIdSoapRequestInfo := nil;
        end;
      finally
        FreeAndNil(LRequestInfo);
      end;
    finally
      FreeAndNil(FClient);
      if Assigned(FOwner) then
        begin
        FOwner.ClientDisconnect;
        end;
    end;
  except
    on e: EIdNotConnected do
      begin
      // suppress
      end;
  end;
end;

{ TIdSoapMsgSendEmail }

constructor TIdSoapTwoWayTCPIP.create(AOwner: TComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.Create';
begin
  inherited;
  FAcceptNewConnection := false;
  FHost := '';
  FSoapHandler := nil;
  FOnDisconnect := nil;
  FOnConnect := nil;
  FPort := 0;
  FConnected := false;
end;

destructor TIdSoapTwoWayTCPIP.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.destroy';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  inherited;
end;

function TIdSoapTwoWayTCPIP.GetWSDLLocation: string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.GetWSDLLocation:';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  if FHost = '' then
    begin
    result := 'bin:localhost:'+inttostr(FPort);
    end
  else
    begin
    result := 'bin:'+FHost+':'+inttostr(FPort);
    end;
end;

procedure TIdSoapTwoWayTCPIP.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.Notification';
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FSoapHandler then
      begin
      FSoapHandler := nil;
      end;
    end;
end;

procedure TIdSoapTwoWayTCPIP.ClearCookie(AName: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapTwoWayTCPIP does not support cookie based sessions');
end;

procedure TIdSoapTwoWayTCPIP.SetCookie(AName, AContent: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapTwoWayTCPIP does not support cookie based sessions');
end;

procedure TIdSoapTwoWayTCPIP.SetHost(const AValue: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.SetHost';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  assert(not Active, ASSERT_LOCATION+': cannot set host while active is true');
  FHost := AValue;
end;

procedure TIdSoapTwoWayTCPIP.SetPort(const AValue: word);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.SetPort';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  assert(AValue > 0, ASSERT_LOCATION+': 0 is not valid for Port');
  assert(not Active, ASSERT_LOCATION+': cannot set port while active is true');
  FPort := AValue;
end;

procedure TIdSoapTwoWayTCPIP.Start;
begin
  inherited;
  Try
    if FHost <> '' then
      begin
      Connect;
      end
    else
      begin
      StartServer;
      end;
  except
    on e:exception do
      begin
      active := false;
      raise EIdSoapUnableToConnect.create(e.message);
      end;
  end;
end;

procedure TIdSoapTwoWayTCPIP.Stop;
begin
  try
    if FHost <> '' then
      begin
      if FConnected then
        begin
        Disconnect;
        end;
      end
    else
      begin
      StopServer;
      end;
  finally
    inherited;
  end;
end;

procedure TIdSoapTwoWayTCPIP.ClientConnected(ASender: TObject);
begin
  FConnected := true;
end;

procedure TIdSoapTwoWayTCPIP.ClientDisconnected(ASender: TObject);
begin
  FConnected := false;
end;

procedure TIdSoapTwoWayTCPIP.Connect;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.Connect';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  assert(FHost <> '', ASSERT_LOCATION+': attempt to start client with invalid host address');
  assert(FPort > 0, ASSERT_LOCATION+': attempt to start client with invalid port');
  assert(FSoapHandler.TestValid(TIdSoapMsgReceiver), ASSERT_LOCATION+': Soap Handler is not valid');
  FClient := TIdTCPClient.create(nil);
  FClient.Host := FHost;
  FClient.Port := FPort;
  FClient.OnConnected := ClientConnected;
  FClient.OnDisconnected := ClientDisconnected;
  FClient.Connect;
  if not FClient.Connected then
    begin
    raise EIdSoapUnableToConnect.create('no connection');
    end;
  if assigned(OnConnect) then
    begin
    OnConnect(self);
    end;
  FClientThread := TIdSoapTwoWayTCPIPClientThread.create(true);
  FClientThread.FClient := FClient;
  FClientThread.FOwner := Self;
  FClientThread.FreeOnTerminate := true;
  FClientThread.Start;
end;

procedure TIdSoapTwoWayTCPIP.Disconnect;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.Disconnect';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  assert(assigned(FClient), ASSERT_LOCATION+': Client is not valid');
  FClientThread.FOwner := nil;
  FClientThread.FClient := nil;
  FClientThread.Terminate;
  FClientThread := nil;
  FreeAndNil(FClient);
  FConnected := false;
  Active := false;
  if assigned(OnDisconnect) then
    begin
    OnDisconnect(self);
    end;
end;

procedure TIdSoapTwoWayTCPIP.ClientDisconnect;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.Disconnect';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  assert(assigned(FClient), ASSERT_LOCATION+': Client is not valid');
  FClientThread := nil;
  FClient := nil;
  FConnected := false;
  Active := false;
  if assigned(OnDisconnect) then
    begin
    OnDisconnect(self);
    end;
end;

procedure TIdSoapTwoWayTCPIP.ServerConnected(AThread: TIdPeerThread);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.ServerConnected';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  if FAcceptNewConnection and assigned(FServerThread) then
    begin
    FServerThread.Connection.Disconnect;
    // now wait for it to disconnect
    sleep(50);
    end;
  FConnected := true;
  FServerThread := AThread;
  if assigned(OnConnect) then
    begin
    OnConnect(self);
    end;
end;

procedure TIdSoapTwoWayTCPIP.ServerDisconnected(AThread: TIdPeerThread);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.ServerDisconnected';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  FConnected := false;
  FServerThread := nil;
  if assigned(OnDisconnect) then
    begin
    OnDisconnect(self);
    end;
end;

procedure TIdSoapTwoWayTCPIP.ReadRequest(AThread: TIdPeerThread);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.ReadRequest';
var
  LMimeTypeLen : cardinal;
  LPacketLen : cardinal;
  LInMimeType : string;
  LRequest : TIdMemoryStream;
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  assert(assigned(AThread), ASSERT_LOCATION+': Thread is not assigned');

  LMimeTypeLen := AThread.Connection.ReadInteger;
  IdRequire(LMimeTypeLen < ID_SOAP_MAX_MIMETYPE_LENGTH, ASSERT_LOCATION+': '+Format(RS_ERR_TCPIP_TOO_LONG, ['Method']));
  LPacketLen := AThread.Connection.ReadInteger;
  IdRequire(LPacketLen < ID_SOAP_MAX_PACKET_LENGTH, ASSERT_LOCATION+': '+Format(RS_ERR_TCPIP_TOO_LONG, ['Packet']));
  LInMimeType := AThread.Connection.ReadString(LMimeTypeLen);
  LRequest := TIdMemoryStream.create;
  try
    AThread.Connection.ReadStream(LRequest, LPacketLen);
    IdRequire(AThread.Connection.ReadInteger = ID_SOAP_TCPIP_MAGIC_FOOTER, ASSERT_LOCATION+': Footer not found');
    LRequest.Position := 0;
    if assigned(OnReceiveMessage) then
      begin
      OnReceiveMessage(self, LRequest);
      end;
    FSoapHandler.HandleSoapMessage(LInMimeType, LRequest);
  finally
    FreeAndNil(LRequest);
  end;
end;

procedure TIdSoapTwoWayTCPIP.ServerExecute(AThread: TIdPeerThread);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.ServerExecute';
var
  LRequestInfo : TIdSoapRequestInformation2WayTCPIP;
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  assert(assigned(AThread), ASSERT_LOCATION+': Thread is not assigned');

  LRequestInfo := TIdSoapRequestInformation2WayTCPIP.create;
  try
    LRequestInfo.ClientCommsSecurity := ccsInsecure;
    LRequestInfo.CommsType := cctTCPIP;
    LRequestInfo.Thread := AThread;
    LRequestInfo.Component := self;
    GIdSoapRequestInfo := LRequestInfo;
    try
      while AThread.Connection.Connected do
        begin
        if AThread.Connection.ReadInteger = ID_SOAP_TCPIP_MAGIC_REQUEST then
          begin
          ReadRequest(AThread);
          end;
        end;
    finally
      GIdSoapRequestInfo := nil;
    end;
  finally
    FreeAndNil(LRequestInfo);
  end;
end;

procedure TIdSoapTwoWayTCPIP.StartServer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.StartServer';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  FServer := TIdTCPServer.create(nil);
  FServer.DefaultPort := FPort;
  FServer.OnConnect := ServerConnected;
  FServer.OnDisconnect := ServerDisconnected;
  FServer.OnExecute := ServerExecute;
  if FAcceptNewConnection then
    begin
    FServer.MaxConnections := 2;
    end
  else
    begin
    FServer.MaxConnections := 1;
    end;
  FServer.Active := true;
end;

procedure TIdSoapTwoWayTCPIP.StopServer;
begin
  FreeAndNil(FServer);
end;

procedure TIdSoapTwoWayTCPIP.DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapTwoWayTCPIP.DoSoapSend';
begin
  assert(Self.TestValid(TIdSoapTwoWayTCPIP), ASSERT_LOCATION+': self is not valid');
  // no check on SoapAction - not sure what to do with it
  assert(AMimeType <> '', ASSERT_LOCATION+': MimeType not provided');
  assert(Assigned(ARequest), ASSERT_LOCATION+': Request is not valid');
  assert(ARequest.Size > 0, ASSERT_LOCATION+': Request is not valid (size = 0)');
  if not FConnected then
    begin
    raise EIdSoapNotConnected.create(ASSERT_LOCATION+': '+Format(RS_ERR_TCPIP_NO_CONN, [Name]));
    end;
  if FHost = '' then
    begin
    assert(assigned(FServerThread), ASSERT_LOCATION+': Server Connection not valid');
    FServerThread.Connection.OpenWriteBuffer;
    try
      FServerThread.Connection.WriteInteger(ID_SOAP_TCPIP_MAGIC_REQUEST);
      if FSuppressMimeType then
        begin
        FServerThread.Connection.WriteInteger(0);
        FServerThread.Connection.WriteInteger(ARequest.Size);
        end
      else
        begin
        FServerThread.Connection.WriteInteger(length(AMimeType));
        FServerThread.Connection.WriteInteger(ARequest.Size);
        FServerThread.Connection.Write(AMimeType);
        end;
      FServerThread.Connection.WriteStream(ARequest);
      FServerThread.Connection.WriteInteger(ID_SOAP_TCPIP_MAGIC_FOOTER);
      FServerThread.Connection.FlushWriteBuffer;
    finally
      FServerThread.Connection.CloseWriteBuffer;
    end;
    end
  else
    begin
    assert(Assigned(FClient), ASSERT_LOCATION+'['+Name+'].DoSoapRequest: Client not valid');
    FClient.OpenWriteBuffer;
    try
      FClient.WriteInteger(ID_SOAP_TCPIP_MAGIC_REQUEST);
      if FSuppressMimeType then
        begin
        FClient.WriteInteger(length(AMimeType));
        FClient.WriteInteger(ARequest.Size);
        FClient.Write(AMimeType);
        end
      else
        begin
        FClient.WriteInteger(0);
        FClient.WriteInteger(ARequest.Size);
        end;
      FClient.WriteStream(ARequest);
      FClient.WriteInteger(ID_SOAP_TCPIP_MAGIC_FOOTER);
      FClient.FlushWriteBuffer;
    finally
      FClient.CloseWriteBuffer;
    end;
    end;
end;

end.




