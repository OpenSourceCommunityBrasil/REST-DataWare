{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15692: IdSoapClient.pas
{
{   Rev 1.2    20/6/2003 00:02:14  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:02:00  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:31:38  GGrieve
}
{
IndySOAP: Client/Sender Implementation

The TIdSoapBaseSender creates a SOAP channel with a single SOAP Server

SOAP clients should only be used in a single thread. You can use different
soap client/transport layer pairs in different threads simultaineously

You can't use a TIdSoapBaseSender directly - you need to choose a
descendent class such as TIdSoapClientHTTP.

To use SOAP as an RPC mechanism:
* create a descendent of TIdSoapBaseSender,
* set the transport parameters as required
* define where the ITI will come from
* use the following code to create and execute interfaces:

    var IIntf : IMyInterface;
    begin
      IIntf := AIdSoapClient as IMyInterface;
      use IIntf...
    end;

  Do not attempt to free the interfaces. (not that you can....)

In order for you to use a interface like this, the interface (IMyInterface
in this case) must:

* must descend from IIdSoapInterface in IdSoapTypeRegistry
* be registered in the client's ITI (See IdSoapITI.pas for further details)
* all the types used in the interface's methods must be registered with IdSoapTypeRegistry
* the server must support the interface

}

{
Version History:
  19-Jun 2003   Grahame Grieve                  support for Sets, Default Parameters, Headers, polymorphism + optimizations
  18-Mar 2003   Grahame Grieve                  Fix leak - var parameters returned as nil by the server used to leak, Support for TIdSoapRawXML
  29-Oct 2002   Grahame Grieve                  Compile fix for D6 and introduction of IdSoapSimpleClass
  04-Oct 2002   Grahame Grieve                  Mime Type hancling changes for Attachments
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  17-Sep 2002   Grahame Grieve                  Fix dereferencing problem reading arrays, allow missing "response" in response messages
  05-Sep 2002   Grahame Grieve                  Fix for Empty Arrays in Doc|Lit mode
  26-Aug 2002   Grahame Grieve                  Dereference arrays before resolving
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  22-Aug 2002   Grahame Grieve                  Fix messageName mismatch error message - was a bit misleading
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  16-Aug 2002   Grahame Grieve                  Fix interface reference counting issue
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  06-Aug 2002   Grahame Grieve                  Introduce TIdSoapBaseSender for one Way support
  26-Jul 2002   Grahame Grieve                  Add Client side WSD Generation
  24-Jul 2002   Grahame Grieve                  Change SoapAction and Namespace handling
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  18-Jul 2002   Grahame Grieve                  Better control over Mime Types
  17-Jul 2002   Andrew Cumming                  Fixed leak in var array of objects
  17-Jul 2002   Andrew Cumming                  Fixed bug in TIdSoapBaseSender.AbandonInterfaces
  17-Jul 2002   Andrew Cumming                  Removed unused private bits to eliminate warnings
  11-Jul 2002   Andrew Cumming                  Fixed up incorrect implementation of dynamic arrays virtual/static methods
  29-May 2002   Andrew Cumming                  Fixed severe bug in class array properties
  29-May 2002   Grahame Grieve                  Support for Dynamic arrays of special classes
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml
   7-May 2002   Andrew Cumming                  Fixed a wierd D4 interface ref count error (I hope)
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing compiler warnings
  22-Apr 2002   Grahame Grieve                  Fix client lifetime management
  14-Apr 2002   Andrew Cumming                  Prepared for Kylix PIC
  12-Apr 2002   Andrew Cumming                  Fixed bug in interface ref counting for multiple interface usage
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  10-Apr 2002   Andrew Cumming                  Fixed for D4,D5 and D6
  10-Apr 2002   Andrew Cumming                  Major changes to lifetime management
  09-Apr 2002   Andrew Cumming                  Fixed bugs with nil classes and empty arrays
  08-Apr 2002   Grahame Grieve/Andrew Cumming   Support for Objects by Reference, Leaks fixed
  05-Apr 2002   Andrew Cumming                  Removed redundent if in class processing
  05-Apr 2002   Grahame Grieve                  Fix class garbage collection
  05-Apr 2002   Andrew Cumming                  Implemented special class handling
  05-Apr 2002   Andrew Cumming                  Fixed up array of class node bug
  05-Apr 2002   Andrew Cumming                  Added ID_SOAP_SHOW_NODES define for visualising nodes (for debugging ONLY)
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  03-Apr 2002   Grahame Grieve                  Handle ITI Method Request and Response Names
  03-Apr 2002   Grahame Grieve                  Change to Packet writer interface - no difference between request and response
  29-Mar 2002   Grahame Grieve                  Garbage collection of TIdBaseSoapableClass
  27-Mar 2002   Andrew Cumming                  Fixed serious big in arrays
  27-Mar 2002   Grahame Grieve                  Fix potential leaks
  26-Mar 2002   Grahame Grieve                  Packet writer changes, review assertions
  24-Mar 2002   Andrew Cumming                  Large refactor of large client func/procs to create simpler func/procs
  22-Mar 2002   Grahame Grieve                  Change Node handling to differentiate between arrays, elements, and structs
  20-Mar 2002   Andrew Cumming                  Fixed D5 compile error
  15-Mar 2002   Andrew Cumming                  Fixed bug in empty array properties
  15-Mar 2002   Andrew Cumming                  Fixed arrays and classes
  14-Mar 2002   Grahame Grieve                  Namespaces, Encoding options
  12-Mar 2002   Grahame Grieve                  Binary support (TStream)
   8-Mar 2002   Andrew Cumming                  Fixed boolean/enumeration bug
   8-Mar 2002   Andrew Cumming                  Made D4/D5 compatible
   7-Mar 2002   Grahame Grieve                  Review assertions, add support for EncodingType
   3-Mar 2002   Andrew Cumming                  Added code to implement SETs
   1-Mar 2002   Andrew Cumming                  Removed bug in dynamic array section (left over code that wasnt meant to be there)
   1-Mar 2002   Andrew Cumming                  Added code for polymorphic classes
   1-Mar 2002   Andrew Cumming                  Fixed bug in var dynamic arrays being freed and added class type results
  28-Feb 2002   Andrew Cumming                  Made D4 compatible
  28-Feb 2002   Andrew Cumming                  First version of classes completed
  24-Feb 2002   Andrew Cumming                  Finished dynamic array results
  24-Feb 2002   Andrew Cumming                  Even more dynamic array changes (there nearly done)
  22-Feb 2002   Andrew Cumming                  More dynamic array changes
  18-Feb 2002   Andrew Cumming                  Change for dynamic array processing
  15-Feb 2002   Andrew Cumming                  Fixed for re-arrangement of code in helper unit
  13-Feb 2002   Andrew Cumming                  Starting Dynamic array coding
  11-Feb 2002   Andrew Cumming                  more fixes for changes to Packet handling layer
   7-Feb 2002   Grahame Grieve                  fix updates for changes to Packet handling layer (more to come yet)
   7-Feb 2002   Grahame Grieve                  updates for changes to Packet handling layer (more to come yet)
   5-Feb 2002   Andrew Cumming                  Fixed some missed D4 changes
   5-Feb 2002   Grahame Grieve                  update for changes in RpcXml
  03-Feb 2002   Andrew Cumming                  Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapClient;

{$I IdSoapDefines.inc}

interface

uses
  {$IFNDEF LINUX}
  ActiveX,
  {$ENDIF}
  Classes,
{$IFNDEF DELPHI4}
  Contnrs,
{$ENDIF}
  IdComponent,
  IdSoapCSHelpers,
  IdSoapComponent,
  IdSoapConsts,
  IdSoapDebug,
  IdSoapITI,
  IdSoapITIProvider,
  IdSoapResourceStrings,
  IdSoapRpcPacket,
  IdSoapTypeRegistry,
  IdSoapUtilities,
  TypInfo;

type

  TIdSoapBaseSender = class;
  TIdSoapInterfaceGlue = class;

  // This class manages interface lifetimes and validity. It is ref counted and also
  // manipulates its ref counting from the glue as well. This is because one client can
  // be working with many interfaces and each interface has it's own glue and lifetime. The
  // GlueList cannot be freed until all glue entries have been released. The interfaces are ref
  // counted using the glue. There is an extra level of complication in that the main client object
  // although not usually used as an interface, does generate interfaces and hence gets involved
  // in ref counting, but only at the GlueList level.
  TIdSoapGlueList = Class ( TIdBaseObject, {$IFDEF DELPHI5} System. {$ENDIF} IUnknown )
    private
      FRefCount: Integer;
      FGlueList: TList;                  // a list of TIdSoapInterfaceGlue
      FSender: TIdSoapBaseSender;        // active Sender or nil if its dead
      function GetCount: Integer;
      function GetGlue(AIndex: Integer): TIdSoapInterfaceGlue;
    { IUnknown }     // this is the actual one used by the TIdSoapBaseSender
      function QueryInterface(const IID: {$IFDEF DELPHI5} System. {$ENDIF} TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
    public
      constructor Create;
      destructor Destroy; Override;
      function Add(AGlue: TIdSoapInterfaceGlue): Integer;
      property count: integer read GetCount;
      property Glue[AIndex: Integer]: TIdSoapInterfaceGlue read GetGlue; Default;
    end;

  { not for use outside this unit }
  TIdSoapInterfaceGlue = class(TIdBaseObject)
  Private
    FRefCount: Integer;
    FParent: TIdSoapGlueList;
    FInterfacePtr: Pointer;                          // Pointer to the VTable
    FSenderSelf: TIdSoapBaseSender;                  // pointer to the Sender that is using us
    FIID: {$IFDEF DELPHI5} System. {$ENDIF} TGUID;   // IID for this interface definition
    FIntf: TIdSoapITIInterface;                      // method lists for this interface from ITI
    procedure SoapCommonEntryStub;
    function CommonEntry(CallID: Integer; Params: Pointer): Int64;
    { This is not a real IUnknown, it just ref counts using the same method names }
    function _AddRef: Integer;
    function _Release: Integer;
  Public
    constructor Create;
    destructor Destroy; Override;
    property InterfacePtr: Pointer Read FInterfacePtr Write FInterfacePtr;
    property IID: {$IFDEF DELPHI5} System. {$ENDIF} TGUID Read FIID Write FIID;
    property SenderSelf: TIdSoapBaseSender Read FSenderSelf Write FSenderSelf;
    property Intf: TIdSoapITIInterface Read FIntf;
  end;

  { not for use outside this unit }
  TIdSoapSenderContext = class(TIdBaseObject)
  Private
    FParamPtr: array of Pointer;  // used for output type param pointer info
    FParamType: array of PTypeInfo;        // type of ParamPtr
    procedure SetParamPtr(AIndex: Integer; APointer: Pointer);
    function  GetParamPtr(AIndex: Integer): Pointer;
    procedure SetParamType(AIndex: Integer; ATypeInfo: PTypeInfo);
    function  GetParamType(AIndex: Integer): PTypeInfo;
  Public
    property ParamPtr[AIndex: Integer]: Pointer Read GetParamPtr Write SetParamPtr;
    property ParamType[AIndex: Integer]: PTypeInfo read GetParamTYpe write SetParamType;
  end;

  // only used internally
  TIdSoapClientSession = class (TIdBaseObject)
  private
    FAppSession : TObject;
    FIdentity : string;
    FId : cardinal;
  end;

  TIdSoapBaseSender = class(TIdSoapITIProvider {$IFDEF DELPHI4}, IUnknown {$ENDIF} {$IFDEF DELPHI5}, system.IUnknown {$ENDIF} {$IFDEF DELPHI6}, IUnknown {$ENDIF})
  Private
    FSoapVersion : TIdSoapVersion;
    FHasResponses : boolean; // will be set by descendent. when no responses, we don't allow interfaces that demand responses
    FGlueList: TIdSoapGlueList;
    FSendHeaders : TIdSoapHeaderList;
    FRecvHeaders : TIdSoapHeaderList;
    FGarbageCollectObjects : boolean;
    FGarbageContext : TIdBaseSoapableClassContext;
    FResultParamName : string;
    FSession : TIdSoapClientSession;
    FLastSessionID : cardinal;
    FAddingCookie : boolean;
    procedure ProcessHeadersSend(AMethod : TIdSoapITIMethod; ASoapWriter : TIdSoapWriter; ASenderContext : TIdSoapSenderContext);
    procedure ProcessHeadersRecv(AMethod : TIdSoapITIMethod; ASoapReader : TIdSoapReader; ASenderContext : TIdSoapSenderContext);

    function  ProcessResult(AResultType: PTypeInfo; ASoapReader: TIdSoapReader; AParams: Pointer; ASenderContext: TIdSoapSenderContext; AMethod : TIdSoapITIMethod): Int64;
    function  ProcessResultInteger(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader): Int64;
    function  ProcessResultFloat(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader): Int64;
    function  ProcessResultStringChar(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader; AResultType: PTypeInfo; AParams: Pointer): Int64;
    function  ProcessResultEnum(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader; AResultType: PTypeInfo; AMethod : TIdSoapITIMethod): Int64;
    function  ProcessResultSet(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader; AResultType: PTypeInfo; AMethod : TIdSoapITIMethod): Int64;
    function  ProcessResultDynArray(ASoapReader: TIdSoapReader; AParams: Pointer; AResultType: PTypeInfo; ASenderContext: TIdSoapSenderContext; AMethod : TIdSoapITIMethod): Int64;
    function  ProcessResultClass(AResultType: PTypeInfo; ASenderContext: TIdSoapSenderContext; ASoapReader: TIdSoapReader; AMethod : TIdSoapITIMethod): Int64;
    function  CommonEntry(AGlue: TIdSoapInterfaceGlue; CallID: Integer; Params: Pointer): Int64;
    function  ProcessParameter(ARootNode: TIdSoapNode;AEntryName: String; ASenderContext: TIdSoapSenderContext; ASoapWriter: TIdSoapWriter; var AData; const AParam: TIdSoapITIParameter; ATypeInfo: PTypeInfo; AParamIndex: Integer; AIsParameter : boolean; ADefault : Integer = MININT): Integer;
    function  ProcessParamInteger(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ADefault : Integer; Var AData): Integer;
    function  ProcessParamSet(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ATypeInfo : PTypeInfo; const AParam: TIdSoapITIParameter; Var AData): Integer;
    function  ProcessParamFloat(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ADefault : integer; Var AData): Integer;
    function  ProcessParamEnum(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; const AParam: TIdSoapITIParameter; ADefault : Integer; Var AData): Integer;
    function  ProcessParamStringChar(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; AParam: TIdSoapITIParameter; ADefault : integer; Var AData): Integer;
    function  ProcessParamDynArray(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; Var AData; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParam: TIdSoapITIParameter): Integer;
    function  ProcessParamClass(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; Var AData; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParam: TIdSoapITIParameter): Integer;
    procedure ProcessOutParams(ABaseNode: TIdSoapNode; AData: Pointer; ASenderContext: TIdSoapSenderContext; AParamIndex: Integer; AParam: TIdSoapITIParameter; ASoapReader: TIdSoapReader; AIsParameter : boolean);
    procedure ProcessOutInteger(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String);
    procedure ProcessOutFloat(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String);
    procedure ProcessOutEnumeration(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; AParam : TIdSoapITIParameter);
    procedure ProcessOutSet(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; AParamType : PTypeInfo; AParam : TIdSoapITIParameter);
    procedure ProcessOutStringChar(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo);
    procedure ProcessOutDynArray(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParam : TIdSoapITIParameter);
    procedure ProcessOutClass(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParamFlag: TParamFlag; AParam : TIdSoapITIParameter);
    procedure AbandonInterfaces;
    procedure SetSoapVersion(const AValue: TIdSoapVersion);
    function  GetSoapAction(AInterface : TIdSoapITIInterface; AMethod : TIdSoapITIMethod):string;
    function GetAppSession : TObject;
    procedure CheckForSessionInfo(AReader : TIdSoapReader);
  Protected
    procedure Start; override;
    procedure Stop; override;
    function  QueryInterface(const AIID: {$IFDEF DELPHI4OR5} System. {$ENDIF} TGUID; out AObj): HResult; Override; Stdcall;

    // overridden by Request/Response Descendents
    Procedure DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string); Virtual;
    procedure SetCookie(AName, AContent : string); virtual; abstract;
    procedure ClearCookie(AName : string);  virtual; abstract;

    // overridden by Sender Descendents
    procedure DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream); Virtual;
    function  GetTransportDefaultEncodingType: TIdSoapEncodingType; virtual;
    function  GetWSDLLocation : string; virtual; abstract;
    property  AddingCookie : boolean read FAddingCookie; 
  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; Override;
    property  GarbageContext : TIdBaseSoapableClassContext read FGarbageContext;
    procedure ListAllInterfaceNames (AList : TStrings);
    procedure GetWSDL(AInterfaceName : string; AStream : TStream);

    // this is an alternative entry point for when interfaces don't work.
    // use CreateWriter to create the right kind of writer for the encoding type
    // just pass nil for the Glue - it's not relevent in this situation
    // When used in one way mode, return value will be nil
    function SoapSend(AWriter : TIdSoapWriter; AGlue : TIdSoapInterfaceGlue; ASoapAction : string = '') : TIdSoapReader;
    function CreateWriter : TIdSoapWriter;

    property SendHeaders : TIdSoapHeaderList read FSendHeaders;
    property RecvHeaders : TIdSoapHeaderList read FRecvHeaders;

    procedure CreateSession(AIdentity : string; ASession : TObject; ACallEvent : boolean = true);
    procedure CloseSession(AIdentity : string = ''; ACallevent : boolean = true);
    property Session : TObject read GetAppSession;

    procedure TestSoapRequest(ASoapAction,ARequestMimeType: String; ARequest, AResponse: TStream; var VMimeType : string); // only provided for DUnit testing
    procedure TestSoapSend(ASoapAction,AMimeType: String; ARequest: TStream); // only provided for DUnit testing
  Published
    property GarbageCollectObjects : boolean read FGarbageCollectObjects write FGarbageCollectObjects;
    Property SoapVersion : TIdSoapVersion read FSoapVersion write SetSoapVersion;
  end;

  TIdSoapBaseClient = class (TIdSoapBaseSender)
  public
    constructor Create(AOwner: TComponent); Override;
  end;

  // base for any client that uses a http framework. Really, this should be called
  // TIdSoapHTTPClient, but that name was given to the indy transport layer a
  // long time ago, painful to change
  TIdSoapWebClient = class (TIdSoapBaseClient)
  private
    FSoapURL : string;
  protected
    procedure SetSoapURL(const AValue: string); virtual; // descendents may wish to take action
  public
    Constructor Create(AOwner : TComponent); override;
  published
    property SoapURL : string read FSoapURL write SetSoapURL;
  end;

  TIdSoapBaseMsgSender = class (TIdSoapBaseSender)
  private
    FMessageSubject : string;
  protected
    function GetTransportDefaultEncodingType: TIdSoapEncodingType; override;
    function GetSubject : string;
  public
    constructor Create(AOwner: TComponent); Override;
  published
    property MessageSubject : string read FMessageSubject write FMessageSubject;
  end;

implementation

uses
{$IFDEF ID_SOAP_SHOW_NODES}
  IdSoapViewer,
{$ENDIF}
{$IFDEF DELPHI4OR5}
  ComObj,
{$ENDIF}
  IdGlobal,
  IdSoapExceptions,
  IdSoapITIBin,
  IdSoapPointerManipulator,
  IdSoapRpcBin,
  IdSoapRpcXml,
  IdSoapRpcUtils,
  IdSoapTypeUtils,
  IdSoapRTTIHelpers,
  IdSoapWsdl,
  IdSoapWsdlIti,
  IdSoapWsdlXml,
  SysUtils
{$IFDEF DELPHI4OR5}
  , Windows
{$ENDIF}
  ;

const
  ASSERT_UNIT = 'IdSoapClient';

type
  PIdSoapBuffer = ^TIdSoapBuffer;
  TIdSoapBuffer = record
    FNext: PIdSoapBuffer;
    FSoapBuffer: array [1..ID_SOAP_BUFFER_SIZE] of Byte;
  end;

  TIdSoapBufferManager = class(TIdBaseObject)
  Private
    FStubBuffer: PIdSoapBuffer;
    FCurrentBuffer: PIdSoapBuffer;
    FOffset: Word;
    function GetCurrentAdr: Pointer;
    procedure CheckIfSufficientSpace(ABytes: Integer);
  Public
    constructor Create;
    destructor Destroy; Override;
    procedure PutMem(var AData; ALen: Integer);
    procedure PutByte(AByte: Byte);
    procedure PutWord(AWord: Word);
    procedure PutInteger(AInteger: Integer);
    procedure PutCardinal(ACardinal: Cardinal);
    procedure PutPointer(APointer: Pointer);
    procedure AsmFarCall(Adr: Pointer);
    procedure AsmPushInt(AInteger: Integer);
    procedure AsmRet(ABytesToPop: Word);
    property CurrentAdr: Pointer Read GetCurrentAdr;
  end;

  TIdSoapInterfaceManager = class(TIdBaseObject)
  Private
    FInterfaces: TList;    // list of PSoapInterfaceInfo
    FSoapMethodRef: Word;
    FSoapGUID: TGUID;
    FSoapVTable: array of Pointer;
    FSoapCommonEntryPtr: Pointer;
    function BytesPushedOnStack(AParam: TIdSoapITIParameter): Integer;
  Public
    constructor Create;
    destructor Destroy; Override;
    procedure AddInterface(AGUID: TGUID; AStubBase: Pointer);
    function FindStub(AGUID: TGUID): Pointer;
    function IsInterfaceDefined(AGUID: TGUID): Boolean;
    procedure StartInterfaceDefine(AGUID: TGUID);
    procedure DefineInterfaceMethod(AMethod: TIdSoapITIMethod);
    procedure EndInterfaceDefine;
    procedure InitializeInterfaceStubs(AITI: TIdSoapITI);
  end;

  PIdSoapInterfaceInfo = ^TIdSoapInterfaceInfo;
  TIdSoapInterfaceInfo = record
    FGUID: TGUID;
    FStubBase: Pointer;
  end;

var
  gIdSoapBufferManager: TIdSoapBufferManager = NIL;
  gIdSoapInterfaceManager: TIdSoapInterfaceManager = NIL;
  gIdGlobalLock: TIdCriticalSection = NIL;

{ TIdSoapBufferManager }

constructor TIdSoapBufferManager.Create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.Create';
begin
  inherited;
  new(FStubBuffer);
  FStubBuffer^.FNext := NIL;
  FCurrentBuffer := FStubBuffer;
  FOffset := 1;
end;

destructor TIdSoapBufferManager.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.Destroy';
var
  LBuf, LNext: PIdSoapBuffer;
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  LBuf := FStubBuffer;
  repeat
    LNext := LBuf^.FNext;
    Dispose(LBuf);
    LBuf := LNext;
  until not Assigned(LBuf);
  inherited;
end;

procedure TIdSoapBufferManager.CheckIfSufficientSpace(ABytes: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.CheckIfSufficientSpace';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  if (FOffset + ABytes) > ID_SOAP_BUFFER_SIZE then  // not enough space at end of buffer
    begin
    new(FCurrentBuffer^.FNext);
    FCurrentBuffer := FCurrentBuffer^.FNext;
    FCurrentBuffer^.FNext := NIL;
    FOffset := 1;
    end;
end;

function TIdSoapBufferManager.GetCurrentAdr: Pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.GetCurrentAdr';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  Assert(gIdGlobalLock.LockedToMe, ASSERT_LOCATION+': Buffer Manager is not locked');
  Result := @FCurrentBuffer^.FSoapBuffer[FOffset];
end;

procedure TIdSoapBufferManager.PutMem(var AData; ALen: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.PutMem';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  Assert(gIdGlobalLock.LockedToMe, ASSERT_LOCATION+': Buffer Manager is not locked');
  Assert(FCurrentBuffer <> NIL, ASSERT_LOCATION+': Current Buffer = nil');
  Assert((FOffset + ALen - 1) <= ID_SOAP_BUFFER_SIZE, ASSERT_LOCATION+' (Offset + Len - 1) > ID_SOAP_BUFFER_SIZE');
  move(AData, FCurrentBuffer^.FSoapBuffer[FOffset], ALen);
  inc(FOffset, ALen);
end;

procedure TIdSoapBufferManager.PutByte(AByte: Byte);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.PutByte';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  PutMem(AByte, Sizeof(AByte));
end;

procedure TIdSoapBufferManager.PutWord(AWord: Word);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.PutWord';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  PutMem(AWord, Sizeof(AWord));
end;

procedure TIdSoapBufferManager.PutInteger(AInteger: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.PutInteger';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  PutMem(AInteger, Sizeof(AInteger));
end;

procedure TIdSoapBufferManager.PutCardinal(ACardinal: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.PutCardinal';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  PutMem(ACardinal, Sizeof(ACardinal));
end;

procedure TIdSoapBufferManager.PutPointer(APointer: Pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.PutPointer';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  PutMem(APointer, Sizeof(APointer));
end;

procedure TIdSoapBufferManager.AsmFarCall(Adr: Pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.AsmFarCall';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  PutWord($15ff);   // reversed for word
  PutMem(Adr, Sizeof(Adr));
end;

procedure TIdSoapBufferManager.AsmPushInt(AInteger: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.AsmPushInt';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  if (AInteger >= -128) and (AInteger <= 127) then
    begin
    PutByte($6A);
    PutByte(AInteger);
    end
  else
    begin
    PutByte($68);
    PutInteger(AInteger);
    end;
end;

procedure TIdSoapBufferManager.AsmRet(ABytesToPop: Word);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBufferManager.AsmRet';
begin
  Assert(Self.TestValid(TIdSoapBufferManager), ASSERT_LOCATION+': Self is not valid');
  if ABytesToPop = 0 then
    begin
    PutByte($c3);
    end
  else
    begin
    PutByte($c2);
    PutWord(ABytesToPop);
    end;
end;

{ TIdSoapInterfaceManager }

constructor TIdSoapInterfaceManager.Create;
begin
  inherited;
  FInterfaces := TList.Create;
end;

destructor TIdSoapInterfaceManager.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.Destroy';
var
  LIndex: Integer;
begin
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  for LIndex := 0 to FInterfaces.Count - 1 do
    Dispose(FInterfaces.Items[LIndex]);
  FreeAndNil(FInterfaces);
  inherited;
end;

procedure TIdSoapInterfaceManager.AddInterface(AGUID: TGUID; AStubBase: Pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.AddInterface';
var
  LInfo: PIdSoapInterfaceInfo;
begin
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  // should check for entry already registered
  new(LInfo);
  LInfo^.FGUID := AGUID;
  LInfo^.FStubBase := AStubBase;
  FInterfaces.Add(LInfo);
end;

function TIdSoapInterfaceManager.FindStub(AGUID: TGUID): Pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.FindStub';
var
  LIndex: Integer;
begin                   // can probably be replaced with a faster search later
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  Result := NIL;
  for LIndex := 0 to FInterfaces.Count - 1 do
    begin
    if IsEqualGUID(AGUID, PIdSoapInterfaceInfo(FInterfaces[LIndex])^.FGUID) then
      begin
      Result := @PIdSoapInterfaceInfo(FInterfaces[LIndex])^.FStubBase;
      break;
      end;
    end;
end;

function TIdSoapInterfaceManager.IsInterfaceDefined(AGUID: TGUID): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.IsInterfaceDefined';
var
  LIndex: Integer;
begin                   // can probably be replaced with a faster search later
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  Result := True;
  for LIndex := 0 to FInterfaces.Count - 1 do
    begin
    if IsEqualGUID(AGUID, PIdSoapInterfaceInfo(FInterfaces[LIndex])^.FGUID) then
      exit;
    end;
  Result := False;
end;

procedure TIdSoapInterfaceManager.StartInterfaceDefine(AGUID: TGUID);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.StartInterfaceDefine';
begin
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  FSoapMethodRef := 1;
  FSoapGUID := AGUID;
  DefineInterfaceMethod(NIL);  // no RTTI needed for these 3. There the AddRef, Release and QueryInterface methods
  DefineInterfaceMethod(NIL);
  DefineInterfaceMethod(NIL);
end;

function TIdSoapInterfaceManager.BytesPushedOnStack(AParam: TIdSoapITIParameter): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.BytesPushedOnStack';
var
  LBasicType: TIdSoapBasicType;
begin
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': Param is not valid');
  LBasicType := IdSoapBasicType(AParam.TypeInformation);
  Result := IdSoapRegisterSizeOfBasicType(LBasicType);
  if LBasicType = isbtShortString then
    begin
    if AParam.ParamFlag = pfVar then
      inc(Result, Sizeof(Integer));  // var types of ShortString have the length pushed on too
    end;
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    if (AParam.TypeInformation^.Kind = tkString) and (AParam.ParamFlag = pfVar) then   // ShortString's are an exception due to the length being pushed too
      begin
      Result := Sizeof(Integer) + Sizeof(Pointer);
      end
    else
      begin
      Result := sizeof(Pointer);  // only the address is on the stack
      end;
    end;
end;

procedure TIdSoapInterfaceManager.DefineInterfaceMethod(AMethod: TIdSoapITIMethod);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.DefineInterfaceMethod';
var
  LParamBytes: Word;
  LParamNum: Integer;
  LCallingFlags: Byte;
  LResultType: String;
begin
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  Assert((AMethod = nil) or AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': Method is not valid');
  SetLength(FSoapVTable, length(FSoapVTable) + 1);
  gIdSoapBufferManager.PutPointer(AMethod);              // RTTI is 4 bytes below stub entry to keep details of method
  FSoapVTable[Length(FSoapVTable) - 1] := gIdSoapBufferManager.CurrentAdr; // stub entry starts here
  gIdSoapBufferManager.AsmPushInt(FSoapMethodRef);       // method #
  // 2 bits. Bit 0 = Calling Convention   0 = CDECL      1 = STDCALL
  //         Bit 1 = Return location      0 = Register   1 = on stack
  LCallingFlags := 0;
  LCallingFlags := (LCallingFlags and $fe) or 1;   // AddRef, Release and QueryInterface must be STDCALL type
  LParamBytes := 0;
  if Assigned(AMethod) then
    begin
    if AMethod.ResultType <> '' then
      begin
      LResultType := UpperCase(AMethod.ResultType);
      if (LResultType = 'STRING') or (LResultType = 'ANSISTRING') then       { do not localize }
        begin
        LCallingFlags := LCallingFlags or 2;   // set as result on stack
        inc(LParamBytes, 4);
        end
      else if LResultType = 'WIDESTRING' then                                { do not localize }
        begin
        LCallingFlags := LCallingFlags or 2;   // set as result on stack
        inc(LParamBytes, 4);
        end
      else if LResultType = 'SHORTSTRING' then                                { do not localize }
        begin
        LCallingFlags := LCallingFlags or 2;   // set as result on stack
        inc(LParamBytes, 4);
        end
      else if AMethod.ResultTypeInfo^.Kind = tkDynArray then
        begin
        LCallingFlags := LCallingFlags or 2;   // set as result on stack
        inc(LParamBytes, 4);
        end;
      end;
    case AMethod.CallingConvention of
      idccStdCall:
        LCallingFlags := (LCallingFlags and $fe) or 1;
      else
        raise EIdSoapBadDefinition.Create('You must use STDCALL for soap methods');
      end;
    end;
  gIdSoapBufferManager.AsmPushInt(LCallingFlags);
  gIdSoapBufferManager.AsmFarCall(@FSoapCommonEntryPtr);        // common entry point
  if Assigned(AMethod) then    // 1st 3 methods are internal and dont have ITI
    begin
    for LParamNum := 0 to AMethod.Parameters.Count - 1 do
      begin
      inc(LParamBytes, BytesPushedOnStack(AMethod.Parameters.Param[LParamNum]));
      end;
    end;
  gIdSoapBufferManager.AsmRet(4 + LParamBytes);    // ret. pop of VTable self and LParamBytes
  inc(FSoapMethodRef);
end;

procedure TIdSoapInterfaceManager.EndInterfaceDefine;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.EndInterfaceDefine';
var
  LIndex: Integer;
begin
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  gIdSoapBufferManager.CheckIfSufficientSpace(length(FSoapVTable) * Sizeof(Pointer));  // ensure theres enough space
  gIdSoapInterfaceManager.AddInterface(FSoapGUID, gIdSoapBufferManager.CurrentAdr);
  for LIndex := 0 to length(FSoapVTable) - 1 do
    begin
    gIdSoapBufferManager.PutPointer(FSoapVTable[LIndex]);
    end;
  SetLength(FSoapVTable, 0);
end;

procedure TIdSoapInterfaceManager.InitializeInterfaceStubs(AITI: TIdSoapITI);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceManager.InitializeInterfaceStubs';
var
  LIndex: Integer;
  LMethodNum: Integer;
  LInterface: TIdSoapITIInterface;
  LLimitCheck: Integer;
begin
  Assert(Self.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': Self is not valid');
  Assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  gIdGlobalLock.Enter;
  try
    for LIndex := 0 to AITI.Interfaces.Count - 1 do
      begin
      LInterface := AITI.Interfaces.Objects[LIndex] as TIdSoapITIInterface;
      if gIdSoapInterfaceManager.IsInterfaceDefined(LInterface.GUID) then
        begin
        continue;   // already in table
        end;
      StartInterfaceDefine(LInterface.GUID);
      for LMethodNum := 0 to LInterface.Methods.Count - 1 do
        begin
        gIdSoapBufferManager.CheckIfSufficientSpace(ID_SOAP_MAX_STUB_BUFFER_SIZE);
        LLimitCheck := gIdSoapBufferManager.FOffset;
        DefineInterfaceMethod(LInterface.Methods.Objects[LMethodNum] as TIdSoapITIMethod);
        Assert(gIdSoapBufferManager.FOffset >= LLimitCheck,ASSERT_LOCATION + ': New buffer allocated when it is not allowed too');
        Assert(gIdSoapBufferManager.FOffset <= LLimitCheck+ID_SOAP_MAX_STUB_BUFFER_SIZE,ASSERT_LOCATION + ': ID_SOAP_MAX_STUB_BUFFER_SIZE is too small');
        end;
      EndInterfaceDefine;
      end;
  finally
    gIdGlobalLock.Leave;
    end;
end;

{ TIdSoapInterfaceGlue }

constructor TIdSoapInterfaceGlue.Create;
begin
  inherited;
end;

destructor TIdSoapInterfaceGlue.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceGlue.Destroy';
begin
  Assert(self.TestValid(TIdSoapInterfaceGlue), ASSERT_LOCATION+': self is not valid');
  if Assigned(FParent) then
    begin
    // i.e. we still attached to our client
    Assert(FParent.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': self is not valid');
    Assert(assigned(Self.FParent.FGlueList), ASSERT_LOCATION+': Parent.GlueList is not valid');
    FParent.FGlueList.Delete(FParent.FGlueList.IndexOf(self));  // remove me from the glue list
    FParent._Release;  // end dec the ref count for my parent
    end;
  inherited;
end;

function TIdSoapInterfaceGlue._AddRef: Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceGlue._AddRef';
begin
  result := IndyInterlockedIncrement(FRefCount);
end;

function TIdSoapInterfaceGlue._Release: Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceGlue._Release';
begin
  result := IndyInterlockedDecrement(FRefCount);
  if result = 0 then  // time to free ourself and remove ourself from the GlueList
    begin
    Free;
    end;
end;

// DONT do any testing of self here as self is invalid here
// ALL SOAP interface methods start here.  The interface instance address is used
// to compute the objects SELF value ready for the CommonEntry call
procedure TIdSoapInterfaceGlue.SoapCommonEntryStub;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceGlue.SoapCommonEntryStub';
asm
  // The fake call that will be made shortly in here, the 1st param is in EAX and the second in ECX
  // as the receiver is using register calling convention
  pop   eax            // Ret adr so we can get at the params above
  pop   edx            // get calling convention
  test  edx,1          // cdecl or pascal call convention ?
  jz    @@CDecl
@@StdCall:
  test  edx,2          // ret val on stack ?
  pop   edx            // get method num
  push  eax            // save ret back
  jnz   @@RetOnStack
@@RetOnReg:
  lea   ecx, [esp+12]  // start of param adr in pascal ordering
  mov   eax, [esp+8]   // interface inst adr in pascal ordering
  jmp   @@CallCommonEntry
@@RetOnStack:
  lea   ecx, [esp+16]  // start of param adr in pascal ordering
  mov   eax, [esp+12]   // interface inst adr in pascal ordering
  jmp   @@CallCommonEntry
@@cdecl:               // we're a cdecl ordered parameter list
// NOT SUPPORTED YET
  int 3                // hit the debugger
//  lea   ecx, [esp+8]   // start of param adr in cdecl ordering
//  mov   eax, [esp+12]  // interface inst adr in cdecl ordering
@@CallCommonEntry:
  sub   eax, offset TIdSoapInterfaceGlue.FInterfacePtr;  // adjust vtable self to class self
  jmp   TIdSoapInterfaceGlue.CommonEntry                          // go do it (callee performs the return)
  end;

function TIdSoapInterfaceGlue.CommonEntry(CallID: Integer; Params: Pointer): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapInterfaceGlue.CommonEntry';
begin
  Result := SenderSelf.CommonEntry(Self, CallId, Params);
end;

{ TIdSoapBaseSender }

constructor TIdSoapBaseSender.Create(AOwner: TComponent);
begin
  inherited;
  FGarbageContext := TIdBaseSoapableClassContext.create;
  FSoapVersion := IdSoapV1_1;
  FSendHeaders := TIdSoapHeaderList.create(true);
  FRecvHeaders := TIdSoapHeaderList.create(true);
  FLastSessionID := 0;
end;

destructor TIdSoapBaseSender.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.Destroy';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  CloseSession();
  FreeAndNil(FSendHeaders);
  FreeAndNil(FRecvHeaders);
  FreeAndNil(FGarbageContext);
  inherited;
end;

procedure TIdSoapBaseSender.SetSoapVersion(const AValue: TIdSoapVersion);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.SetSoapVersion';
begin
  Assert(self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self not valid');
  Assert(not Active, ASSERT_LOCATION+': Cannot change SOAP versions while active = true');
  Assert(IdEnumIsValid(TypeInfo(TIdSoapVersion), ord(AValue)), ASSERT_LOCATION+': SOAP Version is not valid');
  FSoapVersion := AValue;
end;

procedure TIdSoapBaseSender.TestSoapSend(ASoapAction,AMimeType: String; ARequest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.TestSoapSend';
begin
  // no checks is deliberate
  DoSoapSend(ASoapAction, AMimeType, ARequest);
end;

procedure TIdSoapBaseSender.TestSoapRequest(ASoapAction,ARequestMimeType: String; ARequest, AResponse: TStream; var VMimeType : string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.TestSoapRequest';
begin
  // no checks is deliberate
  DoSoapRequest(ASoapAction, ARequestMimeType, ARequest, AResponse, VMimeType);
end;

function TIdSoapBaseSender.QueryInterface(const AIID: {$IFDEF DELPHI5} System. {$ENDIF} TGUID; out AObj): HResult;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.QueryInterface';
var
  LIndex: Integer;
  LInterfaceIndex: Integer;
  LVTable: Pointer;
  LGlue: TIdSoapInterfaceGlue;
  LIntf : TIdSoapITIInterface;
  LTmp: Pointer;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(Self.Active, ASSERT_LOCATION+': Soap Component "'+Name+'" is not active');
  // this interface may not have been loaded till now (it is loaded as late as possible

  // we check if its a SOAP interface. If not, then use inherited queryinterface to see what the answer is
  LInterfaceIndex := -1;
  for LIndex := 0 to FGlueList.Count - 1 do
    begin
    if IsEqualGUID(FGlueList[LIndex].IID, AIID) then
      begin
      LInterfaceIndex := LIndex;
      break;
      end;
    end;
  if LInterfaceIndex = -1 then // Interface is not already built and ready for use, or the interface references are unique (or its not an interface we support)
    begin
    LTmp := gIdSoapInterfaceManager.FindStub(AIID);
    if Assigned(LTmp) then
      LVTable := pointer(LTmp^)
    else
      LVTable := nil;
    if LVTable = NIL then  // its not one of ours
      begin
      Result := inherited QueryInterface(AIID, AObj);  // so let our ancestor figure it out
      exit;
      end;
    LIntf := ITI.FindInterfaceByGUID(AIID);
    Assert(Assigned(LIntf), ASSERT_LOCATION+'["'+Name+'"]: Interface GUID "'+GuidToString(AIID)+'" not found in ITI');

    // now we need to create the interface glue
    LGlue := TIdSoapInterfaceGlue.Create;  // create the glue
    LGlue.IID := AIID;                     // add the IID
    LGlue.InterfacePtr := LVTable;         // and the pointer to the interface's VTable
    LGlue.SenderSelf := Self;
    LGlue.FIntf := LIntf;
    LGLue.FParent := FGlueList;
    FGlueList.Add(LGlue);   // add it to the list of active interfaces
    end
  else
    begin
    LGlue := FGlueList[LInterfaceIndex];
    end;
  LGlue._AddRef;
  // we now have an active interface to work with
  Pointer(AObj) := @LGlue.FInterfacePtr;
  Result := S_OK;
end;

procedure TIdSoapBaseSender.ProcessOutParams(ABaseNode: TIdSoapNode; AData: Pointer; ASenderContext: TIdSoapSenderContext; AParamIndex: Integer; AParam: TIdSoapITIParameter; ASoapReader: TIdSoapReader; AIsParameter : boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutParams';
var
  LData: Pointer;
  LBasicType: TIdSoapBasicType;
  LName : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: BaseNode is not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');
  Assert(AParamIndex >= -2, ASSERT_LOCATION+'["'+Name+'"]: AParamIndex = '+inttostr(AParamIndex));
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: AParam is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: Reader is not valid');

  if Assigned(ABaseNode) then
    begin
    Assert(AParamIndex = -1, ASSERT_LOCATION+'["'+Name+'"]: AParamIndex <> -1');
    Assert(Assigned(AData), ASSERT_LOCATION+'["'+Name+'"]: AData nil');
    LData := AData;
    end
  else
    begin
    Assert(AParamIndex >= -1, ASSERT_LOCATION+'["'+Name+'"]: AParamIndex < 0');
    if not (AParam.ParamFlag in [pfVar, pfOut]) then  // theres no output so ignore it
      exit;
    if AParamIndex = -1 then
      LData := AData
    else
      LData := ASenderContext.ParamPtr[AParamIndex];
    end;
  if AIsParameter then
    begin
    LName := AParam.ReplaceName(AParam.Name);
    end
  else
    begin
    LName := AParam.Name;
    end;
  LBasicType := IdSoapBasicType(AParam.TypeInformation);
  case AParam.TypeInformation^.Kind of
    tkInt64,
    tkInteger:     ProcessOutInteger(LBasicType,LData^,ASoapReader,ABaseNode,LName);
    tkFloat:       ProcessOutFloat(LBasicType,LData^,ASoapReader,ABaseNode,LName);
    tkEnumeration: ProcessOutEnumeration(LBasicType,LData^,ASoapReader,ABaseNode,LName,AParam.TypeInformation, AParam);
    tkSet:         ProcessOutSet(LBasicType,LData^,ASoapReader,ABaseNode,LName, AParam.TypeInformation, AParam);
    tkLString,
    tkWString,
    tkString,
    tkChar,
    tkWChar:       ProcessOutStringChar(LBasicType,LData^,ASoapReader,ABaseNode,LName,AParam.TypeInformation);
    tkDynArray:    ProcessOutDynArray(LBasicType,LData^,ASoapReader,ABaseNode,LName,AParam.TypeInformation,ASenderContext, AParam);
    tkClass:       ProcessOutClass(LBasicType,LData^,ASoapReader,ABaseNode,LName,AParam.TypeInformation,ASenderContext,AParam.ParamFlag, AParam);
    else           raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(AParam.TypeInformation^.Kind))+')');
    end;
end;

procedure TIdSoapBaseSender.ProcessOutInteger(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutInteger';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  // no test ABasicType
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ABaseNode is not valid');

  case ABasicType of
    isbtByte:       Byte(AData)     := ASoapReader.ParamByte[ABaseNode, AParamName];
    isbtShortInt:   ShortInt(AData) := ASoapReader.ParamShortInt[ABaseNode, AParamName];
    isbtSmallInt:   SmallInt(AData) := ASoapReader.ParamSmallInt[ABaseNode, AParamName];
    isbtWord:       Word(AData)     := ASoapReader.ParamWord[ABaseNode, AParamName];
{$IFNDEF DELPHI4}
    isbtCardinal:   Cardinal(AData) := ASoapReader.ParamCardinal[ABaseNode, AParamName];
{$ENDIF}
    isbtInteger:    Integer(AData)  := ASoapReader.ParamInteger[ABaseNode, AParamName];
    isbtInt64:      Int64(AData)    := ASoapReader.ParamInt64[ABaseNode, AParamName];
    else            raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

procedure TIdSoapBaseSender.ProcessOutFloat(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutFloat';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  // no test ABasicType
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ABaseNode is not valid');

  case ABasicType of
    isbtSingle:   Single(AData)   := ASoapReader.ParamSingle[ABaseNode, AParamName];
    isbtDouble:   Double(AData)   := ASoapReader.ParamDouble[ABaseNode, AParamName];
    isbtExtended: Extended(AData) := ASoapReader.ParamExtended[ABaseNode, AParamName];
    isbtComp:     Comp(AData)     := ASoapReader.ParamComp[ABaseNode, AParamName];
    isbtCurrency: Currency(AData) := ASoapReader.ParamCurrency[ABaseNode, AParamName];
    else          raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

procedure TIdSoapBaseSender.ProcessOutEnumeration(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; AParam : TIdSoapITIParameter);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutEnumeration';
var
  LType, LTypeNS : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  // no test ABasicType
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ABaseNode is not valid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: Param is not valid');

  AParam.ReplaceTypeName(ATypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
  case ABasicType of
    isbtBoolean:      Boolean(AData)  := ASoapReader.ParamBoolean[ABaseNode,AParamName];
    isbtEnumShortInt: ShortInt(AData) := ASoapReader.ParamEnumeration[ABaseNode, AParamName, ATypeInfo, LType, LTypeNS, AParam];
    isbtEnumByte:     Byte(AData)     := ASoapReader.ParamEnumeration[ABaseNode, AParamName, ATypeInfo, LType, LTypeNS, AParam];
    isbtEnumSmallInt: SmallInt(AData) := ASoapReader.ParamEnumeration[ABaseNode, AParamName, ATypeInfo, LType, LTypeNS, AParam];
    isbtEnumWord:     Word(AData)     := ASoapReader.ParamEnumeration[ABaseNode, AParamName, ATypeInfo, LType, LTypeNS, AParam];
    isbtEnumInteger:  Integer(AData)  := ASoapReader.ParamEnumeration[ABaseNode, AParamName, ATypeInfo, LType, LTypeNS, AParam];
{$IFNDEF DELPHI4}
    isbtEnumCardinal: Cardinal(AData) := ASoapReader.ParamEnumeration[ABaseNode, AParamName, ATypeInfo, LType, LTypeNS, AParam];
{$ENDIF}
    else              raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

procedure TIdSoapBaseSender.ProcessOutSet(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; AParamType : PTypeInfo; AParam : TIdSoapITIParameter);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutSet';
var
  LType, LTypeNS : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  // no test ABasicType
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ABaseNode is not valid');

  AParam.ReplaceTypeName(AParamType^.Name, DefaultNamespace, LType, LTypeNS);
  case ABasicType of
    isbtSetByte:     Byte(AData)     := ASoapReader.ParamSet[ABaseNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType)];
    isbtSetShortInt: ShortInt(AData) := ASoapReader.ParamSet[ABaseNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType)];
    isbtSetSmallInt: SmallInt(AData) := ASoapReader.ParamSet[ABaseNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType)];
    isbtSetWord:     Word(AData)     := ASoapReader.ParamSet[ABaseNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType)];
{$IFNDEF DELPHI4}
    isbtSetCardinal: Cardinal(AData) := ASoapReader.ParamSet[ABaseNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType)];
{$ENDIF}
    isbtSetInteger:  Integer(AData)  := ASoapReader.ParamSet[ABaseNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType)];
    else             raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

procedure TIdSoapBaseSender.ProcessOutStringChar(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutStringChar';
var
  LTypeData: PTypeData;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  // no test ABasicType
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ABaseNode is not valid');

  case ABasicType of
    isbtLongString:   AnsiString(AData) := ASoapReader.ParamString[ABaseNode, AParamName];
    isbtWideString:   WideString(AData) := ASoapReader.ParamWideString[ABaseNode, AParamName];
    isbtShortString:  begin
                      LTypeData := GetTypeData(ATypeInfo);
                      ShortString(AData) := copy(ASoapReader.ParamShortString[ABaseNode, AParamName], 1, LTypeData^.MaxLength);
                      end;
    isbtChar:         Char(AData)     := ASoapReader.ParamChar[ABaseNode, AParamName];
    isbtWideChar:     WideChar(AData) := ASoapReader.ParamWideChar[ABaseNode, AParamName];
    else              raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

procedure TIdSoapBaseSender.ProcessOutDynArray(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParam : TIdSoapITIParameter);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutDynArray';
var
  LRootNode,LNode : TIdSoapNode;
  LPtr: Pointer;
  LFakeParam: TIdSoapITIParameter;
  LTypeInfo: PTypeInfo;
  LIsParamType: Boolean;
  LIter: TIdSoapNodeIterator;
  LSubscripts: Integer;
  LTemp: Integer;
  LPtr1: Pointer;
  LSubscriptInfo: TIdSoapNodeIteratorInfo;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  // no test ABasicType
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');
  Assert(Assigned(ASenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is nil');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ABaseNode is not valid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: Param is not valid');
  LRootNode := ASoapReader.GetArray(ABaseNode, AParamName, true);
  if not assigned(LRootNode) then
    begin
    // an empty array
    pointer(AData) := nil;
    end
  else
    begin
    Lptr := @AData;
    IdSoapDynArrayClear(pointer(LPtr^),ATypeInfo);  // Finalize the array
    LFakeParam := TIdSoapITIParameter.Create(nil, AParam); // not part of the ITI, but connected to the type/name replacement system
    try
      LFakeParam.ParamFlag := pfReference;
      LTypeInfo := IdSoapGetDynArrBaseTypeInfo(ATypeInfo);
      LFakeParam.TypeInformation := LTypeInfo;
      LFakeParam.NameOfType := LFakeParam.TypeInformation^.Name;
      case LTypeInfo^.kind of
        tkClass    : LIsParamType := IsSpecialClass(LTypeInfo^.Name);
        tkDynArray : LIsParamType := false;
      else
        LIsParamType := True;
      end;
      LIter := TIdSoapNodeIterator.Create;
      try
        LSubscripts := IdSoapDynArrSubscriptsFromTypeInfo(ATypeInfo);
        if LIsParamType then
          dec(LSubscripts);
        // need to check for LSubscripts=0 here and react accordingly (AC)
        if LSubscripts = 0 then
          begin
          LFakeParam.NameOfType := ATypeInfo^.Name;
          for LTemp:=0 to LRootNode.Params.Count-1 do
            begin
            LFakeParam.Name := LRootNode.Params[LTemp];
            LPtr1 := IdSoapGetDynamicArrayDataFromNode(pointer(LPtr^),ATypeInfo,LIter.Info,IdSoapIndexFromName(LFakeParam.Name, ASSERT_LOCATION+'["'+Name+'"]'),LTypeInfo);
            ProcessOutParams(LRootNode,LPtr1,ASenderContext,-1,LFakeParam,ASoapReader, false);
            end;
          end;
        if LIter.First(LRootNode,LSubscripts) then
          begin
          repeat
            if LIsParamType then
              begin
              // get the node below me as this has the final details
              LNode := LIter.Info[LSubscripts-1].Node.Children.Objects[LIter.Info[LSubscripts-1].Index] as TIdSoapNode;
              for LTemp:=0 to LNode.Params.Count-1 do
                begin
                LFakeParam.Name := LNode.Params[LTemp];
                LPtr1 := IdSoapGetDynamicArrayDataFromNode(pointer(LPtr^),ATypeInfo,LIter.Info,IdSoapIndexFromName(LFakeParam.Name, ASSERT_LOCATION+'["'+Name+'"]'),LTypeInfo);
                ProcessOutParams(LNode,LPtr1,ASenderContext,-1,LFakeParam,ASoapReader, false);
                end;
              end
            else
              begin
              LSubscriptInfo := LIter.Info[LSubscripts-1];  // info on the leaf node of the array
              LNode := LSubscriptInfo.Node.Children.Objects[LSubscriptInfo.Index] as TIdSoapNode;
              LFakeParam.Name := LNode.Name;
              LNode := LNode.Parent;
              LPtr1 := IdSoapGetDynamicArrayDataFromNode(pointer(LPtr^),ATypeInfo,LIter.Info,-1,LTypeInfo);
              ProcessOutParams(LNode,LPtr1,ASenderContext,-1,LFakeParam,ASoapReader, false);
              end;
          until not LIter.Next;
          end;
      finally
        FreeAndNil(LIter);
      end;
    finally
      FreeAndNil(LFakeParam);
    end;
    end;
end;

procedure TIdSoapBaseSender.ProcessOutClass(ABasicType: TIdSoapBasicType; Var AData; ASoapReader: TIdSoapReader; ABaseNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParamFlag: TParamFlag; AParam : TIdSoapITIParameter);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessOutClass';
var
  LRootNode : TIdSoapNode;
  LFakeParam: TIdSoapITIParameter;
  LPtr: Pointer;
  LClassName : String;
  LClass: TIdBaseSoapableClass;
  LClassType: PTypeInfo;
  LTClass: TIdBaseSoapableClassClass;
  LPropMan: TIdSoapPropertyManager;
  LSlot: Integer;
  LPropInfo: PPropInfo;
  LSpecialType: TIdSoapSimpleClassHandler;
  LGarbageCollect : boolean;
  LPrecreated : boolean;
  LPropType: PTypeInfo;
  LBufHolder: Array [1..10] of byte;
  LBuf: Pointer;
  LAnsiString: AnsiString;
  LWideString: WideString;
  LShortString: ShortString;
  LDynArr: Pointer;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  // no test ABasicType
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');
  Assert(Assigned(ASenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is nil');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert((ABaseNode = nil) or ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ABaseNode is not valid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');

  LGarbageCollect := FGarbageCollectObjects and ((ABaseNode = nil) or ( (ABaseNode.IsArray) and (ABaseNode.Parent = ASoapReader.BaseNode)) );
  LSpecialType := IdSoapSpecialType(ATypeInfo^.Name);
  if Assigned(LSpecialType) then
    begin
    try
      if not assigned(ABaseNode) and (AParamFlag = pfVar) then
        begin
        FreeAndNil(Pointer(AData));
        end;
      pointer(AData) := LSpecialType.GetParam(ASoapReader, ABaseNode, AParamName);
    finally
      FreeAndNil(LSpecialType);
      end;
    if LGarbageCollect and (TObject(AData) is TIdBaseSoapableClass) then
      begin
      FGarbageContext.Attach(TIdBaseSoapableClass(AData));
      end;
    end
  else
    begin
    if not assigned(ABaseNode) and (AParamFlag = pfVar) then
      begin
      FreeAndNil(Pointer(AData));
      end;
    pointer(AData) := nil;
    LClassType := nil;
    LPrecreated := false;
    LRootNode := ASoapReader.GetNodeNoClassnameCheck(ABaseNode, AParamName,True);
    if not Assigned(LRootNode) then  // its a nil class
      begin
      exit;
      end;
    if Assigned(LRootNode.Reference) then
      begin
      LRootNode := LRootNode.Reference;
      LPrecreated := (seoReferences in EncodingOptions) and assigned(LRootNode.ActualObject);
      end;
    if Assigned(ABaseNode) then
      begin
      if not LPrecreated then
        begin
        if LRootNode.TypeName <> '' then
          begin
          LClassName := AParam.ReverseReplaceType(LRootNode.TypeName, LRootNode.TypeNamespace, DefaultNamespace);
          LClassType := IdSoapGetTypeInfo(LClassname, AParam.TypeInformation);
          end
        else
          begin
          LClassName := AParam.NameOfType;
          LClassType := AParam.TypeInformation;
          end;
        Assert(assigned(LClassType), ASSERT_LOCATION+': Reference to class "'+LClassName+'" could not be resolved');
        pointer(LTClass) := GetTypeData(LClassType)^.ClassType;
        LClass := LTClass.Create;
        if LGarbageCollect then
          begin
          FGarbageContext.Attach(LClass);
          end;
        end
      else
        begin
        LClass := LRootNode.ActualObject as TIdBaseSoapableClass;
        end;
      TObject(AData) := LClass;
      end
    else
      begin
      if assigned(pointer(AData)) then
        begin
        FreeAndNil(AData);
        end;
      if not LPrecreated then
        begin
        if LRootNode.TypeName <> '' then
          begin
          LClassName := AParam.ReverseReplaceType(LRootNode.TypeName, LRootNode.TypeNamespace, DefaultNamespace);
          LClassType := IdSoapGetTypeInfo(LClassname, AParam.TypeInformation);
          end
        else
          begin
          // if we didn't get sent a type, then we have to go by what we expected
          LClassName := AParam.NameOfType;
          LClassType := AParam.TypeInformation;
          end;
        Assert(assigned(LClassType), ASSERT_LOCATION+': Reference to class "'+LClassName+'" could not be resolved');
        pointer(LTClass) := GetTypeData(LClassType)^.ClassType;
        LClass := LTClass.Create;
        end
      else
        begin
        LClass := LRootNode.ActualObject as TIdBaseSoapableClass;
        end;
      Pointer(AData) := LClass;
      end;
    if not LPrecreated then
      begin
      LRootNode.ActualObject := LClass;
      if FGarbageCollectObjects and ((ABaseNode = nil) or ( (ABaseNode.Parent <> nil) and ABaseNode.Parent.IsArray and (ABaseNode.Parent.Parent = ASoapReader.BaseNode))) then
        begin
        FGarbageContext.Attach(LClass as TIdBaseSoapableClass);
        end;
      LPropMan := IdSoapGetClassPropertyInfo(LClassType);
      LFakeParam := TIdSoapITIParameter.Create(nil,AParam);
      try
        LBuf := @LBufHolder;                  // its used as a generic holder
        for LSlot := 1 to LPropMan.Count do
          begin
          LPropInfo := LPropMan[LSlot];
          LPropType := LPropInfo^.PropType^;
          LFakeParam.Name := AParam.ReplacePropertyName(LClassType^.Name, LPropMan[LSlot]^.Name);
          LFakeParam.ParamFlag := pfOut;
          LFakeParam.TypeInformation := LPropType;
          LFakeParam.NameOfType := LPropType^.Name;
          case LPropType^.Kind of
            tkInteger:
              begin
              ProcessOutParams(LRootNode,LBuf,ASenderContext,-1,LFakeParam,ASoapReader, false);
              case GetTypeData(LPropType)^.OrdType of
                otSByte:     LPropMan.AsShortInt[LClass,LSlot] := ShortInt(LBuf^);
                otUByte:     LPropMan.AsByte[LClass,LSlot] := Byte(LBuf^);
                otSWord:     LPropMan.AsSmallInt[LClass,LSlot] := SmallInt(LBuf^);
                otUWord:     LPropMan.AsWord[LClass,LSlot] := Word(LBuf^);
                otSLong:     LPropMan.AsInteger[LClass,LSlot] := Integer(LBuf^);
    {$IFNDEF DELPHI4}
                otULong:     LPropMan.AsCardinal[LClass,LSlot] := Cardinal(LBuf^);
    {$ENDIF}
                else         raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, ['Integer: '+LPropType^.Name]));
                end;
              end;
            tkFloat:
              begin
              ProcessOutParams(LRootNode,LBuf,ASenderContext,-1,LFakeParam,ASoapReader,false);
              case GetTypeData(LPropType)^.FloatType of
                ftSingle:      LPropMan.AsSingle[LClass,LSlot] := Single(LBuf^);
                ftDouble:      LPropMan.AsDouble[LClass,LSlot] := Double(LBuf^);
                ftExtended:    LPropMan.AsExtended[LClass,LSlot] := Extended(LBuf^);
                ftComp:        LPropMan.AsComp[LClass,LSlot] := Comp(LBuf^);
                ftCurr:        LPropMan.AsCurrency[LClass,LSlot] := Currency(LBuf^);
                else  raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, ['Float: '+LPropType^.Name]));
                end;
              end;
            tkLString:
              begin
              ProcessOutParams(LRootNode,@LAnsiString,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsAnsiString[LClass,LSlot] := LAnsiString;
              end;
            tkWString:
              begin
              ProcessOutParams(LRootNode,@LWideString,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsWideString[LClass,LSlot] := LWideString;
              end;
            tkString:
              begin
              ProcessOutParams(LRootNode,@LShortString,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsShortString[LClass,LSlot] := LShortString;
              end;
            tkChar:
              begin
              ProcessOutParams(LRootNode,LBuf,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsChar[LClass,LSlot] := Char(LBuf^);
              end;
            tkWChar:
              begin
              ProcessOutParams(LRootNode,LBuf,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsWideChar[LClass,LSlot] := WideChar(LBuf^);
              end;
            tkEnumeration:
              begin
              // ProcessOutParams will take care of Boolean types too
              ProcessOutParams(LRootNode,LBuf,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsEnumeration[LClass,LSlot] := Integer(LBuf^);
              end;
            tkSet:
              begin
              ProcessOutParams(LRootNode,LBuf,ASenderContext,-1,LFakeParam,ASoapReader,false);
              case GetTypeData(LPropType)^.OrdType of
                otSByte:  LPropMan.AsShortInt[LClass,LSlot] := ShortInt(LBuf^);
                otUByte:  LPropMan.AsByte[LClass,LSlot] := Byte(LBuf^);
                otSWord:  LPropMan.AsSmallInt[LClass,LSlot] := SmallInt(LBuf^);
                otUWord:  LPropMan.AsWord[LClass,LSlot] := Word(LBuf^);
                otSLong:  LPropMan.AsInteger[LClass,LSlot] := Integer(LBuf^);
    {$IFNDEF DELPHI4}
                otULong:  LPropMan.AsCardinal[LClass,LSlot] := Cardinal(LBuf^);
    {$ENDIF}
                else  raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [LPropType^.Name]));
                end;
              end;
            tkInt64:
              begin
              ProcessOutParams(LRootNode,LBuf,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsInt64[LClass,LSlot] := Int64(LBuf^);
              end;
            tkDynArray:
              begin
              LDynArr := LPropMan.AsDynamicArray[LClass,LSlot];
              LPropMan.AsDynamicArray[LClass,LSlot] := nil;  // just in case we exception
              IdSoapDynArrayClear(LDynArr,LPropMan[LSlot]^.PropType^);  // finalize it as we're about to overwrite it
              ProcessOutParams(LRootNode,@LDynArr,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsDynamicArray[LClass,LSlot] := LDynArr;  // and place it in our object
              end;
            tkClass:
              begin
              LPtr := nil;
              ProcessOutParams(LRootNode,@LPtr,ASenderContext,-1,LFakeParam,ASoapReader,false);
              LPropMan.AsClass[LClass,LSlot] := LPtr;
              end;
            end;
          end;
      finally
        FreeAndNil(LFakeParam);
        end;
      end;
    end;
end;

// AParam can be nil if the data is not a parameter (this is intended for traversal of complex types using this routine recursivly)
// if AParam is nil, then AParamIndex is unused and AData is where to store the data
function TIdSoapBaseSender.ProcessParameter(ARootNode: TIdSoapNode; AEntryName: String; ASenderContext: TIdSoapSenderContext; ASoapWriter: TIdSoapWriter; var AData; const AParam: TIdSoapITIParameter; ATypeInfo: PTypeInfo; AParamIndex: Integer; AIsParameter : boolean; ADefault : Integer): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParameter';
var
  LParamName: String;
  LParamFlag: TParamFlag;
  LVarLoc: Pointer;
  LBasicType: TIdSoapBasicType;
  LIsVarParam: Boolean;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: RootNode is not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: AParameter is not valid');
  if AIsParameter then
    begin
    Assert(AParamIndex >= 0, ASSERT_LOCATION+'["'+Name+'"]: AParamIndex < 0');
    end;
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo = nil');
  if AIsParameter then
    begin
    LParamName := AParam.ReplaceName(AParam.Name);
    LParamFlag := AParam.ParamFlag;
    end
  else
    begin
    // i.e. a field object
    LParamName := AEntryName;   // What to call this entry
    LParamFlag := pfReference;  // just to remove the warning for now
    end;
  Assert(LParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: ParamName is blank');

  if LParamFlag in [pfVar, pfOut] then
    begin
    LIsVarParam := LParamFlag = pfVar;
    LVarLoc := Pointer(AData);
    if AIsParameter then  // its a parameter so we need to keep the param data location
      begin
      ASenderContext.ParamPtr[AParamIndex] := LVarLoc;  // for retrieving the result
      end;
    end
  else
    begin
    LIsVarParam := false;
    LVarLoc := @AData;
    end;
  if LParamFlag = pfOut then  // no need to prep it
    begin
    if ATypeInfo^.Kind = tkClass then
      begin
      pointer(LVarLoc^) := nil;
      end;
    Result := 4;    // all OUT type params are 4 bytes (pointer size)
    exit;
    end;

  LBasicType := IdSoapBasicTYpe(ATypeInfo);
  case ATypeInfo^.Kind of
    tkInt64,
    tkInteger:     Result := ProcessParamInteger(LBasicType,ASoapWriter,ARootNode,LParamName,ADefault,LVarLoc^);
    tkFloat:       Result := ProcessParamFloat(LBasicType,ASoapWriter,ARootNode,LParamName,ADefault,LVarLoc^);
    tkEnumeration: Result := ProcessParamEnum(LBasicType,ASoapWriter,ARootNode,LParamName,ATypeInfo,AParam,ADefault,LVarLoc^);
    tkSet:         Result := ProcessParamSet(LBasicType,ASoapWriter,ARootNode,LParamName,ATypeInfo,AParam,LVarLoc^);
    tkLString,
    tkWString,
    tkString,
    tkChar,
    tkWChar:       Result := ProcessParamStringChar(LBasicType,ASoapWriter,ARootNode,LParamName,AParam,ADefault,LVarLoc^);
    tkDynArray:    begin
                   Result := ProcessParamDynArray(LBasicType,ASoapWriter,ARootNode,LParamName,LVarLoc^,ATypeInfo,ASenderContext, AParam);
                   if LIsVarParam and (ARootNode = nil) then  // its a var type parameter
                     begin
                     IdSoapFreeArrayClasses(pointer(LVarLoc^),ATypeInfo,False);
                     end;
                   end;
    tkClass:       Result := ProcessParamClass(LBasicType,ASoapWriter,ARootNode,LParamName,LVarLoc^,ATypeInfo,ASenderContext,AParam);
    else           raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ATypeInfo^.Kind))+')');
    end;
  if LParamFlag in [pfVar, pfOut] then
    begin
    if (ATypeInfo^.Kind = tkString) and (LParamFlag = pfVar) then
      Result := 8
    else
      Result := 4;   // no matter what it was, if its a var, its an address and therefore 4 bytes
    end
end;

function TIdSoapBaseSender.ProcessParamInteger(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ADefault : Integer; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParamInteger';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ARootNode is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');

  Result := IdSoapRegisterSizeofBasicType(ABasicType);
  case ABasicType of
    isbtByte:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamByte(ARootNode, AParamName, Byte(AData));
          end;
        end;
    isbtShortInt:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamShortInt(ARootNode, AParamName, ShortInt(AData));
          end;
        end;
    isbtSmallInt:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamSmallInt(ARootNode, AParamName, SmallInt(AData));
          end;
        end;
    isbtWord:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamWord(ARootNode, AParamName, Word(AData));
          end;
        end;
{$IFNDEF DELPHI4}
    isbtCardinal:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamCardinal(ARootNode, AParamName, Cardinal(AData));
          end;
        end;
{$ENDIF}
    isbtInteger:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamInteger(ARootNode, AParamName, Integer(AData));
          end;
        end;
    isbtInt64:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Int64(AData) = 0) then
          begin
          ASoapWriter.DefineParamInt64(ARootNode, AParamName, Int64(AData));
          end;
        end;
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function TIdSoapBaseSender.ProcessParamSet(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ATypeInfo : PTypeInfo; const AParam: TIdSoapITIParameter; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParamSet';
var
  LType, LTypeNS : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ARootNode is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: Param is not valid');
  Result := IdSoapRegisterSizeofBasicType(ABasicType);

  AParam.ReplaceTypeName(ATypeInfo^.Name, DefaultNamespace, LType, LTypeNS);

  case ABasicType of
    isbtSetByte:     ASoapWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(ATypeInfo), Byte(AData));
    isbtSetShortInt: ASoapWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(ATypeInfo), ShortInt(AData));
    isbtSetSmallInt: ASoapWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(ATypeInfo), SmallInt(AData));
    isbtSetWord:     ASoapWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(ATypeInfo), Word(AData));
{$IFNDEF DELPHI4}
    isbtSetCardinal: ASoapWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(ATypeInfo), Cardinal(AData));
{$ENDIF}                                                             
    isbtSetInteger:  ASoapWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(ATypeInfo), Integer(AData));
    else             raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function TIdSoapBaseSender.ProcessParamFloat(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ADefault : integer; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParamFloat';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ARootNode is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  result := IdSoapRegisterSizeofBasicType(ABasicType);
  case ABasicType of
    isbtSingle:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Single(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamSingle(ARootNode, AParamName, Single(AData));
          end;
        end;
    isbtDouble:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Double(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamDouble(ARootNode, AParamName, Double(AData));
          end;
        end;
    isbtExtended:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Extended(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamExtended(ARootNode, AParamName, Extended(AData));
          end;
        end;
    isbtComp:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Comp(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamComp(ARootNode, AParamName, Comp(AData));
          end;
        end;
    isbtCurrency:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Currency(AData) = ADefault) then
          begin
          ASoapWriter.DefineParamCurrency(ARootNode, AParamName, Currency(AData));
          end;
        end;
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function TIdSoapBaseSender.ProcessParamEnum(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; ATypeInfo: PTypeInfo; const AParam: TIdSoapITIParameter; ADefault : Integer; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParamEnum';
var
  LType, LTypeNS : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ARootNode is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: Param is not valid');
  AParam.ReplaceTypeName(ATypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
  result := IdSoapRegisterSizeofBasicType(ABasicType);
  case ABasicType of
    // no defaults for booleans
    isbtBoolean: ASoapWriter.DefineParamBoolean(ARootNode, AParamName, Boolean(AData));
    // default value of 0 is treated as no default. This a problem - but what can one do?
    isbtEnumShortInt:
        begin
        if ((ADefault <> 0) and (ADefault <> MAXINT)) and (not (seoSendNoDefaults in EncodingOptions) or not (ShortInt(AData) = ADefault)) then
          begin
          ASoapWriter.DefineParamEnumeration(ARootNode, AParamName, ATypeInfo, LType, LTypeNS, AParam, ShortInt(AData));
          end;
        end;
    isbtEnumByte:
        begin
        if ((ADefault <> 0) and (ADefault <> MAXINT)) and (not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault)) then
          begin
          ASoapWriter.DefineParamEnumeration(ARootNode, AParamName, ATypeInfo, LType, LTypeNS, AParam, Byte(AData));
          end;
        end;
    isbtEnumSmallInt:
        begin
        if ((ADefault <> 0) and (ADefault <> MAXINT)) and (not (seoSendNoDefaults in EncodingOptions) or not (SmallInt(AData) = ADefault)) then
          begin
          ASoapWriter.DefineParamEnumeration(ARootNode, AParamName, ATypeInfo, LType, LTypeNS, AParam, SmallInt(AData));
          end;
        end;
    isbtEnumWord:
        begin
        if ((ADefault <> 0) and (ADefault <> MAXINT)) and (not (seoSendNoDefaults in EncodingOptions) or not (Word(AData) = ADefault)) then
          begin
          ASoapWriter.DefineParamEnumeration(ARootNode, AParamName, ATypeInfo, LType, LTypeNS, AParam, Word(AData));
          end;
        end;
    isbtEnumInteger:
        begin
        if ((ADefault <> 0) and (ADefault <> MAXINT)) and (not (seoSendNoDefaults in EncodingOptions) or not (Integer(AData) = ADefault)) then
          begin
          ASoapWriter.DefineParamEnumeration(ARootNode, AParamName, ATypeInfo, LType, LTypeNS, AParam, Integer(AData));
          end;
        end;
{$IFNDEF DELPHI4}
    isbtEnumCardinal:
        begin
        if ((ADefault <> 0) and (ADefault <> MAXINT)) and (not (seoSendNoDefaults in EncodingOptions) or not (integer(AData) = ADefault)) then
          begin
          ASoapWriter.DefineParamEnumeration(ARootNode, AParamName, ATypeInfo, LType, LTypeNS, AParam, Cardinal(AData));
          end;
        end;
{$ENDIF}
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function TIdSoapBaseSender.ProcessParamStringChar(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; AParam: TIdSoapITIParameter; ADefault : integer; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParamStringChar';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ARootNode is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Result := IdSoapRegisterSizeofBasicType(ABasicType);
  case ABasicType of
    isbtLongString:
         begin
         if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (String(AData) = '') then
           begin
           ASoapWriter.DefineParamString(ARootNode, AParamName, String(AData));  // the debugger displays it wrong but its correct
           end;
         end;
    isbtWideString:
         begin
         if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (WideString(AData) = '') then
           begin
           ASoapWriter.DefineParamWideString(ARootNode, AParamName, WideString(AData));  // the debugger displays it wrong but its correct
           end;
         end;
    isbtShortString:
         begin
         if (not Assigned(AParam)) or (AParam.ParamFlag = pfVar) then
           begin
           if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (ShortString(AData) = '') then
             begin
             ASoapWriter.DefineParamShortString(ARootNode, AParamName, ShortString(AData));
             end;
           end
         else
           begin
           if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (ShortString(Pointer(AData)^) = '') then
             begin
             ASoapWriter.DefineParamShortString(ARootNode, AParamName, ShortString(Pointer(AData)^));
             end;
           end;
         Result := Sizeof(Pointer);
         end;
    isbtChar:        ASoapWriter.DefineParamChar(ARootNode, AParamName, Char(AData));
    isbtWideChar:    ASoapWriter.DefineParamWideChar(ARootNode, AParamName, WideChar(AData));
    else             raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function TIdSoapBaseSender.ProcessParamDynArray(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; Var AData; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParam: TIdSoapITIParameter): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParamDynArray';
var
  LDynArr: Pointer;
  LSubscripts : TIdSoapDynArrSubscriptEntryArray;
  LRoot,LNode: TIdSoapNode;
  LTypeInfo: PTypeInfo;
  LAdjust: Integer;
  LIndex : Integer;
  LIsComplexType: Boolean;
  LSubEntry: ^TIdSoapDynArrSubscriptEntry;
  LEndOfSubscript: Integer;
  LGarbageCollect : boolean;
  LData : pointer;
  LClass : TObject;
  LType, LTypeNS : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ARootNode is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');

  Result := Sizeof(Pointer);
  LDynArr := pointer(AData);       // the actual dynamic array
  if not Assigned(LDynArr) then       // theres no array to send so get out
    begin
    exit;
    end;
  // prepare for array traversal
  IdSoapDynArrSetupSubscriptCounter(LSubscripts,LDynArr,ATypeInfo);
  LTypeInfo := IdSoapGetDynArrBaseTypeInfo(ATypeInfo);
  LGarbageCollect := FGarbageCollectObjects and (ARootNode = nil) and (LTypeInfo^.Kind = tkClass);
  LType := GetNativeSchemaType(LTypeInfo^.Name);
  if LType <> '' then
    begin
    LTypeNS := ID_SOAP_NS_SCHEMA_2001;
    end
  else
    begin
    AParam.ReplaceTypeName(LTypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
    end;
  LRoot := ASoapWriter.AddArray(ARootNode,AParamName, LType, LTypeNS, (LTypeInfo^.Kind = tkDynArray) or ((LTypeInfo^.Kind = tkClass) and (not IsSpecialClass(LTypeInfo^.Name))));
  // iterate through all populated array elements
  case LTypeInfo^.Kind of
    tkClass,tkDynArray:
      begin
      LAdjust := 0;
      LIsComplexType := True;
      end;
    else
      begin
      LAdjust := 1;
      LIsComplexType := False;
      end;
    end;
  while IdSoapDynArrNextEntry(LDynArr,LSubscripts) do
    begin
    LData := IdSoapDynArrData(LSubscripts,LDynArr);
    // Garbge collection
    if LGarbageCollect then
      begin
      LClass := TObject(LData^);
      if LClass is TIdBaseSoapableClass then
        begin
        FGarbageContext.Attach(LClass as TIdBaseSoapableClass);
        end;
      end;
    // build node tree to suit this entry
    LEndOfSubscript := length(LSubscripts)-1-LAdjust;
    for LIndex := 0 to LEndOfSubscript do
      begin
      LSubEntry := @LSubscripts[LIndex];
      if not Assigned(LSubEntry^.Node) then  // need to add one
        begin
        if LIndex = 0 then
          LNode := LRoot
        else
          LNode := LSubscripts[LIndex-1].Node;
        // this next test prevents wrong additions for complex types
        if LIsComplexType and (LIndex=LEndOfSubscript)  then
          LSubEntry^.Node := LNode
        else
          LSubEntry^.Node := ASoapWriter.AddArray(LNode, IntToStr(LSubEntry^.Entry), LType, LTypeNS, (LTypeInfo^.Kind = tkDynArray) or ((LTypeInfo^.Kind = tkClass) and (not IsSpecialClass(LTypeInfo^.Name))));
        end;
      end;
    // put the data into the leaf node entry
    if (Length(LSubscripts) = 1) and (LTypeInfo^.Kind <> tkClass) then  // due to the node/parameter issues, 1 dim arrays of simple types are special
      ProcessParameter(LRoot,inttostr(LSubscripts[length(LSubscripts)-1].Entry),ASenderContext,ASoapWriter,LData^,AParam,LTypeInfo,-1, false, MAXINT)
    else
      ProcessParameter(LSubscripts[length(LSubscripts)-1-LAdjust].Node,inttostr(LSubscripts[length(LSubscripts)-1].Entry),ASenderContext,ASoapWriter,LData^,AParam,LTypeInfo,-1, false, MAXINT);
    end;
end;

function TIdSoapBaseSender.ProcessParamClass(ABasicType: TIdSoapBasicType; ASoapWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParamName: String; Var AData; ATypeInfo: PTypeInfo; ASenderContext: TIdSoapSenderContext; AParam: TIdSoapITIParameter): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessParamClass';
var
  LClass: TObject;
  LBuf,LPtr: Pointer;
  LBufMem: Array [1..10] of byte;  // extended type consumes the most space
  LRoot: TIdSoapNode;
  LPropMan: TIdSoapPropertyManager;
  LPropInfo: PPropInfo;
  LPropType: PTypeInfo;
  LIndex : Integer;
  LShortString: ShortString;
  LAnsiString: String;
  LWideString: WideString;
  LInt64: Int64;
  LInteger: Integer;
  LDynArr: Pointer;
  LSpecialType: TIdSoapSimpleClassHandler;
  LName : string;
  LType, LTypeNS : string;
  LWorkingType : PTypeInfo;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');
  Assert((ARootNode = nil) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+'["'+Name+'"]: ARootNode is not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: AParamName is empty');
  Assert(Assigned(@AData), ASSERT_LOCATION+'["'+Name+'"]: AData is nil');
  Assert(Assigned(ATypeInfo), ASSERT_LOCATION+'["'+Name+'"]: ATypeInfo is nil');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+'["'+Name+'"]: ASoapWriter is not valid');

  Result := Sizeof(Pointer);
  LClass := pointer(AData);       // the actual class instance

  LSpecialType := IdSoapSpecialType(ATypeInfo^.Name);
  if Assigned(LSpecialType) then
    begin
    try
      LSpecialType.DefineParam(ASoapWriter, ARootNode, AParamName, LClass);  // the debugger displays it wrong but its correct
    finally
      FreeAndNil(LSpecialType);
      end;
    end
  else
    begin
    LBuf := @LBufMem;                  // its used as a generic holder
    if LClass = nil then  // I don't think we need to send anything for nil classes
      begin
      exit;
      end;
    // polymorphism support
    LWorkingType := GetTypeForClass(ATypeInfo, LClass);
    Assert(Assigned(LWorkingType), ASSERT_LOCATION+'["'+Name+'"]: No RTTI info for class');
    AParam.ReplaceTypeName(LWorkingType^.Name, DefaultNamespace, LType, LTypeNS);
    LRoot := ASoapWriter.AddStruct(ARootNode,AParamName,LType, LTypeNS, LClass);
    // cause if we've already coded this object, then we don't need to again
    if Assigned(LRoot) then
      begin
      LRoot.ForceTypeInXML := LWorkingType <> ATypeInfo;
      if FGarbageCollectObjects and (ARootNode = nil) then
        begin
        FGarbageContext.Attach(LClass as TIdBaseSoapableClass);
        end;

      LPropMan := IdSoapGetClassPropertyInfo(LWorkingType);
      Assert(Assigned(LPropMan), ASSERT_LOCATION+'["'+Name+'"]: Unable to locate property info for class ' + LWorkingType^.Name);
      for LIndex:=1 to LPropMan.Count do
        begin
        LPropInfo := LPropMan[LIndex];
        LPropType := LPropInfo^.PropType^;
        LName := AParam.ReplacePropertyName(LWorkingType^.Name, LPropMan[LIndex]^.Name);
        case LPropType^.Kind of
          tkInteger:
            begin
            case GetTypeData(LPropType)^.OrdType of
              otSByte:  ShortInt(LBuf^) := LPropMan.AsShortInt[LClass,LIndex];
              otUByte:  Byte(LBuf^) := LPropMan.AsByte[LClass,LIndex];
              otSWord:  SmallInt(LBuf^) := LPropMan.AsSmallInt[LClass,LIndex];
              otUWord:  Word(LBuf^) := LPropMan.AsWord[LClass,LIndex];
              otSLong:  Integer(LBuf^) := LPropMan.AsInteger[LClass,LIndex];
  {$IFNDEF DELPHI4}
              otULong:  Cardinal(LBuf^) := LPropMan.AsCardinal[LClass,LIndex];
  {$ENDIF}
              else      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(LPropType^.Kind))+')');
              end;
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LBuf^,AParam,LPropMan[LIndex]^.PropType^,-1, false, LPropMan.DefaultValue[LClass,LIndex]);
            end;
          tkFloat:
            begin
            case GetTypeData(LPropType)^.FloatType of
              ftSingle:      Single(LBuf^) := LPropMan.AsSingle[LClass,LIndex];
              ftDouble:      Double(LBuf^) := LPropMan.AsDouble[LClass,LIndex];
              ftExtended:    Extended(LBuf^) := LPropMan.AsExtended[LClass,LIndex];
              ftComp:        Comp(LBuf^) := LPropMan.AsComp[LClass,LIndex];
              ftCurr:        Currency(LBuf^) := LPropMan.AsCurrency[LClass,LIndex];
              else           raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(GetTypeData(LPropType)^.FloatType))+')');
              end;
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LBuf^,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkLString:
            begin
            LAnsiString := LPropMan.AsAnsiString[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LAnsiString,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkWString:
            begin
            LWideString := LPropMan.AsWideString[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LWideString,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkString:
            begin
            LShortString := LPropMan.AsShortString[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LShortString,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkChar:
            begin
            Char(LBuf^) := LPropMan.AsChar[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LBuf^,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkWChar:
            begin
            WideChar(LBuf^) := LPropMan.AsWideChar[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LBuf^,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkEnumeration:
            begin
            // special boolean case will be looked after by call to ProcessParameter
            LInteger := LPropMan.AsEnumeration[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LInteger,AParam,LPropMan[LIndex]^.PropType^,-1, false, LPropMan.DefaultValue[LClass,LIndex]);
            end;
          tkSet:
            begin
            case GetTypeData(LPropType)^.OrdType of
              otSByte:  ShortInt(LBuf^) := LPropMan.AsShortInt[LClass,LIndex];
              otUByte:  Byte(LBuf^) := LPropMan.AsByte[LClass,LIndex];
              otSWord:  SmallInt(LBuf^) := LPropMan.AsSmallInt[LClass,LIndex];
              otUWord:  Word(LBuf^) := LPropMan.AsWord[LClass,LIndex];
              otSLong:  Integer(LBuf^) := LPropMan.AsInteger[LClass,LIndex];
  {$IFNDEF DELPHI4}
              otULong:  Cardinal(LBuf^) := LPropMan.AsCardinal[LClass,LIndex];
  {$ENDIF}
              else      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(GetTypeData(LPropType)^.OrdType))+')');
              end;
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LBuf^,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkInt64:
            begin
            LInt64 := LPropMan.AsInt64[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LInt64,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          tkDynArray:
            begin

            LDynArr := LPropMan.AsDynamicArray[LClass,LIndex];  // this needs to have finalize run against the array when finished
            try
              ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LDynArr,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            finally
              IdSoapDynArrayClear(LDynArr,LPropMan[LIndex]^.PropType^);  // finalize it
              end;
            end;
          tkClass:
            begin
            LPtr := LPropMan.AsClass[LClass,LIndex];
            ProcessParameter(LRoot,LName,ASenderContext,ASoapWriter,LPtr,AParam,LPropMan[LIndex]^.PropType^,-1, false);
            end;
          end;
        end;
      end; // Assigned(LRoot)
    end;
end;

function TIdSoapBaseSender.ProcessResult(AResultType: PTypeInfo; ASoapReader: TIdSoapReader; AParams: Pointer; ASenderContext: TIdSoapSenderContext; AMethod : TIdSoapITIMethod): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResult';
var
  LBasicType: TIdSoapBasicType;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+'["'+Name+'"]: AResultType cannot be NIL');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');
  Assert(Assigned(AParams), ASSERT_LOCATION+'["'+Name+'"]: AParams cannot be NIL');
  Assert(FResultParamName <> '', ASSERT_LOCATION+'["'+Name+'"]: Name of Return Parameter not identified');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');

  LBasicType := IdSoapBasicType(AResultType);
  case AResultType^.Kind of
    tkInt64,
    tkInteger:        Result := ProcessResultInteger(LBasicType,ASoapReader);
    tkFloat:          Result := ProcessResultFloat(LBasicType,ASoapReader);
    tkLString,
    tkWString,
    tkString,
    tkChar,
    tkWChar:          Result := ProcessResultStringChar(LBasicType,ASoapReader,AResultType,AParams);
    tkEnumeration:    Result := ProcessResultEnum(LBasicType,ASoapReader,AResultType, AMethod);
    tkSet:            Result := ProcessResultSet(LBasicType,ASoapReader,AResultType, AMethod);
    tkDynArray:       Result := ProcessResultDynArray(ASoapReader,AParams,AResultType,ASenderContext,AMethod);
    tkClass:          Result := ProcessResultClass(AResultType,ASenderContext,ASoapReader,AMethod);
    else              raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+AResultType^.Name+'/'+inttostr(ord(AResultType^.Kind))+')');
    end;
end;

function  TIdSoapBaseSender.ProcessResultInteger(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResultInteger';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');

  case ABasicType of
    isbtByte:      Result := ASoapReader.ParamByte[nil, FResultParamName];
    isbtShortInt:  Result := ASoapReader.ParamShortInt[nil, FResultParamName];
    isbtSmallInt:  Result := ASoapReader.ParamSmallInt[nil, FResultParamName];
    isbtWord:      Result := ASoapReader.ParamWord[nil, FResultParamName];
{$IFNDEF DELPHI4}
    isbtCardinal:  Result := ASoapReader.ParamCardinal[nil, FResultParamName];
{$ENDIF}
    isbtInteger:   Result := ASoapReader.ParamInteger[nil, FResultParamName];
    isbtInt64:     Result := ASoapReader.ParamInt64[nil, FResultParamName];
    else           raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function  TIdSoapBaseSender.ProcessResultFloat(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResultFloat';
var
  LTempPtr: Pointer;
  LTempData: array [1..3] of Cardinal;  // used for floating point temp storage
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');

  LTempPtr := @LTempData;     // we want an untyped pointer to typecase float values to
  Result := 0;  // to eliminate warning as float types are on the stack not in registers
  case ABasicType of
    isbtSingle:
      begin
      Single(LTempPtr^) := ASoapReader.ParamSingle[nil, FResultParamName];
      asm
        fld DWord Ptr LTempData
        end;
      end;
    isbtDouble:
      begin
      Double(LTempPtr^) := ASoapReader.ParamDouble[nil, FResultParamName];
      asm
        fld QWord Ptr LTempData
        end;
      end;
    isbtExtended:
      begin
      Extended(LTempPtr^) := ASoapReader.ParamExtended[nil, FResultParamName];
      asm
        fld TByte Ptr LTempData
        end;
      end;
    isbtComp:
      begin
      Comp(LTempPtr^) := ASoapReader.ParamComp[nil, FResultParamName];
      asm
        fild QWord Ptr LTempData
        end;
      end;
    isbtCurrency:
      begin
      Currency(LTempPtr^) := ASoapReader.ParamCurrency[nil, FResultParamName];
      asm
        fild QWord Ptr LTempData
        end;
      end;
    else            raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function  TIdSoapBaseSender.ProcessResultStringChar(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader; AResultType: PTypeInfo; AParams: Pointer): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResultStringChar';
var
  LTempPtr: Pointer;
  LTypeData: PTypeData;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+'["'+Name+'"]: AResultType is nil');
  Assert(Assigned(AParams), ASSERT_LOCATION+'["'+Name+'"]: AParams is nil');

  case ABasicType of
    isbtShortString:
      begin
      Result := 0;  // not used for a ShortString
      LTempPtr := Pointer(Pointer(PChar(AParams) - 8)^);
      LTypeData := GetTypeData(AResultType);
      ShortString(LTempPtr^) := copy(ASoapReader.ParamShortString[nil, FResultParamName], 1, LTypeData^.MaxLength);
      end;
    isbtLongString:
        begin
        Result := 0;   // not needed for LongStrings
        // Ret var on stack is 8 bytes above param pointer.
        // 4 bytes for ret adr and 4 bytes for the param itself
        LTempPtr := Pointer(Pointer(PChar(AParams) - 8)^);
        String(LTempPtr^) := ASoapReader.ParamString[nil, FResultParamName];
        end;
    isbtWideString:
        begin
        Result := 0;   // not needed for WideStrings
        // Ret var on stack is 8 bytes above param pointer.
        // 4 bytes for ret adr and 4 bytes for the param itself
        LTempPtr := Pointer(Pointer(PChar(AParams) - 8)^);
        WideString(LTempPtr^) := ASoapReader.ParamWideString[nil, FResultParamName];
        end;
    isbtChar:
        begin
        Result := Ord(ASoapReader.ParamChar[nil, FResultParamName]);
        end;
    isbtWideChar:
        begin
        Result := Ord(ASoapReader.ParamWideChar[nil, FResultParamName]);
        end;
    else            raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function  TIdSoapBaseSender.ProcessResultSet(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader; AResultType: PTypeInfo; AMethod : TIdSoapITIMethod): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResultSet';
var
  LType, LTypeNS : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+'["'+Name+'"]: AResultType is nil');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');

  AMethod.ReplaceTypeName(AResultType^.Name, DefaultNamespace, LType, LTypeNS);
  result := ASoapReader.ParamSet[nil, FResultParamName, LType, LTypeNS, GetSetContentType(AResultType)];
end;

function  TIdSoapBaseSender.ProcessResultEnum(ABasicType: TIdSoapBasicType; ASoapReader: TIdSoapReader; AResultType: PTypeInfo; AMethod : TIdSoapITIMethod): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResultEnum';
var
  LType, LTypeNS : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+'["'+Name+'"]: AResultType is nil');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');

  AMethod.ReplaceTypeName(AResultType^.Name, DefaultNamespace, LType, LTypeNS);
  case ABasicType of
    isbtBoolean:        Result := ord(ASoapReader.ParamBoolean[nil, FResultParamName]);
    isbtEnumShortInt,
    isbtEnumSmallInt,
    isbtEnumByte,
    isbtEnumWord,
    isbtEnumCardinal,
    isbtEnumInteger:    Result := ASoapReader.ParamEnumeration[nil, FResultParamName, AResultType, LType, LTypeNS, AMethod];
    else                raise EIdSoapUnknownType.Create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_ENGINE_UNKNOWN_TYPE+'('+inttostr(ord(ABasicType))+')');
    end;
end;

function TIdSoapBaseSender.ProcessResultDynArray(ASoapReader: TIdSoapReader; AParams: Pointer; AResultType: PTypeInfo; ASenderContext: TIdSoapSenderContext; AMethod : TIdSoapITIMethod): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResultDynArray';
var
  LRootNode,LNode: TIdSoapNode;
  LPtr,LPtr1,LTempPtr: Pointer;
  LFakeParam: TIdSoapITIParameter;
  LTypeInfo: PTypeInfo;
  LIsComplexType: Boolean;
  LIter: TIdSoapNodeIterator;
  LSubscripts: Integer;
  LSubscriptInfo: TIdSoapNodeIteratorInfo;
  LTemp: Integer;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+'["'+Name+'"]: AResultType is nil');
  Assert(Assigned(AParams), ASSERT_LOCATION+'["'+Name+'"]: AParams is nil');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');

  Result := 0;  // not used for dynamic arrays
  LRootNode := ASoapReader.GetArray(nil, FResultParamName, true);
  if not assigned(LRootNode) then
    begin
    // empty array
    result := 0;
    end
  else
    begin
    If assigned(LRootNode.Reference) then
      begin
      LRootNode := LRootNode.Reference;
      end;
    Lptr := nil;  // where we will save the array
    LFakeParam := TIdSoapITIParameter.Create(nil, AMethod); // not part of the ITI, but connected to the ITI Name/Type replacement system
    try
      LFakeParam.ParamFlag := pfReference;
      LTypeInfo := IdSoapGetDynArrBaseTypeInfo(AResultType);
      LFakeParam.TypeInformation := LTypeInfo;
      LFakeParam.NameOfType := LFakeParam.TypeInformation^.Name;
      case IdSoapGetDynArrBaseTypeInfo(AResultType)^.kind of
        tkClass,tkDynArray:  LIsComplexType := True;
        else                 LIsComplexType := False;
      end;

      LIter := TIdSoapNodeIterator.Create;
      try
        LSubscripts := IdSoapDynArrSubscriptsFromTypeInfo(AResultType);
        if not LIsComplexType then
          dec(LSubscripts);
        // need to check for LSubscripts=0 here and react accordingly (AC)
        if LSubscripts = 0 then
          begin
          LFakeParam.NameOfType := AResultType^.Name;
          for LTemp:=0 to LRootNode.Params.Count-1 do
            begin
            LFakeParam.Name := LRootNode.Params[LTemp];
            LPtr1 := IdSoapGetDynamicArrayDataFromNode(pointer(LPtr),AResultType,LIter.Info,IdSoapIndexFromName(LFakeParam.Name, ASSERT_LOCATION+'["'+Name+'"]'),LTypeInfo);
            ProcessOutParams(LRootNode,LPtr1,ASenderContext,-1,LFakeParam,ASoapReader, false);
            end;
          end;
        if LIter.First(LRootNode,LSubscripts) then
          begin
          repeat
            if LIsComplexType then
              begin
              LSubscriptInfo := LIter.Info[LSubscripts-1];  // info on the leaf node of the array
              LNode := LSubscriptInfo.Node.Children.Objects[LSubscriptInfo.Index] as TIdSoapNode;
              LFakeParam.Name := LNode.Name;
              LNode := LNode.Parent;
              LPtr1 := IdSoapGetDynamicArrayDataFromNode(pointer(LPtr),AResultType,LIter.Info,-1,LTypeInfo);
              ProcessOutParams(LNode,LPtr1,ASenderContext,-1,LFakeParam,ASoapReader, false);
              end
            else
              begin
              // get the node below me as this has the final details
              LSubscriptInfo := LIter.Info[LSubscripts-1];  // info on the leaf node of the array
              LNode := LSubscriptInfo.Node.Children.Objects[LSubscriptInfo.Index] as TIdSoapNode;
              ASoapReader.LinkReferences(LNode);
              If LNode.Reference <> nil then
                begin
                LNode := LNode.Reference;
                ASoapReader.LinkReferences(LNode);
                end;
              for LTemp:=0 to LNode.Params.Count-1 do
                begin
                LFakeParam.Name := LNode.Params[LTemp];
                LPtr1 := IdSoapGetDynamicArrayDataFromNode(pointer(LPtr),AResultType,LIter.Info,IdSoapIndexFromName(LFakeParam.Name, ASSERT_LOCATION+'["'+Name+'"]'),LTypeInfo);
                ProcessOutParams(LNode,LPtr1,ASenderContext,-1,LFakeParam,ASoapReader,false);
                end;
              end;
            until not LIter.Next;
          end;
      finally
        FreeAndNil(LIter);
      end;
    finally
      FreeAndNil(LFakeParam);
      end;
    // LPtr has the result ptr
    LTempPtr := Pointer(Pointer(PChar(AParams) - 8)^);
    pointer(LTempPtr^) := LPtr;
    end;
end;

function TIdSoapBaseSender.ProcessResultClass(AResultType: PTypeInfo; ASenderContext: TIdSoapSenderContext; ASoapReader: TIdSoapReader; AMethod : TIdSoapITIMethod): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessResultClass';
var
  LFakeParam: TIdSoapITIParameter;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+'["'+Name+'"]: ASoapReader is not valid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+'["'+Name+'"]: AResultType is nil');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+'["'+Name+'"]: ASenderContext is not valid');

  LFakeParam := TIdSoapITIParameter.Create(nil, AMethod); // not part of the ITI, but connected to the ITI name/type replacement system
  try
    LFakeParam.Name := FResultParamName;
    LFakeParam.ParamFlag := pfOut;
    LFakeParam.TypeInformation := AResultType;
    LFakeParam.NameOfType := AResultType^.Name;
    Result := 0;
    ProcessOutParams(nil,@Result,ASenderContext,-1,LFakeParam,ASoapReader,false);
  finally
    LFakeParam.Free;
    end;
end;

function TIdSoapBaseSender.SoapSend(AWriter : TIdSoapWriter; AGlue : TIdSoapInterfaceGlue; ASoapAction : string = '') : TIdSoapReader;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.SoapSend';
var
  LRequest: TMemoryStream;
  LRequestMimeType : string;
  LResponse: TMemoryStream;
  LResponseMimeType : string;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': Writer is not valid');
  {$IFDEF ID_SOAP_SHOW_NODES}
  ShowNode('Client Params',AGlue.Intf.Name,LMethod.Name,LSoapWriter.BaseNode);
  {$ENDIF}
  LRequest := TMemoryStream.Create;
  try
    AWriter.Encode(LRequest, LRequestMimeType, OnSendMessageDom, self);
    LRequest.Position := 0;
    DoSendMessage(LRequest);
    if FHasResponses then
      begin
      LResponse := TMemoryStream.Create;
      try
        DoSoapRequest(ASoapAction, LRequestMimeType, LRequest, LResponse, LResponseMimeType);
        LResponse.Position := 0;
        DoReceiveMessage(LResponse);
        result := CreatePacketReader(LResponseMimeType, LResponse, FSoapVersion, XMLProvider);
        try
          result.EncodingMode := AWriter.EncodingMode;
          result.EncodingOptions := EncodingOptions;
          result.ReadMessage(LResponse, LResponseMimeType, OnReceiveMessageDom, self);
          result.CheckPacketOK;
          result.ProcessHeaders;
          CheckForSessionInfo(result);
          result.DecodeMessage;
          {$IFDEF ID_SOAP_SHOW_NODES}
          ShowNode('Client Ret/Outs/Vars',AGlue.Intf.Name,LMethod.Name,LSoapReader.BaseNode);
          {$ENDIF}
        except
          on e:exception do
            begin
            FreeAndNil(result);
            raise;
            end
        end;
      finally
        FreeAndNil(LResponse);
      end;
    end
  else
    begin
    DoSoapSend(ASoapAction, LRequestMimeType, LRequest);
    result := nil;
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

function TIdSoapBaseSender.CommonEntry(AGlue: TIdSoapInterfaceGlue; CallID: Integer; Params: Pointer): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.CommonEntry';
type
  PString = ^String;
var
  LMethod: TIdSoapITIMethod;
  LParamIndex: Integer;
  LParam: TIdSoapITIParameter;
  LSoapWriter: TIdSoapWriter;
  LSoapReader: TIdSoapReader;
  LParamPtr: Pointer;
  LResultType: PTypeInfo;
  LClientContext: TIdSoapSenderContext;
begin
  if AGlue.FParent.FSender = nil then
    begin
    Assert(CallId=3, ASSERT_LOCATION+': Invalid interface method call. Client has previously been destroyed'); // don't use name, isn't valid if test fails
    AGlue._Release;
{$IFDEF DELPHI4}
      // This line is really confusing. Please leave any commented out bits in this IFDEF alone (AC)
//    AGlue.FParent._Release;        // D4 seems to be different
{$ENDIF}
    result := 0;
    exit;
    end;
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  Assert(AGlue.TestValid(TIdSoapInterfaceGlue), ASSERT_LOCATION+'["'+Name+'"]: Glue is not valid');
  IdRequire(Active, ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_CLIENT_NOT_ACTIVE);
  if FGarbageCollectObjects then
    begin
    FGarbageContext.CleanUp;
    end;

  Result := 0;
  if CallId <= 3 then  // stops wasting time doing multiple mostly redundent tests
    begin
    if CallId = 1 then       // its QueryInterface  (but its for the SOAP object, not the client)
      begin
      if not IsEqualGUID(AGlue.IID,TGUID(Params^)) then  // its not us
        Result := E_NOTIMPL
      else
        begin
        inc(PChar(Params), Sizeof(TGUID));
        Pointer(Params^) := @AGlue.FInterfacePtr;  // assign to OUT (2nd param in QueryInterface )
        end;
      end
    // addref and release are referred to the glue. This means that the interfaces
    // hanging off the client have their own reference count and the client itself
    // isn't reference counted
    else if CallID = 2 then  // its an addref
      begin
      Result := AGlue._AddRef;
      end
    else if CallId = 3 then  // its a release
      begin
      result := AGlue._Release;
      end
    else
      Assert(False, ASSERT_LOCATION+'["'+Name+'"]: Invalid Special VTable entry');
    end
  else
    begin
    LParamPtr := Params;
    Assert(Assigned(AGlue.Intf), ASSERT_LOCATION+'["'+Name+'"]: Glue.Intf is nil');
    Assert(Assigned(AGlue.Intf.Methods), ASSERT_LOCATION+'["'+Name+'"]: Glue.Intf.Methods is nil');
    LMethod := AGlue.Intf.Methods.Objects[CallID - 4] as TIdSoapITIMethod;  // interface methods start at 4 (Delphi TIndex starts at 0)
    if not FHasResponses then
      begin
      CheckMethodForNoResponseMode(LMethod);
      end;
    FRecvHeaders.DeleteAll;
    LSoapWriter := CreateWriter;
    try
      LSoapWriter.EncodingMode := LMethod.EncodingMode;
      LClientContext := TIdSoapSenderContext.Create;
      try
        if AGlue.Intf.Namespace <> '' then
          begin
          LSoapWriter.SetMessageName(LMethod.RequestMessageName, AGlue.Intf.Namespace);
          end
        else
          begin
          LSoapWriter.SetMessageName(LMethod.RequestMessageName, DefaultNamespace);
          end;
        ProcessHeadersSend(LMethod, LSoapWriter, LClientContext);
        for LParamIndex := 0 to LMethod.Parameters.Count - 1 do
          begin
          LParam := LMethod.Parameters.Param[LParamIndex];
          inc(PChar(LParamPtr), ProcessParameter(nil,'',LClientContext, LSoapWriter, LParamPtr^, LParam, IdSoapGetTypeInfo(LParam.NameOfType), LParamIndex, true));
          end;
        LSoapReader := SoapSend(LSoapWriter, AGlue, GetSoapAction(AGlue.FIntf, LMethod));
        if FHasResponses then
          begin
          Assert(LSoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION +': SoapSend returned an invalid reader');
          try
            IdRequire((LSoapReader.MessageName = LMethod.ResponseMessageName) or (LSoapReader.MessageName = LMethod.RequestMessageName), ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_CLIENT_WRONG_MESSAGE+' "'+LMethod.ResponseMessageName+'" / "'+LSoapReader.MessageName+'"');
            for LParamIndex := 0 to LMethod.Parameters.Count - 1 do  // look for any var,out etc param types
              begin
              LParam := LMethod.Parameters.Param[LParamIndex];
              ProcessOutParams(nil,nil,LClientContext, LParamIndex, LParam, LSoapReader, true);
              end;
            if LMethod.ResultType <> '' then  // it was a function so get the result
              begin
              FResultParamName := LMethod.ReplaceName('result', ID_SOAP_NAME_RESULT);
              if (FResultParamName = ID_SOAP_NAME_RESULT) and (LSoapReader.FirstEntityName <> '') then
                // SOAP V1.1 - return value is the first one, and user has not specified otherwise
                begin
                FResultParamName := LSoapReader.FirstEntityName;
                end;
              LResultType := IdSoapGetTypeInfo(LMethod.ResultType);
              Result := ProcessResult(LResultType, LSoapReader, Params,LClientContext, LMethod);
              end;
            ProcessHeadersRecv(LMethod, LSoapReader, LClientContext);
          finally
            if LSoapReader.WantGarbageCollect then
              begin
              FGarbageContext.AttachObj(LSoapReader);
              end
            else
              begin
              FreeAndNil(LSoapReader);
              end;
          end;
          end
        else
          begin
          Assert(not assigned(LSoapReader), ASSERT_LOCATION +': SoapSend returned a reader in One Way Mode');
          end;
      finally
        FreeAndNil(LClientContext);
        end;
    finally
      FreeAndNil(LSoapWriter);
      FSendHeaders.DeleteAll(false);
    end;
    end;
end;

function TIdSoapBaseSender.GetSoapAction(AInterface : TIdSoapITIInterface; AMethod : TIdSoapITIMethod):string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.GetSoapAction';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  if AMethod.SoapAction <> '' then
    begin
    result := AMethod.SoapAction;
    end
  else if AInterface.Namespace <> '' then
    begin
    result := AInterface.Namespace+'#';
    end
  else
    begin
    result := DefaultNamespace+'#';
    end;
  if (result <> '') and (result[length(result)] = '#') then
    begin
    result := result + AMethod.Name;
    end;
end;

function TIdSoapBaseSender.CreateWriter : TIdSoapWriter;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.CreateWriter';
var
  LEncodingType : TIdSoapEncodingType;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': Self is not valid');
  LEncodingType := EncodingType;
  if LEncodingType = etIdAutomatic then
    begin
    LEncodingType := GetTransportDefaultEncodingType;
    end;
  case LEncodingType of
    etIdAutomatic :
      begin
      raise EIdSoapRequirementFail.create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_CLIENT_UNKNOWN_ENCODING_TYPE);
      end;
    etIdBinary:
      begin
      result := TIdSoapWriterBin.create(FSoapVersion, XMLProvider);
      end;
    etIdXmlUtf8 :
      begin
      result := TIdSoapWriterXML.create(FSoapVersion, XMLProvider);
      (result as TIdSoapWriterXML).UseUTF16 := false;
      end;
    etIdXmlUtf16 :
      begin
      result := TIdSoapWriterXML.create(FSoapVersion, XMLProvider);
      (result as TIdSoapWriterXML).UseUTF16 := true;
      end;
  else
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_CLIENT_UNKNOWN_ENCODING_TYPE);
  end;
  result.EncodingOptions := EncodingOptions;
  result.SchemaInstanceNamespace := ID_SOAP_NS_SCHEMA_INST_2001;
  result.SchemaNamespace := ID_SOAP_NS_SCHEMA_2001;
