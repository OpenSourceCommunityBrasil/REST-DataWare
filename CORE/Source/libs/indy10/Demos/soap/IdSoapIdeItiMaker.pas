{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15724: IdSoapIdeItiMaker.pas 
{
{   Rev 1.0    11/2/2003 20:33:20  GGrieve
}
{
IndySOAP: IDE plug in to auto-process .IdSoapCfg files
}

{
Version History:
  29-May 2002   Grahame Grieve                  Do pre-compile 
  29-May 2002   Grahame Grieve                  err. Fix to compile
  18-May 2002   Mark Ericksen     [GDG]         Added RemoveNotifier to prevent Delphi IDE crashes when closing (reformated unit to declare class under implementation)
  26-Apr 2002   Andrew Cumming                  Move includes to allow D6 compile
  11-Apr 2002   Grahame Grieve                  Use ASSERT_LOCATION, ResourceStrings were appropriate
  26-Mar 2002   Grahame Grieve                  First written
}

unit IdSoapIdeItiMaker;

{$I IdSoapDefines.inc}

interface

procedure Register;

implementation

uses
  Classes,
  ToolsApi,
  IdSoapConsts,
  IdSoapITIBuilder,
  SysUtils;

var
  GNotifierIndex: Integer;

{ Declare class private to the unit. Remove the opportunity for 'outside'
  interference. }
type
  TIdSoapOTAObject = class (TNotifierObject, IOTAIDENotifier)
  Public
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
  end;

{ TIdSoapOTAObject }

procedure TIdSoapOTAObject.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
begin
  // not interested in this Notification
end;

procedure TIdSoapOTAObject.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
var
  LITIConfigFile : string;
  LDir : string;
begin
  if assigned(Project) then
    begin
    LITIConfigFile := Project.FileName;
    Delete(LITIConfigFile, Length(LITIConfigFile) - length(ExtractFileExt(LITIConfigFile))+1, length(ExtractFileExt(LITIConfigFile)));
    LITIConfigFile := LITIConfigFile + ID_SOAP_CONFIG_FILE_EXT;
    if FileExists(LITIConfigFile) then
      begin
      LDir := GetCurrentDir;
      try
        SetCurrentDir(ExtractFilePath(LITIConfigFile));
        BuildITI(LITIConfigFile);
      finally
        SetCurrentDir(LDir);
      end;
      end;
    end;
end;


procedure TIdSoapOTAObject.AfterCompile(Succeeded: Boolean);
begin
  // not interested in this Notification
end;

procedure Register;
const ASSERT_LOCATION = 'IdSoapIdeItiMaker.Register';
var
  LServices: IOTAServices;
begin
  LServices := BorlandIDEServices as IOTAServices;
  Assert(Assigned(LServices), ASSERT_LOCATION+': IOTAServices not available');
  GNotifierIndex := LServices.AddNotifier(TIdSoapOTAObject.Create);
end;

procedure RemoveNotifier;
const ASSERT_LOCATION = 'IdSoapIdeItiMaker.RemoveNotifier';
var
  LServices: IOTAServices;
begin
  if GNotifierIndex <> -1 then
  begin
    LServices := BorlandIDEServices as IOTAServices;
    Assert(Assigned(LServices), ASSERT_LOCATION+': IOTAServices not available');
    LServices.RemoveNotifier(GNotifierIndex);
  end;
end;

initialization

finalization
  RemoveNotifier;
end.

