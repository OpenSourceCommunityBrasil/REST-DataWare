{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15740: IdSoapITIXML.pas 
{
{   Rev 1.2    20/6/2003 00:03:44  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:02:40  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:34:14  GGrieve
}
{
IndySOAP: this unit knows how to read and write an ITI to and from an XML file
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Header support, ITI renaming support
  18-Mar 2003   Grahame Grieve                  Remove IDSOAP_USE_RENAMED_OPENXML
  10-Oct 2002   Andrew Cumming                  Added streaming for inherited interface info
  26-Sep 2002   Grahame Grieve                  Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
   9-May 2002   Andrew Cumming                  Mods to allow you to state app/soap or text/xml
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing dependency on ole2 unit
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Fix for IDSOAP_USE_RENAMED_OPENXML not defined
  04-Apr 2002   Grahame Grieve                  SoapAction and Namespace properties for Interfaces
  03-Apr 2002   Grahame Grieve                  Handle ITI Method Request and Response Names
  26-Mar 2002   Grahame Grieve                  Change names of Constants
  22-Mar 2002   Grahame Grieve                  WSDL Documentation Support
  14-Mar 2002   Grahame Grieve                  Namespace support
   7-Mar 2002   Grahame Grieve                  Review assertions
  03-Feb 2002   Andrew Cumming                  Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapITIXML;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapITI,
  IdSoapOpenXML;

type
  TIdSoapITIXMLStreamer = class(TIdSoapITIStreamingClass)
  Private
    function BuildNamesAndTypes(ADoc: TDomDocument; AITIObject : TIdSoapITIBaseObject):TdomElement;
    procedure SaveInterface(ADoc: TDomDocument; AParent: TdomNode; AInterface: TIdSoapITIInterface);
    procedure SaveMethod(ADoc: TDomDocument; AParent: TdomNode; AMethod: TIdSoapITIMethod);
    procedure SaveParamList(ADoc: TDomDocument; AParent: TdomNode; AItemName: String; AParamList : TIdSoapITIParamList);
    procedure SaveParameter(ADoc: TDomDocument; AParent: TdomNode; AParameter: TIdSoapITIParameter);

    procedure ReadNamesAndTypes(AElement : TdomElement; AITIObject : TIdSoapITIBaseObject);
    procedure ReadInterface(AITI: TIdSoapITI; ANode: TdomNode);
    procedure ReadMethod(AInterface: TIdSoapITIInterface; ANode: TdomNode);
    function ReadParameter(AMethod: TIdSoapITIMethod; ANode: TdomNode) : TIdSoapITIParameter;
    procedure ReadParamList(AMethod: TIdSoapITIMethod; AParamList: TIdSoapITIParamList; ANode: TdomNode; AName : string);
  Public
    procedure SaveToStream(AITI: TIdSoapITI; AStream: TStream); Override;
    procedure ReadFromStream(AITI: TIdSoapITI; AStream: TStream); Override;
  end;


implementation

uses
{$IFDEF DELPHI4OR5}
  ComObj,
{$ENDIF}
  IdSoapConsts,
  IdSoapExceptions,
  IdSoapResourceStrings,
  IdSoapUtilities,
  SysUtils,
  TypInfo;

{ TIdSoapITIXMLStreamer }

function NewTextNode(ADoc: TDomDocument; AName, AText: String): TDomElement;
const ASSERT_LOCATION = 'IdSoapITIXml.NewTextNode';
begin
  assert(Assigned(ADoc), ASSERT_LOCATION+': Doc is nil');
  assert(AName <> '', ASSERT_LOCATION+': Name = ""');
  Result := ADoc.createElement(AName);
  Result.appendChild(ADoc.createTextNode(AText));
end;

function TIdSoapITIXMLStreamer.BuildNamesAndTypes(ADoc: TDomDocument; AITIObject: TIdSoapITIBaseObject): TdomElement;
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.BuildNamesAndTypes';
var
  i : integer;
  LNode : TdomElement;
  s1, s2 : string;
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(Assigned(ADoc), ASSERT_LOCATION+': Document not valid');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': Parameter not valid');

  result := ADoc.createElement('NamesAndTypes');
  for i := 0 to AITIObject.Names.Count - 1 do
    begin
    LNode := ADoc.createElement('Name');
    result.appendChild(LNode);
    if Pos('.', AITIObject.Names[i]) > 0 then
      begin
      SplitString(AITIObject.Names[i], '.', s1, s2);
      LNode.appendChild(NewTextNode(ADoc, 'ClassName', s1));
      LNode.appendChild(NewTextNode(ADoc, 'PascalName', s2));
      end
    else
      begin
      LNode.appendChild(NewTextNode(ADoc, 'PascalName', AITIObject.Names[i]));
      end;
    LNode.appendChild(NewTextNode(ADoc, 'SoapName', (AITIObject.Names.Objects[i] as TIdSoapITINameObject).Name));
    end;
  for i := 0 to AITIObject.Types.Count - 1 do
    begin
    LNode := ADoc.createElement('Type');
    result.appendChild(LNode);
    LNode.appendChild(NewTextNode(ADoc, 'PascalName', AITIObject.Types[i]));
    LNode.appendChild(NewTextNode(ADoc, 'SoapName', (AITIObject.Types.Objects[i] as TIdSoapITINameObject).Name));
    LNode.appendChild(NewTextNode(ADoc, 'Namespace', (AITIObject.Types.Objects[i] as TIdSoapITINameObject).Namespace));
    end;
  for i := 0 to AITIObject.Enums.Count - 1 do
    begin
    LNode := ADoc.createElement('Enum');
    result.appendChild(LNode);
    LNode.appendChild(NewTextNode(ADoc, 'ClassName', AITIObject.Enums[i]));
    LNode.appendChild(NewTextNode(ADoc, 'SoapName', (AITIObject.Enums.Objects[i] as TIdSoapITINameObject).Name));
    end;
end;

procedure TIdSoapITIXMLStreamer.SaveInterface(ADoc: TDomDocument; AParent: TdomNode; AInterface: TIdSoapITIInterface);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.SaveInterface';
var
  LElement: TdomElement;
  i: Integer;
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(Assigned(ADoc), ASSERT_LOCATION+': Document not valid');
  assert(IdSoapTestNodeValid(AParent, TdomNode), ASSERT_LOCATION+': Parent not valid');
  assert(AInterface.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': Interface nmot valid');
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_NAME, AInterface.Name));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_UNITNAME, AInterface.UnitName));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_DOCUMENTATION, AInterface.Documentation));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_NAMESPACE, AInterface.Namespace));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_IS_INHERITED, IdEnumToString(TypeInfo(Boolean), ord(AInterface.IsInherited))));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_GUID, GUIDToString({$IFDEF DELPHI5} System.TGUID( {$ENDIF} AInterface.GUID {$IFDEF DELPHI5}) {$ENDIF})));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_ANCESTOR, AInterface.Ancestor));
  AParent.AppendChild(BuildNamesAndTypes(ADoc, AInterface));
  for i := 0 to AInterface.Methods.Count - 1 do
    begin
    LElement := ADoc.createElement(ID_SOAP_ITI_XML_NODE_METHOD);
    AParent.appendChild(LElement);
    SaveMethod(ADoc, LElement, AInterface.Methods.Objects[i] as TIdSoapITIMethod);
    end;
