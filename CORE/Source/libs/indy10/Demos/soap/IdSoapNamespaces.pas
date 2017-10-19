{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15748: IdSoapNamespaces.pas 
{
{   Rev 1.3    20/6/2003 00:03:48  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.2    18/3/2003 11:02:56  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.1    25/2/2003 13:14:34  GGrieve
}
{
{   Rev 1.0    11/2/2003 20:34:40  GGrieve
}
{
IndySOAP: Namespace support for XML reading / writing

This is a workaround for missing namespace support in OpenXML
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  add support for ##any
  18-Mar 2003   Grahame Grieve                  Remove IDSOAP_USE_RENAMED_OPENXML
  25-Feb 2003   Grahame Grieve                  support for multiple XML implementations
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  13 Aug 2002   Grahame Grieve                  Improve Error messages
  16-Jul 2002   Grahame Grieve                  New OpenXML version - OpenXML handles namespaces when reading
  29-May 2002   Grahame Grieve                  Fix error message
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  09-Apr 2002   Grahame Grieve                  Fix for IDSOAP_USE_RENAMED_OPENXML not defined
  09-Apr 2002   Grahame Grieve                  First written
}


unit IdSoapNamespaces;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapDebug,
  IdSoapOpenXML,
  IdSoapXML;

const
  NO_DEF = false;
  DEF_OK = true;

type
  TIdSoapXmlNamespaceSupport = class (TIdBaseObject)
  private
    // name spaces are indexed either way
    FNameSpaces : TStringList;
    FUsedCodes : TStringList;
    FCodeList : TStringList;
    FDefaultNamespace : string;
  public
    constructor create;
    destructor destroy; override;
    property NameSpaces : TStringList read FNameSpaces;

    function GetNameSpaceCode(const ANameSpace : string; ADefaultValid : boolean ) : string;
    function DefineNamespace(const ANamespace : string; const ASuggestedCode: string): String;
    procedure DefineDefaultNamespace(Const ANamespace : string; AElement : TdomElement); overload;
    procedure DefineDefaultNamespace(Const ANamespace : string; AElement : TIdSoapXmlElement); overload;
    procedure UnDefineDefaultNamespace;

    procedure AddNamespaceDefinitions(AxmlElement : TdomElement); overload;
    procedure AddNamespaceDefinitions(AxmlElement : TIdSoapXmlElement); overload;
  end;

function ResolveXMLNamespaceCode(AElement : TdomElement; ANamespace, ALocation : string):string;
function LooseFindChildElement(AElement : TdomElement; AName : string):TdomElement;
function GetNamespacePrefix(const AQName : string):string;
procedure SplitNamespace(const AQname : string; var VNamespace, VName : string);

implementation

uses
  IdSoapExceptions,
  IdSoapResourceStrings,
  IdSoapUtilities,
  IdSoapConsts,
  SysUtils;

function ResolveXMLNamespaceCode(AElement : TdomElement; ANamespace, ALocation : string):string;
const ASSERT_LOCATION = 'IdSoapNamespaces.ResolveXMLNamespaceCode';
var
  i : integer;
  LAttr : TdomAttr;
begin
  assert(IdSoapTestNodeValid(AElement, TdomElement), ASSERT_LOCATION+': Element is not valid');
  assert(ANamespace <> '', ASSERT_LOCATION+': namespace is blank ('+ALocation+')');
  assert(ALocation <> '', ASSERT_LOCATION+': Location is blank ('+ALocation+')');

  result := '';
  for i := 0 to AElement.attributes.length - 1 do
    begin
    LAttr := AElement.Attributes.item(i) as TdomAttr;
    if (LAttr.namespaceURI = 'http://www.w3.org/2000/xmlns/') and
       (LAttr.localName = ANameSpace) then
      begin
      result := LAttr.textContent;
      break;
      end;
    end;
  if result = '' then
    begin
    if assigned(AElement.parentNode) and (AElement.parentNode is TdomElement) then
      begin
      result := ResolveXMLNamespaceCode(AElement.parentNode as TdomElement, ANamespace, ALocation);
      end
    else
      begin
      raise EIdSoapNamespaceProblem.CreateFmt(RS_ERR_SOAP_UNRESOLVABLE_NAMESPACE, [ANamespace, ALocation]);
      end;
    end;
end;

function LooseFindChildElement(AElement : TdomElement; AName : string):TdomElement;
const ASSERT_LOCATION = 'IdSoapNamespaces.LooseFindChildElement';
var
  LNode : TdomNode;
begin
  assert(IdSoapTestNodeValid(AElement, TdomElement), ASSERT_LOCATION+': Element is not valid');
  assert(AName <> '', ASSERT_LOCATION+': name is blank');

  LNode := AElement.firstChild;
  result := nil;
  while assigned(LNode) and not Assigned(result) do
    begin
    if (LNode is TdomElement) and ( AnsiSameText(LNode.nodeName, AName) or AnsiSameText(LNode.localName, AName)) then
      begin
      result := LNode as TdomElement;
      end
    else
      begin
      LNode := LNode.nextSibling;
      end;
    end;
end;

{ TIdSoapXmlNamespaceSupport }

constructor TIdSoapXmlNamespaceSupport.create;
const ASSERT_LOCATION = 'IdSoapNamespaces.TIdSoapXmlNamespaceSupport.create';
begin
  inherited;
  FNameSpaces := TStringList.create;
  FCodeList := TStringList.create;
  FUsedCodes := TStringList.create;
  FDefaultNamespace := '';
end;

destructor TIdSoapXmlNamespaceSupport.destroy;
const ASSERT_LOCATION = 'IdSoapNamespaces.TIdSoapXmlNamespaceSupport.destroy';
begin
  assert(Self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FCodeList);
  FreeAndNil(FUsedCodes);
  FreeAndNil(FNameSpaces);
  inherited;
end;

function TIdSoapXmlNamespaceSupport.GetNameSpaceCode(const ANameSpace: string; ADefaultValid : boolean): string;
const ASSERT_LOCATION = 'IdSoapNamespaces.TIdSoapXmlNamespaceSupport.GetNameSpaceCode';
var
  LIndex : integer;
begin
  assert(Self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': self is not valid');
  assert(ANameSpace <> '', ASSERT_LOCATION+': Name space is blank');
  assert(FNameSpaces <> nil, ASSERT_LOCATION+': AllNameSpacesByName is not valid');

  If ADefaultValid and (ANamespace = FDefaultNamespace) then
    begin
    result := '';
    end
  else if ANamespace = '##any' then
    begin
    result := '##any';
    end
  else
    begin
    LIndex := FNameSpaces.IndexOfName(ANameSpace);
    if LIndex = -1 then
      begin
      DefineNamespace(ANamespace, '');
      LIndex := FNameSpaces.IndexOfName(ANameSpace);
      assert(LIndex <> -1, ASSERT_LOCATION+': Namespace "'+ANameSpace+'" not defined?');
      end;
    result := copy(FNameSpaces[Lindex], Length(ANamespace)+2, MaxInt);
    FUsedCodes.Add(result);
    result := result + ':';
    end;
end;

function TIdSoapXmlNamespaceSupport.DefineNamespace(const ANamespace : string; const ASuggestedCode: string): String;
const ASSERT_LOCATION = 'IdSoapNamespaces.TIdSoapXmlNamespaceSupport.DefineNamespace';
var
  i : integer;
begin
  assert(self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': Self is not valid');
  assert(ANamespace <> '', ASSERT_LOCATION+': Namespace = ''''');
  assert(FNameSpaces <> nil, ASSERT_LOCATION+': AllNameSpacesByName is not valid');

  if FNameSpaces.IndexOfName(ANamespace) > -1 then
    begin
    result := FNameSpaces.Values[ANamespace]
    end
  else if ANamespace[1] = '#' then
    begin
    result := ANameSpace;
    end
  else
    begin
    if ASuggestedCode = '' then
      begin
      result := ID_SOAP_DEFAULT_NAMESPACE_CODE;
      end
    else
      begin
      result := ASuggestedCode;
      end;
    i := 1;
    while (i < 10) and (FCodeList.IndexOf(result) > -1) do
      begin
      inc(i);
      if result[length(result)] in ['0'..'8'] then
        begin
        result[length(result)] := chr(ord(result[length(result)])+1)
        end
      else
        begin
        result := result + '1';
        end;
      end;
    FNameSpaces.Values[ANamespace] := result;
    FCodeList.Add(result);
    end;
end;

procedure TIdSoapXmlNamespaceSupport.AddNamespaceDefinitions(AxmlElement: TdomElement);
const ASSERT_LOCATION = 'IdSoapNamespaces.TIdSoapXmlNamespaceSupport.AddNamespaceDefinitions';
var
  i : integer;
  n, v : string;
begin
  assert(self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': self is not valid');
  assert(IdSoapTestNodeValid(AxmlElement, TdomElement), ASSERT_LOCATION+': xmlElement is not valid');
  assert(FNameSpaces <> nil, ASSERT_LOCATION+': AllNameSpacesByName is not valid');
  for i := 0 to FNameSpaces.Count -1 do
    begin
    n := FNameSpaces.Names[i];
    v := copy(FNameSpaces[i], Length(n)+2, MaxInt);
    if FUsedCodes.indexof(v) > -1 then // check that it was actually used
      begin
      AxmlElement.setAttribute(ID_SOAP_NAME_XML_XMLNS+':'+v, n);
      end;
    end;
end;

procedure TIdSoapXmlNamespaceSupport.AddNamespaceDefinitions(AxmlElement: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapNamespaces.TIdSoapXmlNamespaceSupport.AddNamespaceDefinitions';
var
  i : integer;
  n, v : string;
begin
  assert(self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': self is not valid');
  assert(AxmlElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': xmlElement is not valid');
  assert(FNameSpaces <> nil, ASSERT_LOCATION+': AllNameSpacesByName is not valid');
  for i := 0 to FNameSpaces.Count -1 do
    begin
    n := FNameSpaces.Names[i];
    v := copy(FNameSpaces[i], Length(n)+2, MaxInt);
    if FUsedCodes.indexof(v) > -1 then // check that it was actually used
      begin
      AxmlElement.setAttribute(ID_SOAP_NAME_XML_XMLNS+':'+v, n);
      end;
    end;
end;


procedure TIdSoapXmlNamespaceSupport.DefineDefaultNamespace(const ANamespace: string; AElement: TdomElement);
const ASSERT_LOCATION = 'IdSoapNamespaces.DefineDefaultNamespace';
begin
  assert(self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': self is not valid');
  assert(ANamespace <> '', ASSERT_LOCATION+': namespace is blank');
  assert(IdSoapTestNodeValid(AElement, TdomElement), ASSERT_LOCATION+': Element is not valid');
  FDefaultNamespace := ANamespace;
  AElement.setAttribute(ID_SOAP_NAME_XML_XMLNS, ANamespace);
end;

procedure TIdSoapXmlNamespaceSupport.DefineDefaultNamespace(const ANamespace: string; AElement: TIdSoapXmlElement);
const ASSERT_LOCATION = 'IdSoapNamespaces.DefineDefaultNamespace';
begin
  assert(self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': self is not valid');
  assert(ANamespace <> '', ASSERT_LOCATION+': namespace is blank');
  assert(AElement.TestValid(TIdSoapXmlElement), ASSERT_LOCATION+': Element is not valid');
  FDefaultNamespace := ANamespace;
  AElement.setAttribute(ID_SOAP_NAME_XML_XMLNS, ANamespace);
end;

procedure TIdSoapXmlNamespaceSupport.UnDefineDefaultNamespace;
const ASSERT_LOCATION = 'IdSoapNamespaces.UnDefineDefaultNamespace';
begin
  assert(self.TestValid(TIdSoapXmlNamespaceSupport), ASSERT_LOCATION+': self is not valid');
  FDefaultNamespace := '';
end;

function GetNamespacePrefix(const AQName : string):string;
var
  i : integer;
begin
  i := pos(':', AQname);
  if i > 0 then
    begin
    result := copy(AQname, 1, i-1);
    end
  else
    begin
    result := '';
    end;
end;

procedure SplitNamespace(const AQname : string; var VNamespace, VName : string);
var
  i : integer;
begin
  i := pos(':', AQname);
  if i > 0 then
    begin
    VNamespace := copy(AQname, 1, i-1);
    VName := copy(AQname, i+1, $FFFF);
    end
  else
    begin
    VNamespace := '';
    VName := AQname;
    end;
end;


end.




