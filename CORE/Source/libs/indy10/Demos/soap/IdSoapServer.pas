{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15772: IdSoapServer.pas 
{
{   Rev 1.3    23/6/2003 21:28:54  GGrieve
{ fix for Linux EOL issues
}
{
{   Rev 1.2    20/6/2003 00:04:22  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:03:54  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:36:26  GGrieve
}
{
IndySOAP:Server Implementation

To use the server side, you need to create 2 objects, a TIdSoapListener,
and one (or more) Transport implementations. Refer to
IdSoapServerHTTP for more detail about the transport implementation

To use a SOAP Server, you need to:
* create a TIdSOAPServerHTTP or equivalent.
* set the transport layer settings appropriately
* Set the Transport Layer Soap Provider to a TIdSoapListener implementation
* Define where the TIdSoapListener ITI is loaded from
* Register factories for all the interfaces in the ITI in IdSoapIntfRegistry.pas
}

{
Version History:
  23-Jun 2003   Grahame Grieve                  fix for EOL on Linux
  19-Jun 2003   Grahame Grieve                  performance + support for sets, headers, polymorphism
  18-Mar 2003   Grahame Grieve                  Schema extensibility
  29-Oct 2002   Grahame Grieve                  Compile fixes, IdSoapSimpleClass support
  04-Oct 2002   Grahame Grieve                  Change MimeType handling, Change interface implementation lifetime management
  26-Sep 2002   Grahame Grieve                  Header & Sessional Support
  17-Sep 2002   Grahame Grieve                  remove hints
  09-Sep 2002   Andrew Cumming                  Fixed leak in special types 
  05-Sep 2002   Grahame Grieve                  Set Writer.EncodingMode and fix field renaming
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Andrew Cumming                  Refactoring of ProcessParamClass primarily for Doc|Lit
  23-Aug 2002   Grahame Grieve                  Doc|Lit issues fixed
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition  (+ fix major crash in class parameter handling)
  06-Aug 2002   Grahame Grieve                  Introduce TIdSoapListener for one Way support
  24-Jul 2002   Grahame Grieve                  Change Namespace Policy, WSDL generation fixes
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance
  18-Jul 2002   Grahame Grieve                  Better control over Mime Types
  11-Jul 2002   Andrew Cumming                  Fixed up incorrect implementation of dynamic arrays virtual/static methods
  29-May 2002   Grahame Grieve                  Fix problem with out dynamic arrays that are properties
  29-May 2002   Grahame Grieve                  Add ListServerCalls, comments in security section
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing compiler warnings
  14-Apr 2002   Andrew Cumming                  Added code for Linux PIC compatibility
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Andrew Cumming                  Change to WSDL model
  09-Apr 2002   Andrew Cumming                  Fixed bugs with nil classes and empty arrays
  08-Apr 2002   Grahame Grieve                  Change Server cleanup to manage reference counting across objects
  08-Apr 2002   Grahame Grieve                  Fixes for Objects by Reference
  08-Apr 2002   Grahame Grieve                  Support for Objects by Reference
  07-Apr 2002   Andrew Cumming                  Fixed GP in erroneous double free of dynamic array OUT params
  05-Apr 2002   Andrew Cumming                  Fixed bug in array frees for OUT and result type params
  05-Apr 2002   Andrew Cumming                  Implemented special type handling
  05-Apr 2002   Grahame Grieve                  Work on Object lifetime management - incomplete
  05-Apr 2002   Grahame Grieve                  Fix MimeType - should be var paremeter
  05-Apr 2002   Andrew Cumming                  Fixed up array of class node bug
  05-Apr 2002   Andrew Cumming                  Added ID_SOAP_SHOW_NODES define for visualising nodes (for debugging ONLY)
  04-Apr 2002   Grahame Grieve                  Change to the way Mime and SoapAction is handled
  03-Apr 2002   Grahame Grieve                  Handle ITI Method Request and Response Names
  03-Apr 2002   Grahame Grieve                  Change to Packet writer interface - no difference between request and response
  29-Mar 2002   Grahame Grieve                  Start fixing server leaks
  27-Mar 2002   Andrew Cumming                  Fixed serious bug in arrays
  27-Mar 2002   Grahame Grieve                  Fix potential leaks
  26-Mar 2002   Grahame Grieve                  remodel array handling
  26-Mar 2002   Andrew Cumming                  large rework on server code to simplify functions
  22-Mar 2002   Grahame Grieve                  WSDL Location Support
  22-Mar 2002   Grahame Grieve                  Fix WSDL prefix handling
  22-Mar 2002   Grahame Grieve                  Change Node handling to differentiate between arrays, elements, and structs
  21-Mar 2002   Andrew Cumming                  Removed need for LDelayedFree (and probably fixed some bugs too)
  20-Mar 2002   Andrew Cumming                  Found the GP at last. It was LDelayedFree being freed too early
  15-Mar 2002   Andrew Cumming                  Fixed arrays and classes
  14-Mar 2002   Grahame Grieve                  Support for TIdSoapRequestInformation
  14-Mar 2002   Grahame Grieve                  Fixed Widestring bug in Results, use the right encoding for Faults
  14-Mar 2002   Andrew Cumming                  Fixed Classes/Arrays in class properties problem
  14-Mar 2002   Andrew Cumming                  Fixed boolean bug
  14-Mar 2002   Grahame Grieve                  Namespace support
  12-Mar 2002   Grahame Grieve                  Binary support (TStream)
   8-Mar 2002   Andrew Cumming                  Fixed boolean/enumeration bug
   7-Mar 2002   Grahame Grieve                  Review assertions, add support for encoding type
   3-Mar 2002   Andrew Cumming                  Added support for SETs
   1-Mar 2002   Andrew Cumming                  Removed bug in polymorphic section
   1-Mar 2002   Andrew Cumming                  Added code for polymorphic classes
   1-Mar 2002   Andrew Cumming                  Fixed bug in dynamic array freeing, added class result type
  28-Feb 2002   Andrew Cumming                  Made D4 compatible
  28-Feb 2002   Andrew Cumming                  First version of classes completed
  24-Feb 2002   Andrew Cumming                  Even more changes for dynamic arrays (nearly done)
  22-Feb 2002   Andrew Cumming                  Many changes for dynamic arrays
  19-Feb 2002   Andrew Cumming                  Added dynamic array capabilities to all simple types (one way only)
  18-Feb 2002   Andrew Cumming                  many additions for dynamic arrays
  11-Feb 2002   Andrew Cumming                  more fixes for changes to Packet handling layer
   7-Feb 2002   Grahame Grieve                  fix updates for changes to Packet handling layer (more to come yet)
   7-Feb 2002   Grahame Grieve                  updates for changes to Packet handling layer (more to come yet)
   5-Feb 2002   Andrew Cumming                  D4 updates
   5-Feb 2002   Grahame Grieve                  update for changes in RpcXml
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release
}

unit IdSoapServer;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapComponent,
  IdSoapConsts,
  IdSoapCSHelpers,
  IdSoapDebug,
  IdSoapDynamicAsm,
  IdSoapIntfRegistry,
  IdSoapITI,
  IdSoapITIProvider,
  IdSoapRequestInfo,
  IdSoapRpcPacket,
  IdSoapRTTIHelpers,
  IdSoapUtilities,
  SysUtils,
  TypInfo;

type
  PObject = ^TObject;

  PIdSoapStringRec = ^TIdSoapStringRec;
  TIdSoapStringRec = record
    FStr: PString;
    FTarget: Pointer;
  end;

  PIdSoapWideStringRec = ^TIdSoapWideStringRec;
  TIdSoapWideStringRec = record
    FStr: PWideString;
    FTarget: Pointer;
  end;

  PIdSoapFinalizeArray = ^TIdSoapFinalizeArray;
  TIdSoapFinalizeArray = record
    FArray: ^Pointer;          // MUST be ptr to ptr as the actual array memory can move
    FWantClean : boolean;
    FArrayTypeInfo: PTypeInfo;
    end;

  TIdSoapServerRequestContext = class(TIdBaseObject)
  Private
    // dont use dynamic arrays for caching as they tend to move around when you resize them
    FClassDepth: Integer;           // used to track classes/array in a class (finalization issue resolution)
    FStringCache: array [1..ID_SOAP_MAX_STRING_PARAMS] of TIdSoapStringRec;
    FStringCacheIndex: Integer;
    FWideStringCache: array [1..ID_SOAP_MAX_STRING_PARAMS] of TIdSoapWideStringRec;
    FWideStringCacheIndex: Integer;
    FMemoryCache: array of String;      // this way the memory is automatically managed
    FMemoryCacheIndex: Integer;
    FParamPtr: array of Pointer;       // used for var, out etc params (ones passed as pointers)
    FResultPtr: Pointer;              // used by some string coding
    FFinalizeArrays : Array of TIdSoapFinalizeArray;
    FObjectsToDispose: Array of PObject;
    function GetParamPtr(AIndex: Integer): Pointer;
    procedure SetParamPtr(AIndex: Integer; APtr: Pointer);
  Public
    constructor Create;
    destructor Destroy; Override;
    function  GetTempString: PString;
    function  GetTempWideString: PWideString;
    function  GetTempMemory(ASize: Integer): Pointer;
    procedure AddArrayFinalize(AArray: Pointer; AArrayTypeInfo: PTypeInfo; AWantClean : boolean);
    procedure AddObjectToDispose(AObject: PObject);
    property ParamPtr[AIndex: Integer]: Pointer Read GetParamPtr Write SetParamPtr;
    property ResultPtr: Pointer Read FResultPtr Write FResultPtr;
    property ClassDepth: Integer read FClassDepth write FClassDepth;
  end;

  // not for use outside this unit
  TIdSoapServerSession = class (TIdBaseObject)
  private
    FAppSession : TObject;
    FUseCount : integer;
    FIdentity : string;
    FClosed : boolean;
    FWantCallCloseEvent : boolean;
  public
    constructor create;
  end;

  TIdSoapListener = class(TIdSoapITIProvider)
  Private
    FSoapVersions : TIdSoapVersionSet;
    FSessionLock: TIdCriticalSection;
    FSessionList: TStringList;
    function  ProcessParameter(ABaseNode: TIdSoapNode; AParamName : string; var AData; ATypeInfo: PTypeInfo; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; AParam: TIdSoapITIParameter; AServerContext: TIdSoapServerRequestContext; AParamIndex: Integer; AIsParameter : boolean): Integer;
    function  ProcessParamInteger(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
    function  ProcessParamSet(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; ATypeInfo : PTypeInfo; Var AData): Integer;
    function  ProcessParamFloat(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
    function  ProcessParamEnum(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData; AParamType: PTypeInfo): Integer;
    function  ProcessParamDynArray(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData; ATypeInfo: PTypeInfo): Integer;
    function  ProcessParamClass(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData; AParamType: PTypeInfo): Integer;
    function  ProcessParamShortString(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
    function  ProcessParamLongString(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
    function  ProcessParamWideString(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
    function  ProcessParamChar(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
    function  ProcessParamWideChar(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;

    function  ProcessStackBasedResult(AServerContext: TIdSoapServerRequestContext; AAsm: TIdSoapDynamicAsm; AResultType: PTypeInfo): Integer;
    procedure ProcessResult(AServerContext: TIdSoapServerRequestContext; AWriter: TIdSoapWriter; AResultType: PTypeInfo; AMethod: TIdSoapITIMethod; AAns: Int64);
    procedure ProcessResultFloat(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter);
    procedure ProcessResultEnum(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter; var AAns; AResultType: PTypeInfo; AMethod: TIdSoapITIMethod);
    procedure ProcessResultSet(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter; AParamType : PTypeInfo; AMethod: TIdSoapITIMethod; var AAns);
    procedure ProcessResultDynArray(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter; var AAns; AResultType: PTypeInfo; AServerContext: TIdSoapServerRequestContext; AMethod: TIdSoapITIMethod);
    procedure ProcessResultClass(ABasicType: TIdSoapBasicType; AName : string; AMethod : TIdSoapITIMethod; AWriter: TIdSoapWriter; var AAns; AResultType: PTypeInfo; AServerContext: TIdSoapServerRequestContext);
    procedure ProcessOutParam(AData: Pointer; ARootNode: TIdSoapNode; AEntryName: String; AWriter: TIdSoapWriter; AParam: TIdSoapITIParameter; AServerContext: TIdSoapServerRequestContext; AParamIndex: Integer; AIsParameter : boolean; ADefault : integer = MININT);
    procedure ProcessOutParamEnum(AWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParam : TIdSoapITIParameter; AParamName: String; Var AData; AParamType: PTypeInfo; ADefault : Integer);
    procedure ProcessOutParamSet(AWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParam : TIdSoapITIParameter; AParamName: String; Var AData; AParamType: PTypeInfo);

    procedure ProcessOutParamDynArray(AWriter: TIdSoapWriter; AServerContext: TIdSoapServerRequestContext; ARootNode: TIdSoapNode; AParam: TIdSoapITIParameter; Var AData; AParamIndex: Integer);
    procedure ProcessOutParamClass(AWriter: TIdSoapWriter; AServerContext: TIdSoapServerRequestContext; ARootNode: TIdSoapNode; AParam: TIdSoapITIParameter; Var AData);
    procedure ProcessOutParamClassInner(AWriter: TIdSoapWriter; AServerContext: TIdSoapServerRequestContext; ARootNode: TIdSoapNode; AParam: TIdSoapITIParameter; ANamespace, AName : string; ATypeInfo : PTypeInfo; APropMan: TIdSoapPropertyManager; AClass : TObject; AFakeParam: TIdSoapITIParameter);

    procedure ProcessHeadersRecv(AMethod : TIdSoapITIMethod; AReader : TIdSoapReader; AServerContext : TIdSoapServerRequestContext);
    procedure ProcessHeadersSend(AMethod : TIdSoapITIMethod; AWriter : TIdSoapWriter; AServerContext : TIdSoapServerRequestContext);
    function  CheckForSession(AReader: TIdSoapReader; ACookieServices : TIdSoapAbstractCookieIntf):TIdSoapServerSession;
    procedure ReleaseSession(ASession : TIdSoapServerSession);
    procedure ExecuteSoapCall(AReader: TIdSoapReader; ACookieServices : TIdSoapAbstractCookieIntf; AWriter: TIdSoapWriter);
    function CreateWriter(AReader : TIdSoapReader; var VEncodingTypeUsed : TIdSoapEncodingType) : TIdSoapWriter;
    function CreateFaultWriter(AEncodingType : TIdSoapEncodingType) : TIdSoapFaultWriter;
    function ListInterfaces(AITI: TIdSoapITI; APrefix: string): string;
    procedure SetSoapVersion(const AValue: TIdSoapVersionSet);
    function GetWorkingSoapVersion : TIdSoapVersion;
  protected
    Procedure Start; override;
  Public
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;

    procedure GenerateWSDLPage(APrefix, AParam, ALocation: String; AResponse: TStream; Var VContentType : string);

    // this will populate the given string list with a list of the RPC procedure names and their namespaces
    // that this SOAP Server will service. This is included since you have to get this right, and wsdl's
    // require a trained eye to read. The list will be in the format "namespace", "name"
    procedure ListValidCalls(AList : TStrings);

    procedure CreateSession(ARequestInfo : TIdSoapRequestInformation; AIdentity : string; ASession : TObject; ACallEvent : boolean = true);
    property SessionList : TStringList read FSessionList;
    property SessionLock : TIdCriticalSection read FSessionLock;
    procedure CloseSession(AIdentity : string; ACallevent : boolean = true);
 published
    // it's intended that the server may be able to support multiple soap versions
    property SoapVersions : TIdSoapVersionSet read FSoapVersions write SetSoapVersion;
  end;

  TIdSoapServer = class(TIdSoapListener)
  public
    // this is a function so that the transport layer knows whether we are returning an
    // fault or not (it might need to code the transport headers differently)
    function HandleSoapRequest(AInMimeType: String; ACookieServices : TIdSoapAbstractCookieIntf; ARequest, AResponse: TStream; var VOutMimeType : string): Boolean;
  end;

  TIdSoapExceptionEvent = procedure (ASender : TObject; AException : Exception) of object;

  TIdSoapMsgReceiver = class(TIdSoapListener)
  private
    FOnException : TIdSoapExceptionEvent;
  public
    procedure HandleSoapMessage(AInMimeType: String; ARequest: TStream);
  published
    property OnException : TIdSoapExceptionEvent read FOnException write FOnException;
  end;

implementation

uses
{$IFNDEF LINUX}
  ActiveX,
{$ENDIF}
{$IFDEF DELPHI4OR5}
  ComObj,
{$ENDIF}
{$IFDEF ID_SOAP_SHOW_NODES}
  IdSoapViewer,
{$ENDIF}
  IdSoapTypeRegistry,
  IdSoapExceptions,
  IdSoapResourceStrings,
  IdSoapRpcXml,
  IdSoapRpcBin,
  IdSoapRpcUtils,
  IdSoapTypeUtils,
  IdSoapWsdl,
  IdSoapWsdlIti,
  IdSoapWsdlXml,
  IdSoapXML;

const
  ASSERT_UNIT = 'IdSoapServer';

threadvar
  GReferenceCountingSession : integer;

{ TIdSoapServerRequestContext }

constructor TIdSoapServerRequestContext.Create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.Create';
begin
  inherited;
  FClassDepth := 0;
  FStringCacheIndex := 0;
  FWideStringCacheIndex := 0;
end;

destructor TIdSoapServerRequestContext.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.Destroy';
var
  LInt: Integer;
  LArray: PIdSoapFinalizeArray;
  LOk : boolean;
  LMsg : string;
  LObj : TIdBaseSoapableClass;
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  // free AnsiString cache
  for LInt := 1 to FStringCacheIndex do
    begin
    Finalize(FStringCache[LInt].FStr^);
    end;
  // free WideString cache
  for LInt := 1 to FWideStringCacheIndex do
    begin
    Finalize(FWideStringCache[LInt].FStr^);
    end;
  // manual reference count prior to freeing
  inc(GReferenceCountingSession);
  for LInt:=0 to length(FFinalizeArrays)-1 do
    begin
    LArray := @FFinalizeArrays[LInt];
    if (LArray^.FWantClean) then
      begin
      LOK := IdSoapRefCountArrayObjects(LArray^.FArray^, LArray^.FArrayTypeInfo, True, GReferenceCountingSession, LMsg);
      Assert(LOk, ASSERT_LOCATION+': Array '+inttostr(LInt)+' failed Validation - '+LMsg)
      end;
    end;
  for LInt:=0 to length(FObjectsToDispose)-1 do
    begin
    if (FObjectsToDispose[LInt]^) is TIdBaseSoapableClass then
      begin
      LObj := FObjectsToDispose[LInt]^ as TIdBaseSoapableClass;
      if (not LObj.ServerLeaveAlive) and (LObj.OwnsObjects) then
        begin
        LOk := (FObjectsToDispose[LInt]^ as TIdBaseSoapableClass).ValidateTree(GReferenceCountingSession, LMsg);
        Assert(LOk, ASSERT_LOCATION+': Object '+inttostr(LInt)+' failed Validation - '+LMsg)
        end;
      end;
    end;
  // finalize arrays
  for LInt:=0 to length(FFinalizeArrays)-1 do
    begin
    LArray := @FFinalizeArrays[LInt];
    if (LArray^.FWantClean) then
      begin
      IdSoapFreeArrayClasses(LArray^.FArray^, LArray^.FArrayTypeInfo, True);
      end;
    IdSoapDynArrayClear(LArray^.FArray^,LArray^.FArrayTypeInfo);
    end;
  // free objects
  for LInt:=0 to length(FObjectsToDispose)-1 do
    begin
    if (FObjectsToDispose[LInt]^) is TIdBaseSoapableClass then
      begin
      if not ((FObjectsToDispose[LInt]^) as TIdBaseSoapableClass ).ServerLeaveAlive then
        begin
        (FObjectsToDispose[LInt]^ as TIdBaseSoapableClass).Dereference;
        end;
      end
    else
      begin
      FreeAndNil(FObjectsToDispose[LInt]^);
      end;
    end;
  inherited;
end;

function TIdSoapServerRequestContext.GetTempString: PString;
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.GetTempString:';
var
  LRec: PIdSoapStringRec;
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  inc(FStringCacheIndex);
  Assert(FStringCacheIndex <= ID_SOAP_MAX_STRING_PARAMS, ASSERT_LOCATION+': To many ANSISTRING parameters in method');
  LRec := @FStringCache[FStringCacheIndex];
  LRec^.FTarget := NIL;
  LRec^.FStr := @LRec^.FTarget;
  Initialize(LRec^.FStr^);
  Result := LRec^.FStr;
end;

function TIdSoapServerRequestContext.GetTempWideString: PWideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.GetTempWideString:';
var
  LRec: PIdSoapWideStringRec;
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  inc(FWideStringCacheIndex);
  Assert(FWideStringCacheIndex <= ID_SOAP_MAX_STRING_PARAMS, ASSERT_LOCATION+': To many WIDESTRING parameters in method');
  LRec := @FWideStringCache[FWideStringCacheIndex];
  LRec^.FTarget := NIL;
  LRec^.FStr := @LRec^.FTarget;
  Initialize(LRec^.FStr^);
  Result := LRec^.FStr;
end;

function TIdSoapServerRequestContext.GetParamPtr(AIndex: Integer): Pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.GetParamPtr';
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  Assert((AIndex >= 0) and (AIndex < Length(FParamPtr)), ASSERT_LOCATION+': Index out of bounds for FParamPtr');
  Result := FParamPtr[AIndex];
end;

procedure TIdSoapServerRequestContext.SetParamPtr(AIndex: Integer; APtr: Pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.SetParamPtr';
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  Assert(AIndex >= 0, ASSERT_LOCATION+': Index out of bounds for FParamPtr');
  if AIndex >= Length(FParamPtr) then  // need to grow the array
    SetLength(FParamPtr, AIndex + 1);
  FParamPtr[AIndex] := APtr;
end;

function TIdSoapServerRequestContext.GetTempMemory(ASize: Integer): Pointer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.GetTempMemory';
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  Assert(ASize > 0, ASSERT_LOCATION+': Size of memory allocation must be > 0');
  inc(FMemoryCacheIndex);
  SetLength(FMemoryCache, FMemoryCacheIndex);
  SetLength(FMemoryCache[FMemoryCacheIndex - 1], ASize);
  Result := @FMemoryCache[FMemoryCacheIndex - 1][1];
  FillChar(result^, ASize, #0);
end;

// AArray MUST be a ptr to a ptr of the array
procedure TIdSoapServerRequestContext.AddArrayFinalize(AArray: Pointer; AArrayTypeInfo: PTypeInfo; AWantClean : boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.AddArrayFinalize';
Var
  LInfo: PIdSoapFinalizeArray;
  LLen: Integer;
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  Assert(Assigned(AArrayTypeInfo),ASSERT_LOCATION+': Array type info missing');
  Assert(AArrayTypeInfo^.Kind = tkDynArray,ASSERT_LOCATION+': Dynamic array expected');
  if not Assigned(AArray) then
    exit;  // dont need to finalize a nil array
  LLen := length(FFinalizeArrays);
  SetLength(FFinalizeArrays,LLen+1);
  LInfo := @FFinalizeArrays[LLen];
  LInfo^.FArray := AArray;
  LInfo^.FArrayTypeInfo := AArrayTypeInfo;
  LInfo^.FWantClean := AWantClean;
end;

procedure TIdSoapServerRequestContext.AddObjectToDispose(AObject: PObject);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServerRequestContext.AddObjectToDispose';
Var
  LLen: Integer;
begin
  Assert(self.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': self not valid');
  if not Assigned(AObject) then
    exit;
  LLen := length(FObjectsToDispose);
  SetLength(FObjectsToDispose,LLen+1);
  FObjectsToDispose[LLen] := AObject;
end;

{ TIdSoapListener }

constructor TIdSoapListener.create(AOwner: TComponent);
begin
  inherited;
  FSoapVersions := [IdSoapV1_1];
  FSessionLock := TIdCriticalSection.create;
  FSessionList := TIdStringList.create(false);
  FSessionList.Sorted := True;
  FSessionList.Duplicates := dupError;
end;

destructor TIdSoapListener.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.destroy';
var
  i : integer;
  LSession : TIdSoapServerSession;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  for i := 0 to FSessionList.count -1 do
    begin
    if assigned(OnCloseSession) then
      begin
      LSession := FSessionList.Objects[i] as TIdSoapServerSession;
      OnCloseSession(self, LSession.FIdentity, LSession.FAppSession);
      end;
    FSessionList.Objects[i].free;
    end;
  FreeAndNil(FSessionList);
  FreeAndNil(FSessionLock);
  inherited;
end;

procedure TIdSoapListener.SetSoapVersion(const AValue: TIdSoapVersionSet);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.SetSoapVersion';
var
  i : TIdSoapVersion;
  LCount : integer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(not Active, ASSERT_LOCATION+': Cannot change SOAP versions while active = true');

  // although the server is intended to support multiple SOAP versions at once,
  // for the moment, we can only support one
  LCount := 0;
  for i := Low(TIdSoapVersion) to High(TIdSoapVersion) do
    begin
    If TIdSoapVersion(i) in AValue then
      begin
      inc(LCount);
      end;
    end;
  Assert(LCount > 0, ASSERT_LOCATION+': you must define a SOAP Version to support');
  Assert(LCount = 1, ASSERT_LOCATION+': A server can currently only support one SOAP version');
  FSoapVersions := AValue;
end;

function TIdSoapListener.GetWorkingSoapVersion: TIdSoapVersion;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.GetWorkingSoapVersion';
var
  i : TIdSoapVersion;
  LFound : boolean;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  result := IdSoapV1_1;
  LFound := false;
  for i := Low(TIdSoapVersion) to High(TIdSoapVersion) do
    begin
    If TIdSoapVersion(i) in FSoapVersions then
      begin
      result := TIdSoapVersion(i);
      LFound := true;
      break;
      end;
    end;
  Assert(LFound, ASSERT_LOCATION+': no working SOAP version found');
end;


procedure TIdSoapListener.ListValidCalls(AList: TStrings);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ListValidCalls';
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(Assigned(AList), ASSERT_LOCATION+': List is not valid');
  ITI.ListServerCalls(AList);
end;

function TIdSoapListener.ListInterfaces(AITI : TIdSoapITI; APrefix:string):string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ListInterfaces';
var
  i : integer;
begin
  Assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  // no check on APrefix
  result := '';
  for i := 0 to AITI.Interfaces.Count - 1 do
    begin
    if IdSoapInterfaceRegistered(AITI.Interfaces[i]) then
      begin
      result := result + '<a href="'+APrefix+AITI.Interfaces[i]+'">'+AITI.Interfaces[i]+'</a> &nbsp;<font size="-1">'+(AITI.Interfaces.objects[i] as TIdSoapITIInterface).Documentation+'</font><br>'+EOL_PLATFORM;
      end;
    end;
  result :=   { do not localize }
    '<html>'+EOL_PLATFORM+
    '<head><title>WSDL Service List</title></head>'+EOL_PLATFORM+
    '<body>'+EOL_PLATFORM+
    result +EOL_PLATFORM+
    '<a href="'+APrefix+'all">All Interfaces</a> &nbsp;<font size="-1">All the interfaces in a single WSDL</font><br>'+EOL_PLATFORM+
    '<i>Service List generated by IndySoap</i>'+EOL_PLATFORM+
    '</body></html>'+EOL_PLATFORM;
end;


procedure TIdSoapListener.GenerateWSDLPage(APrefix, AParam, ALocation: String; AResponse: TStream; Var VContentType : string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.GenerateWSDLPage';
var
  LStr : string;
  LWsdl : TIdSoapWSDL;
  LNamespace : string;
  LWsdlConvertor : TIdSoapWSDLConvertor;
  LITIDescriber : TIdSoapITIDescriber;
  i : integer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': Self is not valid');
  IdRequire(Active, ASSERT_LOCATION+': not currently Active');
  Assert(Assigned(AResponse), ASSERT_LOCATION+': Response = nil');
  Assert(ITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  // no check on APrefix or AParam
  Assert(assigned(AResponse), ASSERT_LOCATION+': Stream is not valid');

  if AParam <> '' then
    begin
    if AParam[1] = '/' then
      begin
      Delete(AParam, 1, 1);
      end;
    end;
  if (APrefix <> '') and (APrefix[Length(APrefix)] <> '/') then
    begin
    APrefix := APrefix + '/';
    end;
  if AParam = '' then
    begin
    LStr := ListInterfaces(ITI, APrefix);
    AResponse.Write(LStr[1], length(LStr));
    VContentType := 'text/html';                 { do not localize }
    end
  else if (AParam = '*') or (AParam = 'all') then
    begin
    Assert(ITI.Interfaces.count > 0, ASSERT_LOCATION+': no interfaces to show');
    VContentType := 'text/xml';                  { do not localize }
    LNamespace := (ITI.Interfaces.Objects[0] as TIdSoapITIInterface).Namespace;
    if LNamespace = '' then
      begin
      LNamespace := DefaultNamespace;
      end;
    LWsdl := TIdSoapWSDL.create(LNamespace);
    try
      LITIDescriber := TIdSoapITIDescriber.create(LWsdl, Self);
      try
        for i := 0 to ITI.Interfaces.Count - 1 do
          begin
          LITIDescriber.Describe(ITI.Interfaces.Objects[i] as TIdSoapITIInterface, ALocation);
          end;
      finally
        FreeAndNil(LITIDescriber);
      end;
      LWsdlConvertor := TIdSoapWSDLConvertor.create(self, LWsdl);
      try
        LWsdlConvertor.WriteToXml(AResponse);
      finally
        FreeAndNil(LWsdlConvertor);
      end;
    finally
      FreeAndNil(LWsdl);
    end;
    end
  else if (ITI.Interfaces.IndexOf(AParam) > -1) and IdSoapInterfaceRegistered(AParam) then
    begin
    VContentType := 'text/xml';                  { do not localize }
    LNamespace := (ITI.Interfaces.Objects[ITI.Interfaces.IndexOf(AParam)] as TIdSoapITIInterface).Namespace;
    if LNamespace = '' then
      begin
      LNamespace := DefaultNamespace;
      end;
    LWsdl := TIdSoapWSDL.create(LNamespace);
    try
      LITIDescriber := TIdSoapITIDescriber.create(LWsdl, Self);
      try
        LITIDescriber.Describe(ITI.Interfaces.Objects[ITI.Interfaces.IndexOf(AParam)] as TIdSoapITIInterface, ALocation);
      finally
        FreeAndNil(LITIDescriber);
      end;
      LWsdlConvertor := TIdSoapWSDLConvertor.create(self, LWsdl);
      try
        LWsdlConvertor.WriteToXml(AResponse);
      finally
        FreeAndNil(LWsdlConvertor);
      end;
    finally
      FreeAndNil(LWsdl);
    end;
    end
  else
    begin
    VContentType := 'text/plain';               { do not localize }
    LStr := 'The Service "'+AParam+'" is not a known Service';   { do not localize }
    AResponse.Write(LStr[1], length(LStr));
    end;
  AResponse.position := 0;
end;


// AParam will be nil for traversing complex objects.
// if AParam is nil, then do NOT output to AAsm as the data is not a parameter, but a member of a parameter.
// if AParam is nil, then AParamIndex is unused
// yet to arrange for an object cache
// if AParam is nil, then output data to AData and use ATypeInfo for type information
function TIdSoapListener.ProcessParameter(ABaseNode: TIdSoapNode; AParamName : string; var AData; ATypeInfo: PTypeInfo; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; AParam: TIdSoapITIParameter; AServerContext: TIdSoapServerRequestContext; AParamIndex: Integer; AIsParameter : boolean): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParameter';
var
  LParamType: PTypeInfo;
  LBasicType: TIdSoapBasicType;
  LParamName : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': AReader not valid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': AAsm not valid');
  Assert((ATypeInfo <> nil) or AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': AParam not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': AServerContext not valid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ABaseNode not valid');
    end;
  if Assigned(ATypeInfo) then
    LParamType := ATypeInfo
  else
    LParamType := IdSoapGetTypeInfo(AParam.NameOfType);
  Assert(Assigned(LParamType), ASSERT_LOCATION+': Unable to locate type info for ' + AParam.NameOfType);
  LBasicType := IdSoapBasicType(LParamType);
  if AIsParameter then
    begin
    LParamName := AParam.ReplaceName(AParam.Name);
    end
  else
    begin
    // we are a field, and the replacement has already been done
    LParamName := AParam.Name;
    end;
  case LParamType^.Kind of
    tkInt64,
    tkInteger:      result := ProcessParamInteger(LParamName, LBasicType,AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData);
    tkSet:          result := ProcessParamSet(LParamName, LBasicType,AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,LParamType,AData);
    tkFloat:        result := ProcessParamFloat(LParamName, LBasicType,AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData);
    tkEnumeration:  result := ProcessParamEnum(LParamName, LBasicType,AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData,LParamType);
    tkDynArray:     result := ProcessParamDynArray(LParamName, LBasicType,AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData,LParamType);
    tkClass:        result := ProcessParamClass(LParamName, AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData,LParamType);
    tkString:       result := ProcessParamShortString(LParamName, AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData);
    tkLString:      result := ProcessParamLongString(LParamName, AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData);
    tkWString:      result := ProcessParamWideString(LParamName, AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData);
    tkChar:         result := ProcessParamChar(LParamName, AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData);
    tkWChar:        result := ProcessParamWideChar(LParamName, AServerContext,AParam,AParamIndex,AReader,AAsm,ABaseNode,AData);
    else            raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [AParam.NameOfType]));
    end;
end;

function TIdSoapListener.ProcessParamInteger(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamInteger';
var
  LPtr: Pointer;
  LSize: Integer;
  LInt64: Int64;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(ABasicType in (IdSoapBasicTypeInteger + [isbtInt64]), ASSERT_LOCATION+''+IdSoapTypeNameFromBasicType(ABasicType) + ' is not an ordinal type');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  LSize := IdSoapSizeOfBasicType(ABasicType);
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    LPtr := AServerContext.GetTempMemory(LSize);
    result := sizeof(Pointer);
    AServerContext.ParamPtr[AParamIndex] := LPtr;
    if AParam.ParamFlag = pfVar then
      begin
      IdSoapGetParamFromReader(AReader,nil,AParamName,ABasicType,LPtr^);
      end
    else if AParam.ParamFlag = pfOut then
      begin
      FillChar(LPtr^,LSize,ID_SOAP_INIT_MEM_VALUE);
      end;
    if assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPtr);
      end;
    end
  else
    begin
    if Assigned(ABaseNode) then
      begin
      IdSoapGetParamFromReader(AReader,ABaseNode,AParamName,ABasicType,AData);
      result := 0;  // its not a parameter so this value doesnt matter
      end
    else
      begin
      IdSoapGetParamFromReader(AReader,nil,AParamName,ABasicType,LInt64);
      if ABasicType = isbtInt64 then
        begin
        if Assigned(AAsm) then
          begin
          AAsm.AsmPushInt64(LInt64);
          end;
        result := sizeof(int64);
        end
      else
        begin
        if Assigned(AAsm) then
          begin
          AAsm.AsmPushCardinal(Cardinal(LInt64));
          end;
        result := sizeof(cardinal);   // there all 4 bytes here
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamSet(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; ATypeInfo : PTypeInfo; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamSet';
  procedure SetValueForSet(var AData);
  var
    LTemp: Cardinal;
    LType : String;
    LTypeNS : string;
  begin
    AParam.ReplaceTypeName(AParam.NameOfType, DefaultNamespace, LType, LTypeNS);

    LTemp := AReader.ParamSet[ABaseNode, AParamName, LType, LTypeNS, GetSetContentType(ATypeInfo)];
    case ABasicType of
      isbtSetByte:       Byte(AData)     := LTemp;
      isbtSetShortInt:   ShortInt(AData) := LTemp;
      isbtSetWord:       Word(AData)     := LTemp;
      isbtSetSmallInt:   SmallInt(AData) := LTemp;
      isbtSetInteger:    Integer(AData)  := LTemp;
      isbtSetCardinal:   Cardinal(AData) := LTemp;
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+IdSoapTypeNameFromBasicType(ABasicType) + ' is not a supported type'); { do not localize }
    end;
  end;
var
  LPtr: Pointer;
  LSize: Integer;
  LCard : Cardinal;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(ABasicType in IdSoapBasicTypeSet,ASSERT_LOCATION+''+IdSoapTypeNameFromBasicType(ABasicType) + ' is not a SET type in TIdSoapListener.ProcessParamSet.');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  LSize := IdSoapSizeOfBasicType(ABasicType);
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    LPtr := AServerContext.GetTempMemory(LSize);
    result := sizeof(pointer);
    AServerContext.ParamPtr[AParamIndex] := LPtr;
    if AParam.ParamFlag = pfVar then
      begin
      SetValueForSet(LPtr^);
      end
    else if AParam.ParamFlag = pfOut then
      begin
      FillChar(LPtr^,LSize,ID_SOAP_INIT_MEM_VALUE);
      end;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPtr);
      end;
    end
  else
    begin
    result := sizeof(Cardinal);  // all sets are assumed to be 4 bytes
    if Assigned(ABaseNode) then
      begin
      SetValueForSet(AData);
      end
    else
      begin
      SetValueForSet(LCard);
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushCardinal(LCard);
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamFloat(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamFloat';
var
  LPtr: Pointer;
  LSize: Integer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(ABasicType in IdSoapBasicTypeFloat,ASSERT_LOCATION+''+IdSoapTypeNameFromBasicType(ABasicType) + ' is not a FLOAT type in TIdSoapListener.ProcessParamSet.');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  LSize := IdSoapSizeOfBasicType(ABasicType);
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    LPtr := AServerContext.GetTempMemory(LSize);
    result := sizeof(pointer);
    AServerContext.ParamPtr[AParamIndex] := LPtr;
    if AParam.ParamFlag = pfVar then
      begin
      IdSoapGetParamFromReader(AReader,nil,AParamName,ABasicType,LPtr^);
      end
    else if AParam.ParamFlag = pfOut then
      begin
      FillChar(LPtr^, LSize, ID_SOAP_INIT_MEM_VALUE);
      end;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPtr);
      end;
    end
  else
    begin
    if Assigned(ABaseNode) then
      begin
      IdSoapGetParamFromReader(AReader,ABaseNode,AParamName,ABasicType,AData);
      result := 0;  // its not a param so it doesnt matter
      end
    else
      begin
      case ABasicType of
        isbtSingle:
          begin
          if Assigned(AAsm) then
            begin
            AAsm.AsmPushSingle(AReader.ParamSingle[nil, AParamName]);
            end;
          result := sizeof(Single);
          end;
        isbtDouble:
          begin
          if Assigned(AAsm) then
            begin
            AAsm.AsmPushDouble(AReader.ParamDouble[nil, AParamName]);
            end;
          result := sizeof(Double);
          end;
        isbtExtended:
          begin
          if Assigned(AAsm) then
            begin
            AAsm.AsmPushExtended(AReader.ParamExtended[nil, AParamName]);
            end;
          result := sizeof(Extended);
          end;
        isbtComp:
          begin
          if Assigned(AAsm) then
            begin
            AAsm.AsmPushComp(AReader.ParamComp[nil, AParamName]);
            end;
          result := sizeof(Comp);
          end;
        isbtCurrency:
          begin
          if Assigned(AAsm) then
            begin
            AAsm.AsmPushCurrency(AReader.ParamCurrency[nil, AParamName]);
            end;
          result := sizeof(Currency);
          end;
      else raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [IdSoapTypeNameFromBasicType(ABasicType)]));
      end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamEnum(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData; AParamType: PTypeInfo): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamEnum';
var
  LPtr: Pointer;
  LTemp: Integer;
  LType : String;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(ABasicType in IdSoapBasicTypeEnum,ASSERT_LOCATION+''+IdSoapTypeNameFromBasicType(ABasicType) + ' is not an ENUMERATION type.');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  AParam.ReplaceTypeName(AParamType.Name, DefaultNamespace, LType, LTypeNS);
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    LPtr := AServerContext.GetTempMemory(Sizeof(Integer));  // they all work with this
    result := sizeof(pointer);
    AServerContext.ParamPtr[AParamIndex] := LPtr;
    if AParam.ParamFlag = pfVar then
      begin
      if ABasicType = isbtBoolean then
        begin
        Integer(LPtr^) := ord(AReader.ParamBoolean[nil,AParamName]);
        end
      else
        begin
        Integer(LPtr^) := AReader.ParamEnumeration[nil, AParamName, AParamType, LType, LTypeNS, AParam];
        end;
      end
    else if AParam.ParamFlag = pfOut then   // init the OUT
      begin
      FillChar(LPtr^, Sizeof(Integer), ID_SOAP_INIT_MEM_VALUE);
      end;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPtr);
      end;
    end
  else
    begin
    result := sizeof(Cardinal);   // there all a 4 byte stack entry
    if Assigned(ABaseNode) then
      begin
      if ABasicType = isbtBoolean then
        begin
        LTemp := ord(AReader.ParamBoolean[nil,AParamName]);
        end
      else
        LTemp := AReader.ParamEnumeration[ABaseNode, AParamName, AParamType, LType, LTypeNS, AParam];
      move(LTemp,AData,IdSoapSizeOfBasicType(ABasicType));  // should to be sized correctly
      end
    else
      begin
      if ABasicType = isbtBoolean then
        LTemp := ord(AReader.ParamBoolean[nil,AParamName])
      else
        LTemp := AReader.ParamEnumeration[nil, AParamName, AParamType, LType, LTypeNS, AParam];
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushInt(LTemp);
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamDynArray(AParamName : string; ABasicType: TIdSoapBasicType; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData; ATypeInfo: PTypeInfo): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamDynArray';
var
  LPtr: Pointer;
  LDynArr: Pointer;
  LRootNode,LNode : TIdSoapNode;
  LFakeParam: TIdSoapITIParameter;
  LIter: TIdSoapNodeIterator;
  LSubscripts: Integer;
  LIsSimpleType: Boolean;
  LTemp: Integer;
  LSubscriptInfo: TIdSoapNodeIteratorInfo;
  LTypeInfo : PTypeInfo;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  Assert(Assigned(ATypeInfo),ASSERT_LOCATION+': ATypeInfo is nil');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  // AParam.TypeInformation contains the typeinfo for the array
  LDynArr := AServerContext.GetTempMemory(Sizeof(pointer));  // a dynamic array is just a pointer
  pointer(LDynArr^) := nil;                                  // default to empty before we start filling it
  result := sizeof(Pointer);  // either way its a pointer
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    AServerContext.ParamPtr[AParamIndex] := LDynArr;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LDynArr);
      end;
    end;
  if AParam.ParamFlag <> pfOut then   // for value and var types
    begin
    // build a FAKE param element for it
    LRootNode := AReader.GetArray(ABaseNode, AParamName, True);
//    if not AReader.ParamExists[ABaseNode,AParam.Name] then
    if not Assigned(LRootNode) then  // its an empty array
      begin
      AServerContext.AddArrayFinalize(LDynArr,AParam.TypeInformation, ABaseNode = nil);
      if Assigned(ABaseNode) then
        begin
        pointer(AData) := pointer(LDynArr^);
        end
      else if not (AParam.ParamFlag in [pfVar, pfOut]) then  // add code for non-var types
        begin
        if Assigned(AAsm) then
          begin
          AAsm.AsmPushPtr(pointer(LDynArr^));  // push ptr of actual dynamic array structure
          end;
        end;
      exit;
      end;
    LFakeParam := TIdSoapITIParameter.Create(nil, AParam); // connect to Name/Type replacement system
    try
      LFakeParam.ParamFlag := pfReference;
      LTypeInfo := IdSoapGetDynArrBaseTypeInfo(AParam.TypeInformation);
      LFakeParam.TypeInformation := LTypeInfo;
      LFakeParam.NameOfType := LTypeInfo^.Name;
      case LTypeInfo^.kind of
        tkClass  :  LIsSimpleType := IsSpecialClass(LTypeInfo^.Name);
        tkDynArray :  LIsSimpleType := false;
      else
        LIsSimpleType := true;
      end;
      LIter := TIdSoapNodeIterator.Create;
      try
        LSubscripts := IdSoapDynArrSubscriptsFromTypeInfo(AParam.TypeInformation);
        if LIsSimpleType then
          dec(LSubscripts);
        if LSubscripts = 0 then
          begin
          LFakeParam.NameOfType := AParam.TypeInformation^.Name;
          for LTemp:=0 to LRootNode.Params.Count-1 do
            begin
            LFakeParam.Name := LRootNode.Params[LTemp];
            LPtr := IdSoapGetDynamicArrayDataFromNode(pointer(LDynArr^),AParam.TypeInformation,LIter.Info,IdSoapIndexFromName(LFakeParam.Name, ASSERT_LOCATION),ATypeInfo);
            ProcessParameter(LRootNode,LRootNode.Params[LTemp],LPtr^,LTypeInfo,AReader,AAsm,LFakeParam,AServerContext,-1, false);
            end;
          end;
        if LIter.First(LRootNode,LSubscripts) then
          begin
          repeat
            if LIsSimpleType then
              begin
              // get the node below me as this has the final details
              LSubscriptInfo := LIter.Info[LSubscripts-1];
              LNode := LSubscriptInfo.Node.Children.Objects[LSubscriptInfo.Index] as TIdSoapNode;
              for LTemp:=0 to LNode.Params.Count-1 do
                begin
                LFakeParam.Name := LNode.Params[LTemp];
                LPtr := IdSoapGetDynamicArrayDataFromNode(pointer(LDynArr^),AParam.TypeInformation,LIter.Info,IdSoapIndexFromName(LFakeParam.Name, ASSERT_LOCATION),ATypeInfo);
                ProcessParameter(LNode,LNode.Params[LTemp],LPtr^,LTypeInfo,AReader,AAsm,LFakeParam,AServerContext,-1, false);
                end;
              end
            else
              begin
              LSubscriptInfo := LIter.Info[LSubscripts-1];  // info on the leaf node of the array
              LNode := LSubscriptInfo.Node.Children.Objects[LSubscriptInfo.Index] as TIdSoapNode;
              LFakeParam.Name := LNode.Name;
              LNode := LNode.Parent;
              LPtr := IdSoapGetDynamicArrayDataFromNode(pointer(LDynArr^),AParam.TypeInformation,LIter.Info,-1,ATypeInfo);
              ProcessParameter(LNode,LNode.Name,LPtr^,LTypeInfo,AReader,AAsm,LFakeParam,AServerContext,-1, false);
              end;
            until not LIter.Next;
          end;
      finally
        FreeAndNil(LIter);
      end;
    finally
      FreeAndNil(LFakeParam);
    end;
    if AServerContext.ClassDepth = 0 then  // only finalize arrays that are params
      begin
      AServerContext.AddArrayFinalize(LDynArr,AParam.TypeInformation, ABaseNode = nil);
      end;
    if Assigned(ABaseNode) then
      begin
      pointer(AData) := pointer(LDynArr^);
      end
    else if not (AParam.ParamFlag in [pfVar, pfOut]) then  // add code for non-var types
      begin
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushPtr(pointer(LDynArr^));  // push ptr of actual dynamic array structure
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamClass(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData; AParamType: PTypeInfo): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamClass';
var
  LPtr: Pointer;
  LClassType: PTypeInfo;
  LClass: TObject;
  LRootNode: TIdSoapNode;
  LTClass: TIdBaseSoapableClassClass;
  LPropMan: TIdSoapPropertyManager;
  LSlot: Integer;
  LParamName: String;
  LTypeInfo: PTypeInfo;
  LFakeParam: TIdSoapITIParameter;
  LSpecialType: TIdSoapSimpleClassHandler;
  LPrecreated : boolean;
  LClassParam: Pointer;
  LClassName : string;
  LType : string;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  result := sizeof(Pointer);  // either way its a pointer
  LClassType := nil;  // remove warning
  if AParam.ParamFlag = pfOut then
    begin
    if Assigned(ABaseNode) then
      begin
      TObject(AData) := nil;
      end
    else
      begin
      LPtr := AServerContext.GetTempMemory(Sizeof(pointer));
      pointer(LPtr^) := nil;
      AServerContext.ParamPtr[AParamIndex] := LPtr;
      AServerContext.AddObjectToDispose(LPtr);
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushPtr(LPtr);
        end;
      end;
    exit;
    end;
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  LSpecialType := IdSoapSpecialType(AParamType^.Name);
  if Assigned(LSpecialType) then
    begin
    try
      LClassParam := LSpecialType.GetParam(AReader, ABaseNode, AParamName);
      if not Assigned(LClassParam) then  // its a nil class
        begin
        if Assigned(ABaseNode) then   // its not a parameter
          begin
          pointer(AData) := nil;
          end
        else                         // it is a parameter
          begin
          if AParam.ParamFlag in [pfOut,pfVar] then
            begin
            LPtr := AServerContext.GetTempMemory(Sizeof(pointer));
            pointer(LPtr^) := nil;
            AServerContext.ParamPtr[AParamIndex] := LPtr;
            AServerContext.AddObjectToDispose(LPtr);
            if Assigned(AAsm) then
              begin
              AAsm.AsmPushPtr(LPtr);
              end;
            end
          else
            begin
            if Assigned(AAsm) then
              begin
              AAsm.AsmPushPtr(nil);
              end;
            end;
          end;
        exit;
        end;
      if Assigned(ABaseNode) then
        begin
        TObject(AData) := LClassParam;
        end
      else
        begin
        LPtr := AServerContext.GetTempMemory(Sizeof(pointer));
        LClass := ID_SOAP_INVALID_POINTER;  // remove warning and cause GP if its used
        AServerContext.ParamPtr[AParamIndex] := LPtr;
        if AParam.ParamFlag = pfOut then
          begin
          FillChar(LPtr^, Sizeof(pointer), ID_SOAP_INIT_MEM_VALUE);
          end
        else
          begin
          LClass := LClassParam;
          TObject(LPtr^) := LClass;
          end;
        AServerContext.AddObjectToDispose(LPtr);
        if AParam.ParamFlag in [pfVar, pfOut] then
          begin
          if Assigned(AAsm) then
            begin
            AAsm.AsmPushPtr(LPtr);
            end;
          end
        else
          begin
          if Assigned(AAsm) then
            begin
            AAsm.AsmPushPtr(LClass);
            end;
          end;
        end
    finally
      FreeAndNil(LSpecialType);
      end;
    end
  else        // its not a special type
    begin
    LRootNode := AReader.GetNodeNoClassnameCheck(ABaseNode, AParamName,True);
    if not Assigned(LRootNode) then  // its a nil class
      begin
      if Assigned(ABaseNode) then   // its not a parameter
        begin
        pointer(AData) := nil;
        end
      else                         // it is a parameter
        begin
        if Assigned(AAsm) then
          begin
          AAsm.AsmPushPtr(nil);
          end;
        end;
      exit;
      end;
    LPrecreated := false;
    if Assigned(LRootNode.Reference) then
      begin
      LRootNode := LRootNode.Reference;
      LPrecreated := (seoReferences in EncodingOptions) and Assigned(LRootNode.ActualObject);
      end;

    if Assigned(ABaseNode) then
      begin
      if LPrecreated then
        begin
        LClass := LRootNode.ActualObject;
        end
      else
        begin
        if LRootNode.TypeName <> '' then
          begin
          LClassName := AParam.ReverseReplaceType(LRootNode.TypeName, LRootNode.TypeNamespace, DefaultNamespace);
          LClassType := IdSoapGetTypeInfo(LClassName, AParamType);
          end
        else
          begin
          LClassName := AParamType^.Name;
          LClassType := AParamType;
          end;
        Assert(assigned(LClassType), ASSERT_LOCATION+': Reference to class "'+LClassName+'" could not be resolved');
        pointer(LTClass) := GetTypeData(LClassType)^.ClassType;
        LClass := LTClass.Create;
        end;
      TObject(AData) := LClass;
      end
    else
      begin
      LPtr := AServerContext.GetTempMemory(Sizeof(pointer));
      if not LPrecreated then
        begin
        if AServerContext.ClassDepth = 0 then  // its a class we need to destroy ourselves
          begin
          AServerContext.AddObjectToDispose(LPtr);
          end;
        end;
      if AParam.ParamFlag = pfOut then
        begin
        Pointer(LPtr^) := nil;     // its to be assigned (maybe) by the callee
        AServerContext.ParamPtr[AParamIndex] := LPtr;
        if Assigned(AAsm) then
          begin
          AAsm.AsmPushPtr(LPtr);
          end;
        exit;    // we just need the pointer's location
        end;
      if LPrecreated then
        begin
        LClass := LRootNode.ActualObject;
        end
      else
        begin
        if LRootNode.TypeName <> '' then
          begin
          LClassName := AParam.ReverseReplaceType(LRootNode.TypeName, LRootNode.TypeNamespace, DefaultNamespace);
          LClassType := IdSoapGetTypeInfo(LClassName, AParamType);
          end
        else
          begin
          LClassName := AParamType^.Name;
          LClassType := AParamType;
          end;
        Assert(assigned(LClassType), ASSERT_LOCATION+': Reference to class "'+LClassName+'" could not be resolved');
        pointer(LTClass) := GetTypeData(LClassType)^.ClassType;
        LClass := LTClass.Create;
        end;
      Pointer(LPtr^) := LClass;
      if AParam.ParamFlag = pfVar then
        begin
        AServerContext.ParamPtr[AParamIndex] := LPtr;
        if Assigned(AAsm) then
          begin
          AAsm.AsmPushPtr(LPtr);
          end;
        end
      else
        begin
        if Assigned(AAsm) then
          begin
          AAsm.AsmPushPtr(LClass);
          end;
        end;
      end;

    Try
      AServerContext.ClassDepth := AServerContext.ClassDepth + 1;
      if not LPrecreated then
        begin
        LRootNode.ActualObject := LClass;
        LPropMan := IdSoapGetClassPropertyInfo(LClassType);
        LFakeParam := nil;   // it may or may not be allocated. Depends on the data
        try
          for LSlot := 1 to LPropMan.Count do
            begin
            LParamName := AParam.ReplacePropertyName(LClassType^.Name, LPropMan.Properties[LSlot]^.Name);
            LTypeInfo := LPropMan.Properties[LSlot]^.PropType^;
            case LTypeInfo^.Kind of
              tkInteger:
                begin
                case GetTypeData(LTypeInfo)^.OrdType of
                  otSByte:  LPropMan.AsShortInt[LClass,LSlot] := AReader.ParamShortInt[LRootNode, LParamName];
                  otUByte:  LPropMan.AsByte[LClass,LSlot] := AReader.ParamByte[LRootNode, LParamName];
                  otSWord:  LPropMan.AsSmallInt[LClass,LSlot] := AReader.ParamSmallInt[LRootNode, LParamName];
                  otUWord:  LPropMan.AsWord[LClass,LSlot] := AReader.ParamWord[LRootNode, LParamName];
                  otSLong:  LPropMan.AsInteger[LClass,LSlot] := AReader.ParamInteger[LRootNode, LParamName];
      {$IFNDEF DELPHI4}
                  otULong:  LPropMan.AsCardinal[LClass,LSlot] := AReader.ParamCardinal[LRootNode, LParamName];
      {$ENDIF}
                  end;
                end;
              tkFloat:
                begin
                case GetTypeData(LTypeInfo)^.FloatType of
                  ftSingle:    LPropMan.AsSingle[LClass,LSlot] := AReader.ParamSingle[LRootNode, LParamName];
                  ftDouble:    LPropMan.AsDouble[LClass,LSlot] := AReader.ParamDouble[LRootNode, LParamName];
                  ftExtended:  LPropMan.AsExtended[LClass,LSlot] := AReader.ParamExtended[LRootNode, LParamName];
                  ftComp:      LPropMan.AsComp[LClass,LSlot] := AReader.ParamComp[LRootNode, LParamName];
                  ftCurr:      LPropMan.AsCurrency[LClass,LSlot] := AReader.ParamCurrency[LRootNode, LParamName];
                  end;
                end;
              tkLString:     LPropMan.AsAnsiString[LClass,LSlot] := AReader.ParamString[LRootNode, LParamName];
              tkWString:     LPropMan.AsWideString[LClass,LSlot] := AReader.ParamWideString[LRootNode, LParamName];
              tkString:      LPropMan.AsShortString[LClass,LSlot] := AReader.ParamShortString[LRootNode, LParamName];
              tkInt64:       LPropMan.AsInt64[LClass,LSlot] := AReader.ParamInt64[LRootNode, LParamName];
              tkChar:        LPropMan.AsChar[LClass,LSlot] := AReader.ParamChar[LRootNode, LParamName];
              tkWChar:       LPropMan.AsWideChar[LClass,LSlot] := AReader.ParamWideChar[LRootNode, LParamName];
              tkEnumeration: begin
                             if AnsiSameText(LTypeInfo^.Name,'Boolean') then           { do not localize }
                               begin
                               LPropMan.AsBoolean[LClass,LSlot] := AReader.ParamBoolean[LRootNode,LParamName];
                               end
                             else
                               begin
                               AParam.ReplaceTypeName(LTypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
                               LPropMan.AsEnumeration[LClass,LSlot] := AReader.ParamEnumeration[LRootNode,LParamName,LTypeInfo,LType,LTypeNS, AParam];
                               end;
                             end;
              tkSet:         begin
                               AParam.ReplaceTypeName(LTypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
                               LPropMan.AsSet[LClass,LSlot] := AReader.ParamSet[LRootNode,LParamName, LType, LTypeNS, GetSetContentType(LTypeInfo)];
                             end;
              tkClass:       begin
                             LSpecialType := IdSoapSpecialType(AParamType^.Name);
                             if Assigned(LSpecialType) then
                               begin
                               try
                                 LPropMan.AsClass[LClass, LSlot] := LSpecialType.GetParam(AReader, LRootNode, LParamName);
                               finally
                                 FreeAndNil(LSpecialType);
                                 end;
                               end
                             else
                               begin
                               // now build a fake parameter
                               if not Assigned(LFakeParam) then
                                 begin
                                 LFakeParam := TIdSoapITIParameter.Create(nil, AParam); // connect to name/type replacement system
                                 end;
                               LFakeParam.Name := LParamName;
                               LFakeParam.TypeInformation := LTypeInfo;
                               LFakeParam.NameOfType := LTypeInfo^.Name;
                               LFakeParam.ParamFlag := pfReference;
                               ProcessParameter(LRootNode,LParamName,LPtr,LTypeInfo,AReader,AAsm,LFakeParam,AServerContext,-1, false);
                               LPropMan.AsClass[LClass,LSlot] := LPtr;
                               end;
                             end;
              tkDynArray:
                             begin
                             if not Assigned(LFakeParam) then
                               begin
                               LFakeParam := TIdSoapITIParameter.Create(nil, AParam); // connect to name/type replacement system
                               end;
                             LFakeParam.Name := LParamName;
                             LFakeParam.TypeInformation := LTypeInfo;
                             LFakeParam.NameOfType := LTypeInfo^.Name;
                             LFakeParam.ParamFlag := pfReference;
                             ProcessParameter(LRootNode,LParamName,LPtr,LTypeInfo,AReader,AAsm,LFakeParam,AServerContext,-1, false);
                             LPropMan.AsDynamicArray[LClass,LSlot] := LPtr;
                             end;
              else
                raise EIdSoapBadParameterValue.create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_PARAM_TYPE_WRONG, [LParamName, LTypeInfo^.Name]));
              end;
            end;
        finally
          FreeAndNil(LFakeParam);
          end;
      end;
    Finally
      AServerContext.ClassDepth := AServerContext.ClassDepth - 1;
      end;
    end;
end;

function TIdSoapListener.ProcessParamShortString(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamShortString';
var
  LPtr: Pointer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  LPtr := AServerContext.GetTempMemory(256);   // allocate memory for a shortstring
  AServerContext.ParamPtr[AParamIndex] := LPtr;
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    result := sizeof(Pointer);
    if AParam.ParamFlag = pfVar then
      begin
      ShortString(LPtr^) := AReader.ParamShortString[nil, AParamName];
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushInt(255);  // this is the max string len that can be placed in this var/out param
        end;
      end
    else if AParam.ParamFlag = pfOut then
      begin
      Byte(LPtr^) := 0;  // set to 0 length for an OUT type param
      end;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPtr);
      end;
    end
  else
    begin
    result := sizeof(Pointer);  // either way its a pointer
    if Assigned(ABaseNode) then
      begin
      ShortString(AData) := AReader.ParamShortString[ABaseNode, AParamName];
      end
    else
      begin
      ShortString(LPtr^) := AReader.ParamShortString[nil, AParamName]; // just a temp holder for the shortstring
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushPtr(LPtr);
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamLongString(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamLongString';
var
  LPString: PString;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  result := sizeof(Pointer);  // either way its a pointer
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    LPString := AServerContext.GetTempString;
    if AParam.ParamFlag = pfVar then
      begin
      LPString^ := AReader.ParamString[nil, AParamName];
      end
    else if AParam.ParamFlag = pfOut then
      begin
      LPString^ := '';
      end;
    AServerContext.ParamPtr[AParamIndex] := LPString;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPString);
      end;
    end
  else
    begin
    if Assigned(ABaseNode) then
      begin
      String(AData) := AReader.ParamString[ABaseNode, AParamName];
      end
    else
      begin
      LPString := AServerContext.GetTempString;
      LPString^ := AReader.ParamString[nil, AParamName];
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushPtr(pointer(LPString^));
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamWideString(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamWideString';
var
  LPWideString: PWideString;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  result := sizeof(Pointer);  // either way its a pointer
  LPWideString := AServerContext.GetTempWideString;
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    if AParam.ParamFlag = pfVar then
      begin
      LPWideString^ := AReader.ParamWideString[nil, AParamName];
      end
    else if AParam.ParamFlag = pfOut then
      begin
      LPWideString^ := '';
      end;
    AServerContext.ParamPtr[AParamIndex] := LPWideString;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPWideString);
      end;
    end
  else
    begin
    if Assigned(ABaseNode) then
      begin
      WideString(AData) := AReader.ParamWideString[ABaseNode, AParamName];
      end
    else
      begin
      LPWideString^ := AReader.ParamWideString[nil, AParamName];
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushPtr(pointer(LPWideString^));
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamChar(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamChar';
var
  LPtr: Pointer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    LPtr := AServerContext.GetTempMemory(Sizeof(Char));
    result := sizeof(Pointer);
    AServerContext.ParamPtr[AParamIndex] := LPtr;
    if AParam.ParamFlag = pfVar then
      begin
      Char(LPtr^) := AReader.ParamChar[nil, AParamName];
      end
    else if AParam.ParamFlag = pfOut then
      begin
      Char(LPtr^) := ID_SOAP_INIT_MEM_VALUE;
      end;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPtr);
      end;
    end
  else
    begin
    result := sizeof(cardinal);  // its 4 bytes on the stack
    if Assigned(ABaseNode) then
      begin
      Char(AData) := AReader.ParamChar[ABaseNode, AParamName];
      end
    else
      begin
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushCardinal(Ord(AReader.ParamChar[nil, AParamName]));
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessParamWideChar(AParamName : string; AServerContext: TIdSoapServerRequestContext; AParam: TIdSoapITIParameter; AParamIndex: Integer; AReader: TIdSoapReader; AAsm: TIdSoapDynamicAsm; ABaseNode: TIdSoapNode; Var AData): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessParamWideChar';
var
  LPtr: Pointer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AParamName <> '', ASSERT_LOCATION+': No parameter names defined');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AParamIndex >= -1,ASSERT_LOCATION+': AParamIndex is invalid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader is invalid');
  Assert((AAsm = nil) or AAsm.TestValid(TIdSoapDynamicAsm),ASSERT_LOCATION+': AAsm is invalid');
  if Assigned(ABaseNode) then
    begin
    Assert(ABaseNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ABaseNode is invalid');
    end;
  if AParam.ParamFlag in [pfVar, pfOut] then
    begin
    LPtr := AServerContext.GetTempMemory(Sizeof(WideChar));
    result := sizeof(Pointer);
    AServerContext.ParamPtr[AParamIndex] := LPtr;
    if AParam.ParamFlag = pfVar then
      begin
      WideChar(LPtr^) := AReader.ParamWideChar[nil, AParamName];
      end
    else if AParam.ParamFlag = pfOut then
      begin
      WideChar(LPtr^) := ID_SOAP_INIT_MEM_VALUE;
      end;
    if Assigned(AAsm) then
      begin
      AAsm.AsmPushPtr(LPtr);
      end;
    end
  else
    begin
    result := sizeof(Cardinal);   // 4 bytes on the stack
    if Assigned(ABaseNode) then
      begin
      WideChar(AData) := AReader.ParamWideChar[ABaseNode, AParamName];
      end
    else
      begin
      if Assigned(AAsm) then
        begin
        AAsm.AsmPushCardinal(Ord(AReader.ParamWideChar[nil, AParamName]));
        end;
      end;
    end;
end;

function TIdSoapListener.ProcessStackBasedResult(AServerContext: TIdSoapServerRequestContext; AAsm: TIdSoapDynamicAsm; AResultType: PTypeInfo): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessStackBasedResult';
var
  LPtr: Pointer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AAsm.TestValid(TIdSoapDynamicAsm), ASSERT_LOCATION+': AAsm is invalid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+': AResultType is NIL');
  result := 0;   // assume its not on the stack until proven otherwise
  case AResultType^.Kind of
    tkChar,
    tkWChar,
    tkInt64,
    tkEnumeration,
    tkSet,
    tkInteger,
    tkClass,
    tkFloat:
        begin
        end;
    tkString:
        begin
        LPtr := AServerContext.GetTempMemory(256);  // allocate mem for a shortstring
        AServerContext.ResultPtr := LPtr;
        Byte(LPtr^) := 0;                           // set to an empty shortstring
        AAsm.AsmPushPtr(LPtr);                      // save the address on the stack
        result := sizeof(pointer);
        end;
    tkLString:
        begin
        LPtr := AServerContext.GetTempString;
        AServerContext.ResultPtr := LPtr;
        AAsm.AsmPushPtr(LPtr);  // ptr to string handle NOT to string
        result := sizeof(pointer);
        end;
    tkWString:
        begin
        LPtr := AServerContext.GetTempWideString;
        AServerContext.ResultPtr := LPtr;
        AAsm.AsmPushPtr(LPtr);  // ptr to string handle NOT to string
        result := sizeof(pointer);
        end;
    tkDynArray:
        begin
        LPtr := AServerContext.GetTempMemory(Sizeof(Pointer));
        pointer(LPtr^) := nil;
        AServerContext.ResultPtr := LPtr;
        AAsm.AsmPushPtr(LPtr);  // ptr to string handle NOT to string
        result := sizeof(pointer);
        end;
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [AResultType^.Name]));
    end;
end;

procedure TIdSoapListener.ProcessOutParam(AData: Pointer; ARootNode: TIdSoapNode; AEntryName: String; AWriter: TIdSoapWriter; AParam: TIdSoapITIParameter; AServerContext: TIdSoapServerRequestContext; AParamIndex: Integer; AIsParameter : boolean; ADefault : integer = MININT);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessOutParam';
var
  LParamName: String;
  LData: Pointer;
  LBasicType: TIdSoapBasicType;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': AWriter not valid');
  if Assigned(AParam) then
    begin
    Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': AParam not valid');
    if not (AParam.ParamFlag in [pfVar, pfOut]) then   // it isnt an output param type
      begin
      exit;
      end;
    end;
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': AServerContext not valid');
  Assert(AParamIndex >= -1, ASSERT_LOCATION+': AParamIndex must be >= 0');
  Assert(Assigned(AParam),ASSERT_LOCATION+': AParam cannot be nil');
  if AIsParameter then
    begin
    LParamName := AParam.ReplaceName(AParam.Name);
    end
  else
    begin
    LParamName := AParam.Name;
    end;
  if (not Assigned(ARootNode)) and (AParamIndex <> -1) then
    begin
    Assert(Assigned(AServerContext.ParamPtr[AParamIndex]), ASSERT_LOCATION+': an OUT/VAR parameter needs to have a PramPtr to save result to');
    end;
  if Assigned(AData) then
    begin
    LData := AData;
    end
  else
    begin
    LData := AServerContext.ParamPtr[AParamIndex];
    end;
  LBasicType := IdSoapBasicType(AParam.TypeInformation);
  case AParam.TypeInformation^.Kind of
    tkInt64,
    tkFloat,
    tkInteger:       IdSoapDefineParamToWriter(AWriter,ARootNode,LParamName,LBasicType, MAXINT, LData^);
    tkChar:          AWriter.DefineParamChar(ARootNode, LParamName, Char(LData^));
    tkWChar:         AWriter.DefineParamWideChar(ARootNode, LParamName, WideChar(LData^));
    tkEnumeration:   ProcessOutParamEnum(AWriter,ARootNode,AParam,LParamName,LData^,AParam.TypeInformation, MAXINT);
    tkSet:           ProcessOutParamSet(AWriter,ARootNode,AParam,LParamName,LData^,AParam.TypeInformation);
    tkDynArray:      ProcessOutParamDynArray(AWriter,AServerContext,ARootNode,AParam,LData^,AParamIndex);
    tkClass:         ProcessOutParamClass(AWriter,AServerContext,ARootNode,AParam,LData^);
    tkString:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (ShortString(LData^) = '') then
          begin
          AWriter.DefineParamShortString(ARootNode, LParamName, ShortString(LData^));
          end;
        end;
    tkLString:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (PString(LData)^ = '') then
          begin
          AWriter.DefineParamString(ARootNode, LParamName, PString(LData)^);
          end;
        end;
    tkWString:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (PWideString(LData)^ = '') then
          begin
          AWriter.DefineParamWideString(ARootNode, LParamName, PWideString(LData)^);
          end;
        end;
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [AParam.TypeInformation^.Name]));
    end;
end;

procedure TIdSoapListener.ProcessOutParamEnum(AWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParam : TIdSoapITIParameter; AParamName: String; Var AData; AParamType: PTypeInfo; ADefault : Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessOutParamEnum';
var
  LBasicType: TIdSoapBasicType;
  LType : string;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': Param is invalid');
  if Assigned(ARootNode) then
    begin
    Assert(ARootNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ARootNode is invalid');
    end;
  Assert(Assigned(AParamType),ASSERT_LOCATION+': AParamType is nil');
  AParam.ReplaceTypeName(AParam.NameOfType, DefaultNamespace, LType, LTypeNS);
  LBasicType := IdSoapBasicType(AParamType);
  case LBasicType of
    // no default for Boolean
    isbtBoolean:AWriter.DefineParamBoolean(ARootNode, AParamName, Boolean(AData));
    isbtEnumShortInt:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (ShortInt(AData) = ADefault) then
          begin
          AWriter.DefineParamEnumeration(ARootNode, AParamName, AParamType, LType, LTypeNS, AParam, ShortInt(AData));
          end;
        end;
    isbtEnumByte:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Byte(AData) = ADefault) then
          begin
          AWriter.DefineParamEnumeration(ARootNode, AParamName, AParamType, LType, LTypeNS, AParam, Byte(AData));
          end;
        end;
    isbtEnumSmallInt:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (SmallInt(AData) = ADefault) then
          begin
          AWriter.DefineParamEnumeration(ARootNode, AParamName, AParamType, LType, LTypeNS, AParam, SmallInt(AData));
          end;
        end;
    isbtEnumWord:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Word(AData) = ADefault) then
          begin
          AWriter.DefineParamEnumeration(ARootNode, AParamName, AParamType, LType, LTypeNS, AParam, Word(AData));
          end;
        end;
    isbtEnumInteger:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Integer(AData) = ADefault) then
          begin
          AWriter.DefineParamEnumeration(ARootNode, AParamName, AParamType, LType, LTypeNS, AParam, Integer(AData));
          end;
        end;
    isbtEnumCardinal:
        begin
        if (ADefault = MININT) or not (seoSendNoDefaults in EncodingOptions) or not (Integer(AData) = ADefault) then
          begin
          AWriter.DefineParamEnumeration(ARootNode, AParamName, AParamType, LType, LTypeNS, AParam, Cardinal(AData));
          end;
        end;
    else
      raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [AParamType^.Name]));
    end;
