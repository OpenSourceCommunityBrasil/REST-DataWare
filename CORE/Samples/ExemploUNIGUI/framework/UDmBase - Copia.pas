unit UDmBase;

interface

uses
  SysUtils, Classes;

type
  TDmBase = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function DmBase: TDmBase;

implementation

{$R *.dfm}

uses
  UniGUIVars, uniGUIMainModule, MainModule;

function DmBase: TDmBase;
begin
  Result := TDmBase(UniMainModule.GetModuleInstance(TDmBase));
end;

initialization
  RegisterModuleClass(TDmBase);

end.
