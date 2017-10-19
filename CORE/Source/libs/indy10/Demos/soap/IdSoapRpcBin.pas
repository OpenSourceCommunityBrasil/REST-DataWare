{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15762: IdSoapRpcBin.pas 
{
{   Rev 1.2    20/6/2003 00:03:52  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:03:32  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:35:50  GGrieve
}
{
IndySOAP: Binary Packet encoding

This is a custom implementation intended to make the RPC
layer work as fast as possible. It should be mixed with
TCP rather than HTTP to make the system work as absolutely
fast as possible. You must have IndySOAP at both ends to
use this encoding layer.

The protocol may be overhauled at any time, and no attempt will
be made to provide backward compatibility. You need to be able
to upgrade both clients and server at the same time

This packet encoding scheme does not check the namespaces of
types. it is assumed that the user will ensure that there is
simple name compatibility between client and server

Protocol description in doco

}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Header support
  18-Mar 2003   Grahame Grieve                  QName and RawXML support
  29-Oct 2002   Grahame Grieve                  Improved Exception handling, IdSoapSimpleClass System
  04-Oct 2002   Grahame Grieve                  Attachments
  26-Sep 2002   Grahame Grieve                  Header Support
  17-Sep 2002   Grahame Grieve                  HexBinary support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit issues fixed
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  24-Jul 2002   Grahame Grieve                  Restructure Packet handlers to change Namespace Policy
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  18-Jul 2002   Grahame Grieve                  Better control over Mime Types
  17-Jul 2002   Andrew Cumming                  Removed 3 warnings
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Remove Hints and Warnings
  08-Apr 2002   Grahame Grieve                  Support for Objects by Reference
  06-Apr 2002   Andrew Cumming                  Name change for NanoSeconds
  05-Apr 2002   Grahame Grieve                  Remove Hints and warnings
  05-Apr 2002   Grahame Grieve                  Fix for TIdSoapDateTime as class
  04-Apr 2002   Grahame Grieve                  Change to the way message names and namespaces are resolved + Mimetype support
  03-Apr 2002   Grahame Grieve                  Change to Packet writer interface - no difference between request and response
  02-Apr 2002   Grahame Grieve                  Date Time Support
  26-Mar 2002   Grahame Grieve                  Rename Constants, remodel array handling
  22-Mar 2002   Andrew Cumming                  Changed to new IdSoapAdjustLineBreaks for D4/D5
  22-Mar 2002   Grahame Grieve                  Change Node handling to differentiate between arrays, elements, and structs
  18-Mar 2002   Andrew Cumming                  Fixed AdjustLineBreaks for D4/D5 compatibility
  14-Mar 2002   Grahame Grieve                  Support for seoCheckStrings
  14-Mar 2002   Andrew Cumming                  Fixed 2 GP's caused by ref to an empty string
  14-Mar 2002   Grahame Grieve                  Namespace Support, CRLF handling,
  12-Mar 2002   Grahame Grieve                  Binary support (TStream)
   7-Mar 2002   Grahame Grieve                  Review assertions
   3-Mar 2002   Andrew Cumming                  Code for SETs implementation
   3-Mar 2002   Grahame Grieve                  Namespace support
   7-Feb 2002   Andrew Cumming                  D4 compatibility
   7-Feb 2002   Grahame Grieve                  First Release
}


unit IdSoapRpcBin;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapComponent,
  IdSoapDateTime,
  IdSoapDebug,
  IdSoapITI,
  IdSoapRpcPacket,
  IdSoapTypeRegistry,
  IdSoapXML,
  TypInfo;

const
  CURRENT_BINARY_VERSION = 1;


type
  TIdSoapReaderBin = class(TIdSoapReader)
  Private
    FStream: TMemoryStream;
    FNamespaces : TStringList;
    procedure DecodeException;
    procedure ReadParam(ANode: TIdSoapNode);
    procedure ReadNode(ANode: TIdSoapNode; ARefID : integer = 0);
    procedure DecodeNode(ANode: TIdSoapNode);
    procedure DecodeReferredObjects;
    procedure ReadAttachments;
    function GetParamPosition(ANode : TIdSoapNode; const AName : string):integer;
  Protected
    function GetParamBinaryBase64(ANode: TIdSoapNode; const AName: string): TStream; Override;
    function GetParamBinaryHex(ANode: TIdSoapNode; const AName: string): THexStream; Override;
    function GetParamBoolean(ANode: TIdSoapNode; const AName: String): Boolean; Override;
    function GetParamByte(ANode: TIdSoapNode; const AName: String): Byte; Override;
    function GetParamCardinal(ANode: TIdSoapNode; const AName: String): Cardinal; Override;
    function GetParamChar(ANode: TIdSoapNode; const AName: String): Char; Override;
    function GetParamComp(ANode: TIdSoapNode; const AName: String): Comp; Override;
    function GetParamCurrency(ANode: TIdSoapNode; const AName: String): Currency; Override;
    function GetParamDateTime(ANode: TIdSoapNode; const AName: String): TDateTime; Override;
    function GetParamDouble(ANode: TIdSoapNode; const AName: String): Double; Override;
    function GetParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject): Integer; Override;
    function GetParamExists(ANode: TIdSoapNode; const AName: String): boolean; override;
    function GetParamExtended(ANode: TIdSoapNode; const AName: String): Extended; Override;
    function GetParamInt64(ANode: TIdSoapNode; const AName: String): Int64; Override;
    function GetParamInteger(ANode: TIdSoapNode; const AName: String): Integer; Override;
    function GetParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo): Integer; Override;
    function GetParamShortInt(ANode: TIdSoapNode; const AName: String): ShortInt; Override;
    function GetParamShortString(ANode: TIdSoapNode; const AName: String): ShortString; Override;
    function GetParamSingle(ANode: TIdSoapNode; const AName: String): Single; Override;
    function GetParamSmallInt(ANode: TIdSoapNode; const AName: String): SmallInt; Override;
    function GetParamString(ANode: TIdSoapNode; const AName: String): String; Override;
    function GetParamWideChar(ANode: TIdSoapNode; const AName: String): WideChar; Override;
    function GetParamWideString(ANode: TIdSoapNode; const AName: String): WideString; Override;
    function GetParamWord(ANode: TIdSoapNode; const AName: String): Word; Override;
  Public
    constructor Create(Const ASoapVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider); Override;
    destructor Destroy; Override;
    procedure ReadMessage(ASoapPacket: TStream; AMimeType : string; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent); override;
    procedure CheckPacketOK; override;
    procedure ProcessHeaders; override;
    procedure PreDecode; override;
    procedure DecodeMessage; override;
    function GetGeneralParam(ANode: TIdSoapNode; const AName : string; Var VNil: boolean; var VValue, VTypeNS, VType : string):boolean; override;
    function ResolveNamespace(ANode: TIdSoapNode; const AName, ANamespace : string):String; override;
    function GetXMLElement(ANode : TIdSoapNode; AName : string; var VOwnsDom : boolean;
                                          var VDom : TIdSoapXMLDom; var VElem : TIdSoapXMLElement;
                                          var VTypeNS, VType : String):Boolean;  Override;
  end;

  TIdSoapWriterBin = class(TIdSoapWriter)
  Private
    FNamespaces : TStringList;
    procedure WriteNode(AStream: TStream; ANode: TIdSoapNode);
    procedure WriteHeaders(AStream : TStream);
    procedure WriteAttachments(AStream : TStream);
    function GetMimeType: string;
  Public
    constructor Create(Const ASoapVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider); Override;
    destructor Destroy; Override;
    procedure StructNodeAdded(ANode : TIdSoapNode); override;
    procedure Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent); Override;
    function  AddArray(ANode: TIdSoapNode; const AName, ABaseType, ABaseTypeNS: String; ABaseTypeComplex : boolean): TIdSoapNode; Override;
    function  DefineNamespace(ANamespace : string):String; Override;
    procedure DefineGeneralParam(ANode: TIdSoapNode; ANil : boolean; AName, AValue, ATypeNS, AType : string); override;
    procedure DefineParamBinaryBase64(ANode: TIdSoapNode; const AName: string; AStream : TStream); Override;
    procedure DefineParamBinaryHex(ANode: TIdSoapNode; const AName: string; AStream : THexStream); Override;
    procedure DefineParamBoolean(ANode: TIdSoapNode; const AName: String; AValue: Boolean); Override;
    procedure DefineParamByte(ANode: TIdSoapNode; const AName: String; AValue: Byte); Override;
    procedure DefineParamCardinal(ANode: TIdSoapNode; const AName: String; AValue: Cardinal); Override;
    procedure DefineParamChar(ANode: TIdSoapNode; const AName: String; AValue: Char); Override;
    procedure DefineParamComp(ANode: TIdSoapNode; const AName: String; AValue: Comp); Override;
    procedure DefineParamCurrency(ANode: TIdSoapNode; const AName: String; AValue: Currency); Override;
    procedure DefineParamDateTime(ANode: TIdSoapNode; const AName: String; AValue: TDateTime); Override;
    procedure DefineParamDouble(ANode: TIdSoapNode; const AName: String; AValue: Double); Override;
    procedure DefineParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject; AValue: Integer); Override;
    procedure DefineParamExtended(ANode: TIdSoapNode; const AName: String; AValue: Extended); Override;
    procedure DefineParamInt64(ANode: TIdSoapNode; const AName: String; AValue: Int64); Override;
    procedure DefineParamInteger(ANode: TIdSoapNode; const AName: String; AValue: Integer); Override;
    procedure DefineParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo; AValue: Integer); Override;
    procedure DefineParamShortInt(ANode: TIdSoapNode; const AName: String; AValue: ShortInt); Override;
    procedure DefineParamShortString(ANode: TIdSoapNode; const AName: String; AValue: ShortString); Override;
    procedure DefineParamSingle(ANode: TIdSoapNode; const AName: String; AValue: Single); Override;
    procedure DefineParamSmallInt(ANode: TIdSoapNode; const AName: String; AValue: SmallInt); Override;
    procedure DefineParamString(ANode: TIdSoapNode; const AName, AValue: String); Override;
    procedure DefineParamWideChar(ANode: TIdSoapNode; const AName: String; AValue: WideChar); Override;
    procedure DefineParamWideString(ANode: TIdSoapNode; const AName: String; const AValue: WideString); Override;
    procedure DefineParamWord(ANode: TIdSoapNode; const AName: String; AValue: Word); Override;
    procedure DefineParamXML(ANode: TIdSoapNode; AName : string; AXml : TIdSoapXmlElement; ATypeNamespace, ATypeName : string); Override;
  end;

  TIdSoapFaultWriterBin = class(TIdSoapFaultWriter)
  private
    function GetMimeType:String;
  protected
    procedure WriteHeaders(AStream : TStream);
  Public
    procedure Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent); Override;
  end;

