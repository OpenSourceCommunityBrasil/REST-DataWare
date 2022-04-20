unit RDWDM;

interface

uses
  System.SysUtils, System.Classes, uDWDatamodule, uDWAbout, uRESTDWServerEvents,
  uDWJSONObject;

type
  TDM = class(TServerMethodDataModule)
    DWServerEvents1: TDWServerEvents;
    procedure DWServerEvents1EventshelloReplyEvent(var Params: TDWParams;
      var Result: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DWServerEvents1EventshelloReplyEvent(var Params: TDWParams;
  var Result: string);
begin
  Result := 'hello';
end;

end.
