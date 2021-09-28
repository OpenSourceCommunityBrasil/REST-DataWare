{$WARNINGS OFF}
unit dwISAPIRunner;

{$I uRESTDW.inc}

interface

Uses
  {$IFDEF FPC}
   {$IFNDEF LAMW}
    LCL,
   {$ENDIF}
  {$ELSE}
   Windows,
  {$ENDIF} SysUtils,
  ISAPI2,
  uDWAbout,
  idTCPServer, idStack,
  idGlobal,
  idCustomHTTPServer,
  idHeaderList,
  IdHTTPServer,
  idStackWindows,
  idWinSock2,
  IdContext,
  IdGlobalProtocols,
  Classes;

const
  { Session support for ISAPI modules }
  HSE_REQ_IS_KEEP_CONN  =  (HSE_REQ_END_RESERVED+8);

type
  //TECB is an auxiliary class for implementation of ISAPI callback functions
  TECB=class
    public
      // This structure is used by IIS and the extension to exchange information
      ECB: TEXTENSION_CONTROL_BLOCK;
      KeepAlive : boolean;
      Runner : Pointer;
      DocumentRoot : string;
     {Email address of Server Administator (optional, for compatibility
      with Apache) }
      ServerAdmin : string;
      //Thread used for client connections.
      AThread: TIdContext;
      {RequestInfo - TIdHTTPRequestInfo publishes properties that provide
      access to various information for a HTTP request.
      The properties include the HTTP session, authentication parameters,
      the remote computer addresses, HTTP headers, cookies, the HTTP command
      and version, and the document URL for the request.}
      RequestInfo: TIdHTTPRequestInfo;
      {ResponseInfo - IdHTTPResponseInfo publishes properties that provide
      access to various information for a HTTP response.
      These properties include the HTTP session, the authentication realm,
      Cookies, Headers, and the response content, length, and type.}
      ResponseInfo: TIdHTTPResponseInfo;
      //Indy WebServer
      Server : TidHTTPServer;
      WaitEvent : THandle;
     //Allocates memory and constructs a safely initialized instance of a component.
      constructor Create;
      //Disposes of the component and its owned components.
      destructor  Destroy; override;
  end;

  TOnModuleState = procedure(Sender : TObject; AModuleName : string) of object;
  TOnExecuteEvent = procedure(Sender : TObject; RequestInfo : TidHTTPRequestInfo; ResponseInfo : TidHTTPResponseInfo) of object;
  TOnLogServerMessage = procedure(Sender : TObject; RequestInfo : TidHTTPrequestInfo; ResponseInfo : TidHTTPResponseInfo; AMessage : string) of object;

  {TidISAPIRunner component allows to execute ISAPI modules using
   Indy TidHTTPServer component}
  TDWISAPIRunner= Class(TDWComponent)
   private
     FOnLogServerMessage : TOnLogServerMessage;
     FOnModuleNotFound : TOnExecuteEvent;
     FOnISAPIStructureError :TOnExecuteEvent;
     FOnVersionInfoError : TOnExecuteEvent;
     FOnModuleLoad : TOnModuleState;
     FOnModuleUnload : TOnModuleState;
     FLibHandles: TStringList;
     FLibLock:TRTLCriticalSection;
     FBeforeExecute : TNotifyEvent;
     FAfterExecute : TNotifyEvent;
     FServer : TidHTTPServer;
     FServerAdmin : string;
     procedure SetServer(const AValue : TIdHTTPServer);
   protected
      //Forwards notification messages to all owned components.
      procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      procedure DoBeforeExecute; virtual;
      procedure DoAfterExecute; virtual;
      procedure DoModuleNotFound(RequestInfo : TidHTTPRequestInfo; ResponseInfo : TidHTTPResponseInfo); virtual;
   public
     //Allocates memory and constructs a safely initialized instance of a component.
     constructor Create(AOwner : TComponent); override;
     {Disposes of the component}
     destructor Destroy; override;
     {Unload ISAPI module}
     function UnloadDLL(const dllName: string; Ask : boolean = false):Boolean;
     {Load and execute ISAPI module and return result to WebServer
      dllName - the full local path to ISAPI  file
      e.g. c:\inetpub\wwwroot\scripts\myisapi.dll

      RequestInfo - TIdHTTPRequestInfo publishes properties that provide
      access to various information for a HTTP request.
      The properties include the HTTP session, authentication parameters,
      the remote computer addresses, HTTP headers, cookies, the HTTP command
      and version, and the document URL for the request.

      ResponseInfo - IdHTTPResponseInfo publishes properties that provide
      access to various information for a HTTP response.
      These properties include the HTTP session, the authentication realm,
      Cookies, Headers, and the response content, length, and type.

      Action - PathInfo of TWebActionItem of your ISAPI application

      DocumentRoot - server root folder. This variable can be different for
      special tasks and threads (for example: host aliases can have its own
      documentroot which are assigned in idhttpserver.oncommandGet).

      dllUnload - unload ISAPI module after using                         }
     procedure   Execute(const dllName: String; AThread: TIdContext;
                  RequestInfo: TIdHTTPRequestInfo;
                  ResponseInfo: TIdHTTPResponseInfo;
                  const DocumentRoot:string;
                  dllunload:boolean = false;
                  Action : string=''); virtual;
     //Indy TidHTTPServer
     property Server : TidHTTPServer read FServer write SetServer;
   published
     {Email address of Server Administator (optional, for compatibility
      with Apache) }
     property ServerAdmin : string read FServerAdmin write FServerAdmin;
     //Occurs before execute content produced
     property BeforeExecute : TNotifyEvent read FBeforeExecute write FBeforeExecute;
     //Occurs after content produced
     property AfterExecute : TNotifyEvent read FAfterExecute write FAfterExecute;
     //Ocurs when ISAPI DLL loaded by server
     property OnModuleLoad : TOnModuleState read FOnModuleLoad write FOnModuleLoad;
     //Occurs when ISAPI DLL was unloaded by server
     property OnModuleUnload : TOnModuleState read FOnModuleUnload write FOnModuleUnload;
     //Occurs when ISAPI DLL does not exists
     property OnModuleNotFound : TOnExecuteEvent read FOnModuleNotFound write FOnModuleNotFound;
     //Occurs when ISAPI DLL has wrong structure or it is not an ISAPI DLL
     property OnISAPIStructureError : TOnExecuteEvent read FOnISAPIStructureError write FOnISAPIStructureError;
     //
     property OnVersionInfoError : TOnExecuteEvent read FOnversionInfoError write FOnVersionInfoError;
     {You can use this event to write your own custom log strings to the log record.
     When this function is called, the string contained in the buffer you specify
     is appended to the log record for the current HTTP request}
     property OnLogServerMessage : TOnLogServerMessage read FOnLogServerMessage write FOnLogServerMessage;
   end;

 VersionFunc = function(var Ver: THSE_VERSION_INFO): Boolean; stdcall;
 ProcFunc = function(var ECB: TEXTENSION_CONTROL_BLOCK): LongInt; stdcall;

