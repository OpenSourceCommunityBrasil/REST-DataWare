{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15798: IdSoapWsdlXml.pas 
{
{   Rev 1.3    20/6/2003 00:05:16  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.2    18/3/2003 11:04:34  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.1    25/2/2003 13:14:08  GGrieve
}
{
{   Rev 1.0    11/2/2003 20:37:56  GGrieve
}
{
IndySOAP: interconversion between ITI and WSDL
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Set, header and default value support
  18-Mar 2003   Grahame Grieve                  Schema Extensibility support
  25-Feb 2003   Grahame Grieve                  Fix for bug in Borland wsdl importer
  29-Oct 2002   Grahame Grieve                  Support for imports; xsd:Nillable
  04-Oct 2002   Grahame Grieve                  Continued improvements based on a sample WSDL from Apache toolkit
  17-Sep 2002   Grahame Grieve                  Accept bad WSDL base node name
  05-Sep 2002   Grahame Grieve                  Reduce dependency on IdGlobals
  29-Aug 2002   Grahame Grieve                  Fix problem with object inheritence and WSDLs
  28-Aug 2002   Grahame Grieve                  Support for overloaded operations
  26-Aug 2002   Grahame Grieve                  Fix :: in namespace tags etc
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  13 Aug 2002   Grahame Grieve                  Add Support for <sequence>
  24-Jul 2002   Grahame Grieve                  Change to Namespace policy, fixes for WSDL -> pascal conversion
  22-Jul 2002   Grahame Grieve                  Improvements - finally write WSDL OK
  16-Jul 2002   Grahame Grieve                  New OpenXML version - OpenXML handles namespaces when reading
  29-May 2002   Grahame Grieve                  Working on WSDL -> Pascal (incomplete)
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Fix for IDSOAP_USE_RENAMED_OPENXML not defined
  09-Apr 2002   Grahame Grieve                  First written
}

{ TODO :
The reading of schema's needs a major rewrite to
reduce duplication of code. Should be structured
better, but lack of effective DUnit testing is currently
holding back a major rewrite }

unit IdSoapWsdlXml;
{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapDebug,
  IdSoapITIProvider,
  IdSoapNamespaces,
  IdSoapOpenXML,
  IdSoapWsdl;


type
  TIdSoapIncludeEvent = procedure (ASender : TObject; AUri : string; ADefinedNamespace : string) of object;

  TIdSoapWSDLConvertor = class (TIdBaseObject)
  private
    FWsdl : TIdSoapWSDL;
    FNamespaces : TIdSoapXmlNamespaceSupport;
    FDomErr : string;
    FDom : TdomDocument;
    FTypes : TdomElement;
    FOnFindInclude : TIdSoapIncludeEvent;
    FTargetNamespace : string;
    FProvider : TIdSoapITIProvider;
    procedure WriteDocumentation(ANode: TdomElement; ADoco: String);
    procedure DeclareBinding;
    procedure DefineService;
    procedure ListMessages;
    procedure ListOperations;
    procedure ListTypes;

    procedure WriteSchemaAnything(AElement : TdomElement);
    procedure WriteAbstractType(ATypeDefn : TIdSoapWsdlAbstractType; ANode : TdomELement);
    procedure WriteArrayType(ATypeDefn: TIdSoapWsdlArrayType; ASchema: TdomElement; ASuppressName : boolean);
    procedure WriteComplexType(ATypeDefn: TIdSoapWsdlComplexType; ASchema: TdomElement; ASuppressName : boolean);
    procedure WriteEnumeratedType(ATypeDefn: TIdSoapWsdlEnumeratedType; ASchema: TdomElement; ASuppressName : boolean);
    procedure WriteSetType(ATypeDefn: TIdSoapWsdlSetType; ASchema: TdomElement; ASuppressName : boolean);
    function WriteSimpleType(ATypeDefn: TIdSoapWsdlSimpleType; ASchema: TdomElement; ASuppressName : boolean; ANodeName: string = '') : TdomElement;
    procedure WriteElement(ATypeDefn : TIdSoapWsdlElementDefn; ASchema: TdomElement);

    function ReadDocumentation(ANode: TdomElement): String;
    procedure ReadAbstractTypeDetails(ANode: TdomElement; AType : TIdSoapWSDLAbstractType);
    function ReadArrayType(ANamespace, AName: string; ANode: TdomElement):TIdSoapWSDLAbstractType;
    procedure ReadBinding(ANode: TdomElement);
    function ReadEnumSet(ANamespace, AName: string; ANode: TdomElement):TIdSoapWSDLAbstractType;
    function ReadEnumeration(ANamespace, AName: string; ANode: TdomElement):TIdSoapWSDLAbstractType;
    procedure ReadMessages(ARootNode: TdomNode);
    procedure ReadOperations(ANode: TdomElement);
    procedure ReadService(ANode: TdomElement);
    function ReadSimpleType(ANamespace, AName: string; ANode: TdomElement):TIdSoapWSDLAbstractType;
    function ReadStruct(ANamespace, AName: string; ANode: TdomElement):TIdSoapWSDLAbstractType;
    procedure ReadTypes(ANode: TdomElement);

    procedure DOMReadError(ASender: TObject; AError: TdomError; var VGo: boolean);
    procedure ReadHeaders(AElem: TdomElement;
      AMsg: TIdSoapWSDLBindingOperationMessage);
    procedure WriteHeaders(AElem: TdomElement;
      AMsg: TIdSoapWSDLBindingOperationMessage);
  public
    constructor create(AProvider : TIdSoapITIProvider; AWsdl : TIdSoapWSDL);
    procedure WriteToXml(AStream : TStream);
    procedure ReadFromXml(AStream : TStream; ADefinedNamespace : string);
    property OnFindInclude : TIdSoapIncludeEvent read FOnFindInclude write FOnFindInclude;
  end;

implementation

uses
{$IFNDEF DELPHI4}
  Contnrs,
{$ENDIF}
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapUtilities,
  SysUtils;

const    // do not localise any of these
  ID_SOAP_WSDL_ROOT = 'definitions';
  ID_SOAP_WSDL_TARGETNAMESPACE = 'targetNamespace';
  ID_SOAP_WSDL_GEN_ATTRIB_NAME = 'name';
  ID_SOAP_WSDL_GEN_ATTRIB_TYPE = 'type';
  ID_SOAP_WSDL_DOCO = 'documentation';
  ID_SOAP_WSDL_MESSAGE = 'message';
  ID_SOAP_WSDL_PART = 'part';
  ID_SOAP_WSDL_PART_ATTRIB_ELEMENT = 'element';
  ID_SOAP_WSDL_TYPE_ROOT = 'types';
  ID_SOAP_WSDL_ATTRIBUTE = 'attribute';
  ID_SOAP_WSDL_SCHEMA = 'schema';
  ID_SOAP_WSDL_ELEMENT_ATTRIB_TYPE = 'type';
  ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE = 'base';
  ID_SOAP_WSDL_SIMPLETYPE = 'simpleType';
  ID_SOAP_WSDL_DEFAULT = 'default';
  ID_SOAP_WSDL_RESTRICTION = 'restriction';
  ID_SOAP_WSDL_EXTENSION = 'extension';
  ID_SOAP_WSDL_LIST = 'list';
  ID_SOAP_WSDL_SCHEMA_ATTRIB_VALUE = 'value';
  ID_SOAP_WSDL_COMPLEXTYPE = 'complexType';
  ID_SOAP_WSDL_COMPLEXCONTENT = 'complexContent';
  ID_SOAP_WSDL_SIMPLECONTENT = 'simpleContent';
  ID_SOAP_WSDL_ELEMENT = 'element';
  ID_SOAP_WSDL_ENUMERATION = 'enumeration';
  ID_SOAP_WSDL_ALL = 'all';
  ID_SOAP_WSDL_ANY = 'any';
  ID_SOAP_WSDL_CHOICE = 'choice';
  ID_SOAP_SCHEMA_EXTENSION = 'extension';
  ID_SOAP_WSDL_SEQUENCE = 'sequence';
  ID_SOAP_WSDL_PORTTYPE = 'portType';
  ID_SOAP_WSDL_OPERATION = 'operation';
  ID_SOAP_WSDL_INPUT = 'input';
  ID_SOAP_WSDL_OUTPUT = 'output';
  ID_SOAP_WSDL_ATTRIB_MESSAGE = 'message';
  ID_SOAP_WSDL_BINDING = 'binding';
  ID_SOAP_WSDL_BINDING_ATTRIB_STYLE = 'style';
  ID_SOAP_WSDL_BINDING_VALUE_RPC = 'rpc';
  ID_SOAP_WSDL_BINDING_VALUE_DOCUMENT = 'document';
  ID_SOAP_WSDL_BINDING_ATTRIB_TRANSPORT = 'transport';
  ID_SOAP_WSDL_BINDING_VALUE_TRANSPORT = 'http://schemas.xmlsoap.org/soap/http';
  ID_SOAP_WSDL_OPERATION_ATTRIB_ACTION = 'soapAction';
  ID_SOAP_WSDL_BODY = 'body';
  ID_SOAP_WSDL_ATTRIB_USE = 'use';
  ID_SOAP_WSDL_VALUE_USE_ENCODED = 'encoded';
  ID_SOAP_WSDL_ATTRIB_ENCODING = 'encodingStyle';
  ID_SOAP_WSDL_VALUE_ENCODING = 'http://schemas.xmlsoap.org/soap/encoding/';
  ID_SOAP_WSDL_SERVICE = 'service';
  ID_SOAP_WSDL_IMPORT = 'import';
  ID_SOAP_WSDL_PORT = 'port';
  ID_SOAP_WSDL_GEN_ATTRIB_BINDING = 'binding';
  ID_SOAP_WSDL_ADDRESS = 'address';
  ID_SOAP_WSDL_GEN_ATTRIB_LOCATION = 'location';
  ID_SOAP_SCHEMA_SCHEMALOCATION = 'schemaLocation';
  ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE = 'namespace';
  ID_SOAP_TYPE_ARRAY = 'Array';
  ID_SOAP_TYPE_ARRAYTYPE = 'arrayType';
  ID_SOAP_WSDL_ATTRIB_REF = 'ref';
  ID_SOAP_WSDL_SCHEMA_ITEMTYPE = 'itemType';
  ID_SOAP_WSDL_HEADER = 'header';

function FirstChildElement(AElement : TdomElement):TdomElement;
const ASSERT_LOCATION = 'IdSoapWsdlXml.FirstChildElement';
var
  LNode : TdomNode;
begin
  Assert(IdSoapTestNodeValid(AElement, TdomElement), ASSERT_LOCATION+': Element node not valid');
  result := nil;
  LNode := AElement.firstChild;
  while assigned(LNode) and not assigned(result) do
    begin
    if LNode is TdomElement then
      begin
      result := LNode as TdomElement;
      end;
    LNode := LNode.nextSibling;
    end;
end;

function NextSiblingElement(AElement : TdomElement):TdomElement;
const ASSERT_LOCATION = 'IdSoapWsdlXml.NextSiblingElement';
var
  LNode : TdomNode;
begin
  Assert(IdSoapTestNodeValid(AElement, TdomElement), ASSERT_LOCATION+': Element node not valid');
  result := nil;
  LNode := AElement.NextSibling;
  while assigned(LNode) and not assigned(result) do
    begin
    if LNode is TdomElement then
      begin
      result := LNode as TdomElement;
      end;
    LNode := LNode.nextSibling;
    end;
end;

{ TIdSoapWSDLConvertor }

constructor TIdSoapWSDLConvertor.create(AProvider : TIdSoapITIProvider; AWsdl: TIdSoapWSDL);
begin
  inherited create;
  FProvider := AProvider;
  FWsdl := AWsdl;
end;

procedure TIdSoapWSDLConvertor.WriteDocumentation(ANode:TdomElement; ADoco :String);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadMessages';
var
  LDocoNode : TdomElement;
  LRoot : TdomDocumentFragment;
  LParser : TXmlToDomParser;
begin
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Node is not valid');
  if ADoco <> '' then
    begin
    LDocoNode := ANode.ownerDocument.createElement(ID_SOAP_WSDL_DOCO);
    ANode.appendChild(LDocoNode);


    LRoot := ANode.ownerDocument.CreateDocumentFragment;
    LParser := TXmlToDomParser.Create(nil);
    try
      try
        LParser.DocStringToDom(ADoco,'','',LRoot);
        LDocoNode.appendChild(LRoot);
      except
        on ex: Exception do
          begin
          ANode.ownerDocument.FreeAllNodes(TdomNode(LRoot));
          end;
      end;
    finally
      FreeAndNil(LParser);
    end;
    end;
end;

procedure TIdSoapWSDLConvertor.WriteSchemaAnything(AElement: TdomElement);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.WriteSchemaAnything';
var
  LNode, LTemp: TdomElement;
begin
  AElement.setAttribute('mixed', 'true');
  AElement.appendChild(FDom.createComment('This type can have anything in it at all. Not sure about the attribute declarations...'));
  LNode := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA_2001, DEF_OK)+'complexType');
  AElement.appendChild(LNode);
  LTemp := LNode;
  LNode := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA_2001, DEF_OK)+'sequence');
  LTemp.appendChild(LNode);
  LTemp := LNode;
  LNode := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA_2001, DEF_OK)+'any');
  LTemp.appendChild(LNode);
  LNode.setAttribute('namespace', '##any');
  LNode.setAttribute('maxOccurs', 'unbounded');
  LNode.SetAttribute('processContents', 'skip');
  LNode := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA_2001, DEF_OK)+'anyAttribute');
  LTemp.appendChild(LNode);
  LNode.setAttribute('namespace', '##any');
  LNode.SetAttribute('processContents', 'skip');