end;

procedure TIdSoapListener.ProcessOutParamSet(AWriter: TIdSoapWriter; ARootNode: TIdSoapNode; AParam : TIdSoapITIParameter; AParamName: String; Var AData; AParamType: PTypeInfo);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessOutParamSet';
var
  LBasicType: TIdSoapBasicType;
  LType : string;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': Param is invalid');
  if Assigned(ARootNode) then
    begin
    Assert(ARootNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ARootNode is invalid');
    end;
  Assert(Assigned(AParamType),ASSERT_LOCATION+': AParamType is nil');

  AParam.ReplaceTypeName(AParam.NameOfType, DefaultNamespace, LType, LTypeNS);
  LBasicType := IdSoapBasicType(AParamType);
  case LBasicType of
    isbtSetByte:       AWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType), Byte(AData));
    isbtSetShortInt:   AWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType), ShortInt(AData));
    isbtSetWord:       AWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType), Word(AData));
    isbtSetSmallInt:   AWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType), SmallInt(AData));
    isbtSetInteger:    AWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType), Integer(AData));
    isbtSetCardinal:   AWriter.DefineParamSet(ARootNode, AParamName, LType, LTypeNS, GetSetContentType(AParamType), Cardinal(AData));
  else
    raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [AParamType^.Name]));
  end;
