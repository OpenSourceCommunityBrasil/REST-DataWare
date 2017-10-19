{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15768: IdSoapRpcXml.pas 
{
{   Rev 1.3    20/6/2003 00:04:08  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.2    18/3/2003 11:03:48  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.1    25/2/2003 13:14:00  GGrieve
}
{
{   Rev 1.0    11/2/2003 20:36:10  GGrieve
}
{
IndySOAP: This unit implements SOAP xml encoding and decoding
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  performance, polymorphism, headers
  18-Mar 2003   Grahame Grieve                  Remove IDSOAP_USE_RENAMED_OPENXML, support for QName, RawXML, relax type checking
  25-Feb 2003   Grahame Grieve                  Introduce IdSoapXML to allow multiple xml implementations
  29-Oct 2002   Grahame Grieve                  Ordering parameters; IdSoapFault and IdSoapSimpleClass improvements; support for seoUseDefaults
  04-Oct 2002   Grahame Grieve                  Attachments
  26-Sep 2002   Grahame Grieve                  Header Support
  19-Sep 2002   Grahame Grieve                  Introduce seoSendCharset
  17-Sep 2002   Grahame Grieve                  HexBinary, Many SoapBuilders2 issues
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Grahame Grieve                  Support for Arrays In Line
  26-Aug 2002   Grahame Grieve                  Fix for Soap::Lite arrays + Also look for references beside root node
  23-Aug 2002   Grahame Grieve                  Doc|Lit issues fixed
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  17-Aug 2002   Grahame Grieve                  Fix for major leak - forget to free OpenXML classes in Decoder
  17-Aug 2002   Grahame Grieve                  Fix for base64 bug in MS Soap
  16-Aug 2002   Grahame Grieve                  Refactor schema namespace handling *AGAIN*
  13 Aug 2002   Grahame Grieve                  Enforce types - use multiple acceptable types
  24-Jul 2002   Grahame Grieve                  Restructure Packet handlers to change Namespace Policy
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  18-Jul 2002   Grahame Grieve                  Better control over Mime Types
  16-Jul 2002   Grahame Grieve                  New OpenXML version - OpenXML handles namespaces when reading
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Fix for IDSOAP_USE_RENAMED_OPENXML not defined
  09-Apr 2002   Grahame Grieve                  Remove Hints and Warnings
  09-Apr 2002   Grahame Grieve                  Move Namespace support to IdSoapNamespace.pas
  08-Apr 2002   Grahame Grieve                  Support for Objects by Reference
  05-Apr 2002   Grahame Grieve                  Remove Hints and warnings
  05-Apr 2002   Grahame Grieve                  Fix XML parsing errors - get a proper message
  05-Apr 2002   Grahame Grieve                  Fix multidimensional array handling
  04-Apr 2002   Grahame Grieve                  Change to the way message names and namespaces are resolved + Mimetype support
  03-Apr 2002   Grahame Grieve                  Class based TIdSoapDateTime
  03-Apr 2002   Grahame Grieve                  Change to Packet writer interface - no difference between request and response
  02-Apr 2002   Grahame Grieve                  Fix namespace problem in sparse array position attribute
  02-Apr 2002   Grahame Grieve                  Date Time Support + read faults with no namespaces
  27-Mar 2002   Andrew Cumming                  more D4/D5 compliancy
  26-Mar 2002   Andrew Cumming                  Make D4/D5 compliant
  26-Mar 2002   Grahame Grieve                  Remodel Array handling - SOAP Compliant! + change names of constants
  22-Mar 2002   Grahame Grieve                  remove dialogs unit. Whoops
  22-Mar 2002   Andrew Cumming                  Changed to new IdSoapAdjustLineBreaks for D4/D5
  22-Mar 2002   Grahame Grieve                  Add To do for response name problem
  22-Mar 2002   Grahame Grieve                  Change Node handling to differentiate between arrays, elements, and structs
                                                + fix for empty structs/arrays in message
  18-Mar 2002   Andrew Cumming                  Fixed AdjustLineBreaks for D4/D5 compatibility
  15-Mar 2002   Andrew Cumming                  Changed case of string 'array' to 'Array' in line 899
  15-Mar 2002   Grahame Grieve                  Fix Namespace support for Objects
  14-Mar 2002   Grahame Grieve                  Support for seoCheckStrings, Checking Parameter types, get Widestrings right
  14-Mar 2002   Grahame Grieve                  Namespace support, improved WideString handling, default values for some types
  12-Mar 2002   Grahame Grieve                  Binary support (TStream) + Namespace enhancements
   7-Mar 2002   Grahame Grieve                  Review assertions
   3-Mar 2002   Andrew Cumming                  Added code to implent SETs
   3-Mar 2002   Grahame Grieve                  Begin implementing Namespaces
   7-Feb 2002   Andrew Cumming                  D4 compatibility
   7-Feb 2002   Grahame Grieve                  remove much content to IdSoapRpcPacket - abstract interface. Fix all existing tests. Still not standards compliant
   5-Feb 2002   Grahame Grieve                  Object and Array support (interface only, no real implementation)
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release
}

unit IdSoapRpcXml;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapComponent,
  IdSoapDateTime,
  IdSoapDebug,
  IdSoapITI,
  IdSoapNamespaces,
  IdSoapRpcPacket,
  IdSoapTypeRegistry,
  IdSoapXML,
  TypInfo;

type
  TIdSoapArrayDimensions = array of integer;

  { this is declared here for use within this unit only. No use outside this unit }
  TIdReaderParameter = class (TIdBaseObject)
  private
    FXmlLink : TIdSoapXmlElement;
    FIsNil : boolean;
    FTypeNS : string;
    FTypeVal : String;
    FValue : WideString;
    FReference : TIdReaderParameter;
  end;

  TIdSoapReaderXML = class(TIdSoapReader)
  private
    FDom: TIdSoapXMLDOM;
    FRootElement : TIdSoapXmlElement;
    FXMLIsUTF16 : boolean;
    FDomErr : string;
    FEncodingStyle : string;

    function  ReadDimeWrapper(ASoapPacket : TStream) : TStream;

    procedure ObserveXmlEncodingType(ASource : TStream);
    function GetParameter(ANode: TIdSoapNode; const AName: String): TIdReaderParameter;
    procedure CheckSoapEncodingStyle(AXmlNode : TIdSoapXmlElement);

    procedure ReadSimpleElement(AXmlElement: TIdSoapXmlElement; ASoapnode: TIdSoapNode; ATypeNS : string = ''; AType:String = ''; AName : string = '');
    procedure ReadComplex(AXmlElement: TIdSoapXmlElement; ASoapnode: TIdSoapNode; ATypeNS : string = ''; AType:String = ''; AName : string = '');
    procedure ReadArray(AXmlElement: TIdSoapXmlElement; ASoapnode: TIdSoapNode; AName : string = '');
    procedure ReadElement(AXmlElement: TIdSoapXmlElement; ASoapnode: TIdSoapNode; ATypeNS : string = ''; AType:String = ''; AName : string = '');
    procedure ReadReferences(AXmlElement : TIdSoapXmlElement);
    procedure ReadBase(ARootElement: TIdSoapXmlElement; ASoapNode: TIdSoapNode);

    procedure ProcessSoapException(AFaultNode: TIdSoapXmlElement);
    procedure EnforceType(const AParamName: string; const AParam : TIdReaderParameter; const ANamespaceList : array of string; ATypeList : array of string; ARoutineName: string); // clunky, but anamespace and aname iterate together
    procedure ReadReference(AXmlElement : TIdSoapXmlElement; ASoapnode : TIdSoapNode; AName : string = '');
    procedure CheckMsgEncodingStyle(AEnvelope, ABody : TIdSoapXmlElement);
    procedure CheckMsgSchemaVersion(AEnvelope, ABody : TIdSoapXmlElement);
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
    procedure CheckChildReferences(ANode : TIdSoapNode); override;
  Public
    destructor destroy; override;
    procedure ReadMessage(ASoapPacket: TStream; AMimeType : string; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent); override;
    procedure CheckPacketOK;                     override;
    procedure ProcessHeaders; override;
    procedure PreDecode;                         override;
    procedure DecodeMessage; override;
    property XMLIsUTF16 : boolean read FXMLIsUTF16;
    function GetGeneralParam(ANode: TIdSoapNode; const AName : string; Var VNil: boolean; var VValue, VTypeNS, VType : string):boolean; override;
    function ResolveNamespace(ANode: TIdSoapNode; const AName, ANamespace : string):String; override;
    function GetXMLElement(ANode : TIdSoapNode; AName : string; var VOwnsDom : boolean;
                                          var VDom : TIdSoapXMLDom; var VElem : TIdSoapXMLElement;
                                          var VTypeNS, VType : String):Boolean;  Override;
  end;

  // for internal use only
  TIdSoapWriterParameter = class (TIdBaseObject)
  private
    FIsNil : boolean;
    FType : String;
    FTypeNamespaceCode : String;
    FUseWideString : boolean;
    FValue : String;
    FValueW : WideString;
    FElem : TIdSoapXmlElement;
  public
    destructor destroy; override;
  end;

  TIdSoapWriterXML = class(TIdSoapWriter)
  private
    FUseUTF16 : boolean;
    FNamespaceInfo : TIdSoapXmlNamespaceSupport;
    FDom: TIdSoapXMLDOM;
    procedure EncodeParam(AParamInfo : TIdSoapWriterParameter; AElement : TIdSoapXMlElement; AIncludeType : boolean);
    procedure EncodeNode(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode);
    procedure DefineParameter(ANode: TIdSoapNode; const AName, AType, ATypeNamespace, AValue: String; AIsNil : boolean = false);
    procedure DefineParameterW(ANode: TIdSoapNode; const AName, AType, ATypeNamespace: String; AValue: WideString);
    function GetArrayDepth(ASoapNode: TIdSoapNode):integer;
    function ArrayIsSparse(ASoapNode: TIdSoapNode; AComplex : boolean):boolean;
    procedure EncodeArray(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode);
    procedure EncodeComplex(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode);
    procedure EncodeArrayComplex(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode; AComplex: boolean; ADepth: integer;
                                 ACurrentLocation: String; Var VArraySize : TIdSoapArrayDimensions);
    function EncodeArrayStraight(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode; AComplex: boolean): Integer;
    procedure EncodeReferenceObjects(AParent: TIdSoapXmlElement);
    function EncodeArrayInLine(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode; AComplex: boolean): Integer;
    procedure WriteHeaders(ADocElement : TIdSoapXmlElement);
    procedure EncodeAttachments(AStream : TStream; var VMimeType : String);
    function GetMimeType: String;
    procedure SetNilAttribute(AXmlElement: TIdSoapXmlElement; AValue: boolean);
  Public
    constructor Create(const ASoapVersion: TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider); override;
    destructor destroy; override;
    property UseUTF16 : boolean read FUseUTF16 write FUseUTF16;
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

  TIdSoapFaultWriterXml = class(TIdSoapFaultWriter)
  private
    FUseUTF16 : boolean;
    FNamespaceInfo : TIdSoapXmlNamespaceSupport;
    procedure WriteHeaders(ADom: TIdSoapXMLDOM; ADocElement : TIdSoapXmlElement);
    function GetMimeType: String;
    procedure BuildDetailsXML(ADom : TIdSoapXMLDOM; AFaultNode : TIdSoapXmlElement);
  Public
    property UseUTF16 : boolean read FUseUTF16 write FUseUTF16;
    procedure Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent); Override;
  end;


implementation

uses
  IdSoapBase64,
  IdSoapConsts,
  IdSoapDime,
  IdSoapExceptions,
  IdSoapOpenXML,
  IdSoapResourceStrings,
  IdSoapTypeUtils,
  IdSoapUtilities,
  SysUtils;

function IsXmlWhiteSpaceString(AStr : WideString):boolean;
var
  i : integer;
begin
  result := true;
  for i := 1 to length(AStr) do
    begin
    if not isXmlWhiteSpace(AStr[i]) then
      begin
      result := false;
      exit;
      end;
    end;
end;

function NormaliseSchemaNamespace(ANamespace : string):String;
begin
  if ANamespace = ID_SOAP_NS_SCHEMA_1999 then
    begin
    result := ID_SOAP_NS_SCHEMA_2001;
    end
  else
    begin
    result := ANamespace;
    end;
end;

{ TIdSoapReaderXML }

procedure TIdSoapReaderXML.ObserveXmlEncodingType(ASource: TStream);
const ASSERT_LOCATION = 'IdSoapRpcXML.TIdSoapReaderXML.ObserveXmlEncodingType';
var
  LPos : Int64;
  LWord : word;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(assigned(ASource), ASSERT_LOCATION+': Source is nil');
  assert(ASource.Size - ASource.Position > 0, ASSERT_LOCATION+': Source is 0 length');
  LPos := ASource.Position;
  ASource.Read(LWord, sizeof(Word));
  ASource.Position := LPos;
  FXMLIsUTF16 := (LWord = $feff) or (LWord = $fffe);  // ? reliabilty
end;

procedure TIdSoapReaderXML.CheckSoapEncodingStyle(AXmlNode: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXML.TIdSoapReaderXML.CheckSoapEncodingStyle';
var
  s : string;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AXmlNode.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': AXmlNode is not valid');
  if EncodingMode = semRPC then
    begin
    // check that the soap encoding style is one we understand....
    if AXmlNode.hasAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE) then
      begin
      // the soap endocing standard can be further narrowed, in which case the
      // soap encoding style is extended. We will accept this cases, since we are
      // supposed to be able to read them
      s := AXmlNode.getAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE);
      IdRequire(Copy(s, 1, length(ID_SOAP_NS_SOAPENC)) =  ID_SOAP_NS_SOAPENC, ASSERT_LOCATION+': '+RS_ERR_SOAP_ENCODINGSTYLE+' "'+s+'"');
      end;
    end;
end;

