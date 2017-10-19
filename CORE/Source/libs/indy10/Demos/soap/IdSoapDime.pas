{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15718: IdSoapDime.pas 
{
{   Rev 1.1    18/3/2003 11:02:24  GGrieve
{ major release - QName, RawXML, bugs fixed
}
{
{   Rev 1.0    11/2/2003 20:33:00  GGrieve
}
{
IndySOAP: This unit implements DIME encoding and decoding

This is based on http://www.ietf.org/internet-drafts/draft-nielsen-dime-02.txt

Chunking will be collapsed when reading a message. You can get the last
chunk size in the record property

DIME Options are ignored

There's some rules regarding typetypes and whether type information can
be provided. These are ignored. You can specify an invalid conbination
it you want.
}
{
Version History:
  18-Mar 2003   Grahame Grieve                  fix for D4, Kylix
  29-Oct 2002   Grahame Grieve                  remove hints & Warnings
  04-Oct 2002   Grahame Grieve                  First implemented
}

unit IdSoapDime;

{$I IdSoapDefines.inc}

interface

uses
  Classes,
{$IFNDEF DELPHI4}
  Contnrs,
{$ENDIF}
  IdSoapDebug,
  IdSoapUtilities;

type
  TIdSoapDimeType = (dtMime, dtURI, dtNotKnown, dtInvalid);

  TIdSoapDimeRecord = class (TIdBaseObject)
  private
    FTypeType : TIdSoapDimeType;
    FTypeInfo : string;
    FId: String;
    FContent: TStream;
    FClosed : boolean;
    FChunkSize : integer;
    procedure Encode(AStream : TStream; AFirst, ALast : boolean);
  public
    constructor create;
    destructor destroy;  override;
    // you are allowed to change the stream type - free the existing one first. This object assumes ownership of the stream
    property Content : TStream read FContent write FContent;
    property TypeType : TIdSoapDimeType read FTypeType write FTypeType;
    property TypeInfo : string read FTypeInfo write FTypeInfo;
    property Id : string read FId write FId;
    property ChunkSize : integer read FChunkSize write FChunkSize;
  end;

  TIdSoapDimeMessage = class (TIdBaseObject)
  private
    FRecords : TObjectList;
    function GetItem(AIndex: integer): TIdSoapDimeRecord;
    function GetItemByName(AName: string): TIdSoapDimeRecord;
    procedure ReadRecord(AStream : TStream; AIndex : integer; AChunked : boolean);
    function GetRecordCount: integer;
  public
    constructor create;
    destructor destroy;  override;
    procedure ReadFromStream(AStream : TStream);
    procedure WriteToStream(AStream : TStream);

    property Item[AIndex : integer] : TIdSoapDimeRecord read GetItem;
    property ItemByName[AName : string] : TIdSoapDimeRecord read GetItemByName;
    function Add(AId : string = ''):TIdSoapDimeRecord;
    property RecordCount : integer read GetRecordCount;
  end;

procedure StreamWriteBinary(AStream: TStream; APointer: Pointer; ALength: Cardinal);
procedure StreamWriteByte(AStream: TStream; AByte: Byte);
procedure StreamWriteWord(AStream: TStream; AWord: Word);
procedure StreamWriteCardinal(AStream: TStream; ACardinal: Cardinal);
procedure StreamWriteShortString(AStream: TStream; AString: ShortString);
procedure StreamWriteLongString(AStream: TStream; AString: String);
procedure StreamReadBinary(AStream: TStream; APointer: pointer; ALength: Cardinal);
function StreamReadByte(AStream: TStream): Byte;
function StreamReadWord(AStream: TStream): Word;
function StreamReadCardinal(AStream: TStream): Cardinal;
function StreamReadShortString(AStream: TStream): ShortString;
function StreamReadLongString(AStream: TStream): String;
procedure StreamSkip(AStream: TStream; AByteCount : Cardinal);

implementation

uses
  SysUtils;

const
  ASSERT_UNIT = 'IdSoapDime';

procedure StreamWriteBinary(AStream: TStream; APointer: Pointer; ALength: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamWriteBinary';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  assert(Assigned(APointer), ASSERT_LOCATION+': Pointer is nil');
  // no check on ALength?
  AStream.Write(APointer^, ALength);
end;

procedure StreamWriteByte(AStream: TStream; AByte: Byte);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamWriteByte';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  // no check on AByte
  StreamWriteBinary(AStream, @AByte, Sizeof(Byte));
end;

procedure StreamWriteWord(AStream: TStream; AWord: Word);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamWriteWord';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  // no check on AByte
  StreamWriteBinary(AStream, @AWord, Sizeof(Word));
end;

procedure StreamWriteCardinal(AStream: TStream; ACardinal: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamWriteCardinal';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  // no check on ACardinal
  StreamWriteBinary(AStream, @ACardinal, Sizeof(Cardinal));
end;

procedure StreamWriteShortString(AStream: TStream; AString: ShortString);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamWriteShortString';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  // no check on AString
  StreamWriteByte(AStream, length(AString));
  StreamWriteBinary(AStream, @AString[1], Length(AString));
end;

procedure StreamWriteLongString(AStream: TStream; AString: String);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamWriteShortString';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  // no check on AString
  StreamWriteCardinal(AStream, length(AString));
  if Length(AString) <> 0 then
    begin
    StreamWriteBinary(AStream, @AString[1], Length(AString));
    end;
end;

procedure StreamReadBinary(AStream: TStream; APointer: pointer; ALength: Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamReadBinary';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  assert(Assigned(APointer), ASSERT_LOCATION+': Pointer is nil');
  assert(AStream.Position + integer(ALength) <= AStream.Size, 'StreamReadBinary: Attempt to Read off end of Stream');
  AStream.Read(APointer^, ALength);
end;

function StreamReadByte(AStream: TStream): Byte;
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamReadByte';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  StreamReadBinary(AStream, @Result, sizeof(Byte));
end;

function StreamReadWord(AStream: TStream): Word;
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamReadWord';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  StreamReadBinary(AStream, @Result, sizeof(Word));
end;

function StreamReadCardinal(AStream: TStream): Cardinal;
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamReadCardinal';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  StreamReadBinary(AStream, @Result, sizeof(Cardinal));
end;

function StreamReadShortString(AStream: TStream): ShortString;
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamReadShortString';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  SetLength(Result, StreamReadByte(AStream));
  StreamReadBinary(AStream, @Result[1], Length(Result));
end;

function StreamReadLongString(AStream: TStream): String;
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamReadShortString';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  SetLength(Result, StreamReadcardinal(AStream));
  if length(result) <> 0 then
    begin
    StreamReadBinary(AStream, @Result[1], Length(Result));
    end;
end;

procedure StreamSkip(AStream: TStream; AByteCount : Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamSkip';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  assert(AStream.Position + integer(AByteCount) <= AStream.size, ASSERT_LOCATION+': Run off end of stream ('+inttostr(AStream.size)+') at '+inttostr(AStream.Position)+' bytes, skipping '+inttostr(AByteCount));
  AStream.Position := AStream.Position + integer(AByteCount);
end;

procedure StreamSkipPadding(AStream: TStream; AByteCount : Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamSkip';
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  if AByteCount mod 4 <> 0 then
    begin
    StreamSkip(AStream, 4 - (AByteCount mod 4));
    end;
end;

procedure StreamPad(AStream: TStream; AByteCount : Cardinal);
const ASSERT_LOCATION = ASSERT_UNIT+'.StreamSkip';
var
  i : integer;
begin
  assert(Assigned(AStream), ASSERT_LOCATION+': Stream is nil');
  if AByteCount mod 4 <> 0 then
    begin
    for i := 1 to 4 - (AByteCount mod 4) do
      begin
      StreamWriteByte(AStream, 0);
      end;
    end;
end;

function GetTypeForValue(AValue : byte):TIdSoapDimeType;
begin
  case AValue of
    $01     :result := dtMime;
    $02     :result := dtURI;
    $03, $04:result := dtNotKnown;
  else
    result := dtInvalid;
  end;
end;

function GetValueForType(AValue : TIdSoapDimeType):byte;
begin
  case AValue of
    dtMime     :result := $01;
    dtURI     :result := $02;
    dtNotKnown:result := $03;
  else {dtInvalid}
    result := $05;
  end;
end;

{ TIdSoapDimeRecord }

constructor TIdSoapDimeRecord.create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeRecord.create';
begin
  inherited;
  FContent := TIdMemoryStream.create;
end;

destructor TIdSoapDimeRecord.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeRecord.destroy';
begin
  FreeAndNil(FContent);
  inherited;
end;

procedure TIdSoapDimeRecord.Encode(AStream: TStream; AFirst, ALast: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeRecord.destroy';
var
  LHeader : Byte;
  LChunking : boolean;
  LChunkSize : integer;
  LFirstChunk : boolean;
  LLen : cardinal;
begin
  assert(self.TestValid(TIdSoapDimeRecord), ASSERT_LOCATION+': self is not valid');
  assert(Assigned(AStream), ASSERT_LOCATION+': stream is not valid');

  FContent.position := 0;
  LChunking := (FChunkSize > 0) and (FContent.Size > FChunkSize);
  if LChunking then
    begin
    LChunkSize := FChunkSize;
    end
  else
    begin
    LChunkSize := FContent.Size;
    end;
  LFirstChunk := true;

  repeat
    LHeader := ($01 shl 3);
    if LFirstChunk and AFirst then
      begin
      LHeader := LHeader or $04;
      end;
    if ((FContent.Size - FContent.Position) > LChunkSize) then
      begin
      // this is an intermediate chunk
      LHeader := LHeader or $01;
      end
    else
      begin
      if ((FContent.Size - FContent.Position) < LChunkSize) then
        begin
        LChunkSize := FContent.Size - FContent.Position;
        end;
      if ALast then
        begin
        LHeader := LHeader or $02;
        end;
      end;
    StreamWriteByte(AStream, LHeader);
    if LFirstChunk then
      begin
      StreamWriteByte(AStream, GetValueForType(FTypeType) Shl 4);
      StreamWriteWord(AStream, 0);
      LLen := Length(FId);
      StreamWriteByte(AStream, (LLen shr 8) mod 256);
      StreamWriteByte(AStream, LLen mod 256);
      LLen := Length(FTypeInfo);
      StreamWriteByte(AStream, (LLen shr 8) mod 256);
      StreamWriteByte(AStream, LLen mod 256);
      end
    else
      begin
      StreamWriteByte(AStream, 0);
      StreamWriteWord(AStream, 0);
      StreamWriteWord(AStream, 0);
      StreamWriteWord(AStream, 0);
      end;
    StreamWriteByte(AStream, (LChunkSize shr 24) mod 256);
    StreamWriteByte(AStream, (LChunkSize shr 16) mod 256);
    StreamWriteByte(AStream, (LChunkSize shr 8) mod 256);
    StreamWriteByte(AStream, LChunkSize mod 256);
    if LFirstChunk and (FId <> '') then
      begin
      StreamWriteBinary(AStream, @FId[1], length(FId));
      StreamPad(AStream, length(FId));
      end;
    if LFirstChunk and (FTypeInfo <> '') then
      begin
      StreamWriteBinary(AStream, @FTypeInfo[1], length(FTypeInfo));
      StreamPad(AStream, length(FTypeInfo));
      end;
    if LChunkSize > 0 then
      begin
      AStream.CopyFrom(FContent, LChunkSize);
      StreamPad(AStream, LChunkSize);
      end;
    LFirstChunk := false;
  until FContent.Position = FContent.Size;
end;

{ TIdSoapDimeMessage }

constructor TIdSoapDimeMessage.create;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.create';
begin
  inherited;
  FRecords := TObjectList.create(true);
end;

destructor TIdSoapDimeMessage.destroy;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.destroy';
begin
  assert(self.TestValid(TIdSoapDimeMessage), ASSERT_LOCATION+': self is not valid');
  FreeAndNil(FRecords);
  inherited;
end;

procedure TIdSoapDimeMessage.ReadRecord(AStream: TStream; AIndex : integer; AChunked: boolean);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.ReadRecord';
var
  LType : integer;
  LRec : TIdSoapDimeRecord;
  LLenOpt : word;
  LLenId : word;
  LLenType : word;
  LLenData : Cardinal;
begin
  LType := StreamReadByte(AStream) shr 4;
  if LType = 4 then
    begin
    // this was null record
    exit;
    end;
  if LType = 0 then
    begin
    // ok, we are a chunk follow on - though chunked may not be true if this is the last
    IdRequire(FRecords.count > 0, ASSERT_LOCATION+': DIME record '+inttostr(AIndex)+' purports to follow on, but not records found');
    LRec := FRecords.items[FRecords.count - 1] as TIdSoapDimeRecord;
    IdRequire(not LRec.FClosed, ASSERT_LOCATION+': DIME record '+inttostr(AIndex)+' purports to follow on, but the last DIME content is already closed');
    end
  else
    begin
    // ok we are a new record
    IdRequire((FRecords.count = 0) or (FRecords.items[FRecords.count - 1] as TIdSoapDimeRecord).FClosed,
        ASSERT_LOCATION+': DIME record '+inttostr(AIndex)+' is a new record, but the last record has not been closed');
    LRec := TIdSoapDimeRecord.create;
    FRecords.Add(LRec);
    LRec.FTypeType := GetTypeForValue(LType);
    end;
  // There's an endian problem to work around here:
  LLenOpt := StreamReadByte(AStream) shl 8 + StreamReadByte(AStream);
  LLenId := StreamReadByte(AStream) shl 8 + StreamReadByte(AStream);
  LLenType := StreamReadByte(AStream) shl 8 + StreamReadByte(AStream);
  LLenData := StreamReadByte(AStream) shl 24 + StreamReadByte(AStream) shl 16 + StreamReadByte(AStream) shl 8 + StreamReadByte(AStream);
  StreamSkip(AStream, LLenOpt); // skip the options
  StreamSkipPadding(AStream, LLenOpt);
  if LType = 0 then
    begin
    IdRequire(LLenId = 0, ASSERT_LOCATION+': DIME record '+inttostr(AIndex)+' is a repeat chunk, but contains an ID');
    IdRequire(LLenType = 0, ASSERT_LOCATION+': DIME record '+inttostr(AIndex)+' is a repeat chunk, but contains a type');
    end
  else
    begin
    if LLenID <> 0 then
      begin
      SetLength(LRec.FId, LLenId);
      StreamReadBinary(AStream, @LRec.FId[1], LlenID);
      StreamSkipPadding(AStream, LlenID);
      end;
    if LLenType <> 0 then
      begin
      SetLength(LRec.FTypeInfo, LLenType);
      StreamReadBinary(AStream, @LRec.FTypeInfo[1], LLenType);
      StreamSkipPadding(AStream, LLenType);
      end;
    end;
  if LLenData <> 0 then
    begin
    LRec.FContent.CopyFrom(AStream, LLenData);
    StreamSkipPadding(AStream, LLenData);
    end;
  if not AChunked then
    begin
    LRec.FClosed := true;
    end
  else
    begin
    LRec.FChunkSize := LLenData;
    end;
end;

procedure TIdSoapDimeMessage.ReadFromStream(AStream : TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.ReadFromStream';
var
  LHeader : Byte;
  LVersion : Byte;
  LFinished : boolean;
  LRec : TIdSoapDimeRecord;
  i : integer;
begin
  assert(self.TestValid(TIdSoapDimeMessage), ASSERT_LOCATION+': self is not valid');
  assert(Assigned(AStream), ASSERT_LOCATION+': stream is not valid');
  assert(AStream.Size - AStream.Position >= 12, 'Stream is too short to contain valid DIME Content ('+inttostr(AStream.Size - AStream.Position)+')');

  LHeader := StreamReadByte(AStream);
  LVersion := LHeader shr 3;
  i := 0;
  IdRequire(LVersion = $01, ASSERT_LOCATION+': Unknown DIME Version '+inttostr(LVersion)+' encountered');
  IdRequire((LHeader and $04) > 0, ASSERT_LOCATION+': DIME message does not begin with MB packet');
  repeat
    IdRequire((LHeader shr 3) = $01, ASSERT_LOCATION+': Message DIME Version '+inttostr(LVersion)+' different to message DIME version '+inttostr((LHeader shr 3))+' in record '+inttostr(i));
    ReadRecord(AStream, i, LHeader and $01 > 0);
    LFinished := (LHeader and $02) > 0;
    if not LFinished then
      begin
      LHeader := StreamReadByte(AStream);
      IdRequire(LHeader and $04 = 0, ASSERT_LOCATION+': MB flag encountered in record '+inttostr(i));
      end;
    inc(i);
  until LFinished;
  for i := 0 to FRecords.count - 1 do
    begin
    LRec := FRecords.items[i] as TIdSoapDimeRecord;
    IdRequire(LRec.FClosed, ASSERT_LOCATION+': DIME Record '+inttostr(i)+ ' was not closed');
    LRec.FContent.Position := 0;
    end;
end;

function TIdSoapDimeMessage.Add(AId: string): TIdSoapDimeRecord;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.Add';
begin
  assert(self.TestValid(TIdSoapDimeMessage), ASSERT_LOCATION+': self is not valid');
  result := TIdSoapDimeRecord.create;
  FRecords.Add(result);
  result.FId := AId;
end;

function TIdSoapDimeMessage.GetItem(AIndex: integer): TIdSoapDimeRecord;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.GetItem';
begin
  assert(self.TestValid(TIdSoapDimeMessage), ASSERT_LOCATION+': self is not valid');
  result := FRecords.Items[AIndex] as TIdSoapDimeRecord;
end;

function TIdSoapDimeMessage.GetItemByName(AName: string): TIdSoapDimeRecord;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.GetItemByName';
var
  i : integer;
begin
  assert(self.TestValid(TIdSoapDimeMessage), ASSERT_LOCATION+': self is not valid');
  result := nil;
  For i := 0 to FRecords.count -1 do
    begin
    if (FRecords.Items[i] as TIdSoapDimeRecord).FId = AName then
      begin
      result := FRecords.Items[i] as TIdSoapDimeRecord;
      exit;
      end;
    end;
end;

procedure TIdSoapDimeMessage.WriteToStream(AStream: TStream);
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.WriteToStream';
var
  i : integer;
begin
  assert(self.TestValid(TIdSoapDimeMessage), ASSERT_LOCATION+': self is not valid');
  if  FRecords.count = 0 then
    begin
    StreamWriteByte(AStream, (1 shl 3) or $04 or $02);
    StreamWriteByte(AStream, 4 shl 4);
    // no endian worries with 0's
    StreamWriteWord(AStream, 0);
    StreamWriteWord(AStream, 0);
    StreamWriteWord(AStream, 0);
    StreamWriteCardinal(AStream, 0);
    end
  else
    begin
    for i := 0 to FRecords.count - 1 do
      begin
      (FRecords.Items[i] as TIdSoapDimeRecord).Encode(AStream, (i=0), (i = FRecords.count - 1));
      end;
    end;
end;

function TIdSoapDimeMessage.GetRecordCount: integer;
const ASSERT_LOCATION = ASSERT_UNIT+'.TIdSoapDimeMessage.GetRecordCount';
begin
  assert(self.TestValid(TIdSoapDimeMessage), ASSERT_LOCATION+': self is not valid');
  result := FRecords.Count;
end;

end.

