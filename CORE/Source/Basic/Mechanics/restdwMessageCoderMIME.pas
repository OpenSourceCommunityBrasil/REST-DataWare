Unit restdwMessageCoderMIME;

Interface

Uses
 Classes,
 IdBaseComponent,
 IdMessageCoder,
 IdMessage,
 IdGlobal;

 Type
  TRESTDWMessageDecoderMIME = class(TRESTDWMessageDecoder)
  Protected
   FFirstLine,
   FMIMEBoundary      : String;
   FProcessFirstLine,
   FBodyEncoded       : Boolean;
   Function  GetProperHeaderItem(Const Line : String) : String;
   Procedure InitComponent; override;
  Public
   Constructor Create         (AOwner      : TComponent;
                               Const ALine : String); Reintroduce; Overload;
   Function    ReadBody       (ADestStream : TStream;
                               Var VMsgEnd: Boolean) : TRESTDWMessageDecoder; Override;
   Procedure   CheckAndSetType(Const AContentType,
                               AContentDisposition : String);
   Procedure ReadHeader; Override;
   Function GetAttachmentFilename         (Const AContentType,
                                           AContentDisposition : String) : String;
   Function RemoveInvalidCharsFromFilename(Const AFilename     : String): string;
   Property MIMEBoundary : String  Read FMIMEBoundary Write FMIMEBoundary;
   Property BodyEncoded  : Boolean Read FBodyEncoded  Write FBodyEncoded;
 End;

  TRESTDWMessageDecoderInfoMIME = class(TRESTDWMessageDecoderInfo)
  public
    function CheckForStart(ASender: TRESTDWMessage; const ALine: string): TRESTDWMessageDecoder; override;
  end;

  TRESTDWMessageEncoderMIME = class(TRESTDWMessageEncoder)
  public
    procedure Encode(ASrc: TStream; ADest: TStream); override;
  end;

  TRESTDWMessageEncoderInfoMIME = class(TRESTDWMessageEncoderInfo)
  public
    constructor Create; override;
    procedure InitializeHeaders(AMsg: TRESTDWMessage); override;
  end;

  TRESTDWMIMEBoundaryStrings = class
  public
    class function GenerateRandomChar: Char;
    class function GenerateBoundary: String;
  end;

implementation

uses
  IdCoder, IdCoderMIME, IdException, IdGlobalProtocols, IdResourceStrings,
  IdCoderQuotedPrintable, IdCoderBinHex4, IdCoderHeader, SysUtils;

type
  {
  RLebeau: TRESTDWMessageDecoderMIMEIgnore is a private class used when
  TRESTDWMessageDecoderInfoMIME.CheckForStart() detects an ending MIME boundary
  for a finished message part that has nested parts in it.  This is a dirty
  hack to allow TRESTDWMessageClient to skip the boundary line properly, or else
  the line ends up as spare data in the TRESTDWMessage.Body property, which is
  not desired.  A better solution to signal TRESTDWMessageClient to ignore the
  line needs to be found later.
  }

  TRESTDWMessageDecoderMIMEIgnore = class(TRESTDWMessageDecoder)
  public
    function ReadBody(ADestStream: TStream; var VMsgEnd: Boolean): TRESTDWMessageDecoder; override;
    procedure ReadHeader; override;
  end;

function TRESTDWMessageDecoderMIMEIgnore.ReadBody(ADestStream: TStream; var VMsgEnd: Boolean): TRESTDWMessageDecoder;
begin
  VMsgEnd := False;
  Result := nil;
end;

procedure TRESTDWMessageDecoderMIMEIgnore.ReadHeader;
begin
  FPartType := mcptIgnore;
end;

{ TRESTDWMIMEBoundaryStrings }

class function TRESTDWMIMEBoundaryStrings.GenerateRandomChar: Char;
var
  LOrd: integer;
  LFloat: Double;
begin
  if RandSeed = 0 then begin
    Randomize;
  end;
  {Allow only digits (ASCII 48-57), upper-case letters (65-90) and lowercase
  letters (97-122), which is 62 possible chars...}
  LFloat := (Random * 61) + 1.5;  //Gives us 1.5 to 62.5
  LOrd := Trunc(LFloat) + 47;  //(1..62) -> (48..109)
  if LOrd > 83 then begin
    LOrd := LOrd + 13;  {Move into lowercase letter range}
  end else if LOrd > 57 then begin
    Inc(LOrd, 7);  {Move into upper-case letter range}
  end;
  Result := Chr(LOrd);