end;

procedure TIdSoapBaseSender.DoSoapRequest(ASoapAction, ARequestMimeType: String; ARequest, AResponse: TStream; Var VResponseMimeType : string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.DoSoapRequest';
begin
  raise EIdSoapRequirementFail.Create(ASSERT_LOCATION+'["'+Name+'"]: This object of type "'+ClassName+'" does not provide Request/Response Transport');
end;

procedure TIdSoapBaseSender.DoSoapSend(ASoapAction, AMimeType: String; ARequest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.DoSoapSend';
begin
  raise EIdSoapRequirementFail.Create(ASSERT_LOCATION+'["'+Name+'"]: This object of type "'+ClassName+'" does not provide Message Sending Transport');
end;

function TIdSoapBaseSender.GetTransportDefaultEncodingType: TIdSoapEncodingType;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.GetTransportDefaultEncodingType';
begin
  raise EIdSoapRequirementFail.Create(ASSERT_LOCATION+'["'+Name+'"]: You cannot use a TIdSoapBaseSender directly, you need to use a descendent that provides transport services');
end;

procedure TIdSoapBaseSender.Start;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.Start';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  inherited;
  FGlueList := TIdSoapGlueList.Create;
  FGlueList.FSender := Self;
  FGlueList._AddRef;   // make sure we keep it till were done
  Assert(gIdSoapInterfaceManager.TestValid(TIdSoapInterfaceManager), ASSERT_LOCATION+': self is not valid');
  gIdSoapInterfaceManager.InitializeInterfaceStubs(ITI);
end;

procedure TIdSoapBaseSender.Stop;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.Stop';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  AbandonInterfaces;
  inherited;
end;

procedure TIdSoapBaseSender.AbandonInterfaces;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.AbandonInterfaces';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  if assigned(FGlueList) then
    begin
    Assert(FGlueList.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': self is not valid');
    FGlueList.FSender := nil;
    // the FGlueList is a ref counted interface so dont free it. It will free itself
    FGlueList._Release;
    FGlueList := nil;
    end;
end;

procedure TIdSoapBaseSender.ListAllInterfaceNames (AList : TStrings);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.AbandonInterfaces';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  Assert(assigned(AList), ASSERT_LOCATION+': List is not valid');
  IdRequire(Active, ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_CLIENT_NOT_ACTIVE);
  Assert(ITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  AList.Assign(ITI.Interfaces);
end;

procedure TIdSoapBaseSender.GetWSDL(AInterfaceName : string; AStream : TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.GetWSDL';
var
  LWsdl : TIdSoapWSDL;
  LNamespace : string;
  LWsdlConvertor : TIdSoapWSDLConvertor;
  LITIDescriber : TIdSoapITIDescriber;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  Assert(AInterfaceName <> '', ASSERT_LOCATION+': Interface Name not provided');
  Assert(assigned(AStream), ASSERT_LOCATION+': List is not valid');
  IdRequire(Active, ASSERT_LOCATION+'["'+Name+'"]: '+RS_ERR_CLIENT_NOT_ACTIVE);
  Assert(ITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  IdRequire(ITI.Interfaces.IndexOf(AInterfaceName) > -1, ASSERT_LOCATION+': Interface "'+AInterfaceName+'" not known');
  LNamespace := (ITI.Interfaces.Objects[ITI.Interfaces.IndexOf(AInterfaceName)] as TIdSoapITIInterface).Namespace;
  if LNamespace = '' then
    begin
    LNamespace := DefaultNamespace;
    end;
  LWsdl := TIdSoapWSDL.create(LNamespace);
  try
    LITIDescriber := TIdSoapITIDescriber.create(LWsdl, Self);
    try
      LITIDescriber.Describe(ITI.Interfaces.Objects[ITI.Interfaces.IndexOf(AInterfaceName)] as TIdSoapITIInterface, GetWSDLLocation);
    finally
      FreeAndNil(LITIDescriber);
    end;
    LWsdlConvertor := TIdSoapWSDLConvertor.create(self, LWsdl);
    try
      LWsdlConvertor.WriteToXml(AStream);
    finally
      FreeAndNil(LWsdlConvertor);
    end;
  finally
    FreeAndNil(LWsdl);
  end;
  AStream.position := 0;
end;

procedure TIdSoapBaseSender.CreateSession(AIdentity : string; ASession : TObject; ACallEvent : boolean = true);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.CreateSession';
var
  LGUID : TGUID;
  LStr : TIdSoapString;
  LHeader : TIdSoapHeader;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  Assert(SessionSettings.SessionPolicy <> sspNoSessions, ASSERT_LOCATION+': create session but sessions are not supported');

  // things to do
  if assigned(FSession) then
    begin
    CloseSession();
    end;
  if AIdentity = '' then
    begin
    {$IFDEF LINUX}
    CreateGUID(LGUID);
    {$ELSE}
    CoCreateGuid(LGUID);
    {$ENDIF}
    AIdentity := GUIDToString(LGuid);
    end;
  inc(FLastSessionID);
  FSession := TIdSoapClientSession.create;
  FSession.FId := FLastSessionID;
  FSession.FIdentity := AIdentity;
  FSession.FAppSession := ASession;
  if assigned(FSession.FAppSession) and (FSession.FAppSession is TIdSoapBaseApplicationSession) then
    begin
    (FSession.FAppSession as TIdSoapBaseApplicationSession).Identity := FSession.FIdentity;
    end;
  if ACallEvent and assigned(OnCreateSession) then
    begin
    OnCreateSession(Self, FSession.FIdentity, FSession.FAppSession);
    end;
  if SessionSettings.SessionPolicy = sspCookies then
    begin
    FAddingCookie := true;
    try
      SetCookie(SessionSettings.SessionName, FSession.FIdentity);
    finally
      FAddingCookie := false;
    end;
    end
  else
    begin
    LStr := TIdSoapString.create;
    LStr.Value := FSession.FIdentity;
    LHeader := TIdSoapHeader.CreateWithQName(ID_SOAP_DS_DEFAULT_ROOT, SessionSettings.SessionName, LStr);
    LHeader.Persistent := true;
    LHeader.MustUnderstand := true;
    LHeader.MustSend := true;
    FSendHeaders.AddHeader(LHeader);
    end;
end;

procedure TIdSoapBaseSender.CloseSession(AIdentity : string = ''; ACallEvent : boolean = true);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.CloseSession';
begin
  Assert(self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  
  if assigned(FSession) then
    begin
    Assert((AIdentity = '') or (FSession.FIdentity = AIdentity), ASSERT_LOCATION+' Session Names do not match "'+FSession.FIdentity+'"/"'+AIdentity+'"');
    if ACallEvent and assigned(OnCloseSession) then
      begin
      OnCloseSession(self, FSession.FIdentity, FSession.FAppSession);
      end;
    if SessionSettings.SessionPolicy = sspCookies then
      begin
      ClearCookie(SessionSettings.SessionName);
      end
    else
      begin
      FSendHeaders.delete(FSendHeaders.IndexOfQName[ID_SOAP_DS_DEFAULT_ROOT, SessionSettings.SessionName]);
      end;
    FreeAndNil(FSession);
    end;
end;

function TIdSoapBaseSender.GetAppSession : TObject;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.CloseSession';
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  if assigned(FSession) then
    begin
    result := FSession.FAppSession;
    end
  else
    begin
    result := nil;
    end;
end;

procedure TIdSoapBaseSender.CheckForSessionInfo(AReader : TIdSoapReader);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.CheckForSessionInfo';
var
  s : string;
  LHeader : TIdSoapHeader;
begin
  Assert(Self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  Assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': reader is not valid');
  case SessionSettings.SessionPolicy of
    sspNoSessions : ; // do nothing
    sspSoapHeaders :
      begin
      if SessionSettings.AutoAcceptSessions and (AReader.Headers.IndexOfQName[ID_SOAP_DS_DEFAULT_ROOT, SessionSettings.SessionName] <> -1) then
        begin
        LHeader := AReader.Headers.Header[AReader.Headers.IndexOfQName[ID_SOAP_DS_DEFAULT_ROOT, SessionSettings.SessionName]];
        s := (LHeader.Content as TIdSoapString).Value;
        if s = '' then
          begin
          CloseSession();
          end
        else
          begin
          // we consider (for the moment) that the server only sends us a header when we are to change.
          // this will renew the session whether the name is the same or not
          CreateSession(s, nil);
          end;
        end;
      end;
    sspCookies :
      begin
      // this is handled elsewhere
      end;
  else
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': illegal value for SessionSettings.SessionPolicy');
  end;
end;

procedure TIdSoapBaseSender.ProcessHeadersSend(AMethod : TIdSoapITIMethod; ASoapWriter : TIdSoapWriter; ASenderContext : TIdSoapSenderContext);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessHeadersSend';
var
  i, j : integer;
  LHeaderParam : TIdSoapITIParameter;
  LHeader : TIdSoapHeader;
  AData : pointer;
begin
  Assert(self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': AMethod is not valid');
  Assert(ASoapWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': ASoapWriter is not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+': ASenderContext is not valid');

  for i := 0 to AMethod.Headers.count - 1 do
    begin
    LHeaderParam := AMethod.Headers.Param[i];
    j := FSendHeaders.IndexOfName[LHeaderParam.Name];
    if j > -1 then
      begin
      LHeader := FSendHeaders.Header[j];
      LHeader.Node.Free; // parameters are recoded each time they are sent
      LHeader.Node := TIdSoapNode.Create(ID_SOAP_NULL_NODE_NAME, ID_SOAP_NULL_NODE_TYPE, '', False, NIL, ASoapWriter);
      ASoapWriter.StructNodeAdded(LHeader.Node);
      AData := LHeader.Content;
      ProcessParameter(LHeader.Node, LHeaderParam.Name, ASenderContext, ASoapWriter, AData, LHeaderParam, LHeaderParam.TypeInformation, 0, true);
      end;
    end;
  ASoapWriter.UseSoapHeaders(FSendHeaders);
end;

procedure TIdSoapBaseSender.ProcessHeadersRecv(AMethod : TIdSoapITIMethod; ASoapReader : TIdSoapReader; ASenderContext : TIdSoapSenderContext);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseSender.ProcessHeadersRecv';
var
  i, j : integer;
  LHeaderParam : TIdSoapITIParameter;
  LHeader : TIdSoapHeader;
  AData : pointer;
  LClass : TIdBaseSoapableClass;
begin
  Assert(self.TestValid(TIdSoapBaseSender), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': AMethod is not valid');
  Assert(ASoapReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': ASoapWriter is not valid');
  Assert(ASenderContext.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+': ASenderContext is not valid');

  for i := 0 to AMethod.RespHeaders.count - 1 do
    begin
    LHeaderParam := AMethod.RespHeaders.Param[i];
    j := ASoapReader.Headers.IndexOfQName[ASoapReader.MessageNameSpace, AMethod.ReplaceName(LHeaderParam.Name)];
    if j > -1 then
      begin
      LHeader := ASoapReader.Headers.Header[j];
      LHeader.PascalName := LHeaderParam.Name;
      LHeader.Processed := true;
      if assigned(LHeader.Node) then
        begin
        LClass := nil;
        AData := @LClass;
        ProcessOutParams(LHeader.Node, AData, ASenderContext, -1, LHeaderParam, ASoapReader, true);
        if assigned(LClass) then
          begin
          LHeader.Content.Free;
          LHeader.Content := LClass;
          end;
        end;
      end;
    end;
  ASoapReader.CheckMustUnderstand;
  FRecvHeaders.TakeHeaders(ASoapReader.Headers);
end;

{ TIdSoapSenderContext }

function TIdSoapSenderContext.GetParamPtr(AIndex: Integer): Pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.GetParamPtr';
begin
  Assert(Self.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+': Self is not valid');
  Assert((AIndex >= 0) and (AIndex < Length(FParamPtr)), ASSERT_LOCATION+': Index out of bounds for FParamPtr');
  Result := FParamPtr[AIndex];
end;

procedure TIdSoapSenderContext.SetParamPtr(AIndex: Integer; APointer: Pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.SetParamPtr';
begin
  Assert(Self.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+': Self is not valid');
  Assert(AIndex >= 0, ASSERT_LOCATION+': Index out of bounds for FParamPtr');
  if AIndex >= Length(FParamPtr) then  // need to grow the array
    SetLength(FParamPtr, AIndex + 1);
  FParamPtr[AIndex] := APointer;
end;

procedure TIdSoapSenderContext.SetParamType(AIndex: Integer; ATypeInfo: PTypeInfo);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.SetParamType';
begin
  Assert(Self.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+': Self is not valid');
  Assert(AIndex >= 0, ASSERT_LOCATION+': Index out of bounds for FParamPtr');
  if AIndex >= Length(FParamType) then  // need to grow the array
    SetLength(FParamType, AIndex + 1);
  FParamType[AIndex] := ATypeInfo;
end;

function TIdSoapSenderContext.GetParamType(AIndex: Integer): PTypeInfo;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapSenderContext.GetParamType';
begin
  Assert(Self.TestValid(TIdSoapSenderContext), ASSERT_LOCATION+': Self is not valid');
  Assert((AIndex >= 0) and (AIndex < Length(FParamPtr)), ASSERT_LOCATION+': Index out of bounds for FParamType');
  Result := FParamType[AIndex];
end;

{ TIdSoapGlueList }

constructor TIdSoapGlueList.Create;
begin
  inherited;
  FGlueList := TList.Create;
end;

destructor TIdSoapGlueList.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapGlueList.Destroy';
begin
  Assert(self.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': Self is not valid');
  Assert(FGlueList.Count = 0, ASSERT_LOCATION+': There is glue left over');
  FGlueList.Free;
  inherited;
end;

function TIdSoapGlueList.Add(AGlue: TIdSoapInterfaceGlue): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapGlueList.Add';
begin
  Assert(self.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': Self is not valid');
  Assert(AGlue.TestValid(TIdSoapInterfaceGlue), ASSERT_LOCATION+': Glue is not valid');
  result := FGlueList.Add(AGlue);
  _AddRef;
end;

function TIdSoapGlueList.GetCount: Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapGlueList.GetCount';
begin
  Assert(self.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': Self is not valid');
  result := FGlueList.Count;
end;

function TIdSoapGlueList.GetGlue(AIndex: Integer): TIdSoapInterfaceGlue;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapGlueList.GetGlue';
begin
  Assert(self.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': Self is not valid');
  Assert((AIndex >= 0) and (AIndex < FGlueList.count), ASSERT_LOCATION+': Index Value ('+inttostr(AIndex)+') is out of range');
  result := TObject(FGlueList[AIndex]) as TIdSoapInterfaceGlue;
end;

function TIdSoapGlueList.QueryInterface(const IID: {$IFDEF DELPHI5} System. {$ENDIF} TGUID; out Obj): HResult;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapGlueList.QueryInterface';
begin
  Assert(self.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': Self is not valid');
  if FSender = nil then
    result := E_NOINTERFACE
  else
    result := FSender.QueryInterface(IID,Obj);
end;

function TIdSoapGlueList._AddRef: Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapGlueList._AddRef';
begin
  Assert(self.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': Self is not valid');
  result := IndyInterlockedIncrement(FRefCount);
end;

function TIdSoapGlueList._Release: Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapGlueList._Release';
begin
  Assert(self.TestValid(TIdSoapGlueList), ASSERT_LOCATION+': Self is not valid');
  result := IndyInterlockedDecrement(FRefCount);
  if result = 0 then
    Free;
end;

{ TIdSoapBaseClient }

constructor TIdSoapBaseClient.Create(AOwner: TComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseClient.Create';
begin
  inherited;
  FHasResponses := true;
end;

{ TIdSoapBaseMsgSender }

constructor TIdSoapBaseMsgSender.Create(AOwner: TComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseMsgSender.Create';
begin
  inherited;
  FHasResponses := false;
end;

function TIdSoapBaseMsgSender.GetTransportDefaultEncodingType: TIdSoapEncodingType;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseMsgSender.GetTransportDefaultEncodingType';
begin
  Assert(Self.TestValid(TIdSoapBaseMsgSender), ASSERT_LOCATION+': self is not valid');
  result := etIdXmlUtf8;
end;

function TIdSoapBaseMsgSender.GetSubject : string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBaseMsgSender.GetSubject';
begin
  Assert(self.TestValid(TIdSoapBaseMsgSender), ASSERT_LOCATION+': self is not valid');

  if FMessageSubject <> '' then
    begin
    result := FMessageSubject;
    end
  else
    begin
    result := 'Soap Message';
    end;
end;

{ TIdSoapWebClient }

constructor TIdSoapWebClient.create(AOwner : TComponent);
begin
  inherited;
  FSoapURL := ID_SOAP_DEFAULT_SOAP_PATH; // just to provide a hint. User MUST change this
end;

procedure TIdSoapWebClient.SetSoapURL(const AValue: string);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWebClient.SetSoapURL';
begin
  Assert(self.TestValid(TIdSoapWebClient), ASSERT_LOCATION+': self is not valid');
  FSoapURL := AValue;
end;


initialization
  gIdGlobalLock := TIdCriticalSection.Create;
  gIdSoapBufferManager := TIdSoapBufferManager.Create;
  gIdSoapInterfaceManager := TIdSoapInterfaceManager.Create;
  gIdSoapInterfaceManager.FSoapCommonEntryPtr := @TIdSoapInterfaceGlue.SoapCommonEntryStub;
finalization
  FreeAndNil(gIdSoapInterfaceManager);
  FreeAndNil(gIdSoapBufferManager);
  FreeAndNil(gIdGlobalLock);
end.





