unit uRESTDWMessageClient;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
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
  uRESTDWCoderMIME,
  uRESTDWHeaderList,
  uRESTDWBasicTypes,
  uRESTDWConsts,
  uRESTDWTools,
  uRESTDWIOHandlerStream,
  uRESTDWMessage;

 Type
  TRESTDWIOHandlerStreamMsg = Class(TRESTDWIOHandlerStream)
 Protected
  FMaxLineLength     : Integer;
  FTerminatorWasRead,
  FEscapeLines,
  FUnescapeLines     : Boolean;
  FLastByteRecv      : Byte;
  Function ReadDataFromSource(Var VBuffer : TRESTDWBytes): Integer;
 Public
  Constructor Create (AOwner         : TComponent;
                      AReceiveStream : TStream;
                      ASendStream    : TStream = Nil); Override;  //Should this be reintroduce instead of override?
  Procedure   WriteLn(Const AOut     : String); Override;
  Property    EscapeLines   : Boolean Read FEscapeLines   Write FEscapeLines;
  property    UnescapeLines : Boolean Read FUnescapeLines Write FUnescapeLines;
 Published
  Property MaxLineLength : Integer Read FMaxLineLength Write FMaxLineLength Default MaxInt;
 End;

  TRESTDWMessageClient = class(TRESTDWExplicitTLSClient)
  protected
    // The length of the folded line
    FMsgLineLength: integer;
    // The string to be pre-pended to the next line
    FMsgLineFold: string;

    procedure ReceiveBody(AMsg: TRESTDWMessage; const ADelim: string = '.'); virtual;    {do not localize}
    function  ReceiveHeader(AMsg: TRESTDWMessage; const AAltTerm: string = ''): string; virtual;
    procedure SendBody(AMsg: TRESTDWMessage); virtual;
    procedure SendHeader(AMsg: TRESTDWMessage); virtual;
    procedure EncodeAndWriteText(const ABody: TStrings; AEncoding: IIdTextEncoding);
    procedure WriteFoldedLine(const ALine : string);
    procedure InitComponent; override;
  public
    {$IFDEF WORKAROUND_INLINE_CONSTRUCTORS}
    constructor Create(AOwner: TComponent); reintroduce; overload;
    {$ENDIF}
    destructor Destroy; override;
    procedure ProcessMessage(AMsg: TRESTDWMessage; AHeaderOnly: Boolean = False); overload;
    procedure ProcessMessage(AMsg: TRESTDWMessage; AStream: TStream; AHeaderOnly: Boolean = False); overload;
    procedure ProcessMessage(AMsg: TRESTDWMessage; const AFilename: string; AHeaderOnly: Boolean = False); overload;
    procedure SendMsg(AMsg: TRESTDWMessage; AHeadersOnly: Boolean = False); overload; virtual;
    //
  //  property Capabilities;
    property MsgLineLength: integer read FMsgLineLength write FMsgLineLength;
    property MsgLineFold: string read FMsgLineFold write FMsgLineFold;
  end;

Implementation

Uses
 uRESTDWMessageCoderBinHex4,
 uRESTDWMessageCoderQuotedPrintable,
 uRESTDWMessageCoderMIME,
 uRESTDWMessageCoderUUE,
 uRESTDWMessageCoderXXE,
 uRESTDWCoder,
 uRESTDWCoder3to4,
 uRESTDWCoderBinHex4,
 uRESTDWCoderHeader,
 uRESTDWHeaderCoderBase,
 IdMessageCoder,
 uRESTDWException,
 uRESTDWTCPStream,
 uRESTDWAttachmentFile,
 uRESTDWAttachment,
 SysUtils;

Const
  SContentType = 'Content-Type'; {do not localize}
  SContentTransferEncoding = 'Content-Transfer-Encoding'; {do not localize}
  SThisIsMultiPartMessageInMIMEFormat = 'This is a multi-part message in MIME format'; {do not localize}

function GetLongestLine(var ALine : String; const ADelim : String) : String;
var
  i, fnd, delimLen : Integer;
begin
  Result := '';

  fnd := 0;
  delimLen := Length(ADelim);

  for i := 1 to Length(ALine) do
  begin
    if ALine[i] = ADelim[1] then
    begin
      if Copy(ALine, i, delimLen) = ADelim then
      begin
        fnd := i;
      end;
    end;
  end;

  if fnd > 0 then
  begin
    Result := Copy(ALine, 1, fnd - 1);
    ALine := Copy(ALine, fnd + delimLen, MaxInt);
  end;
end;

procedure RemoveLastBlankLine(Body: TStrings);
var
  Count: Integer;
begin
  if Assigned(Body) then begin
    { Remove the last blank line. The last blank line is added again in
      TRESTDWMessageClient.SendBody(). }
    Count := Body.Count;
    if (Count > 0) and (Body[Count - 1] = '') then begin
      Body.Delete(Count - 1);
    end;
  end;
end;

////////////////////////
// TRESTDWIOHandlerStreamMsg
////////////////////////

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

function TRESTDWIOHandlerStreamMsg.ReadDataFromSource(var VBuffer: TRESTDWBytes): Integer;
var
  LTerminator: String;
begin
  if not FTerminatorWasRead then
  begin
    Result := inherited ReadDataFromSource(VBuffer);
    if Result > 0 then begin
      FLastByteRecv := VBuffer[Result-1];
      Exit;
    end;
    // determine whether the stream ended with a line
    // break, adding an extra CR and/or LF if needed...
    if (FLastByteRecv = Ord(LF)) then begin
      // don't add an extra line break
      LTerminator := '.' + EOL;
    end else if (FLastByteRecv = Ord(CR)) then begin
      // add extra LF
      LTerminator := LF + '.' + EOL;
    end else begin
      // add extra CRLF
      LTerminator := EOL + '.' + EOL;
    end;
    FTerminatorWasRead := True;
    // in theory, CopyTRESTDWString() will write the string
    // into the byte array using 1-byte characters even
    // under DotNet where strings are usually Unicode
    // instead of ASCII...
    CopyTRESTDWString(LTerminator, VBuffer, 0);
    Result := Length(LTerminator);
  end else begin
    Result := 0;
  end;
end;

function TRESTDWIOHandlerStreamMsg.ReadLn(ATerminator: string;
  ATimeout: Integer = IdTimeoutDefault; AMaxLineLength: Integer = -1;
  AByteEncoding: IIdTextEncoding = nil
  {$IFDEF STRING_IS_ANSI}; ADestEncoding: IIdTextEncoding = nil{$ENDIF}
  ): string;
