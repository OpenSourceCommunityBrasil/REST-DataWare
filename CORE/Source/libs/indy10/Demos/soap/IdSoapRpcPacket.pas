{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15764: IdSoapRpcPacket.pas 
{
{   Rev 1.2    20/6/2003 00:03:58  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:03:38  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:35:56  GGrieve
}
{
IndySOAP: This unit defines the abstract interface to the actual packet layer

There is multiple actual packet layers. These are summarised here:

  IdSoapRpcXML   SOAP Compliant XML based packet encoding

  IdSoapRpcBin   Stream Based packet encoding. This is not standard and
                 can only be used when both client and server a running
                 IndySOAP. But it's very fast

}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Headers and polymorphism + performance
  18-Mar 2003   Grahame Grieve                  QName and RawXML support, moce special classes to IdSoapRpcUtil
  29-Oct 2002   Grahame Grieve                  IdSoapSimpleClass, IdSoapFault enhancements. Write parameters in order
  04-Oct 2002   Grahame Grieve                  Attachments
  26-Sep 2002   Grahame Grieve                  Header Support
  19-Sep 2002   Grahame Grieve                  Introduce seoSendCharset
  17-Sep 2002   Grahame Grieve                  HexBinary Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  28-Aug 2002   Grahame Grieve                  Fix problem with arrays as xml references
  26-Aug 2002   Grahame Grieve                  Fix for Soap::Lite arrays
  23-Aug 2002   Grahame Grieve                  Doc|Lit issues fixed
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  13 Aug 2002   Grahame Grieve                  Fir TIdSoapNode properties to use self not nil
  06-Aug 2002   Grahame Grieve                  Introduce properties to TIdSoapNode for direct message building
  24-Jul 2002   Grahame Grieve                  Restructure Packet handlers to change Namespace Policy
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  18-Jul 2002   Grahame Grieve                  Better control over Mime Types
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Andrew Cumming                  Fixed bugs with nil classes and empty arrays
  08-Apr 2002   Grahame Grieve                  Fix Objects by Reference
  08-Apr 2002   Grahame Grieve                  Support for Objects by Reference
  05-Apr 2002   Andrew Cumming                  Added generic special class handling code to simplify client/server special case management
  04-Apr 2002   Grahame Grieve                  Change to the way message names and namespaces are resolved + Mimetype support
  03-Apr 2002   Grahame Grieve                  Change to Packet writer interface - no difference between request and response
  02-Apr 2002   Grahame Grieve                  Date Time Support
  29-Mar 2002   Grahame Grieve                  publish TIdSoapNode.Parent
  26-Mar 2002   Grahame Grieve                  Remodel Array Handling, rename constants
  22-Mar 2002   Grahame Grieve                  Change Node handling to differentiate between arrays, elements, and structs
  18-Mar 2002   Andrew Cumming                  Fixed for D4/D5 compatibility
  14-Mar 2002   Grahame Grieve                  added seoCheckStrings + support
  14-Mar 2002   Grahame Grieve                  Namespace support, encoding options, default values for types
  12-Mar 2002   Grahame Grieve                  Binary support (TStream)
  10-Mar 2002   Grahame Grieve                  Add Binary support
   7-Mar 2002   Grahame Grieve                  Review assertions
  03-Mar 2002   Grahame Grieve                  Define MethodNamespace
  01-Mar 2002   Andrew Cumming                  Added GetNodeNoClassnameCheck for polymorphic classes
  22-Feb 2002   Andrew Cumming                  Added a node iterator for node traversal
   7-Feb 2002   Andrew Cumming                  D4 compatibility
   7-Feb 2002   Grahame Grieve                  First release
}

unit IdSoapRpcPacket;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
{$IFNDEF DELPHI4}
  Contnrs,
{$ENDIF}
  IdSoapComponent,
  IdSoapDebug,
  IdSoapDime,
  IdSoapITI,
  IdSoapTypeRegistry,
  IdSoapUtilities,
  IdSoapXML,
  SysUtils,
  TypInfo;

type

  TIdSoapEncodingOption = (
    seoUseCrLf,
      // actually a decoding option. If this is selected, then string #10's will
      // be converted to #13#10 after reading. This only applies to ANSI Strings and Chars,
      // Not widechars or Widestrings
      // (this is cause everything is converted to #10 when encoding. Bin and XML both affected

    seoCheckStrings,
      // If this is selected, then chars & strings will be prescanned to check that
      // none of the characters are out of range. Using XML encoding it's not safe
      // to send these but it is usually safe to send them using the Binary encoding

    seoReferences,
      // if this is selected, then objects will be encoded using references, this allows a single
      // object to be used more than once and the resulting structure being represented at
      // the other end

    seoCheckMustUnderstand,
      // if this is selected, then incoming messages will be cehcked for MustUnderstand
      // headers, and the message will be rejected if any are found. By default, this is
      // not selected, and the mustUnderstand attribute is ignored. The application can
      // check the headers itself it it needs to

    seoRequireTypes,
      // if this is selected, then IndySoap will require a precise match between
      // the pascal type and the corresponding *Stated* schema type. If this is not
      // selected, then a conversion will attempted as best as possible.
      // This is selected by default since it provides better type checking and
      // more informative messages, and works with most RPC SOAP libraries
      // this option applies when reading SOAP messages. This option has no effect
      // when the reader is working in doc|lit mode

    seoSuppressTypes,
      // if this is selected, then IndySoap will not indicate element types in the
      // soap message. Only use this if you have to. This has no meaning in the binary encoding
      // this option applies when writing SOAP messages. This option has no effect
      // when the reader is working in doc|lit mode

    seoArraysAnyNamespace,
      // some soap systems do not put arrays in the soap encoding namespace.
      // this is wrong, but the reader will treat any node with a name "Array"
      // as an array if this is true. (Note: this still won't solve all
      // interoperability problems as there are systems out there with bigger
      // problems than the namespace

    seoArraysInLine,
      // set this to true if the soap system at the other end encodes
      // arrays in-line rather than using the Soap Array Construct.
      // This is the default in doc|lit mode. It's unusual to need this
      // option - usually you would use doc|lit mode if you needed in-line arrays

    seoSendCharset,
      // some servers require the charset of the encoding type to be sent
      // others reject it. By default we don't send it (as of 0.03). You can turn
      // it on.

    seoDimeEncoding,
      // by default, IndySoap will use normal soap, and DIME if there is any
      // attachments. Set seoDimeEncoding if you want DIME encoding used all
      // the time. This only applies in XML

    seoUseDefaults,
      // if this option is set, IndySoap will not require XML elements for
      // all parameters, and will provide a default value if the element
      // is not present. For simple types, you won't be able to determine
      // whether the value was actually sent or not. If this is a problem
      // then use the TIdSoapSimpleClass system. Char is not affected
      // by this option - there can be no default value for char (and widechar)
      // This only applies in XML when reading (see seoSendNoDefaults for writing)

    seoUseNullForNil,
      // support old versions of apache. They require xsi:null instead of
      // xsi:nil even when the schema location is given as the 2001 location
      // (fixed in the 2.3 release of Apache SOAP)

    seoSendNoDefaults
      // when a packet is being built, specifies whether the default values will be
      // sent or not. if this is set, then values that match the default values will
      // not be sent in the message. Default Values:
      //   String, AnsiString, wideString : ''
      //   ordinal types - 0 if a parameter or a property with no nominated default value, otherwise the value of the nominated default
      //   other types - no default
    );
  TIdSoapEncodingOptions = set of TIdSoapEncodingOption;

const
  {$IFDEF LINUX}
  DEFAULT_RPC_OPTIONS = [seoCheckStrings, seoReferences, seoRequireTypes];
  DEFAULT_DOCLIT_OPTIONS = [seoCheckStrings, seoSuppressTypes, seoUseDefaults, seoSendNoDefaults];
  {$ELSE}
  DEFAULT_RPC_OPTIONS = [seoUseCrLf, seoCheckStrings, seoReferences, seoRequireTypes];
  DEFAULT_DOCLIT_OPTIONS = [seoUseCrLf, seoCheckStrings, seoSuppressTypes, seoUseDefaults, seoSendNoDefaults];
  {$ENDIF}


type

  TIdBaseSoapPacket = class;
  TIdSoapNode = class;

  pNodeLink = ^TNodeLink;
  TNodeLink = record
    FChild : TIdSoapNode;
    FParam : TObject;
    FNext : pNodeLink;
  end;

  TIdSoapNode = class(TIdBaseObject)
  Private
    FName: String;
    FOwner: TIdBaseSoapPacket;
    FParent: TIdSoapNode;
    FInOrder : TStringList;
    FParams: TIdStringList;
    FLastParam : integer;
    FChildren: TIdStringList;
    FLastChild : integer;
    FStream: TMemoryStream; // for binary encoder
    FTypeName: String;
    FTypeNamespace : string;
    FReadingReferenceName: String; // for the XML decoder
    FIsArray: Boolean;
    FIsComplexArray : boolean;
    FActualObject: TObject; // used on the writer to hold the real object when object references in use

    FReadingReferenceId: Integer; // when reading, what the reference we need to get is (0 = not a reference, or a referred object).
    FWritingReferenceId: Integer; // when writing, what the reference for this object is (0 = a referring object, or not using references)
    FReference: TIdSoapNode;
    FXMLLink : TIdSoapXMLElement;
    FForceTypeInXML: Boolean;
    FFreeNoChildren: Boolean;

    function GetParamBinaryBase64(const AName: String): TStream;
    function GetParamBinaryHex(const AName: String): THexStream;
    function GetParamBoolean(const AName: String): Boolean;
    function GetParamByte(const AName: String): Byte;
    function GetParamCardinal(const AName: String): Cardinal;
    function GetParamChar(const AName: String): Char;
    function GetParamComp(const AName: String): Comp;
    function GetParamCurrency(const AName: String): Currency;
    function GetParamDateTime(const AName: String): TDateTime;
    function GetParamDouble(const AName: String): Double;
    function GetParamEnumeration(const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject): Integer;
    function GetParamExists(const AName: String): Boolean;
    function GetParamExtended(const AName: String): Extended;
    function GetParamInt64(const AName: String): Int64;
    function GetParamInteger(const AName: String): Integer;
    function GetParamSet(const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo): Integer;
    function GetParamShortInt(const AName: String): ShortInt;
    function GetParamShortString(const AName: String): ShortString;
    function GetParamSingle(const AName: String): Single;
    function GetParamSmallInt(const AName: String): SmallInt;
    function GetParamString(const AName: String): String;
    function GetParamWideChar(const AName: String): WideChar;
    function GetParamWideString(const AName: String): WideString;
    function GetParamWord(const AName: String): Word;
    procedure SetParamBinaryBase64(const AName: String; const AValue: TStream);
    procedure SetParamBinaryHex(const AName: String; const AValue: THexStream);
    procedure SetParamBoolean(const AName: String; const AValue: Boolean);
    procedure SetParamByte(const AName: String; const AValue: Byte);
    procedure SetParamCardinal(const AName: String; const AValue: Cardinal);
    procedure SetParamChar(const AName: String; const AValue: Char);
    procedure SetParamComp(const AName: String; const AValue: Comp);
    procedure SetParamCurrency(const AName: String; const AValue: Currency);
    procedure SetParamDateTime(const AName: String; const AValue: TDateTime);
    procedure SetParamDouble(const AName: String; const AValue: Double);
    procedure SetParamExtended(const AName: String; const AValue: Extended);
    procedure SetParamInt64(const AName: String; const AValue: Int64);
    procedure SetParamInteger(const AName: String; const AValue: Integer);
    procedure SetParamSet(const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo; const AValue: Integer);
    procedure SetParamShortInt(const AName: String; const AValue: ShortInt);
    procedure SetParamShortString(const AName: String; const AValue: ShortString);
    procedure SetParamSingle(const AName: String; const AValue: Single);
    procedure SetParamSmallInt(const AName: String; const AValue: SmallInt);
    procedure SetParamString(const AName, AValue: String);
    procedure SetParamWideChar(const AName: String; const AValue: WideChar);
    procedure SetParamWideString(const AName: String; const AValue: WideString);
    procedure SetParamWord(const AName: String; const AValue: Word);
    procedure SetParamEnumeration(const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject; const AValue: Integer);
  Public
    constructor Create(AName, ATypeName, ATypeNamespace: String; AIsArray: Boolean; AParent: TIdSoapNode; AOwner: TIdBaseSoapPacket);
    destructor Destroy; Override;
    property ActualObject: TObject Read FActualObject Write FActualObject;
    procedure AddChild(AName : string; AChild : TIdSoapNode);
    procedure AddParam(AName : string; AParam : TObject);
    property FreeNoChildren : Boolean read FFreeNoChildren write FFreeNoChildren;
    property Children: TIdStringList Read FChildren;
    function Description: String;
    procedure DeleteChild(AIndex : integer; AFreeObject : boolean);
    procedure DeleteParam(AIndex : integer; AFreeObject : boolean);
    property IsArray: Boolean Read FIsArray;
    property IsComplexArray : boolean read FIsComplexArray write FIsComplexArray;
    property InOrder : TStringList read FInOrder;
    property Name: String Read FName;
    property Owner: TIdBaseSoapPacket Read FOwner;
    property Params: TIdStringList Read FParams;
    property Parent: TIdSoapNode Read FParent;
    property ReadingReferenceId: Integer Read FReadingReferenceId Write FReadingReferenceId;
    property ReadingReferenceName: String Read FReadingReferenceName Write FReadingReferenceName;
    property Reference: TIdSoapNode Read FReference Write FReference;
    property Stream: TMemoryStream Read FStream Write FStream; // for descendents to use if desired
    property TypeName: String Read FTypeName;
    property TypeNamespace : string read FTypeNamespace;
    property WritingReferenceId: Integer Read FWritingReferenceId Write FWritingReferenceId;
    property ForceTypeInXML : Boolean read FForceTypeInXML write FForceTypeInXML;
    function GetParamIndex(AName : string):Integer;
    function GetChildIndex(AName : string):Integer;

    // all these properties are redirected internally through the appropriate reader or writer
    // in order to allow the reader or writer to make whatever checks are appropriate
    property ParamBinaryBase64[const AName: String]: TStream Read GetParamBinaryBase64 write SetParamBinaryBase64;
    property ParamBinaryHex[const AName: String]: THexStream Read GetParamBinaryHex write SetParamBinaryHex;
    property ParamBoolean[const AName: String]: Boolean Read GetParamBoolean write SetParamBoolean;
    property ParamByte[const AName: String]: Byte Read GetParamByte write SetParamByte;
    property ParamCardinal[const AName: String]: Cardinal Read GetParamCardinal write SetParamCardinal;
    property ParamChar[const AName: String]: Char Read GetParamChar write SetParamChar;
    property ParamComp[const AName: String]: Comp Read GetParamComp write SetParamComp;
    property ParamCurrency[const AName: String]: Currency Read GetParamCurrency write SetParamCurrency;
    property ParamDateTime[const AName: String]: TDateTime Read GetParamDateTime write SetParamDateTime;
    property ParamDouble[const AName: String]: Double Read GetParamDouble write SetParamDouble;
    property ParamEnumeration[const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject]: Integer Read GetParamEnumeration Write SetParamEnumeration;
    property ParamExists[const AName: String]: Boolean Read GetParamExists;
    property ParamExtended[const AName: String]: Extended Read GetParamExtended write SetParamExtended;
    property ParamInt64[const AName: String]: Int64 Read GetParamInt64 write SetParamInt64;
    property ParamInteger[const AName: String]: Integer Read GetParamInteger write SetParamInteger;
    property ParamSet[const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo]: Integer Read GetParamSet write SetParamSet;
    property ParamShortInt[const AName: String]: ShortInt Read GetParamShortInt write SetParamShortInt;
    property ParamShortString[const AName: String]: ShortString Read GetParamShortString write SetParamShortString;
    property ParamSingle[const AName: String]: Single Read GetParamSingle write SetParamSingle;
    property ParamSmallInt[const AName: String]: SmallInt Read GetParamSmallInt write SetParamSmallInt;
    property ParamString[const AName: String]: String Read GetParamString write SetParamString;
    property ParamWideChar[const AName: String]: WideChar Read GetParamWideChar write SetParamWideChar;
    property ParamWideString[const AName: String]: WideString Read GetParamWideString write SetParamWideString;
    property ParamWord[const AName: String]: Word Read GetParamWord write SetParamWord;

    property XMLLink : TIdSoapXMLElement read FXMLLink write FXMLLink;
  end;

  PIdSoapNodeIteratorInfo = ^TIdSoapNodeIteratorInfo;
  TIdSoapNodeIteratorInfo = record
    Entry: Integer;     // this nodes index (not the same as the subscript index)
    Index: Integer;     // this subscripts index
    Node: TIdSoapNode;    // this subscripts current node entry
  end;

  TIdSoapNodeIteratorInfoArray = array of TIdSoapNodeIteratorInfo;

  TIdSoapNodeIterator = class(TIdBaseObject)
  Private
    FDepth: Integer;
    FRoot: TIdSoapNode;
    FInfo: TIdSoapNodeIteratorInfoArray;
  Public
    function First(ARootNode: TIdSoapNode; ADepth: Integer): Boolean;
    function Next: Boolean;
    property Info: TIdSoapNodeIteratorInfoArray Read FInfo;
  end;

  TIdSoapAttachment = class (TIdBaseObject)
  private
    FOwner : TIdBaseSoapPacket;
    FChunkSize: integer;
    FId: string;
    FMimeType: string;
    FURIType: string;
    FContent: TStream;
    procedure SetMimeType(const Value: string);
    procedure SetURIType(const Value: string);
    procedure SetChunkSize(const Value: integer);
  public
    constructor create;
    destructor destroy; override;
    property Id : string read FId;
    // you are allowed to change the stream type - free the existing one first. This object assumes ownership of the stream
    property Content : TStream read FContent write FContent;
    property UriType : string read FURIType write SetURIType;
    property MimeType : string read FMimeType write SetMimeType;
    property ChunkSize : integer read FChunkSize write SetChunkSize;
  end;

  TIdSoapAttachmentList = class (TObjectList)
  private
    FOwner : TIdBaseSoapPacket;
    function GetAttachment(const AId: string): TIdSoapAttachment;
    function GetAttachmentByIndex(const AIndex : integer): TIdSoapAttachment;
  public
    property Attachment[const AId : string] : TIdSoapAttachment read GetAttachment;
    property AttachmentByIndex [const AIndex : integer] : TIdSoapAttachment read GetAttachmentByIndex;
    function Add(AId : string = ''; AMakeUpID : boolean = true) : TIdSoapAttachment;      // if one isn't provided, a GUID will be generated
  end;

  // headers are read in 2 stages. In the first stage, they are identified, linked
  // with their XML source, and composed as text. In the second pass, if they are
  // declared, they are reprocessed to their correct type
  TIdSoapHeader = class (TIdBaseObject)
  private
    FContent: TIdBaseSoapableClass;
    FPascalName : String;
    FNamespace: string;
    FName: string;
    FPersistent: boolean;
    FMustUnderstand: boolean;
    FMustSend : boolean;
    FNode : TIdSoapNode;
    FOwnsContent: Boolean;
    FProcessed: Boolean;
    procedure CheckOk;
  public
    constructor CreateWithName(APascalName : String; AContent : TIdBaseSoapableClass);
    constructor CreateWithQName(ANamespace, AName : String; AContent : TIdBaseSoapableClass);
    destructor destroy; override;
    property PascalName : string read FPascalName write FPascalName;
    property Namespace : string read FNamespace write FNamespace;
    property Name : string read FName write FName;
    property Content : TIdBaseSoapableClass read FContent write FContent;
    property Persistent : boolean read FPersistent write FPersistent;
    property MustUnderstand : boolean read FMustUnderstand write FMustUnderstand;
    property MustSend : boolean read FMustSend write FMustSend;
    property Node : TIdSoapNode read FNode write FNode;
    property OwnsContent : Boolean read FOwnsContent write FOwnsContent;
    property Processed : Boolean read FProcessed write FProcessed;
  end;

  TIdSoapHeaderList = class (TObjectList)
  private
    function GetHeader(AIndex : integer): TIdSoapHeader;
    function GetIndexOfName(APascalName : String) : Integer;
    function GetIndexOfQName(ANamespace, AName : String):Integer;
  public
    procedure AddHeader(AHeader : TIdSoapHeader);
    property Header[AIndex : integer]: TIdSoapHeader read GetHeader;
    property IndexOfName[APascalName : String]: Integer read GetIndexOfName;
    property IndexOfQName[ANamespace, AName : String]:Integer read GetIndexOfQName;
    procedure DeleteAll(APersistent: boolean = true);
    procedure TakeHeaders(AList : TIdSoapHeaderList);

    function DefineSimpleHeader(ANamespace, AName, AContent: String) : TIdSoapHeader;
    function GetSimpleHeader(ANamespace, AName : String) : string;
  end;

  TIdBaseSoapPacket = class(TIdBaseObject)
  Private
    FSoapVersion: TIdSoapVersion;
    FEncodingOptions: TIdSoapEncodingOptions;
    FXmlProvider : TIdSoapXmlProvider;
    FMessageNamespace : string;
    FMessageName : string;
    FSchemaNamespace : string;
    FSchemaInstanceNamespace : string;
    FObjectReferences: TIdSoapKeyList;
    FBaseNode: TIdSoapNode;
    FEncodingMode: TIdSoapEncodingMode;
    FAttachments: TIdSoapAttachmentList;
    procedure RefListDispose(ASender: TObject; APtr: pointer);
  Public
    constructor Create(Const ASoapVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider); virtual;
    destructor Destroy; Override;
    property BaseNode: TIdSoapNode Read FBaseNode;
    property EncodingMode : TIdSoapEncodingMode read FEncodingMode write FEncodingMode;
    property EncodingOptions: TIdSoapEncodingOptions Read FEncodingOptions Write FEncodingOptions;
    property SoapVersion: TIdSoapVersion Read FSoapVersion;
    property MessageName: String Read FMessageName write FMessageName;
    property MessageNameSpace: String Read FMessageNameSpace Write FMessageNameSpace;
    property ObjectReferences: TIdSoapKeyList Read FObjectReferences;
    property SchemaInstanceNamespace : string read FSchemaInstanceNamespace write FSchemaInstanceNamespace;
    property SchemaNamespace : string read FSchemaNamespace write FSchemaNamespace;
    property Attachments : TIdSoapAttachmentList read FAttachments;
    property XmlProvider : TIdSoapXmlProvider read FXmlProvider;
  end;

  TIdSoapReader = class(TIdBaseSoapPacket)
  Private
    FNameReferences: TStringList;
    FHeaders : TIdSoapHeaderList;
    FFirstEntityName: string;
    FWantGarbageCollect : boolean;

    FHasBeenDecoded: Boolean;
  Protected
    FPreDecoded : boolean;
    property NameReferences: TStringList Read FNameReferences;
    procedure FinishReading;
    function GenerateSOAPException(AExceptionSourceName, AExceptionClass : String; AMessage: WideString): Exception;

    function GetParamBinaryBase64(ANode: TIdSoapNode; const AName: String): TStream; Virtual; Abstract;
    function GetParamBinaryHex(ANode: TIdSoapNode; const AName: String): THexStream; Virtual; Abstract;
    function GetParamBoolean(ANode: TIdSoapNode; const AName: String): Boolean; Virtual; Abstract;
    function GetParamByte(ANode: TIdSoapNode; const AName: String): Byte; Virtual; Abstract;
    function GetParamCardinal(ANode: TIdSoapNode; const AName: String): Cardinal; Virtual; Abstract;
    function GetParamChar(ANode: TIdSoapNode; const AName: String): Char; Virtual; Abstract;
    function GetParamComp(ANode: TIdSoapNode; const AName: String): Comp; Virtual; Abstract;
    function GetParamCurrency(ANode: TIdSoapNode; const AName: String): Currency; Virtual; Abstract;
    function GetParamDateTime(ANode: TIdSoapNode; const AName: String): TDateTime; Virtual; Abstract;
    function GetParamDouble(ANode: TIdSoapNode; const AName: String): Double; Virtual; Abstract;
    function GetParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject): Integer; Virtual; Abstract;
    function GetParamExists(ANode: TIdSoapNode; const AName: String): Boolean; Virtual; Abstract;
    function GetParamExtended(ANode: TIdSoapNode; const AName: String): Extended; Virtual; Abstract;
    function GetParamInt64(ANode: TIdSoapNode; const AName: String): Int64; Virtual; Abstract;
    function GetParamInteger(ANode: TIdSoapNode; const AName: String): Integer; Virtual; Abstract;
    function GetParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo): Integer; Virtual; Abstract;
    function GetParamShortInt(ANode: TIdSoapNode; const AName: String): ShortInt; Virtual; Abstract;
    function GetParamShortString(ANode: TIdSoapNode; const AName: String): ShortString; Virtual; Abstract;
    function GetParamSingle(ANode: TIdSoapNode; const AName: String): Single; Virtual; Abstract;
    function GetParamSmallInt(ANode: TIdSoapNode; const AName: String): SmallInt; Virtual; Abstract;
    function GetParamString(ANode: TIdSoapNode; const AName: String): String; Virtual; Abstract;
    function GetParamWideChar(ANode: TIdSoapNode; const AName: String): WideChar; Virtual; Abstract;
    function GetParamWideString(ANode: TIdSoapNode; const AName: String): WideString; Virtual; Abstract;
    function GetParamWord(ANode: TIdSoapNode; const AName: String): Word; Virtual; Abstract;
    procedure CheckChildReferences(ANode: TIdSoapNode); virtual;
  Public
    constructor Create(const ASoapVersion: TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider); Override;
    destructor Destroy; Override;

    property Headers : TIdSoapHeaderList read FHeaders; // A list of TIdSoapHeader
    function TakeHeaders : TIdSoapHeaderList; // transfer ownership of the headers to a client

    // if we read an xml fragment (TIdSoapRawXML), then we will want the reader to hang
    // around in the garbage collection context in order for the user to access the XML
    property WantGarbageCollect : boolean read FWantGarbageCollect write FWantGarbageCollect;

    // the reading process is split into 4 parts for clarity elsewhere.
    // each packet reader will implement this as it is able to
    procedure ReadMessage(ASoapPacket: TStream; AMimeType : string; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent); Virtual; Abstract; // check basic structure of message, and read it into structured format
    procedure CheckPacketOK; Virtual; Abstract; // check fules as applied to structure
    procedure ProcessHeaders; Virtual; Abstract; // check headers on packet if any
    procedure PreDecode; Virtual; Abstract; // call on server: read root node name and namespace before Full decode in order to determine Encoding Type
    procedure DecodeMessage; Virtual; Abstract; // actually decode the message into a node structure
                                                // will raise an exception in this method if a fault packet is read
    procedure CheckMustUnderstand;

    function GetArray(ANode: TIdSoapNode; const AName: String; AAllowNil: Boolean = False): TIdSoapNode;
    function GetStruct(ANode: TIdSoapNode; const AName, AClassName, AClassNamespace: String; AAllowNil: Boolean = False): TIdSoapNode;
    function GetNodeNoClassnameCheck(ANode: TIdSoapNode; const AName: String; AAllowNil: Boolean = False): TIdSoapNode;
    procedure LinkReferences(ANode: TIdSoapNode);

    property ParamBinaryBase64[ANode: TIdSoapNode; const AName: String]: TStream Read GetParamBinaryBase64;
    property ParamBinaryHex[ANode: TIdSoapNode; const AName: String]: THexStream Read GetParamBinaryHex;
    property ParamBoolean[ANode: TIdSoapNode; const AName: String]: Boolean Read GetParamBoolean;
    property ParamByte[ANode: TIdSoapNode; const AName: String]: Byte Read GetParamByte;
    property ParamCardinal[ANode: TIdSoapNode; const AName: String]: Cardinal Read GetParamCardinal;
    property ParamChar[ANode: TIdSoapNode; const AName: String]: Char Read GetParamChar;
    property ParamComp[ANode: TIdSoapNode; const AName: String]: Comp Read GetParamComp;
    property ParamCurrency[ANode: TIdSoapNode; const AName: String]: Currency Read GetParamCurrency;
    property ParamDateTime[ANode: TIdSoapNode; const AName: String]: TDateTime Read GetParamDateTime;
    property ParamDouble[ANode: TIdSoapNode; const AName: String]: Double Read GetParamDouble;
    property ParamEnumeration[ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject]: Integer Read GetParamEnumeration;
    property ParamExists[ANode: TIdSoapNode; const AName: String]: Boolean Read GetParamExists;
    property ParamExtended[ANode: TIdSoapNode; const AName: String]: Extended Read GetParamExtended;
    property ParamInt64[ANode: TIdSoapNode; const AName: String]: Int64 Read GetParamInt64;
    property ParamInteger[ANode: TIdSoapNode; const AName: String]: Integer Read GetParamInteger;
    property ParamSet[ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo]: Integer Read GetParamSet;
    property ParamShortInt[ANode: TIdSoapNode; const AName: String]: ShortInt Read GetParamShortInt;
    property ParamShortString[ANode: TIdSoapNode; const AName: String]: ShortString Read GetParamShortString;
    property ParamSingle[ANode: TIdSoapNode; const AName: String]: Single Read GetParamSingle;
    property ParamSmallInt[ANode: TIdSoapNode; const AName: String]: SmallInt Read GetParamSmallInt;
    property ParamString[ANode: TIdSoapNode; const AName: String]: String Read GetParamString;
    property ParamWideChar[ANode: TIdSoapNode; const AName: String]: WideChar Read GetParamWideChar;
    property ParamWideString[ANode: TIdSoapNode; const AName: String]: WideString Read GetParamWideString;
    property ParamWord[ANode: TIdSoapNode; const AName: String]: Word Read GetParamWord;

    property FirstEntityName : string read FFirstEntityName write FFirstEntityName;
    function GetGeneralParam(ANode: TIdSoapNode; const AName : string; Var VNil: boolean; var VValue, VTypeNS, VType : string):boolean; Virtual; Abstract;
    function ResolveNamespace(ANode: TIdSoapNode; const AName, ANamespace : string):String; Virtual; Abstract;

    // direct XML access
    function GetXMLElement(ANode : TIdSoapNode; AName : string; var VOwnsDom : boolean;
                                          var VDom : TIdSoapXMLDom; var VElem : TIdSoapXMLElement;
                                          var VTypeNS, VType : String):Boolean; Virtual; abstract;
  end;

  TIdSoapBuilder = class (TIdBaseSoapPacket)
  private
    FOwnsHeaders : boolean;
  protected
    FHeaders : TIdSoapHeaderList;
  public
    constructor Create(Const ASoapVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider); Override;
    destructor Destroy; Override;
    procedure Encode(AStream: TStream; var VMimeType : String; AEvent : TIdViewMessageDomEvent; ACaller : TIdSoapComponent); Virtual; Abstract;
    property Headers : TIdSoapHeaderList read FHeaders;
    procedure UseSoapHeaders(AHeaders : TIdSoapHeaderList);
  end;

  TIdSoapWriter = class(TIdSoapBuilder)
  Private
    FNextReferenceID: Integer;
  Protected
    procedure CheckForBadCharacters(const AString, AName, ARoutine: String);
  Public
    // create takes a reader, so descendents can clone settings from the reader
    // (this is only relevent on the server. Client, use nil)
    constructor Create(Const ASoapVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider); Override;

    procedure StructNodeAdded(ANode: TIdSoapNode); Virtual;
    procedure SetMessageName(const AName, ANamespace: String);

    function AddStruct(ANode: TIdSoapNode; const AName, AClassName, AClassNamespace: String; AItem: TObject): TIdSoapNode;
    function AddArray(ANode: TIdSoapNode; const AName, ABaseType, ABaseTypeNS: String; ABaseTypeComplex : boolean): TIdSoapNode; Virtual; Abstract;
    function DefineNamespace(ANamespace : string):String; Virtual; Abstract;
    procedure DefineGeneralParam(ANode: TIdSoapNode; ANil : boolean; AName, AValue, ATypeNS, AType : string); Virtual; Abstract;
    procedure DefineParamBinaryBase64(ANode: TIdSoapNode; const AName: String; AStream: TStream); Virtual; Abstract;
    procedure DefineParamBinaryHex(ANode: TIdSoapNode; const AName: String; AStream: THexStream); Virtual; Abstract;
    procedure DefineParamBoolean(ANode: TIdSoapNode; const AName: String; AValue: Boolean); Virtual; Abstract;
    procedure DefineParamByte(ANode: TIdSoapNode; const AName: String; AValue: Byte); Virtual; Abstract;
    procedure DefineParamCardinal(ANode: TIdSoapNode; const AName: String; AValue: Cardinal); Virtual; Abstract;
    procedure DefineParamChar(ANode: TIdSoapNode; const AName: String; AValue: Char); Virtual; Abstract;
    procedure DefineParamComp(ANode: TIdSoapNode; const AName: String; AValue: Comp); Virtual; Abstract;
    procedure DefineParamCurrency(ANode: TIdSoapNode; const AName: String; AValue: Currency); Virtual; Abstract;
    procedure DefineParamDateTime(ANode: TIdSoapNode; const AName: String; AValue: TDateTime); Virtual; Abstract;
    procedure DefineParamDouble(ANode: TIdSoapNode; const AName: String; AValue: Double); Virtual; Abstract;
    procedure DefineParamEnumeration(ANode: TIdSoapNode; const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject; AValue: Integer); Virtual; Abstract;
    procedure DefineParamExtended(ANode: TIdSoapNode; const AName: String; AValue: Extended); Virtual; Abstract;
    procedure DefineParamInt64(ANode: TIdSoapNode; const AName: String; AValue: Int64); Virtual; Abstract;
    procedure DefineParamInteger(ANode: TIdSoapNode; const AName: String; AValue: Integer); Virtual; Abstract;
    procedure DefineParamSet(ANode: TIdSoapNode; const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo; AValue: Integer); Virtual; Abstract;
    procedure DefineParamShortInt(ANode: TIdSoapNode; const AName: String; AValue: ShortInt); Virtual; Abstract;
    procedure DefineParamShortString(ANode: TIdSoapNode; const AName: String; AValue: ShortString); Virtual; Abstract;
    procedure DefineParamSingle(ANode: TIdSoapNode; const AName: String; AValue: Single); Virtual; Abstract;
    procedure DefineParamSmallInt(ANode: TIdSoapNode; const AName: String; AValue: SmallInt); Virtual; Abstract;
    procedure DefineParamString(ANode: TIdSoapNode; const AName, AValue: String); Virtual; Abstract;
    procedure DefineParamWideChar(ANode: TIdSoapNode; const AName: String; AValue: WideChar); Virtual; Abstract;
    procedure DefineParamWideString(ANode: TIdSoapNode; const AName: String; const AValue: WideString); Virtual; Abstract;
    procedure DefineParamWord(ANode: TIdSoapNode; const AName: String; AValue: Word); Virtual; Abstract;
    procedure DefineParamXML(ANode: TIdSoapNode; AName : string; AXml : TIdSoapXmlElement; ATypeNamespace, ATypeName : string); Virtual; Abstract;
  end;

  TIdSoapFaultWriter = class(TIdSoapBuilder)
  Protected
    FActor : String;
    FCode : string;
    FMessage: WideString;
    FDetails : WideString;
    FClass : string;
  Public
    procedure DefineException(AException: Exception);
  end;

