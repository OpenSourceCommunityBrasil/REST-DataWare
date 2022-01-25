unit dmdwcgiserver;

{$mode objfpc}{$H+}

Interface

Uses
  SysUtils, Classes, uRESTDWBase, httpdefs, fpHTTP, fpWeb;

Type
 TdwModService = class(TFPWebModule)
  RESTServiceModule: TRESTServiceCGI;
  Constructor CreateNew       (AOwner     : TComponent;
                               CreateMode : Integer); Override;
  Procedure   DataModuleCreate(Sender : TObject);
 Private
  Procedure Request(Sender      : TObject;
                    ARequest    : TRequest;
                    AResponse   : TResponse;
                    Var Handled : Boolean);
 Public
 End;

Var
  dwModService: TdwModService;

implementation

{$R *.lfm}

Uses uDmService;

Procedure TdwModService.Request(Sender      : TObject;
                                ARequest    : TRequest;
                                AResponse   : TResponse;
                                Var Handled : Boolean);
Begin
 If RESTServiceModule <> Nil Then
  RESTServiceModule.Command(ARequest, AResponse, Handled);
End;

Constructor TdwModService.CreateNew(AOwner: TComponent; CreateMode: Integer);
Begin
 Inherited CreateNew(AOwner, CreateMode);
 onRequest := @Request;
End;

Procedure TdwModService.DataModuleCreate(Sender: TObject);
Begin
 RESTServiceModule.RootPath := '.\';
 RESTServiceModule.ServerMethodClass := TServerMethodDM;
End;

Initialization
 RegisterHTTPModule('', TdwModService);
end.

