Unit uRESTDWFpHttpFCMTransport;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  fphttpclient,
  ssockets,
  sslsockets,
  opensslsockets,
  uRESTDWFCMTransport,
  uRESTDWFCMCompat,
  uRESTDWFCMOpenSSLStream;

Type
  TRESTDWFpHttpFCMHTTPTransport = Class(TRESTDWFCMHTTPTransport)
  Private
    FConnectTimeout : Integer;
    FReadTimeout    : Integer;
    FVerifyPeer     : Boolean;
    FCAFile         : String;
    FCAPath         : String;

    Procedure GetSocketHandler(Sender : TObject;
                               Const UseSSL : Boolean;
                               Out AHandler : TSocketHandler);
  Public
    Constructor Create(AConnectTimeout, AReadTimeout : Integer);

    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Override;

    Function Post(Const AURL       : String;
                  AHeaders         : TStrings;
                  ABody            : TStream;
                  AResponse        : TStream;
                  AResponseError   : TStream) : Integer; Override;
  End;

  TRESTDWFpHttpFCMStreamTransport = Class(TRESTDWFCMOpenSSLStreamTransport)
  End;

Implementation

Procedure TRESTDWFpHttpFCMHTTPTransport.GetSocketHandler(Sender : TObject;
 Const UseSSL : Boolean;
 Out AHandler : TSocketHandler);
Var
 LSSL : TSSLSocketHandler;
Begin
 AHandler := Nil;
 If Not UseSSL Then
  Exit;
 LSSL := TSSLSocketHandler.GetDefaultHandler;
 LSSL.VerifyPeerCert := FVerifyPeer;
 If FCAFile <> '' Then
  LSSL.CertificateData.CertCA.FileName := FCAFile;
 {$IF FPC_FULLVERSION >= 30301}
 If FCAPath <> '' Then
  LSSL.CertificateData.TrustedCertsDir := FCAPath;
 {$ENDIF}
 AHandler := LSSL;
End;

Constructor TRESTDWFpHttpFCMHTTPTransport.Create(AConnectTimeout, AReadTimeout : Integer);
Begin
  Inherited Create;

  FConnectTimeout := AConnectTimeout;
  FReadTimeout := AReadTimeout;
  FVerifyPeer := True;
  FCAFile := '';
  FCAPath := '';
End;

Procedure TRESTDWFpHttpFCMHTTPTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                             Const ACAFile,
                                                   ACAPath : String);
Begin
  FVerifyPeer := AVerifyPeer;
  FCAFile := ACAFile;
  FCAPath := ACAPath;
End;

Function TRESTDWFpHttpFCMHTTPTransport.Post(Const AURL       : String;
                                            AHeaders         : TStrings;
                                            ABody            : TStream;
                                            AResponse        : TStream;
                                            AResponseError   : TStream) : Integer;
Var
  LHTTP : TFPHTTPClient;
  I     : Integer;
Begin
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

  LHTTP := TFPHTTPClient.Create(Nil);
  Try
    LHTTP.AllowRedirect := True;
    LHTTP.ConnectTimeout := FConnectTimeout;
    LHTTP.IOTimeout := FReadTimeout;

    LHTTP.OnGetSocketHandler := {$IFDEF FPC}@{$ENDIF}GetSocketHandler;

    If AHeaders <> Nil Then
      For I := 0 To AHeaders.Count - 1 Do
        LHTTP.AddHeader(AHeaders.Names[I],
                        AHeaders.ValueFromIndex[I]);

    If ABody <> Nil Then
    Begin
      ABody.Position := 0;
      LHTTP.RequestBody := ABody;
    End;

    Try
      LHTTP.Post(AURL, AResponse);
      Result := LHTTP.ResponseStatusCode;
    Except
      On E : Exception Do
      Begin
        Result := LHTTP.ResponseStatusCode;

        If (Result >= 400) And
           (AResponse <> Nil) And
           (AResponseError <> Nil) And
           (AResponse.Size > 0) Then
        Begin
          AResponse.Position := 0;
          AResponseError.CopyFrom(AResponse, 0);
          AResponseError.Position := 0;
          AResponse.Size := 0;
        End
        Else
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

    If AResponse <> Nil Then
      AResponse.Position := 0;

    If AResponseError <> Nil Then
      AResponseError.Position := 0;

  Finally
    LHTTP.RequestBody := Nil;
    LHTTP.Free;
  End;
End;

End.
