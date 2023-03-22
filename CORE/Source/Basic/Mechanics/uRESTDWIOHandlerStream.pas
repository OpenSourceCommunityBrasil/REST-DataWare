unit uRESTDWIOHandlerStream;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface

Uses
 Classes, uRESTDWBasicTypes, uRESTDWProtoTypes, uRESTDWTools, uRESTDWConsts,
 uRESTDWIOHandler, uRESTDWAbout;

 Type
  TRESTDWIOHandlerStream     = Class;
  TRESTDWIOHandlerStreamType = (stRead, stWrite, stReadWrite);
  TRESTDWOnGetStreams        = Procedure(ASender            : TRESTDWIOHandlerStream;
                                         Var VReceiveStream : TStream;
                                         Var VSendStream    : TStream) Of Object;
  TRESTDWIOHandlerStream     = Class(TRESTDWIOHandler)
  Protected
   FFreeStreams    : Boolean;
   FOnGetStreams   : TRESTDWOnGetStreams;
   FReceiveStream,
   FSendStream     : TStream;
   FStreamType     : TRESTDWIOHandlerStreamType;
   Function  ReadDataFromSource(Var VBuffer    : TRESTDWBytes) : Integer;
   Function  WriteDataToTarget (Const ABuffer  : TRESTDWBytes;
                                Const AOffset,
                                ALength        : Integer)      : Integer;
   Function  SourceIsAvailable                 : Boolean;
   Function  CheckForError     (ALastResult    : Integer)      : Integer;
   Procedure RaiseError        (AError         : Integer);
  Public
   Constructor Create(AOwner         : TComponent;
                      AReceiveStream : TStream;
                      ASendStream    : TStream = nil); Reintroduce; Overload; Virtual;
   Constructor Create(AOwner: TComponent); Reintroduce; Overload;
   Procedure Close;
   Procedure Open;
   Property  StreamType    : TRESTDWIOHandlerStreamType Read FStreamType;
   Property  ReceiveStream : TStream                    Read FReceiveStream;
   Property  SendStream    : TStream                    Read FSendStream;
  Published
   Property  FreeStreams   : Boolean                    Read FFreeStreams Write FFreeStreams Default True;
   Property OnGetStreams: TRESTDWOnGetStreams read FOnGetStreams write FOnGetStreams;
  End;

implementation

uses
  uRESTDWException, SysUtils;

Procedure TRESTDWIOHandlerStream.Close;
Begin
 If FreeStreams Then
  Begin
   FreeAndNil(FReceiveStream);
   FreeAndNil(FSendStream);
  End
 Else
  Begin
   FReceiveStream := Nil;
   FSendStream    := Nil;
  End;
End;

Constructor TRESTDWIOHandlerStream.Create(AOwner : TComponent);
Begin
 Inherited Create;
 FFreeStreams := True;
 FStreamType := stReadWrite;
End;

Constructor TRESTDWIOHandlerStream.Create(AOwner         : TComponent;
                                          AReceiveStream : TStream;
                                          ASendStream    : TStream = Nil);
begin
 Inherited Create;
 FFreeStreams   := True;
 FReceiveStream := AReceiveStream;
 FSendStream    := ASendStream;
 If Assigned(FReceiveStream)   And
   (Not Assigned(FSendStream)) Then
  FStreamType := stRead
 Else If (Not Assigned(FReceiveStream)) And
          Assigned(FSendStream)         Then
  FStreamType := stWrite
 Else
  FStreamType := stReadWrite;
End;

Procedure TRESTDWIOHandlerStream.Open;
Begin
 If Assigned(OnGetStreams) Then
  OnGetStreams(Self, FReceiveStream, FSendStream);
 If Assigned(FReceiveStream)   And
   (Not Assigned(FSendStream)) Then
  FStreamType := stRead
 Else If (Not Assigned(FReceiveStream)) And
         Assigned(FSendStream)          Then
  FStreamType := stWrite
 Else
  FStreamType := stReadWrite;
End;

Function TRESTDWIOHandlerStream.ReadDataFromSource(Var VBuffer : TRESTDWBytes) : Integer;
Begin
 If Assigned(FReceiveStream) Then
  Begin
   Result := restdwMin(32 * 1024, restdwLength(VBuffer));
   If Result > 0 Then
    Result := TRESTDWStreamHelper.ReadBytes(FReceiveStream, VBuffer, Result);
  End
 Else
  Result := 0;
End;

Function TRESTDWIOHandlerStream.WriteDataToTarget(Const ABuffer  : TRESTDWBytes;
                                                  Const AOffset,
                                                  ALength        : Integer) : Integer;
Begin
 If Assigned(FSendStream) Then
  Result := TRESTDWStreamHelper.Write(FSendStream, ABuffer, ALength, AOffset)
 Else
  Result := restdwLength(ABuffer, ALength, AOffset);
End;

Function TRESTDWIOHandlerStream.SourceIsAvailable: Boolean;
Begin
 Result := Assigned(ReceiveStream);
End;

Function TRESTDWIOHandlerStream.CheckForError(ALastResult : Integer) : Integer;
Begin
 Result := ALastResult;
 If Result < 0 Then
  Raise eRESTDWException.Create('Stream error'); {do not localize}
End;

Procedure TRESTDWIOHandlerStream.RaiseError(AError: Integer);
Begin
 Raise eRESTDWException.Create('Stream error'); {do not localize}
End;

End.
