unit uRESTDWIOHandler;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
 Classes,
 uRESTDWException,
 uRESTDWBuffer,
 uRESTDWBasicTypes,
 uRESTDWTools,
 uRESTDWAbout,
 uRESTDWConsts;

Const
 GRecvBufferSizeDefault  = 32 * 1024;
 GSendBufferSizeDefault  = 32 * 1024;
 rdwMaxLineLengthDefault = 16 * 1024;
 rdw_IOHandler_MaxCapturedLines = -1;

 Type
  eRESTDWIOHandler = class(eRESTDWException);
  eRESTDWIOHandlerRequiresLargeStream = Class(eRESTDWIOHandler);
  eRESTDWIOHandlerStreamDataTooLarge  = Class(eRESTDWIOHandler);
  TRESTDWIOHandlerClass = Class of TRESTDWIOHandler;
  TRESTDWIOHandler = class(TRESTDWComponent)
 Private
  FLargeStream : Boolean;
 Protected
  FInputBuffer           : TRESTDWBuffer;
  FMaxCapturedLines,
  FMaxLineLength,
  FWriteBufferThreshold,
  FRecvBufferSize,
  FSendBufferSize        : Integer;
  FMaxLineAction         : TRESTDWMaxLineAction;
  FOpened: Boolean;
  FReadLnSplit           : Boolean;
  FWriteBuffer           : TRESTDWBuffer;
  procedure BufferRemoveNotify(ASender : TObject;
                               ABytes  : Integer);
  procedure InitComponent; override;
  procedure PerformCapture(Const ADest          : TObject;
                           Out VLineCount       : Integer;
                           Const ADelim         : String;
                           AUsesDotTransparency : Boolean); Virtual;
  function ReadDataFromSource(var VBuffer: TRESTDWBytes): Integer; virtual; abstract;
  function WriteDataToTarget(const ABuffer: TRESTDWBytes; const AOffset, ALength: Integer): Integer; virtual; abstract;
  function SourceIsAvailable: Boolean; virtual; abstract;
  function CheckForError(ALastResult: Integer): Integer; virtual; abstract;
  procedure RaiseError(AError: Integer); virtual; abstract;
 Public
    procedure AfterAccept; virtual;
    function Connected: Boolean; virtual;
    destructor Destroy; override;
    // CheckForDisconnect allows the implementation to check the status of the
    // connection at the request of the user or this base class.
    procedure CheckForDisconnect(ARaiseExceptionIfDisconnected: Boolean = True;
     AIgnoreBuffer: Boolean = False); virtual; abstract;
    // Does not wait or raise any exceptions. Just reads whatever data is
    // available (if any) into the buffer. Must NOT raise closure exceptions.
    // It is used to get avialable data, and check connection status. That is
    // it can set status flags about the connection.
    function CheckForDataOnSource(ATimeout: Integer = 0): Boolean; virtual;
    procedure Close; virtual;
    procedure CloseGracefully; virtual;
    class function MakeDefaultIOHandler(AOwner: TComponent = nil)
     : TRESTDWIOHandler;
    class function MakeIOHandler(ABaseType: TRESTDWIOHandlerClass;
     AOwner: TComponent = nil): TRESTDWIOHandler;
    // Variant of MakeIOHandler() which returns nil if it cannot find a registered IOHandler
    class function TryMakeIOHandler(ABaseType: TRESTDWIOHandlerClass;
     AOwner: TComponent = nil): TRESTDWIOHandler;
    class procedure RegisterIOHandler;
    class procedure SetDefaultClass;
    function WaitFor(const AString: string; ARemoveFromBuffer: Boolean = True;
      AInclusive: Boolean = False; AByteEncoding: IIdTextEncoding = nil;
      ATimeout: Integer = IdTimeoutDefault
      {$IFDEF STRING_IS_ANSI}; AAnsiEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string;
    // This is different than WriteDirect. WriteDirect goes
    // directly to the network or next level. WriteBuffer allows for buffering
    // using WriteBuffers. This should be the only call to WriteDirect
    // unless the calls that bypass this are aware of WriteBuffering or are
    // intended to bypass it.
    procedure Write(const ABuffer: TRESTDWBytes; const ALength: Integer = -1; const AOffset: Integer = 0); overload; virtual;
    // This is the main write function which all other default implementations
    // use. If default implementations are used, this must be implemented.
    procedure WriteDirect(const ABuffer: TRESTDWBytes; const ALength: Integer = -1; const AOffset: Integer = 0);
    //
    procedure Open; virtual;
    function Readable(AMSec: Integer = IdTimeoutDefault): Boolean; virtual;
    //
    // Optimal Extra Methods
    //
    // These methods are based on the core methods. While they can be
    // overridden, they are so simple that it is rare a more optimal method can
    // be implemented. Because of this they are not overrideable.
    //
    //
    // Write Methods
    //
    // Only the ones that have a hope of being better optimized in descendants
    // have been marked virtual
    procedure Write(const AOut: string; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload; virtual;
    procedure WriteLn(AEncoding: IIdTextEncoding = nil); overload;
    procedure WriteLn(const AOut: string; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload; virtual;
    procedure WriteLnRFC(const AOut: string = ''; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
      ); virtual;
    procedure Write(AValue: TStrings; AWriteLinesCount: Boolean = False;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload; virtual;
    procedure Write(AValue: Byte); overload;
    procedure Write(AValue: Char; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload;

    // for iOS64, Delphi's Longint and LongWord are 64bit, so we can't rely on
    // Write(Longint) and ReadLongint() being 32bit anymore, for instance when
    // sending/reading a TStream with LargeStream=False.  So adding new (U)IntX
    // methods and deprecating the old ones...
    //
    procedure Write(AValue: Int16; AConvert: Boolean = True); overload;
    procedure Write(AValue: UInt16; AConvert: Boolean = True); overload;
    procedure Write(AValue: Int32; AConvert: Boolean = True); overload;
    procedure Write(AValue: UInt32; AConvert: Boolean = True); overload;
    procedure Write(AValue: Int64; AConvert: Boolean = True); overload;
    procedure Write(AValue: TRESTDWUInt64; AConvert: Boolean = True); overload;
    //

    procedure Write(AStream: TStream; ASize: TRESTDWStreamSize = 0;
      AWriteByteCount: Boolean = False); overload; virtual;
    procedure WriteRFCStrings(AStrings: TStrings; AWriteTerminator: Boolean = True;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
      );
    // Not overloaded because it does not have a unique type for source
    // and could be easily unresolvable with future additions
    function WriteFile(const AFile: String; AEnableTransferFile: Boolean = False): Int64; virtual;
    //
    // Read methods
    //
    function AllData(AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; virtual;
    function InputLn(const AMask: string = ''; AEcho: Boolean = True;
      ATabWidth: Integer = 8; AMaxLineLength: Integer = -1;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; AAnsiEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; virtual;
    // Capture
    // Not virtual because each calls PerformCapture which is virtual
    procedure Capture(ADest: TStream; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload; // .Net overload
    procedure Capture(ADest: TStream; ADelim: string;
      AUsesDotTransparency: Boolean = True; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload;
    procedure Capture(ADest: TStream; out VLineCount: Integer;
      const ADelim: string = '.'; AUsesDotTransparency: Boolean = True;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload;
    procedure Capture(ADest: TStrings; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload; // .Net overload
    procedure Capture(ADest: TStrings; const ADelim: string;
      AUsesDotTransparency: Boolean = True; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload;
    procedure Capture(ADest: TStrings; out VLineCount: Integer;
      const ADelim: string = '.'; AUsesDotTransparency: Boolean = True;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ); overload;
    //
    // Read___
    // Cannot overload, compiler cannot overload on return values
    //
    procedure ReadBytes(var VBuffer: TRESTDWBytes; AByteCount: Integer; AAppend: Boolean = True); virtual;
    // ReadLn
    function ReadLn(AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; overload; // .Net overload
    function ReadLn(ATerminator: string; AByteEncoding: IIdTextEncoding
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; overload;
    function ReadLn(ATerminator: string; ATimeout: Integer = IdTimeoutDefault;
      AMaxLineLength: Integer = -1; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; overload; virtual;
    //RLebeau: added for RFC 822 retrieves
    function ReadLnRFC(var VMsgEnd: Boolean; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; overload;
    function ReadLnRFC(var VMsgEnd: Boolean; const ALineTerminator: string;
      const ADelim: string = '.'; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; overload;
    function ReadLnWait(AFailCount: Integer = MaxInt;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string; virtual;
    // Added for retrieving lines over 16K long}
    function ReadLnSplit(var AWasSplit: Boolean; ATerminator: string = LF;
      ATimeout: Integer = IdTimeoutDefault; AMaxLineLength: Integer = -1;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string;
    // Read - Simple Types
    function ReadChar(AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): Char;
    function ReadByte: Byte;
    function ReadString(ABytes: Integer; AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string;

    // for iOS64, Delphi's Longint and LongWord are changed to 64bit, so we can't
    // rely on Write(Longint) and ReadLongint() being 32bit anymore, for instance
    // when sending/reading a TStream with LargeStream=False.  So adding new (U)IntX
    // methods and deprecating the old ones...
    //
    function ReadInt16(AConvert: Boolean = True): Int16;
    function ReadUInt16(AConvert: Boolean = True): UInt16;
    function ReadInt32(AConvert: Boolean = True): Int32;
    function ReadUInt32(AConvert: Boolean = True): UInt32;
    function ReadInt64(AConvert: Boolean = True): Int64;
    function ReadUInt64(AConvert: Boolean = True): TRESTDWUInt64;
    //
    function ReadSmallInt(AConvert: Boolean = True): Int16; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadInt16()'{$ENDIF};{$ENDIF}
    function ReadWord(AConvert: Boolean = True): UInt16; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadUInt16()'{$ENDIF};{$ENDIF}
    function ReadLongInt(AConvert: Boolean = True): Int32; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadInt32()'{$ENDIF};{$ENDIF}
    function ReadLongWord(AConvert: Boolean = True): UInt32; {$IFDEF HAS_DEPRECATED}deprecated{$IFDEF HAS_DEPRECATED_MSG} 'Use ReadUInt32()'{$ENDIF};{$ENDIF}
    //

    procedure ReadStream(AStream: TStream; AByteCount: TRESTDWStreamSize = -1;
     AReadUntilDisconnect: Boolean = False); virtual;
    procedure ReadStrings(ADest: TStrings; AReadLinesCount: Integer = -1;
      AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      );
    //
    procedure Discard(AByteCount: Int64);
    procedure DiscardAll;
    //
    // WriteBuffering Methods
    //
    procedure WriteBufferCancel; virtual;
    procedure WriteBufferClear; virtual;
    procedure WriteBufferClose; virtual;
    procedure WriteBufferFlush; overload; //.Net overload
    procedure WriteBufferFlush(AByteCount: Integer); overload; virtual;
    procedure WriteBufferOpen; overload; //.Net overload
    procedure WriteBufferOpen(AThreshold: Integer); overload; virtual;
    function WriteBufferingActive: Boolean;
    //
    // InputBuffer Methods
    //
    function InputBufferIsEmpty: Boolean;
    //
    // These two are direct access and do no reading of connection
    procedure InputBufferToStream(AStream: TStream; AByteCount: Integer = -1);
    function InputBufferAsString(AByteEncoding: IIdTextEncoding = nil
      {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
      ): string;
    //
    // Properties
    //
    property ConnectTimeout: Integer read FConnectTimeout write FConnectTimeout default 0;
    property ClosedGracefully: Boolean read FClosedGracefully;
                                                                            
    // but new model requires it for writing. Will decide after next set
    // of changes are complete what to do with Buffer prop.
    //
    // Is used by SuperCore
    property InputBuffer: TRESTDWBuffer read FInputBuffer;
    //currently an option, as LargeFile support changes the data format
    property LargeStream: Boolean read FLargeStream write FLargeStream;
    property MaxCapturedLines: Integer read FMaxCapturedLines write FMaxCapturedLines default Id_IOHandler_MaxCapturedLines;
    property Opened: Boolean read FOpened;
    property ReadTimeout: Integer read FReadTimeOut write FReadTimeOut default IdTimeoutDefault;
    property ReadLnTimedout: Boolean read FReadLnTimedout ;
    property WriteBufferThreshold: Integer read FWriteBufferThreshold;
    property DefStringEncoding : IIdTextEncoding read FDefStringEncoding write SetDefStringEncoding;
    {$IFDEF STRING_IS_ANSI}
    property DefAnsiEncoding : IIdTextEncoding read FDefAnsiEncoding write SetDefAnsiEncoding;
    {$ENDIF}
    //
    // Events
    //
    property OnWork;
    property OnWorkBegin;
    property OnWorkEnd;
  published
    property Destination: string read GetDestination write SetDestination;
    property Host: string read FHost write SetHost;
    property Intercept: TRESTDWConnectionIntercept read FIntercept write SetIntercept;
    property MaxLineLength: Integer read FMaxLineLength write FMaxLineLength default IdMaxLineLengthDefault;
    property MaxLineAction: TRESTDWMaxLineAction read FMaxLineAction write FMaxLineAction;
    property Port: Integer read FPort write SetPort;
    // RecvBufferSize is used by some methods that read large amounts of data.
    // RecvBufferSize is the amount of data that will be requested at each read
    // cycle. RecvBuffer is used to receive then send to the Intercepts, after
    // that it goes to InputBuffer
    property RecvBufferSize: Integer read FRecvBufferSize write FRecvBufferSize
     default GRecvBufferSizeDefault;
    // SendBufferSize is used by some methods that have to break apart large
    // amounts of data into smaller pieces. This is the buffer size of the
    // chunks that it will create and use.
    property SendBufferSize: Integer read FSendBufferSize write FSendBufferSize
     default GSendBufferSizeDefault;
  end;

implementation

uses
  //facilitate inlining only.
  {$IFDEF DOTNET}
    {$IFDEF USE_INLINE}
  System.IO,
    {$ENDIF}
  {$ENDIF}
  {$IFDEF WIN32_OR_WIN64}
  Windows,
  {$ENDIF}
  {$IFDEF USE_VCL_POSIX}
    {$IFDEF DARWIN}
  Macapi.CoreServices,
    {$ENDIF}
  {$ENDIF}
  {$IFDEF HAS_UNIT_Generics_Collections}
  System.Generics.Collections,
  {$ENDIF}
  IdStack, IdStackConsts, IdResourceStrings,
  SysUtils;

 Type
  TRESTDWIOHandlerClassList = TList;

var
  GIOHandlerClassDefault: TRESTDWIOHandlerClass = nil;
  GIOHandlerClassList: TRESTDWIOHandlerClassList = nil;

{$IFDEF DCC}
  {$IFNDEF VCL_7_OR_ABOVE}
    // RLebeau 5/13/2015: The Write(Int64) and ReadInt64() methods produce an
    // "Internal error URW533" compiler error in Delphi 5, and an "Internal
    // error URW699" compiler error in Delphi 6, so need to use some workarounds
    // for those versions...
    {$DEFINE AVOID_URW_ERRORS}
  {$ENDIF}
{$ENDIF}

{ TRESTDWIOHandler }

procedure TRESTDWIOHandler.Close;
//do not do FInputBuffer.Clear; here.
//it breaks reading when remote connection does a disconnect
var
  // under ARC, convert a weak reference to a strong reference before working with it
  LIntercept: TRESTDWConnectionIntercept;
begin
  try
    LIntercept := Intercept;
    if LIntercept <> nil then begin
      LIntercept.Disconnect;
    end;
  finally
    FOpened := False;
    WriteBufferClear;
  end;
end;

destructor TRESTDWIOHandler.Destroy;
begin
  Close;
  FreeAndNil(FInputBuffer);
  FreeAndNil(FWriteBuffer);
  inherited Destroy;
end;

procedure TRESTDWIOHandler.AfterAccept;
begin
  //
end;

procedure TRESTDWIOHandler.Open;
begin
  FOpened := False;
  FClosedGracefully := False;
  WriteBufferClear;
  FInputBuffer.Clear;
  FOpened := True;
end;

// under ARC, all weak references to a freed object get nil'ed automatically
{$IFNDEF USE_OBJECT_ARC}
procedure TRESTDWIOHandler.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FIntercept) then begin
    FIntercept := nil;
  end;
  inherited Notification(AComponent, OPeration);
end;
{$ENDIF}

procedure TRESTDWIOHandler.SetIntercept(AValue: TRESTDWConnectionIntercept);
begin
  {$IFDEF USE_OBJECT_ARC}
  // under ARC, all weak references to a freed object get nil'ed automatically
  FIntercept := AValue;
  {$ELSE}
  if FIntercept <> AValue then begin
    // remove self from the Intercept's free notification list
    if Assigned(FIntercept) then begin
      FIntercept.RemoveFreeNotification(Self);
    end;
    FIntercept := AValue;
    // add self to the Intercept's free notification list
    if Assigned(AValue) then begin
      AValue.FreeNotification(Self);
    end;
  end;
  {$ENDIF}
end;

class procedure TRESTDWIOHandler.SetDefaultClass;
begin
  GIOHandlerClassDefault := Self;
  RegisterIOHandler;
end;

procedure TRESTDWIOHandler.SetDefStringEncoding(const AEncoding: IIdTextEncoding);
var
  LEncoding: IIdTextEncoding;
begin
  if FDefStringEncoding <> AEncoding then
  begin
    LEncoding := AEncoding;
    EnsureEncoding(LEncoding);
    FDefStringEncoding := LEncoding;
  end;
end;

{$IFDEF STRING_IS_ANSI}
procedure TRESTDWIOHandler.SetDefAnsiEncoding(const AEncoding: IIdTextEncoding);
var
  LEncoding: IIdTextEncoding;
begin
  if FDefAnsiEncoding <> AEncoding then
  begin
    LEncoding := AEncoding;
    EnsureEncoding(LEncoding, encOSDefault);
    FDefAnsiEncoding := LEncoding;
  end;
end;
{$ENDIF}

class function TRESTDWIOHandler.MakeDefaultIOHandler(AOwner: TComponent = nil): TRESTDWIOHandler;
begin
  Result := GIOHandlerClassDefault.Create(AOwner);
end;

class procedure TRESTDWIOHandler.RegisterIOHandler;
begin
  if GIOHandlerClassList = nil then begin
    GIOHandlerClassList := TRESTDWIOHandlerClassList.Create;
  end;
  {$IFNDEF DOTNET_EXCLUDE}
                                                                       
  // Use an array?
  if GIOHandlerClassList.IndexOf(Self) = -1 then begin
    GIOHandlerClassList.Add(Self);
  end;
  {$ENDIF}
end;

{
  Creates an IOHandler of type ABaseType, or descendant.
}
class function TRESTDWIOHandler.MakeIOHandler(ABaseType: TRESTDWIOHandlerClass;
  AOwner: TComponent = nil): TRESTDWIOHandler;
begin
  Result := TryMakeIOHandler(ABaseType, AOwner);
  if not Assigned(Result) then begin
    raise EIdException.CreateFmt(RSIOHandlerTypeNotInstalled, [ABaseType.ClassName]);
  end;
end;

class function TRESTDWIOHandler.TryMakeIOHandler(ABaseType: TRESTDWIOHandlerClass;
  AOwner: TComponent = nil): TRESTDWIOHandler;
var
  i: Integer;
begin
  if GIOHandlerClassList <> nil then begin
    for i := GIOHandlerClassList.Count - 1 downto 0 do begin
      if TRESTDWIOHandlerClass(GIOHandlerClassList[i]).InheritsFrom(ABaseType) then begin
        Result := TRESTDWIOHandlerClass(GIOHandlerClassList[i]).Create;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

function TRESTDWIOHandler.GetDestination: string;
begin
  Result := FDestination;
end;

procedure TRESTDWIOHandler.SetDestination(const AValue: string);
begin
  FDestination := AValue;
end;

procedure TRESTDWIOHandler.BufferRemoveNotify(ASender: TObject; ABytes: Integer);
begin
  DoWork(wmRead, ABytes);
end;

procedure TRESTDWIOHandler.WriteBufferOpen(AThreshold: Integer);
begin
  if FWriteBuffer <> nil then begin
    FWriteBuffer.Clear;
  end else begin
    FWriteBuffer := TRESTDWBuffer.Create;
  end;
  FWriteBufferThreshold := AThreshold;
end;

procedure TRESTDWIOHandler.WriteBufferClose;
begin
  try
    WriteBufferFlush;
  finally FreeAndNil(FWriteBuffer); end;
end;

procedure TRESTDWIOHandler.WriteBufferFlush(AByteCount: Integer);
var
  LBytes: TRESTDWBytes;
begin
  if FWriteBuffer <> nil then begin
    if FWriteBuffer.Size > 0 then begin
      FWriteBuffer.ExtractToBytes(LBytes, AByteCount);
      WriteDirect(LBytes);
    end;
  end;
end;

procedure TRESTDWIOHandler.WriteBufferClear;
begin
  if FWriteBuffer <> nil then begin
    FWriteBuffer.Clear;
  end;
end;

procedure TRESTDWIOHandler.WriteBufferCancel;
begin
  WriteBufferClear;
  WriteBufferClose;
end;

procedure TRESTDWIOHandler.Write(const AOut: string; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
  );
begin
  if AOut <> '' then begin
    AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
    {$IFDEF STRING_IS_ANSI}
    ASrcEncoding := iif(ASrcEncoding, FDefAnsiEncoding, encOSDefault);
    {$ENDIF}
    Write(
      ToBytes(AOut, -1, 1, AByteEncoding
        {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
        )
      );
  end;
end;

procedure TRESTDWIOHandler.Write(AValue: Byte);
begin
  Write(ToBytes(AValue));
end;

procedure TRESTDWIOHandler.Write(AValue: Char; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
  );
begin
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ASrcEncoding := iif(ASrcEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  Write(
    ToBytes(AValue, AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
      )
    );
end;

procedure TRESTDWIOHandler.Write(AValue: UInt32; AConvert: Boolean = True);
begin
  if AConvert then begin
    AValue := GStack.HostToNetwork(AValue);
  end;
  Write(ToBytes(AValue));
end;

procedure TRESTDWIOHandler.Write(AValue: Int32; AConvert: Boolean = True);
begin
  if AConvert then begin
    AValue := Int32(GStack.HostToNetwork(UInt32(AValue)));
  end;
  Write(ToBytes(AValue));
end;

{$IFDEF HAS_UInt64}
  {$IFDEF BROKEN_UInt64_HPPEMIT}
    {$DEFINE HAS_TRESTDWUInt64_QuadPart}
  {$ENDIF}
{$ELSE}
  {$IFNDEF HAS_QWord}
    {$DEFINE HAS_TRESTDWUInt64_QuadPart}
  {$ENDIF}
{$ENDIF}

procedure TRESTDWIOHandler.Write(AValue: Int64; AConvert: Boolean = True);
{$IFDEF AVOID_URW_ERRORS}
var
  h: Int64;
{$ELSE}
  {$IFDEF HAS_TRESTDWUInt64_QuadPart}
var
  h: TRESTDWUInt64;
  {$ENDIF}
{$ENDIF}
begin
  if AConvert then begin
    {$IFDEF AVOID_URW_ERRORS}
    // assigning to a local variable to avoid an "Internal error URW533" compiler
    // error in Delphi 5, and an "Internal error URW699" compiler error in Delphi
    // 6.  Later versions seem OK without it...
    h := GStack.HostToNetwork(UInt64(AValue));
    AValue := h;
    {$ELSE}
      {$IFDEF HAS_TRESTDWUInt64_QuadPart}
    // assigning to a local variable if UInt64 is not a native type, or if using
    // a C++Builder version that has problems with UInt64 parameters...
    h.QuadPart := UInt64(AValue);
    h := GStack.HostToNetwork(h);
    AValue := Int64(h.QuadPart);
      {$ELSE}
    AValue := Int64(GStack.HostToNetwork(UInt64(AValue)));
      {$ENDIF}
    {$ENDIF}
  end;
  Write(ToBytes(AValue));
end;

procedure TRESTDWIOHandler.Write(AValue: TRESTDWUInt64; AConvert: Boolean = True);
begin
  if AConvert then begin
    AValue := GStack.HostToNetwork(AValue);
  end;
  Write(ToBytes(AValue));
end;

procedure TRESTDWIOHandler.Write(AValue: TStrings; AWriteLinesCount: Boolean = False;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
  );
var
  i: Integer;
  LBufferingStarted: Boolean;
begin
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ASrcEncoding := iif(ASrcEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  LBufferingStarted := not WriteBufferingActive;
  if LBufferingStarted then begin
    WriteBufferOpen;
  end;
  try
    if AWriteLinesCount then begin
      Write(AValue.Count);
    end;
    for i := 0 to AValue.Count - 1 do begin
      WriteLn(AValue.Strings[i], AByteEncoding
        {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
        );
    end;
    if LBufferingStarted then begin
      WriteBufferClose;
    end;
  except
    if LBufferingStarted then begin
      WriteBufferCancel;
    end;
    raise;
  end;
end;

procedure TRESTDWIOHandler.Write(AValue: UInt16; AConvert: Boolean = True);
begin
  if AConvert then begin
    AValue := GStack.HostToNetwork(AValue);
  end;
  Write(ToBytes(AValue));
end;

procedure TRESTDWIOHandler.Write(AValue: Int16; AConvert: Boolean = True);
begin
  if AConvert then begin
    AValue := Int16(GStack.HostToNetwork(UInt16(AValue)));
  end;
  Write(ToBytes(AValue));
end;

function TRESTDWIOHandler.ReadString(ABytes: Integer; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
var
  LBytes: TRESTDWBytes;
begin
  if ABytes > 0 then begin
    ReadBytes(LBytes, ABytes, False);
    AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
    {$IFDEF STRING_IS_ANSI}
    ADestEncoding := iif(ADestEncoding, FDefAnsiEncoding, encOSDefault);
    {$ENDIF}
    Result := BytesToString(LBytes, 0, ABytes, AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
      );
  end else begin
    Result := '';
  end;
end;

procedure TRESTDWIOHandler.ReadStrings(ADest: TStrings; AReadLinesCount: Integer = -1;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
var
  i: Integer;
begin
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ADestEncoding := iif(ADestEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  if AReadLinesCount < 0 then begin
    AReadLinesCount := ReadInt32;
  end;
  for i := 0 to AReadLinesCount - 1 do begin
    ADest.Add(ReadLn(AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
      ));
  end;
end;

function TRESTDWIOHandler.ReadUInt16(AConvert: Boolean = True): UInt16;
var
  LBytes: TRESTDWBytes;
begin
  ReadBytes(LBytes, SizeOf(UInt16), False);
  Result := BytesToUInt16(LBytes);
  if AConvert then begin
    Result := GStack.NetworkToHost(Result);
  end;
end;

{$I IdDeprecatedImplBugOff.inc}
function TRESTDWIOHandler.ReadWord(AConvert: Boolean = True): UInt16;
{$I IdDeprecatedImplBugOn.inc}
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := ReadUInt16(AConvert);
end;

function TRESTDWIOHandler.ReadInt16(AConvert: Boolean = True): Int16;
var
  LBytes: TRESTDWBytes;
begin
  ReadBytes(LBytes, SizeOf(Int16), False);
  Result := BytesToInt16(LBytes);
  if AConvert then begin
    Result := Int16(GStack.NetworkToHost(UInt16(Result)));
  end;
end;

{$I IdDeprecatedImplBugOff.inc}
function TRESTDWIOHandler.ReadSmallInt(AConvert: Boolean = True): Int16;
{$I IdDeprecatedImplBugOn.inc}
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := ReadInt16(AConvert);
end;

function TRESTDWIOHandler.ReadChar(AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): Char;
var
  I, J, NumChars, NumBytes: Integer;
  LBytes: TRESTDWBytes;
  {$IFDEF DOTNET}
  LChars: array[0..1] of Char;
  {$ELSE}
  LChars: TRESTDWWideChars;
    {$IFDEF STRING_IS_ANSI}
  LWTmp: TRESTDWUnicodeString;
  LATmp: TRESTDWBytes;
    {$ENDIF}
  {$ENDIF}
begin
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ADestEncoding := iif(ADestEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  // 2 Chars to handle UTF-16 surrogates
  NumBytes := AByteEncoding.GetMaxByteCount(2);
  SetLength(LBytes, NumBytes);
  {$IFNDEF DOTNET}
  SetLength(LChars, 2);
  {$ENDIF}
  NumChars := 0;
  if NumBytes > 0 then
  begin
    for I := 1 to NumBytes do
    begin
      LBytes[I-1] := ReadByte;
      NumChars := AByteEncoding.GetChars(LBytes, 0, I, LChars, 0);
      if NumChars > 0 then begin
        // RLebeau 10/19/2012: when Indy switched to its own UTF-8 implementation
        // to avoid the MB_ERR_INVALID_CHARS flag on Windows, it accidentally broke
        // this loop!  Since this is not commonly used, this was not noticed until
        // now.  On Windows at least, GetChars() now returns >0 for an invalid
        // sequence, so we have to check if any of the returned characters are the
        // Unicode U+FFFD character, indicating bad data...
        for J := 0 to NumChars-1 do begin
          if LChars[J] = TRESTDWWideChar($FFFD) then begin
            // keep reading...
            NumChars := 0;
            Break;
          end;
        end;
        if NumChars > 0 then begin
          Break;
        end;
      end;
    end;
  end;
  {$IFDEF STRING_IS_UNICODE}
  // RLebeau: if the bytes were decoded into surrogates, the second
  // surrogate is lost here, as it can't be returned unless we cache
  // it somewhere for the the next ReadChar() call to retreive.  Just
  // raise an error for now.  Users will have to update their code to
  // read surrogates differently...
  Assert(NumChars = 1);
  Result := LChars[0];
  {$ELSE}
  // RLebeau: since we can only return an AnsiChar here, let's convert
  // the decoded characters, surrogates and all, into their Ansi
  // representation. This will have the same problem as above if the
  // conversion results in a multibyte character sequence...
  SetString(LWTmp, PWideChar(LChars), NumChars);
  LATmp := ADestEncoding.GetBytes(LWTmp); // convert to Ansi
  Assert(Length(LATmp) = 1);
  Result := Char(LATmp[0]);
  {$ENDIF}
end;

function TRESTDWIOHandler.ReadByte: Byte;
var
  LBytes: TRESTDWBytes;
begin
  ReadBytes(LBytes, 1, False);
  Result := LBytes[0];
end;

function TRESTDWIOHandler.ReadInt32(AConvert: Boolean): Int32;
var
  LBytes: TRESTDWBytes;
begin
  ReadBytes(LBytes, SizeOf(Int32), False);
  Result := BytesToInt32(LBytes);
  if AConvert then begin
    Result := Int32(GStack.NetworkToHost(UInt32(Result)));
  end;
end;

{$I IdDeprecatedImplBugOff.inc}
function TRESTDWIOHandler.ReadLongInt(AConvert: Boolean): Int32;
{$I IdDeprecatedImplBugOn.inc}
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := ReadInt32(AConvert);
end;

function TRESTDWIOHandler.ReadInt64(AConvert: boolean): Int64;
var
  LBytes: TRESTDWBytes;
  {$IFDEF AVOID_URW_ERRORS}
  h: Int64;
  {$ELSE}
    {$IFDEF HAS_TRESTDWUInt64_QuadPart}
  h: TRESTDWUInt64;
    {$ENDIF}
  {$ENDIF}
begin
  ReadBytes(LBytes, SizeOf(Int64), False);
  Result := BytesToInt64(LBytes);
  if AConvert then begin
    {$IFDEF AVOID_URW_ERRORS}
    // assigning to a local variable to avoid an "Internal error URW533" compiler
    // error in Delphi 5, and an "Internal error URW699" compiler error in Delphi
    // 6.  Later versions seem OK without it...
    h := GStack.NetworkToHost(UInt64(Result));
    Result := h;
    {$ELSE}
      {$IFDEF HAS_TRESTDWUInt64_QuadPart}
    // assigning to a local variable if UInt64 is not a native type, or if using
    // a C++Builder version that has problems with UInt64 parameters...
    h.QuadPart := UInt64(Result);
    h := GStack.NetworkToHost(h);
    Result := Int64(h.QuadPart);
      {$ELSE}
    Result := Int64(GStack.NetworkToHost(UInt64(Result)));
      {$ENDIF}
    {$ENDIF}
  end;
end;

function TRESTDWIOHandler.ReadUInt64(AConvert: boolean): TRESTDWUInt64;
var
  LBytes: TRESTDWBytes;
begin
  ReadBytes(LBytes, SizeOf(TRESTDWUInt64), False);
  Result := BytesToUInt64(LBytes);
  if AConvert then begin
    Result := GStack.NetworkToHost(Result);
  end;
end;

function TRESTDWIOHandler.ReadUInt32(AConvert: Boolean): UInt32;
var
  LBytes: TRESTDWBytes;
begin
  ReadBytes(LBytes, SizeOf(UInt32), False);
  Result := BytesToUInt32(LBytes);
  if AConvert then begin
    Result := GStack.NetworkToHost(Result);
  end;
end;

{$I IdDeprecatedImplBugOff.inc}
function TRESTDWIOHandler.ReadLongWord(AConvert: Boolean): UInt32;
{$I IdDeprecatedImplBugOn.inc}
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := ReadUInt32(AConvert);
end;

function TRESTDWIOHandler.ReadLn(AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := ReadLn(LF, IdTimeoutDefault, -1, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

function TRESTDWIOHandler.ReadLn(ATerminator: string; AByteEncoding: IIdTextEncoding
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := ReadLn(ATerminator, IdTimeoutDefault, -1, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

function TRESTDWIOHandler.ReadLn(ATerminator: string; ATimeout: Integer = IdTimeoutDefault;
  AMaxLineLength: Integer = -1; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
var
  LInputBufferSize: Integer;
  LStartPos: Integer;
  LTermPos: Integer;
  LReadLnStartTime: TRESTDWTicks;
  LTerm, LResult: TRESTDWBytes;
begin
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ADestEncoding := iif(ADestEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  if AMaxLineLength < 0 then begin
    AMaxLineLength := MaxLineLength;
  end;
  // User may pass '' if they need to pass arguments beyond the first.
  if ATerminator = '' then begin
    ATerminator := LF;
  end;
                                                                              
  // a LF character to byte $25 instead of $0A (and decodes byte $0A to character
  // #$8E instead of #$A).  To account for that, don't encoding the LF using the
  // specified encoding anymore, force the encoding to what it should be.  But
  // what if UTF-16 is being used?
  {
  if ATerminator = LF then begin
    LTerm := ToBytes(Byte($0A));
  end else begin
    LTerm := ToBytes(ATerminator, AByteEncoding
      {$IFDEF STRING_IS_ANSI, ADestEncoding{$ENDIF
      );
  end;
  }
  LTerm := ToBytes(ATerminator, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
  FReadLnSplit := False;
  FReadLnTimedOut := False;
  LTermPos := -1;
  LStartPos := 0;
  LReadLnStartTime := Ticks64;
  repeat
    LInputBufferSize := FInputBuffer.Size;
    if LInputBufferSize > 0 then begin
      if LStartPos < LInputBufferSize then begin
        LTermPos := FInputBuffer.IndexOf(LTerm, LStartPos);
      end else begin
        LTermPos := -1;
      end;
      LStartPos := IndyMax(LInputBufferSize-(Length(LTerm)-1), 0);
    end;
    // if the line length is limited and terminator is found after the limit or not found and the limit is exceeded
    if (AMaxLineLength > 0) and ((LTermPos > AMaxLineLength) or ((LTermPos = -1) and (LStartPos > AMaxLineLength))) then begin
      if MaxLineAction = maException then begin
        raise EIdReadLnMaxLineLengthExceeded.Create(RSReadLnMaxLineLengthExceeded);
      end;
      // RLebeau: WARNING - if the line is using multibyte character sequences
      // and a sequence staddles the AMaxLineLength boundary, this will chop
      // the sequence, producing invalid data!
      FReadLnSplit := True;
      Result := FInputBuffer.ExtractToString(AMaxLineLength, AByteEncoding
        {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
        );
      Exit;
    end
    // ReadFromSource blocks - do not call unless we need to
    else if LTermPos = -1 then begin
      // ReadLn needs to call this as data may exist in the buffer, but no EOL yet disconnected
      CheckForDisconnect(True, True);
      // Can only return -1 if timeout
      FReadLnTimedOut := ReadFromSource(True, ATimeout, False) = -1;
      if (not FReadLnTimedOut) and (ATimeout >= 0) then begin
        if GetElapsedTicks(LReadLnStartTime) >= UInt32(ATimeout) then begin
          FReadLnTimedOut := True;
        end;
      end;
      if FReadLnTimedOut then begin
        Result := '';
        Exit;
      end;
    end;
  until LTermPos > -1;
  // Extract actual data
  {
  IMPORTANT!!!

   When encoding from UTF8 to Unicode or ASCII, you will not always get the same
   number of bytes that you input so you may have to recalculate LTermPos since
   that was based on the number of bytes in the input stream.  If do not do this,
   you will probably get an incorrect result or a range check error since the
   string is shorter then the original buffer position.

   JPM
   }
  // RLebeau 11/19/08: this is no longer needed as the terminator is encoded to raw bytes now ...
  {
  Result := FInputBuffer.Extract(LTermPos + Length(ATerminator), AEncoding);
  LTermPos := IndyMin(LTermPos, Length(Result));
  if (ATerminator = LF) and (LTermPos > 0) then begin
    if Result[LTermPos] = CR then begin
      Dec(LTermPos);
    end;
  end;
  SetLength(Result, LTermPos);
  }
  FInputBuffer.ExtractToBytes(LResult, LTermPos + Length(LTerm));
  if (ATerminator = LF) and (LTermPos > 0) then begin
    if LResult[LTermPos-1] = Ord(CR) then begin
      Dec(LTermPos);
    end;
  end;
  Result := BytesToString(LResult, 0, LTermPos, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

function TRESTDWIOHandler.ReadLnRFC(var VMsgEnd: Boolean;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := ReadLnRFC(VMsgEnd, LF, '.', AByteEncoding   {do not localize}
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

function TRESTDWIOHandler.ReadLnRFC(var VMsgEnd: Boolean; const ALineTerminator: string;
  const ADelim: String = '.'; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
begin
  Result := ReadLn(ALineTerminator, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
  // Do not use ATerminator since always ends with . (standard)
  if Result = ADelim then
  begin
    VMsgEnd := True;
    Exit;
  end;
  if TextStartsWith(Result, '..') then begin {do not localize}
    Delete(Result, 1, 1);
  end;
  VMsgEnd := False;
end;

function TRESTDWIOHandler.ReadLnSplit(var AWasSplit: Boolean; ATerminator: string = LF;
  ATimeout: Integer = IdTimeoutDefault; AMaxLineLength: Integer = -1;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
var
  FOldAction: TRESTDWMaxLineAction;
begin
  FOldAction := MaxLineAction;
  MaxLineAction := maSplit;
  try
    Result := ReadLn(ATerminator, ATimeout, AMaxLineLength, AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
      );
    AWasSplit := FReadLnSplit;
  finally
    MaxLineAction := FOldAction;
  end;
end;

function TRESTDWIOHandler.ReadLnWait(AFailCount: Integer = MaxInt;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
var
  LAttempts: Integer;
begin
  // MtW: this is mostly used when empty lines could be sent.
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ADestEncoding := iif(ADestEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  Result := '';
  LAttempts := 0;
  while LAttempts < AFailCount do
  begin
    Result := Trim(ReadLn(AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
      ));
    if Length(Result) > 0 then begin
      Exit;
    end;
    if ReadLnTimedOut then begin
      raise EIdReadTimeout.Create(RSReadTimeout);
    end;
    Inc(LAttempts);
  end;
  raise EIdReadLnWaitMaxAttemptsExceeded.Create(RSReadLnWaitMaxAttemptsExceeded);
end;

function TRESTDWIOHandler.ReadFromSource(ARaiseExceptionIfDisconnected: Boolean;
  ATimeout: Integer; ARaiseExceptionOnTimeout: Boolean): Integer;
var
  LByteCount: Integer;
  LLastError: Integer;
  LBuffer: TRESTDWBytes;
  // under ARC, convert a weak reference to a strong reference before working with it
  LIntercept: TRESTDWConnectionIntercept;
begin
  if ATimeout = IdTimeoutDefault then begin
    // MtW: check for 0 too, for compatibility
    if (ReadTimeout = IdTimeoutDefault) or (ReadTimeout = 0) then begin
      ATimeout := IdTimeoutInfinite;
    end else begin
      ATimeout := ReadTimeout;
    end;
  end;
  Result := 0;
  // Check here as this side may have closed the socket
  CheckForDisconnect(ARaiseExceptionIfDisconnected);
  if SourceIsAvailable then begin
    repeat
      LByteCount := 0;
      if Readable(ATimeout) then begin
        if Opened then begin
          // No need to call AntiFreeze, the Readable does that.
          if SourceIsAvailable then begin
                                                                      
            // should be a one time operation per connection.

            // RLebeau: because the Intercept does not allow the buffer
            // size to be specified, and the Intercept could potentially
            // resize the buffer...

            SetLength(LBuffer, RecvBufferSize);
            try
              LByteCount := ReadDataFromSource(LBuffer);
              if LByteCount > 0 then begin
                SetLength(LBuffer, LByteCount);

                LIntercept := Intercept;
                if LIntercept <> nil then begin
                  LIntercept.Receive(LBuffer);
                  {$IFDEF USE_OBJECT_ARC}LIntercept := nil;{$ENDIF}
                  LByteCount := Length(LBuffer);
                end;

                // Pass through LBuffer first so it can go through Intercept
                                                               
                InputBuffer.Write(LBuffer);
              end;
            finally
              LBuffer := nil;
            end;
          end
          else if ARaiseExceptionIfDisconnected then begin
            raise EIdClosedSocket.Create(RSStatusDisconnected);
          end;
        end
        else if ARaiseExceptionIfDisconnected then begin
          raise EIdNotConnected.Create(RSNotConnected);
        end;
        if LByteCount < 0 then
        begin
          LLastError := CheckForError(LByteCount);
          if LLastError = Id_WSAETIMEDOUT then begin
            // Timeout
            if ARaiseExceptionOnTimeout then begin
              raise EIdReadTimeout.Create(RSReadTimeout);
            end;
            Result := -1;
            Break;
          end;
          FClosedGracefully := True;
          Close;
          // Do not raise unless all data has been read by the user
          if InputBufferIsEmpty and ARaiseExceptionIfDisconnected then begin
            RaiseError(LLastError);
          end;
          LByteCount := 0;
        end
        else if LByteCount = 0 then begin
          FClosedGracefully := True;
        end;
        // Check here as other side may have closed connection
        CheckForDisconnect(ARaiseExceptionIfDisconnected);
        Result := LByteCount;
      end else begin
        // Timeout
        if ARaiseExceptionOnTimeout then begin
          raise EIdReadTimeout.Create(RSReadTimeout);
        end;
        Result := -1;
        Break;
      end;
    until (LByteCount <> 0) or (not SourceIsAvailable);
  end
  else if ARaiseExceptionIfDisconnected then begin
    raise EIdNotConnected.Create(RSNotConnected);
  end;
end;

function TRESTDWIOHandler.CheckForDataOnSource(ATimeout: Integer = 0): Boolean;
var
  LPrevSize: Integer;
begin
  Result := False;
  // RLebeau - Connected() might read data into the InputBuffer, thus
  // leaving no data for ReadFromSource() to receive a second time,
  // causing a result of False when it should be True instead.  So we
  // save the current size of the InputBuffer before calling Connected()
  // and then compare it afterwards....
  LPrevSize := InputBuffer.Size;
  if Connected then begin
    // return whether at least 1 byte was received
    Result := (InputBuffer.Size > LPrevSize) or (ReadFromSource(False, ATimeout, False) > 0);
  end;
end;

procedure TRESTDWIOHandler.Write(AStream: TStream; ASize: TRESTDWStreamSize = 0;
  AWriteByteCount: Boolean = FALSE);
var
  LBuffer: TRESTDWBytes;
  LStreamPos: TRESTDWStreamSize;
  LBufSize: Integer;
  // LBufferingStarted: Boolean;
begin
  if ASize < 0 then begin //"-1" All from current position
    LStreamPos := AStream.Position;
    ASize := AStream.Size - LStreamPos;
                                 
    AStream.Position := LStreamPos;
  end
  else if ASize = 0 then begin //"0" ALL
    ASize := AStream.Size;
    AStream.Position := 0;
  end;
  //else ">0" number of bytes

  // RLebeau 3/19/2006: DO NOT ENABLE WRITE BUFFERING IN THIS METHOD!
  //
  // When sending large streams, especially with LargeStream enabled,
  // this can easily cause "Out of Memory" errors.  It is the caller's
  // responsibility to enable/disable write buffering as needed before
  // calling one of the Write() methods.
  //
  // Also, forcing write buffering in this method is having major
  // impacts on TRESTDWFTP, TRESTDWFTPServer, and TRESTDWHTTPServer.

  if AWriteByteCount then begin
    if LargeStream then begin
      Write(Int64(ASize));
    end else begin
      {$IFDEF STREAM_SIZE_64}
      if ASize > High(Integer) then begin
        raise EIdIOHandlerRequiresLargeStream.Create(RSRequiresLargeStream);
      end;
      {$ENDIF}
      Write(Int32(ASize));
    end;
  end;

  BeginWork(wmWrite, ASize);
  try
    SetLength(LBuffer, FSendBufferSize);
    while ASize > 0 do begin
      LBufSize := IndyMin(ASize, Length(LBuffer));
      // Do not use ReadBuffer. Some source streams are real time and will not
      // return as much data as we request. Kind of like recv()
      // NOTE: We use .Size - size must be supported even if real time
      LBufSize := TRESTDWStreamHelper.ReadBytes(AStream, LBuffer, LBufSize);
      if LBufSize <= 0 then begin
        raise EIdNoDataToRead.Create(RSIdNoDataToRead);
      end;
      Write(LBuffer, LBufSize);
      // RLebeau: DoWork() is called in WriteDirect()
      //DoWork(wmWrite, LBufSize);
      Dec(ASize, LBufSize);
    end;
  finally
    EndWork(wmWrite);
    LBuffer := nil;
  end;
end;

procedure TRESTDWIOHandler.ReadBytes(var VBuffer: TRESTDWBytes; AByteCount: Integer; AAppend: Boolean = True);
begin
  Assert(FInputBuffer<>nil);
  if AByteCount > 0 then begin
    // Read from stack until we have enough data
    while FInputBuffer.Size < AByteCount do begin
      // RLebeau: in case the other party disconnects
      // after all of the bytes were transmitted ok.
      // No need to throw an exception just yet...
      if ReadFromSource(False) > 0 then begin
        if FInputBuffer.Size >= AByteCount then begin
          Break; // we have enough data now
        end;
      end;
      CheckForDisconnect(True, True);
    end;
    FInputBuffer.ExtractToBytes(VBuffer, AByteCount, AAppend);
  end else if AByteCount < 0 then begin
    ReadFromSource(False, ReadTimeout, False);
    CheckForDisconnect(True, True);
    FInputBuffer.ExtractToBytes(VBuffer, -1, AAppend);
  end;
end;

procedure TRESTDWIOHandler.WriteLn(AEncoding: IIdTextEncoding = nil);
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  {$IFNDEF VCL_6_OR_ABOVE}
  // RLebeau: in Delphi 5, explicitly specifying the nil value for the third
  // parameter causes a "There is no overloaded version of 'WriteLn' that can
  // be called with these arguments" compiler error.  Must be a compiler bug,
  // because it compiles fine in Delphi 6.  The parameter value is nil by default
  // anyway, so we don't really need to specify it here at all, but I'm documenting
  // this so we know for future reference...
  //
  WriteLn('', AEncoding);
  {$ELSE}
  WriteLn('', AEncoding{$IFDEF STRING_IS_ANSI}, nil{$ENDIF});
  {$ENDIF}
end;

procedure TRESTDWIOHandler.WriteLn(const AOut: string;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
  );
begin
                                                                                  
  // which encodes a LF character to byte $25 instead of $0A (and decodes
  // byte $0A to character #$8E instead of #$A).  To account for that, don't
  // encoding the CRLF using the specified encoding anymore, force the encoding
  // to what it should be...
  //
  // But, what to do if the target encoding is UTF-16?
  {
  Write(AOut, AByteEncoding{$IFDEF STRING_IS_ANSI, ASrcEncoding{$ENDIF);
  Write(EOL, Indy8BitEncoding{$IFDEF STRING_IS_ANSI, Indy8BitEncoding{$ENDIF);
  }

  // Do as one write so it only makes one call to network
  Write(AOut + EOL, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
    );
end;

procedure TRESTDWIOHandler.WriteLnRFC(const AOut: string = '';
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
  );
begin
  if TextStartsWith(AOut, '.') then begin {do not localize}
    WriteLn('.' + AOut, AByteEncoding     {do not localize}
      {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
      );
  end else begin
    WriteLn(AOut, AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
      );
  end;
end;

function TRESTDWIOHandler.Readable(AMSec: Integer): Boolean;
begin
  // In case descendant does not override this or other methods but implements the higher level
  // methods
  Result := False;
end;

procedure TRESTDWIOHandler.SetHost(const AValue: string);
begin
  FHost := AValue;
end;

procedure TRESTDWIOHandler.SetPort(AValue: Integer);
begin
  FPort := AValue;
end;

function TRESTDWIOHandler.Connected: Boolean;
begin
  CheckForDisconnect(False);
  Result :=
   (
     (
       // Set when closed properly. Reflects actual socket state.
       (not ClosedGracefully)
       // Created on Open. Prior to Open ClosedGracefully is still false.
       and (FInputBuffer <> nil)
     )
     // Buffer must be empty. Even if closed, we are "connected" if we still have
     // data
     or (not InputBufferIsEmpty)
   )
   and Opened;
end;

                                    
procedure AdjustStreamSize(const AStream: TStream; const ASize: TRESTDWStreamSize);
var
  LStreamPos: TRESTDWStreamSize;
begin
  LStreamPos := AStream.Position;
  AStream.Size := ASize;
  // Must reset to original value in cases where size changes position
  if AStream.Position <> LStreamPos then begin
    AStream.Position := LStreamPos;
  end;
end;

procedure TRESTDWIOHandler.ReadStream(AStream: TStream; AByteCount: TRESTDWStreamSize;
  AReadUntilDisconnect: Boolean);
var
  i: Integer;
  LBuf: TRESTDWBytes;
  LByteCount, LPos: TRESTDWStreamSize;
  {$IFNDEF STREAM_SIZE_64}
  LTmp: Int64;
  {$ENDIF}
const
  cSizeUnknown = -1;
begin
  if (AByteCount = cSizeUnknown) and (not AReadUntilDisconnect) then begin
    // Read size from connection
    if LargeStream then begin
      {$IFDEF STREAM_SIZE_64}
      LByteCount := ReadInt64;
      {$ELSE}
      LTmp := ReadInt64;
      if LTmp > MaxInt then begin
        raise EIdIOHandlerStreamDataTooLarge.Create(RSDataTooLarge);
      end;
      LByteCount := TRESTDWStreamSize(LTmp);
      {$ENDIF}
    end else begin
      LByteCount := ReadInt32;
    end;
  end else begin
    LByteCount := AByteCount;
  end;

  // Presize stream if we know the size - this reduces memory/disk allocations to one time
  // Have an option for this? user might not want to presize, eg for int64 files
  if (AStream <> nil) and (LByteCount > -1) then begin
    LPos := AStream.Position;
    if (High(TRESTDWStreamSize) - LPos) < LByteCount then begin
      raise EIdIOHandlerStreamDataTooLarge.Create(RSDataTooLarge);
    end;
    AdjustStreamSize(AStream, LPos + LByteCount);
  end;

  if (LByteCount <= cSizeUnknown) and (not AReadUntilDisconnect) then begin
    AReadUntilDisconnect := True;
  end;

  if AReadUntilDisconnect then begin
    BeginWork(wmRead);
  end else begin
    BeginWork(wmRead, LByteCount);
  end;

  try
    // If data already exists in the buffer, write it out first.
    // should this loop for all data in buffer up to workcount? not just one block?
    if FInputBuffer.Size > 0 then begin
      if AReadUntilDisconnect then begin
        i := FInputBuffer.Size;
      end else begin
        i := IndyMin(FInputBuffer.Size, LByteCount);
        Dec(LByteCount, i);
      end;
      if AStream <> nil then begin
        FInputBuffer.ExtractToStream(AStream, i);
      end else begin
        FInputBuffer.Remove(i);
      end;
    end;

    // RLebeau - don't call Connected() here!  ReadBytes() already
    // does that internally. Calling Connected() here can cause an
    // EIdConnClosedGracefully exception that breaks the loop
    // prematurely and thus leave unread bytes in the InputBuffer.
    // Let the loop catch the exception before exiting...

    SetLength(LBuf, RecvBufferSize); // preallocate the buffer
    repeat
      if AReadUntilDisconnect then begin
        i := Length(LBuf);
      end else begin
        i := IndyMin(LByteCount, Length(LBuf));
        if i < 1 then begin
          Break;
        end;
      end;

                                                                       
                                                                                           

                                                                           
      //ReadFromSource() directly to populate the InputBuffer (ReadBytes()
      //would have done that anyway) and then use InputBuffer.ExtractToStream()
      //to copy directly into the TStream. We don't really need another memory
      //buffer here...

      try
        try
          ReadBytes(LBuf, i, False);
        except
          on E: Exception do begin
            // RLebeau - ReadFromSource() inside of ReadBytes()
            // could have filled the InputBuffer with more bytes
            // than actually requested, so don't extract too
            // many bytes here...
            i := IndyMin(i, FInputBuffer.Size);
            FInputBuffer.ExtractToBytes(LBuf, i, False);
            if AReadUntilDisconnect then begin
              if E is EIdConnClosedGracefully then begin
                Exit;
              end
              else if E is EIdSocketError then begin
                case EIdSocketError(E).LastError of
                  Id_WSAESHUTDOWN, Id_WSAECONNABORTED, Id_WSAECONNRESET: begin
                    Exit;
                  end;
                end;
              end;
            end;
            raise;
          end;
        end;
        TRESTDWAntiFreezeBase.DoProcess;
      finally
        if i > 0 then begin
          if AStream <> nil then begin
            TRESTDWStreamHelper.Write(AStream, LBuf, i);
          end;
          if not AReadUntilDisconnect then begin
            Dec(LByteCount, i);
          end;
        end;
      end;
    until False;
  finally
    EndWork(wmRead);
    if AStream <> nil then begin
      if AStream.Size > AStream.Position then begin
        AStream.Size := AStream.Position;
      end;
    end;
    LBuf := nil;
  end;
end;

procedure TRESTDWIOHandler.Discard(AByteCount: Int64);
var
  LSize: Integer;
begin
  Assert(AByteCount >= 0);
  if AByteCount > 0 then
  begin
    BeginWork(wmRead, AByteCount);
    try
      repeat
        LSize := iif(AByteCount < MaxInt, Integer(AByteCount), MaxInt);
        LSize := IndyMin(LSize, FInputBuffer.Size);
        if LSize > 0 then begin
          FInputBuffer.Remove(LSize);
          Dec(AByteCount, LSize);
          if AByteCount < 1 then begin
            Break;
          end;
        end;
        // RLebeau: in case the other party disconnects
        // after all of the bytes were transmitted ok.
        // No need to throw an exception just yet...
        if ReadFromSource(False) < 1 then begin
          CheckForDisconnect(True, True);
        end;
      until False;
    finally
      EndWork(wmRead);
    end;
  end;
end;

procedure TRESTDWIOHandler.DiscardAll;
begin
  BeginWork(wmRead);
  try
    // If data already exists in the buffer, discard it first.
    FInputBuffer.Clear;
    // RLebeau - don't call Connected() here!  ReadBytes() already
    // does that internally. Calling Connected() here can cause an
    // EIdConnClosedGracefully exception that breaks the loop
    // prematurely and thus leave unread bytes in the InputBuffer.
    // Let the loop catch the exception before exiting...
    repeat
                                                                       
      try
        if ReadFromSource(False) > 0 then begin
          FInputBuffer.Clear;
        end else begin;
          CheckForDisconnect(True, True);
        end;
      except
        on E: Exception do begin
          // RLebeau - ReadFromSource() could have filled the
          // InputBuffer with more bytes...
          FInputBuffer.Clear;
          if E is EIdConnClosedGracefully then begin
            Break;
          end else begin
            raise;
          end;
        end;
      end;
      TRESTDWAntiFreezeBase.DoProcess;
    until False;
  finally
    EndWork(wmRead);
  end;
end;

procedure TRESTDWIOHandler.RaiseConnClosedGracefully;
begin
  (* ************************************************************* //
  ------ If you receive an exception here, please read. ----------

  If this is a SERVER
  -------------------
  The client has disconnected the socket normally and this exception is used to notify the
  server handling code. This exception is normal and will only happen from within the IDE, not
  while your program is running as an EXE. If you do not want to see this, add this exception
  or EIdSilentException to the IDE options as exceptions not to break on.

  From the IDE just hit F9 again and Indy will catch and handle the exception.

  Please see the FAQ and help file for possible further information.
  The FAQ is at http://www.nevrona.com/Indy/FAQ.html

  If this is a CLIENT
  -------------------
  The server side of this connection has disconnected normaly but your client has attempted
  to read or write to the connection. You should trap this error using a try..except.
  Please see the help file for possible further information.

  // ************************************************************* *)
  raise EIdConnClosedGracefully.Create(RSConnectionClosedGracefully);
end;

function TRESTDWIOHandler.InputBufferAsString(AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
begin
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ADestEncoding := iif(ADestEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  Result := FInputBuffer.ExtractToString(FInputBuffer.Size, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

function TRESTDWIOHandler.AllData(AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
var
  LBytes: Integer;
begin
  Result := '';
  BeginWork(wmRead);
  try
    if Connected then
    begin
      try
        try
          repeat
            LBytes := ReadFromSource(False, 250, False);
          until LBytes = 0; // -1 on timeout
        finally
          if not InputBufferIsEmpty then begin
            Result := InputBufferAsString(AByteEncoding
              {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
              );
          end;
        end;
      except end;
    end;
  finally
    EndWork(wmRead);
  end;
end;

procedure TRESTDWIOHandler.PerformCapture(const ADest: TObject;
  out VLineCount: Integer; const ADelim: string;
  AUsesDotTransparency: Boolean; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
var
  s: string;
  LStream: TStream;
  LStrings: TStrings;
begin
  VLineCount := 0;

  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ADestEncoding := iif(ADestEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}

  LStream := nil;
  LStrings := nil;

  if ADest is TStrings then begin
    LStrings := TStrings(ADest);
  end
  else if ADest is TStream then begin
    LStream := TStream(ADest);
  end
  else begin
    raise EIdObjectTypeNotSupported.Create(RSObjectTypeNotSupported);
  end;

  BeginWork(wmRead);
  try
    repeat
      s := ReadLn(AByteEncoding
        {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
        );
      if s = ADelim then begin
        Exit;
      end;
      // S.G. 6/4/2004: All the consumers to protect themselves against memory allocation attacks
      if FMaxCapturedLines > 0 then  begin
        if VLineCount > FMaxCapturedLines then begin
          raise EIdMaxCaptureLineExceeded.Create(RSMaximumNumberOfCaptureLineExceeded);
        end;
      end;
      // For RFC retrieves that use dot transparency
      // No length check necessary, if only one byte it will be byte x + #0.
      if AUsesDotTransparency then begin
        if TextStartsWith(s, '..') then begin
          Delete(s, 1, 1);
        end;
      end;
      // Write to output
      Inc(VLineCount);
      if LStrings <> nil then begin
        LStrings.Add(s);
      end
      else if LStream <> nil then begin
        WriteStringToStream(LStream, s+EOL, AByteEncoding
          {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
          );
      end;
    until False;
  finally
    EndWork(wmRead);
  end;
end;

function TRESTDWIOHandler.InputLn(const AMask: String = ''; AEcho: Boolean = True;
  ATabWidth: Integer = 8; AMaxLineLength: Integer = -1;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; AAnsiEncoding: IIdTextEncoding = nil{$ENDIF}
  ): String;
var
  i: Integer;
  LChar: Char;
  LTmp: string;
begin
  Result := '';
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  AAnsiEncoding := iif(AAnsiEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  if AMaxLineLength < 0 then begin
    AMaxLineLength := MaxLineLength;
  end;
  repeat
    LChar := ReadChar(AByteEncoding
      {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
      );
    i := Length(Result);
    if i <= AMaxLineLength then begin
      case LChar of
        BACKSPACE:
          begin
            if i > 0 then begin
              SetLength(Result, i - 1);
              if AEcho then begin
                Write(BACKSPACE + ' ' + BACKSPACE, AByteEncoding
                  {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
                  );
              end;
            end;
          end;
        TAB:
          begin
            if ATabWidth > 0 then begin
              i := ATabWidth - (i mod ATabWidth);
              LTmp := StringOfChar(' ', i);
              Result := Result + LTmp;
              if AEcho then begin
                Write(LTmp, AByteEncoding
                  {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
                  );
              end;
            end else begin
              Result := Result + LChar;
              if AEcho then begin
                Write(LChar, AByteEncoding
                  {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
                  );
              end;
            end;
          end;
        LF: ;
        CR: ;
        #27: ; //ESC - currently not supported
      else
        Result := Result + LChar;
        if AEcho then begin
          if Length(AMask) = 0 then begin
            Write(LChar, AByteEncoding
              {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
              );
          end else begin
            Write(AMask, AByteEncoding
              {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
              );
          end;
        end;
      end;
    end;
  until LChar = LF;
  // Remove CR trail
  i := Length(Result);
  while (i > 0) and CharIsInSet(Result, i, EOL) do begin
    Dec(i);
  end;
  SetLength(Result, i);
  if AEcho then begin
    WriteLn(AByteEncoding);
  end;
end;

                                                                   
                                        
                                     
function TRESTDWIOHandler.WaitFor(const AString: string; ARemoveFromBuffer: Boolean = True;
  AInclusive: Boolean = False; AByteEncoding: IIdTextEncoding = nil;
  ATimeout: Integer = IdTimeoutDefault
  {$IFDEF STRING_IS_ANSI}; AAnsiEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
var
  LBytes: TRESTDWBytes;
  LPos: Integer;
begin
  Result := '';
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  AAnsiEncoding := iif(AAnsiEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  LBytes := ToBytes(AString, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
    );
  LPos := 0;
  repeat
    LPos := InputBuffer.IndexOf(LBytes, LPos);
    if LPos <> -1 then begin
      if ARemoveFromBuffer and AInclusive then begin
        Result := InputBuffer.ExtractToString(LPos+Length(LBytes), AByteEncoding
          {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
          );
      end else begin
        Result := InputBuffer.ExtractToString(LPos, AByteEncoding
          {$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF}
          );
        if ARemoveFromBuffer then begin
          InputBuffer.Remove(Length(LBytes));
        end;
        if AInclusive then begin
          Result := Result + AString;
        end;
      end;
      Exit;
    end;
    LPos := IndyMax(0, InputBuffer.Size - (Length(LBytes)-1));
    ReadFromSource(True, ATimeout, True);
  until False;
end;

procedure TRESTDWIOHandler.Capture(ADest: TStream; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Capture(ADest, '.', True, AByteEncoding     {do not localize}
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

procedure TRESTDWIOHandler.Capture(ADest: TStream; out VLineCount: Integer;
  const ADelim: string = '.'; AUsesDotTransparency: Boolean = True;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  PerformCapture(ADest, VLineCount, ADelim, AUsesDotTransparency, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

procedure TRESTDWIOHandler.Capture(ADest: TStream; ADelim: string;
  AUsesDotTransparency: Boolean = True; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
var
  LLineCount: Integer;
begin
  PerformCapture(ADest, LLineCount, '.', AUsesDotTransparency, AByteEncoding   {do not localize}
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

procedure TRESTDWIOHandler.Capture(ADest: TStrings; out VLineCount: Integer;
  const ADelim: string = '.'; AUsesDotTransparency: Boolean = True;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  PerformCapture(ADest, VLineCount, ADelim, AUsesDotTransparency, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

procedure TRESTDWIOHandler.Capture(ADest: TStrings; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
var
  LLineCount: Integer;
begin
  PerformCapture(ADest, LLineCount, '.', True, AByteEncoding    {do not localize}
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

procedure TRESTDWIOHandler.Capture(ADest: TStrings; const ADelim: string;
  AUsesDotTransparency: Boolean = True; AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  );
var
  LLineCount: Integer;
begin
  PerformCapture(ADest, LLineCount, ADelim, AUsesDotTransparency, AByteEncoding
    {$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF}
    );
end;

procedure TRESTDWIOHandler.InputBufferToStream(AStream: TStream; AByteCount: Integer = -1);
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  FInputBuffer.ExtractToStream(AStream, AByteCount);
end;

function TRESTDWIOHandler.InputBufferIsEmpty: Boolean;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := FInputBuffer.Size = 0;
end;

procedure TRESTDWIOHandler.Write(const ABuffer: TRESTDWBytes; const ALength: Integer = -1;
  const AOffset: Integer = 0);
var
  LLength: Integer;
begin
  LLength := IndyLength(ABuffer, ALength, AOffset);
  if LLength > 0 then begin
    if FWriteBuffer = nil then begin
      WriteDirect(ABuffer, LLength, AOffset);
    end else begin
      // Write Buffering is enabled
      FWriteBuffer.Write(ABuffer, LLength, AOffset);
      if (FWriteBuffer.Size >= WriteBufferThreshold) and (WriteBufferThreshold > 0) then begin
        repeat
          WriteBufferFlush(WriteBufferThreshold);
        until FWriteBuffer.Size < WriteBufferThreshold;
      end;
    end;
  end;
end;

procedure TRESTDWIOHandler.WriteRFCStrings(AStrings: TStrings; AWriteTerminator: Boolean = True;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ASrcEncoding: IIdTextEncoding = nil{$ENDIF}
  );
var
  i: Integer;
begin
  AByteEncoding := iif(AByteEncoding, FDefStringEncoding);
  {$IFDEF STRING_IS_ANSI}
  ASrcEncoding := iif(ASrcEncoding, FDefAnsiEncoding, encOSDefault);
  {$ENDIF}
  for i := 0 to AStrings.Count - 1 do begin
    WriteLnRFC(AStrings[i], AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
      );
  end;
  if AWriteTerminator then begin
    WriteLn('.', AByteEncoding
      {$IFDEF STRING_IS_ANSI}, ASrcEncoding{$ENDIF}
      );
  end;
end;

function TRESTDWIOHandler.WriteFile(const AFile: String; AEnableTransferFile: Boolean): Int64;
var
                                                                           
  LStream: TStream;
  {$IFDEF WIN32_OR_WIN64}
  LOldErrorMode : Integer;
  {$ENDIF}
begin
  Result := 0;
  {$IFDEF WIN32_OR_WIN64}
  LOldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
  {$ENDIF}
    if not FileExists(AFile) then begin
      raise EIdFileNotFound.CreateFmt(RSFileNotFound, [AFile]);
    end;
    LStream := TRESTDWReadFileExclusiveStream.Create(AFile);
    try
      Write(LStream);
      Result := LStream.Size;
    finally
      FreeAndNil(LStream);
    end;
  {$IFDEF WIN32_OR_WIN64}
  finally
    SetErrorMode(LOldErrorMode)
  end;
  {$ENDIF}
end;

function TRESTDWIOHandler.WriteBufferingActive: Boolean;
{$IFDEF USE_CLASSINLINE}inline;{$ENDIF}
begin
  Result := FWriteBuffer <> nil;
end;

procedure TRESTDWIOHandler.CloseGracefully;
begin
  FClosedGracefully := True
end;

procedure TRESTDWIOHandler.InterceptReceive(var VBuffer: TRESTDWBytes);
var
  // under ARC, convert a weak reference to a strong reference before working with it
  LIntercept: TRESTDWConnectionIntercept;
begin
  LIntercept := Intercept;
  if LIntercept <> nil then begin
    LIntercept.Receive(VBuffer);
  end;
end;

procedure TRESTDWIOHandler.InitComponent;
begin
  inherited InitComponent;
  FRecvBufferSize := GRecvBufferSizeDefault;
  FSendBufferSize := GSendBufferSizeDefault;
  FMaxLineLength := IdMaxLineLengthDefault;
  FMaxCapturedLines := Id_IOHandler_MaxCapturedLines;
  FLargeStream := False;
  FReadTimeOut := IdTimeoutDefault;
  FInputBuffer := TRESTDWBuffer.Create(BufferRemoveNotify);
  FDefStringEncoding := IndyTextEncoding_ASCII;
  {$IFDEF STRING_IS_ANSI}
  FDefAnsiEncoding := IndyTextEncoding_OSDefault;
  {$ENDIF}
end;

procedure TRESTDWIOHandler.WriteBufferFlush;
begin
  WriteBufferFlush(-1);
end;

procedure TRESTDWIOHandler.WriteBufferOpen;
begin
  WriteBufferOpen(-1);
end;

procedure TRESTDWIOHandler.WriteDirect(const ABuffer: TRESTDWBytes; const ALength: Integer = -1;
  const AOffset: Integer = 0);
var
  LTemp: TRESTDWBytes;
  LPos: Integer;
  LSize: Integer;
  LByteCount: Integer;
  LLastError: Integer;
  // under ARC, convert a weak reference to a strong reference before working with it
  LIntercept: TRESTDWConnectionIntercept;
begin
  // Check if disconnected
  CheckForDisconnect(True, True);

  LIntercept := Intercept;
  if LIntercept <> nil then begin
                                                         
    // so that a copy is no longer needed here
    LTemp := ToBytes(ABuffer, ALength, AOffset);
    LIntercept.Send(LTemp);
    {$IFDEF USE_OBJECT_ARC}LIntercept := nil;{$ENDIF}
    LSize := Length(LTemp);
    LPos := 0;
  end else begin
    LTemp := ABuffer;
    LSize := IndyLength(LTemp, ALength, AOffset);
    LPos := AOffset;
  end;
  while LSize > 0 do
  begin
    LByteCount := WriteDataToTarget(LTemp, LPos, LSize);
    if LByteCount < 0 then
    begin
      LLastError := CheckForError(LByteCount);
      if LLastError <> Id_WSAETIMEDOUT then begin
        FClosedGracefully := True;
        Close;
      end;
      RaiseError(LLastError);
    end;
                                                                                          
    // can be called more. Maybe a prop of the connection, MaxSendSize?
    TRESTDWAntiFreezeBase.DoProcess(False);
    if LByteCount = 0 then begin
      FClosedGracefully := True;
    end;
    // Check if other side disconnected
    CheckForDisconnect;
    DoWork(wmWrite, LByteCount);
    Inc(LPos, LByteCount);
    Dec(LSize, LByteCount);
  end;
end;

initialization

finalization
  FreeAndNil(GIOHandlerClassList)
end.