end;

procedure TIdSoapWSDLConvertor.WriteAbstractType(ATypeDefn : TIdSoapWsdlAbstractType; ANode : TdomElement);
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteSimpleType';
begin
  Assert(self.TestValid(TIdSoapWSDLConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(ATypeDefn.TestValid(TIdSoapWsdlAbstractType), ASSERT_LOCATION+': TypeDefn is not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Node is not valid');

  if ATypeDefn.Nillable <> nilUnknown then
    begin
    if ATypeDefn.Nillable = nilFalse then
      begin
      ANode.setAttribute(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA_INST_2001, DEF_OK)+ID_SOAP_XSI_ATTR_NILLABLE, BoolToXML(false));
      end
    else
      begin
      ANode.setAttribute(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA_INST_2001, DEF_OK)+ID_SOAP_XSI_ATTR_NILLABLE, BoolToXML(true));
      end;
    end;

end;


function TIdSoapWSDLConvertor.WriteSimpleType(ATypeDefn : TIdSoapWsdlSimpleType; ASchema : TdomElement; ASuppressName : boolean; ANodeName : string = '') : TdomELement;
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteSimpleType';
var
  LElement : TdomElement;
  LHandled : boolean;
begin
  Assert(self.TestValid(TIdSoapWSDLConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(ATypeDefn.TestValid(TIdSoapWsdlSimpleType), ASSERT_LOCATION+': TypeDefn is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(ASchema, TdomElement), ASSERT_LOCATION+': Schema node is not valid');
  Assert(IdSoapTestNodeValid(ASchema, TdomElement), ASSERT_LOCATION+': Schema node is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  if ANodeName = '' then
    begin
    // this is a simple case. The app is using something that maps straight onto a simple type, but has given it
    // a different name (usually for improved self documentation of interfaces)
    LElement := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_SIMPLETYPE);
    if not ASuppressName then
      begin
      LElement.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, ATypeDefn.Name);
      end;
    LElement.setAttribute(ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE, FNamespaces.GetNameSpaceCode(ATypeDefn.Info.NameSpace, NO_DEF)+ATypeDefn.Info.Name);
    end
  else
    begin
    // part of a struct
    LElement := FDom.createElement(ANodeName);
    if not ASuppressName then
      begin
      LElement.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, ATypeDefn.Name);
      end;
    if ATypeDefn.DefaultValue <> '' then
      begin
      LElement.setAttribute(ID_SOAP_WSDL_DEFAULT, ATypeDefn.DefaultValue);
      end;
    if ATypeDefn.Info.NameSpace <> '' then
      begin
      LElement.setAttribute(ID_SOAP_NAME_SCHEMA_TYPE, FNamespaces.GetNameSpaceCode(ATypeDefn.Info.NameSpace, NO_DEF)+ATypeDefn.Info.Name);
      end;
    if ATypeDefn.Path <> '' then
      begin
      LHandled := false;
      if assigned(FProvider) and assigned(FProvider.OnGetSchema) then
        begin
        FProvider.OnGetSchema(FProvider, ATypeDefn.Path, ATypeDefn.Info.NameSpace, ATypeDefn.Info.Name, FNamespaces, LHandled, LElement, FTypes);
        end;
      if not LHandled and (ATypeDefn.Info.NameSpace = '') then
        begin
        WriteSchemaAnything(LElement);
        end;
      end;
    end;
  WriteAbstractType(ATypeDefn, LElement);
  ASchema.appendChild(LElement);
  result := LElement;
end;

procedure TIdSoapWSDLConvertor.WriteElement(ATypeDefn: TIdSoapWsdlElementDefn; ASchema: TdomElement);
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteElement';
var
  LElement : TdomElement;
begin
  Assert(self.TestValid(TIdSoapWSDLConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(ATypeDefn.TestValid(TIdSoapWsdlElementDefn), ASSERT_LOCATION+': TypeDefn is not valid');
  Assert(IdSoapTestNodeValid(ASchema, TdomElement), ASSERT_LOCATION+': Schema node is not valid');
  LElement := FDom.createElement(FNamespaces.GetNamespaceCode(ID_SOAP_NS_SCHEMA_2001, DEF_OK)+ID_SOAP_SCHEMA_ELEMENT);
  LElement.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, ATypeDefn.Name);
  ASchema.appendChild(LElement);
  if Assigned(ATypeDefn.TypeDefn) then
    begin
    if ATypeDefn.TypeDefn is TIdSoapWsdlSimpleType then
      begin
      WriteSimpleType(ATypeDefn.TypeDefn as TIdSoapWsdlSimpleType, LElement, true);
      end
    else if ATypeDefn.TypeDefn is TIdSoapWsdlEnumeratedType then
      begin
      WriteEnumeratedType(ATypeDefn.TypeDefn as TIdSoapWsdlEnumeratedType, LElement, true);
      end
    else if ATypeDefn.TypeDefn is TIdSoapWsdlSetType then
      begin
      WriteSetType(ATypeDefn.TypeDefn as TIdSoapWsdlSetType, LElement, true);
      end
    else if ATypeDefn.TypeDefn is TIdSoapWsdlArrayType then
      begin
      WriteArrayType(ATypeDefn.TypeDefn as TIdSoapWsdlArrayType, LElement, true);
      end
    else if ATypeDefn.TypeDefn is TIdSoapWsdlComplexType then
      begin
      WriteComplexType(ATypeDefn.TypeDefn as TIdSoapWsdlComplexType, LElement, true);
      end
    else
      Assert(false, ASSERT_LOCATION+': unexpected type '+ATypeDefn.TypeDefn.ClassName+' type in Element "'+ATypeDefn.Name+'"');
    end
  else
    begin
    LElement.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_TYPE, FNamespaces.GetNameSpaceCode(ATypeDefn.TypeInfo.Namespace, NO_DEF)+ATypeDefn.TypeInfo.Name);
    end;
end;


procedure TIdSoapWSDLConvertor.WriteEnumeratedType(ATypeDefn : TIdSoapWsdlEnumeratedType; ASchema : TdomElement; ASuppressName : boolean);
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteEnumeratedType';
  function CreateEnumerationNode(AValue : string):TdomElement;
  begin
    result := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_ENUMERATION);
    result.setAttribute(ID_SOAP_WSDL_SCHEMA_ATTRIB_VALUE, AValue);
  end;
var
  LType : TdomElement;
  LRestriction : TdomElement;
  i: Integer;
begin
  Assert(ATypeDefn.TestValid(TIdSoapWsdlEnumeratedType), ASSERT_LOCATION+': TypeDefn is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(ASchema, TdomElement), ASSERT_LOCATION+': Schema node is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  LType := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_SIMPLETYPE);
  WriteAbstractType(ATypeDefn, LType);
  ASchema.appendChild(LType);
  if not ASuppressName then
    begin
    LType.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, ATypeDefn.Name);
    end;
  LType.setAttribute(ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE, FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, NO_DEF)+ID_SOAP_XSI_TYPE_STRING);
  LRestriction := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_RESTRICTION);
  LRestriction.setAttribute(ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE, FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, NO_DEF)+ID_SOAP_XSI_TYPE_STRING);
  LType.appendChild(LRestriction);
  for i := 0 to ATypeDefn.Values.Count - 1  do
    begin
    LRestriction.AppendChild(CreateEnumerationNode(ATypeDefn.Values[i]));
    end;
end;

procedure TIdSoapWSDLConvertor.WriteSetType(ATypeDefn: TIdSoapWsdlSetType; ASchema: TdomElement; ASuppressName : boolean);
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteSetType';
var
  LType : TdomElement;
  LList : TdomElement;
begin
  Assert(ATypeDefn.TestValid(TIdSoapWsdlSetType), ASSERT_LOCATION+': TypeDefn is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');
  Assert(IdSoapTestNodeValid(ASchema, TdomElement), ASSERT_LOCATION+': Schema node is not valid');

//  <s:simpleType name="FindResultMask">
//   <s:list itemType=""/>
//  </s:simpleType>

  LType := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_SIMPLETYPE);
  WriteAbstractType(ATypeDefn, LType);
  ASchema.appendChild(LType);
  if not ASuppressName then
    begin
    LType.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, ATypeDefn.Name);
    end;

  LList := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_LIST);
  LList.setAttribute(ID_SOAP_WSDL_SCHEMA_ITEMTYPE, FNamespaces.GetNameSpaceCode(ATypeDefn.Enum.NameSpace, NO_DEF)+ATypeDefn.Enum.Name);
  LType.appendChild(LList);
end;

procedure TIdSoapWSDLConvertor.WriteArrayType(ATypeDefn : TIdSoapWsdlArrayType; ASchema : TdomElement; ASuppressName : boolean);
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteArrayType';
var
  LTypeNode : TdomElement;
  LContNode : TdomElement;
  LRestNode : TdomElement;
  LAttrNode : TdomElement;
begin
  Assert(ATypeDefn.TestValid(TIdSoapWsdlArrayType), ASSERT_LOCATION+': TypeDefn is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(ASchema, TdomElement), ASSERT_LOCATION+': Schema node is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');
  LTypeNode := FDom.createElement(FNamespaces.GetNamespaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_COMPLEXTYPE);
  if not ASuppressName then
    begin
    LTypeNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, ATypeDefn.Name);
    end;
  WriteAbstractType(ATypeDefn, LTypeNode);
  ASchema.AppendChild(LTypeNode);
  LContNode := FDom.createElement(FNamespaces.GetNamespaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_COMPLEXCONTENT);
  LTypeNode.AppendChild(LContNode);
  LRestNode := FDom.createElement(FNamespaces.GetNamespaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_RESTRICTION);
  LRestNode.setAttribute(ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE, FNamespaces.GetNamespaceCode(ID_SOAP_NS_SOAPENC, NO_DEF)+ID_SOAP_TYPE_ARRAY);
  LContNode.AppendChild(LRestNode);
  LAttrNode := FDom.createElement(FNamespaces.GetNamespaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_ATTRIBUTE);
  LAttrNode.setAttribute(ID_SOAP_WSDL_ATTRIB_REF, FNamespaces.GetNamespaceCode(ID_SOAP_NS_SOAPENC, NO_DEF)+ID_SOAP_TYPE_ARRAYTYPE);
  // this should be:
  //  LAttrNode.setAttribute(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_WSDL, NO_DEF)+ID_SOAP_TYPE_ARRAYTYPE, FNamespaces.GetNameSpaceCode(ATypeDefn.TypeName.NameSpace, NO_DEF)+ATypeDefn.TypeName.Name+'[]');
  // but there is a bug in the borland soap which requires the namespace of the arraytype attribute to be declared locally.
  // YAY BORLAND

  LAttrNode.setAttribute('arr:'+ID_SOAP_TYPE_ARRAYTYPE, FNamespaces.GetNameSpaceCode(ATypeDefn.TypeName.NameSpace, NO_DEF)+ATypeDefn.TypeName.Name+'[]');
  LAttrNode.setAttribute('xmlns:arr', ID_SOAP_NS_WSDL);
  LRestNode.appendChild(LAttrNode);
end;

