unit uRESTDWClientSQLEngine;

interface

uses
  Classes, SysUtils, DB, uRESTDWResponseTranslator, uRESTDWBasicDB,
  uRESTDWParams, uRESTDWBasicClass, uRESTDWPoolermethod, uRESTDWConsts,
  uRESTDWTools;

type
  IRESTDWClientEngine = interface
    procedure loadStream(stream : TStream);
    function findFieldName(name : string) : TField;
    function getDataset : TDataSet;
  end;

  TRESTDWClientSQLEngine = class(TComponent)
  private
    FMemTable : IRESTDWClientEngine;
    FDataBase : TRESTDWDatabasebaseBase;
    FSQL : TStringList;
    FParams : TParams;
    FGetNewData : boolean;
    FOldSQL : string;

    FPoolerMethodClient : TRESTDWPoolerMethodClient;
    FBinaryCompatibleMode : Boolean;

    FRowsAffected : Longint;
  protected
    procedure executeOpen;
    function getData : boolean;
    procedure createParams;

    procedure OnChangingSQL(Sender  : TObject);
    procedure OnBeforeChangingSQL(Sender  : TObject);
  public
    procedure setMemTable(memtable : IRESTDWClientEngine);
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    procedure Open;
    procedure ExecSQL;
  published
    property DataBase : TRESTDWDatabasebaseBase read FDataBase write FDataBase;
    property SQL : TStringList read FSQL;
    property Params : TParams read FParams;

    property BinaryCompatibleMode : boolean read FBinaryCompatibleMode write FBinaryCompatibleMode;
  end;

implementation

Function ScanParams(SQL : string) : TStringList;
var
  FCurrentPos : PChar;
  vParamName  : String;
  bEscape1,
  bEscape2,
  bParam     : boolean;
  vOldChar   : Char;

