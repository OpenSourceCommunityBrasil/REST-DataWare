{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15744: IdSoapMsgDirect.pas 
{
{   Rev 1.1    18/3/2003 11:02:48  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:34:28  GGrieve
}
{
IndySOAP: This unit defines a direct one-Way Soap Sender
}
{
Version History:
  18-Mar 2003   Grahame Grieve                  Remove assert in notify event
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Jul 2002   Grahame Grieve                  D4 Compiler fixes
   6-Aug 2002   Grahame Grieve                  First implementation
}

unit IdSoapMsgDirect;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapClient,
  IdSoapClientDirect,
  IdSoapServer,
  IdSoapITIProvider;

type
  TIdSoapMsgSendDirect = Class (TIdSoapBaseMsgSender)
  private
    FListener: TIdSoapMsgReceiver;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream); override;
    function  GetWSDLLocation : string; override;
    procedure SetCookie(AName, AContent : string); override;
    procedure ClearCookie(AName : string);  override;
  public
    constructor create(AOwner : TComponent); override;
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
  ASSERT_UNIT = 'IdSoapMsgDirect';

{ TIdSoapMsgSendEmail }

constructor TIdSoapMsgSendDirect.create(AOwner: TComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendDirect.Create';
begin
  inherited;
  FListener := nil;
end;

procedure TIdSoapMsgSendDirect.DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendDirect.DoSoapSend';
var
  LRequestInfo : TIdSoapRequestInformationDirect;
begin
  assert(Self.TestValid(TIdSoapMsgSendDirect), ASSERT_LOCATION+': self is not valid');
  // no check on SoapAction - not sure what to do with it
  assert(AMimeType <> '', ASSERT_LOCATION+': MimeType not provided');
  assert(Assigned(ARequest), ASSERT_LOCATION+': Request is not valid');
  assert(FListener.TestValid(TIdSoapMsgReceiver), ASSERT_LOCATION+': Listener is not valid');
  LRequestInfo := TIdSoapRequestInformationDirect.create;
  try
    LRequestInfo.ClientCommsSecurity := ccAuthenticated;
    LRequestInfo.CommsType := cctDirect;
    GIdSoapRequestInfo := LRequestInfo;
    try
      FListener.HandleSoapMessage(AMimeType, ARequest);
    finally
      GIdSoapRequestInfo := nil;
    end;
  finally
    FreeAndNil(LRequestInfo);
  end;
end;

function TIdSoapMsgSendDirect.GetWSDLLocation: string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendDirect.GetWSDLLocation:';
begin
  assert(Self.TestValid(TIdSoapMsgSendDirect), ASSERT_LOCATION+': self is not valid');
  result := 'urn:direct';
end;

procedure TIdSoapMsgSendDirect.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgSendDirect.Notification';
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

procedure TIdSoapMsgSendDirect.ClearCookie(AName: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapMsgSendDirect does not support cookie based sessions');
end;

procedure TIdSoapMsgSendDirect.SetCookie(AName, AContent: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapMsgSendDirect does not support cookie based sessions');
end;

end.



