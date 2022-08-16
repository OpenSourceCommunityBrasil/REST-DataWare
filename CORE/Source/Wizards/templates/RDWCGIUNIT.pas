unit %0:s;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, uRESTDWComponentBase,
  uRESTDWBasic, uRESTDWShellServices,%4:s;

type
  T%1:s = class(%2:s)
    RESTDWShellService1: TRESTDWShellService;
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = T%1:s;
  
implementation


{$R *.dfm}

procedure T%1:s.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  If RESTDWShellService1 <> Nil Then
  RESTDWShellService1.Command(Request, Response, Handled);
end;

procedure T%1:s.WebModuleCreate(Sender: TObject);
begin
  RESTDWShellService1.RootPath := '.\';
  RESTDWShellService1.ServerMethodClass := T%1:s;
end;

end.
