unit FireDacUnit;

interface

uses
  System.SysUtils, System.Classes, ServerDataModuleUnit, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Forms, DIALOGS;

type
  TFireDac = class(TServerDataModule)
    FDConnection: TFDConnection;
    FDQuery: TFDQuery;
    procedure FDConnectionBeforeConnect(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure Prepare(SQL: string; Params: TParams = nil);

  public
    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;
    function ExecuteQuery(SQL: string; Params: TParams = nil)
      : TDataSet; override;
    procedure ExecuteCommand(SQL: string; Params: TParams = nil); override;
  end;

var
  FireDAC: TFireDac;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

procedure TFireDac.CommitTransaction;
begin
  inherited;
  FDConnection.Commit;
end;

procedure TFireDac.DataModuleCreate(Sender: TObject);
var
  sDataBase: string;
begin
  inherited;
  sDataBase := ExtractFilePath(Application.ExeName) + 'EMPLOYEE.FDB';
  FDConnection.Params.Values['DataBase'] := sDataBase;
end;

procedure TFireDac.DataModuleDestroy(Sender: TObject);
begin
  FDQuery.Close;
  FDConnection.Close;
  inherited;
end;

procedure TFireDac.ExecuteCommand(SQL: string; Params: TParams);
begin
  Prepare(SQL, Params);
  FDQuery.ExecSQL;
end;

function TFireDac.ExecuteQuery(SQL: string; Params: TParams): TDataSet;
begin
  Prepare(SQL, Params);
  FDQuery.Open;
  Result := FDQuery;
end;

procedure TFireDac.FDConnectionBeforeConnect(Sender: TObject);
begin
  inherited;
  if DataBaseParams.Text <> '' then begin
    if DataBaseIndex = 1 { FIREBIRD } then begin
      FDConnection.DriverName := 'FB';
    end;
    FDConnection.Params.Text := DataBaseParams.Text;
  end;
end;

procedure TFireDac.Prepare(SQL: string; Params: TParams);
var
  I: Integer;
begin
  if not FDConnection.Connected then
    FDConnection.Connected := True;
  FDQuery.Close;
  FDQuery.SQL.Text := SQL;
  if Params <> nil then
  begin
    for I := 0 to Params.Count - 1 do
    begin
      FDQuery.Params[I].Value := Params[I].Value;
    end;
  end;
end;

procedure TFireDac.RollbackTransaction;
begin
  inherited;
  FDConnection.Rollback;
end;

procedure TFireDac.StartTransaction;
begin
  inherited;
  FDConnection.StartTransaction;
end;

end.
