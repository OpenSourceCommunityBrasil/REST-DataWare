Unit uRESTDWMemStreams;
{$I uRESTDW.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tambm tem por objetivo levar componentes compatveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc usurio que precisa
 de produtividade e flexibilidade para produo de Servios REST/JSON, simplificando o processo para voc programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFDEF FPC}
 {$MODE Delphi}
 {$ASMMode Intel}
{$ENDIF}

Interface
Uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  {$IFDEF RESTDWLINUX}
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Classes, Posix.Unistd,
  {$ELSE ~RESTDWLINUX}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  SysUtils, Classes,
//  Contnrs,
  {$ENDIF ~RESTDWLINUX}
  {$IFDEF HAS_UNIT_LIBC}
  Libc,
  {$ENDIF HAS_UNIT_LIBC}

  uRESTDWMemBase, uRESTDWMemMath,
  uRESTDWMemStringConversions,
  uRESTDWPrototypes;
Const
  StreamDefaultBufferSize = 4096;
Type
  TObjectList     = Class(Tlist);
  EJclStreamError = Class(EJclError);
  // abstraction layer to support Delphi 5 and C++Builder 5 streams
  // 64 bit version of overloaded functions are introduced
  TJclStream = Class(TStream)
  Protected
    Procedure SetSize(NewSize: Longint); overload; override;
    Procedure SetSize(Const NewSize: Int64); overload; override;
  Public
    Function  Seek(Offset: Longint; Origin: Word): Longint; overload; override;
    Procedure LoadFromStream(Source: TStream; BufferSize: Longint = StreamDefaultBufferSize); virtual;
    Procedure LoadFromFile(Const FileName: TFileName; BufferSize: Longint = StreamDefaultBufferSize); virtual;
    Procedure SaveToStream(Dest: TStream; BufferSize: Longint = StreamDefaultBufferSize); virtual;
    Procedure SaveToFile(Const FileName: TFileName; BufferSize: Longint = StreamDefaultBufferSize); virtual;
  End;
  //=== VCL stream replacements ===
  TJclHandleStream = Class(TJclStream)
  Private
    FHandle: THandle;
  Protected
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Constructor Create(AHandle: THandle);
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    property Handle: THandle read FHandle;
  End;
  TJclFileStream = Class(TJclHandleStream)
  Public
    Constructor Create(Const FileName: TFileName; Mode: Word; Rights: Cardinal = $666);
    Destructor Destroy; override;
  End;
  {
  TJclCustomMemoryStream = class(TJclStream)
  end;
  TJclMemoryStream = class(TJclCustomMemoryStream)
  end;
  TJclStringStream = class(TJclStream)
  end;
  TJclResourceStream = class(TJclCustomMemoryStream)
  end;
  }
  //=== new stream ideas ===
  TJclEmptyStream = Class(TJclStream)
  Protected
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
  End;
  TJclMultiplexStream = Class(TJclStream)
  Private
    FStreams: TList;
    FReadStreamIndex: Integer;
    Function GetStream(Index: Integer): TStream;
    Function GetCount: Integer;
    Procedure SetStream(Index: Integer; Const Value: TStream);
    Function GetReadStream: TStream;
    Procedure SetReadStream(Const Value: TStream);
    Procedure SetReadStreamIndex(Const Value: Integer);
  Protected
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Constructor Create;
    Destructor Destroy; override;
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function Add(NewStream: TStream): Integer;
    Procedure Clear;
    Function Remove(AStream: TStream): Integer;
    Procedure Delete(Const Index: Integer);
    property Streams[Index: Integer]: TStream read GetStream write SetStream;
    property ReadStreamIndex: Integer read FReadStreamIndex write SetReadStreamIndex;
    property ReadStream: TStream read GetReadStream write SetReadStream;
    property Count: Integer read GetCount;
  End;
  TJclStreamDecorator = Class(TJclStream)
  Private
    FAfterStreamChange: TNotifyEvent;
    FBeforeStreamChange: TNotifyEvent;
    FOwnsStream: Boolean;
    FStream: TStream;
    Procedure SetStream(Value: TStream);
  Protected
    Procedure DoAfterStreamChange; virtual;
    Procedure DoBeforeStreamChange; virtual;
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Constructor Create(AStream: TStream; AOwnsStream: Boolean = False);
    Destructor Destroy; override;
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property AfterStreamChange: TNotifyEvent read FAfterStreamChange write FAfterStreamChange;
    property BeforeStreamChange: TNotifyEvent read FBeforeStreamChange write FBeforeStreamChange;
    property OwnsStream: Boolean read FOwnsStream write FOwnsStream;
    property Stream: TStream read FStream write SetStream;
  End;
  TJclBufferedStream = Class(TJclStreamDecorator)
  Protected
    FBuffer: array Of Byte;
    FBufferCurrentSize: Longint;
    FBufferMaxModifiedPos: Longint;
    FBufferSize: Longint;
    FBufferStart: Int64; // position of the first byte of the buffer in stream
    FPosition: Int64; // current position in stream
    Function BufferHit: Boolean;
    Function GetCalcedSize: Int64; virtual;
    Function LoadBuffer: Boolean; virtual;
  Protected
    Procedure DoAfterStreamChange; override;
    Procedure DoBeforeStreamChange; override;
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Constructor Create(AStream: TStream; AOwnsStream: Boolean = False);
    Destructor Destroy; override;
    Procedure Flush; virtual;
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property BufferSize: Longint read FBufferSize write FBufferSize;
  End;
  TStreamNotifyEvent = Procedure(Sender: TObject; Position: Int64; Size: Int64) Of object;
  TJclEventStream = Class(TJclStreamDecorator)
  Private
    FNotification: TStreamNotifyEvent;
    Procedure DoNotification;
  Protected
    Procedure DoBeforeStreamChange; override;
    Procedure DoAfterStreamChange; override;
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Constructor Create(AStream: TStream; ANotification: TStreamNotifyEvent = nil;
      AOwnsStream: Boolean = False);
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property OnNotification: TStreamNotifyEvent read FNotification write FNotification;
  End;
  TJclEasyStream = Class(TJclStreamDecorator)
  Public
    Function IsEqual(Stream: TStream): Boolean;
    Function ReadBoolean: Boolean;
    Function ReadChar: Char;
    Function ReadAnsiChar: DWChar;
    Function ReadWideChar: WideChar;
    Function ReadByte: Byte;
    Function ReadCurrency: Currency;
    Function ReadDateTime: TDateTime;
    Function ReadExtended: Extended;
    Function ReadDouble: Double;
    Function ReadInt64: Int64;
    Function ReadInteger: Integer;
    Function ReadCString: string; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
    Function ReadCAnsiString: DWString;
    Function ReadCWideString: DWWideString;
    Function ReadShortString: string;
    Function ReadSingle: Single;
    Function ReadSizedString: string; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
    Function ReadSizedAnsiString: DWString;
    Function ReadSizedWideString: DWWideString;
    Procedure WriteBoolean(Value: Boolean);
    Procedure WriteChar(Value: Char);
    Procedure WriteAnsiChar(Value: DWChar);
    Procedure WriteWideChar(Value: WideChar);
    Procedure WriteByte(Value: Byte);
    Procedure WriteCurrency(Const Value: Currency);
    Procedure WriteDateTime(Const Value: TDateTime);
    Procedure WriteExtended(Const Value: Extended);
    Procedure WriteDouble(Const Value: Double);
    Procedure WriteInt64(Value: Int64); overload;
    Procedure WriteInteger(Value: Integer); overload;
    Procedure WriteCString(Const Value: string); {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
    Procedure WriteCAnsiString(Const Value: DWString);
    Procedure WriteCWideString(Const Value: DWWideString);
    // use WriteCString
    Procedure WriteSingle(Const Value: Single);
    Procedure WriteSizedString(Const Value: string); {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
    Procedure WriteSizedAnsiString(Const Value: DWString);
    Procedure WriteSizedWideString(Const Value: DWWideString);
  End;
  TJclScopedStream = Class(TJclStream)
  Private
    FParentStream: TStream;
    FStartPos: Int64;
    FCurrentPos: Int64;
    FMaxSize: Int64;
  Protected
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    // scopedstream starting at the current position of the ParentStream
    //   if MaxSize is positive or null, read and write operations cannot overrun this size or the ParentStream limitation
    //   if MaxSize is negative, read and write operations are unlimited (up to the ParentStream limitation)
    Constructor Create(AParentStream: TStream; Const AMaxSize: Int64 = -1); overload;
    Constructor Create(AParentStream: TStream; Const AStartPos, AMaxSize: Int64); overload;
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property ParentStream: TStream read FParentStream;
    property StartPos: Int64 read FStartPos;
    property MaxSize: Int64 read FMaxSize write FMaxSize;
  End;
  TJclStreamSeekEvent = Function(Sender: TObject; Const Offset: Int64;
    Origin: TSeekOrigin): Int64 Of object;
  TJclStreamReadEvent = Function(Sender: TObject; Var Buffer; Count: Longint): Longint Of object;
  TJclStreamWriteEvent = Function(Sender: TObject; Const Buffer;Count: Longint): Longint Of object;
  TJclStreamSizeEvent = Procedure(Sender: TObject; Const NewSize: Int64) Of object;
  TJclDelegatedStream = Class(TJclStream)
  Private
    FOnSeek: TJclStreamSeekEvent;
    FOnRead: TJclStreamReadEvent;
    FOnWrite: TJclStreamWriteEvent;
    FOnSize: TJclStreamSizeEvent;
  Protected
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    property OnSeek: TJclStreamSeekEvent read FOnSeek write FOnSeek;
    property OnRead: TJclStreamReadEvent read FOnRead write FOnRead;
    property OnWrite: TJclStreamWriteEvent read FOnWrite write FOnWrite;
    property OnSize: TJclStreamSizeEvent read FOnSize write FOnSize;
  End;
  // ancestor classes for streams with checksums and encrypted streams
  // data are stored in sectors: each BufferSize-d buffer is followed by FSectorOverHead bytes
  // containing the checksum. In case of an encrypted stream, there is no byte
  // but sector is encrypted
  // reusing some code from TJclBufferedStream
  TJclSectoredStream = Class(TJclBufferedStream)
  Protected
    FSectorOverHead: Longint;
    Function FlatToSectored(Const Position: Int64): Int64;
    Function SectoredToFlat(Const Position: Int64): Int64;
    Function GetCalcedSize: Int64; override;
    Function LoadBuffer: Boolean; override;
    Procedure DoAfterStreamChange; override;
    Procedure AfterBlockRead; virtual;   // override to check protection
    Procedure BeforeBlockWrite; virtual; // override to compute protection
    Procedure SetSize(Const NewSize: Int64); override;
  Public
    Constructor Create(AStorageStream: TStream; AOwnsStream: Boolean = False;
      ASectorOverHead: Longint = 0);
    Procedure Flush; override;
  End;
  TJclCRC16Stream = Class(TJclSectoredStream)
  Protected
    Procedure AfterBlockRead; override;
    Procedure BeforeBlockWrite; override;
  Public
    Constructor Create(AStorageStream: TStream; AOwnsStream: Boolean = False);
  End;
  TJclCRC32Stream = Class(TJclSectoredStream)
  Protected
    Procedure AfterBlockRead; override;
    Procedure BeforeBlockWrite; override;
  Public
    Constructor Create(AStorageStream: TStream; AOwnsStream: Boolean = False);
  End;
  {$IFDEF COMPILER7_UP}
    {$DEFINE SIZE64}
  {$ENDIF ~COMPILER7_UP}
  {$IFDEF FPC}
    {$DEFINE SIZE64}
  {$ENDIF FPC}
  TJclSplitStream = Class(TJclStream)
  Private
    FVolume: TStream;
    FVolumeIndex: Integer;
    FVolumeMaxSize: Int64;
    FPosition: Int64;
    FVolumePosition: Int64;
    FForcePosition: Boolean;
  Protected
    Function GetVolume(Index: Integer): TStream; virtual; abstract;
    Function GetVolumeMaxSize(Index: Integer): Int64; virtual; abstract;
    Function GetSize: Int64; {$IFDEF SIZE64}override;{$ENDIF SIZE64}
    Procedure SetSize(Const NewSize: Int64); override;
    Function InternalLoadVolume(Index: Integer): Boolean;
  Public
    Constructor Create(AForcePosition: Boolean = False);
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    Function Read(Var Buffer; Count: Longint): Longint; override;
    Function Write(Const Buffer; Count: Longint): Longint; override;
    property ForcePosition: Boolean read FForcePosition write FForcePosition;
  End;
  TJclVolumeEvent = Function(Index: Integer): TStream Of object;
  TJclVolumeMaxSizeEvent = Function(Index: Integer): Int64 Of object;
  TJclDynamicSplitStream = Class(TJclSplitStream)
  Private
    FOnVolume: TJclVolumeEvent;
    FOnVolumeMaxSize: TJclVolumeMaxSizeEvent;
  Protected
    Function GetVolume(Index: Integer): TStream; override;
    Function GetVolumeMaxSize(Index: Integer): Int64; override;
  Public
    property OnVolume: TJclVolumeEvent read FOnVolume write FOnVolume;
    property OnVolumeMaxSize: TJclVolumeMaxSizeEvent read FOnVolumeMaxSize
      write FOnVolumeMaxSize;
  End;
  TJclSplitVolume = Class
  Public
    MaxSize: Int64;
    Stream: TStream;
    OwnStream: Boolean;
  End;
  TJclStaticSplitStream = Class(TJclSplitStream)
  Private
    FVolumes: TObjectList;
    Function GetVolumeCount: Integer;
  Protected
    Function GetVolume(Index: Integer): TStream; override;
    Function GetVolumeMaxSize(Index: Integer): Int64; override;
  Public
    Constructor Create(AForcePosition: Boolean = False);
    Destructor Destroy; override;
    Function AddVolume(AStream: TStream; AMaxSize: Int64 = 0;
      AOwnStream: Boolean = False): Integer;
    property VolumeCount: Integer read GetVolumeCount;
    property Volumes[Index: Integer]: TStream read GetVolume;
    property VolumeMaxSizes[Index: Integer]: Int64 read GetVolumeMaxSize;
  End;
  TJclStringStream = Class
  Protected
    FStream: TStream;
    FOwnStream: Boolean;
    FBOM: array Of Byte;
    FBufferSize: SizeInt;
    FStrPosition: Int64; // current position in characters
    FStrBuffer: TUCS4Array; // buffer for read/write operations
    FStrBufferPosition: Int64; // position of the first character of the read/write buffer
    FStrBufferCurrentSize: Int64; // numbers of characters available in str buffer
    FStrBufferModifiedSize: Int64; // numbers of characters modified in str buffer
    FStrBufferStart: Int64; // position of the first byte of the read/write buffer in stream
    FStrBufferNext: Int64; // position of the next character following the read/write buffer in stream
    FStrPeekPosition: Int64; // current peek position in characters
    FStrPeekBuffer: TUCS4Array; // buffer for peek operations
    FStrPeekBufferPosition: Int64; // index of the first character of the peek buffer
    FStrPeekBufferCurrentSize: SizeInt; // numbers of characters available in peek buffer
    FStrPeekBufferStart: Int64; // position of the first byte of the peek buffer in stream
    FStrPeekBufferNext: Int64; // position of the next character following the peek buffer in stream
    Function LoadBuffer: Boolean;
    Function LoadPeekBuffer: Boolean;
    Function InternalGetNextChar(S: TStream; out Ch: UCS4): Boolean; virtual; abstract;
    Function InternalGetNextBuffer(S: TStream; Var Buffer: TUCS4Array; Start, Count: SizeInt): Longint; virtual;
    Function InternalSetNextChar(S: TStream; Ch: UCS4): Boolean; virtual; abstract;
    Function InternalSetNextBuffer(S: TStream; Const Buffer: TUCS4Array; Start, Count: SizeInt): Longint; virtual;
    Procedure InvalidateBuffers;
  Public
    Constructor Create(AStream: TStream; AOwnsStream: Boolean = False); virtual;
    Destructor Destroy; override;
    Procedure Flush; virtual;
    Function Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    Function PeekUCS4(out Buffer: UCS4): Boolean;
    Function PeekWideChar(out Buffer: WideChar): Boolean;
    Function ReadUCS4(out Buffer: UCS4): Boolean;
    Function ReadWideChar(out Buffer: WideChar): Boolean;
    Function WriteUCS4(Value: UCS4): Boolean;
    Function WriteWideChar(Value: WideChar): Boolean;
    Function SkipBOM: LongInt; virtual;
    Function WriteBOM: Longint; virtual;
    property BufferSize: SizeInt read FBufferSize write FBufferSize;
    property PeekPosition: Int64 read FStrPeekPosition;
    property Position: Int64 read FStrPosition;
    property Stream: TStream read FStream;
    property OwnStream: Boolean read FOwnStream;
  End;
  TJclStringStreamClass = Class Of TJclStringStream;
  TJclAnsiStream = Class(TJclStringStream)
  Private
    FCodePage: Word;
  Protected
  Public
    Constructor Create(AStream: TStream; AOwnsStream: Boolean = False); override;
    property CodePage: Word read FCodePage write FCodePage;
  End;
  TJclUTF8Stream = Class(TJclStringStream)
  Protected
  Public
    Constructor Create(AStream: TStream; AOwnsStream: Boolean = False); override;
  End;
  TJclUTF16Stream = Class(TJclStringStream)
  Protected
  Public
    Constructor Create(AStream: TStream; AOwnsStream: Boolean = False); override;
  End;
  TJclStringEncoding = (seAnsi, seUTF8, seUTF16, seAuto);
  TJclAutoStream = Class(TJclStringStream)
  Private
    FCodePage: Word;
    FEncoding: TJclStringEncoding;
    Procedure SetCodePage(Value: Word);
  Protected
  Public
    Constructor Create(AStream: TStream; AOwnsStream: Boolean = False); override;
    Function SkipBOM: LongInt; override;
    property CodePage: Word read FCodePage write SetCodePage;
    property Encoding: TJclStringEncoding read FEncoding;
  End;
// buffered copy of all available bytes from Source to Dest
// returns the number of bytes that were copied
Function StreamCopy(Source: TStream; Dest: TStream; BufferSize: Longint = StreamDefaultBufferSize): Int64;
Function CompareStreams(A, B : TStream; BufferSize: Longint = StreamDefaultBufferSize): Boolean;
// compares 2 files for differencies (calling CompareStreams)
Function CompareFiles(Const FileA, FileB: TFileName; BufferSize: Longint = StreamDefaultBufferSize): Boolean;
Implementation
Uses
  {$IFDEF HAS_UNITSCOPE}
  System.Types,
  {$ENDIF HAS_UNITSCOPE}
  uRESTDWMemResources,
  uRESTDWMemCharsets;

Function StreamCopy(Source: TStream; Dest: TStream; BufferSize: Longint): Int64;
Var
  Buffer: array Of Byte;
  ByteCount: Longint;
Begin
  Result := 0;
  SetLength(Buffer, BufferSize);
  Repeat
    ByteCount := Source.Read(Buffer[0], BufferSize);
    Result := Result + ByteCount;
    Dest.WriteBuffer(Buffer[0], ByteCount);
  Until ByteCount < BufferSize;
End;
Function CompareStreams(A, B : TStream; BufferSize: Longint): Boolean;
Var
  BufferA, BufferB: array Of Byte;
  ByteCountA, ByteCountB: Longint;
Begin
  SetLength(BufferA, BufferSize);
  Try
    SetLength(BufferB, BufferSize);
    Try
      Repeat
        ByteCountA := A.Read(BufferA[0], BufferSize);
        ByteCountB := B.Read(BufferB[0], BufferSize);
        Result := (ByteCountA = ByteCountB);
        Result := Result and CompareMem(BufferA, BufferB, ByteCountA);
      Until (ByteCountA <> BufferSize) or (ByteCountB <> BufferSize) or not Result;
    Finally
      SetLength(BufferB, 0);
    End;
  Finally
    SetLength(BufferA, 0);
  End;
End;
Function CompareFiles(Const FileA, FileB: TFileName; BufferSize: Longint): Boolean;
Var
  A, B: TStream;
Begin
  A := TFileStream.Create(FileA, fmOpenRead or fmShareDenyWrite);
  Try
    B := TFileStream.Create(FileB, fmOpenRead or fmShareDenyWrite);
    Try
      Result := CompareStreams(A, B, BufferSize);
    Finally
      B.Free;
    End;
  Finally
    A.Free;
  End;
End;
//=== { TJclStream } =========================================================
Function TJclStream.Seek(Offset: Longint; Origin: Word): Longint;
Var
  Result64: Int64;
Begin
  Case Origin Of
    soFromBeginning:
      Result64 := Seek(Int64(Offset), soBeginning);
    soFromCurrent:
      Result64 := Seek(Int64(Offset), soCurrent);
    soFromEnd:
      Result64 := Seek(Int64(Offset), soEnd);
  Else
    Result64 := -1;
  End;
  If (Result64 < 0) or (Result64 > High(Longint)) Then
    Result64 := -1;
  Result := Result64;
End;
Procedure TJclStream.LoadFromFile(Const FileName: TFileName;
  BufferSize: Longint = StreamDefaultBufferSize);
Var
  FS: TStream;
Begin
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Try
    LoadFromStream(FS, BufferSize);
  Finally
    FS.Free;
  End;
End;
Procedure TJclStream.LoadFromStream(Source: TStream; BufferSize: Longint = StreamDefaultBufferSize);
Begin
  StreamCopy(Source, Self, BufferSize);
End;
Procedure TJclStream.SaveToFile(Const FileName: TFileName; BufferSize: Longint = StreamDefaultBufferSize);
Var
  FS: TStream;
Begin
  FS := TFileStream.Create(FileName, fmCreate);
  Try
    SaveToStream(FS, BufferSize);
  Finally
    FS.Free;
  End;
End;
Procedure TJclStream.SaveToStream(Dest: TStream; BufferSize: Longint = StreamDefaultBufferSize);
Begin
  StreamCopy(Self, Dest, BufferSize);
End;
Procedure TJclStream.SetSize(NewSize: Longint);
Begin
  SetSize(Int64(NewSize));
End;
Procedure TJclStream.SetSize(Const NewSize: Int64);
Begin
  // override to customize
End;
//=== { TJclHandleStream } ===================================================
Constructor TJclHandleStream.Create(AHandle: THandle);
Begin
  Inherited Create;
  FHandle := AHandle;
End;
Function TJclHandleStream.Read(Var Buffer; Count: Longint): Longint;
Begin
  Result := 0;
  {$IFDEF MSWINDOWS}
  If (Count <= 0) or not ReadFile(Handle, Buffer, DWORD(Count), DWORD(Result), nil) Then
    Result := 0;
  {$ENDIF MSWINDOWS}
  {$IFDEF LINUX}
    {$IFDEF RESTDWLINUX}
    Result := __read(Handle, @Buffer, Count);
    {$ELSE}
       Result := __read(Handle, Buffer, Count);
    {$ENDIF}
  {$ENDIF LINUX}
End;
Function TJclHandleStream.Write(Const Buffer; Count: Longint): Longint;
Begin
  Result := 0;
  {$IFDEF MSWINDOWS}
  If (Count <= 0) or not WriteFile(Handle, Buffer, DWORD(Count), DWORD(Result), nil) Then
    Result := 0;
  {$ENDIF MSWINDOWS}
  {$IFDEF LINUX}
  {$IFDEF RESTDWLINUX}
    Result := __write(Handle, @Buffer, Count);
    //Result := 0;
    {$ELSE}
  Result := __write(Handle, Buffer, Count);
  {$ENDIF}
  {$ENDIF LINUX}
End;
Procedure TJclHandleStream.SetSize(Const NewSize: Int64);
Begin
  Seek(NewSize, soBeginning);
  {$IFDEF MSWINDOWS}
  If not SetEndOfFile(Handle) Then
    RaiseLastOSError;
  {$ENDIF MSWINDOWS}
  {$IFDEF LINUX}
   {$IFDEF RESTDWLINUX}
    If ftruncate(Handle, Position) = -1 Then
    raise EJclStreamError.CreateRes(@RsStreamsSetSizeError);
   {$ELSE}
  If ftruncate(Handle, Position) = -1 Then
    raise EJclStreamError.CreateRes(@RsStreamsSetSizeError);
  {$ENDIF}
  {$ENDIF LINUX}
End;
//=== { TJclFileStream } =====================================================
Constructor TJclFileStream.Create(Const FileName: TFileName; Mode: Word; Rights: Cardinal);
Var
  H: THandle;
{$IFDEF LINUX}
Const
  INVALID_HANDLE_VALUE = -1;
{$ENDIF LINUX}
Begin
  If Mode = fmCreate Then
  Begin
    {$IFDEF LINUX}
    {$IFDEF RESTDWLINUX}
       H := FileCreate(PChar(FileName), Mode, Rights);
      {$ELSE}

      H := open(PChar(FileName), O_CREAT or O_RDWR, Rights);
    {$ENDIF}
    {$ENDIF LINUX}
    {$IFDEF MSWINDOWS}
    H := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
      0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    {$ENDIF MSWINDOWS}
    Inherited Create(H);
    If Handle = INVALID_HANDLE_VALUE Then
      raise EJclStreamError.CreateResFmt(@RsStreamsCreateError, [FileName]);
  End
  Else
  Begin
    H := THandle(FileOpen(FileName, Mode));
    Inherited Create(H);
    If Handle = INVALID_HANDLE_VALUE Then
      raise EJclStreamError.CreateResFmt(@RsStreamsOpenError, [FileName]);
  End;
End;
Destructor TJclFileStream.Destroy;
Begin
  {$IFDEF MSWINDOWS}
  If Handle <> INVALID_HANDLE_VALUE Then
    CloseHandle(Handle);
  {$ENDIF MSWINDOWS}
  {$IFDEF LINUX}
  __close(Handle);
  {$ENDIF LINUX}
  Inherited Destroy;
End;
//=== { TJclEmptyStream } ====================================================
// a stream which stays empty no matter what you do
// so it is a Unix /dev/null equivalent
Procedure TJclEmptyStream.SetSize(Const NewSize: Int64);
Begin
  // nothing
End;
Function TJclEmptyStream.Read(Var Buffer; Count: Longint): Longint;
Begin
  // you cannot read anything
  Result := 0;
End;
Function TJclEmptyStream.Write(Const Buffer; Count: Longint): Longint;
Begin
  // you cannot write anything
  Result := 0;
End;
Function TJclEmptyStream.Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64;
Begin
  If Offset <> 0 Then
    // seeking to anywhere except the position 0 is an error
    Result := -1
  Else
    Result := 0;
End;
//=== { TJclMultiplexStream } ================================================
Constructor TJclMultiplexStream.Create;
Begin
  Inherited Create;
  FStreams := TList.Create;
  FReadStreamIndex := -1;
End;
Destructor TJclMultiplexStream.Destroy;
Begin
  FStreams.Free;
  Inherited Destroy;
End;
Function TJclMultiplexStream.Add(NewStream: TStream): Integer;
Begin
  Result := FStreams.Add(Pointer(NewStream));
End;
Procedure TJclMultiplexStream.Clear;
Begin
  FStreams.Clear;
  FReadStreamIndex := -1;
End;
Procedure TJclMultiplexStream.Delete(Const Index: Integer);
Begin
  FStreams.Delete(Index);
  If ReadStreamIndex = Index Then
    FReadStreamIndex := -1
  Else
  If ReadStreamIndex > Index Then
    Dec(FReadStreamIndex);
End;
Function TJclMultiplexStream.GetReadStream: TStream;
Begin
  If FReadStreamIndex >= 0 Then
    Result := TStream(FStreams.Items[FReadStreamIndex])
  Else
    Result := nil;
End;
Function TJclMultiplexStream.GetStream(Index: Integer): TStream;
Begin
  Result := TStream(FStreams.Items[Index]);
End;
Function TJclMultiplexStream.GetCount: Integer;
Begin
  Result := FStreams.Count;
End;
Function TJclMultiplexStream.Read(Var Buffer; Count: Longint): Longint;
Var
  Stream: TStream;
Begin
  Stream := ReadStream;
  If Assigned(Stream) Then
    Result := Stream.Read(Buffer, Count)
  Else
    Result := 0;
End;
Function TJclMultiplexStream.Remove(AStream: TStream): Integer;
Begin
  Result := FStreams.Remove(Pointer(AStream));
  If FReadStreamIndex = Result Then
    FReadStreamIndex := -1
  Else
  If FReadStreamIndex > Result Then
    Dec(FReadStreamIndex);
End;
Function TJclMultiplexStream.Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64;
Begin
  // what should this function do?
  Result := -1;
End;
Procedure TJclMultiplexStream.SetReadStream(Const Value: TStream);
Begin
  FReadStreamIndex := FStreams.IndexOf(Pointer(Value));
End;
Procedure TJclMultiplexStream.SetReadStreamIndex(Const Value: Integer);
Begin
  FReadStreamIndex := Value;
End;
Procedure TJclMultiplexStream.SetSize(Const NewSize: Int64);
Begin
  // what should this function do?
End;
Procedure TJclMultiplexStream.SetStream(Index: Integer; Const Value: TStream);
Begin
  FStreams.Items[Index] := Pointer(Value);
End;
Function TJclMultiplexStream.Write(Const Buffer; Count: Longint): Longint;
Var
  Index: Integer;
  ByteWritten, MinByteWritten: Longint;
Begin
  MinByteWritten := Count;
  For Index := 0 To Self.Count - 1 Do
  Begin
    ByteWritten := TStream(FStreams.Items[Index]).Write(Buffer, Count);
    If ByteWritten < MinByteWritten Then
      MinByteWritten := ByteWritten;
  End;
  Result := MinByteWritten;
End;
//=== { TJclStreamDecorator } ================================================
Constructor TJclStreamDecorator.Create(AStream: TStream; AOwnsStream: Boolean = False);
Begin
  Inherited Create;
  FStream := AStream;
  FOwnsStream := AOwnsStream;
End;
Destructor TJclStreamDecorator.Destroy;
Begin
  If OwnsStream Then
    FStream.Free;
  Inherited Destroy;
End;
Procedure TJclStreamDecorator.DoAfterStreamChange;
Begin
  If Assigned(FAfterStreamChange) Then
    FAfterStreamChange(Self);
End;
Procedure TJclStreamDecorator.DoBeforeStreamChange;
Begin
  If Assigned(FBeforeStreamChange) Then
    FBeforeStreamChange(Self);
End;
Function TJclStreamDecorator.Read(Var Buffer; Count: Longint): Longint;
Begin
  If Assigned(FStream) Then
    Result := Stream.Read(Buffer, Count)
  Else
    Result := 0;
End;
Function TJclStreamDecorator.Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64;
Begin
  Result := Stream.Seek(Offset, Origin);
End;
Procedure TJclStreamDecorator.SetSize(Const NewSize: Int64);
Begin
  If Assigned(FStream) Then
    Stream.Size := NewSize;
End;
Procedure TJclStreamDecorator.SetStream(Value: TStream);
Begin
  If Value <> FStream Then
    Try
      DoBeforeStreamChange;
    Finally
      If OwnsStream Then
        FStream.Free;
      FStream := Value;
      DoAfterStreamChange;
    End;
End;
Function TJclStreamDecorator.Write(Const Buffer; Count: Longint): Longint;
Begin
  If Assigned(FStream) Then
    Result := Stream.Write(Buffer, Count)
  Else
    Result := 0;
End;
//=== { TJclBufferedStream } =================================================
Constructor TJclBufferedStream.Create(AStream: TStream; AOwnsStream: Boolean = False);
Begin
  Inherited Create(AStream, AOwnsStream);
  If Stream <> nil Then
    FPosition := Stream.Position;
  BufferSize := StreamDefaultBufferSize;
  LoadBuffer;
End;
Destructor TJclBufferedStream.Destroy;
Begin
  Flush;
  Inherited Destroy;
End;
Function TJclBufferedStream.BufferHit: Boolean;
Begin
  Result := (FBufferStart <= FPosition) and (FPosition < (FBufferStart + FBufferCurrentSize));
End;
Procedure TJclBufferedStream.DoAfterStreamChange;
Begin
  Inherited DoAfterStreamChange;
  FBufferCurrentSize := 0; // invalidate buffer after stream is changed
  FBufferStart := 0;
  If Stream <> nil Then
    FPosition := Stream.Position;
End;
Procedure TJclBufferedStream.DoBeforeStreamChange;
Begin
  Inherited DoBeforeStreamChange;
  Flush;
End;
Procedure TJclBufferedStream.Flush;
Begin
  If (Stream <> nil) and (FBufferMaxModifiedPos > 0) Then
  Begin
    Stream.Position := FBufferStart;
    Stream.WriteBuffer(FBuffer[0], FBufferMaxModifiedPos);
    FBufferMaxModifiedPos := 0;
  End;
End;
Function TJclBufferedStream.GetCalcedSize: Int64;
Begin
  If Assigned(Stream) Then
    Result := Stream.Size
  Else
    Result := 0;
  If Result < FBufferMaxModifiedPos + FBufferStart Then
    Result := FBufferMaxModifiedPos + FBufferStart;
End;
Function TJclBufferedStream.LoadBuffer: Boolean;
Begin
  Flush;
  If Length(FBuffer) <> FBufferSize Then
    SetLength(FBuffer, FBufferSize);
  If Stream <> nil Then
  Begin
    Stream.Position := FPosition;
    FBufferCurrentSize := Stream.Read(FBuffer[0], FBufferSize);
  End
  Else
    FBufferCurrentSize := 0;
  FBufferStart := FPosition;
  Result := (FBufferCurrentSize > 0);
End;
Function TJclBufferedStream.Seek(Const Offset: Int64;
  Origin: TSeekOrigin): Int64;
Var
  NewPos: Int64;
Begin
  NewPos := FPosition;
  Case Origin Of
    soBeginning:
      NewPos := Offset;
    soCurrent:
      Inc(NewPos, Offset);
    soEnd:
      NewPos := GetCalcedSize + Offset;
  Else
    NewPos := -1;
  End;
  If NewPos < 0 Then
    NewPos := -1
  Else
    FPosition := NewPos;
  Result := NewPos;
End;
Procedure TJclBufferedStream.SetSize(Const NewSize: Int64);
Begin
  Inherited SetSize(NewSize);
  If NewSize < (FBufferStart + FBufferMaxModifiedPos) Then
  Begin
    FBufferMaxModifiedPos := NewSize - FBufferStart;
    If FBufferMaxModifiedPos < 0 Then
      FBufferMaxModifiedPos := 0;
  End;
  If NewSize < (FBufferStart + FBufferCurrentSize) Then
  Begin
    FBufferCurrentSize := NewSize - FBufferStart;
    If FBufferCurrentSize < 0 Then
      FBufferCurrentSize := 0;
  End;
  // fix from Marcelo Rocha
  If Stream <> nil Then
    FPosition := Stream.Position;
End;
//=== { TJclEventStream } ====================================================
Constructor TJclEventStream.Create(AStream: TStream; ANotification:
  TStreamNotifyEvent = nil; AOwnsStream: Boolean = False);
Begin
  Inherited Create(AStream, AOwnsStream);
  FNotification := ANotification;
End;
Procedure TJclEventStream.DoAfterStreamChange;
Begin
  Inherited DoAfterStreamChange;
  If Stream <> nil Then
    DoNotification;
End;
Procedure TJclEventStream.DoBeforeStreamChange;
Begin
  Inherited DoBeforeStreamChange;
  If Stream <> nil Then
    DoNotification;
End;
Procedure TJclEventStream.DoNotification;
Begin
  If Assigned(FNotification) Then
    FNotification(Self, Stream.Position, Stream.Size);
End;
Function TJclEventStream.Read(Var Buffer; Count: Longint): Longint;
Begin
  Result := Inherited Read(Buffer, Count);
  DoNotification;
End;
Function TJclEventStream.Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64;
Begin
  Result := Inherited Seek(Offset, Origin);
  DoNotification;
End;
Procedure TJclEventStream.SetSize(Const NewSize: Int64);
Begin
  Inherited SetSize(NewSize);
  DoNotification;
End;
Function TJclEventStream.Write(Const Buffer; Count: Longint): Longint;
Begin
  Result := Inherited Write(Buffer, Count);
  DoNotification;
End;
//=== { TJclEasyStream } =====================================================
Function TJclEasyStream.IsEqual(Stream: TStream): Boolean;
Var
  SavePos, StreamSavePos: Int64;
Begin
  SavePos := Position;
  StreamSavePos := Stream.Position;
  Try
    Position := 0;
    Stream.Position := 0;
    Result := CompareStreams(Self, Stream);
  Finally
    Position := SavePos;
    Stream.Position := StreamSavePos;
  End;
End;
Function TJclEasyStream.ReadBoolean: Boolean;
Begin
  Result := False;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadChar: Char;
Begin
  Result := #0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadAnsiChar: DWChar;
Begin
  Result := #0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadWideChar: WideChar;
Begin
  Result := #0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadByte: Byte;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadCurrency: Currency;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadDateTime: TDateTime;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadDouble: Double;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadExtended: Extended;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadInt64: Int64;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadInteger: Integer;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadCString: string;
Begin
  {$IFDEF SUPPORTS_UNICODE}
  Result := ReadCWideString;
  {$ELSE ~SUPPORTS_UNICODE}
  Result := ReadCAnsiString;
  {$ENDIF ~SUPPORTS_UNICODE}
End;
Function TJclEasyStream.ReadCAnsiString: DWString;
Var
  CurrPos: Longint;
  StrSize: Integer;
Begin
  CurrPos := Position;
  Repeat
  Until ReadAnsiChar = #0;
  StrSize := Position - CurrPos;                       // Get number of bytes
  SetLength(Result, StrSize div SizeOf(Char) - 1); // Set number of chars without #0
  Position := CurrPos;                                 // Seek to start read
  ReadBuffer(Result[1], StrSize);                      // Read ansi data and #0
End;
Function TJclEasyStream.ReadCWideString: DWWideString;
Var
  CurrPos: Integer;
  StrSize: Integer;
Begin
  CurrPos := Position;
  Repeat
  Until ReadWideChar = #0;
  StrSize := Position - CurrPos;                       // Get number of bytes
  SetLength(Result, StrSize div SizeOf(WideChar) - 1); // Set number of chars without #0
  Position := CurrPos;                                 // Seek to start read
  ReadBuffer(Result[1], StrSize);                      // Read wide data and #0
End;
Function TJclEasyStream.ReadShortString: string;
Var
  StrSize: Integer;
Begin
  StrSize := Ord(ReadChar);
  SetString(Result, PChar(nil), StrSize);
  ReadBuffer(Pointer(Result)^, StrSize);
End;
Function TJclEasyStream.ReadSingle: Single;
Begin
  Result := 0;
  ReadBuffer(Result, SizeOf(Result));
End;
Function TJclEasyStream.ReadSizedString: string;
Begin
  {$IFDEF SUPPORTS_UNICODE}
  Result := ReadSizedWideString;
  {$ELSE ~SUPPORTS_UNICODE}
  Result := ReadSizedAnsiString;
  {$ENDIF ~SUPPORTS_UNICODE}
End;
Function TJclEasyStream.ReadSizedAnsiString: DWString;
Var
  StrSize: Integer;
Begin
  StrSize := ReadInteger;
  SetLength(Result, StrSize);
  ReadBuffer(Result[1], StrSize * SizeOf(Result[1]));
End;
Function TJclEasyStream.ReadSizedWideString: DWWideString;
Var
  StrSize: Integer;
Begin
  StrSize := ReadInteger;
  SetLength(Result, StrSize);
  ReadBuffer(Result[1], StrSize * SizeOf(Result[1]));
End;
Procedure TJclEasyStream.WriteBoolean(Value: Boolean);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteChar(Value: Char);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteAnsiChar(Value: DWChar);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteWideChar(Value: WideChar);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteByte(Value: Byte);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteCurrency(Const Value: Currency);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteDateTime(Const Value: TDateTime);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteDouble(Const Value: Double);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteExtended(Const Value: Extended);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteInt64(Value: Int64);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteInteger(Value: Integer);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteCString(Const Value: string);
Begin
  {$IFDEF SUPPORTS_UNICODE}
  WriteCWideString(Value);
  {$ELSE ~SUPPORTS_UNICODE}
  WriteCAnsiString(Value);
  {$ENDIF ~SUPPORTS_UNICODE}
End;
Procedure TJclEasyStream.WriteCAnsiString(Const Value: DWString);
Var
  StrSize: Integer;
Begin
  StrSize := Length(Value);
  WriteBuffer(Value[1], (StrSize + 1) * SizeOf(Value[1]));
End;
Procedure TJclEasyStream.WriteCWideString(Const Value: DWWideString);
Var
  StrSize: Integer;
Begin
  StrSize := Length(Value);
  WriteBuffer(Value[1], (StrSize + 1) * SizeOf(Value[1]));
End;
Procedure TJclEasyStream.WriteSingle(Const Value: Single);
Begin
  WriteBuffer(Value, SizeOf(Value));
End;
Procedure TJclEasyStream.WriteSizedString(Const Value: string);
Begin
  {$IFDEF SUPPORTS_UNICODE}
  WriteSizedWideString(Value);
  {$ELSE ~SUPPORTS_UNICODE}
  WriteSizedAnsiString(Value);
  {$ENDIF ~SUPPORTS_UNICODE}
End;
Procedure TJclEasyStream.WriteSizedAnsiString(Const Value: DWString);
Var
  StrSize: Integer;
Begin
  StrSize := Length(Value);
  WriteInteger(StrSize);
  WriteBuffer(Value[1], StrSize * SizeOf(Value[1]));
End;
Procedure TJclEasyStream.WriteSizedWideString(Const Value: DWWideString);
Var
  StrSize: Integer;
Begin
  StrSize := Length(Value);
  WriteInteger(StrSize);
  WriteBuffer(Value[1], StrSize * SizeOf(Value[1]));
End;
//=== { TJclScopedStream } ===================================================
Constructor TJclScopedStream.Create(AParentStream: TStream; Const AMaxSize: Int64);
Begin
  Inherited Create;
  FParentStream := AParentStream;
  FStartPos := ParentStream.Position;
  FCurrentPos := 0;
  FMaxSize := AMaxSize;
End;
Constructor TJclScopedStream.Create(AParentStream: TStream; Const AStartPos, AMaxSize: Int64);
Begin
  Inherited Create;
  FParentStream := AParentStream;
  FStartPos := AStartPos;
  FCurrentPos := 0;
  FMaxSize := AMaxSize;
End;
Function TJclScopedStream.Read(Var Buffer; Count: Longint): Longint;
Begin
  If (MaxSize >= 0) and ((FCurrentPos + Count) > MaxSize) Then
    Count := MaxSize - FCurrentPos;
  If (Count > 0) and Assigned(ParentStream) Then
  Begin
    Result := ParentStream.Read(Buffer, Count);
    Inc(FCurrentPos, Result);
  End
  Else
    Result := 0;
End;
Function TJclScopedStream.Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64;
Begin
  Case Origin Of
    soBeginning:
      Begin
        If (Offset < 0) or ((MaxSize >= 0) and (Offset > MaxSize)) Then
          Result := -1            // low and high bound check
        Else
          Result := ParentStream.Seek(StartPos + Offset, soBeginning) - StartPos;
      End;
    soCurrent:
      Begin
        If Offset = 0 Then
          Result := FCurrentPos   // speeding the Position property up
        Else If ((FCurrentPos + Offset) < 0) or ((MaxSize >= 0)
          and ((FCurrentPos + Offset) > MaxSize)) Then
          Result := -1            // low and high bound check
        Else
          Result := ParentStream.Seek(Offset, soCurrent) - StartPos;
      End;
    soEnd:
      Begin
        If (MaxSize >= 0) Then
        Begin
          If (Offset > 0) or (MaxSize < -Offset) Then // low and high bound check
            Result := -1
          Else
            Result := ParentStream.Seek(StartPos + MaxSize + Offset, soBeginning) - StartPos;
        End
        Else
        Begin
          Result := ParentStream.Seek(Offset, soEnd);
          If (Result <> -1) and (Result < StartPos) Then // low bound check
          Begin
            Result := -1;
            ParentStream.Seek(StartPos + FCurrentPos, soBeginning);
          End;
        End;
      End;
    Else
      Result := -1;
  End;
  If Result <> -1 Then
    FCurrentPos := Result;
End;
Procedure TJclScopedStream.SetSize(Const NewSize: Int64);
Var
  ScopedNewSize: Int64;
Begin
  If (FMaxSize >= 0) and (NewSize >= (FStartPos + FMaxSize)) Then
    ScopedNewSize := FMaxSize + FStartPos
  Else
    ScopedNewSize := NewSize;
  Inherited SetSize(ScopedNewSize);
End;
Function TJclScopedStream.Write(Const Buffer; Count: Longint): Longint;
Begin
  If (MaxSize >= 0) and ((FCurrentPos + Count) > MaxSize) Then
    Count := MaxSize - FCurrentPos;
  If (Count > 0) and Assigned(ParentStream) Then
  Begin
    Result := ParentStream.Write(Buffer, Count);
    Inc(FCurrentPos, Result);
  End
  Else
    Result := 0;
End;
//=== { TJclDelegateStream } =================================================
Procedure TJclDelegatedStream.SetSize(Const NewSize: Int64);
Begin
  If Assigned(FOnSize) Then
    FOnSize(Self, NewSize);
End;
Function TJclDelegatedStream.Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64;
Begin
  If Assigned(FOnSeek) Then
    Result := FOnSeek(Self, Offset, Origin)
  Else
    Result := -1;
End;
Function TJclDelegatedStream.Read(Var Buffer; Count: Longint): Longint;
Begin
  If Assigned(FOnRead) Then
    Result := FOnRead(Self, Buffer, Count)
  Else
    Result := -1;
End;
Function TJclDelegatedStream.Write(Const Buffer; Count: Longint): Longint;
Begin
  If Assigned(FOnWrite) Then
    Result := FOnWrite(Self, Buffer, Count)
  Else
    Result := -1;
End;
//=== { TJclSectoredStream } =================================================
Procedure TJclSectoredStream.AfterBlockRead;
Begin
  // override to customize (checks of protection)
End;
Procedure TJclSectoredStream.BeforeBlockWrite;
Begin
  // override to customize (computation of protection)
End;
Constructor TJclSectoredStream.Create(AStorageStream: TStream;
                                      AOwnsStream: Boolean = False;
                                      ASectorOverHead: Longint = 0);
Begin
  Inherited Create(AStorageStream, AOwnsStream);
  FSectorOverHead := ASectorOverHead;
  If Stream <> nil Then
    FPosition := SectoredToFlat(Stream.Position);
End;
Procedure TJclSectoredStream.DoAfterStreamChange;
Begin
  Inherited DoAfterStreamChange;
  If Stream <> nil Then
    FPosition := SectoredToFlat(Stream.Position);
End;
Function TJclSectoredStream.FlatToSectored(Const Position: Int64): Int64;
Begin
  Result := (Position div BufferSize) * (Int64(BufferSize) + FSectorOverHead) // add overheads of previous buffers
    + (Position mod BufferSize); // offset in sector
End;
Procedure TJclSectoredStream.Flush;
Begin
  If (Stream <> nil) and (FBufferMaxModifiedPos > 0) Then
  Begin
    BeforeBlockWrite;
    Stream.Position := FlatToSectored(FBufferStart);
    Stream.WriteBuffer(FBuffer[0], FBufferCurrentSize + FSectorOverHead);
    FBufferMaxModifiedPos := 0;
  End;
End;
Function TJclSectoredStream.GetCalcedSize: Int64;
Var
  VirtualSize: Int64;
Begin
  If Assigned(Stream) Then
    Result := SectoredToFlat(Stream.Size)
  Else
    Result := 0;
  VirtualSize := FBufferMaxModifiedPos + FBufferStart;
  If Result < VirtualSize Then
    Result := VirtualSize;
End;
Function TJclSectoredStream.LoadBuffer: Boolean;
Var
  TotalSectorSize: Longint;
Begin
  Flush;
  TotalSectorSize := FBufferSize + FSectorOverHead;
  If Length(FBuffer) <> TotalSectorSize Then
    SetLength(FBuffer, TotalSectorSize);
  FBufferStart := (FPosition div BufferSize) * BufferSize;
  If Stream <> nil Then
  Begin
    Stream.Position := FlatToSectored(FBufferStart);
    FBufferCurrentSize := Stream.Read(FBuffer[0], TotalSectorSize);
    If FBufferCurrentSize > 0 Then
    Begin
      Dec(FBufferCurrentSize, FSectorOverHead);
      AfterBlockRead;
    End;
  End
  Else
    FBufferCurrentSize := 0;
  Result := (FBufferCurrentSize > 0);
End;
Function TJclSectoredStream.SectoredToFlat(Const Position: Int64): Int64;
Var
  TotalSectorSize: Int64;
Begin
  TotalSectorSize := Int64(BufferSize) + FSectorOverHead;
  Result := (Position div TotalSectorSize) * BufferSize // remove previous overheads
    + Position mod TotalSectorSize; // offset in sector
End;
Procedure TJclSectoredStream.SetSize(Const NewSize: Int64);
Begin
  Inherited SetSize(FlatToSectored(NewSize));
End;
//=== { TJclCRC16Stream } ====================================================
Procedure TJclCRC16Stream.AfterBlockRead;
Var
  CRC: Word;
Begin
  CRC := Word(FBuffer[FBufferCurrentSize]) or (Word(FBuffer[FBufferCurrentSize + 1]) shl 8);
  If CheckCrc16(FBuffer, FBufferCurrentSize, CRC) < 0 Then
    raise EJclStreamError.CreateRes(@RsStreamsCRCError);
End;
Procedure TJclCRC16Stream.BeforeBlockWrite;
Var
  CRC: Word;
Begin
  CRC := Crc16(FBuffer, FBufferCurrentSize);
  FBuffer[FBufferCurrentSize] := CRC and $FF;
  FBuffer[FBufferCurrentSize + 1] := CRC shr 8;
End;
Constructor TJclCRC16Stream.Create(AStorageStream: TStream; AOwnsStream: Boolean);
Begin
  Inherited Create(AStorageStream, AOwnsStream, 2);
End;
//=== { TJclCRC32Stream } ====================================================
Procedure TJclCRC32Stream.AfterBlockRead;
Var
  CRC: Cardinal;
Begin
  CRC := Cardinal(FBuffer[FBufferCurrentSize]) or (Cardinal(FBuffer[FBufferCurrentSize + 1]) shl 8)
    or (Cardinal(FBuffer[FBufferCurrentSize + 2]) shl 16) or (Cardinal(FBuffer[FBufferCurrentSize + 3]) shl 24);
  If CheckCrc32(FBuffer, FBufferCurrentSize, CRC) < 0 Then
    raise EJclStreamError.CreateRes(@RsStreamsCRCError);
End;
Procedure TJclCRC32Stream.BeforeBlockWrite;
Var
  CRC: Cardinal;
Begin
  CRC := Crc32(FBuffer, FBufferCurrentSize);
  FBuffer[FBufferCurrentSize] := CRC and $FF;
  FBuffer[FBufferCurrentSize + 1] := (CRC shr 8) and $FF;
  FBuffer[FBufferCurrentSize + 2] := (CRC shr 16) and $FF;
  FBuffer[FBufferCurrentSize + 3] := (CRC shr 24) and $FF;
End;
Constructor TJclCRC32Stream.Create(AStorageStream: TStream;
  AOwnsStream: Boolean);
Begin
  Inherited Create(AStorageStream, AOwnsStream, 4);
End;
//=== { TJclSplitStream } ====================================================
Constructor TJclSplitStream.Create(AForcePosition: Boolean);
Begin
  Inherited Create;
  FVolume := nil;
  FVolumeIndex := -1;
  FVolumeMaxSize := 0;
  FPosition := 0;
  FVolumePosition := 0;
  FForcePosition := AForcePosition;
End;
Function TJclSplitStream.GetSize: Int64;
Var
  OldVolumeIndex: Integer;
  OldVolumePosition, OldPosition: Int64;
Begin
  OldVolumeIndex := FVolumeIndex;
  OldVolumePosition := FVolumePosition;
  OldPosition := FPosition;
  Result := 0;
  Try
    FVolumeIndex := -1;
    Repeat
      If not InternalLoadVolume(FVolumeIndex + 1) Then
        Break;
      Result := Result + FVolume.Size;
    Until FVolume.Size = 0;
  Finally
    InternalLoadVolume(OldVolumeIndex);
    FPosition := OldPosition;
    If Assigned(FVolume) Then
      FVolumePosition := FVolume.Seek(OldVolumePosition, soBeginning);
  End;
End;
Function TJclSplitStream.InternalLoadVolume(Index: Integer): Boolean;
Var
  OldVolumeIndex: Integer;
  OldVolumePosition: Int64;
  OldVolume: TStream;
Begin
  If Index = -1 Then
    Index := 0;
  If Index <> FVolumeIndex Then
  Begin
    // save current pointers
    OldVolumeIndex := FVolumeIndex;
    OldVolumePosition := FVolumePosition;
    OldVolume := FVolume;
    FVolumeIndex := Index;
    FVolumePosition := 0;
    FVolume := GetVolume(Index);
    Result := Assigned(FVolume);
    If Result Then Begin
      FVolumeMaxSize := GetVolumeMaxSize(Index);
      FVolume.Seek(0, soBeginning)
    End
    Else
    Begin
      // restore old pointers if volume load failed
      FVolumeIndex := OldVolumeIndex;
      FVolumePosition := OldVolumePosition;
      FVolume := OldVolume;
    End;
  End
  Else
    Result := Assigned(FVolume);
End;
Function TJclSplitStream.Read(Var Buffer; Count: Longint): Longint;
Var
  Data: PByte;
  Total, LoopRead: Longint;
Begin
  Result := 0;
  If not InternalLoadVolume(FVolumeIndex) Then
    Exit;
  Data := PByte(@Buffer);
  Total := Count;
  Repeat
    // force position
    If ForcePosition Then
      FVolume.Seek(FVolumePosition, soBeginning);
    // try to read (Count) bytes from current stream
    LoopRead := FVolume.Read(Data^, Count);
    FVolumePosition := FVolumePosition + LoopRead;
    FPosition := FPosition + LoopRead;
    Inc(Result, LoopRead);
    If Result = Total Then
      Break;
    // with next volume
    Dec(Count, LoopRead);
    Inc(Data, LoopRead);
    If not InternalLoadVolume(FVolumeIndex + 1) Then
      Break;
  Until False;
End;
Function TJclSplitStream.Seek(Const Offset: Int64;
  Origin: TSeekOrigin): Int64;
Var
  ExpectedPosition, RemainingOffset: Int64;
Begin
  Case TSeekOrigin(Origin) Of
    soBeginning:
      ExpectedPosition := Offset;
    soCurrent:
      ExpectedPosition := FPosition + Offset;
    soEnd:
      ExpectedPosition := Size + Offset;
  Else
    raise EJclStreamError.CreateRes(@RsStreamsSeekError);
  End;
  RemainingOffset := ExpectedPosition - FPosition;
  Result := FPosition;
  Repeat
    If not InternalLoadVolume(FVolumeIndex) Then
      Break;
    If RemainingOffset < 0 Then
    Begin
      // FPosition > ExpectedPosition, seek backward
      If FVolumePosition >= -RemainingOffset Then
      Begin
        // seek in current volume
        FVolumePosition := FVolume.Seek(FVolumePosition + RemainingOffset, soBeginning);
        Result := Result + RemainingOffset;
        FPosition := Result;
        RemainingOffset := 0;
      End
      Else
      Begin
        // seek to previous volume
        If FVolumeIndex = 0 Then
          Exit;
        // seek to the beginning of current volume
        RemainingOffset := RemainingOffset + FVolumePosition;
        Result := Result - FVolumePosition;
        FPosition := Result;
        FVolumePosition := FVolume.Seek(0, soBeginning);
        // load previous volume
        If not InternalLoadVolume(FVolumeIndex - 1) Then
          Break;
        Result := Result - FVolume.Size;
        FPosition := Result;
        RemainingOffset := RemainingOffset + FVolume.Size;
      End;
    End
    Else If RemainingOffset > 0 Then
    Begin
      // FPosition < ExpectedPosition, seek forward
      If (FVolumeMaxSize = 0) or ((FVolumePosition + RemainingOffset) < FVolumeMaxSize) Then
      Begin
        // can seek in current volume
        FVolumePosition := FVolume.Seek(FVolumePosition + RemainingOffset, soBeginning);
        Result := Result + RemainingOffset;
        FPosition := Result;
        RemainingOffset := 0;
      End
      Else
      Begin
        // seek to next volume
        RemainingOffset := RemainingOffset - FVolumeMaxSize + FVolumePosition;
        Result := Result + FVolumeMaxSize - FVolumePosition;
        FPosition := Result;
        If not InternalLoadVolume(FVolumeIndex + 1) Then Begin
          FVolumePosition := FVolumeMaxSize;
          Break;
        End;
      End;
    End;
  Until RemainingOffset = 0;
End;
Procedure TJclSplitStream.SetSize(Const NewSize: Int64);
Var
  OldVolumeIndex: Integer;
  OldVolumePosition, OldPosition, RemainingSize, VolumeSize: Int64;
Begin
  OldVolumeIndex := FVolumeIndex;
  OldVolumePosition := FVolumePosition;
  OldPosition := FPosition;
  RemainingSize := NewSize;
  Try
    FVolumeIndex := 0;
    Repeat
      If not InternalLoadVolume(FVolumeIndex) Then
        Break;
      If (FVolumeMaxSize > 0) and (RemainingSize > FVolumeMaxSize) Then
        VolumeSize := FVolumeMaxSize
      Else
        VolumeSize := RemainingSize;
      FVolume.Size := VolumeSize;
      RemainingSize := RemainingSize - VolumeSize;
      Inc(FVolumeIndex);
    Until RemainingSize = 0;
  Finally
    InternalLoadVolume(OldVolumeIndex);
    FPosition := OldPosition;
    If Assigned(FVolume) Then
      FVolumePosition := FVolume.Seek(OldVolumePosition, soBeginning);
  End;
End;
Function TJclSplitStream.Write(Const Buffer; Count: Longint): Longint;
Var
  Data: PByte;
  Total, LoopWritten: Longint;
Begin
  Result := 0;
  If not InternalLoadVolume(FVolumeIndex) Then
    Exit;
  Data := PByte(@Buffer);
  Total := Count;
  Repeat
    // force position
    If ForcePosition Then
      FVolume.Seek(FVolumePosition, soBeginning);
    // do not write more than (VolumeMaxSize) bytes in current stream
    If (FVolumeMaxSize > 0) and ((Count + FVolumePosition) > FVolumeMaxSize) Then
      LoopWritten := FVolumeMaxSize - FVolumePosition
    Else
      LoopWritten := Count;
    // try to write (Count) bytes from current stream
    LoopWritten := FVolume.Write(Data^, LoopWritten);
    FVolumePosition := FVolumePosition + LoopWritten;
    FPosition := FPosition + LoopWritten;
    Inc(Result, LoopWritten);
    If Result = Total Then
      Break;
    // with next volume
    Dec(Count, LoopWritten);
    Inc(Data, LoopWritten);
    If not InternalLoadVolume(FVolumeIndex + 1) Then
      Break;
  Until False;
End;
//=== { TJclDynamicSplitStream } =============================================
Function TJclDynamicSplitStream.GetVolume(Index: Integer): TStream;
Begin
  If Assigned(FOnVolume) Then
    Result := FOnVolume(Index)
  Else
    Result := nil;
End;
Function TJclDynamicSplitStream.GetVolumeMaxSize(Index: Integer): Int64;
Begin
  If Assigned(FOnVolumeMaxSize) Then
    Result := FOnVolumeMaxSize(Index)
  Else
    Result := 0;
End;
//=== { TJclStaticSplitStream } ===========================================
Constructor TJclStaticSplitStream.Create(AForcePosition: Boolean);
Begin
  Inherited Create(AForcePosition);
  FVolumes := TObjectList.Create;
End;
Destructor TJclStaticSplitStream.Destroy;
Var
  Index: Integer;
  AVolumeRec: TJclSplitVolume;
Begin
  If Assigned(FVolumes) Then
  Begin
    For Index := 0 To FVolumes.Count - 1 Do
    Begin
      AVolumeRec := TJclSplitVolume(FVolumes.Items[Index]);
      If AVolumeRec.OwnStream Then
        AVolumeRec.Stream.Free;
    End;
    FVolumes.Free;
  End;
  Inherited Destroy;
End;
Function TJclStaticSplitStream.AddVolume(AStream: TStream; AMaxSize: Int64;
  AOwnStream: Boolean): Integer;
Var
  AVolumeRec: TJclSplitVolume;
Begin
  AVolumeRec := TJclSplitVolume.Create;
  AVolumeRec.MaxSize := AMaxSize;
  AVolumeRec.Stream := AStream;
  AVolumeRec.OwnStream := AOwnStream;
  Result := FVolumes.Add(AVolumeRec);
End;
Function TJclStaticSplitStream.GetVolume(Index: Integer): TStream;
Begin
  Result := TJclSplitVolume(FVolumes.Items[Index]).Stream;
End;
Function TJclStaticSplitStream.GetVolumeCount: Integer;
Begin
  Result := FVolumes.Count;
End;
Function TJclStaticSplitStream.GetVolumeMaxSize(Index: Integer): Int64;
Begin
  Result := TJclSplitVolume(FVolumes.Items[Index]).MaxSize;
End;
//=== { TJclStringStream } ====================================================
Constructor TJclStringStream.Create(AStream: TStream; AOwnsStream: Boolean);
Begin
  Inherited Create;
  FStream := AStream;
  FOwnStream := AOwnsStream;
  FBufferSize := StreamDefaultBufferSize;
  // Must call this method so that buffer initial values are properly set.
  // This is most useful when AStream is not located at position zero
  // before being used by us.
  InvalidateBuffers;
End;
Destructor TJclStringStream.Destroy;
Begin
  Flush;
  If FOwnStream Then
    FStream.Free;
  Inherited;
End;
Procedure TJclStringStream.Flush;
Begin
  If FStrBufferModifiedSize > 0 Then
  Begin
    FStream.Position := FStrBufferStart;
    InternalSetNextBuffer(FStream, FStrBuffer, 0, FStrBufferModifiedSize);
    FStrBufferNext := FStream.Seek(0, soCurrent);
    FStrBufferModifiedSize := 0;
  End;
End;
Function TJclStringStream.InternalGetNextBuffer(S: TStream;
  Var Buffer: TUCS4Array; Start, Count: SizeInt): Longint;
Var
  Ch: UCS4;
Begin
  // override to optimize
  Result := 0;
  While Count > 0 Do
  Begin
    If InternalGetNextChar(S, Ch) Then
    Begin
      Buffer[Start] := Ch;
      Inc(Start);
      Inc(Result);
    End
    Else
      Break;
    Dec(Count);
  End;
End;
Function TJclStringStream.InternalSetNextBuffer(S: TStream;
  Const Buffer: TUCS4Array; Start, Count: SizeInt): Longint;
Begin
  // override to optimize
  Result := 0;
  While Count > 0 Do
  Begin
    If InternalSetNextChar(S, Buffer[Start]) Then
    Begin
      Inc(Start);
      Inc(Result);
    End
    Else
      Break;
    Dec(Count);
  End;
End;
Procedure TJclStringStream.InvalidateBuffers;
Begin
  FStrBufferStart := FStream.Seek(0, soCurrent);
  FStrBufferNext := FStrBufferStart;
  FStrBufferPosition := 0;
  FStrBufferCurrentSize := 0;
  FStrBufferModifiedSize := 0;
  FStrPeekBufferStart := FStrBufferStart;
  FStrPeekBufferNext := FStrBufferNext;
  FStrPeekPosition := 0;
  FStrPeekBufferCurrentSize := 0;
End;
Function TJclStringStream.LoadBuffer: Boolean;
Begin
  Flush;
  // first test if the peek buffer contains the value
  If (FStrBufferNext >= FStrPeekBufferStart) and (FStrBufferNext < FStrPeekBufferNext) Then
  Begin
    // the requested buffer is already loaded in the peek buffer
    FStrBufferStart := FStrPeekBufferStart;
    FStrBufferNext := FStrPeekBufferNext;
    If Length(FStrBuffer) <> Length(FStrPeekBuffer) Then
      SetLength(FStrBuffer, Length(FStrPeekBuffer));
    FStrBufferPosition := FStrPeekBufferPosition;
    FStrBufferCurrentSize := FStrPeekBufferCurrentSize;
    Move(FStrPeekBuffer[0], FStrBuffer[0], FStrBufferCurrentSize * SizeOf(FStrBuffer[0]));
  End
  Else
  Begin
    // load a new buffer
    If Length(FStrBuffer) <> FBufferSize Then
      SetLength(FStrBuffer, FBufferSize);
    Inc(FStrBufferPosition, FStrBufferCurrentSize);
    FStrBufferStart := FStrBufferNext;
    FStream.Seek(FStrBufferStart, soBeginning);
    FStrBufferCurrentSize := InternalGetNextBuffer(FStream, FStrBuffer, 0, FBufferSize);
    FStrBufferNext := FStream.Seek(0, soCurrent);
    // reset the peek buffer
    FStrPeekBufferPosition := FStrBufferPosition + FStrBufferCurrentSize;
    FStrPeekBufferCurrentSize := 0;
    FStrPeekBufferNext := FStrBufferNext;
    FStrPeekBufferStart := FStrBufferNext;
  End;
  Result := (FStrPosition >= FStrBufferPosition) and (FStrPosition < (FStrBufferPosition + FStrBufferCurrentSize));
End;
Function TJclStringStream.LoadPeekBuffer: Boolean;
Begin
  If Length(FStrPeekBuffer) <> FBufferSize Then
    SetLength(FStrPeekBuffer, FBufferSize);
  If FStrPeekBufferPosition > FStrPeekPosition Then
  Begin
    // the peek position is rolling back, load the buffer after the read buffer
    FStrPeekBufferPosition := FStrBufferPosition;
    FStrPeekBufferCurrentSize := FStrBufferCurrentSize;
    FStrPeekBufferStart := FStrBufferStart;
    FStrPeekBufferNext := FStrBufferNext;
  End;
  FStrPeekBufferStart := FStrPeekBufferNext;
  Inc(FStrPeekBufferPosition, FStrPeekBufferCurrentSize);
  FStream.Seek(FStrPeekBufferStart, soBeginning);
  FStrPeekBufferCurrentSize := InternalGetNextBuffer(FStream, FStrPeekBuffer, 0, FBufferSize);
  FStrPeekBufferNext := FStream.Seek(0, soCurrent);
  Result := (FStrPeekPosition >= FStrPeekBufferPosition) and (FStrPeekPosition < (FStrPeekBufferPosition + FStrPeekBufferCurrentSize));
End;
Function TJclStringStream.PeekUCS4(out Buffer: UCS4): Boolean;
Begin
  If (FStrPeekPosition >= FStrPeekBufferPosition) and (FStrPeekPosition < (FStrPeekBufferPosition + FStrPeekBufferCurrentSize)) Then
  Begin
    // read from the peek buffer
    Result := True;
    Buffer := FStrPeekBuffer[FStrPeekPosition - FStrPeekBufferPosition];
    Inc(FStrPeekPosition);
  End
  Else
  If (FStrPeekPosition >= FStrBufferPosition) and (FStrPeekPosition < (FStrBufferPosition + FStrBufferCurrentSize)) Then
  Begin
    // read from the read/write buffer
    Result := True;
    Buffer := FStrBuffer[FStrPeekPosition - FStrBufferPosition];
    Inc(FStrPeekPosition);
  End
  Else
  Begin
    // load a new peek buffer
    Result := LoadPeekBuffer;
    If Result Then
    Begin
      Buffer := FStrPeekBuffer[FStrPeekPosition - FStrPeekBufferPosition];
      Inc(FStrPeekPosition);
    End;
  End;
End;
Function TJclStringStream.PeekWideChar(out Buffer: WideChar): Boolean;
Var
  Ch: UCS4;
Begin
  Result := PeekUCS4(Ch);
  If Result Then
    Buffer := UCS4ToWideChar(Ch);
End;
Function TJclStringStream.ReadUCS4(out Buffer: UCS4): Boolean;
Begin
  If (FStrPosition >= FStrBufferPosition) and (FStrPosition < (FStrBufferPosition + FStrBufferCurrentSize)) Then
  Begin
    // load from buffer
    Result := True;
    Buffer := FStrBuffer[FStrPosition - FStrBufferPosition];
    Inc(FStrPosition);
  End
  Else
  Begin
    // load a new buffer
    Result := LoadBuffer;
    If Result Then
    Begin
      Buffer := FStrBuffer[FStrPosition - FStrBufferPosition];
      Inc(FStrPosition);
    End;
  End;
  FStrPeekPosition := FStrPosition;
End;
Function TJclStringStream.ReadWideChar(out Buffer: WideChar): Boolean;
Var
  Ch: UCS4;
Begin
  Result := ReadUCS4(Ch);
  If Result Then
    Buffer := UCS4ToWideChar(Ch);
End;
Function TJclStringStream.Seek(Const Offset: Int64; Origin: TSeekOrigin): Int64;
Begin
  Case Origin Of
    soBeginning:
      If Offset = 0 Then
      Begin
        Flush;
        FStrPosition := 0;
        FStrBufferPosition := 0;
        FStrBufferCurrentSize := 0;
        FStrBufferStart := 0;
        FStrBufferNext := 0;
        FStrPeekBufferPosition := 0;
        FStrPeekBufferCurrentSize := 0;
        FStrPeekBufferStart := 0;
        FStrPeekBufferNext := 0;
      End
      Else
        raise EJclStreamError.CreateRes(@RsStreamsSeekError);
    soCurrent:
      If Offset <> 0 Then
        raise EJclStreamError.CreateRes(@RsStreamsSeekError);
    soEnd:
      raise EJclStreamError.CreateRes(@RsStreamsSeekError);
  End;
  Result := FStrPosition;
  FStrPeekPosition := FStrPosition;
End;
Function TJclStringStream.SkipBOM: Longint;
Var
  Pos: Int64;
  I: Integer;
  BOM: array Of Byte;
Begin
  If Length(FBOM) > 0 Then
  Begin
    Pos := FStream.Seek(0, soCurrent);
    SetLength(BOM, Length(FBOM));
    Result := FStream.Read(BOM[0], Length(BOM) * SizeOf(BOM[0]));
    If Result = Length(FBOM) * SizeOf(FBOM[0]) Then
      For I := Low(FBOM) To High(FBOM) Do
        If BOM[I - Low(FBOM)] <> FBOM[I] Then
          Result := 0;
    If Result <> Length(FBOM) * SizeOf(FBOM[0]) Then
      FStream.Seek(Pos, soBeginning);
  End
  Else
    Result := 0;
  InvalidateBuffers;
End;
Function TJclStringStream.WriteBOM: Longint;
Begin
  If Length(FBOM) > 0 Then
    Result := FStream.Write(FBOM[0], Length(FBOM) * SizeOf(FBOM[0]))
  Else
    Result := 0;
  InvalidateBuffers;
End;
Function TJclStringStream.WriteUCS4(Value: UCS4): Boolean;
Var
  BufferPos: Int64;
Begin
  If FStrPosition >= (FStrBufferPosition + FBufferSize) Then
    // load the next buffer first
    LoadBuffer;
  // write to current buffer
  BufferPos := FStrPosition - FStrBufferPosition;
  Result := True;
  If Length(FStrBuffer) <> FBufferSize Then
    SetLength(FStrBuffer, FBufferSize);
  FStrBuffer[BufferPos] := Value;
  Inc(FStrPosition);
  Inc(BufferPos);
  If FStrBufferModifiedSize < BufferPos Then
    FStrBufferModifiedSize := BufferPos;
  If FStrBufferCurrentSize < BufferPos Then
    FStrBufferCurrentSize := BufferPos;
  FStrPeekPosition := FStrPosition;
End;
Function TJclStringStream.WriteWideChar(Value: WideChar): Boolean;
Begin
  Result := WriteUCS4(WideCharToUCS4(Value));
End;
//=== { TJclAnsiStream } ======================================================
Constructor TJclAnsiStream.Create(AStream: TStream; AOwnsStream: Boolean);
Begin
  Inherited Create(AStream, AOwnsStream);
  SetLength(FBOM, 0);
  FCodePage := CP_ACP;
End;
Constructor TJclUTF8Stream.Create(AStream: TStream; AOwnsStream: Boolean);
Var
  I: Integer;
Begin
  Inherited Create(AStream, AOwnsStream);
  SetLength(FBOM, Length(BOM_UTF8));
  For I := Low(BOM_UTF8) To High(BOM_UTF8) Do
    FBOM[I - Low(BOM_UTF8)] := BOM_UTF8[I];
End;
//=== { TJclUTF16Stream } =====================================================
Constructor TJclUTF16Stream.Create(AStream: TStream; AOwnsStream: Boolean);
Var
  I: Integer;
Begin
  Inherited Create(AStream, AOwnsStream);
  SetLength(FBOM, Length(BOM_UTF16_LSB));
  For I := Low(BOM_UTF16_LSB) To High(BOM_UTF16_LSB) Do
    FBOM[I - Low(BOM_UTF16_LSB)] := BOM_UTF16_LSB[I];
End;
Constructor TJclAutoStream.Create(AStream: TStream; AOwnsStream: Boolean);
Var
  I, MaxLength, ReadLength: Integer;
  BOM: array Of Byte;
Begin
  Inherited Create(AStream, AOwnsStream);
  MaxLength := Length(BOM_UTF8);
  If MaxLength < Length(BOM_UTF16_LSB) Then
    MaxLength := Length(BOM_UTF16_LSB);
  SetLength(BOM, MaxLength);
  ReadLength := FStream.Read(BOM[0], Length(BOM) * SizeOf(BOM[0])) div SizeOf(BOM[0]);
  FEncoding := seAuto;
  // try UTF8 BOM
  If (FEncoding = seAuto) and (ReadLength >= Length(BOM_UTF8) * SizeOf(BOM_UTF8[0])) Then
  Begin
    FCodePage := CP_UTF8;
    FEncoding := seUTF8;
    For I := Low(BOM_UTF8) To High(BOM_UTF8) Do
      If BOM[I - Low(BOM_UTF8)] <> BOM_UTF8[I] Then
    Begin
      FEncoding := seAuto;
      Break;
    End;
  End;
  // try UTF16 BOM
  If (FEncoding = seAuto) and (ReadLength >= Length(BOM_UTF16_LSB) * SizeOf(BOM_UTF16_LSB[0])) Then
  Begin
    FCodePage := CP_UTF16LE;
    FEncoding := seUTF16;
    For I := Low(BOM_UTF16_LSB) To High(BOM_UTF16_LSB) Do
      If BOM[I - Low(BOM_UTF8)] <> BOM_UTF16_LSB[I] Then
    Begin
      FEncoding := seAuto;
      Break;
    End;
  End;
  Case FEncoding Of
    seUTF8:
      Begin
        FCodePage := CP_UTF8;
        SetLength(FBOM, Length(BOM_UTF8));
        For I := Low(BOM_UTF8) To High(BOM_UTF8) Do
          FBOM[I - Low(BOM_UTF8)] := BOM_UTF8[I];
      End;
    seUTF16:
      Begin
        FCodePage := CP_UTF16LE;
        SetLength(FBOM, Length(BOM_UTF16_LSB));
        For I := Low(BOM_UTF16_LSB) To High(BOM_UTF16_LSB) Do
          FBOM[I - Low(BOM_UTF16_LSB)] := BOM_UTF16_LSB[I];
      End;
    seAuto,
    seAnsi:
      Begin
        // defaults to Ansi
        FCodePage := CP_ACP;
        FEncoding := seAnsi;
        SetLength(FBOM, 0);
      End;
  End;
  FStream.Seek(Length(FBOM) - ReadLength, soCurrent);
  InvalidateBuffers;
End;
Procedure TJclAutoStream.SetCodePage(Value: Word);
Begin
  If Value = CP_UTF8 Then
    FEncoding := seUTF8
  Else
  If Value = CP_UTF16LE Then
    FEncoding := seUTF16
  Else
  If Value = CP_ACP Then
    FEncoding := seAnsi
  Else
    FEncoding := seAuto;
  FCodePage := Value;
End;
Function TJclAutoStream.SkipBOM: LongInt;
Begin
  // already skipped to determine encoding
  Result := 0;
  InvalidateBuffers;
End;
{$IFDEF UNITVERSIONING}
Initialization
 RegisterUnitVersion(HInstance, UnitVersioning);
Finalization
 UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
End.
