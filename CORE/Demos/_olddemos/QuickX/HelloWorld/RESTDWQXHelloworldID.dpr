program RESTDWQXHelloworldID;

{$APPTYPE CONSOLE}

Uses
  Classes,
  SysUtils,
  uDWConsts,
  uDWJSONObject,
  uDWJSONTools,
  uRESTDWBaseIDQX,
  //Classes do Firedac
  FireDAC.Comp.Client, FireDAC.Dapt, FireDAC.Phys.FBDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB;

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
 Server_FDConnection : TFDConnection;
 FDQuery             : TFDQuery;
Begin
 JSONValue           := TJSONValue.Create;
 Server_FDConnection := TFDConnection.Create(Nil);
 Server_FDConnection.DriverName := 'FB';
 Server_FDConnection.Params.Add('DriverID=FB');
 Server_FDConnection.Params.Add('Server=localhost');
 Server_FDConnection.Params.Add('Port=3050');
 Server_FDConnection.Params.Add('Database='  + cDatabaseName);
 Server_FDConnection.Params.Add('User_Name=sysdba');
 Server_FDConnection.Params.Add('Password=masterkey');
 Server_FDConnection.Params.Add('Protocol=TCPIP');
 FDQuery             := TFDQuery.Create(Nil);
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
 RESTDWServerQXID.AddUrl('helloworld', [crGet, crPost], Helloworld);
 RESTDWServerQXID.AddUrl('hellofile',  [crGet, crPost], Hellofile);
 RESTDWServerQXID.AddUrl('employee',   [crGet, crPost], employee);
 RESTDWServerQXID.Bind;
End.

