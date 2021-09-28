unit dwCGIRunner;

interface

{$I uRESTDW.inc}

uses
  {$IFDEF FPC}
   {$IFNDEF LAMW}
    LCL,
   {$ENDIF}
  {$ELSE}
  {$IFDEF LINUXFMX}
   Posix.Base,
    Posix.Fcntl,
  {$ELSE}
    Windows,
  {$ENDIF}
  {$ENDIF}
  uDWConsts,
  uDWConstsData,
  uDWConstsCharset,
  SysUtils,
  uDWAbout,
  Classes,
  IdGlobal,
  idTCPServer,
  idStack,
  idCustomHTTPServer,
  idCookie,
  IdContext,
  idHTTPServer;

Type
 TAnoPipe = Record
  Input,            //Handle to send data to the pipe
  Output : THandle; //Handle to read data from the pipe
End;

type
  {TidCGIRunner component allows to execute CGI scripts using
   Indy TidHTTPServer component}
  TDWCGIRunner = Class(TDWComponent)
   private
     FPHPModule,
     FPHPRunFlags,
     FPHPIniPath: String;  // Added PAJ 04.08.2002
     FBeforeExecute : TNotifyEvent;
     FAfterExecute : TNotifyEvent;
     FPHPSupport : boolean;
     FServer : TidHTTPServer;
     FTimeOut : integer;
     FBaseFiles,
     FTimeOutMsg,
     FErrorMsg,
     FServerAdmin    : String;
     FCGIExtensions  : TStringList;
     VEncondig       : TEncodeSelect;             //Enconding se usar CORS usar UTF8 - Alexandre Abade
     procedure SetServer(const AValue : TIdHTTPServer);
     {$IFDEF LINUXFMX}
       Function GetDosOutput(CommandLine : String; Work: String = '/'): String;

     {$ELSE}
       Function GetDosOutput(CommandLine : String; Work: String = 'C:\'): String;
     {$ENDIF}
   protected
      //Forwards notification messages to all owned components.
      procedure Notification(AComponent: TComponent; Operation: TOperation); override;
   public
     //Allocates memory and constructs a safely initialized instance of a component.
     constructor Create(AOwner : TComponent); override;
     destructor  Destroy; override;
     Function Execute(LocalDoc : string;
                      AThread: TIdContext;
                      RequestInfo: TIdHTTPRequestInfo;
                      Var ResponseInfo: TIdHTTPResponseInfo;
                      DocumentRoot : string;
                      Action : string = '') : integer; virtual;
     //Indy TidHTTPServer
     property Server : TidHTTPServer read FServer write SetServer;
   published
     property CGIExtensions : TStringList Read FCGIExtensions Write FCGIExtensions;
     //Specifies the time-out interval, in milliseconds
     property TimeOut: integer read FTimeOut write FTimeOut default 5000;
     //Time-out error message text
     property TimeOutMsg : string read FTimeOutMsg write FTimeOutMsg;
     //General error message text
     property ErrorMsg : string read FErrorMsg write FErrorMsg;
     {Email address of Server Administator (optional, for compatibility
      with Apache) }
     property ServerAdmin : string read FServerAdmin write FServerAdmin;
     //Occurs before executing CGI script
     property BeforeExecute : TNotifyEvent read FBeforeExecute write FBeforeExecute;
     //Occurs after executing CGI script
     property AfterExecute : TNotifyEvent read FAfterExecute write FAfterExecute;
     //Perform special action to support PHP security
     property PHPSupport : boolean read FPHPSupport write FPHPSupport default true;
     // Path to PHP.ini file (added PAJ 04.08.2002)
     property PHPIniPath  : String read FPHPIniPath write FPHPIniPath;
     property PHPModule   : String read FPHPModule  write FPHPModule;
     property PHPRunFlags : String Read FPHPRunFlags Write FPHPRunFlags;
     property BaseFiles : String read FBaseFiles  write FBaseFiles;
    Property Encoding     : TEncodeSelect Read VEncondig Write VEncondig;          //Encoding da string
   end;


implementation

type
  ThreadParams = record
    hReadPipe : THandle;
    s : String;
  end;
  PThreadParams = ^ThreadParams;

{$IFDEF LINUXFMX}
      type
        TStreamHandle = pointer;

      ///  <summary>
      ///    Man Page: http://man7.org/linux/man-pages/man3/popen.3.html
      ///  </summary>
      function popen(const command: MarshaledAString; const _type: MarshaledAString): TStreamHandle; cdecl; external libc name _PU + 'popen';

      ///  <summary>
      ///    Man Page: http://man7.org/linux/man-pages/man3/pclose.3p.html
      ///  </summary>
      function pclose(filehandle: TStreamHandle): int32; cdecl; external libc name _PU + 'pclose';

      ///  <summary>
      ///    Man Page: http://man7.org/linux/man-pages/man3/fgets.3p.html
      ///  </summary>
      function fgets(buffer: pointer; size: int32; Stream: TStreamHAndle): pointer; cdecl; external libc name _PU + 'fgets';


      ///  <summary>
      ///    Utility function to return a buffer of ASCII-Z data as a string.
      ///  </summary>
      function BufferToString( Buffer: pointer; MaxSize: uint32 ): string;
      var
        cursor: ^uint8;
        EndOfBuffer: nativeuint;
      begin
        Result := '';
        if not assigned(Buffer) then begin
          exit;
        end;
        cursor := Buffer;
        EndOfBuffer := NativeUint(cursor) + MaxSize;
        while (NativeUint(cursor)<EndOfBuffer) and (cursor^<>0) do begin
          Result := Result + chr(cursor^);
          cursor := pointer( succ(NativeUInt(cursor)) );
        end;
      end;
    {$ENDIF}

function AdjustHTTP(const Name: string): string;
  const
    SHttp = 'HTTP_';     { do not localize }
begin
    if Pos(SHttp, Name) = 1 then
      Result := Copy(Name, 6, MaxInt)
        else
          Result := Name;
end;

{
function ThreadRead(Params : Pointer):Dword; stdcall;
var
  Info : PThreadParams;
  Buffer :  array [0..4095] of Char;
  nb: DWord;
  i: Longint;
begin
  Result := 0;
  Info := PThreadParams(Params);
  while ReadFile( Info^.hReadPipe,  buffer,  SizeOf(buffer),  nb,  nil) do
     begin
       if nb = 0 then
         Break;
       for i:=0 to nb-1 do
         Info^.s := Info^.s + buffer[i];
      end;

end;
}

function GetEnv(const Name: string): string;
var
  Buffer: array[0..4095] of Char;
begin
{$IFDEF FPC}
 SetString(Result, PChar(GetEnvironmentVariable(PChar(Name))), Length(GetEnvironmentVariable(AnsiString(Name))));
{$ELSE}
{$IFDEF LINUXFMX}
  SetString(Result, pchar(GetEnvironmentVariable(Name)), SizeOf(Buffer));
 {$ELSE}
  SetString(Result, Buffer, GetEnvironmentVariable(PChar(Name), Buffer, SizeOf(Buffer)));
 {$ENDIF}
{$ENDIF}
end;


constructor TDWCGIRunner.Create(AOwner: TComponent);
begin
  inherited;
  FErrorMsg := '<html><body><h1><center>Internal Server Error</body></html>';
  FTimeOutMsg := '<html><body><h1><center>Process was terminated.</body></html>';
  FServerAdmin := 'admin@server';
  FTimeOut := 5000;
  FPHPSupport := true;
  PHPModule       := 'php-cgi.exe';
  FPHPRunFlags    := '-f';
  FCGIExtensions  := TStringList.Create;
  FCGIExtensions.Add('.cgi');
  FCGIExtensions.Add('.exe');
  FCGIExtensions.Add('.dll');
  VEncondig       := esUtf8;
end;

Destructor TDWCGIRunner.Destroy;
Begin
 FCGIExtensions.Free;
  inherited;
End;

{$IFNDEF LINUXFMX}
Function TDWCGIRunner.GetDosOutput(CommandLine : String;
                                   Work        : String = 'C:\') : String;
Var
 SA              : TSecurityAttributes;
 SI              : TStartupInfo;
 PI              : TProcessInformation;
 StdOutPipeRead,
 StdOutPipeWrite : THandle;
 WasOK           : Boolean;
 Buffer          : Array[0..255] of AnsiChar;
 BytesRead       : Cardinal;
 WorkDir         : String;
 Handle          : Boolean;
Begin
 Result := '';
 With SA Do
  Begin
   nLength := SizeOf(SA);
   bInheritHandle := True;
   lpSecurityDescriptor := nil;
  End;
 CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
 Try
  With SI Do
   Begin
    FillChar(SI, SizeOf(SI), 0);
    cb := SizeOf(SI);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    wShowWindow := SW_HIDE;
    hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
    hStdOutput := StdOutPipeWrite;
    hStdError := StdOutPipeWrite;
   End;
  WorkDir := Work;
  Handle := CreateProcess(Nil, PChar('cmd.exe /C ' + CommandLine),
                          Nil, Nil, True, 0, Nil,
                          PChar(WorkDir), SI, PI);
  CloseHandle(StdOutPipeWrite);
  If Handle then
   Begin
    Try
     Repeat
      WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
      If BytesRead > 0 Then
       Begin
        Buffer[BytesRead] := #0;
        Result := Result + Buffer;
       End;
     Until Not WasOK Or (BytesRead = 0);
     WaitForSingleObject(PI.hProcess, INFINITE);
    Finally
     CloseHandle(PI.hThread);
     CloseHandle(PI.hProcess);
    End;
   End;
 Finally
  CloseHandle(StdOutPipeRead);
 End;
End;
{$ELSE}
Function TDWCGIRunner.GetDosOutput(CommandLine : String;
                                   Work        : String = '/') : String;
var
  Handle: TStreamHandle;
  Data: array[0..511] of uint8;

begin
  try
    Handle := popen(MarshaledAString(CommandLine),'r');   //comand Example: '/bin/ls -lart'
    try
      while fgets(@data[0],Sizeof(Data),Handle)<>nil do begin
        Result:=Result+(BufferToString(@Data[0],sizeof(Data)));
      end;
    finally
      pclose(Handle);
    end;
  except
    on E: Exception do
      Result:=(E.ClassName+ ': '+ E.Message);
  end;

end;
 //
{$ENDIF}

function TDWCGIRunner.Execute(LocalDoc : string; AThread: TIdContext;
                              RequestInfo: TIdHTTPRequestInfo;
                              Var ResponseInfo: TIdHTTPResponseInfo;
                              DocumentRoot : string;
                              Action : string = '') : integer;
const
  FEnv = '%s=%s'#0;
  cBufferSize = 2048;
Var
 vBuffer: Pointer;
 vReadBytes,
 i1 : LongWord;
 vPHPRunLine,
 ParsLine : string;
 HeadLine : string;
 ParsList : TStringList;
 I        : integer;
 vFileName,
 cEnv : String;
 shell_cmd : string;
 tmpS : string;
// Cookie : TIdCookie;
 tmp : integer;
 Version_Protocol : TIDIPVersion;
 Function GetFieldByNameEx(AFieldName : string) : string;
 Var
  NewFieldName : string;
 Begin
  NewFieldName := AdjustHTTP(AFieldName);
  Result := RequestInfo.RawHeaders.Values[NewFieldName];
  If Result = '' Then
   Begin
    NewFieldName := StringReplace(NewFieldName,'_','-', [rfReplaceALL]);
    Result := RequestInfo.RawHeaders.Values[NewFieldName];
   End;
 End;
 Function GetFieldByName(AFieldName : string) : string;
 Begin
  Result := RequestInfo.RawHeaders.Values[AFieldName];
  If Result = '' then
   Result := GetFieldByNameEx(AFieldName);
 End;
Begin
 if Assigned(FBeforeExecute) then
  FBeforeExecute(Self);
 cEnv := '';
 If Assigned(FServer) Then
  cEnv := Format(FEnv,['SERVER_SOFTWARE', FServer.ServerSoftware ]);
 cEnv := cEnv + Format(FEnv,['HTTP_CONTENT_TYPE',RequestInfo.RawHeaders.Values['Content-Type']]);
 cEnv := cEnv + Format(FEnv,['CONTENT_TYPE',RequestInfo.RawHeaders.Values['Content-Type']]);
 tmpS := '';
 //Fixes todo XyberX
 For I := 0 To FCGIExtensions.Count -1 Do
  Begin
   If Pos(UpperCase(FCGIExtensions[I]), UpperCase(RequestInfo.Document)) > 0 then
    Begin
     tmpS := Copy(RequestInfo.Document, 1, Pos(UpperCase(FCGIExtensions[I]), UpperCase(RequestInfo.Document))+ 3);
     Break;
    End;
  End;
 If tmpS = '' Then
  tmpS := RequestInfo.Document;
 cEnv := cEnv + Format(FEnv,['URL', tmpS]);
  //for php support
 If PHPSupport Then
  begin
   cEnv := cEnv + Format(FEnv,['PHPRC',FPHPIniPath]);  // Added PAJ 22.05.2002.
   cEnv := cEnv + Format(FEnv,['REDIRECT_STATUS','200']);
   cEnv := cEnv + Format(FEnv,['HTTP_REDIRECT_STATUS','200']);
   cEnv := cEnv + Format(FEnv,['REDIRECT_URL',RequestInfo.Document]);
  End;
 cEnv := cEnv + Format(FEnv,['CONTENT_LENGTH', RequestInfo.RawHeaders.Values['Content-Length']]);
 cEnv := cEnv + Format(FEnv,['HTTP_CONTENT_LENGTH', RequestInfo.RawHeaders.Values['Content-Length']]);
 cEnv := cEnv + Format(FEnv,['SERVER_NAME',RequestInfo.Host]);;
 cEnv := cEnv + Format(FEnv,['SERVER_PROTOCOL',RequestInfo.Version]);
 cEnv := cEnv + Format(FEnv,['SERVER_PORT',IntToStr(AThread.Connection.Socket.Binding.Port)]);
 cEnv := cEnv + Format(FEnv,['GATEWAY_INTERFACE','CGI/1.1']);
 cEnv := cEnv + Format(FEnv,['REQUEST_METHOD',RequestInfo.Command]);
 tmpS := '';
 For I := 0 To FCGIExtensions.Count -1 Do
  Begin
   If Pos(UpperCase(FCGIExtensions[I]), UpperCase(RequestInfo.Document)) > 0 then
    Begin
     tmpS := Copy(RequestInfo.Document, 1, Pos(UpperCase(FCGIExtensions[I]), UpperCase(RequestInfo.Document))+ 3);
     Break;
    End;
  End;
 If tmpS = '' Then
  tmpS := RequestInfo.Document;
 cEnv := cEnv + Format(FEnv,['SCRIPT_NAME',tmpS]);
 If RequestInfo.Command <> 'POST' Then
  cEnv := cEnv + Format(FEnv,['QUERY_STRING',RequestInfo.UnparsedParams]);
 cEnv := cEnv + Format(FEnv,['REMOTE_ADDR', AThread.Binding.IP]); //RequestInfo.RemoteIP]);
 cEnv := cEnv + Format(FEnv,['REMOTE_HOST', AThread.Binding.IP]); //GStack.HostByAddress(AThread.Binding.IP)]);
 //Win32 fields
 cEnv := cEnv + Format(FEnv,['SystemRoot',getenv('SystemRoot')]);
 cEnv := cEnv + Format(FEnv,['COMSPEC',getenv('COMSPEC')]);
 cEnv := cEnv + Format(FEnv,['WINDIR',getenv('WINDIR')]);
 cEnv := cEnv + Format(FEnv,['PATH',getenv('PATH')]);
 If Action <> '' then
  cEnv := cEnv + Format(FEnv,['PATH_INFO', Action])
 Else
  cEnv := cEnv + Format(FEnv,['PATH_INFO', RequestInfo.Document]);
 cEnv := cEnv + Format(FEnv,['REQUEST_URI', RequestInfo.Document]);
 cEnv := cEnv + Format(FEnv,['PATH_TRANSLATED',ExpandFileName(DocumentRoot + RequestInfo.Document)]);
 cEnv := cEnv + Format(FEnv,['SCRIPT_FILENAME',LocalDoc]);
 //Add HTTP_ fields
 cEnv := cEnv + Format(FEnv,['HTTP_DATE', GetFieldByName('DATE')]);
 cEnv := cEnv + Format(FEnv,['HTTP_CACHE_CONTROL', GetFieldByName('CACHE_CONTROL')]);
 cEnv := cEnv + Format(FEnv,['HTTP_ACCEPT',GetFieldByName('ACCEPT')]);
 cEnv := cEnv + Format(FEnv,['HTTP_FROM', GetFieldByName('FROM')]);
 cEnv := cEnv + Format(FEnv,['HTTP_HOST', GetFieldByName('HOST')]);
 cEnv := cEnv + Format(FEnv,['HTTP_IF_MODIFIED_SINCE', GetFieldByName('IF-MODIFIED-SINCE')]);
 cEnv := cEnv + Format(FEnv,['HTTP_REFERER',GetFieldByName('REFERER')]);
 cEnv := cEnv + Format(FEnv,['HTTP_CONTENT_ENCODING', GetFieldByName('CONTENT-ENCODING')]);
 cEnv := cEnv + Format(FEnv,['HTTP_CONTENT_VERSION', GetFieldByName('CONTENT-VERSION')]);
 cEnv := cEnv + Format(FEnv,['HTTP_DERIVED_FROM',GetFieldByName('DERIVED-FROM')]);
 cEnv := cEnv + Format(FEnv,['HTTP_EXPIRES',GetFieldByName('EXPIRES')]);
 cEnv := cEnv + Format(FEnv,['HTTP_TITLE',GetFieldByName('TITLE')]);
 cEnv := cEnv + Format(FEnv,['HTTP_CONNECTION',GetFieldByName('CONNECTION')]);
 cEnv := cEnv + Format(FEnv,['HTTP_AUTHORIZATION',GetFieldByName('AUTHORIZATION')]);
 cEnv := cEnv + Format(FEnv,['HTTP_ACCEPT_LANGUAGE', GetFieldByName('ACCEPT-LANGUAGE')]);
 cEnv := cEnv + Format(FEnv,['HTTP_ACCEPT_ENCODING', GetFieldByName('ACCEPT-ENCODING')]);
 cEnv := cEnv + Format(FEnv,['HTTP_USER_AGENT', RequestInfo.RawHeaders.Values['User-Agent']]);
 cEnv := cEnv + Format(FEnv,['HTTP_COOKIE', RequestInfo.RawHeaders.Values['cookie']]);
 //Apache fields
 cEnv := cEnv + Format(FEnv,['SERVER_ADDR',AThread.Connection.Socket.Binding.IP]);
 cEnv := cEnv + Format(FEnv,['DOCUMENT_ROOT',DocumentRoot]);
 cEnv := cEnv + Format(FEnv,['SERVER_ADMIN',ServerAdmin]);
 cEnv := cEnv + #0;
 Try
  //Long FileName
  If Pos(' ', LocalDoc) <> 0 Then
   LocalDoc := '"'+LocalDoc + '"';
  vPHPRunLine := Trim(FPHPIniPath + FPHPModule + ' ' + FPHPRunFlags);
  If LocalDoc = '' Then
   GetDosOutput(vPHPRunLine + ' ' + '"' + Action + '"')
  Else
   Begin
    vFileName := ExpandFileName(DocumentRoot + RequestInfo.Document);
    vFileName := FBaseFiles + StringReplace(vFileName, '\\', '', [rfReplaceAll]);
    ParsLine := GetDosOutput(vPHPRunLine + ' ' + vFileName + ' '  + cEnv);
   End;
  If ParsLine = '' Then
   Begin
    ResponseInfo.ContentText := FTimeOutMsg;
    ResponseInfo.ContentLength := Length(ResponseInfo.ContentText);
    ResponseInfo.ResponseNo := 500;
    Result :=  ResponseInfo.ContentLength;
    ResponseInfo.WriteContent;
    Exit;
   End
  Else if ParsLine <> '' then
   Begin
    ResponseInfo.ContentType := 'text/html';
    If VEncondig = esUtf8 Then
     ResponseInfo.Charset := 'utf-8'
    Else
     ResponseInfo.Charset := 'ansi';
    ResponseInfo.ContentEncoding := ResponseInfo.Charset;
    If VEncondig = esUtf8 Then
     ResponseInfo.ContentText   := utf8Decode(ParsLine)
    Else
     ResponseInfo.ContentText   := ParsLine;
    ResponseInfo.ContentLength := Length(ResponseInfo.ContentText);
    ResponseInfo.ResponseNo := 200;
    ResponseInfo.WriteContent;
    ParsList.Free;
   End;
  Result :=  ResponseInfo.ContentLength;
 Finally
  if Assigned(FAfterExecute) then
   FAfterExecute(Self);
 End;
End;

procedure TDWCGIRunner.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FServer) then
    FServer := nil;
end;

procedure TDWCGIRunner.SetServer(const AValue: TIdHTTPServer);
begin
  if FServer <> AValue then
  begin
    if Avalue <> nil then AValue.FreeNotification(Self);
    FServer := AValue;
  end;
end;

end.


