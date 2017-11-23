unit MyServerMethods;

interface

uses Windows, SysUtils, Classes, System.JSON,
  SysTypes, uDWJSONObject, Winapi.ShellAPI, TypInfo, ServerUtils,
  uDWConstsData, uDWConsts, uDWJSONTools, ServerModuleUnit, Db,
{$IFDEF FIREDAC}
  FireDacUnit,
{$ENDIF}
{$IFDEF ZEOS}
  ZeosUnit,
{$ENDIF}
  Protocol,
  ServerDataModuleUnit;

Type
  TMyServerMethods = class(TServerMethods)
  private
    FNextParamIndex: Integer;
    ServerDataModule: TServerDataModule;
    DWParams: TDWParams;
    Context: string;
    procedure ExecuteDML;
    procedure Download;
    procedure Dir;
    procedure ClassMethod;
    function GetNextParamIndex: Integer;
    property NextParamIndex: Integer read GetNextParamIndex;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reply(SendType: TSendEvent; Context: string;
      var Params: TDWParams; var Result: string);
  end;

implementation

uses
  mmsystem;

procedure TMyServerMethods.Reply(SendType: TSendEvent; Context: String;
  var Params: TDWParams; var Result: String);
var
  JSONParam: TJSONParam;
  StartTime, ProcessTime: Cardinal;
begin
  DWParams := Params;
  Self.Context := Context;
  try
    try
      StartTime := TimeGetTime;
      case SendType of
        seGET:
          ;
        sePOST:
          begin
            { Comandos SELECT, INSERT, UPDATE, DELETE }
            if Context = 'ExecuteDML' then
              ExecuteDML
              { Download de um arquivo }
            else if Context = 'Download' then
              Download
              { Listar um diretório (Pasta) }
            else if Context = 'Dir' then
              Dir
              { Executar o método de uma classe }
            else if Context = 'ClassMethod' then
              ClassMethod
            else
              raise Exception.Create('Comando ' + Context + ' desconhecido!');
          end;
        sePUT:
          ;
        seDELETE:
          ;
      end;
      Result := RESPONSE_OK;
    except
      on E: Exception do begin
        Result := RESPONSE_EXCEPTION;

        JSONParam := TJSONParam.Create(Params.Encoding);
        JSONParam.ParamName := EXCEPTION_CLASS_NAME;
        JSONParam.SetValue(E.ClassName);
        Params.Add(JSONParam);

        JSONParam := TJSONParam.Create(Params.Encoding);
        JSONParam.ParamName := EXCEPTION_MESSAGE;
        JSONParam.SetValue(E.Message);
        Params.Add(JSONParam);
      end;

    end;
  finally
    ProcessTime := TimeGetTime - StartTime;
    Params.ItemsString[SERVER_TIME_TO_PROCESS].SetValue(IntToStr(ProcessTime));
  end;
end;

procedure TMyServerMethods.ClassMethod;
begin

end;

constructor TMyServerMethods.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  ReplyEvent := Reply;

{$IFDEF FIREDAC}
  ServerDataModule := TFireDac.Create(Self);
{$ENDIF}
{$IFDEF ZEOS}
  ServerDataModule := TZeos.Create(Self);
{$ENDIF}
  FNextParamIndex := -1;
end;

destructor TMyServerMethods.Destroy;
begin
  inherited Destroy;
end;

procedure TMyServerMethods.Dir;
begin

end;

procedure TMyServerMethods.Download;
begin

end;

procedure TMyServerMethods.ExecuteDML;
var
  sSQL: String;
  JSONValue: TJSONValue;
  TotSql: Integer;
  TotParam: Integer;
  S, P: Integer;
  Params: TParams;
  SqlIndex: Integer;
  DMLType: TDMLType;
  sDataBaseParams: string;
begin
  { SGDB Driver Index }
  ServerDataModule.DataBaseIndex :=
    StrToInt(DWParams.ItemsString[DATABASE_INDEX].Value);

  { Parâmetros de conexão - Em branco se optar por configuração dentro do server }
  sDataBaseParams := DWParams.ItemsString[DATABASE_PARAMS].Value;
  if sDataBaseParams <> '0' then
    ServerDataModule.DataBaseParams.Text := sDataBaseParams;

  try
    ServerDataModule.StartTransaction;
    { Quantidade de comandos SQL }
    TotSql := StrToInt(DWParams.ItemsString[SQL_COUNT].Value);
    for S := 1 to TotSql do begin
      { SQL sentence }
      SqlIndex := NextParamIndex;
      sSQL := DWParams.Items[SqlIndex].Value;

      { DML Type }
      DMLType := TDMLType(StrToInt(DWParams.Items[NextParamIndex].Value));

      { Total SQL Params }
      TotParam := StrToInt(DWParams.Items[NextParamIndex].Value);
      try
        if TotParam > 0 then begin
          Params := TParams.Create(nil);
          for P := 1 to TotParam do begin
            { Add a param }
            with Params.AddParameter do begin
              { Param name }
              Name := DWParams.Items[NextParamIndex].Value;

              { Param type }
              DataType :=
                TFieldType(StrToInt(DWParams.Items[NextParamIndex].Value));

              { Param value }
              Value := DWParams.Items[NextParamIndex].Value;
            end;
          end;
        end;
        case DMLType of
          dtSelect: begin
              try
                JSONValue := uDWJSONObject.TJSONValue.Create;
                JSONValue.Encoding := GetEncoding(Encoding);
                JSONValue.LoadFromDataset('DATASET',
                  ServerDataModule.ExecuteQuery(sSQL, Params));
                DWParams.Items[SqlIndex].SetValue(JSONValue.ToJSON);
              finally
                FreeAndNil(JSONValue);
              end;
            end;

          dtCommand: begin
              ServerDataModule.ExecuteCommand(sSQL, Params);
            end;
        end;

      finally
        FreeAndNil(Params);
      end;

    end;
    ServerDataModule.CommitTransaction;
  except
    on E: Exception do begin
      ServerDataModule.RollbackTransaction;
      E.Message := E.Message + #13#10 + sSQL;
      raise;
    end;
  end;

end;

function TMyServerMethods.GetNextParamIndex: Integer;
begin
  if FNextParamIndex = -1 then begin
    FNextParamIndex :=
      StrToInt(DWParams.ItemsString[INITIAL_PARAM_INDEX].Value);
  end else begin
    FNextParamIndex := FNextParamIndex + 1;
  end;
  Result := FNextParamIndex;
end;

end.