function IdSoapIndexFromName(AName, ALocation: String): Integer;

implementation

uses
{$IFNDEF LINUX}
  ActiveX,
{$ENDIF}
{$IFDEF DELPHI4OR5}
  ComObj,
{$ENDIF}
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapResourceStrings;

const
  ASSERT_UNIT = 'IdSoapRpcPacket';
{ TIdSoapNode }

constructor TIdSoapNode.Create(AName, ATypeName, ATypeNamespace: String; AIsArray: Boolean; AParent: TIdSoapNode; AOwner: TIdBaseSoapPacket);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.Create';
begin
  inherited Create;
  Assert(AName <> '', ASSERT_LOCATION + ': Name = ""');
  // we don not insist on a type name or namespace being provided
  Assert((AParent = NIL) or AParent.TestValid(TIdSoapNode), ASSERT_LOCATION + ': Parent is not valid');
  Assert(AOwner.TestValid(TIdBaseSoapPacket), ASSERT_LOCATION + ': Owner is not valid');
  FName := AName;
  FTypeName := ATypeName;
  FTypeNamespace := ATypeNamespace;
  FIsArray := AIsArray;
  FParent := AParent;
  FOwner := AOwner;
  FParams := TIdStringList.Create(True);
  FLastParam := -1;
  FChildren := TIdStringList.Create(True);
  FLastChild := -1;
  if AOwner is TIdSoapWriter then
    begin
    FInOrder := TStringList.create;
    end;