implementation

uses
  IdGlobal,
  IdSoapConsts,
  IdSoapDime,
  IdSoapExceptions,
  IdSoapResourceStrings,
  IdSoapUtilities,
  SysUtils;

const
  ASSERT_UNIT = 'IdSoapRpcBin';
  ID_SOAP_BIN_IDDATETIME_SIZE = (sizeof(Word) * 8)+ sizeof(Cardinal)+sizeof(TIdSoapTimeZoneInfo);
  ID_SOAP_BIN_IDTIME_SIZE = (sizeof(Word) * 5)+ sizeof(Cardinal)+sizeof(TIdSoapTimeZoneInfo);
  ID_SOAP_BIN_IDDATE_SIZE = (sizeof(Word) * 5)+ sizeof(TIdSoapTimeZoneInfo);

{ do not localize any of these: }
function DescribeParamType(AType : Byte):String;
const ASSERT_LOCATION = ASSERT_UNIT+'.DescribeParamType';
begin
  Case AType of
    ID_SOAP_BIN_TYPE_BOOLEAN : result := 'Boolean';
    ID_SOAP_BIN_TYPE_BYTE : result := 'Byte';
    ID_SOAP_BIN_TYPE_CARDINAL : result := 'Cardinal';
    ID_SOAP_BIN_TYPE_CHAR : result := 'Char';
    ID_SOAP_BIN_TYPE_COMP : result := 'Comp';
    ID_SOAP_BIN_TYPE_CURRENCY : result := 'Currency';
    ID_SOAP_BIN_TYPE_DOUBLE : result := 'Double';
    ID_SOAP_BIN_TYPE_ENUM : result := 'Enum';
    ID_SOAP_BIN_TYPE_EXTENDED : result := 'Extended';
    ID_SOAP_BIN_TYPE_INT64 : result := 'Int64';
    ID_SOAP_BIN_TYPE_INTEGER : result := 'Integer';
    ID_SOAP_BIN_TYPE_SHORTINT : result := 'ShortInt';
    ID_SOAP_BIN_TYPE_SHORTSTRING : result := 'ShortString';
    ID_SOAP_BIN_TYPE_SINGLE : result := 'Single';
    ID_SOAP_BIN_TYPE_SMALLINT : result := 'SmallInt';
    ID_SOAP_BIN_TYPE_STRING : result := 'String';
    ID_SOAP_BIN_TYPE_WIDECHAR : result := 'WideChar';
    ID_SOAP_BIN_TYPE_WIDESTRING : result := 'WideString';
    ID_SOAP_BIN_TYPE_WORD : result := 'Word';
    ID_SOAP_BIN_TYPE_SET : result := 'Set';
    ID_SOAP_BIN_TYPE_BINARY : result := 'Binary';
    ID_SOAP_BIN_TYPE_XML : result := 'XML';
    ID_SOAP_BIN_TYPE_DATETIME : result := 'DateTime';
    ID_SOAP_BIN_TYPE_DATETIME_NULL : result := 'DateTime (Null)';
    ID_SOAP_BIN_TYPE_GENERAL : result := 'SpecialClass';
  else
    result := 'Unknown type '+inttostr(AType);
  end;
end;

{ TIdSoapReaderBin }

constructor TIdSoapReaderBin.Create(Const ASoapVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.Create';
begin
  inherited;
  FStream := TMemoryStream.Create;
  BaseNode.Params.OwnsObjects := false;
  FNamespaces := TStringList.create;
  FNamespaces.sorted := false; { index is identifier }
end;

destructor TIdSoapReaderBin.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.Destroy';
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FNamespaces);
  FreeAndNil(FStream);
  inherited;
end;

