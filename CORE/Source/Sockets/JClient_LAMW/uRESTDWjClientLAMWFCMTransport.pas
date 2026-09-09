Unit uRESTDWjClientLAMWFCMTransport;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils,
  uRESTDWFCMTransport;

Type
  TRESTDWjClientLAMWFCMHTTPTransport = Class(TRESTDWFCMHTTPTransport)
  Public
    Function Post(Const AURL       : String;
                  AHeaders         : TStrings;
                  ABody            : TStream;
                  AResponse        : TStream;
                  AResponseError   : TStream) : Integer; Override;
  End;

  TRESTDWjClientLAMWFCMStreamTransport = Class(TRESTDWFCMStreamTransport)
  Public
    Procedure Connect(Const AHost : String;
                      APort       : Integer); Override;
    Procedure Disconnect; Override;
    Function Connected : Boolean; Override;
    Function ReadByte : Byte; Override;
    Procedure ReadBuffer(Var ABuffer; ACount : Integer); Override;
    Procedure WriteBuffer(Const ABuffer; ACount : Integer); Override;
  End;

Implementation

Function TRESTDWjClientLAMWFCMHTTPTransport.Post(Const AURL       : String;
                                                 AHeaders         : TStrings;
                                                 ABody            : TStream;
                                                 AResponse        : TStream;
                                                 AResponseError   : TStream) : Integer;
Begin
  Raise Exception.Create(
    'RESTDW JClient/LAMW FCM transport: TODO para o motor REST Dataware nativo'
  );
End;

Procedure TRESTDWjClientLAMWFCMStreamTransport.Connect(Const AHost : String;
                                                       APort       : Integer);
Begin
  Raise Exception.Create(
    'RESTDW JClient/LAMW FCM stream: TODO para o motor REST Dataware nativo'
  );
End;

Procedure TRESTDWjClientLAMWFCMStreamTransport.Disconnect;
Begin
End;

Function TRESTDWjClientLAMWFCMStreamTransport.Connected : Boolean;
Begin
  Result := False;
End;

Function TRESTDWjClientLAMWFCMStreamTransport.ReadByte : Byte;
Begin
  Raise Exception.Create(
    'RESTDW JClient/LAMW FCM stream: TODO para o motor REST Dataware nativo'
  );
End;

Procedure TRESTDWjClientLAMWFCMStreamTransport.ReadBuffer(Var ABuffer;
                                                          ACount : Integer);
Begin
  Raise Exception.Create(
    'RESTDW JClient/LAMW FCM stream: TODO para o motor REST Dataware nativo'
  );
End;

Procedure TRESTDWjClientLAMWFCMStreamTransport.WriteBuffer(Const ABuffer;
                                                           ACount : Integer);
Begin
  Raise Exception.Create(
    'RESTDW JClient/LAMW FCM stream: TODO para o motor REST Dataware nativo'
  );
End;

End.
