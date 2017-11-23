unit Protocol;

interface

uses
  Classes, System.SysUtils, uDWJSONObject, uDWConsts, uDWConstsData;

type
  TDMLType = (dtSelect, dtCommand);

  TBasicRequest = class(TDWParams)
    constructor Create(AEncoding: TEncodeSelect); reintroduce;
  private
    AdditionalExceptionInfo: TStringList;
    ProtocolParams: TStringList;
    ParamNames: array of string;
    ParamValues: array of Variant;
    function GetRequestId: string;
    procedure SetRequestId(const Value: string);
    function GetInitialParamIndex: Integer;
    function GetServerTimeToProcess: Integer;
    function GetTerminalId: string;
    function GetUserName: string;
    procedure SetTerminalId(const Value: string);
    procedure SetUserName(const Value: string);
  protected
    procedure AddInternalJSONParam(ParamValue: Variant; ParamName: string = '');
  public
    procedure AddJSONParam(ParamValue: Variant; ParamName: string = '');
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure RaiseServerException(const Response: string);
    procedure MountParams;
    property RequestId: string read GetRequestId write SetRequestId;
    property TerminalID: string read GetTerminalId write SetTerminalId;
    property UserName: string read GetUserName Write SetUserName;
    property ServerTimeToProcess: Integer read GetServerTimeToProcess;
    property InitialParamIndex: Integer read GetInitialParamIndex;

  end;

  TDataBaseRequest = class(TBasicRequest)
  private
    FDataBaseIndex: Integer;
    FDataBaseParams: string;
    procedure SetDataBaseParams(const Value: string);

    procedure SetDataBaseIndex(const Value: Integer);
    function GetDataBaseIndex: Integer;
    function GetSqlCount: Integer;
    procedure SetSqlCount(const Value: Integer);
  public
    procedure AfterConstruction; override;
    property DataBaseIndex: Integer read GetDataBaseIndex write SetDataBaseIndex;
    property DataBaseParams: string read FDataBaseParams write SetDataBaseParams;
    property SqlCount: Integer read GetSqlCount write SetSqlCount;
  end;

const
  DATABASE_INDEX = 'DataBaseIndex';
  DATABASE_PARAMS = 'DataBaseParams';
  SQL_COUNT = 'SqlCount';
  REQUEST_ID = 'RequestId';
  TERMINAL_ID = 'TerminalId';
  USER_NAME = 'UserName';
  SERVER_TIME_TO_PROCESS = 'ServerTimeToProcess';
  TRANSFER_TIME = 'TransferTime';
  INITIAL_PARAM_INDEX = 'InitialParamIndex';
  EXCEPTION_CLASS_NAME = 'ExceptionClassName';
  EXCEPTION_MESSAGE = 'ExceptionMessage';

  RESPONSE_OK = 'RESPONSE_OK';
  RESPONSE_EXCEPTION = 'RESPONSE_EXCEPTION';

function Guid: string;

implementation

function Guid: string;
var
  gdStr: TGuId;
begin
  CreateGUID(gdStr);
  Result := GUIDToString(gdStr);
end;
{ TDataBaseRequest }

procedure TDataBaseRequest.AfterConstruction;
begin
  inherited;
  ProtocolParams.Values[DATABASE_INDEX] := '0';
  ProtocolParams.Values[DATABASE_PARAMS] := '0';
  ProtocolParams.Values[SQL_COUNT] := '1';
end;

function TDataBaseRequest.GetDataBaseIndex: Integer;
var
  sDataBaseIndex: string;
begin
  sDataBaseIndex := Trim(ProtocolParams.Values[DATABASE_INDEX]);
  if sDataBaseIndex = '' then
    sDataBaseIndex := '0';
  Result := StrToInt(sDataBaseIndex);
end;

function TDataBaseRequest.GetSqlCount: Integer;
var
  sSqlCount: string;
begin
  sSqlCount := Trim(ProtocolParams.Values[SQL_COUNT]);
  if sSqlCount = '' then
    sSqlCount := '1';
  Result := StrToInt(ProtocolParams.Values[SQL_COUNT]);
end;

procedure TDataBaseRequest.SetDataBaseIndex(const Value: Integer);
begin
  ProtocolParams.Values[DATABASE_INDEX] := IntToStr(Value);
end;

procedure TDataBaseRequest.SetDataBaseParams(const Value: string);
begin
  FDataBaseParams := Value;
  AddJSONParam(Value);
end;

procedure TDataBaseRequest.SetSqlCount(const Value: Integer);
begin
  ProtocolParams.Values[SQL_COUNT] := IntToStr(Value);