end;

procedure TIdSoapITIXMLStreamer.SaveMethod(ADoc: TDomDocument; AParent: TdomNode; AMethod: TIdSoapITIMethod);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.SaveMethod';
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(Assigned(ADoc), ASSERT_LOCATION+': Document not valid');
  assert(IdSoapTestNodeValid(AParent, TdomNode), ASSERT_LOCATION+': Parent not valid');
  assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': Method not valid');
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_NAME, AMethod.Name));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_INHERITED_METHOD, IdEnumToString(TypeInfo(Boolean), ord(AMethod.InheritedMethod))));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_REQUEST_NAME, AMethod.RequestMessageName));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_RESPONSE_NAME, AMethod.ResponseMessageName));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_DOCUMENTATION, AMethod.Documentation));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_SOAPACTION, AMethod.SoapAction));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_SOAPOPTYPE, IdEnumToString(TypeInfo(TIdSoapEncodingMode), ord(AMethod.EncodingMode))));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_CALLINGCONVENTION, IdEnumToString(TypeInfo(TIdSoapCallingConvention), Ord(AMethod.CallingConvention))));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_METHODKIND, IdEnumToString(TypeInfo(TMethodKind), Ord(AMethod.MethodKind))));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_METHODSESSION, BoolToStr(AMethod.SessionRequired)));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_RESULTTYPE, AMethod.ResultType));
  AParent.AppendChild(BuildNamesAndTypes(ADoc, AMethod));
  SaveParamList(ADoc, AParent, ID_SOAP_ITI_XML_NODE_PARAMETER, AMethod.Parameters);
  SaveParamList(ADoc, AParent, ID_SOAP_ITI_XML_NODE_HEADER, AMethod.Headers);
  SaveParamList(ADoc, AParent, ID_SOAP_ITI_XML_NODE_RESPHEADER, AMethod.RespHeaders);