procedure TIdSoapWSDLConvertor.WriteComplexType(ATypeDefn : TIdSoapWsdlComplexType; ASchema : TdomElement; ASuppressName : boolean);
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteComplexType';
var
  LBase : TdomElement;
  LType : TdomElement;
  LALL : TdomElement;
  i : integer;
  LElement : TdomElement;
begin
  Assert(ATypeDefn.TestValid(TIdSoapWsdlComplexType), ASSERT_LOCATION+': TypeDefn is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(ASchema, TdomElement), ASSERT_LOCATION+': Schema node is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  LType := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_COMPLEXTYPE);
  WriteAbstractType(ATypeDefn, LType);
  ASchema.appendChild(LType);
  if not ASuppressName then
    begin
    LType.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, ATypeDefn.Name);
    end;
  if ATypeDefn.ExtensionBase.Name <> '' then
    begin
    LBase := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_SCHEMA_EXTENSION);
    LBase.setAttribute(ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE, FNamespaces.GetNameSpaceCode(ATypeDefn.ExtensionBase.NameSpace, NO_DEF)+ATypeDefn.ExtensionBase.Name);
    LType.appendChild(LBase);
    end
  else
    begin
    LBase := LType;
    end;
  if ATypeDefn.Elements.count > 0 then
    begin
    LAll := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_SEQUENCE);
    LBase.appendChild(LALL);
    for i := 0 to ATypeDefn.Elements.count - 1 do
      begin
      LElement := nil; // bit superfluous - but the warnings checker misses the Assert(false...)
      if ATypeDefn.Elements.objects[i] is TIdSoapWsdlSimpleType then
        begin
        LElement := WriteSimpleType(ATypeDefn.Elements.objects[i] as TIdSoapWsdlSimpleType, LALL, false, FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_PART_ATTRIB_ELEMENT);
        end
      else if ATypeDefn.Elements.objects[i] is TIdSoapWsdlElementDefn then
        begin
        LElement := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_PART_ATTRIB_ELEMENT);
        LAll.appendChild(LElement);
        LElement.setAttribute(ID_SOAP_SCHEMA_REF, FNamespaces.GetNameSpaceCode((ATypeDefn.Elements.objects[i] as TIdSoapWsdlElementDefn).TypeInfo.Namespace, NO_DEF)+(ATypeDefn.Elements.objects[i] as TIdSoapWsdlElementDefn).TypeInfo.Name);
        end
      else
        Assert(false, ASSERT_LOCATION+': Unexpected type "'+ATypeDefn.Elements.objects[i].ClassName+'" in ComplexType list');
      if (ATypeDefn.Elements.objects[i] as TIdSoapWSDLAbstractType).MinOccurs <> '' then
        begin
        LElement.SetAttribute(ID_SOAP_SCHEMA_MINOCCURS, (ATypeDefn.Elements.objects[i] as TIdSoapWSDLAbstractType).MinOccurs);
        end;
      if (ATypeDefn.Elements.objects[i] as TIdSoapWSDLAbstractType).MaxOccurs <> '' then
        begin
        LElement.SetAttribute(ID_SOAP_SCHEMA_MAXOCCURS, (ATypeDefn.Elements.objects[i] as TIdSoapWSDLAbstractType).MaxOccurs);
        end;
      end;
    end;
end;

procedure TIdSoapWSDLConvertor.ListTypes;
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.ListTypes';
var
  LSchemaSection : TIdSoapWSDLSchemaSection;
  LSchema : TdomElement;
  LImport : TdomElement;
  i, j : integer;
  LTypeDefn : TIdSoapWSDLAbstractType;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  FWsdl.PruneSchemaSections;
  if FWsdl.SchemaSections.count > 0 then
    begin
    FTypes := FDom.createElement(ID_SOAP_WSDL_TYPE_ROOT);
    FDom.documentElement.appendChild(FTypes);
    WriteDocumentation(FTypes, FWsdl.TypesDocumentation);
    for j := 0 to FWsdl.SchemaSections.count - 1 do
      begin
      LSchemaSection := FWsdl.SchemaSections.objects[j] as TIdSoapWSDLSchemaSection;
      LSchema := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_SCHEMA, DEF_OK)+ID_SOAP_WSDL_SCHEMA);
      LSchema.setAttribute(ID_SOAP_WSDL_TARGETNAMESPACE, FWsdl.SchemaSections[j]);
      FTypes.AppendChild(LSchema);
      for i := 0 to LSchemaSection.Imports.count - 1 do
        begin
        LImport := FDom.createElement(ID_SOAP_SCHEMA_IMPORT);
        LImport.setAttribute(ID_SOAP_SCHEMA_NAMESPACE, LSchemaSection.Imports[i]);
        LSchema.appendChild(LImport);
        end;
      for i := 0 to LSchemaSection.Elements.count - 1 do
        begin
        LTypeDefn := LSchemaSection.Elements.objects[i] as TIdSoapWSDLAbstractType;
        if LTypeDefn is TIdSoapWsdlElementDefn then
          begin
          WriteElement(LTypeDefn as TIdSoapWsdlElementDefn, LSchema)
          end
        else
          Assert(false, ASSERT_LOCATION+': unrecognised type '+LTypeDefn.ClassName+' in TypeDefn list for "'+FWsdl.SchemaSections[j]+'"');
        end;
      for i := 0 to LSchemaSection.Types.count - 1 do
        begin
        LTypeDefn := LSchemaSection.Types.objects[i] as TIdSoapWSDLAbstractType;
        if LTypeDefn is TIdSoapWsdlSimpleType then
          begin
          WriteSimpleType(LTypeDefn as TIdSoapWsdlSimpleType, LSchema, false);
          end
        else if LTypeDefn is TIdSoapWsdlEnumeratedType then
          begin
          WriteEnumeratedType(LTypeDefn as TIdSoapWsdlEnumeratedType, LSchema, false);
          end
        else if LTypeDefn is TIdSoapWsdlSetType then
          begin
          WriteSetType(LTypeDefn as TIdSoapWsdlSetType, LSchema, false);
          end
        else if LTypeDefn is TIdSoapWsdlArrayType then
          begin
          WriteArrayType(LTypeDefn as TIdSoapWsdlArrayType, LSchema, false);
          end
        else if LTypeDefn is TIdSoapWsdlComplexType then
          begin
          WriteComplexType(LTypeDefn as TIdSoapWsdlComplexType, LSchema, false);
          end
        else
          Assert(false, ASSERT_LOCATION+': unrecognised type '+LTypeDefn.ClassName+' in TypeDefn list for "'+FWsdl.SchemaSections[j]+'"');
        end;
      end;
    end;
end;

procedure TIdSoapWSDLConvertor.ListMessages;
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.ListMessages';
var
  LMsgNode : TdomElement;
  LMessage : TIdSoapWSDLMessage;
  i, j : integer;
  LMsgPart : TIdSoapWSDLMessagePart;
  LPartNode : TdomElement;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  for i := 0 to FWsdl.Messages.count - 1 do
    begin
    LMessage := FWsdl.Messages.objects[i] as TIdSoapWSDLMessage;
    LMsgNode := FDom.createElement(ID_SOAP_WSDL_MESSAGE);
    LMsgNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LMessage.Name);
    WriteDocumentation(LMsgNode, LMessage.Documentation);
    FDom.documentElement.appendChild(LMsgNode);
    for j := 0 to LMessage.Parts.count - 1 do
      begin
      LMsgPart := LMessage.Parts.Objects[j] as TIdSoapWSDLMessagePart;
      LPartNode := FDom.createElement(ID_SOAP_WSDL_PART);
      LMsgNode.appendChild(LPartNode);
      LPartNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LMsgPart.Name);
      if LMsgPart.PartType.Name <> '' then
        begin
        LPartNode.setAttribute(ID_SOAP_WSDL_ELEMENT_ATTRIB_TYPE, FNamespaces.GetNameSpaceCode(LMsgPart.PartType.NameSpace, NO_DEF)+LMsgPart.PartType.Name);
        end
      else
        begin
        LPartNode.setAttribute(ID_SOAP_SCHEMA_ELEMENT, FNamespaces.GetNameSpaceCode(LMsgPart.Element.NameSpace, NO_DEF)+LMsgPart.Element.Name);
        end;
      end;
    end;
end;

procedure TIdSoapWSDLConvertor.ListOperations;
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.ListOperations';
var
  LPTNode : TdomElement;
  LPortType : TIdSoapWSDLPortType;
  LOp : TIdSoapWSDLPortTypeOperation;
  LOpNode : TdomElement;
  LInNode : TdomElement;
  LOutNode : TdomElement;
  i, j : integer;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  for i := 0 to FWsdl.PortTypes.Count - 1 do
    begin
    LPortType := FWsdl.PortTypes.Objects[i] as TIdSoapWSDLPortType;
    LPTNode := FDom.createElement(ID_SOAP_WSDL_PORTTYPE);
    FDom.documentElement.appendChild(LPTNode);
    LPTNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LPortType.Name);
    WriteDocumentation(LPTNode, LPortType.Documentation);
    for j := 0 to LPortType.Operations.count - 1 do
      begin
      LOp := LPortType.Operations.Objects[j] as TIdSoapWSDLPortTypeOperation;
      LOpNode := FDom.createElement(ID_SOAP_WSDL_OPERATION);
      LPTNode.appendChild(LOpNode);
      LOpNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LOp.Name);
      WriteDocumentation(LOpNode, LOp.Documentation);
      LInNode := FDom.createElement(ID_SOAP_WSDL_INPUT);
      LOpNode.appendChild(LInNode);
      LInNode.setAttribute(ID_SOAP_WSDL_ATTRIB_MESSAGE, FNamespaces.GetNameSpaceCode(LOp.Input.Message.NameSpace, NO_DEF)+LOp.Input.Message.Name);
      if LOp.Input.Name <> '' then
        begin
        LInNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LOp.Input.Name);
        end;
      WriteDocumentation(LInNode, LOp.Input.Documentation);
      LOutNode := FDom.createElement(ID_SOAP_WSDL_OUTPUT);
      LOpNode.appendChild(LOutNode);
      LOutNode.setAttribute(ID_SOAP_WSDL_ATTRIB_MESSAGE, FNamespaces.GetNameSpaceCode(LOp.Output.Message.NameSpace, NO_DEF)+LOp.Output.Message.Name);
      if LOp.Output.Name <> '' then
        begin
        LOutNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LOp.Output.Name);
        end;
      WriteDocumentation(LOutNode, LOp.Output.Documentation);
      end;
    end;
end;

procedure TIdSoapWSDLConvertor.WriteHeaders(AElem : TdomElement; AMsg : TIdSoapWSDLBindingOperationMessage);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadHeaders';
var
  LNode : TdomElement;
  LHeader : TIdSoapWSDLBindingOperationMessageHeader;
  i : integer;
