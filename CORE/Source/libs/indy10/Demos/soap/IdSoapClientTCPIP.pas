{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15698: IdSoapClientTCPIP.pas 
{
{   Rev 1.1    20/6/2003 00:02:32  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:32:00  GGrieve
}
{
IndySOAP: This unit defines A SoapClient that uses TCP/IP directly

This requires IndySoap at either end. There is no real re-connection
support in the client. It's intended for LAN operation
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Compression
  04-Oct 2002   Grahame Grieve                  Suppress Mime Type
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Grahame Grieve                  Fix notification Bug
  26-Jul 2002   Grahame Grieve                  Add GetWSDLLocation
  05-Jun 2002   Grahame Grieve                  Fix Disconnect when Stop :-(
  04-Jun 2002   Grahame Grieve                  Disconnect when Stop
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  02-Apr 2002   Grahame Grieve                  Fix access violation using a TIdTCPClient
   7-Mar 2002   Grahame Grieve                  Review assertions, add support for EncodingType
  03-Feb 2002   Andrew Cumming Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}
{
IndySOAP: TCPIP Transport Client Implementation

Custom TCP/IP protocol. Requires IndySoap on both client and server. There is
no commitment to keeping this protocol backwards compatible. You should only
use it where both client and server can be upgraded together

Refer to IdSoapServerTCPIP for network protocol documentation
}

{
Version History:
  20-Mar 2002   Andrew Cumming                  Made D4/D5 compilable
  15-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapClientTCPIP;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapClient,
  IdSoapDebug,
  IdSoapITIProvider,
  IdTCPClient;

type
  TIdSoapClientTCPIP = Class (TIdSoapBaseClient)
  private
    FSoapHost : string;
    FSoapPort : word;
    FSoapTimeout : cardinal;
    FNextPacketID : integer;
    FPrivateTCPClient : TIdTCPClient;
    FWorkingTCPClient : TIdTCPClient;
    FTCPClient : TIdTCPClient;
    FSuppressMimeType: boolean;
    FCompression: boolean;
    procedure GetWorkingTCPClient;
    procedure SetCompression(const Value: boolean);
  protected
    procedure Stop; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string); override;
    function GetTransportDefaultEncodingType: TIdSoapEncodingType; override;
    function  GetWSDLLocation : string; override;
    procedure SetCookie(AName, AContent : string); override;
    procedure ClearCookie(AName : string);  override;
  public
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
  published
    property SoapHost : string read FSoapHost write FSoapHost;
    property SoapPort : word read FSoapPort write FSoapPort;
    property SoapTimeout : cardinal read FSoapTimeout write FSoapTimeout;
    property SuppressMimeType : boolean read FSuppressMimeType write FSuppressMimeType;
    property Compression : boolean read FCompression write SetCompression;
    property TCPClient : TIdTCPClient read FTCPClient write FTCPClient;
  end;

implementation

uses
  {$IFDEF ID_SOAP_COMPRESSION}
  IdCompressionIntercept,
  {$ENDIF}
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapITI,
  IdSoapUtilities,
  SysUtils;

{ TIdSoapClientTCPIP }

constructor TIdSoapClientTCPIP.create(AOwner: TComponent);
begin
  inherited;
  FSoapHost := '';
  FSoapPort := 0;
  FSoapTimeout := ID_SOAP_TCPIP_TIMEOUT;
  FWorkingTCPClient := nil;
  FTCPClient := nil;
  FPrivateTCPClient := nil;
end;

destructor TIdSoapClientTCPIP.destroy;
begin
  assert(Self.TestValid(TIdSoapClientTCPIP), 'IdSoapClientTCPIP.TIdSoapClientTCPIP.Destroy: self is not valid');
  if assigned(FPrivateTCPClient) then
    begin
    FreeAndNil(FPrivateTCPClient);
    end;
  inherited;
end;

procedure TIdSoapClientTCPIP.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FTCPClient then
      begin
      FTCPClient := nil;
      end;
    end;
end;

function TIdSoapClientTCPIP.GetTransportDefaultEncodingType: TIdSoapEncodingType;
begin
  result := etIdBinary;
end;

procedure TIdSoapClientTCPIP.GetWorkingTCPClient;
const ASSERT_LOCATION = 'IdSoapClientTCPIP.TIdSoapClientTCPIP.GetWorkingTCPClient';
begin
  assert(Self.TestValid(TIdSoapClientTCPIP), ASSERT_LOCATION+': self is not valid');
  if not assigned(FWorkingTCPClient) then
    begin
    FNextPacketID := 0;
    if assigned(FTCPClient) then
      begin
      assert(not FCompression, ASSERT_LOCATION+': Compression is not supported when another TCPClient is used');
      FWorkingTCPClient := FTCPClient;
      end
    else
      begin
      FPrivateTCPClient := TIdTCPClient.create(nil);
      FPrivateTCPClient.Host := FSoapHost;
      FPrivateTCPClient.Port := FSoapPort;
      {$IFDEF ID_SOAP_COMPRESSION}
      if FCompression then
        begin
        FPrivateTCPClient.Intercept := TIdCompressionIntercept.create(FPrivateTCPClient);
        (FPrivateTCPClient.Intercept as TIdCompressionIntercept).CompressionLevel := 9;
        end;
      {$ENDIF}
      FWorkingTCPClient := FPrivateTCPClient;
      end;
    end;
  if not FWorkingTCPClient.Connected then
    begin
    FWorkingTCPClient.Connect;
    end;
end;

procedure TIdSoapClientTCPIP.DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string);
const ASSERT_LOCATION = 'IdSoapClientTCPIP.TIdSoapClientTCPIP.DoSoapRequest';
var
  LStreamLen : integer;
  LMimeLen : integer;
begin
  assert(Self.TestValid(TIdSoapClientTCPIP), ASSERT_LOCATION+'['+Name+'].DoSoapRequest: self is not valid');
  assert(ASoapAction <> '', ASSERT_LOCATION+'['+Name+'].DoSoapRequest: SoapAction not provided');
  assert(ARequestMimeType <> '', ASSERT_LOCATION+'['+Name+']: RequestMimeType not provided');
  assert(Assigned(ARequest), ASSERT_LOCATION+'['+Name+'].DoSoapRequest: Request not valid');
  assert(Assigned(AResponse), ASSERT_LOCATION+'['+Name+'].DoSoapRequest: Response not valid');
  assert(FSoapHost <> '', ASSERT_LOCATION+'['+Name+'].DoSoapRequest: Soap Host is not valid');
  assert(FSoapPort <> 0, ASSERT_LOCATION+'['+Name+'].DoSoapRequest: Soa Port is not valid');
  assert(FSoapTimeout > 10, ASSERT_LOCATION+'['+Name+'].DoSoapRequest: Soap Timeout is not valid');
  GetWorkingTCPClient;
  assert(Assigned(FWorkingTCPClient), ASSERT_LOCATION+'['+Name+'].DoSoapRequest: HTTPClient not valid in');
  FWorkingTCPClient.OpenWriteBuffer;
  try
    FWorkingTCPClient.WriteInteger(ID_SOAP_TCPIP_MAGIC_REQUEST);
    inc(FNextPacketID);
    FWorkingTCPClient.WriteInteger(FNextPacketID);
    if FSuppressMimeType then
      begin
      FWorkingTCPClient.WriteInteger(0);
      FWorkingTCPClient.WriteInteger(ARequest.Size);
      end
    else
      begin
      FWorkingTCPClient.WriteInteger(length(ARequestMimeType));
      FWorkingTCPClient.WriteInteger(ARequest.Size);
      FWorkingTCPClient.Write(ARequestMimeType);
      end;
    FWorkingTCPClient.WriteStream(ARequest);
    FWorkingTCPClient.WriteInteger(ID_SOAP_TCPIP_MAGIC_FOOTER);
    FWorkingTCPClient.FlushWriteBuffer;
  finally
    FWorkingTCPClient.CloseWriteBuffer;
  end;

  // packet is sent
  // wait for response
  FWorkingTCPClient.ReadFromStack(true, FSoapTimeout, true);
  IdRequire(FWorkingTCPClient.ReadInteger = ID_SOAP_TCPIP_MAGIC_RESPONSE, 'IdSoapClientTCPIP.TIdSoapClientTCPIP.DoSoapRequest: Unexpected Network traffic');
  IdRequire(FWorkingTCPClient.ReadInteger = FNextPacketID, 'IdSoapClientTCPIP.TIdSoapClientTCPIP.DoSoapRequest: Wrong Packet ID');
  LMimeLen := FWorkingTCPClient.ReadInteger;
  LStreamLen := FWorkingTCPClient.ReadInteger;
  VResponseMimeType := FWorkingTCPClient.ReadString(LMimeLen);
  FWorkingTCPClient.ReadStream(AResponse, LStreamLen);
  AResponse.position := 0;
  IdRequire(FWorkingTCPClient.ReadInteger = ID_SOAP_TCPIP_MAGIC_FOOTER, 'IdSoapClientTCPIP.TIdSoapClientTCPIP.DoSoapRequest: Packet termination error');
end;

procedure TIdSoapClientTCPIP.Stop;
begin
  inherited;
  if assigned(FPrivateTCPClient) then
    begin
    FreeAndNil(FPrivateTCPClient);
    FWorkingTCPClient := nil;
    end;
end;

function TIdSoapClientTCPIP.GetWSDLLocation: string;
begin
  result := 'idsoaptcp:'+FSoapHost+':'+IntToStr(FSoapPort);
end;

procedure TIdSoapClientTCPIP.ClearCookie(AName: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapClientTCPIP does not support cookie based sessions');
end;

procedure TIdSoapClientTCPIP.SetCookie(AName, AContent: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapClientTCPIP does not support cookie based sessions');
end;

procedure TIdSoapClientTCPIP.SetCompression(const Value: boolean);
const ASSERT_LOCATION = 'IdSoapClientTCPIP.TIdSoapClientTCPIP.DoSoapRequest';
begin
  assert(not assigned(FWorkingTCPClient), ASSERT_LOCATION+': cannot change compression setting while client is active');
  {$IFDEF ID_SOAP_COMPRESSION}
  FCompression := Value;
  {$ELSE}
  raise Exception.create(ASSERT_LOCATION+': Compression has been turned off in the compiler defines (see IdSoapDefines.inc)');
  {$ENDIF}
end;

end.

