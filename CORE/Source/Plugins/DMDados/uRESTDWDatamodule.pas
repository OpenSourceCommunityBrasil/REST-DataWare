unit uRESTDWDatamodule;

interface

Uses
  SysUtils, Classes, uRESTDWCharset, uRESTDWDataUtils, uRESTDWComponentEvents,
  uRESTDWBasicTypes, uRESTDWConsts, uRESTDWJSONObject, uRESTDWEncodeClass, uRESTDWParams;

Type
 TUserBasicAuth  =             Procedure(Welcomemsg, AccessTag,
                                         Username, Password : String;
                                         Var Params         : TRESTDWParams;
                                         Var ErrorCode      : Integer;
                                         Var ErrorMessage   : String;
                                         Var Accept         : Boolean) Of Object;
 TUserTokenAuth  =             Procedure(Welcomemsg,
                                         AccessTag          : String;
                                         Params             : TRESTDWParams;
                                         AuthOptions        : TRESTDWAuthTokenParam;
                                         Var ErrorCode      : Integer;
                                         Var ErrorMessage   : String;
                                         Var TokenID        : String;
                                         Var Accept         : Boolean) Of Object;

 Type
  TRESTDWClientInfo = Class(TObject)
 Private
  vip,
  vUserAgent,
  vBaseRequest,
  vToken         : String;
  vport          : Integer;
  Procedure  SetClientInfo(ip,
                           UserAgent,
                           BaseRequest : String;
                           port        : Integer);
 Protected
 Public
  Constructor Create;
//  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property BaseRequest : String  Read vBaseRequest;
  Property ip          : String  Read vip;
  Property UserAgent   : String  Read vUserAgent;
  Property port        : Integer Read vport;
  Property Token       : String  Read vToken;
 End;

 Type
  TServerMethodDataModule = Class(TDataModule)
  Private
   vQueuedRequest        : Boolean;
   vClientWelcomeMessage : String;
   vReplyEvent           : TRESTDWReplyEvent;
   vWelcomeMessage       : TWelcomeMessage;
   vMassiveProcess       : TMassiveProcess;
   vUserBasicAuth        : TUserBasicAuth;
   vUserTokenAuth        : TUserTokenAuth;
   vOnGetToken           : TOnGetToken;
   vOnMassiveBegin,
   vOnMassiveAfterStartTransaction,
   vOnMassiveAfterBeforeCommit,
   vOnMassiveAfterAfterCommit,
   vOnMassiveEnd         : TMassiveEvent;
   vOnMassiveLineProcess : TMassiveLineProcess;
   vEncoding             : TEncodeSelect;
   vRESTDWClientInfo     : TRESTDWClientInfo;
   vServerAuthOptions    : TRESTDWAuthOptionParam;
//   Procedure Loaded; Override;
  Public
   Procedure   SetClientWelcomeMessage(Value : String);
   Procedure   SetClientInfo(ip,
                             UserAgent,
                             BaseRequest : String;
                             port        : Integer);
   Function    GetAction    (Var URL     : String;
                             Var Params  : TRESTDWParams) : Boolean;
   Constructor Create(Sender : TComponent);Override;
   Destructor  Destroy;override;
   Property ServerAuthOptions              : TRESTDWAuthOptionParam Read vServerAuthOptions              Write vServerAuthOptions;
  Published
   Property ClientWelcomeMessage           : String              Read vClientWelcomeMessage;
   Property ClientInfo                     : TRESTDWClientInfo   Read vRESTDWClientInfo;
   Property Encoding                       : TEncodeSelect       Read vEncoding                       Write vEncoding;
   Property OnReplyEvent                   : TRESTDWReplyEvent   Read vReplyEvent                     Write vReplyEvent;
   Property OnWelcomeMessage               : TWelcomeMessage     Read vWelcomeMessage                 Write vWelcomeMessage;
   Property OnMassiveProcess               : TMassiveProcess     Read vMassiveProcess                 Write vMassiveProcess;
   Property OnAfterMassiveLineProcess      : TMassiveLineProcess Read vOnMassiveLineProcess           Write vOnMassiveLineProcess;
   Property OnMassiveBegin                 : TMassiveEvent       Read vOnMassiveBegin                 Write vOnMassiveBegin;
   Property OnMassiveAfterStartTransaction : TMassiveEvent       Read vOnMassiveAfterStartTransaction Write vOnMassiveAfterStartTransaction;
   Property OnMassiveAfterBeforeCommit     : TMassiveEvent       Read vOnMassiveAfterBeforeCommit     Write vOnMassiveAfterBeforeCommit;
   Property OnMassiveAfterAfterCommit      : TMassiveEvent       Read vOnMassiveAfterAfterCommit      Write vOnMassiveAfterAfterCommit;
   Property OnMassiveEnd                   : TMassiveEvent       Read vOnMassiveEnd                   Write vOnMassiveEnd;
   Property OnUserBasicAuth                : TUserBasicAuth      Read vUserBasicAuth                  Write vUserBasicAuth;
   Property OnUserTokenAuth                : TUserTokenAuth      Read vUserTokenAuth                  Write vUserTokenAuth;
   Property OnGetToken                     : TOnGetToken         Read vOnGetToken                     Write vOnGetToken;
   Property QueuedRequest                  : Boolean             Read vQueuedRequest                  Write vQueuedRequest;
 End;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