begin
  Assert(self.TestValid(TIdSoapWSDLConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(IdSoapTestNodeValid(AElem, TdomElement), ASSERT_LOCATION+': Elem Node not found');
  Assert(AMsg.TestValid(TIdSoapWSDLBindingOperationMessage), ASSERT_LOCATION+': Wsdl is not valid');

  for i := 0 to AMsg.Headers.count - 1 do
    begin
    LHeader := AMsg.Headers.Objects[i] as TIdSoapWSDLBindingOperationMessageHeader;
    LNode := TdomElement.create(FDom, FNamespaces.GetNameSpaceCode(ID_SOAP_NS_WSDL_SOAP, NO_DEF)+ID_SOAP_WSDL_HEADER);
    AElem.appendChild(LNode);
    LNode.setAttribute(ID_SOAP_WSDL_PART, LHeader.Name);
    LNode.setAttribute(ID_SOAP_WSDL_MESSAGE, FNamespaces.GetNameSpaceCode(LHeader.Message.NameSpace, NO_DEF)+LHeader.Message.Name);
    if LHeader.SoapNamespace <> '' then
      begin
      LNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE, LHeader.SoapNamespace);
      end;
    if LHeader.SoapEncodingStyle <> '' then
      begin
      LNode.setAttribute(ID_SOAP_WSDL_ATTRIB_ENCODING, LHeader.SoapEncodingStyle);
      end;
    LNode.setAttribute(ID_SOAP_WSDL_ATTRIB_USE, WsdlSoapEncodingStyleToStr(LHeader.SoapUse));
    end;
end;

procedure TIdSoapWSDLConvertor.DeclareBinding;
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.DeclareBinding';
var
  LBinding : TIdSoapWSDLBinding;
  LBindNode : TdomElement;
  LSoapBinding : TdomElement;
  LOperation : TIdSoapWSDLBindingOperation;
  LOpNode : TdomElement;
  LSoapOperation : TdomElement;
  LMessage : TdomElement;
  LSoapMessage : TdomElement;
  i, j : integer;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  for i := 0 to FWsdl.Bindings.count - 1 do
    begin
    LBinding := FWsdl.Bindings.Objects[i] as TIdSoapWSDLBinding;
    LBindNode := FDom.createElement(ID_SOAP_WSDL_BINDING);
    FDom.documentElement.appendChild(LBindNode);
    LBindNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LBinding.Name);
    LBindNode.SetAttribute(ID_SOAP_WSDL_GEN_ATTRIB_TYPE, FNamespaces.GetNameSpaceCode(LBinding.PortType.NameSpace, NO_DEF)+LBinding.PortType.Name);
    WriteDocumentation(LBindNode, LBinding.Documentation);
    LSoapBinding := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_WSDL_SOAP, NO_DEF)+ID_SOAP_WSDL_BINDING);
    LBindNode.appendChild(LSoapBinding);
    if LBinding.SoapStyle <> sbsUnknown then
      begin
      LSoapBinding.setAttribute(ID_SOAP_WSDL_BINDING_ATTRIB_STYLE, WsdlSoapBindingStyleToStr(LBinding.SoapStyle));
      end;
    LSoapBinding.setAttribute(ID_SOAP_WSDL_BINDING_ATTRIB_TRANSPORT, LBinding.SoapTransport);
    for j := 0 to LBinding.Operations.Count - 1  do
      begin
      LOperation := LBinding.Operations.objects[j] as TIdSoapWSDLBindingOperation;
      LOpNode := FDom.createElement(ID_SOAP_WSDL_OPERATION);
      if LOperation.Name <> '' then
        begin
        LOpNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LOperation.Name);
        end;
      LBindNode.appendChild(LOpNode);
      WriteDocumentation(LOpNode, LOperation.Documentation);
      LSoapOperation := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_WSDL_SOAP, DEF_OK)+ID_SOAP_WSDL_OPERATION);
      LOpNode.appendChild(LSoapOperation);
      LSoapOperation.setAttribute(ID_SOAP_WSDL_OPERATION_ATTRIB_ACTION, LOperation.SoapAction);
      if (LOperation.SoapStyle <> sbsUnknown) then
        begin
        LSoapOperation.setAttribute(ID_SOAP_WSDL_BINDING_ATTRIB_STYLE, WsdlSoapBindingStyleToStr(LOperation.SoapStyle));
        end;

      LMessage := FDom.createElement(ID_SOAP_WSDL_INPUT);
      LOpNode.appendChild(LMessage);
      if LOperation.Input.Name <> '' then
        begin
        LMessage.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LOperation.Input.Name);
        end;
      LSoapMessage := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_WSDL_SOAP, DEF_OK)+ID_SOAP_WSDL_BODY);
      LMessage.appendChild(LSoapMessage);
      LSoapMessage.setAttribute(ID_SOAP_WSDL_ATTRIB_USE, WsdlSoapEncodingStyleToStr(LOperation.Input.SoapUse));
      if LOperation.Input.SoapEncodingStyle <> '' then
        begin
        LSoapMessage.setAttribute(ID_SOAP_WSDL_ATTRIB_ENCODING, LOperation.Input.SoapEncodingStyle);
        end;
      if LOperation.Input.SoapNamespace <> '' then
        begin
        LSoapMessage.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE, LOperation.Input.SoapNamespace);
        end;
      WriteHeaders(LMessage, LOperation.Input);
      WriteDocumentation(LSoapMessage, LOperation.Input.Documentation);

      LMessage := FDom.createElement(ID_SOAP_WSDL_OUTPUT);
      LOpNode.appendChild(LMessage);
      if LOperation.Output.Name <> '' then
        begin
        LMessage.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LOperation.Output.Name);
        end;
      LSoapMessage := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_WSDL_SOAP, DEF_OK)+ID_SOAP_WSDL_BODY);
      LMessage.appendChild(LSoapMessage);
      LSoapMessage.setAttribute(ID_SOAP_WSDL_ATTRIB_USE, WsdlSoapEncodingStyleToStr(LOperation.Output.SoapUse));
      if LOperation.Output.SoapEncodingStyle <> '' then
        begin
        LSoapMessage.setAttribute(ID_SOAP_WSDL_ATTRIB_ENCODING, LOperation.Output.SoapEncodingStyle);
        end;
      if LOperation.Output.SoapNamespace <> '' then
        begin
        LSoapMessage.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE, LOperation.Output.SoapNamespace);
        end;
      WriteHeaders(LMessage, LOperation.Output);
      WriteDocumentation(LSoapMessage, LOperation.Output.Documentation);
      end;
    end;
end;

procedure TIdSoapWSDLConvertor.DefineService;
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.DefineService';
var
  LService : TIdSoapWSDLService;
  LPort : TIdSoapWSDLServicePort;
  LSvcNode : TdomElement;
  LPortNode : TdomElement;
  LSoapNode : TdomElement;
  i, j : integer;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  // No check on ALocation
  Assert(FNamespaces.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Namespaces is not valid');
  Assert(IdSoapTestNodeValid(FDom, TdomDocument), ASSERT_LOCATION+': Document is not valid');

  for i := 0 to FWsdl.Services.count - 1 do
    begin
    LService := FWsdl.Services.objects[i] as TIdSoapWSDLService;
    LSvcNode := FDom.createElement(ID_SOAP_WSDL_SERVICE);
    FDom.documentElement.appendChild(LSvcNode);
    LSvcNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LService.Name);
    WriteDocumentation(LSvcNode, LService.Documentation);
    for j := 0 to LService.Ports.count -1 do
      begin
      LPort := LService.Ports.Objects[j] as TIdSoapWSDLServicePort;
      LPortNode := FDom.createElement(ID_SOAP_WSDL_PORT);
      LSvcNode.appendChild(LPortNode);
      LPortNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, LPort.Name);
      LPortNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_BINDING, FNamespaces.GetNameSpaceCode(LPort.BindingName.NameSpace, NO_DEF)+LPort.BindingName.Name);
      WriteDocumentation(LPortNode, LPort.Documentation);
      LSoapNode := FDom.createElement(FNamespaces.GetNameSpaceCode(ID_SOAP_NS_WSDL_SOAP, DEF_OK)+ID_SOAP_WSDL_ADDRESS);
      LPortNode.appendChild(LSoapNode);
      LSoapNode.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_LOCATION, LPort.SoapAddress)
      end;
    end;
end;

procedure TIdSoapWSDLConvertor.WriteToXMl(AStream : TStream);
Const ASSERT_LOCATION = 'IdSoapWsdlIti.TIdSoapWSDLConvertor.WriteWSDLToXMl';
var
  LDomImpl: TDomImplementation;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': WSDL is not valid');
  // No check on ALocation
  Assert(assigned(AStream), 'IdSoapWSDL.ListInterfaces: Stream is not valid');
  LDomImpl := TDomImplementation.Create(NIL);
  try
    FDom := LDomImpl.createDocument(ID_SOAP_WSDL_ROOT, NIL);
    try
      FNamespaces := TIdSoapXmlNamespaceSupport.create;
      try
        FNamespaces.DefineNamespace(ID_SOAP_NS_SCHEMA, ID_SOAP_NS_SCHEMA_CODE);
        FNamespaces.DefineNamespace(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_NS_WSDL_SOAP_CODE);
        FDom.documentElement.setAttribute(ID_SOAP_WSDL_GEN_ATTRIB_NAME, FWsdl.Name);
        FDom.documentElement.setAttribute(ID_SOAP_NAME_XML_XMLNS, ID_SOAP_NS_WSDL);
        if FWsdl.Namespace <> '' then
          begin
          FDom.documentElement.setAttribute(ID_SOAP_WSDL_TARGETNAMESPACE, FWsdl.Namespace);
          FNamespaces.DefineNamespace(FWsdl.Namespace, 'tns');
          end;

        WriteDocumentation(FDom.documentElement, FWsdl.Documentation);
        ListTypes;
        ListMessages;
        ListOperations;
        DeclareBinding;
        DefineService;
        FNamespaces.AddNamespaceDefinitions(FDom.documentElement);
      finally
        FreeAndNil(FNamespaces);
      end;
      FDom.writeCodeAsUTF8(AStream);
    finally
      LDomImpl.freeDocument(FDom);
    end;
  finally
    FreeAndNil(LDomImpl);
  end;
end;

procedure TIdSoapWSDLConvertor.ReadAbstractTypeDetails(ANode: TdomElement; AType: TIdSoapWSDLAbstractType);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadWSDLFromXml';
var
  s : string;
begin
  Assert(self.TestValid(TIdSoapWSDLConvertor), ASSERT_LOCATION+': Self is not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Element Node not valid');
  Assert(AType.TestValid(TIdSoapWSDLAbstractType), ASSERT_LOCATION+': Type is not valid');
  s := ANode.getAttributeNS(ID_SOAP_NS_SCHEMA_INST_2001, ID_SOAP_XSI_ATTR_NILLABLE);
  if s = '' then
    begin
    AType.Nillable := nilUnknown;
    end
  else
    begin
    if XMLToBool(s) then
      begin
      AType.Nillable := nilTrue;
      end
    else
      begin
      AType.Nillable := nilFalse;
      end;
    end;
end;

function TIdSoapWSDLConvertor.ReadSimpleType(ANamespace, AName : string; ANode : TdomElement):TIdSoapWSDLAbstractType;
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadSimpleType';
var
  LNode : TdomElement;
  LTypeDefn : TIdSoapWsdlSimpleType;
  LType : string;
  LTypeNS : string;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is ""');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Element Node not valid');
{
 <xsd:simpletype name="longint" base="xsd:int" default="">
}
  LType := ANode.GetAttributeNS('', ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE);
  if LType = '' then
    begin
    LNode := ANode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA_2001, ID_SOAP_WSDL_RESTRICTION);
    Assert(Assigned(LNode), ASSERT_LOCATION+': SimpleType "'+AName+'" has no simple type and no restriction node. Type could not be determined');
    LType := LNode.GetAttributeNS('', ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE);
    Assert(LType <> '', ASSERT_LOCATION+': SimpleType "'+AName+'" restriction has no base. Type could not be determined');
    end;
  SplitString(LType, ':', LTypeNS, LType);
  LTypeNS := ResolveXMLNamespaceCode(ANode, LTypeNS, 'Element '+ANode.NodeName);
  Assert(LTypeNS <> '', ASSERT_LOCATION+': No Namespace defined for Type "'+AName+'"');
  LTypeDefn := TIdSoapWsdlSimpleType.create(FWsdl, AName);
  LTypeDefn.Info.NameSpace := LTypeNS;
  LTypeDefn.Info.Name := LType;
  LTypeDefn.DefaultValue := ANode.getAttributeNS('', ID_SOAP_WSDL_DEFAULT);
  result := LTypeDefn;
  ReadAbstractTypeDetails(ANode, Result);
end;