procedure TIdSoapReaderBin.DecodeException;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.DecodeException';
var
  LClass : String;
  LMessage: WideString;
  LException : Exception;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  Assert(Assigned(FStream), ASSERT_LOCATION+': FStream is nil');

  LClass := StreamReadShortString(FStream);
  SetLength(LMessage, StreamReadCardinal(FStream));
  StreamReadBinary(FStream, @LMessage[1], Length(LMessage) * 2);
  LException := GenerateSOAPException('', LClass, LMessage);
  if LException = nil then
    begin
    LException := EIdSoapFault.create(LMessage, RS_MSG_SERVER_ERROR, '', LMessage, ''); 
    end;
  raise LException;
end;

procedure TIdSoapReaderBin.ReadParam(ANode: TIdSoapNode);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.ReadParam';
var
  LParamType : Byte;
  LObjType : Byte;
  LName : ShortString;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is nil');
  Assert(Assigned(ANode), ASSERT_LOCATION+': Node is nil');
  Assert(Assigned(FStream), ASSERT_LOCATION+': FStream is nil');
  LName := StreamReadShortString(FStream);
  Assert(LName <> '', ASSERT_LOCATION+': Name is nil');
  ANode.Params.AddObject(LName, TObject(FStream.Position)); // which is a pointer to the type
  LParamType := StreamReadByte(FStream);
  case LParamType of
    ID_SOAP_BIN_TYPE_BOOLEAN        : StreamSkip(FStream, Sizeof(Boolean));
    ID_SOAP_BIN_TYPE_BYTE           : StreamSkip(FStream, Sizeof(Byte));
    ID_SOAP_BIN_TYPE_CARDINAL       : StreamSkip(FStream, Sizeof(Cardinal));
    ID_SOAP_BIN_TYPE_CHAR           : StreamSkip(FStream, Sizeof(Char));
    ID_SOAP_BIN_TYPE_COMP           : StreamSkip(FStream, Sizeof(Comp));
    ID_SOAP_BIN_TYPE_CURRENCY       : StreamSkip(FStream, Sizeof(Currency));
    ID_SOAP_BIN_TYPE_DATETIME       : StreamSkip(FStream, Sizeof(TDateTime));
    ID_SOAP_BIN_TYPE_DATETIME_NULL  : ; // nothing
    ID_SOAP_BIN_TYPE_DOUBLE         : StreamSkip(FStream, Sizeof(Double));
    ID_SOAP_BIN_TYPE_EXTENDED       : StreamSkip(FStream, Sizeof(Extended));
    ID_SOAP_BIN_TYPE_INT64          : StreamSkip(FStream, Sizeof(Int64));
    ID_SOAP_BIN_TYPE_INTEGER        : StreamSkip(FStream, Sizeof(Integer));
    ID_SOAP_BIN_TYPE_SHORTINT       : StreamSkip(FStream, Sizeof(ShortInt));
    ID_SOAP_BIN_TYPE_SHORTSTRING    : StreamSkip(FStream, StreamReadByte(FStream));
    ID_SOAP_BIN_TYPE_SINGLE         : StreamSkip(FStream, Sizeof(Single));
    ID_SOAP_BIN_TYPE_SMALLINT       : StreamSkip(FStream, Sizeof(SmallInt));
    ID_SOAP_BIN_TYPE_STRING         : StreamSkip(FStream, StreamReadCardinal(FStream));
    ID_SOAP_BIN_TYPE_WIDECHAR       : StreamSkip(FStream, Sizeof(WideChar));
    ID_SOAP_BIN_TYPE_WIDESTRING     : StreamSkip(FStream, StreamReadCardinal(FStream) * 2);
    ID_SOAP_BIN_TYPE_WORD           : StreamSkip(FStream, Sizeof(Word));
    ID_SOAP_BIN_TYPE_SET            : StreamSkip(FStream, Sizeof(Integer));
    ID_SOAP_BIN_TYPE_ENUM :
      begin
      StreamReadShortString(FStream);
      StreamReadShortString(FStream);
      StreamSkip(FStream, Sizeof(Cardinal));
      end;
    ID_SOAP_BIN_TYPE_GENERAL :
      begin
      StreamReadByte(FStream);
      StreamReadLongString(FStream);
      StreamReadLongString(FStream);
      StreamReadLongString(FStream);
      end;
    ID_SOAP_BIN_TYPE_BINARY :
      begin
      LObjType := StreamReadByte(FStream);
      case LObjType of
        ID_SOAP_BIN_CLASS_NIL : ; // nothing more in stream for nil streams
        ID_SOAP_BIN_CLASS_NOT_NIL : StreamSkip(FStream, StreamReadCardinal(FStream));
      else
        Raise EIdSoapBadBinaryFormat.create(ASSERT_LOCATION+': '+Format(RS_ERR_BIN_UNKNOWN_TYPE, [inttostr(LObjType)]));
      end;
      end;
    ID_SOAP_BIN_TYPE_XML :
      begin
      StreamReadLongString(FStream);
      StreamReadLongString(FStream);
      StreamSkip(FStream, StreamReadCardinal(FStream));
      end;
  else
    raise EIdSoapBadBinaryFormat.Create(ASSERT_LOCATION+'(2): '+Format(RS_ERR_BIN_UNKNOWN_TYPE, [IntToStr(LParamType)]));
  end;
end;

procedure TIdSoapReaderBin.ReadNode(ANode: TIdSoapNode; ARefID : integer = 0);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.ReadNode';
var
  LClass : ShortString;
  LClassNS : Shortstring;
  LNode : TIdSoapNode;
  LNodeType : Integer;
  LName : ShortString;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is nil');
  Assert(Assigned(ANode) or (ARefID <> 0), ASSERT_LOCATION+': Node is nil and RefID = 0');
  Assert(Assigned(FStream), ASSERT_LOCATION+': FStream is nil');
  LName := StreamReadShortString(FStream);
  LNodeType := StreamReadByte(FStream);
  case LNodeType of
    ID_SOAP_BIN_NODE_STRUCT:
      begin
      LClass := StreamReadShortString(FStream);
      LClassNS := StreamReadShortString(FStream);
      LNode := TIdSoapNode.create(LName, LClass, LClassNS, false, ANode, self);
      LNode.Params.OwnsObjects := false;
      end;
    ID_SOAP_BIN_NODE_ARRAY:
      begin
      LClass := StreamReadShortString(FStream);
      LClassNS := StreamReadShortString(FStream);
      LNode := TIdSoapNode.create(LName, LClass, LClassNS, true, ANode, self);
      LNode.Params.OwnsObjects := false;
      end;
    ID_SOAP_BIN_NODE_REFERENCE:
      begin
      LClass := StreamReadShortString(FStream);
      LClassNS := StreamReadShortString(FStream);
      LNode := TIdSoapNode.create(LName, LClass, LClassNS, false, ANode, self);
      LNode.Params.OwnsObjects := false;
      LNode.ReadingReferenceId := StreamReadCardinal(FStream);
      Assert(LNode.ReadingReferenceId <> 0, ASSERT_LOCATION+': Node is a reference but reference is 0');
      end;
  else
    raise EIdSoapBadBinaryFormat.Create(ASSERT_LOCATION+': Unknown Node Type (' + IntToStr(LNodeType) + ')');
  end;
  if Assigned(ANode) then
    begin
    Assert(ANode.Children.IndexOfName(LName) = -1, ASSERT_LOCATION+': Name "'+LName+'" used more than once in Packet');
    ANode.Children.AddObject(LName, LNode);
    if LNodeType <> ID_SOAP_BIN_NODE_REFERENCE then
      begin
      DecodeNode(LNode);
      end
    else
      begin
      StreamReadByte(FStream); // read the eon marker
      end
    end
  else
    begin
    ObjectReferences.AsObj[ARefID] := LNode;
    Assert(LNodeType <> ID_SOAP_BIN_NODE_REFERENCE, ASSERT_LOCATION+' (not Assigned(ANode)) and (LNodeType <> ID_SOAP_BIN_NODE_REFERENCE)');
    DecodeNode(LNode);
    end;