end;

procedure TIdSoapITIXMLStreamer.SaveParameter(ADoc: TDomDocument; AParent: TdomNode; AParameter: TIdSoapITIParameter);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.SaveParameter';
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(Assigned(ADoc), ASSERT_LOCATION+': Document not valid');
  assert(IdSoapTestNodeValid(AParent, TdomNode), ASSERT_LOCATION+': Parent not valid');
  assert(AParameter.TestValid(TIdSoapITIParameter), ASSERT_LOCATION+': Parameter not valid');
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_NAME, AParameter.Name));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_DOCUMENTATION, AParameter.Documentation));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_PARAMFLAG, IdEnumToString(TypeInfo(TParamFlag), Ord(AParameter.ParamFlag))));
  AParent.appendChild(NewTextNode(ADoc, ID_SOAP_ITI_XML_NODE_NAMEOFTYPE, AParameter.NameOfType));
  AParent.AppendChild(BuildNamesAndTypes(ADoc, AParameter));
end;

procedure TIdSoapITIXMLStreamer.SaveToStream(AITI: TIdSoapITI; AStream: TStream);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.SaveToStream';
var
  FDomImpl: TDomImplementation;
  FDom: TdomDocument;
  i: Integer;
  LElement: TdomElement;
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI is not valid');
  IdRequire(assigned(AStream), ASSERT_LOCATION+': Stream is not assigned');
  FDomImpl := TDomImplementation.Create(NIL);
  try
    FDom := FDomImpl.createDocument(ID_SOAP_ITI_XML_NODE_ITI, NIL);
    try
      FDom.documentElement.appendChild(NewTextNode(FDom, ID_SOAP_ITI_XML_NODE_VERSION, IntToStr(ID_SOAP_ITI_XML_STREAM_VERSION)));
      FDom.documentElement.appendChild(NewTextNode(FDom, ID_SOAP_ITI_XML_NODE_DOCUMENTATION, AITI.Documentation));
      FDom.documentElement.AppendChild(BuildNamesAndTypes(FDom, AITI));
      for i := 0 to AITI.Interfaces.Count - 1 do
        begin
        LElement := FDom.createElement(ID_SOAP_ITI_XML_NODE_INTERFACE);
        FDom.documentElement.appendChild(LElement);
        SaveInterface(FDom, LElement, AITI.Interfaces.Objects[i] as TIdSoapITIInterface);
        end;
      FDom.writeCodeAsUTF8(AStream);
    finally
      FDomImpl.freeDocument(FDom);
      end;
  finally
    FreeAndNil(FDomImpl);
    end;
end;

function GetChildText(ANode: TDomNode; AChildName: String): String;
const ASSERT_LOCATION = 'IdSoapITIXml.GetChildText';
begin
  assert(IdSoapTestNodeValid(ANode, TDomNode), ASSERT_LOCATION+': Attempt to read "' + AChildName + '" from an invalid Node');
  ANode := ANode.getFirstChildElement(AChildName);
  assert(IdSoapTestNodeValid(ANode, TDomNode), ASSERT_LOCATION+': Node "' + AChildName + '" not found/not valid');
  Result := ANode.TextContent;
end;