procedure TIdSoapReaderXML.ProcessSoapException(AFaultNode : TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ProcessSoapException';
var
  LFaultString : TIdSoapXmlElement;
  LFaultCode : TIdSoapXmlElement;
  LFaultActor : TIdSoapXmlElement;
  LDetail : TIdSoapXmlElement;
  LMessage : string;
  LClass : string;
  LSource : string;
  LSourceFiddled : string;
  LActor : string;
  LTemp : string;
  LDetailSrc : string;
  LException : Exception;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(assigned(AFaultNode), ASSERT_LOCATION+': FaultNode is not valid');
  CheckSoapEncodingStyle(AFaultNode);
  LFaultCode := AFaultNode.FirstElement(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_FAULTCODE);
  if not assigned(LFaultCode) then
    begin
    // may be provided with no namespace or in wrong case, or whatever
    LFaultCode := AFaultNode.FindElementAnyNS(ID_SOAP_NAME_FAULTCODE);
    end;
  if Assigned(LFaultCode) then
    begin
    LSource := LFaultCode.textContentA;
    if Pos(':', LSource) > 0 then
      begin
      SplitString(LSource, ':', LTemp, LSourceFiddled)
      end
    else
      begin
      LSourceFiddled := LSource;
      end
    end
  else
    begin
    LSource := '';
    LSourceFiddled := '';
    end;
  LFaultString := AFaultNode.FirstElement(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_FAULTSTRING);
  if not assigned(LFaultString) then
    begin
    // may be provided with no namespace or in wrong case, or whatever
    LFaultString := AFaultNode.FindElementAnyNS(ID_SOAP_NAME_FAULTSTRING);
    end;
  assert(Assigned(LFaultString), ASSERT_LOCATION+': FaultNode Found but no FaultString found');
  LMessage := LFaultString.textContentA;
  assert(LMessage <> '', ASSERT_LOCATION+': FaultNode Found but FaultString was empty');
  LDetail := AFaultNode.FindElementAnyNS(ID_SOAP_NAME_FAULTDETAIL);
  if assigned(LDetail) then
    begin
    LDetailSrc := LDetail.AsXML;
    LClass := LDetail.GetXSIType;
    if pos(':', LClass) > 0 then
      begin
      SplitString(LClass, ':', LTemp, LClass);
      end;
    end
  else
    begin
    LClass := '';
    LDetailSrc := '';
    end;
  LException := GenerateSOAPException(LSource, LClass, LMessage);
  if LException = NIL then
    begin
    LFaultActor := AFaultNode.FirstElement(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_FAULTACTOR);
    if not assigned(LFaultActor) then
      begin
      // may be provided with no namespace or in wrong case, or whatever
      LFaultActor := AFaultNode.FindElementAnyNS(ID_SOAP_NAME_FAULTACTOR);
      end;
    if Assigned(LFaultActor) then
      begin
      LActor := LFaultActor.textContentA;
      end
    else
      begin
      LActor := '';
      end;
    LException := EIdSoapFault.create(LSourceFiddled + ': '+LMessage, LActor, LSource, LMessage, LDetailSrc);
    end;
  raise LException;
end;

procedure TIdSoapReaderXML.ReadMessage(ASoapPacket: TStream; AMimeType : string; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadMessage';
var
  LStream : TStream;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(assigned(ASoapPacket), ASSERT_LOCATION+': Soap Packet Source is nil');
  assert(ASoapPacket.Size - ASoapPacket.Position > 0, ASSERT_LOCATION+': Soap Packet Source is empty');

  LStream := nil;
  if AMimeType = ID_SOAP_HTTP_DIME_TYPE then
    begin
    LStream := ReadDimeWrapper(ASoapPacket);
    ASoapPacket := LStream;
    end;
  try
    FDomErr := '';
    FEncodingStyle := '';
    FirstEntityName := '';

    ObserveXmlEncodingType(ASoapPacket);
    FDom := IdSoapDomFactory(XmlProvider);
    FDom.Read(ASoapPacket);
  finally
    FreeAndNil(LStream);
  end;
  if assigned(AEvent) then
    begin
    AEvent(ACaller, FDom);
    end;
end;

procedure TIdSoapReaderXML.CheckPacketOK;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.CheckPacketOK';
var
  LEnvelope : TIdSoapXmlElement;
  LNode : TIdSoapXmlElement;
  LChildCount : integer;
  LFoundHeader : boolean;
  LBody : TIdSoapXmlElement;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': Document DOM is not valid');
  { TODO : replace strings with resourcestrings }
  LEnvelope := FDom.Root;
  IdRequire(LEnvelope.Name = ID_SOAP_NAME_ENV, ASSERT_LOCATION+': Soap Processing Rules failed - Document root node must be "'+ID_SOAP_NAME_ENV+'", but is "'+LEnvelope.Name+'"');
  IdRequire(LEnvelope.namespace = ID_SOAP_NS_SOAPENV, ASSERT_LOCATION+': Soap Processing Rules failed - Element Node Namespace wrong (is "'+LEnvelope.namespace+'", expected "'+ID_SOAP_NS_SOAPENV+'" (Soap Version 1.1)');

  LBody := nil;
  LFoundHeader := false;
  LChildCount := 0;
  LNode := LEnvelope.firstChild;
  while assigned(LNode) do
    begin
    inc(LChildCount);
    IdRequire(LNode.namespace <> '', ASSERT_LOCATION+': Soap Processing Rules failed - all envelope children must have a namespace (element "'+LNode.nodeName+'")');
    if (LNode.namespace = ID_SOAP_NS_SOAPENV) and (LNode.Name = ID_SOAP_NAME_HEADER) then
      begin
      IdRequire(LChildCount = 1, ASSERT_LOCATION+': Soap Processing Rules failed - Header must be the first node');
      LFoundHeader := true;
      end
    else if (LNode.namespace = ID_SOAP_NS_SOAPENV) and (LNode.Name = ID_SOAP_NAME_BODY) then
      begin
      IdRequire((LChildCount = 1) or ((not assigned(LBody)) and (LFoundHeader) and (LChildCount = 2)), ASSERT_LOCATION+': Soap Processing Rules failed - Body must be the first node or must follow the header');
      LBody := LNode;
      end;
    LNode := LNode.nextSibling;
    end;
  IdRequire(assigned(LBody), ASSERT_LOCATION+': Soap Processing Rules failed - No Body Element found (or it had the wrong Namespace)');
  CheckMsgEncodingStyle(LEnvelope, LBody);
  CheckMsgSchemaVersion(LEnvelope, LBody);
end;

procedure TIdSoapReaderXML.ProcessHeaders;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ProcessHeaders';
var
  LNode : TIdSoapXmlElement;
  LHeader : TIdSoapHeader;
  LStr : TIdSoapString;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': Document DOM is not valid');

  {just collate the headers so that the application can get them}
  LNode := FDom.Root.FirstElement(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_HEADER);
  if assigned(LNode) then
    begin
    LNode := LNode.firstChild;
    while assigned(LNode) do
      begin
      // first, treat the content as strings for pre-processing
      LStr := TIdSoapString.create;
      if LNode.HasText then
        begin
        LStr.Value := LNode.TextContentA;
        end;

      LHeader := TIdSoapHeader.CreateWithQName(LNode.namespace, LNode.Name, LStr);
      Headers.Add(LHeader);
      LHeader.MustUnderstand := LNode.getAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_MUSTUNDERSTAND) = '1';

      // now, set the header up for later processing
      LHeader.Node := TIdSoapNode.Create(ID_SOAP_NULL_NODE_NAME, ID_SOAP_NULL_NODE_TYPE, '', False, NIL, self);
      ReadElement(LNode, LHeader.Node                       ); // simple types?
      LNode := LNode.NextSibling;
      end
    end;
end;

procedure TIdSoapReaderXML.PreDecode;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.PreDecode';
var
  LElement: TIdSoapXmlElement;
  LFault: TIdSoapXmlElement;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': Document DOM is not valid');
  FPreDecoded := true;

  LElement := FDom.root.FirstElement(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_BODY);
  assert(LElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Body Element is not valid');

  LFault := LElement.FindElementAnyNS(ID_SOAP_NAME_FAULT);
  if assigned(LFault) then
    begin
    ProcessSoapException(LFault);
    end;
  // for the moment, we assume that the method element is the first child of the body
  // this is a difficult issue
  FRootElement := LElement.FirstChild;
  IdRequire(FRootElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': '+RS_ERR_SOAP_MISSING_CONTENTS);
  if FRootElement.Namespace <> '' then
    begin
    MessageNameSpace := FRootElement.namespace;
    MessageName := FRootElement.Name;
    end
  else
    begin
    MessageNameSpace := '';
    MessageName := FRootElement.Name;
    end;
end;

procedure TIdSoapReaderXML.DecodeMessage;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.DecodeMessage';
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  if not FPreDecoded then
    begin
    PreDecode;
    end;
  assert(FRootElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Root Element is not valid');
  if FRootElement.hasAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE) then
    begin
    FEncodingStyle := FRootElement.getAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE);
    end;
  // must have defined encoding style by here, or at least, it must not be defined to an unknown value
  IdRequire((EncodingMode = semDocument) or (FEncodingStyle = '') or (AnsiStrLComp(pchar(FEncodingStyle), ID_SOAP_NS_SOAPENC, length(ID_SOAP_NS_SOAPENC)) = 0), ASSERT_LOCATION+': '+RS_ERR_SOAP_ENCODINGSTYLE+' "'+FEncodingStyle+'"');
  ReadBase(FRootElement, BaseNode);
  ReadReferences(FRootElement.NextSibling);
  CheckChildReferences(BaseNode);
  FinishReading;
end;

procedure TIdSoapReaderXML.ReadSimpleElement(AXmlElement : TIdSoapXmlElement; ASoapNode : TIdSoapNode; ATypeNS : string = ''; AType:String = ''; AName : string = '');
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadSimpleElement';
var
  LParam : TIdReaderParameter;
  LName : string;
  LTemp : string;
  LId : string;
  LIdRef : integer;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AXmlElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Element is not valid');
  assert((ASoapNode = nil) or ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': SoapNode is not valid');
  if AName <> '' then
    begin
    LName := AName;
    end
  else
    begin
    LName := AXmlElement.NodeName;
    end;
  if (EncodingMode = semRPC) and Assigned(ASoapNode) then
    begin
    assert(ASoapNode.Params.indexof(LName) = -1, ASSERT_LOCATION+': Attempt to add the parameter "'+AXmlElement.NodeName+'" again');
    end;
  LParam := TIdReaderParameter.create;
  LParam.FXmlLink := AXmlElement;
  if assigned(ASoapNode) then
    begin
    ASoapNode.AddParam(LName, LParam);
    end
  else
    begin
    LId := AXmlElement.getAttribute('', ID_SOAP_NAME_XML_ID);
    LIdRef := StrToIntDef(LId, 0);
    if LIdRef <> 0 then
      begin
      ObjectReferences.AsObj[LIdRef] := LParam;
      end
    else
      begin
      NameReferences.AddObject(LId, LParam)
      end;
    end;
  LTemp := AXmlElement.GetXSIType;
  if LTemp = '' then
    begin
    LParam.FTypeNS := ATypeNS;
    LParam.FTypeVal := AType;
    end
  else
    begin
    if Pos(':', LTemp) = 0 then
      begin
      LParam.FTypeNS := ID_SOAP_NS_SCHEMA_2001;
      LParam.FTypeVal := LTemp;
      end
    else
      begin
      SplitString(LTemp, ':', LParam.FTypeNS, LParam.FTypeVal);
      LParam.FTypeNS := NormaliseSchemaNamespace(AXmlElement.ResolveXMLNamespaceCode(LParam.FTypeNS, 'Type attribute for Element '+AXmlElement.nodeName));
      end;
    end;
{  if (EncodingMode = semRPC) and (seoRequireTypes in EncodingOptions) then
    begin
    IdRequire(LParam.FTypeNS <> '', ASSERT_LOCATION+': No type Namespace for parameter '+AXmlElement.NodeName);
    IdRequire(LParam.FTypeVal <> '', ASSERT_LOCATION+': No type for parameter '+AXmlElement.NodeName);
    end;}
  LParam.FIsNil := AXmlElement.HasNilAttribute;
  if not LParam.FIsNil then
    begin
    LParam.FValue := AXmlElement.TextContentW;
    end;
end;

