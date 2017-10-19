{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15730: IdSoapITIBin.pas 
{
{   Rev 1.1    20/6/2003 00:03:22  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:33:40  GGrieve
}
{
IndySOAP: this unit knows how to save an ITI to a binary
stream using TWriter and read it back using TReader
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  Header support, ITI renaming support
  09-Oct 2002   Andrew Cumming                  Fixed bugs in inherited interfaces
  26-Sep 2002   Grahame Grieve                  Sessional Support
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  23-Aug 2002   Grahame Grieve                  Doc|Lit support
  21-Aug 2002   Grahame Grieve                  Refactor Namespacing *Again*. Marshalling layer handles type resolution, allow for name and type redefinition
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  19-May 2002   Andrew Cumming                  removed ole2 unit from uses
  10-May 2002   Andrew Cumming                  backed out Mods for text/xml option
   9-May 2002   Andrew Cumming                  Mods to allow you to state app/soap or text/xml
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  25-Apr 2002   Andrew Cumming                  Removing dependency on ole2 unit
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  04-Apr 2002   Grahame Grieve                  SoapAction and Namespace properties for Interfaces
  03-Apr 2002   Grahame Grieve                  Handle ITI Method Request and Response Names
  26-Mar 2002   Grahame Grieve                  Change names of constants
  22-Mar 2002   Grahame Grieve                  WSDL Documentation Support
  14-Mar 2002   Grahame Grieve                  Namespace support
   7-Mar 2002   Grahame Grieve                  Review assertions
  03-Feb 2002   Andrew Cumming                  Added D4 support
  25-Jan 2002   Grahame Grieve/Andrew Cumming   First release of IndySOAP
}

unit IdSoapITIBin;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
  IdSoapITI;

type
  TIdSoapITIBinStreamer = class(TIdSoapITIStreamingClass)
  private
    procedure WriteNamesAndTypes(AITIObject : TIdSoapITIBaseObject; AWriter : TWriter);
    procedure ReadNamesAndTypes(AITIObject : TIdSoapITIBaseObject; AReader : TReader; AVer : integer);

    procedure WriteParamList(AWriter : TWriter; AParams : TIdSoapITIParamList);
    procedure ReadParamList(AITI : TIdSoapITI; AMethod : TIdSoapITIMethod; AReader : TReader; AParams : TIdSoapITIParamList; AVer : Integer);

    procedure AddInterfaceMethodsToStream(AInheritedMethod: Boolean; AITI: TIdSoapITI; AInterface: TIdSoapITIInterface; AWriter: TWriter);
  Public
    procedure SaveToStream(AITI: TIdSoapITI; AStream: TStream); Override;
    procedure ReadFromStream(AITI: TIdSoapITI; AStream: TStream); Override;
  end;

implementation

{ TIdSoapITIBinStreamer }

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

procedure TIdSoapITIBinStreamer.ReadFromStream(AITI: TIdSoapITI; AStream: TStream);
const ASSERT_LOCATION = 'IdSoapITIBin.TIdSoapITIBinStreamer.ReadFromStream';
var
  LReader: TReader;
  LInterface: TIdSoapITIInterface;
  LMethod: TIdSoapITIMethod;
  LVer: Integer;
begin
  Assert(Self.TestValid(TIdSoapITIBinStreamer), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  Assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': AITI is not valid');
  Assert(AITI.Interfaces.Count = 0, ASSERT_LOCATION+': AITI is not empty');
  LReader := TReader.Create(AStream, 1024);
  try
    LVer := LReader.ReadInteger;
    if (LVer < ID_SOAP_ITI_BIN_STREAM_VERSION_OLDEST) or (LVer > ID_SOAP_ITI_BIN_STREAM_VERSION) then
      begin
      raise EIdSoapBadITIStore.Create(ASSERT_LOCATION+': '+ RS_ERR_ITI_WRONG_VERSION+ ' ' +  IntToStr(ID_SOAP_ITI_BIN_STREAM_VERSION)+' / '+IntToStr(LVer));
      end;
    AITI.Documentation := LReader.ReadString;
    if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_HEADERS then
      begin
      ReadNamesAndTypes(AITI, LReader, LVer);
      end;
    LReader.ReadListBegin;
    while not LReader.EndOfList do
      begin
      LInterface := TIdSoapITIInterface.Create(AITI);
      LInterface.Name := LReader.ReadString;
      LInterface.UnitName := LReader.ReadString;
      LInterface.Documentation := LReader.ReadString;
      LInterface.Namespace := LReader.ReadString;
      if LVer = ID_SOAP_ITI_BIN_STREAM_VERSION_OLDEST then
        begin
        LReader.ReadString;
        end;
      if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_NAMES then
        begin
        ReadNamesAndTypes(LInterface, LReader, LVer);
        end;
      AITI.AddInterface(LInterface);
      LReader.ReadListBegin;
      while not LReader.EndOfList do
        begin
        LMethod := TIdSoapITIMethod.Create(AITI, LInterface);
        LMethod.Name := LReader.ReadString;
        if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_INTF_FIX then
          begin
          LMethod.InheritedMethod := LReader.ReadBoolean;
          end;
        LMethod.RequestMessageName := LReader.ReadString;
        LMethod.ResponseMessageName := LReader.ReadString;
        LMethod.Documentation := LReader.ReadString;
        if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_SOAPACTION then
          begin
          LMethod.SoapAction := LReader.ReadString;
          if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_SOAPOP then
            begin
            LMethod.EncodingMode := TIdSoapEncodingMode(LReader.ReadInteger);
            if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_SESSION then
              begin
              LMethod.SessionRequired := LReader.ReadBoolean;
              end;
            end;
          end;
        if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_NAMES then
          begin
          ReadNamesAndTypes(LMethod, LReader, LVer);
          end;
        LInterface.AddMethod(LMethod);
        ReadParamList(AITI, LMethod, LReader, LMethod.Parameters, LVer);
        if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_HEADERS then
          begin
          ReadParamList(AITI, LMethod, LReader, LMethod.Headers, LVer);
          ReadParamList(AITI, LMethod, LReader, LMethod.RespHeaders, LVer);
          end;
        LMethod.CallingConvention := TIdSoapCallingConvention(LReader.ReadInteger);
        LMethod.MethodKind := TMethodKind(LReader.ReadInteger);
        LMethod.ResultType := LReader.ReadString;
        end;
      LReader.ReadListEnd;
      LInterface.Ancestor := LReader.ReadString;
      if LVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_INTF_FIX then
        begin
        LInterface.IsInherited := LReader.ReadBoolean;
        end;
      LInterface.GUID := StringToGUID(LReader.ReadString);
      end;
    LReader.ReadListEnd;
  finally
    FreeAndNil(LReader);
    end;
  AITI.Validate('BIN');
end;

procedure TIdSoapITIBinStreamer.AddInterfaceMethodsToStream(AInheritedMethod: Boolean; AITI: TIdSoapITI; AInterface: TIdSoapITIInterface; AWriter: TWriter);
const ASSERT_LOCATION = 'IdSoapITIBin.TIdSoapITIBinStreamer.AddInterfaceMethodsToStream';
var
  LMethodIndex: Integer;
  LIndex: Integer;
  LMethod: TIdSoapITIMethod;
  LInheritedInterface: Boolean;

begin
  Assert(Self.TestValid(TIdSoapITIBinStreamer), ASSERT_LOCATION+': self is not valid');
  // can't test AInheritedMethod
  Assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': AITI is not valid');
  Assert(AInterface.TestValid(TIdSoapITIInterface), ASSERT_LOCATION+': AInterface is not valid');
  Assert(Assigned(AWriter), ASSERT_LOCATION+': AWriter is not valid');
  LInheritedInterface := not AnsiSameText(AInterface.Ancestor,ID_SOAP_INTERFACE_BASE_NAME);
  if LInheritedInterface then
    begin
    Assert(AITI.Interfaces.Find(AInterface.Ancestor,LIndex),ASSERT_LOCATION+': Unable to locate interface ' + AInterface.Name + ' in ITI');
    AddInterfaceMethodsToStream(True,AITI,AITI.Interfaces.Objects[LIndex] as TIdSoapITIInterface,AWriter);
    end;
  for LMethodIndex := 0 to AInterface.Methods.Count - 1 do
    begin
    LMethod := AInterface.Methods.Objects[LMethodIndex] as TIdSoapITIMethod;
    AWriter.WriteString(LMethod.Name);
    AWriter.WriteBoolean(AInheritedMethod);
    AWriter.WriteString(LMethod.RequestMessageName);
    AWriter.WriteString(LMethod.ResponseMessageName);
    AWriter.WriteString(LMethod.Documentation);
    AWriter.WriteString(LMethod.SoapAction);
    AWriter.WriteInteger(ord(LMethod.EncodingMode));
    AWriter.WriteBoolean(LMethod.SessionRequired);
    WriteNamesAndTypes(LMethod, AWriter);
    WriteParamList(AWriter, LMethod.Parameters);
    WriteParamList(AWriter, LMethod.Headers);
    WriteParamList(AWriter, LMethod.RespHeaders);
    AWriter.WriteInteger(Ord(LMethod.CallingConvention));
    AWriter.WriteInteger(Ord(LMethod.MethodKind));
    AWriter.WriteString(LMethod.ResultType);
    end;
end;

procedure TIdSoapITIBinStreamer.SaveToStream(AITI: TIdSoapITI; AStream: TStream);
const ASSERT_LOCATION = 'IdSoapITIBin.TIdSoapITIBinStreamer.SaveToStream';
var
  LWriter: TWriter;
  LInterface: TIdSoapITIInterface;
  LInterfaceIndex: Integer;
begin
  Assert(Self.TestValid(TIdSoapITIBinStreamer), ASSERT_LOCATION+': self is not valid');
  Assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  Assert(AITI.TestValid(TIdSoapITI), ASSERT_LOCATION+': AITI is not valid');
  LWriter := TWriter.Create(AStream, 1024);
  try
    LWriter.WriteInteger(ID_SOAP_ITI_BIN_STREAM_VERSION);
    LWriter.WriteString(AITI.Documentation);
    WriteNamesAndTypes(AITI, LWriter);
    LWriter.WriteListBegin;
    for LInterfaceIndex := 0 to AITI.Interfaces.Count - 1 do
      begin
      LInterface := AITI.Interfaces.Objects[LInterfaceIndex] as TIdSoapITIInterface;
      LWriter.WriteString(LInterface.Name);
      LWriter.WriteString(LInterface.UnitName);
      LWriter.WriteString(LInterface.Documentation);
      LWriter.WriteString(LInterface.Namespace);
      WriteNamesAndTypes(LInterface, LWriter);
      LWriter.WriteListBegin;
      AddInterfaceMethodsToStream(False,AITI,LInterface,LWriter);
      LWriter.WriteListEnd;
      LWriter.WriteString(LInterface.Ancestor);
      LWriter.WriteBoolean(not AnsiSameText(LInterface.Ancestor,ID_SOAP_INTERFACE_BASE_NAME)); // this is a boolean to indicate if the interface is derrived directory from IIdSoapInterface (false) or not (ie Inherited from)
      LWriter.WriteString(GUIDToString({$IFNDEF DELPHI6} System.TGUID( {$ENDIF} LInterface.GUID {$IFNDEF DELPHI6}) {$ENDIF}));
      end;
    LWriter.WriteListEnd;
  finally
    FreeAndNil(LWriter);
    end;
end;

procedure TIdSoapITIBinStreamer.WriteNamesAndTypes(AITIObject: TIdSoapITIBaseObject; AWriter: TWriter);
const ASSERT_LOCATION = 'IdSoapITIBin.TIdSoapITIBinStreamer.WriteNamesAndTypes';
var
  i : integer;
  s1, s2 : string;
begin
  Assert(Self.TestValid(TIdSoapITIBinStreamer), ASSERT_LOCATION+': self is not valid');
  Assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITIObject is not valid');
  Assert(assigned(AWriter), ASSERT_LOCATION+': Writer is not valid');

  AWriter.WriteListBegin;
  for i := 0 to AITIObject.Names.count - 1 do
    begin
    if pos('.', AITIObject.Names[i]) > 0 then
      begin
      SplitString(AITIObject.Names[i], '.', s1, s2);
      AWriter.WriteString(s1);
      AWriter.WriteString(s2);
      end
    else
      begin
      AWriter.WriteString('');
      AWriter.WriteString(AITIObject.Names[i]);
      end;
    AWriter.WriteString((AITIObject.Names.Objects[i] as TIdSoapITINameObject).Name);
    end;
  AWriter.WriteListEnd;
  AWriter.WriteListBegin;
  for i := 0 to AITIObject.Types.count - 1 do
    begin
    AWriter.WriteString(AITIObject.Types[i]);
    AWriter.WriteString((AITIObject.Types.Objects[i] as TIdSoapITINameObject).Name);
    AWriter.WriteString((AITIObject.Types.Objects[i] as TIdSoapITINameObject).Namespace);
    end;
  AWriter.WriteListEnd;
  AWriter.WriteListBegin;
  for i := 0 to AITIObject.Enums.count - 1 do
    begin
    AWriter.WriteString(AITIObject.Enums[i]);
    AWriter.WriteString((AITIObject.Enums.Objects[i] as TIdSoapITINameObject).Name);
    end;
  AWriter.WriteListEnd;
end;

procedure TIdSoapITIBinStreamer.ReadNamesAndTypes(AITIObject: TIdSoapITIBaseObject; AReader: TReader; AVer : integer);
const ASSERT_LOCATION = 'IdSoapITIBin.TIdSoapITIBinStreamer.ReadNamesAndTypes';
var
  LName, LClass, LTypeNS : string;
  sl, sr:string;
begin
  Assert(Self.TestValid(TIdSoapITIBinStreamer), ASSERT_LOCATION+': self is not valid');
  Assert(AITIObject.TestValid(TIdSoapITIBaseObject), ASSERT_LOCATION+': ITIObject is not valid');
  Assert(assigned(AReader), ASSERT_LOCATION+': Writer is not valid');

  AReader.ReadListBegin;
  while not AReader.EndOfList do
    begin
    LClass := AReader.ReadString;
    LName := AReader.ReadString;
    AITIObject.DefineNameReplacement(LCLass, LName, AReader.ReadString);
    end;
  AReader.ReadListEnd;
  AReader.ReadListBegin;
  while not AReader.EndOfList do
    begin
    LName := AReader.ReadString;
    LClass := AReader.ReadString;
    LTypeNS := AReader.ReadString;
    AITIObject.DefineTypeReplacement(LName, LClass, LTypeNS);
    end;
  AReader.ReadListEnd;
  if AVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_HEADERS then
    begin
    AReader.ReadListBegin;
    while not AReader.EndOfList do
      begin
      LName := AReader.ReadString;
      LClass := AReader.ReadString;
      SplitString(LName, '.', sl, sr);
      AITIObject.DefineEnumReplacement(sl, sr, LClass);
      end;
    AReader.ReadListEnd;
    end;
end;

procedure TIdSoapITIBinStreamer.WriteParamList(AWriter: TWriter; AParams: TIdSoapITIParamList);
var
  LParam: TIdSoapITIParameter;
  LIndex: Integer;
begin
    AWriter.WriteListBegin;
    for LIndex := 0 to AParams.Count - 1 do
      begin
      LParam := AParams.Param[LIndex];
      AWriter.WriteString(LParam.Name);
      AWriter.WriteString(LParam.Documentation);
      AWriter.WriteInteger(Ord(LParam.ParamFlag));
      AWriter.WriteString(LParam.NameOfType);
      WriteNamesAndTypes(LParam, AWriter);
      end;
    AWriter.WriteListEnd;
end;

procedure TIdSoapITIBinStreamer.ReadParamList(AITI : TIdSoapITI; AMethod : TIdSoapITIMethod; AReader : TReader; AParams : TIdSoapITIParamList; AVer : Integer);
var
  LParam: TIdSoapITIParameter;
begin
  AReader.ReadListBegin;
  while not AReader.EndOfList do
    begin
    LParam := TIdSoapITIParameter.Create(AITI, AMethod);
    LParam.Name := AReader.ReadString;
    AParams.AddParam(LParam);
    LParam.Documentation := AReader.ReadString;
    LParam.ParamFlag := TParamFlag(AReader.ReadInteger);
    LParam.NameOfTYpe := AReader.ReadString;
    if AVer >= ID_SOAP_ITI_BIN_STREAM_VERSION_NAMES then
      begin
      ReadNamesAndTypes(LParam, AReader, AVer);
      end;
    end;
  AReader.ReadListEnd;
end;

end.