{The CBGetServerVariable function retrieves information about
an HTTP connection or about IIS itself.
Parameters:
ConnID - Specifies the connection handle.
VariableName - A null-terminated string that indicates which variable
is requested. The following table lists the possible variables.
Buffer - Points to the buffer to receive the requested information.
Size - Points to a DWORD that indicates the size of the buffer
pointed to by Buffer. On successful completion, the DWORD contains
the size of bytes transferred into the buffer, including the
null-terminating byte.}
function CBGetServerVariable(connID: HCONN; variableName: PChar; buffer: Pointer; var size: DWORD): Boolean; stdcall;

{The ServerSupportFunction is a callback function that is supplied in the
EXTENSION_CONTROL_BLOCK that is associated with the current HTTP request.
ServerSupportFunction can be used to perform a variety of tasks.}
function CBServerSupport(connID: HCONN; HSERRequest: DWORD; buffer: Pointer;  size: LPDWORD;  dataType: LPDWORD): Boolean; stdcall;

{The WriteClient function is a callback function that is supplied in the
EXTENSION_CONTROL_BLOCK for a request sent to the ISAPI extension.
It sends the data present in the given buffer to the client that made the
request.}
function CBWriteClient(connID: HCONN; buffer: Pointer; var Bytes: DWORD; dwReserved: DWORD): Boolean; stdcall;

//The CBReadClient function reads data from the body of the client's HTTP request
function CBReadClient(connID: HCONN; buffer: Pointer; var size: DWORD): Boolean; stdcall;

implementation

Uses uDWConstsData;

function AdjustHTTP(const Name: string): string;
  const
    SHttp = 'HTTP_';     { do not localize }
begin
    if Pos(SHttp, Name) = 1 then
      Result := Copy(Name, 6, MaxInt)
        else
          Result := Name;
end;

function CBGetServerVariable(connID: HCONN; variableName: PChar; buffer: Pointer; var size: DWORD): Boolean; stdcall;

