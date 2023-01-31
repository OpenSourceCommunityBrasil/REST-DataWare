unit urestfunctions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, opensslsockets;

const
  TagsAPI = 'https://api.github.com/repos/OpenSourceCommunityBrasil/REST-DataWare/tags';
  BranchesAPI =
    'https://api.github.com/repos/OpenSourceCommunityBrasil/REST-DataWare/branches';
  ZipDownloadAPI =
    'https://api.github.com/repos/OpenSourceCommunityBrasil/REST-DataWare/zipball/%s';

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
    function getRepoBranches: TStream;
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
  FHTTPREST.AddHeader('Accept-Encoding', 'gzip2');
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

function TRESTClient.getRepoBranches: TStream;
var
  sresp: TStringStream;
begin
  sresp := TStringStream.Create(FHTTPREST.Get(BranchesAPI), TEncoding.UTF8);
  Result := sresp;
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
