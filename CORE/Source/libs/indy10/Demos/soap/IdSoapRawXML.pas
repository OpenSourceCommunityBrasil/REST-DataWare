{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  17341: IdSoapRawXML.pas 
{
{   Rev 1.0    18/3/2003 11:22:52  GGrieve
}
{
IndySOAP: IdSoapRawXML

A type that exposes the Raw XML to the SOAP Service


{
Version History:
  18-Mar 2003   Grahame Grieve                  First defined
}

unit IdSoapRawXML;

interface

{$I IdSoapDefines.inc}

uses
  IdGlobal,
  IdSoapRpcPacket,
  IdSoapRpcUtils,
  IdSoapTypeRegistry,
  IdSoapXML;

type
  TIdSoapRawXML = class (TIdBaseSoapableClass)
  private
    FOwnsDom : boolean;
    FDom : TIdSoapXmlDom;
    FXML: TIdSoapXmlElement;
    FTypeNamespace : string;
    FTypeName : string;
  public
    destructor Destroy; override;
    procedure InitRead(AOwnsDom: boolean; ADom : TIdSoapXmlDom; AElement : TIdSoapXmlElement);
    procedure Init(AXmlProvider : TIdSoapXmlProvider = xpOpenXML);
    property XML : TIdSoapXmlElement read FXML;
    property TypeNamespace : string read FTypeNamespace write FTypeNamespace;
    property TypeName : string read FTypeName write FTypeName;
  end;

  TIdSoapRawXMLHandler = class (TIdSoapSimpleClassHandler)
  public
    function GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject; override;
    procedure DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject); override;
    function GetNamespace : string; override;
    function GetTypeName : string; override;
  end;


implementation

uses
  Classes,
  IdSoapRpcBin,
  SysUtils;

const
  ASSERT_UNIT = 'IdSoapRawXml';

{ TIdSoapRawXML }

destructor TIdSoapRawXML.Destroy;
const ASSERT_LOCATION = ASSERT_UNIT + '.TIdSoapRawXML.Destroy';
begin
  assert(self.TestValid(TIdSoapRawXML), ASSERT_LOCATION+': self is not valid');
  if FOwnsDom then
    begin
    FreeAndNil(FDom);
    end;
  inherited;
end;

procedure TIdSoapRawXML.Init(AXmlProvider: TIdSoapXmlProvider = xpOpenXML);
const ASSERT_LOCATION = ASSERT_UNIT + '.TIdSoapRawXML.Init';
begin
  assert(self.TestValid(TIdSoapRawXML), ASSERT_LOCATION+': self is not valid');
  assert(not assigned(FDom), ASSERT_LOCATION+': Dom already exists - Cannot call Init twice');
  FOwnsDom := true;
  FDom := IdSoapDomFactory(AXmlProvider);
  FDom.StartBuild('notused'); // create a root element etc
  FXML := FDom.Root;
end;

procedure TIdSoapRawXML.InitRead(AOwnsDom: boolean; ADom: TIdSoapXmlDom; AElement: TIdSoapXmlElement);
const ASSERT_LOCATION = ASSERT_UNIT + '.TIdSoapRawXML.InitRead';
begin
  assert(self.TestValid(TIdSoapRawXML), ASSERT_LOCATION+': self is not valid');
  assert(not assigned(FDom), ASSERT_LOCATION+': Dom already exists - Cannot call Init twice');
  FOwnsDom := AOwnsDom;
  FDom := ADom;
  FXML := AElement;
end;

{ TIdSoapRawXMLHandler }

function TIdSoapRawXMLHandler.GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject;
const ASSERT_LOCATION = ASSERT_UNIT + '.TIdSoapRawXML.InitRead';
var
  LRes : TIdSoapRawXML;
  LDom : TIdSoapXmlDom;
  LElem : TIdSoapXmlElement;
  LTypeNS : string;
  LType : string;
  LOwnsDOM : boolean;
begin
  assert(self.TestValid(TIdSoapRawXMLHandler), ASSERT_LOCATION+': self is not valid');
  assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': reader is not valid');
  assert((ANode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');

  if AReader.GetXMLElement(ANode, AName, LOwnsDOM, LDom, LElem, LTypeNS, LType) then
    begin
    LRes := TIdSoapRawXML.create;
    result := LRes;
    LRes.InitRead(LOwnsDOM, LDom, LElem);
    LRes.TypeNamespace := LTypeNS;
    LRes.TypeName := LType;
    AReader.WantGarbageCollect := true;
    end
  else
    begin
    result := nil;
    end;
end;


procedure TIdSoapRawXMLHandler.DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject);
const ASSERT_LOCATION = ASSERT_UNIT + '.TIdSoapRawXML.InitRead';
begin
  assert(self.TestValid(TIdSoapRawXMLHandler), ASSERT_LOCATION+': self is not valid');
  assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': writer is not valid');
  assert((ANode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');

  if assigned(AObj) then
    begin
    AWriter.DefineParamXML(ANode, AName, (AObj as TIdSoapRawXML).XML, (AObj as TIdSoapRawXML).FTypeNamespace, (AObj as TIdSoapRawXML).FTypeName);
    end;
end;

function TIdSoapRawXMLHandler.GetNamespace: string;
begin
  result := '##any';
end;

function TIdSoapRawXMLHandler.GetTypeName: string;
begin
  result := 'any'
end;

initialization
  IdSoapRegisterType(TypeInfo(TIdSoapRawXML));
  IdSoapRegisterSpecialType('TIdSoapRawXML', TIdSoapRawXMLHandler);
end.