end;

procedure TIdSoapReaderBin.DecodeNode(ANode: TIdSoapNode);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.DecodeNode';
var
  LItemType: Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is nil');
  Assert(Assigned(ANode), ASSERT_LOCATION+': Node is nil');
  Assert(Assigned(FStream), ASSERT_LOCATION+': FStream is nil');
{
A Node looks like this:
String  | String | (Byte  | Param )n | (Byte  | Node )n    | Byte
Name    | Class  | (#1    | Params)n | (#2    | Children)n | #0

we have already read String and Class, so we are about to read the Parameters
}
  repeat
    LItemType := StreamReadByte(FStream);
    case LItemType of
      ID_SOAP_BIN_NOTVALID:; // well, that's OK then
      ID_SOAP_BIN_TYPE_PARAM: ReadParam(ANode);
      ID_SOAP_BIN_TYPE_NODE : ReadNode(ANode);
    else
      raise EIdSoapBadBinaryFormat.Create(ASSERT_LOCATION+': '+Format(RS_ERR_BIN_UNKNOWN_TYPE, [IntToStr(LItemType)]));
    end;
  until LItemType = ID_SOAP_BIN_NOTVALID;
end;

procedure TIdSoapReaderBin.DecodeReferredObjects;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.DecodeReferredObjects';
var
  i : integer;
  LRefID : integer;
  LCount : integer;
begin
  LCount := StreamReadCardinal(FStream);
  Assert(LCount = FStream.Position - 4, 'Stream should be at '+inttostr(LCOunt+4)+', but is at '+inttostr(FStream.Position));
  LCount := StreamReadCardinal(FStream);
  for i := 1 to LCount do
    begin
    LRefID := StreamReadCardinal(FStream);
    ReadNode(nil, LRefID);
    end;
end;

procedure TIdSoapReaderBin.ReadMessage(ASoapPacket: TStream; AMimeType : string; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.ReadMessage';
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is nil');
  Assert(Assigned(ASoapPacket), ASSERT_LOCATION+': SoapPacket is nil');
  Assert(Assigned(FStream), ASSERT_LOCATION+': FStream is nil');

  FirstEntityName := ID_SOAP_NAME_RESULT; // cause we know that it's IndySoap at the other end

  // we make a copy of the SOAP packet as we are not able to guarantee that
  // the memory exists after this call. We will just keep pointers into this
  // memory
  FStream.CopyFrom(ASoapPacket, ASoapPacket.Size);
  FStream.Position := 0;
end;

procedure TIdSoapReaderBin.CheckPacketOK;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.CheckPacketOK';
var
  LVer : byte;
begin
  IdRequire(StreamReadCardinal(FStream) = ID_SOAP_BIN_MAGIC, ASSERT_LOCATION+': '+RS_ERR_BIN_BAD_PACKET);
  LVer := StreamReadByte(FStream);
  IdRequire(LVer = CURRENT_BINARY_VERSION, ASSERT_LOCATION+': '+Format(RS_ERR_BIN_BAD_PACKET_VERSION, [inttostr(LVer),inttostr(CURRENT_BINARY_VERSION)]));
end;

procedure TIdSoapReaderBin.ProcessHeaders;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.ProcessHeaders';
var
  i, t : integer;
  LHeader : TIdSoapHeader;
  LName : string;
  LPName : string;
  LNs : String;
  LReq : boolean;
  LStr : TIdSoapString;
  LNode : TIdSoapNode;
begin
  Assert(Self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': self is not valid');

  Headers.Clear;
  t := StreamReadCardinal(FStream);
  for i := 0 to t - 1 do
    begin
    LName := StreamReadLongString(FStream);
    LNs := StreamReadLongString(FStream);
    LPName := StreamReadLongString(FStream);
    LReq := StreamReadByte(FStream) = 1;
    LStr := TIdSoapString.create;
    LHeader := TIdSoapHeader.CreateWithQName(LNs, LName, LStr);
    Headers.Add(LHeader);
    LHeader.MustUnderstand := LReq;
    LHeader.PascalName := LPName;
    if StreamReadByte(FStream) = 1 then
      begin
      LStr.Value := StreamReadLongString(FStream);
      end;
    if StreamReadByte(FStream) = 1 then
      begin
      LNode := TIdSoapNode.Create(ID_SOAP_NULL_NODE_NAME, ID_SOAP_NULL_NODE_TYPE, '', False, NIL, self);
      ReadNode(LNode);
      Assert(LNode.Children.count = 1, ASSERT_LOCATION+': Child count is wrong');
      LHeader.Node := LNode.Children.Objects[0] as TIdSoapNode;
      LNode.FreeNoChildren := true;
      FreeAndNil(LNode);

      end;
    end;
end;

procedure TIdSoapReaderBin.PreDecode;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.PreDecode';
var
  LPacketType: Byte;
  LNamespace : string;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is nil');
  Assert(Assigned(FStream), ASSERT_LOCATION+': FStream is nil');
  FPreDecoded := true;

  LPacketType := StreamReadByte(FStream);
  if LPacketType = ID_SOAP_BIN_PACKET_EXCEPTION then
    begin
    DecodeException;
    end
  else if LPacketType <> ID_SOAP_BIN_PACKET_MESSAGE then
    begin
    raise EIdSoapRequirementFail.Create(ASSERT_LOCATION+': '+Format(RS_ERR_BIN_UNKNOWN_TYPE, [inttostr(LPacketType)]));
    end
  else
    begin
    SetLength(LNamespace, StreamReadCardinal(FStream));
    StreamReadBinary(FStream, @LNamespace[1], length(LNameSpace));
    MessageNameSpace := LNamespace;
    MessageName := StreamReadShortString(FStream);
    end;
end;

procedure TIdSoapReaderBin.DecodeMessage;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.DecodeMessage';
var
  LTotal, LCount : integer;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is nil');
  Assert(Assigned(FStream), ASSERT_LOCATION+': FStream is nil');
  if not FPreDecoded then
    begin
    PreDecode;
    end;

  IdRequire(StreamReadByte(FStream) = ID_SOAP_BIN_TYPE_NODE, ASSERT_LOCATION+': Encountered a Bad Stream (No node when Node expected)');
  IdRequire(StreamReadShortString(FStream) = ID_SOAP_NULL_NODE_NAME, ASSERT_LOCATION+': Encountered a Bad Stream (First Node Name Wrong)');
  DecodeNode(BaseNode);
  DecodeReferredObjects;
  ReadAttachments;
  IdRequire(StreamReadByte(FStream) = ID_SOAP_BIN_NOTVALID, ASSERT_LOCATION+': Encountered a Bad Stream (Termination wrong)');
  FinishReading;
  LTotal := StreamReadWord(FStream);
  for LCount := 0 to LTotal - 1 do
    begin
    FNamespaces.Add(StreamReadLongString(FStream));
    end;
end;

function TIdSoapReaderBin.GetParamExists(ANode: TIdSoapNode; const AName: String): boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamExists';
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = nil then
    begin
    ANode := BaseNode;
    end;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode wrong owner');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  result := ANode.Params.IndexOf(AName) > -1;
end;

function TIdSoapReaderBin.GetParamPosition(ANode: TIdSoapNode; const AName: string): integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamPosition';
var
  I : integer;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = nil then
    begin
    ANode := BaseNode;
    end;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode wrong owner');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  i := ANode.Params.IndexOf(AName);
  IdRequire(i > -1, ASSERT_LOCATION+': Parameter "' + AName + '" not found');
  Result := integer(ANode.Params.Objects[i])
end;

function TIdSoapReaderBin.GetParamBoolean(ANode: TIdSoapNode; const AName: String): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamBoolean';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_BOOLEAN, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Boolean));
end;

function TIdSoapReaderBin.GetParamByte(ANode: TIdSoapNode; const AName: String): Byte;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamByte';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_BYTE, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Byte));
end;

function TIdSoapReaderBin.GetParamCardinal(ANode: TIdSoapNode; const AName: String): Cardinal;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamCardinal';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_CARDINAL, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Cardinal));
end;

function TIdSoapReaderBin.GetParamChar(ANode: TIdSoapNode; const AName: String): Char;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamChar';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_CHAR, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Char));
  if seoUseCrLf in EncodingOptions then
    begin
    result := IdSoapAdjustLineBreaks(result, tislbsCRLF)[1];
    end;
end;

function TIdSoapReaderBin.GetParamComp(ANode: TIdSoapNode; const AName: String): Comp;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamComp';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_COMP, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Comp));
end;

function TIdSoapReaderBin.GetParamCurrency(ANode: TIdSoapNode; const AName: String): Currency;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamCurrency';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_CURRENCY, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Currency));
end;

function TIdSoapReaderBin.GetParamDateTime(ANode: TIdSoapNode; const AName: String): TDateTime;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamDateTime';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  if LType = ID_SOAP_BIN_TYPE_DATETIME_NULL then
    begin
    result := 0
    end
  else
    begin
    Assert(LType = ID_SOAP_BIN_TYPE_DATETIME, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
    StreamReadBinary(FStream, @Result, sizeof(TDateTime));
    result := result + TimeZoneBias;
    end;
end;

function TIdSoapReaderBin.GetParamDouble(ANode: TIdSoapNode; const AName: String): Double;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamDouble';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_DOUBLE, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Double));
end;

function TIdSoapReaderBin.GetParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamEnumeration';
var
  LType : Byte;
  LName : string;
  LNameNS : string;
  LValue : Cardinal;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_ENUM, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  LName := StreamReadShortString(FStream);
  LNameNS := StreamReadShortString(FStream);
  LValue := StreamReadCardinal(FStream);
  IdRequire(LName = ATypeName, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, ATypeName, LName]));
  IdRequire(LNameNS = ANamespace, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_TYPE_NS_MISMATCH, [AName, ANamespace, LNameNS]));
  result := LValue;
