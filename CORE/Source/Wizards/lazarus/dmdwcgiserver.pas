unit dmdwcgiserver;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, uRESTDWBase, httpdefs, fpHTTP, fpWeb;

type
  Trestdwcgiwebmodule = class(TFPWebModule)
    RESTServiceCGI1: TRESTServiceCGI;
    Constructor CreateNew(AOwner: TComponent; CreateMode: Integer); override;
    Procedure DataModuleCreate(Sender: TObject);
  private
   procedure Request(Sender: TObject; ARequest: TRequest;
                     AResponse: TResponse; var Handled: Boolean);
  public

  end;

var
  restdwcgiwebmodule: Trestdwcgiwebmodule;

implementation

{$R *.lfm}

procedure Trestdwcgiwebmodule.Request(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
begin
 If RESTServiceCGI1 <> Nil Then
  RESTServiceCGI1.Command(ARequest, AResponse, Handled);
end;

constructor Trestdwcgiwebmodule.CreateNew(AOwner: TComponent; CreateMode: Integer);
begin
  inherited CreateNew(AOwner, CreateMode);
  onRequest := @Request;
end;

procedure Trestdwcgiwebmodule.DataModuleCreate(Sender: TObject);
begin
 RESTServiceCGI1.RootPath := IncludeTrailingPathDelimiter('.');
end;

end.