end;

{This generates a random MIME boundary.}
class function TRESTDWMIMEBoundaryStrings.GenerateBoundary: String;
const
  {Generate a string 34 characters long (34 is a whim, not a requirement)...}
  BoundaryLength = 34;
var
  LN: Integer;
  LFloat: Double;
  {$IFDEF STRING_IS_IMMUTABLE}
  LSB: TRESTDWStringBuilder;
  {$ENDIF}
begin
  {$IFDEF STRING_IS_IMMUTABLE}
  LSB := TRESTDWStringBuilder.Create(BoundaryLength);
  {$ELSE}
  Result := StringOfChar(' ', BoundaryLength);
  {$ENDIF}
  for LN := 1 to BoundaryLength do begin
    {$IFDEF STRING_IS_IMMUTABLE}
    LSB.Append(GenerateRandomChar);
    {$ELSE}
    Result[LN] := GenerateRandomChar;
    {$ENDIF}
  end;
  {CC2: RFC 2045 recommends including "=_" in the boundary, insert in random location...}
  LFloat := (Random * (BoundaryLength-2)) + 1.5;  //Gives us 1.5 to Length-0.5
  LN := Trunc(LFloat);  // 1 to Length-1 (we are inserting a 2-char string)
  {$IFDEF STRING_IS_IMMUTABLE}
  LSB[LN-1] := '=';
  LSB[LN] := '_';
  Result := LSB.ToString;
  {$ELSE}
  Result[LN] := '=';
  Result[LN+1] := '_';
  {$ENDIF}
end;

{ TRESTDWMessageDecoderInfoMIME }

function TRESTDWMessageDecoderInfoMIME.CheckForStart(ASender: TRESTDWMessage;
 const ALine: string): TRESTDWMessageDecoder;
begin
  Result := nil;
  if ASender.MIMEBoundary.Boundary <> '' then begin
    if TextIsSame(ALine, '--' + ASender.MIMEBoundary.Boundary) then begin    {Do not Localize}
      Result := TRESTDWMessageDecoderMIME.Create(ASender);
    end
    else if TextIsSame(ALine, '--' + ASender.MIMEBoundary.Boundary + '--') then begin    {Do not Localize}
      ASender.MIMEBoundary.Pop;
      Result := TRESTDWMessageDecoderMIMEIgnore.Create(ASender);
    end;
  end;
  if (Result = nil) and (ASender.ContentTransferEncoding <> '') then begin
    if IsHeaderMediaType(ASender.ContentType, 'multipart') and {do not localize}
       (PosInStrArray(ASender.ContentTransferEncoding, ['7bit', '8bit', 'binary'], False) = -1) then {do not localize}
    begin
      Exit;
    end;
    if (PosInStrArray(ASender.ContentTransferEncoding, ['base64', 'quoted-printable'], False) <> -1) then begin {Do not localize}
      Result := TRESTDWMessageDecoderMIME.Create(ASender, ALine);
    end;
  end;
end;

{ TRESTDWMessageDecoderMIME }

constructor TRESTDWMessageDecoderMIME.Create(AOwner: TComponent; const ALine: string);
begin
  inherited Create(AOwner);
  FFirstLine := ALine;
  FProcessFirstLine := True;
end;

function TRESTDWMessageDecoderMIME.ReadBody(ADestStream: TStream; var VMsgEnd: Boolean): TRESTDWMessageDecoder;
var
  LContentType, LContentTransferEncoding: string;
  LDecoder: TRESTDWDecoder;
  LLine: string;
  LBinaryLineBreak: string;
  LBuffer: string;  //Needed for binhex4 because cannot decode line-by-line.
  LIsThisTheFirstLine: Boolean; //Needed for binary encoding
  LBoundaryStart, LBoundaryEnd: string;
  LIsBinaryContentTransferEncoding: Boolean;
  LEncoding: IIdTextEncoding;