begin
  Result := inherited ReadLn(ATerminator, ATimeout, AMaxLineLength,
    AByteEncoding{$IFDEF STRING_IS_ANSI}, ADestEncoding{$ENDIF});
  if FEscapeLines and TextStartsWith(Result, '.') and (not FTerminatorWasRead) then begin {Do not Localize}
    Result := '.' + Result; {Do not Localize}
  end;
end;

procedure TRESTDWIOHandlerStreamMsg.WriteLn(Const AOut: String);
Var
 LOut : String;
Begin
 LOut := AOut;
 If FUnescapeLines And
    TextStartsWith(LOut, '..') Then
  RDWDelete(LOut, 1, 1);
 Inherited WriteLn(LOut);
end;

///////////////////
// TRESTDWMessageClient
///////////////////

{$IFDEF WORKAROUND_INLINE_CONSTRUCTORS}
constructor TRESTDWMessageClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;
{$ENDIF}

procedure TRESTDWMessageClient.InitComponent;
begin
  inherited InitComponent;
  FMsgLineLength := 79;
  FMsgLineFold := TAB;
end;

procedure TRESTDWMessageClient.WriteFoldedLine(const ALine : string);
var
  ins, s, line, spare : String;
  msgLen, insLen : Word;
begin
  s := ALine;

  // To give an amount of thread-safety
  ins := FMsgLineFold;
  insLen := Length(ins);
  msgLen := FMsgLineLength;

  // Do first line
  if length(s) > FMsgLineLength then
  begin
    spare := Copy(s, 1, msgLen);
    line := GetLongestLine(spare, ' ');    {do not localize}
    s := spare + Copy(s, msgLen + 1, length(s));
    IOHandler.WriteLn(line);

    // continue with the folded lines
    while length(s) > (msgLen - insLen) do
    begin
      spare := Copy(s, 1, (msgLen - insLen));
      line := GetLongestLine(spare, ' ');      {do not localize}
      s := ins + spare + Copy(s, (msgLen - insLen) + 1, length(s));
      IOHandler.WriteLn(line);
    end;

    // complete the output with what's left
    if Trim(s) <> '' then
    begin
      IOHandler.WriteLn(ins + s);
    end;
  end

  else begin
    IOHandler.WriteLn(s);
  end;
end;

