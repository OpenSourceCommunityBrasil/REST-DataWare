Unit uRESTDWFCMTransport;

Interface

{$I uRESTDW.inc}

Uses
  Classes,
  SysUtils;

Type
  TRESTDWFCMHTTPTransport = Class
  Public
    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Virtual;

    Function Post(Const AURL        : String;
                  AHeaders          : TStrings;
                  ABody             : TStream;
                  AResponse         : TStream;
                  AResponseError    : TStream) : Integer; Virtual; Abstract;
  End;

  TRESTDWFCMStreamTransport = Class
  Public
    Procedure ConfigureTLS(AVerifyPeer : Boolean;
                           Const ACAFile,
                                 ACAPath : String); Virtual;

    Procedure Connect(Const AHost : String;
                      APort       : Integer); Virtual; Abstract;
    Procedure Disconnect; Virtual; Abstract;
    Function Connected : Boolean; Virtual; Abstract;
    Function ReadByte : Byte; Virtual; Abstract;
    Procedure ReadBuffer(Var ABuffer; ACount : Integer); Virtual; Abstract;
    Procedure WriteBuffer(Const ABuffer; ACount : Integer); Virtual; Abstract;
  End;

Implementation

Procedure TRESTDWFCMHTTPTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                               Const ACAFile,
                                                     ACAPath : String);
Begin
End;

Procedure TRESTDWFCMStreamTransport.ConfigureTLS(AVerifyPeer : Boolean;
                                                 Const ACAFile,
                                                       ACAPath : String);
Begin
End;

End.
