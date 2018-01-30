unit ServerDataModuleUnit;

interface

uses
  System.SysUtils, System.Classes, Data.DB;

type
  TServerDataModule = class(TDataModule)
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    FDataBaseIndex: Integer;
    procedure SetDataBaseIndex(const Value: Integer);
  public
    DataBaseParams: TStrings;
    procedure StartTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;
    procedure RollbackTransaction; virtual; abstract;
    function ExecuteQuery(SQL: string; Params: TParams = nil): TDataSet; virtual; abstract;
    procedure ExecuteCommand(DML: string; Params: TParams = nil); virtual; abstract;
    property DataBaseIndex: Integer read FDataBaseIndex write SetDataBaseIndex;
  end;

var
  ServerDataModule: TServerDataModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TServerDataModule.DataModuleCreate(Sender: TObject);
begin
  DataBaseParams := TStringList.Create;
end;

procedure TServerDataModule.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(DataBaseParams);
end;

procedure TServerDataModule.SetDataBaseIndex(const Value: Integer);
begin
  FDataBaseIndex := Value;
end;

end.
