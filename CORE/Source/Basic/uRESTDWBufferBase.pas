unit uRESTDWBufferBase;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do pacote.
 A. Brito                   - Admin - Administrador do desenvolvimento.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

Uses {$IFDEF FPC}
      SysUtils, Classes
     {$ELSE}
      {$IF CompilerVersion <= 22}
       SysUtils, Classes
      {$ELSE}
       System.SysUtils, System.Classes
      {$IFEND}
     {$ENDIF},
     uRESTDWBasicComponent,
     uRESTDWBasicTypes;

Type
 TRESTDWBufferBase = Class(TObject)
 Private
  vBufferBase : TStream;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Procedure   ResetPosition;
  Function    Size : DWBufferSize;
  Function    Eof  : Boolean;
  Function    Bof  : Boolean;
  Procedure   NewBuffer;
  Procedure   InputStream (Const Stream   : TStream);
  Procedure   InputBytes  (aBytes         : TRESTDWBytes);
  Function    ReadStream                  : TStream;
  Function    ReadBytes                   : TRESTDWBytes;
  Procedure   SaveToStream(Var Stream     : TStream);
  Procedure   SaveToFile  (aFileName      : String);
  Procedure   LoadToStream(Const Stream   : TStream;
                           aResetBuffer   : Boolean = True;
                           aResetPosition : Boolean = True);
  Procedure   LoadToFile  (aFileName      : String;
                           aResetBuffer   : Boolean = True;
                           aResetPosition : Boolean = True);
 End;

implementation

uses uRESTDWConsts;

Function  TRESTDWBufferBase.ReadBytes : TRESTDWBytes;
Var
 vBufferSize : DWBufferSize;
Begin
 vBufferSize    := 0;
 SetLength(Result, 0);
 If vBufferBase.Size > 0 Then
  Begin
   Try
    vBufferBase.Read(vBufferSize, SizeOf(DWBufferSize));
    If vBufferSize > 0 Then
     Begin
      SetLength(Result,           vBufferSize);
      vBufferBase.Read(Result[0], vBufferSize);
     End;
   Except

   End;
  End;
End;

Procedure TRESTDWBufferBase.SaveToFile(aFileName : String);
Var
 aStream : TMemoryStream;
Begin
 aStream := Nil;
 Try
  SaveToStream(TStream(aStream));
  If aStream.Size > 0 Then
   aStream.SaveToFile(aFileName);
 Finally
  FreeAndNil(aStream);
 End;
End;

Procedure TRESTDWBufferBase.SaveToStream(Var Stream : TStream);
Begin
 vBufferBase.Position := 0;
 If Not Assigned(Stream) Then
  Stream := TMemoryStream.Create;
 Stream.CopyFrom(vBufferBase, vBufferBase.Size);
 Stream.Position := 0;
 ResetPosition;
End;

Function TRESTDWBufferBase.Size : DWBufferSize;
Begin
 Result := vBufferBase.Size;
End;

Procedure TRESTDWBufferBase.LoadToFile(aFileName      : String;
                                       aResetBuffer   : Boolean = True;
                                       aResetPosition : Boolean = True);
Var
 aStream : TMemoryStream;
Begin
 aStream := Nil;
 Try
  If FileExists(aFileName) Then
   Begin
    aStream := TMemoryStream.Create;
    aStream.LoadFromFile(aFileName);
    aStream.Position := 0;
    LoadToStream(aStream, aResetBuffer, aResetPosition);
   End;
 Finally
  If Assigned(aStream) Then
   FreeAndNil(aStream);
 End;
End;

Procedure TRESTDWBufferBase.LoadToStream(Const Stream   : TStream;
                                         aResetBuffer   : Boolean = True;
                                         aResetPosition : Boolean = True);
Var
 vBufferPosition : DWBufferSize;
Begin
 If Assigned(Stream) Then
  Begin
   If aResetBuffer Then
    NewBuffer;
   vBufferPosition := Stream.Position;
   Try
    vBufferBase.CopyFrom(Stream, Stream.Size);
   Finally
    Stream.Position := vBufferPosition;
   End;
   If aResetPosition Then
    ResetPosition;
  End;
End;

Function TRESTDWBufferBase.ReadStream : TStream;
Var
 vBufferSize : DWBufferSize;
Begin
 Result := Nil;
 If vBufferBase.Size > 0 Then
  Begin
   Try
    vBufferBase.Read(vBufferSize, SizeOf(DWBufferSize));
    If vBufferSize > 0 Then
     Begin
      Result := TMemoryStream.Create;
      Result.CopyFrom(vBufferBase, vBufferSize);
      Result.Position := 0;
     End;
   Except

   End;
  End;
End;

Procedure TRESTDWBufferBase.ResetPosition;
Begin
 vBufferBase.Position := 0;
End;

Procedure TRESTDWBufferBase.InputStream(Const Stream : TStream);
Var
 vBufferSize : DWBufferSize;
Begin
 Try
  If Assigned(Stream) Then
   Begin
    vBufferSize := Stream.Size;
    If vBufferSize > 0 Then
     Begin
      vBufferBase.Write(vBufferSize, SizeOf(DWBufferSize));
      vBufferBase.CopyFrom(Stream, vBufferSize);
     End
    Else
     vBufferBase.Write(vBufferSize, SizeOf(DWBufferSize));
   End;
 Finally
 End;
End;

Procedure TRESTDWBufferBase.NewBuffer;
Begin
 FreeAndNil(vBufferBase);
 vBufferBase := TMemoryStream.Create;
End;

Function TRESTDWBufferBase.Bof : Boolean;
Begin
 Result := Assigned(vBufferBase);
 If Result Then
  Result := vBufferBase.Position = 0;
End;

Constructor TRESTDWBufferBase.Create;
Begin
 vBufferBase := TMemoryStream.Create;
End;

Destructor TRESTDWBufferBase.Destroy;
Begin
 FreeAndNil(vBufferBase);
 Inherited;
End;

Function TRESTDWBufferBase.Eof: Boolean;
Begin
 Result := Not Assigned(vBufferBase);
 If Not Result Then
  Result := vBufferBase.Position = vBufferBase.Size;
End;

Procedure TRESTDWBufferBase.InputBytes (aBytes : TRESTDWBytes);
Var
 vBufferSize : DWBufferSize;
Begin
 Try
  vBufferSize := Length(aBytes);
  If Length(aBytes) > 0 Then
   Begin
    vBufferBase.Write(vBufferSize, SizeOf(DWBufferSize));
    vBufferBase.Write(aBytes[0], vBufferSize);
   End
  Else
   vBufferBase.Write(vBufferSize, SizeOf(DWBufferSize));
 Finally
 End;
End;

end.