const
 v_AUTH_TYPE = 1;
 v_AUTH_NAME = 2;
 v_AUTH_PASS = 3;
 v_CONTENT_LENGTH = 4;
 v_CONTENT_TYPE = 5;
 v_GATEWAY_INTERFACE = 6;
 v_PATH_INFO = 7;
 v_PATH_TRANSLATED = 8;
 v_QUERY_STRING = 9;
 v_REMOTE_ADDR = 10;
 v_REMOTE_HOST = 11;
 v_REMOTE_USER = 12;
 v_REQUEST_METHOD = 13;
 v_SCRIPT_NAME = 14;
 v_SERVER_NAME = 15;
 v_SERVER_PORT = 16;
 v_SERVER_PROTOCOL = 17;
 v_SERVER_SOFTWARE = 18;
 v_HTTP_COOKIE = 19;
 v_HTTP_USER_AGENT = 20;
 v_URL = 21;
 v_HTTP_CACHE_CONTROL = 22;
 v_HTTP_DATE = 23;
 v_HTTP_ACCEPT = 24;
 v_HTTP_FROM = 25;
 v_HTTP_HOST = 26;
 v_HTTP_IF_MODIFIED_SINCE = 27;
 v_HTTP_REFERER = 28;
 v_HTTP_CONTENT_ENCODING = 29;
 v_HTTP_CONTENT_VERSION = 30;
 v_HTTP_DERIVED_FROM = 31;
 v_HTTP_EXPIRES = 32;
 v_HTTP_TITLE = 33;
 v_HTTP_CONNECTION = 34;
 v_HTTP_AUTHORIZATION = 35;
 v_DOCUMENT_ROOT = 36;
 v_SERVER_ADMIN = 37;
 v_SERVER_ADDR = 38;
 v_HTTP_ACCEPT_LANGUAGE = 39;
 v_HTTP_ACCEPT_ENCODING = 40;
 v_HTTP_CLIENT_IP = 41;
 v_REDIRECT_STATUS = 42;
 v_HTTP_REDIRECT_STATUS = 43;
 v_REDIRECT_URL = 44;
 v_HTTP_IDSESSION = 45;

const
  VarNames : array[1..45] of string = (
  'AUTH_TYPE',               //1
  'AUTH_NAME',               //2
  'AUTH_PASS',               //3
  'CONTENT_LENGTH',          //4
  'CONTENT_TYPE',            //5
  'GATEWAY_INTERFACE',       //6
  'PATH_INFO',               //7
  'PATH_TRANSLATED',         //8
  'QUERY_STRING',            //9
  'REMOTE_ADDR',             //10
  'REMOTE_HOST',             //11
  'REMOTE_USER',             //12
  'REQUEST_METHOD',          //13
  'SCRIPT_NAME',             //14
  'SERVER_NAME',             //15
  'SERVER_PORT',             //16
  'SERVER_PROTOCOL',         //17
  'SERVER_SOFTWARE',         //18
  'HTTP_COOKIE',             //19
  'HTTP_USER_AGENT',         //20
  'URL',                     //21
  'HTTP_CACHE_CONTROL',      //22
  'HTTP_DATE',               //23
  'HTTP_ACCEPT',             //24
  'HTTP_FROM',               //25
  'HTTP_HOST',               //26
  'HTTP_IF_MODIFIED_SINCE',  //27
  'HTTP_REFERER',            //28
  'HTTP_CONTENT_ENCODING',   //29
  'HTTP_CONTENT_VERSION',    //30
  'HTTP_DERIVED_FROM',       //31
  'HTTP_EXPIRES',            //32
  'HTTP_TITLE',              //33
  'HTTP_CONNECTION',         //34
  'HTTP_AUTHORIZATION',      //35
  'DOCUMENT_ROOT',           //36
  'SERVER_ADMIN',            //37
  'SERVER_ADDR',             //38
  'HTTP_ACCEPT_LANGUAGE',    //39
  'HTTP_ACCEPT_ENCODING',    //40
  'HTTP_CLIENT_IP',          //41
  'REDIRECT_STATUS',         //42
  'HTTP_REDIRECT_STATUS',    //43
  'REDIRECT_URL',            //44
  'HTTP_IDSESSION');         //45 Indy Server Session

var
  Thread       : TIdContext;
  RequestInfo  : TIdHTTPRequestInfo;
  tmpS: String;
  Server       : TidHTTPServer;
  VarNum : integer;
  VarFound : boolean;

function GetFieldByName(AFieldName : string) : string;
begin
   Result := RequestInfo.RawHeaders.Values[AFieldName];
end;

function GetFieldByNameEx(AFieldName : string) : string;
var
 NewFieldName : string;
begin
  NewFieldName := AdjustHTTP(AFieldName);
   Result := RequestInfo.RawHeaders.Values[NewFieldName];
   if Result = '' then
    begin
      NewFieldName := StringReplace(NewFieldName,'_','-', [rfReplaceALL]);
      Result := RequestInfo.RawHeaders.Values[NewFieldName];
    end;
end;

