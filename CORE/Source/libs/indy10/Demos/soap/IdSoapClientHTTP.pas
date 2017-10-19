{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15696: IdSoapClientHTTP.pas 
{
{   Rev 1.1    20/6/2003 00:02:28  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:31:52  GGrieve
}
{
IndySOAP: This unit defines a SoapClient that uses HTTP as the transport layer

  For simple use, just set the SoapURL.

  If you want SSL support, session support, etc, set the HTTPClient
  to some real HTTPClient, and then this will be used.
}
{
Version History:
  19-Jun 2003   Grahame Grieve                  Compression, fix cookie bug
  29-Oct 2002   Grahame Grieve                  Remove misleading commeet
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Grahame Grieve                  Fix notification Bug
  16-Aug 2002   Grahame Grieve                  Fix SoapAction to have ""
  26-Jul 2002   Grahame Grieve                  Add GetWSDLLocation
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  05-Apr 2002   Grahame Grieve                  Handle MimeTypes properly
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  03-Apr 2002   Grahame Grieve                  handle borland soap sending text/xml instead of application/soap on error
  02-Apr 2002   Grahame Grieve                  Check content type with a Protocol Exception
  02-Apr 2002   Grahame Grieve                  Fix access violation using a TIdHTTP, support 500 errors in SOAP binding
  26-Mar 2002   Grahame Grieve                  Change names of constants
  15-Mar 2002   Grahame Grieve                  Use Constants for Soap Headers
   7-Mar 2002   Grahame Grieve                  Review assertions, add support for EncodingType
  03-Feb 2002   Andrew Cumming                  Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapClientHTTP;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdCookie,
  IdCookieManager,
  IdHTTP,
  IdSoapClient,
  IdSoapDebug,
  IdSoapITIProvider;

type
  TIdSoapClientHTTP = Class (TIdSoapWebClient)
  private
    FCookieManager : TIdCookieManager;
    FPrivateClient : TIdCustomHTTP;
    FWorkingHTTPClient : TIdCustomHTTP;
    FHTTPClient : TIdCustomHTTP;
    FCompression: Boolean;
    procedure GetWorkingHTTPClient;
    procedure SetCompression(const AValue: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string); override;
    function GetTransportDefaultEncodingType: TIdSoapEncodingType; override;
    function  GetWSDLLocation : string; override;
    procedure SetCookie(AName, AContent : string); override;
    procedure ClearCookie(AName : string);  override;
    procedure NewCookie(ASender: TObject; ACookie: TIdCookieRFC2109; Var VAccept: Boolean);
  public
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
  published
    property HTTPClient : TIdCustomHTTP read FHTTPClient write FHTTPClient;
    property Compression : Boolean read FCompression write SetCompression;
  end;

implementation

uses
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapITI,
  IdSoapUtilities,
  IdURI,
  SysUtils;

{ TIdSoapClientHTTP }

constructor TIdSoapClientHTTP.create;
const ASSERT_LOCATION = 'IdSoapClientHTTP.TIdSoapClientHTTP.create';
begin
  inherited;
  FWorkingHTTPClient := nil;
  FHTTPClient := nil;
  FPrivateClient := nil;
end;

destructor TIdSoapClientHTTP.destroy;
const ASSERT_LOCATION = 'IdSoapClientDirect.TIdSoapClientHTTP.destroy';
begin
  assert(Self.TestValid(TIdSoapClientHTTP), ASSERT_LOCATION+': self is not valid');
  inherited;
  if assigned(FPrivateClient) then
    begin
    FreeAndNil(FPrivateClient);
    end;
  FreeAndNil(FCookieManager);
end;

procedure TIdSoapClientHTTP.GetWorkingHTTPClient;
const ASSERT_LOCATION = 'IdSoapClientHTTP.TIdSoapClientHTTP.GetWorkingHTTPClient';
begin
  assert(Self.TestValid(TIdSoapClientHTTP), ASSERT_LOCATION+': self is not valid');
  if not assigned(FWorkingHTTPClient) then
    begin
    if assigned(FHTTPClient) then
      begin
      FWorkingHTTPClient := FHTTPClient;
      end
    else
      begin
      FPrivateClient := TIdCustomHTTP.create(nil);
      FPrivateClient.HandleRedirects := false;
      FWorkingHTTPClient := FPrivateClient;
      end;
    if (SessionSettings.SessionPolicy = sspCookies) then
      begin
      if not assigned(FWorkingHTTPClient.CookieManager) then
        begin
        FCookieManager := TIdCookieManager.create(nil);
        FWorkingHTTPClient.CookieManager := FCookieManager;
        end;
      FWorkingHTTPClient.CookieManager.OnNewCookie := NewCookie;
      end;
    end;
end;

procedure TIdSoapClientHTTP.DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string);
const ASSERT_LOCATION = 'IdSoapClientHTTP.TIdSoapClientHTTP.DoSoapRequest';
var
  LRespType : string;
  LJunk : string;
begin
  assert(Self.TestValid(TIdSoapClientHTTP), ASSERT_LOCATION+': self is not valid');
  assert(ASoapAction <> '', ASSERT_LOCATION+'['+Name+']: SoapAction not provided');
  assert(ARequestMimeType <> '', ASSERT_LOCATION+'['+Name+']: MimeType is empty');
  assert(Assigned(ARequest), ASSERT_LOCATION+'['+Name+']: Request not valid');
  assert(Assigned(AResponse), ASSERT_LOCATION+'['+Name+']: Response not valid');
  assert((SoapURL <> '') and (SoapURL <> ID_SOAP_DEFAULT_SOAP_PATH), ASSERT_LOCATION+'['+Name+']: SoapPath not provided');
  if not assigned(FWorkingHTTPClient) then
    begin
    GetWorkingHTTPClient;
    end;
  assert(Assigned(FWorkingHTTPClient), ASSERT_LOCATION+'['+Name+']: HTTPClient not valid');
  FWorkingHTTPClient.Request.CustomHeaders.Values[ID_SOAP_HTTP_ACTION_HEADER] := '"'+ASoapAction+'"';
  FWorkingHTTPClient.Request.ContentType := ARequestMimeType;
  if FCompression then
    begin
    FWorkingHTTPClient.Request.ContentEncoding := ID_SOAP_HTTP_DEFLATE;
    ZCompressStream(ARequest as TMemoryStream);
    end;
  try
    FWorkingHTTPClient.Post(SoapURL, ARequest, AResponse);
    AResponse.Position := 0;
    if FWorkingHTTPClient.Response.ContentEncoding = ID_SOAP_HTTP_DEFLATE then
      begin
      ZDeCompressStream(AResponse as TMemoryStream);
      end;
    VResponseMimeType := FWorkingHTTPClient.Response.ContentType;
  except
    on e:EIdHTTPProtocolException do
      begin
      LRespType := FWorkingHTTPClient.Response.ContentType;
      if Pos(';', LRespType) > 0 then
        begin
        SplitString(LRespType, ';', LRespType, LJunk);
        end;

      if  ( (LRespType = ID_SOAP_HTTP_SOAP_TYPE) or
            (LRespType = ID_SOAP_HTTP_BIN_TYPE) )
         and
           (length(e.ErrorMessage) > 0) then
        begin
        AResponse.Size := 0;
        AResponse.Write(e.ErrorMessage[1], length(e.ErrorMessage));
        AResponse.Position := 0;
        VResponseMimeType := FWorkingHTTPClient.Response.ContentType;
        end
      else
        raise;
      end;
    on e:exception do
      raise
    end;
end;

procedure TIdSoapClientHTTP.Notification(AComponent: TComponent; Operation: TOperation);
const ASSERT_LOCATION = 'IdSoapClientHTTP.TIdSoapClientHTTP.Notification';
begin
  inherited;
  if Operation = opRemove then
    begin
    if AComponent = FHTTPClient then
      begin
      FHTTPClient := nil;
      end;
    end;
end;

function TIdSoapClientHTTP.GetTransportDefaultEncodingType: TIdSoapEncodingType;
const ASSERT_LOCATION = 'IdSoapClientHTTP.TIdSoapClientHTTP.GetTransportDefaultEncodingType:';
begin
  assert(Self.TestValid(TIdSoapClientHTTP), ASSERT_LOCATION+': self is not valid');
  result := etIdXmlUtf8;
end;

function TIdSoapClientHTTP.GetWSDLLocation: string;
begin
  result := SoapURL;
end;

procedure TIdSoapClientHTTP.ClearCookie(AName: string);
var
  LIndex : integer;
begin
  GetWorkingHTTPClient;
  repeat
    LIndex := FWorkingHTTPClient.CookieManager.CookieCollection.GetCookieIndex(0, AName);
    if LIndex <> -1 then
      begin
      FWorkingHTTPClient.CookieManager.CookieCollection.Delete(LIndex);
      end
  until LIndex = -1;
end;

procedure TIdSoapClientHTTP.SetCookie(AName, AContent: string);
var
  LUri : TIdUri;
begin
  GetWorkingHTTPClient;
  LUri := TIdURI.create(SoapURL);
  try
    FWorkingHTTPClient.CookieManager.AddCookie(AName+'='+AContent, LUri.Host);
  finally
    FreeAndNil(LUri);
  end;
end;

procedure TIdSoapClientHTTP.NewCookie(ASender: TObject; ACookie: TIdCookieRFC2109; var VAccept: Boolean);
begin
  if not AddingCookie then
    begin
    if SessionSettings.AutoAcceptSessions and (ACookie.CookieName = SessionSettings.SessionName) then
      begin
      if ACookie.Value = '' then
        begin
        CloseSession();
        end
      else
        begin
        // we consider (for the moment) that the server only sends us a cookie instruction when we are to change.
        // this will renew the session whether the name is the same or not
        CreateSession(ACookie.Value, nil);
        end;
      end
    else
      begin
      VAccept := false;
      end;
    end;
  // workaround for a bug in some versions of indy.
  // all cookies must have a path, but are not created with a path
  if ACookie.Path = ''  then
    begin
    ACookie.Path := '/';
    end;
end;

procedure TIdSoapClientHTTP.SetCompression(const AValue: Boolean);
const ASSERT_LOCATION = 'IdSoapClientHTTP.TIdSoapClientHTTP.SetCompression:';
begin
  IdRequire(ZLibSupported, ASSERT_LOCATION+': Compression has been turned off in the compiler defines (see IdSoapDefines.inc)');
  FCompression := AValue;
end;

end.



