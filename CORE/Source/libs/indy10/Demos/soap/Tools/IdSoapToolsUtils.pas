{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  16664: IdSoapToolsUtils.pas 
{
{   Rev 1.2    19/6/2003 21:14:14  GGrieve
{ Version #1
}
{
{   Rev 1.1    18/3/2003 11:24:46  GGrieve
}
{
{   Rev 1.0    25/2/2003 14:01:40  GGrieve
}
{
Version History:
  19-Jun 2003   Grahame Grieve                  Add XML output for WSDL wizard, support for multiple interface generation
  18-Mar 2003   Grahame Grieve                  Fix for changed convert parameters
  04-Oct 2002   Andrew Cumming                  Removed spurious uses for IdSoapTestingUtils which prevented it from compiling
  19-Sep 2002   Grahame Grieve                  Fix to compile for Indy10 changes
  19-Sep 2002   Grahame Grieve                  Fix to compile for Indy10 changes
  27-Aug 2002   Grahame Grieve                  Split out of Tools Form for Linux availability
}

unit IdSoapToolsUtils;

interface

uses
  IdSoapUtilities;

const
  EXAMPLE_ITI_CONFIG =
';Note that sections, names and Filenames are case sensitive on Linux'+EOL_PLATFORM+
'[Project]'+EOL_PLATFORM+
'; this section is optional.'+EOL_PLATFORM+
'Directory=<dir> ;the root directory for all files'+EOL_PLATFORM+
''+EOL_PLATFORM+
'[Source]'+EOL_PLATFORM+
'; this section is required'+EOL_PLATFORM+
'; a list of files that contain interfaces to be parsed into the ITI'+EOL_PLATFORM+
'; you can use full path names if the files are in different directories'+EOL_PLATFORM+
'; at least one file must be listed'+EOL_PLATFORM+
'<file>'+EOL_PLATFORM+
'<file>'+EOL_PLATFORM+
''+EOL_PLATFORM+
'[Inclusions]'+EOL_PLATFORM+
'; this section is optional'+EOL_PLATFORM+
'; if you list any interfaces by name here, then only the interfaces'+EOL_PLATFORM+
'; listed will be part of the ITI'+EOL_PLATFORM+
''+EOL_PLATFORM+
'[Exclusions]'+EOL_PLATFORM+
'; this section is optional'+EOL_PLATFORM+
'; if you list any interfaces by name here, then they'+EOL_PLATFORM+
'; will not be included in the ITI'+EOL_PLATFORM+
'; the inclusions list overrides the exclusions list'+EOL_PLATFORM+
''+EOL_PLATFORM+
'[Output]'+EOL_PLATFORM+
'; this section is required'+EOL_PLATFORM+
'; this specifies where the ITI source should go after it is built'+EOL_PLATFORM+
'BinOutput=<file> ; [required] specifies the file for the Binary ITI'+EOL_PLATFORM+
'ResOutput=<file> ; [optional] specifies filename to save Resource'+EOL_PLATFORM+
'XMLOutput=<file> ; [optional] specifies filename to save XML output'+EOL_PLATFORM+
'; the XML output encodes the same information as the Binary file,'+EOL_PLATFORM+
'; but is easier to read (in a browser - but only IE. On Linux, you are on your own!)'+EOL_PLATFORM;

const
  EXAMPLE_WSDL_CONFIG =
';Note that sections, names and Filenames are case sensitive on Linux'+EOL_PLATFORM+
'[Project]'+EOL_PLATFORM+
'; this section is optional.'+EOL_PLATFORM+
'Directory=<dir> ;the root directory for all files'+EOL_PLATFORM+
''+EOL_PLATFORM+
';you can have multiple WSDL sections. Repeat WSDL sections must be name '+EOL_PLATFORM+
';WSDL.N. You do not need to number sections sequentially, but repeat WSDL '+EOL_PLATFORM+
';sections will be ignored unless a WSDL section exists'+EOL_PLATFORM+
'[WSDL]'+EOL_PLATFORM+
'Source= location of WSDL. can be http://, or file://'+EOL_PLATFORM+
'Proxy= http proxy details if required (address:port)'+EOL_PLATFORM+
'Auth= authentication details for http if required (username:password)'+EOL_PLATFORM+
'Pascal= pascal file to create'+EOL_PLATFORM+
'Exclude=; a comma delimited list of types to ignore when building the pascal '+EOL_PLATFORM+
'        ; (for types repeated in multiple WSDL files). Format is {namespace}name'+EOL_PLATFORM+
'Uses=; a comma delimited list of units to add to the uses clause of the generated pascal unit'+EOL_PLATFORM+
'Factory= 1 if you want factory code generated as well'+EOL_PLATFORM+
'PrependTypes= 1 if you want "T" prepended to type names'+EOL_PLATFORM+
'MakeITIBin= 1 if you want an ITI File generated as well (as xx.iti)'+EOL_PLATFORM+
'MakeITIRes= 1 if you want an ITI File generated as well (as xx.res, resource name will be xx)'+EOL_PLATFORM;

procedure ExecuteScript(AFileName : string);

implementation

uses
  Classes,
  Contnrs,
  IdGlobal,
  IdHTTP,
  IdSoapDebug,
  IdSoapITIBuilder,
  IdSoapTestingUtils,
  IdSoapWSDL,
  IdSoapWSDLPascal,
  IdSoapWSDLXML,
  IdStrings,
  IniFiles,
  {$IFNDEF LINUX}
  ShellAPI,
  windows,
  {$ENDIF}
  SysUtils;

procedure QuickBuildITI(APascalFile: string; ABuildBin, ABuildRes, ABuildXML: boolean);
var
  LFileName : string;
  s : string;
  LFile : TFileStream;
begin
  s :=
    '[Source]'+EOL_PLATFORM+
    APascalFile+EOL_PLATFORM+
    EOL_PLATFORM+
    '[Output]'+EOL_PLATFORM;
  if ABuildBin then
    begin
    s := s + 'BinOutput='+ChangeFileExt(APascalFile, '.iti')+EOL_PLATFORM;
    end;
  if ABuildRes then
    begin
    s := s + 'ResOutput='+ChangeFileExt(APascalFile, '.res')+EOL_PLATFORM;
    end;
  if ABuildXML then
    begin
    s := s + 'XMLOutput='+ChangeFileExt(APascalFile, '.xml')+EOL_PLATFORM;
    end;
  LFileName := MakeTempFilename;
  LFile := TFileStream.create(LFileName, fmCreate);
  try
    LFile.Write(s[1], length(s));
  finally
    FreeAndNil(LFile);
  end;
  try
    BuildITI(LFileName);
  finally
    deletefile(LFileName);
  end;
end;

type
  TIdSoapWSDLImport = class (TIdBaseObject)
  private
    FUri : string;
    FNamespace : string;
  public
    constructor create(AUri, ANamespace : string);
  end;

  TIdSoapWSDLFetcher = class (TIdBaseObject)
  private
    FIniFile : TMemIniFile;
    FSection : string;

    FQueue : TObjectList;
    FRoot : string; // what to use as the root if the reference is relative
    function MakeHTTPRequest(AUrl: string): TStream;
    procedure RegisterInclude(ASender : TObject; AUri, ANamespace : string);
  public
    Constructor create(AIniFile : TMemIniFile; ASection, ASource: String);
    Destructor destroy; override;
    function GetNextStream(out VStream : TStream; out VNamespace : string):boolean;
  end;

{ TIdSoapWSDLImport }

constructor TIdSoapWSDLImport.create(AUri, ANamespace : string);
begin
  inherited create;
  FUri := AUri;
  FNamespace := ANamespace;
end;

{ TIdSoapWSDLFetcher }

Constructor TIdSoapWSDLFetcher.create(AIniFile : TMemIniFile; ASection, ASource: String);
begin
  inherited create;
  FIniFile := AIniFile;
  FSection := ASection;
  FQueue := TObjectList.create(true);
  FRoot := ExtractFilePath(ASource);
  FQueue.Add(TIdSoapWSDLImport.create(ASource, ''));
end;

Destructor TIdSoapWSDLFetcher.Destroy;
begin
  FreeAndNil(FQueue);
  inherited;
end;

procedure TIdSoapWSDLFetcher.RegisterInclude(ASender : TObject; AUri, ANamespace : string);
begin
  if AUri <> '' then
    begin
    FQueue.Add(TIdSoapWSDLImport.create(AUri, ANamespace));
    end;
end;

function TIdSoapWSDLFetcher.GetNextStream(out VStream : TStream; out VNamespace : string):boolean;
var
  LSource : string;
  LType : string;
  LDetails : string;
begin
  result := FQueue.count > 0;
  if result then
    begin
    LSource := (FQueue[0] as TIdSoapWSDLImport).FUri;
    VNamespace := (FQueue[0] as TIdSoapWSDLImport).FNamespace;
    FQueue.Delete(0);
    if pos(':', LSource) = 0 then
      begin
      LSource := FRoot + LSource;
      end;
    SplitString(LSource, ':', LType, LDetails);
    if AnsiSameText(LType, 'http') then
      begin
      VStream := MakeHTTPRequest(LSource);
      end
    else if AnsiSameText(LType, 'file') then
      begin
      VStream := TFileStream.create(LDetails, fmOpenRead + fmShareDenyWrite);
      end
    else
      begin
      raise Exception.create('Unsupported protocol "'+LType+'"');
      end;
    end;
end;

function TIdSoapWSDLFetcher.MakeHTTPRequest(AUrl: string): TStream;
var
  LHttp : TIdHTTP;
  LLeft, LRight : string;
begin
  LHttp := TIdHTTP.create(nil);
  try
    result := TIdMemoryStream.create;
    if FIniFile.ValueExists(FSection, 'Proxy') then
      begin
      SplitString(FIniFile.ReadString(FSection, 'Proxy', ''), ':', LLeft, LRight);
      LHttp.ProxyParams.ProxyServer := LLeft;
      LHttp.ProxyParams.ProxyPort := IdStrToIntWithError(LRight, 'Proxy port for '+FSection);
      end;
    if FIniFile.ValueExists(FSection, 'Auth') then
      begin
      SplitString(FIniFile.ReadString(FSection, 'Auth', ''), ':', LLeft, LRight);
      LHttp.ProxyParams.ProxyUsername := LLeft;
      LHttp.ProxyParams.ProxyPassword := LRight;
      end;
    LHttp.Get(AUrl, Result);
    result.position := 0;
  finally
    FreeAndNil(LHttp);
  end;
end;

function BuildWSDL(AIniFile : TMemIniFile; ASection, ASource: String): TIdSoapWSDL;
var
  LFetcher : TIdSoapWSDLFetcher;
  LParser : TIdSoapWSDLConvertor;
  LStream : TStream;
  LNamespace : string;
begin
  result := TIdSoapWSDL.create('');
  try
    LFetcher := TIdSoapWSDLFetcher.Create(AIniFile, ASection, ASource);
    try
      LParser := TIdSoapWSDLConvertor.create(nil, Result);
      try
        LParser.OnFindInclude := LFetcher.RegisterInclude;
        while LFetcher.GetNextStream(LStream, LNamespace) do
          begin
          try
            LParser.ReadFromXml(LStream, LNamespace);
          finally
            FreeAndNil(LStream);
          end;
          end;
      finally
        FreeAndNil(LParser);
      end;
    finally
      FreeAndNil(LFetcher);
    end;
  except
    FreeAndNil(result);
    raise;
  end;
end;

procedure ProcessWSDL(AIniFile : TMemIniFile);
var
  i : integer;
  LList : TStringList;
  LConvertor : TIdSoapWSDLToPascalConvertor;
  LWsdl : TIdSoapWSDL;
  LFile : TFileStream;
  LOutputFileName : string;
begin
  LList := TStringList.create;
  try
    AIniFile.ReadSections(LList);
    for i := 0 to LList.count -1 do
      begin
      if copy(lowercase(LList[i]), 1, 4) = 'wsdl' then
        begin
        if AIniFile.ValueExists('Project', 'Directory') then
          begin
          SetCurrentDir(AIniFile.ReadString('Project', 'Directory', ''));
          end;
        LConvertor := TIdSoapWSDLToPascalConvertor.create;
        try
          LConvertor.UnitName := ExtractFileName(AIniFile.ReadString(LList[i], 'pascal', ''));
          if LastDelimiter('.', LConvertor.UnitName) > 1 then
            begin
            LConvertor.UnitName := copy(LConvertor.UnitName, 1, LastDelimiter('.', LConvertor.UnitName)-1);
            end;
          LConvertor.WSDLSource := AIniFile.ReadString(LList[i], 'source', '');
          LConvertor.AddFactory := AIniFile.ReadBool(LList[i], 'Factory', false);
          LConvertor.PrependTypeNames := AIniFile.ReadBool(LList[i], 'PrependTypes', false);
          LConvertor.SetExemptTypes(AIniFile.ReadString(LList[i], 'Exclude', ''));
          LConvertor.SetUsesClause(AIniFile.ReadString(LList[i], 'Uses', ''));
          LConvertor.OnlyOneInterface := AIniFile.ReadBool(LList[i], 'OnlyOneInterface', false);
          LConvertor.OneInterfaceName := AIniFile.ReadString(LList[i], 'InterfaceName', '');


          if AIniFile.ReadBool(LList[i], 'MakeITIRes', false) then
            begin
            LConvertor.ResourceFileName := ChangeFileExt(ExtractFileName(AIniFile.ReadString(LList[i], 'pascal', '')), '.res');
            end;
          LWsdl := BuildWSDL(AIniFile, LList[i], LConvertor.WSDLSource);
          try
          //  IdSoapViewString(LWsdl.TypeDump, 'txt');
            LOutputFileName := ChangeFileExt(AIniFile.ReadString(LList[i], 'pascal', ''), '.pas');
            LFile := TFileStream.Create(LOutputFileName, fmCreate);
            try
              LConvertor.Convert(LWsdl, LFile);
            finally
              FreeAndNil(LFile);
            end;
          finally
            FreeAndNil(LWsdl);
          end;
        finally
          FreeAndNil(LConvertor);
          end;
        {$IFNDEF LINUX}
        ShellExecute(0, NIL, PChar(AIniFile.ReadString(LList[i], 'pascal', '')), NIL, NIL, SW_NORMAL);
        {$ENDIF}
        if AIniFile.ReadBool(LList[i], 'MakeITIBin', false) or AIniFile.ReadBool(LList[i], 'MakeITIRes', false) then
          begin
          QuickBuildITI(LOutputFileName, AIniFile.ReadBool(LList[i], 'MakeITIBin', false), AIniFile.ReadBool(LList[i], 'MakeITIRes', false), AIniFile.ReadBool(LList[i], 'MakeITIXML', false));
          end;
        end;
      end;
  finally
    FreeAndNil(LList);
  end;
end;

procedure ExecuteScript(AFileName : string);
var
  LIni: TMemIniFile;
begin
  LIni := TMemIniFile.Create(AFileName);
  try
    if LIni.ValueExists('Output', 'BinOutput') or LIni.ValueExists('Output', 'ResOutput') then
      begin
      BuildITI(AFileName);
      end;
    ProcessWSDL(LIni);
  finally
    FreeAndNil(LIni);
  end;
end;

end.