procedure TRESTDWMessageClient.ReceiveBody(AMsg: TRESTDWMessage; const ADelim: string = '.');   {do not localize}
var
  LMsgEnd: Boolean;
  LActiveDecoder: TRESTDWMessageDecoder;
  LLine: string;
  LParentPart: integer;
  LPreviousParentPart: integer;
  LEncoding, LCharsetEncoding: IIdTextEncoding;
  LContentTransferEncoding: string;
  LUnknownContentTransferEncoding: Boolean;

                                                                          
  procedure CaptureAndDecodeCharset;
  var
    LMStream: TMemoryStream;
  begin
    LMStream := TMemoryStream.Create;
    try
      IOHandler.Capture(LMStream, ADelim, True, IndyTextEncoding_8Bit{$IFDEF STRING_IS_ANSI}, IndyTextEncoding_8Bit{$ENDIF});
      LMStream.Position := 0;
                                                                               
      // encoding, should this be doing the same? Otherwise, we could just use
      // AMsg.Body.LoadFromStream() instead...
      ReadStringsAsCharSet(LMStream, AMsg.Body, AMsg.CharSet{$IFDEF STRING_IS_ANSI}, CharsetToEncoding(AMsg.CharSet){$ENDIF});
    finally
      FreeAndNil(LMStream);
    end;
  end;

  // RLebeau 11/2/2013: TRESTDWMessage.Headers is a TRESTDWHeaderList, but
  // TRESTDWMessageDecoder.Headers is a plain TStringList.  Although TRESTDWHeaderList
  // is a TStrings descendant, but it reintroduces its own Values[] property
  // instead of implementing the TStrings.Values[] property, so we cannot
  // access TRESTDWMessage.Headers using a TStrings pointer or else the wrong
  // property will be invoked and we won't get the right value when accessing
  // TRESTDWMessage.Headers since TStrings and TRESTDWHeaderList use different
  // NameValueSeparator implementations, so we have to access them separately...
  function GetHeaderValue(const AName: string): string;
  begin
    if AMsg.IsMsgSinglePartMime then begin
      Result := AMsg.Headers.Values[AName];
    end else begin
      Result := LActiveDecoder.Headers.Values[AName];
    end;
  end;

  {Only set AUseBodyAsTarget to True if you want the input stream stored in TRESTDWMessage.Body
  instead of TRESTDWText.Body: this happens with some single-part messages.}
  procedure ProcessTextPart(var VDecoder: TRESTDWMessageDecoder; AUseBodyAsTarget: Boolean);
  var
    LMStream: TMemoryStream;
    i: integer;
    LTxt : TRESTDWText;
    LNewDecoder: TRESTDWMessageDecoder;
    {$IFDEF STRING_IS_ANSI}
    LAnsiEncoding: IIdTextEncoding;
    {$ENDIF}
  begin
    LMStream := TMemoryStream.Create;
    try
      LParentPart := AMsg.MIMEBoundary.ParentPart;
      LNewDecoder := VDecoder.ReadBody(LMStream, LMsgEnd);
      try
        LMStream.Position := 0;
        if AUseBodyAsTarget then begin
          if AMsg.IsMsgSinglePartMime then begin
            {$IFDEF STRING_IS_ANSI}
            LAnsiEncoding := CharsetToEncoding(AMsg.CharSet);
            {$ENDIF}
            ReadStringsAsCharSet(LMStream, AMsg.Body, AMsg.CharSet{$IFDEF STRING_IS_ANSI}, LAnsiEncoding{$ENDIF});
          end else begin
            {$IFDEF STRING_IS_ANSI}
            LAnsiEncoding := ContentTypeToEncoding(VDecoder.Headers.Values[SContentType], QuoteMIME);
            {$ENDIF}
            ReadStringsAsContentType(LMStream, AMsg.Body, VDecoder.Headers.Values[SContentType], QuoteMIME{$IFDEF STRING_IS_ANSI}, LAnsiEncoding{$ENDIF});
          end;
        end else begin
          LTxt := TRESTDWText.Create(AMsg.MessageParts);
          try
            {$IFDEF STRING_IS_ANSI}
            LAnsiEncoding := ContentTypeToEncoding(GetHeaderValue(SContentType), QuoteMIME);
            {$ENDIF}
            ReadStringsAsContentType(LMStream, LTxt.Body, GetHeaderValue(SContentType), QuoteMIME{$IFDEF STRING_IS_ANSI}, LAnsiEncoding{$ENDIF});
            RemoveLastBlankLine(LTxt.Body);
            LTxt.ContentType := LTxt.ResolveContentType(GetHeaderValue(SContentType));
            LTxt.CharSet := LTxt.GetCharSet(GetHeaderValue(SContentType));       {do not localize}
            LTxt.ContentTransfer := GetHeaderValue(SContentTransferEncoding);    {do not localize}
            LTxt.ContentID := GetHeaderValue('Content-ID');  {do not localize}
            LTxt.ContentLocation := GetHeaderValue('Content-Location');  {do not localize}
            LTxt.ContentDescription := GetHeaderValue('Content-Description');  {do not localize}
            LTxt.ContentDisposition := GetHeaderValue('Content-Disposition');  {do not localize}
            if not AMsg.IsMsgSinglePartMime then begin
              for i := 0 to VDecoder.Headers.Count-1 do begin
                if LTxt.Headers.IndexOfName(VDecoder.Headers.Names[i]) < 0 then begin
                  LTxt.ExtraHeaders.AddValue(
                    VDecoder.Headers.Names[i],
                    IndyValueFromIndex(VDecoder.Headers, i)
                  );
                end;
              end;
            end;
            LTxt.Filename := VDecoder.Filename;
            if IsHeaderMediaType(LTxt.ContentType, 'multipart') then begin {do not localize}
              LTxt.ParentPart := LPreviousParentPart;

              // RLebeau 08/17/09 - According to RFC 2045 Section 6.4:
              // "If an entity is of type "multipart" the Content-Transfer-Encoding is not
              // permitted to have any value other than "7bit", "8bit" or "binary"."
              //
              // However, came across one message where the "Content-Type" was set to
              // "multipart/related" and the "Content-Transfer-Encoding" was set to
              // "quoted-printable".  Outlook and Thunderbird were apparently able to parse
              // the message correctly, but Indy was not.  So let's check for that scenario
              // and ignore illegal "Content-Transfer-Encoding" values if present...

              if LTxt.ContentTransfer <> '' then begin
                if PosInStrArray(LTxt.ContentTransfer, ['7bit', '8bit', 'binary'], False) = -1 then begin {do not localize}
                  LTxt.ContentTransfer := '';
                end;
              end;
            end else begin
              LTxt.ParentPart := LParentPart;
            end;
          except
            LTxt.Free;
            raise;
          end;
        end;
      except
        LNewDecoder.Free;
        raise;
      end;
      VDecoder.Free;
      VDecoder := LNewDecoder;
    finally
      FreeAndNil(LMStream);
    end;
  end;

  procedure ProcessAttachment(var VDecoder: TRESTDWMessageDecoder);
  var
    LDestStream: TStream;
    i: integer;
    LAttachment: TRESTDWAttachment;
    LNewDecoder: TRESTDWMessageDecoder;
  begin
    LParentPart := AMsg.MIMEBoundary.ParentPart;
    AMsg.DoCreateAttachment(VDecoder.Headers, LAttachment);
    Assert(Assigned(LAttachment), 'Attachment must not be unassigned here!'); {Do not localize}
    try
      LNewDecoder := nil;
      try
        LDestStream := LAttachment.PrepareTempStream;
        try
          LNewDecoder := VDecoder.ReadBody(LDestStream, LMsgEnd);
        finally
          LAttachment.FinishTempStream;
        end;
        LAttachment.ContentType := LAttachment.ResolveContentType(GetHeaderValue(SContentType));
        LAttachment.CharSet := LAttachment.GetCharSet(GetHeaderValue(SContentType));
        if VDecoder is TRESTDWMessageDecoderUUE then begin
          LAttachment.ContentTransfer := TRESTDWMessageDecoderUUE(VDecoder).CodingType;  {do not localize}
        end else begin
          //Watch out for BinHex 4.0 encoding: no ContentTransfer is specified
          //in the header, but we need to set it to something meaningful for us...
          if IsHeaderMediaType(LAttachment.ContentType, 'application/mac-binhex40') then begin {do not localize}
            LAttachment.ContentTransfer := 'binhex40'; {do not localize}
          end else begin
            LAttachment.ContentTransfer := GetHeaderValue(SContentTransferEncoding);
          end;
        end;
        LAttachment.ContentDisposition := GetHeaderValue('Content-Disposition'); {do not localize}
        LAttachment.ContentID := GetHeaderValue('Content-ID');                   {do not localize}
        LAttachment.ContentLocation := GetHeaderValue('Content-Location');       {do not localize}
        LAttachment.ContentDescription := GetHeaderValue('Content-Description'); {do not localize}
        if not AMsg.IsMsgSinglePartMime then begin
          for i := 0 to VDecoder.Headers.Count-1 do begin
            if LAttachment.Headers.IndexOfName(VDecoder.Headers.Names[i]) < 0 then begin
              LAttachment.ExtraHeaders.AddValue(
                VDecoder.Headers.Names[i],
                IndyValueFromIndex(VDecoder.Headers, i)
              );
            end;
          end;
        end;
        LAttachment.Filename := VDecoder.Filename;
        if IsHeaderMediaType(LAttachment.ContentType, 'multipart') then begin  {do not localize}
          LAttachment.ParentPart := LPreviousParentPart;

          // RLebeau 08/17/09 - According to RFC 2045 Section 6.4:
          // "If an entity is of type "multipart" the Content-Transfer-Encoding is not
          // permitted to have any value other than "7bit", "8bit" or "binary"."
          //
          // However, came across one message where the "Content-Type" was set to
          // "multipart/related" and the "Content-Transfer-Encoding" was set to
          // "quoted-printable".  Outlook and Thunderbird were apparently able to parse
          // the message correctly, but Indy was not.  So let's check for that scenario
          // and ignore illegal "Content-Transfer-Encoding" values if present...

          if LAttachment.ContentTransfer <> '' then begin
            if PosInStrArray(LAttachment.ContentTransfer, ['7bit', '8bit', 'binary'], False) = -1 then begin {do not localize}
              LAttachment.ContentTransfer := '';
            end;
          end;
        end else begin
          LAttachment.ParentPart := LParentPart;
        end;
      except
        LNewDecoder.Free;
        raise;
      end;
      VDecoder.Free;
      VDecoder := LNewDecoder;
    except
      //This should also remove the Item from the TCollection.
      //Note that Delete does not exist in the TCollection.
      LAttachment.Free;
      raise;
    end;
  end;

