unit uRESTDWMessageParts;

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
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFNDEF RESTDWLAZARUS}
 {$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
 {$ENDIF}
{$ENDIF}

Interface

Uses
 Classes, uRESTDWException, uRESTDWProtoTypes, uRESTDWHeaderList;

 Type
  TOnGetMessagePartStream = Procedure(AStream: TStream) of object;
  TRESTDWMessagePartType  = (mptText, mptAttachment);
  TRESTDWMessageParts     = Class;
  TRESTDWMessagePart      = Class(TCollectionItem)
  Protected
   FContentMD5,
   FCharSet,
   FEndBoundary,
   FFileName,
   FName         : String;
   FExtraHeaders : TRESTDWHeaderList;
   FHeaders      : TRESTDWHeaderList;
   FIsEncoded    : Boolean;
   FOnGetMessagePartStream: TOnGetMessagePartStream;
   FParentPart   : Integer;
   Function  GetContentDisposition : String; Virtual;
   Function  GetContentType        : String; Virtual;
   Function  GetContentTransfer    : String; Virtual;
   Function  GetContentID          : String; Virtual;
   Function  GetContentLocation    : String; Virtual;
   Function  GetContentDescription : String; Virtual;
   Function  GetMessageParts       : TRESTDWMessageParts;
   Function  GetOwnerMessage       : TPersistent;
   Procedure SetContentDisposition(Const Value : String); Virtual;
   Procedure SetContentType       (Const Value : String); Virtual;
   Procedure SetContentTransfer   (Const Value : String); Virtual;
   Procedure SetExtraHeaders      (Const Value : TRESTDWHeaderList);
   Procedure SetContentID         (Const Value : String); Virtual;
   Procedure SetContentDescription(Const Value : String); Virtual;
   Procedure SetContentLocation   (Const Value : String); Virtual;
  Public
   Constructor Create(aCollection : TCollection); Override;
   Destructor Destroy; Override;
   Procedure  Assign            (Source       : TPersistent); Override;
   Function   GetCharSet        (AHeader      : String) : String;
   Function   ResolveContentType(AContentType : String) : String;
   Class Function PartType         : TRESTDWMessagePartType; Virtual;
   Property IsEncoded              : Boolean                 Read FIsEncoded;
   Property MessageParts           : TRESTDWMessageParts     Read GetMessageParts;
   Property OwnerMessage           : TPersistent             Read GetOwnerMessage;
   Property OnGetMessagePartStream : TOnGetMessagePartStream Read FOnGetMessagePartStream Write FOnGetMessagePartStream;
   Property Headers                : TRESTDWHeaderList       Read FHeaders;
  Published
   Property CharSet                : String                  Read FCharSet              Write FCharSet;
   Property ContentDescription     : String                  Read GetContentDescription Write SetContentDescription;
   Property ContentDisposition     : String                  Read GetContentDisposition Write SetContentDisposition;
   Property ContentID              : String                  Read GetContentID          Write SetContentID;
   Property ContentLocation        : String                  Read GetContentLocation    Write SetContentLocation;
   Property ContentTransfer        : String                  Read GetContentTransfer    Write SetContentTransfer;
   Property ContentType            : String                  Read GetContentType        Write SetContentType;
   Property ExtraHeaders           : TRESTDWHeaderList       Read FExtraHeaders         Write SetExtraHeaders;
   Property FileName               : String                  Read FFileName             Write FFileName;
   Property Name                   : String                  Read FName                 Write FName;
   Property ParentPart             : Integer                 Read FParentPart           Write FParentPart;
  End;
  TRESTDWMessagePartClass = Class Of TRESTDWMessagePart;
  TRESTDWMessageParts     = Class(TOwnedCollection)
  Protected
   FAttachmentEncoding : String;
   FAttachmentCount,
   FRelatedPartCount,
   FTextPartCount      : Integer;
   FMessageEncoderInfo : TObject;
   Function  GetItem  (Index : Integer): TRESTDWMessagePart;
   Function  GetOwnerMessage : TPersistent;
   Procedure SetAttachmentEncoding(Const AValue : String);
   Procedure SetItem              (Index        : Integer;
                                   Const Value  : TRESTDWMessagePart);
  Public
   Function Add : TRESTDWMessagePart;
   Procedure CountParts;
   Constructor Create(AOwner          : TPersistent); Reintroduce;
   Property    AttachmentCount        : Integer            Read FAttachmentCount;
   Property    AttachmentEncoding     : String             Read FAttachmentEncoding Write SetAttachmentEncoding;
   Property    Items[Index : Integer] : TRESTDWMessagePart Read GetItem             Write SetItem; Default;
   Property    MessageEncoderInfo     : TObject            Read FMessageEncoderInfo;
   Property    OwnerMessage           : TPersistent        Read GetOwnerMessage;
   Property    RelatedPartCount       : Integer            Read FRelatedPartCount;
   Property    TextPartCount          : Integer            Read FTextPartCount;
  End;

  eRESTDWCanNotCreateMessagePart = class(eRESTDWException);

Implementation

Uses
 SysUtils,
 uRESTDWTools,
 uRESTDWConsts,
 uRESTDWMessage,
 uRESTDWCoderHeader,
 uRESTDWMessageCoder;

Procedure TRESTDWMessagePart.Assign(Source: TPersistent);
Var
 mp : TRESTDWMessagePart;
Begin
 If Source Is TRESTDWMessagePart Then
  Begin
   mp := TRESTDWMessagePart(Source);
   Headers.Assign(mp.Headers);
   ExtraHeaders.Assign(mp.ExtraHeaders);
   CharSet := mp.CharSet;
   FileName := mp.FileName;
   Name := mp.Name;
  End
 Else
  Inherited Assign(Source);
End;

Constructor TRESTDWMessagePart.Create(aCollection: TCollection);
Begin
 Inherited;
 If ClassType = TRESTDWMessagePart Then
  Raise eRESTDWCanNotCreateMessagePart.Create(cMessagePartCreate);
 FIsEncoded    := False;
 FHeaders      := TRESTDWHeaderList.Create(QuoteRFC822);
 FExtraHeaders := TRESTDWHeaderList.Create(QuoteRFC822);
 FParentPart   := -1;
End;

Destructor TRESTDWMessagePart.Destroy;
Begin
 FHeaders.Free;
 FExtraHeaders.Free;
 Inherited Destroy;
End;

Function TRESTDWMessagePart.GetContentDisposition : String;
Begin
 Result := Headers.Values['Content-Disposition'];
End;

Function TRESTDWMessagePart.GetContentID : String;
Begin
 Result := Headers.Values['Content-ID'];
End;

Function TRESTDWMessagePart.GetContentDescription : String;
Begin
 Result := Headers.Values['Content-Description'];
End;

Function TRESTDWMessagePart.GetContentLocation    : String;
Begin
 Result := Headers.Values['Content-Location'];
End;

Function TRESTDWMessagePart.GetContentTransfer    : String;
Begin
 Result := Headers.Values['Content-Transfer-Encoding'];
End;

Function TRESTDWMessagePart.GetCharSet(AHeader : String) : String;
Begin
 Result := ExtractHeaderSubItem(AHeader, 'charset', QuoteMIME);
End;

Function TRESTDWMessagePart.ResolveContentType(AContentType : String) : String;
Var
 LMsg   : TRESTDWMessage;
 LParts : TRESTDWMessageParts;
Begin
 If AContentType <> '' Then
  Result := AContentType
 Else
  Begin
   LParts := MessageParts;
   If Assigned(LParts) Then
    Begin
     LMsg := TRESTDWMessage(LParts.OwnerMessage);
     If Assigned(LMsg) And
        (LMsg.Encoding = meMIME) Then
      Begin
       //There is an exception if we are a child of multipart/digest...
       If ParentPart <> -1 Then
        Begin
         AContentType := LParts.Items[ParentPart].Headers.Values['Content-Type'];  {do not localize}
         If IsHeaderMediaType(AContentType, 'multipart/digest') Then
          Begin  {do not localize}
           Result := 'message/rfc822';  {do not localize}
           Exit;
          End;
        End;
       Result := 'text/plain';      {do not localize}
       Exit;
      End;
    End;
   Result := '';  //Default for non-MIME messages
  End;
End;

Function TRESTDWMessagePart.GetContentType : String;
Begin
 Result := Headers.Values['Content-Type']; {do not localize}
End;

Function TRESTDWMessagePart.GetMessageParts: TRESTDWMessageParts;
Begin
 If Collection Is TRESTDWMessageParts Then
  Result := TRESTDWMessageParts(Collection)
 Else
  Result := nil;
End;

Function TRESTDWMessagePart.GetOwnerMessage: TPersistent;
Var
 LParts : TRESTDWMessageParts;
Begin
 LParts := MessageParts;
 If Assigned(LParts) Then
  Result := LParts.OwnerMessage
 Else
  Result := nil;
End;

Class Function TRESTDWMessagePart.PartType : TRESTDWMessagePartType;
Begin
 Result := mptAttachment;
End;

Procedure TRESTDWMessagePart.SetContentID(const Value: string);
Begin
 Headers.Values['Content-ID'] := Value; {do not localize}
End;

Procedure TRESTDWMessagePart.SetContentDescription(Const Value : string);
Begin
 Headers.Values['Content-Description'] := Value; {do not localize}
End;

Procedure TRESTDWMessagePart.SetContentDisposition(Const Value : String);
Var
 LFileName : String;
Begin
 Headers.Values['Content-Disposition'] := RemoveHeaderEntry(Value, 'filename', LFileName, QuoteMIME); {do not localize}
 If LFileName <> '' Then
  LFileName := DecodeHeader(LFileName);
 If LFileName <> '' Then
  FFileName := LFileName;
End;

Procedure TRESTDWMessagePart.SetContentLocation(const Value: string);
Begin
 Headers.Values['Content-Location'] := Value; {do not localize}
End;

procedure TRESTDWMessagePart.SetContentTransfer(const Value: string);
begin
  Headers.Values['Content-Transfer-Encoding'] := Value; {do not localize}
end;

Procedure TRESTDWMessagePart.SetContentType(const Value: string);
Var
 LTmp,
 LCharSet,
 LName     : String;
Begin
 LTmp := RemoveHeaderEntry(Value, 'charset', LCharSet, QuoteMIME);{do not localize}
 LTmp := RemoveHeaderEntry(LTmp, 'name', LName, QuoteMIME);{do not localize}
 Headers.Values['Content-Type'] := LTmp;
 If LCharSet <> '' Then
  FCharSet := LCharSet;
 If LName <> '' Then
  FName := LName;
End;

Procedure TRESTDWMessagePart.SetExtraHeaders(const Value: TRESTDWHeaderList);
Begin
 FExtraHeaders.Assign(Value);
End;

Function TRESTDWMessageParts.Add: TRESTDWMessagePart;
Begin
 Result := nil;
End;

Procedure TRESTDWMessageParts.CountParts;
Var
 i : integer;
Begin
 FAttachmentCount := 0;
 FRelatedPartCount := 0;
 FTextPartCount := 0;
 For i := 0 To Count - 1 Do
  Begin
   If Length(TRESTDWMessagePart(Items[i]).ContentID) > 0 Then
    Inc(FRelatedPartCount);
   Case TRESTDWMessagePart(Items[i]).PartType Of
    mptText       : Inc(FTextPartCount);
    mptAttachment : Inc(FAttachmentCount);
   End;
  End;
End;

Constructor TRESTDWMessageParts.Create(AOwner: TPersistent);
Begin
 Inherited Create(AOwner, TRESTDWMessagePart);
 AttachmentEncoding := 'MIME'; {do not localize}
End;

Function TRESTDWMessageParts.GetItem(Index : Integer) : TRESTDWMessagePart;
Begin
 Result := TRESTDWMessagePart(Inherited GetItem(Index));
End;

Function TRESTDWMessageParts.GetOwnerMessage : TPersistent;
Var
 LOwner : TPersistent;
Begin
 LOwner := Inherited GetOwner;
 If LOwner Is TRESTDWMessage Then
  Result := LOwner
 Else
  Result := nil;
End;

Procedure TRESTDWMessageParts.SetAttachmentEncoding(const AValue: string);
Begin
 FMessageEncoderInfo := TRESTDWMessageEncoderList.ByName(AValue);
 FAttachmentEncoding := AValue;
End;

Procedure TRESTDWMessageParts.SetItem(Index: Integer; const Value: TRESTDWMessagePart);
Begin
 Inherited SetItem(Index, Value);
End;

End.
