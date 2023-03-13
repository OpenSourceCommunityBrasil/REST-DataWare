Unit uRESTDWCoderMIME;

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
 Classes, uRESTDWCoder3to4, uRESTDWProtoTypes;

 Type
  TRESTDWEncoderMIME = Class(TRESTDWEncoder3to4)
 Protected
 Public
  Constructor Create(AOwner : TComponent); Reintroduce; Overload;
 End;
 TRESTDWDecoderMIME = Class(TRESTDWDecoder4to3)
 Protected
 Public
  Constructor Create(AOwner : TComponent); Reintroduce; Overload;
 End;
 TRESTDWDecoderMIMELineByLine = Class(TRESTDWDecoderMIME)
 Protected
  FLeftFromLastTime: TRESTDWBytes;
 Public
  Procedure DecodeBegin(ADestStream  : TStream);        Override;
  Procedure DecodeEnd; Override;
  Procedure Decode     (ASrcStream   : TStream;
                        Const ABytes : Integer = -1);   Override;
 End;

Const
 GBase64CodeTable   : String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

Var
 GBase64DecodeTable : TRESTDWDecodeTable;

Implementation

Uses
 uRESTDWTools,
 SysUtils;

Procedure TRESTDWDecoderMIMELineByLine.DecodeBegin(ADestStream : TStream);
Begin
 Inherited DecodeBegin(ADestStream);
 SetLength(FLeftFromLastTime, 0);
End;

Procedure TRESTDWDecoderMIMELineByLine.DecodeEnd;
Var
 LStream: TMemoryStream;
 LPos: Integer;
Begin
 If restdwLength(FLeftFromLastTime) > 0 Then
  Begin
   LPos := restdwLength(FLeftFromLastTime);
   SetLength(FLeftFromLastTime, 4);
   While LPos < 4 Do
    Begin
     FLeftFromLastTime[LPos] := Ord(FFillChar);
     Inc(LPos);
    End;
   LStream := TMemoryStream.Create;
   Try
    WriteBytesToStream(LStream, FLeftFromLastTime);
    LStream.Position := 0;
    Inherited Decode(LStream);
   Finally
    FreeAndNil(LStream);
    SetLength(FLeftFromLastTime, 0);
   End;
  End;
 Inherited DecodeEnd;
End;

Procedure TRESTDWDecoderMIMELineByLine.Decode(ASrcStream   : TStream;
                                              Const ABytes : Integer = -1);
Var
 LMod,
 LDiv    : Integer;
 LIn,
 LSrc    : TRESTDWBytes;
 LStream : TMemoryStream;
Begin
 LIn := FLeftFromLastTime;
 If ReadBytesFromStream(ASrcStream, LSrc, ABytes) > 0 Then
  AppendBytes(LIn, LSrc);
 LMod := restdwLength(LIn) Mod 4;
 If LMod <> 0 Then
  Begin
   LDiv              := (restdwLength(LIn) Div 4) * 4;
   FLeftFromLastTime := Copy(LIn, LDiv, restdwLength(LIn) - LDiv);
   LIn               := Copy(LIn, 0, LDiv);
  End
 Else
  SetLength(FLeftFromLastTime, 0);
 LStream := TMemoryStream.Create;
 Try
  WriteBytesToStream(LStream, LIn);
  LStream.Position := 0;
  Inherited Decode(LStream, ABytes);
 Finally
  FreeAndNil(LStream);
 End;
End;

Constructor TRESTDWDecoderMIME.Create(AOwner: TComponent);
Begin
 Inherited Create(AOwner);
 FDecodeTable := GBase64DecodeTable;
 FCodingTable := ToBytes(GBase64CodeTable);
 FFillChar    := '=';
End;

Constructor TRESTDWEncoderMIME.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 FCodingTable := ToBytes(GBase64CodeTable);
 FFillChar    := '=';
End;

Initialization
 TRESTDWDecoder4to3.ConstructDecodeTable(GBase64CodeTable, GBase64DecodeTable);
End.