function TIdSoapWSDLConvertor.ReadStruct(ANamespace, AName : string; ANode : TdomElement):TIdSoapWSDLAbstractType;
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadStruct';
var
  LNode : TdomElement;
  LTypeDefn : TIdSoapWsdlComplexType;
  LPropName : string;
  LPropType : string;
  LPropTypeNS : string;
  LPropDefn : TIdSoapWsdlSimpleType;
  LPropTypeDefn : TIdSoapWSDLAbstractType;
  LRefDefn : TIdSoapWsdlElementDefn;
  LRef : String;
  LRefNS : String;
  LType : string;
  LTypeNS : string;
  LSubNode : TdomElement;
  LSubNode2 : TdomElement;
  LInLine : boolean;
  LStack : TObjectList;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is ""');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Element Node not valid for Type "'+AName+'"');
  LInLine := false;

  LTypeDefn := TIdSoapWsdlComplexType.create(FWsdl, AName);
  result := LTypeDefn;
  LNode := FirstChildElement(ANode);
  if assigned(LNode) then // won't be assigned if doc|lit operation it represents takes no parameters
    begin
    Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Type "'+AName+'" is a ComplexType but no sub node was found');
    Assert(LNode.namespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': Type "'+AName+'" is a ComplexType but first child is not from schema namespace');
    Assert((LNode.localName = ID_SOAP_WSDL_ALL) or (LNode.localName = ID_SOAP_WSDL_SEQUENCE) or (LNode.localName = ID_SOAP_SCHEMA_EXTENSION), ASSERT_LOCATION+': Type "'+AName+'" is a ComplexType but first child is not "all" or "sequence" (Required - is "'+LNode.localName+'")');
    if LNode.localName = ID_SOAP_SCHEMA_EXTENSION then
      begin
      LType := LNode.getAttributeNS('', ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE);
      Assert(Pos(':', LType) > 0, ASSERT_LOCATION+': Element extension Base "'+LType+'" does not have a namespace. Please refer this to indy-soap-public@yahoogroups.com for analysis');
      SplitString(LType, ':', LTypeNS, LType);
      LTypeNS := ResolveXMLNamespaceCode(LNode as TdomElement, LTypeNS, 'Base Element on complex type '+AName);
      LNode := FirstChildElement(LNode);
      if assigned(LNode) then
        begin
        Assert((LNode.localName = ID_SOAP_WSDL_ALL) or (LNode.localName = ID_SOAP_WSDL_CHOICE) or (LNode.localName = ID_SOAP_WSDL_SEQUENCE), ASSERT_LOCATION+': Type "'+AName+'" is a ComplexType but first child is not "all" or "sequence" (Required - is "'+LNode.localName+'")');
        end;
      end;
    LTypeDefn.ExtensionBase.NameSpace := LTypeNS;
    LTypeDefn.ExtensionBase.Name := LType;
    if assigned(LNode) then
      begin
      LNode := FirstChildElement(LNode);
      LStack := TObjectList.create(false);
      try
        while Assigned(LNode) do
          begin
          if LNode is TdomElement then
            begin
            Assert(LNode.NamespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': Complex Type "'+AName+'" contains an unknown element '+LNode.NodeName);
            if (LNode.localName = ID_SOAP_WSDL_ALL) or (LNode.localName = ID_SOAP_WSDL_CHOICE) or (LNode.localName = ID_SOAP_WSDL_SEQUENCE) then
              begin
              LStack.Insert(0, LNode);
              LNode := FirstChildElement(LNode);
              Assert(assigned(LNode), ASSERT_LOCATION+': Empty structural element in complex type "'+AName+'"');
              Assert(LNode.NamespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': Complex Type "'+AName+'" contains an unknown element '+LNode.NodeName);
              end;
            Assert((LNode.LocalName = ID_SOAP_WSDL_ELEMENT) or (LNode.LocalName = ID_SOAP_WSDL_ANY), ASSERT_LOCATION+': Complex Type "'+AName+'" contains an unknown element '+LNode.NodeName);
            if LNode.LocalName = ID_SOAP_WSDL_ANY then
              begin
              LPropDefn := TIdSoapWsdlSimpleType.create(FWsdl, LPropName);
              LTypeDefn.Elements.AddObject(LPropName, LPropDefn);
              LPropDefn.Info.Name := ID_SOAP_WSDL_OPEN;
              LPropDefn.Info.NameSpace := LNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE);
              LPropDefn.MinOccurs := LNode.getAttributeNS('', ID_SOAP_SCHEMA_MINOCCURS);
              LPropDefn.MaxOccurs := LNode.getAttributeNS('', ID_SOAP_SCHEMA_MAXOCCURS);
              LPropDefn.DefaultValue := LNode.getAttributeNS('', ID_SOAP_WSDL_DEFAULT);
              end
            else IF (LNode as TdomElement).hasAttributeNS('', ID_SOAP_SCHEMA_REF) then
              begin
              LRef := (LNode as TdomElement).GetAttributeNS('', ID_SOAP_SCHEMA_REF);
              Assert(Pos(':', LRef) > 0, ASSERT_LOCATION+': Element reference "'+LRef+'" does not have a namespace. Please refer this to indy-soap-public@yahoogroups.com for analysis');
              SplitString(LRef, ':', LRefNS, LRef);
              LRefNS := ResolveXMLNamespaceCode(LNode as TdomElement, LRefNS, 'Element on complex type '+AName);
              LRefDefn := TIdSoapWsdlElementDefn.create(FWsdl, LRef, ANamespace);
              LRefDefn.TypeInfo.Namespace := LRefNS;
              LRefDefn.TypeInfo.Name := LRef;
              LRefDefn.IsReference := true;
              LTypeDefn.Elements.AddObject(LRef, LRefDefn); // LRef here is effectively irrelevent?
              LRefDefn.MinOccurs := LNode.getAttributeNS('', ID_SOAP_SCHEMA_MINOCCURS);
              LRefDefn.MaxOccurs := LNode.getAttributeNS('', ID_SOAP_SCHEMA_MAXOCCURS);
              end
            else
              begin
              LPropName := (LNode as TdomElement).getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
              Assert(LPropName <> '', ASSERT_LOCATION+': Complex Type "'+AName+'" contains a element with no assigned name');
              LPropType := (LNode as TdomElement).getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_TYPE);
              if LPropType <> '' then
                begin
                LInLine := false;
                if Pos(':', LPropType) > 0 then
                  begin
                  SplitString(LPropType, ':', LPropTypeNS, LPropType);
                  LPropTypeNS := ResolveXMLNamespaceCode(LNode as TdomElement, LPropTypeNS, 'Element '+LNode.nodeName);
                  end
                else
                  begin
                  LPropTypeNS := ID_SOAP_NS_SCHEMA_2001;
                  end;
                end
              else
                begin
                // a type wasn't provided. We allow simple types to be declared in-line
                LSubnode := LNode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA_2001, ID_SOAP_WSDL_SIMPLETYPE);
                LPropType := LPropName + 'Type';
                if assigned(LSubNode) then
                  begin
                  LInLine := true;
                  LPropTypeNS := ANamespace;
                  if (LSubnode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_LIST) <> nil)  then
                    begin
                    LPropType := LPropName;
                    LPropTypeDefn := ReadEnumSet(LPropTypeNS, LPropType, LSubnode);
                    end
                  else if (LSubnode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION) <> nil) then
                    begin
                    LPropType := LPropName + 'Enum';
                    LPropTypeDefn := ReadEnumeration(LPropTypeNS, LPropType, LSubnode);
                    end
                  else
                    begin
                    LPropTypeDefn := ReadSimpleType(LPropTypeNS, LPropType, LSubnode);
                    end;
                  end
                else
                  begin
                  LSubnode := LNode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA_2001, ID_SOAP_WSDL_COMPLEXTYPE);
                  if LSubNode = nil then
                    begin
                    LPropTypeDefn := TIdSoapWsdlSimpleType.create(FWsdl, AName);
                    (LPropTypeDefn as TIdSoapWsdlSimpleType).Info.NameSpace := '##any';
                    (LPropTypeDefn as TIdSoapWsdlSimpleType).Info.Name := '##any';
                    LPropType := '##any';
                    end
                  else
                    begin
                    Assert(Assigned(LSubNode), ASSERT_LOCATION+': Complex Type "'+AName+'" Element "'+LPropName+'" has no type attribute and no type node. Types such as these are not supported');
                    LInLine := true;

                    // if the first child is complexContent, then we think it's an array
                    LSubnode2 := FirstChildElement(LSubnode);
                    if (Assigned(LSubnode2)) and (LSubnode2.localName = ID_SOAP_WSDL_COMPLEXCONTENT) then
                      begin
                      LPropTypeDefn := ReadArrayType(LPropTypeNS, LPropType, LSubnode);
                      end
                    // if the first child is SimpleContent, then we think it's actually a simple type declaration
                    else if (Assigned(LSubnode2)) and (LSubnode2.localName = ID_SOAP_WSDL_SIMPLECONTENT) then
                      begin
                      if (LSubnode2.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION) <> nil) and
                         (LSubnode2.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION).getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_ENUMERATION) <> nil) then
                        begin
                        LPropType := LPropName + 'Enum';
                        LPropTypeDefn := ReadEnumeration(LPropTypeNS, LPropType, LSubnode2);
                        end
                      else
                        begin
                        LPropTypeDefn := ReadSimpleType(LPropTypeNS, LPropType, LSubnode2);
                        end;
                      end
                    else
                      begin
                      LPropTypeDefn := ReadStruct(LPropTypeNS, LPropType, LSubnode);
                      end;
                    end;
                  end;
                FWsdl.AddTypeDefinition(LPropTypeNS, LPropType, LPropTypeDefn);
                end;
              Assert(LPropTypeNS <> '', ASSERT_LOCATION+': Complex Type "'+AName+'" Element "'+LPropName+'" type "'+LPropType+'" has no namespace');
              LPropDefn := TIdSoapWsdlSimpleType.create(FWsdl, LPropName);
              LTypeDefn.Elements.AddObject(LPropName, LPropDefn);
              LPropDefn.Info.Name := LPropType;
              LPropDefn.Info.NameSpace := LPropTypeNS;
              LPropDefn.DefinedInLine := LInLine;
              LPropDefn.MinOccurs := LNode.getAttributeNS('', ID_SOAP_SCHEMA_MINOCCURS);
              LPropDefn.MaxOccurs := LNode.getAttributeNS('', ID_SOAP_SCHEMA_MAXOCCURS);
              LPropDefn.DefaultValue := LNode.getAttributeNS('', ID_SOAP_WSDL_DEFAULT);
              end;
            end;
          LNode := NextSiblingElement(LNode);
          if not assigned(LNode) and (LStack.Count > 0) then
            begin
            LNode := LStack.items[0] as TdomElement;
            LStack.Delete(0);
            LNode := NextSiblingElement(LNode);
            end;
          end;
      finally
        FreeAndNil(LStack);
      end;
      end;
    end;
  ReadAbstractTypeDetails(ANode, Result);
end;

function TIdSoapWSDLConvertor.ReadEnumSet(ANamespace, AName: string; ANode: TdomElement):TIdSoapWSDLAbstractType;
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadEnumSet';
var
  LEnumType : TQName;
  LType, LTypeNS : String;
  LNode : TdomElement;
  LEnum : TIdSoapWsdlEnumeratedType;
begin
  Assert(ANamespace <> '', ASSERT_LOCATION+': namespace is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': name is not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': node is not valid');

  LNode := ANode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_LIST);
  Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Type "'+AName+'" has no list Node');
  if LNode.hasAttributeNS('', ID_SOAP_WSDL_SCHEMA_ITEMTYPE) then
    begin
    LType := LNode.getAttributeNS('', ID_SOAP_WSDL_SCHEMA_ITEMTYPE);
    SplitNamespace(LType, LTypeNS, LType);
    LEnumType := TQName.create;
    LEnumType.NameSpace := ResolveXMLNamespaceCode(LNode, LTypeNS, 'Set {'+ANamespace+'}'+AName);
    LEnumType.Name := LType;
    result := TIdSoapWsdlSetType.create(FWsdl, AName, LEnumType);
    // todo: we don't get to check that there is <= 32 items in this enumeration
    end
  else
    begin
    LNode := LNode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_SIMPLETYPE);
    Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Type "'+AName+'" has no simpleType Node');
    LEnumType := TQName.create;
    LEnumType.NameSpace := ANamespace;
    LEnumType.Name := AName+'Enum';
    result := TIdSoapWsdlSetType.create(FWsdl, AName, LEnumType);
    LEnum := ReadEnumeration(ANamespace, AName, LNode) as TIdSoapWsdlEnumeratedType;
    FWsdl.AddTypeDefinition(LEnumType.NameSpace, LEnumType.Name, LEnum);
    Assert(LEnum.Values.count <= 32, ASSERT_LOCATION+': Type "'+AName+'" is a set from an Enumeration of more than 32 items, IndySoap does not yet handle this situation');
    end;
end;

function TIdSoapWSDLConvertor.ReadEnumeration(ANamespace, AName : string; ANode : TdomElement):TIdSoapWSDLAbstractType;
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadEnumeration';
var
  LNode : TdomElement;
  LTypeDefn : TIdSoapWsdlEnumeratedType;
  LValue : string;
  LTempNS : string;
  LTemp : string;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(AName <> '', ASSERT_LOCATION+': Name is ""');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Element Node not valid for Type "'+AName+'"');