Uses uRESTDWServerEvents, uRESTDWServerContext;
{ TServerMethodDataModule }

Destructor TServerMethodDataModule.Destroy;
Begin
 FreeAndNil(vRESTDWClientInfo);
 If Assigned(vServerAuthOptions) Then
  FreeAndNil(vServerAuthOptions);
 Inherited;
End;

Function  TServerMethodDataModule.GetAction(Var URL     : String;
                                            Var Params  : TRESTDWParams) : Boolean;
Var
 I, A        : Integer;
 vIsQuery    : Boolean;
 vParamName,
 vTempRoute,
 vTempValue  : String;
 Procedure ParseParams(ParamsURI : String);
 Var
  vTempData,
  vTempParams : String;
  IBar, I,
  ArraySize   : Integer;
  JSONParam   : TJSONParam;
 Begin
  If vIsQuery Then
   ArraySize   := CountExpression(ParamsURI, '&')
  Else
   Begin
    ArraySize   := CountExpression(ParamsURI, '/');
    If ArraySize > 0 Then
     Dec(ArraySize);
   End;
  If ArraySize  = 0 Then
   Begin
    If Length(ParamsURI) > 0 Then
     ArraySize := 1;
   End
  Else
   ArraySize   := ArraySize + 1;
  vTempParams  := ParamsURI;
  For I := 0 To ArraySize -1 Do
   Begin
    JSONParam := Nil;
    If vIsQuery Then
     Begin
      IBar     := Pos('&', vTempParams);
      If IBar = 0 Then
       Begin
        IBar    := Length(vTempParams);
        vTempData := Copy(vTempParams, 1, IBar);
       End
      Else
       vTempData := Copy(vTempParams, 1, IBar - 1);
      If Pos('dwmark:', vTempData) = 0 Then
       Begin
        vParamName := Copy(vTempData, 1, Pos('=', vTempData) - 1);
        If vParamName <> '' Then
         Begin
          JSONParam  := Params.ItemsString[vParamName];
          If JSONParam = Nil Then
           Begin
            Delete(vTempData, 1, Pos('=', vTempData));
            JSONParam := TJSONParam.Create(Params.Encoding);
            JSONParam.ParamName := cUndefined;//Format('PARAM%d', [0]);
            JSONParam.ObjectDirection := odIN;
            JSONParam.SetValue(vTempValue);
            Params.Add(JSONParam);
           End;
         End;
       End;
      Delete(vTempParams, 1, IBar);
     End
    Else
     Begin
      vParamName := IntToStr(I);
      If vParamName <> '' Then
       Begin
        If Pos('/', vTempParams) > 0 Then
         Begin
          If vTempParams[InitStrPos] = '/' Then
           Delete(vTempParams, 1, 1);
          vTempValue := Copy(vTempParams, 1, Pos('/', vTempParams) - 1);
          Delete(vTempParams, 1, Pos('/', vTempParams));
         End
        Else
         vTempValue := vTempParams;
        JSONParam  := Params.ItemsString[vParamName];
        If JSONParam = Nil Then
         Begin
          JSONParam := TJSONParam.Create(Params.Encoding);
          JSONParam.ParamName := vParamName;
          JSONParam.ObjectDirection := odIN;
          If (vTempValue <> '') Then
           JSONParam.SetValue(vTempValue);
          Params.Add(JSONParam);
         End
        Else If Not(vIsQuery)         And
                   (JSONParam.IsNull) And
                   (vTempValue <> '') Then
         JSONParam.SetValue(vTempValue);
       End;
     End;
   End;
 End;
 Procedure CopyParams(SourceParams : TRESTDWParamsMethods);
 Var
  I : Integer;
  vTempParam : TJSONParam;
 Begin
  For I := 0 To SourceParams.Count -1 Do
   Begin
    If SourceParams.Items[I].ObjectDirection in [odIN, odINOUT] Then
     Begin
      If Params.ItemsString[SourceParams.Items[I].ParamName] = Nil Then
       Begin
        vTempParam := TJSONParam.Create(Params.Encoding);
        vTempParam.CopyFrom(SourceParams.Items[I]);
        Params.Add(vTempParam);
       End;
     End;
   End;
 End;
