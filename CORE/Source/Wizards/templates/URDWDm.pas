Unit %0:s;

Interface

Uses
  SysUtils, Classes,
  uRESTDWComponentBase, uRESTDWServerEvents, uRESTDWDatamodule, uRESTDWParams,
  uRESTDWConsts;

Type
  T%1:s = class(%2:s)
    RESTDWServerEvents1: TRESTDWServerEvents;
    procedure RESTDWServerEvents1EventstesteReplyEventByType
      (var Params: TRESTDWParams; var Result: string;
      const RequestType: TRequestType; var StatusCode: Integer;
      RequestHeader: TStringList);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
 %1:s: T%1:s;

Implementation

{$R *.dfm}

procedure T%1:s.RESTDWServerEvents1EventstesteReplyEventByType
  (var Params: TRESTDWParams; var Result: string;
  const RequestType: TRequestType; var StatusCode: Integer;
  RequestHeader: TStringList);
begin
  case RequestType of
    rtGet, rtDelete:
      StatusCode := 200;
    rtPost, rtPut, rtPatch:
      StatusCode := 201;
  end;
end;

End.