end;

destructor TIdSoapNode.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.Destroy';
begin
  Assert(self.TestValid(TIdSoapNode), ASSERT_LOCATION + ': self is not valid');
  FreeAndNil(FInOrder);
  FreeAndNil(FStream);
  FreeAndNil(FParams);
  if FFreeNoChildren then
    begin
    FChildren.OwnsObjects := false;
    end;
  FreeAndNil(FChildren);
  inherited;
end;

function TIdSoapNode.Description: String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.Description:';
begin
  Assert(self.TestValid(TIdSoapNode), ASSERT_LOCATION + ': self is not valid');
  if assigned(FParent) then
    begin
    Result := FParent.Description + '.' + FName;
    end
  else
    begin
    Result := FName;
    end;
end;

function TIdSoapNode.GetParamBinaryBase64(const AName: String): TStream;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamBinaryBase64';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamBinaryBase64[self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamBinaryHex(const AName: String): THexStream;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamBinaryHex';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamBinaryHex[self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamBoolean(const AName: String): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamBoolean';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamBoolean[self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamByte(const AName: String): Byte;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamByte';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamByte[self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;

end;

function TIdSoapNode.GetParamCardinal(const AName: String): Cardinal;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamCardinal';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamCardinal[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamChar(const AName: String): Char;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamChar';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamChar[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamComp(const AName: String): Comp;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamComp';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamComp[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamCurrency(const AName: String): Currency;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamCurrency';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamCurrency[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamDateTime(const AName: String): TDateTime;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamDateTime';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamDateTime[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamDouble(const AName: String): Double;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamDouble';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamDouble[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamEnumeration(const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamEnumeration';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamEnumeration[Self, AName, ATypeInfo, ATypeName, ANamespace, AItiLink];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamExists(const AName: String): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamExists';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamExists[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamExtended(const AName: String): Extended;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamExtended';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamExtended[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamInt64(const AName: String): Int64;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamInt64';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamInt64[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamInteger(const AName: String): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamInteger';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamInteger[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamSet(const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamSet';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamSet[Self, AName, ATypeName, ANamespace, ATypeInfo];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamShortInt(const AName: String): ShortInt;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamShortInt';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamShortInt[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamShortString(const AName: String): ShortString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamShortString';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamShortString[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamSingle(const AName: String): Single;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamSingle';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamSingle[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamSmallInt(const AName: String): SmallInt;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamSmallInt';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamSmallInt[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamString(const AName: String): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamString';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamString[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamWideChar(const AName: String): WideChar;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamWideChar';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamWideChar[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamWideString(const AName: String): WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamWideString';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamWideString[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

function TIdSoapNode.GetParamWord(const AName: String): Word;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamWord';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapReader) then
    begin
    result := (FOwner as TIdSoapReader).ParamWord[Self, AName];
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to get a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamBinaryHex(const AName: String; const AValue: THexStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamBinaryHex';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamBinaryHex(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamBinaryBase64(const AName: String; const AValue: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamBinaryBase64';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamBinaryBase64(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamBoolean(const AName: String; const AValue: Boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamBoolean';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamBoolean(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamByte(const AName: String; const AValue: Byte);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamByte';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamByte(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamCardinal(const AName: String; const AValue: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamCardinal';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamCardinal(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamChar(const AName: String; const AValue: Char);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamChar';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamChar(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamComp(const AName: String; const AValue: Comp);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamComp';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamComp(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamCurrency(const AName: String; const AValue: Currency);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamCurrency';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamCurrency(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamDateTime(const AName: String; const AValue: TDateTime);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamDateTime';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamDateTime(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamDouble(const AName: String; const AValue: Double);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamDouble';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamDouble(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamExtended(const AName: String; const AValue: Extended);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamExtended';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamExtended(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamInt64(const AName: String; const AValue: Int64);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamInt64';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamInt64(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamInteger(const AName: String; const AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamInteger';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamInteger(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamSet(const AName, ATypeName, ANamespace: String; ATypeInfo : pTypeInfo; const AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamSet';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamSet(Self, AName, ATypeName, ANamespace, ATypeInfo, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamShortInt(const AName: String; const AValue: ShortInt);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamShortInt';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamShortInt(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamShortString(const AName: String; const AValue: ShortString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamShortString';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamShortString(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamSingle(const AName: String; const AValue: Single);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamSingle';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamSingle(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamSmallInt(const AName: String; const AValue: SmallInt);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamSmallInt';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamSmallInt(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamString(const AName, AValue: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamString';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamString(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamWideChar(const AName: String; const AValue: WideChar);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamWideChar';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamWideChar(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamWideString(const AName: String; const AValue: WideString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamWideString';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamWideString(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamWord(const AName: String; const AValue: Word);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamWord';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamWord(Self, AName, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.SetParamEnumeration(const AName: String; ATypeInfo: PTypeInfo; ATypeName, ANamespace : string; AItiLink : TIdSoapITIBaseObject; const AValue: Integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamEnumeration';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  Assert(IdEnumIsValid(ATypeInfo, AValue), ASSERT_LOCATION+': Enumeration Value is out of range');
  if (FOwner is TIdSoapWriter) then
    begin
    (FOwner as TIdSoapWriter).DefineParamEnumeration(Self, AName, ATypeInfo, ATypeName, ANamespace, AItiLink, AValue);
    end
  else
    begin
    raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Attempt to set a parameter for unsuitable packet type '+FOwner.ClassName);
    end;
end;

procedure TIdSoapNode.AddChild(AName: string; AChild: TIdSoapNode);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamEnumeration';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  Assert(AChild.TestValid(TIdSoapNode), ASSERT_LOCATION+': child is not valid');
  if assigned(FInOrder) then
    begin
    FInOrder.addObject(AName, AChild);
    end;
  FChildren.AddObject(AName, AChild);
end;

procedure TIdSoapNode.AddParam(AName: string; AParam: TObject);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamEnumeration';
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if assigned(FInOrder) then
    begin
    FInOrder.addObject(AName, AParam);
    end;
  FParams.AddObject(AName, AParam);
end;

procedure TIdSoapNode.DeleteChild(AIndex: integer; AFreeObject: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamEnumeration';
var
  AName : string;
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert((AIndex >= 0) and (AIndex < FChildren.count), ASSERT_LOCATION+': Index '+inttostr(AIndex)+' is not valid');
  AName := FChildren[AIndex];
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if assigned(FInOrder) then
    begin
    Assert(FInOrder.IndexOf(AName) > -1, ASSERT_LOCATION+': Name not found in InOrder list');
    FInOrder.Delete(FInOrder.IndexOf(AName));
    end;
  if not AFreeObject then
    begin
    FChildren.Objects[AIndex] := nil;
    end;
  FChildren.Delete(AIndex);
end;

procedure TIdSoapNode.DeleteParam(AIndex: integer; AFreeObject: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.SetParamEnumeration';
var
  AName : string;
begin
  Assert(Self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert((AIndex >= 0) and (AIndex < FParams.count), ASSERT_LOCATION+': Index '+inttostr(AIndex)+' is not valid');
  AName := FParams[AIndex];
  Assert(AName <> '', ASSERT_LOCATION+': Name is blank');
  if assigned(FInOrder) then
    begin
    Assert(FInOrder.IndexOf(AName) > -1, ASSERT_LOCATION+': Name not found in InOrder list');
    FInOrder.Delete(FInOrder.IndexOf(AName));
    end;
  if not AFreeObject then
    begin
    FParams.Objects[AIndex] := nil;
    end;
  FParams.Delete(AIndex);
end;

function TIdSoapNode.GetParamIndex(AName: string): Integer;
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetParamIndex';
var
  i : integer;
  t : integer;
begin
  Assert(self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is not valid');

  result := -1;
  t := FParams.count;
  for i := 0 to t - 1 do
    begin
    if AnsiSameText(FParams[(i + FLastParam+1) mod t], AName) then
      begin
      result := (i + FLastParam+1) mod t;
      break;
      end;
    end;
  // by remembering the last lookup, we speed up the next, since usually iteration is in order
  FLastParam := result;
end;

function TIdSoapNode.GetChildIndex(AName: string): Integer;
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNode.GetChildIndex';
var
  i : integer;
  t : integer;
begin
  Assert(self.TestValid(TIdSoapNode), ASSERT_LOCATION+': self is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is not valid');

  result := -1;
  t := FChildren.count;
  for i := 0 to t - 1 do
    begin
    if AnsiSameText(FChildren[(i + FLastChild+1) mod t], AName) then
      begin
      result := (i + FLastChild+1) mod t;
      break;
      end;
    end;
  // by remembering the last lookup, we speed up the next, since usually iteration is in order
  FLastChild := result;
end;

{ TIdBaseSoapPacket }

constructor TIdBaseSoapPacket.Create(const ASoapVersion: TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdBaseSoapPacket.Create';
begin
  inherited Create;

  Assert(IdEnumIsValid(TypeInfo(TIdSoapVersion), ord(ASoapVersion)), ASSERT_LOCATION+': SoapVersion is not valid');

  FSoapVersion := ASoapVersion;
  FXmlProvider := AXmlProvider;
  FEncodingMode := semRPC;
  FEncodingOptions := DEFAULT_RPC_OPTIONS;
  FMessageNamespace := '';
  FMessageName := '';
  FSchemaNamespace := ID_SOAP_NS_SCHEMA_2001;
  FSchemaInstanceNamespace := ID_SOAP_NS_SCHEMA_INST_2001;
  FBaseNode := TIdSoapNode.Create(ID_SOAP_NULL_NODE_NAME, ID_SOAP_NULL_NODE_TYPE, '', False, NIL, self);
  FObjectReferences := TIdSoapKeyList.Create(16);
  FObjectReferences.OnDispose := RefListDispose;
  FAttachments := TIdSoapAttachmentList.create(true);
end;

destructor TIdBaseSoapPacket.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdBaseSoapPacket.Destroy';
begin
  Assert(self.TestValid(TIdBaseSoapPacket), ASSERT_LOCATION + ': self is not valid');
  FreeAndNil(FBaseNode);
  FreeAndNil(FAttachments);
  FreeAndNil(FObjectReferences);
  inherited;
end;

procedure TIdBaseSoapPacket.RefListDispose(ASender: TObject; APtr: pointer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdBaseSoapPacket.RefListDispose';
var
  LNode: TIdSoapNode;
begin
  Assert(self.TestValid(TIdBaseSoapPacket), ASSERT_LOCATION + ': Self is not valid');
  LNode := TIdSoapNode(APtr);
  Assert(LNode.TestValid(TIdSoapNode), ASSERT_LOCATION + ': Node is not valid');
  FreeAndNil(LNode);
end;

{ TIdSoapReader }

constructor TIdSoapReader.Create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.create';
begin
  inherited;
  FHasBeenDecoded := False;
  FNameReferences := TIdStringList.Create(True);
  FHeaders := TIdSoapHeaderList.create(True);
  FWantGarbageCollect := false;
end;

destructor TIdSoapReader.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.destroy';
begin
  Assert(self.TestValid, ASSERT_LOCATION + ': Self is not valid');
  FreeAndNil(FHeaders);
  FreeAndNil(FNameReferences);
  inherited;
end;

function TIdSoapReader.GenerateSOAPException(AExceptionSourceName, AExceptionClass : String; AMessage: WideString) : Exception;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.GenerateSOAPException';
begin
  Assert(self.TestValid, ASSERT_LOCATION + ': Self is not valid');
  // no check on AExceptionClass - it can be ''
  Assert(AMessage <> '', ASSERT_LOCATION + ': Message is blank');
  result := IdExceptionFactory(AExceptionSourceName, AExceptionClass, AMessage);
end;

function TIdSoapReader.GetNodeNoClassnameCheck(ANode: TIdSoapNode; const AName: String; AAllowNil: Boolean = False): TIdSoapNode;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.GetNodeNoClassnameCheck';
var
  I: Integer;
begin
  Assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');
  if ANode = NIL then
    begin
    ANode := FBaseNode;
    end;
  Assert(ANode.TestValid, ASSERT_LOCATION + ': Anode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION + ': Anode wrong owner');
  Assert(AName <> '', ASSERT_LOCATION + ': AName is Blank');
  i := ANode.GetChildIndex(AName);
  if i = -1 then
    begin
    Result := NIL;
    IdRequire(AAllowNil, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_PARAM_MISSING, [AName, ANode.Children.CommaText]));
    end
  else
    begin
    Result := ANode.Children.Objects[i] as TIdSoapNode;
    LinkReferences(Result);
    end;
end;

function TIdSoapReader.GetStruct(ANode: TIdSoapNode; const AName, AClassName, AClassNamespace: String; AAllowNil: Boolean = False): TIdSoapNode;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.GetStruct';
begin
  Assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');
  if ANode = NIL then
    begin
    ANode := FBaseNode;
    end;
  Assert(ANode.TestValid, ASSERT_LOCATION + ': Anode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION + ': Anode wrong owner');
  Assert(AName <> '', ASSERT_LOCATION + ': AName is Blank');
  Result := GetNodeNoClassnameCheck(ANode, AName, AAllowNil);
  if Assigned(Result) then
    begin
    LinkReferences(Result);
    IdRequire(not Result.FIsArray, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, AClassName, 'Array'])); { do not localize }
    if (EncodingMode = semRPC) and (seoRequireTypes in EncodingOptions) then
      begin
      if not assigned(Result.Reference) then
        begin
        IdRequire(Result.FTypeName = AClassName, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, AClassName, Result.FTypeName]));
        IdRequire(Result.FTypeNamespace = AClassNamespace, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_TYPE_NS_MISMATCH, [AName, AClassNamespace, Result.FTypeNamespace]));
        end
      else
        begin
        IdRequire(Result.Reference.FTypeName = AClassName, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, AClassName, Result.Reference.FTypeName]));
        IdRequire(Result.Reference.FTypeNamespace = AClassNamespace, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, AClassNamespace, Result.Reference.FTypeNamespace]));
        end;
      end;
    end;
end;

function TIdSoapReader.GetArray(ANode: TIdSoapNode; const AName: String; AAllowNil: Boolean): TIdSoapNode;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.GetArray';
var
  LIndex : Integer;
  LCount : integer;
  LTemp : TIdSoapNode;
begin
  Assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');
  if ANode = NIL then
    begin
    ANode := FBaseNode;
    end;
  Assert(ANode.TestValid, ASSERT_LOCATION + ': Anode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION + ': Anode wrong owner');
  Assert(AName <> '', ASSERT_LOCATION + ': AName is Blank');
  Result := GetNodeNoClassnameCheck(ANode, AName, true);
  if assigned(result) and (assigned(result.Reference)) then
    begin
    LinkReferences(Result);
    result := result.Reference;
    LinkReferences(Result);
    end;
  if (not assigned(Result) or not Result.IsArray) and ((EncodingMode = semDocument) or (seoArraysInLine in EncodingOptions)) then
    begin
    if ANode.GetChildIndex(AName) > -1 then
      begin
      result := TIdSoapNode.create(AName, '', '', true, ANode, self);
      result.IsComplexArray := true;
      LCount := 0;
      for LIndex := 0 to ANode.FChildren.Count -1 do
        begin
        if ANode.FChildren[LIndex] = AName then
          begin
          LTemp := ANode.FChildren.Objects[LIndex] as TIdSoapNode;
          LTemp.FName := inttostr(LCount);
          LTemp.FParent := Result;
          result.AddChild(LTemp.Name, Ltemp);
          ANode.FChildren.Objects[LIndex] := nil;
          ANode.FChildren[LIndex] := ID_SOAP_INVALID;
          inc(LCount);
          end;
        end;
      ANode.AddChild(AName, result);
      end
    else if ANode.FParams.IndexOf(AName) > -1 then
      begin
      result := TIdSoapNode.create(AName, '', '', true, ANode, self);
      result.IsComplexArray := false;
      LCount := 0;
      for LIndex := 0 to ANode.FParams.Count -1 do
        begin
        if ANode.FParams[LIndex] = AName then
          begin
          result.AddParam(inttostr(LCount), ANode.FParams.Objects[LIndex]);
          ANode.FParams[LIndex] := ID_SOAP_INVALID;
          ANode.FParams.Objects[LIndex] := nil;
          inc(LCount);
          end;
        end;
      ANode.AddChild(AName, result);
      end
    else
      begin
      IdRequire(AAllowNil, ASSERT_LOCATION + ': '+ Format(RS_ERR_SOAP_ARRAY_MISSING, [AName, ANode.FParams.CommaText+','+ANode.FChildren.CommaText]));
      end;
    end
  else
    begin
    if Assigned(Result) then
      begin
      if not assigned(Result.Reference) then
        begin
        IdRequire(Result.IsArray, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, 'Array', Result.FTypeName]));
        end
      else
        begin
        IdRequire(Result.Reference.IsArray, ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_TYPE_MISMATCH, [AName, 'Array', Result.Reference.FTypeName]));
        end;
      end
    else
      begin
      IdRequire(AAllowNil, ASSERT_LOCATION + ': '+ Format(RS_ERR_SOAP_ARRAY_MISSING, [AName, ANode.FParams.CommaText+','+ANode.FChildren.CommaText]));
      end;
    end;
end;

procedure TIdSoapReader.CheckChildReferences(ANode: TIdSoapNode);
begin
 // nothing here - xml descendent does things
end;

procedure TIdSoapReader.LinkReferences(ANode: TIdSoapNode);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.LinkReferences';
var
  LIndex: Integer;
begin
  Assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');
  Assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION + ': ANode is invalid');
  if (ANode.ReadingReferenceId <> 0) then
    begin
    ANode.Reference := ObjectReferences.AsObj[ANode.ReadingReferenceId] as TIdSoapNode;
    if not assigned(ANode.Reference) then
      begin
      IdRequire(ObjectReferences.Exists[ANode.ReadingReferenceId], ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_REFERENCE_MISSING, [IntToStr(ANode.ReadingReferenceId)]));
      end;
    end
  else if (ANode.ReadingReferenceName <> '') then
    begin
    IdRequire(FNameReferences.find(ANode.ReadingReferenceName, LIndex), ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_REFERENCE_MISSING, [ANode.ReadingReferenceName, FNameReferences.CommaText]));
    ANode.Reference := (FNameReferences.Objects[LIndex] as TIdSoapNode);
    end;
  if assigned(ANode.Reference) then
    begin
    ANode.FIsArray := ANode.Reference.FIsArray;
    if not ANode.Reference.FIsArray then
      begin
      CheckChildReferences(ANode.Reference);
      end;
    end
  else
    begin
    if not ANode.FIsArray then
      begin
      CheckChildReferences(ANode);
      end;
    end;
end;

procedure TIdSoapReader.FinishReading;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.FinishReading';
begin
  Assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');
  FNameReferences.sort;
end;

function TIdSoapReader.TakeHeaders: TIdSoapHeaderList;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.FinishReading';
begin
  Assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');
  result := FHeaders;
  FHeaders := nil;
end;


procedure TIdSoapReader.CheckMustUnderstand;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapReader.CheckMustUnderstand';
var
  i : integer;
  LHeader : TIdSoapHeader;
begin
  Assert(self.TestValid(TIdSoapReader), ASSERT_LOCATION + ': Self is invalid');

  if (seoCheckMustUnderstand in EncodingOptions) then
    begin
    for i := 0 to FHeaders.count - 1 do
      begin
      LHeader := FHeaders.Header[i];
      IdRequire(not LHeader.MustUnderstand or LHeader.Processed, ASSERT_LOCATION+': The Header {'+LHeader.Namespace+'}'+LHeader.Name+' was marked as MustUnderstand, but not processed');
      end;
    end;
end;

{ TIdSoapWriter }

constructor TIdSoapWriter.Create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriter.create';
begin
  inherited;
  FNextReferenceID := 0;
end;

procedure TIdSoapWriter.SetMessageName(const AName, ANamespace: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriter.SetMessageName';
begin
  Assert(self.TestValid, ASSERT_LOCATION + ': Attempt to use an Invalid TIdSoapWriter');
  Assert(AName <> '', ASSERT_LOCATION + ': A method name must be provided');
  Assert(IsValidIdent(AName), ASSERT_LOCATION + ': A method name must be Valid ("' + AName + '")');
  FMessageName := AName;
  FMessageNameSpace := ANamespace;
end;

procedure TIdSoapWriter.CheckForBadCharacters(const AString, AName, ARoutine: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriter.CheckForBadCharacters';
var
  I: Integer;
  LOrd: Byte;
begin
  Assert(self.TestValid(TIdSoapWriter), ASSERT_LOCATION + ': Self is invalid');

  for i := 1 to length(AString) do
    begin
    LOrd := Ord(AString[i]);
    if (LOrd < 32) and not (LOrd in [13, 10]) then
      begin
      raise EIdSoapRequirementFail.Create(ASSERT_LOCATION + ': ' + Format(RS_ERR_SOAP_BAD_CHAR, [IntToStr(i), IntToStr(LOrd), AName, ARoutine]));
      end;
    end;
end;

function TIdSoapWriter.AddStruct(ANode: TIdSoapNode; const AName, AClassName, AClassNamespace: String; AItem: TObject): TIdSoapNode;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriter.AddStruct';
var
  LNewNode: TIdSoapNode;
  LReference: TIdSoapNode;
begin
  Assert(self.TestValid(TIdSoapWriter), ASSERT_LOCATION + ': Self is not valid');
  if ANode = NIL then
    ANode := FBaseNode;
  Assert(ANode.TestValid(TIdSoapNode), ASSERT_LOCATION + ': ANode not valid');
  Assert(ANode.Owner = Self, ASSERT_LOCATION + ': ANode belongs to wrong owner');
  Assert(AName <> '', ASSERT_LOCATION + ': AName is Blank');
  Assert(AClassName <> '', ASSERT_LOCATION + ': AClassName is Blank');
  Assert(ANode.Children.IndexOf(AName) = -1, ASSERT_LOCATION + ': The Node Name "' + AName + '" has already been used on the Node "' + ANode.Name + '"');

  LNewNode := TIdSoapNode.Create(AName, AClassName, AClassNamespace, False, ANode, Self);
  ANode.AddChild(AName, LNewNode);
  if (seoReferences in FEncodingOptions) then
    begin
    LReference := FObjectReferences.AsObj[Cardinal(AItem)] as TIdSoapNode;
    if Assigned(LReference) then
      begin
      Result := NIL; // sender doesn't need to fill out properties
      end
    else
      begin
      if ANode.IsArray then
        begin
        LReference := TIdSoapNode.Create(ID_SOAP_NAME_SCHEMA_ITEM + AName, AClassName, AClassNamespace, True, NIL, self);
        end
      else
        begin
        LReference := TIdSoapNode.Create(AName, AClassName, AClassNamespace, True, NIL, self);
        end;
      inc(FNextReferenceID);
      LReference.WritingReferenceId := FNextReferenceID;
      StructNodeAdded(LReference);
      FObjectReferences.AsObj[Cardinal(AItem)] := LReference;
      Result := LReference;
      end;
    LNewNode.FReference := LReference;
    LNewNode.FTypeName := ID_SOAP_NAME_REF_TYPE;
    end
  else
    begin
    Result := LNewNode;
    end;
  StructNodeAdded(LNewNode);
end;

procedure TIdSoapWriter.StructNodeAdded(ANode: TIdSoapNode);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapWriter.StructNodeAdded';
begin
  Assert(self.TestValid(TIdSoapWriter), ASSERT_LOCATION + ': Self is not valid');
  // descendents shjould override if they need to do anything
end;

{ TIdSoapFaultWriter }

procedure TIdSoapFaultWriter.DefineException(AException: Exception);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapFaultWriter.DefineException';
var
  e : EIdSoapFault;
begin
  // it's a bit of a problem with exceptions here. But what can one do?
  Assert(self.TestValid, ASSERT_LOCATION + ': Attempt to use an Invalid TIdSoapFaultWriter');
  Assert(Assigned(AException), ASSERT_LOCATION + ': Exception is nil trying to encode it');
  FClass := AException.ClassName;
  if AException is EIdSoapFault then
    begin
    e := AException as EIdSoapFault;
    FMessage := e.FaultString;
    FActor := e.FaultActor;
    FCode := e.FaultCode;
    FDetails := e.Details; // in XML?
    end
  else
    begin
    FMessage := AException.Message;
    end;
end;

{ TIdSoapNodeIterator }

function TIdSoapNodeIterator.First(ARootNode: TIdSoapNode; ADepth: Integer): Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNodeIterator.first';
begin
  Assert(self.TestValid(TIdSoapNodeIterator), ASSERT_LOCATION + ': self is not valid');
  Assert(ARootNode.TestValid(TIdSoapNode), ASSERT_LOCATION + ': RootNode is not Valid');
  // no check on ADepth?
  FDepth := ADepth;
  FRoot := ARootNode;
  setlength(FInfo, FDepth);
  if ADepth < 1 then
    begin
    Result := False;
    exit;
    end;
  FInfo[0].Index := -1;   // to force initial load
  Result := Next;
end;

function TIdSoapNodeIterator.Next: Boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapNodeIterator.next';
var
  LS: String;
  LI: Integer;
  LTempNode: TIdSoapNode;
  function NextIndex(ADepth: Integer): Boolean;
    begin
    Result := False;
    if FInfo[ADepth].Index = -1 then
      begin
      // get active node for this subscript
      if ADepth = 0 then
        LTempNode := FRoot
      else
        LTempNode := FInfo[ADepth - 1].Node.Children.Objects[FInfo[ADepth - 1].Index] as TIdSoapNode;
      FInfo[ADepth].Node := LTempNode;
      if FInfo[ADepth].Node.Children.Count = 0 then  // no entries in this subscript
        exit;                                        // so exit false
      if ADepth < FDepth - 1 then         // is this not the last subscript ?
        begin
        FInfo[ADepth].Index := 0;       // for non-last ones we need to set it to 0. The last one will auto inc it to 0
        FInfo[ADepth + 1].Index := -1;    // for non last we need to force next subscript to re-calc
        end;
      end;
    repeat
      if ADepth = FDepth - 1 then  // are we on the last subscript ?
        begin
        inc(FInfo[ADepth].Index);  // move to the next index value
        if FInfo[ADepth].Index >= FInfo[ADepth].Node.Children.Count then  // gone beyond the end
          exit;                                                           // so exit false
        Result := True;  // solution found
        break;           // so we can compute the rest of the solutions info
        end;
      Result := NextIndex(ADepth + 1);  // try to advance subscript below us
      if not Result then   // didnt advance
        begin
        FInfo[ADepth + 1].Index := -1;  // force to recompute
        inc(FInfo[ADepth].Index);     // advance this index value
        if FInfo[ADepth].Index >= FInfo[ADepth].Node.Children.Count then  // past end ?
          exit;  // yes, so exit
        end;
    until Result;  // until we have a solution
    // now to compute the remainder of the solution
    LS := FInfo[ADepth].Node.Children[FInfo[ADepth].Index];
    LI := pos('_', LS);
    LS := copy(LS, LI + 1, length(LS));
    FInfo[ADepth].Entry := StrToInt(LS);  // entry contains the actual index entry of the dynamic array
    end;
begin
  Assert(self.TestValid(TIdSoapNodeIterator), ASSERT_LOCATION + ': self is not valid');
  // Andrew - how could an assert check that first has been called?
  Result := NextIndex(0);
end;

function IdSoapIndexFromName(AName, ALocation: String): Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapIndexFromName';
begin
  Result := IdStrToIntWithError(AName, ASSERT_LOCATION + ': Reading Array "' + AName + '" Index ' + ALocation);
end;

{ TIdSoapBuilder }

constructor TIdSoapBuilder.Create(const ASoapVersion: TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider);
begin
  inherited;
  FHeaders := TIdSoapHeaderList.create(true);
  FOwnsHeaders := true;
end;

destructor TIdSoapBuilder.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBuilder.destroy';
begin
  Assert(self.TestValid, ASSERT_LOCATION + ': Self is not valid');
  if FOwnsHeaders then
    begin
    FreeAndNil(FHeaders);
    end;
  inherited;
end;

procedure TIdSoapBuilder.UseSoapHeaders(AHeaders: TIdSoapHeaderList);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapBuilder.StructNodeAdded';
begin
  Assert(self.TestValid(TIdSoapWriter), ASSERT_LOCATION + ': Self is not valid');
  if FOwnsHeaders then
    begin
    FreeAndNil(FHeaders);
    end;
  FOwnsHeaders := false;
  FHeaders := AHeaders;
end;

{ TIdSoapAttachment }

constructor TIdSoapAttachment.create;
begin
  inherited;
  FContent := TIdMemoryStream.create;
end;

destructor TIdSoapAttachment.destroy;
begin
  FreeAndNil(FContent);
  inherited;
end;

procedure TIdSoapAttachment.SetChunkSize(const Value: integer);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapAttachment.SetChunkSize';
begin
  Assert(self.TestValid(TIdSoapAttachment), ASSERT_LOCATION + ': Self is not valid');
  Assert((not assigned(Fowner) {testing?}) or (FOwner is TIdSoapWriter), ASSERT_LOCATION + ': Cannot set chunk size unless writing a packet');
  FChunkSize := Value;
end;

procedure TIdSoapAttachment.SetMimeType(const Value: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapAttachment.SetMimeType';
begin
  Assert(self.TestValid(TIdSoapAttachment), ASSERT_LOCATION + ': Self is not valid');
  Assert((not assigned(Fowner) {testing?}) or (FOwner is TIdSoapWriter), ASSERT_LOCATION + ': Cannot set MimeType unless writing a packet');
  FMimeType := Value;
end;

procedure TIdSoapAttachment.SetURIType(const Value: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapAttachment.SetURIType';
begin
  Assert(self.TestValid(TIdSoapAttachment), ASSERT_LOCATION + ': Self is not valid');
  Assert((not assigned(Fowner) {testing?}) or (FOwner is TIdSoapWriter), ASSERT_LOCATION + ': Cannot set URIType unless writing a packet');
  FURIType := Value;
end;

{ TIdSoapAttachmentList }

function TIdSoapAttachmentList.Add(AId: string = ''; AMakeUpID : boolean = true): TIdSoapAttachment;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapAttachmentList.Add';
var
  LGUID : TGUID;
begin
  Assert(assigned(self), ASSERT_LOCATION + ': Self is not valid');
  Assert((not assigned(Fowner) {testing?}) or (FOwner is TIdSoapWriter), ASSERT_LOCATION + ': Cannot add attachments unless writing a packet');
  if (AId = '') and (AMakeUpID) then
    begin
    {$IFDEF LINUX}
    CreateGUID(LGUID);
    {$ELSE}
    CoCreateGuid(LGUID);
    {$ENDIF}
    AId := 'uuid:'+GUIDToString(LGuid);
    end;
  result := TIdSoapAttachment.create;
  result.FId:= AId;
  inherited add(result);
end;

function TIdSoapAttachmentList.GetAttachment(const AId: string): TIdSoapAttachment;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapAttachmentList.GetAttachment';
var
  i : integer;
begin
  Assert(assigned(self), ASSERT_LOCATION + ': Self is not valid');
  result := nil;
  for i := 0 to count - 1 do
    begin
    if (Items[i] as TIdSoapAttachment).FId = AId then
      begin
      result := Items[i] as TIdSoapAttachment;
      exit;
      end;
    end;
end;

function TIdSoapAttachmentList.GetAttachmentByIndex(const AIndex: integer): TIdSoapAttachment;
begin
 result := Items[AIndex] as TIdSoapAttachment;
end;

{ TIdSoapHeaderList }

procedure TIdSoapHeaderList.AddHeader(AHeader: TIdSoapHeader);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeaderList.AddHeader';
begin
  Assert(assigned(self), ASSERT_LOCATION+': self is not valid');
  Assert(AHeader.TestValid(TIdSoapHeader), ASSERT_LOCATION+': Header is not valid');
  AHeader.CheckOK;
  if AHeader.FPascalName <> '' then
    begin
    Assert(GetIndexOfName(AHeader.FPascalName) = -1, ASSERT_LOCATION+': attempt to add a duplicate header (name="'+AHeader.FPascalName+'")');
    end;
  if AHeader.FName <> '' then
    begin
    Assert(AHeader.FNamespace <> '', ASSERT_LOCATION+': attempt to add a badly named header (Qname="{'+AHeader.FNamespace+'}'+AHeader.FName+'")');
    Assert(GetIndexOfQName(AHeader.FNamespace, AHeader.FName) = -1, ASSERT_LOCATION+': attempt to add a duplicate header (Qname="{'+AHeader.FNamespace+'}'+AHeader.FName+'")');
    end;
  Add(AHeader);
end;

function TIdSoapHeaderList.GetHeader(AIndex : integer): TIdSoapHeader;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeaderList.GetHeader';
begin
  if AIndex = -1 then
    begin
    result := nil;
    end
  else
    begin
    result := Items[AIndex] as TIdSoapHeader;
    end;
end;

function TIdSoapHeaderList.GetIndexOfName(APascalName : String) : Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeaderList.GetIndexOfName';
var
  i : integer;
begin
  Assert(APascalName <> '', ASSERT_LOCATION+': Name is not valid');
  result := -1;
  for i := 0 to Count - 1 do
    begin
    if AnsiSametext(GetHeader(i).FPascalName, APascalName) then
      begin
      result := i;
      exit;
      end;
    end;
end;

function TIdSoapHeaderList.GetIndexOfQName(ANamespace, AName : String):Integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeaderList.GetIndexOfQName';
var
  i : integer;
begin
  Assert(ANamespace <> '', ASSERT_LOCATION+': Namespace is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is not valid');
  result := -1;
  for i := 0 to Count - 1 do
    begin
    if (GetHeader(i).FNamespace = ANamespace) and (GetHeader(i).FName = AName) then
      begin
      result := i;
      exit;
      end;
    end;
end;

procedure TIdSoapHeaderList.DeleteAll(APersistent: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeaderList.DeleteAll';
var
  i : integer;
  LHeader : TIdSoapHeader;
begin
  Assert(assigned(self), ASSERT_LOCATION+': self not valid');
  for i := Count -1 downto 0 do
    begin
    LHeader := Items[i] as TIdSoapHeader;
    if APersistent or not (LHeader.Persistent) then
      begin
      Delete(i);
      end;
    end;
end;

procedure TIdSoapHeaderList.TakeHeaders(AList: TIdSoapHeaderList);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeaderList.TakeHeaders';
var
  i : integer;
begin
  Assert(assigned(self), ASSERT_LOCATION+': self not valid');
  Assert(assigned(AList), ASSERT_LOCATION+': List not valid');
  AList.OwnsObjects := false;
  try
    for i := 0 to AList.Count -1 do
      begin
      AddHeader(AList.Items[i] as TIdSoapHeader);
      end;
    AList.clear;
  finally
    AList.OwnsObjects := true;
  end;
end;

function TIdSoapHeaderList.DefineSimpleHeader(ANamespace, AName, AContent: String) : TIdSoapHeader;
var
  LStr : TIdSoapString;
begin
  LStr := TIdSoapString.create;
  LStr.Value := AContent;
  result := TIdSoapHeader.CreateWithQName(ANamespace, AName, LStr);
  AddHeader(result);
end;

function TIdSoapHeaderList.GetSimpleHeader(ANamespace, AName: String): string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeaderList.GetSimpleHeader';
var
  LHeader : TIdSoapHeader;
  LIndex : integer;
begin
  result := '';
  LIndex := GetIndexOfQName(ANamespace, AName);
  if LIndex <> -1 then
    begin
    LHeader := GetHeader(LIndex);
    IdRequire(LHeader.Content is TIdSoapString, ASSERT_LOCATION+': Header content is not a simple string');
    result := (LHeader.Content as TIdSoapString).Value;
    end;
end;

{ TIdSoapHeader }

constructor TIdSoapHeader.CreateWithName(APascalName: String; AContent: TIdBaseSoapableClass);
begin
  inherited create;
  FPascalName := APascalName;
  FContent := AContent;
  FOwnsContent := true;
end;

constructor TIdSoapHeader.CreateWithQName(ANamespace, AName: String; AContent: TIdBaseSoapableClass);
begin
  inherited create;
  FNamespace := ANamespace;
  FName := AName;
  FContent := AContent;
  FOwnsContent := true;
end;

procedure TIdSoapHeader.CheckOk;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeader.CheckOk';
begin
  Assert(self.TestValid(TIdSoapHeader), ASSERT_LOCATION+': self is not valid');
  Assert((FPascalName <> '') or ( (FNamespace <> '') and (FName <> '')), ASSERT_LOCATION+': Header has insufficient identification');
  Assert(FContent.TestValid(TIdBaseSoapableClass), ASSERT_LOCATION+': Content is not valid');
end;

destructor TIdSoapHeader.destroy;
Const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapHeader.destroy';
begin
  Assert(self.TestValid(TIdSoapHeader), ASSERT_LOCATION + ': Self is invalid');
  if FOwnsContent then
    begin
    FreeAndNil(FContent);
    end;
  FreeAndNil(FNode);
  inherited;
end;

end.



