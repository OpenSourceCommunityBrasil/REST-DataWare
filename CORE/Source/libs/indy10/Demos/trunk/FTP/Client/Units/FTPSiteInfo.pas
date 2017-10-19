{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  23176: FTPSiteInfo.pas 
{
{   Rev 1.1    09/11/2003 2:11:52 PM  Jeremy Darling
{ Updated some of the site configuration stuff and made it so that you can add,
{ edit and delete sites from your site list.  Also added a Site Name so that
{ you don't have to see the address when selecting a site.
}
{
{   Rev 1.0    09/11/2003 12:50:02 PM  Jeremy Darling
{ Project Added to TC
}
unit FTPSiteInfo;

interface

uses
  Classes,
  SysUtils;

type
  TFTPSiteInfo = class
    Address,
    Name,
    UserName,
    Password,
    RootDir : String;
  end;

  TFTPSiteList = class
  private
    List : TList;
    function GetCount: Integer;
    function GetSites(index: integer): TFTPSiteInfo;
  public
    property Sites[index:integer] : TFTPSiteInfo read GetSites; default;
    property Count : Integer read GetCount;
    function New : TFTPSiteInfo;
    function Add( Site : TFTPSiteInfo ) : Integer;
    function IndexOfName(SiteName : String) : Integer;
    function IndexOfAddress(SiteAddress : String) : Integer;
    function IndexOf(Site : TFTPSiteInfo) : Integer;
    procedure Clear;
    procedure Delete(index : Integer);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TFTPSiteList }

function TFTPSiteList.Add(Site: TFTPSiteInfo): Integer;
begin
  Result := List.Add(Site);
end;

procedure TFTPSiteList.Clear;
begin
  while Count > 0 do
    Delete(0);
end;

constructor TFTPSiteList.Create;
begin
  inherited;
  List := TList.Create;
end;

procedure TFTPSiteList.Delete(index: Integer);
begin
  Sites[index].Free;
  List.Delete(index);
end;

destructor TFTPSiteList.Destroy;
begin
  List.Free;
  inherited;
end;

function TFTPSiteList.GetCount: Integer;
begin
  Result := List.Count;
end;

function TFTPSiteList.GetSites(index: integer): TFTPSiteInfo;
begin
  Result := List[index];
end;

function TFTPSiteList.IndexOf(Site: TFTPSiteInfo): Integer;
begin
  Result := List.IndexOf(Site);
end;

function TFTPSiteList.IndexOfAddress(SiteAddress: String): Integer;
var
  i : Integer;
begin
  i := 0;
  Result := -1;
  while (i < Count) and
        (Result = -1) do
    begin
      if AnsiCompareText(Sites[i].Address, SiteAddress) = 0 then
        Result := i;
      inc(i);
    end;
end;

function TFTPSiteList.IndexOfName(SiteName: String): Integer;
var
  i : Integer;
begin
  i := 0;
  Result := -1;
  while (i < Count) and
        (Result = -1) do
    begin
      if AnsiCompareText(Sites[i].Name, SiteName) = 0 then
        Result := i;
      inc(i);
    end;
end;

function TFTPSiteList.New: TFTPSiteInfo;
begin
  Result := TFTPSiteInfo.Create;
  List.Add(Result);
end;

end.