end;

procedure TIdSoapListener.ProcessOutParamDynArray(AWriter: TIdSoapWriter; AServerContext: TIdSoapServerRequestContext; ARootNode: TIdSoapNode; AParam: TIdSoapITIParameter; Var AData; AParamIndex: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessOutParamDynArray';
var
  LDynArr: Pointer;
  LSubscripts : TIdSoapDynArrSubscriptEntryArray;
  LSubEntry: ^TIdSoapDynArrSubscriptEntry;
  LRoot,LNode, LWork: TIdSoapNode;
  LTypeInfo: PTypeInfo;
  LAdjust: Integer;
  LIndex: Integer;
  LFakeParam: TIdSoapITIParameter;
  LData: Pointer;
  LIsComplexType: Boolean;
  LEndOfSubscript: Integer;
  LType : string;
  LTypeNS : string;
  LClass: TObject;
  LSpecialType: TIdSoapSimpleClassHandler;
  LClassTypeInfo : PTypeInfo;
  LPropMan: TIdSoapPropertyManager;
  LFakeParam2: TIdSoapITIParameter;
  LType2 : string;
  LTypeNS2 : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  if Assigned(ARootNode) then
    begin
    Assert(ARootNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ARootNode is invalid');
    end;
  LDynArr := pointer(AData);       // the actual dynamic array
  if AParamIndex <> -1 then
    begin
    AServerContext.AddArrayFinalize(@AData,AParam.TypeInformation, ARootNode = nil);
    end;
  // prepare for array traversal
  IdSoapDynArrSetupSubscriptCounter(LSubscripts,LDynArr,AParam.TypeInformation);
  LTypeInfo := IdSoapGetDynArrBaseTypeInfo(AParam.TypeInformation);
  LType := GetNativeSchemaType(LTypeInfo^.Name);
  if LType <> '' then
    begin
    LTypeNS := ID_SOAP_NS_SCHEMA_2001;
    end
  else
    begin
    AParam.ReplaceTypeName(LTypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
    end;
  LRoot := AWriter.AddArray(ARootNode,AParam.Name, LType, LTypeNS, (LTypeInfo^.Kind = tkDynArray) or ((LTypeInfo^.Kind = tkClass) and (not IsSpecialClass(LTypeInfo^.Name))));
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
  // put the data into the leaf node entry
  LSpecialType := nil;
  LFakeParam2 := nil;
  LClassTypeInfo := nil;
  LPropMan := nil;
  LFakeParam := TIdSoapITIParameter.Create(nil, AParam);
  try
    LFakeParam.ParamFlag := pfOut;
    LFakeParam.TypeInformation := LTypeInfo;
    LFakeParam.NameOfType := LTypeInfo^.Name;
    while IdSoapDynArrNextEntry(LDynArr,LSubscripts) do
      begin
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
            LSubEntry^.Node := AWriter.AddArray(LNode, IntToStr(LSubEntry^.Entry), LType, LTypeNS, (LTypeInfo^.Kind = tkDynArray) or ((LTypeInfo^.Kind = tkClass) and (not IsSpecialClass(LTypeInfo^.Name))));
          end;
        end;
        LData := IdSoapDynArrData(LSubscripts,LDynArr);
        LFakeParam.Name := inttostr(LSubscripts[length(LSubscripts)-1].Entry);
        if (Length(LSubscripts) = 1) and (LTypeInfo^.Kind <> tkClass) then  // due to the node/parameter issues, 1 dim arrays of simple types are special
          begin
          LWork := LRoot;
          end
        else
          begin
          LWork := LSubscripts[length(LSubscripts)-1-LAdjust].Node;
          end;
        case LTypeInfo^.Kind of
          tkInt64,
          tkFloat,
          tkInteger:       IdSoapDefineParamToWriter(AWriter,LWork,LFakeParam.Name,IdSoapBasicType(LTypeInfo),MININT,LData^);
          tkChar:          AWriter.DefineParamChar(LWork, LFakeParam.Name, Char(LData^));
          tkWChar:         AWriter.DefineParamWideChar(LWork, LFakeParam.Name, WideChar(LData^));
          tkEnumeration:   ProcessOutParamEnum(AWriter,LWork,AParam,LFakeParam.Name,LData^,LTypeInfo, MININT);
          tkSet:           ProcessOutParamSet(AWriter,LWork,AParam,LFakeParam.Name,LData^,LTypeInfo);
          tkDynArray:      ProcessOutParamDynArray(AWriter,AServerContext,LWork,LFakeParam,LData^,AParamIndex);
          tkString:
              begin
              if not (seoSendNoDefaults in EncodingOptions) or not (ShortString(LData^) = '') then
                begin
                AWriter.DefineParamShortString(LWork, LFakeParam.Name, ShortString(LData^));
                end;
              end;
          tkLString:
              begin
              if not (seoSendNoDefaults in EncodingOptions) or not (PString(LData)^ = '') then
                begin
                AWriter.DefineParamString(LWork, LFakeParam.Name, PString(LData)^);
                end;
              end;
          tkWString:
              begin
              if not (seoSendNoDefaults in EncodingOptions) or not (PWideString(LData)^ = '') then
                begin
                AWriter.DefineParamWideString(LWork, LFakeParam.Name, PWideString(LData)^);
                end;
              end;
          tkClass:
            // arrays of classes are extremely common, and can be very large. They get special consideration for performance reasons
            // here we do metadata lookups as little as possible
            begin
            LClass := TObject(LData^);
            if assigned(LClass) then
              begin
              if (not assigned(LClassTypeInfo) and not assigned(LSpecialType)) or (assigned(LClassTypeInfo) and (LClass.ClassInfo <> LClassTypeInfo)) then
                begin
                if not assigned(LClassTypeInfo) then
                  begin
                  LSpecialType := IdSoapSpecialType(LTypeInfo^.Name);
                  end;
                if not Assigned(LSpecialType) then
                  begin
                  LClassTypeInfo := GetTypeForClass(LTypeInfo, LClass);
                  Assert(Assigned(LClassTypeInfo), ASSERT_LOCATION+'["'+Name+'"]: No RTTI info for class');
                  AParam.ReplaceTypeName(LClassTypeInfo^.Name, DefaultNamespace, LType2, LTypeNS2);
                  LPropMan := IdSoapGetClassPropertyInfo(LClassTypeInfo);
                  Assert(Assigned(LPropMan),ASSERT_LOCATION+': Unable to locate property info for class ' + LClassTypeInfo^.Name);
                  if not assigned(LFakeParam2) then
                    begin
                    LFakeParam2 := TIdSoapITIParameter.Create(nil, AParam); // connect to name/type system
                    LFakeParam2.ParamFlag := pfOut;
                    end;
                  end;
                end;
              if Assigned(LSpecialType) then
                begin
                LSpecialType.DefineParam(AWriter, LWork, LFakeParam.Name, LClass);
                end
              else
                begin
                ProcessOutParamClassInner(AWriter, AServerContext, LWork, LFakeParam, LTypeNS2, LType2, LClassTypeInfo, LPropMan, LClass, LFakeParam2);
                end;
              end;
            end;
        else
          raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [LTypeInfo^.Name]));
        end;
      end;
  finally
    FreeAndNil(LSpecialType);
    FreeAndNil(LFakeParam2);
    FreeAndNil(LFakeParam);
    end;
end;

procedure TIdSoapListener.ProcessOutParamClassInner(AWriter: TIdSoapWriter; AServerContext: TIdSoapServerRequestContext; ARootNode: TIdSoapNode; AParam: TIdSoapITIParameter;
                                                    ANamespace, AName : string; ATypeInfo : PTypeInfo; APropMan: TIdSoapPropertyManager; AClass : TObject; AFakeParam: TIdSoapITIParameter);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessOutParamClass';
var
  LRoot: TIdSoapNode;
  LIndex: Integer;
  LPropInfo: PPropInfo;
  LPropType: PTypeInfo;
  LBufHolder: Array [1..10] of byte;
  LBuf: Pointer;
  LAnsiString: AnsiString;
  LWideString: WideString;
  LShortString: ShortString;
  LDynArr: Pointer;
  LPtr: Pointer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self is not valid');
  Assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': AWriter is not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': AServerContext is not valid');
  Assert(not assigned(ARootNode) or ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ARootNode is not valid');
  Assert(AParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': AParam is not valid');
  // no check ANamespace, AName
  Assert(assigned(ATypeInfo), ASSERT_LOCATION+': ATypeInfo is not valid');
  Assert(APropMan.TestValid(TIdSoapPropertyManager), ASSERT_LOCATION+': APropMan is not valid');
  Assert(assigned(AClass), ASSERT_LOCATION+': AClass is not valid');
  Assert(AFakeParam.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': AFakeParam is not valid');

  LBuf := @LBufHolder;                  // its used as a generic holder
  LRoot := AWriter.AddStruct(ARootNode, AParam.Name, AName, ANamespace, AClass);
  if assigned(LRoot) then
    begin
    LRoot.ForceTypeInXML := ATypeInfo <> AParam.TypeInformation;
    for LIndex:=1 to APropMan.Count do
      begin
      LPropInfo := APropMan[LIndex];
      LPropType := LPropInfo^.PropType^;
      AFakeParam.Name := AParam.ReplacePropertyName(ATypeInfo^.Name, APropMan[LIndex]^.Name);
      AFakeParam.TypeInformation := LPropType;
      AFakeParam.NameOfType := LPropType^.Name;
      case LPropType^.Kind of
        tkInteger:
          begin
          case GetTypeData(LPropType)^.OrdType of
            otSByte:  ShortInt(LBuf^) := APropMan.AsShortInt[AClass,LIndex];
            otUByte:  Byte(LBuf^) := APropMan.AsByte[AClass,LIndex];
            otSWord:  SmallInt(LBuf^) := APropMan.AsSmallInt[AClass,LIndex];
            otUWord:  Word(LBuf^) := APropMan.AsWord[AClass,LIndex];
            otSLong:  Integer(LBuf^) := APropMan.AsInteger[AClass,LIndex];
            {$IFNDEF DELPHI4}
            otULong:  Cardinal(LBuf^) := APropMan.AsCardinal[AClass,LIndex];
            {$ENDIF}
            else  raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, ['Integer: '+LPropType^.Name]));
            end;
          ProcessOutParam(LBuf,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false, LPropInfo^.Default);
          end;
        tkFloat:
          begin
          case GetTypeData(LPropType)^.FloatType of
            ftSingle:      Single(LBuf^) := APropMan.AsSingle[AClass,LIndex];
            ftDouble:      Double(LBuf^) := APropMan.AsDouble[AClass,LIndex];
            ftExtended:    Extended(LBuf^) := APropMan.AsExtended[AClass,LIndex];
            ftComp:        Comp(LBuf^) := APropMan.AsComp[AClass,LIndex];
            ftCurr:        Currency(LBuf^) := APropMan.AsCurrency[AClass,LIndex];
            else  raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, ['Float: '+LPropType^.Name]));
            end;
          ProcessOutParam(LBuf,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkLString:
          begin
          LAnsiString := APropMan.AsAnsiString[AClass,LIndex];
          ProcessOutParam(@LAnsiString,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkWString:
          begin
          LWideString := APropMan.AsWideString[AClass,LIndex];
          ProcessOutParam(@LWideString,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkString:
          begin
          LShortString := APropMan.AsShortString[AClass,LIndex];
          ProcessOutParam(@LShortString,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkChar:
          begin
          Char(LBuf^) := APropMan.AsChar[AClass,LIndex];
          ProcessOutParam(LBuf,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkWChar:
          begin
          WideChar(LBuf^) := APropMan.AsWideChar[AClass,LIndex];
          ProcessOutParam(LBuf,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkEnumeration:
          begin
          // ProcessOutParam will take care of Boolean types too
          Integer(LBuf^) := APropMan.AsEnumeration[AClass,LIndex];
          ProcessOutParam(LBuf,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false, LPropInfo^.Default);
          end;
        tkSet:
          begin
          case GetTypeData(LPropType)^.OrdType of
            otSByte:  ShortInt(LBuf^) := APropMan.AsShortInt[AClass,LIndex];
            otUByte:  Byte(LBuf^) := APropMan.AsByte[AClass,LIndex];
            otSWord:  SmallInt(LBuf^) := APropMan.AsSmallInt[AClass,LIndex];
            otUWord:  Word(LBuf^) := APropMan.AsWord[AClass,LIndex];
            otSLong:  Integer(LBuf^) := APropMan.AsInteger[AClass,LIndex];
            {$IFNDEF DELPHI4}
            otULong:  Cardinal(LBuf^) := APropMan.AsCardinal[AClass,LIndex];
            {$ENDIF}
            else  raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [LPropType^.Name]));
            end;
          ProcessOutParam(LBuf,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkInt64:
          begin
          Int64(LBuf^) := APropMan.AsInt64[AClass,LIndex];
          ProcessOutParam(LBuf,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        tkDynArray:
          begin
          LDynArr := APropMan.AsDynamicArray[AClass,LIndex];  // this needs to have finalize run against the array when finished
          try
            ProcessOutParam(@LDynArr,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          finally
            IdSoapDynArrayClear(LDynArr,APropMan[LIndex]^.PropType^);  // finalize it
            end;
          end;
        tkClass:
          begin
          LPtr := APropMan.AsClass[AClass,LIndex];
          ProcessOutParam(@LPtr,LRoot,APropMan[LIndex]^.Name,AWriter,AFakeParam,AServerContext,-1, false);
          end;
        end;
      end;
  end; //assigned(LRoot)
end;

procedure TIdSoapListener.ProcessOutParamClass(AWriter: TIdSoapWriter; AServerContext: TIdSoapServerRequestContext; ARootNode: TIdSoapNode; AParam: TIdSoapITIParameter; Var AData);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessOutParamClass';
var
  LClass: TObject;
  LSpecialType: TIdSoapSimpleClassHandler;
  LClassTypeInfo : PTypeInfo;
  LPropMan: TIdSoapPropertyManager;
  LFakeParam: TIdSoapITIParameter;
  LType : string;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AParam.TestValid(TIdSoapITIParameter),ASSERT_LOCATION+': AParam is invalid');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  if Assigned(ARootNode) then
    begin
    Assert(ARootNode.TestValid(TIdSoapNode),ASSERT_LOCATION+': ARootNode is invalid');
    end;
  LClass := TObject(AData);
  LSpecialType := IdSoapSpecialType(AParam.TypeInformation^.Name);
  if Assigned(LSpecialType) then
    begin
    try
      LSpecialType.DefineParam(AWriter, ARootNode, AParam.Name, LClass);
    finally
      FreeAndNil(LSpecialType);
      end;
    end
  else
    begin
    if LClass = nil then
      begin
      exit;
      end;

    // polymorphism support
    LClassTypeInfo := GetTypeForClass(AParam.TypeInformation, LClass);
    Assert(Assigned(LClassTypeInfo), ASSERT_LOCATION+'["'+Name+'"]: No RTTI info for class');
    AParam.ReplaceTypeName(LClassTypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
    LPropMan := IdSoapGetClassPropertyInfo(LClassTypeInfo);
    Assert(Assigned(LPropMan),ASSERT_LOCATION+': Unable to locate property info for class ' + LClassTypeInfo^.Name);
    LFakeParam := TIdSoapITIParameter.Create(nil, AParam); // connect to name/type system
    try
      LFakeParam.ParamFlag := pfOut;
      ProcessOutParamClassInner(AWriter, AServerContext, ARootNode, AParam, LTypeNS, LType, LClassTypeInfo, LPropMan, LClass, LFakeParam);
    finally
      FreeAndNil(LFakeParam);
    end;
    end;
end;

procedure TIdSoapListener.ProcessResult(AServerContext: TIdSoapServerRequestContext; AWriter: TIdSoapWriter; AResultType: PTypeInfo; AMethod: TIdSoapITIMethod; AAns: Int64);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessResult';
var
  LBasicType: TIdSoapBasicType;
  LName : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(Assigned(AResultType), ASSERT_LOCATION+': Result type is nil');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': AServerContext not valid');
  Assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': AWriter not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': AMethod invalid');
  LBasicType := IdSoapBasicType(AResultType);
  LName := AMethod.ReplaceName('result', ID_SOAP_NAME_RESULT);
  case AResultType^.Kind of
    tkInteger:        IdSoapDefineParamToWriter(AWriter,nil,LName,LBasicType,0, AAns);
    tkFloat:          ProcessResultFloat(LBasicType, LName, AWriter);
    tkInt64:          AWriter.DefineParamInt64(nil, LName, Int64(AAns));
    tkEnumeration:    ProcessResultEnum(LBasicType,LName,AWriter,AAns,AResultType, AMethod);
    tkSet:            ProcessResultSet(LBasicType,LName,AWriter,AResultType, AMethod, AAns);
    tkDynArray:       ProcessResultDynArray(LBasicType,LName,AWriter,AAns,AResultType,AServerContext, AMethod);
    tkClass:          ProcessResultClass(LBasicType,LName,AMethod, AWriter,AAns,AResultType,AServerContext);
    tkString:
        begin
        Assert(Assigned(AServerContext.ResultPtr), ASSERT_LOCATION+': tkString has a NIL for the result ptr');
        if not (seoSendNoDefaults in EncodingOptions) or not ( ShortString(AServerContext.ResultPtr^) = '') then
          begin
          AWriter.DefineParamShortString(nil, LName, ShortString(AServerContext.ResultPtr^));
          end;
        end;
    tkLString:
        begin
        Assert(Assigned(AServerContext.ResultPtr), ASSERT_LOCATION+': tkLString has a NIL for the result ptr');
        if not (seoSendNoDefaults in EncodingOptions) or not (PString(AServerContext.ResultPtr)^ = '') then
          begin
          AWriter.DefineParamString(nil, LName, PString(AServerContext.ResultPtr)^);
          end;
        end;
    tkWString:
        begin
        Assert(Assigned(AServerContext.ResultPtr), ASSERT_LOCATION+': tkWString has a NIL for the result ptr');
        if not (seoSendNoDefaults in EncodingOptions) or not (PWideString(AServerContext.ResultPtr)^ = '') then
          begin
          AWriter.DefineParamWideString(nil, LName, PWideString(AServerContext.ResultPtr)^);
          end;
        end;
    tkChar:
        begin
        AWriter.DefineParamChar(nil, LName, Char(AAns));
        end;
    tkWChar:
        begin
        AWriter.DefineParamWideChar(nil, LName, WideChar(AAns));
        end;
    else raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [AResultType^.Name]));
    end;
end;

procedure TIdSoapListener.ProcessResultFloat(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessResultFloat';
var
  LTemp: array [1..10] of Byte;  // used for floating point temp retrieval storage
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is empty');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  case ABasicType of
    isbtSingle:
      asm
        fstp DWord Ptr LTemp
        wait
        end;
    isbtDouble:
      asm
        fstp QWord Ptr LTemp
        wait
        end;
    isbtExtended:
      asm
        fstp TByte Ptr LTemp
        wait
        end;
    isbtComp:
      asm
        fistp QWord Ptr LTemp
        wait
        end;
    isbtCurrency:
      asm
        fistp QWord Ptr LTemp
        wait
        end;
    else raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [IdSoapTypeNameFromBasicType(ABasicType)]));
    end;
  IdSoapDefineParamToWriter(AWriter,nil,AName,ABasicType,0,LTemp);
end;

procedure TIdSoapListener.ProcessResultEnum(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter; var AAns; AResultType: PTypeInfo; AMethod: TIdSoapITIMethod);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessResultEnum';
var
  LInteger: Integer;
  LType : string;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is empty');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  Assert(Assigned(AResultType),ASSERT_LOCATION+': AResultType is invalid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': Method is not valid');
  if ABasicType = isbtBoolean then
    begin
    AWriter.DefineParamBoolean(nil, AName, Boolean(AAns));
    end
  else
    begin
    AMethod.ReplaceTypeName(AResultType^.Name, DefaultNamespace, LType, LTypeNS);
    case ABasicType of
      isbtEnumShortInt:       LInteger := ShortInt(AAns);
      isbtEnumByte:           LInteger := Byte(AAns);
      isbtEnumSmallInt:       LInteger := SmallInt(AAns);
      isbtEnumWord:           LInteger := Word(AAns);
      isbtEnumInteger:        LInteger := Integer(AAns);
{$IFNDEF DELPHI4}
      isbtEnumCardinal:       LInteger := Cardinal(AAns);
{$ENDIF}
    else raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [IdSoapTypeNameFromBasicType(ABasicType)]));
    end;
    AWriter.DefineParamEnumeration(nil, AName, AResultType, LType, LTypeNS, AMethod, LInteger);
    end;
