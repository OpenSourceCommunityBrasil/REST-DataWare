Unit uRESTDWIcsFCMTransport;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  OverbyteIcsHttpProt,
  OverbyteIcsSslBase,
  OverbyteIcsSslX509Utils,
  OverbyteIcsSSLEAY,
  uRESTDWFCMTransport,
  uRESTDWFCMCompat,
  uRESTDWFCMOpenSSLStream;

Type
  TRESTDWIcsFCMHTTPTransport = Class(TRESTDWFCMHTTPTransport)
  Private
    FHTTP    : TSslHttpCli;
    FSSL     : TSslContext;
    FHeaders : TStringList;

    Procedure BeforeHeaderSend(Sender       : TObject;
                               Const AMethod : String;
                               AHeaders      : TStrings);
  Public
    Constructor Create(AConnectTimeout, AReadTimeout : Integer);
    Destructor Destroy; Override;

    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Override;

    Function Post(Const AURL       : String;
                  AHeaders         : TStrings;
                  ABody            : TStream;
                  AResponse        : TStream;
                  AResponseError   : TStream) : Integer; Override;
  End;

  TRESTDWIcsFCMStreamTransport = Class(TRESTDWFCMOpenSSLStreamTransport)
  End;

Implementation

Constructor TRESTDWIcsFCMHTTPTransport.Create(AConnectTimeout, AReadTimeout : Integer);
Begin
  Inherited Create;

  FHeaders := TStringList.Create;
  FHTTP := TSslHttpCli.Create(Nil);
  FSSL := TSslContext.Create(Nil);

  FHTTP.MultiThreaded := True;
  FHTTP.SslContext := FSSL;
  FHTTP.FollowRelocation := True;
  FHTTP.Connection := 'close';
  FHTTP.RequestVer := '1.1';
  If AReadTimeout > 0 Then
    FHTTP.Timeout := (AReadTimeout + 999) Div 1000
  Else
    FHTTP.Timeout := 0;
  FHTTP.OnBeforeHeaderSend := BeforeHeaderSend;

  FSSL.SslVerifyPeer := True;
  FSSL.SslMinVersion := sslVerTLS1_2;
  FSSL.SslMaxVersion := sslVerMax;

  If (FSSL.SslCAFile = '') And
     (FSSL.SslCAPath = '') And
     (FSSL.SslCALines.Count = 0) Then
    FSSL.SslCALines.Text := sslRootCACertsBundle;

End;

Procedure TRESTDWIcsFCMHTTPTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                                  Const ACAFile,
                                                        ACAPath : String);
Begin
  FSSL.SslVerifyPeer := AVerifyPeer;

  If ACAFile <> '' Then
  Begin
    FSSL.SslCAFile := ACAFile;
    FSSL.SslCALines.Clear;
  End;

  If ACAPath <> '' Then
    FSSL.SslCAPath := ACAPath;

  If AVerifyPeer And
     (ACAFile = '') And
     (ACAPath = '') And
     (FSSL.SslCAFile = '') And
     (FSSL.SslCAPath = '') And
     (FSSL.SslCALines.Count = 0) Then
    FSSL.SslCALines.Text := sslRootCACertsBundle;

  FSSL.InitContext;
End;

Destructor TRESTDWIcsFCMHTTPTransport.Destroy;
Begin
  FHTTP.OnBeforeHeaderSend := Nil;
  FHTTP.SslContext := Nil;

  FHTTP.Free;
  FSSL.Free;
  FHeaders.Free;

  Inherited Destroy;
End;

Procedure TRESTDWIcsFCMHTTPTransport.BeforeHeaderSend(Sender       : TObject;
                                                      Const AMethod : String;
                                                      AHeaders      : TStrings);
Var
  I : Integer;
Begin
  For I := 0 To FHeaders.Count - 1 Do
    If (FHeaders.Names[I] <> '') And
       (Not SameText(FHeaders.Names[I], 'Content-Type')) And
       (Not SameText(FHeaders.Names[I], 'Accept')) And
       (Not SameText(FHeaders.Names[I], 'Content-Length')) And
       (Not SameText(FHeaders.Names[I], 'Host')) Then
      AHeaders.Add(
        FHeaders.Names[I] + ': ' +
        FHeaders.ValueFromIndex[I]
      );
End;

Function TRESTDWIcsFCMHTTPTransport.Post(Const AURL       : String;
                                         AHeaders         : TStrings;
                                         ABody            : TStream;
                                         AResponse        : TStream;
                                         AResponseError   : TStream) : Integer;
Var
  I : Integer;
  LContentType : String;
  LAccept      : String;
Begin
  Result := 0;

  If AResponse <> Nil Then
  Begin
    AResponse.Size := 0;
    AResponse.Position := 0;
  End;

  If AResponseError <> Nil Then
  Begin
    AResponseError.Size := 0;
    AResponseError.Position := 0;
  End;

  FHeaders.Clear;

  If AHeaders <> Nil Then
    FHeaders.Assign(AHeaders);

  LContentType := '';
  LAccept := '';

  For I := 0 To FHeaders.Count - 1 Do
  Begin
    If SameText(FHeaders.Names[I], 'Content-Type') Then
      LContentType := FHeaders.ValueFromIndex[I]
    Else
    If SameText(FHeaders.Names[I], 'Accept') Then
      LAccept := FHeaders.ValueFromIndex[I];
  End;

  FHTTP.URL := AURL;
  FHTTP.ContentTypePost := LContentType;
  FHTTP.Accept := LAccept;
  FHTTP.SendStream := ABody;
  FHTTP.RcvdStream := AResponse;

  If ABody <> Nil Then
    ABody.Position := 0;

  Try
    Try
      FHTTP.Post;
      Result := FHTTP.StatusCode;
    Except
      On E : Exception Do
      Begin
        Result := FHTTP.StatusCode;

        If (AResponseError <> Nil) And
           (E.Message <> '') Then
          RESTDWFCMWriteUTF8(
            AResponseError,
            E.Message
          );

        If Result = 0 Then
          Raise;
      End;
    End;

    If (Result >= 400) And
       (AResponse <> Nil) And
       (AResponseError <> Nil) And
       (AResponse.Size > 0) Then
    Begin
      AResponse.Position := 0;
      AResponseError.CopyFrom(AResponse, 0);
      AResponseError.Position := 0;
      AResponse.Size := 0;
    End;
  Finally
    FHTTP.SendStream := Nil;
    FHTTP.RcvdStream := Nil;

    If AResponse <> Nil Then
      AResponse.Position := 0;

    If AResponseError <> Nil Then
      AResponseError.Position := 0;
  End;
End;

End.