end;

{ TBasicRequest }

procedure TBasicRequest.AddInternalJSONParam(ParamValue: Variant;
  ParamName: string);
var
  JSONParam: TJSONParam;
  JSONValue: uDWJSONObject.TJSONValue;
begin
  JSONParam := TJSONParam.Create(Encoding);
  JSONParam.ParamName := ParamName;
  JSONParam.SetValue(ParamValue);
  Add(JSONParam);
end;

procedure TBasicRequest.AddJSONParam(ParamValue: Variant;
  ParamName: string = '');
begin
  SetLength(ParamNames, Length(ParamNames) + 1);
  if Trim(ParamName) = '' then
    ParamName := IntToStr(High(ParamNames));
  ParamNames[High(ParamNames)] := ParamName;

  SetLength(ParamValues, Length(ParamValues) + 1);
  ParamValues[High(ParamValues)] := ParamValue;
end;

procedure TBasicRequest.AfterConstruction;
begin
  inherited;
  AdditionalExceptionInfo := TStringList.Create;
  ProtocolParams := TStringList.Create;
  ProtocolParams.Values[REQUEST_ID] := Guid;
  ProtocolParams.Values[TERMINAL_ID] := Guid;
  ProtocolParams.Values[USER_NAME] := USER_NAME;
  ProtocolParams.Values[SERVER_TIME_TO_PROCESS] := '0';
  ProtocolParams.Values[TRANSFER_TIME] := '0';
  ProtocolParams.Values[INITIAL_PARAM_INDEX] := '0';
end;

procedure TBasicRequest.BeforeDestruction;
begin
  FreeAndNil(AdditionalExceptionInfo);
  FreeAndNil(ProtocolParams);
  inherited;
end;

constructor TBasicRequest.Create(AEncoding: TEncodeSelect);
begin
  inherited Create;
  Encoding := GetEncoding(AEncoding);
end;

function TBasicRequest.GetInitialParamIndex: Integer;
begin
  Result := StrToInt(ProtocolParams.Values[INITIAL_PARAM_INDEX]);
end;

function TBasicRequest.GetRequestId: string;
begin
  Result := ProtocolParams.Values[REQUEST_ID];
end;

function TBasicRequest.GetServerTimeToProcess: Integer;
begin
  Result := StrToInt(ProtocolParams.Values[SERVER_TIME_TO_PROCESS]);

end;

function TBasicRequest.GetTerminalId: string;
begin
  Result := ProtocolParams.Values[TERMINAL_ID];
end;

function TBasicRequest.GetUserName: string;
begin
  Result := ProtocolParams.Values[USER_NAME];
end;

procedure TBasicRequest.MountParams;
var
  I, L: ShortInt;
  JSONParam: TJSONParam;
  sParamName: string;
  JSONValue: uDWJSONObject.TJSONValue;
begin
  ProtocolParams.Values[INITIAL_PARAM_INDEX] := IntToStr(ProtocolParams.Count);

  L := ProtocolParams.Count - 1;
  for I := 0 to L do begin
    sParamName := ProtocolParams.Names[I];
    AddInternalJSONParam(ProtocolParams.Values[sParamName], sParamName);
  end;

  L := High(ParamNames);
  for I := 0 to L do begin
    JSONParam := TJSONParam.Create(Encoding);
    JSONParam.ParamName := ParamNames[I];
    JSONParam.SetValue(ParamValues[I]);
    Add(JSONParam);
  end;
end;

procedure TBasicRequest.RaiseServerException(const Response: string);
var
  sExceptionClassName, sExceptionMessage: string;
begin
  if Response = 'EXCEPTION' then begin
    sExceptionClassName := ItemsString['ClassName'].Value;
    sExceptionMessage := ItemsString['Message'].Value;
    sExceptionMessage := sExceptionMessage + #13#10 + AdditionalExceptionInfo.Text;
    AdditionalExceptionInfo.Clear;
    raise Exception.Create(sExceptionClassName + #13#10 + #13#10 +
      sExceptionMessage);
  end;
end;

procedure TBasicRequest.SetRequestId(const Value: string);
begin
  ProtocolParams.Values[REQUEST_ID] := Value;
end;

procedure TBasicRequest.SetTerminalId(const Value: string);
begin
  ProtocolParams.Values[TERMINAL_ID] := Value;
end;

procedure TBasicRequest.SetUserName(const Value: string);
begin
  ProtocolParams.Values[USER_NAME] := Value;
end;

end.
