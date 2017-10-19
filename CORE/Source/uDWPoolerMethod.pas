unit uDWPoolerMethod;

Interface

Uses {$IFDEF FPC}
     SysUtils,   uDWConstsData, Classes, SysTypes,   ServerUtils, {$IFDEF WINDOWS}Windows,{$ENDIF}
     uDWConsts,          uRESTDWBase,        uDWJSONTools,        uDWJSONObject;
     {$ELSE}
     {$IF CompilerVersion < 21}
     SysUtils, Classes,
     {$ELSE}
     System.SysUtils, System.Classes,
     {$IFEND}
     SysTypes,   uDWConstsData, ServerUtils,        {$IFDEF WINDOWS} Windows, {$ENDIF}
     uDWConsts,  uRESTDWBase,        uDWJSONTools,     uDWJSONObject ;
     {$ENDIF}

 Type
  TDWPoolerMethodClient  = Class(TComponent)
  Private
   vOnWork               : TOnWork;
   vOnWorkBegin          : TOnWorkBegin;
   vOnWorkEnd            : TOnWorkEnd;
   vOnStatus             : TOnStatus;
   vCompression          : Boolean;
   {$IFNDEF FPC}
    {$if CompilerVersion > 21}
     vEncoding           : TEncodeSelect;
    {$IFEND}
   {$ENDIF}
   vWelcomeMessage,
   vHost : String;
   vPort : Integer;
   Procedure SetOnWork     (Value : TOnWork);
   Procedure SetOnWorkBegin(Value : TOnWorkBegin);
   Procedure SetOnWorkEnd  (Value : TOnWorkEnd);
   Procedure SetOnStatus   (Value : TOnStatus);
  Public
   Constructor Create(AOwner: TComponent);Override;
   Destructor  Destroy;Override;
   Function GetPoolerList         (Method_Prefix           : String;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : TStringList;Overload;
   Function EchoPooler            (Method_Prefix,
                                   Pooler                  : String;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : String;
   //Retorna todos os Poolers no DataModule do WebService
   Function PoolersDataSet        (Method_Prefix           : String;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : TStringList;
   //Roda Comando SQL
   Function InsertValue           (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Params                  : TDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : Integer;
   Function ExecuteCommand        (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Params                  : TDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Execute                 : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : TJSONValue;
   Function ExecuteCommandJSON    (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Params                  : TDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Execute                 : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : TJSONValue;
   Function InsertValuePure       (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : Integer;
   Function ExecuteCommandPure    (Pooler, Method_Prefix,
                                   SQL                     : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Execute                 : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : TJSONValue;
   Function ExecuteCommandPureJSON(Pooler,
                                   Method_Prefix,
                                   SQL                     : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   Execute                 : Boolean;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil)   : TJSONValue;
   //Executa um ApplyUpdate no Servidor
   Procedure   ApplyChangesPure   (Pooler, Method_Prefix,
                                   TableName,
                                   SQL                     : String;
                                   ADeltaList              : TDWDatalist;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil);
   Procedure   ApplyChanges       (Pooler, Method_Prefix,
                                   TableName,
                                   SQL                     : String;
                                   Params                  : TDWParams;
                                   ADeltaList              : TDWDatalist;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil);
   //Lista todos os Pooler's do Servidor
   Procedure GetPoolerList        (Method_Prefix           : String;
                                   Var PoolerList          : TStringList;
                                   TimeOut                 : Integer = 3000;
                                   UserName                : String  = '';
                                   Password                : String  = '';
                                   RESTClientPooler        : TRESTClientPooler = Nil);Overload;
   //StoredProc
   Procedure  ExecuteProcedure    (Pooler,
                                   Method_Prefix,
                                   ProcName                : String;
                                   Params                  : TDWParams;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   RESTClientPooler        : TRESTClientPooler = Nil);
   Procedure  ExecuteProcedurePure(Pooler,
                                   Method_Prefix,
                                   ProcName                : String;
                                   Var Error               : Boolean;
                                   Var MessageError        : String;
                                   RESTClientPooler        : TRESTClientPooler = Nil);
   Property Compression  : Boolean   Read vCompression Write vCompression;
  {$IFNDEF FPC}
   {$if CompilerVersion > 21}
   Property Encoding    : TEncodeSelect Read vEncoding    Write vEncoding;
   {$IFEND}
  {$ENDIF}
   Property Host           : String        Read vHost           Write vHost;
   Property Port           : Integer       Read vPort           Write vPort;
   Property WelcomeMessage : String        Read vWelcomeMessage Write vWelcomeMessage;
   Property OnWork         : TOnWork       Read vOnWork         Write SetOnWork;
   Property OnWorkBegin    : TOnWorkBegin  Read vOnWorkBegin    Write SetOnWorkBegin;
   Property OnWorkEnd      : TOnWorkEnd    Read vOnWorkEnd      Write SetOnWorkEnd;
   Property OnStatus       : TOnStatus     Read vOnStatus       Write SetOnStatus;
  End;

implementation


{ TDWPoolerMethodClient }

Procedure TDWPoolerMethodClient.ApplyChanges(Pooler, Method_Prefix,
                                             TableName,
                                             SQL                     : String;
                                             Params                  : TDWParams;
                                             ADeltaList              : TDWDatalist;
                                             Var Error               : Boolean;
                                             Var MessageError        : String;
                                             TimeOut                 : Integer = 3000;
                                             UserName                : String  = '';
                                             Password                : String  = '';
                                             RESTClientPooler        : TRESTClientPooler = Nil);
Begin

End;

Procedure TDWPoolerMethodClient.ApplyChangesPure(Pooler, Method_Prefix,
                                                 TableName,
                                                 SQL                     : String;
                                                 ADeltaList              : TDWDatalist;
                                                 Var Error               : Boolean;
                                                 Var MessageError        : String;
                                                 TimeOut                 : Integer = 3000;
                                                 UserName                : String  = '';
                                                 Password                : String  = '';
                                                 RESTClientPooler        : TRESTClientPooler = Nil);
Begin

End;

Procedure TDWPoolerMethodClient.SetOnStatus(Value : TOnStatus);
Begin
 {$IFDEF FPC}
  vOnStatus            := Value;
 {$ELSE}
  vOnStatus            := Value;
 {$ENDIF}
End;

Procedure TDWPoolerMethodClient.SetOnWork(Value : TOnWork);
Begin
 {$IFDEF FPC}
  vOnWork            := Value;
 {$ELSE}
  vOnWork            := Value;
 {$ENDIF}
End;

Procedure TDWPoolerMethodClient.SetOnWorkBegin(Value : TOnWorkBegin);
Begin
 {$IFDEF FPC}
  vOnWorkBegin            := Value;
 {$ELSE}
  vOnWorkBegin            := Value;
 {$ENDIF}
End;

Procedure TDWPoolerMethodClient.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
 {$IFDEF FPC}
  vOnWorkEnd            := Value;
 {$ELSE}
  vOnWorkEnd            := Value;
 {$ENDIF}
End;

Constructor TDWPoolerMethodClient.Create(AOwner: TComponent);
Begin
 Inherited;
 vCompression := True;
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   vEncoding  := esASCII;
  {$IFEND}
 {$ENDIF}
 Host := '127.0.0.1';
 Port := 8082;
End;

Destructor TDWPoolerMethodClient.Destroy;
Begin
 Inherited;
End;

Function TDWPoolerMethodClient.GetPoolerList(Method_Prefix    : String;
                                             TimeOut          : Integer = 3000;
                                             UserName         : String  = '';
                                             Password         : String  = '';
                                             RESTClientPooler : TRESTClientPooler = Nil)   : TStringList;
Var
 RESTClientPoolerExec : TRESTClientPooler;
 vTempString,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TDWParams;
Begin
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                := TRESTClientPooler.Create(Nil)
 Else
  RESTClientPoolerExec                := RESTClientPooler;
 RESTClientPoolerExec.WelcomeMessage  := vWelcomeMessage;
 RESTClientPoolerExec.Host            := Host;
 RESTClientPoolerExec.Port            := Port;
 RESTClientPoolerExec.UserName        := UserName;
 RESTClientPoolerExec.Password        := Password;
 RESTClientPoolerExec.RequestTimeOut  := TimeOut;
 RESTClientPoolerExec.UrlPath         := Method_Prefix;
 RESTClientPoolerExec.DataCompression := Compression;
 {$IFDEF FPC}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ELSE}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ENDIF}
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.SetValue('');
 DWParams  := TDWParams.Create;
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPoolerExec.SendEvent('GetPoolerList', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
    Begin
     Result      := TStringList.Create;
     vTempString := DWParams.ItemsString['Result'].Value;
     While Not (vTempString = '') Do
      Begin
       if Pos('|', vTempString) > 0 then
        Begin
         Result.Add(Copy(vTempString, 1, Pos('|', vTempString) -1));
         Delete(vTempString, 1, Pos('|', vTempString));
        End
       Else
        Begin
         Result.Add(Copy(vTempString, 1, Length(vTempString)));
         Delete(vTempString, 1, Length(vTempString));
        End;
      End;
    End
   Else
    Begin
     If (lResponse = '') Then
      Raise Exception.CreateFmt('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
      Raise Exception.CreateFmt('Unauthorized Username : ''%s''', [UserName]);
    End;
  Except
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TDWPoolerMethodClient.EchoPooler(Method_Prefix,
                                          Pooler                  : String;
                                          TimeOut                 : Integer = 3000;
                                          UserName                : String  = '';
                                          Password                : String  = '';
                                          RESTClientPooler        : TRESTClientPooler = Nil) : String;
Var
 RESTClientPoolerExec : TRESTClientPooler;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TDWParams;
Begin
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                := TRESTClientPooler.Create(Nil)
 Else
  RESTClientPoolerExec                := RESTClientPooler;
 RESTClientPoolerExec.WelcomeMessage  := vWelcomeMessage;
 RESTClientPoolerExec.Host            := Host;
 RESTClientPoolerExec.Port            := Port;
 RESTClientPoolerExec.UserName        := UserName;
 RESTClientPoolerExec.Password        := Password;
 RESTClientPoolerExec.RequestTimeOut  := TimeOut;
 RESTClientPoolerExec.UrlPath         := Method_Prefix;
 RESTClientPoolerExec.DataCompression := vCompression;
 {$IFDEF FPC}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ELSE}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ENDIF}
 DWParams                        := TDWParams.Create;
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Pooler);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.SetValue('');
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPoolerExec.SendEvent('EchoPooler', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
    Result   := DWParams.ItemsString['Result'].Value
   Else
    Begin
     If (lResponse = '') Then
      Raise Exception.CreateFmt('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
      Raise Exception.CreateFmt('Unauthorized Username : ''%s''', [UserName]);
    End;
  Except
   On E : Exception Do
    Begin
     Raise Exception.Create(E.Message);
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TDWPoolerMethodClient.ExecuteCommand(Pooler, Method_Prefix,
                                              SQL                     : String;
                                              Params                  : TDWParams;
                                              Var Error               : Boolean;
                                              Var MessageError        : String;
                                              Execute                 : Boolean;
                                              TimeOut                 : Integer = 3000;
                                              UserName                : String  = '';
                                              Password                : String  = '';
                                              RESTClientPooler        : TRESTClientPooler = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPooler;
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TDWParams;
Begin
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                := TRESTClientPooler.Create(Nil)
 Else
  RESTClientPoolerExec                := RESTClientPooler;
 RESTClientPoolerExec.WelcomeMessage  := vWelcomeMessage;
 RESTClientPoolerExec.Host            := Host;
 RESTClientPoolerExec.Port            := Port;
 RESTClientPoolerExec.UserName        := UserName;
 RESTClientPoolerExec.Password        := Password;
 RESTClientPoolerExec.RequestTimeOut  := TimeOut;
 RESTClientPoolerExec.UrlPath         := Method_Prefix;
 RESTClientPoolerExec.DataCompression := vCompression;
 {$IFDEF FPC}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ELSE}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ENDIF}
 DWParams                        := TDWParams.Create;
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Pooler);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Method_Prefix);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(SQL);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'Params';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Params.ToJSON);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.SetValue(BooleanToString(False));
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.SetValue(MessageError);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'Execute';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(BooleanToString(Execute));
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ENDIF}
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.SetValue('');
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandJSON', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
    Begin
     Result         := TJSONValue.Create;
     Result.Encoded := False;
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DWParams.ItemsString['MessageError'].Value;
     If DWParams.ItemsString['Result'] <> Nil Then
      Result.LoadFromJSON(DWParams.ItemsString['Result'].Value);
    End
   Else
    Begin
     If (lResponse = '') Then
      Raise Exception.CreateFmt('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
      Raise Exception.CreateFmt('Unauthorized Username : ''%s''', [UserName]);
    End;
  Except
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TDWPoolerMethodClient.ExecuteCommandJSON(Pooler, Method_Prefix,
                                                  SQL                     : String;
                                                  Params                  : TDWParams;
                                                  Var Error               : Boolean;
                                                  Var MessageError        : String;
                                                  Execute                 : Boolean;
                                                  TimeOut                 : Integer = 3000;
                                                  UserName                : String  = '';
                                                  Password                : String  = '';
                                                  RESTClientPooler        : TRESTClientPooler = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPooler;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TDWParams;
Begin
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                := TRESTClientPooler.Create(Nil)
 Else
  RESTClientPoolerExec                := RESTClientPooler;
 RESTClientPoolerExec.WelcomeMessage  := vWelcomeMessage;
 RESTClientPoolerExec.Host            := Host;
 RESTClientPoolerExec.Port            := Port;
 RESTClientPoolerExec.UserName        := UserName;
 RESTClientPoolerExec.Password        := Password;
 RESTClientPoolerExec.RequestTimeOut  := TimeOut;
 RESTClientPoolerExec.UrlPath         := Method_Prefix;
 RESTClientPoolerExec.DataCompression := vCompression;
 {$IFDEF FPC}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ELSE}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ENDIF}
 DWParams                        := TDWParams.Create;
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Pooler);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Method_Prefix);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(SQL);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Params';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.SetValue(Params.ToJSON);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.SetValue(BooleanToString(False));
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.SetValue(MessageError);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Execute';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(BooleanToString(Execute));
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.SetValue('');
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandJSON', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
    Begin
     Result         := TJSONValue.Create;
     Result.Encoded := False;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DWParams.ItemsString['MessageError'].Value;
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If DWParams.ItemsString['Result'].Value <> '' Then
        Result.LoadFromJSON(DWParams.ItemsString['Result'].Value);
      End;
    End
   Else
    Begin
     If (lResponse = '') Then
      Raise Exception.CreateFmt('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
      Raise Exception.CreateFmt('Unauthorized Username : ''%s''', [UserName]);
    End;
  Except
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Function TDWPoolerMethodClient.ExecuteCommandPure(Pooler, Method_Prefix,
                                                  SQL                     : String;
                                                  Var Error               : Boolean;
                                                  Var MessageError        : String;
                                                  Execute                 : Boolean;
                                                  TimeOut                 : Integer = 3000;
                                                  UserName                : String  = '';
                                                  Password                : String  = '';
                                                  RESTClientPooler        : TRESTClientPooler = Nil)   : TJSONValue;
Begin

End;

Function TDWPoolerMethodClient.ExecuteCommandPureJSON(Pooler,
                                                      Method_Prefix,
                                                      SQL                 : String;
                                                      Var Error           : Boolean;
                                                      Var MessageError    : String;
                                                      Execute             : Boolean;
                                                      TimeOut             : Integer = 3000;
                                                      UserName            : String  = '';
                                                      Password            : String  = '';
                                                      RESTClientPooler    : TRESTClientPooler = Nil)   : TJSONValue;
Var
 RESTClientPoolerExec : TRESTClientPooler;
 lResponse        : String;
 JSONParam        : TJSONParam;
 DWParams         : TDWParams;
Begin
 If Not Assigned(RESTClientPooler) Then
  RESTClientPoolerExec                := TRESTClientPooler.Create(Nil)
 Else
  RESTClientPoolerExec                := RESTClientPooler;
 RESTClientPoolerExec.WelcomeMessage  := vWelcomeMessage;
 RESTClientPoolerExec.Host            := Host;
 RESTClientPoolerExec.Port            := Port;
 RESTClientPoolerExec.UserName        := UserName;
 RESTClientPoolerExec.Password        := Password;
 RESTClientPoolerExec.RequestTimeOut  := TimeOut;
 RESTClientPoolerExec.UrlPath         := Method_Prefix;
 RESTClientPoolerExec.DataCompression := vCompression;
 {$IFDEF FPC}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ELSE}
  RESTClientPoolerExec.OnWork        := vOnWork;
  RESTClientPoolerExec.OnWorkBegin   := vOnWorkBegin;
  RESTClientPoolerExec.OnWorkEnd     := vOnWorkEnd;
  RESTClientPoolerExec.OnStatus      := vOnStatus;
 {$ENDIF}
 DWParams                        := TDWParams.Create;
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                      := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Pooler';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Pooler);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Method_Prefix';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(Method_Prefix);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'SQL';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(SQL);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.SetValue(BooleanToString(False));
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.SetValue(MessageError);
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Execute';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.SetValue(BooleanToString(Execute));
 DWParams.Add(JSONParam);
 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   RESTClientPoolerExec.Encoding     := vEncoding;
   JSONParam                     := TJSONParam.Create(GetEncoding(TEncodeSelect(RESTClientPoolerExec.Encoding)));
  {$ELSE}
   JSONParam                     := TJSONParam.Create;
  {$IFEND}
 {$ELSE}
  JSONParam                     := TJSONParam.Create;
 {$ENDIF}
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOUT;
 JSONParam.SetValue('');
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPoolerExec.SendEvent('ExecuteCommandPureJSON', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
    Begin
     Result         := TJSONValue.Create;
     Result.Encoded := False;
     If DWParams.ItemsString['MessageError'] <> Nil Then
      MessageError  := DWParams.ItemsString['MessageError'].Value;
     If DWParams.ItemsString['Error'] <> Nil Then
      Error         := StringToBoolean(DWParams.ItemsString['Error'].Value);
     If DWParams.ItemsString['Result'] <> Nil Then
      Begin
       If DWParams.ItemsString['Result'].Value <> '' Then
        Result.LoadFromJSON(DWParams.ItemsString['Result'].Value);
      End;
    End
   Else
    Begin
     If (lResponse = '') Then
      Raise Exception.CreateFmt('Unresolved Host : ''%s''', [Host])
     Else If (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
      Raise Exception.CreateFmt('Unauthorized Username : ''%s''', [UserName]);
    End;
  Except
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

Procedure TDWPoolerMethodClient.ExecuteProcedure(Pooler,
                                                 Method_Prefix,
                                                 ProcName            : String;
                                                 Params              : TDWParams;
                                                 Var Error           : Boolean;
                                                 Var MessageError    : String;
                                                 RESTClientPooler    : TRESTClientPooler = Nil);
Begin

End;

Procedure TDWPoolerMethodClient.ExecuteProcedurePure(Pooler,
                                                     Method_Prefix,
                                                     ProcName            : String;
                                                     Var Error           : Boolean;
                                                     Var MessageError    : String;
                                                     RESTClientPooler    : TRESTClientPooler = Nil);
Begin

End;

Procedure TDWPoolerMethodClient.GetPoolerList(Method_Prefix    : String;
                                              Var PoolerList   : TStringList;
                                              TimeOut          : Integer = 3000;
                                              UserName         : String  = '';
                                              Password         : String  = '';
                                              RESTClientPooler : TRESTClientPooler = Nil);
Begin

End;

Function TDWPoolerMethodClient.InsertValue(Pooler, Method_Prefix,
                                           SQL                     : String;
                                           Params                  : TDWParams;
                                           Var Error               : Boolean;
                                           Var MessageError        : String;
                                           TimeOut                 : Integer = 3000;
                                           UserName                : String  = '';
                                           Password                : String  = '';
                                           RESTClientPooler        : TRESTClientPooler = Nil): Integer;
Begin

End;

Function TDWPoolerMethodClient.InsertValuePure(Pooler, Method_Prefix,
                                               SQL                     : String;
                                               Var Error               : Boolean;
                                               Var MessageError        : String;
                                               TimeOut                 : Integer = 3000;
                                               UserName                : String  = '';
                                               Password                : String  = '';
                                               RESTClientPooler        : TRESTClientPooler = Nil): Integer;
Begin

End;

Function TDWPoolerMethodClient.PoolersDataSet(Method_Prefix    : String;
                                              TimeOut          : Integer = 3000;
                                              UserName         : String  = '';
                                              Password         : String  = '';
                                              RESTClientPooler : TRESTClientPooler = Nil): TStringList;
Begin

End;

end.