end;

procedure TIdSoapListener.ProcessResultSet(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter; AParamType : PTypeInfo; AMethod: TIdSoapITIMethod; var AAns);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessResultSet';
var
  LInteger: Integer;
  LType : string;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is empty');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  AMethod.ReplaceTypeName(AParamType^.Name, DefaultNamespace, LType, LTypeNS);
  case ABasicType of
    isbtSetShortInt:     LInteger := ShortInt(AAns);
    isbtSetByte:         LInteger := Byte(AAns);
    isbtSetSmallInt:     LInteger := SmallInt(AAns);
    isbtSetWord:         LInteger := Word(AAns);
    isbtSetInteger:      LInteger := Integer(AAns);
    isbtSetCardinal:     LInteger := Cardinal(AAns);
    else raise EIdSoapUnknownType.Create(ASSERT_LOCATION+': '+Format(RS_ERR_ENGINE_UNKNOWN_TYPE, [IdSoapTypeNameFromBasicType(ABasicType)]));
    end;
  AWriter.DefineParamSet(nil, AName, LType, LTypeNS, GetSetContentType(AParamType), LInteger);
end;

procedure TIdSoapListener.ProcessResultDynArray(ABasicType: TIdSoapBasicType; AName : string; AWriter: TIdSoapWriter; var AAns; AResultType: PTypeInfo; AServerContext: TIdSoapServerRequestContext; AMethod: TIdSoapITIMethod);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessResultDynArray';
var
  LDynArr: Pointer;
  LSubscripts : TIdSoapDynArrSubscriptEntryArray;
  LSubEntry: ^TIdSoapDynArrSubscriptEntry;
  LRoot,LNode: TIdSoapNode;
  LTypeInfo: PTypeInfo;
  LAdjust: Integer;
  LIndex: Integer;
  LFakeParam: TIdSoapITIParameter;
  LData: Pointer;
  LIsComplexType: Boolean;
  LEndOfSubscript: Integer;
  LType : string;
  LTypeNS : string;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is empty');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  Assert(Assigned(AResultType),ASSERT_LOCATION+': AResultType is nil');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': method is not valid');

  LDynArr := pointer(AServerContext.ResultPtr^);    // the actual dynamic array
  AServerContext.AddArrayFinalize(AServerContext.ResultPtr, AResultType, true);
  // prepare for array traversal
  IdSoapDynArrSetupSubscriptCounter(LSubscripts,LDynArr,AResultType);
  LTypeInfo := IdSoapGetDynArrBaseTypeInfo(AResultType);
  LType := GetNativeSchemaType(LTypeInfo^.Name);
  if LType <> '' then
    begin
    LTypeNS := ID_SOAP_NS_SCHEMA_2001;
    end
  else
    begin
    AMethod.ReplaceTypeName(LTypeInfo^.Name, DefaultNamespace, LType, LTypeNS);
    end;
  LRoot := AWriter.AddArray(nil,AName, LType, LTypeNS, (LTypeInfo^.Kind = tkDynArray) or ((LTypeInfo^.Kind = tkClass) and (not IsSpecialClass(LTypeInfo^.Name))));
  // iterate through all populated array elements
  case LTypeInfo^.Kind of
    tkClass,tkDynArray:
      begin
      LAdjust := 0;
      LIsComplexTYpe := True;
      end;
    else
      begin
      LAdjust := 1;
      LIsComplexTYpe := False;
      end;
    end;
  while IdSoapDynArrNextEntry(LDynArr,LSubscripts) do
    begin
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
        if LIsComplexType and (LIndex=LEndOfSubscript)  then
          LSubEntry^.Node := LNode
        else
        LSubEntry^.Node := AWriter.AddArray(LNode, IntToStr(LSubEntry^.Entry), LType, LTypeNS, (LTypeInfo^.Kind = tkDynArray) or ((LTypeInfo^.Kind = tkClass) and (not IsSpecialClass(LTypeInfo^.Name))));
        end;
      end;
    // put the data into the leaf node entry
    LFakeParam := TIdSoapITIParameter.Create(nil, AMethod);
    try
      LFakeParam.Name := inttostr(LSubscripts[length(LSubscripts)-1].Entry);
      LFakeParam.ParamFlag := pfOut;
      LFakeParam.TypeInformation := LTypeInfo;
      LFakeParam.NameOfType := LTypeInfo^.Name;
      LData := IdSoapDynArrData(LSubscripts,LDynArr);
      if (Length(LSubscripts) = 1) and (LTypeInfo^.Kind <> tkClass) then  // due to the node/parameter issues, 1 dim arrays of simple types are special
        ProcessOutParam(LData,LRoot,LFakeParam.Name,AWriter,LFakeParam,AServerContext,-1, false)
      else
        ProcessOutParam(LData,LSubscripts[length(LSubscripts)-1-LAdjust].Node,LFakeParam.Name,AWriter,LFakeParam,AServerContext,-1, false);
    finally
      FreeAndNil(LFakeParam);
      end;
    end;
