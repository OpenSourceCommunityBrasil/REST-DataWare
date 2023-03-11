unit urestfunctions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, opensslsockets, fpjson, jsonparser;

const
  TagsAPI = 'https://api.github.com/repos/OpenSourceCommunityBrasil/REST-DataWare/tags';
  BranchesAPI =
    'https://api.github.com/repos/OpenSourceCommunityBrasil/REST-DataWare/branches';
  ZipDownloadAPI =
    'https://api.github.com/repos/OpenSourceCommunityBrasil/REST-DataWare/zipball/%s';
  FileDownloadAPI =
    'https://github.com/OpenSourceCommunityBrasil/REST-DataWare/raw/dev/instalador/%s';

type

  { TRESTClient }

  TRESTClient = class
    FHTTPREST: TFPHTTPClient;
  private

  public
    constructor Create;
    destructor Destroy; override;
    procedure setDefaultHeaders;
    function getRepoTags: TStream;
    function getTagsList: string;
    function getBranchesList: string;
    function getRepoBranches: TStream;
    function getFileStream(aFileName: string): TFileStream;
    function Download(aDirectory: string; aVersion: string): boolean;
  end;

implementation

{ TRESTClient }

constructor TRESTClient.Create;
begin
  FHTTPREST := TFPHTTPClient.Create(nil);
  setDefaultHeaders;
end;

destructor TRESTClient.Destroy;
begin
  FHTTPREST.Free;
  inherited Destroy;
end;

procedure TRESTClient.setDefaultHeaders;
begin
  FHTTPREST.RequestHeaders.Clear;
  FHTTPREST.AddHeader('User-Agent', 'REST DataWare Installer Tool');
  FHTTPREST.AddHeader('Accept', '*/*');
  FHTTPREST.AddHeader('Connection', 'keep-alive');
  FHTTPREST.AddHeader('Content-Type', 'application/json; charset=UTF-8');
end;

function TRESTClient.getRepoTags: TStream;
var
  sresp: TStringStream;
begin
  sresp := TStringStream.Create(FHTTPREST.Get(TagsAPI), TEncoding.UTF8);
  Result := sresp;
end;

function TRESTClient.getTagsList: string;
var
  RestClient: TRESTClient;
  Tags: TJSONArray;
  slistTags: TStringList;
  strResposta: TStream;
  I: integer;
begin
  RestClient := TRESTClient.Create;
  slistTags := TStringList.Create;
  Result := '';
  try
    strResposta := RestClient.getRepoTags;
    Tags := TJSONArray(GetJSON(strResposta));
    for I := 0 to pred(Tags.Count) do
      slistTags.Add(TJSONObject(Tags.Items[i]).Get('name'));
    Result := slistTags.DelimitedText;
  finally
    slistTags.Free;
    strResposta.Free;
    Tags.Free;
    RestClient.Free;
  end;
end;

function TRESTClient.getBranchesList: string;
var
  RestClient: TRESTClient;
  Tags: TJSONArray;
  slistBranches: TStringList;
  strResposta: TStream;
  I: integer;
begin
  RestClient := TRESTClient.Create;
  //Tags := TJSONArray.Create;
  slistBranches := TStringList.Create;
  Result := '';
  try
    strResposta := RestClient.getRepoBranches;
    Tags := TJSONArray(GetJSON(strResposta));
    for I := 0 to pred(Tags.Count) do
      slistBranches.Add(TJSONObject(Tags.Items[i]).Get('name'));
    Result := slistBranches.DelimitedText;
  finally
    slistBranches.Free;
    strResposta.Free;
    Tags.Free;
    RestClient.Free;
  end;
end;

function TRESTClient.getRepoBranches: TStream;
var
  sresp: TStringStream;
begin
  sresp := TStringStream.Create(FHTTPREST.Get(BranchesAPI), TEncoding.UTF8);
  Result := sresp;
end;

function TRESTClient.getFileStream(aFileName: string): TFileStream;
begin
  FHTTPREST.Get(Format(FileDownloadAPI, [aFileName]), Result);
end;

function TRESTClient.Download(aDirectory: string; aVersion: string): boolean;
var
  fstr: TFileStream;
begin
  fstr := TFileStream.Create(aDirectory + 'REST DataWare - ' + aVersion +
    '.zip', fmCreate);
  FHTTPREST.Get(Format(ZipDownloadAPI, [aVersion]), fstr);
  fstr.Free;
end;

end.
