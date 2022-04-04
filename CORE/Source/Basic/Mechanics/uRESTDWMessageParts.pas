unit uRESTDWMessageParts;

Interface

Uses
 Classes, uRESTDWException, uRESTDWBasicTypes, uRESTDWHeaderList;

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
   Constructor Create(Collection : TCollection); Override;
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
 uRESTDWMessage;

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

Constructor TRESTDWMessagePart.Create(Collection: TCollection);
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
    //If it is MIME, then we need to find the correct default...
    LParts := MessageParts;
    if Assigned(LParts) then begin
      LMsg := TRESTDWMessage(LParts.OwnerMessage);
      if Assigned(LMsg) and (LMsg.Encoding = meMIME) then begin
        //There is an exception if we are a child of multipart/digest...
        if ParentPart <> -1 then begin
          AContentType := LParts.Items[ParentPart].Headers.Values['Content-Type'];  {do not localize}
          if IsHeaderMediaType(AContentType, 'multipart/digest') then begin  {do not localize}
            Result := 'message/rfc822';  {do not localize}
            Exit;
          end;
        end;
        //The default type...
        Result := 'text/plain';      {do not localize}
        Exit;
      end;
    end;
    Result := '';  //Default for non-MIME messages
  End;
End;

function TRESTDWMessagePart.GetContentType: string;
begin
  Result := Headers.Values['Content-Type']; {do not localize}
end;

function TRESTDWMessagePart.GetMessageParts: TRESTDWMessageParts;
begin
  if Collection is TRESTDWMessageParts then begin
    Result := TRESTDWMessageParts(Collection);
  end else begin
    Result := nil;
  end;
end;

function TRESTDWMessagePart.GetOwnerMessage: TPersistent;
var
  LParts: TRESTDWMessageParts;
begin
  LParts := MessageParts;
  if Assigned(LParts) then begin
    Result := LParts.OwnerMessage;
  end else begin
    Result := nil;
  end;
end;

class function TRESTDWMessagePart.PartType: TRESTDWMessagePartType;
begin
  Result := mptAttachment;
end;

procedure TRESTDWMessagePart.SetContentID(const Value: string);
begin
  Headers.Values['Content-ID'] := Value; {do not localize}
end;

procedure TRESTDWMessagePart.SetContentDescription(const Value: string);
begin
  Headers.Values['Content-Description'] := Value; {do not localize}
end;

procedure TRESTDWMessagePart.SetContentDisposition(const Value: string);
var
  LFileName: string;
begin
  Headers.Values['Content-Disposition'] := RemoveHeaderEntry(Value, 'filename', LFileName, QuoteMIME); {do not localize}
  {RLebeau: override the current value only if the header specifies a new one}
  if LFileName <> '' then begin
    LFileName := DecodeHeader(LFileName);
  end;
  if LFileName <> '' then begin
    FFileName := LFileName;
  end;
end;

procedure TRESTDWMessagePart.SetContentLocation(const Value: string);
begin
  Headers.Values['Content-Location'] := Value; {do not localize}
end;

procedure TRESTDWMessagePart.SetContentTransfer(const Value: string);
begin
  Headers.Values['Content-Transfer-Encoding'] := Value; {do not localize}
end;

procedure TRESTDWMessagePart.SetContentType(const Value: string);
var
  LTmp, LCharSet, LName: string;
begin
  LTmp := RemoveHeaderEntry(Value, 'charset', LCharSet, QuoteMIME);{do not localize}
  LTmp := RemoveHeaderEntry(LTmp, 'name', LName, QuoteMIME);{do not localize}
  Headers.Values['Content-Type'] := LTmp;
  {RLebeau: override the current values only if the header specifies new ones}
  if LCharSet <> '' then begin
    FCharSet := LCharSet;
  end;
  if LName <> '' then begin
    FName := LName;
  end;
end;

procedure TRESTDWMessagePart.SetExtraHeaders(const Value: TRESTDWHeaderList);
begin
  FExtraHeaders.Assign(Value);
end;

{ TMessageParts }

function TRESTDWMessageParts.Add: TRESTDWMessagePart;
begin
  // This helps prevent TRESTDWMessagePart from being added
  Result := nil;
end;

procedure TRESTDWMessageParts.CountParts;
                                                
var
  i: integer;
begin
  FAttachmentCount := 0;
  FRelatedPartCount := 0;
  FTextPartCount := 0;
  for i := 0 to Count - 1 do begin
    if Length(TRESTDWMessagePart(Items[i]).ContentID) > 0 then begin
      Inc(FRelatedPartCount);
    end;
    case TRESTDWMessagePart(Items[i]).PartType of
      mptText :
        begin
          Inc(FTextPartCount)
        end;
      mptAttachment:
        begin
         Inc(FAttachmentCount);
        end;
    end;
  end;
end;

constructor TRESTDWMessageParts.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TRESTDWMessagePart);
  // Must set prop and not variable so it will initialize it
  AttachmentEncoding := 'MIME'; {do not localize}
end;

function TRESTDWMessageParts.GetItem(Index: Integer): TRESTDWMessagePart;
begin
  Result := TRESTDWMessagePart(inherited GetItem(Index));
end;

function TRESTDWMessageParts.GetOwnerMessage: TPersistent;
var
  LOwner: TPersistent;
begin
  LOwner := inherited GetOwner;
  if LOwner is TRESTDWMessage then begin
    Result := LOwner;
  end else begin
    Result := nil;
  end;
end;

procedure TRESTDWMessageParts.SetAttachmentEncoding(const AValue: string);
begin
  FMessageEncoderInfo := TRESTDWMessageEncoderList.ByName(AValue);
  FAttachmentEncoding := AValue;
end;

procedure TRESTDWMessageParts.SetItem(Index: Integer; const Value: TRESTDWMessagePart);
begin
  inherited SetItem(Index, Value);
end;

end.