end;

procedure TIdSoapListener.ProcessResultClass(ABasicType: TIdSoapBasicType; AName : string; AMethod : TIdSoapITIMethod; AWriter: TIdSoapWriter; var AAns; AResultType: PTypeInfo; AServerContext: TIdSoapServerRequestContext);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessResultClass';
var
  LFakeParam: TIdSoapITIParameter;
  LClass : TObject;
  LSpecialType: TIdSoapSimpleClassHandler;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is empty');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext),ASSERT_LOCATION+': AServerContext is invalid');
  Assert(AWriter.TestValid(TIdSoapWriter),ASSERT_LOCATION+': AWriter is invalid');
  Assert(Assigned(AResultType),ASSERT_LOCATION+': AResultType is nil');
  LSpecialType := IdSoapSpecialType(AResultType^.Name);
  if Assigned(LSpecialType) then
    begin
    try
      LClass := TObject(AAns);
      LSpecialType.DefineParam(AWriter, nil, AName, LClass);
      If assigned(LClass) then
        begin
        FreeAndNil(LClass);
        end;
    finally
      FreeAndNil(LSpecialType);
      end;
    end
  else
    begin
    // will most likely call ProcessParameter to get filled in
    LFakeParam := TIdSoapITIParameter.Create(nil, AMethod);
    try
      if Int64(AAns) <> 0 then // result not a nil class
        begin
        if not Assigned(pointer(AAns)) then
          begin
          exit;
          end;
        end;
      LFakeParam.Name := AName;
      LFakeParam.ParamFlag := pfOut;
      LFakeParam.TypeInformation := AResultType;
      LFakeParam.NameOfType := AResultType^.Name;
      ProcessOutParam(@AAns,nil,LFakeParam.Name,AWriter,LFakeParam,AServerContext,-1, false);
    finally
      FreeAndNil(LFakeParam);
      end;
    if Int64(AAns) <> 0 then
      begin
      LClass := TObject(pointer(@AAns)^);
      if LClass is TIdBaseSoapableClass then
        begin
        If not (LClass as TIdBaseSoapableClass).ServerLeaveAlive then
          begin
          FreeAndNil(LClass);
          end;
        end
      else
        begin
        FreeAndNil(LClass);
        end;
      end;
    end;
