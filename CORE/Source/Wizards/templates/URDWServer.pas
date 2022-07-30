unit %0:s;

interface

uses
  Windows, Messages, 
  SysUtils, Variants, Classes, 
  Graphics, Controls, Forms, Dialogs, WinXCtrls,
  uRESTDWAbout, uRESTDWBasic, uRESTDWIdBase;

type
  T%1:s = class(%2:s)
    ToggleSwitch1: TToggleSwitch;
    RESTDWIdServicePooler1: TRESTDWIdServicePooler;
    procedure FormCreate(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
   %1:s: T%1:s;

implementation

uses
  uDM;

{$R *.dfm}

procedure T%1:s.FormCreate(Sender: TObject);
begin
  RESTDWIdServicePooler1.ServerMethodClass := TDM;
end;

procedure T%1:s.ToggleSwitch1Click(Sender: TObject);
begin
  RESTDWIdServicePooler1.Active := ToggleSwitch1.State = tssOn;
end;

end.