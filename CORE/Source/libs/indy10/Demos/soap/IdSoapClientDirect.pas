{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15694: IdSoapClientDirect.pas 
{
{   Rev 1.2    20/6/2003 00:02:24  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:02:06  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:31:46  GGrieve
}
{
IndySOAP: This unit defines A SoapClient that uses a SoapServer directly

}

{
Version History:
  19-Jun 2003   Grahame Grieve                  add wait for view packet
  18-Mar 2003   Grahame Grieve                  Remove Assert in notify event
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Jul 2002   Grahame Grieve                  Add GetWSDLLocation
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing compiler warnings
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings where appropriate
  09-Apr 2002   Andrew Cumming                  Added conditional code for debugging
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  24-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapClientDirect;

{.$.DEFINE ID_SOAP_VIEW_PACKET_REQUEST}
{.$.DEFINE ID_SOAP_VIEW_PACKET_RESPONSE}
{.$.DEFINE ID_SOAP_VIEW_PACKET_WAIT}      // only define this if it's the main thread - (mostly for DUnit testing)

{$IFDEF ID_SOAP_VIEW_PACKET_REQUEST}
  {$DEFINE ID_SOAP_VIEW_PACKET}
{$ENDIF}
{$IFDEF ID_SOAP_VIEW_PACKET_RESPONSE}
  {$DEFINE ID_SOAP_VIEW_PACKET}
{$ENDIF}

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapClient,
  IdSoapDebug,
  IdSoapITIProvider,
  IdSoapRequestInfo,
  IdSoapServer;

type
  TIdSoapRequestInformationDirect = class (TIdSoapRequestInformation);

  TIdSoapClientDirect = Class (TIdSoapBaseClient)
  private
    FSoapServer : TIdSoapServer;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string); override;
    function GetTransportDefaultEncodingType: TIdSoapEncodingType; override;
    function  GetWSDLLocation : string; override;
    procedure SetCookie(AName, AContent : string); override;
    procedure ClearCookie(AName : string);  override;
  published
    property SoapServer : TIdSoapServer read FSoapServer write FSoapServer;
  end;

implementation

uses
{$IFDEF ID_SOAP_VIEW_PACKET_WAIT}
  Dialogs,
{$ENDIF}
  IdSoapConsts,
  IdSoapExceptions,
{$IFDEF ID_SOAP_VIEW_PACKET}
  IdSoapTestingUtils,
{$ENDIF}
  IdSoapUtilities,
  SysUtils;

{ TIdSoapClientDirect }

procedure TIdSoapClientDirect.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = 'IdSoapClientDirect.TIdSoapClientDirect.Notification';
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FSoapServer then
      begin
      FSoapServer := nil;
      end;
    end;
end;

function TIdSoapClientDirect.GetTransportDefaultEncodingType: TIdSoapEncodingType;
const ASSERT_LOCATION = 'IdSoapClientDirect.TIdSoapClientDirect.GetTransportDefaultEncodingType';
begin
  result := etIdBinary;
end;

procedure TIdSoapClientDirect.DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string);
const ASSERT_LOCATION = 'IdSoapClientDirect.TIdSoapClientDirect.DoSoapRequest';
var
  LRequestInfo : TIdSoapRequestInformationDirect;
begin
  assert(Self.TestValid(TIdSoapClientDirect), ASSERT_LOCATION+': DoSoapRequest: self is not valid');
  assert(ASoapAction <> '', ASSERT_LOCATION+'["'+Name+'"]: DoSoapRequest: SoapAction not provided');
  assert(ARequestMimeType <> '', ASSERT_LOCATION+'['+Name+']: RequestMimeType not provided');
  assert(Assigned(ARequest), ASSERT_LOCATION+'["'+Name+'"]: DoSoapRequest: Request not valid');
  assert(Assigned(AResponse), ASSERT_LOCATION+'["'+Name+'"]: DoSoapRequest: Response not valid');
  assert(FSoapServer.TestValid(TIdSoapServer), ASSERT_LOCATION+'["'+Name+'"]: SoapServer is not valid');
{$IFDEF ID_SOAP_VIEW_PACKET_REQUEST}
  IdSoapViewStream(ARequest, 'xml');                      { do not localize }
  ARequest.position := 0;
{$IFDEF ID_SOAP_VIEW_PACKET_WAIT}
  showmessage('Continue?');
{$ENDIF}
{$ENDIF}
  LRequestInfo := TIdSoapRequestInformationDirect.create;
  try
    LRequestInfo.ClientCommsSecurity := ccAuthenticated;
    LRequestInfo.CommsType := cctDirect;
    GIdSoapRequestInfo := LRequestInfo;
    try
      FSoapServer.HandleSoapRequest(ARequestMimeType, nil, ARequest, AResponse, VResponseMimeType);
    finally
      GIdSoapRequestInfo := nil;
    end;
  finally
    FreeAndNil(LRequestInfo);
  end;
  AResponse.position := 0;
{$IFDEF ID_SOAP_VIEW_PACKET_RESPONSE}
  IdSoapViewStream(AResponse, 'xml');                     { do not localize }
  AResponse.position := 0;
{$IFDEF ID_SOAP_VIEW_PACKET_WAIT}
  showmessage('Continue?');
{$ENDIF}
{$ENDIF}
end;


function TIdSoapClientDirect.GetWSDLLocation: string;
begin
  result := 'urn:direct';
end;

procedure TIdSoapClientDirect.ClearCookie(AName: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapClientDirect does not support cookie based sessions');
end;

procedure TIdSoapClientDirect.SetCookie(AName, AContent: string);
begin
  raise EIdSoapRequirementFail.create('TIdSoapClientDirect does not support cookie based sessions');
end;

end.