end;

// The LStringCache is used to serve up unique strings for parameters, and if needed for the result.
// This is needed to allow multiple strings to be easily extracted for parameter usage

procedure TIdSoapListener.ExecuteSoapCall(AReader: TIdSoapReader; ACookieServices : TIdSoapAbstractCookieIntf; AWriter: TIdSoapWriter);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ExecuteSoapCall';
var
  LServerObj: TIdSoapBaseImplementation;
  LMethodPtr: Pointer;
  LInterface: TIdSoapITIInterface;
  LMethod: TIdSoapITIMethod;
  LParamIndex: Integer;
  LAsm: TIdSoapDynamicAsm;
  LAns: Int64;
  LResultType: String;
  LServerContext: TIdSoapServerRequestContext;
  LDummy: Byte;   // until dynamic arrays and classes are coded
  LSession : TIdSoapServerSession;
{$IFDEF LINUX}
  LBackPatch: Integer;
  LStackBytes: Integer;
{$ENDIF}
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': AReader not valid');
  Assert((AWriter = nil) or AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': AWriter not valid');

  LSession := CheckForSession(AReader, ACookieServices);
  try
    try

    {******************* Server Security Checks Start *****************************}
      // Note:
      // Although this is lablled *Security Checks* there is a great number of reasons
      // why these checks might trip. You cannot disable these checks to resolve your
      // problems - you have to solve them elsewhere
      //
      // Check:
      //   * the ITI and the source are synchronised properly
      //   * {$IFNDEF VER140?} your methods are in the published section in your implementation object
      //   * you have got the name spaces right. IndySoap will only handle matching method names and namespaces
      //     The combinations of methods and namespaces are definitively described in the WSDL. Not that it's
      //     easy to read. You can also use the local Soap Server method ListValidCalls to get this information
      //
      IdRequire(ITI.FindRequestHandler(AReader.MessageNameSpace, AReader.MessageName, LInterface, LMethod),
                ASSERT_LOCATION+': '+Format(RS_ERR_SERVER_NO_HANDLER, [AReader.MessageName, AReader.MessageNameSpace]));
      Assert(Assigned(LInterface), ASSERT_LOCATION+': Unable to find interface for the Soap Request "'+AReader.MessageName+'" in namespace "'+AReader.MessageNameSpace+'"');
      Assert(Assigned(LMethod), ASSERT_LOCATION+': Unable to find method for the Soap Request "'+AReader.MessageName+'" in namespace "'+AReader.MessageNameSpace+'"');
      if not assigned(AWriter) then
        begin
        CheckMethodForNoResponseMode(LMethod);
        end;
      if  (LMethod.SessionRequired) and not (assigned(LSession)) then
        begin
        raise EIdSoapSessionRequired.create(Format(RS_ERR_SERVER_SESSION_REQUIRED, [AReader.MessageName, AReader.MessageNameSpace]));
        end;
      LServerObj := IdSoapInterfaceImplementationFactory(LInterface.Name) as TIdSoapBaseImplementation;
      IdRequire(Assigned(LServerObj), ASSERT_LOCATION+': '+Format(RS_ERR_SERVER_NO_IMPL, [AReader.MessageName, AReader.MessageNameSpace]));
      LServerObj._AddRef;
      try
        LMethodPtr := LServerObj.MethodAddress(LMethod.Name);
        IdRequire(Assigned(LMethodPtr), ASSERT_LOCATION+': '+Format(RS_ERR_SERVER_NO_METHOD, [AReader.MessageName, AReader.MessageNameSpace]));
    {******************* Server Security Checks Finish ****************************}


        AReader.EncodingMode := LMethod.EncodingMode;
        if assigned(AWriter) then
          begin
          AWriter.EncodingMode := AReader.EncodingMode;
          end;

        AReader.DecodeMessage;

        {$IFDEF ID_SOAP_SHOW_NODES}
        ShowNode('Server Params',LInterface.Name,LMethod.Name,AReader.BaseNode);
        {$ENDIF}
        LServerContext := TIdSoapServerRequestContext.Create;
        try
          LAsm := TIdSoapDynamicAsm.Create;
          try
            ProcessHeadersRecv(LMethod, AReader, LServerContext);
            {$IFDEF LINUX}
            LStackBytes := 0;
            LBackPatch := LAsm.AsmPushInt(integer($80000000 or 0)) + 1;
            LAsm.AsmPushEbp;
            LAsm.AsmPushInt(integer($beeffeed));
            {$ENDIF}
            for LParamIndex := LMethod.Parameters.Count - 1 downto 0 do   // params are pushed backwards
              begin
              {$IFDEF LINUX}
              LStackBytes := LStackBytes +
              {$ENDIF}
              ProcessParameter(nil, LMethod.Parameters.Param[LParamIndex].ReplaceName(LMethod.Parameters.Param[LParamIndex].Name),
                          LDummy, NIL, AReader, LAsm, LMethod.Parameters.Param[LParamIndex], LServerContext, LParamIndex, true);
              end;
            LAsm.AsmPushPtr(LServerObj);   // push self
            LResultType := UpperCase(LMethod.ResultType);
            if LResultType <> '' then
              begin
              {$IFDEF LINUX}
              LStackBytes := LStackBytes +
              {$ENDIF}
              ProcessStackBasedResult(LServerContext, LAsm, IdSoapGetTypeInfo(LResultType));
              end;
            LAsm.AsmFarCall(@LMethodPtr);
            {$IFDEF LINUX}
            LAsm.AsmAddSp(12);
            {$ENDIF}
            LAsm.AsmRet(0);
            {$IFDEF LINUX}
            LAsm.PatchInt(LBackPatch,LStackBytes);
            {$ENDIF}
           LAns := Lasm.Execute(0);
            if assigned(AWriter) then
              begin
              if LInterface.Namespace <> '' then
                begin
                AWriter.SetMessageName(LMethod.ResponseMessageName, LInterface.Namespace);
                end
              else
                begin
                AWriter.SetMessageName(LMethod.ResponseMessageName, DefaultNamespace);
                end;
              // SOAP v1.1 rules : return value goes first
              if LMethod.ResultType <> '' then
                begin
                ProcessResult(LServerContext, AWriter, IdSoapGetTypeInfo(LResultType), LMethod, LAns);
                end;
              for LParamIndex := 0 to LMethod.Parameters.Count-1 do   // look for output param types
                begin
                ProcessOutParam(nil,nil,'',AWriter, LMethod.Parameters.Param[LParamIndex], LServerContext, LParamIndex, true);
                end;
              ProcessHeadersSend(LMethod, AWriter, LServerContext);
              end;
          finally
            FreeAndNil(LAsm);
           end;
        finally
          FreeAndNil(LServerContext);
        end;
      finally
        LServerObj._Release;
      end;
    except
      on e : EIdSoapSessionInvalid do
        begin
        // this is not thread safe, but not sure whether it needs to be, given what it does - set 2 booleans
        if assigned(LSession) then
          begin
          LSession.FClosed := true;
          LSession.FWantCallCloseEvent := true;
          end;
        raise;
        end;
    end;
  finally
    if Assigned(LSession) then
      begin
      ReleaseSession(LSession);
      end;
  end;

