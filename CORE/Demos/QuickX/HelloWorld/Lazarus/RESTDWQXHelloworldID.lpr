program RESTDWQXHelloworldID;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  SysUtils,
  uDWConsts,
  uDWJSONObject,
  uDWJSONTools,
  uRESTDWBaseIDQX,
  //Classes do Zeos
  ZAbstractConnection, ZConnection,
  ZAbstractRODataset, ZAbstractDataset, ZDataset;

Const
 cDatabaseName = 'D:\Meus Dados\Projetos\SUGV\Componentes\XyberPower\REST_Controls\CORE\Demos\Employee.fdb';

Var
 RESTDWServerQXID : TRESTDWServerQXID;

Procedure Helloworld (Sender                : TObject;
                      RequestHeader         : TStringList;
                      Const Params          : TDWParams;
                      Var   ContentType     : String;
                      Var   Result          : String;
                      Const RequestType     : TRequestType;
                      Var   StatusCode      : Integer;
                      Var   ErrorMessage    : String;
                      Var   OutCustomHeader : TStringList);
Begin
 Case RequestType of
  rtGet    : Begin
              ContentType := 'text/html';
              Result      := '<html><head></head><body><h1>Hello World<h1></body></html>';
             End;
  rtPost   : Result       := '{"json":"Hello World - POST"}';
 End;
End;

Procedure employee (Sender                : TObject;
                      RequestHeader         : TStringList;
                      Const Params          : TDWParams;
                      Var   ContentType     : String;
                      Var   Result          : String;
                      Const RequestType     : TRequestType;
                      Var   StatusCode      : Integer;
                      Var   ErrorMessage    : String;
                      Var   OutCustomHeader : TStringList);
Var
 JSONValue           : TJSONValue;
 Server_FDConnection : TZConnection;
 FDQuery             : TZQuery;
Begin
 JSONValue           := TJSONValue.Create;
 Server_FDConnection := TZConnection.Create(Nil);
 Server_FDConnection.Protocol := 'firebird-2.5';
 Server_FDConnection.HostName := 'localhost';
 Server_FDConnection.Port     := 3050;
 Server_FDConnection.Database := cDatabaseName;
 Server_FDConnection.User     := 'sysdba';
 Server_FDConnection.Password := 'masterkey';
 FDQuery             := TZQuery.Create(Nil);
 FDQuery.Connection  := Server_FDConnection;
 FDQuery.SQL.Add('Select * from employee');
 Try
  JSONValue.JsonMode := jmPureJSON;
  JSONValue.LoadFromDataset('', FDQuery, False, JSONValue.JsonMode);
  Result := JSONValue.ToJSON;
 Finally
  FreeAndNil(Server_FDConnection);
  FreeAndNil(FDQuery);
  FreeAndNil(JSONValue);
 End;
End;

Procedure Hellofile  (Sender                : TObject;
                      RequestHeader         : TStringList;
                      Const Params          : TDWParams;
                      Var   ContentType     : String;
                      Const Result          : TMemoryStream;
                      Const RequestType     : TRequestType;
                      Var   StatusCode      : Integer;
                      Var   ErrorMessage    : String;
                      Var   OutCustomHeader : TStringList);
Var
 vStringFile : TStringStream;
 vResultFile : TMemoryStream;
Begin
 vResultFile := TMemoryStream.Create;
 Try
  Case RequestType of
   rtGet    : Begin
               ContentType := 'image/png';
               Result.LoadFromFile(ExtractFilePath(ParamSTR(0)) + '\rdw.png');
              End;
   rtPost   : Begin
               vResultFile.LoadFromFile(ExtractFilePath(ParamSTR(0)) + '\rdw.png');
               Try
                vStringFile := TStringStream.Create(Format('{"fileb64":"%s"}', [Encodeb64Stream(vResultFile)]));
                vStringFile.Position := 0;
                Result.CopyFrom(vStringFile, vStringFile.Size);
                Result.Position := 0;
               Finally
                FreeAndNil(vStringFile);
               End;
              End;
  End;
 Finally
  FreeAndNil(vResultFile);
 End;
End;

Begin
 RESTDWServerQXID := TRESTDWServerQXID.Create(Nil);
 RESTDWServerQXID.AddUrl('helloworld', [crGet, crPost], @Helloworld);
 RESTDWServerQXID.AddUrl('hellofile',  [crGet, crPost], @Hellofile);
 RESTDWServerQXID.AddUrl('employee',   [crGet, crPost], @employee);
 RESTDWServerQXID.Bind;
End.