procedure TIdSoapReaderXML.ReadComplex(AXmlElement : TIdSoapXmlElement; ASoapnode : TIdSoapNode; ATypeNS : string = ''; AType:String = ''; AName : string = '');
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadComplex';
var
  LId : string;
  LIdRef : integer;
  LType : string;
  LTypeNS : string;
  LName : string;
  LNameNS : string;
  LChildNode : TIdSoapNode;
  LNode: TIdSoapXmlElement;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AXmlElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Element is not valid');
  assert((ASoapNode = nil) or ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': SoapNode is not valid');
  CheckSoapEncodingStyle(AXmlElement);
  if AName <> '' then
    begin
    LName := AName;
    end
  else if Pos(':', AXmlElement.nodeName) > 0 then
    begin
    SplitString(AXmlElement.nodeName, ':', LNameNS, LName); // no default namespace at present, since this namespace is actually ignored
    end
  else
    begin
    LName := AXmlElement.nodeName;
    end;
  if ASoapNode = nil then
    begin
    LId := AXmlElement.getAttribute('', ID_SOAP_NAME_XML_ID);
    LIdRef := StrToIntDef(LId, 0);
    end
  else
    begin
    LId := '';
    LIdRef := 0;
    end;

  if AXmlElement.HasNilAttribute then { do not localize }
    begin
    if ASoapNode = nil then
      begin
      // if a reference is made to a null object, then we must mark this. This isn't really elegant,
      // but the whole system of dealing with null objects isn't very elegant anyway
      if LIdRef <> 0 then
        begin
        ObjectReferences.AsObj[LIdRef] := nil;
        end
      else
        begin
        NameReferences.AddObject(LId, nil);
        end;
      end
    else
      begin
      // we don't do anything in this case
      end;
    end
  else
    begin
    LType := AXmlElement.GetXSIType;
    if LType = '' then
      begin
      LTypeNS := ATypeNS;
      LType := AType;
      end
    else
      begin
      if Pos(':', LType) = 0 then
        begin
        LTypeNS := ID_SOAP_NS_SCHEMA_2001;
        end
      else
        begin
        SplitString(LType, ':', LTypeNS, LType);
        LTypeNS := NormaliseSchemaNamespace(AXmlElement.ResolveXMLNamespaceCode(LTypeNS, 'Attribute '+ID_SOAP_NAME_SCHEMA_TYPE+' on element '+AXmlElement.nodeName));
        end;
      end;
    if (EncodingMode = semRPC) and (seoRequireTypes in EncodingOptions) then
      begin
      IdRequire(LType <> '', ASSERT_LOCATION+': '+RS_ERR_SOAP_MISSING_TYPE+' "'+LName+'"');
      end;
    LChildNode := TIdSoapNode.create(LName, LType, LTypeNS, false, ASoapNode, self);
    LChildNode.XMLLink := AXmlElement;
    if assigned(ASoapNode) then
      begin
      if EncodingMode = semRPC then
        begin
        assert(ASoapNode.Children.indexof(LName) = -1, ASSERT_LOCATION+': Attempt to add the child "'+LName+'" again');
        end;
      ASoapNode.AddChild(LChildNode.Name, LChildNode);
      end
    else
      begin
      if LIdRef <> 0 then
        begin
        ObjectReferences.AsObj[LIdRef] := LChildNode;
        end
      else
        begin
        NameReferences.AddObject(LId, LChildNode)
        end;
      end;

    LNode := AXmlElement.FirstChild;
    while assigned(LNode) do
      begin
      assert(LNode.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Node  is not valid');
      assert(not LNode.hasID, ASSERT_LOCATION+': Node on complex "'+LName+'" has an id');
      ReadElement(LNode, LChildNode);
      LNode := LNode.nextSibling;
      end;
    end;
end;

type
  TIdSoapArrayDescription = class (TIdBaseObject)
  private
    FReader : TIdSoapReaderXML;
    FBaseTypeNS : String;
    FBaseType : string;
    FOffsets : TIdSoapArrayDimensions;
    FBaseDimensions : TIdSoapArrayDimensions; // what the dimensions are
    FUsedPositionAttribute : boolean; // if the Position Attribute was used in the nodes, we do not insist on a fully populated array
    procedure ReadArrayInfo(AXmlElement : TIdSoapXmlElement; AInfo, AOffset : string);
    function CheckFullyPopulated(ASoapNode : TIdSoapNode; AOffset : integer):boolean;
    function GetNodeForNextItem(AElement : TIdSoapXmlElement; AParent : TIdSoapNode; AArrayName : string;
                                var VOffsets : TIdSoapArrayDimensions; Var VFirst : boolean; var VItemNum : string) : TIdSoapNode;
  end;

procedure SplitWrappersRight(const AStr, ALeftToken, ARightToken : string; Var VLeft, VMiddle, VRight : string);
const ASSERT_LOCATION = 'IdSoapRpcXml.SplitWrappersRight';
var
  c, b:integer;
  LStr : string;
begin
  // we don't do any asserting here - the caller will know what to check
  LStr := AStr;
  c := length(LStr);
  while (c > 0) and (copy(LStr, c, length(ALeftToken)) <> ALeftToken) do
    begin
    dec(c);
    end;
  assert(c <> 0, ASSERT_LOCATION+': Left Token "'+ALeftToken+'" not found in "'+LStr+'"');
  b := c;
  while (c <= Length(LStr)) and (copy(LStr, c, length(ARightToken)) <> ARightToken) do
    begin
    inc(c);
    end;
  assert(c <= length(LStr), ASSERT_LOCATION+': Right Token "'+ARightToken+'" not found in "'+LStr+'"');
  VLeft := Copy(LStr, 1, b-1);
  VMiddle := Copy(LStr, b+1, (c-b) - 1);
  VRight := copy(LStr, c+1, length(LStr));
end;

function CharCount(AStr : String; AChar : Char):Integer;
var
  i : integer;
begin
  // no check params
  result := 0;
  for i := 1 to length(AStr) do
    begin
    if AStr[i] = AChar then
      begin
      inc(result);
      end;
    end;
end;

function ReadArrayNumbers(ASize : string):TIdSoapArrayDimensions;
const ASSERT_LOCATION = 'IdSoapRpcXML.ReadArrayNumbers';
var
  LSize : string;
  LLeft : string;
  i : integer;
begin
  // no check params
  LSize := ASize;
  SetLength(result, CharCount(LSize, ',')+1);
  for i := 0 to Length(result) - 1 do
    begin
    result[i] := 0;
    end;
  i := 0;
  while LSize <> '' do
    begin
    SplitString(LSize, ',', LLeft, LSize);
    result[i] := IdStrToIntWithError(LLeft, ASSERT_LOCATION+': ASize Component'); { do not localize }
    inc(i);
    end;
  IdRequire(i = Length(result), ASSERT_LOCATION+': '+RS_ERR_SOAP_ARRAY_DIM_MISSING+' ("'+ASize+'")');
end;

procedure TIdSoapReaderXML.CheckMsgEncodingStyle(AEnvelope, ABody: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXML.CheckMsgEncodingStyle';
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AEnvelope.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Envelope is not valid');
  assert(ABody.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Envelope is not valid');

  if EncodingMode = semRPC then
    begin
    if AEnvelope.hasAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE) then
      begin
      FEncodingStyle := AEnvelope.getAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE);
      end;
    if ABody.hasAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE) then
      begin
      FEncodingStyle := ABody.getAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_ENCODINGSTYLE);
      end;
    if FEncodingStyle <> '' then
      begin
      IdRequire(AnsiStrLComp(pchar(FEncodingStyle), ID_SOAP_NS_SOAPENC, length(ID_SOAP_NS_SOAPENC)) = 0, ASSERT_LOCATION+': '+RS_ERR_SOAP_ENCODINGSTYLE+' "'+FEncodingStyle+'"');
      end;
    end;
end;

procedure TIdSoapReaderXML.CheckMsgSchemaVersion(AEnvelope, ABody: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXML.CheckMsgSchemaVersion';
var
  LFound : boolean;

  procedure ScanAttributes(AElement : TIdSoapXmlElement);
  var
    i : integer;
    LName, LNS : WideString;
  begin
    for i := 0 to AElement.AttributeCount - 1 do
      begin
      assert(AElement.getAttributeName(i, LNS, LName), ASSERT_LOCATION+': Attribute '+inttostr(i)+' not found');
      { TODO : check name of attribute too }
      if AElement.GetAttribute(LNS, LName) = ID_SOAP_NS_SCHEMA_2001 then
        begin
        SchemaNamespace := ID_SOAP_NS_SCHEMA_2001;
        SchemaInstanceNamespace := ID_SOAP_NS_SCHEMA_INST_2001;
        LFound := true;
        break
        end;
      if AElement.GetAttribute(LNS, LName) = ID_SOAP_NS_SCHEMA_1999 then
        begin
        SchemaNamespace := ID_SOAP_NS_SCHEMA_1999;
        SchemaInstanceNamespace := ID_SOAP_NS_SCHEMA_INST_1999;
        LFound := true;
        break
        end
      end;
  end;

begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AEnvelope.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Envelope is not valid');
  assert(ABody.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Envelope is not valid');

  LFound := false;
  ScanAttributes(AEnvelope);
  if not LFound then
    begin
    ScanAttributes(ABody);
    end;
end;

destructor TIdSoapReaderXML.destroy;
const ASSERT_LOCATION = 'IdSoapRpcXML.CheckMsgSchemaVersion';
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FDom);
  inherited;
end;

procedure TIdSoapReaderXML.CheckChildReferences(ANode: TIdSoapNode);
const ASSERT_LOCATION = 'IdSoapRpcPacket.TIdSoapReader.CheckChildReferences';
var
  i : Integer;
  LIndex : integer;
  LNode : TIdSoapNode;
  LParam : TIdReaderParameter;
  LNewParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');
  assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION + ': ANode is invalid');
  for i := ANode.Children.count -1 downto 0 do
    begin
    if ANode.Children[i] <> ID_SOAP_INVALID then
      begin
      LNode := ANode.Children.Objects[i] as TIdSoapNode;
      assert(LNode <> nil, ASSERT_LOCATION + ': nil node found at ['+inttostr(i)+'] in children: '+ANode.Children.CommaText);
      if (LNode.ReadingReferenceId <> 0) or (LNode.ReadingReferenceName <> '') then
        begin
        LParam := nil;
        if LNode.ReadingReferenceId <> 0 then
          begin
          if assigned(ObjectReferences.AsObj[ANode.ReadingReferenceId]) and
              (ObjectReferences.AsObj[ANode.ReadingReferenceId] is TIdReaderParameter) then
            begin
            LParam := ObjectReferences.AsObj[ANode.ReadingReferenceId] as TIdReaderParameter;
            end;
          end
        else
          begin
          if NameReferences.Find(LNode.ReadingReferenceName, LIndex) then
            begin
            if assigned(NameReferences.Objects[LIndex]) and (NameReferences.Objects[LIndex] is TIdReaderParameter) then
              begin
              LParam := NameReferences.Objects[LIndex] as TIdReaderParameter;
              end;
            end;
          end;
        if assigned(LParam) then
          begin
          LNewParam := TIdReaderParameter.create;
          LNewParam.FReference := LParam;
          // move param into place
          ANode.AddParam(ANode.Children[i], LNewParam);
          ANode.DeleteChild(i, true);
          end;
        end;
      end;
    end;
end;

function TIdSoapReaderXML.ReadDimeWrapper(ASoapPacket: TStream): TStream;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadDimeWrapper';
var
  LDime : TIdSoapDimeMessage;
  LRec : TIdSoapDimeRecord;
  LAtt : TIdSoapAttachment;
  i : integer;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(assigned(ASoapPacket), ASSERT_LOCATION+': ASoapPacket is not valid');
  

  LDime := TIdSoapDimeMessage.create;
  try
    LDime.ReadFromStream(ASoapPacket);
    IdRequire(LDime.RecordCount > 0, ASSERT_LOCATION+': No records found in DIME Wrapper');
    LRec := LDime.Item[0];
    // we will treat the first record as the soap message as speciified in draft-nielsen-dime-soap-01, without checking
    Result := LRec.Content;
    LRec.Content := nil;
    for i := 1 to LDime.RecordCount - 1 do
      begin
      LRec := LDime.Item[i];
      LAtt := Attachments.Add(LRec.Id, false);
      LAtt.Content.Free;
      LAtt.Content := LRec.Content;
      LRec.Content := nil;
      case LRec.TypeType of
        dtMime : LAtt.MimeType := LRec.TypeInfo;
        dtURI  : LAtt.URIType := LRec.TypeInfo;
      else
        {dtNotKnown, dtInvalid : } ; // nothing
      end;
      end;
  finally
    FreeAndNil(LDime);
  end;
end;

function TIdSoapReaderXML.ResolveNamespace(ANode: TIdSoapNode; const AName, ANamespace: string): String;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ResolveNamespace';
var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  LParam := GetParameter(ANode, AName);
  assert(LParam.TestValid(TIdReaderParameter), ASSERT_LOCATION+': Param is not valid [1]');
  if LParam.FXmlLink = nil then
    begin
    LParam := LParam.FReference;
    assert(LParam.TestValid(TIdReaderParameter), ASSERT_LOCATION+': Param is not valid [2]');
    end;
  assert(LParam.FXmlLink.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': XMLLink is not valid');
  result := LParam.FXmlLink.ResolveXMLNamespaceCode(ANamespace, AName);
end;

function TIdSoapReaderXML.GetXMLElement(ANode : TIdSoapNode; AName : string; var VOwnsDom : boolean;
           var VDom : TIdSoapXMLDom; var VElem : TIdSoapXMLElement; var VTypeNS, VType : String):Boolean;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetXMLElement';
var
  LParam : TIdReaderParameter;
  LChild : TIdSoapNode;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  // due to problems with the node system, we might find the item we're looking
  // for in either the params or the children
  VOwnsDom := false;
  result := false;
  if ParamExists[ANode, AName] then
    begin
    LParam := GetParameter(ANode, AName);
    assert(LParam.TestValid(TIdReaderParameter), ASSERT_LOCATION+': Param is not valid [1]');
    if LParam.FXmlLink = nil then
      begin
      LParam := LParam.FReference;
      assert(LParam.TestValid(TIdReaderParameter), ASSERT_LOCATION+': Param is not valid [2]');
      end;
    assert(LParam.FXmlLink.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': XMLLink is not valid ( 1)');
    result := true;
    VElem := LParam.FXmlLink;
    VDom := VElem.DOM;
    VTypeNS := LParam.FTypeNS;
    VType := LParam.FTypeVal;
    end
  else
    begin
    LChild := GetNodeNoClassnameCheck(ANode, AName, true);
    if assigned(LChild) then
      begin
      assert(LChild.TestValid(TIdSoapNode), ASSERT_LOCATION+': Child is not valid [1]');
      if LChild.Reference <> nil then
        begin
        LChild := LChild.Reference;
        assert(LChild.TestValid(TIdSoapNode), ASSERT_LOCATION+': Child is not valid [2]');
        end;
      assert(LChild.XmlLink.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': XMLLink is not valid (2)');
      result := true;
      VElem := LChild.XMLLink;
      VDom := VElem.DOM;
      VTypeNS := LChild.TypeNamespace;
      VType := LChild.TypeName;
      end;
    end;
end;

{ TIdSoapArrayDescription }

procedure TIdSoapArrayDescription.ReadArrayInfo(AXmlElement : TIdSoapXmlElement; AInfo, AOffset : string);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapArrayDescription.ReadArrayInfo';
var
  LTemp : string;
  LSize : string;
  LJunk : string;
begin
  assert(self.TestValid(TIdSoapArrayDescription), ASSERT_LOCATION+': self is not valid');
  Assert(AInfo <> '', ASSERT_LOCATION+': Array Info is blank');

  Assert(Pos(':', AInfo) > 0, ASSERT_LOCATION+': Array Info does not contain a namespace code for '+AXmlElement.nodeName);
  SplitString(AInfo, ':', FBaseTypeNS, LTemp);
  if FBaseTypeNS = '' then
    begin
    FBaseTypeNS := ID_SOAP_NS_SCHEMA_2001
    end
  else
    begin
    FBaseTypeNS := NormaliseSchemaNamespace(AXmlElement.ResolveXMLNamespaceCode(FBaseTypeNS, 'Array type attribute on Element '+AXmlElement.NodeName));
    end;
  Assert(Pos('[', LTemp) > 0, ASSERT_LOCATION+': ArrayInfo "'+AInfo+'" does not contain ''ASize'' element');
  SplitWrappersRight(LTemp, '[', ']', LTemp, LSize, LJunk);
  Assert(LJunk = '', ASSERT_LOCATION+': ArrayInfo "'+AInfo+'" Contained info to right of ''ASize''');
  Assert(LSize <> '', ASSERT_LOCATION+': ArrayInfo "'+AInfo+'" Contained ''ASize'' = ""');
  FBaseDimensions := ReadArrayNumbers(LSize);
  while Pos('[', LTemp) > 0 do
    begin
    SplitWrappersRight(LTemp, '[', ']', LTemp, LSize, LJunk);
    Assert(LJunk = '', ASSERT_LOCATION+': ArrayInfo "'+AInfo+'" Contained info to right of ''Rank''');
    // actually, we ignore any information in the rank for the moment
    //SetLength(FOtherDimensions, LOffs+1);
    //FOtherDimensions[LOffs] := CharCount(LSize, ',') + 1;
    end;
  FBaseType := LTemp;
  if AOffset = '' then
    begin
    SetLength(FOffsets, length(FBaseDimensions));
    end
  else
    begin
    SplitWrappersRight(AOffset, '[', ']', LTemp, LSize, LJunk);
    Assert(LTemp = '', ASSERT_LOCATION+': ArrayInfo "'+AOffset+'" Contained info to left of ''Offset''');
    Assert(LJunk = '', ASSERT_LOCATION+': ArrayInfo "'+AOffset+'" Contained info to right of ''Offset''');
    Assert(LSize <> '', ASSERT_LOCATION+': ArrayInfo "'+AOffset+'" Contained ''Offset'' = ""');
    FOffsets := ReadArrayNumbers(LSize);
    IdRequire(Length(FOffsets) = length(FBaseDimensions), ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_DIM_MISSING, [AOffset, AInfo]));
    end;
