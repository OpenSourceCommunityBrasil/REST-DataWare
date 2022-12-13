unit uRESTDWFDClientSQL;

interface

uses
  Classes, SysUtils, FireDAC.Comp.Client, FireDAC.DApt.Intf, FireDAC.DApt,
  DB, uRESTDWClientSQLEngine, uRESTDWBasicDB, uRESTDWPoolermethod,
  FireDAC.Stan.StorageBin, uRESTDWStorageBase, FireDAC.Stan.Intf,
  uRESTDWCharset, uRESTDWMemoryDataset;

type
  TRESTDWFDClientSQL = class(TRESTDWMemTable, IRESTDWClientEngine)
  private
    FClientSQL : TRESTDWClientSQLEngine;
    FRESTDWStorage  : TRESTDWStorageBase;
    {$IFDEF FPC}
      FDatabaseCharSet : TDatabaseCharSet;
    {$ENDIF}
    function getSQL: TStringList;
    function getParams: TParams;
    function getDataBase: TRESTDWDatabasebaseBase;
    function getBinaryCompatibleMode: boolean;

    procedure setDataBase(const AValue: TRESTDWDatabasebaseBase);
    procedure setBinaryCompatibleMode(const AValue: boolean);
  protected
    procedure loadStream(stream : TStream);
    function findFieldName(name : string) : TField;
    function getDataset : TDataSet;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    procedure ExecSQL;
    procedure Open; overload;

    function ParamByName(const AValue: string): TParam; overload;

    procedure SaveToStream(stream : TStream); overload;
    procedure LoadFromStream(stream : TStream); overload;
  published
    property DataBase : TRESTDWDatabasebaseBase read getDataBase write setDataBase;
    property SQL : TStringList read getSQL;
    property Params : TParams read getParams;
    property BinaryCompatibleMode : boolean read getBinaryCompatibleMode write setBinaryCompatibleMode;
    property RESTDWStorage : TRESTDWStorageBase read FRESTDWStorage write FRESTDWStorage;
    {$IFDEF FPC}
      property DatabaseCharSet : TDatabaseCharSet read FDatabaseCharSet write FDatabaseCharSet;
    {$ENDIF}
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - ClientEngines', [TRESTDWFDClientSQL]);
end;

{ TRESTDWPhysicFireDAC }

constructor TRESTDWFDClientSQL.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FClientSQL := TRESTDWClientSQLEngine.Create(Self);
  FClientSQL.setMemTable(Self);
end;

destructor TRESTDWFDClientSQL.Destroy;
begin
  FClientSQL.Free;
  inherited;
end;

procedure TRESTDWFDClientSQL.ExecSQL;
begin
  FClientSQL.ExecSQL;
end;

function TRESTDWFDClientSQL.findFieldName(name: string): TField;
begin
  Result := FindField(name);
end;

function TRESTDWFDClientSQL.getBinaryCompatibleMode: boolean;
begin
  Result := FClientSQL.BinaryCompatibleMode;
end;

function TRESTDWFDClientSQL.getDataBase: TRESTDWDatabasebaseBase;
begin
  Result := FClientSQL.DataBase;
end;

function TRESTDWFDClientSQL.getDataset: TDataSet;
begin
  Result := Self;
end;

function TRESTDWFDClientSQL.getParams: TParams;
begin
  Result := FClientSQL.Params;
end;

function TRESTDWFDClientSQL.getSQL: TStringList;
begin
  Result := FClientSQL.SQL;
end;

procedure TRESTDWFDClientSQL.loadStream(stream: TStream);
begin
  Close;
  stream.Position := 0;
  Self.LoadFromStream(stream);
end;

procedure TRESTDWFDClientSQL.LoadFromStream(stream: TStream);
begin
  if Assigned(FRESTDWStorage) then begin
    {$IFDEF FPC}
      FRESTDWStorage.DatabaseCharSet := FDatabaseCharSet;
    {$ENDIF}
    FRESTDWStorage.EncodeStrs := DataBase.EncodedStrings;

    DisableControls;
    FRESTDWStorage.LoadDatasetFromStream(Self,stream);
    EnableControls;
  end;
//  else begin
//    inherited LoadFromStream(stream,sfBinary);
//  end;
end;

procedure TRESTDWFDClientSQL.Open;
begin
  FClientSQL.Open;
  inherited Open;
end;

function TRESTDWFDClientSQL.ParamByName(const AValue: string): TParam;
begin
  Result := FClientSQL.Params.ParamByName(AValue);
end;

procedure TRESTDWFDClientSQL.SaveToStream(stream: TStream);
begin
  if Assigned(FRESTDWStorage) then begin
    {$IFDEF FPC}
      FRESTDWStorage.DatabaseCharSet := FDatabaseCharSet;
    {$ENDIF}
    FRESTDWStorage.EncodeStrs := DataBase.EncodedStrings;
    FRESTDWStorage.SaveDatasetToStream(self,stream);
  end;
//  else begin
//    inherited SaveToStream(stream,sfBinary);
//  end;
end;

procedure TRESTDWFDClientSQL.setBinaryCompatibleMode(const AValue: boolean);
begin
  FClientSQL.BinaryCompatibleMode := AValue;
end;

procedure TRESTDWFDClientSQL.setDataBase(const AValue: TRESTDWDatabasebaseBase);
begin
  FClientSQL.DataBase := AValue;
end;

end.
