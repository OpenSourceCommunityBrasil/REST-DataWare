{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16451: IdSoapWsdlTests.pas 
{
{   Rev 1.3    23/6/2003 21:30:16  GGrieve
{ fix for EOL on Linux
}
{
{   Rev 1.2    19/6/2003 21:36:52  GGrieve
{ Version #1
}
{
{   Rev 1.1    18/3/2003 11:16:28  GGrieve
{ QName, RawXML changes
}
{
{   Rev 1.0    25/2/2003 13:30:00  GGrieve
}
{
Version History:
  23-Jun 2003   Grahame Grieve                  fix for EOL on Linux
  19 Jun 2003   Grahame Grieve                  Fix for Unit naming
  18-Mar 2003   Grahame Grieve                  Schema extensibility
  27-Aug 2002   Grahame Grieve                  Linux Fixes
  13-Aug 2002   Grahame Grieve                  Change SoapAction handling
  13 Aug 2002   Grahame Grieve                  Add SoapBuilders tests
  24-Jul 2002   Grahame Grieve                  Reorganise WSDL tests
  22-Jul 2002   Grahame Grieve                  Soap V1.1 conformance testing
  29-May 2002   Grahame Grieve                  First added (still failing)
}

Unit IdSoapWsdlTests;

{$I IdSoapDefines.inc}

Interface

uses
  Classes,
  IdSoapWsdl,
  TestFramework;

type
  TIdSoapWSDLTests = class(TTestCase)
  Private
    procedure ConvertFile(AFileNames : array of string);
    procedure FindInclude(ASender : TObject; AUri : string; ADefinedNamespace : string);
    procedure ReadWSDLFromXml(AWsdl: TIdSoapWSDL; AStream: TStream);
    procedure WriteWSDLToXml(AWsdl: TIdSoapWSDL; AStream: TStream);
  Published
    // a big file that contains all sorts of types
    procedure TestWsdl_Xml;

    // a selection of miscellaineous files
    procedure TestWsdl_HelloWorld;
    procedure TestWsdl_INumToWords;
    procedure TestWsdl_Google;
    procedure TestWsdl_Apache;
    procedure TestWsdl_DotNetDocLit;
    procedure TestWsdl_Interop2B;
    procedure TestWsdl_LRIService;


    // soapbuilders - check ITI is right
    procedure TestWsdl_SoapBuilders1;
  end;

Implementation

uses
  IdSoapConsts,
  IdSoapITI,
  IdSoapITIBin,
  IdSoapITIBuilder,
  IdSoapITIProvider,
  IdSoapTestingUtils,
  IdSoapTypeRegistry,
  IdSoapUtilities,
  IdSoapWsdlIti,
  IdSoapWsdlPascal,
  IdSoapWsdlXml,
  SysUtils;

procedure TIdSoapWSDLTests.FindInclude(ASender: TObject; AUri, ADefinedNamespace: string);
begin
  // ignore 
end;


procedure TIdSoapWSDLTests.ReadWSDLFromXml(AWsdl : TIdSoapWSDL; AStream : TStream);
var
  LCnv : TIdSoapWSDLConvertor;
begin
  LCnv := TIdSoapWSDLConvertor.create(nil, AWsdl);
  try
    LCnv.OnFindInclude := FindInclude;
    LCnv.ReadFromXml(AStream, '');
  finally
    FreeAndNil(LCnv);
  end;
end;

procedure TIdSoapWSDLTests.WriteWSDLToXml(AWsdl : TIdSoapWSDL; AStream : TStream);
var
  LCnv : TIdSoapWSDLConvertor;
begin
  LCnv := TIdSoapWSDLConvertor.create(nil, AWsdl);
  try
    LCnv.WriteToXml(AStream);
  finally
    FreeAndNil(LCnv);
  end;
end;

{ TIdSoapInterfaceBaseTests }

procedure TIdSoapWSDLTests.TestWsdl_Xml;
var
  LProvider : TIdSoapITIProvider;
  LWsdl1 : TIdSoapWSDL;
  LWsdl2 : TIdSoapWSDL;
  LStream1 : TStream;
  LStream2 : TStream;
  LOk : boolean;
  LMsg : string;
  LDescriber : TIdSoapITIDescriber;
begin
  // This test creates a WSDL, then writes it to a
  // stream. then it reads the stream in, and writes it out again.
  // then we check that the streams are *identical*
  // finally, we check that it is valid (it should be, given that we wrote it)
  LProvider := TIdSoapITIProvider.Create(nil);
  try
    LProvider.ITISource := islResource;
    LProvider.ITIResourceName := 'IdSoapInterfaceTests';
    LProvider.Active := true;

    // this is a bit of a cheat. it's just too hard to test the RawXml stuff in this kind of test, so
    // we'll just drop them off
    LProvider.ITI.FindInterfaceByName('IIdSoapInterfaceTestsInterface').Methods.Delete(LProvider.ITI.FindInterfaceByName('IIdSoapInterfaceTestsInterface').Methods.IndexOf('FuncRawXML'));
    LProvider.ITI.FindInterfaceByName('IIdSoapInterfaceTestsInterface').Methods.Delete(LProvider.ITI.FindInterfaceByName('IIdSoapInterfaceTestsInterface').Methods.IndexOf('ProcRawXML'));

    LWsdl1 := TIdSoapWSDL.create('urn:tempuri.org');
    try
      LDescriber := TIdSoapITIDescriber.create(LWsdl1, nil);
      try
        LDescriber.Describe(LProvider.ITI.FindInterfaceByName('IIdSoapInterfaceTestsInterface'), 'http://tempuri.org/temp');
      finally
        FreeAndNil(LDescriber);
      end;
      LStream1 := TIdMemoryStream.create;
      try
        WriteWSDLToXml(LWsdl1, LStream1);
        LWsdl2 := TIdSoapWSDL.create('');
        try
          LStream1.Position := 0;
          ReadWSDLFromXml(LWsdl2, LStream1);
          LStream2 := TIdMemoryStream.create;
          try
            WriteWSDLToXml(LWsdl2, LStream2);
            LStream1.Position := 0;
            LStream2.Position := 0;
            LOk := TestStreamsIdentical(LStream1, LStream2, LMsg);
            if not LOk then
              begin
              IdSoapShowXMLDiff(LStream1, LStream2);
              end;
            Check(LOk, LMsg);
          finally
            FreeAndNil(LStream2);
          end;
        finally
          FreeAndNil(LWsdl2);
        end;
      finally
        FreeAndNil(LStream1);
      end;
    finally
      FreeAndNil(LWsdl1);
    end;
  finally
    FreeAndNil(LProvider);
  end;
end;

function MakeUnitName(AName:String) : string;
var
  i : integer;
begin
  result := '';
  for i := 1 to length(AName) do
    begin
    if AName[i] in ['A'..'Z', 'a'..'z', '0'..'9'] then
      begin
      result := result + AName[i];
      end;
    end;
end;

procedure TIdSoapWSDLTests.ConvertFile(AFileNames : array of string);
var
  LWsdl : TIdSoapWsdl;
  LFile : TFileStream;
  LStream : TStringStream;
  LCnv : TIdSoapWSDLToPascalConvertor;
  LUnitName : string;
  LDestFile : string;
  i : integer;
begin
  LDestFile := ChangeFileExt(AFileNames[0], '.tmp');
  LUnitName := ExtractFileName(AFileNames[0]);
  LUnitName := MakeUnitName(ChangeFileExt(LUnitName, ''));
  LWsdl := TIdSoapWSDL.create('');
  try
    for i := low(AFileNames) to High(AFileNames) do
      begin
      LFile := TFileStream.create(AFileNames[i], fmOpenRead + fmShareDenyWrite);
      try
        ReadWSDLFromXml(LWsdl, LFile);
      finally
        FreeAndNil(LFile);
      end;
      end;
    LStream := TStringStream.create('');
    try
      WriteWSDLToXml(LWsdl, LStream);
      Check(LStream.DataString <> '');
    finally
      FreeAndnil(LStream);
    end;
    LStream := TStringStream.create('');
    try
      LCnv := TIdSoapWSDLToPascalConvertor.create;
      try
        LCnv.UnitName := LUnitName;
        LCnv.WSDLSource := 'file://'+AFileNames[0];
        LCnv.AddFactory := true;
        LCnv.Convert(LWsdl, LStream);
      finally
        FreeAndNil(LCnv);
      end;
      Check(LStream.DataString <> '');
      Check(pos('file://'+AFileNames[0], LStream.DataString) <> 0);
      Check(pos(LUnitName, LStream.DataString) <> 0);
      LStream.Position := 0;
      LFile := TFileStream.create(LDestFile, fmCreate);
      try
        LFile.CopyFrom(LStream, 0);
      finally
        FreeAndNil(LFile);
      end;
    finally
      FreeAndnil(LStream);
    end;
    IdSoapSaveStringToFile('[Source]'+EOL_PLATFORM+
                           LDestFile+EOL_PLATFORM+
                           EOL_PLATFORM+
                           '[Output]'+EOL_PLATFORM+
                           'BinOutput='+ChangeFileExt(AFileNames[0], '.iti')+EOL_PLATFORM, ChangeFileExt(AFileNames[0], '.cfg'));
    BuildITI(ChangeFileExt(AFileNames[0], '.cfg'));
  finally
    FreeAndNil(LWsdl);
  end;
end;

procedure TIdSoapWSDLTests.TestWsdl_HelloWorld;
begin
  ConvertFile(['WsdlSamples'+PathDelim+'ProxyHelloWorld.wsdl']);
end;

procedure TIdSoapWSDLTests.TestWsdl_INumToWords;
begin
  ConvertFile(['WsdlSamples'+PathDelim+'INumToWords.wsdl']);
end;

procedure TIdSoapWSDLTests.TestWsdl_Google;
begin
  ConvertFile(['WsdlSamples'+PathDelim+'GoogleSearch.wsdl']);
end;

procedure TIdSoapWSDLTests.TestWsdl_Apache;
begin
  ConvertFile(['WsdlSamples'+PathDelim+'Apache.wsdl']);
end;

procedure TIdSoapWSDLTests.TestWsdl_DotNetDocLit;
begin
  ConvertFile(['WsdlSamples'+PathDelim+'DotNetDocLit.wsdl']);
end;

procedure TIdSoapWSDLTests.TestWsdl_Interop2B;
begin
  ConvertFile(['WsdlSamples'+PathDelim+'Interop2GroupB.wsdl']);
end;

procedure TIdSoapWSDLTests.TestWsdl_LRIService;
begin
  ConvertFile(['WsdlSamples'+PathDelim+'LRIService-service.wsdl', 'WsdlSamples'+PathDelim+'LRIService-binding.wsdl', 'WsdlSamples'+PathDelim+'LRIService-schema.xsd']);
end;

procedure TIdSoapWSDLTests.TestWsdl_SoapBuilders1;
var
  LIti : TIdSoapITI;
  LReader : TIdSoapITIBinStreamer;
  LFile : TFileStream;
  LIntf : TIdSoapITIInterface;
  LOldDesignTime : boolean;
begin
  LOldDesignTime := GDesignTime;
  GDesignTime := true;
  try
    ConvertFile(['SoapBuilders'+PathDelim+'Interop.wsdl']);
    LIti := TIdSoapITI.Create;
    try
      LReader := TIdSoapITIBinStreamer.create;
      try
        LFile := TFileStream.create('SoapBuilders'+PathDelim+'Interop.iti', fmOpenRead + fmShareDenyWrite);
        try
          LReader.ReadFromStream(LIti, LFile);
        finally
          FreeAndNil(LFile);
        end;
      finally
        FreeAndNil(LReader);
      end;
      Check(LIti.Interfaces.count = 1);
      LIntf := LIti.FindInterfaceByName('Interop');
      Check(LIntf.TestValid(TIdSoapITIInterface));
      Check(LIntf.UnitName = 'Interop');    // of course, this is not valid but will do here and now
      Check(LIntf.Namespace = 'http://soapinterop.org/');
      Check(LIntf.Methods.count = 11);
    finally
      FreeAndNil(LIti);
    end;
  finally
    GDesignTime := LOldDesignTime;
  end;
end;

end.


