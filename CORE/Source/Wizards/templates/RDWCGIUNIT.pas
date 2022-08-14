unit %0:s;

// Criação de Exemplo usando CGI para Apache Server feito por "Gilberto Rocha da Silva",
//para uso do Componente TRESTServiceCGI

interface

uses
  SysUtils, Classes, HTTPApp, WSDLPub, SOAPPasInv, SOAPHTTPPasInv,
  SOAPHTTPDisp, WebBrokerSOAP, Soap.InvokeRegistry, Soap.WSDLIntf,
  System.TypInfo, Soap.WebServExp, Soap.WSDLBind, Xml.XMLSchema,
  uRESTDWBase, uRESTDWComponentBase,%4:s;

type
  T%1:s = class(%2:s)
    RESTServiceCGI1: TRESTServiceCGI;
    procedure dwCGIServiceDefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  %1:s: T%1:s;

implementation

uses WebReq;

{$R *.dfm}


procedure T%1:s.dwCGIServiceDefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
 If RESTServiceCGI1 <> Nil Then
  RESTServiceCGI1.Command(Request, Response, Handled);
end;

procedure T%1:s.WebModuleCreate(Sender: TObject);
begin
 RESTServiceCGI1.RootPath := '.\';
 RESTServiceCGI1.ServerMethodClass := T%3:s;
end;

initialization
  WebRequestHandler.WebModuleClass := T%1:s;

end.