{
<xsd:simpleType name="USState">  <-- ANode
  <xsd:restriction base="xsd:string">
    <xsd:enumeration value="AK"/>
    <xsd:enumeration value="AL"/>
    <xsd:enumeration value="AR"/>
    <!-- and so on ... -->
  </xsd:restriction>
</xsd:simpleType>
}
  LNode := ANode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION);

  Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Type "'+AName+'" has no Restriction Node');
  LTemp := (LNode as TdomElement).GetAttributeNS('', ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE);
  Assert(Pos(':', LTemp) > 0, ASSERT_LOCATION+': Type "'+AName+'" is being interpreted as an enumeration but the base type is wrong (no namespace)');
  SplitString(LTemp, ':', LTempNS, LTemp);
  Assert(ResolveXMLNamespaceCode(ANode, LtempNS, 'Element '+ANode.NodeName) = ID_SOAP_NS_SCHEMA,
                                      ASSERT_LOCATION+': Type "'+AName+'" is being interpreted as an enumeration but the base type is wrong (namespace is "'+
                                      ResolveXMLNamespaceCode(ANode, LtempNS, 'Element '+ANode.NodeName)+'", should be "'+
                                      ID_SOAP_NS_SCHEMA+'")');
  Assert(LTemp = ID_SOAP_XSI_TYPE_STRING, ASSERT_LOCATION+': Type "'+AName+'" is being interpreted as an enumeration but the base type is wrong (is "'+
                                      LTemp+'", should be "'+ID_SOAP_XSI_TYPE_STRING+'")');
  Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Type "'+AName+'" is a ComplexType but no "All" node was found (required; Choice types are not yet(?) supported)');
  LTemp := (LNode as TdomElement).GetAttributeNS('', ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE);
  Assert(Pos(':', LTemp) > 0, ASSERT_LOCATION+': Type "'+AName+'" is being interpreted as an enumeration but the restriction type is wrong (no namespace)');
  SplitString(LTemp, ':', LTempNS, LTemp);
  Assert(ResolveXMLNamespaceCode(ANode, LtempNS, 'Element '+ANode.NodeName) = ID_SOAP_NS_SCHEMA,
                                      ASSERT_LOCATION+': Type "'+AName+'" is being interpreted as an enumeration but the restriction type is wrong (namespace is "'+
                                      ResolveXMLNamespaceCode(ANode, LtempNS, 'Element '+ANode.NodeName)+'", should be "'+
                                      ID_SOAP_NS_SCHEMA+'")');
  Assert(LTemp = ID_SOAP_XSI_TYPE_STRING, ASSERT_LOCATION+': Type "'+AName+'" is being interpreted as an enumeration but the restriction type is wrong (is "'+
                                      LTemp+'", should be "'+ID_SOAP_XSI_TYPE_STRING+'")');

  LTypeDefn := TIdSoapWsdlEnumeratedType.create(FWsdl, AName);
  result := LTypeDefn;
  ReadAbstractTypeDetails(ANode, Result);

  LNode := LNode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_ENUMERATION);
  while assigned(LNode) do
    begin
    Assert(IdSoapTestNodeValid(LNode, TdomNode), ASSERT_LOCATION+': Node not valid iterating enumeration "'+AName+'"');
    LValue := (LNode as TdomElement).getAttributeNS('', ID_SOAP_WSDL_SCHEMA_ATTRIB_VALUE);
    Assert(LValue <> '', ASSERT_LOCATION+': Enumerated type "'+AName+'" contains a blank value');
    LTypeDefn.Values.Add(LValue);
    LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_ENUMERATION);
    end;
end;

function TIdSoapWSDLConvertor.ReadArrayType(ANamespace, AName : string; ANode : TdomElement) : TIdSoapWSDLAbstractType;
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadArrayType';
var
  LContNode : TdomElement;
  LRestNode : TdomElement;
  LAttrNode : TdomElement;
  s, ns, junk : string;
  LArrayDefn : TIdSoapWsdlArrayType;
begin
{
<xsd:complexType name="ResultElementArray">
 <xsd:complexContent>
  <xsd:restriction base="soapenc:Array">
   <xsd:attribute ref="soapenc:arrayType" wsdl:arrayType="typens:ResultElement[]" />
  </xsd:restriction>
 </xsd:complexContent>
</xsd:complexType>
}
  LContNode := FirstChildElement(ANode);
  Assert(assigned(LContNode), ASSERT_LOCATION+': no complexContent node found reading array "'+AName+'"');
  Assert(LContNode.NamespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': expected complexContent node in wrong namespace found reading array "'+AName+'"');
  Assert(LContNode.LocalName = ID_SOAP_WSDL_COMPLEXCONTENT, ASSERT_LOCATION+': expected complexContent node in wrong namespace found reading array "'+AName+'"');

  LRestNode := FirstChildElement(LContNode);
  Assert(assigned(LRestNode), ASSERT_LOCATION+': no restriction node found reading array "'+AName+'"');
  Assert(LRestNode.NamespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': expected restriction node in wrong namespace found reading array "'+AName+'"');
  Assert(LRestNode.LocalName = ID_SOAP_WSDL_RESTRICTION, ASSERT_LOCATION+': expected restriction node in wrong namespace found reading array "'+AName+'"');
  s := LRestNode.GetAttributeNS('', ID_SOAP_WSDL_SCHEMA_ATTRIB_BASE);
  SplitString(s, ':', ns, s);
  ns := ResolveXMLNamespaceCode(LRestNode, ns, 'restriction node in array "'+AName+'"');
  Assert(ns = ID_SOAP_NS_SOAPENC, ASSERT_LOCATION+': restriction node has wrong base (NS) found reading array "'+AName+'"');
  Assert(s = ID_SOAP_TYPE_ARRAY, ASSERT_LOCATION+': restriction node has wrong base type found reading array "'+AName+'"');

  LAttrNode := FirstChildElement(LRestNode);
  Assert(assigned(LAttrNode), ASSERT_LOCATION+': no attribute node found reading array "'+AName+'"');
  Assert(LAttrNode.NamespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': expected attribute node in wrong namespace found reading array "'+AName+'"');
  if LAttrNode.LocalName = ID_SOAP_WSDL_SEQUENCE then
    begin
    LAttrNode := NextSiblingElement(LAttrNode);
    Assert(assigned(LAttrNode), ASSERT_LOCATION+': no attribute node found reading array "'+AName+'"');
    Assert(LAttrNode.NamespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': expected attribute node in wrong namespace found reading array "'+AName+'"');
    end;
  Assert(LAttrNode.LocalName = ID_SOAP_WSDL_ATTRIBUTE, ASSERT_LOCATION+': expected attribute node but found "'+LAttrNode.LocalName+'" found reading array "'+AName+'"');
  s := LAttrNode.GetAttributeNS('', ID_SOAP_WSDL_ATTRIB_REF);
  SplitString(s, ':', ns, s);
  ns := ResolveXMLNamespaceCode(LAttrNode, ns, 'attribute node in array "'+AName+'"');
  Assert(ns = ID_SOAP_NS_SOAPENC, ASSERT_LOCATION+': attribute node has wrong ref (NS) found reading array "'+AName+'"');
  Assert(s = ID_SOAP_TYPE_ARRAYTYPE, ASSERT_LOCATION+': attribute node has wrong ref type found reading array "'+AName+'"');
  s := LAttrNode.GetAttributeNS(ID_SOAP_NS_WSDL, ID_SOAP_TYPE_ARRAYTYPE);
  if Pos(':', s) > 0 then
    begin
    SplitString(s, ':', ns, s);
    ns := ResolveXMLNamespaceCode(LRestNode, ns, 'attribute node arraytype attribute in array "'+AName+'"');
    end
  else
    begin
    ns := ID_SOAP_NS_SCHEMA_2001;
    end;
  SplitString(s, '[', s, junk);
  LArrayDefn := TIdSoapWsdlArrayType.create(FWsdl, AName);
  LArrayDefn.TypeName.NameSpace := ns;
  LArrayDefn.TypeName.Name := s;
  result := LArrayDefn;
  ReadAbstractTypeDetails(ANode, Result);
end;


function TIdSoapWSDLConvertor.ReadDocumentation(ANode:TdomElement):String;
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadDocumentation';
var
  LNode : TdomElement;
begin
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Node is not valid');
  result := '';
  LNode := ANode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_DOCO);
  if assigned(LNode) then
    begin
    result := LNode.code;
    delete(result, 1, length('<documentation>'));
    delete(result, (length(result) - length('</documentation>'))+1, length('</documentation>'));
    end;
end;

procedure TIdSoapWSDLConvertor.ReadTypes(ANode : TdomElement);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadTypes';
var
  LSchemaNode : TdomElement;
  LNode : TdomNode;
  LFirstLevelElement : TdomElement;
  LTypeElement : TdomElement;
  LName : string;
  LTargetNamespace : string;
  LArrayNode : TdomElement;
  LTempNode : TdomElement;
  LElementDefn : TIdSoapWsdlElementDefn;
  LTypeDefn : TIdSoapWSDLAbstractType;
  LType : string;
  LTypeNS : String;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Types Node not valid');

  FWsdl.TypesDocumentation := ReadDocumentation(ANode);
  LTypeDefn := nil;

  // we only read the first level of the schema
  if ANode.LocalName = ID_SOAP_WSDL_SCHEMA then
    begin
    LSchemaNode := ANode;
    end
  else
    begin
    LSchemaNode := ANode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_SCHEMA);
    end;
  while assigned(LSchemaNode) do
    begin
    if LSchemaNode.hasAttributeNS('', ID_SOAP_WSDL_TARGETNAMESPACE) then
      begin
      LTargetNamespace := LSchemaNode.getAttributeNS('', ID_SOAP_WSDL_TARGETNAMESPACE);
      end
    else
      begin
      LTargetNamespace := FTargetNamespace;
      end;

    LNode := LSchemaNode.firstChild;
    while assigned(LNode) do
      begin
      if (LNode is TdomElement) then
        begin
        LFirstLevelElement := LNode as TdomElement;
        Assert(LFirstLevelElement.NamespaceURI = ID_SOAP_NS_SCHEMA, ASSERT_LOCATION+': there is a node in the XML schema types that does not come from the schema namespace');
        LName := LFirstLevelElement.GetAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
        if LFirstLevelElement.localName = ID_SOAP_SCHEMA_IMPORT then
          begin
          if (LNode as TdomElement).getAttributeNS('', ID_SOAP_SCHEMA_SCHEMALOCATION) <> ID_SOAP_NS_SOAPENC then
            begin
            OnFindInclude(self, (LNode as TdomElement).getAttributeNS('', ID_SOAP_SCHEMA_SCHEMALOCATION), (LNode as TdomElement).getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE));
            end;
          FWsdl.SchemaSection[LTargetNamespace].Imports.add(LFirstLevelElement.GetAttributeNS('', ID_SOAP_SCHEMA_NAMESPACE));
          end
        else
          begin
          Assert(LName <> '', ASSERT_LOCATION+': There is an unnamed element in XML Schema Types');
          if LFirstLevelElement.localName = ID_SOAP_WSDL_ELEMENT then
            begin
            LElementDefn := TIdSoapWsdlElementDefn.create(FWsdl, LName, LTargetNamespace);
            LTypeElement := FirstChildElement(LFirstLevelElement);
            Assert(Assigned(LTypeElement) xor LFirstLevelElement.hasAttributeNS('', ID_SOAP_NAME_SCHEMA_TYPE), ASSERT_LOCATION+': A Element node should have either a Type stated, a type defined inside. It shouldn''t have both or neither (in "'+LName+'")');
            if not Assigned(LTypeElement) then
              begin
              LType := LFirstLevelElement.GetAttributeNS('', ID_SOAP_NAME_SCHEMA_TYPE);
              Assert(Pos(':', LType) > 0, ASSERT_LOCATION+': No namespace in element "'+LName+'" type');
              SplitString(LType, ':', LTypeNS, LType);
              LElementDefn.TypeInfo.Namespace := ResolveXMLNamespaceCode(LFirstLevelElement, LTypeNS, 'Element '+LName);
              LElementDefn.TypeInfo.Name := LType;
              LElementDefn.IsReference := false;
              end;
            FWsdl.AddElementDefinition(LTargetNamespace, LName, LElementDefn);
            end
          else
            begin
            LElementDefn := nil;
            LTypeElement := LFirstLevelElement;
            end;

          if assigned(LTypeElement) then
            begin
            if LTypeElement.LocalName = ID_SOAP_WSDL_COMPLEXTYPE then
              begin
              // if the first child is complexContent, then we think it's an array
              LArrayNode := FirstChildElement(LTypeElement);
              if (Assigned(LArrayNode)) and (LArrayNode.localName = ID_SOAP_WSDL_COMPLEXCONTENT) then
                begin
                LTempNode := FirstChildElement(LArrayNode);
                if assigned(LTempNode) then
                  begin
                  if LTempNode.localName = ID_SOAP_WSDL_EXTENSION then
                    begin
                    // ok, we guess that this is a struct that is an extension of something
                    LTypeDefn := ReadStruct(LTargetNamespace, LName, LArrayNode);
                    end
                  else
                    begin
                    // we assume that this an array, though it could be wrong...
                    LTypeDefn := ReadArrayType(LTargetNamespace, LName, LTypeElement);
                    end;
                  end
                else
                  begin
                  Assert(false, ASSERT_LOCATION+': unexpected schema declaration: no child node on '+ ID_SOAP_WSDL_COMPLEXCONTENT);
                  end;
                end
              // if the first child is SimpleContent, then we think it's actually a simple type declaration
              else if (Assigned(LArrayNode)) and (LArrayNode.localName = ID_SOAP_WSDL_SIMPLECONTENT) then
                begin
                if (LArrayNode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION) <> nil) and
                   (LArrayNode.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION).getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_ENUMERATION) <> nil) then
                  begin
                  LTypeDefn := ReadEnumeration(LTargetNamespace, LName, LArrayNode);
                  end
                else
                  begin
                  LTypeDefn := ReadSimpleType(LTargetNamespace, LName, LArrayNode);
                  end;
                end
              else
                begin
                LTypeDefn := ReadStruct(LTargetNamespace, LName, LTypeElement);
                end;
              end
            else if LTypeElement.LocalName = ID_SOAP_WSDL_SIMPLETYPE then
              begin
              if ((LTypeElement.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION) <> nil) and
                 (LTypeElement.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_RESTRICTION).getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_ENUMERATION) <> nil))
                or
                  (LTypeElement.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_LIST) <> nil)
                  then
                begin
                if (LTypeElement.getFirstChildElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_LIST) <> nil) then
                  begin
                  LTypeDefn := ReadEnumSet(LTargetNamespace, LName, LTypeElement);
                  end
                else
                  begin
                  LTypeDefn := ReadEnumeration(LTargetNamespace, LName, LTypeElement);
                  end;
                end
              else
                begin
                LTypeDefn := ReadSimpleType(LTargetNamespace, LName, LTypeElement);
                end;
              end
            else
              raise EIdSoapRequirementFail.create(ASSERT_LOCATION+': Unknown Element Type in Schema Types - Type "'+LName+'" element is "'+LTypeElement.LocalName+'"');
            if assigned(LElementDefn) then
              begin
              LElementDefn.TypeDefn := LTypeDefn;
              end
            else
              begin
              FWsdl.AddTypeDefinition(LTargetNamespace, LName, LTypeDefn);
              end;
            end;
          end;
        end;
      LNode := LNode.nextSibling;
      end;
    LSchemaNode := LSchemaNode.getNextSiblingElementNS(ID_SOAP_NS_SCHEMA, ID_SOAP_WSDL_SCHEMA);
    end;
