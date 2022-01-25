unit dmdwcgiserver;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, uRESTDWBase, httpdefs, fpHTTP, fpWeb;

type

  { TdwCGIService }

  TdwCGIService = class(TFPWebModule)
    RESTServiceCGI1: TRESTServiceCGI;
    constructor CreateNew(AOwner: TComponent; CreateMode: Integer); override;
    procedure DataModuleCreate(Sender: TObject);
  private
   procedure Request(Sender: TObject; ARequest: TRequest;
                     AResponse: TResponse; var Handled: Boolean);
  public

  end;

var
  dwCGIService: TdwCGIService;

implementation

{$R *.lfm}

uses uDmService;

procedure TdwCGIService.Request(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
begin
 If RESTServiceCGI1 <> Nil Then
  RESTServiceCGI1.Command(ARequest, AResponse, Handled);
end;

constructor TdwCGIService.CreateNew(AOwner: TComponent; CreateMode: Integer);
begin
  inherited CreateNew(AOwner, CreateMode);
  onRequest := @Request;
end;

procedure TdwCGIService.DataModuleCreate(Sender: TObject);
begin
 RESTServiceCGI1.RootPath := '.\';
 RESTServiceCGI1.ServerMethodClass := TServerMethodDM;
end;


initialization
  RegisterHTTPModule('', TdwCGIService);
end.