end;

function TIdSoapArrayDescription.CheckFullyPopulated(ASoapNode: TIdSoapNode; AOffset: integer): boolean;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapArrayDescription.CheckFullyPopulated';
var
  i : integer;
begin
  assert(self.TestValid(TIdSoapArrayDescription), ASSERT_LOCATION+': self is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');

  if (AOffset = Length(FBaseDimensions) - 1) then
    begin
    result := (FOffsets[AOffset]+ ASoapNode.Params.count + ASoapNode.Children.count = FBaseDimensions[AOffset]);
    end
  else
    begin
    result := (ASoapNode.Children.count = FBaseDimensions[AOffset]);
    end;
  if result and (AOffset < Length(FBaseDimensions) - 1) then
    begin
    for i := 0 to ASoapNode.Children.Count - 1 do
      begin
      result := result and CheckFullyPopulated(ASoapNode.Children.objects[i] as TIdSoapNode, AOffset + 1);
      end;
    end;
end;

function TIdSoapArrayDescription.GetNodeForNextItem(AElement : TIdSoapXmlElement; AParent : TIdSoapNode; AArrayName : string; var VOffsets : TIdSoapArrayDimensions; Var VFirst : boolean; var VItemNum : string) : TIdSoapNode;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapArrayDescription.GetNodeForNextItem';
var
  LThisItem : TIdSoapArrayDimensions;
  LTemp : string;
  LLeft, LRight : string;
  i : integer;
  LDone : boolean;
  LTempNode : TIdSoapNode;
begin
  assert(self.TestValid(TIdSoapArrayDescription), ASSERT_LOCATION+': self is not valid');
  assert(AElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': AElement is not valid');
  assert(AParent.TestValid(TIdSoapNode), ASSERT_LOCATION+': AParent is not valid');
  assert(AArrayName <> '', ASSERT_LOCATION+': ArrayName is blank');

  if AElement.hasAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_NAME_SCHEMA_POSITION) then
    begin
    FUsedPositionAttribute := true;
    LTemp := AElement.getAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_NAME_SCHEMA_POSITION);
    SplitWrappersRight(LTemp, '[', ']', LLeft, LTemp, LRight);
    Assert(LLeft = '', ASSERT_LOCATION+': Error reading Array "'+AArrayName+'", Position attibute has junk to the left reading "'+AElement.getAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_NAME_SCHEMA_POSITION)+'"');
    Assert(LRight = '', ASSERT_LOCATION+': Error reading Array "'+AArrayName+'", Position attibute has junk to the right reading "'+AElement.getAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_NAME_SCHEMA_POSITION)+'"');
    LThisItem := ReadArrayNumbers(LTemp);
    IdRequire(Length(LThisItem) = Length(FBaseDimensions), ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_DIM_MISMATCH2, [AArrayName, AElement.getAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_NAME_SCHEMA_POSITION)]));
    for i := 0 to length(LThisItem) - 1 do
      begin
      IdRequire(Length(LThisItem) = Length(FBaseDimensions), ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_DIM_MISMATCH3, [AArrayName, AElement.getAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_NAME_SCHEMA_POSITION)]));
      end;
    end
  else
    begin
    IdRequire(not FUsedPositionAttribute, ASSERT_LOCATION+': '+RS_ERR_SOAP_ARRAY_ORDER_REQ);
    if VFirst then
      begin
      VOffsets := Copy(FOffsets, 0, length(FOffsets));
      LThisItem :=  VOffsets;
      VFirst := false;
      end
    else
      begin
      LDone := false;
      i := length(VOffsets);
      while (I > 0) and Not LDone do
        begin
        dec(i);
        inc(VOffsets[i]);
        if VOffsets[i] >= FBaseDimensions[i] then
          begin
          VOffsets[i] := FOffsets[i];
          end
        else
          begin
          LDone := true;
          end;
        end;
      IdRequire(LDone, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_DIM_MISMATCH4, [AArrayName]));
      end;
    LThisItem := VOffsets;
    end;
  assert(Length(LThisItem) > 0, ASSERT_LOCATION+': Error reading Array "'+AArrayName+'", no location for item');
  // LThisItem contains the actual location of this item in the array. Now we need to splice
  // off the lowest dimension offset as a name, and get the SoapNode for the next lowest dimension
  VItemNum := inttostr(LThisItem[length(LThisItem)-1]);
  Result := AParent;
  for i := 0 to length(LThisItem)-2 do
    begin
    if result.Children.IndexOf(inttostr(LThisItem[i])) > -1 then
      begin
      result := result.Children.Objects[result.Children.IndexOf(inttostr(LThisItem[i]))] as TIdSoapNode;
      end
    else
      begin
      LTempNode := result;
      result := TIdSoapNode.Create(inttostr(LThisItem[i]), AParent.TypeName, AParent.TypeNamespace, true, LTempNode, FReader);
      result.XMLLink := AElement;
      LTempNode.AddChild(Result.Name, result);
      end;
    end;
  assert(Assigned(result), ASSERT_LOCATION+': result = nil');
end;

procedure TIdSoapReaderXML.ReadArray(AXmlElement : TIdSoapXmlElement; ASoapnode : TIdSoapNode; AName : string = '');
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadArray';
var
  LId : string;
  LIdRef : integer;
  LArrayInfo : TIdSoapArrayDescription;
  LElement : TIdSoapXmlElement;
  LOffsets : TIdSoapArrayDimensions;
  LFirst : boolean;
  LSoapNode : TIdSoapNode;
  LItemNum : string;
  LName : string;
  LChildNode : TIdSoapNode;
  LArrType : string;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AXmlElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Element is not valid');
  assert((ASoapNode = nil) or ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': SoapNode is not valid');
  CheckSoapEncodingStyle(AXmlElement);

  if AName <> '' then
    begin
    LName := AName;
    end
  else
    begin
    LName := AXmlElement.NodeName;
    end;

  LArrType := AXmlElement.GetXSIType;
{  if (LArrType <> '') and (seoRequireTypes in EncodingOptions) then
    begin
    IdRequire(Pos(':', LArrType) > 0, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_NOT_ARRAY, [AXmlElement.nodeName, 'No Namespace']));
    SplitString(LArrType, ':', LTemp, LArrType);
    LTemp := NormaliseSchemaNamespace(AXmlElement.ResolveXMLNamespaceCode(LTemp, 'Element '+AXmlElement.nodeName+' attribute ArrayType'));
    IdRequire((seoArraysAnyNamespace in EncodingOptions) or (LTemp = ID_SOAP_NS_SOAPENC), ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_NOT_ARRAY, [AXmlElement.nodeName, 'Namespace is wrong']));
    IdRequire(AnsiSameText(LArrType, ID_SOAP_SOAPENC_ARRAY), ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_NOT_ARRAY, [AXmlElement.nodeName, 'Value is wrong']));
    end;}

  LArrayInfo := TIdSoapArrayDescription.create;
  try
    LArrayInfo.FReader := self;
    LArrayInfo.ReadArrayInfo(AXmlElement, AXmlElement.getAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_SOAPENC_ARRAYTYPE),
                             AXmlElement.getAttribute(ID_SOAP_NS_SOAPENC, ID_SOAP_NAME_SCHEMA_OFFSET));
    LChildNode := TIdSoapNode.create(LName, LArrayInfo.FBaseType, LArrayInfo.FBaseTypeNS, true, ASoapNode, self);
    LChildNode.XMLLink := AXmlElement;
    if assigned(ASoapNode) then
      begin
      assert(ASoapNode.Children.indexof(LName) = -1, ASSERT_LOCATION+': Attempt to add the parameter "'+LName+'" again');
      ASoapNode.Children.AddObject(LChildNode.Name, LChildNode);
      end
    else
      begin
      LId := AXmlElement.getAttribute('', ID_SOAP_NAME_XML_ID);
      LIdRef := StrToIntDef(LId, 0);
      if LIdRef <> 0 then
        begin
        ObjectReferences.AsObj[LIdRef] := LChildNode;
        end
      else
        begin
        NameReferences.AddObject(LId, LChildNode)
        end;
      end;
    SetLength(LOffsets, Length(LArrayInfo.FBaseDimensions));
    LElement := AXmlElement.firstChild;
    LFirst := true;
    while Assigned(LElement) do
      begin
      if LElement is TIdSoapXmlElement then
        begin
        LSoapNode := LArrayInfo.GetNodeForNextItem(LElement, LChildNode, AXmlElement.NodeName, LOffsets, LFirst, LItemNum);
        ReadElement(LElement, LSoapNode, LArrayInfo.FBaseTypeNS, LArrayInfo.FBaseType, LItemNum);
        end;
      LElement := LElement.nextSibling;
      end;
    if not LArrayInfo.FUsedPositionAttribute then
      IdRequire(LArrayInfo.CheckFullyPopulated(LChildNode, 0), ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_ARRAY_ITEMS_MISSING, [AXmlElement.NodeName]));
  finally
    FreeAndNil(LArrayInfo);
  end;
end;