procedure TIdSoapITIXMLStreamer.ReadNamesAndTypes(AElement: TdomElement; AITIObject: TIdSoapITIBaseObject);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.ReadNamesAndTypes';
var
  LElement : TdomElement;
  sl, sr : string;
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': Parameter not valid');
  if AElement <> nil then
    begin
    LElement := AElement.getFirstChildElement('Name');
    while assigned(LElement) do
      begin
      AITIObject.DefineNameReplacement(GetChildText(LElement, 'ClassName'), GetChildText(LElement, 'PascalName'), GetChildText(LElement, 'SoapName'));
      LElement := AElement.getNextSiblingElement('Name');
      end;
    LElement := AElement.getFirstChildElement('Type');
    while assigned(LElement) do
      begin
      AITIObject.DefineTypeReplacement(GetChildText(LElement, 'PascalName'), GetChildText(LElement, 'SoapName'), GetChildText(LElement, 'Namespace'));
      LElement := AElement.getNextSiblingElement('Type');
      end;
    LElement := AElement.getFirstChildElement('Enum');
    while assigned(LElement) do
      begin
      SplitString(GetChildText(LElement, 'ClassName'), '.', sl, sr);
      AITIObject.DefineEnumReplacement(sl, sr, GetChildText(LElement, 'SoapName'));
      LElement := AElement.getNextSiblingElement('Enum');
      end;
    end;
end;


procedure TIdSoapITIXMLStreamer.ReadInterface(AITI: TIdSoapITI; ANode: TdomNode);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.ReadInterface';
var
  LInterface: TIdSoapITIInterface;
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI not valid');
  assert(IdSoapTestNodeValid(ANode, TdomNode), ASSERT_LOCATION+': Node not valid');
  LInterface := TIdSoapITIInterface.Create(AITI);
  LInterface.Name := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_NAME);
  LInterface.UnitName := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_UNITNAME);
  LInterface.Documentation := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_DOCUMENTATION);
  LInterface.Namespace := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_NAMESPACE);
  AITI.AddInterface(LInterface);
  LInterface.GUID := StringToGUID(GetChildText(ANode, ID_SOAP_ITI_XML_NODE_GUID));
  LInterface.Ancestor := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_ANCESTOR);
  ReadNamesAndTypes(ANode.getFirstChildElement('NamesAndTypes'), LInterface);
  ANode := ANode.getFirstChildElement(ID_SOAP_ITI_XML_NODE_METHOD);
  while ANode <> NIL do
    begin
    ReadMethod(LInterface, ANode);
    ANode := ANode.getNextSiblingElement(ID_SOAP_ITI_XML_NODE_METHOD);
    end;
end;

procedure TIdSoapITIXMLStreamer.ReadMethod(AInterface: TIdSoapITIInterface; ANode: TdomNode);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.ReadMethod';
var
  LMethod: TIdSoapITIMethod;
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(AInterface.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': Interface not valid');
  assert(IdSoapTestNodeValid(ANode, TdomNode), ASSERT_LOCATION+': Node not valid');
  LMethod := TIdSoapITIMethod.Create(AInterface.ITI, AInterface);
  LMethod.Name := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_NAME);
  LMethod.RequestMessageName := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_REQUEST_NAME);
  LMethod.ResponseMessageName := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_RESPONSE_NAME);
  LMethod.Documentation := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_DOCUMENTATION);
  LMethod.SoapAction := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_SOAPACTION);
  if ANode.getFirstChildElement(ID_SOAP_ITI_XML_NODE_SOAPOPTYPE) <> nil then
    begin
    LMethod.EncodingMode := TIdSoapEncodingMode(IdStringToEnum(TypeInfo(TIdSoapEncodingMode), GetChildText(ANode, ID_SOAP_ITI_XML_NODE_SOAPOPTYPE)));
    end;

  AInterface.AddMethod(LMethod);
  LMethod.CallingConvention := TIdSoapCallingConvention(IdStringToEnum(TypeInfo(TIdSoapCallingConvention), GetChildText(ANode, ID_SOAP_ITI_XML_NODE_CALLINGCONVENTION)));
  LMethod.MethodKind := TMethodKind(IdStringToEnum(TypeInfo(TMethodKind), GetChildText(ANode, ID_SOAP_ITI_XML_NODE_METHODKIND)));
  LMethod.SessionRequired := StrToBool(GetChildText(ANode, ID_SOAP_ITI_XML_NODE_METHODSESSION));
  LMethod.ResultType := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_RESULTTYPE);
  ReadNamesAndTypes(ANode.getFirstChildElement('NamesAndTypes'), LMethod);

  ReadParamList(LMethod, LMethod.Parameters, ANode, ID_SOAP_ITI_XML_NODE_PARAMETER);
  ReadParamList(LMethod, LMethod.Headers, ANode, ID_SOAP_ITI_XML_NODE_HEADER);
  ReadParamList(LMethod, LMethod.RespHeaders, ANode, ID_SOAP_ITI_XML_NODE_RESPHEADER);
