unit uRESTDWMessageClient;

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
  Classes,
  uRESTDWCoderMIME, uRESTDWHeaderList, uRESTDWProtoTypes, uRESTDWConsts,
  uRESTDWTools, uRESTDWIOHandlerStream, uRESTDWMessage;

 Type
  TRESTDWIOHandlerStreamMsg = Class(TRESTDWIOHandlerStream)
 Protected
//  FMaxLineLength     : Integer;
  FTerminatorWasRead,
  FEscapeLines,
  FUnescapeLines     : Boolean;
  FLastByteRecv      : Byte;
  Function ReadDataFromSource(Var VBuffer : TRESTDWBytes): Integer;
 Public
  Constructor Create (AOwner         : TComponent;
                      AReceiveStream : TStream;
                      ASendStream    : TStream = Nil); Override;  //Should this be reintroduce instead of override?
  Function ReadLn    (ATerminator    : String;
                      ATimeout       : Integer = cTimeoutDefault;
                      AMaxLineLength : Integer = -1) : String;
  Procedure   WriteLn(Const AOut     : String);
  Property    EscapeLines   : Boolean Read FEscapeLines   Write FEscapeLines;
  property    UnescapeLines : Boolean Read FUnescapeLines Write FUnescapeLines;
 Published
  Property MaxLineLength : Integer Read FMaxLineLength Write FMaxLineLength Default MaxInt;
 End;


Implementation

Uses
 uRESTDWMessageCoderBinHex4,
 uRESTDWMessageCoderQuotedPrintable,
 uRESTDWMessageCoderMIME,
 uRESTDWCoder,
 uRESTDWCoder3to4,
 uRESTDWCoderBinHex4,
 uRESTDWCoderHeader,
 uRESTDWHeaderCoderBase,
 uRESTDWMessageCoder,
 uRESTDWException,
 uRESTDWAttachmentFile,
 uRESTDWAttachment,
 SysUtils;

Const
  SContentType                        = 'Content-Type'; {do not localize}
  SContentTransferEncoding            = 'Content-Transfer-Encoding'; {do not localize}
  SThisIsMultiPartMessageInMIMEFormat = 'This is a multi-part message in MIME format'; {do not localize}

Function GetLongestLine(Var ALine    : String;
                        Const ADelim : String) : String;
Var
 i,
 fnd,
 delimLen : Integer;
Begin
 Result := '';
 fnd := 0;
 delimLen := Length(ADelim);
 For i := 1 To Length(ALine) Do
  Begin
   If ALine[i] = ADelim[1] Then
    Begin
     If Copy(ALine, i, delimLen) = ADelim Then
      fnd := i;
    End;
  End;
 If fnd > 0 Then
  Begin
   Result := Copy(ALine, 1, fnd - 1);
   ALine := Copy(ALine, fnd + delimLen, MaxInt);
  End;
End;

Procedure RemoveLastBlankLine(Body: TStrings);
Var
 Count : Integer;
Begin
 If Assigned(Body) Then
  Begin
   Count := Body.Count;
   If (Count > 0)            And
      (Body[Count - 1] = '') Then
    Body.Delete(Count - 1);
  End;
End;

Constructor TRESTDWIOHandlerStreamMsg.Create(AOwner         : TComponent;
                                             AReceiveStream : TStream;
                                             ASendStream    : TStream = Nil);
Begin
 Inherited Create(AOwner, AReceiveStream, ASendStream);
 FTerminatorWasRead := False;
 FEscapeLines       := False; // do not set this to True! This is for users to set manually...
 FUnescapeLines     := False; // do not set this to True! This is for users to set manually...
 FLastByteRecv      := 0;
 FMaxLineLength     := MaxInt;
End;

Function TRESTDWIOHandlerStreamMsg.ReadDataFromSource(var VBuffer: TRESTDWBytes): Integer;
Var
 LTerminator : String;
Begin
 If not FTerminatorWasRead then
  Begin
   Result := Inherited ReadDataFromSource(VBuffer);
   If Result > 0 Then
    Begin
     FLastByteRecv := VBuffer[Result-1];
     Exit;
    End;
   If (FLastByteRecv = Ord(LF)) Then
    LTerminator := '.' + EOL
   Else If (FLastByteRecv = Ord(CR)) Then
    LTerminator := LF + '.' + EOL
   Else
    LTerminator := EOL + '.' + EOL;
   FTerminatorWasRead := True;
   CopyRDWString(LTerminator, VBuffer, 0);
   Result := Length(LTerminator);
  End
 Else
  Result := 0;
End;

Function TRESTDWIOHandlerStreamMsg.ReadLn(ATerminator    : String;
                                          ATimeout       : Integer = cTimeoutDefault;
                                          AMaxLineLength : Integer = -1) : String;
Begin
 Result := Inherited ReadLn(ATerminator, ATimeout, AMaxLineLength);
 If FEscapeLines                And
    TextStartsWith(Result, '.') And
    (Not FTerminatorWasRead)    Then
  Result := '.' + Result;
End;

procedure TRESTDWIOHandlerStreamMsg.WriteLn(Const AOut: String);
Var
 LOut : String;
Begin
 LOut := AOut;
 If FUnescapeLines And
    TextStartsWith(LOut, '..') Then
  RDWDelete(LOut, 1, 1);
// Inherited WriteLn(LOut);
end;

end.