end;

function TIdSoapReaderBin.GetParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamSet';
var
  LType : Byte;
  LName : string;
  LNameNS : string;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_SET, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  LName := StreamReadShortString(FStream);
  LNameNS := StreamReadShortString(FStream);
  IdRequire(LName = ATypeName, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, ATypeName, LName]));
  IdRequire(LNameNS = ANamespace, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_TYPE_NS_MISMATCH, [AName, ANamespace, LNameNS]));
  StreamReadBinary(FStream, @Result, sizeof(Integer));
end;

function TIdSoapReaderBin.GetParamExtended(ANode: TIdSoapNode; const AName: String): Extended;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamExtended';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_EXTENDED, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Extended));
end;

function TIdSoapReaderBin.GetParamInt64(ANode: TIdSoapNode; const AName: String): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamInt64';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_INT64, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Int64));
end;

function TIdSoapReaderBin.GetParamInteger(ANode: TIdSoapNode; const AName: String): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamInteger';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_INTEGER, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Integer));
end;

function TIdSoapReaderBin.GetParamShortInt(ANode: TIdSoapNode; const AName: String): ShortInt;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamShortInt';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_SHORTINT, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(ShortInt));
end;

function TIdSoapReaderBin.GetParamShortString(ANode: TIdSoapNode; const AName: String): ShortString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamShortString';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_SHORTSTRING, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  result := StreamReadShortString(FStream);
  if seoUseCrLf in EncodingOptions then
    begin
    result := IdSoapAdjustLineBreaks(result, tislbsCRLF);
    end;
end;

function TIdSoapReaderBin.GetParamSingle(ANode: TIdSoapNode; const AName: String): Single;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamSingle';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_SINGLE, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Single));
end;

function TIdSoapReaderBin.GetParamSmallInt(ANode: TIdSoapNode; const AName: String): SmallInt;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamSmallInt';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_SMALLINT, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(SmallInt));
end;

function TIdSoapReaderBin.GetParamString(ANode: TIdSoapNode; const AName: String): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamString';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  if GetParamExists(ANode, AName) then
    begin
    FStream.Position := GetParamPosition(ANode, AName);
    LType := StreamReadByte(FStream);
    Assert(LType = ID_SOAP_BIN_TYPE_STRING, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
    SetLength(result, StreamReadCardinal(FStream));
    if length(result) > 0 then
      begin
      StreamReadBinary(FStream, @result[1], Length(result));
      if seoUseCrLf in EncodingOptions then
        begin
        result := IdSoapAdjustLineBreaks(result, tislbsCRLF);
        end;
      end;
    end
  else
    begin
    result := '';
    end;
end;

function TIdSoapReaderBin.GetGeneralParam(ANode: TIdSoapNode; const AName: string; var VNil: boolean; var VValue, VTypeNS, VType: string): boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamBinary';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_GENERAL, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  VNil := StreamReadByte(FStream) = 1;
  VValue := StreamReadLongString(FStream);
  VTypeNS := StreamReadLongString(FStream);
  VType := StreamReadLongString(FStream);
  result := true; // maybe later this will be changed so that we may return false if not found. For now an exception is returned
end;

function TIdSoapReaderBin.GetXMLElement(ANode : TIdSoapNode; AName : string; var VOwnsDom : boolean;
              var VDom : TIdSoapXMLDom; var VElem : TIdSoapXMLElement; var VTypeNS, VType : String):Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetXMLElement';
var
  LStream : TStream;
  LByteCount : integer;
  LType : Byte;
begin
  result := ParamExists[ANode, AName];
  if result then
    begin
    FStream.Position := GetParamPosition(ANode, AName);
    LType := StreamReadByte(FStream);
    Assert(LType = ID_SOAP_BIN_TYPE_XML, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));

    VOwnsDom := true;
    VTypeNS := StreamReadLongString(FStream);
    VType := StreamReadLongString(FStream);
    LByteCount := StreamReadCardinal(FStream);
    LStream := TIdMemoryStream.create;
    try
      LStream.CopyFrom(FStream, LByteCount);
      LStream.Position := 0;
      VDom := IdSoapDomFactory(XmlProvider);
      try
        VDom.Read(LStream);
      except
        on e:exception do
          begin
          FreeAndNil(VDom);
          raise;
          end;
      end;
      VElem := VDom.Root;
    finally
      FreeAndNil(LStream);
    end;
    end;
end;

