unit uDmClientDW;

interface

uses
  SysUtils, Classes, uRESTDWPoolerDB, uDWDatamodule;

type
  TDataModule2 = class(TServerMethodDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule2: TDataModule2;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