begin
  LIsThisTheFirstLine := True;
  VMsgEnd := False;
  Result := nil;
  if FBodyEncoded then begin
    LContentType := TRESTDWMessage(Owner).ContentType;
    LContentTransferEncoding := TRESTDWMessage(Owner).ContentTransferEncoding;
  end else begin
    LContentType := FHeaders.Values['Content-Type']; {Do not Localize}
    LContentTransferEncoding := FHeaders.Values['Content-Transfer-Encoding']; {Do not Localize}
  end;
  if LContentTransferEncoding = '' then begin
    // RLebeau 04/08/2014: According to RFC 2045 Section 6.1:
    // "Content-Transfer-Encoding: 7BIT" is assumed if the
    // Content-Transfer-Encoding header field is not present."
    if IsHeaderMediaType(LContentType, 'application/mac-binhex40') then begin  {Do not Localize}
      LContentTransferEncoding := 'binhex40'; {do not localize}
    end
    else if not IsHeaderMediaType(LContentType, 'application/octet-stream') then begin  {Do not Localize}
      LContentTransferEncoding := '7bit'; {do not localize}
    end;
  end
  else if IsHeaderMediaType(LContentType, 'multipart') then {do not localize}
  begin
    // RLebeau 08/17/09 - According to RFC 2045 Section 6.4:
    // "If an entity is of type "multipart" the Content-Transfer-Encoding is not
    // permitted to have any value other than "7bit", "8bit" or "binary"."
    //
    // However, came across one message where the "Content-Type" was set to
    // "multipart/related" and the "Content-Transfer-Encoding" was set to
    // "quoted-printable".  Outlook and Thunderbird were apparently able to parse
    // the message correctly, but Indy was not.  So let's check for that scenario
    // and ignore illegal "Content-Transfer-Encoding" values if present...
    if PosInStrArray(LContentTransferEncoding, ['7bit', '8bit', 'binary'], False) = -1 then begin {do not localize}
      LContentTransferEncoding := '';
    end;
  end;

  if TextIsSame(LContentTransferEncoding, 'base64') then begin {Do not Localize}
    LDecoder := TRESTDWDecoderMIMELineByLine.Create(nil);
  end else if TextIsSame(LContentTransferEncoding, 'quoted-printable') then begin {Do not Localize}
    LDecoder := TRESTDWDecoderQuotedPrintable.Create(nil);
  end else if TextIsSame(LContentTransferEncoding, 'binhex40') then begin {Do not Localize}
    LDecoder := TRESTDWDecoderBinHex4.Create(nil);
  end else begin
    LDecoder := nil;
  end;

  try
    if LDecoder <> nil then begin
      LDecoder.DecodeBegin(ADestStream);
    end;

    if MIMEBoundary <> '' then begin
      LBoundaryStart := '--' + MIMEBoundary; {Do not Localize}
      LBoundaryEnd := LBoundaryStart + '--'; {Do not Localize}
    end;

    if LContentTransferEncoding <> '' then begin
      case PosInStrArray(LContentTransferEncoding, ['7bit', 'quoted-printable', 'base64', '8bit', 'binary'], False) of {do not localize}
        0..2: LIsBinaryContentTransferEncoding := False;
        3..4: LIsBinaryContentTransferEncoding := True;
      else
        // According to RFC 2045 Section 6.4:
        // "Any entity with an unrecognized Content-Transfer-Encoding must be
        // treated as if it has a Content-Type of "application/octet-stream",
        // regardless of what the Content-Type header field actually says."
        LIsBinaryContentTransferEncoding := True;
        LContentTransferEncoding := '';
      end;
    end else begin
      LIsBinaryContentTransferEncoding := True;
    end;

    repeat
      if not FProcessFirstLine then begin
        EnsureEncoding(LEncoding, enc8Bit);
        if LIsBinaryContentTransferEncoding then begin
          // For binary, need EOL because the default LF causes spurious CRs in the output...
                                                                                           
          // buffer instead, looking for the next MIME boundary and message terminator while
          // flushing the buffer to the destination stream along the way.  Otherwise, at the
          // very least, we need to detect the type of line break used (CRLF vs bare-LF) so
          // we can duplicate it correctly in the output.  Most systems use CRLF, per the RFCs,
          // but have seen systems use bare-LF instead...
          LLine := ReadLnRFC(VMsgEnd, EOL, '.', LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF}); {do not localize}
          LBinaryLineBreak := EOL;                                           
        end else begin
          LLine := ReadLnRFC(VMsgEnd, LF, '.', LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF}); {do not localize}
        end;
      end else begin
        LLine := FFirstLine;
        FFirstLine := '';    {Do not Localize}
        FProcessFirstLine := False;
        // Do not use ADELIM since always ends with . (standard)
        if LLine = '.' then begin {Do not Localize}
          VMsgEnd := True;
          Break;
        end;
        if TextStartsWith(LLine, '..') then begin
          Delete(LLine, 1, 1);
        end;
      end;
      if VMsgEnd then begin
        Break;
      end;
      // New boundary - end self and create new coder
      if MIMEBoundary <> '' then begin
        if TextIsSame(LLine, LBoundaryStart) then begin
          Result := TRESTDWMessageDecoderMIME.Create(Owner);
          Break;
          // End of all coders (not quite ALL coders)
        end;
        if TextIsSame(LLine, LBoundaryEnd) then begin
          // POP the boundary
          if Owner is TRESTDWMessage then begin
            TRESTDWMessage(Owner).MIMEBoundary.Pop;
          end;
          Break;
        end;
      end;
      if LDecoder = nil then begin
        // Data to save, but not decode
        if Assigned(ADestStream) then begin
          EnsureEncoding(LEncoding, enc8Bit);
        end;
        if LIsBinaryContentTransferEncoding then begin {do not localize}
          //In this case, we have to make sure we dont write out an EOL at the
          //end of the file.
          if LIsThisTheFirstLine then begin
            LIsThisTheFirstLine := False;
          end else begin
            if Assigned(ADestStream) then begin
              WriteStringToStream(ADestStream, LBinaryLineBreak, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
            end;
          end;
          if Assigned(ADestStream) then begin
            WriteStringToStream(ADestStream, LLine, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
          end;
        end else begin
          if Assigned(ADestStream) then begin
            WriteStringToStream(ADestStream, LLine + EOL, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
          end;
        end;
      end
      else begin
        // Data to decode
        if LDecoder is TRESTDWDecoderQuotedPrintable then begin
          // For TRESTDWDecoderQuotedPrintable, we have to make sure all EOLs are intact
          LDecoder.Decode(LLine + EOL);
        end else if LDecoder is TRESTDWDecoderBinHex4 then begin
          // We cannot decode line-by-line because lines don't have a whole
          // number of 4-byte blocks due to the : inserted at the start of
          // the first line, so buffer the file...
                                                                          
          // in it, otherwise we are buffering the entire file in memory
          // before decoding it...
          LBuffer := LBuffer + LLine;
        end else if LLine <> '' then begin
          LDecoder.Decode(LLine);
        end;
      end;
    until False;
    if LDecoder <> nil then begin
      if LDecoder is TRESTDWDecoderBinHex4 then begin
        //Now decode the complete block...
        LDecoder.Decode(LBuffer);
      end;
      LDecoder.DecodeEnd;
    end;
  finally
    FreeAndNil(LDecoder);
  end;
end;

function TRESTDWMessageDecoderMIME.GetAttachmentFilename(const AContentType, AContentDisposition: string): string;
var
  LValue: string;
begin
  LValue := ExtractHeaderSubItem(AContentDisposition, 'filename', QuoteMIME); {do not localize}
  if LValue = '' then begin
    // Get filename from Content-Type
    LValue := ExtractHeaderSubItem(AContentType, 'name', QuoteMIME); {do not localize}
  end;
  if Length(LValue) > 0 then begin
    Result := RemoveInvalidCharsFromFilename(DecodeHeader(LValue));
  end else begin
    Result := '';
  end;
end;

procedure TRESTDWMessageDecoderMIME.CheckAndSetType(const AContentType, AContentDisposition: string);
begin
  {The new world order: Indy now defines a TRESTDWAttachment as a part that either has
  a filename, or else does NOT have a ContentType starting with text/ or multipart/.
  Anything left is a TRESTDWText.}

  {RLebeau 3/28/2006: RFC 2183 states that inlined text can have
  filenames as well, so do NOT treat inlined text as attachments!}

  //WARNING: Attachments may not necessarily have filenames, and Text parts may have filenames!
  FFileName := GetAttachmentFilename(AContentType, AContentDisposition);

  {see what type the part is...}
  if IsHeaderMediaTypes(AContentType, ['text', 'multipart']) and {do not localize}
    (not IsHeaderValue(AContentDisposition, 'attachment')) then {do not localize}
  begin
                                               
    // "Any entity with an unrecognized Content-Transfer-Encoding must be
    // treated as if it has a Content-Type of "application/octet-stream",
    // regardless of what the Content-Type header field actually says."
    FPartType := mcptText;
  end else begin
    FPartType := mcptAttachment;
  end;
end;

function TRESTDWMessageDecoderMIME.GetProperHeaderItem(const Line: string): string;
var
  LPos, Idx, LLen: Integer;
begin
  LPos := Pos(':', Line);
  if LPos = 0 then begin // the header line is invalid
    Result := Line;
    Exit;
  end;

  Idx := LPos - 1;
  while (Idx > 0) and (Line[Idx] = ' ') do begin
    Dec(Idx);
  end;

  LLen := Length(Line);
  Inc(LPos);
  while (LPos <= LLen) and (Line[LPos] = ' ') do begin
    Inc(LPos);
  end;

  Result := Copy(Line, 1, Idx) + '=' + Copy(Line, LPos, MaxInt);
end;

procedure TRESTDWMessageDecoderMIME.ReadHeader;
var
  ABoundary,
  s: string;
  LLine: string;
  LMsgEnd: Boolean;

begin
  if FBodyEncoded then begin // Read header from the actual message since body parts don't exist    {Do not Localize}
    CheckAndSetType(TRESTDWMessage(Owner).ContentType, TRESTDWMessage(Owner).ContentDisposition);
  end else begin
    // Read header
    repeat
      LLine := ReadLnRFC(LMsgEnd);
      if LMsgEnd then begin                                                            
        FPartType := mcptEOF;
        Exit;
      end;//if
      if LLine = '' then begin
        Break;
      end;
      if CharIsInSet(LLine, 1, LWS) then begin
        if FHeaders.Count > 0 then begin
          FHeaders[FHeaders.Count - 1] := FHeaders[FHeaders.Count - 1] + ' ' + TrimLeft(LLine);    {Do not Localize}
        end else begin
          //Make sure you change 'Content-Type :' to 'Content-Type:'
          FHeaders.Add(GetProperHeaderItem(TrimLeft(LLine))); {Do not Localize}
        end;
      end else begin
        //Make sure you change 'Content-Type :' to 'Content-Type:'
        FHeaders.Add(GetProperHeaderItem(LLine));    {Do not Localize}
      end;
    until False;
    s := FHeaders.Values['Content-Type'];    {do not localize}
    //CC: Need to detect on "multipart" rather than boundary, because only the
    //"multipart" bit will be visible later...
    if IsHeaderMediaType(s, 'multipart') then begin  {do not localize}
      ABoundary := ExtractHeaderSubItem(s, 'boundary', QuoteMIME);  {do not localize}
      if Owner is TRESTDWMessage then begin
        if Length(ABoundary) > 0 then begin
          TRESTDWMessage(Owner).MIMEBoundary.Push(ABoundary, TRESTDWMessage(Owner).MessageParts.Count);
          // Also update current boundary
          FMIMEBoundary := ABoundary;
        end else begin
          //CC: We are in trouble.  A multipart MIME Content-Type with no boundary?
          //Try pushing the current boundary...
          TRESTDWMessage(Owner).MIMEBoundary.Push(FMIMEBoundary, TRESTDWMessage(Owner).MessageParts.Count);
        end;
      end;
    end;
    CheckAndSetType(FHeaders.Values['Content-Type'],    {do not localize}
      FHeaders.Values['Content-Disposition']);    {do not localize}
  end;
end;

function TRESTDWMessageDecoderMIME.RemoveInvalidCharsFromFilename(const AFilename: string): string;
const
  // MtW: Inversed: see http://support.microsoft.com/default.aspx?scid=kb;en-us;207188
  InvalidWindowsFilenameChars = '\/:*?"<>|'; {do not localize}
var
  LN: integer;
  {$IFDEF STRING_IS_IMMUTABLE}
  LSB: TRESTDWStringBuilder;
  {$ENDIF}
begin
  Result := AFilename;
  //First, strip any Windows or Unix path...
  for LN := Length(Result) downto 1 do begin
    if ((Result[LN] = '/') or (Result[LN] = '\')) then begin  {do not localize}
      Result := Copy(Result, LN+1, MaxInt);
      Break;
    end;
  end;
  //Now remove any invalid filename chars.
  //Hmm - this code will be less buggy if I just replace them with _
  {$IFDEF STRING_IS_IMMUTABLE}
  LSB := TRESTDWStringBuilder.Create(Result);
  for LN := 0 to LSB.Length-1 do begin
    // MtW: WAS: if Pos(Result[LN], ValidWindowsFilenameChars) = 0 then begin
    if Pos(LSB[LN], InvalidWindowsFilenameChars) > 0 then begin
      LSB[LN] := '_';    {do not localize}
    end;
  end;
  {$ELSE}
  for LN := 1 to Length(Result) do begin
    // MtW: WAS: if Pos(Result[LN], ValidWindowsFilenameChars) = 0 then begin
    if Pos(Result[LN], InvalidWindowsFilenameChars) > 0 then begin
      Result[LN] := '_';    {do not localize}
    end;
  end;
  {$ENDIF}
end;

{ TRESTDWMessageEncoderInfoMIME }

constructor TRESTDWMessageEncoderInfoMIME.Create;
begin
  inherited;
  FMessageEncoderClass := TRESTDWMessageEncoderMIME;
end;

procedure TRESTDWMessageEncoderInfoMIME.InitializeHeaders(AMsg: TRESTDWMessage);
begin
  {CC2: The following logic does not work - it assumes that just because there
  are related parts, that the message header is multipart/related, whereas it
  could be multipart/related inside multipart/alternative, plus there are other
  issues.
  But...it works on simple emails, and it is better than throwing an exception.
  User must specify the ContentType to get the right results.}
  {CC4: removed addition of boundaries; now added at GenerateHeader stage (could
  end up with boundary added more than once)}
  if AMsg.ContentType = '' then begin
    if AMsg.MessageParts.RelatedPartCount > 0 then begin
      AMsg.ContentType := 'multipart/related; type="multipart/alternative"';  //; boundary="' + {do not localize}
    end else begin
      if AMsg.MessageParts.AttachmentCount > 0 then begin
        AMsg.ContentType := 'multipart/mixed'; //; boundary="' {do not localize}
      end else begin
        if AMsg.MessageParts.TextPartCount > 0 then begin
          AMsg.ContentType := 'multipart/alternative';  //; boundary="' {do not localize}
        end;
      end;
    end;
  end;
end;

{ TRESTDWMessageEncoderMIME }

procedure TRESTDWMessageEncoderMIME.Encode(ASrc: TStream; ADest: TStream);
var
  s: string;
  LEncoder: TRESTDWEncoderMIME;
  LSPos, LSSize : TRESTDWStreamSize;
begin
  ASrc.Position := 0;
  LSPos := 0;
  LSSize := ASrc.Size;
  LEncoder := TRESTDWEncoderMIME.Create(nil);
  try
    while LSPos < LSSize do begin
      s := LEncoder.Encode(ASrc, 57) + EOL;
      Inc(LSPos, 57);
      WriteStringToStream(ADest, s);
    end;
  finally
    FreeAndNil(LEncoder);
  end;
end;

procedure TRESTDWMessageDecoderMIME.InitComponent;
begin
  inherited InitComponent;
  FBodyEncoded := False;
  if Owner is TRESTDWMessage then begin
    FMIMEBoundary := TRESTDWMessage(Owner).MIMEBoundary.Boundary;
    {CC2: Check to see if this is an email of the type that is headers followed
    by the body encoded in base64 or quoted-printable.  The problem with this type
    is that the header may state it as MIME, but the MIME parts and their headers
    will be encoded, so we won't find them - in this case, we will later take
    all the info we need from the message header, and not try to take it from
    the part header.}
    if TRESTDWMessage(Owner).ContentTransferEncoding <> '' then begin
      // RLebeau 12/26/2014 - According to RFC 2045 Section 6.4:
      // "If an entity is of type "multipart" the Content-Transfer-Encoding is not
      // permitted to have any value other than "7bit", "8bit" or "binary"."
      //
      // However, came across one message where the "Content-Type" was set to
      // "multipart/related" and the "Content-Transfer-Encoding" was set to
      // "quoted-printable".  Outlook and Thunderbird were apparently able to parse
      // the message correctly, but Indy was not.  So let's check for that scenario
      // and ignore illegal "Content-Transfer-Encoding" values if present...
      if (not IsHeaderMediaType(TRESTDWMessage(Owner).ContentType, 'multipart')) and
        {CC2: added 8bit below, changed to TextIsSame.  Reason is that many emails
        set the Content-Transfer-Encoding to 8bit, have multiple parts, and display
        the part header in plain-text.}
         (PosInStrArray(TRESTDWMessage(Owner).ContentTransferEncoding, ['8bit', '7bit', 'binary'], False) = -1)    {do not localize}
      then begin
        FBodyEncoded := True;
      end;
    end;
  end;
end;

initialization
  TRESTDWMessageDecoderList.RegisterDecoder('MIME'    {Do not Localize}
   , TRESTDWMessageDecoderInfoMIME.Create);
  TRESTDWMessageEncoderList.RegisterEncoder('MIME'    {Do not Localize}
   , TRESTDWMessageEncoderInfoMIME.Create);
finalization

end.