function TIdSoapReaderBin.GetParamBinaryBase64(ANode: TIdSoapNode; const AName: string): TStream;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamBinary';
var
  LType : Byte;
  LStream : TMemoryStream;
  LByteCount : integer;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_BINARY, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  LType := StreamReadByte(FStream);
  if LType = ID_SOAP_BIN_CLASS_NOT_NIL then
    begin
    LByteCount := StreamReadCardinal(FStream);
    LStream := TIdMemoryStream.create;
    if LByteCount > 0 then
      begin
      LStream.CopyFrom(FStream, LByteCount);
      end;
    LStream.Position := 0;
    result := LStream;
    end
  else if LType = ID_SOAP_BIN_CLASS_NIL then
    begin
    result := nil;
    end
  else
    begin
    Raise EIdSoapBadBinaryFormat.create(ASSERT_LOCATION+': '+Format(RS_ERR_BIN_UNKNOWN_TYPE, [inttostr(LType)]));
    end;
end;

function TIdSoapReaderBin.GetParamBinaryHex(ANode: TIdSoapNode; const AName: string): THexStream;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamBinary';
var
  LType : Byte;
  LStream : THexStream;
  LByteCount : integer;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_BINARY, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  LType := StreamReadByte(FStream);
  if LType = ID_SOAP_BIN_CLASS_NOT_NIL then
    begin
    LByteCount := StreamReadCardinal(FStream);
    LStream := THexStream.create;
    if LByteCount > 0 then
      begin
      LStream.CopyFrom(FStream, LByteCount);
      end;
    LStream.Position := 0;
    result := LStream;
    end
  else if LType = ID_SOAP_BIN_CLASS_NIL then
    begin
    result := nil;
    end
  else
    begin
    Raise EIdSoapBadBinaryFormat.create(ASSERT_LOCATION+': '+Format(RS_ERR_BIN_UNKNOWN_TYPE, [inttostr(LType)]));
    end;
end;

function TIdSoapReaderBin.GetParamWideChar(ANode: TIdSoapNode; const AName: String): WideChar;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamWideChar';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_WIDECHAR, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(WideChar));
end;

function TIdSoapReaderBin.GetParamWideString(ANode: TIdSoapNode; const AName: String): WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamWideString';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_WIDESTRING, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  SetLength(result, StreamReadCardinal(FStream));
  StreamReadBinary(FStream, @result[1], Length(result)*2);
end;

function TIdSoapReaderBin.GetParamWord(ANode: TIdSoapNode; const AName: String): Word;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.GetParamWord';
var
  LType : Byte;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');
  // GetParamPosition will check other parameters
  FStream.Position := GetParamPosition(ANode, AName);
  LType := StreamReadByte(FStream);
  Assert(LType = ID_SOAP_BIN_TYPE_WORD, ASSERT_LOCATION+': Value is actually '+DescribeParamType(LType));
  StreamReadBinary(FStream, @Result, sizeof(Word));
end;

procedure TIdSoapReaderBin.ReadAttachments;
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.ReadAttachments';
var
  LAttach : TIdSoapAttachment;
  i, t, l : integer;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': Self is not valid');

  t := StreamReadWord(FStream);
  for i := 0 to t - 1 do
    begin
    LAttach := Attachments.Add(StreamReadLongString(FStream), false);
    LAttach.UriType := StreamReadLongString(FStream);
    LAttach.MimeType := StreamReadLongString(FStream);
    l := StreamReadCardinal(FStream);
    if l <> 0 then
      begin
      LAttach.Content.CopyFrom(FStream, l);
      LAttach.Content.position := 0;
      end;
    end;
end;

function TIdSoapReaderBin.ResolveNamespace(ANode: TIdSoapNode; const AName, ANamespace: string): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReaderBin.ResolveNamespace';
var
  i : integer;
begin
  Assert(self.TestValid(TIdSoapReaderBin), ASSERT_LOCATION+': self is not valid');
  i := IdStrToIntWithError(ANamespace, 'Namespace for "'+AName+'" is not a valid ID#');
  Assert((i >= 0) and (i < FNamespaces.Count), ASSERT_LOCATION+': Unknown namespace '+ANamespace);
  result := FNamespaces[i];
end;

{ TIdSoapWriterBin }

constructor TIdSoapWriterBin.Create(Const ASoapVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.Create';
begin
  inherited;
  BaseNode.Stream := TMemoryStream.Create;
  StreamWriteShortString(BaseNode.Stream, ID_SOAP_NULL_NODE_NAME);
  FNamespaces := TStringList.create;
  FNamespaces.sorted := false; { index is identifier }
end;

destructor TIdSoapWriterBin.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.Destroy';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  FreeAndNil(FNamespaces);
  inherited;
end;

function  TIdSoapWriterBin.AddArray(ANode: TIdSoapNode; const AName, ABaseType, ABaseTypeNS: String; ABaseTypeComplex : boolean): TIdSoapNode;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.AddArray';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  Assert(ANode.Children.IndexOf(AName) = -1, ASSERT_LOCATION+': The Node Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');
  Result := TIdSoapNode.Create(AName, ABaseType, ABaseTypeNS, true, ANode, Self);
  result.IsComplexArray := ABaseTypeComplex;
  Result.Stream := TMemoryStream.Create;
  StreamWriteShortString(Result.Stream, AName);
  StreamWriteByte(Result.Stream, ID_SOAP_BIN_NODE_ARRAY);
  StreamWriteShortString(Result.Stream, ABaseType);
  StreamWriteShortString(Result.Stream, ABaseTypeNS);
  ANode.Children.AddObject(AName, Result);
end;

procedure TIdSoapWriterBin.DefineParamBoolean(ANode: TIdSoapNode; const AName: String; AValue: Boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamBoolean';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue

  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_BOOLEAN);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Boolean));
end;

procedure TIdSoapWriterBin.DefineParamByte(ANode: TIdSoapNode; const AName: String; AValue: Byte);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamByte';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue

  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_BYTE);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Byte));
end;

procedure TIdSoapWriterBin.DefineParamCardinal(ANode: TIdSoapNode; const AName: String; AValue: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamCardinal';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_CARDINAL);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Cardinal));
end;

procedure TIdSoapWriterBin.DefineParamChar(ANode: TIdSoapNode; const AName: String; AValue: Char);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamChar';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  AValue := IdSoapAdjustLineBreaks(AValue, tislbsLF)[1];
  if seoCheckStrings in EncodingOptions then
    begin
    CheckForBadCharacters(AValue, AName, ASSERT_LOCATION);
    end;
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_CHAR);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Char));
end;

procedure TIdSoapWriterBin.DefineParamComp(ANode: TIdSoapNode; const AName: String; AValue: Comp);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamComp';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_COMP);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Comp));
end;

procedure TIdSoapWriterBin.DefineParamCurrency(ANode: TIdSoapNode; const AName: String; AValue: Currency);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamCurrency';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_CURRENCY);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Currency));
end;

procedure TIdSoapWriterBin.DefineParamDateTime(ANode: TIdSoapNode; const AName: String; AValue: TDateTime);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamDateTime';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  if AValue = 0 then
    begin
    StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_DATETIME_NULL);
    end
  else
    begin
    AValue := AValue - TimeZoneBias;
    StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_DATETIME);
    StreamWriteBinary(ANode.Stream, @AValue, sizeof(TDateTime));
    end;
end;

procedure TIdSoapWriterBin.DefineParamDouble(ANode: TIdSoapNode; const AName: String; AValue: Double);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamDouble';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_DOUBLE);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Double));
end;

