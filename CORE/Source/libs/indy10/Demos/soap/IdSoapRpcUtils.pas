{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15766: IdSoapRpcUtils.pas
{
{   Rev 1.4    23/6/2003 15:11:26  GGrieve
{ missed comments
}
{
{   Rev 1.2    20/6/2003 00:04:04  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.1    18/3/2003 11:03:44  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:36:04  GGrieve
}
{
IndySOAP: This unit provides Packet Encoding/DEcoding Utilities

}

{
Version History:
  23-Jun 2003   Grahame Grieve                  Fix THexStream bug
  19-Jun 2003   Grahame Grieve                  better error checking on QNames
  18-Mar 2003   Grahame Grieve                  Move Special class support to here from idSoapRpcPacket (circular unit dependency issues)
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  24-Jul 2002   Grahame Grieve                  Restructure Packet handlers to change Namespace Policy
  22-Jul 2002   Grahame Grieve                  Soap Version 1.1 Conformance changes
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  04-Apr 2002   Andrew Cumming                  Fixed for D4
  04-Apr 2002   Grahame Grieve                  Mimetype support
  26-Mar 2002   Grahame Grieve                  Change names of constants
  14-Mar 2002   Grahame Grieve                  Namespace support
  07-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapRpcUtils;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapComponent,
  IdSoapDebug,
  IdSoapITI,
  IdSoapRpcPacket,
  IdSoapXML;

function CreatePacketReader (AMimeType : string; AStream : TStream; AVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider) : TIdSoapReader;

type
  TIdSoapSimpleClassHandler = class(TIdBaseObject)
  Public
    function GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject; virtual; abstract;
    procedure DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject); virtual; abstract;
    function GetNamespace : string; virtual; abstract;
    function GetTypeName : string; virtual; abstract;
  end;

  TIdSoapSimpleClassHandlerClass = class of TIdSoapSimpleClassHandler;

function IsSpecialClass(AName : string):boolean;
function IdSoapSpecialType(AClassName: String): TIdSoapSimpleClassHandler;
procedure IdSoapRegisterSpecialType(AClassName : string; AHandler : TIdSoapSimpleClassHandlerClass);

implementation

uses
  IdSoapConsts,
  IdSoapRpcBin,
  IdSoapRpcXML,
  IdSoapTypeRegistry,
  IdSoapUtilities,
  SysUtils;

var
  GSpecialTypes : TIdStringList;

function CreatePacketReader (AMimeType : string; AStream : TStream; AVersion : TIdSoapVersion; AXmlProvider: TIdSoapXmlProvider): TIdSoapReader;
const ASSERT_LOCATION = 'IdSoapRpcUtils.CreatePacketReader';
var
  LPos : Int64;
  LMagic : Cardinal;
  LJunk : string;
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  assert(AStream.Size - AStream.position > 0, ASSERT_LOCATION+': Stream is empty');
  SplitString(AMimeType, ';', AMimeType, LJunk);
  if AnsiSameText(AMimeType, ID_SOAP_HTTP_BIN_TYPE) then
    begin
    result := TIdSoapReaderBin.create(AVersion, AXMLProvider);
    end
  else if AnsiSameText(AMimeType, ID_SOAP_HTTP_SOAP_TYPE) then
    begin
    result := TIdSoapReaderXML.create(AVersion, AXmlProvider);
    end
  else
    // check for text/plain, text/html? ??errors
    begin
    // well we didn't recognise the type, so we'll see if we recognise it
    LPos := AStream.Position;
    AStream.Read(LMagic, sizeof(Cardinal));
    AStream.Position := LPos;
    if LMagic = ID_SOAP_BIN_MAGIC then
      begin
      result := TIdSoapReaderBin.create(AVersion, AXmlProvider);
      end
    else
      begin
      // possible future to do: do not leave it up to the XML reader to decide whether
      // stream is valid xml or not
      result := TIdSoapReaderXML.create(AVersion, AXmlProvider);
      end;
    end;
end;

type
  TIdSoapSimpleBinary = class (TIdSoapSimpleClassHandler)
  private
    FClass : TClass;
  public
    constructor create(AClass : TClass);
    function GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject; override;
    procedure DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject); override;
    function GetNamespace : string; override;
    function GetTypeName : string; override;
  end;

  TIdSoapQNameHandler = class (TIdSoapSimpleClassHandler)
  public
    function GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject; override;
    procedure DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject); override;
    function GetNamespace : string; override;
    function GetTypeName : string; override;
  end;

  TIdSoapSimpleRegistered = class (TIdSoapSimpleClassHandler)
  private
    FClass : TIdSoapSimpleClassType;
  public
    constructor create(AClass : TIdSoapSimpleClassType);
    function GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject; override;
    procedure DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject); override;
    function GetNamespace : string; override;
    function GetTypeName : string; override;
  end;

// see if we have a class that requires special treatment
function IdSoapSpecialType(AClassName: String): TIdSoapSimpleClassHandler;
const ASSERT_LOCATION = 'IdSoapRpcUtils.IdSoapSpecialType';
var
  LIndex : integer;
  LClass : TIdSoapSimpleClassType;
begin
  if AClassName = 'TStream' then { do not localize }
    begin
    Result := TIdSoapSimpleBinary.Create(TStream);
    end
  else if AClassName = 'THexStream' then { do not localize }
    begin
    Result := TIdSoapSimpleBinary.Create(THexStream);
    end
  else if GSpecialTypes.find(AClassName, LIndex) then
    begin
    Result := TIdSoapSimpleClassHandlerClass(GSpecialTypes.Objects[LIndex]).Create;
    end
  else
    begin
    LClass := IdSoapGetSimpleClass(AClassName);
    if assigned(LClass) then
      begin
      result := TIdSoapSimpleRegistered.create(LClass);
      end
    else
      begin
      result := nil;
      end;
    end;
end;

procedure IdSoapRegisterSpecialType(AClassName : string; AHandler : TIdSoapSimpleClassHandlerClass);
const ASSERT_LOCATION = 'IdSoapRpcUtils.IdSoapRegisterSpecialType';
begin
  assert(AClassName <> '', ASSERT_LOCATION+': classname is not valid');
  assert(AHandler <> nil, ASSERT_LOCATION+': handler is not valid');
  assert(GSpecialTypes.indexOf(AClassName) = -1, ASSERT_LOCATION+': Attempt to register duplicate class name "'+AClassName+'"');
  GSpecialTypes.AddObject(AClassName, TObject(AHandler));
end;


{ TIdSoapSimpleBinary }

constructor TIdSoapSimpleBinary.create(AClass: TClass);
begin
  inherited create;
  FClass := AClass;
end;

procedure TIdSoapSimpleBinary.DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject);
const ASSERT_LOCATION = 'IdSoapRpcPacket.TIdSoapSimpleBinary.DefineParam';
begin
  assert(self.TestValid(TIdSoapSimpleBinary), ASSERT_LOCATION + ': Attempt to use an Invalid TIdSoapSpecialType');
  assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': Writer is not valid');
  assert((ANode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');
  // no check Class

  if FClass = TStream then
    begin
    if Assigned(AObj) then
      begin
      assert(AObj is TStream, ASSERT_LOCATION + ': Attempt to use an Invalid TStream');
      AWriter.DefineParamBinaryBase64(ANode, AName, AObj as TStream);  // the debugger may displays it wrong but its correct
      end
    else
      begin
      AWriter.DefineGeneralParam(ANode, True, AName, '', ID_SOAP_NS_SCHEMA_2001, ID_SOAP_XSI_TYPE_BASE64BINARY);
      end;
    end
  else if FClass = THexStream then
    begin
    if Assigned(AObj) then
      begin
      assert(AObj is THexStream, ASSERT_LOCATION + ': Attempt to use an Invalid TStream');
      AWriter.DefineParamBinaryHex(ANode, AName, AObj as THexStream);  // the debugger may displays it wrong but its correct
      end
    else
      begin
      AWriter.DefineGeneralParam(ANode, true, AName, '', ID_SOAP_NS_SCHEMA_2001, ID_SOAP_XSI_TYPE_HEXBINARY);
      end;
    end
  else
    begin
    assert(false, ASSERT_LOCATION+': Unaccaptable type '+FClass.ClassName);
    end;
end;

function TIdSoapSimpleBinary.GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject;
const ASSERT_LOCATION = 'IdSoapRpcPacket.TIdSoapSimpleBinary.GetParam';
begin
  assert(self.TestValid(TIdSoapSimpleBinary), ASSERT_LOCATION + ': Attempt to use an Invalid TIdSoapSpecialType');
  assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': Writer is not valid');
  assert((ANode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');

  Result := NIL;
  if AReader.ParamExists[ANode, AName] then
    begin
    if FClass = TStream then
      begin
      Result := AReader.ParamBinaryBase64[ANode, AName];
      end
    else if FClass = THexStream then
      begin
      Result := AReader.ParamBinaryHex[ANode, AName];
      end
    else
      begin
      assert(false, ASSERT_LOCATION+': Unaccaptable type '+FClass.ClassName);
      end;
    end;
end;

function TIdSoapSimpleBinary.GetNamespace: string;
begin
  result := ID_SOAP_NS_SCHEMA_2001;
end;

function TIdSoapSimpleBinary.GetTypeName: string;
begin
  if FClass = TStream then
    begin
    result := ID_SOAP_XSI_TYPE_BASE64BINARY;
    end
  else
    begin
    result := ID_SOAP_XSI_TYPE_HEXBINARY;
    end;
end;

{ TIdSoapSimpleRegistered }

constructor TIdSoapSimpleRegistered.create(AClass: TIdSoapSimpleClassType);
begin
  inherited create;
  FClass := AClass;
end;

procedure TIdSoapSimpleRegistered.DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject);
const ASSERT_LOCATION = 'IdSoapRpcPacket.TIdSoapSimpleRegistered.DefineParam';
var
  LObj : TIdSoapSimpleClass;
begin
  assert(self.TestValid(TIdSoapSimpleRegistered), ASSERT_LOCATION + ': Attempt to use an Invalid TIdSoapSpecialType');
  assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': Writer is not valid');
  assert((ANode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');
  // no check Class
  if assigned(AObj) then
    begin
    assert(AObj is FClass, ASSERT_LOCATION+': Type Mismatch. Expected '+FClass.ClassName+', found '+AObj.ClassName);
    assert(AObj is TIdSoapSimpleClass, ASSERT_LOCATION+': Type Mismatch. Expected '+FClass.ClassName+', found '+AObj.ClassName);
    LObj := AObj as TIdSoapSimpleClass;
    AWriter.DefineGeneralParam(ANode, False, AName, LObj.WriteToXML, LObj.GetNamespace, LObj.GetTypeName);
    end
  else
    begin
    AWriter.DefineGeneralParam(ANode, True, AName, '', FClass.GetNamespace, FClass.GetTypeName);
    end;
end;

function TIdSoapSimpleRegistered.GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject;
const ASSERT_LOCATION = 'IdSoapRpcPacket.TIdSoapSimpleRegistered.GetParam';
var
  LValue, LTypeNS, LType : string;
  LNil : boolean;
  LObj : TIdSoapSimpleClass;
begin
  assert(self.TestValid(TIdSoapSimpleRegistered), ASSERT_LOCATION + ': Attempt to use an Invalid TIdSoapSpecialType');
  assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': Writer is not valid');
  assert((ANode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');
  result := nil;
  if AReader.ParamExists[ANode, AName] then
    begin
    if AReader.GetGeneralParam(ANode, AName, LNil, LValue, LTypeNS, LType) and not LNil then
      begin
      LObj := FClass.Create;
      LObj.SetAsXML(LValue, LTypeNS, LType);
      result := LObj;
      end;
    end;
end;

function TIdSoapSimpleRegistered.GetNamespace: string;
begin
  result := FClass.GetNamespace;
end;

function TIdSoapSimpleRegistered.GetTypeName: string;
begin
  result := FClass.GetTypeName;
end;

{ TIdSoapQNameHandler }

procedure TIdSoapQNameHandler.DefineParam(AWriter: TIdSoapWriter; ANode: TIdSoapNode; const AName: String; AObj: TObject);
const ASSERT_LOCATION = 'IdSoapRpcPacket.TIdSoapQNameHandler.DefineParam';
var
  LQName : TIdSoapQName;
  LPrefix : string;
begin
  assert(self.TestValid(TIdSoapQNameHandler), ASSERT_LOCATION+': self is not valid');
  assert(AWriter.TestValid(TIdSoapWriter), ASSERT_LOCATION+': Writer is not valid');
  assert((Anode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');
  if assigned(AObj) then
    begin
    assert(TIdBaseObject(AObj).TestValid(TIdSoapQName), ASSERT_LOCATION+': QName is not valid ('+IntToHex(integer(AObj), 8)+')');
    LQName := AObj as TIdSoapQName;

    assert(LQName.Value <> '', ASSERT_LOCATION+': QName is not valid as the Value portion is blank');

    LPrefix := AWriter.DefineNamespace(LQName.Namespace);
    AWriter.DefineGeneralParam(ANode, False, AName, LPrefix+LQName.Value, ID_SOAP_NS_SCHEMA_2001, ID_SOAP_SCHEMA_QNAME);
    end;
end;

function TIdSoapQNameHandler.GetParam(AReader: TIdSoapReader; ANode: TIdSoapNode; const AName: String): TObject;
const ASSERT_LOCATION = 'IdSoapRpcPacket.TIdSoapQNameHandler.GetParam';
var
  s, LValue, LTypeNS, LType, LNs : string;
  LNil : boolean;
  LQName : TIdSoapQName;
begin
  assert(self.TestValid(TIdSoapQNameHandler), ASSERT_LOCATION+': self is not valid');
  assert(AReader.TestValid(TIdSoapReader), ASSERT_LOCATION+': Writer is not valid');
  assert((ANode = nil) or ANode.TestValid(TIdSoapNode), ASSERT_LOCATION+': Node is not valid');
  assert(AName <> '', ASSERT_LOCATION+': Name is not valid');

  result := nil;
  if AReader.ParamExists[ANode, AName] then
    begin
    if AReader.GetGeneralParam(ANode, AName, LNil, s, LTypeNS, LType) and not LNil then
      begin
      assert(((LTypeNS = '') and (LType = '')) or ((LTypeNS = ID_SOAP_NS_SCHEMA_2001) and (LType = ID_SOAP_SCHEMA_QNAME)),
          ASSERT_LOCATION+': Unexpected Type "{'+LTypeNS+'}'+LType+'" reading a xs:QName, "'+AName+'"');
      assert(pos(':', s) > 0, ASSERT_LOCATION+': When reading QName "'+AName+'", no namespace prefix was found (content = "'+s+'")');
      SplitString(s, ':', LNs, LValue);
      assert(LNs <> '', ASSERT_LOCATION+': When reading QName "'+AName+'", no namespace prefix part was found (content = "'+s+'")');
      assert(LValue <> '', ASSERT_LOCATION+': When reading QName "'+AName+'", no name part was found (content = "'+s+'")');
      LQName := TIdSoapQName.create;
      result := LQName;
      LQName.Value := LValue;
      LQname.Namespace := AReader.ResolveNamespace(ANode, AName, LNs);
      end;
    end;
end;

function TIdSoapQNameHandler.GetNamespace: string;
begin
  result := ID_SOAP_NS_SCHEMA_2001;
end;

function TIdSoapQNameHandler.GetTypeName: string;
begin
  result := ID_SOAP_XSI_TYPE_QNAME;
end;

function IsSpecialClass(AName : string):boolean;
var
  LHandler : TIdSoapSimpleClassHandler;
begin
  LHandler := IdSoapSpecialType(AName);
  result := assigned(LHandler);
  FreeAndNil(LHandler);

//  (AName = 'TStream') or (AName = 'THexStream') or (AName = 'TIdSoapDateTime') or (AName = 'TIdSoapDate') or (AName = 'TIdSoapTime');
end;


initialization
  GSpecialTypes := TIdStringList.create(false);
  GSpecialTypes.Sorted := true;
  GSpecialTypes.Duplicates := dupError;
  IdSoapRegisterSpecialType('TIdSoapQName', TIdSoapQNameHandler);
finalization
  FreeAndNil(GSpecialTypes);
end.

