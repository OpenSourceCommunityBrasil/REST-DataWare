unit uRESTDWHTMLDesignerAI;
{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}
Interface
Uses
 Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs, IniFiles,
 uRESTDWHTMLIDECompat;
Type
 TRESTDWHTMLAIContextEvent = Function : String Of Object;
 TRESTDWHTMLAISettings = Class
 Public
  Enabled : Boolean;
  Endpoint : String;
  APIKey : String;
  HeaderName : String;
  KeyPrefix : String;
  Model : String;
  SystemPrompt : String;
  IncludePageContext : Boolean;
  Timeout : Integer;
  Constructor Create;
 End;
 TRESTDWHTMLAIConsolePanel = Class(TPanel)
 Private
  FToolbar : TPanel;
  FOutput : TMemo;
  FPrompt : TMemo;
  FSendButton : TButton;
  FClearButton : TButton;
  FConfigureButton : TButton;
  FOnBuildContext : TRESTDWHTMLAIContextEvent;
  Procedure SendClick(Sender : TObject);
  Procedure ClearClick(Sender : TObject);
  Procedure ConfigureClick(Sender : TObject);
  Procedure AppendLine(const AText : String);
 Public
  Constructor Create(AOwner : TComponent); Override;
  Property OnBuildContext : TRESTDWHTMLAIContextEvent
   Read FOnBuildContext Write FOnBuildContext;
 End;
Function DSPageProducerAISettingsFileName : String;
Procedure LoadRESTDWHTMLAISettings(ASettings : TRESTDWHTMLAISettings);
Procedure SaveRESTDWHTMLAISettings(ASettings : TRESTDWHTMLAISettings);
Function ConfigureRESTDWHTMLAI(AOwner : TComponent) : Boolean;
Function ExecuteRESTDWHTMLAI(
 ASettings : TRESTDWHTMLAISettings;
 const APrompt,
 APageContext : String) : String;
{$IFNDEF FPC}
Function RESTDWPostJSON(
 const AURL,
 AHeaderName,
 AHeaderValue,
 ABody : String;
 ATimeout : Integer) : String;
{$ENDIF}
Implementation
Uses
 {$IFDEF FPC}
 fphttpclient, fpjson, jsonparser, opensslsockets;
 {$ELSE}
 Windows, WinInet;
 {$ENDIF}
{$IFNDEF FPC}
Function RESTDWPostJSON(
 const AURL,
 AHeaderName,
 AHeaderValue,
 ABody : String;
 ATimeout : Integer) : String;
Var
 LInternet,
 LConnect,
 LRequest : HINTERNET;
 LComponents : URL_COMPONENTS;
 LHost,
 LPath : Array[0..2047] Of Char;
 LFlags : DWORD;
 LHeaders,
 LBodyUTF8 : UTF8String;
 LBuffer : Array[0..8191] Of Byte;
 LRead : DWORD;
 LStream : TMemoryStream;
 LPort : INTERNET_PORT;
