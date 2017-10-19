{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15746: IdSoapMsgEmail.pas 
{
{   Rev 1.0    11/2/2003 20:34:34  GGrieve
}
{
IndySOAP: This unit defines Sending and Receiving Soap Messaging
objects that use Email for transport
}
{
Version History:
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  27-Aug 2002   Grahame Grieve                  Linux fix - specify port number
  06-Aug 2002   Grahame Grieve                  First implementation
}

unit IdSoapMsgEmail;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSMTP,
  IdEMailAddress,
  IdMessage,
  IdPOP3,
  IdSMTPServer,
  IdSoapClient,
  IdSoapDebug,
  IdSoapITIProvider,
  IdSoapServer,
  IdTCPServer;

type
  // send via email
  TIdSoapMsgSendEmail = Class (TIdSoapBaseMsgSender)
  private
    FDestination : TIdEMailAddressItem;
    FSender : TIdEMailAddressItem;
    FSMTPHost : string;
    FPrivateSMTP : TIdSMTP;
    FWorkingSMTP : TIdSMTP;
    FSMTP : TIdSMTP;
    FSMTPPort: word;
    procedure GetWorkingSMTP;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream); override;
    function  GetWSDLLocation : string; override;
    procedure SetCookie(AName, AContent : string); override;
    procedure ClearCookie(AName : string);  override;
  public
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
  published
    property Destination : TIdEMailAddressItem read FDestination;
    property Sender : TIdEMailAddressItem read FSender;
    property SMTPHost : String read FSMTPHost write FSMTPHost;
    property SMTP : TIdSMTP read FSMTP write FSMTP;
    property SMTPPort : word read FSMTPPort write FSMTPPort;
  end;

  // receive by SMTP. You have no choice but to receive in the server
  // thread in this case. If you don't want threading, use a
  // TIdSoapMsgPOPListener
  // There is no custom SMTP server. Therefore this object exposes
  // the following events:
  //    OnReceiveRaw
  //    OnReceiveMessage
  //    OnReceiveMessageParsed
  // but you can't use any of these on an object of this class without
  // disabling it. Also, don't change the ReceiveMode property
  TIdSoapMsgSMTPListener = Class (TIdSMTPServer)
  private
    FListener: TIdSoapMsgReceiver;
    Procedure MsgIn(ASender: TIdCommand; var VMsg: TIdMessage; ARCPT: TIdEMailAddressList; var VCustomError: string);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor create(AOwner : TComponent); override;
  published
    property Listener : TIdSoapMsgReceiver read FListener write FListener;
  end;

  // receive by Pop
  // currently you have to poll for msgs yourself
  TIdSoapMsgPopListener = Class (TIdPOP3)
  private
    FListener: TIdSoapMsgReceiver;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    Procedure PollForSoapMessages;
  published
    property Listener : TIdSoapMsgReceiver read FListener write FListener;
  end;

implementation

uses
  IdSoapExceptions,
  IdSoapRequestInfo,
  IdSoapUtilities,
  SysUtils;

const
  ASSERT_UNIT = 'IdSoapMsgEmail';

{ TIdSoapMsgSendEmail }

constructor TIdSoapMsgSendEmail.create(AOwner: TComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendEmail.Create';
begin
  inherited;
  FDestination := TIdEMailAddressItem.create(nil);
  FSender := TIdEMailAddressItem.create(nil);
  FPrivateSMTP := nil;
  FWorkingSMTP := nil;
  FSMTP := nil;
end;

destructor TIdSoapMsgSendEmail.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendEmail.destroy';
begin
  assert(Self.TestValid(TIdSoapMsgSendEmail), ASSERT_LOCATION+': self is not valid');
  if assigned(FPrivateSMTP) then
    begin
    FreeAndNil(FPrivateSMTP);
    end;
  FreeAndNil(FDestination);
  FreeAndNil(FSender);
  inherited;
end;

procedure TIdSoapMsgSendEmail.DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendEmail.DoSoapSend';
var
  LMsg : TIdMessage;
  s : string;
begin
  assert(Self.TestValid(TIdSoapMsgSendEmail), ASSERT_LOCATION+': self is not valid');
  // no check on SoapAction - not sure what to do with it
  assert(AMimeType <> '', ASSERT_LOCATION+': MimeType not provided');
  assert(Assigned(ARequest), ASSERT_LOCATION+': Request is not valid');
  assert(ARequest.Size > 0, ASSERT_LOCATION+': Request is not valid (size = 0)');
  assert(FDestination.Address <> '', ASSERT_LOCATION+': Destination Address is blank');
  assert(FSender.Address <> '', ASSERT_LOCATION+': Sender Address is blank');

  SetLength(s, ARequest.Size);
  ARequest.Read(s[1], ARequest.Size);
  s := IdSoapMakeXmlPretty(s);

  LMsg := TIdMessage.create(nil);
  try
    LMsg.From.Assign(FSender);
    LMsg.Recipients.Add.Assign(FDestination);
    LMsg.Subject := GetSubject;
    LMsg.Body.Text := s;
    GetWorkingSMTP;
    assert(FWorkingSMTP.Host <> '', ASSERT_LOCATION+': SMTP Host not identified');
    if not FWorkingSMTP.Connected then
      begin
      FWorkingSMTP.Connect;
      end;
    FWorkingSMTP.Send(LMsg);
  finally
    FreeAndNil(LMsg);
  end;
end;

procedure TIdSoapMsgSendEmail.GetWorkingSMTP;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendEmail.GetWorkingTIdSMTP';
begin
  assert(Self.TestValid(TIdSoapMsgSendEmail), ASSERT_LOCATION+': self is not valid');
  if not assigned(FWorkingSMTP) then
    begin
    if assigned(FSMTP) then
      begin
      FWorkingSMTP := FSMTP;
      end
    else
      begin
      FPrivateSMTP := TIdSMTP.create(nil);
      FPrivateSMTP.Host := FSMTPHost;
      FPrivateSMTP.Port := FSMTPPort;
      FWorkingSMTP := FPrivateSMTP;
      end;
    end;
end;

function TIdSoapMsgSendEmail.GetWSDLLocation: string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendEmail.GetWSDLLocation:';
begin
  assert(Self.TestValid(TIdSoapMsgSendEmail), ASSERT_LOCATION+': self is not valid');
  result := 'mailto:'+FDestination.Address;
end;

procedure TIdSoapMsgSendEmail.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendEmail.Notification';
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FSMTP then
      begin
      FSMTP := nil;
      end;
    end;
end;

procedure TIdSoapMsgSendEmail.ClearCookie(AName: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapMsgSendEmail does not support cookie based sessions');
end;

procedure TIdSoapMsgSendEmail.SetCookie(AName, AContent: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapMsgSendEmail does not support cookie based sessions');
end;

{ TIdSoapMsgSMTPListener }

constructor TIdSoapMsgSMTPListener.create(AOwner: TComponent);
begin
  inherited;
  ReceiveMode := rmMessageParsed;
  OnReceiveMessageParsed := MsgIn;
end;

procedure TIdSoapMsgSMTPListener.MsgIn(ASender: TIdCommand; var VMsg: TIdMessage; ARCPT: TIdEMailAddressList; var VCustomError: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSMTPListener.MsgIn';
var
  LStream : TIdMemoryStream;
begin
  assert(assigned(Self), ASSERT_LOCATION+': self is not valid');
  assert(assigned(VMsg), ASSERT_LOCATION+': Msg is not valid');
  assert(Length(VMsg.Body.Text) > 1, ASSERT_LOCATION+': Msg contains no content');
  assert(FListener.TestValid(TIdSoapMsgReceiver), ASSERT_LOCATION+': Listener is not valid');

  LStream := TIdMemoryStream.create;
  try
    LStream.Write(VMsg.Body.Text[1], Length(VMsg.Body.Text));
    LStream.Position := 0;
    GIdSoapRequestInfo := TIdSoapRequestInformation.create;
    GIdSoapRequestInfo.ClientCommsSecurity := ccsInsecure;
    GIdSoapRequestInfo.CommsType := cctEmail;
    try
      FListener.HandleSoapMessage('', LStream);
    finally
      FreeAndNil(GIdSoapRequestInfo);
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

procedure TIdSoapMsgSMTPListener.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSMTPListener.Notification';
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FListener then
      begin
      FListener := nil;
      end;
    end;
end;

{ TIdSoapMsgPopListener }

procedure TIdSoapMsgPopListener.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgPopListener.Notification';
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FListener then
      begin
      FListener := nil;
      end;
    end;
end;

procedure TIdSoapMsgPopListener.PollForSoapMessages;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgPopListener.PollForSoapMessages';
var
  i : integer;
  LMsg : TIdMessage;
  LStream : TIdMemoryStream;
begin
  assert(assigned(Self), ASSERT_LOCATION+': self is not valid');
  assert(FListener.TestValid(TIdSoapMsgReceiver), ASSERT_LOCATION+': Listener is not valid');
  if not connected then
    begin
    connect;
    end;
  for i := 1 to CheckMessages do
    begin
    LMsg := TIdMessage.create(nil);
    try
      Retrieve(i, LMsg);
      assert(Length(LMsg.Body.Text) > 1, ASSERT_LOCATION+': Msg contains no content');
      LStream := TIdMemoryStream.create;
      try
        LStream.Write(LMsg.Body.Text[1], Length(LMsg.Body.Text));
        LStream.Position := 0;
        GIdSoapRequestInfo := TIdSoapRequestInformation.create;
        GIdSoapRequestInfo.ClientCommsSecurity := ccsInsecure;
        GIdSoapRequestInfo.CommsType := cctEmail;
        try
          FListener.HandleSoapMessage('', LStream);
        finally
          FreeAndNil(GIdSoapRequestInfo);
        end;
      finally
        FreeAndNil(LStream);
      end;
      Delete(i);
    finally
      FreeAndNil(LMsg);
    end;
    end;
end;

end.