begin
  Result:=True;
  thread:= TEcb(connID).AThread;
  RequestInfo := TEcb(connID).RequestInfo;
  Server := TECB(connID).Server;
  if (thread=nil) then
  begin
    Result:=False;
    Exit;
  end;

  varFound := False;

  for VarNum := 1 to 45 do
    begin
      if CompareText(VariableName, VarNames[VarNum]) = 0 then
       begin
         VarFound := true;
         break;
       end;
    end;

  if not VarFound then
   begin
     tmpS := GetFieldByNameEx(VariableName);
     if TmpS <> '' then
      begin
        tmpS := tmpS + #0;
        StrPCopy( PChar(buffer), PChar(tmpS) );
        size:=Length(tmpS);
      end
        else
          begin
            Result := false;
            StrPCopy(PChar(buffer), #0);
            Size := 0;
          end;
     Exit;
   end;

  case VarNum of
  v_AUTH_TYPE:
    begin
      StrPCopy( PChar(buffer), 'Basic'#0 );
      size:=Length('Basic'#0);
    end;

  v_AUTH_NAME:
     begin
       StrPCopy( PChar(buffer), PChar(RequestInfo.AuthUsername) );
       size:=Length(RequestInfo.AuthUsername);
     end;

  v_AUTH_PASS:
     begin
       StrPCopy( PChar(buffer), PChar(RequestInfo.AuthPassword) );
       size:=Length(RequestInfo.AuthPassword);
     end;

  v_CONTENT_LENGTH:
     begin
       if RequestInfo.RawHeaders.Values['content-length'] <> EmptyStr then
        tmpS:=RequestInfo.RawHeaders.Values['content-length'];
       tmps := Tmps + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_CONTENT_TYPE:
     begin
       if RequestInfo.RawHeaders.Values['content-type'] <> EmptyStr then
         tmpS:= RequestInfo.RawHeaders.Values['content-type'];
       TmpS := TmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_GATEWAY_INTERFACE:
     begin
       tmpS:='ISAPI'#0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_PATH_INFO:
     begin
       tmpS:= TEcb(ConnID).ECB.lpszPathTranslated;
       tmps := Tmps + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_PATH_TRANSLATED:
     begin
       tmpS:=RequestInfo.Document;
       tmps := Tmps + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_QUERY_STRING:
     begin
       tmpS:= RequestInfo.UnparsedParams;
       tmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_REMOTE_ADDR:
     begin
       tmpS:= RequestInfo.RemoteIP;
       tmpS := tmpS +  #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_REMOTE_HOST:
     begin
       tmps := GStack.HostByAddress(RequestInfo.RemoteIP);
       tmpS := tmpS +  #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_REMOTE_USER:
     begin
       TmpS := RequestInfo.AuthUsername;
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_REQUEST_METHOD:
     begin
       tmpS := RequestInfo.Command;
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_SCRIPT_NAME:
     begin
       if pos('.DLL', UpperCase(RequestInfo.Document)) > 0 then
         tmpS := Copy(RequestInfo.Document,1,Pos('.DLL', UpperCase(RequestInfo.Document))+ 3)
          else
           tmpS := RequestInfo.Document;
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_SERVER_NAME:
     begin
       tmpS:=RequestInfo.Host;
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_SERVER_PORT:
     begin
       tmpS:= IntToStr(Thread.Connection.Socket.Binding.Port);
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_SERVER_PROTOCOL:
     begin
       tmpS:=RequestInfo.Version;
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_SERVER_SOFTWARE:
     begin
       if Assigned(Server) then
         TmpS := Server.ServerSoftware
          else
           TmpS := '';
        TmpS := tmpS + #0;
        StrPCopy( PChar(buffer), PChar(tmpS) );
        size:=Length(tmpS);
     end;

 v_HTTP_COOKIE:
     begin
       tmpS:= RequestInfo.RawHeaders.Values['cookie'];
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_USER_AGENT:
    begin
      tmpS := RequestInfo.RawHeaders.Values['User-Agent'];
      TmpS := tmpS + #0;
      StrPCopy( PChar(buffer), PChar(tmpS) );
      size:=Length(tmpS);
    end;

 v_URL: begin
       if pos('.DLL', UpperCase(RequestInfo.Document)) > 0 then
         tmpS := Copy(RequestInfo.Document,1,Pos('.DLL',UpperCase(RequestInfo.Document))+ 3)
          else
           tmpS := RequestInfo.Document;
       TmpS := TmpS + #0;
       StrPCopy(pChar(Buffer), PChar(tmpS));
       Size := length(tmpS);
     end;

 //v 3.0
  v_HTTP_CACHE_CONTROL:
     begin
       tmpS:= GetFieldByNameEx('CACHE_CONTROL');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_DATE:
     begin
       tmpS:= GetFieldByName('DATE');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_ACCEPT:
     begin
       tmpS:= GetFieldByName('ACCEPT');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_FROM:
     begin
       tmpS:= GetFieldByName('FROM');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_HOST:
     begin
       tmpS:= GetFieldByName('HOST');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_IF_MODIFIED_SINCE :
     begin
       tmpS := GetFieldByNameEx('IF-MODIFIED-SINCE');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_REFERER:
     begin
       TmpS := GetFieldByName('REFERER');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_CONTENT_ENCODING:
     begin
       TmpS := GetFieldByName('CONTENT-ENCODING');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_CONTENT_VERSION:
     begin
       TmpS := GetFieldByName('CONTENT-VERSION');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_DERIVED_FROM:
     begin
       TmpS := GetFieldByName('DERIVED-FROM');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_EXPIRES:
     begin
       tmpS:= GetFieldByName('EXPIRES');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_TITLE:
     begin
       TmpS := GetFieldByName('TITLE');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_CONNECTION:
     begin
       TmpS := GetFieldByName('CONNECTION');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

 v_HTTP_AUTHORIZATION:
     begin
       TmpS := GetFieldByName('AUTHORIZATION');
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  V_DOCUMENT_ROOT:
     begin
       TmpS := TEcb(connID).DocumentRoot;
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_SERVER_ADMIN:
     begin
       TmpS := TEcb(connID).ServerAdmin;
       TmpS := tmpS + #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_SERVER_ADDR:
     begin
       tmpS:= RequestInfo.RemoteIP;
       tmpS := tmpS +  #0;
       StrPCopy( PChar(buffer), PChar(tmpS) );
       size:=Length(tmpS);
     end;

  v_HTTP_ACCEPT_LANGUAGE :
  begin
    TmpS := GetFieldByName('ACCEPT-LANGUAGE');
    TmpS := tmpS + #0;
    StrPCopy( PChar(buffer), PChar(tmpS) );
    size:=Length(tmpS);
  end;

  v_HTTP_ACCEPT_ENCODING :
  begin
    TmpS := GetFieldByName('ACCEPT-ENCODING');
    TmpS := tmpS + #0;
     StrPCopy( PChar(buffer), PChar(tmpS) );
     size:=Length(tmpS);
  end;

  v_HTTP_CLIENT_IP :
  begin
    tmpS:= RequestInfo.RemoteIP;
    tmpS := tmpS +  #0;
    StrPCopy( PChar(buffer), PChar(tmpS) );
     size:=Length(tmpS);
  end;

  v_REDIRECT_STATUS :
  begin
    tmpS := '200';
    tmpS := tmpS +  #0;
    StrPCopy( PChar(buffer), PChar(tmpS) );
     size:=Length(tmpS);
  end;

  v_HTTP_REDIRECT_STATUS :
  begin
    tmpS := '200';
    tmpS := tmpS +  #0;
    StrPCopy( PChar(buffer), PChar(tmpS) );
     size:=Length(tmpS);
  end;

  v_REDIRECT_URL :
  begin
    tmpS := RequestInfo.Document;
    tmpS := tmpS +  #0;
    StrPCopy( PChar(buffer), PChar(tmpS) );
     size:=Length(tmpS);
  end;

 v_HTTP_IDSESSION :
 begin
   tmpS := '';
   if Assigned(RequestInfo.Session) then
    tmpS := RequestInfo.Session.Content.Text;
   tmpS := tmpS + #0;
   StrPCopy( PChar(buffer), PChar(tmpS) );
    size:=Length(tmpS);
 end;

 else
   begin
     Result:=False;
   end;
 end;

end;

function CBWriteClient(connID: HCONN; buffer: Pointer; var Bytes: DWORD; dwReserved: DWORD): Boolean; stdcall;
var
  ResponseInfo : TIdHTTPResponseInfo;
  S            : String;
begin
  Result:=True;
  ResponseInfo := TECB(ConnID).ResponseInfo;
try
   SetLength(S,Bytes);
   Move(Buffer^,S[1],Bytes);
   ResponseInfo.ContentText := ResponseInfo.ContentText + S;
 except
   Bytes:=0;
   Result:=False;
 end;

end;

function CBReadClient(connID: HCONN; buffer: Pointer; var size: DWORD): Boolean; stdcall;
var
  Thread       : TIdContext;
begin
  Result:=True;
  Thread:= TEcb(connID).AThread;

  if (thread=nil) then
  begin
    Result:=False;
    Exit;
  end;

 try
   Thread.Connection.IOHandler.ReadBytes(tidBytes(buffer^), size);
 except
   size:=0;
   Result:=False;
 end;

end;

function CBServerSupport(connID: HCONN; HSERRequest: DWORD; buffer: Pointer; size: LPDWORD; dataType: LPDWORD): Boolean; stdcall;
var
  ResponseInfo : TIdHTTPResponseInfo;
  RequestInfo  : TidHTTPRequestInfo;
  HeaderList : TIdHeaderList;
  tmpS: String;
  ind : integer;
  cook : string;
  RedirURL : string;
  Runner : TDWISAPIRunner;
  ts_info : THSE_TF_INFO;
begin
  ResponseInfo := TECB(ConnID).ResponseInfo;
  RequestInfo  := TECB(ConnID).RequestInfo;
  Runner := TECB(ConnID).Runner;

  tmpS:=String(buffer);

  Case HSERRequest of

  (HSE_REQ_END_RESERVED+20) :
  begin
    if Assigned(RequestInfo.Session) then
      RequestInfo.Session.Content.Text := tmpS;
     result := true;
  end;

  HSE_APPEND_LOG_PARAMETER :
  begin
    if Assigned(Runner) then
     begin
       if Assigned(Runner.FOnLogServerMessage) then
         Runner.FOnLogServerMessage(Runner, RequestInfo, ResponseInfo, tmpS);
         Result := true;
      end
        else
          Result := false;
  end;

  HSE_REQ_TRANSMIT_FILE :
  begin
    ts_info := THSE_TF_INFO(buffer^);
    TransmitFile(TECB(ConnID).AThread.Connection.Socket.Binding.Handle,
       ts_info.hFile, ts_info.BytesToWrite, 0, nil, nil, 0);
    Result := true;
  end;

  HSE_REQ_DONE_WITH_SESSION :
  begin
    SetEvent(TECB(connID).WaitEvent);
    result := false;
  end;

  HSE_REQ_IS_KEEP_CONN :
  begin
     TECB(ConnID).KeepAlive := boolean(buffer);
     Result := true;
  end;

  HSE_REQ_SEND_URL_REDIRECT_RESP, HSE_REQ_SEND_URL :
    begin
      try
       RedirURL := Copy(tmpS,1, length(tmpS));
       ResponseInfo.Redirect(redirURL);
       Result := true;
      except
       Result:=False;
      end
    end;


  HSE_REQ_SEND_RESPONSE_HEADER:
   begin
     try
       tmpS := pchar(datatype);
       tmpS := Copy(tmpS,1,Length(tmpS) -2);
       HeaderList := TidHeaderList.Create{$IFNDEF FPC}{$IFNDEF OLDINDY}(QuoteHTTP){$ENDIF}{$ELSE}(QuoteHTTP){$ENDIF};
       HeaderList.Text := tmpS;
       if TECB(ConnID).KeepAlive then
        HeaderList.Values['Connection'] := 'Keep-Alive';
       for ind := 0 to HeaderList.Count - 1 do
       begin
         if Pos('Set-Cookie: ', HeaderList[ind]) =1 then
          begin
            cook := HeaderList[ind];
            Delete(cook, 1 , 12);
            {$IFNDEF FPC}
             {$IFNDEF OLDINDY}
             ResponseInfo.Cookies.AddClientCookie(cook);
             {$ENDIF}
            {$ELSE}
             ResponseInfo.Cookies.AddClientCookie(cook);
            {$ENDIF}
          end;
       end;


       if HeaderList.Values['Content-type'] <> '' then
        ResponseInfo.ContentType := HeaderList.Values['Content-Type'];
       ResponseInfo.Location := HeaderList.Values['Location'];
       if ResponseInfo.Location <> '' then
         ResponseInfo.ResponseNo := 302;
       ResponseInfo.Pragma := HeaderList.Values['Pragma'];
       if (HeaderList.IndexOfName('Date') > 0) then
         ResponseInfo.Date := StrToDateTime(HeaderList.Values['Date']);

       if (HeaderList.IndexOfName('Expires') > 0) then
         ResponseInfo.Expires := GMTToLocalDateTime(HeaderList.Values['Expires']);

       if (HeaderList.IndexOfName('LastModified') > 0) then
         ResponseInfo.LastModified := StrToDateTime(HeaderList.Values['LastModified']);

       HeaderList.Free;
       Result := true;
     except
       Result:=False;
     end
   end
  else
  begin
    Result:=False;
  end;
 end;
end;

constructor TECB.Create;
begin
  ECB.cbSize:=sizeof(TEXTENSION_CONTROL_BLOCK);
  ECB.dwVersion:= MAKELONG(HSE_VERSION_MINOR, HSE_VERSION_MAJOR);
  ECB.ConnID:= THandle(Self);
  ECB.GetServerVariable:=@CBGetServerVariable;
  ECB.WriteClient:=@CBWriteClient;
  ECB.ReadClient:=@CBReadClient;
  ECB.ServerSupportFunction:=@CBServerSupport;
  ECB.lpszLogData:='DEFAULT LOG DATA';
  ECB.lpszMethod := nil;
  ECB.lpszQueryString := nil;
  ECB.lpszPathInfo:= nil;
  ECB.lpszPathTranslated:= nil;
  ECB.cbTotalBytes:=0;
  ECB.cbAvailable:=0;
  ECB.lpbData:=nil;
  ECB.lpszContentType:=nil;
end;


procedure TDWISAPIRunner.Execute(const dllName: String; AThread: TIdContext;
                  RequestInfo: TIdHTTPRequestInfo;
                  ResponseInfo: TIdHTTPResponseInfo;
                  const DocumentRoot : string;
                  dllunload : boolean = false;
                  Action : string='');
const
  HSE_TERM: array[Boolean] of DWORD = (HSE_TERM_ADVISORY_UNLOAD, HSE_TERM_MUST_UNLOAD);

var
  dllHandle   : THandle;
  versionInfo : THSE_VERSION_INFO;
  version     : VersionFunc;
  proc        : ProcFunc;
  controlBlock: TECB;
  PatchInfo   : string;
  rc          : DWORD;
  bufsize     : integer;
  i           : integer;
  ErrorMode: Integer;
  ModuleName : string;
begin

  if not Assigned(AThread) then
   Exit;

  if not Assigned(RequestInfo) then
   Exit;

  if not Assigned(ResponseInfo) then
   Exit;

  DoBeforeExecute;

  // Load the Dll only if it is not already loaded
  EnterCriticalSection(fliblock);
  ModuleName := ExtractFileName(dllName);
  i := FLibHandles.IndexOf(ModuleName);
  if i = -1 then
  begin
    ErrorMode := SetErrorMode(SEM_NOOPENFILEERRORBOX);
    dllHandle := LoadLibrary( PChar(dllName));
    SetErrorMode(ErrorMode);

    if dllHandle=0 then
     begin
      ResponseInfo.ResponseNo := 404;
      ResponseInfo.ResponseText := '<H1>'+ DLLName + ' not found</H1>';
      DoModuleNotFound(RequestInfo, ResponseInfo);
      LeaveCriticalSection(fliblock);
      exit;
     end;

    if not dllunload then
      begin
        FLibHandles.AddObject(ModuleName, TObject(dllHandle));
        if Assigned(FOnModuleLoad) then
          FOnModuleLoad(Self, DLLName);
      end;
  end
   else
     begin
       dllHandle := THandle(FLibHandles.Objects[i]);
       if dllunload then
         begin
           FLibHandles.delete(i);
         end;
     end;
  LeaveCriticalSection(fliblock);

  try

    @version:=GetProcAddress(dllHandle, PChar('GetExtensionVersion') );
    @proc:=GetProcAddress(dllHandle, PCHar('HttpExtensionProc') );

    if (@version=nil) then
      begin
        ResponseInfo.ResponseNo := 500;
        ResponseInfo.ContentText := 'Internal server error. GetExtensionVersion procedure not assigned';
        if Assigned(FOnISAPIStructureError) then
         FOnISAPIStructureError(Self, RequestInfo, ResponseInfo);
        Exit;
      end;

    if (@proc=nil) then
     begin
       ResponseInfo.ResponseNo := 500;
       ResponseInfo.ContentText := 'Internal server error. HttpExtensionProc procedure not assigned';
       if Assigned(FOnISAPIStructureError) then
         FOnISAPIStructureError(Self, RequestInfo, ResponseInfo);
       Exit;
     end;

    if ( NOT version(versionInfo) ) then
     begin
       ResponseInfo.ResponseNo := 500;
       if Assigned(FOnVersionInfoError) then
        FOnVersionInfoError(Self, RequestInfo, ResponseInfo);
       Exit;
     end;

    ControlBlock := TEcb.Create;
    ControlBlock.Runner := Self;
    ControlBlock.KeepAlive := false;
    ControlBlock.DocumentRoot := DocumentRoot;
    ControlBlock.ServerAdmin := ServerAdmin;
    ControlBlock.AThread := AThread;
    ControlBlock.Server := FServer;
    ControlBlock.RequestInfo := RequestInfo;
    ControlBlock.ResponseInfo := ResponseInfo;
    ControlBlock.ECB.lpszMethod:= PAnsiChar(StrNew(PChar(RequestInfo.Command)));
    ControlBlock.ECB.lpszContentType := PAnsiChar(StrNew(PChar(RequestInfo.ContentType)));
    if SameText(RequestInfo.Command, 'GET') then
      ControlBlock.ECB.lpszQueryString:= PAnsiChar(StrNew(PChar(RequestInfo.UnparsedParams)));
    PatchInfo:= Action;
    ControlBlock.ECB.lpszPathInfo:=PAnsiChar(PatchInfo);
    {$WARNINGS OFF}
    ControlBlock.ECB.lpszPathTranslated :=
    StrNew(PAnsiChar(ExpandFilename(IncludeTrailingBackslash(DocumentRoot)+ RequestInfo.Document)));
    if SameText(RequestInfo.Command, 'POST') then
     begin
       if RequestInfo.ContentLength > 0 then
        begin
         BufSize := RequestInfo.ContentLength;
         GetMem(ControlBlock.ECB.lpbData, BufSize + 1);
         StrPCopy(PChar(ControlBlock.ECB.lpbData), requestInfo.FormParams);
         ControlBlock.ECB.cbAvailable := BufSize;
         ControlBlock.ECB.cbTotalBytes := BufSize;
        end;
     end;
    ControlBlock.WaitEvent := CreateEvent(nil, false, false, nil);
    try

     rc := Proc(ControlBlock.ECB);
     if rc = HSE_STATUS_PENDING then
      begin
        WaitForSingleObject(ControlBlock.WaitEvent , infinite);
      end;

      CloseHandle(ControlBlock.WaitEvent);
      Sleep(75);
    except
      ResponseInfo.ResponseNo := 500;
      Exit;
    end;

    if (ControlBlock.ECB.lpbData<>nil) then
    begin
       FreeMem( ControlBlock.ECB.lpbData );
       ControlBlock.ECB.lpbData:=nil;
    end;


  ControlBlock.Free;

  finally
    if dllunload then
       UnloadDLL(ModuleName);
     DoAfterExecute;
  end;

end;

procedure TDWISAPIRunner.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FServer) then
    FServer := nil;
end;

procedure TDWISAPIRunner.SetServer(const AValue: TIdHTTPServer);
begin
  if FServer <> AValue then
  begin
    if Avalue <> nil then AValue.FreeNotification(Self);
    FServer := AValue;
  end;
end;

constructor TDWISAPIRunner.Create(AOwner: TComponent);
begin
  inherited;
  FLibHandles:=TStringList.create;
  InitializeCriticalSection(fliblock);
  FServerAdmin := 'admin@server';
end;

destructor TDWISAPIRunner.Destroy;
var
  i: Integer;
  lh: THandle;
 begin
  inherited;
  EnterCriticalSection(fliblock);
  for i := 0 to FLibHandles.Count -1 do
   begin
    try
     lh := THandle(FLibHandles.Objects[i]);
     FreeLibrary(lh);
     except
     end;
   end;
  LeaveCriticalSection(fliblock);
  FLibHandles.free;
  DeleteCriticalSection(fliblock);
 end;

function TDWISAPIRunner.UnloadDLL(const dllName: string; Ask : boolean = false):Boolean;
var
  i: Integer;
  lh: THandle;
const
  HSE_TERM: array[Boolean] of DWORD = (HSE_TERM_ADVISORY_UNLOAD, HSE_TERM_MUST_UNLOAD);
var
  CanUnload: Boolean;
  TermProc    : TTerminateExtension ;
begin
  // unload and remove the dll from the List;
  if Assigned(FOnModuleUnload) then
   FOnModuleUnload(Self, DLLName);
  Result := False;
  EnterCriticalSection(fliblock);
  i := FLibHandles.IndexOf(dllName);
  if i <> -1 then
  begin
    try
      lh := THandle(FLibHandles.Objects[i]);
      @TermProc := GetProcAddress(lh, 'TerminateExtension');
      CanUnload := True;
      if Assigned(TermProc) then
       CanUnload := not Ask or TermProc(HSE_TERM[Ask]);
      if CanUnload then
       begin
         FreeLibrary(lh);
         FLibHandles.Delete(i);
         Result := true;
       end
        else
          Result := false;
    except
    end;
  end;
  LeaveCriticalSection(fliblock);
end;


destructor TECB.Destroy;
begin
  with ECB do
  begin
    FreeMem(lpbData);
  end;
  inherited;
end;

procedure TDWISAPIRunner.DoAfterExecute;
begin
   if Assigned(FAfterExecute) then
    FAfterExecute(Self);
end;

procedure TDWISAPIRunner.DoBeforeExecute;
begin
  if Assigned(FBeforeExecute) then
   FBeforeExecute(Self);
end;

procedure TDWISAPIRunner.DoModuleNotFound(RequestInfo : TidHTTPRequestInfo; ResponseInfo : TidHTTPResponseInfo);
begin
  if Assigned(FOnModuleNotFound) then
   FOnModuleNotFound(Self, RequestInfo, ResponseInfo);
end;

end.

