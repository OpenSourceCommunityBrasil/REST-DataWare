Unit %0:s;

interface

uses
  uRESTDWComponentBase,
  uRESTDWParams,
  uRESTDWServerEvents,
  uRESTDWDatamodule,
  System.Classes,
  System.SysUtils;

type
  T%1:s = class(%2:s)
    RESTDWServerEvents1: TRESTDWServerEvents;
    procedure RESTDWServerEvents1EventshelloworldReplyEvent(
      var Params: TRESTDWParams; var Result: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  %1:s: T%1:s;

implementation


{$R *.dfm}

procedure T%1:s.RESTDWServerEvents1EventshelloworldReplyEvent(
  var Params: TRESTDWParams; var Result: string);
begin
  Result := ('{"Message":"'+Params.Itemsstring['entrada'].Asstring+'"}');
end;