end;

function TIdSoapITIXMLStreamer.ReadParameter(AMethod: TIdSoapITIMethod; ANode: TdomNode) : TIdSoapITIParameter;
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.ReadParameter';
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(AMethod.TestValid(TIdSoapITIMethod), ASSERT_LOCATION+': Method not valid');
  Assert(IdSoapTestNodeValid(ANode, TdomNode), ASSERT_LOCATION+': Node not valid');
  result := TIdSoapITIParameter.Create(AMethod.ITI, AMethod);
  result.Name := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_NAME);
  result.Documentation := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_DOCUMENTATION);
  result.ParamFlag := TParamFlag(IdStringToEnum(TypeInfo(TParamFlag), GetChildText(ANode, ID_SOAP_ITI_XML_NODE_PARAMFLAG)));
  result.NameOfType := GetChildText(ANode, ID_SOAP_ITI_XML_NODE_NAMEOFTYPE);
  ReadNamesAndTypes(ANode.getFirstChildElement('NamesAndTypes'), result);
end;

procedure TIdSoapITIXMLStreamer.ReadFromStream(AITI: TIdSoapITI; AStream: TStream);
const ASSERT_LOCATION = 'IdSoapITIXml.TIdSoapITIXMLStreamer.ReadFromStream';
var
  FDomImpl: TDomImplementation;
  FDom: TdomDocument;
  FParser: TXmlToDomParser;
  LNode: TdomNode;
begin
  Assert(Self.TestValid(TIdSoapITIXMLStreamer), ASSERT_LOCATION+': Self is not valid');
  assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': ITI not valid');
  assert(Assigned(AStream), ASSERT_LOCATION+': Node not valid');
  FDomImpl := TDomImplementation.Create(NIL);
  try
    FParser := TXmlToDomParser.Create(NIL);
    try
      FParser.DOMImpl := FDomImpl;
      FParser.streamToDom(AStream);
    finally
      FreeAndNil(FParser);
      end;
    FDom := (FDomImpl.documents.item(0) as TdomDocument);
    LNode := FDom.documentElement;
    if StrToIntDef(GetChildText(LNode, ID_SOAP_ITI_XML_NODE_VERSION), 0) <> ID_SOAP_ITI_XML_STREAM_VERSION then
      begin
      raise EIdSoapBadITIStore.Create(ASSERT_LOCATION+': '+RS_ERR_ITI_WRONG_VERSION+' '+IntToStr(ID_SOAP_ITI_XML_STREAM_VERSION) + ' / ' + GetChildText(LNode, ID_SOAP_ITI_XML_NODE_VERSION));
      end;
    AITI.Documentation := GetChildText(LNode, ID_SOAP_ITI_XML_NODE_DOCUMENTATION);
    ReadNamesAndTypes(LNode as TdomElement, AITI);
    LNode := LNode.getFirstChildElement(ID_SOAP_ITI_XML_NODE_INTERFACE);
    while LNode <> NIL do
      begin
      ReadInterface(AITI, LNode);
      LNode := LNode.getNextSiblingElement(ID_SOAP_ITI_XML_NODE_INTERFACE);
      end;
    AITI.Validate('xml');
  finally
    FreeAndNil(FDomImpl);
    end;
end;

procedure TIdSoapITIXMLStreamer.ReadParamList(AMethod: TIdSoapITIMethod; AParamList: TIdSoapITIParamList; ANode: TdomNode; AName : string);
begin
  ANode := ANode.getFirstChildElement(AName);
  while ANode <> NIL do
    begin
    AParamList.AddParam(ReadParameter(AMethod, ANode));
    ANode := ANode.getNextSiblingElement(AName);
    end;
end;

procedure TIdSoapITIXMLStreamer.SaveParamList(ADoc: TDomDocument; AParent: TdomNode; AItemName: String; AParamList: TIdSoapITIParamList);
var
  LElement: TdomElement;
  i: Integer;
begin
  for i := 0 to AParamList.Count - 1 do
    begin
    LElement := ADoc.createElement(AItemName);
    AParent.appendChild(LElement);
    SaveParameter(ADoc, LElement, AParamList.Param[i]);
    end;
end;

end.
