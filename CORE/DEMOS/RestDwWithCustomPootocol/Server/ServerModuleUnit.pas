unit ServerModuleUnit;

interface

uses
  System.SysUtils, System.Classes;

type
  TServerModule = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServerModule: TServerModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
