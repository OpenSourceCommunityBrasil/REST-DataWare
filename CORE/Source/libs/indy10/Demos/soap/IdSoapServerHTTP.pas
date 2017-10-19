{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15774: IdSoapServerHTTP.pas 
{
{   Rev 1.2    20/6/2003 00:04:32  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:03:58  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:36:36  GGrieve
}
{
IndySOAP: HTTP Server Transport Implementation

To use this, set up like a normal HTTP Server, and then
assign values to the following properties:

* SOAPPath - The URL for SOAP Services (usually is /SOAP -default value)
* WSDLPath - The URL for WSDL generation (usually is /WSDL -default value)
* SOAPServer - a TIdSOAPServerHTTP object to provide the actual services.

It is planned to rework these properties so that more than one SoapServer
can be associated with a single TIdSOAPServerHTTP

2 new events are provided by this Server.

  OnPreExecute  - called before every request - to allow security checking, etc
                   set VHandled to true, and this server will assume that you
                   have handled the response
  OnNonSOAPExecute - called if a non-Soap request is received, to allow a normal
                     web server to co-exist with the SOAP Server
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Compression
  18-Mar 2003   Grahame Grieve                  Remove assert in notify event
  26-Sep 2002   Grahame Grieve                  Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  22-Jul 2002   Grahame Grieve                  remove double up on Port in WSDL generation
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  05-Apr 2002   Grahame Grieve                  Fix Mime Type handling
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  03-Apr 2002   Grahame Grieve                  Fix Content Type and Indy HTTP bug
  02-Apr 2002   Grahame Grieve                  Fix Content-Type in returned message
  26-Mar 2002   Grahame Grieve                  Publish properties, rename constants
  22-Mar 2002   Grahame Grieve                  WSDL Location Support
  22-Mar 2002   Grahame Grieve                  Fix WSDL prefix handling
  15-Mar 2002   Grahame Grieve                  Fix bug in NonSoapExecute event declaration
  14-Mar 2002   Grahame Grieve                  Support for TIdSoapRequestInformation
   8-Mar 2002   Andrew Cumming                  Made D4/D5 compatible
   7-Mar 2002   Grahame Grieve                  Review assertions
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release
}

unit IdSoapServerHTTP;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdCustomHTTPServer,
  IdSoapRequestInfo,
  IdSoapServer,
  IdTCPServer;

type
  TIdSoapRequestInformationHTTP = class (TIdSoapRequestInformation)
  private
    FRequestInfo: TIdHTTPRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;
    FThread: TIdPeerThread;
  public
    property Thread : TIdPeerThread read FThread write FThread;
    Property RequestInfo : TIdHTTPRequestInfo read FRequestInfo write FRequestInfo;
    property ResponseInfo: TIdHTTPResponseInfo read FResponseInfo write FResponseInfo;
  end;

  TIdSOAPPreExecuteEvent = procedure(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo;
    AResponseInfo: TIdHTTPResponseInfo; var VHandled: Boolean) of object;

  TIdSoapIndyCookieIntf = class (TIdSoapAbstractCookieIntf)
  private
    FRequestInfo: TIdHTTPRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;
  public
    constructor create(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function GetCookie(Const AName : string) : string; override;
    procedure SetCookie(Const AName, AValue : string); override;
  end;

  TIdSOAPServerHTTP = class(TIdCustomHTTPServer)
  private
    FCompression: Boolean;
    procedure SetCompression(const AValue: Boolean);
  Protected
    FOnPreExecute: TIdSOAPPreExecuteEvent;
    FOnNonSOAPExecute: TIdHTTPGetEvent;
    FSOAPPath: String;
    FWSDLPath: String;
    FSoapServer: TIdSOAPServer;
    procedure CreatePostStream(ASender: TIdPeerThread; var VPostStream: TStream); Override;
    procedure DoCommandGet(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo); Override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); Override;
  Public
    constructor Create(AOwner: TComponent); Override;
  Published
    property SOAPPath: String Read FSOAPPath Write FSOAPPath;
    property SOAPServer: TIdSOAPServer Read FSoapServer Write FSoapServer;
    property WSDLPath: String Read FWSDLPath Write FWSDLPath;
    property OnPreExecute: TIdSOAPPreExecuteEvent Read FOnPreExecute Write FOnPreExecute;
    property OnNonSOAPExecute: TIdHTTPGetEvent Read FOnNonSOAPExecute Write FOnNonSOAPExecute;
    property Compression : Boolean read FCompression write SetCompression;
  end;

implementation

uses
  IdCookie,
  IdSoapConsts,
  IdSoapUtilities,
  SysUtils;

{ TIdSOAPServerHTTP }

constructor TIdSOAPServerHTTP.Create;
const ASSERT_LOCATION = 'IdSoapServerHTTP.TIdSOAPServerHTTP.Create';
begin
  inherited Create(AOwner);
  FOkToProcessCommand := True;
  FSOAPPath := ID_SOAP_DEFAULT_SOAP_PATH;
  FWSDLPath := ID_SOAP_DEFAULT_WSDL_PATH;
end;

procedure TIdSOAPServerHTTP.CreatePostStream(ASender: TIdPeerThread; var VPostStream: TStream);
const ASSERT_LOCATION = 'IdSoapServerHTTP.TIdSOAPServerHTTP.CreatePostStream';
begin
  VPostStream := TIdMemoryStream.Create;
end;

procedure TIdSOAPServerHTTP.DoCommandGet(AThread: TIdPeerThread; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
const ASSERT_LOCATION = 'IdSoapServerHTTP.TIdSOAPServerHTTP.DoCommandGet';
var
  LHandled: Boolean;
  LSoapRequestInfo : TIdSoapRequestInformationHTTP;
  LContentType : string;
  LCookieIntf : TIdSoapIndyCookieIntf;
  LNoCompression : Boolean;
begin
  assert(assigned(Self), ASSERT_LOCATION+': self not valid');
  assert(assigned(AThread), ASSERT_LOCATION+': AThread not valid');
  assert(assigned(ARequestInfo), ASSERT_LOCATION+': ARequestInfo not valid');
  assert(assigned(AResponseInfo), ASSERT_LOCATION+': AResponseInfo not valid');
  LHandled := False;
  LNoCompression := false;

  AResponseInfo.LastModified := -1;
  LSoapRequestInfo := TIdSoapRequestInformationHTTP.create;
  try
    LSoapRequestInfo.CommsType := cctHTTP;
    LSoapRequestInfo.ClientCommsSecurity := ccsInsecure;
    LSoapRequestInfo.FRequestInfo := ARequestInfo;
    LSoapRequestInfo.FResponseInfo := AResponseInfo;
    LSoapRequestInfo.FThread := AThread;
    if ARequestInfo.ContentEncoding = ID_SOAP_HTTP_DEFLATE then
      begin
      ZDeCompressStream(ARequestInfo.PostStream as TMemoryStream);
      end;

    GIdSoapRequestInfo := LSoapRequestInfo;
    try
      if assigned(FOnPreExecute) then
        begin
        FOnPreExecute(AThread, ARequestInfo, AResponseInfo, LHandled);
        end;
      if not LHandled then
        begin
        if AnsiSameText(ARequestInfo.Document, FSOAPPath) then
          begin
          Assert(FSoapServer.TestValid, ASSERT_LOCATION+': No Valid Soap Server Could be found');
          ARequestInfo.PostStream.Position := 0;
          AResponseInfo.ContentStream := TIdMemoryStream.Create;
          LCookieIntf := TIdSoapIndyCookieIntf.create(ARequestInfo, AResponseInfo);
          try
            GIdSoapRequestInfo.CookieServices := LCookieIntf;
            if FSoapServer.HandleSoapRequest(ARequestInfo.ContentType, LCookieIntf, ARequestInfo.PostStream, AResponseInfo.ContentStream, LContentType) then
              begin
              AResponseInfo.ResponseNo := 200;
              end
            else
              begin
              AResponseInfo.ResponseNo := 500;
              end;
          finally
            FreeAndNil(LCookieIntf);
          end;
          AResponseInfo.ContentType := LContentType;
          end
        else if AnsiSameText(copy(ARequestInfo.Document, 1, length(FWSDLPath)), FWSDLPath) then
          begin
          LNoCompression := true;
          Assert(FSoapServer.TestValid, ASSERT_LOCATION+': No Valid Soap Server Could be found');
          AResponseInfo.ContentStream := TMemoryStream.create;
          FSoapServer.GenerateWSDLPage(FWSDLPath, copy(ARequestInfo.Document, length(FWSDLPath)+1, length(ARequestInfo.Document)),
                                       'http://'+ARequestInfo.Host+FSOAPPath, AResponseInfo.ContentStream, LContentType);// do not localise
          AResponseInfo.ContentType := LContentType;
          end
        else
          begin
          if Assigned(FOnNonSOAPExecute) then
            begin
            // add LNoCompression to parameter list
            FOnNonSOAPExecute(AThread, ARequestInfo, AResponseInfo)
            end
          else
            begin
            // encourage a hacker to investigate passwords to no avail ;-)
            LNoCompression := true;
            AResponseInfo.ResponseNo := 404;
            AResponseInfo.ResponseText := 'Access Denied';  // do not localise
            AResponseInfo.ContentText := 'Access Denied';   // do not localise
            AResponseInfo.CloseConnection := True;
            end;
          end
        end;
      if FCompression and not LNoCompression then
        begin
        ZCompressStream(AResponseInfo.ContentStream as TMemoryStream);
        AResponseInfo.ContentEncoding := ID_SOAP_HTTP_DEFLATE;
        end;
    finally
      GIdSoapRequestInfo := nil;
    end;
  finally
    FreeAndNil(LSoapRequestInfo)
  end;
end;

procedure TIdSoapServerHTTP.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = 'IdSoapServerHTTP.TIdSoapServerHTTP.Notification';
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

procedure TIdSOAPServerHTTP.SetCompression(const AValue: Boolean);
const ASSERT_LOCATION = 'IdSoapServerHTTP.TIdSoapServerHTTP.SetCompression';
begin
  IdRequire(ZLibSupported, ASSERT_LOCATION+': Compression has been turned off in the compiler defines (see IdSoapDefines.inc)');
  FCompression := AValue;
end;

{ TIdSoapIndyCookieIntf }

constructor TIdSoapIndyCookieIntf.create(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  inherited create;
  FRequestInfo := ARequestInfo;
  FResponseInfo := AResponseInfo;
end;

function TIdSoapIndyCookieIntf.GetCookie(const AName: string): string;
var
  LCookie : TIdNetscapeCookie;
begin
  LCookie := FRequestInfo.Cookies.Cookie[AName];
  if assigned(LCookie) then
    begin
    result := LCookie.Value;
    end
  else
    begin
    result := '';
    end;
end;

procedure TIdSoapIndyCookieIntf.SetCookie(const AName, AValue: string);
begin
  FResponseInfo.Cookies.AddSrcCookie(AName+'='+AValue);
end;

end.