const
  endParam : set of Char = [';', '=','>','<',' ',',','(',')','-','+','/','*','!',
                            '''','"','|',#0..#31,#127..#255];
  procedure AddParamSQL;
  begin
    vParamName := Trim(vParamName);
    if vParamName <> '' then begin
      if Result.IndexOf(vParamName) < 0 Then
        Result.Add(vParamName);
    end;
    bParam := False;
    vParamName := '';
  end;
begin
  Result := TStringList.Create;
  FCurrentPos := PChar(SQL);
  bEscape1 := False;
  bEscape2 := False;
  bParam := False;
  while Not (FCurrentPos^ = #0) do begin
    if (FCurrentPos^ = '''') and (Not bEscape2) and (not (bEscape1 and (vOldChar = '\'))) then begin
      AddParamSQL;
      bEscape1 := not bEscape1;
    end
    else If (FCurrentPos^ = '"') and (Not bEscape1) and (not (bEscape2 and (vOldChar = '\'))) then begin
      AddParamSQL;
      bEscape2 := not bEscape2;
    end
    else if (FCurrentPos^ = ':') and (Not bEscape1) and (not bEscape2) then begin
      AddParamSQL;
      bParam := vOldChar in endParam;
    end
    else if (bParam) then begin
      if (not (FCurrentPos^ In endParam)) then
        vParamName := vParamName + FCurrentPos^
      else
        AddParamSQL;
    end;
    vOldChar := FCurrentPos^;
    Inc(FCurrentPos);
  end;
  AddParamSQL;
End;

Function ReturnParamsAtual(ParamsList : TParams) : TStringList;
var
  i : Integer;
Begin
  Result := Nil;
  if ParamsList.Count > 0 then begin
    Result := TStringList.Create;
    for i := 0 To ParamsList.Count-1 Do
      Result.Add(ParamsList[i].Name);
  end;
End;

{ TRESTDWClientSQLEngine }

constructor TRESTDWClientSQLEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSQL := TStringList.Create;

 {$IFDEF FPC}
  FSQL.OnChanging := @OnBeforeChangingSQL;
  FSQL.OnChange   := @OnChangingSQL;
 {$ELSE}
  FSQL.OnChanging := OnBeforeChangingSQL;
  FSQL.OnChange   := OnChangingSQL;
 {$ENDIF}

  FParams := TParams.Create(Self);
  FPoolerMethodClient := TRESTDWPoolerMethodClient.Create(Self);
end;

procedure TRESTDWClientSQLEngine.createParams;
var
  I         : Integer;
  ParamsListAtual,
  ParamList : TStringList;

  procedure CreateParam(Value : String);
  var
    FieldDef : TField;

    function ParamSeek (Name : String) : Boolean;
    var
      ip : Integer;
    begin
      Result := False;
      for ip := 0 To FParams.Count-1 do begin
        Result := SameText(FParams.items[ip].Name,Name);
        if Result then
          Break;
      end;
    end;
  begin
    FieldDef := FMemTable.findFieldName(Value);
    if FieldDef <> nil then begin
      if not (ParamSeek(Value)) then begin
        FParams.CreateParam(FieldDef.DataType, Value, ptInput);
        FParams.ParamByName(Value).Size := FieldDef.Size;
      end
      else begin
        FParams.ParamByName(Value).DataType := FieldDef.DataType;
      end;
    end
    else if not(ParamSeek(Value)) then begin
      FParams.CreateParam(ftString, Value, ptInput);
    end;
  end;

  function CompareParams(A, B : TStringList) : Boolean;
  var
    j, x : Integer;
  begin
    Result := (A <> nil) and (B <> Nil);
    if Result then begin
      for j := 0 To A.Count -1 do begin
        for X := 0 To B.Count -1 do begin
          Result := SameText(A[j],B[X]);
          if Result then
            Break;
        end;
        if not Result Then
          Break;
      end;
    end;
    if Result then
      Result := B.Count > 0;
  end;

Begin
  ParamList       := ScanParams(FSQL.Text);
  ParamsListAtual := ReturnParamsAtual(FParams);

  if not CompareParams(ParamsListAtual, ParamList) Then
    FParams.Clear;

  if ParamList <> nil then begin
    for I := 0 to ParamList.Count -1 do
      CreateParam(ParamList[I]);
  end;

  FreeAndNil(ParamList);
  FreeAndNil(ParamsListAtual);
end;

destructor TRESTDWClientSQLEngine.Destroy;
begin
  FSQL.Free;
  FParams.Free;
  FPoolerMethodClient.Free;
  inherited;
end;

procedure TRESTDWClientSQLEngine.ExecSQL;
begin
  executeOpen;
end;

procedure TRESTDWClientSQLEngine.executeOpen;
begin
  if (FDataBase <> nil) then begin
    FDataBase.Active := True;
    if not FDataBase.Active then
      Exit;
    getData;
  end;
end;

function TRESTDWClientSQLEngine.getData: boolean;
var
  I             : Integer;
  LDataSetList  : TJSONValue;
  vMetadata,
  vError        : Boolean;
  vValue,
  vMessageError : String;
  vStream       : TMemoryStream;
begin
  vValue        := '';
  Result        := False;
  LDataSetList  := Nil;
  vStream       := Nil;
  FRowsAffected := 0;
  if Assigned(FDataBase) then begin
    try
      vMetadata := True;
      for I := 0 to 1 do begin
        FDataBase.ExecuteCommand(FPoolerMethodClient, FSQL, FParams, vError, vMessageError, LDataSetList,
                                 FRowsAffected, False, True, FBinaryCompatibleMode, vMetaData, FDataBase.RESTClientPooler);
        if Not(vError) or (vMessageError <> cInvalidAuth) then
         Break;
      end;

      if LDataSetList <> nil then begin
        if not LDataSetList.IsNull then begin
          vStream := TMemoryStream.Create;
          try
            LDataSetList.SaveToStream(vStream);
//            vStream.SaveToFile('d:\str_rdw1.txt');
            FMemTable.loadStream(vStream);

          finally
            vStream.Free;
          end
        end;
      end;
    except

    end;
  end;
end;

procedure TRESTDWClientSQLEngine.OnBeforeChangingSQL(Sender: TObject);
begin
  FOldSQL := FSQL.Text;
end;

procedure TRESTDWClientSQLEngine.OnChangingSQL(Sender: TObject);
begin
  FGetNewData := TStringList(Sender).Text <> FOldSQL;
  if FGetNewData then
   FOldSQL := TStringList(Sender).Text;
  createParams;
end;

procedure TRESTDWClientSQLEngine.Open;
begin
  executeOpen;
end;

procedure TRESTDWClientSQLEngine.setMemTable(memtable: IRESTDWClientEngine);
begin
  FMemTable := memtable;
end;

end.
