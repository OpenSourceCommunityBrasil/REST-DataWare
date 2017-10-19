{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16334: IdSoapXML.pas
{
{   Rev 1.3    23/6/2003 15:10:28  GGrieve
{ various fixes for V#1
}
{
{   Rev 1.2    20/6/2003 00:05:22  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:04:40  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    25/2/2003 12:54:46  GGrieve
}

{
IndySOAP: IdSoapXML

Abstract XML interface to multiple XML implementations

}

{
Version History:
  23-Jun 2003   Grahame Grieve                  Fix CharSet issues
  19-Jun 2003   Grahame Grieve                  Add custom provider, various optimisations
  18-Mar 2003   Grahame Grieve                  MSXML support, RawXML support
  25-Feb 2003   Grahame Grieve                  First implemented
}

unit IdSoapXML;

interface

{$I IdSoapDefines.inc}

{$IFNDEF LINUX}
  {$IFNDEF DELPHI4}
    {$DEFINE USE_MSXML}
  {$ENDIF}
{$ENDIF}

uses
{$IFDEF USE_MSXML}
  ActiveX,
  ComObj,
{$ENDIF}
  Classes,
{$IFNDEF DELPHI4}
  Contnrs,
{$ENDIF}
  IdSoapComponent,
  IdSoapDebug,
{$IFDEF USE_MSXML}
  IdSoapMsXml,
{$ENDIF}
  IdSoapOpenXML,
  IdSoapUtilities;

type

  TIdSoapXmlProvider = (
     xpOpenXML,  // OpenXML provider built into IndySoap
     xpMsXml,    // MsXML 4.1 - must be installed
     xpCustom);  // has known issues supporting characters in the 128 - 256 range

  TIdSoapXmlElement = class;

  TIdSoapXmlDom = class (TIdBaseObject)
  protected
    FRoot : TIdSoapXMLElement;
  public
    destructor destroy; override;
    property Root : TIdSoapXMLElement read FRoot;

    procedure Read(ASource : TStream); virtual; abstract;
    procedure StartBuild(AName : string); virtual; abstract;
    procedure writeUTF16(ADest : TStream); virtual; abstract;
    procedure writeUTF8(ADest : TStream); virtual; abstract;

    function ImportElement(AElem : TIdSoapXmlElement) : TIdSoapXmlElement; virtual; abstract;
  end;

  TIdSoapXmlElement = class (TIdBaseObject)
  private
    FDom : TIdSoapXmlDom;
    FChildren : TObjectList;
    FParentNode : TIdSoapXmlElement;
    FSibling : TIdSoapXmlElement;
    FKnowNilAttribute : boolean;
    FNilAttribute : boolean;
    FKnowXSIType : boolean;
    FXSIType : String;
    FKnowHasID : boolean;
    FHasID : boolean;
    function GetChildCount  : integer;
    function GetFirstChild  : TIdSoapXmlElement;
    procedure PrivAppendChild(AChild : TIdSoapXmlElement);
    procedure PrivRemoveChild(AElement : TIdSoapXmlElement);
  protected
    function GetAttributeCount : integer;             virtual; abstract;
    function GetName : WideString;                    virtual; abstract;
    function GetNamespace : WideString;               virtual; abstract;
    function GetNodeName : WideString;                virtual; abstract;
    function GetHasText : boolean;                    virtual; abstract;
    function GetAsXML : WideString;                   virtual; abstract;
    function GetTextContentA:String;                  virtual; abstract;
    procedure SetTextContentA(AValue : String);       virtual; abstract;
    function GetTextContentW:WideString;              virtual; abstract;
    procedure SetTextContentW(AValue : WideString);   virtual; abstract;
  public
    constructor create(ADom : TIdSoapXmlDom; AParent : TIdSoapXmlElement);
    destructor destroy; override;

    property DOM : TIdSoapXmlDom read FDom;

    // DOM navigation
    Property ParentNode  : TIdSoapXmlElement read FParentNode;
    Property ChildCount  : integer           read GetChildCount;
    Property FirstChild  : TIdSoapXmlElement read GetFirstChild;
    Property NextSibling : TIdSoapXmlElement read FSibling;
    function FirstElement(ANamespace, AName : WideString) : TIdSoapXmlElement;
    function NextElement(ANamespace, AName : WideString) : TIdSoapXmlElement;
    function FindElementAnyNS(AName : WideString) : TIdSoapXmlElement;
    function AppendChild(AName : WideString):TIdSoapxmlelement;                          virtual; abstract;
    procedure removeChild(AElement : TIdSoapXmlElement);                                 virtual; abstract;

    // attributes
    property AttributeCount : integer read GetAttributeCount;
    function hasAttribute(const ANamespace, AName : WideString): boolean;                virtual; abstract;
    function getAttribute(const ANamespace, AName : WideString): WideString;             virtual; abstract;
    function getAttributeName(i : integer; Var VNamespace, VName : WideString) :boolean; virtual; abstract;
    procedure setAttribute(AName, AValue : WideString); virtual; abstract;

    // names and namespaces
    function ResolveXMLNamespaceCode(ANamespace, ALocation : WideString) : string;       virtual; abstract;
    property Name : WideString read GetName;
    property Namespace : WideString read GetNamespace;
    property NodeName : WideString read GetNodeName;

    // text content. Code is xml encoded contents
    property HasText : boolean read GetHasText;
    property TextContentA : String read GetTextContentA write SetTextContentA;
    property TextContentW : WideString read GetTextContentW write SetTextContentW;

    // utilities
    procedure GrabChildren(AElem : TIdSoapXmlElement; AOtherDOM : boolean);              virtual; abstract;
    function Path : string;
    function HasNilAttribute : boolean;
    function GetSchemaInstanceAttribute(AAttributeName: string): string;
    function GetXSIType: string;
    function HasID : boolean;

    // xml content
    property AsXML : WideString read GetAsXML;
    procedure BuildChildFromXML(ASrc : WideString);                                      virtual; abstract;
  end;

{=== open XML =================================================================}
type
  TIdSoapOpenXmlElement = class;

  TIdSoapOpenXmlDom = class (TIdSoapXmlDom)
  private
    FDom : TDomImplementation;
    FDoc : TdomDocument;
    FDomErr : string;
    procedure DOMReadError(ASender: TObject; AError: TdomError; var VGo: boolean);
    procedure IterateChildren(AElem : TIdSoapOpenXmlElement);
  public
    destructor destroy; override;
    procedure Read(ASource : TStream); override;
    procedure StartBuild(AName : string); override;
    procedure writeUTF16(ADest : TStream); override;
    procedure writeUTF8(ADest : TStream); override;
    function ImportElement(AElem : TIdSoapXmlElement) : TIdSoapXmlElement; override;
  end;

  TIdSoapOpenXmlElement = class (TIdSoapXmlElement)
  private
    FElement : TdomElement;
  protected
    function GetAttributeCount : integer;             override;
    function GetName : WideString;                    override;
    function GetNamespace : WideString;               override;
    function GetNodeName : WideString;                override;
    function GetHasText : boolean;                    override;
    function GetAsXML : WideString;                   override;
    function GetTextContentA:String;                  override;
    procedure SetTextContentA(AValue : String);       override;
    function GetTextContentW:WideString;              override;
    procedure SetTextContentW(AValue : WideString);   override;
  public
    constructor create(ADom : TIdSoapXmlDom; AParent : TIdSoapXmlElement; AElement : TdomElement);

    function AppendChild(AName : WideString):TIdSoapxmlelement;                          override;
    procedure removeChild(AElement : TIdSoapXmlElement);                                 override;
    function hasAttribute(const ANamespace, AName : WideString): boolean;                override;
    function getAttribute(const ANamespace, AName : WideString): WideString;             override;
    function getAttributeName(i : integer; Var VNamespace, VName : WideString) :boolean; override;
    procedure setAttribute(AName, AValue : WideString);                                  override;
    function ResolveXMLNamespaceCode(ANamespace, ALocation : WideString) : string;       override;
    procedure BuildChildFromXML(ASrc : WideString);                                      override;
    procedure GrabChildren(AElem : TIdSoapXmlElement; AOtherDOM : boolean);              override;

    // expose raw XML for direct access through TIdSoapRawXML
    property XMLElement : TdomElement read FElement;
  end;

{$IFDEF USE_MSXML}
{=== MSXML =================================================================}

type
  TIdSoapMSXmlElement = class;

  TIdSoapMSXmlDom = class (TIdSoapXmlDom)
  private
    FDom : IXMLDomDocument2;
    procedure IterateChildren(AElem : TIdSoapMSXmlElement);
  public
    destructor destroy; override;
    procedure Read(ASource : TStream); override;
    procedure StartBuild(AName : string); override;
    procedure writeUTF16(ADest : TStream); override;
    procedure writeUTF8(ADest : TStream); override;
    function ImportElement(AElem : TIdSoapXmlElement) : TIdSoapXmlElement; override;
  end;

  TIdSoapMSXmlElement = class (TIdSoapXmlElement)
  private
    FElem : IXMLDOMElement;
  protected
    function GetAttributeCount : integer;             override;
    function GetName : WideString;                    override;
    function GetNamespace : WideString;               override;
    function GetNodeName : WideString;                override;
    function GetHasText : boolean;                    override;
    function GetAsXML : WideString;                   override;
    function GetTextContentA:String;                  override;
    procedure SetTextContentA(AValue : String);       override;
    function GetTextContentW:WideString;              override;
    procedure SetTextContentW(AValue : WideString);   override;
  public
    constructor create(ADom : TIdSoapXmlDom; AParent : TIdSoapXmlElement; AElem : IXMLDOMElement);
    function AppendChild(AName : WideString):TIdSoapxmlelement;                          override;
    procedure removeChild(AElement : TIdSoapXmlElement);                                 override;
    function hasAttribute(const ANamespace, AName : WideString): boolean;                override;
    function getAttribute(const ANamespace, AName : WideString): WideString;             override;
    function getAttributeName(i : integer; Var VNamespace, VName : WideString) :boolean; override;
    procedure setAttribute(AName, AValue : WideString);                                  override;
    function ResolveXMLNamespaceCode(ANamespace, ALocation : WideString) : string;       override;
    procedure BuildChildFromXML(ASrc : WideString);                                      override;
    procedure GrabChildren(AElem : TIdSoapXmlElement; AOtherDOM : boolean);              override;

    // expose raw XML for direct access through TIdSoapRawXML
    property XMLElement : IXMLDOMElement read FElem;
  end;
{$ENDIF}

{=== Custom ======================================================================}
type
  TIdSoapCustomElement = class;

  TIdSoapCustomDom = class (TIdSoapXmlDom)
  private
    FSrc : PChar;
    FLength : integer;
    FCursor : integer;
    FIsUTF8 : boolean;
    function ReadToken(ASkipWhitespace : Boolean): string;
    function ReadToNextChar(ACh : Char): String;
    procedure ReadAttribute(AName : string; AOwner: TIdSoapCustomElement);
    function ReadElement(AParent : TIdSoapXMLElement; ADefaultNamespace : string) : TIdSoapCustomElement;
  public
    procedure Read(ASource : TStream); override;
    procedure StartBuild(AName : string); override;
    procedure writeUTF16(ADest : TStream); override;
    procedure writeUTF8(ADest : TStream); override;
    function ImportElement(AElem : TIdSoapXmlElement) : TIdSoapXmlElement; override;
  end;

  TIdSoapCustomAttribute = class (TIdBaseObject)
  private
    FNs : string;
    FName : String;
    FContent : String;
  public

  end;

  TIdSoapCustomElement = class (TIdSoapXmlElement)
  private
    FNodeName : String;
    FNs : String;
    FName : String;
    FContent : String;
    FXMLNs : TObjectList;
    FAttr : TObjectList;
    procedure WriteToString(var VCnt : string; var VLen : integer);
    function ResolveNamespaces(ADefaultNamespace : String) : String;
  protected
    function GetAttributeCount : integer;             override;
    function GetName : WideString;                    override;
    function GetNamespace : WideString;               override;
    function GetNodeName : WideString;                override;
    function GetHasText : boolean;                    override;
    function GetAsXML : WideString;                   override;
    function GetTextContentA:String;                  override;
    procedure SetTextContentA(AValue : String);       override;
    function GetTextContentW:WideString;              override;
    procedure SetTextContentW(AValue : WideString);   override;
  public
    constructor create(ADom : TIdSoapXmlDom; AParent : TIdSoapXmlElement; AName : widestring);
    destructor destroy; override;

    function AppendChild(AName : WideString):TIdSoapxmlelement;                          override;
    procedure removeChild(AElement : TIdSoapXmlElement);                                 override;
    function hasAttribute(const ANamespace, AName : WideString): boolean;                override;
    function getAttribute(const ANamespace, AName : WideString): WideString;             override;
    function getAttributeName(i : integer; Var VNamespace, VName : WideString) :boolean; override;
    procedure setAttribute(AName, AValue : WideString);                                  override;
    function ResolveXMLNamespaceCode(ANamespace, ALocation : WideString) : string;       override;
    procedure BuildChildFromXML(ASrc : WideString);                                      override;
    procedure GrabChildren(AElem : TIdSoapXmlElement; AOtherDOM : boolean);              override;
  end;

  TIdViewMessageDomEvent = procedure (ASender : TIdSoapComponent; ADom : TIdSoapXmlDom) of object;

function IdSoapDomFactory(AXmlProvider : TIdSoapXmlProvider = xpOpenXML) : TIdSoapXmlDom;

implementation

uses
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapNamespaces,
  IdSoapResourceStrings,
  IdSoapOpenXmlUCL,
  SysUtils
  {$IFDEF VER140}
  , Variants
  {$ENDIF};

const
  ASSERT_UNIT = 'IdSoapXML';

{ TIdSoapXmlDom }

destructor TIdSoapXmlDom.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlDom.destroy';
begin
  FreeAndNil(FRoot);
  inherited;
end;

{ TIdSoapXmlElement }

constructor TIdSoapXmlElement.create(ADom : TIdSoapXmlDom; AParent: TIdSoapXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.create';
begin
  inherited create;
  assert(ADom.TestValid(TIdSoapXmlDom), ASSERT_LOCATION+': Dom is not valid');
  assert((AParent = nil) or (AParent.TestValid(TIdSoapXmlElement)), ASSERT_LOCATION+': parent is not valid');
  FDom := ADom;
  FParentNode := AParent;
  FChildren := TObjectList.create(true);
  FSibling := nil;
  FKnowNilAttribute := false;
  FNilAttribute := false;
  FKnowXSIType := false;
  FXSIType := '';
  FKnowHasID := false;
  FHasID := false;
end;

destructor TIdSoapXmlElement.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.destroy';
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FChildren);
  inherited;
end;

function TIdSoapXmlElement.GetChildCount  : integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.GetChildCount';
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FChildren.Count;
end;

function TIdSoapXmlElement.GetFirstChild  : TIdSoapXmlElement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.GetFirstChild';
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  if FChildren.Count > 0 then
    begin
    result := FChildren[0] as TIdSoapXmlElement;
    end
  else
    begin
    result := nil;
    end;
end;

function TIdSoapXmlElement.FirstElement(ANamespace, AName : WideString) : TIdSoapXmlElement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.FirstElement';
var
  i : integer;
  LChild : TIdSoapXmlElement;
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(ANamespace <> '', ASSERT_LOCATION+': namespace is blank');
  assert(AName <> '', ASSERT_LOCATION+': name is blank');
  result := nil;
  for i := 0 to FChildren.Count - 1 do
    begin
    LChild := FChildren[i] as TIdSoapXmlElement;
    if AnsiSameText(LChild.Namespace, ANamespace) and AnsiSameText(LChild.Name, AName) then
      begin
      result := LChild;
      break;
      end;
    end;
end;

function TIdSoapXmlElement.NextElement(ANamespace, AName : WideString) : TIdSoapXmlElement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.NextElement';
var
  LSib : TIdSoapXmlElement;
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(ANamespace <> '', ASSERT_LOCATION+': namespace is blank');
  assert(AName <> '', ASSERT_LOCATION+': name is blank');
  result := nil;
  LSib := self.FSibling;
  while Assigned(LSib) and not assigned(result) do
    begin
    if AnsiSameText(LSib.Namespace, ANamespace) and AnsiSameText(LSib.Name, AName) then
      begin
      result := LSib;
      end;
    end;
end;


function TIdSoapXmlElement.FindElementAnyNS(AName : WideString) : TIdSoapXmlElement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.FindElementAnyNS';
var
  i : integer;
  LChild : TIdSoapXmlElement;
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  result := nil;
  for i := 0 to FChildren.Count - 1 do
    begin
    LChild := FChildren[i] as TIdSoapXmlElement;
    if (AnsiSameText(LChild.Name, AName) or AnsiSameText(LChild.nodeName, AName)) then
      begin
      result := LChild;
      break;
      end;
    end;
end;

procedure TIdSoapXmlElement.PrivAppendChild(AChild: TIdSoapXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.PrivAppendChild';
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(AChild.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': child is not valid');
  if FChildren.Count > 0 then
    begin
    (FChildren[FChildren.Count - 1] as TIdSoapXmlElement).FSibling := AChild;
    end;
  FChildren.Add(AChild);
end;

procedure TIdSoapXmlElement.PrivRemoveChild(AElement: TIdSoapXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapXmlElement.PrivRemoveChild';
var
  i : integer;
begin
  assert(self.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(AElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': child is not valid');
  i := FChildren.IndexOf(AElement);
  if i >= 0 then
    begin
    if i > 0 then
      begin
      if i < FChildren.Count -1 then
        begin
        (FChildren[i - 1] as TIdSoapXmlElement).FSibling := (FChildren[i + 1] as TIdSoapXmlElement);
        end
      else
        begin
        (FChildren[i - 1] as TIdSoapXmlElement).FSibling := nil;
        end;
      FChildren.Delete(i);
      end;
    end;
end;

function TIdSoapXmlElement.Path: string;
begin
  if assigned(FParentNode) then
    begin
    result := FParentNode.Path+'\'+NodeName;
    end
  else
    begin
    result := '\'+NodeName;
    end;
end;

function TIdSoapXmlElement.HasNilAttribute: boolean;
begin
  if not FKnowNilAttribute then
    begin
    FNilAttribute :=
      AnsiSameText(GetSchemaInstanceAttribute(ID_SOAP_XSI_ATTR_NIL),  'true') or { do not localize }
      AnsiSameText(GetSchemaInstanceAttribute(ID_SOAP_XSI_ATTR_NULL),  'true') or { do not localize }
      AnsiSameText(GetSchemaInstanceAttribute('Nil'),  'true') or { do not localize }
      AnsiSameText(GetSchemaInstanceAttribute('NIL'),  'true') or { do not localize }
      AnsiSameText(GetSchemaInstanceAttribute('Null'),  'true') or { do not localize }
      AnsiSameText(GetSchemaInstanceAttribute('NULL'),  'true'); { do not localize }
    FKnowNilAttribute := true;
    end;
  result := FNilAttribute;
end;

function TIdSoapXmlElement.GetSchemaInstanceAttribute(AAttributeName : string):string;
begin
  result := getAttribute(ID_SOAP_NS_SCHEMA_INST_2001, AAttributeName);
  if result = '' then
    begin
    result := getAttribute(ID_SOAP_NS_SCHEMA_INST_1999, AAttributeName)
    end;
end;

function TIdSoapXmlElement.GetXSIType: string;
begin
  if not FKnowXSIType then
    begin
    FXSIType := GetSchemaInstanceAttribute(ID_SOAP_NAME_SCHEMA_TYPE);
    FKnowXSIType := true;
    end;
  result := FXSIType;
end;

function TIdSoapXmlElement.HasID: boolean;
begin
  if not FKnowHasID then
    begin
    FHasID := hasAttribute('', ID_SOAP_NAME_XML_ID);
    FKnowHasID := true;
    end;
  result := FHasID;
end;

{ TIdSoapOpenXmlDom }

destructor TIdSoapOpenXmlDom.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.destroy';
begin
  assert(self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FDom);
  inherited;
end;

procedure TIdSoapOpenXmlDom.DOMReadError(ASender: TObject; AError: TdomError; var VGo: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.DOMReadError';
begin
  assert(Self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  assert(assigned(AError), ASSERT_LOCATION+': Error is nil');
  VGo := false;
  if assigned(AError.location.relatedNode) then
    begin
    FDomErr := AError.code+': '+AError.message+' (at '+AError.location.relatedNode.localName+')';        { do not localize }
    end
  else
    begin
    FDomErr := AError.code+': '+AError.message;
    end;
end;

function TIdSoapOpenXmlDom.ImportElement(AElem: TIdSoapXmlElement): TIdSoapXmlElement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.ImportElement';
begin
  assert(Self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  // check that XML provider is the right type
  IdRequire(AElem.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': Element is not valid');

  result := TIdSoapOpenXmlElement.create(self, nil, FDoc.ImportNode((AElem as TIdSoapOpenXmlElement).FElement, true) as TdomElement);
end;

procedure TIdSoapOpenXmlDom.IterateChildren(AElem: TIdSoapOpenXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.IterateChildren';
var
  LNode : TdomNode;
  LChild : TIdSoapOpenXmlElement;
begin
  assert(self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  assert(AElem.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': Elem is not valid');
  LNode := AElem.FElement.firstChild;
  while Assigned(LNode) do
    begin
    if LNode is TdomElement then
      begin
      LChild := TIdSoapOpenXmlElement.create(Self, AElem, LNode as TdomElement);
      AElem.PrivAppendChild(LChild);
      IterateChildren(LChild);
      end;
    LNode := LNode.nextSibling;
    end;
end;

procedure TIdSoapOpenXmlDom.Read(ASource: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.Read';
var
  LParser: TXmlToDomParser;
begin
  assert(self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  FDom := TDomImplementation.Create(NIL);
  FDom.OnError := DOMReadError;
  FDomErr := '';
  LParser := TXmlToDomParser.Create(NIL);
  try
    LParser.DOMImpl := FDom;
    LParser.DocBuilder.BuildNamespaceTree := true;
    try
      LParser.StreamToDom(ASource);
    except
      on e:Exception do
        begin
        if FDomErr <> '' then
          begin
          e.message := e.message + ' '+FDomErr;
          end;
        raise;
        end;
    end;
  finally
    FreeAndNil(LParser);
  end;
  (FDom.documents.item(0) as TdomDocument).resolveEntityReferences(erReplace);
  FDoc := (FDom.documents.item(0) as TdomDocument);
  FRoot := TIdSoapOpenXmlElement.create(self, nil, FDoc.documentElement);
  IterateChildren(FRoot as TIdSoapOpenXmlElement);
end;

procedure TIdSoapOpenXmlDom.StartBuild(AName: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.StartBuild';
begin
  assert(self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');
  FDom := TDomImplementation.Create(NIL);
  FDoc := FDom.createDocument(AName, NIL);
  FRoot := TIdSoapOpenXmlElement.create(self, nil, FDoc.documentElement);
end;

procedure TIdSoapOpenXmlDom.writeUTF16(ADest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.writeUTF16';
begin
  assert(self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  FDoc.writeCodeAsUTF16(ADest);
end;

procedure TIdSoapOpenXmlDom.writeUTF8(ADest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlDom.writeUTF8';
begin
  assert(self.TestValid(TIdSoapOpenXmlDom), ASSERT_LOCATION+': self is not valid');
  FDoc.writeCodeAsUTF8(ADest);
end;

{ TIdSoapOpenXmlElement }

constructor TIdSoapOpenXmlElement.create(ADom : TIdSoapXmlDom; AParent : TIdSoapXmlElement; AElement : TdomElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.create';
begin
  inherited create(ADom, AParent);
  assert(IdSoapTestNodeValid(AElement, TdomElement), ASSERT_LOCATION+': Element is not valid');
  FElement := AElement;
end;

function TIdSoapOpenXmlElement.GetAttributeCount : integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetAttributeCount';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElement.attributes.length;
end;

function TIdSoapOpenXmlElement.GetName : WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetName';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElement.localName;
end;

function TIdSoapOpenXmlElement.GetNamespace : WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetNamespace';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElement.namespaceURI;
end;

function TIdSoapOpenXmlElement.GetNodeName : WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetNodeName';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElement.nodeName;
end;

function TIdSoapOpenXmlElement.GetHasText : boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetHasText';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  result := (FElement.childNodes.length = 0) or ((FElement.childNodes.length = 1) and (FElement.firstChild is TdomText));
end;

function TIdSoapOpenXmlElement.GetTextContentA:String;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetTextContent';
begin
  result := GetTextContentW;
end;

function TIdSoapOpenXmlElement.GetTextContentW:WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetTextContent';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(hasText, ASSERT_LOCATION+': attempt to get text content when HasText is false');
  if FElement.childNodes.length = 0 then
    begin
    result := '';
    end
  else
    begin
    result := FElement.firstChild.nodeValue;
    end;
end;

function TIdSoapOpenXmlElement.GetAsXML : WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GetAsXML';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElement.code;
end;

procedure TIdSoapOpenXmlElement.SetTextContentA(AValue : String);
begin
  SetTextContentW(AValue);
end;

procedure TIdSoapOpenXmlElement.SetTextContentW(AValue : WideString);
const
  ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.SetTextContent';
var
  LText : TdomText;
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  // no check on AValue
  assert(FElement.childNodes.length = 0, ASSERT_LOCATION+': attempt to set TextContent when children already exist');
  LText := (FDom as TIdSoapOpenXmlDom).FDoc.createTextNode(AValue);
  FElement.appendChild(LText);
end;

function TIdSoapOpenXmlElement.AppendChild(AName : WideString):TIdSoapxmlelement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.AppendChild';
var
  LElem : TdomElement;
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  LElem := (FDom as TIdSoapOpenXmlDom).FDoc.createElement(AName);
  FElement.appendChild(LElem);
  result := TIdSoapOpenXmlElement.create(FDom, Self, LElem);
  PrivAppendChild(result);
end;

procedure TIdSoapOpenXmlElement.removeChild(AElement : TIdSoapXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.removeChild';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(AElement.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': element is not valid');
  FElement.removeChild((AElement as TIdSoapOpenXmlElement).FElement);
  PrivRemoveChild(AElement);
end;

function TIdSoapOpenXmlElement.hasAttribute(const ANamespace, AName : WideString): boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.hasAttribute';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  // no check on namespace
  assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  result := FElement.hasAttributeNS(ANamespace, AName);
end;

function TIdSoapOpenXmlElement.getAttribute(const ANamespace, AName : WideString): WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.getAttribute';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  // no check on namespace
  assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  result := FElement.getAttributeNS(ANamespace, AName);
end;

function TIdSoapOpenXmlElement.getAttributeName(i : integer; Var VNamespace, VName : WideString) :boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.getAttributeName';
var
  LAttr : TdomAttr;
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  // no check on i
  LAttr := FElement.attributes.item(i) as TdomAttr;
  result := assigned(LAttr);
  if result then
    begin
    VNamespace := LAttr.namespaceURI;
    VName := LAttr.localName;
    end;
end;

procedure TIdSoapOpenXmlElement.setAttribute(AName, AValue : WideString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.setAttribute';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  // no check on AValue
  FElement.setAttribute(AName, AValue);
end;

function TIdSoapOpenXmlElement.ResolveXMLNamespaceCode(ANamespace, ALocation : WideString) : string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.ResolveXMLNamespaceCode';
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(ANamespace <> '', ASSERT_LOCATION+': namespace is not valid');
  assert(ALocation <> '', ASSERT_LOCATION+': location is not valid');
  result := IdSoapNamespaces.ResolveXMLNamespaceCode(FElement, ANamespace, ALocation);
end;

procedure TIdSoapOpenXmlElement.BuildChildFromXML(ASrc : WideString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.BuildChildFromXML';
var
  LRoot : TdomDocumentFragment;
  LParser : TXmlToDomParser;
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  // no check on ASrc

  // this code courtesy of Ernst van der Pols, NLSoftware@hetnet.nl
  // import fragment
  LRoot := (FDom as TIdSoapOpenXmlDom).FDoc.CreateDocumentFragment;
  LParser := TXmlToDomParser.Create(nil);
  try
    try
      LParser.DocStringToDom(ASrc,'','',LRoot);
      FElement.appendChild(LRoot);
    except
      on ex: Exception do
        begin
        (FDom as TIdSoapOpenXmlDom).FDoc.FreeAllNodes(TdomNode(LRoot));
        TextContentW := 'Invalid XML details: '+ASrc;
        end;
    end;
  finally
    LParser.Free;
  end;
end;

procedure TIdSoapOpenXmlElement.GrabChildren(AElem: TIdSoapXmlElement; AOtherDOM : boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapOpenXmlElement.GrabChildren';
var
  LSrc, LDest : TdomElement;
  i : integer;
begin
  assert(self.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': self is not valid');
  // check provider is the right type
  IdRequire(AElem.TestValid(TIdSoapOpenXmlElement), ASSERT_LOCATION+': Elem is not valid');

  LSrc := (AELem as TIdSoapOpenXmlElement).FElement;
  LDest := FElement;

  while assigned(LSrc.FirstChild) do
    begin
    if AOtherDom then
      begin
      LDest.AppendChild((FDom as TIdSoapOpenXMLDom).FDoc.importNode(LSrc.FirstChild, true));
      LSrc.removeChild(LSrc.FirstChild);
      end
    else
      begin
      LDest.AppendChild(LSrc.FirstChild);
      end;
    end;
  // now the attributes
  for i := 0 to LSrc.attributes.length - 1 do
    begin
    LDest.setAttribute(LSrc.attributes.item(i).nodeName, LSrc.attributes.item(i).textContent);
    end;
end;

{$IFDEF USE_MSXML}

function CreateOleInterface(AOleObjectName: String): IUnknown;
const ASSERT_LOCATION = ASSERT_UNIT +'.CreateOleInterface';
var
  LVariant: Variant;
begin
  LVariant := CreateOleObject(AOleObjectName);
  assert(VarType(LVariant) = varDispatch, ASSERT_LOCATION+': Dispatch type expected');
  result := IUnknown(TVarData(LVariant).VDispatch);
end;

{ TIdSoapMSXmlDom }

destructor TIdSoapMSXmlDom.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlDom.destroy';
begin
  assert(self.TestValid(TIdSoapMSXmlDom), ASSERT_LOCATION+': self is not valid');
  FDom := nil;
  inherited;
end;

function TIdSoapMSXmlDom.ImportElement(AElem: TIdSoapXmlElement): TIdSoapXmlElement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlDom.ImportElement';
begin
  assert(Self.TestValid(TIdSoapMSXmlDom), ASSERT_LOCATION+': self is not valid');
  // check that XML provider is the right type
  IdRequire(AElem.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': Element is not valid');

  result := TIdSoapMSXmlElement.create(self, nil, (AElem as TIdSoapMsXmlElement).FElem.cloneNode(true) as IXMLDOMElement);
end;

procedure TIdSoapMSXmlDom.IterateChildren(AElem: TIdSoapMSXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlDom.IterateChildren';
var
  LNode : IXMLDOMNode;
  LChild : TIdSoapMSXmlElement;
begin
  assert(self.TestValid(TIdSoapMSXmlDom), ASSERT_LOCATION+': self is not valid');
  assert(AElem.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': Elem is not valid');
  LNode := AElem.FElem.firstChild;
  while Assigned(LNode) do
    begin
    if LNode.nodeType = NODE_ELEMENT then
      begin
      LChild := TIdSoapMSXmlElement.create(Self, AElem, LNode as IXMLDOMElement);
      AElem.PrivAppendChild(LChild);
      IterateChildren(LChild);
      end;
    LNode := LNode.nextSibling;
    end;
end;

procedure TIdSoapMSXmlDom.Read(ASource: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlDom.Read';
var
  LAdapter : Variant;
begin
  assert(self.TestValid(TIdSoapMSXmlDom), ASSERT_LOCATION+': self is not valid');
  FDom := CreateOleInterface('MSXML2.DOMDocument.4.0') as IXMLDomDocument2;
  FDom.validateOnParse := false;
  FDom.preserveWhiteSpace := true;
  FDom.setProperty('NewParser', true);
  LAdapter := TStreamAdapter.create(ASource) as IStream;
  assert(FDom.load(LAdapter), ASSERT_LOCATION+': xml load failed: '+FDom.parseError.reason);
  assert(assigned(FDom.documentElement), ASSERT_LOCATION+': document could not be parsed');
  FDom.documentElement.normalize;
  FRoot := TIdSoapMSXmlElement.create(Self, nil, FDom.documentElement);
  IterateChildren(FRoot as TIdSoapMSXmlElement);
end;

procedure TIdSoapMSXmlDom.StartBuild(AName: string);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlDom.StartBuild';
begin
  assert(self.TestValid(TIdSoapMSXmlDom), ASSERT_LOCATION+': self is not valid');
  FDom := CreateOleInterface('MSXML2.DOMDocument.4.0') as IXMLDomDocument2;
  FDom.documentElement := FDom.createElement(AName);
  FRoot := TIdSoapMSXmlElement.create(Self, nil, FDom.documentElement);
end;

procedure TIdSoapMSXmlDom.writeUTF16(ADest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlDom.writeUTF16';
var
  LAdapter : Variant;
begin
  assert(self.TestValid(TIdSoapMSXmlDom), ASSERT_LOCATION+': self is not valid');
  // set up for utf-16....
  LAdapter := TStreamAdapter.create(ADest) as IStream;
  FDom.save(LAdapter);
end;

procedure TIdSoapMSXmlDom.writeUTF8(ADest: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlDom.writeUTF8';
var
  LAdapter : Variant;
begin
  assert(self.TestValid(TIdSoapMSXmlDom), ASSERT_LOCATION+': self is not valid');
  LAdapter := TStreamAdapter.create(ADest) as IStream;
  FDom.save(LAdapter);
end;

{ TIdSoapMSXmlElement }

constructor TIdSoapMSXmlElement.create(ADom: TIdSoapXmlDom; AParent: TIdSoapXmlElement; AElem : IXMLDOMElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.create';
begin
  inherited create(ADom, AParent);
  FElem := AElem;
end;


function TIdSoapMSXmlElement.AppendChild(AName: WideString): TIdSoapxmlelement;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.AppendChild';
var
  LElem : IXMLDOMElement;
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  LElem := (FDom as TIdSoapMSXmlDom).FDom.createElement(AName);
  FElem.appendChild(LElem);
  result := TIdSoapMSXmlElement.create(FDom, Self, LElem);
  PrivAppendChild(result);
end;

procedure TIdSoapMSXmlElement.BuildChildFromXML(ASrc: WideString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.BuildChildFromXML';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
 {TODO}
end;

function TIdSoapMSXmlElement.GetAsXML: WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GetAsXML:';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElem.xml;
end;

function TIdSoapMSXmlElement.getAttribute(const ANamespace, AName: WideString): WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.getAttribute';
var
  LAttr : IXMLDOMNamedNodeMap;
  LNode : IXMLDOMAttribute;
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  LAttr := FElem.attributes;
  LNode := LAttr.getQualifiedItem(AName, ANamespace) as IXMLDOMAttribute;
  if assigned(Lnode) then
    begin
    result := LNode.text;
    end;
end;

function TIdSoapMSXmlElement.GetAttributeCount: integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GetAttributeCount:';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElem.attributes.length;
end;

function TIdSoapMSXmlElement.getAttributeName(i: integer; var VNamespace, VName: WideString): boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.getAttributeName';
var
  LAttr : IXMLDOMNamedNodeMap;
  LNode : IXMLDOMNode;
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  LAttr := FElem.attributes;
  LNode := LAttr.item[i];
  result := Assigned(LNode);
  if result then
    begin
    VNamespace := LNode.namespaceURI;
    VName := LNode.baseName;
    end;
end;

function TIdSoapMSXmlElement.GetHasText: boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GetHasText:';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  result := (FElem.childNodes.length = 0) or ((FElem.childNodes.length = 1) and (FElem.firstChild.NodeType = NODE_TEXT));
end;

function TIdSoapMSXmlElement.GetName: WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GetName:';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElem.baseName;
end;

function TIdSoapMSXmlElement.GetNamespace: WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GetNamespace:';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElem.namespaceURI;
end;

function TIdSoapMSXmlElement.GetNodeName: WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GetNodeName:';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  result := FElem.nodeName;
end;

function TIdSoapMSXmlElement.GetTextContentA: String;
begin
  result := GetTextContentW;
end;

function TIdSoapMSXmlElement.GetTextContentW: WideString;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GetTextContent:';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  assert(hasText, ASSERT_LOCATION+': attempt to get text content when HasText is false');
  if FElem.childNodes.length = 0 then
    begin
    result := '';
    end
  else
    begin
    result := FElem.firstChild.text;
    end;
end;

function TIdSoapMSXmlElement.hasAttribute(const ANamespace, AName: WideString): boolean;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.hasAttribute';
var
  LAttr : IXMLDOMNamedNodeMap;
  LNode : IXMLDOMNode;
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  LAttr := FElem.attributes;
  LNode := LAttr.getQualifiedItem(AName, ANamespace);
  result := assigned(LNode);
end;

procedure TIdSoapMSXmlElement.removeChild(AElement: TIdSoapXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.removeChild';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  FElem.removeChild((AElement as TIdSoapMSXmlElement).FElem);
  PrivRemoveChild(AElement);
end;

function ResolveMSXMLNamespaceCode(AElement : IXMLDOMElement; ANamespace, ALocation : string):string;
const ASSERT_LOCATION = 'IdSoapXML.ResolveMSXMLNamespaceCode';
var
  i : integer;
  LAttr : IXMLDOMAttribute;
begin
  assert(ANamespace <> '', ASSERT_LOCATION+': namespace is blank ('+ALocation+')');
  assert(ALocation <> '', ASSERT_LOCATION+': Location is blank ('+ALocation+')');

  result := '';
  for i := 0 to AElement.attributes.length - 1 do
    begin
    LAttr := AElement.Attributes.item[i] as IXMLDOMAttribute;
    if (LAttr.prefix = 'xmlns') and
       (LAttr.baseName = ANameSpace) then
      begin
      result := LAttr.text;
      break;
      end;
    end;
  if result = '' then
    begin
    if assigned(AElement.parentNode) then
      begin
      result := ResolveMSXMLNamespaceCode(AElement.parentNode as IXMLDOMElement, ANamespace, ALocation);
      end
    else
      begin
      raise EIdSoapNamespaceProblem.CreateFmt(RS_ERR_SOAP_UNRESOLVABLE_NAMESPACE, [ANamespace, ALocation]);
      end;
    end;
end;


function TIdSoapMSXmlElement.ResolveXMLNamespaceCode(ANamespace, ALocation: WideString): string;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.ResolveXMLNamespaceCode';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  result := ResolveMSXMLNamespaceCode(FElem, ANamespace, ALocation);
end;

procedure TIdSoapMSXmlElement.setAttribute(AName, AValue: WideString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.setAttribute';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  FElem.setAttribute(AName, AValue);
end;

procedure TIdSoapMSXmlElement.SetTextContentA(AValue: String);
begin
  SetTextContentW(AValue);
end;

procedure TIdSoapMSXmlElement.SetTextContentW(AValue: WideString);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.SetTextContent';
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  FElem.text := AValue;
end;

procedure TIdSoapMSXmlElement.GrabChildren(AElem: TIdSoapXmlElement; AOtherDOM : boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapMSXmlElement.GrabChildren';
var
  LSrc, LDest : IXMLDOMElement;
  i : integer;
begin
  assert(self.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': self is not valid');
  // check provider is the right type
  IdRequire(AElem.TestValid(TIdSoapMSXmlElement), ASSERT_LOCATION+': Elem is not valid');

  LSrc := (AELem as TIdSoapMSXmlElement).FElem;
  LDest := FElem;

  while assigned(LSrc.FirstChild) do
    begin
    if AOtherDom then
      begin
      LDest.AppendChild(LSrc.FirstChild.cloneNode(true));
      LSrc.removeChild(LSrc.FirstChild);
      end
    else
      begin
      LDest.AppendChild(LSrc.FirstChild);
      end;
    end;
  // now the attributes
  for i := 0 to LSrc.attributes.length - 1 do
    begin
    LDest.setAttribute(LSrc.attributes.item[i].nodeName, LSrc.attributes.item[i].text);
    end;
end;
{$ENDIF}

function IdSoapDomFactory(AXmlProvider : TIdSoapXmlProvider = xpOpenXML) : TIdSoapXmlDom;
const ASSERT_LOCATION = ASSERT_UNIT+'.IdSoapDomFactory';
begin
  assert(IdEnumIsValid(TypeInfo(TIdSoapXmlProvider), ord(AXmlProvider)), ASSERT_LOCATION+': XML provider type is invalid');
  {$IFDEF USE_MSXML}
  if AXmlProvider = xpMsXml then
    begin
    result := TIdSoapMSXmlDom.create;
    end
  else {$ENDIF} if AXmlProvider = xpCustom then
    begin
    result := TIdSoapCustomDom.create;
    end
  else  if AXmlProvider = xpOpenXML then
    begin
    result := TIdSoapOpenXmlDom.create;
    end
  else
    begin
    raise EIdSoapBadParameterValue.create(ASSERT_LOCATION+': unknown soap Provider "'+inttostr(ord(AXMLProvider))+'"'); 
    end;
end;

{== String Utilities for writing XML directly =================================}

procedure StringAppendStart(var VStr: String; var VLen: Integer);
begin
  VLen := Length(VStr);
  SetLength(VStr, Length(VStr) + 4096);
end;

procedure StringAppend(var VStr: String; AStrToAdd: String; var VLen: Integer);
begin
  if (AStrToAdd = '') then
    begin
    exit;
    end;
  if VLen + length(AStrToAdd) > length(VStr) then
    SetLength(VStr, length(VStr) + max(4096, length(AStrToAdd)));
  move(AStrToAdd[1], VStr[VLen + 1], length(AStrToAdd));
  inc(VLen, length(AStrToAdd));
end;

procedure StringAppendClose(var VStr: String; ALen: Integer);
begin
  SetLength(VStr, ALen);
end;

function TextToXML(AStr : String):String;
const ASSERT_LOCATION = 'TextToXML';
var
  i, LLen: Integer;
  s : string;
begin
  i := 1;
  result := '';
  StringAppendStart(result, LLen);
  while i <= length(AStr) do
    begin
    case AStr[i] of
      '''':s := '&#' + IntToStr(Ord(AStr[i])) + ';';
      '"': s := '&quot;';
      '&': s := '&amp;';
      '<': s := '&lt;';
      '>': s := '&gt;';
      #13:
        begin
        s := #10;
        if (i < length(AStr)) and (AStr[i + 1] = #10) then
          begin
          Inc(i);
          end;
        end;
    else
        begin
        if AStr[i] in [' '..'~'] then
          begin
          s :=  AStr[i]
          end
        else
          begin
          // s := '&#' + IntToStr(Ord(AStr[i])) + ';';
          s := UTF16BEToUTF8Str(cp1252ToUTF16Str(AStr[i]), false);
          end;
        end;
    end;
    StringAppend(result, s, LLen);
    inc(i);
    end;
  StringAppendClose(result, LLen);
end;

function XMLToText(AStr: String): String;
const ASSERT_LOCATION = 'XMLToText';
var
  i, j, LLen: Integer;
  s : string;
begin
  i := 1;
  result := '';
  StringAppendStart(result, LLen);
  while i <= length(AStr) do
    begin
    if AStr[i] = '&' then
      begin
      inc(i);
      j := i;
      repeat
        inc(i);
        assert(i <= length(AStr), ASSERT_LOCATION+': illegal XML source "'+AStr+'" - unterminated Entity');
      until AStr[i] = ';';
      s := copy(AStr, j, i-j);
      if s[1] = '#' then
        begin
        StringAppend(result, chr(IdStrToIntWithError(copy(s, 2, length(s)), 'Entity in XML source "'+AStr+'"')), LLen);
        end
      else if s = 'quot' then
        begin
        StringAppend(result, '"', LLen);
        end
      else if s = 'amp' then
        begin
        StringAppend(result, '&', LLen);
        end
      else if s = 'lt' then
        begin
        StringAppend(result, '<', LLen);
        end
      else if s = 'gt' then
        begin
        StringAppend(result, '>', LLen);
        end
      else if s = 'apos' then
        begin
        StringAppend(result, '''', LLen);
        end
      else
        begin
        assert(false, ASSERT_LOCATION+': illegal XML source "'+AStr+'" - unknown Entity +"'+s+'"');
        end;
      end
    else
      begin
      
      if (AStr[i] = #13) then
        begin
        StringAppend(result, #10, LLen);
        if (i < length(AStr)) and (AStr[i+1] = #10) then
          begin
          inc(i);
          end;
        end
      else
        begin
        StringAppend(result, AStr[i], LLen);
        end;
      end;
    inc(i);
    end;
  StringAppendClose(result, LLen);
end;

function IsXmlNameChar(const ACh : Char): boolean;
begin
  result := ACh in ['_', ':', '-', '.', 'A'..'Z', 'a'..'z', '0'..'9'];
end;

function IsXmlWhiteSpace(const ACh : Char): boolean;
begin
  result := ACh in [#$09,#$0A,#$0D,#$20];
end;

{ TIdSoapCustomElement }

constructor TIdSoapCustomElement.create(ADom : TIdSoapXmlDom; AParent : TIdSoapXmlElement; AName : widestring);
begin
  inherited create(ADom, AParent);
  FNodeName := AName;
  FName := AName;
  FContent := '';
  FAttr := TObjectList.create(true);
  FXMLNs := TObjectList.create(false);
end;

destructor TIdSoapCustomElement.destroy;
begin
  FreeAndNil(FXMLNs);
  FreeAndNil(FAttr);
  inherited;
end;

function TIdSoapCustomElement.AppendChild(AName: WideString): TIdSoapxmlelement;
begin
  result := TIdSoapCustomElement.create(FDom, self, AName);
  FChildren.Add(result);
end;

procedure TIdSoapCustomElement.BuildChildFromXML(ASrc: WideString);
begin
  raise exception.create('not supported');
end;

function TIdSoapCustomElement.GetAsXML: WideString;
var
  LCnt : String;
  LLen : integer;
begin
  LCnt := '';
  StringAppendStart(LCnt, LLen);
  WriteToString(LCnt, LLen);
  StringAppendClose(LCnt, LLen);
  result := LCnt;
end;

function TIdSoapCustomElement.getAttribute(const ANamespace, AName: WideString): WideString;
var
  i : integer;
  LAttr : TIdSoapCustomAttribute;
begin
  result := '';
  for i := 0 to FAttr.count -1 do
    begin
    LAttr := FAttr[i] as TIdSoapCustomAttribute;
    if (LAttr.FNs = ANamespace) and (LAttr.FName = AName) then
      begin
      result := LAttr.FContent;
      exit;
      end;
    end;
end;

function TIdSoapCustomElement.GetAttributeCount: integer;
begin
  result := FAttr.count;
end;

function TIdSoapCustomElement.getAttributeName(i: integer; var VNamespace, VName: WideString): boolean;
var
  LAttr : TIdSoapCustomAttribute;
begin
  LAttr := FAttr[i] as TIdSoapCustomAttribute;
  result := true;
  VNamespace := LAttr.FNs;
  VName := LAttr.FName;
end;

function TIdSoapCustomElement.GetHasText: boolean;
begin
  result := (FContent <> '') and (FChildren.Count = 0);
end;

function TIdSoapCustomElement.GetName: WideString;
begin
  result := FName;
end;

function TIdSoapCustomElement.GetNamespace: WideString;
begin
  result := FNs;
end;

function TIdSoapCustomElement.GetNodeName: WideString;
begin
  result := FNodeName;
end;

function TIdSoapCustomElement.GetTextContentA: String;
begin
  result := FContent;
end;

function TIdSoapCustomElement.GetTextContentW: WideString;
begin
  {$IFDEF MSWINDOWS}
  result := Iso8859_1ToUTF16Str(FContent);
  {$ELSE}
  result := UTF8ToUTF16BEStr(FContent);
  {$ENDIF}
end;

procedure TIdSoapCustomElement.GrabChildren(AElem: TIdSoapXmlElement; AOtherDOM: boolean);
begin
  raise exception.create('not supported');
end;

function TIdSoapCustomElement.hasAttribute(const ANamespace, AName: WideString): boolean;
var
  i : integer;
  LAttr : TIdSoapCustomAttribute;
begin
  result := false;
  for i := 0 to FAttr.count -1 do
    begin
    LAttr := FAttr[i] as TIdSoapCustomAttribute;
    if (LAttr.FNs = ANamespace) and (LAttr.FName = AName) then
      begin
      result := true;
      exit;
      end;
    end;
end;

procedure TIdSoapCustomElement.removeChild(AElement: TIdSoapXmlElement);
begin
  FChildren.Remove(AElement);
end;

function TIdSoapCustomElement.ResolveXMLNamespaceCode(ANamespace, ALocation: WideString): string;
const ASSERT_LOCATION ='ss';
var
  i : integer;
  LAttr : TIdSoapCustomAttribute;
begin
  if (ANamespace = 'xml') or (ANamespace = 'xmlns') then
    begin
    result := ANamespace;
    end
  else
    begin
    result := '';
    for i := 0 to FXMLNs.count -1 do
      begin
      LAttr := FXMLNs[i] as TIdSoapCustomAttribute;
      if (LAttr.FName = ANamespace) then
        begin
        result := LAttr.FContent;
        break;
        end
      end;
    end;
  if result = '' then
    begin
    if assigned(FParentNode) then
      begin
      result := FParentNode.ResolveXMLNamespaceCode(ANamespace, ALocation);
      end
    else
      begin
      IdRequire(false, ASSERT_LOCATION+': Error reading XML document: the namespace prefix "'+ANamespace+'" found at "'+ALocation+'" could not be resolved');
      end;
    end;
end;

procedure TIdSoapCustomElement.setAttribute(AName, AValue: WideString);
var
  LAttr : TIdSoapCustomAttribute;
begin
  LAttr := TIdSoapCustomAttribute.create;
  LAttr.FName := AName;
  LAttr.FContent := AValue;
  FAttr.Add(LAttr);
end;

procedure TIdSoapCustomElement.SetTextContentA(AValue: String);
begin
  FContent := TextToXML(AValue);
end;

procedure TIdSoapCustomElement.SetTextContentW(AValue: WideString);
begin
  FContent := UTF16BEToUTF8Str(AValue, false);
end;

procedure TIdSoapCustomElement.WriteToString(var VCnt: string; var VLen: integer);
var
  i : integer;
  LAttr : TIdSoapCustomAttribute;
begin
  StringAppend(VCnt, '<'+FNodeName, VLen);
  for i := 0 to FAttr.count - 1 do
    begin
    LAttr := FAttr[i] as TIdSoapCustomAttribute;
    StringAppend(VCnt, ' ', VLen);
    StringAppend(VCnt, LAttr.FName, VLen);
    StringAppend(VCnt, '="', VLen);
    StringAppend(VCnt, TextToXML(LAttr.FContent), VLen);
    StringAppend(VCnt, '"', VLen);
    end;
  if (FContent = '') and (FChildren.count = 0) then
    begin
    StringAppend(VCnt, '/>', VLen);
    end
  else
    begin
    StringAppend(VCnt, '>', VLen);
    if FContent <> '' then
      begin
      StringAppend(VCnt, FContent, VLen);
      end;
    for i := 0 to FChildren.Count - 1 do
      begin
      (FChildren[i] as TIdSoapCustomElement).WriteToString(VCnt, VLen);
      end;
     StringAppend(VCnt, '</', VLen);
     StringAppend(VCnt, FName, VLen);
     StringAppend(VCnt, '>', VLen);
    end;
end;

function TIdSoapCustomElement.ResolveNamespaces(ADefaultNamespace: String): String;
var
  LAttr : TIdSoapCustomAttribute;
  sl, sr : string;
  i : integer;
begin
  result := ADefaultNamespace;
  for i := 0 to FAttr.count - 1 do
    begin
    LAttr := FAttr[i] as TIdSoapCustomAttribute;
    if (LAttr.FNs = '') and (LAttr.FName = 'xmlns') then
      begin
      result := LAttr.FContent;
      end
    else if (LAttr.FNs) = 'xmlns' then
      begin
      FXMLNs.Add(LAttr);
      end;
    end;
  if pos(':', FNodeName) = 0 then
    begin
    FNs := result;
    FName := FNodeName;
    end
  else
    begin
    SplitNamespace(FNodeName, sl, sr);
    FNs := ResolveXMLNamespaceCode(sl, 'XML Element "'+Path+'"');
    FName := sr;
    end;
  for i := 0 to FAttr.count - 1 do
    begin
    LAttr := FAttr[i] as TIdSoapCustomAttribute;
    if (LAttr.FNs <> '') and (LAttr.FNs <> 'xml') and (LAttr.FNs <> 'xmlns') then
      begin
      LAttr.FNs := ResolveXMLNamespaceCode(LAttr.FNs, 'Attribute "'+LAttr.FName+'" on '+Path);
      end;
    end;
end;

{ TIdSoapCustomDom }

function TIdSoapCustomDom.ImportElement(AElem: TIdSoapXmlElement): TIdSoapXmlElement;
begin
  raise exception.create('not supported');
end;

function TIdSoapCustomDom.ReadToken(ASkipWhitespace : Boolean): string;
const ASSERT_LOCATION = 'asdfasd';
var
  LCh : char;
  LStart : integer;
begin
  if ASkipWhitespace then
    begin
    while (FCursor < FLength) and IsXmlWhiteSpace(FSrc[FCursor]) do
      begin
      inc(FCursor);
      end;
    end;
  IdRequire(FCursor < FLength, ASSERT_LOCATION+': read of end of stream');
  LCh := FSrc[FCursor];
  inc(FCursor);
  if isXmlNameChar(LCh) then
    begin
    LStart := FCursor - 1;
    while (FCursor < FLength) and isXmlNameChar(FSrc[FCursor]) do
      begin
      inc(FCursor);
      end;
    IdRequire(FCursor < FLength, ASSERT_LOCATION+': read of end of stream');
    Setlength(result, FCursor - LStart);
    move(FSrc[LStart], result[1], FCursor - LStart);
    end
  else
    begin
    result := LCh;
    case LCh of
      '<':begin
          IdRequire(FCursor < FLength, ASSERT_LOCATION+': read of end of stream');
          LCh := FSrc[FCursor];
          inc(FCursor);
          if (LCh in ['?', '/']) then
            begin
            result := '<' + LCh;
            end
          else
            begin
            dec(FCursor);
            end;
          end;
      '/':begin
          IdRequire(FCursor < FLength, ASSERT_LOCATION+': read of end of stream');
          LCh := FSrc[FCursor];
          inc(FCursor);
          if LCh = '>' then
            begin
            result := '/>';
            end
          else
            begin
            dec(FCursor);
            end;
          end;
    else
      // don't care
    end;
    end;
end;

function TIdSoapCustomDom.ReadToNextChar(ACh : Char): String;
const ASSERT_LOCATION= 'asasd';
var
  LStart : integer;
begin
  LStart := FCursor;
  while (FCursor < FLength) and (FSrc[FCursor]<> ACh) do
    begin
    inc(FCursor);
    end;
  IdRequire(FCursor < FLength, ASSERT_LOCATION+': read of end of stream');
  Setlength(result, FCursor - LStart);
  if FCursor - LStart > 0 then
    begin
    move(FSrc[LStart], result[1], FCursor - LStart);
    end;
end;

procedure TIdSoapCustomDom.ReadAttribute(AName : string; AOwner: TIdSoapCustomElement);
var
  LAttr : TIdSoapCustomAttribute;
  s : string;
begin
  LAttr := TIdSoapCustomAttribute.create;
  AOwner.FAttr.Add(LAttr);
  SplitNamespace(AName, s, AName);
  LAttr.FNs := s;
  LAttr.FName := AName;
  s := ReadToken(true);
  assert(s = '=');
  s := ReadToken(true);
  assert((s = '"') or (s = ''''));
  {$IFDEF MSWINDOWS}
  if FIsUTF8 then
    begin
    LAttr.FContent := IdSoapUTF8ToAnsi(XmlToText(ReadToNextChar(s[1])));
    end
  else
    begin
    LAttr.FContent := XmlToText(ReadToNextChar(s[1]));
    end;
  {$ELSE}
  if FIsUTF8 then
    begin
    LAttr.FContent := XmlToText(ReadToNextChar(s[1]));
    end
  else
    begin
    LAttr.FContent := IdSoapAnsiToUTF8(XmlToText(ReadToNextChar(s[1])));
    end;
  {$ENDIF}
  s := ReadToken(false);
  assert((s = '"') or (s = ''''));
end;

function TIdSoapCustomDom.ReadElement(AParent : TIdSoapXMLElement; ADefaultNamespace : string) : TIdSoapCustomElement;
var
  LNew, LSib : TIdSoapCustomElement;
  s : string;
begin
  LSib := nil;
  result := TIdSoapCustomElement.create(self, AParent, '');
  result.FNodeName := ReadToken(true);
  s := ReadToken(true);
  while (s <> '/>') and (s <> '>') do
    begin
    ReadAttribute(s, result);
    s := ReadToken(true);
    end;
  ADefaultNamespace := result.ResolveNamespaces(ADefaultNamespace);
  if s = '>' then
    begin
    // there's actual content to read
    while s <> '</' do
      begin
      {$IFDEF MSWINDOWS}
      if FIsUTF8 then
        begin
        result.FContent := result.FContent + IdSoapUTF8ToAnsi(XmlToText(ReadToNextChar('<')));
        end
      else
        begin
        result.FContent := result.FContent + XmlToText(ReadToNextChar('<'));
        end;
      {$ELSE}
      if FIsUTF8 then
        begin
        result.FContent := result.FContent + XmlToText(ReadToNextChar('<'));
        end
      else
        begin
        result.FContent := result.FContent + IdSoapAnsiToUTF8(XmlToText(ReadToNextChar('<')));
        end;
      {$ENDIF}
      s := ReadToken(false);
      if s = '<' then
        begin
        LNew := readElement(result, ADefaultNamespace);
        if assigned(LSib) then
          begin
          LSib.FSibling := LNew;
          end;
        LSib := LNew;
        Result.FChildren.Add(LNew);
        end;
      end;
    s := ReadToken(true);
    assert(s = result.FNodeName);
    s := Readtoken(true);
    assert(s = '>');
    end;
end;

procedure TIdSoapCustomDom.Read(ASource: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapCustomDom.Read';
var
  s : String;
begin
  FLength := ASource.Size - ASource.Position;
  GetMem(FSrc, FLength);
  try
    ASource.Read(FSrc^, FLength);
    FCursor := 0;
    s := ReadToken(true);
    IdRequire(s[1] = '<', ASSERT_LOCATION+': Unable to read Soap Packet - starts with "'+s+'"');
    if s = '<?' then
      begin
      repeat
        s := readToken(true);
        if s = 'encoding' then
          begin
          s := readToken(true);
          assert(s = '=');
          s := readToken(true);
          assert((s = '"') or (s=''''));
          s := readToken(true);
          if AnsiSameText(s, 'ISO-8859-1') then
            begin
            FIsUTF8 := false;
            end
          else if AnsiSameText(s, 'UTF-8') then
            begin
            FIsUTF8 := true;
            end
          else
            begin
            raise EIdSoapException.create('The IndySoap Custom XML parser does not support the encoding "'+s+'"');
            end;
          end;
      until (s = '>') or (s = '?>');
      s := ReadToken(true);
      end;
    IdRequire(s = '<', ASSERT_LOCATION+': Unable to read Soap Packet - First element has "'+s+'"');
    FRoot := ReadElement(nil, '');
  finally
    FreeMem(FSrc);
  end;
end;

procedure TIdSoapCustomDom.StartBuild(AName: string);
begin
  FRoot:= TIdSoapCustomElement.create(Self, nil, AName);
end;

procedure TIdSoapCustomDom.writeUTF16(ADest: TStream);
begin
  raise exception.create('unicode is not supported');
end;

procedure TIdSoapCustomDom.writeUTF8(ADest: TStream);
var
  LCnt : String;
  LLen : integer;
begin
  LCnt := '';
  StringAppendStart(LCnt, LLen);
  {$IFDEF MSWINDOWS}
  StringAppend(LCnt, '<?xml version="1.0" encoding="ISO-8859-1" ?>', LLen);
  {$ELSE}
  StringAppend(LCnt, '<?xml version="1.0" encoding="UTF-8" ?>', LLen);
  {$ENDIF}
  (FRoot as TIdSoapCustomElement).WriteToString(LCnt, LLen);
  StringAppendClose(LCnt, LLen);
  ADest.Write(LCnt[1], length(LCnt));
end;

end.