begin
  LMsgEnd := False;

  // RLebeau 08/09/09 - TRESTDWNNTP.GetBody() calls TRESTDWMessage.Clear() before then
  // calling ReceiveBody(), thus the TRESTDWMessage.ContentTransferEncoding value
  // is not available for use below.  What is the best way to detect that so
  // the user could be allowed to set up the IOHandler.DefStringEncoding
  // beforehand?

  LUnknownContentTransferEncoding := False;

  if AMsg.NoDecode then begin
    LEncoding := IndyTextEncoding_8Bit;
  end else
  begin
    LContentTransferEncoding := AMsg.ContentTransferEncoding;
    if LContentTransferEncoding = '' then begin
      // RLebeau 04/08/2014: According to RFC 2045 Section 6.1:
      // "Content-Transfer-Encoding: 7BIT" is assumed if the
      // Content-Transfer-Encoding header field is not present."
      if IsHeaderMediaType(AMsg.ContentType, 'application/mac-binhex40') then begin  {Do not Localize}
        LContentTransferEncoding := 'binhex40'; {do not localize}
      end
      else if (AMsg.Encoding = meMIME) and (AMsg.MIMEBoundary.Count > 0) then begin
        LContentTransferEncoding := '7bit'; {do not localize}
      end;
    end
    else if IsHeaderMediaType(AMsg.ContentType, 'multipart') then {do not localize}
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
        //LUnknownContentTransferEncoding := True;
      end;
    end;

    if LContentTransferEncoding <> '' then begin
      case PosInStrArray(LContentTransferEncoding, ['7bit', 'quoted-printable', 'base64', '8bit', 'binary'], False) of {do not localize}
        0..2: LEncoding := IndyTextEncoding_ASCII;
        3..4: LEncoding := IndyTextEncoding_8Bit;
      else
        // According to RFC 2045 Section 6.4:
        // "Any entity with an unrecognized Content-Transfer-Encoding must be
        // treated as if it has a Content-Type of "application/octet-stream",
        // regardless of what the Content-Type header field actually says."
        LEncoding := IndyTextEncoding_8Bit;
        LContentTransferEncoding := '';
        LUnknownContentTransferEncoding := True;
      end;
    end else begin
      LEncoding := IndyTextEncoding_8Bit;
    end;
  end;

  BeginWork(wmRead);
  try
    if AMsg.NoDecode then begin
      CaptureAndDecodeCharset;
    end else begin
      LActiveDecoder := nil;
      try
        if ((not LUnknownContentTransferEncoding) and
         ((AMsg.Encoding = meMIME) and (AMsg.MIMEBoundary.Count > 0)) or
         ((AMsg.Encoding = mePlainText) and (PosInStrArray(AMsg.ContentTransferEncoding, ['base64', 'quoted-printable'], False) = -1))  {do not localize}
         ) then begin
          {NOTE: You hit this code path with multipart MIME messages and with
          plain-text messages (which may have UUE or XXE attachments embedded).}
          LCharsetEncoding := CharsetToEncoding(AMsg.CharSet);
          repeat
            {CC: This code assumes the preamble text (before the first boundary)
            is plain text.  I cannot imagine it not being, but if it arises, lines
            will have to be decoded.}

                                                                              
            // and charset encoding together!  Need to read the raw bytes into
            // an intermediate buffer of some kind using the transfer encoding,
            // and then decode the characters using the charset afterwards...
            //
            // Need to do this anyway because ReadLnRFC() processes the LF and
            // ADelim values in terms of the charset specified, which is wrong.
            // EBCDIC-based charsets totally break that logic! For example, cp1026
            // converts #10 (LF) to $25 instead of $0A during encoding, and converts
            // $0A (LF) and $2E ('.') to #$83 and #6 during decoding, etc. And what
            // if the charset is UTF-16 instead?  So we need to read raw bytes into
            // a buffer, checking it for handling of line breaks, dot-transparency,
            // and message termination, and THEN decode whatever is left using the
            // charset...

            LLine := IOHandler.ReadLnRFC(LMsgEnd, LF, ADelim, IndyTextEncoding_8Bit{$IFDEF STRING_IS_ANSI}, IndyTextEncoding_8Bit{$ENDIF});
            if LMsgEnd then begin
              Break;
            end;
            if LActiveDecoder = nil then begin
              LActiveDecoder := TRESTDWMessageDecoderList.CheckForStart(AMsg, LLine);
            end;
            // Check again, the if above can set it.
            if LActiveDecoder = nil then begin
              LLine := LCharsetEncoding.GetString(ToBytes(LLine, IndyTextEncoding_8Bit{$IFDEF STRING_IS_ANSI}, IndyTextEncoding_8Bit{$ENDIF}));
              AMsg.Body.Add(LLine);
            end else begin
              RemoveLastBlankLine(AMsg.Body);
              while LActiveDecoder <> nil do begin
                LActiveDecoder.SourceStream := TRESTDWTCPStream.Create(Self);
                LPreviousParentPart := AMsg.MIMEBoundary.ParentPart;
                LActiveDecoder.ReadHeader;
                case LActiveDecoder.PartType of
                  mcptText:       ProcessTextPart(LActiveDecoder, False);
                  mcptAttachment: ProcessAttachment(LActiveDecoder);
                  mcptIgnore:     FreeAndNil(LActiveDecoder);
                  mcptEOF:        begin FreeAndNil(LActiveDecoder); LMsgEnd := True; end;
                end;
              end;
            end;
          until LMsgEnd;
          RemoveLastBlankLine(AMsg.Body);
        end else begin
          {These are single-part MIMEs, or else mePlainTexts with the body encoded QP/base64}
          AMsg.IsMsgSinglePartMime := True;
          LActiveDecoder := TRESTDWMessageDecoderMime.Create(AMsg);
          LActiveDecoder.SourceStream := TRESTDWTCPStream.Create(Self);
          // RLebeau: override what TRESTDWMessageDecoderMime.InitComponent() assigns
          TRESTDWMessageDecoderMime(LActiveDecoder).BodyEncoded := True;
          TRESTDWMessageDecoderMime(LActiveDecoder).ReadHeader;
          case LActiveDecoder.PartType of
            mcptText: begin
              if LUnknownContentTransferEncoding then begin
                ProcessAttachment(LActiveDecoder);
              end else begin
                ProcessTextPart(LActiveDecoder, True); //Put the text into TRESTDWMessage.Body
              end;
            end;
            mcptAttachment: ProcessAttachment(LActiveDecoder);
            mcptIgnore:     FreeAndNil(LActiveDecoder);
            mcptEOF:        FreeAndNil(LActiveDecoder);
          end;
        end;
      finally
        FreeAndNil(LActiveDecoder);
      end;
    end;
  finally
    EndWork(wmRead);
  end;