procedure TIdSoapReaderXML.ReadReference(AXmlElement : TIdSoapXmlElement; ASoapnode : TIdSoapNode; AName : string = '');
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadReference';
var
  LId : string;
  LIdRef : integer;
  LName : string;
  LNameNS : string;
  LChildNode : TIdSoapNode;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AXmlElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': XmlElement is not valid');
  assert(ASoapnode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Soapnode is not valid');

  LId := AXmlElement.getAttribute('', ID_SOAP_NAME_XML_HREF);
  if AName <> '' then
    begin
    LName := AName;
    end
  else if Pos(':', AXmlElement.nodeName) > 0 then
    begin
    SplitString(AXmlElement.nodeName, ':', LNameNS, LName); // no default namespace at present, since this namespace is actually ignored
    end
  else
    begin
    LName := AXmlElement.nodeName;
    end;
  assert(LId <> '', ASSERT_LOCATION+': Id is blank for node '+LName);
  assert(LId[1] = '#', ASSERT_LOCATION+': Id[1] <> # for node '+LName);
  delete(LId, 1, 1);
  LIdRef := StrToIntDef(LId, 0);
  LChildNode := TIdSoapNode.create(LName, ID_SOAP_NAME_REF_TYPE, '', false, ASoapNode, self);
  LChildNode.XMLLink := AXmlElement;
  if EncodingMode = semRPC then
    begin
    assert(ASoapNode.Children.indexof(LName) = -1, ASSERT_LOCATION+': Attempt to add the child "'+LName+'" again');
    end;
  ASoapNode.AddChild(LName, LChildNode);
  if LIdRef <> 0 then
    begin
    LChildNode.ReadingReferenceId := LIdRef;
    end
  else
    begin
    LChildNode.ReadingReferenceName := LId;
    end;
end;

procedure TIdSoapReaderXML.ReadElement(AXmlElement : TIdSoapXmlElement; ASoapnode : TIdSoapNode; ATypeNS : string = ''; AType:String = ''; AName : string = '');
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadElement';
var
  LType : string;
  LTypeNS : string;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(AXmlElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Element is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': SoapNode is not valid');

  // first question, what kind of node is this. There's a little bit of guess work here,
  // and too a degree the only way to really know is to consult the WSDL (or ITI) for the service.
  // This is being avoided at this time. Will be reviewed continuously
  if AXmlElement.hasAttribute('', ID_SOAP_NAME_XML_HREF) then
    begin
    // this is a complex type or array by reference.
    ReadReference(AXmlElement, ASoapNode, AName);
    end
  else
    begin
    LType := AXmlElement.GetXSIType;
    if LType = '' then
      begin
      LTypeNS := ATypeNS;
      LType := AType;
      end
    else
      begin
      if Pos(':', LType) > 0 then
        begin
        SplitString(LType, ':', LTypeNS, LType);
        LTypeNS := NormaliseSchemaNamespace(AXmlElement.ResolveXMLNamespaceCode(LTypeNS, 'Type attribute on Element '+AXmlElement.nodeName));
        end
      else
        begin
        LTypeNS := ID_SOAP_NS_SCHEMA_2001;
        end;
      end;
    if ((seoArraysAnyNamespace in EncodingOptions) or AnsiSameText(LTypeNS, ID_SOAP_NS_SOAPENC)) and
         AnsiSameText(LType, ID_SOAP_SOAPENC_ARRAY) or (AXmlElement.hasAttribute(ID_SOAP_NS_SOAPENC,ID_SOAP_SOAPENC_ARRAYTYPE)) then
      begin
      // XML schema Array
      ReadArray(AXmlElement, ASoapNode, AName);
      end
    else if ((EncodingMode = semRPC) and ((LType <> '') and ((LTypeNS = '')) or AnsiSameText(LTypeNS, ID_SOAP_NS_SCHEMA_2001))) then
      begin
      // Schema type is automatically a simple type at this level
      ReadSimpleElement(AXmlElement, ASoapnode, ATypeNS, AType, AName);
      end
    else if AXmlElement.HasNilAttribute then
      begin
      ReadComplex(AXmlElement, ASoapNode, ATypeNS, AType, AName);
      end
    else if (LTypeNS = '') and (LType = '') and (AXmlElement.childcount = 0) and not (AXmlElement.HasText) then
      begin
      // oh dear. This is a real gotcha associated with the IndySoap infrastucture.
      // we are required to determine whether this is a complex type or a simple type
      // here. But we have no information on which to make this decision. It matters
      // later whether this is empty or not present - it's the difference between an
      // empty or a nil object. And since it matters even if we are dealing with
      // parameters (TStream), we ca't simply assume that it's a class. We can't add
      // it to both either, or we can ruin the late array conversion
      // This causes the first genuine hack in IndySoap. When the marshalling layer
      // is looking for an array, and it's looking for a child, and it doesn't find
      // one, it will check for an empty param in the param list.
      // GDG. 23-Aug 2002.
      ReadSimpleElement(AXmlElement, ASoapNode, ATypeNS, AType, AName);
      end
    else
      begin
      if (AXmlElement.HasText) then
        begin
        ReadSimpleElement(AXmlElement, ASoapNode, ATypeNS, AType, AName);
        end
      else
        begin
        ReadComplex(AXmlElement, ASoapNode, ATypeNS, AType, AName);
        end;
      end;
    end;
end;

procedure TIdSoapReaderXML.ReadBase(ARootElement : TIdSoapXmlElement; ASoapNode : TIdSoapNode);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadBase';
var
  LNode: TIdSoapXmlElement;
  LTemp : string;
  LType : string;
  LTypeNS : string;
begin
  assert(Self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  assert(ARootElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': XmlNode is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': SoapNode is not valid');
  CheckSoapEncodingStyle(ARootElement);
  LNode := ARootElement.FirstChild;
  while assigned(LNode) do
    begin
    assert(LNode.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Base Node is not valid');
    if FirstEntityName = '' then
      begin
      FirstEntityName := LNode.nodeName; // cause they aren't supposed to have namespaces
      end;
    if LNode.hasID then
      begin
      LTemp :=  LNode.GetXSIType;
      if Pos(':', LTemp) > 0 then
        begin
        SplitString(LTemp, ':', LTypeNS, LType);
        LTypeNS := NormaliseSchemaNamespace(LNode.ResolveXMLNamespaceCode(LTypeNS, 'Element '+LNode.nodeName));
        end
      else if LTemp <> '' then
        begin
        LTypeNS := ID_SOAP_NS_SCHEMA_2001;
        LType := LTemp;
        end;
      if ((seoArraysAnyNamespace in EncodingOptions) or (AnsiSameText(LTypeNS, ID_SOAP_NS_SOAPENC)) and
         AnsiSameText(LType, ID_SOAP_SOAPENC_ARRAY)) then
        begin
        ReadArray((LNode), nil);
        end
      else
        begin
        ReadComplex(LNode, nil);
        end;
      end
    else
      begin
      ReadElement(LNode, ASoapNode);
      end;
    LNode := LNode.nextSibling;
    end;
end;

procedure TIdSoapReaderXML.ReadReferences(AXmlElement: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.ReadReferences';
var
  LTemp : string;
  LType : string;
  LTypeNS : string;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');

  while assigned(AXmlElement) and AXmlElement.hasID do
    begin
    LTemp :=  AXmlElement.GetXSIType;
    if Pos(':', LTemp) > 0 then
      begin
      SplitString(LTemp, ':', LTypeNS, LType);
      LTypeNS := NormaliseSchemaNamespace(AXmlElement.ResolveXMLNamespaceCode(LTypeNS, 'Element '+AXmlElement.nodeName+' id '+AXmlElement.getAttribute('', ID_SOAP_NAME_XML_ID)));
      end
    else if LTemp <> '' then
      begin
      LTypeNS := ID_SOAP_NS_SCHEMA_2001;
      LType := LTemp;
      end
    else
      begin
      LTemp := AXmlElement.nodeName;
      if Pos(':', LTemp) > 0 then
        begin
        SplitString(LTemp, ':', LTypeNS, LType);
        LTypeNS := NormaliseSchemaNamespace(AXmlElement.ResolveXMLNamespaceCode(LTypeNS, 'Element '+AXmlElement.nodeName+' id '+AXmlElement.getAttribute('', ID_SOAP_NAME_XML_ID)));
        end
      else if LTemp <> '' then
        begin
        LTypeNS := ID_SOAP_NS_SCHEMA_2001;
        LType := LTemp;
        end
      end;
    if ((EncodingMode = semRPC) and ((LType <> '') and ((LTypeNS = '')) or AnsiSameText(LTypeNS, ID_SOAP_NS_SCHEMA_2001))) then
      begin
      ReadSimpleElement(AXmlElement, nil);
      end
    else if ((seoArraysAnyNamespace in EncodingOptions) or (AnsiSameText(LTypeNS, ID_SOAP_NS_SOAPENC)) and
       AnsiSameText(LType, ID_SOAP_SOAPENC_ARRAY)) then
      begin
      ReadArray(AXmlElement, nil);
      end
    else
      begin
      ReadComplex(AXmlElement, nil);
      end;
    AXmlElement := AXmlElement.nextSibling;
    end;
end;

function TIdSoapReaderXML.GetParamExists(ANode: TIdSoapNode; const AName: String): boolean;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamExists';
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  if ANode = nil then
    begin
    ANode := BaseNode;
    end;
  assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ANode not valid');
  assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode wrong owner');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  result := ANode.Params.IndexOf(AName) > -1;
end;


function TIdSoapReaderXML.GetParameter(ANode: TIdSoapNode; const AName: String): TIdReaderParameter;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParameter';
var
  LIndex : integer;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  if ANode = nil then
    begin
    ANode := BaseNode;
    end;
  assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ANode not valid');
  assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode wrong owner');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  LIndex := ANode.GetParamIndex(AName);

  if LIndex < 0 then
    begin
    IdRequire(seoUseDefaults in EncodingOptions, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_PARAM_MISSING, [AName, ANode.Params.CommaText]));
    result := nil;
    end
  else
    begin
    Result := ANode.Params.Objects[LIndex] as TIdReaderParameter;
    if assigned(result.FReference) then
      begin
      result := result.FReference;
      end;
    end;
end;

procedure TIdSoapReaderXML.EnforceType(const AParamName: string; const AParam : TIdReaderParameter; const ANamespaceList : array of string; ATypeList : array of string; ARoutineName: string); // clunky, but anamespace and aname iterate together
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.EnforceType';
var
  i : integer;
  LTypes : string;
  LFound : boolean;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  Assert(AParam.TestValid(TIdReaderParameter), ASSERT_LOCATION+': Param Type = ''''');
  Assert(ARoutineName <> '', ASSERT_LOCATION+': Routine Name = ''''');
  Assert(Length(ATypeList) <> 0, ASSERT_LOCATION+': no Types Provided');
  Assert((Length(ANamespaceList) = Length(ATypeList)) or (Length(ANamespaceList) = 1), ASSERT_LOCATION+': Namespace List length <> TypeList length');
  LTypes := '';
  for i := Low(ATypeList) to High(ATypeList) do
    begin
    Assert(ATypeList[i] <> '', ASSERT_LOCATION+': Type['+inttostr(i)+'] = ''''');
    if Length(ANamespaceList) = 1 then
      begin
      LTypes := CommaAdd(LTypes, '{'+ANamespaceList[0]+'}'+ATypeList[i]);
      end
    else
      begin
      Assert(ANamespaceList[i] <> '', ASSERT_LOCATION+': Namespace['+inttostr(i)+'] = ''''');
      LTypes := CommaAdd(LTypes, '{'+ANamespaceList[i]+'}'+ATypeList[i]);
      end;
    end;

  if (EncodingMode = semRPC) and (seoRequireTypes in EncodingOptions) then
    begin
    LFound := false;
    for i := Low(ATypeList) to High(ATypeList) do
      begin
      if Length(ANamespaceList) = 1 then
        begin
        LFound := LFound or ((AParam.FTypeNS = ANamespaceList[0]) and (AParam.FTypeVal = ATypeList[i]));
        end
      else
        begin
        LFound := LFound or ((AParam.FTypeNS = ANamespaceList[i]) and (AParam.FTypeVal = ATypeList[i]));
        end;
      end;
    IdRequire(LFound,
        Format(RS_ERR_SOAP_TYPE_MISMATCH_NS, [AParamName, AParam.FTypeVal, AParam.FTypeNS, LTypes]));
    end;
end;

function TIdSoapReaderXML.GetParamString(ANode: TIdSoapNode; const AName: String): String;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamString';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  if ANode = nil then
    begin
    ANode := BaseNode;
    end;
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam, [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_STRING], ASSERT_LOCATION);
    result := LParam.FValue;
    if seoUseCrLf in EncodingOptions then
      begin
      result := IdSoapAdjustLineBreaks(Result, tislbsCRLF);
      end;
    end
  else
    begin
    result := '';
    end;
end;

function TIdSoapReaderXML.GetParamInteger(ANode: TIdSoapNode; const AName: String): Integer;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamInteger';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_INTEGER, ID_SOAP_XSI_TYPE_SHORTINT, ID_SOAP_XSI_TYPE_SMALLINT, ID_SOAP_XSI_TYPE_WORD, ID_SOAP_XSI_TYPE_BYTE, ID_SOAP_XSI_TYPE_CARDINAL, ID_SOAP_XSI_TYPE_COMP, ID_SOAP_XSI_TYPE_CURRENCY], ASSERT_LOCATION);
    Result := IdStrToIntWithError(LParam.FValue, ASSERT_LOCATION+': Parameter ' + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamBoolean(ANode: TIdSoapNode; const AName: String): Boolean;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamBoolean';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    try
      EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_BOOLEAN], ASSERT_LOCATION);
      Result := XMLToBool(LParam.FValue);
    except
      raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_TYPE_NOT_BOOLEAN, [AName, LParam.FValue]));
    end
    end
  else
    begin
    result := false;
    end;
end;

function TIdSoapReaderXML.GetParamByte(ANode: TIdSoapNode; const AName: String): Byte;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamByte';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_BYTE], ASSERT_LOCATION);
    Result := IdStrToIntWithErrorAndRange(0, 255, LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamCardinal(ANode: TIdSoapNode; const AName: String): Cardinal;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamCardinal';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_CARDINAL, ID_SOAP_XSI_TYPE_SHORTINT, ID_SOAP_XSI_TYPE_SMALLINT, ID_SOAP_XSI_TYPE_WORD, ID_SOAP_XSI_TYPE_INTEGER, ID_SOAP_XSI_TYPE_BYTE, ID_SOAP_XSI_TYPE_CURRENCY], ASSERT_LOCATION);
    Result := IdStrToInt64WithErrorAndRange(0, $ffffffff, LParam.FValue, ASSERT_LOCATION+': '+RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamChar(ANode: TIdSoapNode; const AName: String): Char;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamChar';
var
  LString: String;
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_STRING], ASSERT_LOCATION);
    LString := LParam.FValue;
    Assert(Length(LString) = 1, ASSERT_LOCATION+':'+Format(RS_ERR_SOAP_TYPE_NOT_CHAR, [AName, LParam.FValue]));
    Result := LString[1];
    if seoUseCrLf in EncodingOptions then
      begin
      result := IdSoapAdjustLineBreaks(result, tislbsCRLF)[1];
      end;
    end
  else
    begin
    // no default value possible
    if ANode = nil then
      begin
      ANode := BaseNode;
      end;
    result := ' '; // just suppress the warning
    IdRequire(false, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_PARAM_MISSING, [AName, ANode.Params.CommaText]));
    end;
end;

function TIdSoapReaderXML.GetParamWideChar(ANode: TIdSoapNode; const AName: String): WideChar;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamWideChar';
var
  LString: WideString;
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam, [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_STRING], ASSERT_LOCATION);
    LString := LParam.FValue;
    Assert(Length(LString) = 1, ASSERT_LOCATION+':'+Format(RS_ERR_SOAP_TYPE_NOT_WIDECHAR, [AName, LParam.FValue]));
    Result := LString[1];
    end
  else
    begin
    // no default value possible
    result := ' '; // just suppress the warning
    IdRequire(false, ASSERT_LOCATION+': '+Format(RS_ERR_SOAP_PARAM_MISSING, [AName, ANode.Params.CommaText]));
    end;
end;