{$IFDEF ID_SOAP_SHOW_NODES}
  if assigned(AWriter) then
    begin
    ShowNode('Server Ret/Outs/Vars',LInterface.Name,LMethod.Name,AWriter.BaseNode);
    end;
{$ENDIF}
end;

function TIdSoapListener.CreateWriter(AReader: TIdSoapReader; var VEncodingTypeUsed : TIdSoapEncodingType): TIdSoapWriter;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.CreateWriter';
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self not valid');
  Assert(AReader.TestValid(TIdSoapReader),ASSERT_LOCATION+': AReader invalid');
  case EncodingType of
    etIdAutomatic :
      begin
      if AReader is TIdSoapReaderXML then
        begin
        result := TIdSoapWriterXML.create(AReader.SoapVersion, XMLProvider);
        if (AReader as TIdSoapReaderXML).XMLIsUTF16 then
          begin
          (result as TIdSoapWriterXML).UseUTF16 := true;
          VEncodingTypeUsed := etIdXmlUtf16;
          end
        else
          begin
          (result as TIdSoapWriterXML).UseUTF16 := false;
          VEncodingTypeUsed := etIdXmlUtf8;
          end;
        end
      else
        begin
        VEncodingTypeUsed := etIdBinary;
        result := TIdSoapWriterBin.create(AReader.SoapVersion, XMLProvider);
        end;
      end;
    etIdBinary:
      begin
      VEncodingTypeUsed := etIdBinary;
      result := TIdSoapWriterBin.create(AReader.SoapVersion, XMLProvider);
      end;
    etIdXmlUtf8 :
      begin
      VEncodingTypeUsed := etIdXmlUtf8;
      result := TIdSoapWriterXML.create(AReader.SoapVersion, XMLProvider);
      (result as TIdSoapWriterXML).UseUTF16 := false;
      end;
    etIdXmlUtf16 :
      begin
      VEncodingTypeUsed := etIdXmlUtf16;
      result := TIdSoapWriterXML.create(AReader.SoapVersion, XMLProvider);
      (result as TIdSoapWriterXML).UseUTF16 := true;
      end;
  else
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Encoding Type unknown ('+inttostr(ord(EncodingType))+')');
  end;
  result.SchemaInstanceNamespace := AReader.SchemaInstanceNamespace;
  Result.SchemaNamespace := AReader.SchemaNamespace;
  result.EncodingOptions := EncodingOptions;
end;

