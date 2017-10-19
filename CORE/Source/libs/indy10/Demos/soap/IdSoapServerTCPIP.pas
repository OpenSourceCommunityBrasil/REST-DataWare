{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15776: IdSoapServerTCPIP.pas 
{
{   Rev 1.2    20/6/2003 00:04:36  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:04:02  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:36:42  GGrieve
}
{
IndySOAP: TCPIP Transport Server Implementation

Custom TCP/IP protocol. Requires IndySoap on both client and server. There is
no commitment to keeping this protocol abckwards compatible. You should only
use it where both client and server can be upgraded together

Network protocol for request:

ID   Block                  Size        Description
#1  Header                 4 bytes     IndySoap Identifier - IDSQ
#2  PacketID               4 bytes     Serially incrementing number for each request
#3  Method Name Length     4 bytes     Length of Method Name String
#4  Packet Length          4 bytes     Length of IndySoap Packet
#5  Method Name            see #3      Name of method
#6  Packet                 see #4      Actual IndySoap Packet
#7  Footer                 4 bytes     IndySoap Identifier - IDSE

Network protocol for response:
ID   Block                  Size        Description
#1  Header                 4 bytes     IndySoap Identifier - IDSA
#2  PacketID               4 bytes     PacketID of request packet that this response matches
#3  Packet Length          4 bytes     Length of IndySoap Packet
#4  Packet                 see #3      Actual IndySoap Packet
#5  Footer                 4 bytes     IndySoap Identifier - IDSE

}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Compression
  18-Mar 2003   Grahame Grieve                  Remove assert in notify event
  04-Oct 2002   Grahame Grieve                  Suppress MimeType - precursor to proper system for shrinking packets
  26-Sep 2002   Grahame Grieve                  Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  26-Mar 2002   Grahame Grieve                  remove warnings
  18-Mar 2002   Andrew Cumming                  Fixed for D4/D5 compatibility
  15-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapServerTCPIP;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapRequestInfo,
  IdSoapServer,
  IdTCPServer;

type
  TIdSoapRequestInformationTCPIP = class (TIdSoapRequestInformation)
  private
    FThread: TIdPeerThread;
  public
    property Thread : TIdPeerThread read FThread write FThread;
  end;

  TIdSoapTCPIPPreExecuteOutcome = (peoNotHandled, peoWriteStream, peoHandled);

  TIdSOAPPreExecuteTCPIPEvent = procedure (AThread: TIdPeerThread; const AInMimeType : string; ARequest, AResponse : TStream; var VOutMimeType : string; var VOutcome: TIdSoapTCPIPPreExecuteOutcome) of object;

  TIdSOAPServerTCPIP = class(TIdTCPServer)
  private
    FSuppressMimeType: boolean;
    FCompression: boolean;
    procedure SetCompression(const Value: boolean);
  protected
    FSoapServer: TIdSOAPServer;
    FOnPreExecute: TIdSOAPPreExecuteTCPIPEvent;
    procedure ReadRequest(AThread: TIdPeerThread);
    function DoExecute(AThread: TIdPeerThread): boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); Override;
  published
    property Compression : boolean read FCompression write SetCompression;
    property OnPreExecute: TIdSOAPPreExecuteTCPIPEvent Read FOnPreExecute Write FOnPreExecute;
    property SOAPServer: TIdSOAPServer Read FSoapServer Write FSoapServer;
    property SuppressMimeType : boolean read FSuppressMimeType write FSuppressMimeType;
  end;

implementation

uses
  {$IFDEF ID_SOAP_COMPRESSION}
  IdCompressionIntercept,
  {$ENDIF}
  IdSoapConsts,
  IdSoapResourceStrings,
  IdSoapUtilities,
  SysUtils;

{ TIdSOAPServerTCPIP }

procedure TIdSOAPServerTCPIP.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = 'IdSoapServerTCPIP.TIdSOAPServerTCPIP.Notification';
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FSoapServer then
      begin
      FSoapServer := NIL;
      end;
    end;
end;

procedure TIdSOAPServerTCPIP.ReadRequest(AThread: TIdPeerThread);
const ASSERT_LOCATION = 'IdSoapServerTCPIP.TIdSOAPServerTCPIP.ReadRequest';
var
  LPacketID : cardinal;
  LMimeTypeLen : cardinal;
  LPacketLen : cardinal;
  LInMimeType : string;
  LOutMimeType : string;
  LRequest : TIdMemoryStream;
  LResponse : TIdMemoryStream;
  LOutcome : TIdSoapTCPIPPreExecuteOutcome;
begin
  LPacketID := AThread.Connection.ReadInteger;
  LMimeTypeLen := AThread.Connection.ReadInteger;
  IdRequire(LMimeTypeLen < ID_SOAP_MAX_MIMETYPE_LENGTH, ASSERT_LOCATION+': '+Format(RS_ERR_TCPIP_TOO_LONG, ['Method']));
  LPacketLen := AThread.Connection.ReadInteger;
  IdRequire(LPacketLen < ID_SOAP_MAX_PACKET_LENGTH, ASSERT_LOCATION+': '+Format(RS_ERR_TCPIP_TOO_LONG, ['Packet']));
  LInMimeType := AThread.Connection.ReadString(LMimeTypeLen);
  LOutMimeType := ID_SOAP_HTTP_BIN_TYPE;
  LRequest := TIdMemoryStream.create;
  try
    AThread.Connection.ReadStream(LRequest, LPacketLen);
    IdRequire(AThread.Connection.ReadInteger = ID_SOAP_TCPIP_MAGIC_FOOTER, ASSERT_LOCATION+': Footer not found');
    LRequest.Position := 0;
    LResponse := TIdMemoryStream.create;
    try
      LOutcome := peoNotHandled;
      if Assigned(FOnPreExecute) then
        begin
        FOnPreExecute(AThread, LInMimeType, LRequest, LResponse, LOutMimeType, LOutcome);
        end;
      if LOutcome = peoNotHandled then
        begin
        Assert(FSoapServer.TestValid, ASSERT_LOCATION+': Soap Server not valid');
        FSoapServer.HandleSoapRequest(LInMimeType, nil, LRequest, LResponse, LOutMimeType);
        end;
      if LOutcome <> peoHandled then
        begin
        LResponse.position := 0;
        AThread.Connection.OpenWriteBuffer;
        try
          AThread.Connection.WriteInteger(ID_SOAP_TCPIP_MAGIC_RESPONSE);
          AThread.Connection.WriteInteger(LPacketID);
          if FSuppressMimeType then
            begin
            AThread.Connection.WriteInteger(0);
            AThread.Connection.WriteInteger(LResponse.Size);
            end
          else
            begin
            AThread.Connection.WriteInteger(length(LOutMimeType));
            AThread.Connection.WriteInteger(LResponse.Size);
            AThread.Connection.Write(LOutMimeType);
            end;
          AThread.Connection.WriteStream(LResponse);
          AThread.Connection.WriteInteger(ID_SOAP_TCPIP_MAGIC_FOOTER);
          AThread.Connection.FlushWriteBuffer;
        finally
          AThread.Connection.CloseWriteBuffer;
        end;
        end;
    finally
      FreeAndNil(LResponse);
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

function TIdSOAPServerTCPIP.DoExecute(AThread: TIdPeerThread): boolean;
const ASSERT_LOCATION = 'IdSoapServerTCPIP.TIdSOAPServerTCPIP.DoExecute';
var
  LRequestInfo : TIdSoapRequestInformationTCPIP;
begin
  result := true;
  Assert(assigned(AThread), ASSERT_LOCATION+': Thread is not assigned');
  LRequestInfo := TIdSoapRequestInformationTCPIP.create;
  try
    LRequestInfo.ClientCommsSecurity := ccsInsecure;
    LRequestInfo.CommsType := cctTCPIP;
    LRequestInfo.Thread := AThread;
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

procedure TIdSOAPServerTCPIP.SetCompression(const Value: boolean);
const ASSERT_LOCATION = 'IdSoapServerTCPIP.TIdSOAPServerTCPIP.DoExecute';
begin
  Assert(not active, ASSERT_LOCATION+': cannot change the compression while the server is active');
  {$IFDEF ID_SOAP_COMPRESSION}
  FCompression := Value;
  Self.Intercept := TIdServerCompressionIntercept.create(nil);
  (Self.Intercept as TIdServerCompressionIntercept).CompressionLevel := 9;
  {$ELSE}
  raise Exception.create(ASSERT_LOCATION+': Compression has been turned off in the compiler defines (see IdSoapDefines.inc)');
  // but see note in idCompilerDefines.inc
  {$ENDIF}
end;

end.