end;

procedure TRESTDWMessageClient.SendHeader(AMsg: TRESTDWMessage);
begin
  AMsg.GenerateHeader;
  IOHandler.Write(AMsg.LastGeneratedHeaders);
end;

procedure TRESTDWMessageClient.SendBody(AMsg: TRESTDWMessage);
var
  i: Integer;
  LAttachment: TRESTDWAttachment;
  LBoundary: string;
  LDestStream: TStream;
  LStrStream: TStream;
  ISOCharset: string;
  HeaderEncoding: Char;  { B | Q }
  LEncoder: TRESTDWMessageEncoder;
  LLine: string;

  procedure EncodeStrings(AStrings: TStrings; AEncoderClass: TRESTDWMessageEncoderClass; AByteEncoding: IIdTextEncoding
    {$IFDEF STRING_IS_ANSI}; AAnsiEncoding: IIdTextEncoding{$ENDIF});
  var
    LStrings: TStringList;
  begin
    {$IFDEF STRING_IS_ANSI}
    EnsureEncoding(AAnsiEncoding, encOSDefault);
    {$ENDIF}
    LStrings := TStringList.Create; try
      LEncoder := AEncoderClass.Create(Self); try
        LStrStream := TMemoryStream.Create; try
          // RLebeau 10/06/2010: not using TStrings.SaveToStream() in D2009+
          // anymore, as it may save a BOM which we do not want here...
          WriteStringToStream(LStrStream, AStrings.Text, AByteEncoding{$IFDEF STRING_IS_ANSI}, AAnsiEncoding{$ENDIF});
          LStrStream.Position := 0;
          LEncoder.Encode(LStrStream, LStrings);
        finally FreeAndNil(LStrStream); end;
      finally FreeAndNil(LEncoder); end;
      IOHandler.WriteRFCStrings(LStrings, False);
    finally FreeAndNil(LStrings); end;
  end;

  procedure EncodeAttachment(AAttachment: TRESTDWAttachment; AEncoderClass: TRESTDWMessageEncoderClass);
  var
    LAttachStream: TStream;
  begin
    LDestStream := TRESTDWTCPStream.Create(Self, 8192); try
      LEncoder := AEncoderClass.Create(Self); try
        LEncoder.Filename := AAttachment.Filename;
        LAttachStream := AAttachment.OpenLoadStream; try
          LEncoder.Encode(LAttachStream, LDestStream);
        finally AAttachment.CloseLoadStream; end;
      finally FreeAndNil(LEncoder); end;
    finally FreeAndNil(LDestStream); end;
  end;

  procedure WriteTextPart(ATextPart: TRESTDWText);
  var
    LEncoding: IIdTextEncoding;
    LFileName: String;
  begin
    if ATextPart.ContentType = '' then begin
      ATextPart.ContentType := 'text/plain'; {do not localize}
    end;

    // RLebeau 08/17/09 - According to RFC 2045 Section 6.4:
    // "If an entity is of type "multipart" the Content-Transfer-Encoding is not
    // permitted to have any value other than "7bit", "8bit" or "binary"."
    //
    // However, came across one message where the "Content-Type" was set to
    // "multipart/related" and the "Content-Transfer-Encoding" was set to
    // "quoted-printable".  Outlook and Thunderbird were apparently able to parse
    // the message correctly, but Indy was not.  So let's check for that scenario
    // and ignore illegal "Content-Transfer-Encoding" values if present...

    if IsHeaderMediaType(ATextPart.ContentType, 'multipart') then begin {do not localize}
      if ATextPart.ContentTransfer <> '' then begin
        if PosInStrArray(ATextPart.ContentTransfer, ['7bit', '8bit', 'binary'], False) = -1 then begin {do not localize}
          ATextPart.ContentTransfer := '';
        end;
      end;
    end
    else if ATextPart.ContentTransfer = '' then begin
      ATextPart.ContentTransfer := 'quoted-printable'; {do not localize}
    end
    else if (PosInStrArray(ATextPart.ContentTransfer, ['quoted-printable', 'base64'], False) = -1) {do not localize}
      and ATextPart.IsBodyEncodingRequired then
    begin
      ATextPart.ContentTransfer := '8bit';                    {do not localize}
    end;

    if ATextPart.ContentDisposition = '' then begin
      ATextPart.ContentDisposition := 'inline'; {do not localize}
    end;

                                                                                                                               
    LFileName := EncodeHeader(ExtractFileName(ATextPart.FileName), '', HeaderEncoding, ISOCharSet); {do not localize}

    if ATextPart.ContentType <> '' then begin
      IOHandler.Write('Content-Type: ' + ATextPart.ContentType); {do not localize}
      if ATextPart.CharSet <> '' then begin
        IOHandler.Write('; charset="' + ATextPart.CharSet + '"'); {do not localize}
      end;
      if LFileName <> '' then begin
        IOHandler.WriteLn(';');  {do not localize}
        IOHandler.Write(TAB + 'name="' + LFileName + '"'); {do not localize}
      end;
      IOHandler.WriteLn;
    end;

    if ATextPart.ContentTransfer <> '' then begin
      IOHandler.WriteLn(SContentTransferEncoding + ': ' + ATextPart.ContentTransfer); {do not localize}
    end;

    IOHandler.Write('Content-Disposition: ' + ATextPart.ContentDisposition); {do not localize}
    if LFileName <> '' then begin
      IOHandler.WriteLn(';'); {do not localize}
      IOHandler.Write(TAB + 'filename="' + LFileName + '"'); {do not localize}
    end;
    IOHandler.WriteLn;

    if ATextPart.ContentID <> '' then begin
      IOHandler.WriteLn('Content-ID: ' + ATextPart.ContentID);  {do not localize}
    end;

    if ATextPart.ContentDescription <> '' then begin
      IOHandler.WriteLn('Content-Description: ' + ATextPart.ContentDescription); {do not localize}
    end;

    IOHandler.Write(ATextPart.ExtraHeaders);
    IOHandler.WriteLn;

    LEncoding := CharsetToEncoding(ATextPart.CharSet);
    if TextIsSame(ATextPart.ContentTransfer, 'quoted-printable') then begin {do not localize}
      EncodeStrings(ATextPart.Body, TRESTDWMessageEncoderQuotedPrintable, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
    end
    else if TextIsSame(ATextPart.ContentTransfer, 'base64') then begin  {do not localize}
      EncodeStrings(ATextPart.Body, TRESTDWMessageEncoderMIME, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
    end else
    begin
      IOHandler.WriteRFCStrings(ATextPart.Body, False, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
      { No test for last line break necessary because IOHandler.WriteRFCStrings() uses WriteLn(). }
    end;
  end;

var
  LFileName: String;
  LTextPart: TRESTDWText;
  LAddedTextPart: Boolean;
  LLastPart: Integer;
  LEncoding: IIdTextEncoding;
  LAttachStream: TStream;
begin
  LBoundary := '';
  AMsg.InitializeISO(HeaderEncoding, ISOCharSet);
  BeginWork(wmWrite);
  try
    if (not AMsg.IsMsgSinglePartMime) and
      (PosInStrArray(AMsg.ContentTransferEncoding, ['base64', 'quoted-printable'], False) <> -1) then {do not localize}
    begin
      //CC2: The user wants the body encoded.
      if AMsg.MessageParts.Count > 0 then begin
        //CC2: We cannot deal with parts within a body encoding (user has to do
        //this manually, if the user really wants to). Note this should have been trapped in TRESTDWMessage.GenerateHeader.
        raise EIdException.Create(RSMsgClientInvalidForTransferEncoding);
      end;
      IOHandler.WriteLn;     //This is the blank line after the headers
      DoStatus(hsStatusText, [RSMsgClientEncodingText]);
      LEncoding := CharsetToEncoding(AMsg.CharSet);
      //CC2: Now output AMsg.Body in the chosen encoding...
      if TextIsSame(AMsg.ContentTransferEncoding, 'base64') then begin  {do not localize}
        EncodeStrings(AMsg.Body, TRESTDWMessageEncoderMIME, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
      end else begin  {'quoted-printable'}
        EncodeStrings(AMsg.Body, TRESTDWMessageEncoderQuotedPrintable, LEncoding{$IFDEF STRING_IS_ANSI}, LEncoding{$ENDIF});
      end;
    end
    else if AMsg.Encoding = mePlainText then begin
      IOHandler.WriteLn;     //This is the blank line after the headers
      //CC2: It is NOT Mime.  It is a body followed by optional attachments
      DoStatus(hsStatusText, [RSMsgClientEncodingText]);
      // Write out Body first
      LEncoding := CharsetToEncoding(AMsg.CharSet);
      EncodeAndWriteText(AMsg.Body, LEncoding);
      IOHandler.WriteLn;
      if AMsg.MessageParts.Count > 0 then begin
        //The message has attachments.
        for i := 0 to AMsg.MessageParts.Count - 1 do begin
          //CC: Added support for TRESTDWText...
          if AMsg.MessageParts.Items[i] is TRESTDWText then begin
            IOHandler.WriteLn;
            IOHandler.WriteLn('------- Start of text attachment -------'); {do not localize}
            DoStatus(hsStatusText,  [RSMsgClientEncodingText]);
            WriteTextPart(TRESTDWText(AMsg.MessageParts.Items[i]));
            IOHandler.WriteLn('------- End of text attachment -------');   {do not localize}
          end
          else if AMsg.MessageParts.Items[i] is TRESTDWAttachment then begin
            LAttachment := TRESTDWAttachment(AMsg.MessageParts[i]);
            DoStatus(hsStatusText, [RSMsgClientEncodingAttachment]);
            if LAttachment.ContentTransfer = '' then begin
              //The user has nothing specified: see has he set a preference in
              //TRESTDWMessage.AttachmentEncoding (AttachmentEncoding is really an
              //old and somewhat deprecated property, but we can still support it)...
              if PosInStrArray(AMsg.AttachmentEncoding, ['UUE', 'XXE']) <> -1 then begin  {do not localize}
                LAttachment.ContentTransfer := AMsg.AttachmentEncoding;
              end else begin
                //We default to UUE (rather than XXE)...
                LAttachment.ContentTransfer := 'UUE';  {do not localize}
              end;
            end;
            case PosInStrArray(LAttachment.ContentTransfer, ['UUE', 'XXE'], False) of  {do not localize}
              0: EncodeAttachment(LAttachment, TRESTDWMessageEncoderUUE);
              1: EncodeAttachment(LAttachment, TRESTDWMessageEncoderXXE);
            end;
          end;
          IOHandler.WriteLn;
        end;
      end;
    end
    else begin
      //CC2: It is MIME-encoding...
      LAddedTextPart := False;
      //######### OUTPUT THE PREAMBLE TEXT ########
      {For single-part MIME messages, we want the message part headers to be appended
      to the message headers.  Otherwise, add the blank separator between header and
      body...}
      if not AMsg.IsMsgSinglePartMime then begin
        IOHandler.WriteLn;     //This is the blank line after the headers
        //if AMsg.Body.Count > 0 then begin
        if not AMsg.IsBodyEmpty then begin
          //CC2: The message has a body text.  There are now a few possibilities.
          //First up, if ConvertPreamble is False then the user explicitly does not want us
          //to convert the .Body since he had to change it from the default False.
          //Secondly, if AMsg.MessageParts.TextPartCount > 0, he may have put the
          //message text in the part, so don't convert the body.
          //Thirdly, if AMsg.MessageParts.Count = 0, then it has no other parts
          //anyway: in this case, output it without boundaries.
          //if (AMsg.ConvertPreamble and (AMsg.MessageParts.TextPartCount = 0)) then begin
          if AMsg.ConvertPreamble and (AMsg.MessageParts.TextPartCount = 0) and (AMsg.MessageParts.Count > 0) then begin
            //CC2: There is no text part, the user has not changed ConvertPreamble from
            //its default of True, so the user has probably put his message into
            //the body by mistake instead of putting it in a TRESTDWText part.
            //Create a TRESTDWText part from the .Body text...
            LTextPart := TRESTDWText.Create(AMsg.MessageParts, AMsg.Body);
            LTextPart.CharSet := AMsg.CharSet;
            LTextPart.ContentType := 'text/plain';  {do not localize}
            LTextPart.ContentTransfer := 'quoted-printable';    {do not localize}
            //Have to remember that we added a text part, which is the last part
            //in the collection, because we need it to be outputted first...
            LAddedTextPart := True;
            //CC2: Insert our standard preamble text...
            IOHandler.WriteLn(SThisIsMultiPartMessageInMIMEFormat);
          end else begin
            //CC2: Hopefully the user has put suitable text in the preamble, or this
            //is an already-received message which already has a preamble text...
            LEncoding := CharsetToEncoding(AMsg.CharSet);
            EncodeAndWriteText(AMsg.Body, LEncoding);
          end;
        end
        else begin
          //CC2: The user has specified no body text: he presumably has the message in
          //a TRESTDWText part, but it may have no text at all (a message consisting only
          //of headers, which is allowed under the RFC, which will have a parts count
          //of 0).
          if AMsg.MessageParts.Count <> 0 then begin
            //Add the "standard" MIME preamble text for non-html email clients...
            IOHandler.WriteLn(SThisIsMultiPartMessageInMIMEFormat);
          end;
        end;
        IOHandler.WriteLn;
        //######### SET UP THE BOUNDARY STACK ########
        LBoundary := AMsg.MIMEBoundary.Boundary;
        if LBoundary = '' then begin
          LBoundary := TRESTDWMIMEBoundaryStrings.GenerateBoundary;
          AMsg.MIMEBoundary.Push(LBoundary, -1);  //-1 is "top level"
        end;
      end;
      //######### OUTPUT THE PARTS ########
      //CC2: Write the text parts in their order, if you change the order you
      //can mess up mutipart sequences.
      //The exception is due to ConvertPreamble, which may have added a text
      //part at the end (the only place a TRESTDWText part can be added), but it
      //needs to be outputted first...
      LLastPart := AMsg.MessageParts.Count - 1;
      if LAddedTextPart then begin
        IOHandler.WriteLn('--' + LBoundary);       {do not localize}
        DoStatus(hsStatusText, [RSMsgClientEncodingText]);
        WriteTextPart(AMsg.MessageParts.Items[LLastPart] as TRESTDWText);
        IOHandler.WriteLn;
        Dec(LLastPart);  //Don't output it again in the following "for" loop
      end;
      for i := 0 to LLastPart do begin
        LLine := AMsg.MessageParts.Items[i].ContentType;
        if IsHeaderMediaType(LLine, 'multipart') then begin  {do not localize}
          //A multipart header.  Write out the CURRENT boundary first...
          IOHandler.WriteLn('--' + LBoundary);      {do not localize}
          //Make the current boundary and this part number active...
          //Now need to generate a new boundary...
          LBoundary := TRESTDWMIMEBoundaryStrings.GenerateBoundary;
          AMsg.MIMEBoundary.Push(LBoundary, i);
          //Make sure the header does not already have a pre-existing
          //boundary since we just generated a new one...
          IOHandler.WriteLn('Content-Type: ' + RemoveHeaderEntry(LLine, 'boundary', QuoteMIME) + ';');            {do not localize}
          IOHandler.WriteLn(TAB + 'boundary="' + LBoundary + '"');  {do not localize}
          IOHandler.WriteLn;
        end
        else begin
          //Not a multipart header, see if it is a part change...
          if not AMsg.IsMsgSinglePartMime then begin
            while AMsg.MessageParts.Items[i].ParentPart <> AMsg.MIMEBoundary.ParentPart do begin
              IOHandler.WriteLn('--' + LBoundary + '--');  {do not localize}
              IOHandler.WriteLn;
              AMsg.MIMEBoundary.Pop;  //This also pops AMsg.MIMEBoundary.ParentPart
              LBoundary := AMsg.MIMEBoundary.Boundary;
            end;
            IOHandler.WriteLn('--' + LBoundary);  {do not localize}
          end;
          if AMsg.MessageParts.Items[i] is TRESTDWText then begin
            DoStatus(hsStatusText,  [RSMsgClientEncodingText]);
            WriteTextPart(AMsg.MessageParts.Items[i] as TRESTDWText);
            IOHandler.WriteLn;
          end
          else if AMsg.MessageParts.Items[i] is TRESTDWAttachment then begin
            LAttachment := TRESTDWAttachment(AMsg.MessageParts[i]);
            DoStatus(hsStatusText, [RSMsgClientEncodingAttachment]);
            if LAttachment.ContentTransfer = '' then begin
              LAttachment.ContentTransfer := 'base64'; {do not localize}
            end;
            if LAttachment.ContentDisposition = '' then begin
              LAttachment.ContentDisposition := 'attachment'; {do not localize}
            end;
            if LAttachment.ContentType = '' then begin
              if TextIsSame(LAttachment.ContentTransfer, 'base64') then begin {do not localize}
                LAttachment.ContentType := 'application/octet-stream'; {do not localize}
              end else begin
                {CC4: Set default type if not base64 encoded...}
                LAttachment.ContentType := 'text/plain'; {do not localize}
              end;
            end;

                                                                                                                                       
            LFileName := EncodeHeader(ExtractFileName(LAttachment.FileName), '', HeaderEncoding, ISOCharSet); {do not localize}

            if TextIsSame(LAttachment.ContentTransfer, 'binhex40') then begin   {do not localize}
              //This is special - you do NOT write out any Content-Transfer-Encoding
              //header!  We also have to write a Content-Type specified in RFC 1741
              //(overriding any ContentType present, if necessary).
              LAttachment.ContentType := 'application/mac-binhex40';            {do not localize}
              IOHandler.Write('Content-Type: ' + LAttachment.ContentType); {do not localize}
              if LAttachment.CharSet <> '' then begin
                IOHandler.Write('; charset="' + LAttachment.CharSet + '"'); {do not localize}
              end;
              if LFileName <> '' then begin
                IOHandler.WriteLn(';'); {do not localize}
                IOHandler.Write(TAB + 'name="' + LFileName + '"'); {do not localize}
              end;
              IOHandler.WriteLn;
            end
            else begin
              IOHandler.Write('Content-Type: ' + LAttachment.ContentType); {do not localize}
              if LAttachment.CharSet <> '' then begin
                IOHandler.Write('; charset="' + LAttachment.CharSet + '"'); {do not localize}
              end;
              if LFileName <> '' then begin
                IOHandler.WriteLn(';');
                IOHandler.Write(TAB + 'name="' + LFileName + '"'); {do not localize}
              end;
              IOHandler.WriteLn;
              IOHandler.WriteLn('Content-Transfer-Encoding: ' + LAttachment.ContentTransfer); {do not localize}
              IOHandler.Write('Content-Disposition: ' + LAttachment.ContentDisposition); {do not localize}
              if LFileName <> '' then begin
                IOHandler.WriteLn(';');
                IOHandler.Write(TAB + 'filename="' + LFileName + '"'); {do not localize}
              end;
              IOHandler.WriteLn;
            end;
            if LAttachment.ContentID <> '' then begin
              IOHandler.WriteLn('Content-ID: '+ LAttachment.ContentID); {Do not Localize}
            end;
            if LAttachment.ContentDescription <> '' then begin
              IOHandler.WriteLn('Content-Description: ' + LAttachment.ContentDescription); {Do not localize}
            end;

            IOHandler.Write(LAttachment.ExtraHeaders);
            IOHandler.WriteLn;

            case PosInStrArray(LAttachment.ContentTransfer, ['base64', 'quoted-printable', 'binhex40'], False) of {do not localize}
              0: EncodeAttachment(LAttachment, TRESTDWMessageEncoderMIME);
              1: EncodeAttachment(LAttachment, TRESTDWMessageEncoderQuotedPrintable);
              2: EncodeAttachment(LAttachment, TRESTDWMessageEncoderBinHex4);
              else
              begin
                LEncoding := CharsetToEncoding(LAttachment.Charset);
                LAttachStream := LAttachment.OpenLoadStream;
                try
                  while ReadLnFromStream(LAttachStream, LLine, -1, LEncoding) do begin
                    IOHandler.WriteLnRFC(LLine, LEncoding);
                  end;
                finally
                  LAttachment.CloseLoadStream;
                end;
              end;
            end;
            IOHandler.WriteLn;
          end;
        end;
      end;
      if AMsg.MessageParts.Count > 0 then begin
        for i := 0 to AMsg.MIMEBoundary.Count - 1 do begin
          if not AMsg.IsMsgSinglePartMime then begin
            IOHandler.WriteLn('--' + AMsg.MIMEBoundary.Boundary + '--');
            IOHandler.WriteLn;
          end;
          AMsg.MIMEBoundary.Pop;
        end;
      end;
    end;
  finally
    EndWork(wmWrite);
  end;
end;

procedure TRESTDWMessageClient.SendMsg(AMsg: TRESTDWMessage; AHeadersOnly: Boolean = False);
begin
  BeginWork(wmWrite);
  try
    if AMsg.NoEncode then begin
      IOHandler.Write(AMsg.Headers);
      IOHandler.WriteLn;
      if not AHeadersOnly then begin
        IOHandler.WriteRFCStrings(AMsg.Body, False);
      end;
    end else begin
      SendHeader(AMsg);
      if (not AHeadersOnly) then begin
        SendBody(AMsg);
      end;
    end;
  finally
    EndWork(wmWrite);
  end;
end;

function TRESTDWMessageClient.ReceiveHeader(AMsg: TRESTDWMessage; const AAltTerm: string = ''): string;
var
  LMsgEnd: Boolean;
begin
  BeginWork(wmRead);
  try
    repeat
      Result := IOHandler.ReadLnRFC(LMsgEnd);
      // Exchange Bug: Exchange sometimes returns . when getting a message instead of
      // '' then a . - That is there is no seperation between the header and the message for an
      // empty message.
      if ((Length(AAltTerm) = 0) and LMsgEnd) or  {do not localize}
         ({APR: why? (Length(AAltTerm) > 0) and }(Result = AAltTerm)) then begin
        Break;
      end else if Result <> '' then begin
        AMsg.Headers.Append(Result);
      end;
    until False;
    AMsg.ProcessHeaders;
  finally
    EndWork(wmRead);
  end;
end;

procedure TRESTDWMessageClient.ProcessMessage(AMsg: TRESTDWMessage; AHeaderOnly: Boolean = False);
begin
  if IOHandler <> nil then begin
    //Don't call ReceiveBody if the message ended at the end of the headers
    //(ReceiveHeader() would have returned '.' in that case)...
    BeginWork(wmRead);
    try
      if ReceiveHeader(AMsg) = '' then begin
        if not AHeaderOnly then begin
          ReceiveBody(AMsg);
        end;
      end;
    finally
      EndWork(wmRead);
    end;
  end;
end;

procedure TRESTDWMessageClient.ProcessMessage(AMsg: TRESTDWMessage; AStream: TStream; AHeaderOnly: Boolean = False);
var
  LIOHandler: TRESTDWIOHandlerStreamMsg;
begin
  LIOHandler := TRESTDWIOHandlerStreamMsg.Create(nil, AStream);
  try
    LIOHandler.FreeStreams := False;
    IOHandler := LIOHandler;
    try
      IOHandler.Open;
      ProcessMessage(AMsg, AHeaderOnly);
    finally
      IOHandler := nil;
    end;
  finally
    LIOHandler.Free;
  end;
end;

procedure TRESTDWMessageClient.ProcessMessage(AMsg: TRESTDWMessage; const AFilename: string; AHeaderOnly: Boolean = False);
var
  LStream: TStream;
begin
  LStream := TRESTDWReadFileExclusiveStream.Create(AFileName); try
    ProcessMessage(AMsg, LStream, AHeaderOnly);
  finally FreeAndNil(LStream); end;
end;

procedure TRESTDWMessageClient.EncodeAndWriteText(const ABody: TStrings; AEncoding: IIdTextEncoding);
begin
  Assert(ABody<>nil);
  Assert(IOHandler<>nil);
                             
  IOHandler.WriteRFCStrings(ABody, False, AEncoding);
end;

destructor TRESTDWMessageClient.Destroy;
begin
  inherited Destroy;
end;

end.