function TIdSoapListener.CreateFaultWriter(AEncodingType: TIdSoapEncodingType): TIdSoapFaultWriter;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.CreateFaultWriter';
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION + ': self not valid');
  case AEncodingType of
    etIdAutomatic :
      begin
      raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Encoding Type is Automatic, shouldn''t happen');
      end;
    etIdBinary :
      begin
      result := TIdSoapFaultWriterBin.create(GetWorkingSoapVersion, XMLProvider);
      end;
    etIdXmlUtf8 :
      begin
      result := TIdSoapFaultWriterXml.create(GetWorkingSoapVersion, XMLProvider);
      (result as TIdSoapFaultWriterXml).UseUTF16 := false;
      end;
    etIdXmlUtf16 :
      begin
      result := TIdSoapFaultWriterXml.create(GetWorkingSoapVersion, XMLProvider);
      (result as TIdSoapFaultWriterXml).UseUTF16 := true;
      end;
  else
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Encoding Type unknown ('+inttostr(ord(EncodingType))+')');
  end;
end;

procedure TIdSoapListener.Start;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.Start';
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION + ': self not valid');
  inherited;
  Assert(ITI.TestValid(TIdSoapITI), ASSERT_LOCATION + ': self not valid');
  ITI.ConstructServerReference(DefaultNamespace);
end;

procedure TIdSoapListener.CreateSession(ARequestInfo: TIdSoapRequestInformation; AIdentity: string; ASession: TObject; ACallEvent: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.CreateSession';
var
  LSession : TIdSoapServerSession;
  LGUID : TGUID;
  LIndex : integer;
  LHeader : TIdSoapHeader;
  LStr : TIdSoapString;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION + ': self not valid');
  Assert(SessionSettings.SessionPolicy <> sspNoSessions, ASSERT_LOCATION+': sessions cannot be used');

  LSession := TIdSoapServerSession.create;
  if AIdentity = '' then
    begin
    {$IFDEF LINUX}
    CreateGUID(LGUID);
    {$ELSE}
    CoCreateGuid(LGUID);
    {$ENDIF}
    AIdentity := GUIDToString(LGuid);
    end;
  LSession.FIdentity := AIdentity;
  LSession.FAppSession := ASession;
  if ACallEvent and (assigned(OnCreateSession)) then
    begin
    OnCreateSession(Self, AIdentity, LSession.FAppSession);
    end;
  if assigned(LSession.FAppSession) and (LSession.FAppSession is TIdSoapBaseApplicationSession) then
    begin
    (LSession.FAppSession as TIdSoapBaseApplicationSession).Identity := AIdentity;
    (LSession.FAppSession as TIdSoapBaseApplicationSession).LastRequest := Now;
    end;
  FSessionLock.Enter;
  try
    Assert(not FSessionList.Find(AIdentity, LIndex), ASSERT_LOCATION + ': Attempt to define a duplicate session "'+AIdentity+'"');
    FSessionList.AddObject(AIdentity, LSession);
  finally
    FSessionLock.Leave;
  end;
  if assigned(ARequestInfo) then
    begin
    if SessionSettings.SessionPolicy = sspSoapHeaders then
      begin
      LStr := TIdSoapString.create;
      LStr.Value := AIdentity;
      LHeader := TIdSoapHeader.CreateWithQName(ID_SOAP_DS_DEFAULT_ROOT, SessionSettings.SessionName, LStr);
      ARequestInfo.Writer.Headers.AddHeader(LHeader);
      end
    else
      begin
      ARequestInfo.CookieServices.SetCookie(SessionSettings.SessionName, AIdentity);
      end;
    end;
end;

procedure TIdSoapListener.CloseSession(AIdentity: string; ACallevent: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.CloseSession';
var
  LIndex : integer;
  LSession : TIdSoapServerSession;
  LCloseNow : boolean;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION + ': self not valid');
  Assert(AIdentity <> '', ASSERT_LOCATION+': Identity is blank');
  FSessionLock.Enter;
  try
    IdRequire(FSessionList.Find(AIdentity, LIndex), ASSERT_LOCATION + ': Attempt to close a non-existent session "'+AIdentity+'"');
    LSession := FSessionList.objects[LIndex] as TIdSoapServerSession;
    IdRequire(not LSession.FClosed, ASSERT_LOCATION + ': Attempt to close a closed session "'+AIdentity+'"');
    LSession.FClosed := True;
    LSession.FWantCallCloseEvent := true;
    if LSession.FUseCount = 0 then
      begin
      LCloseNow := true;
      FSessionList.Delete(LIndex);
      end
    else
      begin
      LCloseNow := false;
      end;
  finally
    FSessionLock.Leave;
  end;
  if LCloseNow then
    begin
    if ACallevent and assigned(OnCloseSession) then
      begin
      OnCloseSession(self, AIdentity, LSession.FAppSession);
      end;
    FreeAndNil(LSession);
    end;
end;

function TIdSoapListener.CheckForSession(AReader: TIdSoapReader; ACookieServices: TIdSoapAbstractCookieIntf): TIdSoapServerSession;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.CheckForSession';
var
  s : string;
  LIndex : integer;
  LWantInit : boolean;
  LHeader : TIdSoapHeader;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION + ': self not valid');
  Assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Reader not valid');
  Assert((ACookieServices = nil) or (ACookieServices.TestValid(TIdSoapAbstractCookieIntf)), ASSERT_LOCATION + ': CookieServices not valid');
  result := nil;
  LWantInit := false;

  if SessionSettings.SessionPolicy <> sspNoSessions then
    begin
    Assert(SessionSettings.SessionName <> '', ASSERT_LOCATION+': SessionName is blank');
    if SessionSettings.SessionPolicy = sspSoapHeaders then
      begin
      s := '';
      LHeader := AReader.Headers.Header[AReader.Headers.IndexOfQName[ID_SOAP_DS_DEFAULT_ROOT,SessionSettings.SessionName]];
      if assigned(LHeader) then
        begin
        s := (LHeader.Content as TIdSoapString).Value;
        end;
      end
    else
      begin
      Assert((ACookieServices.TestValid(TIdSoapAbstractCookieIntf)), ASSERT_LOCATION + ': CookieServices not valid');
      s := ACookieServices.GetCookie(SessionSettings.SessionName);
      end;
    if s <> '' then
      begin
      FSessionLock.Enter;
      try
        if FSessionList.Find(s, LIndex) then
          begin
          result := FSessionList.Objects[LIndex] as TIdSoapServerSession;
          if result.FClosed then
            begin
            result := nil; // don't see closed sessions - and AutoAcceptSessions is ignored in this case
            end
          else
            begin
            inc(result.FUseCount);
            if result.FAppSession is TIdSoapBaseApplicationSession then
              begin
              (result.FAppSession as TIdSoapBaseApplicationSession).LastRequest := Now;
              end;
            end;
          end
        else
          begin
          if SessionSettings.AutoAcceptSessions then
            begin
            result := TIdSoapServerSession.create;
            result.FIdentity := s;
            result.FAppSession := nil;
            inc(result.FUseCount);
            LWantInit := true;
            FSessionList.AddObject(s, result);
            end;
          end;
      finally
        FSessionLock.Leave;
      end;
      if LWantInit and assigned(OnCreateSession) then
        begin
        OnCreateSession(self, result.FIdentity, result.FAppSession);
        end;
      end;
    end;
  if assigned(result) then
    begin
    GIdSoapRequestInfo.Session := result.FAppSession;
    end
  else
    begin
    GIdSoapRequestInfo.Session := nil;
    end;

end;

procedure TIdSoapListener.ReleaseSession(ASession: TIdSoapServerSession);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.CheckForSession';
var
  LIndex : integer;
  FWantClose : boolean;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION + ': self not valid');
  Assert(ASession.TestValid(TIdSoapServerSession), ASSERT_LOCATION + ': self not valid');

  FSessionLock.Enter;
  try
    Assert(FSessionList.Find(ASession.FIdentity, LIndex), ASSERT_LOCATION + ': Session "'+ASession.FIdentity+'" not found');
    Assert(ASession.FUseCount > 0, ASSERT_LOCATION+': Session "'+ASession.FIdentity+'" not found');
    Dec(ASession.FUseCount);
    FWantClose := ASession.FClosed;
    if FWantClose then
      begin
      FSessionList.Delete(LIndex);
      end;
  finally
    FSessionLock.Leave;
  end;
  if FWantClose then
    begin
    if ASession.FWantCallCloseEvent and assigned(OnCloseSession) then
      begin
      OnCloseSession(self, ASession.FIdentity, ASession.FAppSession);
      end;
    FreeAndNil(ASession);
    end;
end;

procedure TIdSoapListener.ProcessHeadersRecv(AMethod: TIdSoapITIMethod; AReader: TIdSoapReader; AServerContext: TIdSoapServerRequestContext);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessHeadersRecv';
var
  i, j : integer;
  LHeaderParam : TIdSoapITIParameter;
  LHeader : TIdSoapHeader;
  AData : pointer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': AMethod is not valid');
  Assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': AReader is not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': AServerContext is not valid');

  for i := 0 to AMethod.Headers.Count - 1 do
    begin
    LHeaderParam := AMethod.Headers.Param[i];
    j := AReader.Headers.IndexOfQName[AReader.MessageNameSpace, AMethod.ReplaceName(LHeaderParam.Name)];
    if j = -1 then
      begin
      j := AReader.Headers.IndexOfName[LHeaderParam.Name];
      end;
    if j > -1 then
      begin
      LHeader := AReader.Headers.Header[j];
      LHeader.Content.Free; // because we are going to replace it
      LHeader.Processed := true;
      AData := nil;
      LHeader.PascalName := LHeaderParam.Name;
      ProcessParameter(LHeader.Node, LHeaderParam.Name, AData, LHeaderParam.TypeInformation, AReader, nil, LHeaderParam, AServerContext, 0, true);
      LHeader.Content := TIdBaseSoapableClass(AData);
      end;
    end;
  AReader.CheckMustUnderstand;
end;

procedure TIdSoapListener.ProcessHeadersSend(AMethod: TIdSoapITIMethod; AWriter: TIdSoapWriter; AServerContext: TIdSoapServerRequestContext);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapListener.ProcessHeadersSend';
var
  i, j : integer;
  LHeaderParam : TIdSoapITIParameter;
  LHeader : TIdSoapHeader;
  AData : pointer;
begin
  Assert(self.TestValid(TIdSoapListener), ASSERT_LOCATION+': self is not valid');
  Assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': AMethod is not valid');
  Assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': AReader is not valid');
  Assert(AServerContext.TestValid(TIdSoapServerRequestContext), ASSERT_LOCATION+': AServerContext is not valid');

  for i := 0 to AMethod.RespHeaders.Count - 1 do
    begin
    LHeaderParam := AMethod.RespHeaders.Param[i];
    j := AWriter.Headers.IndexOfName[LHeaderParam.Name];
    if j > -1 then
      begin
      LHeader := AWriter.Headers.Header[j];
      LHeader.Namespace := AWriter.MessageNameSpace;
      LHeader.Name := AMethod.ReplaceName(LHeaderParam.Name);

      // on the client we have to free the Node first, but on the server, the concept of
      // resending the same header doesn't arise
      LHeader.Node := TIdSoapNode.Create(ID_SOAP_NULL_NODE_NAME, ID_SOAP_NULL_NODE_TYPE, '', False, NIL, AWriter);
      AWriter.StructNodeAdded(LHeader.node);
      AData := @LHeader.Content;
      ProcessOutParam(AData, LHeader.Node, LHeader.Name, AWriter, LHeaderParam, AServerContext, 0, true);
      end;
    end;
end;

{ TIdSoapServer }

function TIdSoapServer.HandleSoapRequest(AInMimeType: String; ACookieServices : TIdSoapAbstractCookieIntf; ARequest, AResponse: TStream; var VOutMimeType : string): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapServer.HandleSoapRequest';
var
  LReader: TIdSoapReader;
  LWriter: TIdSoapWriter;
  LFault: TIdSoapFaultWriter;
  LEncodingType : TIdSoapEncodingType;
begin
  Assert(self.TestValid(TIdSoapServer), ASSERT_LOCATION+': self not valid');
  IdRequire(Active, ASSERT_LOCATION+': not currently active');
  // no requirements for AInMimeType - can be null and we will just have to try to recognise the packet
  Assert(Assigned(ARequest), ASSERT_LOCATION+': ARequest not valid');
  Assert(Assigned(AResponse), ASSERT_LOCATION+': AResponse not valid in Request/Response Mode');
  Assert(Assigned(GIdSoapRequestInfo), ASSERT_LOCATION+': GIdSoapRequestInfo is not valid');
  VOutMimeType := '';


  // these in case we fail before we can determine what the user was sending us
  if EncodingType = etIdAutomatic then
    begin
    LEncodingType := etIdXmlUtf8;
    end
  else
    begin
    LEncodingType := EncodingType;
    end;

  try
    DoReceiveMessage(ARequest);
    LReader := CreatePacketReader(AInMimeType, ARequest, GetWorkingSoapVersion, XMLProvider);
    try
      LReader.EncodingOptions := EncodingOptions;
      LReader.ReadMessage(ARequest, AInMimeType, OnReceiveMessageDom, Self);
      LReader.CheckPacketOK; {includes checking versions etc}
      LReader.ProcessHeaders;
      LReader.PreDecode;
      LWriter := CreateWriter(LReader, LEncodingType);
      try
        GIdSoapRequestInfo.Reader := LReader;
        GIdSoapRequestInfo.Writer := LWriter;
        GIdSoapRequestInfo.Server := self;
        try
          ExecuteSoapCall(LReader, ACookieServices, LWriter);
          LWriter.Encode(AResponse, VOutMimeType, OnSendMessageDom, self);
        finally
          GIdSoapRequestInfo.Reader := nil;
          GIdSoapRequestInfo.Writer := nil;
        end;
      finally
        FreeAndNil(LWriter);
        end;
      DoSendMessage(AResponse);
    finally
      GIdSoapRequestInfo.Reader := nil;
      FreeAndNil(LReader);
      end;
    Result := True;
  except
    on e: Exception do
      begin
      Result := False;
      LFault := CreateFaultWriter(LEncodingType);
      try
        AResponse.Size := 0; // reset the stream
        LFault.DefineException(e);
        LFault.Encode(AResponse, VOutMimeType, OnSendExceptionDom, self);
      finally
        FreeAndNil(LFault);
      end;
      end;
  end;
end;

{ TIdSoapMsgReceiver }

procedure TIdSoapMsgReceiver.HandleSoapMessage(AInMimeType: String; ARequest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMsgReceiver.HandleSoapMessage';
var
  LReader: TIdSoapReader;
begin
  Assert(self.TestValid(TIdSoapMsgReceiver), ASSERT_LOCATION+': self not valid');
  IdRequire(Active, ASSERT_LOCATION+': not currently active');
  // no requirements for AInMimeType - can be null and we will just have to try to recognise the packet
  Assert(Assigned(ARequest), ASSERT_LOCATION+': ARequest not valid');
  Assert(Assigned(GIdSoapRequestInfo), ASSERT_LOCATION+': GIdSoapRequestInfo is not valid');
  try
    DoReceiveMessage(ARequest);
    LReader := CreatePacketReader(AInMimeType, ARequest, GetWorkingSoapVersion, XMLProvider);
    try
      LReader.EncodingOptions := EncodingOptions;
      LReader.ReadMessage(ARequest, AInMimeType, OnReceiveMessageDom, self);
      LReader.CheckPacketOK; {includes checking versions etc}
      LReader.ProcessHeaders;
      LReader.PreDecode;
      GIdSoapRequestInfo.Reader := LReader;
      GIdSoapRequestInfo.Server := self;
      ExecuteSoapCall(LReader, nil, nil);
    finally
      GIdSoapRequestInfo.Reader := nil;
      FreeAndNil(LReader);
    end;
  except
    on e: Exception do
      begin
      if assigned(FOnException) then
        begin
        FOnException(self, e);
        end
      // else
      //  well, what else can we do?
      //  the exception is suppressed
      end;
  end;
end;

{ TIdSoapServerSession }

constructor TIdSoapServerSession.create;
begin
  inherited;
  FAppSession := nil;
  FUseCount := 0;
end;

end.