end;

procedure TIdSoapWSDLConvertor.ReadMessages(ARootNode : TdomNode);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadMessages';
var
  LNode : TdomElement;
  LName : string;
  LMsgDefn : TIdSoapWSDLMessage;
  LPartNode : TdomElement;
  LPartName : string;
  LPartType : string;
  LPartTypeNS : string;
  LPartDefn : TIdSoapWSDLMessagePart;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(IdSoapTestNodeValid(ARootNode, TdomNode), ASSERT_LOCATION+': RootNode is not valid');
  LNode := ARootNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_MESSAGE);
  while assigned(LNode) do
    begin
    LName := LNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
    Assert(LName <> '', ASSERT_LOCATION+': Message Name is blank');
    Assert(FWsdl.Messages.indexof(LName) = -1, ASSERT_LOCATION+': Message Name "'+LName+'" duplicated');
    LMsgDefn := TIdSoapWSDLMessage.create(FWsdl, LName);
    FWsdl.Messages.AddObject(LName, LMsgDefn);
    LMsgDefn.Documentation := ReadDocumentation(LNode);
    LPartNode := LNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_PART);
    while assigned(LPartNode) do
      begin
      LPartName := LPartNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
      Assert(LPartName <> '', ASSERT_LOCATION+': UnNamed Part in message "'+LName+'"');
      Assert(LMsgDefn.Parts.indexOf(LPartName) = -1, ASSERT_LOCATION+': Duplicate Part "'+LPartName+'" in message "'+LName+'"');
      LPartDefn := TIdSoapWSDLMessagePart.create(FWsdl, LPartName);
      LMsgDefn.Parts.AddObject(LPartName, LPartDefn);
      if LPartNode.hasAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_TYPE) then
        begin
        LPartType := LPartNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_TYPE);
        Assert(LPartType <> '', ASSERT_LOCATION+': Part Type "'+LPartName+'" in message "'+LName+'" has no type');
        Assert(Pos(':', LPartType) > 0, ASSERT_LOCATION+': Part Type "'+LPartName+'" in message "'+LName+'" has no namespace');
        SplitString(LPartType, ':', LPartTypeNS, LPartType);
        LPartTypeNS := ResolveXMLNamespaceCode(LPartNode, LPartTypeNS, 'Element '+LPartNode.NodeName);
        LPartDefn.PartType.NameSpace := LPartTypeNS;
        LPartDefn.PartType.Name := LPartType;
        end
      else if LPartNode.hasAttributeNS('', ID_SOAP_SCHEMA_ELEMENT) then
        begin
        LPartType := LPartNode.getAttributeNS('', ID_SOAP_SCHEMA_ELEMENT);
        Assert(LPartType <> '', ASSERT_LOCATION+': Part Type "'+LPartName+'" in message "'+LName+'" has no type');
        Assert(Pos(':', LPartType) > 0, ASSERT_LOCATION+': Part Type "'+LPartName+'" in message "'+LName+'" has no namespace');
        SplitString(LPartType, ':', LPartTypeNS, LPartType);
        LPartTypeNS := ResolveXMLNamespaceCode(LPartNode, LPartTypeNS, 'Element '+LPartNode.NodeName);
        LPartDefn.Element.NameSpace := LPartTypeNS;
        LPartDefn.Element.Name := LPartType;
        end;
      LPartNode := LPartNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_PART);
      end;
    LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_MESSAGE);
    end;
end;

procedure TIdSoapWSDLConvertor.ReadOperations(ANode : TdomElement);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadOperations';
var
  LNode : TdomElement;
  LName : string;
  LPortDefn : TIdSoapWSDLPortType;
  LOpDefn : TIdSoapWSDLPortTypeOperation;
  LMsgNode : TdomElement;
  LMsgName : string;
  LMsgNameNS : string;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Types Node not found');

  LName := ANode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
  Assert(LName <> '', ASSERT_LOCATION+': PortType is unnamed');
  Assert(FWsdl.PortTypes.indexOf(LName) = -1, 'Duplicate PortType Name "'+LName+'"');
  LPortDefn := TIdSoapWSDLPortType.create(FWsdl, LName);
  FWsdl.PortTypes.AddObject(LName, LPortDefn);
  LPortDefn.Documentation := ReadDocumentation(ANode);

  LNode := ANode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_OPERATION);
  while assigned(LNode) do
    begin
    LName := LNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
    LOpDefn := TIdSoapWSDLPortTypeOperation.create(FWsdl, LName);
    LOpDefn.Documentation := ReadDocumentation(LNode);

    LMsgNode := LNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_INPUT);
    if assigned(LMsgNode) then
      begin
      Assert(IdSoapTestNodeValid(LMsgNode, TdomElement), ASSERT_LOCATION+': Port "'+LPortDefn.Name+'" Operation "'+LOpDefn.Name+'" Input not found');
      LOpDefn.Input.Name := LMsgNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
      LMsgName := LMsgNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_MESSAGE);
      Assert(Pos(':', LMsgName) > 0, ASSERT_LOCATION+': Port "'+LPortDefn.Name+'" Operation "'+LOpDefn.Name+'" Input Message Namespace is blank');
      SplitString(LMsgName, ':', LMsgNameNS, LMsgName);
      Assert(LMsgName <> '', ASSERT_LOCATION+': Port "'+LPortDefn.Name+'" Operation "'+LOpDefn.Name+'" Input Message Name is blank');
      LMsgNameNS := ResolveXMLNamespaceCode(LMsgNode, LMsgNameNS, 'Message '+LMsgName);
      LOpDefn.Input.Message.NameSpace := LMsgNameNS;
      LOpDefn.Input.Message.Name := LMsgName;
      end;

    LMsgNode := LNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_OUTPUT);
    if assigned(LMsgNode) then
      begin
      Assert(IdSoapTestNodeValid(LMsgNode, TdomElement), ASSERT_LOCATION+': Port "'+LPortDefn.Name+'" Operation "'+LOpDefn.Name+'" output not found');
      LOpDefn.Output.Name := LMsgNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
      LMsgName := LMsgNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_MESSAGE);
      Assert(Pos(':', LMsgName) > 0, ASSERT_LOCATION+': Port "'+LPortDefn.Name+'" Operation "'+LOpDefn.Name+'" Output Message Namespace is blank');
      SplitString(LMsgName, ':', LMsgNameNS, LMsgName);
      Assert(LMsgName <> '', ASSERT_LOCATION+': Port "'+LPortDefn.Name+'" Operation "'+LOpDefn.Name+'" Output Message Name is blank');
      LMsgNameNS := ResolveXMLNamespaceCode(LMsgNode, LMsgNameNS, 'Message '+LMsgName);
      LOpDefn.Output.Message.NameSpace := LMsgNameNS;
      LOpDefn.Output.Message.Name := LMsgName;
      end;

    LName := LName + '|' + LOpDefn.Input.Name+ '|' + LOpDefn.Output.Name;
    Assert(LName <> '', ASSERT_LOCATION+': Unnamed operation found');
    Assert(LPortDefn.Operations.indexOf(LName) = -1, ASSERT_LOCATION+': Duplicate Operation "'+LName+'" in Port "'+LPortDefn.Name+'"');
    LPortDefn.Operations.AddObject(LName, LOpDefn);

    Assert((LOpDefn.Output.Message.Name <> '') or (LOpDefn.Input.Message.Name <> ''), ASSERT_LOCATION+': Port "'+LPortDefn.Name+'" Operation "'+LOpDefn.Name+'" has neither Input or Output messages defined');


    LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_OPERATION);
    end;
end;

procedure TIdSoapWSDLConvertor.ReadHeaders(AElem : TdomElement; AMsg : TIdSoapWSDLBindingOperationMessage);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadHeaders';
var
  LNode : TdomElement;
  LHeader : TIdSoapWSDLBindingOperationMessageHeader;
  s, ns : String;
begin
  Assert(self.TestValid(TIdSoapWSDLConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(IdSoapTestNodeValid(AElem, TdomElement), ASSERT_LOCATION+': Elem Node not found');
  Assert(AMsg.TestValid(TIdSoapWSDLBindingOperationMessage), ASSERT_LOCATION+': Wsdl is not valid');

  LNode := AElem.getFirstChildElementNS(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_WSDL_HEADER);
  while assigned(LNode) do
    begin
    LHeader := TIdSoapWSDLBindingOperationMessageHeader.create(FWSDL, LNode.getAttributeNS('', ID_SOAP_WSDL_PART));
    AMsg.AddHeader(LHeader);
    s := LNode.getAttributeNS('', ID_SOAP_WSDL_MESSAGE);
    SplitNamespace(s, ns, s);
    LHeader.Message.NameSpace := ResolveXMLNamespaceCode(LNode, ns, 'Header "'+LHeader.Name+'"');
    LHeader.Message.Name := s;
    LHeader.SoapNamespace := LNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE);
    LHeader.SoapUse := StrToWsdlSoapEncodingStyle(LNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_USE), 'Header "'+LHeader.Name+'" Encoding Style');
    LHeader.SoapEncodingStyle := LNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_ENCODING);
    LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_WSDL_HEADER);
    end;
end;