function TIdSoapReaderXML.GetParamComp(ANode: TIdSoapNode; const AName: String): Comp;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamComp';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam, [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_COMP], ASSERT_LOCATION);
    Result := IdStrToCompWithError(LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamCurrency(ANode: TIdSoapNode; const AName: String): Currency;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamCurrency';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_CURRENCY], ASSERT_LOCATION);
    try
      Result := IdStrToCurrencyWithError(LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    except
      raise EIdSoapBadParameterValue.Create(ASSERT_LOCATION+':'+Format(RS_ERR_SOAP_TYPE_NOT_CURRENCY, [AName, LParam.FValue]));
    end;
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamDateTime(ANode: TIdSoapNode; const AName: String): TDateTime;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamDateTime';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_DATETIME, ID_SOAP_XSI_TYPE_TIME, ID_SOAP_XSI_TYPE_DATE], ASSERT_LOCATION);
    Result := IdStrToDateTimeWithError(LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamDouble(ANode: TIdSoapNode; const AName: String): Double;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamDouble';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_DOUBLE, ID_SOAP_XSI_TYPE_INTEGER, ID_SOAP_XSI_TYPE_BYTE, ID_SOAP_XSI_TYPE_CARDINAL, ID_SOAP_XSI_TYPE_COMP, ID_SOAP_XSI_TYPE_CURRENCY, ID_SOAP_XSI_TYPE_EXTENDED, ID_SOAP_XSI_TYPE_SINGLE], ASSERT_LOCATION);
    Result := IdStrToDoubleWithError(LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamExtended(ANode: TIdSoapNode; const AName: String): Extended;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamExtended';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_DOUBLE, ID_SOAP_XSI_TYPE_INTEGER, ID_SOAP_XSI_TYPE_BYTE, ID_SOAP_XSI_TYPE_CARDINAL, ID_SOAP_XSI_TYPE_COMP, ID_SOAP_XSI_TYPE_CURRENCY, ID_SOAP_XSI_TYPE_EXTENDED, ID_SOAP_XSI_TYPE_SINGLE], ASSERT_LOCATION);
    Result := IdStrToExtendedWithError(LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamInt64(ANode: TIdSoapNode; const AName: String): Int64;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamInt64';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_INT64], ASSERT_LOCATION);
    Result := IdStrToInt64WithError(LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamShortInt(ANode: TIdSoapNode; const AName: String): ShortInt;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamShortInt';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_SHORTINT], ASSERT_LOCATION);
    Result := IdStrToIntWithErrorAndRange(-128, 127, LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamShortString(ANode: TIdSoapNode; const AName: String): ShortString;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamShortString';
Var
  LParam : TIdReaderParameter;
  LString: String;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_STRING], ASSERT_LOCATION);
    LString := LParam.FValue;
    Assert(length(LString) < 256, ASSERT_LOCATION+':'+Format(RS_ERR_SOAP_TYPE_NOT_SHORTSTRING, [AName, LParam.FValue]));
    Result := LString;
    if seoUseCrLf in EncodingOptions then
      begin
      result := IdSoapAdjustLineBreaks(result, tislbsCRLF);
      end;
    end
  else
    begin
    result := '';
    end;
end;

function TIdSoapReaderXML.GetParamSingle(ANode: TIdSoapNode; const AName: String): Single;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamSingle';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_SINGLE], ASSERT_LOCATION);
    Result := IdStrToSingleWithError(LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamSmallInt(ANode: TIdSoapNode; const AName: String): SmallInt;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamSmallInt';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_SMALLINT], ASSERT_LOCATION);
    Result := IdStrToIntWithErrorAndRange(-32768, 32767, LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamWideString(ANode: TIdSoapNode; const AName: String): WideString;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamWideString';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_STRING], ASSERT_LOCATION);
    Result := LParam.FValue;
    end
  else
    begin
    result := '';
    end;
end;

function TIdSoapReaderXML.GetParamWord(ANode: TIdSoapNode; const AName: String): Word;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamWord';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_WORD], ASSERT_LOCATION);
    Result := IdStrToIntWithErrorAndRange(0, 65535, LParam.FValue, RS_NAME_SOAP_PARAMETER + AName);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject): Integer;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamEnumeration';
var
  LParam : TIdReaderParameter;
  LEnumValue: String;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam, [ANameSpace], [ATypeName], ASSERT_LOCATION);
    assert(Assigned(ATypeInfo), ASSERT_LOCATION+': ATypeInfo is nil');
    LEnumValue := LParam.FValue;
    assert(LEnumValue <> '', ASSERT_LOCATION+': Enumeration value is empty');
    if assigned(AItiLink) then
      begin
      LEnumValue := AItiLink.ReverseReplaceEnumName(ATypeInfo^.Name, LEnumValue);
      end;
    Result := IdStringToEnum(ATypeInfo, LEnumValue);
    end
  else
    begin
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo): Integer;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamSet';
var
  LParam : TIdReaderParameter;
  LSetValue, LItem: String;
  LVal : Cardinal;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam, [ANamespace], [ATypeName], ASSERT_LOCATION);
    result := 0;
    LSetValue := LParam.FValue;
    repeat
      SplitString(Trim(LSetValue), ' ', LItem, LSetValue);
      if LItem <> '' then
        begin
        LVal := IdStringToEnum(ATypeInfo, LItem);
        result := result or (1 shl LVal);
        end
    until LSetValue = '';
    end
  else
    begin
    // default value
    result := 0;
    end;
end;

function TIdSoapReaderXML.GetGeneralParam(ANode: TIdSoapNode; const AName: string; var VNil: boolean; var VValue, VTypeNS, VType: string): boolean;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetGeneralParam';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  LParam := GetParameter(ANode, AName);
  result := assigned(LParam);
  if result then
    begin
    VNil := LParam.FIsNil;
    VValue := LParam.FValue;
    VTypeNS := LParam.FTypeNS;
    VType := LParam.FTypeVal;
    end;
end;

function TIdSoapReaderXML.GetParamBinaryBase64(ANode: TIdSoapNode; const AName: string): TStream;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamBinary';
Var
  LParam : TIdReaderParameter;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001, ID_SOAP_NS_SOAPENC], [ID_SOAP_XSI_TYPE_BASE64BINARY, ID_SOAP_SOAP_TYPE_BASE64BINARY], ASSERT_LOCATION);
    result := IdSoapBase64Decode(LParam.FValue);
    end
  else
    begin
    result := nil;
    end;
end;

function TIdSoapReaderXML.GetParamBinaryHex(ANode: TIdSoapNode; const AName: string): THexStream;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapReaderXML.GetParamBinary';
Var
  LParam : TIdReaderParameter;
  LStream : THexStream;
begin
  assert(self.TestValid(TIdSoapReaderXML), ASSERT_LOCATION+': Self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  // GetParameter will check other parameters
  LParam := GetParameter(ANode, AName);
  if assigned(LParam) and (not LParam.FIsNil) then
    begin
    EnforceType(AName, LParam,  [ID_SOAP_NS_SCHEMA_2001], [ID_SOAP_XSI_TYPE_HEXBINARY], ASSERT_LOCATION);
    LStream := THexStream.create;
    IdSoapHexToBin(IdStripTrailingEOL(LParam.FValue), LStream);
    LStream.position := 0;
    result := LStream;
    end
  else
    begin
    // default value
    result := nil;
    end;
end;

{ TIdSoapWriterXML }

constructor TIdSoapWriterXML.create(const ASoapVersion: TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider);
begin
  inherited;
  FNamespaceInfo := TIdSoapXmlNamespaceSupport.create;
  FNamespaceInfo.DefineNamespace(ID_SOAP_NS_SOAPENV, ID_SOAP_NS_SOAPENV_CODE);
  if ENcodingMode = semRPC then
    begin
    FNamespaceInfo.DefineNamespace(ID_SOAP_NS_SOAPENC, ID_SOAP_NS_SOAPENC_CODE);
    end;
  FNamespaceInfo.DefineNamespace(SchemaNamespace, ID_SOAP_NS_SCHEMA_CODE);
  FNamespaceInfo.DefineNamespace(SchemaInstanceNamespace, ID_SOAP_NS_SCHEMA_INST_CODE);

  FDom := IdSoapDomFactory(XmlProvider);
  FDom.StartBuild(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENV, DEF_OK)+ID_SOAP_NAME_ENV);
end;

destructor TIdSoapWriterXML.destroy;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.destroy';
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FDom);
  FreeAndNil(FNamespaceInfo);
  inherited;
end;

function TIdSoapWriterXML.ArrayIsSparse(ASoapNode: TIdSoapNode; AComplex: boolean): boolean;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.ArrayIsSparse';
var
  LList : TStringList;
  i : integer;
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ASoapNode is not valid');
  assert(ASoapNode.IsArray, ASSERT_LOCATION+': not an array');
  // no check AComplex

  if AComplex then
    begin
    LList := ASoapNode.Children;
    end
  else
    begin
    LList := ASoapNode.Params;
    end;
  result := false;
  if LList.Count <> 0 then
    begin
    for i := 0 to LList.count - 1 do
      begin
      if LList[i] <> inttostr(i) then
        begin
        result := true;
        exit;
        end;
      end;
    end;
end;

function TIdSoapWriterXML.GetArrayDepth(ASoapNode: TIdSoapNode): integer;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.GetArrayDepth';
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ASoapNode is not valid');
  assert(ASoapNode.IsArray, ASSERT_LOCATION+': not an array');

  if (ASoapNode.Children.Count > 0) and (ASoapNode.Children.Objects[0] as TIdSoapNode).IsArray then
    begin
    result := GetArrayDepth(ASoapNode.Children.Objects[0] as TIdSoapNode) + 1;
    end
  else
    begin
    result := 1;
    end;
end;

function TIdSoapWriterXML.EncodeArrayStraight(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode; AComplex : boolean):Integer;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeArrayStraight';
var
  LElement : TIdSoapXmlElement;
  i : integer;
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': FDom is not valid');
  assert(AParent.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': AParent is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ASoapNode is not valid');

  if AComplex then
    begin
    result := ASoapNode.Children.Count;
    for i := 0 to ASoapNode.Children.Count - 1 do
      begin
      LElement := AParent.appendChild(ID_SOAP_NAME_SCHEMA_ITEM);
      EncodeNode(LElement, ASoapNode.Children.Objects[i] as TIdSoapNode);
      end;
    end
  else
    begin
    result := ASoapNode.Params.Count;
    for i := 0 to ASoapNode.Params.Count - 1 do
      begin
      Assert(ASoapNode.Params[i] <> '', ASSERT_LOCATION+': Name of '+inttostr(i)+'th parameter is blank');
      LElement := AParent.appendChild(ID_SOAP_NAME_SCHEMA_ITEM);
      EncodeParam(ASoapNode.Params.objects[i] as TIdSoapWriterParameter, LElement, false);
      end;
    end;
end;

function TIdSoapWriterXML.EncodeArrayInLine(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode; AComplex : boolean):Integer;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeArrayInLine';
var
  LRoot : TIdSoapXmlElement;
  LName : string;
  LElement : TIdSoapXmlElement;
  i : integer;
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': FDom is not valid');
  assert(AParent.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': AParent is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ASoapNode is not valid');

  // we want to add our nodes at the same level as parent. So we move up a level and delete it
  // this is a bit of a hack, but better than re-working everything
  LName := AParent.nodeName;
  LRoot := AParent.parentNode;
  assert(LRoot.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Parent of Parent is not valid');
  LRoot.removeChild(AParent);

  if AComplex then
    begin
    result := ASoapNode.Children.Count;
    for i := 0 to ASoapNode.Children.Count - 1 do
      begin
      LElement := LRoot.appendChild(LName);
      EncodeNode(LElement, ASoapNode.Children.Objects[i] as TIdSoapNode);
      end;
    end
  else
    begin
    result := ASoapNode.Params.Count;
    for i := 0 to ASoapNode.Params.Count - 1 do
      begin
      Assert(ASoapNode.Params[i] <> '', ASSERT_LOCATION+': Name of '+inttostr(i)+'th parameter is blank');
      LElement := LRoot.appendChild(LName);
      EncodeParam(ASoapNode.Params.objects[i] as TIdSoapWriterParameter, LElement, false);
      end;
    end;
end;

procedure TIdSoapWriterXML.EncodeArrayComplex(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode; AComplex : boolean; ADepth : integer; ACurrentLocation : String; Var VArraySize : TIdSoapArrayDimensions);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeArrayComplex';
var
  LElement : TIdSoapXmlElement;
  i : integer;
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': FDom is not valid');
  assert(AParent.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': AParent is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ASoapNode is not valid');
  // no check AComplex, ACurrentLocation
  assert(ADepth > 0, ASSERT_LOCATION+': Depth = 0');

  if ADepth = 1 then
    begin
    if AComplex then
      begin
      for i := 0 to ASoapNode.Children.Count - 1 do
        begin
        VArraySize[Length(VArraySize) - ADepth] := Max(VArraySize[Length(VArraySize) - ADepth], IdStrToIntWithError(ASoapNode.Children[i], ASSERT_LOCATION+': '+ASoapNode.Name)+1);
        LElement := AParent.appendChild(ID_SOAP_NAME_SCHEMA_ITEM);
        LElement.setAttribute(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENC, NO_DEF)+ID_SOAP_NAME_SCHEMA_POSITION, '['+CommaAdd(ACurrentLocation,ASoapNode.Children[i])+']');
        EncodeNode(LElement, ASoapNode.Children.Objects[i] as TIdSoapNode);
        end;
      end
    else
      begin
      for i := 0 to ASoapNode.Params.Count - 1 do
        begin
        VArraySize[Length(VArraySize) - ADepth] := Max(VArraySize[Length(VArraySize) - ADepth], IdStrToIntWithError(ASoapNode.Params[i], 'Node Name in TIdSoapWriterXML.EncodeArrayComplex')+1);
        Assert(ASoapNode.Params[i] <> '', ASSERT_LOCATION+': Name of '+inttostr(i)+'th parameter is blank');
        LElement := AParent.appendChild(ID_SOAP_NAME_SCHEMA_ITEM);
        LElement.setAttribute(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENC, NO_DEF)+ID_SOAP_NAME_SCHEMA_POSITION, '['+CommaAdd(ACurrentLocation, ASoapNode.Params[i])+']');
        EncodeParam(ASoapNode.Params.objects[i] as TIdSoapWriterParameter, LElement, false);
        end;
      end;
    end
  else
    begin
    for i := 0 to ASoapNode.Children.Count - 1 do
      begin
      VArraySize[Length(VArraySize) - ADepth] := Max(VArraySize[Length(VArraySize) - ADepth], IdStrToIntWithError(ASoapNode.Children[i], ASSERT_LOCATION+': '+ASoapNode.Name)+1);
      EncodeArrayComplex(AParent, ASoapNode.Children.Objects[i] as TIdSoapNode, AComplex, ADepth - 1, CommaAdd(ACurrentLocation, ASoapNode.Children[i]), VArraySize);
      end;
    end;
end;


procedure TIdSoapWriterXML.EncodeArray(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeArray';
var
  LComplex : boolean;
  LDepth : integer;
  LSparse : boolean;
  LArrayType : string;
  i : integer;
  LArraySize : TIdSoapArrayDimensions;
  s  : String;
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': FDom is not valid');
  assert(AParent.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': AParent is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ASoapNode is not valid');

  AParent.setAttribute(FNamespaceInfo.GetNameSpaceCode(SchemaInstanceNamespace, NO_DEF)+ID_SOAP_NAME_SCHEMA_TYPE, FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENC, NO_DEF)+ID_SOAP_SOAPENC_ARRAY);
  assert(ASoapNode.TypeName <> '', ASSERT_LOCATION+': Array type not provided');

  assert((ASoapNode.Children.count = 0) or (ASoapNode.Params.count = 0), ASSERT_LOCATION+': Error in Array - the array has mixed content (both params and children)');

  LComplex := ASoapNode.IsComplexArray;
  LDepth := GetArrayDepth(ASoapNode);
  LSparse := (LDepth > 1) or ArrayIsSparse(ASoapNode, LComplex);
  LArrayType := FNamespaceInfo.GetNameSpaceCode(ASoapNode.TypeNamespace, NO_DEF)+ASoapNode.TypeName;

  if (EncodingMode = semDocument) or (seoArraysInLine in EncodingOptions) then
    begin
    IdRequire(Not LSparse, ASSERT_LOCATION+': Sparse Arrays Are not supported under Document/Literal Soap Encoding');
    EncodeArrayInline(AParent, ASoapNode, LComplex);
    end
  else if not LSparse then
    begin
    LArrayType := LArrayType+'['+inttostr(EncodeArrayStraight(AParent, ASoapNode, LComplex))+']';
    end
  else
    begin
    // now we need to iterate the SubNode Structure
    // encoding any real values that we find, including their full position in the array
    SetLength(LArraySize, LDepth);
    EncodeArrayComplex(AParent, ASoapNode, LComplex, LDepth, '', LArraySize);
    s := '';
    for i := 0 to LDepth - 1 do
      begin
      s := CommaAdd(s, inttostr(LArraySize[i]) );
      end;
    LArrayType := LArrayType+'['+s+']'; // open length
    end;
  if (EncodingMode = semRPC) and not (seoSuppressTypes in EncodingOptions) then
    begin
    AParent.setAttribute(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENC, NO_DEF)+ID_SOAP_SOAPENC_ARRAYTYPE, LArrayType);
    end;
end;