Begin
 Result   := False;
 If Length(URL) = 0 Then
  Exit;
 vTempValue := URL;
 vIsQuery   := (Pos('?', vTempValue) > 0);
 For I := 0 To ComponentCount -1 Do
  Begin
   If (Components[i] is TRESTDWServerEvents) Or
      (Components[i] is TRESTDWServerContext)  Then
    Begin
     If (Components[i] is TRESTDWServerEvents) Then
      Begin
       For A := 0 To TRESTDWServerEvents(Components[I]).Events.Count -1 Do
        Begin
         vTempRoute := Lowercase(TRESTDWServerEvents(Components[I]).Events[A].BaseURL   +
                                 TRESTDWServerEvents(Components[I]).Events[A].EventName);
         If vIsQuery Then
          Begin
           vTempRoute := vTempRoute + '?';
           If Copy(vTempValue, Length(vTempValue), 1) <> '?' Then
            vTempValue := vTempValue + '?';
          End
         Else
          Begin
           vTempRoute := vTempRoute + '/';
           If Copy(vTempValue, Length(vTempValue), 1) <> '/' Then
            vTempValue :=  vTempValue + '/';
          End;
         Result     := vTempRoute = Copy(vTempValue, 1, Length(vTempRoute));
         If Result Then
          Begin
           CopyParams(TRESTDWServerEvents(Components[I]).Events[A].Params);
           URL        := vTempRoute;
           vTempValue := Copy(vTempValue, Length(URL), Length(vTempValue));
           If vIsQuery Then
            Begin
             If Copy(vTempValue, 1, 1) = '?' Then
              Delete(vTempValue, 1, 1);
             If Copy(vTempValue, Length(vTempValue), 1) = '?' Then
              Delete(vTempValue, Length(vTempValue), 1);
             If Copy(URL, Length(URL), 1) = '?' Then
              Delete(URL, Length(URL), 1);
            End
           Else
            Begin
             If Copy(vTempValue, Length(vTempValue), 1) = '/' Then
              Delete(vTempValue, Length(vTempValue), 1);
             If Copy(URL, Length(URL), 1) = '/' Then
              Delete(URL, Length(URL), 1);
            End;
           Break;
          End;
        End;
      End
     Else
      Begin
       For A := 0 To TRESTDWServerContext(Components[I]).ContextList.Count -1 Do
        Begin
         vTempRoute := Lowercase(TRESTDWServerContext(Components[I]).ContextList[A].BaseURL   +
                                 TRESTDWServerContext(Components[I]).ContextList[A].ContextName);
         If vIsQuery Then
          Begin
           vTempRoute := vTempRoute + '?';
           If Copy(vTempValue, Length(vTempValue), 1) <> '?' Then
            vTempValue := vTempValue + '?';
          End
         Else
          Begin
           vTempRoute := vTempRoute + '/';
           If Copy(vTempValue, Length(vTempValue), 1) <> '/' Then
            vTempValue :=  vTempValue + '/';
          End;
         Result     := vTempRoute = Copy(vTempValue, 1, Length(vTempRoute));
         If Result Then
          Begin
           CopyParams(TRESTDWServerContext(Components[I]).ContextList[A].Params);
           URL        := vTempRoute;
           vTempValue := Copy(vTempValue, Length(URL), Length(vTempValue));
           If vIsQuery Then
            Begin
             If Copy(vTempValue, 1, 1) = '?' Then
              Delete(vTempValue, 1, 1);
             If Copy(vTempValue, Length(vTempValue), 1) = '?' Then
              Delete(vTempValue, Length(vTempValue), 1);
             If Copy(URL, Length(URL), 1) = '?' Then
              Delete(URL, Length(URL), 1);
            End
           Else
            Begin
             If Copy(vTempValue, Length(vTempValue), 1) = '/' Then
              Delete(vTempValue, Length(vTempValue), 1);
             If Copy(URL, Length(URL), 1) = '/' Then
              Delete(URL, Length(URL), 1);
            End;
           Break;
          End;
        End;
      End;
     If Result Then
      Begin
       ParseParams(vTempValue);
       Break;
      End;
    End;
  End;
End;

Procedure TServerMethodDataModule.SetClientInfo(ip,
                                                UserAgent,
                                                BaseRequest   : String;
                                                port          : Integer);
Begin
 vRESTDWClientInfo.SetClientInfo(Trim(ip), Trim(UserAgent), BaseRequest, Port);
End;

Constructor TServerMethodDataModule.Create(Sender: TComponent);
Begin
 Inherited Create(Sender);
 vRESTDWClientInfo               := TRESTDWClientInfo.Create;
 vClientWelcomeMessage           := '';
 vServerAuthOptions              := Nil;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  Encoding         := esUtf8;
 {$ELSE}
  Encoding         := esAscii;
 {$IFEND}
 {$ELSE}
  Encoding         := esUtf8;
 {$ENDIF}
End;

Procedure TServerMethodDataModule.SetClientWelcomeMessage(Value: String);
Begin
 vClientWelcomeMessage := Value;
End;

Constructor TRESTDWClientInfo.Create;
Begin
 Inherited;
 vip          := '0.0.0.0';
 vUserAgent   := 'Undefined';
 vport        := 0;
 vToken       := '';
 vBaseRequest := '';
End;

Procedure TRESTDWClientInfo.SetClientInfo(ip,
                                          UserAgent,
                                          BaseRequest : String;
                                          port        : Integer);
Begin
 vip          := Trim(ip);
 vUserAgent   := Trim(UserAgent);
 vport        := Port;
 vBaseRequest := BaseRequest;
End;

end.