procedure TIdSoapWSDLConvertor.ReadBinding(ANode : TdomElement);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadBinding';
var
  LName : string;
  LBindDefn : TIdSoapWSDLBinding;
  LSoapNode : TdomElement;
  LOpNode : TdomElement;
  LOpDefn : TIdSoapWSDLBindingOperation;
  LMsgNode : TdomElement;
  LPortType : string;
  LPortTypeNS : String;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Bindings Node not found');

  LName := ANode.GetAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
  Assert(LName <> '', ASSERT_LOCATION+': Name is blank');
  Assert(FWsdl.Bindings.IndexOf(LName) = -1, ASSERT_LOCATION+': Duplicate Binding Name "'+LName+'"');
  LBindDefn := TIdSoapWSDLBinding.create(FWsdl, LName);
  FWsdl.Bindings.AddObject(LName, LBindDefn);
  LBindDefn.Documentation := ReadDocumentation(ANode);
  LPortType := ANode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_TYPE);
  if LPortType <> '' then
    begin
    SplitString(LPortType, ':', LPortTypeNS, LPortType);
    LPortTypeNS := ResolveXMLNamespaceCode(ANode, LPortTypeNS, 'PortType for binding '+LName);
    LBindDefn.PortType.NameSpace := LPortTypeNS;
    LBindDefn.PortType.Name := LPortType;
    end;

  LSoapNode := ANode.getFirstChildElementNS(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_WSDL_BINDING);
  if assigned(LSoapNode) then
    begin
    LBindDefn.SoapStyle := StrToWsdlSoapBindingStyle(LSoapNode.getAttributeNS('', ID_SOAP_WSDL_BINDING_ATTRIB_STYLE), 'Soap Style for Binding "'+LName+'"');
    LBindDefn.SoapTransport := LSoapNode.getAttributeNS('', ID_SOAP_WSDL_BINDING_ATTRIB_TRANSPORT);
    Assert(LBindDefn.SoapTransport <> '', ASSERT_LOCATION+': Soap Transport for Binding "'+LName+'" not specified');

    LOpNode := ANode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_OPERATION);
    while assigned(LOpNode) do
      begin
      LName := LOpNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
      Assert(LName <> '', ASSERT_LOCATION+': the binding "'+LBindDefn.Name+'" contains an operation with a blank name');
      LOpDefn := TIdSoapWSDLBindingOperation.create(FWsdl, LName);
      LOpDefn.Documentation := ReadDocumentation(LOpNode);

      LSoapNode := LOpNode.getFirstChildElementNS(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_WSDL_OPERATION);
      Assert(IdSoapTestNodeValid(LSoapNode, TdomElement), ASSERT_LOCATION+': No Soap Operation Information found for Binding "'+LBindDefn.Name+'", Operation "'+LOpDefn.Name+'"');
      LOpDefn.SoapStyle := StrToWsdlSoapBindingStyle(LSoapNode.getAttributeNS('', ID_SOAP_WSDL_BINDING_ATTRIB_STYLE), 'Soap Style for Binding "'+LBindDefn.Name+'", Operation "'+LOpDefn.Name+'"');
      LOpDefn.SoapAction := LSoapNode.getAttributeNS('', ID_SOAP_WSDL_OPERATION_ATTRIB_ACTION);

      LMsgNode := LOpNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_INPUT);
      Assert(IdSoapTestNodeValid(LMsgNode, TdomElement), ASSERT_LOCATION+': No Input Information found for Binding "'+LBindDefn.Name+'", Operation "'+LOpDefn.Name+'"');
      LOpDefn.Input.Name := LMsgNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
      LName := LName + '|'+ LOpDefn.Input.Name;
      LSoapNode := LMsgNode.getFirstChildElementNS(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_WSDL_BODY);
      LOpDefn.Input.SoapUse := StrToWsdlSoapEncodingStyle(LSoapNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_USE), 'Input Soap Use for Binding "'+LBindDefn.Name+'", Operation "'+LOpDefn.Name+'"');
      LOpDefn.Input.SoapEncodingStyle := LSoapNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_ENCODING);
      LOpDefn.Input.SoapNamespace := LSoapNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE);
      ReadHeaders(LMsgNode, LOpDefn.Input);

      LMsgNode := LOpNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_OUTPUT);
      Assert(IdSoapTestNodeValid(LMsgNode, TdomElement), ASSERT_LOCATION+': No Output Information found for Binding "'+LBindDefn.Name+'", Operation "'+LOpDefn.Name+'"');
      LOpDefn.Output.Name := LMsgNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
      LName := LName + '|'+ LOpDefn.Output.Name;
      LSoapNode := LMsgNode.getFirstChildElementNS(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_WSDL_BODY);
      LOpDefn.Output.SoapUse := StrToWsdlSoapEncodingStyle(LSoapNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_USE), 'Output Soap Use for Binding "'+LBindDefn.Name+'", Operation "'+LOpDefn.Name+'"');
      LOpDefn.Output.SoapEncodingStyle := LSoapNode.getAttributeNS('', ID_SOAP_WSDL_ATTRIB_ENCODING);
      LOpDefn.Output.SoapNamespace := LSoapNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE);
      ReadHeaders(LMsgNode, LOpDefn.Output);

      Assert(LBindDefn.Operations.indexOf(LName) = -1, ASSERT_LOCATION+': the binding "'+LBindDefn.Name+'" contains an duplicate operation name "'+LName+'"');
      LBindDefn.Operations.AddObject(LName, LOpDefn);

      LOpNode := LOpNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_OPERATION);
      end;
    end;
end;

procedure TIdSoapWSDLConvertor.ReadService(ANode : TdomElement);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadBinding';
var
  LName : string;
  LSvcDefn : TIdSoapWSDLService;
  LPortNode : TdomElement;
  LPort  : TIdSoapWSDLServicePort;
  LBindName : string;
  LBindNameNS : string;
  LSoapNode : TdomElement;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomElement), ASSERT_LOCATION+': Types Node not found');

  LName := ANode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
  Assert(LName <> '', ASSERT_LOCATION+': Name is blank');
  Assert(FWsdl.Services.indexOf(LName) = -1, ASSERT_LOCATION+': Duplicate Service Name "'+LName+'"');
  LSvcDefn := TIdSoapWSDLService.create(FWsdl, LName);
  FWsdl.Services.AddObject(LName, LSvcDefn);
  LSvcDefn.Documentation := ReadDocumentation(ANode);

  LPortNode := ANode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_PORT);
  while assigned(LPortNode) do
    begin
    LPort := TIdSoapWSDLServicePort.create(FWsdl, LPortNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME));
    LSvcDefn.Ports.AddObject(LPort.Name, LPort);
    LPort.Documentation := ReadDocumentation(LPortNode);
    LBindName := LPortNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_BINDING);
    SplitString(LBindName, ':', LBindNameNS, LBindName);
    LBindNameNS := ResolveXMLNamespaceCode(LPortNode, LBindNameNS, 'Server Port '+LPort.Name);
    LPort.BindingName.NameSpace := LBindNameNS;
    LPort.BindingName.Name := LBindName;
    LSoapNode := LPortNode.getFirstChildElementNS(ID_SOAP_NS_WSDL_SOAP, ID_SOAP_WSDL_ADDRESS);
    if assigned(LSoapNode) then
      begin
      LPort.SoapAddress := LSoapNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_LOCATION);
      end;
    LPortNode := LPortNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_PORT);
    end;
end;

procedure TIdSoapWSDLConvertor.DOMReadError(ASender: TObject; AError: TdomError; var VGo: boolean);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.DOMReadError';
begin
  Assert(Self.TestValid(TIdSoapWSDLConvertor), ASSERT_LOCATION+': self is not valid');
  Assert(assigned(AError), ASSERT_LOCATION+': Error is nil');
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

procedure TIdSoapWSDLConvertor.ReadFromXml(AStream : TStream; ADefinedNamespace : string);
const ASSERT_LOCATION = 'IdSoapWsdlXml.TIdSoapWSDLConvertor.ReadWSDLFromXml';
var
  LDomImpl: TDomImplementation;
  LDom: TdomDocument;
  LParser: TXmlToDomParser;
  LDefinitionsNode : TdomNode;
  LNode : TdomElement;
  s, ns : string;
begin
  Assert(FWsdl.TestValid(TIdSoapWSDL), ASSERT_LOCATION+': Wsdl is not valid');
  Assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');

  FDomErr := '';
  LDomImpl := TDomImplementation.Create(NIL);
  try
    LDomImpl.OnError := DOMReadError;
    LParser := TXmlToDomParser.Create(NIL);
    try
      LParser.DOMImpl := LDomImpl;
      LParser.DocBuilder.BuildNamespaceTree := true;
      try
        LParser.StreamToDom(AStream);
      except
        on e:Exception do
          begin
          if FDomErr <> '' then
            e.message := e.message + ' '+FDomErr;
          raise;
          end;
      end;
    finally
      FreeAndNil(LParser);
      end;
    LDom := (LDomImpl.documents.item(0) as TdomDocument);
    Assert(IdSoapTestNodeValid(LDom, TdomDocument), ASSERT_LOCATION+': Dom is not valid');

    LDefinitionsNode := LDom.documentElement;
    if FWsdl.Name = '' then
      begin
      FWsdl.Name := (LDefinitionsNode as TdomElement).GetAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);

      Assert(IdSoapTestNodeValid(LDefinitionsNode, TdomNode), ASSERT_LOCATION+': Types Node not found');
      Assert((LDefinitionsNode.NodeName = ID_SOAP_WSDL_ROOT) or (LDefinitionsNode.LocalName = ID_SOAP_WSDL_ROOT), ASSERT_LOCATION+': Wrong Name on Root Node');

      if (LDefinitionsNode as TdomElement).hasAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME) then
        begin
        FWsdl.Name := (LDefinitionsNode as TdomElement).GetAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAME);
        if Pos(':', FWsdl.Name) > 0 then
          begin
          // this is a specific workaround for a bug observed in the google WSDL. They used some toolkit, so the toolkit has the bug....
          SplitString(FWsdl.Name, ':', ns, s);
          FWsdl.Name := s;
          end;
        Assert((LDefinitionsNode as TdomElement).hasAttributeNS('', ID_SOAP_WSDL_TARGETNAMESPACE), ASSERT_LOCATION+': No TargetNamespace attribute on WSDL definitions entity');
        end;
      end;
    if ADefinedNamespace <> '' then
      begin
      FTargetNamespace := ADefinedNamespace;
      end
    else
      begin
      FTargetNamespace := (LDefinitionsNode as TdomElement).GetAttributeNS('', ID_SOAP_WSDL_TARGETNAMESPACE);
      if FWsdl.Namespace = '' then
        begin
        FWsdl.Namespace := FTargetNamespace
        end;
      end;
    if LDefinitionsNode.LocalName = 'schema' then
      begin
      ReadTypes(LDefinitionsNode as TdomElement);
      end;

    LNode := LDefinitionsNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_TYPE_ROOT);
    while assigned(LNode) do
      begin
      Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Type Node not valid');
      ReadTypes(LNode);
      LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_TYPE_ROOT);
      end;

    ReadMessages(LDefinitionsNode);

    LNode := LDefinitionsNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_PORTTYPE);
    while assigned(LNode) do
      begin
      Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': PortType Node not valid');
      ReadOperations(LNode);
      LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_PORTTYPE);
      end;

    LNode := LDefinitionsNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_BINDING);
    while assigned(LNode) do
      begin
      Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Binding Node not valid');
      ReadBinding(LNode);
      LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_BINDING);
      end;

    LNode := LDefinitionsNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_SERVICE);
    while assigned(LNode) do
      begin
      Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Binding Node not valid');
      ReadService(LNode);
      LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_SERVICE);
      end;

    LNode := LDefinitionsNode.getFirstChildElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_IMPORT);
    while assigned(LNode) do
      begin
      Assert(IdSoapTestNodeValid(LNode, TdomElement), ASSERT_LOCATION+': Binding Node not valid');
      OnFindInclude(self, LNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_LOCATION), LNode.getAttributeNS('', ID_SOAP_WSDL_GEN_ATTRIB_NAMESPACE));
      LNode := LNode.getNextSiblingElementNS(ID_SOAP_NS_WSDL, ID_SOAP_WSDL_IMPORT);
      end;

    FWsdl.Documentation := ReadDocumentation(LDom.documentElement);

  finally
    FreeAndNil(LDomImpl);
    end;
end;

end.