Begin
 Result := '';
 FillChar(LComponents,SizeOf(LComponents),0);
 FillChar(LHost,SizeOf(LHost),0);
 FillChar(LPath,SizeOf(LPath),0);
 LComponents.dwStructSize := SizeOf(LComponents);
 LComponents.lpszHostName := @LHost[0];
 LComponents.dwHostNameLength := Length(LHost);
 LComponents.lpszUrlPath := @LPath[0];
 LComponents.dwUrlPathLength := Length(LPath);
 If Not InternetCrackUrl(PChar(AURL),0,0,LComponents) Then
  Raise Exception.Create('Invalid AI endpoint URL.');
 LPort := LComponents.nPort;
 LInternet := InternetOpen(
  'RESTDataware-HTML-Designer',
  INTERNET_OPEN_TYPE_PRECONFIG,
  Nil,
  Nil,
  0
 );
 If LInternet = Nil Then
  Raise Exception.Create('Unable to initialize WinInet.');
 Try
  InternetSetOption(
   LInternet,
   INTERNET_OPTION_CONNECT_TIMEOUT,
   @ATimeout,
   SizeOf(ATimeout)
  );
  InternetSetOption(
   LInternet,
   INTERNET_OPTION_RECEIVE_TIMEOUT,
   @ATimeout,
   SizeOf(ATimeout)
  );
  InternetSetOption(
   LInternet,
   INTERNET_OPTION_SEND_TIMEOUT,
   @ATimeout,
   SizeOf(ATimeout)
  );
  LConnect := InternetConnect(
   LInternet,
   LHost,
   LPort,
   Nil,
   Nil,
   INTERNET_SERVICE_HTTP,
   0,
   0
  );
  If LConnect = Nil Then
   Raise Exception.Create('Unable to connect to AI endpoint.');
  Try
   LFlags :=
    INTERNET_FLAG_RELOAD Or
    INTERNET_FLAG_NO_CACHE_WRITE Or
    INTERNET_FLAG_KEEP_CONNECTION;
   If LComponents.nScheme = INTERNET_SCHEME_HTTPS Then
    LFlags := LFlags Or INTERNET_FLAG_SECURE;
   LRequest := HttpOpenRequest(
    LConnect,
    'POST',
    LPath,
    Nil,
    Nil,
    Nil,
    LFlags,
    0
   );
   If LRequest = Nil Then
    Raise Exception.Create('Unable to create AI HTTP request.');
   Try
    LHeaders := 'Content-Type: application/json'#13#10;
    If (Trim(AHeaderName) <> '') And
       (Trim(AHeaderValue) <> '') Then
     LHeaders :=
      LHeaders +
      UTF8String(AHeaderName + ': ' + AHeaderValue + #13#10);
    LBodyUTF8 := UTF8String(ABody);
    If Not HttpSendRequest(
     LRequest,
     PChar(String(LHeaders)),
     Length(String(LHeaders)),
     Pointer(LBodyUTF8),
     Length(LBodyUTF8)
    ) Then
     Raise Exception.Create(
      'AI HTTP request failed. Win32 error ' +
      IntToStr(GetLastError)
     );
    LStream := TMemoryStream.Create;
    Try
     Repeat
      LRead := 0;
      If Not InternetReadFile(
       LRequest,
       @LBuffer[0],
       SizeOf(LBuffer),
       LRead
      ) Then
       Raise Exception.Create('Unable to read AI HTTP response.');
      If LRead > 0 Then
       LStream.WriteBuffer(LBuffer[0],LRead);
     Until LRead = 0;
     SetLength(LBodyUTF8,LStream.Size);
     If LStream.Size > 0 Then
     Begin
      LStream.Position := 0;
      LStream.ReadBuffer(
       Pointer(LBodyUTF8)^,
       LStream.Size
      );
     End;
     Result := UTF8ToString(LBodyUTF8);
    Finally
     LStream.Free;
    End;
   Finally
    InternetCloseHandle(LRequest);
   End;
  Finally
   InternetCloseHandle(LConnect);
  End;
 Finally
  InternetCloseHandle(LInternet);
 End;
End;
Function RESTDWJSONEscape(
 const AValue : String) : String;
Var
 I : Integer;
 C : Char;
Begin
 Result := '';
 For I := 1 To Length(AValue) Do
 Begin
  C := AValue[I];
  Case C Of
   '"' : Result := Result + '\"';
   '\' : Result := Result + '\\';
   #8 : Result := Result + '\b';
   #9 : Result := Result + '\t';
   #10 : Result := Result + '\n';
   #12 : Result := Result + '\f';
   #13 : Result := Result + '\r';
  Else
   Result := Result + C;
  End;
 End;
End;
Function RESTDWJSONUnescape(
 const AValue : String) : String;
Var
 I : Integer;
 C : Char;
Begin
 Result := '';
 I := 1;
 While I <= Length(AValue) Do
 Begin
  C := AValue[I];
  If (C = '\') And (I < Length(AValue)) Then
  Begin
   Inc(I);
   C := AValue[I];
   Case C Of
    'n' : Result := Result + #10;
    'r' : Result := Result + #13;
    't' : Result := Result + #9;
    'b' : Result := Result + #8;
    'f' : Result := Result + #12;
    '"' : Result := Result + '"';
    '\' : Result := Result + '\';
   Else
    Result := Result + C;
   End;
  End
  Else
   Result := Result + C;
  Inc(I);
 End;
End;
Function RESTDWJSONFindString(
 const AJSON,
 AName : String) : String;
Var
 P,
 I : Integer;
 S : String;
 Escaped : Boolean;
Begin
 Result := '';
 S := '"' + AName + '"';
 P := Pos(S,AJSON);
 If P = 0 Then
  Exit;
 P := P + Length(S);
 While (P <= Length(AJSON)) And (AJSON[P] <> ':') Do Inc(P);
 Inc(P);
 While (P <= Length(AJSON)) And (AJSON[P] <= ' ') Do Inc(P);
 If (P > Length(AJSON)) Or (AJSON[P] <> '"') Then Exit;
 Inc(P);
 I := P;
 Escaped := False;
 While I <= Length(AJSON) Do
 Begin
  If Escaped Then
   Escaped := False
  Else If AJSON[I] = '\' Then
   Escaped := True
  Else If AJSON[I] = '"' Then
  Begin
   Result := RESTDWJSONUnescape(Copy(AJSON,P,I-P));
   Exit;
  End;
  Inc(I);
 End;
End;
{$ENDIF}
Function ExecuteRESTDWHTMLAI(
 ASettings : TRESTDWHTMLAISettings;
 const APrompt,
 APageContext : String) : String;
{$IFDEF FPC}
Var
 Client : TFPHTTPClient;
 Input : TStringStream;
 Root : TJSONObject;
 Messages : TJSONArray;
 Msg : TJSONObject;
 Data,
 Value : TJSONData;
 RequestText,
 UserText,
 ResponseText : String;
Begin
 Result := '';
 If ASettings = Nil Then
  Raise Exception.Create('AI settings are required.');
 If Not ASettings.Enabled Then
  Raise Exception.Create(
   'AI integration is disabled. Open AI > Configuration.'
  );
 If Trim(ASettings.Endpoint) = '' Then
  Raise Exception.Create('AI endpoint is not configured.');
 If Trim(ASettings.Model) = '' Then
  Raise Exception.Create('AI model is not configured.');
 UserText := APrompt;
 If ASettings.IncludePageContext And
    (Trim(APageContext) <> '') Then
  UserText :=
   APrompt +
   LineEnding +
   LineEnding +
   'Current REST Dataware page:' +
   LineEnding +
   APageContext;
 Root := TJSONObject.Create;
 Try
  Root.Add('model',ASettings.Model);
  Messages := TJSONArray.Create;
  Root.Add('messages',Messages);
  If Trim(ASettings.SystemPrompt) <> '' Then
  Begin
   Msg := TJSONObject.Create;
   Msg.Add('role','system');
   Msg.Add('content',ASettings.SystemPrompt);
   Messages.Add(Msg);
  End;
  Msg := TJSONObject.Create;
  Msg.Add('role','user');
  Msg.Add('content',UserText);
  Messages.Add(Msg);
  RequestText := Root.AsJSON;
 Finally
  Root.Free;
 End;
 Client := TFPHTTPClient.Create(Nil);
 Input := TStringStream.Create(RequestText);
 Try
  Client.ConnectTimeout := ASettings.Timeout;
  Client.IOTimeout := ASettings.Timeout;
  Client.AddHeader('Content-Type','application/json');
  If (Trim(ASettings.APIKey) <> '') And
     (Trim(ASettings.HeaderName) <> '') Then
   Client.AddHeader(
    ASettings.HeaderName,
    ASettings.KeyPrefix + ASettings.APIKey
   );
  Client.RequestBody := Input;
  ResponseText := Client.Post(ASettings.Endpoint);
 Finally
  Input.Free;
  Client.Free;
 End;
 Data := Nil;
 Try
  Data := GetJSON(ResponseText);
  Value := Data.FindPath('choices[0].message.content');
  If Value <> Nil Then
  Begin
   Result := Value.AsString;
   Exit;
  End;
  Value := Data.FindPath('output_text');
  If Value <> Nil Then
  Begin
   Result := Value.AsString;
   Exit;
  End;
  Result := ResponseText;
 Finally
  Data.Free;
 End;
End;
{$ELSE}
Var
 RequestText,
 UserText,
 ResponseText,
 LValue : String;
Begin
 Result := '';
 If ASettings = Nil Then
  Raise Exception.Create('AI settings are required.');
 If Not ASettings.Enabled Then
  Raise Exception.Create(
   'AI integration is disabled. Open AI > Configuration.'
  );
 If Trim(ASettings.Endpoint) = '' Then
  Raise Exception.Create('AI endpoint is not configured.');
 If Trim(ASettings.Model) = '' Then
  Raise Exception.Create('AI model is not configured.');
 UserText := APrompt;
 If ASettings.IncludePageContext And
    (Trim(APageContext) <> '') Then
  UserText :=
   APrompt +
   sLineBreak +
   sLineBreak +
   'Current REST Dataware page:' +
   sLineBreak +
   APageContext;
 RequestText :=
  '{"model":"' +
  RESTDWJSONEscape(ASettings.Model) +
  '","messages":[';
 If Trim(ASettings.SystemPrompt) <> '' Then
  RequestText :=
   RequestText +
   '{"role":"system","content":"' +
   RESTDWJSONEscape(ASettings.SystemPrompt) +
   '"},';
 RequestText :=
  RequestText +
  '{"role":"user","content":"' +
  RESTDWJSONEscape(UserText) +
  '"}]}';
 ResponseText := RESTDWPostJSON(
  ASettings.Endpoint,
  ASettings.HeaderName,
  ASettings.KeyPrefix + ASettings.APIKey,
  RequestText,
  ASettings.Timeout
 );
 LValue := RESTDWJSONFindString(ResponseText,'content');
 If LValue = '' Then
  LValue := RESTDWJSONFindString(ResponseText,'output_text');
 If LValue <> '' Then
  Result := LValue
 Else
  Result := ResponseText;
End;
{$ENDIF}
Constructor TRESTDWHTMLAISettings.Create;
Begin
 Inherited Create;
 Enabled := False;
 Endpoint := '';
 APIKey := '';
 HeaderName := 'Authorization';
 KeyPrefix := 'Bearer ';
 Model := '';
 SystemPrompt :=
  'You are integrated with the REST Dataware HTML Editor. ' +
  'Help edit, explain and improve the current HTML, CSS and JavaScript.';
 IncludePageContext := True;
 Timeout := 60000;
End;
Function DSPageProducerAISettingsFileName : String;
Begin
 Result :=
  IncludeTrailingPathDelimiter(RESTDWEditorConfigDir) +
  'ai.ini';
End;
Procedure LoadRESTDWHTMLAISettings(ASettings : TRESTDWHTMLAISettings);
Var
 LIni : TIniFile;
Begin
 If Not Assigned(ASettings) Then Exit;
 LIni := TIniFile.Create(DSPageProducerAISettingsFileName);
 Try
  ASettings.Enabled := LIni.ReadBool('AI','Enabled',ASettings.Enabled);
  ASettings.Endpoint := LIni.ReadString('AI','Endpoint',ASettings.Endpoint);
  ASettings.APIKey := LIni.ReadString('AI','APIKey',ASettings.APIKey);
  ASettings.HeaderName := LIni.ReadString('AI','HeaderName',ASettings.HeaderName);
  ASettings.KeyPrefix := LIni.ReadString('AI','KeyPrefix',ASettings.KeyPrefix);
  ASettings.Model := LIni.ReadString('AI','Model',ASettings.Model);
  ASettings.SystemPrompt := LIni.ReadString('AI','SystemPrompt',ASettings.SystemPrompt);
  ASettings.IncludePageContext := LIni.ReadBool('AI','IncludePageContext',ASettings.IncludePageContext);
  ASettings.Timeout := LIni.ReadInteger('AI','Timeout',ASettings.Timeout);
 Finally
  LIni.Free;
 End;
End;
Procedure SaveRESTDWHTMLAISettings(ASettings : TRESTDWHTMLAISettings);
Var
 LIni : TIniFile;
Begin
 If Not Assigned(ASettings) Then Exit;
 LIni := TIniFile.Create(DSPageProducerAISettingsFileName);
 Try
  LIni.WriteBool('AI','Enabled',ASettings.Enabled);
  LIni.WriteString('AI','Endpoint',ASettings.Endpoint);
  LIni.WriteString('AI','APIKey',ASettings.APIKey);
  LIni.WriteString('AI','HeaderName',ASettings.HeaderName);
  LIni.WriteString('AI','KeyPrefix',ASettings.KeyPrefix);
  LIni.WriteString('AI','Model',ASettings.Model);
  LIni.WriteString('AI','SystemPrompt',ASettings.SystemPrompt);
  LIni.WriteBool('AI','IncludePageContext',ASettings.IncludePageContext);
  LIni.WriteInteger('AI','Timeout',ASettings.Timeout);
 Finally
  LIni.Free;
 End;
End;
Function ConfigureRESTDWHTMLAI(AOwner : TComponent) : Boolean;
Var
 S : TRESTDWHTMLAISettings;
 LValue : String;
Begin
 Result := False;
 S := TRESTDWHTMLAISettings.Create;
 Try
  LoadRESTDWHTMLAISettings(S);
  LValue := S.Endpoint;
  If Not InputQuery('REST Dataware HTML Designer AI','Endpoint',LValue) Then Exit;
  S.Endpoint := Trim(LValue);
  LValue := S.Model;
  If Not InputQuery('REST Dataware HTML Designer AI','Model',LValue) Then Exit;
  S.Model := Trim(LValue);
  LValue := S.APIKey;
  If Not InputQuery('REST Dataware HTML Designer AI','API Key',LValue) Then Exit;
  S.APIKey := LValue;
  S.Enabled := S.Endpoint <> '';
  SaveRESTDWHTMLAISettings(S);
  Result := True;
 Finally
  S.Free;
 End;
End;
Constructor TRESTDWHTMLAIConsolePanel.Create(
 AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 Caption := '';
 BevelOuter := bvNone;
 FToolbar := TPanel.Create(Self);
 FToolbar.Parent := Self;
 FToolbar.Align := alTop;
 FToolbar.Height := 34;
 FToolbar.Caption := '';
 FToolbar.BevelOuter := bvNone;
 FSendButton := TButton.Create(Self);
 FSendButton.Parent := FToolbar;
 FSendButton.Left := 6;
 FSendButton.Top := 4;
 FSendButton.Width := 72;
 FSendButton.Height := 26;
 FSendButton.Caption := 'Send';
 FSendButton.OnClick := SendClick;
 FClearButton := TButton.Create(Self);
 FClearButton.Parent := FToolbar;
 FClearButton.Left := 84;
 FClearButton.Top := 4;
 FClearButton.Width := 72;
 FClearButton.Height := 26;
 FClearButton.Caption := 'Clear';
 FClearButton.OnClick := ClearClick;
 FConfigureButton := TButton.Create(Self);
 FConfigureButton.Parent := FToolbar;
 FConfigureButton.Left := 162;
 FConfigureButton.Top := 4;
 FConfigureButton.Width := 96;
 FConfigureButton.Height := 26;
 FConfigureButton.Caption := 'Configure';
 FConfigureButton.OnClick := ConfigureClick;
 FPrompt := TMemo.Create(Self);
 FPrompt.Parent := Self;
 FPrompt.Align := alBottom;
 FPrompt.Height := 82;
 FPrompt.ScrollBars := ssVertical;
 FPrompt.Text := '';
 FOutput := TMemo.Create(Self);
 FOutput.Parent := Self;
 FOutput.Align := alClient;
 FOutput.ReadOnly := True;
 FOutput.ScrollBars := ssBoth;
 FOutput.WordWrap := True;
End;
Procedure TRESTDWHTMLAIConsolePanel.AppendLine(
 const AText : String);
Begin
 FOutput.Lines.Add(
  AText
 );
 FOutput.SelStart :=
  Length(
   FOutput.Text
  );
End;
Procedure TRESTDWHTMLAIConsolePanel.ClearClick(
 Sender : TObject);
Begin
 FOutput.Clear;
End;
Procedure TRESTDWHTMLAIConsolePanel.ConfigureClick(
 Sender : TObject);
Begin
 ConfigureRESTDWHTMLAI(
  Self
 );
End;
Procedure TRESTDWHTMLAIConsolePanel.SendClick(
 Sender : TObject);
Var
 S : TRESTDWHTMLAISettings;
 LPrompt,
 LContext,
 LResponse : String;
Begin
 LPrompt :=
  Trim(
   FPrompt.Text
  );
 If LPrompt = '' Then
  Exit;
 LContext := '';
 If Assigned(FOnBuildContext) Then
  LContext :=
   FOnBuildContext();
 AppendLine(
  '> ' +
  LPrompt
 );
 FSendButton.Enabled := False;
 Try
  Application.ProcessMessages;
  S := TRESTDWHTMLAISettings.Create;
  Try
   LoadRESTDWHTMLAISettings(
    S
   );
   LResponse :=
    ExecuteRESTDWHTMLAI(
     S,
     LPrompt,
     LContext
    );
  Finally
   S.Free;
  End;
  AppendLine(
   LResponse
  );
  FPrompt.Clear;
 Except
  On E : Exception Do
   AppendLine(
    'ERROR: ' +
    E.Message
   );
 End;
 FSendButton.Enabled := True;
End;
End.