procedure TIdSoapWriterXML.EncodeComplex(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeComplex';
var
  LElement : TIdSoapXmlElement;
  i : integer;
begin
  assert(Self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': FDom is not valid');
  assert(AParent.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': AParent is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ASoapNode is not valid');

  if assigned(ASoapNode.Reference) then
    begin
    AParent.setAttribute(ID_SOAP_NAME_XML_HREF, '#'+IntToStr(ASoapnode.Reference.WritingReferenceId));
    end
  else
    begin
    if (ASoapNode <> BaseNode) then
      begin
      if (ASoapNode.ForceTypeInXML) or (not ((EncodingMode = semDocument) or (seoSuppressTypes in EncodingOptions))) then
        begin
        AParent.setAttribute(FNamespaceInfo.GetNameSpaceCode(SchemaInstanceNamespace, NO_DEF)+ID_SOAP_NAME_SCHEMA_TYPE, FNamespaceInfo.GetNameSpaceCode(ASoapNode.TypeNamespace, NO_DEF)+ASoapNode.TypeName);
        end;
      end;
    for i := 0 to ASoapNode.InOrder.count -1 do
      begin
      Assert(ASoapNode.InOrder[i] <> '', ASSERT_LOCATION+': Name of '+inttostr(i)+'th node is blank');
      if ASoapNode.InOrder.objects[i] is TIdSoapWriterParameter then
        begin
        LElement := AParent.appendChild(ASoapNode.InOrder[i]);
        EncodeParam(ASoapNode.InOrder.objects[i] as TIdSoapWriterParameter, LElement, true);
        end
      else
        begin
        LElement := AParent.appendChild(ASoapNode.InOrder[i]);
        EncodeNode(LElement, ASoapNode.InOrder.Objects[i] as TIdSoapNode);
        end;
      end;
    end;
end;

procedure TIdSoapWriterXML.EncodeNode(AParent: TIdSoapXmlElement; ASoapNode: TIdSoapNode);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeNode';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': DOM is not valid');
  assert(AParent.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Parent is not valid');
  assert(ASoapNode.TestValid(TIdSoapNode), ASSERT_LOCATION+': SoapNode is not valid');
  assert(Assigned(ASoapNode.Params), ASSERT_LOCATION+': SoapNode params is nil');
  assert(Assigned(ASoapNode.Children), ASSERT_LOCATION+': SoapNode Children is nil');

  if ASoapNode.IsArray then
    begin
    EncodeArray(AParent, ASoapNode);
    end
  else
    begin
    EncodeComplex(AParent, ASoapNode);
    end;
end;

procedure TIdSoapWriterXML.EncodeReferenceObjects(AParent: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeReferenceObjects';
var
  LProgressRec : TIdSoapKeyProgressRec;
  LCount : Cardinal;
  LKey : Cardinal;
  LNode : TIdSoapXmlElement;
  LSoapNode : TIdSoapNode;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(FDom.TestValid(TIdSoapXMLDOM), ASSERT_LOCATION+': DOM is not valid');
  assert(AParent.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Parent is not valid');
  Assert(ObjectReferences.TestValid(TIdSoapKeyList), ASSERT_LOCATION+': ObjectReferenceList is not valid');
  LCount := 0;
  if ObjectReferences.GetFirstKey(LProgressRec, LKey) then
    begin
    repeat
      inc(LCount);
      LSoapNode  := ObjectReferences.AsObj[LKey] as TIdSoapNode;
      // GDG 8/4/2002 as far as I can determine, this name has no namespace, or any particular significance
      // we use the name used in the first reference to the object. This name should not be assigned any particular significance
      LNode := AParent.appendChild(LSoapNode.Name);
      LNode.setAttribute(ID_SOAP_NAME_XML_ID, IntToStr(LSoapNode.WritingReferenceId));
      EncodeComplex(LNode, LSoapNode); // cause it can't be an array
    until not ObjectReferences.GetNextKey(LProgressRec, LKey);
    end;
  assert(LCount = ObjectReferences.Count, ASSERT_LOCATION+': LCount <> ObjectReferences.Count');
end;

procedure TIdSoapWriterXML.Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.Encode';
var
  LBody: TIdSoapXmlElement;
  LMethod: TIdSoapXmlElement;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  assert(MessageName <> '', ASSERT_LOCATION+': A Message name must be provided');
  assert(MessageNameSpace <> '', ASSERT_LOCATION+': A Message namespace must be provided');

  VMimeType := GetMimeType;

  WriteHeaders(FDom.Root);
  LBody := FDom.Root.appendChild(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENV, DEF_OK)+ID_SOAP_NAME_BODY);
  if ENcodingMode = semRPC then
    begin
    LMethod := LBody.appendChild(FNamespaceInfo.GetNameSpaceCode(MessageNamespace, DEF_OK)+MessageName);
    LMethod.setAttribute(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENV, DEF_OK)+ID_SOAP_NAME_ENCODINGSTYLE, ID_SOAP_NS_SOAPENC);
    end
  else
    begin
    LMethod := LBody.appendChild(MessageName);
    FNamespaceInfo.DefineDefaultNamespace(MessageNamespace, LMethod);
    end;

  EncodeNode(LMethod, BaseNode);
  EncodeReferenceObjects(LMethod);

  FNamespaceInfo.AddNamespaceDefinitions(FDom.Root);

  if assigned(AEvent) then
    begin
    AEvent(ACaller, FDom);
    end;

  if FUseUTF16 then
    FDom.writeUTF16(AStream)
  else
    FDom.writeUTF8(AStream);

  // ok, now we have the stream. Do we have attachments?
  if Attachments.count > 0 then
    begin
    EncodeAttachments(AStream, VMimeType);
    end;
end;

function  TIdSoapWriterXML.AddArray(ANode: TIdSoapNode; const AName, ABaseType, ABaseTypeNS: String; ABaseTypeComplex : boolean): TIdSoapNode;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.AddArray';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    ANode := BaseNode;
  assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ANode not valid');
  assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode belongs to wrong owner');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  Assert(ANode.Children.IndexOf(AName) = -1, ASSERT_LOCATION+': The Node Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');
  Result := TIdSoapNode.Create(AName, ABaseType, ABaseTypeNS, true, ANode, Self);
  result.IsComplexArray := ABaseTypeComplex;
  ANode.AddChild(AName, Result);
end;

procedure TIdSoapWriterXML.DefineParameter(ANode: TIdSoapNode; const AName, AType, ATypeNamespace, AValue: String; AIsNil : boolean = false);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParameter';
var
  LParamInfo : TIdSoapWriterParameter;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    begin
    ANode := BaseNode;
    end;
  assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ANode not valid');
  assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode not valid');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  Assert(AType <> '', ASSERT_LOCATION+': AType is Blank');
  Assert(ATypeNamespace <> '', ASSERT_LOCATION+': Type Namespace is Blank');
  // we don't check AValue
  assert(ANode.Params.IndexOf(AName) = -1, ASSERT_LOCATION+': The Parameter Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');
  assert(ANode.Children.IndexOf(AName) = -1, ASSERT_LOCATION+': The Parameter Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');

  LParamInfo := TIdSoapWriterParameter.create;
  LParamInfo.FType := AType;
  if (EncodingMode = semRPC) and not (seoSuppressTypes in EncodingOptions) then
    begin
    LParamInfo.FTypeNamespaceCode := FNamespaceInfo.GetNameSpaceCode(ATypeNamespace, NO_DEF);
    end;
  LParamInfo.FUseWideString := false;
  LParamInfo.FValue := AValue;
  LParamInfo.FIsNil := AIsNil;
  ANode.AddParam(AName, LParamInfo);
end;

procedure TIdSoapWriterXML.DefineParameterW(ANode: TIdSoapNode; const AName, AType, ATypeNamespace: String; AValue : WideString);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParameterW';
var
  LParamInfo : TIdSoapWriterParameter;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    begin
    ANode := BaseNode;
    end;
  assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ANode not valid');
  assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode not valid');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');
  Assert(AType <> '', ASSERT_LOCATION+': AType is Blank');
  Assert(ATypeNamespace <> '', ASSERT_LOCATION+': Type Namespace is Blank');
  // we don't check AValue

  assert(ANode.Params.IndexOf(AName) = -1, ASSERT_LOCATION+': The Parameter Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');
  assert(ANode.Children.IndexOf(AName) = -1, ASSERT_LOCATION+': The Parameter Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');

  LParamInfo := TIdSoapWriterParameter.create;
  LParamInfo.FType := AType;
  if (EncodingMode = semRPC) and not (seoSuppressTypes in EncodingOptions) then
    begin
    LParamInfo.FTypeNamespaceCode := FNamespaceInfo.GetNameSpaceCode(ATypeNamespace, NO_DEF);
    end;
  LParamInfo.FUseWideString := true;
  LParamInfo.FValueW := AValue;
  ANode.AddParam(AName, LParamInfo);
end;

procedure TIdSoapWriterXML.DefineParamString(ANode: TIdSoapNode; const AName, AValue: String);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamString';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name = ''''');
  // no check on AValue
  if seoCheckStrings in EncodingOptions then
    begin
    CheckForBadCharacters(AValue, AName, ASSERT_LOCATION);
    end;
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_STRING, SchemaNamespace, IdSoapAdjustLineBreaks(AValue, tislbsLF));
end;

procedure TIdSoapWriterXML.DefineParamInteger(ANode: TIdSoapNode; const AName: String; AValue: Integer);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamInteger';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_INTEGER, SchemaNamespace, IntToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamBoolean(ANode: TIdSoapNode; const AName: String; AValue: Boolean);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamBoolean';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  // false is default valud but we will code it anyway
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_BOOLEAN, SchemaNamespace, BoolToXML(AValue, True));
end;

procedure TIdSoapWriterXML.DefineParamByte(ANode: TIdSoapNode; const AName: String; AValue: Byte);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamByte';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_BYTE, SchemaNamespace, IntToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamCardinal(ANode: TIdSoapNode; const AName: String; AValue: Cardinal);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamCardinal';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_CARDINAL, SchemaNamespace, IntToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamChar(ANode: TIdSoapNode; const AName: String; AValue: Char);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamChar';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  AValue := IdSoapAdjustLineBreaks(AValue, tislbsLF)[1];
  if seoCheckStrings in EncodingOptions then
    begin
    CheckForBadCharacters(AValue, AName, ASSERT_LOCATION);
    end;
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_STRING, SchemaNamespace, AValue);
end;

procedure TIdSoapWriterXML.DefineParamWideChar(ANode: TIdSoapNode; const AName: String; AValue: WideChar);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamWideChar';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameterW(ANode, AName, ID_SOAP_XSI_TYPE_STRING, SchemaNamespace, AValue);
end;

procedure TIdSoapWriterXML.DefineParamComp(ANode: TIdSoapNode; const AName: String; AValue: Comp);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamComp';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_COMP, SchemaNamespace, IdCompToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamCurrency(ANode: TIdSoapNode; const AName: String; AValue: Currency);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamCurrency';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_CURRENCY, SchemaNamespace, IdCurrencyToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamDateTime(ANode: TIdSoapNode; const AName: String; AValue: TDateTime);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamDateTime';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  if AValue <> 0 then
    DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_DATETIME, SchemaNamespace, IdDateTimeToStr(AValue, RS_NAME_SOAP_PARAMETER+AName));
end;

procedure TIdSoapWriterXML.DefineParamDouble(ANode: TIdSoapNode; const AName: String; AValue: Double);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamDouble';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_DOUBLE, SchemaNamespace, IdDoubleToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamExtended(ANode: TIdSoapNode; const AName: String; AValue: Extended);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamExtended';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_EXTENDED, SchemaNamespace, IdExtendedToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamInt64(ANode: TIdSoapNode; const AName: String; AValue: Int64);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamInt64';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_INT64, SchemaNamespace, IntToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamShortInt(ANode: TIdSoapNode; const AName: String; AValue: ShortInt);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamShortInt';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_SHORTINT, SchemaNamespace, IntToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamShortString(ANode: TIdSoapNode; const AName: String; AValue: ShortString);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamShortString';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  AValue := IdSoapAdjustLineBreaks(AValue, tislbsLF);
  if seoCheckStrings in EncodingOptions then
    begin
    CheckForBadCharacters(AValue, AName, ASSERT_LOCATION);
    end;
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_STRING, SchemaNamespace, AValue);
end;

procedure TIdSoapWriterXML.DefineParamSingle(ANode: TIdSoapNode; const AName: String; AValue: Single);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamSingle';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_SINGLE, SchemaNamespace, IdSingleToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamSmallInt(ANode: TIdSoapNode; const AName: String; AValue: SmallInt);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamSmallInt';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_SMALLINT, SchemaNamespace, IntToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamWideString(ANode: TIdSoapNode; const AName: String; const AValue: WideString);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamWideString';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameterW(ANode, AName, ID_SOAP_XSI_TYPE_STRING, SchemaNamespace, AValue);
end;

procedure TIdSoapWriterXML.DefineParamWord(ANode: TIdSoapNode; const AName: String; AValue: Word);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamWord';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_WORD, SchemaNamespace, IntToStr(AValue));
end;

procedure TIdSoapWriterXML.DefineParamXML(ANode: TIdSoapNode; AName: string; AXml: TIdSoapXmlElement; ATypeNamespace, ATypeName : string);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamXML';
var
  LParamInfo : TIdSoapWriterParameter;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  if ANode = NIL then
    begin
    ANode := BaseNode;
    end;
  assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': ANode not valid');
  assert(ANode.Owner = Self, ASSERT_LOCATION+': ANode not valid');
  Assert(AName <> '', ASSERT_LOCATION+': AName is Blank');

  assert(ANode.Params.IndexOf(AName) = -1, ASSERT_LOCATION+': The Parameter Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');
  assert(ANode.Children.IndexOf(AName) = -1, ASSERT_LOCATION+': The Parameter Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');

  LParamInfo := TIdSoapWriterParameter.create;
  if ATypeName <> '' then
    begin
    LParamInfo.FType := ATypeName;
    LParamInfo.FTypeNamespaceCode := FNamespaceInfo.GetNameSpaceCode(ATypeNamespace, false);
    end;
  LParamInfo.FUseWideString := false;
  LParamInfo.FElem := FDom.ImportElement(AXml);
  ANode.AddParam(AName, LParamInfo);
end;

procedure TIdSoapWriterXML.DefineParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject; AValue: Integer);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamEnumeration';
var
  LVal: String;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  assert(ATypeInfo <> NIL, ASSERT_LOCATION+': ATypeInfo = nil');
  assert(IdEnumIsValid(ATypeInfo, AValue), ASSERT_LOCATION+': Enumeration Out of Range (' + IntToStr(AValue) + ':' + ATypeInfo.Name + ')');
  // DefineParameter will check parameters

  LVal := IdEnumToString(ATypeInfo, AValue);
  Assert(LVal <> '', 'Unknown enumeration value [' + IntToStr(AValue) + '] in Enumeration Type [' + ATypeInfo^.Name +']');
  if assigned(AItiLink) then
    begin
    LVal := AItiLink.ReplaceEnumName(ATypeInfo^.Name, LVal);
    end;
  DefineParameter(ANode, AName, ATypeName, ANameSpace, LVal);
end;

procedure TIdSoapWriterXML.DefineParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo; AValue: Integer);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamSet';
var
  LTypeData : PTypeData;
  i : integer;
  LTokens : String;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check parameters
  assert(assigned(ATypeInfo), ASSERT_LOCATION+': Typeinfo is not valid');

  LTokens := '';
  LTypeData := GetTypeData(ATypeInfo);
  for i := LTypeData.MinValue to LTypeData.MaxValue do
    begin
    if AValue and (1 shl i) > 0 then
      begin
      LTokens := LTokens + IdEnumToString(ATypeInfo, i)+' ';
      end
    end;
  DefineParameter(ANode, AName, ATypeName, ANamespace, TrimRight(LTokens));
end;

procedure TIdSoapWriterXML.DefineParamBinaryBase64(ANode: TIdSoapNode; const AName: string; AStream: TStream);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamBinary';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check Node, Name
  if assigned(AStream) then
    begin
    DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_BASE64BINARY, SchemaNamespace, IdSoapBase64Encode(AStream, false));
    end
  else
    begin
    // nil is default value
    end;
end;

procedure TIdSoapWriterXML.DefineParamBinaryHex(ANode: TIdSoapNode; const AName: string; AStream: THexStream);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineParamBinary';
var
  LHex : string;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // DefineParameter will check Node, Name
  if assigned(AStream) then
    begin
    LHex := IdSoapBinToHex(AStream);
    DefineParameter(ANode, AName, ID_SOAP_XSI_TYPE_HEXBINARY, SchemaNamespace, LHex);
    end
  else
    begin
    // nil is default value
    end;
end;

function TIdSoapWriterXML.GetMimeType: String;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.GetMimeType';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  // 0.03 - don't send charset unless required to do so
  if seoSendCharset in EncodingOptions then
    begin
    if FUseUTF16 then
      begin
      result := ID_SOAP_HTTP_SOAP_TYPE+'; '+ID_SOAP_CHARSET_16;
      end
    else
      begin
      result := ID_SOAP_HTTP_SOAP_TYPE+'; '+ID_SOAP_CHARSET_8;
      end;
    end
  else
    begin
    result := ID_SOAP_HTTP_SOAP_TYPE;
    end;
end;

procedure TIdSoapWriterXML.SetNilAttribute(AXmlElement : TIdSoapXmlElement; AValue : boolean);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.SetNilAttribute';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  assert(AXmlElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Element is not valid');
  // no check AValue

  if seoUseNullForNil in EncodingOptions then
    begin
    AXmlElement.setAttribute(FNamespaceInfo.GetNameSpaceCode(SchemaInstanceNamespace, NO_DEF)+ID_SOAP_XSI_ATTR_NULL, BoolToXML(AValue));
    end
  else
    begin
    AXmlElement.setAttribute(FNamespaceInfo.GetNameSpaceCode(SchemaInstanceNamespace, NO_DEF)+ID_SOAP_XSI_ATTR_NIL, BoolToXML(AValue));
    end;
end;

procedure TIdSoapWriterXML.WriteHeaders(ADocElement : TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.CheckHeaders';
var
  LHeaderElem : TIdSoapXmlElement;
  LElem : TIdSoapXmlElement;
  i : integer;
  LHeader : TIdSoapHeader;
  LStr : TIdSoapString;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': Self is not valid');
  if FHeaders.Count > 0 then
    begin
    LHeaderElem := ADocElement.appendChild(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENV, DEF_OK)+ID_SOAP_NAME_HEADER);
    FNamespaceInfo.DefineDefaultNamespace(MessageNamespace, LHeaderElem);
    try
      for i := 0 to FHeaders.count -1 do
        begin
        LHeader := FHeaders.Items[i] as TIdSoapHeader;
        if assigned(LHeader.Node) then
          begin
          EncodeComplex(LHeaderElem, LHeader.Node);
          end
        else
          begin
          LElem := LHeaderElem.appendChild(FNamespaceInfo.GetNameSpaceCode(LHeader.Namespace, DEF_OK)+LHeader.Name);
          LStr := LHeader.Content as TIdSoapString;
          LElem.TextContentA := LStr.Value;
          if LHeader.MustUnderstand then
            begin
            LElem.setAttribute(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENV, DEF_OK)+ ID_SOAP_NAME_MUSTUNDERSTAND, '1');
            end;
          end;
        end;
    finally
      FNamespaceInfo.UnDefineDefaultNamespace;
    end;
    end;
end;

procedure TIdSoapWriterXML.EncodeAttachments(AStream: TStream; var VMimeType : String);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeAttachments';
var
  LDime : TIdSoapDimeMessage;
  LRec : TIdSoapDimeRecord;
  LAtt : TIdSoapAttachment;
  i : integer;
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  assert(Assigned(AStream), ASSERT_LOCATION+': stream is not valid');
  AStream.position := 0;
  VMimeType := ID_SOAP_HTTP_DIME_TYPE;
  LDime := TIdSoapDimeMessage.create;
  try
    LRec := LDime.Add('SoapPrimary');
    LRec.TypeType := dtURI;
    LRec.TypeInfo := 'http://schemas.xmlsoap.org/soap/envelope/';
    LRec.Content.CopyFrom(AStream, 0);
    for i := 0 to Attachments.count -1 do
      begin
      LAtt := Attachments.AttachmentByIndex[i];
      LRec := LDime.Add(LAtt.Id);
      if LAtt.MimeType <> '' then
        begin
        LRec.TypeType := dtMime;
        LRec.TypeInfo := LAtt.MimeType;
        end
      else if LAtt.UriType <> '' then
        begin
        LRec.TypeType := dtURI;
        LRec.TypeInfo := LAtt.URIType;
        end
      else
        begin
        LRec.TypeType := dtNotKnown;
        end;
      LRec.Content.Free;
      LRec.Content := LAtt.Content;
      LAtt.Content := nil;
      end;
    AStream.Size := 0;
    LDime.WriteToStream(AStream);
  finally
    FreeAndNil(LDime);
  end;
end;

procedure TIdSoapWriterXML.DefineGeneralParam(ANode: TIdSoapNode; ANil : boolean; AName, AValue, ATypeNS, AType: string);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineGeneralParam';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  if not ((EncodingMode = semDocument) and ANil) then
    begin
    DefineParameter(ANode, AName, AType, ATypeNS, AValue, ANil);
    end;
end;

function TIdSoapWriterXML.DefineNamespace(ANamespace: string): String;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.DefineNamespace';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  result := FNamespaceInfo.GetNameSpaceCode(ANamespace, false);
end;

procedure TIdSoapWriterXML.EncodeParam(AParamInfo: TIdSoapWriterParameter; AElement: TIdSoapXMlElement; AIncludeType : boolean);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapWriterXML.EncodeParam';
begin
  assert(self.TestValid(TIdSoapWriterXML), ASSERT_LOCATION+': self is not valid');
  Assert(AParamInfo.TestValid(TIdSoapWriterParameter), ASSERT_LOCATION+': ParamInfo is not valid');
  assert(AElement.TestValid(TIdSoapXMlElement), ASSERT_LOCATION+': Element is not valid');
  // no check AIncludeType

  if AIncludeType and (EncodingMode = semRPC) and not (seoSuppressTypes in EncodingOptions) then
    begin
    AElement.setAttribute(FNamespaceInfo.GetNameSpaceCode(SchemaInstanceNamespace, NO_DEF)+ID_SOAP_NAME_SCHEMA_TYPE,  AParamInfo.FTypeNamespaceCode+AParamInfo.FType);
    end;
  if assigned(AParamInfo.FElem) then
    begin
    AElement.GrabChildren(AParamInfo.FElem, false);
    end
  else
    begin
    if AParamInfo.FIsNil and (EncodingMode = semRPC) then
      begin
      SetNilAttribute(AElement, true);
      end
    else if AParamInfo.FUseWideString then
      begin
      AElement.TextContentW := AParamInfo.FValueW;
      end
    else
      begin
      AElement.TextContentA := AParamInfo.FValue;
      end;
    end;
end;

{ TIdSoapFaultWriterXml }
procedure TIdSoapFaultWriterXml.BuildDetailsXML(ADom: TIdSoapXMLDOM; AFaultNode: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapFaultWriterXml.BuildDetailsXML';
var
  LDetails : TIdSoapXmlElement;
begin
  assert(self.TestValid(TIdSoapFaultWriterXml), ASSERT_LOCATION+': self is not valid');
  assert(ADom.TestValid(TIdSoapXMLDOM) , ASSERT_LOCATION+': DOM is not valid');
  assert(AFaultNode.TestValid(TIdSoapXmlElement) , ASSERT_LOCATION+': FaultNode is not valid');
  assert(FDetails <> '', ASSERT_LOCATION+': Fault details are not valid');

  // FDetails Contain an arbitrary anything.
  // if the first character is not < then it is not XML. we will insert it as text
  if pos('<', FDetails) <> 1 then
    begin
    LDetails := AFaultNode.appendChild(ID_SOAP_NAME_FAULTDETAIL);
    LDetails.TextContentW := FDetails;
    end
  else
    begin
    AFaultNode.BuildChildFromXML(FDetails);
    end;
end;

procedure TIdSoapFaultWriterXml.Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapFaultWriterXml.Encode';
var
  LDom: TIdSoapXMLDOM;
  LBody: TIdSoapXmlElement;
  LFault: TIdSoapXmlElement;
  LDetails: TIdSoapXmlElement;
  LElement: TIdSoapXmlElement;
begin
  // it's a bit of a problem with exceptions here. But what can one do?
  assert(self.TestValid(TIdSoapFaultWriterXml), ASSERT_LOCATION+': self is not valid');
  assert((FMessage <> '') and (FClass <> ''), ASSERT_LOCATION+': Attempt to Encode an Exception before any information provided');
  VMimeType := GetMimeType;
  LDom := IdSoapDomFactory(XmlProvider);
  try
    LDom.StartBuild(ID_SOAP_NS_SOAPENV_CODE+':'+ID_SOAP_NAME_ENV);
    LDom.Root.setAttribute(ID_SOAP_NAME_XML_XMLNS+':'+ID_SOAP_NS_SOAPENV_CODE, ID_SOAP_NS_SOAPENV);
    LDom.Root.setAttribute(ID_SOAP_NAME_XML_XMLNS+':'+ID_SOAP_NS_SOAPENC_CODE, ID_SOAP_NS_SOAPENC);
    LDom.Root.setAttribute(ID_SOAP_NAME_XML_XMLNS+':'+ID_SOAP_NS_SCHEMA_CODE, ID_SOAP_NS_SCHEMA_2001);
    LDom.Root.setAttribute(ID_SOAP_NAME_XML_XMLNS+':'+ID_SOAP_NS_SCHEMA_INST_CODE, ID_SOAP_NS_SCHEMA_INST_2001);
    WriteHeaders(LDom, LDom.Root);
    LBody := LDom.Root.appendChild(ID_SOAP_NS_SOAPENV_CODE+':'+ID_SOAP_NAME_BODY);
    LFault := LBody.appendChild(ID_SOAP_NS_SOAPENV_CODE+':'+ID_SOAP_NAME_FAULT);

    if FCode <> '' then
      begin
      LElement := LFault.appendChild(ID_SOAP_NS_SOAPENV_CODE+':'+ID_SOAP_NAME_FAULTCODE);
      LElement.TextContentA := ID_SOAP_NS_SOAPENV_CODE+':'+FCode;
      end
    else
      begin
      LElement := LFault.appendChild(ID_SOAP_NS_SOAPENV_CODE+':'+ID_SOAP_NAME_FAULTCODE);
      LElement.TextContentA := ID_SOAP_NS_SOAPENV_CODE+':'+RS_NAME_SOAP_ERROR_SOURCE;
      end;

    if FActor <> '' then
      begin
      LElement := LFault.appendChild(ID_SOAP_NS_SOAPENV_CODE+':'+ID_SOAP_NAME_FAULTACTOR);
      LElement.TextContentA := FActor;
      end;

    LElement := LFault.appendChild(ID_SOAP_NS_SOAPENV_CODE+':'+ID_SOAP_NAME_FAULTSTRING);
    LElement.TextContentW := FMessage; // we need to consider how we might really tell and what the SOAP standard thinks it means anyway

    if FDetails <> '' then
      begin
      BuildDetailsXML(LDom, LFault);
      end
    else
      begin
      LDetails := LFault.appendChild(ID_SOAP_NAME_FAULTDETAIL);
      LDetails.setAttribute(ID_SOAP_NS_SCHEMA_INST_CODE+':'+ID_SOAP_NAME_SCHEMA_TYPE, FClass);
      end;

    if assigned(AEvent) then
      begin
      AEvent(ACaller, LDom);
      end;
    if FUseUTF16 then
      begin
      LDom.writeUTF16(AStream)
      end
    else
      begin
      LDom.writeUTF8(AStream);
      end;
  finally
    FreeAndNil(LDom);
  end;
end;

function TIdSoapFaultWriterXml.GetMimeType: String;
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapFaultWriterXml.GetMimeType';
begin
  assert(self.TestValid(TIdSoapFaultWriterXml), ASSERT_LOCATION+': self is not valid');
  if FUseUTF16 then
    begin
    result := ID_SOAP_HTTP_SOAP_TYPE+'; '+ID_SOAP_CHARSET_16;
    end
  else
    begin
    result := ID_SOAP_HTTP_SOAP_TYPE+'; '+ID_SOAP_CHARSET_8;
    end;
end;

procedure TIdSoapFaultWriterXml.WriteHeaders(ADom: TIdSoapXMLDOM; ADocElement: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapRpcXml.TIdSoapFaultWriterXml.CheckHeaders';
var
  LHeaderElem : TIdSoapXmlElement;
  i : integer;
  LElem : TIdSoapXmlElement;
  LHeader : TIdSoapHeader;
  LStr : TIdSoapString;
begin
  assert(self.TestValid(TIdSoapFaultWriterXml), ASSERT_LOCATION+': Self is not valid');
  if FHeaders.Count > 0 then
    begin
    LHeaderElem := ADocElement.appendChild(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENV, DEF_OK)+ID_SOAP_NAME_HEADER);
    for i := 0 to FHeaders.count -1 do
      begin
      LHeader := FHeaders.Items[i] as TIdSoapHeader;
      LElem := LHeaderElem.appendChild(FNamespaceInfo.GetNameSpaceCode(LHeader.Namespace, DEF_OK)+LHeader.Name);
      LStr := LHeader.Content as TIdSoapString;
      LElem.TextContentA := LStr.Value;
      if LHeader.MustUnderstand then
        begin
        LElem.setAttribute(FNamespaceInfo.GetNameSpaceCode(ID_SOAP_NS_SOAPENV, DEF_OK)+ ID_SOAP_NAME_MUSTUNDERSTAND, '1');
        end;
      end;
    end;

end;

{ TIdSoapWriterParameter }

destructor TIdSoapWriterParameter.destroy;
begin
  FreeAndNil(FElem);
  inherited;
end;

end.


//  checking MustUnderstand
//      IdRequire(not ACheckMustUnderstand or (LNode.getAttribute(ID_SOAP_NS_SOAPENV, ID_SOAP_NAME_MUSTUNDERSTAND) <> '1'),
//        ASSERT_LOCATION+': Soap Processing Rules failed - Unable to understand mustUnderstand Header "'+LNode.nodeName+'"');

