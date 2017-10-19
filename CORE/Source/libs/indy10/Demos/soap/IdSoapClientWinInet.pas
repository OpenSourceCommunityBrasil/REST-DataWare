{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15700: IdSoapClientWinInet.pas 
{
{   Rev 1.2    23/6/2003 21:28:48  GGrieve
{ fix for Linux EOL issues
}
{
{   Rev 1.1    20/6/2003 00:02:36  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:32:06  GGrieve
}
{
IndySOAP: This unit defines a SoapClient that uses WinInet HTTP as the transport layer

  For simple use, just set the SoapURL.

  The point of this component is mainly that it uses the IE infrastructure,
  both the proxy settings and certificates, etc

}
{
Version History:
  23-Jun 2003   Grahame Grieve                  fix for EOL on Linux
  19-Jun 2003   Grahame Grieve                  Add Username and password (WinInet is only support for Digest Authentication)
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  27-Aug 2002   Grahame Grieve                  Fix for Linux
  16-Aug 2002   Grahame Grieve                  Fix SoapAction to have "" + fix several wininet issues
  15-Aug 2002   Grahame Grieve                  UseIEProxySettings defaults to true
  26-Jul 2002   Grahame Grieve                  Add GetWSDLLocation
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  05-Apr 2002   Grahame Grieve                  Fix assertions
  05-Apr 2002   Grahame Grieve                  Remove Hints and warnings
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  02-Apr 2002   Grahame Grieve                  First Written
}

unit IdSoapClientWinInet;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapClient,
  IdSoapDebug,
  IdSoapITIProvider,
  Windows;

type
  HInternet = pointer;
  INTERNET_PORT = Word;
  TInternetPort = INTERNET_PORT;

type
  TIdSoapClientWinInet = Class (TIdSoapWebClient)
  private
    FSession : pointer;
    FConnection : pointer;
    FUseIEProxySettings : boolean;
    FUserName: string;
    FPassword: string;

    procedure Connect(AProtocol, AServer, APort : string);
    procedure DoRequest(ASecure : boolean; APath : string; ASoapAction, AMimeType : string; ARequest, AResponse : TStream; Var VResponseMimeType : string);
    function  GetHeader(ARequest : HINTERNET; AHeader : DWord):string;
  protected
    procedure DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string); override;
    function GetTransportDefaultEncodingType: TIdSoapEncodingType; override;
    function  GetWSDLLocation : string; override;
    procedure SetCookie(AName, AContent : string); override;
    procedure ClearCookie(AName : string);  override;
    procedure SetSoapURL(const AValue: string);  override;
  public
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
    procedure DisConnect;
  published
    property UseIEProxySettings : boolean read FUseIEProxySettings write FUseIEProxySettings; // for testing, really. noramlly you'd leave this true
    property Username : string read FUserName write FUserName;
    property Password : string read FPassword write FPassword;
  end;

implementation

uses
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapITI,
  IdSoapResourceStrings,
  IdSoapTestingUtils,
  IdSoapUtilities,
  IdURI,
  SysUtils;

procedure WinInetCheck(ACondition : boolean; ALastError : DWord; ALocation, ADescription, ADetail : string);
begin
  if not ACondition then
    raise EIdSoapRequirementFail.create(ALocation+': '+ADescription+' ['+ADetail+'] failed with error '+inttostr(ALastError)+' ('+SysErrorMessage(ALastError)+')');
end;


{ WinInet interface }
{
adapted from Jedi. Thanks Jedi

Why not use jedi?

1. cross dependencies are a pain
2. Jedi Library is statically bound. No thanks

}


const
  DLL_WININET = 'wininet.dll';

  INTERNET_OPEN_TYPE_PRECONFIG                    = 0;   // use registry configuration
  INTERNET_OPEN_TYPE_DIRECT                       = 1;   // direct to net
  INTERNET_FLAG_SECURE            = $00800000;  // use PCT/SSL if applicable (HTTP)
  INTERNET_FLAG_KEEP_CONNECTION   = $00400000;  // use keep-alive semantics
  INTERNET_FLAG_NO_AUTO_REDIRECT  = $00200000;  // don't handle redirections automatically
  INTERNET_FLAG_NO_CACHE_WRITE    = $04000000;  // don't write this item to the cache
  INTERNET_FLAG_PRAGMA_NOCACHE    = $00000100;  // asking wininet to add "pragma: no-cache"
  HTTP_QUERY_CONTENT_TYPE         = 1;
  INTERNET_DEFAULT_HTTP_PORT      = 80;
  INTERNET_DEFAULT_HTTPS_PORT     = 443;
  INTERNET_SERVICE_HTTP           = 3;

type
  TInternetOpen = function(lpszAgent: PChar; dwAccessType: DWORD;
                            lpszProxy, lpszProxyBypass: PChar; dwFlags: DWORD): HInternet; stdcall;
  TInternetCloseHandle = function(hInternet: HINTERNET): BOOL; stdcall;
  TInternetConnect = function(hInternet: HINTERNET; lpszServerName: PChar;
                            nServerPort: TInternetPort; lpszUserName, lpszPassword: PChar;
                            dwService, dwFlags, dwContext: DWORD): HINTERNET; stdcall;
  THttpQueryInfo = function(hRequest: HINTERNET; dwInfoLevel: DWORD;
                            lpBuffer: Pointer; var lpdwBufferLength, lpdwIndex: DWORD): BOOL; stdcall;
  THttpOpenRequest = function(hConnect: HINTERNET; lpszVerb, lpszObjectName, lpszVersion,lpszReferrer: PChar;
                            lplpszAcceptTypes: PChar; dwFlags, dwContext: DWORD): HINTERNET; stdcall;
  THttpSendRequest = function(hRequest: HINTERNET; lpszHeaders: PChar; dwHeadersLength: DWORD;
                            lpOptional: Pointer; dwOptionalLength: DWORD): BOOL; stdcall;
  TInternetQueryDataAvailable = function (hFile: HINTERNET; var lpdwNumberOfBytesAvailable: DWORD;
                            dwFlags, dwContext: DWORD): BOOL; stdcall;
  TInternetReadFile = function (hFile: HINTERNET; lpBuffer: Pointer; dwNumberOfBytesToRead: DWORD;
                            var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;

var
  HDLL : THandle = 0;
  InternetOpen : TInternetOpen = nil;
  InternetCloseHandle : TInternetCloseHandle = nil;
  InternetConnect : TInternetConnect = nil;
  HttpQueryInfo : THttpQueryInfo = nil;
  HttpOpenRequest : THttpOpenRequest = nil;
  HttpSendRequest : THttpSendRequest = nil;
  InternetQueryDataAvailable : TInternetQueryDataAvailable = nil;
  InternetReadFile : TInternetReadFile = nil;

procedure LoadEntryPoint(Var VPointer : pointer; const AName : string);
const ASSERT_LOCATION = 'IdSoapClientWinInet.LoadEntryPoint';
begin
  VPointer := GetProcAddress(HDLL, pchar(AName));
  WinInetCheck(VPointer <> nil, GetLastError, ASSERT_LOCATION, RS_ERR_WININET_NO_ROUTINE, AName);
end;


procedure LoadWinInet;
const ASSERT_LOCATION = 'IdSoapClientWinInet.LoadWinInet';
begin
  if HDLL <> 0 then
    exit;
  HDLL := LoadLibrary(DLL_WININET);
  WinInetCheck(HDLL >= 32, GetLastError, ASSERT_LOCATION, RS_ERR_WININET_NO_DLL, DLL_WININET);
  LoadEntryPoint(@InternetOpen, 'InternetOpenA');              { do not localize }
  LoadEntryPoint(@InternetCloseHandle, 'InternetCloseHandle'); { do not localize }
  LoadEntryPoint(@InternetConnect, 'InternetConnectA');        { do not localize }
  LoadEntryPoint(@HttpQueryInfo, 'HttpQueryInfoA');            { do not localize }
  LoadEntryPoint(@HttpOpenRequest, 'HttpOpenRequestA');        { do not localize }
  LoadEntryPoint(@HttpSendRequest, 'HttpSendRequestA');        { do not localize }
  LoadEntryPoint(@InternetQueryDataAvailable, 'InternetQueryDataAvailable'); { do not localize }
  LoadEntryPoint(@InternetReadFile, 'InternetReadFile');       { do not localize }
end;

{ TIdSoapClientHTTP }

constructor TIdSoapClientWinInet.create;
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.create';
begin
  inherited;
  LoadWinInet;
  FUseIEProxySettings := true;
end;

destructor TIdSoapClientWinInet.destroy;
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.destroy';
begin
  assert(Self.TestValid(TIdSoapClientWinInet), ASSERT_LOCATION+': self is not valid');
  DisConnect;
  inherited;
end;

function TIdSoapClientWinInet.GetHeader(ARequest : HINTERNET; AHeader : DWord):string;
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.GetHeader';
var
  LMem : pointer;
  LSize : DWord;
  LIndex : DWord;
  LOk : boolean;
begin
  assert(Self.TestValid(TIdSoapClientWinInet), ASSERT_LOCATION+': self is not valid');
  // *$&%^ Microsoft - a static buffer. YUCK
  LSize := 1024;
  GetMem(LMem, LSize);
  try
    LIndex := 0;
    if not HttpQueryInfo(ARequest, AHeader, LMem, LSize, LIndex) then
      begin
      if GetLastError = ERROR_INSUFFICIENT_BUFFER then
        begin
        FreeMem(LMem);
        Getmem(LMem, LSize);
        LOk := HttpQueryInfo(ARequest, AHeader, LMem, LSize, LIndex);
        WinInetCheck(LOk, GetLastError, ASSERT_LOCATION, RS_OP_WININET_QUERY, '2'); { do not localize }
        end
      else
        begin
        WinInetCheck(False, GetLastError, ASSERT_LOCATION, RS_OP_WININET_QUERY, '1'); { do not localize }
        end;
      end;
    if LSize <> 0 then
      begin
      SetLength(result, LSize);
      move(LMem^, result[1], LSize);
      end
    else
      begin
      result := ''; { do not localize }
      end;
  finally
    FreeMem(LMem);
  end;
end;

procedure TIdSoapClientWinInet.DoRequest(ASecure : boolean; APath : string; ASoapAction, AMimeType : string; ARequest, AResponse : TStream; Var VResponseMimeType : string);
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.DoRequest';
var
  LReqHandle : HINTERNET;
  LHeaders : string;
  LData : Pointer;
  LSize : DWord;
  LOk : boolean;
  s : string;
begin
  assert(Self.TestValid(TIdSoapClientWinInet), ASSERT_LOCATION+': self is not valid');
  LHeaders :=
     ID_SOAP_HTTP_ACTION_HEADER+': "'+ASoapAction+'"'+EOL_PLATFORM+
     'Content-Type: '+ AMimeType +EOL_PLATFORM;                                          { do not localize }
  if ASecure then
    begin
    LReqHandle := HttpOpenRequest(FConnection, 'POST', PChar(APath), nil, nil, nil, INTERNET_FLAG_SECURE or INTERNET_FLAG_KEEP_CONNECTION or INTERNET_FLAG_NO_AUTO_REDIRECT or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_PRAGMA_NOCACHE, 0);{ do not localize }
    end
  else
    begin
    LReqHandle := HttpOpenRequest(FConnection, 'POST', PChar(APath), nil, nil, nil, INTERNET_FLAG_KEEP_CONNECTION or INTERNET_FLAG_NO_AUTO_REDIRECT or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_PRAGMA_NOCACHE, 0);{ do not localize }
    end;
  WinInetCheck(LReqHandle <> nil, GetLastError, ASSERT_LOCATION, RS_OP_WININET_REQ_OPEN, APath);
  try
    GetMem(LData, ARequest.size);
    try
      ARequest.Read(LData^, ARequest.Size);
      LOk := HttpSendRequest(LReqHandle, pchar(LHeaders), length(LHeaders), LData, ARequest.Size);
      WinInetCheck(LOk, GetLastError, ASSERT_LOCATION, RS_OP_WININET_REQ_SEND, APath);
    finally
      FreeMem(LData);
      end;
//    LOk := InternetQueryDataAvailable(LReqHandle, LSize, 0, 0);
//    WinInetCheck(LOk, GetLastError, ASSERT_LOCATION, RS_OP_WININET_QUERY, APath);
    AResponse.Size := 0;
    VResponseMimeType := GetHeader(LReqHandle, HTTP_QUERY_CONTENT_TYPE);
    repeat
      GetMem(LData, 1024);
      try
        FillChar(LData^, 1024, #0);
        LOk := InternetReadFile(LReqHandle, LData, 1024, LSize);
        WinInetCheck(LOk, GetLastError, ASSERT_LOCATION, RS_OP_WININET_READ, APath);
        if LSize > 0 then
          begin
          AResponse.Write(LData^, LSize);
          end;
      finally
        FreeMem(LData);
      end;
    until LOk and (LSize = 0);
    if Pos(';', VResponseMimeType) > 0 then
      begin
      s := copy(VResponseMimeType, 1, Pos(';', VResponseMimeType) - 1);
      end
    else
      begin
      s := VResponseMimeType;
      end;
    if (s <> ID_SOAP_HTTP_SOAP_TYPE) and (s <> ID_SOAP_HTTP_BIN_TYPE) then
      begin
      if AResponse.Size > 0 then
        begin
        AResponse.position := 0;
        SetLength(s, AResponse.Size);
        AResponse.Read(s[1], AResponse.Size);
        end;
      raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': '+RS_ERR_CLIENT_MIMETYPE +' "'+VResponseMimeType+'": "'+s+'"');
      end;
  finally
    InternetCloseHandle(LReqHandle);
  end;
end;

const
  ID_SOAP_USER_AGENT = 'IndySoap Ver '+ ID_SOAP_VERSION; { do not localize }

procedure TIdSoapClientWinInet.Connect(AProtocol, AServer, APort : string);
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.Connect';
var
  s : string;
begin
  assert(Self.TestValid(TIdSoapClientWinInet), ASSERT_LOCATION+': self is not valid');
  s := ID_SOAP_USER_AGENT;
  LoadWinInet;
  if FSession = nil then
    begin
    if FUseIEProxySettings then
      begin
      FSession := InternetOpen(pchar(s), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
      end
    else
      begin
      FSession := InternetOpen(pchar(s), INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
      end;
    WinInetCheck(FSession <> nil, GetLastError, ASSERT_LOCATION, RS_OP_WININET_CONNECT, AProtocol+'://'+AServer+':'+APort);
    end;
  if FConnection = nil then
    begin
    If AnsiSameText(AProtocol, 'https') then { do not localize }
      begin
      FConnection := InternetConnect(FSession, pchar(AServer), StrToIntDef(APort, INTERNET_DEFAULT_HTTPS_PORT), pChar(FUserName), pChar(FPassword), INTERNET_SERVICE_HTTP, 0, 0);
      end
    else
      begin
      FConnection := InternetConnect(FSession, pchar(AServer), StrToIntDef(APort, INTERNET_DEFAULT_HTTP_PORT), pChar(FUserName), pChar(FPassword), INTERNET_SERVICE_HTTP, 0, 0);
      end;
    WinInetCheck(FConnection <> nil, GetLastError, ASSERT_LOCATION, RS_OP_WININET_CONNECT, AProtocol+'://'+AServer+':'+APort);
    end;
end;

procedure TIdSoapClientWinInet.DisConnect;
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.DisConnect';
begin
  assert(Self.TestValid(TIdSoapClientWinInet), ASSERT_LOCATION+': self is not valid');
  InternetCloseHandle(FConnection);
  FConnection := nil;
  InternetCloseHandle(FSession);
  FSession := nil;
end;

procedure TIdSoapClientWinInet.DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string);
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.DoSoapRequest';
var
  LURL : TIdURI;
begin
  assert(Self.TestValid(TIdSoapClientWinInet), ASSERT_LOCATION+': self is not valid');
  assert(ASoapAction <> '', ASSERT_LOCATION+'['+Name+']: SoapAction not provided');
  assert(ARequestMimeType <> '', ASSERT_LOCATION+'['+Name+']: RequestMimeType not provided');
  assert(Assigned(ARequest), ASSERT_LOCATION+'['+Name+']: Request not valid');
  assert(Assigned(AResponse), ASSERT_LOCATION+'['+Name+']: Response not valid');

  assert((SoapURL <> '') and (SoapURL <> ID_SOAP_DEFAULT_SOAP_PATH), ASSERT_LOCATION+'['+Name+']: SoapPath not provided');

  LURL := TIdURI.create(SoapURL);
  try
    Connect(LURL.Protocol, LURL.Host, LURL.Port);
    DoRequest(AnsiSameText(LURL.Protocol, 'https'), LURL.Path+LURL.Document+LURL.Params, ASoapAction, ARequestMimeType, ARequest, AResponse, VResponseMimeType); { do not localize }
  finally
    FreeAndNil(LURL);
  end;
end;

function TIdSoapClientWinInet.GetTransportDefaultEncodingType: TIdSoapEncodingType;
const ASSERT_LOCATION = 'IdSoapClientWinInet.TIdSoapClientWinInet.GetTransportDefaultEncodingType';
begin
  assert(Self.TestValid(TIdSoapClientWinInet), ASSERT_LOCATION+': self is not valid');
  result := etIdXmlUtf8;
end;

function TIdSoapClientWinInet.GetWSDLLocation: string;
begin
  result := SoapURL;
end;

procedure TIdSoapClientWinInet.ClearCookie(AName: string);
begin
  // we are looking for someone to do this. when it's done, there is a suite of tests in idSoapRenamingtests that are not registered that should pass
  raise EIdUnderDevelopment.create('not done yet');
end;

procedure TIdSoapClientWinInet.SetCookie(AName, AContent: string);
begin
  // we are looking for someone to do this.
  raise EIdUnderDevelopment.create('not done yet');
end;

procedure TIdSoapClientWinInet.SetSoapURL(const AValue: string);
begin
  if not (AValue = SoapURL) then
    begin
    //Should disconnect any existing connection.
    Disconnect;
    inherited;
    end
end;

end.




