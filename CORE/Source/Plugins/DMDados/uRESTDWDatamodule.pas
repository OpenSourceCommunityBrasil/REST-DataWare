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
var
  I, A,
  vPosQuery   : Integer;
  vIsQuery    : Boolean;
  vTempRoute,
  vTempValue,
  vTempParamsURI,
  vTempURL : String;
  ParamsURI : String;
  vParamMethods : TRESTDWParamsMethods;

  procedure ParseParams;
  var
    lst : TStringList;
    pAux1, cAux1 : integer;
    sAux1, sAux2 : string;
    JSONParam   : TJSONParam;
  begin
    lst := TStringList.Create;
    try
      pAux1 := Pos('?',ParamsURI);
      // params com /
      sAux1 := Copy(ParamsURI,1,pAux1-1);
      // params com &
      sAux2 := Copy(ParamsURI,pAux1+1,Length(ParamsURI));

      cAux1 := 0;
      while (sAux1 <> '') do begin
        pAux1 := Pos('/',sAux1);
        if pAux1 = 0 then
          pAux1 := Length(sAux1)+1;

        lst.Add(IntToStr(cAux1)+'='+Copy(sAux1,1,pAux1-1));

        cAux1 := cAux1 + 1;
        Delete(sAux1,1,pAux1);
      end;

      while (sAux2 <> '') do begin
        pAux1 := Pos('&',sAux2);
        if pAux1 = 0 then
          pAux1 := Length(sAux2)+1;

        sAux1 := Copy(sAux2,1,pAux1-1);

        if Pos('dwmark:', sAux1) = 0 then
          lst.Add(sAux1);

        Delete(sAux2,1,pAux1);
      end;

      while lst.Count > 0 do begin
        JSONParam  := Params.ItemsString[lst.Names[0]];
        if JSONParam = Nil then begin
          JSONParam := TJSONParam.Create(Params.Encoding);
          JSONParam.ParamName := lst.Names[0];
          JSONParam.ObjectDirection := odIN;
          JSONParam.SetValue(lst.ValueFromIndex[0]);
          Params.Add(JSONParam);
        end
        else if JSONParam.IsNull then begin
          JSONParam.SetValue(lst.ValueFromIndex[0]);
        end;
        lst.Delete(0);
      end;
    finally
      FreeAndNil(lst);
    end;
  end;

  procedure CopyParams(SourceParams : TRESTDWParamsMethods);
  var
    isrc : Integer;
    vTempParam : TJSONParam;
  begin
    for isrc := 0 To SourceParams.Count -1 do begin
      if SourceParams.Items[isrc].ObjectDirection in [odIN, odINOUT] then begin
        if Params.ItemsString[SourceParams.Items[isrc].ParamName] = nil then begin
          vTempParam := TJSONParam.Create(Params.Encoding);
          vTempParam.CopyFrom(SourceParams.Items[isrc]);
          Params.Add(vTempParam);
        end;
      end;
    end;
  end;

  procedure ParseURL;
  begin
    vPosQuery  := Pos('?', URL);
    vIsQuery   := vPosQuery > 0;

    ParamsURI := '';
    if vIsQuery then begin
      ParamsURI := Copy(URL,vPosQuery+1,Length(URL));
      URL := Copy(URL,1,vPosQuery-1);
    end;

    // url igual http://localhost:8082/usuarios//?var=teste
    while (URL <> '') and (URL[Length(URL)] in ['/','?']) do
      Delete(URL,Length(URL),1);

    // url http://localhost:8082/usuarios//login//?var=teste
    while (Pos('//',URL) > 0) do
      Delete(URL,Pos('//',URL),1);

    // ParamsURI = /?teste=1
    while (ParamsURI <> '') and (ParamsURI[InitStrPos] in ['/','?']) do
      Delete(ParamsURI,InitStrPos,1);

    if URL = '' then
      URL := '/';
  end;

Begin
  Result   := False;
  if Length(URL) = 0 Then
    Exit;

  ParseURL;

  vTempValue := URL;

  for I := 0 To ComponentCount -1 do begin
    if (Components[i] is TRESTDWServerEvents) then begin
      for A := 0 To TRESTDWServerEvents(Components[I]).Events.Count -1 do begin
        vTempRoute := TRESTDWServerEvents(Components[I]).Events[A].BaseURL   +
                      TRESTDWServerEvents(Components[I]).Events[A].EventName;

        if ((vTempValue = '/') or (vTempValue = '')) then begin
          if TRESTDWServerEvents(Components[I]).DefaultEvent <> '' then begin
            vTempValue := TRESTDWServerEvents(Components[I]).DefaultEvent;
            if vTempValue[InitStrPos] <> '/' then
              vTempValue :=  '/' + vTempValue;
          end;
        end;

        if SameText(vTempRoute, vTempValue) then begin
          Result := True;
          vTempURL := vTempRoute;
          vTempParamsURI := '';
          vParamMethods := TRESTDWServerEvents(Components[I]).Events[A].Params;
          Break;
        end
        else if SameText(vTempRoute, Copy(vTempValue,1,Length(vTempRoute))) then begin
          Result := True;
          vTempURL := vTempRoute;
          vTempParamsURI := Copy(vTempValue,Length(vTempRoute)+2,Length(vTempValue));
          vParamMethods := TRESTDWServerEvents(Components[I]).Events[A].Params;
        end;
      end;
    end
    else if (Components[i] is TRESTDWServerContext) then begin
      for A := 0 To TRESTDWServerContext(Components[I]).ContextList.Count -1 do begin
        vTempRoute := TRESTDWServerContext(Components[I]).ContextList[A].BaseURL   +
                      TRESTDWServerContext(Components[I]).ContextList[A].ContextName;
        if ((vTempValue = '/') or (vTempValue = '')) then begin
          if TRESTDWServerContext(Components[I]).DefaultContext <> '' then begin
            vTempValue := TRESTDWServerContext(Components[I]).DefaultContext;
            if vTempValue[InitStrPos] <> '/' then
              vTempValue :=  '/' + vTempValue;
          end;
        end;

        if SameText(vTempRoute, vTempValue) then begin
          Result := True;
          vTempURL := vTempRoute;
          vTempParamsURI := '';
          vParamMethods := TRESTDWServerContext(Components[I]).ContextList[A].Params;
          Break;
        end
        else if SameText(vTempRoute, Copy(vTempValue,1,Length(vTempRoute))) then begin
          Result := True;
          vTempURL := vTempRoute;
          vTempParamsURI := Copy(vTempValue,Length(vTempRoute)+2,Length(vTempValue));
          vParamMethods := TRESTDWServerContext(Components[I]).ContextList[A].Params;
        end;
      end;
    end;

    if Result then begin
      CopyParams(vParamMethods);

      URL := vTempURL;
      ParamsURI := '?'+ParamsURI;
      ParamsURI := vTempParamsURI+ParamsURI;

      ParseParams;
      Break;
    end;
  end;

  if (not Result) and ((URL = '') or (URL = '/')) then
    URL := '';
end;

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

