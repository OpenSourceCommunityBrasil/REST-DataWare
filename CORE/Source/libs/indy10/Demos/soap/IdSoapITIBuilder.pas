{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15732: IdSoapITIBuilder.pas 
{
{   Rev 1.1    20/6/2003 00:03:26  GGrieve
{ Main V#1 book-in
}
{
{   Rev 1.0    11/2/2003 20:33:46  GGrieve
}
{
IndySOAP: This unit controls the building of an ITI from the source.
Refer to IdSoapITI for a description of how this works
}

{
Version History:
  19-Jun 2003   Grahame Grieve                  compile fix
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  27-Aug 2002   Grahame Grieve                  Linux Fixes
  13 Aug 2002   Grahame Grieve                  Restore Design time setting for DUnit testing
  07-May 2002   Andrew Cumming                  Added resource file as output option
  07-May 2002   Grahame Grieve                  Make sure streamer is cleaned up
  14-Mar 2002   Grahame Grieve                  Update for changes to Parser
}

unit IdSoapITIBuilder;

interface

procedure BuildITI(AConfigFile: String);

implementation

uses
  Classes,
{$IFDEF WIN32}
  Windows,
{$ENDIF}
  IdSoapITI,
  IdSoapITIBin,
  IdSoapITIXML,
  IdSoapITIParser,
  IdSoapUtilities,
  IdSoapResourceFile,
  IniFiles,
  SysUtils;

procedure ReadFiles(AITI: TIdSoapITI; AConfigFile: TMemIniFile);
var
  LFile: TFileStream;
  i: Integer;
  LFileList: TStringList;
  LInclusionList: TStringList;
  LExclusionList: TStringList;
  LParser: TIdSoapITIParser;
  LUnitName : string;
begin
  assert(AITI.TestValid, 'IdSoapITIBuilder.ReadFiles: ITI is not valid');
  assert(assigned(AConfigFile), 'IdSoapITIBuilder.ReadFiles: IniFile is not valid');
  LFileList := TIdStringList.Create;
  try
    AConfigFile.ReadSectionValues('Source', LFileList);
    IdRequire(LFileList.Count > 0, 'IdSoapITIBuilder.ReadFiles: No Source Files listed in the ITI Config File');
    for i := 0 to LFileList.Count - 1 do
      begin
      IdRequire(FileExists(LFileList[i]), 'IdSoapITIBuilder.ReadFiles: File "' + LFileList[i] + '" not found');
      LFile := TFileStream.Create(LFileList[i], fmOpenRead + fmShareDenyWrite);
      try
        LInclusionList := TStringList.Create;
        try
          AConfigFile.ReadSectionValues('Inclusions', LInclusionList);
          LExclusionList := TStringList.Create;
          try
            AConfigFile.ReadSectionValues('Exclusions', LExclusionList);
            LUnitName := ExtractFileName(LFileList[i]);
            if Pos('.', LUnitName) > 0 then
              begin
              LUnitName := copy(LUnitName, 1, Pos('.', LUnitName)-1);
              end;
            LParser := TIdSoapITIParser.Create;
            try
              LParser.Parse(AITI, LFile, LUnitName, LInclusionList, LExclusionList);
            finally
              FreeAndNil(LParser);
            end;
          finally
            LExclusionList.Free;
          end;
        finally
          LInclusionList.Free;
        end;
      finally
        FreeAndNil(LFile);
      end;
      end;
  finally
    FreeAndNil(LFileList);
  end;
end;

procedure SaveITI(AITI: TIdSoapITI; AFileName: String; AStreamer: TIdSoapITIStreamingClass);
var
  LFile: TFileStream;
begin
  try
    assert(AITI.TestValid(TIdSoapITI), 'IdSoapITIBuilder.SaveITI: ITI does not exist saving it');
    assert(AFileName <> '', 'IdSoapITIBuilder.SaveITI: Filename not provided saving ITI');
    assert(AStreamer.TestValid, 'IdSoapITIBuilder.SaveITI: Streaming object does not exist saving ITI');
    LFile := TFileStream.Create(AFileName, fmCreate);
    try
      AStreamer.SaveToStream(AITI, LFile);
    finally
      FreeAndNil(LFile)
    end;
  finally
    FreeAndNil(AStreamer);
  end;
end;

procedure SaveITIToResources(AResInfo: String; AITI: TIdSoapITI);
var
  LResourceStream: TMemoryStream;
  LResourceCreator: TIdSoapResourceFile;
  LResourceEntry: TIdSoapResourceEntry;
  LITIBinStreamer: TIdSoapITIBinStreamer;
  LResourceName: String;
  LResourceFile: String;
begin
  IdRequire(Assigned(AITI) and (AITI is TIdSoapITI) , 'IdSoapITIBuilder.SaveITIToResources: .IdSoapCfg AITI is nil');
  if AResInfo = '' then
    begin
    exit;
    end;
  LResourceStream := TMemoryStream.Create;
  try
    LITIBinStreamer := TIdSoapITIBinStreamer.Create;
    try
      LITIBinStreamer.SaveToStream(AITI,LResourceStream);
    finally
      FreeAndNil(LITIBinStreamer);
      end;
    LResourceCreator := TIdSoapResourceFile.Create;
    try
      SplitString(AResInfo,';',LResourceFile,LResourceName);
      if LResourceName='' then
        begin
        LResourceName := ExtractFilename(LResourceFile);
        LResourceName := copy(LResourceName,1,length(LResourceName)-length(ExtractFileExt(LResourceName)));
        end;
      LResourceEntry := TIdSoapResourceEntry.Create;
      LResourceCreator.Add(LResourceEntry);
      LResourceEntry.Size := LResourceStream.Size;
      move(LResourceStream.Memory^,LResourceEntry.Data^,LResourceEntry.Size);
      {$IFDEF LINUX}
      LResourceEntry.ResType := 'RT_RCDATA'; // ??? not sure what to do
      {$ELSE}
      LResourceEntry.ResType := RT_RCDATA;
      {$ENDIF}
      LResourceEntry.Name := LResourceName;
      LResourceCreator.SaveToFile(LResourceFile);
    finally
      FreeAndNil(LResourceCreator);
      end;
  finally
    FreeAndNil(LResourceStream);
    end;
end;

procedure BuildITI(AConfigFile: String);
var
  LIni: TMemIniFile;
  LITI: TIdSoapITI;
  LOldDesignTime : boolean;
begin
  // in a sense, this is hack - it's not valid to use BuildITI at run time,
  // although we do in the DUnit testing. so we restore the old setting
  LOldDesignTime := GDesignTime;
  GDesignTime := True;
  try
    IdRequire(FileExists(AConfigFile), 'IdSoapITIBuilder.BuildITI: .IdSoapCfg File ("' + AConfigFile + '") Not Found');
    LIni := TMemIniFile.Create(AConfigFile);
    try
      IdRequire((LIni.ReadString('Output', 'BinOutput', '') <> '') or (LIni.ReadString('Output', 'ResOutput', '') <> ''), 'IdSoapITIBuilder.BuildITI: You must specify a Valid BinOutput or ResOutput File');
      LITI := TIdSoapITI.Create;
      try
        LITI.SetupBaseRenaming;
        SetCurrentDir(LIni.ReadString('Project', 'Directory', GetCurrentDir));
        ReadFiles(LITI, LIni);
        LITI.Validate('parser');
        if LIni.ReadString('Output', 'BinOutput', '') <> '' then
          begin
          SaveITI(LITI, LIni.ReadString('Output', 'BinOutput', ''), TIdSoapITIBinStreamer.Create);
          end;
        if LIni.ReadString('Output', 'XMLOutput', '') <> '' then
          begin
          SaveITI(LITI, LIni.ReadString('Output', 'XMLOutput', ''), TIdSoapITIXMLStreamer.Create);
          end;
        SaveITIToResources(LIni.ReadString('Output','ResOutput',''),LITI);
      finally
        FreeAndNil(LITI);
      end;
    finally
      FreeAndNil(LIni)
    end;
  finally
    GDesignTime := LOldDesignTime;
  end;
end;

end.

