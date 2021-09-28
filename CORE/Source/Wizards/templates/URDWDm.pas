Unit %0:s;

Interface

Uses
  SysUtils,
  Classes,
  SysTypes,
  UDWDatamodule,
  UDWJSONObject,
  Dialogs,
  ServerUtils,
  UDWConstsData,
  URESTDWPoolerDB,
  uDWConsts, uRESTDWServerEvents,
  uSystemEvents, uDWAbout,
  uRESTDWServerContext,
  DB;

Type
  T%1:s = class(%2:s)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    procedure DWServerEvents1EventshelloworldReplyEvent(var Params: TDWParams;
      var Result: string);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
 %1:s: T%1:s;

Implementation

{$R *.dfm}

procedure T%1:s.DWServerEvents1EventshelloworldReplyEvent(
  var Params: TDWParams; var Result: string);
begin
 Result := '{"Message":"Hello World...RDW Online..."}';
end;

End.