procedure TIdSoapWriterBin.DefineParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject; AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamEnumeration';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_ENUM);
  StreamWriteShortString(ANode.Stream, ATypeName);
  StreamWriteShortString(ANode.Stream, ANameSpace);
  StreamWriteCardinal(ANode.Stream, AValue);
end;

procedure TIdSoapWriterBin.DefineParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo; AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamSet';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_SET);
  StreamWriteShortString(ANode.Stream, ATypeName);
  StreamWriteShortString(ANode.Stream, ANameSpace);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Integer));
end;

procedure TIdSoapWriterBin.DefineParamExtended(ANode: TIdSoapNode; const AName: String; AValue: Extended);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamExtended';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_EXTENDED);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Extended));
end;

procedure TIdSoapWriterBin.DefineParamInt64(ANode: TIdSoapNode; const AName: String; AValue: Int64);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamInt64';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_INT64);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Int64));
end;

procedure TIdSoapWriterBin.DefineParamInteger(ANode: TIdSoapNode; const AName: String; AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamInteger';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_INTEGER);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Integer));
end;

procedure TIdSoapWriterBin.DefineParamShortInt(ANode: TIdSoapNode; const AName: String; AValue: ShortInt);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamShortInt';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_SHORTINT);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(ShortInt));
end;

procedure TIdSoapWriterBin.DefineParamShortString(ANode: TIdSoapNode; const AName: String; AValue: ShortString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamShortString';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  AValue := IdSoapAdjustLineBreaks(AValue, tislbsLF);
  if seoCheckStrings in EncodingOptions then
    begin
    CheckForBadCharacters(AValue, AName, ASSERT_LOCATION);
    end;
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_SHORTSTRING);
  StreamWriteShortString(ANode.Stream, AValue);
end;

procedure TIdSoapWriterBin.DefineParamSingle(ANode: TIdSoapNode; const AName: String; AValue: Single);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamSingle';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_SINGLE);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Single));
end;

procedure TIdSoapWriterBin.DefineParamSmallInt(ANode: TIdSoapNode; const AName: String; AValue: SmallInt);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamSmallInt';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_SMALLINT);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(SmallInt));
end;

procedure TIdSoapWriterBin.DefineParamString(ANode: TIdSoapNode; const AName, AValue: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamString';
var
  LValue : string;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  LValue := IdSoapAdjustLineBreaks(AValue, tislbsLF);
  if seoCheckStrings in EncodingOptions then
    begin
    CheckForBadCharacters(LValue, AName, ASSERT_LOCATION);
    end;
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_STRING);
  StreamWriteCardinal(ANode.Stream, Length(LValue));
  if length(LValue) > 0 then
    begin
    StreamWriteBinary(ANode.Stream, @LValue[1], Length(LValue));
    end;
end;

procedure TIdSoapWriterBin.DefineParamWideChar(ANode: TIdSoapNode; const AName: String; AValue: WideChar);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamWideChar';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_WIDECHAR);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(WideChar));
end;

procedure TIdSoapWriterBin.DefineParamWideString(ANode: TIdSoapNode; const AName: String; const AValue: WideString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamWideString';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_WIDESTRING);
  StreamWriteCardinal(ANode.Stream, Length(AValue));
  StreamWriteBinary(ANode.Stream, @AValue[1], Length(AValue) * 2);
end;

procedure TIdSoapWriterBin.DefineParamWord(ANode: TIdSoapNode; const AName: String; AValue: Word);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamWord';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_WORD);
  StreamWriteBinary(ANode.Stream, @AValue, sizeof(Word));
end;

procedure TIdSoapWriterBin.DefineGeneralParam(ANode: TIdSoapNode; ANil : boolean; AName, AValue, ATypeNS, AType: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineGeneralParam';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');

  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  // no check on AValue
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_GENERAL);
  if ANil then
    begin
    StreamWriteByte(ANode.Stream, 1);
    end
  else
    begin
    StreamWriteByte(ANode.Stream, 0);
    end;
  StreamWriteLongString(ANode.Stream, AValue);
  StreamWriteLongString(ANode.Stream, ATypeNS);
  StreamWriteLongString(ANode.Stream, AType);
end;


procedure TIdSoapWriterBin.DefineParamBinaryBase64(ANode: TIdSoapNode; const AName: string; AStream: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamBinary';
var
  LByteCount : integer;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_BINARY);
  if Assigned(AStream) then
    begin
    StreamWriteByte(ANode.Stream, ID_SOAP_BIN_CLASS_NOT_NIL);
    LByteCount := AStream.Size - AStream.Position;
    StreamWriteCardinal(ANode.Stream, LByteCount);
    if LByteCount > 0 then
      begin
      ANode.Stream.CopyFrom(AStream, LByteCount);
      end
    end
  else
    begin
    StreamWriteByte(ANode.Stream, ID_SOAP_BIN_CLASS_NIL);
    end;
end;

procedure TIdSoapWriterBin.DefineParamBinaryHex(ANode: TIdSoapNode; const AName: string; AStream: THexStream);
begin
  DefineParamBinaryBase64(ANode, AName, AStream);
end;

procedure TIdSoapWriterBin.WriteNode(AStream: TStream; ANode: TIdSoapNode);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.WriteNode';
var
  i: Integer;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  Assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');

  StreamWriteBinary(AStream, ANode.Stream.Memory, ANode.Stream.Size);
  for i := 0 to ANode.Children.Count - 1 do
    begin
    StreamWriteByte(AStream, ID_SOAP_BIN_TYPE_NODE);
    WriteNode(AStream, ANode.Children.objects[i] as TIdSoapNode);
    end;
  StreamWriteByte(AStream, ID_SOAP_BIN_NOTVALID);
end;


procedure TIdSoapWriterBin.Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.Encode';
var
  LCount : Cardinal;
  LProgressRec : TIdSoapKeyProgressRec;
  LKey : cardinal;
  LNode : TIdSoapNode;
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  Assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  Assert(MessageName <> '', ASSERT_LOCATION+': A method name must be provided');
  VMimeType := GetMimeType;
  StreamWriteCardinal(AStream, ID_SOAP_BIN_MAGIC);
  StreamWriteByte(AStream, CURRENT_BINARY_VERSION);
  WriteHeaders(AStream);
  StreamWriteByte(AStream, ID_SOAP_BIN_PACKET_MESSAGE);
  StreamWriteLongString(AStream, MessageNamespace);
  StreamWriteShortString(AStream, MessageName);
  // start node list
  StreamWriteByte(AStream, ID_SOAP_BIN_TYPE_NODE);
  WriteNode(AStream, BaseNode);
  StreamWriteCardinal(AStream, AStream.size);
  StreamWriteCardinal(AStream, ObjectReferences.Count);
  LCount := 0;
  if ObjectReferences.GetFirstKey(LProgressRec, LKey) then
    begin
    repeat
      inc(LCount);
      LNode := ObjectReferences[LKey] as TIdSoapNode;
      StreamWriteCardinal(AStream, LNode.WritingReferenceId);
      WriteNode(AStream, LNode);
    until not ObjectReferences.GetNextKey(LProgressRec, LKey);
    end;
  Assert(LCount = ObjectReferences.Count, ASSERT_LOCATION+': LCount <> ObjectReferences.Count');
  WriteAttachments(AStream);
  StreamWriteByte(AStream, +ID_SOAP_BIN_NOTVALID);
  StreamWriteWord(AStream, FNamespaces.Count);
  for i := 0 to FNamespaces.count - 1 do
    begin
    StreamWriteLongString(AStream, FNamespaces[i]);
    end;
end;

procedure TIdSoapWriterBin.StructNodeAdded(ANode: TIdSoapNode);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.StructNodeAdded';
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  Assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');
  ANode.Stream := TMemoryStream.Create;
  StreamWriteShortString(ANode.Stream, ANode.Name);
  if ANode.Reference <> nil then
    begin
    StreamWriteByte(ANode.Stream, ID_SOAP_BIN_NODE_REFERENCE);
    if (EncodingMode = semRPC) and (not (seoSuppressTypes in EncodingOptions)) then
      begin
      StreamWriteShortString(ANode.Stream, ANode.TypeName);
      StreamWriteShortString(ANode.Stream, ANode.TypeNamespace);
      end
    else
      begin
      StreamWriteShortString(ANode.Stream, '');
      StreamWriteShortString(ANode.Stream, '');
      end;
    StreamWriteCardinal(ANode.Stream, ANode.Reference.WritingReferenceId);
    end
  else
    begin
    StreamWriteByte(ANode.Stream, ID_SOAP_BIN_NODE_STRUCT);
    if (EncodingMode = semRPC) and (not (seoSuppressTypes in EncodingOptions)) then
      begin
      StreamWriteShortString(ANode.Stream, ANode.TypeName);
      StreamWriteShortString(ANode.Stream, ANode.TypeNamespace);
      end
    else
      begin
      StreamWriteShortString(ANode.Stream, '');
      StreamWriteShortString(ANode.Stream, '');
      end;
    end;
end;

function TIdSoapWriterBin.GetMimeType: string;
begin
  result := ID_SOAP_HTTP_BIN_TYPE;
end;

procedure TIdSoapWriterBin.WriteHeaders(AStream : TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.StructNodeAdded';
var
  i : integer;
  LHeader : TIdSoapHeader;
  LStr : TIdSoapString;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  StreamWriteCardinal(AStream, FHeaders.Count);
  for i := 0 to FHeaders.count -1 do
    begin
    LHeader := FHeaders.Items[i] as TIdSoapHeader;

    StreamWriteLongString(AStream, LHeader.Name);
    StreamWriteLongString(AStream, LHeader.Namespace);
    StreamWriteLongString(AStream, LHeader.PascalName);
    if LHeader.MustUnderstand then
      begin
      StreamWriteByte(AStream, 1);
      end
    else
      begin
      StreamWriteByte(AStream, 0);
      end;
    if LHeader.Content is TIdSoapString then
      begin
      StreamWriteByte(AStream, 1);
      LStr := LHeader.Content as TIdSoapString;
      StreamWriteLongString(AStream, LStr.Value);
      end
    else
      begin
      StreamWriteByte(AStream, 0);
      end;
    if assigned(LHeader.Node) then
      begin
      StreamWriteByte(AStream, 1);
      WriteNode(AStream, LHeader.Node);
      end
    else
      begin
      StreamWriteByte(AStream, 0);
      end;
    end;
end;

procedure TIdSoapWriterBin.WriteAttachments(AStream: TStream);
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.WriteAttachments';
var
  LAttach : TIdSoapAttachment;
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  StreamWriteWord(AStream, Attachments.Count);
  for i := 0 to Attachments.Count - 1 do
    begin
    LAttach := Attachments.AttachmentByIndex[i];
    StreamWriteLongString(AStream, LAttach.Id);
    StreamWriteLongString(AStream, LAttach.UriType);
    StreamWriteLongString(AStream, LAttach.MimeType);
    LAttach.Content.position := 0;
    StreamWriteCardinal(AStream, LAttach.Content.Size);
    AStream.CopyFrom(LAttach.Content, LAttach.Content.Size);
    end;
end;

function TIdSoapWriterBin.DefineNamespace(ANamespace: string): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineNamespace';
var
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  i := FNamespaces.indexof(ANamespace);
  if i = -1 then
    begin
    i := FNamespaces.Add(ANamespace);
    end;
  result := inttostr(i)+':';
end;

procedure TIdSoapWriterBin.DefineParamXML(ANode: TIdSoapNode; AName: string; AXml: TIdSoapXmlElement; ATypeNamespace, ATypeName : string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.DefineParamXML';
var
  LStream : TStream;
  LByteCount : Cardinal;
begin
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  Assert(self.TestValid(TIdSoapWriterBin), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  Assert(ANode.TestValid, ASSERT_LOCATION+': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(assigned(ANode.Stream), ASSERT_LOCATION+': ANode has no stream');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  {$IFOPT C+}
  Assert(ANode.Params.indexof(AName) = -1, ASSERT_LOCATION+': Attempt to use the parameter name ' + AName + ' more than once');
  ANode.Params.Add(AName);
  {$ENDIF}
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_PARAM);
  StreamWriteShortString(ANode.Stream, AName);
  StreamWriteByte(ANode.Stream, ID_SOAP_BIN_TYPE_XML);
  StreamWriteLongString(ANode.Stream, ATypeNamespace);
  StreamWriteLongString(ANode.Stream, ATypeName);
  LStream := TStringStream.create(AXML.AsXML);
  try
    LByteCount := LStream.Size - LStream.Position;
    StreamWriteCardinal(ANode.Stream, LByteCount);
    if LByteCount > 0 then
      begin
      ANode.Stream.CopyFrom(LStream, LByteCount);
      end;
  finally
    FreeAndNil(LStream);
  end;
end;

{ TIdSoapFaultWriterBin }

procedure TIdSoapFaultWriterBin.Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapFaultWriterBin.Encode';
begin
  Assert(self.TestValid(TIdSoapFaultWriterBin), ASSERT_LOCATION+': Self is not valid');
  Assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  VMimeType := GetMimeType;
  StreamWriteCardinal(AStream, ID_SOAP_BIN_MAGIC);
  StreamWriteByte(AStream, CURRENT_BINARY_VERSION);
  WriteHeaders(AStream); 
  StreamWriteByte(AStream, ID_SOAP_BIN_PACKET_EXCEPTION);
  StreamWriteShortString(AStream, FClass);
  StreamWriteCardinal(AStream, Length(FMessage));
  StreamWriteBinary(AStream, @FMessage[1], Length(FMessage)*2);
end;

function TIdSoapFaultWriterBin.GetMimeType: String;
begin
  result := ID_SOAP_HTTP_BIN_TYPE;
end;

procedure TIdSoapFaultWriterBin.WriteHeaders(AStream: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriterBin.StructNodeAdded';
var
  i : integer;
  LHeader : TIdSoapHeader;
  LStr : TIdSoapString;
begin
  Assert(self.TestValid(TIdSoapFaultWriterBin), ASSERT_LOCATION+': Self is not valid');
  StreamWriteCardinal(AStream, FHeaders.Count);
  for i := 0 to FHeaders.count -1 do
    begin
    LHeader := FHeaders.Items[i] as TIdSoapHeader;

    StreamWriteLongString(AStream, LHeader.Name);
    if LHeader.MustUnderstand then
      begin
      StreamWriteByte(AStream, 1);
      end
    else
      begin
      StreamWriteByte(AStream, 0);
      end;
    StreamWriteLongString(AStream, LHeader.Namespace);
    LStr := LHeader.Content as TIdSoapString;
    StreamWriteLongString(AStream, LStr.Value);
    end;
end;

end.

